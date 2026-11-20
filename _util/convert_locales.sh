#!/usr/bin/env bash

set -e

SourceDir="$(realpath "${1:?Usage: $0 <SourceDir>}")"
OutputDir="converted_$(basename "$SourceDir")"
nErrors=0

mkdir -p "$OutputDir"

while IFS= read -r -d '' File; do
	Out="$OutputDir/${File#"$SourceDir"/}"
	mkdir -p "$(dirname "$Out")"

	if [[ "$File" != *.txt ]]; then
		echo "::error file=$File::Unexpected file $File"
		(( nErrors+=1 ))
		continue
	fi

	if [[ "$(LC_ALL=C head -c 3 "$File" | od -An -tx1 | tr -d ' \n')" != "efbbbf" ]]; then
		echo "::error file=$File::$File is not UTF-8-BOM"
		(( nErrors+=1 ))
		continue
	fi

	iconv -f UTF-8 -t UTF-16LE "$File" -o "$Out"
done < <( find "$SourceDir" -type f -print0 )

exit "$nErrors"