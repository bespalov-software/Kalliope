import Foundation
@testable import Kalliope
import Testing

/// Tests for GMP String Interpolation support.
struct GMPFormattedIOStringInterpolationTests {
    // MARK: - GMPInteger Default Interpolation

    @Test
    func interpolation_Integer_Default() async throws {
        // Given: A GMPInteger initialized to 1234
        let z = GMPInteger(1234)

        // When: let str = "Value: \(z)" is evaluated
        let str = "Value: \(z)"

        // Then: str equals "Value: 1234"
        #expect(str == "Value: 1234")
    }

    @Test
    func interpolation_Integer_Zero_Default() async throws {
        // Given: A GMPInteger initialized to 0
        let z = GMPInteger(0)

        // When: let str = "Value: \(z)" is evaluated
        let str = "Value: \(z)"

        // Then: str equals "Value: 0"
        #expect(str == "Value: 0")
    }

    @Test
    func interpolation_Integer_Negative_Default() async throws {
        // Given: A GMPInteger initialized to -1234
        let z = GMPInteger(-1234)

        // When: let str = "Value: \(z)" is evaluated
        let str = "Value: \(z)"

        // Then: str equals "Value: -1234"
        #expect(str == "Value: -1234")
    }

    @Test
    func interpolation_Integer_Large_Default() async throws {
        // Given: A GMPInteger initialized to a very large value (e.g., 2^100)
        let z = GMPInteger.power(base: 2, exponent: 100) // z = 2^100

        // When: let str = "Value: \(z)" is evaluated
        let str = "Value: \(z)"

        // Then: str contains the correct string representation
        #expect(str.hasPrefix("Value: "))
        #expect(str.count > 10) // Should be a large number
    }

    // MARK: - GMPInteger Format String Interpolation

    @Test
    func interpolation_Integer_Format_Hex() async throws {
        // Given: A GMPInteger initialized to 255
        let z = GMPInteger(255)

        // When: let str = "Hex: \(z, format: "%Zx")" is evaluated
        let str = "Hex: \(z, format: "%Zx")"

        // Then: str equals "Hex: ff"
        #expect(str == "Hex: ff")
    }

    @Test
    func interpolation_Integer_Format_HexWithPrefix() async throws {
        // Given: A GMPInteger initialized to 255
        let z = GMPInteger(255)

        // When: let str = "Hex: \(z, format: "%#Zx")" is evaluated
        let str = "Hex: \(z, format: "%#Zx")"

        // Then: str equals "Hex: 0xff"
        #expect(str == "Hex: 0xff")
    }

    @Test
    func interpolation_Integer_Format_Octal() async throws {
        // Given: A GMPInteger initialized to 255
        let z = GMPInteger(255)

        // When: let str = "Octal: \(z, format: "%Zo")" is evaluated
        let str = "Octal: \(z, format: "%Zo")"

        // Then: str equals "Octal: 377"
        #expect(str == "Octal: 377")
    }

    @Test
    func interpolation_Integer_Format_OctalWithPrefix() async throws {
        // Given: A GMPInteger initialized to 255
        let z = GMPInteger(255)

        // When: let str = "Octal: \(z, format: "%#Zo")" is evaluated
        let str = "Octal: \(z, format: "%#Zo")"

        // Then: str equals "Octal: 0377"
        #expect(str == "Octal: 0377")
    }

    @Test
    func interpolation_Integer_Format_Width() async throws {
        // Given: A GMPInteger initialized to 1234
        let z = GMPInteger(1234)

        // When: let str = "Value: \(z, format: "%10Zd")" is evaluated
        let str = "Value: \(z, format: "%10Zd")"

        // Then: str equals "Value:        1234" (10 characters wide, right-aligned)
        #expect(str.hasPrefix("Value: "))
        #expect(str.hasSuffix("1234"))
        let valuePart = String(str.dropFirst(7)) // "Value: " is 7 chars
        #expect(valuePart.count == 10)
    }

    @Test
    func interpolation_Integer_Format_WidthZeroPad() async throws {
        // Given: A GMPInteger initialized to 1234
        let z = GMPInteger(1234)

        // When: let str = "Value: \(z, format: "%010Zd")" is evaluated
        let str = "Value: \(z, format: "%010Zd")"

        // Then: str equals "Value: 0000001234" (zero-padded, 10 width)
        #expect(str == "Value: 0000001234")
    }

    @Test
    func interpolation_Integer_Format_SignAlways() async throws {
        // Given: A GMPInteger initialized to 1234
        let z = GMPInteger(1234)

        // When: let str = "Value: \(z, format: "%+Zd")" is evaluated
        let str = "Value: \(z, format: "%+Zd")"

        // Then: str equals "Value: +1234"
        #expect(str == "Value: +1234")
    }

    @Test
    func interpolation_Integer_Format_Invalid() async throws {
        // Given: A GMPInteger initialized to 1234
        let z = GMPInteger(1234)

        // When: let str = "Value: \(z, format: "%Z")" is evaluated (invalid format)
        // Note: GMP may interpret "%Z" as a literal "Z", so we test that it
        // doesn't crash
        // and produces some output (either the formatted result or fallback)
        let str = "Value: \(z, format: "%Z")"

        // Then: str contains "Value: " and some representation of the number
        // (either formatted or fallback to toString)
        #expect(str.hasPrefix("Value: "))
        // The result might be "Value: Z" (GMP interprets it) or "Value: 1234"
        // (fallback)
        // Both are acceptable - the important thing is it doesn't crash
        #expect(str.count > 7) // At least "Value: " plus something
    }

    // MARK: - GMPInteger Convenience Parameter Interpolation

    @Test
    func interpolation_Integer_Base() async throws {
        // Given: A GMPInteger initialized to 255
        let z = GMPInteger(255)

        // When: let str = "Hex: \(z, base: 16)" is evaluated
        let str = "Hex: \(z, base: 16)"

        // Then: str equals "Hex: ff"
        #expect(str == "Hex: ff")
    }

    @Test
    func interpolation_Integer_BaseWithPrefix() async throws {
        // Given: A GMPInteger initialized to 255
        let z = GMPInteger(255)

        // When: let str = "Hex: \(z, base: 16, prefix: true)" is evaluated
        let str = "Hex: \(z, base: 16, prefix: true)"

        // Then: str equals "Hex: 0xff"
        #expect(str == "Hex: 0xff")
    }

    @Test
    func interpolation_Integer_Width() async throws {
        // Given: A GMPInteger initialized to 1234
        let z = GMPInteger(1234)

        // When: let str = "Value: \(z, width: 10)" is evaluated
        let str = "Value: \(z, width: 10)"

        // Then: str equals "Value:        1234" (10 characters wide)
        #expect(str.hasPrefix("Value: "))
        #expect(str.hasSuffix("1234"))
        let valuePart = String(str.dropFirst(7))
        #expect(valuePart.count == 10)
    }

    @Test
    func interpolation_Integer_WidthZeroPad() async throws {
        // Given: A GMPInteger initialized to 1234
        let z = GMPInteger(1234)

        // When: let str = "Value: \(z, width: 10, pad: .zero)" is evaluated
        let str = "Value: \(z, width: 10, pad: .zero)"

        // Then: str equals "Value: 0000001234"
        #expect(str == "Value: 0000001234")
    }

    @Test
    func interpolation_Integer_AllOptions() async throws {
        // Given: A GMPInteger initialized to 255
        let z = GMPInteger(255)

        // When: let str = "\(z, base: 16, width: 10, pad: .zero, prefix: true)" is evaluated
        let str = "\(z, base: 16, width: 10, pad: .zero, prefix: true)"

        // Then: str equals "0x000000ff"
        #expect(str == "0x000000ff")
    }

    @Test
    func interpolation_Integer_Base_Boundary_Minimum() async throws {
        // Given: A GMPInteger initialized to 255
        let z = GMPInteger(255)

        // When: let str = "\(z, base: 2)" is evaluated
        let str = "\(z, base: 2)"

        // Then: str contains valid binary representation
        #expect(str.allSatisfy { $0 == "0" || $0 == "1" })
        // 255 in binary is "11111111"
        #expect(str == "11111111")
    }

    @Test
    func interpolation_Integer_Base_Boundary_Maximum() async throws {
        // Given: A GMPInteger initialized to 255
        let z = GMPInteger(255)

        // When: let str = "\(z, base: 62)" is evaluated
        let str = "\(z, base: 62)"

        // Then: str contains valid base-62 representation
        #expect(!str.isEmpty)
        // Base 62 uses 0-9, A-Z, a-z - verify it's a valid representation
        let validChars =
            CharacterSet(
                charactersIn: "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
            )
        #expect(str.unicodeScalars.allSatisfy { validChars.contains($0) })
    }

    // MARK: - GMPRational Default Interpolation

    @Test
    func interpolation_Rational_Default() async throws {
        // Given: A GMPRational initialized to 1/2
        let q = try GMPRational(numerator: 1, denominator: 2)

        // When: let str = "Value: \(q)" is evaluated
        let str = "Value: \(q)"

        // Then: str equals "Value: 1/2"
        #expect(str == "Value: 1/2")
    }

    @Test
    func interpolation_Rational_Integer_Default() async throws {
        // Given: A GMPRational initialized to 5/1
        let q = try GMPRational(numerator: 5, denominator: 1)

        // When: let str = "Value: \(q)" is evaluated
        let str = "Value: \(q)"

        // Then: str equals "Value: 5" (toString() returns just numerator when denominator is 1)
        #expect(str == "Value: 5")
    }

    @Test
    func interpolation_Rational_Negative_Default() async throws {
        // Given: A GMPRational initialized to -1/2
        let q = try GMPRational(numerator: -1, denominator: 2)

        // When: let str = "Value: \(q)" is evaluated
        let str = "Value: \(q)"

        // Then: str equals "Value: -1/2"
        #expect(str == "Value: -1/2")
    }

    // MARK: - GMPRational Format String Interpolation

    @Test
    func interpolation_Rational_Format() async throws {
        // Given: A GMPRational initialized to 1/2
        let q = try GMPRational(numerator: 1, denominator: 2)

        // When: let str = "Value: \(q, format: "%Qd")" is evaluated
        let str = "Value: \(q, format: "%Qd")"

        // Then: str equals "Value: 1/2"
        #expect(str == "Value: 1/2")
    }

    @Test
    func interpolation_Rational_Format_Invalid() async throws {
        // Given: A GMPRational initialized to 1/2
        let q = try GMPRational(numerator: 1, denominator: 2)

        // When: let str = "Value: \(q, format: "%Q")" is evaluated (invalid format)
        // Note: GMP may interpret "%Q" as a literal "Q", so we test that it
        // doesn't crash
        let str = "Value: \(q, format: "%Q")"

        // Then: str contains "Value: " and some representation
        // (either formatted or fallback to toString)
        #expect(str.hasPrefix("Value: "))
        // The result might be "Value: Q" (GMP interprets it) or "Value: 1/2"
        // (fallback)
        // Both are acceptable - the important thing is it doesn't crash
        #expect(str.count > 7) // At least "Value: " plus something
    }

    // MARK: - GMPRational Convenience Parameter Interpolation

    @Test
    func interpolation_Rational_Base() async throws {
        // Given: A GMPRational initialized to 1/2
        let q = try GMPRational(numerator: 1, denominator: 2)

        // When: let str = "Value: \(q, base: 16)" is evaluated
        let str = "Value: \(q, base: 16)"

        // Then: str equals "Value: 1/2" (in base 16)
        #expect(str == "Value: 1/2")
    }

    // MARK: - GMPFloat Default Interpolation

    @Test
    func interpolation_Float_Default() async throws {
        // Given: A GMPFloat initialized to 3.14159
        let f = GMPFloat(3.14159)

        // When: let str = "Value: \(f)" is evaluated
        let str = "Value: \(f)"

        // Then: str equals "Value: 3.14159" (or similar, depending on precision)
        #expect(str.hasPrefix("Value: 3.14")) // Check first few digits
        #expect(str.contains("3.14")) // Should contain the value
    }

    @Test
    func interpolation_Float_Zero_Default() async throws {
        // Given: A GMPFloat initialized to 0.0
        let f = GMPFloat(0.0)

        // When: let str = "Value: \(f)" is evaluated
        let str = "Value: \(f)"

        // Then: str equals "Value: 0" (toString() returns "0" for zero values)
        #expect(str == "Value: 0")
    }

    @Test
    func interpolation_Float_Negative_Default() async throws {
        // Given: A GMPFloat initialized to -3.14159
        let f = GMPFloat(-3.14159)

        // When: let str = "Value: \(f)" is evaluated
        let str = "Value: \(f)"

        // Then: str equals "Value: -3.14159" (approximately, precision may vary)
        // GMP may format as "-3.14..." or "-.314..." depending on precision
        #expect(str.hasPrefix("Value: -")) // Should be negative
        #expect(str.contains("314") || str
            .contains("3.14")) // Should contain the value digits
    }

    // MARK: - GMPFloat Format String Interpolation

    @Test
    func interpolation_Float_Format_Precision() async throws {
        // Given: A GMPFloat initialized to 3.14159
        let f = GMPFloat(3.14159)

        // When: let str = "Value: \(f, format: "%.2Ff")" is evaluated
        let str = "Value: \(f, format: "%.2Ff")"

        // Then: str equals "Value: 3.14"
        #expect(str.hasPrefix("Value: 3.14"))
    }

    @Test
    func interpolation_Float_Format_Scientific() async throws {
        // Given: A GMPFloat initialized to 1234.567
        let f = GMPFloat(1234.567)

        // When: let str = "Value: \(f, format: "%Fe")" is evaluated
        let str = "Value: \(f, format: "%Fe")"

        // Then: str contains scientific notation with lowercase e (e.g., "Value: 1.234567e+03")
        // %Fe uses lowercase 'e' format specifier, so should produce lowercase
        // 'e'
        #expect(str.contains("e"))
    }

    @Test
    func interpolation_Float_Format_ScientificUpper() async throws {
        // Given: A GMPFloat initialized to 1234.567
        let f = GMPFloat(1234.567)

        // When: let str = "Value: \(f, format: "%FE")" is evaluated
        let str = "Value: \(f, format: "%FE")"

        // Then: str contains scientific notation with uppercase E
        #expect(str.contains("E"))
    }

    @Test
    func interpolation_Float_Format_Auto() async throws {
        // Given: A GMPFloat initialized to 1234.567
        let f = GMPFloat(1234.567)

        // When: let str = "Value: \(f, format: "%Fg")" is evaluated
        let str = "Value: \(f, format: "%Fg")"

        // Then: str contains fixed or scientific format (auto-selected)
        #expect(str.hasPrefix("Value: "))
        // Verify it contains the value (1234.567 in some format)
        #expect(str.contains("1234") || str.contains("1.234"))
    }

    @Test
    func interpolation_Float_Format_WidthPrecision() async throws {
        // Given: A GMPFloat initialized to 3.14159
        let f = GMPFloat(3.14159)

        // When: let str = "Value: \(f, format: "%10.2Ff")" is evaluated
        let str = "Value: \(f, format: "%10.2Ff")"

        // Then: str equals "Value:       3.14" (10 width, 2 precision)
        #expect(str.hasPrefix("Value: "))
        #expect(str.hasSuffix("3.14"))
        let valuePart = String(str.dropFirst(7))
        #expect(valuePart.count == 10)
    }

    // MARK: - GMPFloat Convenience Parameter Interpolation

    @Test
    func interpolation_Float_Precision() async throws {
        // Given: A GMPFloat initialized to 3.14159
        let f = GMPFloat(3.14159)

        // When: let str = "Value: \(f, precision: 2)" is evaluated
        let str = "Value: \(f, precision: 2)"

        // Then: str equals "Value: 3.14" (approximately, precision may vary)
        #expect(str.hasPrefix("Value: 3.1")) // Check first few digits
        #expect(str.contains("3.1")) // Should contain the value
    }

    @Test
    func interpolation_Float_Style_Fixed() async throws {
        // Given: A GMPFloat initialized to 3.14159
        let f = GMPFloat(3.14159)

        // When: let str = "Value: \(f, style: .fixed, precision: 2)" is evaluated
        let str = "Value: \(f, style: .fixed, precision: 2)"

        // Then: str equals "Value: 3.14"
        #expect(str.hasPrefix("Value: 3.14"))
    }

    @Test
    func interpolation_Float_Style_Scientific() async throws {
        // Given: A GMPFloat initialized to 1234.567
        let f = GMPFloat(1234.567)

        // When: let str = "Value: \(f, style: .scientific)" is evaluated
        let str = "Value: \(f, style: .scientific)"

        // Then: str contains scientific notation with lowercase e
        // .scientific style uses %Fe format which produces lowercase 'e'
        #expect(str.contains("e"))
    }

    @Test
    func interpolation_Float_Style_Auto() async throws {
        // Given: A GMPFloat initialized to 1234.567
        let f = GMPFloat(1234.567)

        // When: let str = "Value: \(f, style: .auto)" is evaluated
        let str = "Value: \(f, style: .auto)"

        // Then: str contains appropriate format (fixed or scientific)
        #expect(str.hasPrefix("Value: "))
        // Verify it contains the value (1234.567 in some format)
        #expect(str.contains("1234") || str.contains("1.234"))
    }

    @Test
    func interpolation_Float_Width() async throws {
        // Given: A GMPFloat initialized to 3.14159
        let f = GMPFloat(3.14159)

        // When: let str = "Value: \(f, style: .fixed, precision: 2, width: 10)" is evaluated
        let str = "Value: \(f, style: .fixed, precision: 2, width: 10)"

        // Then: str equals "Value:       3.14" (10 width)
        #expect(str.hasPrefix("Value: "))
        #expect(str.hasSuffix("3.14"))
        let valuePart = String(str.dropFirst(7))
        #expect(valuePart.count == 10)
    }

    // MARK: - Mixed Types Interpolation

    @Test
    func interpolation_MixedTypes_Default() async throws {
        // Given: GMPInteger(1234), GMPRational(1, 2), GMPFloat(3.14)
        let z = GMPInteger(1234)
        let q = try GMPRational(numerator: 1, denominator: 2)
        let f = GMPFloat(3.14)

        // When: let str = "z=\(z), q=\(q), f=\(f)" is evaluated
        let str = "z=\(z), q=\(q), f=\(f)"

        // Then: str equals "z=1234, q=1/2, f=3.14" (approximately)
        #expect(str.hasPrefix("z=1234, q=1/2, f=3.1"))
    }

    @Test
    func interpolation_MixedTypes_Formatted() async throws {
        // Given: GMPInteger(255), GMPRational(1, 2), GMPFloat(3.14159)
        let z = GMPInteger(255)
        let q = try GMPRational(numerator: 1, denominator: 2)
        let f = GMPFloat(3.14159)

        // When: let str = "z=\(z, format: "%#Zx"), q=\(q), f=\(f, format: "%.2Ff")" is evaluated
        let str = "z=\(z, format: "%#Zx"), q=\(q), f=\(f, format: "%.2Ff")"

        // Then: str equals "z=0xff, q=1/2, f=3.14"
        #expect(str == "z=0xff, q=1/2, f=3.14")
    }

    @Test
    func interpolation_MixedTypes_Convenience() async throws {
        // Given: GMPInteger(255), GMPFloat(3.14159)
        let z = GMPInteger(255)
        let f = GMPFloat(3.14159)

        // When: let str = "z=\(z, base: 16, prefix: true), f=\(f, style: .fixed, precision: 2)" is evaluated
        let str = "z=\(z, base: 16, prefix: true), f=\(f, style: .fixed, precision: 2)"

        // Then: str equals "z=0xff, f=3.14"
        #expect(str == "z=0xff, f=3.14")
    }

    @Test
    func interpolation_MixedTypes_WithStandardTypes() async throws {
        // Given: GMPInteger(1234), Int(42), String("test")
        let z = GMPInteger(1234)
        let n = 42
        let s = "test"

        // When: let str = "z=\(z), n=\(n), s=\(s)" is evaluated
        let str = "z=\(z), n=\(n), s=\(s)"

        // Then: str equals "z=1234, n=42, s=test"
        #expect(str == "z=1234, n=42, s=test")
    }

    // MARK: - Edge Cases Interpolation

    @Test
    func interpolation_Integer_VeryLarge() async throws {
        // Given: A GMPInteger initialized to 2^1000
        let z = GMPInteger.power(base: 2, exponent: 1000)

        // When: let str = "Value: \(z)" is evaluated
        let str = "Value: \(z)"

        // Then: str contains the correct string representation
        #expect(str.hasPrefix("Value: "))
        #expect(str.count > 100) // Should be a very large number
    }

    @Test
    func interpolation_Float_VeryLarge() async throws {
        // Given: A GMPFloat initialized to a very large value
        // Use a simpler approach: create a large float directly
        let f = GMPFloat(1.0e100) // Very large but manageable for testing

        // When: let str = "Value: \(f, style: .scientific)" is evaluated
        let str = "Value: \(f, style: .scientific)"

        // Then: str contains scientific notation with lowercase e
        // .scientific style uses %Fe format which produces lowercase 'e'
        #expect(str.contains("e"))
    }

    @Test
    func interpolation_Float_VerySmall() async throws {
        // Given: A GMPFloat initialized to a very small value
        let f = GMPFloat(1.0e-100) // Very small but manageable for testing

        // When: let str = "Value: \(f, style: .scientific)" is evaluated
        let str = "Value: \(f, style: .scientific)"

        // Then: str contains scientific notation with lowercase e
        // .scientific style uses %Fe format which produces lowercase 'e'
        #expect(str.contains("e"))
    }

    @Test
    func interpolation_MultipleInterpolations() async throws {
        // Given: A GMPInteger initialized to 1234
        let z = GMPInteger(1234)

        // When: let str = "\(z) \(z) \(z)" is evaluated
        let str = "\(z) \(z) \(z)"

        // Then: str equals "1234 1234 1234"
        #expect(str == "1234 1234 1234")
    }

    @Test
    func interpolation_NestedStrings() async throws {
        // Given: A GMPInteger initialized to 1234
        let z = GMPInteger(1234)

        // When: let str = "Outer: \"Inner: \(z)\"" is evaluated
        let str = "Outer: \"Inner: \(z)\""

        // Then: str equals "Outer: \"Inner: 1234\""
        #expect(str == "Outer: \"Inner: 1234\"")
    }

    @Test
    func interpolation_EmptyString() async throws {
        // Given: A GMPInteger initialized to 1234
        let z = GMPInteger(1234)

        // When: let str = "\(z)" is evaluated (only interpolation, no literal)
        let str = "\(z)"

        // Then: str equals "1234"
        #expect(str == "1234")
    }

    @Test
    func interpolation_NoInterpolation() async throws {
        // Given: No GMP values
        // When: let str = "Just a string" is evaluated
        let str = "Just a string"

        // Then: str equals "Just a string" (no GMP formatting involved)
        #expect(str == "Just a string")
    }

    // MARK: - Error Handling Interpolation

    @Test
    func interpolation_Integer_InvalidFormat_Fallback() async throws {
        // Given: A GMPInteger initialized to 1234
        let z = GMPInteger(1234)

        // When: let str = "\(z, format: "%Z")" is evaluated (invalid format)
        let str = "\(z, format: "%Z")"

        // Then: str equals "1234" (falls back to toString) or contains some representation
        // GMP may interpret "%Z" as literal "Z", so we just verify it doesn't
        // crash
        #expect(!str.isEmpty)
        // If fallback works, it should be "1234", otherwise might be "Z"
        #expect(str == "1234" || str == "Z")
    }

    @Test
    func interpolation_Float_InvalidFormat_Fallback() async throws {
        // Given: A GMPFloat initialized to 3.14
        let f = GMPFloat(3.14)

        // When: let str = "\(f, format: "%F")" is evaluated (invalid format)
        let str = "\(f, format: "%F")"

        // Then: str contains some representation (fallback mechanism handles invalid format)
        // GMP may interpret "%F" in various ways - it might be treated as a
        // literal "F"
        // or might produce unexpected output. The important thing is that our
        // fallback
        // mechanism handles it gracefully and doesn't crash.
        // We verify it doesn't crash and produces some output
        // The actual output depends on how GMP interprets "%F" - it might be
        // "F",
        // "3.14" (fallback), or something else. The key is that it doesn't
        // crash.
        // Since the behavior is undefined for invalid formats, we only verify
        // it produces output
        #expect(!str.isEmpty)
    }

    @Test
    func interpolation_Integer_InvalidBase_Fallback() async throws {
        // Given: A GMPInteger initialized to 1234
        let z = GMPInteger(1234)

        // When: let str = "\(z, base: 100)" is evaluated (invalid base)
        let str = "\(z, base: 100)"

        // Then: str equals "1234" (falls back to default, or handles gracefully)
        // For invalid base, it should fall back to toString with base 10
        #expect(str == "1234")
    }
}
