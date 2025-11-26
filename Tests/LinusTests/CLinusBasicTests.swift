import CKalliope // Import CKalliope first so gmp.h is available
import CLinus
import CLinusBridge
import Kalliope
@testable import Linus
import Testing

/// Basic tests to verify CLinus framework can be imported and MPFR functions
/// work
/// Note: We use actual C functions, not macros, since complex C macros are
/// unavailable in Swift
struct CLinusBasicTests {
    @Test
    func mpfrVersion() {
        // Test that we can get MPFR version string
        let version = String(cString: mpfr_get_version())
        #expect(!version.isEmpty, "MPFR version should not be empty")
        #expect(version.contains("4.2"), "MPFR version should be 4.2.x")
        print("MPFR Version: \(version)")
    }

    @Test
    func mpfrThreadSafetyEnabled() {
        // Test that MPFR was built with thread-safety enabled
        // mpfr_buildopt_tls_p() returns non-zero if thread-safe (TLS) is
        // enabled
        // This checks if MPFR was built with --enable-thread-safe configure
        // option
        let isThreadSafe = mpfr_buildopt_tls_p()

        #expect(
            isThreadSafe != 0,
            """
            MPFR should be built with --enable-thread-safe.
            Current value: \(isThreadSafe) (0 = disabled, non-zero = enabled).
            """
        )
    }

    @Test
    func mpfrInitialization() {
        // Test basic MPFR initialization and operations
        var x = mpfr_t()
        var y = mpfr_t()
        var result = mpfr_t()

        // Initialize with default precision
        mpfr_init(&x)
        mpfr_init(&y)
        mpfr_init(&result)

        defer {
            mpfr_clear(&x)
            mpfr_clear(&y)
            mpfr_clear(&result)
        }

        // Set values: x = 3.14, y = 2.71
        let setX = mpfr_set_d(&x, 3.14, MPFR_RNDN)
        let setY = mpfr_set_d(&y, 2.71, MPFR_RNDN)

        #expect(setX == 0, "Setting x should succeed")
        #expect(setY == 0, "Setting y should succeed")

        // Add: result = x + y = 3.14 + 2.71 = 5.85
        // mpfr_add returns exactly: 0 (exact), 1 (rounded up), or -1 (rounded
        // down)
        let addResult = mpfr_add(&result, &x, &y, MPFR_RNDN)
        #expect(
            addResult == -1 || addResult == 0 || addResult == 1,
            "Return value must be exactly -1, 0, or 1"
        )

        // Get the result as double - this is what matters
        let resultValue = mpfr_get_d(&result, MPFR_RNDN)
        #expect(
            abs(resultValue - 5.85) < 0.01,
            "Result should be approximately 5.85"
        )
    }

    @Test
    func mpfrPrecision() {
        // Test precision management
        let precision: mpfr_prec_t = 100

        var x = mpfr_t()
        mpfr_init2(&x, precision)

        defer {
            mpfr_clear(&x)
        }

        let actualPrecision = mpfr_get_prec(&x)
        #expect(
            actualPrecision >= precision,
            "Precision should be at least requested value"
        )
    }

    @Test
    func mpfrRoundingMode() {
        // Test rounding mode functions
        let originalMode = mpfr_get_default_rounding_mode()

        // Set to round toward zero
        mpfr_set_default_rounding_mode(MPFR_RNDZ)
        let newMode = mpfr_get_default_rounding_mode()
        #expect(newMode == MPFR_RNDZ, "Rounding mode should be set to RNDZ")

        // Restore original mode
        mpfr_set_default_rounding_mode(originalMode)
        let restoredMode = mpfr_get_default_rounding_mode()
        #expect(
            restoredMode == originalMode,
            "Rounding mode should be restored"
        )
    }

    @Test
    func mpfrComparison() {
        // Test comparison functions
        var x = mpfr_t()
        var y = mpfr_t()

        mpfr_init(&x)
        mpfr_init(&y)

        defer {
            mpfr_clear(&x)
            mpfr_clear(&y)
        }

        mpfr_set_d(&x, 3.14, MPFR_RNDN)
        mpfr_set_d(&y, 2.71, MPFR_RNDN)

        // x > y
        // Note: mpfr_cmp is a macro in C, so we use mpfr_cmp3 directly in Swift
        let cmpResult = mpfr_cmp3(&x, &y, 1)
        #expect(cmpResult > 0, "x should be greater than y")

        // x == x
        let cmpSelf = mpfr_cmp3(&x, &x, 1)
        #expect(cmpSelf == 0, "x should equal itself")
    }

    @Test
    func mpfrConcurrentConstantOperations() async throws {
        // Test that constant functions work correctly when called concurrently
        // This verifies that thread-safe MPFR (with TLS) handles concurrent
        // access
        // without requiring explicit synchronization

        let iterations = 100
        let concurrentTasks = 10

        await withTaskGroup(of: Void.self) { group in
            for _ in 0 ..< concurrentTasks {
                group.addTask {
                    for _ in 0 ..< iterations {
                        // Call all constant functions concurrently
                        let (pi, _) = MPFRFloat.pi(precision: 64)
                        let (euler, _) = MPFRFloat.euler(precision: 64)
                        let (catalan, _) = MPFRFloat.catalan(precision: 64)
                        let (log2, _) = MPFRFloat.log2(precision: 64)

                        // Verify results are valid (not NaN, not corrupted)
                        #expect(!pi.isNaN, "pi should not be NaN")
                        #expect(!euler.isNaN, "euler should not be NaN")
                        #expect(!catalan.isNaN, "catalan should not be NaN")
                        #expect(!log2.isNaN, "log2 should not be NaN")

                        // Verify values are reasonable
                        let piValue = pi.toDouble()
                        let eulerValue = euler.toDouble()
                        let catalanValue = catalan.toDouble()
                        let log2Value = log2.toDouble()

                        #expect(
                            piValue > 3.0 && piValue < 4.0,
                            "pi should be between 3 and 4"
                        )
                        #expect(
                            eulerValue > 0.5 && eulerValue < 1.0,
                            "euler should be between 0.5 and 1.0"
                        )
                        #expect(
                            catalanValue > 0.9 && catalanValue < 1.0,
                            "catalan should be between 0.9 and 1.0"
                        )
                        #expect(
                            log2Value > 0.6 && log2Value < 0.7,
                            "log2 should be between 0.6 and 0.7"
                        )
                    }
                }
            }
        }

        print(
            "✓ Successfully completed \(concurrentTasks * iterations) concurrent constant operations per function"
        )
    }
}
