# Implementation Plan: Close BXCanonical Embedding (v18 -- Ordered-Discharge Chain Replacement)

- **Task**: 93 - Complete BXCanonical embedding
- **Status**: [NOT STARTED]
- **Effort**: 24 hours
- **Dependencies**: None (v14 Phase 1 infrastructure complete; quasimodel/filtration closed all Frame.lean sorries)
- **Research Inputs**: reports/18_team-research.md, reports/17_round-robin-chain-history.md, reports/16_team-research.md, handoffs/02_forward-F-analysis.md
- **Artifacts**: plans/18_bxcanonical-embedding.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Six sorry sites remain in `RootScopedChain.lean` (lines 1275, 1306, 1313, 1366, 1371, 1376), all downstream of a single primary blocker: `rr_fwd_chain_forward_F` (line 1275). Plan v17 attempted Strategy C (direct witness contradiction on the existing chain) and was BLOCKED -- team research report 18 confirms with high confidence (85-90%) that Strategy C is mathematically invalid because permanent BX11 displacement is syntactically consistent with the unconstrained `.choose` in `set_lindenbaum`. This v18 plan abandons Strategy C and implements the most viable long-term path: a **modified chain construction** that controls the Lindenbaum choice to guarantee target resolution, using the "never-resolved count" termination measure identified by Teammate D. This requires replacing `enriched_fwd_step` with a target-resolving step that uses `discharge_single_step` and an F-obligation recovery mechanism, then re-proving approximately 30 downstream theorems. The architecture (6,400+ lines sorry-free) is sound and fully reusable. Definition of done: `lake build` succeeds with zero sorry in RootScopedChain.lean, ROAD_MAP.md updated with dead ends and progress.

### Research Integration

- **Report 18** (4-teammate consensus): Strategy C is invalid (85-90% confidence). Permanent BX11 displacement is syntactically consistent. The `.choose` in `set_lindenbaum` is the source of non-determinism. Architecture is sound (95%). Most viable path: ordered-discharge chain with never-resolved count (55-65% confidence), accepting ~30 theorem re-proof cost. No published proof addresses forward_F syntactically -- all standard completeness proofs (Burgess 1984, Goldblatt 1992, Gabbay-Hodkinson-Reynolds 1994) handle it semantically.
- **Report 17** (round-robin chain history): 19+ failed approaches cataloged. Key lessons: semantics-syntax gap is real, BX11 is weaker than semantic ordering, F-obligation constancy (BX8+BX10) is the key structural fact.
- **Report 16** (4-teammate consensus): 3-cycle counterexample invalidating Strategy A. F-obligation set exactly constant. Corrected derivation: BX8+BX10.
- **Handoff 02**: BX11 non-transitivity, counting argument failure.

### Prior Plan Reference

Plan v17 (16 hours, 5 phases) was partially executed. Phase 1 (Strategy C) was BLOCKED after exhausting all three attack vectors (visit-step analysis, pigeonhole, discharge_single_step). Key learnings: (1) Strategy C is dead -- cannot prove forward_F on the existing chain because `.choose` is unconstrained, (2) six helper lemmas were proved and remain valid (`discharge_single_step`, `discharge_two_step`, `enriched_resolving_seed_consistent`, `bx11_earlier_resolving_seed_strong`, `rr_fwd_chain_F_obligation_forward/backward`), (3) F-obligation constancy infrastructure works, (4) effort estimates for the re-proof path were calibrated by Teammate D at 15-20 hours. Phases 2-5 were never attempted.

### Roadmap Alignment

- Advances the sole remaining active-path sorry blocking `bx_completeness` at Completeness.lean:154 (through `dd_countermodel`)
- Advances roadmap item: "TaskModel embedding (final step)" from OPEN toward DONE
- Would unblock task 95 (`#print axioms` audit on `bx_completeness`)

## Goals & Non-Goals

**Goals**:
- Update ROAD_MAP.md with all dead ends, progress made, and remaining work
- Define a new `target_resolving_fwd_step` that controls the Lindenbaum choice to guarantee `target in M'`
- Thread a "never-resolved count" invariant through the chain to guarantee termination
- Prove `rr_fwd_chain_forward_F` via well-founded induction on the never-resolved count
- Re-prove all downstream theorems that depend on the old chain definition (~30 theorems)
- Close all 6 sorry sites in RootScopedChain.lean
- Achieve `lake build` with zero sorry in RootScopedChain.lean

**Non-Goals**:
- Modifying CanonicalModel.lean (dead code, not on active path)
- Modifying Frame.lean, TruthLemma.lean, or Completeness.lean (sorry-free, not affected)
- Attempting Strategy C (dead, confirmed by Report 18)
- Attempting Strategy A (dead, confirmed by Report 16)
- Preserving the current `enriched_fwd_step` chain (it is the root cause)
- Proving unrestricted coherence properties (restricted suffices)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `{target} union g_content(M) union f_carry(M)` seed is inconsistent, blocking the combined target-resolution + F-preservation step | H | M (35%) | Report 18 notes `discharge_single_step` guarantees `target in M'` but does NOT preserve F-obligations. The new step must use a two-phase approach: first discharge the target via `discharge_single_step`, then recover F-obligations through BX8+BX10 (phi in MCS implies F(phi) in MCS). If the combined seed IS inconsistent, fall back to the two-phase approach where F-obligations are recovered at the NEXT chain step rather than the current one. |
| Never-resolved count invariant creates circular dependency with chain definition | H | M (30%) | Define the chain via well-founded recursion on the never-resolved count directly (not as a separate invariant). Use `WellFoundedRelation` or `Finset.card` decreasing measure. The chain and the invariant are defined simultaneously. |
| Re-proof cost exceeds 30 theorems, cascading failures | M | L (20%) | Most downstream theorems depend only on `g_content M subset M'` and `SetMaximalConsistent M'`, which the new step also provides. Track re-proof progress explicitly. If cost balloons past 40 theorems, reassess. |
| F-obligation recovery via BX8+BX10 only gives `F(psi) in M'`, not `psi in M'`, which is insufficient for some downstream lemmas | M | M (25%) | This is expected and acceptable. The chain's guarantee is `target in M'` (deterministic) plus `chi in M' or F(chi) in M'` for other F-obligations (disjunctive). The existing `enriched_fwd_step_preserves` already has this disjunctive shape, so downstream theorems should not need modification for this. |
| Backward chain (`rr_bwd_chain`) needs symmetric changes for `dd_fmcs_backward_P` | M | H (60%) | The backward chain uses `bwd_pred` which is symmetric. Apply the same ordered-discharge pattern. Budget 3 hours explicitly for this. |
| Lean formalization overhead exceeds estimates | M | M (25%) | Extensive sorry-free infrastructure exists. Use `lean_goal` + `lean_multi_attempt` for rapid iteration. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |
| 6 | 6 | 5 |
| 7 | 7 | 6 |

Phases within the same wave can execute in parallel.

---

### Phase 1: ROAD_MAP.md Update [NOT STARTED]

**Goal**: Update ROAD_MAP.md with all dead ends from the task 93 investigation, progress made, what remains, and corrected sorry inventory.

**Tasks**:
- [ ] Add dead ends 13-21+ to "Dead Ends (Archived)" section, drawing from Report 17's catalog of 19 failed approaches. Each entry should include the approach name, why it failed, and a reference to the report:
  - 13. **f_carry seed for enriched forward step** (task 93, plans v8-v14): `{target} union g_content(M) union f_carry(M)` is inconsistent in general. Counterexample: `G(F(alpha) -> neg psi) in M`, `F(alpha) in M`, `F(psi) in M`. The G-formula forces `F(alpha) -> neg psi` into any Lindenbaum extension containing g_content(M), while f_carry requires both F(alpha) and F(psi) to be present. No G-lift argument avoids this.
  - 14. **Fuel-based F-nesting recursion** (task 93, plans v5-v7): Conflates F-nesting depth (bounded by subformula closure) with visit count (unbounded). F(psi) can persist through arbitrarily many round-robin cycles without resolution.
  - 15. **BX11 acyclicity gate check** (task 93, plan v16 Strategy A): 3-cycle semantic counterexample. Three formulas psi1, psi2, psi3 with bx11_earlier forming a cycle in different MCS contexts. BX11 is not transitive and does not induce a well-order.
  - 16. **Strategy C: direct witness contradiction on existing chain** (task 93, plans v16-v17): Permanent BX11 displacement is syntactically consistent. The `.choose` in `set_lindenbaum` is unconstrained. All three attack vectors (visit-step analysis, pigeonhole, discharge_single_step) fail. Confidence: 10-15%.
  - 17. **Approach A: target-prioritized fold** (task 93, report 18): Reduces multi-step fold Case 3 to single BX11 application, but the final BX11 between target and compound can still fire Case 3.
  - 18. **Approach B: iterative refinement** (task 93, report 18): Mathematically sound but requires chain redefinition -- subsumed by the ordered-discharge approach.
  - 19. **Approach C: discharge_single_step at chain level** (task 93, report 18): Fatal F-propagation gap at non-target resolving steps.
  - 20. **Approach 21: Until reformulation via BX12** (task 93, report 18): `F(psi) -> top U psi` by BX12, then `bx_until_eventuality_resolution`. Produces abstract BXPoints not chain indices; `top U psi` may not be in `deferralClosure(root)`.
  - 21. **Strategy C fold-order variant** (task 93, report 18 synthesis): Processing target last in the BX11 fold. Investigated but fold outcome depends on MCS content which is itself determined by `.choose`.
- [ ] Add a "Task 93: Progress and Infrastructure" section documenting:
  - Six sorry-free helper lemmas proved during v17 Phase 1: `discharge_single_step`, `discharge_two_step`, `enriched_resolving_seed_consistent`, `bx11_earlier_resolving_seed_strong`, `rr_fwd_chain_F_obligation_forward`, `rr_fwd_chain_F_obligation_backward`
  - F-obligation constancy infrastructure: `rr_fwd_chain_F_propagate` reduces forward_F to "F(psi) cannot persist at every future step"
  - The core finding: the `.choose` in `set_lindenbaum` (called via `resolving_enriched_fwd_exists`) is the root cause. Controlling this choice is the only viable path.
- [ ] Update the active-path sorry inventory to include the 6 RootScopedChain.lean sorries explicitly:
  - Line 1275: `rr_fwd_chain_forward_F` -- PRIMARY BLOCKER
  - Line 1306: `dd_fmcs_forward_F` (t < 0 case) -- depends on 1275
  - Line 1313: `dd_fmcs_backward_P` -- symmetric to forward_F
  - Line 1366: `dd_bfmcs_restricted_tc` -- depends on forward_F and backward_P
  - Line 1371: `dd_bfmcs_restricted_buc` -- backward Until coherence
  - Line 1376: `dd_bfmcs_restricted_fuc` -- forward Until coherence
- [ ] Update the task 93 cross-reference from `[NOT STARTED]` to `[PLANNING]` with note: "Chain replacement approach (ordered-discharge with never-resolved count)"
- [ ] Update the module import graph line counts for RootScopedChain.lean (currently not listed separately -- it is part of the BXCanonical module but significant enough to warrant its own entry)

**Timing**: 2 hours

**Depends on**: none

**Files to modify**:
- `specs/ROAD_MAP.md` -- add dead ends 13-21, progress section, sorry inventory, task cross-reference update

**Verification**:
- ROAD_MAP.md compiles as valid markdown
- All 9 new dead ends are documented with failure reasons
- Sorry inventory lists all 6 RootScopedChain.lean sorries
- Task 93 cross-reference updated

---

### Phase 2: Design and Define target_resolving_fwd_step [NOT STARTED]

**Goal**: Replace `enriched_fwd_step` with a new `target_resolving_fwd_step` that controls the Lindenbaum choice to guarantee `target in M'` while preserving `g_content(M) subset M'` and providing `chi in M' or F(chi) in M'` for other F-obligations.

**Tasks**:
- [ ] Analyze the existing `enriched_fwd_step` (line 561) and `resolving_enriched_fwd_exists` (line 366) to understand exactly which properties downstream theorems depend on. Document the complete API surface:
  - `enriched_fwd_step_mcs` -- M' is MCS
  - `enriched_fwd_step_g_content` -- g_content(M) subset M'
  - `enriched_fwd_step_preserves` -- chi in M' or F(chi) in M' for sigma_list members with F(chi) in M
  - `enriched_fwd_step_resolves_one` -- at least one formula directly resolved (w in M')
  - `enriched_fwd_step_spec` -- combined specification
- [ ] Define `target_resolving_fwd_step` with the following structure:
  ```
  noncomputable def target_resolving_fwd_step (M : Set Formula) (h_mcs : SetMaximalConsistent M)
      (target : Formula) (sigma_list : List Formula) : Set Formula :=
    if h_F : Formula.some_future target in M then
      -- Use discharge_single_step to get M_base with target in M_base and g_content(M) subset M_base
      -- Then verify F-obligation preservation: for each chi in sigma_list with F(chi) in M,
      -- since g_content(M) subset M_base and phi_in_mcs_imp_F_phi gives F(chi) in M -> G(F(chi)) in M
      -- ... wait, G(F(chi)) is NOT guaranteed from F(chi).
      -- Alternative: use the fact that F(chi) in M and g_content(M) subset M_base.
      -- G(F(chi)) in M would give F(chi) in M_base, but F(chi) -> G(F(chi)) is not derivable.
      -- Key insight: we DON'T need F(chi) in M_base from g_content. Instead:
      -- At the next step, chi may or may not have F(chi) in M_base.
      -- If F(chi) in M_base: chi remains an F-obligation (persists).
      -- If F(chi) not in M_base: then by MCS completeness, neg F(chi) in M_base,
      --   which means G(neg chi) in M_base (by the equivalence in MCS).
      --   But this doesn't help -- it means chi is NEVER satisfied in the future from M_base.
      -- REVISED APPROACH: The two-phase step.
      -- Phase A: Use discharge_single_step for target -> get M_target with target in M_target.
      -- Phase B: For F-obligations, since phi_in_mcs_imp_F_phi gives
      --   psi in MCS -> F(psi) in MCS, and BX4 gives psi -> G(P(psi)),
      --   the key is that the CHAIN's F-obligation set is constant (already proved).
      --   So F-obligations that are lost at this step will be RE-ESTABLISHED at subsequent steps
      --   by the sigma_list membership + the round-robin schedule.
      -- The target_resolving step needs to:
      --   1. Guarantee target in M' (via discharge_single_step seed)
      --   2. Guarantee g_content(M) subset M' (via discharge_single_step seed)
      --   3. Accept that F-obligations may be disjunctively preserved (chi in M' or F(chi) in M')
      -- Property 3 follows from BX11: for each chi with F(chi) in M, BX11 gives
      --   F(chi and target) in M or F(target and chi) in M or target = chi.
      -- Actually, the simplest approach is:
      --   Seed = {target} union g_content(M)
      --   This is consistent by forward_temporal_witness_seed_consistent (already proved).
      --   Lindenbaum extension gives M' with target in M' and g_content(M) subset M'.
      --   For F-preservation: F(chi) in M and g_content(M) subset M' does NOT give F(chi) in M'.
      --   But BX10+BX8 gives: if psi in M, then F(psi) in M (by BX8: psi -> psi U psi ... no).
      --   Wait: phi_in_mcs_imp_F_phi says psi in M -> F(psi) in M. This is ALREADY IN M, not M'.
      --   The question is whether F(chi) in M' for chi in sigma_list with F(chi) in M.
      --   This is NOT guaranteed by {target} union g_content(M) seed alone.
      --   F(chi) is NOT a G-formula, so it's not in g_content(M).
      -- CONCLUSION: The target_resolving step CANNOT simultaneously guarantee
      --   target in M' AND F(chi) in M' for all F-obligations.
      --   It CAN guarantee target in M' and g_content(M) subset M'.
      --   F-obligations must be handled by the CHAIN INVARIANT, not the step.
      (discharge_single_step M h_mcs target h_F).choose
    else
      fwd_succ M h_mcs target
  ```
- [ ] Prove the core properties of `target_resolving_fwd_step`:
  - `target_resolving_fwd_step_mcs` -- M' is MCS
  - `target_resolving_fwd_step_g_content` -- g_content(M) subset M'
  - `target_resolving_fwd_step_target_in` -- when F(target) in M, target in M' (THE KEY NEW PROPERTY)
- [ ] Identify which `enriched_fwd_step_*` properties are NOT satisfied by the new step:
  - `enriched_fwd_step_preserves` -- F(chi) in M does NOT imply chi in M' or F(chi) in M' (LOST)
  - `enriched_fwd_step_resolves_one` -- still holds (target is resolved, which is stronger)
- [ ] Document the API difference and plan the re-proof strategy for downstream theorems

**Timing**: 2 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- add new definitions and proofs (lines 560-640 region, alongside existing definitions)

**Verification**:
- `target_resolving_fwd_step` compiles
- All three core property theorems compile without sorry
- `lake build` succeeds (existing code untouched at this stage)

---

### Phase 3: Define target_resolving_chain and Never-Resolved Invariant [NOT STARTED]

**Goal**: Define a new chain `target_resolving_chain` using `target_resolving_fwd_step` and thread a "never-resolved count" invariant through the recursion that guarantees termination of the F-obligation discharge.

**Tasks**:
- [ ] Define `never_resolved_set`: for a chain up to step n, the set of formulas chi in sigma_list such that chi has never appeared in any chain step 0..n:
  ```
  def never_resolved_set (chain_fn : Nat -> Set Formula) (sigma_list : List Formula) (n : Nat) : Finset Formula :=
    sigma_list.toFinset.filter (fun chi => forall k, k <= n -> chi not in chain_fn k)
  ```
- [ ] Define `target_resolving_chain` using `target_resolving_fwd_step`:
  ```
  noncomputable def target_resolving_chain (M0 : Set Formula) (h0 : SetMaximalConsistent M0)
      (sigma_list : List Formula) : (n : Nat) -> { M : Set Formula // SetMaximalConsistent M }
    | 0 => ⟨M0, h0⟩
    | n + 1 =>
      let ⟨M, hM⟩ := target_resolving_chain M0 h0 sigma_list n
      let target := rrSchedule sigma_list n
      ⟨target_resolving_fwd_step M hM target sigma_list,
       target_resolving_fwd_step_mcs M hM target sigma_list⟩
  ```
- [ ] Prove the key invariant: at each step where F(target) in chain(n), target in chain(n+1):
  ```
  theorem target_resolving_chain_resolves_target : ... :=
    -- When F(target) in chain(n), target_resolving_fwd_step guarantees target in chain(n+1)
  ```
- [ ] Prove the never-resolved count decreases: at each step n, if the scheduled target has F(target) in chain(n), then target was previously never-resolved (or already resolved), and after this step target IS resolved. The never-resolved count for formulas that have F-obligations strictly decreases.
- [ ] Prove g_content propagation for the new chain:
  ```
  theorem target_resolving_chain_g_content (n : Nat) :
      g_content (target_resolving_chain M0 h0 sigma_list n).val subset
        (target_resolving_chain M0 h0 sigma_list (n + 1)).val
  ```
- [ ] Prove the F-obligation constancy property: F(chi) in chain(n) implies F(chi) in chain(n+1) or chi in chain(n+1). NOTE: This is the property that is NOT automatically preserved by `target_resolving_fwd_step`. We need to prove it through the chain structure:
  - If F(chi) in chain(n), then G(F(chi)) may or may not be in chain(n).
  - Since g_content(chain(n)) subset chain(n+1), if G(F(chi)) in chain(n) then F(chi) in chain(n+1).
  - If G(F(chi)) NOT in chain(n), then by MCS, neg G(F(chi)) in chain(n), i.e., F(neg F(chi)) in chain(n).
  - This is the crux: we need phi_in_mcs_imp_F_phi (psi in MCS -> F(psi) in MCS, proved) to establish that F(chi) in chain(n) implies some structural fact about chain(n+1).
  - CRITICAL INSIGHT: We may NOT need step-level F-preservation at all. The forward_F proof via never-resolved count works differently: it says "F(psi) in chain(n)" implies "psi appears in chain(s) for some s > n" by induction on the number of formulas that have never been resolved. At psi's visit step, F(psi) must still be in the chain (by F-obligation constancy from g_content propagation + BX4 connect_future), and target_resolving_fwd_step guarantees psi in chain(step+1).
  - WAIT: F-obligation constancy from g_content requires G(F(psi)) in chain(n). F(psi) in chain(n) does NOT imply G(F(psi)) in chain(n). The existing `rr_fwd_chain_F_obligation_persists` uses `enriched_fwd_step_preserves` which the new step does NOT have.
  - REVISED APPROACH: The never-resolved count argument does NOT require F-obligation persistence between steps. Instead, it requires: given F(psi) in chain(n), there exists some s > n where psi's round-robin visit step occurs AND F(psi) in chain(s). This can be established by: (a) BX4 gives psi -> G(P(psi)), and (b) phi_in_mcs_imp_F_phi gives psi in MCS -> F(psi) in MCS. If psi was resolved at some earlier step k (psi in chain(k)), then F(psi) in chain(k) (by phi_in_mcs_imp_F_phi). Then G(F(psi)) MAY be in chain(k). Actually this is getting circular.
  - ALTERNATIVE: Use the proved `enriched_fwd_step_preserves` as-is for non-target formulas. The new chain uses `target_resolving_fwd_step` ONLY at the target's visit step, and uses the original `enriched_fwd_step` at all other steps. This hybrid approach keeps F-preservation for non-target steps while guaranteeing target resolution at target steps.
- [ ] DECISION POINT: Choose between pure target_resolving chain vs. hybrid chain. The hybrid chain (target_resolving at target's visit step, enriched at other steps) preserves most existing infrastructure. Document the decision and rationale.

**Timing**: 2 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- add chain definition and invariant proofs

**Verification**:
- `target_resolving_chain` compiles
- g_content propagation theorem compiles
- Never-resolved count decrease theorem compiles (or is clearly scoped)
- `lake build` succeeds

---

### Phase 4: Prove rr_fwd_chain_forward_F via Never-Resolved Induction [NOT STARTED]

**Goal**: Prove the primary blocker `rr_fwd_chain_forward_F` (line 1275) using the new chain construction and well-founded induction on the never-resolved count.

**Tasks**:
- [ ] Establish the key lemma: at psi's round-robin visit step (index j + k * |sigma_list| for psi's index j), if F(psi) is in the chain at that step, then psi is in the chain at the NEXT step. This follows directly from `target_resolving_fwd_step_target_in`.
- [ ] Prove F-obligation propagation to the visit step. Given F(psi) in chain(n), we need F(psi) in chain(m) for the next visit step m > n. This requires showing that F(psi) persists from step n to step m. There are two sub-approaches:
  - Sub-approach A (hybrid chain): At non-target steps, `enriched_fwd_step_preserves` gives F(psi) in chain(k+1) or psi in chain(k+1). If psi appears before the visit step, we are done. If F(psi) persists, it reaches the visit step.
  - Sub-approach B (pure chain): Prove that g_content propagation + BX4/BX8/BX10 suffice to propagate F-obligations. If F(psi) in chain(k) and psi in sigma_list, then at psi's next visit step, either psi was resolved at some intermediate step (done) or F(psi) persists to the visit step.
- [ ] Formalize the well-founded induction argument:
  - Base case: if all formulas in sigma_list with F-obligations have been resolved at least once before step n, then psi has been resolved (since it's one of them).
  - Inductive step: at each complete round-robin cycle (|sigma_list| steps), at least one new formula from sigma_list is resolved for the first time (by `target_resolving_fwd_step_target_in` at its visit step, when F(target) is present). The never-resolved count strictly decreases. Since sigma_list is finite, after at most |sigma_list| complete cycles, all formulas with persistent F-obligations are resolved.
  - For psi specifically: within |sigma_list|^2 steps of F(psi) appearing, psi must be resolved.
- [ ] Write the proof in Lean. The structure should be:
  ```
  theorem rr_fwd_chain_forward_F ... := by
    -- Induction on |{chi in sigma_list | chi never resolved in chain(0..n)}|
    -- At psi's visit step m (exists by round-robin), F(psi) in chain(m)
    -- target_resolving_fwd_step gives psi in chain(m+1). Done.
    -- The key is showing F(psi) persists to m. Use F-propagation lemma.
  ```
- [ ] Handle the edge case where F(psi) might disappear before the visit step (this is the crux of the whole problem -- the hybrid chain approach or the g_content-based propagation must address this)
- [ ] If the pure approach has a gap in F-propagation, switch to the hybrid chain approach and re-do the relevant parts of Phase 3

**Timing**: 2 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- replace sorry at line 1275 with proof

**Verification**:
- `rr_fwd_chain_forward_F` compiles without sorry
- `lake build` succeeds
- `lean_verify` confirms no sorry-dependent axioms in `rr_fwd_chain_forward_F`

---

### Phase 5: Re-prove Downstream Forward Chain Theorems [NOT STARTED]

**Goal**: Update `rr_fwd_chain` to use the new chain definition (or prove that the new chain satisfies all properties needed by downstream theorems) and re-prove the ~30 theorems that depend on the chain definition.

**Tasks**:
- [ ] Catalog all theorems between `rr_fwd_chain` (line 637) and `rr_fwd_chain_forward_F` (line 1275) that reference `enriched_fwd_step` or `rr_fwd_chain` directly. Expected list includes:
  - `rr_fwd_chain_mcs` -- chain produces MCS (trivial re-proof)
  - `rr_fwd_chain_g_content` -- g_content propagation (trivial re-proof)
  - `rr_fwd_chain_F_obligation_persists` -- F(psi) in chain(n) -> F(psi) in chain(n+1) (NEEDS RE-PROOF if chain changed)
  - `rr_fwd_chain_F_obligation_absent` -- absence propagates (depends on chain structure)
  - `rr_fwd_chain_F_obligation_forward` -- F-obligation constancy forward
  - `rr_fwd_chain_F_obligation_backward` -- F-obligation constancy backward
  - `rr_fwd_chain_F_propagate` -- reduces forward_F to "cannot persist forever"
  - Various helper lemmas for the enriched fold
- [ ] Strategy A (recommended): Replace `rr_fwd_chain` definition with the new chain, then fix all downstream proofs. This is cleaner but has higher blast radius.
- [ ] Strategy B (conservative): Keep `rr_fwd_chain` as-is, define `target_resolving_chain` alongside it, prove `target_resolving_chain` has all the same properties PLUS forward_F, then use `target_resolving_chain` in `dd_fmcs`. Lower blast radius but more code.
- [ ] Choose strategy based on Phase 3/4 outcome. If the hybrid chain approach was used, Strategy B is natural. If the pure replacement approach works, Strategy A is cleaner.
- [ ] Re-prove each affected theorem. For most, the proof structure is identical -- only the step function name changes. For F-obligation theorems, the proofs may need substantive changes.
- [ ] Ensure `dd_chain` (the bidirectional chain combining forward and backward) still works with the new definitions.
- [ ] Run `lake build` after each batch of re-proofs to catch cascading issues early.

**Timing**: 2 hours

**Depends on**: 4

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- modify chain definition or add new chain, re-prove ~30 theorems

**Verification**:
- All theorems between lines 637-1275 compile without sorry
- `lake build` succeeds
- No new sorry introduced

---

### Phase 6: Close Remaining 5 Sorry Sites [NOT STARTED]

**Goal**: Close the remaining 5 sorry sites (lines 1306, 1313, 1366, 1371, 1376) that depend on `rr_fwd_chain_forward_F`.

**Tasks**:
- [ ] **dd_fmcs_forward_F t < 0 case** (line 1306): F(psi) in backward chain at index (-t).toNat. Approach: the backward chain propagates h_content. If F(psi) can be propagated to M0 (the junction point), then use `rr_fwd_chain_forward_F` (now proved) for the forward direction. If F(psi) does NOT propagate to M0 via h_content, investigate whether the backward chain needs a symmetric target-resolving modification.
  - Sub-task: Check whether `H(F(psi)) in M` follows from `F(psi) in M` in an MCS. If yes, h_content propagation carries F(psi) backward to M0.
  - Sub-task: If not, implement a symmetric `target_resolving_bwd_step` using `discharge_single_step` for the backward direction (with P-obligations instead of F-obligations).
- [ ] **dd_fmcs_backward_P** (line 1313): Symmetric to forward_F but for P-obligations in the backward chain. Approach:
  - For t <= 0: P(psi) in backward chain. The backward chain should resolve P-obligations at psi's visit step. If the backward chain uses the original `bwd_pred` construction, it may already have this property, or may need the same target-resolving treatment.
  - For t > 0: P(psi) in forward chain. Propagate to M0 and use backward chain. Check whether `G(P(psi)) in M` follows from `P(psi) in M` (it does, by BX4: psi -> G(P(psi)), so if psi in M then G(P(psi)) in M; but we have P(psi) in M, not psi in M). Alternative: BX4' gives psi -> H(F(psi)), not directly helpful.
  - Key fact: the backward direction is structurally symmetric. If the forward chain replacement works, the backward chain replacement follows the same pattern with H/P swapped for G/F.
- [ ] **dd_bfmcs_restricted_tc** (line 1366): Restricted temporal coherence. Delegates to four sub-cases:
  - G(phi) forward propagation: by `dd_chain_g_content` (proved, unaffected by chain change)
  - H(phi) backward propagation: by `dd_chain_h_content` (proved, unaffected)
  - F(phi) forward: by `dd_fmcs_forward_F` (now proved in both cases)
  - P(phi) backward: by `dd_fmcs_backward_P` (now proved)
  - This should be a straightforward assembly of the four sub-proofs.
- [ ] **dd_bfmcs_restricted_fuc** (line 1376): Forward Until/Since coherence. For `(phi U psi) in fam.mcs(t)`:
  - F(psi) in fam.mcs(t) by BX10 (`until_F` / `until_implies_some_future`)
  - psi in fam.mcs(s) for some s > t by `dd_fmcs_forward_F`
  - Persistence of (phi U psi) through [t, s) by BX5 (`self_accum_until`) + BX9 (`until_elim`)
  - phi holds on [t, s) by BX9 extraction
  - For Since direction: symmetric using `dd_fmcs_backward_P`
- [ ] **dd_bfmcs_restricted_buc** (line 1371): Backward Until/Since coherence. This was identified in Plan v17 as the HARDEST sorry (55% failure likelihood). However, with backward_P now proved, the approach is:
  - For `(phi S psi) in fam.mcs(t)`: P(psi) in fam.mcs(t) by BX10' (`since_P`)
  - psi in fam.mcs(s) for some s < t by `dd_fmcs_backward_P`
  - Persistence through (s, t] by BX5' + BX9'
  - This is structurally identical to fuc but in the backward direction. With backward_P proved, the difficulty is reduced significantly.
- [ ] For each sorry: write the proof, run `lake build`, fix any issues.

**Timing**: 2 hours

**Depends on**: 5

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- replace sorry at lines 1306, 1313, 1366, 1371, 1376

**Verification**:
- All 6 sorry sites in RootScopedChain.lean have no sorry
- `lake build` succeeds
- `grep -n sorry RootScopedChain.lean` returns zero matches

---

### Phase 7: Final Verification, Axiom Audit, and ROAD_MAP.md Completion [NOT STARTED]

**Goal**: Verify the complete sorry-free build, run axiom audits, update ROAD_MAP.md with the successful outcome, and add documentation.

**Tasks**:
- [ ] Run `lake build` from clean state and verify zero errors
- [ ] Run `grep -rn sorry Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` and verify zero matches
- [ ] Run `lean_verify` on `dd_countermodel` and verify no sorry-dependent axioms
- [ ] Run `lean_verify` on `bx_completeness` and verify the axiom set is exactly `{propext, Classical.choice, Quot.sound}`
- [ ] Update ROAD_MAP.md:
  - Change active-path sorry count from 1 to 0
  - Update TaskModel embedding status from OPEN to DONE
  - Update task 93 cross-reference to [IMPLEMENTING] or [PLANNED] (per actual status)
  - Add a "How the Chain Was Fixed" section documenting:
    - The ordered-discharge approach with target_resolving_fwd_step
    - The never-resolved count termination argument
    - Why this works when the original enriched_fwd_step did not
    - The ~30 theorem re-proof cost and strategy used
  - Update module import graph line counts
- [ ] Add docstrings to new definitions:
  - `target_resolving_fwd_step` -- reference to Burgess 1984 canonical construction, explain why controlled Lindenbaum choice is needed
  - `target_resolving_chain` -- explain the round-robin + controlled-choice structure
  - `never_resolved_set` / termination measure -- explain the well-founded induction argument
- [ ] Add a summary comment at the top of the modified section documenting the approach

**Timing**: 2 hours

**Depends on**: 6

**Files to modify**:
- `specs/ROAD_MAP.md` -- update sorry inventory, add success documentation
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- add docstrings and summary comments

**Verification**:
- `lake build` succeeds with zero errors
- Sorry count in RootScopedChain.lean is 0
- Sorry count in entire BXCanonical module is 0 (if Completeness.lean sorry is also closed)
- ROAD_MAP.md accurately reflects current state
- Axiom audit clean
- All new definitions have docstrings

## Testing & Validation

- [ ] `lake build` succeeds with zero errors at each phase boundary
- [ ] `grep -rn sorry Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` returns zero matches
- [ ] `lean_verify` on `dd_countermodel` shows no sorry-dependent axioms
- [ ] `lean_verify` on `bx_completeness` shows only `propext`, `Classical.choice`, `Quot.sound`
- [ ] No new sorry introduced in any file
- [ ] `dd_countermodel` theorem compiles end-to-end
- [ ] ROAD_MAP.md dead ends section updated with task 93 entries (13-21)
- [ ] ROAD_MAP.md sorry inventory reflects zero active-path sorries (or 0 in RootScopedChain.lean + 1 in Completeness.lean if dd_countermodel is wired separately)
- [ ] All new definitions have docstrings referencing the mathematical construction

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- modified (6 sorry sites replaced, new chain construction, ~30 re-proved theorems, docstrings)
- `specs/ROAD_MAP.md` -- updated (dead ends 13-21, progress documentation, sorry inventory, task cross-reference, success documentation)
- `specs/093_complete_bxcanonical_embedding/plans/18_bxcanonical-embedding.md` -- this plan

## Rollback/Contingency

Changes are confined to `RootScopedChain.lean` (lines 560+) and `specs/ROAD_MAP.md`.

1. **Chain replacement succeeds (all 6 sorries closed)**: No rollback needed. Update ROAD_MAP.md with success. This is the expected path at 55-65% confidence.

2. **Chain replacement partially succeeds (forward_F proved, some coherence sorries remain)**: Keep all proved theorems. The forward chain fix has permanent value. Close as many coherence sorries as possible, document remaining gaps, and spawn focused tasks for each remaining sorry. Even partial success (3-4 of 6 sorries) is substantial progress.

3. **Chain replacement blocked (cannot prove F-obligation propagation to visit step)**: This would mean the pure target-resolving approach fails. Fall back to the hybrid chain (target_resolving at visit steps, enriched at others). This preserves F-obligation constancy from the existing infrastructure while adding target resolution. If the hybrid approach also fails, the obstruction is deeper than the `.choose` -- document precisely and spawn a dedicated research task for alternative completeness proof architectures.

4. **Re-proof cost exceeds 40 theorems**: Reassess Strategy B (parallel chain alongside existing). This doubles the code but avoids modifying existing proofs. Budget: 4 additional hours.

5. **Full rollback**: `git checkout -- Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` restores the 6-sorry state. ROAD_MAP.md Phase 1 changes should be committed independently and preserved regardless.

### Key Differences from Plan v17

| Aspect | Plan v17 | Plan v18 |
|--------|----------|----------|
| Primary strategy | Strategy C (direct contradiction) | Ordered-discharge chain replacement |
| Chain modification | None (preserve existing chain) | Replace enriched_fwd_step with target_resolving_fwd_step |
| ROAD_MAP.md update | Phase 4 (after implementation) | Phase 1 (first, per user instruction) |
| Re-proof cost | 0 (Strategy C works on existing chain) | ~30 theorems (accepted) |
| Phase count | 5 | 7 |
| Total effort | 16 hours | 24 hours |
| Confidence | 15-20% (Strategy C, post-report 18) | 55-65% (ordered-discharge, per Teammate D) |
| F-preservation approach | Not applicable (chain unchanged) | Hybrid chain or g_content + BX4/BX8/BX10 recovery |
