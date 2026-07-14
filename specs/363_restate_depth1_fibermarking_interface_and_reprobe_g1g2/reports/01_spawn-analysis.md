# Blocker Analysis: Task #358

**Parent Task**: #358 - Realization recursion `nf_nvar_exist_all_depths` (post-360 gap closure)
**Generated**: 2026-07-13
**Blocker**: The general-depth (m>=1) fiber-marking interface underlying both of task 358's
remaining supply legs (G1 interior rows 5-6, G2 exterior rows 8-11) is machine-refuted as FALSE.
Two sorry-free countermodel probes this session establish that neither leg can be built on the
current interface; both share one root cause.

## Root Cause

Plan v3 (`specs/358_realization_recursion_nf_nvar_exist_all_depths/plans/03_post-360-gap-closure.md`)
mandated two cheap GO/NO-GO probe phases before any general-m/general-depth build-out:

- **Phase 6** (Probe C0, general-m slice identification at m=1) — `[COMPLETED]`, verdict **NO-GO**.
  Countermodel theorem `kvE_probeM1_sliceId_NOGO`
  (`Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorPinnedProbeM1K.lean`)
  refutes rows 8-11 (the exterior `hslice*`/`hexclSlice*` obligations,
  `EndIntervalConsumerK.lean:141-162`).
- **Phase 8** (G1 independence probe, interior `hreal`/`hexcl` at general depth) — `[BLOCKED]`,
  verdict **NO-GO**, machine-confirmed to SHARE the Phase-6 root cause. Countermodel theorems
  `kvE_probeM1_interiorHreal_NOGO` and `kvE_probeM1_interiorGuard_identical` (same file) refute
  rows 5-6 (the interior obligations, `KampPrior.lean:835-846`).

**Shared mechanism (D7)**: depth-1 (and general depth >= 1) fiber marking is not pinned by
free-env or projected rendering. The countermodel constructs a "doppelganger-tail" fake fiber
`s* := nf_characteristic 1 5 [22, 25, 15, 2, 21]` that shares the honest pinned fiber
`[25, 15, 2, 18]`'s depth-0 atom 4-type but diverges in its tail. This fake:

1. Passes the atom-level admissibility fiber guard (conjunct-2 reads only depth-0 atoms).
2. Is free-env-realized (`22 in (18, 25)`) yet has NO pinned realization at any candidate
   witness (`m1_sstar_not_pinned` — the inner types at `19`/`20` force emptiness).
3. Is projection-invisible through the `igFoldBit (zone, nfk_projFresh)` arity-1 F1 channel
   (`InteriorGateGeneralK.lean:318`) — `nfk_projFresh (tau ⊕ s*) = nfk_projFresh tau` because the
   doppelganger difference lives entirely in slots this projection discards.

Because both the exterior slice-equality keying (rows 8-11, `kvE_futSliceEq`) and the interior
`igFoldBit` fold-bit guard (rows 5-6) key their obligation's hypothesis side to this same kind of
free-env/projected rendering, the fake fiber is indistinguishable from the honest one under
BOTH legs' current binder shapes — while the honest conclusion (a genuine pinned realizer / a
correctly-marked fiber) fails at the fake. This is one interface defect surfacing through two
consumer seams, not two independent defects: fixing the fiber-marking interface at its single
root (the rungK binder / `igFoldBit` consumer seam, `KampPrior.lean:835-846` +
`InteriorGateGeneralK.lean:318`) resolves both.

**Why this blocks task 358**: Phase 7 (G2 general-m supply) is gated on Phase 6 GO and cannot
proceed. Phase 8 (G1 interior supply) is independently NO-GO. Phase 9 (arm rewrite, retires
KampPrior.lean:361) depends on both Phase 7 and Phase 8. Phase 10 (:364 arity lift) depends on
Phase 9. The k=0/k=1 unconditional layers (rung0/rung1, `kampPrior_case1_arm_k0`, the m=0 supply
theorems from task 360) are untouched, unrefuted, and out of scope for the repair.

## Proposed New Tasks

### New Task 1: Restate the depth->=1 fiber-marking interface and re-probe G1/G2
- **Effort**: 6-10 hours
- **Task Type**: lean4
- **Rationale**: This is the sole blocking defect. Per plan v3's NO-GO escalation branch (the
  task-360 slice re-key precedent) and the explicit "SCOPE GUIDANCE" in this blocker's
  description, the repair is ONE interface restatement covering both legs, because they share
  one root cause and one fix seam (the rungK binder / `igFoldBit` consumer seam). Candidate
  approaches (either or a synthesis, to be adjudicated in-task against the two countermodels):
  (a) anchored/pinned item rendering — carry the depth->=1 fiber's full pinned coordinates
  through the binder rather than a free-env/projected summary; or (b) a depth-graded fiber guard
  — strengthen the admissibility/fold-bit guard so it distinguishes fibers by depth-graded
  content the projection currently discards (defeating both `m1_sstar` fake constructions).
  After restatement, re-run the EXISTING probes
  (`kvE_probeM1_sliceId_NOGO`, `kvE_probeM1_interiorHreal_NOGO`,
  `kvE_probeM1_interiorGuard_identical` in `ExteriorPinnedProbeM1K.lean`) against the new
  interface to confirm the doppelganger countermodel no longer applies to either leg. Territory:
  `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/InteriorGateGeneralK.lean`,
  `ExteriorPinnedConverseK.lean`, `ExteriorPinnedConversePastK.lean`, `ExteriorPinnedProbeM1K.lean`
  (re-probe leaf), and the rungK binder declarations in
  `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean` (read/reference only for the
  binder shape at :835-846; the general-m/general-depth supply build-out itself remains task
  358's Phase 7/8, downstream of this restatement). MUST NOT touch or re-open the k=0 layers
  (rung0/rung1, m=0 supply theorems, `kampPrior_case1_arm_k0`) — these are unrefuted and frozen.
  Zero-debt terminus: no sorry, no vacuous def; if neither candidate approach closes green, the
  task returns [BLOCKED] with its own escalation rather than landing debt.
- **Depends on**: None

## Dependency Reasoning

This blocker analysis proposes exactly one new task. There is no internal dependency graph to
reason about among new tasks (a single-task decomposition is explicitly sanctioned by the Task
Minimization Principle when the blocker's own scope guidance says so — see "SCOPE GUIDANCE" in
the triggering blocker description: "This should be ONE focused lean4 task ... not a
decomposition").

- **Parent task 358 depends on New Task 1**: task 358's Phase 7 (G2 supply) and Phase 8 (G1
  supply) both consume the fiber-marking interface that New Task 1 restates. The SPECIFIC
  implementation detail New Task 1 must fix — which of the two candidate repair shapes
  (anchored/pinned rendering vs depth-graded guard, or a synthesis) is adopted, and the exact
  binder signature that results — directly determines how Phase 7's general-m slice
  identification/uniqueness kernels and Phase 8's `hreal`/`hexcl` supply theorems are stated and
  proved. This is a genuine implementation-detail dependency (not merely "must complete first"):
  Phase 7/8's proof obligations are literally re-keyed to whatever shape New Task 1 lands.

## After Completion

Once New Task 1 is complete (interface restated, both legs' probes re-run and returning GO),
resume the parent task with `/implement 358`. Implementation resumes at Phase 7 (G2 general-m
slice supply), which will now consume New Task 1's restated interface; Phase 8 (G1 interior
supply) follows once Phase 7's shared uniqueness/readback kernel (R3) lands, then Phases 9-10
proceed unchanged from plan v3.

The blocker will be resolved because: New Task 1 removes the doppelganger-tail fake fiber's
indistinguishability from the honest fiber at depth >= 1 — the exact defect both countermodel
theorems (`kvE_probeM1_sliceId_NOGO`, `kvE_probeM1_interiorHreal_NOGO`,
`kvE_probeM1_interiorGuard_identical`) exploit. With fiber marking pinned (or depth-graded) at
the rungK binder / `igFoldBit` seam, the fake construction either fails to satisfy the
restated hypothesis side or is correctly excluded by the strengthened guard, so both Phase 7's
and Phase 8's supply theorems become provable statements rather than false ones.
