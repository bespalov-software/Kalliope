# ============================================================================
# GMP and MPFR Library Build Makefile (Data-Driven Refactored Version)
# ============================================================================
# This Makefile uses a data-driven approach to eliminate repetition.
# All platforms are defined in a single data structure, and targets are
# generated programmatically.

# ============================================================================
# Library Configuration
# ============================================================================

GMP_VERSION := 6.3.0
GMP_TARBALL := gmp-$(GMP_VERSION).tar.lz
VENDOR_DIR := Sources/CKalliope/vendor

MPFR_VERSION := 4.2.2
MPFR_TARBALL := mpfr-$(MPFR_VERSION).tar.xz
MPFR_VENDOR_DIR := Sources/CLinus/vendor

XCFRAMEWORK_DIR := $(CURDIR)/Sources/CKalliope/extra/CKalliope.xcframework
CLINUS_XCFRAMEWORK_DIR := $(CURDIR)/Sources/CLinus/extra/CLinus.xcframework

# ============================================================================
# Platform Configuration
# ============================================================================
# Note: Platform configurations are defined in scripts/build.sh
# The Makefile only needs the platform list for generating targets

PLATFORMS := ios-arm64 ios-simulator-arm64 ios-simulator-x86_64 \
             tvos-arm64 tvos-simulator-arm64 tvos-simulator-x86_64 \
             watchos-arm64 watchos-simulator-arm64 watchos-simulator-x86_64 \
             visionos-arm64 visionos-simulator-arm64 visionos-simulator-x86_64 \
             maccatalyst-arm64 maccatalyst-x86_64 \
             macos-arm64 macos-x86_64

# Note: All build logic has been moved to scripts/build.sh

# ============================================================================
# Generate Build Targets Programmatically
# ============================================================================

# Generate GMP build target for a platform
define generate-gmp-build-target
build-$(1): $(VENDOR_DIR)/$(GMP_TARBALL)
	@scripts/build.sh --task=build --library=gmp --platform-name=$(1)
endef

# Generate MPFR build target for a platform
define generate-mpfr-build-target
$$(MPFR_VENDOR_DIR)/mpfr-$(1)/lib/libmpfr.a: $(MPFR_VENDOR_DIR)/$(MPFR_TARBALL) build-$(1)
	@scripts/build.sh --task=build --library=mpfr --platform-name=$(1)
build-mpfr-$(1): $$(MPFR_VENDOR_DIR)/mpfr-$(1)/lib/libmpfr.a
endef

# Generate all build targets
$(foreach p,$(PLATFORMS),$(eval $(call generate-gmp-build-target,$(p))))
$(foreach p,$(PLATFORMS),$(eval $(call generate-mpfr-build-target,$(p))))

# ============================================================================
# Aggregate Build Targets
# ============================================================================

build-ios-simulator: build-ios-simulator-arm64 build-ios-simulator-x86_64
build-tvos-simulator: build-tvos-simulator-arm64 build-tvos-simulator-x86_64
build-watchos-simulator: build-watchos-simulator-arm64 build-watchos-simulator-x86_64
build-visionos-simulator: build-visionos-simulator-arm64 build-visionos-simulator-x86_64
build-maccatalyst: build-maccatalyst-arm64 build-maccatalyst-x86_64

build-all: build-ios-arm64 build-ios-simulator build-tvos-arm64 build-tvos-simulator build-watchos-arm64 build-watchos-simulator build-visionos-arm64 build-visionos-simulator build-maccatalyst build-macos-arm64 build-macos-x86_64

build-mpfr-ios-simulator: build-mpfr-ios-simulator-arm64 build-mpfr-ios-simulator-x86_64
build-mpfr-tvos-simulator: build-mpfr-tvos-simulator-arm64 build-mpfr-tvos-simulator-x86_64
build-mpfr-watchos-simulator: build-mpfr-watchos-simulator-arm64 build-mpfr-watchos-simulator-x86_64
build-mpfr-visionos-simulator: build-mpfr-visionos-simulator-arm64 build-mpfr-visionos-simulator-x86_64
build-mpfr-maccatalyst: build-mpfr-maccatalyst-arm64 build-mpfr-maccatalyst-x86_64

build-mpfr-all: build-mpfr-ios-arm64 build-mpfr-ios-simulator build-mpfr-tvos-arm64 build-mpfr-tvos-simulator build-mpfr-watchos-arm64 build-mpfr-watchos-simulator build-mpfr-visionos-arm64 build-mpfr-visionos-simulator build-mpfr-maccatalyst build-mpfr-macos-arm64 build-mpfr-macos-x86_64
	@echo ""
	@echo "✓ All MPFR platforms built successfully!"

# ============================================================================
# Library and Headers Preparation
# ============================================================================
# Note: Universal platform mappings are now in scripts/build.sh
# For link-libs, we use universal platform names (ios-simulator, macos, etc.)
# which automatically combine arm64 + x86_64 into universal binaries

LINK_LIBS_PLATFORMS := ios-arm64 ios-simulator tvos-arm64 tvos-simulator \
                       watchos-arm64 watchos-simulator \
                       visionos-arm64 visionos-simulator \
                       maccatalyst macos

# Create universal GMP libraries and prepare headers
create-gmp-libs-and-headers: build-all
	@scripts/build.sh --task=link-libs --library=gmp --platforms="$(LINK_LIBS_PLATFORMS)"

# Create universal MPFR libraries and prepare headers
create-mpfr-libs-and-headers: build-mpfr-all
	@scripts/build.sh --task=link-libs --library=mpfr --platforms="$(LINK_LIBS_PLATFORMS)"

# ============================================================================
# XCFramework Creation
# ============================================================================

# Create GMP xcframework
create-xcframework: create-gmp-libs-and-headers
	@scripts/build.sh --task=create-xcframework --library=gmp --xcframework-dir=$(XCFRAMEWORK_DIR) --platforms="$(LINK_LIBS_PLATFORMS)"

# Create MPFR xcframework
create-mpfr-xcframework: create-mpfr-libs-and-headers
	@scripts/build.sh --task=create-xcframework --library=mpfr --xcframework-dir=$(CLINUS_XCFRAMEWORK_DIR) --platforms="$(LINK_LIBS_PLATFORMS)"

# ============================================================================
# Download and Extract Targets
# ============================================================================

all: $(VENDOR_DIR)/$(GMP_TARBALL)
	@echo "GMP library downloaded successfully!"

$(VENDOR_DIR):
	@mkdir -p $(VENDOR_DIR)

$(VENDOR_DIR)/$(GMP_TARBALL): $(VENDOR_DIR)
	@scripts/build.sh --task=download --library=gmp

download-mpfr: $(MPFR_VENDOR_DIR)/$(MPFR_TARBALL)
	@echo "MPFR library downloaded successfully!"

$(MPFR_VENDOR_DIR):
	@mkdir -p $(MPFR_VENDOR_DIR)

$(MPFR_VENDOR_DIR)/$(MPFR_TARBALL): $(MPFR_VENDOR_DIR)
	@scripts/build.sh --task=download --library=mpfr

# ============================================================================
# MPFR Documentation
# ============================================================================

mpfr-docs: $(MPFR_VENDOR_DIR)/$(MPFR_TARBALL)
	@scripts/build.sh --task=docs --library=mpfr

# ============================================================================
# Documentation Generation
# ============================================================================

generate-docs:
	@scripts/build.sh --task=docs --library=Kalliope

docs: generate-docs

clean-docs:
	@scripts/build.sh --task=clean --what=docs

# ============================================================================
# Clean Targets
# ============================================================================

clean:
	@scripts/build.sh --task=clean --what=all

clean-build:
	@scripts/build.sh --task=clean --what=build

# ============================================================================
# Phony Targets
# ============================================================================

.PHONY: all download-mpfr mpfr-docs \
        build-all build-mpfr-all \
        create-gmp-libs-and-headers create-mpfr-libs-and-headers \
        create-xcframework create-mpfr-xcframework \
        docs generate-docs clean-docs \
        clean clean-build help \
        $(foreach p,$(PLATFORMS),build-$(p) build-mpfr-$(p)) \
        build-ios-simulator build-tvos-simulator build-watchos-simulator build-visionos-simulator build-maccatalyst \
        build-mpfr-ios-simulator build-mpfr-tvos-simulator build-mpfr-watchos-simulator build-mpfr-visionos-simulator build-mpfr-maccatalyst

# ============================================================================
# Help Target
# ============================================================================

help:
	@echo "GMP and MPFR Library Build Makefile (Data-Driven Version)"
	@echo ""
	@echo "Targets:"
	@echo "  all                        - Download GMP (default)"
	@echo "  download-mpfr              - Download MPFR library"
	@echo "  mpfr-docs                  - Build MPFR HTML documentation"
	@echo ""
	@echo "Build Targets (Generated for all platforms):"
	@echo "  build-<platform>           - Build GMP for specific platform"
	@echo "  build-mpfr-<platform>      - Build MPFR for specific platform"
	@echo "  build-all                  - Build GMP for all platforms"
	@echo "  build-mpfr-all             - Build MPFR for all platforms"
	@echo ""
	@echo "Platforms:"
	@$(foreach p,$(PLATFORMS),echo "  - $(p)"; ) true
	@echo ""
	@echo "XCFramework Targets:"
	@echo "  create-xcframework         - Create GMP xcframework"
	@echo "  create-mpfr-xcframework    - Create MPFR xcframework"
	@echo ""
	@echo "Documentation:"
	@echo "  docs                       - Generate documentation"
	@echo "  generate-docs               - Generate documentation in docs/ directory"
	@echo "  clean-docs                 - Remove generated documentation"
	@echo ""
	@echo "Clean Targets:"
	@echo "  clean                      - Remove all downloaded and built files"
	@echo "  clean-build                - Remove only build artifacts (keep source)"
	@echo ""
	@echo "To skip tests (faster builds):"
	@echo "  make SKIP_TESTS=1 build-all"
	@echo ""
	@echo "Typical workflow:"
	@echo "  1. make SKIP_TESTS=1 build-all    # Build for all platforms"
	@echo "  2. make create-xcframework        # Create xcframework"
	@echo "  3. swift build                    # Build Swift package"
	@echo "  4. swift test                     # Run tests"

