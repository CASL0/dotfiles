#!/bin/bash
set -e

PS1="[\u@\h] \w \$ "
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
. "/opt/homebrew/opt/asdf/libexec/asdf.sh"
