#!/usr/bin/env bash
# Score humanize-it rewrites against brandonwise/humanizer as oracle.
# Usage: ./run.sh [fixture-glob]
# Env:   HUMANIZER=path/to/humanizer  THRESHOLD=25  CLAUDE=path/to/claude

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_DIR="$(dirname "$SCRIPT_DIR")"
# Override which fixture set to score: FIXTURES_DIR=samples/hc3 ./run.sh
FIXTURES_DIR="${FIXTURES_DIR:-$SCRIPT_DIR/fixtures}"
OUTPUTS_DIR="$SCRIPT_DIR/outputs"
HUMANIZER="${HUMANIZER:-humanizer}"
CLAUDE="${CLAUDE:-claude}"
THRESHOLD="${THRESHOLD:-25}"

mkdir -p "$OUTPUTS_DIR"

# Dependency check
command -v "$CLAUDE" >/dev/null 2>&1 || { echo "ERROR: claude CLI not found. Install Claude Code." >&2; exit 1; }
command -v "$HUMANIZER" >/dev/null 2>&1 || { echo "ERROR: brandonwise humanizer not found. Run: cd /tmp && git clone https://github.com/brandonwise/humanizer && cd humanizer && npm install -g ." >&2; exit 1; }

# Fixture filter (default: all)
PATTERN="${1:-*.md}"

extract_score() {
    grep -oE '[0-9]+/100' | head -1 | cut -d/ -f1
}

# Header
printf "%-40s | %6s | %6s | %6s | %6s | %s\n" "fixture" "before" "after" "human" "delta" "result"
printf "%-40s-+-%6s-+-%6s-+-%6s-+-%6s-+-%s\n" "$(printf -- '-%.0s' {1..40})" "------" "------" "------" "------" "--------"

pass=0
fail=0
void=0
total=0

for fixture in "$FIXTURES_DIR"/$PATTERN; do
    [[ -f "$fixture" ]] || continue
    # Skip .human.md sidecars (HC3 reference answers — not meant to be rewritten)
    [[ "$fixture" == *.human.md ]] && continue
    total=$((total + 1))
    name=$(basename "$fixture" .md)
    text=$(cat "$fixture")

    # Score original
    before=$(printf "%s" "$text" | "$HUMANIZER" score 2>/dev/null | extract_score)

    # Score human reference if a sidecar exists (HC3-style paired data)
    human_score="-"
    human_path="${fixture%.md}.human.md"
    if [[ -f "$human_path" ]]; then
        human_score=$(cat "$human_path" | "$HUMANIZER" score 2>/dev/null | extract_score)
        [[ -z "$human_score" ]] && human_score="-"
    fi

    # Get rewrite via headless Claude Code (load plugin from local repo)
    rewrite=$("$CLAUDE" --plugin-dir "$PLUGIN_DIR" -p "/humanize-it:humanize $text" 2>/dev/null | sed -e '/^$/d' || true)
    printf "%s\n" "$rewrite" > "$OUTPUTS_DIR/$name.out.md"

    # Special case: void flag
    if [[ "$rewrite" == *"(no substantive content"* ]]; then
        printf "%-40s | %6s | %6s | %6s | %6s | %s\n" "$name" "$before" "void" "$human_score" "—" "✓ void-flag"
        void=$((void + 1))
        continue
    fi

    # Score rewrite
    after=$(printf "%s" "$rewrite" | "$HUMANIZER" score 2>/dev/null | extract_score)
    if [[ -z "$after" ]]; then after=0; fi

    delta=$((before - after))

    # Monotonicity check: rewrite must not introduce tells the source didn't have.
    # Brace-group + `|| true` defangs grep's exit-1-on-no-match under set -o pipefail.
    count_pat() { printf "%s" "$1" | { grep -oE "$2" || true; } | wc -l; }
    # Count markdown list items (lines starting with -, *, or N.)
    count_lists() { printf "%s" "$1" | { grep -cE '^\s*([-*]\s|[0-9]+\.\s)' || true; }; }
    # Count occurrences of leak patterns (case-insensitive fixed strings from leak-patterns.txt)
    count_leaks() {
        local patterns_file="$SCRIPT_DIR/leak-patterns.txt"
        [[ -f "$patterns_file" ]] || { echo 0; return; }
        # Strip comments + blanks, then count occurrences via grep -Foi
        local active_patterns
        active_patterns=$(grep -vE '^\s*(#|$)' "$patterns_file")
        [[ -z "$active_patterns" ]] && { echo 0; return; }
        printf "%s" "$1" | { grep -Foi -f <(echo "$active_patterns") || true; } | wc -l
    }

    src_em=$(count_pat "$text" "—")
    out_em=$(count_pat "$rewrite" "—")
    src_bold=$(count_pat "$text" '\*\*[^*]+\*\*')
    out_bold=$(count_pat "$rewrite" '\*\*[^*]+\*\*')
    src_curly=$(count_pat "$text" '[“”‘’]')
    out_curly=$(count_pat "$rewrite" '[“”‘’]')
    src_lists=$(count_lists "$text")
    out_lists=$(count_lists "$rewrite")
    src_leaks=$(count_leaks "$text")
    out_leaks=$(count_leaks "$rewrite")

    mono_violations=()
    (( out_em > src_em ))       && mono_violations+=("em-dash $src_em→$out_em")
    (( out_bold > src_bold ))   && mono_violations+=("bold $src_bold→$out_bold")
    (( out_curly > src_curly )) && mono_violations+=("curly-quote $src_curly→$out_curly")
    (( out_lists > src_lists )) && mono_violations+=("md-list $src_lists→$out_lists")
    (( out_leaks > src_leaks )) && mono_violations+=("leak-phrase $src_leaks→$out_leaks")

    if (( ${#mono_violations[@]} > 0 )); then
        IFS=', '; result="✗ fail (mono: ${mono_violations[*]})"; unset IFS
        fail=$((fail + 1))
    elif (( after < THRESHOLD )); then
        result="✓ pass"
        pass=$((pass + 1))
    else
        result="✗ fail (>=$THRESHOLD)"
        fail=$((fail + 1))
    fi

    printf "%-40s | %6s | %6s | %6s | %+6d | %s\n" "$name" "$before" "$after" "$human_score" "$delta" "$result"
done

echo ""
echo "Summary: $pass pass, $fail fail, $void void-flag, $total total. Threshold: <$THRESHOLD."
echo "Rewrites saved to $OUTPUTS_DIR/."

# Exit non-zero if any fixture failed
[[ $fail -eq 0 ]]
