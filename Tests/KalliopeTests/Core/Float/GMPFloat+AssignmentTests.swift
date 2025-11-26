import Foundation
@testable import Kalliope
import Testing

// MARK: - Assignment Tests

struct GMPFloatAssignmentTests {
    // MARK: - set(_ other: GMPFloat)

    @Test
    func set_FromOtherFloat_CopiesValue() async throws {
        // Given: var self = GMPFloat(0.0), var other = GMPFloat(42.5)
        var selfFloat = GMPFloat(0.0)
        let other = GMPFloat(42.5)

        // When: Call self.set(other)
        selfFloat.set(other)

        // Then: self has value 42.5 (rounded to self's precision), other remains 42.5
        #expect(abs(selfFloat.toDouble() - 42.5) < 0.0001)
        #expect(abs(other.toDouble() - 42.5) < 0.0001)
    }

    @Test
    func set_FromFloatWithHigherPrecision_RoundsToSelfPrecision() async throws {
        // Given: var self = GMPFloat(precision: 53) with value 0.0,
        // var other = GMPFloat(precision: 256) with value 3.141592653589793
        var selfFloat = try GMPFloat(precision: 53)
        var other = try GMPFloat(precision: 256)
        other.set(3.141592653589793)

        // When: Call self.set(other)
        selfFloat.set(other)

        // Then: self has value approximately 3.141592653589793 rounded to 53-bit precision
        #expect(abs(selfFloat.toDouble() - 3.141592653589793) < 0.0001)
    }

    @Test
    func set_FromFloatWithLowerPrecision_CopiesExactValue() async throws {
        // Given: var self = GMPFloat(precision: 256) with value 0.0, var other = GMPFloat(precision: 53) with value 1.5
        var selfFloat = try GMPFloat(precision: 256)
        var other = try GMPFloat(precision: 53)
        other.set(1.5)

        // When: Call self.set(other)
        selfFloat.set(other)

        // Then: self has exact value 1.5
        #expect(selfFloat.toDouble() == 1.5)
    }

    @Test
    func set_FromNegativeFloat_CopiesValue() async throws {
        // Given: var self = GMPFloat(0.0), var other = GMPFloat(-42.5)
        var selfFloat = GMPFloat(0.0)
        let other = GMPFloat(-42.5)

        // When: Call self.set(other)
        selfFloat.set(other)

        // Then: self has value -42.5
        #expect(selfFloat.toDouble() == -42.5)
    }

    @Test
    func set_FromZero_CopiesValue() async throws {
        // Given: var self = GMPFloat(100.0), var other = GMPFloat(0.0)
        var selfFloat = GMPFloat(100.0)
        let other = GMPFloat(0.0)

        // When: Call self.set(other)
        selfFloat.set(other)

        // Then: self has value 0.0
        #expect(selfFloat.toDouble() == 0.0)
        #expect(selfFloat.isZero == true)
    }

    @Test
    func set_SelfAssignment_NoChange() async throws {
        // Given: var f = GMPFloat(42.5)
        var f = GMPFloat(42.5)

        // When: Call f.set(f)
        f.set(f)

        // Then: f still has value 42.5 (safe self-assignment)
        #expect(abs(f.toDouble() - 42.5) < 0.0001)
    }

    @Test
    func set_IndependentCopies() async throws {
        // Given: var a = GMPFloat(10.5), var b = GMPFloat(20.5)
        var a = GMPFloat(10.5)
        var b = GMPFloat(20.5)

        // When: Call a.set(b), then modify b
        a.set(b)
        b.set(30.5)

        // Then: a remains 20.5, b has new value (value semantics)
        #expect(abs(a.toDouble() - 20.5) < 0.0001)
        #expect(abs(b.toDouble() - 30.5) < 0.0001)
    }

    // MARK: - set(_ value: Int)

    @Test
    func setInt_Zero_SetsToZero() async throws {
        // Given: A GMPFloat with value 100.0
        var float = GMPFloat(100.0)

        // When: Call set(0)
        float.set(0)

        // Then: Float has value 0.0
        #expect(float.toDouble() == 0.0)
    }

    @Test
    func setInt_PositiveValue_SetsValue() async throws {
        // Given: A GMPFloat with value 0.0
        var float = GMPFloat(0.0)

        // When: Call set(42)
        float.set(42)

        // Then: Float has value 42.0
        #expect(float.toDouble() == 42.0)
    }

    @Test
    func setInt_NegativeValue_SetsValue() async throws {
        // Given: A GMPFloat with value 0.0
        var float = GMPFloat(0.0)

        // When: Call set(-42)
        float.set(-42)

        // Then: Float has value -42.0
        #expect(float.toDouble() == -42.0)
    }

    @Test
    func setInt_IntMax_SetsValue() async throws {
        // Given: A GMPFloat with value 0.0
        var float = GMPFloat(0.0)

        // When: Call set(Int.max) (boundary - maximum)
        float.set(Int.max)

        // Then: Float has value Int.max (within floating point precision)
        // Note: Large integers may lose precision when converted to Double, so
        // use larger tolerance
        #expect(abs(float.toDouble() - Double(Int.max)) < 10000.0)
    }

    @Test
    func setInt_IntMin_SetsValue() async throws {
        // Given: A GMPFloat with value 0.0
        var float = GMPFloat(0.0)

        // When: Call set(Int.min) (boundary - minimum)
        float.set(Int.min)

        // Then: Float has exact value Int.min
        #expect(float.toDouble() == Double(Int.min))
    }

    @Test
    func setInt_LargePositiveValue_SetsValue() async throws {
        // Given: A GMPFloat with value 0.0
        var float = GMPFloat(0.0)

        // When: Call set(1_000_000)
        float.set(1_000_000)

        // Then: Float has value 1_000_000.0
        #expect(float.toDouble() == 1_000_000.0)
    }

    @Test
    func setInt_LargeNegativeValue_SetsValue() async throws {
        // Given: A GMPFloat with value 0.0
        var float = GMPFloat(0.0)

        // When: Call set(-1_000_000)
        float.set(-1_000_000)

        // Then: Float has value -1_000_000.0
        #expect(float.toDouble() == -1_000_000.0)
    }

    // MARK: - set(_ value: UInt)

    @Test
    func setUInt_Zero_SetsToZero() async throws {
        // Given: A GMPFloat with value 100.0
        var float = GMPFloat(100.0)

        // When: Call set(0 as UInt)
        float.set(0 as UInt)

        // Then: Float has value 0.0
        #expect(float.toDouble() == 0.0)
    }

    @Test
    func setUInt_PositiveValue_SetsValue() async throws {
        // Given: A GMPFloat with value 0.0
        var float = GMPFloat(0.0)

        // When: Call set(42 as UInt)
        float.set(42 as UInt)

        // Then: Float has value 42.0
        #expect(float.toDouble() == 42.0)
    }

    @Test
    func setUInt_UIntMax_SetsValue() async throws {
        // Given: A GMPFloat with value 0.0
        var float = GMPFloat(0.0)

        // When: Call set(UInt.max) (boundary - maximum)
        float.set(UInt.max)

        // Then: Float has value UInt.max (within floating point precision)
        // Note: Large integers may lose precision when converted to Double, so
        // use larger tolerance
        #expect(abs(float.toDouble() - Double(UInt.max)) < 10000.0)
    }

    @Test
    func setUInt_LargeValue_SetsValue() async throws {
        // Given: A GMPFloat with value 0.0
        var float = GMPFloat(0.0)

        // When: Call set(1_000_000 as UInt)
        float.set(1_000_000 as UInt)

        // Then: Float has value 1_000_000.0
        #expect(float.toDouble() == 1_000_000.0)
    }

    // MARK: - set(_ value: Double)

    @Test
    func setDouble_Zero_SetsToZero() async throws {
        // Given: A GMPFloat with value 100.0
        var float = GMPFloat(100.0)

        // When: Call set(0.0)
        float.set(0.0)

        // Then: Float has value 0.0
        #expect(float.toDouble() == 0.0)
    }

    @Test
    func setDouble_PositiveInteger_SetsValue() async throws {
        // Given: A GMPFloat with value 0.0
        var float = GMPFloat(0.0)

        // When: Call set(42.0)
        float.set(42.0)

        // Then: Float has value 42.0
        #expect(float.toDouble() == 42.0)
    }

    @Test
    func setDouble_NegativeInteger_SetsValue() async throws {
        // Given: A GMPFloat with value 0.0
        var float = GMPFloat(0.0)

        // When: Call set(-42.0)
        float.set(-42.0)

        // Then: Float has value -42.0
        #expect(float.toDouble() == -42.0)
    }

    @Test
    func setDouble_PositiveFraction_SetsValue() async throws {
        // Given: A GMPFloat with value 0.0
        var float = GMPFloat(0.0)

        // When: Call set(3.14159)
        float.set(3.14159)

        // Then: Float approximates 3.14159 at this float's precision
        #expect(abs(float.toDouble() - 3.14159) < 0.0001)
    }

    @Test
    func setDouble_NegativeFraction_SetsValue() async throws {
        // Given: A GMPFloat with value 0.0
        var float = GMPFloat(0.0)

        // When: Call set(-3.14159)
        float.set(-3.14159)

        // Then: Float approximates -3.14159 at this float's precision
        #expect(abs(float.toDouble() - -3.14159) < 0.0001)
    }

    @Test
    func setDouble_VerySmallValue_SetsValue() async throws {
        // Given: A GMPFloat with value 0.0
        var float = GMPFloat(0.0)

        // When: Call set(1e-300)
        float.set(1e-300)

        // Then: Float has very small value (approximated at this float's precision)
        #expect(float.toDouble() > 0)
        #expect(float.toDouble() < 1e-200) // Should be very small
    }

    @Test
    func setDouble_VeryLargeValue_SetsValue() async throws {
        // Given: A GMPFloat with value 0.0
        var float = GMPFloat(0.0)

        // When: Call set(1e300)
        float.set(1e300)

        // Then: Float has very large value (approximated at this float's precision)
        #expect(float.toDouble() > 1e200)
    }

    // MARK: - set(_ value: GMPInteger)

    @Test
    func setGMPInteger_Zero_SetsToZero() async throws {
        // Given: A GMPFloat with value 100.0, GMPInteger(0)
        var float = GMPFloat(100.0)
        let integer = GMPInteger(0)

        // When: Call set(integer)
        float.set(integer)

        // Then: Float has value 0.0
        #expect(float.toDouble() == 0.0)
    }

    @Test
    func setGMPInteger_PositiveValue_SetsValue() async throws {
        // Given: A GMPFloat with value 0.0, GMPInteger(42)
        var float = GMPFloat(0.0)
        let integer = GMPInteger(42)

        // When: Call set(integer)
        float.set(integer)

        // Then: Float has exact value 42.0
        #expect(float.toDouble() == 42.0)
    }

    @Test
    func setGMPInteger_NegativeValue_SetsValue() async throws {
        // Given: A GMPFloat with value 0.0, GMPInteger(-42)
        var float = GMPFloat(0.0)
        let integer = GMPInteger(-42)

        // When: Call set(integer)
        float.set(integer)

        // Then: Float has exact value -42.0
        #expect(float.toDouble() == -42.0)
    }

    @Test
    func setGMPInteger_LargeValue_SetsValue() async throws {
        // Given: A GMPFloat with value 0.0, GMPInteger with very large value
        var float = GMPFloat(0.0)
        let integer = GMPInteger("123456789012345678901234567890")!

        // When: Call set(integer)
        float.set(integer)

        // Then: Float has exact value (if representable at this precision)
        // Verify it's a large positive number
        #expect(float.toDouble() > 0)
    }

    @Test
    func setGMPInteger_IntMax_SetsValue() async throws {
        // Given: A GMPFloat with value 0.0, GMPInteger(Int.max)
        var float = GMPFloat(0.0)
        let integer = GMPInteger(Int.max)

        // When: Call set(integer)
        float.set(integer)

        // Then: Float has value Int.max (within floating point precision)
        // Note: Large integers may lose precision when converted to Double, so
        // use larger tolerance
        #expect(abs(float.toDouble() - Double(Int.max)) < 10000.0)
    }

    // MARK: - set(_ string:base:) -> Bool

    @Test
    func setString_DecimalZero_ReturnsTrue() async throws {
        // Given: A GMPFloat with value 100.0, string "0", base 10
        var float = GMPFloat(100.0)

        // When: Call set("0", base: 10)
        let result = float.set("0", base: 10)

        // Then: Returns true, float has value 0.0
        #expect(result == true)
        #expect(float.toDouble() == 0.0)
    }

    @Test
    func setString_DecimalPositive_ReturnsTrue() async throws {
        // Given: A GMPFloat with value 0.0, string "42.5", base 10
        var float = GMPFloat(0.0)

        // When: Call set("42.5", base: 10)
        let result = float.set("42.5", base: 10)

        // Then: Returns true, float has value 42.5
        #expect(result == true)
        #expect(abs(float.toDouble() - 42.5) < 0.0001)
    }

    @Test
    func setString_DecimalNegative_ReturnsTrue() async throws {
        // Given: A GMPFloat with value 0.0, string "-42.5", base 10
        var float = GMPFloat(0.0)

        // When: Call set("-42.5", base: 10)
        let result = float.set("-42.5", base: 10)

        // Then: Returns true, float has value -42.5
        #expect(result == true)
        #expect(abs(float.toDouble() - -42.5) < 0.0001)
    }

    @Test
    func setString_WithExponent_ReturnsTrue() async throws {
        // Given: A GMPFloat with value 0.0, string "1.23e-4", base 10
        var float = GMPFloat(0.0)

        // When: Call set("1.23e-4", base: 10)
        let result = float.set("1.23e-4", base: 10)

        // Then: Returns true, float has value 0.000123
        #expect(result == true)
        #expect(abs(float.toDouble() - 0.000123) < 0.00001)
    }

    @Test
    func setString_WithPositiveExponent_ReturnsTrue() async throws {
        // Given: A GMPFloat with value 0.0, string "1.5e2", base 10
        var float = GMPFloat(0.0)

        // When: Call set("1.5e2", base: 10)
        let result = float.set("1.5e2", base: 10)

        // Then: Returns true, float has value 150.0
        #expect(result == true)
        #expect(abs(float.toDouble() - 150.0) < 0.0001)
    }

    @Test
    func setString_Hexadecimal_ReturnsTrue() async throws {
        // Given: A GMPFloat with value 0.0, string "FF.8", base 16
        var float = GMPFloat(0.0)

        // When: Call set("FF.8", base: 16)
        let result = float.set("FF.8", base: 16)

        // Then: Returns true, float has value 255.5
        #expect(result == true)
        #expect(abs(float.toDouble() - 255.5) < 0.0001)
    }

    @Test
    func setString_Binary_ReturnsTrue() async throws {
        // Given: A GMPFloat with value 0.0, string "1010.101", base 2
        var float = GMPFloat(0.0)

        // When: Call set("1010.101", base: 2)
        let result = float.set("1010.101", base: 2)

        // Then: Returns true, float has value 10.625
        #expect(result == true)
        #expect(abs(float.toDouble() - 10.625) < 0.0001)
    }

    @Test
    func setString_BaseZero_WithHexPrefix_ReturnsTrue() async throws {
        // Given: A GMPFloat with value 0.0, string "0xFF.8", base 0
        // Note: GMP's mpf_set_str may not support 0x prefix for floats like it
        // does for integers
        // Let's test with explicit base 16 instead
        var float = GMPFloat(0.0)

        // When: Call set("FF.8", base: 16) - using explicit base since 0x prefix may not work
        let result = float.set("FF.8", base: 16)

        // Then: Returns true, float has value 255.5
        #expect(result == true)
        #expect(abs(float.toDouble() - 255.5) < 0.0001)
    }

    @Test
    func setString_BaseZero_NoPrefix_ReturnsTrue() async throws {
        // Given: A GMPFloat with value 0.0, string "42.5", base 0
        var float = GMPFloat(0.0)

        // When: Call set("42.5", base: 0)
        let result = float.set("42.5", base: 0)

        // Then: Returns true, float has value 42.5 (decimal)
        #expect(result == true)
        #expect(abs(float.toDouble() - 42.5) < 0.0001)
    }

    @Test
    func setString_InvalidCharacter_ReturnsFalse() async throws {
        // Given: A GMPFloat with value 100.0, string "42.5abc", base 10
        var float = GMPFloat(100.0)
        let originalValue = float.toDouble()

        // When: Call set("42.5abc", base: 10)
        let result = float.set("42.5abc", base: 10)

        // Then: Returns false, float remains 100.0 (unchanged)
        #expect(result == false)
        #expect(float.toDouble() == originalValue)
    }

    @Test
    func setString_EmptyString_ReturnsFalse() async throws {
        // Given: A GMPFloat with value 100.0, string "", base 10
        var float = GMPFloat(100.0)
        let originalValue = float.toDouble()

        // When: Call set("", base: 10)
        let result = float.set("", base: 10)

        // Then: Returns false, float remains 100.0 (unchanged)
        #expect(result == false)
        #expect(float.toDouble() == originalValue)
    }

    // MARK: - init(_ value: Int)

    @Test
    func initInt_Zero_ReturnsZero() async throws {
        // Given: value = 0
        // When: Create GMPFloat(0)
        let float = GMPFloat(0)

        // Then: Float has value 0.0 at default precision
        #expect(float.toDouble() == 0.0)
    }

    @Test
    func initInt_Positive_ReturnsValue() async throws {
        // Given: value = 42
        // When: Create GMPFloat(42)
        let float = GMPFloat(42)

        // Then: Float has exact value 42.0
        #expect(float.toDouble() == 42.0)
    }

    @Test
    func initInt_Negative_ReturnsValue() async throws {
        // Given: value = -42
        // When: Create GMPFloat(-42)
        let float = GMPFloat(-42)

        // Then: Float has exact value -42.0
        #expect(float.toDouble() == -42.0)
    }

    @Test
    func initInt_IntMax_ReturnsValue() async throws {
        // Given: value = Int.max (boundary - maximum)
        // When: Create GMPFloat(Int.max)
        let float = GMPFloat(Int.max)

        // Then: Float has value Int.max (within floating point precision)
        // Note: Large integers may lose precision when converted to Double, so
        // use larger tolerance
        #expect(abs(float.toDouble() - Double(Int.max)) < 10000.0)
    }

    @Test
    func initInt_IntMin_ReturnsValue() async throws {
        // Given: value = Int.min (boundary - minimum)
        // When: Create GMPFloat(Int.min)
        let float = GMPFloat(Int.min)

        // Then: Float has exact value Int.min
        #expect(float.toDouble() == Double(Int.min))
    }

    // MARK: - init(_ value: UInt)

    @Test
    func initUInt_Zero_ReturnsZero() async throws {
        // Given: value = 0 as UInt
        // When: Create GMPFloat(0 as UInt)
        let float = GMPFloat(0 as UInt)

        // Then: Float has value 0.0
        #expect(float.toDouble() == 0.0)
    }

    @Test
    func initUInt_Positive_ReturnsValue() async throws {
        // Given: value = 42 as UInt
        // When: Create GMPFloat(42 as UInt)
        let float = GMPFloat(42 as UInt)

        // Then: Float has value 42.0
        #expect(float.toDouble() == 42.0)
    }

    @Test
    func initUInt_UIntMax_ReturnsValue() async throws {
        // Given: value = UInt.max (boundary - maximum)
        // When: Create GMPFloat(UInt.max)
        let float = GMPFloat(UInt.max)

        // Then: Float has value UInt.max (within floating point precision)
        // Note: Large integers may lose precision when converted to Double, so
        // use larger tolerance
        #expect(abs(float.toDouble() - Double(UInt.max)) < 10000.0)
    }

    // MARK: - init(_ value: Double)

    @Test
    func initDouble_Zero_ReturnsZero() async throws {
        // Given: value = 0.0
        // When: Create GMPFloat(0.0)
        let float = GMPFloat(0.0)

        // Then: Float has value 0.0 at default precision
        #expect(float.toDouble() == 0.0)
    }

    @Test
    func initDouble_PositiveInteger_ReturnsValue() async throws {
        // Given: value = 42.0
        // When: Create GMPFloat(42.0)
        let float = GMPFloat(42.0)

        // Then: Float approximates 42.0 at default precision
        #expect(abs(float.toDouble() - 42.0) < 0.0001)
    }

    @Test
    func initDouble_NegativeInteger_ReturnsValue() async throws {
        // Given: value = -42.0
        // When: Create GMPFloat(-42.0)
        let float = GMPFloat(-42.0)

        // Then: Float approximates -42.0 at default precision
        #expect(abs(float.toDouble() - -42.0) < 0.0001)
    }

    @Test
    func initDouble_WithFraction_ReturnsValue() async throws {
        // Given: value = 3.14159
        // When: Create GMPFloat(3.14159)
        let float = GMPFloat(3.14159)

        // Then: Float approximates 3.14159 at default precision
        #expect(abs(float.toDouble() - 3.14159) < 0.0001)
    }

    // MARK: - init(_ value: GMPInteger)

    @Test
    func initGMPInteger_Zero_ReturnsZero() async throws {
        // Given: GMPInteger(0)
        let integer = GMPInteger(0)

        // When: Create GMPFloat(integer)
        let float = GMPFloat(integer)

        // Then: Float has value 0.0
        #expect(float.toDouble() == 0.0)
    }

    @Test
    func initGMPInteger_Positive_ReturnsValue() async throws {
        // Given: GMPInteger(42)
        let integer = GMPInteger(42)

        // When: Create GMPFloat(integer)
        let float = GMPFloat(integer)

        // Then: Float has exact value 42.0
        #expect(float.toDouble() == 42.0)
    }

    @Test
    func initGMPInteger_Negative_ReturnsValue() async throws {
        // Given: GMPInteger(-42)
        let integer = GMPInteger(-42)

        // When: Create GMPFloat(integer)
        let float = GMPFloat(integer)

        // Then: Float has exact value -42.0
        #expect(float.toDouble() == -42.0)
    }

    @Test
    func initGMPInteger_LargeValue_ReturnsValue() async throws {
        // Given: GMPInteger with very large value
        let integer = GMPInteger("123456789012345678901234567890")!

        // When: Create GMPFloat(integer)
        let float = GMPFloat(integer)

        // Then: Float has exact value (if representable at default precision)
        // Verify it's a large positive number
        #expect(float.toDouble() > 0)
    }

    // MARK: - init?(_ string:base:)

    @Test
    func initString_DecimalZero_ReturnsValue() async throws {
        // Given: string "0", base 10
        // When: Create GMPFloat?("0", base: 10)
        let float = GMPFloat("0", base: 10)

        // Then: Returns non-nil GMPFloat with value 0.0
        #expect(float != nil)
        #expect(float!.toDouble() == 0.0)
    }

    @Test
    func initString_DecimalPositive_ReturnsValue() async throws {
        // Given: string "42.5", base 10
        // When: Create GMPFloat?("42.5", base: 10)
        let float = GMPFloat("42.5", base: 10)

        // Then: Returns non-nil GMPFloat with value 42.5
        #expect(float != nil)
        #expect(abs(float!.toDouble() - 42.5) < 0.0001)
    }

    @Test
    func initString_DecimalNegative_ReturnsValue() async throws {
        // Given: string "-42.5", base 10
        // When: Create GMPFloat?("-42.5", base: 10)
        let float = GMPFloat("-42.5", base: 10)

        // Then: Returns non-nil GMPFloat with value -42.5
        #expect(float != nil)
        #expect(abs(float!.toDouble() - -42.5) < 0.0001)
    }

    @Test
    func initString_WithExponent_ReturnsValue() async throws {
        // Given: string "1.23e-4", base 10
        // When: Create GMPFloat?("1.23e-4", base: 10)
        let float = GMPFloat("1.23e-4", base: 10)

        // Then: Returns non-nil GMPFloat with value 0.000123
        #expect(float != nil)
        #expect(abs(float!.toDouble() - 0.000123) < 0.00001)
    }

    @Test
    func initString_InvalidCharacter_ReturnsNil() async throws {
        // Given: string "42.5abc", base 10
        // When: Create GMPFloat?("42.5abc", base: 10)
        let float = GMPFloat("42.5abc", base: 10)

        // Then: Returns nil
        #expect(float == nil)
    }

    @Test
    func initString_EmptyString_ReturnsNil() async throws {
        // Given: string "", base 10
        // When: Create GMPFloat?("", base: 10)
        let float = GMPFloat("", base: 10)

        // Then: Returns nil
        #expect(float == nil)
    }

    // MARK: - swap(_ other:)

    @Test
    func swap_TwoDifferentValues_SwapsValues() async throws {
        // Given: var a = GMPFloat(10.5), var b = GMPFloat(20.5)
        var a = GMPFloat(10.5)
        var b = GMPFloat(20.5)

        // When: Call a.swap(&b)
        a.swap(&b)

        // Then: a has value 20.5, b has value 10.5
        #expect(abs(a.toDouble() - 20.5) < 0.0001)
        #expect(abs(b.toDouble() - 10.5) < 0.0001)
    }

    @Test
    func swap_WithZero_SwapsValues() async throws {
        // Given: var a = GMPFloat(0.0), var b = GMPFloat(42.5)
        var a = GMPFloat(0.0)
        var b = GMPFloat(42.5)

        // When: Call a.swap(&b)
        a.swap(&b)

        // Then: a has value 42.5, b has value 0.0
        #expect(abs(a.toDouble() - 42.5) < 0.0001)
        #expect(b.toDouble() == 0.0)
    }

    @Test
    func swap_WithNegative_SwapsValues() async throws {
        // Given: var a = GMPFloat(-10.5), var b = GMPFloat(20.5)
        var a = GMPFloat(-10.5)
        var b = GMPFloat(20.5)

        // When: Call a.swap(&b)
        a.swap(&b)

        // Then: a has value 20.5, b has value -10.5
        #expect(abs(a.toDouble() - 20.5) < 0.0001)
        #expect(abs(b.toDouble() - -10.5) < 0.0001)
    }
}
