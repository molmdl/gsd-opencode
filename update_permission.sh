#!/bin/bash
# =====================================================
# GSD-OpenCode Pure Bash Permission Updater (Fixed v5 - Correct Placement)
# =====================================================
# Final fixes:
#   - Never creates 3 --- 
#   - Always places the permission: block **inside** the frontmatter, 
#     right before the **closing** ---
#   - If permission: already exists, only updates/replaces the bash: subsection inside it
#   - Keeps all other permissions (edit, read, webfetch, etc.) untouched
#   - Removes old bash: true / allowed / allow and tools: bash: true
#   - Safe to re-run with updated opencode.json

set -euo pipefail

echo "=== GSD-OpenCode Permission Updater (Fixed v5 - Correct Placement) ==="

if [ ! -f "./opencode.json" ]; then
  echo "❌ ERROR: ./opencode.json not found!"
  echo "   Place your updated opencode.json in the current directory."
  exit 1
fi

# OS-specific sed
if [[ "$(uname)" == "Darwin" ]]; then
  SED_I="sed -i ''"
else
  SED_I="sed -i"
fi

echo "📦 Extracting ONLY the bash section from opencode.json..."

BASH_JSON=$(awk '
  BEGIN { in_bash=0; brace=0 }
  /^\s*"bash"\s*:/ { in_bash=1; brace=1; print; next }
  in_bash {
    print
    if (/\{/) brace++
    if (/\}/) brace--
    if (brace == 0) { in_bash=0; exit }
  }
' ./opencode.json)

if [[ -z "$BASH_JSON" ]]; then
  echo "❌ ERROR: Could not extract \"bash\" section from opencode.json"
  exit 1
fi

# Convert to clean YAML (indented under permission:)
TEMP_BASH=$(mktemp)
{
  echo "  bash:"
  echo "$BASH_JSON" | sed '
    s/^[ \t]*"bash":\s*{\s*//;
    s/\s*}[ \t,]*$//;
    s/^[ \t]*"//;
    s/":[ \t]*/: /;
    s/",[ \t]*$//;
    s/"[ \t]*$//;
    s/^/    /;
  ' | sed '/^ *$/d'
} > "$TEMP_BASH"

echo "✅ New bash block ready:"
cat "$TEMP_BASH"
echo ""

# Pattern for old bash lines
GREP_PATTERN='(bash[[:space:]]*:[[:space:]]*(true|allowed|allow))|(tools:[[:space:]]*\n?[[:space:]]*bash[[:space:]]*:[[:space:]]*true)'

echo "🔍 Scanning for files needing update..."

mapfile -t TARGET_FILES < <(grep -l -r -E --ignore-case \
  --include='*.md' \
  --include='*.yaml' \
  --include='*.yml' \
  "$GREP_PATTERN" . 2>/dev/null | grep -v './opencode.json' || true)

if [ ${#TARGET_FILES[@]} -eq 0 ]; then
  echo "✅ No files with old bash permission found."
  rm -f "$TEMP_BASH"
  exit 0
fi

echo "📝 Found ${#TARGET_FILES[@]} file(s)."

EDITED_FILES=()

for file in "${TARGET_FILES[@]}"; do
  echo "   ↳ Updating: $file"

  # Create the cp- prefixed copy
  dir=$(dirname "$file")
  filename=$(basename "$file")
  COPY_FILE="${dir}/cp-${filename}"
  cp "$file" "$COPY_FILE"

  # 1. Remove old bash declarations from the copy
  $SED_I '/^[ \t]*bash[ \t]*:[ \t]*\(true\|allowed\|allow\)[ \t]*$/d' "$COPY_FILE"
  $SED_I '/^[ \t]*tools:[ \t]*$/{
    N
    /bash[ \t]*:[ \t]*true/d
  }' "$COPY_FILE"

  # 2. Remove any existing bash: subsection inside permission: from the copy
  awk '
    BEGIN { in_perm=0; in_bash=0 }
    /^[ \t]*permission:[ \t]*$/ { in_perm=1; print; next }
    in_perm && /^[ \t]*bash:[ \t]*$/ { in_bash=1; next }
    in_bash && /^[ \t]*[a-z0-9_]/ && !/^[ \t]*bash:/ { in_bash=0 }
    in_bash && /^[ \t]*}/ { in_bash=0; next }
    in_bash { next }
    { print }
  ' "$COPY_FILE" > "${COPY_FILE}.tmp" && mv "${COPY_FILE}.tmp" "$COPY_FILE"

  # 3. Insert the bash subsection in the correct place (before closing ---) in the copy
  awk '
    BEGIN { inserted=0; in_frontmatter=0; has_permission=0 }
    # First --- starts the frontmatter
    /^---[ \t]*$/ && in_frontmatter == 0 {
      in_frontmatter = 1
      print
      next
    }
    # Track if permission: or permissions: already exists
    /^[ \t]*permissions?:[ \t]*$/ {
      has_permission = 1
    }
    # If permission:/permissions: already exists, add bash right after it
    /^[ \t]*permissions?:[ \t]*$/ && inserted == 0 {
      print
      system("cat '"$TEMP_BASH"'")
      inserted = 1
      next
    }
    # Closing --- (second ---) - insert permission block here if not already inserted
    # This handles: no permission block, OR has tools: block
    /^---[ \t]*$/ && in_frontmatter == 1 && inserted == 0 {
      print "permission:"
      system("cat '"$TEMP_BASH"'")
      print
      inserted = 1
      next
    }
    { print }
  ' "$COPY_FILE" > "${COPY_FILE}.tmp" && mv "${COPY_FILE}.tmp" "$COPY_FILE"

  EDITED_FILES+=("$COPY_FILE")
  echo "      ✓ Created: $COPY_FILE"
done

rm -f "$TEMP_BASH"

echo ""
echo "✅ Update completed successfully!"
echo "📋 cp- prefixed copies created with updated permissions:"

for f in "${EDITED_FILES[@]}"; do
  echo "   • $f"
done

echo ""
echo "💡 Next steps:"
echo "   diff ${TARGET_FILES[0]} ${EDITED_FILES[0]}  # compare original vs edited copy"
echo "   git add . && git commit -m 'chore: update bash permissions inside permission: block'"
echo ""
echo "The permission: block is now correctly placed **inside** the frontmatter, right before the closing ---."
echo "No extra --- lines are added, and other permissions are preserved."
echo "Original files remain unchanged."
