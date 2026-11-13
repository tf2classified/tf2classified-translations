#!/usr/bin/env bash

set -e

SourceDir="${1:?Usage: $0 <SourceDir>}"
OutputDir="converted_${SourceDir}"
nErrors=0

mkdir -p "$OutputDir"

while IFS= read -r -d '' File; do
	Out="$OutputDir/${File#"$SourceDir"/}"
	mkdir -p "$(dirname "$Out")"

	if [[ "$File" != *.txt ]]; then
		cp "$File" "$Out"
		continue
	fi

	if [ "$(xxd -p -l 3 "$File")" != "efbbbf" ]; then
		echo "::error file=$File::$File is not UTF-8-BOM"
		(( nErrors+=1 ))
		continue
	fi

	iconv -f UTF-8 -t UTF-16LE "$File" -o "$Out"
done < <( find "$SourceDir" -type f -print0 )

exit "$nErrors"