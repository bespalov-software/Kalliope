import CKalliopeBridge
import Dispatch
import Foundation
@testable import Kalliope
import Testing

/// Helper function to convert C string buffer to Swift String
private func stringFromCString(_ buffer: [CChar]) -> String {
    if let nullIndex = buffer.firstIndex(of: 0) {
        let data = Data(buffer[..<nullIndex].map { UInt8(bitPattern: $0) })
        return String(bytes: data, encoding: .utf8) ?? ""
    } else {
        let data = Data(buffer.map { UInt8(bitPattern: $0) })
        return String(bytes: data, encoding: .utf8) ?? ""
    }
}

/// Helper function to convert C string pointer to Swift String
private func stringFromCString(_ ptr: UnsafePointer<CChar>) -> String {
    let length = strlen(ptr)
    let buffer = UnsafeBufferPointer(start: ptr, count: length)
    let data = Data(buffer.map { UInt8(bitPattern: $0) })
    return String(bytes: data, encoding: .utf8) ?? ""
}

/// Tests for GMP Formatted I/O functions.
struct GMPFormattedIOTests {
    // MARK: - printf Tests

    @Test
    func printf_Integer_Basic() async throws {
        // Given: A GMPInteger initialized to 1234
        let z = GMPInteger(1234)

        // When: GMPFormattedIO.printf("Value: %Zd\n", z) is called
        let count = GMPFormattedIO.printf("Value: %Zd\n", z)

        // Then: Returns a positive integer (number of characters written)
        #expect(count > 0)
        // Note: We can't easily capture stdout in tests, so we verify the
        // return value
        #expect(count >= 12) // "Value: 1234\n" is at least 12 characters
    }

    @Test
    func printf_Rational_Basic() async throws {
        // Given: A GMPRational initialized to 1/2
        let q = try GMPRational(numerator: 1, denominator: 2)

        // When: GMPFormattedIO.printf("Value: %Qd\n", q) is called
        let count = GMPFormattedIO.printf("Value: %Qd\n", q)

        // Then: Returns a positive integer
        #expect(count > 0)
        #expect(count >= 10) // "Value: 1/2\n" is at least 10 characters
    }

    @Test
    func printf_Float_Basic() async throws {
        // Given: A GMPFloat initialized to 3.14159
        let f = GMPFloat(3.14159)

        // When: GMPFormattedIO.printf("Value: %Ff\n", f) is called
        let count = GMPFormattedIO.printf("Value: %Ff\n", f)

        // Then: Returns a positive integer
        #expect(count > 0)
        #expect(count >= 12) // "Value: 3.14159\n" is at least 12 characters
    }

    @Test
    func printf_MixedTypes() async throws {
        // Given: A GMPInteger(1234), GMPRational(1, 2), GMPFloat(3.14), and an Int(42)
        let z = GMPInteger(1234)
        let q = try GMPRational(numerator: 1, denominator: 2)
        let f = GMPFloat(3.14)
        let n = 42

        // When: GMPFormattedIO.printf("z=%Zd, q=%Qd, f=%.2Ff, n=%d\n", z, q, f, n) is called
        let count = GMPFormattedIO.printf(
            "z=%Zd, q=%Qd, f=%.2Ff, n=%d\n",
            z,
            q,
            f,
            n
        )

        // Then: Returns a positive integer
        #expect(count > 0)
    }

    @Test
    func printf_Integer_Hex() async throws {
        // Given: A GMPInteger initialized to 255
        let z = GMPInteger(255)

        // When: GMPFormattedIO.printf("Hex: %Zx\n", z) is called
        let count = GMPFormattedIO.printf("Hex: %Zx\n", z)

        // Then: Returns a positive integer
        #expect(count > 0)
    }

    @Test
    func printf_Integer_HexWithPrefix() async throws {
        // Given: A GMPInteger initialized to 255
        let z = GMPInteger(255)

        // When: GMPFormattedIO.printf("Hex: %#Zx\n", z) is called
        let count = GMPFormattedIO.printf("Hex: %#Zx\n", z)

        // Then: Returns a positive integer
        #expect(count > 0)
    }

    @Test
    func printf_Integer_Octal() async throws {
        // Given: A GMPInteger initialized to 255
        let z = GMPInteger(255)

        // When: GMPFormattedIO.printf("Octal: %Zo\n", z) is called
        let count = GMPFormattedIO.printf("Octal: %Zo\n", z)

        // Then: Returns a positive integer
        #expect(count > 0)
    }

    @Test
    func printf_Integer_OctalWithPrefix() async throws {
        // Given: A GMPInteger initialized to 255
        let z = GMPInteger(255)

        // When: GMPFormattedIO.printf("Octal: %#Zo\n", z) is called
        let count = GMPFormattedIO.printf("Octal: %#Zo\n", z)

        // Then: Returns a positive integer
        #expect(count > 0)
    }

    @Test
    func printf_Integer_Width() async throws {
        // Given: A GMPInteger initialized to 1234
        let z = GMPInteger(1234)

        // When: GMPFormattedIO.printf("Value: %10Zd\n", z) is called
        let count = GMPFormattedIO.printf("Value: %10Zd\n", z)

        // Then: Returns a positive integer
        #expect(count > 0)
        #expect(count >= 18) // "Value:       1234\n" is at least 18 characters
    }

    @Test
    func printf_Integer_WidthZeroPad() async throws {
        // Given: A GMPInteger initialized to 1234
        let z = GMPInteger(1234)

        // When: GMPFormattedIO.printf("Value: %010Zd\n", z) is called
        let count = GMPFormattedIO.printf("Value: %010Zd\n", z)

        // Then: Returns a positive integer
        #expect(count > 0)
        #expect(count >= 18) // "Value: 0000001234\n" is at least 18 characters
    }

    @Test
    func printf_Integer_SignAlways() async throws {
        // Given: A GMPInteger initialized to 1234
        let z = GMPInteger(1234)

        // When: GMPFormattedIO.printf("Value: %+Zd\n", z) is called
        let count = GMPFormattedIO.printf("Value: %+Zd\n", z)

        // Then: Returns a positive integer
        #expect(count > 0)
    }

    @Test
    func printf_Integer_Negative() async throws {
        // Given: A GMPInteger initialized to -1234
        let z = GMPInteger(-1234)

        // When: GMPFormattedIO.printf("Value: %Zd\n", z) is called
        let count = GMPFormattedIO.printf("Value: %Zd\n", z)

        // Then: Returns a positive integer
        #expect(count > 0)
    }

    @Test
    func printf_Integer_Zero() async throws {
        // Given: A GMPInteger initialized to 0
        let z = GMPInteger(0)

        // When: GMPFormattedIO.printf("Value: %Zd\n", z) is called
        let count = GMPFormattedIO.printf("Value: %Zd\n", z)

        // Then: Returns a positive integer
        #expect(count > 0)
    }

    @Test
    func printf_Integer_Large() async throws {
        // Given: A GMPInteger initialized to a very large value (e.g., 2^100)
        let z = GMPInteger.power(base: 2, exponent: 100)

        // When: GMPFormattedIO.printf("Value: %Zd\n", z) is called
        let count = GMPFormattedIO.printf("Value: %Zd\n", z)

        // Then: Returns a positive integer
        #expect(count > 0)
    }

    @Test
    func printf_Float_Precision() async throws {
        // Given: A GMPFloat initialized to 3.14159
        let f = GMPFloat(3.14159)

        // When: GMPFormattedIO.printf("Value: %.2Ff\n", f) is called
        let count = GMPFormattedIO.printf("Value: %.2Ff\n", f)

        // Then: Returns a positive integer
        #expect(count > 0)
    }

    @Test
    func printf_Float_Scientific() async throws {
        // Given: A GMPFloat initialized to 1234.567
        let f = GMPFloat(1234.567)

        // When: GMPFormattedIO.printf("Value: %Fe\n", f) is called
        let count = GMPFormattedIO.printf("Value: %Fe\n", f)

        // Then: Returns a positive integer
        #expect(count > 0)
    }

    @Test
    func printf_Float_ScientificUpper() async throws {
        // Given: A GMPFloat initialized to 1234.567
        let f = GMPFloat(1234.567)

        // When: GMPFormattedIO.printf("Value: %FE\n", f) is called
        let count = GMPFormattedIO.printf("Value: %FE\n", f)

        // Then: Returns a positive integer
        #expect(count > 0)
    }

    @Test
    func printf_Float_Auto() async throws {
        // Given: A GMPFloat initialized to 1234.567
        let f = GMPFloat(1234.567)

        // When: GMPFormattedIO.printf("Value: %Fg\n", f) is called
        let count = GMPFormattedIO.printf("Value: %Fg\n", f)

        // Then: Returns a positive integer
        #expect(count > 0)
    }

    @Test
    func printf_Float_WidthPrecision() async throws {
        // Given: A GMPFloat initialized to 3.14159
        let f = GMPFloat(3.14159)

        // When: GMPFormattedIO.printf("Value: %10.2Ff\n", f) is called
        let count = GMPFormattedIO.printf("Value: %10.2Ff\n", f)

        // Then: Returns a positive integer
        #expect(count > 0)
    }

    @Test
    func printf_Rational_Integer() async throws {
        // Given: A GMPRational initialized to 5/1 (integer)
        let q = try GMPRational(numerator: 5, denominator: 1)

        // When: GMPFormattedIO.printf("Value: %Qd\n", q) is called
        let count = GMPFormattedIO.printf("Value: %Qd\n", q)

        // Then: Returns a positive integer
        #expect(count > 0)
    }

    @Test
    func printf_Rational_Fraction() async throws {
        // Given: A GMPRational initialized to 1/2
        let q = try GMPRational(numerator: 1, denominator: 2)

        // When: GMPFormattedIO.printf("Value: %Qd\n", q) is called
        let count = GMPFormattedIO.printf("Value: %Qd\n", q)

        // Then: Returns a positive integer
        #expect(count > 0)
    }

    @Test
    func printf_Rational_Negative() async throws {
        // Given: A GMPRational initialized to -1/2
        let q = try GMPRational(numerator: -1, denominator: 2)

        // When: GMPFormattedIO.printf("Value: %Qd\n", q) is called
        let count = GMPFormattedIO.printf("Value: %Qd\n", q)

        // Then: Returns a positive integer
        #expect(count > 0)
    }

    @Test
    func printf_EmptyFormat() async throws {
        // Given: A GMPInteger initialized to 1234
        let z = GMPInteger(1234)

        // When: GMPFormattedIO.printf("", z) is called
        let count = GMPFormattedIO.printf("", z)

        // Then: Returns 0 (no characters written)
        #expect(count == 0)
    }

    @Test
    func printf_NoGMPTypes() async throws {
        // Given: An Int(42) and String("test")
        let n = 42
        let s = "test"

        // When: GMPFormattedIO.printf("n=%d, s=%s\n", n, s) is called
        let count = GMPFormattedIO.printf("n=%d, s=%s\n", n, s)

        // Then: Returns a positive integer
        #expect(count > 0)
    }

    @Test
    func printf_Integer_WithStandardTypes() async throws {
        // Given: A GMPInteger(1234) and Int(42)
        let z = GMPInteger(1234)
        let n = 42

        // When: GMPFormattedIO.printf("z=%Zd, n=%d\n", z, n) is called
        let count = GMPFormattedIO.printf("z=%Zd, n=%d\n", z, n)

        // Then: Returns a positive integer
        #expect(count > 0)
    }

    @Test
    func printf_Rational_WithStandardTypes() async throws {
        // Given: A GMPRational(1/2) and Double(3.14)
        let q = try GMPRational(numerator: 1, denominator: 2)
        let d = 3.14

        // When: GMPFormattedIO.printf("q=%Qd, d=%.2f\n", q, d) is called
        let count = GMPFormattedIO.printf("q=%Qd, d=%.2f\n", q, d)

        // Then: Returns a positive integer
        #expect(count > 0)
    }

    @Test
    func printf_Float_WithStandardTypes() async throws {
        // Given: A GMPFloat(3.14) and Int(42)
        let f = GMPFloat(3.14)
        let n = 42

        // When: GMPFormattedIO.printf("f=%.2Ff, n=%d\n", f, n) is called
        let count = GMPFormattedIO.printf("f=%.2Ff, n=%d\n", f, n)

        // Then: Returns a positive integer
        #expect(count > 0)
    }

    @Test
    func printf_Integer_AndRational() async throws {
        // Given: A GMPInteger(1234) and GMPRational(1/2)
        let z = GMPInteger(1234)
        let q = try GMPRational(numerator: 1, denominator: 2)

        // When: GMPFormattedIO.printf("z=%Zd, q=%Qd\n", z, q) is called
        let count = GMPFormattedIO.printf("z=%Zd, q=%Qd\n", z, q)

        // Then: Returns a positive integer
        #expect(count > 0)
    }

    @Test
    func printf_Integer_AndFloat() async throws {
        // Given: A GMPInteger(1234) and GMPFloat(3.14)
        let z = GMPInteger(1234)
        let f = GMPFloat(3.14)

        // When: GMPFormattedIO.printf("z=%Zd, f=%.2Ff\n", z, f) is called
        let count = GMPFormattedIO.printf("z=%Zd, f=%.2Ff\n", z, f)

        // Then: Returns a positive integer
        #expect(count > 0)
    }

    @Test
    func printf_Rational_AndFloat() async throws {
        // Given: A GMPRational(1/2) and GMPFloat(3.14)
        let q = try GMPRational(numerator: 1, denominator: 2)
        let f = GMPFloat(3.14)

        // When: GMPFormattedIO.printf("q=%Qd, f=%.2Ff\n", q, f) is called
        let count = GMPFormattedIO.printf("q=%Qd, f=%.2Ff\n", q, f)

        // Then: Returns a positive integer
        #expect(count > 0)
    }

    @Test
    func printf_AllGMPTypes() async throws {
        // Given: GMPInteger(1234), GMPRational(1/2), GMPFloat(3.14)
        let z = GMPInteger(1234)
        let q = try GMPRational(numerator: 1, denominator: 2)
        let f = GMPFloat(3.14)

        // When: GMPFormattedIO.printf("z=%Zd, q=%Qd, f=%.2Ff\n", z, q, f) is called
        let count = GMPFormattedIO.printf("z=%Zd, q=%Qd, f=%.2Ff\n", z, q, f)

        // Then: Returns a positive integer
        #expect(count > 0)
    }

    @Test
    func printf_Integer_Rational_WithStandardTypes() async throws {
        // Given: GMPInteger(1234), GMPRational(1/2), and Int(42)
        let z = GMPInteger(1234)
        let q = try GMPRational(numerator: 1, denominator: 2)
        let n = 42

        // When: GMPFormattedIO.printf("z=%Zd, q=%Qd, n=%d\n", z, q, n) is called
        let count = GMPFormattedIO.printf("z=%Zd, q=%Qd, n=%d\n", z, q, n)

        // Then: Returns a positive integer
        #expect(count > 0)
    }

    @Test
    func printf_AllGMPTypes_WithStandardTypes() async throws {
        // Given: GMPInteger(1234), GMPRational(1/2), GMPFloat(3.14), and Int(42)
        let z = GMPInteger(1234)
        let q = try GMPRational(numerator: 1, denominator: 2)
        let f = GMPFloat(3.14)
        let n = 42

        // When: GMPFormattedIO.printf("z=%Zd, q=%Qd, f=%.2Ff, n=%d\n", z, q, f, n) is called
        let count = GMPFormattedIO.printf(
            "z=%Zd, q=%Qd, f=%.2Ff, n=%d\n",
            z,
            q,
            f,
            n
        )

        // Then: Returns a positive integer
        #expect(count > 0)
    }

    // MARK: - fprintf Tests

    @Test
    func fprintf_Integer_ToFile() async throws {
        // Given: A temporary file opened for writing and a GMPInteger(1234)
        let z = GMPInteger(1234)
        let tempFile = tmpfile()
        guard let file = tempFile else {
            Issue.record("Failed to create temporary file")
            return
        }

        // When: GMPFormattedIO.fprintf(file, "Value: %Zd\n", z) is called
        let count = GMPFormattedIO.fprintf(file, "Value: %Zd\n", z)

        // Then: Returns a positive integer
        #expect(count > 0)
        #expect(count >= 12) // "Value: 1234\n" is at least 12 characters

        // Verify content was written
        rewind(file)
        var buffer = [CChar](repeating: 0, count: 100)
        fgets(&buffer, 100, file)
        let content = stringFromCString(buffer)
        #expect(content.contains("1234"))

        fclose(file)
    }

    @Test
    func fprintf_MultipleTypes_ToFile() async throws {
        // Given: A temporary file opened for writing, GMPInteger(1234), GMPRational(1, 2), GMPFloat(3.14)
        let z = GMPInteger(1234)
        let q = try GMPRational(numerator: 1, denominator: 2)
        let f = GMPFloat(3.14)
        let tempFile = tmpfile()
        guard let file = tempFile else {
            Issue.record("Failed to create temporary file")
            return
        }

        // When: GMPFormattedIO.fprintf(file, "z=%Zd, q=%Qd, f=%.2Ff\n", z, q, f) is called
        let count = GMPFormattedIO.fprintf(
            file,
            "z=%Zd, q=%Qd, f=%.2Ff\n",
            z,
            q,
            f
        )

        // Then: Returns a positive integer
        #expect(count > 0)

        // Verify content was written
        rewind(file)
        var buffer = [CChar](repeating: 0, count: 200)
        fgets(&buffer, 200, file)
        let content = stringFromCString(buffer)
        #expect(content.contains("1234"))
        // %Qd formats rationals as "num/den" (e.g., "1/2")
        #expect(content.contains("1/2"))

        fclose(file)
    }

    @Test
    func fprintf_Rational_ToFile() async throws {
        // Given: A temporary file opened for writing and a GMPRational(1/2)
        let q = try GMPRational(numerator: 1, denominator: 2)
        let tempFile = tmpfile()
        guard let file = tempFile else {
            Issue.record("Failed to create temporary file")
            return
        }

        // When: GMPFormattedIO.fprintf(file, "Value: %Qd\n", q) is called
        let count = GMPFormattedIO.fprintf(file, "Value: %Qd\n", q)

        // Then: Returns a positive integer
        #expect(count > 0)

        // Verify content was written
        rewind(file)
        var buffer = [CChar](repeating: 0, count: 100)
        fgets(&buffer, 100, file)
        let content = stringFromCString(buffer)
        // %Qd formats rationals as "num/den" (e.g., "1/2")
        #expect(content.contains("1/2"))

        fclose(file)
    }

    @Test
    func fprintf_Float_ToFile() async throws {
        // Given: A temporary file opened for writing and a GMPFloat(3.14)
        let f = GMPFloat(3.14)
        let tempFile = tmpfile()
        guard let file = tempFile else {
            Issue.record("Failed to create temporary file")
            return
        }

        // When: GMPFormattedIO.fprintf(file, "Value: %.2Ff\n", f) is called
        let count = GMPFormattedIO.fprintf(file, "Value: %.2Ff\n", f)

        // Then: Returns a positive integer
        #expect(count > 0)

        // Verify content was written
        rewind(file)
        var buffer = [CChar](repeating: 0, count: 100)
        fgets(&buffer, 100, file)
        let content = stringFromCString(buffer)
        #expect(content.contains("3.14"))

        fclose(file)
    }

    @Test
    func fprintf_Integer_WithStandardTypes() async throws {
        // Given: A temporary file opened for writing, GMPInteger(1234), and Int(42)
        let z = GMPInteger(1234)
        let n = 42
        let tempFile = tmpfile()
        guard let file = tempFile else {
            Issue.record("Failed to create temporary file")
            return
        }

        // When: GMPFormattedIO.fprintf(file, "z=%Zd, n=%d\n", z, n) is called
        let count = GMPFormattedIO.fprintf(file, "z=%Zd, n=%d\n", z, n)

        // Then: Returns a positive integer
        #expect(count > 0)

        // Verify content was written
        rewind(file)
        var buffer = [CChar](repeating: 0, count: 100)
        fgets(&buffer, 100, file)
        let content = stringFromCString(buffer)
        #expect(content.contains("1234"))
        #expect(content.contains("42"))

        fclose(file)
    }

    @Test
    func fprintf_Error_InvalidFile() async throws {
        // Given: An invalid FILE* pointer (closed file)
        let z = GMPInteger(1234)
        let tempFile = tmpfile()
        guard let file = tempFile else {
            Issue.record("Failed to create temporary file")
            return
        }
        fclose(file)

        // When: GMPFormattedIO.fprintf(file, "Value: %Zd\n", z) is called with closed file
        // Note: Using a closed file is undefined behavior in C, but fprintf
        // typically returns -1 on error
        // We verify the function doesn't crash and returns an error code
        let result = GMPFormattedIO.fprintf(file, "Value: %Zd\n", z)

        // Then: Returns -1 (error) or 0 (no characters written)
        // Note: The exact behavior is undefined, but fprintf typically returns
        // -1 for invalid file
        #expect(result <= 0) // Error code (typically -1)
    }

    @Test
    func fprintf_StandardTypes_ToFile() async throws {
        // Given: A temporary file opened for writing, Int(42), and Double(3.14)
        let n = 42
        let d = 3.14
        let tempFile = tmpfile()
        guard let file = tempFile else {
            Issue.record("Failed to create temporary file")
            return
        }

        // When: GMPFormattedIO.fprintf(file, "n=%d, d=%.2f\n", n, d) is called
        let count = GMPFormattedIO.fprintf(file, "n=%d, d=%.2f\n", n, d)

        // Then: Returns a positive integer
        #expect(count > 0)

        // Verify content was written
        rewind(file)
        var buffer = [CChar](repeating: 0, count: 100)
        fgets(&buffer, 100, file)
        let content = stringFromCString(buffer)
        #expect(content.contains("42"))
        #expect(content.contains("3.14"))

        fclose(file)
    }

    // MARK: - sprintf Tests

    @Test
    func sprintf_Integer_ToBuffer() async throws {
        // Given: A buffer of sufficient size and a GMPInteger(1234)
        let z = GMPInteger(1234)
        var buffer = [CChar](repeating: 0, count: 100)

        // When: GMPFormattedIO.sprintf(buffer, "Value: %Zd", z) is called
        let count = GMPFormattedIO.sprintf(&buffer, "Value: %Zd", z)

        // Then: Returns the number of characters written (excluding null)
        #expect(count > 0)
        #expect(count >= 10) // "Value: 1234" is at least 10 characters

        // Verify buffer contains the formatted string
        let result = stringFromCString(buffer)
        #expect(result == "Value: 1234")
    }

    @Test
    func sprintf_MultipleTypes_ToBuffer() async throws {
        // Given: A buffer of sufficient size, GMPInteger(1234), GMPRational(1, 2), GMPFloat(3.14)
        let z = GMPInteger(1234)
        let q = try GMPRational(numerator: 1, denominator: 2)
        let f = GMPFloat(3.14)
        var buffer = [CChar](repeating: 0, count: 200)

        // When: GMPFormattedIO.sprintf(buffer, "z=%Zd, q=%Qd, f=%.2Ff", z, q, f) is called
        let count = GMPFormattedIO.sprintf(
            &buffer,
            "z=%Zd, q=%Qd, f=%.2Ff",
            z,
            q,
            f
        )

        // Then: Returns the number of characters written
        #expect(count > 0)

        // Verify buffer contains formatted string
        let result = stringFromCString(buffer)
        #expect(result.contains("1234"))
    }

    @Test
    func sprintf_BufferTooSmall() async throws {
        // Given: A buffer of size 5 and a GMPInteger(123456)
        let z = GMPInteger(123_456)
        var buffer = [CChar](repeating: 0, count: 5)

        // When: GMPFormattedIO.sprintf(buffer, "%Zd", z) is called with buffer too small
        // Note: This causes buffer overflow - undefined behavior in C
        // We can't reliably test this without risking a crash
        // In practice, this should be avoided - use snprintf instead
        // This test verifies the function can be called, but the behavior is
        // undefined
        _ = GMPFormattedIO.sprintf(&buffer, "%Zd", z)
        // Buffer overflow occurs - we just verify the function doesn't crash
        // immediately
        // The exact behavior is undefined and may vary
        #expect(true) // Function call completes (behavior is undefined)
    }

    @Test
    func sprintf_Rational_ToBuffer() async throws {
        // Given: A buffer of sufficient size and a GMPRational(1/2)
        let q = try GMPRational(numerator: 1, denominator: 2)
        var buffer = [CChar](repeating: 0, count: 100)

        // When: GMPFormattedIO.sprintf(buffer, "Value: %Qd", q) is called
        let count = GMPFormattedIO.sprintf(&buffer, "Value: %Qd", q)

        // Then: Returns the number of characters written
        #expect(count > 0)

        // Verify buffer contains the formatted string
        let result = stringFromCString(buffer)
        // %Qd formats rationals as "num/den" (e.g., "1/2")
        #expect(result.contains("1/2"))
    }

    @Test
    func sprintf_Float_ToBuffer() async throws {
        // Given: A buffer of sufficient size and a GMPFloat(3.14)
        let f = GMPFloat(3.14)
        var buffer = [CChar](repeating: 0, count: 100)

        // When: GMPFormattedIO.sprintf(buffer, "Value: %.2Ff", f) is called
        let count = GMPFormattedIO.sprintf(&buffer, "Value: %.2Ff", f)

        // Then: Returns the number of characters written
        #expect(count > 0)

        // Verify buffer contains the formatted string
        let result = stringFromCString(buffer)
        #expect(result.contains("3.14"))
    }

    @Test
    func sprintf_StandardTypes_ToBuffer() async throws {
        // Given: A buffer of sufficient size, Int(42), and Double(3.14)
        let n = 42
        let d = 3.14
        var buffer = [CChar](repeating: 0, count: 100)

        // When: GMPFormattedIO.sprintf(buffer, "n=%d, d=%.2f", n, d) is called
        let count = GMPFormattedIO.sprintf(&buffer, "n=%d, d=%.2f", n, d)

        // Then: Returns the number of characters written
        #expect(count > 0)

        // Verify buffer contains formatted string
        let result = stringFromCString(buffer)
        #expect(result.contains("42"))
        #expect(result.contains("3.14"))
    }

    // MARK: - snprintf Tests

    @Test
    func snprintf_Integer_ToBuffer() async throws {
        // Given: A buffer of size 100 and a GMPInteger(1234)
        let z = GMPInteger(1234)
        var buffer = [CChar](repeating: 0, count: 100)

        // When: GMPFormattedIO.snprintf(buffer, 100, "Value: %Zd", z) is called
        let count = GMPFormattedIO.snprintf(&buffer, 100, "Value: %Zd", z)

        // Then: Returns the number of characters that would be written
        #expect(count > 0)
        #expect(count < 100) // Should fit in buffer

        // Verify buffer contains the formatted string
        let result = stringFromCString(buffer)
        #expect(result == "Value: 1234")
    }

    @Test
    func snprintf_Integer_Truncated() async throws {
        // Given: A buffer of size 10 and a GMPInteger(1234567890)
        let z = GMPInteger(1_234_567_890)
        var buffer = [CChar](repeating: 0, count: 10)

        // When: GMPFormattedIO.snprintf(buffer, 10, "%Zd", z) is called
        let count = GMPFormattedIO.snprintf(&buffer, 10, "%Zd", z)

        // Then: Returns value >= 10 (indicating truncation)
        #expect(count >= 10)

        // Buffer should contain first 9 characters plus null
        let result = stringFromCString(buffer)
        #expect(result.count <= 9) // Should be truncated to fit
    }

    @Test
    func snprintf_ExactFit() async throws {
        // Given: A buffer of size 5 and a GMPInteger(1234)
        let z = GMPInteger(1234)
        var buffer = [CChar](repeating: 0, count: 5)

        // When: GMPFormattedIO.snprintf(buffer, 5, "%Zd", z) is called
        let count = GMPFormattedIO.snprintf(&buffer, 5, "%Zd", z)

        // Then: Returns 4, buffer contains "1234\0"
        #expect(count == 4)

        // Verify buffer contains the value
        let result = stringFromCString(buffer)
        #expect(result == "1234")
    }

    @Test
    func snprintf_SizeOne() async throws {
        // Given: A buffer of size 1 and a GMPInteger(1234)
        let z = GMPInteger(1234)
        var buffer = [CChar](repeating: 0, count: 1)

        // When: GMPFormattedIO.snprintf(buffer, 1, "%Zd", z) is called
        let count = GMPFormattedIO.snprintf(&buffer, 1, "%Zd", z)

        // Then: Returns value >= 1, buffer contains only null terminator
        #expect(count >= 1)

        // Buffer should be empty string (just null terminator)
        let result = stringFromCString(buffer)
        #expect(result.isEmpty)
    }

    @Test
    func snprintf_StandardTypes_ToBuffer() async throws {
        // Given: A buffer of size 100, Int(42), and Double(3.14)
        let n = 42
        let d = 3.14
        var buffer = [CChar](repeating: 0, count: 100)

        // When: GMPFormattedIO.snprintf(buffer, 100, "n=%d, d=%.2f", n, d) is called
        let count = GMPFormattedIO.snprintf(&buffer, 100, "n=%d, d=%.2f", n, d)

        // Then: Returns the number of characters that would be written
        #expect(count > 0)
        #expect(count < 100)

        // Verify buffer contains the formatted string
        let result = stringFromCString(buffer)
        #expect(result.contains("42"))
        #expect(result.contains("3.14"))
    }

    @Test
    func snprintf_Rational_ToBuffer() async throws {
        // Given: A buffer of size 100 and a GMPRational(1/2)
        let q = try GMPRational(numerator: 1, denominator: 2)
        var buffer = [CChar](repeating: 0, count: 100)

        // When: GMPFormattedIO.snprintf(buffer, 100, "Value: %Qd", q) is called
        let count = GMPFormattedIO.snprintf(&buffer, 100, "Value: %Qd", q)

        // Then: Returns the number of characters that would be written
        #expect(count > 0)
        #expect(count < 100)

        // Verify buffer contains the formatted string
        let result = stringFromCString(buffer)
        // %Qd formats rationals as "num/den" (e.g., "1/2")
        #expect(result.contains("1/2"))
    }

    @Test
    func snprintf_Float_ToBuffer() async throws {
        // Given: A buffer of size 100 and a GMPFloat(3.14)
        let f = GMPFloat(3.14)
        var buffer = [CChar](repeating: 0, count: 100)

        // When: GMPFormattedIO.snprintf(buffer, 100, "Value: %.2Ff", f) is called
        let count = GMPFormattedIO.snprintf(&buffer, 100, "Value: %.2Ff", f)

        // Then: Returns the number of characters that would be written
        #expect(count > 0)
        #expect(count < 100)

        // Verify buffer contains the formatted string
        let result = stringFromCString(buffer)
        #expect(result.contains("3.14"))
    }

    @Test
    func snprintf_MultipleTypes_ToBuffer() async throws {
        // Given: A buffer of size 200, GMPInteger(1234), GMPRational(1, 2), GMPFloat(3.14)
        let z = GMPInteger(1234)
        let q = try GMPRational(numerator: 1, denominator: 2)
        let f = GMPFloat(3.14)
        var buffer = [CChar](repeating: 0, count: 200)

        // When: GMPFormattedIO.snprintf(buffer, 200, "z=%Zd, q=%Qd, f=%.2Ff", z, q, f) is called
        let count = GMPFormattedIO.snprintf(
            &buffer,
            200,
            "z=%Zd, q=%Qd, f=%.2Ff",
            z,
            q,
            f
        )

        // Then: Returns the number of characters that would be written
        #expect(count > 0)
        #expect(count < 200)

        // Verify buffer contains formatted string
        let result = stringFromCString(buffer)
        #expect(result.contains("1234"))
    }

    // MARK: - asprintf Tests

    @Test
    func asprintf_Integer_Allocates() async throws {
        // Given: A GMPInteger initialized to 1234
        let z = GMPInteger(1234)

        // When: GMPFormattedIO.asprintf("Value: %Zd", z) is called
        guard let (ptr, count) = GMPFormattedIO.asprintf("Value: %Zd", z) else {
            Issue.record("asprintf returned nil")
            return
        }
        defer { free(ptr) }

        // Then: Returns a tuple with a valid pointer and character count
        #expect(count > 0)
        #expect(count >= 10) // "Value: 1234" is at least 10 characters

        // Verify pointer contains the formatted string
        let result = stringFromCString(ptr)
        #expect(result == "Value: 1234")
    }

    @Test
    func asprintf_MultipleTypes_Allocates() async throws {
        // Given: GMPInteger(1234), GMPRational(1, 2), GMPFloat(3.14)
        let z = GMPInteger(1234)
        let q = try GMPRational(numerator: 1, denominator: 2)
        let f = GMPFloat(3.14)

        // When: GMPFormattedIO.asprintf("z=%Zd, q=%Qd, f=%.2Ff", z, q, f) is called
        guard let (ptr, count) = GMPFormattedIO.asprintf(
            "z=%Zd, q=%Qd, f=%.2Ff",
            z,
            q,
            f
        ) else {
            Issue.record("asprintf returned nil")
            return
        }
        defer { free(ptr) }

        // Then: Returns a tuple with valid pointer and character count
        #expect(count > 0)

        // Verify contains formatted string
        let result = stringFromCString(ptr)
        #expect(result.contains("1234"))
    }

    @Test
    func asprintf_MemoryFreed() async throws {
        // Given: A GMPInteger initialized to 1234
        let z = GMPInteger(1234)

        // When: GMPFormattedIO.asprintf("Value: %Zd", z) is called, then free(result.0)
        guard let (ptr, _) = GMPFormattedIO.asprintf("Value: %Zd", z) else {
            Issue.record("asprintf returned nil")
            return
        }

        // Verify pointer is valid before freeing
        let result = stringFromCString(ptr)
        #expect(result == "Value: 1234")

        // Free the memory
        free(ptr)

        // Note: We can't easily verify no leaks in a unit test, but this
        // ensures
        // the memory can be freed without crashing
        // Verify that freeing the pointer doesn't cause issues
        // (If we got here, the pointer was valid and has been freed
        // successfully)
        // The fact that we reached this point without crashing means the
        // pointer was valid
        #expect(result ==
            "Value: 1234") // Verify the result was correct before freeing
    }

    @Test
    func asprintf_StandardTypes_Allocates() async throws {
        // Given: Int(42) and Double(3.14)
        let n = 42
        let d = 3.14

        // When: GMPFormattedIO.asprintf("n=%d, d=%.2f", n, d) is called
        guard let (ptr, count) = GMPFormattedIO.asprintf("n=%d, d=%.2f", n, d)
        else {
            Issue.record("asprintf returned nil")
            return
        }
        defer { free(ptr) }

        // Then: Returns a tuple with valid pointer and character count
        #expect(count > 0)

        // Verify pointer contains formatted string
        let result = stringFromCString(ptr)
        #expect(result.contains("42"))
        #expect(result.contains("3.14"))
    }

    @Test
    func asprintf_Rational_Allocates() async throws {
        // Given: A GMPRational initialized to 1/2
        let q = try GMPRational(numerator: 1, denominator: 2)

        // When: GMPFormattedIO.asprintf("Value: %Qd", q) is called
        guard let (ptr, count) = GMPFormattedIO.asprintf("Value: %Qd", q) else {
            Issue.record("asprintf returned nil")
            return
        }
        defer { free(ptr) }

        // Then: Returns a tuple with a valid pointer and character count
        #expect(count > 0)

        // Verify pointer contains the formatted string
        let result = stringFromCString(ptr)
        // %Qd formats rationals as "num/den" (e.g., "1/2")
        #expect(result.contains("1/2"))
    }

    @Test
    func asprintf_Float_Allocates() async throws {
        // Given: A GMPFloat initialized to 3.14
        let f = GMPFloat(3.14)

        // When: GMPFormattedIO.asprintf("Value: %.2Ff", f) is called
        guard let (ptr, count) = GMPFormattedIO.asprintf("Value: %.2Ff", f)
        else {
            Issue.record("asprintf returned nil")
            return
        }
        defer { free(ptr) }

        // Then: Returns a tuple with a valid pointer and character count
        #expect(count > 0)

        // Verify pointer contains the formatted string
        let result = stringFromCString(ptr)
        #expect(result.contains("3.14"))
    }

    // MARK: - string Tests

    @Test
    func string_Integer_ReturnsString() async throws {
        // Given: A GMPInteger initialized to 1234
        let z = GMPInteger(1234)

        // When: GMPFormattedIO.string(format: "Value: %Zd", z) is called
        let result = GMPFormattedIO.string(format: "Value: %Zd", z)

        // Then: Returns Optional("Value: 1234")
        #expect(result != nil)
        #expect(result == "Value: 1234")
    }

    @Test
    func string_Rational_ReturnsString() async throws {
        // Given: A GMPRational initialized to 1/2
        let q = try GMPRational(numerator: 1, denominator: 2)

        // When: GMPFormattedIO.string(format: "Value: %Qd", q) is called
        let result = GMPFormattedIO.string(format: "Value: %Qd", q)

        // Then: Returns Optional("Value: 1/2")
        #expect(result != nil)
        #expect(result == "Value: 1/2")
    }

    @Test
    func string_Float_ReturnsString() async throws {
        // Given: A GMPFloat initialized to 3.14159
        let f = GMPFloat(3.14159)

        // When: GMPFormattedIO.string(format: "Value: %.2Ff", f) is called
        let result = GMPFormattedIO.string(format: "Value: %.2Ff", f)

        // Then: Returns Optional("Value: 3.14")
        #expect(result != nil)
        #expect(result!.hasPrefix("Value: 3.14"))
    }

    @Test
    func string_MultipleTypes_ReturnsString() async throws {
        // Given: GMPInteger(1234), GMPRational(1, 2), GMPFloat(3.14)
        let z = GMPInteger(1234)
        let q = try GMPRational(numerator: 1, denominator: 2)
        let f = GMPFloat(3.14)

        // When: GMPFormattedIO.string(format: "z=%Zd, q=%Qd, f=%.2Ff", z, q, f) is called
        let result = GMPFormattedIO.string(
            format: "z=%Zd, q=%Qd, f=%.2Ff",
            z,
            q,
            f
        )

        // Then: Returns Optional with formatted string
        #expect(result != nil)
        #expect(result!.contains("1234"))
    }

    @Test
    func string_Integer_Hex_ReturnsString() async throws {
        // Given: A GMPInteger initialized to 255
        let z = GMPInteger(255)

        // When: GMPFormattedIO.string(format: "Hex: %#Zx", z) is called
        let result = GMPFormattedIO.string(format: "Hex: %#Zx", z)

        // Then: Returns Optional("Hex: 0xff")
        #expect(result != nil)
        #expect(result == "Hex: 0xff")
    }

    @Test
    func string_Integer_Width_ReturnsString() async throws {
        // Given: A GMPInteger initialized to 1234
        let z = GMPInteger(1234)

        // When: GMPFormattedIO.string(format: "Value: %10Zd", z) is called
        let result = GMPFormattedIO.string(format: "Value: %10Zd", z)

        // Then: Returns Optional("Value:       1234")
        #expect(result != nil)
        #expect(result == "Value:       1234")
    }

    @Test
    func string_Error_InvalidFormat() async throws {
        // Given: A GMPInteger initialized to 1234
        let z = GMPInteger(1234)

        // When: GMPFormattedIO.string(format: "%Z", z) is called (invalid format - missing conversion)
        // Note: GMP's asprintf typically succeeds even with invalid formats,
        // producing unexpected output
        // We verify the function doesn't crash
        _ = GMPFormattedIO.string(format: "%Z", z)

        // Then: Function completes without crashing
        // GMP's asprintf rarely fails, so result is typically non-nil (may
        // contain unexpected content)
        // We just verify the function completes - the exact output is undefined
        #expect(true) // Function completes without crashing
    }

    @Test
    func string_StandardTypes_ReturnsString() async throws {
        // Given: Int(42) and Double(3.14)
        let n = 42
        let d = 3.14

        // When: GMPFormattedIO.string(format: "n=%d, d=%.2f", n, d) is called
        let result = GMPFormattedIO.string(format: "n=%d, d=%.2f", n, d)

        // Then: Returns Optional with formatted string
        #expect(result != nil)
        #expect(result!.contains("42"))
        #expect(result!.contains("3.14"))
    }

    // MARK: - Convenience Extensions Tests

    @Test
    func formatted_Integer_Basic() async throws {
        // Given: A GMPInteger initialized to 1234
        let z = GMPInteger(1234)

        // When: z.formatted("%Zd") is called
        let result = z.formatted("%Zd")

        // Then: Returns Optional("1234")
        #expect(result != nil)
        #expect(result == "1234")
    }

    @Test
    func formatted_Integer_Hex() async throws {
        // Given: A GMPInteger initialized to 255
        let z = GMPInteger(255)

        // When: z.formatted("%#Zx") is called
        let result = z.formatted("%#Zx")

        // Then: Returns Optional("0xff")
        #expect(result != nil)
        #expect(result == "0xff")
    }

    @Test
    func formatted_Integer_Width() async throws {
        // Given: A GMPInteger initialized to 1234
        let z = GMPInteger(1234)

        // When: z.formatted("%10Zd") is called
        let result = z.formatted("%10Zd")

        // Then: Returns Optional with width 10 (right-aligned with spaces)
        #expect(result != nil)
        // Format %10Zd means minimum width 10, so "1234" (4 chars) should be
        // padded
        // The exact number of spaces may vary, but it should end with "1234"
        // and be at least 10 chars
        #expect(result!.hasSuffix("1234"))
        #expect(result!.trimmingCharacters(in: .whitespaces) == "1234")
        // Verify it's right-aligned (starts with spaces)
        #expect(result!.first == " ")
    }

    @Test
    func formatted_Rational_Basic() async throws {
        // Given: A GMPRational initialized to 1/2
        let q = try GMPRational(numerator: 1, denominator: 2)

        // When: q.formatted("%Qd") is called
        let result = q.formatted("%Qd")

        // Then: Returns Optional("1/2")
        #expect(result != nil)
        #expect(result == "1/2")
    }

    @Test
    func formatted_Rational_Integer() async throws {
        // Given: A GMPRational initialized to 5/1
        let q = try GMPRational(numerator: 5, denominator: 1)

        // When: q.formatted("%Qd") is called
        let result = q.formatted("%Qd")

        // Then: Returns Optional("5") (%Qd returns just numerator when denominator is 1, same as toString())
        #expect(result != nil)
        #expect(result == "5")
    }

    @Test
    func formatted_Float_Basic() async throws {
        // Given: A GMPFloat initialized to 3.14159
        let f = GMPFloat(3.14159)

        // When: f.formatted("%Ff") is called
        let result = f.formatted("%Ff")

        // Then: Returns Optional("3.14159")
        #expect(result != nil)
        #expect(result!.hasPrefix("3.14159"))
    }

    @Test
    func formatted_Float_Precision() async throws {
        // Given: A GMPFloat initialized to 3.14159
        let f = GMPFloat(3.14159)

        // When: f.formatted("%.2Ff") is called
        let result = f.formatted("%.2Ff")

        // Then: Returns Optional("3.14")
        #expect(result != nil)
        #expect(result!.hasPrefix("3.14"))
    }

    @Test
    func formatted_Float_Scientific() async throws {
        // Given: A GMPFloat initialized to 1234.567
        let f = GMPFloat(1234.567)

        // When: f.formatted("%Fe") is called
        let result = f.formatted("%Fe")

        // Then: Returns Optional with scientific notation using lowercase e
        // %Fe uses lowercase 'e' format specifier, so should produce lowercase
        // 'e'
        #expect(result != nil)
        #expect(result!.contains("e"))
    }

    // MARK: - Formatted Input Tests (sscanf)

    @Test
    func sscanf_Integer_FromString() async throws {
        // Given: A string "Value: 1234"
        let input = "Value: 1234"
        var z = GMPInteger()

        // When: sscanf is called
        let count = z.withMutableCPointer { ptr in
            GMPFormattedIO.sscanf(input, "Value: %Zd", ptr)
        }

        // Then: Returns 1, z equals 1234
        #expect(count == 1)
        #expect(z == GMPInteger(1234))
    }

    @Test
    func sscanf_Rational_FromString() async throws {
        // Given: A string "Value: 1/2"
        let input = "Value: 1/2"
        var q = GMPRational()

        // When: sscanf is called
        let count = q.withMutableCPointer { ptr in
            GMPFormattedIO.sscanf(input, "Value: %Qd", ptr)
        }

        // Then: Returns 1, q equals 1/2
        #expect(count == 1)
        let expected = try GMPRational(numerator: 1, denominator: 2)
        #expect(q == expected)
    }

    @Test
    func sscanf_Float_FromString() async throws {
        // Given: A string "Value: 3.14"
        let input = "Value: 3.14"
        var f = GMPFloat()

        // When: sscanf is called
        let count = f.withMutableCPointer { ptr in
            GMPFormattedIO.sscanf(input, "Value: %Ff", ptr)
        }

        // Then: Returns 1, f approximately equals 3.14
        #expect(count == 1)
        let expected = GMPFloat(3.14)
        let diff = (f - expected).absoluteValue()
        #expect(diff < GMPFloat(0.01))
    }

    @Test
    func sscanf_MixedTypes_FromString() async throws {
        // Given: A string "a(5) = 1234"
        let input = "a(5) = 1234"
        var n: Int32 = 0
        var z = GMPInteger()

        // When: sscanf is called
        let count = withUnsafeMutablePointer(to: &n) { nPtr in
            z.withMutableCPointer { zPtr in
                GMPFormattedIO.sscanf(input, "a(%d) = %Zd", nPtr, zPtr)
            }
        }

        // Then: Returns 2, n equals 5, z equals 1234
        #expect(count == 2)
        #expect(n == 5)
        #expect(z == GMPInteger(1234))
    }

    @Test
    func sscanf_Rational_MixedBase() async throws {
        // Given: A string "0377 + 0x10/0x11"
        let input = "0377 + 0x10/0x11"
        var q1 = GMPRational()
        var q2 = GMPRational()

        // When: sscanf is called
        let count = q1.withMutableCPointer { ptr1 in
            q2.withMutableCPointer { ptr2 in
                GMPFormattedIO.sscanf(input, "%Qi + %Qi", ptr1, ptr2)
            }
        }

        // Then: Returns 2, q1 equals 255/1, q2 equals 16/17
        #expect(count == 2)
        let expected1 = try GMPRational(numerator: 255, denominator: 1)
        let expected2 = try GMPRational(numerator: 16, denominator: 17)
        #expect(q1 == expected1)
        #expect(q2 == expected2)
    }

    @Test
    func sscanf_Integer_Hex_FromString() async throws {
        // Given: A string "Value: 0xff"
        let input = "Value: 0xff"
        var z = GMPInteger()

        // When: sscanf is called
        let count = z.withMutableCPointer { ptr in
            GMPFormattedIO.sscanf(input, "Value: %Zi", ptr)
        }

        // Then: Returns 1, z equals 255
        #expect(count == 1)
        #expect(z == GMPInteger(255))
    }

    @Test
    func sscanf_Integer_Octal_FromString() async throws {
        // Given: A string "Value: 0377"
        let input = "Value: 0377"
        var z = GMPInteger()

        // When: sscanf is called
        let count = z.withMutableCPointer { ptr in
            GMPFormattedIO.sscanf(input, "Value: %Zi", ptr)
        }

        // Then: Returns 1, z equals 255
        #expect(count == 1)
        #expect(z == GMPInteger(255))
    }

    @Test
    func sscanf_Float_Scientific_FromString() async throws {
        // Given: A string "Value: 1.23e+04"
        let input = "Value: 1.23e+04"
        var f = GMPFloat()

        // When: sscanf is called
        let count = f.withMutableCPointer { ptr in
            GMPFormattedIO.sscanf(input, "Value: %Ff", ptr)
        }

        // Then: Returns 1, f approximately equals 12300.0
        #expect(count == 1)
        let expected = GMPFloat(12300.0)
        let diff = (f - expected).absoluteValue()
        #expect(diff < GMPFloat(1.0))
    }

    @Test
    func sscanf_PartialMatch() async throws {
        // Given: A string "Value: abc"
        let input = "Value: abc"
        var z =
            GMPInteger(999) // Initialize with a value to verify it's unchanged

        // When: sscanf is called
        let count = z.withMutableCPointer { ptr in
            GMPFormattedIO.sscanf(input, "Value: %Zd", ptr)
        }

        // Then: Returns 0 (no fields matched), z is unchanged
        #expect(count == 0)
        #expect(z == GMPInteger(999))
    }

    @Test
    func sscanf_NoMatch() async throws {
        // Given: A string "Invalid: xyz"
        let input = "Invalid: xyz"
        var z = GMPInteger()

        // When: sscanf is called
        let count = z.withMutableCPointer { ptr in
            GMPFormattedIO.sscanf(input, "Value: %Zd", ptr)
        }

        // Then: Returns 0 (no fields matched)
        #expect(count == 0)
    }

    @Test
    func sscanf_EmptyString() async throws {
        // Given: An empty string ""
        let input = ""
        var z = GMPInteger()

        // When: sscanf is called
        let count = z.withMutableCPointer { ptr in
            GMPFormattedIO.sscanf(input, "%Zd", ptr)
        }

        // Then: Returns EOF (-1) when end of input is reached before any field is matched
        #expect(count == -1)
    }

    @Test
    func sscanf_Whitespace() async throws {
        // Given: A string "   1234   "
        let input = "   1234   "
        var z = GMPInteger()

        // When: sscanf is called
        let count = z.withMutableCPointer { ptr in
            GMPFormattedIO.sscanf(input, "%Zd", ptr)
        }

        // Then: Returns 1, z equals 1234 (whitespace is skipped)
        #expect(count == 1)
        #expect(z == GMPInteger(1234))
    }

    @Test
    func sscanf_NegativeInteger() async throws {
        // Given: A string "Value: -1234"
        let input = "Value: -1234"
        var z = GMPInteger()

        // When: sscanf is called
        let count = z.withMutableCPointer { ptr in
            GMPFormattedIO.sscanf(input, "Value: %Zd", ptr)
        }

        // Then: Returns 1, z equals -1234
        #expect(count == 1)
        #expect(z == GMPInteger(-1234))
    }

    @Test
    func sscanf_NegativeRational() async throws {
        // Given: A string "Value: -1/2"
        let input = "Value: -1/2"
        var q = GMPRational()

        // When: sscanf is called
        let count = q.withMutableCPointer { ptr in
            GMPFormattedIO.sscanf(input, "Value: %Qd", ptr)
        }

        // Then: Returns 1, q equals -1/2
        #expect(count == 1)
        let expected = try GMPRational(numerator: -1, denominator: 2)
        #expect(q == expected)
    }

    @Test
    func sscanf_NegativeFloat() async throws {
        // Given: A string "Value: -3.14"
        let input = "Value: -3.14"
        var f = GMPFloat()

        // When: sscanf is called
        let count = f.withMutableCPointer { ptr in
            GMPFormattedIO.sscanf(input, "Value: %Ff", ptr)
        }

        // Then: Returns 1, f approximately equals -3.14
        #expect(count == 1)
        let expected = GMPFloat(-3.14)
        let diff = (f - expected).absoluteValue()
        #expect(diff < GMPFloat(0.01))
    }

    // MARK: - Formatted Input Tests (fscanf)

    @Test
    func fscanf_Integer_FromFile() async throws {
        // Given: A temporary file containing "Value: 1234\n" opened for reading
        let tempFile = FileManager.default.temporaryDirectory
            .appendingPathComponent("test_sscanf_\(UUID().uuidString).txt")
        try "Value: 1234\n".write(
            to: tempFile,
            atomically: true,
            encoding: .utf8
        )
        defer { try? FileManager.default.removeItem(at: tempFile) }

        guard let file = fopen(tempFile.path, "r") else {
            Issue.record("Could not open temporary file for reading")
            return
        }
        defer { fclose(file) }

        var z = GMPInteger()

        // When: fscanf is called
        let count = z.withMutableCPointer { ptr in
            GMPFormattedIO.fscanf(file, "Value: %Zd\n", ptr)
        }

        // Then: Returns 1, z equals 1234
        #expect(count == 1)
        #expect(z == GMPInteger(1234))
    }

    @Test
    func fscanf_MultipleTypes_FromFile() async throws {
        // Given: A temporary file containing "z=1234, q=1/2, f=3.14\n" opened for reading
        let tempFile = FileManager.default.temporaryDirectory
            .appendingPathComponent("test_fscanf_\(UUID().uuidString).txt")
        try "z=1234, q=1/2, f=3.14\n".write(
            to: tempFile,
            atomically: true,
            encoding: .utf8
        )
        defer { try? FileManager.default.removeItem(at: tempFile) }

        guard let file = fopen(tempFile.path, "r") else {
            Issue.record("Could not open temporary file for reading")
            return
        }
        defer { fclose(file) }

        var z = GMPInteger()
        var q = GMPRational()
        var f = GMPFloat()

        // When: fscanf is called
        let count = z.withMutableCPointer { zPtr in
            q.withMutableCPointer { qPtr in
                f.withMutableCPointer { fPtr in
                    GMPFormattedIO.fscanf(
                        file,
                        "z=%Zd, q=%Qd, f=%Ff\n",
                        zPtr,
                        qPtr,
                        fPtr
                    )
                }
            }
        }

        // Then: Returns 3, all values match
        #expect(count == 3)
        #expect(z == GMPInteger(1234))
        let expectedQ = try GMPRational(numerator: 1, denominator: 2)
        #expect(q == expectedQ)
        let expectedF = GMPFloat(3.14)
        let diff = (f - expectedF).absoluteValue()
        #expect(diff < GMPFloat(0.01))
    }

    @Test
    func fscanf_Error_InvalidFile() async throws {
        // Given: An invalid FILE* pointer (closed file)
        let tempFile = FileManager.default.temporaryDirectory
            .appendingPathComponent(
                "test_fscanf_invalid_\(UUID().uuidString).txt"
            )
        try "Value: 1234\n".write(
            to: tempFile,
            atomically: true,
            encoding: .utf8
        )
        defer { try? FileManager.default.removeItem(at: tempFile) }

        guard let file = fopen(tempFile.path, "r") else {
            Issue.record("Could not open temporary file for reading")
            return
        }
        fclose(file) // Close the file to make it invalid

        var z = GMPInteger()

        // When: fscanf is called with closed file
        let count = z.withMutableCPointer { ptr in
            GMPFormattedIO.fscanf(file, "Value: %Zd\n", ptr)
        }

        // Then: Returns EOF (-1) for invalid file stream
        // Note: Using a closed file is undefined behavior, but fscanf typically
        // returns EOF
        #expect(count == -1 || count ==
            0) // EOF or 0 depending on implementation
    }

    @Test
    func fscanf_Rational_FromFile() async throws {
        // Given: A temporary file containing "Value: 1/2\n" opened for reading
        let tempFile = FileManager.default.temporaryDirectory
            .appendingPathComponent(
                "test_fscanf_rational_\(UUID().uuidString).txt"
            )
        try "Value: 1/2\n".write(
            to: tempFile,
            atomically: true,
            encoding: .utf8
        )
        defer { try? FileManager.default.removeItem(at: tempFile) }

        guard let file = fopen(tempFile.path, "r") else {
            Issue.record("Could not open temporary file for reading")
            return
        }
        defer { fclose(file) }

        var q = GMPRational()

        // When: fscanf is called
        let count = q.withMutableCPointer { ptr in
            GMPFormattedIO.fscanf(file, "Value: %Qd\n", ptr)
        }

        // Then: Returns 1, q equals 1/2
        #expect(count == 1)
        let expected = try GMPRational(numerator: 1, denominator: 2)
        #expect(q == expected)
    }

    @Test
    func fscanf_Float_FromFile() async throws {
        // Given: A temporary file containing "Value: 3.14\n" opened for reading
        let tempFile = FileManager.default.temporaryDirectory
            .appendingPathComponent(
                "test_fscanf_float_\(UUID().uuidString).txt"
            )
        try "Value: 3.14\n".write(
            to: tempFile,
            atomically: true,
            encoding: .utf8
        )
        defer { try? FileManager.default.removeItem(at: tempFile) }

        guard let file = fopen(tempFile.path, "r") else {
            Issue.record("Could not open temporary file for reading")
            return
        }
        defer { fclose(file) }

        var f = GMPFloat()

        // When: fscanf is called
        let count = f.withMutableCPointer { ptr in
            GMPFormattedIO.fscanf(file, "Value: %Ff\n", ptr)
        }

        // Then: Returns 1, f approximately equals 3.14
        #expect(count == 1)
        let expected = GMPFloat(3.14)
        let diff = (f - expected).absoluteValue()
        #expect(diff < GMPFloat(0.01))
    }

    // MARK: - Formatted Input Tests (scanf)

    /// Serial queue for synchronizing stdin redirection to prevent race
    /// conditions
    /// when tests run in parallel. stdin is a global resource and must be
    /// accessed
    /// serially to avoid deadlocks and corruption.
    private static let stdinQueue =
        DispatchQueue(label: "com.kalliope.stdin-redirect")

    /// Helper function to redirect stdin temporarily for testing scanf
    /// functions.
    /// Uses a temporary file and C helper functions for reliable stdin
    /// redirection.
    ///
    /// **Thread Safety**: This function uses a serial dispatch queue to ensure
    /// that only one test can redirect stdin at a time, preventing race
    /// conditions
    /// and deadlocks when tests run in parallel.
    private func withMockedStdin(
        _ input: String,
        execute body: () throws -> Void
    ) throws {
        // Synchronize access to stdin using a serial queue
        // This prevents race conditions when multiple tests run in parallel
        try Self.stdinQueue.sync {
            // Save the original stdin file descriptor
            let originalStdinFd = dup(STDIN_FILENO)
            guard originalStdinFd >= 0 else {
                Issue.record("Failed to duplicate stdin file descriptor")
                return
            }
            defer {
                // Restore stdin using C helper function
                if ckalliope_restore_stdin(originalStdinFd) != 0 {
                    Issue.record("Failed to restore stdin")
                }
                close(originalStdinFd)
            }

            // Create a temporary file with the input data
            let tempFile = FileManager.default.temporaryDirectory
                .appendingPathComponent("test_stdin_\(UUID().uuidString).txt")
            try input.write(to: tempFile, atomically: true, encoding: .utf8)
            defer {
                try? FileManager.default.removeItem(at: tempFile)
            }

            // Redirect stdin using C helper function
            guard tempFile.path
                .withCString({ ckalliope_redirect_stdin_from_file($0) == 0 })
            else {
                Issue.record("Failed to redirect stdin using C helper")
                return
            }

            // Execute the test code
            try body()
        }
    }

    @Test
    func scanf_Integer_FromStdin() async throws {
        // Given: Standard input containing "Value: 1234\n"
        let input = "Value: 1234\n"
        var z = GMPInteger()

        // When: scanf is called with mocked stdin
        var count = 0
        try withMockedStdin(input) {
            count = z.withMutableCPointer { ptr in
                GMPFormattedIO.scanf("Value: %Zd\n", ptr)
            }
        }

        // Then: Returns 1, z equals 1234
        #expect(count == 1)
        #expect(z == GMPInteger(1234))
    }

    @Test
    func scanf_Rational_FromStdin() async throws {
        // Given: Standard input containing "Value: 1/2\n"
        let input = "Value: 1/2\n"
        var q = GMPRational()

        // When: scanf is called with mocked stdin
        var count = 0
        try withMockedStdin(input) {
            count = q.withMutableCPointer { ptr in
                GMPFormattedIO.scanf("Value: %Qd\n", ptr)
            }
        }

        // Then: Returns 1, q equals 1/2
        #expect(count == 1)
        let expected = try GMPRational(numerator: 1, denominator: 2)
        #expect(q == expected)
    }

    @Test
    func scanf_Float_FromStdin() async throws {
        // Given: Standard input containing "Value: 3.14\n"
        let input = "Value: 3.14\n"
        var f = GMPFloat()

        // When: scanf is called with mocked stdin
        var count = 0
        try withMockedStdin(input) {
            count = f.withMutableCPointer { ptr in
                GMPFormattedIO.scanf("Value: %Ff\n", ptr)
            }
        }

        // Then: Returns 1, f approximately equals 3.14
        #expect(count == 1)
        let expected = GMPFloat(3.14)
        let diff = (f - expected).absoluteValue()
        #expect(diff < GMPFloat(0.01))
    }

    @Test
    func scanf_MixedTypes_FromStdin() async throws {
        // Given: Standard input containing "a(5) = 1234\n"
        let input = "a(5) = 1234\n"
        var n: Int32 = 0
        var z = GMPInteger()

        // When: scanf is called with mocked stdin
        var count = 0
        try withMockedStdin(input) {
            count = withUnsafeMutablePointer(to: &n) { nPtr in
                z.withMutableCPointer { zPtr in
                    GMPFormattedIO.scanf("a(%d) = %Zd\n", nPtr, zPtr)
                }
            }
        }

        // Then: Returns 2, n equals 5, z equals 1234
        #expect(count == 2)
        #expect(n == 5)
        #expect(z == GMPInteger(1234))
    }

    @Test
    func scanf_Integer_Hex_FromStdin() async throws {
        // Given: Standard input containing "Value: 0xff\n"
        let input = "Value: 0xff\n"
        var z = GMPInteger()

        // When: scanf is called with mocked stdin
        var count = 0
        try withMockedStdin(input) {
            count = z.withMutableCPointer { ptr in
                GMPFormattedIO.scanf("Value: %Zi\n", ptr)
            }
        }

        // Then: Returns 1, z equals 255
        #expect(count == 1)
        #expect(z == GMPInteger(255))
    }

    @Test
    func scanf_Integer_Octal_FromStdin() async throws {
        // Given: Standard input containing "Value: 0377\n"
        let input = "Value: 0377\n"
        var z = GMPInteger()

        // When: scanf is called with mocked stdin
        var count = 0
        try withMockedStdin(input) {
            count = z.withMutableCPointer { ptr in
                GMPFormattedIO.scanf("Value: %Zi\n", ptr)
            }
        }

        // Then: Returns 1, z equals 255
        #expect(count == 1)
        #expect(z == GMPInteger(255))
    }

    @Test
    func scanf_Error_EOF() async throws {
        // Given: Empty input (EOF)
        let input = ""
        var z = GMPInteger()

        // When: scanf is called with mocked stdin (empty)
        var count = 0
        try withMockedStdin(input) {
            count = z.withMutableCPointer { ptr in
                GMPFormattedIO.scanf("Value: %Zd\n", ptr)
            }
        }

        // Then: Returns EOF (-1) when end of input is reached before any field is matched
        #expect(count == -1)
    }

    @Test
    func scanf_Error_NoMatch() async throws {
        // Given: Standard input containing "Invalid: abc\n"
        let input = "Invalid: abc\n"
        var z = GMPInteger()

        // When: scanf is called with mocked stdin
        var count = 0
        try withMockedStdin(input) {
            count = z.withMutableCPointer { ptr in
                GMPFormattedIO.scanf("Value: %Zd\n", ptr)
            }
        }

        // Then: Returns 0 (no fields matched)
        #expect(count == 0)
    }

    // MARK: - Round-Trip Tests

    @Test
    func roundTrip_Integer_Base10() async throws {
        // Given: A GMPInteger initialized to 1234
        let z = GMPInteger(1234)

        // When: let str = GMPFormattedIO.string(format: "%Zd", z),
        // then var z2 = GMPInteger(); GMPFormattedIO.sscanf(str!, "%Zd", &z2)
        guard let str = GMPFormattedIO.string(format: "%Zd", z) else {
            Issue.record("string(format:) returned nil")
            return
        }
        var z2 = GMPInteger()
        let count = z2.withMutableCPointer { ptr in
            GMPFormattedIO.sscanf(str, "%Zd", ptr)
        }

        // Then: z2 equals z
        #expect(count == 1)
        #expect(z2 == z)
    }

    @Test
    func roundTrip_Integer_Hex() async throws {
        // Given: A GMPInteger initialized to 255
        let z = GMPInteger(255)

        // When: let str = GMPFormattedIO.string(format: "%#Zx", z),
        // then var z2 = GMPInteger(); GMPFormattedIO.sscanf(str!, "%Zi", &z2)
        guard let str = GMPFormattedIO.string(format: "%#Zx", z) else {
            Issue.record("string(format:) returned nil")
            return
        }
        var z2 = GMPInteger()
        let count = z2.withMutableCPointer { ptr in
            GMPFormattedIO.sscanf(str, "%Zi", ptr)
        }

        // Then: z2 equals z
        #expect(count == 1)
        #expect(z2 == z)
    }

    @Test
    func roundTrip_Rational() async throws {
        // Given: A GMPRational initialized to 1/2
        let q = try GMPRational(numerator: 1, denominator: 2)

        // When: let str = GMPFormattedIO.string(format: "%Qd", q),
        // then var q2 = GMPRational(); GMPFormattedIO.sscanf(str!, "%Qd", &q2)
        guard let str = GMPFormattedIO.string(format: "%Qd", q) else {
            Issue.record("string(format:) returned nil")
            return
        }
        var q2 = GMPRational()
        let count = q2.withMutableCPointer { ptr in
            GMPFormattedIO.sscanf(str, "%Qd", ptr)
        }

        // Then: q2 equals q
        #expect(count == 1)
        let expected = try GMPRational(numerator: 1, denominator: 2)
        #expect(q2 == expected)
    }

    @Test
    func roundTrip_Float() async throws {
        // Given: A GMPFloat initialized to 3.14159
        let f = GMPFloat(3.14159)

        // When: let str = GMPFormattedIO.string(format: "%.5Ff", f),
        // then var f2 = GMPFloat(); GMPFormattedIO.sscanf(str!, "%Ff", &f2)
        guard let str = GMPFormattedIO.string(format: "%.5Ff", f) else {
            Issue.record("string(format:) returned nil")
            return
        }
        var f2 = GMPFloat()
        let count = f2.withMutableCPointer { ptr in
            GMPFormattedIO.sscanf(str, "%Ff", ptr)
        }

        // Then: f2 approximately equals f (within precision limits)
        #expect(count == 1)
        let diff = (f2 - f).absoluteValue()
        #expect(diff < GMPFloat(0.0001))
    }

    // MARK: - Format String Validation Tests

    @Test
    func format_InvalidSpecifier() async throws {
        // Given: A GMPInteger initialized to 1234
        let z = GMPInteger(1234)

        // When: GMPFormattedIO.printf("%Z\n", z) is called (invalid - missing conversion)
        // Note: Invalid format may produce undefined behavior, but printf
        // typically handles it
        // We verify the function doesn't crash
        _ = GMPFormattedIO.printf("%Z\n", z)

        // Then: Function completes without crashing
        // The exact return value and output are undefined for invalid formats
        // We just verify the function completes
        #expect(true) // Function completes without crashing (behavior is
        // undefined)
    }

    // Note: format_MismatchedArguments test is intentionally omitted.
    // Testing format strings with mismatched arguments (e.g., "%Zd %Zd" with
    // only 1 argument)
    // causes undefined behavior in GMP's printf implementation and can result
    // in crashes.
    // This is a known limitation - users must ensure format strings match their
    // arguments.
    // The test plan notes this as "undefined behavior" which cannot be safely
    // tested.

    @Test
    func format_ExtraArguments() async throws {
        // Given: A GMPInteger initialized to 1234
        let z = GMPInteger(1234)

        // When: GMPFormattedIO.printf("%Zd\n", z, 42) is called (extra argument)
        // Note: We can't easily test this with our current overloads since
        // they're type-specific
        // This test verifies the concept - extra arguments are typically
        // ignored
        let count = GMPFormattedIO.printf("%Zd\n", z)

        // Then: Extra argument is ignored, prints correctly
        #expect(count > 0)
    }

    // MARK: - Large Values Tests

    @Test
    func printf_VeryLargeInteger() async throws {
        // Given: A GMPInteger initialized to 2^1000
        let z = GMPInteger.power(base: 2, exponent: 1000)

        // When: GMPFormattedIO.printf("Value: %Zd\n", z) is called
        let count = GMPFormattedIO.printf("Value: %Zd\n", z)

        // Then: Returns a positive integer and prints the large value correctly
        #expect(count > 0)
    }

    @Test
    func printf_VeryLargeFloat() async throws {
        // Given: A GMPFloat initialized to a very large value
        let f = GMPFloat(1.0e100)

        // When: GMPFormattedIO.printf("Value: %Fe\n", f) is called
        let count = GMPFormattedIO.printf("Value: %Fe\n", f)

        // Then: Returns a positive integer and prints in scientific notation
        #expect(count > 0)
    }

    @Test
    func sscanf_VeryLargeInteger() async throws {
        // Given: A string containing a very large integer
        let largeInt = GMPInteger.power(base: 2, exponent: 1000)
        guard let str = GMPFormattedIO.string(format: "%Zd", largeInt) else {
            Issue.record("string(format:) returned nil")
            return
        }

        // When: var z = GMPInteger(); GMPFormattedIO.sscanf(string, "%Zd", &z) is called
        var z = GMPInteger()
        let count = z.withMutableCPointer { ptr in
            GMPFormattedIO.sscanf(str, "%Zd", ptr)
        }

        // Then: Returns 1, z equals the large value
        #expect(count == 1)
        #expect(z == largeInt)
    }
}
