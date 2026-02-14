# DETAILED BEHAVIOR COMPARISON: install.sh vs install.js

## CRITICAL ISSUE #1: SOURCE DIRECTORY PATH
**install.sh (line 203):**
```bash
local source_cmd="$SOURCE_DIR/command/gsd"
```

**install.js (line 251):**
```javascript
const gsdSrc = path.join(src, "command", "gsd");
```

**ACTUAL DIRECTORY:**
```
gsd-opencode/commands/gsd  ← Note: "commands" (plural), not "command"
```

**STATUS:** ⚠️ BOTH SCRIPTS ARE BROKEN - They will fail with "Source directory not found" error

---

## CRITICAL ISSUE #2: PATH PREFIX LOGIC (OPENCODE_CONFIG_DIR handling)

**install.sh (lines 225-236):**
```bash
if [[ $is_global -eq 1 ]]; then
  if [[ -n "$CONFIG_DIR" ]]; then
    dest_dir="$(expand_tilde "$CONFIG_DIR")"
    path_prefix="${dest_dir}/"
  elif [[ -n "$OPENCODE_CONFIG_DIR" ]]; then
    dest_dir="$(expand_tilde "$OPENCODE_CONFIG_DIR")"
    path_prefix="${dest_dir}/"
  else
    dest_dir="${HOME}/.config/opencode"
    path_prefix="~/.config/opencode/"
  fi
```

**install.js (lines 161-180):**
```javascript
const configDir = expandTilde(explicitConfigDir) || expandTilde(process.env.OPENCODE_CONFIG_DIR);
const defaultGlobalDir = configDir || path.join(os.homedir(), ".config", "opencode");
const opencodeDir = isGlobal ? defaultGlobalDir : path.join(process.cwd(), ".opencode");

const pathPrefix = isGlobal
  ? configDir
    ? `${opencodeDir}/`
    : "~/.config/opencode/"
  : "./.opencode/";
```

**DIFFERENCE:** 
- In install.sh, when `--config-dir` is used, `path_prefix` is set to the expanded actual path + "/"
- In install.js, `pathPrefix` uses `opencodeDir` (which may be expanded), but checks `configDir` (boolean)
  - If configDir exists: uses `${opencodeDir}/` (correct)
  - If not: uses `"~/.config/opencode/"` literal (will be wrong if OPENCODE_CONFIG_DIR is set)

**STATUS:** ⚠️ install.js has a subtle bug when OPENCODE_CONFIG_DIR is set without --config-dir

---

## ISSUE #3: Tilde Expansion Compatibility

**install.sh:**
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
- Handles all tilde patterns (~/foo, ~user/foo, etc.)

**install.js:**
```javascript
function expandTilde(filePath) {
  if (filePath && filePath.startsWith("~/")) {
    return path.join(os.homedir(), filePath.slice(2));
  }
  return filePath;
}
```
- Only handles `~/` pattern
- Doesn't handle `~user/foo` patterns

**STATUS:** ⚠️ Minor difference but install.js is less robust

---

## ISSUE #4: VERSION File Content

Both create VERSION file but let me verify the format:

**install.sh (line 274):**
```bash
echo "v$version" > "$dest_skill/VERSION"
```

**install.js (line 272):**
```javascript
fs.writeFileSync(path.join(skillDest, "VERSION"), `v${pkg.version}`);
```

Both write `v<version>` format. ✓ OK

---

## ISSUE #5: File Copying with Replacements

**install.sh (lines 148-154):**
```bash
if [[ "$src_file" == *.md ]]; then
  sed -e "s|@gsd-opencode/|@${path_prefix}|g" \
      -e "s|gsd-opencode/|${path_prefix}|g" \
      -e "s|~\/\.claude\/|${path_prefix}|g" \
      -e "s|\.\/\.claude\/|\./.opencode/|g" \
      "$src_file" > "$dest_file"
```

**install.js (lines 136-146):**
```javascript
content = content.replace(/@gsd-opencode\//g, `@${pathPrefix}`);
content = content.replace(/\bgsd-opencode\//g, pathPrefix);
content = content.replace(/~\/\.claude\//g, pathPrefix);
content = content.replace(/\.\/\.claude\//g, "./.opencode/");
```

**DIFFERENCE:**
- install.sh: `\bgsd-opencode/` uses word boundary (more precise)
- install.js: `/\bgsd-opencode\//g` uses word boundary (same)

Both are essentially equivalent. ✓ OK

---

## ISSUE #6: Error Handling & Validation

**install.sh:**
- Validates source directories exist (lines 208-219)
- Will fail early if source dirs missing ✓

**install.js:**
- No validation of source directories
- Will fail later during copy attempt ✗

**STATUS:** ⚠️ install.sh is more defensive

---

## ISSUE #7: Argument Parsing Edge Cases

**install.sh (lines 54-102):**
- Manual loop-based parsing
- Validates mutual exclusivity of --global and --local
- Validates --config-dir not used with --local
- Error messages go to stderr ✓

**install.js (lines 311-323):**
- Uses `args.includes()` and `findIndex()`
- Same validations ✓
- Error messages go to stderr via `console.error()` ✓

Both are equivalent. ✓ OK

---

## SUMMARY OF ISSUES

| Issue | install.sh | install.js | Severity |
|-------|-----------|-----------|----------|
| Source dir path (command vs commands) | ❌ BROKEN | ❌ BROKEN | 🔴 CRITICAL |
| Path prefix logic with OPENCODE_CONFIG_DIR | ✓ Correct | ⚠️ Buggy | 🟠 MEDIUM |
| Tilde expansion robustness | ✓ Good | ⚠️ Limited | 🟡 LOW |
| Source dir validation | ✓ Yes | ❌ No | 🟡 LOW |

