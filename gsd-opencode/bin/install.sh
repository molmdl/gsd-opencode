#!/bin/bash

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="$(dirname "$SCRIPT_DIR")"

# Initialize variables
INSTALL_GLOBAL=""
SHOW_HELP=""
CONFIG_DIR=""

# Function to display help
show_help() {
  cat << 'EOF'
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

EOF
}

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

# Function to parse command-line arguments
parse_arguments() {
  local has_global=0
  local has_local=0
  local i=0

  while [[ $i -lt ${#@} ]]; do
    local arg="${@:$((i+1)):1}"
    
    case "$arg" in
      -h|--help)
        SHOW_HELP=1
        ;;
      -g|--global)
        has_global=1
        INSTALL_GLOBAL=1
        ;;
      -l|--local)
        has_local=1
        INSTALL_GLOBAL=0
        ;;
      -c|--config-dir)
        i=$((i+1))
        if [[ $i -ge ${#@} ]]; then
          echo "Error: --config-dir requires a path argument" >&2
          exit 1
        fi
        CONFIG_DIR="${@:$((i+1)):1}"
        ;;
      *)
        echo "Error: Unknown option: $arg" >&2
        echo "Use -h or --help for usage information" >&2
        exit 1
        ;;
    esac
    
    i=$((i+1))
  done

  # Validate argument combinations
  if [[ $has_global -eq 1 && $has_local -eq 1 ]]; then
    echo "Error: Cannot specify both --global and --local" >&2
    exit 1
  fi

  if [[ -n "$CONFIG_DIR" && $has_local -eq 1 ]]; then
    echo "Error: Cannot use --config-dir with --local" >&2
    exit 1
  fi
}

# Function to prompt user for overwrite decision
prompt_for_overwrite() {
  local dest="$1"
  
  if [[ -d "$dest" ]]; then
    local response
    while true; do
      echo "Destination already exists: $dest"
      read -p "Overwrite? (y/n): " response
      case "$response" in
        [yY])
          return 0
          ;;
        [nN])
          echo "Installation cancelled."
          exit 0
          ;;
        *)
          echo "Please answer y or n"
          ;;
      esac
    done
  fi
}

# Function to recursively copy files with path replacements for .md files
copy_with_replacements() {
  local src_dir="$1"
  local dest_dir="$2"
  local path_prefix="$3"

  # Validate source directory is readable (TASK 3)
  if [[ ! -d "$src_dir" ]]; then
    echo -e "${RED}✗ Error: Source directory not found or not a directory${NC}" >&2
    echo "  Expected: ${BLUE}$src_dir${NC}" >&2
    return 1
  fi

  if [[ ! -r "$src_dir" ]]; then
    echo -e "${RED}✗ Error: Source directory is not readable${NC}" >&2
    echo "  Directory: ${BLUE}$src_dir${NC}" >&2
    return 1
  fi

  # Create destination directory with error checking (TASK 3)
  if ! mkdir -p "$dest_dir"; then
    echo -e "${RED}✗ Error: Failed to create destination directory${NC}" >&2
    echo "  Target: ${BLUE}$dest_dir${NC}" >&2
    return 1
  fi

  # Process all files in source directory
  while IFS= read -r src_file; do
    local rel_path="${src_file#"$src_dir"/}"
    local dest_file="$dest_dir/$rel_path"
    local dest_file_dir="$(dirname "$dest_file")"

    # Create destination directory if it doesn't exist
    mkdir -p "$dest_file_dir"

    # If it's a markdown file, apply replacements (TASK 2)
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
        echo -e "${RED}✗ Error: Failed to process markdown file${NC}" >&2
        echo "  File: ${BLUE}$src_file${NC}" >&2
        return 1
      fi
      
      # Verify replacements were applied
      if ! grep -q "." "$dest_file"; then
        echo -e "${RED}✗ Error: Markdown file is empty after replacement${NC}" >&2
        echo "  File: ${BLUE}$dest_file${NC}" >&2
        return 1
      fi
    else
      # Copy non-markdown files with error checking
      if ! cp "$src_file" "$dest_file"; then
        echo -e "${RED}✗ Error: Failed to copy file${NC}" >&2
        echo "  Source: ${BLUE}$src_file${NC}" >&2
        return 1
      fi
    fi
  done < <(find "$src_dir" -type f)
}

# Function to scan for unresolved repo-local tokens
scan_unresolved_tokens() {
  local dest_root="$1"
  local count=0
  local max_hits=10

  while IFS= read -r file; do
    if [[ $count -ge $max_hits ]]; then
      break
    fi

    # Check if file contains unresolved tokens
    if grep -q '@gsd-opencode/\|gsd-opencode/' "$file" 2>/dev/null; then
      if [[ $count -eq 0 ]]; then
        echo ""
        echo -e "${YELLOW}Warning: Unresolved repo-local tokens found (sanity check)${NC}"
      fi
      
      # Find the line number and show snippet
      while IFS=: read -r line_num snippet; do
        if [[ $count -ge $max_hits ]]; then
          break
        fi
        if grep -q '@gsd-opencode/\|gsd-opencode/' <<< "$snippet"; then
          local display_path="${file#"$HOME/"}"
          echo -e "  ${YELLOW}$display_path:$line_num${NC}"
          echo "    > ${snippet:0:120}"
          count=$((count+1))
        fi
      done < <(grep -n '@gsd-opencode/\|gsd-opencode/' "$file" 2>/dev/null)
    fi
  done < <(find "$dest_root" -type f -name "*.md")

  if [[ $count -gt 0 ]]; then
    echo ""
    echo -e "${YELLOW}Summary: Found $count unresolved token(s)${NC}"
    echo "These may cause issues when using commands in other directories."
    echo "Consider running installation from the repo root for best results."
    echo ""
  fi
}

# Function to perform the installation
install() {
  local is_global="$1"
  local source_cmd="$SOURCE_DIR/commands/gsd"
  local source_agents="$SOURCE_DIR/agents"
  local source_skill="$SOURCE_DIR/get-shit-done"

  # Validate source directories exist
  if [[ ! -d "$source_cmd" ]]; then
    echo -e "${RED}✗ Error: Source directory not found${NC}" >&2
    echo -e "  Expected: ${BLUE}$source_cmd${NC}" >&2
    echo "  This is required for installation to proceed." >&2
    exit 1
  fi
  if [[ ! -d "$source_agents" ]]; then
    echo -e "${RED}✗ Error: Source directory not found${NC}" >&2
    echo -e "  Expected: ${BLUE}$source_agents${NC}" >&2
    echo "  This is required for installation to proceed." >&2
    exit 1
  fi
  if [[ ! -d "$source_skill" ]]; then
    echo -e "${RED}✗ Error: Source directory not found${NC}" >&2
    echo -e "  Expected: ${BLUE}$source_skill${NC}" >&2
    echo "  This is required for installation to proceed." >&2
    exit 1
  fi

  # Determine destination directory
  local dest_dir
  local path_prefix
  
  if [[ $is_global -eq 1 ]]; then
    # Global installation
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
  else
    # Local installation
    dest_dir="./.opencode"
    path_prefix="./.opencode/"
  fi

  # Expand tilde in dest_dir if needed
  dest_dir="$(expand_tilde "$dest_dir")"

  # Check write permission to parent directory
  if [[ ! -w "$(dirname "$dest_dir")" ]]; then
    echo -e "${RED}✗ Error: No write permission to parent directory${NC}" >&2
    echo -e "  Parent: ${BLUE}$(dirname "$dest_dir")${NC}" >&2
    echo "  Please check permissions or use a different location." >&2
    exit 1
  fi

  # Prompt for overwrite if destination exists
  prompt_for_overwrite "$dest_dir"

  # Display installation location
  echo -e "Installing to ${BLUE}$dest_dir${NC}"
  echo ""

  # Create main destination directory
  mkdir -p "$dest_dir"

  # Copy commands/gsd with replacements (source dir is plural, dest is singular)
  local dest_cmd="$dest_dir/command/gsd"
  echo "Installing command/gsd..."
  if ! copy_with_replacements "$source_cmd" "$dest_cmd" "$path_prefix"; then
    echo -e "${RED}✗ Failed to install command/gsd${NC}" >&2
    exit 1
  fi
  echo -e "${GREEN}✓ Installed command/gsd${NC}"

  # Copy agents with replacements
  local dest_agents="$dest_dir/agents"
  echo "Installing agents..."
  if ! copy_with_replacements "$source_agents" "$dest_agents" "$path_prefix"; then
    echo -e "${RED}✗ Failed to install agents${NC}" >&2
    exit 1
  fi
  echo -e "${GREEN}✓ Installed agents${NC}"

  # Copy get-shit-done skill with replacements
  local dest_skill="$dest_dir/get-shit-done"
  echo "Installing get-shit-done..."
  if ! copy_with_replacements "$source_skill" "$dest_skill" "$path_prefix"; then
    echo -e "${RED}✗ Failed to install get-shit-done${NC}" >&2
    exit 1
  fi
  echo -e "${GREEN}✓ Installed get-shit-done${NC}"

  # Create VERSION file
  local version
  version=$(get_version)
  echo "v$version" > "$dest_skill/VERSION"
  echo -e "${GREEN}✓ Created VERSION file${NC}"

  # Scan for unresolved tokens
  scan_unresolved_tokens "$dest_dir"

  # Generate installation summary (TASK 8)
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
}

# Function to prompt user for installation location
prompt_location() {
  local response
  
  cat << 'EOF'
Where would you like to install?

1) Global (~/.config/opencode) - available in all projects
2) Local (./.opencode) - this project only

EOF

  read -p "Choice [1]: " response
  response="${response:-1}"

  case "$response" in
    1)
      install 1
      ;;
    2)
      install 0
      ;;
    *)
      echo "Invalid choice. Please enter 1 or 2."
      prompt_location
      ;;
  esac
}

# Main entry point
main() {
  parse_arguments "$@"

  if [[ -n "$SHOW_HELP" ]]; then
    show_help
    exit 0
  fi

  if [[ -n "$INSTALL_GLOBAL" ]]; then
    # Explicit --global flag
    install 1
  elif [[ "$INSTALL_GLOBAL" == "0" ]]; then
    # Explicit --local flag
    install 0
  else
    # No flag provided, prompt user
    prompt_location
  fi
}

# Run main function
main "$@"
