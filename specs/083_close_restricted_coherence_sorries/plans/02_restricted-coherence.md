# Implementation Plan: Close Restricted Coherence Sorries (v2)

- **Task**: 83 - Close Restricted Coherence Sorries
- **Status**: [NOT STARTED]
- **Effort**: 14-20 hours
- **Dependencies**: None (Phase 2 infrastructure from v1 plan is in place)
- **Research Inputs**: specs/083_close_restricted_coherence_sorries/reports/02_blocker-analysis.md, specs/083_close_restricted_coherence_sorries/reports/01_team-research.md
- **Artifacts**: plans/02_restricted-coherence.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Close the 2 remaining sorries (`succ_chain_restricted_forward_F` and `succ_chain_restricted_backward_P` in UltrafilterChain.lean) that block sorry-free canonical completeness over Int. Round 2 research established that these sorries are **unprovable on the existing `succ_chain_fam` construction** because Lindenbaum extensions can perpetually defer F-obligations. The plan replaces `SuccChainFMCS` with a new `ResolvingFMCS` in the `boxClassFamilies` definition, where each family uses a targeted chain with an enriched seed containing deferral disjunctions. This ensures F/P-resolution by construction. The completeness path is rewired through the new bundle while the original sorry theorems are marked as bypassed.

### Research Integration

- **Round 2 report** (02_blocker-analysis.md): Established that (1) existing sorries are unprovable for `succ_chain_fam`, (2) the Phase 2 TargetedChain has a multi-target F-persistence gap, (3) deferral disjunctions in the seed are the correct mechanism for F-persistence, (4) the blocking relation is acyclic (new insight), and (5) the recommended approach is replacing the chain construction entirely.
- **Round 1 report** (01_team-research.md): Confirmed the FALSE theorem chain, dead code identification, and G-lift gap as universal bottleneck.
- **v1 implementation summary**: Phases 1-2 complete (dead code cleanup, TargetedChain.lean created with sorry-free forward_G/backward_H). Phase 3 blocked on multi-target F-persistence.

## Goals & Non-Goals

**Goals**:
- Achieve sorry-free `completeness_over_Int` and `discrete_completeness_fc`
- Build a new `ResolvingFMCS` that has both forward_G/backward_H (from TargetedChain infrastructure) AND restricted forward_F/backward_P (from enriched deferral seed)
- Replace `boxClassFamilies` to use `ResolvingFMCS` instead of `SuccChainFMCS`
- Mark the original sorry theorems as bypassed (not needed on new path)
- Clean `lake build` with zero errors

**Non-Goals**:
- Proving the original `succ_chain_restricted_forward_F` on `succ_chain_fam` (confirmed unprovable)
- Closing `bfmcs_from_mcs_temporally_coherent` (unrestricted coherence; not needed)
- Closing `dense_completeness` (separate task)
- Proving the acyclicity of the blocking relation in Lean (not needed for the chosen approach)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Enriched deferral seed consistency proof fails | H | M | The seed `{target} union g_content(M) union {chi v F(chi) | F(chi) in M, chi in DC}` has all non-target elements in M (deferral disjunctions are provable from F(chi) via weakening). If direct consistency proof fails, fall back to proving it via the existing `forward_temporal_witness_seed_consistent` plus MCS closure properties. |
| F-persistence across targeted steps cannot be proved | H | L | Deferral disjunctions in the enriched seed guarantee `chi in W or F(chi) in W` for each pending obligation. This is a direct consequence of the disjunction being in the Lindenbaum seed. The challenge is only the consistency of the enriched seed. |
| Round-robin scheduling doesn't terminate F-obligations in bounded steps | M | L | With N = |deferralClosure(root)| targets and round-robin scheduling, each obligation is targeted within N steps. When targeted, the deferral disjunction resolves to either chi (done) or F(chi) (deferred). The bounded F-nesting depth within deferralClosure ensures termination within N rounds. |
| `boxClassFamilies` replacement breaks modal coherence properties | M | L | The modal properties (`modal_forward`, `modal_backward`, `bundle_forward_F`, `bundle_backward_P`) depend on `box_class_agree` and `temporal_theory_witness_exists`, which are properties of MCSes, not of the specific chain construction. The replacement only changes the family type; the bundle-level properties port directly. |
| `construct_bfmcs_bundle_eval_at_zero` breaks | H | L | The eval family must have mcs(0) = M0. Since `ResolvingFMCS` uses `targeted_fam` with base M0, `targeted_fam_zero` gives mcs(0) = M0. Direct. |

## Implementation Phases

### Phase 1: Enriched Deferral Seed and Consistency [BLOCKED]

**Goal**: Define the enriched targeted seed that includes deferral disjunctions for F-persistence, and prove it is consistent.

**Mathematical content**:

The enriched seed for resolving target psi given MCS M and formula set DC:
```
enriched_seed(M, psi, DC) = {psi} union g_content(M) union {chi v F(chi) | F(chi) in M, chi in DC}
```

Consistency proof when `F(psi) in M`:
- Every element of `g_content(M)` is phi where `G(phi) in M`, so `phi in M` by T-axiom.
- Every deferral disjunction `chi v F(chi)`: since `F(chi) in M`, by weakening `F(chi) -> chi v F(chi)`, so `chi v F(chi) in M`.
- Thus `g_content(M) union deferral_disjunctions subset M`.
- Suppose `L subset enriched_seed, L derives bot`.
  - If `psi not in L`: all of `L subset M`, contradicting M consistent.
  - If `psi in L`: `L \ {psi} derives neg(psi)`. Since `L \ {psi} subset M`, we get `neg(psi) in M` by MCS closure. Now `L \ {psi}` contains elements from g_content(M) and deferral disjunctions, ALL of which are in M. So the derivation `L \ {psi} |- neg(psi)` can be G-lifted on the g_content part. BUT deferral disjunctions are NOT G-liftable.
  - **Key argument**: Replace each deferral disjunction `chi v F(chi)` in L with `F(chi)` (which is in M and implies `chi v F(chi)`). This gives a new derivation `L' |- neg(psi)` where `L' subset {psi} union g_content(M) union {F(chi_i)}`. Since `{F(chi_i)} subset M` and `g_content(M) subset M`, we have `L' \ {psi} subset M`, so `neg(psi) in M`. Now deduct all the F-formulas: `g_content(M) |- F(chi_1) -> ... -> F(chi_k) -> neg(psi)`. By generalized temporal K: `G(F(chi_1) -> ... -> neg(psi)) in M`. By T: `F(chi_1) -> ... -> neg(psi) in M`. By modus ponens: `neg(psi) in M` (which we already know).
  - This does NOT give a contradiction. So we cannot G-lift to contradict F(psi).
  - **Alternative approach**: Do NOT try to prove enriched seed consistency from scratch. Instead, observe that the standard `forward_temporal_witness_seed` is `{psi} union g_content(M)`, which is already proven consistent. The Lindenbaum extension of this seed produces W with `psi in W` and `g_content(M) subset W`. The deferral disjunctions `chi v F(chi)` for `F(chi) in M` are **provable in TM from F(chi)**: by `F(chi) -> chi v F(chi)` (right weakening of disjunction). Since `F(chi) in M` and the Lindenbaum extension W is an MCS extending `{psi} union g_content(M)`, we need to show `chi v F(chi) in W`.
  - This requires: does `F(chi) in W`? Not necessarily -- W extends `{psi} union g_content(M)`, and `F(chi)` is not in g_content(M) unless `G(F(chi)) in M`.
  - **Correct approach**: Use the enriched seed directly in Lindenbaum, not as a post-hoc property. Define `enriched_forward_temporal_witness_seed M psi DC` and prove its consistency. The proof: suppose inconsistent. Take finite L subset seed with L |- bot. Partition L = {psi} union L_G union L_D. All of L_G union L_D are in M (shown above). If psi not in L, L subset M, contradiction. If psi in L, L_G union L_D |- neg(psi). All of L_G union L_D subset M, so neg(psi) in M. This is fine (neg(psi) coexists with F(psi)). But then {psi} union L_G union L_D |- bot means L_G union L_D |- neg(psi), and we need {psi, neg(psi)} to derive bot. Which it does. So the question is: does L_G union L_D actually derive neg(psi)?
  - Since L_G union L_D subset M and M is an MCS, either neg(psi) in M or psi in M. If psi in M, done trivially (target already resolved). If neg(psi) in M, then neg(psi) is in M but NOT necessarily derivable from the SPECIFIC FINITE subset L_G union L_D.
  - **The correct formal argument**: Suppose the enriched seed is inconsistent. Then exists finite L subset seed with L |- bot. Separate L into {psi} (if present) and L_rest. Case 1: psi not in L. Then L subset g_content(M) union deferral_disj subset M. M consistent, contradiction. Case 2: psi in L. Then L_rest |- neg(psi). L_rest subset M. Since M is MCS and L_rest subset M derives neg(psi), we have neg(psi) in M. Now: `{psi} union g_content(M)` is consistent (by `forward_temporal_witness_seed_consistent`). But L_rest subset g_content(M) union deferral_disj. If L_rest subset g_content(M), then g_content(M) |- neg(psi), contradicting `forward_temporal_witness_seed_consistent`. So L_rest must include some deferral disjunction d_i = chi_i v F(chi_i) not in g_content(M). In M, d_i holds. But d_i is NOT in g_content(M) (d_i is not of form G(something) in M). So the derivation of neg(psi) REQUIRES the deferral disjunctions, not just g_content.
  - **Summary**: The enriched seed consistency proof requires showing that deferral disjunctions from M cannot combine with g_content and {psi} to produce a contradiction beyond what g_content and {psi} alone produce. This is the core mathematical lemma.

**Lean implementation strategy**: Define the enriched seed. Attempt the consistency proof. If the direct proof is too complex, use the alternative: build the Lindenbaum extension from `forward_temporal_witness_seed` (proven consistent) and then prove the deferral properties as consequences of MCS properties of W.

**Tasks**:
- [ ] Define `enriched_forward_seed M psi DC := {psi} union g_content(M) union {chi.or (chi.some_future) | F(chi) in M, chi in DC}` in TargetedChain.lean
- [ ] Define `enriched_backward_seed M psi DC` symmetrically
- [ ] Prove `deferral_disjunction_in_mcs`: if `F(chi) in M` and M is MCS, then `chi v F(chi) in M`
- [ ] Prove `enriched_forward_seed_subset_M_union_target`: all elements of enriched seed are either psi or in M
- [ ] Attempt direct consistency proof: `F(psi) in M -> SetConsistent (enriched_forward_seed M psi DC)`
- [ ] If direct proof blocked: use `forward_temporal_witness_seed_consistent` as base, then show Lindenbaum extension W of `{psi} union g_content(M)` satisfies deferral properties (since W is MCS, either chi in W or neg(chi) in W; since F(chi) and neg(chi) are consistent, F(chi) can be in W; but we need chi v F(chi) in W)
- [ ] Prove symmetric `enriched_backward_seed_consistent`

**Timing**: 3-4 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/TargetedChain.lean` -- add enriched seed definitions and consistency proofs

**Verification**:
- `lake build` passes
- `lean_verify` on enriched seed consistency theorems shows no sorry

---

### Phase 2: Resolving Chain with F-Persistence [NOT STARTED]

**Goal**: Build a new chain construction (`resolving_forward_chain`) that uses the enriched seed, providing both g_content persistence (for forward_G) and deferral disjunction membership (for F-persistence).

**Mathematical content**:

The resolving chain builds successors using the enriched seed:
```
resolving_successor(M, target, DC) = Lindenbaum(enriched_forward_seed(M, target, DC))
```

Properties of `W = resolving_successor(M, target, DC)` when `F(target) in M`:
1. `W is MCS` (Lindenbaum output)
2. `target in W` (target in seed, seed subset W)
3. `g_content(M) subset W` (g_content in seed, seed subset W)
4. For each chi in DC with F(chi) in M: `chi in W or F(chi) in W` (deferral disjunction `chi v F(chi)` in seed, W is MCS)

Property 4 is the **F-persistence guarantee**: non-target F-obligations either resolve (chi in W) or persist (F(chi) in W).

The resolving chain with round-robin:
```
resolving_forward_chain(M0, targets, DC, 0) = M0
resolving_forward_chain(M0, targets, DC, n+1) =
  resolving_successor(chain(n), schedule(targets, n), DC)
```

**Tasks**:
- [ ] Define `resolving_forward_successor M h_mcs target DC h_F` using enriched seed + Lindenbaum
- [ ] Prove `resolving_forward_successor_mcs`
- [ ] Prove `resolving_forward_successor_resolves`: target in successor when F(target) in M
- [ ] Prove `resolving_forward_successor_g_persistence`: g_content(M) subset successor
- [ ] Prove `resolving_forward_successor_deferral`: for chi in DC, F(chi) in M implies chi in successor or F(chi) in successor
- [ ] Define `resolving_forward_chain` with round-robin scheduling over DC targets
- [ ] Prove `resolving_forward_chain_mcs`
- [ ] Prove `resolving_forward_chain_g_step`: g_content(chain(n)) subset chain(n+1)
- [ ] Define `resolving_backward_chain` symmetrically using enriched backward seed
- [ ] Define `resolving_fam` combining forward and backward chains (Int-indexed)
- [ ] Prove `resolving_fam_mcs`, `resolving_fam_zero`
- [ ] Prove `resolving_fam_G_step` and `resolving_fam_H_step`

**Timing**: 3-4 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/TargetedChain.lean` -- add resolving chain construction

**Verification**:
- `lake build` passes
- All resolving chain theorems sorry-free

---

### Phase 3: Restricted F/P Resolution Proof [NOT STARTED]

**Goal**: Prove that the resolving chain resolves all F-obligations for deferralClosure formulas within bounded steps, using the deferral property and round-robin scheduling.

**Mathematical content**:

Given `F(psi) in resolving_fam(n)` with `psi in DC` where `|DC| = N`:
1. At each step, the deferral property ensures: either psi resolves (psi in chain(n+1)) or F(psi) persists (F(psi) in chain(n+1)).
2. With round-robin scheduling, psi is targeted at step `m = n + ((idx(psi) - n) mod N)` (within N steps).
3. At step m, if F(psi) still holds (persisted by deferral property through m-n steps), then `psi in chain(m+1)` by the resolves property.
4. Key lemma: F-persistence chains through multiple steps. If `F(psi) in chain(n)` and psi is not the target at steps n, n+1, ..., n+k-1, then `F(psi) in chain(n+k)` (by induction using the deferral property at each step: either psi resolves or F(psi) persists; if psi is not targeted, the deferral disjunction still forces chi v F(chi), and since the target resolution doesn't directly force neg(psi), F(psi) typically persists -- but we need this formally).
5. **Critical subtlety**: The deferral property gives `psi in W or F(psi) in W`, but psi resolving at a non-targeted step is ALSO acceptable (it means the obligation is resolved early).

The F-persistence lemma: `F(chi) in chain(n), chi in DC -> chi in chain(n+1) or F(chi) in chain(n+1)`.

This follows directly from `resolving_forward_successor_deferral`.

The forward_F theorem: `F(psi) in resolving_fam(n), psi in DC -> exists m >= n, psi in resolving_fam(m)`.

Proof by strong induction on the number of steps until psi is next scheduled:
- At each step k >= n: either psi in chain(k) (done) or F(psi) in chain(k) (continue).
- When psi is scheduled at step m: F(psi) in chain(m) -> psi in chain(m+1). Done.
- F(psi) persists from n to m by the deferral property applied at each intermediate step.

**Tasks**:
- [ ] Prove `resolving_forward_chain_deferral_step`: F(chi) in chain(n), chi in DC -> chi in chain(n+1) or F(chi) in chain(n+1)
- [ ] Prove `resolving_forward_chain_F_persistence`: F(chi) in chain(n), chi in DC -> forall k, n <= k -> chi in chain(k) or F(chi) in chain(k)` (induction on k-n using deferral_step)
- [ ] Prove `resolving_forward_chain_forward_F`: F(psi) in chain(n), psi in DC, psi in targets -> exists m >= n, psi in chain(m) (using persistence + scheduling)
- [ ] Prove `resolving_fam_forward_G`: G(phi) at t implies phi at all t' >= t (from g_step, same pattern as targeted_fam_forward_G)
- [ ] Prove `resolving_fam_backward_H`: H(phi) at t implies phi at all t' <= t
- [ ] Prove `resolving_fam_restricted_forward_F`: F(psi) at t, psi in DC -> exists s >= t, psi at s
- [ ] Prove `resolving_fam_restricted_backward_P`: P(psi) at t, psi in DC -> exists s <= t, psi at s
- [ ] Construct `ResolvingFMCS`: FMCS with forward_G and backward_H

**Timing**: 3-5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/TargetedChain.lean` -- add F/P resolution proofs

**Verification**:
- `lake build` passes
- `lean_verify` on `resolving_fam_restricted_forward_F` shows no sorry
- `lean_verify` on `ResolvingFMCS` shows no sorry

---

### Phase 4: Replace boxClassFamilies and Rewire Completeness [NOT STARTED]

**Goal**: Define a new `resolvingBoxClassFamilies` using `ResolvingFMCS` instead of `SuccChainFMCS`, prove all BFMCS_Bundle properties, and rewire the completeness theorem.

**Mathematical content**:

The new bundle families:
```
resolvingBoxClassFamilies M0 h_mcs root = { f | exists W h_W k,
  box_class_agree M0 W /\
  f = shifted_fmcs (ResolvingFMCS W h_W (deferralClosure root).toList) k }
```

Key properties to port from existing `boxClassFamilies`:
1. `nonempty` -- trivial (M0 with k=0)
2. `modal_forward` -- Box(phi) in one family implies Box(phi) in all (uses box_class_agree)
3. `modal_backward` -- contrapositive of modal_forward
4. `bundle_forward_F` -- F(phi) in fam.mcs(t) implies exists witness family with phi at t+1 (uses `temporal_theory_witness_exists` which gives box_class_agree and phi in W; build ResolvingFMCS from W)
5. `bundle_backward_P` -- symmetric
6. `eval_family_mem` -- eval family is in the set
7. `eval_at_zero` -- eval family at 0 is M0
8. `restricted_temporally_coherent` -- each family has restricted forward_F/backward_P for deferralClosure formulas (uses Phase 3 results)

The completeness rewiring:
- Define `construct_resolving_bfmcs_bundle`
- Prove `resolving_bfmcs_restricted_temporally_coherent` (delegates to Phase 3 F/P resolution)
- Rewire `restricted_bundle_validity_implies_provability` to use the new bundle (or define a new version)
- Update `completeness_over_Int` to use the new path
- Mark original sorry theorems as BYPASSED

**Tasks**:
- [ ] Define `resolvingBoxClassFamilies M0 h_mcs root`
- [ ] Prove `resolvingBoxClassFamilies_nonempty`
- [ ] Prove `resolvingBoxClassFamilies_modal_forward` (port from existing proof; same argument since box_class_agree is MCS-level, not chain-level)
- [ ] Prove `resolvingBoxClassFamilies_modal_backward`
- [ ] Prove `resolvingBoxClassFamilies_bundle_forward_F` (use `temporal_theory_witness_exists` then build `ResolvingFMCS` from witness)
- [ ] Prove `resolvingBoxClassFamilies_bundle_backward_P`
- [ ] Prove `resolvingBoxClassFamilies_box_agree_at_time` (box_class_agree preserved along resolving chain)
- [ ] Define `construct_resolving_bfmcs_bundle`
- [ ] Prove `construct_resolving_bfmcs_bundle_eval_at_zero`
- [ ] Prove `resolving_bfmcs_restricted_temporally_coherent root`
- [ ] Define or rewire `resolving_completeness_over_Int` using the new bundle
- [ ] Update `completeness_over_Int` to delegate to the resolving path
- [ ] Mark `succ_chain_restricted_forward_F` and `succ_chain_restricted_backward_P` as BYPASSED in docstrings

**Timing**: 3-4 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/TargetedChain.lean` -- new bundle construction
- `Theories/Bimodal/FrameConditions/Completeness.lean` -- rewire completeness path
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` -- BYPASSED annotations on sorry theorems

**Verification**:
- `lake build` passes
- `lean_verify` on `completeness_over_Int` shows no sorry
- `lean_verify` on `discrete_completeness_fc` shows no sorry

---

### Phase 5: Verification, Cleanup, and Documentation [NOT STARTED]

**Goal**: Full verification that the completeness path is sorry-free, cleanup of dead code, and documentation updates.

**Tasks**:
- [ ] Run `lake build` and verify zero errors
- [ ] Run `lean_verify` on `completeness_over_Int` -- confirm no sorry axioms
- [ ] Run `lean_verify` on `discrete_completeness_fc` -- confirm no sorry axioms
- [ ] Run `lean_verify` on `resolving_bfmcs_restricted_temporally_coherent` -- confirm no sorry
- [ ] Grep for `sorry` in Completeness.lean -- confirm only in `bfmcs_from_mcs_temporally_coherent` (unrestricted path) and `dense_completeness`
- [ ] Grep for `sorry` in TargetedChain.lean -- confirm zero matches
- [ ] Update docstrings:
  - `succ_chain_restricted_forward_F`: BYPASSED -- replaced by resolving chain construction
  - `succ_chain_restricted_backward_P`: BYPASSED -- replaced by resolving chain construction
  - `bfmcs_restricted_temporally_coherent`: note it now uses the resolving path
  - `completeness_over_Int`: note sorry-free status
- [ ] Add module documentation to TargetedChain.lean for the resolving chain section
- [ ] Verify `discrete_completeness_fc` delegates correctly through `completeness_over_Int`

**Timing**: 1-2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/TargetedChain.lean` -- documentation
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` -- BYPASSED annotations
- `Theories/Bimodal/FrameConditions/Completeness.lean` -- updated docstrings

**Verification**:
- `lake build` passes with zero warnings
- `lean_verify completeness_over_Int` shows no sorry axiom
- All sorry occurrences in modified files are accounted for (dead code, FALSE-annotated, or BYPASSED)

## Testing & Validation

- [ ] `lake build` passes with zero errors
- [ ] `lean_verify` on `Bimodal.FrameConditions.Completeness.completeness_over_Int` shows no sorry
- [ ] `lean_verify` on `Bimodal.FrameConditions.Completeness.discrete_completeness_fc` shows no sorry
- [ ] `lean_verify` on `Bimodal.Metalogic.Bundle.TargetedChain.ResolvingFMCS` shows no sorry
- [ ] grep for `sorry` in `Completeness.lean` returns only `bfmcs_from_mcs_temporally_coherent` (unrestricted, unused) and `dense_completeness`
- [ ] grep for `sorry` in `TargetedChain.lean` returns zero matches
- [ ] grep for `sorry` in `UltrafilterChain.lean` -- the 2 bypassed sorries remain but are not on the completeness path

## Artifacts & Outputs

- `specs/083_close_restricted_coherence_sorries/plans/02_restricted-coherence.md` (this file)
- Modified: `Theories/Bimodal/Metalogic/Bundle/TargetedChain.lean` (enriched seed, resolving chain, FMCS, bundle)
- Modified: `Theories/Bimodal/FrameConditions/Completeness.lean` (rewired completeness path)
- Modified: `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` (BYPASSED annotations)
- `specs/083_close_restricted_coherence_sorries/summaries/02_restricted-coherence-summary.md` (after implementation)

## Rollback/Contingency

**If Phase 1 fails (enriched seed consistency cannot be proven)**:
- Fall back to a two-pass construction: first pass builds the targeted chain (already sorry-free for g_content), second pass proves deferral properties using MCS membership analysis rather than seed consistency. Specifically: show that `canonical_forward_F` witness W (which is a Lindenbaum extension of `{psi} union g_content(M)`) is an MCS, and therefore for any `F(chi) in M`, either `chi in W` or `neg(chi) in W`. If `neg(chi) in W`, then `G(neg(chi)) in W` is NOT forced (W only extends `{psi} union g_content(M)`, not arbitrary elements). So `F(chi)` might or might not be in W.
- Alternative: use a custom Lindenbaum variant that starts from a larger seed and explicitly includes deferral disjunctions in the enumeration ordering.
- Estimated additional effort: 6-10 hours.

**If Phase 4 fails (cannot port bundle properties)**:
- Simplify by proving completeness directly from a single resolving family without going through the multi-family BFMCS bundle. The `restricted_shifted_truth_lemma` can be adapted to work with a single-family structure if we can prove modal coherence differently.
- Estimated additional effort: 4-6 hours.

**Full rollback**:
- `git revert` all commits from this round.
- The 2 original sorries remain; completeness depends on them as before.
- Phase 1-2 infrastructure from v1 (TargetedChain.lean) is preserved.
