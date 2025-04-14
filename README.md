# 🪄 Autocommit

A tiny Git auto-committer in Bash that watches a folder, detects changes, and commits them for you.

- 🧠 Smart file hashing (no unnecessary commits)
- 🕒 Configurable intervals
- 🧾 Customizable commit messages
- 🚀 Installable via Homebrew & `.deb` packages
- 🧩 Can run as a macOS LaunchAgent or Linux systemd service

---

## 🚀 Installation

### 🍎 Homebrew (macOS/Linux)

```bash
brew tap CraftyRobot/autocommit
brew install autocommit
```

### 🐧 Debian/Ubuntu (.deb)

Download the latest `.deb` from [Releases](https://github.com/CraftyRobot/autocommit/releases):

```bash
wget https://github.com/CraftyRobot/autocommit/releases/download/v0.1.X/autocommit_0.1.X_all.deb
sudo dpkg -i autocommit_0.1.X_all.deb
```

---

## 🛠 Usage

```bash
autocommit [OPTIONS]
```

### Options

- `--path <path>`: Path to Git repo to watch (default: current dir or `$AUTOCOMMIT_PATH`)
- `--interval <seconds>`: Time between checks (default: 120 or `$AUTOCOMMIT_INTERVAL`)
- `--message <template>`: Commit message template, use `{date}` as placeholder
- `--branch <branch>`: Branch to commit to (default: `auto-commit`)
- `--state-file <file>`: Path to store last known hash (default: `.autocommit-hash`)
- `--help`: Show help
- `--version`: Show version

Environment variables are supported for all options.

---

## 🔍 How it works

Autocommit watches for changes by hashing the contents of all files (excluding `.git` and the state file).
It stores the last known hash in a file (default: `.autocommit-hash` in the repo).

When changes are detected:

- Stages all files
- Commits with the configured message template
- Pushes to the specified branch (if `origin` exists)

---

## 🧩 Running as a Background Service

### 🖥 macOS (LaunchAgent)

Save this as `~/Library/LaunchAgents/com.craftyrobot.autocommit.plist`:

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

Then enable and start the service:

[code bash]
sudo systemctl daemon-reexec
sudo systemctl enable autocommit
sudo systemctl start autocommit
```

---

## 🪟 Windows Support?

`autocommit` is just a Bash script, so it can work on Windows with:

- [Git Bash](https://git-scm.com/downloads)
- [WSL (Windows Subsystem for Linux)](https://learn.microsoft.com/en-us/windows/wsl/)
- A cross-platform shell like [MSYS2](https://www.msys2.org/)

You can even create a `.bat` or `.vbs` wrapper to run it in the background.

Want native Windows service support? PRs welcome 😉

---

## 👨‍🔧 Developing

Run manually:

```bash
./autocommit.sh --path ~/myrepo --interval 30 --branch test
```

To build from source:

```bash
brew install --build-from-source ./autocommit.rb
```

---

## 📜 License

[MIT](LICENSE)

---

## ✨ Credits

Created by [@LambergaR](https://github.com/LambergaR) & contributors.
Stars appreciated ⭐️ — PRs always welcome!
