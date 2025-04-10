#!/bin/bash

# === Default Configuration ===
INTERVAL="${AUTOCOMMIT_INTERVAL:-120}"
COMMIT_MESSAGE_TEMPLATE="${AUTOCOMMIT_MESSAGE:-Auto-commit at {date}}"
WATCH_DIR="${AUTOCOMMIT_PATH:-.}"
BRANCH="${AUTOCOMMIT_BRANCH:-auto-commit}"
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
  --help                  Show this help message

You can also configure everything via environment variables:
  AUTOCOMMIT_PATH, AUTOCOMMIT_INTERVAL, AUTOCOMMIT_MESSAGE, AUTOCOMMIT_BRANCH

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
    --help)
      SHOW_HELP=true; shift ;;
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

if [ ! -d ".git" ]; then
  echo "❌ Error: $WATCH_DIR is not a Git repository." >&2
  exit 1
fi

# === Ensure Branch Exists ===
git checkout "$BRANCH" 2>/dev/null || git checkout -b "$BRANCH"

# === Change Detection ===
HASH_ID=$(echo "$WATCH_DIR" | sha1sum | awk '{print $1}')
LAST_HASH_FILE="/tmp/auto-committer-$HASH_ID.hash"

compute_dir_hash() {
  find . -type f -not -path './.git/*' -exec sha1sum {} \; | sort | sha1sum
}

if [ ! -f "$LAST_HASH_FILE" ]; then
  compute_dir_hash > "$LAST_HASH_FILE"
fi

echo "📁 Watching '$WATCH_DIR' every $INTERVAL seconds"
echo "🔁 Committing to branch '$BRANCH'"
echo "✏️ Message template: $COMMIT_MESSAGE_TEMPLATE"
echo "📦 Commit hash tracking file: $LAST_HASH_FILE"
echo ""

# === Main Loop ===
while true; do
  CURRENT_HASH=$(compute_dir_hash)
  LAST_HASH=$(cat "$LAST_HASH_FILE")

  if [ "$CURRENT_HASH" != "$LAST_HASH" ]; then
    echo "✅ Changes detected at $(date)"

    git add .
    COMMIT_DATE=$(date '+%Y-%m-%d %H:%M:%S')
    COMMIT_MESSAGE=${COMMIT_MESSAGE_TEMPLATE//\{date\}/$COMMIT_DATE}

    git commit -m "$COMMIT_MESSAGE"
    git push origin "$BRANCH"

    echo "$CURRENT_HASH" > "$LAST_HASH_FILE"
  else
    echo "🟢 No changes at $(date)"
  fi

  sleep "$INTERVAL"
done
