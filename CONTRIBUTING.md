# Contributing to Claude Code Bug Catcher

We love contributions! This guide will help you get started.

## Ways to Contribute

1. **Add new check patterns** — Extend existing checks with new patterns
2. **Add new check modules** — Create entirely new check categories
3. **Fix false positives** — Improve detection accuracy
4. **Improve documentation** — Better examples, clearer explanations
5. **Report bugs** — Help us improve Bug Catcher

## Adding New Check Patterns

### 1. Identify the Pattern

What bug pattern are you seeing that Bug Catcher misses? Be specific:
- What code triggers the bug?
- What's the expected behavior vs actual?
- How common is this pattern?

### 2. Add to Existing Check

Each check file follows this structure:

```markdown
### N. Pattern Name

**Pattern**: One-line description of what to detect.

**Detect**:
- Bullet list of specific code patterns to look for
- Each item should be a concrete, actionable rule

**Example (Bad)**:
```language
// Code that has the bug
```

**Example (Fix)**:
```language
// Code with the fix applied
```
```

### 3. Submit PR

```bash
# Fork and clone
git clone https://github.com/YOUR_USERNAME/claude-code-bug-catcher.git

# Create branch
git checkout -b add-pattern-name

# Edit the relevant check file
# skills/bug-catcher/checks/error-patterns.md
# skills/bug-catcher/checks/logic-verify.md
# skills/bug-catcher/checks/security-scan.md
# skills/bug-catcher/checks/perf-check.md
# skills/bug-catcher/checks/test-coverage.md

# Commit and push
git add .
git commit -m "feat: add [pattern name] to [check module]"
git push origin add-pattern-name

# Create PR on GitHub
```

## Adding New Check Modules

### 1. Create the Check File

Create a new `.md` file in `skills/bug-catcher/checks/`:

```markdown
# Check Name

## Purpose

One paragraph describing what this check catches.

## Check ID

`check-name`

## Patterns to Detect

### 1. Pattern Name

**Pattern**: Description.

**Detect**:
- Rules

**Example (Bad)**:
```language
// Bad code
```

**Example (Fix)**:
```language
// Good code
```

## Output Format

```
[check-name] SEVERITY: Description at line N
  File: path/to/file.ext
  Code: the problematic code
  Fix: suggested fix
```

## Severity Rules

- **CRITICAL**: Description
- **WARNING**: Description
- **INFO**: Description
```

### 2. Register in SKILL.md

Add your check to the workflow section:

```markdown
### Step 2: Run Parallel Checks

Execute all checks simultaneously:

```
/checks/your-new-check.md   → Description of what it catches
```
```

### 3. Add Configuration Support

Update the configuration section to include your check:

```json
{
  "checks": {
    "yourCheck": { "enabled": true, "severity": "warning" }
  }
}
```

## Improving Detection Accuracy

### Reducing False Positives

If you find a false positive:
1. Identify the exact code pattern
2. Add an exception rule to the check file
3. Document why it's an exception

Example:
```markdown
**Exceptions**:
- When using `JSON.parse()` inside a try-catch block
- When the input is validated before parsing
```

### Improving True Positives

If you find a missed bug:
1. Identify the pattern that should be caught
2. Add detection rules
3. Add examples

## Code Style

### Markdown Files

- Use consistent heading levels (## for sections, ### for patterns)
- Include both "bad" and "fix" examples
- Keep detection rules concise and actionable
- Use code blocks with language hints

### Detection Rules

- Be specific: "Check for X in Y context" not "Check for issues"
- Be actionable: Each rule should be implementable as a check
- Be testable: Each rule should have clear pass/fail criteria

## Testing Changes

Before submitting:
1. Test with real code examples
2. Verify no false positives on common patterns
3. Check that severity levels are appropriate
4. Ensure examples are clear and correct

## Reporting Issues

When reporting bugs:
1. Include the code that triggers the issue
2. Include the expected vs actual output
3. Include your `.bug-catcher.json` configuration
4. Include Claude Code version

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
