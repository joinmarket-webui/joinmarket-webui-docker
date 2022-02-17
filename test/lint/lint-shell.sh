#!/usr/bin/env bash
#
# Copyright (c) 2018-2021 The Bitcoin Core developers
# Distributed under the MIT software license, see the accompanying
# file COPYING or http://www.opensource.org/licenses/mit-license.php.
#
# Check for shellcheck warnings in shell scripts.

export LC_ALL=C

# Disabled warnings:
disabled=(
    SC2034 # parsedval appears unused. Verify use (or export if used externally).
)

EXIT_CODE=0

if ! command -v shellcheck > /dev/null; then
    echo "Skipping shell linting since shellcheck is not installed."
    exit $EXIT_CODE
fi

SHELLCHECK_CMD=(shellcheck --external-sources --check-sourced --source-path=SCRIPTDIR)
EXCLUDE="--exclude=$(IFS=','; echo "${disabled[*]}")"
# Check shellcheck directive used for sourced files
mapfile -t SOURCED_FILES < <(git ls-files | xargs gawk '/^# shellcheck shell=/ {print FILENAME} {nextfile}')
mapfile -t FILES < <(git ls-files -- '*.sh')
if ! "${SHELLCHECK_CMD[@]}" "$EXCLUDE" "${SOURCED_FILES[@]}" "${FILES[@]}"; then
    EXIT_CODE=1
fi

exit $EXIT_CODE

