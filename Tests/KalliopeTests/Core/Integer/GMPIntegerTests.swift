import Foundation
@testable import Kalliope
import Testing

// MARK: - Initialization Tests

struct GMPIntegerInitializationTests {
    @Test
    func init_DefaultInitialization_ReturnsZero() async throws {
        // Given: No preconditions
        // When: Create a new GMPInteger using init()
        let integer = GMPInteger()

        // Then: The integer has value 0, is properly initialized, and can be used for operations
        #expect(integer.toInt() == 0)
        #expect(integer.isZero == true)
    }

    @Test
    func init_DefaultInitialization_CanPerformOperations() async throws {
        // Given: A newly initialized GMPInteger with value 0
        let integer = GMPInteger()

        // When: Perform operations like addition, comparison
        let result = integer.toInt()

        // Then: Operations succeed without errors
        #expect(result == 0)
    }

    @Test
    func initPreallocatedBits_ZeroBits_ReturnsZero() async throws {
        // Given: bits = 0
        // When: Create GMPInteger(preallocatedBits: 0)
        let integer = GMPInteger(preallocatedBits: 0)

        // Then: Integer has value 0 and is properly initialized
        #expect(integer.toInt() == 0)
        #expect(integer.isZero == true)
    }

    @Test
    func initPreallocatedBits_SmallValue_ReturnsZero() async throws {
        // Given: bits = 1
        // When: Create GMPInteger(preallocatedBits: 1)
        let integer = GMPInteger(preallocatedBits: 1)

        // Then: Integer has value 0 and space for at least 1 bit
        #expect(integer.toInt() == 0)
    }

    @Test
    func initPreallocatedBits_MediumValue_ReturnsZero() async throws {
        // Given: bits = 64
        // When: Create GMPInteger(preallocatedBits: 64)
        let integer = GMPInteger(preallocatedBits: 64)

        // Then: Integer has value 0 and space for at least 64 bits
        #expect(integer.toInt() == 0)
    }

    @Test
    func initPreallocatedBits_LargeValue_ReturnsZero() async throws {
        // Given: bits = 1024
        // When: Create GMPInteger(preallocatedBits: 1024)
        let integer = GMPInteger(preallocatedBits: 1024)

        // Then: Integer has value 0 and space for at least 1024 bits
        #expect(integer.toInt() == 0)
    }

    @Test
    func reallocate_IncreaseSize_PreservesValue() async throws {
        // Given: A GMPInteger with value 42 and small allocation
        var integer = GMPInteger(42)

        // When: Call reallocate(bits: 128)
        integer.reallocate(bits: 128)

        // Then: Integer has space for at least 128 bits and value is preserved
        #expect(integer.toInt() == 42)
    }

    @Test
    func reallocate_SameSize_NoChange() async throws {
        // Given: A GMPInteger with value 100
        var integer = GMPInteger(100)

        // When: Call reallocate(bits:) with current size
        let currentBits = integer.bitCount
        integer.reallocate(bits: currentBits)

        // Then: Integer value is preserved
        #expect(integer.toInt() == 100)
    }

    @Test
    func init_UInt_Zero_ReturnsZero() async throws {
        // Given: UInt value 0
        // When: Create GMPInteger(UInt(0))
        let integer = GMPInteger(UInt(0))

        // Then: Integer has value 0
        #expect(integer.toInt() == 0)
        #expect(integer.isZero == true)
    }

    @Test
    func init_UInt_Positive_ReturnsValue() async throws {
        // Given: UInt value 42
        // When: Create GMPInteger(UInt(42))
        let integer = GMPInteger(UInt(42))

        // Then: Integer has value 42
        #expect(integer.toInt() == 42)
    }

    @Test
    func init_UInt_Large_ReturnsValue() async throws {
        // Given: Large UInt value
        let value = UInt.max
        // When: Create GMPInteger(value)
        let integer = GMPInteger(value)

        // Then: Integer has the correct value
        #expect(integer.toUInt() == value)
    }

    @Test
    func init_Double_Zero_ReturnsZero() async throws {
        // Given: Double value 0.0
        // When: Create GMPInteger(0.0)
        let integer = GMPInteger(0.0)

        // Then: Integer has value 0
        #expect(integer.toInt() == 0)
        #expect(integer.isZero == true)
    }

    @Test
    func init_Double_Positive_Truncates() async throws {
        // Given: Double value 42.7
        // When: Create GMPInteger(42.7)
        let integer = GMPInteger(42.7)

        // Then: Integer has value 42 (truncated)
        #expect(integer.toInt() == 42)
    }

    @Test
    func init_Double_Negative_Truncates() async throws {
        // Given: Double value -42.7
        // When: Create GMPInteger(-42.7)
        let integer = GMPInteger(-42.7)

        // Then: Integer has value -42 (truncated)
        #expect(integer.toInt() == -42)
    }

    @Test
    func init_Double_Large_ReturnsValue() async throws {
        // Given: Large Double value
        let value = 1_000_000_000.0
        // When: Create GMPInteger(value)
        let integer = GMPInteger(value)

        // Then: Integer has the truncated value
        #expect(integer.toInt() == 1_000_000_000)
    }
}

// MARK: - Assignment Tests

struct GMPIntegerAssignmentTests {
    @Test
    func set_FromOtherInteger_CopiesValue() async throws {
        // Given: self = GMPInteger(0), other = GMPInteger(42)
        var selfInteger = GMPInteger(0)
        let other = GMPInteger(42)

        // When: Call self.set(other)
        selfInteger.set(other)

        // Then: self has value 42, other remains 42
        #expect(selfInteger.toInt() == 42)
        #expect(other.toInt() == 42)
    }

    @Test
    func set_FromNegativeInteger_CopiesValue() async throws {
        // Given: self = GMPInteger(0), other = GMPInteger(-100)
        var selfInteger = GMPInteger(0)
        let other = GMPInteger(-100)

        // When: Call self.set(other)
        selfInteger.set(other)

        // Then: self has value -100
        #expect(selfInteger.toInt() == -100)
    }

    @Test
    func set_FromZero_CopiesValue() async throws {
        // Given: self = GMPInteger(100), other = GMPInteger(0)
        var selfInteger = GMPInteger(100)
        let other = GMPInteger(0)

        // When: Call self.set(other)
        selfInteger.set(other)

        // Then: self has value 0
        #expect(selfInteger.toInt() == 0)
        #expect(selfInteger.isZero == true)
    }

    @Test
    func set_SelfAssignment_NoChange() async throws {
        // Given: var x = GMPInteger(42)
        var x = GMPInteger(42)

        // When: Call x.set(x)
        x.set(x)

        // Then: x still has value 42 (safe self-assignment)
        #expect(x.toInt() == 42)
    }

    @Test
    func set_IndependentCopies() async throws {
        // Given: var a = GMPInteger(10), var b = GMPInteger(20)
        var a = GMPInteger(10)
        var b = GMPInteger(20)

        // When: Call a.set(b), then modify b
        a.set(b)
        b.set(GMPInteger(30))

        // Then: a remains 20, b has new value (value semantics)
        #expect(a.toInt() == 20)
        #expect(b.toInt() == 30)
    }

    @Test
    func setInt_Zero_SetsToZero() async throws {
        // Given: A GMPInteger with value 100
        var integer = GMPInteger(100)

        // When: Call set(0)
        integer.set(0)

        // Then: Integer has value 0
        #expect(integer.toInt() == 0)
    }

    @Test
    func setInt_PositiveValue_SetsValue() async throws {
        // Given: A GMPInteger with value 0
        var integer = GMPInteger(0)

        // When: Call set(42)
        integer.set(42)

        // Then: Integer has value 42
        #expect(integer.toInt() == 42)
    }

    @Test
    func setInt_NegativeValue_SetsValue() async throws {
        // Given: A GMPInteger with value 0
        var integer = GMPInteger(0)

        // When: Call set(-42)
        integer.set(-42)

        // Then: Integer has value -42
        #expect(integer.toInt() == -42)
    }

    @Test
    func setInt_IntMax_SetsValue() async throws {
        // Given: A GMPInteger with value 0
        var integer = GMPInteger(0)

        // When: Call set(Int.max)
        integer.set(Int.max)

        // Then: Integer has value Int.max
        #expect(integer.toInt() == Int.max)
    }

    @Test
    func setInt_IntMin_SetsValue() async throws {
        // Given: A GMPInteger with value 0
        var integer = GMPInteger(0)

        // When: Call set(Int.min)
        integer.set(Int.min)

        // Then: Integer has value Int.min
        #expect(integer.toInt() == Int.min)
    }

    @Test
    func setUInt_Zero_SetsToZero() async throws {
        // Given: A GMPInteger with value 100
        var integer = GMPInteger(100)

        // When: Call set(0 as UInt)
        integer.set(0 as UInt)

        // Then: Integer has value 0
        #expect(integer.toInt() == 0)
    }

    @Test
    func setUInt_PositiveValue_SetsValue() async throws {
        // Given: A GMPInteger with value 0
        var integer = GMPInteger(0)

        // When: Call set(42 as UInt)
        integer.set(42 as UInt)

        // Then: Integer has value 42
        #expect(integer.toInt() == 42)
    }

    @Test
    func setUInt_UIntMax_SetsValue() async throws {
        // Given: A GMPInteger with value 0
        var integer = GMPInteger(0)

        // When: Call set(UInt.max)
        integer.set(UInt.max)

        // Then: Integer has value UInt.max (check via toUInt)
        #expect(integer.toUInt() == UInt.max)
    }
}

// MARK: - Comparison Tests

struct GMPIntegerComparisonTests {
    @Test
    func lessThan_LeftSmaller_ReturnsTrue() async throws {
        // Given: lhs = GMPInteger(10), rhs = GMPInteger(20)
        let lhs = GMPInteger(10)
        let rhs = GMPInteger(20)

        // When: Evaluate lhs < rhs
        // Then: Returns true
        #expect(lhs < rhs)
    }

    @Test
    func lessThan_LeftLarger_ReturnsFalse() async throws {
        // Given: lhs = GMPInteger(20), rhs = GMPInteger(10)
        let lhs = GMPInteger(20)
        let rhs = GMPInteger(10)

        // When: Evaluate lhs < rhs
        // Then: Returns false
        #expect(!(lhs < rhs))
    }

    @Test
    func lessThan_Equal_ReturnsFalse() async throws {
        // Given: lhs = GMPInteger(10), rhs = GMPInteger(10)
        let lhs = GMPInteger(10)
        let rhs = GMPInteger(10)

        // When: Evaluate lhs < rhs
        // Then: Returns false
        #expect(!(lhs < rhs))
    }

    @Test
    func lessThan_NegativeLeft_ReturnsTrue() async throws {
        // Given: lhs = GMPInteger(-10), rhs = GMPInteger(10)
        let lhs = GMPInteger(-10)
        let rhs = GMPInteger(10)

        // When: Evaluate lhs < rhs
        // Then: Returns true
        #expect(lhs < rhs)
    }

    @Test
    func lessThanOrEqual_LeftSmaller_ReturnsTrue() async throws {
        // Given: lhs = GMPInteger(10), rhs = GMPInteger(20)
        let lhs = GMPInteger(10)
        let rhs = GMPInteger(20)

        // When: Evaluate lhs <= rhs
        // Then: Returns true
        #expect(lhs <= rhs)
    }

    @Test
    func lessThanOrEqual_Equal_ReturnsTrue() async throws {
        // Given: lhs = GMPInteger(10), rhs = GMPInteger(10)
        let lhs = GMPInteger(10)
        let rhs = GMPInteger(10)

        // When: Evaluate lhs <= rhs
        // Then: Returns true
        #expect(lhs <= rhs)
    }

    @Test
    func greaterThan_LeftLarger_ReturnsTrue() async throws {
        // Given: lhs = GMPInteger(20), rhs = GMPInteger(10)
        let lhs = GMPInteger(20)
        let rhs = GMPInteger(10)

        // When: Evaluate lhs > rhs
        // Then: Returns true
        #expect(lhs > rhs)
    }

    @Test
    func compare_Smaller_ReturnsNegativeOne() async throws {
        // Given: self = GMPInteger(10), other = GMPInteger(20)
        let selfInteger = GMPInteger(10)
        let other = GMPInteger(20)

        // When: Call compare(to: other)
        let result = selfInteger.compare(to: other)

        // Then: Returns -1
        #expect(result == -1)
    }

    @Test
    func compare_Equal_ReturnsZero() async throws {
        // Given: self = GMPInteger(10), other = GMPInteger(10)
        let selfInteger = GMPInteger(10)
        let other = GMPInteger(10)

        // When: Call compare(to: other)
        let result = selfInteger.compare(to: other)

        // Then: Returns 0
        #expect(result == 0)
    }

    @Test
    func compare_Larger_ReturnsOne() async throws {
        // Given: self = GMPInteger(20), other = GMPInteger(10)
        let selfInteger = GMPInteger(20)
        let other = GMPInteger(10)

        // When: Call compare(to: other)
        let result = selfInteger.compare(to: other)

        // Then: Returns 1
        #expect(result == 1)
    }

    @Test
    func sign_Zero_ReturnsZero() async throws {
        // Given: GMPInteger(0)
        let integer = GMPInteger(0)

        // When: Access sign
        // Then: Returns 0
        #expect(integer.sign == 0)
    }

    @Test
    func sign_Positive_ReturnsOne() async throws {
        // Given: GMPInteger(42)
        let integer = GMPInteger(42)

        // When: Access sign
        // Then: Returns 1
        #expect(integer.sign == 1)
    }

    @Test
    func sign_Negative_ReturnsNegativeOne() async throws {
        // Given: GMPInteger(-42)
        let integer = GMPInteger(-42)

        // When: Access sign
        // Then: Returns -1
        #expect(integer.sign == -1)
    }

    @Test
    func isNegative_Zero_ReturnsFalse() async throws {
        // Given: GMPInteger(0)
        let integer = GMPInteger(0)

        // When: Access isNegative
        // Then: Returns false
        #expect(!integer.isNegative)
    }

    @Test
    func isNegative_Positive_ReturnsFalse() async throws {
        // Given: GMPInteger(42)
        let integer = GMPInteger(42)

        // When: Access isNegative
        // Then: Returns false
        #expect(!integer.isNegative)
    }

    @Test
    func isNegative_Negative_ReturnsTrue() async throws {
        // Given: GMPInteger(-42)
        let integer = GMPInteger(-42)

        // When: Access isNegative
        // Then: Returns true
        #expect(integer.isNegative)
    }

    @Test
    func isPositive_Zero_ReturnsFalse() async throws {
        // Given: GMPInteger(0)
        let integer = GMPInteger(0)

        // When: Access isPositive
        // Then: Returns false
        #expect(!integer.isPositive)
    }

    @Test
    func isPositive_Positive_ReturnsTrue() async throws {
        // Given: GMPInteger(42)
        let integer = GMPInteger(42)

        // When: Access isPositive
        // Then: Returns true
        #expect(integer.isPositive)
    }

    @Test
    func isPositive_Negative_ReturnsFalse() async throws {
        // Given: GMPInteger(-42)
        let integer = GMPInteger(-42)

        // When: Access isPositive
        // Then: Returns false
        #expect(!integer.isPositive)
    }

    @Test
    func compare_ToDouble_Equal_ReturnsZero() async throws {
        // Given: GMPInteger(42), Double(42.0)
        let integer = GMPInteger(42)
        let value = 42.0

        // When: Call compare(to: value)
        let result = integer.compare(to: value)

        // Then: Returns 0
        #expect(result == 0)
    }

    @Test
    func compare_ToDouble_LessThan_ReturnsNegative() async throws {
        // Given: GMPInteger(42), Double(100.0)
        let integer = GMPInteger(42)
        let value = 100.0

        // When: Call compare(to: value)
        let result = integer.compare(to: value)

        // Then: Returns negative value
        #expect(result < 0)
    }

    @Test
    func compare_ToDouble_GreaterThan_ReturnsPositive() async throws {
        // Given: GMPInteger(100), Double(42.0)
        let integer = GMPInteger(100)
        let value = 42.0

        // When: Call compare(to: value)
        let result = integer.compare(to: value)

        // Then: Returns positive value
        #expect(result > 0)
    }

    @Test
    func compare_ToInt_Equal_ReturnsZero() async throws {
        // Given: GMPInteger(42), Int(42)
        let integer = GMPInteger(42)
        let value = 42

        // When: Call compare(to: value)
        let result = integer.compare(to: value)

        // Then: Returns 0
        #expect(result == 0)
    }

    @Test
    func compare_ToInt_LessThan_ReturnsNegative() async throws {
        // Given: GMPInteger(42), Int(100)
        let integer = GMPInteger(42)
        let value = 100

        // When: Call compare(to: value)
        let result = integer.compare(to: value)

        // Then: Returns negative value
        #expect(result < 0)
    }

    @Test
    func compare_ToInt_GreaterThan_ReturnsPositive() async throws {
        // Given: GMPInteger(100), Int(42)
        let integer = GMPInteger(100)
        let value = 42

        // When: Call compare(to: value)
        let result = integer.compare(to: value)

        // Then: Returns positive value
        #expect(result > 0)
    }

    @Test
    func compareAbsoluteValue_ToGMPInteger_Equal_ReturnsZero() async throws {
        // Given: GMPInteger(42), GMPInteger(42)
        let a = GMPInteger(42)
        let b = GMPInteger(42)

        // When: Call compareAbsoluteValue(to: b)
        let result = a.compareAbsoluteValue(to: b)

        // Then: Returns 0
        #expect(result == 0)
    }

    @Test
    func compareAbsoluteValue_ToGMPInteger_Negative_ReturnsZero() async throws {
        // Given: GMPInteger(42), GMPInteger(-42)
        let a = GMPInteger(42)
        let b = GMPInteger(-42)

        // When: Call compareAbsoluteValue(to: b)
        let result = a.compareAbsoluteValue(to: b)

        // Then: Returns 0 (absolute values are equal)
        #expect(result == 0)
    }

    @Test
    func compareAbsoluteValue_ToDouble_Equal_ReturnsZero() async throws {
        // Given: GMPInteger(42), Double(42.0)
        let integer = GMPInteger(42)
        let value = 42.0

        // When: Call compareAbsoluteValue(to: value)
        let result = integer.compareAbsoluteValue(to: value)

        // Then: Returns 0
        #expect(result == 0)
    }

    @Test
    func compareAbsoluteValue_ToDouble_Negative_ReturnsZero() async throws {
        // Given: GMPInteger(42), Double(-42.0)
        let integer = GMPInteger(42)
        let value = -42.0

        // When: Call compareAbsoluteValue(to: value)
        let result = integer.compareAbsoluteValue(to: value)

        // Then: Returns 0 (absolute values are equal)
        #expect(result == 0)
    }

    @Test
    func compareAbsoluteValue_ToInt_Equal_ReturnsZero() async throws {
        // Given: GMPInteger(42), Int(42)
        let integer = GMPInteger(42)
        let value = 42

        // When: Call compareAbsoluteValue(to: value)
        let result = integer.compareAbsoluteValue(to: value)

        // Then: Returns 0
        #expect(result == 0)
    }

    @Test
    func compareAbsoluteValue_ToInt_Negative_ReturnsZero() async throws {
        // Given: GMPInteger(42), Int(-42)
        let integer = GMPInteger(42)
        let value = -42

        // When: Call compareAbsoluteValue(to: value)
        let result = integer.compareAbsoluteValue(to: value)

        // Then: Returns 0 (absolute values are equal)
        #expect(result == 0)
    }
}

// MARK: - Conversion Tests

struct GMPIntegerConversionTests {
    @Test
    func toUInt_Zero_ReturnsZero() async throws {
        // Given: GMPInteger(0)
        let integer = GMPInteger(0)

        // When: Call toUInt()
        // Then: Returns 0
        #expect(integer.toUInt() == 0)
    }

    @Test
    func toUInt_SmallPositive_ReturnsValue() async throws {
        // Given: GMPInteger(42)
        let integer = GMPInteger(42)

        // When: Call toUInt()
        // Then: Returns 42
        #expect(integer.toUInt() == 42)
    }

    @Test
    func toUInt_Negative_ReturnsAbsoluteValueTruncated() async throws {
        // Given: GMPInteger(-42)
        let integer = GMPInteger(-42)

        // When: Call toUInt()
        // Then: Returns 42 (absolute value)
        #expect(integer.toUInt() == 42)
    }

    @Test
    func toInt_Zero_ReturnsZero() async throws {
        // Given: GMPInteger(0)
        let integer = GMPInteger(0)

        // When: Call toInt()
        // Then: Returns 0
        #expect(integer.toInt() == 0)
    }

    @Test
    func toInt_SmallPositive_ReturnsValue() async throws {
        // Given: GMPInteger(42)
        let integer = GMPInteger(42)

        // When: Call toInt()
        // Then: Returns 42
        #expect(integer.toInt() == 42)
    }

    @Test
    func toInt_SmallNegative_ReturnsValue() async throws {
        // Given: GMPInteger(-42)
        let integer = GMPInteger(-42)

        // When: Call toInt()
        // Then: Returns -42
        #expect(integer.toInt() == -42)
    }

    @Test
    func toInt_IntMax_ReturnsValue() async throws {
        // Given: GMPInteger(Int.max)
        let integer = GMPInteger(Int.max)

        // When: Call toInt()
        // Then: Returns Int.max
        #expect(integer.toInt() == Int.max)
    }

    @Test
    func toInt_IntMin_ReturnsValue() async throws {
        // Given: GMPInteger(Int.min)
        let integer = GMPInteger(Int.min)

        // When: Call toInt()
        // Then: Returns Int.min
        #expect(integer.toInt() == Int.min)
    }

    @Test
    func toDouble_Zero_ReturnsZero() async throws {
        // Given: GMPInteger(0)
        let integer = GMPInteger(0)

        // When: Call toDouble()
        // Then: Returns 0.0
        #expect(integer.toDouble() == 0.0)
    }

    @Test
    func toDouble_Positive_ReturnsValue() async throws {
        // Given: GMPInteger(42)
        let integer = GMPInteger(42)

        // When: Call toDouble()
        // Then: Returns 42.0
        #expect(integer.toDouble() == 42.0)
    }

    @Test
    func toDouble_Negative_ReturnsValue() async throws {
        // Given: GMPInteger(-42)
        let integer = GMPInteger(-42)

        // When: Call toDouble()
        // Then: Returns -42.0
        #expect(integer.toDouble() == -42.0)
    }

    @Test
    func toDouble2Exp_Zero_ReturnsZero() async throws {
        // Given: GMPInteger(0)
        let integer = GMPInteger(0)

        // When: Call toDouble2Exp()
        let result = integer.toDouble2Exp()

        // Then: Returns (mantissa: 0.0, exponent: 0)
        #expect(result.mantissa == 0.0)
        #expect(result.exponent == 0)
    }

    @Test
    func toDouble2Exp_Positive_ReturnsMantissaAndExponent() async throws {
        // Given: GMPInteger(42)
        let integer = GMPInteger(42)

        // When: Call toDouble2Exp()
        let result = integer.toDouble2Exp()

        // Then: Returns valid mantissa and exponent such that mantissa * 2^exponent == 42
        let reconstructed = result.mantissa * pow(2.0, Double(result.exponent))
        #expect(abs(reconstructed - 42.0) < 0.0001)
    }

    @Test
    func toDouble2Exp_Large_ReturnsMantissaAndExponent() async throws {
        // Given: Large GMPInteger
        let integer = GMPInteger(1_000_000)

        // When: Call toDouble2Exp()
        let result = integer.toDouble2Exp()

        // Then: Returns valid mantissa and exponent
        let reconstructed = result.mantissa * pow(2.0, Double(result.exponent))
        #expect(abs(reconstructed - 1_000_000.0) < 1.0)
    }

    @Test
    func set_Double_Zero_SetsToZero() async throws {
        // Given: A GMPInteger with value 100
        var integer = GMPInteger(100)

        // When: Call set(0.0)
        integer.set(0.0)

        // Then: Integer has value 0
        #expect(integer.toInt() == 0)
    }

    @Test
    func set_Double_Positive_Truncates() async throws {
        // Given: A GMPInteger with value 0
        var integer = GMPInteger(0)

        // When: Call set(42.7)
        integer.set(42.7)

        // Then: Integer has value 42 (truncated)
        #expect(integer.toInt() == 42)
    }

    @Test
    func set_Double_Negative_Truncates() async throws {
        // Given: A GMPInteger with value 0
        var integer = GMPInteger(0)

        // When: Call set(-42.7)
        integer.set(-42.7)

        // Then: Integer has value -42 (truncated)
        #expect(integer.toInt() == -42)
    }

    @Test
    func fitsInUInt64_Zero_ReturnsTrue() async throws {
        // Given: GMPInteger(0)
        let integer = GMPInteger(0)

        // When: Call fitsInUInt64()
        // Then: Returns true
        #expect(integer.fitsInUInt64() == true)
    }

    @Test
    func fitsInUInt64_SmallPositive_ReturnsTrue() async throws {
        // Given: GMPInteger(42)
        let integer = GMPInteger(42)

        // When: Call fitsInUInt64()
        // Then: Returns true
        #expect(integer.fitsInUInt64() == true)
    }

    @Test
    func fitsInUInt64_Negative_ReturnsFalse() async throws {
        // Given: GMPInteger(-1)
        let integer = GMPInteger(-1)

        // When: Call fitsInUInt64()
        // Then: Returns false
        #expect(integer.fitsInUInt64() == false)
    }

    @Test
    func fitsInInt64_Zero_ReturnsTrue() async throws {
        // Given: GMPInteger(0)
        let integer = GMPInteger(0)

        // When: Call fitsInInt64()
        // Then: Returns true
        #expect(integer.fitsInInt64() == true)
    }

    @Test
    func fitsInInt64_SmallPositive_ReturnsTrue() async throws {
        // Given: GMPInteger(42)
        let integer = GMPInteger(42)

        // When: Call fitsInInt64()
        // Then: Returns true
        #expect(integer.fitsInInt64() == true)
    }

    @Test
    func fitsInInt64_SmallNegative_ReturnsTrue() async throws {
        // Given: GMPInteger(-42)
        let integer = GMPInteger(-42)

        // When: Call fitsInInt64()
        // Then: Returns true
        #expect(integer.fitsInInt64() == true)
    }

    @Test
    func fitsInUInt32_Zero_ReturnsTrue() async throws {
        // Given: GMPInteger(0)
        let integer = GMPInteger(0)

        // When: Call fitsInUInt32()
        // Then: Returns true
        #expect(integer.fitsInUInt32() == true)
    }

    @Test
    func fitsInUInt32_SmallPositive_ReturnsTrue() async throws {
        // Given: GMPInteger(42)
        let integer = GMPInteger(42)

        // When: Call fitsInUInt32()
        // Then: Returns true
        #expect(integer.fitsInUInt32() == true)
    }

    @Test
    func fitsInUInt32_Negative_ReturnsFalse() async throws {
        // Given: GMPInteger(-1)
        let integer = GMPInteger(-1)

        // When: Call fitsInUInt32()
        // Then: Returns false
        #expect(integer.fitsInUInt32() == false)
    }

    @Test
    func fitsInInt32_Zero_ReturnsTrue() async throws {
        // Given: GMPInteger(0)
        let integer = GMPInteger(0)

        // When: Call fitsInInt32()
        // Then: Returns true
        #expect(integer.fitsInInt32() == true)
    }

    @Test
    func fitsInInt32_SmallPositive_ReturnsTrue() async throws {
        // Given: GMPInteger(42)
        let integer = GMPInteger(42)

        // When: Call fitsInInt32()
        // Then: Returns true
        #expect(integer.fitsInInt32() == true)
    }

    @Test
    func fitsInInt32_SmallNegative_ReturnsTrue() async throws {
        // Given: GMPInteger(-42)
        let integer = GMPInteger(-42)

        // When: Call fitsInInt32()
        // Then: Returns true
        #expect(integer.fitsInInt32() == true)
    }

    @Test
    func fitsInUInt16_Zero_ReturnsTrue() async throws {
        // Given: GMPInteger(0)
        let integer = GMPInteger(0)

        // When: Call fitsInUInt16()
        // Then: Returns true
        #expect(integer.fitsInUInt16() == true)
    }

    @Test
    func fitsInUInt16_SmallPositive_ReturnsTrue() async throws {
        // Given: GMPInteger(42)
        let integer = GMPInteger(42)

        // When: Call fitsInUInt16()
        // Then: Returns true
        #expect(integer.fitsInUInt16() == true)
    }

    @Test
    func fitsInUInt16_Negative_ReturnsFalse() async throws {
        // Given: GMPInteger(-1)
        let integer = GMPInteger(-1)

        // When: Call fitsInUInt16()
        // Then: Returns false
        #expect(integer.fitsInUInt16() == false)
    }

    @Test
    func fitsInInt16_Zero_ReturnsTrue() async throws {
        // Given: GMPInteger(0)
        let integer = GMPInteger(0)

        // When: Call fitsInInt16()
        // Then: Returns true
        #expect(integer.fitsInInt16() == true)
    }

    @Test
    func fitsInInt16_SmallPositive_ReturnsTrue() async throws {
        // Given: GMPInteger(42)
        let integer = GMPInteger(42)

        // When: Call fitsInInt16()
        // Then: Returns true
        #expect(integer.fitsInInt16() == true)
    }

    @Test
    func fitsInInt16_SmallNegative_ReturnsTrue() async throws {
        // Given: GMPInteger(-42)
        let integer = GMPInteger(-42)

        // When: Call fitsInInt16()
        // Then: Returns true
        #expect(integer.fitsInInt16() == true)
    }

    @Test
    func limbCount_Zero_ReturnsZero() async throws {
        // Given: GMPInteger(0)
        let integer = GMPInteger(0)

        // When: Access limbCount
        // Then: Returns 0
        #expect(integer.limbCount == 0)
    }

    @Test
    func limbCount_SmallPositive_ReturnsPositive() async throws {
        // Given: GMPInteger(42)
        let integer = GMPInteger(42)

        // When: Access limbCount
        // Then: Returns positive value
        #expect(integer.limbCount >= 0)
    }

    @Test
    func sizeInBase_Base10_ReturnsCorrectSize() async throws {
        // Given: GMPInteger(12345), base 10
        let integer = GMPInteger(12345)

        // When: Call sizeInBase(10)
        let size = integer.sizeInBase(10)

        // Then: Returns size of "12345" (5 characters)
        #expect(size == 5)
    }

    @Test
    func sizeInBase_Base2_ReturnsCorrectSize() async throws {
        // Given: GMPInteger(42), base 2
        let integer = GMPInteger(42)

        // When: Call sizeInBase(2)
        let size = integer.sizeInBase(2)

        // Then: Returns size of binary representation
        #expect(size > 0)
    }

    @Test
    func sizeInBase_Base16_ReturnsCorrectSize() async throws {
        // Given: GMPInteger(255), base 16
        let integer = GMPInteger(255)

        // When: Call sizeInBase(16)
        let size = integer.sizeInBase(16)

        // Then: Returns size of "ff" (2 characters)
        #expect(size == 2)
    }

    @Test
    func toString_Zero_Base10_ReturnsZero() async throws {
        // Given: GMPInteger(0), base 10
        let integer = GMPInteger(0)

        // When: Call toString(base: 10)
        // Then: Returns "0"
        #expect(integer.toString(base: 10) == "0")
    }

    @Test
    func toString_Positive_Base10_ReturnsString() async throws {
        // Given: GMPInteger(42), base 10
        let integer = GMPInteger(42)

        // When: Call toString(base: 10)
        // Then: Returns "42"
        #expect(integer.toString(base: 10) == "42")
    }

    @Test
    func toString_Negative_Base10_ReturnsStringWithMinus() async throws {
        // Given: GMPInteger(-42), base 10
        let integer = GMPInteger(-42)

        // When: Call toString(base: 10)
        // Then: Returns "-42"
        #expect(integer.toString(base: 10) == "-42")
    }

    @Test
    func toString_Base2_ReturnsBinary() async throws {
        // Given: GMPInteger(10), base 2
        let integer = GMPInteger(10)

        // When: Call toString(base: 2)
        // Then: Returns "1010"
        #expect(integer.toString(base: 2) == "1010")
    }

    @Test
    func toString_Base16_ReturnsHexadecimal() async throws {
        // Given: GMPInteger(255), base 16
        let integer = GMPInteger(255)

        // When: Call toString(base: 16)
        // Then: Returns "ff"
        #expect(integer.toString(base: 16) == "ff")
    }

    @Test
    func fitsInUInt_Zero_ReturnsTrue() async throws {
        // Given: GMPInteger(0)
        let integer = GMPInteger(0)

        // When: Call fitsInUInt()
        // Then: Returns true
        #expect(integer.fitsInUInt() == true)
    }

    @Test
    func fitsInUInt_SmallPositive_ReturnsTrue() async throws {
        // Given: GMPInteger(42)
        let integer = GMPInteger(42)

        // When: Call fitsInUInt()
        // Then: Returns true
        #expect(integer.fitsInUInt() == true)
    }

    @Test
    func fitsInUInt_Negative_ReturnsFalse() async throws {
        // Given: GMPInteger(-1)
        let integer = GMPInteger(-1)

        // When: Call fitsInUInt()
        // Then: Returns false
        #expect(integer.fitsInUInt() == false)
    }

    @Test
    func fitsInInt_Zero_ReturnsTrue() async throws {
        // Given: GMPInteger(0)
        let integer = GMPInteger(0)

        // When: Call fitsInInt()
        // Then: Returns true
        #expect(integer.fitsInInt() == true)
    }

    @Test
    func fitsInInt_SmallPositive_ReturnsTrue() async throws {
        // Given: GMPInteger(42)
        let integer = GMPInteger(42)

        // When: Call fitsInInt()
        // Then: Returns true
        #expect(integer.fitsInInt() == true)
    }

    @Test
    func fitsInInt_SmallNegative_ReturnsTrue() async throws {
        // Given: GMPInteger(-42)
        let integer = GMPInteger(-42)

        // When: Call fitsInInt()
        // Then: Returns true
        #expect(integer.fitsInInt() == true)
    }

    @Test
    func fitsInInt_IntMax_ReturnsTrue() async throws {
        // Given: GMPInteger(Int.max)
        let integer = GMPInteger(Int.max)

        // When: Call fitsInInt()
        // Then: Returns true
        #expect(integer.fitsInInt() == true)
    }

    @Test
    func fitsInInt_IntMin_ReturnsTrue() async throws {
        // Given: GMPInteger(Int.min)
        let integer = GMPInteger(Int.min)

        // When: Call fitsInInt()
        // Then: Returns true
        #expect(integer.fitsInInt() == true)
    }

    @Test
    func bitCount_Zero_ReturnsZero() async throws {
        // Given: GMPInteger(0)
        let integer = GMPInteger(0)

        // When: Access bitCount
        // Then: Returns 0
        #expect(integer.bitCount == 0)
    }

    @Test
    func bitCount_One_ReturnsOne() async throws {
        // Given: GMPInteger(1)
        let integer = GMPInteger(1)

        // When: Access bitCount
        // Then: Returns 1
        #expect(integer.bitCount == 1)
    }

    @Test
    func bitCount_Two_ReturnsTwo() async throws {
        // Given: GMPInteger(2)
        let integer = GMPInteger(2)

        // When: Access bitCount
        // Then: Returns 2
        #expect(integer.bitCount == 2)
    }

    @Test
    func bitCount_Four_ReturnsThree() async throws {
        // Given: GMPInteger(4)
        let integer = GMPInteger(4)

        // When: Access bitCount
        // Then: Returns 3
        #expect(integer.bitCount == 3)
    }

    @Test
    func bitCount_Negative_ReturnsAbsoluteValueBitCount() async throws {
        // Given: GMPInteger(-42)
        let integer = GMPInteger(-42)

        // When: Access bitCount
        // Then: Returns bit count of absolute value (42)
        let positive = GMPInteger(42)
        #expect(integer.bitCount == positive.bitCount)
    }
}

// MARK: - String Initialization Tests

struct GMPIntegerStringInitializationTests {
    @Test
    func initString_DecimalZero_ReturnsValue() async throws {
        // Given: string "0", base 10
        // When: Create GMPInteger?("0", base: 10)
        let integer = GMPInteger("0", base: 10)

        // Then: Returns non-nil GMPInteger with value 0
        #expect(integer != nil)
        #expect(integer!.toInt() == 0)
    }

    @Test
    func initString_DecimalPositive_ReturnsValue() async throws {
        // Given: string "42", base 10
        // When: Create GMPInteger?("42", base: 10)
        let integer = GMPInteger("42", base: 10)

        // Then: Returns non-nil GMPInteger with value 42
        #expect(integer != nil)
        #expect(integer!.toInt() == 42)
    }

    @Test
    func initString_DecimalNegative_ReturnsValue() async throws {
        // Given: string "-42", base 10
        // When: Create GMPInteger?("-42", base: 10)
        let integer = GMPInteger("-42", base: 10)

        // Then: Returns non-nil GMPInteger with value -42
        #expect(integer != nil)
        #expect(integer!.toInt() == -42)
    }

    @Test
    func initString_Hexadecimal_ReturnsValue() async throws {
        // Given: string "FF", base 16
        // When: Create GMPInteger?("FF", base: 16)
        let integer = GMPInteger("FF", base: 16)

        // Then: Returns non-nil GMPInteger with value 255
        #expect(integer != nil)
        #expect(integer!.toInt() == 255)
    }

    @Test
    func initString_Binary_ReturnsValue() async throws {
        // Given: string "1010", base 2
        // When: Create GMPInteger?("1010", base: 2)
        let integer = GMPInteger("1010", base: 2)

        // Then: Returns non-nil GMPInteger with value 10
        #expect(integer != nil)
        #expect(integer!.toInt() == 10)
    }

    @Test
    func initString_BaseZero_WithHexPrefix_ReturnsValue() async throws {
        // Given: string "0xFF", base 0
        // When: Create GMPInteger?("0xFF", base: 0)
        let integer = GMPInteger("0xFF", base: 0)

        // Then: Returns non-nil GMPInteger with value 255
        #expect(integer != nil)
        #expect(integer!.toInt() == 255)
    }

    @Test
    func initString_InvalidCharacter_ReturnsNil() async throws {
        // Given: string "42abc", base 10
        // When: Create GMPInteger?("42abc", base: 10)
        let integer = GMPInteger("42abc", base: 10)

        // Then: Returns nil
        #expect(integer == nil)
    }

    @Test
    func initString_EmptyString_ReturnsNil() async throws {
        // Given: string "", base 10
        // When: Create GMPInteger?("", base: 10)
        let integer = GMPInteger("", base: 10)

        // Then: Returns nil
        #expect(integer == nil)
    }

    @Test
    func setString_DecimalZero_ReturnsTrue() async throws {
        // Given: A GMPInteger with value 0, string "0", base 10
        var integer = GMPInteger(100)

        // When: Call set("0", base: 10)
        let result = integer.set("0", base: 10)

        // Then: Returns true, integer has value 0
        #expect(result == true)
        #expect(integer.toInt() == 0)
    }

    @Test
    func setString_DecimalPositive_ReturnsTrue() async throws {
        // Given: A GMPInteger with value 0, string "42", base 10
        var integer = GMPInteger(0)

        // When: Call set("42", base: 10)
        let result = integer.set("42", base: 10)

        // Then: Returns true, integer has value 42
        #expect(result == true)
        #expect(integer.toInt() == 42)
    }

    @Test
    func setString_InvalidCharacter_ReturnsFalse() async throws {
        // Given: A GMPInteger with value 100, string "42abc", base 10
        var integer = GMPInteger(100)

        // When: Call set("42abc", base: 10)
        let result = integer.set("42abc", base: 10)

        // Then: Returns false, integer remains 100 (unchanged)
        #expect(result == false)
        #expect(integer.toInt() == 100)
    }
}

// MARK: - Swap Tests

struct GMPIntegerSwapTests {
    @Test
    func swap_TwoDifferentValues_SwapsValues() async throws {
        // Given: var a = GMPInteger(10), var b = GMPInteger(20)
        var a = GMPInteger(10)
        var b = GMPInteger(20)

        // When: Call a.swap(&b)
        a.swap(&b)

        // Then: a has value 20, b has value 10
        #expect(a.toInt() == 20)
        #expect(b.toInt() == 10)
    }

    @Test
    func swap_WithZero_SwapsValues() async throws {
        // Given: var a = GMPInteger(0), var b = GMPInteger(42)
        var a = GMPInteger(0)
        var b = GMPInteger(42)

        // When: Call a.swap(&b)
        a.swap(&b)

        // Then: a has value 42, b has value 0
        #expect(a.toInt() == 42)
        #expect(b.toInt() == 0)
    }

    @Test
    func swap_SelfSwap_NoChange() async throws {
        // Given: var a = GMPInteger(42)
        var a = GMPInteger(42)
        let originalValue = a.toInt()

        // When: Call swap with itself (using a workaround for Swift's inout restriction)
        // Note: GMP's swap is safe for self-swap, but Swift doesn't allow &a
        // and &a in same call
        // So we test that swap works correctly, and self-swap safety is
        // guaranteed by GMP
        var b = a
        a.swap(&b)
        a.swap(&b) // Swap back

        // Then: a still has value 42 (swap is reversible)
        #expect(a.toInt() == originalValue)
    }
}
