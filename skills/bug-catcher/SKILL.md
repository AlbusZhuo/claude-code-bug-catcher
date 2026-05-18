# Bug Catcher

## Purpose

Automatically catch bugs in AI-generated code before it runs. This skill activates when Claude Code writes or modifies code, running 5 parallel checks to identify issues.

## Activation

This skill activates automatically when:
- Claude Code writes new code (any language)
- Claude Code modifies existing code
- User invokes `/review-bugs`

## Workflow

### Step 1: Detect Changes

When code is written or modified:
1. Identify which files changed
2. Identify which functions/methods were added or modified
3. Determine the programming language

### Step 2: Run Parallel Checks

Execute all 5 checks simultaneously on the changed code:

```
/checks/error-patterns.md   → Null refs, type errors, unhandled promises, race conditions
/checks/logic-verify.md     → Off-by-one, boundary conditions, inverted logic, dead code
/checks/security-scan.md    → Injection, XSS, hardcoded secrets, unsafe deserialization
/checks/perf-check.md       → N+1 queries, memory leaks, unnecessary allocations, blocking I/O
/checks/test-coverage.md    → Untested branches, missing edge cases, assertion gaps
```

### Step 3: Report Findings

Output a prioritized report:

```
BUG-CATCHER REPORT
==================

[CRITICAL] security-scan: SQL injection at line 15
  File: src/db.ts
  Code: `SELECT * FROM users WHERE id = ${id}`
  Fix: Use parameterized query: `SELECT * FROM users WHERE id = ?`

[WARNING] error-patterns: Unhandled null at line 8
  File: src/parser.ts
  Code: const user = getUser(); return user.name;
  Fix: Add null check: if (!user) throw new Error('User not found');

[INFO] perf-check: Unnecessary array allocation at line 22
  File: src/utils.ts
  Code: const arr = [...new Array(1000)].map((_, i) => i)
  Fix: Use Array.from({length: 1000}, (_, i) => i)

SUMMARY: 1 critical, 1 warning, 1 info
```

### Step 4: Auto-Fix (if enabled)

For issues with clear fixes:
1. Show the proposed fix
2. Apply if `autoFix` is enabled in `.bug-catcher.json`
3. Skip if fix is ambiguous or risky

## Severity Levels

- **CRITICAL**: Security vulnerabilities, data loss risks, crash-causing bugs. Must fix before commit.
- **WARNING**: Logic errors, missing error handling, potential bugs. Should fix before commit.
- **INFO**: Performance issues, code style, minor improvements. Fix when convenient.

## Configuration

Read `.bug-catcher.json` from project root if it exists:

```json
{
  "autoFix": false,
  "checks": {
    "errorPatterns": { "enabled": true, "severity": "warning" },
    "logicVerify": { "enabled": true, "severity": "warning" },
    "securityScan": { "enabled": true, "severity": "error" },
    "perfCheck": { "enabled": true, "severity": "info" },
    "testCoverage": { "enabled": true, "severity": "info" }
  },
  "ignore": ["*.test.ts", "*.spec.ts", "node_modules/**"]
}
```

## Manual Invocation

```
/review-bugs                  — Review current file
/review-bugs <file>           — Review specific file
/review-bugs --checks security,logic  — Run specific checks only
/review-bugs --staged         — Review staged changes (pre-commit)
/review-bugs --fix            — Review and auto-fix safe issues
```

## Integration with Other Skills

Bug Catcher works alongside other Claude Code skills:
- Runs after code generation skills
- Runs before commit/push skills
- Can be chained with `/review` for comprehensive analysis
