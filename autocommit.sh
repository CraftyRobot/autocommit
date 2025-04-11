#!/bin/bash

VERSION="0.1.14"

# === Default Configuration ===
INTERVAL="${AUTOCOMMIT_INTERVAL:-120}"
COMMIT_MESSAGE_TEMPLATE="${AUTOCOMMIT_MESSAGE:-Auto-commit at {date}}"
WATCH_DIR="${AUTOCOMMIT_PATH:-.}"
BRANCH="${AUTOCOMMIT_BRANCH:-auto-commit}"
STATE_FILE="${AUTOCOMMIT_STATE_FILE:-}"
SHOW_HELP=false

# === Help ===
print_help() {
  cat <<EOF
Usage: $0 [OPTIONS]

Options:
  --path <path>           Path to the Git repo to watch (default: current dir or \$AUTOCOMMIT_PATH)
  --interval <seconds>    Interval in seconds between checks (default: 120 or \$AUTOCOMMIT_INTERVAL)
  --message <template>    Commit message template. Use {date} as placeholder (default: "Auto-commit at {date}" or \$AUTOCOMMIT_MESSAGE)
  --branch <branch>       Branch to commit to (default: auto-commit or \$AUTOCOMMIT_BRANCH)
  --state-file <file>     File to use for storing the last hash (default: .autocommit-hash in the watched directory or \$AUTOCOMMIT_STATE_FILE)
  --version               Print the script version
  --help                  Show this help message

You can also configure everything via environment variables:
  AUTOCOMMIT_PATH, AUTOCOMMIT_INTERVAL, AUTOCOMMIT_MESSAGE, AUTOCOMMIT_BRANCH, AUTOCOMMIT_STATE_FILE

Example:
  $0 --path ~/myrepo --interval 300 --message "Backup: {date}" --branch main
EOF
}

# === CLI Arg Parsing ===
while [[ $# -gt 0 ]]; do
  case "$1" in
    --path)
      WATCH_DIR="$2"; shift 2 ;;
    --interval)
      INTERVAL="$2"; shift 2 ;;
    --message)
      COMMIT_MESSAGE_TEMPLATE="$2"; shift 2 ;;
    --branch)
      BRANCH="$2"; shift 2 ;;
    --state-file)
      STATE_FILE="$2"; shift 2 ;;
    --help)
      SHOW_HELP=true; shift ;;
    --version)
      echo "autocommit version $VERSION"
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      print_help
      exit 1
      ;;
  esac
done

if $SHOW_HELP; then
  print_help
  exit 0
fi

# === Safety Checks ===
if [ ! -d "$WATCH_DIR" ]; then
  echo "❌ Error: WATCH_DIR ($WATCH_DIR) does not exist." >&2
  exit 1
fi

cd "$WATCH_DIR" || exit 1

# 🔁 Worktree-aware Git check
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "❌ Error: $WATCH_DIR is not a valid Git repository." >&2
  exit 1
fi

# === Determine state file location ===
if [ -z "$STATE_FILE" ]; then
  STATE_FILE="$WATCH_DIR/.autocommit-hash"
fi

# === Ensure Branch Exists ===
git checkout "$BRANCH" 2>/dev/null || git checkout -b "$BRANCH"

# === Compute directory hash ===
compute_dir_hash() {
  find . -type f \
    -not -path './.git/*' \
    -not -name "$(basename "$STATE_FILE")" \
    -exec sha1sum {} \; | sort | sha1sum
}

# === Initialize state ===
if [ ! -f "$STATE_FILE" ]; then
  compute_dir_hash > "$STATE_FILE"
fi

# === Info ===
echo "📁 Watching:         '$WATCH_DIR'"
echo "🕒 Interval:         ${INTERVAL}s"
echo "🔁 Committing to:    '$BRANCH'"
echo "✏️  Commit message:  $COMMIT_MESSAGE_TEMPLATE"
echo "📄 State file:       $STATE_FILE"
echo ""

# === Main Loop ===
while true; do
  CURRENT_HASH=$(compute_dir_hash)
  LAST_HASH=$(cat "$STATE_FILE")

  if [ "$CURRENT_HASH" != "$LAST_HASH" ]; then
    echo "✅ Changes detected at $(date)"

    git add .
    COMMIT_DATE=$(date '+%Y-%m-%d %H:%M:%S')
    COMMIT_MESSAGE=${COMMIT_MESSAGE_TEMPLATE//\{date\}/$COMMIT_DATE}

    git commit -m "$COMMIT_MESSAGE"
    git push origin "$BRANCH"

    echo "$CURRENT_HASH" > "$STATE_FILE"
  else
    echo "🟢 No changes at $(date)"
  fi

  sleep "$INTERVAL"
done
