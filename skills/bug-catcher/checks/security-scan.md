# Security Scan

## Purpose

Detect security vulnerabilities in AI-generated code. AI models are trained on code from the internet — including insecure patterns. This check catches them.

## Check ID

`security-scan`

## Patterns to Detect

### 1. Injection Vulnerabilities

**Pattern**: User input used directly in queries, commands, or templates.

**Detect**:
- SQL string interpolation (`SELECT * FROM users WHERE id = ${id}`)
- Command injection (`exec(userInput)`, `spawn('sh', ['-c', cmd])`)
- Template injection (server-side template rendering with user data)
- LDAP/XPath/NoSQL injection patterns

**Example (Bad)**:
```javascript
db.query(`SELECT * FROM users WHERE name = '${req.body.name}'`);
```

**Example (Fix)**:
```javascript
db.query('SELECT * FROM users WHERE name = ?', [req.body.name]);
```

### 2. Cross-Site Scripting (XSS)

**Pattern**: User input rendered in HTML without sanitization.

**Detect**:
- `innerHTML` with user data
- Template literals in HTML context
- `document.write()` with dynamic content
- Missing Content-Security-Policy headers
- `dangerouslySetInnerHTML` without sanitization

**Example (Bad)**:
```javascript
element.innerHTML = `Welcome, ${userName}`;
```

**Example (Fix)**:
```javascript
element.textContent = `Welcome, ${userName}`;
// Or with sanitization:
element.innerHTML = sanitize(`Welcome, ${escapeHtml(userName)}`);
```

### 3. Hardcoded Secrets

**Pattern**: Credentials, tokens, or keys embedded in code.

**Detect**:
- API keys in source code
- Passwords in configuration
- Private keys in files
- JWT secrets hardcoded
- Connection strings with credentials

**Example (Bad)**:
```javascript
const API_KEY = 'sk-1234567890abcdef';
const dbPassword = 'admin123';
```

**Example (Fix)**:
```javascript
const API_KEY = process.env.API_KEY;
if (!API_KEY) throw new Error('API_KEY environment variable is required');
```

### 4. Insecure Deserialization

**Pattern**: Parsing untrusted data without validation.

**Detect**:
- `JSON.parse()` on untrusted input without try-catch
- `eval()` or `Function()` with dynamic content
- `pickle.loads()` in Python with untrusted data
- XML parsing without disabling external entities

**Example (Bad)**:
```javascript
const data = JSON.parse(userInput); // Crashes on invalid JSON
const result = eval(userInput); // Remote code execution
```

**Example (Fix)**:
```javascript
let data;
try {
  data = JSON.parse(userInput);
} catch (e) {
  throw new ValidationError('Invalid JSON input');
}
// Never use eval with user input
```

### 5. Path Traversal

**Pattern**: File operations with user-controlled paths.

**Detect**:
- `fs.readFile(userPath)` without path validation
- Missing path.resolve() to prevent `../` traversal
- Serving files without restricting to allowed directory
- User-controlled filenames in uploads

**Example (Bad)**:
```javascript
app.get('/file', (req, res) => {
  res.sendFile(req.query.path); // Can access /etc/passwd
});
```

**Example (Fix)**:
```javascript
app.get('/file', (req, res) => {
  const safePath = path.resolve(UPLOAD_DIR, req.query.path);
  if (!safePath.startsWith(UPLOAD_DIR)) {
    return res.status(403).send('Access denied');
  }
  res.sendFile(safePath);
});
```

### 6. Missing Authentication/Authorization

**Pattern**: Endpoints or operations without proper access control.

**Detect**:
- API endpoints without auth middleware
- Missing role/permission checks
- IDOR (Insecure Direct Object Reference) patterns
- Client-side only authorization

### 7. Weak Cryptography

**Pattern**: Using outdated or weak cryptographic methods.

**Detect**:
- MD5 or SHA1 for password hashing
- DES or RC4 encryption
- Hard-coded initialization vectors
- Predictable random values for security purposes
- `Math.random()` for tokens/keys

**Example (Bad)**:
```javascript
const token = Math.random().toString(36); // Predictable!
const hash = crypto.createHash('md5').update(password).digest('hex'); // Weak!
```

**Example (Fix)**:
```javascript
const token = crypto.randomBytes(32).toString('hex');
const hash = await bcrypt.hash(password, 12);
```

### 8. Insecure HTTP

**Pattern**: Using HTTP instead of HTTPS, or disabling SSL verification.

**Detect**:
- `http://` URLs for API calls
- `rejectUnauthorized: false` in TLS options
- Missing certificate validation
- CORS misconfiguration (`Access-Control-Allow-Origin: *`)

### 9. Information Disclosure

**Pattern**: Leaking sensitive information in responses or logs.

**Detect**:
- Stack traces in production responses
- Database error messages exposed to users
- Logging sensitive data (passwords, tokens)
- Debug endpoints left enabled

### 10. Race Conditions (Security)

**Pattern**: TOCTOU (Time-of-Check-Time-of-Use) vulnerabilities.

**Detect**:
- Check-then-act on file operations
- Non-atomic balance operations
- Session fixation patterns

## Output Format

```
[security-scan] SEVERITY: Description at line N
  File: path/to/file.ext
  Code: the vulnerable code
  Fix: suggested fix
  CWE: CWE-XXX (if applicable)
```

## Severity Rules

- **CRITICAL**: SQL injection, RCE, hardcoded secrets, path traversal
- **WARNING**: XSS, weak crypto, missing auth, insecure deserialization
- **INFO**: Information disclosure, CORS issues, HTTP usage
