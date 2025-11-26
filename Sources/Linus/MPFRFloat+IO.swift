// Import CKalliope first so gmp.h is available when CLinus imports mpfr.h
import CKalliope
import CLinus
import CLinusBridge
import Darwin
import Foundation
import Kalliope

/// Input/output operations for `MPFRFloat`.
extension MPFRFloat {
    // MARK: - String-based I/O (Primary Swift API)

    /// Convert this float to a string representation in the given base.
    ///
    /// This is the primary Swift API for converting floats to strings.
    /// Equivalent to
    /// `toString(base:digits:rounding:)` but provided for consistency with I/O
    /// naming.
    ///
    /// - Parameters:
    ///   - base: The numeric base (radix) for conversion. Must be in the range
    /// 2-62,
    ///     or from -2 to -36. Defaults to 10 (decimal).
    ///   - digits: The number of significant digits to output. If 0, outputs
    /// all significant
    ///     digits. Must be non-negative. Defaults to 0.
    ///   - rounding: The rounding mode to use. Defaults to `.nearest`.
    /// - Returns: A string representation of the float in the specified base.
    ///
    /// - Requires: This float must be properly initialized. `base` must be in
    /// the range
    ///   2-62 or -36 to -2. `digits` must be non-negative.
    /// - Guarantees: Returns a valid string representation. The string can be
    /// parsed back
    ///   using `init(string:base:precision:rounding:)` with the same base to
    /// recover the value
    ///   (within precision limits).
    ///
    /// - Note: Wraps `mpfr_get_str`.
    public func writeToString(
        base: Int = 10,
        digits: Int = 0,
        rounding: MPFRRoundingMode = .nearest
    ) -> String {
        toString(base: base, digits: digits, rounding: rounding)
    }

    /// Create a float from a string representation.
    ///
    /// This is the primary Swift API for parsing floats from strings.
    /// Equivalent to
    /// `init(_:base:precision:rounding:)` but provided for consistency with I/O
    /// naming.
    ///
    /// - Parameters:
    ///   - string: The string to parse. Must be a valid floating-point number
    /// in the
    ///     specified base. May include decimal point and exponent.
    ///   - base: The numeric base (radix) for parsing. Must be 0 or in the
    /// range 2-62.
    ///     Defaults to 10. If 0, the base is auto-detected from prefixes (0x,
    /// 0b, etc.).
    ///   - precision: The precision in bits. If nil, uses default precision.
    ///   - rounding: The rounding mode to use. Defaults to `.nearest`.
    /// - Returns: A new `MPFRFloat` if parsing succeeds, `nil` otherwise.
    ///
    /// - Requires: `base` must be 0 or in the range 2-62. `string` must not be
    /// empty.
    /// - Guarantees: If parsing succeeds, returns a valid `MPFRFloat` with the
    /// parsed value.
    ///   If parsing fails, returns `nil`.
    ///
    /// - Note: Wraps `mpfr_set_str`.
    public init?(
        string: String,
        base: Int = 10,
        precision: Int? = nil,
        rounding: MPFRRoundingMode = .nearest
    ) {
        self.init(string, base: base, precision: precision, rounding: rounding)
    }

    // MARK: - FileHandle-based I/O (Swift-idiomatic)

    /// Write this float to a FileHandle in string format.
    ///
    /// Writes the float as a string of digits in the specified base, followed
    /// by a newline.
    ///
    /// - Parameters:
    ///   - fileHandle: The FileHandle to write to. Must be open for writing.
    ///   - base: The numeric base (radix) for conversion. Must be in the range
    /// 2-62.
    ///     Defaults to 10.
    ///   - digits: The number of significant digits to output. If 0, outputs
    /// all significant
    ///     digits. Must be non-negative. Defaults to 0.
    ///   - rounding: The rounding mode to use. Defaults to `.nearest`.
    /// - Returns: The number of bytes written, or 0 on error.
    ///
    /// - Requires: This float must be properly initialized. `fileHandle` must
    /// be open
    ///   for writing. `base` must be in the range 2-62. `digits` must be
    /// non-negative.
    /// - Guarantees: If successful, returns the number of bytes written
    /// (including newline).
    ///   If an error occurs, returns 0. `self` is unchanged.
    public func write(
        to fileHandle: FileHandle,
        base: Int = 10,
        digits: Int = 0,
        rounding: MPFRRoundingMode = .nearest
    ) -> Int {
        precondition(
            base >= 2 && base <= 62,
            "base must be in the range 2-62"
        )
        precondition(digits >= 0, "digits must be non-negative")
        let string = writeToString(
            base: base,
            digits: digits,
            rounding: rounding
        ) + "\n"
        guard let data = string.data(using: .utf8) else {
            return 0
        }
        do {
            try fileHandle.write(contentsOf: data)
            return data.count
        } catch {
            // FileHandle write failed (e.g., closed handle)
            return 0
        }
    }

    /// Create a float by reading from a FileHandle in string format.
    ///
    /// Reads characters from the FileHandle until a newline or end of file is
    /// encountered,
    /// then parses the string as a floating-point number in the specified base.
    ///
    /// - Parameters:
    ///   - fileHandle: The FileHandle to read from. Must be open for reading.
    ///   - base: The numeric base (radix) for parsing. Must be 0 or in the
    /// range 2-62.
    ///     Defaults to 10.
    ///   - precision: The precision in bits. If nil, uses default precision.
    ///   - rounding: The rounding mode to use. Defaults to `.nearest`.
    /// - Returns: A new `MPFRFloat` if reading and parsing succeed, `nil`
    /// otherwise.
    ///
    /// - Requires: `fileHandle` must be open for reading. `base` must be 0 or
    /// in the
    ///   range 2-62.
    /// - Guarantees: If reading and parsing succeed, returns a valid
    /// `MPFRFloat` with
    ///   the parsed value. If reading fails or parsing fails, returns `nil`.
    public init?(
        fileHandle: FileHandle,
        base: Int = 10,
        precision: Int? = nil,
        rounding: MPFRRoundingMode = .nearest
    ) {
        precondition(
            base == 0 || (base >= 2 && base <= 62),
            "base must be 0 or in the range 2-62"
        )

        // Safely get file descriptor using helper that catches ObjC exceptions
        let fd = withExtendedLifetime(fileHandle) {
            let unmanaged = Unmanaged.passUnretained(fileHandle)
            return clinus_safe_file_descriptor(unmanaged.toOpaque())
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

        guard !line.isEmpty else {
            return nil
        }

        self.init(
            string: line,
            base: base,
            precision: precision,
            rounding: rounding
        )
    }

    // MARK: - Pointer Access for Formatted I/O

    /// Execute a closure with a pointer to the underlying `mpfr_t`, ensuring
    /// the pointer
    /// remains valid for the duration of the closure.
    ///
    /// This method ensures that the storage is kept alive and the pointer is
    /// valid
    /// during the execution of the closure. This is the preferred way to use
    /// the
    /// pointer in contexts where it needs to remain valid (e.g., in
    /// `withVaList`).
    ///
    /// - Parameter body: A closure that receives the pointer and returns a
    /// value.
    /// - Returns: The value returned by the closure.
    func withCPointer<T>(
        _ body: (UnsafePointer<mpfr_t>) throws -> T
    ) rethrows -> T {
        try withUnsafePointer(to: _storage.value) { ptr in
            try body(ptr)
        }
    }

    /// Execute a closure with a mutable pointer to the underlying `mpfr_t`,
    /// ensuring the pointer
    /// remains valid for the duration of the closure.
    ///
    /// This method ensures that the storage is kept alive and the pointer is
    /// valid
    /// during the execution of the closure. This is the preferred way to use
    /// the
    /// mutable pointer in contexts where it needs to remain valid.
    ///
    /// - Parameter body: A closure that receives the mutable pointer and
    /// returns a value.
    /// - Returns: The value returned by the closure.
    mutating func withMutableCPointer<T>(
        _ body: (UnsafeMutablePointer<mpfr_t>) throws -> T
    ) rethrows -> T {
        _ensureUnique()
        return try withUnsafeMutablePointer(to: &_storage.value) { ptr in
            try body(ptr)
        }
    }

    // MARK: - Formatted I/O (C-style, lower-level)

    /// Write this float to a FileHandle using formatted output.
    ///
    /// Uses printf-style formatting. The format string follows the same
    /// conventions
    /// as C's `printf` for floating-point numbers, with MPFR-specific
    /// extensions.
    ///
    /// - Parameters:
    ///   - fileHandle: The FileHandle to write to. Must be open for writing.
    ///   - format: The format string. Must be a valid MPFR format string. The
    /// format
    ///     string can include rounding mode in %R?f syntax (e.g., %Rnf for
    /// nearest).
    ///     If rounding is not specified in the format string, MPFR's default
    /// rounding
    ///     mode is used.
    ///   - rounding: The rounding mode to use. Defaults to `.nearest`. Note:
    /// This
    ///     parameter may be ignored if the format string already specifies a
    /// rounding
    ///     mode using %R?f syntax.
    /// - Returns: The number of characters written, or a negative value on
    /// error.
    ///
    /// - Requires: This float must be properly initialized. `fileHandle` must
    /// be open
    ///   for writing. `format` must be a valid format string.
    /// - Guarantees: If successful, returns the number of characters written.
    ///   If an error occurs, returns a negative value.
    ///
    /// - Note: Wraps `mpfr_vfprintf`. Requires `stdio.h` to be included.
    public func fprintf(
        to fileHandle: FileHandle,
        format: String,
        rounding _: MPFRRoundingMode = .nearest
    ) -> Int {
        // Safely get file descriptor using helper that catches ObjC exceptions
        // This avoids crashes when FileHandle is closed
        let fd = withExtendedLifetime(fileHandle) {
            let unmanaged = Unmanaged.passUnretained(fileHandle)
            return clinus_safe_file_descriptor(unmanaged.toOpaque())
        }
        guard fd >= 0 else {
            // File descriptor is invalid (closed handle)
            return -1
        }

        // Convert file descriptor to FILE* using fdopen
        let mode = "w"
        guard let filePtr = fdopen(fd, mode) else {
            return -1
        }
        defer {
            // Don't close the FILE* - FileHandle owns the file descriptor
            // Just flush to ensure data is written
            fflush(filePtr)
        }

        // Validate format string contains at least one format specifier
        // MPFR format strings should contain %R?f, %R?e, %R?g, etc.
        guard format.contains("%") else {
            return -1
        }

        return format.withCString { formatPtr -> Int in
            return withCPointer { floatPtr -> Int in
                let result = Int(withVaList([floatPtr]) { vaList -> Int32 in
                    clinus_mpfr_vfprintf(filePtr, formatPtr, vaList)
                })
                // Check for errors - negative return indicates failure
                if result < 0 {
                    return -1
                }
                return result
            }
        }
    }

    /// Write this float to standard output using formatted output.
    ///
    /// - Parameters:
    ///   - format: The format string. Must be a valid MPFR format string. The
    /// format
    ///     string can include rounding mode in %R?f syntax (e.g., %Rnf for
    /// nearest).
    ///     If rounding is not specified in the format string, MPFR's default
    /// rounding
    ///     mode is used.
    ///   - rounding: The rounding mode to use. Defaults to `.nearest`. Note:
    /// This
    ///     parameter may be ignored if the format string already specifies a
    /// rounding
    ///     mode using %R?f syntax.
    /// - Returns: The number of characters written, or a negative value on
    /// error.
    ///
    /// - Requires: This float must be properly initialized. `format` must be a
    /// valid format string.
    /// - Guarantees: If successful, returns the number of characters written.
    ///
    /// - Note: Wraps `mpfr_vprintf`. Requires `stdio.h` to be included.
    public func printf(
        format: String,
        rounding _: MPFRRoundingMode = .nearest
    ) -> Int {
        // Validate format string contains at least one format specifier
        guard format.contains("%") else {
            return -1
        }

        return format.withCString { formatPtr -> Int in
            return withCPointer { floatPtr -> Int in
                let result = Int(withVaList([floatPtr]) { vaList -> Int32 in
                    clinus_mpfr_vprintf(formatPtr, vaList)
                })
                // Check for errors - negative return indicates failure
                if result < 0 {
                    return -1
                }
                return result
            }
        }
    }

    /// Create a float by reading from a FileHandle using formatted input.
    ///
    /// Reads a floating-point value from the FileHandle. Since MPFR does not
    /// provide
    /// scanf-style formatted input functions, this implementation reads a
    /// whitespace-separated
    /// token and parses it as a float.
    ///
    /// - Parameters:
    ///   - fileHandle: The FileHandle to read from. Must be open for reading.
    ///   - format: The format string (currently used as a hint; actual format
    /// parsing
    ///     is simplified since MPFR lacks scanf support).
    ///   - rounding: The rounding mode to use. Defaults to `.nearest`.
    /// - Returns: A new `MPFRFloat` if reading and parsing succeed, `nil`
    /// otherwise.
    ///
    /// - Requires: `fileHandle` must be open for reading.
    /// - Guarantees: If reading and parsing succeed, returns a valid
    /// `MPFRFloat` with
    ///   the parsed value. If reading fails or parsing fails, returns `nil`.
    ///
    /// - Note: MPFR does not provide scanf functions, so this reads and parses
    /// a string token.
    public init?(
        fileHandle: FileHandle,
        format: String,
        rounding: MPFRRoundingMode = .nearest
    ) {
        // Safely get file descriptor using helper that catches ObjC exceptions
        let fd = withExtendedLifetime(fileHandle) {
            let unmanaged = Unmanaged.passUnretained(fileHandle)
            return clinus_safe_file_descriptor(unmanaged.toOpaque())
        }
        guard fd >= 0 else {
            // File descriptor is invalid (closed handle)
            return nil
        }

        // Note: Since MPFR doesn't provide scanf functions, we can't validate
        // the format string against MPFR scanf format specifiers. We just parse
        // the string as a float. The format parameter is currently
        // informational.
        // Basic validation: format should not be empty
        guard !format.isEmpty else {
            return nil
        }

        // Read a line or whitespace-separated token from the file handle
        var line = ""
        var buffer = Data()
        let chunkSize = 1024

        while true {
            let data = fileHandle.readData(ofLength: chunkSize)
            if data.isEmpty {
                break
            }
            buffer.append(data)
            if let string = String(data: buffer, encoding: .utf8) {
                // Try to find first whitespace or end of string
                let trimmed = string.trimmingCharacters(in: .whitespaces)
                if !trimmed.isEmpty {
                    // Extract first token (up to whitespace)
                    let components = trimmed
                        .components(separatedBy: .whitespaces)
                    if let firstToken = components.first {
                        line = firstToken
                        break
                    }
                }
                // If no newline and more data might come, continue
                if string.contains("\n") {
                    let newlineIndex = string.firstIndex(of: "\n")!
                    line = String(string[..<newlineIndex])
                        .trimmingCharacters(in: .whitespaces)
                    break
                }
            }
        }

        if line.isEmpty, !buffer.isEmpty {
            if let string = String(data: buffer, encoding: .utf8) {
                line = string.trimmingCharacters(in: .whitespaces)
                // Extract first token
                let components = line.components(separatedBy: .whitespaces)
                if let firstToken = components.first {
                    line = firstToken
                }
            }
        }

        guard !line.isEmpty else {
            return nil
        }

        // Parse the token as a float
        // Note: Since MPFR doesn't have scanf, we can't validate the format
        // string.
        // We just parse the string as a float regardless of the format
        // parameter.
        self.init(string: line, precision: nil, rounding: rounding)
    }

    /// Create a float by reading from standard input using formatted input.
    ///
    /// Reads a floating-point value from stdin. Since MPFR does not provide
    /// scanf-style formatted input functions, this implementation reads a line
    /// and parses it.
    ///
    /// - Parameters:
    ///   - format: The format string (currently used as a hint; actual format
    /// parsing
    ///     is simplified since MPFR lacks scanf support).
    ///   - rounding: The rounding mode to use. Defaults to `.nearest`.
    /// - Returns: A new `MPFRFloat` if reading and parsing succeed, `nil`
    /// otherwise.
    ///
    /// - Requires: `format` must be a valid format string.
    /// - Guarantees: If reading and parsing succeed, returns a valid
    /// `MPFRFloat`.
    ///
    /// - Note: MPFR does not provide scanf functions, so this reads from stdin
    /// and parses a string.
    public init?(
        format: String,
        rounding: MPFRRoundingMode = .nearest
    ) {
        // Note: Since MPFR doesn't provide scanf functions, we can't validate
        // the format string against MPFR scanf format specifiers. We just parse
        // the string as a float. The format parameter is currently
        // informational.
        // Basic validation: format should not be empty
        guard !format.isEmpty else {
            return nil
        }

        // Read from stdin using FileHandle
        // Note: After stdin redirection (e.g., in tests),
        // FileHandle.standardInput
        // may reference the old file descriptor. Create a new FileHandle from
        // the current STDIN_FILENO to ensure we read from the redirected stdin.
        // This is necessary because FileHandle.standardInput is a singleton
        // that
        // caches the file descriptor at creation time.
        let stdinHandle = FileHandle(
            fileDescriptor: STDIN_FILENO,
            closeOnDealloc: false
        )

        // Use readData instead of availableData to avoid issues with
        // closed/invalid
        // file descriptors. availableData can throw
        // NSFileHandleOperationException
        // if the file descriptor is invalid. readData is safer and doesn't
        // throw
        // exceptions in the same way.
        let data = stdinHandle.readData(ofLength: 1024)

        guard !data.isEmpty,
              let line = String(data: data, encoding: .utf8)
        else {
            return nil
        }

        // Extract first whitespace-separated token
        let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return nil
        }

        let components = trimmed.components(separatedBy: .whitespaces)
        guard let firstToken = components.first else {
            return nil
        }

        // Parse the token as a float
        self.init(string: firstToken, precision: nil, rounding: rounding)
    }

    // MARK: - String Parsing with Position Tracking

    /// Parse a float from a string, returning the position after the parsed
    /// number.
    ///
    /// Similar to `strtod`, this function parses a floating-point number from a
    /// string
    /// and returns information about where parsing stopped.
    ///
    /// - Parameters:
    ///   - string: The string to parse. Must contain a valid floating-point
    /// number.
    ///   - base: The numeric base (radix) for parsing. Must be 0 or in the
    /// range 2-62.
    ///     Defaults to 10. If 0, the base is auto-detected from prefixes.
    ///   - precision: The precision in bits. If nil, uses default precision.
    ///   - rounding: The rounding mode to use. Defaults to `.nearest`.
    /// - Returns: A tuple `(result: MPFRFloat, endIndex: String.Index, ternary:
    /// Int)`
    ///   where `endIndex` points to the first character after the parsed
    /// number, or `nil`
    ///   if parsing fails.
    ///
    /// - Requires: `base` must be 0 or in the range 2-62. `string` must not be
    /// empty.
    /// - Guarantees: If parsing succeeds, returns the parsed value, the
    /// position after
    ///   the number, and a ternary value. If parsing fails, returns `nil`.
    ///
    /// - Note: Wraps `mpfr_strtofr`.
    public static func parse(
        _ string: String,
        base: Int = 10,
        precision: Int? = nil,
        rounding: MPFRRoundingMode = .nearest
    ) -> (result: MPFRFloat, endIndex: String.Index, ternary: Int)? {
        precondition(
            base == 0 || (base >= 2 && base <= 62),
            "base must be 0 or in the range 2-62"
        )
        guard !string.isEmpty else {
            return nil
        }

        // Initialize result with specified precision
        var result: MPFRFloat
        if let prec = precision {
            let precMin = Int(clinus_get_prec_min())
            let precMax = Int(clinus_get_prec_max())
            precondition(
                prec >= precMin && prec <= precMax,
                "precision must be between MPFR_PREC_MIN and MPFR_PREC_MAX"
            )
            result = MPFRFloat(precision: prec)
        } else {
            result = MPFRFloat()
        }

        let rnd = rounding.toMPFRRoundingMode()

        // Use mpfr_strtofr which returns end pointer
        // We need to compute the offset within the withCString closure
        var offset: Int?
        var ternary: Int32 = 0

        let parseResult = string.withCString { cString in
            // Directly access storage since result is a local variable
            withUnsafeMutablePointer(to: &result._storage.value) { floatPtr in
                var tempEndPtr: UnsafeMutablePointer<CChar>?
                let tern = mpfr_strtofr(
                    floatPtr,
                    cString,
                    &tempEndPtr,
                    Int32(base),
                    rnd
                )

                // Compute offset while cString is still valid
                if let endPtr = tempEndPtr {
                    // Convert both pointers to UnsafePointer for subtraction
                    let startPtr = UnsafePointer<CChar>(cString)
                    let endPtrImmutable = UnsafePointer<CChar>(endPtr)
                    let byteOffset = endPtrImmutable - startPtr
                    // Check that endPtr advanced past the start (indicates
                    // something was parsed)
                    if byteOffset > 0, byteOffset <= string.utf8.count {
                        offset = byteOffset
                    }
                }

                return tern
            }
        }
        ternary = parseResult

        // Check if parsing succeeded
        // mpfr_strtofr returns a ternary value (0, positive, or negative)
        guard let offset else {
            return nil
        }

        // Convert byte offset to String.Index
        guard let endIndex = string.utf8.index(
            string.startIndex,
            offsetBy: offset,
            limitedBy: string.endIndex
        ) else {
            return nil
        }

        return (result: result, endIndex: endIndex, ternary: Int(ternary))
    }
}
