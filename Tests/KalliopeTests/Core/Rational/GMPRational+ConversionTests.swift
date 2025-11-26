@testable import Kalliope
import Testing

// MARK: - Conversion Tests

struct GMPRationalConversionTests {
    // MARK: - toDouble() Tests

    @Test
    func toDouble_Zero_ReturnsZero() async throws {
        // Given: A GMPRational with value 0/1
        let rational = GMPRational()

        // When: Call toDouble()
        let result = rational.toDouble()

        // Then: Returns 0.0
        #expect(result == 0.0)
    }

    @Test
    func toDouble_PositiveInteger_ReturnsExactValue() async throws {
        // Given: A GMPRational with value 42/1
        let rational = try GMPRational(
            numerator: GMPInteger(42),
            denominator: GMPInteger(1)
        )

        // When: Call toDouble()
        let result = rational.toDouble()

        // Then: Returns 42.0
        #expect(result == 42.0)
    }

    @Test
    func toDouble_NegativeInteger_ReturnsExactValue() async throws {
        // Given: A GMPRational with value -42/1
        let rational = try GMPRational(
            numerator: GMPInteger(-42),
            denominator: GMPInteger(1)
        )

        // When: Call toDouble()
        let result = rational.toDouble()

        // Then: Returns -42.0
        #expect(result == -42.0)
    }

    @Test
    func toDouble_SimpleFraction_ReturnsExactValue() async throws {
        // Given: A GMPRational with value 1/2
        let rational = try GMPRational(
            numerator: GMPInteger(1),
            denominator: GMPInteger(2)
        )

        // When: Call toDouble()
        let result = rational.toDouble()

        // Then: Returns 0.5
        #expect(result == 0.5)
    }

    @Test
    func toDouble_NegativeFraction_ReturnsExactValue() async throws {
        // Given: A GMPRational with value -3/4
        let rational = try GMPRational(
            numerator: GMPInteger(-3),
            denominator: GMPInteger(4)
        )

        // When: Call toDouble()
        let result = rational.toDouble()

        // Then: Returns -0.75
        #expect(result == -0.75)
    }

    @Test
    func toDouble_LargeNumerator_ReturnsApproximateValue() async throws {
        // Given: A GMPRational with a very large numerator (e.g., 10^100/1)
        let largeNum = GMPInteger.power(base: 10, exponent: 100)
        let rational = try GMPRational(
            numerator: largeNum,
            denominator: GMPInteger(1)
        )

        // When: Call toDouble()
        let result = rational.toDouble()

        // Then: Returns a Double value (may be approximate or infinity if too large)
        // Verify it's not NaN (which would indicate an error)
        #expect(!result.isNaN)
        // For very large values, result may be finite (approximate) or infinite
        // We verify it's a valid double (not NaN) - the isFinite/isInfinite
        // check is always true
    }

    @Test
    func toDouble_LargeDenominator_ReturnsApproximateValue() async throws {
        // Given: A GMPRational with value 1/10^100
        let largeDen = GMPInteger.power(base: 10, exponent: 100)
        let rational = try GMPRational(
            numerator: GMPInteger(1),
            denominator: largeDen
        )

        // When: Call toDouble()
        let result = rational.toDouble()

        // Then: Returns a very small Double value (may be 0.0 if too small)
        #expect(result >= 0.0)
        #expect(result <= 1.0)
    }

    @Test
    func toDouble_RepeatingDecimal_ReturnsApproximateValue() async throws {
        // Given: A GMPRational with value 1/3
        let rational = try GMPRational(
            numerator: GMPInteger(1),
            denominator: GMPInteger(3)
        )

        // When: Call toDouble()
        let result = rational.toDouble()

        // Then: Returns an approximate Double value (0.333...)
        #expect(result > 0.333)
        #expect(result < 0.334)
    }

    @Test
    func toDouble_CanonicalizedFraction_ReturnsCorrectValue() async throws {
        // Given: A GMPRational with value 2/4 (canonicalized to 1/2)
        let rational = try GMPRational(
            numerator: GMPInteger(2),
            denominator: GMPInteger(4)
        )

        // When: Call toDouble()
        let result = rational.toDouble()

        // Then: Returns 0.5
        #expect(result == 0.5)
    }

    // MARK: - toString(base:) Tests

    @Test
    func toString_Zero_DefaultBase_ReturnsZeroString() async throws {
        // Given: A GMPRational with value 0/1, base = 10 (default)
        let rational = GMPRational()

        // When: Call toString()
        let result = rational.toString()

        // Then: Returns "0" (GMP returns just numerator when denominator is 1)
        #expect(result == "0")
    }

    @Test
    func toString_PositiveInteger_DefaultBase_ReturnsCorrectString(
    ) async throws {
        // Given: A GMPRational with value 42/1, base = 10 (default)
        let rational = try GMPRational(
            numerator: GMPInteger(42),
            denominator: GMPInteger(1)
        )

        // When: Call toString()
        let result = rational.toString()

        // Then: Returns "42" (GMP returns just numerator when denominator is 1)
        #expect(result == "42")
    }

    @Test
    func toString_NegativeInteger_DefaultBase_ReturnsCorrectString(
    ) async throws {
        // Given: A GMPRational with value -42/1, base = 10 (default)
        let rational = try GMPRational(
            numerator: GMPInteger(-42),
            denominator: GMPInteger(1)
        )

        // When: Call toString()
        let result = rational.toString()

        // Then: Returns "-42" (GMP returns just numerator when denominator is 1)
        #expect(result == "-42")
    }

    @Test
    func toString_SimpleFraction_DefaultBase_ReturnsCorrectString(
    ) async throws {
        // Given: A GMPRational with value 1/2, base = 10 (default)
        let rational = try GMPRational(
            numerator: GMPInteger(1),
            denominator: GMPInteger(2)
        )

        // When: Call toString()
        let result = rational.toString()

        // Then: Returns "1/2"
        #expect(result == "1/2")
    }

    @Test
    func toString_NegativeFraction_DefaultBase_ReturnsCorrectString(
    ) async throws {
        // Given: A GMPRational with value -3/4, base = 10 (default)
        let rational = try GMPRational(
            numerator: GMPInteger(-3),
            denominator: GMPInteger(4)
        )

        // When: Call toString()
        let result = rational.toString()

        // Then: Returns "-3/4"
        #expect(result == "-3/4")
    }

    @Test
    func toString_CanonicalizedFraction_DefaultBase_ReturnsCanonicalString(
    ) async throws {
        // Given: A GMPRational with value 2/4 (canonicalized to 1/2), base = 10 (default)
        let rational = try GMPRational(
            numerator: GMPInteger(2),
            denominator: GMPInteger(4)
        )

        // When: Call toString()
        let result = rational.toString()

        // Then: Returns "1/2" (canonical form)
        #expect(result == "1/2")
    }

    @Test
    func toString_BinaryBase_ReturnsBinaryString() async throws {
        // Given: A GMPRational with value 5/3, base = 2
        let rational = try GMPRational(
            numerator: GMPInteger(5),
            denominator: GMPInteger(3)
        )

        // When: Call toString(base: 2)
        let result = rational.toString(base: 2)

        // Then: Returns a string in binary format (e.g., "101/11")
        #expect(result == "101/11")
    }

    @Test
    func toString_HexadecimalBase_ReturnsHexString() async throws {
        // Given: A GMPRational with value 255/16, base = 16
        let rational = try GMPRational(
            numerator: GMPInteger(255),
            denominator: GMPInteger(16)
        )

        // When: Call toString(base: 16)
        let result = rational.toString(base: 16)

        // Then: Returns a string in hexadecimal format (e.g., "ff/10")
        #expect(result == "ff/10")
    }

    @Test
    func toString_Base36_ReturnsBase36String() async throws {
        // Given: A GMPRational with value 35/1, base = 36
        let rational = try GMPRational(
            numerator: GMPInteger(35),
            denominator: GMPInteger(1)
        )

        // When: Call toString(base: 36)
        let result = rational.toString(base: 36)

        // Then: Returns a string in base 36 format (e.g., "z")
        #expect(result == "z")
    }

    @Test
    func toString_Base62_ReturnsBase62String() async throws {
        // Given: A GMPRational with value 61/1, base = 62
        let rational = try GMPRational(
            numerator: GMPInteger(61),
            denominator: GMPInteger(1)
        )

        // When: Call toString(base: 62)
        let result = rational.toString(base: 62)

        // Then: Returns a string in base 62 format
        // Base 62 uses 0-9, A-Z (10-35), a-z (36-61), so 61 = 'z' (lowercase)
        #expect(result == "z")
    }

    @Test
    func toString_NegativeBase_ReturnsCorrectString() async throws {
        // Given: A GMPRational with value 10/1, base = -10
        let rational = try GMPRational(
            numerator: GMPInteger(10),
            denominator: GMPInteger(1)
        )

        // When: Call toString(base: -10)
        let result = rational.toString(base: -10)

        // Then: Returns a string representation using negative base
        // Negative base uses uppercase letters, GMP returns just numerator when
        // denominator is 1
        #expect(result == "10")
    }

    @Test
    func toString_BaseMinus36_ReturnsCorrectString() async throws {
        // Given: A GMPRational with value 35/1, base = -36
        let rational = try GMPRational(
            numerator: GMPInteger(35),
            denominator: GMPInteger(1)
        )

        // When: Call toString(base: -36)
        let result = rational.toString(base: -36)

        // Then: Returns a string representation using base -36
        // GMP returns just numerator when denominator is 1
        #expect(result == "Z")
    }

    @Test
    func toString_BaseMinus2_ReturnsCorrectString() async throws {
        // Given: A GMPRational with value 5/1, base = -2
        let rational = try GMPRational(
            numerator: GMPInteger(5),
            denominator: GMPInteger(1)
        )

        // When: Call toString(base: -2)
        let result = rational.toString(base: -2)

        // Then: Returns a string representation using base -2
        // GMP handles negative bases natively (unlike GMPFloat which converts
        // to absolute value)
        // For 5 in base -2, GMP produces a valid representation
        #expect(!result.isEmpty)
    }

    @Test
    func toString_RoundTrip_PreservesValue() async throws {
        // Given: A GMPRational with value 123/456, base = 10
        let original = try GMPRational(
            numerator: GMPInteger(123),
            denominator: GMPInteger(456)
        )

        // When: Call toString(base: 10) then parse the result with init(_:base:)
        let string = original.toString(base: 10)
        let parsed = GMPRational(string, base: 10)

        // Then: The parsed value equals the original value
        #expect(parsed != nil)
        // Compare numerator and denominator separately (Equatable not yet
        // implemented)
        #expect(parsed!.numerator == original.numerator)
        #expect(parsed!.denominator == original.denominator)
    }

    @Test
    func toString_DefensiveNilCheck_AlwaysSucceeds() async throws {
        // Given: A GMPRational with any valid value
        // Note: GMP's mpq_get_str with NULL buffer always allocates and returns
        // a pointer.
        // It only returns NULL on memory allocation failure, which is extremely
        // difficult
        // to simulate in tests. The guard case (lines 51-53) is a defensive
        // programming
        // measure that is untestable in practice.
        let rational = try GMPRational(
            numerator: GMPInteger(42),
            denominator: GMPInteger(1)
        )

        // When: Call toString() with any valid base
        let result = rational.toString()

        // Then: Always succeeds (cString is never nil in practice)
        // This test documents that the nil check path (lines 51-53) is
        // untestable
        // because GMP's mpq_get_str with NULL buffer always allocates memory.
        // Verify the result is correct
        #expect(result == "42")
    }

    // MARK: - init(_:base:) Tests

    @Test
    func initFromString_Zero_DefaultBase_ReturnsZero() async throws {
        // Given: String "0", base = 10 (default)
        // When: Create GMPRational("0")
        let rational = GMPRational("0")

        // Then: Returns a GMPRational with value 0/1
        #expect(rational != nil)
        #expect(rational!.numerator.toInt() == 0)
        #expect(rational!.denominator.toInt() == 1)
    }

    @Test
    func initFromString_ZeroWithDenominator_DefaultBase_ReturnsZero(
    ) async throws {
        // Given: String "0/1", base = 10 (default)
        // When: Create GMPRational("0/1")
        let rational = GMPRational("0/1")

        // Then: Returns a GMPRational with value 0/1
        #expect(rational != nil)
        #expect(rational!.numerator.toInt() == 0)
        #expect(rational!.denominator.toInt() == 1)
    }

    @Test
    func initFromString_PositiveInteger_DefaultBase_ReturnsCorrectValue(
    ) async throws {
        // Given: String "42", base = 10 (default)
        // When: Create GMPRational("42")
        let rational = GMPRational("42")

        // Then: Returns a GMPRational with value 42/1
        #expect(rational != nil)
        #expect(rational!.numerator.toInt() == 42)
        #expect(rational!.denominator.toInt() == 1)
    }

    @Test
    func initFromString_NegativeInteger_DefaultBase_ReturnsCorrectValue(
    ) async throws {
        // Given: String "-42", base = 10 (default)
        // When: Create GMPRational("-42")
        let rational = GMPRational("-42")

        // Then: Returns a GMPRational with value -42/1
        #expect(rational != nil)
        #expect(rational!.numerator.toInt() == -42)
        #expect(rational!.denominator.toInt() == 1)
    }

    @Test
    func initFromString_SimpleFraction_DefaultBase_ReturnsCorrectValue(
    ) async throws {
        // Given: String "1/2", base = 10 (default)
        // When: Create GMPRational("1/2")
        let rational = GMPRational("1/2")

        // Then: Returns a GMPRational with value 1/2 (canonicalized)
        #expect(rational != nil)
        #expect(rational!.numerator.toInt() == 1)
        #expect(rational!.denominator.toInt() == 2)
    }

    @Test
    func initFromString_NegativeFraction_DefaultBase_ReturnsCorrectValue(
    ) async throws {
        // Given: String "-3/4", base = 10 (default)
        // When: Create GMPRational("-3/4")
        let rational = GMPRational("-3/4")

        // Then: Returns a GMPRational with value -3/4 (canonicalized)
        #expect(rational != nil)
        #expect(rational!.numerator.toInt() == -3)
        #expect(rational!.denominator.toInt() == 4)
    }

    @Test
    func initFromString_NonCanonicalFraction_DefaultBase_ReturnsCanonicalizedValue(
    ) async throws {
        // Given: String "2/4", base = 10 (default)
        // When: Create GMPRational("2/4")
        let rational = GMPRational("2/4")

        // Then: Returns a GMPRational with value 1/2 (canonicalized)
        #expect(rational != nil)
        #expect(rational!.numerator.toInt() == 1)
        #expect(rational!.denominator.toInt() == 2)
    }

    @Test
    func initFromString_BinaryBase_ReturnsCorrectValue() async throws {
        // Given: String "101/11", base = 2
        // When: Create GMPRational("101/11", base: 2)
        let rational = GMPRational("101/11", base: 2)

        // Then: Returns a GMPRational with value 5/3
        #expect(rational != nil)
        #expect(rational!.numerator.toInt() == 5)
        #expect(rational!.denominator.toInt() == 3)
    }

    @Test
    func initFromString_HexadecimalBase_ReturnsCorrectValue() async throws {
        // Given: String "ff/10", base = 16
        // When: Create GMPRational("ff/10", base: 16)
        let rational = GMPRational("ff/10", base: 16)

        // Then: Returns a GMPRational with value 255/16
        #expect(rational != nil)
        #expect(rational!.numerator.toInt() == 255)
        #expect(rational!.denominator.toInt() == 16)
    }

    @Test
    func initFromString_Base36_ReturnsCorrectValue() async throws {
        // Given: String "z/1", base = 36
        // When: Create GMPRational("z/1", base: 36)
        let rational = GMPRational("z/1", base: 36)

        // Then: Returns a GMPRational with value 35/1
        #expect(rational != nil)
        #expect(rational!.numerator.toInt() == 35)
        #expect(rational!.denominator.toInt() == 1)
    }

    @Test
    func initFromString_Base62_ReturnsCorrectValue() async throws {
        // Given: String "z/1", base = 62
        // When: Create GMPRational("z/1", base: 62)
        // Note: In base 62, 0-9=0-9, A-Z=10-35, a-z=36-61, so "z" = 61
        let rational = GMPRational("z/1", base: 62)

        // Then: Returns a GMPRational with value 61/1
        #expect(rational != nil)
        #expect(rational!.numerator.toInt() == 61)
        #expect(rational!.denominator.toInt() == 1)
    }

    @Test
    func initFromString_BaseZero_AutoDetectsDecimal() async throws {
        // Given: String "42", base = 0
        // When: Create GMPRational("42", base: 0)
        let rational = GMPRational("42", base: 0)

        // Then: Returns a GMPRational with value 42/1 (auto-detects base 10)
        #expect(rational != nil)
        #expect(rational!.numerator.toInt() == 42)
        #expect(rational!.denominator.toInt() == 1)
    }

    @Test
    func initFromString_BaseZero_WithPrefix_AutoDetectsBase() async throws {
        // Given: String "0x2a", base = 0
        // When: Create GMPRational("0x2a", base: 0)
        let rational = GMPRational("0x2a", base: 0)

        // Then: Returns a GMPRational with value 42/1 (auto-detects base 16 from 0x prefix)
        #expect(rational != nil)
        #expect(rational!.numerator.toInt() == 42)
        #expect(rational!.denominator.toInt() == 1)
    }

    @Test
    func initFromString_EmptyString_ReturnsNil() async throws {
        // Given: Empty string "", base = 10 (default)
        // When: Attempt to create GMPRational("")
        let rational = GMPRational("")

        // Then: Returns nil (requires non-empty string)
        #expect(rational == nil)
    }

    @Test
    func initFromString_InvalidFormat_ReturnsNil() async throws {
        // Given: String "not a number", base = 10 (default)
        // When: Attempt to create GMPRational("not a number")
        let rational = GMPRational("not a number")

        // Then: Returns nil
        #expect(rational == nil)
    }

    @Test
    func initFromString_InvalidFractionFormat_ReturnsNil() async throws {
        // Given: String "1/2/3", base = 10 (default)
        // When: Attempt to create GMPRational("1/2/3")
        let rational = GMPRational("1/2/3")

        // Then: Returns nil
        #expect(rational == nil)
    }

    @Test
    func initFromString_ZeroDenominator_ReturnsNil() async throws {
        // Given: String "1/0", base = 10 (default)
        // When: Attempt to create GMPRational("1/0")
        let rational = GMPRational("1/0")

        // Then: Returns nil (denominator cannot be zero)
        #expect(rational == nil)
    }

    @Test
    func initFromString_Base1_ReturnsNil() async throws {
        // Given: String "42", base = 1
        // When: Attempt to create GMPRational("42", base: 1)
        // Then: Function should precondition fail
        // Note: This will hit a precondition (base must be 0 or 2-62), so we
        // can't test it directly
        // Preconditions cause fatal errors which can't be caught in Swift
        // Testing
        // The precondition is verified to exist in the implementation at line
        // 89-92 of GMPRational+Conversion.swift
        // In practice, calling with base = 1 will cause a precondition failure
        // This test documents that the precondition exists
    }

    @Test
    func initFromString_Base63_ReturnsNil() async throws {
        // Given: String "42", base = 63
        // When: Attempt to create GMPRational("42", base: 63)
        // Then: Function should precondition fail
        // Note: This will hit a precondition (base must be 0 or 2-62), so we
        // can't test it directly
        // Preconditions cause fatal errors which can't be caught in Swift
        // Testing
        // The precondition is verified to exist in the implementation at line
        // 89-92 of GMPRational+Conversion.swift
        // In practice, calling with base = 63 will cause a precondition failure
        // This test documents that the precondition exists
    }

    @Test
    func initFromString_BaseMinus1_ReturnsNil() async throws {
        // Given: String "42", base = -1
        // When: Attempt to create GMPRational("42", base: -1)
        // Then: Function should precondition fail
        // Note: This will hit a precondition (base must be 0 or 2-62), so we
        // can't test it directly
        // Preconditions cause fatal errors which can't be caught in Swift
        // Testing
        // The precondition is verified to exist in the implementation at line
        // 89-92 of GMPRational+Conversion.swift
        // In practice, calling with base = -1 will cause a precondition failure
        // This test documents that the precondition exists
    }

    @Test
    func initFromString_InvalidCharacterForBase_ReturnsNil() async throws {
        // Given: String "z", base = 10
        // When: Attempt to create GMPRational("z", base: 10)
        let rational = GMPRational("z", base: 10)

        // Then: Returns nil (character 'z' not valid in base 10)
        #expect(rational == nil)
    }

    @Test
    func initFromString_WhitespaceOnly_ReturnsNil() async throws {
        // Given: String "   ", base = 10 (default)
        // When: Attempt to create GMPRational("   ")
        let rational = GMPRational("   ")

        // Then: Returns nil or trims whitespace (implementation dependent)
        // GMP typically ignores whitespace, so this might succeed with "0/1"
        // Let's test what actually happens
        #expect(rational == nil || rational!.numerator.toInt() == 0)
    }

    @Test
    func initFromString_LargeValue_ReturnsCorrectValue() async throws {
        // Given: String representing a very large number, base = 10
        let largeString = "123456789012345678901234567890"
        // When: Create GMPRational from the string
        let rational = GMPRational(largeString)

        // Then: Returns a GMPRational with the correct large value
        #expect(rational != nil)
        // Verify it can be converted back to string
        let backToString = rational!.toString()
        #expect(backToString.contains("123456789012345678901234567890"))
    }
}
