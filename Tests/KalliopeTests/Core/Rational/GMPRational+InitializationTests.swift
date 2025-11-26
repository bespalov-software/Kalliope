import CKalliope
@testable import Kalliope
import Testing

// MARK: - Initialization Tests

struct GMPRationalInitializationTests {
    @Test
    func init_createsZeroRational() async throws {
        // Given: No preconditions
        // When: A new GMPRational is initialized with init()
        let rational = GMPRational()

        // Then: The rational has value 0/1, numerator is 0, denominator is 1
        #expect(rational.numerator.toInt() == 0)
        #expect(rational.denominator.toInt() == 1)
    }

    @Test
    func init_isCanonical() async throws {
        // Given: No preconditions
        // When: A new GMPRational is initialized with init()
        let rational = GMPRational()

        // Then: The rational is in canonical form (denominator is positive, fraction is reduced)
        // For 0/1, this means:
        // - Denominator is positive (1 > 0)
        // - Fraction is reduced (gcd(0, 1) = 1)
        #expect(rational.denominator.toInt() > 0)
        #expect(rational.numerator.toInt() == 0)
        #expect(rational.denominator.toInt() == 1)
    }

    // MARK: - init(numerator:denominator:) with GMPInteger

    @Test
    func init_fromGMPInteger_positiveValues() async throws {
        // Given: Two positive GMPInteger values: numerator = 6, denominator = 8
        let num = GMPInteger(6)
        let den = GMPInteger(8)

        // When: Initialize GMPRational(numerator: 6, denominator: 8)
        let rational = try GMPRational(numerator: num, denominator: den)

        // Then: Rational is 3/4 (canonicalized), denominator is positive
        #expect(rational.numerator.toInt() == 3)
        #expect(rational.denominator.toInt() == 4)
    }

    @Test
    func init_fromGMPInteger_negativeNumerator() async throws {
        // Given: Negative numerator GMPInteger(-6), positive denominator GMPInteger(8)
        let num = GMPInteger(-6)
        let den = GMPInteger(8)

        // When: Initialize GMPRational(numerator: -6, denominator: 8)
        let rational = try GMPRational(numerator: num, denominator: den)

        // Then: Rational is -3/4 (canonicalized), denominator is positive
        #expect(rational.numerator.toInt() == -3)
        #expect(rational.denominator.toInt() == 4)
    }

    @Test
    func init_fromGMPInteger_negativeDenominator() async throws {
        // Given: Positive numerator GMPInteger(6), negative denominator GMPInteger(-8)
        let num = GMPInteger(6)
        let den = GMPInteger(-8)

        // When: Initialize GMPRational(numerator: 6, denominator: -8)
        let rational = try GMPRational(numerator: num, denominator: den)

        // Then: Rational is -3/4 (canonicalized), denominator is positive
        #expect(rational.numerator.toInt() == -3)
        #expect(rational.denominator.toInt() == 4)
    }

    @Test
    func init_fromGMPInteger_bothNegative() async throws {
        // Given: Both negative: numerator GMPInteger(-6), denominator GMPInteger(-8)
        let num = GMPInteger(-6)
        let den = GMPInteger(-8)

        // When: Initialize GMPRational(numerator: -6, denominator: -8)
        let rational = try GMPRational(numerator: num, denominator: den)

        // Then: Rational is 3/4 (canonicalized), denominator is positive
        #expect(rational.numerator.toInt() == 3)
        #expect(rational.denominator.toInt() == 4)
    }

    @Test
    func init_fromGMPInteger_alreadyCanonical() async throws {
        // Given: Already canonical values: numerator GMPInteger(3), denominator GMPInteger(4)
        let num = GMPInteger(3)
        let den = GMPInteger(4)

        // When: Initialize GMPRational(numerator: 3, denominator: 4)
        let rational = try GMPRational(numerator: num, denominator: den)

        // Then: Rational is 3/4, unchanged
        #expect(rational.numerator.toInt() == 3)
        #expect(rational.denominator.toInt() == 4)
    }

    @Test
    func init_fromGMPInteger_largeValues() async throws {
        // Given: Large GMPInteger values (e.g., 2^100, 2^50)
        let num = GMPInteger.power(base: 2, exponent: 100)
        let den = GMPInteger.power(base: 2, exponent: 50)

        // When: Initialize with these values
        let rational = try GMPRational(numerator: num, denominator: den)

        // Then: Rational is correctly canonicalized
        // 2^100 / 2^50 = 2^50 / 1
        let expected = GMPInteger.power(base: 2, exponent: 50)
        #expect(rational.numerator == expected)
        #expect(rational.denominator.toInt() == 1)
    }

    @Test
    func init_fromGMPInteger_zeroDenominator_throws() async throws {
        // Given: Numerator GMPInteger(5), denominator GMPInteger(0)
        let num = GMPInteger(5)
        let den = GMPInteger(0)

        // When: Initialize GMPRational(numerator: 5, denominator: 0)
        // Then: Throws GMPError.divisionByZero
        #expect(throws: GMPError.divisionByZero) {
            _ = try GMPRational(numerator: num, denominator: den)
        }
    }

    @Test
    func init_fromGMPInteger_zeroNumerator() async throws {
        // Given: Numerator GMPInteger(0), denominator GMPInteger(5)
        let num = GMPInteger(0)
        let den = GMPInteger(5)

        // When: Initialize GMPRational(numerator: 0, denominator: 5)
        let rational = try GMPRational(numerator: num, denominator: den)

        // Then: Rational is 0/1 (canonicalized to 0/1)
        #expect(rational.numerator.toInt() == 0)
        #expect(rational.denominator.toInt() == 1)
    }

    @Test
    func init_fromGMPInteger_denominatorOne() async throws {
        // Given: Numerator GMPInteger(42), denominator GMPInteger(1)
        let num = GMPInteger(42)
        let den = GMPInteger(1)

        // When: Initialize GMPRational(numerator: 42, denominator: 1)
        let rational = try GMPRational(numerator: num, denominator: den)

        // Then: Rational is 42/1 (or canonicalized equivalent)
        #expect(rational.numerator.toInt() == 42)
        #expect(rational.denominator.toInt() == 1)
    }

    @Test
    func init_fromGMPInteger_gcdReduction() async throws {
        // Given: Values with common factors: numerator GMPInteger(15), denominator GMPInteger(25)
        let num = GMPInteger(15)
        let den = GMPInteger(25)

        // When: Initialize GMPRational(numerator: 15, denominator: 25)
        let rational = try GMPRational(numerator: num, denominator: den)

        // Then: Rational is 3/5 (reduced by GCD)
        #expect(rational.numerator.toInt() == 3)
        #expect(rational.denominator.toInt() == 5)
    }

    // MARK: - init(numerator:denominator:) with Int

    @Test
    func init_fromInt_positiveValues() async throws {
        // Given: numerator = 6, denominator = 8 (both Int)
        // When: Initialize GMPRational(numerator: 6, denominator: 8)
        let rational = try GMPRational(numerator: 6, denominator: 8)

        // Then: Rational is 3/4 (canonicalized)
        #expect(rational.numerator.toInt() == 3)
        #expect(rational.denominator.toInt() == 4)
    }

    @Test
    func init_fromInt_negativeNumerator() async throws {
        // Given: numerator = -6, denominator = 8
        // When: Initialize GMPRational(numerator: -6, denominator: 8)
        let rational = try GMPRational(numerator: -6, denominator: 8)

        // Then: Rational is -3/4 (canonicalized)
        #expect(rational.numerator.toInt() == -3)
        #expect(rational.denominator.toInt() == 4)
    }

    @Test
    func init_fromInt_negativeDenominator() async throws {
        // Given: numerator = 6, denominator = -8
        // When: Initialize GMPRational(numerator: 6, denominator: -8)
        let rational = try GMPRational(numerator: 6, denominator: -8)

        // Then: Rational is -3/4 (canonicalized)
        #expect(rational.numerator.toInt() == -3)
        #expect(rational.denominator.toInt() == 4)
    }

    @Test
    func init_fromInt_maxIntValues() async throws {
        // Given: numerator = Int.max, denominator = Int.max
        // When: Initialize GMPRational(numerator: Int.max, denominator: Int.max)
        let rational = try GMPRational(numerator: Int.max, denominator: Int.max)

        // Then: Rational is 1/1 (canonicalized)
        #expect(rational.numerator.toInt() == 1)
        #expect(rational.denominator.toInt() == 1)
    }

    @Test
    func init_fromInt_minIntValues() async throws {
        // Given: numerator = Int.min, denominator = Int.max
        // When: Initialize GMPRational(numerator: Int.min, denominator: Int.max)
        let rational = try GMPRational(numerator: Int.min, denominator: Int.max)

        // Then: Rational is correctly canonicalized (negative value)
        // Int.min / Int.max should be negative
        #expect(rational.numerator.toInt() < 0)
        #expect(rational.denominator.toInt() > 0)
    }

    @Test
    func init_fromInt_zeroDenominator_throws() async throws {
        // Given: numerator = 5, denominator = 0
        // When: Initialize GMPRational(numerator: 5, denominator: 0)
        // Then: Throws GMPError.divisionByZero
        #expect(throws: GMPError.divisionByZero) {
            _ = try GMPRational(numerator: 5, denominator: 0)
        }
    }

    @Test
    func init_fromInt_zeroNumerator() async throws {
        // Given: numerator = 0, denominator = 5
        // When: Initialize GMPRational(numerator: 0, denominator: 5)
        let rational = try GMPRational(numerator: 0, denominator: 5)

        // Then: Rational is 0/1
        #expect(rational.numerator.toInt() == 0)
        #expect(rational.denominator.toInt() == 1)
    }

    // MARK: - init(numerator:denominator:) with UInt

    @Test
    func init_fromUInt_positiveValues() async throws {
        // Given: numerator = 6, denominator = 8 (both UInt)
        // When: Initialize GMPRational(numerator: 6, denominator: 8)
        let rational = try GMPRational(numerator: UInt(6), denominator: UInt(8))

        // Then: Rational is 3/4 (canonicalized)
        #expect(rational.numerator.toInt() == 3)
        #expect(rational.denominator.toInt() == 4)
    }

    @Test
    func init_fromUInt_maxUIntValues() async throws {
        // Given: numerator = UInt.max, denominator = UInt.max
        // When: Initialize GMPRational(numerator: UInt.max, denominator: UInt.max)
        let rational = try GMPRational(
            numerator: UInt.max,
            denominator: UInt.max
        )

        // Then: Rational is 1/1 (canonicalized)
        #expect(rational.numerator.toInt() == 1)
        #expect(rational.denominator.toInt() == 1)
    }

    @Test
    func init_fromUInt_zeroDenominator_throws() async throws {
        // Given: numerator = 5, denominator = 0 (both UInt)
        // When: Initialize GMPRational(numerator: 5, denominator: 0)
        // Then: Throws GMPError.divisionByZero
        #expect(throws: GMPError.divisionByZero) {
            _ = try GMPRational(numerator: UInt(5), denominator: UInt(0))
        }
    }

    @Test
    func init_fromUInt_zeroNumerator() async throws {
        // Given: numerator = 0, denominator = 5 (both UInt)
        // When: Initialize GMPRational(numerator: 0, denominator: 5)
        let rational = try GMPRational(numerator: UInt(0), denominator: UInt(5))

        // Then: Rational is 0/1
        #expect(rational.numerator.toInt() == 0)
        #expect(rational.denominator.toInt() == 1)
    }

    // MARK: - canonicalize()

    @Test
    func canonicalize_reducesFraction() async throws {
        // Given: Rational with value 6/8 (not canonical)
        // Create a rational and manually set to 6/8 without canonicalization
        var rational = GMPRational()
        rational._ensureUnique()
        let num = GMPInteger(6)
        let den = GMPInteger(8)
        __gmpq_set_num(&rational._storage.value, &num._storage.value)
        __gmpq_set_den(&rational._storage.value, &den._storage.value)
        // Verify it's not canonical
        #expect(rational.numerator.toInt() == 6)
        #expect(rational.denominator.toInt() == 8)

        // When: Call canonicalize()
        try rational.canonicalize()

        // Then: Rational becomes 3/4, denominator is positive
        #expect(rational.numerator.toInt() == 3)
        #expect(rational.denominator.toInt() == 4)
    }

    @Test
    func canonicalize_negativeDenominator() async throws {
        // Given: Rational with value 6/-8
        var rational = GMPRational()
        rational._ensureUnique()
        let num = GMPInteger(6)
        let den = GMPInteger(-8)
        __gmpq_set_num(&rational._storage.value, &num._storage.value)
        __gmpq_set_den(&rational._storage.value, &den._storage.value)

        // When: Call canonicalize()
        try rational.canonicalize()

        // Then: Rational becomes -3/4, denominator is positive
        #expect(rational.numerator.toInt() == -3)
        #expect(rational.denominator.toInt() == 4)
    }

    @Test
    func canonicalize_alreadyCanonical() async throws {
        // Given: Rational with value 3/4 (already canonical)
        let rational = try GMPRational(
            numerator: GMPInteger(3),
            denominator: GMPInteger(4)
        )
        var mutableRational = rational

        // When: Call canonicalize()
        try mutableRational.canonicalize()

        // Then: Rational remains 3/4, unchanged
        #expect(mutableRational.numerator.toInt() == 3)
        #expect(mutableRational.denominator.toInt() == 4)
    }

    @Test
    func canonicalize_largeValues() async throws {
        // Given: Rational with large numerator and denominator
        // Use 2^100 / 2^50 which should reduce to 2^50 / 1
        let num = GMPInteger.power(base: 2, exponent: 100)
        let den = GMPInteger.power(base: 2, exponent: 50)
        var rational = GMPRational()
        rational._ensureUnique()
        __gmpq_set_num(&rational._storage.value, &num._storage.value)
        __gmpq_set_den(&rational._storage.value, &den._storage.value)

        // When: Call canonicalize()
        try rational.canonicalize()

        // Then: Rational is reduced to lowest terms, denominator is positive
        let expected = GMPInteger.power(base: 2, exponent: 50)
        #expect(rational.numerator == expected)
        #expect(rational.denominator.toInt() == 1)
    }

    @Test
    func canonicalize_zeroNumerator() async throws {
        // Given: Rational with value 0/5
        var rational = GMPRational()
        rational._ensureUnique()
        let num = GMPInteger(0)
        let den = GMPInteger(5)
        __gmpq_set_num(&rational._storage.value, &num._storage.value)
        __gmpq_set_den(&rational._storage.value, &den._storage.value)

        // When: Call canonicalize()
        try rational.canonicalize()

        // Then: Rational becomes 0/1
        #expect(rational.numerator.toInt() == 0)
        #expect(rational.denominator.toInt() == 1)
    }

    @Test
    func canonicalize_zeroDenominator_throws() async throws {
        // Given: Rational with zero denominator (invalid state)
        // Create a rational and manually set denominator to 0
        // We need to ensure unique storage first
        var rational = GMPRational()
        rational._ensureUnique()
        let num = GMPInteger(5)
        let den = GMPInteger(0)
        __gmpq_set_num(&rational._storage.value, &num._storage.value)
        __gmpq_set_den(&rational._storage.value, &den._storage.value)

        // When: Call canonicalize()
        // Then: Throws GMPError.divisionByZero
        #expect(throws: GMPError.divisionByZero) {
            try rational.canonicalize()
        }
    }
}
