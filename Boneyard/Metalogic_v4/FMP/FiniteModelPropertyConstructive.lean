/-!
# Archived: Finite Model Property Constructive (Task 776)

**Archived**: 2026-01-30
**Original Location**: Theories/Bimodal/Metalogic/FMP/FiniteModelProperty.lean
**Reason**: Contains sorry for truth bridge which depends on archived truth_at_implies_semantic_truth

## Why This Code is Archived

### Sorry #3: finite_model_property_constructive

The theorem tries to provide a constructive FMP with explicit model and cardinality bounds.
The sorry is the "truth bridge" - proving `truth_at (SemanticCanonicalModel phi) tau 0 phi`.

**Why it's sorry'd**: This requires proving the forward truth lemma
(`truth_at_implies_semantic_truth`), which is architecturally impossible (see
`TruthLemmaGap.lean` for full explanation).

The proof constructs:
1. A ClosureMaximalConsistent set S containing phi
2. A FiniteWorldState from S
3. A FiniteHistory and WorldHistory
4. A SemanticWorldState

But then it needs to show `truth_at M tau 0 phi`. This is the exact same gap as
`truth_at_implies_semantic_truth` - connecting recursive truth evaluation to
assignment truth.

## Still-Available Results

The non-constructive FMP theorem remains in the active codebase:

```lean
-- In Theories/Bimodal/Metalogic/FMP/FiniteModelProperty.lean
theorem finite_model_property (phi : Formula) :
    formula_satisfiable phi ->
    exists (D : Type) (inst1 : AddCommGroup D) (inst2 : LinearOrder D)
           (inst3 : IsOrderedAddMonoid D)
      (F : TaskFrame D) (M : TaskModel F) (tau : WorldHistory F) (t : D),
      truth_at M tau t phi
```

This theorem is trivially proven (satisfiability witness provides the model).

For the completeness result, use `semantic_weak_completeness`.

## Original Code

The following theorem was removed from FiniteModelProperty.lean:

```lean
-- DEPRECATED (Task 769, 2026-01-30): Use semantic_weak_completeness instead
theorem finite_model_property_constructive (phi : Formula) (h_sat : formula_satisfiable phi) :
    exists (F : TaskFrame Int) (M : TaskModel F) (tau : WorldHistory F) (t : Int)
      (h_finite : Finite F.WorldState)
      (h_fintype : Fintype F.WorldState),
      truth_at M tau t phi and
      Fintype.card F.WorldState <= 2 ^ (closureSize phi) := by
  -- [proof omitted - contains sorry for truth bridge]
  sorry
```

## References

- Task 750: Research on truth bridge gap
- Task 769: Sorry audit and deprecation marking
- Task 776: This archival
-/
