# Error Pattern Detection

## Purpose

Catch common error patterns that AI-generated code systematically misses. These are bugs that "work" in simple cases but crash in production.

## Check ID

`error-patterns`

## Patterns to Detect

### 1. Null/Undefined Access

**Pattern**: Accessing properties on potentially null/undefined values without checks.

**Detect**:
- Property access after function calls that could return null
- Array element access without bounds checking
- Optional chaining missing where needed
- Destructuring without null guards

**Example (Bad)**:
```javascript
const user = getUser(id);
return user.name; // Crashes if user is null
```

**Example (Fix)**:
```javascript
const user = getUser(id);
if (!user) throw new NotFoundError(`User ${id} not found`);
return user.name;
```

### 2. Unhandled Promises

**Pattern**: Async operations without proper error handling.

**Detect**:
- `await` without try-catch
- `.then()` without `.catch()`
- Fire-and-forget promises
- Missing `async` keyword on function using await

**Example (Bad)**:
```javascript
async function fetchData() {
  const res = await fetch(url); // Crashes on network error
  return res.json();
}
```

**Example (Fix)**:
```javascript
async function fetchData() {
  try {
    const res = await fetch(url);
    if (!res.ok) throw new HttpError(res.status);
    return res.json();
  } catch (err) {
    logger.error('Failed to fetch data', { url, error: err });
    throw err;
  }
}
```

### 3. Type Coercion Traps

**Pattern**: Implicit type conversions that produce unexpected results.

**Detect**:
- `parseInt()` without radix or on non-string
- `==` instead of `===` for comparisons
- String + number concatenation instead of template literals
- Boolean coercion of truthy/falsy values

**Example (Bad)**:
```javascript
const count = parseInt(userInput); // NaN if input is "abc"
if (count == 0) { ... } // true for "", null, undefined, false
```

**Example (Fix)**:
```javascript
const count = Number(userInput);
if (isNaN(count) || count < 0) throw new ValidationError('Invalid count');
if (count === 0) { ... }
```

### 4. Resource Leaks

**Pattern**: Resources opened but never closed.

**Detect**:
- File handles without try-with-resources or finally block
- Database connections without cleanup
- Event listeners without removal
- Timers without clearTimeout/clearInterval

**Example (Bad)**:
```javascript
const data = fs.readFileSync('file.txt');
// File handle leaked if error occurs before close
```

**Example (Fix)**:
```javascript
let fh;
try {
  fh = await fs.open('file.txt', 'r');
  const data = await fh.readFile('utf8');
} finally {
  await fh?.close();
}
```

### 5. Race Conditions

**Pattern**: Concurrent access to shared state without synchronization.

**Detect**:
- Read-modify-write without locks
- Check-then-act patterns
- Shared mutable state in async code
- Missing atomicity in multi-step operations

### 6. Array/String Boundary Errors

**Pattern**: Off-by-one and boundary violations.

**Detect**:
- `array.length - 1` in loop conditions (should be `< length`)
- Substring/slice with hardcoded indices
- Missing empty array/string checks before access

### 7. Error Swallowing

**Pattern**: Catch blocks that hide errors.

**Detect**:
- Empty catch blocks
- Catch blocks that only log but don't re-throw
- Generic catch-all without specific handling
- `catch (e) {}` patterns

## Output Format

```
[error-patterns] SEVERITY: Description at line N
  File: path/to/file.ext
  Code: the problematic code
  Fix: suggested fix
```

## Severity Rules

- **CRITICAL**: Race conditions, resource leaks in loops, null access in critical paths
- **WARNING**: Unhandled promises, type coercion, missing null checks
- **INFO**: Error swallowing, minor boundary issues
