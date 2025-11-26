@testable import Kalliope
import Testing

// MARK: - Comparison Tests

struct GMPRationalProtocolsTests {
    // MARK: - compare(to: GMPRational) Tests

    @Test
    func compareToRational_LessThan_ReturnsNegativeOne() async throws {
        // Given: self = GMPRational(1, 2), other = GMPRational(3, 4)
        let self_ = try GMPRational(
            numerator: GMPInteger(1),
            denominator: GMPInteger(2)
        )
        let other = try GMPRational(
            numerator: GMPInteger(3),
            denominator: GMPInteger(4)
        )

        // When: Call self.compare(to: other)
        let result = self_.compare(to: other)

        // Then: Returns -1
        #expect(result == -1)
    }

    @Test
    func compareToRational_Equal_ReturnsZero() async throws {
        // Given: self = GMPRational(1, 2), other = GMPRational(1, 2)
        let self_ = try GMPRational(
            numerator: GMPInteger(1),
            denominator: GMPInteger(2)
        )
        let other = try GMPRational(
            numerator: GMPInteger(1),
            denominator: GMPInteger(2)
        )

        // When: Call self.compare(to: other)
        let result = self_.compare(to: other)

        // Then: Returns 0
        #expect(result == 0)
    }

    @Test
    func compareToRational_GreaterThan_ReturnsOne() async throws {
        // Given: self = GMPRational(3, 4), other = GMPRational(1, 2)
        let self_ = try GMPRational(
            numerator: GMPInteger(3),
            denominator: GMPInteger(4)
        )
        let other = try GMPRational(
            numerator: GMPInteger(1),
            denominator: GMPInteger(2)
        )

        // When: Call self.compare(to: other)
        let result = self_.compare(to: other)

        // Then: Returns 1
        #expect(result == 1)
    }

    @Test
    func compareToRational_NegativeValues_ReturnsCorrectResult() async throws {
        // Given: self = GMPRational(-3, 4), other = GMPRational(-1, 2)
        let self_ = try GMPRational(
            numerator: GMPInteger(-3),
            denominator: GMPInteger(4)
        )
        let other = try GMPRational(
            numerator: GMPInteger(-1),
            denominator: GMPInteger(2)
        )

        // When: Call self.compare(to: other)
        let result = self_.compare(to: other)

        // Then: Returns -1 (more negative is less)
        #expect(result == -1)
    }

    @Test
    func compareToRational_Zero_ReturnsZero() async throws {
        // Given: self = GMPRational(0, 1), other = GMPRational(0, 1)
        let self_ = GMPRational()
        let other = GMPRational()

        // When: Call self.compare(to: other)
        let result = self_.compare(to: other)

        // Then: Returns 0
        #expect(result == 0)
    }

    @Test
    func compareToRational_CanonicalizedFractions_ComparesCorrectly(
    ) async throws {
        // Given: self = GMPRational(2, 4), other = GMPRational(1, 2)
        let self_ = try GMPRational(
            numerator: GMPInteger(2),
            denominator: GMPInteger(4)
        )
        let other = try GMPRational(
            numerator: GMPInteger(1),
            denominator: GMPInteger(2)
        )

        // When: Call self.compare(to: other)
        let result = self_.compare(to: other)

        // Then: Returns 0 (both canonicalized to 1/2)
        #expect(result == 0)
    }

    // MARK: - compare(to: GMPInteger) Tests

    @Test
    func compareToInteger_Equal_ReturnsZero() async throws {
        // Given: self = GMPRational(42, 1), integer = GMPInteger(42)
        let self_ = try GMPRational(
            numerator: GMPInteger(42),
            denominator: GMPInteger(1)
        )
        let integer = GMPInteger(42)

        // When: Call self.compare(to: integer)
        let result = self_.compare(to: integer)

        // Then: Returns 0
        #expect(result == 0)
    }

    @Test
    func compareToInteger_LessThan_ReturnsNegativeOne() async throws {
        // Given: self = GMPRational(41, 1), integer = GMPInteger(42)
        let self_ = try GMPRational(
            numerator: GMPInteger(41),
            denominator: GMPInteger(1)
        )
        let integer = GMPInteger(42)

        // When: Call self.compare(to: integer)
        let result = self_.compare(to: integer)

        // Then: Returns -1
        #expect(result == -1)
    }

    @Test
    func compareToInteger_GreaterThan_ReturnsOne() async throws {
        // Given: self = GMPRational(43, 1), integer = GMPInteger(42)
        let self_ = try GMPRational(
            numerator: GMPInteger(43),
            denominator: GMPInteger(1)
        )
        let integer = GMPInteger(42)

        // When: Call self.compare(to: integer)
        let result = self_.compare(to: integer)

        // Then: Returns 1
        #expect(result == 1)
    }

    @Test
    func compareToInteger_FractionLessThanInteger_ReturnsNegativeOne(
    ) async throws {
        // Given: self = GMPRational(1, 2), integer = GMPInteger(1)
        let self_ = try GMPRational(
            numerator: GMPInteger(1),
            denominator: GMPInteger(2)
        )
        let integer = GMPInteger(1)

        // When: Call self.compare(to: integer)
        let result = self_.compare(to: integer)

        // Then: Returns -1
        #expect(result == -1)
    }

    @Test
    func compareToInteger_FractionGreaterThanInteger_ReturnsOne() async throws {
        // Given: self = GMPRational(3, 2), integer = GMPInteger(1)
        let self_ = try GMPRational(
            numerator: GMPInteger(3),
            denominator: GMPInteger(2)
        )
        let integer = GMPInteger(1)

        // When: Call self.compare(to: integer)
        let result = self_.compare(to: integer)

        // Then: Returns 1
        #expect(result == 1)
    }

    @Test
    func compareToInteger_NegativeRational_ReturnsNegativeOne() async throws {
        // Given: self = GMPRational(-1, 2), integer = GMPInteger(0)
        let self_ = try GMPRational(
            numerator: GMPInteger(-1),
            denominator: GMPInteger(2)
        )
        let integer = GMPInteger(0)

        // When: Call self.compare(to: integer)
        let result = self_.compare(to: integer)

        // Then: Returns -1
        #expect(result == -1)
    }

    // MARK: - compare(to num: Int, den: Int) Tests

    @Test
    func compareToInt_Equal_ReturnsZero() async throws {
        // Given: self = GMPRational(42, 1), num = 42, den = 1
        let self_ = try GMPRational(
            numerator: GMPInteger(42),
            denominator: GMPInteger(1)
        )

        // When: Call self.compare(to: 42, den: 1)
        let result = self_.compare(to: 42, den: 1)

        // Then: Returns 0
        #expect(result == 0)
    }

    @Test
    func compareToInt_LessThan_ReturnsNegativeOne() async throws {
        // Given: self = GMPRational(1, 2), num = 1, den = 1
        let self_ = try GMPRational(
            numerator: GMPInteger(1),
            denominator: GMPInteger(2)
        )

        // When: Call self.compare(to: 1, den: 1)
        let result = self_.compare(to: 1, den: 1)

        // Then: Returns -1
        #expect(result == -1)
    }

    @Test
    func compareToInt_GreaterThan_ReturnsOne() async throws {
        // Given: self = GMPRational(3, 2), num = 1, den = 1
        let self_ = try GMPRational(
            numerator: GMPInteger(3),
            denominator: GMPInteger(2)
        )

        // When: Call self.compare(to: 1, den: 1)
        let result = self_.compare(to: 1, den: 1)

        // Then: Returns 1
        #expect(result == 1)
    }

    @Test
    func compareToInt_FractionEqual_ReturnsZero() async throws {
        // Given: self = GMPRational(1, 2), num = 1, den = 2
        let self_ = try GMPRational(
            numerator: GMPInteger(1),
            denominator: GMPInteger(2)
        )

        // When: Call self.compare(to: 1, den: 2)
        let result = self_.compare(to: 1, den: 2)

        // Then: Returns 0
        #expect(result == 0)
    }

    @Test
    func compareToInt_NegativeNumerator_ReturnsCorrectResult() async throws {
        // Given: self = GMPRational(-1, 2), num = -1, den = 2
        let self_ = try GMPRational(
            numerator: GMPInteger(-1),
            denominator: GMPInteger(2)
        )

        // When: Call self.compare(to: -1, den: 2)
        let result = self_.compare(to: -1, den: 2)

        // Then: Returns 0
        #expect(result == 0)
    }

    @Test
    func compareToInt_LargeValues_ReturnsCorrectResult() async throws {
        // Given: self = GMPRational with large value, num = Int.max, den = 1
        let largeNum = GMPInteger(Int.max)
        let self_ = try GMPRational(
            numerator: largeNum,
            denominator: GMPInteger(1)
        )

        // When: Call self.compare(to: Int.max, den: 1)
        let result = self_.compare(to: Int.max, den: 1)

        // Then: Returns correct comparison result (should be 0)
        #expect(result == 0)
    }

    @Test
    func compareToInt_ZeroNumerator_ReturnsCorrectResult() async throws {
        // Given: self = GMPRational(1, 2), num = 0, den = 1
        let self_ = try GMPRational(
            numerator: GMPInteger(1),
            denominator: GMPInteger(2)
        )

        // When: Call self.compare(to: 0, den: 1)
        let result = self_.compare(to: 0, den: 1)

        // Then: Returns 1 (1/2 > 0/1)
        #expect(result == 1)
    }

    @Test
    func compareToInt_ZeroNumerator_Equal_ReturnsZero() async throws {
        // Given: self = GMPRational(0, 1), num = 0, den = 1
        let self_ = GMPRational()

        // When: Call self.compare(to: 0, den: 1)
        let result = self_.compare(to: 0, den: 1)

        // Then: Returns 0 (0/1 == 0/1)
        #expect(result == 0)
    }

    // MARK: - sign property Tests

    @Test
    func sign_Positive_ReturnsOne() async throws {
        // Given: A GMPRational with value 1/2
        let rational = try GMPRational(
            numerator: GMPInteger(1),
            denominator: GMPInteger(2)
        )

        // When: Access sign property
        let result = rational.sign

        // Then: Returns 1
        #expect(result == 1)
    }

    @Test
    func sign_Zero_ReturnsZero() async throws {
        // Given: A GMPRational with value 0/1
        let rational = GMPRational()

        // When: Access sign property
        let result = rational.sign

        // Then: Returns 0
        #expect(result == 0)
    }

    @Test
    func sign_Negative_ReturnsNegativeOne() async throws {
        // Given: A GMPRational with value -1/2
        let rational = try GMPRational(
            numerator: GMPInteger(-1),
            denominator: GMPInteger(2)
        )

        // When: Access sign property
        let result = rational.sign

        // Then: Returns -1
        #expect(result == -1)
    }

    @Test
    func sign_LargePositive_ReturnsOne() async throws {
        // Given: A GMPRational with a very large positive value
        let largeNum = GMPInteger.power(base: 10, exponent: 100)
        let rational = try GMPRational(
            numerator: largeNum,
            denominator: GMPInteger(1)
        )

        // When: Access sign property
        let result = rational.sign

        // Then: Returns 1
        #expect(result == 1)
    }

    @Test
    func sign_LargeNegative_ReturnsNegativeOne() async throws {
        // Given: A GMPRational with a very large negative value
        let largeNum = GMPInteger.power(base: 10, exponent: 100)
        let rational = try GMPRational(
            numerator: largeNum.negated(),
            denominator: GMPInteger(1)
        )

        // When: Access sign property
        let result = rational.sign

        // Then: Returns -1
        #expect(result == -1)
    }

    // MARK: - isZero property Tests

    @Test
    func isZero_Zero_ReturnsTrue() async throws {
        // Given: A GMPRational with value 0/1
        let rational = GMPRational()

        // When: Access isZero property
        let result = rational.isZero

        // Then: Returns true
        #expect(result == true)
    }

    @Test
    func isZero_Positive_ReturnsFalse() async throws {
        // Given: A GMPRational with value 1/2
        let rational = try GMPRational(
            numerator: GMPInteger(1),
            denominator: GMPInteger(2)
        )

        // When: Access isZero property
        let result = rational.isZero

        // Then: Returns false
        #expect(result == false)
    }

    @Test
    func isZero_Negative_ReturnsFalse() async throws {
        // Given: A GMPRational with value -1/2
        let rational = try GMPRational(
            numerator: GMPInteger(-1),
            denominator: GMPInteger(2)
        )

        // When: Access isZero property
        let result = rational.isZero

        // Then: Returns false
        #expect(result == false)
    }

    @Test
    func isZero_CanonicalizedZero_ReturnsTrue() async throws {
        // Given: A GMPRational with value 0/5 (canonicalized to 0/1)
        let rational = try GMPRational(
            numerator: GMPInteger(0),
            denominator: GMPInteger(5)
        )

        // When: Access isZero property
        let result = rational.isZero

        // Then: Returns true
        #expect(result == true)
    }

    // MARK: - isNegative property Tests

    @Test
    func isNegative_Negative_ReturnsTrue() async throws {
        // Given: A GMPRational with value -1/2
        let rational = try GMPRational(
            numerator: GMPInteger(-1),
            denominator: GMPInteger(2)
        )

        // When: Access isNegative property
        let result = rational.isNegative

        // Then: Returns true
        #expect(result == true)
    }

    @Test
    func isNegative_Zero_ReturnsFalse() async throws {
        // Given: A GMPRational with value 0/1
        let rational = GMPRational()

        // When: Access isNegative property
        let result = rational.isNegative

        // Then: Returns false
        #expect(result == false)
    }

    @Test
    func isNegative_Positive_ReturnsFalse() async throws {
        // Given: A GMPRational with value 1/2
        let rational = try GMPRational(
            numerator: GMPInteger(1),
            denominator: GMPInteger(2)
        )

        // When: Access isNegative property
        let result = rational.isNegative

        // Then: Returns false
        #expect(result == false)
    }

    @Test
    func isNegative_LargeNegative_ReturnsTrue() async throws {
        // Given: A GMPRational with a very large negative value
        let largeNum = GMPInteger.power(base: 10, exponent: 100)
        let rational = try GMPRational(
            numerator: largeNum.negated(),
            denominator: GMPInteger(1)
        )

        // When: Access isNegative property
        let result = rational.isNegative

        // Then: Returns true
        #expect(result == true)
    }

    // MARK: - isPositive property Tests

    @Test
    func isPositive_Positive_ReturnsTrue() async throws {
        // Given: A GMPRational with value 1/2
        let rational = try GMPRational(
            numerator: GMPInteger(1),
            denominator: GMPInteger(2)
        )

        // When: Access isPositive property
        let result = rational.isPositive

        // Then: Returns true
        #expect(result == true)
    }

    @Test
    func isPositive_Zero_ReturnsFalse() async throws {
        // Given: A GMPRational with value 0/1
        let rational = GMPRational()

        // When: Access isPositive property
        let result = rational.isPositive

        // Then: Returns false
        #expect(result == false)
    }

    @Test
    func isPositive_Negative_ReturnsFalse() async throws {
        // Given: A GMPRational with value -1/2
        let rational = try GMPRational(
            numerator: GMPInteger(-1),
            denominator: GMPInteger(2)
        )

        // When: Access isPositive property
        let result = rational.isPositive

        // Then: Returns false
        #expect(result == false)
    }

    @Test
    func isPositive_LargePositive_ReturnsTrue() async throws {
        // Given: A GMPRational with a very large positive value
        let largeNum = GMPInteger.power(base: 10, exponent: 100)
        let rational = try GMPRational(
            numerator: largeNum,
            denominator: GMPInteger(1)
        )

        // When: Access isPositive property
        let result = rational.isPositive

        // Then: Returns true
        #expect(result == true)
    }

    // MARK: - < operator Tests

    @Test
    func lessThan_PositiveLessThanPositive_ReturnsTrue() async throws {
        // Given: lhs = GMPRational(1, 2), rhs = GMPRational(3, 4)
        let lhs = try GMPRational(
            numerator: GMPInteger(1),
            denominator: GMPInteger(2)
        )
        let rhs = try GMPRational(
            numerator: GMPInteger(3),
            denominator: GMPInteger(4)
        )

        // When: Evaluate lhs < rhs
        let result = lhs < rhs

        // Then: Returns true
        #expect(result == true)
    }

    @Test
    func lessThan_PositiveGreaterThanPositive_ReturnsFalse() async throws {
        // Given: lhs = GMPRational(3, 4), rhs = GMPRational(1, 2)
        let lhs = try GMPRational(
            numerator: GMPInteger(3),
            denominator: GMPInteger(4)
        )
        let rhs = try GMPRational(
            numerator: GMPInteger(1),
            denominator: GMPInteger(2)
        )

        // When: Evaluate lhs < rhs
        let result = lhs < rhs

        // Then: Returns false
        #expect(result == false)
    }

    @Test
    func lessThan_EqualValues_ReturnsFalse() async throws {
        // Given: lhs = GMPRational(1, 2), rhs = GMPRational(1, 2)
        let lhs = try GMPRational(
            numerator: GMPInteger(1),
            denominator: GMPInteger(2)
        )
        let rhs = try GMPRational(
            numerator: GMPInteger(1),
            denominator: GMPInteger(2)
        )

        // When: Evaluate lhs < rhs
        let result = lhs < rhs

        // Then: Returns false
        #expect(result == false)
    }

    @Test
    func lessThan_NegativeLessThanPositive_ReturnsTrue() async throws {
        // Given: lhs = GMPRational(-1, 2), rhs = GMPRational(1, 2)
        let lhs = try GMPRational(
            numerator: GMPInteger(-1),
            denominator: GMPInteger(2)
        )
        let rhs = try GMPRational(
            numerator: GMPInteger(1),
            denominator: GMPInteger(2)
        )

        // When: Evaluate lhs < rhs
        let result = lhs < rhs

        // Then: Returns true
        #expect(result == true)
    }

    @Test
    func lessThan_NegativeLessThanNegative_ReturnsTrue() async throws {
        // Given: lhs = GMPRational(-3, 4), rhs = GMPRational(-1, 2)
        let lhs = try GMPRational(
            numerator: GMPInteger(-3),
            denominator: GMPInteger(4)
        )
        let rhs = try GMPRational(
            numerator: GMPInteger(-1),
            denominator: GMPInteger(2)
        )

        // When: Evaluate lhs < rhs
        let result = lhs < rhs

        // Then: Returns true
        #expect(result == true)
    }

    @Test
    func lessThan_ZeroLessThanPositive_ReturnsTrue() async throws {
        // Given: lhs = GMPRational(0, 1), rhs = GMPRational(1, 2)
        let lhs = GMPRational()
        let rhs = try GMPRational(
            numerator: GMPInteger(1),
            denominator: GMPInteger(2)
        )

        // When: Evaluate lhs < rhs
        let result = lhs < rhs

        // Then: Returns true
        #expect(result == true)
    }

    @Test
    func lessThan_ZeroLessThanNegative_ReturnsFalse() async throws {
        // Given: lhs = GMPRational(0, 1), rhs = GMPRational(-1, 2)
        let lhs = GMPRational()
        let rhs = try GMPRational(
            numerator: GMPInteger(-1),
            denominator: GMPInteger(2)
        )

        // When: Evaluate lhs < rhs
        let result = lhs < rhs

        // Then: Returns false
        #expect(result == false)
    }

    // MARK: - <= operator Tests

    @Test
    func lessThanOrEqual_LessThan_ReturnsTrue() async throws {
        // Given: lhs = GMPRational(1, 2), rhs = GMPRational(3, 4)
        let lhs = try GMPRational(
            numerator: GMPInteger(1),
            denominator: GMPInteger(2)
        )
        let rhs = try GMPRational(
            numerator: GMPInteger(3),
            denominator: GMPInteger(4)
        )

        // When: Evaluate lhs <= rhs
        let result = lhs <= rhs

        // Then: Returns true
        #expect(result == true)
    }

    @Test
    func lessThanOrEqual_Equal_ReturnsTrue() async throws {
        // Given: lhs = GMPRational(1, 2), rhs = GMPRational(1, 2)
        let lhs = try GMPRational(
            numerator: GMPInteger(1),
            denominator: GMPInteger(2)
        )
        let rhs = try GMPRational(
            numerator: GMPInteger(1),
            denominator: GMPInteger(2)
        )

        // When: Evaluate lhs <= rhs
        let result = lhs <= rhs

        // Then: Returns true
        #expect(result == true)
    }

    @Test
    func lessThanOrEqual_GreaterThan_ReturnsFalse() async throws {
        // Given: lhs = GMPRational(3, 4), rhs = GMPRational(1, 2)
        let lhs = try GMPRational(
            numerator: GMPInteger(3),
            denominator: GMPInteger(4)
        )
        let rhs = try GMPRational(
            numerator: GMPInteger(1),
            denominator: GMPInteger(2)
        )

        // When: Evaluate lhs <= rhs
        let result = lhs <= rhs

        // Then: Returns false
        #expect(result == false)
    }

    @Test
    func lessThanOrEqual_Zero_ReturnsTrue() async throws {
        // Given: lhs = GMPRational(0, 1), rhs = GMPRational(0, 1)
        let lhs = GMPRational()
        let rhs = GMPRational()

        // When: Evaluate lhs <= rhs
        let result = lhs <= rhs

        // Then: Returns true
        #expect(result == true)
    }

    // MARK: - > operator Tests

    @Test
    func greaterThan_GreaterThan_ReturnsTrue() async throws {
        // Given: lhs = GMPRational(3, 4), rhs = GMPRational(1, 2)
        let lhs = try GMPRational(
            numerator: GMPInteger(3),
            denominator: GMPInteger(4)
        )
        let rhs = try GMPRational(
            numerator: GMPInteger(1),
            denominator: GMPInteger(2)
        )

        // When: Evaluate lhs > rhs
        let result = lhs > rhs

        // Then: Returns true
        #expect(result == true)
    }

    @Test
    func greaterThan_Equal_ReturnsFalse() async throws {
        // Given: lhs = GMPRational(1, 2), rhs = GMPRational(1, 2)
        let lhs = try GMPRational(
            numerator: GMPInteger(1),
            denominator: GMPInteger(2)
        )
        let rhs = try GMPRational(
            numerator: GMPInteger(1),
            denominator: GMPInteger(2)
        )

        // When: Evaluate lhs > rhs
        let result = lhs > rhs

        // Then: Returns false
        #expect(result == false)
    }

    @Test
    func greaterThan_LessThan_ReturnsFalse() async throws {
        // Given: lhs = GMPRational(1, 2), rhs = GMPRational(3, 4)
        let lhs = try GMPRational(
            numerator: GMPInteger(1),
            denominator: GMPInteger(2)
        )
        let rhs = try GMPRational(
            numerator: GMPInteger(3),
            denominator: GMPInteger(4)
        )

        // When: Evaluate lhs > rhs
        let result = lhs > rhs

        // Then: Returns false
        #expect(result == false)
    }

    @Test
    func greaterThan_PositiveGreaterThanNegative_ReturnsTrue() async throws {
        // Given: lhs = GMPRational(1, 2), rhs = GMPRational(-1, 2)
        let lhs = try GMPRational(
            numerator: GMPInteger(1),
            denominator: GMPInteger(2)
        )
        let rhs = try GMPRational(
            numerator: GMPInteger(-1),
            denominator: GMPInteger(2)
        )

        // When: Evaluate lhs > rhs
        let result = lhs > rhs

        // Then: Returns true
        #expect(result == true)
    }

    // MARK: - >= operator Tests

    @Test
    func greaterThanOrEqual_GreaterThan_ReturnsTrue() async throws {
        // Given: lhs = GMPRational(3, 4), rhs = GMPRational(1, 2)
        let lhs = try GMPRational(
            numerator: GMPInteger(3),
            denominator: GMPInteger(4)
        )
        let rhs = try GMPRational(
            numerator: GMPInteger(1),
            denominator: GMPInteger(2)
        )

        // When: Evaluate lhs >= rhs
        let result = lhs >= rhs

        // Then: Returns true
        #expect(result == true)
    }

    @Test
    func greaterThanOrEqual_Equal_ReturnsTrue() async throws {
        // Given: lhs = GMPRational(1, 2), rhs = GMPRational(1, 2)
        let lhs = try GMPRational(
            numerator: GMPInteger(1),
            denominator: GMPInteger(2)
        )
        let rhs = try GMPRational(
            numerator: GMPInteger(1),
            denominator: GMPInteger(2)
        )

        // When: Evaluate lhs >= rhs
        let result = lhs >= rhs

        // Then: Returns true
        #expect(result == true)
    }

    @Test
    func greaterThanOrEqual_LessThan_ReturnsFalse() async throws {
        // Given: lhs = GMPRational(1, 2), rhs = GMPRational(3, 4)
        let lhs = try GMPRational(
            numerator: GMPInteger(1),
            denominator: GMPInteger(2)
        )
        let rhs = try GMPRational(
            numerator: GMPInteger(3),
            denominator: GMPInteger(4)
        )

        // When: Evaluate lhs >= rhs
        let result = lhs >= rhs

        // Then: Returns false
        #expect(result == false)
    }

    // MARK: - == operator (Equatable) Tests

    @Test
    func equal_EqualValues_ReturnsTrue() async throws {
        // Given: lhs = GMPRational(1, 2), rhs = GMPRational(1, 2)
        let lhs = try GMPRational(
            numerator: GMPInteger(1),
            denominator: GMPInteger(2)
        )
        let rhs = try GMPRational(
            numerator: GMPInteger(1),
            denominator: GMPInteger(2)
        )

        // When: Evaluate lhs == rhs
        let result = lhs == rhs

        // Then: Returns true
        #expect(result == true)
    }

    @Test
    func equal_DifferentValues_ReturnsFalse() async throws {
        // Given: lhs = GMPRational(1, 2), rhs = GMPRational(3, 4)
        let lhs = try GMPRational(
            numerator: GMPInteger(1),
            denominator: GMPInteger(2)
        )
        let rhs = try GMPRational(
            numerator: GMPInteger(3),
            denominator: GMPInteger(4)
        )

        // When: Evaluate lhs == rhs
        let result = lhs == rhs

        // Then: Returns false
        #expect(result == false)
    }

    @Test
    func equal_CanonicalizedFractions_ReturnsTrue() async throws {
        // Given: lhs = GMPRational(2, 4), rhs = GMPRational(1, 2)
        let lhs = try GMPRational(
            numerator: GMPInteger(2),
            denominator: GMPInteger(4)
        )
        let rhs = try GMPRational(
            numerator: GMPInteger(1),
            denominator: GMPInteger(2)
        )

        // When: Evaluate lhs == rhs
        let result = lhs == rhs

        // Then: Returns true (both canonicalized to 1/2)
        #expect(result == true)
    }

    @Test
    func equal_Zero_ReturnsTrue() async throws {
        // Given: lhs = GMPRational(0, 1), rhs = GMPRational(0, 1)
        let lhs = GMPRational()
        let rhs = GMPRational()

        // When: Evaluate lhs == rhs
        let result = lhs == rhs

        // Then: Returns true
        #expect(result == true)
    }
}

// MARK: - Hashable Tests

extension GMPRationalProtocolsTests {
    @Test
    func gMPRationalHash_SameFraction_SameHash() async throws {
        let a = try GMPRational(numerator: 1, denominator: 2)
        let b = try GMPRational(numerator: 1, denominator: 2)

        var hasherA = Hasher()
        var hasherB = Hasher()
        a.hash(into: &hasherA)
        b.hash(into: &hasherB)

        #expect(hasherA.finalize() == hasherB.finalize())
    }

    @Test
    func gMPRationalHash_EquivalentFractions_SameHash() async throws {
        let a = try GMPRational(numerator: 1, denominator: 2)
        let b = try GMPRational(numerator: 2, denominator: 4)

        var hasherA = Hasher()
        var hasherB = Hasher()
        a.hash(into: &hasherA)
        b.hash(into: &hasherB)

        #expect(hasherA.finalize() == hasherB.finalize())
    }

    @Test
    func gMPRationalHash_DifferentFractions_DifferentHash() async throws {
        let a = try GMPRational(numerator: 1, denominator: 2)
        let b = try GMPRational(numerator: 1, denominator: 3)

        var hasherA = Hasher()
        var hasherB = Hasher()
        a.hash(into: &hasherA)
        b.hash(into: &hasherB)

        #expect(hasherA.finalize() != hasherB.finalize())
    }

    @Test
    func gMPRationalHash_Zero_ConsistentHash() async throws {
        let a = try GMPRational(numerator: 0, denominator: 1)
        let b = try GMPRational(numerator: 0, denominator: 5)

        var hasherA = Hasher()
        var hasherB = Hasher()
        a.hash(into: &hasherA)
        b.hash(into: &hasherB)

        #expect(hasherA.finalize() == hasherB.finalize())
    }

    @Test
    func gMPRationalHash_IntegerValue_SameHash() async throws {
        let a = try GMPRational(numerator: 42, denominator: 1)
        let b = try GMPRational(numerator: 42, denominator: 1)

        var hasherA = Hasher()
        var hasherB = Hasher()
        a.hash(into: &hasherA)
        b.hash(into: &hasherB)

        #expect(hasherA.finalize() == hasherB.finalize())
    }

    @Test
    func gMPRationalHash_EqualityImpliesSameHash() async throws {
        let a = try GMPRational(numerator: 1, denominator: 2)
        let b = try GMPRational(numerator: 2, denominator: 4)

        #expect(a == b)
        #expect(a.hashValue == b.hashValue)
    }

    @Test
    func gMPRationalHash_VeryLargeNumeratorDenominator_ComputesHash(
    ) async throws {
        let largeNum = GMPInteger("123456789012345678901234567890", base: 10)!
        let largeDen = GMPInteger("987654321098765432109876543210", base: 10)!
        let rational = try GMPRational(
            numerator: largeNum,
            denominator: largeDen
        )

        var hasher = Hasher()
        rational.hash(into: &hasher)
        let hash = hasher.finalize()

        // Just verify it computes without error
        #expect(hash != 0 || rational.isZero)
    }
}

// MARK: - CustomStringConvertible Tests

extension GMPRationalProtocolsTests {
    @Test
    func gMPRationalDescription_PositiveFraction_ReturnsDecimalString(
    ) async throws {
        let value = try GMPRational(numerator: 1, denominator: 2)
        let description = value.description
        #expect(description.contains("0.5") || description.contains("1/2"))
        #expect(description == value.toString())
    }

    @Test
    func gMPRationalDescription_Zero_ReturnsZero() async throws {
        let value = try GMPRational(numerator: 0, denominator: 1)
        #expect(value.description == "0")
        #expect(value.description == value.toString())
    }

    @Test
    func gMPRationalDescription_NegativeFraction_ReturnsDecimalStringWithMinus(
    ) async throws {
        let value = try GMPRational(numerator: -1, denominator: 2)
        let description = value.description
        #expect(description.contains("-"))
        #expect(description == value.toString())
    }

    @Test
    func gMPRationalDescription_IntegerValue_ReturnsDecimalString(
    ) async throws {
        let value = try GMPRational(numerator: 42, denominator: 1)
        let description = value.description
        #expect(description.contains("42"))
        #expect(description == value.toString())
    }

    @Test
    func gMPRationalDescription_MatchesToString() async throws {
        let value = try GMPRational(numerator: 22, denominator: 7)
        #expect(value.description == value.toString())
    }
}
