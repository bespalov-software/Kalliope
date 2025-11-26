# ``Kalliope``

A high-performance Swift wrapper around the GNU Multiple Precision Arithmetic Library (GMP), providing arbitrary-precision arithmetic for all Apple platforms.

## Overview

Kalliope provides Swift-friendly APIs for arbitrary-precision arithmetic, including:

- **Arbitrary-Precision Integers** - `GMPInteger` for working with integers of any size
- **Arbitrary-Precision Floats** - `GMPFloat` with configurable precision
- **Rational Numbers** - `GMPRational` for exact fractional arithmetic
- **Number Theory** - GCD, LCM, modular arithmetic, primality testing, and more
- **Random Number Generation** - High-quality random numbers via `GMPRandomState`

## Topics

### Core Types

- ``GMPInteger``
- ``GMPFloat``
- ``GMPRational``
- ``GMPRandomState``
- ``GMPError``

### Getting Started

To get started with Kalliope, import the module and start using arbitrary-precision types:

```swift
import Kalliope

// Create integers from literals
let a: GMPInteger = 12345678901234567890
let b: GMPInteger = 98765432109876543210

// Perform arithmetic operations
let sum = a + b
let product = a * b
```

## See Also

- [GMP Library](https://gmplib.org/) - The underlying arbitrary-precision arithmetic library

