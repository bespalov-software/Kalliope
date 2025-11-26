import CKalliope
@testable import Kalliope
import Testing

// MARK: - Component Access Tests

struct GMPRationalComponentsTests {
    // MARK: - numerator (getter)

    @Test
    func numerator_returnsCorrectValue() async throws {
        // Given: Rational a = 3/4
        let a = try GMPRational(
            numerator: GMPInteger(3),
            denominator: GMPInteger(4)
        )

        // When: Access a.numerator
        let num = a.numerator

        // Then: Returns GMPInteger(3)
        #expect(num.toInt() == 3)
    }

    @Test
    func numerator_negativeRational() async throws {
        // Given: Rational a = -3/4
        let a = try GMPRational(
            numerator: GMPInteger(-3),
            denominator: GMPInteger(4)
        )

        // When: Access a.numerator
        let num = a.numerator

        // Then: Returns GMPInteger(-3)
        #expect(num.toInt() == -3)
    }

    @Test
    func numerator_zeroRational() async throws {
        // Given: Rational a = 0/1
        let a = GMPRational()

        // When: Access a.numerator
        let num = a.numerator

        // Then: Returns GMPInteger(0)
        #expect(num.toInt() == 0)
    }

    @Test
    func numerator_returnsCopy() async throws {
        // Given: Rational a = 3/4
        let a = try GMPRational(
            numerator: GMPInteger(3),
            denominator: GMPInteger(4)
        )

        // When: Get num = a.numerator, modify num
        var num = a.numerator
        num = GMPInteger(100)
        _ = num // Modified but not read - test verifies original is unchanged

        // Then: a remains 3/4 (copy returned, not reference)
        #expect(a.numerator.toInt() == 3)
        #expect(a.denominator.toInt() == 4)
    }

    @Test
    func numerator_largeValue() async throws {
        // Given: Rational with large numerator
        let largeNum = GMPInteger.power(base: 2, exponent: 100)
        let a = try GMPRational(numerator: largeNum, denominator: GMPInteger(1))

        // When: Access a.numerator
        let num = a.numerator

        // Then: Returns correct large GMPInteger value
        #expect(num == largeNum)
    }

    // MARK: - denominator (getter)

    @Test
    func denominator_returnsCorrectValue() async throws {
        // Given: Rational a = 3/4
        let a = try GMPRational(
            numerator: GMPInteger(3),
            denominator: GMPInteger(4)
        )

        // When: Access a.denominator
        let den = a.denominator

        // Then: Returns GMPInteger(4)
        #expect(den.toInt() == 4)
    }

    @Test
    func denominator_alwaysPositive() async throws {
        // Given: Rational a = -3/4 (canonical form)
        let a = try GMPRational(
            numerator: GMPInteger(-3),
            denominator: GMPInteger(4)
        )

        // When: Access a.denominator
        let den = a.denominator

        // Then: Returns positive GMPInteger(4)
        #expect(den.toInt() == 4)
        #expect(den.toInt() > 0)
    }

    @Test
    func denominator_zeroRational() async throws {
        // Given: Rational a = 0/1
        let a = GMPRational()

        // When: Access a.denominator
        let den = a.denominator

        // Then: Returns GMPInteger(1)
        #expect(den.toInt() == 1)
    }

    @Test
    func denominator_returnsCopy() async throws {
        // Given: Rational a = 3/4
        let a = try GMPRational(
            numerator: GMPInteger(3),
            denominator: GMPInteger(4)
        )

        // When: Get den = a.denominator, modify den
        var den = a.denominator
        den = GMPInteger(100)
        _ = den // Modified but not read - test verifies original is unchanged

        // Then: a remains 3/4 (copy returned, not reference)
        #expect(a.numerator.toInt() == 3)
        #expect(a.denominator.toInt() == 4)
    }

    @Test
    func denominator_largeValue() async throws {
        // Given: Rational with large denominator
        let largeDen = GMPInteger.power(base: 2, exponent: 100)
        let a = try GMPRational(numerator: GMPInteger(1), denominator: largeDen)

        // When: Access a.denominator
        let den = a.denominator

        // Then: Returns correct large GMPInteger value
        #expect(den == largeDen)
    }

    // MARK: - setNumerator(_ value:)

    @Test
    func setNumerator_positiveValue() async throws {
        // Given: Rational a = 3/4, new numerator = 5
        var a = try GMPRational(
            numerator: GMPInteger(3),
            denominator: GMPInteger(4)
        )
        let newNum = GMPInteger(5)

        // When: Call a.setNumerator(5)
        a.setNumerator(newNum)

        // Then: a becomes 5/4 (may need canonicalization)
        #expect(a.numerator.toInt() == 5)
        #expect(a.denominator.toInt() == 4)
    }

    @Test
    func setNumerator_negativeValue() async throws {
        // Given: Rational a = 3/4, new numerator = -5
        var a = try GMPRational(
            numerator: GMPInteger(3),
            denominator: GMPInteger(4)
        )
        let newNum = GMPInteger(-5)

        // When: Call a.setNumerator(-5)
        a.setNumerator(newNum)

        // Then: a becomes -5/4 (may need canonicalization)
        #expect(a.numerator.toInt() == -5)
        #expect(a.denominator.toInt() == 4)
    }

    @Test
    func setNumerator_zero() async throws {
        // Given: Rational a = 3/4, new numerator = 0
        var a = try GMPRational(
            numerator: GMPInteger(3),
            denominator: GMPInteger(4)
        )
        let newNum = GMPInteger(0)

        // When: Call a.setNumerator(0)
        a.setNumerator(newNum)

        // Then: a becomes 0/4 (may need canonicalization to 0/1)
        #expect(a.numerator.toInt() == 0)
        // After canonicalization, denominator should be 1
        try a.canonicalize()
        #expect(a.denominator.toInt() == 1)
    }

    @Test
    func setNumerator_largeValue() async throws {
        // Given: Rational a = 3/4, large GMPInteger numerator
        var a = try GMPRational(
            numerator: GMPInteger(3),
            denominator: GMPInteger(4)
        )
        let largeNum = GMPInteger.power(base: 2, exponent: 100)

        // When: Call a.setNumerator(largeValue)
        a.setNumerator(largeNum)

        // Then: Numerator is set correctly
        #expect(a.numerator == largeNum)
        #expect(a.denominator.toInt() == 4)
    }

    @Test
    func setNumerator_requiresCanonicalization() async throws {
        // Given: Rational a = 3/4, new numerator = 6
        var a = try GMPRational(
            numerator: GMPInteger(3),
            denominator: GMPInteger(4)
        )
        let newNum = GMPInteger(6)

        // When: Call a.setNumerator(6), then a.canonicalize()
        a.setNumerator(newNum)
        try a.canonicalize()

        // Then: a becomes 3/2 (if denominator was 4, gcd(6,4)=2, so 6/4 = 3/2)
        #expect(a.numerator.toInt() == 3)
        #expect(a.denominator.toInt() == 2)
    }

    // MARK: - setDenominator(_ value:)

    @Test
    func setDenominator_positiveValue() async throws {
        // Given: Rational a = 3/4, new denominator = 5
        var a = try GMPRational(
            numerator: GMPInteger(3),
            denominator: GMPInteger(4)
        )
        let newDen = GMPInteger(5)

        // When: Call a.setDenominator(5)
        try a.setDenominator(newDen)

        // Then: a becomes 3/5 (may need canonicalization)
        #expect(a.numerator.toInt() == 3)
        #expect(a.denominator.toInt() == 5)
    }

    @Test
    func setDenominator_negativeValue() async throws {
        // Given: Rational a = 3/4, new denominator = -5
        var a = try GMPRational(
            numerator: GMPInteger(3),
            denominator: GMPInteger(4)
        )
        let newDen = GMPInteger(-5)
        // Store original values for comparison (not used in this test but kept
        // for clarity)
        _ = a.numerator
        _ = a.denominator

        // When: Call a.setDenominator(-5)
        try a.setDenominator(newDen)
        try a.canonicalize()

        // Then: a becomes -3/5 after canonicalization (sign adjusted)
        #expect(a.numerator.toInt() == -3)
        #expect(a.denominator.toInt() == 5)
    }

    @Test
    func setDenominator_zero_throws() async throws {
        // Given: Rational a = 3/4, new denominator = 0
        var a = try GMPRational(
            numerator: GMPInteger(3),
            denominator: GMPInteger(4)
        )
        let zero = GMPInteger(0)
        let originalNum = a.numerator
        let originalDen = a.denominator

        // When: Call a.setDenominator(0)
        // Then: Throws GMPError.divisionByZero, a is unchanged
        #expect(throws: GMPError.divisionByZero) {
            try a.setDenominator(zero)
        }
        #expect(a.numerator == originalNum)
        #expect(a.denominator == originalDen)
    }

    @Test
    func setDenominator_one() async throws {
        // Given: Rational a = 3/4, new denominator = 1
        var a = try GMPRational(
            numerator: GMPInteger(3),
            denominator: GMPInteger(4)
        )
        let one = GMPInteger(1)

        // When: Call a.setDenominator(1)
        try a.setDenominator(one)

        // Then: a becomes 3/1
        #expect(a.numerator.toInt() == 3)
        #expect(a.denominator.toInt() == 1)
    }

    @Test
    func setDenominator_largeValue() async throws {
        // Given: Rational a = 3/4, large GMPInteger denominator
        var a = try GMPRational(
            numerator: GMPInteger(3),
            denominator: GMPInteger(4)
        )
        let largeDen = GMPInteger.power(base: 2, exponent: 100)

        // When: Call a.setDenominator(largeValue)
        try a.setDenominator(largeDen)

        // Then: Denominator is set correctly
        #expect(a.numerator.toInt() == 3)
        #expect(a.denominator == largeDen)
    }

    @Test
    func setDenominator_requiresCanonicalization() async throws {
        // Given: Rational a = 3/4, new denominator = 6
        var a = try GMPRational(
            numerator: GMPInteger(3),
            denominator: GMPInteger(4)
        )
        let newDen = GMPInteger(6)

        // When: Call a.setDenominator(6), then a.canonicalize()
        try a.setDenominator(newDen)
        try a.canonicalize()

        // Then: a becomes 1/2 (if numerator was 3, gcd(3,6)=3, so 3/6 = 1/2)
        #expect(a.numerator.toInt() == 1)
        #expect(a.denominator.toInt() == 2)
    }
}
