# Implementation Plan: Carrier Normalization — the Successor-Archimedean Transfer

- **Task**: 475 - CARRIER NORMALIZATION: THE SUCCESSOR-ARCHIMEDEAN TRANSFER
- **Status**: [IMPLEMENTING]
- **Effort**: 5 hours
- **Dependencies**: None
- **Research Inputs**: `specs/475_carrier_normalization_successor_archimedean_transfer/reports/01_carrier-normalization-transfer.md`
- **Artifacts**: plans/01_carrier-normalization-int-transfer.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

The research pass produced a complete, compiled, `sorry`-free, axiom-clean prototype of **both**
task steps at
`specs/475_carrier_normalization_successor_archimedean_transfer/prototype/verified-prototype.lean`
(294 lines; `#print axioms Probe.validDiscrete_iff_validInt` reports
`[propext, Classical.choice, Quot.sound]`). This plan is therefore a **transcription, placement,
and docstring-repair** plan, not a discovery plan. Every phase below moves a named, already-
elaborated block out of the prototype's `Probe` namespace into its permanent home in
`FormalSystem.Semantics`, and ends green. Definition of done: `lake build` green, no new `sorry`,
no new `axiom`, `validDiscrete_iff_validInt` landed in the tree, and the three docstrings that
currently assert this lemma is absent repaired.

### Research Integration

Findings from `reports/01_carrier-normalization-transfer.md` that shape the phases:

1. **Step 1 needs fewer binders than the task assumed.** `PredOrder D` and `IsPredArchimedean D`
   are not used by `intIso`. State the block at
   `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [SuccOrder D] [Nontrivial D]` plus
   `[IsSuccArchimedean D]` on the two declarations that need it (§2.3 of the report). The two
   unused `ValidDiscrete` instances simply go unused at the application site.
2. **`spherical` is the cheapest interesting `TaskFrame` field to transport (11 lines), not the
   most expensive** — under an ordered-group iso the fiber and segment predicates pick out the
   *identical* subsets of `WorldState`, so `F.spherical` is handed the same directed family
   (§3.2).
3. **Do NOT prove `WorldHistory F ≃ WorldHistory (F.map e)`.** The round-trip forces a dependent
   equality on the `states` field and degenerates into `HEq` wrangling. Use the `Prop`-valued
   `Aligned` relation instead; it is `HEq`-free and its one transport is discharged by the tree's
   existing `WorldHistory.states_eq_of_time_eq` (`Semantics/WorldHistory.lean:323`) (§4.1). This
   is the single design decision the implementer must not get wrong.
4. **Two measured tactic traps** (§7). `linarith` does **not** fire on a bare
   `AddCommGroup` + `LinearOrder` — there is no ring structure; use `le_sub_iff_add_le` +
   `add_comm` (Phase 1, `succ_eq_add_succ_zero`). `simpa` does **not** close
   `(comap e ρ').domain s` from `ρ'.domain (e s)` — the equality is definitional and `simp`
   normalizes past it; use the bare term `fun s => hρ' (e s)` (Phase 4, `box` case).
5. **Three docstrings become false** and a build will not catch it (§5.3). Their repair is
   Phase 6, explicitly gated by greps.

**The recorded wrong turn stays avoided**: `orderIsoIntOfLinearSuccPredArch` is never used
anywhere in this plan. Nothing below consumes an order-only isomorphism. Durations add
(`TaskRel`'s Compositionality is stated at `x + y`), so `≃+o` — not `≃o` — is the only usable
transfer.

### Planner decision: where `ValidInt` lives

The report leaves this open ("either placement compiles; pick one — do not define it twice").
**Decision: `ValidInt` is defined in the new `FormalSystem/Semantics/IntTransfer.lean`, beside
`validDiscrete_iff_validInt`** (Phase 5). Rationale: it keeps `Validity.lean`'s import list
unchanged — that module is imported very widely, and the alternative placement would push
`Mathlib.Algebra.Order.Group.Int` and `Mathlib.Data.Int.SuccPred` into its closure for the sake
of one definition. `Validity.lean` is touched in this task for a docstring repair only.

### Prior Plan Reference

No prior plan. `plans/` contained only `.gitkeep` at planning time.

### Roadmap Alignment

`roadmap_path` was not supplied in the delegation context and `roadmap_flag` is not set, so no
roadmap review/update phases are included and `specs/ROADMAP.md` is not modified by this plan. A
read-only consultation notes one directly related entry: the roadmap's "Why Discrete is
weak-only" bullet records that `ValidDiscrete` requires `IsSuccArchimedean`/`IsPredArchimedean`
over an arbitrary Archimedean discrete carrier. This task supplies the ℤ-normalization for that
carrier bundle; it does not change the weak/strong completeness picture the bullet describes.

## Goals & Non-Goals

**Goals**:
- Land `archimedean_of_succ`, the successor-based analogue of `archimedean_of_lub`, at the
  reduced binder bundle, with `LinearOrderedAddCommGroup.int_orderAddMonoidIso_of_isLeast_pos`
  applying to it via `intIso : D ≃+o ℤ`.
- Land a generic transport of `TaskFrame`, `TaskModel`, `WorldHistory`, and `TruthAt` along any
  `e : D ≃+o E`.
- Land `validDiscrete_iff_validInt : ValidDiscrete φ ↔ ValidInt φ` as a theorem in the tree.
- Keep the build green, `sorry`-free and `axiom`-free at every phase boundary.
- Repair the three docstrings that assert the successor-based lemma is absent from the tree.
- Wire the new module into the `FormalSystem/Semantics.lean` aggregator (import + Submodules
  bullet) so `check-module-invariants.sh` C8/C6 stay green.

**Non-Goals**:
- Proving the packaged "nontrivial dense Dedekind-complete ⇒ `≃+o ℝ`" statement that
  `DurationClassification.lean` deliberately omits. Out of scope; its omission note stays.
- Any change to `TaskFrame`, `TaskModel`, `WorldHistory`, `PartialHistory`, or `Truth`. These are
  **read-only** here. `TaskFrame.map` is a new definition, not a modification of the structure, so
  no existing frame construction (`ofStep`, `toTaskFrame`, `zTaskFrameV2`, `trivialFrame`, …) is
  affected.
- Using or citing `orderIsoIntOfLinearSuccPredArch` as a transfer route (see above).
- Consuming the new theorem at any downstream site (completeness, decidability). Landing it is the
  whole task; applications are follow-on work.
- Deleting the recorded wrong-turn prose from the three docstrings — it remains true and remains
  worth recording. Only the "is absent"/"is not in this tree" claims change.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Implementer re-derives instead of transcribing, and re-hits the two measured tactic traps | M | M | Every phase names its source line range in `prototype/verified-prototype.lean`; the two traps are called out inline in Phases 1 and 4 |
| Implementer reaches for `WorldHistory F ≃ WorldHistory (F.map e)` and lands in `HEq` wrangling | H | M | Phase 3 states the `Aligned` design decision as a MUST and forbids the `Equiv` route explicitly |
| Namespace move breaks name resolution (prototype declares in `namespace Probe` with `open FormalSystem.Semantics`; target is *inside* `FormalSystem.Semantics`) | M | M | Verified no collision exists for any of the 13 new names; the dot-notation references (`TaskFrame.Seg`, `TaskFrame.Fib`, `TaskFrame.map`) still resolve from inside the namespace. Each phase's gate is a module build, so a resolution failure surfaces immediately |
| Docstring phase silently skipped — a build will not catch a false docstring | M | H | Phase 6 is a separate gated phase with three literal grep assertions as its verification |
| Aggregator wiring omitted, leaving the new module unreachable-and-unmanifested | M | M | Phase 5 gate runs `bash scripts/check-module-invariants.sh` (C8/C6) in addition to `lake build` |
| Universe-level drift: the prototype states Step 2 at `{D E : Type}`, not `Type*` | L | L | Transcribe at `Type` verbatim. `ValidDiscrete` binds `∀ (D : Type)` and `ValidInt` is at `ℤ`, so `Type` suffices for the headline theorem. A `Type*` generalization is optional and MUST NOT block any phase |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3 | 2 |
| 3 | 4 | 3 |
| 4 | 5 | 1, 4 |
| 5 | 6 | 5 |

Phases within the same wave can execute in parallel. Phases 1 and 2 have disjoint file territory
(Phase 1 owns `Semantics/DurationClassification.lean`; Phase 2 owns the new
`Semantics/IntTransfer.lean`) and neither reads a symbol the other introduces, so they are
genuinely parallel. Phase 5 is the first phase that consumes `intIso` from Phase 1.

---

### Phase 1: Successor-Archimedean block into DurationClassification.lean [COMPLETED]

**Goal**: Land Step 1 — the four declarations that close the successor-Archimedean gap and make
`int_orderAddMonoidIso_of_isLeast_pos` apply.

**Tasks**:
- [x] Add `import Mathlib.Order.SuccPred.Archimedean` to
      `FormalSystem/Semantics/DurationClassification.lean`. (Already in the closure via
      `Semantics/Validity.lean`, so it costs no build time.)
- [x] Transcribe, inside `namespace FormalSystem.Semantics`, after `complete_not_dense_iso_int`
      and before `end FormalSystem.Semantics`, from
      `prototype/verified-prototype.lean` lines 10-50:
      `isLeast_pos_succ_zero`, `succ_eq_add_succ_zero`, `succ_iterate_zero`,
      `archimedean_of_succ`, and `noncomputable def intIso`.
- [x] State the shared `variable` bundle as
      `{D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [SuccOrder D] [Nontrivial D]`,
      with `[IsSuccArchimedean D]` on `archimedean_of_succ` and `intIso` only. Do **not** add
      `PredOrder D` or `IsPredArchimedean D` — they are unused.
- [x] Write a module-level docstring for `archimedean_of_succ` that names it as the successor
      branch companion to `archimedean_of_lub`, mirroring that lemma's docstring style.
- [x] TRAP: in `succ_eq_add_succ_zero`, do not reach for `linarith` — it does not fire on a bare
      `AddCommGroup` + `LinearOrder` (no ring structure). Use `le_sub_iff_add_le` + `add_comm`
      exactly as in the prototype.

**Timing**: 0.75 hours

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: 4 theorems + 1 `noncomputable def` (5 declarations), ~45 lines, 1 added
import, 1 file touched. Confirm at implementation time by counting the transcribed declarations
against prototype lines 13-50 and by `git diff --stat` on the single file; a divergence in either
direction is a signal that the transcription was edited rather than copied.

**Files to modify**:
- `FormalSystem/Semantics/DurationClassification.lean` — one new import; five new declarations
  appended inside the existing namespace.

**Verification**:
- `lake build FormalSystem.Semantics.DurationClassification` green.
- `#print axioms FormalSystem.Semantics.archimedean_of_succ` and
  `#print axioms FormalSystem.Semantics.intIso` each report exactly
  `[propext, Classical.choice, Quot.sound]` — no `sorryAx`.
- `grep -c "sorry" FormalSystem/Semantics/DurationClassification.lean` unchanged from before the
  edit.

---

### Phase 2: New IntTransfer.lean with TaskFrame.map [NOT STARTED]

**Goal**: Create the new module and land the frame transport — all seven `TaskFrame` fields
carried along an arbitrary `e : D ≃+o E`.

**Tasks**:
- [ ] Create `FormalSystem/Semantics/IntTransfer.lean` with the standard copyright header
      (copy the four-line form used by `Semantics/DurationClassification.lean`).
- [ ] Imports: `FormalSystem.Semantics.Validity`, `FormalSystem.Semantics.DurationClassification`,
      `Mathlib.Algebra.Order.Hom.Monoid`, `Mathlib.Algebra.Order.Group.Int`,
      `Mathlib.Data.Int.SuccPred`. (Verified sufficient — the prototype uses exactly this set.)
- [ ] Write the module docstring: what the module is for (normalizing an arbitrary discrete
      duration carrier to ℤ), the `Aligned`-not-`Equiv` design decision, and a `## Main results`
      list. Record the two measured tactic traps so a future editor does not re-hit them.
- [ ] Open `namespace FormalSystem.Semantics` and declare the shared variable bundle from
      prototype lines 59-60: `{D E : Type}` with `[AddCommGroup] [LinearOrder]
      [IsOrderedAddMonoid] [Nontrivial]` on each.
- [ ] Transcribe `TaskFrame.map` from prototype lines 63-107 (all seven fields:
      `WorldState`/`nonempty`, `nullity_identity`, `comp`, `converse`, `serial`, `limit`,
      `spherical`).
- [ ] Note in the `spherical` field's comment that it is discharged by handing `F.spherical` the
      *identical* directed family — no directedness argument is reconstructed.

**Timing**: 1 hour

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: 1 new file, 1 definition, 7 structure fields, ~55 lines of body plus header
and docstring, 5 imports. Confirm by `wc -l` on the new file and by checking that every field name
of `structure TaskFrame` in `FormalSystem/Semantics/TaskFrame.lean` appears exactly once in
`TaskFrame.map` — if `TaskFrame` has a field the map does not set, the build fails and the
hypothesis was wrong.

**Files to modify**:
- `FormalSystem/Semantics/IntTransfer.lean` — new file.

**Verification**:
- `lake build FormalSystem.Semantics.IntTransfer` green.
- No `sorry`, no `axiom` in the new file (`grep -n "sorry\|^axiom" FormalSystem/Semantics/IntTransfer.lean`
  returns nothing).
- Do not wire the aggregator yet — that is Phase 5. The module is intentionally unreachable
  between Phases 2 and 5.

---

### Phase 3: Model/history transport and the Aligned relation [NOT STARTED]

**Goal**: Land `TaskModel.map`, `WorldHistory.map`, `WorldHistory.comap`, and the `Aligned`
machinery that lets `TruthAt`'s `box` clause move in both directions without `HEq`.

**Tasks**:
- [ ] Transcribe from prototype lines 117-151 and 162-190, into `IntTransfer.lean`:
      `TaskModel.map`, `WorldHistory.map`, `structure Aligned`, `aligned_map`, `isTotal_map`,
      `WorldHistory.comap`, `aligned_comap`.
- [ ] MUST: use the `Prop`-valued `Aligned` structure. MUST NOT attempt
      `WorldHistory F ≃ WorldHistory (TaskFrame.map F e)` — round-tripping `map`/`comap` forces a
      dependent structure equality on the `states` field and degenerates into `HEq` wrangling.
      `Aligned.st` is a non-dependent equation between two `F.WorldState` terms because
      `(F.map e).WorldState` is definitionally `F.WorldState`.
- [ ] `aligned_comap`'s single transport is discharged by the tree's **existing**
      `WorldHistory.states_eq_of_time_eq` (`FormalSystem/Semantics/WorldHistory.lean:323`) at
      `n = e (e.symm n)`. Do not write a new transport lemma.
- [ ] Docstring `Aligned` with the design rationale (why a relation, not an `Equiv`).

**Timing**: 1 hour

**Depends on**: 2

**Verification Tier**: local

**Scope Hypothesis**: 7 declarations (3 `def`, 1 `structure`, 3 `theorem`), ~75 lines. Confirm by
enumerating the declaration names in the phase diff against prototype lines 117-190.

**Files to modify**:
- `FormalSystem/Semantics/IntTransfer.lean` — append to the module created in Phase 2.

**Verification**:
- `lake build FormalSystem.Semantics.IntTransfer` green.
- `grep -n "HEq" FormalSystem/Semantics/IntTransfer.lean` returns nothing — an `HEq` appearing is
  the signal that the forbidden `Equiv` route was taken.
- No `sorry`, no `axiom` in the file.

---

### Phase 4: truthAt_map [NOT STARTED]

**Goal**: Land the truth-transfer theorem — the induction on `Formula` that carries `TruthAt`
across the frame transport.

**Tasks**:
- [ ] Transcribe `truthAt_map` from prototype lines 200-271 into `IntTransfer.lean`.
- [ ] Keep the statement's generalization shape exactly as in the prototype: the induction is on
      `φ`, generalizing over **both** histories and the time. That generalization is what makes
      `box` (which swaps the history) and `untl`/`snce` (which move the time) both go through.
      Do not specialize the statement to a fixed `σ`/`t`.
- [ ] TRAP: in the `box` forward case, `(comap e ρ').domain s` follows from `ρ'.domain (e s)`
      *definitionally*. `simpa` normalizes past it and fails. Use the bare term
      `fun s => hρ' (e s)` exactly as in the prototype.
- [ ] Docstring `truthAt_map` naming `box` as the only case that uses `comap`, and `untl`/`snce`
      as pure order transfer.

**Timing**: 1 hour

**Depends on**: 3

**Verification Tier**: local

**Scope Hypothesis**: 1 theorem, 6 `Formula` cases (`atom` ~22 lines, `bot` 1, `imp` 3, `box` 8,
`untl` 17, `snce` 17), ~80 lines total. Confirm at implementation time that the case list matches
the constructor list of `Formula` in `FormalSystem/Syntax/` — a missing case is a build error, an
extra case means the constructor set changed since the prototype was written and the transcription
must be re-checked rather than patched.

**Files to modify**:
- `FormalSystem/Semantics/IntTransfer.lean` — append.

**Verification**:
- `lake build FormalSystem.Semantics.IntTransfer` green.
- `#print axioms FormalSystem.Semantics.truthAt_map` reports exactly
  `[propext, Classical.choice, Quot.sound]`.
- No `sorry`, no `axiom` in the file.

---

### Phase 5: ValidInt, validDiscrete_iff_validInt, and aggregator wiring [NOT STARTED]

**Goal**: Land the headline theorem and make the new module reachable and manifested.

**Tasks**:
- [ ] Transcribe `ValidInt` and `validDiscrete_iff_validInt` from prototype lines 278-290 into
      `IntTransfer.lean` (see "Planner decision: where `ValidInt` lives" — it goes here, **not**
      in `Validity.lean`, and is defined exactly once).
- [ ] Docstring both: `ValidInt` as the ℤ-frame validity predicate, and
      `validDiscrete_iff_validInt` as the carrier-normalization theorem, naming `intIso` as the
      transfer and noting that the forward direction is a single instantiation at ℤ (ℤ discharges
      the whole `ValidDiscrete` binder bundle with zero instance work).
- [ ] Add `import FormalSystem.Semantics.IntTransfer` to `FormalSystem/Semantics.lean`.
- [ ] Add a matching `IntTransfer` bullet to that file's `## Submodules` list, in the same style
      as the neighbouring `DurationClassification` bullet. Both the import and the bullet are
      required — `check-module-invariants.sh` flags the module as unreachable-and-unmanifested if
      either is missing.

**Timing**: 0.75 hours

**Depends on**: 1, 4

**Verification Tier**: full

**Scope Hypothesis**: 1 `def` + 1 `theorem` (~20 lines) in `IntTransfer.lean`, plus exactly 2
edits to `FormalSystem/Semantics.lean` (one import line, one Submodules bullet). Confirm by
`git diff` on `FormalSystem/Semantics.lean` showing exactly those two hunks and nothing else.

**Files to modify**:
- `FormalSystem/Semantics/IntTransfer.lean` — append `ValidInt` and `validDiscrete_iff_validInt`.
- `FormalSystem/Semantics.lean` — one import line, one `## Submodules` bullet.

**Verification**:
- Full `lake build` green.
- `#print axioms FormalSystem.Semantics.validDiscrete_iff_validInt` reports exactly
  `[propext, Classical.choice, Quot.sound]` — no `sorryAx`, no new axiom.
- `bash scripts/check-module-invariants.sh` — C8 (aggregator convention) and C6 (unreachable-module
  rot guard) both pass.
- Task acceptance criteria are met at this phase boundary except the docstring repair (Phase 6).

---

### Phase 6: Repair the three stale docstrings [NOT STARTED]

**Goal**: Remove the three recorded findings that assert the successor-based lemma is absent from
the tree. A build will not catch these; that is why this is a separate gated phase.

**Tasks**:
- [ ] `FormalSystem/Semantics/Validity.lean` (~line 241, in the `ValidDiscrete` docstring):
      the sentence "The successor-based analogue of `DurationClassification.lean`'s
      `archimedean_of_lub` — the missing input to that route — is not in this tree." Rewrite to
      state that it is now present, pointing at `archimedean_of_succ` / `intIso` and at
      `validDiscrete_iff_validInt`.
- [ ] `FormalSystem/Semantics/DurationClassification.lean` (~line 85, in the `archimedean_of_lub`
      docstring): the whole section headed "This is the Dedekind branch only; the discrete branch
      has no analogue in this tree", including the "**is absent**" sentence. Rewrite as *both
      branches present*. Also add `archimedean_of_succ`, `isLeast_pos_succ_zero`, and `intIso` to
      the module docstring's `## Main results` list.
- [ ] `FormalSystem/Semantics/IntNormalForm.lean` (~line 76): "the discrete branch needs the
      successor-based analogue, which is not in the tree." Rewrite to name the landed
      declarations.
- [ ] **Keep the recorded wrong turn in all three places.** The `orderIsoIntOfLinearSuccPredArch`
      finding — that it fits the bundle verbatim but yields only `D ≃o ℤ`, and that durations add
      so an order-only isomorphism cannot carry a frame — remains true and remains the reason the
      route is what it is. Only the "absent"/"not in this tree" claims change.
- [ ] Confirm line numbers before editing; the numbers above are from the planning-time tree and
      may have drifted. Anchor on the quoted sentence text, not the line number.

**Timing**: 0.5 hours

**Depends on**: 5

**Verification Tier**: local

**Scope Hypothesis**: 3 files, 3 stale claims, plus 1 `## Main results` list update in
`DurationClassification.lean`. Confirm at implementation time by running the three greps below
*before* editing (each must have ≥1 hit, proving the target is still there and the plan is not
describing an already-changed tree) and again *after* (each must have 0 hits). If a pre-edit grep
returns 0 hits, stop and re-locate the claim by text rather than assuming it was already fixed.

**Files to modify**:
- `FormalSystem/Semantics/Validity.lean` — one docstring sentence.
- `FormalSystem/Semantics/DurationClassification.lean` — one docstring section plus the
  `## Main results` list.
- `FormalSystem/Semantics/IntNormalForm.lean` — one docstring sentence.

**Verification**:
- `grep -c "is not in this tree" FormalSystem/Semantics/Validity.lean` → 0.
- `grep -rc "has no analogue in this tree" FormalSystem/` → 0 repo-wide.
- `grep -c "which is not in the tree" FormalSystem/Semantics/IntNormalForm.lean` → 0.
- `grep -c "orderIsoIntOfLinearSuccPredArch" FormalSystem/Semantics/IntNormalForm.lean` ≥ 1 — the
  wrong-turn record survived.
- `lake build FormalSystem.Semantics.Validity`,
  `lake build FormalSystem.Semantics.DurationClassification`, and
  `lake build FormalSystem.Semantics.IntNormalForm` each green — Lean doc-comments are attached to
  declarations and do elaborate, so a malformed comment is a build error, not a cosmetic one.
- Final full `lake build` green.

---

## Testing & Validation

- [ ] Full `lake build` green with no new warnings attributable to this task.
- [ ] `#print axioms FormalSystem.Semantics.validDiscrete_iff_validInt` reports exactly
      `[propext, Classical.choice, Quot.sound]` — the task's headline acceptance criterion.
- [ ] Same axiom check clean for `archimedean_of_succ`, `intIso`, and `truthAt_map`.
- [ ] No new `sorry` anywhere: repo `sorry` count unchanged from the pre-task baseline (capture
      the baseline at Phase 1 start).
- [ ] No new `axiom` declaration introduced in any touched file.
- [ ] `bash scripts/check-module-invariants.sh` passes (C8 aggregator convention, C6 reachability).
- [ ] The four docstring greps in Phase 6 return their expected counts.
- [ ] Cross-check against the prototype: re-run
      `lake env lean specs/475_carrier_normalization_successor_archimedean_transfer/prototype/verified-prototype.lean`
      if any transcribed proof needs to be diffed against its verified source.
- [ ] `grep -rn "orderIsoIntOfLinearSuccPredArch" FormalSystem/` shows it referenced only in
      wrong-turn prose, never applied in a proof term.

## Artifacts & Outputs

- `FormalSystem/Semantics/IntTransfer.lean` — new module (~230 lines): `TaskFrame.map`,
  `TaskModel.map`, `WorldHistory.map`, `WorldHistory.comap`, `Aligned`, `aligned_map`,
  `aligned_comap`, `isTotal_map`, `truthAt_map`, `ValidInt`, `validDiscrete_iff_validInt`.
- `FormalSystem/Semantics/DurationClassification.lean` — extended: one import,
  `isLeast_pos_succ_zero`, `succ_eq_add_succ_zero`, `succ_iterate_zero`, `archimedean_of_succ`,
  `intIso`; docstring repair.
- `FormalSystem/Semantics.lean` — one import, one `## Submodules` bullet.
- `FormalSystem/Semantics/Validity.lean` — docstring repair.
- `FormalSystem/Semantics/IntNormalForm.lean` — docstring repair.
- `specs/475_carrier_normalization_successor_archimedean_transfer/summaries/01_carrier-normalization-int-transfer-summary.md`
  — implementation summary.

## Rollback/Contingency

Every phase is additive and independently revertible; the tree is green at each phase boundary, so
`git revert` of a phase commit restores a buildable state.

- Phases 2-5 are confined to one new file plus (at Phase 5) two lines of the aggregator. Deleting
  `FormalSystem/Semantics/IntTransfer.lean` and reverting the two aggregator lines returns the tree
  to its pre-task state with no other change.
- Phase 1 is a pure addition to `DurationClassification.lean`; reverting it removes five
  declarations and one import that nothing outside this task consumes.
- Phase 6 is documentation-only and revertible in isolation.
- If a transcribed proof fails to elaborate in its new namespace, the fallback is **not** to
  weaken the statement or insert a `sorry`: re-elaborate the failing block against
  `prototype/verified-prototype.lean` (which is known-green) and diff the two, since the only
  legitimate difference is namespace and variable-bundle placement. The prototype is the ground
  truth for every proof body in this plan.
