# Implementation Plan: Henkin Chain One-at-a-Time F-Resolution for Sorry-Free completeness_discrete

- **Task**: 202 - Reynolds k-equivalence bypass for sorry-free completeness_discrete
- **Status**: [NOT STARTED]
- **Effort**: 6-10 hours
- **Dependencies**: None (bypasses task 155 entirely)
- **Research Inputs**: specs/202_reynolds_k_equivalence_bypass/reports/01_reynolds-bypass-research.md, specs/202_reynolds_k_equivalence_bypass/reports/02_option-c-pivot-research.md
- **Artifacts**: plans/03_henkin-chain-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Plan v3 replaces the blocked plan v2 (Option C) with a refined Henkin chain strategy. Plan v2's Phase 1 was blocked because all six attempted approaches (simultaneous F-witnesses, successor deferral seed, dovetailing, direct succ_cofinal, stage-based induction, direct restricted_tc) failed due to a common obstacle: under irreflexive strict temporal semantics, G(phi) does not imply phi, so g_content(M) is not a subset of M, and F-persistence through g_content is not guaranteed.

The key insight of plan v3: resolve F-formulas ONE AT A TIME rather than simultaneously. `forward_temporal_witness_seed_consistent` (WitnessSeed.lean, sorry-free) already proves that `{psi} U g_content(M)` is consistent when `F(psi) in M`. This means at each Henkin chain step we can pick ONE unresolved F-formula F(psi), build the seed `{psi} U g_content(mcs(n))`, extend to a full MCS via Lindenbaum, and repeat. Since `deferralClosure(root)` is finite, all F-formulas reachable from the root MCS get resolved within finitely many steps.

This completely sidesteps the blocker: we never need F-persistence through g_content (Approach 4's failure), we never need simultaneous F-witness consistency (Approach 2's failure), and we never need g_content(M) to be a subset of M (Approach 3's failure). Each step uses exactly the already-proved `forward_temporal_witness_seed_consistent`.

### Research Integration

- `reports/01_reynolds-bypass-research.md` (integrated in plan v1): Mapped ~80% complete Reynolds infrastructure, identified `no_gaps_discrete` as sole critical sorry, confirmed `succ_cofinal` is unprovable.
- `reports/02_option-c-pivot-research.md` (integrated in plan v2): Sorry DAG analysis showing `restricted_tc/fuc` -> `succ_embed_surjective` -> `succ_cofinal`. Confirmed `forward_temporal_witness_seed_consistent` is sorry-free and reusable.
- Phase 1 handoff `handoffs/phase-1-handoff-20260529.md` (integrated in plan v3): Documented 6 failed approaches, proved `g_content_consistent` and `h_content_consistent` sorry-free, identified the one-at-a-time resolution strategy as the viable path forward.

### Prior Plan Reference

Plan v1 (`01_reynolds-bypass-plan.md`) had 5 phases targeting the Reynolds pipeline. Phase 3 was completed (sorry-free `one_class_implies_very_good`, `chronicle_is_good_direct`, fc generalization). Phases 1, 2, 4 were blocked. Plan v2 (`02_option-c-plan.md`) pivoted to Henkin chain FMCS on Z. Phase 1 was blocked after 6 approaches failed. Plan v3 refines the Henkin chain approach with the one-at-a-time F-resolution insight.

### Sorry Chain (Root Cause)

```
completeness_discrete
  --> countermodel_discrete_enriched
        |-- cantor_bfmcs_discrete                    [OK]
        |-- cantor_bfmcs_discrete_restricted_tc      [SORRY]
        |     --> succ_embed_surjective              [SORRY]
        |           --> limitDomSubtype_isSuccArchimedean [SORRY]
        |                 --> succ_cofinal           [ROOT SORRY]
        |-- cantor_bfmcs_discrete_restricted_buc     [OK]
        |-- cantor_bfmcs_discrete_restricted_fuc     [SORRY]
        |     --> succ_embed_surjective              [SORRY] (same chain)
        |-- fully_restricted_parametric_completeness_from_neg_membership [OK]
```

Plan v3 eliminates the `succ_embed_surjective` dependency entirely by constructing an FMCS on Z where F/Until witnesses are integers by construction, using `forward_temporal_witness_seed_consistent` one formula at a time.

### Roadmap Alignment

Critical path for sorry-free `completeness_discrete`. Advances "Sorry-free `bx_completeness`" roadmap item. Unblocks task 95 (verification audit), task 176 (chronicle relocation).

## Goals & Non-Goals

**Goals**:
- Build a Henkin chain on Z that resolves F-formulas one at a time using `forward_temporal_witness_seed_consistent`
- Prove the chain resolves ALL F-formulas reachable from the root within |deferralClosure| steps
- Build a sorry-free BFMCS on Z from these chains
- Wire into `countermodel_discrete_enriched` to eliminate `succ_cofinal`
- Achieve `#print axioms completeness_discrete` with no `sorryAx`
- `lake build` passes with zero errors

**Non-Goals**:
- Completing the Reynolds pipeline (no_gaps_discrete, US expressive completeness)
- Proving `succ_cofinal` or `succ_embed_surjective` (bypassed entirely)
- Changing the chronicle construction or the dense case
- Removing plan v1 Phase 3's completed work (it stays as independently useful)
- Addressing dead-code sorries in BXCanonical
- Optimizing proof term size or compilation time

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| G-coherence across Henkin chain steps: G(phi) in mcs(n) must imply phi in mcs(m) for all m > n | H | L | Each step includes g_content(mcs(n)) in the seed, so all G-obligations propagate forward. Lindenbaum extends consistently. Standard induction on m-n. |
| Until-witnessing requires more than one-at-a-time F-resolution | H | M | Until is handled by the standard reduction: U(phi,psi) at step n means either psi holds at n+1 (resolved), or phi and U(phi,psi) hold at n+1 (deferred). Deferral terminates because the Until formula's guard psi must eventually hold (BX axioms ensure Until cannot defer indefinitely in discrete frames). The deferral set is finite. Fallback: use existing sorry-free `restricted_buc` for backward Until and build only forward witnessing. |
| Lindenbaum extension at each step may not preserve F-formula membership from root | M | L | F-formulas from the root propagate through g_content: if F(psi) is in mcs(0) and not yet resolved, then either F(psi) is directly in the seed (if chosen at this step) or F(psi) persists via the MCS closure properties. Key: we track unresolved F-formulas explicitly and resolve them by enumeration order. |
| BFMCS assembly for box-equivalent families is complex | M | M | Follow the exact same pattern as `cantor_bfmcs_discrete`: each box-equivalent MCS N gets its own Henkin chain. Box-equivalence ensures the modal coherence proofs transfer directly. |
| Integration with `countermodel_discrete_enriched` requires signature changes | L | M | The parametric infrastructure is generic over any BFMCS. The new BFMCS is a drop-in replacement for `cantor_bfmcs_discrete`. |
| P-formula witnessing (backward direction) has same structure | M | L | Symmetric: use `past_temporal_witness_seed_consistent` (sorry-free) one P-formula at a time. H-content propagates backward. |

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

### Phase 1: One-at-a-Time Henkin Chain Construction [BLOCKED]

**Goal**: Build the core Henkin chain on Z that resolves F-formulas one at a time, using `forward_temporal_witness_seed_consistent` at each step, and prove G/H coherence and F-resolution for the chain.

**Tasks**:
- [x] Create or extend `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/HenkinDiscreteChain.lean` (add to existing file which already has `g_content_consistent` and `h_content_consistent`) *(completed — extended with analysis documentation)*
- [x] Study `forward_temporal_witness_seed_consistent` in WitnessSeed.lean to confirm the exact signature: given `F(psi) in M`, proves `{psi} U g_content(M)` is consistent *(completed — signature confirmed, fc-polymorphic)*
- [x] Study `past_temporal_witness_seed_consistent` for the symmetric backward case *(completed — symmetric to forward case)*
- [ ] Define `unresolved_F_formulas (root : Set Formula) (phi : Formula) (resolved : Finset Formula) : Finset Formula` -- the F-subformulas of phi reachable from root that have not yet been resolved. Use `deferralClosure phi` to bound the finite set. *(deviation: blocked — F-persistence prevents one-at-a-time resolution)*
- [ ] Define the forward Henkin chain `henkin_forward_mcs : (root : Set Formula) -> (h_mcs : SetMaximalConsistent root) -> (h_discrete : box next_top in root) -> (phi : Formula) -> Nat -> Set Formula` that builds MCS at each natural number step:
  - `henkin_forward_mcs ... 0 = root`
  - For `n+1`: pick the next unresolved F-formula `F(psi)` from the finite enumeration of F-subformulas in `deferralClosure(phi)`. Build seed `{psi} U g_content(henkin_forward_mcs ... n)`. Use `forward_temporal_witness_seed_consistent` to prove consistency (requires `F(psi) in henkin_forward_mcs ... n` -- see next point). Extend to MCS via Lindenbaum.
  - If all F-formulas are resolved by step n, use `g_content(henkin_forward_mcs ... n)` as the seed (which is consistent by `g_content_consistent`).
- [ ] Prove F-formula persistence: if `F(psi) in henkin_forward_mcs ... n` and F(psi) is not resolved at step n, then `F(psi) in henkin_forward_mcs ... (n+1)`. Strategy: F(psi) is in `deferralClosure(phi)`, and g_content propagates membership of formulas reachable from the current MCS. More precisely: `G(neg psi) not in mcs(n)` (since `F(psi) in mcs(n)`), and at step n+1 either we resolve F(psi) directly or the Lindenbaum extension of the g_content seed must include F(psi) since excluding it would yield G(neg psi) in the MCS (by negation completeness), contradicting the parent's F(psi).
  - **Key subtlety**: This argument uses the fact that `F(psi) in deferralClosure(phi)` so both F(psi) and its negation G(neg psi) are in the scope of the restricted MCS. If using full (unrestricted) MCS, negation completeness gives this directly.
- [ ] Prove `henkin_forward_G`: `G(chi) in henkin_forward_mcs ... n -> chi in henkin_forward_mcs ... (n+1)` for all chi. Follows from g_content inclusion in the seed at every step.
- [ ] Prove `henkin_forward_tc`: `F(psi) in henkin_forward_mcs ... 0 -> exists s > 0, psi in henkin_forward_mcs ... s`. By the finite enumeration, F(psi) is assigned a resolution step k <= |deferralClosure(phi)|. At step k, the seed includes psi, so the Lindenbaum extension contains psi.
- [ ] Define the symmetric backward chain for P-formulas and H-coherence (using `past_temporal_witness_seed_consistent`).
- [ ] Prove `henkin_backward_H`: `H(chi) in mcs(n) -> chi in mcs(m)` for all `m < n` (backward direction).
- [ ] Prove `henkin_backward_pc`: `P(psi) in mcs(0) -> exists s < 0, psi in mcs(s)` (using the backward chain).
- [ ] Combine forward and backward chains into a full Z-indexed chain: `henkin_chain_mcs : Z -> Set Formula` mapping integers to MCS values.
- [ ] Verify with `lean_verify` that all new definitions are sorry-free
- [ ] Verify that no dependency on `succ_cofinal`, `succ_embed_surjective`, or `limitDomSubtype_isSuccArchimedean` exists

**BLOCKER** (Phase 1):
- **What failed**: F-formula persistence through the Henkin chain. When building mcs(n+1) as a Lindenbaum extension of `{witness} ∪ g_content(mcs(n))`, F(ψ) ∈ mcs(n) does NOT imply F(ψ) ∈ mcs(n+1). The Lindenbaum extension (via Classical.choice) may arbitrarily include G(¬ψ) instead of F(ψ), since ¬ψ ∉ g_content(mcs(n)) does not prevent the extension from including ¬ψ.
- **What was tried**:
  1. Simple g_content chain (CanonicalModel.lean's bx_fmcs pattern): F(ψ) drops out because Lindenbaum is arbitrary. Confirmed by constructing explicit counterexample: M has p and F(¬p); seed {¬p} ∪ g_content(M) is consistent; extension may include G(p), killing F(¬p) forever.
  2. Augmented seed with F-formulas: `{witness} ∪ g_content(M) ∪ {F(χ) | F(χ) ∈ M, χ ∈ DC}`. The augmented seed g_content(M) ∪ {F(χᵢ)} ⊆ M is consistent. But `{witness} ∪ g_content(M) ∪ {F(χ)}` is NOT necessarily consistent: witness ψ might conflict with F(χ) (e.g., ψ = ¬χ ∧ G(¬χ)).
  3. Multi-family BFMCS (one family per temporal obligation): restricted_tc requires witness in the SAME family, not a different one. BFMCS coherence is per-family.
  4. Schedule-based resolution with infinite visits: schedule visits ψ infinitely often, but F(ψ) may drop out at the first step and never return.
  5. Restricted Lindenbaum within deferralClosure: would give negation completeness within the closure, but the existing truth lemma (`fully_restricted_parametric_completeness_from_neg_membership`) requires full MCS (SetMaximalConsistent), not restricted MCS. Changing to restricted MCS requires rewriting the entire truth lemma infrastructure.
- **Why it's stuck**: The Lindenbaum lemma produces an ARBITRARY maximal consistent extension. There is no way to control WHICH extension is chosen (it's via Classical.choice). F-persistence requires the extension to include F(ψ), but nothing in the seed forces this. The g_content seed only forces the G-propagated formulas; F-formulas are existential and cannot be propagated through g_content.
- **What is needed**: One of:
  (a) A consistency proof for the augmented seed `{ψ} ∪ g_content(M) ∪ {F(χ) | F(χ) ∈ M, χ ∈ DC}` — requires showing that the resolution witness ψ is consistent with all active F-obligations simultaneously. This is a non-trivial proof obligation.
  (b) A restricted MCS truth lemma that works with restricted Lindenbaum extensions — requires significant new infrastructure (restricted FMCS, restricted BFMCS, restricted truth lemma).
  (c) Task 129 (conservative extension from reflexive semantics) — under reflexive semantics, G(φ) → φ holds, making g_content(M) ⊆ M. Then the seed `{ψ} ∪ g_content(M)` is a subset of `{ψ} ∪ M`, and F-persistence follows from the full MCS containing the seed. Transfer to irreflexive via conservative extension.
  (d) A direct proof of `succ_cofinal` by a construction-level gap analysis — show the omega-chain elimination cannot produce gaps in the succ-orbit.
- **Prohibited workarounds**: Do NOT use `sorry`, `def X := True`, or any vacuous placeholder.

**Timing**: 3-5 hours

**Depends on**: none

**Files to modify**:
- Extend: `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/HenkinDiscreteChain.lean` (~300-400 new lines)
- Possibly: `Theories/Bimodal/Metalogic/Bundle/WitnessSeed.lean` (if minor adaptations needed)

**Verification**:
- All `henkin_*` definitions compile with no sorry
- `lean_verify` on each new definition shows no `sorryAx`
- `lake build Bimodal.Metalogic.BXCanonical.Chronicle.HenkinDiscreteChain` passes

**Key mathematical argument -- F-persistence without g_content propagation**:

The plan v2 Approach 4 (dovetailing) failed because F(psi) at step n does not persist to step n+1 through g_content alone -- G(F(psi)) is not derivable from F(psi). The one-at-a-time approach avoids this problem entirely:

1. At step n, `F(psi) in mcs(n)` (given).
2. If step n+1 resolves F(psi), then psi is in the seed, so `psi in mcs(n+1)`.
3. If step n+1 resolves a DIFFERENT formula F(chi), the seed is `{chi} U g_content(mcs(n))`. The resulting MCS (after Lindenbaum) must contain either `F(psi)` or `G(neg psi)` (by negation completeness of MCS). But `G(neg psi) in mcs(n+1)` would require `neg psi in g_content(mcs(n))` (i.e., `G(neg psi) in mcs(n)`), which contradicts `F(psi) in mcs(n)`. So `F(psi) in mcs(n+1)`.

This is the crucial difference: we do NOT need F(psi) to propagate through g_content. We only need that the Lindenbaum extension of the g_content-based seed cannot exclude F(psi) without contradicting the parent MCS.

**IMPORTANT NOTE**: The persistence argument in item 3 above requires careful handling. The Lindenbaum extension is NOT constrained to agree with mcs(n) on formulas outside g_content. The argument works because: (a) all of g_content(mcs(n)) is in the seed, (b) if `G(neg psi) in mcs(n)` then `neg psi in g_content(mcs(n))` is in the seed, (c) from `neg psi` in the seed and psi not in the seed, the Lindenbaum extension could include neg psi, yielding `G(neg psi)` at the next level. But this does NOT happen because `F(psi) = neg G(neg psi)` is in mcs(n) which means `G(neg psi) not in mcs(n)`. So `neg psi not in g_content(mcs(n))`.

Wait -- the issue is more subtle. `neg psi not in g_content(mcs(n))` only means `G(neg psi) not in mcs(n)`. But the Lindenbaum extension of the seed might still include `neg psi` and hence `G(neg psi)` could appear at the NEXT step. The key insight: we do NOT need F(psi) to persist indefinitely. We only need it to persist until the step where it is resolved. Since the enumeration order is fixed and finite, F(psi) will be resolved at step k, and at that step psi is placed in the seed.

Actually, the correct argument is simpler: we do not need F-persistence at all. Instead, we enumerate F-formulas of the ROOT MCS in a fixed order and resolve each one at a predetermined step. Since `forward_temporal_witness_seed_consistent` proves the seed is consistent whenever `F(psi) in mcs(n)`, we need F(psi) to be in the current MCS at its resolution step. This IS guaranteed by the forward G-coherence: if `F(psi) in mcs(0)` and `G(neg psi) not in mcs(0)`, then neg psi is not in g_content(mcs(0)), so the step-1 MCS does not contain `neg psi` from the seed. By MCS negation completeness, `psi in mcs(1)` OR `neg psi in mcs(1)`. If `neg psi in mcs(1)`, this came from Lindenbaum, not from the seed. But that is fine: the key is that at the resolution step k, we PUT psi in the seed, and `forward_temporal_witness_seed_consistent` guarantees the seed `{psi} U g_content(mcs(k-1))` is consistent PROVIDED `F(psi) in mcs(k-1)`.

So the real question is: does `F(psi) in mcs(0)` imply `F(psi) in mcs(k-1)` for all intermediate steps? The argument in step 3 above shows this -- at each step, `neg psi` is not forced into the MCS by the seed (since `G(neg psi) not in` the parent), so the Lindenbaum extension has the freedom to include `F(psi)`. But Lindenbaum does not guarantee it includes F(psi) -- it only guarantees a maximal consistent extension. The extension MIGHT include `G(neg psi)` instead of `F(psi)`.

**Resolution**: To make this rigorous, use RESTRICTED Lindenbaum over `deferralClosure(phi)`. Then at each step, the restricted MCS is maximal within `deferralClosure(phi)`. For F(psi) with `psi in deferralClosure(phi)`, the restricted MCS contains either F(psi) or G(neg psi). By the seed's consistency with the parent MCS's constraints, we can ensure F(psi) persists. Alternatively: build the chain using FULL (unrestricted) MCS and prove persistence via a direct argument about consistency.

The implementation agent should explore both approaches and select whichever leads to cleaner formalization.

---

### Phase 2: Until-Resolution and BFMCS Assembly [NOT STARTED]

**Goal**: Extend the Henkin chain to handle Until-formulas (FUC), build the BFMCS from box-equivalent Henkin chains, and prove all restricted coherence conditions.

**Tasks**:
- [ ] Extend the Henkin chain to resolve Until-formulas: for `U(phi, psi) in mcs(n)`, include the Until deferral in the seed (either `psi` for resolution or `phi /\ U(phi, psi)` for deferral). Use the standard Until induction: the set of active Until-formulas is finite (bounded by `deferralClosure`), and each deferral step preserves the Until formula while progressing toward resolution.
- [ ] Prove `henkin_restricted_fuc`: `U(phi, psi) in henkin_chain_mcs ... 0 -> exists s > 0, psi in henkin_chain_mcs ... s /\ forall r, 0 < r < s -> phi in henkin_chain_mcs ... r`.
  - Strategy: enumerate Until-formulas alongside F-formulas in the resolution schedule. Within |deferralClosure| steps, every Until must resolve because the BX axioms ensure discrete Until cannot defer indefinitely.
- [ ] Prove symmetric backward Until/Since resolution (BUC): adapt existing sorry-free `restricted_buc` pattern or prove from backward chain properties.
- [ ] Define `henkin_bfmcs_discrete` analogous to `cantor_bfmcs_discrete`:
  - Families parameterized by `(N : Set Formula, s : Int)` where N is a discrete MCS box-equivalent to root A
  - Each family's chain: `henkin_chain_mcs N h_mcs h_discrete phi (t - s)` at position t
  - Finite family count (bounded by box-equivalence classes)
- [ ] Prove modal coherence for the new BFMCS:
  - `henkin_bfmcs_modal_forward`: box(chi) in fam.mcs(t) -> chi in fam'.mcs(t) for all box-equivalent fam'
  - `henkin_bfmcs_modal_backward`: chi in fam'.mcs(t) for all box-equivalent fam' -> box(chi) in fam.mcs(t)
- [ ] Wire restricted coherence proofs into BFMCS:
  - `henkin_bfmcs_restricted_tc` from Phase 1's `henkin_forward_tc`
  - `henkin_bfmcs_restricted_fuc` from this phase's Until resolution
  - `henkin_bfmcs_restricted_buc` from backward Until resolution
- [ ] Verify the BFMCS satisfies all hypotheses of `fully_restricted_parametric_completeness_from_neg_membership`
- [ ] Verify with `lean_verify` that the BFMCS and all coherence proofs are sorry-free

**Timing**: 2-3 hours

**Depends on**: 1

**Files to modify**:
- Extend: `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/HenkinDiscreteChain.lean` (~150-250 new lines)

**Verification**:
- `henkin_bfmcs_discrete` compiles with no sorry
- All restricted coherence proofs (tc, fuc, buc) compile with no sorry
- `lean_verify` on each shows no `sorryAx`
- No dependency on `succ_cofinal`, `succ_embed_surjective`, or `limitDomSubtype_isSuccArchimedean`

---

### Phase 3: Wire into completeness_discrete [NOT STARTED]

**Goal**: Replace the sorry-producing `countermodel_discrete_enriched` with a version using the Henkin BFMCS, making `completeness_discrete` sorry-free.

**Tasks**:
- [ ] Create `countermodel_discrete_henkin` that:
  1. Takes MCS A with `neg phi in A` and `box(next_top) in A`
  2. Builds `henkin_bfmcs_discrete A` from Phase 2
  3. Passes the three sorry-free restricted coherence proofs (tc, fuc, buc) to `fully_restricted_parametric_completeness_from_neg_membership`
  4. Returns the countermodel (TaskFrame Int + valuation + point where phi fails)
- [ ] Update `countermodel_discrete_enriched` in `Completeness.lean` to call the Henkin version instead of `cantor_bfmcs_discrete`:
  - Replace `cantor_bfmcs_discrete` with `henkin_bfmcs_discrete`
  - Replace `cantor_bfmcs_discrete_restricted_tc` with `henkin_bfmcs_restricted_tc`
  - Replace `cantor_bfmcs_discrete_restricted_fuc` with `henkin_bfmcs_restricted_fuc`
  - Keep `cantor_bfmcs_discrete_restricted_buc` OR replace with `henkin_bfmcs_restricted_buc`
  - Update the rooted FMCS reference (`rooted_succ_discrete_fmcs` -> Henkin chain equivalent)
- [ ] Alternatively: create a NEW `countermodel_discrete_enriched_v2` and update the `completeness_discrete` call site to use it (lower risk, preserves old code for reference)
- [ ] Verify `completeness_discrete` compiles with no sorry
- [ ] Verify `completeness_dense` still compiles with no sorry (uses separate code path)
- [ ] Check that no other definitions are broken

**Timing**: 1-2 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` (rewire `countermodel_discrete_enriched`)
- Possibly: `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean` (update `countermodel_discrete` delegation)

**Verification**:
- `lean_verify Bimodal.Metalogic.BXCanonical.completeness_discrete` shows no `sorryAx`
- `lean_verify Bimodal.Metalogic.BXCanonical.completeness_dense` still shows no `sorryAx`
- `lake build Bimodal.Metalogic.BXCanonical.Completeness` passes

---

### Phase 4: Full Build Verification and Cleanup [NOT STARTED]

**Goal**: Full build verification, axiom audit, and documentation update.

**Tasks**:
- [ ] Run `lake build` (full project build, all modules)
- [ ] Run `lean_verify Bimodal.Metalogic.BXCanonical.completeness_discrete` and confirm no `sorryAx`
- [ ] Run `lean_verify Bimodal.Metalogic.BXCanonical.completeness_dense` and confirm still sorry-free
- [ ] Check `#print axioms completeness_discrete` output (should show only standard Lean axioms: propext, Classical.choice, Quot.sound, Lean.ofReduceBool, Lean.trustCompiler)
- [ ] If any sorries remain in the chain, trace and fix them
- [ ] Evaluate dead code status of `succ_cofinal`, `succ_embed_surjective`, `limitDomSubtype_isSuccArchimedean`, `cantor_bfmcs_discrete_restricted_tc`, `cantor_bfmcs_discrete_restricted_fuc`:
  - If still used by other live paths: leave them
  - If dead: mark with `-- DEAD CODE (Henkin chain bypass)` comment
- [ ] Update `#print axioms` comment in Completeness.lean to reflect sorry-free status
- [ ] Update `specs/ROADMAP.md`: sorry count, critical path status

**Timing**: 1-2 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` (axiom audit comments)
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` (dead code markers)
- `specs/ROADMAP.md` (sorry count, critical path)

**Verification**:
- `lake build` passes with zero errors
- `lean_verify Bimodal.Metalogic.BXCanonical.completeness_discrete` shows NO `sorryAx`
- `#print axioms completeness_discrete` matches expected output (standard Lean axioms only)
- ROADMAP.md accurately reflects sorry-free status

---

## Prior Plan Phases (Preserved Work)

The following work from plan v1 Phase 3 was completed and remains in the codebase. It is NOT on the critical path for plan v3 but is independently valuable:

- **`one_class_implies_very_good`** (ShiftAndGlue.lean, sorry-free)
- **`chronicle_is_good_direct`** (ShiftAndGlue.lean, has sorry via no_gaps_discrete)
- **fc generalization** (NEquivalence.lean, ShiftAndGlue.lean, Transfer.lean, TruthLemma.lean, sorry-free)
- **`countermodel_discrete_reynolds`** (Transfer.lean, has sorry)

From plan v2 implementation attempt:

- **`g_content_consistent`** (HenkinDiscreteChain.lean, sorry-free): g_content(M) is consistent for any MCS
- **`h_content_consistent`** (HenkinDiscreteChain.lean, sorry-free): h_content(M) is consistent for any MCS

## Testing & Validation

- [ ] `henkin_forward_mcs` compiles without sorry
- [ ] `henkin_forward_G` (G-coherence) compiles without sorry
- [ ] `henkin_forward_tc` (F-resolution) compiles without sorry
- [ ] F-formula persistence across chain steps compiles without sorry
- [ ] `henkin_restricted_fuc` (Until-resolution) compiles without sorry
- [ ] `henkin_bfmcs_discrete` compiles without sorry with all coherence proofs
- [ ] `lean_verify` on the new countermodel function shows no `sorryAx`
- [ ] `lean_verify Bimodal.Metalogic.BXCanonical.completeness_discrete` shows no `sorryAx`
- [ ] `lean_verify Bimodal.Metalogic.BXCanonical.completeness_dense` still shows no `sorryAx`
- [ ] `lake build` passes with zero errors
- [ ] No new sorries introduced anywhere in the codebase

## Artifacts & Outputs

- `specs/202_reynolds_k_equivalence_bypass/plans/03_henkin-chain-plan.md` (this file)
- Modified: `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/HenkinDiscreteChain.lean` (~400-600 new lines)
- Modified: `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` (countermodel rewiring + axiom audit)
- Modified: `specs/ROADMAP.md` (sorry count, critical path)
- Possibly modified: `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean` (delegation update)

## Rollback/Contingency

If plan v3 proves infeasible:

1. **F-persistence fallback**: If the F-persistence argument is too complex, use RESTRICTED Lindenbaum within `deferralClosure(phi)` where negation completeness within the closure guarantees persistence. This trades generality for simpler proofs.

2. **Until fallback**: If Until-resolution is harder than F-resolution, use the existing sorry-free `restricted_buc` (backward Until is already sorry-free) and focus only on forward Until. The forward Until deferral mechanism in discrete frames is well-understood (BX axioms ensure progress).

3. **Partial rollback**: All new code extends HenkinDiscreteChain.lean. The countermodel rewiring in Completeness.lean is a localized change. Revert the countermodel function to restore the original `cantor_bfmcs_discrete` path.

4. **Reynolds pipeline fallback**: Return to task 155 and invest in US expressive completeness over Prior structures (8-12h).

5. **Task 129**: Weak/reflexive completeness + conservative extension. Under reflexive semantics, the entire Henkin chain construction becomes trivial (g_content(M) is a subset of M).
