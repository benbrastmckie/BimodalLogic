#!/usr/bin/env bash
# LaTeX Fix Script for ProofChecker Theories
# Usage: ./latex-fix.sh [clean|rebuild|check] [theory_name]
#
# Examples:
#   ./latex-fix.sh rebuild logos        # Work on Logos theory
#   ./latex-fix.sh check bimodal        # Check Bimodal theory
#   ./latex-fix.sh rebuild              # Auto-detect theory from current directory

set -e  # Exit on any error

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROOF_CHECKER_ROOT="$(dirname "$SCRIPT_DIR")"

# Function to detect theory name from current directory
detect_theory() {
    local pwd_path="$(pwd)"
    if [[ "$pwd_path" == *"Theories/"* ]]; then
        echo "$pwd_path" | sed 's|.*/Theories/||' | sed 's|/.*||'
    else
        echo ""
    fi
}

# Determine which theory to work on
THEORY_NAME="${2:-$(detect_theory)}"

if [ -z "$THEORY_NAME" ]; then
    echo "Error: Could not detect theory name. Please specify it:"
    echo "  $0 <command> <theory_name>"
    echo ""
    echo "Available theories:"
    find "$PROOF_CHECKER_ROOT/Theories" -maxdepth 1 -type d -not -path "*/Theories" | xargs -n1 basename
    exit 1
fi

# Try exact match first, then case-insensitive
THEORY_DIR="$PROOF_CHECKER_ROOT/Theories/$THEORY_NAME/latex"
if [ ! -d "$THEORY_DIR" ]; then
    # Try to find case-insensitive match
    MATCHED_THEORY=$(find "$PROOF_CHECKER_ROOT/Theories" -maxdepth 1 -type d -iname "$THEORY_NAME" | head -1)
    if [ -n "$MATCHED_THEORY" ] && [ -d "$MATCHED_THEORY/latex" ]; then
        THEORY_DIR="$MATCHED_THEORY/latex"
        THEORY_NAME=$(basename "$MATCHED_THEORY")
    else
        echo "Error: Theory directory not found: $THEORY_NAME/latex"
        echo "Available theories with LaTeX directories:"
        find "$PROOF_CHECKER_ROOT/Theories" -maxdepth 2 -name "latex" -type d | while read dir; do
            echo "  $(basename $(dirname "$dir"))"
        done
        exit 1
    fi
fi

if [ ! -d "$THEORY_DIR" ]; then
    echo "Error: Theory directory not found: $THEORY_DIR"
    exit 1
fi

echo "Working on theory: $THEORY_NAME"
cd "$THEORY_DIR"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to clean all LaTeX build files
clean_all() {
    print_status "Cleaning all LaTeX build files..."
    latexmk -C
    rm -f *.aux *.log *.out *.toc *.fdb_latexmk *.fls *.synctex.gz *.bbl *.blg
    rm -f build/*.aux build/*.log build/*.out build/*.toc build/*.fdb_latexmk build/*.fls build/*.synctex.gz build/*.bbl build/*.blg
    if [ -d "build" ]; then
        find build -name "*.aux" -delete 2>/dev/null || true
        find build -name "*.log" -delete 2>/dev/null || true
        find build -name "*.out" -delete 2>/dev/null || true
    fi
    print_status "Clean completed."
}

# Function to rebuild from scratch
rebuild() {
    print_status "Starting complete rebuild..."
    clean_all
    print_status "Compiling with XeLaTeX..."
    # Find main .tex file (look for common patterns)
    MAIN_TEX=$(find . -maxdepth 1 -name "*.tex" -not -name ".*" | head -1)
    if [ -z "$MAIN_TEX" ]; then
        print_error "No main .tex file found in $THEORY_DIR"
        exit 1
    fi
    
    MAIN_BASE=$(basename "$MAIN_TEX" .tex)
    
    if latexmk -f -pdf "$MAIN_TEX"; then
        print_status "Build successful!"
        echo ""
        print_status "Generated files:"
        ls -la build/*.pdf 2>/dev/null || print_warning "No PDF found in build/"
        echo ""
        print_status "Checking for warnings..."
        if [ -f "build/$MAIN_BASE.log" ]; then
            WARNINGS=$(grep -c "Warning" "build/$MAIN_BASE.log" || echo "0")
            echo "Found $WARNINGS warnings in compilation log"
            if [ "$WARNINGS" -gt 0 ]; then
                echo ""
                print_warning "Summary of warnings:"
                grep "Warning" "build/$MAIN_BASE.log" | head -5
            fi
        fi
    else
        print_error "Build failed!"
        echo ""
        print_status "Checking for errors..."
        if [ -f "build/$MAIN_BASE.log" ]; then
            grep -A3 -B1 "Error" "build/$MAIN_BASE.log" | tail -10 || true
        fi
        exit 1
    fi
}

# Function to check document health
check_document() {
    print_status "Checking document health..."
    
    # Find main .tex file
    MAIN_TEX=$(find . -maxdepth 1 -name "*.tex" -not -name ".*" | head -1)
    if [ -z "$MAIN_TEX" ]; then
        print_error "No main .tex file found in $THEORY_DIR"
        exit 1
    fi
    
    MAIN_BASE=$(basename "$MAIN_TEX" .tex)
    
    if [ ! -f "build/$MAIN_BASE.pdf" ]; then
        print_warning "PDF not found. Building first..."
        rebuild
        return
    fi
    
    echo ""
    print_status "Document statistics:"
    if [ -f "build/$MAIN_BASE.pdf" ]; then
        PAGES=$(pdfinfo "build/$MAIN_BASE.pdf" 2>/dev/null | grep Pages | awk '{print $2}' || echo "unknown")
        SIZE=$(ls -lh "build/$MAIN_BASE.pdf" | awk '{print $5}')
        echo "  Pages: $PAGES"
        echo "  Size: $SIZE"
    fi
    
    echo ""
    print_status "Checking for common issues..."
    
    # Check for undefined references
    if [ -f "build/$MAIN_BASE.log" ]; then
        UNDEFINED=$(grep -c "undefined" "build/$MAIN_BASE.log" 2>/dev/null | tr -d '\n' || echo "0")
        if [ "${UNDEFINED:-0}" -gt 0 ]; then
            print_warning "Found $UNDEFINED undefined references"
        else
            print_status "No undefined references found"
        fi
        
        # Check for missing bibliography entries
        MISSING_BIB=$(grep -c "Missing" "build/$MAIN_BASE.log" 2>/dev/null | tr -d '\n' || echo "0")
        if [ "${MISSING_BIB:-0}" -gt 0 ]; then
            print_warning "Found $MISSING_BIB missing bibliography entries"
            echo "Missing entries:"
            grep "Missing" "build/$MAIN_BASE.log" | head -3
        fi
    fi
    
    echo ""
    print_status "Document health check completed."
}

# Function to show help
show_help() {
    echo "LaTeX Fix Script for ProofChecker Theories"
    echo ""
    echo "Usage: $0 [command] [theory_name]"
    echo ""
    echo "Commands:"
    echo "  clean    Clean all build files"
    echo "  rebuild  Clean and rebuild from scratch"
    echo "  check    Check document health and statistics"
    echo "  help     Show this help message"
    echo ""
    echo "Theory names:"
    echo "  logos     - Logos Reference Manual"
    echo "  bimodal   - Bimodal Logic Theory"
    echo "  (others)  - Add as needed"
    echo ""
    echo "If no theory name is specified, it will be auto-detected from current directory."
    echo "If no command is specified, 'rebuild' is used as default."
    echo ""
    echo "Examples:"
    echo "  $0 rebuild logos    # Rebuild Logos theory"
    echo "  $0 check bimodal    # Check Bimodal theory health"
    echo "  cd Theories/Logos/latex && $0 rebuild  # Auto-detect Logos"
}

# Main execution
case "${1:-rebuild}" in
    "clean")
        clean_all
        ;;
    "rebuild")
        rebuild
        ;;
    "check")
        check_document
        ;;
    "help"|"-h"|"--help")
        show_help
        ;;
    *)
        print_error "Unknown command: $1"
        show_help
        exit 1
        ;;
esac