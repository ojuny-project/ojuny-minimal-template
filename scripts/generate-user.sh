#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="${OJUNY_ROOT:-$PWD}"
HELPER="$REPO_ROOT/scripts/flake_structure.py"
OUT="$(python3 "$HELPER" --root "$REPO_ROOT" --non-interactive path --module users --fallback modules/00-user.nix)"
STATE_VERSION="26.11"
HOME_MANAGER="auto"

force=0
while [ "$#" -gt 0 ]; do
  case "$1" in
  --force) force=1 ;;
  --state-version)
    STATE_VERSION="${2:?--state-version needs a value}"
    shift
    ;;
  --home-manager) HOME_MANAGER=1 ;;
  --no-home-manager) HOME_MANAGER=0 ;;
  *)
    echo "generate-user: unknown argument: $1" >&2
    exit 2
    ;;
  esac
  shift
done

if [ "$HOME_MANAGER" = auto ]; then
  if grep -q 'home-manager' "$REPO_ROOT/flake.nix" 2>/dev/null; then
    HOME_MANAGER=1
  else
    HOME_MANAGER=0
  fi
fi

if [ -e "$OUT" ] && [ "$force" -ne 1 ]; then
  echo "generate-user: refusing to overwrite $OUT (pass --force)" >&2
  exit 1
fi

read -rp "Username [user]: " username
username="${username:-user}"
read -rp "Description (full name) [Primary account]: " description
description="${description:-Primary account}"
read -rp "Extra groups [networkmanager wheel video input]: " groups
groups="${groups:-networkmanager wheel video input}"
read -rp "Login shell [zsh]: " shell
shell="${shell:-zsh}"

read -rsp "Password (empty to leave locked): " password
echo

hashed="!"
if [ -n "$password" ]; then
  if command -v mkpasswd >/dev/null 2>&1; then
    hashed="$(mkpasswd -m yescrypt "$password" 2>/dev/null || mkpasswd -m sha-512 "$password")"
  else
    echo "generate-user: mkpasswd not found" >&2
    exit 1
  fi
fi

read -ra group_names <<<"$groups"
group_list=""
for g in "${group_names[@]}"; do
  group_list+="\"$g\" "
done
group_list="${group_list% }"

key_list=""
while true; do
  read -rp "SSH public key (empty to finish): " key
  [ -z "$key" ] && break
  key_list+="      \"$key\""$'\n'
done
if [ -z "$key_list" ]; then
  keys_block="[ ]"
else
  keys_block="$(printf '[\n%s    ]' "$key_list")"
fi

if [ "$HOME_MANAGER" = 1 ]; then
  hm_import=" inputs.home-manager.nixosModules.home-manager"
  hm_option=" homeManager = true;"
  hm_block="
      home-manager.users = {
        $username = {
          home.stateVersion = \"$STATE_VERSION\";
        };
      };"
else
  hm_import=""
  hm_option=""
  hm_block=""
fi

{
  cat <<EOF
/* @menu
   displayname = "Users";
   icon = "avatar-default-symbolic";
   order = 10;
   description = "User Accounts";
   category = "01-Users";
*/

{ self, inputs, ... }: {

  flake.modules.nixos.users = { pkgs, ... }: {

    imports = [$hm_import ];

    config = {
      /* @option widget = "users"; label = "Accounts";$hm_option */
      users.users = {
        $username = {
          isNormalUser = true;
          uid = 1000;
          description = "$description";
          extraGroups = [ $group_list ];
          hashedPassword = "$hashed";
          openssh.authorizedKeys.keys = $keys_block;
          shell = pkgs.$shell;
        };
      };
$hm_block
    };

  };

}
EOF
} >"$OUT"

python3 "$HELPER" --root "$REPO_ROOT" --non-interactive ensure-imports \
  --name users >/dev/null

echo "generate-user: wrote $OUT"
