#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# build.sh – Robust Godot 4.2.2 Web export for Vercel
# =============================================================================

GODOT_VERSION="4.2.2"
GODOT_TAG="${GODOT_VERSION}-stable"
GODOT_BIN_URL="https://github.com/godotengine/godot/releases/download/${GODOT_TAG}/Godot_v${GODOT_TAG}_linux.x86_64.zip"
TEMPLATES_URL="https://github.com/godotengine/godot/releases/download/${GODOT_TAG}/Godot_v${GODOT_TAG}_export_templates.tpz"

EXPORT_DIR="export/web"
TEMPLATE_DIR="${HOME}/.local/share/godot/export_templates/${GODOT_VERSION}.stable"
TEMP_DIR=""

cleanup() {
  if [[ -n "${TEMP_DIR}" && -d "${TEMP_DIR}" ]]; then
    rm -rf "${TEMP_DIR}"
  fi
}
trap cleanup EXIT

die() {
  echo "ERROR: $*" >&2
  exit 1
}

step() {
  echo ""
  echo "==> $*"
}

# -----------------------------------------------------------------------------
# 0. Check required tools
# -----------------------------------------------------------------------------
step "Checking required tools"
for cmd in curl unzip find chmod mkdir; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    die "Required tool not found: $cmd"
  fi
done
echo "All required tools are available."

# -----------------------------------------------------------------------------
# 1. Create temporary working directory
# -----------------------------------------------------------------------------
step "Creating temporary directory"
TEMP_DIR=$(mktemp -d)
echo "Temp dir: ${TEMP_DIR}"

# -----------------------------------------------------------------------------
# 2. Download Godot engine
# -----------------------------------------------------------------------------
step "Downloading Godot ${GODOT_VERSION} (linux.x86_64)"
GODOT_ZIP="${TEMP_DIR}/godot.zip"
if ! curl -fL --retry 3 --retry-delay 2 -o "${GODOT_ZIP}" "${GODOT_BIN_URL}"; then
  die "Failed to download Godot binary from ${GODOT_BIN_URL}"
fi
echo "Downloaded: ${GODOT_ZIP}"

# -----------------------------------------------------------------------------
# 3. Extract Godot and locate the executable (no fragile path assumptions)
# -----------------------------------------------------------------------------
step "Extracting Godot binary"
GODOT_EXTRACT_DIR="${TEMP_DIR}/godot"
mkdir -p "${GODOT_EXTRACT_DIR}"
if ! unzip -q -o "${GODOT_ZIP}" -d "${GODOT_EXTRACT_DIR}"; then
  die "Failed to unzip Godot binary"
fi

GODOT_BIN=$(find "${GODOT_EXTRACT_DIR}" -type f -name "Godot*" -executable 2>/dev/null | head -n1)
if [[ -z "${GODOT_BIN}" ]]; then
  # Fallback: any file that looks like the Godot binary (not a directory)
  GODOT_BIN=$(find "${GODOT_EXTRACT_DIR}" -type f \( -name "Godot*" -o -name "godot*" \) ! -name "*.zip" ! -name "*.tpz" | head -n1)
fi
if [[ -z "${GODOT_BIN}" || ! -f "${GODOT_BIN}" ]]; then
  echo "Contents of extract directory:" >&2
  find "${GODOT_EXTRACT_DIR}" -type f | head -20 >&2
  die "Could not locate Godot executable after extraction"
fi

chmod +x "${GODOT_BIN}"
echo "Found Godot binary: ${GODOT_BIN}"
"${GODOT_BIN}" --version || die "Godot binary is not runnable"

# -----------------------------------------------------------------------------
# 4. Download export templates
# -----------------------------------------------------------------------------
step "Downloading export templates ${GODOT_VERSION}"
TEMPLATES_TPZ="${TEMP_DIR}/templates.tpz"
if ! curl -fL --retry 3 --retry-delay 2 -o "${TEMPLATES_TPZ}" "${TEMPLATES_URL}"; then
  die "Failed to download export templates from ${TEMPLATES_URL}"
fi
echo "Downloaded: ${TEMPLATES_TPZ}"

# -----------------------------------------------------------------------------
# 5. Extract .tpz and install Web templates to the exact location Godot expects
# -----------------------------------------------------------------------------
step "Extracting and installing export templates"
TEMPLATES_EXTRACT_DIR="${TEMP_DIR}/templates"
mkdir -p "${TEMPLATES_EXTRACT_DIR}"
# .tpz is a zip archive
if ! unzip -q -o "${TEMPLATES_TPZ}" -d "${TEMPLATES_EXTRACT_DIR}"; then
  die "Failed to unzip export templates (.tpz)"
fi

# Locate the templates folder that contains the versioned content
# Typical structure after unzip: templates/ or templates/4.2.2.stable/...
FOUND_TEMPLATES=$(find "${TEMPLATES_EXTRACT_DIR}" -type d -name "${GODOT_VERSION}.stable" 2>/dev/null | head -n1)
if [[ -z "${FOUND_TEMPLATES}" ]]; then
  # Sometimes the content is directly under "templates/"
  if [[ -d "${TEMPLATES_EXTRACT_DIR}/templates" ]]; then
    FOUND_TEMPLATES="${TEMPLATES_EXTRACT_DIR}/templates"
  else
    FOUND_TEMPLATES="${TEMPLATES_EXTRACT_DIR}"
  fi
fi

mkdir -p "${TEMPLATE_DIR}"
# Copy everything that looks like templates into the expected location
if [[ -d "${FOUND_TEMPLATES}" ]]; then
  cp -a "${FOUND_TEMPLATES}/." "${TEMPLATE_DIR}/" || die "Failed to copy templates to ${TEMPLATE_DIR}"
else
  die "Could not find extracted templates directory"
fi

echo "Templates installed to: ${TEMPLATE_DIR}"

# -----------------------------------------------------------------------------
# 6. Verify Web release template exists
# -----------------------------------------------------------------------------
step "Verifying Web export template"
WEB_TEMPLATE="${TEMPLATE_DIR}/web_release.zip"
if [[ ! -f "${WEB_TEMPLATE}" ]]; then
  echo "Looking for any web_* files in ${TEMPLATE_DIR}:" >&2
  find "${TEMPLATE_DIR}" -name "web_*" 2>/dev/null || true
  ls -la "${TEMPLATE_DIR}" 2>/dev/null || true
  die "Web release template not found at ${WEB_TEMPLATE}"
fi
echo "Web template OK: ${WEB_TEMPLATE}"

# -----------------------------------------------------------------------------
# 7. Prepare export directory
# -----------------------------------------------------------------------------
step "Preparing export directory"
rm -rf "${EXPORT_DIR}"
mkdir -p "${EXPORT_DIR}"
echo "Export directory ready: ${EXPORT_DIR}"

# -----------------------------------------------------------------------------
# 8. Run headless export
# -----------------------------------------------------------------------------
step "Exporting project (Web preset) with Godot headless"
# Force gl_compatibility and use the configured main scene via the project.
# The "Web" preset must exist in export_presets.cfg
if ! "${GODOT_BIN}" --headless --path . --export-release "Web" "${EXPORT_DIR}/index.html"; then
  die "Godot export command failed"
fi

# -----------------------------------------------------------------------------
# 9. Verify export produced the expected files
# -----------------------------------------------------------------------------
step "Verifying export output"
REQUIRED_FILES=(
  "${EXPORT_DIR}/index.html"
)

# Look for typical Godot Web artifacts
WASM=$(find "${EXPORT_DIR}" -name "*.wasm" | head -n1 || true)
PCK=$(find "${EXPORT_DIR}" -name "*.pck" | head -n1 || true)
JS=$(find "${EXPORT_DIR}" -name "*.js" | head -n1 || true)

if [[ ! -f "${EXPORT_DIR}/index.html" ]]; then
  die "Export did not produce ${EXPORT_DIR}/index.html"
fi
if [[ -z "${WASM}" ]]; then
  die "Export did not produce a .wasm file"
fi
if [[ -z "${PCK}" ]]; then
  die "Export did not produce a .pck file"
fi

echo "Export successful!"
echo "  index.html : ${EXPORT_DIR}/index.html"
echo "  wasm       : ${WASM}"
echo "  pck        : ${PCK}"
[[ -n "${JS}" ]] && echo "  js         : ${JS}"

echo ""
echo "Build finished successfully."
