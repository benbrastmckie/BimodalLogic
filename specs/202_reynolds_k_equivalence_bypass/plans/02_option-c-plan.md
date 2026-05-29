# Implementation Plan: Option C -- Henkin Chain FMCS on Z for Sorry-Free completeness_discrete

- **Task**: 202 - Reynolds k-equivalence bypass for sorry-free completeness_discrete
- **Status**: [NOT STARTED]
- **Effort**: 8-12 hours
- **Dependencies**: None (bypasses task 155 entirely)
- **Research Inputs**: specs/202_reynolds_k_equivalence_bypass/reports/01_reynolds-bypass-research.md, specs/202_reynolds_k_equivalence_bypass/reports/02_option-c-pivot-research.md
- **Artifacts**: plans/02_option-c-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Pivot from the Reynolds k-equivalence pipeline to a direct Henkin chain construction on Z. The Reynolds approach hit two independent architectural blockers: (1) US expressive completeness over Prior structures requires 8-12h of complex mathematical formalization (Phase 1), and (2) `zIntervalTaskFrame` uses `WorldState=Unit` which is fundamentally incompatible with position-dependent atom truth needed by `temporal_truth` (Phase 4). Option C bypasses both blockers by building a fresh FMCS directly on Z using Henkin-style Lindenbaum extensions at each integer step, making `restricted_tc` (F-resolution) and `restricted_fuc` (Until-resolution) trivial by construction. This replaces the chronicle-based FMCS whose coherence proofs require the unprovable `succ_embed_surjective`.

### Research Integration

- `reports/01_reynolds-bypass-research.md` (integrated in plan v1): Mapped the ~80% complete Reynolds infrastructure, identified `no_gaps_discrete` as the sole critical sorry, confirmed `succ_cofinal` is unprovable.
- `reports/02_option-c-pivot-research.md` (integrated in plan v2): Precise sorry DAG analysis showing `restricted_tc`/`restricted_fuc` -> `succ_embed_surjective` -> `succ_cofinal`. Confirmed `cantor_bfmcs_discrete`, `restricted_buc`, and the parametric truth lemma are all sorry-free. Established that a direct Henkin chain on Z makes F/Until witnessing trivial by construction. Identified `forward_temporal_witness_seed_consistent` from WitnessSeed.lean as reusable sorry-free infrastructure.

### Prior Plan Reference

Plan v1 (`01_reynolds-bypass-plan.md`) had 5 phases targeting the Reynolds pipeline. Phase 3 was completed (sorry-free `one_class_implies_very_good`, `chronicle_is_good_direct`, fc generalization). Phases 1, 2, 4 were blocked. This plan (v2) abandons the Reynolds pipeline approach and pivots to Option C. Phase 3's completed work (`one_class_implies_very_good`, `chronicle_is_good_direct`, fc generalization) remains in the codebase as independently valuable infrastructure but is not on the critical path for Option C.

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

Option C eliminates the `succ_embed_surjective` dependency entirely by constructing the FMCS so that F/Until witnesses are integers by construction.

### Roadmap Alignment

Critical path for sorry-free `completeness_discrete`. Advances "Sorry-free `bx_completeness`" roadmap item. Unblocks task 95 (verification audit), task 176 (chronicle relocation).

## Goals & Non-Goals

**Goals**:
- Build a Henkin chain FMCS on Z that witnesses F/Until at each integer step
- Prove sorry-free `restricted_tc` and `restricted_fuc` for the new FMCS
- Assemble a sorry-free BFMCS on Z using the new FMCS families
- Wire into `countermodel_discrete_enriched` (or create a parallel version) to eliminate `succ_cofinal`
- Achieve `#print axioms completeness_discrete` with no `sorryAx`
- `lake build` passes with zero errors

**Non-Goals**:
- Completing the Reynolds pipeline (no_gaps_discrete, US expressive completeness over Prior structures)
- Proving `succ_cofinal` or `succ_embed_surjective` (bypassed entirely)
- Changing the chronicle construction or the dense case
- Removing Phase 3's completed work (one_class_implies_very_good, etc.) -- it stays as independently useful
- Addressing ~17 dead-code sorries in BXCanonical
- Optimizing proof term size or compilation time

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Until-witnessing termination argument is harder than expected | H | M | The Until deferral mechanism in discrete orders is well-understood mathematically (BX axioms ensure progress via `next_top = U(T, bot)`). Can use well-founded induction on formula complexity if step-wise deferral is insufficient. Fallback: use existing `restricted_buc` (sorry-free contrapositive) for the backward direction and build only forward Until coherence. |
| Henkin chain G/H coherence proof is complex | M | L | Standard technique: Lindenbaum extension with g_content/h_content seeds. The existing `forward_temporal_witness_seed_consistent` from WitnessSeed.lean is sorry-free and provides the core mechanism. |
| Modal coherence (box stability) for new BFMCS is non-trivial | M | L | Same pattern as existing `cantor_bfmcs_discrete` modal_forward/backward. Box-equivalent MCS chains produce box-stable families by construction. |
| Integration with `countermodel_discrete_enriched` requires signature changes | L | M | The parametric infrastructure (`fully_restricted_parametric_completeness_from_neg_membership`, `ParametricCanonicalTaskFrame`, `ParametricCanonicalTaskModel`) is generic over any BFMCS. The new BFMCS is a drop-in replacement. |
| `SuccExistence.lean` has a sorry (`constrained_successor_seed_consistent` line 446) that infects the chain | H | L | Verify via `lean_verify` that the chosen seed construction path does NOT depend on this sorry. Use `forward_temporal_witness_seed_consistent` from WitnessSeed.lean instead (verified sorry-free). |
| Compilation time explosion from new 400-600 lines | L | M | Factor proofs into small lemmas. Use `set_option maxHeartbeats` locally. Use `lake build Module.Name` for incremental checking. |

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

### Phase 1: Henkin Chain FMCS Construction on Z [BLOCKED]

**BLOCKER** (Phase 1):
- **What failed**: Both the Henkin chain approach AND the direct succ_cofinal proof face the same fundamental mathematical obstacle: proving that F-formula witnesses are reachable from the succ-orbit. The Henkin chain requires simultaneously consistent F-witnesses (f_content(M) ∪ g_content(M) is NOT necessarily consistent since F doesn't distribute over conjunction). The succ_cofinal proof requires a well-founded measure for the "gap elimination" step, but all candidate measures (rational distance, stage count, limit_dom cardinality) fail because the limit domain has infinitely many points from unbounded stages.
- **What was tried**:
  1. Direct restricted_tc/fuc proofs avoiding surjectivity: F(phi) persists through the orbit via backward_G contrapositive, but we cannot prove the orbit reaches the chronicle's witness y without succ_cofinal.
  2. Henkin chain with f_content + g_content seed: f_content ∪ g_content is NOT consistent (F doesn't distribute over conjunction; countermodel on Z with phi at 1, psi at 2 shows F(phi) ∧ F(psi) but not F(phi ∧ psi)).
  3. Henkin chain with successor_deferral_seed: g_content ∪ {phi ∨ F(phi)} seed consistency under irreflexive semantics requires g_content(M) not being a subset of M (since G(phi) → phi is not valid). Existing sorry at SuccExistence.lean:749.
  4. Dovetailing (one F-formula per step): F-persistence fails -- F(phi) at step n does NOT propagate to step n+1 through g_content because G(F(phi)) is not derivable from F(phi).
  5. Direct succ_cofinal via pred(b) induction: pred(b) < b gives a "smaller" interval, but IsPredArchimedean is equivalent to IsSuccArchimedean (circular). No well-founded Nat measure found.
  6. Stage-based induction (succ_reaches_dom_N): boundary case sorry at line 1285 -- orbit reaches max(dom(N)) but b > max(dom(N)), and the succ function in the limit domain might skip to points from later stages.
- **Why it's stuck**: The gap scenario -- succ orbit converging to a limit L without reaching b -- is the fundamental obstacle. Under irreflexive strict temporal semantics, the constant-MCS scenario (all orbit points have identical MCS labels) evades all temporal axiom arguments (Z1, Prior-UZ, BX5/BX6). The construction-level argument (omega-chain counterexample enumeration should prevent gaps) requires deep interaction with the omega_chain_elim_result internals.
- **What is needed**: One of: (a) A construction-level proof that the omega-chain cannot produce gaps (using properties of eliminate_potential_counterexample), (b) A proof that successor_deferral_seed is consistent under irreflexive semantics for general fc (not just FrameClass.Base), (c) The weak/reflexive completeness + conservative extension approach (task 129), or (d) A direct proof that f_content(M) ∪ g_content(M) is consistent when M has the discrete property.
- **Prohibited workarounds**: Do NOT use `sorry`, `def X := True`, or any vacuous placeholder

**Goal**: Build a Henkin-style FMCS on Z that constructs an MCS at each integer by Lindenbaum extension, witnessing F-formulas and Until-formulas at each successor step. Prove forward_G and backward_H coherence for the chain.

**Tasks**:
- [ ] Create new file `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/HenkinChain.lean` (or add to existing file in the IntegerModel directory)
- [ ] Study the existing FMCS construction path: `rooted_succ_discrete_fmcs` in `ChronicleToCountermodel.lean` to understand the FMCS structure and its sorry-producing `succ_embed` dependency
- [ ] Study `forward_temporal_witness_seed_consistent` in `WitnessSeed.lean` -- this is the sorry-free seed constructor that builds a consistent context witnessing F/P/Until/Since formulas
- [ ] Study `cantor_bfmcs_discrete` to understand the BFMCS structure and what restricted coherence proofs it needs
- [ ] Define `henkin_discrete_mcs : (root : Set Formula) -> (h_mcs : IsMCS root) -> (h_discrete : box next_top in root) -> Z -> Set Formula` that assigns an MCS to each integer:
  - `henkin_discrete_mcs root h_mcs h_discrete 0 = root`
  - For `n+1`: Lindenbaum extension of seed built from `henkin_discrete_mcs ... n`, containing:
    - All `phi` where `G(phi) in henkin_discrete_mcs ... n` (forward_G content)
    - F-witnesses: for each `F(psi) in henkin_discrete_mcs ... n`, include `psi` in the seed
    - Until-witnesses: for each `U(psi1, psi2) in henkin_discrete_mcs ... n`, include either `psi1` (resolution) or `psi2 /\ U(psi1, psi2)` (deferral) -- choosing resolution when consistent
  - For `n-1`: Symmetric for past direction (backward_H content, P-witnesses, Since-witnesses)
- [ ] Prove seed consistency at each step using `forward_temporal_witness_seed_consistent` (or adapt its technique)
- [ ] Prove `henkin_forward_G`: `G(phi) in henkin_discrete_mcs ... n -> phi in henkin_discrete_mcs ... m` for all `m > n`
- [ ] Prove `henkin_backward_H`: `H(phi) in henkin_discrete_mcs ... n -> phi in henkin_discrete_mcs ... m` for all `m < n`
- [ ] Prove `henkin_restricted_tc`: `F(phi) in henkin_discrete_mcs ... n -> exists s > n, phi in henkin_discrete_mcs ... s` (trivial: witness is `n+1` by construction)
- [ ] Prove `henkin_restricted_fuc`: `U(phi, psi) in henkin_discrete_mcs ... n -> exists s > n, phi in henkin_discrete_mcs ... s /\ forall r, n < r < s -> psi in henkin_discrete_mcs ... r` (by chain construction + induction on Until deferral)
- [ ] Verify with `lean_verify` that all new definitions are sorry-free
- [ ] Verify that no dependency on `succ_cofinal`, `succ_embed_surjective`, or `limitDomSubtype_isSuccArchimedean` exists

**Timing**: 3-5 hours

**Depends on**: none

**Files to modify**:
- New: `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/HenkinChain.lean` (primary, ~300-400 lines)
- Possibly: `Theories/Bimodal/Metalogic/WeakCanonical/Bundle/WitnessSeed.lean` (if seed adaptation needed)

**Verification**:
- All `henkin_*` definitions compile with no sorry
- `lean_verify` on each new definition shows no `sorryAx`
- `lake build Bimodal.Metalogic.WeakCanonical.IntegerModel.HenkinChain` passes

**Key risk -- Until-witnessing termination**: The Until case requires showing that the deferral `psi2 /\ U(psi1, psi2)` in the chain eventually resolves to `psi1`. In a discrete MCS with `next_top = U(T, bot)`, the BX axioms ensure Until cannot defer indefinitely. Specifically, the self-accumulation axiom BX5 together with discreteness means that if `U(psi1, psi2) in MCS(n)`, then within finitely many steps either `psi1` appears or the MCS is inconsistent. If this direct argument is too complex to formalize, the alternative is to show that the FMCS witnesses Until by construction: at step `n+1`, the seed includes `psi1` when doing so is consistent with the G/H content, and includes the deferral `psi2 /\ U(psi1, psi2)` otherwise. The Until formula's depth does not decrease, but the set of "active Until formulas" is finite (bounded by subformulas of the target formula), and at each step at least one active Until makes progress (either resolves or the guard holds), giving a well-founded measure.

---

### Phase 2: BFMCS Assembly and Restricted Coherence [NOT STARTED]

**Goal**: Build a sorry-free BFMCS on Z using the Henkin chain FMCS families, with sorry-free restricted coherence proofs (restricted_tc, restricted_fuc, restricted_buc).

**Tasks**:
- [ ] Define `henkin_bfmcs_discrete` analogous to `cantor_bfmcs_discrete`:
  - Families parametrized by `(N : Set Formula, s : Z)` where N is a discrete MCS box-equivalent to the root MCS A
  - `henkin_bfmcs_discrete.fam(N, s).mcs(t) = henkin_discrete_mcs N h_mcs h_discrete (t - s)` (or equivalent offset scheme)
  - Finite many families (bounded by box-equivalence classes up to depth k)
- [ ] Prove modal coherence for the new BFMCS:
  - `henkin_bfmcs_modal_forward`: box(phi) in fam.mcs(t) -> phi in fam'.mcs(t) for all box-equivalent fam'
  - `henkin_bfmcs_modal_backward`: phi in fam'.mcs(t) for all box-equivalent fam' -> box(phi) in fam.mcs(t)
  - These follow the same pattern as existing `cantor_bfmcs_discrete` modal coherence (box-equivalent MCSes share the same box content)
- [ ] Wire the restricted coherence proofs:
  - `henkin_restricted_tc` from Phase 1 becomes `henkin_bfmcs_restricted_tc`
  - `henkin_restricted_fuc` from Phase 1 becomes `henkin_bfmcs_restricted_fuc`
  - `henkin_restricted_buc`: either adapt existing sorry-free `restricted_buc` (contrapositive argument) or prove directly from the Henkin chain's backward witnessing
- [ ] Verify the BFMCS satisfies all hypotheses of `fully_restricted_parametric_completeness_from_neg_membership`
- [ ] Verify with `lean_verify` that the BFMCS and all coherence proofs are sorry-free

**Timing**: 2-3 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/HenkinChain.lean` (extend with BFMCS assembly, ~100-150 lines)
- Possibly: `Theories/Bimodal/Metalogic/WeakCanonical/ChronicleToCountermodel.lean` (if adapting existing BFMCS patterns)

**Verification**:
- `henkin_bfmcs_discrete` compiles with no sorry
- All restricted coherence proofs (tc, fuc, buc) compile with no sorry
- `lean_verify` on each shows no `sorryAx`
- No dependency on `succ_cofinal`, `succ_embed_surjective`, or `limitDomSubtype_isSuccArchimedean`

---

### Phase 3: Rewire completeness_discrete [NOT STARTED]

**Goal**: Replace the sorry-producing `countermodel_discrete_enriched` call (or create a parallel version) that uses the new Henkin BFMCS, making `completeness_discrete` sorry-free.

**Tasks**:
- [ ] Create `countermodel_discrete_henkin` (or modify `countermodel_discrete_enriched`) that:
  1. Takes MCS A with `neg phi in A` and `box(next_top) in A`
  2. Builds `henkin_bfmcs_discrete A` from Phase 2
  3. Passes the three sorry-free restricted coherence proofs (tc, fuc, buc) to `fully_restricted_parametric_completeness_from_neg_membership`
  4. Obtains `NOT truth_at ... t phi` from the parametric truth lemma
  5. Returns the countermodel (TaskFrame + valuation + point where phi fails)
- [ ] Wire into `completeness_discrete`:
  - Either replace the body of `countermodel_discrete_enriched` with the Henkin version
  - Or create `countermodel_discrete_henkin` and update the call site in `completeness_discrete` (or `completeness_discrete`'s caller)
  - The key call site is in `Completeness.lean` or `Transfer.lean` where `countermodel_discrete_enriched` is invoked
- [ ] Verify that `completeness_discrete` compiles with no sorry
- [ ] Verify that `completeness_dense` still compiles with no sorry (it uses a separate code path)
- [ ] Check that no other definitions are broken by the change

**Timing**: 1-2 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/ChronicleToCountermodel.lean` (replace or supplement `countermodel_discrete_enriched`)
- Possibly: `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` (if call site needs updating)
- Possibly: `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean` (if countermodel_discrete is defined there)

**Verification**:
- `countermodel_discrete_henkin` (or modified `countermodel_discrete_enriched`) compiles with no sorry
- `lean_verify Bimodal.Metalogic.BXCanonical.completeness_discrete` shows no `sorryAx`
- `lean_verify Bimodal.Metalogic.BXCanonical.completeness_dense` still shows no `sorryAx`
- `lake build Bimodal.Metalogic.BXCanonical.Completeness` passes

---

### Phase 4: Full Build Verification and Cleanup [NOT STARTED]

**Goal**: Full build verification, axiom audit, and ROADMAP update.

**Tasks**:
- [ ] Run `lake build` (full project build, all modules)
- [ ] Run `lean_verify Bimodal.Metalogic.BXCanonical.completeness_discrete` and confirm no `sorryAx`
- [ ] Run `lean_verify Bimodal.Metalogic.BXCanonical.completeness_dense` and confirm still sorry-free
- [ ] Check `#print axioms completeness_discrete` output (should show only standard Lean axioms: propext, Classical.choice, Quot.sound)
- [ ] If any sorries remain in the chain, trace and fix them
- [ ] Evaluate whether `succ_cofinal`, `succ_embed_surjective`, `limitDomSubtype_isSuccArchimedean`, and the old `cantor_bfmcs_discrete_restricted_tc`/`_fuc` are now dead code:
  - If still used by other live paths: leave them
  - If dead: mark with `-- DEAD CODE (Option C bypass)` comment or remove
- [ ] Evaluate whether `countermodel_discrete_reynolds` (Transfer.lean:866, sorry) and related Reynolds pipeline experimental code should be removed or preserved as documentation
- [ ] Update `#print axioms` comment in Completeness.lean to reflect sorry-free status
- [ ] Update `specs/ROADMAP.md`: sorry count, critical path status, mark "Sorry-free `bx_completeness`" as achieved

**Timing**: 1-2 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` (axiom audit comments)
- `Theories/Bimodal/Metalogic/WeakCanonical/ChronicleToCountermodel.lean` (dead code cleanup)
- `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean` (dead code cleanup)
- `specs/ROADMAP.md` (sorry count, critical path)

**Verification**:
- `lake build` passes with zero errors
- `lean_verify Bimodal.Metalogic.BXCanonical.completeness_discrete` shows NO `sorryAx`
- `#print axioms completeness_discrete` matches expected output (standard Lean axioms only)
- ROADMAP.md accurately reflects sorry-free status

---

## Prior Plan Phase 3 (Preserved Work)

The following work from plan v1 Phase 3 was completed and remains in the codebase. It is NOT on the critical path for Option C but is independently valuable infrastructure:

- **`one_class_implies_very_good`** (ShiftAndGlue.lean, sorry-free): If all points are contemp_equiv, the structure is very_good.
- **`chronicle_is_good_direct`** (ShiftAndGlue.lean, has sorry via no_gaps_discrete): Alternative proof of chronicle goodness via one_class path. Not used by Option C.
- **fc generalization** (NEquivalence.lean, ShiftAndGlue.lean, Transfer.lean, TruthLemma.lean): Generalized 10+ definitions from `FrameClass.Base` to generic `fc`. Sorry-free, improves modularity.
- **`countermodel_discrete_reynolds`** (Transfer.lean, has sorry): Experimental Reynolds pipeline assembly. Not used by Option C.

## Testing & Validation

- [ ] `henkin_discrete_mcs` compiles without sorry
- [ ] `henkin_forward_G` and `henkin_backward_H` compile without sorry
- [ ] `henkin_restricted_tc` compiles without sorry
- [ ] `henkin_restricted_fuc` compiles without sorry
- [ ] `henkin_bfmcs_discrete` compiles without sorry with all coherence proofs
- [ ] `lean_verify` on the new countermodel function shows no `sorryAx`
- [ ] `lean_verify Bimodal.Metalogic.BXCanonical.completeness_discrete` shows no `sorryAx`
- [ ] `lean_verify Bimodal.Metalogic.BXCanonical.completeness_dense` still shows no `sorryAx`
- [ ] `lake build` passes with zero errors
- [ ] No new sorries introduced anywhere in the codebase

## Artifacts & Outputs

- `specs/202_reynolds_k_equivalence_bypass/plans/02_option-c-plan.md` (this file)
- New: `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/HenkinChain.lean` (~400-600 lines)
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/ChronicleToCountermodel.lean` (countermodel rewiring)
- Modified: `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` (axiom audit comments)
- Modified: `specs/ROADMAP.md` (sorry count, critical path)
- Potentially modified: `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean` (dead code cleanup)

## Rollback/Contingency

If Option C proves infeasible:

1. **Partial rollback**: All new Henkin chain code is in a new file (`HenkinChain.lean`) and the countermodel change is localized. Revert the countermodel rewiring to restore the original `countermodel_discrete_enriched` call. All intermediate Henkin chain work is independently valuable and should be preserved.

2. **Fallback to Reynolds pipeline**: Return to plan v1 and invest the 8-12h in Phase 1 (US expressive completeness over Prior structures). The Phase 3 completed work from plan v1 remains ready for this path.

3. **Hybrid approach**: If the Henkin chain works for F (restricted_tc) but not Until (restricted_fuc), use the Henkin chain for F-resolution and attempt to adapt the existing sorry-free `restricted_buc` contrapositive technique for the forward Until case.

4. **Scope reduction**: If the full BFMCS assembly is too complex, build just one FMCS on Z (for the root MCS) and prove completeness for that single chain, then lift to the full BFMCS.

5. **Git recovery**: All changes are on `main`. The new file `HenkinChain.lean` can be deleted, and countermodel changes can be reverted per-file with `git checkout`.
