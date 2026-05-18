# Bug Catcher Demo

## Quick Demo

Copy this code into a file and watch Bug Catcher catch the bugs:

### demo.js

```javascript
// Bug Catcher will catch 5 bugs in this code

const express = require('express');
const app = express();

app.use(express.json());

// Bug 1: SQL Injection
app.get('/user', (req, res) => {
  const query = `SELECT * FROM users WHERE id = ${req.query.id}`;
  db.query(query, (err, result) => {
    res.json(result);
  });
});

// Bug 2: XSS
app.post('/profile', (req, res) => {
  const html = `<h1>Welcome, ${req.body.name}</h1>`;
  res.send(html);
});

// Bug 3: Hardcoded Secret
const API_KEY = 'sk-proj-1234567890abcdef';
const JWT_SECRET = 'super-secret-key';

// Bug 4: Unhandled Promise
app.get('/data', async (req, res) => {
  const response = await fetch('https://api.example.com/data');
  const data = await response.json();
  res.json(data);
});

// Bug 5: Path Traversal
app.get('/file', (req, res) => {
  const filePath = req.query.path;
  res.sendFile(filePath);
});

app.listen(3000);
```

### Expected Output

```
BUG-CATCHER REPORT
==================

[CRITICAL] security-scan: SQL injection at line 8
  File: demo.js
  Code: `SELECT * FROM users WHERE id = ${req.query.id}`
  Fix: Use parameterized query: db.query('SELECT * FROM users WHERE id = ?', [req.query.id])
  CWE: CWE-89

[CRITICAL] security-scan: XSS vulnerability at line 15
  File: demo.js
  Code: `<h1>Welcome, ${req.body.name}</h1>`
  Fix: Escape HTML: `<h1>Welcome, ${escapeHtml(req.body.name)}</h1>`
  CWE: CWE-79

[CRITICAL] security-scan: Hardcoded API key at line 20
  File: demo.js
  Code: const API_KEY = 'sk-proj-1234567890abcdef'
  Fix: Use environment variable: process.env.API_KEY
  CWE: CWE-798

[CRITICAL] security-scan: Hardcoded JWT secret at line 21
  File: demo.js
  Code: const JWT_SECRET = 'super-secret-key'
  Fix: Use environment variable: process.env.JWT_SECRET
  CWE: CWE-798

[WARNING] error-patterns: Unhandled promise rejection at line 24
  File: demo.js
  Code: const response = await fetch('https://api.example.com/data')
  Fix: Wrap in try-catch: try { ... } catch (err) { res.status(500).json({error: 'Failed to fetch'}) }

[CRITICAL] security-scan: Path traversal at line 31
  File: demo.js
  Code: res.sendFile(req.query.path)
  Fix: Validate path: const safePath = path.join(UPLOAD_DIR, req.query.path); if (!safePath.startsWith(UPLOAD_DIR)) return res.status(403).send('Access denied');
  CWE: CWE-22

SUMMARY: 5 critical, 1 warning, 0 info
```

## Manual Review Demo

```bash
# Review a specific file
/review-bugs demo.js

# Review with only security checks
/review-bugs demo.js --checks security

# Review staged changes (pre-commit)
/review-bugs --staged
```

## Configuration Demo

Create `.bug-catcher.json`:

```json
{
  "autoFix": true,
  "checks": {
    "securityScan": { "enabled": true, "severity": "error" },
    "errorPatterns": { "enabled": true, "severity": "warning" },
    "logicVerify": { "enabled": false },
    "perfCheck": { "enabled": false },
    "testCoverage": { "enabled": false }
  },
  "ignore": ["test/**", "*.test.js"]
}
```

This configuration:
- Enables auto-fix for safe issues
- Only runs security and error pattern checks
- Ignores test files
