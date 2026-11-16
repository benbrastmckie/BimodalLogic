# Phase 11.39 handoff — the `untl` jump clause: outcome (b)

**Status**: Phase 11.39 `[BLOCKED]` (plan v24, dispatch 67). Not entered: 11.33–11.35, 11.40.

**Immediate next action**: a `/revise`. The path forth's state relation cannot be `Zrel` at any
thresholds; the route question is which object-dependent relation replaces it. Phase 11.33 (the
time-boxed gap-clip gate) is independent of this and remains enterable.

**Current state**:
- `LadderStepFrag.lean` (1197 lines) now carries `LnkRow.refl`, `RowFrag`, `truth_iff_of_lnkRow`
  (the whole truth lemma over the row link at the `⊡`-free level: `untl` and `snce`, every
  guard), `LnkRow.first_zero`, `LnkRow.region_end_obj`.
- New wired probe `specs/evidence/seam-gluing-ray-product/ladder-row-link-residue-obstruction.lean`:
  `no_rowLinked_path_of_Zrel` — on a three-state object (pending `2`-cycle, idle sink), for every
  `(A, B)`, `Zrel A B`-related states with no row-linked path at a row budget `(a, b + 1)`,
  `1 ≤ a + b`.
- The path forth `exists_rowLinked_path` is declared nowhere.
- All gates green: guarded `lake build` (2976 jobs), `build BimodalTest` (3044 jobs),
  `check-module-invariants.sh`, `readme-lint.sh`, `check-evidence-probes.sh` (65 probes),
  `typst-sync-check.sh`, `verify-deploy.sh` (15 checks).

**Key findings**:
- The truth lemma over `LnkRow` needs no path construction and is NOT a corollary of the path
  forth; the two halves of the phase's Goal are independent.
- A row link forces the two current pending regions to end at one object state
  (`LnkRow.region_end_obj`). Different countdowns mean object walks of different lengths, so the
  state relation must carry a residue of the countdown: `(K1)`'s modulus. `(K2)`'s margin was not
  reached.
- Not known: whether `Zrel` plus a residue conjunct suffices; whether the register offset after a
  lengthened region can be absorbed without the cascade.

**Deviations**: the probe and its wiring in `scripts/check-evidence-probes.sh` are outside the
phase's file list (the list names the module, the record and the axiom test); three README
inventory surfaces and `typst/generated/status.typ` were regenerated for line counts.

**Record**: `records/round-24-jump-clause-verdict.md`.
