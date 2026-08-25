# Implementation Plan: Close `WeakCanonical.countermodel_discrete` at Base

- **Task**: 479 - tc_close_countermodel_discrete_at_base
- **Status**: [IMPLEMENTING]
- **Effort**: 5 hours
- **Dependencies**: Task 478 (delivered `WeakCanonical.companionChronicle`, axiom-clean, landed)
- **Research Inputs**: `specs/479_tc_close_countermodel_discrete_at_base/reports/01_countermodel-discrete-base-port.md`
- **Artifacts**: plans/01_close-countermodel-discrete-base.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

`WeakCanonical.countermodel_discrete` (`Transfer.lean:1069`, `sorry` at `:1102`) is the tree's
sole live structural `sorry` and the only `sorryAx` source reaching `BXCanonical.completeness`.
Research established that the proof body of `countermodel_discrete_reynolds_v2`
(`IntegerModel/ReynoldsBridge.lean:936-1352`) ports to `FrameClass.Base` mechanically once three
substitutions are made (`limitdom_is_good` -> `companionChronicle`, `multiFamTaskFrame` ->
`multiFamTaskFrameGen (ℚ ×ₗ ℤ)`, `Discrete` -> `Base`), and identified one structural blocker:
`Transfer.lean` is strictly upstream of `GroupModel/GroupableCompanion.lean`, so the theorem
must be **relocated** to a new module, not edited in place. Definition of done: `lake build`
green, `#print axioms` on both `countermodel_discrete` and `BXCanonical.completeness` free of
`sorryAx`, and `scripts/check-module-invariants.sh` reporting a structural-sorry inventory of
zero.

### Research Integration

The plan implements report §6's recommended resolution verbatim (new
`GroupModel/CountermodelBase.lean`, name-preserving relocation, aggregator wiring, no
`Completeness.lean` edit) and honours the two body deltas of §5: the `goodGroupable` carrier is
`ℚ ×ₗ ℤ` by `rfl`, so `h_bounds`/`h_lo`/`h_hi`/`toCarrier`/`z_interval_carrier_contains_all`
(~40 lines at `ReynoldsBridge.lean:971-987` plus 16 call sites) **delete** rather than port; and
the 16 `omega` calls in the `untl`/`snce` cases become `add_lt_add_iff_left` / `abel` /
`zero_add`, all probe-verified. §7's two `check-module-invariants.sh` edits and §8's nine
stale-docstring files are carried as a required phase, not an optional cleanup.

Verified against live source while planning: `Transfer.lean` deletion range is exactly
**1049-1102** (section docstring header through the `sorry`; line 1103 is blank, 1104 is
`end FormalSystem.Metalogic.WeakCanonical`). `Completeness.lean:228-229` destructures ten
binders — matching the Base existential exactly — so it needs no edit provided the
fully-qualified name is preserved.

### Prior Plan Reference

No prior plan for this task.

### Roadmap Alignment

No `roadmap_path` was provided in the delegation context; no roadmap phases are included.

## Goals & Non-Goals

**Goals**:
- Close `WeakCanonical.countermodel_discrete` with **zero** new `sorry`, axiom, or statement
  weakening.
- Preserve the fully-qualified name `FormalSystem.Metalogic.WeakCanonical.countermodel_discrete`
  so `Completeness.lean` requires no edit.
- Drive `BXCanonical.completeness` to `[propext, Classical.choice, Quot.sound]`.
- Leave `scripts/check-module-invariants.sh` and all nine stale docstring sites truthful, so CI
  is green on the same commit series.

**Non-Goals**:
- Do NOT re-attempt the O1 isomorphism or `succ_cofinal`. Settled negatively and permanently
  (task 422 report 02; `Boneyard/BXPipelineGapAnalysis/`).
- Do NOT re-derive the companion lemma. `companionChronicle` is consumed by signature only.
- Do NOT do construction-level work in `ChronicleConstruction.lean` or `PointInsertion.lean`.
- Do NOT weaken `countermodel_discrete`'s statement to make it close. If the port does not
  elaborate, report the specific type mismatch and escalate — do not adjust the goal.
- Do NOT move `truth_transfer` out of `Transfer.lean` to break the cycle upstream (report §6:
  unbounded churn, strictly worse).

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| The ~380-line ported body fails to elaborate somewhere in the box case | H | L | Report §3a classified every symbol in the box case as fc-generic and carrier-agnostic; only `multiFam_total_eq` -> `multiFamGen_total_eq` changes. Phase 1 lands all scaffolding green first so a Phase 2 failure is isolated to the body |
| An `omega` replacement does not close its goal at `ℚ ×ₗ ℤ` | M | M | Phase 1 pre-lands the three arithmetic facts as named, independently-verified lemmas, so Phase 2 applies a proved name instead of guessing a tactic |
| Deleting `Transfer.lean:1049-1102` breaks a consumer not found by grep | H | L | Report §1 grep-verified `Completeness.lean:229` is the sole consumer; Phase 3 re-greps before deleting and the full `lake build` is the backstop |
| Duplicate-declaration clash if the new theorem lands under the final name while the old one still exists | M | M | Phase 2 lands under a temporary name (`countermodel_discrete_base_port`); Phase 3 renames and deletes in one atomic step |
| `check-module-invariants.sh` C2/C3 hard-fail after the sorry disappears | M | H (certain) | Declared transient between Phase 3 and Phase 4; Phase 4 is mandatory and immediately follows |
| Implementer substitutes a `sorry` to "make progress" | H | L | Explicit non-goal above; Phase 5 gates on a zero-sorry inventory and would catch it |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |

Phases within the same wave can execute in parallel. This plan is fully sequential.

---

### Phase 1: New module scaffold, aggregator wiring, and carrier arithmetic lemmas [COMPLETED]

**Goal**: Land every piece of mechanical scaffolding the port needs — the new module in the
build closure, the import edges, and the three `ℚ ×ₗ ℤ` arithmetic facts that replace `omega` —
as a fully green, independently committable commit, so that Phase 2 contains nothing but the
risky proof body.

**Tasks**:
- [ ] Create `FormalSystem/Metalogic/WeakCanonical/GroupModel/CountermodelBase.lean` with the
      standard copyright header and these imports:
      `FormalSystem.Metalogic.WeakCanonical.GroupModel.GroupableCompanion`,
      `FormalSystem.Metalogic.Algebraic.FlowFrame`, `Mathlib.Algebra.Order.Monoid.Prod`.
      (The third arrives transitively via `GoodGroupable.lean` but is listed explicitly for
      legibility, per report §4.)
- [ ] Write the module docstring: state that this module hosts the Base-MCS discrete
      countermodel, that it lives here rather than in `Transfer.lean` because
      `Transfer <- ReynoldsBridge <- GroupableCompanion` makes in-place closure a cycle, and
      that the fully-qualified name is deliberately preserved for `Completeness.lean`.
- [ ] Open `namespace FormalSystem.Metalogic.WeakCanonical`.
- [ ] Prove three named `private theorem`s over `ℚ ×ₗ ℤ` (report §5(ii), all probe-verified):
      shift-monotonicity (`w + t < w + s ↔ t < s`, by `add_lt_add_iff_left w`),
      shift-cancellation (`w + (s - w) = s`, by `abel`), and zero-shift (`0 + s = s`, by
      `zero_add`). Give them descriptive names; Phase 2 will cite them.
- [ ] Add a compile-time instance gate (a `example`/`#check` block, `noncomputable` where
      needed) confirming `AddCommGroup`, `LinearOrder`, `IsOrderedAddMonoid`, `Nontrivial` all
      resolve at `ℚ ×ₗ ℤ` and that `multiFamTaskFrameGen (ℚ ×ₗ ℤ) FamIdx` elaborates for a
      nonempty dummy index. Mirrors the existing gates at `GoodGroupable.lean:118-121` and
      `DiscreteCarrierProbe.lean:66-69`.
- [ ] Add `import FormalSystem.Metalogic.WeakCanonical.GroupModel.CountermodelBase` to
      `FormalSystem/Metalogic/WeakCanonical.lean`, placed after the existing
      `GroupModel.GroupableCompanion` import.
- [ ] Do NOT edit `Transfer.lean` in this phase.

**Timing**: 0.75 hours

**Depends on**: none

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: Three arithmetic lemmas are asserted sufficient to replace all 16 `omega`
calls (report §5(ii) enumerates exactly three replacement shapes across 16 sites). Confirm at
Phase 2 implementation time: if a fourth arithmetic shape appears in the `untl`/`snce` cases,
add it to this module and record the deviation rather than inlining an ad hoc tactic.

**Files to modify**:
- `FormalSystem/Metalogic/WeakCanonical/GroupModel/CountermodelBase.lean` - NEW; header,
  imports, docstring, namespace, three private arithmetic lemmas, instance gate
- `FormalSystem/Metalogic/WeakCanonical.lean` - one added import line

**Verification**:
- `lake build` completes successfully.
- The new module contains zero `sorry` tokens.
- `scripts/check-module-invariants.sh` still passes end-to-end (C3 still finds exactly one
  structural sorry, still in `Transfer.lean` / `countermodel_discrete`; C2 baseline unchanged).
- Commit on green.

---

### Phase 2: Port the v2 proof body at `ℚ ×ₗ ℤ` under a temporary name [COMPLETED]

**Goal**: Transcribe `countermodel_discrete_reynolds_v2`'s body (`ReynoldsBridge.lean:936-1352`)
into `CountermodelBase.lean` as `countermodel_discrete_base_port`, with the Base statement, the
`ℚ ×ₗ ℤ` carrier, and zero `sorry`. Landing under a temporary name keeps this phase green
alongside the still-sorried `Transfer.lean` original, isolating the risky elaboration from the
cutover.

**Tasks**:
- [ ] Declare `theorem countermodel_discrete_base_port` with the **byte-identical statement** of
      `Transfer.lean:1069-1076` — ten binders: `D`, `AddCommGroup`, `LinearOrder`,
      `IsOrderedAddMonoid`, `Nontrivial`, `F`, `TM`, `τ`, `τ.IsTotal`, `t`. Four v2 binders
      (`SuccOrder`, `PredOrder`, `IsSuccArchimedean`, `IsPredArchimedean`) are DROPPED (report
      §5); do not reintroduce them.
- [ ] Port the preamble: `FamIdx` as the subtype of Base-MCS box-equivalent to `A` carrying
      `box nextTop`, `f₀ := ⟨A, h_mcs, h_box_discrete, fun _ => Iff.rfl⟩`,
      `haveI : Nonempty FamIdx`, `sig := mkSigFrom φ`, `k := operatorDepth φ + 2`.
- [ ] Replace the `h_fam_good` step: `limitdom_is_good N hN_mcs (le_refl _) hN_box φ k` becomes
      `companionChronicle N hN_mcs hN_box φ k`, yielding `goodGroupable` not `good`. The
      `(le_refl _)` argument disappears (no `h_fc` slot).
- [ ] Rename `getZ` to `getQ` (a `QZStructure sig`); `.choose` / `.choose_spec` port verbatim.
- [ ] **DELETE** `h_bounds`, `h_lo`, `h_hi` (v2 `:971-987`), the
      `z_interval_carrier_contains_all` call, the `2 ≤ k` side condition those needed, and every
      `toCarrier (h_lo f) (h_hi f) e` application (16 sites) — with
      `QZStructure.toOrdered_carrier` being `rfl` to `ℚ ×ₗ ℤ`, every `toCarrier … (w₀ + t)`
      becomes plain `w₀ + t`, and the `Subtype.ext` / `.val` bookkeeping goes with it.
- [ ] Port `TM` with `valuation := fun w atom => (getQ w.1).interp (mkAtomMapFwd φ (.atom atom)) w.2`
      at `w : FamIdx × (ℚ ×ₗ ℤ)` (report §5(iii): types directly, `atom` case stays definitional).
- [ ] Port `h_root_neg`, `h_k_bound`, and the `truth_transfer` application obtaining `s₀`,
      substituting `FrameClass.Discrete` -> `FrameClass.Base` in `zero_mem_limit_dom`.
- [ ] Restate the `suffices h_truth_corr` with `w₀ t : ℚ ×ₗ ℤ`, `multiFamHistoryGen f w₀`, and
      target point `w₀ + t` (no `toCarrier`).
- [ ] Port the existential packaging: `refine ⟨ℚ ×ₗ ℤ, inferInstance ×4,
      multiFamTaskFrameGen (ℚ ×ₗ ℤ) FamIdx, TM, multiFamHistoryGen f₀ …,
      multiFamHistoryGen_total …, …⟩` — four fewer `inferInstance` slots than v2.
- [ ] Port the induction, case by case, verifying the goal after each with `lean_goal` /
      `lean_diagnostic_messages` before moving on: `atom` (definitional), `bot`, `imp`, then
      `box` (v2 relative lines 110-350: forward steps A1-A5/B/C and backward steps 1-7 — all
      fc-generic and carrier-agnostic; the ONLY edit is `multiFam_total_eq` ->
      `multiFamGen_total_eq`, plus `multiFamHistory` -> `multiFamHistoryGen`,
      `multiFamHistory_total` -> `multiFamHistoryGen_total`; the `Axiom.modal_t` /
      `DerivationTree.axiom [] _ (Axiom.modal_t ψ) trivial` step survives unchanged because
      `modal_t` is a `.Base` axiom and `FrameClass.le .Base _` is `True`).
- [ ] Port `untl` and `snce` (v2 relative lines 350-416). The correspondence map is `r ↦ w₀ + r`,
      an order-isomorphism on any ordered group. Forward witness `w₀ + s`; backward witness
      `rc - w₀` (was `rc.val - w₀`). Replace every `omega` with the Phase 1 lemma matching its
      shape. `TruthAt`'s `untl`/`snce` clauses quantify over all `s : D`, not over `τ.domain`,
      so there are no domain side conditions.
- [x] Confirm the module still has zero `sorry` and no new `axiom`. *(completed)*

**Deviations recorded (Scope Hypothesis confirmation)**: two additional private arithmetic
helpers beyond the three of Phase 1 were required, both anticipated by the phase's Scope
Hypothesis clause. (a) `qz_sub_add_cancel` (`z - t + t = z`) — a fourth arithmetic shape, in the
**box** forward case (`h_univ`), where the `ℤ` blueprint used `omega`; (b) `qz_exists_shift`
(`∃ x, w + x = r`) — the offset-surjectivity packaging of `qz_add_sub_cancel`, needed because
`rc`/`sc` in the `untl`/`snce` cases have type `((getQ f).toOrdered sig).carrier`, which is only
`rfl`-equal to `ℚ ×ₗ ℤ`; Lean's `-` elaborator compares operand types syntactically and cannot
see through the projection, so a subtraction cannot be written against those points directly.
The same `rfl`-not-syntactic gap forced the existential-packaging zero-shift step to use an
explicit congruence (`h_point`) instead of `rw [qz_zero_add]`. All three are bookkeeping around
the carrier's defeq presentation, not mathematical additions.

**Timing**: 2 hours

**Depends on**: 1

**Verification Tier**: full

**Commit Mode**: atomic-batch — declared file set is the single module
`FormalSystem/Metalogic/WeakCanonical/GroupModel/CountermodelBase.lean`. A partially
transcribed proof body is expected red and MUST NOT be committed; the phase produces exactly one
commit, on green. Do not retroactively widen this batch to other files.

**Scope Hypothesis**: The body is asserted to be ~380 lines and to require no substitutions
beyond the three named plus the two deltas of report §5. Confirm at implementation time by
diffing the ported body against `ReynoldsBridge.lean:936-1352`; any third delta is a deviation
to be recorded in the implementation summary, not absorbed silently.

**Files to modify**:
- `FormalSystem/Metalogic/WeakCanonical/GroupModel/CountermodelBase.lean` - add the ported
  theorem under the temporary name

**Verification**:
- `lake build` completes successfully.
- `#print axioms FormalSystem.Metalogic.WeakCanonical.countermodel_discrete_base_port` returns
  `[propext, Classical.choice, Quot.sound]` — no `sorryAx`.
- `grep -c sorry` on the new module is 0.
- `scripts/check-module-invariants.sh` still passes (the old sorry is still the sole one).
- **Escalation clause**: if any goal fails to close, do NOT insert a `sorry` and do NOT weaken
  the statement. Record the exact goal state and type mismatch, mark the phase `[BLOCKED]`, and
  report.

---

### Phase 3: Cutover — rename to the canonical name and delete the `Transfer.lean` original [COMPLETED]

**Goal**: Make the ported theorem BE `FormalSystem.Metalogic.WeakCanonical.countermodel_discrete`
and remove the sorried original, so that `Completeness.lean:229` — untouched — now resolves to
the proved theorem and `BXCanonical.completeness` becomes `sorryAx`-free.

**Tasks**:
- [ ] Re-grep for consumers of `countermodel_discrete` across `FormalSystem/` and `Tests/` to
      confirm `Completeness.lean:229` is still the sole non-docstring reference.
- [ ] Rename `countermodel_discrete_base_port` to `countermodel_discrete` in
      `CountermodelBase.lean` and give it the real doc-comment (Base-MCS discrete branch of
      `completeness`; consumes `companionChronicle`; carrier `ℚ ×ₗ ℤ`).
- [ ] Delete `FormalSystem/Metalogic/WeakCanonical/Transfer.lean` lines **1049-1102** — the
      `/-! ## countermodel_discrete — the one live sorry -/` section header through the `sorry`
      — leaving line 1104's `end FormalSystem.Metalogic.WeakCanonical` and trimming the blank
      line so the file ends cleanly.
- [ ] Verify `FormalSystem/Metalogic/BXCanonical/Completeness.lean` requires NO edit: it already
      imports both the `WeakCanonical` aggregator and `FormalSystem.Metalogic.Algebraic.FlowFrame`,
      and its ten-binder `obtain` pattern already matches. Confirm by build, do not preemptively
      edit.
- [ ] Update the `WeakCanonical.lean` aggregator comment block at `:50-70`: `GroupableCompanion`
      is no longer a "CI edge only … leaf" — it now has a real consumer. Rewrite that comment
      and place the `CountermodelBase` import as a normal (non-CI-edge) import.

**Timing**: 0.75 hours

**Depends on**: 2

**Verification Tier**: full

**Commit Mode**: atomic-batch — the rename and the deletion must land together or the build
carries a duplicate declaration. Declared file set: `CountermodelBase.lean`, `Transfer.lean`,
`WeakCanonical.lean`.

**Files to modify**:
- `FormalSystem/Metalogic/WeakCanonical/GroupModel/CountermodelBase.lean` - rename + doc-comment
- `FormalSystem/Metalogic/WeakCanonical/Transfer.lean` - delete lines 1049-1102
- `FormalSystem/Metalogic/WeakCanonical.lean` - demote the CI-edge comment for `GroupableCompanion`

**Verification**:
- `lake build` completes successfully with no duplicate-declaration error.
- `#print axioms FormalSystem.Metalogic.WeakCanonical.countermodel_discrete` ->
  `[propext, Classical.choice, Quot.sound]`.
- `#print axioms FormalSystem.Metalogic.BXCanonical.completeness` -> same three, **no `sorryAx`**.
- `Completeness.lean` shows zero diff.
- **Declared transient**: `scripts/check-module-invariants.sh` C2 and C3 are now EXPECTED TO
  FAIL (C2 pins a `sorryAx` baseline; C3 asserts `SORRY_COUNT -eq 1` and will report "found 0").
  This is the intended consequence of closing the sorry, is repaired by Phase 4, and does not
  block this phase's commit — the `lake build` gate is green. Phase 4 MUST follow immediately.

---

### Phase 4: Retarget the CI invariant checks and correct the nine stale-docstring sites [COMPLETED]

**Goal**: Restore `scripts/check-module-invariants.sh` to green against the new reality and make
every docstring that asserts "the sole/only live sorry" truthful. Acceptance is not met without
this phase.

**Tasks**:
- [ ] `scripts/check-module-invariants.sh` C2 (`AXIOM_BASELINE`, around `:128`): drop `sorryAx`
      from the `'FormalSystem.Metalogic.BXCanonical.completeness' depends on axioms: […]` line so
      it reads `[propext, Classical.choice, Quot.sound]`. The other three baseline lines are
      unchanged.
- [ ] `scripts/check-module-invariants.sh` C3 (`:167-200`): re-target from "exactly 1 structural
      sorry in `Transfer.lean` / `countermodel_discrete`" to "**zero** structural sorries".
      Delete the now-dead `EXPECTED_FILE` / `EXPECTED_THM` / `ENCLOSING`-scan machinery; on
      `SORRY_COUNT -ne 0`, fail and list the hits. Update C3's section comment accordingly.
- [ ] Update the nine docstring sites (report §8), removing or rewriting every "sole"/"only"/
      "one structural sorry"/"still open" claim:
      - `FormalSystem/Metalogic.lean` — 49, 116-118
      - `FormalSystem/Metalogic/WeakCanonical.lean` — 96-102 (Main Export), 107-124 (Status
        section: rewrite to "this subtree is sorry-free", and update the C3 description to match
        the retargeted check)
      - `FormalSystem/Metalogic/WeakCanonical/Transfer.lean` — 18-26 module header (the file no
        longer contains `countermodel_discrete`; point readers to
        `GroupModel/CountermodelBase.lean`)
      - `FormalSystem/Metalogic/BXCanonical/Completeness.lean` — 41-50, 173, 177-188, 215, 382
      - `FormalSystem/Metalogic/Decidability.lean` — 128-133
      - `FormalSystem/Metalogic/WeakCanonical/PriorExpressivenessDense.lean` — 95
      - `FormalSystem/Metalogic/WeakCanonical/RealModel/ShuffleReal.lean` — 43
      - `FormalSystem/Metalogic/BXCanonical/DiscreteCarrierProbe.lean` — 27-33 (the obligation it
        describes as open is now discharged; say so and name the discharging module)
      - `FormalSystem/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` — 70-85
        (route narrative)
- [x] Re-grep the tree for any remaining "sole sorry" / "only live sorry" / "one structural
      sorry" phrasing missed by the inventory and fix it. *(deviation: altered — the fresh
      repo-wide grep found five sites the report's nine-file inventory missed, all now fixed:
      `FormalSystem/README.md:30`, `FormalSystem/Metalogic/README.md:284`,
      `FormalSystem/Metalogic/WeakCanonical/README.md:26` (plus a stale line count and a
      missing `GroupModel/` row), `FormalSystem/Metalogic/Decidability/FMP/README.md:26`, and
      `scripts/check-module-invariants.sh:11` (the C3 header comment). The report's
      `Decidability.lean 128-133` site also had a companion at
      `Decidability/Verified/Decidable.lean:98`, likewise fixed. Per the phase's Scope
      Hypothesis these are additions to the list, not grounds to skip them.)*
- [ ] Do NOT reference task numbers in any of these files
      (`.claude/rules/no-task-references-in-deliverables.md`).

**Timing**: 1 hour

**Depends on**: 3

**Verification Tier**: full — the docstring edits alone would be `prose`, but this phase also
edits `scripts/check-module-invariants.sh`, which gates the repository; strictest-applicable
tie-break gives `full`.

**Commit Mode**: per-substep — the two script edits form one green sub-step (C2/C3 pass), and the
docstring sites form a second; commit each on green.

**Scope Hypothesis**: Nine files and two script checks are asserted to be the complete set
(report §8, grep-verified). Confirm at implementation time with a fresh repo-wide grep for the
stale-sorry phrasings before closing the phase; extra hits are additions to this list, not
grounds to skip them.

**Files to modify**:
- `scripts/check-module-invariants.sh` - C2 baseline line, C3 block
- The nine `FormalSystem/**` files listed above - docstring corrections

**Verification**:
- `bash scripts/check-module-invariants.sh` passes end-to-end, C2 and C3 both green.
- `lake build` still green (docstring edits must not cross out of comment boundaries).
- Repo-wide grep for "sole `sorry`" / "only live sorry" / "exactly one structural" returns no
  live (non-Boneyard, non-`specs/`) hits.

---

### Phase 5: Final verification and acceptance [NOT STARTED]

**Goal**: Produce the evidence that the task's acceptance criteria are met, from a clean build.

**Tasks**:
- [ ] `lake build` from a clean-ish state; record "Build completed successfully".
- [ ] Compile a scratch file against the built library printing:
      `#print axioms FormalSystem.Metalogic.WeakCanonical.countermodel_discrete` and
      `#print axioms FormalSystem.Metalogic.BXCanonical.completeness`. Both MUST be
      `[propext, Classical.choice, Quot.sound]` with **no `sorryAx`**.
- [ ] Also print `completeness_dense`, `completeness_discrete`, and
      `Chronicle.countermodel_dense` to confirm no regression against the C2 baseline.
- [ ] `bash scripts/check-module-invariants.sh` — all checks pass; C3 reports a structural sorry
      inventory of **ZERO**.
- [ ] Repo-wide structural-sorry grep over `FormalSystem/` excluding `Boneyard/` returns nothing.
- [ ] `lake build BimodalTest` / the test suite is green.
- [ ] Record the evidence in the implementation summary.

**Timing**: 0.5 hours

**Depends on**: 4

**Verification Tier**: full

**Commit Mode**: per-substep

**Files to modify**:
- None (verification only; summary artifact is written by the implement postflight)

**Verification**:
- Every bullet above produces its stated result. Any deviation blocks task completion.

---

## Testing & Validation

- [ ] `lake build` green at the end of every phase.
- [ ] `#print axioms WeakCanonical.countermodel_discrete` free of `sorryAx`.
- [ ] `#print axioms BXCanonical.completeness` free of `sorryAx`.
- [ ] `completeness_dense`, `completeness_discrete`, `Chronicle.countermodel_dense` axiom sets
      unchanged from the existing C2 baseline (no regression).
- [ ] `scripts/check-module-invariants.sh` passes with C3 asserting zero structural sorries.
- [ ] `FormalSystem/Metalogic/BXCanonical/Completeness.lean` has zero diff across the whole task.
- [ ] No new `axiom` declarations anywhere.
- [ ] Test suite (`lake build BimodalTest`) green.

## Artifacts & Outputs

- `FormalSystem/Metalogic/WeakCanonical/GroupModel/CountermodelBase.lean` (NEW) — hosts the
  proved `FormalSystem.Metalogic.WeakCanonical.countermodel_discrete` plus its private
  `ℚ ×ₗ ℤ` arithmetic lemmas.
- `FormalSystem/Metalogic/WeakCanonical/Transfer.lean` — 54 lines shorter; no longer hosts
  `countermodel_discrete`.
- `FormalSystem/Metalogic/WeakCanonical.lean` — one new import; CI-edge comment demoted.
- `scripts/check-module-invariants.sh` — C2 baseline and C3 check retargeted.
- Nine `FormalSystem/**` files with corrected docstrings.
- `specs/479_tc_close_countermodel_discrete_at_base/summaries/01_*-summary.md` — written at
  implement postflight, carrying the Phase 5 evidence.

## Rollback/Contingency

Every phase is an independent commit on a green `lake build`, so rollback is `git revert` of the
phase commits in reverse order. Reverting Phases 3-5 restores the sorried `countermodel_discrete`
in `Transfer.lean` and the original CI baseline; reverting Phases 1-2 additionally removes the
new module and its aggregator import. Because Phase 2 lands under a temporary name, a Phase 3+
rollback leaves a green tree with the ported theorem present but unconsumed — a safe resting
state from which to retry the cutover.

If Phase 2 does not elaborate: mark it `[BLOCKED]`, leave Phases 3-5 unstarted, and report the
exact goal state and type mismatch. Do not insert a `sorry`, do not weaken the statement, and do
not attempt the archived `succ_cofinal` route.
