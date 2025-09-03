#!/usr/bin/env bash
set -euo pipefail

ROOT="${1:-.}"
TARGET_SCOPE="@m-szopinski"
REGISTRY_URL="https://npm.pkg.github.com"

normalize_pkg() {
  local pkg_dir="$1"
  local pkg_json="$pkg_dir/package.json"

  if [[ -f "$pkg_json" ]]; then
    tmpfile="$(mktemp)"
    jq --arg scope "$TARGET_SCOPE" --arg reg "$REGISTRY_URL" '
      . as $root
      | if ($root.name | startswith("@babylonjs/")) then
          .name = ($scope + "/" + ($root.name | sub("^@babylonjs/"; "")))
        else
          .
        end
      | .publishConfig = (.publishConfig // {}) + { registry: $reg }
    ' "$pkg_json" > "$tmpfile"
    mv "$tmpfile" "$pkg_json"
    echo "Normalized: $pkg_json"
  fi
}

# Normalize root assembled package
normalize_pkg "$ROOT/Assembled"

# Normalize iOS/macOS and BaseKit iOS/macOS packages
for dir in "$ROOT"/Assembled-iOSmacOS* "$ROOT"/Assembled-BaseKit-iOSmacOS*; do
  [[ -d "$dir" ]] && normalize_pkg "$dir" || true
done