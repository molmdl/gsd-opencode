#!/bin/bash

echo "=== COMPARISON: install.sh vs install.js ==="
echo ""

echo "1. SOURCE DIRECTORY REFERENCES:"
echo "install.sh expects: $SOURCE_DIR/command/gsd (WRONG - should be commands/)"
echo "install.js expects: src/command/gsd (WRONG - should be commands/)"
echo "Actual directory:   gsd-opencode/commands/gsd ✓"
echo ""

echo "2. DESTINATION DIRECTORY FOR COMMANDS:"
echo "install.sh: dest_dir/command/gsd"
echo "install.js: opencodeDir/command (comment says 'singular command not commands')"
echo "→ Both create 'command/' not 'commands/' in destination"
echo ""

echo "3. PATH PREFIX HANDLING:"
echo "install.sh: Uses variables INSTALL_GLOBAL and CONFIG_DIR with clear logic"
echo "install.js: Uses ternary chains with configDir check"
echo "Potential difference in edge cases with OPENCODE_CONFIG_DIR"
echo ""

echo "4. TILDE EXPANSION:"
grep -A 3 "expand_tilde" /./gsd-opencode/gsd-opencode/bin/install.sh | head -5
echo "---"
grep -A 3 "expandTilde" /./gsd-opencode/gsd-opencode/bin/install.js | head -5
echo ""

echo "5. UNRESOLVED TOKENS SCAN:"
echo "install.sh: Searches .md files for @gsd-opencode/ and gsd-opencode/ patterns"
echo "install.js: Same patterns, but with more detailed hit tracking"
echo ""

echo "6. VERSION FILE CREATION:"
grep "VERSION" /./gsd-opencode/gsd-opencode/bin/install.sh
echo "---"
grep "VERSION" /./gsd-opencode/gsd-opencode/bin/install.js
echo ""

