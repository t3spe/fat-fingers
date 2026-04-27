#!/usr/bin/env bash
# Download external slop corpora into tests/corpora/ for sampling into fixtures.
# Idempotent: skips files that already exist (use --force to re-download).
# Files land in a gitignored directory; total ~1.5 GB after full run.
#
# Usage:
#   ./download-corpora.sh             # download missing files
#   ./download-corpora.sh --force     # re-download everything
#   ./download-corpora.sh --check     # report sizes, no downloads

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CORPORA_DIR="$SCRIPT_DIR/corpora"

FORCE=0
CHECK_ONLY=0
case "${1:-}" in
    --force) FORCE=1 ;;
    --check) CHECK_ONLY=1 ;;
    --help|-h) sed -n '2,11p' "$0" | sed 's/^# //;s/^#//'; exit 0 ;;
    "") ;;
    *) echo "Unknown arg: $1" >&2; exit 1 ;;
esac

mkdir -p "$CORPORA_DIR"/{hc3,raid,slop-forensics}

# download_if_needed <url> <out-path> <human-label>
download_if_needed() {
    local url="$1" out="$2" label="$3"
    if [[ -f "$out" && $FORCE -eq 0 ]]; then
        printf "  ✓ %-50s (cached, %s)\n" "$label" "$(du -h "$out" | cut -f1)"
        return 0
    fi
    if [[ $CHECK_ONLY -eq 1 ]]; then
        printf "  ✗ %-50s (missing)\n" "$label"
        return 0
    fi
    printf "  ↓ %-50s ... " "$label"
    if curl -fsSL --retry 3 --retry-delay 2 -o "$out.tmp" "$url"; then
        mv "$out.tmp" "$out"
        printf "done (%s)\n" "$(du -h "$out" | cut -f1)"
    else
        rm -f "$out.tmp"
        printf "FAILED\n" >&2
        return 1
    fi
}

echo "=== HC3 (Human-ChatGPT Comparison Corpus, ~140 MB) ==="
echo "    Source: https://huggingface.co/datasets/Hello-SimpleAI/HC3"
HC3_BASE="https://huggingface.co/datasets/Hello-SimpleAI/HC3/resolve/main"
download_if_needed "$HC3_BASE/all.jsonl"          "$CORPORA_DIR/hc3/all.jsonl"          "all.jsonl (combined, ~70 MB)"
download_if_needed "$HC3_BASE/finance.jsonl"      "$CORPORA_DIR/hc3/finance.jsonl"      "finance.jsonl"
download_if_needed "$HC3_BASE/medicine.jsonl"     "$CORPORA_DIR/hc3/medicine.jsonl"     "medicine.jsonl"
download_if_needed "$HC3_BASE/open_qa.jsonl"      "$CORPORA_DIR/hc3/open_qa.jsonl"      "open_qa.jsonl"
download_if_needed "$HC3_BASE/reddit_eli5.jsonl"  "$CORPORA_DIR/hc3/reddit_eli5.jsonl"  "reddit_eli5.jsonl"
download_if_needed "$HC3_BASE/wiki_csai.jsonl"    "$CORPORA_DIR/hc3/wiki_csai.jsonl"    "wiki_csai.jsonl"

echo ""
echo "=== RAID test split (~1.2 GB) ==="
echo "    Source: https://huggingface.co/datasets/liamdugan/raid"
download_if_needed \
    "https://huggingface.co/datasets/liamdugan/raid/resolve/main/test.csv" \
    "$CORPORA_DIR/raid/test.csv" \
    "test.csv (~1.2 GB)"

echo ""
echo "=== slop-forensics canonical lists (~25 KB) ==="
echo "    Source: https://github.com/sam-paech/slop-forensics"
SLOP_BASE="https://raw.githubusercontent.com/sam-paech/slop-forensics/main/data"
download_if_needed "$SLOP_BASE/slop_list.json"           "$CORPORA_DIR/slop-forensics/slop_list.json"           "slop_list.json"
download_if_needed "$SLOP_BASE/slop_list_bigrams.json"   "$CORPORA_DIR/slop-forensics/slop_list_bigrams.json"   "slop_list_bigrams.json"
download_if_needed "$SLOP_BASE/slop_list_trigrams.json"  "$CORPORA_DIR/slop-forensics/slop_list_trigrams.json"  "slop_list_trigrams.json"

echo ""
echo "=== Summary ==="
if [[ -d "$CORPORA_DIR" ]]; then
    du -sh "$CORPORA_DIR"/*/ 2>/dev/null | sort -hr
    echo "    ----------"
    printf "    Total: %s\n" "$(du -sh "$CORPORA_DIR" | cut -f1)"
fi
