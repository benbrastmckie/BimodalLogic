# Handoff after Phase 6 (Part B applied, tree GREEN)

## Immediate next action

Phase 7.1 (`tools/prose_sweep.py --mode lean`) and Phase 7.2 (`--mode docs`) own disjoint file
trees and may run in parallel. Neither can break the build; both must be verified against it.

## State

Phases 1-6 COMPLETE and committed. Tree GREEN.

| Invariant | Value |
|---|---|
| `bash tools/build-all.sh` | GREEN, 2725 jobs |
| live `sorry` outside `Boneyard/` | 1, `theorem countermodel_discrete`, `Metalogic/WeakCanonical/Transfer.lean` |
| `scripts/check-module-invariants.sh` | ALL CHECKS PASSED |
| unmasked `defsWithUnderscore` | **20** (was 861) |
| all other linter categories | exactly at Phase 1 unmasked baseline |
| new axioms / `@[deprecated]` aliases | 0 / 0 |

## The build command changed

`lake build` alone builds ONLY `@[default_target] lean_lib FormalSystem`, leaving 22 source
files unbuilt — including `Automation/ProofStepExport.lean`. Use
`bash specs/402_.../tools/build-all.sh`, which adds `BimodalTest` and all 12 `lean_exe` roots.
A plain `lake build` is not a sufficient verification for this migration.

Two files are permanently uncovered: `Tests/BimodalTest/Semantics/SemanticBenchmark.lean` and
`Tests/BimodalTest/ProofSystem/DerivationBenchmark.lean`. They do not compile on the unmodified
tree either (verified at HEAD before any edit). Pre-existing breakage in orphan modules.

## What Phase 8 inherits

The 20 surviving `defsWithUnderscore`:

- 18 `tactic*` syntax declarations — the plan's anticipated decision.
- `FormalSystem.Automation.LemmaDB.Parser.Attr.tm_lemma` — an attribute declaration with no
  `.ilean` entry; same structural class as the 18, missed by the Phase 5.1 separation.
- `FormalSystem.Metalogic.WeakCanonical.Separation.sNestingAboveU.S_nesting_above_U_inner` —
  the Phase 5.2 table excluded this as a "parent-derived auxiliary" whose name Lean regenerates
  from the parent's. **That is false.** Renaming the parent moved only the namespace component;
  the final component is spelled literally in source. The other two excluded auxiliaries
  (`iddfs_search.iterate`, `bestFirst_search.searchLoop`) are genuinely parent-derived and did
  follow, which is why the error was not symmetric.

## Traps confirmed during Phase 6 — do not relearn them

- **`lake clean` with no argument deletes EVERY package's build dir, Mathlib included.** Use
  `lake clean Logos`.
- **A `lean_lib`'s glob is its root module's import closure.** Anything not transitively
  imported is neither built nor `.ilean`-covered, so a rename breaks it with no error anywhere.
- **The `.ilean` coverage gap was 30 sites, not the projected ~390** (0.117% of 25,640 spans).
  Five classes: intra-`structure` field references; `have ⟨pat⟩ : T := by` ascriptions;
  dot-notation projections; `macro` syntax quotations; plain unrecorded term refs.
- **A `macro` quotation reports its error at the USE site, not the definition site**, with a
  hygiene dagger on the name (`deduction_theorem✝`). A position-driven fixer edits the wrong
  file. Only one such site exists: `Automation/Tactics/Deduction.lean`.
- **Lean 4.33 writes ``Unknown identifier `x` `` with backticks**, and reports dot-notation
  failures as ``Invalid field `f`: the environment does not contain `FQN` `` — a different
  message shape carrying the fully-qualified old name.
