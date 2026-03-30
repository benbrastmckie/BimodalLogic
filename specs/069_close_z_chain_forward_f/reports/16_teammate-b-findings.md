# Research Report: Strong Induction Strategy for F-Preserving Temporal Witness

**Task**: 69 - close_z_chain_forward_f
**Focus**: Strong induction proof structure for `f_preserving_seed_consistent`
**Date**: 2026-03-30
**Researcher**: Teammate B (math-research-agent)

---

## Key Findings

### 1. The Fundamental Asymmetry Problem

The current 700-line proof at lines 1384-2101 has an irreparable structural flaw:

**Current Extraction Order**:
1. Extract F(psi) first: `L |- bot` becomes `L_no_F |- G(neg psi)`
2. Then extract phi: `L_no_F |- G(neg psi)` becomes `L_no_phi |- phi -> G(neg psi)`
3. G-lift: `G(phi -> G(neg psi)) in M`
4. K-distribution: `G(phi) -> G(G(neg psi)) in M`

**The Break Point**: When `G(phi) not in M` (equivalently `neg(G(phi)) = F(neg phi) in M`):
- The implication `G(phi) -> G(neg psi)` is vacuously true in M
- Modus ponens cannot derive `G(neg psi) in M`
- We cannot contradict `F(psi) in M`

This is NOT a local proof bug -- it reflects a genuine logical gap in the extraction strategy.

### 2. The Critical Modal Logic Principle

**Key Insight**: `G(A or B) -> G(A) or G(B)` is NOT valid in modal logic.

For the proof to work, we need a different route. The correct principle is:

**What IS Valid**:
- `G(A) or G(B) |- G(A or B)` (trivial, by weakening inside G)
- The T-axiom: `G(X) -> X`, so `G(G(A)) -> G(A)`
- If we derive `L_final |- G(neg s1) or ... or G(neg sk) or neg(phi)` where `L_final ⊆ temporal_box_seed M`, then:
  - G-lift: `G(G(neg s1) or ... or G(neg sk) or neg(phi)) in M`
  - T-axiom application to each G-formula inside: `G(neg s1) or ... or G(neg sk) or G(neg phi) in M`
  - MCS disjunction: at least one disjunct is in M
  - Each contradicts the corresponding F-formula in M

**The Fix**: Build a disjunction where EVERY disjunct is already a G-formula (or becomes one via T-axiom).

### 3. Correct Extraction Order: phi LAST, not specially

**Recommended Strategy**:

1. **Extract ALL F-formulas FIRST** (including F(phi) if phi itself is an F-formula):
   - Each `F(sigma)` extraction: `L |- bot` becomes `L \ {F(sigma)} |- G(neg sigma)`
   - Accumulate: `L_core |- G(neg s1) or G(neg s2) or ... or bot`

2. **Extract phi LAST**:
   - After all F-formulas: `L_core |- disjunction` where `L_core ⊆ {phi} union temporal_box_seed M`
   - Extract phi: `L_final |- neg(phi) or disjunction` where `L_final ⊆ temporal_box_seed M`

3. **G-lift the whole disjunction**:
   - Since `L_final ⊆ temporal_box_seed M`, all elements are G-liftable
   - `G(neg(phi) or G(neg s1) or ...) in M`

4. **Apply T-axiom and MCS disjunction**:
   - `G(neg(phi)) or G(neg s1) or ... in M`
   - Some disjunct must be in M
   - Each contradicts the corresponding F-formula

**Why This Works**: phi is treated uniformly. We never need to case-split on `G(phi) in M`.

---

## Induction Measure Analysis

### Option A: Count of F-formulas (excluding phi)

```lean
def countFUnresolved (M : Set Formula) (phi : Formula) (L : List Formula) : Nat :=
  L.countP (fun x => x.is_some_future && decide (x in F_unresolved_theory M) && decide (x != phi.some_future))
```

**Pros**: Direct count of what we're extracting
**Cons**: phi extraction handled separately at the end

### Option B: Count of non-G-liftable formulas (RECOMMENDED)

```lean
def countNonLiftable (M : Set Formula) (L : List Formula) : Nat :=
  L.countP (fun x => decide (x not in temporal_box_seed M))
```

**Pros**:
- Includes both F-formulas AND phi in a uniform measure
- Base case is exactly when `L ⊆ temporal_box_seed M`
- Matches the proof structure perfectly

**Cons**: None significant

### Option C: Combined measure (lexicographic)

```lean
def measure (M : Set Formula) (phi : Formula) (L : List Formula) : Nat × Nat :=
  (L.countP isF, if phi in L then 1 else 0)
```

**Analysis**: Unnecessarily complex. Option B suffices.

**Recommendation**: Use Option B (`countNonLiftable`) as the induction measure.

---

## Extraction Order Strategy

### The Invariant to Maintain

During induction, maintain:
```
(L, accumulated_disjunction) where:
- L ⊆ f_preserving_seed M phi
- L |- accumulated_disjunction
- accumulated_disjunction = G(neg s1) or ... or G(neg sk) or target
```

### Base Case (count = 0)

When `countNonLiftable M L = 0`:
- `L ⊆ temporal_box_seed M`
- All elements are G-liftable
- G-lift the accumulated disjunction
- Apply T-axiom to nested G's
- Use MCS disjunction property to get witness
- Derive contradiction with corresponding F-formula

### Inductive Case (count > 0)

When `countNonLiftable M L > 0`:

1. **Find a non-liftable element x in L**:
   - If `x in F_unresolved_theory M`: extract as F-formula
   - If `x = phi`: extract to get `neg(phi)` in disjunction
   - Otherwise: impossible (all other elements are G-liftable)

2. **Extract x**:
   - `L |- target` becomes `L \ {x} |- x.neg or target`
   - For F(sigma): `x.neg = G(neg sigma)`
   - For phi: `x.neg = neg(phi)`

3. **Update accumulated disjunction**:
   - New disjunction includes the extracted negation

4. **Recurse**:
   - `countNonLiftable M (L \ {x}) < countNonLiftable M L`

### Order of Extraction Within Inductive Case

**Does order matter?** Not fundamentally, but:

- Extract F-formulas before phi for cleaner nested G structure
- Each F-formula extraction adds `G(neg sigma)` to disjunction
- phi extraction (if needed) adds `neg(phi)` to disjunction
- Final G-lift converts `neg(phi)` to `G(neg phi)` automatically

---

## G-Lifting Analysis

### The Final G-Lift Step

After full extraction:
```lean
L_final ⊆ temporal_box_seed M
L_final |- (G(neg s1) or G(neg s2) or ... or neg(phi))
```

**G-lift application**:
```lean
G((G(neg s1) or G(neg s2) or ... or neg(phi))) in M
```

**T-axiom simplification**:
Since `G(G(X)) -> G(X)` (4-axiom + T), we can "flatten":
```lean
G(neg s1) or G(neg s2) or ... or G(neg phi) in M
```

**Wait -- is this valid?**

Actually, we need to be more careful. `G(A or B)` does NOT imply `G(A) or G(B)`.

**Correct Analysis**:

We have `G(D) in M` where `D = G(neg s1) or ... or neg(phi)`.

By T-axiom: `G(D) -> D`, so `D in M`.

So `G(neg s1) or ... or neg(phi) in M`.

By MCS disjunction: at least one disjunct is in M.

**Case 1**: `G(neg si) in M` for some i
- Contradicts `F(si) in M` (from F_unresolved_theory definition)

**Case 2**: `neg(phi) in M`
- Then `phi not in M`
- But `F(phi) in M` (given hypothesis)
- By T-axiom on `G(neg(phi))`: wait, we have `neg(phi)`, not `G(neg(phi))`

**Problem!** We only get `neg(phi)` in M, not `G(neg(phi))`. This doesn't directly contradict `F(phi) in M`.

### Fixing the Final Step

The issue: `neg(phi) in M` and `F(phi) in M` are NOT contradictory!
- `neg(phi)` means phi is false NOW
- `F(phi)` means phi will be true EVENTUALLY

**Solution**: We need to G-lift `neg(phi)` before it joins the disjunction.

**Revised Strategy**:

1. Extract all F-formulas: `L_no_F |- G(neg s1) or ... or G(neg sk) or bot`
2. This simplifies to: `L_no_F |- G(neg s1) or ... or G(neg sk)`
3. If `L_no_F ⊆ temporal_box_seed M`, we're done (G-lift and apply T)
4. If phi in L_no_F:
   - Extract phi: `L_final |- phi -> (G(neg s1) or ...)`
   - G-lift: `G(phi -> (G(neg s1) or ...)) in M`
   - By K: `G(phi) -> G(G(neg s1) or ...) in M`
   - By T inside: `G(phi) -> (G(neg s1) or ...) in M`

Now we're back to the original problem: we need `G(phi) in M` to apply modus ponens.

**Alternative**: Don't extract phi specially. Include it in the F-formula accumulation.

If `F(phi) in M` and `phi not in M`, then `F(phi) in F_unresolved_theory M`.

So phi.some_future can be extracted just like any other F-formula!

**This is the key insight**: Treat `F(phi)` as an element of `F_unresolved_theory M` (which it is, since `phi not in M` holds in the interesting case).

---

## Recommended Strong Induction Structure

### Main Theorem Statement

```lean
theorem f_preserving_seed_consistent (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_F : Formula.some_future phi ∈ M) :
    SetConsistent (f_preserving_seed M phi) := by
```

### Proof Outline (80-120 lines)

```lean
  intro L h_L_sub ⟨d⟩

  -- Define measure: count of F-formulas in L from F_unresolved_theory
  let count := L.countP (fun x => decide (x ∈ F_unresolved_theory M))

  -- Strong induction on count
  revert L h_L_sub d
  refine Nat.strong_induction_on count ?_
  intro n ih L h_L_sub h_count d

  -- Base case: no F-formulas from F_unresolved_theory
  by_cases h_zero : n = 0
  · -- All elements in {phi} ∪ temporal_box_seed M
    -- Extract phi to get L_no_phi |- neg(phi)
    -- G-lift to get G(neg(phi)) ∈ M
    -- Contradict with F(phi) ∈ M
    -- This is exactly temporal_theory_witness_consistent!
    have h_L_sub' : ∀ x ∈ L, x ∈ {phi} ∪ temporal_box_seed M := by
      intro x hx
      have hx_seed := h_L_sub x hx
      -- If count = 0 and x ∈ L, then x ∉ F_unresolved_theory M
      -- So x ∈ {phi} ∪ temporal_box_seed M
      ...
    exact temporal_theory_witness_consistent M h_mcs phi h_F L h_L_sub' ⟨d⟩

  · -- Inductive case: extract one F(sigma)
    obtain ⟨k, rfl⟩ := Nat.exists_eq_succ_of_ne_zero h_zero
    -- Find F(sigma) ∈ L ∩ F_unresolved_theory M
    have ⟨F_sigma, hF_in_L, hF_unres⟩ := ... (from countP > 0)
    obtain ⟨sigma, rfl, h_Fsigma_M, h_sigma_not_M⟩ := hF_unres

    -- Extract F(sigma)
    let L_no_F := L.filter (· ≠ F_sigma)
    have d_G_neg : L_no_F ⊢ G(neg sigma) := deduction_theorem ...

    -- Show count decreases
    have h_count' : L_no_F.countP (...) < n.succ := by
      apply countP_filter_ne_lt
      ...

    -- Key: L_no_F still ⊆ f_preserving_seed M phi
    have h_L_no_F_sub : ∀ x ∈ L_no_F, x ∈ f_preserving_seed M phi := ...

    -- If L_no_F is inconsistent, apply IH
    by_cases h_cons : SetConsistent (fun x => x ∈ L_no_F)

    · -- L_no_F consistent: derive G(neg sigma) ∈ M via derivation closure
      -- Wait, this doesn't work directly because L_no_F ⊢ G(neg sigma), not bot
      -- Need different approach
      ...

    · -- L_no_F inconsistent: apply IH
      ...
```

**Issue Identified**: The induction doesn't quite work because extraction changes the goal from `bot` to `G(neg sigma)`.

### Revised Approach: Track Accumulated Disjunction

```lean
-- Helper lemma that tracks the accumulated disjunction
lemma f_extraction_induction (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_F : Formula.some_future phi ∈ M) :
    ∀ (n : Nat) (L : List Formula) (accum : List Formula),
      (∀ x ∈ L, x ∈ f_preserving_seed M phi) →
      (∀ g ∈ accum, ∃ σ, g = Formula.all_future (Formula.neg σ) ∧
                         Formula.some_future σ ∈ M ∧ σ ∉ M) →
      L.countP (· ∈ F_unresolved_theory M) = n →
      (L ⊢ accum.foldr Formula.or Formula.bot) →
      False := by
  intro n
  induction n using Nat.strong_induction_on with
  | ind n ih =>
    intro L accum h_L_sub h_accum h_count d

    by_cases h_zero : n = 0

    · -- Base case: L ⊆ {phi} ∪ temporal_box_seed M
      -- Have L ⊢ (G(neg σ₁) ∨ ... ∨ ⊥)
      -- Extract phi to get: L_no_phi ⊢ neg(phi) ∨ (G(neg σ₁) ∨ ...)
      -- G-lift: G(neg(phi) ∨ G(neg σ₁) ∨ ...) ∈ M
      -- T-axiom: neg(phi) ∨ G(neg σ₁) ∨ ... ∈ M
      -- Wait, this gives neg(phi), not G(neg(phi))

      -- Actually, need to G-lift BEFORE adding neg(phi):
      -- L_no_phi ⊆ temporal_box_seed M
      -- L_no_phi ⊢ phi → (G(neg σ₁) ∨ ...)
      -- G-lift: G(phi → ...) ∈ M
      -- This still has the G(phi) problem!

      -- Alternative: don't use temporal_theory_witness_consistent
      -- Instead, handle phi like an F-formula
      sorry

    · -- Inductive case
      sorry
```

**Conclusion from Analysis**: The proof structure needs more careful handling. The `temporal_theory_witness_consistent` base case works when there are NO F-formulas, but the inductive case needs to track a disjunction of G-formulas properly.

---

## Literature References

### Modal Logic Completeness Techniques

1. **Canonical Models for Normal Logics** - Imperial College notes on canonical model construction
   - Key insight: completeness via canonical models requires showing the canonical model belongs to the target frame class
   - [PDF](https://www.doc.ic.ac.uk/~mjs/teaching/ModalTemporal499/CanonicalNormal_499_v0809_2up.pdf)

2. **Henkin-Style Completeness for S5** - PhilArchive paper
   - Demonstrates strong induction in Truth Lemma proofs
   - [PhilArchive](https://philarchive.org/archive/BENAHC-2)

3. **Completeness in Modal Logic** - Chicago REU paper
   - Shows consistency preservation via structural induction on proof trees
   - [PDF](https://math.uchicago.edu/~may/REU2020/REUPapers/Hebert.pdf)

### Temporal Logic Specific

4. **Temporal Logic - Stanford Encyclopedia**
   - F-preservation and omega-chain constructions in canonical models
   - Notes that not every normal logic has canonical model completeness
   - [SEP](https://plato.stanford.edu/entries/logic-temporal/)

5. **Verification of Concurrent Programs: Temporal Proof Principles** - Manna & Pnueli
   - Eventuality properties and computational induction
   - [Springer](https://link.springer.com/chapter/10.1007/BFb0025785)

### Mathlib References

6. **`Nat.strong_induction_on`** - Mathlib.Data.Nat.Init
   - `{p : Nat -> Prop} (n : Nat) (h : forall n, (forall m < n, p m) -> p n) : p n`

7. **`List.countP_filter`** - Init.Data.List.Count
   - `countP p (filter q l) = countP (fun a => p a && q a) l`

8. **`List.countP_erase`** - Mathlib.Data.List.Count
   - `countP p (l.erase a) = countP p l - if a ∈ l ∧ p a then 1 else 0`

---

## Confidence Level

**Overall**: Medium

**High Confidence**:
- The current proof structure is fundamentally flawed
- Strong induction is the correct approach
- `countNonLiftable` or `countFUnresolved` are good measures
- The final contradiction via MCS disjunction is sound

**Medium Confidence**:
- The exact extraction order (F-formulas vs phi)
- Whether `temporal_theory_witness_consistent` can serve as base case directly
- The accumulated disjunction tracking mechanism

**Low Confidence**:
- Whether the proof can be done in 80-120 lines (might need more infrastructure)
- The exact helper lemmas needed for `countP` manipulation

---

## Recommendations for Implementation

### Phase 1: Define Infrastructure

1. Add helper lemma for `countP` decrease:
```lean
theorem countP_filter_ne_lt {α} [DecidableEq α] {p : α → Bool} {L : List α} {x : α}
    (hx : x ∈ L) (hp : p x = true) :
    List.countP p (L.filter (· ≠ x)) < List.countP p L
```

2. Define the count measure:
```lean
def countFInL (M : Set Formula) (L : List Formula) : Nat :=
  L.countP (fun x => decide (x ∈ F_unresolved_theory M))
```

### Phase 2: Prove Main Lemma with Disjunction Tracking

Start with a helper that extracts one F-formula and builds up the disjunction:

```lean
lemma extract_F_formula (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (L : List Formula) (sigma : Formula)
    (h_F_in_L : Formula.some_future sigma ∈ L)
    (h_F_unres : Formula.some_future sigma ∈ F_unresolved_theory M)
    (d : L ⊢ target) :
    (L.filter (· ≠ Formula.some_future sigma)) ⊢
      (Formula.all_future (Formula.neg sigma)).or target
```

### Phase 3: Delete Old Proof, Insert New

Once the helper infrastructure is in place:
1. Delete lines 1384-2101 (current broken proof)
2. Insert the new strong induction proof
3. Verify downstream theorems compile

### What NOT To Do

1. **Don't try to fix the neg(G(phi)) case** in the current proof structure
2. **Don't extract phi specially** - treat it like any other formula in the induction
3. **Don't assume G distributes over disjunction** - it doesn't!
4. **Don't use the vacuous implication route** - it doesn't give us what we need

---

## Summary

The `f_preserving_seed_consistent` proof requires complete restructuring. The key insight is:

**Treat phi uniformly with F-formulas**. When `F(phi) ∈ M` and `phi ∉ M` (the interesting case), `F(phi) ∈ F_unresolved_theory M`, so it can be extracted just like any other F-formula.

The induction should:
1. Count F-formulas from `F_unresolved_theory M` in the context
2. Extract them one by one, accumulating a disjunction of G-negations
3. When count = 0 (base case), all remaining formulas are G-liftable
4. G-lift the accumulated disjunction
5. Use MCS disjunction + T-axiom to get a witness
6. Contradict with the corresponding F-formula in M

This avoids the `G(phi) ∈ M` vs `G(phi) ∉ M` case split that breaks the current proof.
