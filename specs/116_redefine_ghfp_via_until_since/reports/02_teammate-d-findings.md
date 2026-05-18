# Teammate D Findings: Strategic Horizons — Task 116

**Task**: 116 — Redefine G, H, F, P in terms of U and S following Burgess 1982
**Date**: 2026-05-18
**Angle**: Long-term alignment, strategic direction, cross-task coordination
**Confidence Level**: High (most findings grounded in code and roadmap analysis)

---

## Key Findings

### 1. Task Ordering: 116 Should Proceed NOW — Not After 115/124/126

The ROADMAP.md Phase 2 suggests a sequence: task 126 (frame hierarchy) → task 124 (remove TF) → task 115 (remove A4a) → task 116 (redefine G/H/F/P). However:

- **Tasks 115 and 124 are already completed/archived** — they no longer appear in TODO.md or state.json's active projects. The roadmap text is stale.
- **Task 126 (frame hierarchy) is ABANDONED** — status [ABANDONED] in TODO.md. Its prerequisites changed with the chronicle approach.
- **Task 116 has no blocking dependencies** — its only dependency (task 107) is completed.

**More importantly**: Task 157 (expressive completeness of {S,U}) **explicitly depends on task 116** (see `specs/157_expressive_completeness_su_integer/reports/10_task116-dependency-analysis.md`). Task 157's Phase 3 hierarchy proof is structurally blocked by the existence of `all_future`/`all_past` constructors in the Formula type. The 10 research reports and 8 plan versions for task 157 document repeated failures caused by this.

**Recommendation**: Task 116 should proceed immediately. It unblocks task 157, which is high-priority and has been blocked for weeks.

### 2. Massive Scope Undercount: 83 Files, 1891 References (Not 70/1416)

The original research report identified ~70 files with ~1416 references. The actual count is:
- **83 files** with `all_future`/`all_past` references (non-Boneyard)
- **1891 total references** across those files

The gap comes primarily from the **WeakCanonical/Separation/** module (task 157's separation theorem), which has **492 references** across 15 files:

| File | Refs | Notes |
|------|------|-------|
| Separation/Hierarchy.lean | 115 | Hierarchy theorem — callback circularity site |
| Separation/TemporalClosure.lean | 111 | Temporal closure operations |
| ReflexiveCanonical.lean | 84 | Weak canonical model |
| Separation/Defs.lean | 45 | Core definitions including `int_truth`, `is_syntactically_separated` |
| ExpressiveCompleteness.lean | 25 | Top-level expressive completeness |
| Others (10 files) | ~112 | Various support files |

Also missed: `UltrafilterFrame.lean` (82 refs, untracked new file from task 163).

**Impact**: The original 10-phase plan does not include ANY phase for WeakCanonical. This is a missing phase that must be added.

### 3. `@[match_pattern]` — A Crucial Lean 4 Feature the Plan Should Use

Lean 4 supports `@[match_pattern]` (confirmed in Mathlib usage: `Mathlib/SetTheory/Lists.lean`, `Mathlib/Algebra/Symmetrized.lean`, etc.). This attribute allows a `def` to be used in pattern matching positions.

If we define:
```lean
@[match_pattern]
def all_future (φ : Formula) : Formula := (some_future φ.neg).neg

@[match_pattern]
def all_past (φ : Formula) : Formula := (some_past φ.neg).neg
```

Then existing pattern matches like:
```lean
| .all_future ψ => ...
```
**might still compile** (or could be adapted to use the `@[match_pattern]` definitions). This would dramatically reduce the refactoring surface.

**Critical caveat**: `@[match_pattern]` works for simple constructors-of-a-different-type wrapping (like `Lists.atom` wrapping a sigma type). For `all_future`, which expands to `(untl φ.neg top).neg` = `(untl (φ.imp bot) (bot.imp bot)).imp bot`, the pattern is complex. **This needs prototyping before committing** — it may not work for the nested expansion, or Lean may not be able to discriminate during pattern matching (since `neg(untl(neg(φ), top))` overlaps with general `imp` patterns).

**Even if `@[match_pattern]` doesn't work for pattern matching**, it should be explored for the `def` declarations. Lean 4's elaborator may provide partial support that reduces the work.

### 4. The ConservativeExtension Module Has a STRUCTURAL PROBLEM

`ExtFormula` is a separate inductive type that:
- **Has** `all_past`/`all_future` as constructors
- **Does NOT have** `untl`/`snce` constructors at all

This means after task 116:
1. `Formula` will have 6 constructors: `{atom, bot, imp, box, untl, snce}`
2. `ExtFormula` will have 6 constructors: `{atom, bot, imp, box, all_past, all_future}`
3. The `embedFormula` function cannot translate `untl`/`snce` formulas

The current `embedFormula` translates `Formula.all_past → ExtFormula.all_past` etc. After task 116, `Formula.all_past` is a `def` that expands to `(snce φ.neg top).neg`. But `ExtFormula` has no `snce`.

**Options**:
- **(A) Add `untl`/`snce` constructors to `ExtFormula`** and remove `all_past`/`all_future` (mirror the main Formula change). This is the consistent approach.
- **(B) Redefine `ExtFormula` as a type alias** for `Formula` parameterized by atom type. This eliminates the parallel type entirely.
- **(C) Remove the ConservativeExtension module** if it's no longer needed. Check if any live code depends on it.

**Recommendation**: Option (A) is safest. Option (B) is better long-term but a larger change. Check downstream usage before deciding.

### 5. The Separation Module WANTS This Change

Task 157's dependency analysis (report 10) is unambiguous: the `all_future`/`all_past` constructors in `Formula` are the root cause of a structural circularity that has blocked task 157 through 8 plan versions. After task 116:

- `is_syntactically_separated` (Defs.lean:148-149) loses its `all_past`/`all_future` cases
- The hierarchy theorem callback circularity vanishes
- The formalization matches GHR94's language exactly: `{S, U, ¬, ∧}`

**However**: The Separation module has `int_truth` (Defs.lean:42-51) which pattern-matches on all 8 constructors. After task 116, it will have 6 cases. The `all_past`/`all_future` cases currently define the semantics directly:
```lean
| .all_past φ => ∀ s : ℤ, s < t → int_truth M s φ
| .all_future φ => ∀ s : ℤ, t < s → int_truth M s φ
```
These will need to be replaced with semantic equivalence lemmas (similar to Phase 5's `truth_at` changes). The equivalence must go through `untl`/`snce` semantics with the `top` guard.

### 6. Algebraic Impact: The STSA Typeclass Uses Abstract G/H — Minimal Disruption

The `STSA` typeclass (TenseS5Algebra.lean) defines `G` and `H` as **abstract operators** on the algebra, not as formula constructors:
```lean
class STSA (α : Type*) extends BooleanAlgebra α where
  G : α → α
  H : α → α
  ...
```

The `LindenbaumAlg` instance maps `G` to `all_future` via the quotient. After task 116, `all_future` is a `def`, so the instance should still work — it produces `all_future φ` which now expands differently, but the algebraic properties are proved at the quotient level.

**Impact**: Low for the STSA typeclass itself. Medium for `UltrafilterFrame.lean` (82 refs) which uses `φ.all_future` as method syntax — this will still work since `all_future` is a `def` on `Formula`.

**Key risk**: Proofs in `UltrafilterFrame.lean` that use `temp_k_dist` and `temp_4` axioms (which are being removed). The file already has 18 sorries from prior BX axiom removal. Task 116's axiom changes will add more sorries to this file — coordinate with task 125 (J-T representation) to resolve them.

### 7. Publication Strategy: This Refactor IMPROVES Publishability

**Positive effects**:
- Reduces `Formula` from 8 to 6 constructors — simpler and matches standard presentations (Burgess 1982, GHR94)
- Removes 2 axioms (temp_k_dist, temp_4) — smaller axiom system is more elegant
- Enables task 157 (expressive completeness) — a significant publication-worthy result
- Aligns with the "minimal primitive" aesthetic: `{S, U, □, →, ⊥}` is the canonical set

**Negative effects**:
- Temporary sorry proliferation in `UltrafilterFrame.lean` (but this file already has 18 sorries)
- `SubformulaClosure` complexity increase (but this is theoretically correct — GHR94 doesn't use G/H as primitives)
- ~1891 reference changes across 83 files — risk of introducing new sorries

**Net assessment**: Strongly positive for publication. The refactoring aligns the formalization with the standard mathematical treatment.

### 8. Naming Convention Opportunity

After the refactor, `all_future`/`all_past`/`some_future`/`some_past` become `def`s. Consider adding short aliases:
```lean
abbrev G := all_future
abbrev H := all_past
abbrev F := some_future
abbrev P := some_past
```

This would improve proof readability — matching the one-letter notation used in the literature and making proofs more compact. These are the standard symbols across all temporal logic literature.

**However**: The project currently uses descriptive names consistently (`box` not `□`, `all_future` not `G`). Adding aliases would create two naming styles. Defer this to a style cleanup task unless there's a clear benefit now.

---

## Recommended Approach

### 1. Proceed with task 116 immediately
It unblocks task 157 (high-priority, weeks blocked). No other dependencies stand in the way.

### 2. Add Phase 7.5 to the plan for WeakCanonical/Separation
The original plan has no phase for the 492 references across 15 files in `Metalogic/WeakCanonical/`. This is the SECOND-largest affected module after SubformulaClosure. Add a dedicated phase.

### 3. Prototype `@[match_pattern]` before committing to full refactor
Create a branch with just the `Formula` type change and `@[match_pattern]` on the new `def`s. Test whether existing pattern matches survive. If they do, the refactoring surface shrinks dramatically (possibly by 50%+). If not, proceed with the full mechanical refactor.

### 4. Handle ConservativeExtension/ExtFormula in coordination
Add `untl`/`snce` to `ExtFormula`, remove `all_past`/`all_future` (or mark for future cleanup). The current design where `ExtFormula` is a parallel type with different constructors will become even more divergent.

### 5. Use Strategy A (transparent expansion) with one enhancement
Keep Strategy A as planned. But add `@[simp]` lemmas that re-fold expanded forms:
```lean
@[simp] lemma all_future_unfold : (untl φ.neg top).neg = all_future φ := rfl
@[simp] lemma all_past_unfold : (snce φ.neg top).neg = all_past φ := rfl
```
These lemmas let `simp` normalize terms back to `all_future`/`all_past`, preventing term explosion in proofs while keeping the transparent Strategy A semantics.

### 6. Coordinate with task 163 (in progress)
Task 163 is currently implementing UltrafilterFrame.lean recovery from Boneyard. That file has 82 `all_future`/`all_past` references. If task 163 completes before task 116 starts, task 116 will need to update the newly recovered file. Coordinate timing to avoid double-work.

---

## Evidence/Examples

### Scope Undercount Evidence
```
Original estimate: 70 files, ~1416 refs
Actual count:      83 files, 1891 refs
Delta:             +13 files, +475 refs

Missed modules:
- WeakCanonical/Separation/ (15 files, 359 refs)
- WeakCanonical/ top-level  (5 files, 133 refs)  
- UltrafilterFrame.lean     (1 file, 82 refs, untracked)
```

### Task 157 Dependency Evidence
From `specs/157_expressive_completeness_su_integer/reports/10_task116-dependency-analysis.md`:
> "Every one of the 7+ failed attempts followed this pattern: accept the Case 1-2 witnesses as given, try to handle all_past/all_future in the callback, hit circular dependency."

### `@[match_pattern]` Evidence
From `Mathlib/SetTheory/Lists.lean:201`:
```lean
@[match_pattern]
def atom (a : α) : Lists α := ⟨_, Lists'.atom a⟩
```
This enables `| Lists.atom a => ...` pattern matching on a `def`, not a constructor.

### ConservativeExtension Divergence Evidence
```
Formula constructors:    atom, bot, imp, box, untl, snce        (after 116)
ExtFormula constructors: atom, bot, imp, box, all_past, all_future (unchanged)
```
No `untl`/`snce` in `ExtFormula` — `embedFormula` cannot map the full formula language.

---

## Confidence Levels

| Finding | Confidence |
|---------|------------|
| Task ordering (proceed now) | **High** — verified via state.json, TODO.md, dependency analysis |
| Scope undercount (83 files, 1891 refs) | **High** — verified via grep |
| `@[match_pattern]` potential | **Medium** — exists in Lean 4, but untested for complex expansions |
| ConservativeExtension structural problem | **High** — verified via code reading |
| Separation module benefits | **High** — documented in task 157 report 10 |
| STSA/algebraic minimal impact | **High** — STSA uses abstract operators, not constructors |
| Publication alignment | **High** — matches standard literature presentations |
| Naming convention (defer) | **Medium** — style preference, low priority |
