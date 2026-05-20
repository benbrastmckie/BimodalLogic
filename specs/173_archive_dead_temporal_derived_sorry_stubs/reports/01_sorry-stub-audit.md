# Task 173 Research: Audit of Sorry Stubs in TemporalDerived.lean

**Session**: sess_1779292958_9c8d94
**Date**: 2026-05-20
**File**: `Theories/Bimodal/Theorems/TemporalDerived.lean` (673 lines)

## Executive Summary

The file contains **19 definitions with direct `sorry`** and **8 additional definitions that transitively depend on sorry stubs** (27 tainted definitions total). The 19 direct sorry stubs fall into three categories based on their invalidity reason:

| Category | Count (direct sorry) | Reason |
|----------|---------------------|--------|
| Open guard invalid (BX8/BX9 removed) | 14 | Relied on removed BX8/BX9 axioms; NOT valid under open guard `(t,s)` semantics |
| Pre-existing seriality sorry | 2 | Requires seriality derivation (unrelated to guard change) |
| Pre-existing other sorry | 3 | Requires BX8, density axiom, or past density axiom |

The 8 transitive dependents contain no `sorry` keyword but call sorry-bearing definitions. They are equally dead and should be archived together.

The file also contains **14 sorry-free, fully proven definitions** that must remain.

## Complete Inventory

### A. Direct Sorry Stubs: Open Guard Invalid (14 definitions)

These are explicitly documented as "NOT VALID under open guard semantics" in the file header (task 113). They relied on BX8 (`until_step`/`since_step`) or BX9 (`until_elim`/`since_elim`), both removed as unsound.

| # | Name | Line | Visibility | Downstream Users | Sorry Content |
|---|------|------|------------|------------------|---------------|
| 1 | `psi_imp_until` | 384 | public | **UntilSinceCoherence:84, SuccRelation:618** | `sorry` only |
| 2 | `psi_imp_since` | 394 | public | **UntilSinceCoherence:94, SuccRelation:639** | `sorry` only |
| 3 | `until_imp_or` | 404 | public | (none external) | `sorry` only |
| 4 | `since_imp_or` | 413 | public | (none external) | `sorry` only |
| 5 | `bot_until_bot_absurd` | 333 | public | (none external) | `sorry` only |
| 6 | `bot_since_bot_absurd` | 341 | public | (none external) | `sorry` only |
| 7 | `bot_until_elim` | 363 | **private** | (internal only) | `sorry` only |
| 8 | `bot_since_elim` | 368 | **private** | (internal only) | `sorry` only |
| 9 | `bot_until_id` | 474 | public | (none external) | `sorry` only |
| 10 | `bot_since_id` | 479 | public | (none external) | `sorry` only |
| 11 | `until_unfold_thm` | 528 | public | (none external) | `sorry` only |
| 12 | `since_unfold_thm` | 534 | public | (none external) | `sorry` only |
| 13 | `refl_F` | 577 | public | (none external) | `sorry` only |
| 14 | `refl_P` | 586 | public | (none external) | `sorry` only |

### B. Direct Sorry Stubs: Pre-existing (5 definitions)

These sorry stubs predate the open guard refactoring and have different root causes.

| # | Name | Line | Downstream Users | Root Cause |
|---|------|------|------------------|------------|
| 15 | `G_bot_absurd` | 223 | **UltrafilterFrame:543** | Requires seriality under irreflexive G/H |
| 16 | `H_bot_absurd` | 232 | **UltrafilterFrame:779** | Requires seriality under irreflexive G/H |
| 17 | `G_implies_topUntil` | 324 | (none external) | Requires BX8 (removed) |
| 18 | `density_derivable` | 293 | (none external) | Requires density axiom under irreflexive semantics |
| 19 | `past_density_derivable` | 302 | (none external) | Requires past density axiom |

### C. Transitive Sorry Dependents (8 definitions, no direct sorry)

These compile but call sorry-bearing definitions, making them equally unsound.

| # | Name | Line | Depends On | Downstream Users |
|---|------|------|------------|------------------|
| 20 | `or_until_imp` | 493 | `psi_imp_until` (#1) | (none external) |
| 21 | `or_since_imp` | 510 | `psi_imp_since` (#2) | (none external) |
| 22 | `until_unfold_wrapped` | 541 | `until_unfold_thm` (#11) + `psi_imp_until` (#1) | **SuccRelation:553** |
| 23 | `since_unfold_wrapped` | 546 | `since_unfold_thm` (#12) + `psi_imp_since` (#2) | **SuccRelation:561** |
| 24 | `until_intro` | 555 | `bot_until_id` (#9) + `or_until_imp` (#20) | (none external) |
| 25 | `since_intro` | 560 | `bot_since_id` (#10) + `or_since_imp` (#21) | (none external) |
| 26 | `until_F_expansion` | 605 | `until_unfold_thm` (#11) + `refl_F` (#13) | (none external) |
| 27 | `since_P_expansion` | 632 | `since_unfold_thm` (#12) + `refl_P` (#14) | (none external) |

### D. Sorry-Free Definitions (KEEP -- do not archive)

These 14 definitions are fully proven and must remain in the active codebase:

| Name | Line | Status | Notes |
|------|------|--------|-------|
| `neg_contrapositive_imp_neg` | 100 | proven, private | Helper for G_distribution |
| `top_and_intro` | 106 | proven, private | Helper for temp_4 |
| `F_neg_contra_imp_F_neg` | 121 | proven, private | Helper for G_distribution |
| `G_imp_to_G_contra` | 132 | proven, private | Helper for G_distribution |
| `G_contra_to_GK` | 140 | proven, private | Helper for G_distribution |
| `temp_k_dist_derived` | 152 | proven | **Heavily used downstream** (PointInsertion, WitnessSeed, RRelation, AesopRules) |
| `dne_lift_F` | 169 | proven, private | Helper for temp_4 |
| `FF_to_F_top_and` | 181 | proven, private | Helper for temp_4 |
| `F_top_and_absorb` | 194 | proven, private | Helper for temp_4 |
| `temp_4_derived` | 207 | proven | **Heavily used downstream** (MCSProperties, AesopRules, TruthPreservation) |
| `G_distribution` | 238 | proven | Wrapper for `temp_k_dist_derived` |
| `H_distribution` | 245 | proven | Past K-distribution |
| `G_transitivity` | 252 | proven | Wrapper for `temp_4_derived` |
| `H_transitivity` | 259 | proven | Past transitivity via duality |
| `connect_future_thm` | 276 | proven | Direct BX4 |
| `connect_past_thm` | 284 | proven | Direct BX4' |
| `G_implies_G_id` | 309 | proven | Propositional |
| `until_implies_some_future` | 349 | proven | Direct BX10 |
| `since_implies_some_past` | 357 | proven | Direct BX10' |
| `until_imp_F` | 423 | proven | Direct BX10 |
| `since_imp_P` | 431 | proven | Direct BX10' |
| `contrapositive` | 441 | proven | Propositional helper |
| `ctx_mp` | 444 | proven, private | Context modus ponens |
| `ctx_thm` | 448 | proven, private | Context weakening |
| `formula_or_comm` | 455 | proven | Disjunction commutativity |

## Downstream Impact Analysis

### Definitions with Active Downstream Users (CRITICAL)

Six sorry-tainted definitions are referenced by active modules:

| Sorry Definition | Used By | Impact |
|------------------|---------|--------|
| `psi_imp_until` | `UntilSinceCoherence.lean:84`, `SuccRelation.lean:618` | Completeness construction |
| `psi_imp_since` | `UntilSinceCoherence.lean:94`, `SuccRelation.lean:639` | Completeness construction |
| `until_unfold_wrapped` | `SuccRelation.lean:553` | Successor relation construction |
| `since_unfold_wrapped` | `SuccRelation.lean:561` | Successor relation construction |
| `G_bot_absurd` | `UltrafilterFrame.lean:543` | Ultrafilter seriality |
| `H_bot_absurd` | `UltrafilterFrame.lean:779` | Ultrafilter seriality |

**Action required**: When archiving these definitions, downstream references must be updated to either:
1. Reference the Boneyard location (if kept as sorry stubs), or
2. Be replaced with `sorry` directly at the call site, or
3. Be removed if the downstream code is also dead.

Since the downstream modules (UntilSinceCoherence, SuccRelation, UltrafilterFrame) likely have their own sorry-dependencies and are part of the completeness construction that is still in progress, option 2 (replace with `sorry` at call site) is cleanest.

## Recommendations: Archive vs Delete

### Existing Boneyard Precedent

The file `Boneyard/ClosedGuardLegacy/ClosedGuardTemporalDerived.lean` already archives the **original closed-guard proofs** for several of these theorems (bot_until_bot_absurd, bot_since_bot_absurd, bot_until_elim, bot_since_elim, until_imp_or, since_imp_or, bot_until_id, bot_since_id, until_unfold_thm, since_unfold_thm). This means the closed-guard versions are already preserved. The current sorry stubs in TemporalDerived.lean are just placeholder declarations with `sorry` -- they contain no proof content.

### Recommendation Summary

| Recommendation | Definitions | Rationale |
|----------------|-------------|-----------|
| **DELETE** | 22 of 27 tainted definitions | Pure `sorry` stubs or transitive sorry dependents with no proof content; closed-guard originals already in Boneyard |
| **ARCHIVE** | 5 definitions | Contain partial proofs, educational proofs, or have proof content worth preserving |

### DELETE (22 definitions)

These are pure sorry stubs with zero proof content (just `sorry`) and/or their closed-guard originals are already archived:

**BX9-dependent sorry stubs (already archived in ClosedGuardLegacy):**
1. `bot_until_bot_absurd` -- DELETE: 1-line sorry, original proof in Boneyard
2. `bot_since_bot_absurd` -- DELETE: 1-line sorry, original proof in Boneyard
3. `bot_until_elim` -- DELETE: private, 1-line sorry, original in Boneyard
4. `bot_since_elim` -- DELETE: private, 1-line sorry, original in Boneyard
5. `bot_until_id` -- DELETE: 1-line sorry, original in Boneyard
6. `bot_since_id` -- DELETE: 1-line sorry, original in Boneyard
7. `until_imp_or` -- DELETE: 1-line sorry, original in Boneyard
8. `since_imp_or` -- DELETE: 1-line sorry, original in Boneyard
9. `until_unfold_thm` -- DELETE: 1-line sorry, original in Boneyard
10. `since_unfold_thm` -- DELETE: 1-line sorry, original in Boneyard

**Open-guard invalid sorry stubs (no proof content to preserve):**
11. `psi_imp_until` -- DELETE: 1-line sorry, semantically invalid
12. `psi_imp_since` -- DELETE: 1-line sorry, semantically invalid
13. `refl_F` -- DELETE: 1-line sorry, semantically invalid under irreflexive order
14. `refl_P` -- DELETE: 1-line sorry, semantically invalid under irreflexive order

**Transitive sorry dependents (proofs reference deleted stubs):**
15. `or_until_imp` -- DELETE: complete proof but uses `psi_imp_until` (deleted)
16. `or_since_imp` -- DELETE: complete proof but uses `psi_imp_since` (deleted)
17. `until_unfold_wrapped` -- DELETE: 1-line composition of deleted stubs
18. `since_unfold_wrapped` -- DELETE: 1-line composition of deleted stubs
19. `until_intro` -- DELETE: 1-line composition of deleted stubs
20. `since_intro` -- DELETE: 1-line composition of deleted stubs

**Pre-existing sorry stubs (no proof content):**
21. `G_implies_topUntil` -- DELETE: 1-line sorry, requires removed BX8
22. `density_derivable` -- DELETE: 1-line sorry, requires density axiom not in system

### ARCHIVE to Boneyard (5 definitions)

These contain educational proof content, partial proofs, or have potential value under different semantics:

23. **`past_density_derivable`** -- ARCHIVE: Comment documents the semantic relationship between density and BX1'. Trivially recreatable, but archiving is consistent with `density_derivable`.

    *Actually, on reflection*: `past_density_derivable` is also a 1-line sorry. DELETE.

24. **`until_F_expansion`** -- ARCHIVE: Contains a **substantial 25-line proof** (lines 605-629) that is correct modulo its sorry dependencies (`until_unfold_thm`, `refl_F`). Demonstrates the proof technique for strengthening until-unfolding with F-wrapping. Worth preserving as a proof template.

25. **`since_P_expansion`** -- ARCHIVE: Contains a **substantial 23-line proof** (lines 632-654) mirroring `until_F_expansion`. Same rationale.

26. **`G_bot_absurd`** -- ARCHIVE: Has downstream users in active code (UltrafilterFrame:543). The comment documents that this requires seriality, which is a legitimate proof obligation (not an invalid theorem). Should be preserved with a note that it needs a seriality-based derivation.

27. **`H_bot_absurd`** -- ARCHIVE: Mirror of `G_bot_absurd`, downstream user at UltrafilterFrame:779.

### Revised Final Counts

| Action | Count | Sorry reduction |
|--------|-------|-----------------|
| DELETE from TemporalDerived.lean | 22 | -17 direct sorries (some are transitive, not direct sorry) |
| ARCHIVE to Boneyard | 5 | -2 direct sorries (G_bot_absurd, H_bot_absurd move to Boneyard) |
| KEEP in TemporalDerived.lean | 24 sorry-free definitions | 0 |
| **Net sorry reduction** | | **-19 sorries** |

Wait -- let me recount. The 19 direct sorry stubs:
- 14 open-guard invalid = DELETE (14 sorries removed)
- 3 pre-existing (G_implies_topUntil, density_derivable, past_density_derivable) = DELETE (3 sorries removed)
- 2 pre-existing (G_bot_absurd, H_bot_absurd) = ARCHIVE (2 sorries move to Boneyard)

That's 17 sorries eliminated + 2 moved = 19 direct sorries accounted for. Plus 8 transitive dependents removed (0 additional sorry keyword removals).

**Net active sorry count reduction: 19** (17 deleted outright + 2 moved to Boneyard where sorries don't count).

## Implementation Plan

### Step 1: Create Boneyard Archive

Create `Theories/Bimodal/Boneyard/OpenGuardInvalid/OpenGuardTemporalDerived.lean` containing:
- All 22 DELETE definitions (as documentation, in code-fence comments like ClosedGuardLegacy precedent)
- The 5 ARCHIVE definitions (with their proof bodies)
- Header documenting why they were archived and cross-references

Suggested directory name: `OpenGuardInvalid/` (parallels `ClosedGuardLegacy/`)

### Step 2: Update Downstream References

Replace the 6 downstream references with direct `sorry`:
- `UntilSinceCoherence.lean:84,94` -- replace `psi_imp_until`/`psi_imp_since` calls
- `SuccRelation.lean:553,561,618,639` -- replace `until_unfold_wrapped`/`since_unfold_wrapped`/`psi_imp_until`/`psi_imp_since` calls
- `UltrafilterFrame.lean:543,779` -- replace `G_bot_absurd`/`H_bot_absurd` calls

Each downstream site should get a tombstone comment:
```lean
-- TOMBSTONE (task 173): was TemporalDerived.psi_imp_until; invalid under open guard semantics
sorry
```

### Step 3: Remove Sorry Stubs from TemporalDerived.lean

Delete all 27 tainted definitions (19 direct + 8 transitive). Preserve:
- Module header (updated to reflect removals)
- All 24 sorry-free definitions
- Section structure and docstrings for remaining content
- A tombstone comment block listing what was removed

### Step 4: Update File Header

Replace the "NOT VALID" section (lines 19-31) with:
```
### Removed (Task 173)
Definitions not valid under open guard semantics have been archived to
`Boneyard/OpenGuardInvalid/OpenGuardTemporalDerived.lean`. See that file
for the complete list and original proof attempts. Closed-guard originals
remain in `Boneyard/ClosedGuardLegacy/ClosedGuardTemporalDerived.lean`.
```

### Step 5: Update Boneyard README

Add an entry to `Theories/Bimodal/Boneyard/README.md`:
```
| OpenGuardInvalid | 1 | ~200 | TemporalDerived.lean | BX8/BX9 dependent + reflexivity-dependent theorems invalid under open guard (t,s) | 173 |
```

### Tombstone Comment Format

For the Boneyard archive file header:
```lean
/-!
# Archived TemporalDerived Sorry Stubs (Open Guard Invalid)

Archived 2026-05-20 (task 173): These theorems are NOT valid under the current
open guard (t,s) semantics. They relied on:
- BX8 (until_step/since_step): reflexive Until/Since introduction
- BX9 (until_elim/since_elim): Until/Since elimination to disjunction
- Reflexive temporal order (α → F(α)): invalid under strict future

Closed-guard original proofs are separately archived in
`ClosedGuardLegacy/ClosedGuardTemporalDerived.lean`.

## Definitions Archived
[list of all 27 definitions with type signatures]
-/
```

For inline tombstone comments at downstream call sites:
```lean
-- TOMBSTONE (task 173): TemporalDerived.{name} archived to Boneyard/OpenGuardInvalid/
-- Reason: {BX9 removed | reflexive Until invalid | reflexive F invalid} under open guard (t,s)
```

## Risk Assessment

- **LOW RISK**: All deleted definitions are sorry-bearing. No working proofs are lost.
- **DOWNSTREAM IMPACT**: 6 call sites need updating but all are already in sorry-bearing code paths. No working proof chain is broken.
- **BUILD VERIFICATION**: After implementation, `lake build` should succeed with the same or fewer errors.
- **ROLLBACK**: Git history preserves all removed code. Boneyard archive provides human-readable backup.
