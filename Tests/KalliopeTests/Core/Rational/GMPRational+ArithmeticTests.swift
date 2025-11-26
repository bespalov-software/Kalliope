import CKalliope
@testable import Kalliope
import Testing

// MARK: - Arithmetic Tests

struct GMPRationalArithmeticTests {
    // MARK: - Immutable Operations

    // MARK: - adding(_ other:)

    @Test
    func adding_positiveRationals() async throws {
        // Given: a = 1/2, b = 1/3
        let a = try GMPRational(
            numerator: GMPInteger(1),
            denominator: GMPInteger(2)
        )
        let b = try GMPRational(
            numerator: GMPInteger(1),
            denominator: GMPInteger(3)
        )

        // When: Call a.adding(b)
        let result = a.adding(b)

        // Then: Returns 5/6 (canonicalized), a and b unchanged
        #expect(result.numerator.toInt() == 5)
        #expect(result.denominator.toInt() == 6)
        #expect(a.numerator.toInt() == 1)
        #expect(a.denominator.toInt() == 2)
        #expect(b.numerator.toInt() == 1)
        #expect(b.denominator.toInt() == 3)
    }

    @Test
    func adding_negativeRational() async throws {
        // Given: a = 1/2, b = -1/3
        let a = try GMPRational(
            numerator: GMPInteger(1),
            denominator: GMPInteger(2)
        )
        let b = try GMPRational(
            numerator: GMPInteger(-1),
            denominator: GMPInteger(3)
        )

        // When: Call a.adding(b)
        let result = a.adding(b)

        // Then: Returns 1/6 (canonicalized)
        #expect(result.numerator.toInt() == 1)
        #expect(result.denominator.toInt() == 6)
    }

    @Test
    func adding_zero() async throws {
        // Given: a = 3/4, b = 0/1
        let a = try GMPRational(
            numerator: GMPInteger(3),
            denominator: GMPInteger(4)
        )
        let b = GMPRational()

        // When: Call a.adding(b)
        let result = a.adding(b)

        // Then: Returns 3/4, a unchanged
        #expect(result.numerator.toInt() == 3)
        #expect(result.denominator.toInt() == 4)
        #expect(a.numerator.toInt() == 3)
        #expect(a.denominator.toInt() == 4)
    }

    @Test
    func adding_toZero() async throws {
        // Given: a = 0/1, b = 3/4
        let a = GMPRational()
        let b = try GMPRational(
            numerator: GMPInteger(3),
            denominator: GMPInteger(4)
        )

        // When: Call a.adding(b)
        let result = a.adding(b)

        // Then: Returns 3/4
        #expect(result.numerator.toInt() == 3)
        #expect(result.denominator.toInt() == 4)
    }

    @Test
    func adding_opposites() async throws {
        // Given: a = 3/4, b = -3/4
        let a = try GMPRational(
            numerator: GMPInteger(3),
            denominator: GMPInteger(4)
        )
        let b = try GMPRational(
            numerator: GMPInteger(-3),
            denominator: GMPInteger(4)
        )

        // When: Call a.adding(b)
        let result = a.adding(b)

        // Then: Returns 0/1
        #expect(result.numerator.toInt() == 0)
        #expect(result.denominator.toInt() == 1)
    }

    @Test
    func adding_largeValues() async throws {
        // Given: Two rationals with large numerators/denominators
        let largeNum1 = GMPInteger.power(base: 2, exponent: 50)
        let largeDen1 = GMPInteger.power(base: 2, exponent: 49)
        let largeNum2 = GMPInteger.power(base: 3, exponent: 30)
        let largeDen2 = GMPInteger.power(base: 3, exponent: 29)
        let a = try GMPRational(numerator: largeNum1, denominator: largeDen1)
        let b = try GMPRational(numerator: largeNum2, denominator: largeDen2)

        // When: Call a.adding(b)
        let result = a.adding(b)

        // Then: Returns correct canonicalized sum
        // a = 2^50/2^49 = 2/1, b = 3^30/3^29 = 3/1, so result = 5/1
        #expect(result.numerator.toInt() == 5)
        #expect(result.denominator.toInt() == 1)
    }

    @Test
    func adding_self() async throws {
        // Given: a = 3/4
        let a = try GMPRational(
            numerator: GMPInteger(3),
            denominator: GMPInteger(4)
        )

        // When: Call a.adding(a)
        let result = a.adding(a)

        // Then: Returns 3/2 (canonicalized), a unchanged
        #expect(result.numerator.toInt() == 3)
        #expect(result.denominator.toInt() == 2)
        #expect(a.numerator.toInt() == 3)
        #expect(a.denominator.toInt() == 4)
    }

    // MARK: - subtracting(_ other:)

    @Test
    func subtracting_positiveRationals() async throws {
        // Given: a = 1/2, b = 1/3
        let a = try GMPRational(
            numerator: GMPInteger(1),
            denominator: GMPInteger(2)
        )
        let b = try GMPRational(
            numerator: GMPInteger(1),
            denominator: GMPInteger(3)
        )

        // When: Call a.subtracting(b)
        let result = a.subtracting(b)

        // Then: Returns 1/6 (canonicalized), a and b unchanged
        #expect(result.numerator.toInt() == 1)
        #expect(result.denominator.toInt() == 6)
        #expect(a.numerator.toInt() == 1)
        #expect(a.denominator.toInt() == 2)
        #expect(b.numerator.toInt() == 1)
        #expect(b.denominator.toInt() == 3)
    }

    @Test
    func subtracting_negativeRational() async throws {
        // Given: a = 1/2, b = -1/3
        let a = try GMPRational(
            numerator: GMPInteger(1),
            denominator: GMPInteger(2)
        )
        let b = try GMPRational(
            numerator: GMPInteger(-1),
            denominator: GMPInteger(3)
        )

        // When: Call a.subtracting(b)
        let result = a.subtracting(b)

        // Then: Returns 5/6 (canonicalized)
        #expect(result.numerator.toInt() == 5)
        #expect(result.denominator.toInt() == 6)
    }

    @Test
    func subtracting_zero() async throws {
        // Given: a = 3/4, b = 0/1
        let a = try GMPRational(
            numerator: GMPInteger(3),
            denominator: GMPInteger(4)
        )
        let b = GMPRational()

        // When: Call a.subtracting(b)
        let result = a.subtracting(b)

        // Then: Returns 3/4, a unchanged
        #expect(result.numerator.toInt() == 3)
        #expect(result.denominator.toInt() == 4)
        #expect(a.numerator.toInt() == 3)
        #expect(a.denominator.toInt() == 4)
    }

    @Test
    func subtracting_fromZero() async throws {
        // Given: a = 0/1, b = 3/4
        let a = GMPRational()
        let b = try GMPRational(
            numerator: GMPInteger(3),
            denominator: GMPInteger(4)
        )

        // When: Call a.subtracting(b)
        let result = a.subtracting(b)

        // Then: Returns -3/4
        #expect(result.numerator.toInt() == -3)
        #expect(result.denominator.toInt() == 4)
    }

    @Test
    func subtracting_equalValues() async throws {
        // Given: a = 3/4, b = 3/4
        let a = try GMPRational(
            numerator: GMPInteger(3),
            denominator: GMPInteger(4)
        )
        let b = try GMPRational(
            numerator: GMPInteger(3),
            denominator: GMPInteger(4)
        )

        // When: Call a.subtracting(b)
        let result = a.subtracting(b)

        // Then: Returns 0/1
        #expect(result.numerator.toInt() == 0)
        #expect(result.denominator.toInt() == 1)
    }

    @Test
    func subtracting_self() async throws {
        // Given: a = 3/4
        let a = try GMPRational(
            numerator: GMPInteger(3),
            denominator: GMPInteger(4)
        )

        // When: Call a.subtracting(a)
        let result = a.subtracting(a)

        // Then: Returns 0/1, a unchanged
        #expect(result.numerator.toInt() == 0)
        #expect(result.denominator.toInt() == 1)
        #expect(a.numerator.toInt() == 3)
        #expect(a.denominator.toInt() == 4)
    }

    // MARK: - multiplied(by other:)

    @Test
    func multiplied_positiveRationals() async throws {
        // Given: a = 1/2, b = 2/3
        let a = try GMPRational(
            numerator: GMPInteger(1),
            denominator: GMPInteger(2)
        )
        let b = try GMPRational(
            numerator: GMPInteger(2),
            denominator: GMPInteger(3)
        )

        // When: Call a.multiplied(by: b)
        let result = a.multiplied(by: b)

        // Then: Returns 1/3 (canonicalized), a and b unchanged
        #expect(result.numerator.toInt() == 1)
        #expect(result.denominator.toInt() == 3)
        #expect(a.numerator.toInt() == 1)
        #expect(a.denominator.toInt() == 2)
        #expect(b.numerator.toInt() == 2)
        #expect(b.denominator.toInt() == 3)
    }

    @Test
    func multiplied_negativeRational() async throws {
        // Given: a = 1/2, b = -2/3
        let a = try GMPRational(
            numerator: GMPInteger(1),
            denominator: GMPInteger(2)
        )
        let b = try GMPRational(
            numerator: GMPInteger(-2),
            denominator: GMPInteger(3)
        )

        // When: Call a.multiplied(by: b)
        let result = a.multiplied(by: b)

        // Then: Returns -1/3 (canonicalized)
        #expect(result.numerator.toInt() == -1)
        #expect(result.denominator.toInt() == 3)
    }

    @Test
    func multiplied_byZero() async throws {
        // Given: a = 3/4, b = 0/1
        let a = try GMPRational(
            numerator: GMPInteger(3),
            denominator: GMPInteger(4)
        )
        let b = GMPRational()

        // When: Call a.multiplied(by: b)
        let result = a.multiplied(by: b)

        // Then: Returns 0/1
        #expect(result.numerator.toInt() == 0)
        #expect(result.denominator.toInt() == 1)
    }

    @Test
    func multiplied_zeroByValue() async throws {
        // Given: a = 0/1, b = 3/4
        let a = GMPRational()
        let b = try GMPRational(
            numerator: GMPInteger(3),
            denominator: GMPInteger(4)
        )

        // When: Call a.multiplied(by: b)
        let result = a.multiplied(by: b)

        // Then: Returns 0/1
        #expect(result.numerator.toInt() == 0)
        #expect(result.denominator.toInt() == 1)
    }

    @Test
    func multiplied_byOne() async throws {
        // Given: a = 3/4, b = 1/1
        let a = try GMPRational(
            numerator: GMPInteger(3),
            denominator: GMPInteger(4)
        )
        let b = try GMPRational(
            numerator: GMPInteger(1),
            denominator: GMPInteger(1)
        )

        // When: Call a.multiplied(by: b)
        let result = a.multiplied(by: b)

        // Then: Returns 3/4
        #expect(result.numerator.toInt() == 3)
        #expect(result.denominator.toInt() == 4)
    }

    @Test
    func multiplied_reciprocals() async throws {
        // Given: a = 3/4, b = 4/3
        let a = try GMPRational(
            numerator: GMPInteger(3),
            denominator: GMPInteger(4)
        )
        let b = try GMPRational(
            numerator: GMPInteger(4),
            denominator: GMPInteger(3)
        )

        // When: Call a.multiplied(by: b)
        let result = a.multiplied(by: b)

        // Then: Returns 1/1
        #expect(result.numerator.toInt() == 1)
        #expect(result.denominator.toInt() == 1)
    }

    @Test
    func multiplied_largeValues() async throws {
        // Given: Two rationals with large numerators/denominators
        let largeNum1 = GMPInteger.power(base: 2, exponent: 50)
        let largeDen1 = GMPInteger.power(base: 2, exponent: 49)
        let largeNum2 = GMPInteger.power(base: 3, exponent: 30)
        let largeDen2 = GMPInteger.power(base: 3, exponent: 29)
        let a = try GMPRational(numerator: largeNum1, denominator: largeDen1)
        let b = try GMPRational(numerator: largeNum2, denominator: largeDen2)

        // When: Call a.multiplied(by: b)
        let result = a.multiplied(by: b)

        // Then: Returns correct canonicalized product
        // a = 2^50/2^49 = 2/1, b = 3^30/3^29 = 3/1, so result = 6/1
        #expect(result.numerator.toInt() == 6)
        #expect(result.denominator.toInt() == 1)
    }

    // MARK: - divided(by other:)

    @Test
    func divided_positiveRationals() async throws {
        // Given: a = 1/2, b = 2/3
        let a = try GMPRational(
            numerator: GMPInteger(1),
            denominator: GMPInteger(2)
        )
        let b = try GMPRational(
            numerator: GMPInteger(2),
            denominator: GMPInteger(3)
        )

        // When: Call a.divided(by: b)
        let result = try a.divided(by: b)

        // Then: Returns 3/4 (canonicalized), a and b unchanged
        #expect(result.numerator.toInt() == 3)
        #expect(result.denominator.toInt() == 4)
        #expect(a.numerator.toInt() == 1)
        #expect(a.denominator.toInt() == 2)
        #expect(b.numerator.toInt() == 2)
        #expect(b.denominator.toInt() == 3)
    }

    @Test
    func divided_negativeRational() async throws {
        // Given: a = 1/2, b = -2/3
        let a = try GMPRational(
            numerator: GMPInteger(1),
            denominator: GMPInteger(2)
        )
        let b = try GMPRational(
            numerator: GMPInteger(-2),
            denominator: GMPInteger(3)
        )

        // When: Call a.divided(by: b)
        let result = try a.divided(by: b)

        // Then: Returns -3/4 (canonicalized)
        #expect(result.numerator.toInt() == -3)
        #expect(result.denominator.toInt() == 4)
    }

    @Test
    func divided_byZero_throws() async throws {
        // Given: a = 3/4, b = 0/1
        let a = try GMPRational(
            numerator: GMPInteger(3),
            denominator: GMPInteger(4)
        )
        let b = GMPRational()
        let originalNum = a.numerator
        let originalDen = a.denominator

        // When: Call a.divided(by: b)
        // Then: Throws GMPError.divisionByZero, a and b unchanged
        #expect(throws: GMPError.divisionByZero) {
            _ = try a.divided(by: b)
        }
        #expect(a.numerator == originalNum)
        #expect(a.denominator == originalDen)
    }

    @Test
    func divided_zeroByValue() async throws {
        // Given: a = 0/1, b = 3/4
        let a = GMPRational()
        let b = try GMPRational(
            numerator: GMPInteger(3),
            denominator: GMPInteger(4)
        )

        // When: Call a.divided(by: b)
        let result = try a.divided(by: b)

        // Then: Returns 0/1
        #expect(result.numerator.toInt() == 0)
        #expect(result.denominator.toInt() == 1)
    }

    @Test
    func divided_byOne() async throws {
        // Given: a = 3/4, b = 1/1
        let a = try GMPRational(
            numerator: GMPInteger(3),
            denominator: GMPInteger(4)
        )
        let b = try GMPRational(
            numerator: GMPInteger(1),
            denominator: GMPInteger(1)
        )

        // When: Call a.divided(by: b)
        let result = try a.divided(by: b)

        // Then: Returns 3/4
        #expect(result.numerator.toInt() == 3)
        #expect(result.denominator.toInt() == 4)
    }

    @Test
    func divided_bySelf() async throws {
        // Given: a = 3/4
        let a = try GMPRational(
            numerator: GMPInteger(3),
            denominator: GMPInteger(4)
        )

        // When: Call a.divided(by: a)
        let result = try a.divided(by: a)

        // Then: Returns 1/1, a unchanged
        #expect(result.numerator.toInt() == 1)
        #expect(result.denominator.toInt() == 1)
        #expect(a.numerator.toInt() == 3)
        #expect(a.denominator.toInt() == 4)
    }

    @Test
    func divided_largeValues() async throws {
        // Given: Two rationals with large numerators/denominators
        let largeNum1 = GMPInteger.power(base: 2, exponent: 50)
        let largeDen1 = GMPInteger.power(base: 2, exponent: 49)
        let largeNum2 = GMPInteger.power(base: 3, exponent: 30)
        let largeDen2 = GMPInteger.power(base: 3, exponent: 29)
        let a = try GMPRational(numerator: largeNum1, denominator: largeDen1)
        let b = try GMPRational(numerator: largeNum2, denominator: largeDen2)

        // When: Call a.divided(by: b)
        let result = try a.divided(by: b)

        // Then: Returns correct canonicalized quotient
        // a = 2^50/2^49 = 2/1, b = 3^30/3^29 = 3/1, so result = 2/3
        #expect(result.numerator.toInt() == 2)
        #expect(result.denominator.toInt() == 3)
    }

    // MARK: - negated()

    @Test
    func negated_positiveValue() async throws {
        // Given: a = 3/4
        let a = try GMPRational(
            numerator: GMPInteger(3),
            denominator: GMPInteger(4)
        )

        // When: Call a.negated()
        let result = a.negated()

        // Then: Returns -3/4, a unchanged
        #expect(result.numerator.toInt() == -3)
        #expect(result.denominator.toInt() == 4)
        #expect(a.numerator.toInt() == 3)
        #expect(a.denominator.toInt() == 4)
    }

    @Test
    func negated_negativeValue() async throws {
        // Given: a = -3/4
        let a = try GMPRational(
            numerator: GMPInteger(-3),
            denominator: GMPInteger(4)
        )

        // When: Call a.negated()
        let result = a.negated()

        // Then: Returns 3/4, a unchanged
        #expect(result.numerator.toInt() == 3)
        #expect(result.denominator.toInt() == 4)
        #expect(a.numerator.toInt() == -3)
        #expect(a.denominator.toInt() == 4)
    }

    @Test
    func negated_zero() async throws {
        // Given: a = 0/1
        let a = GMPRational()

        // When: Call a.negated()
        let result = a.negated()

        // Then: Returns 0/1, a unchanged
        #expect(result.numerator.toInt() == 0)
        #expect(result.denominator.toInt() == 1)
        #expect(a.numerator.toInt() == 0)
        #expect(a.denominator.toInt() == 1)
    }

    @Test
    func negated_doubleNegation() async throws {
        // Given: a = 3/4
        let a = try GMPRational(
            numerator: GMPInteger(3),
            denominator: GMPInteger(4)
        )

        // When: Call a.negated().negated()
        let result = a.negated().negated()

        // Then: Returns 3/4, a unchanged
        #expect(result.numerator.toInt() == 3)
        #expect(result.denominator.toInt() == 4)
        #expect(a.numerator.toInt() == 3)
        #expect(a.denominator.toInt() == 4)
    }

    // MARK: - absoluteValue()

    @Test
    func absoluteValue_positiveValue() async throws {
        // Given: a = 3/4
        let a = try GMPRational(
            numerator: GMPInteger(3),
            denominator: GMPInteger(4)
        )

        // When: Call a.absoluteValue()
        let result = a.absoluteValue()

        // Then: Returns 3/4, a unchanged
        #expect(result.numerator.toInt() == 3)
        #expect(result.denominator.toInt() == 4)
        #expect(a.numerator.toInt() == 3)
        #expect(a.denominator.toInt() == 4)
    }

    @Test
    func absoluteValue_negativeValue() async throws {
        // Given: a = -3/4
        let a = try GMPRational(
            numerator: GMPInteger(-3),
            denominator: GMPInteger(4)
        )

        // When: Call a.absoluteValue()
        let result = a.absoluteValue()

        // Then: Returns 3/4, a unchanged
        #expect(result.numerator.toInt() == 3)
        #expect(result.denominator.toInt() == 4)
        #expect(a.numerator.toInt() == -3)
        #expect(a.denominator.toInt() == 4)
    }

    @Test
    func absoluteValue_zero() async throws {
        // Given: a = 0/1
        let a = GMPRational()

        // When: Call a.absoluteValue()
        let result = a.absoluteValue()

        // Then: Returns 0/1, a unchanged
        #expect(result.numerator.toInt() == 0)
        #expect(result.denominator.toInt() == 1)
        #expect(a.numerator.toInt() == 0)
        #expect(a.denominator.toInt() == 1)
    }

    // MARK: - inverted()

    @Test
    func inverted_positiveValue() async throws {
        // Given: a = 3/4
        let a = try GMPRational(
            numerator: GMPInteger(3),
            denominator: GMPInteger(4)
        )

        // When: Call a.inverted()
        let result = try a.inverted()

        // Then: Returns 4/3 (canonicalized), a unchanged
        #expect(result.numerator.toInt() == 4)
        #expect(result.denominator.toInt() == 3)
        #expect(a.numerator.toInt() == 3)
        #expect(a.denominator.toInt() == 4)
    }

    @Test
    func inverted_negativeValue() async throws {
        // Given: a = -3/4
        let a = try GMPRational(
            numerator: GMPInteger(-3),
            denominator: GMPInteger(4)
        )

        // When: Call a.inverted()
        let result = try a.inverted()

        // Then: Returns -4/3 (canonicalized), a unchanged
        #expect(result.numerator.toInt() == -4)
        #expect(result.denominator.toInt() == 3)
        #expect(a.numerator.toInt() == -3)
        #expect(a.denominator.toInt() == 4)
    }

    @Test
    func inverted_zero_throws() async throws {
        // Given: a = 0/1
        let a = GMPRational()
        let originalNum = a.numerator
        let originalDen = a.denominator

        // When: Call a.inverted()
        // Then: Throws GMPError.divisionByZero, a unchanged
        #expect(throws: GMPError.divisionByZero) {
            _ = try a.inverted()
        }
        #expect(a.numerator == originalNum)
        #expect(a.denominator == originalDen)
    }

    @Test
    func inverted_one() async throws {
        // Given: a = 1/1
        let a = try GMPRational(
            numerator: GMPInteger(1),
            denominator: GMPInteger(1)
        )

        // When: Call a.inverted()
        let result = try a.inverted()

        // Then: Returns 1/1, a unchanged
        #expect(result.numerator.toInt() == 1)
        #expect(result.denominator.toInt() == 1)
        #expect(a.numerator.toInt() == 1)
        #expect(a.denominator.toInt() == 1)
    }

    @Test
    func inverted_doubleInversion() async throws {
        // Given: a = 3/4
        let a = try GMPRational(
            numerator: GMPInteger(3),
            denominator: GMPInteger(4)
        )

        // When: Call a.inverted().inverted()
        let result = try a.inverted().inverted()

        // Then: Returns 3/4, a unchanged
        #expect(result.numerator.toInt() == 3)
        #expect(result.denominator.toInt() == 4)
        #expect(a.numerator.toInt() == 3)
        #expect(a.denominator.toInt() == 4)
    }

    // MARK: - Mutable Operations

    // MARK: - add(_ other:)

    @Test
    func add_positiveRationals() async throws {
        // Given: a = 1/2, b = 1/3
        var a = try GMPRational(
            numerator: GMPInteger(1),
            denominator: GMPInteger(2)
        )
        let b = try GMPRational(
            numerator: GMPInteger(1),
            denominator: GMPInteger(3)
        )

        // When: Call a.add(b)
        a.add(b)

        // Then: a equals 5/6 (canonicalized), b unchanged
        #expect(a.numerator.toInt() == 5)
        #expect(a.denominator.toInt() == 6)
        #expect(b.numerator.toInt() == 1)
        #expect(b.denominator.toInt() == 3)
    }

    @Test
    func add_negativeRational() async throws {
        // Given: a = 1/2, b = -1/3
        var a = try GMPRational(
            numerator: GMPInteger(1),
            denominator: GMPInteger(2)
        )
        let b = try GMPRational(
            numerator: GMPInteger(-1),
            denominator: GMPInteger(3)
        )

        // When: Call a.add(b)
        a.add(b)

        // Then: a equals 1/6 (canonicalized)
        #expect(a.numerator.toInt() == 1)
        #expect(a.denominator.toInt() == 6)
    }

    @Test
    func add_zero() async throws {
        // Given: a = 3/4, b = 0/1
        var a = try GMPRational(
            numerator: GMPInteger(3),
            denominator: GMPInteger(4)
        )
        let b = GMPRational()

        // When: Call a.add(b)
        a.add(b)

        // Then: a equals 3/4 (unchanged)
        #expect(a.numerator.toInt() == 3)
        #expect(a.denominator.toInt() == 4)
    }

    @Test
    func add_self() async throws {
        // Given: a = 3/4
        var a = try GMPRational(
            numerator: GMPInteger(3),
            denominator: GMPInteger(4)
        )

        // When: Call a.add(a)
        a.add(a)

        // Then: a equals 3/2 (canonicalized)
        #expect(a.numerator.toInt() == 3)
        #expect(a.denominator.toInt() == 2)
    }

    // MARK: - subtract(_ other:)

    @Test
    func subtract_positiveRationals() async throws {
        // Given: a = 1/2, b = 1/3
        var a = try GMPRational(
            numerator: GMPInteger(1),
            denominator: GMPInteger(2)
        )
        let b = try GMPRational(
            numerator: GMPInteger(1),
            denominator: GMPInteger(3)
        )

        // When: Call a.subtract(b)
        a.subtract(b)

        // Then: a equals 1/6 (canonicalized), b unchanged
        #expect(a.numerator.toInt() == 1)
        #expect(a.denominator.toInt() == 6)
        #expect(b.numerator.toInt() == 1)
        #expect(b.denominator.toInt() == 3)
    }

    @Test
    func subtract_negativeRational() async throws {
        // Given: a = 1/2, b = -1/3
        var a = try GMPRational(
            numerator: GMPInteger(1),
            denominator: GMPInteger(2)
        )
        let b = try GMPRational(
            numerator: GMPInteger(-1),
            denominator: GMPInteger(3)
        )

        // When: Call a.subtract(b)
        a.subtract(b)

        // Then: a equals 5/6 (canonicalized)
        #expect(a.numerator.toInt() == 5)
        #expect(a.denominator.toInt() == 6)
    }

    @Test
    func subtract_zero() async throws {
        // Given: a = 3/4, b = 0/1
        var a = try GMPRational(
            numerator: GMPInteger(3),
            denominator: GMPInteger(4)
        )
        let b = GMPRational()

        // When: Call a.subtract(b)
        a.subtract(b)

        // Then: a equals 3/4 (unchanged)
        #expect(a.numerator.toInt() == 3)
        #expect(a.denominator.toInt() == 4)
    }

    @Test
    func subtract_self() async throws {
        // Given: a = 3/4
        var a = try GMPRational(
            numerator: GMPInteger(3),
            denominator: GMPInteger(4)
        )

        // When: Call a.subtract(a)
        a.subtract(a)

        // Then: a equals 0/1
        #expect(a.numerator.toInt() == 0)
        #expect(a.denominator.toInt() == 1)
    }

    // MARK: - multiply(by other:)

    @Test
    func multiply_positiveRationals() async throws {
        // Given: a = 1/2, b = 2/3
        var a = try GMPRational(
            numerator: GMPInteger(1),
            denominator: GMPInteger(2)
        )
        let b = try GMPRational(
            numerator: GMPInteger(2),
            denominator: GMPInteger(3)
        )

        // When: Call a.multiply(by: b)
        a.multiply(by: b)

        // Then: a equals 1/3 (canonicalized), b unchanged
        #expect(a.numerator.toInt() == 1)
        #expect(a.denominator.toInt() == 3)
        #expect(b.numerator.toInt() == 2)
        #expect(b.denominator.toInt() == 3)
    }

    @Test
    func multiply_negativeRational() async throws {
        // Given: a = 1/2, b = -2/3
        var a = try GMPRational(
            numerator: GMPInteger(1),
            denominator: GMPInteger(2)
        )
        let b = try GMPRational(
            numerator: GMPInteger(-2),
            denominator: GMPInteger(3)
        )

        // When: Call a.multiply(by: b)
        a.multiply(by: b)

        // Then: a equals -1/3 (canonicalized)
        #expect(a.numerator.toInt() == -1)
        #expect(a.denominator.toInt() == 3)
    }

    @Test
    func multiply_byZero() async throws {
        // Given: a = 3/4, b = 0/1
        var a = try GMPRational(
            numerator: GMPInteger(3),
            denominator: GMPInteger(4)
        )
        let b = GMPRational()

        // When: Call a.multiply(by: b)
        a.multiply(by: b)

        // Then: a equals 0/1
        #expect(a.numerator.toInt() == 0)
        #expect(a.denominator.toInt() == 1)
    }

    @Test
    func multiply_byOne() async throws {
        // Given: a = 3/4, b = 1/1
        var a = try GMPRational(
            numerator: GMPInteger(3),
            denominator: GMPInteger(4)
        )
        let b = try GMPRational(
            numerator: GMPInteger(1),
            denominator: GMPInteger(1)
        )

        // When: Call a.multiply(by: b)
        a.multiply(by: b)

        // Then: a equals 3/4 (unchanged)
        #expect(a.numerator.toInt() == 3)
        #expect(a.denominator.toInt() == 4)
    }

    // MARK: - divide(by other:)

    @Test
    func divide_positiveRationals() async throws {
        // Given: a = 1/2, b = 2/3
        var a = try GMPRational(
            numerator: GMPInteger(1),
            denominator: GMPInteger(2)
        )
        let b = try GMPRational(
            numerator: GMPInteger(2),
            denominator: GMPInteger(3)
        )

        // When: Call a.divide(by: b)
        try a.divide(by: b)

        // Then: a equals 3/4 (canonicalized), b unchanged
        #expect(a.numerator.toInt() == 3)
        #expect(a.denominator.toInt() == 4)
        #expect(b.numerator.toInt() == 2)
        #expect(b.denominator.toInt() == 3)
    }

    @Test
    func divide_negativeRational() async throws {
        // Given: a = 1/2, b = -2/3
        var a = try GMPRational(
            numerator: GMPInteger(1),
            denominator: GMPInteger(2)
        )
        let b = try GMPRational(
            numerator: GMPInteger(-2),
            denominator: GMPInteger(3)
        )

        // When: Call a.divide(by: b)
        try a.divide(by: b)

        // Then: a equals -3/4 (canonicalized)
        #expect(a.numerator.toInt() == -3)
        #expect(a.denominator.toInt() == 4)
    }

    @Test
    func divide_byZero_throws() async throws {
        // Given: a = 3/4, b = 0/1
        var a = try GMPRational(
            numerator: GMPInteger(3),
            denominator: GMPInteger(4)
        )
        let b = GMPRational()
        let originalNum = a.numerator
        let originalDen = a.denominator

        // When: Call a.divide(by: b)
        // Then: Throws GMPError.divisionByZero, a unchanged
        #expect(throws: GMPError.divisionByZero) {
            try a.divide(by: b)
        }
        #expect(a.numerator == originalNum)
        #expect(a.denominator == originalDen)
    }

    @Test
    func divide_byOne() async throws {
        // Given: a = 3/4, b = 1/1
        var a = try GMPRational(
            numerator: GMPInteger(3),
            denominator: GMPInteger(4)
        )
        let b = try GMPRational(
            numerator: GMPInteger(1),
            denominator: GMPInteger(1)
        )

        // When: Call a.divide(by: b)
        try a.divide(by: b)

        // Then: a equals 3/4 (unchanged)
        #expect(a.numerator.toInt() == 3)
        #expect(a.denominator.toInt() == 4)
    }

    @Test
    func divide_bySelf() async throws {
        // Given: a = 3/4
        var a = try GMPRational(
            numerator: GMPInteger(3),
            denominator: GMPInteger(4)
        )

        // When: Call a.divide(by: a)
        try a.divide(by: a)

        // Then: a equals 1/1
        #expect(a.numerator.toInt() == 1)
        #expect(a.denominator.toInt() == 1)
    }

    // MARK: - negate()

    @Test
    func negate_positiveValue() async throws {
        // Given: a = 3/4
        var a = try GMPRational(
            numerator: GMPInteger(3),
            denominator: GMPInteger(4)
        )

        // When: Call a.negate()
        a.negate()

        // Then: a equals -3/4
        #expect(a.numerator.toInt() == -3)
        #expect(a.denominator.toInt() == 4)
    }

    @Test
    func negate_negativeValue() async throws {
        // Given: a = -3/4
        var a = try GMPRational(
            numerator: GMPInteger(-3),
            denominator: GMPInteger(4)
        )

        // When: Call a.negate()
        a.negate()

        // Then: a equals 3/4
        #expect(a.numerator.toInt() == 3)
        #expect(a.denominator.toInt() == 4)
    }

    @Test
    func negate_zero() async throws {
        // Given: a = 0/1
        var a = GMPRational()

        // When: Call a.negate()
        a.negate()

        // Then: a equals 0/1 (unchanged)
        #expect(a.numerator.toInt() == 0)
        #expect(a.denominator.toInt() == 1)
    }

    @Test
    func negate_doubleNegation() async throws {
        // Given: a = 3/4
        var a = try GMPRational(
            numerator: GMPInteger(3),
            denominator: GMPInteger(4)
        )

        // When: Call a.negate(), then a.negate()
        a.negate()
        a.negate()

        // Then: a equals 3/4
        #expect(a.numerator.toInt() == 3)
        #expect(a.denominator.toInt() == 4)
    }

    // MARK: - makeAbsolute()

    @Test
    func makeAbsolute_positiveValue() async throws {
        // Given: a = 3/4
        var a = try GMPRational(
            numerator: GMPInteger(3),
            denominator: GMPInteger(4)
        )

        // When: Call a.makeAbsolute()
        a.makeAbsolute()

        // Then: a equals 3/4 (unchanged)
        #expect(a.numerator.toInt() == 3)
        #expect(a.denominator.toInt() == 4)
    }

    @Test
    func makeAbsolute_negativeValue() async throws {
        // Given: a = -3/4
        var a = try GMPRational(
            numerator: GMPInteger(-3),
            denominator: GMPInteger(4)
        )

        // When: Call a.makeAbsolute()
        a.makeAbsolute()

        // Then: a equals 3/4
        #expect(a.numerator.toInt() == 3)
        #expect(a.denominator.toInt() == 4)
    }

    @Test
    func makeAbsolute_zero() async throws {
        // Given: a = 0/1
        var a = GMPRational()

        // When: Call a.makeAbsolute()
        a.makeAbsolute()

        // Then: a equals 0/1 (unchanged)
        #expect(a.numerator.toInt() == 0)
        #expect(a.denominator.toInt() == 1)
    }

    // MARK: - invert()

    @Test
    func invert_positiveValue() async throws {
        // Given: a = 3/4
        var a = try GMPRational(
            numerator: GMPInteger(3),
            denominator: GMPInteger(4)
        )

        // When: Call a.invert()
        try a.invert()

        // Then: a equals 4/3 (canonicalized)
        #expect(a.numerator.toInt() == 4)
        #expect(a.denominator.toInt() == 3)
    }

    @Test
    func invert_negativeValue() async throws {
        // Given: a = -3/4
        var a = try GMPRational(
            numerator: GMPInteger(-3),
            denominator: GMPInteger(4)
        )

        // When: Call a.invert()
        try a.invert()

        // Then: a equals -4/3 (canonicalized)
        #expect(a.numerator.toInt() == -4)
        #expect(a.denominator.toInt() == 3)
    }

    @Test
    func invert_zero_throws() async throws {
        // Given: a = 0/1
        var a = GMPRational()
        let originalNum = a.numerator
        let originalDen = a.denominator

        // When: Call a.invert()
        // Then: Throws GMPError.divisionByZero, a unchanged
        #expect(throws: GMPError.divisionByZero) {
            try a.invert()
        }
        #expect(a.numerator == originalNum)
        #expect(a.denominator == originalDen)
    }

    @Test
    func invert_one() async throws {
        // Given: a = 1/1
        var a = try GMPRational(
            numerator: GMPInteger(1),
            denominator: GMPInteger(1)
        )

        // When: Call a.invert()
        try a.invert()

        // Then: a equals 1/1 (unchanged)
        #expect(a.numerator.toInt() == 1)
        #expect(a.denominator.toInt() == 1)
    }

    @Test
    func invert_doubleInversion() async throws {
        // Given: a = 3/4
        var a = try GMPRational(
            numerator: GMPInteger(3),
            denominator: GMPInteger(4)
        )

        // When: Call a.invert(), then a.invert()
        try a.invert()
        try a.invert()

        // Then: a equals 3/4
        #expect(a.numerator.toInt() == 3)
        #expect(a.denominator.toInt() == 4)
    }

    // MARK: - Power of 2 Operations

    // MARK: - multipliedByPowerOf2(_ exponent:)

    @Test
    func multipliedByPowerOf2_positiveExponent() async throws {
        // Given: a = 3/4, exponent = 2
        let a = try GMPRational(
            numerator: GMPInteger(3),
            denominator: GMPInteger(4)
        )

        // When: Call a.multipliedByPowerOf2(2)
        let result = a.multipliedByPowerOf2(2)

        // Then: Returns 3/1 (3/4 * 4 = 3), a unchanged
        #expect(result.numerator.toInt() == 3)
        #expect(result.denominator.toInt() == 1)
        #expect(a.numerator.toInt() == 3)
        #expect(a.denominator.toInt() == 4)
    }

    @Test
    func multipliedByPowerOf2_negativeExponent() async throws {
        // Given: a = 3/4, exponent = -2
        let a = try GMPRational(
            numerator: GMPInteger(3),
            denominator: GMPInteger(4)
        )

        // When: Call a.multipliedByPowerOf2(-2)
        let result = a.multipliedByPowerOf2(-2)

        // Then: Returns 3/16 (3/4 / 4), a unchanged
        #expect(result.numerator.toInt() == 3)
        #expect(result.denominator.toInt() == 16)
        #expect(a.numerator.toInt() == 3)
        #expect(a.denominator.toInt() == 4)
    }

    @Test
    func multipliedByPowerOf2_zeroExponent() async throws {
        // Given: a = 3/4, exponent = 0
        let a = try GMPRational(
            numerator: GMPInteger(3),
            denominator: GMPInteger(4)
        )

        // When: Call a.multipliedByPowerOf2(0)
        let result = a.multipliedByPowerOf2(0)

        // Then: Returns 3/4 (unchanged), a unchanged
        #expect(result.numerator.toInt() == 3)
        #expect(result.denominator.toInt() == 4)
        #expect(a.numerator.toInt() == 3)
        #expect(a.denominator.toInt() == 4)
    }

    @Test
    func multipliedByPowerOf2_largeExponent() async throws {
        // Given: a = 1/1, exponent = 100
        let a = try GMPRational(
            numerator: GMPInteger(1),
            denominator: GMPInteger(1)
        )

        // When: Call a.multipliedByPowerOf2(100)
        let result = a.multipliedByPowerOf2(100)

        // Then: Returns 2^100/1, a unchanged
        let expected = GMPInteger.power(base: 2, exponent: 100)
        #expect(result.numerator == expected)
        #expect(result.denominator.toInt() == 1)
        #expect(a.numerator.toInt() == 1)
        #expect(a.denominator.toInt() == 1)
    }

    @Test
    func multipliedByPowerOf2_largeNegativeExponent() async throws {
        // Given: a = 1/1, exponent = -100
        let a = try GMPRational(
            numerator: GMPInteger(1),
            denominator: GMPInteger(1)
        )

        // When: Call a.multipliedByPowerOf2(-100)
        let result = a.multipliedByPowerOf2(-100)

        // Then: Returns 1/2^100, a unchanged
        let expectedDen = GMPInteger.power(base: 2, exponent: 100)
        #expect(result.numerator.toInt() == 1)
        #expect(result.denominator == expectedDen)
        #expect(a.numerator.toInt() == 1)
        #expect(a.denominator.toInt() == 1)
    }

    // MARK: - dividedByPowerOf2(_ exponent:)

    @Test
    func dividedByPowerOf2_positiveExponent() async throws {
        // Given: a = 3/4, exponent = 2
        let a = try GMPRational(
            numerator: GMPInteger(3),
            denominator: GMPInteger(4)
        )

        // When: Call a.dividedByPowerOf2(2)
        let result = try a.dividedByPowerOf2(2)

        // Then: Returns 3/16 (3/4 / 4), a unchanged
        #expect(result.numerator.toInt() == 3)
        #expect(result.denominator.toInt() == 16)
        #expect(a.numerator.toInt() == 3)
        #expect(a.denominator.toInt() == 4)
    }

    @Test
    func dividedByPowerOf2_zeroExponent() async throws {
        // Given: a = 3/4, exponent = 0
        let a = try GMPRational(
            numerator: GMPInteger(3),
            denominator: GMPInteger(4)
        )

        // When: Call a.dividedByPowerOf2(0)
        let result = try a.dividedByPowerOf2(0)

        // Then: Returns 3/4 (unchanged), a unchanged
        #expect(result.numerator.toInt() == 3)
        #expect(result.denominator.toInt() == 4)
        #expect(a.numerator.toInt() == 3)
        #expect(a.denominator.toInt() == 4)
    }

    @Test
    func dividedByPowerOf2_largeExponent() async throws {
        // Given: a = 1/1, exponent = 100
        let a = try GMPRational(
            numerator: GMPInteger(1),
            denominator: GMPInteger(1)
        )

        // When: Call a.dividedByPowerOf2(100)
        let result = try a.dividedByPowerOf2(100)

        // Then: Returns 1/2^100, a unchanged
        let expectedDen = GMPInteger.power(base: 2, exponent: 100)
        #expect(result.numerator.toInt() == 1)
        #expect(result.denominator == expectedDen)
        #expect(a.numerator.toInt() == 1)
        #expect(a.denominator.toInt() == 1)
    }

    @Test
    func dividedByPowerOf2_negativeExponent_throws() async throws {
        // Given: a = 3/4, exponent = -2
        let a = try GMPRational(
            numerator: GMPInteger(3),
            denominator: GMPInteger(4)
        )
        let originalNum = a.numerator
        let originalDen = a.denominator

        // When: Call a.dividedByPowerOf2(-2)
        // Then: Throws GMPError.invalidExponent, a unchanged
        #expect(throws: GMPError.invalidExponent(-2)) {
            _ = try a.dividedByPowerOf2(-2)
        }
        #expect(a.numerator == originalNum)
        #expect(a.denominator == originalDen)
    }

    // MARK: - multiplyByPowerOf2(_ exponent:)

    @Test
    func multiplyByPowerOf2_positiveExponent() async throws {
        // Given: a = 3/4, exponent = 2
        var a = try GMPRational(
            numerator: GMPInteger(3),
            denominator: GMPInteger(4)
        )

        // When: Call a.multiplyByPowerOf2(2)
        a.multiplyByPowerOf2(2)

        // Then: a equals 3/1 (3/4 * 4 = 3)
        #expect(a.numerator.toInt() == 3)
        #expect(a.denominator.toInt() == 1)
    }

    @Test
    func multiplyByPowerOf2_negativeExponent() async throws {
        // Given: a = 3/4, exponent = -2
        var a = try GMPRational(
            numerator: GMPInteger(3),
            denominator: GMPInteger(4)
        )

        // When: Call a.multiplyByPowerOf2(-2)
        a.multiplyByPowerOf2(-2)

        // Then: a equals 3/16 (3/4 / 4)
        #expect(a.numerator.toInt() == 3)
        #expect(a.denominator.toInt() == 16)
    }

    @Test
    func multiplyByPowerOf2_zeroExponent() async throws {
        // Given: a = 3/4, exponent = 0
        var a = try GMPRational(
            numerator: GMPInteger(3),
            denominator: GMPInteger(4)
        )

        // When: Call a.multiplyByPowerOf2(0)
        a.multiplyByPowerOf2(0)

        // Then: a equals 3/4 (unchanged)
        #expect(a.numerator.toInt() == 3)
        #expect(a.denominator.toInt() == 4)
    }

    // MARK: - divideByPowerOf2(_ exponent:)

    @Test
    func divideByPowerOf2_positiveExponent() async throws {
        // Given: a = 3/4, exponent = 2
        var a = try GMPRational(
            numerator: GMPInteger(3),
            denominator: GMPInteger(4)
        )

        // When: Call a.divideByPowerOf2(2)
        try a.divideByPowerOf2(2)

        // Then: a equals 3/16 (3/4 / 4)
        #expect(a.numerator.toInt() == 3)
        #expect(a.denominator.toInt() == 16)
    }

    @Test
    func divideByPowerOf2_zeroExponent() async throws {
        // Given: a = 3/4, exponent = 0
        var a = try GMPRational(
            numerator: GMPInteger(3),
            denominator: GMPInteger(4)
        )

        // When: Call a.divideByPowerOf2(0)
        try a.divideByPowerOf2(0)

        // Then: a equals 3/4 (unchanged)
        #expect(a.numerator.toInt() == 3)
        #expect(a.denominator.toInt() == 4)
    }

    @Test
    func divideByPowerOf2_negativeExponent_throws() async throws {
        // Given: a = 3/4, exponent = -2
        var a = try GMPRational(
            numerator: GMPInteger(3),
            denominator: GMPInteger(4)
        )
        let originalNum = a.numerator
        let originalDen = a.denominator

        // When: Call a.divideByPowerOf2(-2)
        // Then: Throws GMPError.invalidExponent, a unchanged
        #expect(throws: GMPError.invalidExponent(-2)) {
            try a.divideByPowerOf2(-2)
        }
        #expect(a.numerator == originalNum)
        #expect(a.denominator == originalDen)
    }

    // MARK: - Operator Overloads

    // MARK: - + operator

    @Test
    func plusOperator_positiveRationals() async throws {
        // Given: a = 1/2, b = 1/3
        let a = try GMPRational(
            numerator: GMPInteger(1),
            denominator: GMPInteger(2)
        )
        let b = try GMPRational(
            numerator: GMPInteger(1),
            denominator: GMPInteger(3)
        )

        // When: Evaluate a + b
        let result = a + b

        // Then: Returns 5/6 (canonicalized), a and b unchanged
        #expect(result.numerator.toInt() == 5)
        #expect(result.denominator.toInt() == 6)
        #expect(a.numerator.toInt() == 1)
        #expect(a.denominator.toInt() == 2)
        #expect(b.numerator.toInt() == 1)
        #expect(b.denominator.toInt() == 3)
    }

    @Test
    func plusOperator_negativeRational() async throws {
        // Given: a = 1/2, b = -1/3
        let a = try GMPRational(
            numerator: GMPInteger(1),
            denominator: GMPInteger(2)
        )
        let b = try GMPRational(
            numerator: GMPInteger(-1),
            denominator: GMPInteger(3)
        )

        // When: Evaluate a + b
        let result = a + b

        // Then: Returns 1/6 (canonicalized)
        #expect(result.numerator.toInt() == 1)
        #expect(result.denominator.toInt() == 6)
    }

    @Test
    func plusOperator_zero() async throws {
        // Given: a = 3/4, b = 0/1
        let a = try GMPRational(
            numerator: GMPInteger(3),
            denominator: GMPInteger(4)
        )
        let b = GMPRational()

        // When: Evaluate a + b
        let result = a + b

        // Then: Returns 3/4
        #expect(result.numerator.toInt() == 3)
        #expect(result.denominator.toInt() == 4)
    }

    // MARK: - - operator

    @Test
    func minusOperator_positiveRationals() async throws {
        // Given: a = 1/2, b = 1/3
        let a = try GMPRational(
            numerator: GMPInteger(1),
            denominator: GMPInteger(2)
        )
        let b = try GMPRational(
            numerator: GMPInteger(1),
            denominator: GMPInteger(3)
        )

        // When: Evaluate a - b
        let result = a - b

        // Then: Returns 1/6 (canonicalized), a and b unchanged
        #expect(result.numerator.toInt() == 1)
        #expect(result.denominator.toInt() == 6)
        #expect(a.numerator.toInt() == 1)
        #expect(a.denominator.toInt() == 2)
        #expect(b.numerator.toInt() == 1)
        #expect(b.denominator.toInt() == 3)
    }

    @Test
    func minusOperator_negativeRational() async throws {
        // Given: a = 1/2, b = -1/3
        let a = try GMPRational(
            numerator: GMPInteger(1),
            denominator: GMPInteger(2)
        )
        let b = try GMPRational(
            numerator: GMPInteger(-1),
            denominator: GMPInteger(3)
        )

        // When: Evaluate a - b
        let result = a - b

        // Then: Returns 5/6 (canonicalized)
        #expect(result.numerator.toInt() == 5)
        #expect(result.denominator.toInt() == 6)
    }

    // MARK: - * operator

    @Test
    func multiplyOperator_positiveRationals() async throws {
        // Given: a = 1/2, b = 2/3
        let a = try GMPRational(
            numerator: GMPInteger(1),
            denominator: GMPInteger(2)
        )
        let b = try GMPRational(
            numerator: GMPInteger(2),
            denominator: GMPInteger(3)
        )

        // When: Evaluate a * b
        let result = a * b

        // Then: Returns 1/3 (canonicalized), a and b unchanged
        #expect(result.numerator.toInt() == 1)
        #expect(result.denominator.toInt() == 3)
        #expect(a.numerator.toInt() == 1)
        #expect(a.denominator.toInt() == 2)
        #expect(b.numerator.toInt() == 2)
        #expect(b.denominator.toInt() == 3)
    }

    @Test
    func multiplyOperator_negativeRational() async throws {
        // Given: a = 1/2, b = -2/3
        let a = try GMPRational(
            numerator: GMPInteger(1),
            denominator: GMPInteger(2)
        )
        let b = try GMPRational(
            numerator: GMPInteger(-2),
            denominator: GMPInteger(3)
        )

        // When: Evaluate a * b
        let result = a * b

        // Then: Returns -1/3 (canonicalized)
        #expect(result.numerator.toInt() == -1)
        #expect(result.denominator.toInt() == 3)
    }

    // MARK: - / operator

    @Test
    func divideOperator_positiveRationals() async throws {
        // Given: a = 1/2, b = 2/3
        let a = try GMPRational(
            numerator: GMPInteger(1),
            denominator: GMPInteger(2)
        )
        let b = try GMPRational(
            numerator: GMPInteger(2),
            denominator: GMPInteger(3)
        )

        // When: Evaluate a / b
        let result = try a / b

        // Then: Returns 3/4 (canonicalized), a and b unchanged
        #expect(result.numerator.toInt() == 3)
        #expect(result.denominator.toInt() == 4)
        #expect(a.numerator.toInt() == 1)
        #expect(a.denominator.toInt() == 2)
        #expect(b.numerator.toInt() == 2)
        #expect(b.denominator.toInt() == 3)
    }

    @Test
    func divideOperator_byZero_throws() async throws {
        // Given: a = 3/4, b = 0/1
        let a = try GMPRational(
            numerator: GMPInteger(3),
            denominator: GMPInteger(4)
        )
        let b = GMPRational()

        // When: Evaluate a / b
        // Then: Throws GMPError.divisionByZero
        #expect(throws: GMPError.divisionByZero) {
            _ = try a / b
        }
    }

    // MARK: - prefix - operator

    @Test
    func prefixMinus_positiveValue() async throws {
        // Given: a = 3/4
        let a = try GMPRational(
            numerator: GMPInteger(3),
            denominator: GMPInteger(4)
        )

        // When: Evaluate -a
        let result = -a

        // Then: Returns -3/4, a unchanged
        #expect(result.numerator.toInt() == -3)
        #expect(result.denominator.toInt() == 4)
        #expect(a.numerator.toInt() == 3)
        #expect(a.denominator.toInt() == 4)
    }

    @Test
    func prefixMinus_negativeValue() async throws {
        // Given: a = -3/4
        let a = try GMPRational(
            numerator: GMPInteger(-3),
            denominator: GMPInteger(4)
        )

        // When: Evaluate -a
        let result = -a

        // Then: Returns 3/4, a unchanged
        #expect(result.numerator.toInt() == 3)
        #expect(result.denominator.toInt() == 4)
        #expect(a.numerator.toInt() == -3)
        #expect(a.denominator.toInt() == 4)
    }

    @Test
    func prefixMinus_zero() async throws {
        // Given: a = 0/1
        let a = GMPRational()

        // When: Evaluate -a
        let result = -a

        // Then: Returns 0/1, a unchanged
        #expect(result.numerator.toInt() == 0)
        #expect(result.denominator.toInt() == 1)
        #expect(a.numerator.toInt() == 0)
        #expect(a.denominator.toInt() == 1)
    }

    // MARK: - += operator

    @Test
    func plusEquals_positiveRationals() async throws {
        // Given: a = 1/2, b = 1/3
        var a = try GMPRational(
            numerator: GMPInteger(1),
            denominator: GMPInteger(2)
        )
        let b = try GMPRational(
            numerator: GMPInteger(1),
            denominator: GMPInteger(3)
        )

        // When: Evaluate a += b
        a += b

        // Then: a equals 5/6 (canonicalized), b unchanged
        #expect(a.numerator.toInt() == 5)
        #expect(a.denominator.toInt() == 6)
        #expect(b.numerator.toInt() == 1)
        #expect(b.denominator.toInt() == 3)
    }

    @Test
    func plusEquals_zero() async throws {
        // Given: a = 3/4, b = 0/1
        var a = try GMPRational(
            numerator: GMPInteger(3),
            denominator: GMPInteger(4)
        )
        let b = GMPRational()

        // When: Evaluate a += b
        a += b

        // Then: a equals 3/4 (unchanged)
        #expect(a.numerator.toInt() == 3)
        #expect(a.denominator.toInt() == 4)
    }

    // MARK: - -= operator

    @Test
    func minusEquals_positiveRationals() async throws {
        // Given: a = 1/2, b = 1/3
        var a = try GMPRational(
            numerator: GMPInteger(1),
            denominator: GMPInteger(2)
        )
        let b = try GMPRational(
            numerator: GMPInteger(1),
            denominator: GMPInteger(3)
        )

        // When: Evaluate a -= b
        a -= b

        // Then: a equals 1/6 (canonicalized), b unchanged
        #expect(a.numerator.toInt() == 1)
        #expect(a.denominator.toInt() == 6)
        #expect(b.numerator.toInt() == 1)
        #expect(b.denominator.toInt() == 3)
    }

    @Test
    func minusEquals_zero() async throws {
        // Given: a = 3/4, b = 0/1
        var a = try GMPRational(
            numerator: GMPInteger(3),
            denominator: GMPInteger(4)
        )
        let b = GMPRational()

        // When: Evaluate a -= b
        a -= b

        // Then: a equals 3/4 (unchanged)
        #expect(a.numerator.toInt() == 3)
        #expect(a.denominator.toInt() == 4)
    }

    // MARK: - *= operator

    @Test
    func multiplyEquals_positiveRationals() async throws {
        // Given: a = 1/2, b = 2/3
        var a = try GMPRational(
            numerator: GMPInteger(1),
            denominator: GMPInteger(2)
        )
        let b = try GMPRational(
            numerator: GMPInteger(2),
            denominator: GMPInteger(3)
        )

        // When: Evaluate a *= b
        a *= b

        // Then: a equals 1/3 (canonicalized), b unchanged
        #expect(a.numerator.toInt() == 1)
        #expect(a.denominator.toInt() == 3)
        #expect(b.numerator.toInt() == 2)
        #expect(b.denominator.toInt() == 3)
    }

    @Test
    func multiplyEquals_byZero() async throws {
        // Given: a = 3/4, b = 0/1
        var a = try GMPRational(
            numerator: GMPInteger(3),
            denominator: GMPInteger(4)
        )
        let b = GMPRational()

        // When: Evaluate a *= b
        a *= b

        // Then: a equals 0/1
        #expect(a.numerator.toInt() == 0)
        #expect(a.denominator.toInt() == 1)
    }

    // MARK: - /= operator

    @Test
    func divideEquals_positiveRationals() async throws {
        // Given: a = 1/2, b = 2/3
        var a = try GMPRational(
            numerator: GMPInteger(1),
            denominator: GMPInteger(2)
        )
        let b = try GMPRational(
            numerator: GMPInteger(2),
            denominator: GMPInteger(3)
        )

        // When: Evaluate a /= b
        try a /= b

        // Then: a equals 3/4 (canonicalized), b unchanged
        #expect(a.numerator.toInt() == 3)
        #expect(a.denominator.toInt() == 4)
        #expect(b.numerator.toInt() == 2)
        #expect(b.denominator.toInt() == 3)
    }

    @Test
    func divideEquals_byZero_throws() async throws {
        // Given: a = 3/4, b = 0/1
        var a = try GMPRational(
            numerator: GMPInteger(3),
            denominator: GMPInteger(4)
        )
        let b = GMPRational()
        let originalNum = a.numerator
        let originalDen = a.denominator

        // When: Evaluate a /= b
        // Then: Throws GMPError.divisionByZero, a unchanged
        #expect(throws: GMPError.divisionByZero) {
            try a /= b
        }
        #expect(a.numerator == originalNum)
        #expect(a.denominator == originalDen)
    }
}
