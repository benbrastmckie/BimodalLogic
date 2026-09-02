# Implementation Plan: SoundnessLemmas Consolidation and Dead-Code Deletion

- **Task**: 519 - WAVE 1 (deletion): retire the soundness machinery the FrameClass refactor superseded
- **Status**: [NOT STARTED]
- **Effort**: 13 hours
- **Dependencies**: None (does not wait on siblings 521 or 522; 522 depends on this task)
- **Research Inputs**: `specs/519_soundnesslemmas_consolidation_delete_dead/reports/01_soundnesslemmas-dead-code-reachability.md`
- **Artifacts**: plans/01_soundnesslemmas-consolidation-deletion.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

`FormalSystem/Metalogic/SoundnessLemmas/` carries 2,487 lines, of which the reachability audit
measured ~1,259 as unreachable or duplicated: an entire 420-line swap dispatcher
(`axiom_swap_valid`) that duplicates 323 lines of its surviving twin, a 298-line private
`axiom_locally_valid` with zero references, and twenty-odd helper lemmas consumed only by those
two. This plan deletes that machinery, transplants the eight live survivors into
`FrameClassVariants.lean`, removes `DenseValidity.lean` and `Core.lean` outright, one-lines the
surviving 45-arm dispatcher, and retires the local `IsValid` notion in favour of the project-wide
`ValidIn`/`ValidDiscrete`. Done means: `lake build` green, `check-module-invariants.sh` ALL PASS,
the C2 axiom baseline unchanged, and the directory at ~1,228 lines with no declaration whose only
occurrence in the tree is its own definition.

The plan is nine phases because every phase must leave the tree buildable and must fit one agent
run. Nothing here requires a `sorry`: every step is a deletion of an unreferenced declaration, a
verbatim transplant, or a restatement between two propositions that are equal by structure eta,
with the intro/elim adapters already written and already exercised at live call sites.

### Research Integration

The research report re-measured every claim in the task description and its numbers supersede
the description's. Integrated findings:

- `DenseValidity.lean` is 1,296 lines (not 1,297); the dead ranges sum to ~636 lines, so the
  description's "615" is an undercount.
- The `:717-874` block holds **fourteen** `axiom_*_valid` helpers (not eleven), plus a fourth
  `and_of_not_imp_not` copy at `:826`. Four of the fourteen are already `occ=1` independently of
  the dead dispatcher.
- `DenseValidity.lean:280` is named `and_extract`, not `and_of_not_imp_not`. There are four
  distinct names for that statement, not five copies of one name.
- The two dispatchers share **323** identical lines, not 321.
- Five dead declarations the task description omits are handled here:
  `valid_at_triple` (`Core.lean:56`), `truth_at_swap_swap` (`Core.lean:67`), `and_extract`
  (`DenseValidity.lean:280`), and — critically — `swap_axiom_F_until_equiv_valid` and
  `swap_axiom_P_since_equiv_valid` (`DenseValidity.lean:170`, `:180`), which are **live today**
  and become dead only when `axiom_swap_valid` is deleted. They are removed in the same phase
  that kills their sole consumer (Phase 3), not by an early sweep that would miss them.
- Every one of `DenseValidity.lean`'s eight surviving declarations is consumed only by
  `FrameClassVariants.lean`, so the file is deleted outright after the transplant rather than
  left as a rump module.
- `IsValid` has a live consumer at `Decidability/Verified/Decidable.lean:2413`
  (`truthAt_of_isValid`, used at `:2449`, `:2482`, `:2532`). The orchestrator has widened this
  task's `file_scope` to include that file; the full restatement is planned here.
- D-09 is narrower than the description reads: the no-op `simp only [Formula.swapTemporal,
  TruthAt]` removal is validated for **purely-propositional arms only**. Blanket deletion breaks
  the build. Encoded as an explicit constraint in Phase 6.
- `and_of_not_imp_not` cross-directory consolidation is **deferred** per the research
  recommendation: this task deletes only the two `DenseValidity` copies.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` supplied in the delegation context; no ROADMAP.md consulted.

### Planner Deviation From One Orchestrator Instruction (stated, not silent)

The orchestrator directed that the `IsValid → ValidIn` restatement get "its own final, isolated
phase". This plan **splits that restatement in two**, and the reason is the sizing mandate that
accompanied the same instruction:

- `axiom_swap_valid_general` is stated at `IsValid D`. Phases 6-7 extract ~29 per-constructor
  lemmas out of its arms. If those lemmas are born at `IsValid D`, the final restatement phase
  must additionally rewrite all ~29 signatures — turning the highest-risk phase into a ~35
  declaration edit and defeating the isolation the instruction exists to provide.
- The restatement decomposes cleanly along the risk line the research drew. The `.Base`
  half — `axiom_swap_valid_general` plus the eight transplanted survivors at
  `ValidIn FrameClass.Base` — has **no** `SuccOrder`/`PredOrder` data-instance hazard and **no**
  C2 exposure: `FrameClass.Base.Sat` is discarded by every consumer
  (`Soundness.lean:1331` already passes it as `_`), so `ValidIn.of_forall_total` is a
  mechanical opening swap. That half runs early, as **Phase 5**, so the extracted lemmas are born
  in final form.
- The `.Discrete` half — the four `prior_UZ_is_valid`/`prior_SZ_is_valid`/`z1_is_valid`/
  `z1_past_is_valid` theorems at `ValidDiscrete`, the `Decidable.lean:2413` retarget, and the
  `Core.lean` deletion — is the piece carrying the entire defeq hazard and the only C2-baseline
  exposure. It is **Phase 8**: the final code phase, isolated, nothing else in it.

If the orchestrator prefers the literal single-phase reading, the fix is to merge Phase 5 into
Phase 8 and re-run Phases 6-7 afterwards; this plan does not take that option because it triples
the size of the riskiest phase.

## Goals & Non-Goals

**Goals**:
- Delete every declaration under `SoundnessLemmas/` whose only occurrence in `FormalSystem/` and
  `Tests/` is its own definition line, including the five the task description omits.
- Delete `DenseValidity.lean` and `Core.lean` outright, retargeting all four orphaned import
  lines.
- Leave exactly one 45-arm swap dispatcher, `axiom_swap_valid_general`, with every arm a one-line
  delegation.
- Retire the local `IsValid` notion; state everything at `ValidIn`/`ValidDiscrete`.
- Deduplicate `exists_isGLB_of_lub` down to the single `Separability.lean` copy.
- Bring `SoundnessLemmas/` to at most ~1,400 lines (projected ~1,228).
- Keep `lake build` green at every phase boundary, `check-module-invariants.sh` ALL PASS, and the
  C2 axiom baseline unchanged.

**Non-Goals**:
- Cross-directory consolidation of `and_of_not_imp_not`. Three copies survive
  (`Soundness.lean:153`, `CoValidity.lean:61`, `Decidable.lean:2563` as `and_of_not_imp_not'`);
  they have no clean common ancestor and `Truth.and_iff` does not exist yet. Deferred behind
  sibling task 521.
- Eliminating `Decidable.lean:2569`'s `exists_isGLB_of_lub'`. It is removable (that file already
  imports `Separability`) but is outside the acceptance criteria. Note it; leave it.
- Reducing `simp only [TruthAt` counts beyond the four D-09-validated no-op sites. That is
  sibling task 522's completion criterion, and it depends on this task leaving the arms as small
  named lemmas rather than 29-line inline blocks.
- Touching `Separability.lean` beyond dropping one `private` keyword; every declaration in it is
  live.
- Touching `CoValidity.lean` beyond its import line; `co_valid` and `always_elim` are live.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `ValidDiscrete` restatement breaks defeq: `SuccOrder`/`PredOrder` are **data**, and routing them through the instance cache with `haveI` breaks equality against instances already fixed in the types of `F` and `M` (`Validity.lean:610-617`; `Decidable.lean:2422` makes the same point independently) | H | M | Do not invent an opening. Copy the already-working wrappers at `Soundness.lean:913-935` verbatim: `refine ValidDiscrete.of_forall ?_ ; intro F _ _ _ _ M τ h_mem t`. `ValidDiscrete.of_forall` already does the `obtain` and applies the witnesses positionally with `@`. Phase 8 only. |
| C2 axiom baseline moves via `Decidability.sound_of_isValid`, which is downstream of `truthAt_of_isValid` | H | L | Phase 8 is the only phase that can perturb it, which is why it runs last and alone. Run the **full** `check-module-invariants.sh` (not `--no-build`) immediately after Phase 8. The retarget preserves the proof term: `h F M τ hτ t` becomes `h F ⟨so,po,hsa,hpa⟩ M ⟨τ,hτ⟩ t`, adding no axiom. |
| Blanket removal of `simp only [Formula.swapTemporal, TruthAt]` breaks arms that need `Truth.future_iff`/`past_iff` to expose a quantifier (e.g. `until_F`, `since_P`, `serial_future`, `serial_past`) | M | H if unconstrained | Phase 6 removes it at **exactly four** constructor arms — `prop_k`, `prop_s`, `ex_falso`, `modal_k_dist` — and nowhere else. Rule of thumb for any additional candidate: drop only where the next tactic is `intro`/`exact` and the goal is propositional; lean on the build to catch overreach. |
| A dead-code sweep run before Phase 3 misses `swap_axiom_F_until_equiv_valid` / `swap_axiom_P_since_equiv_valid` | M | M | Those two are deleted in Phase 3, in the same edit as their sole consumer `axiom_swap_valid`. The authoritative sweep runs in Phase 9, after every deletion. |
| Deleting `Core.lean` / `DenseValidity.lean` orphans import lines (C4 failure) | M | M | Four sites, all enumerated: `SoundnessLemmas.lean:8,9`, `CoValidity.lean:7`, `FrameClassVariants.lean:7`. Each is edited in the same phase as the deletion that orphans it (Phase 4 for `DenseValidity`, Phase 8 for `Core`), under `atomic-batch` commit mode. |
| Arm extraction is line-**additive** (+~90 for signatures and docstrings), so Phase 6/7 do not shrink the file | L | H | Budgeted. The ~1,400-line target still holds at the projected ~1,228 total. Do not treat a line increase in those phases as a defect. |
| LSP goes stale after large deletions (a `lean --worker` currently holds `DenseValidity.lean` open) | L | M | After each structural deletion, restart via `lean_build` rather than trusting hover/goal output mid-edit. |
| A particular arm resists extraction in Phase 6/7 | L | M | Zero-debt policy: leave that arm inlined and record it as a reasoned exclusion. Never stub with `sorry`, `native_decide`, or a new `axiom`. The acceptance criterion is about the dispatcher's shape; one stubborn arm is a documented partial. |
| Another agent edits `Decidability/` concurrently (`FrameClassVariants.lean` and `Separability.lean` are both imported by `Decidable.lean`) | M | L | Re-check `git status` before Phase 8. No foreign modification inside `FormalSystem/` was observed at audit time. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3 | 1, 2 |
| 3 | 4 | 3 |
| 4 | 5 | 4 |
| 5 | 6 | 5 |
| 6 | 7 | 6 |
| 7 | 8 | 7 |
| 8 | 9 | 8 |

Phases within the same wave can execute in parallel. Phases 1 and 2 touch disjoint files
(`DenseValidity.lean` + `Core.lean` vs `Soundness.lean` + `Separability.lean`) and are genuinely
independent.

---

### Phase 1: Delete the already-dead ranges [NOT STARTED]

**Goal**: Remove every declaration under `SoundnessLemmas/` that is already unreachable today,
before any restructuring, so every later phase works against a smaller file.

**Tasks**:
- [ ] In `DenseValidity.lean`, delete `swap_axiom_t4_valid`, `swap_axiom_ta_valid`,
      `swap_axiom_tl_valid` (`:98-169`).
- [ ] Delete the section docstring, the four `*_preserves_swap_valid` lemmas, and `and_extract`
      (`:215-296`). The supersession docstring at `:215-217` goes with them.
- [ ] Delete the fourteen `axiom_*_valid` helpers and the `and_of_not_imp_not` copy at `:826`
      (`:717-874`). Named: `axiom_prop_k_valid`, `axiom_prop_s_valid`, `axiom_modal_t_valid`,
      `axiom_modal_4_valid`, `axiom_modal_b_valid`, `axiom_modal_5_collapse_valid`,
      `axiom_ex_falso_valid`, `axiom_peirce_valid`, `axiom_modal_k_dist_valid`,
      `axiom_temp_k_dist_valid`, `axiom_temp_4_valid`, `axiom_temp_a_valid`,
      `axiom_temp_l_valid`, `axiom_modal_future_valid`.
- [ ] Delete `axiom_density_valid` (`:960`), `axiom_locally_valid` (`:970-1267`, 298 lines,
      private), and the three `*_preserves_*` lemmas `mp_preserves_valid`,
      `necessitation_preserves_local_valid`, `temporal_necessitation_preserves_local_valid`
      (`:1268-1296`).
- [ ] In `Core.lean`, delete `valid_at_triple` (`:56`) and `truth_at_swap_swap` (`:67`).
- [ ] Update `Core.lean`'s module docstring (`:15`), which names `truth_at_swap_swap`, so the file
      does not describe a declaration it no longer has.
- [ ] Preserve `DenseValidity.lean`'s eight survivors and `axiom_swap_valid` untouched:
      `swap_axiom_mt_valid`, `swap_axiom_m4_valid`, `swap_axiom_mb_valid` (`:50-97`),
      `swap_axiom_F_until_equiv_valid`, `swap_axiom_P_since_equiv_valid` (`:170-198`, still live
      via `axiom_swap_valid`), `swap_axiom_mf_valid` (`:199-214`), `axiom_swap_valid`
      (`:297-716`), and the four local-validity survivors at `:875-959`.

**Timing**: 0.75 hours

**Depends on**: none

**Verification Tier**: interface

**Scope Hypothesis**: this phase asserts four deletion ranges in `DenseValidity.lean` totalling
~636 lines and two declarations in `Core.lean`. Line numbers are from the audit baseline
(`f35c16401`) and shift as edits land — locate every range by **declaration name**, never by line
number, and confirm before deleting that each name still reports `occ=1` under the sweep in
Phase 9's task list. If any name reports a live consumer, stop and report rather than deleting.

**Files to modify**:
- `FormalSystem/Metalogic/SoundnessLemmas/DenseValidity.lean` - delete four ranges (~636 lines)
- `FormalSystem/Metalogic/SoundnessLemmas/Core.lean` - delete two dead lemmas, fix docstring

**Verification**:
- `lake build` green.
- `bash scripts/check-module-invariants.sh --no-build` passes.
- `wc -l FormalSystem/Metalogic/SoundnessLemmas/DenseValidity.lean` reports ~660.
- `grep -rn "axiom_locally_valid\|and_extract\|valid_at_triple\|truth_at_swap_swap"
  --include='*.lean' FormalSystem Tests` returns nothing.

---

### Phase 2: Deduplicate `exists_isGLB_of_lub` [NOT STARTED]

**Goal**: Collapse the two copies of `exists_isGLB_of_lub` to the single `Separability.lean` one,
removing the copy whose docstring apologises for existing.

**Tasks**:
- [ ] Drop the `private` keyword from `exists_isGLB_of_lub` at `Separability.lean:48` and remove
      the apologetic docstring paragraph that justified the duplication.
- [ ] Delete the copy at `Soundness.lean:1000-1028`.
- [ ] Confirm the consumer at `Soundness.lean:1095` now resolves through the existing
      `import FormalSystem.Metalogic.SoundnessLemmas.Separability` at `Soundness.lean:11` — no new
      import is needed.
- [ ] Leave `Decidable.lean:2569`'s `exists_isGLB_of_lub'` alone (explicit non-goal); add no
      comment about it in `FormalSystem/`.

**Timing**: 0.5 hours

**Depends on**: none

**Verification Tier**: interface

**Files to modify**:
- `FormalSystem/Metalogic/SoundnessLemmas/Separability.lean` - un-private one declaration
- `FormalSystem/Metalogic/Soundness.lean` - delete the duplicate (~29 lines)

**Verification**:
- `lake build` green.
- `grep -rn "\bexists_isGLB_of_lub\b" --include='*.lean' FormalSystem` shows exactly one
  definition site (`Separability.lean`) plus its consumers.

---

### Phase 3: Retire `axiom_swap_valid` [NOT STARTED]

**Goal**: Replace the only two live arms of the 420-line duplicate dispatcher with two named
lemmas in `Soundness.lean`, then delete the dispatcher and the two lemmas that become dead with
it.

**Tasks**:
- [ ] Write `density_swap_valid` and `dense_indicator_swap_valid` in `Soundness.lean`, placed
      beside `sep_swap_valid`. Lift their proof bodies **verbatim** from the corresponding arms of
      `axiom_swap_valid` before deleting it; do not re-derive them.
- [ ] Repoint the two `ValidDense.of_forall` blocks in `axiom_swap_validIn_min`
      (`Soundness.lean:1336-1342` at baseline) from
      `SoundnessLemmas.axiom_swap_valid (D := F.Duration) _ (Axiom.density a0) trivial F.toFibre …`
      to the new lemmas, matching the one-line shape the `sep` arm already has.
- [ ] Delete `axiom_swap_valid` from `DenseValidity.lean` (`:297-716` at baseline, 420 lines).
- [ ] Delete `swap_axiom_F_until_equiv_valid` and `swap_axiom_P_since_equiv_valid`
      (`:170-198` at baseline) — their only consumer was `axiom_swap_valid:606,607`, so they are
      dead the moment it goes. **This is the phase where they must be caught**; a sweep run
      earlier reports them live.
- [ ] Confirm `axiom_swap_valid` has no remaining occurrence anywhere in `FormalSystem/` or
      `Tests/`.

**Timing**: 1.5 hours

**Depends on**: 1, 2

**Verification Tier**: full

**Scope Hypothesis**: this phase asserts that `axiom_swap_valid` has exactly two live consumers
(`Soundness.lean:1337` and `:1341`, the `density` and `dense_indicator` arms). Confirm with
`grep -rn "\baxiom_swap_valid\b" --include='*.lean' FormalSystem Tests` **before** deleting; if
a third consumer exists, extract a third lemma rather than proceeding.

**Files to modify**:
- `FormalSystem/Metalogic/Soundness.lean` - add two lemmas (~25 lines), repoint two arms
- `FormalSystem/Metalogic/SoundnessLemmas/DenseValidity.lean` - delete ~450 lines

**Verification**:
- `lake build` green.
- `bash scripts/check-module-invariants.sh` (full run, with build) passes.
- `grep -rn "\baxiom_swap_valid\b" --include='*.lean' FormalSystem Tests` returns nothing (note
  the word boundary: `axiom_swap_valid_general` must survive).
- `DenseValidity.lean` now holds only its header, imports, and eight declarations.

---

### Phase 4: Transplant the survivors and delete `DenseValidity.lean` [NOT STARTED]

**Goal**: Move the eight surviving declarations into their sole consumer and remove the file and
its import edges.

**Tasks**:
- [ ] Move these eight declarations verbatim from `DenseValidity.lean` into
      `FrameClassVariants.lean`, above `axiom_swap_valid_general`: `swap_axiom_mt_valid`,
      `swap_axiom_m4_valid`, `swap_axiom_mb_valid`, `swap_axiom_mf_valid`,
      `axiom_temp_linearity_valid`, `axiom_temp_linearity_past_valid`,
      `axiom_F_until_equiv_valid`, `axiom_P_since_equiv_valid`.
- [ ] Add to `FrameClassVariants.lean`: `import FormalSystem.Metalogic.SoundnessLemmas.Core`
      (currently transitive through `DenseValidity`), `import Mathlib.Order.SuccPred.Basic`, and
      `import Mathlib.Order.SuccPred.Archimedean` (the discrete theorems at `:400-591` currently
      get these transitively).
- [ ] Replace `import FormalSystem.Metalogic.SoundnessLemmas.DenseValidity` at
      `FrameClassVariants.lean:7`.
- [ ] Delete `FormalSystem/Metalogic/SoundnessLemmas/DenseValidity.lean`.
- [ ] In the aggregator `FormalSystem/Metalogic/SoundnessLemmas.lean`: remove the `DenseValidity`
      import (`:9`), add `import FormalSystem.Metalogic.SoundnessLemmas.Separability` (A-10 —
      omitted today), and update the `## Contents` docstring list to match the four remaining
      modules.
- [ ] Confirm `scripts/module-invariants-manifest.txt` needs **no** edit: neither `Core` nor
      `DenseValidity` is listed there, and adding `Separability` to the aggregator does not change
      its reachability (`Soundness.lean:11` already imports it directly). Verify by running C6
      rather than by inspection alone.

**Timing**: 1.5 hours

**Depends on**: 3

**Verification Tier**: full

**Commit Mode**: atomic-batch

**Scope Hypothesis**: this phase asserts exactly eight surviving declarations and exactly three
import sites to retarget. Confirm the survivor list by re-running the `occ` sweep against the
post-Phase-3 `DenseValidity.lean`, and confirm the import sites with
`grep -rn "SoundnessLemmas.DenseValidity" --include='*.lean' FormalSystem Tests`.

**Files to modify**:
- `FormalSystem/Metalogic/SoundnessLemmas/FrameClassVariants.lean` - +~150 lines, +3 imports
- `FormalSystem/Metalogic/SoundnessLemmas/DenseValidity.lean` - **deleted**
- `FormalSystem/Metalogic/SoundnessLemmas.lean` - import and docstring edits

**Verification**:
- `lake build` green (run `lean_build` to restart the LSP first; a worker holds the deleted file
  open).
- `bash scripts/check-module-invariants.sh` full run passes, C4 and C6 specifically.
- `grep -rn "DenseValidity" --include='*.lean' FormalSystem Tests` returns nothing.
- `SoundnessLemmas/` is now four files.

---

### Phase 5: Restate the `.Base` layer at `ValidIn FrameClass.Base` [NOT STARTED]

**Goal**: Move `axiom_swap_valid_general` and the eight transplanted survivors off the local
`IsValid` notion, **before** arm extraction, so the ~29 lemmas Phases 6-7 create are born in
their final form and never need restating. This is the benign half of the `IsValid` retirement
(see "Planner Deviation" in the Overview); the hazardous half is Phase 8.

**Tasks**:
- [ ] Restate `axiom_swap_valid_general` from `IsValid D φ.swapTemporal` to
      `ValidIn FrameClass.Base φ.swapTemporal`. Open with
      `refine ValidIn.of_forall_total ?_ ; intro F _ M τ _hτ t` **before** the `cases h with`, so
      each arm's body loses its own `intro F M τ _hτ t` line and is otherwise unchanged. The
      `fc.Sat F` argument is discarded — `Soundness.lean:1331` already passes it as `_`.
- [ ] Restate the eight transplanted survivors at `ValidIn FrameClass.Base` the same way, so the
      delegating arms (`| modal_t ψ => exact swap_axiom_mt_valid ψ` and the four two-line
      temp-linearity/equiv arms) keep working unchanged.
- [ ] Simplify `Soundness.lean`'s `axiom_swap_validIn_min` `.Base` branch: the
      `ValidIn.of_forall_total fun F _ M τ hτ t => SoundnessLemmas.axiom_swap_valid_general
      (D := F.Duration) φ ax hbase F.toFibre M τ hτ t` shim collapses to
      `exact axiom_swap_valid_general φ ax hbase`.
- [ ] Do **not** touch the four discrete theorems (`prior_UZ_is_valid`, `prior_SZ_is_valid`,
      `z1_is_valid`, `z1_past_is_valid`) — they stay at `IsValid D` until Phase 8. `Core.lean`
      therefore still has live consumers at the end of this phase, and must not be deleted here.
- [ ] Do not "extract a `_swap_valid` wrapper" for the four two-line delegating arms
      (`temp_linearity`, `temp_linearity_past`, `F_until_equiv`, `P_since_equiv`). Their existing
      shape — delegating to the local-validity survivor at swapped arguments — is already correct;
      a wrapper would be pure noise.

**Timing**: 1.5 hours

**Depends on**: 4

**Verification Tier**: full

**Commit Mode**: atomic-batch

**Files to modify**:
- `FormalSystem/Metalogic/SoundnessLemmas/FrameClassVariants.lean` - nine statement restatements
- `FormalSystem/Metalogic/Soundness.lean` - collapse the `.Base` shim

**Verification**:
- `lake build` green.
- `bash scripts/check-module-invariants.sh` full run passes.
- `grep -n "IsValid" FormalSystem/Metalogic/SoundnessLemmas/FrameClassVariants.lean` shows only
  the four discrete theorems.
- No `sorry` introduced: `grep -rn "\bsorry\b" --include='*.lean' FormalSystem/Metalogic` shows
  only the four prose sentences in `Soundness.lean` that assert sorry-freeness.

---

### Phase 6: One-line the propositional and modal arms [NOT STARTED]

**Goal**: Extract per-constructor lemmas out of the inlined propositional, modal, and seriality
arms of `axiom_swap_valid_general`, leaving each arm a one-line `exact <name> …`.

**Tasks**:
- [ ] For each inlined propositional/modal/seriality arm, extract a named lemma stated at
      `ValidIn FrameClass.Base` immediately above the dispatcher, with a docstring, and reduce the
      arm to `exact <ctor>_swap_valid <args>`. Arms in scope: `prop_k`, `prop_s`,
      `modal_5_collapse`, `ex_falso`, `peirce`, `modal_k_dist`, `serial_future`, `serial_past`,
      and the remaining non-temporal inlined arms between them.
- [ ] **D-09, narrow form**: drop the no-op `simp only [Formula.swapTemporal, TruthAt]` line at
      **exactly four** arms — `prop_k`, `prop_s`, `ex_falso`, `modal_k_dist` — where `TruthAt … (φ.imp ψ)`
      is definitionally an arrow (`Truth.imp_iff` is `rfl`, `Truth.lean:192`). Keep it everywhere
      it exposes a quantifier via `Truth.future_iff`/`Truth.past_iff`, including `serial_future`
      and `serial_past`, which pair it with `Truth.some_past_iff`/`Truth.some_future_iff`. If a
      further candidate looks removable, the test is: the next tactic is `intro` or `exact` and
      the goal is propositional. Blanket removal breaks the build.
- [ ] Leave the 8 `absurd h_fc` arms for non-Base constructors alone — already one-line.
- [ ] Leave the 4 existing one-line delegating arms (`modal_t`, `modal_4`, `modal_b`,
      `modal_future`) and the 4 two-line delegating arms alone.
- [ ] Do not over-optimise the extracted proofs. Sibling task 522 rewrites their `simp only`
      calls; this phase's job is to leave them as small named lemmas rather than inline blocks.

**Timing**: 2 hours

**Depends on**: 5

**Verification Tier**: full

**Scope Hypothesis**: the research measured ~29 fully inlined arms across Phases 6 and 7
combined, and exactly four D-09-validated no-op `simp only` sites. Confirm both at implementation
time: enumerate the arms of `axiom_swap_valid_general` that are longer than one line and are not
delegating, and record the actual count in the phase's progress notes. Extraction is
line-**additive** (+~3 lines per lemma) — a line increase here is expected, not a defect.

**Files to modify**:
- `FormalSystem/Metalogic/SoundnessLemmas/FrameClassVariants.lean` - extract lemmas, shrink arms

**Verification**:
- `lake build` green.
- Every arm touched in this phase is a single line.
- `grep -c "simp only \[Formula.swapTemporal, TruthAt\]"` on the file has dropped by exactly 4
  relative to the start of the phase (the rest have **moved into** the extracted lemmas, not
  vanished).

---

### Phase 7: One-line the temporal arms [NOT STARTED]

**Goal**: Same treatment for the temporal arms, which carry the largest bodies.

**Tasks**:
- [ ] Extract named `ValidIn FrameClass.Base` lemmas for the temporal inlined arms, largest
      first: `linear_until` (~29 lines) and `linear_since` (~32 lines), then `until_F`, `since_P`,
      the `discrete_symm_*` arms, and the remaining temporal arms.
- [ ] Reduce each to `exact <ctor>_swap_valid <args>`.
- [ ] Keep every `simp only [Formula.swap_temporal_some_future, …]` /
      `simp only [TruthAt, Truth.some_past_iff]` pair intact inside the extracted lemmas — these
      are load-bearing, not D-09 no-ops.
- [ ] If a particular arm resists extraction, leave it inlined, record it under a
      `#### Reasoned Exclusions` table in this phase with the evidence, and mark the phase
      `[COMPLETED WITH EXCLUSIONS]`. Never stub with `sorry`, `native_decide`, or a new `axiom`.

**Timing**: 2 hours

**Depends on**: 6

**Verification Tier**: full

**Scope Hypothesis**: the two largest arms are asserted at ~29 and ~32 lines
(`linear_until`, `linear_since`). Re-measure at implementation time; if either has grown past
~50 lines, split it into two lemmas rather than extracting one oversized one.

**Files to modify**:
- `FormalSystem/Metalogic/SoundnessLemmas/FrameClassVariants.lean` - extract lemmas, shrink arms

**Verification**:
- `lake build` green.
- `bash scripts/check-module-invariants.sh` full run passes.
- Every one of `axiom_swap_valid_general`'s 45 arms is one line, or is enumerated in a
  `#### Reasoned Exclusions` table.

---

### Phase 8: Retire `IsValid` and delete `Core.lean` [NOT STARTED]

**Goal**: Restate the four discrete theorems at `ValidDiscrete`, retarget the one out-of-directory
consumer, and delete the local validity notion and its module. **This is the highest-risk phase
and it runs alone**: it carries the entire `SuccOrder`/`PredOrder` defeq hazard and the only C2
baseline exposure in the task.

**Tasks**:
- [ ] Before starting, re-check `git status` for foreign modification under `FormalSystem/`,
      particularly `Decidability/` — `FrameClassVariants.lean` and `Separability.lean` are both
      imported by `Decidable.lean`, so that is the collision surface.
- [ ] Restate `prior_UZ_is_valid`, `prior_SZ_is_valid`, `z1_is_valid`, and `z1_past_is_valid` in
      `FrameClassVariants.lean` from `IsValid D` (with `[SuccOrder ↑D] [PredOrder ↑D]
      [IsSuccArchimedean ↑D] [IsPredArchimedean ↑D]` binders) to `ValidDiscrete`. **Copy the
      opening verbatim** from the already-working wrappers at `Soundness.lean:913-935`:
      `refine ValidDiscrete.of_forall ?_ ; intro F _ _ _ _ M τ h_mem t`. `ValidDiscrete.of_forall`
      (`Validity.lean:618`) already destructures `FrameClass.Discrete.Sat`'s existential with
      `obtain` and applies the four witnesses positionally with `@`. **Never** install the two
      data instances with `haveI` — routing `SuccOrder`/`PredOrder` through the instance cache
      breaks definitional equality against instances already fixed in the types of `F` and `M`
      (`Validity.lean:610-617`, and `Decidable.lean:2422` independently).
- [ ] Collapse the now-redundant `.toFibre` + `(D := F.Duration)` shims in `Soundness.lean` that
      wrapped those four: `prior_UZ_valid`, `prior_SZ_valid`, `z1_valid` (`:913-935`) and the
      three `ValidDiscrete.of_forall` blocks in `axiom_swap_validIn_min` (`:1345-1353`).
- [ ] Retarget `truthAt_of_isValid` at `Decidable.lean:2413` to wrap `ValidDiscrete.apply`
      (`Validity.lean:628`), whose signature already binds the four instances
      instance-implicitly. Its three consumers at `:2449`, `:2482`, `:2532`
      (`ruleSound_priorUZ`, `ruleSound_priorSZ`, `ruleSound_z1Rule`) should need no change beyond
      the wrapper's own argument list. Keep the lemma as a named landing step, per A-08.
- [ ] Replace `import FormalSystem.Metalogic.SoundnessLemmas.Core` at `CoValidity.lean:7`. `Core`
      supplied `FormalSystem.Semantics.Truth`, `ProofSystem.Derivation`, `ProofSystem.Axioms`
      (`Core.lean:7-9`); in practice `Semantics.Truth` is the only one `CoValidity` needs. Confirm
      by build, adding the others only if it fails.
- [ ] Replace the `Core` import at `FrameClassVariants.lean` (added in Phase 4) the same way.
- [ ] Remove `import FormalSystem.Metalogic.SoundnessLemmas.Core` from the aggregator
      `SoundnessLemmas.lean:8` and drop `Core` from its `## Contents` docstring list.
- [ ] Delete `FormalSystem/Metalogic/SoundnessLemmas/Core.lean`.

**Timing**: 2 hours

**Depends on**: 7

**Verification Tier**: full

**Commit Mode**: atomic-batch

**Scope Hypothesis**: this phase asserts that after Phase 5, `IsValid` has exactly five consumers
— the four discrete theorems in `FrameClassVariants.lean` and `truthAt_of_isValid` at
`Decidable.lean:2413`. Confirm with `grep -rn "\bIsValid\b" --include='*.lean' FormalSystem Tests`
before starting. If a sixth appears, retarget it in this phase rather than deferring.

**Files to modify**:
- `FormalSystem/Metalogic/SoundnessLemmas/FrameClassVariants.lean` - four restatements, import
- `FormalSystem/Metalogic/SoundnessLemmas/Core.lean` - **deleted**
- `FormalSystem/Metalogic/SoundnessLemmas/CoValidity.lean` - import retarget only
- `FormalSystem/Metalogic/SoundnessLemmas.lean` - drop `Core` import and docstring entry
- `FormalSystem/Metalogic/Soundness.lean` - collapse ~20 lines of shims
- `FormalSystem/Metalogic/Decidability/Verified/Decidable.lean` - retarget `truthAt_of_isValid`

**Verification**:
- `lake build` green.
- **Full** `bash scripts/check-module-invariants.sh` (not `--no-build`), ALL PASS — this is the
  C2/C14 gate and this phase is the only one that can move it.
- `grep -rn "SoundnessLemmas.IsValid\|\bIsValid\b" --include='*.lean' FormalSystem Tests` returns
  nothing.
- `#print axioms` for the C2/C14(ii) pinned theorems — `BXCanonical.completeness`,
  `completeness_dense`, `completeness_discrete`, `Chronicle.countermodel_dense`,
  `Decidability.sound_of_isValid`, `completeness_dedekind`, `strongCompletenessBase`,
  `strongCompletenessDense` — unchanged from the pre-task baseline.
- No new `sorry`, `native_decide`, or `axiom` declaration anywhere in the diff.

---

### Phase 9: Documentation, manifest, and acceptance gate [NOT STARTED]

**Goal**: Bring the prose in line with the tree and prove every acceptance criterion.

**Tasks**:
- [ ] Regenerate `FormalSystem/Metalogic/SoundnessLemmas/README.md` with
      `bash scripts/readme-inventory.sh`, which emits the `| File | Lines | Description |` table
      with live `wc -l` counts. Remove the `Core.lean` and `DenseValidity.lean` rows; keep the
      three surviving descriptions accurate. Update the `Dependencies` section (it names
      `Semantics.Truth`, `Semantics.Validity`, `ProofSystem.Derivation`, `ProofSystem.Axioms` and
      Mathlib order modules) and the `Last verified` date.
- [ ] Update `FormalSystem/Metalogic.lean:250`'s `SoundnessLemmas/  3 files` claim. The count is
      now accidentally correct — set it deliberately, and re-verify with `ls`.
- [ ] Correct `docs/development/LEAN_STYLE_GUIDE.md:915-926`, which mentions `IsValid` and already
      misattributes it to `Validity.lean`. No path breakage, but it is the last live reference.
- [ ] Run the authoritative dead-declaration sweep across the directory and **read** its output —
      a declaration whose only second occurrence is a docstring backtick reports `occ=2` and slips
      through an exit-code check:
      ```bash
      for f in FormalSystem/Metalogic/SoundnessLemmas/*.lean; do
        grep -oP '^(private |protected |noncomputable )*(theorem|lemma|def|abbrev|instance) \K[A-Za-z_][A-Za-z0-9_'"'"'.]*' "$f" | while read n; do
          tot=$(grep -rhno "\b$n\b" --include='*.lean' FormalSystem Tests | wc -l)
          [ "$tot" -le 1 ] && echo "DEAD: $n ($f)"
        done
      done
      ```
- [ ] Confirm C9 / the repo-wide `no-task-references-in-deliverables` rule: no prose added under
      `FormalSystem/` or `docs/` in any phase cites a task number.
- [ ] Record the final measured line counts against the projection in the implementation summary.

**Timing**: 1 hour

**Depends on**: 8

**Verification Tier**: full

**Scope Hypothesis**: the projection is `SoundnessLemmas/` at ~1,228 lines (CoValidity ~141,
FrameClassVariants ~735, Separability 352) against a ~1,400 ceiling. Measure, do not assume; if
the total exceeds 1,400, report the overage with a per-file breakdown rather than trimming
opportunistically.

**Files to modify**:
- `FormalSystem/Metalogic/SoundnessLemmas/README.md` - regenerated
- `FormalSystem/Metalogic.lean` - file-count line in the layout docstring
- `docs/development/LEAN_STYLE_GUIDE.md` - `IsValid` reference correction

**Verification**:
- `lake build` green.
- `bash scripts/check-module-invariants.sh` full run, **ALL PASS** — C4, C5, C6, C9, C12, C13, C14
  in particular.
- The dead-declaration sweep prints nothing.
- `wc -l FormalSystem/Metalogic/SoundnessLemmas/*.lean | tail -1` is at most ~1,400.

---

## Testing & Validation

Acceptance criteria, carried verbatim from the task and checked at Phase 9:

- [ ] `SoundnessLemmas/` totals at most ~1,400 lines, down from 2,487 (projected ~1,228).
- [ ] Exactly one 45-arm swap dispatcher remains — `axiom_swap_valid_general` — with one-line
      arms. (Note: `Soundness.lean:1277`'s `axiom_validIn_min` is also a 45-arm `cases`, but it is
      the *local*-validity dispatcher, already one-lined, and is the stated model for the target
      shape rather than a duplicate. `axiom_swap_validIn_min` is a nine-arm dispatcher plus a
      `.Base` delegation.)
- [ ] Zero declarations in the directory whose only occurrence in `FormalSystem/` and `Tests/` is
      their own definition line. Verified by the Phase 9 sweep, read rather than exit-code-checked.
- [ ] `lake build` green.
- [ ] `bash scripts/check-module-invariants.sh` reports ALL PASS.
- [ ] C2 axiom baseline unchanged: `#print axioms` for the four C2-pinned and four C14(ii)-pinned
      theorems matches the pre-task baseline.

Per-phase gates:
- [ ] `lake build` green at **every** phase boundary — a phase ordering that leaves the tree red
      in between is a planning defect, not an implementation detail.
- [ ] `bash scripts/check-module-invariants.sh --no-build` after each structural phase (1, 4, 8);
      full run with build after Phases 3, 5, 7, 8, 9.
- [ ] Zero-debt: no `sorry`, `native_decide`, or new `axiom` declaration in any phase. The
      pre-task `sorry` baseline is zero structural sorries in scope; the four `grep` hits in
      `Soundness.lean` (`:113`, `:988`, `:1558`, `:1639`) are prose sentences asserting
      sorry-freeness and must stay prose.
- [ ] After every large deletion, restart the LSP (`lean_build`) rather than trusting stale
      hover/goal output.

## Artifacts & Outputs

- `specs/519_soundnesslemmas_consolidation_delete_dead/plans/01_soundnesslemmas-consolidation-deletion.md` (this file)
- `specs/519_soundnesslemmas_consolidation_delete_dead/summaries/01_soundnesslemmas-consolidation-summary.md` (on completion)
- Deleted: `FormalSystem/Metalogic/SoundnessLemmas/DenseValidity.lean`,
  `FormalSystem/Metalogic/SoundnessLemmas/Core.lean`
- Modified: `FormalSystem/Metalogic/SoundnessLemmas/{FrameClassVariants,CoValidity,Separability,README.md}`,
  `FormalSystem/Metalogic/SoundnessLemmas.lean`, `FormalSystem/Metalogic/Soundness.lean`,
  `FormalSystem/Metalogic.lean`,
  `FormalSystem/Metalogic/Decidability/Verified/Decidable.lean`,
  `docs/development/LEAN_STYLE_GUIDE.md`

## Rollback/Contingency

Every phase is a self-contained commit against a green build, so rollback is `git revert` of the
phase commit or `git reset` to the previous phase boundary — there is no partial state to unwind
within a phase except in the two `atomic-batch` phases (4 and 8), whose intermediate per-file
states are expected red and are deliberately never committed.

Phase-specific contingencies:
- **Phase 3**: if `axiom_swap_valid` turns out to have a third live consumer, extract a third
  lemma into `Soundness.lean` rather than abandoning the deletion.
- **Phase 5**: if the `ValidIn FrameClass.Base` restatement of `axiom_swap_valid_general` fails to
  elaborate, revert the phase and fall back to the literal orchestrator ordering — leave the
  dispatcher at `IsValid D`, extract arms at `IsValid D` in Phases 6-7, and absorb their
  restatement into Phase 8, splitting Phase 8 into 8.1 (`.Base` lemmas) and 8.2 (`.Discrete` plus
  `Core.lean` deletion) to keep each within one agent run.
- **Phases 6-7**: a resisting arm stays inlined and is recorded as a reasoned exclusion; it never
  becomes a `sorry`.
- **Phase 8**: if the C2 baseline moves, revert the phase immediately and report — a changed axiom
  closure means the restatement was not the definitional no-op it is claimed to be, and that is a
  finding, not something to patch around.
