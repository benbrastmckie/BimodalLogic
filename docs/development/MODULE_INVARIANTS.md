# Module Invariants Check

`scripts/check-module-invariants.sh` answers one question mechanically: **did a change
to the module structure break anything?** It exists so that "nothing broke" is a command
with an exit code rather than a judgement call.

```bash
bash scripts/check-module-invariants.sh              # everything (builds; ~1-2 min warm)
bash scripts/check-module-invariants.sh --no-build   # structural checks only (seconds)
```

Exit 0 means every check passed. Any failure names the specific check and the offending
file and line.

## What It Checks

| ID | Check | Why it exists |
|----|-------|---------------|
| B0 | Both Boneyards are found and excluded | A filter naming only the top-level `Boneyard/` counts 27k archived lines under `Kamp/Boneyard/` as live |
| C1 | `lake build` and `lake build BimodalTest` exit 0 | Baseline correctness |
| C2 | `#print axioms` for four flagship theorems matches a recorded baseline | Detects a proof silently rerouted through different dependencies — invisible to a green build and an unchanged sorry count |
| C3 | Exactly one structural `sorry`, located **by content** | Asserting a line number breaks on any edit above it; the check finds the enclosing declaration instead |
| C4 | Every `import Bimodal.*` / `import BimodalTest.*` resolves | Catches a half-finished file move |
| C5 | Every module-shaped `Bimodal.*` path in non-`specs/` markdown resolves | A `.lean`-only rewrite leaves documentation dangling |
| C6 | Known-unreachable live modules still compile | Code outside the build graph cannot rot unseen |
| C7 | Live inventory (informational, never asserted) | The correct source for any file count |
| C8 | Every Lean-bearing subdirectory has exactly one sibling aggregator `X.lean` beside `X/` | One convention, checkable |
| C9 | Zero task-number citations under `Theories/` | Task numbers are renumbered by archival and mean nothing to a later reader |
| C10 | Zero references to the pre-relocation `Theories/Bimodal/{docs,latex,typst}` paths | `docs/`, `latex/` and `typst/` live at the project root |

## The Two Companion Files

### `scripts/module-invariants-manifest.txt` — known-unreachable modules (C6)

`lake build` only compiles what is reachable from a Lake target root. A module that no
target imports is never compiled, so a broken import inside it goes unnoticed
indefinitely. Every such module must be listed here; C6 compile-checks each one with
`lake build <Module>`.

- C6 **fails** if an unreachable live module is missing from the file.
- C6 **fails** if an entry names a module that no longer exists.
- C6 **fails** if an entry names a module that is now *reachable* — `lake build` already
  guards it, so the line is stale and must be deleted.
- A `broken:` prefix marks a module known not to compile. It is still tracked, so it
  cannot be forgotten, but is not compile-checked. Removing the prefix is how a repaired
  module re-enters the gate.

Wiring a module into the build graph means **deleting** its line here.

### `scripts/module-invariants-allowlist.txt` — non-module dotted names (C5)

C5 cannot distinguish a module path from a fully-qualified namespace or declaration
name: both are dotted and capitalized. Names verified to be real namespaces or
declarations are listed here with the file and line that defines them.

This is a permanent, documented exemption — **not** a place to park a genuinely stale
module path. Add an entry only after confirming with `grep -rn` that the name is live.
C5 reports allowlist entries that no longer occur, so stale exemptions get pruned.

## Adding a Check

Checks C8, C9 and C10 describe end-state invariants that a tree in mid-reorganization
does not yet satisfy. Each is computed and reported from the outset but gated behind an
`ENFORCE_C<n>` variable near the top of the script; while the flag is 0 the check prints
a `TODO` line and does not affect the exit code. This makes progress visible without a
permanently-red gate.

**Never flip an `ENFORCE_` flag back to 0 to make a gate pass.** Preventing exactly that
is why the flags are named and defaulted in the script rather than passed on the command
line.

## When to Run It

- After any file move, rename, or import change
- Before committing a change to the module structure
- Whenever you need a live file count — use C7's output rather than an ad-hoc `find`,
  which will get the Boneyard exclusion wrong

## Related Documentation

- [Metalogic architecture map](../../Theories/Bimodal/Metalogic/README.md)
- [Module organization](MODULE_ORGANIZATION.md)
- [Library README](../../Theories/Bimodal/README.md)
