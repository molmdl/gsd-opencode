# SESSION 1: Critical Fixes for Install Scripts

**Objective:** Fix critical bugs that prevent both scripts from working

**Priority:** 🔴 CRITICAL - MUST COMPLETE FIRST

**Estimated Duration:** 30-45 minutes

---

## Overview

Both `install.sh` and `install.js` reference the wrong source directory name. They look for `command/gsd` but the actual directory is `commands/gsd` (plural). This causes both scripts to fail immediately with "Source directory not found" error.

Additionally, `install.js` lacks source directory validation, making error messages unclear.

---

## Issues to Fix

### Issue #1: install.sh - Wrong Source Directory Reference
**Files:** `gsd-opencode/bin/install.sh`
**Lines:** 203, 208, 256, 257, 259
**Problem:** References `$SOURCE_DIR/command/gsd` but actual directory is `$SOURCE_DIR/commands/gsd`

### Issue #2: install.js - Wrong Source Directory Reference  
**Files:** `gsd-opencode/bin/install.js`
**Lines:** 251
**Problem:** References `path.join(src, "command", "gsd")` but actual directory is `commands/gsd`

### Issue #3: install.js - No Source Directory Validation
**Files:** `gsd-opencode/bin/install.js`
**Problem:** Unlike install.sh, doesn't validate source directories exist before copying. Error fails late with unclear message.

---

## Execution Plan

### TASK 1: Fix install.sh Source Directory Reference

**File:** `gsd-opencode/bin/install.sh`

**Changes:**

1. **Line 203** - Change source_cmd variable:
   ```diff
   - local source_cmd="$SOURCE_DIR/command/gsd"
   + local source_cmd="$SOURCE_DIR/commands/gsd"
   ```

2. **Line 208** - Update validation check (automatic - will fix with variable change)

3. **Line 256-259** - Update comments and dest_cmd reference:
   ```diff
   - # Copy command/gsd with replacements
   - local dest_cmd="$dest_dir/command/gsd"
   + # Copy commands/gsd with replacements (source dir is plural, dest is singular)
   + local dest_cmd="$dest_dir/command/gsd"
   ```
   Note: Destination stays `command/` (singular) - this is intentional normalization

---

### TASK 2: Fix install.js Source Directory Reference

**File:** `gsd-opencode/bin/install.js`

**Changes:**

1. **Line 251** - Change gsdSrc path:
   ```diff
   - const gsdSrc = path.join(src, "command", "gsd");
   + const gsdSrc = path.join(src, "commands", "gsd");
   ```

2. **Line 250** - Update comment:
   ```diff
   - // Copy commands/gsd with path replacement
   + // Copy commands/gsd (source dir is plural) with path replacement
   ```

---

### TASK 3: Add Source Directory Validation to install.js

**File:** `gsd-opencode/bin/install.js`

**Location:** After line 167 (inside the `install()` function), before any copying starts

**Add validation block:**
```javascript
  // Validate source directories exist
  const commandsSrc = path.join(src, "commands", "gsd");
  const agentsSrc = path.join(src, "agents");
  const skillSrc = path.join(src, "get-shit-done");

  if (!fs.existsSync(commandsSrc)) {
    console.error(`  ${yellow}Error: Source directory not found: ${commandsSrc}${reset}`);
    process.exit(1);
  }
  if (!fs.existsSync(agentsSrc)) {
    console.error(`  ${yellow}Error: Source directory not found: ${agentsSrc}${reset}`);
    process.exit(1);
  }
  if (!fs.existsSync(skillSrc)) {
    console.error(`  ${yellow}Error: Source directory not found: ${skillSrc}${reset}`);
    process.exit(1);
  }
```

**Note:** Install.js needs to import `fs` at the top if not already done. Check line 1-10.

---

## Verification Steps

After making changes, verify both scripts work:

### Test 1: Dry Run (Verify No Source Dir Errors)
```bash
cd /./gsd-opencode

# Test install.sh finds source directories
bash gsd-opencode/bin/install.sh --help
# Should show help without "Source directory not found" error

# Test install.js finds source directories (if Node available)
node gsd-opencode/bin/install.js --help
# Should show help without errors
```

### Test 2: Interactive Test (Create Test Installation)
```bash
cd /tmp
mkdir -p test-gsd-install
cd test-gsd-install

# Test install.sh with --local flag (should not prompt)
bash /./gsd-opencode/gsd-opencode/bin/install.sh --local

# Verify installation succeeded
ls -la .opencode/command/gsd/
# Should list files without errors

# Cleanup
cd /tmp && rm -rf test-gsd-install
```

### Test 3: Verify Installation Output
```bash
cd /tmp && mkdir test-gsd-install && cd test-gsd-install
bash /./gsd-opencode/gsd-opencode/bin/install.sh --local 2>&1 | head -20
# Should show:
# ✓ Installed command/gsd
# ✓ Installed agents
# ✓ Installed get-shit-done
# ✓ Created VERSION file
# Done! Run /gsd-help to get started.
```

---

## Success Criteria

✅ **PASS** if:
- [x] install.sh --help runs without "Source directory not found" error
- [x] install.js --help runs without "Source directory not found" error
- [x] install.sh --local creates .opencode/command/gsd/ directory structure
- [x] install.js --local creates .opencode/command/gsd/ directory structure (if Node available)
- [x] Both create VERSION file in get-shit-done directory
- [x] Both scan and report unresolved tokens in markdown files

❌ **FAIL** if:
- Any "Source directory not found" error appears
- Installation completes but skips copying any directory
- VERSION file is not created
- Either script exits with non-zero status unexpectedly

---

## Files Modified in This Session

1. `gsd-opencode/bin/install.sh` - 3 changes
2. `gsd-opencode/bin/install.js` - 2 changes + 1 addition

## Notes

- The destination directory stays as `command/` (singular) in both scripts - this is intentional normalization
- Source directory is `commands/` (plural) to match actual project structure
- After fixing, both scripts should behave identically for basic functionality
- Path prefix logic bug in install.js will be addressed in SESSION 2
