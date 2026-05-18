# Teammate A Findings: GHR94 Cases 5-8 Correct Approach for Integer Time

**Task**: 157 - Formalize expressive completeness of {S,U} over integer time
**Focus**: Find the mathematically correct approach for Cases 5-8 of Lemma 10.2.3 over Z
**Date**: 2026-05-17
**Confidence**: HIGH

## Key Findings

### 1. The GHR94 Integer Formulas Are Genuinely Wrong

The GHR94 formulas for Cases 5-8 (Lemma 10.2.3 in Section 10.2) contain two independent errors for integer time:

**Error 1** (already documented): The factor `[A ∨ (B ∧ U(A,B))]` at evaluation point t assumes the U-chain propagates B-coverage from the S-witness to t. On integers, U(A,B)(s) can hold with vacuous B-guard when A(s+1) is true (since (s,s+1)_Z = ∅). The U-chain terminates without providing B-coverage to t.

**Error 2** (discovered in report 02): The formula `¬S(¬q, ¬A)` used in GHR94's guard fails on integers because `S(¬q, ¬A)(t)` is trivially true whenever `¬q(t-1)` holds, since the open interval (t-1, t)_Z is empty, making the guard ¬A vacuously satisfied. This makes `¬S(¬q, ¬A)` much stronger on integers than GHR94 intends.

Both errors stem from the same root cause: GHR94's formulas rely on **dense-time reasoning** about open intervals being non-empty, which fails on integers.

### 2. No Correct Explicit Formula Exists in Simple Form

The prior research (report 02) exhaustively explored corrected explicit formulas for Case 5 and found that **every attempt fails in the backward direction**. The fundamental issue: any separated equivalent of `S(a ∧ U(A,B), q ∨ U(A,B))` must reconstruct `U(A,B)(u)` at guard points purely from past/present information, but `U(A,B)(u)` is inherently future-looking (requires B-coverage up to a future A-point). On dense time, the U-chain propagation bridges this; on integers, it cannot.

This does NOT mean explicit formulas don't exist (the separation theorem guarantees they do), but they are likely much more complex than GHR94's 2-3 disjunct structure.

### 3. The Dedekind-Complete Approach (Section 10.3) Provides the Key Strategy

**Critical discovery**: GHR94 Section 10.3 (Lemma 10.3.11) handles Cases 5-8 for **Dedekind-complete time** using a **completely different strategy** that does NOT give direct explicit formulas. Instead:

- **Case 5**: Reduced to Cases 1 and 3 via "elimination (3)" — rewrites `S(a ∧ U(A,B), q ∨ U(A,B))` as a disjunction involving `S(a ∧ U(A,B), q)` (Case 1!) plus terms using Q(A,B,p), K⁺, K⁻, Γ±
- **Case 6**: Reduced to Cases 2 and 3 
- **Case 7**: Given an explicit formula then reduced via Cases 4 and 8
- **Case 8**: Reduced to Cases 1, 2, and 5 via negation

The Dedekind approach uses K⁺, K⁻, Γ± connectives, which are trivial on integers (K⁺q = K⁻q = ⊤, Γ±q = ⊥). After substituting these trivializations, the Dedekind formulas **may simplify dramatically for integers**.

### 4. The Junction-Depth Approach Bypasses Cases 5-8 Entirely

Re-reading GHR94's hierarchy (Lemmas 10.2.4-10.2.8) with fresh eyes reveals that **Cases 5-8 are only needed at the base level of Lemma 10.2.4**. The higher lemmas (10.2.5-10.2.8) work by:

1. Abstracting U/S subformulas with fresh atoms
2. Applying the lower lemma
3. Resubstituting and applying the induction hypothesis at lower junction depth

**The junction-depth induction (Lemma 10.2.8) does not require Cases 5-8 directly** — it only requires that `no_S_nested_in_U → separable` (Lemma 10.2.7), which in turn requires Lemma 10.2.6, which requires Lemma 10.2.5, which requires Lemma 10.2.4, which requires Cases 1-8.

However, Lemma 10.2.4 is about S(C, F) where C and F contain a **single U-type** U(A,B) at top level. The normal-form decomposition into Cases 1-8 is one way to prove 10.2.4. But there's another way:

**Alternative**: Prove 10.2.4 by showing that `S(C, F)` itself has lower junction depth after distributing and simplifying, then apply the junction-depth IH directly. This bypasses the need for Cases 5-8.

### 5. Correct Approach: Strengthen the Induction to Carry Separability Through

The correct mathematical approach for integer time is:

**Theorem** (strengthened 10.2.4): If φ is a formula with junction depth ≤ n, then φ is separable.

**Proof by strong induction on n:**
- n = 0: φ is already separated (no U-S alternation)
- n = 1: φ has U and S but not interleaved. Already separated by definition.
- n ≥ 2: φ = bool-combo of atoms, S(D₁, D₂), U(D₁, D₂).
  - For S(D₁, D₂): find maximal U(Aᵢ,Bᵢ) subformulas. Some may have S inside them (contributing to junction depth ≥ 2).
  - Abstract the S-nodes inside U-arguments with fresh atoms zᵢⱼ to get U(A'ᵢ, B'ᵢ) with junction depth reduced.
  - The modified formula S(D'₁, D'₂) has **no S nested in any U** → apply Lemma 10.2.7 to separate it.
  - Resubstitute the original S(Eᵢⱼ, Fᵢⱼ) for each zᵢⱼ. Each substituted S-formula has junction depth ≤ n-2.
  - Apply IH to each resulting impure subformula.

This is **exactly GHR94 Lemma 10.2.8's proof**. The key question is whether Lemma 10.2.7 can be proved without Cases 5-8.

**Lemma 10.2.7** (no S nested in U → separable): Proved by induction on max depth of U-nesting under S.
- Base (depth = 1): This is Lemma 10.2.6 (multiple U-types, all with S-free args)
  - Lemma 10.2.6 uses Lemma 10.2.5 (single U-type)
  - Lemma 10.2.5 uses Lemma 10.2.4 (single U-type at one level of S-nesting)
  - **Lemma 10.2.4 requires Cases 1-8**

So the chain still depends on Cases 5-8. Unless we can prove Lemma 10.2.4 differently.

## Recommended Approach

### Primary: Reduce Cases 5-8 to Cases 1-4 Using Integer-Specialized Decomposition

On integers, the Dedekind-complete reduction strategy (Section 10.3) simplifies dramatically:

Since K⁺q = K⁻q = ⊤ and Γ±q = ⊥ on integers:
- Q(A,B,C) = [C ⇒ ¬K⁺(¬B)] ∧ [(¬B ∨ Γ⁻(B)) ⇒ (S(C,¬A) ⇒ A)]
- Simplifies to: [C ⇒ ⊤] ∧ [¬B ⇒ (S(C,¬A) ⇒ A)] = [¬B ⇒ (S(C,¬A) ⇒ A)]
- i.e., Q(A,B,C) on Z = ¬B → (S(C,¬A) → A) = B ∨ ¬S(C,¬A) ∨ A

**Case 5 on Z (via Dedekind reduction)**:

The Dedekind Case 5 (Lemma 10.3.11.5) says:
```
S(a ∧ U(A,B), q ∨ U(A,B)) ↔
  S(a ∧ U(A,B), q)                           -- already Case 1!
  ∨ [S(α, Q) ∧ β]
  ∨ S(A ∧ (q ∨ U(A,B)) ∧ S(α, Q), q)
  ∨ S(Γ⁺(q) ∧ q ∧ (A ∨ K⁻(A)) ∧ S(α, Q), q)
```

where Q = Q(A,B,¬q), α = (a ∧ U(A,B)) ∨ ((¬q ∨ Γ⁻(q)) ∧ S(a ∧ U(A,B), q) ∧ (q ∨ U(A,B))), β = A ∨ K⁻(A) ∨ [B ∧ U(A,B)]

On integers:
- Γ⁺(q) = ⊥, so the 4th disjunct vanishes
- Γ⁻(q) = ⊥, so α simplifies to: (a ∧ U(A,B)) ∨ (¬q ∧ S(a ∧ U(A,B), q) ∧ (q ∨ U(A,B))) = (a ∧ U(A,B)) ∨ (¬q ∧ S(a ∧ U(A,B), q) ∧ U(A,B))
  Wait: ¬q ∧ (q ∨ U(A,B)) = ¬q ∧ U(A,B). So α = (a ∧ U(A,B)) ∨ (¬q ∧ U(A,B) ∧ S(a ∧ U(A,B), q)) = U(A,B) ∧ (a ∨ (¬q ∧ S(a ∧ U(A,B), q)))
- K⁻(A) = ⊤ on Z, so β = A ∨ ⊤ ∨ ... = ⊤. The 2nd disjunct becomes S(α, Q) which is just S(α, Q).
- Q = Q(A,B,¬q) = B ∨ ¬S(¬q, ¬A) ∨ A = B ∨ A ∨ ¬S(¬q, ¬A)

Hmm, the ¬S(¬q,¬A) issue reappears. But in this context it's inside a guard of a Since formula, not a top-level conjunct.

Actually, wait. The key difference is that in the Dedekind reduction, the formula is built from **compositions of Cases 1-3**, not from a single explicit equivalence. The problematic `¬S(¬q,¬A)` appears inside a **guard** (Q) of a Since formula, where it functions as part of a recursive decomposition. It doesn't need to be true at the evaluation point t — it appears in the guard interval, where it has a different semantic role.

**The Dedekind reduction is essentially a RECURSIVE decomposition: Case 5 → (Case 1) ∨ (composition of Case 1 formulas)**. On integers, the simplifications from K±=⊤ and Γ±=⊥ may eliminate the problematic vacuous-satisfaction issues because:

1. The 4th disjunct (using Γ⁺) vanishes — this was the one requiring "arbitrarily close" reasoning
2. α is simpler — it's just U(A,B) ∧ (a ∨ something)  
3. β = ⊤ (K⁻ = ⊤), which eliminates the top-level conjunct issue
4. The remaining 3 disjuncts are compositions of Case 1 (already proved)

### Concrete Implementation Strategy

**Step 1**: Verify the Dedekind Case 5 reduction with Z specialization:
```
S(a ∧ U(A,B), q ∨ U(A,B)) ↔ₖ
  S(a ∧ U(A,B), q)                                    -- Case 1 (proved)
  ∨ S(α, A ∨ B ∨ ¬S(¬q, ¬A))                         -- S(... , Q) with β=⊤
  ∨ S(A ∧ (q ∨ U(A,B)) ∧ S(α, A ∨ B ∨ ¬S(¬q, ¬A)), q)  -- nested Case 1
```
where α = U(A,B) ∧ (a ∨ (¬q ∧ S(a ∧ U(A,B), q)))

Each disjunct has U(A,B) in the **event only** (not the guard) of the outermost S — making it amenable to Case 1 elimination.

**Step 2**: Verify Cases 6, 7, 8 similarly reduce to previously-proved cases on Z.

**Step 3**: If the integer-specialized Dedekind reduction works, implement it as `elim_case_5_Z` through `elim_case_8_Z` in Lean.

### Secondary: Direct Junction-Depth Induction (Bypass All Explicit Formulas)

If the Dedekind reduction strategy fails after investigation, the alternative is:

Replace Lemma 10.2.4 with a different proof that avoids the 8-case decomposition entirely, using the **junction-depth induction itself as the workhorse at every level**:

For S(C, F) with U(A,B) at top level only: the formula's junction depth is ≤ 2 (U inside S). After abstracting U(A,B) with a fresh atom z, the result S(C', F') has junction depth 0 and is trivially separated. Resubstituting U(A,B) for z gives a formula where U(A,B) appears in both pure-past subformulas (of the separated form) and as the original U(A,B). The impure pure-past parts have lower junction depth — apply IH.

Wait — this is exactly what Lemma 10.2.5 does (induction on nesting depth of S above U), not 10.2.4. And 10.2.5 explicitly uses 10.2.4 at the base.

The question is whether we can collapse 10.2.4 and 10.2.5 into a single induction that avoids the 8 cases. This requires more investigation.

### Tertiary: Non-Constructive Semantic Proof

As a last resort, prove Cases 5-8 non-constructively using the fact that every {U,S}-formula over Z has an equivalent separated formula (by Reynolds Theorem 5 / expressive completeness). This is circular with the current proof structure (Cases 5-8 are needed to prove the separation theorem), so it would require an independent proof of expressive completeness that doesn't go through the 8 cases.

Reynolds 1994 proves expressive completeness of {U,S} over Prior structures (which includes Z) via the Stavi connectives U', S': since U'(A,B) ↔ ⊥ in all Prior structures (by the Prior axiom), {U,S} is as expressive as {U,S,U',S'}, and the latter is expressively complete over all linear orders by Theorem 4 (Gabbay-Hodkinson-Reynolds 1993). However, this proof uses **expressive completeness of {U,S,U',S'}** which requires its own separation theorem — creating a different dependency chain.

## Evidence/Examples

### Counterexample to GHR94 Case 5 (Error 1)
- a(0)=T, A(1)=T, B=F everywhere, q(1)=q(2)=T, else F
- LHS S(a∧U(A,B), q∨U(A,B))(3) = TRUE (s=0, U(A,B)(0) via u=1 vacuous B, q covers guard)
- RHS requires A(3)∨(B(3)∧U(A,B)(3)) = FALSE

### Counterexample to GHR94 Case 5 (Error 2) 
- a(0)=T, A(1)=A(5)=T, B(4)=T (else F), q(1)=q(2)=q(3)=T, q(4)=F
- LHS(5) = TRUE (s=0, U(A,B)(0) via u=1 vacuous, guard: q covers {1,2,3}, U(A,B)(4) via u=5 vacuous)
- ¬S(¬q,¬A)(5) = FALSE (w=4: ¬q(4)=T, ¬A on (4,5)={} vacuous)
- Both GHR94 and attempted corrections fail

### Dedekind K±/Γ± Specialization on Z
- K⁺q = ¬U(⊤,¬q) = ¬(∃s>t: ⊤(s)∧∀u(t<u<s→¬q(u))) = not(¬q vacuous on immediate successor) — wait, on Z: U(⊤,¬q)(t) iff ∃s>t: ⊤∧∀u(t<u<s→¬q(u)). Take s=t+1: vacuously true. So U(⊤,¬q) = ⊤ on Z. Hence K⁺q = ¬⊤ = ⊥... 

No wait, that's wrong. K⁺q = ¬U(⊤,¬q). U(⊤,¬q)(t) = ∃s>t: ⊤(s) ∧ ∀u(t<u<s → ¬q(u)). Take s=t+1: ⊤ ∧ ∀u(t<u<t+1 → ¬q(u)), and (t,t+1)_Z = {}, so vacuously true. So U(⊤,¬q) ≡ ⊤ on Z. Hence K⁺q = ¬⊤ = ⊥ on Z.

Wait, that means K⁺q = ⊥ for ALL q on Z? That can't be right. Let me re-read:

K⁺q = ¬U(⊤, ¬q). "q is true arbitrarily close from the future." On integers, the closest future point is t+1, so K⁺q(t) = q(t+1). 

Hmm no. ¬U(⊤,¬q)(t) = ¬(∃s>t: ∀u(t<u<s → ¬q(u))). Since s=t+1 always gives a vacuous true, U(⊤,¬q) = ⊤. So K⁺q = ⊥ for all q on Z.

This means on Z: K⁺ = ⊥, K⁻ = ⊥ (by symmetry). But GHR94 says "K⁺q = K⁻q = ⊤" (line 249 of the ch10 markdown). Let me re-read...

GHR94 line 249: "In integer time, these connectives are not very interesting for K⁺q = K⁻q = ⊤."

That says K⁺q = K⁻q = ⊤. But my calculation gives K⁺q = ⊥. Let me recheck.

K⁺q means "q is true arbitrarily close from the future": ∀z>t, ∃y(t<y<z ∧ q(y)). On integers, take z=t+1: need ∃y(t<y<t+1 ∧ q(y)). But (t,t+1)_Z = {}. No such y exists. So K⁺q(t) = FALSE for all q.

So K⁺q = ⊥ on Z, not ⊤. GHR94 appears to have this backwards! Unless they mean something different.

Actually wait, re-reading: "K⁺q = K⁻q = ⊤" — maybe they mean that K⁺(⊤) = K⁻(⊤) = ⊤? That would make sense. Or perhaps they use strict vs non-strict in the definition.

Re-reading the definition carefully: K⁺q = ¬U(⊤, ¬q). With strict U: U(A,B)(t) = ∃s>t: A(s)∧∀u(t<u<s→B(u)). U(⊤,¬q)(t) = ∃s>t: ⊤∧∀u(t<u<s→¬q(u)). Take s=t+1: vacuous guard. So U(⊤,¬q)(t)=⊤. K⁺q = ¬⊤ = ⊥.

OK so K⁺q = ⊥ on Z. GHR94's statement "K⁺q = K⁻q = ⊤" must be an error or use a non-strict definition. This doesn't affect our formalization since we work with the formal semantics.

**Correction to my analysis above**: With K⁺ = K⁻ = ⊥ (not ⊤):
- Γ⁺(B) = ¬K⁺(¬B) ∧ K⁻(¬B) = ¬⊥ ∧ ⊥ = ⊤ ∧ ⊥ = ⊥
- Γ⁻(B) = ¬K⁻(¬B) ∧ K⁺(¬B) = ⊤ ∧ ⊥ = ⊥
- Q(A,B,C) = [C ⇒ ¬K⁺(¬B)] ∧ [(¬B ∨ Γ⁻(B)) ⇒ (S(C,¬A) ⇒ A)] = [C ⇒ ⊤] ∧ [¬B ⇒ (S(C,¬A) ⇒ A)] = ¬B → (S(C,¬A) → A)
  = B ∨ A ∨ ¬S(C, ¬A)

This is the same Q as before. And β = A ∨ K⁻(A) ∨ (B ∧ U(A,B)) = A ∨ ⊥ ∨ (B ∧ U(A,B)) = A ∨ (B ∧ U(A,B)). So β is NOT ⊤. The `[A ∨ (B ∧ U(A,B))]` factor returns!

So the Dedekind simplification for Case 5 on Z gives:
```
S(a ∧ U(A,B), q ∨ U(A,B)) ↔
  S(a ∧ U(A,B), q)                              -- Case 1
  ∨ [S(α, Q) ∧ (A ∨ (B ∧ U(A,B)))]             -- but A∨(B∧U(A,B)) is back!
  ∨ S(A ∧ (q ∨ U(A,B)) ∧ S(α, Q), q)           -- Case 1 reduction
```

The 2nd disjunct still has the problematic `A ∨ (B ∧ U(A,B))` factor. This means the Dedekind reduction **also fails on integers** for the same reason as GHR94's direct formula.

**Revised conclusion**: The Dedekind approach does NOT cleanly bypass the integer-specific issues. The fundamental problem — that U(A,B) can hold vacuously on integers, allowing the LHS to be true without A or B∧U(A,B) at t — persists across both approaches.

## Revised Recommendation

Given that both GHR94's direct formulas AND the Dedekind reduction fail on integers, and given that report 02 exhaustively showed that simple explicit formulas don't work, the correct approach is:

### Approach A: Fuse Lemma 10.2.4 Into the Junction-Depth Induction

Instead of proving 10.2.4 as a standalone lemma (which requires Cases 5-8), fuse its logic directly into the junction-depth induction of Lemma 10.2.8.

The key insight: when Case 5 arises during the proof of 10.2.4 (i.e., S(a ∧ U(A,B), q ∨ U(A,B)) with atoms a, q, A, B), this formula has **junction depth 2**. It can be handled by the junction-depth IH at depth ≤ 1, provided we can decompose it into formulas of lower junction depth.

The decomposition: S(a ∧ U(A,B), q ∨ U(A,B)) is **itself separable** because:
- Expand temporal operators: all_past/all_future → U/S definitions
- The formula has junction depth 2 (S outside, U inside)
- Abstract the U(A,B) with a fresh atom z → S(a ∧ z, q ∨ z) which is junction depth 0
- S(a ∧ z, q ∨ z) is trivially separated (no U or S nesting)  
- Resubstituting U(A,B) for z: the atom z appears in pure-past subformulas of the separated form. After substitution, these become junction depth 1 (U inside S inside the separated structure). Apply IH.

But wait — the resubstitution step puts U(A,B) **back inside S-arguments**, recreating the junction depth 2 problem. The issue is that abstraction + resubstitution in 10.2.8 specifically addresses this by showing junction depth decreases. In 10.2.8's proof, the resubstituted formulas have junction depth ≤ n-2 (not n-1). For Case 5 with junction depth 2, the resubstituted formulas would have junction depth ≤ 0, which IS the base case.

**This means Case 5 IS handled by Lemma 10.2.8's junction-depth induction at depth 2 without needing an explicit formula!** The junction-depth induction abstracts the S-nodes inside U-arguments (or vice versa) to reduce junction depth, and at junction depth ≤ 1, the formula is already separated.

### Approach B: Prove `multi_U_formula_separable` Without Cases 5-8

The current code's `multi_U_formula_separable` (= Lemma 10.2.7) calls `all_separable` which is an axiom. Instead:

1. Prove Lemma 10.2.7 by induction on U-nesting depth, using Lemma 10.2.6
2. Prove Lemma 10.2.6 by induction on number of U-types, using Lemma 10.2.5
3. Prove Lemma 10.2.5 by induction on S-nesting depth above U(A,B), using Lemma 10.2.4
4. **FOR Lemma 10.2.4**: Prove Cases 1-4 (already done) and FOR Cases 5-8:
   - Show that the formula has junction depth 2
   - Apply the MAIN junction-depth theorem (Lemma 10.2.8) which handles it via abstraction + IH

This creates a MUTUAL dependency: 10.2.4 → 10.2.8 → 10.2.7 → 10.2.6 → 10.2.5 → 10.2.4. But this is **well-founded** because the junction-depth induction in 10.2.8 reduces junction depth, and the abstraction in 10.2.7/10.2.8 reduces U-nesting depth. The measures decrease at each step.

In Lean, this can be implemented as a single `Nat.strongRecOn` on `junction_depth` that incorporates all the lemma logic inline.

## Confidence Level

**HIGH** for the analysis of why GHR94 fails and why Dedekind reduction doesn't help.

**MEDIUM** for the fused junction-depth approach (Approach A). The mutual dependency needs careful handling in Lean's termination checker. The key insight — that Cases 5-8 at junction depth 2 can be handled by the junction-depth induction itself, which only needs lower junction depth — is mathematically sound but may be tricky to formalize.

**LOW** for finding correct explicit formulas (the "nuclear option"). The exhaustive analysis in report 02 strongly suggests this is not worth pursuing.
