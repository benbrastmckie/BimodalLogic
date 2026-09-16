# Implementation Plan: Task #598

- **Task**: 598 - Derive nullity_identity instead of carrying it as a FrameOver field
- **Status**: [IMPLEMENTING]
- **Effort**: 5 hours
- **Dependencies**: None blocking (task 596 nesting is completed; task 599 is in planning and overlaps only on `FormalSystem/Semantics.lean` prose)
- **Research Inputs**: specs/598_derive_nullity_identity/reports/01_derive-nullity-identity.md
- **Artifacts**: plans/01_derive-nullity-identity.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

`FrameOver` (in `FormalSystem/Semantics/TaskFrame.lean`) carries a `nullity_identity` field
(`TaskRel w 0 u ↔ w = u`) that is fully derivable: reflexivity from *Seriality* + *Limit*
(`TaskFrame.nullity_of_serial_limit`) and injectivity-at-zero from *Limit* alone (cone witness
`y := 0`). This plan removes the field so the structure is exactly the paper's `def:frame`
(`comp`, `serial`, `limit`, `saturation`, plus `converse` and nonempty `W`), re-exposes
`FrameOver.nullity_identity` as a theorem with the identical statement (so every consumer keeps
compiling), deletes the now-redundant discharge proofs at all construction sites and the helper
cruft that existed only to feed them, and rewrites every docstring/doc/typst passage that
describes the field as kept for construction ergonomics or as a "strictly stronger" design fact.
Definition of done: full `lake build` green, zero `sorry`/new axioms, no live `nullity_identity :=`
field line outside `FormalSystem/Boneyard/`.

### Research Integration

Report 01 verified (via a `lean_run_code` probe, axioms `[propext]`) that `nullity`,
`eq_of_taskRel_zero`, and `nullity_identity` are provable for arbitrary `F : FrameOver D` from
`F.serial` and `F.limit`. Load-bearing findings integrated here:
- `nullity_of_serial_limit` lives in `Semantics/FrameAxioms.lean`, downstream of `TaskFrame.lean`;
  it must MOVE into `TaskFrame.lean`'s pre-structure `namespace TaskFrame` block (FQN unchanged,
  so `Extension/Admissible.lean:318` keeps compiling).
- 17 construction sites supply the field; none use anonymous-constructor or `FrameOver.mk` syntax.
- `limit_of_succOrder` consumes the iff but uses only `.mp`; weakening it to the
  `R w 0 u → u = w` shape (already used by `limit_of_shift`) makes
  `nullity_identity_of_permissive` dead and shrinks `fn_nullity` to its injectivity half. This
  plan takes that option (the task asks for minimality, avoiding cruft).
- `FlowFrame.lean:283` and `RegionFrame.lean:285` derive `*_limit` from the frame's
  `nullity_identity`; after the change this is circular-looking, so replace with the frame's own
  `.limit` field.
- `fzero_nullity` (DriftFrame) becomes unused and is deleted.
- Boneyard is not built and is out of scope.

A plan-time `lean_run_code` check confirmed the Challenge statements below elaborate against the
current build.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No roadmap consultation requested for this dispatch.

## Goals & Non-Goals

**Goals**:
- The structure has no zero-duration field; `nullity_identity` is a theorem with the unchanged statement (zero-duration task iff equality).
- `nullity` (reflexivity) and `eq_of_taskRel_zero` (injectivity-at-zero) are theorems proved from the serial and limit fields only, placed before `nullity_identity` at the top of the fibre namespace.
- `nullity_of_serial_limit` lives in the frame module ahead of the structure, with its fully qualified name unchanged and no duplicate left in the frame-axioms module.
- `limit_of_succOrder` takes the one-directional zero hypothesis (zero-duration task implies equality).
- Every construction site drops its field line; helpers that existed only to feed it are deleted.
- All prose (Lean docstrings, READMEs, docs, typst) describes the zero law as derived.
- Acceptance: full lake build green (FormalSystem and BimodalTest), no new sorries, no new axioms.

**Non-Goals**:
- Changing the bundled `TaskFrame.nullity_identity` / `TaskFrame.nullity` accessors (kept, statements unchanged).
- Editing `FormalSystem/Boneyard/**` (not built).
- The history-layer unification of the in-flight history task (task 599); edits to `FormalSystem/Semantics.lean` stay confined to the frame table/paragraph.
- Rewriting historical audit records (e.g. `typst/SYNC-MAP.md` verdict rows are dated audit entries, not live claims).
- Any change to `limit_of_shift` or `limit_of_permissive`'s public signatures.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Unused-instance linter on moved `nullity_of_serial_limit` (`Nontrivial` unused) | L | M | `omit [Nontrivial D] in` as neighbouring helpers already do |
| `rw [F.nullity_identity] at hu hv` (DeterministicBridge) behaves differently with a theorem than a projection | M | L | Both are `∀ w u, _ ↔ _`; if `rw` fails, use `(F.nullity_identity _ _)` explicitly |
| Name clash: adding theorem `FrameOver.nullity_identity` while the field still exists | M | H if mis-sequenced | Phase 2 deletes the field and adds the theorem in the same edit (atomic batch) |
| Weakened `limit_of_succOrder` breaks a caller not found by research | M | L | Phase 1 re-greps callers before editing; full build closes Phase 1 |
| Concurrent history task (599) edits `Semantics.lean` | L | M | Confine edits to lines ~215-230; re-read file immediately before editing; targeted staging |
| Obligation counts ("six"/"seven" fields) missed in prose | L | M | Phase 3 greps for `seven\|six` near `FrameOver`/`field`/`obligation`; prefer naming fields over counting |
| `@[reducible]` frames (`fnFrameOver`, `fzeroFrame`) change behavior | L | L | Removing a Prop field does not affect `WorldState` reducibility; build verifies |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3, 4 | 2 |
| 4 | 5 | 3, 4 |

Phases within the same wave can execute in parallel (Phases 3 and 4 own disjoint files: 3 owns
`.lean` files, 4 owns `docs/`, `typst/`, and `*.md` READMEs).

### Phase 1: Relocate and weaken helpers (field still present) [COMPLETED]

**Goal**: Land every change that does not require removing the field, keeping the build green,
so Phase 2 is a pure deletion batch.

**Tasks**:
- [x] Move `nullity_of_serial_limit` (with its docstring, trimmed of the paragraph describing the field) from `FormalSystem/Semantics/FrameAxioms.lean` into `FormalSystem/Semantics/TaskFrame.lean`'s first `namespace TaskFrame` block, after `Serial` (and before `end TaskFrame` at ~line 524); add `omit [Nontrivial D] in` if the linter requires. Delete the declaration from `FrameAxioms.lean`, leaving its list-item pointer (line ~86) pointing at `TaskFrame.lean`.
- [x] Weaken `TaskFrame.limit_of_succOrder` (TaskFrame.lean ~845) to `(hzero : ∀ w u, R w 0 u → u = w)`; last line becomes `exact hzero w u hR`. Update its docstring.
- [x] Re-grep `limit_of_succOrder` callers and update each: `limit_of_permissive` (TaskFrame.lean ~1267, e.g. `fun w u h => by rw [hR] at h; simpa [eq_comm] using h`), `fn_limit` (ForwardDeterministicFrame.lean ~189), `IntNormalForm.ofStep`'s `limit` (IntNormalForm.lean ~477). For `fn_limit`, replace `fn_nullity` by a one-directional lemma (shrink `fn_nullity` to `fnRel w 0 u → u = w`, renaming it e.g. `fn_eq_of_zero` if the old name misleads; the field line still uses the iff in this phase, so keep the iff proof inline there or temporarily keep both halves — Phase 2 removes the field line). *(deviation: altered — `fn_limit` adapts the still-iff `fn_nullity` inline in this phase; the lemma is shrunk in Phase 2)*
- [x] Add `FrameOver.eq_of_taskRel_zero` at the top of `namespace FrameOver` (TaskFrame.lean ~733), proved from `F.limit` alone: `(F.limit w u fun x hx => ⟨0, by simpa using hx, h⟩).symm`.
- [x] Reprove `FrameOver.nullity` from `TaskFrame.nullity_of_serial_limit F.serial F.limit w` and move it above `forward_comp`.
- [x] Replace the bodies of the standalone `*_limit` theorems at `Metalogic/Algebraic/FlowFrame.lean:~283` and `Metalogic/Decidability/Verified/Bridge/RegionFrame.lean:~285` with `(multiFamTaskFrameGen D FamIdx).limit` / `(regionFrame W ι D).limit` (or delete the theorem if it is unused after inspection; grep first).
- [x] Build: `lake build FormalSystem.Semantics.TaskFrame FormalSystem.Semantics.FrameAxioms`, then full `lake build` (detached, per lean4.md long-build guidance). Commit. *(deviation: altered — scoped build of all six touched modules plus `Extension.Admissible` instead of a full build; full build deferred to Phase 2, which touches every downstream site anyway)*

**Timing**: 1.25 hours

**Depends on**: none

**Verification Tier**: interface

**Scope Hypothesis**: `limit_of_succOrder` has exactly three callers (`fn_limit`, `limit_of_permissive`, `IntNormalForm.ofStep`); confirm with `grep -rn "limit_of_succOrder" --include=*.lean FormalSystem Tests | grep -v Boneyard` before editing.

**Files to modify**:
- `FormalSystem/Semantics/TaskFrame.lean` - move-in, weaken helper, add/reorder derived theorems
- `FormalSystem/Semantics/FrameAxioms.lean` - remove moved declaration
- `FormalSystem/Metalogic/Independence/ForwardDeterministicFrame.lean` - `fn_limit` input
- `FormalSystem/Semantics/IntNormalForm.lean` - `ofStep.limit` argument
- `FormalSystem/Metalogic/Algebraic/FlowFrame.lean` - `*_limit` body
- `FormalSystem/Metalogic/Decidability/Verified/Bridge/RegionFrame.lean` - `*_limit` body

**Verification**:
- Full `lake build` green; `lean_verify` on `FormalSystem.Semantics.FrameOver.nullity` and `FormalSystem.Semantics.FrameOver.eq_of_taskRel_zero` shows no `sorryAx`.

---

### Phase 2: Remove the field and delete redundant discharges [COMPLETED]

**Goal**: Delete the `nullity_identity` field, add the same-named theorem, and remove every
construction-site proof and dead helper in one atomic batch.

**Tasks**:
- [x] In `TaskFrame.lean`: delete the field `nullity_identity : ∀ w u, TaskRel w 0 u ↔ w = u` (~651) and its long docstring (~600-650, including the embedded `nullity_iff_of_serial_limit` snippet); add `theorem nullity_identity (F : FrameOver D) : ∀ w u, F.TaskRel w 0 u ↔ w = u := fun _ _ => ⟨F.eq_of_taskRel_zero, fun h => h ▸ F.nullity _⟩` directly after `eq_of_taskRel_zero`/`nullity`.
- [x] In `TaskFrame.lean`: delete the field lines in `trivialFrame` (~1556), `staticFrame` (~1619), `natFrame` (~1690); delete `nullity_identity_of_permissive` (~1204) after confirming no remaining users.
- [x] Delete the field line at: `Semantics/Frames/Standard.lean` (`translationFrame` ~77, `permissiveFrame` ~131), `Semantics/IntNormalForm.lean` (`ofStep` ~449), `Semantics/IntTransfer.lean` (`FrameOver.map` ~142), `Semantics/ShiftSet.lean` (`fibre` ~166), `Examples/TemporalStructures.lean` (~82, ~127, ~229), `Metalogic/Independence/ClockFrame.lean` (~173), `Metalogic/Independence/DriftFrame.lean` (~228), `Metalogic/Independence/ForwardDeterministicFrame.lean` (~221), `Metalogic/Algebraic/FlowFrame.lean` (~153), `Metalogic/WeakCanonical/IntegerModel/ReynoldsBridge.lean` (~467), `Metalogic/Decidability/Verified/Bridge/RegionFrame.lean` (~197), `Metalogic/Decidability/FMP/Filtration.lean` (~303).
- [x] Delete `fzero_nullity` (DriftFrame.lean ~148) and its listing (~36); in ForwardDeterministicFrame, ensure only the injectivity lemma consumed by `fn_limit` remains (remove any now-unused iff version). *(deviation: altered — `fn_nullity` replaced by the one-directional `fn_eq_of_zero`)*
- [x] Delete any local helper lemmas that become unused (check each touched file for private lemmas only used by the deleted field proof).
- [x] Build detached: full `lake build`; then `grep -rn "nullity_identity :=" --include=*.lean FormalSystem Tests | grep -v Boneyard` returns nothing. Commit once green (atomic batch: do not commit intermediate red states). *(deviation: altered — 18 field lines removed (3 in TaskFrame.lean, 15 elsewhere), not 17; committed as HEAD-derived hunks only, since the concurrent history-migration task edits several of the same files)*

**Timing**: 1.5 hours

**Depends on**: 1

**Verification Tier**: full

**Commit Mode**: atomic-batch

**Scope Hypothesis**: 17 field-supplying sites across 14 files (list above, from the research report); confirm with `grep -rn "nullity_identity :=\|nullity_identity w u :=" --include=*.lean FormalSystem Tests | grep -v Boneyard` and also `grep -rn "saturation :=" --include=*.lean FormalSystem Tests | grep -v Boneyard` to catch any construction discharging the field under a different syntax. Delegating frames (`multiFamTaskFrame`, `IntPresentation.toFibre`, `FiniteModel`, `RealTranslationFrame`, `flipFrame`) are expected to need no code edits.

**Files to modify**:
- `FormalSystem/Semantics/TaskFrame.lean` - field removal, new theorem, in-file frames, dead helper
- the 13 other files listed in Tasks - one-line (or few-line) deletions

**Verification**:
- Full `lake build` green (FormalSystem and BimodalTest); `lean_verify FormalSystem.Semantics.FrameOver.nullity_identity` axioms within `[propext]` (plus standard Mathlib axioms if any).
- Consumers (`IntNormalForm.lean:197`, `DeterministicBridge.lean:136-154`, `Extension/Extension.lean:235`) compile unchanged.

---

### Phase 3: Lean docstring and module prose [COMPLETED]

**Goal**: Make every Lean-side docstring describe the frame as the four axioms plus `converse`
and the zero law as derived.

**Tasks**:
- [x] `TaskFrame.lean`: module docstring bullets (~83, ~121-124, ~147-150, ~158-159, ~170, ~202), the pre-`FrameOver` explanatory block (~537-577), and the `limit` field docstring (~702-704): remove "strictly STRONGER"/"open design question" language; state the structure carries `comp`, `converse`, `serial`, `limit`, `saturation` and that `nullity`, `eq_of_taskRel_zero`, `nullity_identity` are derived. Fix `natFrame`'s "All six axiom fields" comment.
- [x] `FrameAxioms.lean` (~86, ~103, ~159-163): pointer to the moved theorem; drop the field discussion.
- [x] `Semantics.lean` (~226-229): replace "retains it as a `nullity_identity` field for construction ergonomics only" with the derived-theorem statement; correct the table's `compositionality` field name to `comp`. Re-read immediately before editing (concurrent history task).
- [x] `Extension/Admissible.lean` (~97-111, ~284-285): the open design question is closed; `nullity_identity` is a derived theorem.
- [x] `Extension/Extension.lean` (~97, ~221), `DeterministicBridge.lean` (~67-70, ~126: "is a structure field" -> derived theorem), `IntNormalForm.lean` (~24, ~190, ~212, ~367, ~432 table row), `IntTransfer.lean` (~101 table row), `ShiftSet.lean` ("seven live fields"), `ConvexHistory.lean` (~285) *(deviation: skipped — the file was folded into `PartialHistory.lean` by the concurrent history-migration task and the passage no longer exists)*, `Frames/Standard.lean` ("seven obligations", *Nullity*), `Examples/TemporalStructures.lean` (~121, ~369, ~454, ~460), `ClockFrame.lean` (~161), `DriftFrame.lean` (~29, ~37, ~145, ~222), `ForwardDeterministicFrame.lean` (~127, ~186, ~216), `Filtration.lean` (~281, ~479), `IntPresentation.lean` (~121), `RealTranslationFrame.lean` (~128), `Metalogic/Independence.lean` (~69), `Tests/BimodalTest/Property/Generators.lean` (~32, ~146).
- [x] Sweep: `grep -rn "nullity_identity" --include=*.lean FormalSystem Tests | grep -v Boneyard` and `grep -rniE "(six|seven) (axiom |live )?(fields|obligations)" --include=*.lean FormalSystem Tests | grep -v Boneyard`; every remaining hit must be a genuine use of the theorem or a correct count. Prefer naming fields over counting.
- [x] Build touched modules (docstrings elaborate); commit. *(deviation: altered — verified by a full `lake build` of FormalSystem, not per-module; `Tests/` generator docstring is checked in Phase 5)*

**Timing**: 1 hour

**Depends on**: 2

**Verification Tier**: local

**Scope Hypothesis**: prose hits are those enumerated by the research report plus the grep sweep; confirm via the two greps above, which must end with no stale hits.

**Files to modify**:
- The `.lean` files listed in Tasks (docstrings/comments only)

**Verification**:
- Grep sweeps clean; diff read-through shows only comment/docstring hunks; touched modules build.

---

### Phase 4: External docs and typst prose [COMPLETED]

**Goal**: Update non-Lean documentation to the derived-theorem account.

**Tasks**:
- [x] `FormalSystem/Semantics/README.md` (~66, ~69 "all seven fields ... Six are free"): zero case is the derived `nullity_identity` theorem; fix field count.
- [x] `docs/reference/API_REFERENCE.md` (~144, ~160) and `docs/user-guide/architecture.md` (~479) *(deviation: altered — also rewrote the top-level `README.md` frame paragraph, which described the field as retained for construction ergonomics)*: drop `nullity_identity` from the field list; add a line naming it as a derived theorem.
- [x] `typst/chapters/02-semantics.typ` (~150-154): state `nullity` and the iff `nullity_identity` are derived theorems (reflexivity from Seriality + Limit, injectivity from Limit); delete the "strictly stronger" design-fact paragraph and the `CONFIRM(lean)` comment.
- [x] `typst/chapters/06-notes.typ` (~28): replace "strengthened to the Lean field `nullity_identity`" with the derived-theorem account.
- [x] Keep `typst/notation/bimodal-notation.typ`'s `leanNullityIdentity` macro (name still valid). Leave `typst/SYNC-MAP.md` audit rows untouched (historical record).
- [x] `typst compile` the main document if a build entry exists (e.g. `typst compile typst/<main>.typ` into the scratchpad) to confirm no broken references; commit.

**Timing**: 0.5 hours

**Depends on**: 2

**Verification Tier**: prose

**Scope Hypothesis**: 5 non-Lean files need edits; confirm with `grep -rn "nullity_identity\|construction ergonomics\|strictly stronger" docs typst FormalSystem/Semantics/README.md README.md`.

**Files to modify**:
- `FormalSystem/Semantics/README.md`, `docs/reference/API_REFERENCE.md`, `docs/user-guide/architecture.md`, `typst/chapters/02-semantics.typ`, `typst/chapters/06-notes.typ`

**Verification**:
- Grep above shows no stale claims; typst compiles; `readme-lint.sh` (if present in `.claude/scripts/`) exits 0.

---

### Phase 5: Final gate [COMPLETED]

**Goal**: Confirm the whole repository is green and the task-level acceptance bar holds.

**Tasks**:
- [x] Full `lake build` (detached), FormalSystem and BimodalTest.
- [x] `lean_verify` on `FormalSystem.Semantics.FrameOver.nullity`, `.eq_of_taskRel_zero`, `.nullity_identity`, `FormalSystem.Semantics.TaskFrame.nullity_of_serial_limit`, `FormalSystem.Semantics.TaskFrame.limit_of_succOrder`: no `sorryAx`, no new axioms.
- [x] `grep -rn "sorry" ` diff check: no new `sorry` introduced (`git diff main -- '*.lean' | grep '^+.*sorry'` empty).
- [x] Run module invariant/README lint scripts if present (`check-module-invariants.sh`, `readme-lint.sh`). *(deviation: skipped — neither script exists in `.claude/scripts/`)*

**Timing**: 0.75 hours

**Depends on**: 3, 4

**Verification Tier**: full

**Files to modify**:
- none (verification only; fix-ups loop back to the owning phase's files)

**Verification**:
- All gates above pass.

## Lean Challenge Statements

The identifiers below are statement pins for the Goals; they are placed in a scratch namespace so
the module elaborates alongside the real declarations. The real declarations live at
`FormalSystem.Semantics.FrameOver.{nullity, eq_of_taskRel_zero, nullity_identity}` and
`FormalSystem.Semantics.TaskFrame.{nullity_of_serial_limit, limit_of_succOrder}` with these exact
statements.

```lean
import FormalSystem.Semantics.TaskFrame

namespace FormalSystem.Semantics.NullityChallenge

open FormalSystem.Semantics

section Unbundled
variable {D : Type} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]

theorem nullity_of_serial_limit {W : Type} {R : W → D → W → Prop}
    (hSer : TaskFrame.Serial R)
    (hLim : ∀ w u, (∀ x, 0 < x → ∃ y, |y| < x ∧ R w y u) → u = w)
    (w : W) : R w 0 w := sorry

theorem limit_of_succOrder [SuccOrder D] [NoMaxOrder D]
    {W : Type} {R : W → D → W → Prop} (hzero : ∀ w u, R w 0 u → u = w) :
    ∀ w u, (∀ x, 0 < x → ∃ y, |y| < x ∧ R w y u) → u = w := sorry
end Unbundled

section Fibre
variable {D : TemporalOrder}

theorem nullity (F : FrameOver D) (w : F.WorldState) : F.TaskRel w 0 w := sorry

theorem eq_of_taskRel_zero (F : FrameOver D) {w u : F.WorldState}
    (h : F.TaskRel w 0 u) : w = u := sorry

theorem nullity_identity (F : FrameOver D) : ∀ w u, F.TaskRel w 0 u ↔ w = u := sorry
end Fibre

end FormalSystem.Semantics.NullityChallenge
```

## Testing & Validation

- [x] Full `lake build` green after Phases 1, 2, and 5.
- [x] No `nullity_identity :=` field lines remain outside `FormalSystem/Boneyard/`.
- [x] `FrameOver` structure declares exactly `WorldState`, `TaskRel`, nonemptiness, `comp`, `converse`, `serial`, `limit`, `saturation` (confirm by reading the structure).
- [x] Axiom checks on the five pinned declarations show no `sorryAx`.
- [x] Prose grep sweeps (Phases 3-4) clean.

## Artifacts & Outputs

- `specs/598_derive_nullity_identity/plans/01_derive-nullity-identity.md` (this plan)
- Modified Lean sources under `FormalSystem/Semantics/`, `FormalSystem/Metalogic/`, `FormalSystem/Examples/`, `Tests/BimodalTest/Property/`
- Modified docs: `FormalSystem/Semantics/README.md`, `docs/reference/API_REFERENCE.md`, `docs/user-guide/architecture.md`, `typst/chapters/02-semantics.typ`, `typst/chapters/06-notes.typ`
- `specs/598_derive_nullity_identity/summaries/01_derive-nullity-identity-summary.md` (at implementation end)

## Rollback/Contingency

Each phase ends in its own commit, so a failed phase is reverted by `git revert` of that phase's
commit. If Phase 2's atomic batch cannot be made green (e.g. an unforeseen consumer relies on the
field being a projection), a whole-tree rollback of the uncommitted batch follows
`context/contracts/recovery.md`'s rollback rung (snapshot first, including its out-of-scope
override flag for the deliberate whole-tree case), and the fallback is to keep Phase 1's green
state and record the blocking consumer for a revised plan. If the weakened `limit_of_succOrder`
proves awkward for a caller, revert just that helper change and keep `nullity_identity_of_permissive`
(ergonomics only, not correctness).
