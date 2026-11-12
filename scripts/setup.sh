#!/usr/bin/env bash
set -euo pipefail

default_clone_dir="${OJUNY_CLONE_DIR:-$HOME/repos/nix-flake}"

printf '\033[2J\033[H'
cat <<'EOF'
Ojuny minimal template setup

Fork the template, then enter the URL of your fork.
EOF

read -rp "Git URL of your fork: " fork_url
[ -n "${fork_url:-}" ] || {
  echo "setup: no URL given, aborting" >&2
  exit 1
}

read -rp "Location to clone into [$default_clone_dir]: " answer
clone_dir="${answer:-$default_clone_dir}"
if [ -e "$clone_dir" ]; then
  echo "setup: $clone_dir already exists" >&2
  exit 1
fi

mkdir -p "$(dirname "$clone_dir")"
git clone "$fork_url" "$clone_dir"
export OJUNY_ROOT="$clone_dir"
export OJUNY_CLONE_PATH="$clone_dir"
cd "$clone_dir"

state_version="26.11"
if grep -q '^ID=ojuny' /etc/os-release 2>/dev/null &&
  [ -L /etc/ojuny/flake-source ]; then
  source="$(readlink -f /etc/ojuny/flake-source)"
  candidate="$(
    nix eval --raw "path:$source#nixosConfigurations.$(uname -n).config.system.stateVersion" 2>/dev/null || true
  )"
  [ -n "$candidate" ] && state_version="$candidate"
fi
if [ -z "${candidate:-}" ] && [ -f /etc/nixos/configuration.nix ]; then
  candidate="$(
    sed -n 's/.*system\.stateVersion[[:space:]]*=[[:space:]]*"\([0-9][0-9.]*\)".*/\1/p' \
      /etc/nixos/configuration.nix | head -n1
  )"
  [ -n "$candidate" ] && state_version="$candidate"
fi

echo "==> generate-hw"
generate-hw --force
echo "==> generate-user"
generate-user --force --state-version "$state_version"
read -rp "Hostname [$(uname -n)]: " hostname
hostname="${hostname:-$(uname -n)}"
echo "==> create-new-system"
create-new-system --force --state-version="$state_version" --hostname="$hostname"

git add -A
host="$hostname"

echo
read -rp "Rebuild and reboot now? [y/N] " rebuild
case "$rebuild" in
[yY] | [yY][eE][sS])
  nixos-rebuild boot --flake "$clone_dir#$host" --sudo
  read -rp "Reboot now? [y/N] " reboot
  case "$reboot" in
  [yY] | [yY][eE][sS]) sudo systemctl reboot ;;
  esac
  ;;
*)
  echo "setup: done. Rebuild later with:"
  echo "  nixos-rebuild boot --flake $clone_dir#$host"
  ;;
esac
