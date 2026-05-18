# Teammate B Findings: GHR94 Literature Analysis for Task 157

**Date**: 2026-05-18
**Focus**: Precise GHR94 structure for Case 7, hierarchy Lemmas 10.2.4-10.2.8, constituent substitution, and circularity avoidance

## Key Findings

### A. Case 7 in GHR94 — The Correct Decomposition

**Source**: GHR94 Ch. 10, Lemma 10.2.3, item 7 (lines 95-101 of ch10.md)

GHR94 gives an EXPLICIT equivalent for Case 7 that does NOT use neg_until_equiv:

```
S(a ∧ U(A,B), q ∨ ¬U(A,B))
↔ [S(A ∧ (q ∨ ¬U(A,B)) ∧ S(a, B∧q), q ∨ ¬U(A,B))]    -- D1
  ∨ [S(a, B∧q) ∧ A]                                       -- D2
  ∨ [S(a, B∧q) ∧ B ∧ U(A,B)]                              -- D3
```

**Semantic argument** (lines 95-96): "By considering when A is true" — the three disjuncts correspond to:
- D1: A is true in the past (between the event witness s and now)
- D2: A is true now (at time t)
- D3: A is true in the future (via U(A,B) extending past t)

**Key analysis of each disjunct**:

- **D2** = `S(a, B∧q) ∧ A`: Already separated. S(a, B∧q) has no U (a, B, q are atoms/S-free/U-free). A is an atom. Product of pure-past and pure-present.

- **D3** = `S(a, B∧q) ∧ B ∧ U(A,B)`: Already separated in the `no_S_nested_in_U` sense. S(a,B∧q) is U-free (pure past). B is an atom. U(A,B) is S-free (pure future). Boolean combination of past/future/present.

- **D1** = `S(A ∧ (q ∨ ¬U) ∧ S(a,B∧q), q ∨ ¬U)`: This is **Case 8 form**. The event's U-content is `¬U(A,B)` only (A is U-free, q∨¬U has ¬U, S(a,B∧q) is U-free). The guard is `q∨¬U`. So D1 = S(event'∧¬U, q∨¬U) = Case 8, where event' = A∧(q∨True part extracted)∧S(a,B∧q).

  Then GHR94 says (line 101): "The first disjunct can be further eliminated by eliminations (8) and (4)."
  
  **Elimination (8)** handles S(stuff∧¬U, q∨¬U). After Case 8, the RHS contains S-terms with guard ¬U or q∨U types that fall under Case 4 or Case 5.
  
  **Elimination (4)** handles S(a, q∨¬U).

**CRITICAL INSIGHT**: GHR94's Case 7 decomposition is a DIRECT semantic equivalence. It does NOT use neg_until_equiv (Lemma 10.2.2). It does NOT introduce a second U-type U(¬A∧¬B, ¬A). The decomposition keeps only the ORIGINAL U(A,B) throughout.

**Why the current implementation is blocked**: The current DedekindZ.lean (line 1659) uses `all_separable _` for Case 7 and the handoff notes say it tried neg_until_equiv, which introduces U' = U(¬A∧¬B, ¬A). This is the WRONG approach. GHR94 never does this for Case 7.

### B. The Hierarchy Structure (Lemmas 10.2.4-10.2.8)

**Lemma 10.2.4** (lines 124-139): Given S(C, F) where C and F contain only U(A,B) (one specific U-type) not nested under S, prove it equivalent to a syntactically separated wff with U only as U(A,B).

- *Method*: Boolean rearrangement + Lemma 10.2.1 distributes S(C,F) into boolean combination of S(C₁,C₂) (U-free) and S(C₁∧±U, C₂∨±U) forms. Apply Cases 1-8 to each. Result: boolean combination of atoms, U(A,B), and S(X,Y) with X,Y built from atoms + S only (no U). This is syntactically separated.
- *Measure*: None (direct application of eliminations).

**Lemma 10.2.5** (lines 143-155): Given D where only U(A,B) appears and A,B have no S or U, prove D equivalent to separated wff with U only as U(A,B).

- *Measure*: Maximum number k of nested S's above any U(A,B).
- *k=0*: Already separated (U(A,B) is at top level under booleans only).
- *k>0*: Apply 10.2.4 to each most-deeply-nested S(C,F) containing U(A,B). This removes U(A,B) from under that S. The maximum S-nesting above U(A,B) decreases. Apply IH.
- *Key point*: After 10.2.4, U still only appears as U(A,B) (the eliminations preserve this).

**Lemma 10.2.6** (lines 157-171): Given D where U appears only as U(A₁,B₁),...,U(Aₙ,Bₙ) with each Aᵢ,Bᵢ built without S or U.

- *Measure*: Number n of distinct U-types.
- *n=1*: Apply 10.2.5.
- *n>1*: Replace U(Aᵢ,Bᵢ) for i=1..n-1 with fresh atoms qᵢ → get D'. Apply 10.2.5 to D' (only U(Aₙ,Bₙ) remains) → get separated E'. E' is bool(atoms∪{qᵢ}, U(Aₙ,Bₙ), past-formulas-Dⱼ-with-qᵢ). **Substitute U(Aᵢ,Bᵢ) back for qᵢ IN EACH Dⱼ**. Apply IH (n-1 U-types) to each Dⱼ.
- **"Constituents"**: The Dⱼ are the **pure past subformulas** of the separated E'. These are the S-based boolean constituents.

**Lemma 10.2.7** (lines 173-187): Given D with no S nested within any U.

- *Measure*: Maximum depth n of nesting of U's beneath an S.
- *n=1*: U-args are atom-only → 10.2.6 applies.
- *n>1*: Find outermost U(Aᵢ,Bᵢ) covering all U-appearances. Each Aᵢ,Bᵢ contains sub-U's U(Xᵢⱼ,Yᵢⱼ). Replace each U(Xᵢⱼ,Yᵢⱼ) with fresh atom zᵢⱼ → get U(A'ᵢ,B'ᵢ) with A'ᵢ,B'ᵢ atom-only. Replace in D to get D'. Apply 10.2.6 → separated E'. **Substitute U(Xᵢⱼ,Yᵢⱼ) back for zᵢⱼ** in each pure past subformula of E'. Apply IH (nesting depth decreased).

**Lemma 10.2.8** (lines 189-220): Any wff D.

- *Measure*: Junction depth of D.
- *jd ≤ 1*: Already separated.
- *jd ≥ 2*: D is bool(atoms, S(D₁,D₂), U(D₁,D₂)). For each S(D₁,D₂):
  1. Find maximal U(Aᵢ,Bᵢ) covering all U-appearances.
  2. Some U(Aᵢ,Bᵢ) have S-subformulas S(Eᵢⱼ,Fᵢⱼ). Replace each maximal such S-subformula with fresh atom zᵢⱼ → get U(A'ᵢ,B'ᵢ).
  3. Replace in S(D₁,D₂) to get E'. Apply 10.2.7 → separated E'.
  4. **Substitute S(Eᵢⱼ,Fᵢⱼ) back for zᵢⱼ**. Apply IH (junction depth decreased by at least 2 for the S-subformulas, at most d-1 for U-subformulas).

### C. Constituent Substitution — The Core Technique

**What "substitute back into constituents" means** (GHR94 lines 169, 185, 218):

After abstracting (replacing temporal subformulas with atoms) and separating, you get E' = bool(atoms, pure-future, pure-past). The **constituents** are:

1. **Atoms** (including fresh atoms zᵢⱼ): When you substitute back, an atom zᵢⱼ becomes a temporal formula (e.g., U(Xᵢⱼ,Yᵢⱼ) or S(Eᵢⱼ,Fᵢⱼ)). If it was at an atom position, it's now at that same position.

2. **Pure future subformulas** (U-based): These don't contain the fresh atoms from S-abstraction (because the abstraction only replaced S-inside-U, not U-inside-S). So they remain pure future.

3. **Pure past subformulas** (S-based): These MAY contain fresh atoms zᵢⱼ. After substitution, they become impure. These are the ones that need the IH.

**The key structural insight**: Substitution back creates impure formulas ONLY in the pure-past constituents of E'. You apply the IH to each such constituent INDEPENDENTLY. The boolean structure of E' is preserved — you're just replacing each past-constituent with its own separated equivalent.

**Why this works**: The separated formula is `bool(atoms, future-terms, past-terms)`. Replacing each past-term with `bool(atoms', future', past')` gives `bool(atoms∪atoms', future∪future', past∪past')` which is still separated.

### D. Why Circularity Doesn't Arise in GHR94

The GHR94 proof structure is STRICTLY layered:

1. **Cases 1-8 (10.2.3)**: Direct semantic equivalences. No induction needed. No axiom dependency. Each case produces a boolean combination of: atoms, U(A,B), and S(X,Y) where X,Y don't contain U.

2. **10.2.4**: Uses only Cases 1-8 + boolean rearrangement.

3. **10.2.5**: Uses only 10.2.4. Induction on S-nesting depth k. No circularity because k strictly decreases.

4. **10.2.6**: Uses only 10.2.5. Induction on number n of U-types. After abstracting n-1 U-types and separating via 10.2.5, you substitute back into **past constituents** of the separated form. These past constituents have n-1 U-types. The IH applies directly.

5. **10.2.7**: Uses only 10.2.6. Induction on U-nesting depth. Same substitute-into-constituents pattern.

6. **10.2.8**: Uses only 10.2.7. Induction on junction depth. Same pattern.

**Where `snce_separable` fits**: It's NOT a prerequisite. It's a CONSEQUENCE. After proving 10.2.8 (all formulas separable), you get `snce_separable` for free: S(φ,ψ) is separable because it's a formula, and all formulas are separable.

**The circularity in the current Lean code**: The code tries to prove `multi_U_formula_separable` using `all_separable` (which is an axiom that requires `snce_separable`). GHR94 proves 10.2.6 (multi-U) by abstracting and substituting into constituents of the ALREADY-SEPARATED form, not by composing temporal closure operations.

**The key conceptual error**: The current approach tries to substitute a temporal formula back into the WHOLE separated formula and then show the result is still separable. This requires `snce_separable`. GHR94's approach substitutes into each CONSTITUENT independently, which only requires the IH (with a lower complexity measure).

### E. Alternative Literature

**Burgess 1982/1984**: These papers concern axiomatization and basic tense logic, not separation/expressive completeness directly. Burgess 1982 provides axioms for S and U but not the separation procedure. Not useful for the current problem.

**Caleiro/Viganò/Volpe 2013 (Mosaic Method)**: This paper uses a fundamentally different technique (mosaics) for temporal logic completeness. While potentially applicable, it would require a completely different formalization approach. Not recommended for the current task.

**GHR93 (Temporal Expressive Completeness in the Presence of Gaps)**: This paper extends the separation theorem to general linear time with gaps, using Stavi connectives. The integer-time case is subsumed by GHR94 Ch. 10.2 which is simpler. Not directly useful.

**Conclusion**: GHR94 Ch. 10.2 is the definitive and simplest source for integer-time separation. No alternative literature provides a meaningfully simpler approach.

## Recommended Approach

### For Case 7

**Implement GHR94 Lemma 10.2.3 item 7 DIRECTLY**:

```
S(a∧U, q∨¬U) ↔ S(A∧(q∨¬U)∧S(a,B∧q), q∨¬U) ∨ S(a,B∧q)∧A ∨ S(a,B∧q)∧B∧U
```

Semantic proof outline:
1. **(⇒)** Given S(a∧U(A,B), q∨¬U)(t): There exists s < t with a(s)∧U(A,B)(s) and (q∨¬U) on (s,t). From U(A,B)(s): ∃w>s with A(w)∧B on (s,w). Three sub-cases:
   - w > t: B holds on (s,t), and U(A,B) holds at t. Also q∨¬U on (s,t) and ¬U fails at s. So q must hold on (s+1,t) since each point in (s,t) has q∨¬U and for the points near s where ¬U may fail we need q. Wait — actually (q∨¬U) throughout (s,t). If a point r in (s,t) has ¬U(r) that's fine. So B∧q on (s,t)? No, only q∨¬U. But B on (s,w) with w>t means B on (s,t). So B∧(q∨¬U) on (s,t). For B∧q: we need q throughout too. This doesn't follow directly. Let me re-examine.
   
   Actually the GHR94 decomposition is about "when A is true" relative to the current time t:
   - A true at t: D2 (S(a,B∧q)∧A). Need to show S(a,B∧q) from U(A,B)(s) with w=t: B on (s,t), and need q on (s,t). From q∨¬U on (s,t): at each r∈(s,t), q(r)∨¬U(r). But U(A,B) has A at t... Hmm, this needs careful integer analysis.
   - A true in future (w>t): D3 (S(a,B∧q)∧B∧U(A,B)). B on (s,t+), U(A,B) at t.
   - A true in past (s<w<t): D1.

2. **(⇐)** Each disjunct implies S(a∧U, q∨¬U).

After proving this equivalence:
- D2 and D3 are directly separable (no nested U under S)
- D1 = S(event'∧¬U, q∨¬U) is Case 8. Apply case8_separable_Z. The result may contain Case 4 or Case 5 sub-problems, but these are already proved.

**This completely avoids the multi-U-type problem.**

### For the Hierarchy

Implement the constituent-substitution pattern from GHR94:

1. For 10.2.6 (multi_U_formula_separable): Abstract n-1 U-types → separate via 10.2.5 → get bool(atoms, U(Aₙ,Bₙ), past-constituents-Dⱼ). Substitute back into each Dⱼ. Apply IH to each Dⱼ. The boolean structure stays separated.

2. For 10.2.7 (no_S_nested_in_U_separable): Same pattern with U-nesting depth.

3. For 10.2.8 (all formulas): Same pattern with junction depth.

**The key Lean infrastructure needed**: A function that takes a syntactically separated formula and extracts its "past constituents" — the S-based boolean sub-parts. Then after substitution into each, reassemble.

### For Case 6 (2 remaining sorries)

The Case 6 approach in the code (neg_until_equiv + Branch A/B decomposition) appears mostly correct but has 2 sorries in the D3 branches. These may be avoidable by using GHR94's original Case 6 approach directly:

GHR94 10.2.3 item 6 (lines 88-93):
```
S(a∧¬U, q∨U) ↔ [S(a, q∧¬A)∧¬A∧¬(B∧U(A,B))]
               ∨ S(¬B∧¬A∧(q∨U)∧S(a,q∧¬A), q∨U)
```
Then use eliminations (3) and (5) to finish.

This is a cleaner decomposition than the neg_until_equiv approach.

## Evidence/Examples

### Case 7 formula (GHR94 10.2.3.7, lines 95-101)
```
S(a ∧ U(A, B), q ∨ ¬U(A, B))
↔ [S(A ∧ (q ∨ ¬U(A, B)) ∧ S(a, B ∧ q), q ∨ ¬U(A, B))]
  ∨ [S(a, B ∧ q) ∧ A]
  ∨ [S(a, B ∧ q) ∧ B ∧ U(A, B)].

The first disjunct can be further eliminated by eliminations (8) and (4).
```

### Case 6 formula (GHR94 10.2.3.6, lines 88-93)
```
S(a ∧ ¬U(A, B), q ∨ U(A, B))
↔ [S(a, q ∧ ¬A) ∧ ¬A ∧ ¬(B ∧ U(A, B))]
  ∨ S(¬B ∧ ¬A ∧ (q ∨ U(A, B)) ∧ S(a, q ∧ ¬A), q ∨ U(A, B)).
Eliminations (3) and (5) can be used to finish the separating.
```

### Constituent substitution (GHR94 10.2.6, lines 167-170)
```
E' is separated and so is a boolean combination of atoms, of pure future wffs
(i.e. U(Aₙ, Bₙ)) and pure past wffs Dⱼ which are built from atoms including
q₁, ..., qₙ₋₁, those in Aₙ, and Bₙ, and others of D. Note that U(Aₙ, Bₙ)
does not appear in any Dⱼ. Now substitute U(Aᵢ, Bᵢ) for each qᵢ
(i = 1, ..., n − 1) in each Dⱼ and, using the induction hypothesis, separate them.
```

### Junction depth substitution (GHR94 10.2.8, lines 216-220)
```
If we resubstitute the original wffs for each zᵢⱼ then we will have a formula
equivalent to S(D₁, D₂) but of one less junction depth and we may use the
induction hypothesis.
```

## Confidence Level

**High confidence** on the Case 7 decomposition — GHR94 gives the explicit formula and it avoids the multi-U-type problem entirely. The current implementation's approach (neg_until_equiv) is demonstrably wrong for Case 7.

**High confidence** on the hierarchy structure — the constituent-substitution pattern is clearly described in 10.2.6, 10.2.7, 10.2.8.

**Medium confidence** on the Lean implementation feasibility — the constituent-extraction from a separated formula requires non-trivial Lean infrastructure (identifying the "past subformulas" of a boolean combination). The abstract/substitute approach in Hierarchy.lean already has most of this infrastructure.

## Summary of Blockers and Solutions

| Problem | Root Cause | GHR94 Solution |
|---------|-----------|----------------|
| Case 7 blocked by multi-U-type | neg_until_equiv introduces U' | Use GHR94 10.2.3.7 direct decomposition (no neg_until_equiv) |
| Case 6 has 2 sorries | Complex D3 branch in Branch B | Consider GHR94 10.2.3.6 direct decomposition instead |
| Hierarchy circular | multi_U_formula_separable uses all_separable axiom | Implement constituent-substitution pattern from 10.2.6 |
| snce_separable axiom needed | Hierarchy assumed it as prerequisite | It's a CONSEQUENCE of 10.2.8, not a prerequisite |
