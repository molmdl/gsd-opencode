# Bash Installation Script for gsd-opencode

## Overview

A pure bash drop-in replacement for `npx gsd-opencode` installer.

**Location:** `gsd-opencode/bin/install.sh`

**Requirements:** Only standard Linux utilities (bash, grep, sed, find, cp, mkdir)

---

## Features

✓ Command-line argument parsing (`-g`, `-l`, `-c`, `-h`)  
✓ Interactive user prompts (location selection, overwrite confirmation)  
✓ Global installation (`~/.config/opencode` or custom `$OPENCODE_CONFIG_DIR`)  
✓ Local installation (`./.opencode` in current directory)  
✓ Path replacements in markdown files (sed-based, pure bash)  
✓ Version file creation from `package.json`  
✓ Sanity check for unresolved repo-local tokens  
✓ Simple, minimal output (no colors, no banner)  
✓ Comprehensive error handling  

---

## Usage

```bash
bash ./install.sh [OPTIONS]
```

### Options

```
-g, --global              Install globally (~/.config/opencode)
-l, --local               Install locally (./.opencode)
-c, --config-dir <path>   Specify custom config directory
-h, --help                Show help message
```

### Examples

```bash
# Interactive prompt (will ask where to install)
bash ./install.sh

# Install globally (default location)
bash ./install.sh --global

# Install locally to this project only
bash ./install.sh --local

# Install to custom global location
bash ./install.sh --global --config-dir ~/my-opencode

# Use environment variable for config directory
OPENCODE_CONFIG_DIR=~/.opencode-dev bash ./install.sh --global
```

---

## What Gets Installed

The script copies three main directories:

```
1. command/gsd/     → {dest}/command/gsd/
2. agents/          → {dest}/agents/
3. get-shit-done/   → {dest}/get-shit-done/
```

**Global installation** (default):
```
~/.config/opencode/
├── command/
│   └── gsd/
├── agents/
└── get-shit-done/
```

**Local installation:**
```
./.opencode/
├── command/
│   └── gsd/
├── agents/
└── get-shit-done/
```

---

## Path Replacements

The script automatically replaces paths in all `.md` files during installation. This ensures prompts and references work correctly from the installation location.

**Replacement patterns (applied in order):**

| Source Pattern | Replacement | Purpose |
|---|---|---|
| `@gsd-opencode/` | `@{install_path}/` | Install-relative references in prompts |
| `gsd-opencode/` | `{install_path}/` | Install-relative paths in markdown |
| `~/.claude/` | `{install_path}/` | Legacy Claude paths (backward compatibility) |
| `./.claude/` | `./.opencode/` | Legacy local Claude paths |

**Example path prefix values:**
- Global: `~/.config/opencode/` or `{full_path}/` (if custom directory)
- Local: `./.opencode/`

---

## Key Functions

### Core Functions

| Function | Purpose |
|---|---|
| `parse_arguments()` | Handle CLI flags with validation |
| `expand_tilde()` | Convert `~/` to home directory path |
| `get_version()` | Extract version from `package.json` |
| `copy_with_replacements()` | Recursive copy with sed replacements for `.md` files |
| `scan_unresolved_tokens()` | Sanity check for unresolved repo-local tokens |
| `prompt_for_overwrite()` | Ask user before overwriting existing installation |
| `install()` | Main installation logic |
| `prompt_location()` | Interactive menu for global/local selection |
| `main()` | Entry point and control flow |

---

## Installation Flow

1. Parse command-line arguments
2. Validate argument combinations
3. Show help if `-h` requested, or proceed to install
4. If no flags provided: prompt user for location (global/local)
5. Validate source directories exist
6. Determine destination path (with tilde expansion)
7. Check if destination exists → prompt for overwrite if yes
8. Create destination directories recursively
9. Copy `command/gsd/` with path replacements
10. Copy `agents/` with path replacements
11. Copy `get-shit-done/` with path replacements
12. Create `VERSION` file with version string
13. Run sanity check for unresolved tokens
14. Print success message

---

## Error Handling

The script validates and handles errors at multiple points:

- **Argument validation:** Rejects conflicting flags (`-g` + `-l`, `-c` + `-l`)
- **Source validation:** Checks all required source directories exist
- **Destination validation:** Prompts user if destination already exists
- **Path expansion:** Handles tilde (`~`) and environment variables
- **Sanity check:** Warns if unresolved repo-local tokens remain after installation
- **Clear error messages:** Errors sent to stderr with descriptive text
- **Graceful failures:** Permission errors handled by OS with clear messages

---

## Design Principles

### Pure Bash
- No Node.js, npm, jq, or external tools required
- Uses only standard Linux utilities: bash, grep, sed, find, cp, mkdir
- Version extraction uses `grep` + `sed` (no `jq` needed)

### Simplicity
- No colors or fancy formatting
- No ASCII art or banner
- Clear, straightforward output messages
- Minimal dependencies on external tools

### User-Friendly
- Interactive prompts for unclear situations
- Help text available via `-h` flag
- Confirmation prompts before destructive operations
- Informative status messages during installation

### Compatibility
- Drop-in replacement for `npx gsd-opencode`
- Same command-line interface
- Same behavior and options
- Same file structure after installation

---

## Output Examples

### Help Text
```
Usage: bash ./install.sh [OPTIONS]

Options:
  -g, --global              Install globally (~/.config/opencode or $OPENCODE_CONFIG_DIR)
  -l, --local               Install locally (./.opencode in current directory)
  -c, --config-dir <path>   Specify custom config directory (overrides $OPENCODE_CONFIG_DIR)
  -h, --help                Show this help message

Examples:
  bash ./install.sh --global
  bash ./install.sh --local
  bash ./install.sh --global --config-dir ~/my-opencode
```

### Success Output
```
Installing to /home/user/.config/opencode

✓ Installed command/gsd
✓ Installed agents
✓ Installed get-shit-done
✓ Created VERSION file

Done! Run /gsd-help to get started.
```

### Sanity Check Warning
```
Warning: Unresolved repo-local tokens found (sanity check)
- command/gsd/some-file.md:42
  This is a line with @gsd-opencode/ that wasn't replaced
```

### Interactive Prompt
```
Where would you like to install?

1) Global (~/.config/opencode) - available in all projects
2) Local (./.opencode) - this project only

Choice [1]:
```

---

## Comparison: Bash vs Node.js Installer

| Feature | Node.js | Bash |
|---|---|---|
| Entry point | `npx gsd-opencode` | `bash ./install.sh` |
| CLI options | `-g`, `-l`, `-c`, `-h` | `-g`, `-l`, `-c`, `-h` |
| Interactive prompt | Yes | Yes |
| Overwrite confirmation | Yes | Yes |
| Path replacements | sed-based | sed-based |
| Version file | Yes | Yes |
| Sanity check | Yes | Yes |
| Banner output | Yes (with colors) | No (plain text) |
| Dependencies | Node.js 16.7.0+ | bash, grep, sed, find, cp, mkdir |

---

## Technical Details

### Path Replacement Implementation

The script uses `sed` with process substitution to apply replacements:

```bash
sed -e "s|@gsd-opencode/|@${path_prefix}|g" \
    -e "s|gsd-opencode/|${path_prefix}|g" \
    -e "s|~/.claude/|${path_prefix}|g" \
    -e "s|./.claude/|./.opencode/|g" \
    "$src_file" > "$dest_file"
```

**Order matters:** Replacements are applied sequentially to avoid double-rewrites.

### Directory Traversal

Uses `find` with process substitution for robust file handling:

```bash
find "$src_dir" -type f | while IFS= read -r src_file; do
  # Process each file
done
```

This handles filenames with spaces and special characters correctly.

### Version Extraction

Extracts version from `package.json` using pure bash:

```bash
version=$(grep '"version"' "$SOURCE_DIR/package.json" | sed 's/.*"version": "\([^"]*\)".*/\1/' | head -1)
```

Fallback to "unknown" if version cannot be determined.

---

## Troubleshooting

### "Error: Source directory not found"
The script couldn't find the source directories. Make sure:
- You're running the script from `gsd-opencode/bin/` directory
- All required subdirectories exist: `command/gsd/`, `agents/`, `get-shit-done/`

### "Error: Cannot specify both --global and --local"
You used both `-g` and `-l` flags. Choose one:
```bash
bash ./install.sh --global   # OR
bash ./install.sh --local
```

### "Error: Cannot use --config-dir with --local"
The `-c` flag only works with `-g` for global installation:
```bash
bash ./install.sh --global --config-dir ~/my-path
```

### "Destination already exists"
The script will prompt you. Answer `y` to overwrite or `n` to cancel:
```
Destination already exists: /home/user/.config/opencode
Overwrite? (y/n):
```

### "Warning: Unresolved repo-local tokens found"
Some paths weren't replaced correctly. This is a sanity check warning.
The installation succeeded, but you should investigate the listed files.

---

## Script Statistics

- **Total lines:** 335
- **Functions:** 9
- **Lines of comments:** ~40
- **No external dependencies:** Pure bash + standard Linux tools

