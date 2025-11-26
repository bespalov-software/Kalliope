import CKalliope

/// Formatted I/O pointer accessors and convenience methods for `GMPInteger`.
///
/// This extension provides accessors to the underlying `mpz_t` structure for
/// use
/// with GMP's formatted I/O functions (printf/scanf style), as well as
/// convenience
/// methods for formatting.
extension GMPInteger {
    /// Execute a closure with a pointer to the underlying `mpz_t`, ensuring the
    /// pointer
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
    ///
    /// - Example:
    ///   ```swift
    ///   let z = GMPInteger(42)
    ///   z.withCPointer { ptr in
    ///       withVaList([ptr]) { vaList in
    ///           // Use vaList safely here
    ///       }
    ///   }
    ///   ```
    public func withCPointer<T>(_ body: (UnsafePointer<mpz_t>) throws
        -> T) rethrows
        -> T
    {
        try withUnsafePointer(to: _storage.value) { ptr in
            try body(ptr)
        }
    }

    /// Execute a closure with a mutable pointer to the underlying `mpz_t`,
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
    public mutating func withMutableCPointer<T>(
        _ body: (UnsafeMutablePointer<mpz_t>) throws
            -> T
    ) rethrows -> T {
        _ensureUnique()
        return try withUnsafeMutablePointer(to: &_storage.value) { ptr in
            try body(ptr)
        }
    }

    // MARK: - Convenience Formatting

    /// Format this integer using a GMP format string.
    ///
    /// This is a convenience method that calls
    /// `GMPFormattedIO.string(format:format, self)`.
    /// It provides a more ergonomic API than calling the static method
    /// directly.
    ///
    /// - Parameter format: A GMP format string (e.g., `"%Zd"`, `"%#Zx"`,
    /// `"%10Zd"`).
    /// - Returns: A formatted Swift `String`, or `nil` if formatting failed.
    ///
    /// - Example:
    ///   ```swift
    ///   let z = GMPInteger(255)
    ///   let hex = z.formatted("%#Zx")  // Returns "0xff"
    ///   let padded = z.formatted("%10Zd")  // Returns "       255"
    ///   ```
    public func formatted(_ format: String) -> String? {
        GMPFormattedIO.string(format: format, self)
    }
}
