# Quick Reference: Bash Fallback Installation Fixes

**For quick lookup during execution - see full plans for detailed context.**

---

## SESSION 1: Critical Fixes

### Change #1: install.sh line 203
```bash
# BEFORE:
local source_cmd="$SOURCE_DIR/command/gsd"

# AFTER:
local source_cmd="$SOURCE_DIR/commands/gsd"
```

### Change #2: install.sh line 256-259
```bash
# BEFORE:
# Copy command/gsd with replacements
local dest_cmd="$dest_dir/command/gsd"
copy_with_replacements "$source_cmd" "$dest_cmd" "$path_prefix"
echo "✓ Installed command/gsd"

# AFTER:
# Copy commands/gsd with replacements (source dir is plural, dest is singular)
local dest_cmd="$dest_dir/command/gsd"
copy_with_replacements "$source_cmd" "$dest_cmd" "$path_prefix"
echo "✓ Installed command/gsd"
```

### Change #3: install.js line 251
```javascript
// BEFORE:
const gsdSrc = path.join(src, "command", "gsd");

// AFTER:
const gsdSrc = path.join(src, "commands", "gsd");
```

### Change #4: install.js line 250 (comment update)
```javascript
// BEFORE:
// Copy commands/gsd with path replacement

// AFTER:
// Copy commands/gsd (source dir is plural) with path replacement
```

### Change #5: install.js - Add validation after line 167
```javascript
// Add after: const opencodeDir = isGlobal ? defaultGlobalDir : path.join(process.cwd(), ".opencode");

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

---

## SESSION 1: Quick Verification

```bash
# Test 1: Help works
bash gsd-opencode/bin/install.sh --help

# Test 2: Install locally
cd /tmp && mkdir test-install && cd test-install
bash /path/to/install.sh --local
ls .opencode/command/gsd/  # Should list files

# Test 3: Check version created
cat .opencode/get-shit-done/VERSION  # Should show v1.10.0 or similar
```

---

## SESSION 2: Color Codes (Add near top of install.sh after set -e)

```bash
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color
```

---

## SESSION 2: Enhanced Tilde Expansion (Replace lines 34-41)

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

---

## SESSION 2: Enhanced File Copy (Replace lines 148-159)

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

---

## SESSION 2: Directory Validation (Add at start of copy_with_replacements after line 133)

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

## Key Files to Edit

- `gsd-opencode/bin/install.sh` - Main bash installer
- `gsd-opencode/bin/install.js` - Node.js installer

## Directory References

- Source: `gsd-opencode/commands/gsd` (note: plural)
- Dest: `.opencode/command/gsd` (note: singular)

## Color Output Examples

```bash
echo -e "${RED}✗ Error message${NC}"
echo -e "${GREEN}✓ Success message${NC}"
echo -e "${YELLOW}⚠ Warning message${NC}"
echo -e "${BLUE}ℹ Info message${NC}"
```

---

**See full SESSION plans for context and complete implementation details.**
