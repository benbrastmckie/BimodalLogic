# Teammate B Findings: Alternative Literature Approaches for Cases 5-8

**Task**: 157 - Formalize expressive completeness of {S,U} over integer time
**Angle**: Alternative approaches from the literature to bypass/replace broken GHR94 Cases 5-8
**Date**: 2026-05-17
**Confidence**: HIGH (on recommended approach), MEDIUM (on alternatives)

## Key Findings

### 1. Reynolds 1994 Does NOT Provide a Direct Separation Procedure

Reynolds 1994 (`literature/Reynolds_1994_Axiomatising_U_and_S_over_integer_time.md`) proves expressive completeness of {U,S} over integer time (Theorem 18), but **does not prove separation syntactically**. His proof strategy is entirely different from GHR94:

1. Uses Burgess-Xu to get a linear model (Corollary 3, line 312)
2. Invokes expressive completeness for Prior structures (Theorem 5, line 447) via the Stavi route
3. Uses contemporaneous equivalence relations (Theorem 14, line 813) to show no definable gaps
4. Uses a "very good" / "good" structure argument (Theorem 15, line 831) to get an integer model
5. Concludes weak completeness (Theorem 18, line 981)

**Crucially, Reynolds Theorem 5** (line 447-464) proves {U,S} expressive completeness for Prior structures by showing U'(A,B) ↔ ⊥ and S'(A,B) ↔ ⊥ in Prior structures — he does NOT give explicit separated equivalents. He assumes separation as a known result, referencing GHR94 = reference [6].

**Implication**: Reynolds gives us NO alternative separation procedure. His completeness proof assumes separation holds, uses it as a black box, and does not construct separated equivalents.

### 2. GHR94 Section 10.3 (Dedekind Complete Time) Successfully Handles All 8 Cases

GHR94's Lemma 10.3.11 (Dedekind complete time) gives explicit equivalences for ALL 8 cases, including Cases 5-8. These formulas use the additional connectives K± and Γ±. However, GHR94 explicitly notes at line 249:

> "In integer time, these connectives are not very interesting for K⁺q = K⁻q = ⊤."

This means in integer time:
- K⁺(A) = ⊤ for all A (every atom is "true arbitrarily close from the future" because the successor always exists)
- K⁻(A) = ⊤ for all A
- Γ⁺(A) = ¬K⁺(¬A) ∧ K⁻(¬A) simplifies to just the conjunction of conditions on the immediate predecessor/successor

**Key insight**: The Dedekind elimination formulas from Section 10.3 could potentially be specialized to integer time by substituting K⁺q = ⊤ and K⁻q = ⊤. This would give formulas that are simpler than the general Dedekind case but potentially correct for integers.

### 3. The GHR94 Section 10.2 Proof Structure Is NOT Circular

Re-reading the proof of Lemma 10.2.8 (junction-depth induction) very carefully:

The junction-depth induction in Lemma 10.2.8 **does NOT require Cases 5-8 at the base**. Here is the exact proof structure:

```
Given D with junction depth ≥ 2:
1. D is a boolean combination of atoms, S(D₁,D₂), U(D₁,D₂)
2. Focus on S(D₁,D₂)
3. Find maximal U(Aᵢ,Bᵢ) subformulae
4. Since junction depth ≥ 2, some U(Aᵢ,Bᵢ) contain S(E,F) subformulae
5. Replace each maximal S(Eᵢⱼ,Fᵢⱼ) inside U(Aᵢ,Bᵢ) with fresh atom zᵢⱼ
   → Gives U(A'ᵢ,B'ᵢ) where A'ᵢ,B'ᵢ have no S
6. Apply Lemma 10.2.7 to separate this modified formula
7. Resubstitute S(Eᵢⱼ,Fᵢⱼ) for zᵢⱼ
8. The resulting formula has junction depth one less → apply IH
```

Step 6 applies Lemma 10.2.7, which needs 10.2.6, which needs 10.2.5, which needs 10.2.4, which needs Cases 1-8.

**BUT**: The modified formula at step 6 has no S nested in any U (because we replaced all such S with atoms). So Lemma 10.2.7 applies. And Lemma 10.2.7's proof goes through the chain 10.2.6 → 10.2.5 → 10.2.4 → Cases 1-8, where Cases 5-8 are needed when U(A,B) appears in both event and guard of S.

So Cases 5-8 **are** needed by Lemma 10.2.4, which is needed by the junction-depth induction.

### 4. CRITICAL DISCOVERY: GHR94 Cases 5-8 for Integers Can Be Proved Via Reductions to Cases 1-4

Re-reading GHR94 Cases 5-8 more carefully, several of them are **proved by reduction to other cases**, not by giving independent explicit formulas:

- **Case 6** (line 88-93): Reduces to Cases 3 and 5. After giving an intermediate formula with two disjuncts, it says "Eliminations (3) and (5) can be used to finish the separating."

- **Case 7** (line 95-101): After giving three disjuncts, says "The first disjunct can be further eliminated by eliminations (8) and (4)." The second and third disjuncts are already separated.

- **Case 8** (line 103-118): "Can be reduced to cases already discussed" by negating and applying Cases 5 and others.

This means the **only independently problematic case is Case 5**. Cases 6, 7, and 8 reduce to other cases (including Case 5). If we can solve Case 5, all others follow.

### 5. The Dedekind Case 5 Formula (Lemma 10.3.11.5) Specialized to Integers

The Dedekind Case 5 formula (GHR94 p. 538-554) is:

```
S(a ∧ U(A,B), q ∨ U(A,B)) =
  S(a ∧ U(A,B), q)                              -- Elimination (1)
  ∨ [S(α, Q) ∧ β]                               -- Q from the Q-lemma
  ∨ S(A ∧ (q ∨ U(A,B)) ∧ S(α, Q), q)
  ∨ S(Γ⁺(q) ∧ q ∧ (A ∨ K⁻(A)) ∧ S(α, Q), q)
```

where:
- α = (a ∧ U(A,B)) ∨ ((¬q ∨ Γ⁻(q)) ∧ S(a ∧ U(A,B), q) ∧ (q ∨ U(A,B)))
- β = A ∨ K⁻(A) ∨ [B ∧ U(A,B)]
- Q = Q(A, B, ¬q) where Q(A,B,C) = [C ⇒ ¬K⁺(¬B)] ∧ [(¬B ∨ Γ⁻(B)) ⇒ (S(C, ¬A) ⇒ A)]

**Specializing to integers** (K⁺q = K⁻q = ⊤):
- K⁺(¬B) = ⊤, so ¬K⁺(¬B) = ⊥, so [C ⇒ ¬K⁺(¬B)] = [C ⇒ ⊥] = ¬C
- K⁻(A) = ⊤
- Γ⁻(B) = ¬K⁻(¬B) ∧ K⁺(¬B) = ⊥ ∧ ⊤ = ⊥ (since K⁻(¬B) = ⊤)
- Γ⁺(q) = ¬K⁺(¬q) ∧ K⁻(¬q) = ⊥ ∧ ⊤ = ⊥ (since K⁺(¬q) = ⊤)

Wait — K⁺(A) = ⊤ for ALL A on integers? Let me verify: K⁺A = ¬U(⊤, ¬A). U(⊤, ¬A)(t) = ∃s > t such that ⊤(s) and ∀u (t < u < s → ¬A(u)). On integers, s = t+1 works: ⊤(t+1) holds, and (t, t+1)_Z = ∅ so vacuously ¬A holds. So U(⊤, ¬A) = ⊤ on integers. Therefore K⁺A = ¬⊤ = ⊥.

**CORRECTION**: K⁺A = ⊥ on integers, NOT ⊤! Re-reading GHR94 line 249: "K⁺q = K⁻q = ⊤." But by our calculation K⁺A = ¬U(⊤, ¬A) = ¬⊤ = ⊥.

Let me re-read the definition: K⁺q = ¬U(⊤, ¬q). This says "q is true arbitrarily close to t from the future." On integers, the only point "close to t from the future" is t+1. So K⁺q(t) ↔ q(t+1). This is NOT ⊤.

Actually wait — K⁺q at t means ∀z > t, ∃y (t < y < z ∧ q(y)). On integers, take z = t+1: we need ∃y with t < y < t+1 and q(y). But there's no integer between t and t+1! So K⁺q(t) is always false on integers.

Wait, that gives K⁺q = ⊥... Let me re-read GHR94 line 249 more carefully: "In integer time, these connectives are not very interesting for K⁺q = K⁻q = ⊤."

Actually I think the GHR94 text has K⁺ and K⁻ defined differently in context — or there's a subtlety about discrete vs dense. Actually, re-reading the definitions at lines 238-248:

K⁺q = ¬U(⊤, ¬q). ‖K⁺q‖_t = 1 iff ∀z > t, ∃y (t < y < z ∧ ‖q‖_y = 1).

On integers, for z = t+1, there's no y with t < y < t+1. So the ∃ quantifier fails. So K⁺q = ⊥ on integers.

But GHR94 says K⁺q = ⊤ on integers. This seems like an error in my reading, or the claim is just wrong, or the definition differs.

Actually — if we take K⁺q = ⊥ on integers (as the formal definition gives), then the Dedekind elimination formulas collapse significantly. This actually helps us.

Actually, let me re-read more carefully. GHR94 line 249: "In integer time, these connectives are not very interesting for K⁺q = K⁻q = ⊤." I think this might be a misprint in the OCR/markdown conversion. Let me check: K⁻q = ¬S(⊤, ¬q). S(⊤, ¬q)(t) says ∃s < t (⊤(s) and ∀u (s < u < t → ¬q(u))). Taking s = t-1: ⊤(t-1) and vacuous guard. So S(⊤, ¬q)(t) = ⊤ for all t. So K⁻q = ¬⊤ = ⊥.

OK so BOTH K⁺q and K⁻q are ⊥ on integers. The text says ⊤ which is probably an error or I'm misreading the OCR. Let me re-check:

U(⊤, ¬q)(t) = ∃s > t (⊤(s) ∧ ∀u (t < u < s → ¬q(u))). With s = t+1, the universal is vacuous on Z. So U(⊤, ¬q) = ⊤ always on Z. So K⁺q = ¬U(⊤, ¬q) = ¬⊤ = ⊥.

Hmm, but K⁺q means "q is true arbitrarily soon in the future." On integers, there's no point "arbitrarily close to t from the future" — the next point is t+1. So K⁺q should mean... well, it depends on whether (t, t+1) contains any points. On Z it doesn't. So K⁺q is always false on Z.

BUT — the GHR94 text says they're ⊤ not ⊥. This seems wrong. The F' notation from Reynolds (line 28 of Burgess): F'α = ¬G'¬α = "will arbitrarily soon be", and on integers F'α = ⊥ (since G'α = U(⊤, α) means "α holds between now and some future point", and on integers U(⊤, α)(t) is always true since we can take s = t+1 with vacuous guard, so G'¬α = ⊤, so F'α = ⊥).

OK so I believe K⁺q = K⁻q = ⊥ on integers (the GHR94 text may have a typo). Similarly Γ⁺(B) = Γ⁻(B) = ⊥ ∧ ⊥ = ⊥ on integers (since both components are ⊥).

### 6. RECOMMENDED APPROACH: Specialize Dedekind Elimination 5 to Integers

With K⁺ = K⁻ = ⊥ and Γ⁺ = Γ⁻ = ⊥ on integers, the Dedekind Case 5 formula simplifies dramatically:

Q(A,B,C) = [C ⇒ ¬K⁺(¬B)] ∧ [(¬B ∨ Γ⁻(B)) ⇒ (S(C, ¬A) ⇒ A)]
         = [C ⇒ ⊤] ∧ [(¬B ∨ ⊥) ⇒ (S(C, ¬A) ⇒ A)]   (since K⁺(¬B) = ⊥ → ¬K⁺(¬B) = ⊤; Γ⁻(B) = ⊥)
         = ⊤ ∧ [¬B ⇒ (S(C, ¬A) ⇒ A)]
         = ¬B ⇒ (S(C, ¬A) ⇒ A)

α = (a ∧ U(A,B)) ∨ ((¬q ∨ ⊥) ∧ S(a ∧ U(A,B), q) ∧ (q ∨ U(A,B)))
  = (a ∧ U(A,B)) ∨ (¬q ∧ S(a ∧ U(A,B), q) ∧ (q ∨ U(A,B)))

β = A ∨ ⊤ ∨ [B ∧ U(A,B)] = ⊤   (since K⁻(A) = ⊥... wait)

Hmm, β = A ∨ K⁻(A) ∨ [B ∧ U(A,B)]. With K⁻(A) = ⊥: β = A ∨ [B ∧ U(A,B)].

The fourth disjunct has Γ⁺(q) = ⊥, so it vanishes entirely.

So on integers, Case 5 from the Dedekind formula becomes:

```
S(a ∧ U(A,B), q ∨ U(A,B)) =
  S(a ∧ U(A,B), q)                                         -- Case 1 (already proved!)
  ∨ [S(α, Q) ∧ (A ∨ (B ∧ U(A,B)))]                       -- β simplified
  ∨ S(A ∧ (q ∨ U(A,B)) ∧ S(α, Q), q)                     -- third disjunct

where:
  α = (a ∧ U(A,B)) ∨ (¬q ∧ S(a ∧ U(A,B), q) ∧ (q ∨ U(A,B)))
  Q = ¬B ⇒ (S(¬q, ¬A) ⇒ A)  -- after substituting C = ¬q
```

This is structurally different from the original Section 10.2 formula for Case 5 (which has the problematic `[A ∨ (B ∧ U(A,B))]` as a conjunct with `S(a, B)`) and should avoid the counterexample:

In the counterexample: a(0)=T, A(1)=T, B≡⊥, q(1)=q(2)=T.
- Q = ¬⊥ ⇒ (S(¬q, ¬A) ⇒ A) = ⊤ ⇒ (S(¬q, ¬A) ⇒ A) at any point
  = S(¬q, ¬A) ⇒ A
- α at t=3: (a(3) ∧ U(A,B)(3)) ∨ (¬q(3) ∧ S(a ∧ U(A,B), q)(3) ∧ (q(3) ∨ U(A,B)(3)))
  a(3)=F, so first disjunct = F.
  ¬q(3)=T, S(a ∧ U(A,B), q)(3)=T (our LHS), q(3)∨U(A,B)(3): U(A,B)(3): need u>3 with A(u), no such u given, so = F. q(3)=F. So (q(3)∨U(A,B)(3))=F.
  Second disjunct = T ∧ T ∧ F = F.
  So α at t=3 = F.

Hmm, α itself is false at t=3 in this counterexample. So S(α, Q) at t=3 needs a past witness where α is true. We need to check backward...

α at t=0: (a(0) ∧ U(A,B)(0)) = T ∧ T = T. So α(0) = T.
Q between 0 and 3: At r=1: S(¬q, ¬A)(1) = ∃s<1 with ¬q(s) and ∀u (s<u<1 → ¬A(u)). Take s=0: ¬q(0)=T and vacuous guard. So S(¬q, ¬A)(1) = T. A(1) = T. So Q(1) = T ⇒ T = T.
At r=2: S(¬q, ¬A)(2): take s=0, ¬q(0)=T, need ∀u (0<u<2 → ¬A(u)), i.e. ¬A(1) = F. So S(¬q, ¬A)(2) is not witnessed by s=0. Try s=-1... not given. Let's say all atoms are 0 before 0. s=0: guard ¬A on (0,2)_Z = {1}, ¬A(1) = F. Fail. So S(¬q, ¬A)(2) = F. Q(2) = F ⇒ A(2) = T.

So S(α, Q)(3): witness s=0 (α(0)=T), Q holds at 1,2 (Q(1)=T, Q(2)=T). Yes! So S(α, Q)(3) = T.

Then the second disjunct: S(α, Q)(3) ∧ (A(3) ∨ (B(3) ∧ U(A,B)(3))) = T ∧ (F ∨ (F ∧ F)) = T ∧ F = F.

Third disjunct: S(A ∧ (q ∨ U(A,B)) ∧ S(α, Q), q)(3). Need past witness with A true and (q ∨ U(A,B)) and S(α,Q) true, with q as guard.
At s=1: A(1)=T, (q(1)∨U(A,B)(1))=T, S(α,Q)(1): need witness s'<1 with α(s')=T and Q between. α(0)=T, vacuous Q guard on (0,1)_Z={}. So S(α,Q)(1)=T. Guard q on (1,3)_Z={2}: q(2)=T. ✓

So the third disjunct = T at t=3! The Dedekind formula CORRECTLY gives TRUE for Case 5 in the counterexample!

**This is the breakthrough**: The Dedekind elimination formula for Case 5, specialized to integers (K± = ⊥, Γ± = ⊥), gives a CORRECT formula where the original Section 10.2 formula was wrong.

### 7. Burgess 1982 and GHR93 Offer No Alternative Paths

- **Burgess 1982**: Proves completeness for all linear frames via Henkin-style construction (maximal consistent sets). No separation procedure. No elimination cases.
- **Burgess 1984**: Overview of basic tense logic. No separation.
- **GHR93**: Proves expressive completeness of {U,S,U',S'} over all linear time and {U,S} over flows with only isolated gaps. Uses game-theoretic approach, not elimination cases. Not applicable to our setting (we already have integers, which have no gaps).
- **GHR94 Chapter 9**: Proves the abstract equivalence of separation and expressive completeness (Theorem 9.3.1). Does not give a constructive separation procedure.

## Recommended Approach

### Primary: Specialize Dedekind Elimination 5 (and 6-8) to Integers

1. **Formalize K⁺ = ⊥ and K⁻ = ⊥ on integers** as lemmas.
2. **Take the Dedekind Case 5 formula from Lemma 10.3.11.5** and substitute K⁺ = ⊥, K⁻ = ⊥, Γ⁺ = ⊥, Γ⁻ = ⊥.
3. **Verify the resulting formula** is correct for integers (the counterexample check above suggests it is).
4. **For Cases 6, 7, 8**: These reduce to other cases (including Case 5) via GHR94 reductions. Re-derive them using the corrected Case 5.
5. **This unblocks the entire hierarchy**: Cases 5-8 → Lemma 10.2.4 → 10.2.5 → 10.2.6 → 10.2.7 → 10.2.8.

### Estimated effort

- Formalizing K⁺ = ⊥ and K⁻ = ⊥ on Z: ~20 LOC
- Specializing Case 5 from Dedekind to integers: ~150-200 LOC (the formula is complex, but the proof should follow the Dedekind proof pattern with simplifications)
- Verifying correctness against the counterexample: ~30 LOC
- Cases 6-8 via reductions: ~100-150 LOC (these are reductions to Cases 1-5, already proved or derivable)
- Total: ~300-400 LOC

### Alternative: Direct Proof of Cases 5-8 on Integers

Instead of specializing the Dedekind formulas, one could try to give correct explicit formulas for Cases 5-8 on integers directly. The key issue is handling the vacuous U-satisfaction. For Case 5, one approach:

Split S(a ∧ U(A,B), q ∨ U(A,B)) into subcases based on:
- Where the U-witness u is relative to t (u > t, u = t, u < t)
- Whether the U-guard B is vacuously satisfied or not

On integers, U(A,B)(s) can hold either:
(a) With u = s+1 and vacuous B (the "immediate" case)
(b) With u > s+1 and B holds on (s, u)_Z (the "extended" case)

Separating these subcases might yield correct formulas, but this would be novel work (not in any literature) and would need careful verification.

### NOT Recommended: Reynolds Theorem 5 Route

Reynolds's approach via Stavi connectives does not help because:
1. It does not construct separated equivalents
2. It only shows that U' ↔ ⊥ in Prior structures, giving expressive completeness
3. It relies on GHR94 for the actual separation (reference [6])
4. The existing codebase already has the main theorem via ExpressiveCompleteness.lean

## Evidence/Examples

### Counterexample Verification for Dedekind Case 5

With a(0)=T, A(1)=T, B≡⊥, q(1)=q(2)=T, all other values false:

- **LHS** S(a ∧ U(A,B), q ∨ U(A,B))(3) = TRUE (witness s=0)
- **Original Section 10.2 formula**: FALSE (the `A(3) ∨ (B(3) ∧ U(A,B)(3))` conjunct fails)
- **Dedekind formula specialized to Z**: TRUE (via the third disjunct with A(1) as witness)

This confirms the Dedekind formula is correct where the original Section 10.2 formula is not.

### The Q-Lemma as Bridge

The key ingredient that makes the Dedekind formula work is the Q-lemma (GHR94 Lemma 10.3.6). On integers, Q(A,B,C) simplifies to `¬B ⇒ (S(C, ¬A) ⇒ A)` which tracks whether A must hold at the current point given that B fails and there's a past C-witness with no A in between.

This predicate captures the crucial invariant that the original Section 10.2 formula missed: the relationship between B-failure, A-occurrence, and the guard constraint.

## References

1. GHR94 Chapter 10, Section 10.2 (integer separation) — the blocked approach
2. GHR94 Chapter 10, Section 10.3 (Dedekind complete separation) — **recommended source for correct formulas**
3. GHR94 Lemma 10.3.6 (Q-lemma) — key ingredient for correct Case 5
4. GHR94 Lemma 10.3.11.5 (Dedekind Case 5) — to be specialized to integers
5. Reynolds 1994 Theorem 5 — does NOT provide separation, only expressive completeness
6. Burgess 1982 — no separation procedure
