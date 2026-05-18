# Test Coverage Check

## Purpose

Identify code paths that lack test coverage. AI-generated code often has tests for the happy path but misses edge cases and error conditions.

## Check ID

`test-coverage`

## Patterns to Detect

### 1. Missing Edge Case Tests

**Pattern**: Functions with boundary conditions that aren't tested.

**Detect**:
- Numeric functions without tests for 0, negative, MAX_SAFE_INTEGER
- String functions without tests for empty string, very long strings, unicode
- Array functions without tests for empty array, single element, very large arrays
- Date functions without tests for leap years, timezone edge cases

**Example (Missing)**:
```javascript
function divide(a, b) {
  if (b === 0) throw new Error('Division by zero');
  return a / b;
}

// Tests exist for: divide(10, 2) = 5
// Tests missing for: divide(0, 5), divide(-10, 2), divide(10, 0), divide(0, 0)
```

### 2. Error Path Coverage

**Pattern**: Error handling code that isn't tested.

**Detect**:
- Try-catch blocks where catch isn't tested
- Error throwing without corresponding test
- Validation code without invalid input tests
- Fallback logic without test for fallback condition

**Example (Missing)**:
```javascript
function processUser(input) {
  if (!input.name) throw new ValidationError('Name required');
  // ...
}

// Test exists for: processUser({ name: 'John' })
// Test missing for: processUser({}), processUser(null), processUser(undefined)
```

### 3. Async Error Handling

**Pattern**: Promise rejection paths not tested.

**Detect**:
- Async functions without tests for rejection
- Promise chains without tests for .catch()
- Missing tests for timeout scenarios
- Missing tests for network failure scenarios

### 4. Type Variation Coverage

**Pattern**: Functions that handle multiple types but only test one.

**Detect**:
- Functions accepting string | number but only testing string
- Functions accepting arrays but only testing non-empty arrays
- Optional parameters without tests for undefined/null

### 5. State Transition Coverage

**Pattern**: State machines with untested transitions.

**Detect**:
- Missing tests for invalid state transitions
- Missing tests for concurrent state changes
- Missing tests for state reset scenarios

### 6. Integration Point Coverage

**Pattern**: External dependencies without mocked tests.

**Detect**:
- API calls without error response tests
- Database operations without connection failure tests
- File operations without permission error tests

### 7. Concurrency Coverage

**Pattern**: Async operations without race condition tests.

**Detect**:
- Parallel operations without tests for ordering
- Shared state without tests for concurrent access
- Missing tests for cancellation scenarios

## Test Gap Report

For each detected gap, output:

```
[test-coverage] SEVERITY: Missing test for: description
  Function: functionName at line N
  File: path/to/file.ext
  Gap: What's not tested
  Suggested Test:
    it('should handle edge case', () => {
      // Arrange
      const input = ...;
      // Act
      const result = functionUnderTest(input);
      // Assert
      expect(result).toBe(...);
    });
```

## Severity Rules

- **CRITICAL**: Missing tests for error paths in security-critical code
- **WARNING**: Missing edge case tests, missing async error tests
- **INFO**: Missing type variation tests, missing integration tests
