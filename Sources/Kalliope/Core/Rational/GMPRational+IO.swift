import CKalliope
import CKalliopeBridge
import Foundation

/// Input/output operations for `GMPRational`.
extension GMPRational {
    // MARK: - String-based I/O (Primary Swift API)

    /// Convert this rational number to a string representation in the given
    /// base.
    ///
    /// This is the primary Swift API for converting rationals to strings.
    /// Equivalent to
    /// `toString(base:)` but provided for consistency with I/O naming.
    ///
    /// - Parameter base: The numeric base (radix) for conversion. Must be in
    /// the range 2-62,
    ///   or from -2 to -36. Defaults to 10 (decimal).
    /// - Returns: A string representation in the format "num/den".
    ///
    /// - Requires: This rational must be properly initialized. `base` must be
    /// in the range
    ///   2-62 or -36 to -2.
    /// - Guarantees: Returns a valid string representation. The string can be
    /// parsed back
    ///   using `init(string:base:)` with the same base to recover the original
    /// value.
    ///
    /// - Note: Uses `mpq_get_str`.
    public func writeToString(base: Int = 10) -> String {
        toString(base: base)
    }

    /// Create a rational number from a string representation.
    ///
    /// This is the primary Swift API for parsing rationals from strings.
    /// Equivalent to
    /// `init(_:base:)` but provided for consistency with I/O naming.
    ///
    /// - Parameters:
    ///   - string: The string to parse. Format: "num/den" or "num".
    ///   - base: The numeric base (radix) for parsing. Must be 0 or in the
    /// range 2-62.
    ///     Defaults to 10.
    /// - Returns: A new `GMPRational` if parsing succeeds, `nil` otherwise.
    ///
    /// - Requires: `base` must be 0 or in the range 2-62. `string` must not be
    /// empty.
    /// - Guarantees: If parsing succeeds, returns a valid `GMPRational` with
    /// the canonicalized
    ///   value. If parsing fails, returns `nil`.
    ///
    /// - Note: Uses `mpq_set_str`.
    public init?(string: String, base: Int = 10) {
        self.init(string, base: base)
    }

    // MARK: - FileHandle-based I/O (Swift-idiomatic)

    /// Write this rational number to a FileHandle in string format.
    ///
    /// Writes the rational as a string in the format "num/den", followed by a
    /// newline.
    ///
    /// - Parameters:
    ///   - fileHandle: The FileHandle to write to. Must be open for writing.
    ///   - base: The numeric base (radix) for conversion. Must be in the range
    /// 2-62.
    ///     Defaults to 10.
    /// - Returns: The number of bytes written, or 0 on error.
    ///
    /// - Requires: This rational must be properly initialized. `fileHandle`
    /// must be open
    ///   for writing. `base` must be in the range 2-62.
    /// - Guarantees: If successful, returns the number of bytes written
    /// (including newline).
    ///   If an error occurs, returns 0. `self` is unchanged.
    public func write(to fileHandle: FileHandle, base: Int = 10) -> Int {
        precondition(base >= 2 && base <= 62, "base must be in the range 2-62")
        let string = writeToString(base: base) + "\n"
        // Note: UTF-8 encoding failure is nearly impossible to test in practice
        // since
        // Swift strings are always valid UTF-8. This is a defensive programming
        // measure.
        guard let data = string.data(using: .utf8) else {
            return 0
        }
        fileHandle.write(data)
        return data.count
    }

    /// Create a rational number by reading from a FileHandle in string format.
    ///
    /// Reads characters from the FileHandle until a newline or end of file is
    /// encountered,
    /// then parses the string as a rational number in the specified base.
    ///
    /// - Parameters:
    ///   - fileHandle: The FileHandle to read from. Must be open for reading.
    ///   - base: The numeric base (radix) for parsing. Must be 0 or in the
    /// range 2-62.
    ///     Defaults to 10.
    /// - Returns: A new `GMPRational` if reading and parsing succeed, `nil`
    /// otherwise.
    ///
    /// - Requires: `fileHandle` must be open for reading. `base` must be 0 or
    /// in the
    ///   range 2-62.
    /// - Guarantees: If reading and parsing succeed, returns a valid
    /// `GMPRational` with
    ///   the parsed value. If reading fails or parsing fails, returns `nil`.
    public init?(fileHandle: FileHandle, base: Int = 10) {
        precondition(
            base == 0 || (base >= 2 && base <= 62),
            "base must be 0 or in the range 2-62"
        )

        // Safely get file descriptor using helper that catches ObjC exceptions
        let fd = withExtendedLifetime(fileHandle) {
            let unmanaged = Unmanaged.passUnretained(fileHandle)
            return ckalliope_safe_file_descriptor(unmanaged.toOpaque())
        }
        guard fd >= 0 else {
            // File descriptor is invalid (closed handle)
            return nil
        }

        var line = ""
        var buffer = Data()
        let chunkSize = 1024

        // File descriptor is valid, so we can safely read
        // Note: readData(ofLength:) may still throw ObjC exceptions in edge
        // cases,
        // but the file descriptor check prevents most issues
        while true {
            let data = fileHandle.readData(ofLength: chunkSize)
            if data.isEmpty {
                break
            }
            buffer.append(data)
            if let string = String(data: buffer, encoding: .utf8),
               let newlineIndex = string.firstIndex(of: "\n")
            {
                line = String(string[..<newlineIndex])
                break
            }
        }

        if line.isEmpty, !buffer.isEmpty {
            if let string = String(data: buffer, encoding: .utf8) {
                line = string
            }
        }

        if line.isEmpty {
            return nil
        }

        // Trim whitespace
        line = line.trimmingCharacters(in: .whitespacesAndNewlines)
        if line.isEmpty {
            return nil
        }

        // Parse the line
        self.init(string: line, base: base)
    }
}
