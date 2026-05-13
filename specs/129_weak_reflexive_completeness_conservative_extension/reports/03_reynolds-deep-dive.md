# Reynolds Deep Dive: End-to-End Proof Trace for Task 129

**Task**: 129 — Weak/reflexive completeness and conservative extension
**Date**: 2026-05-13
**Type**: Focused deep-dive on three open questions

---

## 1. Executive Summary

The Reynolds approach is viable and is the recommended path. The hardest part is **not** the gap elimination (which mostly collapses in the canonical model) but rather **the truth lemma for the reflexive canonical model** and **the ordered-sum n-equivalence preservation for temporal formulas**. The gap elimination (Reynolds Lemmas 6-13) largely simplifies away because in the canonical model every point is a distinct MCS, making expressive completeness unnecessary — the Prior-UZ/SZ axioms applied directly to temporal formulas suffice. The ordered-sum lemma (Doets 1.4) works for monadic first-order sentences, and since every temporal formula has a first-order table, we can work at the monadic first-order level for the n-equivalence argument, avoiding a purely temporal proof. The end-to-end pipeline requires approximately **1800-2400 lines** across 9 new files, with **45-65 hours** estimated effort. The approach replaces only `dd_countermodel_chronicle_discrete` in `bx_completeness`, leaving the dense and mixed cases untouched.

---

## 2. Question 1: Gap Elimination in the Canonical Model

### The Key Structural Difference

Reynolds works with a Burgess-Xu model M₀ that is:
- A generic countable discrete linear order without endpoints
- Prior-UZ/SZ valid everywhere
- NOT a canonical model — points are NOT MCS, subsets are NOT all definable

In our setting, we work with the **reflexive canonical model** where:
- Domain = {S : Set Formula | SetMaximalConsistent S}
- Each point IS an MCS
- For any two distinct points x ≠ y, ∃ φ with φ ∈ x ∧ φ ∉ y
- Every subset definable by a formula IS a "temporal definable" subset
- The model already satisfies Prior-UZ/SZ (as axioms, in every MCS)

### Reynolds's Gap Elimination: What It Does

Reynolds §7 proves Theorem 14: if ~ is a contemporaneous equivalence on a Prior structure M, then ~-classes don't end at gaps. The proof goes through Lemmas 6-13.

The core concern: a contemporaneous equivalence ~M partitions M into convex classes. Could a class boundary coincide with a "gap" (a Dedekind cut where neither side contains the cut point)? Reynolds shows this cannot happen in Prior structures.

### Lemma-by-Lemma Analysis in the Canonical Model

**Lemma 6**: *There is a US-formula R holding exactly at points whose ~-class ends in a gap on the right.*

Reynolds defines a first-order formula ρ(x) meaning "x's ~-class ends in a gap on the right" and invokes expressive completeness (Theorem 5) to get a temporal formula R equivalent to ρ over Prior structures.

**In the canonical model**: We DON'T need this step. The reason:

In Reynolds's proof, R is used to apply Prior-UZ to R itself — "if R holds somewhere ahead, then R holds until ¬R" (i.e., the first occurrence of R is definably reachable). This requires R to be a temporal formula (since Prior-UZ applies to temporal formulas).

In the canonical model, the situation is simpler. For the Theorem 15 proof (Section 8), the gap elimination is used in a single step: "a's class cannot end at a gap on the right (by Theorem 14)." The argument then continues: "so it must include a point c but not c+1. But M|[c, c+1] is finite, hence very good, and ~ is transitive. Contradiction."

**The critical question**: Does the Reynolds Theorem 15 proof actually USE Lemmas 6-13, or does it only cite Theorem 14?

Looking at the Theorem 15 proof (Reynolds p.131, line 970):
> "Now a's class can not end at a gap on the right (by theorem 5 and the fact that Prior-UZ and dual imply Prior-U and dual)"

Wait — Reynolds cites **Theorem 5** (expressive completeness) and the Prior axioms directly, not Theorem 14! The argument is:

1. Suppose a's ~-class ends in a gap on the right
2. By definition of ~M (Lemma 17), the class boundary is where "very good" fails
3. "Very good" is defined via k-equivalence to Z-intervals, which is a first-order definable property (finitely many k-types, Lemma 17 proof)
4. So the ~M equivalence is contemporaneous (defined by a monadic formula)
5. By Theorem 14 (= Theorem 5 + Prior axioms), ~M classes don't end at gaps

So Theorem 14 IS used, and its proof chain (Lemmas 6-13) IS on the critical path.

### Can We Avoid Expressive Completeness?

**Yes, but not by eliminating Theorem 14.** Instead, we can simplify the argument by working directly in the canonical model.

The key observation: **In the canonical model, we don't need to translate between temporal and monadic first-order formulas.** The canonical model's points are MCS, so every monadic predicate on the domain that is definable by a first-order formula is ALSO definable by a temporal formula (because each MCS is characterized by its temporal-formula membership).

More precisely: the equivalence ~M from Lemma 17 is defined by the monadic formula ε(x,y) which says "M|[x,y] is very good." "Very good" means "all subintervals are good," and "good" means "has a k-equivalent with Z-flow." Since there are finitely many k-types (conjunctions of monadic sentences of quantifier depth ≤ k), goodness is definable by a monadic formula γ(x,y). In the canonical model, every monadic formula with one free variable is equivalent to a temporal formula (because the canonical model satisfies all Prior axiom instances, making it a Prior structure, and US is expressively complete over Prior structures).

**BUT**: we don't actually need to formalize expressive completeness as a theorem. We need only the following:

**Claim**: In the reflexive canonical model, the Prior-UZ axiom instances applied to the temporal formulas in the subformula closure of the target formula φ suffice to eliminate gaps for the ~M equivalence (where k is determined by φ).

**Argument**: The ~M equivalence classes are determined by the k-types of intervals. k-types are conjunctions over a finite set of monadic sentences. In the canonical model, each such sentence is equivalent to a temporal formula (by construction — the canonical model's domain consists of MCS, so formula membership determines all properties). Prior-UZ applied to these temporal formulas says: if some formula holds in the future, there is a first time it holds. This means gaps cannot occur at class boundaries, because a gap would create a temporal discontinuity detectable by one of finitely many formulas.

### Simplified Gap Elimination for the Canonical Model

Instead of Lemmas 6-13, the argument in the canonical model is:

1. Define ~M as in Reynolds Lemma 17 (via "very good" intervals)
2. ~M is a contemporaneous equivalence (Lemma 17, works identically)
3. Suppose class C ends in a gap on the right: ∃ a ∈ C, ∀ b > a with b ∉ C, ∃ c with a < c < b and c ∈ C (cofinal in the gap)
4. The "very good" property is definable by finitely many formulas from the subformula closure (at depth k)
5. Let ψ be the temporal formula that characterizes "being in a non-very-good interval with the start of my class." ψ holds at all points of C that are near the gap and fails at all points beyond the gap.
6. Prior-UZ applied to ψ says: Fψ → U(ψ, ¬ψ). If ψ holds somewhere ahead, there is a first future point where ψ holds. But ψ holds approaching the gap and fails after it — the "first ψ" would have to be at the gap itself, which doesn't exist.
7. Contradiction.

**Key simplification**: We don't need Lemma 6 (finding temporal R via expressive completeness), because in the canonical model, ψ can be constructed directly from formulas in the MCS. Steps 4-6 replace Lemmas 6-13 entirely.

**Estimated Lean 4 lines**: 200-350 lines for the canonical model gap elimination (vs. ~600+ for formalizing Reynolds Lemmas 6-13 + expressive completeness).

**Confidence**: MEDIUM-HIGH. The argument is sound but the exact formalization of "ψ characterizes being near the gap" needs careful treatment. The finiteness of k-types is the key enabler.

### Actually — An Even Simpler Path

Re-reading the Theorem 15 proof more carefully:

> "Now a's class can not end at a gap on the right (by theorem 5 and the fact that Prior-UZ and dual imply Prior-U and dual) so it must include a point c but not the successor c + 1 of c."

Reynolds uses TWO facts: (1) no gap at class boundary, and (2) the model is discrete so the only alternative to a gap is a successor jump (c to c+1).

In a discrete model without endpoints (which our canonical model is, since □U(⊤,⊥) ensures discreteness), **gaps cannot exist at all**. Here's why:

- In a discrete linear order, between any two points a < b there are finitely many points (by IsSuccArchimedean — wait, that's what we're trying to prove!)

Actually no, the canonical model is NOT necessarily IsSuccArchimedean. It's discrete (has immediate successors) but could have Z+Z-type structure. So gaps CAN exist in the abstract order. But:

- The canonical model is a linear order on MCS
- Each MCS is "discrete" (contains □U(⊤,⊥), so every MCS has an immediate successor in the canonical ordering)
- Between c and c+1 there are no points (by definition of immediate successor)
- So the ONLY way a ~-class can end is at a point c where c ∈ [a's class] but c+1 ∉ [a's class]

This means: in a discrete canonical model, **gaps cannot occur at class boundaries because there are no gaps — all boundaries are at successor jumps**. The gap elimination is trivially true!

Wait — is this right? A gap in the sense of Reynolds/Doets means a Dedekind cut where neither side has the cut point. In a discrete order, can this happen?

Yes, it CAN happen if the order has Z+Z-structure: the "gap" between the left Z and the right Z is a genuine Dedekind gap. Neither Z has a maximum/minimum at the cut.

But such a gap would require an infinite descending sequence on one side and an infinite ascending sequence on the other. In the canonical model, each point has an immediate successor (from □U(⊤,⊥)), so if c is in the left part and c+1 exists, where does c+1 go?

If c is in the left part of the gap, c+1 must also be in the left part (or in the gap itself — but there are no gap points). If c+1 is in the right part, then c and c+1 are on opposite sides of the gap, which means there's no gap between them (they're consecutive!). So the gap must be further to the right of c+1. But then c+1 is in the left part, and by the same argument c+2 is in the left part, etc. By induction, ALL successors of c are in the left part. So the left part is cofinal — there is no gap.

**This is the argument.** In a discrete order with immediate successors, the only way ~-classes can end is at successor boundaries (c to c+1), not at gaps. No expressive completeness needed. No gap elimination lemmas needed. The discreteness + immediate successors does all the work.

**Conclusion for Question 1**: Reynolds's Lemmas 6-13 are **entirely unnecessary** in our setting because our canonical model is discrete with immediate successors everywhere (from □U(⊤,⊥)). In a discrete model, there are no gaps — every class boundary is a successor jump. The only thing we need from Reynolds §7-8 is the "good/very good" framework from Theorem 15.

**Estimated Lean 4 lines for gap elimination**: ~50-80 lines (a simple induction showing that in a discrete order with immediate successors, no Dedekind gaps exist between convex subsets).

**Confidence**: HIGH. This is a simple order-theoretic fact about discrete linear orders.

---

## 3. Question 2: Ordered Sum n-Equivalence

### The Problem

Doets Lemma 1.4 states: if m(i) =ₙ m'(i) for all i ∈ I, then Σᵢ m(i) =ₙ Σᵢ m'(i), where =ₙ is first-order n-equivalence (agreement on all sentences of quantifier depth ≤ n).

Reynolds Theorem 15 uses this implicitly ("Because =ₖ is preserved under lexicographic sums") and cites references [10, 3, 9].

### Does It Work for Temporal Formulas?

**Yes, because Reynolds works at the monadic first-order level, not the temporal level.**

Reynolds's Theorem 15 states: "there is a temporal structure with flow of time the integers satisfying the same **monadic first-order sentences** of quantifier depth at most k as M does."

The proof:
1. Build a Z-model N with N =ₖ M (monadic first-order k-equivalence)
2. The target formula A₀ has a "table" — a monadic first-order formula α(t) with truth_at(M,t,A₀) ↔ M ⊨ α(t)
3. The quantifier depth of α is bounded by some function of A₀'s modal depth
4. Choose k greater than this depth
5. Since N =ₖ M, N ⊨ ∃t α(t) iff M ⊨ ∃t α(t)
6. Since M ⊨ A₀(t₀), M ⊨ α(t₀), so M ⊨ ∃t α(t), so N ⊨ ∃t α(t)
7. Therefore N ⊨ A₀(b) for some b

The key: we work with monadic first-order k-equivalence throughout. Temporal formulas enter only via their tables (standard translation). The ordered-sum preservation (Doets Lemma 1.4) is for first-order k-equivalence and applies directly.

### Do We Need to Formalize the Standard Translation?

**Partially.** We need:

1. **Definition of monadic first-order k-equivalence**: M =ₖ N iff M and N satisfy the same monadic first-order sentences of quantifier depth ≤ k. In practice, this is equivalent to: for each monadic k-type τ (maximal consistent conjunction of sentences of depth ≤ k), M ⊨ τ iff N ⊨ τ. Since there are finitely many k-types, k-equivalence is decidable.

2. **Ordered sum preservation (Doets 1.4)**: If m(i) =ₖ m'(i) for each i, then Σᵢ m(i) =ₖ Σᵢ m'(i). This is a standard result whose proof via Ehrenfeucht games is well-known but nontrivial to formalize.

3. **Table existence**: Every temporal formula A has a monadic formula α(t) such that for all structures, truth_at(M,t,A) ↔ M ⊨ α(t). This is a simple induction on formula structure.

4. **Quantifier depth bound**: The quantifier depth of α(A) is bounded by a function of A's complexity. For atoms: depth 1. For ¬A: depth of α(A). For A ∧ B: max(depth(α(A)), depth(α(B))). For U(A,B): 1 + max(depth(α(A)), depth(α(B))). For □A: TBD (depends on the modal dimension).

### Can We Avoid Formalizing Ehrenfeucht Games?

**Yes.** Instead of formalizing the full Ehrenfeucht game characterization, we can use a simpler approach:

**Approach**: Define k-equivalence directly as "agree on all monadic sentences of quantifier depth ≤ k." Prove ordered-sum preservation by induction on k using back-and-forth arguments on the sentences themselves (not on games).

Actually, the cleanest approach for Lean is:

**Type-based k-equivalence**: A structure M has k-type τ_k(M), which is the set of monadic sentences of depth ≤ k true in M. There are finitely many k-types (since the language has finitely many predicate symbols). Two structures are k-equivalent iff they have the same k-type.

**Ordered sum preservation**: To show Σᵢ m(i) has the same k-type as Σᵢ m'(i) when each m(i) has the same k-type as m'(i), argue by induction on the sentences. For ∃x φ(x) (depth ≤ k), the witness x ∈ m(i) for some i. By k-1-equivalence of m(i) and m'(i), the same formula holds in m'(i), giving a witness in the sum.

Wait — this is oversimplified. The full argument needs to handle quantifiers that range across different summands. The Ehrenfeucht game argument handles this naturally. Without games, we'd need to prove the following lemma:

**Lemma**: For ordered sums of monadic structures with finitely many predicates, if the "profile" of the index set (which k-types appear and with what density/distribution) matches, then the sums are k-equivalent.

This is exactly Doets Lemma 1.5, and its proof really does use the game technique.

### Practical Resolution: Wrap the k-Equivalence in an Axiom or Trust It

For the formalization, we have three options:

**(A) Fully formalize Ehrenfeucht games + Doets 1.4**: ~500-800 lines. Reusable but substantial.

**(B) Formalize a restricted version**: Since we only need the result for FINITE k-type sets (our language has finitely many atoms for any given target formula), we can formalize a simpler version: "if all summands have k-types from a finite set Σ, and two index sets have the same distribution of Σ-types (each type dense in both, or each type present in the same ordinal pattern), then the sums are k-equivalent." This is ~300-500 lines.

**(C) Use a sorry for the ordered-sum preservation and close it later**: ~20 lines. The mathematical validity is not in question (it's a textbook result). The sorry would be mathematically clean and isolated.

**Recommendation**: Option (B) for the first implementation, with the possibility of upgrading to (A) later. The restricted version is sufficient for Reynolds's proof: in Lemma 16 (countable very-good → good), the summands are finite subintervals of the canonical model, each with a k-type from a finite set. The sum has the same k-type as a sum of Z-intervals with matching types.

**Estimated Lean 4 lines**: 300-500 lines for option (B).

**Confidence**: MEDIUM. The mathematical content is standard, but formalizing it in Lean 4 with the right level of generality requires careful engineering.

---

## 4. Question 3: End-to-End Pipeline

### Overview

The proof is by contrapositive: assume φ is not derivable, construct a countermodel on ℤ.

### Step-by-Step Type-Level Trace

**Step 0: Entry point (replaces dd_countermodel_chronicle_discrete)**

```lean
theorem doets_countermodel_discrete (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (φ : Formula) (h_neg_in : φ.neg ∈ A)
    (h_box_discrete : Formula.box next_top ∈ A) :
    ∃ (D : Type) (_ : AddCommGroup D) (_ : LinearOrder D) (_ : IsOrderedAddMonoid D)
      (_ : Nontrivial D) (F : TaskFrame D) (TM : TaskModel F)
      (Omega : Set (WorldHistory F)) (_ : ShiftClosed Omega)
      (τ : WorldHistory F) (_ : τ ∈ Omega) (t : D),
      ¬truth_at TM Omega τ t φ
```

This has the EXACT same signature as `dd_countermodel_chronicle_discrete` (ChronicleToCountermodel.lean:3285). It is a drop-in replacement.

**Source**: NEW (Integration.lean)
**Reuse**: Signature matches existing; called from bx_completeness in same position.
**Lines**: ~30 (wrapper that calls the pipeline)

---

**Step 1: Reflexive Canonical Model Construction**

```lean
-- Domain: All MCS of the TM system (unchanged from existing)
def ReflCanDomain := { S : Set Formula // SetMaximalConsistent S }

-- Reflexive accessibility: x R y iff G_w content of x ⊆ y
-- where G_w(ψ) = ψ ∧ G(ψ), so g_w_content x = {ψ | ψ ∧ G(ψ) ∈ x}
def g_w_content (x : ReflCanDomain) : Set Formula :=
  { ψ | Formula.and ψ (Formula.all_future ψ) ∈ x.val }

def reflCanR (x y : ReflCanDomain) : Prop :=
  g_w_content x ⊆ y.val

-- Key properties:
theorem reflCanR_refl : ∀ x : ReflCanDomain, reflCanR x x
-- Proof: G_w(ψ) → ψ is a propositional tautology (φ∧Gφ → φ), hence in every MCS.
-- So if ψ∧G(ψ) ∈ x, then ψ ∈ x.

theorem reflCanR_trans : ∀ x y z : ReflCanDomain,
    reflCanR x y → reflCanR y z → reflCanR x z
-- Proof: If ψ∧G(ψ) ∈ x then ψ ∈ y and G(ψ) ∈ y (by MCS conjunction).
-- G(ψ) ∈ y → G(G(ψ)) ∈ y (by temp_4 axiom).
-- ψ ∈ y and G(ψ) ∈ y → ψ∧G(ψ) ∈ y (by MCS conjunction).
-- So ψ∧G(ψ) ∈ y, and since reflCanR y z, ψ ∈ z.

theorem reflCanR_linear : ∀ x y : ReflCanDomain,
    reflCanR x y ∨ reflCanR y x
-- Proof: From BX11 (temporal linearity) and BX4 (connectedness).
```

**Source**: NEW (ReflexiveCanonical.lean)
**Reuse**: `SetMaximalConsistent`, `set_lindenbaum` from Core/MaximalConsistent.lean; MCS properties from Core/MCSProperties.lean; `g_content` pattern from Bundle/WitnessSeed.lean
**Lines**: ~250 (domain def, R def, reflexivity, transitivity, linearity, discreteness)

---

**Step 2: Discrete Structure of the Canonical Model**

```lean
-- From □U(⊤,⊥) ∈ A and MCS properties, every MCS contains U(⊤,⊥)
-- (by box_closure: □φ ∈ S → φ ∈ S for S5 MCS, and since all box-
-- equivalent MCS share □U(⊤,⊥)).

-- Actually, we need: ∀ x : ReflCanDomain, box_related_to_A x →
--   next_top ∈ x.val
-- where next_top = U(⊤,⊥).

-- The canonical model restricted to box-class of A has immediate successors:
-- If x is in the canonical model, next_top ∈ x, so ∃ y > x with
-- y is the immediate successor (no points between x and y in the
-- reflexive canonical order).

-- This needs the truth lemma for Until in the reflexive model.
```

**Source**: NEW (ReflexiveCanonical.lean, later section)
**Reuse**: Box-related MCS lemmas from Completeness.lean
**Lines**: ~100 (discreteness propagation, immediate successor existence)

---

**Step 3: Truth Lemma for the Reflexive Canonical Model**

```lean
-- For the restricted subformula closure of the target formula φ:
-- For all ψ ∈ SubformulaClosure(φ), for all x : ReflCanDomain,
--   ψ ∈ x.val ↔ reflCanModel_truth_at x ψ

-- where reflCanModel_truth_at evaluates ψ at x in the reflexive canonical model.
-- Note: this is NOT the standard truth_at (which uses strict <).
-- This is truth under the reflexive preorder R.

-- Cases:
-- atom p: ψ ∈ x ↔ atom(p) ∈ x (by definition of canonical valuation)
-- bot: False ↔ bot ∈ x (by MCS consistency)
-- imp: (ψ₁ → ψ₂) ∈ x ↔ (ψ₁ ∈ x → ψ₂ ∈ x) (by MCS implication property)
-- box: □ψ ∈ x ↔ ∀ y box-related to x, ψ ∈ y (standard S5 canonical model)
-- all_future (G): Gψ ∈ x ↔ ∀ y with x R y, y ≠ x → ψ ∈ y
--   Wait — G uses STRICT future in truth_at. In the reflexive canonical model:
--   G_w(ψ) ∈ x ↔ ∀ y ≥ x, ψ ∈ y (reflexive).
--   G(ψ) ∈ x ↔ ∀ y > x, ψ ∈ y (strict, same as standard truth_at).
--   The truth lemma for G: G(ψ) ∉ x → ∃ y, x R y ∧ y ≠ x ∧ ψ ∉ y
--   Proof: G(ψ) ∉ x → ¬G(ψ) ∈ x → F(¬ψ) ∈ x → by Lindenbaum,
--   extend {χ | G(χ) ∈ x} ∪ {¬ψ} to MCS y. Then x R y (by G-content)
--   and ψ ∉ y (by ¬ψ ∈ y). Need y ≠ x: since ψ ∈ SubCl(φ), if ψ ∉ y
--   but ψ status unknown for x... actually we need G(ψ) ∉ x, so either
--   ψ ∉ x (then we already have x ≠ y is possible) or ψ ∈ x but
--   G(ψ) ∉ x (then y can equal x if ψ ∈ y, but ψ ∉ y, so y ≠ x). Done.
-- all_past (H): Symmetric to G.
-- untl (Until): U(ψ₁,ψ₂) ∈ x ↔ ∃ y > x, ψ₁ ∈ y ∧ ∀ z, x < z < y → ψ₂ ∈ z
--   Forward: U(ψ₁,ψ₂) ∈ x → F(ψ₁) ∈ x (by until_F axiom) → ∃ y > x.
--   Backward: U(ψ₁,ψ₂) ∉ x → ...
--   The backward direction for Until requires constructing a witness chain.
--   Standard approach: by induction using self-accumulation (BX5) and
--   absorption (BX6) axioms. This is the most complex case.
-- snce (Since): Symmetric to Until.
```

**Source**: NEW (TruthLemma.lean)
**Reuse**: MCS properties; deduction theorem; existing WitnessSeed patterns
**Lines**: ~500-700 (this is the largest single component)

The truth lemma handles G/H in the reflexive canonical model straightforwardly. The Until/Since cases are the hardest, requiring the standard Henkin construction of chains of MCS witnessing the eventuality structure. The key tools: Lindenbaum extension, BX5 (self-accumulation), BX6 (absorption), BX7 (linearity).

---

**Step 4: Frame Properties**

```lean
-- Z1 holds in the canonical frame:
-- For all x, G(Gψ→ψ)→(FGψ→Gψ) ∈ x (by axiom z1, theorem_in_mcs)
-- By truth lemma: the canonical frame validates Z1.

-- Prior-UZ/SZ hold:
-- For all x, Fψ → U(ψ,¬ψ) ∈ x (by axiom prior_UZ, theorem_in_mcs)
-- By truth lemma: the canonical frame validates Prior-UZ/SZ.

-- Discreteness:
-- For all x in box-class of A, U(⊤,⊥) ∈ x (from h_box_discrete)
-- By truth lemma: every point has an immediate successor.
```

**Source**: NEW (FrameProperties.lean or part of ReflexiveCanonical.lean)
**Reuse**: `theorem_in_mcs` from Core/MCSProperties.lean
**Lines**: ~80

---

**Step 5: Reynolds Theorem 15 (Z-Model Construction)**

This is the core: given the reflexive canonical model M (countable, discrete, no endpoints, Prior-UZ/SZ valid), produce a Z-model k-equivalent to M.

```lean
-- 5a: Define k-type and k-equivalence (monadic first-order)
-- A k-type is a maximal consistent set of monadic sentences of quantifier depth ≤ k.
-- In practice: represented as a Finset of monadic sentences.
-- M =ₖ N iff they have the same k-type.

-- 5b: Define "good" and "very good"
def good (k : Nat) (M : Structure) : Prop :=
  ∃ N : Structure, N.flow_is_Z_interval ∧ N =ₖ M

def very_good (k : Nat) (M : Structure) : Prop :=
  ∀ a b : M.domain, a ≤ b → good k (M.restrict [a,b])

-- 5c: Define ~M (contemporaneous equivalence)
def contemporary_equiv (k : Nat) (M : Structure) (a b : M.domain) : Prop :=
  a = b ∨ (a < b ∧ very_good k (M.restrict [a,b])) ∨
  (b < a ∧ very_good k (M.restrict [b,a]))

-- 5d: ~M is an equivalence relation with convex classes (Lemma 17)
-- Key: transitivity uses ordered-sum preservation (Doets 1.4)
-- If a ~ b and b ~ c (a < b < c), then M|[a,c] is very good because:
-- M|[t,u] for t < b < u: M|[t,b] is good, M|[b+1,u] is good,
-- so M|[t,u] =ₖ Z₁ + Z₂ (by Doets 1.4) which is a Z-interval. Hence good.

-- 5e: Gap elimination (simplified for discrete model)
-- In a discrete model, ~-classes cannot end at gaps (trivial — see Q1).
-- The only way a class can end is at a successor boundary c, c+1.
-- But M|[c,c+1] is a 2-element structure, hence finite, hence good.
-- So c ~ c+1, contradicting the class boundary. Hence one class.

-- 5f: One class → M is good (Lemma 16)
-- If M is very good and countable:
-- Choose cofinal sequence a₀ < a₁ < a₂ < ...
-- Each M|[aᵢ, aᵢ₊₁-1] is good, so =ₖ to some Zᵢ (finite Z-interval)
-- M =ₖ Σᵢ Zᵢ (by Doets 1.4), which has Z-flow.
-- Handle the backward direction symmetrically.

-- 5g: Produce the Z-model
-- M is good → ∃ N with Z-flow and N =ₖ M.
-- N is a temporal structure on Z with a valuation.
```

**Source**: NEW (NEquivalence.lean, OrderedSum.lean, IntegerModel.lean)
**Reuse**: None (this is all new infrastructure)
**Lines**: 
- NEquivalence.lean: ~200 (k-types, k-equivalence, finiteness)
- OrderedSum.lean: ~350 (ordered sums, Doets 1.4 restricted)
- IntegerModel.lean: ~300 (good, very good, ~M, one-class, Z-model)

---

**Step 6: Truth Transfer**

```lean
-- The Z-model N has N =ₖ M (monadic first-order k-equivalence).
-- The target formula φ has a "table" α(t) with quantifier depth < k.
-- M ⊨ ∃t α(t) (since M ⊨ φ(t₀) iff M ⊨ α(t₀)).
-- N ⊨ ∃t α(t) (by k-equivalence).
-- So ∃ b ∈ Z, N ⊨ α(b), hence N ⊨ φ(b).
-- N falsifies our target: ¬φ was true at the root MCS A₀ in M.
-- By k-equivalence, ¬φ is true somewhere in N.

-- Actually: the specific transfer.
-- We need: ¬φ ∈ A₀ → ¬truth_at(N, b, φ) for some b.
-- The table of ¬φ has quantifier depth ≤ k.
-- A₀ satisfies ¬φ in M (by truth lemma).
-- M ⊨ ∃t α(¬φ)(t) (witnessed by t₀).
-- N ⊨ ∃t α(¬φ)(t) (by k-equivalence).
-- So ∃ b, N ⊨ (¬φ)(b), i.e., ¬truth_at(N, b, φ).
```

**Source**: NEW (Transfer.lean)
**Reuse**: Truth lemma (from Step 3)
**Lines**: ~120 (table construction + transfer argument)

---

**Step 7: Z is a Valid Discrete Frame**

```lean
-- ℤ with standard < satisfies:
-- AddCommGroup ℤ ✓ (Mathlib)
-- LinearOrder ℤ ✓ (Mathlib)
-- IsOrderedAddMonoid ℤ ✓ (Mathlib)
-- Nontrivial ℤ ✓ (Mathlib)
-- SuccOrder ℤ ✓ (Mathlib)
-- PredOrder ℤ ✓ (Mathlib)
-- IsSuccArchimedean ℤ ✓ (Mathlib)
-- IsPredArchimedean ℤ ✓ (Mathlib)

-- The N model on ℤ can be packaged as a TaskFrame + TaskModel:
-- TaskFrame ℤ: trivial construction
-- TaskModel: valuation from the Z-model
-- Omega: singleton or universal (ShiftClosed)
-- WorldHistory: trivial on ℤ

-- Package into the existential type matching dd_countermodel_chronicle_discrete.
```

**Source**: NEW (Integration.lean)
**Reuse**: Mathlib instances for ℤ; TaskFrame/TaskModel constructors from Semantics/
**Lines**: ~80

---

**Step 8: Wire into bx_completeness**

```lean
-- In Completeness.lean, replace:
--   Chronicle.dd_countermodel_chronicle_discrete M hM_mcs φ h_neg_in h_box_discrete
-- with:
--   doets_countermodel_discrete M hM_mcs φ h_neg_in h_box_discrete

-- Since the type signatures match exactly, this is a 1-line change.
```

**Source**: MODIFY (Completeness.lean, 1 line)
**Lines**: 1

---

### Pipeline Summary Table

| Step | File | Type | Lines | Reuse |
|------|------|------|-------|-------|
| 0 | Integration.lean | NEW | 30 | Signature from ChronicleToCountermodel |
| 1 | ReflexiveCanonical.lean | NEW | 250 | SetMaximalConsistent, set_lindenbaum, MCS properties |
| 2 | ReflexiveCanonical.lean | NEW | 100 | Box-class lemmas |
| 3 | TruthLemma.lean | NEW | 600 | MCS properties, DeductionTheorem, WitnessSeed pattern |
| 4 | FrameProperties.lean | NEW | 80 | theorem_in_mcs |
| 5a | NEquivalence.lean | NEW | 200 | None (new infrastructure) |
| 5b | OrderedSum.lean | NEW | 350 | None (new infrastructure) |
| 5c-g | IntegerModel.lean | NEW | 300 | NEquivalence, OrderedSum |
| 6 | Transfer.lean | NEW | 120 | TruthLemma, NEquivalence |
| 7-8 | Integration.lean | NEW+MODIFY | 80+1 | Mathlib instances, TaskFrame/TaskModel |
| — | WeakCanonical.lean | NEW | 15 | Root import |
| **Total** | | | **~2130** | |

---

## 5. Revised Architecture

The answers to Q1-Q3 revise the recommended architecture as follows:

### Major Simplification: No Gap Elimination Module

The canonical model is discrete (from □U(⊤,⊥)), so gaps cannot exist between ~-class boundaries. The 200-350 lines estimated for gap elimination (from the team synthesis) reduces to ~50 lines. No `GapElimination.lean` file is needed; the argument fits inside `IntegerModel.lean`.

### Module Structure

```
Metalogic/WeakCanonical/
├── ReflexiveCanonical.lean   — Domain, R, reflexivity, transitivity, linearity, discreteness (~350 lines)
├── TruthLemma.lean           — Full truth lemma for reflexive canonical model (~600 lines)
├── NEquivalence.lean         — k-types, k-equivalence, finiteness (~200 lines)
├── OrderedSum.lean           — Ordered sums, Doets 1.4 (restricted) (~350 lines)
├── IntegerModel.lean         — good/very_good, ~M, one-class, Z-model (~300 lines)
├── Transfer.lean             — Table construction + transfer argument (~120 lines)
├── Integration.lean          — doets_countermodel_discrete + packaging (~110 lines)
└── WeakCanonical.lean        — Root import (~15 lines)
```

**Total: ~2050 lines** (± 400)

### What Changed from Team Synthesis

1. **Eliminated GapElimination.lean** — gaps don't exist in discrete models
2. **Eliminated WeakOperators.lean** — G_w is used only in ReflexiveCanonical.lean's R definition, not worth a separate file
3. **Eliminated WeakAxioms.lean** — no separate weak axiom system; the axiom system is unchanged
4. **Added OrderedSum.lean** — the ordered-sum preservation is the new hard infrastructure
5. **Added Transfer.lean** — cleanly separated from the model construction

---

## 6. Risk Assessment

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Truth lemma for Until/Since in reflexive canonical model is harder than expected | HIGH | MEDIUM | Follow existing WitnessSeed pattern from Bundle/; BX5+BX6 handle eventuality resolution |
| Ordered-sum preservation (Doets 1.4) is harder to formalize than expected | MEDIUM | MEDIUM | Can use a sorry initially and close it as a separate task; the mathematical content is textbook |
| Packaging Z-model as TaskFrame/TaskModel/WorldHistory is awkward | LOW | HIGH | TaskFrame/TaskModel are simple structures; WorldHistory on Z may need a trivial total function |
| The "table" construction (temporal → monadic FO) needs more lines than estimated | LOW | MEDIUM | Can use a simplified version: just track subformula depth, not full standard translation |
| Compilation time increases significantly (~2000 new lines) | LOW | LOW | Separate files minimize recompilation; no changes to existing heavy files |

### The One Real Risk

The **truth lemma for Until/Since** is the hardest known challenge. The existing chronicle construction (ChronicleToCountermodel.lean) spends thousands of lines on related constructions. For the reflexive canonical model, the truth lemma is simpler (no irreflexivity issues, no chronicle), but the Until backward direction still requires constructing MCS chains. Estimate: 200-300 lines for Until alone, which is feasible but the primary schedule risk.

---

## 7. Recommended Phase Structure

### Phase 1: Reflexive Canonical Model (12-16 hours)
- **Files**: ReflexiveCanonical.lean, TruthLemma.lean
- **Content**: Domain, R definition, reflexivity/transitivity/linearity proofs, discreteness propagation, full truth lemma
- **Depends on**: Nothing (uses only existing Core/ infrastructure)
- **Risk**: Until/Since truth lemma
- **Deliverable**: A complete reflexive canonical model with truth lemma

### Phase 2: n-Equivalence Infrastructure (10-14 hours)
- **Files**: NEquivalence.lean, OrderedSum.lean
- **Content**: k-types, k-equivalence, finiteness, ordered sum construction, Doets Lemma 1.4 (restricted)
- **Depends on**: Nothing (pure order theory + finite combinatorics)
- **Risk**: Ordered-sum preservation formalization
- **Deliverable**: Reusable n-equivalence library

### Phase 3: Z-Model Construction (8-12 hours)
- **Files**: IntegerModel.lean, Transfer.lean
- **Content**: Good/very-good definitions, ~M equivalence, one-class argument, Z-model extraction, truth transfer
- **Depends on**: Phase 1 (canonical model), Phase 2 (n-equivalence)
- **Risk**: Low (mathematical content is the Reynolds Theorem 15 proof, which is straightforward given Phase 1-2)
- **Deliverable**: A Z-model falsifying the target formula

### Phase 4: Integration (3-5 hours)
- **Files**: Integration.lean, WeakCanonical.lean, modify Completeness.lean (1 line)
- **Content**: Package Z-model as TaskFrame/TaskModel, wire into bx_completeness
- **Depends on**: Phase 3
- **Risk**: Low (type-matching exercise)
- **Deliverable**: Sorry-free discrete completeness path

### Total: 33-47 hours (4 phases, serial)

Phases 1 and 2 are independent and could run in parallel if desired, reducing wall-clock time to ~25-35 hours.
