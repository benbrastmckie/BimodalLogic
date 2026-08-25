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
| B0 | The archive is a single directory, found and excluded | Every traversal filters on the `*/Boneyard/*` name glob. When the archive was split across two directories a filter naming only the top-level one counted 29k archived lines as live; asserting the count is exactly 1 turns a second archive reappearing into a gate failure rather than a silent miscount |
| C1 | `lake build` and `lake build BimodalTest` exit 0 | Baseline correctness |
| C2 | `#print axioms` for four flagship theorems matches a recorded baseline | Detects a proof silently rerouted through different dependencies — invisible to a green build and an unchanged sorry count |
| C3 | Exactly one structural `sorry`, located **by content** | Asserting a line number breaks on any edit above it; the check finds the enclosing declaration instead |
| C4 | Every `import FormalSystem.*` / `import BimodalTest.*` resolves | Catches a half-finished file move |
| C5 | Every module-shaped `Bimodal.*` path in non-`specs/` markdown resolves | A `.lean`-only rewrite leaves documentation dangling |
| C6 | Known-unreachable live modules still compile | Code outside the build graph cannot rot unseen |
| C7 | Live inventory (informational, never asserted) | The correct source for any file count |
| C8 | Every Lean-bearing subdirectory has exactly one sibling aggregator `X.lean` beside `X/` | One convention, checkable |
| C9 | Zero task-number citations under `FormalSystem/` | Task numbers are renumbered by archival and mean nothing to a later reader |
| C10 | Zero references to the pre-relocation `FormalSystem/{docs,latex,typst}` paths | `docs/`, `latex/` and `typst/` live at the project root |
| C11 | Every `import` inside `FormalSystem/Boneyard/` resolves, or is waived | The archive is never compiled, so `lake build` cannot see its imports rot. 65 archived import lines were already dangling when the two archives were consolidated |
| C12 | Every **slash-shaped** source path in `docs/` + `README.md` resolves | C5 matches only *dotted* module names, so the slash form of `FormalSystem/Metalogic/Bundle/BFMCS.lean` is invisible to it. A table naming six source files, four of which did not exist, survived a green gate on exactly this blind spot |
| C13 | Every relative markdown link in `docs/` + `README.md` resolves | Nothing checked `docs/` links at all; 96 of them had rotted, several pointing outside the repository |
| C14 | Documented axiom and sorry counts match the tree, and the two headline theorems C2 does not cover match their axiom baseline | C2 and C3 assert facts about the *tree*; C14 is what asserts the *documentation* agrees with them. `docs/` had documented the axiom count as 21 against an actual 45, and the sorry count as 12 against an actual 0 |
| C9D | Task-number citations under `docs/` (computed always, **soft** by default) | C9's rule binds `docs/` too, but `docs/` does not yet satisfy it. Reported at every gate so the debt is visible rather than forgotten |

### Why C5 was not simply extended

C12 is a separate check rather than a widening of C5's regex, and this is deliberate.
Extending C5 to also match `Bimodal.*` would immediately turn the gate red on occurrences in
`FormalSystem/**/README.md` that are a separate piece of work. C12 covers the *slash* form over
a *different scope*, so it can be enforced today without holding the gate hostage to unrelated
files. Do not merge the two.

C12's pattern includes `Logos/` and `Bimodal/` — the two pre-merge tree roots. Neither resolves
to anything in the current tree, so any occurrence is a defect by construction, which is the
point of naming them.

## The Companion Files

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

### `scripts/boneyard-import-waivers.txt` — unrepairable archived imports (C11)

An archived file is outside the import closure, so nothing compiles it and nothing
notices when a module it imports is deleted or moved. C11 closes that hole: every
`import FormalSystem.*` / `import BimodalTest.*` line under `FormalSystem/Boneyard/`
must resolve to a file on disk, or appear here.

Entries are permanent records of imports that **cannot** be repaired — the target was
deleted outright, or its name is genuinely ambiguous and choosing a target would
fabricate provenance. Each carries the reason, and a deletion carries the commit that
did it.

This is not a backlog. Before adding an entry, prove there is no unique target file on
disk; if there is one, fix the import instead. C11 reports entries that no longer occur
as stale, on the C5 model, so the file cannot become a dumping ground.

### `scripts/markdown-link-allowlist.txt` — link-syntax illustrations (C13)

Markdown **files** (not individual links) whose relative links are not resolution-checked. Only
two justifications are admissible, and both are about links that illustrate link *syntax*
rather than links a reader is meant to follow: template snippets showing what a directory
README should look like, and grep patterns inside a fenced code block that happen to parse as
markdown links. Three files qualify today.

"This link is broken and I do not want to fix it" is not an admissible reason. Fix the link, or
delete it and keep the prose.

`scripts/readme-lint.sh` reads the same file, so the two checks cannot disagree about what
counts as an illustration.

### `scripts/markdown-slash-path-allowlist.txt` — hypothetical source paths (C12)

Slash-shaped paths permitted not to resolve. The bar is a path that is deliberately
hypothetical — a "create this file" instruction in a guide. Prefer naming the containing
directory instead, which resolves and needs no entry at all; that is why this file is currently
**empty**.

Both allowlists report entries that no longer match anything as an `INFO` line, so neither can
silently rot.

C11 ships enforced, with no `ENFORCE_C11` flag: unlike C8/C9/C10 below, the invariant was
already true at the moment the check landed, so there was never a red phase to gate.

## Adding a Check

Checks C8, C9, C10 and C9D describe end-state invariants that a tree in mid-reorganization
does not yet satisfy. Each is computed and reported from the outset but gated behind an
`ENFORCE_C<n>` variable near the top of the script; while the flag is 0 the check prints
a `TODO` line and does not affect the exit code. This makes progress visible without a
permanently-red gate.

`ENFORCE_C9_DOCS` is the live example. It defaults to **0**, and the check reports a
three-figure citation count at every gate, two thirds of it in a single historical file
(`PHASED_IMPLEMENTATION.md`). Verify it is a real computation rather than a stub with:

```bash
ENFORCE_C9_DOCS=1 bash scripts/check-module-invariants.sh --no-build   # exits 1, with a count
```

Flip the default to 1 once those citations are cleared.

C12, C13 and C14 ship **enforced**, with no flags, because the work that cleared their debt
landed in the same change that added them. C14 has two halves: a content scan that always runs,
and a `#print axioms` half that skips cleanly under `--no-build` exactly as C2 does.

**Never flip an `ENFORCE_` flag back to 0 to make a gate pass.** Preventing exactly that
is why the flags are named and defaulted in the script rather than passed on the command
line.

## When to Run It

- After any file move, rename, or import change
- Before committing a change to the module structure
- Whenever you need a live file count — use C7's output rather than an ad-hoc `find`,
  which will get the Boneyard exclusion wrong

## Related Documentation

- [Metalogic architecture map](../../FormalSystem/Metalogic/README.md)
- [Module organization](MODULE_ORGANIZATION.md)
- [Library README](../../FormalSystem/README.md)

## A note on this file

C12 and C14 scan `docs/`, and this file is in `docs/`. Prose here that names a hypothetical
source path, or quotes a stale count in the shape the tripwire matches, will fail the very
checks it documents. That is the checks working, not a false positive: both were caught on this
page while it was being written. Cite a path that resolves, and phrase a historical count so it
does not read as a current claim.
