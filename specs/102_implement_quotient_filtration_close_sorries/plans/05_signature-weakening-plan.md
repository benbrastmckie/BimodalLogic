# Implementation Plan: Weaken Frame.lean Sorry Signatures to Chain-Member Quantification (v4)

- **Task**: 102 - implement_quotient_filtration_close_sorries
- **Status**: [NOT STARTED]
- **Effort**: 16 hours
- **Dependencies**: None
- **Research Inputs**:
  - specs/102_implement_quotient_filtration_close_sorries/reports/05_team-research.md
  - specs/102_implement_quotient_filtration_close_sorries/reports/05_teammate-c-findings.md
  - specs/102_implement_quotient_filtration_close_sorries/reports/05_teammate-b-findings.md
  - specs/102_implement_quotient_filtration_close_sorries/reports/05_teammate-a-findings.md
- **Artifacts**: plans/05_signature-weakening-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Close all 4 Frame.lean sorries by weakening their signatures from universal quantification over all BXPoints in a `bx_le` interval to quantification over chain members only. The round 5 team research established consensus (80% confidence) that the current signatures are unprovable because `bx_le` (g_content subset inclusion) is a non-total preorder admitting "junk points" from unrelated Lindenbaum extensions. Alternative A from the Critic (Teammate C) fixes the root cause: the signatures conflate information-theoretic ordering with positional ordering. The weakened signatures match what the TruthLemma actually needs -- guard properties at chain positions, not arbitrary BXPoints. The 6 Realization.lean and 4 CanonicalChain.lean sorries are pure delegation to Frame.lean and resolve automatically. Definition of done: all 4 Frame.lean sorries closed, all downstream delegations compile, `lake build` clean, no new axioms.

### Research Integration

Reports integrated in this plan version:
- `05_team-research.md` -- Consensus on unprovability of current signatures; Alternative A (weaken signatures) endorsed at 65% confidence; root cause identified as positional vs information-theoretic ordering mismatch
- `05_teammate-c-findings.md` -- Proposed Alternative A; detailed analysis of why current signatures are too strong; suggested chain-member quantification aligning with Truth.lean's existential world-history structure
- `05_teammate-b-findings.md` -- Mapped complete dependency chain: Frame.lean -> TruthLemma.lean -> Completeness.lean; confirmed that `defect_step_phi` provides the key propagation lemma for chain guard; inventoried all existing infrastructure
- `05_teammate-a-findings.md` -- Confirmed Path 1 (Until induction) does NOT close these sorries; the guard problem is structural and no axiom addition resolves it; BX10 already handles seed consistency

### Prior Plan Reference

Prior plan: `plans/04_canonical-chain-plan.md` (v3, 28h estimated). Key lessons:
- **Effort calibration**: v3 allocated 8h to Phase 3 (closing Frame.lean sorries) with a "revised strategy" fallback acknowledging the universal guard may be unprovable. This plan implements that fallback directly.
- **Phase structure validated**: The forward chain step (v3 Phase 1) and defect-discharge chain (v3 Phase 2) are the same building blocks needed here, but with a lighter-weight chain type (List-based rather than Int-indexed bi-infinite chain).
- **Risk validated**: v3 explicitly flagged "If the universal guard cannot be proved from the chain: Restructure the Frame.lean sorry signatures to use chain-member quantification." This plan commits to that restructuring.
- **Realization.lean delegation confirmed**: v3 correctly identified that Realization.lean sorries are pure delegation to Frame.lean and resolve automatically once Frame.lean is fixed.

### Roadmap Alignment

This plan advances the following ROAD_MAP.md items:
- **Until/Since eventuality + backward**: Closes 4 Frame.lean sorries (lines 607-647)
- **Active-path sorry reduction**: Reduces active-path sorries; Realization.lean and CanonicalChain.lean delegation bridges resolve automatically

## Goals & Non-Goals

**Goals**:
- Change the 4 Frame.lean sorry signatures to quantify over chain members (a `List BXPoint`) rather than arbitrary BXPoints
- Build a finite defect-discharge chain using `bx_forward_witness` and `defect_step_phi`
- Close all 4 Frame.lean sorries with the weakened signatures
- Update TruthLemma.lean (`until_iff_mcs`, `since_iff_mcs`) to use the new chain-based signatures
- Verify Realization.lean + CanonicalChain.lean delegation bridges compile with updated signatures
- `lake build` passes with zero new sorries and zero new axioms

**Non-Goals**:
- Closing the Completeness.lean sorry (line 154, canonical model embedding) -- separate concern
- Constructing a bi-infinite `Int -> BXPoint` chain -- lighter-weight `List BXPoint` suffices
- Proving `bx_le` totality on any interval -- impossible and unnecessary
- Modifying the BX axiom system (no new axioms)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Chain seed consistency for enriched seed (`{phi, phi U psi} ∪ g_content(w)`) is hard to prove | H | M | Use `bx_forward_witness` directly (already proved) instead of custom seed; discharge one defect per step via choosing `psi`-witness from `defect_step_F_psi` |
| TruthLemma.lean callers need more than chain-member quantification | H | L | Traced all 4 call sites: forward direction destructures to `h_guard_raw u h_wu h_uv`, backward direction passes guard to `bx_until_backward`. Both operate on the specific witness `v`, never on "all BXPoints between w and v" independently of the witness construction |
| Defect-discharge chain termination hits Lean termination checker | M | M | Use `Nat.lt_wfRel` with `sigma_defect_count` as the measure; `sigma_defect_count_bounded` provides the bound; fallback to `sorry`-free manual recursion with `have : ... < ...` decreasing_by |
| LocusControl.lean primed variants (`bx_until_eventuality_resolution'` etc.) have signature mismatch after changes | M | L | These are pure wrappers calling Realization.lean which calls Frame.lean; all use identical signatures. Change propagates automatically. Verify with `lake build`. |
| Backward direction (`bx_until_backward`) is harder to prove than forward | M | M | The backward direction (given a witness `v` with guard, derive `phi U psi in w`) can use BX8 enriched-seed + contradiction: if `not(phi U psi) in w`, construct an intermediate point violating the guard. Realization.lean's `enriched_seed_consistent_until` already provides the key seed consistency lemma. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Define Chain Type and Build Forward Chain [NOT STARTED]

**Goal**: Define a finite defect-discharge chain structure (`UntilChain` / `SinceChain`) and the chain construction function using well-founded recursion on defect count.

**Tasks**:
- [ ] Add `UntilChain` structure to `CanonicalChain.lean`:
  ```
  structure UntilChain (w : BXPoint) (φ ψ : Formula) where
    endpoint : BXPoint
    members : List BXPoint
    head_eq : members.head? = some w
    last_eq : members.getLast? = some endpoint
    nonempty : members.length > 0
    consecutive_le : ∀ i, (i + 1) < members.length →
      bx_le (members[i]!) (members[i+1]!)
    guard : ∀ i, (i + 1) < members.length →
      φ ∈ (members[i]!).formulas
    endpoint_psi : ψ ∈ endpoint.formulas
  ```
- [ ] Define `build_until_chain` by well-founded recursion on `sigma_defect_count w Sigma`:
  - Base: if `ψ ∈ w.formulas`, chain is `[w]` with endpoint `w`
  - Recursive: `ψ ∉ w.formulas`, so `φ ∈ w.formulas` (by `defect_step_phi`), `F(ψ) ∈ w.formulas` (by `defect_step_F_psi`), get `v` via `bx_forward_witness` with `ψ ∈ v.formulas`, prepend `w` to recursive chain from `v`
  - Termination: need `sigma_defect_count v Sigma < sigma_defect_count w Sigma` after the step. Key: the defect `φ U ψ` is discharged at `v` because `ψ ∈ v.formulas`. If other defects increase, need to argue total count still decreases -- use the enriched seed approach to ensure `φ U ψ` discharge dominates
- [ ] If direct defect-count termination is difficult, use an alternative: iterate at most `Sigma.card` steps (bounded by `sigma_defect_count_bounded`), with a `Nat.rec` loop rather than well-founded recursion
- [ ] Define mirror `SinceChain` and `build_since_chain` for backward direction using `bx_backward_witness` and `since_defect_step_phi`
- [ ] Verify `lake build` passes with chain construction sorry-free

**Timing**: 5 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalChain.lean` -- add chain type and construction

**Verification**:
- `UntilChain` and `SinceChain` are defined without sorry
- `build_until_chain` and `build_since_chain` terminate and are sorry-free
- `lake build` passes cleanly

---

### Phase 2: Rewrite Frame.lean Sorry Signatures and Close Forward Sorries [NOT STARTED]

**Goal**: Change the 4 Frame.lean sorry signatures to use chain-member quantification, then close `bx_until_eventuality_resolution` and `bx_since_eventuality_resolution` using the chain construction from Phase 1.

**Tasks**:
- [ ] Change `bx_until_eventuality_resolution` signature from:
  ```lean
  ∃ v : BXPoint, bx_le w v ∧ ψ ∈ v.formulas ∧
    ∀ u : BXPoint, bx_le w u → bx_le u v ∧ ¬bx_le v u → φ ∈ u.formulas
  ```
  to:
  ```lean
  ∃ (chain : UntilChain w φ ψ), True
  ```
  or equivalently, to a chain-existential form that exposes the endpoint and guard:
  ```lean
  ∃ (members : List BXPoint),
    members.head? = some w ∧
    (∃ v, members.getLast? = some v ∧ bx_le w v ∧ ψ ∈ v.formulas) ∧
    ∀ i, (i + 1) < members.length → φ ∈ (members[i]!).formulas ∧
      bx_le (members[i]!) (members[i+1]!)
  ```
  The exact signature will depend on what TruthLemma.lean needs (analyzed below). The key change: the guard ranges over list indices, not arbitrary BXPoints.
- [ ] Alternative approach (simpler): keep the existential `∃ v` form but add a chain witness:
  ```lean
  ∃ v : BXPoint, bx_le w v ∧ ψ ∈ v.formulas ∧
    ∃ (members : List BXPoint),
      members.head? = some w ∧ members.getLast? = some v ∧
      (∀ i, (i + 1) < members.length →
        bx_le (members[i]!) (members[i+1]!) ∧ φ ∈ (members[i]!).formulas)
  ```
  This preserves the `∃ v, bx_le w v ∧ ψ ∈ v.formulas` structure that TruthLemma consumes, while replacing the universal BXPoint guard with a chain-member guard.
- [ ] Close `bx_until_eventuality_resolution` body: construct `UntilChain` via `build_until_chain`, extract endpoint and members
- [ ] Change `bx_since_eventuality_resolution` signature (mirror of Until) and close its body via `build_since_chain`
- [ ] Change `bx_until_backward` signature: the guard hypothesis becomes chain-based. Close body using contradiction: if `¬(φ U ψ) ∈ w`, use `enriched_seed_consistent_until` (Realization.lean) to find an intermediate point with `¬(φ U ψ)`, then use BX9 to derive contradiction with chain guard
- [ ] Change `bx_since_backward` signature (mirror) and close body similarly
- [ ] Verify `lake build` passes with Frame.lean sorry-free (except box modal-equivalence sorry at ~line 440)

**Timing**: 5 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean` -- change 4 signatures, close 4 sorries

**Verification**:
- Frame.lean has zero new sorries (4 Until/Since sorries closed; box sorry remains unchanged)
- `lake build` may show errors in downstream files (TruthLemma.lean etc.) -- expected, fixed in Phase 3

---

### Phase 3: Update Callers (TruthLemma, Realization, CanonicalChain, LocusControl) [NOT STARTED]

**Goal**: Update all files that call the 4 Frame.lean functions to use the new chain-based signatures.

**Tasks**:
- [ ] Update `TruthLemma.lean` `until_iff_mcs` (line 281):
  - Forward direction (line 294-296): currently destructures `bx_until_eventuality_resolution` result as `⟨v, h_wv, h_ψv, h_guard_raw⟩`. With chain-based signature, destructure to extract `v` (endpoint), `h_wv` (bx_le from chain consecutive), `h_ψv` (endpoint has psi), and the chain guard. The TruthLemma statement uses `bx_lt u v` which is `bx_le u v ∧ ¬bx_le v u`. With the chain-based guard, we need to show: for any `u` with `bx_le w u` and `bx_lt u v`, `φ ∈ u.formulas`. This is NOT directly available from the chain guard (which only covers chain members). **Key decision**: either (a) change `until_iff_mcs` statement to use chain-based quantification too, or (b) keep `until_iff_mcs` statement unchanged and prove the universal guard from chain properties for the specific witness `v` produced by the chain.
  - **Preferred approach (a)**: Change `until_iff_mcs` to:
    ```lean
    φ.untl ψ ∈ w.formulas ↔
      ∃ v : BXPoint, bx_le w v ∧ ψ ∈ v.formulas ∧
        ∃ (members : List BXPoint), ... chain guard ...
    ```
    This propagates the chain-based quantification up to the truth lemma level, which is correct because truth evaluation in TaskModel semantics operates along specific histories (chains), not over all BXPoints.
  - Backward direction (line 305-307): currently calls `bx_until_backward`. Update to match new signature.
- [ ] Update `TruthLemma.lean` `since_iff_mcs` (line 315): mirror of Until changes
- [ ] Update `CanonicalChain.lean` delegation bridges (lines 166-201): these are thin wrappers that call Frame.lean directly. Update signatures to match and forward arguments.
- [ ] Update `Realization.lean` (lines 430-468): `until_eventuality_resolution`, `until_backward`, `since_eventuality_resolution`, `since_backward` -- all delegate to Frame.lean with identical signatures. Update to match.
- [ ] Update `LocusControl.lean` (lines 54-94): `bx_until_eventuality_resolution'` etc. -- delegate to Realization.lean. Update to match.
- [ ] Verify `lake build` passes cleanly across all modified files

**Timing**: 4 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/TruthLemma.lean` -- update `until_iff_mcs`, `since_iff_mcs` statements and proofs
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalChain.lean` -- update delegation bridges
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/Realization.lean` -- update 4 delegation functions
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/LocusControl.lean` -- update 4 primed functions

**Verification**:
- All 6 files compile without error
- No new sorries introduced in any file
- `lake build` passes cleanly

---

### Phase 4: Final Validation and Cleanup [NOT STARTED]

**Goal**: Comprehensive verification that all changes are consistent, no regressions, and the codebase is clean.

**Tasks**:
- [ ] Run `lake build` and verify zero errors
- [ ] Count total remaining sorries in `BXCanonical/` directory and compare to baseline
  - Before: 4 (Frame.lean) + 4 delegation (CanonicalChain.lean) + 4 delegation (Realization.lean) + 4 delegation (LocusControl.lean) = all chain to 4 sorry sources in Frame.lean
  - After: 0 Until/Since sorries. Box modal-equivalence sorry and Completeness.lean sorry remain (out of scope).
- [ ] Verify no new `axiom` declarations across the codebase
- [ ] Verify `CanonicalChain.lean` import is in `BXCanonical.lean` aggregator (should already be there)
- [ ] Ensure `Filtration/SigmaOrdering.lean` and `Filtration/DefectChain.lean` still compile (they are imported by `CanonicalChain.lean`)
- [ ] Update the CanonicalChain.lean module docstring to reflect the completed chain-based approach (remove "sorry gap" documentation, add description of the chain construction)
- [ ] Clean up any temporary comments or debug code

**Timing**: 2 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalChain.lean` -- update docstring
- Any files needing cleanup

**Verification**:
- `lake build` passes cleanly
- No new sorries anywhere (net reduction of 4 sorry sources in Frame.lean)
- No new axiom declarations
- CanonicalChain.lean docstring accurately describes the implemented approach

## Testing & Validation

- [ ] `lake build` passes at the end of each phase with no regressions
- [ ] Frame.lean: 4 Until/Since sorries -> 0 (box sorry at ~line 440 remains, out of scope)
- [ ] All delegation bridges (CanonicalChain, Realization, LocusControl) compile without sorry
- [ ] TruthLemma.lean `until_iff_mcs` and `since_iff_mcs` proved without sorry
- [ ] No new `sorry` anywhere in the codebase (net reduction of 4)
- [ ] No new `axiom` declarations
- [ ] DefectChain.lean and SigmaOrdering.lean still compile unchanged

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalChain.lean` -- extended (UntilChain/SinceChain types, build functions)
- `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean` -- modified (4 sorry signatures weakened and closed)
- `Theories/Bimodal/Metalogic/BXCanonical/TruthLemma.lean` -- modified (until_iff_mcs/since_iff_mcs updated)
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/Realization.lean` -- modified (delegation signatures updated)
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/LocusControl.lean` -- modified (delegation signatures updated)
- `specs/102_implement_quotient_filtration_close_sorries/plans/05_signature-weakening-plan.md` -- this plan

## Rollback/Contingency

**If chain termination is difficult**: Use bounded iteration (`Nat.rec` with `Sigma.card` as the bound) instead of well-founded recursion. The `sigma_defect_count_bounded` theorem guarantees termination within `Sigma.card` steps. This avoids fighting Lean's termination checker.

**If TruthLemma signature change cascades further**: Check whether Completeness.lean (line 154, currently sorry'd) references `until_iff_mcs`. It does not (verified by grep), so the cascade stops at TruthLemma.lean. The Completeness.lean sorry is about canonical model embedding, not about the truth lemma formulation.

**If the backward direction (`bx_until_backward`) resists proof**: Time-box at 3 hours. The backward direction is logically simpler (given a witness with guard, derive the formula in w). If stuck, leave `bx_until_backward` and `bx_since_backward` as sorry and focus on the forward sorries which are the primary blockers. This gives 2/4 sorries closed, which is still meaningful progress.

**Git rollback**: Each phase is committed separately. Revert to the last successful phase commit if a later phase fails. Existing DefectChain.lean and SigmaOrdering.lean are only imported (not modified) and remain safe.
