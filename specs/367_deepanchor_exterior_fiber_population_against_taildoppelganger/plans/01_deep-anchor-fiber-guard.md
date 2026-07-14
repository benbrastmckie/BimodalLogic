# Implementation Plan: Task #367

- **Task**: 367 - Deep-anchor exterior fiber population against tail-doppelganger (interface refinement)
- **Status**: [NOT STARTED]
- **Effort**: 10 hours
- **Dependencies**: None (parent task 358 is [BLOCKED] on this; it resumes via `/revise 358` after this lands)
- **Research Inputs**:
  - specs/358_realization_recursion_nf_nvar_exist_all_depths/reports/09_spawn-analysis.md
  - specs/358_realization_recursion_nf_nvar_exist_all_depths/handoffs/phase-2-v05-handoff-20260714.md
- **Artifacts**: plans/01_deep-anchor-fiber-guard.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md, .claude/rules/lean4.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Task 358's general-m G2 kernel (G2-1 `kvE_{fut,past}SliceId_of_end` at general m) and the
rows-8-9 binders (`_hsliceFut`/`_hslicePast`,
`Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/EndIntervalConsumerK.lean:154-167`)
are machine-refuted at fiber depth >= 1 by an all-honest TAIL-doppelganger: the sorry-free
certificates `kvE_probe358_tailDG_gapItem_pinned_fails` and
`kvE_probe358_tailDG_sigma_in_population`
(`.../NfMultiAnchorBridge/ExteriorPinnedProbe358TailK.lean`, floor axioms
`[propext, Classical.choice, Quot.sound]`, zero guard-unfoldings) show that a fully realized
fake-tail slice passes the 364-strengthened `kvE_futAdmissible` through the sanctioned
byte-stable route (`kvE_futRealizer_admissible`, `ExteriorNegationK.lean:131`), sits on the
REAL ambient's fiber (`nfk_dropFresh sigma = qnf.1`), and marks an un-pinnable gap fiber.
The depth-0 row check is the ONLY antecedent tying a marked fiber's realizing tail to the
ambient; this task designs and lands a depth-recursive (hereditary) on-fiber/content guard
that anchors the exterior fiber population to the ambient one layer deeper (and, hereditarily,
all the way down), restating the rows-8-9 binders against it. Scope is the interface
refinement + re-probe ONLY; the general-m G1/G2 supply build-out stays with task 358.

**Definition of done is the re-probe, not the restated signature**: every phase below ends at
a machine-checkable green/refute gate (a named sorry-free certificate at floor axioms or a
scoped `lake build`), per the task-363/364 probe-first methodology. Zero-debt terminus: no
sorry, no vacuous def, no forcing a proof against a live countermodel. If neither candidate
approach closes green after the one permitted redesign loop, exit `[BLOCKED]` with a
structured escalation record (matching the phase-2-v05 handoff format).

### Research Integration

From the spawn analysis (report 09) and the phase-2-v05 handoff:
- The blocker is a genuinely NEW gap one layer deeper than 363/364 — not a re-litigation.
  Task 364's co-realization check has no purchase: every element of the tail-doppelganger cast
  is honest (realized). Any sigma-internal realizability-based strengthening therefore CANNOT
  work; the anchor must reference `qnf` (the ambient), i.e. it lives at the rows-8-9 binder
  antecedent, not inside `kvE_futAdmissible`.
- Candidate shapes (from the handoff, NOT prescriptive — the implementer adjudicates by
  probe): (a) a recursive on-fiber guard requiring sigma's marked fibers' one-slot-dropped
  DEEP forms to be qnf-marked one level down (hereditary fiber anchoring); (b) restate the
  rows-8-9 antecedents with a deep on-fiber condition replacing `nfk_dropFresh sigma = qnf.1`
  directly, following the `ExteriorFiberConsistencyK.lean` guard-and-`_of_realized`-lemma
  template one layer down.
- The free-env -> pinned upgrade (`kvE_futGapItem_pinned_zero` shape) is FALSE at fiber
  depth 1 (`kvE_probe358_tailDG_gapItem_pinned_fails`); route R2 already refutes any
  m=0-generalization argument at depth 1. Do NOT re-attempt G2-1 against the current
  interface.
- Binder-level closure (analytical, handoff): on (Q, <) with one discrepantly-placed R-point,
  automorphism homogeneity lets the pure fake characteristic fire the ENTIRE `hsliceFut`
  antecedent stack while every qnf-marked sigma' carries the real coupling vector — rows 8-9
  at m >= 1 are false-as-restated. The deep anchor must provably dissolve this family too
  (every fake characteristic's marked deep fiber carries the fake coupling vector, never
  qnf-marked).
- G2-2 (`SliceUnique`) is NOT refuted by this cast; G1 and rows 10-11 are downstream of the
  same restatement. All remain task-358 scope.

### Prior Plan Reference

No prior plan for task 367. The structural template is task 364's plan
(`specs/364_strengthen_fiberelemconsistent_mate_check_against_planted_unrealizable_mates/plans/01_strengthen-fiber-mate-check.md`,
executed [COMPLETED] in 10h, zero redesign loops): probe-only candidate adjudication first,
honest-preservation crux at probe level BEFORE promotion, dedicated adversarial re-plant with
a one-redesign churn cap, a single production-touching phase behind stable names, then a full
re-probe gate. Calibration lessons from 364: (i) the adjudicated candidate was NOT the primary
paper candidate — plan candidates non-prescriptively and let the probes decide; (ii) most
frozen certificate proofs survived untouched (only one needed a proof-script repair); (iii)
the universal exclusion engine was worth front-loading into Phase 1. This task is one layer
deeper and binder-touching (364 was definition-internal), so consumer re-threading is expected
where 364 had none — reflected in Phase 4's scope and risks.

### Roadmap Alignment

No roadmap consultation requested (roadmap_flag not set). The task is the sole blocker on the
task-358 critical path (KampPrior live sorries `:519`/`:522` are upstream-blocked on the
rows-8-9 interface).

## Goals & Non-Goals

**Goals**:
- Design (candidate (a), (b), or a synthesis — adjudicated in-task against machine probes) a
  depth-recursive (hereditary) on-fiber/content guard `kvE_deepOnFiber qnf sigma : Bool`
  (name indicative) anchoring the exterior fiber population to the ambient beyond the depth-0
  row `nfk_dropFresh sigma = qnf.1`.
- Machine-certify at probe level, BEFORE any production edit: (i) the tail-doppelganger slice
  fails the guard w.r.t. the real ambient (excluded from the refined population), (ii)
  honest preservation — realized slices over the ambient's own tail pass the guard
  (`_of_realized`-style crux, general model/signature), (iii) m=0/depth-0 inertness so the
  frozen m=0 discharge layer is untouched, (iv) survival of a dedicated adversarial re-plant
  (deeper doppelganger + content-copying plant) under a ONE-redesign-loop churn cap.
- Land the guard in a NEW additive production module and restate the rows-8-9 binders in
  `EndIntervalConsumerK.lean:154-167` IN PLACE behind byte-stable names/signatures everywhere
  else: the binder restatement is the ONLY statement change; all frozen 363/364/m=0/k<=1/360
  assets stay byte-unchanged; threading sites are repaired at proof-script level via
  byte-stable `_of_realized`/`_zero`-adapter lemmas — never by unfolding any guard.
- Full re-probe gate: successor guard-level certificates against the production definition +
  re-verification of ALL prior GO certificates (363's 8, 364's set, the 358 records including
  `kvE_probe358_eP_atomMate_present` and both `kvE_probe358_tailDG_*`, M1 residuals) + frozen
  -layer diff audit + sorry-count discipline (exactly KampPrior `:519`/`:522`).
- Write `.orchestrator-handoff.json` recording the final guard shape (it dictates the witness
  term task 358's re-keyed G2 supply must construct) and the explicit next action
  `/revise 358` then `/implement 358`.

**Non-Goals** (scope boundary — MUST NOT):
- The general-m G1/G2 supply build-out itself: the four G2 supply theorems, G2-1 slice-id
  kernel at general m, G2-2 `SliceUnique`, G1 interior supply, rows 10-11, and the
  `KampPrior.lean:519`/`:522` sorry retirements — all resume on task 358 via `/revise 358`
  after this lands.
- Touching or re-opening frozen layers: m=0 kernels (`_zero` family, e.g.
  `kvE_futSliceId_of_end_zero`), k<=1 rungs (`kampPrior_case1_arm_k0`), task 360's m=0
  supply, and ALL of task 363/364's guard/lemmas/probes (`ExteriorFiberConsistencyK.lean`,
  `ExteriorFiberConsistencyProbeK.lean`, `ExteriorFiberConsistencyProbe364K.lean`) — zero
  statement edits to any of these; byte-unchanged except where a docstring-only supersession
  note is explicitly planned (Phase 5, `ExteriorPinnedProbe358TailK.lean` only).
- Redesigning `kvE_futAdmissible`/`kvE_pastAdmissible` conjunct structure or
  `kvE_fiberElemConsistent` (the countermodel is realized — sigma-internal strengthening is
  provably the wrong lever here).
- Weakening or negating the frozen 358 tail-doppelganger certificates: both remain TRUE
  statements about the OLD interface and are kept compiling as the permanent regression
  record.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| One-level-deeper anchoring is defeated one MORE layer down (depth-2 tail-doppelganger), replaying this exact blocker pattern (363 -> 364 -> now) | H | H | The guard MUST be hereditary (full recursion to depth 0), not a single extra level. Phase 3 includes a dedicated depth-2 doppelganger re-plant as a mandatory gate; a defeat there forces the redesign loop, not a "good enough" landing |
| Type/arity bookkeeping: `qnf : NormalForm sig (m+2) 3` marks `sigma' : NormalForm sig (m+1) 4`; `sigma : NormalForm sig (m+1) 4` marks fibers `s : NormalForm sig m 5`. Comparing sigma's marked fibers' one-slot-dropped deep forms against qnf's deep marking crosses both a depth offset and an arity offset (the x1 slot); a naive formulation does not typecheck (364's Risk-1 analog, one layer down) | H | M | Phase 1 designs the comparison form explicitly (candidate forms: `mergeNF`/`skipFin` slot-drop of `s` at the x1 position matched against qnf-marked sigma''s fibers; or content comparison routed through `nf_characteristic` of dropped tuples). Adjudicate by probe, not on paper |
| Honest-preservation crux fails: for realizer-derived sigma over the real tail, the guard demands sigma's marked deep fibers appear in qnf's marking — this needs qnf's realization to mark the corresponding characteristics (the `hsigma.2` completeness direction). If the guard compares raw forms instead of characteristics, marked-set membership may be unprovable | H | M | Phase 2 proves `_of_realized` at PROBE level (general M, env) before any production edit — the mate witness pattern is `ExteriorFiberConsistencyK.lean:149` (`kvE_fiberElemConsistent_of_realized`): the characteristic of the dropped tuple, qnf-marked by realization, content-matching by construction. If (a) fails, fall back to (b)/synthesis; one loop max; then [BLOCKED] |
| Binder restatement propagates statement changes beyond `EndIntervalConsumerK.lean` — the binder types are verbatim copies from `ExteriorGateAssembleK.lean` (5 hslice sites) and are threaded in `KampPrior.lean` (3 sites) and referenced in `ExteriorPinnedConverse{,Past}K.lean` | H | H | Phase 1 maps every consumption/threading site (bounded read budget) and classifies statement-touching vs proof-script-only. Phase 4 confines statement changes to the mapped threading sites (`EndIntervalConsumerK`, `ExteriorGateAssembleK`, KampPrior threading) — any statement edit needed in a FROZEN file is a scope alarm: stop, restore snapshot, escalate |
| m=0 discharge breakage: the frozen `kvE_{fut,past}SliceId_of_end_zero` kernels discharge the OLD binder shape (`nfk_dropFresh sigma = qnf.1`); after restatement the m=0 discharge site must produce the NEW antecedent without editing the frozen kernels | H | M | The guard ships with a depth-inertness adapter (`kvE_deepOnFiber_zero`-style: at fiber depth 0 the hereditary arm is vacuous and the guard is equivalent to / implied by the depth-0 row check, `rfl`-cheap). The m=0 discharge is repaired proof-script-level through this byte-stable adapter — the same inertness pattern 363 used (`kvE_fiberConsistent_zero`) |
| Adapted plant: adversary manufactures sigma whose marked fibers' deep forms syntactically copy qnf's deep marking while sigma realizes over a fake tail | H | M | Phase 3 is a dedicated adversarial re-plant gate. Expected self-defeat channels: the 364 co-realization conjunct inside admissibility (copied content must still be jointly realizable), and hereditary recursion (copied content must be consistent all the way down). At most ONE redesign loop (churn cap); a second defeat exits [BLOCKED] with the refutation certificate as escalation payload |
| The analytical (Q, <) homogeneity family is not mechanized; a guard could pass all finite Z-casts yet still admit it | M | M | Phase 3 requires a written closure argument in the probe leaf docstring (why every fake-characteristic's marked deep fiber carries the fake coupling vector, never qnf-marked) + a mechanized finite proxy cast where feasible; the analytical family's dissolution is re-recorded in the Phase 6 handoff for task 358's re-key |
| Elaboration blow-up: `Finset.univ.toList` over `NormalForm` instances at concrete signature, one depth layer above 364's already-heavy probes | M | M | Reuse the landed mitigations: symbolic-membership routing (`kvE_nf_mem_univ_toList`), `set_option maxRecDepth 8000` precedent, `maxHeartbeats` bumps where already precedented, scoped `lake build` per module, `lean_multi_attempt` before edits |
| Frozen-layer drift | H | L | Phase 5 runs an explicit `git diff --name-only` audit; Phase 4 snapshots first (`git-snapshot.sh`); per-phase green commits enable exact rollback |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4 | 2, 3 |
| 4 | 5 | 4 |
| 5 | 6 | 5 |

Phases within the same wave can execute in parallel (Phases 2 and 3 both consume Phase 1's
adjudicated candidate and touch disjoint probe content).

---

### Phase 1: Baseline freeze, consumption-site map, candidate deep-anchor design (probe-only) [COMPLETED]

**Goal**: Choose and machine-validate the hereditary deep-anchor CANDIDATE in a NEW additive
probe leaf, without touching any production file. The candidate must exclude the
tail-doppelganger slice from the anchored population while remaining m=0-inert.

**Tasks**:
- [x] Baseline: scoped `lake build` of
      `Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.ExteriorPinnedProbe358TailK`
      and `...EndIntervalConsumerK` confirming green start; `lean_verify` spot-checks on
      `kvE_probe358_tailDG_gapItem_pinned_fails`, `kvE_probe358_tailDG_sigma_in_population`,
      `kvE_probe364_sigma2_inadmissible`, and `kvE_probe363_tau_admissible` (all floor axioms
      `[propext, Classical.choice, Quot.sound]`, no sorryAx). *(completed — all four at floor axioms)*
- [x] Consumption-site map (bounded read budget; record in the new leaf's module docstring) *(completed — recorded in leaf docstring; deviation: altered — the map adds `ExteriorBracketAssembleK.lean` as a statement-touching site beyond the plan's Phase-4 list: the rows-8-9 binder types are passed whole to D3/D4 (`ExteriorGateAssembleK:328/:344`) whose slice-unmarked branch applies `hslice` to arbitrary bracket-range σ, and the un-re-keyed bracket FORMULA is honestly unsatisfiable at m ≥ 1 (the fake σ's negative clause conjoins against its own firing chain), so the range filter, `_iff`, and D1-D4 must carry the guard)*:
      classify every `hsliceFut`/`hslicePast` site — `EndIntervalConsumerK.lean` (binder
      definitions :154-167 + `endInterval_step_correct` threading), `ExteriorGateAssembleK.lean`
      (verbatim binder copies / discharge consumption), `KampPrior.lean` (threading + the m=0
      discharge through `kvE_{fut,past}SliceId_of_end_zero`), `ExteriorPinnedConverse{,Past}K.lean`
      (kernel/docstring references) — as statement-touching vs proof-script-only. This map is
      Phase 4's authoritative edit boundary.
- [x] Create NEW additive probe leaf
      `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorFiberDeepAnchorProbe367K.lean`:
      replicate the private m3 cast from `ExteriorPinnedProbe358TailK.lean` (model `(Z, <)`,
      `R = {10}`, real `[35,5,2,30]`, fake `[40,12,8,25]`, walk `32`; established replication
      precedent for `private` originals) plus the real ambient
      `qnf367 := nf_characteristic M3M 3 3 m3realEnv3` (the `NormalForm sig (m+2) 3` shape at
      m = 1).
- [x] *(deviation: altered — landed as a synthesis: row check `&&` a qnf-marked deep-content mate `∃ σ', qnf.2 σ' ∧ σ'.2 = σ.2`; full `.2` equality is hereditary to depth 0 by construction and resolves Risk-2 bookkeeping without a deep slot-drop; fiber-depth-1 arm is the pure row check, giving `rfl` m=0 inertness)* Define candidate `kvE_deepOnFiberV0 (qnf) (sigma) : Bool` implementing candidate (a)
      hereditary fiber anchoring — sigma's marked fibers' one-slot-dropped DEEP forms must be
      matched in qnf's deep marking one level down, recursing to depth 0 (NOT a single extra
      level; see Risk 1). Resolve the depth/arity bookkeeping explicitly (Risk 2). Keep the
      depth-0/base arm literally trivial so inertness stays `rfl`-cheap. Document candidate (b)
      (direct binder-level deep on-fiber condition) as the in-file fallback with its trade-offs.
- [x] **Gate 1a (tail-doppelganger excluded)**: sorry-free certificate
      `kvE_probe367_tailDG_deep_rejected : kvE_deepOnFiberV0 qnf367 m3sigma367 = false` — the
      fake slice, though admissible (`kvE_futAdmissible = true` via the sanctioned realizer
      route) and depth-0 on-fiber, fails the deep anchor w.r.t. the real ambient.
- [x] **Gate 1b (m=0 inertness)**: `kvE_deepOnFiberV0_zero`-style lemma — at fiber depth 0 the
      hereditary arm is vacuous and the guard reduces to (or is directly implied by) the
      depth-0 row check, `rfl` or cheap — the guard rail that keeps the frozen m=0 discharge
      layer untouched in Phase 4.
- [x] Scoped `lake build` of the new leaf; `lean_verify` both gates (floor axioms); `git status`
      audit: the only tree change is the new leaf.

**Timing**: 2 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorFiberDeepAnchorProbe367K.lean` — NEW additive probe leaf (cast + candidate + gates 1a/1b + consumption-site map docstring)

**Verification**:
- Gates 1a/1b compile sorry-free at floor axioms; no production file touched; consumption-site
  map recorded.

---

### Phase 2: Honest-preservation crux at probe level [COMPLETED]

**Goal**: Prove, at probe level and in full generality (any model, any env), that honestly
realized slices over the ambient's own tail pass the deep anchor. This is the load-bearing
mathematics: without it, task 358's re-keyed G2 supply has no discharge route and the
restated rows 8-9 would be vacuously unservable.

**Tasks**:
- [x] Prove `kvE_deepOnFiberV0_of_realized` (the `kvE_fiberElemConsistent_of_realized:149` /
      `kvE_fiberConsistent_of_realized:238` template one layer down): if `qnf` is realized at
      `env3 = [w, x, t]` and `sigma` is realized at `Fin.cons x1 env3` (a pinned tuple sharing
      the ambient's tail), then `kvE_deepOnFiberV0 qnf sigma = true`. Expected witness pattern:
      for each sigma-marked fiber realized at a witness point, the characteristic of the
      dropped tuple is qnf-marked by qnf's realization and content-matching by construction
      (the `cons_cons_skipOne` bookkeeping pattern generalizes across the x1 slot). Induction
      on fiber depth carries the hereditary arm.
- [x] **Gate 2a (honest cast preservation)**: sorry-free concrete certificate
      `kvE_probe367_real_slice_deep_anchored` — the REAL slice
      (`nf_characteristic M3M 2 4 m3realEnv`) passes the guard w.r.t. `qnf367`, derived FROM
      the `_of_realized` lemma (not by concrete computation), uniformly where applicable.
- [x] **Gate 2b (supply-feasibility shape)**: certify the discharge route the re-keyed task-358
      supply will use: the guard for realizer-derived sigma is dischargeable through
      `_of_realized` alone (no guard unfolding anywhere in the leaf — source-scan discipline as
      in the 358Tail probe).
- [x] **Adjudication checkpoint** *(completed — hereditary marked-mate membership dischargeable: mate is sigma itself under realization; zero redesign loops consumed)*: if the hereditary marked-set membership is NOT dischargeable
      for the characteristic witnesses under candidate (a), switch to candidate (b)/synthesis
      and loop Phase 1's gates ONCE. If neither candidate closes gates 1a/1b AND this phase's
      preservation proof, STOP: mark task `[BLOCKED]`, write the structured escalation (what
      was tried, exact failing goal states, the countermodel or unprovable obligation),
      quarantine the leaf as a NO-GO record — no sorry, no vacuous def.

**Timing**: 2 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorFiberDeepAnchorProbe367K.lean` — preservation lemma + gate 2a/2b certificates

**Verification**:
- `kvE_deepOnFiberV0_of_realized` compiles sorry-free at general model/signature; gates 2a/2b
  green at floor axioms; scoped `lake build` of the leaf; zero guard-unfoldings (source scan).

---

### Phase 3: Adversarial re-plant probe (churn cap: ONE redesign loop) [COMPLETED]

**Goal**: Attempt to defeat the CANDIDATE the same way the 358 tail probe defeated the 364
interface — before promotion, not after. The refinement is only credible if the
next-layer-down attack provably fails.

**Tasks**:
- [x] **Depth-2 tail-doppelganger** (the mandatory hereditary test, Risk 1) *(completed — Gate 3a `kvE_probe367_depth2DG_deep_rejected`: fake tail [40,9,8,11], discrepancy = discrete gap (9,10) empty, visible only two fiber layers down; candidate SURVIVES, zero redesign loops)*: construct a fake
      tail whose coupling discrepancy with the real one is visible only at fiber depth 2
      (depth-0 AND depth-1 indistinguishable rows/couplings; e.g. a second marker point or a
      two-layer nesting of the R-point placement). Machine-adjudicate:
      - **Gate 3a (candidate survives)**: sorry-free certificate that the depth-2 fake slice
        fails `kvE_deepOnFiberV0` w.r.t. the real ambient (the hereditary recursion fires two
        levels down); OR
      - **Gate 3b (candidate defeated)**: a refutation certificate in the
        `kvE_probe358_tailDG_*` style. Then loop back to Phase 1 design ONCE (churn guard);
        a SECOND defeat exits `[BLOCKED]` with the refutation certificate as the escalation
        payload.
- [x] **Content-copying plant**: the strongest adapted attack *(completed — `kvE_probe367_copyPlant_collapses`: any admissible sigma* copying the real deep marking IS the real slice, via the byte-stable `kvE_futAdmissible_onFiber` extraction)* — a sigma realized over a fake
      tail whose marked fibers' deep forms are manufactured to BE qnf-marked forms (copying
      the ambient's deep marking payload). Machine-adjudicate self-defeat: the copy must
      survive sigma's own admissibility (the 364 co-realization conjunct: copied content must
      be jointly realizable with sigma) AND the hereditary arm (consistent all the way down).
      Certificate either excludes the adapted sigma or shows its construction impossible.
- [x] **Prior-family cross-check** *(completed — docstring argument: guard strictly shrinks population; admissibility untouched; 363/364/358 records byte-stable, re-verified Phase 5)*: confirm at probe level that the candidate does not reopen
      any previously-closed hole — the 363 m=1 fake (`s*` within `m1sigma`), the 364 plant
      (`m2sigma`/`m2sstar`), and the historical atom-row record
      (`kvE_probe358_eP_atomMate_present`) — via certificates or a docstring argument keyed to
      the unchanged frozen exclusion mechanisms (the guard is a NEW conjunct at the binder; it
      strictly shrinks the obligation population, so prior exclusions cannot be weakened —
      record the argument explicitly).
- [x] **Analytical-family closure record** *(completed — module docstring; the m3_noPinned chase is model-generic in shape; the Z casts are finite proxies)*: write the (Q, <) homogeneity dissolution argument
      into the leaf's module docstring (why every fake-characteristic's marked deep fiber
      carries the fake coupling vector at the discrepancy layer, hence is never qnf-marked),
      plus a mechanized finite proxy cast where feasible.

**Timing**: 2 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorFiberDeepAnchorProbe367K.lean` — adversarial section + gate 3 certificates + closure docstring

**Verification**:
- Gate 3a certificates compile sorry-free at floor axioms (or the documented single redesign
  loop has completed with gates 1a/1b/2a/2b/3a all green on the revised candidate);
  prior-family cross-check recorded.

---

### Phase 4: Production landing — new guard module + rows-8-9 restatement (snapshot first) [NOT STARTED]

**Goal**: The single production-touching phase. Promote the adjudicated guard into a NEW
additive production module and restate the rows-8-9 binders in place, keeping every frozen
name/signature byte-stable and repairing the mapped threading sites at proof-script level
only.

**Tasks**:
- [ ] Snapshot first: `bash .claude/scripts/git-snapshot.sh` before any production edit.
- [ ] Create NEW production module
      `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorFiberDeepAnchorK.lean`:
      promote the adjudicated guard verbatim from the probe leaf (`kvE_deepOnFiber` +
      `_zero` inertness/adapter + `_of_realized`), with a module docstring recording the
      consumption map, the tail-doppelganger it defeats, and the never-unfold routing rule
      (discharge ONLY via the byte-stable `_of_realized` / `_zero` adapter lemmas — never by
      unfolding `kvE_deepOnFiber`, `kvE_fiberElemConsistent`, or the admissibility predicates).
- [ ] Restate the rows-8-9 binders (`_hsliceFut`/`_hslicePast`,
      `EndIntervalConsumerK.lean:154-167`) per the adjudicated form: the depth-0 antecedent
      `nfk_dropFresh sigma = qnf.1` is replaced by (or strengthened with) the named
      `kvE_deepOnFiber qnf sigma = true` condition. Update the `endInterval_step_correct`
      threading in the same file. This binder restatement is the ONLY statement change of the
      task.
- [ ] Repair the mapped threading sites from Phase 1's consumption map ONLY:
      `ExteriorGateAssembleK.lean` (verbatim binder copies / discharge consumption — mechanical
      binder-type propagation) and `KampPrior.lean` (threading + the m=0 discharge site,
      repaired proof-script-level through the `_zero` inertness adapter so the frozen
      `kvE_{fut,past}SliceId_of_end_zero` kernels discharge the restated binder unchanged).
      **Scope alarm**: any statement edit needed in a frozen file
      (`ExteriorFiberConsistencyK/ProbeK/Probe364K`, `ExteriorPinnedConverse{,Past}K` kernels,
      task 360 m=0 supply, k<=1 rungs) or in any file outside the Phase-1 map — STOP, restore
      the snapshot, escalate; that indicates the candidate is not signature-stable and needs
      redesign, not forcing.
- [ ] Rewire `ExteriorFiberDeepAnchorProbe367K.lean` to certify against the PRODUCTION
      definition (drop or alias the V0 duplicate so exactly one live definition exists; retain
      the leaf as the permanent regression record, per the 363/364 probe-module precedent).
- [ ] Scoped `lake build` across the full consumer chain: `ExteriorFiberDeepAnchorK`,
      `EndIntervalConsumerK`, `ExteriorGateAssembleK`, `ExteriorNegationK`,
      `ExteriorNegationPastK`, `ExteriorPinnedConverseK`, `ExteriorPinnedConversePastK`,
      `ExteriorFiberConsistencyProbeK`, `ExteriorFiberConsistencyProbe364K`,
      `ExteriorPinnedProbe358K`, `ExteriorPinnedProbe358TailK`, `ExteriorPinnedProbeM1K`,
      `KampPrior`.

**Timing**: 2 hours

**Depends on**: 2, 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorFiberDeepAnchorK.lean` — NEW production guard module
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/EndIntervalConsumerK.lean` — rows-8-9 binder restatement (:154-167) + threading
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorGateAssembleK.lean` — mechanical binder-type propagation only (per Phase-1 map)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean` — threading + m=0 discharge adapter, proof-script level only (per Phase-1 map)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorFiberDeepAnchorProbe367K.lean` — rewire to production definition

**Verification**:
- Scoped `lake build` green across the whole chain; `git diff --stat` over `Theories/` shows
  exactly the files listed above; zero statement changes outside `EndIntervalConsumerK`'s
  binders and their mapped mechanical propagation; zero guard-unfoldings introduced.

---

### Phase 5: Full re-probe gate — the definition of done [NOT STARTED]

**Goal**: Machine-adjudicate the task's definition of done against the landed production
interface: tail-doppelganger excluded, all prior GO certificates green, frozen layers
byte-unchanged, zero debt.

**Tasks**:
- [ ] **Successor guard-level certificates** (production definitions): the Phase-1/2/3
      certificates restated against `kvE_deepOnFiber` —
      `kvE_probe367_tailDG_deep_rejected` (the fake slice is outside the restated rows-8-9
      obligation population), `kvE_probe367_real_slice_deep_anchored` (honest anchoring
      preserved), and the surviving adversarial gate 3 certificates — all sorry-free at floor
      axioms, zero guard-unfoldings.
- [ ] **358 tail-record supersession**: keep `kvE_probe358_tailDG_gapItem_pinned_fails` and
      `kvE_probe358_tailDG_sigma_in_population` compiling BYTE-STABLE as the permanent
      regression record (both remain true — the depth-0 facts hold; the population statement
      is about the OLD depth-0 anchor); add a docstring-only supersession note in
      `ExteriorPinnedProbe358TailK.lean` pointing at the task-367 successor certificates
      (statement bytes unchanged; the 364 precedent for the 358K docstring).
- [ ] **Prior GO re-verification**: `lean_verify` sweep at floor axioms, no sorryAx, over: all
      8 task-363 GO certificates (`ExteriorFiberConsistencyProbeK.lean`), the task-364 set
      (`kvE_probe364_sigma2_inadmissible`, `kvE_probe364_sstar_honest_unrealizable`, plant/
      honest/replant certs in `ExteriorFiberConsistencyProbe364K.lean`), the historical
      `kvE_probe358_eP_atomMate_present`, and the M1 residual records
      (`kvE_probeM1_interiorHreal_NOGO`, `kvE_probeM1_interiorGuard_identical`).
- [ ] **Frozen-layer diff audit**: `git diff --name-only` over the task's full change set
      confirms byte-unchanged: `ExteriorFiberConsistencyK.lean`,
      `ExteriorFiberConsistencyProbeK.lean`, `ExteriorFiberConsistencyProbe364K.lean`,
      `ExteriorNegationK.lean`, `ExteriorNegationPastK.lean`, the m=0 kernels in
      `ExteriorPinnedConverse{,Past}K.lean`, task 360's m=0 supply, and
      `kampPrior_case1_arm_k0` / k<=1 rungs. Change set is exactly Phase 4's file list plus
      the probe leaf and the 358TailK docstring.
- [ ] **Zero-debt audit**: full `lake build` green; repo-wide sorry count unchanged (exactly
      `KampPrior.lean:519`/`:522` — line numbers may shift; count and identity must not);
      no vacuous defs (`def _ := True`-class scan); `lean_verify` on every new/changed
      certificate; source scan confirms zero unfoldings of `kvE_deepOnFiber`,
      `kvE_fiberElemConsistent`, `kvE_futAdmissible`, `kvE_pastAdmissible` outside their home
      modules.

**Timing**: 1.5 hours

**Depends on**: 4

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorPinnedProbe358TailK.lean` — docstring-only supersession note
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorFiberDeepAnchorProbe367K.lean` — successor certificate finalization (if not completed in Phase 4 rewire)

**Verification**:
- Every listed certificate green at floor axioms; full `lake build` passes; frozen-file diff
  empty; sorry inventory = 2 (KampPrior only); vacuous-def scan clean.

---

### Phase 6: Wrap-up — summary, handoff, re-key notes for task 358 [NOT STARTED]

**Goal**: Land the documentation and orchestrator handoff so task 358 can be re-keyed
(`/revise 358`) against the refined interface.

**Tasks**:
- [ ] Write implementation summary
      `specs/367_deepanchor_exterior_fiber_population_against_taildoppelganger/summaries/01_deep-anchor-fiber-guard-summary.md`:
      which candidate landed ((a)/(b)/synthesis) and the exact final guard form; the full
      certificate inventory (gates 1a-5) with `lean_verify` axiom results; the adversarial
      re-plant outcome (including the depth-2 hereditary test); the consumption-site repair
      record; any plan deviations.
- [ ] Update `specs/367_deepanchor_exterior_fiber_population_against_taildoppelganger/.orchestrator-handoff.json`:
      final guard signature and chosen candidate (this dictates the witness term task 358's
      re-keyed G2 supply must construct — hereditary marked-characteristic membership vs
      direct deep condition), certificate list, files touched, frozen-audit result, and the
      explicit next action `/revise 358` (re-key Phase 2 against the refined rows-8-9
      interface) then `/implement 358`.
- [ ] Update plan phase statuses and `.return-meta.json`; per-green-milestone commits
      (`task 367 phase {P}: {name}`) should have landed at each phase; final
      `task 367: complete implementation`.

**Timing**: 0.5 hours

**Depends on**: 5

**Files to modify**:
- `specs/367_deepanchor_exterior_fiber_population_against_taildoppelganger/summaries/01_deep-anchor-fiber-guard-summary.md` — NEW
- `specs/367_deepanchor_exterior_fiber_population_against_taildoppelganger/.orchestrator-handoff.json` — update
- this plan file — status markers

**Verification**:
- Summary and handoff files exist, are non-empty, and the handoff JSON parses; plan statuses
  updated.

## Testing & Validation

- [ ] Gate 1a: `kvE_probe367_tailDG_deep_rejected` — tail-doppelganger slice fails the
      candidate deep anchor w.r.t. the real ambient (sorry-free, floor axioms)
- [ ] Gate 1b: m=0 inertness lemma (`rfl`-cheap) — frozen m=0 discharge layer guard rail
- [ ] Gate 2a/2b: `kvE_deepOnFiberV0_of_realized` in full generality + honest cast
      certificate derived from it; discharge route uses `_of_realized` only (zero
      guard-unfoldings)
- [ ] Gate 3: depth-2 hereditary doppelganger rejected; content-copying plant self-defeating;
      prior 363/364/358 families not reopened; analytical (Q, <) closure recorded; at most ONE
      redesign loop consumed
- [ ] Phase 4: scoped `lake build` green across the full consumer chain; statement changes
      confined to the rows-8-9 binders + mapped mechanical propagation; snapshot taken before
      edits
- [ ] Phase 5: successor certificates green against production definitions; ALL prior GO
      certificates re-verified at floor axioms (363's 8, 364's set, 358 records incl. both
      `kvE_probe358_tailDG_*` byte-stable, M1 residuals); frozen-layer diff empty; full
      `lake build`; sorry count = 2 (KampPrior :519/:522 only); vacuous-def scan clean
- [ ] Blocked-exit contract honored if any gate cannot close after the one redesign loop:
      `[BLOCKED]` + structured escalation record (handoff format), never
      sorry/vacuous-def/forced proof

## Artifacts & Outputs

- `plans/01_deep-anchor-fiber-guard.md` (this file)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorFiberDeepAnchorProbe367K.lean` (NEW probe leaf: cast replication, candidate adjudication, preservation crux, adversarial re-plant, permanent regression record)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorFiberDeepAnchorK.lean` (NEW production guard module: `kvE_deepOnFiber` + `_zero` adapter + `_of_realized`)
- Restated `EndIntervalConsumerK.lean` rows-8-9 binders (in place)
- Repaired threading in `ExteriorGateAssembleK.lean` / `KampPrior.lean` (per Phase-1 map)
- Docstring supersession note in `ExteriorPinnedProbe358TailK.lean` (statements byte-stable)
- `summaries/01_deep-anchor-fiber-guard-summary.md`
- `.orchestrator-handoff.json` (task-358 re-key handoff: final guard shape + `/revise 358` next action)

## Rollback/Contingency

- Phases 1-3 are purely additive (one new probe leaf, no production file touched): rollback =
  delete the leaf. A NO-GO adjudication at Phase 2/3 (after the one permitted redesign loop)
  converts the leaf into a quarantined NO-GO record and the task exits `[BLOCKED]` with a
  structured escalation — the escalation record must name the failing goal states or the
  defeating countermodel certificate, matching the phase-2-v05 handoff format.
- Phase 4 is the only production-touching phase. Snapshot first via
  `bash .claude/scripts/git-snapshot.sh`. If repair exceeds the Phase-1 consumption map (any
  statement edit in a frozen file, or any file outside the map), stop, restore the snapshot,
  and escalate — that indicates the candidate is not signature-stable and needs redesign, not
  forcing.
- Per-phase green commits (`task 367 phase {P}: ...`) ensure any failure resumes from the last
  green milestone; incomplete phase work is never committed.
- If Phase 5 uncovers a regression on any prior GO certificate that cannot be repaired at
  proof-script level, revert the Phase-4 commit(s) (production returns to the current
  interface — machine-refuted at m >= 1 but self-consistent and green) and exit `[BLOCKED]` —
  the frozen reference layer is never left broken.
