# Teammate D: Horizons Assessment -- Normal Form KType Redesign

**Task**: 143 -- Doets Lemma 1.1 Normal Form KType Redesign
**Focus**: Long-term design, strategic alignment, publication value, downstream impact
**Date**: 2026-05-15

---

## 1. Strategic Assessment: How NormalForm Fits the Reynolds Pipeline

### 1.1 The Dependency Chain

The sorry-free `bx_completeness` goal requires closing 14 sorries across 4 tasks (139, 140, 141, 142). Task 143 targets the `ktype_finite` / `finite_types` sorries which sit at the foundation of the Reynolds pipeline:

```
Task 143 (NormalForm / ktype_finite)
  |
  v
Task 139 (FO satisfaction: k_type_of, k_equiv_monotone, KEquivalenceFramework instance)
  |
  v
Task 140 (truth transfer: table correctness, Reynolds pipeline wiring)
  |
  v
Task 142 (mixed-case countermodel: final bx_completeness branch)
```

**Critical observation**: The task 139 research report (02_fintype-blocker-research.md) establishes that `ktype_finite` is **mathematically impossible as currently stated** -- the domain `{s : MonadicFormula sig 0 // s.quantifier_depth <= k}` is syntactically infinite (unbounded `not`/`and` nesting), so `Fintype` on the function type is impossible. Task 143 is therefore not a nice-to-have; it is a **necessary prerequisite** for task 139 to close `finite_types`.

However, the same report identifies that **neither `ktype_finite` nor `finite_types` is consumed anywhere downstream**. This means the redesign has maximum architectural freedom: we can change type signatures, redefine `KType`, and restructure `KEquivalenceFramework` without breaking any existing code.

### 1.2 What Downstream Tasks Actually Need

Reading through the sorry chain carefully:

- **`finite_structures_good`** (IntegerModel.lean:95): Needs to show finite structures are k-equivalent to a Z-interval. Does not directly use `ktype_finite` or `finite_types`.
- **`very_good_implies_good`** (IntegerModel.lean:210): Needs `sum_preservation` (Doets Lemma 1.4), which is about k-equivalence preservation under ordered sums.
- **`chronicle_is_good`** (IntegerModel.lean:222): Chains through `very_good_implies_good`.
- **`contemp_equiv_is_equiv` transitivity** (IntegerModel.lean:136): Needs combining subintervals.
- **`sum_preservation`** (NEquivalence.lean:325): The deepest sorry -- ordered sums preserve k-equivalence.

The actual bottleneck is `sum_preservation` (Doets Lemma 1.4), not `ktype_finite`. Normal forms help with `sum_preservation` because the EF-game argument for ordered sums relies on the finiteness of the space of k-characteristics (Doets 1987 Lemma 3.1.7/3.1.8). Without finiteness, the duplicator's strategy in the EF game cannot be defined.

### 1.3 Serving All Downstream Uses

For the design to serve tasks 139 through 142:

1. **Task 139**: Needs `Fintype (Quotient (Setoid.ker (k_type_of sig k)))` or equivalent. The redesign must provide a **finite witness type** through which `k_type_of` factors.

2. **Task 140**: Needs `table : Formula -> MonadicFormula sig 1` and `table_depth_bound`. These are independent of NormalForm but benefit from a clean `k_type_of` definition for the truth transfer step.

3. **Task 142** (mixed case): Uses the Reynolds pipeline at a higher level. Needs the full chain to work.

4. **`sum_preservation`**: This is the hardest sorry and benefits most from normal forms. With a finite `NormalForm` type, the EF-game argument simplifies: player II's strategy depends only on which normal form each component realizes, and there are finitely many such strategies.

---

## 2. Will Normal Forms Simplify sum_preservation?

### 2.1 The EF-Game Argument (Doets 1987 Lemma 3.1.7)

The classical proof of sum preservation (Doets 1987, Lemma 3.1.7) states:

> If for all i in I, m(i) is n-equivalent to m'(i), then the ordered sum of m(i) is n-equivalent to the ordered sum of m'(i).

The proof uses EF games: player II's strategy in the n-game on the sums is to (a) identify which component contains I's chosen element, (b) find a matching element in the corresponding component of the other sum using the component-level winning strategy, and (c) ensure consistency across components.

### 2.2 Can Normal Forms Bypass EF Games?

**Partially, yes.** With normal forms:

- k-equivalence = same normal form assignment (same truth on all depth-k characteristics)
- Each component has a well-defined k-type in `NormalFormIdx sig k 0`
- The ordered sum's k-type is determined by the indexed family of component k-types
- `sum_preservation` reduces to: if components have matching k-types, the sums have matching k-types

**However**, the proof that "the ordered sum's k-type is determined by the component k-types" itself requires an inductive argument on quantifier depth that is structurally similar to the EF-game proof. The induction step at depth k+1 requires showing that for any existential sentence of depth k+1, its truth in the sum depends only on the truth of depth-k sentences in the components.

**Assessment**: Normal forms do not eliminate the EF-game argument but **reformulate it as a cleaner structural induction** on quantifier depth. The EF game becomes implicit in the normal form induction rather than requiring explicit game-tree construction. This is a significant simplification for formalization.

### 2.3 A Concrete Path for sum_preservation

With `NormalForm sig k n` defined as `Fin (nfCount p k n)`:

1. Define `nf_eval : NormalFormIdx sig k n -> OrderedMonadicStructure sig -> (Fin n -> carrier) -> Prop` giving the semantic meaning of each normal form index.
2. Prove `nf_completeness`: every depth-k formula with n variables is equivalent to a disjunction of normal forms.
3. Prove `sum_nf_determined`: the truth of a normal form in an ordered sum depends only on the normal forms realized in the components, via structural induction on k.
4. Derive `sum_preservation` from `sum_nf_determined`.

Step 3 is the core work and corresponds to the induction step in Doets' Lemma 3.1.7/3.1.8. The quantifier case uses: "exists x in Sum_i m(i) satisfying phi" iff "exists component i and exists x in m(i) satisfying phi" -- the FO quantifier ranges over the sum's carrier, which decomposes component-wise.

---

## 3. Design Recommendations

### 3.1 Recommended Architecture: Hybrid Normal Form + Quotient

I recommend a **hybrid approach** combining Approaches 1 and 2 from the task 139 research:

**Layer 1: Computable Normal Form Count** (purely computational)
```lean
def nfCount (p : Nat) : Nat -> Nat -> Nat
  | 0, n => 2 ^ (p * n + n * (n - 1) / 2)
  | k+1, n => nfCount p 0 n * 2 ^ (nfCount p k (n + 1))

abbrev NormalFormIdx (sig : MonadicSignature) (k n : Nat) :=
  Fin (nfCount (Fintype.card sig.preds) k n)
```

**Layer 2: Semantic Content** (ties indices to truth)
```lean
noncomputable def nf_eval (sig : MonadicSignature) (k n : Nat) :
    NormalFormIdx sig k n -> OrderedMonadicStructure sig -> (Fin n -> carrier) -> Prop
```

**Layer 3: Bridge Theorem** (Doets Lemma 1.1 = the mathematical core)
```lean
theorem doets_lemma_1_1 (sig : MonadicSignature) (k n : Nat)
    (phi : MonadicFormula sig n) (h : phi.quantifier_depth <= k) :
    exists (S : Finset (NormalFormIdx sig k n)),
      forall (M : OrderedMonadicStructure sig) (env : Fin n -> M.carrier),
        eval M env phi <-> exists idx in S, nf_eval sig k n idx M env
```

**Layer 4: KType Redesign**
```lean
-- Option A: Redefine KType with finite domain
def KType (sig : MonadicSignature) (k : Nat) : Type :=
  NormalFormIdx sig k 0 -> Bool

-- ktype_finite is now trivial
instance ktype_finite : Fintype (KType sig k) := inferInstance

-- k_type_of factors through nf_eval
noncomputable def k_type_of (sig : MonadicSignature) (k : Nat)
    (M : OrderedMonadicStructure sig) : KType sig k :=
  fun idx => decide (nf_eval sig k 0 idx M Fin.elim0)
```

**Why this hybrid**: Layer 1 is computable and gives `Fintype` trivially. Layer 2 provides the semantic bridge. Layer 3 is the genuine mathematical content. Layer 4 gives clean downstream APIs.

### 3.2 Why Not Use Mathlib's BoundedFormula?

Mathlib has `FirstOrder.Language.BoundedFormula` with:
- `Theory.iffSetoid` (semantic equivalence as a setoid)
- `Theory.Iff` (semantic equivalence relation)
- `BoundedFormula.Realize` (satisfaction)
- `IsQF`, `IsPrenex` (complexity classification)
- Fraisse theory for linear orders (`isFraisseLimit_of_countable_nonempty_dlo`)

**Analysis of alignment**:

- **Pro-Mathlib**: `BoundedFormula` handles arbitrary first-order languages, has well-tested infrastructure, and `Theory.iffSetoid` already defines the quotient we need.
- **Anti-Mathlib**: The monadic FO case is **dramatically simpler** than general FO. Mathlib's `BoundedFormula` has full multi-ary function symbols, equality, and arbitrary relation arities. Our formulas only need: unary predicates, binary `<`, and quantification over a single sort. Using `BoundedFormula` would require:
  1. Defining a `Language` with `Relations 1 := sig.preds`, `Relations 2 := Unit` (for `<`), `Functions _ := Empty`
  2. Encoding the `<` interpretation via `OrderedStructure` from `Mathlib.ModelTheory.Order`
  3. Proving that our monadic formulas embed into `BoundedFormula`
  4. Relating our `eval` to `BoundedFormula.Realize`

**Verdict**: Building on the existing `MonadicFormula` is strongly preferred. The codebase already has a working `eval`, `k_type_of`, `k_equiv`, and the full `KEquivalenceFramework`. Migrating to Mathlib's `BoundedFormula` would require rewriting 400+ lines of NEquivalence.lean, IntegerModel.lean, OrderedSum.lean, and Table.lean -- with no concrete benefit since we never need the generality of multi-ary relations or function symbols.

However, I recommend **documenting the correspondence** with Mathlib's infrastructure in a comment, so that a future contributor could build a bridge if desired:

```lean
-- NormalFormIdx sig k n corresponds to equivalence classes of
-- MonadicFormula sig n under logical equivalence at depth k.
-- This parallels Mathlib's Theory.iffSetoid on BoundedFormula,
-- specialized to the monadic FO case over linear orders.
```

### 3.3 Specificity vs Generality

**Recommendation: Monadic-FO-over-linear-orders specific.**

Reasons:
1. The entire Reynolds pipeline is specific to monadic FO over linear orders.
2. General FO normal forms (Scott sentences, n-characteristics for arbitrary signatures) are a much larger project with different combinatorics.
3. The nfCount formula is specific to the monadic-order case (atoms = predicates * variables + order pairs).
4. Generality would require parameterizing over relation arities and function symbols, turning a 6-9 hour task into a 30+ hour task with no benefit to this project.
5. Lean/Mathlib already provides the general infrastructure via `BoundedFormula`. Our contribution is the *specialized* formalization.

### 3.4 Computation vs Classical Proof

**Recommendation: Computational `nfCount`, classical `nf_eval`.**

- `nfCount` should be **computable** -- it is a pure arithmetic function with no logical content. This enables `Fintype` via `inferInstance` and potential `#eval` for small cases.
- `nf_eval` should be **noncomputable** using `Classical.dec` -- because evaluation over potentially infinite carriers requires decidability of satisfaction, which is only available classically for infinite structures.
- `k_type_of` should remain **noncomputable** -- same reason as `nf_eval`.
- `doets_lemma_1_1` is a **Prop-valued existence statement** -- it says "there exists a finite set of normal forms equivalent to phi." It does not need computability.

**Trade-off analysis**:
- Making `nf_eval` computable would require `DecidableEq` and `Fintype` on carriers, restricting to finite structures. This breaks `k_type_of` for infinite structures (like Z-models), which is the primary use case.
- The `decide` call in `k_type_of` uses `Classical.dec` precisely because the carrier may be infinite. This is correct and necessary.
- Future tasks (frame hierarchy, algebraic representation) will also need classical reasoning over infinite domains.

---

## 4. Impact on Future Tasks

### 4.1 Task 126: Frame Hierarchy

The four-tier frame hierarchy (Base -> Dense/Discrete -> Integer) uses Sahlqvist correspondence for each axiom extension. Normal forms are not directly relevant here -- frame correspondence works at the modal level, not the monadic FO level. However, NormalForm provides the semantic foundation for understanding *why* each tier has the same set of k-equivalence classes: the Sahlqvist axioms constrain which normal forms are realizable at each tier.

**Impact**: Low direct, moderate conceptual.

### 4.2 Task 127: Time Addition Operator

The time addition operator extends expressiveness from FO[<] to FO[<,+]. Normal forms for FO[<,+] are fundamentally different from those for FO[<] -- Presburger arithmetic's quantifier elimination has a different structure. The `NormalForm` type defined here would NOT be reusable for FO[<,+].

**Impact**: None. Task 127 would need its own normal form theory.

### 4.3 Task 125: Jonsson-Tarski Representation

The algebraic representation theorem connects modal algebras to Kripke frames via atom structures. The key bridge is that the Lindenbaum algebra modulo logical equivalence is a BAO (Boolean Algebra with Operators). Normal forms provide a concrete **finite basis** for the subalgebra generated by formulas of bounded depth. This could simplify the construction of canonical structures in the algebraic framework.

**Impact**: Moderate. The `NormalFormIdx` type provides a finite generating set for the Lindenbaum algebra truncated at depth k. This is relevant to the STSA representation (task 992) and Jonsson-Tarski (task 125) but would require additional bridge lemmas.

### 4.4 Task 116: Redefine G/H/F/P via Until/Since

No interaction. This is a syntactic refactoring of temporal operators that does not touch the monadic FO level.

**Impact**: None.

### 4.5 Summary of Cross-Task Impact

| Task | Impact Level | Nature |
|------|-------------|--------|
| 139 (FO satisfaction) | **Critical** | Provides the finite type needed for `finite_types` |
| 140 (truth transfer) | **High** | Clean `k_type_of` enables table correctness proof |
| 141 (truth lemma) | None | Works at MCS level, not monadic FO |
| 142 (mixed case) | **High** | Needs full Reynolds pipeline which needs `sum_preservation` |
| 126 (frame hierarchy) | Low | Conceptual connection only |
| 125 (Jonsson-Tarski) | Moderate | Finite basis for Lindenbaum subalgebra |
| 127 (time addition) | None | Different signature, different normal forms |

---

## 5. Literature-Guided Design

### 5.1 Doets 1987 Chapter 1 (Sections 1.6-1.7): n-Characteristics

Doets defines the n-characteristic `[[a]]^n` of a point `a` in model A (Definition 1.6.1):

- **Base**: `[[a]]^0` = conjunction of all atomic/negated-atomic sentences true of `a`
- **Step**: `[[a]]^{n+1}` = `[[a]]^0 ∧ ∀x∨_{a'∈A} [[a,a']]^n ∧ ∧_{a'∈A} ∃x [[a,a']]^n`

**Lemma 1.7.1**: If the language is finite, there are finitely many n-characteristics for sequences of length k.

This is exactly the theorem we need. The key insight is that n-characteristics are defined **inductively on n** with a finite base case and a finite step (since the set of (n-1)-characteristics is finite by induction).

**Formalization note**: Doets' definition quantifies over all elements of A, producing infinitary formulas for infinite models. For the *finite* case (finite language, characteristic as an equivalence class), the finiteness comes from the counting argument, not from the syntactic formula itself. Our `NormalFormIdx` captures this counting.

### 5.2 Doets 1987 Chapter 7: Z-Completeness Proof

The Z-completeness proof (our task 140's endpoint) uses n-characteristics at step 9:

> Suppose x in A and n in A* have the same shape. Then for all formulas phi over VAR_chi: M |= phi[x] iff N |= phi[n].

This step relies on the EF game for tense logic, where player II can always maintain a position where (i) positions are in the same equivalence class and (ii) positions have the same shape (= same 0-characteristic = same atom assignment). The finite number of shapes is crucial.

**For our design**: The "shape" at depth 0 is just the 0-characteristic: which atoms are true. This corresponds to `NormalFormIdx sig 0 0 = Fin (2^p)` where p = number of predicates. The Z-completeness proof uses this at the specific depth k = rank(chi), confirming that our `nfCount` calculation aligns with the literature.

### 5.3 Reynolds 1994 (via Hodkinson-Reynolds 2006)

Reynolds' framework uses k-equivalence (our `k_equiv`) and the key properties:
- k-equivalence is an equivalence relation (trivial from definition)
- Finitely many k-types (our `finite_types` -- this is Doets Lemma 1.7.1)
- Sum preservation (Doets Lemma 3.1.7/3.1.8)

Reynolds does not introduce normal forms explicitly -- he relies on Doets for the finiteness result and uses k-types as abstract equivalence classes. Our `NormalFormIdx` provides the concrete realization that Reynolds leaves implicit.

### 5.4 Venema 1991 Chapter 2: Sahlqvist and Canonical Structures

Venema's chapter focuses on completeness for modal logics with non-xi rules (like the irreflexivity rule). The relevant connection is to our task 126 (frame hierarchy), not directly to normal forms. However, Venema's Theorem 2.3.3 (persistence of Sahlqvist formulas on discrete general frames) is relevant to understanding why our Sahlqvist axioms (trans, succ, r-lin, l-lin, modified Lob) work correctly in the canonical model -- they persist from the general frame to the underlying Kripke frame.

**For NormalForm design**: No direct impact, but Venema's framework confirms that the Sahlqvist axioms of our tense logic TM are canonical, which means the truth lemma (task 141) and canonical model construction work correctly. The normal forms operate at the monadic FO level (below the modal level), so they are independent of the Sahlqvist machinery.

---

## 6. Publication Value

### 6.1 What Would Be Novel

To my knowledge, there is no existing Lean/Mathlib formalization of:
1. Ehrenfeucht-Fraisse games for monadic FO over linear orders
2. Normal forms / n-characteristics for monadic FO (Doets 1987 Lemma 1.7.1)
3. Sum preservation of k-equivalence (Doets 1987 Lemma 3.1.7)
4. The Reynolds Z-completeness pipeline for tense logic

Mathlib has general Fraisse theory (`isFraisse_finite_linear_order`, `isFraisseLimit_of_countable_nonempty_dlo`) but not the bounded quantifier-depth version needed for completeness proofs.

### 6.2 Design Choices for Maximum Publication Impact

1. **Clean separation of layers**: The computational layer (nfCount), the semantic layer (nf_eval), and the bridge theorem (doets_lemma_1_1) should be in separate sections/files. This makes each layer independently citable.

2. **Explicit induction principle**: The proof of doets_lemma_1_1 should use a clean induction on quantifier depth with explicit base case and step case, mirroring the textbook proof. This makes the formalization pedagogically valuable.

3. **Compatibility with Mathlib's `Theory.iffSetoid`**: Document how `NormalFormIdx` relates to the equivalence classes of `MonadicFormula sig n` under logical equivalence. A bridge lemma showing `Fintype (Quotient (iffSetoid T))` for the monadic theory T restricted to depth k would be a publishable result.

4. **Standalone module**: The NormalForm definitions should be importable independently of the Reynolds pipeline, so they could be used in other Lean formalizations of model theory.

### 6.3 Contribution Positioning

The formalization could be positioned as:

> **A Lean 4 formalization of Doets' normal forms for monadic first-order logic over linear orders, with applications to completeness of tense logic TM over integer time.**

This is a contribution to:
- Lean/Mathlib model theory (fills gap between general Fraisse theory and specific completeness proofs)
- Formalized mathematics (first mechanized proof of Z-completeness for Until/Since tense logic)
- Temporal logic (machine-verified completeness for the Burgess/Reynolds axiom system)

---

## 7. Confidence Assessment

| Aspect | Confidence | Notes |
|--------|-----------|-------|
| `nfCount` formula correctness | **High (95%)** | Standard combinatorial argument from Doets 1987 |
| Feasibility of `doets_lemma_1_1` proof | **High (90%)** | Induction on quantifier depth is well-understood |
| Feasibility of `sum_preservation` via NormalForm | **Medium-High (80%)** | Structural induction replaces EF game, but inductive step requires careful handling of ordered sum quantification |
| No need for Mathlib BoundedFormula migration | **High (95%)** | Existing MonadicFormula infrastructure is sufficient and well-integrated |
| 6-9 hour estimate accuracy | **Medium (70%)** | `doets_lemma_1_1` proof is the risk factor; could expand to 12+ hours if the inductive step is tricky |
| Publication value | **High (90%)** | Novel formalization territory with clear audience |
| Correctness of nfCount step case | **Medium (75%)** | The formula `nfCount p 0 n * 2^(nfCount p k (n+1))` combines the QF base with 2^(number of depth-k formulas with n+1 vars). Need to verify this matches Doets exactly -- may need adjustment for the quantifier alternation structure |

### Key Risk

The `nfCount` step case formula deserves scrutiny. Doets' argument at depth k+1 with n free variables says:

- Every depth-(k+1) formula is equivalent to a Boolean combination of:
  - QF atoms (depth 0 with n variables): there are `nfCount p 0 n` equivalence classes
  - Formulas `forall x_{n+1}. phi` where `phi` has depth k and n+1 variables: there are `nfCount p k (n+1)` equivalence classes
  
- A Boolean combination of M items has at most `2^M` equivalence classes (up to Boolean equivalence).

So at depth k+1 with n variables, the count should be:
```
2^(nfCount p 0 n + nfCount p k (n+1))
```

But the report from task 139 has:
```
nfCount p 0 n * 2^(nfCount p k (n+1))
```

These are **not the same** unless `nfCount p 0 n = 2^(nfCount p 0 n)`, which is false. The correct formula should be:

```
2^(nfCount p 0 n + nfCount p k (n+1))
```

since both the QF part and the quantified part contribute independent Boolean coordinates. This needs to be verified carefully during implementation.

**Alternatively**, the step case could be:
```
nfCount p 0 n * 2^(2 * nfCount p k (n+1))
```

if we account for both `forall` and `exists` contributing independently (since `exists x. phi` is equivalent to `not forall x. not phi`, each forall class gives an exists class, so the combined space is `nfCount p 0 n * 2^(nfCount p k (n+1))` for the forall sentences, but since exists is reducible to forall+not, the Boolean combination space might be different).

**Recommendation**: Verify the exact counting formula against Doets 1987 Lemma 1.7.1 before implementation. The formula matters for correctness of `nfCount` but NOT for the overall architecture -- any correct upper bound suffices for defining `Fin N` as the index type.

---

## 8. Summary of Design Recommendations

1. **Use NormalFormIdx = Fin (nfCount p k n)** as the core finite type. This gives trivial `Fintype` and clean APIs.

2. **Keep MonadicFormula infrastructure**. Do not migrate to Mathlib's BoundedFormula. The existing eval/k_type_of/k_equiv are well-integrated and sufficient.

3. **Scope to monadic FO over linear orders**. General FO normal forms are a different (much larger) project. Our contribution is the specialized formalization.

4. **Use computational nfCount + classical nf_eval**. The counting function is computable; the semantic evaluation uses Classical.dec for infinite carriers.

5. **Redefine KType to use NormalFormIdx as domain**. This makes ktype_finite trivial and aligns with the mathematical definition.

6. **Prove doets_lemma_1_1 by induction on k**. This is the mathematical core. Base case is straightforward (enumerate atom assignments). Step case requires showing every depth-(k+1) formula reduces to a Boolean combination of QF atoms and forall-of-depth-k formulas.

7. **Verify the nfCount step-case formula** against Doets 1987 before implementation. The formula from the task 139 report may have an error.

8. **Place NormalForm in its own file** (e.g., `NormalForm.lean`) importable independently of the Reynolds pipeline, for maximum reusability and publication value.

9. **Delete the unused `ktype_finite` sorry** after redefining KType. It was impossible as stated and is consumed nowhere.

10. **Target sum_preservation as the next sorry** after normal forms are in place. Normal forms transform the EF-game argument into structural induction on quantifier depth, which is more formalization-friendly.
