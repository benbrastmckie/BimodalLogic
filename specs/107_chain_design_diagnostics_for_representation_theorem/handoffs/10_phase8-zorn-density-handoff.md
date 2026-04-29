# Handoff: Phase 8 — Zorn Sorry and Density Sorry Analysis

**Session**: sess_1746051812_phase8
**Date**: 2026-04-29
**Phase**: 8 (Zorn sorry + density sorry)

## Status

- **Zorn sorry** (RRelation.lean:772): NOT CLOSED. Analyzed in depth; see below.
- **Density sorry**: ALREADY CLOSED. `eliminate_density_counterexample` is sorry-free.
- **Remaining sorries in CounterexampleElimination.lean**: 2 (lines 412, 510) — C4/C4' hard cases, NOT density sorries.

## Zorn Sorry Analysis

### Location
`RRelation.lean:772` inside `burgessR3Maximal_extension_exists`.

### Goal State
```
case neg
A C : Set Formula
_h_mcs_A : SetMaximalConsistent A
_h_mcs_C : SetMaximalConsistent C
S : Set Formula
h_dcs : SetDeductivelyClosed S
h_r3 : burgessR3 A S C
h_S_in : S ∈ burgessR3DCSExtensions A S C
B : Set Formula
hB_max : ∀ ⦃y : Set Formula⦄, (fun x ↦ x ∈ burgessR3DCSExtensions A S C) y → B ≤ y → y ≤ B
hSB : S ⊆ B
hB_dcs : SetDeductivelyClosed B
hB_r3 : burgessR3 A B C
D : Set Formula
hD_cud : ClosedUnderDerivation D
hBD : B ⊂ D
hD_r3 : burgessR3 A D C
hD_cons : ¬SetConsistent D
⊢ False
```

### Why the Proof Is Blocked

The sorry corresponds to the case where D is an inconsistent (¬SetConsistent D) ClosedUnderDerivation set satisfying burgessR3(A, D, C).

Since D is inconsistent and ClosedUnderDerivation, `⊥ ∈ D` (by DCS derivability).

From `hD_r3.1 : burgessRSet A D C` with β = ⊥: for all γ ∈ C, `untl ⊥ γ ∈ A`.

This is `burgessR A ⊥ C`. From `burgessR_implies_burgessRSince`, this is equivalent to `burgessRSince C ⊥ A`, which is also directly given by `hD_r3.2` with β = ⊥.

**The fundamental problem**: to derive `False`, we need to show `untl ⊥ γ ∈ A` leads to a contradiction with A being an MCS. But:

1. `untl ⊥ γ → ⊥` is NOT provable in BX without BX9 (until_elim), which was removed as unsound under open guard semantics.
2. Under discrete frame semantics, `untl ⊥ γ` is satisfiable (witness at the immediate successor).
3. The BX7 approach: taking φ₁ = γ, φ₂ = neg γ ∈ Set.univ, BX7 gives a disjunction in A, but extracting a specific disjunct that yields `F(X)` where `G(¬X) ∈ A` is a theorem cannot be guaranteed.
4. The BX4 + BX10 argument used in `burgessR_implies_burgessRSince` step 1: applying this with β = ⊥ gives case split: either H(¬α) ∈ C (→ contradiction via G(P(α)) ∈ A vs F(H(¬α)) ∈ A) OR P(α) ∈ C. The second case gives `P(α) ∈ C` for all α ∈ A, which is not contradictory.

**Confirmed by**: `Boneyard/XuLemma321.lean` which documents the same blocker for Xu's Lemma 3.2.1.

**Conclusion**: The sorry cannot be closed proof-theoretically without a density axiom (`untl ⊥ γ → ⊥` or equivalent).

### BX4 + BX10 Case-Split Partial Proof

The ONLY partial progress is: if we can show H(¬α) ∈ C for some specific α ∈ A, the contradiction goes through. Specifically:

- From `burgessR A ⊥ C`: `untl ⊥ (H(¬α)) ∈ A` (if H(¬α) ∈ C)
- By BX10: `F(H(¬α)) ∈ A`
- By BX4: `G(P(α)) ∈ A` (from α ∈ A)
- Since `F(H(¬α)) = neg(G(P(α)))` definitionally: contradiction

But we cannot FORCE `H(¬α) ∈ C` — it depends on the specific MCS C.

### Possible Resolutions

1. **Change BurgessR3Maximal back to SetDeductivelyClosed maximality**:
   - Changes `∀ D, ClosedUnderDerivation D → B ⊂ D → ¬burgessR3 A D C` to `∀ D, SetDeductivelyClosed D → B ⊂ D → ¬burgessR3 A D C`
   - Removes the Zorn sorry (inconsistent D is not SetDeductivelyClosed, case doesn't arise)
   - Breaks `g_content_sub_B_of_BurgessR3Maximal` (inconsistent case, lines 835-839 in PointInsertion.lean)
   - That inconsistent case currently uses `h_r3m.2.2 Set.univ set_univ_closed_under_derivation (dcs_ssubset_univ h_r3m.1) h_r3_univ`
   - With SetDeductivelyClosed maximality, Set.univ can't be used (not consistent)
   - Need ALTERNATIVE proof of `g_content_sub_B` inconsistent case

2. **Prove g_content_sub_B inconsistent case directly without Set.univ**:
   In the inconsistent case: `φ.neg ∈ B`, `G(φ) ∈ A`, `burgessR3(A, B, C)`, `h_gc: g_content(A) ⊆ C`.
   - `φ ∈ g_content(A)` → `φ ∈ C` (from h_gc)
   - `untl(φ.neg, φ) ∈ A` (from burgessR3(A,B,C) with β = φ.neg ∈ B, γ = φ ∈ C)
   - `G(φ) ∈ A` + `G_ex_falso_strengthen`: `G(φ.neg → ψ) ∈ A` for any ψ
   - `untl_left_mono_G`: `untl(ψ, φ) ∈ A` for any ψ... not contradictory

   Alternative via BX4+BX10 contradiction:
   - `G(φ) ∈ A` → by BX10 from `untl(φ.neg, H(¬G(φ))) ∈ A` (if H(¬G(φ)) ∈ C):
     `F(H(¬G(φ))) ∈ A`
   - `G(P(G(φ))) ∈ A` from BX4 + G(φ) ∈ A
   - `F(H(¬G(φ))) = neg(G(P(G(φ))))`: contradiction
   But: `H(¬G(φ)) = H(F(¬φ))` must be in C. Is it? Unclear.

   This approach seems promising but requires showing H(F(¬φ)) ∈ C or NOT in C (the complement case gives a different argument).

3. **Add hypothesis `¬burgessR3 A Set.univ C` to `burgessR3Maximal_extension_exists`**:
   - Callers must discharge this precondition
   - At `burgessR3Maximal_from_g_content_sub`, this might be provable from `g_content(A) ⊆ C` + h_gc structure
   - At other call sites, might be harder

4. **Accept the sorry and proceed**: The sorry was already present before Phase 5b (just in a different form). The sorry chain is: burgessR3Maximal_extension_exists → burgessR3Maximal_exists_from_seed → burgessR3Maximal_from_g_content_sub → everything else. If this sorry is accepted, the chronicle construction is still sorry-polluted.

### Recommended Resolution

Option 1 (revert to SetDeductivelyClosed maximality) with Option 2 (prove g_content_sub_B inconsistent case differently).

The key for Option 2: In the inconsistent case, `φ.neg ∈ B` and `G(φ) ∈ A` and `h_gc: g_content(A) ⊆ C`. Note:
- `φ ∈ g_content(A)` means `G(φ) ∈ A` means `φ ∈ C` (from h_gc). So φ ∈ C.
- `φ.neg ∈ B` and `φ ∈ C` and `burgessR3(A, B, C)`: `untl(φ.neg, φ) ∈ A`
- By BX5 (self_accum_until): `untl((φ.neg ∧ untl(φ.neg, φ)), φ) ∈ A`
- By BX7: ... this leads to the same BX7 → untl(⊥, ?) problem

Actually the simplest approach: if `φ.neg ∈ B` and `φ ∈ C` and `burgessR3(A, B, C)`, derive:
`untl(φ.neg, φ) ∈ A`. Apply `burgessR_implies_burgessRSince` step 1 argument to β = φ.neg and α = G(φ) ∈ A:
- Either H(¬G(φ)) ∈ C: `untl(φ.neg, H(¬G(φ))) ∈ A`, F(H(¬G(φ))) ∈ A, G(P(G(φ))) ∈ A from BX4. Contradiction!
- Or P(G(φ)) ∈ C: `some_past (all_future φ) ∈ C`. This is consistent with C being MCS.

So again, only one of the two MCS cases gives contradiction. The other case (P(G(φ)) ∈ C) is not contradictory on its own.

**CONCLUSION**: The Zorn sorry (and the related inconsistent case in g_content_sub_B) cannot be closed without density axioms in the current BX axiom system. The proof-theoretic tools are insufficient.

## Density Sorry Status

`eliminate_density_counterexample` at lines 620-651 is ALREADY SORRY-FREE. The instruction to "close the density sorry" is moot — there is no density sorry.

## CounterexampleElimination.lean Remaining Sorries

Lines 412 and 510 are the C4/C4' hard cases. These require BurgessR3Maximal for adjacent pairs. Before Phase 7, these were supposed to use c2' (BurgessR3Maximal for g(w,w_next)). With c2' removed from the omega_chain invariant, these sorries cannot be closed without a different argument.

These are the same as the "C5 g-value construction" from Phase 9 — they require knowing BurgessR3Maximal holds for the interval g(w, w_next) where (w, w_next) are adjacent in the chronicle.

### What's Available

1. `g_content_sub_B_of_BurgessR3Maximal` (sorry-free) — uses h_r3m.2.2 (Zorn-sorry-polluted)
2. `burgessR3Maximal_from_g_content_sub` — sorry-polluted (via Zorn sorry chain)
3. `lemma_2_6_splitting` — sorry-polluted (from PointInsertion.lean)

The C4 hard case at line 412 needs: given adjacent (w, w_next) in the chronicle with burgessR3 conditions, find D ∈ (f(w), f(w_next)) such that `¬γ ∈ D`. This is Lemma 2.7 (splitting), which is Phase 6.

## Files NOT Modified

Both RRelation.lean and CounterexampleElimination.lean remain unchanged from Phase 7 results. The Zorn sorry at RRelation.lean:772 was analyzed but not closed.

## Next Steps for Future Agent

1. If the goal is to close the Zorn sorry: investigate adding density axioms to BX, or accept the sorry as a known limitation.

2. If the goal is to close the C4/C4' hard cases (lines 412, 510): implement Lemma 2.7 (Phase 6, splitting_lemma) first, then use it here. The C4 hard case requires finding a BurgessR3Maximal extension — use `burgessR3Maximal_from_g_content_sub` once the Zorn chain is resolved, or add specific hypotheses at call sites.

3. The comment in Phase 8 of the plan says: "the density construction only needs to produce a new point z between x and y with some f(z) and valid f_agrees/g_agrees" — this is ALREADY done in `eliminate_density_counterexample` (line 620-651). No sorry there.

4. The C4 hard case (lines 412, 510) is actually Phase 6 (Lemma 2.7) territory, not Phase 8.
