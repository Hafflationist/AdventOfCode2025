# justfile

default:
    @echo "Usage: just <task>"
    @echo "Available tasks: t1"

# Evaluate day 1
eval TAG:
  nix eval --extra-experimental-features pipe-operators --option max-call-depth 4294967295 -f {{TAG}}/default.nix
