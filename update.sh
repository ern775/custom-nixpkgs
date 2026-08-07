#!/usr/bin/env bash
set -uo pipefail

CHANGES_FILE="${1:-/tmp/nvfetcher-changes}"

setHash () {
    jq --arg app "${1}" --arg hash "${2}" '.[$app] = $hash' pkgs/vendorHashes.json > tmp.json
    mv tmp.json pkgs/vendorHashes.json
}

mapfile -t APP_NAMES < <(cut -d: -f1 "$CHANGES_FILE")

for APP_NAME in "${APP_NAMES[@]}"; do
    if ! jq -e --arg app "${APP_NAME}" 'has($app)' pkgs/vendorHashes.json > /dev/null; then
        echo "Skipping ${APP_NAME}: not declared in vendorHashes.json"
        continue
    fi

    echo "Updating vendor hash for ${APP_NAME}..."

    while true; do
        build_log=$(nix build -L --no-link ".#${APP_NAME}" 2>&1)
        build_exit=$?

        echo "$build_log"

        if [[ $build_exit -eq 0 ]]; then
            echo "Successfully built ${APP_NAME}"
            break
        fi

        if grep -q "hash mismatch" <<< "$build_log"; then
            new_hash=$(grep -oP 'got:\s*\Ksha256-[A-Za-z0-9+/=]+' <<< "$build_log" | head -1)
            echo "Hash mismatch for ${APP_NAME}, retrying with: ${new_hash}"
            setHash "${APP_NAME}" "$new_hash"
        else
            echo "Build of ${APP_NAME} failed (not a hash mismatch), skipping"
            break
        fi
    done
done