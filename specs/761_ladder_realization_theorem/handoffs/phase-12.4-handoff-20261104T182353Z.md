# Phase 12.4 Handoff — The Frozen-Bound Probe and the Gate's Two Owed Wirings

- **Phase**: 12.4, status `[COMPLETED]`
- **Immediate next action**: Phase 12.5 (the three re-homed conditions of `Real`), then 12.6.

## What landed

`specs/evidence/seam-gluing-ray-product/ladder-reps-bound-refutation.lean` (204 lines, MEASURED
at close), namespace `Probe761W`:

- `repsCntPre` at the FROZEN pre-widening `Tc + Tn + P + B + 2`, declared locally rather than
  imported, with `rkStepBPre`, `RKbPre`, `RKPre` and `decidableRKPre` over it — verbatim the
  library's own text with the one range argument as it stood. `repsCntPre_range` reads the range
  argument back as a theorem so the freezing is checkable and not just asserted.
- Three `decide`-checked refutations — `witnessA_not_RKPre` at `(1, 2, 2, 2)`,
  `witnessB_not_RKPre` at `(4, 6, 5, 2)`, `witnessC_not_RKPre` at `(0, 0, 0, 3)` — each with its
  `Count` and `Drift` step also by `decide`, at the `set_option` ceilings the research input
  recorded, unchanged.
- Three POSITIVE counterparts at the library's widened `RK`, each ONE application of
  `rk_of_count_drift`, never `decide`: `witnessA_RK`, `witnessB_RK`, `witnessC_RK`. This is the
  first use site of that lemma.
- `both_sides_A`/`both_sides_B`/`both_sides_C`: the two sides as conjuncts per tuple, so
  non-vacuity is witnessed on both sides per tuple and not only per probe.

`scripts/check-evidence-probes.sh`: a table block and a `WIRED` entry for this probe AND for
`seam-gluing-ray-product/ladder-tight-chain-nonliftability`, the 480-line probe Phase 11.9 landed
and left unprotected. Gate reports `PASS  all 49 wired probe(s) compile` — the authoring baseline
of 47 (46 `WIRED` + 1 `WIRED_REPO`) plus these two.

## Phase 11.9's three recorded statements, in their repaired form

Recorded as an annotation on this phase's own checklist item too, since this agent's plan-file
write authority covers phase headings and checklist items only. Phase 11.9's own body and its
`#### Reasoned Exclusions` record are byte-identical to their pre-dispatch text.

1. `0 < m` on the deletion count. At `m = 0` the derivative deletes nothing, IS the chain, and is
   a ladder path, so the recorded statement is false as written. Carried by
   `tightChain_iter_deletion_does_not_lift` and `tightChain_deletion_derivative_does_not_lift`.
2. The LIFTING form. The recorded conclusion `¬ IsLadderPath (delIterWalk …)` constrains the
   deleted walk's own register and is weaker than the record's claim. All three headlines,
   `tightChain_positive_deletion_does_not_lift` included, quantify the countdown and the register
   away.
3. Pins UNBOUNDED ABOVE. On a finite-`J` chain the last region is followed by the idle-forever
   tail, carries no pin above it, and the chain HAS a lifting deletion-derivative. The probe's
   declared object is the chain idle at every `v ≤ 0` and exactly at `2^j - 2` for `j ≥ 1`.

The probe's own headline names already carry all three under honest names; this records the
correspondence and does not restate or re-sign them.

## Deviation

**Namespace.** The phase directs `Probe761R`, which `ladder-unconstrained-parameter-refutation.lean`
already uses (`CounterQuotient.lean`'s module docstring names it as such). Landed under
`Probe761W`. Phase 12.3's own citations in `repsCnt`'s docstring and in the axiom test were
written against `Probe761W` from the start, so no citation went stale.

## Verification evidence

- Guarded standalone compile of the new probe: exit 0, zero `error:`, zero
  `declaration uses 'sorry'`.
- `#print axioms` on all nine headline theorems plus the six step facts and
  `repsCntPre_range`: every profile a subset of `[propext, Classical.choice, Quot.sound]`; the
  six `Count`/`Drift` facts depend on no axiom at all. No `sorryAx`, no custom axiom, no
  `native_decide` (grep: 0 occurrences of `sorry`, `native_decide` or `^axiom ` in the file).
- Non-vacuity on both sides, per tuple: `both_sides_A`, `both_sides_B`, `both_sides_C`.
- The frozen bound really is frozen: `repsCntPre`'s range argument is `Tc + Tn + P + B + 2`, read
  off the definition and off `repsCntPre_range`; the probe declares it locally and does not
  import `repsCnt`; the three positive counterparts are `rk_of_count_drift` applications (grep of
  the proof bodies shows no `decide` in any of them).
- Witness C is named as the `P = 0` half in its own docstring.
- Both probes wired, in the same commit: `check-evidence-probes.sh` exits 0 reporting 49 wired.
- `check-task-references.sh --quiet` exits 0 on both probes.
- No library file changed: `git status --short FormalSystem/ Tests/` empty at close.
- `lean-sorry-census.sh FormalSystem Tests` exit 0, `sorry_count: 0`, unchanged, as it must be
  since this phase adds nothing to either root.
- Phase 11.9's recorded statement block and its `#### Reasoned Exclusions` record are untouched:
  the plan-file diff over this phase's commits touches Phase 12.4's own checklist items only.

## Gotcha for a successor

The gate requires a probe to be TRACKED, not merely present (`git ls-files --error-unmatch`). A
newly authored probe fails the gate with `FAIL (untracked: …)` until it is staged, which is
expected and is not probe rot.
