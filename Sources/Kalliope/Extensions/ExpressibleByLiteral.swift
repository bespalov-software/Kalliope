import CKalliope

/// ExpressibleByIntegerLiteral conformance for `GMPInteger`.
///
/// Allows `GMPInteger` values to be created from integer literals, enabling
/// syntax like `let x: GMPInteger = 42`.
extension GMPInteger: ExpressibleByIntegerLiteral {
    /// Create an integer from an integer literal.
    ///
    /// - Parameter value: The integer literal value.
    ///
    /// - Requires: None
    /// - Guarantees: Returns a valid `GMPInteger` with the exact value of
    /// `value`.
    ///   Equivalent to `GMPInteger(value)`.
    public init(integerLiteral value: Int) {
        self.init(value)
    }
}

/// ExpressibleByIntegerLiteral conformance for `GMPRational`.
///
/// Allows `GMPRational` values to be created from integer literals, enabling
/// syntax like `let x: GMPRational = 42` (which creates 42/1).
extension GMPRational: ExpressibleByIntegerLiteral {
    /// Create a rational from an integer literal.
    ///
    /// Creates a rational with value `value/1`.
    ///
    /// - Parameter value: The integer literal value.
    ///
    /// - Requires: None
    /// - Guarantees: Returns a valid `GMPRational` with value `value/1`
    /// (canonicalized).
    ///   Equivalent to `GMPRational(value)`.
    public init(integerLiteral value: Int) {
        // Create from Int by converting to GMPInteger first
        let intValue = GMPInteger(value)
        self.init(intValue)
    }
}

/// ExpressibleByIntegerLiteral conformance for `GMPFloat`.
///
/// Allows `GMPFloat` values to be created from integer literals, enabling
/// syntax like `let x: GMPFloat = 42`.
extension GMPFloat: ExpressibleByIntegerLiteral {
    /// Create a float from an integer literal.
    ///
    /// - Parameter value: The integer literal value.
    ///
    /// - Requires: None
    /// - Guarantees: Returns a valid `GMPFloat` with the exact value of `value`
    ///   (at default precision). Equivalent to `GMPFloat(value)`.
    public init(integerLiteral value: Int) {
        self.init(value)
    }
}

/// ExpressibleByFloatLiteral conformance for `GMPRational`.
///
/// Allows `GMPRational` values to be created from floating-point literals,
/// enabling
/// syntax like `let x: GMPRational = 3.14`. The conversion may be approximate.
extension GMPRational: ExpressibleByFloatLiteral {
    /// Create a rational from a floating-point literal.
    ///
    /// Converts the floating-point value to a rational number. The conversion
    /// may
    /// be approximate depending on the precision of the double.
    ///
    /// - Parameter value: The floating-point literal value.
    ///
    /// - Requires: `value` must not be infinite or NaN.
    /// - Guarantees: Returns a valid `GMPRational` approximating `value`.
    ///   Equivalent to `GMPRational(value)`.
    public init(floatLiteral value: Double) {
        self.init(value)
    }
}

/// ExpressibleByFloatLiteral conformance for `GMPFloat`.
///
/// Allows `GMPFloat` values to be created from floating-point literals,
/// enabling
/// syntax like `let x: GMPFloat = 3.14`.
extension GMPFloat: ExpressibleByFloatLiteral {
    /// Create a float from a floating-point literal.
    ///
    /// - Parameter value: The floating-point literal value.
    ///
    /// - Requires: `value` must not be infinite or NaN.
    /// - Guarantees: Returns a valid `GMPFloat` approximating `value` at
    /// default precision.
    ///   Equivalent to `GMPFloat(value)`.
    public init(floatLiteral value: Double) {
        self.init(value)
    }
}
