# Implementation Plan: Shift-Set Representation Theorem (Compactness Feasibility Gate)

- **Task**: 424 - Prove shift-set representation theorem (compactness feasibility gate)
- **Status**: [COMPLETED]
- **Effort**: 5.5 hours (core Phases 1-6) + 1.5 hours (optional Phase 7)
- **Dependencies**: 470 (state.json); historically [361, 414, 439, 454] — 361 and 414 archived, gate-relevant vocabulary discharged
- **Research Inputs**: `specs/424_prove_shift_set_representation_theorem_compactness_feasibility_gate/reports/01_shift-set-representation-feasibility.md`; compiled prototype `specs/424_prove_shift_set_representation_theorem_compactness_feasibility_gate/prototype/ShiftSet-prototype.lean` (225 lines, `lake env lean`-verified)
- **Artifacts**: plans/01_shift-set-representation-theorem.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Land `FormalSystem/Semantics/ShiftSet.lean`: a `ShiftSet` structure over the two-sorted signature
`⟨Ω, D; <, +, 0, sh, (A_p)⟩` plus both directions of the representation theorem with their truth
correspondence, sorry-free, and register the module so `lake build` actually builds it. The
research phase produced a complete compiled prototype of every obligation, so this is a
transcription-and-integration task, not a discovery task: the mathematical risk is already
retired and the remaining risk is build-integration and namespace placement. Definition of done
is the gate's own evidence standard, verbatim: both directions sorry-free, `#print axioms` clean
of `sorryAx` on each, `lake build` green, and the task summary stating PASSED or FAILED.

### Research Integration

The research report (`reports/01_shift-set-representation-feasibility.md`) is machine-backed
rather than argumentative, and three of its findings change what this plan must contain:

1. **The gate is feasible and, in prototype form, already PASSES.** `forward_repr` reports
   `[propext, Quot.sound]`; `reverse_repr` reports `[propext, Classical.choice, Quot.sound]`
   (choice from `PartialHistory.hF_nonempty` only). No `sorryAx` on either. The cancel condition
   is NOT triggered.
2. **The design document's forward-direction "holds by construction" list is stale.** It was
   written against a 5-field `TaskFrame`; the live `TaskFrame`
   (`FormalSystem/Semantics/TaskFrame.lean:474-577`) has 7. `serial`, `spherical`, and the
   interpolation half of the biconditional `comp` are additionally free. `limit` is **not** free:
   it is false for an arbitrary `D`-action (counterexample: `D = ℝ` acting on `ℝ/ℚ`; the failure
   mode is a dense proper stabiliser). The `ShiftSet` structure therefore MUST carry a separation
   field transcribing the paper's *Limit* axiom. That field is first-order over the two-sorted
   signature, hence ultraproduct-preserved, so the design doc's cancel condition — which names an
   additional **non-elementary** hypothesis — is not met and **Route B stands**.
3. **A scope change is mandatory, not optional.** `lakefile.lean:18` sets `roots := #[FormalSystem]`
   and the semantics aggregator is `FormalSystem/Semantics.lean` (imports at :7-20, verified).
   A `ShiftSet.lean` that nothing imports is not built by `lake build`, which would make the
   "lake build green" acceptance criterion vacuous. See "Declared Scope Change" below.

Two rejected alternatives are carried forward from research as binding constraints, not
suggestions: **freeness** (`∀ w d, sh w d = w → d = 0`) must NOT replace the separation field —
constant total histories have full stabiliser, so the reverse direction cannot discharge freeness
and would be refuted; and **`Type*`** must NOT replace `Type` in the `D` binder — design-doc risk
R3, discharged at the structure declaration in Phase 1, not at assembly time.

### Declared Scope Change

Task `file_scope` is `["FormalSystem/Semantics/ShiftSet.lean"]`. This plan requires one addition:

| File | Change | Why |
|------|--------|-----|
| `FormalSystem/Semantics/ShiftSet.lean` | created (~250-300 lines) | the deliverable |
| `FormalSystem/Semantics.lean` | +1 import line | without it `lake build` never compiles the deliverable and the acceptance criterion is vacuous |
| `FormalSystem/Semantics/README.md` | +1 table row (discretionary) | the module table at :14 lists every sibling module; omitting the new one leaves the directory doc stale |

The first two are load-bearing for acceptance. The third is documentation-only; the implementer
may skip it without failing the gate, but should not skip it silently.

### Prior Plan Reference

No prior plan. This is the first plan for this task.

### Roadmap Alignment

`specs/ROADMAP.md` was not passed as `roadmap_path` in the delegation context, but it names this
task explicitly and the alignment is worth recording (read-only; this plan does not modify it):

- ROADMAP.md:61-63 states the Base/Dense strong-completeness GATING RULE with this task as the
  cheap feasibility gate for the whole semantic-compactness route.
- ROADMAP.md:56-57 records both the Base and Dense strong-completeness questions as "OPEN —
  gated on the shift-set representation theorem, task 424".
- ROADMAP.md:86-87 names the recommended route as semantic compactness via a bespoke ultraproduct
  over a shift-set representation of task models, gated per that rule.

A PASSED verdict from this plan unblocks authorization for S2-S5 and leg B of the capstone; it
does not itself advance them. A FAILED verdict cancels the branch (see Rollback/Contingency).

## Goals & Non-Goals

**Goals**:
- Land `FormalSystem.Semantics.ShiftSet` with exactly four axioms plus the valuation:
  `carrier_nonempty`, `sh_zero`, `sh_add`, `sep` (the *Limit* transcription), `A`.
- Land `ShiftSet.frame` discharging all **seven** live `TaskFrame` fields.
- Land both truth-correspondence theorems in the statement shapes fixed below, sorry-free.
- Register the module so `lake build` compiles it, and reproduce the two clean `#print axioms`
  lines inside the real build rather than in a scratch file.
- Record the gate verdict (PASSED / FAILED) explicitly in the task summary.

**Non-Goals**:
- Do NOT spawn, plan, or dispatch S2-S5 (ultraproduct carrier, Łoś lemma for `TruthAt`,
  compactness of the Base/Dense consequence relations, strong completeness for Dense and Base).
  That authorization activates only after this task lands sorry-free, per the GATING RULE
  (`specs/archive/361_.../design/02_compactness-route.md:255-280`).
- Do NOT touch task 362's legs A, C, or D, and do NOT touch task 423.
- Do NOT hoist a `WorldHistory.ext` into `Semantics/WorldHistory.lean` and retarget
  `RegionFrame.lean` — research recommends the local-copy option (a) to keep scope honest;
  consolidation is a clean separate follow-up.
- Do NOT prove the compactness theorem itself. This task proves only representability.

### Statement shapes that must land verbatim

```lean
theorem ShiftSet.forward_repr (S : ShiftSet D) (w : S.Carrier) (t : D) (φ : Formula) :
    TruthAt S.model (S.hist w) t φ ↔ ShiftTruth S w t φ

theorem ShiftSet.reverse_repr (F : TaskFrame D) (M : TaskModel F) (τ : F.HF) (t : D)
    (φ : Formula) :
    ShiftTruth (ShiftSet.ofModel F M) τ t φ ↔ TruthAt M τ.val t φ
```

A pair of bare *constructions* (`frame`, `ofModel`) with no truth correspondence would type-check
and be **vacuous as a gate** — `TruthAt` transfer is precisely what S3's Łoś lemma will be stated
against. Both theorems above must be present, and both must be what `#print axioms` is run on.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `lake build` is slow: Mathlib is only partially built in this checkout (~1840 of ~7000 oleans) | H | H | Iterate with `lake build FormalSystem.Semantics.ShiftSet`, not a bare `lake build`; try `lake exe cache get` before Phase 6. Budget Phase 6 for a long wall-clock build. |
| Prototype drift on namespace placement: the prototype declares `ShiftSet` at root with `open FormalSystem.Semantics`; the landed file must sit in `namespace FormalSystem.Semantics` (sibling convention, `Truth.lean:91`) | M | H | Place the whole file in `namespace FormalSystem.Semantics`; keep short names `ShiftSet.forward_repr` / `ShiftSet.reverse_repr`; run `#print axioms` on the **fully qualified** `FormalSystem.Semantics.ShiftSet.forward_repr` etc. |
| Implementer "simplifies" `sep` to a free action | H (refutes reverse direction) | M | Phase 1 docstring must state the rejection and its reason (constant total histories have full stabiliser). Phase 5 `ofModel` is the live check: it will not compile under freeness. |
| Implementer relaxes `D : Type` to `Type*` (design-doc risk R3) | H | L | Asserted at the structure binder in Phase 1. `TaskFrame.WorldState : Type` (`TaskFrame.lean:477`) and `valid` binds `D : Type` (`Validity.lean:95`); the reverse direction's carrier would not land where the forward direction needs it. |
| Local `wh_ext` copy silently drifts from `worldHistory_ext` (`Metalogic/Decidability/Verified/Bridge/RegionFrame.lean:132`) | L | M | Docstring the local copy as a local copy with an explicit cross-reference to that path; note the layering reason (importing `Metalogic/` from `Semantics/` inverts the layering). |
| Reverse direction's `Classical.choice` mistaken for a defect by a later reader | L | M | Module docstring states the provenance: `PartialHistory.hF_nonempty` (`Semantics/Extension/Extension.lean:266`, Zorn-based). The gate's evidence standard forbids `sorryAx`, not choice. |
| Scope change to `FormalSystem/Semantics.lean` rejected | H | L | Without it the acceptance criterion is vacuous; escalate rather than proceed. Declared explicitly above so it is decided before Phase 6, not during. |
| Gate FAILS (either direction refuted, or a non-elementary hypothesis proves necessary) | H | L (prototype compiles) | Cancel condition, not retry. See Rollback/Contingency. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |
| 6 | 6 | 5 |
| 7 | 7 | 6 |

Phases within the same wave can execute in parallel. This plan is fully sequential: every phase
edits the same single file and each builds on the previous phase's declarations. Phase 7 is
optional and is the only phase that may be dropped without failing the gate.

---

### Phase 1: Module header, `ShiftSet` structure, action lemmas, local extensionality [COMPLETED]

**Goal**: Create `FormalSystem/Semantics/ShiftSet.lean` with the structure declaration, R3
asserted at the binder, the two action-inverse lemmas, and the local history-extensionality copy.

**Tasks**:
- [x] Create the file with the repo's standard copyright header (copy the shape from
      `FormalSystem/Semantics/Truth.lean:1-5`) and `namespace FormalSystem.Semantics`.
- [x] Imports: `FormalSystem.Semantics.TaskModel`, `FormalSystem.Semantics.Truth`,
      `FormalSystem.Semantics.Extension.Extension`.
- [x] Module docstring stating: (a) what the representation theorem says; (b) that the four
      shift-set axioms replace seven frame axioms, three of which are consequences of
      functionality plus the group action; (c) that `Classical.choice` on the reverse direction
      comes only from `PartialHistory.hF_nonempty` (`Semantics/Extension/Extension.lean:266`)
      and is not a defect.
- [x] Declare `structure ShiftSet (D : Type) [AddCommGroup D] [LinearOrder D]
      [IsOrderedAddMonoid D] [Nontrivial D]` with fields `Carrier : Type`, `carrier_nonempty`,
      `sh`, `sh_zero`, `sh_add`, `sep`, `A`. **`D : Type`, not `Type*`; `Carrier : Type`.**
- [x] Docstring the `sep` field as the paper's *Limit* axiom transcribed over the shift action,
      recording (i) that it is first-order over `⟨Ω, D; <, +, 0, sh, (A_p)⟩` and hence
      ultraproduct-preserved, and (ii) that the stronger free-action axiom is **rejected**
      because constant total histories have full stabiliser.
- [x] Prove `sh_neg`, `sh_neg'`.
- [x] Add `wh_ext` with a docstring marking it a local copy of `worldHistory_ext`
      (`FormalSystem/Metalogic/Decidability/Verified/Bridge/RegionFrame.lean:132`) and naming the
      layering reason.
- [x] Verify the file elaborates: `lake env lean FormalSystem/Semantics/ShiftSet.lean`.

**Timing**: 0.75 hours

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: The structure is asserted to need exactly four axiom fields
(`carrier_nonempty`, `sh_zero`, `sh_add`, `sep`) plus `A`, and the `D` binder is asserted to need
exactly `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]`. Confirm at
implementation time by elaborating the structure and checking the instance list against
`TaskFrame`'s own binder in `FormalSystem/Semantics/TaskFrame.lean:474`; if an instance is
missing or extra, record the delta rather than assuming the prototype's list.

**Files to modify**:
- `FormalSystem/Semantics/ShiftSet.lean` - created; header, structure, `sh_neg`, `sh_neg'`, `wh_ext`

**Verification**:
- File elaborates with no errors and no `sorry`.
- `grep -n "Type\*" FormalSystem/Semantics/ShiftSet.lean` returns nothing (R3 assertion).
- The `sep` field is present and its docstring names the freeness rejection.

---

### Phase 2: `ShiftSet.frame` — all seven `TaskFrame` fields [COMPLETED]

**Goal**: Construct the induced task frame under `TaskRel w d u := (u = sh w d)` and discharge
every live `TaskFrame` field.

**Tasks**:
- [x] Define `ShiftSet.frame (S : ShiftSet D) : TaskFrame D` with `WorldState := S.Carrier`,
      `nonempty := S.carrier_nonempty`, `TaskRel := fun w d u => u = S.sh w d`.
- [x] Discharge `nullity_identity` (from `sh_zero`).
- [x] Discharge **both halves** of the biconditional `comp` — the interpolation half is witnessed
      by `sh w x`, uniquely; the design doc omits this half.
- [x] Discharge `converse` (from the two action laws).
- [x] Discharge `serial` (witnesses `sh w x` and `sh w (-x)`).
- [x] Set `limit := S.sep`.
- [x] Discharge `spherical`: under a functional task relation `Fib R w x` is a singleton and
      `Seg R w v x y` is a singleton or empty; `DirectedFamily` (`TaskFrame.lean:276`) then forces
      every member of the family to be the same singleton, so `⋂₀ S` is that singleton and is
      nonempty. No frame-theoretic machinery and no Zorn.
- [x] Add a short comment recording that `serial`, `spherical`, and `comp`'s interpolation half
      are free consequences of functionality plus the group action, correcting the design doc's
      5-field list.
- [x] Verify: `lake env lean FormalSystem/Semantics/ShiftSet.lean`.

**Timing**: 1 hour

**Depends on**: 1

**Verification Tier**: local

**Scope Hypothesis**: The live `TaskFrame` is asserted to have exactly seven fields
(`nonempty`, `nullity_identity`, `comp`, `converse`, `serial`, `limit`, `spherical`, at
`FormalSystem/Semantics/TaskFrame.lean:474-577`). Confirm by reading the structure at
implementation time and enumerating its fields; if the count differs, the extra/missing field is
a new obligation and must be discharged or escalated before Phase 3, not deferred.

**Files to modify**:
- `FormalSystem/Semantics/ShiftSet.lean` - add `ShiftSet.frame`

**Verification**:
- `ShiftSet.frame` elaborates with no missing-field error and no `sorry`.
- No `sorry` anywhere in the file.

---

### Phase 3: `hist`, `hist_isTotal`, `model`, `total_eq_orbit` [COMPLETED]

**Goal**: Build the induced total history through a carrier point, the induced task model, and
prove the re-issue's named new forward obligation: the constructed frame's total histories are
exactly the shift orbits.

**Tasks**:
- [x] Define `ShiftSet.hist (S) (w) : WorldHistory S.frame` with `domain := fun _ => True`,
      `states := fun t _ => S.sh w t`, `respects_task` from `sh_add` + `add_sub_cancel`, `convex`
      trivial.
- [x] Prove `hist_isTotal`.
- [x] Define `ShiftSet.model (S) : TaskModel S.frame` with `valuation := fun w p => S.A p w`.
- [x] Prove `total_eq_orbit (S) (σ : WorldHistory S.frame) (hσ : σ.IsTotal) :
      σ = S.hist (σ.states 0 (hσ 0))`, via `wh_ext` and `σ.respects_task 0 r` after `sub_zero`.
- [x] Docstring `total_eq_orbit` as the obligation the task re-issue anticipated, noting that it
      is genuine and easy but was not the only new obligation and not the hard one.
- [x] Verify: `lake env lean FormalSystem/Semantics/ShiftSet.lean`.

**Timing**: 0.5 hours

**Depends on**: 2

**Verification Tier**: local

**Files to modify**:
- `FormalSystem/Semantics/ShiftSet.lean` - add `hist`, `hist_isTotal`, `model`, `total_eq_orbit`

**Verification**:
- All four declarations elaborate; no `sorry`.
- `total_eq_orbit` states equality of histories, not merely of states.

---

### Phase 4: `ShiftTruth` and the forward direction [COMPLETED]

**Goal**: Define shift-set truth with `box` ranging over the whole carrier, and prove
`forward_repr` by induction on the formula.

**Tasks**:
- [x] Define `ShiftTruth (S : ShiftSet D) : S.Carrier → D → Formula → Prop` with all six clauses
      (`atom`, `bot`, `imp`, `box`, `untl`, `snce`), matching `TruthAt`'s clause structure
      (`FormalSystem/Semantics/Truth.lean:159-167`). `box` quantifies over the whole carrier —
      there is no `Omega` parameter anywhere in the current semantics.
- [x] Prove `forward_repr` in the verbatim statement shape fixed above, by
      `induction φ generalizing w t`. The `box` case is where `hist_isTotal` (forward) and
      `total_eq_orbit` (backward) are consumed.
- [x] Docstring `forward_repr` as the FORWARD DIRECTION of the representation theorem.
- [x] Verify: `lake env lean FormalSystem/Semantics/ShiftSet.lean`.

**Timing**: 1 hour

**Depends on**: 3

**Verification Tier**: local

**Files to modify**:
- `FormalSystem/Semantics/ShiftSet.lean` - add `ShiftTruth`, `forward_repr`

**Verification**:
- `forward_repr`'s statement matches the verbatim shape in "Goals & Non-Goals" character-for-character
  modulo namespace qualification.
- Elaborates sorry-free; all six formula constructors covered with no `sorry` in any branch.

---

### Phase 5: `ts_zero`, `ts_add`, `rev_sep`, `ofModel`, and the reverse direction [COMPLETED]

**Goal**: Build the shift set induced by an arbitrary task model and prove `reverse_repr`.

**Tasks**:
- [x] Prove `ts_zero : WorldHistory.timeShift σ 0 = σ` and
      `ts_add : timeShift (timeShift σ a) b = timeShift σ (a + b)` via `wh_ext` and
      `WorldHistory.states_eq_of_time_eq`.
- [x] Prove `rev_sep {F} (σ τ : F.HF) : (∀ x, 0 < x → ∃ y, |y| < x ∧ τ = σ.timeShift y) → τ = σ`,
      discharging the separation field straight out of `F.limit`: at each time `t`,
      `σ.respects_task t (t+y)` gives `F.TaskRel (σ.states t) y (τ.states t)`, and `F.limit`
      collapses the two states. **No new frame hypothesis is needed** — record this in a
      docstring, since it is the reason freeness must be rejected.
- [x] Define `ofModel (F : TaskFrame D) (M : TaskModel F) : ShiftSet D` with
      `Carrier := F.HF`, `carrier_nonempty := PartialHistory.hF_nonempty F F.nonempty.some`,
      `sh := TaskFrame.HF.timeShift`, `sep := rev_sep`,
      `A := fun p τ => TruthAt M τ.val 0 (Formula.atom p)`.
- [x] Prove `reverse_repr` in the verbatim statement shape fixed above, by
      `induction φ generalizing τ t`. The `atom` case consumes
      `TimeShift.time_shift_preserves_truth` (`Semantics/Truth.lean:457`, signature
      `(M) (σ) (x y : D) (φ)`, **unconditional** — no `h_sc` argument, since `ShiftClosed` is
      retired, not renamed) together with `TaskFrame.HF.timeShift_val`
      (`Semantics/WorldHistory.lean:525`).
- [x] Docstring `ofModel` and `reverse_repr` as the REVERSE DIRECTION.
- [x] Verify: `lake env lean FormalSystem/Semantics/ShiftSet.lean`.

**Timing**: 1 hour

**Depends on**: 4

**Verification Tier**: local

**Files to modify**:
- `FormalSystem/Semantics/ShiftSet.lean` - add `ts_zero`, `ts_add`, `rev_sep`, `ofModel`, `reverse_repr`

**Verification**:
- `reverse_repr`'s statement matches the verbatim shape modulo namespace qualification.
- `ofModel` elaborates with `sep` discharged by `rev_sep` and **no** freeness field.
- Elaborates sorry-free.

---

### Phase 6: Register the module, run the gate evidence, close the gate [COMPLETED]

**Goal**: Make `lake build` actually build the file, and reproduce the two clean `#print axioms`
lines inside the real build rather than in a scratch elaboration. This is the phase at which the
gate verdict is determined.

**Tasks**:
- [x] Add `import FormalSystem.Semantics.ShiftSet` to `FormalSystem/Semantics.lean` (import block
      at :7-20), placed to keep the existing ordering convention.
- [x] Add a row for `ShiftSet.lean` to the module table in `FormalSystem/Semantics/README.md`
      (table at :14) — discretionary; do not skip silently.
- [x] Try `lake exe cache get` before building, given the partial Mathlib build in this checkout.
- [x] Run `lake build FormalSystem.Semantics.ShiftSet` first (fast path), then the full
      `lake build` for the acceptance criterion. Budget for a long wall-clock build.
- [x] Run `#print axioms FormalSystem.Semantics.ShiftSet.forward_repr`,
      `#print axioms FormalSystem.Semantics.ShiftSet.reverse_repr`, and
      `#print axioms FormalSystem.Semantics.ShiftSet.total_eq_orbit` (or `lean_verify` on the
      fully qualified names) and record the exact output.
- [x] Confirm `grep -rn "sorry" FormalSystem/Semantics/ShiftSet.lean` returns nothing.
- [x] Record the gate verdict — **PASSED** if both directions are sorry-free with no `sorryAx` on
      either and `lake build` is green; **FAILED** otherwise — for the task summary.

**Timing**: 1.25 hours (dominated by build wall-clock, not by edits)

**Depends on**: 5

**Verification Tier**: full

**Scope Hypothesis**: This phase asserts the registration edit is exactly one import line in
`FormalSystem/Semantics.lean` plus one README table row, and that the expected axiom sets are
`[propext, Quot.sound]` for `forward_repr` and `[propext, Classical.choice, Quot.sound]` for
`reverse_repr`. Confirm by reading `FormalSystem/Semantics.lean:7-20` before editing and by
comparing the actual `#print axioms` output against the expected sets; any additional axiom —
and above all any `sorryAx` — is a gate-relevant finding to be recorded, not normalized away.

**Files to modify**:
- `FormalSystem/Semantics.lean` - +1 import line (declared scope change)
- `FormalSystem/Semantics/README.md` - +1 module-table row (discretionary)

**Verification**:
- `lake build` exits green.
- Neither `#print axioms` line contains `sorryAx`.
- Zero occurrences of `sorry` in `FormalSystem/Semantics/ShiftSet.lean`.
- Both verbatim theorem statements are present in the landed file.

---

### Phase 7: (OPTIONAL) Dyadic counterexample witnessing that `sep` is not derivable [COMPLETED]

**Goal**: Convert "the `sep` field is an unjustified strengthening of the shift-set notion" from
an open reviewer objection into a theorem, by exhibiting a `D`-action satisfying `sh_zero` and
`sh_add` for which the separation condition fails.

**Tasks**:
- [x] Construct `D := ℚ`, `Ω := ℚ ⧸ H` with `H := {q : ℚ | ∃ (a : ℤ) (n : ℕ), q = a / 2^n}` (the
      dyadics — a dense proper subgroup of `ℚ`), `sh [a] d := [a + d]`.
- [x] Prove `1/3 ∉ H` (`2^n = 3a` would force `3 ∣ 2^n`).
- [x] Prove that both action laws hold but the separation condition fails at `w := [0]`,
      `u := [1/3]`.
- [x] Docstring the result as the justification for `sep` being a structure field rather than a
      derived lemma.
- [x] Rebuild and confirm no regression to the Phase 6 evidence.

**Timing**: 1.5 hours

**Depends on**: 6

**Verification Tier**: local

**Scope Hypothesis**: Research estimates 40-60 lines for the dyadic construction and notes the
`ℝ`/`ℚ` variant is avoided only because `Mathlib.Data.Real.Irrational` is not in this checkout's
partial Mathlib build. Confirm both at implementation time: check whether the needed Mathlib
modules are actually built before starting, and if the line count runs materially over, stop and
report rather than expanding — this phase is explicitly optional and must not delay the gate.

**Files to modify**:
- `FormalSystem/Semantics/ShiftSet.lean` - append the counterexample section

**Verification**:
- The counterexample elaborates sorry-free.
- Phase 6's `#print axioms` output on both directions is unchanged.

---

## Testing & Validation

- [x] `lake build` exits 0 (full build, after registration in Phase 6).
- [x] `#print axioms FormalSystem.Semantics.ShiftSet.forward_repr` — no `sorryAx`
      (expected `[propext, Quot.sound]`).
- [x] `#print axioms FormalSystem.Semantics.ShiftSet.reverse_repr` — no `sorryAx`
      (expected `[propext, Classical.choice, Quot.sound]`; choice traced to
      `PartialHistory.hF_nonempty` only).
- [x] `#print axioms FormalSystem.Semantics.ShiftSet.total_eq_orbit` — no `sorryAx`.
- [x] `grep -rn "sorry" FormalSystem/Semantics/ShiftSet.lean` returns nothing.
- [x] `grep -n "Type\*" FormalSystem/Semantics/ShiftSet.lean` returns nothing (R3).
- [x] Both verbatim theorem statements present; neither direction reduced to a bare construction.
- [x] `ofModel` carries no freeness field.
- [x] `FormalSystem/Semantics.lean` imports `FormalSystem.Semantics.ShiftSet`.
- [x] Task summary states the gate verdict explicitly as PASSED or FAILED.

## Artifacts & Outputs

- `FormalSystem/Semantics/ShiftSet.lean` — new module, ~250-300 lines including docstrings
  (Phases 1-6; ~300-360 with optional Phase 7).
- `FormalSystem/Semantics.lean` — one added import line.
- `FormalSystem/Semantics/README.md` — one added module-table row (discretionary).
- Task summary under `specs/424_.../summaries/` recording the gate verdict, the two
  `#print axioms` outputs verbatim, and the two design-document corrections (the stale 5-field
  "by construction" list; the `limit` gap and its elementary fix).

## Rollback/Contingency

**If a phase fails to compile**: the prototype at
`specs/424_.../prototype/ShiftSet-prototype.lean` is a compiled, line-for-line reference for every
declaration in Phases 1-5. Diff against it before improvising. Do not introduce `sorry` to get
past a red phase — a `sorry` anywhere in this file makes the gate FAIL by definition, so a stuck
phase is reported, not papered over.

**If registration proves impossible** (Phase 6): the file itself may still be sorry-free, but the
"lake build green" criterion is unmet and the gate does not pass. Escalate the scope decision
rather than declaring a pass on `lake env lean` evidence alone.

**If the gate FAILS** — either direction is refuted, or the construction cannot be stated without
an additional **non-elementary** hypothesis — then Route B (semantic compactness via ultraproduct)
is **REFUTED and the whole branch is cancelled, not retried**, per the GATING RULE
(`specs/archive/361_strong_completeness_architecture_and_weak_terminus_gap_analysis/design/02_compactness-route.md:255-280`).
In that event: record the refutation in the summary, re-open the Q1 compactness question, and do
**not** proceed to S2 hoping the gap can be patched downstream. Note explicitly that the `sep`
field does **not** trigger this condition — it is first-order over
`⟨Ω, D; <, +, 0, sh, (A_p)⟩` and hence ultraproduct-preserved.

**Git rollback**: the deliverable is one new file plus a one-line import; `git checkout --
FormalSystem/Semantics.lean FormalSystem/Semantics/README.md && rm FormalSystem/Semantics/ShiftSet.lean`
restores the tree exactly.
