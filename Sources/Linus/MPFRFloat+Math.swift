// Import CKalliope first so gmp.h is available when CLinus imports mpfr.h
import CKalliope
import CLinus
import CLinusBridge
import Kalliope

// MARK: - Mathematical Functions

/// Mathematical functions for `MPFRFloat`.
///
/// All mathematical functions use the precision of the destination float and
/// support
/// explicit rounding modes. All operations return a ternary value indicating
/// the
/// rounding direction: 0 if exact, positive if rounded up, negative if rounded
/// down.
extension MPFRFloat {
    // MARK: - Flag Checking Helper

    /// Check MPFR flags after an operation and throw if exceptions occurred.
    ///
    /// This function checks MPFR exception flags and throws an `MPFRError`
    /// OptionSet containing all exception flags that were set.
    ///
    /// Multiple flags can be set simultaneously (flags are bit-maskable). This
    /// function returns all set flags as an OptionSet, allowing callers to
    /// check
    /// for multiple exceptions at once.
    ///
    /// - Throws: `MPFRError` OptionSet containing all exception flags that were
    ///   set (underflow, overflow, NaN, divide-by-zero, or range error).
    private static func checkFlagsAndThrow() throws {
        // Check all exception flags (excluding INEXACT)
        let exceptionFlags: mpfr_flags_t = UInt32(MPFR_FLAGS_UNDERFLOW) |
            UInt32(MPFR_FLAGS_OVERFLOW) |
            UInt32(MPFR_FLAGS_NAN) |
            UInt32(MPFR_FLAGS_ERANGE) |
            UInt32(MPFR_FLAGS_DIVBY0)

        let flags = mpfr_flags_test(exceptionFlags)

        // If no exception flags are set, return early
        guard flags != 0 else { return }

        // Convert MPFR flags to MPFRError OptionSet
        throw MPFRError(rawValue: flags)
    }

    // MARK: - Square Root

    /// Get the square root of this float.
    ///
    /// Computes the square root using the precision of this float. If the value
    /// is negative,
    /// the result is NaN.
    ///
    /// - Parameter rounding: The rounding mode to use. Defaults to `.nearest`.
    /// - Returns: A new `MPFRFloat` with the square root, and a ternary value.
    ///
    /// - Requires: This float must be properly initialized. The value must be
    /// non-negative.
    /// - Guarantees: Returns a new `MPFRFloat` with the square root, rounded to
    /// `self`'s precision.
    ///   `self` is unchanged. If the value is negative, returns NaN.
    ///
    /// - Note: Wraps `mpfr_sqrt`.
    public func squareRoot(rounding: MPFRRoundingMode = .nearest)
        -> (result: MPFRFloat, ternary: Int)
    {
        let result =
            MPFRFloat(precision: precision) // Mutated through pointer below
        let rnd = rounding.toMPFRRoundingMode()
        let ternary = mpfr_sqrt(&result._storage.value, &_storage.value, rnd)
        return (result: result, ternary: Int(ternary))
    }

    /// Replace this float with its square root in place.
    ///
    /// - Parameter rounding: The rounding mode to use. Defaults to `.nearest`.
    /// - Returns: A ternary value indicating the rounding direction.
    ///
    /// - Requires: This float must be properly initialized. The value must be
    /// non-negative.
    /// - Guarantees: After this call, `self` equals the square root of `self`
    /// (before the call),
    ///   rounded to `self`'s precision. If the value was negative, `self` is
    /// set to NaN.
    ///
    /// - Note: Wraps `mpfr_sqrt`.
    @discardableResult
    public mutating func formSquareRoot(rounding: MPFRRoundingMode = .nearest)
        -> Int
    {
        // Use immutable squareRoot() + assignment pattern to avoid exclusivity
        // violations
        let (result, ternary) = squareRoot(rounding: rounding)
        self = result
        return ternary
    }

    /// Compute the square root of an integer.
    ///
    /// - Parameters:
    ///   - value: The integer value. Must be non-negative.
    ///   - precision: The precision in bits. If nil, uses default precision.
    ///   - rounding: The rounding mode to use. Defaults to `.nearest`.
    /// - Returns: A new `MPFRFloat` with the square root, and a ternary value.
    ///
    /// - Requires: `value` must be non-negative.
    /// - Guarantees: Returns a new `MPFRFloat` with the square root.
    ///
    /// - Note: Wraps `mpfr_sqrt_ui`.
    public static func squareRoot(
        of value: UInt,
        precision: Int? = nil,
        rounding: MPFRRoundingMode = .nearest
    ) -> (result: MPFRFloat, ternary: Int) {
        let result: MPFRFloat
        if let prec = precision {
            let precMin = Int(clinus_get_prec_min())
            let precMax = Int(clinus_get_prec_max())
            precondition(
                prec >= precMin && prec <= precMax,
                "precision must be between MPFR_PREC_MIN and MPFR_PREC_MAX"
            )
            result = MPFRFloat(precision: prec)
        } else {
            let defaultPrec = mpfr_get_default_prec()
            result = MPFRFloat(precision: Int(defaultPrec))
        }
        let rnd = rounding.toMPFRRoundingMode()
        let ternary = mpfr_sqrt_ui(
            &result._storage.value,
            CUnsignedLong(value),
            rnd
        )
        return (result: result, ternary: Int(ternary))
    }

    // MARK: - Power Functions

    /// Raise this float to the power of `exponent`.
    ///
    /// Computes `self^exponent` using the precision of this float.
    ///
    /// - Parameters:
    ///   - exponent: The exponent (unsigned integer).
    ///   - rounding: The rounding mode to use. Defaults to `.nearest`.
    /// - Returns: A new `MPFRFloat` equal to `self^exponent`, and a ternary
    /// value.
    ///
    /// - Requires: This float must be properly initialized.
    /// - Guarantees: Returns a new `MPFRFloat` with the result, rounded to
    /// `self`'s precision.
    ///   `self` is unchanged.
    ///
    /// - Note: Wraps `mpfr_pow_ui`.
    public func raisedToPower(
        _ exponent: UInt,
        rounding: MPFRRoundingMode = .nearest
    ) -> (result: MPFRFloat, ternary: Int) {
        let result =
            MPFRFloat(precision: precision) // Mutated through pointer below
        let rnd = rounding.toMPFRRoundingMode()
        let ternary = mpfr_pow_ui(
            &result._storage.value,
            &_storage.value,
            CUnsignedLong(exponent),
            rnd
        )
        return (result: result, ternary: Int(ternary))
    }

    /// Raise this float to the power of a signed integer exponent.
    ///
    /// Computes `self^exponent` using the precision of this float. If
    /// `exponent` is negative,
    /// computes `1 / self^|exponent|`.
    ///
    /// - Parameters:
    ///   - exponent: The exponent (signed integer).
    ///   - rounding: The rounding mode to use. Defaults to `.nearest`.
    /// - Returns: A new `MPFRFloat` equal to `self^exponent`, and a ternary
    /// value.
    ///
    /// - Requires: This float must be properly initialized. If `exponent` is
    /// negative, `self` must not be zero.
    /// - Guarantees: Returns a new `MPFRFloat` with the result, rounded to
    /// `self`'s precision.
    ///
    /// - Note: Wraps `mpfr_pow_si`.
    public func raisedToPower(
        _ exponent: Int,
        rounding: MPFRRoundingMode = .nearest
    ) -> (result: MPFRFloat, ternary: Int) {
        let result =
            MPFRFloat(precision: precision) // Mutated through pointer below
        let rnd = rounding.toMPFRRoundingMode()
        let ternary = mpfr_pow_si(
            &result._storage.value,
            &_storage.value,
            CLong(exponent),
            rnd
        )
        return (result: result, ternary: Int(ternary))
    }

    /// Raise this float to the power of another float.
    ///
    /// Computes `self^other` using the precision of this float.
    ///
    /// - Parameters:
    ///   - other: The exponent (float).
    ///   - rounding: The rounding mode to use. Defaults to `.nearest`.
    /// - Returns: A new `MPFRFloat` equal to `self^other`, and a ternary value.
    ///
    /// - Requires: Both floats must be properly initialized.
    /// - Guarantees: Returns a new `MPFRFloat` with the result, rounded to
    /// `self`'s precision.
    ///
    /// - Note: Wraps `mpfr_pow`.
    public func raisedToPower(
        _ other: MPFRFloat,
        rounding: MPFRRoundingMode = .nearest
    ) -> (result: MPFRFloat, ternary: Int) {
        let result =
            MPFRFloat(precision: precision) // Mutated through pointer below
        let rnd = rounding.toMPFRRoundingMode()
        let ternary = mpfr_pow(
            &result._storage.value,
            &_storage.value,
            &other._storage.value,
            rnd
        )
        return (result: result, ternary: Int(ternary))
    }

    /// Replace this float with its value raised to the power of `exponent` in
    /// place.
    ///
    /// - Parameters:
    ///   - exponent: The exponent (unsigned integer).
    ///   - rounding: The rounding mode to use. Defaults to `.nearest`.
    /// - Returns: A ternary value indicating the rounding direction.
    ///
    /// - Requires: This float must be properly initialized.
    /// - Guarantees: After this call, `self` equals `self^exponent` (before the
    /// call),
    ///   rounded to `self`'s precision.
    ///
    /// - Note: Wraps `mpfr_pow_ui`.
    @discardableResult
    public mutating func formRaisedToPower(
        _ exponent: UInt,
        rounding: MPFRRoundingMode = .nearest
    ) -> Int {
        // Use immutable raisedToPower() + assignment pattern to avoid
        // exclusivity violations
        let (result, ternary) = raisedToPower(exponent, rounding: rounding)
        self = result
        return ternary
    }

    // MARK: - Exponential and Logarithmic Functions

    /// Compute the exponential function e^x.
    ///
    /// - Parameter rounding: The rounding mode to use. Defaults to `.nearest`.
    /// - Returns: A new `MPFRFloat` equal to e^self, and a ternary value.
    ///
    /// - Requires: This float must be properly initialized.
    /// - Guarantees: Returns a new `MPFRFloat` with e^self, rounded to `self`'s
    /// precision.
    ///
    /// - Note: Wraps `mpfr_exp`.
    ///
    /// - Throws: `MPFRError` if an exception occurs during the operation
    ///   (underflow, overflow, NaN, divide-by-zero, or range error).
    public func exp(rounding: MPFRRoundingMode = .nearest) throws
        -> (result: MPFRFloat, ternary: Int)
    {
        // Clear flags before operation to prevent assertion failures in
        // internal mpfr_agm() calls and to isolate this operation's exceptions
        mpfr_clear_flags()
        let result =
            MPFRFloat(precision: precision) // Mutated through pointer below
        let rnd = rounding.toMPFRRoundingMode()
        let ternary = mpfr_exp(&result._storage.value, &_storage.value, rnd)

        // Check flags after operation and throw if exceptions occurred
        try Self.checkFlagsAndThrow()

        return (result: result, ternary: Int(ternary))
    }

    /// Compute the natural logarithm (base e).
    ///
    /// - Parameter rounding: The rounding mode to use. Defaults to `.nearest`.
    /// - Returns: A new `MPFRFloat` equal to ln(self), and a ternary value.
    ///
    /// - Requires: This float must be properly initialized. The value must be
    /// positive.
    /// - Guarantees: Returns a new `MPFRFloat` with ln(self). If self <= 0,
    /// returns NaN or -Inf.
    ///
    /// - Note: Wraps `mpfr_log`.
    ///
    /// - Throws: `MPFRError` if an exception occurs during the operation
    ///   (underflow, overflow, NaN, divide-by-zero, or range error).
    public func log(rounding: MPFRRoundingMode = .nearest) throws
        -> (result: MPFRFloat, ternary: Int)
    {
        // Clear flags before operation to prevent assertion failures in
        // internal mpfr_agm() calls and to isolate this operation's exceptions
        mpfr_clear_flags()
        let result =
            MPFRFloat(precision: precision) // Mutated through pointer below
        let rnd = rounding.toMPFRRoundingMode()
        let ternary = mpfr_log(&result._storage.value, &_storage.value, rnd)

        // Check flags after operation and throw if exceptions occurred
        try Self.checkFlagsAndThrow()

        return (result: result, ternary: Int(ternary))
    }

    /// Compute the base-2 logarithm.
    ///
    /// - Parameter rounding: The rounding mode to use. Defaults to `.nearest`.
    /// - Returns: A new `MPFRFloat` equal to log₂(self), and a ternary value.
    ///
    /// - Requires: This float must be properly initialized. The value must be
    /// positive.
    /// - Guarantees: Returns a new `MPFRFloat` with log₂(self).
    ///
    /// - Note: Wraps `mpfr_log2`.
    ///
    /// - Throws: `MPFRError` if an exception occurs during the operation
    ///   (underflow, overflow, NaN, divide-by-zero, or range error).
    public func log2(rounding: MPFRRoundingMode = .nearest) throws
        -> (result: MPFRFloat, ternary: Int)
    {
        // Clear flags before operation to prevent assertion failures in
        // internal mpfr_agm() calls and to isolate this operation's exceptions
        mpfr_clear_flags()
        let result =
            MPFRFloat(precision: precision) // Mutated through pointer below
        let rnd = rounding.toMPFRRoundingMode()
        let ternary = mpfr_log2(&result._storage.value, &_storage.value, rnd)

        // Check flags after operation and throw if exceptions occurred
        try Self.checkFlagsAndThrow()

        return (result: result, ternary: Int(ternary))
    }

    /// Compute the base-10 logarithm.
    ///
    /// - Parameter rounding: The rounding mode to use. Defaults to `.nearest`.
    /// - Returns: A new `MPFRFloat` equal to log₁₀(self), and a ternary value.
    ///
    /// - Requires: This float must be properly initialized. The value must be
    /// positive.
    /// - Guarantees: Returns a new `MPFRFloat` with log₁₀(self).
    ///
    /// - Note: Wraps `mpfr_log10`.
    ///
    /// - Throws: `MPFRError` if an exception occurs during the operation
    ///   (underflow, overflow, NaN, divide-by-zero, or range error).
    public func log10(rounding: MPFRRoundingMode = .nearest) throws
        -> (result: MPFRFloat, ternary: Int)
    {
        // Clear flags before operation to prevent assertion failures in
        // internal mpfr_agm() calls and to isolate this operation's exceptions
        mpfr_clear_flags()
        let result =
            MPFRFloat(precision: precision) // Mutated through pointer below
        let rnd = rounding.toMPFRRoundingMode()
        let ternary = mpfr_log10(&result._storage.value, &_storage.value, rnd)

        // Check flags after operation and throw if exceptions occurred
        try Self.checkFlagsAndThrow()

        return (result: result, ternary: Int(ternary))
    }

    // MARK: - Trigonometric Functions

    /// Compute the sine function.
    ///
    /// - Parameter rounding: The rounding mode to use. Defaults to `.nearest`.
    /// - Returns: A new `MPFRFloat` equal to sin(self), and a ternary value.
    ///
    /// - Requires: This float must be properly initialized.
    /// - Guarantees: Returns a new `MPFRFloat` with sin(self), rounded to
    /// `self`'s precision.
    ///
    /// - Note: Wraps `mpfr_sin`.
    public func sin(rounding: MPFRRoundingMode = .nearest)
        -> (result: MPFRFloat, ternary: Int)
    {
        let result =
            MPFRFloat(precision: precision) // Mutated through pointer below
        let rnd = rounding.toMPFRRoundingMode()
        let ternary = mpfr_sin(&result._storage.value, &_storage.value, rnd)
        return (result: result, ternary: Int(ternary))
    }

    /// Compute the cosine function.
    ///
    /// - Parameter rounding: The rounding mode to use. Defaults to `.nearest`.
    /// - Returns: A new `MPFRFloat` equal to cos(self), and a ternary value.
    ///
    /// - Requires: This float must be properly initialized.
    /// - Guarantees: Returns a new `MPFRFloat` with cos(self), rounded to
    /// `self`'s precision.
    ///
    /// - Note: Wraps `mpfr_cos`.
    public func cos(rounding: MPFRRoundingMode = .nearest)
        -> (result: MPFRFloat, ternary: Int)
    {
        let result =
            MPFRFloat(precision: precision) // Mutated through pointer below
        let rnd = rounding.toMPFRRoundingMode()
        let ternary = mpfr_cos(&result._storage.value, &_storage.value, rnd)
        return (result: result, ternary: Int(ternary))
    }

    /// Compute both sine and cosine simultaneously.
    ///
    /// - Parameter rounding: The rounding mode to use. Defaults to `.nearest`.
    /// - Returns: A tuple `(sin: MPFRFloat, cos: MPFRFloat, ternary: Int)`.
    ///
    /// - Requires: This float must be properly initialized.
    /// - Guarantees: Returns both sin(self) and cos(self), rounded to `self`'s
    /// precision.
    ///
    /// - Note: Wraps `mpfr_sin_cos`.
    public func sinCos(rounding: MPFRRoundingMode = .nearest)
        -> (sin: MPFRFloat, cos: MPFRFloat, ternary: Int)
    {
        let sinResult =
            MPFRFloat(precision: precision) // Mutated through pointer below
        let cosResult =
            MPFRFloat(precision: precision) // Mutated through pointer below
        let rnd = rounding.toMPFRRoundingMode()
        let ternary = mpfr_sin_cos(
            &sinResult._storage.value,
            &cosResult._storage.value,
            &_storage.value,
            rnd
        )
        return (sin: sinResult, cos: cosResult, ternary: Int(ternary))
    }

    /// Compute the tangent function.
    ///
    /// - Parameter rounding: The rounding mode to use. Defaults to `.nearest`.
    /// - Returns: A new `MPFRFloat` equal to tan(self), and a ternary value.
    ///
    /// - Requires: This float must be properly initialized.
    /// - Guarantees: Returns a new `MPFRFloat` with tan(self), rounded to
    /// `self`'s precision.
    ///
    /// - Note: Wraps `mpfr_tan`.
    public func tan(rounding: MPFRRoundingMode = .nearest)
        -> (result: MPFRFloat, ternary: Int)
    {
        let result =
            MPFRFloat(precision: precision) // Mutated through pointer below
        let rnd = rounding.toMPFRRoundingMode()
        let ternary = mpfr_tan(&result._storage.value, &_storage.value, rnd)
        return (result: result, ternary: Int(ternary))
    }

    /// Compute the arcsine function.
    ///
    /// - Parameter rounding: The rounding mode to use. Defaults to `.nearest`.
    /// - Returns: A new `MPFRFloat` equal to arcsin(self), and a ternary value.
    ///
    /// - Requires: This float must be properly initialized. The value must be
    /// in [-1, 1].
    /// - Guarantees: Returns a new `MPFRFloat` with arcsin(self). If |self| >
    /// 1, returns NaN.
    ///
    /// - Note: Wraps `mpfr_asin`.
    public func asin(rounding: MPFRRoundingMode = .nearest)
        -> (result: MPFRFloat, ternary: Int)
    {
        let result =
            MPFRFloat(precision: precision) // Mutated through pointer below
        let rnd = rounding.toMPFRRoundingMode()
        let ternary = mpfr_asin(&result._storage.value, &_storage.value, rnd)
        return (result: result, ternary: Int(ternary))
    }

    /// Compute the arccosine function.
    ///
    /// - Parameter rounding: The rounding mode to use. Defaults to `.nearest`.
    /// - Returns: A new `MPFRFloat` equal to arccos(self), and a ternary value.
    ///
    /// - Requires: This float must be properly initialized. The value must be
    /// in [-1, 1].
    /// - Guarantees: Returns a new `MPFRFloat` with arccos(self). If |self| >
    /// 1, returns NaN.
    ///
    /// - Note: Wraps `mpfr_acos`.
    public func acos(rounding: MPFRRoundingMode = .nearest)
        -> (result: MPFRFloat, ternary: Int)
    {
        let result =
            MPFRFloat(precision: precision) // Mutated through pointer below
        let rnd = rounding.toMPFRRoundingMode()
        let ternary = mpfr_acos(&result._storage.value, &_storage.value, rnd)
        return (result: result, ternary: Int(ternary))
    }

    /// Compute the arctangent function.
    ///
    /// - Parameter rounding: The rounding mode to use. Defaults to `.nearest`.
    /// - Returns: A new `MPFRFloat` equal to arctan(self), and a ternary value.
    ///
    /// - Requires: This float must be properly initialized.
    /// - Guarantees: Returns a new `MPFRFloat` with arctan(self), rounded to
    /// `self`'s precision.
    ///
    /// - Note: Wraps `mpfr_atan`.
    public func atan(rounding: MPFRRoundingMode = .nearest)
        -> (result: MPFRFloat, ternary: Int)
    {
        let result =
            MPFRFloat(precision: precision) // Mutated through pointer below
        let rnd = rounding.toMPFRRoundingMode()
        let ternary = mpfr_atan(&result._storage.value, &_storage.value, rnd)
        return (result: result, ternary: Int(ternary))
    }

    /// Compute the arctangent of y/x.
    ///
    /// Computes atan2(y, x) = arctan(y/x) with proper quadrant handling.
    ///
    /// - Parameters:
    ///   - x: The x coordinate.
    ///   - rounding: The rounding mode to use. Defaults to `.nearest`.
    /// - Returns: A new `MPFRFloat` equal to atan2(self, x), and a ternary
    /// value.
    ///
    /// - Requires: Both floats must be properly initialized. Both cannot be
    /// zero.
    /// - Guarantees: Returns a new `MPFRFloat` with atan2(self, x).
    ///
    /// - Note: Wraps `mpfr_atan2`.
    public func atan2(
        x: MPFRFloat,
        rounding: MPFRRoundingMode = .nearest
    )
        -> (result: MPFRFloat, ternary: Int)
    {
        let result =
            MPFRFloat(precision: precision) // Mutated through pointer below
        let rnd = rounding.toMPFRRoundingMode()
        let ternary = mpfr_atan2(
            &result._storage.value,
            &_storage.value,
            &x._storage.value,
            rnd
        )
        return (result: result, ternary: Int(ternary))
    }

    // MARK: - Hyperbolic Functions

    /// Compute the hyperbolic sine function.
    ///
    /// - Parameter rounding: The rounding mode to use. Defaults to `.nearest`.
    /// - Returns: A new `MPFRFloat` equal to sinh(self), and a ternary value.
    ///
    /// - Requires: This float must be properly initialized.
    /// - Guarantees: Returns a new `MPFRFloat` with sinh(self), rounded to
    /// `self`'s precision.
    ///
    /// - Note: Wraps `mpfr_sinh`.
    public func sinh(rounding: MPFRRoundingMode = .nearest)
        -> (result: MPFRFloat, ternary: Int)
    {
        let result =
            MPFRFloat(precision: precision) // Mutated through pointer below
        let rnd = rounding.toMPFRRoundingMode()
        let ternary = mpfr_sinh(&result._storage.value, &_storage.value, rnd)
        return (result: result, ternary: Int(ternary))
    }

    /// Compute the hyperbolic cosine function.
    ///
    /// - Parameter rounding: The rounding mode to use. Defaults to `.nearest`.
    /// - Returns: A new `MPFRFloat` equal to cosh(self), and a ternary value.
    ///
    /// - Requires: This float must be properly initialized.
    /// - Guarantees: Returns a new `MPFRFloat` with cosh(self), rounded to
    /// `self`'s precision.
    ///
    /// - Note: Wraps `mpfr_cosh`.
    public func cosh(rounding: MPFRRoundingMode = .nearest)
        -> (result: MPFRFloat, ternary: Int)
    {
        let result =
            MPFRFloat(precision: precision) // Mutated through pointer below
        let rnd = rounding.toMPFRRoundingMode()
        let ternary = mpfr_cosh(&result._storage.value, &_storage.value, rnd)
        return (result: result, ternary: Int(ternary))
    }

    /// Compute both hyperbolic sine and cosine simultaneously.
    ///
    /// - Parameter rounding: The rounding mode to use. Defaults to `.nearest`.
    /// - Returns: A tuple `(sinh: MPFRFloat, cosh: MPFRFloat, ternary: Int)`.
    ///
    /// - Requires: This float must be properly initialized.
    /// - Guarantees: Returns both sinh(self) and cosh(self), rounded to
    /// `self`'s precision.
    ///
    /// - Note: Wraps `mpfr_sinh_cosh`.
    public func sinhCosh(rounding: MPFRRoundingMode = .nearest)
        -> (sinh: MPFRFloat, cosh: MPFRFloat, ternary: Int)
    {
        // Mutated through pointer below
        let sinhResult = MPFRFloat(precision: precision)
        // Mutated through pointer below
        let coshResult = MPFRFloat(precision: precision)
        let rnd = rounding.toMPFRRoundingMode()
        let ternary = mpfr_sinh_cosh(
            &sinhResult._storage.value,
            &coshResult._storage.value,
            &_storage.value,
            rnd
        )
        return (sinh: sinhResult, cosh: coshResult, ternary: Int(ternary))
    }

    /// Compute the hyperbolic tangent function.
    ///
    /// - Parameter rounding: The rounding mode to use. Defaults to `.nearest`.
    /// - Returns: A new `MPFRFloat` equal to tanh(self), and a ternary value.
    ///
    /// - Requires: This float must be properly initialized.
    /// - Guarantees: Returns a new `MPFRFloat` with tanh(self), rounded to
    /// `self`'s precision.
    ///
    /// - Note: Wraps `mpfr_tanh`.
    public func tanh(rounding: MPFRRoundingMode = .nearest)
        -> (result: MPFRFloat, ternary: Int)
    {
        let result =
            MPFRFloat(precision: precision) // Mutated through pointer below
        let rnd = rounding.toMPFRRoundingMode()
        let ternary = mpfr_tanh(&result._storage.value, &_storage.value, rnd)
        return (result: result, ternary: Int(ternary))
    }

    /// Compute the inverse hyperbolic sine function.
    ///
    /// - Parameter rounding: The rounding mode to use. Defaults to `.nearest`.
    /// - Returns: A new `MPFRFloat` equal to asinh(self), and a ternary value.
    ///
    /// - Requires: This float must be properly initialized.
    /// - Guarantees: Returns a new `MPFRFloat` with asinh(self), rounded to
    /// `self`'s precision.
    ///
    /// - Note: Wraps `mpfr_asinh`.
    ///
    /// - Throws: `MPFRError` if an exception occurs during the operation
    ///   (underflow, overflow, NaN, divide-by-zero, or range error).
    public func asinh(rounding: MPFRRoundingMode = .nearest) throws
        -> (result: MPFRFloat, ternary: Int)
    {
        // Clear flags before operation to prevent assertion failures in
        // internal mpfr_agm() calls and to isolate this operation's exceptions
        mpfr_clear_flags()
        let result =
            MPFRFloat(precision: precision) // Mutated through pointer below
        let rnd = rounding.toMPFRRoundingMode()
        let ternary = mpfr_asinh(&result._storage.value, &_storage.value, rnd)

        // Check flags after operation and throw if exceptions occurred
        try Self.checkFlagsAndThrow()

        return (result: result, ternary: Int(ternary))
    }

    /// Compute the inverse hyperbolic cosine function.
    ///
    /// - Parameter rounding: The rounding mode to use. Defaults to `.nearest`.
    /// - Returns: A new `MPFRFloat` equal to acosh(self), and a ternary value.
    ///
    /// - Requires: This float must be properly initialized. The value must be
    /// >= 1.
    /// - Guarantees: Returns a new `MPFRFloat` with acosh(self). If self < 1,
    /// returns NaN.
    ///
    /// - Note: Wraps `mpfr_acosh`.
    ///
    /// - Throws: `MPFRError` if an exception occurs during the operation
    ///   (underflow, overflow, NaN, divide-by-zero, or range error).
    public func acosh(rounding: MPFRRoundingMode = .nearest) throws
        -> (result: MPFRFloat, ternary: Int)
    {
        // Clear flags before operation to prevent assertion failures in
        // internal mpfr_agm() calls and to isolate this operation's exceptions
        mpfr_clear_flags()
        let result =
            MPFRFloat(precision: precision) // Mutated through pointer below
        let rnd = rounding.toMPFRRoundingMode()
        let ternary = mpfr_acosh(&result._storage.value, &_storage.value, rnd)

        // Check flags after operation and throw if exceptions occurred
        try Self.checkFlagsAndThrow()

        return (result: result, ternary: Int(ternary))
    }

    /// Compute the inverse hyperbolic tangent function.
    ///
    /// - Parameter rounding: The rounding mode to use. Defaults to `.nearest`.
    /// - Returns: A new `MPFRFloat` equal to atanh(self), and a ternary value.
    ///
    /// - Requires: This float must be properly initialized. The value must be
    /// in (-1, 1).
    /// - Guarantees: Returns a new `MPFRFloat` with atanh(self). If |self| >=
    /// 1, returns NaN or Inf.
    ///
    /// - Note: Wraps `mpfr_atanh`.
    ///
    /// - Throws: `MPFRError` if an exception occurs during the operation
    ///   (underflow, overflow, NaN, divide-by-zero, or range error).
    public func atanh(rounding: MPFRRoundingMode = .nearest) throws
        -> (result: MPFRFloat, ternary: Int)
    {
        // Clear flags before operation to prevent assertion failures in
        // internal mpfr_agm() calls and to isolate this operation's exceptions
        mpfr_clear_flags()
        let result =
            MPFRFloat(precision: precision) // Mutated through pointer below
        let rnd = rounding.toMPFRRoundingMode()
        let ternary = mpfr_atanh(&result._storage.value, &_storage.value, rnd)

        // Check flags after operation and throw if exceptions occurred
        try Self.checkFlagsAndThrow()

        return (result: result, ternary: Int(ternary))
    }

    // MARK: - Rounding Functions

    /// Get the floor (greatest integer <= self).
    ///
    /// - Parameter rounding: The rounding mode to use. Defaults to `.nearest`.
    ///   Note: floor is independent of the rounding mode.
    /// - Returns: A new `MPFRFloat` with the floor value, and a ternary value.
    ///
    /// - Requires: This float must be properly initialized.
    /// - Guarantees: Returns a new `MPFRFloat` with the floor value. `self` is
    /// unchanged.
    ///
    /// - Note: Wraps `mpfr_floor`.
    public func floor(rounding: MPFRRoundingMode = .nearest)
        -> (result: MPFRFloat, ternary: Int)
    {
        let result =
            MPFRFloat(precision: precision) // Mutated through pointer below
        let rnd = rounding.toMPFRRoundingMode()
        // Use bridge function that wraps mpfr_rint_floor (takes rounding mode
        // parameter)
        let ternary = clinus_mpfr_rint_floor(
            &result._storage.value,
            &_storage.value,
            Int32(rnd.rawValue)
        )
        return (result: result, ternary: Int(ternary))
    }

    /// Replace this float with its floor value in place.
    ///
    /// - Parameter rounding: The rounding mode to use. Defaults to `.nearest`.
    ///   Note: floor is independent of the rounding mode.
    /// - Returns: A ternary value indicating the rounding direction.
    ///
    /// - Requires: This float must be properly initialized.
    /// - Guarantees: After this call, `self` equals the floor of `self` (before
    /// the call).
    ///
    /// - Note: Wraps `mpfr_floor`.
    @discardableResult
    public mutating func formFloor(rounding: MPFRRoundingMode = .nearest)
        -> Int
    {
        // Use immutable floor() + assignment pattern to avoid exclusivity
        // violations
        let (result, ternary) = floor(rounding: rounding)
        self = result
        return ternary
    }

    /// Get the ceiling (least integer >= self).
    ///
    /// - Parameter rounding: The rounding mode to use. Defaults to `.nearest`.
    ///   Note: ceil is independent of the rounding mode.
    /// - Returns: A new `MPFRFloat` with the ceiling value, and a ternary
    /// value.
    ///
    /// - Requires: This float must be properly initialized.
    /// - Guarantees: Returns a new `MPFRFloat` with the ceiling value. `self`
    /// is unchanged.
    ///
    /// - Note: Wraps `mpfr_ceil`.
    public func ceil(rounding: MPFRRoundingMode = .nearest)
        -> (result: MPFRFloat, ternary: Int)
    {
        let result =
            MPFRFloat(precision: precision) // Mutated through pointer below
        let rnd = rounding.toMPFRRoundingMode()
        // Use bridge function that wraps mpfr_rint_ceil (takes rounding mode
        // parameter)
        let ternary = clinus_mpfr_rint_ceil(
            &result._storage.value,
            &_storage.value,
            Int32(rnd.rawValue)
        )
        return (result: result, ternary: Int(ternary))
    }

    /// Replace this float with its ceiling value in place.
    ///
    /// - Parameter rounding: The rounding mode to use. Defaults to `.nearest`.
    ///   Note: ceil is independent of the rounding mode.
    /// - Returns: A ternary value indicating the rounding direction.
    ///
    /// - Requires: This float must be properly initialized.
    /// - Guarantees: After this call, `self` equals the ceiling of `self`
    /// (before the call).
    ///
    /// - Note: Wraps `mpfr_ceil`.
    @discardableResult
    public mutating func formCeiling(rounding: MPFRRoundingMode = .nearest)
        -> Int
    {
        // Use immutable ceil() + assignment pattern to avoid exclusivity
        // violations
        let (result, ternary) = ceil(rounding: rounding)
        self = result
        return ternary
    }

    /// Get the truncation (round toward zero).
    ///
    /// - Parameter rounding: The rounding mode to use. Defaults to `.nearest`.
    ///   Note: trunc is independent of the rounding mode.
    /// - Returns: A new `MPFRFloat` with the truncated value, and a ternary
    /// value.
    ///
    /// - Requires: This float must be properly initialized.
    /// - Guarantees: Returns a new `MPFRFloat` with the truncated value. `self`
    /// is unchanged.
    ///
    /// - Note: Wraps `mpfr_trunc`.
    public func trunc(rounding: MPFRRoundingMode = .nearest)
        -> (result: MPFRFloat, ternary: Int)
    {
        let result =
            MPFRFloat(precision: precision) // Mutated through pointer below
        let rnd = rounding.toMPFRRoundingMode()
        // Use bridge function that wraps mpfr_rint_trunc (takes rounding mode
        // parameter)
        let ternary = clinus_mpfr_rint_trunc(
            &result._storage.value,
            &_storage.value,
            Int32(rnd.rawValue)
        )
        return (result: result, ternary: Int(ternary))
    }

    /// Replace this float with its truncated value in place.
    ///
    /// - Parameter rounding: The rounding mode to use. Defaults to `.nearest`.
    ///   Note: trunc is independent of the rounding mode.
    /// - Returns: A ternary value indicating the rounding direction.
    ///
    /// - Requires: This float must be properly initialized.
    /// - Guarantees: After this call, `self` equals the truncated value of
    /// `self` (before the call).
    ///
    /// - Note: Wraps `mpfr_trunc`.
    @discardableResult
    public mutating func formTruncate(rounding: MPFRRoundingMode = .nearest)
        -> Int
    {
        // Use immutable trunc() + assignment pattern to avoid exclusivity
        // violations
        let (result, ternary) = trunc(rounding: rounding)
        self = result
        return ternary
    }

    /// Round to the nearest integer (ties to even).
    ///
    /// - Parameter rounding: The rounding mode to use. Defaults to `.nearest`.
    ///   Note: The rounding mode parameter affects behavior.
    /// - Returns: A new `MPFRFloat` with the rounded value, and a ternary
    /// value.
    ///
    /// - Requires: This float must be properly initialized.
    /// - Guarantees: Returns a new `MPFRFloat` with the rounded value. `self`
    /// is unchanged.
    ///
    /// - Note: Wraps `mpfr_round` (via `mpfr_rint_round` to support rounding
    /// mode).
    public func round(rounding: MPFRRoundingMode = .nearest)
        -> (result: MPFRFloat, ternary: Int)
    {
        let result =
            MPFRFloat(precision: precision) // Mutated through pointer below
        let rnd = rounding.toMPFRRoundingMode()
        let ternary = mpfr_rint_round(
            &result._storage.value,
            &_storage.value,
            rnd
        )
        return (result: result, ternary: Int(ternary))
    }

    /// Replace this float with its rounded value in place.
    ///
    /// - Parameter rounding: The rounding mode to use. Defaults to `.nearest`.
    /// - Returns: A ternary value indicating the rounding direction.
    ///
    /// - Requires: This float must be properly initialized.
    /// - Guarantees: After this call, `self` equals the rounded value of `self`
    /// (before the call).
    ///
    /// - Note: Wraps `mpfr_round`.
    @discardableResult
    public mutating func formRound(rounding: MPFRRoundingMode = .nearest)
        -> Int
    {
        // Use immutable round() + assignment pattern to avoid exclusivity
        // violations
        let (result, ternary) = round(rounding: rounding)
        self = result
        return ternary
    }

    /// Round to the nearest integer using the specified rounding mode.
    ///
    /// - Parameter rounding: The rounding mode to use. Defaults to `.nearest`.
    /// - Returns: A new `MPFRFloat` with the rounded value, and a ternary
    /// value.
    ///
    /// - Requires: This float must be properly initialized.
    /// - Guarantees: Returns a new `MPFRFloat` with the rounded value. `self`
    /// is unchanged.
    ///
    /// - Note: Wraps `mpfr_rint`.
    public func rint(rounding: MPFRRoundingMode = .nearest)
        -> (result: MPFRFloat, ternary: Int)
    {
        let result =
            MPFRFloat(precision: precision) // Mutated through pointer below
        let rnd = rounding.toMPFRRoundingMode()
        let ternary = mpfr_rint(&result._storage.value, &_storage.value, rnd)
        return (result: result, ternary: Int(ternary))
    }

    /// Check if this float represents an integer value.
    ///
    /// - Returns: `true` if this float has no fractional part, `false`
    /// otherwise.
    ///
    /// - Requires: This float must be properly initialized.
    /// - Guarantees: Returns `true` if and only if this float represents an
    /// integer value.
    ///
    /// - Note: Wraps `mpfr_integer_p`.
    public var isInteger: Bool {
        mpfr_integer_p(&_storage.value) != 0
    }

    /// Compute the relative difference between two floats.
    ///
    /// Computes |a - b| / max(|a|, |b|). If both are zero, returns zero.
    ///
    /// - Parameters:
    ///   - a: The first float.
    ///   - b: The second float.
    ///   - rounding: The rounding mode to use. Defaults to `.nearest`.
    /// - Returns: A new `MPFRFloat` with the relative difference, and a ternary
    /// value.
    ///
    /// - Requires: Both floats must be properly initialized.
    /// - Guarantees: Returns a new `MPFRFloat` with the relative difference.
    ///
    /// - Note: Wraps `mpfr_reldiff`.
    public static func relativeDifference(
        _ a: MPFRFloat,
        _ b: MPFRFloat,
        rounding: MPFRRoundingMode = .nearest
    ) -> (result: MPFRFloat, ternary: Int) {
        let result = MPFRFloat(precision: a
            .precision) // Mutated through pointer below
        let rnd = rounding.toMPFRRoundingMode()
        // mpfr_reldiff returns void, so we return 0 for ternary
        mpfr_reldiff(
            &result._storage.value,
            &a._storage.value,
            &b._storage.value,
            rnd
        )
        // Since mpfr_reldiff returns void, we can't get a ternary value
        // Return 0 to indicate we don't know the rounding direction
        return (result: result, ternary: 0)
    }

    /// Get the next representable value toward positive infinity.
    ///
    /// - Parameter rounding: The rounding mode to use. Defaults to `.nearest`.
    /// - Returns: A new `MPFRFloat` with the next value, and a ternary value.
    ///
    /// - Requires: This float must be properly initialized.
    /// - Guarantees: Returns a new `MPFRFloat` with the next representable
    /// value toward +Inf. `self` is unchanged.
    ///
    /// - Note: Wraps `mpfr_nextabove`.
    public func nextUp(rounding _: MPFRRoundingMode = .nearest)
        -> (result: MPFRFloat, ternary: Int)
    {
        // Create result by copying self
        // Mutated through pointer below
        let result = self
        // mpfr_nextabove modifies in place and returns void
        mpfr_nextabove(&result._storage.value)
        // Since mpfr_nextabove returns void, we return 0 for ternary
        return (result: result, ternary: 0)
    }

    /// Get the next representable value toward negative infinity.
    ///
    /// - Parameter rounding: The rounding mode to use. Defaults to `.nearest`.
    /// - Returns: A new `MPFRFloat` with the next value, and a ternary value.
    ///
    /// - Requires: This float must be properly initialized.
    /// - Guarantees: Returns a new `MPFRFloat` with the next representable
    /// value toward -Inf. `self` is unchanged.
    ///
    /// - Note: Wraps `mpfr_nextbelow`.
    public func nextDown(rounding _: MPFRRoundingMode = .nearest)
        -> (result: MPFRFloat, ternary: Int)
    {
        // Create result by copying self
        // Mutated through pointer below
        let result = self
        // mpfr_nextbelow modifies in place and returns void
        mpfr_nextbelow(&result._storage.value)
        // Since mpfr_nextbelow returns void, we return 0 for ternary
        return (result: result, ternary: 0)
    }

    /// Get the minimum of two floats.
    ///
    /// - Parameters:
    ///   - other: The other float to compare.
    ///   - rounding: The rounding mode to use. Defaults to `.nearest`.
    /// - Returns: A new `MPFRFloat` with the minimum value, and a ternary
    /// value.
    ///
    /// - Requires: Both floats must be properly initialized.
    /// - Guarantees: Returns a new `MPFRFloat` with the minimum of `self` and
    /// `other`. Both `self` and `other` are unchanged.
    ///
    /// - Note: Wraps `mpfr_min`.
    public func min(
        _ other: MPFRFloat,
        rounding: MPFRRoundingMode = .nearest
    )
        -> (result: MPFRFloat, ternary: Int)
    {
        let result =
            MPFRFloat(precision: precision) // Mutated through pointer below
        let rnd = rounding.toMPFRRoundingMode()
        let ternary = mpfr_min(
            &result._storage.value,
            &_storage.value,
            &other._storage.value,
            rnd
        )
        return (result: result, ternary: Int(ternary))
    }

    /// Get the maximum of two floats.
    ///
    /// - Parameters:
    ///   - other: The other float to compare.
    ///   - rounding: The rounding mode to use. Defaults to `.nearest`.
    /// - Returns: A new `MPFRFloat` with the maximum value, and a ternary
    /// value.
    ///
    /// - Requires: Both floats must be properly initialized.
    /// - Guarantees: Returns a new `MPFRFloat` with the maximum of `self` and
    /// `other`. Both `self` and `other` are unchanged.
    ///
    /// - Note: Wraps `mpfr_max`.
    public func max(
        _ other: MPFRFloat,
        rounding: MPFRRoundingMode = .nearest
    )
        -> (result: MPFRFloat, ternary: Int)
    {
        let result =
            MPFRFloat(precision: precision) // Mutated through pointer below
        let rnd = rounding.toMPFRRoundingMode()
        let ternary = mpfr_max(
            &result._storage.value,
            &_storage.value,
            &other._storage.value,
            rnd
        )
        return (result: result, ternary: Int(ternary))
    }

    // MARK: - Mathematical Constants

    /// Serial queue for synchronizing ALL MPFR operations to prevent race
    /// conditions when tests run in parallel. MPFR uses GMP internally for
    /// memory

    /// Get the mathematical constant π (pi).
    ///
    /// - Parameters:
    ///   - precision: The precision in bits. If nil, uses default precision.
    ///   - rounding: The rounding mode to use. Defaults to `.nearest`.
    /// - Returns: A new `MPFRFloat` with π, and a ternary value.
    ///
    /// - Requires: None
    /// - Guarantees: Returns a new `MPFRFloat` with π, rounded to the specified
    /// precision.
    ///
    /// - Note: Wraps `mpfr_const_pi`.
    public static func pi(
        precision: Int? = nil,
        rounding: MPFRRoundingMode = .nearest
    ) -> (result: MPFRFloat, ternary: Int) {
        let result: MPFRFloat
        if let prec = precision {
            let precMin = Int(clinus_get_prec_min())
            let precMax = Int(clinus_get_prec_max())
            precondition(
                prec >= precMin && prec <= precMax,
                "precision must be between MPFR_PREC_MIN and MPFR_PREC_MAX"
            )
            result = MPFRFloat(precision: prec)
        } else {
            let defaultPrec = mpfr_get_default_prec()
            result = MPFRFloat(precision: Int(defaultPrec))
        }
        let rnd = rounding.toMPFRRoundingMode()
        let ternary = mpfr_const_pi(&result._storage.value, rnd)
        return (result: result, ternary: Int(ternary))
    }

    /// Get Euler's constant (γ ≈ 0.5772156649...).
    ///
    /// - Parameters:
    ///   - precision: The precision in bits. If nil, uses default precision.
    ///   - rounding: The rounding mode to use. Defaults to `.nearest`.
    /// - Returns: A new `MPFRFloat` with Euler's constant, and a ternary value.
    ///
    /// - Requires: None
    /// - Guarantees: Returns a new `MPFRFloat` with Euler's constant, rounded
    /// to the specified precision.
    ///
    /// - Note: Wraps `mpfr_const_euler`.
    public static func euler(
        precision: Int? = nil,
        rounding: MPFRRoundingMode = .nearest
    ) -> (result: MPFRFloat, ternary: Int) {
        let result: MPFRFloat
        if let prec = precision {
            let precMin = Int(clinus_get_prec_min())
            let precMax = Int(clinus_get_prec_max())
            precondition(
                prec >= precMin && prec <= precMax,
                "precision must be between MPFR_PREC_MIN and MPFR_PREC_MAX"
            )
            result = MPFRFloat(precision: prec)
        } else {
            let defaultPrec = mpfr_get_default_prec()
            result = MPFRFloat(precision: Int(defaultPrec))
        }
        let rnd = rounding.toMPFRRoundingMode()
        let ternary = mpfr_const_euler(&result._storage.value, rnd)
        return (result: result, ternary: Int(ternary))
    }

    /// Get Catalan's constant (G ≈ 0.9159655941...).
    ///
    /// - Parameters:
    ///   - precision: The precision in bits. If nil, uses default precision.
    ///   - rounding: The rounding mode to use. Defaults to `.nearest`.
    /// - Returns: A new `MPFRFloat` with Catalan's constant, and a ternary
    /// value.
    ///
    /// - Requires: None
    /// - Guarantees: Returns a new `MPFRFloat` with Catalan's constant, rounded
    /// to the specified precision.
    ///
    /// - Note: Wraps `mpfr_const_catalan`.
    public static func catalan(
        precision: Int? = nil,
        rounding: MPFRRoundingMode = .nearest
    ) -> (result: MPFRFloat, ternary: Int) {
        let result: MPFRFloat
        if let prec = precision {
            let precMin = Int(clinus_get_prec_min())
            let precMax = Int(clinus_get_prec_max())
            precondition(
                prec >= precMin && prec <= precMax,
                "precision must be between MPFR_PREC_MIN and MPFR_PREC_MAX"
            )
            result = MPFRFloat(precision: prec)
        } else {
            let defaultPrec = mpfr_get_default_prec()
            result = MPFRFloat(precision: Int(defaultPrec))
        }
        let rnd = rounding.toMPFRRoundingMode()
        let ternary = mpfr_const_catalan(&result._storage.value, rnd)
        return (result: result, ternary: Int(ternary))
    }

    /// Get the natural logarithm of 2 (ln(2)).
    ///
    /// - Parameters:
    ///   - precision: The precision in bits. If nil, uses default precision.
    ///   - rounding: The rounding mode to use. Defaults to `.nearest`.
    /// - Returns: A new `MPFRFloat` with ln(2), and a ternary value.
    ///
    /// - Requires: None
    /// - Guarantees: Returns a new `MPFRFloat` with ln(2), rounded to the
    /// specified precision.
    ///
    /// - Note: Wraps `mpfr_const_log2`.
    /// - Note: This is different from the instance method `log2(rounding:)`
    /// which computes log₂(x).
    public static func log2(
        precision: Int? = nil,
        rounding: MPFRRoundingMode = .nearest
    ) -> (result: MPFRFloat, ternary: Int) {
        let result: MPFRFloat
        if let prec = precision {
            let precMin = Int(clinus_get_prec_min())
            let precMax = Int(clinus_get_prec_max())
            precondition(
                prec >= precMin && prec <= precMax,
                "precision must be between MPFR_PREC_MIN and MPFR_PREC_MAX"
            )
            result = MPFRFloat(precision: prec)
        } else {
            let defaultPrec = mpfr_get_default_prec()
            result = MPFRFloat(precision: Int(defaultPrec))
        }
        let rnd = rounding.toMPFRRoundingMode()
        let ternary = mpfr_const_log2(&result._storage.value, rnd)
        return (result: result, ternary: Int(ternary))
    }
}
