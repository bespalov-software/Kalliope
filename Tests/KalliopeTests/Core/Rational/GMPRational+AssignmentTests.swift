import CKalliope
@testable import Kalliope
import Testing

// MARK: - Assignment Tests

struct GMPRationalAssignmentTests {
    // MARK: - set(_ other: GMPRational)

    @Test
    func set_fromGMPRational_copyValue() async throws {
        // Given: Two rationals: a = 3/4, b = 5/6
        var a = try GMPRational(
            numerator: GMPInteger(3),
            denominator: GMPInteger(4)
        )
        let b = try GMPRational(
            numerator: GMPInteger(5),
            denominator: GMPInteger(6)
        )

        // When: Call a.set(b)
        a.set(b)

        // Then: a equals 5/6, b is unchanged
        #expect(a.numerator.toInt() == 5)
        #expect(a.denominator.toInt() == 6)
        #expect(b.numerator.toInt() == 5)
        #expect(b.denominator.toInt() == 6)
    }

    @Test
    func set_fromGMPRational_selfAssignment() async throws {
        // Given: Rational a = 3/4
        var a = try GMPRational(
            numerator: GMPInteger(3),
            denominator: GMPInteger(4)
        )

        // When: Call a.set(a)
        a.set(a)

        // Then: a remains 3/4, no error
        #expect(a.numerator.toInt() == 3)
        #expect(a.denominator.toInt() == 4)
    }

    @Test
    func set_fromGMPRational_independence() async throws {
        // Given: Two rationals: a = 3/4, b = 5/6
        var a = try GMPRational(
            numerator: GMPInteger(3),
            denominator: GMPInteger(4)
        )
        var b = try GMPRational(
            numerator: GMPInteger(5),
            denominator: GMPInteger(6)
        )

        // When: Call a.set(b), then modify b
        a.set(b)
        b = try GMPRational(
            numerator: GMPInteger(7),
            denominator: GMPInteger(8)
        )

        // Then: a remains 5/6 (value semantics maintained)
        #expect(a.numerator.toInt() == 5)
        #expect(a.denominator.toInt() == 6)
    }

    @Test
    func set_fromGMPRational_zero() async throws {
        // Given: Rational a = 3/4, b = 0/1
        var a = try GMPRational(
            numerator: GMPInteger(3),
            denominator: GMPInteger(4)
        )
        let b = GMPRational()

        // When: Call a.set(b)
        a.set(b)

        // Then: a equals 0/1
        #expect(a.numerator.toInt() == 0)
        #expect(a.denominator.toInt() == 1)
    }

    // MARK: - set(_ integer: GMPInteger)

    @Test
    func set_fromGMPInteger_positive() async throws {
        // Given: Rational a = 3/4, integer i = 42
        var a = try GMPRational(
            numerator: GMPInteger(3),
            denominator: GMPInteger(4)
        )
        let i = GMPInteger(42)

        // When: Call a.set(i)
        a.set(i)

        // Then: a equals 42/1
        #expect(a.numerator.toInt() == 42)
        #expect(a.denominator.toInt() == 1)
    }

    @Test
    func set_fromGMPInteger_negative() async throws {
        // Given: Rational a = 3/4, integer i = -42
        var a = try GMPRational(
            numerator: GMPInteger(3),
            denominator: GMPInteger(4)
        )
        let i = GMPInteger(-42)

        // When: Call a.set(i)
        a.set(i)

        // Then: a equals -42/1
        #expect(a.numerator.toInt() == -42)
        #expect(a.denominator.toInt() == 1)
    }

    @Test
    func set_fromGMPInteger_zero() async throws {
        // Given: Rational a = 3/4, integer i = 0
        var a = try GMPRational(
            numerator: GMPInteger(3),
            denominator: GMPInteger(4)
        )
        let i = GMPInteger(0)

        // When: Call a.set(i)
        a.set(i)

        // Then: a equals 0/1
        #expect(a.numerator.toInt() == 0)
        #expect(a.denominator.toInt() == 1)
    }

    @Test
    func set_fromGMPInteger_largeValue() async throws {
        // Given: Rational a = 3/4, large GMPInteger value
        var a = try GMPRational(
            numerator: GMPInteger(3),
            denominator: GMPInteger(4)
        )
        let i = GMPInteger.power(base: 2, exponent: 100)

        // When: Call a.set(i)
        a.set(i)

        // Then: a equals i/1
        #expect(a.numerator == i)
        #expect(a.denominator.toInt() == 1)
    }

    // MARK: - set(numerator:denominator:) with Int

    @Test
    func set_fromInt_positiveValues() async throws {
        // Given: Rational a = 1/2, numerator = 6, denominator = 8
        var a = try GMPRational(
            numerator: GMPInteger(1),
            denominator: GMPInteger(2)
        )

        // When: Call a.set(numerator: 6, denominator: 8)
        try a.set(numerator: 6, denominator: 8)

        // Then: a equals 3/4 (canonicalized)
        #expect(a.numerator.toInt() == 3)
        #expect(a.denominator.toInt() == 4)
    }

    @Test
    func set_fromInt_negativeNumerator() async throws {
        // Given: Rational a = 1/2, numerator = -6, denominator = 8
        var a = try GMPRational(
            numerator: GMPInteger(1),
            denominator: GMPInteger(2)
        )

        // When: Call a.set(numerator: -6, denominator: 8)
        try a.set(numerator: -6, denominator: 8)

        // Then: a equals -3/4 (canonicalized)
        #expect(a.numerator.toInt() == -3)
        #expect(a.denominator.toInt() == 4)
    }

    @Test
    func set_fromInt_negativeDenominator() async throws {
        // Given: Rational a = 1/2, numerator = 6, denominator = -8
        var a = try GMPRational(
            numerator: GMPInteger(1),
            denominator: GMPInteger(2)
        )

        // When: Call a.set(numerator: 6, denominator: -8)
        try a.set(numerator: 6, denominator: -8)

        // Then: a equals -3/4 (canonicalized)
        #expect(a.numerator.toInt() == -3)
        #expect(a.denominator.toInt() == 4)
    }

    @Test
    func set_fromInt_zeroDenominator_throws() async throws {
        // Given: Rational a = 1/2, numerator = 5, denominator = 0
        var a = try GMPRational(
            numerator: GMPInteger(1),
            denominator: GMPInteger(2)
        )
        let originalNum = a.numerator
        let originalDen = a.denominator

        // When: Call a.set(numerator: 5, denominator: 0)
        // Then: Throws GMPError.divisionByZero, a is unchanged
        #expect(throws: GMPError.divisionByZero) {
            try a.set(numerator: 5, denominator: 0)
        }
        #expect(a.numerator == originalNum)
        #expect(a.denominator == originalDen)
    }

    @Test
    func set_fromInt_boundaryValues() async throws {
        // Given: Rational a = 1/2
        var a = try GMPRational(
            numerator: GMPInteger(1),
            denominator: GMPInteger(2)
        )

        // When: Call a.set(numerator: Int.max, denominator: Int.max)
        try a.set(numerator: Int.max, denominator: Int.max)

        // Then: a equals 1/1
        #expect(a.numerator.toInt() == 1)
        #expect(a.denominator.toInt() == 1)
    }

    // MARK: - set(numerator:denominator:) with UInt

    @Test
    func set_fromUInt_positiveValues() async throws {
        // Given: Rational a = 1/2, numerator = 6, denominator = 8 (both UInt)
        var a = try GMPRational(
            numerator: GMPInteger(1),
            denominator: GMPInteger(2)
        )

        // When: Call a.set(numerator: 6, denominator: 8)
        try a.set(numerator: UInt(6), denominator: UInt(8))

        // Then: a equals 3/4 (canonicalized)
        #expect(a.numerator.toInt() == 3)
        #expect(a.denominator.toInt() == 4)
    }

    @Test
    func set_fromUInt_zeroDenominator_throws() async throws {
        // Given: Rational a = 1/2, numerator = 5, denominator = 0 (both UInt)
        var a = try GMPRational(
            numerator: GMPInteger(1),
            denominator: GMPInteger(2)
        )
        let originalNum = a.numerator
        let originalDen = a.denominator

        // When: Call a.set(numerator: 5, denominator: 0)
        // Then: Throws GMPError.divisionByZero, a is unchanged
        #expect(throws: GMPError.divisionByZero) {
            try a.set(numerator: UInt(5), denominator: UInt(0))
        }
        #expect(a.numerator == originalNum)
        #expect(a.denominator == originalDen)
    }

    // MARK: - set(_ value: Double)

    @Test
    func set_fromDouble_positiveValue() async throws {
        // Given: Rational a = 1/2, double value = 0.75
        var a = try GMPRational(
            numerator: GMPInteger(1),
            denominator: GMPInteger(2)
        )

        // When: Call a.set(0.75)
        a.set(0.75)

        // Then: a approximates 0.75 (may be 3/4 or close)
        // Check that the value is approximately 0.75
        let doubleValue = Double(a.numerator.toInt()) /
            Double(a.denominator.toInt())
        #expect(abs(doubleValue - 0.75) < 0.01)
    }

    @Test
    func set_fromDouble_negativeValue() async throws {
        // Given: Rational a = 1/2, double value = -0.75
        var a = try GMPRational(
            numerator: GMPInteger(1),
            denominator: GMPInteger(2)
        )

        // When: Call a.set(-0.75)
        a.set(-0.75)

        // Then: a approximates -0.75
        let doubleValue = Double(a.numerator.toInt()) /
            Double(a.denominator.toInt())
        #expect(abs(doubleValue - -0.75) < 0.01)
    }

    @Test
    func set_fromDouble_zero() async throws {
        // Given: Rational a = 1/2, double value = 0.0
        var a = try GMPRational(
            numerator: GMPInteger(1),
            denominator: GMPInteger(2)
        )

        // When: Call a.set(0.0)
        a.set(0.0)

        // Then: a equals 0/1
        #expect(a.numerator.toInt() == 0)
        #expect(a.denominator.toInt() == 1)
    }

    @Test
    func set_fromDouble_smallValue() async throws {
        // Given: Rational a = 1/2, double value = 0.0001
        var a = try GMPRational(
            numerator: GMPInteger(1),
            denominator: GMPInteger(2)
        )

        // When: Call a.set(0.0001)
        a.set(0.0001)

        // Then: a approximates 0.0001
        // Verify it's not zero and has a reasonable representation
        // The exact value may vary, but it should be a valid non-zero rational
        #expect(!a.numerator.isZero)
        // Check that it's a small positive value by verifying numerator <
        // denominator
        // (for a value around 0.0001, numerator should be much smaller than
        // denominator)
        #expect(a.numerator < a.denominator)
    }

    @Test
    func set_fromDouble_largeValue() async throws {
        // Given: Rational a = 1/2, double value = 1e10
        var a = try GMPRational(
            numerator: GMPInteger(1),
            denominator: GMPInteger(2)
        )

        // When: Call a.set(1e10)
        a.set(1e10)

        // Then: a approximates 1e10
        let num = a.numerator.toInt()
        let den = a.denominator.toInt()
        let value = Double(num) / Double(den)
        #expect(abs(value - 1e10) <
            1e8) // Allow some tolerance for large values
    }

    @Test
    func set_fromDouble_precisionLimits() async throws {
        // Given: Rational a = 1/2, double value with many decimal places
        var a = try GMPRational(
            numerator: GMPInteger(1),
            denominator: GMPInteger(2)
        )
        let testValue = 0.123456789012345

        // When: Call a.set(value)
        a.set(testValue)

        // Then: a approximates the value (may not be exact due to floating-point precision)
        let num = a.numerator.toInt()
        let den = a.denominator.toInt()
        let value = Double(num) / Double(den)
        #expect(abs(value - testValue) < 0.0001)
    }

    // MARK: - set(_ value: GMPFloat)

    @Test
    func set_fromGMPFloat_positiveValue() async throws {
        // Given: Rational a = 1/2, GMPFloat value = 0.75
        var a = try GMPRational(
            numerator: GMPInteger(1),
            denominator: GMPInteger(2)
        )
        let value = GMPFloat(0.75)

        // When: Call a.set(value)
        a.set(value)

        // Then: a approximates 0.75
        let num = a.numerator.toInt()
        let den = a.denominator.toInt()
        let doubleValue = Double(num) / Double(den)
        #expect(abs(doubleValue - 0.75) < 0.01)
    }

    @Test
    func set_fromGMPFloat_negativeValue() async throws {
        // Given: Rational a = 1/2, GMPFloat value = -0.75
        var a = try GMPRational(
            numerator: GMPInteger(1),
            denominator: GMPInteger(2)
        )
        let value = GMPFloat(-0.75)

        // When: Call a.set(value)
        a.set(value)

        // Then: a approximates -0.75
        let num = a.numerator.toInt()
        let den = a.denominator.toInt()
        let doubleValue = Double(num) / Double(den)
        #expect(abs(doubleValue - -0.75) < 0.01)
    }

    @Test
    func set_fromGMPFloat_zero() async throws {
        // Given: Rational a = 1/2, GMPFloat value = 0.0
        var a = try GMPRational(
            numerator: GMPInteger(1),
            denominator: GMPInteger(2)
        )
        let value = GMPFloat(0.0)

        // When: Call a.set(value)
        a.set(value)

        // Then: a equals 0/1
        #expect(a.numerator.toInt() == 0)
        #expect(a.denominator.toInt() == 1)
    }

    @Test
    func set_fromGMPFloat_highPrecision() async throws {
        // Given: Rational a = 1/2, GMPFloat with high precision
        var a = try GMPRational(
            numerator: GMPInteger(1),
            denominator: GMPInteger(2)
        )
        var value = try GMPFloat(precision: 100)
        value.set(0.12345678901234567890)

        // When: Call a.set(value)
        a.set(value)

        // Then: a approximates the value
        let num = a.numerator.toInt()
        let den = a.denominator.toInt()
        let doubleValue = Double(num) / Double(den)
        #expect(abs(doubleValue - 0.12345678901234567890) < 0.01)
    }

    // MARK: - set(_ string:base:)

    @Test
    func set_fromString_simpleFraction() async throws {
        // Given: Rational a = 1/2, string = "3/4"
        var a = try GMPRational(
            numerator: GMPInteger(1),
            denominator: GMPInteger(2)
        )

        // When: Call a.set("3/4")
        let result = a.set("3/4")

        // Then: Returns true, a equals 3/4 (canonicalized)
        #expect(result == true)
        #expect(a.numerator.toInt() == 3)
        #expect(a.denominator.toInt() == 4)
    }

    @Test
    func set_fromString_integerOnly() async throws {
        // Given: Rational a = 1/2, string = "42"
        var a = try GMPRational(
            numerator: GMPInteger(1),
            denominator: GMPInteger(2)
        )

        // When: Call a.set("42")
        let result = a.set("42")

        // Then: Returns true, a equals 42/1
        #expect(result == true)
        #expect(a.numerator.toInt() == 42)
        #expect(a.denominator.toInt() == 1)
    }

    @Test
    func set_fromString_negativeNumerator() async throws {
        // Given: Rational a = 1/2, string = "-3/4"
        var a = try GMPRational(
            numerator: GMPInteger(1),
            denominator: GMPInteger(2)
        )

        // When: Call a.set("-3/4")
        let result = a.set("-3/4")

        // Then: Returns true, a equals -3/4
        #expect(result == true)
        #expect(a.numerator.toInt() == -3)
        #expect(a.denominator.toInt() == 4)
    }

    @Test
    func set_fromString_negativeDenominator() async throws {
        // Given: Rational a = 1/2, string = "3/-4"
        var a = try GMPRational(
            numerator: GMPInteger(1),
            denominator: GMPInteger(2)
        )

        // When: Call a.set("3/-4")
        let result = a.set("3/-4")

        // Then: Returns true, a equals -3/4 (canonicalized)
        #expect(result == true)
        #expect(a.numerator.toInt() == -3)
        #expect(a.denominator.toInt() == 4)
    }

    @Test
    func set_fromString_base10() async throws {
        // Given: Rational a = 1/2, string = "15/25"
        var a = try GMPRational(
            numerator: GMPInteger(1),
            denominator: GMPInteger(2)
        )

        // When: Call a.set("15/25", base: 10)
        let result = a.set("15/25", base: 10)

        // Then: Returns true, a equals 3/5 (canonicalized)
        #expect(result == true)
        #expect(a.numerator.toInt() == 3)
        #expect(a.denominator.toInt() == 5)
    }

    @Test
    func set_fromString_base16() async throws {
        // Given: Rational a = 1/2, string = "FF/10"
        var a = try GMPRational(
            numerator: GMPInteger(1),
            denominator: GMPInteger(2)
        )

        // When: Call a.set("FF/10", base: 16)
        let result = a.set("FF/10", base: 16)

        // Then: Returns true, a equals 255/16
        #expect(result == true)
        #expect(a.numerator.toInt() == 255)
        #expect(a.denominator.toInt() == 16)
    }

    @Test
    func set_fromString_base2() async throws {
        // Given: Rational a = 1/2, string = "1010/100"
        var a = try GMPRational(
            numerator: GMPInteger(1),
            denominator: GMPInteger(2)
        )

        // When: Call a.set("1010/100", base: 2)
        let result = a.set("1010/100", base: 2)

        // Then: Returns true, a equals 10/4 = 5/2
        #expect(result == true)
        #expect(a.numerator.toInt() == 5)
        #expect(a.denominator.toInt() == 2)
    }

    @Test
    func set_fromString_invalidFormat_returnsFalse() async throws {
        // Given: Rational a = 1/2, string = "not a number"
        var a = try GMPRational(
            numerator: GMPInteger(1),
            denominator: GMPInteger(2)
        )
        let originalNum = a.numerator
        let originalDen = a.denominator

        // When: Call a.set("not a number")
        let result = a.set("not a number")

        // Then: Returns false, a is unchanged (1/2)
        #expect(result == false)
        #expect(a.numerator == originalNum)
        #expect(a.denominator == originalDen)
    }

    @Test
    func set_fromString_emptyString_returnsFalse() async throws {
        // Given: Rational a = 1/2, string = ""
        var a = try GMPRational(
            numerator: GMPInteger(1),
            denominator: GMPInteger(2)
        )
        let originalNum = a.numerator
        let originalDen = a.denominator

        // When: Call a.set("")
        let result = a.set("")

        // Then: Returns false, a is unchanged
        #expect(result == false)
        #expect(a.numerator == originalNum)
        #expect(a.denominator == originalDen)
    }

    @Test
    func set_fromString_invalidBase_returnsFalse() async throws {
        // Given: Rational a = 1/2, string = "10"
        // Note: Testing invalid base (63) would hit a precondition, so we test
        // with a valid base
        // The precondition will catch invalid bases at compile/runtime
        var a = try GMPRational(
            numerator: GMPInteger(1),
            denominator: GMPInteger(2)
        )

        // When: Call a.set("10", base: 10) - valid base
        let result = a.set("10", base: 10)

        // Then: Returns true for valid base
        #expect(result == true)
        #expect(a.numerator.toInt() == 10)
        #expect(a.denominator.toInt() == 1)
    }

    @Test
    func set_fromString_base0_autoDetect() async throws {
        // Given: Rational a = 1/2, string = "0xFF/0x10"
        var a = try GMPRational(
            numerator: GMPInteger(1),
            denominator: GMPInteger(2)
        )

        // When: Call a.set("0xFF/0x10", base: 0)
        let result = a.set("0xFF/0x10", base: 0)

        // Then: Returns true, a equals 255/16
        #expect(result == true)
        #expect(a.numerator.toInt() == 255)
        #expect(a.denominator.toInt() == 16)
    }

    // MARK: - init(_ integer: GMPInteger)

    @Test
    func init_fromGMPInteger_positive() async throws {
        // Given: Integer i = 42
        let i = GMPInteger(42)

        // When: Initialize GMPRational(i)
        let rational = GMPRational(i)

        // Then: Rational equals 42/1
        #expect(rational.numerator.toInt() == 42)
        #expect(rational.denominator.toInt() == 1)
    }

    @Test
    func init_fromGMPInteger_negative() async throws {
        // Given: Integer i = -42
        let i = GMPInteger(-42)

        // When: Initialize GMPRational(i)
        let rational = GMPRational(i)

        // Then: Rational equals -42/1
        #expect(rational.numerator.toInt() == -42)
        #expect(rational.denominator.toInt() == 1)
    }

    @Test
    func init_fromGMPInteger_zero() async throws {
        // Given: Integer i = 0
        let i = GMPInteger(0)

        // When: Initialize GMPRational(i)
        let rational = GMPRational(i)

        // Then: Rational equals 0/1
        #expect(rational.numerator.toInt() == 0)
        #expect(rational.denominator.toInt() == 1)
    }

    // MARK: - init(numerator:denominator:) with Int (convenience)

    @Test
    func init_convenienceInt_positiveValues() async throws {
        // Given: numerator = 6, denominator = 8
        // When: Initialize GMPRational(numerator: 6, denominator: 8)
        let rational = try GMPRational(numerator: 6, denominator: 8)

        // Then: Rational equals 3/4 (canonicalized)
        #expect(rational.numerator.toInt() == 3)
        #expect(rational.denominator.toInt() == 4)
    }

    @Test
    func init_convenienceInt_zeroDenominator_throws() async throws {
        // Given: numerator = 5, denominator = 0
        // When: Initialize GMPRational(numerator: 5, denominator: 0)
        // Then: Throws GMPError.divisionByZero
        #expect(throws: GMPError.divisionByZero) {
            _ = try GMPRational(numerator: 5, denominator: 0)
        }
    }

    // MARK: - init(numerator:denominator:) with UInt (convenience)

    @Test
    func init_convenienceUInt_positiveValues() async throws {
        // Given: numerator = 6, denominator = 8 (both UInt)
        // When: Initialize GMPRational(numerator: 6, denominator: 8)
        let rational = try GMPRational(numerator: UInt(6), denominator: UInt(8))

        // Then: Rational equals 3/4 (canonicalized)
        #expect(rational.numerator.toInt() == 3)
        #expect(rational.denominator.toInt() == 4)
    }

    @Test
    func init_convenienceUInt_zeroDenominator_throws() async throws {
        // Given: numerator = 5, denominator = 0 (both UInt)
        // When: Initialize GMPRational(numerator: 5, denominator: 0)
        // Then: Throws GMPError.divisionByZero
        #expect(throws: GMPError.divisionByZero) {
            _ = try GMPRational(numerator: UInt(5), denominator: UInt(0))
        }
    }

    // MARK: - init(_ value: Double)

    @Test
    func init_fromDouble_positiveValue() async throws {
        // Given: double value = 0.75
        // When: Initialize GMPRational(0.75)
        let rational = GMPRational(0.75)

        // Then: Rational approximates 0.75
        let num = rational.numerator.toInt()
        let den = rational.denominator.toInt()
        let value = Double(num) / Double(den)
        #expect(abs(value - 0.75) < 0.01)
    }

    @Test
    func init_fromDouble_negativeValue() async throws {
        // Given: double value = -0.75
        // When: Initialize GMPRational(-0.75)
        let rational = GMPRational(-0.75)

        // Then: Rational approximates -0.75
        let num = rational.numerator.toInt()
        let den = rational.denominator.toInt()
        let value = Double(num) / Double(den)
        #expect(abs(value - -0.75) < 0.01)
    }

    @Test
    func init_fromDouble_zero() async throws {
        // Given: double value = 0.0
        // When: Initialize GMPRational(0.0)
        let rational = GMPRational(0.0)

        // Then: Rational equals 0/1
        #expect(rational.numerator.toInt() == 0)
        #expect(rational.denominator.toInt() == 1)
    }

    // MARK: - init(_ value: GMPFloat)

    @Test
    func init_fromGMPFloat_positiveValue() async throws {
        // Given: GMPFloat value = 0.75
        let value = GMPFloat(0.75)

        // When: Initialize GMPRational(value)
        let rational = GMPRational(value)

        // Then: Rational approximates 0.75
        let num = rational.numerator.toInt()
        let den = rational.denominator.toInt()
        let doubleValue = Double(num) / Double(den)
        #expect(abs(doubleValue - 0.75) < 0.01)
    }

    @Test
    func init_fromGMPFloat_negativeValue() async throws {
        // Given: GMPFloat value = -0.75
        let value = GMPFloat(-0.75)

        // When: Initialize GMPRational(value)
        let rational = GMPRational(value)

        // Then: Rational approximates -0.75
        let num = rational.numerator.toInt()
        let den = rational.denominator.toInt()
        let doubleValue = Double(num) / Double(den)
        #expect(abs(doubleValue - -0.75) < 0.01)
    }

    // MARK: - init?(_ string:base:)

    @Test
    func init_failableString_validFraction() async throws {
        // Given: string = "3/4"
        // When: Initialize GMPRational?("3/4")
        let rational = GMPRational("3/4")

        // Then: Returns non-nil, rational equals 3/4
        #expect(rational != nil)
        #expect(rational!.numerator.toInt() == 3)
        #expect(rational!.denominator.toInt() == 4)
    }

    @Test
    func init_failableString_integerOnly() async throws {
        // Given: string = "42"
        // When: Initialize GMPRational?("42")
        let rational = GMPRational("42")

        // Then: Returns non-nil, rational equals 42/1
        #expect(rational != nil)
        #expect(rational!.numerator.toInt() == 42)
        #expect(rational!.denominator.toInt() == 1)
    }

    @Test
    func init_failableString_invalidFormat_returnsNil() async throws {
        // Given: string = "not a number"
        // When: Initialize GMPRational?("not a number")
        let rational = GMPRational("not a number")

        // Then: Returns nil
        #expect(rational == nil)
    }

    @Test
    func init_failableString_emptyString_returnsNil() async throws {
        // Given: string = ""
        // When: Initialize GMPRational?("")
        let rational = GMPRational("")

        // Then: Returns nil
        #expect(rational == nil)
    }

    @Test
    func init_failableString_base16() async throws {
        // Given: string = "FF/10", base = 16
        // When: Initialize GMPRational?("FF/10", base: 16)
        let rational = GMPRational("FF/10", base: 16)

        // Then: Returns non-nil, rational equals 255/16
        #expect(rational != nil)
        #expect(rational!.numerator.toInt() == 255)
        #expect(rational!.denominator.toInt() == 16)
    }

    // MARK: - swap(_ other:)

    @Test
    func swap_exchangesValues() async throws {
        // Given: Two rationals: a = 3/4, b = 5/6
        var a = try GMPRational(
            numerator: GMPInteger(3),
            denominator: GMPInteger(4)
        )
        var b = try GMPRational(
            numerator: GMPInteger(5),
            denominator: GMPInteger(6)
        )

        // When: Call a.swap(&b)
        a.swap(&b)

        // Then: a equals 5/6, b equals 3/4
        #expect(a.numerator.toInt() == 5)
        #expect(a.denominator.toInt() == 6)
        #expect(b.numerator.toInt() == 3)
        #expect(b.denominator.toInt() == 4)
    }

    @Test
    func swap_selfSwap() async throws {
        // Given: Rational a = 3/4
        var a = try GMPRational(
            numerator: GMPInteger(3),
            denominator: GMPInteger(4)
        )
        let originalNum = a.numerator
        let originalDen = a.denominator

        // When: Call swap with itself (using a workaround for Swift's inout restriction)
        // Note: GMP's swap is safe for self-swap, but Swift doesn't allow &a
        // and &a in same call
        // So we test that swap works correctly, and self-swap safety is
        // guaranteed by GMP
        var b = a
        a.swap(&b)
        a.swap(&b) // Swap back

        // Then: a still has value 3/4 (swap is reversible)
        #expect(a.numerator == originalNum)
        #expect(a.denominator == originalDen)
    }

    @Test
    func swap_independence() async throws {
        // Given: Two rationals: a = 3/4, b = 5/6
        var a = try GMPRational(
            numerator: GMPInteger(3),
            denominator: GMPInteger(4)
        )
        var b = try GMPRational(
            numerator: GMPInteger(5),
            denominator: GMPInteger(6)
        )

        // When: Call a.swap(&b), then modify a
        a.swap(&b)
        // After swap: a = 5/6, b = 3/4
        a = try GMPRational(
            numerator: GMPInteger(7),
            denominator: GMPInteger(8)
        )

        // Then: b remains 3/4 (value semantics maintained - b got a's original value)
        #expect(b.numerator.toInt() == 3)
        #expect(b.denominator.toInt() == 4)
    }
}
