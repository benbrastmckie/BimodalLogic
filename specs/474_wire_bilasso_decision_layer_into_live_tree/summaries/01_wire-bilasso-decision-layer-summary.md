# Implementation Summary: Wire the BiLasso Decision Layer into the Live Tree

- **Task**: 474
- **Plan**: `specs/474_wire_bilasso_decision_layer_into_live_tree/plans/01_wire-bilasso-decision-layer.md`
- **Status**: COMPLETED — all four phases, four commits
- **Type**: lean4

## What Landed

**Phase 1 (`9bd8fbc89`) — registration and manifest retirement, atomic.**
One import of the re-export `FormalSystem.Metalogic.Decidability.BiLasso` added to
`FormalSystem/Metalogic/Decidability.lean`, plus one `## Submodules` bullet; the `## Status` block
rewritten earlier this session was left untouched (verified by reading the staged diff: exactly
one import line and one bullet). In the same commit, exactly 15 module-path lines deleted from
`scripts/module-invariants-manifest.txt`. Three block comments rewritten, including the one whose
"DELETE this line when the bi-lasso re-export lands" instruction would have broken C6.

**Phase 2 (`d5715e88d`) — `BiLasso/Assembly.lean`.**
The merged, previously-compiled probe source transcribed as a live module with five declarations,
wired into `BiLasso.lean`. No manifest entry — it is reachable through the aggregator registered
in Phase 1.

**Phase 3 (`e62203aff`) — `BiLasso/README.md`.**
The stale pointer to `specs/469_.../evidence/` replaced with a pointer to `Assembly.lean` naming
the five declarations; a matching Modules-table row added. The `fmp` framing above it is unchanged.

**Phase 4 (`380fda670`) — `specs/ROADMAP.md`.**
New `### Bi-Lasso Decision Layer` subsection under `## Other Open Items`, beside
`### FMP Truth Preservation` and tagged "Decidability track only". Roadmap BiLasso mentions: 0 -> 5.

## Measurements

Re-derived rather than trusted, by replaying `check-module-invariants.sh`'s own `roots`/`seen`
reachability walk against a graph with the new import spliced in, **before** editing:

- Unreachable live modules **37 -> 22**; exactly 15 modules flip, and they are exactly the
  aggregator plus its 14 imports. The plan's 15/4/1 split is exact.
- The four `Extend`/`Successor`/`Orbit`/`Agreement` modules, `Semantics.Extension.PeriodicExtension`
  and `BimodalTest.Metalogic.PeriodicExtensionAxiomTest` all stay unreachable after wiring — so
  all six manifest lines were kept, all six verified present at the close.

Closing gate, full harness green (`ALL CHECKS PASSED`):

- C1: `lake build` and `lake build BimodalTest` both exit 0
- C2: all four flagship axiom sets match baseline
- C3: sole structural sorry is `theorem countermodel_discrete`
  (`FormalSystem/Metalogic/WeakCanonical/Transfer.lean:1102`) — count did not increase
- C6: `all 22 unreachable live module(s) are manifested`, all 20 non-broken still compile in
  isolation, and no manifest entry names a reachable module
- C5: markdown module paths resolve, including the new `Assembly` path
- Declared `axiom` count in `FormalSystem/`: 7 before, 7 after — none introduced

Axiom sets of the five new declarations, measured independently in a scratch file outside the
source tree (`lake env lean`, exit 0): `not_validDiscrete_of_satAtState`,
`validDiscrete_iff_check`, `decidableValidDiscrete`, `validDiscrete_iff_checkFamily`,
`decidableValidDiscreteFamily` — each `[propext, Classical.choice, Quot.sound]`. **No
choice-freedom is claimed anywhere**, and the docstring says why the computing instance is not
the same property.

## What This Does Not Do

`Assembly.lean` takes the finite-model step as a hypothesis `fmp` and proves no part of it. The
layer model-checks a *given* `IntPresentation`; nothing in it quantifies over frames. No
documentation added by this task describes BiLasso as covering the semantic finite model property.

## Plan Deviations

- Phase 3 additionally adds an `Assembly.lean` row to the README's Modules table. The table
  enumerates every file in the directory, so a new module absent from it would have been a fresh
  false claim in the same file the phase exists to correct. No plan step was skipped, altered, or
  deferred.
