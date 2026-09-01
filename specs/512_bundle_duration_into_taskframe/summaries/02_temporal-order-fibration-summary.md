# Task 512 — the temporal-order fibration: implementation summary

**Plan of record**: `plans/02_temporal-order-fibration.md` (v02, 21 phases).
**Status**: all 21 phases `[COMPLETED]`.
**This dispatch** (`sess_1788235711_6acdbf`) closed phases **11–20**; phases 0–10 were closed in
earlier dispatches.

## What landed

The library now names the paper's `def:temporal-order` and expresses `def:frame` as a fibration:

| Lean | Paper | Role |
|------|-------|------|
| `TemporalOrder` | `def:temporal-order` | the object `𝔇`, reified as a structure bundling carrier + four algebra fields |
| `FrameOver D` | frames at a fixed `𝔇` | the fibre; the sole declaration site of the six frame fields |
| `TaskFrame` | `𝔉 = ⟨W, 𝔇, ⇒⟩` | the total space, `Σ (D : TemporalOrder), FrameOver D` |

`FrameOver.toTaskFrame` is the inclusion and literally the constructor; the total-space identity
`⟨F.Duration, F.toFibre⟩ = F` holds by `rfl`. `TaskFrame`'s flat surface (`F.WorldState`,
`F.TaskRel`, `F.spherical`, …) is preserved by delegating accessors, so the migration never
required a tree-wide restatement of consumers.

The transitional layer (`ParamTaskFrame`, `ParamFiniteTaskFrame`, `ofParam`, `toParam`, their
`CoeOut`) is deleted, along with `FrameConditions.ValidOver`.

## The two structural wins, concretely

1. **The Σ-collapse.** Theorems that spent five existential slots saying "there is a temporal
   order" — `∃ (D : Type) (_ : AddCommGroup D) (_ : LinearOrder D) (_ : IsOrderedAddMonoid D)
   (_ : Nontrivial D) (F : ParamTaskFrame D)` — now read `∃ (F : TaskFrame)`. Four theorems
   (Phases 11 and 13); their consumers each lose five `_` slots.
2. **Binder collapse.** `{D : Type} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
   [Nontrivial D]` becomes `{D : TemporalOrder}` wherever `D` is used *only* as a duration order
   (`LoopingDuration.lean`'s nine declarations, `CoNotPriorU`'s `Connectives` section,
   `FlowFrame`'s generic layer, `TemporalStructures`' polymorphic section). Genuine carrier side
   conditions stay binders — `[Archimedean ↑D]`, `[SuccOrder ↑D]`, `[DenselyOrdered ↑D]`.

## The criterion that governed every phase

`D` becomes a `(D : TemporalOrder)` binder wherever it is used **only** as a duration order. It
stays an ambient carrier, with the frame written `FrameOver (TemporalOrder.of D)`, wherever a
neighbouring abstraction this task does not restate — `BFMCS` in the bundle layer,
`FrameConditionFor`, `TemporalCarrier`, and the frame-condition family `C : (D : Type) → … → Prop`
in the decidability bridge — consumes the same `D` as a bare type. Promoting only the frame's
binder at those sites makes `?D` uninferable at every call site, because unification cannot invert
`TemporalOrder.carrier ?D =?= Rat`. That is why `TemporalOrder.of` is permanent.

## Verification at completion

- `lake build` exit 0; isolated full rebuild **327 s** against a 403 s baseline (19 % below).
- `lake build BimodalTest` exit 0.
- `scripts/check-module-invariants.sh`, full run with build: **ALL CHECKS PASSED**.
- Zero structural `sorry`; no new axioms; no `▸` cast introduced anywhere.
- C2, per theorem: `completeness`, `completeness_dense`, `completeness_discrete`,
  `Chronicle.countermodel_dense` all `[propext, Classical.choice, Quot.sound]`.
- `grep` for `ParamTaskFrame` / `ParamFiniteTaskFrame` / `ofParam` / `toParam` / `ValidOver` over
  `FormalSystem` and `Tests`: empty.

## Plan Deviations

Each is documented in full, with its reasoning, in the corresponding `#### Phase N Record` in the
plan. The three that are **decisions rather than measurement corrections** are flagged first.

**Decisions (warrant review):**
- **`TemporalOrder.of` retained for pinned carriers** (Phases 12, 14, 20). The plan's Phase 12
  text asked for `bundleFlowFrame` to become "a `FrameOver D` value for abstract
  `(D : TemporalOrder)`". Executed instead as `FrameOver (TemporalOrder.of D)` over an ambient
  carrier, because the literal form leaves `?D` uninferable at ~18 call sites and would require a
  per-site `(D := …)` campaign — which standing contract item 8 forbids in spirit. Phase 20's task
  list explicitly contemplates keeping `TemporalOrder.of`, and it is kept.
- **`realOrder` / `ratOrder` not declared** (Phases 13, 16, 20). A single `ratOrder` must live in
  `Semantics/TemporalOrder.lean` to be visible to both `BXCanonical` and `Independence`, and that
  module cannot state `⟨Rat⟩` without a new Mathlib import in the transitive closure of every
  module in the tree (probed directly: `failed to synthesize AddCommGroup Rat`). Present spelling
  `TemporalOrder.of ℝ` / `of ℚ` / `of (ℚ ×ₗ ℤ)`, all `@[reducible]` and behaviourally identical.
  Recommended to task 507, which owns names.
- **`ValidOver`'s deletion cascaded further than planned** (Phase 18). The plan called it orphaned
  with "two bridges"; it had 15 uses across all three `FrameConditions/` modules. Deleted anyway,
  with every use restated over `TaskFrame.ValidOn`; no new lemma was needed. Forced two renames:
  `ValidOverInt` → `ValidOnInt`, `valid_over_Int_of_valid_discrete` →
  `valid_on_Int_of_valid_discrete`.

**Measurement corrections (scope hypotheses confirmed at implementation time, as the standing
contract requires):**
- Phase 12: 37 occurrences hypothesised, 16 measured; edit blast radius 2 files → 6.
- Phase 14: ~32 hypothesised, 25 measured (`RegionFrame` 16, not 22).
- Phase 15: 14 files, 4 occurrences, **2** real edits — the `IntPresentation` interface carried
  the directory across, exactly as the scope hypothesis warned it might.
- Phase 16: 22 hypothesised, 20 measured; `Archimedean` binder sites 4 asserted, **3** confirmed.
- Phase 17: 70 hypothesised, 55 measured, of which **5** are type ascriptions; the plan's list of
  eleven frames for this file named six that live elsewhere.
- Phase 19: 81 hypothesised, 73 measured, of which **11** are type ascriptions.
- Phase 20: the plan expected a `ParamTaskFrame` sweep of 15 markdown files; docs contained
  **zero** such occurrences.

**Items skipped, with reasons:**
- Phase 15's optional `@LT.lt ℤ _` relaxation: examined and not taken. `omega` reads the syntactic
  type of a hypothesis and does not see through the `TemporalOrder` carrier coercion, so those
  restatements are load-bearing.
- Phase 17: no `@[reducible]` added to the three ℤ frames. R1/R3's requirement is on the temporal
  *order* constant, which `intOrder` already satisfies.

## Follow-ups handed on (not defects in this tree)

1. `scripts/check-paper-definitions.sh` exits 1 on **source-paper** drift: a new
   `def:time-shift-histories` in the live paper, and two anchors whose environment structure moved.
   This task touched no `typst/`, `latex/` or `specs/paper-definitions-of-record.md` file.
2. `Tests/BimodalTest/Semantics/SemanticBenchmark.lean` does not elaborate and has not since
   before this task (verified against `92c26855e`). Unimported, so `lake build` does not cover it.
3. `docs/` carries pre-existing staleness unrelated to the fibration (`LinearOrderedAddCommGroup`,
   `ConvexSet T`, `String`-valued valuations). The passages stating the *frame's shape* were
   rewritten; the rest was left and is reported here.
4. For 510: `TemporalCarrier` (`Carrier.lean:126`) carries exactly `TemporalOrder`'s four
   components and may reduce to `(fc) (D : TemporalOrder)` plus two fields.
5. For 507/513: `FrameConditions.LinearTemporalFrame` is redundant under this design.
