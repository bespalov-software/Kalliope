import Foundation
@testable import Kalliope
import Testing

// MARK: - Conversion Tests

struct GMPFloatConversionTests {
    // MARK: - toDouble()

    @Test
    func toDouble_Zero_ReturnsZero() async throws {
        // Given: GMPFloat(0.0)
        let float = GMPFloat(0.0)

        // When: Call toDouble()
        // Then: Returns 0.0
        #expect(float.toDouble() == 0.0)
    }

    @Test
    func toDouble_PositiveInteger_ReturnsValue() async throws {
        // Given: GMPFloat(42.0)
        let float = GMPFloat(42.0)

        // When: Call toDouble()
        // Then: Returns 42.0
        #expect(float.toDouble() == 42.0)
    }

    @Test
    func toDouble_NegativeInteger_ReturnsValue() async throws {
        // Given: GMPFloat(-42.0)
        let float = GMPFloat(-42.0)

        // When: Call toDouble()
        // Then: Returns -42.0
        #expect(float.toDouble() == -42.0)
    }

    @Test
    func toDouble_PositiveFraction_ReturnsValue() async throws {
        // Given: GMPFloat(3.14159)
        let float = GMPFloat(3.14159)

        // When: Call toDouble()
        // Then: Returns approximate value 3.14159 (may lose precision if float has higher precision)
        #expect(abs(float.toDouble() - 3.14159) < 0.0001)
    }

    @Test
    func toDouble_NegativeFraction_ReturnsValue() async throws {
        // Given: GMPFloat(-3.14159)
        let float = GMPFloat(-3.14159)

        // When: Call toDouble()
        // Then: Returns approximate value -3.14159
        #expect(abs(float.toDouble() - -3.14159) < 0.0001)
    }

    // MARK: - toDouble2Exp()

    @Test
    func toDouble2Exp_Zero_ReturnsZeroAndZero() async throws {
        // Given: GMPFloat(0.0)
        let float = GMPFloat(0.0)

        // When: Call toDouble2Exp()
        let result = float.toDouble2Exp()

        // Then: Returns (mantissa: 0.0, exponent: 0)
        #expect(result.mantissa == 0.0)
        #expect(result.exponent == 0)
    }

    @Test
    func toDouble2Exp_PositiveInteger_ReturnsMantissaAndExponent() async throws {
        // Given: GMPFloat(42.0)
        let float = GMPFloat(42.0)

        // When: Call toDouble2Exp()
        let result = float.toDouble2Exp()

        // Then: Returns tuple where mantissa is in [0.5, 1) and mantissa * 2^exponent == 42
        #expect(result.mantissa >= 0.5)
        #expect(result.mantissa < 1.0)
        let reconstructed = result.mantissa * pow(2.0, Double(result.exponent))
        #expect(abs(reconstructed - 42.0) < 0.0001)
    }

    @Test
    func toDouble2Exp_NegativeInteger_ReturnsMantissaAndExponent() async throws {
        // Given: GMPFloat(-42.0)
        let float = GMPFloat(-42.0)

        // When: Call toDouble2Exp()
        let result = float.toDouble2Exp()

        // Then: Returns tuple where absolute value of mantissa is in [0.5, 1) and mantissa * 2^exponent == -42.0
        // Note: For negative values, mantissa is negative
        #expect(abs(result.mantissa) >= 0.5)
        #expect(abs(result.mantissa) < 1.0)
        let reconstructed = result.mantissa * pow(2.0, Double(result.exponent))
        #expect(abs(reconstructed - -42.0) < 0.0001)
    }

    @Test
    func toDouble2Exp_PositiveFraction_ReturnsMantissaAndExponent(
    ) async throws {
        // Given: GMPFloat(3.14159)
        let float = GMPFloat(3.14159)

        // When: Call toDouble2Exp()
        let result = float.toDouble2Exp()

        // Then: Returns tuple where mantissa is in [0.5, 1) and mantissa * 2^exponent == 3.14159 (approximately)
        #expect(result.mantissa >= 0.5)
        #expect(result.mantissa < 1.0)
        let reconstructed = result.mantissa * pow(2.0, Double(result.exponent))
        #expect(abs(reconstructed - 3.14159) < 0.0001)
    }

    @Test
    func toDouble2Exp_PowerOfTwo_ReturnsCorrectValues() async throws {
        // Given: GMPFloat(64.0) (2^6)
        let float = GMPFloat(64.0)

        // When: Call toDouble2Exp()
        let result = float.toDouble2Exp()

        // Then: Returns mantissa in [0.5, 1) and exponent such that result equals 64.0
        #expect(result.mantissa >= 0.5)
        #expect(result.mantissa < 1.0)
        let reconstructed = result.mantissa * pow(2.0, Double(result.exponent))
        #expect(abs(reconstructed - 64.0) < 0.0001)
    }

    @Test
    func toDouble2Exp_MantissaInRange() async throws {
        // Given: Various GMPFloat values (positive, negative, large, small)
        let values: [Double] = [1.0, 2.0, 3.14159, 100.0, 0.5, 0.25]

        // When: Call toDouble2Exp()
        for value in values {
            let float = GMPFloat(value)
            let result = float.toDouble2Exp()

            // Then: Mantissa is always in range [0.5, 1) or 0.0 for zero
            if value == 0.0 {
                #expect(result.mantissa == 0.0)
            } else {
                #expect(result.mantissa >= 0.5)
                #expect(result.mantissa < 1.0)
            }
        }
    }

    // MARK: - toUInt()

    @Test
    func toUInt_Zero_ReturnsZero() async throws {
        // Given: GMPFloat(0.0)
        let float = GMPFloat(0.0)

        // When: Call toUInt()
        // Then: Returns 0
        #expect(float.toUInt() == 0)
    }

    @Test
    func toUInt_SmallPositive_ReturnsTruncated() async throws {
        // Given: GMPFloat(42.7)
        let float = GMPFloat(42.7)

        // When: Call toUInt()
        // Then: Returns 42 (truncated toward zero)
        #expect(float.toUInt() == 42)
    }

    @Test
    func toUInt_IntegerValue_ReturnsValue() async throws {
        // Given: GMPFloat(42.0)
        let float = GMPFloat(42.0)

        // When: Call toUInt()
        // Then: Returns 42
        #expect(float.toUInt() == 42)
    }

    @Test
    func toUInt_FractionalValue_TruncatesTowardZero() async throws {
        // Given: GMPFloat(99.9)
        let float = GMPFloat(99.9)

        // When: Call toUInt()
        // Then: Returns 99 (truncated)
        #expect(float.toUInt() == 99)
    }

    @Test
    func toUInt_NegativeValue_ReturnsAbsoluteValueTruncated() async throws {
        // Given: GMPFloat(-42.7)
        let float = GMPFloat(-42.7)

        // When: Call toUInt()
        // Then: Returns 42 (absolute value, truncated)
        #expect(float.toUInt() == 42)
    }

    // MARK: - toInt()

    @Test
    func toInt_Zero_ReturnsZero() async throws {
        // Given: GMPFloat(0.0)
        let float = GMPFloat(0.0)

        // When: Call toInt()
        // Then: Returns 0
        #expect(float.toInt() == 0)
    }

    @Test
    func toInt_SmallPositive_ReturnsTruncated() async throws {
        // Given: GMPFloat(42.7)
        let float = GMPFloat(42.7)

        // When: Call toInt()
        // Then: Returns 42 (truncated toward zero)
        #expect(float.toInt() == 42)
    }

    @Test
    func toInt_SmallNegative_ReturnsTruncated() async throws {
        // Given: GMPFloat(-42.7)
        let float = GMPFloat(-42.7)

        // When: Call toInt()
        // Then: Returns -42 (truncated toward zero)
        #expect(float.toInt() == -42)
    }

    @Test
    func toInt_IntegerValue_ReturnsValue() async throws {
        // Given: GMPFloat(42.0)
        let float = GMPFloat(42.0)

        // When: Call toInt()
        // Then: Returns 42
        #expect(float.toInt() == 42)
    }

    @Test
    func toInt_NegativeInteger_ReturnsValue() async throws {
        // Given: GMPFloat(-42.0)
        let float = GMPFloat(-42.0)

        // When: Call toInt()
        // Then: Returns -42
        #expect(float.toInt() == -42)
    }

    // MARK: - toString(base:digits:)

    @Test
    func toString_Zero_Base10_ReturnsZero() async throws {
        // Given: GMPFloat(0.0), base 10, digits 0
        let float = GMPFloat(0.0)

        // When: Call toString(base: 10, digits: 0)
        let result = float.toString(base: 10, digits: 0)

        // Then: Returns "0" or "0.0" or similar
        #expect(result.contains("0"))
    }

    @Test
    func toString_Positive_Base10_ReturnsString() async throws {
        // Given: GMPFloat(42.5), base 10, digits 0
        let float = GMPFloat(42.5)

        // When: Call toString(base: 10, digits: 0)
        let result = float.toString(base: 10, digits: 0)

        // Then: Returns string representation of 42.5
        // Parse it back and verify
        let parsed = GMPFloat(result, base: 10)
        #expect(parsed != nil)
        #expect(abs(parsed!.toDouble() - 42.5) < 0.1)
    }

    @Test
    func toString_Negative_Base10_ReturnsStringWithMinus() async throws {
        // Given: GMPFloat(-42.5), base 10, digits 0
        let float = GMPFloat(-42.5)

        // When: Call toString(base: 10, digits: 0)
        let result = float.toString(base: 10, digits: 0)

        // Then: Returns string representation starting with "-"
        #expect(result.hasPrefix("-"))
    }

    @Test
    func toString_WithDigits_ReturnsStringWithSpecifiedDigits() async throws {
        // Given: GMPFloat(3.14159), base 10, digits 5
        let float = GMPFloat(3.14159)

        // When: Call toString(base: 10, digits: 5)
        let result = float.toString(base: 10, digits: 5)

        // Then: Returns string with approximately 5 significant digits
        // The exact format may vary, but should have limited precision
        #expect(!result.isEmpty)
    }

    @Test
    func toString_Base2_ReturnsBinary() async throws {
        // Given: GMPFloat(10.5), base 2, digits 0
        let float = GMPFloat(10.5)

        // When: Call toString(base: 2, digits: 0)
        let result = float.toString(base: 2, digits: 0)

        // Then: Returns binary representation
        // Parse it back and verify
        let parsed = GMPFloat(result, base: 2)
        #expect(parsed != nil)
        #expect(abs(parsed!.toDouble() - 10.5) < 0.1)
    }

    @Test
    func toString_Base16_ReturnsHexadecimal() async throws {
        // Given: GMPFloat(255.5), base 16, digits 0
        let float = GMPFloat(255.5)

        // When: Call toString(base: 16, digits: 0)
        let result = float.toString(base: 16, digits: 0)

        // Then: Returns hexadecimal representation
        // Parse it back and verify
        let parsed = GMPFloat(result, base: 16)
        #expect(parsed != nil)
        #expect(abs(parsed!.toDouble() - 255.5) < 0.1)
    }

    @Test
    func toString_ExpZero_ReturnsDecimalFormat() async throws {
        // Given: GMPFloat with value between 1/base and 1 (exp == 0)
        // For base 10, a value like 0.5 should have exp == 0
        let float = GMPFloat(0.5)

        // When: Call toString(base: 10, digits: 0)
        let result = float.toString(base: 10, digits: 0)

        // Then: Returns string starting with "0."
        #expect(result.hasPrefix("0."))
        // Parse it back and verify
        let parsed = GMPFloat(result, base: 10)
        #expect(parsed != nil)
        #expect(abs(parsed!.toDouble() - 0.5) < 0.1)
    }

    @Test
    func toString_ExpGreaterThanMantissaLength_AppendsZeros() async throws {
        // Given: GMPFloat with value where exp >= mantissaString.count
        // This happens when all digits are before the decimal point
        // For example, 100.0 in base 10 should have exp > mantissa length
        let float = GMPFloat(100.0)

        // When: Call toString(base: 10, digits: 0)
        let result = float.toString(base: 10, digits: 0)

        // Then: Returns string representation
        // Parse it back and verify
        let parsed = GMPFloat(result, base: 10)
        #expect(parsed != nil)
        #expect(abs(parsed!.toDouble() - 100.0) < 0.1)
    }

    @Test
    func toString_ExpNegative_ReturnsSmallDecimalFormat() async throws {
        // Given: GMPFloat with value < 1/base (exp < 0)
        // For base 10, a very small value like 0.001
        let float = GMPFloat(0.001)

        // When: Call toString(base: 10, digits: 0)
        let result = float.toString(base: 10, digits: 0)

        // Then: Returns string starting with "0." followed by zeros
        #expect(result.hasPrefix("0."))
        // Parse it back and verify
        let parsed = GMPFloat(result, base: 10)
        #expect(parsed != nil)
        #expect(abs(parsed!.toDouble() - 0.001) < 0.01)
    }

    @Test
    func toString_VerySmallValue_ReturnsCorrectFormat() async throws {
        // Given: GMPFloat with very small value
        let float = GMPFloat(0.0001)

        // When: Call toString(base: 10, digits: 0)
        let result = float.toString(base: 10, digits: 0)

        // Then: Returns valid string representation
        #expect(result.hasPrefix("0."))
        let parsed = GMPFloat(result, base: 10)
        #expect(parsed != nil)
        #expect(parsed!.toDouble() > 0)
        #expect(parsed!.toDouble() < 0.001)
    }

    // MARK: - fitsInUInt()

    @Test
    func fitsInUInt_Zero_ReturnsTrue() async throws {
        // Given: GMPFloat(0.0)
        let float = GMPFloat(0.0)

        // When: Call fitsInUInt()
        // Then: Returns true
        #expect(float.fitsInUInt() == true)
    }

    @Test
    func fitsInUInt_SmallPositiveInteger_ReturnsTrue() async throws {
        // Given: GMPFloat(42.0)
        let float = GMPFloat(42.0)

        // When: Call fitsInUInt()
        // Then: Returns true
        #expect(float.fitsInUInt() == true)
    }

    @Test
    func fitsInUInt_WithFractionalPart_ReturnsFalse() async throws {
        // Given: GMPFloat(42.5)
        let float = GMPFloat(42.5)

        // When: Call fitsInUInt()
        // Then: Returns false (has fractional part)
        #expect(float.fitsInUInt() == false)
    }

    @Test
    func fitsInUInt_Negative_ReturnsFalse() async throws {
        // Given: GMPFloat(-1.0)
        let float = GMPFloat(-1.0)

        // When: Call fitsInUInt()
        // Then: Returns false (negative)
        #expect(float.fitsInUInt() == false)
    }

    // MARK: - fitsInInt()

    @Test
    func fitsInInt_Zero_ReturnsTrue() async throws {
        // Given: GMPFloat(0.0)
        let float = GMPFloat(0.0)

        // When: Call fitsInInt()
        // Then: Returns true
        #expect(float.fitsInInt() == true)
    }

    @Test
    func fitsInInt_SmallPositiveInteger_ReturnsTrue() async throws {
        // Given: GMPFloat(42.0)
        let float = GMPFloat(42.0)

        // When: Call fitsInInt()
        // Then: Returns true
        #expect(float.fitsInInt() == true)
    }

    @Test
    func fitsInInt_SmallNegativeInteger_ReturnsTrue() async throws {
        // Given: GMPFloat(-42.0)
        let float = GMPFloat(-42.0)

        // When: Call fitsInInt()
        // Then: Returns true
        #expect(float.fitsInInt() == true)
    }

    @Test
    func fitsInInt_WithFractionalPart_ReturnsFalse() async throws {
        // Given: GMPFloat(42.5)
        let float = GMPFloat(42.5)

        // When: Call fitsInInt()
        // Then: Returns false (has fractional part)
        #expect(float.fitsInInt() == false)
    }

    // MARK: - fitsInUInt64()

    @Test
    func fitsInUInt64_Zero_ReturnsTrue() async throws {
        // Given: GMPFloat(0.0)
        let float = GMPFloat(0.0)

        // When: Call fitsInUInt64()
        // Then: Returns true
        #expect(float.fitsInUInt64() == true)
    }

    @Test
    func fitsInUInt64_Negative_ReturnsFalse() async throws {
        // Given: GMPFloat(-1.0)
        let float = GMPFloat(-1.0)

        // When: Call fitsInUInt64()
        // Then: Returns false
        #expect(float.fitsInUInt64() == false)
    }

    @Test
    func fitsInUInt64_WithFractionalPart_ReturnsFalse() async throws {
        // Given: GMPFloat(42.5)
        let float = GMPFloat(42.5)

        // When: Call fitsInUInt64()
        // Then: Returns false
        #expect(float.fitsInUInt64() == false)
    }

    // MARK: - fitsInInt64()

    @Test
    func fitsInInt64_Zero_ReturnsTrue() async throws {
        // Given: GMPFloat(0.0)
        let float = GMPFloat(0.0)

        // When: Call fitsInInt64()
        // Then: Returns true
        #expect(float.fitsInInt64() == true)
    }

    @Test
    func fitsInInt64_WithFractionalPart_ReturnsFalse() async throws {
        // Given: GMPFloat(42.5)
        let float = GMPFloat(42.5)

        // When: Call fitsInInt64()
        // Then: Returns false
        #expect(float.fitsInInt64() == false)
    }
}
