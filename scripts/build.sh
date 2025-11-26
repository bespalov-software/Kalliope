#!/bin/zsh
# ============================================================================
# GMP and MPFR Library Build Script
# ============================================================================

set -euo pipefail

# ============================================================================
# USAGE DOCUMENTATION
# ============================================================================
#
# This script provides a unified interface for building GMP and MPFR libraries
# for multiple Apple platforms. All operations are performed via tasks.
#
# Basic Usage:
#   scripts/build.sh --task=<task-name> [--parameter=value ...]
#
# Available Tasks:
#   1. build          - Build GMP or MPFR library for a specific platform
#   2. link-libs      - Create library binaries and prepare headers for platforms
#   3. create-xcframework - Create XCFramework from built libraries
#   4. download       - Download and extract library source tarballs
#   5. docs           - Generate documentation (HTML for GMP/MPFR, DocC for Kalliope)
#   6. clean          - Clean build artifacts, downloaded files, or documentation
#
# ============================================================================
# TASK: build
# ============================================================================
# Builds GMP or MPFR library for a specific platform.
#
# Required Parameters:
#   --library <gmp|mpfr>
#       Which library to build. Must be either "gmp" or "mpfr".
#
#   --platform-name <platform>
#       Platform identifier. Supported platforms:
#       Single-arch: ios-arm64, tvos-arm64, watchos-arm64, visionos-arm64
#       Universal: ios-simulator, tvos-simulator, watchos-simulator,
#                  visionos-simulator, maccatalyst, macos
#       Individual archs: ios-simulator-arm64, ios-simulator-x86_64,
#                         macos-arm64, macos-x86_64, etc.
#
# Environment Variables (with defaults):
#   CURDIR              - Current directory (default: $(pwd))
#   VENDOR_DIR          - GMP vendor directory (default: Sources/CKalliope/vendor)
#   MPFR_VENDOR_DIR     - MPFR vendor directory (default: Sources/CLinus/vendor)
#   BUILD_DIR           - Build directory (default: $VENDOR_DIR/build)
#   GMP_VERSION         - GMP version (default: 6.3.0)
#   MPFR_VERSION        - MPFR version (default: 4.2.2)
#   SKIP_TESTS          - Set to "1" to skip test suite (default: run tests if possible)
#
# What it does:
#   - Validates SDK availability for the target platform
#   - Configures autotools (for GMP) if needed
#   - Runs configure script with platform-specific flags
#   - Builds the library using make
#   - Runs test suite if build target matches current machine
#   - Installs library to $VENDOR_DIR/$platform (GMP) or $MPFR_VENDOR_DIR/mpfr-$platform (MPFR)
#
# Examples:
#   # Build GMP for iOS arm64
#   scripts/build.sh --task=build --library=gmp --platform-name=ios-arm64
#
#   # Build MPFR for macOS (universal)
#   scripts/build.sh --task=build --library=mpfr --platform-name=macos-arm64
#
#   # Build with custom vendor directory
#   VENDOR_DIR=/custom/path scripts/build.sh --task=build --library=gmp --platform-name=ios-arm64
#
#   # Build and skip tests
#   SKIP_TESTS=1 scripts/build.sh --task=build --library=gmp --platform-name=macos-arm64
#
# ============================================================================
# TASK: link-libs
# ============================================================================
# Creates library binaries and prepares headers for one or more platforms.
# For universal platforms, creates universal binaries from arm64 + x86_64.
#
# Required Parameters:
#   --library <gmp|mpfr>
#       Which library to process. Must be either "gmp" or "mpfr".
#
#   --platforms <platform1 platform2 ...>
#       Space-separated list of platform identifiers. Can include both
#       single-arch and universal platforms.
#
# Environment Variables (with defaults):
#   BUILD_DIR           - Build directory (default: Sources/CKalliope/vendor/build)
#   VENDOR_DIR          - GMP vendor directory (default: Sources/CKalliope/vendor)
#   MPFR_VENDOR_DIR     - MPFR vendor directory (default: Sources/CLinus/vendor)
#
# Output Structure:
#   For each platform, creates:
#   $BUILD_DIR/{gmp,mpfr}-libs/$platform/
#     ├── lib/
#     │   └── lib{gmp,mpfr}.a
#     └── include/
#         ├── {gmp,mpfr}.h
#         └── module.modulemap
#
# What it does:
#   - For single-arch platforms: Copies library from vendor directory
#   - For universal platforms: Creates universal binary using lipo
#   - Prepares headers with module.modulemap for Swift module system
#   - For MPFR: Also copies gmp.h and modifies mpfr.h to use local gmp.h
#
# Examples:
#   # Prepare GMP libraries for all platforms
#   scripts/build.sh --task=link-libs --library=gmp --platforms="ios-arm64 ios-simulator macos"
#
#   # Prepare MPFR libraries for specific platforms
#   scripts/build.sh --task=link-libs --library=mpfr --platforms="macos-arm64 macos-x86_64"
#
# ============================================================================
# TASK: create-xcframework
# ============================================================================
# Creates an XCFramework from previously built libraries and headers.
# Requires that link-libs has been run for all target platforms.
#
# Required Parameters:
#   --library <gmp|mpfr>
#       Which library xcframework to create. Must be either "gmp" or "mpfr".
#
#   --xcframework-dir <path>
#       Output directory for the XCFramework. Will be created/overwritten.
#
#   --platforms <platform1 platform2 ...>
#       Space-separated list of platforms to include in the XCFramework.
#       All platforms must have been processed by link-libs first.
#
# Environment Variables (with defaults):
#   BUILD_DIR           - Build directory (default: Sources/CKalliope/vendor/build)
#
# What it does:
#   - Uses xcodebuild -create-xcframework to combine libraries
#   - Includes headers and module.modulemap for each platform
#   - Creates a single XCFramework that can be used in Xcode projects
#
# Examples:
#   # Create GMP XCFramework
#   scripts/build.sh --task=create-xcframework \
#     --library=gmp \
#     --xcframework-dir=Sources/CKalliope/extra/CKalliope.xcframework \
#     --platforms="ios-arm64 ios-simulator macos maccatalyst"
#
#   # Create MPFR XCFramework
#   scripts/build.sh --task=create-xcframework \
#     --library=mpfr \
#     --xcframework-dir=Sources/CLinus/extra/CLinus.xcframework \
#     --platforms="ios-arm64 ios-simulator macos"
#
# ============================================================================
# TASK: download
# ============================================================================
# Downloads and extracts library source tarballs.
# Automatically extracts after download if source directory doesn't exist.
#
# Required Parameters:
#   --library <gmp|mpfr>
#       Which library to download. Must be either "gmp" or "mpfr".
#
# Environment Variables (with defaults):
#   VENDOR_DIR          - GMP vendor directory (default: Sources/CKalliope/vendor)
#   MPFR_VENDOR_DIR     - MPFR vendor directory (default: Sources/CLinus/vendor)
#   GMP_VERSION         - GMP version (default: 6.3.0)
#   MPFR_VERSION        - MPFR version (default: 4.2.2)
#   CURDIR              - Current directory (default: $(pwd))
#
# What it does:
#   - Downloads tarball if it doesn't exist
#   - Extracts tarball using appropriate tool (lzip for GMP, xz for MPFR)
#   - Skips download if tarball already exists
#   - Skips extraction if source directory already exists
#
# Dependencies:
#   - GMP: Requires lzip or plzip (brew install lzip)
#   - MPFR: Requires xz or unxz (usually pre-installed on macOS)
#
# Examples:
#   # Download and extract GMP
#   scripts/build.sh --task=download --library=gmp
#
#   # Download and extract MPFR
#   scripts/build.sh --task=download --library=mpfr
#
#   # Download specific version
#   GMP_VERSION=6.2.1 scripts/build.sh --task=download --library=gmp
#
# ============================================================================
# TASK: docs
# ============================================================================
# Generates documentation for GMP, MPFR, or Kalliope.
#
# Required Parameters:
#   --library <gmp|mpfr|Kalliope>
#       Which documentation to generate:
#       - gmp: HTML documentation from gmp.texi
#       - mpfr: HTML documentation from mpfr.texi
#       - Kalliope: Swift symbol graphs and DocC HTML documentation
#
# Environment Variables (with defaults):
#   For GMP:
#     VENDOR_DIR        - GMP vendor directory (default: Sources/CKalliope/vendor)
#     GMP_VERSION       - GMP version (default: 6.3.0)
#     GMP_DOCS_DIR      - Output directory (default: $VENDOR_DIR/gmp-docs)
#     CURDIR            - Current directory (default: $(pwd))
#
#   For MPFR:
#     MPFR_VENDOR_DIR   - MPFR vendor directory (default: Sources/CLinus/vendor)
#     MPFR_VERSION      - MPFR version (default: 4.2.2)
#     MPFR_DOCS_DIR     - Output directory (default: $MPFR_VENDOR_DIR/mpfr-docs)
#     CURDIR            - Current directory (default: $(pwd))
#
#   For Kalliope:
#     DOCS_DIR          - Output directory (default: docs)
#     CURDIR            - Current directory (default: $(pwd))
#
# Dependencies:
#   - GMP/MPFR: Requires makeinfo (brew install texinfo)
#   - Kalliope: Requires Swift and Xcode (for DocC)
#
# What it does:
#   - GMP/MPFR: Generates HTML documentation using makeinfo
#   - Kalliope: Generates Swift symbol graphs and DocC HTML documentation
#
# Examples:
#   # Generate GMP HTML documentation
#   scripts/build.sh --task=docs --library=gmp
#
#   # Generate MPFR HTML documentation
#   scripts/build.sh --task=docs --library=mpfr
#
#   # Generate Kalliope Swift documentation
#   scripts/build.sh --task=docs --library=Kalliope
#
# ============================================================================
# TASK: clean
# ============================================================================
# Cleans build artifacts, downloaded files, or generated documentation.
#
# Optional Parameters:
#   --what <all|build|docs>
#       What to clean (default: all):
#       - all: Removes all downloaded source files, build artifacts, and xcframeworks
#       - build: Removes only build artifacts (keeps downloaded source)
#       - docs: Removes generated documentation (preserves DocC bundle if present)
#
# Environment Variables (with defaults):
#   VENDOR_DIR          - GMP vendor directory (default: Sources/CKalliope/vendor)
#   MPFR_VENDOR_DIR     - MPFR vendor directory (default: Sources/CLinus/vendor)
#   BUILD_DIR           - Build directory (default: $VENDOR_DIR/build)
#   DOCS_DIR            - Documentation directory (default: docs)
#   XCFRAMEWORK_DIR     - GMP XCFramework directory (default: Sources/CKalliope/extra/CKalliope.xcframework)
#   CLINUS_XCFRAMEWORK_DIR - MPFR XCFramework directory (default: Sources/CLinus/extra/CLinus.xcframework)
#   CURDIR              - Current directory (default: $(pwd))
#
# What it does:
#   - all: Removes vendor directories, build directories, xcframeworks, and extra directories
#   - build: Removes build directories, platform install directories, and xcframeworks
#   - docs: Removes documentation directory while preserving Kalliope.docc bundle if present
#
# Examples:
#   # Clean everything (downloaded sources, builds, xcframeworks)
#   scripts/build.sh --task=clean --what=all
#
#   # Clean only build artifacts (keep downloaded sources)
#   scripts/build.sh --task=clean --what=build
#
#   # Clean only documentation
#   scripts/build.sh --task=clean --what=docs
#
#   # Clean with default (all)
#   scripts/build.sh --task=clean
#
# ============================================================================
# SUPPORTED PLATFORMS
# ============================================================================
#
# Single-Arch Platforms (device only):
#   - ios-arm64          (iOS 13.0+)
#   - tvos-arm64         (tvOS 15.0+)
#   - watchos-arm64      (watchOS 8.0+)
#   - visionos-arm64     (visionOS 1.0+)
#
# Universal Platforms (automatically combines arm64 + x86_64):
#   - ios-simulator       (iOS Simulator)
#   - tvos-simulator      (tvOS Simulator)
#   - watchos-simulator   (watchOS Simulator)
#   - visionos-simulator  (visionOS Simulator)
#   - maccatalyst         (macCatalyst)
#   - macos               (macOS 11.0+)
#
# Individual Architecture Variants (for building specific archs):
#   - ios-simulator-arm64, ios-simulator-x86_64
#   - tvos-simulator-arm64, tvos-simulator-x86_64
#   - watchos-simulator-arm64, watchos-simulator-x86_64
#   - visionos-simulator-arm64, visionos-simulator-x86_64
#   - maccatalyst-arm64, maccatalyst-x86_64
#   - macos-arm64, macos-x86_64
#
# ============================================================================
# INTERNAL FUNCTIONS (Not exposed as tasks)
# ============================================================================
#
# These functions are used internally by tasks and are not accessible via --task:
#
#   validate_sdk(sdk_name, platform_name)
#       Validates that the required SDK is available. Called by task_build.
#
#   create_universal_lib(universal_lib_dir, arm64_lib_path, x86_64_lib_path, lib_name, display_name)
#       Creates a universal binary using lipo. Called by task_link_libs.
#
#   prepare_headers(library, headers_dir, install_dir, gmp_install_dir, platform_name)
#       Copies headers and creates module.modulemap. Called by task_link_libs.
#
#   create_framework(framework_dir, lib_path, headers_dir, modules_dir, framework_name, min_version)
#       Creates a framework bundle structure. Called by task_create_xcframework.
#
#   create_universal_framework(universal_framework_dir, arm64_framework_dir, x86_64_framework_dir, display_name)
#       Creates a universal framework by combining arm64 + x86_64 frameworks using lipo.
#       Called by task_create_xcframework.
#
#   extract_library(library, vendor_dir, tarball_path, extract_dir)
#       Extracts library tarball using appropriate tool. Called by task_download.
#
#   check_platform(build_dir, platform_name)
#       Runs test suite for already-built library. Can be called directly from Makefile.
#
# ============================================================================
# PARAMETER FORMAT
# ============================================================================
#
# Parameters can be specified in two formats:
#   1. --parameter=value
#   2. --parameter value
#
# Examples:
#   scripts/build.sh --task=build --library=gmp --platform-name=ios-arm64
#   scripts/build.sh --task=build --library=gmp --platform-name ios-arm64
#
# ============================================================================
# ERROR HANDLING
# ============================================================================
#
# The script uses "set -euo pipefail" for strict error handling:
#   - set -e: Exit immediately if a command exits with non-zero status
#   - set -u: Treat unset variables as an error
#   - set -o pipefail: Return value of a pipeline is the status of the last
#                      command to exit with a non-zero status
#
# All errors are printed to stderr with red color coding for visibility.
#
# ============================================================================

set -euo pipefail

# ============================================================================
# Color Codes
# ============================================================================
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# ============================================================================
# Platform Configurations
# ============================================================================
# Format: platform_name|sdk_name|host_triple|arch|disable_assembly|platform_id|min_version|cflags_template
typeset -A PLATFORM_CONFIGS

PLATFORM_CONFIGS["ios-arm64"]="ios-arm64|iphoneos|arm64-apple-ios|arm64|1|ios|13.0|-arch %ARCH% -isysroot %SDK% -mios-version-min=%MIN_VERSION%"
PLATFORM_CONFIGS["ios-simulator-arm64"]="ios-simulator-arm64|iphonesimulator|arm64-apple-ios|arm64|1|ios-simulator|13.0|-arch %ARCH% -isysroot %SDK% -mios-simulator-version-min=%MIN_VERSION%"
PLATFORM_CONFIGS["ios-simulator-x86_64"]="ios-simulator-x86_64|iphonesimulator|x86_64-apple-ios|x86_64|1|ios-simulator|13.0|-arch %ARCH% -isysroot %SDK% -mios-simulator-version-min=%MIN_VERSION%"
PLATFORM_CONFIGS["tvos-arm64"]="tvos-arm64|appletvos|arm64-apple-ios|arm64|1|tvos|15.0|-arch %ARCH% -isysroot %SDK% -mtvos-version-min=%MIN_VERSION%"
PLATFORM_CONFIGS["tvos-simulator-arm64"]="tvos-simulator-arm64|appletvsimulator|arm64-apple-ios|arm64|1|tvos-simulator|15.0|-arch %ARCH% -isysroot %SDK% -mtvos-simulator-version-min=%MIN_VERSION%"
PLATFORM_CONFIGS["tvos-simulator-x86_64"]="tvos-simulator-x86_64|appletvsimulator|x86_64-apple-ios|x86_64|1|tvos-simulator|15.0|-arch %ARCH% -isysroot %SDK% -mtvos-simulator-version-min=%MIN_VERSION%"
PLATFORM_CONFIGS["watchos-arm64"]="watchos-arm64|watchos|arm64-apple-ios|arm64|1|watchos|8.0|-arch %ARCH% -isysroot %SDK% -mwatchos-version-min=%MIN_VERSION%"
PLATFORM_CONFIGS["watchos-simulator-arm64"]="watchos-simulator-arm64|watchsimulator|arm64-apple-ios|arm64|1|watchos-simulator|8.0|-arch %ARCH% -isysroot %SDK% -mwatchos-simulator-version-min=%MIN_VERSION%"
PLATFORM_CONFIGS["watchos-simulator-x86_64"]="watchos-simulator-x86_64|watchsimulator|x86_64-apple-ios|x86_64|1|watchos-simulator|8.0|-arch %ARCH% -isysroot %SDK% -mwatchos-simulator-version-min=%MIN_VERSION%"
PLATFORM_CONFIGS["visionos-arm64"]="visionos-arm64|xros|arm64-apple-ios|arm64|1|xros|1.0|-arch %ARCH% -isysroot %SDK% -target arm64-apple-xros%MIN_VERSION%"
PLATFORM_CONFIGS["visionos-simulator-arm64"]="visionos-simulator-arm64|xrsimulator|arm64-apple-ios|arm64|1|xros-simulator|1.0|-arch %ARCH% -isysroot %SDK% -target arm64-apple-xros%MIN_VERSION%-simulator"
PLATFORM_CONFIGS["visionos-simulator-x86_64"]="visionos-simulator-x86_64|xrsimulator|x86_64-apple-ios|x86_64|1|xros-simulator|1.0|-arch %ARCH% -isysroot %SDK% -target x86_64-apple-xros%MIN_VERSION%-simulator"
PLATFORM_CONFIGS["maccatalyst-arm64"]="maccatalyst-arm64|macosx|arm64-apple-ios|arm64|1|maccatalyst|15.0|-arch %ARCH% -isysroot %SDK% -target arm64-apple-ios-macabi -miphoneos-version-min=%MIN_VERSION%"
PLATFORM_CONFIGS["maccatalyst-x86_64"]="maccatalyst-x86_64|macosx|x86_64-apple-ios|x86_64|1|maccatalyst|15.0|-arch %ARCH% -isysroot %SDK% -target x86_64-apple-ios-macabi -miphoneos-version-min=%MIN_VERSION%"
PLATFORM_CONFIGS["macos-arm64"]="macos-arm64|macosx|arm64-apple-darwin|arm64|0|macos|11.0|-arch %ARCH% -isysroot %SDK% -mmacosx-version-min=%MIN_VERSION%"
PLATFORM_CONFIGS["macos-x86_64"]="macos-x86_64|macosx|x86_64-apple-darwin|x86_64|0|macos|11.0|-arch %ARCH% -isysroot %SDK% -mmacosx-version-min=%MIN_VERSION%"

# Universal platform mappings (base name -> arm64 and x86_64 platform names)
# Format: base_name|arm64_platform|x86_64_platform|display_name
typeset -A UNIVERSAL_PLATFORM_CONFIGS

UNIVERSAL_PLATFORM_CONFIGS["ios-simulator"]="ios-simulator|ios-simulator-arm64|ios-simulator-x86_64|iOS Simulator"
UNIVERSAL_PLATFORM_CONFIGS["tvos-simulator"]="tvos-simulator|tvos-simulator-arm64|tvos-simulator-x86_64|tvOS Simulator"
UNIVERSAL_PLATFORM_CONFIGS["watchos-simulator"]="watchos-simulator|watchos-simulator-arm64|watchos-simulator-x86_64|watchOS Simulator"
UNIVERSAL_PLATFORM_CONFIGS["visionos-simulator"]="visionos-simulator|visionos-simulator-arm64|visionos-simulator-x86_64|visionOS Simulator"
UNIVERSAL_PLATFORM_CONFIGS["maccatalyst"]="maccatalyst|maccatalyst-arm64|maccatalyst-x86_64|macCatalyst"
UNIVERSAL_PLATFORM_CONFIGS["macos"]="macos|macos-arm64|macos-x86_64|macOS"

UNIVERSAL_PLATFORMS="ios-simulator tvos-simulator watchos-simulator visionos-simulator maccatalyst macos"
SINGLE_ARCH_PLATFORMS="ios-arm64 tvos-arm64 watchos-arm64 visionos-arm64"

# ============================================================================
# Helper Functions
# ============================================================================

# Get platform config field by index
# Field indices: 1=platform_name, 2=sdk_name, 3=host_triple, 4=arch, 5=disable_assembly, 6=platform_id, 7=min_version, 8=cf_flags_template
get_platform_field() {
    local platform_name="$1"
    local field_index="$2"
    local config="${PLATFORM_CONFIGS["$platform_name"]:-}"
    if [ -z "$config" ]; then
        echo "ERROR: Unknown platform: $platform_name" >&2
        return 1
    fi
    echo "$config" | cut -d'|' -f"$field_index"
}

# Get universal platform config field by index
# Field indices: 1=base_name, 2=arm64_platform, 3=x86_64_platform, 4=display_name
get_universal_field() {
    local base_name="$1"
    local field_index="$2"
    local config="${UNIVERSAL_PLATFORM_CONFIGS["$base_name"]:-}"
    if [ -z "$config" ]; then
        echo "ERROR: Unknown universal platform: $base_name" >&2
        return 1
    fi
    echo "$config" | cut -d'|' -f"$field_index"
}

# Parse platform config into variables
parse_platform_config() {
    local platform_name="$1"
    local config="${PLATFORM_CONFIGS["$platform_name"]:-}"
    if [ -z "$config" ]; then
        echo "ERROR: Unknown platform: $platform_name" >&2
        return 1
    fi
    
    IFS='|' read -r platform_name_val sdk_name host_triple arch disable_assembly platform_id min_version cflags_template <<< "$config"
    
    # Export as individual variables (using eval to set in caller's scope)
    eval "PLATFORM_SDK_NAME='$sdk_name'"
    eval "PLATFORM_HOST_TRIPLE='$host_triple'"
    eval "PLATFORM_ARCH='$arch'"
    eval "PLATFORM_DISABLE_ASSEMBLY='$disable_assembly'"
    eval "PLATFORM_ID='$platform_id'"
    eval "PLATFORM_MIN_VERSION='$min_version'"
    eval "PLATFORM_CFLAGS_TEMPLATE='$cflags_template'"
}

# Expand CFLAGS template
expand_cflags() {
    local platform_name="$1"
    local sdk_path="$2"
    local arch="$3"
    local min_version="$4"
    
    parse_platform_config "$platform_name"
    local cflags_template="$PLATFORM_CFLAGS_TEMPLATE"
    
    # Use zsh parameter expansion for string replacement
    cflags_template="${cflags_template//\%ARCH\%/$arch}"
    cflags_template="${cflags_template//\%SDK\%/$sdk_path}"
    cflags_template="${cflags_template//\%MIN_VERSION\%/$min_version}"
    
    echo "$cflags_template"
}

# Find Xcode tool
find_xcode_tool() {
    local tool_name="$1"
    local tool_path
    tool_path=$(xcrun --find "$tool_name" 2>/dev/null || echo "")
    if [ -z "$tool_path" ]; then
        tool_path="/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/$tool_name"
    fi
    echo "$tool_path"
}

# Detect autotools from Homebrew
detect_autotools() {
    local tool_name="$1"
    local brew_prefix=""
    
    if command -v brew >/dev/null 2>&1; then
        brew_prefix=$(brew --prefix 2>/dev/null || echo "")
    elif [ -d "/opt/homebrew" ]; then
        brew_prefix="/opt/homebrew"
    elif [ -d "/usr/local" ]; then
        brew_prefix="/usr/local"
    fi
    
    if [ -n "$brew_prefix" ] && [ -f "$brew_prefix/bin/$tool_name" ]; then
        echo "$brew_prefix/bin/$tool_name"
    elif [ -f "/opt/homebrew/bin/$tool_name" ]; then
        echo "/opt/homebrew/bin/$tool_name"
    elif [ -f "/usr/local/bin/$tool_name" ]; then
        echo "/usr/local/bin/$tool_name"
    elif command -v "$tool_name" >/dev/null 2>&1; then
        command -v "$tool_name"
    else
        echo ""
    fi
}

# Check if platform is universal (needs universal binary)
is_universal_platform() {
    local platform_name="$1"
    case "$platform_name" in
        ios-simulator|tvos-simulator|watchos-simulator|visionos-simulator|maccatalyst|macos)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

# Get arm64 variant for universal platform
get_arm64_platform() {
    local base_platform="$1"
    get_universal_field "$base_platform" 2
}

# Get x86_64 variant for universal platform
get_x86_64_platform() {
    local base_platform="$1"
    get_universal_field "$base_platform" 3
}

# Get display name for platform
get_display_name() {
    local platform_name="$1"
    if is_universal_platform "$platform_name"; then
        get_universal_field "$platform_name" 4
    else
        case "$platform_name" in
            ios-arm64) echo "iOS" ;;
            tvos-arm64) echo "tvOS" ;;
            watchos-arm64) echo "watchOS" ;;
            visionos-arm64) echo "visionOS" ;;
            *) echo "$platform_name" ;;
        esac
    fi
}

# Determine if tests should run
should_run_tests() {
    local host_triple="$1"
    
    if [ "${SKIP_TESTS:-}" = "1" ]; then
        return 1
    fi
    
    local current_arch=$(uname -m)
    local current_os=$(uname -s | tr '[:upper:]' '[:lower:]')
    local host_arch=$(echo "$host_triple" | cut -d'-' -f1)
    local host_os=$(echo "$host_triple" | cut -d'-' -f3-)
    
    if [ "$host_arch" = "aarch64" ]; then
        host_arch="arm64"
    fi
    
    # Only run tests if build target matches current machine
    if [ "$current_os" = "darwin" ] && [ "$host_os" = "darwin" ]; then
        if [ "$current_arch" = "$host_arch" ]; then
            return 0
        fi
    fi
    
    # Don't run tests for iOS/tvOS/watchOS/visionOS/macCatalyst
    case "$host_os" in
        ios|ios-simulator|tvos|tvos-simulator|watchos|watchos-simulator|xros|xros-simulator|maccatalyst)
            return 1
            ;;
    esac
    
    return 1
}

# ============================================================================
# Internal Functions (Not exposed as tasks)
# ============================================================================

# Validate SDK
validate_sdk() {
    local sdk_name="$1"
    local platform_name="$2"
    
    local sdk_path
    sdk_path=$(xcrun --sdk "$sdk_name" --show-sdk-path 2>/dev/null || echo "")
    if [ -z "$sdk_path" ]; then
        echo -e "${RED}ERROR: $platform_name SDK not found. Make sure Xcode is installed.${NC}" >&2
        exit 1
    fi
    
    local sdk_version
    sdk_version=$(xcrun --sdk "$sdk_name" --show-sdk-version 2>/dev/null || echo "")
    if [ -z "$sdk_version" ]; then
        echo -e "${RED}ERROR: $platform_name SDK version not found. Make sure Xcode is installed.${NC}" >&2
        exit 1
    fi
}

# Create universal library (combine arm64 + x86_64 with lipo)
create_universal_lib() {
    local universal_lib_dir="$1"
    local arm64_lib_path="$2"
    local x86_64_lib_path="$3"
    local lib_name="$4"
    local display_name="${5:-}"
    
    if [ -z "$display_name" ]; then
        display_name="$lib_name"
    fi
    
    echo "Creating universal $display_name $lib_name library (arm64 + x86_64)..."
    
    if [ ! -f "$arm64_lib_path" ]; then
        echo -e "${RED}ERROR: ARM64 library not found at $arm64_lib_path${NC}" >&2
        exit 1
    fi
    
    if [ ! -f "$x86_64_lib_path" ]; then
        echo -e "${RED}ERROR: x86_64 library not found at $x86_64_lib_path${NC}" >&2
        exit 1
    fi
    
    mkdir -p "$universal_lib_dir"
    
    local universal_lib="$universal_lib_dir/$lib_name"
    if [ -f "$universal_lib" ] && \
       [ "$universal_lib" -nt "$arm64_lib_path" ] && \
       [ "$universal_lib" -nt "$x86_64_lib_path" ]; then
        echo "Universal $display_name $lib_name library already exists and is up to date (skipping)"
    else
        local xcode_lipo
        xcode_lipo=$(find_xcode_tool lipo)
        "$xcode_lipo" -create "$arm64_lib_path" "$x86_64_lib_path" -output "$universal_lib"
        echo "Universal binary architectures:"
        "$xcode_lipo" -info "$universal_lib"
        echo -e "${GREEN}✓ Universal $display_name $lib_name library created at $universal_lib${NC}"
    fi
}

# Prepare headers directory
prepare_headers() {
    local library="$1"
    local headers_dir="$2"
    local install_dir="$3"
    local gmp_install_dir="${4:-}"
    local platform_name="${5:-}"
    
    mkdir -p "$headers_dir"
    
    if [ "$library" = "gmp" ]; then
        echo "Preparing GMP headers${platform_name:+ for $platform_name}..."
        if [ -d "$install_dir/include" ]; then
            cp "$install_dir/include/"*.h "$headers_dir/" 2>/dev/null || true
        fi
        if [ ! -f "$headers_dir/gmp.h" ]; then
            echo -e "${RED}  ERROR: gmp.h not found after copy${NC}" >&2
            exit 1
        fi
        # Create Modules directory for module.modulemap (required by xcodebuild -create-xcframework)
        # Modules must be at the same level as Headers (which is "include" in our structure)
        local modules_dir
        modules_dir="$(dirname "$headers_dir")/Modules"
        mkdir -p "$modules_dir"
        echo "framework module CKalliope {" > "$modules_dir/module.modulemap"
        echo "    header \"gmp.h\"" >> "$modules_dir/module.modulemap"
        echo "    export *" >> "$modules_dir/module.modulemap"
        echo "}" >> "$modules_dir/module.modulemap"
        echo "  Created module.modulemap in Modules directory"
        echo -e "${GREEN}✓ GMP headers prepared at $headers_dir${NC}"
    elif [ "$library" = "mpfr" ]; then
        echo "Preparing MPFR headers${platform_name:+ for $platform_name}..."
        if [ -d "$install_dir/include" ]; then
            cp "$install_dir/include/"*.h "$headers_dir/" 2>/dev/null || true
        fi
        
        # Determine GMP install dir if not provided
        if [ -z "$gmp_install_dir" ]; then
            local mpfr_dir_name
            mpfr_dir_name=$(basename "$install_dir")
            local gmp_platform
            gmp_platform=$(echo "$mpfr_dir_name" | sed 's/^mpfr-//')
            gmp_install_dir="${VENDOR_DIR:-Sources/CKalliope/vendor}/$gmp_platform"
        fi
        
        if [ -f "$gmp_install_dir/include/gmp.h" ]; then
            cp "$gmp_install_dir/include/gmp.h" "$headers_dir/" && \
            echo "  Copied gmp.h from $gmp_install_dir"
        else
            echo -e "${RED}  ERROR: gmp.h not found at $gmp_install_dir/include/gmp.h${NC}" >&2
            exit 1
        fi
        
        if [ -f "$headers_dir/mpfr.h" ]; then
            if grep -q '#include <gmp\.h>' "$headers_dir/mpfr.h" 2>/dev/null; then
                sed -i '' 's/#include <gmp\.h>/#include "gmp.h"/' "$headers_dir/mpfr.h" && \
                echo "  Modified mpfr.h in include directory to use quotes for gmp.h"
            fi
        else
            echo -e "${RED}  ERROR: mpfr.h not found in include directory after copy${NC}" >&2
            exit 1
        fi
        
        # Create Modules directory for module.modulemap (required by xcodebuild -create-xcframework)
        local modules_dir
        modules_dir="$(dirname "$headers_dir")/Modules"
        mkdir -p "$modules_dir"
        echo "framework module CLinus {" > "$modules_dir/module.modulemap"
        echo "    header \"gmp.h\"" >> "$modules_dir/module.modulemap"
        echo "    header \"mpfr.h\"" >> "$modules_dir/module.modulemap"
        echo "    link \"CKalliope\"" >> "$modules_dir/module.modulemap"
        echo "    export *" >> "$modules_dir/module.modulemap"
        echo "}" >> "$modules_dir/module.modulemap"
        echo "  Created module.modulemap in Modules directory"
        echo -e "${GREEN}✓ MPFR headers prepared at $headers_dir${NC}"
    else
        echo -e "${RED}ERROR: Unknown library: $library${NC}" >&2
        exit 1
    fi
}

# Create framework bundle structure
create_framework() {
    local framework_dir="$1"
    local lib_path="$2"
    local headers_dir="$3"
    local modules_dir="$4"
    local framework_name="$5"
    local min_version="${6:-11.0}"
    
    local framework_path="$framework_dir/$framework_name.framework"
    
    echo "Creating framework bundle for $framework_name..."
    rm -rf "$framework_path"
    mkdir -p "$framework_path/Headers"
    mkdir -p "$framework_path/Modules"
    
    if [ ! -f "$lib_path" ]; then
        echo -e "${RED}ERROR: Static library not found at $lib_path${NC}" >&2
        exit 1
    fi
    
    # Copy library binary (rename to framework name)
    cp "$lib_path" "$framework_path/$framework_name"
    
    # Copy headers
    if [ -d "$headers_dir" ]; then
        cp "$headers_dir"/*.h "$framework_path/Headers/" 2>/dev/null || true
    fi
    
    # Verify required header exists
    if [ "$framework_name" = "CKalliope" ]; then
        if [ ! -f "$framework_path/Headers/gmp.h" ]; then
            echo -e "${RED}ERROR: gmp.h not found in Headers directory${NC}" >&2
            exit 1
        fi
    elif [ "$framework_name" = "CLinus" ]; then
        if [ ! -f "$framework_path/Headers/mpfr.h" ]; then
            echo -e "${RED}ERROR: mpfr.h not found in Headers directory${NC}" >&2
            exit 1
        fi
    fi
    
    # Copy module.modulemap
    if [ -d "$modules_dir" ] && [ -f "$modules_dir/module.modulemap" ]; then
        cp "$modules_dir/module.modulemap" "$framework_path/Modules/"
    else
        echo -e "${RED}ERROR: module.modulemap not found at $modules_dir${NC}" >&2
        exit 1
    fi
    
    # Create Info.plist
    if ! plutil -create -xml "$framework_path/Info.plist" > /dev/null 2>&1; then
        cat > "$framework_path/Info.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict/>
</plist>
EOF
    fi
    
    plutil -replace CFBundleDevelopmentRegion -string "en" "$framework_path/Info.plist"
    plutil -replace CFBundleExecutable -string "$framework_name" "$framework_path/Info.plist"
    plutil -replace CFBundleIdentifier -string "com.kalliope.$framework_name" "$framework_path/Info.plist"
    plutil -replace CFBundleInfoDictionaryVersion -string "6.0" "$framework_path/Info.plist"
    plutil -replace CFBundleName -string "$framework_name" "$framework_path/Info.plist"
    plutil -replace CFBundlePackageType -string "FMWK" "$framework_path/Info.plist"
    plutil -replace CFBundleShortVersionString -string "1.0" "$framework_path/Info.plist"
    plutil -replace CFBundleVersion -string "1" "$framework_path/Info.plist"
    plutil -replace MinimumOSVersion -string "$min_version" "$framework_path/Info.plist"
    
    echo -e "${GREEN}✓ Framework bundle created at $framework_path${NC}"
}

# Create universal framework (combine arm64 + x86_64)
create_universal_framework() {
    local universal_framework_dir="$1"
    local arm64_framework_dir="$2"
    local x86_64_framework_dir="$3"
    local display_name="${4:-}"
    local framework_name="${5:-}"
    
    if [ -z "$display_name" ]; then
        display_name="Universal"
    fi
    
    if [ -z "$framework_name" ]; then
        # Try to get framework name from arm64 framework directory
        if [ -d "$arm64_framework_dir" ]; then
            for fw in "$arm64_framework_dir"/*.framework; do
                if [ -d "$fw" ]; then
                    framework_name=$(basename "$fw" .framework)
                    break
                fi
            done
        fi
        if [ -z "$framework_name" ]; then
            echo -e "${RED}ERROR: Could not determine framework name from $arm64_framework_dir${NC}" >&2
            exit 1
        fi
    fi
    
    echo "Creating universal $display_name framework (arm64 + x86_64)..."
    
    local arm64_framework="$arm64_framework_dir/$framework_name.framework"
    local x86_64_framework="$x86_64_framework_dir/$framework_name.framework"
    local universal_framework="$universal_framework_dir/$framework_name.framework"
    
    if [ ! -d "$arm64_framework" ]; then
        echo -e "${RED}ERROR: ARM64 framework not found at $arm64_framework${NC}" >&2
        exit 1
    fi
    
    if [ ! -d "$x86_64_framework" ]; then
        echo -e "${RED}ERROR: x86_64 framework not found at $x86_64_framework${NC}" >&2
        exit 1
    fi
    
    rm -rf "$universal_framework"
    mkdir -p "$universal_framework"
    
    # Copy structure from arm64 framework
    cp -R "$arm64_framework/"* "$universal_framework/"
    
    # Create universal binary using lipo
    local xcode_lipo
    xcode_lipo=$(find_xcode_tool lipo)
    "$xcode_lipo" -create \
        "$arm64_framework/$framework_name" \
        "$x86_64_framework/$framework_name" \
        -output "$universal_framework/$framework_name"
    
    echo "Universal binary architectures:"
    "$xcode_lipo" -info "$universal_framework/$framework_name"
    
    echo -e "${GREEN}✓ Universal $display_name framework created at $universal_framework${NC}"
}

# Extract library tarball
extract_library() {
    local library="$1"
    local vendor_dir="$2"
    local tarball_path="$3"
    local extract_dir="$4"
    
    if [ -d "$extract_dir" ]; then
        echo "${(U)library} already extracted at: $extract_dir"
        return 0
    fi
    
    echo "Extracting ${(U)library} tarball..."
    
    if [ "$library" = "gmp" ]; then
        cd "$vendor_dir" && \
        if command -v lzip >/dev/null 2>&1; then
            tar --lzip -xf "$(basename "$tarball_path")"
        elif command -v plzip >/dev/null 2>&1; then
            tar --lzip -xf "$(basename "$tarball_path")"
        else
            echo -e "${RED}ERROR: lzip or plzip is required to extract .tar.lz files${NC}" >&2
            echo "Install with: brew install lzip (macOS) or apt-get install lzip (Linux)" >&2
            exit 1
        fi
    elif [ "$library" = "mpfr" ]; then
        cd "$vendor_dir" && \
        if command -v xz >/dev/null 2>&1; then
            tar -xJf "$(basename "$tarball_path")"
        elif command -v unxz >/dev/null 2>&1; then
            tar -xJf "$(basename "$tarball_path")"
        else
            echo -e "${RED}ERROR: xz or unxz is required to extract .tar.xz files${NC}" >&2
            echo "Install with: brew install xz (macOS) or apt-get install xz-utils (Linux)" >&2
            exit 1
        fi
    else
        echo -e "${RED}ERROR: Unknown library: $library${NC}" >&2
        exit 1
    fi
    
    echo "Extracted to: $extract_dir"
}

# Check platform (run tests) - internal function
check_platform() {
    local build_dir="$1"
    local platform_name="$2"
    
    if [ ! -f "$build_dir/Makefile" ]; then
        echo -e "${RED}ERROR: $platform_name build not found. Run 'make build-$platform_name' first.${NC}" >&2
        exit 1
    fi
    
    echo "Running test suite for $platform_name..."
    cd "$build_dir" && make check
}

# ============================================================================
# External Task Functions
# ============================================================================

# Task: build
task_build() {
    local library="${PARAMS["library"]:-}"
    local platform_name="${PARAMS["platform-name"]:-}"
    
    if [ -z "$library" ] || [ -z "$platform_name" ]; then
        echo -e "${RED}ERROR: --library and --platform-name are required for build task${NC}" >&2
        exit 1
    fi
    
    # Get environment variables with defaults
    local curdir="${CURDIR:-$(pwd)}"
    local vendor_dir="${VENDOR_DIR:-Sources/CKalliope/vendor}"
    local mpfr_vendor_dir="${MPFR_VENDOR_DIR:-Sources/CLinus/vendor}"
    local build_dir="${BUILD_DIR:-$vendor_dir/build}"
    local gmp_version="${GMP_VERSION:-6.3.0}"
    local mpfr_version="${MPFR_VERSION:-4.2.2}"
    
    # Parse platform config
    parse_platform_config "$platform_name"
    local sdk_name="$PLATFORM_SDK_NAME"
    local host_triple="$PLATFORM_HOST_TRIPLE"
    local arch="$PLATFORM_ARCH"
    local disable_assembly="$PLATFORM_DISABLE_ASSEMBLY"
    local platform_id="$PLATFORM_ID"
    local min_version="$PLATFORM_MIN_VERSION"
    
    # Validate SDK
    validate_sdk "$sdk_name" "$platform_name"
    
    local sdk_path
    sdk_path=$(xcrun --sdk "$sdk_name" --show-sdk-path 2>/dev/null)
    local sdk_version
    sdk_version=$(xcrun --sdk "$sdk_name" --show-sdk-version 2>/dev/null)
    
    # Expand CFLAGS
    local cflags
    cflags=$(expand_cflags "$platform_name" "$sdk_path" "$arch" "$min_version")
    
    # Determine paths
    local platform_build_dir
    local platform_install_dir
    local platform_install_prefix
    local source_dir
    
    if [ "$library" = "gmp" ]; then
        platform_build_dir="$curdir/$build_dir/$platform_name"
        platform_install_dir="$curdir/$vendor_dir/$platform_name"
        platform_install_prefix="$platform_install_dir"
        source_dir="$curdir/$vendor_dir/gmp-$gmp_version"
    elif [ "$library" = "mpfr" ]; then
        platform_build_dir="$curdir/$build_dir/mpfr-$platform_name"
        platform_install_dir="$curdir/$mpfr_vendor_dir/mpfr-$platform_name"
        platform_install_prefix="$platform_install_dir"
        source_dir="$curdir/$mpfr_vendor_dir/mpfr-$mpfr_version"
        
        # Validate GMP dependency
        local gmp_install_dir="$curdir/$vendor_dir/$platform_name"
        if [ ! -d "$gmp_install_dir" ] || [ ! -f "$gmp_install_dir/lib/libgmp.a" ]; then
            echo -e "${RED}ERROR: GMP must be built first for $platform_name. Run 'make build-$platform_name' first.${NC}" >&2
            exit 1
        fi
    else
        echo -e "${RED}ERROR: Unknown library: $library${NC}" >&2
        exit 1
    fi
    
    # Check for configure script
    if [ "$library" = "mpfr" ] && [ ! -f "$source_dir/configure" ]; then
        echo -e "${RED}ERROR: MPFR configure script not found at $source_dir/configure${NC}" >&2
        echo "       MPFR tarballs should include configure already. Check if extraction failed." >&2
        exit 1
    fi
    
    # Setup autotools for GMP
    if [ "$library" = "gmp" ]; then
        local autoconf_bin
        autoconf_bin=$(detect_autotools autoreconf)
        if [ -z "$autoconf_bin" ]; then
            echo -e "${RED}ERROR: autoreconf is required. Install with: brew install autoconf automake libtool${NC}" >&2
            exit 1
        fi
        
        local autoupdate_bin
        autoupdate_bin=$(detect_autotools autoupdate)
        if [ -z "$autoupdate_bin" ]; then
            echo -e "${RED}ERROR: autoupdate is required. Install with: brew install autoconf automake libtool${NC}" >&2
            exit 1
        fi
        
        echo "Using autoreconf: $autoconf_bin"
        echo "Using autoupdate: $autoupdate_bin"
        
        if [ ! -f "$source_dir/configure" ]; then
            echo "Step 1: Cleaning old autotools files..."
            cd "$source_dir" && rm -f configure aclocal.m4 autom4te.cache 2>/dev/null || true
            echo "Step 2: Regenerating build system with autoreconf -i -s..."
            cd "$source_dir" && "$autoconf_bin" -i -s
            echo "Step 3: Updating configure.ac with autoupdate..."
            cd "$source_dir" && "$autoupdate_bin" || true
            echo "Autotools setup complete."
        fi
    fi
    
    mkdir -p "$platform_build_dir"
    mkdir -p "$platform_install_dir"
    
    # Always run configure to ensure configuration is up-to-date with current parameters
    # Configure is idempotent, so this is safe and ensures we catch any parameter changes
    echo "Configuring ${(U)library} for $platform_name..."
        
    local assembly_flag=""
    if [ "$disable_assembly" = "1" ]; then
        assembly_flag="--disable-assembly"
        echo "  (Assembly disabled for $platform_name - required for iOS)"
    else
        echo "  (Assembly enabled for $platform_name - better performance)"
    fi
    
    # Build BUILD_TRIPLE
    local build_cpu
    build_cpu=$(uname -m)
    local build_cpu_gmp
    if [ "$build_cpu" = "arm64" ]; then
        build_cpu_gmp="aarch64"
    else
        build_cpu_gmp="$build_cpu"
    fi
    local build_darwin_version
    build_darwin_version=$(uname -r | cut -d. -f1)
    local build_triple="${build_cpu_gmp}-apple-darwin${build_darwin_version}"
    
    # Setup LDFLAGS with platform version
    local ldflags_with_platform=""
    if [ -n "$platform_id" ] && [ -n "$min_version" ] && [ -n "$sdk_version" ]; then
        ldflags_with_platform="-Wl,-platform_version,$platform_id,$min_version,$sdk_version"
    fi
    
    # Setup build tools
    local macos_sdk_path
    macos_sdk_path=$(xcrun --sdk macosx --show-sdk-path 2>/dev/null)
    local macos_clang
    macos_clang=$(xcrun --sdk macosx --find clang)
    local macos_clangxx
    macos_clangxx=$(xcrun --sdk macosx --find clang++)
    export CC_FOR_BUILD="$macos_clang -isysroot $macos_sdk_path"
    export CXX_FOR_BUILD="$macos_clangxx -isysroot $macos_sdk_path"
    export CFLAGS_FOR_BUILD="-isysroot $macos_sdk_path"
    
    # Find Xcode tools
    local xcode_ar xcode_ld xcode_as xcode_ranlib xcode_nm
    xcode_ar=$(find_xcode_tool ar)
    xcode_ld=$(find_xcode_tool ld)
    xcode_as=$(find_xcode_tool as)
    xcode_ranlib=$(find_xcode_tool ranlib)
    xcode_nm=$(find_xcode_tool nm)
    
    # Find CC and CXX for target platform
    local cc cxx
    cc=$(xcrun --sdk "$sdk_name" --find clang)
    cxx=$(xcrun --sdk "$sdk_name" --find clang++)
    
    # Configure
    cd "$platform_build_dir" && \
    CC="$cc" \
    CXX="$cxx" \
    CFLAGS="$cflags" \
    "$source_dir/configure" \
        --build="$build_triple" \
        --host="$host_triple" \
        --prefix="$platform_install_prefix" \
        --disable-cxx \
        --with-pic \
        --disable-shared \
        --enable-static \
        $assembly_flag \
        ABI=64 \
        AR="$xcode_ar" \
        LD="$xcode_ld" \
        AS="$xcode_as" \
        RANLIB="$xcode_ranlib" \
        NM="$xcode_nm" \
        CC_FOR_BUILD="$CC_FOR_BUILD" \
        CXX_FOR_BUILD="$CXX_FOR_BUILD" \
        CFLAGS_FOR_BUILD="$CFLAGS_FOR_BUILD" \
        LDFLAGS="$ldflags_with_platform" \
        $([ "$library" = "gmp" ] && echo "--enable-alloca=reentrant" || echo "") \
        $([ "$library" = "mpfr" ] && echo "--with-gmp=$gmp_install_dir --enable-thread-safe" || echo "")
    
    # Build
    local lib_file
    if [ "$library" = "gmp" ]; then
        lib_file="$platform_install_dir/lib/libgmp.a"
    else
        lib_file="$platform_install_dir/lib/libmpfr.a"
    fi
    
    if [ -f "$lib_file" ] && [ "$lib_file" -nt "$platform_build_dir/Makefile" ]; then
        echo "${(U)library} library already built for $platform_name (skipping build)"
    else
        echo "Building ${(U)library} for $platform_name..."
        cd "$platform_build_dir" && make -j$(sysctl -n hw.ncpu 2>/dev/null || echo 4) && make install
    fi
    
    # Run tests if appropriate
    if should_run_tests "$host_triple"; then
        local current_arch
        current_arch=$(uname -m)
        local current_os
        current_os=$(uname -s | tr '[:upper:]' '[:lower:]')
        echo "Running ${(U)library} test suite for $platform_name (this may take several minutes)..."
        echo "  (Build target matches current machine: $current_arch-$current_os)"
        cd "$platform_build_dir" && make check || {
            echo -e "${RED}ERROR: ${(U)library} tests failed for $platform_name${NC}" >&2
            exit 1
        }
        echo -e "${GREEN}✓ Tests passed for $platform_name${NC}"
    else
        echo "⚠ Skipping tests for $platform_name"
        local host_os
        host_os=$(echo "$host_triple" | cut -d'-' -f3-)
        case "$host_os" in
            ios|ios-simulator|tvos|tvos-simulator|watchos|watchos-simulator|xros|xros-simulator|maccatalyst)
                echo "  (iOS/tvOS/watchOS/visionOS/macCatalyst binaries cannot run on macOS)"
                ;;
            *)
                local current_arch current_os
                current_arch=$(uname -m)
                current_os=$(uname -s | tr '[:upper:]' '[:lower:]')
                echo "  (Build target $host_triple does not match current machine: $current_arch-$current_os)"
                echo "  (Tests can only run when build target matches the current machine)"
                ;;
        esac
    fi
    
    # Install
    echo "Installing ${(U)library} to $platform_install_dir..."
    cd "$platform_build_dir" && make install
    echo -e "${GREEN}✓ ${(U)library} built and installed for $platform_name at $platform_install_dir${NC}"
}

# Task: link-libs
task_link_libs() {
    local library="${PARAMS["library"]:-}"
    local platforms="${PARAMS["platforms"]:-}"
    
    if [ -z "$library" ] || [ -z "$platforms" ]; then
        echo -e "${RED}ERROR: --library and --platforms are required for link-libs task${NC}" >&2
        exit 1
    fi
    
    # Get environment variables with defaults
    local curdir="${CURDIR:-$(pwd)}"
    local vendor_dir="${VENDOR_DIR:-Sources/CKalliope/vendor}"
    local mpfr_vendor_dir="${MPFR_VENDOR_DIR:-Sources/CLinus/vendor}"
    
    # Use correct vendor directory based on library
    local vendor_base_dir
    if [ "$library" = "gmp" ]; then
        vendor_base_dir="$vendor_dir"
    else
        vendor_base_dir="$mpfr_vendor_dir"
    fi
    
    local build_dir="${BUILD_DIR:-$vendor_base_dir/build}"
    
    local libs_dir
    if [ "$library" = "gmp" ]; then
        libs_dir="$build_dir/gmp-libs"
    else
        libs_dir="$build_dir/mpfr-libs"
    fi
    
    local lib_name
    if [ "$library" = "gmp" ]; then
        lib_name="libgmp.a"
    else
        lib_name="libmpfr.a"
    fi
    
    echo "Creating ${(U)library} libraries and preparing headers..."
    
    # Process each platform (force word splitting in zsh)
    for platform in ${=platforms}; do
        if is_universal_platform "$platform"; then
            # Universal platform: create universal binary
            local arm64_platform x86_64_platform display_name
            arm64_platform=$(get_arm64_platform "$platform")
            x86_64_platform=$(get_x86_64_platform "$platform")
            display_name=$(get_display_name "$platform")
            
            local platform_libs_dir="$curdir/$libs_dir/$platform"
            local platform_headers_dir="$curdir/$libs_dir/$platform/include"
            
            mkdir -p "$platform_libs_dir/lib"
            mkdir -p "$platform_headers_dir"
            
            # Determine source paths
            local arm64_lib_path x86_64_lib_path
            local arm64_install_dir x86_64_install_dir
            
            if [ "$library" = "gmp" ]; then
                arm64_install_dir="$curdir/$vendor_dir/$arm64_platform"
                x86_64_install_dir="$curdir/$vendor_dir/$x86_64_platform"
            else
                arm64_install_dir="$curdir/$mpfr_vendor_dir/mpfr-$arm64_platform"
                x86_64_install_dir="$curdir/$mpfr_vendor_dir/mpfr-$x86_64_platform"
            fi
            
            arm64_lib_path="$arm64_install_dir/lib/$lib_name"
            x86_64_lib_path="$x86_64_install_dir/lib/$lib_name"
            
            # Create universal library
            create_universal_lib "$platform_libs_dir/lib" "$arm64_lib_path" "$x86_64_lib_path" "$lib_name" "$display_name"
            
            # Prepare headers (use arm64 install dir as source)
            if [ "$library" = "gmp" ]; then
                prepare_headers "$library" "$platform_headers_dir" "$arm64_install_dir" "" "$display_name"
            else
                local gmp_platform="$arm64_platform"
                local gmp_install_dir="$curdir/$vendor_dir/$gmp_platform"
                prepare_headers "$library" "$platform_headers_dir" "$arm64_install_dir" "$gmp_install_dir" "$display_name"
            fi
        else
            # Single-arch platform: copy library and prepare headers
            local platform_libs_dir="$curdir/$libs_dir/$platform"
            local platform_headers_dir="$curdir/$libs_dir/$platform/include"
            
            mkdir -p "$platform_libs_dir/lib"
            mkdir -p "$platform_headers_dir"
            
            # Determine source paths
            local source_install_dir
            if [ "$library" = "gmp" ]; then
                source_install_dir="$curdir/$vendor_dir/$platform"
            else
                source_install_dir="$curdir/$mpfr_vendor_dir/mpfr-$platform"
            fi
            
            local source_lib="$source_install_dir/lib/$lib_name"
            local dest_lib="$platform_libs_dir/lib/$lib_name"
            
            # Copy library
            if [ -f "$source_lib" ]; then
                if [ -f "$dest_lib" ] && [ "$dest_lib" -nt "$source_lib" ]; then
                    echo "${(U)library} library for $platform already copied (skipping)"
                else
                    cp "$source_lib" "$dest_lib"
                    echo "Copied $lib_name for $platform"
                fi
            else
                echo -e "${RED}ERROR: Library not found at $source_lib${NC}" >&2
                exit 1
            fi
            
            # Prepare headers
            local display_name
            display_name=$(get_display_name "$platform")
            if [ "$library" = "gmp" ]; then
                prepare_headers "$library" "$platform_headers_dir" "$source_install_dir" "" "$display_name"
            else
                local gmp_install_dir="$curdir/$vendor_dir/$platform"
                prepare_headers "$library" "$platform_headers_dir" "$source_install_dir" "$gmp_install_dir" "$display_name"
            fi
        fi
    done
    
    echo ""
    echo -e "${GREEN}✓ All ${(U)library} libraries and headers prepared successfully!${NC}"
}

# Task: create-xcframework
task_create_xcframework() {
    local library="${PARAMS["library"]:-}"
    local xcframework_dir="${PARAMS["xcframework-dir"]:-}"
    local platforms="${PARAMS["platforms"]:-}"
    
    if [ -z "$library" ] || [ -z "$xcframework_dir" ] || [ -z "$platforms" ]; then
        echo -e "${RED}ERROR: --library, --xcframework-dir, and --platforms are required for create-xcframework task${NC}" >&2
        exit 1
    fi
    
    # Get environment variables with defaults
    local curdir="${CURDIR:-$(pwd)}"
    local vendor_dir="${VENDOR_DIR:-Sources/CKalliope/vendor}"
    local mpfr_vendor_dir="${MPFR_VENDOR_DIR:-Sources/CLinus/vendor}"
    
    # Use correct vendor directory based on library
    local vendor_base_dir
    if [ "$library" = "gmp" ]; then
        vendor_base_dir="$vendor_dir"
    else
        vendor_base_dir="$mpfr_vendor_dir"
    fi
    
    local build_dir="${BUILD_DIR:-$vendor_base_dir/build}"
    
    local libs_dir
    if [ "$library" = "gmp" ]; then
        libs_dir="$build_dir/gmp-libs"
    else
        libs_dir="$build_dir/mpfr-libs"
    fi
    
    local lib_name
    if [ "$library" = "gmp" ]; then
        lib_name="libgmp.a"
    else
        lib_name="libmpfr.a"
    fi
    
    # Determine framework name
    local framework_name
    if [ "$library" = "gmp" ]; then
        framework_name="CKalliope"
    else
        framework_name="CLinus"
    fi
    
    # Create temporary directory for frameworks
    local frameworks_dir="$build_dir/frameworks"
    rm -rf "$frameworks_dir"
    mkdir -p "$frameworks_dir"
    
    echo "Creating ${(U)library} frameworks for xcframework..."
    echo ""
    
    # Step 1: Create frameworks for each platform
    local framework_paths=()
    
    for platform in ${=platforms}; do
        local platform_lib="$curdir/$libs_dir/$platform/lib/$lib_name"
        local platform_headers="$curdir/$libs_dir/$platform/include"
        local platform_modules="$curdir/$libs_dir/$platform/Modules"
        
        if [ ! -f "$platform_lib" ]; then
            echo -e "${RED}ERROR: Library not found at $platform_lib${NC}" >&2
            exit 1
        fi
        
        if [ ! -d "$platform_headers" ]; then
            echo -e "${RED}ERROR: Headers directory not found at $platform_headers${NC}" >&2
            exit 1
        fi
        
        if [ ! -d "$platform_modules" ] || [ ! -f "$platform_modules/module.modulemap" ]; then
            echo -e "${RED}ERROR: Modules directory or module.modulemap not found at $platform_modules${NC}" >&2
            exit 1
        fi
        
        if is_universal_platform "$platform"; then
            # Universal platform: create arm64 and x86_64 frameworks, then combine
            local arm64_platform x86_64_platform display_name
            arm64_platform=$(get_arm64_platform "$platform")
            x86_64_platform=$(get_x86_64_platform "$platform")
            display_name=$(get_display_name "$platform")
            
            # Get min version from platform config
            parse_platform_config "$arm64_platform"
            local min_version="$PLATFORM_MIN_VERSION"
            
            # Get libraries from vendor directory (individual arch builds)
            local arm64_lib x86_64_lib
            if [ "$library" = "gmp" ]; then
                arm64_lib="$curdir/$vendor_dir/$arm64_platform/lib/$lib_name"
                x86_64_lib="$curdir/$vendor_dir/$x86_64_platform/lib/$lib_name"
            else
                arm64_lib="$curdir/$mpfr_vendor_dir/mpfr-$arm64_platform/lib/$lib_name"
                x86_64_lib="$curdir/$mpfr_vendor_dir/mpfr-$x86_64_platform/lib/$lib_name"
            fi
            
            # Use headers and modules from the universal platform (already prepared by link-libs)
            local arm64_headers="$curdir/$libs_dir/$platform/include"
            local arm64_modules="$curdir/$libs_dir/$platform/Modules"
            local x86_64_headers="$arm64_headers"  # Same headers for both archs
            local x86_64_modules="$arm64_modules"   # Same modules for both archs
            
            local arm64_framework_dir="$frameworks_dir/$arm64_platform"
            local x86_64_framework_dir="$frameworks_dir/$x86_64_platform"
            
            if [ ! -f "$arm64_lib" ]; then
                echo -e "${RED}ERROR: ARM64 library not found at $arm64_lib${NC}" >&2
                exit 1
            fi
            
            if [ ! -f "$x86_64_lib" ]; then
                echo -e "${RED}ERROR: x86_64 library not found at $x86_64_lib${NC}" >&2
                exit 1
            fi
            
            if [ ! -d "$arm64_headers" ] || [ ! -d "$arm64_modules" ]; then
                echo -e "${RED}ERROR: Headers or Modules not found for $platform${NC}" >&2
                exit 1
            fi
            
            # Create arm64 framework
            create_framework "$arm64_framework_dir" "$arm64_lib" "$arm64_headers" "$arm64_modules" "$framework_name" "$min_version"
            
            # Create x86_64 framework
            create_framework "$x86_64_framework_dir" "$x86_64_lib" "$x86_64_headers" "$x86_64_modules" "$framework_name" "$min_version"
            
            # Create universal framework
            local universal_framework_dir="$frameworks_dir/$platform"
            create_universal_framework "$universal_framework_dir" "$arm64_framework_dir" "$x86_64_framework_dir" "$display_name" "$framework_name"
            
            framework_paths+=("$universal_framework_dir/$framework_name.framework")
        else
            # Single-arch platform: create framework directly
            # Get min version from platform config
            parse_platform_config "$platform"
            local min_version="$PLATFORM_MIN_VERSION"
            
            local platform_framework_dir="$frameworks_dir/$platform"
            create_framework "$platform_framework_dir" "$platform_lib" "$platform_headers" "$platform_modules" "$framework_name" "$min_version"
            
            framework_paths+=("$platform_framework_dir/$framework_name.framework")
        fi
    done
    
    # Step 2: Create xcframework using xcodebuild
    echo ""
    echo "Creating xcframework using xcodebuild..."
    
    # Convert xcframework_dir to absolute path
    # Handle case where path starts with /Sources (from empty CURDIR in Makefile)
    if [[ "$xcframework_dir" == /Sources/* ]]; then
        # This is likely from $(CURDIR)/Sources/... where CURDIR was empty
        # Convert to relative path from current directory
        xcframework_dir="${xcframework_dir#/}"  # Remove leading /
        xcframework_dir="$curdir/$xcframework_dir"
    elif [[ "$xcframework_dir" != /* ]]; then
        # Relative path - make it absolute relative to curdir
        xcframework_dir="$curdir/$xcframework_dir"
    fi
    # If it's already an absolute path (and not /Sources/*), use it as-is
    
    rm -rf "$xcframework_dir"
    mkdir -p "$(dirname "$xcframework_dir")"
    
    local xcodebuild_cmd="xcodebuild -create-xcframework"
    for framework_path in "${framework_paths[@]}"; do
        xcodebuild_cmd="$xcodebuild_cmd -framework \"$framework_path\""
    done
    xcodebuild_cmd="$xcodebuild_cmd -output \"$xcframework_dir\""
    
    eval "$xcodebuild_cmd" || {
        echo -e "${RED}ERROR: Failed to create ${(U)library} xcframework${NC}" >&2
        exit 1
    }
    
    echo ""
    echo -e "${GREEN}✓ XCFramework created at $xcframework_dir${NC}"
    echo ""
    echo "Verifying xcframework structure..."
    if [ -f "$xcframework_dir/Info.plist" ]; then
        echo "✓ XCFramework Info.plist found"
        plutil -p "$xcframework_dir/Info.plist" 2>/dev/null | head -10 || true
    else
        echo "⚠ Warning: Info.plist not found"
    fi
    
    # Verify framework structure in xcframework
    echo ""
    echo "Verifying framework structure..."
    local frameworks_found=0
    for platform_dir in "$xcframework_dir"/*/; do
        if [ -d "$platform_dir" ] && [ -d "$platform_dir/$framework_name.framework" ]; then
            local framework="$platform_dir/$framework_name.framework"
            if [ -d "$framework/Modules" ] && [ -f "$framework/Modules/module.modulemap" ]; then
                echo "✓ Found framework with Modules in $(basename "$platform_dir")"
                frameworks_found=$((frameworks_found + 1))
            else
                echo -e "${YELLOW}⚠ Warning: Framework in $(basename "$platform_dir") missing Modules${NC}"
            fi
        fi
    done
    if [ $frameworks_found -gt 0 ]; then
        echo -e "${GREEN}✓ Frameworks verified ($frameworks_found platform slices)${NC}"
    else
        echo -e "${YELLOW}⚠ Warning: No frameworks found in xcframework${NC}"
    fi
    
    # Step 3: Copy headers to common location for bridge code
    # Headers are the same across platforms, so we copy from macos-arm64_x86_64
    # This allows bridge code to include headers without platform-specific paths
    if [ "$library" = "mpfr" ]; then
        echo ""
        echo "Copying MPFR headers to common location for CLinusBridge..."
        local common_headers_dir="$curdir/Sources/CLinus/extra/headers"
        mkdir -p "$common_headers_dir"
        
        # Try to find headers from macos-arm64_x86_64 first, fallback to any platform
        local source_headers_dir=""
        if [ -d "$xcframework_dir/macos-arm64_x86_64/$framework_name.framework/Headers" ]; then
            source_headers_dir="$xcframework_dir/macos-arm64_x86_64/$framework_name.framework/Headers"
        else
            # Fallback to first available platform
            for platform_dir in "$xcframework_dir"/*/; do
                if [ -d "$platform_dir/$framework_name.framework/Headers" ]; then
                    source_headers_dir="$platform_dir/$framework_name.framework/Headers"
                    break
                fi
            done
        fi
        
        if [ -n "$source_headers_dir" ] && [ -d "$source_headers_dir" ]; then
            cp "$source_headers_dir"/*.h "$common_headers_dir/" 2>/dev/null || true
            if [ -f "$common_headers_dir/mpfr.h" ] && [ -f "$common_headers_dir/gmp.h" ]; then
                echo -e "${GREEN}✓ Headers copied to $common_headers_dir${NC}"
            else
                echo -e "${YELLOW}⚠ Warning: Some headers may be missing in $common_headers_dir${NC}"
            fi
        else
            echo -e "${YELLOW}⚠ Warning: Could not find headers to copy${NC}"
        fi
    elif [ "$library" = "gmp" ]; then
        echo ""
        echo "Copying GMP headers to common location for CKalliopeBridge..."
        local common_headers_dir="$curdir/Sources/CKalliope/extra/headers"
        mkdir -p "$common_headers_dir"
        
        # Try to find headers from macos-arm64_x86_64 first, fallback to any platform
        local source_headers_dir=""
        if [ -d "$xcframework_dir/macos-arm64_x86_64/$framework_name.framework/Headers" ]; then
            source_headers_dir="$xcframework_dir/macos-arm64_x86_64/$framework_name.framework/Headers"
        else
            # Fallback to first available platform
            for platform_dir in "$xcframework_dir"/*/; do
                if [ -d "$platform_dir/$framework_name.framework/Headers" ]; then
                    source_headers_dir="$platform_dir/$framework_name.framework/Headers"
                    break
                fi
            done
        fi
        
        if [ -n "$source_headers_dir" ] && [ -d "$source_headers_dir" ]; then
            cp "$source_headers_dir"/*.h "$common_headers_dir/" 2>/dev/null || true
            if [ -f "$common_headers_dir/gmp.h" ]; then
                echo -e "${GREEN}✓ Headers copied to $common_headers_dir${NC}"
            else
                echo -e "${YELLOW}⚠ Warning: gmp.h not found in $common_headers_dir${NC}"
            fi
        else
            echo -e "${YELLOW}⚠ Warning: Could not find headers to copy${NC}"
        fi
    fi
    
    # Clean up temporary frameworks directory
    rm -rf "$frameworks_dir"
    
    echo ""
    echo -e "${GREEN}✓ XCFramework creation completed successfully!${NC}"
}

# Task: download
task_download() {
    local library="${PARAMS["library"]:-}"
    
    if [ -z "$library" ]; then
        echo -e "${RED}ERROR: --library is required for download task${NC}" >&2
        exit 1
    fi
    
    # Get environment variables with defaults
    local curdir="${CURDIR:-$(pwd)}"
    local vendor_dir="${VENDOR_DIR:-Sources/CKalliope/vendor}"
    local mpfr_vendor_dir="${MPFR_VENDOR_DIR:-Sources/CLinus/vendor}"
    local gmp_version="${GMP_VERSION:-6.3.0}"
    local mpfr_version="${MPFR_VERSION:-4.2.2}"
    
    local vendor_target_dir
    local tarball_name
    local base_url
    local extract_dir
    
    if [ "$library" = "gmp" ]; then
        vendor_target_dir="$vendor_dir"
        tarball_name="gmp-$gmp_version.tar.lz"
        base_url="https://gmplib.org/download/gmp"
        extract_dir="$vendor_dir/gmp-$gmp_version"
    elif [ "$library" = "mpfr" ]; then
        vendor_target_dir="$mpfr_vendor_dir"
        tarball_name="mpfr-$mpfr_version.tar.xz"
        base_url="https://www.mpfr.org/mpfr-current"
        extract_dir="$mpfr_vendor_dir/mpfr-$mpfr_version"
    else
        echo -e "${RED}ERROR: Unknown library: $library${NC}" >&2
        exit 1
    fi
    
    local tarball_path="$vendor_target_dir/$tarball_name"
    
    # Create vendor directory
    mkdir -p "$vendor_target_dir"
    
    # Download if not exists
    if [ ! -f "$tarball_path" ]; then
        echo "Downloading ${(U)library} $([ "$library" = "gmp" ] && echo "$gmp_version" || echo "$mpfr_version")..."
        curl -L "$base_url/$tarball_name" -o "$tarball_path"
        echo "Downloaded: $tarball_path"
    else
        echo "${(U)library} tarball already exists: $tarball_path"
    fi
    
    # Extract automatically
    extract_library "$library" "$vendor_target_dir" "$tarball_path" "$extract_dir"
}

# Task: docs
task_docs() {
    local library="${PARAMS["library"]:-}"
    
    if [ -z "$library" ]; then
        echo -e "${RED}ERROR: --library is required for docs task${NC}" >&2
        exit 1
    fi
    
    # Get environment variables with defaults
    local curdir="${CURDIR:-$(pwd)}"
    local vendor_dir="${VENDOR_DIR:-Sources/CKalliope/vendor}"
    local mpfr_vendor_dir="${MPFR_VENDOR_DIR:-Sources/CLinus/vendor}"
    local gmp_version="${GMP_VERSION:-6.3.0}"
    local mpfr_version="${MPFR_VERSION:-4.2.2}"
    local docs_dir="${DOCS_DIR:-docs}"
    
    case "$library" in
        gmp)
            echo "Building GMP HTML documentation..."
            if ! command -v makeinfo >/dev/null 2>&1; then
                echo -e "${RED}ERROR: makeinfo is required to build GMP documentation${NC}" >&2
                echo "Install with: brew install texinfo (macOS) or apt-get install texinfo (Linux)" >&2
                exit 1
            fi
            
            local gmp_dir="$vendor_dir/gmp-$gmp_version"
            local gmp_docs_dir="${GMP_DOCS_DIR:-$vendor_dir/gmp-docs}"
            
            echo "Generating HTML documentation using makeinfo..."
            mkdir -p "$curdir/$gmp_docs_dir"
            local doc_output_dir="$curdir/$gmp_docs_dir"
            
            cd "$gmp_dir/doc" && \
            echo "  Running: makeinfo --html --no-split -o gmp.html gmp.texi"
            makeinfo --html --no-split -o gmp.html gmp.texi || {
                echo -e "${RED}ERROR: Failed to generate HTML documentation${NC}" >&2
                echo "   Make sure texinfo is installed: brew install texinfo" >&2
                exit 1
            }
            
            if [ -f "gmp.html" ]; then
                cp gmp.html "$doc_output_dir/"
                echo -e "${GREEN}✓ GMP HTML documentation generated: $doc_output_dir/gmp.html${NC}"
            else
                echo -e "${RED}⚠️  ERROR: HTML documentation not found after build${NC}" >&2
                echo "   Check $gmp_dir/doc/ for generated files" >&2
                exit 1
            fi
            
            echo ""
            echo -e "${GREEN}✓ GMP HTML documentation build complete!${NC}"
            echo "   Location: $curdir/$gmp_docs_dir/"
            ;;
            
        mpfr)
            echo "Building MPFR HTML documentation..."
            echo "  (Using makeinfo directly, as per MPFR INSTALL instructions)"
            if ! command -v makeinfo >/dev/null 2>&1; then
                echo -e "${RED}ERROR: makeinfo is required to build MPFR documentation${NC}" >&2
                echo "Install with: brew install texinfo (macOS) or apt-get install texinfo (Linux)" >&2
                exit 1
            fi
            
            local mpfr_dir="$mpfr_vendor_dir/mpfr-$mpfr_version"
            local mpfr_docs_dir="${MPFR_DOCS_DIR:-$mpfr_vendor_dir/mpfr-docs}"
            
            echo "Generating HTML documentation using makeinfo..."
            mkdir -p "$curdir/$mpfr_docs_dir"
            local doc_output_dir="$curdir/$mpfr_docs_dir"
            
            cd "$mpfr_dir/doc" && \
            echo "  Running: makeinfo --html --no-split -o mpfr.html mpfr.texi"
            makeinfo --html --no-split -o mpfr.html mpfr.texi || {
                echo -e "${RED}ERROR: Failed to generate HTML documentation${NC}" >&2
                echo "   Make sure texinfo is installed: brew install texinfo" >&2
                exit 1
            }
            
            if [ -f "mpfr.html" ]; then
                cp mpfr.html "$doc_output_dir/"
                echo -e "${GREEN}✓ MPFR HTML documentation generated: $doc_output_dir/mpfr.html${NC}"
            else
                echo -e "${RED}⚠️  ERROR: HTML documentation not found after build${NC}" >&2
                echo "   Check $mpfr_dir/doc/ for generated files" >&2
                exit 1
            fi
            
            if [ -f "FAQ.html" ]; then
                cp FAQ.html "$doc_output_dir/" 2>/dev/null || true
                echo "  Also copied FAQ.html"
            fi
            
            echo ""
            echo -e "${GREEN}✓ MPFR HTML documentation build complete!${NC}"
            echo "   Location: $curdir/$mpfr_docs_dir/"
            echo ""
            echo "To view the documentation:"
            if [ -f "$curdir/$mpfr_docs_dir/mpfr.html" ]; then
                echo "  open $curdir/$mpfr_docs_dir/mpfr.html"
            fi
            ;;
            
        Kalliope)
            echo "Generating Swift documentation for all targets (using binary target workaround)..."
            if ! command -v swift >/dev/null 2>&1; then
                echo -e "${RED}❌ ERROR: Swift is not installed or not in PATH${NC}" >&2
                exit 1
            fi
            if ! command -v xcrun >/dev/null 2>&1; then
                echo -e "${RED}❌ ERROR: xcrun is not available (Xcode required)${NC}" >&2
                exit 1
            fi
            
            echo "Resolving package dependencies..."
            swift package resolve || {
                echo -e "${RED}❌ ERROR: Failed to resolve package dependencies${NC}" >&2
                exit 1
            }
            
            echo "Building package with symbol graph generation for all targets..."
            local symbol_graph_dir=".build/symbol-graph"
            mkdir -p "$symbol_graph_dir"
            
            # Build symbol graphs for Kalliope target
            echo "  Building symbol graphs for Kalliope target..."
            swift build --target Kalliope \
                -Xswiftc -emit-symbol-graph \
                -Xswiftc -emit-symbol-graph-dir \
                -Xswiftc "$symbol_graph_dir" || {
                echo -e "${RED}❌ ERROR: Failed to build Kalliope target with symbol graphs${NC}" >&2
                exit 1
            }
            
            # Build symbol graphs for Linus target
            echo "  Building symbol graphs for Linus target..."
            swift build --target Linus \
                -Xswiftc -emit-symbol-graph \
                -Xswiftc -emit-symbol-graph-dir \
                -Xswiftc "$symbol_graph_dir" || {
                echo -e "${RED}❌ ERROR: Failed to build Linus target with symbol graphs${NC}" >&2
                exit 1
            }
            
            echo "Verifying symbol graphs were generated..."
            if [ ! -d "$symbol_graph_dir" ] || [ -z "$(ls -A "$symbol_graph_dir" 2>/dev/null)" ]; then
                echo -e "${RED}❌ ERROR: No symbol graphs generated${NC}" >&2
                exit 1
            fi
            
            echo -e "${GREEN}✓ Symbol graphs generated in $symbol_graph_dir${NC}"
            local symbol_count
            symbol_count=$(find "$symbol_graph_dir" -name "*.symbols.json" | wc -l | tr -d ' ')
            echo "  Found $symbol_count symbol graph file(s)"
            echo ""
            echo "Generating HTML documentation with DocC..."
            
            local docs_bundle="$docs_dir/Kalliope.docc"
            if [ ! -d "$docs_bundle" ]; then
                echo "⚠️  WARNING: DocC bundle not found at $docs_bundle"
                echo "   Creating minimal bundle..."
                mkdir -p "$docs_bundle"
                cat > "$docs_bundle/Info.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict><key>CFBundleIdentifier</key><string>com.kalliope.docs</string></dict></plist>
EOF
            fi
            
            if command -v xcrun >/dev/null 2>&1 && xcrun docc convert --help >/dev/null 2>&1; then
                echo "Converting DocC bundle to HTML..."
                # Use a temp directory outside docs/ to avoid conflicts
                local temp_output_dir
                temp_output_dir=$(mktemp -d)
                mkdir -p "$temp_output_dir"
                if xcrun docc convert "$docs_bundle" \
                    --output-path "$temp_output_dir" \
                    --additional-symbol-graph-dir "$symbol_graph_dir" \
                    --transform-for-static-hosting \
                    --hosting-base-path /Kalliope >/dev/null 2>&1; then
                    if [ -d "$temp_output_dir/data/documentation" ]; then
                        echo -e "${GREEN}✓ HTML documentation generated, moving to docs/...${NC}"
                        # Backup Kalliope.docc if it exists
                        local docs_bundle_backup=""
                        if [ -d "$docs_dir/Kalliope.docc" ]; then
                            docs_bundle_backup=$(mktemp -d)
                            mv "$docs_dir/Kalliope.docc" "$docs_bundle_backup/"
                        fi
                        # Remove all existing files in docs_dir except hidden files
                        # This ensures we don't have nested html/ subdirectory
                        for item in "$docs_dir"/*; do
                            [ -e "$item" ] || continue
                            rm -rf "$item" 2>/dev/null || true
                        done
                        # Move all contents from temp directory to docs/ root
                        if [ -d "$temp_output_dir" ]; then
                            # Move each item individually to avoid issues
                            for item in "$temp_output_dir"/*; do
                                [ -e "$item" ] || continue
                                mv "$item" "$docs_dir/" 2>/dev/null || true
                            done
                            # Clean up the temp directory
                            rm -rf "$temp_output_dir" 2>/dev/null || true
                        fi
                        # Restore Kalliope.docc
                        if [ -n "$docs_bundle_backup" ] && [ -d "$docs_bundle_backup/Kalliope.docc" ]; then
                            mv "$docs_bundle_backup/Kalliope.docc" "$docs_dir/"
                            rmdir "$docs_bundle_backup" 2>/dev/null || true
                        fi
                        if [ -d "$docs_dir/data/documentation" ]; then
                            echo -e "${GREEN}✓ HTML documentation moved to $docs_dir/${NC}"
                        fi
                    else
                        echo "⚠️  Documentation structure created but may be incomplete"
                    fi
                else
                    echo "⚠️  DocC conversion had issues. Check DocC output above."
                    echo "   Symbol graphs are still available in $symbol_graph_dir"
                    # Clean up temp directory if conversion failed
                    rm -rf "$temp_output_dir" 2>/dev/null || true
                fi
            else
                echo "⚠️  DocC not available (xcrun docc). Symbol graphs generated but HTML docs not created."
                echo "   Install Xcode to generate full HTML documentation."
            fi
            
            echo ""
            echo -e "${GREEN}✓ Documentation generation complete!${NC}"
            echo ""
            echo "Symbol graphs: .build/symbol-graph/"
            if [ -d "$docs_dir/data/documentation" ]; then
                echo "HTML documentation: $docs_dir/"
                echo ""
                echo "To view locally:"
                echo "  open $docs_dir/index.html"
                echo ""
                echo "To publish on GitHub Pages:"
                echo "  1. The HTML docs are in $docs_dir/"
                echo "  2. Configure GitHub Pages to serve from the 'docs' directory"
            else
                echo "HTML documentation: Not generated (DocC may not be available)"
            fi
            echo ""
            echo "For SwiftPackageIndex:"
            echo "  SwiftPackageIndex can automatically use the symbol graphs from your repository."
            echo "  The symbol graphs in .build/symbol-graph/ contain all API documentation."
            ;;
            
        *)
            echo -e "${RED}ERROR: Unknown library for docs: $library${NC}" >&2
            echo "Supported libraries: gmp, mpfr, Kalliope" >&2
            echo "Note: 'Kalliope' generates docs for both Kalliope and Linus targets" >&2
            exit 1
            ;;
    esac
}

# Task: clean
task_clean() {
    local what="${PARAMS["what"]:-all}"
    
    # Get environment variables with defaults
    local curdir="${CURDIR:-$(pwd)}"
    local vendor_dir="${VENDOR_DIR:-Sources/CKalliope/vendor}"
    local mpfr_vendor_dir="${MPFR_VENDOR_DIR:-Sources/CLinus/vendor}"
    local build_dir="${BUILD_DIR:-$vendor_dir/build}"
    local docs_dir="${DOCS_DIR:-docs}"
    local xcframework_dir="${XCFRAMEWORK_DIR:-Sources/CKalliope/extra/CKalliope.xcframework}"
    local clinus_xcframework_dir="${CLINUS_XCFRAMEWORK_DIR:-Sources/CLinus/extra/CLinus.xcframework}"
    
    case "$what" in
        all)
            echo "Cleaning up (removing all downloaded and built files)..."
            if [ -d "$vendor_dir" ]; then
                rm -rf "$vendor_dir"
                echo "  Removed $vendor_dir"
            fi
            if [ -d "$mpfr_vendor_dir" ]; then
                rm -rf "$mpfr_vendor_dir"
                echo "  Removed $mpfr_vendor_dir"
            fi
            if [ -d "$curdir/Sources/CKalliope/extra" ]; then
                rm -rf "$curdir/Sources/CKalliope/extra"
                echo "  Removed Sources/CKalliope/extra"
            fi
            if [ -d "$curdir/Sources/CLinus/extra" ]; then
                rm -rf "$curdir/Sources/CLinus/extra"
                echo "  Removed Sources/CLinus/extra"
            fi
            echo -e "${GREEN}✓ Clean complete${NC}"
            ;;
            
        build)
            echo "Cleaning build artifacts..."
            if [ -d "$build_dir" ]; then
                rm -rf "$build_dir"
                echo "  Removed $build_dir"
            fi
            
            # Remove platform install directories
            local platforms=""
            for platform in ${(k)PLATFORM_CONFIGS}; do
                platforms="$platforms $platform"
            done
            for platform in ${=platforms}; do
                local install_dir="$vendor_dir/$platform"
                if [ -d "$install_dir" ]; then
                    rm -rf "$install_dir"
                    echo "  Removed $install_dir"
                fi
                local mpfr_install_dir="$mpfr_vendor_dir/mpfr-$platform"
                if [ -d "$mpfr_install_dir" ]; then
                    rm -rf "$mpfr_install_dir"
                    echo "  Removed $mpfr_install_dir"
                fi
            done
            
            if [ -d "$curdir/Sources/CKalliope/extra" ]; then
                rm -rf "$curdir/Sources/CKalliope/extra"
                echo "  Removed Sources/CKalliope/extra"
            fi
            if [ -d "$clinus_xcframework_dir" ]; then
                rm -rf "$clinus_xcframework_dir"
                echo "  Removed $clinus_xcframework_dir"
            fi
            echo -e "${GREEN}✓ Build artifacts cleaned${NC}"
            ;;
            
        docs)
            echo "Cleaning generated documentation..."
            if [ -d "$docs_dir/Kalliope.docc" ]; then
                echo "Preserving Kalliope.docc bundle..."
                local temp_dir
                temp_dir=$(mktemp -d)
                mv "$docs_dir/Kalliope.docc" "$temp_dir/" 2>/dev/null || true
                rm -rf "$docs_dir"
                mkdir -p "$docs_dir"
                mv "$temp_dir/Kalliope.docc" "$docs_dir/" 2>/dev/null || true
                rmdir "$temp_dir" 2>/dev/null || true
                echo -e "${GREEN}✓ Documentation cleaned (Kalliope.docc bundle preserved)${NC}"
            else
                rm -rf "$docs_dir"
                echo -e "${GREEN}✓ Documentation cleaned${NC}"
            fi
            if [ -d "$curdir/.build/documentation" ]; then
                rm -rf "$curdir/.build/documentation"
                echo "  Removed .build/documentation"
            fi
            ;;
            
        *)
            echo -e "${RED}ERROR: Unknown clean target: $what${NC}" >&2
            echo "Supported targets: all, build, docs" >&2
            exit 1
            ;;
    esac
}

# ============================================================================
# Argument Parsing and Task Dispatcher
# ============================================================================

# Only run dispatcher if script is executed directly (not sourced)
if [[ -n "${funcfiletrace[1]:-}" ]] && [[ "$0" != *"build.sh"* ]]; then
    return 0 2>/dev/null || true
fi

{
    TASK=""
    typeset -A PARAMS

    # Parse arguments
    while [ $# -gt 0 ]; do
        case $1 in
            --task=*)
                TASK="${1#*=}"
                shift
                ;;
            --task)
                TASK="$2"
                shift 2
                ;;
            --*)
                key="${1#--}"
                # Handle --key=value format first
                if [[ "$key" == *"="* ]]; then
                    PARAMS["${key%%=*}"]="${key#*=}"
                    shift
                elif [[ -n "${2:-}" ]] && [[ "${2:-}" != --* ]]; then
                    # Handle --key value format
                    PARAMS["$key"]="$2"
                    shift 2
                else
                    # Flag without value
                    PARAMS["$key"]=""
                    shift
                fi
                ;;
            *)
                echo -e "${RED}Unknown parameter: $1${NC}" >&2
                exit 1
                ;;
        esac
    done


    # Task dispatcher
    case "$TASK" in
        build)
            task_build
            ;;
        link-libs)
            task_link_libs
            ;;
        create-xcframework)
            task_create_xcframework
            ;;
        download)
            task_download
            ;;
        docs)
            task_docs
            ;;
        clean)
            task_clean
            ;;
        *)
            if [ -z "$TASK" ]; then
                echo -e "${RED}ERROR: --task is required${NC}" >&2
            else
                echo -e "${RED}Unknown task: $TASK${NC}" >&2
            fi
            echo "Available tasks: build, link-libs, create-xcframework, download, docs, clean" >&2
            exit 1
            ;;
    esac
}

