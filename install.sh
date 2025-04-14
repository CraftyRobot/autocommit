#!/bin/bash

set -e

INSTALL_NAME="autocommit"
REPO="CraftyRobot/autocommit"
FORCE=false

print_banner() {
  echo ""
  echo "🚀 Installing autocommit..."
  echo ""
}

print_success() {
  echo ""
  echo "✅ autocommit installed successfully!"
  echo "   Run 'autocommit --help' to get started."
}

print_up_to_date() {
  echo "✅ autocommit is already up to date (version $1)"
  exit 0
}

print_update_instructions() {
  echo "🆕 A newer version of autocommit is available: $1 (installed: $2)"

  if command -v brew >/dev/null 2>&1; then
    echo "   • To upgrade: run 'brew upgrade autocommit'"
  elif command -v yay >/dev/null 2>&1 || command -v paru >/dev/null 2>&1; then
    echo "   • To upgrade: run your AUR helper (e.g. 'yay -S autocommit-bin')"
  elif command -v dpkg >/dev/null 2>&1; then
    echo "   • To upgrade: download the latest .deb from GitHub and re-install via 'dpkg -i'"
  else
    echo "   • To upgrade: re-run this script with '--force' to overwrite"
  fi

  exit 0
}

install_with_brew() {
  echo "🍺 Homebrew detected, installing via brew..."
  brew tap CraftyRobot/autocommit
  brew install autocommit
}

install_with_aur() {
  echo "🐧 Detected Arch-based system. Installing via AUR..."
  if command -v yay >/dev/null 2>&1; then
    yay -S --noconfirm autocommit-bin
  elif command -v paru >/dev/null 2>&1; then
    paru -S --noconfirm autocommit-bin
  else
    echo "❌ No AUR helper found (yay/paru). Please install manually:"
    echo "   git clone https://aur.archlinux.org/autocommit-bin.git && cd autocommit-bin && makepkg -si"
    exit 1
  fi
}

install_deb_package() {
  echo "📦 Detected Debian/Ubuntu. Installing .deb package..."

  LATEST_VERSION=$(curl -s https://api.github.com/repos/$REPO/releases/latest | grep tag_name | cut -d '"' -f4)
  DEB_NAME="autocommit_${LATEST_VERSION#v}_all.deb"
  DEB_URL="https://github.com/$REPO/releases/download/$LATEST_VERSION/$DEB_NAME"

  echo "⬇️  Downloading $DEB_URL..."
  wget -q "$DEB_URL" -O "$DEB_NAME"

  echo "📦 Installing package..."
  sudo dpkg -i "$DEB_NAME"

  rm "$DEB_NAME"
}

install_raw_script() {
  echo "📄 No package manager found. Falling back to raw script install..."
  echo "⬇️  Downloading autocommit.sh from GitHub..."

  sudo curl -fsSL "https://raw.githubusercontent.com/$REPO/main/autocommit.sh" \
    -o "/usr/local/bin/$INSTALL_NAME"

  sudo chmod +x "/usr/local/bin/$INSTALL_NAME"
}

check_version() {
  if command -v autocommit >/dev/null 2>&1; then
    INSTALLED_VERSION=$(autocommit --version 2>/dev/null | awk '{print $NF}')
    LATEST_VERSION=$(curl -s https://api.github.com/repos/$REPO/releases/latest | grep tag_name | cut -d '"' -f4 | sed 's/^v//')

    if [ "$INSTALLED_VERSION" = "$LATEST_VERSION" ] && [ "$FORCE" = false ]; then
      print_up_to_date "$INSTALLED_VERSION"
    fi

    COMPARE=$(printf "%s\n%s" "$INSTALLED_VERSION" "$LATEST_VERSION" | sort -V | head -n1)
    if [ "$COMPARE" = "$INSTALLED_VERSION" ] && [ "$INSTALLED_VERSION" != "$LATEST_VERSION" ] && [ "$FORCE" = false ]; then
      print_update_instructions "$LATEST_VERSION" "$INSTALLED_VERSION"
    fi
  fi
}

# === MAIN ===
if [[ "$1" == "--force" ]]; then
  FORCE=true
fi

print_banner
check_version

if command -v brew >/dev/null 2>&1; then
  install_with_brew
elif command -v pacman >/dev/null 2>&1; then
  install_with_aur
elif command -v dpkg >/dev/null 2>&1 && command -v wget >/dev/null 2>&1; then
  install_deb_package
else
  install_raw_script
fi

print_success
