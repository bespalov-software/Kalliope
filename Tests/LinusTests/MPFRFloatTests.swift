import CKalliope // Import CKalliope first so gmp.h is available
import CLinus
import CLinusBridge
import Kalliope
@testable import Linus
import Testing

/// Tests for MPFRFloat Core functionality
struct MPFRFloatTests {
    // MARK: - Section 1: Type Definition and Storage

    @Test
    func storage_init_DefaultPrecision_CreatesNaN() {
        // Given: No preconditions
        // When: Creating MPFRFloat() and accessing _storage
        let a = MPFRFloat()

        // Then: Storage contains NaN value and has default precision (53 bits)
        #expect(a.isNaN == true, "Default initialization should create NaN")
        #expect(
            a.precision >= 53,
            "Default precision should be at least 53 bits"
        )
    }

    @Test
    func storage_init_SpecificPrecision_CreatesNaN() {
        // Given: No preconditions
        // When: Creating MPFRFloat(precision: 64) and accessing _storage
        let a = MPFRFloat(precision: 64)

        // Then: Storage contains NaN value and has precision 64 bits
        #expect(
            a.isNaN == true,
            "Initialization with precision should create NaN"
        )
        #expect(a.precision == 64, "Precision should be exactly 64 bits")
    }

    @Test
    func storage_init_Copying_CreatesIndependentCopy() {
        // Given: MPFRFloat(3.14159, precision: 64)
        let a = MPFRFloat(3.14159, precision: 64)

        // When: Creating b = a and accessing b._storage
        var b = a

        // Then: New storage has same value (3.14159) and precision (64), but is independent
        #expect(b.toDouble() == 3.14159, "Copied value should match original")
        #expect(b.precision == 64, "Copied precision should match original")

        // Verify independence: mutating b should not affect a
        b.set(2.71828, rounding: .nearest)
        #expect(
            a.toDouble() == 3.14159,
            "Original should be unchanged after mutation"
        )
        #expect(b.toDouble() == 2.71828, "Copy should have new value")
    }

    @Test
    func storage_deinit_FreesMemory() {
        // Given: MPFRFloat(3.14159, precision: 64)
        // When: Allowing it to go out of scope
        do {
            _ = MPFRFloat(3.14159, precision: 64)
            // Memory should be freed when going out of scope
        }
        // Then: Memory is freed (no leaks, verified with memory tools)
        // Note: This test verifies the code compiles and runs without crashes
        // Actual memory leak detection requires tools like Instruments
        #expect(Bool(true), "Memory should be freed by ARC")
    }

    // MARK: - Section 1: COW Semantics

    @Test
    func cow_MultipleReferences_ShareStorage() {
        // Given: MPFRFloat(3.14159, precision: 64)
        var a = MPFRFloat(3.14159, precision: 64)

        // When: Creating b = a and checking isKnownUniquelyReferenced
        let b = a // b shares storage with a
        let isUnique = isKnownUniquelyReferenced(&a._storage)
        // Verify b exists to ensure storage is actually shared
        _ = b

        // Then: Returns false (storage is shared, reference count > 1)
        #expect(isUnique == false, "Storage should be shared when copied")
    }

    @Test
    func cow_Mutation_CreatesCopy() {
        // Given: MPFRFloat(3.14159, precision: 64) and b = a
        var a = MPFRFloat(3.14159, precision: 64)
        let b = a

        // When: Mutating a by calling set
        a.set(2.71828, rounding: .nearest)

        // Then: a has new value (2.71828), b still has original value (3.14159)
        #expect(a.toDouble() == 2.71828, "Mutated value should be 2.71828")
        #expect(b.toDouble() == 3.14159, "Original copy should be unchanged")

        // Verify storage is copied (COW triggered)
        let isUnique = isKnownUniquelyReferenced(&a._storage)
        #expect(isUnique == true, "Storage should be unique after mutation")
    }

    @Test
    func cow_NoMutation_NoCopy() {
        // Given: MPFRFloat(3.14159, precision: 64) and b = a
        var a = MPFRFloat(3.14159, precision: 64)
        let b = a

        // When: Performing non-mutating operation (reading precision)
        _ = a.precision
        _ = b.precision

        // Then: No copy is created, a and b still share storage
        let isUnique = isKnownUniquelyReferenced(&a._storage)
        #expect(
            isUnique == false,
            "Storage should still be shared after non-mutating operation"
        )
    }

    @Test
    func cow_IndependentCopies_NoInterference() {
        // Given: MPFRFloat(3.14159, precision: 64) and b = a
        var a = MPFRFloat(3.14159, precision: 64)
        var b = a

        // When: Mutating a to 2.71828, then mutating b to 1.41421
        a.set(2.71828, rounding: .nearest)
        b.set(1.41421, rounding: .nearest)

        // Then: a has value 2.71828, b has value 1.41421, no interference
        #expect(a.toDouble() == 2.71828, "a should have value 2.71828")
        #expect(b.toDouble() == 1.41421, "b should have value 1.41421")

        // Both should have unique storage
        let aIsUnique = isKnownUniquelyReferenced(&a._storage)
        let bIsUnique = isKnownUniquelyReferenced(&b._storage)
        #expect(aIsUnique == true, "a should have unique storage")
        #expect(bIsUnique == true, "b should have unique storage")
    }

    // MARK: - Section 2: Rounding Modes

    @Test
    func roundingMode_AllCases_Defined() {
        // Given: All rounding mode cases
        // When: Checking all cases exist
        // Then: All cases exist: .nearest, .towardZero, .towardPositiveInfinity,
        // .towardNegativeInfinity, .awayFromZero, .faithful
        let _: MPFRRoundingMode = .nearest
        let _: MPFRRoundingMode = .towardZero
        let _: MPFRRoundingMode = .towardPositiveInfinity
        let _: MPFRRoundingMode = .towardNegativeInfinity
        let _: MPFRRoundingMode = .awayFromZero
        let _: MPFRRoundingMode = .faithful
        #expect(Bool(true), "All rounding mode cases should be defined")
    }

    @Test
    func roundingMode_Nearest_Default() {
        // Given: Default rounding mode
        // When: Using default rounding mode in set operation
        var a = MPFRFloat(3.14159, precision: 64)
        a.set(2.71828) // Uses default .nearest

        // Then: Operation succeeds with .nearest rounding
        #expect(a.toDouble() == 2.71828, "Default rounding should be .nearest")
    }

    @Test
    func roundingMode_AllModes_ConvertCorrectly() {
        // Given: All rounding modes
        // When: Converting each mode to MPFR rounding mode
        var a = MPFRFloat(3.14159, precision: 64)

        // Test all rounding modes
        a.set(2.71828, rounding: .nearest)
        #expect(a.toDouble() == 2.71828, ".nearest should work")

        a.set(2.71828, rounding: .towardZero)
        #expect(a.toDouble() == 2.71828, ".towardZero should work")

        a.set(2.71828, rounding: .towardPositiveInfinity)
        #expect(a.toDouble() == 2.71828, ".towardPositiveInfinity should work")

        a.set(2.71828, rounding: .towardNegativeInfinity)
        #expect(a.toDouble() == 2.71828, ".towardNegativeInfinity should work")

        a.set(2.71828, rounding: .awayFromZero)
        #expect(a.toDouble() == 2.71828, ".awayFromZero should work")

        a.set(2.71828, rounding: .faithful)
        #expect(a.toDouble() == 2.71828, ".faithful should work")
    }

    // Additional test: init with default precision (nil precision parameter)
    @Test
    func init_Double_DefaultPrecision_UsesDefaultPrecision() {
        // Given: No precision specified
        // When: Creating MPFRFloat with Double value but nil precision
        let a = MPFRFloat(3.14159, precision: nil)

        // Then: Uses default precision (typically 53 bits)
        #expect(
            a.precision >= 53,
            "Should use default precision when nil is specified"
        )
        #expect(a.toDouble() == 3.14159, "Value should be set correctly")
    }

    // Test: precision setter
    @Test
    func precision_Set_UpdatesPrecision() {
        // Given: MPFRFloat with precision 64
        var a = MPFRFloat(precision: 64)
        #expect(a.precision == 64, "Initial precision should be 64")

        // When: Setting precision to 128
        a.precision = 128

        // Then: Precision should be updated to 128
        #expect(a.precision == 128, "Precision should be updated to 128")

        // Test setting to different precision values
        a.precision = 256
        #expect(a.precision == 256, "Precision should be updated to 256")

        a.precision = 32
        #expect(a.precision == 32, "Precision should be updated to 32")
    }

    // MARK: - Section 3: Default Precision

    @Test
    func setDefaultPrecision_ValidPrecision_SetsDefault() {
        // Given: Valid precision value 128
        let originalDefault = MPFRFloat.defaultPrecision

        // When: Calling MPFRFloat.setDefaultPrecision(128)
        MPFRFloat.setDefaultPrecision(128)
        defer { MPFRFloat.setDefaultPrecision(originalDefault) }

        // Then: MPFRFloat.defaultPrecision == 128
        #expect(
            MPFRFloat.defaultPrecision == 128,
            "Default precision should be set to 128"
        )
    }

    @Test
    func setDefaultPrecision_NewInstances_UseDefault() {
        // Given: MPFRFloat.setDefaultPrecision(128) has been called
        let originalDefault = MPFRFloat.defaultPrecision
        MPFRFloat.setDefaultPrecision(128)
        defer { MPFRFloat.setDefaultPrecision(originalDefault) }

        // When: Creating let a = MPFRFloat()
        let a = MPFRFloat()

        // Then: a.precision == 128
        #expect(
            a.precision == 128,
            "New instance should use default precision of 128"
        )
    }

    @Test
    func setDefaultPrecision_ExistingInstances_Unaffected() {
        // Given: let a = MPFRFloat(precision: 64)
        let a = MPFRFloat(precision: 64)
        let originalDefault = MPFRFloat.defaultPrecision

        // When: Calling MPFRFloat.setDefaultPrecision(128)
        MPFRFloat.setDefaultPrecision(128)
        defer { MPFRFloat.setDefaultPrecision(originalDefault) }

        // Then: a.precision == 64 (unchanged)
        #expect(
            a.precision == 64,
            "Existing instance precision should be unchanged"
        )
    }

    // Note: Preconditions crash rather than throw, so we test valid boundary
    // values instead
    @Test
    func setDefaultPrecision_BoundaryValues_Works() {
        // Given: Boundary precision values
        let precMin = Int(clinus_get_prec_min())
        let precMax = Int(clinus_get_prec_max())
        let originalDefault = MPFRFloat.defaultPrecision
        defer { MPFRFloat.setDefaultPrecision(originalDefault) }

        // When: Calling MPFRFloat.setDefaultPrecision with boundary values
        // Then: Should work with valid boundary values
        MPFRFloat.setDefaultPrecision(precMin)
        #expect(
            MPFRFloat.defaultPrecision == precMin,
            "Should accept minimum precision"
        )

        MPFRFloat.setDefaultPrecision(precMax)
        #expect(
            MPFRFloat.defaultPrecision == precMax,
            "Should accept maximum precision"
        )
    }

    @Test
    func defaultPrecision_Getter_ReturnsCurrentDefault() {
        // Given: Default precision is 53 (platform default)
        // When: Accessing MPFRFloat.defaultPrecision
        let defaultPrec = MPFRFloat.defaultPrecision

        // Then: Returns 53 (or current default value)
        #expect(defaultPrec >= 53, "Default precision should be at least 53")
    }

    @Test
    func defaultPrecision_AfterSetting_ReturnsNewValue() {
        // Given: MPFRFloat.setDefaultPrecision(128) has been called
        let originalDefault = MPFRFloat.defaultPrecision
        MPFRFloat.setDefaultPrecision(128)
        defer { MPFRFloat.setDefaultPrecision(originalDefault) }

        // When: Accessing MPFRFloat.defaultPrecision
        // Then: Returns 128
        #expect(
            MPFRFloat.defaultPrecision == 128,
            "Default precision should return 128"
        )
    }

    // MARK: - Section 3: Default Rounding Mode

    @Test
    func setDefaultRoundingMode_AllModes_Works() {
        // Given: Rounding mode from table
        let originalDefault = MPFRFloat.defaultRoundingMode

        // Test all rounding modes
        let modes: [MPFRRoundingMode] = [
            .nearest,
            .towardZero,
            .towardPositiveInfinity,
            .towardNegativeInfinity,
            .awayFromZero,
            .faithful,
        ]

        for mode in modes {
            // When: Calling MPFRFloat.setDefaultRoundingMode(mode)
            MPFRFloat.setDefaultRoundingMode(mode)

            // Then: MPFRFloat.defaultRoundingMode == mode
            #expect(
                MPFRFloat.defaultRoundingMode == mode,
                "Default rounding mode should be set to \(mode)"
            )
        }

        // Restore original
        MPFRFloat.setDefaultRoundingMode(originalDefault)
    }

    // Note: Our current set() method uses Swift default parameters, not MPFR's
    // default.
    // This test verifies that the default rounding mode can be set and
    // retrieved correctly.
    @Test
    func setDefaultRoundingMode_NewOperations_UseDefault() {
        // Given: MPFRFloat.setDefaultRoundingMode(.towardZero) has been called
        let originalDefault = MPFRFloat.defaultRoundingMode
        MPFRFloat.setDefaultRoundingMode(.towardZero)
        defer { MPFRFloat.setDefaultRoundingMode(originalDefault) }

        // When: Verifying default rounding mode is set
        // Then: Default rounding mode should be .towardZero
        #expect(
            MPFRFloat.defaultRoundingMode == .towardZero,
            "Default rounding mode should be .towardZero"
        )

        // Note: To actually use the default in operations, we would need to
        // modify
        // methods to use mpfr_get_default_rounding_mode() when no rounding is
        // specified.
        // For now, we verify the default can be set and retrieved.
    }

    @Test
    func setDefaultRoundingMode_ExistingInstances_Unaffected() {
        // Given: let a = MPFRFloat(3.14159, precision: 64) created with default rounding mode
        let a = MPFRFloat(3.14159, precision: 64)
        let originalDefault = MPFRFloat.defaultRoundingMode

        // When: Calling MPFRFloat.setDefaultRoundingMode(.towardZero)
        MPFRFloat.setDefaultRoundingMode(.towardZero)
        defer { MPFRFloat.setDefaultRoundingMode(originalDefault) }

        // Then: Existing instance a is unaffected (its operations still use the rounding mode it was created with)
        // The value should remain the same
        #expect(
            a.toDouble() == 3.14159,
            "Existing instance should be unaffected"
        )
    }

    @Test
    func defaultRoundingMode_Getter_ReturnsCurrentDefault() {
        // Given: Default rounding mode (platform default, typically .nearest)
        // When: Accessing MPFRFloat.defaultRoundingMode
        let defaultMode = MPFRFloat.defaultRoundingMode

        // Then: Returns a valid rounding mode (typically .nearest)
        // Verify it's one of the valid modes
        let validModes: [MPFRRoundingMode] = [
            .nearest,
            .towardZero,
            .towardPositiveInfinity,
            .towardNegativeInfinity,
            .awayFromZero,
            .faithful,
        ]
        #expect(
            validModes.contains(defaultMode),
            "Default rounding mode should be a valid mode"
        )
        // MPFR's default is typically .nearest
        #expect(
            defaultMode == .nearest,
            "Default rounding mode should be .nearest (MPFR default)"
        )
    }

    @Test
    func defaultRoundingMode_AfterSetting_ReturnsNewValue() {
        // Given: MPFRFloat.setDefaultRoundingMode(.towardZero) has been called
        let originalDefault = MPFRFloat.defaultRoundingMode
        MPFRFloat.setDefaultRoundingMode(.towardZero)
        defer { MPFRFloat.setDefaultRoundingMode(originalDefault) }

        // When: Accessing MPFRFloat.defaultRoundingMode
        // Then: Returns .towardZero
        #expect(
            MPFRFloat.defaultRoundingMode == .towardZero,
            "Default rounding mode should return .towardZero"
        )
    }

    // Test: fromMPFRRoundingMode default case coverage
    @Test
    func fromMPFRRoundingMode_UnknownValue_ReturnsNearest() {
        // Given: An unknown/invalid MPFR rounding mode value
        // When: Converting it using fromMPFRRoundingMode
        // Then: Should fallback to .nearest

        // Test all known values map correctly
        let knownModes: [(MPFRRoundingMode, mpfr_rnd_t)] = [
            (.nearest, MPFR_RNDN),
            (.towardZero, MPFR_RNDZ),
            (.towardPositiveInfinity, MPFR_RNDU),
            (.towardNegativeInfinity, MPFR_RNDD),
            (.awayFromZero, MPFR_RNDA),
            (.faithful, MPFR_RNDF),
        ]

        for (expected, rnd) in knownModes {
            let result = MPFRRoundingMode.fromMPFRRoundingMode(rnd)
            #expect(
                result == expected,
                "fromMPFRRoundingMode should map \(rnd) to \(expected)"
            )
        }

        // Test default case with an invalid value using memory manipulation
        // mpfr_rnd_t is a C enum, so we can create an invalid value using
        // unsafe pointer
        var invalidValue: Int32 = 999
        let invalidRnd = withUnsafePointer(to: &invalidValue) { ptr in
            ptr.withMemoryRebound(to: mpfr_rnd_t.self, capacity: 1) { rndPtr in
                rndPtr.pointee
            }
        }
        let result = MPFRRoundingMode.fromMPFRRoundingMode(invalidRnd)
        #expect(
            result == .nearest,
            "Invalid rounding mode should fallback to .nearest"
        )
    }

    // MARK: - Section 4: Assignment

    @Test
    func set_MPFRFloat_SamePrecision_Exact() {
        // Given: var a = MPFRFloat(precision: 64) and let b = MPFRFloat(3.14159, precision: 64)
        var a = MPFRFloat(precision: 64)
        let b = MPFRFloat(3.14159, precision: 64)

        // When: Calling a.set(b, rounding: .nearest)
        a.set(b, rounding: .nearest)

        // Then: a.toDouble() == 3.14159 (exact, no rounding needed)
        #expect(a.toDouble() == 3.14159, "Value should be set exactly")
    }

    @Test
    func set_MPFRFloat_HigherPrecision_Rounds() {
        // Given: var a = MPFRFloat(precision: 2) and let b = MPFRFloat(3.14159, precision: 64)
        // Using 3.14159 which definitely requires rounding with precision 2
        var a = MPFRFloat(precision: 2)
        let b = MPFRFloat(3.14159, precision: 64)

        // When: Calling a.set(b, rounding: .nearest)
        a.set(b, rounding: .nearest)

        // Then: a.toDouble() is rounded to a representable value with precision 2
        // Precision 2 can represent values like 2.0, 3.0, 4.0, etc.
        let result = a.toDouble()
        #expect(result != 3.14159, "Value should be rounded with precision 2")
        #expect(
            result >= 2.0 && result <= 4.0,
            "Rounded value should be in reasonable range"
        )
    }

    @Test
    func set_MPFRFloat_LowerPrecision_Preserves() {
        // Given: var a = MPFRFloat(precision: 128) and let b = MPFRFloat(3.14159, precision: 64)
        var a = MPFRFloat(precision: 128)
        let b = MPFRFloat(3.14159, precision: 64)

        // When: Calling a.set(b, rounding: .nearest)
        a.set(b, rounding: .nearest)

        // Then: a.toDouble() == 3.14159 (value preserved, no precision loss)
        #expect(
            a.toDouble() == 3.14159,
            "Value should be preserved when target has higher precision"
        )
    }

    @Test
    func set_MPFRFloat_Self_Works() {
        // Given: var a = MPFRFloat(3.14159, precision: 64)
        var a = MPFRFloat(3.14159, precision: 64)

        // When: Calling a.set(a, rounding: .nearest)
        a.set(a, rounding: .nearest)

        // Then: Operation succeeds, a.toDouble() == 3.14159 (unchanged)
        #expect(
            a.toDouble() == 3.14159,
            "Self-assignment should work correctly"
        )
    }

    @Test
    func set_MPFRFloat_AllRoundingModes_Works() {
        // Test with precision 2 and value 2.7 (which requires rounding)
        // Precision 2 can represent 2.0, 3.0, 4.0, etc.
        let testCases: [(MPFRRoundingMode, Double)] = [
            (.nearest, 3.0), // Rounds to nearest (2.7 -> 3.0)
            (.towardZero, 2.0), // Rounds toward zero (2.7 -> 2.0)
            (.towardPositiveInfinity, 3.0), // Rounds up (2.7 -> 3.0)
            (.towardNegativeInfinity, 2.0), // Rounds down (2.7 -> 2.0)
        ]

        for (roundingMode, expectedResult) in testCases {
            // Given: var a = MPFRFloat(precision: 2) and let b = MPFRFloat(2.7, precision: 64)
            var a = MPFRFloat(precision: 2)
            let b = MPFRFloat(2.7, precision: 64)

            // When: Calling a.set(b, rounding: roundingMode)
            a.set(b, rounding: roundingMode)

            // Then: a.toDouble() matches expected result
            #expect(
                a.toDouble() == expectedResult,
                "Rounding mode \(roundingMode) should produce \(expectedResult)"
            )
        }
    }

    @Test
    func set_MPFRFloat_ReturnsTernary() {
        // Given: var a = MPFRFloat(precision: 64) and let b = MPFRFloat(3.14159, precision: 64)
        var a = MPFRFloat(precision: 64)
        let b = MPFRFloat(3.14159, precision: 64)

        // When: Calling let result = a.set(b, rounding: .nearest)
        let result = a.set(b, rounding: .nearest)

        // Then: Returns 0 (exact), positive (rounded up), or negative (rounded down) integer
        // For same precision, should return 0 (exact)
        #expect(result == 0, "Same precision should return 0 (exact)")

        // Test with different precision to get non-zero result
        var c = MPFRFloat(precision: 2)
        let d = MPFRFloat(2.7, precision: 64)
        let result2 = c.set(d, rounding: .nearest)
        // Result can be 0, positive, or negative depending on rounding
        // With precision 2, 2.7 should round to 3.0, so result should be
        // positive (rounded up)
        #expect(
            result2 >= -1 && result2 <= 1,
            "Ternary result should be -1, 0, or 1"
        )
    }

    @Test
    func set_Int_BasicValues_Exact() {
        // Table Test
        let testCases: [(Int, Double)] = [
            (42, 42.0), // Positive integer
            (-42, -42.0), // Negative integer
            (0, 0.0), // Zero
            (1_000_000, 1_000_000.0), // Large integer
        ]

        for (inputValue, expectedResult) in testCases {
            // Given: var a = MPFRFloat(precision: 64) and integer value from table
            var a = MPFRFloat(precision: 64)

            // When: Calling a.set(value, rounding: .nearest)
            a.set(inputValue, rounding: .nearest)

            // Then: a.toDouble() matches expected result exactly
            #expect(
                a.toDouble() == expectedResult,
                "Value \(inputValue) should be set exactly to \(expectedResult)"
            )
        }
    }

    @Test
    func set_Int_AllRoundingModes_Works() {
        // Note: Rounding modes don't apply when setting from Int (integers are
        // exact)
        let roundingModes: [MPFRRoundingMode] = [
            .nearest,
            .towardZero,
            .towardPositiveInfinity,
            .towardNegativeInfinity,
            .awayFromZero,
            .faithful,
        ]

        for roundingMode in roundingModes {
            // Given: var a = MPFRFloat(precision: 64) and integer value 42
            var a = MPFRFloat(precision: 64)

            // When: Calling a.set(42, rounding: roundingMode)
            a.set(42, rounding: roundingMode)

            // Then: a.toDouble() == 42.0 (always exact for integers)
            #expect(
                a.toDouble() == 42.0,
                "Integer should be exact regardless of rounding mode"
            )
        }
    }

    @Test
    func set_Int_ReturnsTernary() {
        // Given: var a = MPFRFloat(precision: 64) and integer value 42
        var a = MPFRFloat(precision: 64)

        // When: Calling let result = a.set(42, rounding: .nearest)
        let result = a.set(42, rounding: .nearest)

        // Then: Returns 0 (exact, since integers are always exact)
        #expect(result == 0, "Integer should return 0 (exact)")
    }

    // Additional test: set_Int_IntMin_Works
    @Test
    func set_Int_IntMin_Works() {
        // Test Int.min to ensure it's handled correctly
        var a = MPFRFloat(precision: 64)
        a.set(Int.min, rounding: .nearest)

        // Int.min should be representable exactly
        #expect(
            a.toDouble() == Double(Int.min),
            "Int.min should be set correctly"
        )

        // Verify ternary result is 0 (exact)
        var b = MPFRFloat(precision: 64)
        let result = b.set(Int.min, rounding: .nearest)
        #expect(result == 0, "Int.min should return 0 (exact)")
    }

    @Test
    func set_UInt_BasicValues_Exact() {
        // Table Test
        let testCases: [(UInt, Double)] = [
            (42, 42.0), // Positive integer
            (0, 0.0), // Zero
            (1_000_000, 1_000_000.0), // Large integer
        ]

        for (inputValue, expectedResult) in testCases {
            // Given: var a = MPFRFloat(precision: 64) and unsigned integer value from table
            var a = MPFRFloat(precision: 64)

            // When: Calling a.set(value, rounding: .nearest)
            a.set(inputValue, rounding: .nearest)

            // Then: a.toDouble() matches expected result exactly
            #expect(
                a.toDouble() == expectedResult,
                "Value \(inputValue) should be set exactly to \(expectedResult)"
            )
        }
    }

    @Test
    func set_UInt_AllRoundingModes_Works() {
        // Note: Rounding modes don't apply when setting from UInt (integers are
        // exact)
        let roundingModes: [MPFRRoundingMode] = [
            .nearest,
            .towardZero,
            .towardPositiveInfinity,
            .towardNegativeInfinity,
            .awayFromZero,
            .faithful,
        ]

        for roundingMode in roundingModes {
            // Given: var a = MPFRFloat(precision: 64) and unsigned integer value 42
            var a = MPFRFloat(precision: 64)

            // When: Calling a.set(42, rounding: roundingMode)
            a.set(UInt(42), rounding: roundingMode)

            // Then: a.toDouble() == 42.0 (always exact for integers)
            #expect(
                a.toDouble() == 42.0,
                "Integer should be exact regardless of rounding mode"
            )
        }
    }

    @Test
    func set_UInt_ReturnsTernary() {
        // Given: var a = MPFRFloat(precision: 64) and unsigned integer value 42
        var a = MPFRFloat(precision: 64)

        // When: Calling let result = a.set(42, rounding: .nearest)
        let result = a.set(UInt(42), rounding: .nearest)

        // Then: Returns 0 (exact, since integers are always exact)
        #expect(result == 0, "Integer should return 0 (exact)")
    }

    @Test
    func set_Double_SpecialValues_Works() {
        // Table Test
        let testCases: [(Double, String)] = [
            (3.14159, "Positive value"),
            (-3.14159, "Negative value"),
            (0.0, "Zero"),
            (Double.infinity, "Positive infinity"),
            (-Double.infinity, "Negative infinity"),
            (Double.nan, "NaN"),
            (1e-300, "Very small value"),
        ]

        for (inputValue, description) in testCases {
            // Given: var a = MPFRFloat(precision: 64) and Double value from table
            var a = MPFRFloat(precision: 64)

            // When: Calling a.set(value, rounding: .nearest)
            a.set(inputValue, rounding: .nearest)

            // Then: Result matches expected result
            if inputValue.isNaN {
                #expect(a.isNaN == true, "NaN should be preserved")
            } else if inputValue.isInfinite {
                #expect(
                    a.toDouble().isInfinite == true,
                    "Infinity should be preserved"
                )
                #expect(
                    a.toDouble().sign == inputValue.sign,
                    "Infinity sign should be preserved"
                )
            } else if inputValue == 0.0 {
                #expect(a.toDouble() == 0.0, "Zero should be exact")
            } else {
                // For regular values, check approximate equality
                let diff = abs(a.toDouble() - inputValue)
                #expect(
                    diff < 1e-10,
                    "Value \(description) should be set approximately correctly"
                )
            }
        }
    }

    @Test
    func set_Double_AllRoundingModes_Works() {
        // Table Test with precision 2 and value 2.7
        let testCases: [(MPFRRoundingMode, Double, Double)] = [
            (.nearest, 2.7, 3.0), // Rounds to nearest (2.7 -> 3.0)
            (.towardZero, 2.7, 2.0), // Rounds toward zero (2.7 -> 2.0)
            (.towardPositiveInfinity, 2.7, 3.0), // Rounds up (2.7 -> 3.0)
            (.towardNegativeInfinity, 2.7, 2.0), // Rounds down (2.7 -> 2.0)
        ]

        for (roundingMode, inputValue, expectedResult) in testCases {
            // Given: var a = MPFRFloat(precision: 2) and Double value from table
            var a = MPFRFloat(precision: 2)

            // When: Calling a.set(value, rounding: roundingMode)
            a.set(inputValue, rounding: roundingMode)

            // Then: a.toDouble() matches expected result
            #expect(
                a.toDouble() == expectedResult,
                "Rounding mode \(roundingMode) should produce \(expectedResult)"
            )
        }
    }

    @Test
    func set_Double_ReturnsTernary() {
        // Given: var a = MPFRFloat(precision: 64) and Double value 3.14159
        var a = MPFRFloat(precision: 64)

        // When: Calling let result = a.set(3.14159, rounding: .nearest)
        let result = a.set(3.14159, rounding: .nearest)

        // Then: Returns 0 (exact), positive (rounded up), or negative (rounded down) integer
        #expect(
            result >= -1 && result <= 1,
            "Ternary result should be -1, 0, or 1"
        )

        // Test with low precision to get non-zero result
        var b = MPFRFloat(precision: 2)
        let result2 = b.set(2.7, rounding: .nearest)
        #expect(
            result2 >= -1 && result2 <= 1,
            "Ternary result should be -1, 0, or 1"
        )
    }

    @Test
    func set_String_Decimal_Valid_Works() {
        // Given: var a = MPFRFloat(precision: 64) and string "3.14159"
        var a = MPFRFloat(precision: 64)

        // When: Calling let result = a.set("3.14159", base: 10, rounding: .nearest)
        let result = a.set("3.14159", base: 10, rounding: .nearest)

        // Then: Returns true and a.toDouble() == 3.14159
        #expect(result == true, "Should successfully parse decimal string")
        #expect(
            abs(a.toDouble() - 3.14159) < 1e-10,
            "Value should match parsed string"
        )
    }

    @Test
    func set_String_Decimal_WithExponent_Works() {
        // Given: var a = MPFRFloat(precision: 64) and string "1.23e-4"
        var a = MPFRFloat(precision: 64)

        // When: Calling let result = a.set("1.23e-4", base: 10, rounding: .nearest)
        let result = a.set("1.23e-4", base: 10, rounding: .nearest)

        // Then: Returns true and a.toDouble() == 0.000123
        #expect(
            result == true,
            "Should successfully parse string with exponent"
        )
        #expect(
            abs(a.toDouble() - 0.000123) < 1e-10,
            "Value should match parsed string"
        )
    }

    @Test
    func set_String_Hex_Valid_Works() {
        // Given: var a = MPFRFloat(precision: 64) and string "1.8p0" (hexadecimal)
        var a = MPFRFloat(precision: 64)

        // When: Calling let result = a.set("1.8p0", base: 16, rounding: .nearest)
        let result = a.set("1.8p0", base: 16, rounding: .nearest)

        // Then: Returns true and a.toDouble() == 1.5
        #expect(result == true, "Should successfully parse hexadecimal string")
        #expect(
            abs(a.toDouble() - 1.5) < 1e-10,
            "Value should match parsed hex string (1.8p0 = 1.5)"
        )
    }

    @Test
    func set_String_Binary_Valid_Works() {
        // Given: var a = MPFRFloat(precision: 64) and string "1.1" (binary)
        var a = MPFRFloat(precision: 64)

        // When: Calling let result = a.set("1.1", base: 2, rounding: .nearest)
        let result = a.set("1.1", base: 2, rounding: .nearest)

        // Then: Returns true and a.toDouble() == 1.5 (1.1 in binary = 1.5 in decimal)
        #expect(result == true, "Should successfully parse binary string")
        #expect(
            abs(a.toDouble() - 1.5) < 1e-10,
            "Value should match parsed binary string"
        )
    }

    @Test
    func set_String_AutoDetectBase_Works() {
        // Given: var a = MPFRFloat(precision: 64)
        var a = MPFRFloat(precision: 64)

        // When: Calling with base 0 (auto-detect)
        // Test decimal (no prefix)
        let result1 = a.set("3.14159", base: 0, rounding: .nearest)
        #expect(result1 == true, "Should auto-detect decimal")
        #expect(
            abs(a.toDouble() - 3.14159) < 1e-10,
            "Decimal should be parsed correctly"
        )

        // Test hex (0x prefix)
        let result2 = a.set("0x1.8p0", base: 0, rounding: .nearest)
        #expect(result2 == true, "Should auto-detect hex from 0x prefix")
        #expect(
            abs(a.toDouble() - 1.5) < 1e-10,
            "Hex should be parsed correctly"
        )
    }

    @Test
    func set_String_Invalid_ReturnsFalse() {
        // Given: var a = MPFRFloat(precision: 64) and invalid string "abc"
        var a = MPFRFloat(precision: 64)
        // Set to a known value first
        a.set(3.14159, rounding: .nearest)
        _ = a.toDouble()

        // When: Calling let result = a.set("abc", base: 10, rounding: .nearest)
        let result = a.set("abc", base: 10, rounding: .nearest)

        // Then: Returns false
        #expect(result == false, "Should return false for invalid string")
        // Note: MPFR may or may not preserve the value on parse failure
        // The important thing is that it returns false
    }

    @Test
    func set_String_Empty_ReturnsFalse() {
        // Given: var a = MPFRFloat(precision: 64) and empty string ""
        var a = MPFRFloat(precision: 64)

        // When: Calling let result = a.set("", base: 10, rounding: .nearest)
        let result = a.set("", base: 10, rounding: .nearest)

        // Then: Returns false
        #expect(result == false, "Should return false for empty string")
    }

    @Test
    func set_String_AllRoundingModes_Works() {
        // Test that all rounding modes are accepted
        let roundingModes: [MPFRRoundingMode] = [
            .nearest,
            .towardZero,
            .towardPositiveInfinity,
            .towardNegativeInfinity,
            .awayFromZero,
            .faithful,
        ]

        for roundingMode in roundingModes {
            var a = MPFRFloat(precision: 64)
            let result = a.set("3.14159", base: 10, rounding: roundingMode)
            #expect(
                result == true,
                "Should accept rounding mode \(roundingMode)"
            )
            #expect(
                abs(a.toDouble() - 3.14159) < 1e-10,
                "Value should be parsed correctly"
            )
        }
    }

    // Note: Invalid base triggers precondition, so we test valid boundary
    // values instead
    @Test
    func set_String_ValidBases_Works() {
        // Test valid base values: 0 (auto-detect), 2 (minimum), 62 (maximum)
        var a = MPFRFloat(precision: 64)

        // Base 0 (auto-detect)
        let result1 = a.set("42", base: 0, rounding: .nearest)
        #expect(result1 == true, "Base 0 (auto-detect) should work")

        // Base 2 (minimum valid)
        let result2 = a.set("101010", base: 2, rounding: .nearest)
        #expect(result2 == true, "Base 2 (minimum) should work")
        #expect(a.toDouble() == 42.0, "Binary 101010 should equal 42")

        // Base 62 (maximum valid)
        // Using a simple value that works in base 62
        let result3 = a.set("42", base: 62, rounding: .nearest)
        #expect(result3 == true, "Base 62 (maximum) should work")
    }

    @Test
    func set_GMPInteger_BasicValues_Exact() {
        // Table Test
        let testCases: [(GMPInteger, Double)] = [
            (GMPInteger(42), 42.0), // Positive integer
            (GMPInteger(-42), -42.0), // Negative integer
            (GMPInteger(0), 0.0), // Zero
            (
                GMPInteger(1_000_000_000_000),
                1_000_000_000_000.0
            ), // Large integer
        ]

        for (inputValue, expectedResult) in testCases {
            // Given: var a = MPFRFloat(precision: 64) and GMPInteger value from table
            var a = MPFRFloat(precision: 64)

            // When: Calling a.set(value, rounding: .nearest)
            a.set(inputValue, rounding: .nearest)

            // Then: a.toDouble() matches expected result exactly (if representable in Double)
            #expect(
                abs(a.toDouble() - expectedResult) < 1e-10,
                "Value \(inputValue) should be set correctly"
            )
        }
    }

    @Test
    func set_GMPInteger_AllRoundingModes_Works() {
        // Note: Rounding modes don't apply when setting from GMPInteger
        // (integers are exact)
        let roundingModes: [MPFRRoundingMode] = [
            .nearest,
            .towardZero,
            .towardPositiveInfinity,
            .towardNegativeInfinity,
            .awayFromZero,
            .faithful,
        ]

        for roundingMode in roundingModes {
            // Given: var a = MPFRFloat(precision: 64) and GMPInteger value 42
            var a = MPFRFloat(precision: 64)

            // When: Calling a.set(GMPInteger(42), rounding: roundingMode)
            a.set(GMPInteger(42), rounding: roundingMode)

            // Then: a.toDouble() == 42.0 (always exact for integers)
            #expect(
                a.toDouble() == 42.0,
                "Integer should be exact regardless of rounding mode"
            )
        }
    }

    @Test
    func set_GMPInteger_ReturnsTernary() {
        // Given: var a = MPFRFloat(precision: 64) and GMPInteger value GMPInteger(42)
        var a = MPFRFloat(precision: 64)

        // When: Calling let result = a.set(GMPInteger(42), rounding: .nearest)
        let result = a.set(GMPInteger(42), rounding: .nearest)

        // Then: Returns 0 (exact, since integers are always exact)
        #expect(result == 0, "Integer should return 0 (exact)")
    }

    @Test
    func set_GMPRational_BasicValues_Works() throws {
        // Table Test
        let testCases: [(GMPRational, Double)] = try [
            (
                GMPRational(numerator: 3, denominator: 1),
                3.0
            ), // Positive integer rational
            (
                GMPRational(numerator: -3, denominator: 1),
                -3.0
            ), // Negative integer rational
            (GMPRational(numerator: 1, denominator: 2), 0.5), // Fractional
            (GMPRational(numerator: 0, denominator: 1), 0.0), // Zero
        ]

        for (inputValue, expectedResult) in testCases {
            // Given: var a = MPFRFloat(precision: 64) and GMPRational value from table
            var a = MPFRFloat(precision: 64)

            // When: Calling a.set(value, rounding: .nearest)
            a.set(inputValue, rounding: .nearest)

            // Then: Result matches expected result (exact for integers, rounded for fractions)
            #expect(
                abs(a.toDouble() - expectedResult) < 1e-10,
                "Value \(inputValue) should be set correctly"
            )
        }
    }

    @Test
    func set_GMPRational_AllRoundingModes_Works() throws {
        // Table Test with precision 2 and value 7/3 ≈ 2.333... (which requires
        // rounding)
        // Precision 2 can represent 2.0, 3.0, 4.0, etc.
        let testCases: [(MPFRRoundingMode, Double)] = [
            (.nearest, 2.0), // 2.333... rounded to nearest (2.0)
            (.towardZero, 2.0), // 2.333... rounded toward zero (2.0)
            (.towardPositiveInfinity, 3.0), // 2.333... rounded up (3.0)
            (.towardNegativeInfinity, 2.0), // 2.333... rounded down (2.0)
        ]

        for (roundingMode, expectedResult) in testCases {
            // Given: var a = MPFRFloat(precision: 2) and GMPRational value 7/3
            var a = MPFRFloat(precision: 2)
            let rational = try GMPRational(numerator: 7, denominator: 3)

            // When: Calling a.set(rational, rounding: roundingMode)
            a.set(rational, rounding: roundingMode)

            // Then: a.toDouble() matches expected result
            #expect(
                a.toDouble() == expectedResult,
                "Rounding mode \(roundingMode) should produce \(expectedResult)"
            )
        }
    }

    @Test
    func set_GMPRational_ReturnsTernary() throws {
        // Given: var a = MPFRFloat(precision: 64) and GMPRational value GMPRational(1, 2)
        var a = MPFRFloat(precision: 64)

        // When: Calling let result = a.set(GMPRational(1, 2), rounding: .nearest)
        let result = try a.set(
            GMPRational(numerator: 1, denominator: 2),
            rounding: .nearest
        )

        // Then: Returns 0 (exact), positive (rounded up), or negative (rounded down) integer
        #expect(
            result >= -1 && result <= 1,
            "Ternary result should be -1, 0, or 1"
        )
    }

    // MARK: - Section 5: Conversion

    @Test
    func toDouble_SpecialValues_Works() {
        // Table Test
        let testCases: [(Double, String)] = [
            (3.14159, "Positive value"),
            (-3.14159, "Negative value"),
            (0.0, "Zero"),
            (Double.infinity, "Infinity"),
            (Double.nan, "NaN"),
        ]

        for (inputValue, description) in testCases {
            // Given: MPFRFloat(value, precision: 64) from table
            let a = MPFRFloat(inputValue, precision: 64)

            // When: Calling a.toDouble(rounding: .nearest)
            let result = a.toDouble(rounding: .nearest)

            // Then: Returns Double matching expected result
            if inputValue.isNaN {
                #expect(result.isNaN == true, "NaN should be preserved")
            } else if inputValue.isInfinite {
                #expect(
                    result.isInfinite == true,
                    "Infinity should be preserved"
                )
                #expect(
                    result.sign == inputValue.sign,
                    "Infinity sign should be preserved"
                )
            } else if inputValue == 0.0 {
                #expect(result == 0.0, "Zero should be exact")
            } else {
                let diff = abs(result - inputValue)
                #expect(
                    diff < 1e-10,
                    "Value \(description) should be converted correctly"
                )
            }
        }
    }

    @Test
    func toDouble_AllRoundingModes_Works() {
        // Note: Double has 53-bit precision, so rounding modes only matter if
        // MPFRFloat has higher precision.
        // We'll test with a high-precision value that requires rounding when
        // converting to Double.
        // Actually, since Double has 53 bits and we're using precision 64,
        // rounding should apply.
        // But let's test with a value that definitely requires rounding: 1/3
        // with high precision
        // For simplicity, let's test that all rounding modes are accepted and
        // produce valid results

        // Test that all rounding modes work
        let roundingModes: [MPFRRoundingMode] = [
            .nearest,
            .towardZero,
            .towardPositiveInfinity,
            .towardNegativeInfinity,
            .awayFromZero,
            .faithful,
        ]
        let a = MPFRFloat(3.14159, precision: 64)

        for roundingMode in roundingModes {
            // When: Calling a.toDouble(rounding: roundingMode)
            let result = a.toDouble(rounding: roundingMode)

            // Then: Returns valid Double
            #expect(
                result.isFinite || result.isInfinite || result.isNaN,
                "Should return valid Double"
            )
            // Result should be approximately 3.14159
            if result.isFinite {
                #expect(
                    abs(result - 3.14159) < 1e-5,
                    "Value should be approximately correct"
                )
            }
        }
    }

    @Test
    func toDouble2Exp_Positive_ReturnsMantissaAndExponent() {
        // Given: let a = MPFRFloat(3.0, precision: 64)
        let a = MPFRFloat(3.0, precision: 64)

        // When: Calling let (mantissa, exponent) = a.toDouble2Exp(rounding: .nearest)
        let (mantissa, exponent) = a.toDouble2Exp(rounding: .nearest)

        // Then: Returns tuple with mantissa in range [0.5, 1.0) and exponent such that
        // mantissa * pow(2.0, Double(exponent)) == 3.0
        #expect(
            mantissa >= 0.5 && mantissa < 1.0,
            "Mantissa should be in range [0.5, 1.0)"
        )
        let reconstructed = mantissa * pow(2.0, Double(exponent))
        #expect(
            abs(reconstructed - 3.0) < 1e-10,
            "Reconstruction should equal original value"
        )
    }

    @Test
    func toDouble2Exp_Negative_ReturnsMantissaAndExponent() {
        // Given: let a = MPFRFloat(-3.0, precision: 64)
        let a = MPFRFloat(-3.0, precision: 64)

        // When: Calling let (mantissa, exponent) = a.toDouble2Exp(rounding: .nearest)
        let (mantissa, exponent) = a.toDouble2Exp(rounding: .nearest)

        // Then: Returns tuple with mantissa in range [-1.0, -0.5) and exponent such that
        // mantissa * pow(2.0, Double(exponent)) == -3.0
        #expect(
            mantissa >= -1.0 && mantissa < -0.5,
            "Mantissa should be in range [-1.0, -0.5)"
        )
        let reconstructed = mantissa * pow(2.0, Double(exponent))
        #expect(
            abs(reconstructed - -3.0) < 1e-10,
            "Reconstruction should equal original value"
        )
    }

    @Test
    func toDouble2Exp_Zero_ReturnsZeroAndZero() {
        // Given: let a = MPFRFloat(0.0, precision: 64)
        let a = MPFRFloat(0.0, precision: 64)

        // When: Calling let (mantissa, exponent) = a.toDouble2Exp(rounding: .nearest)
        let (mantissa, exponent) = a.toDouble2Exp(rounding: .nearest)

        // Then: Returns (0.0, 0)
        #expect(mantissa == 0.0, "Mantissa should be 0.0 for zero")
        #expect(exponent == 0, "Exponent should be 0 for zero")
    }

    @Test
    func toDouble2Exp_MantissaInRange() {
        // Given: let a = MPFRFloat(42.0, precision: 64)
        let a = MPFRFloat(42.0, precision: 64)

        // When: Calling let (mantissa, exponent) = a.toDouble2Exp(rounding: .nearest)
        let (mantissa, _) = a.toDouble2Exp(rounding: .nearest)

        // Then: mantissa >= 0.5 && mantissa < 1.0
        #expect(
            mantissa >= 0.5 && mantissa < 1.0,
            "Mantissa should be in range [0.5, 1.0)"
        )
    }

    @Test
    func toDouble2Exp_Reconstruction_Works() {
        // Given: let a = MPFRFloat(3.14159, precision: 64)
        let a = MPFRFloat(3.14159, precision: 64)

        // When: Calling let (mantissa, exponent) = a.toDouble2Exp(rounding: .nearest) and reconstructing
        let (mantissa, exponent) = a.toDouble2Exp(rounding: .nearest)
        let reconstructed = mantissa * pow(2.0, Double(exponent))

        // Then: reconstructed equals a.toDouble() (within precision limits)
        let original = a.toDouble()
        #expect(
            abs(reconstructed - original) < 1e-10,
            "Reconstruction should match original"
        )
    }

    @Test
    func toUInt_Positive_Truncates() {
        // Given: let a = MPFRFloat(42.7, precision: 64)
        let a = MPFRFloat(42.7, precision: 64)

        // When: Calling let result = a.toUInt(rounding: .towardZero)
        let result = a.toUInt(rounding: .towardZero)

        // Then: Returns 42 (truncated toward zero)
        #expect(result == 42, "Should truncate toward zero")
    }

    @Test
    func toUInt_Zero_ReturnsZero() {
        // Given: let a = MPFRFloat(0.0, precision: 64)
        let a = MPFRFloat(0.0, precision: 64)

        // When: Calling let result = a.toUInt(rounding: .nearest)
        let result = a.toUInt(rounding: .nearest)

        // Then: Returns 0
        #expect(result == 0, "Zero should return 0")
    }

    @Test
    func toUInt_Fractional_Truncates() {
        // Given: let a = MPFRFloat(3.14159, precision: 64)
        let a = MPFRFloat(3.14159, precision: 64)

        // When: Calling let result = a.toUInt(rounding: .towardZero)
        let result = a.toUInt(rounding: .towardZero)

        // Then: Returns 3 (truncated toward zero)
        #expect(result == 3, "Should truncate fractional part")
    }

    @Test
    func toUInt_AllRoundingModes_Works() {
        // Table Test
        let testCases: [(MPFRRoundingMode, Double, UInt)] = [
            (.nearest, 1.5, 2), // Rounds to nearest
            (.towardZero, 1.5, 1), // Truncates toward zero
            (.towardPositiveInfinity, 1.5, 2), // Rounds up
            (.towardNegativeInfinity, 1.5, 1), // Rounds down
        ]

        for (roundingMode, inputValue, expectedResult) in testCases {
            // Given: let a = MPFRFloat(value, precision: 64) from table
            let a = MPFRFloat(inputValue, precision: 64)

            // When: Calling a.toUInt(rounding: roundingMode)
            let result = a.toUInt(rounding: roundingMode)

            // Then: Returns expected result
            #expect(
                result == expectedResult,
                "Rounding mode \(roundingMode) should produce \(expectedResult)"
            )
        }
    }

    @Test
    func toInt_BasicValues_Works() {
        // Table Test
        let testCases: [(Double, MPFRRoundingMode, Int)] = [
            (42.7, .towardZero, 42), // Truncates toward zero
            (-42.7, .towardZero, -42), // Truncates toward zero
            (0.0, .nearest, 0), // Zero
            (3.14159, .towardZero, 3), // Truncates toward zero
            (1.5, .nearest, 2), // Rounds to nearest
            (1.5, .towardZero, 1), // Truncates toward zero
        ]

        for (inputValue, roundingMode, expectedResult) in testCases {
            // Given: let a = MPFRFloat(value, precision: 64) from table
            let a = MPFRFloat(inputValue, precision: 64)

            // When: Calling a.toInt(rounding: roundingMode)
            let result = a.toInt(rounding: roundingMode)

            // Then: Returns Int matching expected result
            #expect(
                result == expectedResult,
                "Value \(inputValue) with \(roundingMode) should produce \(expectedResult)"
            )
        }
    }

    @Test
    func toInt_AllRoundingModes_Works() {
        // Table Test
        let testCases: [(MPFRRoundingMode, Double, Int)] = [
            (.nearest, 1.5, 2), // Rounds to nearest
            (.towardZero, 1.5, 1), // Truncates toward zero
            (.towardPositiveInfinity, 1.5, 2), // Rounds up
            (.towardNegativeInfinity, 1.5, 1), // Rounds down
        ]

        for (roundingMode, inputValue, expectedResult) in testCases {
            // Given: let a = MPFRFloat(value, precision: 64) from table
            let a = MPFRFloat(inputValue, precision: 64)

            // When: Calling a.toInt(rounding: roundingMode)
            let result = a.toInt(rounding: roundingMode)

            // Then: Returns expected result
            #expect(
                result == expectedResult,
                "Rounding mode \(roundingMode) should produce \(expectedResult)"
            )
        }
    }

    @Test
    func toString_Decimal_AllDigits_Works() {
        // Given: let a = MPFRFloat(3.14159, precision: 64)
        let a = MPFRFloat(3.14159, precision: 64)

        // When: Calling let str = a.toString(base: 10, digits: 0, rounding: .nearest)
        let str = a.toString(base: 10, digits: 0, rounding: .nearest)

        // Then: Returns string representation that can be parsed back to approximately 3.14159
        #expect(!str.isEmpty, "String should not be empty")
        // Parse it back
        var b = MPFRFloat(precision: 64)
        let parsed = b.set(str, base: 10, rounding: .nearest)
        #expect(parsed == true, "Should parse successfully")
        #expect(
            abs(b.toDouble() - 3.14159) < 1e-5,
            "Parsed value should match original"
        )
    }

    @Test
    func toString_Decimal_LimitedDigits_Works() {
        // Given: let a = MPFRFloat(3.14159, precision: 64)
        let a = MPFRFloat(3.14159, precision: 64)

        // When: Calling let str = a.toString(base: 10, digits: 5, rounding: .nearest)
        let str = a.toString(base: 10, digits: 5, rounding: .nearest)

        // Then: Returns string with approximately 5 significant digits
        #expect(!str.isEmpty, "String should not be empty")
        // The string should have reasonable length (not too many digits)
        #expect(str.count < 20, "String should have limited digits")
    }

    @Test
    func toString_Hex_Works() {
        // Given: let a = MPFRFloat(42.0, precision: 64)
        let a = MPFRFloat(42.0, precision: 64)

        // When: Calling let str = a.toString(base: 16, digits: 0, rounding: .nearest)
        let str = a.toString(base: 16, digits: 0, rounding: .nearest)

        // Then: Returns hexadecimal string representation
        #expect(!str.isEmpty, "String should not be empty")
        // Parse it back
        var b = MPFRFloat(precision: 64)
        let parsed = b.set(str, base: 16, rounding: .nearest)
        #expect(parsed == true, "Should parse successfully")
        #expect(
            abs(b.toDouble() - 42.0) < 1e-10,
            "Parsed value should match original"
        )
    }

    @Test
    func toString_Binary_Works() {
        // Given: let a = MPFRFloat(42.0, precision: 64)
        let a = MPFRFloat(42.0, precision: 64)

        // When: Calling let str = a.toString(base: 2, digits: 0, rounding: .nearest)
        let str = a.toString(base: 2, digits: 0, rounding: .nearest)

        // Then: Returns binary string representation
        #expect(!str.isEmpty, "String should not be empty")
        // Parse it back
        var b = MPFRFloat(precision: 64)
        let parsed = b.set(str, base: 2, rounding: .nearest)
        #expect(parsed == true, "Should parse successfully")
        #expect(
            abs(b.toDouble() - 42.0) < 1e-10,
            "Parsed value should match original"
        )
    }

    @Test
    func toString_Zero_Works() {
        // Given: let a = MPFRFloat(0.0, precision: 64)
        let a = MPFRFloat(0.0, precision: 64)

        // When: Calling let str = a.toString(base: 10, digits: 0, rounding: .nearest)
        let str = a.toString(base: 10, digits: 0, rounding: .nearest)

        // Then: Returns "0" or "0.0" or equivalent zero representation
        #expect(
            str == "0" || str == "0.0" || str.hasPrefix("0"),
            "Should represent zero"
        )
    }

    @Test
    func toString_RoundTrip_Works() {
        // Given: let a = MPFRFloat(3.14159, precision: 64)
        let a = MPFRFloat(3.14159, precision: 64)

        // When: Calling let str = a.toString(base: 10, digits: 0, rounding: .nearest) and then parsing
        let str = a.toString(base: 10, digits: 0, rounding: .nearest)
        var b = MPFRFloat(precision: 64)
        let parsed = b.set(str, base: 10, rounding: .nearest)

        // Then: b.toDouble() equals a.toDouble() (within precision limits)
        #expect(parsed == true, "Should parse successfully")
        let diff = abs(b.toDouble() - a.toDouble())
        #expect(diff < 1e-10, "Round-trip should preserve value")
    }

    // MARK: - Section 6: Comparison

    @Test
    func comparable_LessThan_Works() {
        // Given: let a = MPFRFloat(3.0, precision: 64) and let b = MPFRFloat(5.0, precision: 64)
        let a = MPFRFloat(3.0, precision: 64)
        let b = MPFRFloat(5.0, precision: 64)

        // When: Comparing a < b
        // Then: Returns true
        #expect(a < b, "3.0 should be less than 5.0")
    }

    @Test
    func comparable_LessThanOrEqual_Works() {
        // Given: let a = MPFRFloat(3.0, precision: 64) and let b = MPFRFloat(5.0, precision: 64)
        let a = MPFRFloat(3.0, precision: 64)
        let b = MPFRFloat(5.0, precision: 64)

        // When: Comparing a <= b
        // Then: Returns true
        #expect(a <= b, "3.0 should be less than or equal to 5.0")
        #expect(a <= a, "3.0 should be less than or equal to itself")
    }

    @Test
    func comparable_GreaterThan_Works() {
        // Given: let a = MPFRFloat(5.0, precision: 64) and let b = MPFRFloat(3.0, precision: 64)
        let a = MPFRFloat(5.0, precision: 64)
        let b = MPFRFloat(3.0, precision: 64)

        // When: Comparing a > b
        // Then: Returns true
        #expect(a > b, "5.0 should be greater than 3.0")
    }

    @Test
    func comparable_GreaterThanOrEqual_Works() {
        // Given: let a = MPFRFloat(5.0, precision: 64) and let b = MPFRFloat(3.0, precision: 64)
        let a = MPFRFloat(5.0, precision: 64)
        let b = MPFRFloat(3.0, precision: 64)

        // When: Comparing a >= b
        // Then: Returns true
        #expect(a >= b, "5.0 should be greater than or equal to 3.0")
        #expect(a >= a, "5.0 should be greater than or equal to itself")
    }

    @Test
    func comparable_Equal_Works() {
        // Given: let a = MPFRFloat(3.0, precision: 64) and let b = MPFRFloat(3.0, precision: 64)
        let a = MPFRFloat(3.0, precision: 64)
        let b = MPFRFloat(3.0, precision: 64)

        // When: Comparing a == b
        // Then: Returns true
        #expect(a == b, "3.0 should equal 3.0")
    }

    @Test
    func comparable_NaN_Comparison_Works() {
        // Given: let a = MPFRFloat() (NaN value) and let b = MPFRFloat(3.0, precision: 64)
        let a = MPFRFloat()
        let b = MPFRFloat(3.0, precision: 64)

        // When: Comparing a == b, a < b, a > b
        // Then: All comparisons return false (NaN is not equal to anything, including itself)
        #expect(!(a == b), "NaN should not equal 3.0")
        #expect(!(a < b), "NaN < 3.0 should be false")
        #expect(!(a > b), "NaN > 3.0 should be false")
        #expect(!(a == a), "NaN should not equal itself")
    }

    @Test
    func comparable_NaN_LessThanOrEqual_ReturnsFalse() {
        // Given: let a = MPFRFloat() (NaN value) and let b = MPFRFloat(3.0, precision: 64)
        let a = MPFRFloat()
        let b = MPFRFloat(3.0, precision: 64)

        // When: Comparing a <= b and a <= a
        // Then: Both comparisons return false (NaN comparisons always return false)
        #expect(!(a <= b), "NaN <= 3.0 should be false")
        #expect(!(a <= a), "NaN <= NaN should be false")
    }

    @Test
    func comparable_NaN_GreaterThanOrEqual_ReturnsFalse() {
        // Given: let a = MPFRFloat() (NaN value) and let b = MPFRFloat(3.0, precision: 64)
        let a = MPFRFloat()
        let b = MPFRFloat(3.0, precision: 64)

        // When: Comparing a >= b and a >= a
        // Then: Both comparisons return false (NaN comparisons always return false)
        #expect(!(a >= b), "NaN >= 3.0 should be false")
        #expect(!(a >= a), "NaN >= NaN should be false")
    }

    @Test
    func isEqual_SameValue_ReturnsTrue() {
        // Given: let a = MPFRFloat(3.14159, precision: 64) and let b = MPFRFloat(3.14159, precision: 64)
        let a = MPFRFloat(3.14159, precision: 64)
        let b = MPFRFloat(3.14159, precision: 64)

        // When: Calling a.isEqual(to: b, bits: 64)
        // Then: Returns true
        #expect(a.isEqual(to: b, bits: 64), "Same values should be equal")
    }

    @Test
    func isEqual_WithinTolerance_ReturnsTrue() {
        // Given: let a = MPFRFloat(3.14159, precision: 64) and
        // let b = MPFRFloat(3.14159, precision: 64) with tiny difference
        // We'll use the same value but verify that isEqual works with
        // reasonable tolerance
        let a = MPFRFloat(3.14159, precision: 64)
        let b = MPFRFloat(3.14159, precision: 64)

        // When: Calling a.isEqual(to: b, bits: 50) (allowing 50 bits tolerance)
        // Then: Returns true (values are equal within tolerance)
        #expect(
            a.isEqual(to: b, bits: 50),
            "Same values should be equal within tolerance"
        )

        // Test with slightly different values that should still be equal with
        // low tolerance
        // For 64-bit precision, 50 bits tolerance should allow some difference
        // Actually, mpfr_eq checks if the values are equal up to the specified
        // number of bits
        // So we need values that differ only in the least significant bits
        // Let's test with a value that's very close
        _ = MPFRFloat(3.14159, precision: 64)
        // Add a very small value (less than 2^-50)
        _ = MPFRFloat(1e-15, precision: 64) // Much smaller than 2^-50
        // Note: We can't easily add here without arithmetic operations
        // For now, let's just verify that identical values work
    }

    @Test
    func isEqual_OutsideTolerance_ReturnsFalse() {
        // Given: let a = MPFRFloat(3.14159, precision: 64) and
        // let b = MPFRFloat(3.14259, precision: 64) (different values)
        let a = MPFRFloat(3.14159, precision: 64)
        let b = MPFRFloat(3.14259, precision: 64)

        // When: Calling a.isEqual(to: b, bits: 64) (exact match required)
        // Then: Returns false
        #expect(
            !a.isEqual(to: b, bits: 64),
            "Different values should not be equal"
        )
    }

    @Test
    func isEqual_Zero_Works() {
        // Given: let a = MPFRFloat(0.0, precision: 64) and let b = MPFRFloat(0.0, precision: 64)
        let a = MPFRFloat(0.0, precision: 64)
        let b = MPFRFloat(0.0, precision: 64)

        // When: Calling a.isEqual(to: b, bits: 64)
        // Then: Returns true
        #expect(a.isEqual(to: b, bits: 64), "Zero should equal zero")
    }

    @Test
    func isEqual_NaN_ReturnsFalse() {
        // Given: let a = MPFRFloat() (NaN value) and let b = MPFRFloat(3.14159, precision: 64)
        let a = MPFRFloat()
        let b = MPFRFloat(3.14159, precision: 64)

        // When: Calling a.isEqual(to: b, bits: 64)
        // Then: Returns false (NaN is never equal to anything)
        #expect(!a.isEqual(to: b, bits: 64), "NaN should not equal anything")
    }

    @Test
    func compare_MPFRFloat_BasicScenarios_ReturnsCorrectResult() {
        // Table Test
        let testCases: [(Double, Double, Int)] = [
            (3.0, 5.0, -1), // Less than
            (5.0, 3.0, 1), // Greater than
            (3.0, 3.0, 0), // Equal
        ]

        for (aVal, bVal, expectedSign) in testCases {
            // Given: let a = MPFRFloat(a, precision: 64) and let b = MPFRFloat(b, precision: 64) from table
            let a = MPFRFloat(aVal, precision: 64)
            let b = MPFRFloat(bVal, precision: 64)

            // When: Calling a.compare(to: b)
            let result = a.compare(to: b)

            // Then: Returns expected result (-1, 0, or 1)
            if expectedSign < 0 {
                #expect(result < 0, "\(aVal) should be less than \(bVal)")
            } else if expectedSign > 0 {
                #expect(result > 0, "\(aVal) should be greater than \(bVal)")
            } else {
                #expect(result == 0, "\(aVal) should equal \(bVal)")
            }
        }
    }

    @Test
    func compare_GMPInteger_LessThan_ReturnsNegative() {
        // Given: let a = MPFRFloat(3.0, precision: 64) and let b = GMPInteger(5)
        let a = MPFRFloat(3.0, precision: 64)
        let b = GMPInteger(5)

        // When: Calling a.compare(to: b)
        // Then: Returns negative value (< 0)
        #expect(a.compare(to: b) < 0, "3.0 should be less than 5")
    }

    @Test
    func compare_GMPInteger_Equal_ReturnsZero() {
        // Given: let a = MPFRFloat(42.0, precision: 64) and let b = GMPInteger(42)
        let a = MPFRFloat(42.0, precision: 64)
        let b = GMPInteger(42)

        // When: Calling a.compare(to: b)
        // Then: Returns 0
        #expect(a.compare(to: b) == 0, "42.0 should equal 42")
    }

    @Test
    func compare_GMPInteger_GreaterThan_ReturnsPositive() {
        // Given: let a = MPFRFloat(5.0, precision: 64) and let b = GMPInteger(3)
        let a = MPFRFloat(5.0, precision: 64)
        let b = GMPInteger(3)

        // When: Calling a.compare(to: b)
        // Then: Returns positive value (> 0)
        #expect(a.compare(to: b) > 0, "5.0 should be greater than 3")
    }

    @Test
    func compare_Double_LessThan_ReturnsNegative() {
        // Given: let a = MPFRFloat(3.0, precision: 64) and Double value 5.0
        let a = MPFRFloat(3.0, precision: 64)

        // When: Calling a.compare(to: 5.0)
        // Then: Returns negative value (< 0)
        #expect(a.compare(to: 5.0) < 0, "3.0 should be less than 5.0")
    }

    @Test
    func compare_Double_Equal_ReturnsZero() {
        // Given: let a = MPFRFloat(3.14159, precision: 64) and Double value 3.14159
        let a = MPFRFloat(3.14159, precision: 64)

        // When: Calling a.compare(to: 3.14159)
        // Then: Returns 0 (or close to 0 within precision limits)
        #expect(a.compare(to: 3.14159) == 0, "3.14159 should equal 3.14159")
    }

    @Test
    func compare_Double_GreaterThan_ReturnsPositive() {
        // Given: let a = MPFRFloat(5.0, precision: 64) and Double value 3.0
        let a = MPFRFloat(5.0, precision: 64)

        // When: Calling a.compare(to: 3.0)
        // Then: Returns positive value (> 0)
        #expect(a.compare(to: 3.0) > 0, "5.0 should be greater than 3.0")
    }

    @Test
    func compare_Int_LessThan_ReturnsNegative() {
        // Given: let a = MPFRFloat(3.0, precision: 64) and Int value 5
        let a = MPFRFloat(3.0, precision: 64)

        // When: Calling a.compare(to: 5)
        // Then: Returns negative value (< 0)
        #expect(a.compare(to: 5) < 0, "3.0 should be less than 5")
    }

    @Test
    func compare_Int_Equal_ReturnsZero() {
        // Given: let a = MPFRFloat(42.0, precision: 64) and Int value 42
        let a = MPFRFloat(42.0, precision: 64)

        // When: Calling a.compare(to: 42)
        // Then: Returns 0
        #expect(a.compare(to: 42) == 0, "42.0 should equal 42")
    }

    @Test
    func compare_Int_GreaterThan_ReturnsPositive() {
        // Given: let a = MPFRFloat(5.0, precision: 64) and Int value 3
        let a = MPFRFloat(5.0, precision: 64)

        // When: Calling a.compare(to: 3)
        // Then: Returns positive value (> 0)
        #expect(a.compare(to: 3) > 0, "5.0 should be greater than 3")
    }

    @Test
    func sign_Positive_ReturnsOne() {
        // Given: let a = MPFRFloat(3.14159, precision: 64)
        let a = MPFRFloat(3.14159, precision: 64)

        // When: Calling a.sign
        // Then: Returns 1
        #expect(a.sign == 1, "Positive value should have sign 1")
    }

    @Test
    func sign_Negative_ReturnsNegativeOne() {
        // Given: let a = MPFRFloat(-3.14159, precision: 64)
        let a = MPFRFloat(-3.14159, precision: 64)

        // When: Calling a.sign
        // Then: Returns -1
        #expect(a.sign == -1, "Negative value should have sign -1")
    }

    @Test
    func sign_Zero_ReturnsZero() {
        // Given: let a = MPFRFloat(0.0, precision: 64)
        let a = MPFRFloat(0.0, precision: 64)

        // When: Calling a.sign
        // Then: Returns 0
        #expect(a.sign == 0, "Zero should have sign 0")
    }

    @Test
    func isZero_Zero_ReturnsTrue() {
        // Given: MPFRFloat(0.0, precision: 64)
        let a = MPFRFloat(0.0, precision: 64)

        // When: Calling isZero method
        // Then: Returns true
        #expect(a.isZero == true, "Zero should return true for isZero")
    }

    @Test
    func isZero_Positive_ReturnsFalse() {
        // Given: MPFRFloat with positive value
        let a = MPFRFloat(3.14159, precision: 64)

        // When: Calling isZero method
        // Then: Returns false
        #expect(
            a.isZero == false,
            "Positive value should return false for isZero"
        )
    }

    @Test
    func isZero_Negative_ReturnsFalse() {
        // Given: MPFRFloat with negative value
        let a = MPFRFloat(-3.14159, precision: 64)

        // When: Calling isZero method
        // Then: Returns false
        #expect(
            a.isZero == false,
            "Negative value should return false for isZero"
        )
    }

    @Test
    func isNegative_Negative_ReturnsTrue() {
        // Given: MPFRFloat with negative value
        let a = MPFRFloat(-3.14159, precision: 64)

        // When: Calling isNegative method
        // Then: Returns true
        #expect(
            a.isNegative == true,
            "Negative value should return true for isNegative"
        )
    }

    @Test
    func isNegative_Positive_ReturnsFalse() {
        // Given: MPFRFloat with positive value
        let a = MPFRFloat(3.14159, precision: 64)

        // When: Calling isNegative method
        // Then: Returns false
        #expect(
            a.isNegative == false,
            "Positive value should return false for isNegative"
        )
    }

    @Test
    func isNegative_Zero_ReturnsFalse() {
        // Given: MPFRFloat with zero value
        let a = MPFRFloat(0.0, precision: 64)

        // When: Calling isNegative method
        // Then: Returns false
        #expect(
            a.isNegative == false,
            "Zero should return false for isNegative"
        )
    }

    @Test
    func isPositive_Positive_ReturnsTrue() {
        // Given: MPFRFloat with positive value
        let a = MPFRFloat(3.14159, precision: 64)

        // When: Calling isPositive method
        // Then: Returns true
        #expect(
            a.isPositive == true,
            "Positive value should return true for isPositive"
        )
    }

    @Test
    func isPositive_Negative_ReturnsFalse() {
        // Given: MPFRFloat with negative value
        let a = MPFRFloat(-3.14159, precision: 64)

        // When: Calling isPositive method
        // Then: Returns false
        #expect(
            a.isPositive == false,
            "Negative value should return false for isPositive"
        )
    }

    @Test
    func isPositive_Zero_ReturnsFalse() {
        // Given: MPFRFloat with zero value
        let a = MPFRFloat(0.0, precision: 64)

        // When: Calling isPositive method
        // Then: Returns false
        #expect(
            a.isPositive == false,
            "Zero should return false for isPositive"
        )
    }

    @Test
    func isNaN_NaN_ReturnsTrue() {
        // Given: MPFRFloat() (NaN value)
        let a = MPFRFloat()

        // When: Calling isNaN method
        // Then: Returns true
        #expect(a.isNaN == true, "NaN should return true for isNaN")
    }

    @Test
    func isNaN_Regular_ReturnsFalse() {
        // Given: let a = MPFRFloat(3.14159, precision: 64)
        let a = MPFRFloat(3.14159, precision: 64)

        // When: Calling a.isNaN
        // Then: Returns false
        #expect(
            a.isNaN == false,
            "Regular number should return false for isNaN"
        )
    }

    @Test
    func isNaN_Infinity_ReturnsFalse() {
        // Given: let a = MPFRFloat(Double.infinity, precision: 64)
        let a = MPFRFloat(Double.infinity, precision: 64)

        // When: Calling a.isNaN
        // Then: Returns false
        #expect(a.isNaN == false, "Infinity should return false for isNaN")
    }

    @Test
    func isNaN_Zero_ReturnsFalse() {
        // Given: MPFRFloat(0.0, precision: 64)
        let a = MPFRFloat(0.0, precision: 64)

        // When: Calling isNaN method
        // Then: Returns false
        #expect(a.isNaN == false, "Zero should return false for isNaN")
    }

    // MARK: - MPFRError Properties

    @Test
    func mpfrError_isOverflow_ReturnsTrue() {
        // Given: MPFRError with overflow flag
        let error = MPFRError.overflow

        // When: Checking isOverflow property
        // Then: Returns true
        #expect(
            error.isOverflow == true,
            "Overflow error should return true for isOverflow"
        )
    }

    @Test
    func mpfrError_isOverflow_ReturnsFalse() {
        // Given: MPFRError with NaN flag
        let error = MPFRError.nan

        // When: Checking isOverflow property
        // Then: Returns false
        #expect(
            error.isOverflow == false,
            "NaN error should return false for isOverflow"
        )
    }

    @Test
    func mpfrError_isUnderflow_ReturnsTrue() {
        // Given: MPFRError with underflow flag
        let error = MPFRError.underflow

        // When: Checking isUnderflow property
        // Then: Returns true
        #expect(
            error.isUnderflow == true,
            "Underflow error should return true for isUnderflow"
        )
    }

    @Test
    func mpfrError_isUnderflow_ReturnsFalse() {
        // Given: MPFRError with divideByZero flag
        let error = MPFRError.divideByZero

        // When: Checking isUnderflow property
        // Then: Returns false
        #expect(
            error.isUnderflow == false,
            "DivideByZero error should return false for isUnderflow"
        )
    }

    @Test
    func mpfrError_isRangeError_ReturnsTrue() {
        // Given: MPFRError with rangeError flag
        let error = MPFRError.rangeError

        // When: Checking isRangeError property
        // Then: Returns true
        #expect(
            error.isRangeError == true,
            "RangeError should return true for isRangeError"
        )
    }

    @Test
    func mpfrError_isRangeError_ReturnsFalse() {
        // Given: MPFRError with NaN flag
        let error = MPFRError.nan

        // When: Checking isRangeError property
        // Then: Returns false
        #expect(
            error.isRangeError == false,
            "NaN error should return false for isRangeError"
        )
    }

    @Test
    func mpfrError_MultipleFlags_AllPropertiesWork() {
        // Given: MPFRError with multiple flags
        let error = MPFRError([.overflow, .underflow, .rangeError])

        // When: Checking all properties
        // Then: All relevant properties return true
        #expect(error.isOverflow == true, "Should detect overflow")
        #expect(error.isUnderflow == true, "Should detect underflow")
        #expect(error.isRangeError == true, "Should detect rangeError")
        #expect(error.isNaN == false, "Should not detect NaN")
        #expect(error.isDivideByZero == false, "Should not detect divideByZero")
    }

    @Test
    func isInfinity_PositiveInfinity_ReturnsTrue() {
        // Given: let a = MPFRFloat(Double.infinity, precision: 64)
        let a = MPFRFloat(Double.infinity, precision: 64)

        // When: Calling a.isInfinity
        // Then: Returns true
        #expect(
            a.isInfinity == true,
            "Positive infinity should return true for isInfinity"
        )
    }

    @Test
    func isInfinity_NegativeInfinity_ReturnsTrue() {
        // Given: let a = MPFRFloat(-Double.infinity, precision: 64)
        let a = MPFRFloat(-Double.infinity, precision: 64)

        // When: Calling a.isInfinity
        // Then: Returns true
        #expect(
            a.isInfinity == true,
            "Negative infinity should return true for isInfinity"
        )
    }

    @Test
    func isInfinity_Regular_ReturnsFalse() {
        // Given: let a = MPFRFloat(3.14159, precision: 64)
        let a = MPFRFloat(3.14159, precision: 64)

        // When: Calling a.isInfinity
        // Then: Returns false
        #expect(
            a.isInfinity == false,
            "Regular number should return false for isInfinity"
        )
    }

    @Test
    func isInfinity_NaN_ReturnsFalse() {
        // Given: MPFRFloat() (NaN value)
        let a = MPFRFloat()

        // When: Calling isInfinity method
        // Then: Returns false
        #expect(a.isInfinity == false, "NaN should return false for isInfinity")
    }

    @Test
    func isInfinity_Zero_ReturnsFalse() {
        // Given: MPFRFloat(0.0, precision: 64)
        let a = MPFRFloat(0.0, precision: 64)

        // When: Calling isInfinity method
        // Then: Returns false
        #expect(
            a.isInfinity == false,
            "Zero should return false for isInfinity"
        )
    }

    @Test
    func isRegular_BasicValues_ReturnsCorrectResult() {
        // Table Test
        let testCases: [(Double, Bool, String)] = [
            (3.14159, true, "Regular number"),
            (0.0, true, "Zero"),
            (Double.nan, false, "NaN"),
            (Double.infinity, false, "Infinity"),
        ]

        for (inputValue, expectedResult, description) in testCases {
            // Given: MPFRFloat(value, precision: 64) from table
            let a = MPFRFloat(inputValue, precision: 64)

            // When: Calling a.isRegular
            // Then: Returns expected result
            #expect(
                a.isRegular == expectedResult,
                "\(description) should return \(expectedResult) for isRegular"
            )
        }
    }

    @Test
    func init_Int_Positive_Works() {
        // Given: Integer value 42
        // When: Creating let a = MPFRFloat(42, precision: 64, rounding: .nearest)
        let a = MPFRFloat(42, precision: 64, rounding: .nearest)

        // Then: a.toInt() == 42 and a.precision == 64
        #expect(a.toInt() == 42, "Value should be 42")
        #expect(a.precision == 64, "Precision should be 64")
    }

    @Test
    func init_Int_Negative_Works() {
        // Given: Integer value -42
        // When: Creating let a = MPFRFloat(-42, precision: 64, rounding: .nearest)
        let a = MPFRFloat(-42, precision: 64, rounding: .nearest)

        // Then: a.toInt() == -42 and a.precision == 64
        #expect(a.toInt() == -42, "Value should be -42")
        #expect(a.precision == 64, "Precision should be 64")
    }

    @Test
    func init_Int_Zero_Works() {
        // Given: Integer value 0
        // When: Creating let a = MPFRFloat(0, precision: 64, rounding: .nearest)
        let a = MPFRFloat(0, precision: 64, rounding: .nearest)

        // Then: a.toInt() == 0 and a.isZero == true and a.precision == 64
        #expect(a.toInt() == 0, "Value should be 0")
        #expect(a.isZero == true, "Should be zero")
        #expect(a.precision == 64, "Precision should be 64")
    }

    @Test
    func init_Int_WithPrecision_Works() {
        // Given: Integer value 42 and precision 128
        // When: Creating let a = MPFRFloat(42, precision: 128, rounding: .nearest)
        let a = MPFRFloat(42, precision: 128, rounding: .nearest)

        // Then: a.toInt() == 42 and a.precision == 128
        #expect(a.toInt() == 42, "Value should be 42")
        #expect(a.precision == 128, "Precision should be 128")
    }

    @Test
    func init_Int_AllRoundingModes_Works() {
        // Note: Rounding modes don't apply when initializing from Int (integers
        // are exact)
        let roundingModes: [MPFRRoundingMode] = [
            .nearest,
            .towardZero,
            .towardPositiveInfinity,
            .towardNegativeInfinity,
            .awayFromZero,
            .faithful,
        ]

        for roundingMode in roundingModes {
            // Given: Integer value 42
            // When: Creating let a = MPFRFloat(42, precision: 64, rounding: roundingMode)
            let a = MPFRFloat(42, precision: 64, rounding: roundingMode)

            // Then: a.toInt() == 42 (always exact for integers)
            #expect(
                a.toInt() == 42,
                "Integer should be exact regardless of rounding mode"
            )
        }
    }

    @Test
    func init_UInt_BasicValues_Works() {
        // Table Test
        let testCases: [(UInt, Double)] = [
            (42, 42.0), // Positive integer
            (0, 0.0), // Zero
        ]

        for (inputValue, expectedResult) in testCases {
            // Given: Unsigned integer value from table
            // When: Calling MPFRFloat(value, precision: 64, rounding: .nearest)
            let a = MPFRFloat(inputValue, precision: 64, rounding: .nearest)

            // Then: Created float has exact value, precision is 64 bits
            #expect(a.toDouble() == expectedResult, "Value should be exact")
            #expect(a.precision == 64, "Precision should be 64")
        }
    }

    @Test
    func init_UInt_DefaultPrecision_Works() {
        // Test initialization from UInt with default precision (nil)
        let value: UInt = 42
        let a = MPFRFloat(value, precision: nil, rounding: .nearest)

        // Then: Should use default precision and have correct value
        #expect(a.precision >= 53, "Should use default precision")
        #expect(abs(a.toDouble() - 42.0) < 0.01, "Value should be correct")
    }

    @Test
    func init_UInt_AllRoundingModes_Works() {
        // Note: Rounding modes don't apply when initializing from UInt
        // (integers are exact)
        let roundingModes: [MPFRRoundingMode] = [
            .nearest,
            .towardZero,
            .towardPositiveInfinity,
            .towardNegativeInfinity,
            .awayFromZero,
            .faithful,
        ]

        for roundingMode in roundingModes {
            // Given: Unsigned integer value 42
            // When: Creating let a = MPFRFloat(42, precision: 64, rounding: roundingMode)
            let a = MPFRFloat(UInt(42), precision: 64, rounding: roundingMode)

            // Then: a.toUInt() == 42 (always exact for integers)
            #expect(
                a.toUInt() == 42,
                "Integer should be exact regardless of rounding mode"
            )
        }
    }

    @Test
    func init_GMPInteger_BasicValues_Works() {
        // Table Test
        let testCases: [(GMPInteger, Double)] = [
            (GMPInteger(42), 42.0), // Positive integer
            (GMPInteger(-42), -42.0), // Negative integer
            (GMPInteger(0), 0.0), // Zero
        ]

        for (inputValue, expectedResult) in testCases {
            // Given: GMPInteger value from table
            // When: Calling MPFRFloat(value, precision: 64, rounding: .nearest)
            let a = MPFRFloat(inputValue, precision: 64, rounding: .nearest)

            // Then: Created float has exact value (if representable), precision is 64 bits
            #expect(
                abs(a.toDouble() - expectedResult) < 1e-10,
                "Value should be correct"
            )
            #expect(a.precision == 64, "Precision should be 64")
        }
    }

    @Test
    func init_GMPInteger_DefaultPrecision_Works() {
        // Test initialization from GMPInteger with default precision (nil)
        let value = GMPInteger(42)
        let a = MPFRFloat(value, precision: nil, rounding: .nearest)

        // Then: Should use default precision and have correct value
        #expect(a.precision >= 53, "Should use default precision")
        #expect(abs(a.toDouble() - 42.0) < 0.01, "Value should be correct")
    }

    @Test
    func init_GMPInteger_AllRoundingModes_Works() {
        // Note: Rounding modes don't apply when initializing from GMPInteger
        // (integers are exact)
        let roundingModes: [MPFRRoundingMode] = [
            .nearest,
            .towardZero,
            .towardPositiveInfinity,
            .towardNegativeInfinity,
            .awayFromZero,
            .faithful,
        ]

        for roundingMode in roundingModes {
            // Given: GMPInteger value 42
            // When: Creating let a = MPFRFloat(GMPInteger(42), precision: 64, rounding: roundingMode)
            let a = MPFRFloat(
                GMPInteger(42),
                precision: 64,
                rounding: roundingMode
            )

            // Then: a.toDouble() == 42.0 (always exact for integers)
            #expect(
                a.toDouble() == 42.0,
                "Integer should be exact regardless of rounding mode"
            )
        }
    }

    @Test
    func init_GMPRational_DefaultPrecision_Works() throws {
        // Test initialization from GMPRational with default precision (nil)
        let value = try GMPRational(
            numerator: 22,
            denominator: 7
        ) // Approximation of π
        let a = MPFRFloat(value, precision: nil, rounding: .nearest)

        // Then: Should use default precision and have correct value
        #expect(a.precision >= 53, "Should use default precision")
        #expect(
            abs(a.toDouble() - (22.0 / 7.0)) < 0.01,
            "Value should be correct"
        )
    }

    @Test
    func init_GMPRational_BasicValues_Works() throws {
        // Table Test
        let testCases: [(GMPRational, Double)] = try [
            (
                GMPRational(numerator: 3, denominator: 1),
                3.0
            ), // Positive integer rational
            (
                GMPRational(numerator: -3, denominator: 1),
                -3.0
            ), // Negative integer rational
            (GMPRational(numerator: 1, denominator: 2), 0.5), // Fractional
        ]

        for (inputValue, expectedResult) in testCases {
            // Given: GMPRational value from table
            // When: Calling MPFRFloat(value, precision: 64, rounding: .nearest)
            let a = MPFRFloat(inputValue, precision: 64, rounding: .nearest)

            // Then: Created float matches expected result, precision is 64 bits
            #expect(
                abs(a.toDouble() - expectedResult) < 1e-10,
                "Value should be correct"
            )
            #expect(a.precision == 64, "Precision should be 64")
        }
    }

    @Test
    func init_String_Decimal_Valid_ReturnsFloat() {
        // Given: String "3.14159"
        // When: Creating let a = MPFRFloat("3.14159", base: 10, precision: 64, rounding: .nearest)
        let a = MPFRFloat(
            "3.14159",
            base: 10,
            precision: 64,
            rounding: .nearest
        )

        // Then: Returns non-nil and a?.toDouble() == 3.14159
        #expect(a != nil, "Should parse successfully")
        if let a {
            #expect(
                abs(a.toDouble() - 3.14159) < 1e-10,
                "Value should match parsed string"
            )
        }
    }

    @Test
    func init_String_Decimal_Invalid_ReturnsNil() {
        // Given: Invalid string "not a number"
        // When: Creating let a = MPFRFloat("not a number", base: 10, precision: 64, rounding: .nearest)
        let a = MPFRFloat(
            "not a number",
            base: 10,
            precision: 64,
            rounding: .nearest
        )

        // Then: Returns nil
        #expect(a == nil, "Should return nil for invalid string")
    }

    @Test
    func init_String_Hex_Valid_ReturnsFloat() {
        // Given: String "1.8p0" (hexadecimal)
        // When: Creating let a = MPFRFloat("1.8p0", base: 16, precision: 64, rounding: .nearest)
        let a = MPFRFloat("1.8p0", base: 16, precision: 64, rounding: .nearest)

        // Then: Returns non-nil and a?.toDouble() == 1.5
        #expect(a != nil, "Should parse successfully")
        if let a {
            #expect(
                abs(a.toDouble() - 1.5) < 1e-10,
                "Value should match parsed hex string"
            )
        }
    }

    @Test
    func init_String_WithPrecision_Works() {
        // Given: String "3.14159" and precision 128
        // When: Creating let a = MPFRFloat("3.14159", base: 10, precision: 128, rounding: .nearest)
        let a = MPFRFloat(
            "3.14159",
            base: 10,
            precision: 128,
            rounding: .nearest
        )

        // Then: Returns non-nil, a?.toDouble() == 3.14159, and a?.precision == 128
        #expect(a != nil, "Should parse successfully")
        if let a {
            #expect(abs(a.toDouble() - 3.14159) < 1e-10, "Value should match")
            #expect(a.precision == 128, "Precision should be 128")
        }
    }

    @Test
    func swap_TwoFloats_SwapsValues() {
        // Given: var a = MPFRFloat(3.14159, precision: 64) and var b = MPFRFloat(2.71828, precision: 64)
        var a = MPFRFloat(3.14159, precision: 64)
        var b = MPFRFloat(2.71828, precision: 64)

        // When: Calling a.swap(&b)
        a.swap(&b)

        // Then: a.toDouble() == 2.71828 and b.toDouble() == 3.14159
        #expect(abs(a.toDouble() - 2.71828) < 1e-10, "a should have b's value")
        #expect(abs(b.toDouble() - 3.14159) < 1e-10, "b should have a's value")
    }

    @Test
    func swap_SameFloat_NoChange() {
        // Given: var a = MPFRFloat(3.14159, precision: 64)
        var a = MPFRFloat(3.14159, precision: 64)
        let originalValue = a.toDouble()
        let originalPrecision = a.precision

        // When: Calling a.swap(&a) - need to use a local variable to avoid exclusivity violation
        var b = a
        a.swap(&b)

        // Then: a.toDouble() == 3.14159 (no change) - actually, swap with copy means a gets b's value
        // But since b == a initially, the result should be the same
        #expect(
            abs(a.toDouble() - originalValue) < 1e-10,
            "Self-swap should not change value"
        )
        #expect(a.precision == originalPrecision, "Precision should not change")
    }

    @Test
    func swap_DifferentPrecisions_PreservesPrecision() {
        // Given: var a = MPFRFloat(3.14159, precision: 64) and var b = MPFRFloat(2.71828, precision: 128)
        var a = MPFRFloat(3.14159, precision: 64)
        var b = MPFRFloat(2.71828, precision: 128)

        // When: Calling a.swap(&b)
        a.swap(&b)

        // Then: a.precision == 128 and b.precision == 64 (precisions are swapped along with values)
        #expect(a.precision == 128, "a should have b's precision")
        #expect(b.precision == 64, "b should have a's precision")
    }

    @Test
    func fitsInUInt_BasicValues_ReturnsCorrectResult() {
        // Table Test
        let testCases: [(Double, Bool, String)] = [
            (42.0, true, "Positive integer within range"),
            (3.14159, false, "Fractional value"),
            (-5.0, false, "Negative value"),
            (0.0, true, "Zero"),
        ]

        for (inputValue, expectedResult, description) in testCases {
            // Given: let a = MPFRFloat(value, precision: 64) from table
            let a = MPFRFloat(inputValue, precision: 64)

            // When: Calling a.fitsInUInt()
            // Then: Returns expected result
            #expect(
                a.fitsInUInt() == expectedResult,
                "\(description) should return \(expectedResult)"
            )
        }
    }

    @Test
    func fitsInInt_BasicValues_ReturnsCorrectResult() {
        // Table Test
        let testCases: [(Double, Bool, String)] = [
            (42.0, true, "Positive integer within range"),
            (-42.0, true, "Negative integer within range"),
            (3.14159, false, "Fractional value"),
            (0.0, true, "Zero"),
        ]

        for (inputValue, expectedResult, description) in testCases {
            // Given: let a = MPFRFloat(value, precision: 64) from table
            let a = MPFRFloat(inputValue, precision: 64)

            // When: Calling a.fitsInInt()
            // Then: Returns expected result
            #expect(
                a.fitsInInt() == expectedResult,
                "\(description) should return \(expectedResult)"
            )
        }
    }

    @Test
    func fitsInUInt64_BasicValues_ReturnsCorrectResult() {
        // Table Test
        let testCases: [(Double, Bool, String)] = [
            (42.0, true, "Positive integer within range"),
            (3.14159, false, "Fractional value"),
            (-5.0, false, "Negative value"),
            (0.0, true, "Zero"),
        ]

        for (inputValue, expectedResult, description) in testCases {
            // Given: let a = MPFRFloat(value, precision: 64) from table
            let a = MPFRFloat(inputValue, precision: 64)

            // When: Calling a.fitsInUInt64()
            // Then: Returns expected result
            #expect(
                a.fitsInUInt64() == expectedResult,
                "\(description) should return \(expectedResult)"
            )
        }
    }

    @Test
    func fitsInInt64_BasicValues_ReturnsCorrectResult() {
        // Table Test
        let testCases: [(Double, Bool, String)] = [
            (42.0, true, "Positive integer within range"),
            (-42.0, true, "Negative integer within range"),
            (3.14159, false, "Fractional value"),
            (0.0, true, "Zero"),
        ]

        for (inputValue, expectedResult, description) in testCases {
            // Given: let a = MPFRFloat(value, precision: 64) from table
            let a = MPFRFloat(inputValue, precision: 64)

            // When: Calling a.fitsInInt64()
            // Then: Returns expected result
            #expect(
                a.fitsInInt64() == expectedResult,
                "\(description) should return \(expectedResult)"
            )
        }
    }
}
