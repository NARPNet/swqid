#!/usr/bin/env bash

SCRIPT_DIR="$(dirname "$(realpath "$0")")"

VERSION=$(cat ../version.txt)

echo "DID YOU UPDATE THE VERSION?"
read -p "Press enter to continue"
echo
echo "Making release zip ..."
echo
pushd . >& /dev/null
cd "$SCRIPT_DIR"
cd ../src
find . -name '*.sh' -exec chmod 770 {} \;
find . -name '*.ps1' -exec chmod 770 {} \;
rm -rf ../release
mkdir -p ../release
cp ../README.md swqid/
zip -9 -r "../release/swqid-${VERSION}.zip" swqid
rm swqid/README.md

popd >& /dev/null

echo
echo "Done."
echo

read -p "Press enter to continue"