#!/usr/bin/env bash

setHash () {
    jq --arg app "${1}" --arg hash "${2}" '.[$app] = $hash' pkgs/vendorHashes.json > tmp.json
    mv tmp.json pkgs/vendorHashes.json
}

declare -a APP_NAMES=()
while read -r line; do
    APP_NAMES+=("${line%:*}")
done < /tmp/nvfetcher-changes

for APP_NAME in "${APP_NAMES[@]}"; do
    if ! jq -e --arg app "${APP_NAME}" 'has($app)' pkgs/vendorHashes.json > /dev/null; then
        echo "Skipping ${APP_NAME}: not declared in vendorhash.json"
        continue
    fi

    echo "Updating vendor hash for ${APP_NAME}..."

    while true; do
        tmp_log=$(mktemp)

        script --quiet --return --command "nix build -L --no-link .#${APP_NAME}" \
            | tee "$tmp_log"
        nix_exit=${PIPESTATUS[0]}

        if [[ $nix_exit -eq 0 ]]; then
            echo "Successfully built ${APP_NAME}"
            rm -f "$tmp_log"
            break
        fi

        if grep -qa "hash mismatch" "$tmp_log"; then
            new_hash=$(grep -a "got:" "$tmp_log" | grep -oaP 'sha256-[A-Za-z0-9+/=]+' | head -1)
            rm -f "$tmp_log"
            echo "Hash mismatch for ${APP_NAME}, retrying with: ${new_hash}"
            setHash "${APP_NAME}" "$new_hash"
        else
            rm -f "$tmp_log"
            echo "Build of ${APP_NAME} failed (not a hash mismatch), skipping"
            break
        fi
    done
done