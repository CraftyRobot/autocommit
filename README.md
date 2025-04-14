# 🪄 Autocommit

A tiny Git auto-committer in Bash that watches a folder, detects changes, and commits them for you.

- 🧠 Smart file hashing (no unnecessary commits)
- 🕒 Configurable intervals
- 🧾 Customizable commit messages
- 🚀 Installable via Homebrew, `.deb`, raw script, and AUR
- 🧩 Runs as a background service on macOS or Linux

---

## 🚀 Installation

### 🌍 Universal one-liner (macOS, Linux)

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/CraftyRobot/autocommit/main/install.sh)"
```

- Detects your OS & package manager
- Checks installed version and skips if up to date
- Reinstall with `--force` if needed:

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/CraftyRobot/autocommit/main/install.sh)" --force
```

---

### 🐧 Manual `.deb` install (Debian/Ubuntu)

```bash
wget https://github.com/CraftyRobot/autocommit/releases/download/v0.1.X/autocommit_0.1.X_all.deb
sudo dpkg -i autocommit_0.1.X_all.deb
```

---

### 🍺 Homebrew (macOS/Linux)

```bash
brew tap CraftyRobot/autocommit
brew install autocommit
```

---

### 🅰️ Arch Linux (via AUR)

If you're on Arch or Manjaro, install with an AUR helper like:

```bash
yay -S autocommit-bin
```

---

## 🛠 Usage

```bash
autocommit [OPTIONS]
```

### Options

- `--path <path>`: Git repo to watch (default: current dir or `$AUTOCOMMIT_PATH`)
- `--interval <seconds>`: Time between checks (default: 120)
- `--message <template>`: Commit message template, `{date}` will be replaced
- `--branch <branch>`: Target branch (default: `auto-commit`)
- `--state-file <file>`: Where to store last hash (default: `.autocommit-hash`)
- `--help`: Show help
- `--version`: Show installed version

Environment variables supported for all options.

---

## 🔍 How it works

Autocommit calculates a hash of all file contents (excluding `.git` and the state file).
If the hash has changed:

- Stages everything
- Commits with your message template
- Pushes to the configured branch

It stores the last known hash in `.autocommit-hash` by default.

---

## 🧩 Run as a Background Service

### 🖥 macOS (LaunchAgent)

Create `~/Library/LaunchAgents/com.craftyrobot.autocommit.plist`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>com.craftyrobot.autocommit</string>
  <key>ProgramArguments</key>
  <array>
    <string>/opt/homebrew/bin/autocommit</string>
    <string>--path</string>
    <string>/Users/youruser/path/to/repo</string>
    <string>--interval</string>
    <string>60</string>
    <string>--branch</string>
    <string>main</string>
  </array>
  <key>RunAtLoad</key>
  <true/>
  <key>KeepAlive</key>
  <true/>
  <key>StandardOutPath</key>
  <string>/tmp/autocommit.log</string>
  <key>StandardErrorPath</key>
  <string>/tmp/autocommit.err</string>
</dict>
</plist>
```

Then run:

```bash
launchctl load ~/Library/LaunchAgents/com.craftyrobot.autocommit.plist
```

---

### 🐧 Linux (systemd)

Create `/etc/systemd/system/autocommit.service`:

```ini
[Unit]
Description=Autocommit Git Watcher
After=network.target

[Service]
ExecStart=/usr/local/bin/autocommit --path /home/youruser/repo --interval 60 --branch main
Restart=always
User=youruser
WorkingDirectory=/home/youruser/repo
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=default.target
[/code]

Enable the service:

[code bash]
sudo systemctl daemon-reexec
sudo systemctl enable autocommit
sudo systemctl start autocommit
```

---

## 👨‍🔧 Developing

Run manually:

```bash
./autocommit.sh --path ~/myrepo --interval 30 --branch test
```

Build from source:

```bash
brew install --build-from-source ./autocommit.rb
```

---

## 📜 License

[MIT](LICENSE)

---

## ✨ Credits

Created by [@LambergaR](https://github.com/LambergaR) & contributors.
PRs welcome, stars appreciated ⭐
