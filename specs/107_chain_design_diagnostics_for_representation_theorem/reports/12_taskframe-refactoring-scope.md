# TaskFrame AddCommGroup Refactoring: Scoping Report

## Executive Summary

The `[AddCommGroup D]` constraint on `TaskFrame D` is **load-bearing in exactly 5 locations** and **incidentally carried in ~40 locations**. The group operations (subtraction, negation, addition) are **essentially used** in:

1. **TaskFrame axioms** themselves (nullity_identity uses `0`, forward_comp uses `+` and `0 <=`, converse uses `-d`)
2. **WorldHistory.respects_task** (uses `t - s`)
3. **WorldHistory.time_shift** (uses `+ Delta`, `- Delta`, `add_sub_cancel`, `neg_add_cancel`)
4. **time_shift_preserves_truth** (uses `y - x`, `x - y`, `-(x-y)`, extensive group arithmetic)
5. **ParametricHistory.parametric_to_history** (uses `t - s`, `sub_pos`, `sub_nonneg`)

Removing `AddCommGroup` requires replacing the **duration-based** task relation `task_rel w d u` with a **pair-based** formulation, and replacing the time-shift mechanism. This is a **big-bang refactoring** that touches every layer of the semantic stack.

## 1. File-by-File Change List

### Layer 1: Core Semantics (ESSENTIAL uses -- must change)

#### `Semantics/TaskFrame.lean` (lines 93-302)
- **Line 93**: `structure TaskFrame (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]` -- STRUCTURE DEFINITION
- **Line 97**: `task_rel : WorldState -> D -> WorldState -> Prop` -- uses duration `d : D`
- **Line 104**: `nullity_identity : ... task_rel w 0 u <-> w = u` -- uses `0 : D` (additive identity)
- **Line 114**: `forward_comp : ... 0 <= x -> 0 <= y -> task_rel w x u -> task_rel u y v -> task_rel w (x + y) v` -- uses `+`, `0 <=`
- **Line 122**: `converse : ... task_rel w d u <-> task_rel u (-d) w` -- uses negation `-d`
- **Line 126**: `variable {D : Type*} [AddCommGroup D] ...` -- carried constraint
- **Lines 133-159**: `nullity`, `backward_comp` -- use `0`, `-x`, `-y`, `neg_nonneg`, `neg_add_rev`, `add_comm`
- **Lines 167, 180, 211**: `trivial_frame`, `identity_frame`, `nat_frame` -- use `0`, `-`, `neg_eq_zero`
- **Lines 284, 291**: `FiniteTaskFrame` -- carried constraint
- **Classification**: **ESSENTIAL** -- group operations are structurally embedded in the task relation and its axioms
- **Estimated changes**: ~100 lines (complete rewrite of structure + derived theorems)

#### `Semantics/WorldHistory.lean` (lines 69-418)
- **Line 69**: `structure WorldHistory ... [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]` -- STRUCTURE DEFINITION
- **Line 97**: `respects_task : ... s <= t -> F.task_rel (states s hs) (t - s) (states t ht)` -- uses `t - s`
- **Lines 238-260**: `time_shift` -- uses `+ Delta`, `add_comm`, `add_le_add_right`, `add_sub_add_right_eq_sub`
- **Lines 273-287**: `time_shift_inverse_domain` -- uses `add_assoc`, `neg_add_cancel`, `add_zero`
- **Lines 306-313**: `time_shift_time_shift_states` -- uses `add_assoc`, `neg_add_cancel`, `add_zero`
- **Lines 326-351**: Various time_shift lemmas -- all use group arithmetic
- **Lines 370-415**: `neg_lt_neg_iff`, `neg_le_neg_iff`, `neg_neg_eq`, `neg_injective` -- all use group negation
- **Classification**: **ESSENTIAL** -- `respects_task` and `time_shift` fundamentally use subtraction and addition
- **Estimated changes**: ~150 lines (rewrite respects_task, time_shift, all derived lemmas)

#### `Semantics/Truth.lean` (lines 89-643)
- **Line 89**: `variable {D : Type*} [AddCommGroup D] ...` -- carried constraint
- **Lines 119-130**: `truth_at` definition -- does NOT use group ops directly (only `<` on D)
- **Lines 140-231**: Truth theorem lemmas -- carried constraint, no group ops used
- **Lines 369-638**: `time_shift_preserves_truth` -- **MASSIVELY** uses group ops: `add_sub`, `add_sub_cancel_left`, `sub_lt_sub_right`, `add_lt_add_right`, `sub_sub_cancel`, `neg_sub`, `sub_add_cancel`, etc. (~270 lines of dense group arithmetic)
- **Classification**: **MIXED** -- `truth_at` itself is INCIDENTAL (only needs `<`), but `time_shift_preserves_truth` is ESSENTIAL
- **Estimated changes**: ~280 lines (rewrite time_shift_preserves_truth entirely)

#### `Semantics/TaskModel.lean` (lines 43-90)
- **Line 43**: `structure TaskModel ... [AddCommGroup D] ...` -- carried constraint
- **Line 53**: `variable {D : Type*} [AddCommGroup D] ...` -- carried constraint
- **Line 90**: `abbrev FiniteTaskModel ...` -- carried constraint
- **Classification**: **INCIDENTAL** -- no group ops used in any field or proof
- **Estimated changes**: ~5 lines (change constraint declarations)

#### `Semantics/Validity.lean` (lines 74-256)
- **Lines 74, 98, 123, 132, 148, 163, 181, 248, 256**: Many `AddCommGroup D` declarations
- **Classification**: **INCIDENTAL** -- all are parameter/variable declarations; no group ops in proofs
- **Estimated changes**: ~15 lines (change constraint declarations)

### Layer 2: Parametric Algebraic Infrastructure (ESSENTIAL uses)

#### `Metalogic/Algebraic/ParametricCanonical.lean` (lines 72-244)
- **Line 72**: `variable {D : Type*} [AddCommGroup D] ...`
- **Lines 84-88**: `parametric_canonical_task_rel` -- uses `d > 0`, `d < 0`, `d = 0` (needs `LinearOrder`, not group)
- **Lines 100-149**: `parametric_task_rel_forward_comp` -- uses `add_pos`, `add_zero`, `zero_add`, `lt_irrefl` -- needs `0 <=`, `+`, `0`
- **Lines 160-183**: `parametric_task_rel_converse` -- uses `neg_neg_of_pos`, `neg_pos_of_neg`, `neg_zero` -- needs negation
- **Line 198**: `ParametricCanonicalTaskFrame D` -- produces `TaskFrame D`
- **Classification**: **ESSENTIAL** -- task_rel definition uses sign comparison, forward_comp uses addition, converse uses negation
- **Estimated changes**: ~80 lines (restructure to match new TaskFrame)

#### `Metalogic/Algebraic/ParametricHistory.lean` (lines 41-173)
- **Line 41**: `variable {D : Type*} [AddCommGroup D] ...`
- **Lines 61-82**: `parametric_to_history` -- uses `t - s`, `sub_pos`, `sub_nonneg`, `sub_eq_zero`
- **Lines 124-135**: `time_shift_parametric_to_history_compose` -- uses `add_assoc`, `add_comm`
- **Lines 138-140**: `parametric_to_history_eq_time_shift_zero` -- uses `add_zero`
- **Classification**: **ESSENTIAL** -- `respects_task` proof fundamentally uses duration arithmetic `t - s`
- **Estimated changes**: ~50 lines

#### `Metalogic/Algebraic/ParametricTruthLemma.lean` (lines 85-531)
- **Line 85**: `variable {D : Type*} [AddCommGroup D] ...`
- **Line 96-98**: `ParametricCanonicalTaskModel` -- carried constraint
- **Lines 219-530**: Truth lemma proofs -- mostly use MCS properties, NOT group ops
- **Line 460**: `add_sub_cancel_left t delta` -- one essential use in box case of shifted truth lemma
- **Classification**: **MOSTLY INCIDENTAL** -- only the box shifted case uses group arithmetic (via time_shift_preserves_truth)
- **Estimated changes**: ~20 lines (adjust box case after time_shift rewrite)

#### `Metalogic/Algebraic/RestrictedParametricTruthLemma.lean` (line 37)
- **Line 37**: `variable {D : Type*} [AddCommGroup D] ...` -- carried
- **Lines 104-475**: Proofs mirror ParametricTruthLemma -- same pattern
- **Line 379**: `add_sub_cancel_left t delta` -- same essential use in box case
- **Classification**: **MOSTLY INCIDENTAL** -- same as ParametricTruthLemma
- **Estimated changes**: ~20 lines

#### `Metalogic/Algebraic/ParametricRepresentation.lean` (line 96)
- **Line 96**: `variable {D : Type*} [AddCommGroup D] ...` -- carried
- **Classification**: **INCIDENTAL** -- no group ops in any proof
- **Estimated changes**: ~5 lines

### Layer 3: Soundness & Decidability

#### `Metalogic/Soundness.lean` (lines 983-1295)
- **Lines 983, 1148, 1295**: `[AddCommGroup D]` in theorem signatures -- carried constraint
- **Classification**: **INCIDENTAL** -- soundness proofs use truth_at properties, not group ops directly
- **Estimated changes**: ~10 lines (change type signatures)

#### `Metalogic/SoundnessLemmas.lean` (lines 85-92)
- **Lines 85, 92**: `[AddCommGroup D]` declarations -- carried constraint
- **Classification**: **INCIDENTAL** -- no group arithmetic in proofs
- **Estimated changes**: ~5 lines

#### `Metalogic/Decidability/FMP/Filtration.lean` (line 176)
- **Line 176**: `variable (D : Type*) [AddCommGroup D] ...`
- **Lines 214-234**: Uses `neg_eq_of_add_eq_zero_right`, `neg_nonneg`, `neg_zero` -- in filtered task_rel proofs
- **Classification**: **ESSENTIAL** -- filtration constructs a new task frame, uses group ops
- **Estimated changes**: ~30 lines

#### `Metalogic/Decidability/FMP/FMP.lean` (lines 157-165)
- **Lines 157, 165**: `[AddCommGroup D]` in signatures -- carried
- **Classification**: **INCIDENTAL** -- wraps filtration results
- **Estimated changes**: ~5 lines

#### `Metalogic/Decidability/FMP/FiniteModel.lean` (line 145)
- **Line 145**: `variable (D : Type*) [AddCommGroup D] ...` -- carried
- **Classification**: **INCIDENTAL**
- **Estimated changes**: ~3 lines

### Layer 4: Frame Conditions

#### `FrameConditions/FrameClass.lean` (many lines)
- **82, 97, 101, 118, 123, 146, 151, 162, 170, 178, 219, 227**: Many `[AddCommGroup D]` declarations
- **Classification**: **INCIDENTAL** -- these are marker classes that don't use group ops
- **Estimated changes**: ~20 lines

#### `FrameConditions/Compatibility.lean` (lines 69, 77, 86)
- `[AddCommGroup D]` in structure fields -- carried
- **Classification**: **INCIDENTAL**
- **Estimated changes**: ~5 lines

#### `FrameConditions/Soundness.lean` (lines 49-132)
- Several `[AddCommGroup D]` declarations -- carried
- **Classification**: **INCIDENTAL**
- **Estimated changes**: ~10 lines

#### `FrameConditions/Validity.lean` (lines 53-117)
- Several `[AddCommGroup D]` declarations -- carried
- **Classification**: **INCIDENTAL**
- **Estimated changes**: ~10 lines

### Layer 5: BXCanonical (Completeness Wiring)

#### `BXCanonical/RootScopedChain.lean` (line 204)
- Existential witness: `exists (D : Type) (_ : AddCommGroup D) ...` -- uses `Int`
- **Classification**: **INCIDENTAL** -- just packages the type with instances
- **Estimated changes**: ~5 lines

#### `BXCanonical/Chronicle/ChronicleToCountermodel.lean` (line 398)
- Existential witness: `exists (D : Type) (_ : AddCommGroup D) ...` -- uses `Rat`
- **Classification**: **INCIDENTAL** -- just packages the type with instances
- **Estimated changes**: ~5 lines

### Layer 6: Bundle Infrastructure

#### `Metalogic/Bundle/FMCSDef.lean`
- **Line 77**: `variable (D : Type*) [Preorder D]`
- **Classification**: **ALREADY CORRECT** -- FMCS only requires `[Preorder D]`
- **Estimated changes**: 0 lines

#### `Metalogic/Bundle/BFMCS.lean`
- **Line 53**: `variable (D : Type*) [Preorder D]`
- **Classification**: **ALREADY CORRECT** -- BFMCS only requires `[Preorder D]`
- **Estimated changes**: 0 lines

### Layer 7: Examples & Tests

#### `Examples/TemporalStructures.lean`
- **Lines 136, 235, 257, 274**: `[AddCommGroup D]` declarations
- **Classification**: **INCIDENTAL**
- **Estimated changes**: ~10 lines

#### `Tests/BimodalTest/` (various)
- Use `Int` or `Rat` which have `AddCommGroup` -- will need updated constraints
- **Estimated changes**: ~20 lines

## 2. Essential vs Incidental Classification Summary

| Category | File Count | Line Count | Group Ops Used? |
|----------|-----------|------------|-----------------|
| **ESSENTIAL** | 7 | ~690 | Yes -- subtraction, negation, addition in proofs |
| **INCIDENTAL** | ~25 | ~130 | No -- only `[AddCommGroup D]` constraint declarations |
| **ALREADY CORRECT** | 2 | 0 | N/A -- FMCSDef, BFMCS already use `[Preorder D]` |

### Essential Uses (Group Operations in Proofs)

| File | Operation | Purpose |
|------|-----------|---------|
| TaskFrame.lean | `0`, `+`, `-d`, `neg_nonneg` | Task relation axioms |
| WorldHistory.lean | `t - s`, `+ Delta`, `-Delta`, `neg_add_cancel` | respects_task, time_shift |
| Truth.lean | `y - x`, `x - y`, `-(x-y)`, `add_sub_cancel`, `sub_lt_sub` | time_shift_preserves_truth |
| ParametricCanonical.lean | `add_pos`, `neg_neg_of_pos`, `neg_pos_of_neg` | TaskFrame axiom proofs |
| ParametricHistory.lean | `t - s`, `sub_pos`, `sub_nonneg` | respects_task proof |
| ParametricTruthLemma.lean | `add_sub_cancel_left` | Box case of shifted truth lemma |
| Filtration.lean | `neg_eq_of_add_eq_zero`, `neg_nonneg` | Filtered task frame construction |

### Incidental Uses (Constraint Only, No Group Ops)

All other files (~25) only carry `[AddCommGroup D]` in variable declarations, function signatures, or structure parameters. Removing the constraint from upstream definitions would require only mechanical signature changes.

## 3. Dependency Order for Changes

The refactoring must proceed **bottom-up** through the dependency chain:

```
Phase 1: TaskFrame.lean (core structure)
    |
Phase 2: WorldHistory.lean (depends on TaskFrame)
    |
Phase 3: TaskModel.lean, Truth.lean (depend on WorldHistory)
    |
Phase 4: Validity.lean, SoundnessLemmas.lean (depend on Truth)
    |
Phase 5: ParametricCanonical.lean (depends on TaskFrame)
    |
Phase 6: ParametricHistory.lean (depends on ParametricCanonical + WorldHistory)
    |
Phase 7: ParametricTruthLemma.lean, RestrictedParametricTruthLemma.lean
    |
Phase 8: ParametricRepresentation.lean
    |
Phase 9: Soundness.lean, Decidability/, FrameConditions/
    |
Phase 10: BXCanonical/, Examples/, Tests/
```

## 4. Risk Assessment

| Risk | Severity | Mitigation |
|------|----------|------------|
| **TaskFrame axiom reformulation** | HIGH | The converse axiom `task_rel w d u <-> task_rel u (-d) w` intrinsically uses negation. Must replace with an equivalent order-based formulation. |
| **time_shift_preserves_truth breakage** | HIGH | 270 lines of dense group arithmetic must be completely rewritten. This is the single largest proof in the semantic stack. |
| **respects_task reformulation** | MEDIUM | `task_rel (states s hs) (t - s) (states t ht)` must become `task_rel_pair (states s hs) s t (states t ht)` or similar. |
| **Soundness regression** | MEDIUM | Soundness.lean is sorry-free; changes to Truth.lean could break it. |
| **Decidability regression** | MEDIUM | Filtration.lean builds a new TaskFrame; must adapt to new formulation. |
| **ParametricCanonical task_rel** | MEDIUM | The sign-based `if d > 0 then ExistsTask M N else if d < 0 then ExistsTask N M else M = N` formulation naturally maps to pairs `(s, t)` with `s < t`. |
| **Box case of shifted truth lemma** | LOW | Only 1 essential line (`add_sub_cancel_left`); rest of truth lemma uses only `<` on D. |

## 5. Recommended Approach

### Big-Bang is Required

**Incremental migration is not feasible.** The constraint change propagates through every layer simultaneously because:

1. `TaskFrame D` is imported by every semantic file
2. `WorldHistory` depends on `TaskFrame`
3. `Truth.lean` depends on both
4. All parametric infrastructure depends on all of the above

Creating a parallel `TaskFrameOrd D [LinearOrder D]` would require duplicating the ENTIRE semantic stack (WorldHistory, TaskModel, Truth, Validity, time_shift_preserves_truth, Soundness, ParametricCanonical, ParametricHistory, ParametricTruthLemma, RestrictedParametricTruthLemma, ParametricRepresentation, Decidability, FrameConditions). This is worse than modifying in place.

### Recommended Design: Pair-Based Task Relation

Replace the duration-based formulation with ordered pairs:

```lean
-- CURRENT (requires AddCommGroup)
structure TaskFrame (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] where
  WorldState : Type
  task_rel : WorldState -> D -> WorldState -> Prop
  nullity_identity : forall w u, task_rel w 0 u <-> w = u
  forward_comp : forall w u v x y, 0 <= x -> 0 <= y -> task_rel w x u -> task_rel u y v -> task_rel w (x + y) v
  converse : forall w d u, task_rel w d u <-> task_rel u (-d) w

-- PROPOSED (requires only LinearOrder)
structure TaskFrame (D : Type*) [LinearOrder D] where
  WorldState : Type
  task_rel : WorldState -> D -> D -> WorldState -> Prop  -- w, s, t, u
  identity : forall w u t, task_rel w t t u <-> w = u
  forward_comp : forall w u v s t r, s <= t -> t <= r ->
    task_rel w s t u -> task_rel u t r v -> task_rel w s r v
  converse : forall w u s t, task_rel w s t u <-> task_rel u t s w
```

**Key insight**: `task_rel w s t u` means "from world w at time s, executing until time t reaches world u". The duration `d = t - s` is implicit. The converse becomes time-reversal without needing negation.

### Corresponding Changes

- **WorldHistory.respects_task**: `s <= t -> F.task_rel (states s hs) s t (states t ht)`
- **WorldHistory.time_shift**: Shift by `Delta` maps `(s, t)` to `(s + Delta, t + Delta)` -- but this STILL needs addition. Alternative: time_shift is not needed if we reformulate the box axiom differently.

### CRITICAL ISSUE: time_shift Still Needs Group Structure

The `time_shift` mechanism and `time_shift_preserves_truth` are used for:
1. **Box soundness** (MF axiom): Proving `Box(phi) -> phi` at shifted times
2. **TF axiom soundness**: `Box(phi) -> G(Box(phi))`
3. **ShiftClosed Omega**: The canonical Omega must be shift-closed

Even with pair-based task_rel, the time_shift construction needs:
- `z + Delta` (for shifted domain)
- `(t + Delta) - (s + Delta) = t - s` (for shifted respects_task)
- `z + (-Delta) + Delta = z` (for inverse shift)

**This means the refactoring CANNOT fully eliminate group structure from the semantic layer.** The time-shift mechanism inherently requires an abelian group action on the time domain.

### Alternative: Ordered Group Action

Instead of requiring `D` itself to be an AddCommGroup, introduce a separate "shift group" `G` acting on `D`:

```lean
structure TaskFrame (D : Type*) [LinearOrder D] (G : Type*) [AddCommGroup G]
    (shift : G -> D -> D) [IsOrderedAction G D shift] where
  ...
```

But this adds complexity without clear benefit and still requires a group somewhere.

### Realistic Assessment

The `AddCommGroup` requirement on the TaskFrame domain is **not an accident**. It is mathematically load-bearing because:

1. The JPL paper specification explicitly requires D to be a "totally ordered abelian group"
2. The time-shift mechanism (essential for S5 box axiom validity) requires group translation
3. The converse axiom requires temporal symmetry via group inverse
4. The compositionality axiom requires duration addition

**The correct approach for the Burgess chronicle is NOT to weaken TaskFrame, but to:**

1. Keep `TaskFrame D [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]`
2. Use `D = Rat` for the chronicle countermodel (as currently done in ChronicleToCountermodel.lean)
3. Construct the FMCS over `Rat` where `mcs t` is defined for ALL `t : Rat` but the chronicle domain only uses finitely many points
4. The `forward_G` obligation becomes: for `s < t` in `Rat`, if `G(phi) in mcs(s)` then `phi in mcs(t)`
5. Outside `limit_dom`, the MCS assignment can be defined by "nearest point" or "constant extension"

This is exactly what the current `shifted_chronicle_fmcs` construction does: it maps ALL of `Rat` to MCSs, with the chronicle determining the MCS at points in `limit_dom` and extending to the rest of `Rat`.

## 6. Total Effort Estimate

| Approach | Effort | Risk | Benefit |
|----------|--------|------|---------|
| **Big-bang refactor** (pair-based TaskFrame) | 15-25 days | Very High | Eliminates AddCommGroup from TaskFrame |
| **Selective weakening** (TaskFrame stays, BFMCS uses Preorder) | 0 days | None | Already done -- BFMCS/FMCS already use `[Preorder D]` |
| **Order-isomorphism approach** (use Rat, extend chronicle) | 3-5 days | Medium | Works within existing infrastructure |

### Recommendation

**Do NOT refactor TaskFrame.** The AddCommGroup requirement is mathematically correct per the JPL paper. The FMCS/BFMCS infrastructure already uses only `[Preorder D]`. The correct path forward is:

1. The chronicle construction builds over `Rat` (which has `AddCommGroup`)
2. The MCS assignment extends to all of `Rat` (not just `limit_dom`)
3. The `forward_G` obligation for `Rat` is satisfied because the chronicle's temporal coherence extends monotonically
4. The truth lemma evaluates at `t = 0 : Rat`
5. The countermodel is over `D = Rat` with full `AddCommGroup` structure

This is already the architecture in `ChronicleToCountermodel.lean` lines 403-404: `D = Rat, inferInstance, inferInstance, inferInstance`.

## 7. Impact on Sorry-Free Code

| Module | Status | Impact of Refactoring |
|--------|--------|----------------------|
| Soundness.lean | Sorry-free | BROKEN if TaskFrame changes (signatures change) |
| Decidability/ | Sorry-free | BROKEN if TaskFrame changes (Filtration rewrites) |
| Theorems/ | Sorry-free | Unaffected (pure proof theory, no TaskFrame) |
| ParametricTruthLemma.lean | Sorry-free | BROKEN if time_shift_preserves_truth changes |
| ParametricCanonical.lean | Sorry-free | BROKEN (produces TaskFrame) |
| Truth.lean | Sorry-free | BROKEN (time_shift_preserves_truth rewrite) |
| WorldHistory.lean | Sorry-free | BROKEN (respects_task rewrite) |

**Conclusion**: Refactoring TaskFrame would break 7 sorry-free modules containing approximately 3000 lines of verified proofs. The risk-benefit ratio is strongly against this refactoring.
