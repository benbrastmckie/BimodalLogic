# Phase 22.2 Handoff — GHR Lemma 10.2.5 by Structural Recursion

- **Status**: [COMPLETED]
- **Dispatch**: 17 (stall re-prompt; session sess_1793993028_251d86)
- **Plan**: `specs/867_formalize_gabbay_separation_ztime/plans/03_structural-route-measure-split.md`

## Immediate next action

Phase 22.3 (`uTypeCount` and GHR Lemma 10.2.6). Its part (b) obligation — "separation does not
raise the count" — now cites `isUTyped_sepU`, landed here, rather than `isUTyped_sepSnce`, which
covers (b) only at 10.2.4; the plan revision already made that substitution in the task text, so
the citation is available and no further prerequisite is outstanding.

## Proof state

No open goals. `lean-sorry-census.sh`: `sorry_count: 0` across all eight resolved source roots.
Full unscoped guarded `lake build`: exit 0, zero `error:`, 2961 jobs; `.olean` newer than source
for the touched module.

## What landed

Four additive declarations in the module Phase 22.1 created, exactly at the Scope Hypothesis
(one `def`, three theorems, zero new modules, zero measures):

- `FormalSystem/Metalogic/Expressiveness/SeparationZ/Hierarchy.lean` (169 -> 268 lines): `sepU`
  by plain structural recursion over `USForm`; `isUTyped_sepU` (the single-`untl`-type clause);
  `usTruth_sepU` (the equivalence); `isSeparated_sepU` (the separatedness, a one-line composite).
  The module docstring gained the record that these are GHR Lemma 10.2.5 in full and that the
  source's own induction on maximum nested-`S` depth above a `U(A,B)` is deliberately not
  formalized, naming D-h and why the structural recursion reaches the same conclusion.
- `FormalSystem/Metalogic/Expressiveness/SeparationZ/README.md`: module row (line count and
  description), one Key Results bullet, and the `## Not landed` section, which now opens at
  Lemma 10.2.6 rather than 10.2.5.
- `typst/generated/status.typ`, `README.md`, `FormalSystem/Metalogic/README.md`: regenerated
  counts.

## Key decisions

- Decision D-h was taken as the plan rules it, not re-litigated. The observable consequence the
  Scope Hypothesis asks for holds: `grep -rn 'snceDepthAbove\|hasUntl'` over the `SeparationZ/`
  subtree returns nothing, so the measure route's machinery is absent from the tree.
- `isUTyped_sepU` is proved **before** the equivalence, because it supplies the hypotheses
  `usTruth_sepSnce` demands at every `snce` node. The plan's warning is accurate: attempting the
  equivalence first is what makes the phase look harder than it is.
- Both transcription hazards Phase 22.1's handoff carried forward were honoured. The `snce` arm
  crosses its arguments (`snce ψ φ ↦ sepSnce A B (sepU A B φ) (sepU A B ψ)`), and the `untl` arm
  is the identity with no decidable-equality test.
- `sepU` is a plain `def` with no `noncomputable`, as the blocking check requires, and
  `#print axioms` reports it depends on no axioms at all — so the Phase 26 executability
  deliverable is not compromised through this layer.
- `usTruth_sepU` cites `usTruth_sepSnce` and `isUTyped_sepU` and re-derives no part of 10.2.4;
  `isSeparated_sepU` is the composite, not a second induction.

## Deviations

One, annotated inline on the final checklist item: two generated inventory blocks (`README.md`,
`FormalSystem/Metalogic/README.md`) also required regeneration, because the module's line count
moved and the phase's gates require `check-module-invariants.sh` green. Repaired through the
sanctioned `--emit-inventory` entry point. The same collision was recorded at Phases 21 and 22.1.

## Measured gates

- Scoped guarded build of `...SeparationZ.Hierarchy`: exit 0, zero `error:`, 1492 jobs.
- Full unscoped guarded `lake build`: exit 0, zero `error:`, 2961 jobs, `.olean` newer than source.
- `lean-sorry-census.sh`: `sorry_count: 0`.
- Vacuous-pattern grep: 1 hit, pre-existing at `FormalSystem/Examples/TemporalStructures.lean:495`
  (a `trivial` whose goal genuinely is `True`-shaped), in a file this phase does not touch.
- `axiom ` declarations: 14, unchanged from the Phase 22.1 baseline, none in a touched file.
- Axiom profiles, measured by `#print axioms` under `lake env lean`: `sepU` depends on no axioms;
  `isUTyped_sepU` and `isSeparated_sepU` on `propext`; `usTruth_sepU` on
  `propext, Classical.choice, Quot.sound`. All within the three standard axioms the landed
  eliminations already carry — nothing new.
- Blocking check — no `noncomputable` on `sepU`: the only occurrence of the token in the module
  is inside `sepU`'s own docstring, explaining its absence.
- Blocking check — ruling not bypassed: `snceDepthAbove`/`hasUntl` absent from `SeparationZ/`.
- `check-module-invariants.sh`: ALL CHECKS PASSED (exit 0) after the inventory regeneration.
- `check-metalogic-cycles.sh`: exit 0, recorded cycle and upward import set unchanged.
- `typst-sync-check.sh --fix`: PASS (status.typ regenerated; module map and machine appendix
  already in sync).
