# 🕒 Auto Committer

A lightweight Bash script that watches a Git repository and automatically commits changes at regular intervals. Ideal for versioning auto-generated files, notes, or backups.

## ✨ Features

- Polls for changes every N seconds (default: 120)
- Custom commit message templates with timestamp placeholders
- Works standalone **or** as a `systemd` template service
- Supports CLI args **and** environment variables
- Outputs logs via `stdout` — suitable for terminal, `nohup`, or `systemd` logging

---

## 🔧 Usage

```bash
./autocommit.sh [OPTIONS]
```

### Options

| Option        | Description                                                                                      |
|---------------|--------------------------------------------------------------------------------------------------|
| `--path`      | Path to the Git repo to monitor (defaults to current dir or `$AUTOCOMMIT_PATH`)                |
| `--interval`  | Interval in seconds between checks (defaults to `120` or `$AUTOCOMMIT_INTERVAL`)               |
| `--message`   | Commit message template. Use `{date}` to include timestamp (defaults to `Auto-commit at {date}`) |
| `--branch`    | Git branch to commit to (defaults to `auto-commit` or `$AUTOCOMMIT_BRANCH`)                    |
| `--help`      | Show help message                                                                                |

### Example

```bash
./autocommit.sh \
  --path ~/projects/my-notes \
  --interval 300 \
  --message "Backup commit on {date}" \
  --branch backup
```

---

## ⚙️ Environment Variables

All options can also be passed using environment variables — ideal for `systemd`:

| Variable               | CLI Equivalent   |
|------------------------|------------------|
| `AUTOCOMMIT_PATH`      | `--path`         |
| `AUTOCOMMIT_INTERVAL`  | `--interval`     |
| `AUTOCOMMIT_MESSAGE`   | `--message`      |
| `AUTOCOMMIT_BRANCH`    | `--branch`       |

---

## 🖥️ systemd Integration (Optional)

### 1. Copy the script

```bash
sudo cp autocommit.sh /usr/local/bin/autocommit.sh
sudo chmod +x /usr/local/bin/autocommit.sh
```

### 2. Create a systemd template unit

File: `/etc/systemd/system/auto-committer@.service`

```bash
[Unit]
Description=Auto Git Committer for %i
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/autocommit.sh
WorkingDirectory=/home/%u/repos/%i
Environment=AUTOCOMMIT_PATH=/home/%u/repos/%i
Environment=AUTOCOMMIT_INTERVAL=300
Environment=AUTOCOMMIT_MESSAGE=Auto commit for %i at {date}
User=%u
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

> Replace `/home/%u/repos/%i` with your desired structure if needed.

### 3. Enable and start

```json
sudo systemctl daemon-reload
sudo systemctl enable auto-committer@myproject
sudo systemctl start auto-committer@myproject
```

### 4. Monitor logs

```bash
journalctl -u auto-committer@myproject -f
```

---

## 📂 File Tracking

The script uses a hash of all file contents (excluding `.git`) to detect changes.  
It stores the last known hash in `/tmp/auto-committer-<hash>.hash`.

---

## 🧪 Test Locally

```bash
AUTOCOMMIT_PATH=~/repos/test-repo \
AUTOCOMMIT_INTERVAL=60 \
AUTOCOMMIT_MESSAGE="Test commit at {date}" \
./autocommit.sh
```

---

## 📜 License

MIT – Use freely, modify as needed.

---

## 🙌 Contributing

Pull requests welcome! Ideas, improvements, or even rewrites in Python or Go are fair game.
