# Implementation Plan: F/P Witness — Safe Target Seed Consistency (v12)

- **Task**: 81 - F/P Witness Representation Theorem
- **Status**: [NOT STARTED]
- **Effort**: 10 hours
- **Dependencies**: None (uses only sorry-free infrastructure from v11)
- **Research Inputs**: reports/12_team-research.md
- **Artifacts**: plans/12_implementation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Close the sorry in `constrained_successor_seed_restricted_consistent` (SuccChainFMCS.lean:1790), which is the single mathematical gap blocking `completeness_over_Int` and `discrete_completeness_fc`. The entire proof chain from `build_restricted_tc_family` through `restricted_forward_chain_forward_F` to `completeness_over_Int` is structurally complete — only this seed consistency lemma has a sorry. The plan proves consistency of the enriched seed `g_content(u) ∪ deferralDisjunctions(u) ∪ p_step_blocking(u) ∪ boundary_resolution_set(u) ∪ f_content(u)` by establishing that all seed elements are derivable from u under the G-lift + temporal axioms, leveraging the sorry-free `temporal_theory_witness_exists` as the core consistency witness.

### Research Integration

Report 12 (team-research.md, 2 teammates) establishes:
- Including F-obligations in the successor seed prevents Lindenbaum from adding their G-negations (both teammates agree)
- The enriched seed CAN be inconsistent for certain target choices (counterexample: G(q) + F(neg q))
- A "safe" target ordering always exists (semantic argument), but the constrained seed has NO target — it includes ALL f_content simultaneously
- The constrained_successor_seed_restricted does NOT include an arbitrary target — it includes g_content, deferralDisjunctions, p_step_blocking, boundary_resolution_set, and f_content. The counterexample from research (target conflicts with F-obligations) does NOT apply because there is no separate target in this seed.

**Critical insight**: The seed `constrained_successor_seed_restricted` is a SUBSET of the DRM u (all components — g_content, deferralDisjunctions, p_step_blocking, boundary_resolution_set, f_content — are subsets of u). A subset of a consistent set is consistent. The proof strategy is to establish this subset relationship rigorously.

## Goals & Non-Goals

**Goals**:
- Prove `constrained_successor_seed_restricted_consistent` sorry-free
- Make `completeness_over_Int` and `discrete_completeness_fc` sorry-free for this blocker
- Leverage the existing structurally complete proof chain — no new files needed

**Non-Goals**:
- Close `bfmcs_from_mcs_temporally_coherent` directly (it is bypassed by the restricted chain approach)
- Address `dense_completeness_fc` (separate issue, requires dense canonical model)
- Create new chain infrastructure (v11 infrastructure in MCSWitnessSuccessor/MCSWitnessChain is helpful but not needed for this approach)
- Restructure the completeness proof

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| f_content(u) is NOT a subset of u (f_content extracts psi from F(psi)) | H | H | f_content(u) = {psi : F(psi) in u}. These psi may NOT be in u. The subset argument fails for f_content. Need alternative: prove consistency via the MCS witness construction (temporal_theory_witness_exists). |
| boundary_resolution_set elements not in u | H | M | boundary_resolution_set contains chi where F(chi) in u and chi in deferralClosure. Same issue as f_content — chi may not be in u. |
| G-lift argument fails for F-formulas | H | Known | Research confirms G-lift cannot handle F-formulas. Alternative: prove seed consistency by constructing an explicit consistent superset (the MCS witness W intersect deferralClosure contains the seed). |
| Interaction between f_content and p_step_blocking creates inconsistency | M | L | p_step_blocking adds neg(P(chi)) when P(chi) not in u. These are in u (by DRM maximality). f_content adds psi for F(psi) in u. Potential conflict: neg(P(chi)) and psi where psi implies P(chi). Mitigate by proving from the MCS witness that both coexist. |
| Proof too long for single theorem | M | M | Break into lemmas: seed_subset_witness, witness_consistent, therefore seed_consistent. |

## Implementation Phases

### Phase 1: Analyze Seed Components and Prove Subset Relationships [NOT STARTED]

**Goal**: Establish which seed components are subsets of u and which are not. Prove the easy subset cases. Identify exactly what remains.

**Tasks**:
- [ ] Read `constrained_successor_seed_restricted` definition and `mem_constrained_successor_seed_restricted_iff` to enumerate all 5 components
- [ ] Verify: `g_content(u) ⊆ u` — g_content = {a : G(a) in u}, and by T-axiom G(a) -> a, we have a in u. Prove or find existing lemma.
- [ ] Verify: `deferralDisjunctions(u) ⊆ u` — these are chi v F(chi) for F(chi) in u. By DRM disjunction property + deferralClosure membership, the disjunction is in u.
- [ ] Verify: `p_step_blocking_restricted(u) ⊆ u` — these are neg(P(chi)) when P(chi) not in u. By DRM negation completeness within deferralClosure, neg(P(chi)) in u.
- [ ] Verify: `boundary_resolution_set(u) ⊆ u` — examine definition. These may involve chi where F(chi) in u. Determine if chi in u.
- [ ] Verify: `f_content(u) ⊆ u` — f_content = {psi : F(psi) in u}. psi may NOT be in u (this is the whole point of F-obligations). This component is NOT a subset of u.
- [ ] Document findings: which components are trivially subsets, which are not
- [ ] Run `lake build` to verify existing code state

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` (read-only analysis + small helper lemmas, ~50 lines)

**Verification**:
- Clear documentation of which seed components are/are not subsets of u
- Helper lemmas for the subset cases compile without sorry

---

### Phase 2: MCS Witness Consistency Argument [NOT STARTED]

**Goal**: Prove that the constrained_successor_seed_restricted is consistent by showing it is a subset of the MCS witness W intersected with deferralClosure, where W comes from `temporal_theory_witness_exists`.

**Tasks**:
- [ ] Define the proof strategy: Given DRM u with F_top in u, extend u to full MCS M. Apply `temporal_theory_witness_exists` with target = F_top (or any theorem). Get MCS W with G-agree (G(a) in M -> G(a) in W).
- [ ] Prove g_content(u) subset W: For a in g_content(u), G(a) in u subset M. By G-agree, G(a) in W. By T-axiom and W being MCS, a in W.
- [ ] Prove deferralDisjunctions(u) subset W: chi v F(chi) is in u subset M. Since M subset of W is NOT guaranteed, we need an alternative. Alternative: chi v F(chi) is equivalent to F(chi) (since chi -> F(chi) by T-axiom). F(chi) in u subset M. Need F(chi) in W. This requires showing F(chi) propagates from M to W via the G-agree property. Since G-agree gives G(a) in M -> G(a) in W, and F(chi) is NOT of the form G(a), this path may fail. Alternative: prove deferralDisjunctions are in u (subset argument from Phase 1).
- [ ] Prove p_step_blocking_restricted(u) subset W: neg(P(chi)) in u (from Phase 1 subset result). u subset M. Need neg(P(chi)) in W. Same issue — not G-liftable.
- [ ] If the W-intersection approach fails for non-G-liftable components, pivot to the DIRECT subset argument: prove that all 5 components of the seed are subsets of u. For f_content, prove that if F(psi) in u and u is a DRM, then psi in u (this would mean all F-obligations are already resolved, which contradicts the purpose of F(psi)). This is FALSE in general — so we need a different approach.
- [ ] Alternative approach: Prove consistency directly by contradiction. Assume the seed is inconsistent. Then there exist finitely many seed elements s1,...,sn that derive contradiction. Each si is in one of the 5 components. Use properties of u (consistency, DRM maximality) to show the derivation is impossible.
- [ ] Run `lake build`

**Timing**: 2.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` (~100-200 lines of proof)

**Verification**:
- Either: seed subset of W proven, giving consistency from W's consistency
- Or: direct contradiction argument established
- Key intermediate lemmas compile without sorry

---

### Phase 3: Prove constrained_successor_seed_restricted_consistent [NOT STARTED]

**Goal**: Complete the sorry-free proof of `constrained_successor_seed_restricted_consistent` using the strategy identified in Phase 2.

**Tasks**:
- [ ] If Phase 2 identified the W-intersection path: Wire the proof. Given DRM u with F_top, extend to MCS M, get witness W, show seed subset W intersect deferralClosure, conclude consistency.
- [ ] If Phase 2 identified the direct contradiction path: Formalize the contradiction argument. Key insight from research: in a DRM u, F(psi) and psi are NOT contradictory — F(psi) means "psi at some future time" and psi can hold now too. So {psi, F(psi)} is consistent. The seed includes both f_content (the psi values) and implicitly F(psi) through the deferralDisjunctions. Prove no subset of the seed derives contradiction.
- [ ] If Phase 2 identified a novel path: Implement it.
- [ ] Handle the symmetric sorry `constrained_predecessor_seed_restricted_consistent` (SuccChainFMCS.lean:~3685) using the same technique
- [ ] Run `lake build` to verify the sorry is closed

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` (replace sorry at line ~1793 and ~3685, ~100-200 lines)

**Verification**:
- `constrained_successor_seed_restricted_consistent` compiles without sorry
- `constrained_predecessor_seed_restricted_consistent` compiles without sorry
- `lake build` succeeds with no new errors

---

### Phase 4: Verify Sorry Closure Propagation [NOT STARTED]

**Goal**: Verify that closing the seed consistency sorry propagates through the entire proof chain to make `completeness_over_Int` and `discrete_completeness_fc` sorry-free (for this blocker).

**Tasks**:
- [ ] Run `lean_verify` on `constrained_successor_seed_restricted_consistent` — confirm no sorry axioms
- [ ] Run `lean_verify` on `constrained_successor_restricted_f_content_persistence` — confirm no sorry
- [ ] Run `lean_verify` on `restricted_forward_chain_F_resolves` — confirm no sorry
- [ ] Run `lean_verify` on `restricted_forward_chain_forward_F` — confirm no sorry
- [ ] Run `lean_verify` on `build_restricted_tc_family` — confirm no sorry
- [ ] Run `lean_verify` on `completeness_over_Int` — check if sorry-free or if other sorries remain
- [ ] Run `lean_verify` on `discrete_completeness_fc` — check status
- [ ] Run `lean_verify` on `bfmcs_from_mcs_temporally_coherent` — this may still have a sorry (it uses a different path)
- [ ] Document which theorems are now sorry-free and which still have sorries
- [ ] Run full `lake build` to verify no regressions

**Timing**: 1.5 hours

**Files to modify**:
- None (verification only)
- Possibly `Theories/Bimodal/FrameConditions/Completeness.lean` if wiring adjustments needed (~10 lines)

**Verification**:
- `completeness_over_Int` verified sorry-free (or remaining sorries documented)
- `discrete_completeness_fc` verified sorry-free (or remaining sorries documented)
- Full `lake build` succeeds

---

### Phase 5: Completeness Wiring (if needed) [NOT STARTED]

**Goal**: If Phase 4 reveals that `completeness_over_Int` does not automatically become sorry-free (e.g., because it routes through `bfmcs_from_mcs_temporally_coherent` rather than the restricted chain), rewire the proof to use the restricted chain path.

**Tasks**:
- [ ] If `completeness_over_Int` is already sorry-free: skip this phase
- [ ] If not: examine `bundle_validity_implies_provability` to understand the wiring
- [ ] Option A: Fill `bfmcs_from_mcs_temporally_coherent` by showing the SuccChainFMCS families are now temporally coherent (since the restricted chain's forward_F is sorry-free)
- [ ] Option B: Create alternative completeness theorem using `build_restricted_tc_family` -> `restricted_tc_family_to_fmcs` -> canonical model construction, bypassing `bfmcs_from_mcs_temporally_coherent` entirely
- [ ] Wire `completeness_over_Int` to the sorry-free path
- [ ] Run `lake build` and `lean_verify` on completeness theorems

**Timing**: 2.5 hours

**Files to modify**:
- `Theories/Bimodal/FrameConditions/Completeness.lean` (~50-100 lines)
- Possibly `Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean` (if using restricted TC family path)

**Verification**:
- `completeness_over_Int` is sorry-free
- `discrete_completeness_fc` is sorry-free
- `lake build` succeeds

## Testing & Validation

- [ ] `lake build` succeeds with no new sorries in modified files
- [ ] `lean_verify` on `constrained_successor_seed_restricted_consistent` confirms no sorry axioms
- [ ] `lean_verify` on `constrained_predecessor_seed_restricted_consistent` confirms no sorry axioms
- [ ] `lean_verify` on `completeness_over_Int` confirms sorry-free (or documents remaining blockers)
- [ ] `lean_verify` on `discrete_completeness_fc` confirms sorry-free (or documents remaining blockers)
- [ ] Each phase's theorems compile independently (incremental verification)
- [ ] No new axioms introduced (no `axiom` or `sorry` in new code)

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` — Sorry replaced at `constrained_successor_seed_restricted_consistent` (~line 1793) and symmetric predecessor (~line 3685)
- `Theories/Bimodal/FrameConditions/Completeness.lean` — Possible wiring adjustment (Phase 5)
- `specs/081_fp_witness_representation_theorem/summaries/12_execution-summary.md` — Execution summary

## Rollback/Contingency

- All changes are to existing files with well-defined sorry locations. Rollback = restore the sorry.
- If Phase 2 reveals that NO approach works for seed consistency:
  - Fallback A: Redefine `constrained_successor_seed_restricted` to EXCLUDE f_content (removing it from the seed). This makes the seed trivially consistent (all components are subsets of u). Then prove forward_F through the existing `build_targeted_successor` from MCSWitnessSuccessor.lean, which resolves F-obligations one at a time.
  - Fallback B: Replace the entire `restricted_forward_chain` with a new chain using `build_targeted_successor` at each step (as in v11 plan phases 3-6), accepting the F-persistence gap as the new sorry target.
  - Fallback C: Use the research Path C (direct semantic model construction) as a last resort.
- Git tags before each phase enable granular rollback.
