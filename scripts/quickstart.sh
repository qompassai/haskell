#!/bin/sh
# /qompassai/haskell/scripts/quickstart.sh
# Qompass AI Haskell Stack Quickstart
# Copyright (C) 2025 Qompass AI, All rights reserved
####################################################
set -eu
IFS='
'
detect_os_arch() {
	case "$(uname -s)" in
	Linux*) OS="linux" ;;
	Darwin*) OS="macos" ;;
	CYGWIN* | MINGW* | MSYS*) OS="windows" ;;
	*) OS="unknown" ;;
	esac
	case "$(uname -m)" in
	x86_64 | amd64) ARCH="x86_64" ;;
	arm64 | aarch64) ARCH="aarch64" ;;
	*) ARCH="unknown" ;;
	esac
	echo "$OS" "$ARCH"
}
read -r OS ARCH <<EOF
$(detect_os_arch)
EOF
echo "→ Detected OS: $OS"
echo "→ Detected Architecture: $ARCH"
echo
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_BIN_HOME="${XDG_BIN_HOME:-$HOME/.local/bin}"
case "$OS" in
linux | macos)
	STACK_CONFIG_DIR="$XDG_CONFIG_HOME/stack"
	;;
windows)
	STACK_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/AppData/Roaming}/stack"
	;;
*)
	STACK_CONFIG_DIR="$XDG_CONFIG_HOME/stack"
	;;
esac
STACK_CONFIG="$STACK_CONFIG_DIR/config.yaml"
mkdir -p "$XDG_CONFIG_HOME" "$XDG_DATA_HOME" "$XDG_BIN_HOME" "$STACK_CONFIG_DIR"
echo "╭──────────────────────────────╮"
echo "│ Qompass AI Haskell Quickstart│"
echo "╰──────────────────────────────╯"
install_stack() {
	case "$OS" in
	linux | macos)
		echo "→ Installing Haskell Stack (OS: $OS, Arch: $ARCH)"
		curl -sSL https://get.haskellstack.org/ | sh
		;;
	windows)
		echo "❌ Automated Windows install not supported here."
		echo "➡ Download from: https://get.haskellstack.org/stable/windows-x86_64-installer.exe"
		exit 1
		;;
	*)
		echo "❌ Unknown OS - please install Stack manually."
		exit 1
		;;
	esac
}
if ! command -v stack >/dev/null 2>&1; then
	install_stack
else
	echo "✓ Haskell Stack already installed"
fi
if [ ! -f "$STACK_CONFIG" ]; then
	echo "→ No stack config found at: $STACK_CONFIG"
	echo "→ Creating default config..."
	stack config set resolver lts --global
	DEFAULT_PATH="$(stack path --global-config-location 2>/dev/null || true)"
	if [ -f "$DEFAULT_PATH" ] && [ "$DEFAULT_PATH" != "$STACK_CONFIG" ]; then
		mkdir -p "$(dirname "$STACK_CONFIG")"
		mv "$DEFAULT_PATH" "$STACK_CONFIG"
		echo "✓ Moved default config to $STACK_CONFIG"
	fi
else
	echo "✓ Found existing stack config at $STACK_CONFIG"
fi
if ! echo "$PATH" | grep -q "$XDG_BIN_HOME"; then
	export PATH="$XDG_BIN_HOME:$PATH"
	echo "→ Added $XDG_BIN_HOME to PATH for this session"
fi
if command -v nix-shell >/dev/null 2>&1; then
	echo "✓ Nix detected — Stack Nix mode available"
else
	echo "⚠ Nix not detected — Stack will run without Nix integration"
fi
echo
echo "✓ Haskell stack setup complete!"
echo "Detected OS: $OS | Arch: $ARCH"
echo "Stack config: $STACK_CONFIG"
echo "Local bin dir: $XDG_BIN_HOME"
echo
echo "Examples:"
echo "  stack new myproject"
echo "  cd myproject && stack build && stack exec myproject-exe"
