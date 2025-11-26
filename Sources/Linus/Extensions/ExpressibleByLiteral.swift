// Import CKalliope first so gmp.h is available when CLinus imports mpfr.h
import CKalliope
import CLinus
import CLinusBridge
import Kalliope

/// ExpressibleByIntegerLiteral conformance for `MPFRFloat`.
///
/// Allows `MPFRFloat` values to be created from integer literals, enabling
/// syntax like `let x: MPFRFloat = 42`.
extension MPFRFloat: ExpressibleByIntegerLiteral {
    /// Create a float from an integer literal.
    ///
    /// - Parameter value: The integer literal value.
    ///
    /// - Requires: None
    /// - Guarantees: Returns a valid `MPFRFloat` with the exact value of
    /// `value`
    ///   (at default precision). Equivalent to `MPFRFloat(value)`.
    public init(integerLiteral value: Int) {
        self.init(value)
    }
}

/// ExpressibleByFloatLiteral conformance for `MPFRFloat`.
///
/// Allows `MPFRFloat` values to be created from floating-point literals,
/// enabling
/// syntax like `let x: MPFRFloat = 3.14`.
extension MPFRFloat: ExpressibleByFloatLiteral {
    /// Create a float from a floating-point literal.
    ///
    /// - Parameter value: The floating-point literal value.
    ///
    /// - Requires: `value` must not be infinite or NaN.
    /// - Guarantees: Returns a valid `MPFRFloat` approximating `value` at
    /// default precision.
    ///   Equivalent to `MPFRFloat(value)`.
    public init(floatLiteral value: Double) {
        self.init(value)
    }
}
