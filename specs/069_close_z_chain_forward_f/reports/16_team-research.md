# Research Report: Task #69 - F-Preserving Seed Construction & Strong Induction Strategy

**Task**: 69 - close_z_chain_forward_f
**Date**: 2026-03-30
**Mode**: Team Research (2 teammates)
**Session**: sess_1774908101_88f875
**Focus**: Study the blocker in f_preserving_seed_consistent; how the seed construction should differ or how strong induction proofs should go; consult literature on F-preserving temporal witness constructions

---

## Summary

Both teammates confirm the seed construction is mathematically correct — the issue lies entirely in the proof strategy. The recommended approach is strong induction with disjunction accumulation. However, a **critical unresolved subtlety** was identified: extracting phi produces `neg(phi)`, not `G(neg phi)`, and `neg(phi) ∈ M` does NOT contradict `F(phi) ∈ M` (phi false now is compatible with phi true eventually). Understanding how the existing `temporal_theory_witness_consistent` and `G_lift_from_context` handle this case is essential for designing the correct induction.

---

## Key Findings

### 1. Seed Definition is Correct (HIGH confidence, both agree)

```lean
def f_preserving_seed (M : Set Formula) (phi : Formula) : Set Formula :=
  {phi} ∪ temporal_box_seed M ∪ F_unresolved_theory M
```

Key observations:
- `temporal_box_seed M ⊆ M` and `F_unresolved_theory M ⊆ M`
- Only `phi` may not be in M
- No modification to the seed is needed
- Alternative seed constructions (adding G-negations, treating phi as F-formula, removing phi) are all either unsound or lose the witness property

### 2. Current Proof is Fundamentally Flawed (HIGH confidence, both agree)

The 700-line proof has an irreparable asymmetry at lines 2068/2073:
- Extracting F(psi) then phi gives implication `phi → G(neg psi)`
- G-lifting + K-axiom gives `G(phi) → G(G(neg psi)) ∈ M`
- When `G(phi) ∉ M` (i.e., `F(neg phi) ∈ M`): modus ponens fails
- No workaround exists within this extraction order

### 3. G Does NOT Distribute Over Disjunction (HIGH confidence, both agree)

`G(A ∨ B) → G(A) ∨ G(B)` is **invalid** in modal/temporal logic. This rules out naive approaches.

What IS valid:
- T-axiom: `G(X) → X` (so `G(D) ∈ M` implies `D ∈ M`)
- K-axiom: `G(A → B) → (G(A) → G(B))`
- MCS disjunction: if `A ∨ B ∈ M` (MCS), then `A ∈ M` or `B ∈ M`

### 4. Strong Induction is the Correct Framework (HIGH confidence, both agree)

Induction measure: count of formulas from `F_unresolved_theory M` in context L.

---

## Synthesis: The Critical Unresolved Question

### The `neg(phi)` vs `G(neg phi)` Problem

**Teammate A** proposes uniform extraction with disjunction accumulation, ending with G-lift and T-axiom to get some disjunct in M, then contradiction.

**Teammate B** identifies a critical flaw in this plan:

After extracting all F-formulas AND phi from L:
1. `L_final ⊆ temporal_box_seed M`, `L_final ⊢ neg(phi) ∨ G(neg s1) ∨ ...`
2. G-lift: `G(neg(phi) ∨ G(neg s1) ∨ ...) ∈ M`
3. T-axiom: `neg(phi) ∨ G(neg s1) ∨ ... ∈ M`
4. MCS picks one disjunct

If `G(neg si) ∈ M`: contradicts `F(si) ∈ M` ✓
If `neg(phi) ∈ M`: does NOT contradict `F(phi) ∈ M` ✗

Because `neg(phi)` means "phi false now" while `F(phi)` means "phi true eventually" — these are compatible!

We need `G(neg phi) ∈ M` (= `neg(F(phi)) ∈ M`) for contradiction, but the extraction only gives `neg(phi)`.

### How the Base Case Handles This

The existing `temporal_theory_witness_consistent` successfully proves `{phi} ∪ temporal_box_seed M` is consistent. It handles the phi case via `G_lift_from_context` (line ~1066):

When `L ⊆ {phi} ∪ temporal_box_seed M` and `L ⊢ bot`:
1. Extract phi: `L \ {phi} ⊢ neg(phi)` where `L \ {phi} ⊆ temporal_box_seed M`
2. **G-lift from context**: Since ALL premises are from temporal_box_seed (G-closed), the derivation `L \ {phi} ⊢ neg(phi)` lifts to `G(neg phi) ∈ M`
3. `G(neg phi) = neg(F(phi))`, contradicting `F(phi) ∈ M` ✓

The G-lift works because `temporal_box_seed M` only contains G-theory and box-theory formulas, which form a "G-liftable" context. This is the key mechanism.

### Implications for the Inductive Case

The induction must ensure that after extracting all F-formulas, we reduce to the base case: `L_core ⊆ {phi} ∪ temporal_box_seed M` with `L_core ⊢ bot`.

**This means we need `⊢ bot` as the derivation target at the base case**, not `⊢ disjunction`. The G_lift_from_context converts `L_core \ {phi} ⊢ neg(phi)` (from L_core ⊢ bot) to `G(neg phi) ∈ M` — this works because it G-lifts the ENTIRE derivation from the temporal_box_seed context, not just the conclusion.

### Two Viable Approaches

#### Approach A: Direct Reduction to Inconsistency

Instead of building a disjunction, try to show that extracting F-formulas preserves inconsistency:

Given `L ⊢ bot` with `F(sigma) ∈ L`:
- By deduction theorem: `L \ {F(sigma)} ⊢ neg(F(sigma))`
- `neg(F(sigma)) = G(neg sigma)` (temporal duality)
- `G(neg sigma) ∈ G_theory M` if `G(neg sigma) ∈ M`...

But we DON'T know `G(neg sigma) ∈ M`! That's what we're trying to prove leads to contradiction.

**Issue**: Extracting F(sigma) changes the goal from bot to G(neg sigma). We can't simply maintain `⊢ bot`.

**Possible fix**: After extracting F(sigma) and getting `L' ⊢ G(neg sigma)`:
- Add `F(sigma)` back via weakening: `L' ∪ {F(sigma)} ⊢ G(neg sigma)`
- `F(sigma)` and `G(neg sigma) = neg(F(sigma))` together give: `L' ∪ {F(sigma)} ⊢ bot`
- But this gives us L again — circular!

So direct reduction to inconsistency doesn't work naively.

#### Approach B: Disjunction Accumulation WITH Base Case Delegation

Track a disjunction accumulator, but at the base case, delegate to a modified version of `temporal_theory_witness_consistent` that handles the accumulated disjunction:

```lean
lemma temporal_theory_witness_consistent_general
    (M : Set Formula) (h_mcs : SetMaximalConsistent M) (phi : Formula)
    (h_F : Formula.some_future phi ∈ M)
    (L : List Formula) (h_sub : ∀ x ∈ L, x ∈ {phi} ∪ temporal_box_seed M)
    (accum : List Formula)
    (h_accum : ∀ g ∈ accum, ∃ σ, g = Formula.neg (Formula.some_future σ) ∧
                                  Formula.some_future σ ∈ M)
    (d : DerivationTree L (accum.foldr Formula.or Formula.bot)) : False
```

This generalized base case handles the accumulated G-negations:
1. Extract phi from L: get `L \ {phi} ⊢ neg(phi) ∨ accum.foldr (∨) bot`
2. L \ {phi} ⊆ temporal_box_seed M
3. G-lift the DERIVATION: get `G(neg(phi) ∨ G(neg s1) ∨ ...) ∈ M`
4. T-axiom: `neg(phi) ∨ G(neg s1) ∨ ... ∈ M`

**WAIT** — same problem: neg(phi) doesn't give G(neg phi).

Unless the G-lift gives us something stronger. If `L \ {phi} ⊢ X`, G-lift gives `G(X) ∈ M`, not `X ∈ M`. So:

G-lift gives `G(neg(phi) ∨ G(neg s1) ∨ ...) ∈ M`.

Then T-axiom: `neg(phi) ∨ G(neg s1) ∨ ... ∈ M`.

The neg(phi) disjunct is NOT wrapped in G. So if M picks neg(phi), no contradiction.

**HOWEVER**: We have `G(neg(phi) ∨ ...) ∈ M`. This means `neg(phi) ∨ ... ∈ M` AND it holds at ALL future times.

Can we use the G differently? G(D) means D holds at all future times. If D is a disjunction, at least one disjunct holds at each time, but possibly different disjuncts at different times.

For our purposes, `G(neg(phi) ∨ G(neg s1) ∨ ...) ∈ M` gives us, at the current time: `neg(phi) ∨ G(neg s1) ∨ ... ∈ M`. That's all we get via T.

#### Approach C: Separate phi Extraction BEFORE the Induction

**New insight from synthesis**: Handle the phi case OUTSIDE the F-formula induction.

Two master cases:
1. **phi ∈ M**: Then `f_preserving_seed M phi ⊆ M`. Any finite L ⊆ M with L ⊢ bot would put bot ∈ M (derivation closure), contradicting M's consistency. Done immediately.

2. **phi ∉ M**: Then phi is the ONLY element in the seed not in M.
   Given L ⊆ f_preserving_seed with L ⊢ bot:
   - If phi ∉ L: L ⊆ M. Same argument as case 1. ✓
   - If phi ∈ L: L \ {phi} ⊆ M. By deduction theorem: L \ {phi} ⊢ neg(phi).
     Since L \ {phi} ⊆ M: neg(phi) ∈ M (derivation closure).
     But phi ∉ M is already given, so neg(phi) ∈ M is consistent (MCS).

     **This doesn't give contradiction!**

Wait... but `temporal_theory_witness_consistent` DOES handle this case. It uses G-lift. The key is that L \ {phi} contains ONLY G-theory and box-theory and F_unresolved_theory formulas. The G-lift works on the G-theory + box-theory part.

Hmm but F_unresolved_theory formulas are F-formulas (like F(sigma)). These are NOT G-liftable. So if L \ {phi} contains F-formulas, the G-lift can't apply.

**THIS IS WHY THE BASE CASE REQUIRES NO F-FORMULAS**: `temporal_theory_witness_consistent` only works when L ⊆ {phi} ∪ temporal_box_seed M (no F-formulas). With F-formulas, the G-lift from context fails because F-formulas are not G-liftable.

So the induction MUST fully extract all F-formulas before the base case can apply. And the base case handles phi via G-lift from the pure temporal_box_seed context.

#### Approach D: Strengthened Induction Target (RECOMMENDED)

Reformulate the induction to derive `False` directly, not an intermediate formula:

```lean
-- Main lemma: F-formulas in the context are harmless
-- If L ⊢ bot and L ⊆ f_preserving_seed, we derive False
-- by strong induction on count of F-formulas from F_unresolved_theory in L
lemma seed_inconsistency_impossible
    (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_F : Formula.some_future phi ∈ M) :
    ∀ (n : Nat), ∀ (L : List Formula),
      (∀ x ∈ L, x ∈ f_preserving_seed M phi) →
      L.countP (fun x => decide (x ∈ F_unresolved_theory M)) = n →
      DerivationTree L Formula.bot →
      False
```

**Induction step**: Given L ⊢ bot with F(sigma) ∈ L:
- By deduction theorem: L \ {F(sigma)} ⊢ neg(F(sigma)) = G(neg sigma)
- Now we need to show L \ {F(sigma)} is ALSO inconsistent (⊢ bot)
- We know F(sigma) ∈ M (from F_unresolved_theory)
- So neg(F(sigma)) ∉ M (since F(sigma) ∈ M and M is consistent)
- But L \ {F(sigma)} ⊢ neg(F(sigma)), and if L \ {F(sigma)} ⊆ M, then neg(F(sigma)) ∈ M — contradiction
- So L \ {F(sigma)} ⊄ M... which means phi ∈ L \ {F(sigma)} and phi ∉ M

This shows: when L \ {F(sigma)} ⊆ M, we get a contradiction (neg(F(sigma)) ∈ M contradicts F(sigma) ∈ M), so `False` holds. ✓

When phi ∈ L \ {F(sigma)} and phi ∉ M:
- (L \ {F(sigma)}) \ {phi} ⊆ M (all elements except phi are in M)
- Deduction on phi: (L \ {F(sigma)} \ {phi}) ⊢ phi → neg(F(sigma))
- Context is ⊆ temporal_box_seed M ∪ F_unresolved_theory M... NO! It may still contain other F-formulas!

So we're stuck in the same loop. We can't G-lift because there are other F-formulas present.

#### Approach E: Absorption into M (ALTERNATIVE)

Since every element of `f_preserving_seed M phi` except phi is in M:

Given L ⊢ bot with L ⊆ f_preserving_seed:
- Let L_M = {x ∈ L | x ∈ M} and note L \ L_M ⊆ {phi}
- Case phi ∉ L: L = L_M ⊆ M. bot ∈ M. Contradiction. ✓
- Case phi ∈ L: L_M = L \ {phi}. L_M ⊆ M.
  - Deduction: L_M ⊢ neg(phi)
  - Derivation closure: neg(phi) ∈ M
  - G-lift from L_M?? NO — L_M contains F-formulas that aren't G-liftable

  But wait — we don't NEED to G-lift from L_M. We need to G-lift from a G-liftable subset.

  What if we partition L_M:
  - L_temporal = L_M ∩ temporal_box_seed M (G-liftable)
  - L_F = L_M ∩ F_unresolved_theory M (not G-liftable, but all in M)

  Since L_F ⊆ M, each F(sigma_i) ∈ M. The derivation L_M ⊢ neg(phi) uses both L_temporal and L_F formulas.

  **Repeatedly extract F-formulas from L_M**: Each gives a neg(F(sigma)) = G(neg sigma).
  Eventually: L_temporal ⊢ neg(phi) ∨ G(neg s1) ∨ ... ∨ G(neg sk)

  Now L_temporal ⊆ temporal_box_seed M (G-liftable).
  G-lift: G(neg(phi) ∨ G(neg s1) ∨ ...) ∈ M.
  T-axiom: neg(phi) ∨ G(neg s1) ∨ ... ∈ M.

  Same problem: neg(phi) ∈ M doesn't contradict F(phi) ∈ M.

---

## Critical Analysis: The `G_lift_from_context` Mechanism

The resolution likely lies in understanding exactly what `G_lift_from_context` (line ~1066) provides.

**Hypothesis**: `G_lift_from_context` doesn't just G-wrap the conclusion. Given `L ⊢ X` where `L ⊆ temporal_box_seed M`:
- All premises in L are of the form G(a) or □(b) or ¬□(b)
- The G(a) premises are already universally-quantified over future times
- The □(b) and ¬□(b) are modal and timeless (hold at all times in S5)
- So the derivation `L ⊢ X` is "timeless" in the sense that it holds at every future time
- Therefore G(X) ∈ M

The key: `G_lift_from_context` works by constructing a G-closed derivation. It turns `{G(a1), ..., G(an), □(b1), ..., ¬□(b2), ...} ⊢ X` into a proof of `G(X)` using K-axiom for the G-premises and the fact that box-formulas are temporally stable.

**For the inductive case**: After extracting all F-formulas from L_M and phi from L, we get:
`L_temporal ⊢ neg(phi) ∨ G(neg s1) ∨ ... ∨ G(neg sk)`

G-lift gives: `G(neg(phi) ∨ G(neg s1) ∨ ... ∨ G(neg sk)) ∈ M`

But we want EACH disjunct G-wrapped. We only get the whole thing G-wrapped.

**Alternative**: Don't build the disjunction. Instead, extract phi FIRST (before F-formulas), then extract F-formulas:

1. Start: `L ⊢ bot` with `phi ∈ L`
2. Extract phi: `L \ {phi} ⊢ neg(phi)`
3. L \ {phi} may contain F-formulas
4. Extract F(s1): `L \ {phi, F(s1)} ⊢ neg(phi) ∨ G(neg s1)`
5. Extract F(s2): `L \ {phi, F(s1), F(s2)} ⊢ neg(phi) ∨ G(neg s1) ∨ G(neg s2)`
6. ... continue until L_final ⊆ temporal_box_seed M
7. G-lift: `G(neg(phi) ∨ G(neg s1) ∨ ...) ∈ M`

Same result. The order of extraction doesn't change the final G-lift issue.

**The actual mechanism**: Going back to temporal_theory_witness_consistent (base case):

When there are NO F-formulas: `L ⊆ {phi} ∪ temporal_box_seed M`
- Extract phi: `L \ {phi} ⊢ neg(phi)` where `L \ {phi} ⊆ temporal_box_seed M`
- G-lift THE DERIVATION `L \ {phi} ⊢ neg(phi)` to get `G(neg(phi)) ∈ M`
- `G(neg phi) = neg(F(phi))`, contradicts `F(phi) ∈ M`

Notice: the G-lift applies to `neg(phi)` as the target. There's NO disjunction.

For the inductive case to work, we need to either:
1. Reduce to `L_temporal ⊢ neg(phi)` (no disjunction, just neg(phi)), or
2. G-lift a disjunction and handle `neg(phi)` specially

Option 1 means showing that L_temporal ∪ {phi} ⊢ bot (without F-formulas). This would be the case if the F-formulas in L were "redundant" — derivable from the rest. But F-formulas are generally NOT derivable from temporal_box_seed.

**KEY REALIZATION**: The F-formulas in L are not arbitrary — they are in `F_unresolved_theory M ⊆ M`. And `L \ {phi} ⊆ M`. So `L \ {phi} ⊢ neg(phi)` means `neg(phi) ∈ M` (derivation closure). Then by MCS: `phi ∉ M` (which we already know).

But this alone doesn't give us `G(neg phi) ∈ M`. The derivation `L \ {phi} ⊢ neg(phi)` CANNOT be G-lifted because L \ {phi} contains F-formulas that are not G-liftable.

**SO THE INDUCTION MUST SOMEHOW REMOVE F-FORMULAS FROM THE CONTEXT WHILE PRESERVING `⊢ bot`.**

This is the core unsolved problem.

---

## Recommended Next Steps

### Step 1: Study `G_lift_from_context` (CRITICAL)

Read and understand `G_lift_from_context` at line ~1066:
- What exactly are its premises and conclusion?
- Does it work with ALL temporal_box_seed elements or just G_theory?
- Can it be generalized to handle additional premises?

### Step 2: Study `temporal_theory_witness_consistent` (CRITICAL)

Read and understand the existing working proof:
- How does it handle the phi ∉ M case?
- What G-lift mechanism does it use?
- Can its pattern be generalized to handle F-formulas in the context?

### Step 3: Study `G_of_disjunction_in_mcs_elim` (line ~1255)

This lemma extracts a witness from a disjunction of G-formulas:
- What is its exact type signature?
- Does it require ALL disjuncts to be G-formulas?
- Can it handle mixed disjunctions (some G-wrapped, some not)?

### Step 4: Investigate Whether F-formulas Are Eliminable

The core question: Given `L ⊢ bot` with `L = L_temporal ∪ L_F ∪ {phi}` (where L_temporal ⊆ temporal_box_seed and L_F ⊆ F_unresolved_theory), can we show `L_temporal ∪ {phi} ⊢ bot`?

This would hold if F-formulas in L are "derivationally redundant" — but this seems unlikely in general. The F-formulas contribute genuine information to the derivation.

### Step 5: Consider Contrapositive/Semantic Arguments

Instead of proof-theoretic extraction, consider:
- If the seed is inconsistent, what does this mean semantically?
- In task semantics, can we construct a counter-model?
- Does the model existence theorem help?

### Step 6: Research Alternative Proof Techniques

- **Lindenbaum-based**: Instead of proving the seed is consistent directly, show that any MCS extending temporal_box_seed ∪ {phi} can be further extended to include F_unresolved_theory
- **Compactness-based**: Use compactness to reduce to finite subsets (already doing this)
- **Model-theoretic**: Construct a model satisfying the seed directly

---

## Teammate Contributions

| Teammate | Focus | Status | Confidence |
|----------|-------|--------|------------|
| A | Seed construction analysis | Completed | High on seed correctness, Medium on disjunction approach |
| B | Strong induction strategy | Completed | High on structural issues, Medium on implementation details |

### Points of Agreement
1. Seed definition is correct ✓
2. Current proof is fundamentally flawed ✓
3. Strong induction is the right framework ✓
4. G doesn't distribute over disjunction ✓
5. Incremental fixes won't work ✓

### Points of Disagreement/Tension
1. **Extraction order**: Teammate A says extract ALL uniformly; Teammate B says the order reveals a deeper problem with `neg(phi)` vs `G(neg phi)`
2. **Confidence in disjunction approach**: Teammate A is high confidence it works; Teammate B identifies the neg(phi) flaw

### Resolution
The neg(phi) vs G(neg phi) issue is real and must be resolved before implementation. The disjunction accumulation approach needs modification to handle this case. The key to resolution likely lies in understanding `G_lift_from_context` and `temporal_theory_witness_consistent` deeply.

---

## Literature References

### Modal Logic Completeness
- Blackburn, de Rijke, Venema "Modal Logic" (2001): Canonical model construction with MCS
- Kozen "Elementary Completeness Proof for PDL": Fischer-Ladner closure technique
- Henkin-style completeness for S5 (PhilArchive)
- Chicago REU paper on consistency preservation via structural induction

### Temporal Logic
- Stanford Encyclopedia on Temporal Logic: F-preservation and omega-chain constructions
- Yde Venema "Temporal Logic" (Handbook): "Completeness via canonical models does not always work for temporal logics"
- Rosu "Finite-Trace LTL Coinductive Completeness": Deduction theorems for LTL
- Manna & Pnueli: Eventuality properties and computational induction

### Mathlib References
- `Nat.strong_induction_on`: strong induction principle
- `List.countP_filter`, `List.countP_erase`: count manipulation lemmas

### Task Semantics (Project-Specific)
- Tasks are modal equivalence classes; time flows within tasks
- F(phi) = "phi at some future point in current task"
- G(phi) = "phi at all future points in current task"
- This differs from standard branching-time or linear-time models

---

## Summary

The blocker in `f_preserving_seed_consistent` is a genuine mathematical challenge, not just an implementation difficulty. The seed definition is correct but the proof strategy must change from the current extraction-based approach. Strong induction with disjunction accumulation is the most promising direction, but the `neg(phi)` vs `G(neg phi)` problem must be resolved first. Understanding the existing `G_lift_from_context` and `temporal_theory_witness_consistent` mechanisms deeply is the critical next step before any implementation attempt.
