# Research Report: F-Preserving Seed Construction Analysis

**Task**: 69 - close_z_chain_forward_f
**Date**: 2026-03-30
**Session**: sess_teammate_a
**Mode**: Teammate A - Seed Construction Analysis
**Focus**: How the seed construction should differ to make strong induction proofs work

---

## Key Findings

1. **The current proof structure has a fundamental asymmetry**: Extracting `phi` separately from F-formulas creates an implication `phi -> G(neg psi)` that cannot be resolved when `G(phi) not in M`. The G-lift works only when `G(phi) in M`, creating an unfixable case split.

2. **The solution requires uniform treatment**: All extractable formulas (both `phi` AND F-formulas) must be treated uniformly in a single strong induction, building a disjunction accumulator that reaches a pure `temporal_box_seed` context.

3. **The seed definition itself is correct**: The issue is not in `f_preserving_seed` but in the PROOF STRATEGY. The seed `{phi} U temporal_box_seed M U F_unresolved_theory M` is the right seed; the proof needs restructuring.

4. **Task semantics matters**: In this system, F(phi) means "phi holds at some future point in the current task" (not standard LTL). The modal S5 component means accessibility is reflexive/transitive/symmetric within tasks. This affects how witnesses are constructed.

---

## Seed Construction Analysis

### Current Seed Definition (Correct)

```lean
def f_preserving_seed (M : Set Formula) (phi : Formula) : Set Formula :=
  {phi} ∪ temporal_box_seed M ∪ F_unresolved_theory M

where:
- temporal_box_seed M = G_theory M ∪ box_theory M
- G_theory M = {G(a) | G(a) ∈ M}
- box_theory M = {Box(a) | Box(a) ∈ M} ∪ {neg(Box(a)) | Box(a) ∉ M}
- F_unresolved_theory M = {F(psi) | F(psi) ∈ M ∧ psi ∉ M}
```

### Why the Seed Definition is Correct

The seed correctly includes:
1. **phi**: The witness formula we want in the extended MCS
2. **G_theory M**: All G-formulas from M (necessary for temporal theory agreement)
3. **box_theory M**: All modal formulas (necessary for box-class agreement)
4. **F_unresolved_theory M**: All unresolved F-obligations (prevents Lindenbaum from adding their negations)

The inclusion of `F_unresolved_theory M` is the key innovation: it forces any MCS extending the seed to contain these F-formulas, preventing Lindenbaum from adding `G(neg psi) = neg(F(psi))` for any unresolved F(psi).

### Why Treating Phi Separately Breaks the Proof

The current proof at lines 1372-2101 follows this pattern:
1. Assume L ⊆ f_preserving_seed with L ⊢ bot
2. Extract F(psi) from L: get L_no_F ⊢ G(neg psi)
3. Extract phi from L_no_F: get L_no_phi ⊢ phi -> G(neg psi)
4. G-lift: G(phi -> G(neg psi)) ∈ M
5. Apply K-axiom: G(phi) -> G(G(neg psi)) ∈ M
6. **Case split**: G(phi) ∈ M or neg(G(phi)) ∈ M

When `G(phi) ∈ M`:
- Modus ponens gives G(G(neg psi)) ∈ M
- T-axiom gives G(neg psi) ∈ M
- Contradiction with F(psi) ∈ M

When `neg(G(phi)) ∈ M` (i.e., F(neg phi) ∈ M):
- G(phi) ∉ M, so the implication is vacuously satisfied
- Cannot derive G(neg psi) ∈ M
- **No contradiction available**

The proof constructs `[F(psi), phi, G(phi -> G(neg psi))] ⊢ bot`, but this proves the seed IS inconsistent under these assumptions, contradicting the goal of proving consistency.

---

## Alternative Constructions Considered

### Alternative 1: Include G-negations of F-formulas

**Idea**: Include `G(neg psi)` for all F(psi) ∈ F_unresolved_theory in the seed.

**Problems**:
- This would make the seed immediately inconsistent: F(psi) and G(neg psi) = neg(F(psi)) cannot both be in a consistent set.
- **Rejected**: Fundamentally unsound.

### Alternative 2: Treat phi as F(phi_0) for base case

**Idea**: Unify phi with F-formulas by considering it as a special resolved eventuality.

**Problems**:
- phi is the witness formula selected because F(phi) ∈ M. It's not itself an F-formula.
- phi ∈ f_preserving_seed is correct; phi is NOT in F_unresolved_theory (by definition, F_unresolved has F(psi) with psi ∉ M, but phi is what we're trying to put in the witness).
- **Rejected**: Type mismatch - phi and F(phi) are different formulas.

### Alternative 3: Include neg(F(psi)) = G(neg psi) for certain formulas

**Idea**: For each F(psi) ∈ M where we can prove F(psi) will be resolved, include the resolution.

**Problems**:
- We don't know which F-formulas will be resolved in the final witness W.
- The Lindenbaum construction determines this non-deterministically.
- **Rejected**: Cannot determine ahead of time which resolutions to force.

### Alternative 4: Uniform extraction with disjunction accumulation (RECOMMENDED)

**Idea**: Extract ALL non-G-liftable elements (phi AND all F-formulas) uniformly, building a disjunction.

**How it works**:
1. Define count measure: `countFUnresolved M phi L = L.countP (x => x ∈ F_unresolved_theory M)`
2. Strong induction on count
3. Base case (count = 0): L ⊆ {phi} ∪ temporal_box_seed M, use existing `temporal_theory_witness_consistent`
4. Inductive case: extract one F(sigma), apply deduction theorem, add G(neg sigma) to disjunction, recurse
5. Final step: pure temporal_box_seed context derives disjunction of G(neg sigma_i) ∨ neg(phi)
6. G-lift entire disjunction
7. By `G_of_disjunction_in_mcs_elim`: some G(neg sigma_i) ∈ M or G(neg phi) ∈ M
8. Contradiction with respective F-formula

**Key insight**: This avoids the case split on `G(phi) ∈ M` by NOT extracting phi into an implication. Instead, phi becomes part of the final disjunction like all other formulas.

---

## Recommended Approach

### Step 1: Define the Induction Measure

```lean
private def countFUnresolved (M : Set Formula) (L : List Formula) : Nat :=
  L.countP (fun x => x.is_some_future ∧ ∃ psi, x = Formula.some_future psi ∧
                     Formula.some_future psi ∈ M ∧ psi ∉ M)
```

Note: phi is NOT counted because phi is not an F-formula (it's the inner formula of F(phi)).

### Step 2: Main Induction Structure

```lean
theorem f_preserving_seed_consistent (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_F : Formula.some_future phi ∈ M) :
    SetConsistent (f_preserving_seed M phi) := by
  intro L h_L_sub ⟨d⟩
  -- Let n = countFUnresolved M L
  let n := countFUnresolved M L
  -- Strong induction on n
  induction n using Nat.strong_induction_on generalizing L with
  | ind n ih =>
    by_cases h_zero : countFUnresolved M L = 0
    · -- Base case: no F-formulas from F_unresolved_theory in L
      -- L ⊆ {phi} ∪ temporal_box_seed M
      -- Apply temporal_theory_witness_consistent
      ...
    · -- Inductive case: extract one F(sigma), recurse
      ...
```

### Step 3: Base Case (count = 0)

When `countFUnresolved M L = 0`:
- All F-formulas in L are either not in F_unresolved_theory or L has none
- L ⊆ {phi} ∪ temporal_box_seed M
- Apply `temporal_theory_witness_consistent M h_mcs phi h_F`
- This theorem already handles the phi extraction + G-lift correctly

### Step 4: Inductive Case with Disjunction Accumulation

The critical insight is that each F-extraction changes the target:
- `L ⊢ bot` becomes `L \ {F(sigma)} ⊢ G(neg sigma)` (not bot!)
- Need to accumulate: `L_core ⊢ G(neg sigma_1) ∨ G(neg sigma_2) ∨ ...`

Alternative formulation using target tracking:

```lean
lemma F_extraction_accumulation (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_F : Formula.some_future phi ∈ M) :
    ∀ (n : Nat) (L : List Formula) (target : Formula),
      (∀ x ∈ L, x ∈ f_preserving_seed M phi) →
      countFUnresolved M L = n →
      L ⊢ target →
      ∃ (L_core : List Formula) (disjuncts : List Formula),
        (∀ x ∈ L_core, x ∈ {phi} ∪ temporal_box_seed M) ∧
        (∀ d ∈ disjuncts, ∃ sigma, d = Formula.all_future (Formula.neg sigma) ∧
                          Formula.some_future sigma ∈ F_unresolved_theory M) ∧
        L_core ⊢ (disjuncts.foldr Formula.or target)
```

### Step 5: Final Contradiction

After full extraction with `target = bot`:
1. `L_core ⊆ {phi} ∪ temporal_box_seed M`
2. `L_core ⊢ G(neg sigma_1) ∨ ... ∨ G(neg sigma_k)` (or-chain ending in bot = pure disjunction)

Now extract phi:
3. `L_core_no_phi ⊢ neg(phi) ∨ G(neg sigma_1) ∨ ... ∨ G(neg sigma_k)`
4. `L_core_no_phi ⊆ temporal_box_seed M`
5. G-lift: `G(neg(phi) ∨ G(neg sigma_1) ∨ ...) ∈ M`

By modal distribution (G over disjunction via repeated K-axiom application):
6. `G(neg phi) ∨ G(G(neg sigma_1)) ∨ ... ∈ M`

By T-axiom applied to each `G(G(neg sigma_i))`:
7. `G(neg phi) ∨ G(neg sigma_1) ∨ ... ∈ M`

By `G_of_disjunction_in_mcs_elim`:
8. Either `G(neg phi) ∈ M` or some `G(neg sigma_i) ∈ M`

Contradiction:
- If `G(neg phi) ∈ M`: contradicts `F(phi) ∈ M` via `some_future_excludes_all_future_neg`
- If `G(neg sigma_i) ∈ M`: contradicts `F(sigma_i) ∈ M` (from F_unresolved_theory)

---

## Literature References

### Modal Logic Completeness

- **Blackburn, de Rijke, Venema "Modal Logic" (2001)**: Canonical model construction uses maximal consistent sets. Completeness proofs for temporal logic often require explicit enumeration/fairness arguments when the standard canonical model doesn't work directly.
  [Source](https://modal-logic.gabrieluzquiano.org/completeness)

- **Yde Venema "Temporal Logic" (Handbook chapter)**: "Proofs of completeness via canonical models do not always work... many temporal logics are examples of this."
  [Source](https://staff.science.uva.nl/y.venema/papers/TempLog.pdf)

### Fischer-Ladner Closure

- **Fischer & Ladner (1979)**: PDL satisfiability is decidable; consistent formulas have models bounded by Fischer-Ladner closure size. The closure concept is used for finite model constructions.
  [Source](https://link.springer.com/chapter/10.1007/3-540-08921-7_88)

- **Kozen "Elementary Completeness Proof for PDL"**: Uses ConAt(A) - the set of consistent atoms in the Boolean algebra generated by Fischer-Ladner closure.
  [Source](https://www.cs.cornell.edu/~kozen/Papers/ElemPDL.pdf)

### LTL Completeness

- **Wikipedia on LTL**: The "eventually" operator F is a key temporal modality; eventuality automata accept when all goals are achieved infinitely often.
  [Source](https://en.wikipedia.org/wiki/Linear_temporal_logic)

- **Rosu "Finite-Trace LTL Coinductive Completeness"**: Completeness for finite-trace LTL uses coinduction; deduction theorems for LTL allow conversion between consequence and provability.
  [Source](https://formal-systems-laboratory.github.io/fsl/papers/2016/rosu-2016-rv/rosu-2016-rv.pdf)

### Task Semantics (Project-Specific)

The ProofChecker system uses task semantics where:
- Modal operators (Box/Diamond) quantify over "tasks" (modal equivalence classes)
- Temporal operators (G/F/H/P) flow along individual tasks
- F(phi) = "phi at some future point in current task"
- This differs from standard branching-time models

---

## Confidence Level

**High confidence** on:
1. The seed definition is correct; the proof strategy is the issue
2. Uniform extraction with disjunction accumulation is the right approach
3. Strong induction on F-formula count is the correct termination measure
4. The final contradiction via `G_of_disjunction_in_mcs_elim` and `some_future_excludes_all_future_neg` will work

**Medium confidence** on:
1. The exact modal distribution step (G over disjunction) may need helper lemmas not currently in the codebase
2. The interleaving of phi extraction with F-formula extraction in the final step

**Low confidence** on:
1. Any approach that avoids the strong induction restructuring
2. The current 700-line proof being salvageable with incremental fixes

---

## What NOT To Do

1. **Don't try to fix the `neg(G(phi))` case in the current proof** - this case is structurally unfixable with the current extraction order

2. **Don't add formulas to the seed** - the seed is correct; adding more (like G-negations) would make it inconsistent

3. **Don't treat phi as an F-formula** - phi and F(phi) are fundamentally different; phi is the witness content, F(phi) is the obligation

4. **Don't skip the disjunction accumulation** - direct contradiction (as attempted in the current proof) requires case splits that cannot all close

---

## Summary

The seed construction `{phi} ∪ temporal_box_seed M ∪ F_unresolved_theory M` is mathematically correct. The proof failure stems from extracting phi separately from F-formulas, creating an implication that leads to an unfixable case split.

The fix is to restructure the proof using strong induction on F-formula count, extracting ALL non-G-liftable elements uniformly into a disjunction, then G-lifting the entire disjunction and using existing helper lemmas (`G_of_disjunction_in_mcs_elim`, `some_future_excludes_all_future_neg`) for the final contradiction.

Estimated implementation: 80-120 lines, replacing the current 700+ line proof.
