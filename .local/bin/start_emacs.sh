#!/usr/bin/env bash

MODE="scratchpad"   # scratchpad | no-scratchpad
case "${1:-}" in
  "" ) ;;
  --no-scratchpad ) MODE="no-scratchpad" ;;
  -h|--help )
    echo "Usage: $0 [--no-scratchpad]"
    exit 0
    ;;
  * )
    echo "Unknown argument: $1" >&2
    exit 2
    ;;
esac

LOG="${XDG_STATE_HOME:-$HOME/.local/state}/emacs-scratchpad.log"
mkdir -p "$(dirname "$LOG")"
exec >>"$LOG" 2>&1

echo "=== $(date -Is) emacs-scratchpad (${MODE}) ==="
echo "PATH=$PATH"

need_cmd() { command -v "$1" >/dev/null 2>&1 || { echo "missing command: $1"; exit 1; }; }
need_cmd swaymsg
need_cmd emacsclient

TITLE="scratch-emacs"

tree_has_title() {
  swaymsg -t get_tree | grep -q "$TITLE"
}

# If it already exists, do nothing (or optionally show it)
if tree_has_title; then
  echo "Found existing '$TITLE' in sway tree. Not starting anything."
  if [[ "$MODE" == "scratchpad" ]]; then
    # If it's already in scratchpad, this just reveals it; if it isn't, it will show wherever it is.
    swaymsg "[title=\"$TITLE\"] scratchpad show" || true
  fi
  exit 0
fi

echo "No existing '$TITLE' window found -> ensuring Emacs server exists"

# Ensure daemon/server is up (start daemon only if needed)
if ! emacsclient -e t >/dev/null 2>&1; then
  echo "Emacs server not reachable -> starting daemon"
  emacs --daemon >/dev/null 2>&1 || { echo "failed to start emacs --daemon"; exit 1; }
fi

# Wait until server responds
for i in $(seq 1 100); do
  if emacsclient -e t >/dev/null 2>&1; then
    echo "Emacs server is up"
    break
  fi
  sleep 0.05
done

echo "Creating frame '$TITLE'"
emacsclient -c -n -F "((title . \"$TITLE\") (name . \"$TITLE\"))" >/dev/null 2>&1

if [[ "$MODE" == "no-scratchpad" ]]; then
  echo "Mode no-scratchpad -> leaving frame unmanaged"
  exit 0
fi

# Move/show the newly created frame in scratchpad
for i in $(seq 1 200); do
  if tree_has_title; then
    echo "Found '$TITLE' in sway tree -> moving to scratchpad"
    swaymsg "[title=\"$TITLE\"] move to scratchpad"
    swaymsg "[title=\"$TITLE\"] scratchpad show"
    echo "Done"
    exit 0
  fi
  sleep 0.05
done

echo "Timed out: sway never saw '$TITLE' window"
exit 1
