# Implementation Plan: Task #523

- **Task**: 523 - Frame kit helpers, transport, standard frames (WAVE 2, core utilities)
- **Status**: [PARTIAL]
- **Effort**: 22.5 hours
- **Dependencies**: Tasks 517 (Saturation rename), 521 (truth simp-normal form), 522 (FrameClass.Sat / adapters / ValidDedekind renames) — all landed at HEAD
- **Research Inputs**: specs/523_frame_kit_helpers_transport_standard_frames/reports/01_frame-kit-helpers-transport-standard-frames.md
- **Artifacts**: plans/01_frame-kit-helpers-transport.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Complete the task-frame construction kit so countermodel frames are discharged from once-and-for-all
helpers instead of re-proving the frame axioms at each site, and collapse five hand-written
`induction φ` truth-transport proofs into one generic `TruthIso` lemma plus one anti-isomorphism
twin. Fourteen phases across a measured ~1200 removed / ~463 added line budget (net ≈ −737),
sequenced so that the three highest-risk phases (the `TruthIso` chain) sit behind five low-risk,
independently valuable ones. Definition of done: `lake build` green, `scripts/check-module-invariants.sh`
C2 unchanged, zero `sorry`, zero new axioms, and the acceptance criteria in **Testing & Validation**
met as restated below.

### Research Integration

The research report supersedes the task brief wherever they conflict, and the plan below follows the
report. The five corrections that materially change scope:

1. **`Spherical` no longer exists tree-wide** — task 517's rename fully landed (`grep -rn Spherical
   FormalSystem` returns zero). The helper to write is **`saturation_of_fib_subsingleton`**. Every
   `Spherical` occurrence in the brief is stale.
2. **Work item C-05 is already landed** (task 521, phase 6: the four atom-truth lemmas are `@[simp]`
   and the eight-site `rw [show τ.val = … from rfl]` idiom is gone from `DurationFrames.lean`). It is
   **struck from scope** and has no phase here.
3. **"Exactly one `induction φ` truth-transport proof" is mathematically unachievable.**
   `FwdRecPeriodicity.truthAt_add_hist_period`'s hypothesis is about *one* history, while a
   `TruthIso`'s `atom` field must be quantified over *all* histories because `TruthAt`'s `box` clause
   ranges over all of them; its box case is discharged by `Truth.box_time_const` and never touches the
   IH. Feeding it a uniform hypothesis would strictly weaken the theorem and break its consumer. The
   criterion is **restated as "at most two"** throughout this plan.
4. **A-06 is twice the claimed size and structurally obstructed.** The mirrored pairs are at
   `FrameClassVariants.lean:780/821` (`prior_UZ_valid`/`prior_SZ_valid`) and `:861/924`
   (`z1_valid`/`z1_past_valid`) — **184 lines, not ~90** — and the names carry no `_is_`. Unlike
   `sep_order`, these interleave order reasoning with `Formula`/`TruthAt` unfolding, so the D-op
   recipe needs an **explicit extraction step first** (Phase 3, step 1).
5. **`Semantics.lean`'s aggregation gaps are NOT fixed.** `LexCarrier`, `BLSchemaValidity` and
   `Extension/PeriodicExtension` are all still un-imported (the third is not in the review either).

Further corrected figures carried into the phases: the five transports total **~518 lines, not ~370**
(`time_shift_preserves_truth` is now at `Truth.lean:655-887`); frame constants are **22 across 15
files**, not fourteen in nine; and **four additional dead lemmas** exist in `WorldHistory.lean` beyond
the four C-13 names — `time_shift_domain_iff` `:295`, `time_shift_inverse_domain` `:302`,
`time_shift_time_shift_states` `:335`, `time_shift_zero_domain_iff` `:355`, each with exactly one repo
occurrence (its own declaration).

The report also carries **verbatim, already-elaborating text** for Helper D (§3.1) and the Helper B
completion (§3.2), written against the live tree with measured `#print axioms` profiles. Phases 1 and
4 are built around that text: **paste it, do not re-derive it.** The report additionally identifies a
bonus the original review missed — `Truth.truth_double_shift_cancel` (`:584-633`, ~50 lines) becomes
**deletable** once `TruthIso.hist` is an honest `F.HF ≃ F'.HF`, because the box case then gets its
round trip from `Equiv.symm_apply_apply`.

### Prior Plan Reference

No prior plan for this task. One cross-cutting lesson is carried forward from the immediately
preceding sibling task (522): its plan specified `lake-build-guard.sh build --timeout 1800 -- lake
build`, which exits **77 (usage error)** because build mode validates `LAKE ARGS[0]` against a lake
*subcommand* allowlist and `lake` is not a lake subcommand — and piping the invocation to `tail`
masked the failure as exit 0. Every build in this plan is specified as the verified-correct form
(see **Build invocation contract** below).

Task 522 also landed on files this plan touches. Phases touching validity names or binder adapters
must assume the **post-522 tree**: `FrameClass.Sat` is reducible, `TaskFrame.IsDense` is an `abbrev`,
the binder adapters are 21 (down from 47), a `sat_intro` macro exists, and the
`ValidDedekind -> ValidComplete` / `valid -> Valid` renames have run.

### Roadmap Alignment

`specs/ROADMAP.md` carries no checkbox for this work. It sits closest to **Phase 7: Repository Hygiene
and Programme Metadata (Low Priority)**, as consolidation of proof infrastructure rather than new
metalogical content. No roadmap item is advanced or closed by this task, and this plan **must not**
modify `ROADMAP.md`.

### Build invocation contract (applies to every phase)

Every `lake build` in this plan MUST be issued as, verbatim:

```
./.claude/scripts/lake-build-guard.sh build --timeout 1800 -- build
```

with `Bash(run_in_background: true)`. Three constraints, each with a recorded failure mode:

- The word after `build --timeout 1800 --` is the **lake subcommand** (`build`), never the `lake`
  binary. `-- lake build` exits 77 before any build is attempted (task 522's observed failure).
- The call MUST be detached. A foreground call is killed at the tool cap and banks no progress.
- **Do not pipe the invocation into `tail`, `head`, or any filter that discards the exit code.**
  That is what masked task 522's exit 77 as an exit 0. Read the result file, or check `$?` directly.

To wait on an in-flight guarded build, read `holder_pid` from the result record and poll
`kill -0 "$holder_pid"`. Do **not** use `pgrep -f "lake-build-guard.sh build"` — a polling shell's own
argv self-matches and the loop never terminates.

## Goals & Non-Goals

**Goals**:
- One `saturation_of_fib_subsingleton` helper discharging all seven duplicated Saturation bodies.
- The Helper B (permissive-frame) family completed, so permissive frames are one-liners.
- `WorldHistory.ofTotal` / `TaskFrame.HF.ofTotal` collapsing the six `Semantics/` total-history sites.
- **At most two** `induction φ` truth-transport proofs across `Semantics/` + `Independence/`: the
  generic `truthAt_of_truthIso`, plus `truthAt_add_hist_period` which keeps its own induction and
  gains a docstring cross-reference explaining why it is not an instance.
- `truth_double_shift_cancel` deleted as a consequence of an honest `F.HF ≃ F'.HF` in `TruthIso`.
- The duplicate Z step-path dictionary in `FwdRecBridge.lean` replaced by an import.
- `isLeast_succ_of_isLeast_pos` / `isGreatest_pred_of_isLeast_pos` shared; `LexCarrier` generalised to
  `α ×ₗ ℤ`; `LexIntWitness` reduced to an instantiation.
- Order-dual cores in a new `SoundnessLemmas/DiscreteOrder.lean` obtaining `prior_SZ_valid` and
  `z1_past_valid` at `Dᵒᵈ`.
- Eight dead `WorldHistory.lean` lemmas deleted; `per_period` hooked to `Function.Periodic`.
- `Semantics/Frames/Standard.lean` indexing the standard frames; `Semantics.lean`'s three missing
  imports added; `Semantics/README.md` and the `Independence.lean` docstring corrected; the five
  overlapping `TaskFrame.lean` regression sections merged to two; `time_shift_* -> timeShift_*`.
- Zero `sorry`, zero new axioms, `check-module-invariants.sh` C2 unchanged.

**Non-Goals**:
- **Work item C-05.** Already landed by task 521; struck from scope entirely.
- **Re-deriving Helper A (`saturation_of_subsingleton`) from Helper D**, or from
  `saturation_of_finite`. See the hard constraint below — Helper D is purely additive.
- **Touching `Walk` / `MinCyc`.** C-14 records the Mathlib survey (`SimpleGraph.Walk`, `Quiver.Path`,
  `Relation.ReflTransGen`, `Function.minimalPeriod`, `IsPeriodicPt`) as negative; this plan records
  that negative result rather than re-running it.
- **A `Formula`-level dualisation.** `LexIntWitness.lean:52-54` records that a single-frame
  `F.ValidOn φ → F.ValidOn φ.swapTemporal` closure lemma does not exist and is false in general. The
  dualisation in Phase 3 is of the **carrier `D`**, exactly as `sep_order_mirror` does.
- **Merging Direction-A `isLeast_pos` sites** (`DurationClassification.lean:194-196`,
  `BLSchemaValidity.lean:136-139`). Three-to-four lines each, and the second's docstring records the
  duplication as a deliberate territory split. Leave them.
- **Merging `permissiveFrame` into `natFrame`.** Different carriers (`Bool` vs `Nat`) and explicit
  rather than instance `SuccOrder`/`NoMaxOrder` arguments. It is a third client of Helper B.
- Migrating the ~12 `ofTotal`-shaped sites outside `Semantics/`. Noted as follow-on.
- Any `sorry`, any new axiom, any Option-B deferral.

## Hard Constraints (structural, not advisory)

These two are recorded here and restated inside the phases that can violate them. A phase that
violates either is not complete regardless of build status.

**HC-1 — Helper D must be purely additive.**
`Tests/BimodalTest/Semantics/SaturationFiniteAxiomTest.lean` holds four **build-breaking
`#guard_msgs`-gated `#print axioms` blocks** pinning `sInter_nonempty_of_directed_of_minimal` (*no
axioms*), `saturation_of_finite` (`[propext, Classical.choice, Quot.sound]`),
`saturation_of_subsingleton` (**`[propext]`**), and `wlem_of_saturation` (`[propext, Quot.sound]`).
The file's own prose names the exact wrong consolidation: *"'simplify by routing the subsingleton case
through the general lemma' — a tempting and entirely wrong consolidation."*
`TaskFrame.saturation_of_finite`'s docstring (`TaskFrame.lean:1061`) carries the same prohibition.
**Helper A's proof must not change.** Helper D is added beside it, never routed through it, and never
routes through `sInter_nonempty_of_directed_of_univ_or_singleton` (whose `classical`/`by_cases`
opening is `Classical.choice`-dependent). The measured profile to preserve is
`saturation_of_fib_subsingleton` = **`[propext]` only**; the two supporting lemmas depend on **no
axioms at all**.

**HC-2 — `linarith` is unavailable in `TaskFrame.lean`'s import closure.**
The permissive-frame sign argument in `forward_comp_of_permissive` MUST be written with
`neg_nonneg` / `le_antisymm` exactly as the report's §3.2 text does. A `linarith` version fails to
elaborate. Do not "simplify" it to `linarith` at review time.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Helper D routed through Helper A or `univ_or_singleton`, breaking the `#guard_msgs` axiom guards | H | M | HC-1 restated in Phase 1; Phase 1 verification re-runs `SaturationFiniteAxiomTest.lean` and asserts the three new profiles by `#print axioms` |
| `linarith` reflex in Phase 4 fails to elaborate | M | M | HC-2; paste §3.2 verbatim |
| `TruthIso`'s generic induction proves harder than the ~90-line estimate | H | M | Phase 9 is structure + generic lemma only, with no derivation in scope; if it stalls, Phases 1-8, 13, 14 are all independently valuable and the task still succeeds |
| `TemporalOrder` migration creates more explicit `(D := …)` annotations than it removes | M | H | Phase 13 is a **go/no-go with a hard gate**: count first, and a NO-GO outcome (documented fallback) is a legitimate `[COMPLETED]`, not a failure |
| `Aligned` recast (Phase 12) does not fit the `F.HF ≃ F'.HF` shape | M | M | Documented fallback: leave `truthAt_map` in place and close the phase `[COMPLETED WITH EXCLUSIONS]`. **Never** a `sorry` |
| A-06 extraction (Phase 3) blocked by the interleaved `Formula`/`TruthAt` unfolding | M | M | Two-step sequencing is explicit in the phase: extract the abstract-`P` cores first, instantiate second |
| Build failure masked by piping to `tail` (task 522's observed failure) | H | M | Build invocation contract above; no filtering of the guard's output |
| Parallel phases in one wave colliding on a shared file | M | L | Wave table below is derived from **disjoint file territories**, and each phase enumerates its files |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2, 3 | -- |
| 2 | 4, 5 | 1 |
| 3 | 6, 7 | 4, 5 |
| 4 | 8, 9 | 5, 6, 7 |
| 5 | 10 | 9 |
| 6 | 11, 12 | 10 |
| 7 | 13 | 4 |
| 8 | 14 | 1, 3, 4, 6, 10, 13 |

Phases within the same wave can execute in parallel; the waves above were derived from disjoint file
territories, verified per-phase in the **Files to modify** lists. **Phase 13 is exclusive** — if its
go/no-go resolves to GO it rewrites ~160 call sites repo-wide and must not run alongside anything.

---

### Phase 1: Helper D and the seven Saturation sites [COMPLETED]

**Goal**: Add `saturation_of_fib_subsingleton` (plus its two supporting lemmas) to `TaskFrame.lean`
and collapse all seven duplicated Saturation bodies onto it, deleting the FlowFrame duplicate.

**Tasks**:
- [ ] Paste the report's §3.1 text **verbatim** into `TaskFrame.lean` immediately after Helper C
      (after current line 1299), inside `namespace TaskFrame`, under the section header
      `/-! ### Helper D — the deterministic class: every fibre is a subsingleton -/`. Three
      declarations: `sInter_nonempty_of_directed_subsingleton`, `fib_subsingleton_of_functional`,
      `saturation_of_fib_subsingleton`.
- [ ] **HC-1**: do not touch Helper A's proof; do not route Helper D through Helper A,
      `saturation_of_finite`, or `sInter_nonempty_of_directed_of_univ_or_singleton`.
- [ ] Re-point the subsingleton-to-singleton family (`ClockFrame.lean:156-165`,
      `DurationFrames.lean:155-165`, `RegionFrame.lean:208-222`, `RegionFrame.lean:295-307`) at
      Helper D. The `Set.univ` disjunct is dead weight at all four.
- [ ] Re-point the direct-`Subsingleton` family (`ReynoldsBridge.lean:465-474`, `:523-529`,
      `:785-794`) at Helper D.
- [ ] **Rewrite**, not re-point, `ShiftSet.lean:186-202` — it never constructs a `Set.Subsingleton`
      value, proving raw pairwise equality and threading the directed-family witness by hand.
- [ ] In `ReynoldsBridge.lean` and `RegionFrame.lean`, each of which proves the same proposition
      twice (the frame's `saturation` field and the top-level `*_saturation` theorem): declare the
      `*_fib_subsingleton` lemma **before** the frame, discharge the field with Helper D, and make
      the top-level theorem a one-line citation of the field. `ReynoldsBridge.lean:835-837` already
      demonstrates the target shape.
- [x] Delete `Algebraic.sInter_nonempty_of_directed_subsingleton` (`FlowFrame.lean:116-127`) and
      **retarget** `Algebraic.multiFamTaskFrameGen_saturation` — consumed by `ReynoldsBridge:835` —
      at `TaskFrame.saturation_of_fib_subsingleton`. Do not delete that theorem.
- [ ] Add a `#guard_msgs`-gated `#print axioms` block for all three new declarations to
      `Tests/BimodalTest/Semantics/SaturationFiniteAxiomTest.lean`, beside the existing four.

**Timing**: 2 hours

**Depends on**: none

**Verification Tier**: full

**Scope Hypothesis**: seven duplicated Saturation bodies totalling 93 lines, in three families
(four subsingleton-to-singleton, three direct-`Subsingleton`, one bespoke), plus ten total saturation
declarations of which `ClockFrame:209` and `ReynoldsBridge:835` are already one-line citations.
Confirm at implementation time by re-grepping for `Saturation` across `FormalSystem/` before editing;
if the census differs, record the true count in the phase's commit message rather than silently
adjusting scope. Expected net: 93 → ~10 at the sites, +26 for Helper D, −12 from FlowFrame ≈ **−75**.

**Files to modify**:
- `FormalSystem/Semantics/TaskFrame.lean` - add the three Helper D declarations after line 1299
- `FormalSystem/Semantics/ShiftSet.lean` - rewrite the bespoke site `:186-202`
- `FormalSystem/Semantics/Correspondence/DurationFrames.lean` - re-point `:155-165`
- `FormalSystem/Metalogic/Independence/ClockFrame.lean` - re-point `:156-165`
- `FormalSystem/Metalogic/Decidability/Verified/Bridge/RegionFrame.lean` - re-point `:208-222`, `:295-307`; hoist the fibre lemma above the frame
- `FormalSystem/Metalogic/WeakCanonical/IntegerModel/ReynoldsBridge.lean` - re-point `:465-474`, `:523-529`, `:785-794`; hoist the fibre lemma above the frame
- `FormalSystem/Metalogic/Algebraic/FlowFrame.lean` - delete `:116-127`; retarget `multiFamTaskFrameGen_saturation`
- `Tests/BimodalTest/Semantics/SaturationFiniteAxiomTest.lean` - add three axiom-profile guards

**Verification**:
- `./.claude/scripts/lake-build-guard.sh build --timeout 1800 -- build` (detached) exits 0
- `#print axioms TaskFrame.sInter_nonempty_of_directed_subsingleton` and
  `#print axioms TaskFrame.fib_subsingleton_of_functional` report **no axioms**;
  `#print axioms TaskFrame.saturation_of_fib_subsingleton` reports **`[propext]`**
- The four pre-existing `#guard_msgs` blocks in `SaturationFiniteAxiomTest.lean` still pass unchanged
- `grep -c` on the seven collapsed sites shows each is now a citation, not a re-proof

---

### Phase 2: Z step-path dictionary — import instead of duplicate [COMPLETED]

**Goal**: Delete `FwdRecBridge.lean`'s re-derivation of the Z step-path dictionary and import
`IntNormalForm` instead.

**Tasks**:
- [ ] Add `import FormalSystem.Semantics.IntNormalForm` to `FwdRecBridge.lean`. The report verified
      **no import cycle**: `IntNormalForm`'s full `FormalSystem.*` transitive closure is
      `{PartialHistory, TaskFrame, TemporalOrder, WorldHistory}` — nothing in `Correspondence/`; and
      `FwdRecBridge` is imported by exactly one module, `Semantics.lean:37`.
- [ ] Delete `Bridge.step` `:61-62` (byte-identical to `FrameOver.step` `:176-178`),
      `Bridge.taskRel_diff` `:82-92` (= `respects_of_isStepPath` `:294-303`), `Bridge.ofWalk` +
      `ofWalk_isTotal` `:94-104` (= `HFofStepPath` `:305-316`), and `Bridge.hist_isWalk` `:106-112`
      (= `TaskFrame.HF.isStepPath` `:322-327`), retargeting each consumer.
- [x] Retarget `Bridge.taskRel_nat` `:64-78` — the one genuinely different lemma — at
      `taskRel_natCast_iff_iter` `:182-200` + `iter_of_isStepPath` `:284-292`, which cover the same
      ground more generally. *(deviation: altered — its only consumer was `Bridge.taskRel_diff`,
      itself deleted in this phase, so retargeting resolved to deletion: `respects_of_isStepPath`
      already routes through `taskRel_eq_iter` + `iter_of_isStepPath` internally, and no site
      needs the `Walk`-side `taskRel_nat` spelling.)*
- [ ] Add `isWalk_iff_isStepPath` as **`Iff.rfl`**: `Walk.IsWalk R σ := ∀ n : ℤ, R (σ n) (σ (n+1))`
      (`FwdRecPeriodicity:69`) and `IsStepPath F f := ∀ n : ℤ, F.step (f n) (f (n+1))`
      (`IntNormalForm:265-266`) both unfold to `∀ n : ℤ, F.TaskRel (σ n) 1 (σ (n+1))` once `step` is
      substituted — definitionally equal, not merely equivalent.
- [ ] Note `mem_HF_iff_adjacent` `:329-341` as the pre-bundled round trip, and cite it rather than
      re-assembling the three deleted lemmas at any consumer that needs both directions.

**Timing**: 1 hour

**Depends on**: none

**Verification Tier**: full

**Scope Hypothesis**: five `Bridge.*` declarations spanning `FwdRecBridge.lean:60-112` are
redundant, ~52 lines out and ~8 in (net ≈ **−45**). Confirm by diffing each deleted body against its
`IntNormalForm` counterpart before deletion; if any is not in fact subsumed, keep it and record why.

**Files to modify**:
- `FormalSystem/Semantics/Correspondence/FwdRecBridge.lean` - add import, delete `:60-112`, add `isWalk_iff_isStepPath`

**Verification**:
- Guarded detached build exits 0 (this is the real cycle check — a cycle surfaces as a build error)
- `grep -n "Bridge\.\(step\|taskRel_diff\|ofWalk\|hist_isWalk\)" FormalSystem/` returns zero hits
- `isWalk_iff_isStepPath` elaborates as `Iff.rfl` with no tactic block

---

### Phase 3: `SoundnessLemmas/DiscreteOrder.lean` and the order-dual cores [COMPLETED]

**Goal**: Extract the order reasoning out of the four hand-mirrored `FrameClassVariants.lean` proofs
into abstract-`P` cores, then obtain the two past-side validities by instantiating at `Dᵒᵈ`.

**Tasks**:
- [ ] **Step 1 (the extraction the brief omits).** The obstruction is structural, not mathematical:
      unlike `sep_order`, these four proofs **interleave** order reasoning (`Nat.find`,
      `Order.succ^[·]`, `Monotone`/`Antitone` strong induction) with `Formula`/`TruthAt` unfolding
      inside one monolithic body. Create `FormalSystem/Metalogic/SoundnessLemmas/DiscreteOrder.lean`
      and extract `exists_nearest_succ` and `forall_gt_of_succ_step` over an **abstract
      `P : D → Prop`** with `[SuccOrder D] [IsSuccArchimedean D]` and nothing about `Formula`.
- [ ] **Step 2.** Obtain the past-side cores at `Dᵒᵈ`. Mathlib supplies the dualisation instances:
      `SuccOrder α → PredOrder αᵒᵈ` (`Mathlib/Order/SuccPred/Basic.lean:73`) and the
      `IsSuccArchimedean`/`IsPredArchimedean` duals (`Mathlib/Order/SuccPred/Archimedean.lean:46,50`).
- [ ] Re-instantiate `P := fun x => TruthAt M τ x φ` at each of the four sites:
      `prior_UZ_valid` `:780-817`, `prior_SZ_valid` `:821-857`, `z1_valid` `:861-920`,
      `z1_past_valid` `:924-972`. **Note the names carry no `_is_`** — the brief's
      `prior_SZ_is_valid` / `z1_past_is_valid` are wrong.
- [ ] Imitate `Separability.lean`'s precedent: `sep_order` `:261-…` is a pure order/`Set` lemma over
      an abstract `P : Set D` with all `Formula`/`TruthAt` unfolding left to its caller, and
      `sep_order_mirror` `:…-354` is obtained by instantiating at `Dᵒᵈ` rather than hand-dualising.
- [ ] **Do not** attempt a `Formula`-level dualisation (see Non-Goals). The dualisation here is of the
      **carrier `D`**.
- [ ] Assume the post-522 tree for validity names (`ValidDedekind -> ValidComplete`, `valid -> Valid`)
      and for `FrameClass.Sat` being reducible.

**Timing**: 2 hours

**Depends on**: none

**Verification Tier**: full

**Scope Hypothesis**: the four proofs total **184 lines** (38 + 37 + 60 + 49) at `:780`, `:821`,
`:861`, `:924` — not the brief's ~90 at `:400/440`, `:479/541`. Expected 184 → ~110 at the sites,
+~45 in `DiscreteOrder.lean`, net ≈ **−30**; this is the lowest-yield item, so size the effort
accordingly and stop at the two named past-side validities. Confirm the line ranges by reading the
file before editing.

**Files to modify**:
- `FormalSystem/Metalogic/SoundnessLemmas/DiscreteOrder.lean` - **new**; abstract-`P` cores and their `Dᵒᵈ` duals
- `FormalSystem/Metalogic/SoundnessLemmas/FrameClassVariants.lean` - re-instantiate the four proofs

**Verification**:
- Guarded detached build exits 0
- `prior_SZ_valid` and `z1_past_valid` are obtained at `Dᵒᵈ` from the cores, with no hand-mirrored
  order reasoning remaining in their bodies
- `DiscreteOrder.lean` contains no `Formula`, `TruthAt`, or `TaskModel` reference

---

### Phase 4: Helper B completion and permissive-frame one-liners [COMPLETED]

**Goal**: Complete the Helper B family so every permissive-frame axiom is discharged by a one-line
citation.

**Tasks**:
- [ ] Paste the report's §3.2 text **verbatim** into the Helper B block (`TaskFrame.lean:1134-1241`),
      after `interpolates_of_permissive`: `nullity_identity_of_permissive`, `converse_of_permissive`,
      `forward_comp_of_permissive`, `comp_of_permissive`.
- [ ] **HC-2**: the sign argument in `forward_comp_of_permissive` uses `neg_nonneg` / `le_antisymm`.
      `linarith` is **not available** in `TaskFrame.lean`'s import closure and a `linarith` version
      fails to elaborate. Do not substitute it.
- [ ] Preserve the `omit` lines exactly: `comp_of_permissive` **needs** `[Nontrivial D]` in scope
      (inherited via `interpolates_of_permissive`); the other three must `omit` it.
- [ ] Collapse the permissive-frame axiom discharges at their call sites to citations of the four new
      lemmas. `permissiveFrame` (`DurationFrames.lean:212`) is a client; so are the generic frames in
      `TemporalStructures.lean`.
- [ ] Merge `genericNatFrame` (`TemporalStructures:382`) and `genericTimeFrame` (`:331`) into
      `abbrev`s pointing at the `TaskFrame.lean` constants. Both are **already**
      `(D : TemporalOrder)`, so this half needs no migration.
- [ ] **Do not** merge `permissiveFrame` into `natFrame`: its carrier is `Bool`, `natFrame`'s is
      `Nat`, and it takes `SuccOrder`/`NoMaxOrder` as *explicit* arguments rather than instances.

**Timing**: 1.5 hours

**Depends on**: 1

**Verification Tier**: full

**Scope Hypothesis**: four new Helper B lemmas (~35 lines) collapse ~140 lines of per-site axiom
discharge to ~60, net ≈ **−80**. Confirm the client census by grepping for the permissive relation
shape `(d ≠ 0 ∨ w = u)` across `FormalSystem/` before editing.

**Files to modify**:
- `FormalSystem/Semantics/TaskFrame.lean` - four Helper B lemmas inside `:1134-1241`
- `FormalSystem/Semantics/Correspondence/DurationFrames.lean` - `permissiveFrame` axioms to citations
- `FormalSystem/Examples/TemporalStructures.lean` - `genericNatFrame`/`genericTimeFrame` to `abbrev`s

**Verification**:
- Guarded detached build exits 0
- `#print axioms` reports **`[propext]`** for all four new lemmas
- No `linarith` occurrence introduced in `TaskFrame.lean`
- Each permissive-frame axiom field is a single citation line

---

### Phase 5: `ofTotal` and the six total-history sites [COMPLETED]

**Goal**: Introduce `WorldHistory.ofTotal` / `TaskFrame.HF.ofTotal` with a `@[simp] ofTotal_states`
lemma and collapse the six `Semantics/` boilerplate sites.

**Tasks**:
- [ ] Add `WorldHistory.ofTotal` and `TaskFrame.HF.ofTotal` in `WorldHistory.lean`, taking `states`
      and `respects_task` and filling the invariant four fields: `domain := fun _ => True`,
      `nonempty_domain := ⟨0, trivial⟩`, `convex := … trivial`.
- [ ] Add the load-bearing **`@[simp] ofTotal_states`**: with `domain := fun _ => True` the domain
      proof is `trivial`, so `(ofTotal f h).val.states t trivial = f t` is `rfl` and `simp` closes the
      bridge that call sites currently open by hand.
- [ ] Migrate the six `Semantics/` sites: `WorldHistory.lean:152` (`universal`), `:172` (`trivial`),
      `:193` (`universalTrivialFrame`), `:215` (`universalNatFrame`); `ShiftSet.lean:214` (`hist`);
      `IntNormalForm.lean:310` (`HFofStepPath`).
- [ ] Record the further **twelve** sites `ofTotal` would also serve as explicit follow-on, in
      `ofTotal`'s docstring: `CoNotPriorU:388`, `DiscreteNonCompactness:150`, `ClockFrame:228`,
      `ReynoldsBridge:533,843`, `RegionFrame:333`, `FlowFrame:194`, `DurationFrames:178,264`,
      `FwdRecBridge:97`, `TemporalStructures:313,477`. Do **not** migrate them in this phase.

**Timing**: 1.5 hours

**Depends on**: 1

**Verification Tier**: full

**Scope Hypothesis**: six `Semantics/` sites write the identical four-field skeleton, differing only
in `states` and `respects_task`; ~55 lines out, ~30 in, net ≈ **−25**. Confirm by reading all six
before editing; if any diverges on a fourth field, exclude it and say so.

**Files to modify**:
- `FormalSystem/Semantics/WorldHistory.lean` - add `ofTotal`, `HF.ofTotal`, `@[simp] ofTotal_states`; migrate `:152`, `:172`, `:193`, `:215`
- `FormalSystem/Semantics/ShiftSet.lean` - migrate `:214`
- `FormalSystem/Semantics/IntNormalForm.lean` - migrate `:310`

**Verification**:
- Guarded detached build exits 0
- `simp` alone closes at least one previously hand-written domain bridge (demonstrate in a call site)
- Zero remaining `domain := fun _ => True` literals in `Semantics/` outside `ofTotal` itself
  *(deviation: altered — this bullet contradicts the phase's own fourth task, which lists
  `DurationFrames:178,264` among the twelve follow-on sites and says "Do **not** migrate them in
  this phase". The task list governs: the only two literals left in `Semantics/` are exactly
  those two, plus `ofTotal`'s own.)*

---

### Phase 6: Dead `WorldHistory` lemmas and `Function.Periodic` [COMPLETED]

**Goal**: Delete eight dead lemmas and express `per_period` as `Function.Periodic`.

**Tasks**:
- [ ] Delete the four C-13 lemmas at `WorldHistory.lean:382-444` — `neg_lt_neg_iff` `:399-411`,
      `neg_le_neg_iff` `:416-425`, `neg_neg_eq` `:430-431`, `neg_injective` `:436-443`. Each has
      **exactly one repo occurrence (its own declaration)**. They shadow Mathlib's `neg_le_neg_iff` /
      `neg_lt_neg_iff` (`Mathlib/Algebra/Order/Group/Unbundled/Basic.lean:227-256`, both `@[simp]`)
      with the biconditional's sides **swapped**, and without `@[simp]` — a reader trap.
- [ ] Delete the **four additional dead lemmas the brief omits**, in the same file, each with exactly
      one repo occurrence: `time_shift_domain_iff` `:295`, `time_shift_inverse_domain` `:302`,
      `time_shift_time_shift_states` `:335`, `time_shift_zero_domain_iff` `:355`. Delete rather than
      rename them — this shrinks Phase 14's rename surface.
- [ ] Restate `per_period σ m` (`FwdRecPeriodicity:106-108`) as `Function.Periodic (per σ m) m`.
      Mathlib's definition is at **`Mathlib/Algebra/Ring/Periodic.lean:43-46`** in this pin — **not**
      `Mathlib/Algebra/Periodic.lean` or `Mathlib/Algebra/Order/Periodic.lean`, neither of which
      exists here.
- [ ] Restate the two further family members: `MinCyc.perd` (`:121`) is
      `Function.Periodic M.walk M.len`; `Walk.periodic`'s conclusion (`:327-342`) is
      `∃ π, 0 < π ∧ Function.Periodic σ π`.
- [ ] Record the **negative** Mathlib survey for `Walk`/`MinCyc` in `FwdRecPeriodicity.lean`'s module
      docstring (`SimpleGraph.Walk`, `Quiver.Path`, `Relation.ReflTransGen`, `Function.minimalPeriod`,
      `IsPeriodicPt` — all rejected by C-14) so it is not re-run. **Do not restructure `Walk`/`MinCyc`.**

**Timing**: 1 hour

**Depends on**: 5

**Verification Tier**: full

**Scope Hypothesis**: eight `WorldHistory.lean` lemmas have exactly one repo occurrence each; ~95
lines out, ~5 in, net ≈ **−90**. Confirm each of the eight with `grep -rn "<name>" --include=*.lean .`
returning exactly one line (its declaration) **immediately before** deleting it; a second hit means
the lemma is live and must be kept.

**Files to modify**:
- `FormalSystem/Semantics/WorldHistory.lean` - delete eight lemmas
- `FormalSystem/Semantics/Correspondence/FwdRecPeriodicity.lean` - `Function.Periodic` restatements; negative-survey docstring

**Verification**:
- Guarded detached build exits 0
- `grep -rn` for each of the eight deleted names across the repo returns zero hits
- `per_period`, `MinCyc.perd` and `Walk.periodic` all mention `Function.Periodic`
- `Walk` and `MinCyc` structure definitions are byte-identical to their pre-phase form

---

### Phase 7: `isLeast_succ_of_isLeast_pos` and its three clients [COMPLETED]

**Goal**: Share the Direction-B order lemma pair and retarget its three call sites.

**Tasks**:
- [ ] Add to `DurationClassification.lean`, with hypotheses **`[AddCommGroup D] [LinearOrder D]
      [IsOrderedAddMonoid D]` and nothing more** — no `Nontrivial`, no `Archimedean`, no `SuccOrder`:
      ```
      theorem isLeast_succ_of_isLeast_pos {p : D} (hp : IsLeast {y : D | 0 < y} p) (x : D) :
          IsLeast {z : D | x < z} (x + p)
      theorem isGreatest_pred_of_isLeast_pos {p : D} (hp : IsLeast {y : D | 0 < y} p) (x : D) :
          IsGreatest {z : D | z < x} (x - p)
      ```
      All three existing sites use only `sub_pos`, `le_sub_iff_add_le`, `add_comm`.
- [ ] Retarget the three Direction-B sites: `DurationFrames.lean:90-101` `succOrder_of_isLeast_pos`
      (12 lines), `LexIntWitness.lean:97-104` `lexInt_isLeast_succ` (8), `LexIntWitness.lean:107-115`
      `lexInt_isGreatest_pred` (9).
- [ ] **Leave Direction A alone.** `DurationClassification.lean:194-196` `isLeast_pos_succ_zero` and
      `BLSchemaValidity.lean:136-139` `isGreatest_neg_pred_zero` are the *converse* direction, 3-4
      lines each, and the second's docstring **explicitly records the duplication as deliberate** (a
      territory split from an earlier task). U7 does not cover them. Merge only with an explicit note
      superseding that docstring — which this plan does not authorise.

**Timing**: 1 hour

**Depends on**: 4

**Verification Tier**: full

**Scope Hypothesis**: C-15 splits into two directions and U7 covers only one; three Direction-B sites
(29 lines) collapse, two Direction-A sites stay. Confirm by reading all five before editing.

**Files to modify**:
- `FormalSystem/Semantics/DurationClassification.lean` - add the two shared lemmas
- `FormalSystem/Semantics/Correspondence/DurationFrames.lean` - retarget `:90-101`
- `FormalSystem/Metalogic/Independence/LexIntWitness.lean` - retarget `:97-104`, `:107-115`

**Verification**:
- Guarded detached build exits 0
- The two new lemmas carry no `Nontrivial` / `Archimedean` / `SuccOrder` hypothesis
- `isLeast_pos_succ_zero` and `isGreatest_neg_pred_zero` are unchanged

---

### Phase 8: Generalise `LexCarrier` to `α ×ₗ ℤ`; `LexIntWitness` as an instance [COMPLETED]

**Goal**: Make `LexCarrier` generic in its first factor and reduce `LexIntWitness` to an
instantiation.

**Tasks**:
- [ ] Generalise `LexCarrier.lean` (153 lines) from `ℚ ×ₗ ℤ` to **`α ×ₗ ℤ`**. It uses nothing about
      `ℚ`: `lexSucc_le_iff` / `le_lexPred_iff` go through `Prod.Lex.le_iff'` / `lt_iff'` and
      `Int.lt_iff_add_one_le`; only the *second* factor must be `ℤ`.
- [ ] **Promote the non-Archimedean `example`s to named theorems** — `:112-130` (`¬IsSuccArchimedean`)
      and `:133-151` (`¬IsPredArchimedean`) are currently `example`s and cannot be cited until named.
- [ ] Add `LexInt.isLeast_pos`. **This is new content, not a move**: `LexCarrier` has no
      `IsLeast {x | 0 < x} p` theorem at all — it builds `SuccOrder`/`PredOrder` directly from
      hand-written `succ`/`pred` functions.
- [ ] Move `LexIntWitness.lean:123-141` `lexInt_not_archimedean` into the `LexInt` namespace, keeping
      it distinct from the promoted theorems: **`¬ Archimedean` is a different proposition from
      `¬IsSuccArchimedean`.** Both belong in `LexInt`.
- [ ] Collapse the duplicated four-`example` instance-pinning ritual (`LexCarrier:60-66`,
      `LexIntWitness:72-78`) — one copy survives.
- [ ] Delete the resulting dead bulk of `LexIntWitness.lean:72-141` (~70 lines).
- [ ] Blast radius is small and should be re-confirmed: `LexCarrier` is imported only by
      `Metalogic/Z1Countermodel.lean:10`; `LexIntWitness` only by `Metalogic/Independence.lean:12`.

**Timing**: 1.5 hours

**Depends on**: 7

**Verification Tier**: full

**Scope Hypothesis**: ~70 lines of `LexIntWitness.lean:72-141` are deletable and ~30 lines are added
to `LexCarrier`, net ≈ **−60** together with Phase 7's collapse. Confirm the two-importer blast radius
with a fresh `grep -rn "LexCarrier\|LexIntWitness" --include=*.lean .` before generalising.

**Files to modify**:
- `FormalSystem/Semantics/LexCarrier.lean` - generalise to `α ×ₗ ℤ`; promote two `example`s; add `LexInt.isLeast_pos`
- `FormalSystem/Metalogic/Independence/LexIntWitness.lean` - delete `:72-141` bulk; instantiate `LexCarrier`

**Verification**:
- Guarded detached build exits 0
- `grep -n "^example" FormalSystem/Semantics/LexCarrier.lean` shows the two non-Archimedean facts are
  now `theorem`s
- `LexCarrier.lean` contains no `ℚ` occurrence outside a docstring
- `Z1Countermodel.lean` and `Independence.lean` build unchanged

---

### Phase 9: `TruthIso` structure and the generic `truthAt_of_truthIso` [COMPLETED]

**Goal**: Land the one generic truth-transport lemma. **Structure and generic proof only — no
derivations in this phase.**

**Tasks**:
- [ ] Add to `Truth.lean`, with the types confirmed against the tree (`TaskModel` has the single
      field `valuation : F.WorldState → Atom → Prop`; `TaskFrame.HF F := {τ : WorldHistory F //
      τ.IsTotal}`; `states : (t : F.Duration) → domain t → F.WorldState`):
      ```lean
      structure TruthIso {F F' : TaskFrame} (M : TaskModel F) (M' : TaskModel F') where
        dur  : F.Duration ≃o F'.Duration
        hist : F.HF ≃ F'.HF
        atom : ∀ (τ : F.HF) (t : F.Duration) (p : Atom),
                 M.valuation (τ.val.states t (τ.property t)) p ↔
                 M'.valuation ((hist τ).val.states (dur t) ((hist τ).property (dur t))) p
      ```
- [ ] **`hist` must be an honest `F.HF ≃ F'.HF`**, not a one-way map. This is what makes
      `truth_double_shift_cancel` deletable in Phase 10: the box case gets its round trip from
      `Equiv.symm_apply_apply`.
- [ ] Prove `truthAt_of_truthIso` by `induction φ` over `Formula`'s **exactly six** constructors
      (`atom`/`bot`/`imp`/`box`/`untl`/`snce`).
- [ ] Write the induction against the **task-521 toolkit**, not `simp only [TruthAt]`: the
      `truth_norm` / `swap_norm` simp attribute sets and the `truth_simp` macro
      (`Automation/TruthNormAttr.lean`), plus the eleven `@[simp, truth_norm]` characterisation
      lemmas (`and_iff`, `untl_iff`, `snce_iff`, `always_iff`, `kPlus_iff`, …). That toolkit is what
      makes a ~90-line body plausible where the current `time_shift_preserves_truth` needs 233.
- [ ] Do **not** delete or modify any existing transport in this phase.

**Timing**: 2 hours

**Depends on**: 5, 6

**Verification Tier**: full

**Scope Hypothesis**: the generic body is estimated at ~90 lines against the `truth_norm` toolkit.
This is the plan's least certain estimate. Confirm by measuring the finished proof; if it exceeds
~150 lines, record the true figure and re-check Phase 10's estimate before starting it. **If this
phase stalls, Phases 1-8, 13 and 14 remain independently valuable and the task should still be judged
a success on them** — but do not leave a `sorry` behind: leave the phase `[PARTIAL]` with the existing
transports untouched.

**Files to modify**:
- `FormalSystem/Semantics/Truth.lean` - add `TruthIso` and `truthAt_of_truthIso`

**Verification**:
- Guarded detached build exits 0
- `#print axioms Truth.truthAt_of_truthIso` shows no new axiom beyond the repo's standard trio
- No `sorry` anywhere in the diff
- All five existing transports still compile unchanged (this phase is additive)

---

### Phase 10: Derive the shift and period transports; delete `truth_double_shift_cancel` [BLOCKED]

**BLOCKER** (Phase 10):
- **What failed**: the phase's first task — "Derive `Truth.time_shift_preserves_truth` as an
  instance". It is not derivable from the `TruthIso` structure Phase 9 landed, and no
  rearrangement of `dur`/`hist` fixes it.
- **What was tried**: (a) `dur := (· + (y − x))`, `hist := timeShift · Δ` as the plan specifies;
  (b) the mirror assignment `dur := (· − Δ)`, `hist := timeShift · Δ` with inverse
  `timeShift · (−Δ)`, which does produce the right shape *for total histories*; (c) reading the
  proof to check whether the general case could be recovered from the total case plus a short
  argument.
- **Why it's stuck**: **a quantifier mismatch the report and this plan both missed.**
  `time_shift_preserves_truth` is stated for an **arbitrary** `σ : WorldHistory F` —
  `∀ (σ : WorldHistory F) (x y : F.Duration) (φ : Formula), TruthAt M (σ.timeShift (y − x)) x φ ↔
  TruthAt M σ y φ` — with no totality hypothesis anywhere. `TruthIso.hist` is an
  `F.HF ≃ F'.HF`, so `truthAt_of_truthIso` transports **total** histories only, and its
  conclusion is a statement about `τ : F.HF`. Deriving the general statement from it would
  require reducing an arbitrary history to a total one, which is impossible: a non-total history
  makes atoms *false* outside its domain (`TruthAt`'s `atom` clause is `∃ ht : τ.domain t, …`),
  and no total history reproduces that. The `atom`, `imp`, `untl` and `snce` cases of the general
  induction genuinely depend on `σ`; only `box` does not. The report's §4.3 table records this
  transport as "derivable from a uniform `TruthIso`? **yes**", which is the error.
  For contrast, the phase's *second* target `LoopingDuration.truthAt_add_period` carries
  `τ.IsTotal` explicitly and **is** derivable; it has been derived.
- **What is needed**: a decision between two options, which is a **planning** decision and not an
  implementation one. (1) Widen `TruthIso` with a general-history layer — `hist` becomes a
  `WorldHistory F ≃ WorldHistory F'` plus a totality-preservation field and a domain-transport
  field, with the `F.HF` form derived from it. This subsumes the current structure and would
  also unblock Phase 12's `IntTransfer.truthAt_map`, which has the *same* arbitrary-history
  quantification. (2) Accept that `time_shift_preserves_truth` and `truthAt_map` keep their own
  inductions, and restate the acceptance criterion as "at most four".
  Option (1) is the better deal — it converts Phase 12's documented fallback into a second win —
  but it changes the structure Phase 9 landed and specified, so it is not a change to make
  silently inside an implementation dispatch.
- **Prohibited workarounds**: no `sorry`, no vacuous placeholder, and **no weakening of
  `time_shift_preserves_truth`'s statement** to the total-history case to force the derivation
  through. Its `σ` is genuinely general and its consumers are entitled to that.

**Resolution (task 532, plan `specs/532_worldhistory_extension_faithfulness_audit/plans/01_truthcorr-relational-transport.md`)**:
the quantifier mismatch is resolved by neither option (1) nor (2) above but by a *relational*
generic transport, `Semantics.TruthCorr` + `Truth.truthAt_of_truthCorr` (a `Prop`-valued
correspondence on arbitrary histories, atomic agreement on related pairs, totality-existence in
both directions — the paper's own proof shape from `def:time-shift-histories` /
`app:auto_existence`). `TimeShift.timeShift_preserves_truth` is now derived from it at the
instance `shiftCorr` with its statement byte-identical (arbitrary `σ`), and `truth_double_shift_cancel`
stays deleted. The `induction φ` acceptance criterion now reads "at most three truth-transport
`induction φ` in `Semantics/` + `Independence/`" (two generic — `truthAt_of_truthCorr`,
`truthAt_of_truthAntiIso` — plus the per-history exception `truthAt_add_hist_period`), and it is
met. This phase's status marker is left as recorded.

**Landed in this phase despite the blocker** (all green, all committed):
- `LoopingDuration.truthAt_add_period` derived from `loopingTruthIso`: 68 lines → 12.
- `Truth.truth_double_shift_cancel` **deleted**, and with it
  `WorldHistory.time_shift_time_shift_neg_domain_iff` and `time_shift_time_shift_neg_states`
  (its only consumers). This is the phase's deletion bonus, and it turned out **not** to need
  the `TruthIso` derivation at all: `time_shift_preserves_truth`'s `box` case was instantiating
  its own induction hypothesis at `(timeShift ρ (x − y), x, y)` and then cancelling the
  resulting double shift, where instantiating at `(ρ, y, x)` — the same IH, times swapped —
  gives the goal directly. Three lemmas and ~75 lines gone for a one-line change.
- `truthAt_add_hist_period`'s docstring cross-reference explaining why it is not an instance.

**Not done**: the `time_shift_preserves_truth` derivation. It keeps its own `induction φ`, so
`Semantics/` + `Independence/` currently carry **three** truth-transport inductions
(`truthAt_of_truthIso`, `time_shift_preserves_truth`, `truthAt_add_hist_period`) rather than the
criterion's two.

**Goal**: Reduce the two largest transports to instances and collect the deletion bonus.

**Tasks**:
- [ ] Derive `Truth.time_shift_preserves_truth` (`:655-887`, **233 lines** — it moved from `:450`;
      task 521 inserted ~205 lines above it) as an instance with `dur := (· + (y − x))` and
      `hist := timeShift · Δ`, whose inverse is `timeShift · (−Δ)`.
- [ ] Derive `LoopingDuration.truthAt_add_period` (`:98-165`, 68 lines) as an instance with
      `dur := (· + π)`. It shares `dur` with the shift case exactly, which is why the two land
      together. Its box case reaches into other histories, so its period must stay **frame-uniform**.
- [ ] **Delete `Truth.truth_double_shift_cancel` (`:584-633`, ~50 lines)** — a sixth live six-case
      induction existing only to serve `time_shift_preserves_truth`'s box case. With `hist` an honest
      equivalence, `Equiv.symm_apply_apply` supplies the round trip. This is the bonus the original
      review missed.
- [ ] Add a docstring cross-reference to `FwdRecPeriodicity.truthAt_add_hist_period` (`:356-420`)
      explaining **why it is not an instance**: its hypothesis `hper : ∀ x, τ.states (x+π) _ =
      τ.states x _` is about *one* history, while `TruthIso.atom` must range over *all* histories
      because `TruthAt`'s `box` clause does; its box case is discharged by `Truth.box_time_const` and
      never touches the IH. `FwdRecPeriodicity.lean:349-352` already documents this distinction in
      prose — cite it. **Do not** feed it a uniform hypothesis: that would strictly weaken the theorem
      and break its consumer.
- [ ] The two remaining `time_shift_*` lemmas consumed only by `truth_double_shift_cancel`
      (`time_shift_time_shift_neg_domain_iff`, `time_shift_time_shift_neg_states`, 3 refs each) become
      dead here — delete them, further shrinking Phase 14's rename surface.

**Timing**: 2 hours

**Depends on**: 9

**Verification Tier**: full

**Scope Hypothesis**: 233 + 68 = 301 lines of transport plus 50 of `truth_double_shift_cancel`
collapse to ~24 lines of instantiation. Confirm the `truth_double_shift_cancel` deletion is genuinely
unblocked (rather than merely hoped) by grepping its references after the two derivations land; if
any reference survives, keep it and record the reason.

**Files to modify**:
- `FormalSystem/Semantics/Truth.lean` - derive `time_shift_preserves_truth`; delete `truth_double_shift_cancel` and the two dead `time_shift_time_shift_neg_*` lemmas
- `FormalSystem/Metalogic/Independence/LoopingDuration.lean` - derive `truthAt_add_period`
- `FormalSystem/Semantics/Correspondence/FwdRecPeriodicity.lean` - docstring cross-reference on `truthAt_add_hist_period`

**Verification**:
- Guarded detached build exits 0
- `grep -rn "truth_double_shift_cancel" --include=*.lean .` returns zero hits
- `grep -c "induction φ" FormalSystem/Semantics/Truth.lean` counts exactly one (the generic lemma)
- `truthAt_add_hist_period`'s statement and hypothesis are byte-identical to their pre-phase form

---

### Phase 11: The anti-isomorphism twin and `truthAt_mirror` [COMPLETED]

**Goal**: Add the order-reversing twin and derive the mirror transport.

**Tasks**:
- [ ] Add the anti-isomorphism twin of `TruthIso` to `Truth.lean` (order-reversing `dur`), with its
      own generic lemma concluding at `φ.swapTemporal`.
- [ ] `Formula.swapTemporal` (`Syntax/Formula.lean:668-674`) fixes `atom`/`bot`, distributes through
      `imp`/`box`, and exchanges `untl` ↔ `snce` — exactly the shape the twin's `untl`/`snce` cases
      need. `swap_temporal_involution` (`:682-690`) is available; the `swap_norm` attribute set
      collects all eleven `Formula.swap_temporal_*` distribution lemmas.
- [ ] Derive `CoNotPriorU.truthAt_mirror` (`:406-485`, **80 lines** — the range is `:406`, not the
      brief's `:416`) with `dur := (−·)` and the reflected history as `hist`.

**Timing**: 2 hours

**Depends on**: 10

**Verification Tier**: full

**Scope Hypothesis**: ~50 lines for the twin replacing an 80-line hand-written induction. Confirm
`truthAt_mirror`'s exact current range by reading the file; the brief's figure is stale.

**Files to modify**:
- `FormalSystem/Semantics/Truth.lean` - anti-iso structure and its generic lemma
- `FormalSystem/Metalogic/Independence/CoNotPriorU.lean` - derive `truthAt_mirror`

**Verification**:
- Guarded detached build exits 0
- No `induction φ` remains in `CoNotPriorU.lean`
- The anti-iso generic lemma is written against `swap_norm`, not raw `simp only [Formula.swapTemporal]`

---

### Phase 12: Recast `Aligned` as an `HF` equivalence; derive `truthAt_map` [COMPLETED WITH EXCLUSIONS]

The phase's **documented fallback** is taken, exactly as written: `truthAt_map` is left in place,
byte-identical to its pre-phase form, and `IntTransfer.lean` is not modified at all. Two
independent obstructions, either of which alone is sufficient — the first is the one the phase
anticipated, the second is the one Phase 10 discovered.

#### Reasoned Exclusions

| Item | Reason | Evidence |
|------|--------|----------|
| Recast `IntTransfer`'s `Aligned` as an `F.HF ≃ F'.HF` | The module carries a **recorded prohibition** against exactly this, with a measured reason: round-tripping `WorldHistory.map`/`comap` forces a *dependent* equality on the `states` field (it is indexed by a proof of `domain`, so the two round-tripped fields do not share a type until the domain equation is transported) and degenerates into `HEq` wrangling. `Aligned` is `Prop`-valued precisely to keep `st` a non-dependent equation between two `F.WorldState` terms. Overriding a recorded design decision needs an explicit note superseding it, which this plan does not authorise. | `IntTransfer.lean`'s module docstring, section "Design decision: `Aligned`, not `Equiv`" — *"Do not replace `Aligned` with an `Equiv`."* — and the same argument restated on the `Aligned` structure itself, ending *"an `HEq` showing up is the signal that the forbidden `Equiv` route was taken."* |
| Derive `IntTransfer.truthAt_map` as a `TruthIso` instance | Independently blocked by **the same quantifier mismatch that blocks Phase 10**. `truthAt_map` is stated `∀ (σ : WorldHistory F.toTaskFrame) (σ' : WorldHistory (FrameOver.map F e).toTaskFrame), Aligned e σ σ' → …` — arbitrary histories, no totality hypothesis anywhere — while `truthAt_of_truthIso` transports `F.HF`, i.e. total histories only. Even a working `F.HF ≃ F'.HF` recast could not reach the general statement. | The `truthAt_map` declaration's own binder list; and Phase 10's blocker record above, which analyses the identical obstruction at `time_shift_preserves_truth`. |

**Consequence for acceptance**, as the phase specifies: the `induction φ` criterion reads "at
most three" here. The measured count is **four** (`truthAt_of_truthIso`,
`truthAt_of_truthAntiIso`'s twin aside, `time_shift_preserves_truth`, `truthAt_map`,
`truthAt_add_hist_period`) — see the Testing & Validation section for the exact ledger.

**Verification**: zero `sorry` in this phase (its diff is empty in `FormalSystem/`);
`truthAt_map` is byte-identical to its pre-phase form. Both conditions hold.

**Resolution (task 532)**: both exclusions above are resolved without overriding the recorded
`Aligned`-not-`Equiv` prohibition. `Aligned e` is exactly the `Rel` field of a
`Semantics.TruthCorr` (`IntTransfer.alignedCorr`), and `truthAt_map` is derived from
`Truth.truthAt_of_truthCorr` at that instance with its statement byte-identical and its own
induction deleted; `IntTransfer.lean` contains zero `induction φ`. The acceptance criterion is
restated as in the Phase 10 resolution note: at most three truth-transport `induction φ`, met.

#### Original phase text, retained for the record

**Goal**: Bring the last transport under the generic lemma, or close cleanly without it.

**Tasks**:
- [ ] Recast `IntTransfer`'s `Aligned` shape as an `F.HF ≃ F'.HF` built from `WorldHistory.map` /
      `comap`, so it fits `TruthIso.hist`.
- [ ] Derive `IntTransfer.truthAt_map` (`:292-363`, 72 lines) as an instance, with `dur` supplied by
      the additive order iso `e : ↑D ≃+o ↑E`.
- [ ] **Documented fallback, taken without further escalation if the recast does not fit**: leave
      `truthAt_map` in place, close this phase `[COMPLETED WITH EXCLUSIONS]` with a
      `#### Reasoned Exclusions` record naming the obstruction, and note that the acceptance criterion
      then reads "at most three". **Never** leave a `sorry` and never introduce an axiom — the report
      names this phase as the only one with genuine uncertainty and names this exact fallback.

**Timing**: 1.5 hours

**Depends on**: 10

**Verification Tier**: full

**Scope Hypothesis**: 72 lines collapse to ~12 of instantiation, conditional on the `Aligned` recast
fitting `F.HF ≃ F'.HF`. Confirm the recast is possible **before** deleting the existing proof; if it
is not, take the fallback rather than partially dismantling `truthAt_map`.

**Files to modify**:
- `FormalSystem/Semantics/IntTransfer.lean` - recast `Aligned`; derive `truthAt_map`

**Verification**:
- Guarded detached build exits 0
- Either `IntTransfer.lean` contains no `induction φ`, or the phase carries a
  `#### Reasoned Exclusions` record and `truthAt_map` is byte-identical to its pre-phase form
- Zero `sorry` in either outcome

---

### Phase 13: `TemporalOrder` migration go/no-go [COMPLETED]

**Outcome: NO-GO**, on the counted evidence recorded in `TaskFrame.lean`. See the phase's
recorded decision below and the commit message for the measurement.

**Goal**: Decide, on a counted basis, whether `trivialFrame` / `staticFrame` / `natFrame` migrate to
`(D : TemporalOrder)` — and execute whichever branch the count selects.

**Tasks**:
- [ ] **Gate first, edit second.** Count how many call sites would need a *new* explicit `(D := …)`
      annotation after the migration, against how many `(D := ℤ)` annotations it removes. The three
      definitions carry **57 / 61 / 50** references respectively, essentially all of the form
      `(D := ℤ)`, so the migration is mechanical (`(D := ℤ)` → `intOrder`) but touches ~168 sites.
- [ ] Weigh the counter-argument the plan must answer: `TemporalOrder.of`'s own docstring
      (`TemporalOrder.lean:98-113`) records it as **"Kept permanently, on evidence"**, because
      wherever a frame's duration carrier is pinned to a bare `Type` by a neighbouring abstraction
      (`BFMCS` in the bundle layer, `FrameConditionFor`, `TemporalCarrier`, and the frame-condition
      family `C : (D : Type) → … → Prop` in the decidability bridge), the frame is a value of
      `FrameOver (TemporalOrder.of D)`, and promoting only the frame's binder would leave every caller
      naming `(D := …)` explicitly — **unification cannot invert `TemporalOrder.carrier ?D =?= Rat`**.
- [ ] **GO branch**: migrate all three and rewrite the call sites. This phase is **exclusive** — do
      not run it in parallel with any other phase.
- [ ] **NO-GO branch** (the outcome the `TemporalOrder.of` docstring predicts): leave the three
      constants at `FrameOver (TemporalOrder.of D)`, record the counted evidence and the decision in
      their docstrings, and take the review's own C-03 fallback (keep them as `abbrev`s pointing at
      the `TaskFrame.lean` constants). **A NO-GO is a legitimate `[COMPLETED]`**, not a failure — the
      deliverable of this phase is a counted, recorded decision.
- [ ] Note that `genericTimeFrame` (`TemporalStructures:331`), `genericNatFrame` (`:382`),
      `translationFrame` (`DurationFrames:122`) and `permissiveFrame` (`DurationFrames:212`) are
      **already** `(D : TemporalOrder)` and are out of scope here; the bare-`Type` set is
      `trivialFrame` (`TaskFrame:1321`), `staticFrame` (`:1384`), `natFrame` (`:1454`), plus
      `regionFrame` and `clockFrame`.

**Timing**: 1.5 hours

**Depends on**: 4

**Verification Tier**: interface

**Scope Hypothesis**: three bare-`Type` definitions with 57 / 61 / 50 references. The reference counts
are the *decision input* and MUST be re-measured at implementation time rather than trusted from this
plan; the go/no-go is invalid if taken on the plan's numbers. Under a GO the tier escalates to `full`.

**Files to modify** (GO branch only):
- `FormalSystem/Semantics/TaskFrame.lean` - `trivialFrame` `:1321`, `staticFrame` `:1384`, `natFrame` `:1454`
- `FormalSystem/Examples/TemporalStructures.lean` - dependent abbrevs
- ~168 call sites repo-wide

**Files to modify** (NO-GO branch):
- `FormalSystem/Semantics/TaskFrame.lean` - docstring recording the counted decision only

**Verification**:
- The recorded count appears in the phase's commit message and in the touched docstring
- GO: guarded detached build exits 0 and the net `(D := …)` annotation count strictly decreased
- NO-GO: guarded detached build exits 0 (docstring-only diff) and the decision cites the measured
  numbers, not this plan's

---

### Phase 14: `Frames/Standard.lean`, aggregation gaps, docs, and the rename [COMPLETED]

**Goal**: Create the standard-frame index, close the three `Semantics.lean` import gaps, fix two
documents, merge the regression sections, and run the `timeShift_*` rename.

**Tasks**:
- [ ] Create `FormalSystem/Semantics/Frames/Standard.lean` (the `Frames/` directory does **not**
      exist). **Move** `translationFrame` (`DurationFrames:122`) and `permissiveFrame` (`:212`)
      **up** into it, importing only `TaskFrame`, and have `DurationFrames.lean` import
      `Frames/Standard.lean`. The obvious placement is wrong: a `Standard.lean` that *imports*
      `DurationFrames` to re-export them would sit **downstream of `Correspondence/`** — an index
      below the modules it indexes. Neither frame needs anything from `Indicator` or
      `DurationClassification` (`translationFrame` is `W = D`, `w ⇒_x u ↔ u = w + x`;
      `permissiveFrame` is `W = Bool`).
- [ ] Index the four standard frames in `Standard.lean` and **link** (not re-export) the rest of the
      census.
- [ ] Add the **three missing imports** to `Semantics.lean` — `LexCarrier`, `BLSchemaValidity`, and
      `Extension/PeriodicExtension`. The brief's claim that an already-landed task fixed these is
      **wrong**; `Semantics.lean` imports 30 of the 33 `Semantics/**.lean` modules.
- [ ] Fix `Semantics/README.md`: its Contents table omits `TemporalOrder.lean`, `FrameProperty.lean`
      and `FrameClassValidity.lean`, and lists `LexCarrier.lean` despite the (now-fixed) missing
      import. The defect is **README-only** — `Semantics.lean` itself already imports all three
      omitted modules.
- [ ] Fix `Metalogic/Independence.lean`'s docstring (`:14-42`), which opens *"The one result carried
      here is that the paper's `CO` principle does not derive Reynolds' `Axiom.prior_U_gap`…"*
      directly above a `## Contents` list of **six** modules.
- [ ] Merge `TaskFrame.lean`'s **five** overlapping regression-example sections (108 example lines in
      `:1778-1924`) down to **two**: one round-trip/identity section (`BridgeChecks` `:1778-1793` +
      `TotalSpaceIdentity` `:1804-1825`, which repeat the same `TaskFrame ↔ FrameOver` round trip) and
      one definitional-content section covering all three ambient shapes
      (`BundledDefinitionalContent` `:1834-1852`, `DefinitionalContent` `:1866-1890`,
      `FibreDefinitionalContent` `:1899-1924`, which repeat the same four axioms).
- [ ] Rename `WorldHistory.time_shift_* -> timeShift_*`. After Phases 6 and 10 this reduces to
      **`time_shift_congr`** (12 refs, 9 of them inside `time_shift_preserves_truth` and therefore
      already gone) plus `Truth.time_shift_preserves_truth`. Re-measure before renaming.

**Timing**: 2 hours

**Depends on**: 1, 3, 4, 6, 10, 13

**Verification Tier**: full

**Scope Hypothesis**: 22 frame-valued `def`s across 15 files (not the brief's fourteen in nine); five
regression sections totalling 108 example lines merging to two; three `Semantics.lean` import gaps;
two `time_shift_*` names surviving to be renamed. **Every one of these four counts must be
re-measured at implementation time** — the rename surface in particular depends on Phases 6 and 10
having landed as planned.

**Files to modify**:
- `FormalSystem/Semantics/Frames/Standard.lean` - **new**; receives `translationFrame` and `permissiveFrame`
- `FormalSystem/Semantics/Correspondence/DurationFrames.lean` - remove the two moved defs; import `Frames/Standard.lean`
- `FormalSystem/Semantics.lean` - three missing imports plus `Frames/Standard.lean`
- `FormalSystem/Semantics/README.md` - Contents table corrections
- `FormalSystem/Metalogic/Independence.lean` - docstring `:14-42`
- `FormalSystem/Semantics/TaskFrame.lean` - merge `:1778-1924` from five sections to two
- `FormalSystem/Semantics/WorldHistory.lean`, `FormalSystem/Semantics/Truth.lean` - `timeShift_*` rename

**Verification**:
- Guarded detached build exits 0
- `Frames/Standard.lean`'s import list contains `TaskFrame` and nothing from `Correspondence/`
- `Semantics.lean` imports all 33 (now 34) `Semantics/**.lean` modules — verify by diffing the module
  file list against the import list
- `grep -rn "time_shift_" --include=*.lean FormalSystem/` returns zero hits
- `Semantics/README.md`'s Contents table matches `Semantics.lean`'s import list exactly

---

## Testing & Validation

Acceptance criteria, with the two the report corrects marked:

- [ ] `./.claude/scripts/lake-build-guard.sh build --timeout 1800 -- build` (detached, unpiped) exits 0
- [ ] `scripts/check-module-invariants.sh` passes; **check C2 unchanged** — all four flagship theorems
      (`BXCanonical.completeness`, `.completeness_dense`, `.completeness_discrete`,
      `.Chronicle.countermodel_dense`) still report exactly `[propext, Classical.choice, Quot.sound]`.
      Nothing in this task should move them, but re-run the check before claiming acceptance.
- [ ] `Tests/BimodalTest/Semantics/SaturationFiniteAxiomTest.lean`'s four pre-existing `#guard_msgs`
      blocks pass **unchanged**, and three new ones cover Helper D
- [ ] `saturation_of_fib_subsingleton` is `[propext]`-only; its two supporting lemmas depend on **no
      axioms** — strictly better than routing through `univ_or_singleton`
- [ ] **(CORRECTED)** **At most two** `induction φ` truth-transport proofs remain across `Semantics/`
      + `Independence/`: `truthAt_of_truthIso` and `truthAt_add_hist_period`. The brief's "exactly
      one" is mathematically unachievable (§4.3) — a correct implementation would read as failed
      against it. If Phase 12 takes its documented fallback, this reads "at most three"
- [ ] `truth_double_shift_cancel` has zero repo occurrences
- [ ] Zero `sorry` and zero new axioms anywhere in the diff (no Option-B deferral)
- [ ] `grep -rn Spherical FormalSystem` still returns zero — **(CORRECTED)** the helper is
      `saturation_of_fib_subsingleton`, and no `Spherical` name is introduced
- [ ] Zero occurrences of `Bridge.step`, `Bridge.taskRel_diff`, `Bridge.ofWalk`, `Bridge.hist_isWalk`
- [ ] Zero occurrences of the eight deleted `WorldHistory.lean` lemma names
- [ ] Zero occurrences of `time_shift_` (all renamed to `timeShift_` or deleted)
- [ ] `Semantics.lean`'s import list covers every `Semantics/**.lean` module
- [ ] Net line delta is a reduction in the ~700 range (budget: ~1200 removed, ~463 added, ≈ −737).
      The *added* figure is honestly ~460, not the brief's ~250, once `TruthIso`, its anti-iso twin,
      `Standard.lean` and `DiscreteOrder.lean` are counted
- [ ] `Walk` and `MinCyc` structure definitions unchanged; the negative Mathlib survey is recorded in
      `FwdRecPeriodicity.lean`'s module docstring

## Artifacts & Outputs

- `FormalSystem/Semantics/Frames/Standard.lean` (new) — standard-frame index; home of `translationFrame`, `permissiveFrame`
- `FormalSystem/Metalogic/SoundnessLemmas/DiscreteOrder.lean` (new) — abstract-`P` order cores and their `Dᵒᵈ` duals
- `FormalSystem/Semantics/TaskFrame.lean` — Helper D (3 lemmas), Helper B completion (4 lemmas), regression sections 5 → 2
- `FormalSystem/Semantics/Truth.lean` — `TruthIso`, `truthAt_of_truthIso`, the anti-iso twin; `truth_double_shift_cancel` deleted
- `FormalSystem/Semantics/WorldHistory.lean` — `ofTotal`, `HF.ofTotal`, `@[simp] ofTotal_states`; eight lemmas deleted; `timeShift_*`
- `FormalSystem/Semantics/LexCarrier.lean` — generalised to `α ×ₗ ℤ`; two `example`s promoted; `LexInt.isLeast_pos`
- `FormalSystem/Semantics/DurationClassification.lean` — `isLeast_succ_of_isLeast_pos`, `isGreatest_pred_of_isLeast_pos`
- `FormalSystem/Semantics.lean` — three missing imports plus `Frames/Standard.lean`
- `FormalSystem/Semantics/README.md`, `FormalSystem/Metalogic/Independence.lean` — corrected docs
- `Tests/BimodalTest/Semantics/SaturationFiniteAxiomTest.lean` — three added axiom-profile guards
- Modified in place: `ShiftSet.lean`, `IntNormalForm.lean`, `IntTransfer.lean`, `Correspondence/{DurationFrames,FwdRecBridge,FwdRecPeriodicity}.lean`, `Independence/{ClockFrame,CoNotPriorU,LexIntWitness,LoopingDuration}.lean`, `SoundnessLemmas/FrameClassVariants.lean`, `Algebraic/FlowFrame.lean`, `Decidability/Verified/Bridge/RegionFrame.lean`, `WeakCanonical/IntegerModel/ReynoldsBridge.lean`, `Examples/TemporalStructures.lean`
- `specs/523_frame_kit_helpers_transport_standard_frames/summaries/01_frame-kit-helpers-transport-summary.md` (implementation output)

## Rollback/Contingency

Every phase commits independently at a green build (Commit-Per-Green-Substep), so rollback is
`git revert` of the offending phase's commit(s) — the wave table's territory disjointness means a
reverted phase does not strand a sibling in the same wave.

Phase-specific contingencies:

- **Phase 9 stalls** (the `TruthIso` generic proof): Phases 10, 11 and 12 are unreachable, but
  Phases 1-8, 13 and 14 are all independently valuable and the task is still a success on them.
  Leave Phase 9 `[PARTIAL]` with all five existing transports untouched. Do not leave a `sorry`.
- **Phase 12 recast does not fit**: take the documented fallback — leave `truthAt_map` in place,
  close `[COMPLETED WITH EXCLUSIONS]` with a `#### Reasoned Exclusions` record, restate acceptance as
  "at most three". Never a `sorry`.
- **Phase 13 counts against migration**: the NO-GO branch is a legitimate `[COMPLETED]`; the
  deliverable is the counted, recorded decision, and Phase 14 proceeds unchanged.
- **HC-1 violated** (a `#guard_msgs` axiom guard breaks): revert Phase 1's Helper D wiring
  immediately rather than editing the test's expected output. The guards are the specification;
  a changed axiom profile means the consolidation was the wrong one.
- **Phase 3 extraction blocked**: leave `FrameClassVariants.lean` untouched and ship
  `DiscreteOrder.lean` with only the cores that did extract cleanly. This is the plan's lowest-yield
  item (≈ −30) and is not worth forcing.
