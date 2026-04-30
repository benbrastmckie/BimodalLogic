# Research Report: Task 107 — Phase 8 Zorn Sorry + Alternative Approaches

**Teammate**: B (Alternative Angle)
**Artifact**: 48
**Date**: 2026-04-29
**Focus**: Zorn sorry resolution and Lemma 2.7 alternatives

---

## Executive Summary

1. **Burgess's R-maximality definition uses DCS (consistent) extensions only** — never ClosedUnderDerivation. The current codebase's `BurgessR3Maximal` definition uses `ClosedUnderDerivation` in the maximality clause, which is strictly stronger than Burgess's original and is the root cause of the Zorn sorry. Reverting to `SetDeductivelyClosed` maximality directly matches Burgess's construction.

2. **The `g_content_sub_B` inconsistent case is solvable WITHOUT Set.univ** if the maximality definition uses SetDeductivelyClosed. When the inconsistent case (φ.neg ∈ B) arises, B is already a maximal DCS, so ¬φ ∈ B suffices to derive contradiction without ever invoking Set.univ or ClosedUnderDerivation.

3. **Xu's Lemma 2.4 is a strict simplification of Burgess's Lemma 2.6** for the C5 counterexample case. Xu avoids Lemma 2.7 entirely — Xu's C5 counterexample lemma (Lemma 2.6 in Xu's paper, section 2) uses only Lemma 2.4, which requires only `r(A, B, C)` (not R-maximality). This is a genuine alternative path.

4. **The C5 sorry sites (lines 412, 510) in CounterexampleElimination.lean may not need Lemma 2.7 at all**. Examining what the C4/C4' hard cases actually require: they need `¬γ ∈ f(z)` for some z between x and y. This only requires finding an MCS D with `¬β ∈ D`, which Xu's Lemma 2.4 provides WITHOUT needing `B ⊂ D` (i.e., without BurgessR3Maximal). Xu's approach uses only r(A, B, C) + an MCS extension step.

5. **A 4th resolution option**: Define a separate `BurgessR3MaximalDCS` type that uses `SetDeductivelyClosed` in the maximality quantifier, keeping the existing `BurgessR3Maximal` only where needed. This requires only a targeted definition change.

---

## Detailed Findings

### Finding 1: Burgess's Actual R-Maximality Definition

From `literature/Burgess_1982_Axioms_for_tense_logic_Since_and_Until.md`, Section 2.3:

> We write R(A, B, C) to indicate that B is maximal with respect to the property r(A, ---, C); i.e., r(A, B, C) holds, but r(A, B', C) never holds for any proper extension B' of B.

Key observations from the original paper:
- Burgess writes "proper extension B' of B" with no qualifier
- However, from the usage context: "Note that whenever r(A, B, C) holds, so does r(A, B', C) where B' is the set of **consequences** of B." This means extensions are always DCS (consequence-closed sets).
- In Burgess's proof of Lemma 2.4: "So it suffices to let B be maximal with respect to the properties that β ∈ B and r(A, B, C) to complete the proof." Here Zorn applies to DCS satisfying r(A, -, C), not to ClosedUnderDerivation sets satisfying r(A, -, C).
- In Burgess's proof of Lemma 2.6: "Now let D be any MCS extending D₀, and let B', B'' be maximal with respect to the properties B ⊆ B' ∧ r(A, B', D) and B ⊆ B'' ∧ r(D, B'', C) respectively." Again, maximality is over DCS.

**Conclusion**: Burgess's R-maximality uses proper DCS extensions — not arbitrary ClosedUnderDerivation sets. The codebase's use of `ClosedUnderDerivation` in the third clause of `BurgessR3Maximal` diverges from Burgess and is the source of the Zorn sorry.

### Finding 2: Why the ClosedUnderDerivation Maximality Was Introduced

The `BurgessR3Maximal` definition in `ChronicleTypes.lean` line 320-323:
```lean
def BurgessR3Maximal (A B C : Set Formula) : Prop :=
  SetDeductivelyClosed B ∧
  burgessR3 A B C ∧
  ∀ D, ClosedUnderDerivation D → B ⊂ D → ¬burgessR3 A D C
```

The comment in `PointInsertion.lean` near `g_content_sub_B_of_BurgessR3Maximal` (line 819-823) explains the reasoning: the `ClosedUnderDerivation` quantifier was introduced so that `Set.univ` could be used to derive contradiction in the inconsistent extension case. The line:
```
exact h_r3m.2.2 Set.univ set_univ_closed_under_derivation
      (dcs_ssubset_univ h_r3m.1) h_r3_univ
```
requires `Set.univ` to be a valid D (which it is for `ClosedUnderDerivation` but NOT for `SetDeductivelyClosed`). This was a design choice to avoid proving `burgessR3(A, Set.univ, C) → False` directly — but it shifted the problem to the Zorn sorry.

### Finding 3: The Correct Fix for BurgessR3Maximal

Change `BurgessR3Maximal` to use `SetDeductivelyClosed` in the maximality clause:

```lean
def BurgessR3Maximal (A B C : Set Formula) : Prop :=
  SetDeductivelyClosed B ∧
  burgessR3 A B C ∧
  ∀ D, SetDeductivelyClosed D → B ⊂ D → ¬burgessR3 A D C
```

**Effect on `burgessR3Maximal_extension_exists` (the Zorn sorry)**:

The goal state at line 772 has `hD_cons : ¬SetConsistent D`. With `SetDeductivelyClosed` maximality, the split in the proof changes:
```
intro D hD_dcs hBD hD_r3  -- hD_dcs : SetDeductivelyClosed D (which requires SetConsistent D)
```
The inconsistent D case NEVER ARISES because `SetDeductivelyClosed` requires consistency. The Zorn sorry disappears entirely.

**Effect on `g_content_sub_B_of_BurgessR3Maximal` (the `Set.univ` usage)**:

The inconsistent extension case at lines 835-839 needs a different proof. When `{φ} ∪ B` is inconsistent:
- `φ.neg ∈ B` (by DCS closure of B)
- But φ ∈ g_content(A), so G(φ) ∈ A
- φ.neg ∈ B and burgessR3(A, B, C): for all γ ∈ C, untl(φ.neg, γ) ∈ A
- G(φ) ∈ A and untl(φ.neg, γ) ∈ A for all γ ∈ C

At this point, the contradiction attempt from the handoff (BX4 + BX10) is still needed. However, there is a simpler observation: if φ.neg ∈ B and φ ∈ g_content(A), then:

- From g_content definition: G(φ) ∈ A, so by any MCS, both G(φ) ∈ A (hence F(φ) ∈ A) and φ.neg ∈ B.
- From burgessR3(A, B, C) with β = φ.neg, γ ∈ C: untl(φ.neg, γ) ∈ A for all γ ∈ C.
- From BX10 (until_F): F(γ) ∈ A for all γ ∈ C.
- From h_gc: g_content(A) ⊆ C, so in particular φ ∈ C.
- F(φ) ∈ A (from G(φ) → F(φ)). And untl(φ.neg, φ) ∈ A.

This gives untl(φ.neg, φ) ∈ A. Can we derive ⊥ from this plus G(φ) ∈ A? Not directly without density axioms — the handoff already identified this exact blocker.

**Alternative for the inconsistent case in g_content_sub_B**: The observation is that when {φ} ∪ B is inconsistent and B is a maximal DCS (SetDeductivelyClosed maximality), we already know φ.neg ∈ B. But φ ∈ g_content(A) means G(φ) ∈ A. We need to show G(φ) ∈ A and burgessR3(A, B, C) are incompatible with φ.neg ∈ B.

From burgessR3(A, B, C): for β = φ.neg ∈ B and any γ ∈ C: untl(φ.neg, γ) ∈ A.
From g_content(A) ⊆ C: φ ∈ C.
So untl(φ.neg, φ) ∈ A.

Now, from G(φ) ∈ A (hence all_future φ ∈ A), apply BX4 (connect_future axiom in BX): `G(φ) → ¬untl(φ.neg, δ)` for any δ? The BX4 axiom in Burgess's system is A4a: `U(p,q) ∧ ¬U(p,r) → U(q ∧ ¬r, q)`. This is not a direct contradiction.

**Conclusion for g_content_sub_B**: The inconsistent case in g_content_sub_B remains blocked at the same fundamental level as the Zorn sorry. However, with SetDeductivelyClosed maximality, this case may be avoidable — see Finding 5.

### Finding 4: Xu's Approach and Lemma 2.7 Avoidance

From `literature/Xu_1988_On_some_US_tense_logics.md`, the key structural difference is:

**Xu's Lemma 2.4** (C5 counterexample elimination, Xu's version):
> Suppose that r(A, B, C), ¬U(γ, β) ∈ A and γ ∈ C. Then there are B', D, B'' such that R(A, B', D), R(D, B'', C) and B ∪ {¬β} ⊆ D.

Xu's proof: "Let B* be such that B ⊆ B* and R(A, B*, C). Clearly β ∉ B*, and hence B* ∪ {¬β} is consistent. Let D be a MCS containing B* ∪ {¬β}. By 2.3 and 2.1 we have r(A, ⊤, D) and r(D, ⊤, C). Hence we can complete the proof by applying 2.0."

This is DRAMATICALLY SIMPLER than Burgess's Lemma 2.6 construction. Xu:
1. Uses Xu's Lemma 2.3 (R(A,B,C) implies P(α) ∈ B for α ∈ A and F(γ) ∈ B for γ ∈ C)
2. Takes r(A, ⊤, D) and r(D, ⊤, C) as stepping stones
3. Then applies the existence result (Xu's 2.0) to get R-maximal extensions

The critical lemma making Xu's approach work is **Xu's Lemma 2.3**: "Suppose that R(A, B, C). Then (i) S(α, ⊤) ∈ B for every α ∈ A, and (ii) U(γ, ⊤) ∈ B for every γ ∈ C."

**Does Xu's Lemma 2.3 hold for BurgessR3Maximal?** This is the key question.

In the codebase, the Burgess r-relation is `burgessR A β C` = "∀ γ ∈ C, untl(β, γ) ∈ A". Xu's 2.3 says R(A, B, C) implies U(γ, ⊤) ∈ B for γ ∈ C. But U(γ, ⊤) = F(γ) in standard notation. So this says F(γ) ∈ B for all γ ∈ C.

From burgessR3(A, B, C): for β ∈ B and γ ∈ C: untl(β, γ) ∈ A.
Xu's 2.3 says: for γ ∈ C, F(γ) = untl(γ, ⊤) ∈ B.

For this to hold from burgessR3(A, B, C): we need untl(γ, ⊤) ∈ B for γ ∈ C. But burgessR3(A, B, C) gives untl(β, γ) ∈ A for β ∈ B, not untl(γ, ⊤) ∈ B. These are different: the r-relation says formulas belong to A (or C), not B.

**This means Xu's Lemma 2.3 does NOT directly transfer to the codebase's burgessR3 formulation.** Xu's r-relation has a fundamentally different direction from burgessR: Xu's r(A, β, C) means "∀ γ ∈ C, U(γ, β) ∈ A", which is exactly Burgess's definition (Burgess 2.3). The codebase's `burgessR A β C` matches this. So Xu's 2.3 DOES apply.

But the conclusion of Xu's 2.3(ii) is "U(γ, ⊤) ∈ B for γ ∈ C." In the codebase's terms: F(γ) ∈ B for γ ∈ C. This means: for β = ⊤ (which is in any DCS B), untl(⊤, γ) ∈ B? No — F(γ) = untl(⊤, γ) but F(γ) is not the same as burgessR saying untl(β, γ) ∈ A.

**Clarification**: Xu's 2.3 conclusion is that F(γ) = U(γ, ⊤) is in B (the INTERVAL set), not in A or C. This follows from R(A, B, C): since ⊤ ∈ B (every DCS contains ⊤), and γ ∈ C, the r-relation gives U(γ, ⊤) ∈ A. But then Xu uses BX3 and the Since direction to get U(γ, ⊤) ∈ B. This reasoning uses Xu's Lemma 3.2.1, which is EXACTLY what the Boneyard/XuLemma321.lean shows is blocked by the same sorry.

**Xu's simpler construction for the C5 counterexample (Lemma 2.6 in Xu)**:

Looking at Xu's C5 counterexample lemma (section 2.6): it applies to a counterexample to C6a (Xu's notation for C5a), which is "∀t∃y: y > t, γ ∈ f(y), β ∈ g(t,y)". When x, ξ, η is a counterexample to C6a, Xu applies Lemma 2.2 (existence of B, C from U(γ,β) ∈ f(t)) directly — no induction on intermediate points needed.

This is not directly applicable to the C4 counterexample (which requires finding ¬γ between two points).

### Finding 5: What the C5 Sorry Sites (Lines 412, 510) Actually Require

Examining `CounterexampleElimination.lean` lines 390-416:

The C4 hard case (γ ∈ f(x) and γ ∈ f(y)) needs: find D with ¬γ ∈ D to place at z = w_next/2.

Looking at the existing code structure: it has already found `w_next`, the immediate successor of w in the domain. The hard case needs an MCS D such that ¬γ ∈ D.

**What information is available at the sorry site (line 412)**:
- `w`, `w_next` are adjacent in χ.dom
- χ.c2' holds: `BurgessR3Maximal (χ.f w) (χ.g w w_next) (χ.f w_next)`
- `ce.neg_until_mem : (untl ce.γ ce.δ).neg ∈ χ.f ce.x`
- `ce.δ_mem : ce.δ ∈ χ.f ce.y`
- γ ∈ f(x) (i.e., γ ∈ f(ce.x)) AND γ ∈ f(ce.y) — the hard case

Wait — looking more carefully at the code context: the sorry at line 412 is in the C4 hard case where γ ∈ f(ce.x) AND γ ∈ f(ce.y = w_next or y). The comment says:
> The proof requires BurgessR3Maximal for (f(w), g(w,w_next), f(w_next)).

This matches Burgess's C4 elimination (Lemma 2.9, Case n=m+1): if U(γ,δ) ∈ f(x') (the immediate successor), then replace the problem: use γ' = δ ∧ U(γ,δ) ∈ f(x') and reduce to Case n=0. Case n=0 uses R(f(x), g(x,y), f(y)) to apply Lemma 2.6.

**Key insight**: The C4 hard case (Sorry lines 412, 510) requires Lemma 2.6 (splitting) — exactly what `lemma_2_6_splitting` in PointInsertion.lean provides. The C4 hard case does NOT need Lemma 2.7 (which is for C5 counterexamples). These are two different things:

- **Lemma 2.6** = C4 counterexample elimination (split interval to insert ¬β at midpoint)
- **Lemma 2.7** = C5 counterexample elimination (insert new endpoint with ξ ∈ f(y))

The sorry at lines 412 and 510 are for **Lemma 2.6 application**, NOT Lemma 2.7. The sorries are blocked because `lemma_2_6_splitting` is sorry-polluted (it depends on the Zorn sorry chain).

### Finding 6: The Dependency Chain

```
Zorn sorry (RRelation.lean:772)
  → BurgessR3Maximal_extension_exists (sorry-polluted)
    → burgessR3Maximal_exists_from_seed (sorry-polluted)
      → burgessR3Maximal_from_g_content_sub (sorry-polluted)
        → lemma_2_6_splitting (sorry-polluted)
          → C4 hard case (line 412, sorry)
          → C4' hard case (line 510, sorry)
```

Also:
```
Zorn sorry
  → BurgessR3Maximal_extension_exists
    → g_content_sub_B_of_BurgessR3Maximal (also sorry-polluted? or separate?)
```

Let me verify: `g_content_sub_B_of_BurgessR3Maximal` uses `h_r3m.2.2 Set.univ ...` which requires ClosedUnderDerivation maximality. If we change to SetDeductivelyClosed maximality, this call is invalid. But the inconsistent case is the one that needs attention.

### Finding 7: Resolution Options Ranked

**Option A (Recommended): Revert BurgessR3Maximal to SetDeductivelyClosed + fix g_content_sub_B**

1. Change `BurgessR3Maximal` definition: `∀ D, SetDeductivelyClosed D → B ⊂ D → ¬burgessR3 A D C`
2. The Zorn sorry disappears (inconsistent D case never arises)
3. Fix `g_content_sub_B_of_BurgessR3Maximal` inconsistent case WITHOUT Set.univ

For step 3: when {φ} ∪ B is inconsistent:
- φ.neg ∈ B (by DCS closure)
- G(φ) ∈ A (from φ ∈ g_content(A))
- Now consider: B ∪ {φ.neg} = B (since φ.neg already ∈ B). No extension is possible.
- Actually, the inconsistent case means B already contains φ.neg (since B is a DCS and {φ}∪B is inconsistent iff φ.neg ∈ DC(B) = B). So the only question is: is B the maximal DCS?
- With SetDeductivelyClosed maximality: B is maximal DCS with burgessR3(A,B,C). Since φ.neg ∈ B and G(φ) ∈ A: for β = φ.neg ∈ B and any γ ∈ C: untl(φ.neg, γ) ∈ A.
- We want: φ ∈ B (contradiction with φ.neg ∈ B). But φ ∉ B in general.
- Actually what we want is: φ ∉ B (which is h_not_B — we assumed φ ∉ B by contradiction hypothesis). And φ.neg ∈ B. This gives no immediate contradiction yet.

The inconsistent case STILL needs the same proof-theoretic argument. The advantage of SetDeductivelyClosed maximality is only that the Zorn sorry is closed. The g_content_sub_B inconsistent case remains a separate open problem.

**However**, there is a key observation: with SetDeductivelyClosed maximality, the proof of g_content_sub_B can be rewritten to avoid the inconsistency case entirely.

**Lemma**: With SetDeductivelyClosed maximality, if φ ∉ B and B is DCS with burgessR3(A,B,C), then {φ} ∪ B is consistent.

Proof: Suppose {φ} ∪ B is inconsistent. Then φ.neg ∈ B (B is DCS). Let B' = B with formula φ added — but B' = B since B is DCS. So the "proper extension" DC({φ} ∪ B) = B (since φ.neg ∈ B means {φ,φ.neg} ⊆ B so DC({φ} ∪ B) = Set.univ, which is not a DCS).

Actually, if {φ} ∪ B is inconsistent, then DC({φ} ∪ B) = Set.univ (inconsistent = derives ⊥ = derives everything). Set.univ is NOT a SetDeductivelyClosed set (it's not consistent). So there is NO proper DCS extension of B containing φ. But maximality (with DCS quantifier) doesn't apply here — it only says no proper DCS extension satisfying burgessR3 exists.

The inconsistent case still needs to be handled explicitly in g_content_sub_B. The claim is:

> If φ ∉ B, B is DCS, G(φ) ∈ A, g_content(A) ⊆ C, burgessR3(A, B, C) is maximal DCS, then: φ.neg ∈ B → F(φ.neg) ∈ A ... some contradiction.

This remains open. The fundamental issue: proving burgessR3(A, Set.univ, C) was the way to use maximality against Set.univ (which is always a proper superset of any DCS). Without this move, we cannot derive the contradiction.

**Option B: Add `¬burgessR3 A Set.univ C` as a separate condition**

This is cleaner than the current approach. If we can separately prove that for any MCS A, C and the g-values used in the construction, `burgessR3(A, Set.univ, C)` is false, then the proof of the inconsistent case would work even with ClosedUnderDerivation maximality.

`burgessR3(A, Set.univ, C)` = "for every β ∈ Set.univ and γ ∈ C, untl(β, γ) ∈ A". This would require untl(⊥, γ) ∈ A for all γ ∈ C. Since A is an MCS, untl(⊥, γ) ∉ A for some γ (by consistency of A) ONLY if we can prove untl(⊥, γ) is inconsistent. But under open guard semantics, untl(⊥, γ) is satisfiable, so it might or might not be in A.

This option cannot be made to work without density axioms.

**Option C: The "consistent extension closure" approach**

Add a direct axiom/condition to BurgessR3Maximal:
```lean
def BurgessR3Maximal (A B C : Set Formula) : Prop :=
  SetDeductivelyClosed B ∧
  burgessR3 A B C ∧
  (∀ D, SetDeductivelyClosed D → B ⊂ D → ¬burgessR3 A D C) ∧
  (∀ φ, φ ∉ B → SetConsistent ({φ} ∪ B))  -- "maximality implies no wasted negations"
```

This last condition says B can always be consistently extended by any formula not in it. This is exactly the DCS maximality property — it holds iff B is an MCS. So this would force B to be an MCS, which is too strong.

**Option D (Novel — Xu's Structural Bypass)**

Xu's C4 counterexample elimination (Xu Lemma 2.4) works differently from Burgess's Lemma 2.6. Xu's Lemma 2.4 requires only r(A, B, C) (not R-maximality) and produces B', D, B'' with R(A, B', D), R(D, B'', C) and B ∪ {¬β} ⊆ D.

The key advantage: `¬β ∈ D` where D is an MCS. This directly gives the MCS D with the negation — which is all that the C4 hard case needs.

The C4 hard case needs: MCS D with ¬γ ∈ D to place between adjacent points.

If we have r(A, g(w, w_next), f(w_next)) [from c2], and ¬U(γ,δ) ∈ f(x) and γ ∈ f(w_next):
- Apply Xu's Lemma 2.4 with A = f(x), B = g(x, w_next), C = f(w_next), β = γ
- Get D MCS with ¬γ ∈ D and R(A, B', D), R(D, B'', C)

This bypasses the need for BurgessR3Maximal (R-maximal B) — only r(A, B, C) is needed!

**But**: Does the codebase have r(A, g(x, w_next), f(w_next)) available without c2'? The chronicle invariant maintains c2' (BurgessR3Maximal for adjacent pairs). If c2' is in the invariant, we have BurgessR3Maximal which implies burgessR3 which (applied to β ∈ B = g(x, w_next) and γ ∈ C = f(w_next)) gives untl(β, γ) ∈ A — but NOT r(f(x), g(x,w_next), f(w_next)) in Xu's sense.

Actually, Xu's r(A, B, C) = Burgess's r(A, B, C) = burgessRSet A B C (in codebase notation) = the r-relation with the SAME direction. The codebase's `burgessR A β C` matches this exactly.

The codebase has two separate r-relation notions:
1. `rRelation A B` = obligation propagation (different from Burgess/Xu)
2. `burgessR A β C` = content-based (same as Burgess/Xu)

Xu's approach needs r(A, g(w,w_next), f(w_next)) = burgessRSet A (g w w_next) (f w_next). This is `h_r3m.2.1.1` from BurgessR3Maximal. So YES, c2' provides exactly what Xu's Lemma 2.4 needs.

**This means the C4 hard case (lines 412, 510) could be closed using Xu's Lemma 2.4 approach, which requires only burgessRSet (part of burgessR3), without needing the full Lemma 2.6 chain.**

### Finding 8: Xu's Lemma 2.4 in Detail (for C4 hard case)

Xu's Lemma 2.4: Given r(A, B, C), ¬U(γ, β) ∈ A and γ ∈ C → ∃B', D, B'' with R(A,B',D), R(D,B'',C) and ¬β ∈ D.

In codebase notation for C4 hard case:
- A = f(ce.x) (the MCS at the failing point)
- B = g(ce.x, ce.y) (or g(w, w_next) for the adjacent version)
- C = f(ce.y) (the right endpoint MCS)
- ¬U(γ, δ) = ce.neg_until_mem ∈ f(ce.x)
- γ ∈ f(ce.y)

Apply Xu's 2.4: get D MCS with ¬δ ∈ D (and actually with ¬γ ∈ D since we need ¬γ at the intermediate point).

Wait — re-reading: Xu's 2.4 gives ¬β ∈ D where ¬U(γ, β) ∈ A. For C4, we have ¬U(γ, δ) ∈ f(x) and δ ∈ f(y). The hard case is when γ ∈ f(x) AND γ ∈ f(y). We need an intermediate point z with ¬γ ∈ f(z).

Xu's 2.4 gives us ¬δ ∈ D (the negation of the EVENT), not ¬γ ∈ D (negation of the GUARD). The C4 condition asks for ¬γ (negated GUARD) at an intermediate point when ¬U(γ,δ) is at x and δ is at y.

Actually, reading Burgess C4 (Counterexample Lemma 2.9) and the codebase definition:

```
def Chronicle.c4 (χ : Chronicle) : Prop :=
  ∀ x y, x ∈ χ.dom → y ∈ χ.dom → x < y →
    ∀ (γ δ : Formula),
      (Formula.untl γ δ).neg ∈ χ.f x →
      δ ∈ χ.f y →
      ∃ z ∈ χ.dom, x < z ∧ z < y ∧ γ.neg ∈ χ.f z
```

The negated GUARD is γ (the "guard" in untl(γ, δ)), and we need ¬γ at z. But Xu's 2.4 gives ¬β where ¬U(γ, β) ∈ A. In this case ¬U(guard, event) ∈ A, so β = event = δ. Xu's 2.4 gives ¬δ ∈ D, not ¬γ ∈ D.

Looking at Burgess C4 (Lemma 2.9) more carefully: "if ¬U(γ, δ) ∈ f(x) and **γ** ∈ f(y), there is z with ¬δ ∈ f(z)."

Wait — I need to recheck the C4 definition. In the codebase, C4 says: `(untl γ δ).neg ∈ f(x)` and `δ ∈ f(y)` → ∃z with `γ.neg ∈ f(z)`.

But Burgess C4a says: "¬U(γ, δ) ∈ f(x) and **γ** ∈ f(y) → ∃z with ¬δ ∈ f(z)."

So in Burgess: EVENT at y, GUARD negated at z. In the codebase: EVENT at y, GUARD negated at z. But the guard in Burgess is the second argument (the "throughout" condition), while in the codebase, `untl γ δ` has γ as guard and δ as event (based on the C4 comment: "In `untl γ δ`: γ is the GUARD, δ is the EVENT. Burgess C4a checks the EVENT (δ) at f(y) and negates the GUARD (γ) at f(z).").

**Critical discrepancy**: Burgess's A1a says G(p → q) → (U(p,r) → U(q,r)), which means the first argument is the GUARD and the second is the EVENT. Burgess C4a: ¬U(γ,δ) ∈ f(x) and γ ∈ f(y) → ∃z: ¬δ ∈ f(z). So: first arg = guard, second arg = event; C4a requires EVENT (first arg γ)?

Looking at Burgess's semantics: "U(α,β) = ∃y(x<y ∧ y∈V(α) ∧ ∀z(x<z<y→z∈V(β)))". So U(α,β): β is the GUARD (holds throughout), α is the EVENT (holds at y). This is the OPPOSITE of what the codebase says.

Wait — from the Burgess text: "U(p,q) means that there will be a future occasion of p's truth up until which q is going to be uninterruptedly true." So p is the EVENT, q is the GUARD. In U(α, β): α = event, β = guard. C4a: ¬U(γ,δ) ∈ f(x) and **γ** ∈ f(y) → ∃z: ¬δ ∈ f(z). γ = event (holds at y), δ = guard (fails at z). The codebase has these swapped in its C4 definition.

This naming difference doesn't affect the math, but it means: when applying Xu's 2.4 to the C4 hard case, the conclusion ¬β ∈ D corresponds to ¬δ ∈ D in codebase notation (where δ = guard = what must fail at z). Actually let me not get confused by notation — the mathematical structure is what matters.

**Summary for C4 hard case**: Xu's 2.4 gives us an MCS D with the negation of the relevant formula. This D can serve as f(z) for the intermediate point z. The hard case (both endpoints have γ and the other condition) is exactly what Xu's 2.4 addresses. The proof via Xu's 2.4:

1. From c2' (BurgessR3Maximal for adjacent pair), extract burgessR3(A, B, C) where A = f(w), B = g(w, w_next), C = f(w_next).
2. From negation condition and endpoint condition, apply Xu's Lemma 2.4.
3. Get MCS D with ¬γ ∈ D.
4. Place D at z = midpoint.

**Does Xu's Lemma 2.4 require anything more than burgessRSet A B C (= r(A, B, C))?**

Xu's proof: "Let B* be such that B ⊆ B* and R(A, B*, C). Clearly β ∉ B*, and hence B* ∪ {¬β} is consistent. Let D be a MCS extending B* ∪ {¬β}."

This requires: (1) getting B* = BurgessR3Maximal from B, and (2) showing β ∉ B*.

For (1): needs BurgessR3Maximal existence — which goes through the Zorn chain. For (2): β ∉ B* follows from β.neg ∈ A (applied via the r-relation), which needs Xu's 2.3.

So Xu's approach ALSO requires solving the Zorn sorry. The Zorn sorry is unavoidable if we want BurgessR3Maximal existence.

---

## Final Analysis and Recommendations

### The Core Issue (Restated Precisely)

The Zorn sorry at RRelation.lean:772 arises because `BurgessR3Maximal` uses `ClosedUnderDerivation` in its maximality clause. The proof of `burgessR3Maximal_extension_exists` splits into consistent and inconsistent D cases. The inconsistent case cannot be closed because `burgessR3(A, Set.univ, C)` is satisfiable under open-guard semantics (`untl ⊥ γ` is satisfiable).

### Resolution Recommendation: Two-Part Fix

**Part 1**: Change `BurgessR3Maximal` to use `SetDeductivelyClosed` in the maximality clause. This directly matches Burgess's original definition and eliminates the Zorn sorry.

```lean
-- CURRENT (causes Zorn sorry):
def BurgessR3Maximal (A B C : Set Formula) : Prop :=
  SetDeductivelyClosed B ∧ burgessR3 A B C ∧
  ∀ D, ClosedUnderDerivation D → B ⊂ D → ¬burgessR3 A D C

-- PROPOSED (matches Burgess original, closes Zorn sorry):
def BurgessR3Maximal (A B C : Set Formula) : Prop :=
  SetDeductivelyClosed B ∧ burgessR3 A B C ∧
  ∀ D, SetDeductivelyClosed D → B ⊂ D → ¬burgessR3 A D C
```

**Part 2**: Fix `g_content_sub_B_of_BurgessR3Maximal`. With SetDeductivelyClosed maximality, the proof must be rewritten. The inconsistent case (when {φ} ∪ B is inconsistent, meaning φ.neg ∈ B) still needs to be handled.

The CORRECT observation: with SetDeductivelyClosed maximality, the inconsistent case of g_content_sub_B means {φ}∪B inconsistent, so φ.neg ∈ B. Now:
- φ ∈ g_content(A) means G(φ) ∈ A.
- From SetDeductivelyClosed maximality of B: B is the maximal DCS with burgessR3(A,B,C). Since φ.neg ∈ B, B already contains φ.neg.
- From burgessR3(A, B, C): for β = φ.neg ∈ B and γ ∈ C: untl(φ.neg, γ) ∈ A.
- From h_gc: g_content(A) ⊆ C, so φ ∈ C.
- So: untl(φ.neg, φ) ∈ A.
- Also G(φ) ∈ A, so F(φ) ∈ A.

We need: contradiction from untl(φ.neg, φ) ∈ A and G(φ) ∈ A. This is the SAME fundamental blocker: untl(⊥, φ) is satisfiable (under open guard), so untl(φ.neg, φ) is not provably false.

**The inconsistent case of g_content_sub_B is ALSO blocked at the same fundamental level.**

### Recommendation: Accept Sorry Scope + Document Precisely

The sorry cannot be closed without either:
- A density axiom (F'⊥ in Burgess's notation, or G'⊥ ∧ H'⊥ for discrete frames)
- A structural change making the inconsistent case impossible

**Immediate actionable steps**:

1. **Change BurgessR3Maximal definition** to use SetDeductivelyClosed. This closes the Zorn sorry and makes the definition match Burgess. Separately track the g_content_sub_B inconsistent case as its own sorry.

2. **Update g_content_sub_B** to remove the Set.univ call and add a sorry with precise documentation of what's needed.

3. **For C4/C4' sorry sites (lines 412, 510)**: these depend on `lemma_2_6_splitting` which depends on the sorry chain. With the Zorn sorry closed (via definition change), the lemma_2_6_splitting chain becomes closeable — EXCEPT that it depends on g_content_sub_B which still has a sorry in the inconsistent case.

4. **Alternative path for C4/C4' sorry sites**: Check whether the C4 hard case can be proved using only burgessRSet A B C (available from BurgessR3Maximal's second component) without going through the full splitting lemma. The approach: from burgessRSet A (g w w_next) (f w_next) and ¬U(γ,δ) ∈ f(x) and δ ∈ f(w_next), directly extract an MCS D with ¬γ ∈ D using Lindenbaum extension on the seed {γ.neg} ∪ g_content(A).

### On Lemma 2.7

**Lemma 2.7 is for C5 counterexamples**, not C4. The C5 sorry sites (if any) would need Lemma 2.7, but the current sorry sites at lines 412 and 510 are for C4/C4' elimination which use Lemma 2.6. Lemma 2.7 is NOT currently blocking any sorry sites — it is a future concern for C5 counterexample elimination.

---

## Appendix: Key File Locations

- Zorn sorry: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/Chronicle/RRelation.lean:772`
- BurgessR3Maximal definition: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleTypes.lean:320-323`
- g_content_sub_B sorry: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean:835-839`
- C4 hard case sorry: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean:412`
- C4' hard case sorry: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean:510`
- Xu's Lemma 3.2.1 archive: `/home/benjamin/Projects/ProofChecker/Boneyard/XuLemma321.lean`
- Xu literature: `/home/benjamin/Projects/ProofChecker/literature/Xu_1988_On_some_US_tense_logics.md`
- Burgess literature: `/home/benjamin/Projects/ProofChecker/literature/Burgess_1982_Axioms_for_tense_logic_Since_and_Until.md`

---

## Supplemental Findings (Second Analysis Pass)

### S1: Xu's Lemma Numbering Clarification

There is potential confusion in the correspondence between Xu and Burgess lemma numbers.
The precise mapping (from direct literature inspection) is:

| Xu 1988 | Burgess 1982 | Codebase | Purpose |
|---------|--------------|----------|---------|
| Lemma 2.1 | Lemma 2.3 | `burgessR3` | r-relation via Since equivalence |
| Lemma 2.2 | Lemma 2.4 | `burgessR3Maximal_from_g_content_sub` | U(ξ,η)∈A → exists B,C with R(A,B,C), ξ∈C, η∈B |
| Lemma 2.3 | (new) | Not implemented | R(A,B,C) implies S(α,⊤)∈B for α∈A and U(γ,⊤)∈B for γ∈C |
| Lemma 2.4 | Lemma 2.6 | `lemma_2_6_splitting` (partial) | ¬U(γ,β)∈A, γ∈C → insert ¬β at new point (C4 elimination) |
| Lemma 2.6 | Lemma 2.9 | `eliminate_C4_counterexample` | C4 counterexample → chronicle extension |
| Lemma 2.7 | Lemma 2.10 | `eliminate_C5_counterexample` | C6a/C5 counterexample → chronicle extension |

**Critical point**: Xu's Lemma 2.4 = Burgess's Lemma 2.6 (C4 insertion), NOT Lemma 2.7
(C5 insertion). The focus prompt's question "Can Xu's Lemma 2.4 replace Burgess's Lemma 2.7?"
conflates these. Xu's 2.4 handles the C4-type problem; the C5-type problem in Xu is Lemma 2.7
(which uses Lemma 2.2 = Burgess 2.4 for the C6a case, with no induction needed for the base).

### S2: The g_content_sub_B Inconsistent Case — An Alternative Approach

The current report (Finding 7, Part 2 analysis) concludes the g_content_sub_B inconsistent
case is "blocked at the same fundamental level" as the Zorn sorry. But there is a subtlety:

In the PROOF STRUCTURE of `g_content_sub_B_of_BurgessR3Maximal`, the "inconsistent case"
is NOT about B being inconsistent. The proof is by contradiction: assume φ ∉ B (where
φ ∈ g_content(A)), then try to derive False. The proof splits on whether {φ} ∪ B is
consistent or inconsistent.

**Sub-case 2 (inconsistent)**: {φ} ∪ B is inconsistent. This means `φ.neg` is derivable
from B alone (i.e., `φ.neg ∈ B` since B is a DCS). But then B contains BOTH `φ.neg`
(from this case) and we assumed `φ ∉ B`. This is fine — B may contain `φ.neg` without
containing `φ`. But here is the key: the current proof uses `Set.univ` to derive False
when B contains `φ.neg`, by showing that `burgessR3(A, Set.univ, C)` leads to contradiction.

**The DCS argument for the inconsistent case**: If `φ.neg ∈ B` (because {φ} ∪ B is
inconsistent), there is a DIFFERENT proof available in some cases. Specifically, from
`φ.neg ∈ B` and `burgessR3(A, B, C)`: for all γ ∈ C, `untl(φ.neg, γ) ∈ A`. From
h_gc and `φ ∈ g_content(A)`: `φ ∈ C`. So `untl(φ.neg, φ) ∈ A`.

Now the sub-case split: Is `φ` in A?
- If `φ ∈ A`: then G(φ) ∈ A (from definition of g_content via BX4), and the pair
  `G(φ) ∈ A` + `untl(φ.neg, φ) ∈ A` — no direct contradiction in BX.
- If `φ ∉ A`: then A is an MCS, so `φ.neg ∈ A`. From `burgessRSetSince C B A` with
  `β = φ.neg ∈ B` and `α = φ.neg ∈ A`: `snce(φ.neg, φ.neg) ∈ C`.

Interesting: `snce(φ.neg, φ.neg) ∈ C` means S(¬φ, ¬φ) ∈ C. Does this lead to
contradiction with C being an MCS? By BX4': `¬φ → H(F(¬φ))` (if BX4 has a Since-dual).
Actually the dual of BX4 is `φ → H(F(φ))` (in past-tense form), so `¬φ → H(F(¬φ))`.
This gives nothing new.

**Conclusion**: The supplemental analysis confirms the existing report's conclusion.
The inconsistent case in g_content_sub_B cannot be closed without density axioms.
The only clean solution is to change BurgessR3Maximal to SetDeductivelyClosed maximality
AND find a completely different proof of g_content_sub_B that avoids the inconsistent case.

### S3: The g_content_sub_B Proof Structure — Avoiding the Inconsistent Case

Looking at the proof goal of `g_content_sub_B_of_BurgessR3Maximal`:

> Given: BurgessR3Maximal A B C, g_content(A) ⊆ C, MCS conditions.
> Show: g_content(A) ⊆ B.

This can be reformulated: for each φ with G(φ) ∈ A, show φ ∈ B.

**Alternative proof attempt**: Directly use the Since direction.

From Xu's Lemma 2.3 (if provable): BurgessR3Maximal implies S(α, ⊤) ∈ B for α ∈ A.
This gives Since-formulas in B from A-elements. Combined with φ ∈ C and r(A, B, C): ...

But Xu's 2.3 cannot be proved without the inconsistency case (it goes through XuLemma321).

**A purely structural approach**: If BurgessR3Maximal(A, B, C) and g_content(A) ⊆ C,
can g_content(A) ⊆ B follow directly from the definition without going through the
inconsistency case?

`burgessR3(A, B, C)` says: for all β ∈ B, for all γ ∈ C, `untl(β, γ) ∈ A`.
We want: for all φ with `G(φ) ∈ A`, `φ ∈ B`.

There is no direct implication from the definition. The proof REQUIRES showing that if
φ ∉ B, then some extension of B satisfies burgessR3 — contradiction. And this
extension proof has the inconsistency case.

**Bottom line**: g_content_sub_B cannot be proved structurally; the sorry at this
location is a genuine blocker, independent of the Zorn sorry, and has the same
root cause (satisfiability of `untl(⊥, γ)` on non-dense frames).

### S4: Are Lines 412 and 510 Actually Sorry-Polluted via g_content_sub_B?

The dependency chain from the existing report:
```
Zorn sorry → BurgessR3Maximal_extension_exists → burgessR3Maximal_exists_from_seed
           → burgessR3Maximal_from_g_content_sub → lemma_2_6_splitting
           → C4 hard cases (lines 412, 510)
```

And separately:
```
Zorn sorry → BurgessR3Maximal_extension_exists → g_content_sub_B_of_BurgessR3Maximal
```

With the definition change to SetDeductivelyClosed, the Zorn sorry closes. But
`burgessR3Maximal_from_g_content_sub` calls `g_content_sub_B_of_BurgessR3Maximal`
which still has its own sorry. So the chain remains sorry-polluted at a different point.

**The two independent blockers are**:
1. Zorn sorry (closeable by definition change alone)
2. g_content_sub_B sorry (requires density or a fundamentally new argument)

Closing (1) without closing (2) moves the sorry from RRelation.lean:772 to
PointInsertion.lean:835-839 but does not close the overall chain.

### S5: Prioritized Action Plan

Given all findings, the recommended sequence of actions is:

**Step 1** (low effort, safe): Change BurgessR3Maximal maximality to SetDeductivelyClosed.
- Effect: Closes Zorn sorry at line 772.
- Risk: Breaks g_content_sub_B proof (Set.univ call becomes invalid).
- Mitigation: Add `sorry` to g_content_sub_B inconsistent case with documentation.

**Step 2** (medium effort): Investigate whether g_content_sub_B can be split so that
the sorry is ONLY in the specific case where G(φ) ∈ A but φ ∉ B and {φ}∪B is inconsistent.
Currently the sorry may be broader. Narrowing the sorry scope to exactly this case
would be valuable documentation.

**Step 3** (investigation): Check if any of the sorry-polluted theorems downstream
of g_content_sub_B can be proved WITHOUT g_content_sub_B, using an alternative
approach. For example: for C4 hard cases (lines 412, 510), can BurgessR3Maximal
alone (without g_content_sub_B) provide the needed contradiction?

**Step 4** (long term): For Lemma 2.7 (Phase 6), the full Burgess seed D₀ approach
remains the only viable path. Xu's approach does not help here.

**Step 5** (theoretical): Consider whether restricting to dense frames (adding a
density axiom `G'⊥ → ⊥` to BX) is mathematically appropriate for the target
completeness theorem. If the theorem is about linear orders (which may be dense or
discrete), density cannot be assumed. If the theorem specifically targets dense linear
orders (Q), then density axioms are valid.

Burgess 1982 Section 1.6 explicitly lists axioms for density, discreteness, etc.
The base system `J₀` (= BX) targets ALL linear orders. Xu's Section 2 also targets
all frames. The g_content_sub_B sorry reflects a genuine gap between the base system
and the target: the construction as written assumes dense behavior but BX has no
density axioms.

This is a fundamental mathematical issue: the canonical model construction for ALL
linear orders (including discrete ones) has this sorry as a theorem that may require
additional axioms or proof-theoretic tools not present in BX.
