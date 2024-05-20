#!/bin/bash
set -e

if [[ -r "${HOME}/.bashrc" ]]; then
    # shellcheck source=/dev/null
    source "${HOME}/.bashrc"
fi
