# Performance Check

## Purpose

Detect performance issues that work fine in development but degrade at scale. AI models optimize for "correct" code, not "fast" code.

## Check ID

`perf-check`

## Patterns to Detect

### 1. N+1 Query Patterns

**Pattern**: Looping over items and making individual database/API calls.

**Detect**:
- Database queries inside loops
- API calls inside loops
- Sequential async operations that could be parallel
- Missing batch operations

**Example (Bad)**:
```javascript
for (const userId of userIds) {
  const user = await db.query('SELECT * FROM users WHERE id = ?', [userId]);
  results.push(user);
}
```

**Example (Fix)**:
```javascript
const users = await db.query('SELECT * FROM users WHERE id IN (?)', [userIds]);
```

### 2. Unnecessary Allocations

**Pattern**: Creating objects/arrays that could be avoided.

**Detect**:
- Creating arrays just to iterate (use generators)
- Intermediate arrays in chains (filter → map → reduce)
- Object spread in loops
- String concatenation in loops (use join or template)
- Unnecessary cloning

**Example (Bad)**:
```javascript
const result = items
  .filter(x => x.active)     // Creates intermediate array
  .map(x => x.value)         // Creates another array
  .reduce((a, b) => a + b);  // Creates yet another
```

**Example (Fix)**:
```javascript
const result = items.reduce((sum, x) => {
  return x.active ? sum + x.value : sum;
}, 0);
```

### 3. Blocking Operations

**Pattern**: Synchronous operations that block the event loop.

**Detect**:
- `fs.readFileSync()` in request handlers
- `JSON.parse()` on large payloads without streaming
- CPU-intensive operations without worker threads
- Synchronous crypto operations

**Example (Bad)**:
```javascript
app.get('/data', (req, res) => {
  const data = fs.readFileSync('large-file.json', 'utf8');
  res.json(JSON.parse(data));
});
```

**Example (Fix)**:
```javascript
app.get('/data', async (req, res) => {
  const stream = fs.createReadStream('large-file.json');
  res.type('json');
  stream.pipe(res);
});
```

### 4. Memory Leaks

**Pattern**: Objects that accumulate without being released.

**Detect**:
- Global arrays/maps that grow without bounds
- Event listeners added without removal
- Closures capturing large scopes
- Circular references preventing GC
- Missing cleanup in component unmount

**Example (Bad)**:
```javascript
const cache = {};
function addToCache(key, value) {
  cache[key] = value; // Never cleaned up!
}
```

**Example (Fix)**:
```javascript
const cache = new Map();
const MAX_CACHE = 1000;

function addToCache(key, value) {
  if (cache.size >= MAX_CACHE) {
    const firstKey = cache.keys().next().value;
    cache.delete(firstKey);
  }
  cache.set(key, value);
}
```

### 5. Inefficient Algorithms

**Pattern**: O(n²) or worse when O(n) or O(n log n) is possible.

**Detect**:
- Nested loops over the same data
- Linear search when hash map could be used
- Repeated sorting of the same data
- String concatenation in loops

**Example (Bad)**:
```javascript
// O(n²) - checking if array has duplicates
for (let i = 0; i < arr.length; i++) {
  for (let j = i + 1; j < arr.length; j++) {
    if (arr[i] === arr[j]) return true;
  }
}
```

**Example (Fix)**:
```javascript
// O(n) - using Set
const seen = new Set();
for (const item of arr) {
  if (seen.has(item)) return true;
  seen.add(item);
}
```

### 6. Redundant Computations

**Pattern**: Computing the same thing multiple times.

**Detect**:
- Same calculation in both if and else branches
- Repeated property access in loops
- Date parsing in loops
- Regex compilation in loops

**Example (Bad)**:
```javascript
for (const item of items) {
  if (new Date(item.date) > new Date('2024-01-01')) {
    // new Date('2024-01-01') created every iteration!
  }
}
```

**Example (Fix)**:
```javascript
const cutoff = new Date('2024-01-01');
for (const item of items) {
  if (new Date(item.date) > cutoff) {
    // cutoff created once
  }
}
```

### 7. Missing Indexes

**Pattern**: Database queries on unindexed columns.

**Detect**:
- WHERE clauses on non-indexed columns
- JOIN conditions on non-indexed columns
- ORDER BY on non-indexed columns
- Frequent queries that could benefit from composite indexes

### 8. Large Payload Issues

**Pattern**: Processing large data without streaming or pagination.

**Detect**:
- Loading entire file into memory
- Fetching all records when only some needed
- Missing pagination in API responses
- Large JSON serialization without streaming

### 9. Synchronous I/O in Async Context

**Pattern**: Using sync versions of I/O functions in async code.

**Detect**:
- `readFileSync` in Express/Fastify handlers
- `execSync` in async functions
- `globSync` in request handlers

## Output Format

```
[perf-check] SEVERITY: Description at line N
  File: path/to/file.ext
  Code: the inefficient code
  Fix: suggested optimization
  Impact: Estimated improvement (e.g., "O(n²) → O(n)")
```

## Severity Rules

- **CRITICAL**: N+1 queries in hot paths, memory leaks in long-running processes
- **WARNING**: Blocking operations, inefficient algorithms, redundant computations
- **INFO**: Minor allocation optimizations, missing indexes
