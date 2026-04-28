# Implementation Summary: Task #113 Phase 5 -- Open Guard Final Cleanup

## Phase 5 Results

### Step 1: Truth.lean `time_shift_preserves_truth` (2 sorries removed)

Fixed the `untl` and `snce` cases in `time_shift_preserves_truth`. The proof shifts
the Until/Since witness `s` by `(y-x)` between the shifted and original histories,
preserving strict `<` inequalities through the shift. Both directions (mp/mpr)
required careful coordination of `truth_history_eq` and the inductive hypotheses
to bridge between definitionally-unequal shift amounts (e.g., `(s+(y-x))-s` vs `y-x`).

### Step 2: TemporalDerived.lean documentation update

Updated module docstring to document which theorems are invalid under open guard
semantics (BX8/BX9-dependent chain) vs pre-existing sorries (seriality-dependent).
Dead theorems left in place as sorry stubs because downstream files
(SuccRelation.lean, UntilSinceCoherence.lean, PointInsertion.lean) depend on them.
Boneyard archive `ClosedGuardTemporalDerived.lean` already existed from Phase 1.

### Step 3: Substitution.lean verification

Both `ProofSystem/Substitution.lean` and `ConservativeExtension/Substitution.lean`
were already clean -- stale match arms removed in Phase 1 with NOTE comments.
No changes needed.

### Step 4: ChronicleToCountermodel.lean `cantor_bfmcs_restricted_buc` (1 sorry removed)

Restored the backward Until/Since coherence proof with open guard fix.
The key change: guard bounds `le_of_lt hz_rat_gt` (half-closed `t <= r`)
replaced with direct `hz_rat_gt` (open `t < r`), since C4 already produces
strict intermediate points `t < z < s`.

### Step 5: Documentation and verification

- Updated CanonicalChain.lean comment (line 42) to reference open guard
- Updated ROADMAP.md: removed BX9/BX9' from axiom table, added removal note
- Updated ROADMAP.md BX9 discussion section to document removal
- Full `lake build` passes clean

## Sorry Count

- Sorries removed this phase: 3 (2 in Truth.lean, 1 in ChronicleToCountermodel.lean)
- No new sorries introduced
- No new axioms introduced
- Build passes clean

## Files Modified

- `Theories/Bimodal/Semantics/Truth.lean` -- fixed untl/snce cases
- `Theories/Bimodal/Theorems/TemporalDerived.lean` -- updated docstrings
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalChain.lean` -- updated comment
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- fixed BUC proof
- `specs/ROADMAP.md` -- updated axiom table and BX9 discussion
