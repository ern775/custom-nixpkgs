setHash () {
    jq --arg app "${1}" --arg hash "${2}" '.[$app] = $hash' pkgs/vendorHashes.json > tmp.json
    mv tmp.json pkgs/vendorHashes.json
}

declare -a APP_NAMES
while read line; do
    APP_NAMES+=("${line%:*}")
done < tmp/nvfetcher-changes

for APP_NAME in "${APP_NAMES[@]}"; do
    # Check if the app is already declared in vendorhash.json
    if ! jq -e --arg app "${APP_NAME}" 'has($app)' pkgs/vendorHashes.json > /dev/null; then
        echo "Skipping ${APP_NAME}: not declared in vendorhash.json"
        continue
    fi

    echo "Updating vendor hash for ${APP_NAME}..."
    setHash "${APP_NAME}" ""
    vendorHash=$(nix build --no-link .#${APP_NAME} 2>&1 >/dev/null | grep "got:" | cut -d':' -f2 | sed 's| ||g')

    if [[ -n "${vendorHash}" ]]; then
        setHash "${APP_NAME}" "${vendorHash}"
        echo "Updated ${APP_NAME} with vendorHash: ${vendorHash}"
    fi
done