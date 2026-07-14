# Implementation Plan: Task #363 — Restate depth>=1 fiber-marking interface and re-probe G1/G2

- **Task**: 363 - restate_depth1_fibermarking_interface_and_reprobe_g1g2
- **Status**: [COMPLETED]
- **Effort**: 9 hours
- **Dependencies**: None (parent task 358 Phases 7-10 are downstream consumers)
- **Research Inputs**:
  - specs/363_restate_depth1_fibermarking_interface_and_reprobe_g1g2/reports/02_interface-restatement-plan-research.md (primary)
  - specs/363_restate_depth1_fibermarking_interface_and_reprobe_g1g2/reports/01_spawn-analysis.md
- **Artifacts**: plans/01_interface-restatement-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md, .claude/rules/lean4.md (zero sorry / zero vacuous def)
- **Type**: lean4
- **Lean Intent**: true

## Overview

The general-depth (m>=1) fiber-marking interface behind task 358's G1 (interior rows 5-6) and G2
(exterior rows 8-11) supply legs is machine-refuted FALSE by three sorry-free probes in
`Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorPinnedProbeM1K.lean`
(`kvE_probeM1_sliceId_NOGO`, `kvE_probeM1_interiorHreal_NOGO`,
`kvE_probeM1_interiorGuard_identical`). All three exploit one defect (D7): every fiber-marking
channel keys marked fibers only by depth-0 atom data or arity-1 fresh projection, so a
"doppelganger-tail" fake fiber `s*` — differing from the honest fiber only in the discarded
depth-1 inner marking — is interface-indistinguishable yet has no pinned realization.

This plan adopts research approach **(b)**: a decidable, m=0-inert, depth-graded
fiber-consistency guard (`kvE_futFiberConsistent`, working name), added (i) as a conjunct to
`kvE_futAdmissible`/`kvE_pastAdmissible` (exterior leg) and (ii) as an antecedent on the rows 5-6
interior obligations (interior leg). Approach (a) (refining `igFoldBit` / pinned item rendering)
is INFEASIBLE — `igFoldBit` (`InteriorGateGeneralK.lean:318`) is byte-frozen to the private
carrier `bracketEndChar_kv` via the `rfl` bridge `bracketEndChar_kv_succ_eq` and MUST NOT be
reopened. The interior fix therefore lives at the consumer/binder seam, one layer outside the
frozen gate.

**Definition of done**: re-run the EXISTING probes against the restated interface and confirm the
doppelganger countermodel no longer applies to either leg (a passing/GO result per §Testing) —
NOT merely a restated signature. Zero-debt terminus: no sorry, no vacuous def, no forcing a proof
against a live countermodel; if the guard cannot close green, the task ends [BLOCKED] with
structured escalation (Phase 6).

### Research Integration

Key findings from `02_interface-restatement-plan-research.md` integrated into this plan:
- D7 defect anatomy keyed to file:line (§1): the three fiber-marking channels (`nfk_dropFresh`,
  `nfk_zoneSpec`, `nfk_projFresh`) are all depth-0 or arity-1; `s*` evades all of them, and even
  full atom 5-types and all prefix takes of arity < 5 fail to separate fake from honest — the
  difference is purely in the depth-1 `.2` marking. The predicate MUST read the depth>=1 inner
  marking; no atom-layer or prefix-take refinement can work.
- Approach adjudication (§2): (b) recommended; (a) not standalone-implementable
  (model-dependent + frozen `igFoldBit`).
- Frozen-boundary map (§3) — reproduced below as an explicit constraint section.
- Re-probe protocol (§4) — adopted as the Phase 5 DoD and Testing bar.
- Proposed 4-phase skeleton (§5) — adopted and refined into 5 phases + conditional fallback:
  the exterior leg is split into future (Phase 2) and past-mirror + chain rebuild (Phase 3) to
  keep each phase within one agent run.
- Task-358 dovetail (§6) — recorded below.

### Prior Plan Reference

No prior plan (this is plan v1 for task 363).

### Roadmap Alignment

No roadmap context provided for this dispatch. Parent-task linkage: unblocks task 358 Phases 7-10
(see "Task-358 Dovetail" below).

## Goals & Non-Goals

**Goals**:
- Define a decidable, model-independent, depth-recursive fiber-consistency predicate
  (`kvE_futFiberConsistent` + past mirror) that reads the depth>=1 inner marking, rejects the
  doppelganger `s*`/`m1sigma`, accepts all honest probe fibers, and is trivially true at depth 0.
- Machine-validate the predicate on the existing m=1 cast BEFORE any production edit
  (task-360 "probe before landing" precedent) — Phase 1 is a hard GO/NO-GO gate.
- Exterior leg (G2): strengthen `kvE_futAdmissible` (`ExteriorNegationK.lean:86`) and
  `kvE_pastAdmissible` (`ExteriorNegationPastK.lean:152`) with the new conjunct; re-prove
  `kvE_futRealizer_admissible` (+ past mirror) so honest realizers stay admissible; rebuild the
  exterior chain green.
- Interior leg (G1): add the consistency predicate as an antecedent on the rows 5-6
  `_hreal`/`_hexcl` obligations (`EndIntervalConsumerK.lean:119-130` and the mirrored KampPrior
  supply shape); `igFoldBit` untouched.
- Re-probe DoD: prove sorry-free that (1) `kvE_futAdmissible m1sigma = false`, (2) every honest
  probe fiber remains admissible, (3) the restated interior antecedent fails at
  `(qnfG1, m1sigma)`, (4) the m=0 supply certificates still build unchanged. Full `lake build`
  green, zero new sorry/axioms in touched declarations.
- Record the final predicate signature (conjunct shape + interior antecedent shape) in the
  implementation summary so task 358's planner can key Phases 7-8 to it.

**Non-Goals**:
- Do NOT build the general-m/general-depth supply theorems (G1/G2 discharge) — that remains task
  358 Phases 7-8, downstream of this restatement.
- Do NOT touch, re-signature, or reopen any frozen declaration (see Frozen-Boundary Constraints).
- Do NOT redefine `igFoldBit` or any pinned item rendering (approach (a) is adjudicated
  infeasible; it survives only as escalation framing).
- Do NOT land debt: no sorry, no vacuous def, no proof forced against a live countermodel.

## Frozen-Boundary Constraints (MUST NOT touch or reopen)

| Declaration | Location | Why frozen |
|-------------|----------|-----------|
| `igFoldBit` | `InteriorGateGeneralK.lean:318` | byte-for-byte pinned to frozen carrier via `bracketEndChar_kv_succ_eq` rfl bridge |
| `bracketEndChar_kv_succ_eq`, `igBody`, `igOffFiber`, `igFoldBit_iff`, `bracketEndChar_kv_succ_holds_iff` | `InteriorGateGeneralK.lean:286-413` | defeq bridge to frozen private `kv_body` |
| `bracketEndChar_kv` (private carrier) | `CarrierKv.lean` | frozen production carrier |
| `kampPrior_site_rung0_match` (k=0), `kampPrior_site_rung1_match` (k=1) | `KampPrior.lean:830-874` | unconditional k<=1 rungs, unrefuted |
| `bracketEndChar_kv_correct_zero_prior`, `bracketEndChar_kv_correct_one_prior` | (imported) | k=0/k=1 correctness |
| `kampPrior_case1_arm_k0` | KampPrior (k=0 arm) | frozen, unrefuted |
| `kvE_hsliceFut_supply_zero` | `ExteriorPinnedConverseK.lean:1301` | task-360 m=0 supply, landed |
| `kvE_hexclSliceFut_supply_zero` | `ExteriorPinnedConverseK.lean:1242` | task-360 m=0 supply, landed |
| `kvE_futSliceId_of_end_zero` / past mirror, `kvE_futSliceUnique_zero` | ExteriorPinnedConverseK / PastK | task-360 m=0 kernels |
| `kvE_fiberZoneList`, `kvE_fiber`, `kvE_minPick`, `nfk_take`, `nfk_projFresh`, `nfk_dropFresh`, `nfk_zoneSpec`, `nf0_zoneSpec` | ExteriorFiberK / CarrierKv / NfEFold | shared infra consumed by frozen k=0/k=1; do NOT re-signature (NEW helpers alongside are allowed) |

**Guard rails**:
- The k=0 and k=1 layers are unconditional and unrefuted. The new conjunct/antecedent MUST be
  **inert at k=0 (m=0)**: design the predicate trivially true at depth 0 (where fibers have no
  depth>=1 inner marking), so the m=0 supply theorems continue to type and prove unchanged.
- `InteriorGateGeneralK.lean` MUST be diff-verified unmodified at the end of Phase 4 (the
  `bracketEndChar_kv_succ_eq` rfl bridge must still hold).
- Frozen declarations may be *consumed* (imported, referenced) but never edited, re-signatured,
  or shadowed.

**In-scope to modify / add** (from research §3.2):

| Target | Location | Change |
|--------|----------|--------|
| `kvE_futAdmissible` | `ExteriorNegationK.lean:86` | add depth-graded conjunct |
| `kvE_pastAdmissible` | `ExteriorNegationPastK.lean:152` | add mirror conjunct |
| `kvE_futRealizer_admissible` (+ past) | `ExteriorNegationK.lean:124` | re-prove with new conjunct |
| rows 5-6 interior obligations `_hreal`/`_hexcl` | `EndIntervalConsumerK.lean:119-130`; mirrored KampPrior supply shape | add consistency antecedent |
| exterior binders rows 8-11 (`_hsliceFut`/`_hexclSliceFut` etc.) | `EndIntervalConsumerK.lean:141-168` | re-statement only if needed to thread strengthened admissibility |
| NEW predicate `kvE_futFiberConsistent` (+ past) | new leaf or ExteriorFiberK/Negation sibling | the depth-graded guard itself |
| `ExteriorPinnedProbeM1K.lean` | probe leaf (no file imports it — verified) | re-probe target; safe to edit; sibling probe module also allowed |

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Predicate inadequate at m>=2 (hardcoded m=1 check instead of depth-recursive) | H | M | Phase 1 probes the *recursive* definition on the m=1 cast; predicate must be depth-graded by construction, not cast-specific |
| New conjunct too strong: breaks `kvE_futRealizer_admissible` (honest realizers rejected) | H | M | Phase 1 GO gate proves honest fibers pass BEFORE any production edit; Phase 2 re-proves the realizer lemma as its own green milestone |
| m=0 non-inertness: frozen task-360 m=0 supply breaks | H | L | Predicate defined trivially true at depth 0; Phase 3 explicitly rebuilds and diff-checks `kvE_hsliceFut_supply_zero` / `kvE_hexclSliceFut_supply_zero` |
| Frozen `igFoldBit` wall: interior antecedent undischargeable by 358 Phase 8 (fix merely relocates the obstruction) | M | M | Phase 1 includes a feasibility check that honest ambients satisfy the antecedent (i.e. 358's supply population is non-trivial); escalate via Phase 6 if not |
| Past/future asymmetry drift | M | M | Every exterior change lands with its past mirror in the same phase (Phase 3 owns the past leg + lockstep check) |
| Downstream chain breakage (ExteriorFiberK -> ... -> KampPrior) from admissibility change | M | M | Scoped `lake build` per module in Phases 2-4; full-chain build in Phase 5; commit at every green milestone |
| Neither approach closes green | H | L-M | Phase 6 [BLOCKED] escalation with structured obstruction report; no debt landed |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |
| (conditional) | 6 | NO-GO in 1 or failure in 5 |

Phases are fully sequential: Phase 1 is the GO/NO-GO gate for all production edits; Phases 3 and
4 both edit `EndIntervalConsumerK.lean` (rows 8-11 vs rows 5-6) and are serialized to avoid
churn. Phase 6 executes ONLY on a NO-GO/failure verdict and replaces Phases 2-5 or 5's wrap-up.

---

### Phase 1: Design and machine-probe the depth-graded predicate (GO/NO-GO gate) [COMPLETED]

**VERDICT: GO.** Predicate pair `kvE_fiberElemConsistent` (per-fiber, depth-recursive,
mergeNF-at-slot-1 atom-mate check + recursion into the fiber) and `kvE_fiberConsistent`
(σ-level) landed in `ExteriorFiberConsistencyProbeK.lean`. All six GO certificates sorry-free
(axioms: propext, Classical.choice, Quot.sound). *(deviation: altered — the "past mirror" is
realized as the SAME direction-agnostic predicate, since the consistency notion never reads
anchor order; the relational `(qnf, σ)` form collapsed to the σ-internal form
`kvE_fiberConsistent σ`, which both legs consume.)*

**Goal**: A candidate `kvE_futFiberConsistent` — decidable, model-independent, depth-recursive,
trivially true at depth 0 — machine-validated on the existing m=1 cast in a NON-production
module, separating fake from honest on both legs. No production file is touched in this phase.

**Tasks**:
- [x] Read the probe cast (`ExteriorPinnedProbeM1K.lean`: `s*` at :100-101, honest `s°` at
      :738-739, `m1_sstar_not_pinned` at :133-225, `m1sigma`/`qnfG1` at :813-814) and the three
      channel definitions (`NfEFold.lean:578,586,153`; `CarrierKv.lean:73-82`) to fix the exact
      inner-marking data the predicate must read.
- [x] Define candidate `kvE_futFiberConsistent` (and its past-mirror shape) in a new
      non-production probe/sibling module (e.g. `ExteriorFiberConsistencyProbeK.lean` next to the
      existing probe leaf): decidable (`NormalForm ... -> Bool` or `DecidablePred`),
      depth-recursive over the `.2` inner marking, inert (constant `true`) at depth 0.
- [x] Prove on the m=1 cast: `kvE_futFiberConsistent ... m1sigma = false` (equivalently for
      `s*`) — the fake is rejected via the relational inconsistency of its depth-1 marks
      (`e_b`/`e_c` re-anchored to the honest tail demand impossible points).
- [x] Prove on the m=1 cast: `kvE_futFiberConsistent ... = true` for every honest probe fiber —
      the gap fibers `nf_characteristic M1M 1 5 (Fin.cons r m1env4)` for `r ∈ (18,25)` and the
      self/ray witnesses.
- [x] Feasibility check (interior seam): confirm the honest ambient `m1qnf`'s marked fibers all
      satisfy the predicate, i.e. the interior antecedent restricts to a population task 358's
      Phase 8 can actually supply (not empty, not fake-inclusive).
- [x] Record the GO/NO-GO verdict + final predicate signature in the phase commit message and a
      short note block in the probe module docstring.

**Timing**: 2 hours

**Depends on**: none

**Files to modify**:
- NEW: `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorFiberConsistencyProbeK.lean` (or equivalently named sibling probe leaf) — predicate candidate + m=1 cast certificates

**Verification**:
- Scoped `lake build` of the new probe module green; zero sorry (`lean_verify` /
  `#print axioms` on each certificate).
- GO gate: predicate separates fake from honest on BOTH the exterior `s*` cast and the interior
  `qnfG1` cast, decidably and model-independently.
- **If NO-GO**: skip Phases 2-5, execute Phase 6 immediately. No production edit is made.

---

### Phase 2: Land the exterior conjunct (future leg) and re-prove realizer admissibility [COMPLETED]

Production home: `ExteriorFiberConsistencyK.lean` (predicate pair + inertness lemmas +
realized lemmas + symbolic membership helper). Conjunct placed INSIDE `kvE_futAdmissible`
conjunct 2's body — `(decide (nfk_dropFresh s = σ.1) && kvE_fiberElemConsistent σ s) || !(σ.2 s)`
— NOT as a fifth top-level `&&`. *(deviation: altered — plan said "add the conjunct ...
preserving the existing four conjuncts' shape"; in-body placement is the only shape that keeps
the FROZEN m=0 supply proofs (which destructure the 4-conjunct chain via `hh.1.1.1`/`hadm'.2`
and 3x `Bool.and_eq_true`) byte-identical.)* `kvE_futRealizer_admissible` re-proved green
(axioms clean); probe module rewired to consume production defs.

**Goal**: `kvE_futAdmissible` strengthened with the Phase-1 predicate as a new conjunct; the
load-bearing correctness obligation `kvE_futRealizer_admissible` re-proved green (honest
realizers remain admissible); the predicate promoted from probe module to a production home.

**Tasks**:
- [x] Promote `kvE_futFiberConsistent` (exact Phase-1 signature) into a production module (new
      leaf or sibling within the ExteriorFiberK/ExteriorNegationK neighborhood — do NOT
      re-signature any frozen shared-infra declaration; add alongside).
- [x] Add the conjunct to `kvE_futAdmissible` (`ExteriorNegationK.lean:86-98`), preserving the
      existing four conjuncts' shape so downstream destructuring proofs repair minimally.
- [x] Re-prove `kvE_futRealizer_admissible` (`ExteriorNegationK.lean:124-...`): every honest
      realizer satisfies the new conjunct (uses the Phase-1 honest-preservation certificates'
      proof pattern, generalized off the m=1 cast).
- [x] Repair any other in-module consumers of `kvE_futAdmissible` within `ExteriorNegationK.lean`. *(none needed — remaining in-module uses are opaque)*
- [x] Commit at green (`task 363 phase 2: ...`).

**Timing**: 2 hours

**Depends on**: 1

**Files to modify**:
- NEW production home for `kvE_futFiberConsistent` (+ past-mirror declaration stub may land here too)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorNegationK.lean` — conjunct + realizer re-proof

**Verification**:
- Scoped `lake build` of the predicate module + `ExteriorNegationK.lean` green; zero sorry in
  touched declarations.
- `kvE_futRealizer_admissible` proved (not vacuous, not sorry'd) — this is the phase's green
  milestone.

---

### Phase 3: Past mirror + exterior chain rebuild + m=0 inertness check [COMPLETED]

Past mirror landed (same direction-agnostic guard inside `kvE_pastAdmissible` conjunct 2;
`kvE_pastRealizer_admissible` re-proved). Chain repairs: `kvE_futAdmissible_fiber_dichotomy` /
past mirror (conjunct-2 read), `kvE_futAdmissible_of_subMarking` (+ `hcons` hypothesis —
consistency is not monotone under mark-erasure; k=0 consumer supplies
`kvE_fiberElemConsistent_zero`). ExteriorPinnedConverseK/PastK frozen m=0 kernels
diff-verified byte-unchanged; full `lake build` green; leaf probes: ExteriorPinnedProbeK and
ExteriorFiberProbeK green; ExteriorPinnedProbeM1K red AS EXPECTED (its `m1_sigma_adm`
hypothesis-side assembly is now unprovable — the countermodel dissolved; rewritten in
Phase 5).

**Goal**: The past leg in lockstep (`kvE_pastAdmissible` + past realizer re-proof), the full
exterior consumer chain rebuilt green through `EndIntervalConsumerK`, and the frozen m=0 supply
certificates verified byte-unchanged.

**Tasks**:
- [x] Add the mirror conjunct to `kvE_pastAdmissible` (`ExteriorNegationPastK.lean:152`) and
      re-prove the past realizer-admissibility lemma (mirror of Phase 2).
- [x] Rebuild and repair the exterior chain in import order: ExteriorFiberK ->
      ExteriorPinnedConverseK / ExteriorPinnedConversePastK -> ExteriorBracketAssembleK ->
      ExteriorGateAssembleK -> EndIntervalConsumerK (rows 8-11 binders
      `_hsliceFut`/`_hexclSliceFut`, `EndIntervalConsumerK.lean:141-168`: re-state ONLY if needed
      to thread the strengthened admissibility; keep the restatement minimal and record it).
- [x] Verify m=0 inertness: `kvE_hsliceFut_supply_zero` (`ExteriorPinnedConverseK.lean:1301`),
      `kvE_hexclSliceFut_supply_zero` (`:1242`), `kvE_futSliceId_of_end_zero` (+ past mirror),
      `kvE_futSliceUnique_zero` all still build with UNCHANGED statements and proofs (git diff
      confirms no edit to these declarations).
- [x] Diff-check: no frozen declaration from the Frozen-Boundary table was modified.
- [x] Commit at green (`task 363 phase 3: ...`).

**Timing**: 2 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorNegationPastK.lean`
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorFiberK.lean` (repair only, no re-signature of frozen infra)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorPinnedConverseK.lean` / `ExteriorPinnedConversePastK.lean` (repair only; m=0 kernels untouched)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorBracketAssembleK.lean`, `ExteriorGateAssembleK.lean` (repair as needed)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/EndIntervalConsumerK.lean` (rows 8-11 only, if threading requires)

**Verification**:
- Scoped `lake build` green through `EndIntervalConsumerK` and `KampPrior` (consumers compile).
- m=0 supply theorems build unchanged (statement + proof diff-verified).
- Zero sorry in all touched declarations; past/future conjuncts structurally mirrored.

---

### Phase 4: Land the interior antecedent on rows 5-6 [COMPLETED]

Restated shape: NEW binder `_hfiberCons : ∀ σ, qnf.2 σ = true → kvE_fiberConsistent σ = true`
(population antecedent) PLUS per-σ antecedent `kvE_fiberConsistent σ = true →` threaded into
`_hreal` and `_hexcl`, in both `EndIntervalCorrectPrior` (m+2 arm) and
`kampPrior_site_rungK_gate_match`. `endInterval_step_correct` / the gate-match proof
reconstruct the unrestricted obligations for the UNCHANGED downstream
`bracketEndChar_kvExt_correct_prior` (hreal: modus ponens with hfiberCons; hexcl: case split —
an inconsistent σ has no realization by `kvE_fiberConsistent_of_realized`). *(deviation:
altered — the plan's single "antecedent on rows 5-6" is realized as the antecedent PAIR
(qnf-level binder + per-σ antecedent); the qnf-level binder is what lets the consumer
reconstruct the frozen downstream interface without touching it.)*

**Goal**: The consistency predicate added as an ANTECEDENT on the interior rows 5-6
`_hreal`/`_hexcl` obligations — restricting the marked-fiber population the (future, task-358)
supply must cover — with `igFoldBit` and the entire `InteriorGateGeneralK.lean` file untouched.

**Tasks**:
- [x] Add the consistency antecedent to the rows 5-6 obligations
      (`EndIntervalConsumerK.lean:119-130` `_hreal`/`_hexcl`), shaped as: "for every marked
      `σ` of the ambient qnf, `kvE_futFiberConsistent qnf σ`" (exact Phase-1/2 signature).
- [x] Mirror the antecedent into the corresponding KampPrior supply shape (the rows 5-6 binder
      shape referenced at `KampPrior.lean:835-846` — read/reference the binder; edit only the
      obligation statements this task owns, NOT the frozen k<=1 rungs at :830-874).
- [x] Repair downstream consumers of the restated obligations so `KampPrior.lean` +
      `EndIntervalConsumerK.lean` build green.
- [x] Diff-check: `InteriorGateGeneralK.lean` is byte-unmodified; the
      `bracketEndChar_kv_succ_eq` rfl bridge still elaborates (build of the file's consumers
      passes with no edit to the file itself).
- [x] Commit at green (`task 363 phase 4: ...`).

**Timing**: 1.5 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/EndIntervalConsumerK.lean` (rows 5-6)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean` (rows 5-6 obligation/supply shape ONLY; k<=1 rungs and `kampPrior_case1_arm_k0` untouched)

**Verification**:
- `lake build` of `KampPrior.lean` + `EndIntervalConsumerK.lean` green; zero sorry in touched
  declarations.
- `git diff --stat` shows NO change to `InteriorGateGeneralK.lean`, `CarrierKv.lean`, or any
  frozen k=0/k=1 declaration.

---

### Phase 5: Re-probe (DoD) and wrap-up [COMPLETED]

All four DoD GO certificates sorry-free: (1) `kvE_probe363_sigma_inadmissible`
(`kvE_futAdmissible m1sigma = false`); (2) `kvE_probe363_tau_admissible` + per-fiber honest
certificates; (3) `kvE_probe363_qnfG1_antecedent_fails` (+ `kvE_probe363_fake_slice_inconsistent`);
(4) m=0 certificates byte-unchanged. Old NOGO disposition: `kvE_probeM1_sliceId_NOGO` +
`m1_sigma_adm` RETIRED (git history; replaced by `kvE_probeM1_sliceId_superseded`);
`kvE_probeM1_interiorHreal_NOGO` / `kvE_probeM1_interiorGuard_identical` RETAINED with
superseded/expected-residual docstrings. Full `lake build` + all leaf probes green; axioms
clean. *(deviation: altered — the re-probe certificates live in
`ExteriorFiberConsistencyProbeK` (owner of the private m=1 cast) rather than inside
`ExteriorPinnedProbeM1K`.)*

**Goal**: The Definition of Done — sorry-free machine confirmation, against the restated
production definitions, that the doppelganger countermodel no longer applies to either leg;
full `lake build` green; predicate signature recorded for task 358.

**Tasks**:
- [x] Exterior leg (G2): in `ExteriorPinnedProbeM1K.lean` (leaf, safe to edit) or a sibling
      re-probe module, prove `kvE_futAdmissible m1sigma = false` (equivalently: the old
      `m1_sigma_adm` assembly is now unprovable / the fake fails the new conjunct), making
      `kvE_probeM1_sliceId_NOGO` non-instantiable against the restated interface.
- [x] Exterior honest-preservation: prove every honest probe fiber (gap fibers for
      `r ∈ (18,25)`, self/ray witnesses) still satisfies the strengthened `kvE_futAdmissible`
      (i.e. `kvE_futRealizer_admissible` fires on the cast).
- [x] Interior leg (G1): prove `¬ kvE_futFiberConsistent m1qnfG1 m1sigma` at production
      signature — the restated rows 5-6 hypothesis side (guard AND consistency antecedent) is
      unsatisfiable at `qnfG1`, dissolving `kvE_probeM1_interiorHreal_NOGO`.
- [x] Document the expected residual: `kvE_probeM1_interiorGuard_identical`
      (`igFoldBit qnfG1 = igFoldBit m1qnf`) REMAINS TRUE — `igFoldBit` is frozen and unchanged;
      the separation happens at the new antecedent one layer out. Record this explicitly in the
      probe module so it is not misread as a regression.
- [x] Reconcile the old NO-GO theorems: either retire/re-express them against the restated
      interface (leaf file, no importers) or retain them with a docstring marking them as
      certificates against the SUPERSEDED interface — no dangling refutation of live production
      statements may remain.
- [x] Confirm m=0 certificates unchanged one final time; run FULL `lake build` (whole project)
      green.
- [x] Run `lean_verify` / `#print axioms` on: the predicate, both admissibility definitions'
      key consumers (`kvE_futRealizer_admissible` + past), the restated rows 5-6 obligations'
      consumers, and all new probe certificates — zero sorry, zero new axioms.
- [x] Write the implementation summary including the **final predicate signature** (exterior
      conjunct shape + interior antecedent shape) as the explicit contract for task 358's
      Phases 7-8 re-keying.
- [x] Commit (`task 363 phase 5: ...` then `task 363: complete implementation`).

**Timing**: 1.5 hours

**Depends on**: 4

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorPinnedProbeM1K.lean` (and/or a sibling re-probe module)
- `specs/363_restate_depth1_fibermarking_interface_and_reprobe_g1g2/summaries/01_interface-restatement-summary.md` (new)

**Verification** (the four GO certificates, all sorry-free):
1. `kvE_futAdmissible m1sigma = false` — exterior fake excluded.
2. Every honest probe fiber still admissible — honest population preserved.
3. Restated interior antecedent fails at `(qnfG1, m1sigma)` — interior fake excluded.
4. m=0 layer certificates (`kvE_hsliceFut_supply_zero` etc.) build unchanged.
Plus: full `lake build` green; zero new sorry/axioms in touched declarations.
- **If any certificate cannot be closed green**: do NOT force it; execute Phase 6.

---

### Phase 6 (conditional fallback): [BLOCKED] escalation [NOT STARTED]

**Goal**: Structured, debt-free termination if Phase 1 returns NO-GO or Phase 5's certificates
cannot close green. This phase replaces the remaining phases; it never coexists with a GO
wrap-up.

**Tasks**:
- [ ] Roll back or quarantine any incomplete production edits so the build is green with NO
      sorry and NO vacuous def (snapshot first via `bash .claude/scripts/git-snapshot.sh` if any
      working-tree rollback is needed; committed green phases may stand if they are
      independently sound, otherwise revert to the pre-task state).
- [ ] Write the escalation report (`reports/03_blocked-escalation.md`) containing:
      the exact predicate candidate(s) tried (full Lean statements); the goal states reached;
      which arm failed — fake-exclusion (`s*` not rejected) or honest-preservation
      (`kvE_futRealizer_admissible` broken) or interior-antecedent dischargeability (358
      Phase 8's population empty/undischargeable); and the obstruction classification:
      model-dependence (pure approach (a) needed — pinned realization not decidable from the
      qnf) vs frozen-`igFoldBit` wall (needed data withheld by the frozen gate with no
      consumer-seam antecedent available).
- [ ] Update task status to [BLOCKED] with the escalation report linked; note in the handoff
      that task 358 remains blocked and a design-level decision (e.g. unfreezing policy or a new
      carrier generation) is required upstream.
- [ ] Commit the escalation artifacts.

**Timing**: 1 hour (only if triggered)

**Depends on**: triggered by NO-GO in Phase 1 or red certificates in Phase 5

**Files to modify**:
- `specs/363_restate_depth1_fibermarking_interface_and_reprobe_g1g2/reports/03_blocked-escalation.md` (new)
- Production files: rollback/quarantine only, per recovery ladder (`.claude/context/contracts/recovery.md`)

**Verification**:
- Repository builds green with zero sorry and zero vacuous defs (no debt landed).
- Escalation report contains all four required elements (candidates tried, goal states, failed
  arm, obstruction classification).

## Testing & Validation

- [x] Phase-1 GO gate: predicate rejects `m1sigma`/`s*` AND accepts all honest m=1 probe fibers,
      in a non-production module, before any production edit.
- [x] `kvE_futRealizer_admissible` (+ past mirror) re-proved sorry-free against the strengthened
      admissibility — the load-bearing honest-preservation obligation.
- [x] m=0 inertness: `kvE_hsliceFut_supply_zero`, `kvE_hexclSliceFut_supply_zero`,
      `kvE_futSliceId_of_end_zero` (+ past), `kvE_futSliceUnique_zero` build with unchanged
      statements/proofs (git diff-verified) after Phases 3-5.
- [x] Frozen-boundary audit: `git diff` shows no modification to `InteriorGateGeneralK.lean`,
      `CarrierKv.lean` frozen carrier, `KampPrior.lean:830-874` rungs, or `kampPrior_case1_arm_k0`.
- [x] Re-probe DoD (the four GO certificates of Phase 5), all sorry-free.
- [x] Expected residual documented: `igFoldBit qnfG1 = igFoldBit m1qnf` remains true (frozen
      gate) — separation happens at the new antecedent; explicitly NOT a regression.
- [x] Full `lake build` green at land time; `lean_verify` / `#print axioms` clean (zero sorry,
      zero new axioms) on every touched/new declaration.
- [x] Implementation summary records the final predicate signature (task-358 contract).

## Task-358 Dovetail (what lands downstream)

Once 363 lands GO, task 358 resumes at `/implement 358` Phase 7:
- **G2 (exterior rows 8-11, 358 Phase 7)**: with `s*`-class fakes excluded from
  `kvE_futAdmissible`, every admissible σ is pinned-consistent, so the slice-identification
  conclusion ("exists admissible slice-equal qnf-marked mate") becomes TRUE;
  `kvE_probeM1_sliceId_NOGO` no longer refutes it. Phase 7's slice-identification/uniqueness
  kernels (R3) re-key to the strengthened admissibility.
- **G1 (interior rows 5-6, 358 Phase 8)**: with the consistency antecedent, the supply need only
  cover pinned-consistent marked σ; the fake `qnfG1` is outside the population, so `hreal`
  becomes provable; `kvE_probeM1_interiorHreal_NOGO` no longer refutes it.
- **358 Phases 9-10** (arm rewrite retiring `KampPrior.lean:361`; :364 arity lift) proceed
  unchanged from 358 plan v3 once Phases 7-8 land.
- **Contract**: the exact predicate signature recorded in this task's summary (Phase 5)
  determines how 358's Phase 7/8 obligations are stated — a genuine implementation-detail
  dependency, not merely ordering.

## Artifacts & Outputs

- plans/01_interface-restatement-plan.md (this file)
- NEW Lean probe module (Phase 1): `ExteriorFiberConsistencyProbeK.lean` (or sibling name)
- NEW Lean production module (Phase 2): production home of `kvE_futFiberConsistent` (+ past)
- Modified: `ExteriorNegationK.lean`, `ExteriorNegationPastK.lean`, exterior chain repairs,
  `EndIntervalConsumerK.lean`, `KampPrior.lean` (rows 5-6 shape only),
  `ExteriorPinnedProbeM1K.lean` (re-probe)
- summaries/01_interface-restatement-summary.md (Phase 5; includes final predicate signature)
- On NO-GO only: reports/03_blocked-escalation.md (Phase 6)

## Rollback/Contingency

- Every phase commits only at green (commit-per-green-substep mandate); a failed phase never
  lands partial edits — fix forward within the phase or roll back the working tree via
  `git-snapshot.sh` + snapshot-then-rollback (recovery ladder), never leaving sorry/vacuous defs.
- Phase 1 is deliberately non-production: a NO-GO verdict costs zero production churn.
- If Phases 2-4 land green but Phase 5 certificates fail, Phase 6 decides per-commit whether the
  landed strengthening is independently sound (may stand: a strictly stronger admissibility with
  proved realizer lemma is not debt) or must be reverted to the pre-task commit
  (`git revert` of the task's phase commits) — the deciding bar is: no production statement may
  remain that the live countermodel refutes and no obligation may remain vacuously true.
- The three original NO-GO probe theorems are preserved in git history regardless of outcome;
  they are the permanent regression tests for any future interface change.
