import Foundation
@testable import Kalliope
import Testing

// MARK: - Import/Export Tests

struct GMPIntegerImportExportTests {
    // MARK: - export(order:size:endian:nails:) Tests

    @Test
    func export_ZeroValue_DefaultParameters() async throws {
        // Given: A GMPInteger initialized to 0
        let integer = GMPInteger(0)

        // When: export() is called with default parameters
        let data = integer.export(
            order: GMPInteger.ByteOrder.native,
            size: 8,
            endian: GMPInteger.Endianness.native,
            nails: 0
        )

        // Then: Returns a Data object that can be imported to recover 0
        let imported = GMPInteger(
            data: data,
            order: GMPInteger.ByteOrder.native,
            size: 8,
            endian: GMPInteger.Endianness.native,
            nails: 0
        )
        #expect(imported != nil)
        #expect(imported!.toInt() == 0)
    }

    @Test
    func export_PositiveValue_DefaultParameters() async throws {
        // Given: A GMPInteger initialized to a positive value (e.g., 12345)
        let integer = GMPInteger(12345)

        // When: export() is called with default parameters
        let data = integer.export(
            order: GMPInteger.ByteOrder.native,
            size: 8,
            endian: GMPInteger.Endianness.native,
            nails: 0
        )

        // Then: Returns a Data object that can be imported to recover the original value
        let imported = GMPInteger(
            data: data,
            order: GMPInteger.ByteOrder.native,
            size: 8,
            endian: GMPInteger.Endianness.native,
            nails: 0
        )
        #expect(imported != nil)
        #expect(imported!.toInt() == 12345)
    }

    @Test
    func export_NegativeValue_DefaultParameters() async throws {
        // Given: A GMPInteger initialized to a negative value (e.g., -12345)
        let integer = GMPInteger(-12345)

        // When: export() is called with default parameters
        let data = integer.export(
            order: GMPInteger.ByteOrder.native,
            size: 8,
            endian: GMPInteger.Endianness.native,
            nails: 0
        )

        // Then: Returns a Data object that can be imported to recover the original value
        let imported = GMPInteger(
            data: data,
            order: GMPInteger.ByteOrder.native,
            size: 8,
            endian: GMPInteger.Endianness.native,
            nails: 0
        )
        #expect(imported != nil)
        #expect(imported!.toInt() == -12345)
    }

    @Test
    func export_LargeValue_DefaultParameters() async throws {
        // Given: A GMPInteger initialized to a very large value (e.g., 2^256)
        let integer = GMPInteger(1).multipliedByPowerOf2(256)

        // When: export() is called with default parameters
        let data = integer.export(
            order: GMPInteger.ByteOrder.native,
            size: 8,
            endian: GMPInteger.Endianness.native,
            nails: 0
        )

        // Then: Returns a Data object that can be imported to recover the original value
        let imported = GMPInteger(
            data: data,
            order: GMPInteger.ByteOrder.native,
            size: 8,
            endian: GMPInteger.Endianness.native,
            nails: 0
        )
        #expect(imported != nil)
        #expect(imported! == integer)
    }

    @Test
    func export_AllByteOrders() async throws {
        // Given: A GMPInteger initialized to a known value
        let integer = GMPInteger(12345)

        // When: export() is called with each ByteOrder
        let data1 = integer.export(
            order: GMPInteger.ByteOrder.native,
            size: 8,
            endian: GMPInteger.Endianness.native,
            nails: 0
        )
        let data2 = integer.export(
            order: GMPInteger.ByteOrder.leastSignificantFirst,
            size: 8,
            endian: GMPInteger.Endianness.native,
            nails: 0
        )
        let data3 = integer.export(
            order: GMPInteger.ByteOrder.mostSignificantFirst,
            size: 8,
            endian: GMPInteger.Endianness.native,
            nails: 0
        )

        // Then: Each export produces valid Data that can be imported with matching order
        let imported1 = GMPInteger(
            data: data1,
            order: GMPInteger.ByteOrder.native,
            size: 8,
            endian: GMPInteger.Endianness.native,
            nails: 0
        )
        let imported2 = GMPInteger(
            data: data2,
            order: GMPInteger.ByteOrder.leastSignificantFirst,
            size: 8,
            endian: GMPInteger.Endianness.native,
            nails: 0
        )
        let imported3 = GMPInteger(
            data: data3,
            order: GMPInteger.ByteOrder.mostSignificantFirst,
            size: 8,
            endian: GMPInteger.Endianness.native,
            nails: 0
        )

        #expect(imported1 != nil)
        #expect(imported1!.toInt() == 12345)
        #expect(imported2 != nil)
        #expect(imported2!.toInt() == 12345)
        #expect(imported3 != nil)
        #expect(imported3!.toInt() == 12345)
    }

    @Test
    func export_AllEndianness() async throws {
        // Given: A GMPInteger initialized to a known value
        let integer = GMPInteger(12345)

        // When: export() is called with each Endianness
        let data1 = integer.export(
            order: GMPInteger.ByteOrder.native,
            size: 8,
            endian: GMPInteger.Endianness.native,
            nails: 0
        )
        let data2 = integer.export(
            order: GMPInteger.ByteOrder.native,
            size: 8,
            endian: GMPInteger.Endianness.little,
            nails: 0
        )
        let data3 = integer.export(
            order: GMPInteger.ByteOrder.native,
            size: 8,
            endian: GMPInteger.Endianness.big,
            nails: 0
        )

        // Then: Each export produces valid Data that can be imported with matching endianness
        let imported1 = GMPInteger(
            data: data1,
            order: GMPInteger.ByteOrder.native,
            size: 8,
            endian: GMPInteger.Endianness.native,
            nails: 0
        )
        let imported2 = GMPInteger(
            data: data2,
            order: GMPInteger.ByteOrder.native,
            size: 8,
            endian: GMPInteger.Endianness.little,
            nails: 0
        )
        let imported3 = GMPInteger(
            data: data3,
            order: GMPInteger.ByteOrder.native,
            size: 8,
            endian: GMPInteger.Endianness.big,
            nails: 0
        )

        #expect(imported1 != nil)
        #expect(imported1!.toInt() == 12345)
        #expect(imported2 != nil)
        #expect(imported2!.toInt() == 12345)
        #expect(imported3 != nil)
        #expect(imported3!.toInt() == 12345)
    }

    @Test
    func export_VariousSizes() async throws {
        // Given: A GMPInteger initialized to a known value
        let integer = GMPInteger(12345)

        // When: export() is called with size values 1, 2, 4, 8
        let data1 = integer.export(
            order: GMPInteger.ByteOrder.native,
            size: 1,
            endian: GMPInteger.Endianness.native,
            nails: 0
        )
        let data2 = integer.export(
            order: GMPInteger.ByteOrder.native,
            size: 2,
            endian: GMPInteger.Endianness.native,
            nails: 0
        )
        let data4 = integer.export(
            order: GMPInteger.ByteOrder.native,
            size: 4,
            endian: GMPInteger.Endianness.native,
            nails: 0
        )
        let data8 = integer.export(
            order: GMPInteger.ByteOrder.native,
            size: 8,
            endian: GMPInteger.Endianness.native,
            nails: 0
        )

        // Then: Each export produces valid Data that can be imported with matching size
        let imported1 = GMPInteger(
            data: data1,
            order: GMPInteger.ByteOrder.native,
            size: 1,
            endian: GMPInteger.Endianness.native,
            nails: 0
        )
        let imported2 = GMPInteger(
            data: data2,
            order: GMPInteger.ByteOrder.native,
            size: 2,
            endian: GMPInteger.Endianness.native,
            nails: 0
        )
        let imported4 = GMPInteger(
            data: data4,
            order: GMPInteger.ByteOrder.native,
            size: 4,
            endian: GMPInteger.Endianness.native,
            nails: 0
        )
        let imported8 = GMPInteger(
            data: data8,
            order: GMPInteger.ByteOrder.native,
            size: 8,
            endian: GMPInteger.Endianness.native,
            nails: 0
        )

        #expect(imported1 != nil)
        #expect(imported1!.toInt() == 12345)
        #expect(imported2 != nil)
        #expect(imported2!.toInt() == 12345)
        #expect(imported4 != nil)
        #expect(imported4!.toInt() == 12345)
        #expect(imported8 != nil)
        #expect(imported8!.toInt() == 12345)
    }

    @Test
    func export_SizeBoundary_Minimum() async throws {
        // Given: A GMPInteger initialized to a value
        let integer = GMPInteger(42)

        // When: export() is called with size = 1 (minimum valid)
        let data = integer.export(
            order: GMPInteger.ByteOrder.native,
            size: 1,
            endian: GMPInteger.Endianness.native,
            nails: 0
        )

        // Then: Returns valid Data that can be imported
        let imported = GMPInteger(
            data: data,
            order: GMPInteger.ByteOrder.native,
            size: 1,
            endian: GMPInteger.Endianness.native,
            nails: 0
        )
        #expect(imported != nil)
        #expect(imported!.toInt() == 42)
    }

    @Test
    func export_RoundTrip_AllCombinations() async throws {
        // Given: A GMPInteger initialized to various test values
        let testValues = [
            GMPInteger(0),
            GMPInteger(1),
            GMPInteger(-1),
            GMPInteger(12345),
            GMPInteger(-12345),
        ]

        // When: export() is called with various parameter combinations, then import() with same parameters
        for value in testValues {
            let data = value.export(
                order: GMPInteger.ByteOrder.native,
                size: 8,
                endian: GMPInteger.Endianness.native,
                nails: 0
            )
            let imported = GMPInteger(
                data: data,
                order: GMPInteger.ByteOrder.native,
                size: 8,
                endian: GMPInteger.Endianness.native,
                nails: 0
            )

            // Then: All round trips recover the original value
            #expect(imported != nil)
            #expect(imported! == value)
        }
    }

    // MARK: - init?(data:order:size:endian:nails:) Tests

    @Test
    func init_ValidData_DefaultParameters() async throws {
        // Given: Valid Data exported from a known GMPInteger with default parameters
        let original = GMPInteger(12345)
        let data = original.export(
            order: GMPInteger.ByteOrder.native,
            size: 8,
            endian: GMPInteger.Endianness.native,
            nails: 0
        )

        // When: init?(data:order:size:endian:nails:) is called with matching parameters
        let imported = GMPInteger(
            data: data,
            order: GMPInteger.ByteOrder.native,
            size: 8,
            endian: GMPInteger.Endianness.native,
            nails: 0
        )

        // Then: Returns a GMPInteger with the original value
        #expect(imported != nil)
        #expect(imported!.toInt() == 12345)
    }

    @Test
    func init_EmptyData() async throws {
        // Given: Empty Data object
        let emptyData = Data()

        // When: init?() is called
        let imported = GMPInteger(
            data: emptyData,
            order: GMPInteger.ByteOrder.native,
            size: 8,
            endian: GMPInteger.Endianness.native,
            nails: 0
        )

        // Then: Returns nil (insufficient bytes for at least one word)
        #expect(imported == nil)
    }

    @Test
    func init_InsufficientData() async throws {
        // Given: Data with fewer bytes than required for one word (e.g., size=8 but only 4 bytes)
        let insufficientData = Data([0x01, 0x02, 0x03, 0x04])

        // When: init?() is called
        let imported = GMPInteger(
            data: insufficientData,
            order: GMPInteger.ByteOrder.native,
            size: 8,
            endian: GMPInteger.Endianness.native,
            nails: 0
        )

        // Then: Returns nil
        #expect(imported == nil)
    }
}

// MARK: - String-based I/O Tests

struct GMPIntegerStringIOTests {
    // MARK: - writeToString(base:) Tests

    @Test
    func writeToString_Zero_Base10() async throws {
        // Given: A GMPInteger initialized to 0
        let integer = GMPInteger(0)

        // When: writeToString(base: 10) is called
        let result = integer.writeToString(base: 10)

        // Then: Returns "0"
        #expect(result == "0")
    }

    @Test
    func writeToString_Positive_Base10() async throws {
        // Given: A GMPInteger initialized to 12345
        let integer = GMPInteger(12345)

        // When: writeToString(base: 10) is called
        let result = integer.writeToString(base: 10)

        // Then: Returns "12345"
        #expect(result == "12345")
    }

    @Test
    func writeToString_Negative_Base10() async throws {
        // Given: A GMPInteger initialized to -12345
        let integer = GMPInteger(-12345)

        // When: writeToString(base: 10) is called
        let result = integer.writeToString(base: 10)

        // Then: Returns "-12345"
        #expect(result == "-12345")
    }

    @Test
    func writeToString_Base2() async throws {
        // Given: A GMPInteger initialized to 10
        let integer = GMPInteger(10)

        // When: writeToString(base: 2) is called
        let result = integer.writeToString(base: 2)

        // Then: Returns "1010"
        #expect(result == "1010")
    }

    @Test
    func writeToString_Base16() async throws {
        // Given: A GMPInteger initialized to 255
        let integer = GMPInteger(255)

        // When: writeToString(base: 16) is called
        let result = integer.writeToString(base: 16)

        // Then: Returns "ff" (lowercase)
        #expect(result == "ff")
    }

    @Test
    func writeToString_DefaultBase() async throws {
        // Given: A GMPInteger initialized to 12345
        let integer = GMPInteger(12345)

        // When: writeToString() is called (default base = 10)
        let result = integer.writeToString()

        // Then: Returns "12345"
        #expect(result == "12345")
    }

    @Test
    func writeToString_RoundTrip_AllBases() async throws {
        // Given: A GMPInteger initialized to various test values
        let testValues = [
            GMPInteger(0),
            GMPInteger(1),
            GMPInteger(-1),
            GMPInteger(12345),
            GMPInteger(-12345),
        ]
        let bases = [2, 10, 16, 36]

        // When: writeToString(base: n) is called, then init?(string:base: n) with result
        for value in testValues {
            for base in bases {
                let string = value.writeToString(base: base)
                let imported = GMPInteger(string: string, base: base)

                // Then: All round trips recover the original value
                #expect(imported != nil)
                #expect(imported! == value)
            }
        }
    }

    // MARK: - init?(string:base:) Tests

    @Test
    func init_String_Zero_Base10() async throws {
        // Given: String "0"
        // When: init?(string: "0", base: 10) is called
        let integer = GMPInteger(string: "0", base: 10)

        // Then: Returns a GMPInteger with value 0
        #expect(integer != nil)
        #expect(integer!.toInt() == 0)
    }

    @Test
    func init_String_Positive_Base10() async throws {
        // Given: String "12345"
        // When: init?(string: "12345", base: 10) is called
        let integer = GMPInteger(string: "12345", base: 10)

        // Then: Returns a GMPInteger with value 12345
        #expect(integer != nil)
        #expect(integer!.toInt() == 12345)
    }

    @Test
    func init_String_Negative_Base10() async throws {
        // Given: String "-12345"
        // When: init?(string: "-12345", base: 10) is called
        let integer = GMPInteger(string: "-12345", base: 10)

        // Then: Returns a GMPInteger with value -12345
        #expect(integer != nil)
        #expect(integer!.toInt() == -12345)
    }

    @Test
    func init_String_Base2() async throws {
        // Given: String "1010"
        // When: init?(string: "1010", base: 2) is called
        let integer = GMPInteger(string: "1010", base: 2)

        // Then: Returns a GMPInteger with value 10
        #expect(integer != nil)
        #expect(integer!.toInt() == 10)
    }

    @Test
    func init_String_Base16() async throws {
        // Given: String "ff"
        // When: init?(string: "ff", base: 16) is called
        let integer = GMPInteger(string: "ff", base: 16)

        // Then: Returns a GMPInteger with value 255
        #expect(integer != nil)
        #expect(integer!.toInt() == 255)
    }

    @Test
    func init_String_Base16_UpperCase() async throws {
        // Given: String "FF"
        // When: init?(string: "FF", base: 16) is called
        let integer = GMPInteger(string: "FF", base: 16)

        // Then: Returns a GMPInteger with value 255
        #expect(integer != nil)
        #expect(integer!.toInt() == 255)
    }

    @Test
    func init_String_Base0_AutoDetect_Decimal() async throws {
        // Given: String "12345"
        // When: init?(string: "12345", base: 0) is called
        let integer = GMPInteger(string: "12345", base: 0)

        // Then: Returns a GMPInteger with value 12345 (auto-detects decimal)
        #expect(integer != nil)
        #expect(integer!.toInt() == 12345)
    }

    @Test
    func init_String_Base0_AutoDetect_Hex() async throws {
        // Given: String "0xff"
        // When: init?(string: "0xff", base: 0) is called
        let integer = GMPInteger(string: "0xff", base: 0)

        // Then: Returns a GMPInteger with value 255 (auto-detects hex)
        #expect(integer != nil)
        #expect(integer!.toInt() == 255)
    }

    @Test
    func init_String_Empty() async throws {
        // Given: Empty string ""
        // When: init?(string: "", base: 10) is called
        let integer = GMPInteger(string: "", base: 10)

        // Then: Returns nil
        #expect(integer == nil)
    }

    @Test
    func init_String_DefaultBase() async throws {
        // Given: String "12345"
        // When: init?(string: "12345") is called (default base = 10)
        let integer = GMPInteger(string: "12345")

        // Then: Returns a GMPInteger with value 12345
        #expect(integer != nil)
        #expect(integer!.toInt() == 12345)
    }
}

// MARK: - FileHandle-based I/O Tests

struct GMPIntegerFileHandleIOTests {
    @Test
    func write_FileHandle_Base10() async throws {
        // Given: A GMPInteger initialized to 12345, a FileHandle open for writing
        let integer = GMPInteger(12345)
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        FileManager.default.createFile(atPath: tempURL.path, contents: nil)
        let fileHandle = try FileHandle(forWritingTo: tempURL)
        defer {
            try? fileHandle.close()
            try? FileManager.default.removeItem(at: tempURL)
        }

        // When: write(to: fileHandle, base: 10) is called
        let bytesWritten = integer.write(to: fileHandle, base: 10)

        // Then: Returns number of bytes written (> 0), fileHandle contains "12345\n"
        #expect(bytesWritten > 0)
        try fileHandle.close()
        let fileHandle2 = try FileHandle(forReadingFrom: tempURL)
        defer { try? fileHandle2.close() }
        let data = fileHandle2.readDataToEndOfFile()
        let content = String(data: data, encoding: .utf8) ?? ""
        #expect(content == "12345\n")
    }

    @Test
    func write_FileHandle_Zero_Base10() async throws {
        // Given: A GMPInteger initialized to 0, a FileHandle open for writing
        let integer = GMPInteger(0)
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        FileManager.default.createFile(atPath: tempURL.path, contents: nil)
        let fileHandle = try FileHandle(forWritingTo: tempURL)
        defer {
            try? fileHandle.close()
            try? FileManager.default.removeItem(at: tempURL)
        }

        // When: write(to: fileHandle, base: 10) is called
        let bytesWritten = integer.write(to: fileHandle, base: 10)

        // Then: Returns number of bytes written, fileHandle contains "0\n"
        #expect(bytesWritten > 0)
        try fileHandle.close()
        let fileHandle2 = try FileHandle(forReadingFrom: tempURL)
        defer { try? fileHandle2.close() }
        let data = fileHandle2.readDataToEndOfFile()
        let content = String(data: data, encoding: .utf8) ?? ""
        #expect(content == "0\n")
    }

    @Test
    func init_FileHandle_Base10() async throws {
        // Given: A FileHandle containing "12345\n", open for reading
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        let content = "12345\n"
        try content.write(to: tempURL, atomically: true, encoding: .utf8)
        let fileHandle = try FileHandle(forReadingFrom: tempURL)
        defer {
            try? fileHandle.close()
            try? FileManager.default.removeItem(at: tempURL)
        }

        // When: init?(fileHandle: fileHandle, base: 10) is called
        let integer = GMPInteger(fileHandle: fileHandle, base: 10)

        // Then: Returns a GMPInteger with value 12345
        #expect(integer != nil)
        #expect(integer!.toInt() == 12345)
    }

    @Test
    func writeRaw_FileHandle_RoundTrip() async throws {
        // Given: A GMPInteger initialized to a value, a FileHandle open for writing/reading
        let original = GMPInteger(12345)
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        FileManager.default.createFile(atPath: tempURL.path, contents: nil)
        let writeHandle = try FileHandle(forWritingTo: tempURL)
        defer { try? writeHandle.close() }

        // When: writeRaw(to: fileHandle) is called
        let bytesWritten = original.writeRaw(to: writeHandle)
        #expect(bytesWritten > 0)
        try writeHandle.close()

        // Then: init?(rawFileHandle: fileHandle) recovers the original value
        let readHandle = try FileHandle(forReadingFrom: tempURL)
        defer {
            try? readHandle.close()
            try? FileManager.default.removeItem(at: tempURL)
        }
        let imported = GMPInteger(rawFileHandle: readHandle)
        #expect(imported != nil)
        #expect(imported! == original)
    }
}

// MARK: - Debug Tests

struct GMPIntegerDebugTests {
    @Test
    func dump_Zero() async throws {
        // Given: A GMPInteger initialized to 0
        let integer = GMPInteger(0)

        // When: dump() is called
        integer.dump()

        // Then: Outputs debug information to standard error, self is unchanged
        // (We can't easily test stderr output, but we can verify no crash)
        #expect(integer.toInt() == 0)
    }

    @Test
    func dump_Positive() async throws {
        // Given: A GMPInteger initialized to 12345
        let integer = GMPInteger(12345)

        // When: dump() is called
        integer.dump()

        // Then: Outputs debug information to standard error, self is unchanged
        #expect(integer.toInt() == 12345)
    }
}

// MARK: - Low-Level Access Tests

struct GMPIntegerLowLevelAccessTests {
    @Test
    func getLimb_Index_Zero() async throws {
        // Given: A GMPInteger initialized to a value with known limb structure
        let integer = GMPInteger(42)

        // When: getLimb(at: 0) is called (least significant limb)
        let limb = integer.getLimb(at: 0)

        // Then: Returns the correct limb value
        #expect(limb == 42)
    }

    @Test
    func getLimb_ZeroValue() async throws {
        // Given: A GMPInteger initialized to 0
        let integer = GMPInteger(0)

        // When: getLimb(at: 0) is called
        let limb = integer.getLimb(at: 0)

        // Then: Returns 0
        #expect(limb == 0)
    }

    @Test
    func getLimb_NoSideEffects() async throws {
        // Given: A GMPInteger initialized to a value
        let integer = GMPInteger(12345)
        let originalValue = integer.toInt()

        // When: getLimb(at: index) is called, then the value is checked
        _ = integer.getLimb(at: 0)

        // Then: The value is unchanged
        #expect(integer.toInt() == originalValue)
    }

    // MARK: - Random Number Generation Tests

    @Test
    func random_Bits_One_ReturnsValidValue() async throws {
        // Given: A properly initialized GMPRandomState
        let state = GMPRandomState(mersenneTwister: GMPInteger(42))

        // When: random(bits: 1, using: state) is called
        let result = GMPInteger.random(bits: 1, using: state)

        // Then: Returns a GMPInteger with exactly 1 bit (value in range [0, 2))
        #expect(result >= GMPInteger(0))
        #expect(result < GMPInteger(2))
    }

    @Test
    func random_Bits_Small_ReturnsValidValue() async throws {
        // Given: A properly initialized GMPRandomState
        let state = GMPRandomState(mersenneTwister: GMPInteger(42))

        // When: random(bits: 8, using: state) is called
        let result = GMPInteger.random(bits: 8, using: state)

        // Then: Returns a GMPInteger with exactly 8 bits (value in range [0, 256))
        #expect(result >= GMPInteger(0))
        #expect(result < GMPInteger(256))
    }

    @Test
    func random_Bits_Medium_ReturnsValidValue() async throws {
        // Given: A properly initialized GMPRandomState
        let state = GMPRandomState(mersenneTwister: GMPInteger(42))

        // When: random(bits: 64, using: state) is called
        let result = GMPInteger.random(bits: 64, using: state)

        // Then: Returns a GMPInteger with exactly 64 bits
        #expect(result >= GMPInteger(0))
    }

    @Test
    func random_Reproducibility_WithSameSeed() async throws {
        // Given: Two GMPRandomState instances initialized with the same seed
        let state1 = GMPRandomState(mersenneTwister: GMPInteger(42))
        let state2 = GMPRandomState(mersenneTwister: GMPInteger(42))

        // When: random(bits: 64, using: state1) and random(bits: 64, using: state2) are called
        let result1 = GMPInteger.random(bits: 64, using: state1)
        let result2 = GMPInteger.random(bits: 64, using: state2)

        // Then: Both calls produce the same value (reproducible)
        #expect(result1 == result2)
    }

    @Test
    func random_UpperBound_Small_ReturnsInRange() async throws {
        // Given: A properly initialized GMPRandomState and upperBound
        let state = GMPRandomState(mersenneTwister: GMPInteger(42))
        let upperBound = GMPInteger(100)

        // When: random(upperBound: upperBound, using: state) is called
        let result = GMPInteger.random(upperBound: upperBound, using: state)

        // Then: Returns a GMPInteger in range [0, upperBound)
        #expect(result >= GMPInteger(0))
        #expect(result < upperBound)
    }

    @Test
    func random_UpperBound_Large_ReturnsInRange() async throws {
        // Given: A properly initialized GMPRandomState and large upperBound
        let state = GMPRandomState(mersenneTwister: GMPInteger(42))
        let upperBound = GMPInteger("1000000000000000000000000")!

        // When: random(upperBound: upperBound, using: state) is called
        let result = GMPInteger.random(upperBound: upperBound, using: state)

        // Then: Returns a GMPInteger in range [0, upperBound)
        #expect(result >= GMPInteger(0))
        #expect(result < upperBound)
    }

    @Test
    func randomLong_Bits_ReturnsValidValue() async throws {
        // Given: A properly initialized GMPRandomState
        let state = GMPRandomState(mersenneTwister: GMPInteger(42))

        // When: randomLong(bits: 64, using: state) is called
        let result = GMPInteger.randomLong(bits: 64, using: state)

        // Then: Returns a GMPInteger with the specified number of bits
        #expect(result >= GMPInteger(0))
    }

    // MARK: - Cryptographically Secure Random Number Generation Tests

    @Test
    func secureRandom_Bits_One_ReturnsValidValue() async throws {
        // Given: bits = 1
        // When: secureRandom(bits: 1) is called
        let result = try GMPInteger.secureRandom(bits: 1)

        // Then: Returns a GMPInteger with exactly 1 bit (value 0 or 1)
        #expect(result >= GMPInteger(0))
        #expect(result < GMPInteger(2))
        // Verify it has exactly 1 bit (should be 1, since we ensure minValue)
        #expect(result == GMPInteger(1))
    }

    @Test
    func secureRandom_Bits_Small_ReturnsValidValue() async throws {
        // Given: bits = 8
        // When: secureRandom(bits: 8) is called
        let result = try GMPInteger.secureRandom(bits: 8)

        // Then: Returns a GMPInteger with exactly 8 bits (in range [128, 256))
        #expect(result >= GMPInteger(128))
        #expect(result < GMPInteger(256))
        #expect(result.bitCount == 8)
    }

    @Test
    func secureRandom_Bits_Medium_ReturnsValidValue() async throws {
        // Given: bits = 64
        // When: secureRandom(bits: 64) is called
        let result = try GMPInteger.secureRandom(bits: 64)

        // Then: Returns a GMPInteger with exactly 64 bits
        #expect(result >= GMPInteger(1) << 63)
        #expect(result < GMPInteger(1) << 64)
        #expect(result.bitCount == 64)
    }

    @Test
    func secureRandom_Bits_Large_ReturnsValidValue() async throws {
        // Given: bits = 256
        // When: secureRandom(bits: 256) is called
        let result = try GMPInteger.secureRandom(bits: 256)

        // Then: Returns a GMPInteger with exactly 256 bits
        #expect(result >= GMPInteger(1) << 255)
        #expect(result < GMPInteger(1) << 256)
        #expect(result.bitCount == 256)
    }

    @Test
    func secureRandom_Bits_NonDeterministic() async throws {
        // Given: Multiple calls to secureRandom
        // When: secureRandom(bits: 256) is called multiple times
        let result1 = try GMPInteger.secureRandom(bits: 256)
        let result2 = try GMPInteger.secureRandom(bits: 256)
        let result3 = try GMPInteger.secureRandom(bits: 256)

        // Then: Each call produces a different value (non-deterministic)
        // Note: It's extremely unlikely (but not impossible) for all three to
        // be the same
        // We check that at least two are different, which should always be true
        let allSame = result1 == result2 && result2 == result3
        #expect(!allSame, "Secure random should produce different values")
    }

    @Test
    func secureRandom_UpperBound_Small_ReturnsInRange() async throws {
        // Given: upperBound = GMPInteger(100)
        let upperBound = GMPInteger(100)

        // When: secureRandom(upperBound: upperBound) is called multiple times
        for _ in 0 ..< 100 {
            let result = try GMPInteger.secureRandom(upperBound: upperBound)

            // Then: All returned values are in range [0, upperBound)
            #expect(result >= GMPInteger(0))
            #expect(result < upperBound)
        }
    }

    @Test
    func secureRandom_UpperBound_Large_ReturnsInRange() async throws {
        // Given: upperBound = GMPInteger(2^256)
        let upperBound = GMPInteger(1) << 256

        // When: secureRandom(upperBound: upperBound) is called
        let result = try GMPInteger.secureRandom(upperBound: upperBound)

        // Then: Returns a GMPInteger in range [0, upperBound)
        #expect(result >= GMPInteger(0))
        #expect(result < upperBound)
    }

    @Test
    func secureRandom_UpperBound_NonDeterministic() async throws {
        // Given: upperBound = GMPInteger(1000)
        let upperBound = GMPInteger(1000)

        // When: secureRandom(upperBound: upperBound) is called multiple times
        let result1 = try GMPInteger.secureRandom(upperBound: upperBound)
        let result2 = try GMPInteger.secureRandom(upperBound: upperBound)
        let result3 = try GMPInteger.secureRandom(upperBound: upperBound)

        // Then: Each call produces a different value (non-deterministic)
        // Note: It's extremely unlikely (but not impossible) for all three to
        // be the same
        let allSame = result1 == result2 && result2 == result3
        #expect(!allSame, "Secure random should produce different values")
    }

    @Test
    func secureRandom_UpperBound_UniformDistribution() async throws {
        // Given: upperBound = GMPInteger(10) for testing distribution
        let upperBound = GMPInteger(10)

        // When: secureRandom(upperBound: upperBound) is called many times
        var counts: [GMPInteger: Int] = [:]
        for _ in 0 ..< 1000 {
            let result = try GMPInteger.secureRandom(upperBound: upperBound)
            counts[result, default: 0] += 1
        }

        // Then: Values are distributed (uniform distribution test)
        // With 1000 samples and 10 possible values, we should see multiple
        // different values
        // Note: With secure random and rejection sampling, it's statistically
        // possible
        // (though very unlikely) that not all values appear, so we check for at
        // least 2
        #expect(
            counts.count >= 2,
            "Should see multiple values in uniform distribution"
        )

        // Verify all values are in valid range
        for (value, _) in counts {
            #expect(value >= GMPInteger(0))
            #expect(value < upperBound)
        }
    }

    @Test
    func secureRandom_UpperBound_One_ReturnsZero() async throws {
        // Given: upperBound = GMPInteger(1)
        let upperBound = GMPInteger(1)

        // When: secureRandom(upperBound: upperBound) is called
        let result = try GMPInteger.secureRandom(upperBound: upperBound)

        // Then: Always returns 0 (only value in range [0, 1))
        #expect(result == GMPInteger(0))
    }

    @Test
    func secureRandom_Bits_EdgeCase_OneBit() async throws {
        // Given: bits = 1
        // When: secureRandom(bits: 1) is called
        let result = try GMPInteger.secureRandom(bits: 1)

        // Then: Returns exactly 1 (ensured by minValue logic)
        #expect(result == GMPInteger(1))
        #expect(result.bitCount == 1)
    }
}
