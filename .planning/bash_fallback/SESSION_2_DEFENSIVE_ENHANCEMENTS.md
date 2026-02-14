# SESSION 2: Enhance install.sh Defensive Measures

**Objective:** Improve install.sh robustness and error handling to make it production-ready pure-bash fallback

**Priority:** 🟡 MEDIUM - Optional but recommended for production use

**Estimated Duration:** 45-60 minutes

**Prerequisite:** Must complete SESSION 1 first

---

## Overview

After fixing critical bugs in SESSION 1, this session focuses on making `install.sh` more robust by:
1. Improving tilde expansion to handle all edge cases
2. Adding better error handling and validation
3. Adding sanity checks for file operations
4. Improving error messages for better debugging

Goal: Make `install.sh` the most reliable pure-bash fallback with no Node.js dependencies.

---

## Issues to Address

### Issue #1: Limited Tilde Expansion
**File:** `gsd-opencode/bin/install.sh`
**Lines:** 34-41
**Problem:** Current implementation only handles `~/` patterns, not `~user/foo` patterns
**Impact:** Won't work correctly with paths like `~alice/.opencode`

### Issue #2: No Validation on File Copy Operations
**File:** `gsd-opencode/bin/install.sh`
**Lines:** 148-159 (copy_with_replacements function)
**Problem:** If sed fails or file copy fails, script continues without error
**Impact:** Silent failures could leave incomplete installations

### Issue #3: Missing Sanity Checks for Markdown Replacements
**File:** `gsd-opencode/bin/install.sh`
**Lines:** 148-159
**Problem:** No validation that replacements actually happened correctly
**Impact:** Could miss incorrect path replacements

### Issue #4: Unclear Error Messages
**File:** `gsd-opencode/bin/install.sh`
**Lines:** Multiple
**Problem:** Some errors don't indicate what went wrong or why
**Impact:** Harder to debug installation failures

### Issue #5: No Handling of Special Characters in Paths
**File:** `gsd-opencode/bin/install.sh`
**Lines:** 148-159
**Problem:** If path_prefix contains special sed characters (|, &, \), replacements fail
**Impact:** Installation fails silently with spaces or special chars in paths

---

## Execution Plan

### TASK 1: Improve Tilde Expansion Function

**File:** `gsd-opencode/bin/install.sh`
**Location:** Lines 34-41 (expand_tilde function)

**Current Implementation:**
```bash
expand_tilde() {
  local path="$1"
  if [[ "$path" == ~* ]]; then
    echo "${path/#~/$HOME}"
  else
    echo "$path"
  fi
}
```

**Enhanced Implementation:**
```bash
# Function to expand tilde to home directory
expand_tilde() {
  local path="$1"
  
  # Handle plain tilde or ~/ pattern
  if [[ "$path" == "~" || "$path" == ~/* ]]; then
    echo "${path/#~/$HOME}"
  # Handle ~user/ pattern
  elif [[ "$path" == ~* ]]; then
    # Extract username and remaining path
    local user="${path#~}"
    user="${user%%/*}"
    local remainder="${path#~"$user"}"
    
    # Get home directory for user
    local userhome
    userhome=$(eval "echo ~$user" 2>/dev/null) || {
      echo "Error: Cannot expand ~$user" >&2
      return 1
    }
    echo "$userhome$remainder"
  else
    echo "$path"
  fi
}
```

**Verification:**
```bash
# Test cases to verify after implementation:
expand_tilde "~/test"           # Should expand to /home/user/test
expand_tilde "/absolute/path"   # Should return as-is
expand_tilde "relative/path"    # Should return as-is
```

---

### TASK 2: Add Error Handling to File Copy Operations

**File:** `gsd-opencode/bin/install.sh`
**Location:** Lines 148-159 (copy_with_replacements function)

**Current Implementation:**
```bash
if [[ "$src_file" == *.md ]]; then
  sed -e "s|@gsd-opencode/|@${path_prefix}|g" \
      -e "s|gsd-opencode/|${path_prefix}|g" \
      -e "s|~\/\.claude\/|${path_prefix}|g" \
      -e "s|\.\/\.claude\/|\./.opencode/|g" \
      "$src_file" > "$dest_file"
else
  cp "$src_file" "$dest_file"
fi
```

**Enhanced Implementation with Error Checking:**
```bash
if [[ "$src_file" == *.md ]]; then
  # Escape special characters in path_prefix for sed
  local escaped_prefix
  escaped_prefix=$(printf '%s\n' "$path_prefix" | sed -e 's/[\/&]/\\&/g')
  
  # Apply sed with error checking
  if ! sed -e "s|@gsd-opencode/|@${escaped_prefix}|g" \
           -e "s|gsd-opencode/|${escaped_prefix}|g" \
           -e "s|~\/\.claude\/|${escaped_prefix}|g" \
           -e "s|\.\/\.claude\/|\./.opencode/|g" \
           "$src_file" > "$dest_file"; then
    echo "Error: Failed to process markdown file: $src_file" >&2
    return 1
  fi
  
  # Verify replacements were applied
  if ! grep -q "." "$dest_file"; then
    echo "Error: Markdown file is empty after replacement: $dest_file" >&2
    return 1
  fi
else
  # Copy non-markdown files with error checking
  if ! cp "$src_file" "$dest_file"; then
    echo "Error: Failed to copy file: $src_file" >&2
    return 1
  fi
fi
```

**Note:** Add `set -e` check or explicit `|| return 1` after copy operations

---

### TASK 3: Add Validation for Directory Creation

**File:** `gsd-opencode/bin/install.sh`
**Location:** Lines 136-146 (beginning of copy_with_replacements)

**Add validation:**
```bash
# Validate source directory is readable
if [[ ! -d "$src_dir" ]]; then
  echo "Error: Source directory not found or not a directory: $src_dir" >&2
  return 1
fi

if [[ ! -r "$src_dir" ]]; then
  echo "Error: Source directory is not readable: $src_dir" >&2
  return 1
fi

# Create destination directory with error checking
if ! mkdir -p "$dest_dir"; then
  echo "Error: Failed to create destination directory: $dest_dir" >&2
  return 1
fi
```

---

### TASK 4: Improve Error Messages in Main Install Function

**File:** `gsd-opencode/bin/install.sh`
**Location:** Lines 200-282 (install function)

**Changes:**

1. **Add color codes for better visibility:**
   ```bash
   # Add near top of script (after set -e)
   RED='\033[0;31m'
   GREEN='\033[0;32m'
   YELLOW='\033[1;33m'
   BLUE='\033[0;34m'
   NC='\033[0m' # No Color
   ```

2. **Update error messages to use colors and be more descriptive:**
   ```diff
   - echo "Error: Source directory not found: $source_cmd" >&2
   + echo -e "${RED}✗ Error: Source directory not found${NC}" >&2
   + echo -e "  Expected: ${BLUE}$source_cmd${NC}" >&2
   + echo "  This is required for installation to proceed." >&2
   ```

3. **Add informative success messages:**
   ```bash
   echo -e "${GREEN}✓ Installed command/gsd${NC}"
   # Instead of just:
   echo "✓ Installed command/gsd"
   ```

4. **Add more context for common errors:**
   ```bash
   # Add after dest_dir validation
   if [[ ! -w "$(dirname "$dest_dir")" ]]; then
     echo -e "${RED}✗ Error: No write permission to parent directory${NC}" >&2
     echo "  Parent: $(dirname "$dest_dir")" >&2
     echo "  Please check permissions or use a different location." >&2
     exit 1
   fi
   ```

---

### TASK 5: Add Defensive Checks Throughout Installation

**File:** `gsd-opencode/bin/install.sh`
**Location:** Lines 250-270 (main copy operations in install function)

**Wrap each copy with immediate feedback:**
```bash
echo "Installing command/gsd..."
if ! copy_with_replacements "$source_cmd" "$dest_cmd" "$path_prefix"; then
  echo -e "${RED}✗ Failed to install command/gsd${NC}" >&2
  exit 1
fi
echo -e "${GREEN}✓ Installed command/gsd${NC}"

echo "Installing agents..."
if ! copy_with_replacements "$source_agents" "$dest_agents" "$path_prefix"; then
  echo -e "${RED}✗ Failed to install agents${NC}" >&2
  exit 1
fi
echo -e "${GREEN}✓ Installed agents${NC}"

# ... etc for other components
```

---

### TASK 6: Improve Unresolved Token Scanning

**File:** `gsd-opencode/bin/install.sh`
**Location:** Lines 162-198 (scan_unresolved_tokens function)

**Enhancements:**

1. **Add better context display:**
   ```diff
   - echo "- $display_path:$line_num"
   - echo "  ${snippet:0:100}"
   + echo -e "  ${YELLOW}$display_path:$line_num${NC}"
   + echo "    > ${snippet:0:120}"
   ```

2. **Add summary statistics:**
   ```bash
   # At end of scan_unresolved_tokens:
   if [[ $count -gt 0 ]]; then
     echo ""
     echo -e "${YELLOW}Summary: Found $count unresolved token(s)${NC}"
     echo "These may cause issues when using commands in other directories."
     echo "Consider running installation from the repo root for best results."
   fi
   ```

---

### TASK 7: Add Version Validation

**File:** `gsd-opencode/bin/install.sh`
**Location:** Lines 44-51 (get_version function)

**Enhance with validation:**
```bash
# Function to extract version from package.json
get_version() {
  local version
  version=$(grep '"version"' "$SOURCE_DIR/package.json" 2>/dev/null | \
    sed 's/.*"version": "\([^"]*\)".*/\1/' | head -1)
  
  # Validate version format (basic semver check)
  if [[ -z "$version" ]]; then
    version="unknown"
    echo -e "${YELLOW}Warning: Could not determine version from package.json${NC}" >&2
  elif ! [[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+ ]]; then
    echo -e "${YELLOW}Warning: Version format unusual: $version${NC}" >&2
  fi
  
  echo "$version"
}
```

---

### TASK 8: Add Installation Summary Report

**File:** `gsd-opencode/bin/install.sh`
**Location:** After line 280 (after successful installation)

**Add summary:**
```bash
# Generate installation summary
cat << EOF

${GREEN}═══════════════════════════════════════${NC}
${GREEN}Installation Complete!${NC}
${GREEN}═══════════════════════════════════════${NC}

Installation Details:
  Location:    $dest_dir
  Version:     v$version
  Type:        $([ $is_global -eq 1 ] && echo "Global" || echo "Local")
  
Components Installed:
  ✓ command/gsd        (OpenCode commands)
  ✓ agents             (GSD agents)
  ✓ get-shit-done      (GSD skill)
  ✓ VERSION            ($version)

Next Steps:
  1. Run: /gsd-help
  2. Configure your profile
  3. Start using GSD commands

Environment:
  OPENCODE_CONFIG_DIR: ${OPENCODE_CONFIG_DIR:-not set}
  Shell:               $SHELL

${GREEN}═══════════════════════════════════════${NC}
EOF
```

---

## Verification Steps

### Test 1: Tilde Expansion
```bash
source gsd-opencode/bin/install.sh

# Test different patterns
expand_tilde "~/test"
expand_tilde "/absolute/path"
expand_tilde "relative/path"
```

### Test 2: Error Handling with Invalid Paths
```bash
cd /tmp/test-error-cases

# Test with read-only parent directory
mkdir -p test_readonly
chmod 000 test_readonly
bash gsd-opencode/bin/install.sh --config-dir test_readonly/nested 2>&1 | grep -i "error\|permission"
chmod 755 test_readonly
rm -rf test_readonly
```

### Test 3: Installation with Colors
```bash
cd /tmp && rm -rf test-gsd-install && mkdir test-gsd-install && cd test-gsd-install
bash /./gsd-opencode/gsd-opencode/bin/install.sh --local
# Verify colored output appears correctly
```

### Test 4: Version Detection
```bash
bash gsd-opencode/bin/install.sh --local 2>&1 | grep -i "version"
```

### Test 5: Special Characters in Path
```bash
# Test with space in path
cd /tmp && mkdir "test with spaces" && cd "test with spaces"
bash /path/to/install.sh --config-dir "./.opencode test"
# Should handle spaces correctly without sed errors
```

---

## Success Criteria

✅ **PASS** if:
- [x] Tilde expansion handles `~/`, `~user/`, and absolute paths
- [x] All file operations include error checking
- [x] Installation fails gracefully with clear error messages on problems
- [x] Colored output appears in terminal (GREEN, YELLOW, RED)
- [x] Installation summary is displayed after success
- [x] Paths with spaces and special characters work correctly
- [x] Version is correctly detected and displayed
- [x] Unresolved token scan shows improved formatting

❌ **FAIL** if:
- Any error messages are unclear or missing context
- Script continues after critical errors
- Colors don't display or cause terminal issues
- Sed operations fail with special characters in paths
- Version detection fails silently

---

## Files Modified in This Session

1. `gsd-opencode/bin/install.sh` - 8 enhancements across multiple functions

## Implementation Notes

- All enhancements are backward compatible
- Script still uses pure bash (no external dependencies beyond standard Unix tools)
- Color codes are ANSI standard and work on most terminals
- Error checking is comprehensive but doesn't add excessive output noise
- All changes follow existing code style and conventions

## Optional Improvements for Future Sessions

- Add progress indicator (█░░░░░░░░░░) during file copying
- Add dry-run mode (`--dry-run` flag) to preview changes
- Add logging mode (`--log-file` flag) to save installation transcript
- Add rollback capability to revert failed installations
- Add integrity checking (checksums) for installed files
