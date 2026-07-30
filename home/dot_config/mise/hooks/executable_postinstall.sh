#!/usr/bin/env bash
set -euo pipefail

case "${MISE_INSTALLED_TOOLS:-}" in
  *ruby*)
    gem update --system --no-document
    gem install bundler --no-document
    ;;
esac
