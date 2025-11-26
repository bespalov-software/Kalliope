import Foundation
@testable import Kalliope
import Testing

// MARK: - String-based I/O Tests

struct GMPRationalStringIOTests {
    // MARK: - writeToString(base:) Tests

    @Test
    func writeToString_Zero_DefaultBase_ReturnsZeroString() async throws {
        // Given: A GMPRational with value 0/1, base = 10 (default)
        let rational = GMPRational()

        // When: Call writeToString()
        let result = rational.writeToString()

        // Then: Returns "0" (GMP returns just numerator when denominator is 1)
        #expect(result == "0")
    }

    @Test
    func writeToString_PositiveInteger_DefaultBase_ReturnsCorrectString(
    ) async throws {
        // Given: A GMPRational with value 42/1, base = 10 (default)
        let rational = try GMPRational(
            numerator: GMPInteger(42),
            denominator: GMPInteger(1)
        )

        // When: Call writeToString()
        let result = rational.writeToString()

        // Then: Returns "42" (GMP returns just numerator when denominator is 1)
        #expect(result == "42")
    }

    @Test
    func writeToString_SimpleFraction_DefaultBase_ReturnsCorrectString(
    ) async throws {
        // Given: A GMPRational with value 1/2, base = 10 (default)
        let rational = try GMPRational(
            numerator: GMPInteger(1),
            denominator: GMPInteger(2)
        )

        // When: Call writeToString()
        let result = rational.writeToString()

        // Then: Returns "1/2"
        #expect(result == "1/2")
    }

    @Test
    func writeToString_BinaryBase_ReturnsBinaryString() async throws {
        // Given: A GMPRational with value 5/3, base = 2
        let rational = try GMPRational(
            numerator: GMPInteger(5),
            denominator: GMPInteger(3)
        )

        // When: Call writeToString(base: 2)
        let result = rational.writeToString(base: 2)

        // Then: Returns binary representation "101/11"
        #expect(result == "101/11")
    }

    @Test
    func writeToString_HexadecimalBase_ReturnsHexString() async throws {
        // Given: A GMPRational with value 255/16, base = 16
        let rational = try GMPRational(
            numerator: GMPInteger(255),
            denominator: GMPInteger(16)
        )

        // When: Call writeToString(base: 16)
        let result = rational.writeToString(base: 16)

        // Then: Returns hexadecimal representation
        #expect(result == "ff/10")
    }

    @Test
    func writeToString_Base62_ReturnsBase62String() async throws {
        // Given: A GMPRational with value 61/1, base = 62
        let rational = try GMPRational(
            numerator: GMPInteger(61),
            denominator: GMPInteger(1)
        )

        // When: Call writeToString(base: 62)
        let result = rational.writeToString(base: 62)

        // Then: Returns base 62 representation
        #expect(result == "z")
    }

    @Test
    func writeToString_RoundTrip_PreservesValue() async throws {
        // Given: A GMPRational with value 123/456, base = 10
        let original = try GMPRational(
            numerator: GMPInteger(123),
            denominator: GMPInteger(456)
        )

        // When: Call writeToString(base: 10) then parse the result with init(string:base:)
        let string = original.writeToString(base: 10)
        let parsed = GMPRational(string: string, base: 10)

        // Then: The parsed value equals the original value
        #expect(parsed != nil)
        #expect(parsed! == original)
    }

    // MARK: - init?(string:base:) Tests

    @Test
    func initString_Zero_DefaultBase_ReturnsZero() async throws {
        // Given: String "0", base = 10 (default)
        // When: Create GMPRational(string: "0")
        let rational = GMPRational(string: "0")

        // Then: Returns a GMPRational with value 0/1
        #expect(rational != nil)
        #expect(rational!.numerator.toInt() == 0)
        #expect(rational!.denominator.toInt() == 1)
    }

    @Test
    func initString_PositiveInteger_DefaultBase_ReturnsCorrectValue(
    ) async throws {
        // Given: String "42", base = 10 (default)
        // When: Create GMPRational(string: "42")
        let rational = GMPRational(string: "42")

        // Then: Returns a GMPRational with value 42/1
        #expect(rational != nil)
        #expect(rational!.numerator.toInt() == 42)
        #expect(rational!.denominator.toInt() == 1)
    }

    @Test
    func initString_SimpleFraction_DefaultBase_ReturnsCorrectValue(
    ) async throws {
        // Given: String "1/2", base = 10 (default)
        // When: Create GMPRational(string: "1/2")
        let rational = GMPRational(string: "1/2")

        // Then: Returns a GMPRational with value 1/2 (canonicalized)
        #expect(rational != nil)
        #expect(rational!.numerator.toInt() == 1)
        #expect(rational!.denominator.toInt() == 2)
    }

    @Test
    func initString_BinaryBase_ReturnsCorrectValue() async throws {
        // Given: String "101/11", base = 2
        // When: Create GMPRational(string: "101/11", base: 2)
        let rational = GMPRational(string: "101/11", base: 2)

        // Then: Returns a GMPRational with value 5/3
        #expect(rational != nil)
        #expect(rational!.numerator.toInt() == 5)
        #expect(rational!.denominator.toInt() == 3)
    }

    @Test
    func initString_BaseZero_AutoDetectsDecimal() async throws {
        // Given: String "42", base = 0
        // When: Create GMPRational(string: "42", base: 0)
        let rational = GMPRational(string: "42", base: 0)

        // Then: Returns a GMPRational with value 42/1 (auto-detects base 10)
        #expect(rational != nil)
        #expect(rational!.numerator.toInt() == 42)
        #expect(rational!.denominator.toInt() == 1)
    }

    @Test
    func initString_EmptyString_ReturnsNil() async throws {
        // Given: Empty string "", base = 10 (default)
        // When: Attempt to create GMPRational(string: "")
        let rational = GMPRational(string: "")

        // Then: Returns nil (requires non-empty string)
        #expect(rational == nil)
    }

    @Test
    func initString_InvalidFormat_ReturnsNil() async throws {
        // Given: String "not a number", base = 10 (default)
        // When: Attempt to create GMPRational(string: "not a number")
        let rational = GMPRational(string: "not a number")

        // Then: Returns nil
        #expect(rational == nil)
    }

    @Test
    func initString_ZeroDenominator_ReturnsNil() async throws {
        // Given: String "1/0", base = 10 (default)
        // When: Attempt to create GMPRational(string: "1/0", base: 10)
        let rational = GMPRational(string: "1/0")

        // Then: Returns nil (denominator cannot be zero)
        #expect(rational == nil)
    }
}

// MARK: - FileHandle-based I/O Tests

struct GMPRationalFileHandleIOTests {
    /// Helper function to create a temporary file with content in a thread-safe
    /// manner.
    /// This avoids race conditions with String.write(to:atomically:encoding:)
    /// when
    /// multiple tests run in parallel.
    private static func createTempFile(with content: String) throws -> URL {
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        // Create file first, then write to it using FileHandle for
        // thread-safety
        // This avoids race conditions with
        // String.write(to:atomically:encoding:)
        FileManager.default.createFile(atPath: tempURL.path, contents: nil)
        let writeHandle = try FileHandle(forWritingTo: tempURL)
        defer { try? writeHandle.close() }
        guard let data = content.data(using: .utf8) else {
            throw NSError(
                domain: "GMPRationalIOTests",
                code: 1,
                userInfo: [
                    NSLocalizedDescriptionKey: "Failed to convert string to UTF-8 data",
                ]
            )
        }
        try writeHandle.write(contentsOf: data)
        try writeHandle.synchronize()
        try writeHandle.close()
        return tempURL
    }

    // MARK: - write(to:base:) Tests

    @Test
    func writeToFileHandle_Zero_DefaultBase_WritesCorrectString() async throws {
        // Given: A GMPRational with value 0/1, a FileHandle open for writing, base = 10 (default)
        let rational = GMPRational()
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        FileManager.default.createFile(atPath: tempURL.path, contents: nil)
        let fileHandle = try FileHandle(forWritingTo: tempURL)
        defer {
            try? fileHandle.close()
            try? FileManager.default.removeItem(at: tempURL)
        }

        // When: Call write(to: fileHandle)
        let bytesWritten = rational.write(to: fileHandle)

        // Then: Returns number of bytes written (> 0), and FileHandle contains "0\n"
        #expect(bytesWritten > 0)
        try fileHandle.synchronize()
        try fileHandle.close()

        let readHandle = try FileHandle(forReadingFrom: tempURL)
        defer { try? readHandle.close() }
        let data = readHandle.readDataToEndOfFile()
        let content = String(data: data, encoding: .utf8) ?? ""
        #expect(content == "0\n")
    }

    @Test
    func writeToFileHandle_PositiveInteger_DefaultBase_WritesCorrectString(
    ) async throws {
        // Given: A GMPRational with value 42/1, a FileHandle open for writing, base = 10 (default)
        let rational = try GMPRational(
            numerator: GMPInteger(42),
            denominator: GMPInteger(1)
        )
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        FileManager.default.createFile(atPath: tempURL.path, contents: nil)
        let fileHandle = try FileHandle(forWritingTo: tempURL)
        defer {
            try? fileHandle.close()
            try? FileManager.default.removeItem(at: tempURL)
        }

        // When: Call write(to: fileHandle)
        let bytesWritten = rational.write(to: fileHandle)

        // Then: Returns number of bytes written (> 0), and FileHandle contains "42\n"
        #expect(bytesWritten > 0)
        try fileHandle.synchronize()
        try fileHandle.close()

        let readHandle = try FileHandle(forReadingFrom: tempURL)
        defer { try? readHandle.close() }
        let data = readHandle.readDataToEndOfFile()
        let content = String(data: data, encoding: .utf8) ?? ""
        #expect(content == "42\n")
    }

    @Test
    func writeToFileHandle_SimpleFraction_DefaultBase_WritesCorrectString(
    ) async throws {
        // Given: A GMPRational with value 1/2, a FileHandle open for writing, base = 10 (default)
        let rational = try GMPRational(
            numerator: GMPInteger(1),
            denominator: GMPInteger(2)
        )
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        FileManager.default.createFile(atPath: tempURL.path, contents: nil)
        let fileHandle = try FileHandle(forWritingTo: tempURL)
        defer {
            try? fileHandle.close()
            try? FileManager.default.removeItem(at: tempURL)
        }

        // When: Call write(to: fileHandle)
        let bytesWritten = rational.write(to: fileHandle)

        // Then: Returns number of bytes written (> 0), and FileHandle contains "1/2\n"
        #expect(bytesWritten > 0)
        try fileHandle.synchronize()
        try fileHandle.close()

        let readHandle = try FileHandle(forReadingFrom: tempURL)
        defer { try? readHandle.close() }
        let data = readHandle.readDataToEndOfFile()
        let content = String(data: data, encoding: .utf8) ?? ""
        #expect(content == "1/2\n")
    }

    @Test
    func writeToFileHandle_BinaryBase_WritesBinaryString() async throws {
        // Given: A GMPRational with value 5/3, a FileHandle open for writing, base = 2
        let rational = try GMPRational(
            numerator: GMPInteger(5),
            denominator: GMPInteger(3)
        )
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        FileManager.default.createFile(atPath: tempURL.path, contents: nil)
        let fileHandle = try FileHandle(forWritingTo: tempURL)
        defer {
            try? fileHandle.close()
            try? FileManager.default.removeItem(at: tempURL)
        }

        // When: Call write(to: fileHandle, base: 2)
        let bytesWritten = rational.write(to: fileHandle, base: 2)

        // Then: Returns number of bytes written (> 0), and FileHandle contains binary
        // representation followed by newline
        #expect(bytesWritten > 0)
        try fileHandle.synchronize()
        try fileHandle.close()

        let readHandle = try FileHandle(forReadingFrom: tempURL)
        defer { try? readHandle.close() }
        let data = readHandle.readDataToEndOfFile()
        let content = String(data: data, encoding: .utf8) ?? ""
        #expect(content == "101/11\n")
    }

    @Test
    func writeToFileHandle_HexadecimalBase_WritesHexString() async throws {
        // Given: A GMPRational with value 255/16, a FileHandle open for writing, base = 16
        let rational = try GMPRational(
            numerator: GMPInteger(255),
            denominator: GMPInteger(16)
        )
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        FileManager.default.createFile(atPath: tempURL.path, contents: nil)
        let fileHandle = try FileHandle(forWritingTo: tempURL)
        defer {
            try? fileHandle.close()
            try? FileManager.default.removeItem(at: tempURL)
        }

        // When: Call write(to: fileHandle, base: 16)
        let bytesWritten = rational.write(to: fileHandle, base: 16)

        // Then: Returns number of bytes written (> 0), and FileHandle contains
        // hexadecimal representation followed by newline
        #expect(bytesWritten > 0)
        try fileHandle.synchronize()
        try fileHandle.close()

        let readHandle = try FileHandle(forReadingFrom: tempURL)
        defer { try? readHandle.close() }
        let data = readHandle.readDataToEndOfFile()
        let content = String(data: data, encoding: .utf8) ?? ""
        #expect(content == "ff/10\n")
    }

    @Test
    func writeToFileHandle_Base62_ReturnsCorrectBytes() async throws {
        // Given: A GMPRational with value 61/1, a FileHandle open for writing, base = 62
        let rational = try GMPRational(
            numerator: GMPInteger(61),
            denominator: GMPInteger(1)
        )
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        FileManager.default.createFile(atPath: tempURL.path, contents: nil)
        let fileHandle = try FileHandle(forWritingTo: tempURL)
        defer {
            try? fileHandle.close()
            try? FileManager.default.removeItem(at: tempURL)
        }

        // When: Call write(to: fileHandle, base: 62)
        let bytesWritten = rational.write(to: fileHandle, base: 62)

        // Then: Returns number of bytes written (> 0), and FileHandle contains base 62
        // representation followed by newline
        #expect(bytesWritten > 0)
        try fileHandle.synchronize()
        try fileHandle.close()

        let readHandle = try FileHandle(forReadingFrom: tempURL)
        defer { try? readHandle.close() }
        let data = readHandle.readDataToEndOfFile()
        let content = String(data: data, encoding: .utf8) ?? ""
        #expect(content == "z\n")
    }

    @Test
    func writeToFileHandle_LargeValue_WritesCorrectString() async throws {
        // Given: A GMPRational with a very large value, a FileHandle open for writing, base = 10 (default)
        let largeNum = GMPInteger.power(base: 10, exponent: 100)
        let rational = try GMPRational(
            numerator: largeNum,
            denominator: GMPInteger(1)
        )
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        FileManager.default.createFile(atPath: tempURL.path, contents: nil)
        let fileHandle = try FileHandle(forWritingTo: tempURL)
        defer {
            try? fileHandle.close()
            try? FileManager.default.removeItem(at: tempURL)
        }

        // When: Call write(to: fileHandle)
        let bytesWritten = rational.write(to: fileHandle)

        // Then: Returns number of bytes written (> 0), and FileHandle contains correct representation
        #expect(bytesWritten > 0)
        try fileHandle.synchronize()
        try fileHandle.close()

        let readHandle = try FileHandle(forReadingFrom: tempURL)
        defer { try? readHandle.close() }
        let data = readHandle.readDataToEndOfFile()
        let content = String(data: data, encoding: .utf8) ?? ""
        #expect(!content.isEmpty)
        #expect(content.hasSuffix("\n"))
        // Verify it can be parsed back
        let parsed = GMPRational(string: String(content.dropLast()), base: 10)
        #expect(parsed != nil)
        #expect(parsed! == rational)
    }

    // MARK: - init?(fileHandle:base:) Tests

    @Test
    func initFileHandle_Zero_DefaultBase_ReturnsZero() async throws {
        // Given: A FileHandle open for reading containing "0\n", base = 10 (default)
        let tempURL = try Self.createTempFile(with: "0\n")
        let fileHandle = try FileHandle(forReadingFrom: tempURL)
        defer {
            try? fileHandle.close()
            try? FileManager.default.removeItem(at: tempURL)
        }

        // When: Create GMPRational(fileHandle: fileHandle)
        let rational = GMPRational(fileHandle: fileHandle)

        // Then: Returns a GMPRational with value 0/1
        #expect(rational != nil)
        #expect(rational!.numerator.toInt() == 0)
        #expect(rational!.denominator.toInt() == 1)
    }

    @Test
    func initFileHandle_PositiveInteger_DefaultBase_ReturnsCorrectValue(
    ) async throws {
        // Given: A FileHandle open for reading containing "42\n", base = 10 (default)
        let tempURL = try Self.createTempFile(with: "42\n")
        let fileHandle = try FileHandle(forReadingFrom: tempURL)
        defer {
            try? fileHandle.close()
            try? FileManager.default.removeItem(at: tempURL)
        }

        // When: Create GMPRational(fileHandle: fileHandle)
        let rational = GMPRational(fileHandle: fileHandle)

        // Then: Returns a GMPRational with value 42/1
        #expect(rational != nil)
        #expect(rational!.numerator.toInt() == 42)
        #expect(rational!.denominator.toInt() == 1)
    }

    @Test
    func initFileHandle_SimpleFraction_DefaultBase_ReturnsCorrectValue(
    ) async throws {
        // Given: A FileHandle open for reading containing "1/2\n", base = 10 (default)
        let tempURL = try Self.createTempFile(with: "1/2\n")
        let fileHandle = try FileHandle(forReadingFrom: tempURL)
        defer {
            try? fileHandle.close()
            try? FileManager.default.removeItem(at: tempURL)
        }

        // When: Create GMPRational(fileHandle: fileHandle)
        let rational = GMPRational(fileHandle: fileHandle)

        // Then: Returns a GMPRational with value 1/2 (canonicalized)
        #expect(rational != nil)
        #expect(rational!.numerator.toInt() == 1)
        #expect(rational!.denominator.toInt() == 2)
    }

    @Test
    func initFileHandle_BinaryBase_ReturnsCorrectValue() async throws {
        // Given: A FileHandle open for reading containing "101/11\n", base = 2
        let tempURL = try Self.createTempFile(with: "101/11\n")
        let fileHandle = try FileHandle(forReadingFrom: tempURL)
        defer {
            try? fileHandle.close()
            try? FileManager.default.removeItem(at: tempURL)
        }

        // When: Create GMPRational(fileHandle: fileHandle, base: 2)
        let rational = GMPRational(fileHandle: fileHandle, base: 2)

        // Then: Returns a GMPRational with value 5/3
        #expect(rational != nil)
        #expect(rational!.numerator.toInt() == 5)
        #expect(rational!.denominator.toInt() == 3)
    }

    @Test
    func initFileHandle_BaseZero_AutoDetectsDecimal() async throws {
        // Given: A FileHandle open for reading containing "42\n", base = 0
        let tempURL = try Self.createTempFile(with: "42\n")
        let fileHandle = try FileHandle(forReadingFrom: tempURL)
        defer {
            try? fileHandle.close()
            try? FileManager.default.removeItem(at: tempURL)
        }

        // When: Create GMPRational(fileHandle: fileHandle, base: 0)
        let rational = GMPRational(fileHandle: fileHandle, base: 0)

        // Then: Returns a GMPRational with value 42/1 (auto-detects base 10)
        #expect(rational != nil)
        #expect(rational!.numerator.toInt() == 42)
        #expect(rational!.denominator.toInt() == 1)
    }

    @Test
    func initFileHandle_EmptyFile_ReturnsNil() async throws {
        // Given: A FileHandle open for reading at end of file (empty), base = 10 (default)
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        FileManager.default.createFile(atPath: tempURL.path, contents: nil)
        let fileHandle = try FileHandle(forReadingFrom: tempURL)
        defer {
            try? fileHandle.close()
            try? FileManager.default.removeItem(at: tempURL)
        }

        // When: Attempt to create GMPRational(fileHandle: fileHandle)
        let rational = GMPRational(fileHandle: fileHandle)

        // Then: Returns nil (no data to read)
        #expect(rational == nil)
    }

    @Test
    func initFileHandle_InvalidFormat_ReturnsNil() async throws {
        // Given: A FileHandle open for reading containing "not a number\n", base = 10 (default)
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        try "not a number\n".write(
            to: tempURL,
            atomically: true,
            encoding: .utf8
        )
        let fileHandle = try FileHandle(forReadingFrom: tempURL)
        defer {
            try? fileHandle.close()
            try? FileManager.default.removeItem(at: tempURL)
        }

        // When: Attempt to create GMPRational(fileHandle: fileHandle)
        let rational = GMPRational(fileHandle: fileHandle)

        // Then: Returns nil (parsing failed)
        #expect(rational == nil)
    }

    @Test
    func initFileHandle_ZeroDenominator_ReturnsNil() async throws {
        // Given: A FileHandle open for reading containing "1/0\n", base = 10 (default)
        let tempURL = try Self.createTempFile(with: "1/0\n")
        let fileHandle = try FileHandle(forReadingFrom: tempURL)
        defer {
            try? fileHandle.close()
            try? FileManager.default.removeItem(at: tempURL)
        }

        // When: Attempt to create GMPRational(fileHandle: fileHandle)
        let rational = GMPRational(fileHandle: fileHandle)

        // Then: Returns nil (denominator cannot be zero)
        #expect(rational == nil)
    }

    @Test
    func initFileHandle_NoNewline_ReadsUntilEOF() async throws {
        // Given: A FileHandle open for reading containing "42" (no newline, at EOF), base = 10 (default)
        let tempURL = try Self.createTempFile(with: "42")
        let fileHandle = try FileHandle(forReadingFrom: tempURL)
        defer {
            try? fileHandle.close()
            try? FileManager.default.removeItem(at: tempURL)
        }

        // When: Create GMPRational(fileHandle: fileHandle)
        let rational = GMPRational(fileHandle: fileHandle)

        // Then: Returns a GMPRational with value 42/1 (reads until EOF)
        #expect(rational != nil)
        #expect(rational!.numerator.toInt() == 42)
        #expect(rational!.denominator.toInt() == 1)
    }

    @Test
    func initFileHandle_MultipleLines_ReadsFirstLine() async throws {
        // Given: A FileHandle open for reading containing "42\n100\n", base = 10 (default)
        let tempURL = try Self.createTempFile(with: "42\n100\n")
        let fileHandle = try FileHandle(forReadingFrom: tempURL)
        defer {
            try? fileHandle.close()
            try? FileManager.default.removeItem(at: tempURL)
        }

        // When: Create GMPRational(fileHandle: fileHandle)
        let rational = GMPRational(fileHandle: fileHandle)

        // Then: Returns a GMPRational with value 42/1 (reads first line only)
        #expect(rational != nil)
        #expect(rational!.numerator.toInt() == 42)
        #expect(rational!.denominator.toInt() == 1)
    }

    @Test
    func initFileHandle_WhitespaceOnly_ReturnsNil() async throws {
        // Given: A FileHandle open for reading containing only whitespace "   \n", base = 10 (default)
        let tempURL = try Self.createTempFile(with: "   \n")
        let fileHandle = try FileHandle(forReadingFrom: tempURL)
        defer {
            try? fileHandle.close()
            try? FileManager.default.removeItem(at: tempURL)
        }

        // When: Attempt to create GMPRational(fileHandle: fileHandle)
        let rational = GMPRational(fileHandle: fileHandle)

        // Then: Returns nil (line is empty after trimming whitespace)
        #expect(rational == nil)
    }

    @Test
    func writeToFileHandle_UTF8Encoding_AlwaysSucceeds() async throws {
        // Given: A GMPRational and FileHandle
        // Note: In Swift, String.data(using: .utf8) will never return nil
        // because Swift strings are guaranteed to be valid UTF-8. The error
        // path in
        // write(to:base:) is a defensive programming measure that is untestable in practice.
        let rational = try GMPRational(
            numerator: GMPInteger(42),
            denominator: GMPInteger(1)
        )
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        FileManager.default.createFile(atPath: tempURL.path, contents: nil)
        let fileHandle = try FileHandle(forWritingTo: tempURL)
        defer {
            try? fileHandle.close()
            try? FileManager.default.removeItem(at: tempURL)
        }

        // When: write(to: fileHandle) is called with a valid string
        let bytesWritten = rational.write(to: fileHandle)

        // Then: UTF-8 encoding always succeeds (bytesWritten > 0)
        // This test documents that the UTF-8 encoding failure path (line 69) is
        // untestable because Swift strings are always valid UTF-8.
        #expect(bytesWritten > 0)
    }
}
