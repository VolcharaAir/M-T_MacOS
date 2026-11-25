#!/bin/bash
cd "$(dirname "$0")" || exit 1
bash scripts/build-macos.sh
result=$?
if [[ "$result" -eq 0 ]]; then
  open dist
else
  echo "Build failed (exit $result). Send the error above for diagnosis."
fi
read -r -p 'Press Enter to close… ' ignored
exit "$result"
