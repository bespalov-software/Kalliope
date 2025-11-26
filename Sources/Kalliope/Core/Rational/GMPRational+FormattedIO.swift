import CKalliope

/// Formatted I/O pointer accessors and convenience methods for `GMPRational`.
///
/// This extension provides accessors to the underlying `mpq_t` structure for
/// use
/// with GMP's formatted I/O functions (printf/scanf style), as well as
/// convenience
/// methods for formatting.
extension GMPRational {
    /// Execute a closure with a pointer to the underlying `mpq_t`, ensuring the
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
    public func withCPointer<T>(_ body: (UnsafePointer<mpq_t>) throws
        -> T) rethrows
        -> T
    {
        try withUnsafePointer(to: _storage.value) { ptr in
            try body(ptr)
        }
    }

    /// Execute a closure with a mutable pointer to the underlying `mpq_t`,
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
        _ body: (UnsafeMutablePointer<mpq_t>) throws
            -> T
    ) rethrows -> T {
        _ensureUnique()
        return try withUnsafeMutablePointer(to: &_storage.value) { ptr in
            try body(ptr)
        }
    }

    // MARK: - Convenience Formatting

    /// Format this rational using a GMP format string.
    ///
    /// This is a convenience method that calls
    /// `GMPFormattedIO.string(format:format, self)`.
    /// It provides a more ergonomic API than calling the static method
    /// directly.
    ///
    /// - Parameter format: A GMP format string (e.g., `"%Qd"`).
    /// - Returns: A formatted Swift `String`, or `nil` if formatting failed.
    ///
    /// - Example:
    ///   ```swift
    ///   let q = try GMPRational(numerator: 1, denominator: 2)
    ///   let str = q.formatted("%Qd")  // Returns "1/2"
    ///   ```
    public func formatted(_ format: String) -> String? {
        GMPFormattedIO.string(format: format, self)
    }
}
