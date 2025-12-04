# Temporal Duality Partial Proof Summary

## Metadata
- **Date**: 2025-12-03
- **File**: /home/benjamin/Documents/Philosophy/Projects/Logos/Logos/Semantics/Truth.lean
- **Theorem**: `truth_swap_of_valid_at_triple` and `valid_swap_of_valid`
- **Status**: PARTIAL (3/6 cases complete, 3 sorry remaining)
- **Attempts**: 1/3
- **Lines Modified**: 519-672 (TemporalDuality namespace added)
- **Sorry Count**: 3 (lines 589, 637, 644)

## Proof Strategy

The goal is to prove that validity is preserved under the `swap_past_future` transformation, which exchanges Past and Future operators. The proof proceeds by structural induction on formulas.

### Completed Cases (3/6)

1. **atom case** (lines 552-556): ✅ COMPLETE
   - `swap_past_future (atom p) = atom p` (identity)
   - Validity directly implies truth at any triple
   - **Proof**: `simp only [Formula.swap_past_future]; exact h_valid F M τ t ht`

2. **bot case** (lines 558-565): ✅ COMPLETE
   - `swap_past_future bot = bot`
   - Both sides are `False`
   - **Proof**: Bot cannot be valid (it's always False), so `h_valid F M τ t ht` directly proves False
   - **Tactics**: `simp only [Formula.swap_past_future, truth_at]; exact h_valid F M τ t ht`

3. **box case** (lines 586-602): ✅ COMPLETE
   - `swap_past_future (□ψ) = □(swap ψ)`
   - **Key insight**: `is_valid (□ψ)` implies `is_valid ψ`
   - **Proof**: If `□ψ` valid, then at all triples (F', M', τ', t'), for all histories σ, ψ holds at σ
   - Choosing σ = τ' gives: ψ holds at (F', M', τ', t')
   - Therefore ψ is valid
   - By IH: `swap ψ` is true at (M, σ, t, hs)
   - **Tactics**: `simp only`, `intro`, `have` (helper lemma), `exact` (IH application)

### Incomplete Cases (3/6)

1. **imp case** (line 583): ❌ INCOMPLETE
   - **Goal**: Given `is_valid (ψ → χ)` and `truth_at M τ t ht (swap ψ)`, prove `truth_at M τ t ht (swap χ)`
   - **Challenge**: Validity of `ψ → χ` doesn't imply validity of ψ or χ individually
   - **Attempted**: Using swap involution (`swap(swap φ) = φ`)
   - **Blocker**: Cannot decompose validity of implication to get properties of subformulas

2. **past case** (line 631): ❌ INCOMPLETE
   - **Goal**: Given `is_valid (Past ψ)` and `t < s`, prove `truth_at M τ s hs (swap ψ)`
   - **Transform**: `swap_past_future (Past ψ) = Future (swap ψ)`
   - **Need**: Show that `∀ r > s, truth_at M τ r (swap ψ)`
   - **Challenge**: Requires showing `is_valid (Past ψ) → is_valid ψ`
   - **Blocker**: This reduction requires domain extension assumptions not available in current framework

3. **future case** (line 638): ❌ INCOMPLETE
   - **Goal**: Given `is_valid (Future ψ)` and `s < t`, prove `truth_at M τ s hs (swap ψ)`
   - **Transform**: `swap_past_future (Future ψ) = Past (swap ψ)`
   - **Challenge**: Symmetric to past case
   - **Blocker**: Same as past case

## Tactics Used

- `intro` - Introduce hypotheses and universal quantifications
- `have` - Create intermediate lemmas
- `exact` - Provide exact proof terms
- `simp only` - Simplify using specific lemmas
- `sorry` - Placeholder for incomplete proofs

## Mathlib Theorems Referenced

- None (uses only Logos definitions)

## Key Lemmas Defined

### `is_valid` (private def, line 525-527)
Local definition of validity to avoid circular dependency with Validity.lean:
```lean
private def is_valid (φ : Formula) : Prop :=
  ∀ (F : TaskFrame) (M : TaskModel F) (τ : WorldHistory F) (t : Int) (ht : τ.domain t),
    truth_at M τ t ht φ
```

### `valid_at_triple` (theorem, lines 535-537)
Auxiliary lemma unpacking validity definition:
```lean
theorem valid_at_triple {φ : Formula} (h_valid : is_valid φ) (F : TaskFrame) (M : TaskModel F)
    (τ : WorldHistory F) (t : Int) (ht : τ.domain t) :
    truth_at M τ t ht φ := h_valid F M τ t ht
```

## Diagnostics

No compilation errors. File builds successfully with 3 remaining `sorry` markers.

## Work Remaining

### Immediate Next Steps (estimated 6-10 hours)

1. **Prove helper lemmas for temporal cases**:
   - `valid_of_valid_past`: If `Past ψ` is valid, then `ψ` is valid
   - `valid_of_valid_future`: If `Future ψ` is valid, then `ψ` is valid
   - **Challenge**: May require additional frame axioms or domain extension properties

2. **Resolve imp case**:
   - May need bidirectional proof strategy
   - Consider proving `truth_at M τ t ht (swap φ) ↔ <some property of φ>` as a mutual induction
   - Alternatively, prove `is_valid φ ↔ is_valid (swap φ)` as a separate theorem

3. **Alternative approach**:
   - Instead of proving `is_valid ψ` from `is_valid (Past ψ)`, directly construct witnesses
   - Use validity at ALL triples to choose appropriate triples for quantification
   - May require constructing extended histories with known domain properties

### Theoretical Considerations

From the research report (Section 5.2), the proof should exploit:
- Int as an abelian group with order reversal: `s < t ↔ -t < -s`
- Validity means truth at ALL triples (universal quantification)
- swap_past_future exchanges temporal quantifiers correspondingly

The remaining cases likely need:
1. A more sophisticated structural lemma relating temporal quantification to validity
2. Explicit construction of witness histories for existential claims
3. Or a bidirectional/mutual induction approach

## Notes

### Design Decision: Local `is_valid` Definition

To avoid circular dependency (Truth.lean ← Validity.lean), we defined `is_valid` locally in the TemporalDuality namespace. This is identical to `valid` in Validity.lean but scoped privately.

### Box Case Success Pattern

The box case succeeded because:
- Box quantifies over ALL histories at a given time
- This universal quantification is strong enough to imply universal truth (validity)
- The IH could then be applied directly

This pattern suggests that temporal cases might also succeed if we can show that temporal quantification over ALL times (in validity context) implies validity of subformulas.

### Potential Alternative: Frame Extension Axiom

If direct proof remains blocked, consider adding a frame axiom:
```lean
axiom domain_extension : ∀ (F : TaskFrame) (τ : WorldHistory F) (t : Int) (ht : τ.domain t),
  ∃ (τ' : WorldHistory F) (ht' : τ'.domain (t + 1)),
    (∀ s, s ≤ t → τ.domain s → τ'.states s _ = τ.states s ht)
```

This would allow constructing futures/pasts needed for temporal validity reductions.

## Context Exhaustion

Context usage: ~60K tokens / 200K budget
Remaining budget: ~140K tokens
Context exhausted: **No**

## Integration Notes

- Changes are backward compatible (no API changes)
- New local definitions are private to TemporalDuality namespace
- Completed box case reduces sorry count from 4 to 3
- File compiles successfully with `lake build Logos.Semantics.Truth`

## Testing Strategy

Once complete, add tests:
- `test_temporal_duality_valid_box`: Verify box case
- `test_temporal_duality_valid_past`: Verify past case
- `test_temporal_duality_valid_future`: Verify future case
- `test_temporal_duality_valid_nested`: Verify nested combinations

## References

- Research Report: `.claude/specs/026_temporal_symmetry_derivation/reports/001-temporal-symmetry-analysis.md`
- Plan: `.claude/specs/026_temporal_symmetry_derivation/plans/001-temporal-symmetry-derivation-plan.md`
- Formula.lean: `swap_past_future` definition and `swap_past_future_involution` theorem
