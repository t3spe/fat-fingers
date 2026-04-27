#!/usr/bin/env bash
# Score humanize-it rewrites against brandonwise/humanizer as oracle.
# Usage: ./run.sh [fixture-glob]
# Env:   HUMANIZER=path/to/humanizer  THRESHOLD=25  CLAUDE=path/to/claude

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_DIR="$(dirname "$SCRIPT_DIR")"
FIXTURES_DIR="$SCRIPT_DIR/fixtures"
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
printf "%-32s | %6s | %6s | %6s | %s\n" "fixture" "before" "after" "delta" "result"
printf "%-32s-+-%6s-+-%6s-+-%6s-+-%s\n" "$(printf -- '-%.0s' {1..32})" "------" "------" "------" "--------"

pass=0
fail=0
void=0
total=0

for fixture in "$FIXTURES_DIR"/$PATTERN; do
    [[ -f "$fixture" ]] || continue
    total=$((total + 1))
    name=$(basename "$fixture" .md)
    text=$(cat "$fixture")

    # Score original
    before=$(printf "%s" "$text" | "$HUMANIZER" score 2>/dev/null | extract_score)

    # Get rewrite via headless Claude Code (load plugin from local repo)
    rewrite=$("$CLAUDE" --plugin-dir "$PLUGIN_DIR" -p "/humanize-it:humanize $text" 2>/dev/null | sed -e '/^$/d' || true)
    printf "%s\n" "$rewrite" > "$OUTPUTS_DIR/$name.out.md"

    # Special case: void flag
    if [[ "$rewrite" == *"(no substantive content"* ]]; then
        printf "%-32s | %6s | %6s | %6s | %s\n" "$name" "$before" "void" "—" "✓ void-flag"
        void=$((void + 1))
        continue
    fi

    # Score rewrite
    after=$(printf "%s" "$rewrite" | "$HUMANIZER" score 2>/dev/null | extract_score)
    if [[ -z "$after" ]]; then after=0; fi

    delta=$((before - after))

    # Monotonicity check: rewrite must not introduce tells the source didn't have.
    # Currently checks em dashes (the most common LLM-leak even with the rule in place).
    # Brace-group + `|| true` defangs grep's exit-1-on-no-match under set -o pipefail.
    src_em=$(printf "%s" "$text" | { grep -o "—" || true; } | wc -l)
    out_em=$(printf "%s" "$rewrite" | { grep -o "—" || true; } | wc -l)
    mono_ok=1
    if (( out_em > src_em )); then
        mono_ok=0
    fi

    if (( after < THRESHOLD )) && (( mono_ok == 1 )); then
        result="✓ pass"
        pass=$((pass + 1))
    elif (( mono_ok == 0 )); then
        result="✗ fail (mono: em-dash $src_em→$out_em)"
        fail=$((fail + 1))
    else
        result="✗ fail (>=$THRESHOLD)"
        fail=$((fail + 1))
    fi

    printf "%-32s | %6s | %6s | %+6d | %s\n" "$name" "$before" "$after" "$delta" "$result"
done

echo ""
echo "Summary: $pass pass, $fail fail, $void void-flag, $total total. Threshold: <$THRESHOLD."
echo "Rewrites saved to $OUTPUTS_DIR/."

# Exit non-zero if any fixture failed
[[ $fail -eq 0 ]]
