#!/bin/bash
# Build script for Bimodal TM Logic Reference Manual
#
# Usage: ./build.sh [--clean | --full-clean]
#   --clean:      Remove auxiliary files (keep PDF)
#   --full-clean: Remove all build artifacts including PDF
#
# This script uses latexmk with configuration from ./latexmkrc
# which loads the shared ProofChecker LaTeX settings.

set -e

# Change to the LaTeX directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Handle clean flags
if [[ "$1" == "--clean" ]]; then
    echo "Cleaning auxiliary files (keeping PDF)..."
    latexmk -c BimodalReference.tex
    rm -f subfiles/*.aux
    echo "Clean complete."
    exit 0
fi

if [[ "$1" == "--full-clean" ]]; then
    echo "Cleaning all build artifacts..."
    latexmk -C BimodalReference.tex
    rm -f subfiles/*.aux
    rm -rf build/
    echo "Full clean complete."
    exit 0
fi

# Build the main document using latexmk
# Configuration is loaded from ./latexmkrc -> ../../LaTeX/latexmkrc
echo "Building BimodalReference.tex with latexmk..."
latexmk BimodalReference.tex

echo ""
echo "Build complete: build/BimodalReference.pdf"
