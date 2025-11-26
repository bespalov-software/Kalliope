# Troubleshooting Guide - GMPInteger Implementation Issues

This document catalogs common problems encountered during GMPInteger development and their solutions.

## Swift Exclusivity Violations

Swift's exclusivity checker prevents simultaneous access to the same memory location. This affects GMPInteger operations in several ways.

### Problem 1: Same Source/Destination in GMP Functions

Swift's exclusivity checker detects simultaneous access when:
- Directly passing `&_storage.value` to GMP functions
- Calling GMP functions that modify the same pointer they read from (e.g., `__gmpz_neg` with same source/destination)

**Error Message:**
```
Simultaneous accesses to 0x..., but modification requires exclusive access.
Fatal access conflict detected.
```

**Solution:** Use `withUnsafePointer` and `withUnsafeMutablePointer` to create separate pointer references:

```swift
// ❌ BAD - Causes exclusivity violation
__gmpz_divexact_ui(
    &result._storage.value,
    &_storage.value,
    CUnsignedLong(absDivisor)
)
if divisor < 0 {
    __gmpz_neg(&result._storage.value, &result._storage.value)  // Conflict!
}

// ✅ GOOD - Uses separate pointers
let opPtr = withUnsafePointer(to: _storage.value) { $0 }
let resultPtr = withUnsafeMutablePointer(to: &result._storage.value) { $0 }
__gmpz_divexact_ui(resultPtr, opPtr, CUnsignedLong(absDivisor))
if divisor < 0 {
    __gmpz_neg(resultPtr, resultPtr)  // Safe - using pointer, not direct access
}
```

**Affected Functions:**
- `exactlyDivided(by: Int)`
- `floorDivided(by: Int)` - negative divisor branch
- `floorRemainder(dividingBy: Int)` - negative divisor branch
- `ceilingDivided(by: Int)`
- `ceilingRemainder(dividingBy: Int)`
- `ceilingQuotientAndRemainder(dividingBy: Int)`
- `truncatedDivided(by: Int)` - all branches
- `truncatedRemainder(dividingBy: Int)` - all branches
- `truncatedQuotientAndRemainder(dividingBy: Int)` - all branches
- `modulo(_ modulus: Int)` - all branches

### Problem 2: Mutating Operations with Same-Variable Parameters

When a mutating method takes a `GMPInteger` parameter and `self` and the parameter refer to the same variable (e.g., `a.add(a)`), Swift's exclusivity checker detects conflicting access even after `_ensureUnique()` creates separate storage objects.

**Error Message:**
```
Simultaneous accesses to 0x..., but modification requires exclusive access.
Fatal access conflict detected.
```

**Root Cause:**
Swift tracks variable access, not just object identity. Even though `_ensureUnique()` creates a new storage object for `self`, accessing `other._storage` is still seen as accessing the same variable `a` while `self` is being mutated.

**Example:**
```swift
// ❌ BAD - Exclusivity violation when a.add(a) is called
public mutating func add(_ other: GMPInteger) {
    _ensureUnique()  // Creates new storage for self
    __gmpz_add(&_storage.value, &_storage.value, &other._storage.value)
    // Accessing other._storage.value conflicts with mutating self
}
```

**Solution:** Use the immutable version of the operation to create a new result, then assign it back:

```swift
// ✅ GOOD - Uses immutable operation + assignment
public mutating func add(_ other: GMPInteger) {
    let result = adding(other)  // Immutable operation creates new GMPInteger
    self = result               // Single assignment avoids exclusivity conflict
}
```

**Why This Works:**
- `adding(other)` is non-mutating and returns a new `GMPInteger` instance
- No simultaneous access to `self` and `other` occurs
- The final assignment `self = result` is a single, safe operation
- GMP handles overlapping operands correctly in the immutable version

**Affected Functions:**
All mutating arithmetic operations that take `GMPInteger` parameters:
- `add(_ other: GMPInteger)`
- `subtract(_ other: GMPInteger)`
- `multiply(by other: GMPInteger)`
- `addProduct(_ multiplicand: GMPInteger, _ multiplier: GMPInteger)`
- `addProduct(_ multiplicand: GMPInteger, _ multiplier: Int)`
- `subtractProduct(_ multiplicand: GMPInteger, _ multiplier: GMPInteger)`
- `subtractProduct(_ multiplicand: GMPInteger, _ multiplier: Int)`

**Note:** For `addProduct`/`subtractProduct`, compose immutable operations:
```swift
public mutating func addProduct(_ multiplicand: GMPInteger, _ multiplier: GMPInteger) {
    let product = multiplicand.multiplied(by: multiplier)
    let result = adding(product)
    self = result
}
```

### Problem 3: Mutating Bitwise Operations

Mutating bitwise operations that modify `self` in place (e.g., `formBitwiseAnd`, `formBitwiseNot`, `leftShift`) caused Swift exclusivity violations when calling GMP functions with the same source and destination pointer.

**Error Message:**
```
Fatal access conflict detected.
```

**Example:**
```swift
// ❌ BAD - Exclusivity violation
public mutating func formBitwiseNot() {
    _ensureUnique()
    __gmpz_com(&_storage.value, &_storage.value)  // Same pointer for source and dest
}
```

**Solution:** Use the immutable version and assign back:

```swift
// ✅ GOOD - Uses immutable version
public mutating func formBitwiseNot() {
    let result = bitwiseNot  // Immutable operation
    self = result            // Assignment avoids exclusivity issues
}
```

**Affected Functions:**
All mutating bitwise operations:
- `formBitwiseAnd(_:)`, `formBitwiseOr(_:)`, `formBitwiseXor(_:)`, `formBitwiseNot()`
- `leftShift(by:)`, `rightShift(by:)`

**Key Insight:**
Even though GMP functions support overlapping operands, Swift's exclusivity rules apply at the variable level. The "immutable method + assign" pattern is idiomatic Swift for value types and avoids all exclusivity issues while maintaining correctness.

## Arithmetic and Value Handling Issues

### Arithmetic Overflow with Int.min

**Problem:**
When negating `Int.min` (value: -2,147,483,648), the operation `-Int.min` causes an arithmetic overflow because the result (2,147,483,648) exceeds `Int.max` (2,147,483,647).

**Error Message:**
```
Swift runtime failure: arithmetic overflow
```

**Common Pattern:**
```swift
// ❌ BAD - Crashes when value is Int.min
let absValue = value < 0 ? -value : value  // -Int.min overflows!
__gmpz_add_ui(&result, &op, CUnsignedLong(absValue))
```

**Solution:**
Handle `Int.min` as a special case before negation:

```swift
// ✅ GOOD - Handles Int.min correctly
let absValue: CUnsignedLong
if value == Int.min {
    // Int.min = -2,147,483,648, so abs(Int.min) = 2,147,483,648
    // This fits in CUnsignedLong (UInt) but not in Int
    absValue = CUnsignedLong(Int.max) + 1
} else {
    absValue = CUnsignedLong(value < 0 ? -value : value)
}
__gmpz_add_ui(&result, &op, absValue)
```

**Affected Functions:**
- `adding(_ other: Int)` - when `other < 0`
- `subtracting(_ other: Int)` - when `other < 0`
- `subtracting(_ lhs: Int, _ rhs: GMPInteger)` - when `lhs < 0`
- `add(_ other: Int)` - when `other < 0`
- `subtract(_ other: Int)` - when `other < 0`
- `floorDivided(by: Int)` - when `divisor < 0`
- `ceilingDivided(by: Int)` - when `divisor < 0`
- `truncatedDivided(by: Int)` - when `divisor < 0`
- `gcd(_ a: GMPInteger, _ b: Int)` - when computing `abs(b)`
- `lcm(_ a: GMPInteger, _ b: Int)` - when computing `abs(b)`
- `power(base: Int, exponent: Int)` - when `base < 0`

**Key Insight:**
`Int.min` is the only value where `-value` overflows. The absolute value of `Int.min` is `Int.max + 1`, which fits in `CUnsignedLong` (UInt) but not in `Int`. Always check for `Int.min` before negating.

### Negative Value Handling in Congruence Checks

**Problem:**
When checking congruence with `Int` parameters, using `abs(value)` incorrectly converts negative values, breaking the congruence relation.

**Example:**
- `-10 ≡ -4 (mod 3)` should be `true` (difference is -6, divisible by 3)
- But `abs(-4) = 4`, so checking `-10 ≡ 4 (mod 3)` gives `false` (difference is -14, not divisible by 3)

**Solution:**
Reduce the value modulo the modulus first, handling negative values correctly:

```swift
// ❌ BAD - Incorrect for negative values
let absModulus = abs(modulus)
return __gmpz_congruent_ui_p(
    &_storage.value,
    CUnsignedLong(abs(value)),  // -4 becomes 4, wrong!
    CUnsignedLong(absModulus)
) != 0

// ✅ GOOD - Properly reduces negative values
let absModulus = abs(modulus)
let reducedValue: CUnsignedLong
if value < 0 {
    let absValue = CUnsignedLong(-value)
    let remainder = absValue % CUnsignedLong(absModulus)
    reducedValue = remainder == 0 ? 0 : CUnsignedLong(absModulus) - remainder
} else {
    reducedValue = CUnsignedLong(value) % CUnsignedLong(absModulus)
}
return __gmpz_congruent_ui_p(
    &_storage.value,
    reducedValue,
    CUnsignedLong(absModulus)
) != 0
```

**Affected Functions:**
- `isCongruent(to: Int, modulo: Int)`

### Quotient Negation Bugs in Division Functions

**Problem:**
Functions that compute quotient and remainder for negative `Int` divisors were not negating the quotient, causing incorrect results.

**Example:**
- `10 / -3` with ceiling division should give quotient `-4`, but was returning `4`
- `truncatedQuotientAndRemainder(dividingBy: -3)` was returning positive quotient instead of negative

**Error Symptoms:**
- Test failures with incorrect quotient signs
- Identity checks failing: `dividend != quotient * divisor + remainder`

**Solution:**
After computing quotient with absolute divisor, explicitly negate the quotient for negative divisors:

```swift
// ❌ BAD - Missing quotient negation
let absDivisor = abs(divisor)
__gmpz_cdiv_qr_ui(quotientPtr, remainderTempPtr, opPtr, CUnsignedLong(absDivisor))
// Quotient is positive even when divisor is negative!

// ✅ GOOD - Negates quotient for negative divisors
let absDivisor = abs(divisor)
__gmpz_cdiv_qr_ui(quotientPtr, remainderTempPtr, opPtr, CUnsignedLong(absDivisor))
if divisor < 0 {
    __gmpz_neg(quotientPtr, quotientPtr)  // Negate quotient
}
```

**Affected Functions:**
- `ceilingQuotientAndRemainder(dividingBy: Int)` - missing quotient negation
- `truncatedQuotientAndRemainder(dividingBy: Int)` - missing quotient negation

**Note:**
This only affects functions that return both quotient and remainder. Functions that return only quotient (like `truncatedDivided`) already handle this correctly.

## GMP API Issues

### GMP Function Naming: Modulo Operations

**Problem:**
The function `__gmpz_mod_ui` does not exist in GMP. Attempting to use it causes a compilation error.

**Error Message:**
```
error: cannot find '__gmpz_mod_ui' in scope
```

**Root Cause:**
GMP doesn't have a separate `mpz_mod_ui` function. According to GMP documentation, `mpz_mod_ui` is defined as an alias for `mpz_fdiv_r_ui` (floor remainder).

**Solution:**
Use `__gmpz_fdiv_ui` instead, which computes the floor remainder (always non-negative):

```swift
// ❌ BAD - Function doesn't exist
let result = __gmpz_mod_ui(&_storage.value, &_storage.value, CUnsignedLong(absModulus))

// ✅ GOOD - Use floor division remainder
let result = __gmpz_fdiv_ui(&_storage.value, CUnsignedLong(absModulus))
```

**Note:** `__gmpz_fdiv_ui` takes only 2 parameters (dividend pointer and divisor), not 3. It returns the remainder directly.

**Affected Functions:**
- `modulo(_ modulus: Int) -> Int`

**Key Insight:**
Always verify GMP function signatures in the header files. GMP uses aliases and macros that may not be directly callable from Swift.

## Swift Language and Compiler Issues

### Compiler Warnings: var vs let for C-Pointer Mutations

**Problem:**
Swift compiler warns about `var` variables that are never mutated, even when they're mutated through C pointers passed to GMP functions.

**Warning Message:**
```
variable 'result' was never mutated; consider changing to 'let' constant
```

**Example:**
```swift
// ❌ BAD - Compiler warning
var result = GMPInteger()
__gmpz_add(&result._storage.value, &a._storage.value, &b._storage.value)
return result
```

**Solution:**
Use `let` and add a comment explaining that mutation happens through the C pointer:

```swift
// ✅ GOOD - No warning, clear intent
let result = GMPInteger() // Mutated through pointer below
__gmpz_add(&result._storage.value, &a._storage.value, &b._storage.value)
return result
```

**Affected Functions:**
All static/immutable functions that create a new `GMPInteger` and mutate it via C pointer:
- Arithmetic: `adding`, `subtracting`, `multiplied`, `negated`, `absoluteValue`
- Division: `floorDivided`, `floorRemainder`, `ceilingDivided`, `ceilingRemainder`, `truncatedDivided`, `truncatedRemainder`, `modulo`, `exactDivision`
- Number Theory: `gcd`, `lcm`, `extendedGCD`, `modularInverse`, `nextPrime`, `previousPrime`, `factorial`, `binomial`, `fibonacci`, `lucas`
- Exponentiation: `raisedToPower`, `power`

**Key Insight:**
Swift's compiler doesn't recognize mutations through C pointers as mutations of the Swift variable. Using `let` is semantically correct since the Swift variable itself isn't mutated - only the underlying C struct is modified.

### Access Modifier Issues in Extensions

**Problem:**
Extensions in separate files cannot access `private` members of the original type, causing compilation errors when trying to access `_storage` or call `_ensureUnique()`.

**Error Message:**
```
error: '_storage' is inaccessible due to 'private' protection level
error: '_ensureUnique' is inaccessible due to 'private' protection level
```

**Root Cause:**
- `_GMPIntegerStorage` was declared as `private final class`
- `_storage` property was declared as `private var`
- `_ensureUnique()` method was declared as `private mutating func`

**Solution:**
Change access modifiers to `internal` to allow access from extensions in the same module:

```swift
// ❌ BAD - Private prevents extension access
private final class _GMPIntegerStorage { ... }
private var _storage: _GMPIntegerStorage
private mutating func _ensureUnique() { ... }

// ✅ GOOD - Internal allows extension access
internal final class _GMPIntegerStorage { ... }
internal var _storage: _GMPIntegerStorage
internal mutating func _ensureUnique() { ... }
```

**Note:** The comment in the code already indicated `internal` was intended: "It's marked as `final` and `internal` to allow access from extensions in the same module."

**Affected Files:**
- `GMPInteger.swift` - Storage class and property declarations
- All extension files that access `_storage` or call `_ensureUnique()`

**Key Insight:**
In Swift, `private` restricts access to the same file, while `internal` allows access within the same module. Extensions in separate files need `internal` access.

### Comparison Operators with Non-BinaryInteger Types

**Problem:**
Using comparison operators (`<`, `>`, `>=`, etc.) directly on `GMPInteger` fails because it doesn't conform to `BinaryInteger`.

**Error Message:**
```
error: referencing operator function '<' on 'BinaryInteger' requires that 'GMPInteger' conform to 'BinaryInteger'
```

**Example:**
```swift
// ❌ BAD - Requires BinaryInteger conformance
if self < 0 {
    return -Int(remainderValue)
}
```

**Solution:**
Use the `sign` property or `compare(to:)` method instead:

```swift
// ✅ GOOD - Uses sign property
if self.sign < 0 {
    return -Int(remainderValue)
}

// ✅ GOOD - Uses compare method
if self.compare(to: GMPInteger(0)) < 0 {
    return -Int(remainderValue)
}

// ✅ GOOD - For comparisons with other GMPIntegers
if absRemainder.compare(to: absDivisor) < 0 {
    // ...
}
```

**Affected Code:**
- Division functions checking sign of `self` or comparing `GMPInteger` values
- Test code comparing `GMPInteger` values

**Key Insight:**
`GMPInteger` conforms to `Comparable` (providing `<`, `>`, etc. for `GMPInteger` vs `GMPInteger`), but not `BinaryInteger`. For sign checks, use `.sign` property. For comparisons, use `compare(to:)` or the `Comparable` operators when both operands are `GMPInteger`.

### Error Type Conformance for Testing

**Problem:**
Swift Testing framework's `#expect(throws:)` macro requires error types to conform to `Equatable`, but `GMPError` only conformed to `Error`.

**Error Message:**
```
error: macro 'expect(throws:_:sourceLocation:performing:)' requires that 'GMPError' conform to 'Equatable'
```

**Solution:**
Add `Equatable` conformance to the error enum:

```swift
// ❌ BAD - Missing Equatable
public enum GMPError: Error {
    case divisionByZero
    case invalidExponent(Int)
    // ...
}

// ✅ GOOD - Conforms to both Error and Equatable
public enum GMPError: Error, Equatable {
    case divisionByZero
    case invalidExponent(Int)
    // ...
}
```

**Note:** Associated values in enum cases automatically make the enum `Equatable` if all associated value types are `Equatable` (which `Int` is).

**Affected Files:**
- `GMPError.swift` - Error type definition
- All test files using `#expect(throws: GMPError.divisionByZero)`

**Key Insight:**
Swift Testing framework requires `Equatable` conformance to match thrown errors. This is automatic for simple enums, but must be explicitly declared.

## Testing Issues

### Test Coverage Gaps

**Problem:**
Functions with `Int` parameter variants were not tested, leaving significant code uncovered.

**Solution:**
Add comprehensive tests for all `Int` parameter variants:
- `exactlyDivided(by: Int)`
- `isDivisible(by: Int)`
- `isCongruent(to: Int, modulo: Int)`
- `gcd(_ a: GMPInteger, _ b: Int)` with edge cases (very large a, Int.min)
- `lcm(_ a: GMPInteger, _ b: Int)` with Int.min
- `modularInverse(modulo: GMPInteger)` with zero modulus
- `truncatedDivided(by: Int)` - all sign combinations, Int.min edge case
- `truncatedRemainder(dividingBy: Int)` - all sign combinations
- `truncatedQuotientAndRemainder(dividingBy: Int)` - all sign combinations, identity verification
- `modulo(_ modulus: Int)` - all sign combinations, non-negative result guarantee

**Testing Patterns:**
- Test positive and negative values
- Test zero cases
- Test boundary values (Int.max, Int.min)
- Test error cases (division by zero, invalid exponents)
- Verify immutability of operands

### Unused Test Results

**Problem:**
Tests were calling functions but discarding the results with `_`, making the tests ineffective at catching bugs.

**Example:**
```swift
// ❌ BAD - Result not checked
_ = a.bitwiseAnd(b)
#expect(a.toInt() == 10)  // Only checks operand unchanged, not the result!
```

**Solution:**
Always capture and verify function results:

```swift
// ✅ GOOD - Result captured and verified
let result = a.bitwiseAnd(b)
#expect(result.toInt() == (10 & -3))  // Verify correct result
#expect(a.toInt() == 10)  // Also verify operand unchanged
```

**Affected Test Functions:**
- `aND_positive_and_negative_integers()` - wasn't checking bitwise AND result
- `xOR_positive_and_negative_integers()` - wasn't checking bitwise XOR result
- `xOR_two_negative_integers()` - wasn't checking bitwise XOR result

**Testing Best Practice:**
When testing functions that return values:
1. Capture the result in a variable
2. Verify the result matches expected behavior (compare with Swift's native operations when applicable)
3. Verify operands remain unchanged (for non-mutating functions)

### Optional String Initializer in Tests

**Problem:**
The `GMPInteger` string initializer `init?(_ string: String, base: Int = 10)` returns an optional, but tests were using it without unwrapping, causing compilation errors.

**Error Message:**
```
error: value of optional type 'GMPInteger?' must be unwrapped to refer to member 'bitwiseAnd' of wrapped base type 'GMPInteger'
```

**Example:**
```swift
// ❌ BAD - Compilation error
let a = GMPInteger("123456789012345678901234567890")
let result = a.bitwiseAnd(b)  // Error: a is GMPInteger?
```

**Solution:**
Force unwrap the optional in tests (since test strings are known to be valid):

```swift
// ✅ GOOD - Force unwrap known-valid strings
let a = GMPInteger("123456789012345678901234567890")!
let result = a.bitwiseAnd(b)
```

**Affected Test Functions:**
- `testAND_large_values()` - String initialization for large test values
- Any test using `GMPInteger(_: String)` initializer

**Key Insight:**
In production code, handle the optional properly. In tests with known-valid strings, force unwrapping is acceptable.

### Missing Try Statements in Tests

**Problem:**
Test functions calling throwing functions without `try` cause compilation errors.

**Error Message:**
```
error: call can throw but is not marked with 'try'
note: did you mean to use 'try'?
```

**Example:**
```swift
// ❌ BAD - Missing try
let quotient = dividend.floorDivided(by: divisor)
let remainder = dividend.floorRemainder(dividingBy: divisor)
```

**Solution:**
Add `try` before all throwing function calls in tests:

```swift
// ✅ GOOD - Uses try
let quotient = try dividend.floorDivided(by: divisor)
let remainder = try dividend.floorRemainder(dividingBy: divisor)
```

**Note:** Test functions are marked `async throws`, so they can propagate errors. Use `try` for all throwing operations.

**Affected Test Files:**
- All division test files calling throwing division functions
- Functions that throw: `floorDivided`, `floorRemainder`, `ceilingDivided`, `truncatedDivided`, `modulo`, `exactlyDivided`, `isDivisible(byPowerOf2:)`, `isCongruent(moduloPowerOf2:)`, power-of-2 division functions

**Key Insight:**
When implementing TDD, remember that all throwing functions require `try` in the calling code, including test code. Batch find/replace can help fix this systematically across test files.

### Test Coverage for Int.min Branches

**Problem:**
Functions that handle `Int.min` as a special case to avoid arithmetic overflow may have their `Int.min` branches showing 0% coverage in coverage reports, even when the functions are tested with other negative values.

**Root Cause:**
- Tests may use negative values like `-3` or `-10`, which hit the `else` branch of the ternary operator but not the `Int.min` branch
- Coverage tools may not clearly distinguish which branch of a ternary operator was executed
- The `Int.min` case requires explicit testing to ensure the special handling is covered

**Example:**
```swift
// Code with Int.min handling
let absValue: CUnsignedLong = value == Int.min 
    ? CUnsignedLong(Int.max) + 1 
    : CUnsignedLong(-value)

// ❌ BAD - Test doesn't cover Int.min branch
@Test
func adding_Int_NegativeInt_ReturnsDifference() async throws {
    let a = GMPInteger(5)
    let result = a.adding(-3)  // Uses -3, not Int.min
    #expect(result.toInt() == 2)
}
```

**Solution:**
Add explicit tests that pass `Int.min` as a parameter to ensure the special case branch is covered:

```swift
// ✅ GOOD - Explicitly tests Int.min branch
@Test
func adding_Int_IntMin_VerifiesSpecialCaseHandling() async throws {
    let a = GMPInteger(10)
    let other = Int.min
    let result = a.adding(other)
    // Verify result is computed correctly using Int.min special case
    let expected = GMPInteger(10).subtracting(GMPInteger(Int.max).adding(1))
    #expect(result == expected)
}

@Test
func power_IntMinBase() async throws {
    // Test Int.min as base with even exponent
    let result = GMPInteger.power(base: Int.min, exponent: 2)
    let minGMP = GMPInteger(Int.min)
    let expected = minGMP.multiplied(by: minGMP)
    #expect(result == expected)
}

@Test
func floorDividedByInt_IntMinDivisor_HappyCase() async throws {
    // Test Int.min as divisor
    let dividend = GMPInteger(10)
    let divisor = Int.min
    let quotient = try dividend.floorDivided(by: divisor)
    // Verify Int.min branch is executed without overflow
    #expect(quotient.toInt() == 0 || quotient.toInt() == -1)
}
```

**Finding Uncovered Int.min Branches:**
1. Search for `Int.min` in source files: `grep -r "Int\.min" Sources/`
2. Check coverage for those specific lines using `llvm-cov show`
3. Look for ternary operators or if statements checking `value == Int.min`
4. Add tests that explicitly pass `Int.min` as the parameter

**Affected Functions:**
- `adding(_ other: Int)` - when `other == Int.min`
- `subtracting(_ lhs: Int, _ rhs: GMPInteger)` - when `lhs == Int.min`
- `floorDivided(by: Int)` - when `divisor == Int.min`
- `ceilingDivided(by: Int)` - when `divisor == Int.min`
- `truncatedDivided(by: Int)` - when `divisor == Int.min`
- `gcd(_ a: GMPInteger, _ b: Int)` - when `b == Int.min`
- `lcm(_ a: GMPInteger, _ b: Int)` - when `b == Int.min`
- `power(base: Int, exponent: Int)` - when `base == Int.min`

**Key Insight:**
Even if a function is tested with negative values, the `Int.min` branch requires explicit testing. Use `Int.min` directly in test parameters to ensure the special case handling is covered. Compute expected values using `GMPInteger` operations to avoid calculation errors.

## Code Quality and Tooling Issues

### SwiftLint Configuration Issues

**Problem:**
SwiftLint was flagging hundreds of violations:
- `identifier_name`: Short variable names (`a`, `b`, `n`, `k`, etc.) and underscore-prefixed names
- `type_name`: Underscore-prefixed types and long type names
- `large_tuple`: Tuples with more than 2 members
- `shorthand_operator`: Preferring `+=` over `a = a + b`
- `force_try`: Using `try!` instead of proper error handling
- `todo`: TODO comments in code
- `orphaned_doc_comment`: Documentation comments not attached to declarations
- `line_length`: Lines exceeding 120 characters

**Solution:**

**Configuration Changes** (`.swiftlint.yml`):
```yaml
disabled_rules:
  - type_name
  - shorthand_operator

identifier_name:
  min_length:
    warning: 0
    error: 0
  allowed_symbols: ["_"]

large_tuple:
  warning: 4
  error: 4
```

**Code-Level Fixes:**

1. **Force Try Violations**: Add `swiftlint:disable:next force_try` immediately before the line with `try!`:
```swift
// ❌ BAD - Disable comment too far from try!
// swiftlint:disable:next force_try
precondition(
    (try! value.modulo(two)).toInt() == 1,  // Not disabled!
    "error"
)

// ✅ GOOD - Disable comment right before try!
precondition(
    // swiftlint:disable:next force_try
    (try! value.modulo(two)).toInt() == 1,  // Properly disabled
    "error"
)
```

2. **TODO Violations**: Suppress with `swiftlint:disable:next todo` before TODO comments:
```swift
// swiftlint:disable:next todo
// TODO: This requires GMPRandomState to be implemented
```

3. **Line Length in Comments**: SwiftFormat doesn't format comment lines. Manually break long comments:
```swift
// ❌ BAD - Too long
// Given: A GMPInteger base (e.g., 3), negative exponent (e.g., -1), and modulus (e.g., 11) where 3 has modular inverse mod 11

// ✅ GOOD - Manually broken
// Given: A GMPInteger base (e.g., 3), negative exponent (e.g., -1),
// and modulus (e.g., 11) where 3 has modular inverse mod 11
```

4. **Orphaned Doc Comments**: Remove duplicate or unattached documentation comments.

**Key Points:**
- `swiftlint:disable:next` only affects the **immediately following line**
- SwiftFormat doesn't automatically format comment lines - break them manually
- Pre-commit hooks "fail" when SwiftFormat modifies files - this is expected; stage the changes and commit again
- Always place disable comments directly before the line they're disabling, not before function calls containing the violation

**Affected Files:**
- `.swiftlint.yml` - Configuration updates
- `GMPInteger+IO.swift` - Removed orphaned doc comments and dummy FILE* methods
- `GMPInteger+Division.swift` - Fixed force try violations
- `GMPInteger+Exponentiation.swift` - Fixed force try violations
- `GMPInteger+ExponentiationTests.swift` - Fixed line length violations

## Key Takeaways

1. **Always use pointer wrappers** (`withUnsafePointer`/`withUnsafeMutablePointer`) when passing GMP storage to C functions, especially when the same memory might be accessed multiple times.

2. **Use immutable method + assign pattern** for mutating operations that take `GMPInteger` parameters. This avoids exclusivity violations when `self` and the parameter are the same variable (e.g., `a.add(a)`).

3. **Handle `Int.min` specially** - Always check for `Int.min` before negating, as `-Int.min` causes arithmetic overflow. Use `CUnsignedLong(Int.max) + 1` to represent its absolute value.

4. **Handle negative values explicitly** when converting to unsigned types for GMP functions. Don't just use `abs()` - properly reduce modulo the relevant value.

5. **Use `let` for C-pointer mutations** - Variables mutated only through C pointers should be `let` with explanatory comments.

6. **Test all parameter variants** - if a function has both `GMPInteger` and `Int` versions, test both thoroughly.

7. **Edge cases matter** - Int.max, Int.min, zero, and negative values often reveal bugs in arithmetic operations.

8. **Always verify test results** - Don't discard function return values with `_`. Capture and verify results to ensure functions work correctly.

## Pointer Lifetime and Memory Safety Issues

### Dangling Pointers from Computed Properties

**Problem:**
Computed properties that return `UnsafePointer` or `UnsafeMutablePointer` to class properties (like `_storage.value`) create dangling pointers. The pointer becomes invalid once the property accessor returns, even if `withExtendedLifetime` is used, because the pointer's validity is tied to the closure scope, not the property return.

**Error Symptoms:**
- Crashes in GMP functions when accessing pointers
- Stack traces showing `__gmpn_copyi`, `__gmpz_get_str`, or similar GMP internal functions
- Crashes occur intermittently, often in formatted I/O operations

**Root Cause:**
```swift
// ❌ BAD - Returns dangling pointer
var cPointer: UnsafePointer<mpz_t> {
    return withExtendedLifetime(_storage) {
        return UnsafeRawPointer(&_storage.value).assumingMemoryBound(to: mpz_t.self)
    }
}
// Pointer is invalid after property returns!
```

**Solution:**
Replace computed properties with closure-based methods that ensure the pointer is only valid within the closure:

```swift
// ✅ GOOD - Pointer valid only within closure
internal func withCPointer<T>(_ body: (UnsafePointer<mpz_t>) throws -> T) rethrows -> T {
    return try withUnsafePointer(to: _storage.value) { ptr in
        try body(ptr)
    }
}

internal mutating func withMutableCPointer<T>(_ body: (UnsafeMutablePointer<mpz_t>) throws -> T) rethrows -> T {
    _ensureUnique()  // Ensure unique storage for mutations
    return try withUnsafeMutablePointer(to: &_storage.value) { ptr in
        try body(ptr)
    }
}
```

**Usage:**
```swift
// ✅ GOOD - Use closure-based access
z.withCPointer { ptr in
    withVaList([ptr]) { vaList in
        // Use vaList safely here
    }
}

var z = GMPInteger()
z.withMutableCPointer { ptr in
    GMPFormattedIO.scanf("Value: %Zd", ptr)
}
```

**Affected Types:**
- `GMPInteger` - Removed `cPointer` and `mutableCPointer` properties
- `GMPRational` - Removed `cPointer` and `mutableCPointer` properties
- `GMPFloat` - Removed `cPointer` and `mutableCPointer` properties

**Key Insight:**
Never return raw pointers from computed properties when the pointer points to a property of a class. Always use closure-based access methods that keep the pointer valid only within the closure scope.

### Random State Pointer Lifetime Issues

**Problem:**
`GMPRandomState.random(upperBound:)` and `random(bits:)` were passing `&_storage.value` directly to GMP functions, creating dangling pointers that caused hangs or crashes.

**Error Symptoms:**
- Tests hanging indefinitely in `__gmp_urandomm_ui` or `__gmp_urandomb_ui`
- Crashes in GMP random number generation functions

**Solution:**
Make the methods `mutating`, ensure unique storage, and use `withUnsafeMutablePointer` with `withExtendedLifetime`:

```swift
// ✅ GOOD - Safe pointer access
public mutating func random(upperBound: Int) -> Int {
    precondition(upperBound > 0, "upperBound must be positive")
    // Ensure unique storage for COW semantics
    if !isKnownUniquelyReferenced(&_storage) {
        _storage = _GMPRandomStateStorage(copying: _storage)
    }
    return withExtendedLifetime(_storage) {
        return withUnsafeMutablePointer(to: &_storage.value) { ptr in
            let result = __gmp_urandomm_ui(ptr, CUnsignedLong(upperBound))
            // ... handle result ...
        }
    }
}
```

**Affected Functions:**
- `GMPRandomState.random(upperBound:)`
- `GMPRandomState.random(bits:)`

**Key Insight:**
Always use `withUnsafeMutablePointer` or `withUnsafePointer` when passing class property addresses to C functions, and ensure the class instance stays alive with `withExtendedLifetime` if needed.

### scanf Operations Requiring Unique Storage

**Problem:**
`withMutableCPointer` methods for GMP types weren't ensuring unique storage before mutation, causing scanf operations to fail silently or produce incorrect results.

**Error Symptoms:**
- `scanf` operations returning 0 (no fields parsed)
- Values not being updated after `scanf` calls
- Test failures: `count == 0` when expecting `count == 1`

**Solution:**
Add `_ensureUnique()` call at the start of `withMutableCPointer` methods:

```swift
// ✅ GOOD - Ensures unique storage before mutation
internal mutating func withMutableCPointer<T>(_ body: (UnsafeMutablePointer<mpz_t>) throws -> T) rethrows -> T {
    _ensureUnique()  // Critical for scanf operations
    return try withUnsafeMutablePointer(to: &_storage.value) { ptr in
        try body(ptr)
    }
}
```

**Affected Types:**
- `GMPInteger.withMutableCPointer`
- `GMPRational.withMutableCPointer`
- `GMPFloat.withMutableCPointer`

**Key Insight:**
Any method that provides a mutable pointer for mutation must ensure unique storage first to maintain value semantics and prevent COW issues.

## GMP Library Issues

### Linear Congruential Generator Infinite Loop with Exponent = 1

**Problem:**
Initializing a linear congruential random number generator with `exponent = 1` causes an infinite loop in GMP's `randget_lc()` function, causing tests to hang indefinitely.

**Error Symptoms:**
- Tests hanging in `__gmp_urandomm_ui` → `randget_lc()` → `lc()`
- Stack traces showing infinite recursion in GMP random functions

**Root Cause:**
In GMP's `rand/randlc2x.c`, line 164:
```c
chunk_nbits = p->_mp_m2exp / 2;  // With m2exp=1, this becomes 0
```
Then at line 170:
```c
while (rbitpos + chunk_nbits <= nbits)  // If chunk_nbits=0, this is always true!
```
When `chunk_nbits = 0`, the loop condition `rbitpos + 0 <= nbits` is always true, and `rbitpos` never increases, creating an infinite loop.

**Solution:**
Add a precondition requiring `exponent >= 2`:

```swift
// ✅ GOOD - Prevents GMP bug
public init(
    linearCongruential2Exp seed: GMPInteger,
    multiplier: GMPInteger,
    addend: GMPInteger,
    exponent: Int
) {
    precondition(exponent > 0, "exponent must be positive")
    // GMP's linear congruential generator with exponent = 1 causes an infinite loop
    // in randget_lc() because chunk_nbits = m2exp / 2 = 0, making the while loop
    // condition always true. Minimum practical exponent is 2.
    precondition(exponent >= 2, "exponent must be at least 2 (exponent = 1 causes infinite loop in GMP)")
    // ... rest of implementation
}
```

**Affected Functions:**
- `GMPRandomState.init(linearCongruential2Exp:multiplier:addend:exponent:)`

**Key Insight:**
Even if GMP accepts a parameter value, it may have bugs with edge cases. Always test edge cases and add preconditions to prevent known GMP bugs from affecting Swift code.

## Copy-on-Write (COW) Semantics

### Mutating Methods Trigger COW

**Problem:**
Tests expected that calling `random()` on a `GMPRandomState` wouldn't trigger COW, but since `random()` is a `mutating` method, it does trigger COW when storage is shared.

**Error Symptoms:**
- Test failures: `state1._storage === state2._storage` after calling `random()`
- Tests expecting shared storage after mutations

**Solution:**
Update test expectations to reflect that mutating methods trigger COW:

```swift
// ✅ GOOD - Correct expectation
// When: Generate random numbers from state1 (mutating operation)
_ = state1.random(upperBound: 10)
_ = state1.random(bits: 8)

// Then: state1 and state2 no longer share storage (random generation is mutating)
// Note: Random generation advances the internal GMP state, and since it's mutating
// in Swift, it triggers COW. state1 gets its own copy of the storage.
#expect(state1._storage !== state2._storage)
```

**Key Insight:**
Any `mutating` method on a value type with COW semantics will trigger a copy if the storage is shared. Tests should reflect this behavior, not expect storage to remain shared after mutations.

## API Cleanup

### Removing Deprecated APIs

**Problem:**
Deprecated APIs like `GMPFloat.random2(limbs:exponent:)` were still present in the codebase, causing deprecation warnings and confusion.

**Solution:**
Remove deprecated methods and their tests entirely rather than keeping them marked as deprecated:

```swift
// ❌ BAD - Keeps deprecated API
@available(*, deprecated, message: "Use random(bits:using:) with GMPRandomState instead")
public static func random2(limbs: Int, exponent: Int) -> GMPFloat { ... }

// ✅ GOOD - Removed entirely
// Method removed - use random(bits:using:) with GMPRandomState instead
```

**Key Insight:**
If deprecated APIs aren't being used, remove them completely rather than keeping them marked as deprecated. This reduces API surface area and eliminates confusion.

## Test Infrastructure and Thread Safety Issues

### Stdin Redirection Deadlocks in Parallel Tests

**Problem:**
Tests using `withMockedStdin` to redirect stdin for `scanf` operations were hanging indefinitely when run in parallel. The hang occurred in `fflush(stdin)` within the C helper function.

**Error Symptoms:**
- Tests hanging in `__psynch_mutexwait()` → `flockfile()` → `fflush()`
- Stack traces showing deadlock in stdin file locking
- Intermittent failures when running full test suite multiple times

**Root Cause:**
- `fflush(stdin)` can deadlock when stdin is locked by another thread
- Concurrent tests trying to redirect the global `stdin` resource simultaneously
- No synchronization between parallel test executions

**Solution:**
1. Remove `fflush(stdin)` calls from C helper functions (not needed and causes deadlocks)
2. Add serial dispatch queue synchronization in Swift test helper:

```swift
// ✅ GOOD - Thread-safe stdin redirection
private static let stdinQueue = DispatchQueue(label: "com.kalliope.stdin-redirect")

private func withMockedStdin(_ input: String, execute body: () throws -> Void) throws {
    try Self.stdinQueue.sync {
        // All stdin redirection code here - serialized
    }
}
```

**Affected Files:**
- `Sources/CKalliopeBridge/CKalliope.c` - Removed `fflush(stdin)` from `ckalliope_redirect_stdin_from_file` and `ckalliope_restore_stdin`
- `Tests/KalliopeTests/Core/FormattedIO/GMPFormattedIOTests.swift` - Added serial queue synchronization

**Key Insight:**
Global resources like `stdin` must be accessed serially when modified. Use dispatch queues to serialize access in parallel test environments.

### Flaky "Bad File Descriptor" Errors in File Creation

**Problem:**
Tests creating temporary files using `String.write(to:atomically:encoding:)` were failing intermittently with "Bad file descriptor" errors when run in parallel.

**Error Message:**
```
Error Domain=NSCocoaErrorDomain Code=512 "The file ... couldn't be saved"
NSPOSIXErrorDomain Code=9 "Bad file descriptor"
```

**Root Cause:**
- `String.write(to:atomically:encoding:)` has race conditions under concurrent file system access
- Multiple tests creating files in the same temporary directory simultaneously
- File descriptors becoming invalid during concurrent operations

**Solution:**
Replace `String.write(to:atomically:encoding:)` with a thread-safe helper that uses `FileManager.createFile` + `FileHandle` operations:

```swift
// ✅ GOOD - Thread-safe file creation
private static func createTempFile(with content: String) throws -> URL {
    let tempURL = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString)
    FileManager.default.createFile(atPath: tempURL.path, contents: nil)
    let writeHandle = try FileHandle(forWritingTo: tempURL)
    defer { try? writeHandle.close() }
    guard let data = content.data(using: .utf8) else {
        throw NSError(domain: "GMPRationalIOTests", code: 1, 
                     userInfo: [NSLocalizedDescriptionKey: "Failed to convert string to UTF-8 data"])
    }
    try writeHandle.write(contentsOf: data)
    try writeHandle.synchronize()
    try writeHandle.close()
    return tempURL
}
```

**Affected Files:**
- `Tests/KalliopeTests/Core/Rational/GMPRational+IOTests.swift` - Replaced all 8 instances of `String.write(to:atomically:encoding:)` with `createTempFile(with:)` helper

**Key Insight:**
`FileManager.createFile` + `FileHandle` operations are more robust under concurrent access than `String.write(to:atomically:encoding:)`. Always use explicit file handle operations for thread-safe file creation in parallel test environments.
