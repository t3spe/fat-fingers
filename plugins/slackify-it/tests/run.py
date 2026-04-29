#!/usr/bin/env python3
"""Test slackify-it against fixtures using deterministic property checks.

No external oracle — slackify rules are deterministic enough that grep-style
property assertions are sufficient. Universal checks apply to every fixture;
class-specific checks are dispatched by filename prefix.

Usage:
  ./run.py                       # run all fixtures
  ./run.py 'email-*.md'          # glob filter
  ./run.py --verbose             # show full rewrite for each fixture
"""

import argparse
import re
import subprocess
import sys
from pathlib import Path

SCRIPT_DIR = Path(__file__).resolve().parent
PLUGIN_DIR = SCRIPT_DIR.parent
FIXTURES_DIR = SCRIPT_DIR / "fixtures"
OUTPUTS_DIR = SCRIPT_DIR / "outputs"


# --- Universal checks (apply to every fixture) ---

def check_no_double_asterisk(out):
    """Slack uses single asterisks for bold; double is invalid."""
    if "**" in out:
        return "contains '**' (Slack bold is single asterisks)"
    return None


def check_no_markdown_headers(out):
    """Slack doesn't render # / ## headers in default mode."""
    for line in out.splitlines():
        stripped = line.lstrip()
        if re.match(r'^#{1,6}\s', stripped):
            return f"contains markdown header line: {stripped[:40]!r}"
    return None


def check_no_markdown_links(out):
    """Slack uses <url|text>, not [text](url)."""
    if re.search(r'\[[^\]]+\]\([^)]+\)', out):
        return "contains markdown link [text](url) — should be <url|text>"
    return None


def check_under_4000_chars(out):
    """Slack hard recommended max."""
    if len(out) > 4000:
        return f"output is {len(out)} chars (>4000 max)"
    return None


def check_no_markdown_table(out):
    """Slack doesn't render markdown tables."""
    for line in out.splitlines():
        if re.match(r'^\s*\|.+\|\s*$', line):
            return "contains markdown table syntax (|...|) — Slack doesn't render tables"
    return None


UNIVERSAL_CHECKS = [
    check_no_double_asterisk,
    check_no_markdown_headers,
    check_no_markdown_links,
    check_under_4000_chars,
    check_no_markdown_table,
]


# --- Class-specific checks (dispatched by filename prefix) ---

EMAIL_GREETINGS = ["Hi team", "Hello team", "Dear team", "Hey everyone", "Hi all", "Hello all", "Dear all", "Good morning team", "Hi folks", "Hey team"]
EMAIL_SIGNOFFS = ["Best regards", "Best,", "Sincerely", "Cheers,", "Kind regards", "Warm regards"]


def check_strips_email_greeting(out):
    for g in EMAIL_GREETINGS:
        if g.lower() in out.lower():
            return f"contains email greeting: {g!r}"
    return None


def check_strips_email_signoff(out):
    for s in EMAIL_SIGNOFFS:
        if s.lower() in out.lower():
            return f"contains email sign-off: {s!r}"
    return None


def check_short_stays_brief(out):
    if len(out) > 150:
        return f"output is {len(out)} chars; short pings should stay <150"
    return None


def check_ack_suggests_reaction(out):
    if "consider reacting" not in out.lower() and "react" not in out.lower():
        return "expected reaction suggestion (e.g. 'consider reacting with 👍') — not found"
    return None


def check_long_has_tldr_or_thread(out):
    lower = out.lower()
    if "tl;dr" not in lower and "thread" not in lower:
        return "long-form rewrite should include TL;DR or thread suggestion"
    return None


def check_no_casual_broadcast(out):
    # Strip casual @channel/@everyone/@here from greetings.
    # Allow Slack-formatted broadcasts (<!channel>, <!everyone>, <!here>) — those are intentional.
    if re.search(r'(?<![<!])@(channel|everyone|here)\b', out, re.IGNORECASE):
        return "contains casual @channel/@everyone/@here broadcast — should be stripped"
    return None


CLASS_CHECKS = {
    "email": [check_strips_email_greeting, check_strips_email_signoff],
    "short": [check_short_stays_brief],
    "ack": [check_ack_suggests_reaction],
    "long": [check_long_has_tldr_or_thread],
    "broadcast": [check_no_casual_broadcast],
    # markdown / table / headers fixtures rely on universal checks alone.
}


def get_class_for(name):
    """Filename prefix → class name (e.g. 'email-01-foo' → 'email')."""
    parts = name.split("-", 1)
    return parts[0] if parts else None


def slackify(text):
    """Invoke the skill via headless claude. Returns (output, error_msg)."""
    try:
        result = subprocess.run(
            ["claude", "--plugin-dir", str(PLUGIN_DIR), "-p", f"/slackify-it:slackify {text}"],
            capture_output=True, text=True, timeout=120,
        )
    except subprocess.TimeoutExpired:
        return ("", "claude -p timed out after 120s")
    except FileNotFoundError:
        return ("", "claude CLI not found")
    if result.returncode != 0:
        return (result.stdout, f"claude exited {result.returncode}: {result.stderr.strip()[:200]}")
    return (result.stdout.strip(), None)


def run_fixture(path, verbose):
    """Run a single fixture. Returns (output, list_of_violations)."""
    text = path.read_text()
    output, err = slackify(text)
    OUTPUTS_DIR.mkdir(exist_ok=True)
    (OUTPUTS_DIR / f"{path.stem}.out.md").write_text(output + "\n")

    violations = []
    if err:
        violations.append(f"runtime: {err}")
        return output, violations

    # Universal checks
    for check in UNIVERSAL_CHECKS:
        v = check(output)
        if v:
            violations.append(v)

    # Class-specific checks
    cls = get_class_for(path.stem)
    if cls in CLASS_CHECKS:
        for check in CLASS_CHECKS[cls]:
            v = check(output)
            if v:
                violations.append(v)

    return output, violations


def main():
    p = argparse.ArgumentParser(description=__doc__.split("\n", 1)[0])
    p.add_argument("pattern", nargs="?", default="*.md", help="fixture glob (default: *.md)")
    p.add_argument("--verbose", "-v", action="store_true", help="print full rewrite for each fixture")
    args = p.parse_args()

    fixtures = sorted(FIXTURES_DIR.glob(args.pattern))
    if not fixtures:
        print(f"No fixtures matched {args.pattern!r} in {FIXTURES_DIR}", file=sys.stderr)
        return 1

    print(f"{'fixture':<42} | {'chars':>6} | result")
    print(f"{'-' * 42}-+-{'-' * 6}-+-{'-' * 40}")

    pass_count = 0
    fail_count = 0
    for fixture in fixtures:
        output, violations = run_fixture(fixture, args.verbose)
        chars = len(output)
        if violations:
            result = f"✗ fail: {'; '.join(violations[:2])}"
            fail_count += 1
        else:
            result = "✓ pass"
            pass_count += 1
        print(f"{fixture.stem:<42} | {chars:>6} | {result}")
        if args.verbose:
            print(f"    {output[:300]!r}")
            print()

    print()
    print(f"Summary: {pass_count} pass, {fail_count} fail, {len(fixtures)} total")
    print(f"Rewrites saved to {OUTPUTS_DIR}/")
    return 0 if fail_count == 0 else 1


if __name__ == "__main__":
    sys.exit(main())
