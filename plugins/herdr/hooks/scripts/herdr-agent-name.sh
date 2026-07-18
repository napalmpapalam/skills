#!/bin/sh
# Custom (not managed by herdr): name the herdr agent after Claude's own chat
# title (the "ai-title" summary Claude generates and updates each turn), so the
# sidebar shows a meaningful title instead of "claude". Falls back to the
# submitted prompt until Claude has generated a title.
set -eu

[ -n "${HERDR_PANE_ID:-}" ] || exit 0          # only inside a herdr pane
command -v herdr >/dev/null 2>&1 || exit 0
command -v python3 >/dev/null 2>&1 || exit 0

HOOK_JSON="$(cat 2>/dev/null || true)"
export HOOK_JSON

python3 <<'PY'
import json, os, subprocess

pane = os.environ["HERDR_PANE_ID"]
try:
    data = json.loads(os.environ.get("HOOK_JSON") or "{}")
except Exception:
    data = {}

title = None

# Preferred source: the LAST ai-title entry in the transcript (Claude's summary).
tx = data.get("transcript_path")
if tx and os.path.exists(tx):
    try:
        with open(tx, encoding="utf-8") as f:
            for line in f:
                line = line.strip()
                if not line:
                    continue
                try:
                    d = json.loads(line)
                except Exception:
                    continue
                if d.get("type") == "ai-title" and d.get("aiTitle"):
                    title = d["aiTitle"]        # keep overwriting -> ends on latest
    except Exception:
        pass

# Fallback: the just-submitted prompt (present on UserPromptSubmit), used only
# early in a session before Claude has produced an ai-title.
if not title:
    title = data.get("prompt")

if not title:
    raise SystemExit(0)

title = " ".join(str(title).split())
if len(title) > 48:
    title = title[:47].rstrip() + "…"

subprocess.run(["herdr", "agent", "rename", pane, title],
               capture_output=True, text=True, timeout=5)
PY
