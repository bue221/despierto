#!/bin/bash
# Instala Despierto ☕: descarga la última versión y la copia a Aplicaciones.
#
#   curl -fsSL https://raw.githubusercontent.com/laulys/despierto/main/install.sh | bash
#
# Lee este script antes de ejecutarlo si quieres: solo descarga el zip de la
# última versión de GitHub, lo descomprime en Aplicaciones y abre la app.
set -euo pipefail

URL="https://github.com/laulys/despierto/releases/latest/download/Despierto.zip"
DEST="${DESPIERTO_DEST:-/Applications}"

if [ "$(uname)" != "Darwin" ]; then
  echo "Despierto solo funciona en macOS." >&2
  exit 1
fi

# Si no se puede escribir en /Applications, usamos la carpeta Aplicaciones del usuario
if [ ! -w "$DEST" ]; then
  DEST="$HOME/Applications"
fi
mkdir -p "$DEST"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

echo "☕ Descargando Despierto…"
curl -fsSL "$URL" -o "$TMP/Despierto.zip"
ditto -x -k "$TMP/Despierto.zip" "$TMP"

# Si ya estaba abierta (esta misma copia), la cerramos para poder reemplazarla
pkill -f "$DEST/Despierto.app/Contents/MacOS/Despierto" 2>/dev/null || true
rm -rf "$DEST/Despierto.app"
cp -R "$TMP/Despierto.app" "$DEST/"

echo "✅ Instalada en $DEST/Despierto.app"
echo "   Búscala arriba, en la barra de menú (una tacita de café)."

if [ -z "${DESPIERTO_NO_OPEN:-}" ]; then
  open "$DEST/Despierto.app"
fi
