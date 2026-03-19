#!/usr/bin/env nix-shell
#!nix-shell -i bash -p bash curl jq

set -euo pipefail
pkg_dir="$(dirname "$0")"

releases=$(curl -sSfL ${GITHUB_TOKEN:+-u ":$GITHUB_TOKEN"} "https://api.github.com/repos/wireapp/wire-desktop/releases")

linux_tag=$(echo "$releases" | jq -r '[.[] | select(.tag_name | startswith("linux/"))] | .[0].tag_name')
macos_tag=$(echo "$releases" | jq -r '[.[] | select(.tag_name | startswith("macos/"))] | .[0].tag_name')

if [[ "$linux_tag" == "null" || -z "$linux_tag" ]]; then
    echo "Error: Could not find a linux/ tag in recent releases." >&2
    exit 1
fi
if [[ "$macos_tag" == "null" || -z "$macos_tag" ]]; then
    echo "Error: Could not find a macos/ tag in recent releases." >&2
    exit 1
fi

linux_version=${linux_tag#linux/}
macos_version=${macos_tag#macos/}

prefetch_github_hash() {
    local tag=$1
    local url="https://github.com/wireapp/wire-desktop/archive/refs/tags/${tag}.tar.gz"
    local store_path
    store_path=$(nix-prefetch-url --unpack "$url")
    nix-hash --type sha256 --to-sri "$store_path"
}

linux_hash=$(prefetch_github_hash "$linux_tag")
sed -i -e "/x86_64-linux = rec {/,/};/ { s|version = \".*\";|version = \"$linux_version\";|; s|hash = \".*\";|hash = \"$linux_hash\";|; }" $pkg_dir/package.nix

macos_hash=$(prefetch_github_hash "$macos_tag")
sed -i -e "/x86_64-darwin = rec {/,/};/ { s|version = \".*\";|version = \"$macos_version\";|; s|hash = \".*\";|hash = \"$macos_hash\";|; }" $pkg_dir/package.nix