import CKalliope

/// Formatted I/O pointer accessors and convenience methods for `GMPFloat`.
///
/// This extension provides accessors to the underlying `mpf_t` structure for
/// use
/// with GMP's formatted I/O functions (printf/scanf style), as well as
/// convenience
/// methods for formatting.
extension GMPFloat {
    /// Execute a closure with a pointer to the underlying `mpf_t`, ensuring the
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
    func withCPointer<T>(_ body: (UnsafePointer<mpf_t>) throws -> T) rethrows
        -> T
    {
        try withUnsafePointer(to: _storage.value) { ptr in
            try body(ptr)
        }
    }

    /// Execute a closure with a mutable pointer to the underlying `mpf_t`,
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
        _ body: (UnsafeMutablePointer<mpf_t>) throws
            -> T
    ) rethrows -> T {
        _ensureUnique()
        return try withUnsafeMutablePointer(to: &_storage.value) { ptr in
            try body(ptr)
        }
    }

    // MARK: - Convenience Formatting

    /// Format this float using a GMP format string.
    ///
    /// This is a convenience method that calls
    /// `GMPFormattedIO.string(format:format, self)`.
    /// It provides a more ergonomic API than calling the static method
    /// directly.
    ///
    /// - Parameter format: A GMP format string (e.g., `"%Ff"`, `"%.2Ff"`,
    /// `"%Fe"`).
    /// - Returns: A formatted Swift `String`, or `nil` if formatting failed.
    ///
    /// - Example:
    ///   ```swift
    ///   let f = GMPFloat(3.14159)
    ///   let str = f.formatted("%.2Ff")  // Returns "3.14"
    ///   let sci = f.formatted("%Fe")  // Returns scientific notation
    ///   ```
    public func formatted(_ format: String) -> String? {
        GMPFormattedIO.string(format: format, self)
    }
}
