# Phase 2 Handoff -- Archimedean Bypass (v6 Plan)

## Session
- Session ID: sess_1780082532_cfce4b
- Date: 2026-05-29
- Phase: 2 of v6 plan (partial, with major deviation)

## Key Achievement

Discovered and implemented an archimedean bypass that makes Phases 2-4 of the
v6 plan (Reynolds Lemmas 6-13, Theorem 14) unnecessary for the completeness
pipeline. The chronicle domain bundles `IsSuccArchimedean`, so
`one_class_archimedean` (trivial proof using finite subintervals) replaces
`one_class` (which needed `no_gaps_discrete` and the full Reynolds argument).

## Sorry Sites Closed

1. **ShiftAndGlue.lean:984** (`chronicle_is_good_direct` semantic Prior-UZ) -- CLOSED
2. **ShiftAndGlue.lean:990** (`chronicle_is_good_direct` semantic Prior-SZ) -- CLOSED

Both closed by replacing `one_class` call with `one_class_archimedean`.

## Sorry Sites Remaining

3. **Transfer.lean:866** (`countermodel_discrete_reynolds` pipeline packaging) -- OPEN
   - Needs: Z.lo = none proof; TaskModel with position-dependent valuation;
     truth_at <-> temporal_truth inductive correspondence
   - Estimated: 150-200 lines, architecturally non-trivial

4. **GoodStructures.lean:842** (`no_gaps_discrete` general case) -- OPEN but NOT on critical path
   - Would need full Reynolds Lemmas 6-13 (~950 lines)
   - No longer called from `chronicle_is_good_direct`

## Axiom Status

- `chronicle_is_good_direct`: sorry-free [propext, Classical.choice, Quot.sound]
- `countermodel_discrete_reynolds`: has sorryAx (Transfer.lean:866)
- `completeness_discrete`: has sorryAx (from enriched path, NOT from our changes)

## Next Action

Close Transfer.lean:866 to make `countermodel_discrete_reynolds` sorry-free,
then rewire `completeness_discrete` to use it. Key steps:
1. Prove Z-interval from `very_good_implies_good` is unbounded
2. Build TaskFrame with WorldState = (sig.preds -> Prop)
3. Build TaskModel with valuation = function application  
4. Prove truth_at <-> temporal_truth by formula induction
5. Rewire `completeness_discrete` to use `countermodel_discrete_reynolds`

## Files Modified This Session

- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/ShiftAndGlue.lean` (modified)
- `specs/202_reynolds_k_equivalence_bypass/plans/06_reynolds-theorem-14-plan.md` (updated)
