#!/bin/bash

set -e

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
  if [[ "$path" == ~* ]]; then
    echo "${path/#~/$HOME}"
  else
    echo "$path"
  fi
}

# Function to extract version from package.json
get_version() {
  local version
  version=$(grep '"version"' "$SOURCE_DIR/package.json" 2>/dev/null | sed 's/.*"version": "\([^"]*\)".*/\1/' | head -1)
  if [[ -z "$version" ]]; then
    version="unknown"
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

  # Create destination directory
  mkdir -p "$dest_dir"

  # Process all files in source directory
  while IFS= read -r src_file; do
    local rel_path="${src_file#"$src_dir"/}"
    local dest_file="$dest_dir/$rel_path"
    local dest_file_dir="$(dirname "$dest_file")"

    # Create destination directory if it doesn't exist
    mkdir -p "$dest_file_dir"

    # If it's a markdown file, apply replacements
    if [[ "$src_file" == *.md ]]; then
      # Apply sed replacements in order
      sed -e "s|@gsd-opencode/|@${path_prefix}|g" \
          -e "s|gsd-opencode/|${path_prefix}|g" \
          -e "s|~/.claude/|${path_prefix}|g" \
          -e "s|./.claude/|./.opencode/|g" \
          "$src_file" > "$dest_file"
    else
      # For other files, just copy
      cp "$src_file" "$dest_file"
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
        echo "Warning: Unresolved repo-local tokens found (sanity check)"
      fi
      
      # Find the line number and show snippet
      while IFS=: read -r line_num snippet; do
        if [[ $count -ge $max_hits ]]; then
          break
        fi
        if grep -q '@gsd-opencode/\|gsd-opencode/' <<< "$snippet"; then
          local display_path="${file#"$HOME/"}"
          echo "- $display_path:$line_num"
          echo "  ${snippet:0:100}"
          count=$((count+1))
        fi
      done < <(grep -n '@gsd-opencode/\|gsd-opencode/' "$file" 2>/dev/null)
    fi
  done < <(find "$dest_root" -type f -name "*.md")

  if [[ $count -gt 0 ]]; then
    echo ""
  fi
}

# Function to perform the installation
install() {
  local is_global="$1"
  local source_cmd="$SOURCE_DIR/command/gsd"
  local source_agents="$SOURCE_DIR/agents"
  local source_skill="$SOURCE_DIR/get-shit-done"

  # Validate source directories exist
  if [[ ! -d "$source_cmd" ]]; then
    echo "Error: Source directory not found: $source_cmd" >&2
    exit 1
  fi
  if [[ ! -d "$source_agents" ]]; then
    echo "Error: Source directory not found: $source_agents" >&2
    exit 1
  fi
  if [[ ! -d "$source_skill" ]]; then
    echo "Error: Source directory not found: $source_skill" >&2
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

  # Prompt for overwrite if destination exists
  prompt_for_overwrite "$dest_dir"

  # Display installation location
  echo "Installing to $dest_dir"
  echo ""

  # Create main destination directory
  mkdir -p "$dest_dir"

  # Copy command/gsd with replacements
  local dest_cmd="$dest_dir/command/gsd"
  copy_with_replacements "$source_cmd" "$dest_cmd" "$path_prefix"
  echo "✓ Installed command/gsd"

  # Copy agents with replacements
  local dest_agents="$dest_dir/agents"
  copy_with_replacements "$source_agents" "$dest_agents" "$path_prefix"
  echo "✓ Installed agents"

  # Copy get-shit-done skill with replacements
  local dest_skill="$dest_dir/get-shit-done"
  copy_with_replacements "$source_skill" "$dest_skill" "$path_prefix"
  echo "✓ Installed get-shit-done"

  # Create VERSION file
  local version
  version=$(get_version)
  echo "v$version" > "$dest_skill/VERSION"
  echo "✓ Created VERSION file"

  # Scan for unresolved tokens
  scan_unresolved_tokens "$dest_dir"

  echo "Done! Run /gsd-help to get started."
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
