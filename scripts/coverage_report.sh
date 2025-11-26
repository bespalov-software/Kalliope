#!/bin/bash
# Coverage reporting script for Kalliope files
# Usage: ./scripts/coverage_report.sh [filter_pattern] [directory_pattern] [architecture] [build_dir]
# Examples:
#   ./scripts/coverage_report.sh GMPInteger Core/Integer
#   ./scripts/coverage_report.sh GMPFormattedIO Core/FormattedIO
#   ./scripts/coverage_report.sh FormattedIO Extensions
#   ./scripts/coverage_report.sh GMPInteger Core/Integer arm64 .build
#
# Environment variables (optional):
#   COVERAGE_ARCH - Architecture (default: arm64 or detected)
#   COVERAGE_BUILD_DIR - Build directory (default: .build)
#   COVERAGE_PROFDATA - Explicit path to profdata file
#   COVERAGE_BINARY - Explicit path to test binary

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get the project root directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT"

# Parameters with defaults
FILTER="${1:-GMPInteger}"
DIR_PATTERN="${2:-Core/Integer}"
ARCH="${3:-${COVERAGE_ARCH:-arm64}}"
BUILD_DIR="${4:-${COVERAGE_BUILD_DIR:-.build}}"

# Auto-detect architecture if not provided and not set via env var
if [ -z "$3" ] && [ -z "$COVERAGE_ARCH" ]; then
    # Try to detect from build directory structure
    DETECTED_ARCH=$(find "$BUILD_DIR" -type d -name "*-apple-*" 2>/dev/null | head -1 | sed -E 's/.*\/([^-]+)-.*/\1/' || echo "arm64")
    ARCH="${DETECTED_ARCH}"
fi

# Find coverage data and binary
if [ -n "$COVERAGE_PROFDATA" ] && [ -f "$COVERAGE_PROFDATA" ]; then
    PROFDATA="$COVERAGE_PROFDATA"
elif [ -n "$COVERAGE_PROFDATA" ]; then
    echo -e "${RED}Error: Specified profdata file not found: $COVERAGE_PROFDATA${NC}"
    exit 1
else
    # Search for profdata in common locations
    PROFDATA=$(find "$BUILD_DIR" -name "default.profdata" -type f 2>/dev/null | head -1)
    
    # Fallback to constructed path
    if [ -z "$PROFDATA" ]; then
        PROFDATA="$BUILD_DIR/${ARCH}-apple-macosx/debug/codecov/default.profdata"
    fi
fi

if [ -n "$COVERAGE_BINARY" ] && [ -f "$COVERAGE_BINARY" ]; then
    BINARY="$COVERAGE_BINARY"
elif [ -n "$COVERAGE_BINARY" ]; then
    echo -e "${RED}Error: Specified binary file not found: $COVERAGE_BINARY${NC}"
    exit 1
else
    # Search for test binary
    BINARY=$(find "$BUILD_DIR" -name "KalliopePackageTests" -type f 2>/dev/null | grep -E "\.xctest|KalliopePackageTests$" | head -1)
    
    # Fallback to constructed path
    if [ -z "$BINARY" ]; then
        BINARY="$BUILD_DIR/${ARCH}-apple-macosx/debug/KalliopePackageTests.xctest/Contents/MacOS/KalliopePackageTests"
    fi
fi

# Validate files exist
if [ ! -f "$PROFDATA" ]; then
    echo -e "${RED}Error: Coverage data not found at: $PROFDATA${NC}"
    echo -e "${YELLOW}Run 'swift test --enable-code-coverage' first.${NC}"
    echo -e "${BLUE}Or set COVERAGE_PROFDATA environment variable to specify the path.${NC}"
    exit 1
fi

if [ ! -f "$BINARY" ]; then
    echo -e "${RED}Error: Test binary not found at: $BINARY${NC}"
    echo -e "${YELLOW}Run 'swift test --enable-code-coverage' first.${NC}"
    echo -e "${BLUE}Or set COVERAGE_BINARY environment variable to specify the path.${NC}"
    exit 1
fi

echo "========================================="
echo "Coverage Report for $FILTER* files"
echo "Directory: Sources/Kalliope/$DIR_PATTERN"
echo "Architecture: $ARCH"
echo "Build Directory: $BUILD_DIR"
echo "========================================="
echo ""
echo -e "${BLUE}Profdata: $PROFDATA${NC}"
echo -e "${BLUE}Binary: $BINARY${NC}"
echo ""

# Summary report
echo -e "${GREEN}=== Coverage Summary ===${NC}"
xcrun llvm-cov report \
    -instr-profile="$PROFDATA" \
    "$BINARY" \
    -arch "$ARCH" 2>/dev/null | \
    grep -E "($FILTER|^Filename)" | \
    head -20

echo ""
echo -e "${YELLOW}=== Uncovered Lines (excluding preconditions/fatalError) ===${NC}"
echo ""

# Detailed uncovered lines for each file
# Support multiple directory patterns
SEARCH_DIRS=(
    "Sources/Kalliope/$DIR_PATTERN"
    "Sources/Kalliope/Extensions"
)

for dir in "${SEARCH_DIRS[@]}"; do
    if [ ! -d "$dir" ]; then
        continue
    fi
    
    for file in "$dir"/${FILTER}*.swift; do
    if [ ! -f "$file" ]; then
        continue
    fi
    
    echo "----------------------------------------"
    echo "File: $file"
    echo "----------------------------------------"
    
        # Get coverage summary for this file
        xcrun llvm-cov report \
            -instr-profile="$PROFDATA" \
            "$BINARY" \
            -arch "$ARCH" "$file" 2>/dev/null | \
            tail -1
        
        echo ""
        echo "Uncovered lines:"
    xcrun llvm-cov show \
        -instr-profile="$PROFDATA" \
        "$BINARY" \
            -arch "$ARCH" "$file" 2>&1 | \
        awk '/^[ ]*[0-9]+\|[ ]*0\|/ {
            line=$0
            gsub(/^[ ]*[0-9]+\|[ ]*0\|[ ]*/, "", line)
                if (line !~ /precondition/ && line !~ /fatalError/ && line !~ /^[ ]*$/) {
                print $1"|"line
            }
        }' | \
        head -30
    
    echo ""
    done
done

echo -e "${GREEN}=== Report Complete ===${NC}"

