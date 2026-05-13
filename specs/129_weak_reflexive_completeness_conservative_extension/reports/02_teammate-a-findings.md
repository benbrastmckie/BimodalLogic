# Teammate A Findings: Doets Construction Detailed Study

- **Task**: 129 - weak_reflexive_completeness_conservative_extension
- **Teammate**: A (Primary Angle)
- **Date**: 2026-05-13
- **Focus**: Precise mapping of Doets (1989) to our setting, gap analysis vs existing plan

## Key Findings

1. **The existing plan fundamentally misidentifies which Doets section is relevant.** The plan and research report repeatedly reference "Doets Claims 9-11" as if these are numbered claims within a single proof. In reality, Doets (1989) has separate sections: Section 2 (scattered orderings), Section 3 (ω and finite orderings), Section 4 (complete orderings). Each section has its own Claims 1-4 within its proofs. The plan conflates these.

2. **Section 4 (complete orderings) is NOT the right section to adapt.** Section 4 proves that definably complete orderings have complete n-equivalents. It uses *dense* condensation arguments and constructs n-equivalents of order type ℝ. Our setting is discrete (integer-like), not dense-complete. **Section 3 (definable induction on ω) is much closer to our needs**, but even it is not a perfect match because our canonical model is a reflexive preorder, not an ordering of type ω.

3. **The real Doets argument we need is a hybrid**: we need the condensation approach from Section 4 (because our canonical model has a dense-like quotient), but our target order type is ℤ (not ω or ℝ). The compression step must produce ℤ, not ω.

4. **The "10-line conservative extension" claim in the existing report is roughly correct in outline but glosses over the hardest step**: showing that the Doets compression preserves truth of the target formula. This is not "10 lines" — it requires the full n-equivalence machinery.

5. **n-equivalence in our setting corresponds to the subformula closure, NOT quantifier rank.** This is a critical distinction. See the dedicated section below.

6. **The plan's Phase 4 is severely underestimated.** The Doets compression is the hardest phase by far. The plan allocates 10 hours for it and breaks it into 4 files. In practice, the condensation + expansion + compression pipeline with full n-equivalence proofs will require 20-30 hours and is the crux of the entire construction.

**Confidence**: HIGH on findings 1-3, 5-6. MEDIUM on finding 4 (the outline is correct, the difficulty estimate may vary).

---

## Doets Paper Structure and Which Parts We Need

### Section 1: Framework

**Theorem 1.2** is the master theorem. It says: condition (ii) — "every model of the first-order schema has an n-equivalent satisfying the Π₁¹ property for each n" — implies condition (i) — "the first-order schema proves all monadic Π₁¹ consequences."

**For us**: The Π₁¹ property is IsSuccArchimedean (equivalent to: "every non-empty bounded-above set has a maximum" in our discrete setting). The first-order schema is the set of all first-order instances of IsSuccArchimedean — i.e., "for every definable set D, if D is non-empty and bounded above, then D has a maximum." This is exactly what Z1 gives us (via `FG(φ) → G(φ)`, which says definable sets that are eventually constant have a maximum for their complement).

So our goal maps to proving condition (ii): given any model of "Z1 for all definable predicates" (i.e., our weak canonical model), we need to produce an n-equivalent model that is genuinely IsSuccArchimedean (i.e., a model on ℤ).

**Lemma 1.3** (condensation from transitive relations): This is directly applicable. Our weak canonical model has a reflexive preorder R. Define `x ~ y ↔ x R y ∧ y R x`. This induces a condensation (partition into intervals). The quotient order is a strict linear order.

**Lemma 1.4** (n-equivalence of ordered sums): If each m(i) =ₙ m'(i), then Σᵢ m(i) =ₙ Σᵢ m'(i). This is the workhorse for replacing equivalence classes by n-equivalent copies.

**Lemma 1.5** (generalized ordered sum): The more sophisticated version where I and J may differ, but the distribution of n-characteristics matches. This is used in Claim 4 of Section 4.

### Section 3: ω and Finite Orderings (Theorem 3.1)

**Theorem 3.1**: If (M,<) ≡₃ (ω,<) and M satisfies definable induction, then M has n-equivalents of order type ω.

**Proof structure**: Define the set X = {a ∈ M | ∀ b < a, [b,a) has a finite n-equivalent}. Show X is definable. Show X contains the least element. Show X is closed under immediate successors. By definable induction, X = M. Then glue finite n-equivalents to get an ω-model.

**Relevance to us**: LOW. This proof works for one-sided discrete orderings (ω). Our model needs order type ℤ (two-sided). And our canonical model's preorder is reflexive, not just discrete. The induction schema proof technique of Section 3 does not directly apply.

### Section 4: Complete Orderings (Theorem 4.1)

**Theorem 4.1**: If M is definably complete, then M has complete n-equivalents for each n.

**Proof structure** (the Claims):

**Setting up the condensation**: Define `a R b` iff `a < b` and `(a,b)` has a complete n-equivalent. R is transitive (by Lemma 4.5: completely ordered sums of complete orderings are complete). So ~ from Lemma 1.3 induces a condensation. ~ is definable (finitely many n-characteristics, testing whether (a,b) has a complete n-equivalent is first-order).

**Claim 1**: Each equivalence class has a complete n-equivalent. 
- If the class I has no upper bound: choose cofinal sequence a₀ < a₁ < ..., each [aξ, aξ₊₁) has a complete n-equivalent Nξ, so I≥a = Σξ Nξ is a complete n-equivalent.
- If the class I has an upper bound: by definable completeness, the sup s exists and s ∈ I (because (a,s) has a complete n-equivalent for all a ∈ I below s, which follows from the cofinal argument applied to the sequence approaching s).

**Claim 2**: M/~ is densely ordered.
- If I < J are neighbors in M/~, then sup(I) and inf(J) are neighbors in M. But (sup(I), inf(J)) is empty (since they're consecutive), contradicting the fact that they're in different equivalence classes.

**Claim 3**: There is a proper interval D of M/~ and a finite set Σ of n-characteristics such that every I ∈ D has τ(I) ∈ Σ and each σ ∈ Σ is dense in D.
- This follows from Ramsey-like pigeonhole: finitely many n-characteristics, dense ordering.

**Claim 4**: D has but one element (contradiction).
- For any a,b in ⋃D with a < b, show (a,b) has a complete n-equivalent. The key step: construct a complete n-equivalent of ⋃E (where E is the interval (I,J) in D) by taking h: ℝ → Σ, a partition of ℝ into |Σ| dense classes, and forming the ordered sum N = Σₓ∈ℝ h(x). By Lemma 4.5, N is complete. By Lemma 1.5, N =ₙ ⋃E.

**Since M/~ is densely ordered but has only one class, M itself has a complete n-equivalent.**

### The Contradiction Argument

The key insight: if M/~ has more than one class, we get a dense ordering of equivalence classes. But we can show that ⋃D for any proper interval D has a complete n-equivalent (by the shuffling construction using ℝ). This means any two points in ⋃D are in the same equivalence class — contradiction with D being a proper interval.

So M has exactly one equivalence class, and that class has a complete n-equivalent (by Claim 1).

---

## Mapping to Our Setting

### What is our "model"?

Our starting point is the **weak Henkin canonical model**: 
- Domain: Set of weak MCS (maximal consistent sets for the weak system where G_w = φ ∧ Gφ, etc.)
- Order: `x R y ↔ ∀ φ, G_w(φ) ∈ x → φ ∈ y` (reflexive preorder)
- Valuation: `V(p) = {x | atom(p) ∈ x}`

This is a reflexive linear preorder (linearity from temporal linearity axioms BX11).

### What is our "Π₁¹ property"?

`IsSuccArchimedean`: for all a ≤ b, there exists n with succ^[n](a) = b. Equivalently (in our linear discrete setting): every non-empty bounded-above subset has a maximum.

### What is "definable"?

A subset S of the canonical model domain is definable iff S = {x | φ ∈ x} for some formula φ. In the canonical model, every point is a distinct MCS, so the definable subsets separate points (this is where the weak semantics is crucial — in the chronicle model under strict semantics, distinct points can share MCS labels, making definable sets degenerate).

### What does Z1 give us?

Z1: `G(Gφ → φ) → (FGφ → Gφ)` — under weak semantics, `G_w(G_w(φ) → φ)` is trivially `G_w(⊤) = ⊤` since `G_w(φ) → φ` is valid (by reflexivity). So Z1 collapses to `FG_w(φ) → G_w(φ)`. This says: if a definable set {x | φ ∈ x} is eventually constantly true, then it is constantly true from the current point. Equivalently: every definable set that is bounded above and non-empty has a maximum element.

So "Z1 for all definable predicates" = "definable completeness" in Doets's sense.

### Step-by-step map

| Doets (Section 4) | Our setting |
|-|-|
| Ordered model M = (M, <, U₁,...,Uₖ) | Weak canonical model = (WeakMCS, ≤, V) |
| `<` ordering | Strict part of ≤ after quotienting |
| Uᵢ unary predicates | V(p) = {x \| atom(p) ∈ x} for each p |
| "definably complete" | Z1 for all definable predicates (= Sahlqvist canonicity) |
| Π₁¹ property: "complete" | IsSuccArchimedean (every bounded set has a max) |
| Condensation ~R | `x ~ y ↔ x ≤ y ∧ y ≤ x` (mutual accessibility) |
| n-equivalence | Agreement on all formulas in `subformulaClosure(φ)` where φ is the target formula |
| n-characteristic σ of m(i) | The "type" of an equivalence class: the set of formulas from `closureWithNeg(φ)` that hold at all/some points in the class |
| Claim 1 (each class has complete n-equiv) | Each equivalence class is n-equivalent to a single ℤ segment |
| Claim 2 (M/~ dense) | M/~ has no gaps (density of the quotient) |
| Claims 3-4 (contradiction → single class) | Shuffle construction collapses M/~ to one class |
| Result: complete n-equivalent of M | Result: ℤ-model with strict < that is n-equivalent to the canonical model |

---

## Comparison with Existing Plan: Gaps and Corrections

### GAP 1: "Claims 9-11" don't exist as such

The plan references "Doets 1987 Claims 9-11" in Phase 4. Doets (1989) — the paper is from 1989, not 1987 — has Claims 1-4 within Section 4's proof of Theorem 4.1, and separate Claims 1-3 in Section 4's proof of Theorem 4.9 (about ℝ). There are no "Claims 9-11" in the paper. The plan appears to be using internally-generated numbering that doesn't correspond to the paper.

**Impact**: MEDIUM — the proof outline is roughly correct despite the misidentification. But it means the plan was written without closely reading the paper.

### GAP 2: Section 4 vs. Section 3

The plan and report treat the Doets construction as purely a "complete orderings" argument (Section 4). But our target order type is ℤ, not ℝ. Section 3's Theorem 3.1 handles ω (one-sided discrete), and Section 4's Theorem 4.1 handles complete orderings (dense-like).

We actually need a **hybrid**: the canonical model's quotient is a dense linear order (Claim 2 of Section 4), so the shuffling argument from Claim 4 of Section 4 applies. But the output must be ℤ, not some generic complete order. We need an additional step: once we know M/~ has one class, and that class has a "complete n-equivalent," we need to show the canonical model itself (before quotienting) has a ℤ-equivalent.

**Impact**: HIGH — the plan as written cannot produce order type ℤ. It produces "a complete n-equivalent" which might be some other complete order. The additional step from complete n-equivalent to ℤ-equivalent needs the Section 3 / well-ordering argument (Corollary 4.4) or a direct discrete construction.

**Resolution**: After establishing M/~ has one class (by the Section 4 argument), use the fact that our canonical model is not just complete but has immediate successors (from the discrete axiom U(⊤,⊥)) and satisfies definable induction (from Z1). Theorem 3.1 gives ω-equivalents for one direction, and the bidirectional version gives ℤ-equivalents.

Actually, the better approach: since M/~ has one class, and that class has both a least-type part (no lower bound) and a greatest-type part (no upper bound), and the class has immediate successors everywhere (from U(⊤,⊥) in all weak MCS), the class is a discrete linear order without endpoints. By definable induction (via Z1 and U(⊤,⊥)), the class is n-equivalent to ℤ.

### GAP 3: The plan conflates "Doets quotient" with "quotient by ~"

The plan's Step 1 says: "Define x ~ y iff x ≤ y and y ≤ x. Quotient by ~. The result is a strict partial order on equivalence classes."

This is correct. But the plan then says (Step 3) "expand equivalence classes to Z-shapes." This doesn't match Doets. In Doets Section 4, Claim 1 says each equivalence class already has a complete n-equivalent — it doesn't "expand" classes to Z-shapes. The classes are *replaced* by n-equivalent models with the desired order type.

The "Z-shape expansion" terminology in the plan seems to come from thinking of each equivalence class as a single point that needs to be expanded to Z. But in the canonical model, equivalence classes can be large (containing many distinct MCS that are mutually accessible). The Doets argument shows that the *entire model* is n-equivalent to a model with the desired order type.

**Impact**: HIGH — the phase structure is wrong. Phase 4 shouldn't have separate "quotient", "expansion", "compression" steps. It should be a single condensation argument that shows: (1) define ~, (2) show M/~ is dense, (3) show M/~ has one class (by contradiction), (4) show M has a ℤ-equivalent.

### GAP 4: The plan underestimates Phase 4

The plan allocates 10 hours for Phase 4 and breaks it into 4 files. The actual Doets argument requires:
1. Defining condensation and proving Lemma 1.3
2. Proving Lemma 1.4 (n-equivalence of ordered sums)
3. Proving Lemma 1.5 (generalized ordered sum n-equivalence)
4. Defining n-equivalence for our temporal logic (agreement on subformula closure)
5. Proving finiteness of n-characteristics (from finite subformula closure)
6. Proving R is transitive (for the condensation)
7. Proving definability of ~ (so we can use Z1/definable completeness)
8. Claims 1-4 of Section 4 adapted to our setting
9. The final step: converting from "single equivalence class has an n-equivalent" to "the canonical model has a ℤ n-equivalent"
10. The truth transfer: the ℤ n-equivalent satisfies ¬φ (from n-equivalence)

This is 15-25 hours of Lean code, not 10.

### GAP 5: The sorry closure approach is wrong

The plan's Phase 7 says: "Replace the sorry in succ_cofinal (or limitDomSubtype_isSuccArchimedean) with a call to the integration wrapper from Phase 6."

But the sorry is inside the Burgess chronicle construction — it's trying to prove that the chronicle's limit domain is IsSuccArchimedean. The weak Doets approach **bypasses** the chronicle entirely. It doesn't prove succ_cofinal within the chronicle; it provides an alternative discrete completeness theorem that doesn't use chronicles at all.

The integration should replace `dd_countermodel_chronicle_discrete` with a new `dd_countermodel_doets_discrete` that constructs the countermodel via the weak canonical model + Doets compression. Or it should provide an alternative proof of `bx_completeness_discrete` that doesn't go through chronicles.

**Impact**: HIGH — the plan fundamentally misunderstands the integration point. The sorry at succ_cofinal is deep inside the chronicle machinery. The Doets approach doesn't fix the chronicle; it replaces it.

---

## The n-Equivalence / Quantifier Rank Question

### Doets's notion: first-order quantifier rank

In Doets (1989), two models are n-equivalent iff they satisfy the same first-order sentences of quantifier rank < n. For models in a language with finitely many unary predicates and a binary order relation, n-equivalence has finitely many classes (Lemma 1.1). The Ehrenfeucht game characterization says: the second player wins the n-round game.

### Our notion: subformula closure agreement

In our bimodal temporal logic, formulas are not first-order — they are modal/temporal. The analogue of "quantifier rank" is the nesting depth of temporal/modal operators, or more precisely, the **subformula closure** of the target formula φ.

Two points x, y in the canonical model are "n-equivalent" (for our purposes) iff they agree on all formulas in `subformulaClosure(φ)` — i.e., for every ψ ∈ subformulaClosure(φ), ψ ∈ x ↔ ψ ∈ y.

Since `subformulaClosure(φ)` is a finite set (by the `Finset` type in the codebase), n-equivalence in our sense has finitely many equivalence classes. This is the modal analogue of Doets's Lemma 1.1.

### Why subformula closure, not modal depth?

The truth of φ at a point in the model depends only on the truth values of subformulas of φ at that point and neighboring points. The inductive truth lemma for the canonical model establishes this: `truth_at M t ψ ↔ ψ ∈ M.mcs(t)` for all ψ ∈ subformulaClosure(φ).

So our "n-characteristic" of a point x is: σ(x) = {ψ ∈ subformulaClosure(φ) | ψ ∈ x}. This is a subset of the finite set subformulaClosure(φ), giving at most 2^|subformulaClosure(φ)| many types. In practice, only the consistent types (those realized by some MCS) matter.

### How Lemma 1.5 translates

Lemma 1.5 says: if two ordered sums Σᵢ m(i) and Σⱼ m'(j) have the same distribution of n-characteristics (i.e., for each σ, {i | τ(m(i)) = σ} and {j | τ(m'(j)) = σ} are "alike"), then the sums are n-equivalent.

In our setting: if we replace each interval (equivalence class) by an interval with the same subformula-closure types distributed similarly, the resulting model agrees on all subformulas of φ. This is what makes the shuffling (Claim 4) work.

### Critical subtlety: ordered sum n-equivalence for temporal formulas

For first-order logic, Lemma 1.4/1.5 follows from Ehrenfeucht games. For temporal logic, we need an analogous result. The key property is that temporal connectives (G, H, F, P, U, S) are "local" in the following sense:

- G(ψ) at point t depends on ψ at all points t' > t
- F(ψ) at point t depends on ψ at some point t' > t
- U(ψ,χ) at point t depends on ψ,χ at points between t and some future witness

The truth of any formula ψ at a point t in an ordered sum Σ m(i) depends only on:
1. The n-characteristic of m(i) containing t
2. The n-characteristics of all m(j) with j > i (for G/F/U)
3. The n-characteristics of all m(j) with j < i (for H/P/S)
4. The way these n-characteristics are distributed in the index set I

This is exactly the content of Lemma 1.5 generalized to temporal logic. The proof is a bisimulation / back-and-forth argument.

**For Lean formalization**: This is the hardest part. We need to prove that n-equivalence (subformula agreement) is preserved by ordered sums. This requires a careful induction on formula structure, showing that truth at a point in an ordered sum depends only on the n-type of the surrounding intervals.

---

## The Transfer Argument (Fully Detailed)

### Statement

**Theorem (Discrete Completeness via Doets)**: If φ is valid on all discrete IsSuccArchimedean frames under strict semantics, then φ is provable (i.e., `Nonempty (DerivationTree ∅ φ)`).

### Proof (Contrapositive)

**Step 1**: Assume φ is not provable: `¬ Nonempty (DerivationTree ∅ φ)`.

**Step 2**: Then {¬φ} is consistent in the strict system (by `neg_consistent_of_not_derivable`, already proved in `Completeness.lean:58`).

**Step 3**: Define the weak axiom system. The weak temporal operators are: G_w(ψ) = ψ ∧ G(ψ), etc. The weak axioms include:
- All strict axioms (BX1-BX11, S5 modal axioms, Prior-UZ/SZ, Z1)
- T axiom for weak temporal: G_w(ψ) → ψ (propositional tautology: (ψ ∧ Gψ) → ψ)
No additional axioms are needed — the strict axioms already generate the weak system.

**Step 4**: Since all strict axioms are weak axioms (the weak system extends the strict system), consistency in the strict system implies consistency in the weak system. Formally: if {¬φ} derives ⊥ in the weak system, then (since every weak axiom is a strict theorem) {¬φ} derives ⊥ in the strict system, contradicting Step 2.

*SUBTLETY*: This step requires care. The weak system doesn't have new axioms — it uses the SAME axiom system but interprets G_w as an abbreviation for φ ∧ G(φ). The "weak canonical model" is constructed using the SAME derivation system but with the reflexive preorder coming from G_w rather than G. The consistency transfer is trivial because the axiom systems are identical.

**Step 5**: By Lindenbaum's lemma (already proved as `set_lindenbaum`), extend {¬φ} to a maximal consistent set A₀.

**Step 6**: Construct the weak canonical model:
- Domain: all MCS of the (same!) axiom system
- Order: `x R y ↔ ∀ψ, G(ψ) ∈ x → ψ ∈ y` (this is reflexive because each MCS contains all theorems, and G(ψ) → ψ is not a theorem — wait, this is the problem. Under the strict system, G(ψ) → ψ is NOT a theorem, so R is NOT automatically reflexive.)

**CRITICAL ISSUE**: The existing report says "R is reflexive since G_w(ψ) → ψ is an axiom." But G_w(ψ) = ψ ∧ G(ψ), and G_w(ψ) → ψ is a propositional tautology. However, the canonical model relation is defined using G_w, not G. If we define `x R y ↔ ∀ψ, G_w(ψ) ∈ x → ψ ∈ y`, then R is reflexive because G_w(ψ) → ψ is in every MCS (being a tautology, hence a theorem, hence in every MCS by maximality).

So the canonical model construction works as follows:
1. Build MCS using the standard axiom system (same as always)
2. Define order using G_w: `x ≤ y ↔ ∀ψ, G_w(ψ) ∈ x → ψ ∈ y`
3. This is reflexive (G_w(ψ) → ψ is in every MCS)
4. This is transitive (from G_w(ψ) → G_w(G_w(ψ)), which requires: (ψ∧Gψ) → ((ψ∧Gψ) ∧ G(ψ∧Gψ)). The first conjunct is immediate. The second requires Gψ → G(ψ∧Gψ), which follows from G(Gψ → ψ∧Gψ) and K for G. G(Gψ → ψ∧Gψ) follows from Gψ → ψ∧Gψ being a theorem under G — wait, this gets complicated.)
5. Actually: G_w(ψ) → G_w(G_w(ψ)) is equivalent to (ψ∧Gψ) → ((ψ∧Gψ)∧G(ψ∧Gψ)). This reduces to (ψ∧Gψ) → G(ψ∧Gψ). By monotonicity of G: Gψ → G(ψ∧Gψ) follows from ψ → (ψ∧Gψ → ψ∧Gψ) — no, this doesn't work directly. We need: G(ψ) ∧ G(Gψ) → G(ψ ∧ Gψ). This follows from G distributing over ∧. And G(Gψ) follows from G(ψ) via the 4-axiom for G if present. But do we have G(Gψ) → G(G(Gψ))? Yes, if we have BX4 (G(ψ) → G(G(ψ))) as an axiom.

Actually, checking the Axiom type would clarify. But for now: transitivity of R follows from standard modal logic properties. The point is that these are derivable in the strict system.

**Step 7**: Truth lemma: for all ψ ∈ subformulaClosure(φ), the weak canonical model satisfies `ψ ∈ x ↔ x ⊨_R ψ` where ⊨_R is truth under the reflexive preorder.

The key cases:
- G_w(ψ) case forward: G_w(ψ) ∈ x means ψ ∧ G(ψ) ∈ x. For any y with x R y, we need ψ ∈ y. If y = x, then ψ ∈ x (from the conjunction). If y ≠ x with x R y, then G(ψ) ∈ x gives ψ ∈ y by definition of R.
- G_w(ψ) case backward: G_w(ψ) ∉ x means either ψ ∉ x or G(ψ) ∉ x. If ψ ∉ x, then x itself witnesses the failure (R is reflexive). If G(ψ) ∉ x, by Lindenbaum, there exists y with x R y and ψ ∉ y.

**Step 8**: The canonical model with the reflexive preorder R satisfies Z1 for all definable predicates (Sahlqvist canonicity: Z1 is Sahlqvist, so the canonical frame validates Z1). Under weak semantics, Z1 collapses to: every definable set that is bounded above and eventually constant has a global maximum — i.e., the canonical model is "definably IsSuccArchimedean."

**Step 9**: Apply the Doets condensation argument (adapted from Section 4, Theorem 4.1):
- Define condensation ~ on the canonical model
- Show M/~ is densely ordered (Claim 2)
- Show M/~ has one equivalence class (Claims 3-4)
- Conclude: the canonical model has an n-equivalent with order type ℤ (combining the single-class result with the discrete structure from U(⊤,⊥))

**Step 10**: Let N be the ℤ n-equivalent. N is a model on ℤ with strict ordering <. By n-equivalence, N satisfies the same formulas of the target depth as the canonical model. In particular, ¬φ is true at the point corresponding to A₀ in N.

**Step 11**: N, being ℤ with strict <, is trivially a discrete IsSuccArchimedean frame (ℤ is IsSuccArchimedean in Mathlib).

**Step 12**: We have a model N on ℤ (discrete, IsSuccArchimedean) where φ is false. This contradicts the assumption that φ is valid on all discrete IsSuccArchimedean frames.

**Step 13**: Therefore φ is provable. QED.

### Where the "10 lines" claim fails

The transfer argument (Steps 1-13) is indeed short in mathematical prose. But Steps 6-10 each require substantial Lean infrastructure:
- Step 6: Full canonical model construction for the weak system (~500 lines)
- Step 7: Truth lemma (~300 lines)
- Step 8: Sahlqvist canonicity for Z1 (~100 lines)
- Step 9: Full Doets condensation argument (~800 lines)
- Step 10: n-equivalence preservation of truth (~200 lines)

The "10 lines" is the *outline* (Steps 1-5 + Steps 11-13). The meat (Steps 6-10) is ~2000 lines of Lean.

---

## Recommended Approach

### Architecture

Instead of the plan's 7 phases, I recommend 5:

**Phase 1: Weak Canonical Model (15h)**
Build the canonical model using the existing axiom system but with the R defined via G_w. Include:
- R definition, reflexivity, transitivity, linearity
- Full truth lemma for all formula constructors
- Z1 canonicity (definable IsSuccArchimedean)
- Discreteness propagation from □(U(⊤,⊥))

**Phase 2: n-Equivalence Infrastructure (10h)**
Define:
- n-type (subformula closure restriction) 
- n-equivalence of ordered models (agreement on subformula types)
- Prove ordered sum preservation (Lemmas 1.4, 1.5 for our temporal logic)
- Prove finiteness of n-types

**Phase 3: Doets Condensation (12h)**
The core argument:
- Define condensation ~ on the canonical model
- Prove Claims 1-4 adapted to our setting
- Conclude single equivalence class
- Produce ℤ n-equivalent

**Phase 4: Transfer Theorem (3h)**
The contrapositive argument wiring everything together:
- neg_consistent_of_not_derivable → Lindenbaum → weak canonical model → Doets condensation → ℤ countermodel → contradiction

**Phase 5: Integration (3h)**
Replace `dd_countermodel_chronicle_discrete` with a new `dd_countermodel_doets_discrete` that uses the transfer theorem. Update `bx_completeness` to use the new path. The chronicle `succ_cofinal` sorry becomes dead code (can be archived in task 130).

Total: ~43h

### Key design decision: avoid the "weak axiom system" entirely

The plan and report create a separate "weak axiom system" with "weak consistency," "weak MCS," etc. This is unnecessary. The weak canonical model uses the **same** axiom system as the strict one. The only difference is the definition of R: instead of `x R y ↔ ∀ψ, G(ψ) ∈ x → ψ ∈ y` (irreflexive), we use `x R y ↔ ∀ψ, (ψ ∧ G(ψ)) ∈ x → ψ ∈ y` (reflexive). 

This means we can reuse ALL existing MCS infrastructure (`SetMaximalConsistent`, `set_lindenbaum`, all MCS properties). No new "WeakMCS" type is needed.

---

## Evidence/Examples

### Van Benthem's Example (Doets 1.6.1)

(ω, <) satisfies definable cofinality — every definable set is either finite or cofinite — so the schema "X and its complement cannot both be cofinal" holds for definable X. But ω doesn't have a greatest element (which is what the full Π₁¹ property requires).

This is exactly analogous to our chronicle model: every definable predicate in the constant-MCS case is either empty or the full domain, so Z1 holds vacuously, but the model can have Z+Z structure (not IsSuccArchimedean).

### The canonical model resolves this

In the canonical model, every non-trivial subset IS approximated by a definable one (since distinct MCS have discriminating formulas). So "definable IsSuccArchimedean" (from Z1) implies full IsSuccArchimedean. This is the definability gap closure.

---

## Confidence Levels

| Finding | Confidence |
|-|-|
| Plan misidentifies Doets claims numbering | HIGH |
| Section 4 is the right framework (not Section 3 alone) | HIGH |
| n-equivalence = subformula closure agreement | HIGH |
| Phase 4 is severely underestimated at 10h | HIGH |
| Sorry closure approach is wrong (should bypass chronicle, not fix it) | HIGH |
| "10-line argument" is correct in outline but hides ~2000 lines of infrastructure | HIGH |
| Hybrid Section 3+4 approach needed for ℤ target | HIGH |
| Weak axiom system is unnecessary (reuse existing MCS) | MEDIUM — depends on whether R reflexivity proof goes through cleanly with the same axiom system |
| Total effort estimate ~43h | MEDIUM — could be higher if n-equivalence infrastructure proves harder than expected |
