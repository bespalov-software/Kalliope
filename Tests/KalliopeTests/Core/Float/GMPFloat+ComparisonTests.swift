import Foundation
@testable import Kalliope
import Testing

// MARK: - Comparison Tests

struct GMPFloatComparisonTests {
    // MARK: - < (lhs:rhs:)

    @Test
    func lessThan_LeftSmaller_ReturnsTrue() async throws {
        // Given: lhs = GMPFloat(10.5), rhs = GMPFloat(20.5)
        let lhs = GMPFloat(10.5)
        let rhs = GMPFloat(20.5)

        // When: Evaluate lhs < rhs
        // Then: Returns true
        #expect(lhs < rhs)
    }

    @Test
    func lessThan_LeftLarger_ReturnsFalse() async throws {
        // Given: lhs = GMPFloat(20.5), rhs = GMPFloat(10.5)
        let lhs = GMPFloat(20.5)
        let rhs = GMPFloat(10.5)

        // When: Evaluate lhs < rhs
        // Then: Returns false
        #expect(!(lhs < rhs))
    }

    @Test
    func lessThan_Equal_ReturnsFalse() async throws {
        // Given: lhs = GMPFloat(10.5), rhs = GMPFloat(10.5)
        let lhs = GMPFloat(10.5)
        let rhs = GMPFloat(10.5)

        // When: Evaluate lhs < rhs
        // Then: Returns false
        #expect(!(lhs < rhs))
    }

    @Test
    func lessThan_NegativeLeft_ReturnsTrue() async throws {
        // Given: lhs = GMPFloat(-10.5), rhs = GMPFloat(10.5)
        let lhs = GMPFloat(-10.5)
        let rhs = GMPFloat(10.5)

        // When: Evaluate lhs < rhs
        // Then: Returns true
        #expect(lhs < rhs)
    }

    @Test
    func lessThan_BothNegative_LeftSmaller_ReturnsTrue() async throws {
        // Given: lhs = GMPFloat(-20.5), rhs = GMPFloat(-10.5)
        let lhs = GMPFloat(-20.5)
        let rhs = GMPFloat(-10.5)

        // When: Evaluate lhs < rhs
        // Then: Returns true
        #expect(lhs < rhs)
    }

    @Test
    func lessThan_DifferentPrecisions_ComparesCorrectly() async throws {
        // Given: lhs = GMPFloat(precision: 53) with value 10.5, rhs = GMPFloat(precision: 256) with value 10.5
        var lhs = try GMPFloat(precision: 53)
        lhs.set(10.5)
        var rhs = try GMPFloat(precision: 256)
        rhs.set(10.5)

        // When: Evaluate lhs < rhs
        // Then: Returns false (equal values)
        #expect(!(lhs < rhs))
    }

    // MARK: - <= (lhs:rhs:)

    @Test
    func lessThanOrEqual_LeftSmaller_ReturnsTrue() async throws {
        // Given: lhs = GMPFloat(10.5), rhs = GMPFloat(20.5)
        let lhs = GMPFloat(10.5)
        let rhs = GMPFloat(20.5)

        // When: Evaluate lhs <= rhs
        // Then: Returns true
        #expect(lhs <= rhs)
    }

    @Test
    func lessThanOrEqual_Equal_ReturnsTrue() async throws {
        // Given: lhs = GMPFloat(10.5), rhs = GMPFloat(10.5)
        let lhs = GMPFloat(10.5)
        let rhs = GMPFloat(10.5)

        // When: Evaluate lhs <= rhs
        // Then: Returns true
        #expect(lhs <= rhs)
    }

    @Test
    func lessThanOrEqual_LeftLarger_ReturnsFalse() async throws {
        // Given: lhs = GMPFloat(20.5), rhs = GMPFloat(10.5)
        let lhs = GMPFloat(20.5)
        let rhs = GMPFloat(10.5)

        // When: Evaluate lhs <= rhs
        // Then: Returns false
        #expect(!(lhs <= rhs))
    }

    // MARK: - > (lhs:rhs:)

    @Test
    func greaterThan_LeftLarger_ReturnsTrue() async throws {
        // Given: lhs = GMPFloat(20.5), rhs = GMPFloat(10.5)
        let lhs = GMPFloat(20.5)
        let rhs = GMPFloat(10.5)

        // When: Evaluate lhs > rhs
        // Then: Returns true
        #expect(lhs > rhs)
    }

    @Test
    func greaterThan_LeftSmaller_ReturnsFalse() async throws {
        // Given: lhs = GMPFloat(10.5), rhs = GMPFloat(20.5)
        let lhs = GMPFloat(10.5)
        let rhs = GMPFloat(20.5)

        // When: Evaluate lhs > rhs
        // Then: Returns false
        #expect(!(lhs > rhs))
    }

    @Test
    func greaterThan_Equal_ReturnsFalse() async throws {
        // Given: lhs = GMPFloat(10.5), rhs = GMPFloat(10.5)
        let lhs = GMPFloat(10.5)
        let rhs = GMPFloat(10.5)

        // When: Evaluate lhs > rhs
        // Then: Returns false
        #expect(!(lhs > rhs))
    }

    // MARK: - >= (lhs:rhs:)

    @Test
    func greaterThanOrEqual_LeftLarger_ReturnsTrue() async throws {
        // Given: lhs = GMPFloat(20.5), rhs = GMPFloat(10.5)
        let lhs = GMPFloat(20.5)
        let rhs = GMPFloat(10.5)

        // When: Evaluate lhs >= rhs
        // Then: Returns true
        #expect(lhs >= rhs)
    }

    @Test
    func greaterThanOrEqual_Equal_ReturnsTrue() async throws {
        // Given: lhs = GMPFloat(10.5), rhs = GMPFloat(10.5)
        let lhs = GMPFloat(10.5)
        let rhs = GMPFloat(10.5)

        // When: Evaluate lhs >= rhs
        // Then: Returns true
        #expect(lhs >= rhs)
    }

    @Test
    func greaterThanOrEqual_LeftSmaller_ReturnsFalse() async throws {
        // Given: lhs = GMPFloat(10.5), rhs = GMPFloat(20.5)
        let lhs = GMPFloat(10.5)
        let rhs = GMPFloat(20.5)

        // When: Evaluate lhs >= rhs
        // Then: Returns false
        #expect(!(lhs >= rhs))
    }

    // MARK: - compare(to other: GMPFloat)

    @Test
    func compare_Smaller_ReturnsNegativeOne() async throws {
        // Given: self = GMPFloat(10.5), other = GMPFloat(20.5)
        let selfFloat = GMPFloat(10.5)
        let other = GMPFloat(20.5)

        // When: Call compare(to: other)
        // Then: Returns -1
        #expect(selfFloat.compare(to: other) == -1)
    }

    @Test
    func compare_Equal_ReturnsZero() async throws {
        // Given: self = GMPFloat(10.5), other = GMPFloat(10.5)
        let selfFloat = GMPFloat(10.5)
        let other = GMPFloat(10.5)

        // When: Call compare(to: other)
        // Then: Returns 0
        #expect(selfFloat.compare(to: other) == 0)
    }

    @Test
    func compare_Larger_ReturnsOne() async throws {
        // Given: self = GMPFloat(20.5), other = GMPFloat(10.5)
        let selfFloat = GMPFloat(20.5)
        let other = GMPFloat(10.5)

        // When: Call compare(to: other)
        // Then: Returns 1
        #expect(selfFloat.compare(to: other) == 1)
    }

    @Test
    func compare_Negative_ReturnsNegativeOne() async throws {
        // Given: self = GMPFloat(-10.5), other = GMPFloat(10.5)
        let selfFloat = GMPFloat(-10.5)
        let other = GMPFloat(10.5)

        // When: Call compare(to: other)
        // Then: Returns -1
        #expect(selfFloat.compare(to: other) == -1)
    }

    @Test
    func compare_BothNegative_SmallerAbsolute_ReturnsOne() async throws {
        // Given: self = GMPFloat(-10.5), other = GMPFloat(-20.5)
        let selfFloat = GMPFloat(-10.5)
        let other = GMPFloat(-20.5)

        // When: Call compare(to: other)
        // Then: Returns 1 (-10.5 > -20.5)
        #expect(selfFloat.compare(to: other) == 1)
    }

    @Test
    func compare_DifferentPrecisions_ComparesValues() async throws {
        // Given: self = GMPFloat(precision: 53) with value 10.5, other = GMPFloat(precision: 256) with value 10.5
        var selfFloat = try GMPFloat(precision: 53)
        selfFloat.set(10.5)
        var other = try GMPFloat(precision: 256)
        other.set(10.5)

        // When: Call compare(to: other)
        // Then: Returns 0 (equal values despite different precisions)
        #expect(selfFloat.compare(to: other) == 0)
    }

    // MARK: - compare(to integer: GMPInteger)

    @Test
    func compareGMPInteger_Smaller_ReturnsNegativeOne() async throws {
        // Given: self = GMPFloat(10.5), integer = GMPInteger(20)
        let selfFloat = GMPFloat(10.5)
        let integer = GMPInteger(20)

        // When: Call compare(to: integer)
        // Then: Returns -1
        #expect(selfFloat.compare(to: integer) == -1)
    }

    @Test
    func compareGMPInteger_Equal_ReturnsZero() async throws {
        // Given: self = GMPFloat(10.0), integer = GMPInteger(10)
        let selfFloat = GMPFloat(10.0)
        let integer = GMPInteger(10)

        // When: Call compare(to: integer)
        // Then: Returns 0
        #expect(selfFloat.compare(to: integer) == 0)
    }

    @Test
    func compareGMPInteger_Larger_ReturnsOne() async throws {
        // Given: self = GMPFloat(20.5), integer = GMPInteger(10)
        let selfFloat = GMPFloat(20.5)
        let integer = GMPInteger(10)

        // When: Call compare(to: integer)
        // Then: Returns 1
        #expect(selfFloat.compare(to: integer) == 1)
    }

    @Test
    func compareGMPInteger_Negative_ReturnsNegativeOne() async throws {
        // Given: self = GMPFloat(-10.5), integer = GMPInteger(10)
        let selfFloat = GMPFloat(-10.5)
        let integer = GMPInteger(10)

        // When: Call compare(to: integer)
        // Then: Returns -1
        #expect(selfFloat.compare(to: integer) == -1)
    }

    @Test
    func compareGMPInteger_FractionalVsInteger_ComparesCorrectly() async throws {
        // Given: self = GMPFloat(10.5), integer = GMPInteger(10)
        let selfFloat = GMPFloat(10.5)
        let integer = GMPInteger(10)

        // When: Call compare(to: integer)
        // Then: Returns 1 (10.5 > 10)
        #expect(selfFloat.compare(to: integer) == 1)
    }

    // MARK: - compare(to value: Double)

    @Test
    func compareDouble_Smaller_ReturnsNegativeOne() async throws {
        // Given: self = GMPFloat(10.5), value = 20.5
        let selfFloat = GMPFloat(10.5)

        // When: Call compare(to: value)
        // Then: Returns -1
        #expect(selfFloat.compare(to: 20.5) == -1)
    }

    @Test
    func compareDouble_Equal_ReturnsZero() async throws {
        // Given: self = GMPFloat(10.5), value = 10.5
        let selfFloat = GMPFloat(10.5)

        // When: Call compare(to: value)
        // Then: Returns 0 (or very close to 0 if precision differs)
        #expect(selfFloat.compare(to: 10.5) == 0)
    }

    @Test
    func compareDouble_Larger_ReturnsOne() async throws {
        // Given: self = GMPFloat(20.5), value = 10.5
        let selfFloat = GMPFloat(20.5)

        // When: Call compare(to: value)
        // Then: Returns 1
        #expect(selfFloat.compare(to: 10.5) == 1)
    }

    @Test
    func compareDouble_WithFraction_ComparesCorrectly() async throws {
        // Given: self = GMPFloat(10.0), value = 10.5
        let selfFloat = GMPFloat(10.0)

        // When: Call compare(to: value)
        // Then: Returns -1 (10.0 < 10.5)
        #expect(selfFloat.compare(to: 10.5) == -1)
    }

    @Test
    func compareDouble_Negative_ReturnsNegativeOne() async throws {
        // Given: self = GMPFloat(-10.5), value = 10.5
        let selfFloat = GMPFloat(-10.5)

        // When: Call compare(to: value)
        // Then: Returns -1
        #expect(selfFloat.compare(to: 10.5) == -1)
    }

    // MARK: - compare(to value: Int)

    @Test
    func compareInt_Smaller_ReturnsNegativeOne() async throws {
        // Given: self = GMPFloat(10.5), value = 20
        let selfFloat = GMPFloat(10.5)

        // When: Call compare(to: value)
        // Then: Returns -1
        #expect(selfFloat.compare(to: 20) == -1)
    }

    @Test
    func compareInt_Equal_ReturnsZero() async throws {
        // Given: self = GMPFloat(10.0), value = 10
        let selfFloat = GMPFloat(10.0)

        // When: Call compare(to: value)
        // Then: Returns 0
        #expect(selfFloat.compare(to: 10) == 0)
    }

    @Test
    func compareInt_Larger_ReturnsOne() async throws {
        // Given: self = GMPFloat(20.5), value = 10
        let selfFloat = GMPFloat(20.5)

        // When: Call compare(to: value)
        // Then: Returns 1
        #expect(selfFloat.compare(to: 10) == 1)
    }

    @Test
    func compareInt_Negative_ReturnsNegativeOne() async throws {
        // Given: self = GMPFloat(-10.5), value = 10
        let selfFloat = GMPFloat(-10.5)

        // When: Call compare(to: value)
        // Then: Returns -1
        #expect(selfFloat.compare(to: 10) == -1)
    }

    @Test
    func compareInt_FractionalVsInteger_ComparesCorrectly() async throws {
        // Given: self = GMPFloat(10.5), value = 10
        let selfFloat = GMPFloat(10.5)

        // When: Call compare(to: value)
        // Then: Returns 1 (10.5 > 10)
        #expect(selfFloat.compare(to: 10) == 1)
    }

    // MARK: - sign

    @Test
    func sign_Zero_ReturnsZero() async throws {
        // Given: GMPFloat(0.0)
        let float = GMPFloat(0.0)

        // When: Access sign property
        // Then: Returns 0
        #expect(float.sign == 0)
    }

    @Test
    func sign_Positive_ReturnsOne() async throws {
        // Given: GMPFloat(42.5)
        let float = GMPFloat(42.5)

        // When: Access sign property
        // Then: Returns 1
        #expect(float.sign == 1)
    }

    @Test
    func sign_Negative_ReturnsNegativeOne() async throws {
        // Given: GMPFloat(-42.5)
        let float = GMPFloat(-42.5)

        // When: Access sign property
        // Then: Returns -1
        #expect(float.sign == -1)
    }

    @Test
    func sign_VerySmallPositive_ReturnsOne() async throws {
        // Given: GMPFloat with very small positive value
        let float = GMPFloat(0.0001)

        // When: Access sign property
        // Then: Returns 1
        #expect(float.sign == 1)
    }

    @Test
    func sign_VerySmallNegative_ReturnsNegativeOne() async throws {
        // Given: GMPFloat with very small negative value
        let float = GMPFloat(-0.0001)

        // When: Access sign property
        // Then: Returns -1
        #expect(float.sign == -1)
    }

    // MARK: - isPositive

    @Test
    func isPositive_Zero_ReturnsFalse() async throws {
        // Given: GMPFloat(0.0)
        let float = GMPFloat(0.0)

        // When: Access isPositive property
        // Then: Returns false
        #expect(float.isPositive == false)
    }

    @Test
    func isPositive_Positive_ReturnsTrue() async throws {
        // Given: GMPFloat(42.5)
        let float = GMPFloat(42.5)

        // When: Access isPositive property
        // Then: Returns true
        #expect(float.isPositive == true)
    }

    @Test
    func isPositive_Negative_ReturnsFalse() async throws {
        // Given: GMPFloat(-42.5)
        let float = GMPFloat(-42.5)

        // When: Access isPositive property
        // Then: Returns false
        #expect(float.isPositive == false)
    }

    @Test
    func isPositive_VerySmallPositive_ReturnsTrue() async throws {
        // Given: GMPFloat with very small positive value
        let float = GMPFloat(0.0001)

        // When: Access isPositive property
        // Then: Returns true
        #expect(float.isPositive == true)
    }

    // MARK: - isEqual(to:bits:)

    @Test
    func isEqual_SameValue_ReturnsTrue() async throws {
        // Given: self = GMPFloat(42.5), other = GMPFloat(42.5), bits = 53
        let selfFloat = GMPFloat(42.5)
        let other = GMPFloat(42.5)

        // When: Call isEqual(to: other, bits: 53)
        // Then: Returns true
        #expect(selfFloat.isEqual(to: other, bits: 53) == true)
    }

    @Test
    func isEqual_DifferentValues_ReturnsFalse() async throws {
        // Given: self = GMPFloat(1.0), other = GMPFloat(2.0), bits = 53
        let selfFloat = GMPFloat(1.0)
        let other = GMPFloat(2.0)

        // When: Call isEqual(to: other, bits: 53)
        // Then: Returns false
        #expect(selfFloat.isEqual(to: other, bits: 53) == false)
    }

    @Test
    func isEqual_ZeroValues_ReturnsTrue() async throws {
        // Given: self = GMPFloat(0.0), other = GMPFloat(0.0), bits = 53
        let selfFloat = GMPFloat(0.0)
        let other = GMPFloat(0.0)

        // When: Call isEqual(to: other, bits: 53)
        // Then: Returns true
        #expect(selfFloat.isEqual(to: other, bits: 53) == true)
    }

    // MARK: - == (Equatable)

    @Test
    func equal_EqualValues_ReturnsTrue() async throws {
        // Given: lhs = GMPFloat(42.5), rhs = GMPFloat(42.5)
        let lhs = GMPFloat(42.5)
        let rhs = GMPFloat(42.5)

        // When: Evaluate lhs == rhs
        // Then: Returns true
        #expect(lhs == rhs)
    }

    @Test
    func equal_DifferentValues_ReturnsFalse() async throws {
        // Given: lhs = GMPFloat(42.5), rhs = GMPFloat(20.5)
        let lhs = GMPFloat(42.5)
        let rhs = GMPFloat(20.5)

        // When: Evaluate lhs == rhs
        // Then: Returns false
        #expect(!(lhs == rhs))
    }

    @Test
    func equal_ZeroValues_ReturnsTrue() async throws {
        // Given: lhs = GMPFloat(0.0), rhs = GMPFloat(0.0)
        let lhs = GMPFloat(0.0)
        let rhs = GMPFloat(0.0)

        // When: Evaluate lhs == rhs
        // Then: Returns true
        #expect(lhs == rhs)
    }

    @Test
    func equal_NegativeValues_ReturnsTrue() async throws {
        // Given: lhs = GMPFloat(-42.5), rhs = GMPFloat(-42.5)
        let lhs = GMPFloat(-42.5)
        let rhs = GMPFloat(-42.5)

        // When: Evaluate lhs == rhs
        // Then: Returns true
        #expect(lhs == rhs)
    }
}
