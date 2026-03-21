# Research Report: G-Inference Validity in K4 Logic

**Task**: 981 - remove_axiom_technical_debt_from_task_979
**Teammate**: A (Mathematical Validity Specialist)
**Focus**: G-inference step in the consistency proof for `discreteImmediateSuccSeed`
**Date**: 2026-03-16

---

## Key Findings

### Finding 1: The Gap Is Real (HIGH confidence)

**The G-inference step as proposed does NOT work in K4 logic.**

The proposed proof (from research-003) claims:
> From `L_g ⊢ ⊥` (where `L_g ⊆ g_content(M)`), apply G-inference to get `G(L_g) ⊢ G(⊥)`, conclude `G(L_g) ⊆ M` derives `⊥`.

This reasoning is VALID. But research-003 then states:
> Apply "G-inference" to lift: `G(L_g) ∪ triggers ⊢ ⊥`

This conflates two different operations:
1. **G-necessitation** (valid): From `L ⊢ φ`, derive `G(L) ⊢ G(φ)` (proven in `GeneralizedNecessitation.lean:152-173`)
2. **Partial G-lifting** (INVALID in K4): From `L_g ∪ {¬G(ψ)} ⊢ ⊥`, derive `G(L_g) ∪ {¬G(ψ)} ⊢ ⊥`

The second operation requires passing `¬G(ψ)` through the G-lift unchanged. This would require `G(¬G(ψ)) → ¬G(ψ)`, which is `G(¬G(ψ)) → ¬G(ψ)` = `¬G(G(ψ)) → ¬G(ψ)` (by duality with F). This is equivalent to `G(ψ) → G(G(ψ))`, which is the 4-axiom. **BUT** the proof needs the CONVERSE: `G(G(ψ)) → G(ψ)`, which is NOT valid in K4.

---

### Finding 2: Semantic Counterexample for `G(G(ψ)) ↛ G(ψ)` in K4 (HIGH confidence)

**Countermodel (K4 = transitive frames, NOT reflexive):**

Consider frame `F = (W, R)`:
- `W = {w₀, w₁, w₂}`
- `R = {(w₀, w₁), (w₀, w₂), (w₁, w₂)}` (transitive, irreflexive)

Valuation `V`:
- `V(p) = {w₂}` (p is true only at w₂)

Evaluation:
- At `w₂`: `G(p) = True` (no R-successors of w₂, so vacuously true)
- At `w₁`: `G(p) = True` (only successor is w₂, where p holds)
- At `w₀`:
  - `G(G(p)) = True` (both successors w₁, w₂ satisfy `G(p)`)
  - `G(p) = ?` (successors are w₁, w₂)
    - At w₁: p is FALSE
    - At w₂: p is TRUE
  - So `G(p) = False` at w₀

**Result**: `w₀ ⊨ G(G(p)) ∧ ¬G(p)`, proving `G(G(ψ)) ↛ G(ψ)` in K4.

**The semantic intuition**: In K4 with irreflexive accessibility, "all 2+-step successors satisfy ψ" does NOT imply "all 1-step successors satisfy ψ". The 1-step successors can fail ψ while their own successors satisfy it.

---

### Finding 3: The Codebase Uses KT4 (Reflexive + Transitive) (HIGH confidence)

Examining `Axioms.lean:242-256`, the codebase includes:

```lean
/-- Temporal T axiom (future): `Gφ → φ` (reflexivity for future). -/
| temp_t_future (φ : Formula) : Axiom ((Formula.all_future φ).imp φ)
```

This is the **T-axiom** for temporal logic, corresponding to **reflexive** temporal order (`t ≤ t`).

Combined with `temp_4` (the 4-axiom at line 239):
```lean
| temp_4 (φ : Formula) :
  Axiom ((Formula.all_future φ).imp (Formula.all_future (Formula.all_future φ)))
```

The logic is actually **KT4** (also known as **S4** in pure modal terms), not just K4.

---

### Finding 4: In KT4, `G(G(ψ)) → G(ψ)` IS Derivable (HIGH confidence)

In KT4 (reflexive + transitive), we have:
- **T-axiom**: `G(φ) → φ`
- **4-axiom**: `G(φ) → G(G(φ))`

**Derivation of `G(G(ψ)) → G(ψ)`**:

1. `G(G(ψ)) → G(ψ)` is simply an instance of the T-axiom with `φ := G(ψ)`.

So in KT4, `G(G(ψ)) → G(ψ)` is a **theorem** (specifically `temp_t_future` applied to `G(ψ)`).

**This means the G-inference approach MAY work after all, but NOT via the mechanism proposed in research-003.**

---

### Finding 5: The Actual Proof Gap is Different (MEDIUM-HIGH confidence)

The real issue is NOT `G(G(ψ)) → G(ψ)` (which IS valid in KT4), but the structure of the seed consistency argument.

Looking at `DiscreteSuccSeed.lean:313-319`:

```lean
-- TODO: Complete Case 2 using cut/substitution to replace bf with its trigger,
-- then show g_content(M) ∪ {¬G(ψ)} is consistent.
-- The challenge: g_content elements have G(φ) ∈ M, while ¬G(ψ) ∈ M directly.
-- Need partial G-lifting: from L_g ∪ {¬G(ψ)} ⊢ ⊥, derive G(L_g) ∪ {¬G(ψ)} ⊢ ⊥.
```

The issue is:
1. We have `L_g ∪ L_b ⊢ ⊥` where `L_b` contains blocking formulas `¬ψ ∨ ¬G(ψ)`
2. Each blocking formula has trigger `¬G(ψ) ∈ M`
3. We can replace `bf` with trigger to get `L_g ∪ triggers ⊢ ⊥`
4. Now we need to derive contradiction with M's consistency

The key insight: **G-inference applies to the entire derivation**, not partially. We cannot "lift" only `L_g` while leaving triggers unchanged.

---

### Finding 6: Correct Proof Structure for KT4 (MEDIUM confidence)

The proof should proceed differently. Given `L_g ∪ triggers ⊢ ⊥`:

**Case Analysis on Trigger Structure**:

Let `triggers = {¬G(ψ₁), ..., ¬G(ψₖ)}`. We have:
- Each `¬G(ψᵢ) ∈ M`
- `L_g ⊆ g_content(M)`, so each `φ ∈ L_g` has `G(φ) ∈ M`

**Observation**: `¬G(ψ)` is equivalent to `F(¬ψ)` (some_future(¬ψ)).

**Alternative Approach** (using existing pattern from `WitnessSeed.lean:79-178`):

The `forward_temporal_witness_seed_consistent` proof shows how to handle `g_content ∪ {ψ}` consistency when `F(ψ) ∈ M`. The key is:
- If `L ⊢ ⊥` and `L ⊆ {ψ} ∪ g_content(M)` with `F(ψ) ∈ M`
- Case on whether `ψ ∈ L`:
  - If yes: Filter out ψ, apply deduction theorem, lift with G, use `F(ψ) = ¬G(¬ψ)` contradiction
  - If no: Pure g_content case, lift with G, derive `G(⊥) ∈ M`, contradict seriality

For blocking formulas, the structure is different because:
- Blocking formula `bf = ¬ψ ∨ ¬G(ψ)` is NOT a pure element to filter
- Trigger `¬G(ψ) = F(¬ψ)` is an existential claim

**The Structural Challenge**: The WitnessSeed pattern relies on `F(ψ) ∈ M` to get a contradiction. For blocking formulas, we have `¬G(ψ) ∈ M` (equivalently `F(¬ψ) ∈ M`), but the blocking formula adds disjunctive structure.

---

### Finding 7: Does Reflexivity Actually Help? (MEDIUM confidence)

With KT4's reflexive semantics (G quantifies over `t' ≥ t`, not `t' > t`):

The blocking formula semantics change:
- `blockingFormula(ψ) = ¬ψ ∨ ¬G(ψ)`
- For immediate successor `N` of `M`:
  - `N` should satisfy `g_content(M)` (all φ where G(φ) ∈ M should be in N)
  - `N` should satisfy blocking formulas (to prevent going "too far ahead")

**With reflexive G**: If `G(ψ) ∈ M`, then by reflexivity `ψ ∈ M`. So `g_content(M)` only contains formulas that are ALSO in M directly (by T-axiom).

This is a significant structural difference from irreflexive semantics. It means:
- `g_content(M) = {φ | G(φ) ∈ M}` has the property that `φ ∈ M` for all `φ ∈ g_content(M)` (by T-axiom closure)
- So `g_content(M) ⊆ M`!

**Key Implication**: Under reflexive semantics, `g_content(M) ⊆ M` by MCS closure under the T-axiom.

---

### Finding 8: Revised Proof Strategy for KT4 (MEDIUM confidence)

Given Finding 7, the proof simplifies:

Since `g_content(M) ⊆ M` (by T-axiom closure in MCS), and `triggers ⊆ M` (by definition), we have:
- `L_g ⊆ g_content(M) ⊆ M`
- `triggers ⊆ M`

So `L_g ∪ triggers ⊆ M`.

If `L_g ∪ triggers ⊢ ⊥`, then by MCS closure under derivation, `⊥ ∈ M`, contradicting M's consistency.

**This is the direct argument!** No G-lifting needed at all.

---

## Mathematical Analysis

### K4 vs KT4 Axiom Comparison

| Property | K4 | KT4 (Codebase) |
|----------|-----|----------------|
| 4-axiom `G(φ) → G(G(φ))` | Yes | Yes |
| T-axiom `G(φ) → φ` | No | Yes (`temp_t_future`) |
| `G(G(φ)) → G(φ)` | No (counterexample above) | Yes (instance of T) |
| `g_content(M) ⊆ M` for MCS | Not necessarily | Yes (T-axiom closure) |

### Frame Correspondence

| Axiom | Frame Condition |
|-------|-----------------|
| K (distribution) | All frames |
| T (reflexivity) | Reflexive: ∀w. R(w,w) |
| 4 (transitivity) | Transitive: R∘R ⊆ R |
| KT4 = S4 | Preorder (reflexive + transitive) |

### Critical Observation

The codebase implements **reflexive temporal semantics** (Task 967 added `temp_t_future` and `temp_t_past`). This makes the logic KT4 (S4 in modal terms), which has strictly more theorems than K4.

The G-inference gap identified in research-003 is **NOT actually a gap in this logic**, because the converse `G(G(ψ)) → G(ψ)` is derivable as an instance of the T-axiom.

---

## Implications for the Proof

### The Proof at DiscreteSuccSeed.lean:319 Can Be Completed

The sorry at line 319 should be fillable using the following strategy:

**Proof Sketch**:

1. We have `L ⊆ discreteImmediateSuccSeed(M)` and `L ⊢ ⊥`
2. Partition: `L = L_g ∪ L_b` where `L_g ⊆ g_content(M)`, `L_b ⊆ blockingFormulas(M)`
3. Case 1 (`L_b = ∅`): Use `g_content_consistent` (already proven at line 209-253)
4. Case 2 (`L_b ≠ ∅`):
   - Each `bf ∈ L_b` has form `¬ψ ∨ ¬G(ψ)` with trigger `¬G(ψ) ∈ M`
   - `[¬G(ψ)] ⊢ bf` (proven at line 258-264)
   - By cut: `L_g ∪ triggers ⊢ ⊥` where `triggers = {¬G(ψᵢ) | bfᵢ ∈ L_b}`
   - **Key**: `triggers ⊆ M` (by definition of blocking formulas)
   - **Key**: `L_g ⊆ g_content(M) ⊆ M` (by T-axiom: `G(φ) ∈ M` implies `φ ∈ M`)
   - So `L_g ∪ triggers ⊆ M`
   - Since M is closed under derivation and `L_g ∪ triggers ⊢ ⊥`, we get `⊥ ∈ M`
   - Contradiction with M's consistency ∎

### Key Lemma Needed

```lean
lemma g_content_subset_mcs (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    g_content M ⊆ M := by
  intro φ h_in_gc
  -- h_in_gc : G(φ) ∈ M
  -- By T-axiom (temp_t_future): G(φ) → φ is a theorem
  -- By MCS closure under implication: φ ∈ M
  have h_T : [] ⊢ (Formula.all_future φ).imp φ :=
    DerivationTree.axiom [] _ (Axiom.temp_t_future φ)
  exact SetMaximalConsistent.implication_property h_mcs (theorem_in_mcs h_mcs h_T) h_in_gc
```

---

## Recommendations

### Recommendation 1: Add `g_content_subset_mcs` Lemma (HIGH priority)

Prove the lemma showing `g_content(M) ⊆ M` for any MCS, using the T-axiom. This is a simple application of MCS closure under derivation.

### Recommendation 2: Complete Case 2 Using Direct Subset Argument (HIGH priority)

The sorry at line 319 can be filled using:
1. Cut to replace blocking formulas with triggers
2. Show `L_g ∪ triggers ⊆ M` (using `g_content_subset_mcs` + trigger definition)
3. Apply MCS closure to get contradiction

### Recommendation 3: Document the KT4 Assumption (MEDIUM priority)

The proof relies on the T-axiom (`temp_t_future`). Document this dependency clearly, as it would NOT work in pure K4 logic.

### Recommendation 4: Do NOT Pursue K4 G-Lifting (LOW priority)

The "partial G-lifting" approach suggested in research-003's closing argument section is unnecessary and mathematically problematic in K4. With the T-axiom available, the direct subset argument is simpler and correct.

---

## Summary

| Question | Answer |
|----------|--------|
| Does `G(G(ψ)) ↛ G(ψ)` in K4? | **Yes** (counterexample provided) |
| Does `G(G(ψ)) → G(ψ)` in KT4? | **Yes** (instance of T-axiom) |
| Is this codebase K4 or KT4? | **KT4** (`temp_t_future` at Axioms.lean:256) |
| Can the G-inference approach work? | **Not as stated** (requires converse of 4-axiom) |
| Is there a better approach? | **Yes** - direct subset argument using T-axiom |
| Is the sorry fillable? | **Yes** - using `g_content_subset_mcs` + MCS closure |

The critical insight is that under KT4's reflexive semantics, `g_content(M) ⊆ M` for any MCS, which makes the consistency proof much simpler than the G-inference approach would suggest.
