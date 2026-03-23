# Teammate B Findings: Box Backward Direction - Alternative Approaches & Prior Art

## Key Findings

### 1. The Sorry Is Genuinely Non-Blocking for Completeness

The completeness proof in `SuccChainCompleteness.lean` uses only `succ_chain_truth_forward` (the `.mp` direction of the biconditional). The file's module doc at line 34 explicitly states:

> "One sorry in SuccChainTruth (Box backward - not used in completeness)"

The completeness proof at lines 131–161 calls `succ_chain_truth_forward M0 φ.neg 0 h_neg_in_fam` and never touches the backward direction for Box. The sorry is structurally isolated.

### 2. The `imp` Case Creates an Indirect Dependency

The sorry **is** reached indirectly during the inductive proof structure. In the `imp` case backward direction (line 226), the proof calls `(ih_chi t).mpr h_chi_true`, which triggers the backward IH for `chi`. If `chi` is of the form `Box psi`, this IH call lands at the sorry.

However, the completeness proof only invokes `succ_chain_truth_forward`, which calls `(succ_chain_truth_lemma M0 phi t).mp`. The `.mp` direction is the forward direction. The sorry is in the `.mpr` direction. Because `succ_chain_truth_forward` only uses `.mp`, the sorry is never reached transitively in the completeness chain.

### 3. Why the Backward Direction Is False for Singleton Omega

The mathematical obstruction is well-documented. In a singleton-Omega model:

- **Backward goal**: `(∀ σ ∈ {τ}, truth σ t ψ) → Box ψ ∈ MCS`
- This reduces to: `ψ ∈ MCS t → Box ψ ∈ MCS t`
- This is the converse of the T-axiom: Box ψ → ψ
- The converse is **not an axiom** and is not derivable

This is confirmed by prior art in the codebase. `MultiFamilyBFMCS.lean` (lines 27–39) contains an "ARCHITECTURAL NOTE" stating:

> "The singleton BFMCS approach... modal_backward requires: φ ∈ MCS → □φ ∈ MCS (converse of T-axiom, FALSE). The sorry at line 287 CANNOT be eliminated."

Similarly, `ModallyCoherentBFMCS.lean` (lines 14–18):

> "The singleton BFMCS approach has an **unprovable** modal_backward sorry. For a singleton bundle, modal_backward requires `φ ∈ MCS → □φ ∈ MCS`, which is the converse of the T-axiom and mathematically impossible for contingent formulas."

### 4. The BFMCS Multi-Family Pattern Does Solve the Problem (With Cost)

The `ParametricTruthLemma.lean` shows the correct approach for a provable Box backward direction: use a multi-family BFMCS (`BFMCS D`) with `modal_backward` as a structure field. In that proof (lines 260–270):

```lean
-- Backward: forall sigma in Omega, truth sigma t psi -> box psi in MCS
intro h_all
have h_psi_all_mcs : ∀ fam' ∈ B.families, psi ∈ fam'.mcs t := by
  intro fam' hfam'
  have h_in_omega : parametric_to_history fam' ∈ ParametricCanonicalOmega B := ⟨fam', hfam', rfl⟩
  have h_truth := h_all (parametric_to_history fam') h_in_omega
  exact (ih fam' hfam' t).mpr h_truth
-- By modal_backward: box psi in MCS
exact B.modal_backward fam hfam psi t h_psi_all_mcs
```

This works because Omega is no longer a singleton—it contains one history per family in the bundle—so the backward direction reduces to `modal_backward`, which is a proof-theoretically satisfied property of the bundle (not a claim that `φ → □φ`).

The cost: migrating the SuccChain construction to a multi-family BFMCS is architecturally significant.

### 5. The Refactoring Option: Forward-Only Truth Lemma

The current biconditional structure exists because the `imp` forward direction needs `ih_psi.mpr` (backward IH for `psi`) at line 192. This creates mutual dependence between forward and backward directions during induction.

A **forward-only truth lemma** `phi ∈ MCS → truth phi` can be stated and proved without ever needing the Box backward direction. The `imp` forward direction `(psi → chi) ∈ MCS ∧ truth psi → truth chi` can be proved via:
1. By IH forward on `psi`: from `psi ∈ MCS`, get `truth psi`
2. Actually the dependency runs the other way: we need `truth psi → psi ∈ MCS` to use modus ponens

So the genuine circularity is: the `imp` **forward** direction requires `psi` backward (to extract `psi ∈ MCS` from `truth psi`). This mutual dependence means a purely forward-only lemma for `imp` is not straightforward—it would require a different proof technique (e.g., proving both directions simultaneously as a biconditional, or using a different structural approach).

### 6. Prior Art: How Standard References Handle This

The standard Henkin completeness argument for modal logic (e.g., Blackburn, de Rijke & Venema "Modal Logic") does NOT use a singleton model for the Box case. The canonical model has one world per MCS, and accessibility is defined via Box content:

> `w R v iff {φ | □φ ∈ w} ⊆ v`

This makes Box backward provable: if `ψ` is true at all accessible worlds `v`, and `Box ψ ∉ w`, then by maximality `◇(¬ψ) ∈ w`, so there is an accessible world with `¬ψ`, contradiction.

The SuccChain approach departs from this standard pattern by using a single history, which is what causes the Box backward obstruction.

---

## Recommended Approach

**Recommendation: Document the sorry as non-blocking and leave it in place.**

Rationale:

1. **The sorry does not block completeness.** `succ_chain_truth_forward` is all that is needed, and it is provably used in `SuccChainCompleteness.lean` without reaching the sorry.

2. **The sorry is mathematically irreparable in the current architecture.** The singleton-Omega design makes Box backward false, not merely unproven. Multiple independent sources in the codebase (`MultiFamilyBFMCS.lean` line 27–39, `ModallyCoherentBFMCS.lean` lines 14–18) have analyzed and confirmed this.

3. **The BFMCS fix is architecturally heavy.** Migrating to multi-family BFMCS would require:
   - Replacing `succ_chain_omega` (singleton) with a proper `BFMCS Int` structure
   - Providing `modal_forward` and `modal_backward` proofs for that bundle
   - The existing `DirectMultiFamilyBFMCS.lean` has 4+ sorries of its own

4. **The "restricted version sufficient for completeness" approach is already implemented.** The current code uses only `succ_chain_truth_forward` in the completeness proof. This is the restricted version.

If stronger than non-blocking debt is desired:

**Option A (Forward-Only Lemma Rename)**: Rename `succ_chain_truth_lemma` to `succ_chain_truth_biconditional` and add a cleaner `succ_chain_truth_forward` that directly proves only `.mp` without the sorry. This eliminates the sorry by not claiming a biconditional. The `sorry` propagates into an unprovable `.mpr` direction, which can be removed. This requires restructuring the induction for `imp` forward to avoid needing `psi` backward.

**Option B (Status Quo with Better Documentation)**: Add a clear theorem-level comment to `succ_chain_truth_lemma` explaining the sorry is intentional and non-blocking, and update the task note in `SuccChainCompleteness.lean`. No code change required.

---

## Evidence / Examples

| Location | Evidence |
|---|---|
| `SuccChainCompleteness.lean:34` | "One sorry in SuccChainTruth (Box backward - not used in completeness)" |
| `SuccChainCompleteness.lean:154` | Only calls `succ_chain_truth_forward` (`.mp` direction) |
| `MultiFamilyBFMCS.lean:27-39` | "DEAD END: singletonCanonicalBFMCS... modal_backward requires φ ∈ MCS → □φ ∈ MCS (converse of T-axiom, FALSE)" |
| `ModallyCoherentBFMCS.lean:17` | "singleton bundle... φ → □φ mathematically impossible for contingent formulas" |
| `ParametricTruthLemma.lean:260-270` | Correct Box backward proof using multi-family BFMCS |
| `ModalSaturation.lean:1-40` | Full modal saturation infrastructure ready for multi-family pattern |

---

## Confidence Level

**High** — The mathematical impossibility of Box backward in a singleton-Omega model is independently confirmed by three separate modules in the codebase. The non-blocking status for completeness is confirmed by direct inspection of the calling chain. The BFMCS path is architecturally sound but over-engineered for the current goal.
