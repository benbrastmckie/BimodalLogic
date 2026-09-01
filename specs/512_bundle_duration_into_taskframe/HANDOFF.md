# Handoff — batch orchestration of tasks 512, 507, 508, 509, 510, 513

**Written**: 2026-08-31 21:00 PDT
**Batch session**: `sess_1788209220_633087`
**Multi-state file**: `specs/.orchestrator-multi-state-sess_1788209220_633087.json`
**Reason for handoff**: context refresh (the implementation agent exhausted its own context at
Phase 11; the orchestrator session is being refreshed alongside it)

---

## 1. How to resume

```
/orchestrate 512, 507, 508, 509, 510, 513
```

The batch is mid-flight, not finished. Task 512 is `implementing` and holds the whole batch: the
dependency chain is strictly serial at the front.

**Wave schedule** (computed from `dependencies[]`, unchanged):

| Wave | Tasks | Blocked on |
|------|-------|-----------|
| 0 | 512 | — (in progress) |
| 1 | 507 | 512 |
| 2 | 510, 513 | 507 (513 also on 512) |
| 3 | 508 | 507, 510 |
| 4 | 509 | 507, 508 |

Task 514 is `completed`, so the out-of-batch edges from 512 and 507 are satisfied.

**Before resuming**, deal with the in-flight state described in §3.

---

## 2. Task 512 status — 11 of 21 phases green

Plan of record: `specs/512_bundle_duration_into_taskframe/plans/02_temporal-order-fibration.md`
(v02 — supersedes v01; 21 phases, 13 dependency waves).

Last green commit: **`c955eb8c7`** (`task 512 phase 10: the finite-model-property family`).

Phases 0–10 `[COMPLETED]`. Phase 11 `[IN PROGRESS]`. Phases 12–20 `[NOT STARTED]`.

Every completed phase was verified with: `lake build` exit 0, `lake build BimodalTest` exit 0,
`scripts/check-module-invariants.sh` ALL CHECKS PASSED, C2 flagship axiom profiles
`[propext, Classical.choice, Quot.sound]` unchanged, zero structural sorry.

---

## 3. In-flight state that needs attention FIRST

At the time of writing, a `lake build` is **still running** (started by the dead agent) and two
source files carry **uncommitted** Phase 11 edits:

```
 M FormalSystem/Metalogic/BXCanonical/Completeness.lean
 M FormalSystem/Metalogic/WeakCanonical/IntegerModel/ReynoldsBridge.lean
```

These are Phase 11 (`ReynoldsBridge.lean`) work in progress. They are **not** garbage — Phase 11
was actively being verified when the agent died. Do not discard them reflexively.

**Recommended first step on resume**: let the build finish (or re-run it), then decide whether
Phase 11's edits are complete and green:

- If green and complete → commit as `task 512 phase 11: ReynoldsBridge.lean`, mark the heading
  `[COMPLETED]`, resume at Phase 12.
- If incomplete → the fresh agent continues Phase 11 from these edits.
- Never `git reset --hard` / `git checkout --` these files to reach a green build. Fix forward.
  (See `.claude/rules/error-handling.md`; a snapshot via `scripts/git-snapshot.sh 512` is the
  sanctioned path if a rollback is genuinely wanted.)

Other uncommitted paths (`.claude-extensions.json`, `specs/events.jsonl`, `.syncprotect`,
`scripts/__pycache__/`) are unrelated ambient state, not this task's work.

**The implementation agent must be dispatched FRESH.** The previous one died with
`Prompt is too long`; resuming it will fail again. Carry §5's findings forward in the prompt
instead of relying on its transcript.

---

## 4. The design (settled — do not re-litigate)

The original task asked to bundle `Duration` as a field of `TaskFrame`. v01 executed 5 phases
that way and hit a hard blocker: bundling makes the **fibre** notion — "frames over a fixed
duration type" — inexpressible, and the entire ℤ machinery is stated exactly that way.
`(F : TaskFrame) (hD : F.Duration = ℤ)` cannot carry it, because `hD` is a `Prop` while
`OfNat F.Duration 1` is data, so the equation cannot transport the instance.

**Root-cause diagnosis**: the library had no name for the paper's `def:temporal-order`. It was
transcribed as an unnamed 4-binder list `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
[Nontrivial D]`, hand-copied 225 times in 30 distinct shapes. That single omission caused both
the binder-noise proliferation and the fibre-inexpressibility blocker: you cannot fix "a temporal
order" when there is no such object, only a bare `Type` plus four loose instance arguments.

**Owner decision (approved by the user, priority: long-term quality over cost)** — reify the
temporal order, make the fibre primitive, define `TaskFrame` as the total space:

```lean
structure TemporalOrder where            -- def:temporal-order, reified
  carrier : Type
  [addCommGroup : AddCommGroup carrier] [linearOrder : LinearOrder carrier]
  [isOrderedAddMonoid : IsOrderedAddMonoid carrier] [nontrivial : Nontrivial carrier]

instance : CoeSort TemporalOrder Type := ⟨TemporalOrder.carrier⟩

structure FrameOver (D : TemporalOrder) where   -- the fibre; frame axioms live HERE, once
  WorldState : Type
  TaskRel : WorldState → D → WorldState → Prop
  comp, converse, serial, limit, spherical, nullity_identity : ...

structure TaskFrame where                       -- the total space, ≅ Σ D, FrameOver D
  Duration : TemporalOrder
  toFibre  : FrameOver Duration
```

Rejected alternatives, with reasons, are recorded in plan v02's decision section. In short:
keeping `ParamTaskFrame` permanently duplicates all six frame axioms across two structures and
needs `CoeOut` machinery with a universe restriction; reformulating the ℤ code over raw
components is a ~350-site redesign rather than a restatement; carrying the carrier equation as
data is the workaround-shaped version of indexing by `TemporalOrder`.

This is **more** faithful to the paper, not less: `def:frame-properties` predicates
Discrete/Dense/Complete of the frame through its D-component, which becomes literally
`F.Duration.Dense`.

---

## 5. Findings to carry forward into the next dispatch

These were earned during execution and are not all written in the plan.

1. **Phase 0 (STOP gate) passed all six probes.** Probe files:
   `probes/07_temporal-order-shape.lean`, `probes/08_fibre-and-accessors.lean`.
   - `(↑intOrder : Type) = ℤ` by `rfl`; numerals work at the fibre.
   - `omega` at the ℤ fibre works via ℤ-typed binders; no diamond in instance resolution;
     Σ-identity `⟨F.Duration, F.toFibre⟩ = F` by `rfl`; the transitional alias
     `ParamTaskFrame ℤ = FrameOver intOrder` holds by `rfl`.
   - **Shape correction**: Prop-valued accessors must be `theorem`s, not `@[reducible] def`s
     (Lean refuses to set reducibility on a non-definition). Harmless by proof irrelevance.

2. **The `omega` hazard is narrower than first thought.** It breaks only where the hypothesis is
   *produced by a frame field's own type* — not merely because a file mentions ℤ. Phase 7 needed
   **zero** casts because its arithmetic binders are the statement's own (`(d : ℤ)`, `(n : ℕ)`).
   Where it does break, the only sanctioned recovery is a genuine type change,
   `change (0 : ℤ) ≤ x at hx` — an ascription (`show`/`have`) does **not** work. Still relevant
   to Phases 15 and 19.

3. **`check-module-invariants.sh` is load-bearing, not ceremonial.** It has caught three
   breakages a green `lake build` did not: C6's isolation compile of
   `PeriodicExtension.lean` (unreachable-but-manifested, so the build does not cover it), the
   default target excluding `BimodalTest`, and a namespace-resolution failure. Never treat a
   green build as sufficient verification in this tree.

4. **Phase 8 verdict — NEGATIVE, and settled.** `IntTransfer.lean` is base change only along
   **isomorphisms**, and the restriction is forced. The obstruction localizes to one axiom:
   *Limit* uses `map_lt_map_iff` in both directions (instantiates its hypothesis at `e x`,
   produces its witness as `e.symm n`), so a one-directional morphism has nothing to instantiate
   with. This is mathematically real, not a proof artifact — *Limit* says every positive cone
   shrinks to a point, and a non-surjective reindexing can omit exactly the small durations that
   witness it. **No base-change theory was added, deliberately**: a general one is new
   mathematics, not a restatement refactor. Tasks 507 and 513 must size that honestly rather than
   assume Phase 8 delivered it.

5. **The migration is cheaper than the plan estimated.** Phase 3 (swapping `TaskFrame` to the
   total space) had a blast radius of **one file** — all 86 files from v01 compiled untouched;
   `ShiftSet.frame` was repaired by *splitting* the definition (bodies moved verbatim into
   `ShiftSet.fibre`, `frame := S.fibre.toTaskFrame`) so no proof changed. Phase 4 needed zero
   edits. Phase 5 was mis-sized in the plan (its premise was true of the pre-512 tree, but v01
   had already bundled that family): blast radius 1 file, not 17. **Every confirmed scope count
   has come in at or below estimate; no phase has needed its pre-authorized split.**
   Re-measure each phase before editing rather than trusting the estimate.

6. **`grep -rn "toParam" FormalSystem/Metalogic` returns 0.** Phase 5 discharged both v01
   exclusions, including `satisfiable (D : TemporalOrder)` over `FrameOver D` — the fibre
   predicate the fibration makes expressible for the first time.

7. **Useful identity for 507**: under the fibration, `∃ D, ∃ F : FrameOver D` **is**
   `∃ F : TaskFrame` by the Σ-identity — which is exactly what `ValidDiscrete` consumes.

8. **Incident, do not repeat**: `lake clean` in this Lake version wipes the **workspace**,
   Mathlib included. It cost ~20 min of wall time (recovered via `lake exe cache get`; the
   5.5 GB `~/.cache/mathlib` was intact). Barred for the rest of this task.

---

## 6. Standing constraints for every remaining dispatch

- Per-phase contract: `lake build` exit 0, `lake build BimodalTest` exit 0,
  `check-module-invariants.sh` ALL CHECKS PASSED, zero sorry, C2 flagship axiom profiles
  unchanged, **commit at each green boundary**. Never batch phases into one commit.
- Mark each finished phase `[COMPLETED]` in the plan as you go; report honest
  `phases_completed`/`phases_total` in the handoff and `.return-meta.json`.
- **512 owns binders, 507 owns names.** Do not rename any `Dedekind` identifier in 512. (507
  renames `Dedekind` → `Complete` per the paper; the wave order keeps them from colliding in
  `Validity.lean`.)
- Boneyard stays excluded — 2 frames already fail to elaborate; leave dead.
- Phases 13 and 16 own the deferred `ratOrder`/`realOrder` declarations. They were deferred for
  import hygiene: do not pull `Mathlib.Data.Real.Basic` into modules that do not need it.
- Phase 14: task 510's `TemporalCarrier`/`FrameConditionFor` at `Bridge/Carrier.lean:110,126` is
  **FLAG-ONLY** — record the finding, do not act on 510's scope.
- Prohibited: `sorry`, vacuous definitions (`def X := True`), per-site `▸` casting campaigns
  presented as restatements, discarding uncommitted work to reach green, `lake clean`.
- ACCEPTANCE (unchanged): sorry-free, `lake build` green, `check-module-invariants.sh` passes,
  axiom profiles unchanged on flagship theorems. This is a **restatement refactor** — no
  theorem's mathematical content may change; semantic drift is a defect.
- If something needs an owner decision: **STOP and escalate** with a structured blocker rather
  than improvising. That is what happened at v01 Phase 5 and escalating was the right call.

---

## 7. Cross-task observations recorded (not acted on)

- **Task 510 may shrink to a merge.** `TemporalCarrier`/`FrameConditionFor` at
  `Bridge/Carrier.lean:110,126` may simply *be* `TemporalOrder` under this design.
- **Task 507 gets cleaner.** Several frame classes are pure temporal-order conditions and can
  factor through the base; and finding 7 above collapses its quantifier pattern for free.
- **Base-change theory is a candidate new task** (see finding 4) — it is new mathematics, out of
  scope for 512.
- **Admission advisory, benign**: 512's `file_scope` (`FormalSystem/`) overlaps out-of-batch task
  **#177**, which is idle (`not_started`), so it admitted rather than deferring. Add a
  `dependencies[]` edge between them if ordering matters.

---

## 8. Incidental defects surfaced (carried from v01, still open unless noted)

- `Tests/BimodalTest/Semantics/SemanticBenchmark.lean:50` named a nonexistent
  `TaskFrame.trivial_frame`. Fixed in v01; the deliberate decision **not** to wire the file into
  the test aggregator was recorded rather than silently skipped. The file remains unimported by
  the aggregator, which is why the defect went uncaught.
- Two Boneyard frames use the pre-generalization field set and would not elaborate today either.
  Left dead deliberately.
- The build emits `Overlapping instance parameters` lint warnings (`2 [Nontrivial D] instances;
  one is sufficient`) at several sites in `Metalogic/Decidability/Verified/Decidable.lean` —
  the hand-copied binder-list problem showing up as lint noise. Reifying `TemporalOrder` is what
  removes it; expect these to disappear as the remaining phases land.
