# Implementation Summary: Task 268 — Reynolds Pipeline Bridge

## Status: PARTIAL

### Completed
- **Phase 1**: Archive dead BX pipeline code (COMPLETED)
  - Moved `ReynoldsModelSurgery.lean` to `Theories/Bimodal/Boneyard/BXPipelineDeadCode/`
  - Annotated dead code sections in `ChronicleToCountermodel.lean` and `Transfer.lean`
  - Build passes (1682 jobs, zero errors)

### Blocked
- **Phase 2**: Fix `chronicle_gap_contradiction` (BLOCKED)
  - The plan's approach via `gap_contradicts_prior` from `GoodStructuresModelSurgery.lean` is fundamentally inapplicable
  - **Root cause**: `contemp_equiv sig k M a b` is trivially true for ALL bounded subintervals at ANY depth k with ANY MonadicSignature. This is because any bounded sub-subinterval `[c,d]` with carrier `{x | c <= x <= d}` is k-equivalent to a Z-interval structure (via `finite_structures_good` for finite intervals, and k-type matching for infinite intervals). Therefore `h_bounded_above` — the hypothesis required by `gap_contradicts_prior` — is never satisfiable.
  - **Implication**: The entire `contemp_equiv` framework only detects differences between unbounded structures, not within bounded subintervals of a larger structure.
- **Phase 3**: Wire downstream (NOT STARTED, depends on Phase 2)
- **Phase 4**: Full build verification (NOT STARTED, depends on Phase 3)

### What Remains
Two alternative proof approaches were identified:

1. **Path A: Omega-chain stage induction (~300-600 lines)**
   - Prove `limitDomSubtype_isSuccArchimedean` directly by induction on `omega_chain_val` stages
   - For any a, b in `limit_dom`, find stage N where both appear
   - Show the finite stage-N domain is archimedean, and the limit succ function agrees with stage-N succ

2. **Path B: Connectivity lemma (~200-400 lines)**
   - Prove `limit_dom` is order-connected: the omega-chain construction never creates disjoint components
   - Each stage extends existing connected components rather than creating new ones

Both bypass `chronicle_gap_contradiction` and `gap_contradicts_prior` entirely.

### Files Modified
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/ReynoldsModelSurgery.lean` — moved to Boneyard
- `Theories/Bimodal/Boneyard/BXPipelineDeadCode/ReynoldsModelSurgery.lean` — new Boneyard location
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` — updated docstrings
- `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean` — annotated deprecated code

### Sorry Impact
- No new sorries introduced
- No existing sorries removed
- The sorry at `chronicle_gap_contradiction` remains, propagating through `succ_cofinal -> limitDomSubtype_isSuccArchimedean -> succ_embed_surjective -> completeness_discrete`

### Plan Deviations
All Phase 2 tasks were skipped because the model surgery approach is fundamentally blocked. The plan's assumption that `gap_contradicts_prior` could resolve the sorry was incorrect — `contemp_equiv` is trivially true for bounded subintervals, making the approach inapplicable regardless of MCS equality or signature choice.
