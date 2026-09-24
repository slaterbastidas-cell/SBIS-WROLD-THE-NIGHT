#!/usr/bin/env bash
set -euo pipefail

GODOT_VERSION="4.2.2"
GODOT_ZIP="Godot_v${GODOT_VERSION}-stable_linux.x86_64.zip"
GODOT_URL="https://github.com/godotengine/godot/releases/download/${GODOT_VERSION}-stable/${GODOT_ZIP}"
GODOT_DIR="${HOME}/godot-${GODOT_VERSION}"
GODOT_BIN="${GODOT_DIR}/godot"
TEMPLATE_DIR="${HOME}/.local/share/godot/export_templates/${GODOT_VERSION}.stable"
TEMPLATE_ZIP="Godot_v${GODOT_VERSION}-stable_export_templates.tpz"
TEMPLATE_URL="https://github.com/godotengine/godot/releases/download/${GODOT_VERSION}-stable/${TEMPLATE_ZIP}"

mkdir -p "${GODOT_DIR}" "${TEMPLATE_DIR}"

if [ ! -x "${GODOT_BIN}" ]; then
  tmpdir="$(mktemp -d)"
  curl -fsSL "$GODOT_URL" -o "${tmpdir}/${GODOT_ZIP}"
  unzip -q "${tmpdir}/${GODOT_ZIP}" -d "${tmpdir}/godot"
  install -m 0755 "${tmpdir}/godot/Godot_v${GODOT_VERSION}-stable_linux.x86_64" "${GODOT_BIN}"
  rm -rf "$tmpdir"
fi

# Godot 4.2 expects the Web export templates as zip files in this directory.
if [ ! -f "${TEMPLATE_DIR}/web_nothreads_release.zip" ]; then
  tmpdir="$(mktemp -d)"
  curl -fsSL "$TEMPLATE_URL" -o "${tmpdir}/${TEMPLATE_ZIP}"
  unzip -q "${tmpdir}/${TEMPLATE_ZIP}" -d "${tmpdir}/templates"
  install -m 0644 "${tmpdir}/templates/templates/web_nothreads_release.zip" "${TEMPLATE_DIR}/web_nothreads_release.zip"
  if [ -f "${tmpdir}/templates/templates/web_nothreads_debug.zip" ]; then
    install -m 0644 "${tmpdir}/templates/templates/web_nothreads_debug.zip" "${TEMPLATE_DIR}/web_nothreads_debug.zip"
  fi
  rm -rf "$tmpdir"
fi

rm -rf export/web
mkdir -p export/web

"${GODOT_BIN}" --headless --path . --editor --quit-after 1
"${GODOT_BIN}" --headless --path . --export-release Web export/web/index.html

test -s export/web/index.html
test -f export/web/index.pck

echo "Godot Web export completed successfully: export/web"
