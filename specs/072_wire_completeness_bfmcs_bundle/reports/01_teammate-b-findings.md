# Task 72: Teammate B Findings — Alternative Approaches and Prior Art

**Date**: 2026-03-31
**Focus**: FMP path, fair-scheduling, alternative BFMCS constructions, prior art
**Note**: This file was initially populated by Teammate A. Teammate B's full findings follow.

---

## Key Findings

### 1. FMP Path (semantic_weak_completeness) — Not a Bypass

The `semantic_weak_completeness` reference mentioned in task 70 is NOT a separate sorry-free
completeness theorem that exists. It is referenced in comments within `SuccChainTruth.lean`
and `SuccChainFMCS.lean` as "use this instead" guidance, pointing to:

- `FMP/SemanticCanonicalModel.lean` — this file does NOT exist in the codebase
- The FMP infrastructure at `Metalogic/Decidability/FMP/*.lean` does NOT contain a
  `semantic_weak_completeness` theorem

The actual FMP path (in `Decidability/FMP/FMP.lean`, `TruthPreservation.lean`) has its own
sorries: `mcs_all_future_closure` and `mcs_all_past_closure` (TruthPreservation.lean:256-281)
are both sorry due to a semantic mismatch: `(G(psi) → psi)` and `(H(psi) → psi)` are
NOT valid in strict temporal semantics. The FMP proof strategy needs redesign and is not
sorry-free.

**Conclusion**: The FMP path is NOT a working bypass. It has its own open sorries.

### 2. Bundle-Level Coherence — A COMPLETE SORRY-FREE CONSTRUCTION EXISTS

This is the most important finding. `UltrafilterChain.lean` contains a complete,
sorry-free `BFMCS_Bundle` structure and `construct_bfmcs_bundle` function:

**Lines 5633-5660** (`UltrafilterChain.lean`): `BFMCS_Bundle` structure with:
- `modal_forward`, `modal_backward` (S5 modal coherence)
- `bundle_forward_F`: F(phi) in fam.mcs(t) → ∃ fam' ∈ families, ∃ s > t, phi ∈ fam'.mcs(s)
- `bundle_backward_P`: P(phi) in fam.mcs(t) → ∃ fam' ∈ families, ∃ s < t, phi ∈ fam'.mcs(s)

**Lines 5518-5614** (key theorems, ALL SORRY-FREE):
- `boxClassFamilies_bundle_forward_F` — PROVED (no sorry)
- `boxClassFamilies_bundle_backward_P` — PROVED (no sorry)
- `boxClassFamilies_bundle_temporally_coherent` — PROVED (no sorry)

**Lines 5728-5752** (construction):
- `construct_bfmcs_bundle` — PROVED (no sorry), produces a `BFMCS_Bundle` from any MCS M0
- `construct_bfmcs_bundle_temporally_coherent` — PROVED (no sorry)

The **key insight** that makes this work: witnesses for F(phi) live in a DIFFERENT family
(built as `shifted_fmcs(SuccChainFMCS(W), t+1)`), not the same family. This avoids the
chain-level F-persistence problem which is mathematically false.

### 3. The Remaining Gap: Bundle-Level vs Family-Level Coherence

The truth lemma (`ParametricTruthLemma.lean`) requires family-level coherence:
`BFMCS.temporally_coherent` (same-family witnesses), not bundle-level coherence.

From `UltrafilterChain.lean` lines 5754-5781 (the codebase documents this gap explicitly):
> "Step 3 requires `B.temporally_coherent` (family-level forward_F/backward_P).
> The sorry-free bundle construction provides only bundle-level coherence.
> The gap between bundle-level and family-level coherence is the remaining blocker."

The `BFMCS.temporally_coherent` predicate (TemporalCoherence.lean:218-222) requires:
- For EACH fam in families: F(phi) ∈ fam.mcs(t) → ∃ s ≥ t, phi ∈ **fam**.mcs(s)
- For EACH fam in families: P(phi) ∈ fam.mcs(t) → ∃ s ≤ t, phi ∈ **fam**.mcs(s)

This is STRICTLY STRONGER than `BFMCS_Bundle`'s bundle-level requirement.

### 4. Restricted Chain Path — PARTIALLY SORRY-FREE

`SuccChainFMCS.lean` contains `RestrictedTemporallyCoherentFamily` built over
`DeferralRestrictedMCS` (MCS restricted to subformula closure). Key status:

- `restricted_forward_chain_forward_F` — **SORRY-FREE** (lines 2930-2934)
  - Uses `restricted_forward_chain_F_resolves` → `restricted_forward_chain_f_content_persistence`
  - F-obligations are resolved in one step due to bounded F-nesting within closure
- `restricted_backward_chain_backward_P` — **HAS SORRIES** (lines 5386, 5740)
  - Two "semantically unreachable" sorry branches in fuel-bounded recursion helpers
  - Status comment: "semantically unreachable with sufficient initial fuel"

The backward P path uses `restricted_backward_bounded_witness` → `restricted_backward_bounded_witness_fueled`
which has sorry branches at fuel=0 that are claimed to be unreachable.

### 5. Truth Lemma Gap in RestrictedTruthLemma.lean

`RestrictedTruthLemma.lean` has sorries at lines 116 and 158 for G-propagation and H-step
lemmas. These are marked as "pending Phase 4 requirements analysis."

### 6. Alternative Algebraic Path: BFMCS_Bundle Truth Lemma (Not Yet Written)

The codebase comment (UltrafilterChain.lean:5771-5780) identifies the path forward:
a **bidirectional truth lemma for BFMCS_Bundle** that uses bundle-level F/P coherence
instead of family-level. The key question is whether the backward G/H cases of the truth
lemma can be proved using bundle-level witnesses.

**The mathematical analysis**: The backward G proof uses:
1. Assume G(psi) not in fam.mcs(t)
2. neg(G(psi)) ∈ fam.mcs(t) → F(neg psi) ∈ fam.mcs(t)
3. By forward_F: ∃ s > t with neg(psi) ∈ fam.mcs(s)    ← requires SAME-family witness
4. Hypothesis says: psi holds at all s ≥ t (semantic, evaluated along `to_history(fam)`)
5. Contradiction: psi and neg(psi) both in fam.mcs(s)

Step 3-4 require the witness to be in the SAME family because step 4 evaluates along
`to_history(fam)`, not `to_history(fam')`. A witness in fam' would be in a different
history and step 4 would not apply.

**This confirms**: The bundle-level construction alone cannot directly fix the truth lemma
backward G/H cases. A fundamentally different semantic argument is needed.

---

## Recommended Approach

### Option B: Bundle-Level Truth Lemma with Cross-Family Semantics

The most promising path is to define a new truth lemma that matches `BFMCS_Bundle`:

**Semantic reinterpretation**: For `BFMCS_Bundle`, define truth of G(psi) as:
> G(psi) is true at (fam, t) iff for ALL s > t, psi is true at **SOME fam' with phi at s**

This is the "bundle semantics" interpretation compatible with `bundle_forward_F`.
The truth lemma backward G case would then use:
1. Assume G(psi) ∉ fam.mcs(t)
2. F(neg psi) ∈ fam.mcs(t)
3. By bundle_forward_F: ∃ fam' ∈ families, ∃ s > t, neg(psi) ∈ fam'.mcs(s)
4. By hypothesis (bundle semantics): psi is true at (fam', s) for some fam' with phi at s
5. By backward IH applied to fam': psi ∈ fam'.mcs(s) — contradiction!

This WOULD work if the semantic hypothesis in step 4 uses bundle semantics rather than
family-local history semantics.

**However**: This requires a new `TaskModel` and `truth_at` definition compatible with
bundle semantics, which is a significant refactor.

### Option A: Restricted Family Path (Most Conservative)

The `RestrictedTemporallyCoherentFamily` path is closest to sorry-free completeness:
- `restricted_forward_chain_forward_F` is already sorry-free
- The backward P sorry in `restricted_backward_bounded_witness_fueled` is claimed
  unreachable — if proven unreachable, the restricted path would work
- This gives formula-restricted completeness (for formulas in deferralClosure)
- To get full completeness, the formula-restricted model suffices (standard technique)

**Action items for Option A**:
1. Verify the "unreachable" sorry claims in `restricted_backward_bounded_witness_fueled`
   (lines 5386, 5740) can be replaced by `Nat.rec_aux` showing `fuel = B*B+1` suffices
2. Prove the G-propagation sorry in `RestrictedTruthLemma.lean:116`
3. Prove the H-step sorry in `RestrictedTruthLemma.lean:158`
4. Wire `RestrictedTruthLemma.restricted_truth_lemma` into the completeness theorem

---

## Evidence/Examples (Line References)

| Item | File | Lines | Status |
|------|------|-------|--------|
| `BFMCS_Bundle` structure | `UltrafilterChain.lean` | 5633-5660 | Sorry-free |
| `boxClassFamilies_bundle_forward_F` | `UltrafilterChain.lean` | 5518-5556 | **Sorry-free** |
| `boxClassFamilies_bundle_backward_P` | `UltrafilterChain.lean` | 5563-5600 | **Sorry-free** |
| `boxClassFamilies_bundle_temporally_coherent` | `UltrafilterChain.lean` | 5605-5614 | **Sorry-free** |
| `construct_bfmcs_bundle` | `UltrafilterChain.lean` | 5728-5739 | **Sorry-free** |
| `construct_bfmcs_bundle_temporally_coherent` | `UltrafilterChain.lean` | 5750-5752 | **Sorry-free** |
| `boxClassFamilies_bundle_temporally_coherent` gap analysis | `UltrafilterChain.lean` | 5754-5781 | Documents gap |
| `restricted_forward_chain_forward_F` | `SuccChainFMCS.lean` | 2930-2934 | **Sorry-free** |
| `restricted_backward_chain_backward_P` | `SuccChainFMCS.lean` | 5459-5544 | Has sorries (claimed unreachable) |
| `BFMCS.temporally_coherent` definition | `TemporalCoherence.lean` | 218-222 | Definition |
| FMP path: sorry-laden | `TruthPreservation.lean` | 256-281 | Has sorries |
| `semantic_weak_completeness` — does not exist | (no file found) | — | Missing |
| Truth lemma bidirectionality analysis | `ParametricTruthLemma.lean` | 25-70 | Documents gap |
| RestrictedTruthLemma G-propagation sorry | `RestrictedTruthLemma.lean` | 110-116 | Sorry |
| RestrictedTruthLemma H-step sorry | `RestrictedTruthLemma.lean` | 154-158 | Sorry |

---

## Confidence Level

**High confidence**:
- `semantic_weak_completeness` does not exist as a sorry-free theorem
- `BFMCS_Bundle` construction is sorry-free (verified by reading full proofs)
- Bundle-level vs family-level coherence gap is real and documented
- Truth lemma backward G/H structurally requires same-family witnesses

**Medium confidence**:
- Option A (restricted path) is closeable if the "unreachable" sorry claims are justified
- Option B (bundle semantics) is mathematically sound but needs significant new proof work
- The `restricted_backward_bounded_witness_fueled` sorry branches may genuinely be unreachable

**Low confidence**:
- Whether the fuel=0 sorry branches in the backward chain can be proven unreachable without
  structural recursion redesign

---

## Open Questions

1. **Can `restricted_backward_bounded_witness_fueled` fuel=0 branches be proven unreachable?**
   The fuel `B*B+1` (where `B = closure_F_bound phi`) is argued sufficient. Is there a
   clean termination argument that avoids the sorry?

2. **Does `RestrictedTruthLemma.restricted_truth_lemma` exist in a sorry-free form?**
   The module has sorries in the G-propagation and H-step helpers (lines 116, 158).
   Are these blocking the full truth lemma or just helpers that may not be needed?

3. **What is the exact signature of `restricted_truth_lemma` in RestrictedTruthLemma.lean?**
   The existing file structure suggests it may be defined conditionally.

4. **Could the Z_chain approach work if we redesign OmegaFMCS to use dovetailing?**
   The dovetailed omega chain section (UltrafilterChain.lean:5873-6200) describes a
   construction that would resolve ALL F-obligations. Is this closer to completion?

5. **Is the `construct_bfmcs` callback signature in `parametric_algebraic_representation_conditional`
   compatible with `construct_bfmcs_bundle`?** The former requires `BFMCS D` (with
   `BFMCS.temporally_coherent`), but `construct_bfmcs_bundle` produces `BFMCS_Bundle`.
   These are different types — wiring would require either a type conversion or a new
   variant of `parametric_algebraic_representation_conditional` for `BFMCS_Bundle`.

---

## Supplementary Findings (Teammate B Additional Analysis)

### Exact Sorry Map for SuccChainFMCS.lean

Actual `sorry` tactic calls (not just comments) in `SuccChainFMCS.lean`:

| Line | Theorem | Nature |
|------|---------|--------|
| 1734 | `g_content_union_brs_consistent` | Multi-BRS case: G-wrapping fails for multiple BRS elements |
| 1763 | `augmented_seed_consistent` | Delegates to above (same sorry) |
| 2082 | `constrained_successor_seed_restricted_consistent` | Multi-BRS case: same structural gap |
| 5386 | `restricted_backward_bounded_witness_fueled` | fuel=0, `d ≥ 1`: claimed semantically unreachable |
| 5544 | `restricted_combined_bounded_witness_fueled` | fuel=0, `d ≥ 1`: claimed semantically unreachable |
| 5740 | `restricted_combined_bounded_witness_P_fueled` | fuel=0, `d ≥ 1`: claimed semantically unreachable |

The multi-BRS sorry (lines 1734, 1763, 2082) is the **same structural gap** repeated: when a
derivation `L ⊢ ⊥` uses multiple boundary_resolution_set elements simultaneously, the single-BRS
consistency argument cannot be extended without a more careful proof.

The fuel-0 sorries (lines 5386, 5544, 5740) all have the form:
```lean
| 0 => ... | _ + 1 => exact ⟨pos, by omega, by sorry⟩
```
The callers use `fuel = B * B + 1` where `B = closure_F_bound phi`. The unreachability claim
requires: depth of F/P nesting in deferralClosure phi is bounded by B*B+1, so fuel never hits 0.

### Fair-Scheduling: FPreservingForwardChain is Sorry-Free (Forward Only)

`UltrafilterChain.lean` contains a **sorry-free Nat-indexed** dovetailed chain:
- `omega_chain_F_preserving_forward`: Dovetailed chain using `Nat.unpair` for F-obligation scheduling
- `omega_F_preserving_forward_F_resolution` (line 6858): **SORRY-FREE** forward_F theorem
- `FPreservingForwardChain` structure (line 6946): Packages the chain with sorry-free forward_F

The key selectFormulaToResolve mechanism at step n:
1. Decode `(t, k) = Nat.unpair(n)` where `k = encode(phi)`
2. If `F(phi) ∈ chain(n)` unresolved, put `phi` in chain(n+1)
3. This ensures at step `n0 = Nat.pair(t, encode(phi))`, if F(phi) persists, it gets resolved

**Status**: This is sorry-free for Nat-indexed chains (t ≥ 0). The Int extension still has
sorries in `Z_chain_forward_F` at the t < 0 branch (line 6531: `sorry` in backward chain case).

### The Bidirectional Int-Indexed Gap Remains Open

The `Z_chain` (Int-indexed) has two separate sorries:
- `Z_chain_forward_F` line 5352: phi ∉ chain(t), t ≥ 0 — gap between Z_chain and F-preserving chain
- `Z_chain_forward_F'` line 6531: t < 0 branch — F(phi) in backward chain, needs forward resolution

The `PPreservingBackwardChain` symmetric structure (Phase 6B, line 7096+) is being built
similarly. Together they would give a bidirectional Int-indexed sorry-free construction.

### Completeness Proof Chain Summary

```
discrete_completeness_fc         — WIRED (no own sorry)
  → completeness_over_Int        — WIRED
    → bundle_validity_implies_provability  — WIRED
      → bfmcs_from_mcs_temporally_coherent  — THE sorry (line 220-226)
        → requires succ_chain_forward_F for each boxClassFamily
          → restricted chain forward_F: sorry-free (SuccChainFMCS:2930)
          → restricted chain backward_P: 3 fuel-0 sorries (lines 5386, 5544, 5740)
          → restricted chain successor step: multi-BRS sorry (lines 1734, 1763, 2082)
```

### Dovetailed Chain vs Restricted Chain: Two Parallel Approaches

| Approach | Forward F | Backward P | Int Extension |
|----------|-----------|------------|---------------|
| Dovetailed (FPreservingForwardChain) | Sorry-free (Nat) | Symmetric (Phase 6B) | Partial sorry |
| Restricted chain (RestrictedTemporallyCoherentFamily) | Sorry-free | 3 fuel-0 sorries | Needs multi-BRS fix |

Both approaches have the same final gap: combining forward/backward into a full Int-indexed family.
