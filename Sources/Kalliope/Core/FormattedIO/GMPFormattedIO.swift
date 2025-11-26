import CKalliope
import CKalliopeBridge
import Darwin // For FILE*
import Foundation

/// Helper function to convert C string pointer to Swift String
private func stringFromCString(_ ptr: UnsafePointer<CChar>) -> String {
    let length = strlen(ptr)
    let buffer = UnsafeBufferPointer(start: ptr, count: length)
    let data = Data(buffer.map { UInt8(bitPattern: $0) })
    return String(bytes: data, encoding: .utf8) ?? ""
}

// Swift-style API for GMP formatted I/O.
//
// All functions use variadic `Any...` parameters, similar to Swift's `print()`.
// This allows mixing GMP types and standard types in any combination.
// The `PointerCollector` class handles pointer lifetime management
// automatically.

/// Formatted I/O operations for GMP types.
///
/// Provides printf-style formatted output and scanf-style formatted input with
/// support for GMP-specific type specifiers:
/// - `%Zd` - GMPInteger (mpz_t)
/// - `%Qd` - GMPRational (mpq_t)
/// - `%Ff` - GMPFloat (mpf_t)
///
/// All standard C printf/scanf format specifiers are also supported and can be
/// freely intermixed.
public enum GMPFormattedIO {
    // MARK: - Print to Standard Output

    /// Print formatted output to standard output (stdout).
    ///
    /// Swift-style variadic function similar to `print()`. Accepts any
    /// combination
    /// of GMP types and standard types.
    ///
    /// - Parameters:
    ///   - format: Format string with C printf specifiers plus GMP extensions
    ///     (`%Zd` for GMPInteger, `%Qd` for GMPRational, `%Ff` for GMPFloat).
    ///   - args: Variadic arguments of any type (GMP types or standard CVarArg
    /// types).
    /// - Returns: Number of characters written, or -1 on error.
    ///
    /// Example:
    /// ```swift
    /// let z = GMPInteger(1234)
    /// let q = GMPRational(numerator: 1, denominator: 2)
    /// GMPFormattedIO.printf("z=%Zd, q=%Qd, n=%d\n", z, q, 42)
    /// ```
    public static func printf(_ format: String, _ args: Any...) -> Int {
        format.withCString { formatPtr in
            _withFormattedArgs(args) { cvArgs in
                Int(withVaList(cvArgs) { vaList in
                    ckalliope_vprintf(formatPtr, vaList)
                })
            }
        }
    }

    /// Internal helper to convert variadic arguments to CVarArg array.
    ///
    /// Handles both GMP types and standard types, ensuring GMP type pointers
    /// remain valid during the C call.
    ///
    /// **Critical**: The pointers from `withCPointer` are only valid within
    /// their
    /// closure. We use nested closures to collect all pointers and use them
    /// immediately, all within a single extended lifetime scope.
    ///
    /// **String Handling**: Swift `String` arguments must be converted to C
    /// string
    /// pointers for C `printf`'s `%s` format specifier. We convert strings and
    /// keep
    /// the C string pointers alive during the call.
    private static func _withFormattedArgs<T>(
        _ args: [Any],
        _ body: ([CVarArg]) -> T
    ) -> T {
        // First, collect all GMP types and Strings to keep them alive
        var gmpStorage: [Any] = []
        var stringStorage: [String] = []
        for arg in args {
            switch arg {
            case let z as GMPInteger:
                gmpStorage.append(z)
            case let q as GMPRational:
                gmpStorage.append(q)
            case let f as GMPFloat:
                gmpStorage.append(f)
            case let s as String:
                stringStorage.append(s)
            default:
                break
            }
        }

        // Use nested closures to collect all pointers and use them immediately
        // This ensures pointers remain valid throughout the entire operation
        return withExtendedLifetime((gmpStorage, stringStorage)) {
            // Helper to collect pointers recursively using nested closures
            func collectPointers(
                _ remaining: ArraySlice<Any>,
                _ collected: [CVarArg]
            ) -> T {
                guard let first = remaining.first else {
                    // All arguments processed, use the collected pointers
                    return body(collected)
                }

                let rest = remaining.dropFirst()

                switch first {
                case let z as GMPInteger:
                    return z.withCPointer { ptr in
                        collectPointers(rest, collected + [ptr])
                    }
                case let q as GMPRational:
                    return q.withCPointer { ptr in
                        collectPointers(rest, collected + [ptr])
                    }
                case let f as GMPFloat:
                    return f.withCPointer { ptr in
                        collectPointers(rest, collected + [ptr])
                    }
                case let s as String:
                    // Convert String to C string pointer - pointer valid within
                    // closure
                    return s.withCString { cStrPtr in
                        collectPointers(rest, collected + [cStrPtr])
                    }
                case let cvArg as CVarArg:
                    return collectPointers(rest, collected + [cvArg])
                default:
                    if let cvArg = first as? CVarArg {
                        return collectPointers(rest, collected + [cvArg])
                    } else {
                        fatalError(
                            "Unsupported type in formatted I/O: \(type(of: first))"
                        )
                    }
                }
            }

            return collectPointers(args[...], [])
        }
    }

    // MARK: - Print to File Stream

    /// Print formatted output to a file stream.
    ///
    /// - Parameters:
    ///   - stream: Pointer to a C FILE structure (must be open for writing).
    ///   - format: Format string with C printf specifiers plus GMP extensions.
    ///   - args: Variadic arguments of any type (GMP types or standard CVarArg
    /// types).
    /// - Returns: Number of characters written, or -1 on error.
    ///
    /// - Warning: **Unsafe**. Direct C FILE* access. Prefer Swift
    /// FileHandle-based APIs.
    public static func fprintf(
        _ stream: UnsafeMutablePointer<FILE>,
        _ format: String,
        _ args: Any...
    ) -> Int {
        format.withCString { formatPtr in
            _withFormattedArgs(args) { cvArgs in
                Int(withVaList(cvArgs) { vaList in
                    ckalliope_vfprintf(stream, formatPtr, vaList)
                })
            }
        }
    }

    // MARK: - Print to String Buffer

    /// Print formatted output to a string buffer.
    ///
    /// - Parameters:
    ///   - buffer: Pointer to a buffer large enough to hold the formatted
    /// string.
    ///   - format: Format string with C printf specifiers plus GMP extensions.
    ///   - args: Variadic arguments of any type (GMP types or standard CVarArg
    /// types).
    /// - Returns: Number of characters written (excluding null terminator), or
    /// -1 on error.
    ///
    /// - Warning: **Unsafe** - no buffer overflow protection. Use `snprintf`
    /// for safer operation.
    public static func sprintf(
        _ buffer: UnsafeMutablePointer<CChar>,
        _ format: String,
        _ args: Any...
    ) -> Int {
        format.withCString { formatPtr in
            _withFormattedArgs(args) { cvArgs in
                Int(withVaList(cvArgs) { vaList in
                    ckalliope_vsprintf(buffer, formatPtr, vaList)
                })
            }
        }
    }

    /// Print formatted output to a string buffer with size limit.
    ///
    /// - Parameters:
    ///   - buffer: Pointer to a buffer.
    ///   - size: Maximum number of characters to write (including null
    /// terminator).
    ///   - format: Format string with C printf specifiers plus GMP extensions.
    ///   - args: Variadic arguments of any type (GMP types or standard CVarArg
    /// types).
    /// - Returns: Number of characters that would be written (excluding null
    /// terminator)
    ///   if size were unlimited, or -1 on error. If return value >= size,
    /// output was truncated.
    public static func snprintf(
        _ buffer: UnsafeMutablePointer<CChar>,
        _ size: Int,
        _ format: String,
        _ args: Any...
    ) -> Int {
        format.withCString { formatPtr in
            _withFormattedArgs(args) { cvArgs in
                Int(withVaList(cvArgs) { vaList in
                    ckalliope_vsnprintf(buffer, size, formatPtr, vaList)
                })
            }
        }
    }

    // MARK: - Print to Allocated String

    /// Print formatted output to an allocated string.
    ///
    /// - Parameters:
    ///   - format: Format string with C printf specifiers plus GMP extensions.
    ///   - args: Variadic arguments of any type (GMP types or standard CVarArg
    /// types).
    /// - Returns: Tuple containing allocated pointer and character count, or
    /// `nil` on error.
    ///   The caller **must** free the returned pointer using `free()`.
    ///
    /// - Warning: **Memory Management** - Caller is responsible for freeing the
    /// pointer.
    ///   Use `string(format:)` for automatic memory management.
    public static func asprintf(
        _ format: String,
        _ args: Any...
    ) -> (UnsafeMutablePointer<CChar>, Int)? {
        format.withCString { formatPtr in
            _withFormattedArgs(args) { cvArgs in
                var resultPtr: UnsafeMutablePointer<CChar>?
                let count = withVaList(cvArgs) { vaList in
                    ckalliope_vasprintf(&resultPtr, formatPtr, vaList)
                }
                guard count >= 0, let ptr = resultPtr else { return nil }
                return (ptr, Int(count))
            }
        }
    }

    /// Format a string with GMP types, automatically managing memory.
    ///
    /// This is the recommended Swift API for formatted output. It handles
    /// memory
    /// allocation and deallocation automatically, returning a Swift `String` or
    /// `nil` on error.
    ///
    /// - Parameters:
    ///   - format: Format string with C printf specifiers plus GMP extensions.
    ///   - args: Variadic arguments of any type (GMP types or standard CVarArg
    /// types).
    /// - Returns: Formatted Swift `String`, or `nil` if formatting failed.
    ///
    /// Example:
    /// ```swift
    /// let z = GMPInteger(1234)
    /// let q = GMPRational(numerator: 1, denominator: 2)
    /// let result = GMPFormattedIO.string(format: "z=%Zd, q=%Qd", z, q)
    /// // result == "z=1234, q=1/2"
    /// ```
    public static func string(format: String, _ args: Any...) -> String? {
        guard let (ptr, _) = asprintf(format, args) else { return nil }
        defer { free(ptr) }
        return stringFromCString(ptr)
    }

    // MARK: - Read from String

    /// Read formatted input from a string.
    ///
    /// - Parameters:
    ///   - string: Input string to parse.
    ///   - format: Format string with C scanf specifiers plus GMP extensions.
    ///   - args: Variadic arguments (pointers) matching the format specifiers.
    ///     For GMP types, use `withMutableCPointer` to get pointers.
    /// - Returns: Number of fields successfully parsed, or EOF on error.
    ///
    /// Example:
    /// ```swift
    /// var z = GMPInteger()
    /// z.withMutableCPointer { ptr in
    ///     let count = GMPFormattedIO.sscanf("Value: 1234", "Value: %Zd", ptr)
    /// }
    /// ```
    public static func sscanf(
        _ string: String,
        _ format: String,
        _ args: CVarArg...
    ) -> Int {
        string.withCString { strPtr in
            format.withCString { fmtPtr in
                Int(withVaList(args) { vaList in
                    ckalliope_vsscanf(strPtr, fmtPtr, vaList)
                })
            }
        }
    }

    // MARK: - Read from File Stream

    /// Read formatted input from a file stream.
    ///
    /// - Parameters:
    ///   - stream: Pointer to a C FILE structure (must be open for reading).
    ///   - format: Format string with C scanf specifiers plus GMP extensions.
    ///   - args: Variadic arguments (pointers) matching the format specifiers.
    ///     For GMP types, use `withMutableCPointer` to get pointers.
    /// - Returns: Number of fields successfully parsed, or EOF if end of input
    ///   is reached before any field is matched.
    ///
    /// Example:
    /// ```swift
    /// let file = fopen("input.txt", "r")
    /// var z = GMPInteger()
    /// z.withMutableCPointer { ptr in
    ///     let count = GMPFormattedIO.fscanf(file, "Value: %Zd\n", ptr)
    /// }
    /// fclose(file)
    /// ```
    public static func fscanf(
        _ stream: UnsafeMutablePointer<FILE>,
        _ format: String,
        _ args: CVarArg...
    ) -> Int {
        format.withCString { fmtPtr in
            Int(withVaList(args) { vaList in
                ckalliope_vfscanf(stream, fmtPtr, vaList)
            })
        }
    }

    // MARK: - Read from Standard Input

    /// Read formatted input from standard input (stdin).
    ///
    /// - Parameters:
    ///   - format: Format string with C scanf specifiers plus GMP extensions.
    ///   - args: Variadic arguments (pointers) matching the format specifiers.
    ///     For GMP types, use `withMutableCPointer` to get pointers.
    /// - Returns: Number of fields successfully parsed, or EOF if end of input
    ///   is reached before any field is matched.
    ///
    /// Example:
    /// ```swift
    /// var z = GMPInteger()
    /// z.withMutableCPointer { ptr in
    ///     let count = GMPFormattedIO.scanf("Value: %Zd\n", ptr)
    /// }
    /// ```
    public static func scanf(
        _ format: String,
        _ args: CVarArg...
    ) -> Int {
        format.withCString { fmtPtr in
            Int(withVaList(args) { vaList in
                ckalliope_vscanf(fmtPtr, vaList)
            })
        }
    }
}
