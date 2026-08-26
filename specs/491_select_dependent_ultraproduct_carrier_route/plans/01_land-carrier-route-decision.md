# Implementation Plan: Land the Dependent Ultraproduct Carrier Route Decision

- **Task**: 491 - select_dependent_ultraproduct_carrier_route
- **Status**: [IMPLEMENTING]
- **Effort**: 1.75 hours
- **Dependencies**: None
- **Research Inputs**: `specs/491_select_dependent_ultraproduct_carrier_route/reports/01_dependent-ultraproduct-carrier-route.md`
- **Artifacts**: plans/01_land-carrier-route-decision.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

The primary deliverable of this task — the route-selection report — is already produced and is
not re-opened here. Route (a) (a bespoke quotient of `(∀ i, D i)` by the eventually-zero
`AddSubgroup`) is SELECTED; route (b) (carrier normalization first) is a NO-GO on three
independent grounds. What remains is durability: the evidence for that decision currently lives
in a 230-line prototype under `specs/`, which no build target compiles, so a future change to
`FormalSystem/Semantics/ShiftSet.lean` or a Mathlib bump could silently invalidate the decision
without anything going red. This plan lands that evidence where the build checks it, and records
the decision where the successor task will actually read it. It does **not** write the Łoś lemma,
does not construct the ultrafilter on the index type, and does not discharge `ShiftSet.sep` — all
three belong to `build_shiftset_ultraproduct_and_los_lemma`, which owns S2 and S3.

### Research Integration

Findings carried into this plan verbatim from the report:

- **Route (a) selected, verified.** The prototype at
  `specs/491_select_dependent_ultraproduct_carrier_route/prototype/DependentUltraproduct.lean`
  compiles sorry-free against the live tree (Lean v4.33.0-rc1, Mathlib `79d0395a`), and three
  `#print axioms` probes report `[propext, Classical.choice, Quot.sound]` with no `sorryAx`.
- **Instance burden is 5 (6 with Dense), not ~15.** `AddCommGroup` comes free from
  `QuotientAddGroup.Quotient.addCommGroup` because the quotient is by an `AddSubgroup`, not a raw
  setoid. Hand-supplied: `evZero` (3 fields), `LE`, `LinearOrder` (5 fields), `IsOrderedAddMonoid`
  (1 field), `Nontrivial`, plus `DenselyOrdered` on the Dense branch.
- **Do not import `Mathlib.Order.Filter.Germ` / `FilterProduct`.** Measured at 8 seconds / 5
  modules, but `Filter.Product` carries only `coeTC` and `Inhabited` — nothing the route needs.
  `Mathlib.Order.Filter.Ultrafilter.Basic` (already built) supplies everything used.
- **R3 is discharged by elaboration.** `shiftSetOnUD` elaborating `ShiftSet (UD φ D)` is only
  well-typed because the quotient stays in `Type`; this is a compiler check, not an assertion,
  and it is exactly the property that stops being checked if the file is left uncompiled.
- **Report §5 names three obligations that are explicitly out of scope here**: the ultrafilter on
  the index type, `ShiftSet.sep` on the ultraproduct, and `carrier_nonempty` plus the valuation.

### Prior Plan Reference

No prior plan. `specs/491_select_dependent_ultraproduct_carrier_route/plans/` was empty at
planning time.

### Roadmap Alignment

`specs/ROADMAP.md` was consulted read-only (it was not passed in the delegation context; no
roadmap phases are included and this plan does not modify it). Phase 1, Leg B
(`specs/ROADMAP.md:74-77`) records that the gate authorizing the ultraproduct route has been
passed but that "the expensive ultraproduct work itself is not yet scoped as tasks". This task
does not change that status: it makes the route decision durable so the scoping that follows
starts from checked ground rather than from a report claim.

### Scope Judgment (stated assumption, flagged for the reader)

The delegating instruction gates promotion of the prototype into the source tree on the report
recommending it. The report does **not** literally recommend promotion — it treats the prototype
as evidence. This plan therefore does **not** put the file in the `FormalSystem/` library, where
it would be unused code that the successor task immediately supersedes. It lands it instead under
`Tests/BimodalTest/` as a **probe**, which is this repository's existing, established convention
for a compiled-but-not-yet-consumed feasibility artifact (`RayRegionProbe.lean`,
`RegionGateProbe.lean`, `BoxNegPreservationProbe.lean`, `UntlSnceCopyProbe.lean`, all wired into
`Tests/BimodalTest.lean`). This preserves the compiled evidence without pre-empting S2. If the
reviewer disagrees and wants the file in `FormalSystem/Semantics/` instead, Phase 1 is a
single-path change; nothing else in the plan moves.

## Goals & Non-Goals

**Goals**:
- Put the route-(a) carrier construction under a build target, so the decision is checked by
  `lake build` rather than asserted in prose.
- Confirm the construction survives the library's stricter elaboration options
  (`autoImplicit := false`), which the ad-hoc `lake env lean` verification did not exercise.
- Record the selected route, the rejected route, and the anchor path where the successor task
  will read them.
- Leave the three unstarted obligations (index ultrafilter, `sep`, valuation) explicitly named
  and explicitly unattempted.

**Non-Goals**:
- The Łoś lemma, or any clause of it. Forbidden by the task description.
- The ultrafilter on `{L : List Formula // ∀ ψ ∈ L, ψ ∈ Γ}`. Belongs to S2.
- `ShiftSet.sep` on the ultraproduct, `carrier_nonempty`, or the valuation `A`. Report §5.
- Re-litigating route (b), or re-measuring the Mathlib build cost.
- Any import of `Mathlib.Order.Filter.Germ` or `Mathlib.Order.Filter.FilterProduct`.
- Adding anything to the `FormalSystem/` library.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Prototype relies on `autoImplicit`, which `BimodalTest`'s `leanOptions` disable — it was verified with bare `lake env lean`, not under the lib's options | M | M | This is precisely what Phase 1 measures. Every binder in the prototype is already explicit or in a `variable` block, so the expected fix is nil-to-small (add explicit binders). If it turns out non-trivial, keep the `set_option` scoped to the file rather than weakening the lib options |
| `set_option linter.unusedSectionVars false` masks a real problem when compiled in-tree | L | L | Keep the `set_option` (the prototype needs it for its `variable` blocks) but confine it to the probe file; do not add it to any shared config |
| `#print axioms` emits info messages into the test build output, adding noise | L | M | Acceptable — the axiom profile is the evidence. If the noise is judged unacceptable, wrap each in `/-- info: ... -/ #guard_msgs in`, which turns the profile into an assertion rather than a print. Do not simply delete them |
| Adding a probe to `Tests/BimodalTest.lean` slows the test build | L | L | The probe imports only `FormalSystem.Semantics.ShiftSet` and `Mathlib.Order.Filter.Ultrafilter.Basic`, both already built. Measured incremental cost expected to be seconds; record the actual figure |
| Doc comments in the probe cite task numbers, tripping the no-task-references lint (`Tests/**` is outside `specs/**` and the write-time hook blocks it) | M | M | Cite durable anchors only — `FormalSystem/Semantics/ShiftSet.lean`, `Metalogic/SetConsequence.lean`, `DiscreteNonCompactness.lean`, symbol names. Never "task N" |
| Scope creep into S2 while the file is open and the next step is obvious | H | M | The probe's own docstring states what it deliberately does not do. Phase 1's verification explicitly checks that no new declaration beyond the prototype's has appeared |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |

Phases within the same wave can execute in parallel.

### Phase 1: Land the verified carrier construction as a compiled semantics probe [COMPLETED]

**Goal**: The route-(a) construction compiles as part of the `BimodalTest` lean_lib, under that
library's own `leanOptions`, so the decision is protected by `lake build` from here on.

**Tasks**:
- [x] Copy `specs/491_select_dependent_ultraproduct_carrier_route/prototype/DependentUltraproduct.lean`
      to `Tests/BimodalTest/Semantics/DependentUltraproductProbe.lean`. Copy the mathematical
      content **verbatim**; do not re-derive, re-prove, or "improve" any proof.
- [x] Add the standard file header (copyright block matching the other probes) and rewrite the
      module docstring in the probe idiom used by `Tests/BimodalTest/RayRegionProbe.lean`: what
      hypothesis was tested, what was measured, and what the result licenses. It must state
      plainly that this is the *carrier* only, and that the Łoś lemma, the index-type
      ultrafilter, `ShiftSet.sep`, `carrier_nonempty`, and the valuation are **not** here.
- [x] Cite anchors by path and symbol only. No task numbers anywhere in the file (this path is
      outside `specs/**`; see `.claude/rules/no-task-references-in-deliverables.md`).
- [x] Rename the namespace from `UProto` to something that reads as a probe rather than a
      prototype (e.g. `BimodalTest.DependentUltraproductProbe`), updating the three
      `#print axioms` lines to the new fully-qualified names.
- [x] Build the single module and resolve any fallout from `autoImplicit := false` by adding
      explicit binders — **not** by re-enabling `autoImplicit` and **not** by changing
      `lakefile.lean`'s `theoryLeanOptions`. *(measured: no fallout — the module built clean in
      1.4s under `theoryLeanOptions`; no binder was added and no option was changed)*
- [x] Confirm `grep -c sorry` is 0 on the new file and that the three `#print axioms` outputs are
      still exactly `[propext, Classical.choice, Quot.sound]`.

**Timing**: 1 hour

**Depends on**: none

**Verification Tier**: interface

**Commit Mode**: per-substep

**Scope Hypothesis**: The plan asserts the probe is the prototype's 230 lines carried over with
**no new declarations** — specifically that the declaration set is exactly `evZero`,
`mem_evZero`, `UD`, `mk`, `mk_eq_mk`, the `LE` instance, `mk_le_mk`, the `LinearOrder` instance,
the `IsOrderedAddMonoid` instance, `not_eventually_false`, `mk_lt_mk`, the `Nontrivial` instance,
the `DenselyOrdered` instance, `carrierSetoid`, `UOmega`, `omk`, `omk_eq_omk`, `omk_surjective`,
`shU`, `shU_mk`, `shU_zero`, `shU_add`, `shiftSetOnUD`. Confirm at implementation time by
diffing the declaration names in the new file against the prototype (`grep -oE '^(def|theorem|abbrev|instance|noncomputable instance)[^:]*'` on both, or `#print`-free name extraction) and
asserting the sets are equal. Any addition is scope creep into S2 and must be reverted, not
justified.

**Files to modify**:
- `Tests/BimodalTest/Semantics/DependentUltraproductProbe.lean` - new; the promoted construction
- (no changes to `FormalSystem/**`, and none to `lakefile.lean`)

**Verification**:
- `lake env lean Tests/BimodalTest/Semantics/DependentUltraproductProbe.lean` exits 0 with no
  errors and no `sorry` *(deviation: altered — verified with the scoped
  `lake build BimodalTest.Semantics.DependentUltraproductProbe` instead, which is strictly
  stronger: `lake env lean` does not apply the lib's `leanOptions`, and applying them is the
  whole point of this phase. Exit 0, no errors, no warnings attributable to this file)*
- The declaration-set diff described under Scope Hypothesis is empty in both directions
- The three axiom profiles are unchanged from the report's §2.5

---

### Phase 2: Wire the probe into the test suite and record the decision for the successor task [NOT STARTED]

**Goal**: The probe is part of `lake build BimodalTest` (so it cannot rot unnoticed), and the
route decision plus its checked anchor are readable from where S2/S3 work will start.

**Tasks**:
- [ ] Add `import BimodalTest.Semantics.DependentUltraproductProbe` to `Tests/BimodalTest.lean`,
      placed with the other `BimodalTest.Semantics.*` imports.
- [ ] Run `lake build BimodalTest` and confirm green. Record the incremental build time the probe
      adds.
- [ ] Run `lake build` (default target) and confirm the `FormalSystem` library is untouched and
      still green.
- [ ] Append a short decision record to `specs/491_select_dependent_ultraproduct_carrier_route/reports/01_dependent-ultraproduct-carrier-route.md`
      (a new final section, not an edit to the existing findings): the selected route in one
      sentence, the rejected route in one sentence, the probe's in-tree path, and the three
      obligations from §5 restated as *not done here*.
- [ ] Update the `build_shiftset_ultraproduct_and_los_lemma` entry in `specs/state.json` so its
      description carries the concrete pointer — the selected route named explicitly, the report
      path, and the probe path — rather than the current indirect "the carrier route selected by
      the preceding research task". Append to the description; do not rewrite the rest of it, and
      do not touch its `artifacts` array. Then run `bash .claude/scripts/generate-todo.sh`.
- [ ] Leave `specs/ROADMAP.md` unmodified.

**Timing**: 45 minutes

**Depends on**: 1

**Verification Tier**: interface

**Commit Mode**: per-substep

**Files to modify**:
- `Tests/BimodalTest.lean` - one import line
- `specs/491_select_dependent_ultraproduct_carrier_route/reports/01_dependent-ultraproduct-carrier-route.md` - appended decision record
- `specs/state.json` - successor task's description gains the concrete route pointer
- `specs/TODO.md` - regenerated, not hand-edited

**Verification**:
- `lake build BimodalTest` exits 0
- `lake build` exits 0 and `git status --short` shows no modification under `FormalSystem/`
- `jq` read-back of the successor task's entry shows the appended pointer and an unchanged
  `artifacts` array
- `bash .claude/scripts/check-task-references.sh` (or equivalent lint) reports no task-number
  reference introduced under `Tests/**`

---

## Testing & Validation

- [ ] `lake build` green (default `FormalSystem` target unaffected)
- [ ] `lake build BimodalTest` green with the probe included
- [ ] Zero `sorry` in `Tests/BimodalTest/Semantics/DependentUltraproductProbe.lean`
- [ ] Axiom profile of each of the three probed declarations is
      `[propext, Classical.choice, Quot.sound]` — `sorryAx` absent
- [ ] No import of `Mathlib.Order.Filter.Germ` or `Mathlib.Order.Filter.FilterProduct` anywhere in
      the diff
- [ ] Declaration set of the probe equals that of the prototype (no S2 work smuggled in)
- [ ] No task-number references introduced outside `specs/**`

## Artifacts & Outputs

- `Tests/BimodalTest/Semantics/DependentUltraproductProbe.lean` — the route-(a) carrier
  construction, now compiled by a build target
- `Tests/BimodalTest.lean` — one added import
- `specs/491_select_dependent_ultraproduct_carrier_route/reports/01_dependent-ultraproduct-carrier-route.md`
  — appended decision record
- `specs/state.json` — successor task's description carries the concrete route pointer
- `specs/491_select_dependent_ultraproduct_carrier_route/summaries/01_land-carrier-route-decision-summary.md`
  — execution summary (written at wrap-up)

## Rollback/Contingency

Both phases are additive and confined to `Tests/**` and `specs/**`. Rollback is deleting
`Tests/BimodalTest/Semantics/DependentUltraproductProbe.lean`, reverting the single import line in
`Tests/BimodalTest.lean`, and reverting the `specs/` edits — the `FormalSystem/` library is never
touched, so no proof in the library can regress. If Phase 1 finds that the construction does not
survive `autoImplicit := false` without material proof changes, stop: do **not** rewrite the
proofs to make it fit. Record the finding in the report's decision record, leave the prototype
under `specs/` as the (still valid) evidence, and complete Phase 2's recording steps only. The
route decision stands either way; only its build-time protection would be deferred.
