import CKalliope

/// Hashable conformance for `GMPInteger`.
///
/// The hash value is based on the integer's value, not its internal
/// representation.
/// Two integers with the same value will have the same hash value.
extension GMPInteger: Hashable {
    /// Hash the integer into the provided hasher.
    ///
    /// - Parameter hasher: The hasher to use for combining hash values.
    ///
    /// - Requires: This integer must be properly initialized.
    /// - Guarantees: The hash value is based on the integer's value. Two
    /// integers
    ///   with the same value will produce the same hash value.
    public func hash(into hasher: inout Hasher) {
        // Hash the underlying limb representation directly for efficiency
        // This is much faster than string conversion and works for arbitrary
        // precision
        let count = limbCount
        hasher.combine(count)

        // Hash sign (0 for non-negative, 1 for negative)
        let sign: UInt8 = isNegative ? 1 : 0
        hasher.combine(sign)

        // Hash all limbs directly
        let limbs = limbsRead
        for i in 0 ..< count {
            hasher.combine(limbs[i])
        }
    }
}

// MARK: - CustomStringConvertible Conformance

extension GMPInteger: CustomStringConvertible {
    /// A textual representation of this integer.
    ///
    /// Returns the decimal string representation of the integer.
    public var description: String {
        toString()
    }
}
