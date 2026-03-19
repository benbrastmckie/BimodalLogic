# Research Report: Task #981 — Blocker Analysis and Resolution Path

**Task**: 981 - remove_axiom_technical_debt_from_task_979
**Date**: 2026-03-17
**Mode**: Team Research (2 teammates, math domain override)
**Session**: sess_1773709593_2088bd
**Run**: 004

---

## Summary

This report resolves the "K4 logic gap" blocker at `DiscreteSuccSeed.lean:319`. The sorry IS fillable
using a **direct subset argument** based on the T-axiom. However, deeper investigation reveals a
structural inconsistency in the proof system (T-axiom + IRR rule) that requires acknowledgment.

**Bottom line**: The sorry can be filled using `g_content_subset_mcs` (T-axiom gives g_content(M) ⊆ M),
making the proof **valid in Lean** and **mathematically sound modulo the IRR soundness gap**.

---

## Key Findings

### Finding 1: The Codebase Uses KT4 (Reflexive), NOT Strict K4 (HIGH confidence)

The proof system has the **T-axiom** for temporal logic, added by Task 967:

```lean
-- Axioms.lean:256
| temp_t_future (φ : Formula) : Axiom ((Formula.all_future φ).imp φ)

-- Axioms.lean:272
| temp_t_past (φ : Formula) : Axiom ((Formula.all_past φ).imp φ)
```

The semantics confirm reflexive interpretation (`Truth.lean:120`):
```lean
| Formula.all_future φ => ∀ (s : D), t ≤ s → truth_at M Omega τ s φ
```
`t ≤ s` includes `t` itself (reflexive), not `t < s` (strict/irreflexive).

**The "K4 logic gap" in the commit message was incorrectly framed.** The logic is KT4, not K4.

---

### Finding 2: g_content(M) ⊆ M for ALL MCSs (HIGH confidence)

Given the T-axiom, for any MCS M and any φ ∈ g_content(M) (i.e., G(φ) ∈ M):
1. `temp_t_future φ`: `[] ⊢ G(φ) → φ` is a theorem
2. By `theorem_in_mcs h_mcs`: `(G(φ) → φ) ∈ M`
3. By `implication_property h_mcs`: `φ ∈ M`

Therefore **g_content(M) ⊆ M** for any MCS M in this logic.

Formally:
```lean
lemma g_content_subset_mcs (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    g_content M ⊆ M := by
  intro φ h_in_gc
  have h_T : [] ⊢ (Formula.all_future φ).imp φ :=
    DerivationTree.axiom [] _ (Axiom.temp_t_future φ)
  exact SetMaximalConsistent.implication_property h_mcs
    (theorem_in_mcs h_mcs h_T) h_in_gc
```

This lemma is NOT in the codebase yet and must be added.

---

### Finding 3: The Sorry at Line 319 IS Fillable — Direct Subset Argument (HIGH confidence)

With `g_content(M) ⊆ M`, the Case 2 sorry has a clean proof:

**Proof of Case 2** (L contains blocking formulas):

```
Given: L_g ∪ L_b ⊢ ⊥ where L_g ⊆ g_content(M), L_b ⊆ blockingFormulas(M)

Step 1: For each bf ∈ L_b, bf has trigger ¬G(ψ) ∈ M
        [¬G(ψ)] ⊢ bf  (by blocking_formula_from_negG, already proved)
        By cut/weakening: L_g ∪ triggers ⊢ ⊥
        where triggers = {¬G(ψ) | bf ∈ L_b}, triggers ⊆ M

Step 2: L_g ⊆ g_content(M) ⊆ M  (by g_content_subset_mcs, using T-axiom)

Step 3: L_g ∪ triggers ⊆ M  (from Steps 1 and 2)

Step 4: By SetMaximalConsistent.closed_under_derivation: ⊥ ∈ M

Step 5: Contradiction with M's consistency ∎
```

**This proof requires NO G-lifting, NO K4 analysis, and NO complex modal reasoning.**
The research-003 G-inference approach was chasing the wrong problem.

---

### Finding 4: The "Cut" Step Requires a Substitution Lemma (MEDIUM confidence)

Step 1 above requires replacing each blocking formula `bf = ¬ψ ∨ ¬G(ψ)` with its trigger
`¬G(ψ)` in the derivation, using the fact that `[¬G(ψ)] ⊢ bf`.

This is a **cut/substitution** operation. The exact Lean formalization needs:
```lean
-- From L_g ∪ {bf} ⊢ ⊥ and [¬G(ψ)] ⊢ bf, derive L_g ∪ {¬G(ψ)} ⊢ ⊥
-- i.e., cut on bf with its derivation from ¬G(ψ)
```

Check whether `DerivationTree` has a cut rule. If not, use weakening + the derivation
from `blocking_formula_from_negG` directly:
- Since `[¬G(ψ)] ⊢ bf`, and we can use modus ponens chain, we can replace bf in context.
- Alternatively, keep the full blocking formula structure in the proof and work with
  the extended context `L_g ∪ {bf} ∪ {¬G(ψ)}` where both bf and its trigger are available.

**Simpler path**: Keep L_g ∪ L_b context as is, add triggers to context via weakening,
then use the trigger membership in M to derive contradiction directly.

---

### Finding 5: Deeper Structural Issue — T-Axiom + IRR Creates Object-Level Inconsistency (HIGH confidence)

**This is a critical finding for the project, though it does NOT block task 981.**

The proof system has BOTH:
1. **T-axiom for past**: `⊢ H(¬p) → ¬p`
2. **Gabbay IRR rule** (`Derivation.lean:149`): From `⊢ (p ∧ H(¬p)) → φ` with `p ∉ φ.atoms`, infer `⊢ φ`

The IRR rule's comment says: "This rule is sound on irreflexive frames". But the T-axiom was
added for REFLEXIVE semantics (Task 967). These are incompatible:

**Derivation of ⊥**:
1. `⊢ H(¬p) → ¬p` (T-axiom for past)
2. `⊢ (p ∧ H(¬p)) → p` (left conjunction elimination)
3. `⊢ (p ∧ H(¬p)) → H(¬p)` (right conjunction elimination)
4. `⊢ (p ∧ H(¬p)) → ¬p` (chaining with step 1)
5. `⊢ (p ∧ H(¬p)) → ⊥` (from steps 2 and 4: p ∧ ¬p → ⊥)
6. `Formula.bot.atoms = ∅`, so `p ∉ ⊥.atoms` — freshness satisfied
7. By IRR with φ = ⊥: `⊢ ⊥`

**The object-level proof system is INCONSISTENT.** This is confirmed by:
- `Soundness.lean:576` has `sorry` for the IRR rule soundness case
- `canonicalR_irreflexive` claims `¬CanonicalR M M`, but with T-axiom `g_content(M) ⊆ M` for all MCSs,
  so `CanonicalR M M` IS always true — a direct contradiction

**Impact on task 981**:
- The sorry at line 319 CAN be filled using the T-axiom approach
- The resulting Lean proof type-checks and is internally consistent
- The proof is "valid" at the Lean level but the underlying proof system has the IRR inconsistency
- This inconsistency is a **pre-existing issue** from Task 967, NOT introduced by task 981
- Task 981's goal (removing `discrete_Icc_finite_axiom`) is achievable without fixing this deeper issue

---

### Finding 6: Conflict Resolution — Teammate A vs Teammate B (HIGH confidence)

**Conflict**: Teammate A said the codebase IS KT4; Teammate B said it uses strict K4 without T-axiom.

**Resolution**: Teammate A is CORRECT. Verification:
```bash
# Axioms.lean:256 — T-axiom is present
| temp_t_future (φ : Formula) : Axiom ((Formula.all_future φ).imp φ)
# Truth.lean:120 — reflexive semantics
| Formula.all_future φ => ∀ (s : D), t ≤ s → truth_at M Omega τ s φ
```

Teammate B's Finding 6 (restricted necessitation) correctly explains why the G-inference approach
from research-003 is problematic in PRINCIPLE, but it is moot because the T-axiom provides a
simpler and more direct proof strategy.

---

## Mathematical Analysis: Proof Structure

### Phase 2 Proof Template

```lean
theorem discreteImmediateSuccSeed_consistent (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    SetConsistent (discreteImmediateSuccSeed M) := by
  intro L hL_sub ⟨d⟩
  have h_partition : ∀ φ ∈ L, φ ∈ g_content M ∨ φ ∈ blockingFormulas M := ...  -- done
  by_cases h_all_gc : ∀ φ ∈ L, φ ∈ g_content M
  · -- Case 1: L ⊆ g_content(M) — handled by g_content_consistent
    exact g_content_consistent M h_mcs L h_all_gc ⟨d⟩
  · -- Case 2: L contains blocking formulas
    push_neg at h_all_gc
    obtain ⟨bf, hbf_in_L, hbf_not_gc⟩ := h_all_gc

    -- STRATEGY: Show all of L is "ultimately" in M
    -- Step A: Partition L into L_g (g_content) and L_b (blocking)
    -- Step B: For each bf_i ∈ L_b: trigger_i = ¬G(ψ_i) ∈ M
    -- Step C: From L_g ∪ L_b ⊢ ⊥, using blocking_formula_from_negG, derive
    --         that a subset of M derives ⊥
    -- Step D: Contradict h_mcs.consistent

    -- The key: g_content(M) ⊆ M (by T-axiom)
    -- So L_g ⊆ g_content(M) ⊆ M
    -- And triggers ⊆ M (by definition of blocking formulas)

    sorry  -- TO BE IMPLEMENTED: see plan-revision below
```

### Required New Lemmas (in order of dependency)

1. **`g_content_subset_mcs`**: `g_content M ⊆ M` when M is MCS
   - Uses: `temp_t_future`, `theorem_in_mcs`, `implication_property`
   - ~5 lines

2. **`finite_subset_in_mcs_derives_bot`** (or reuse existing closure):
   - `SetMaximalConsistent.closed_under_derivation` already handles: if L ⊆ M and L ⊢ φ, then φ ∈ M
   - Need to use this for the contradiction

3. **Blocking formula cut lemma**: How to replace blocking formulas with triggers in derivation
   - Option A: Use cut rule if available
   - Option B: Restructure proof to avoid explicit cut (show all formulas in M)
   - The cleanest Lean approach: use `SetMaximalConsistent.closed_under_derivation` twice

---

## Synthesis

### Conflicts Resolved

| Conflict | Resolution |
|----------|-----------|
| K4 vs KT4 frame class | KT4 (T-axiom confirmed at Axioms.lean:256) |
| G-inference vs direct argument | Direct subset argument is correct |
| Teammate A: "sorry is fillable" vs Teammate B: "G-lifting fails" | Both partly right: G-lifting fails (Teammate B correct), but T-axiom provides simpler path (Teammate A correct on conclusion) |
| canonicalR_irreflexive vs g_content ⊆ M | Both hold in an INCONSISTENT proof system; IRR soundness sorry exists |

### Gaps Remaining After This Research

1. **Cut/substitution mechanics**: The exact Lean tactic sequence for replacing blocking formulas
   with triggers needs to be worked out during implementation. Options:
   - Use `DerivationTree.weakening` to add triggers to context, then chain derivations
   - Look for cut admissibility lemma in `DeductionTheorem.lean`

2. **IRR soundness sorry** (`Soundness.lean:576`): Pre-existing issue. Not in scope for task 981
   but should be tracked. The T-axiom + IRR combination creates an object-level inconsistency.

3. **g_content_subset_mcs**: New lemma needed, straightforward to prove.

---

## Recommendations

### Primary Recommendation: Direct Subset Proof Using T-Axiom (IMPLEMENT IMMEDIATELY)

**Phase 2 implementation**:
1. Add lemma `g_content_subset_mcs` (uses `temp_t_future`)
2. For Case 2 sorry:
   - Build a map from each blocking formula in L to its trigger in M
   - Show g_content formulas in L are also in M (by `g_content_subset_mcs`)
   - Use `SetMaximalConsistent.closed_under_derivation` with the "effective" context in M
3. The cut step is the main implementation challenge; consult `DeductionTheorem.lean`
   for available cut/substitution tools

**Confidence**: HIGH that this approach works; MEDIUM on exact Lean formalization of cut step.

### Secondary Recommendation: Track IRR + T-Axiom Inconsistency

Create a separate task to investigate the IRR soundness sorry and whether T-axiom + IRR
creates an object-level inconsistency. This is pre-existing technical debt from Task 967
and does not block task 981.

### Implementation Strategy for Phase 2

```lean
-- RECOMMENDED PROOF SKETCH FOR LINE 319 SORRY:

-- After obtaining: bf ∈ blockingFormulas(M), ψ with ¬G(ψ) ∈ M, bf = ¬ψ ∨ ¬G(ψ)
-- And: L_g ⊆ g_content(M), L_b ⊆ blockingFormulas(M), L_g ∪ L_b ⊢ ⊥

-- Build the "reduced" context: all of L mapped to M-members
-- For φ ∈ L_g: φ ∈ g_content(M) ⊆ M (by g_content_subset_mcs)
-- For bf_i ∈ L_b: trigger_i = ¬G(ψ_i) ∈ M

-- The "trigger substitution" derivation:
-- From L_g ∪ L_b ⊢ ⊥ and {[trigger_i] ⊢ bf_i} for each i:
-- Build L_g ∪ triggers_list ⊢ ⊥ using repeated cut/weakening
-- ALTERNATIVE: Add all triggers to context, weaken L_g ∪ L_b derivation,
--   then use cuts to discharge each bf_i using its trigger

-- Final step:
have h_subset : ∀ φ ∈ L_g ∪ triggers_list, φ ∈ M := ...
exact absurd (SetMaximalConsistent.closed_under_derivation h_mcs _ h_subset d_reduced)
  (not_bot_in_consistent_mcs h_mcs)
```

---

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Contribution |
|----------|-------|--------|------------|-----------------|
| A | Mathematical validity of G-inference in K4 | Completed | HIGH | T-axiom → g_content ⊆ M; direct subset proof |
| B | Literature review and alternative approaches | Completed | HIGH | IRR restriction; reflexive vs irreflexive frame analysis |
| Lead synthesis | Inconsistency analysis | Completed | HIGH | T-axiom + IRR = ⊢ ⊥; IRR soundness sorry at Soundness.lean:576 |

---

## References

- `Theories/Bimodal/ProofSystem/Axioms.lean:256` — T-axiom `temp_t_future`
- `Theories/Bimodal/ProofSystem/Derivation.lean:149` — IRR rule definition
- `Theories/Bimodal/Semantics/Truth.lean:120` — Reflexive semantics for `all_future`
- `Theories/Bimodal/Metalogic/Soundness.lean:576` — IRR soundness sorry (pre-existing)
- `Theories/Bimodal/Metalogic/Bundle/CanonicalIrreflexivity.lean:1214` — `canonicalR_irreflexive`
- `Theories/Bimodal/Metalogic/StagedConstruction/DiscreteSuccSeed.lean:209` — `g_content_consistent`
- `Theories/Bimodal/Metalogic/StagedConstruction/DiscreteSuccSeed.lean:258` — `blocking_formula_from_negG`
- Task 967: Reflexive semantics refactor (introduced T-axiom + preserved IRR rule)
- Hakli & Negri: "Does the deduction theorem fail for modal logic?" (IRR restriction)
- Segerberg (1970), Verbrugge et al.: Constructive method for tense logic completeness
