# Logic Verification

## Purpose

Catch logic errors that produce wrong results without crashing. These are the hardest bugs to find because the code "works" — just incorrectly.

## Check ID

`logic-verify`

## Patterns to Detect

### 1. Off-by-One Errors

**Pattern**: Loop bounds, array indices, or range checks that are off by one.

**Detect**:
- `<` vs `<=` in loop conditions
- Starting index 0 vs 1 for 1-based systems
- Pagination: page * size vs (page - 1) * size
- Date ranges: inclusive vs exclusive end dates

**Example (Bad)**:
```javascript
// Get last 10 items
const recent = items.slice(items.length - 10, items.length - 1);
// Misses the last item! Should be items.length
```

**Example (Fix)**:
```javascript
const recent = items.slice(-10);
```

### 2. Inverted Logic

**Pattern**: Boolean expressions that are backwards.

**Detect**:
- `if (condition)` when it should be `if (!condition)`
- Ternary operators with swapped branches
- Filter conditions that include when they should exclude
- Guard clauses that allow through when they should block

**Example (Bad)**:
```javascript
const adults = users.filter(user => user.age < 18); // Wrong! Gets minors
```

**Example (Fix)**:
```javascript
const adults = users.filter(user => user.age >= 18);
```

### 3. Boundary Condition Failures

**Pattern**: Code that works for normal values but fails at boundaries.

**Detect**:
- Missing empty array/string handling
- Missing single-element array handling
- Integer overflow possibilities
- Division by zero not guarded
- NaN propagation

**Example (Bad)**:
```javascript
function average(numbers) {
  const sum = numbers.reduce((a, b) => a + b, 0);
  return sum / numbers.length; // Returns NaN for empty array
}
```

**Example (Fix)**:
```javascript
function average(numbers) {
  if (numbers.length === 0) return 0;
  const sum = numbers.reduce((a, b) => a + b, 0);
  return sum / numbers.length;
}
```

### 4. Dead Code / Unreachable Logic

**Pattern**: Code that can never execute.

**Detect**:
- Conditions that are always true/false
- Return statements before unreachable code
- Switch cases that can never match
- Variables assigned but never used before reassignment

### 5. State Machine Errors

**Pattern**: Incorrect state transitions.

**Detect**:
- Missing state validation before transition
- Allowed transitions that shouldn't be
- State not reset after error
- Concurrent state modifications

### 6. String Comparison Issues

**Pattern**: String operations that fail for edge cases.

**Detect**:
- Case-sensitive comparisons when case-insensitive needed
- Missing trim() before comparison
- Unicode normalization issues
- Locale-dependent string operations

**Example (Bad)**:
```javascript
if (user.role === 'admin') { // Fails for 'Admin', 'ADMIN', ' admin '
```

**Example (Fix)**:
```javascript
if (user.role?.trim().toLowerCase() === 'admin') {
```

### 7. Floating Point Comparison

**Pattern**: Direct equality comparison of floating point numbers.

**Detect**:
- `===` on float values
- Accumulated floating point errors not handled
- Currency calculations using float instead of integer cents

**Example (Bad)**:
```javascript
if (total === 0.1 + 0.2) { // false! 0.1 + 0.2 = 0.30000000000000004
```

**Example (Fix)**:
```javascript
const EPSILON = 0.00001;
if (Math.abs(total - 0.3) < EPSILON) {
```

### 8. Short-Circuit Evaluation Traps

**Pattern**: Relying on short-circuit evaluation in ways that mask bugs.

**Detect**:
- `x && x.foo` when `x` could be falsy non-null (0, "", false)
- `x || default` when 0 or "" are valid values
- Using `??` vs `||` incorrectly

### 9. Copy-Paste Logic Errors

**Pattern**: Similar code blocks where one was updated but not the other.

**Detect**:
- Near-identical functions with small differences
- Repeated condition blocks with copy-paste artifacts
- Variable names that don't match their context

## Output Format

```
[logic-verify] SEVERITY: Description at line N
  File: path/to/file.ext
  Code: the problematic code
  Fix: suggested fix
```

## Severity Rules

- **CRITICAL**: Inverted logic in security checks, off-by-one in financial calculations
- **WARNING**: Boundary failures, dead code, state machine errors
- **INFO**: Floating point comparison, string comparison edge cases
