# Kalliope

[![Swift](https://img.shields.io/badge/Swift-6.2-orange.svg)](https://swift.org)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-iOS%20%7C%20macOS%20%7C%20tvOS%20%7C%20watchOS%20%7C%20visionOS-lightgrey.svg)](Package.swift)

A high-performance Swift wrapper around the [GNU Multiple Precision Arithmetic Library (GMP)](https://gmplib.org/) and [MPFR (Multiple Precision Floating-Point Reliable Library)](https://www.mpfr.org/), providing arbitrary-precision arithmetic for all Apple platforms.

## Features

### Kalliope (GMP)
- ✅ **Arbitrary-Precision Integers** - `GMPInteger` for working with integers of any size
- ✅ **Arbitrary-Precision Floats** - `GMPFloat` with configurable precision
- ✅ **Rational Numbers** - `GMPRational` for exact fractional arithmetic
- ✅ **Number Theory** - GCD, LCM, modular arithmetic, primality testing, factorials, and more
- ✅ **Random Number Generation** - `GMPRandomState` for random numbers

### Linus (MPFR)
- ✅ **IEEE 754-Compliant Floats** - `MPFRFloat` with correct rounding and IEEE 754 semantics
- ✅ **Comprehensive Math Functions** - Trigonometric, logarithmic, exponential, and special functions
- ✅ **Configurable Rounding Modes** - Control rounding behavior (nearest, up, down, toward zero, away from zero)
- ✅ **Exception Handling** - Detailed error reporting with `MPFRError` for overflow, underflow, NaN, and more

### Common Features
- ✅ **Value Semantics** - Copy-on-Write (COW) implementation ensures efficient memory usage
- ✅ **Protocol Conformances** - Integrates seamlessly with Swift's standard library protocols
- ✅ **Formatted I/O** - Flexible string formatting and parsing with custom radix support
- ✅ **Cross-Platform** - Supports iOS, macOS, tvOS, watchOS, visionOS, and macCatalyst
- ✅ **Well-tested** - Comprehensive test suite

## Requirements

- **Swift**: 6.2 or later
- **Platforms**:
  - iOS 13.0+
  - macOS 11.0+
  - tvOS 15.0+
  - watchOS 8.0+
  - visionOS 1.0+
  - macCatalyst 15.0+

## Installation

### Swift Package Manager

Add Kalliope (and optionally Linus) to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/bespalov-software/Kalliope.git", from: "1.0.0")
]
```

Then add the products you need to your target:

```swift
.target(
    name: "YourTarget",
    dependencies: [
        .product(name: "Kalliope", package: "Kalliope"),  // GMP wrapper
        .product(name: "Linus", package: "Kalliope"),      // MPFR wrapper (optional)
    ]
)
```

Or add it through Xcode:
1. File → Add Packages...
2. Enter the repository URL
3. Select the version you want to use
4. Choose which products (Kalliope, Linus, or both) to add to your target

## Quick Start

### Basic Arithmetic

```swift
import Kalliope

// Create integers from literals
let a: GMPInteger = 12345678901234567890
let b: GMPInteger = 98765432109876543210

// Perform arithmetic operations
let sum = a + b
let product = a * b
let quotient = b / a

// Work with very large numbers
let factorial = GMPInteger.factorial(100) // 100!
```

### Floating-Point Arithmetic

```swift
import Kalliope

// Create floating-point numbers with arbitrary precision
var x = try GMPFloat(precision: 100) // 100 bits of precision
x.set(3.14159)
var y = try GMPFloat(precision: 100)
y.set(2.71828)

// Perform operations
let result = x * y
let sqrtResult = try x.squareRoot()
```

### Rational Numbers

```swift
import Kalliope

// Create rational numbers
let r1 = try GMPRational(numerator: 22, denominator: 7) // 22/7
let r2 = try GMPRational(numerator: 355, denominator: 113) // 355/113

// Operations maintain exact precision
let sum = r1 + r2
let product = r1 * r2
```

### Number Theory

```swift
import Kalliope

let a: GMPInteger = 48
let b: GMPInteger = 18

// Greatest Common Divisor
let gcd = GMPInteger.gcd(a, b) // 6

// Least Common Multiple
let lcm = GMPInteger.lcm(a, b) // 144

// Modular arithmetic
let result = a.raisedToPower(100, modulo: 97)

// Primality testing
let primeResult = GMPInteger(97).isProbablePrime(reps: 25) // Returns Int: 0=composite, 1=probably prime, 2=definitely prime
```

### String Formatting

```swift
import Kalliope

let num: GMPInteger = 255

// Format in different bases
print(num.toString(base: 16)) // "ff"
print(num.toString(base: 2))   // "11111111"
print(num.toString(base: 8))   // "377"

// Parse from strings
let parsed = GMPInteger("12345678901234567890", base: 10)
```

### Random Number Generation

Kalliope provides two types of random number generation:

**Pseudorandom Number Generation (PRNG)** - Fast, reproducible random numbers for simulations and testing:

```swift
import Kalliope

var rng = GMPRandomState()
let randomInt = GMPInteger.random(bits: 256, using: rng) // 256-bit random integer
let randomFloat = GMPFloat.random(bits: 53, using: rng) // Random float
```

> **ℹ️ Note**: `GMPRandomState` uses GMP's pseudorandom number generators, which are suitable for simulations, testing, Monte Carlo methods, and general-purpose randomness. For cryptographic purposes (keys, nonces, salts, tokens), use the secure random methods below.

**Cryptographically Secure Random Number Generation** - For security-sensitive applications:

```swift
import Kalliope

// Generate cryptographically secure random integers
let secureKey = try GMPInteger.secureRandom(bits: 256) // 256-bit secure key
let nonce = try GMPInteger.secureRandom(upperBound: GMPInteger(1000000)) // Secure nonce

// Generate cryptographically secure random floats
let secureFloat = try GMPFloat.secureRandom(bits: 53) // Secure random float in [0, 1)
```

> **ℹ️ Note**: Secure random methods use `SecRandomCopyBytes()` from the Security framework, providing cryptographically secure random numbers suitable for cryptographic keys, nonces, salts, and other security-sensitive applications.

### MPFRFloat (Linus) - IEEE 754-Compliant Arbitrary-Precision Floats

Linus provides `MPFRFloat`, an arbitrary-precision floating-point type with IEEE 754-compliant rounding and comprehensive mathematical functions. Unlike `GMPFloat`, `MPFRFloat` provides correct rounding and follows IEEE 754 semantics.

```swift
import Linus

// Create floats with specific precision
var x = MPFRFloat(precision: 100) // 100 bits of precision
x.set(3.14159265358979323846)

var y = MPFRFloat(precision: 100)
y.set(2.71828182845904523536)

// Arithmetic operations (operators use default rounding mode)
let sum = x + y
let product = x * y

// Explicit methods with rounding control
let (sumWithRounding, _) = x.adding(y, rounding: .nearest)
let (productWithRounding, _) = x.multiplied(by: y, rounding: .towardZero)
let (difference, _) = x.subtracting(y, rounding: .awayFromZero)
let (quotient, _) = x.divided(by: y, rounding: .towardPositive)

// Ternary value indicates rounding: 0=exact, positive=rounded up, negative=rounded down
let (result, ternary) = x.adding(y, rounding: .nearest)
if ternary == 0 {
    print("Result is exact")
} else if ternary > 0 {
    print("Result was rounded up")
} else {
    print("Result was rounded down")
}

// Mathematical functions (all return tuples with result and ternary value)
let (sqrtResult, _) = x.squareRoot(rounding: .nearest)
let (logResult, _) = try x.log(rounding: .nearest)
let (sinResult, _) = x.sin(rounding: .nearest)

// Trigonometric functions
let (sinVal, cosVal, _) = x.sinCos(rounding: .nearest)

// Special constants
let (pi, _) = MPFRFloat.pi(precision: 100, rounding: .nearest)
let (e, _) = MPFRFloat.euler(precision: 100, rounding: .nearest)

// String I/O with custom formatting
let str = x.toString(base: 10, digits: 50)
let parsed = MPFRFloat("3.14159", base: 10, precision: 100)
```

**Key Advantages of MPFRFloat over GMPFloat:**
- ✅ **IEEE 754 Compliance** - Correct rounding and standard semantics
- ✅ **Comprehensive Math Functions** - Trig, log, exp, hyperbolic, and special functions
- ✅ **Exception Handling** - Detailed error reporting with `MPFRError`
- ✅ **Rounding Mode Control** - Explicit control over rounding behavior
- ✅ **Better Precision Management** - More predictable precision handling

## API Documentation

📖 **Full API documentation**: Available via `make docs` (generates documentation in `docs/` directory)

### Main Types

#### `GMPInteger`

An arbitrary-precision integer type with value semantics.

```swift
public struct GMPInteger {
    // Initialization
    public init()
    public init(_ value: Int)
    public init?(_ string: String, base: Int = 10)
    
    // Arithmetic operations
    public static func + (lhs: GMPInteger, rhs: GMPInteger) -> GMPInteger
    public static func - (lhs: GMPInteger, rhs: GMPInteger) -> GMPInteger
    public static func * (lhs: GMPInteger, rhs: GMPInteger) -> GMPInteger
    public static func / (lhs: GMPInteger, rhs: GMPInteger) throws -> GMPInteger
    
    // Number theory
    public static func gcd(_ a: GMPInteger, _ b: GMPInteger) -> GMPInteger
    public static func lcm(_ a: GMPInteger, _ b: GMPInteger) -> GMPInteger
    public func raisedToPower(_ exponent: GMPInteger, modulo modulus: GMPInteger) -> GMPInteger
    public func isProbablePrime(reps: Int = 25) -> Int // Returns 0=composite, 1=probably prime, 2=definitely prime
    
    // Special sequences
    public static func factorial(_ n: Int) -> GMPInteger
    public static func binomial(_ n: Int, _ k: Int) -> GMPInteger
    public static func fibonacci(_ n: Int) -> GMPInteger
    
    // String formatting
    public func toString(base: Int = 10) -> String
}
```

#### `GMPFloat`

An arbitrary-precision floating-point number type.

```swift
public struct GMPFloat {
    // Initialization
    public init()
    public init(precision: Int) throws
    public init(_ value: Double) // Uses default precision
    public init(_ value: Int) // Uses default precision
    public init?(_ string: String, base: Int = 10) // Uses default precision
    
    // Arithmetic operations
    public static func + (lhs: GMPFloat, rhs: GMPFloat) -> GMPFloat
    public static func - (lhs: GMPFloat, rhs: GMPFloat) -> GMPFloat
    public static func * (lhs: GMPFloat, rhs: GMPFloat) -> GMPFloat
    public static func / (lhs: GMPFloat, rhs: GMPFloat) throws -> GMPFloat
    
    // Mathematical functions
    public func squareRoot() throws -> GMPFloat
    public func raisedToPower(_ exponent: Int) -> GMPFloat
    public var floor: GMPFloat
    public var ceiling: GMPFloat
    public var truncated: GMPFloat
    
    // Precision management
    public var precision: Int { get set }
}
```

#### `GMPRational`

An arbitrary-precision rational number type.

```swift
public struct GMPRational {
    // Initialization
    public init()
    public init(numerator: GMPInteger, denominator: GMPInteger) throws
    public init(numerator: Int, denominator: Int) throws
    public init?(_ string: String, base: Int = 10)
    
    // Components
    public var numerator: GMPInteger { get }
    public var denominator: GMPInteger { get }
    
    // Arithmetic operations
    public static func + (lhs: GMPRational, rhs: GMPRational) -> GMPRational
    public static func - (lhs: GMPRational, rhs: GMPRational) -> GMPRational
    public static func * (lhs: GMPRational, rhs: GMPRational) -> GMPRational
    public static func / (lhs: GMPRational, rhs: GMPRational) throws -> GMPRational
    
    // Conversion
    public func toDouble() -> Double
    public func toString(base: Int = 10) -> String
}
```

#### `GMPRandomState`

A random number generator using GMP's high-quality pseudorandom number generators (PRNGs).

> **ℹ️ Note**: `GMPRandomState` provides fast, reproducible random numbers suitable for simulations, testing, Monte Carlo methods, and general-purpose randomness. For cryptographic purposes, use `GMPInteger.secureRandom(bits:)`, `GMPInteger.secureRandom(upperBound:)`, or `GMPFloat.secureRandom(bits:)` which use `SecRandomCopyBytes()`.

```swift
public struct GMPRandomState {
    // Initialization
    public init()
    public init(seed: GMPInteger)
    
    // Random number generation (PRNG)
    public mutating func random(bits: Int) -> Int
    public mutating func random(upperBound: Int) -> Int
    public var seed: GMPInteger { get }
    public mutating func seed(_ value: GMPInteger)
    public mutating func seed(_ value: Int)
}

// Static random methods on GMPInteger and GMPFloat
extension GMPInteger {
    public static func random(bits: Int, using state: GMPRandomState) -> GMPInteger
    public static func random(upperBound: GMPInteger, using state: GMPRandomState) -> GMPInteger
}

extension GMPFloat {
    public static func random(bits: Int, using state: GMPRandomState) -> GMPFloat
}
```

#### Secure Random Number Generation

For cryptographic purposes, use these methods that leverage `SecRandomCopyBytes()`:

```swift
// Cryptographically secure random integers
public static func secureRandom(bits: Int) throws -> GMPInteger
public static func secureRandom(upperBound: GMPInteger) throws -> GMPInteger

// Cryptographically secure random floats
public static func secureRandom(bits: Int) throws -> GMPFloat
```

#### `MPFRFloat`

An IEEE 754-compliant arbitrary-precision floating-point number type with correct rounding.

```swift
public struct MPFRFloat {
    // Initialization
    public init()
    public init(precision: Int)
    public init(_ value: Double, precision: Int)
    public init(_ value: Int, precision: Int)
    public init?(_ string: String, base: Int = 10, precision: Int)
    
    // Precision management
    public var precision: Int { get set }
    public static func setDefaultPrecision(_ precision: Int)
    public static var defaultPrecision: Int { get }
    
    // Rounding modes
    public static func setDefaultRoundingMode(_ mode: MPFRRoundingMode)
    public static var defaultRoundingMode: MPFRRoundingMode { get }
    
    // Arithmetic operations (operators use default rounding mode)
    public static func + (lhs: MPFRFloat, rhs: MPFRFloat) -> MPFRFloat
    public static func - (lhs: MPFRFloat, rhs: MPFRFloat) -> MPFRFloat
    public static func * (lhs: MPFRFloat, rhs: MPFRFloat) -> MPFRFloat
    public static func / (lhs: MPFRFloat, rhs: MPFRFloat) -> MPFRFloat
    
    // Explicit arithmetic methods with rounding control
    public func adding(_ other: MPFRFloat, rounding: MPFRRoundingMode = .nearest) -> (result: MPFRFloat, ternary: Int)
    public func subtracting(_ other: MPFRFloat, rounding: MPFRRoundingMode = .nearest) -> (result: MPFRFloat, ternary: Int)
    public func multiplied(by other: MPFRFloat, rounding: MPFRRoundingMode = .nearest) -> (result: MPFRFloat, ternary: Int)
    public func divided(by other: MPFRFloat, rounding: MPFRRoundingMode = .nearest) -> (result: MPFRFloat, ternary: Int)
    
    // Mathematical functions
    public func squareRoot(rounding: MPFRRoundingMode = .nearest) -> (result: MPFRFloat, ternary: Int)
    public func raisedToPower(_ exponent: Int, rounding: MPFRRoundingMode = .nearest) -> (result: MPFRFloat, ternary: Int)
    public func exp(rounding: MPFRRoundingMode = .nearest) throws -> (result: MPFRFloat, ternary: Int)
    public func log(rounding: MPFRRoundingMode = .nearest) throws -> (result: MPFRFloat, ternary: Int)
    public func log2(rounding: MPFRRoundingMode = .nearest) throws -> (result: MPFRFloat, ternary: Int)
    public func log10(rounding: MPFRRoundingMode = .nearest) throws -> (result: MPFRFloat, ternary: Int)
    
    // Trigonometric functions
    public func sin(rounding: MPFRRoundingMode = .nearest) -> (result: MPFRFloat, ternary: Int)
    public func cos(rounding: MPFRRoundingMode = .nearest) -> (result: MPFRFloat, ternary: Int)
    public func sinCos(rounding: MPFRRoundingMode = .nearest) -> (sin: MPFRFloat, cos: MPFRFloat, ternary: Int)
    public func tan(rounding: MPFRRoundingMode = .nearest) -> (result: MPFRFloat, ternary: Int)
    public func asin(rounding: MPFRRoundingMode = .nearest) -> (result: MPFRFloat, ternary: Int)
    public func acos(rounding: MPFRRoundingMode = .nearest) -> (result: MPFRFloat, ternary: Int)
    public func atan(rounding: MPFRRoundingMode = .nearest) -> (result: MPFRFloat, ternary: Int)
    public func atan2(_ y: MPFRFloat, rounding: MPFRRoundingMode = .nearest) -> (result: MPFRFloat, ternary: Int)
    
    // Hyperbolic functions
    public func sinh(rounding: MPFRRoundingMode = .nearest) -> (result: MPFRFloat, ternary: Int)
    public func cosh(rounding: MPFRRoundingMode = .nearest) -> (result: MPFRFloat, ternary: Int)
    public func tanh(rounding: MPFRRoundingMode = .nearest) -> (result: MPFRFloat, ternary: Int)
    public func asinh(rounding: MPFRRoundingMode = .nearest) throws -> (result: MPFRFloat, ternary: Int)
    public func acosh(rounding: MPFRRoundingMode = .nearest) throws -> (result: MPFRFloat, ternary: Int)
    public func atanh(rounding: MPFRRoundingMode = .nearest) throws -> (result: MPFRFloat, ternary: Int)
    
    // Rounding functions
    public func floor(rounding: MPFRRoundingMode = .nearest) -> (result: MPFRFloat, ternary: Int)
    public func ceil(rounding: MPFRRoundingMode = .nearest) -> (result: MPFRFloat, ternary: Int)
    public func trunc(rounding: MPFRRoundingMode = .nearest) -> (result: MPFRFloat, ternary: Int)
    public func round(rounding: MPFRRoundingMode = .nearest) -> (result: MPFRFloat, ternary: Int)
    
    // Special constants
    public static func pi(precision: Int, rounding: MPFRRoundingMode = .nearest) -> (result: MPFRFloat, ternary: Int)
    public static func euler(precision: Int, rounding: MPFRRoundingMode = .nearest) -> (result: MPFRFloat, ternary: Int)
    public static func catalan(precision: Int, rounding: MPFRRoundingMode = .nearest) -> (result: MPFRFloat, ternary: Int)
    public static func log2(precision: Int, rounding: MPFRRoundingMode = .nearest) -> (result: MPFRFloat, ternary: Int)
    
    // String I/O
    public func toString(base: Int = 10, digits: Int? = nil) -> String
    public init?(_ string: String, base: Int = 10, precision: Int)
    
    // Conversions
    public func toDouble(rounding: MPFRRoundingMode = .nearest) -> Double
    public func toInt(rounding: MPFRRoundingMode = .nearest) -> Int
}
```

#### `MPFRRoundingMode`

Rounding modes for MPFR operations:

```swift
public enum MPFRRoundingMode {
    case nearest    // Round to nearest, ties to even (default)
    case towardZero // Round toward zero
    case towardPositive // Round toward +∞
    case towardNegative // Round toward -∞
    case awayFromZero  // Round away from zero
    case nearestAway   // Round to nearest, ties away from zero
    case faithful      // Faithful rounding (not yet implemented in MPFR)
}
```

#### `MPFRError`

Exception flags for MPFR operations (OptionSet):

```swift
public struct MPFRError: Error, OptionSet {
    public static let underflow      // Result underflowed
    public static let overflow       // Result overflowed
    public static let nan            // Result is NaN
    public static let rangeError     // Range error
    public static let divideByZero   // Division by zero
    
    // Convenience accessors
    public var isNaN: Bool
    public var isDivideByZero: Bool
    public var isOverflow: Bool
    public var isUnderflow: Bool
    public var isRangeError: Bool
}
```

### Error Handling

#### GMP Errors

```swift
public enum GMPError: Error {
    case divisionByZero
    case invalidStringFormat
    case overflow
    case underflow
    case invalidPrecision
    case invalidRadix(Int)
    case invalidExponent(Int)
    case negativeSquareRoot
    case invalidRandomState
}
```

#### MPFR Errors

MPFR uses `MPFRError` (an OptionSet) to represent exception flags. Multiple exceptions can be set simultaneously.

## Development

### Prerequisites

- Swift 6.2+
- Xcode 15.0+ (for development)
- **Autotools** (autoconf, automake, libtool) - Install via `brew install autoconf automake libtool`
- **lzip** - For extracting GMP tarball - Install via `brew install lzip`

### Setting Up the Development Environment

1. **Clone the repository:**
   ```bash
   git clone https://github.com/bespalov-software/Kalliope.git
   cd Kalliope
   ```

2. **Build GMP and MPFR libraries and create XCFrameworks:**
   ```bash
   # Create GMP XCFramework (builds for all platforms automatically)
   make create-xcframework
   
   # Create MPFR XCFramework (builds for all platforms automatically)
   make create-mpfr-xcframework
   ```

### Building

Build the package:

```bash
swift build
```

Run tests:

```bash
swift test
```

### Building GMP and MPFR from Source

The Makefile provides targets for building GMP and MPFR for all Apple platforms. The simplest approach is to use the XCFramework creation targets, which automatically build for all platforms:

```bash
# Create XCFrameworks (builds for all platforms automatically)
make create-xcframework      # Creates GMP XCFramework
make create-mpfr-xcframework # Creates MPFR XCFramework

# For more control, see available targets:
make help
```

For advanced usage, you can build for specific platforms. See `make help` for all available targets.

### Documentation

Generate documentation:

```bash
make docs
```

This creates symbol graphs in `.build/symbol-graph/` which contain all API documentation for both **Kalliope** and **Linus** targets. The symbol graphs are compatible with:
- **SwiftPackageIndex** - Automatically uses symbol graphs from your repository
- **DocC** - Can be converted to full documentation (requires a `.docc` bundle)

**Note**: There is a [known bug in SwiftPM (Issue #7580)](https://github.com/swiftlang/swift-package-manager/issues/7580) where `swift-docc-plugin` cannot generate documentation for packages with `binaryTarget` dependencies. This Makefile uses a workaround that manually generates symbol graphs using `swift build -emit-symbol-graph` for each target, which works correctly with binary targets.

**For SwiftPackageIndex**: The symbol graphs in `.build/symbol-graph/` contain all the information needed for both Kalliope and Linus. SwiftPackageIndex will automatically discover and use them when indexing your package.

**For GitHub Pages**: If you want to host full DocC documentation, you'll need to create a `Kalliope.docc` bundle and use `docc convert` with the generated symbol graphs.

### Code Style

- Follow Swift API Design Guidelines
- Use conventional commits: https://www.conventionalcommits.org/
- Code is well-documented with comprehensive inline documentation

See the [Makefile](Makefile) for more build targets.

## Contributing

Contributions are welcome! Please follow these guidelines:

1. **Fork the repository**
2. **Create a feature branch** (`git checkout -b feature/amazing-feature`)
3. **Make your changes** following the code style guidelines
4. **Add tests** for new functionality
5. **Run the test suite** (`swift test`)
6. **Commit your changes** using [conventional commits](https://www.conventionalcommits.org/)
7. **Push to your branch** (`git push origin feature/amazing-feature`)
8. **Open a Pull Request**

### Reporting Issues

If you find a bug or have a feature request, please open an issue on GitHub with:
- A clear description of the problem
- Steps to reproduce (for bugs)
- Expected vs. actual behavior
- Swift version and platform information

## License

This project is licensed under the **MIT License**. See [LICENSE](LICENSE) for full terms.

## Acknowledgments

This project is built on top of:
- **[GMP (GNU Multiple Precision Arithmetic Library)](https://gmplib.org/)** - Provides the underlying arbitrary-precision integer and floating-point arithmetic implementations. GMP is released under the LGPL v3 and GPL v2 licenses.
- **[MPFR (Multiple Precision Floating-Point Reliable Library)](https://www.mpfr.org/)** - Provides IEEE 754-compliant arbitrary-precision floating-point arithmetic with correct rounding. MPFR is released under the LGPL v3 and GPL v2 licenses.

## Support

- **Documentation**: 
  - Full API documentation: Available via `make docs` (generates documentation in `docs/` directory)
  - This README and inline code documentation
- **Issues**: [GitHub Issues](https://github.com/bespalov-software/Kalliope/issues)
- **Professional Support**: Need help with integration, custom development, or have questions? Contact us at [hello@bespalov.software](mailto:hello@bespalov.software) or visit [bespalov.software](https://bespalov.software)
- **Sponsorship**: Interested in sponsoring this project or other services? Reach out via [hello@bespalov.software](mailto:hello@bespalov.software) or visit [bespalov.software](https://bespalov.software)

## Related Projects

- [GMP (GNU Multiple Precision Arithmetic Library)](https://gmplib.org/) - The underlying arbitrary-precision arithmetic library
- [GMP Documentation](https://gmplib.org/manual/) - Official GMP documentation
- [MPFR (Multiple Precision Floating-Point Reliable Library)](https://www.mpfr.org/) - IEEE 754-compliant arbitrary-precision floating-point library
- [MPFR Documentation](https://www.mpfr.org/mpfr-current/mpfr.html) - Official MPFR documentation
