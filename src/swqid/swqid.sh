#!/usr/bin/env bash

export version="0.9.0-beta"
export author="lobanz@protonmail.com"

if [ $# -ne 2 ]
then
  echo ""
  echo "FLAMP Relay File Queue ID Switcher"
  echo "Version: ${version}"
  echo "Author: ${author}"
  echo ""
  echo "Simple program to change a FLAMP relay file from one queue id to another."
  echo ""
  echo "Usage: $(basename $0) <new_queue> <relay_file>"
  echo ""
  echo "Where <new_queue> is the new queue ID you want to use, and"
  echo "<relay_file> is the relay file you want to switch the queue in."
  echo "The new relay file is printed to the standard output."
  echo ""
  echo "Example: $(basename $0) 1234 my_file.txt > new_file.txt"
  echo ""
  echo "This example converts the existing relay file called my_file.txt,"
  echo "changes the queue to 1234 and puts the result in new_file.txt."
  echo ""
  exit 1
fi

QUEUE_NEW=$1
RELAY_FILE=$2

# Make sure relay file is readable
if ! [ -r "$RELAY_FILE" ]
then
  echo "Could not read file '$RELAY_FILE'" >&2
  exit 2
else
  # Determine existing queue id of relay file
  # Looks for ">{XXXX:" where XXXX is the queue id and uses the first match
  QUEUE_IN=$(sed -rn '/.*>\{(\w+):.*/{s//\1/p;q}' "$RELAY_FILE")

  # Make sure we could determine existing queue id
  if [ -z "$QUEUE_IN" ]
  then
    echo "Could not determine queue id for file '$RELAY_FILE'" >&2
    exit 3
  else
    sed -r "s/>\{(\w+)/>{$QUEUE_NEW/g" "$RELAY_FILE"
  fi
fi 

exit 0
