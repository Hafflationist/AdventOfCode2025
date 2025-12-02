# justfile

default:
    @echo "Usage: just <task>"
    @echo "Available tasks: t1"

# Evaluate day 1
t1:
    nix eval -f T1/default.nix
