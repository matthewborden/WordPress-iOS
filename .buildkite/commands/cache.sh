#!/bin/bash

set -e

# Ensure required tools are available
command -v tar >/dev/null 2>&1 || { echo "tar is required but it's not installed. Aborting."; exit 1; }

BUILDKITE_CACHE_MOUNT_PATH="${BUILDKITE_CACHE_MOUNT_PATH:-.cache/buildkite}"

# Read cache paths from BUILDKITE_AGENT_CACHE_PATHS
IFS=',' read -r -a CACHE_PATHS <<< "$BUILDKITE_AGENT_CACHE_PATHS"

function expand_templates() {
  CACHE_KEY="$1"
  HASHER_BIN="sha1sum"
  if [[ "$OSTYPE" == "darwin"* ]]; then
    HASHER_BIN="shasum"
  fi

  while [[ "$CACHE_KEY" =~ (.*)\{\{\ *(.*)\ *\}\}(.*) ]]; do
    TEMPLATE_VALUE="${BASH_REMATCH[2]}"
    EXPANDED_VALUE=""
    case $TEMPLATE_VALUE in
    "checksum "*)
      TARGET="$(echo -e "${TEMPLATE_VALUE/"checksum"/""}" | tr -d \' | tr -d \" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
      EXPANDED_VALUE=$(find "$TARGET" -type f -exec $HASHER_BIN {} \; | sort -k 2 | $HASHER_BIN | awk '{print $1}')
      ;;
    "date "*)
      DATE_FMT="$(echo -e "${TEMPLATE_VALUE/"date"/""}" | tr -d \' | tr -d \" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
      EXPANDED_VALUE=$(date "${DATE_FMT}")
      ;;
    "env."*)
      ENV_VAR_NAME="$(echo -e "${TEMPLATE_VALUE/"env."/""}" | tr -d \' | tr -d \" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
      EXPANDED_VALUE="${!ENV_VAR_NAME}"
      ;;
    "git.branch"*)
      BRANCH="${BUILDKITE_BRANCH}"
      EXPANDED_VALUE="${BRANCH//\//_}"
      ;;
    "git.commit"*)
      EXPANDED_VALUE="${BUILDKITE_COMMIT}"
      ;;
    "id"*)
      EXPANDED_VALUE="${BK_CACHE_ID}"
      ;;
    "runner.os"*)
      case $OSTYPE in
      "linux-gnu"* | "freebsd"*)
        OS="Linux"
        ;;
      "darwin"*)
        OS="macOS"
        ;;
      "cygwin" | "msys" | "win32" | "mingw"*)
        OS="Windows"
        ;;
      *)
        OS="Generic"
        ;;
      esac
      EXPANDED_VALUE="${OS}"
      ;;
    *)
      echo >&2 "Invalid template expression: $TEMPLATE_VALUE"
      return 1
      ;;
    esac
    CACHE_KEY="${BASH_REMATCH[1]}${EXPANDED_VALUE}${BASH_REMATCH[3]}"
  done

  echo "$CACHE_KEY"
}

# Function to perform checksum interpolation for the key
generate_cache_key() {
  local template="$1"

  # Extract the file to checksum from the template
  local file_to_checksum
  file_to_checksum=$(extract_checksum_file "$template")

  # Compute the checksum for the extracted file
  local file_checksum
  file_checksum=$(checksum "$file_to_checksum")

  # Replace the checksum template with the actual checksum
  echo "${template//\{\{ checksum \"$file_to_checksum\" \}\}/$file_checksum}"
}

# Load paths and key from environment variable
CACHE_KEY=$(expand_templates "$2")
echo "CACHE_KEY: $CACHE_KEY"

CACHE_DIR="${BUILDKITE_CACHE_MOUNT_PATH}/${CACHE_KEY}"

echo "CACHE_DIR: $CACHE_DIR"

CACHE_ARCHIVE="${CACHE_DIR}/cache.tar"

echo "CACHE_ARCHIVE: $CACHE_ARCHIVE"


# Function to serialize a path into a filename-safe format
serialize_path() {
  local path="$1"
  # Replace '/' with '_', '~' with 'home', and trim leading/trailing spaces
  echo "${path/#\~/$HOME}" | sed 's/\//_/g' | tr -d ' '
}

# Function to deserialize a filename-safe format back to a path
deserialize_path() {
  local serialized="$1"
  # Replace '_' with '/', 'home' with '~', and trim leading/trailing spaces
  echo "${serialized}" | sed 's/_/\//g' | sed 's/^home/$HOME/' | tr -d ' '
}

# Cache function to tar the directories (without compression)
cache() {
  echo "Caching files..."
  mkdir -p "${CACHE_DIR}"

  for path in "${CACHE_PATHS[@]}"; do
    path=$(eval echo "$path") # Expand environment variables like $GOPATH

    echo "Checking path: ${path}"

    if [ -d "${path}" ]; then
      serialized_path=$(serialize_path "${path}")
      echo "Archiving ${path} as ${serialized_path}..."
      tar -cf "${CACHE_DIR}/${serialized_path}.tar" -C "$(dirname ${path})" "$(basename ${path})"
    else
      echo "Warning: Path ${path} does not exist, skipping..."
    fi
  done
}

# Restore function to untar the cached directories
restore() {
  echo "Restoring cache from ${CACHE_DIR}..."
  if [ -d "${CACHE_DIR}" ]; then
    for archive in "${CACHE_DIR}"/*.tar; do
      serialized_path=$(basename "${archive}" .tar)
      original_path=$(deserialize_path "${serialized_path}")
      echo "Extracting ${archive} to ${original_path}..."
      # Create the necessary directory structure and extract
      mkdir -p "$(dirname "${original_path}")"
      tar -xf "${archive}" -C "$(dirname "${original_path}")"
    done
  else
    echo "No cache found."
  fi
}


if [ "$1" == "save" ]; then
  cache
elif [ "$1" == "restore" ]; then
  restore
else
  echo "Usage: $0 [save|restore]"
  exit 1
fi
