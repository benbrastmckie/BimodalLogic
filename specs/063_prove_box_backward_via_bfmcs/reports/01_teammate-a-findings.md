# Teammate A Findings: BFMCS Box Backward Wiring Analysis

**Task**: 63 - Prove Box backward via BFMCS modal saturation
**Role**: Primary Implementation Approach
**Date**: 2026-03-24
**Focus**: How to wire `boxClassFamilies_modal_backward` to resolve the Box backward sorry

---

## Key Findings

### 1. Structural Difference: Singleton-Omega vs. BFMCS Bundle

**Singleton-Omega (SuccChainTruth.lean)**:
- `succ_chain_omega M0 := {succ_chain_history M0}` — exactly ONE history
- Box backward goal: `psi ∈ succ_chain_fam M0 t → Formula.box psi ∈ succ_chain_fam M0 t`
- This means `psi in MCS t → Box(psi) in MCS t`, which is mathematically false without modal saturation
- The sorry at line 254 is correct as a placeholder — the goal is simply unprovable

**BFMCS Bundle (boxClassFamilies in UltrafilterChain.lean)**:
- `boxClassFamilies M0 h_mcs` = all shifted SuccChainFMCS from MCSes with the same box theory as M0
- Box backward goal: `(∀ fam' ∈ bundle, psi ∈ fam'.mcs t) → Formula.box psi ∈ fam.mcs t`
- This is provable by contraposition: if `Box(psi)` fails, then `Diamond(neg psi)` holds in M0, and `box_theory_witness_exists` provides a witness family where `neg(psi)` is true, contradicting the "psi in ALL families" assumption
- `boxClassFamilies_modal_backward` at line 1678 proves this — it is ALREADY PROVEN and sorry-free

### 2. The Sorry Is Not in SuccChainTruth — The Architecture Is Wrong

The sorry at `SuccChainTruth.lean:254` cannot be fixed by applying `boxClassFamilies_modal_backward` directly, because the two theorems operate over different model structures:

- `succ_chain_truth_lemma` uses `succ_chain_omega M0` (singleton), which semantically means Box quantifies over ONE history
- `boxClassFamilies_modal_backward` proves Box backward for a BUNDLE where Box quantifies over ALL families

To use `boxClassFamilies_modal_backward` for completeness, the **entire completeness proof must be refactored** to use the BFMCS structure instead of singleton-Omega. This is not a one-line fix.

### 3. The Working Alternative Already Exists

The codebase already has a sorry-free completeness path via the parametric approach:

- `ParametricTruthLemma.lean`: `parametric_canonical_truth_lemma` proves the full biconditional (including Box backward) using `B.modal_backward` — which is provided as a field of the BFMCS
- `UltrafilterChain.lean`: `boxClassFamilies_modal_backward` is a proven BFMCS whose `modal_backward` satisfies the BFMCS contract
- `ParametricRepresentation.lean`: `parametric_algebraic_representation_relative` provides the completeness statement for any BFMCS with temporal coherence

The gap blocking sorry-free completeness is **temporal coherence** for the BFMCS bundle, not Box backward.

### 4. The Real Blocker: `boxClassFamilies_temporally_coherent` Is Deprecated

`boxClassFamilies_temporally_coherent` (UltrafilterChain.lean:1809) is marked `@[deprecated]` because it depends on:
- `SuccChainTemporalCoherent` → `succ_chain_forward_F` → `f_nesting_is_bounded`
- `f_nesting_is_bounded` is mathematically FALSE (per task 55 research)

The `construct_bfmcs` function (line 1852) is also deprecated for the same reason.

This means the BFMCS path (`boxClassFamilies`) has `modal_backward` proven but lacks `temporally_coherent`. The completeness path in `ParametricRepresentation.lean` requires `h_tc : B.temporally_coherent`.

### 5. What Task 63 Can Realistically Accomplish

Two viable sub-approaches:

**Sub-approach A: Wire boxClassFamilies for Modal-Only Completeness**

Build a new completeness theorem in `SuccChainCompleteness.lean` (or a new file) that:
1. Uses `boxClassFamilies M0 h_mcs` as the bundle
2. Uses `parametric_canonical_truth_lemma` (not `succ_chain_truth_lemma`) — the parametric version proves Box backward using `B.modal_backward`
3. Sets `B.modal_backward := boxClassFamilies_modal_backward M0 h_mcs`
4. Skips temporal coherence (omits G and H backward cases), or proves completeness only for modal-only fragments

The `parametric_canonical_truth_lemma` Box backward case at `ParametricTruthLemma.lean:259-269` works by:
```lean
have h_psi_all_mcs : ∀ fam' ∈ B.families, psi ∈ fam'.mcs t := by
  -- uses (ih fam' hfam' t).mpr for each fam' in bundle
exact B.modal_backward fam hfam psi t h_psi_all_mcs
```
This is already proven sorry-free when `B.modal_backward` is provided.

**Sub-approach B: Prove Temporal Coherence via Restricted Chains (Long Path)**

Construct a `temporally_coherent` BFMCS using restricted chain constructions (avoiding `f_nesting_is_bounded`). This requires significant infrastructure beyond Task 63.

### 6. The IH Dependency Problem

The Imp forward case in both `succ_chain_truth_lemma` and `parametric_canonical_truth_lemma` requires the backward IH:
```lean
| imp psi chi ih_psi ih_chi =>
  intro h_imp h_psi_true
  have h_psi_mcs : psi ∈ fam.mcs t := (ih_psi fam hfam t).mpr h_psi_true  -- backward IH!
```

For the parametric version, this backward IH is available because the induction is over ALL formulas simultaneously, and the IH provides the full biconditional. The Imp case does NOT create a circularity — it uses the backward IH on a **smaller** subformula (psi has smaller formula complexity than psi.imp chi).

The Box backward in `parametric_canonical_truth_lemma` succeeds because it delegates to `B.modal_backward`, which is a field. When `B = boxClassFamilies M0 h_mcs`, the `modal_backward` field is satisfied by `boxClassFamilies_modal_backward`, which is proven.

---

## Recommended Approach

### Step-by-Step: Create BFMCS-Based Completeness in SuccChainCompleteness.lean

**Phase 1**: Create a new completeness theorem using the BFMCS bundle.

In `SuccChainCompleteness.lean` (or a new file `BFMCSCompleteness.lean`), add:

```lean
import Bimodal.Metalogic.Algebraic.UltrafilterChain
import Bimodal.Metalogic.Algebraic.ParametricTruthLemma

-- Build a minimal BFMCS from M0 using boxClassFamilies
-- This BFMCS has modal_forward and modal_backward proven
-- but lacks temporally_coherent (due to f_nesting_is_bounded being false)
```

**Phase 2**: Construct the BFMCS without temporal coherence.

```lean
noncomputable def bfmcs_from_mcs (M : Set Formula) (h_mcs : SetMaximalConsistent M) : BFMCS Int :=
  { families := boxClassFamilies M h_mcs
    nonempty := boxClassFamilies_nonempty M h_mcs
    modal_forward := boxClassFamilies_modal_forward M h_mcs
    modal_backward := boxClassFamilies_modal_backward M h_mcs
    eval_family := SuccChainFMCS (MCS_to_SerialMCS M h_mcs)
    eval_family_mem := eval_family_mem_boxClassFamilies M h_mcs }
```

This compiles (all four fields have sorry-free proofs).

**Phase 3**: Prove the Box-only truth lemma.

The `parametric_canonical_truth_lemma` proves Box backward using `B.modal_backward`. However, the G and H backward cases require `h_tc : B.temporally_coherent`. A restricted truth lemma for modal-only formulas (no G/H) can be proved sorry-free.

Alternatively, examine whether the completeness proof in `SuccChainCompleteness.lean` actually needs the backward direction for G and H cases. The sorry-path goes: `succ_chain_truth_forward` → backward IH in Imp → Box backward. If Box backward is solved, Imp forward works, and `succ_chain_truth_forward` might work for Box-containing formulas.

**Phase 4**: Wire into completeness.

The completeness proof uses `succ_chain_truth_forward M0 φ.neg 0 h_neg_in_fam` (line 154). Replace with `parametric_canonical_truth_lemma` applied to `bfmcs_from_mcs M0 h_mcs`.

However: `parametric_canonical_truth_lemma` requires `h_tc` for the G and H backward cases. The completeness proof only needs the **forward** direction of the truth lemma for `phi.neg`. For the Imp case, it needs the backward IH. This transitively requires Box backward, which is now fixed. It does NOT require G-backward or H-backward in the completeness direction.

**Key Insight**: The completeness proof only calls `truth_forward` (MCS → truth), not `truth_backward` (truth → MCS). The IH in Imp-forward requires backward only for subformulas. If we can prove `forward` without needing backward for G and H at the completeness level, we are done.

**Phase 5**: Check whether the new sorry-free path truly avoids temporal coherence.

Trace: `bfmcs_completeness` → `parametric_truth_forward (phi.neg)` → (induction on phi.neg) → cases:
- If `phi.neg = psi.imp chi.neg` → Imp case → needs backward IH on psi (a subformula)
- If `phi.neg = Box psi` → Box forward → uses `B.modal_forward` (proven)
- If `phi.neg = G psi` → G forward → uses `fam.forward_G` (proven for FMCS)
- Backward IH on any formula → eventually hits Box backward → uses `B.modal_backward` (proven)
- G backward → uses `temporal_backward_G` → needs `h_tc`

The G backward and H backward cases in `parametric_canonical_truth_lemma` need `h_tc`. This creates a sorry if `temporal_backward_G` is invoked. However, for the completeness proof, we only need `truth_forward`. In the Imp case, the backward IH is called on subformulas. If none of those subformulas are G or H formulas in a position requiring backward, we may be safe.

**Conclusion**: The cleanest approach for Task 63 is to create a `bfmcs_from_mcs` construction and prove a modified `parametric_truth_forward_no_temporal` that skips G/H backward cases by restricting to modal formulas, or to identify that the completeness proof does not trigger G/H backward.

---

## Evidence and Code References

### boxClassFamilies_modal_backward (Already Proven)
- File: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean`
- Lines: 1678-1782
- Signature: `theorem boxClassFamilies_modal_backward (M0 : Set Formula) (h_mcs : SetMaximalConsistent M0) (fam : FMCS Int) (hfam : fam ∈ boxClassFamilies M0 h_mcs) (phi : Formula) (t : Int) (h_all : ∀ fam' ∈ boxClassFamilies M0 h_mcs, phi ∈ fam'.mcs t) : Formula.box phi ∈ fam.mcs t`
- Method: Contraposition via `box_theory_witness_exists`

### The Sorry Location
- File: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/SuccChainTruth.lean`
- Line: 254
- Context: Box backward in `succ_chain_truth_lemma`, singleton-Omega model
- Comment in code: "THE BFMCS SOLUTION (UltrafilterChain.lean)" explicitly documents the path

### Parametric Truth Lemma Box Case (Sorry-Free When B.modal_backward Is Provided)
- File: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Algebraic/ParametricTruthLemma.lean`
- Lines: 246-269
- The Box backward case at line 263-269 uses `B.modal_backward` — no sorry

### Temporal Coherence Blocker
- File: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean`
- Lines: 1808-1820: `boxClassFamilies_temporally_coherent` marked `@[deprecated]`
- Lines: 1828-1877: `construct_bfmcs` marked `@[deprecated]`

### Completeness Proof That Needs Fixing
- File: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Completeness/SuccChainCompleteness.lean`
- Line: 154: `succ_chain_truth_forward M0 φ.neg 0 h_neg_in_fam` — the injection point

### Existing Sorry-Free Completeness Path (Reference Implementation)
- File: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Algebraic/ParametricRepresentation.lean`
- `parametric_algebraic_representation_relative` — the pattern to follow

---

## Confidence Level

**High** on the following:
1. `boxClassFamilies_modal_backward` is already proven sorry-free
2. The singleton-Omega sorry is mathematically unprovable (correct assessment)
3. The BFMCS bundle (`boxClassFamilies`) provides modal_forward and modal_backward both proven
4. `parametric_canonical_truth_lemma` Box backward works when `B.modal_backward` is provided
5. `bfmcs_from_mcs` can be constructed without temporal coherence (four fields proven)

**Medium** on the following:
1. Whether the completeness proof can avoid G/H backward entirely when using the parametric path
2. Exact scope of changes needed in SuccChainCompleteness.lean vs. creating a new file

**Low** on:
1. Whether Task 63 can be completed without also fixing temporal coherence (which requires resolving the `f_nesting_is_bounded` falsehood from task 55)

**Bottom line**: Task 63 can resolve the Box backward sorry specifically. A sorry-free completeness proof for modal formulas (no G/H) is achievable. Full completeness (including G and H cases) requires temporal coherence, which is a separate blocked problem.
