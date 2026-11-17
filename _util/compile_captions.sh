#!/usr/bin/env bash

set -e

SourceDir="$(realpath "${1:?Usage: $0 <SourceDir>}")"
OutputDir="compiled_$(basename "$SourceDir")"
BinDir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)/bin/linux64"
nErrors=0

mkdir -p "$OutputDir"

while IFS= read -r -d '' File; do
	Out="$OutputDir/${File#"$SourceDir"/}"
	mkdir -p "$(dirname "$Out")"

	LD_LIBRARY_PATH="$BinDir:${LD_LIBRARY_PATH:-}" "$BinDir/captioncompiler" "$File" -o "$(realpath -m "$OutputDir")"
done < <( find "$SourceDir" -type f -print0 )

exit "$nErrors"