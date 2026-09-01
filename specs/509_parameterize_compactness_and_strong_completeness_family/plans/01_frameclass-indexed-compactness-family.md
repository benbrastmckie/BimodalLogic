# Implementation Plan: Task #509

- **Task**: 509 - Parameterize the compactness and strong-completeness family by `FrameClass`
- **Status**: [IMPLEMENTING]
- **Effort**: 5.25 hours
- **Dependencies**: None (tasks 507 and 508 are landed prerequisites)
- **Research Inputs**: `specs/509_parameterize_compactness_and_strong_completeness_family/reports/01_frameclass-indexed-compactness-family.md` plus three probe files in the same directory
- **Artifacts**: plans/01_frameclass-indexed-compactness-family.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

This is a **transplant**, not a derivation. The research compile-verified the entire collapse
against the live tree and left three probe files. Every definition, both collapsed theorems, all
Base/Dense/Discrete instantiations, and the whole Dedekind row already compile with axiom profile
`[propext, Classical.choice, Quot.sound]` — identical to the C14 baseline, `sorryAx` absent. The
implementer's job is to move verified text into `FormalSystem/`, repair exactly two friction
points with fixes that are themselves already compiled, and update a documentation surface that is
larger than the research reported.

The collapse is cheap because **task 507 already paid for it**. `Semantics/Validity.lean` defines
`valid := ValidIn .Base` (`:377`), `ValidDense := ValidIn .Dense` (`:521`),
`ValidDiscrete := ValidIn .Discrete` (`:595`), `ValidDedekindDense := ValidIn .Dedekind` (`:752`)
as plain `def`s. So an indexed `Compact fc` stated with `ValidIn fc (…)` is **definitionally
equal** to today's `CompactBase`/`CompactDense`/`CompactDiscrete`. **Eight of the ten per-class
statements are recovered by `rfl`.** Do not plan or perform proof work where `rfl` suffices.

### Research Integration

Findings carried into this plan verbatim:

- The four indexed definitions (`SatisfiableSet`, `ModelExistence`, `Compact`,
  `StrongCompleteness`), transplanted from `probe_509.lean` Part A.
- `strongCompleteness_of_compact` and `compact_of_modelExistence`, transplanted from
  `probe_509.lean` Parts C and D. The `engine` parameter stays live, per the task brief.
- `ValidIn.of_not`, the one missing generic lemma, from `probe_509.lean` Part D.
- The two friction-point repairs, from `probe_509c.lean` §C1/§C1'/§C2 and §C3.
- The Dedekind handoff shape, from `probe_509.lean` Part E.

### Independent anchor re-verification — three defects found in the research inventory

Every line citation below was re-derived by grep against `HEAD = ac6080ae2`. The research's own
anchors all check out, but its **call-site inventory is incomplete in three ways**. Treat the
corrections below as authoritative over research §5.

**Defect 1 (build-breaking).** Research §5 classifies the four theorems being deleted as having
no consumer outside `Compactness.lean`. That is wrong. `FormalSystem/Metalogic/StrongCompleteness.lean`
carries three live `#print axioms` directives naming them:

```
StrongCompleteness.lean:1047:#print axioms strongCompletenessBase_of_compact
StrongCompleteness.lean:1048:#print axioms compactBase_of_modelExistence
StrongCompleteness.lean:1049:#print axioms compactDense_of_modelExistenceDense
```

A `#print axioms` on a deleted name is a **hard elaboration error**. Phase 4 must rewrite this
block, together with the audit prose at `:1005-1021` that narrates "these three reductions".

**Defect 2 (wide prose surface).** Research §5 lists only `Metalogic.lean:109-118,:158-175` as
prose naming the deleted theorems. The live surface is much larger — 24 further sites, enumerated
in Phase 5's file inventory. In particular `SetConsequence.lean` and `StrongCompleteness.lean`
each carry six-plus docstring references to names that will not exist.

**Defect 3 (incomplete stale-citation list).** Research §5 lists
`docs/user-guide/architecture.md:824-826`. The live table spans `:823-829` (seven rows, including
the three Dense rows). Full corrected list in Phase 5.

Two cosmetic notes, neither affecting the work: research §7 cites the Dedekind adapter shape as
`probe_509c.lean` §B6, but it is in `probe_509b_negative_control.lean` §B6 (the code is correct);
and `FormalSystem/Metalogic/README.md:143` records `StrongCompleteness.lean` at 943 lines when the
live file is 1,060 — **pre-existing** staleness introduced by task 508, not by this task.

One confirmation worth stating because it contrasts sharply with task 508's run: `Tests/` has
**zero** consumers of any of the ten per-class names or the four theorems. There is no test-suite
edit in this task.

### Prior Plan Reference

No prior plan for task 509. Two adjacent landed tasks calibrate the effort and establish the
conventions this plan follows:

- **Task 507** collapsed the validity layer onto `ValidIn` and established the *binder-shape
  adapter* convention (`ValidDense.of_forall`/`.apply`) for absorbing an added frame-condition
  slot at call sites. Its plan recorded that a `.of_not` contrapositive adapter had to be added
  beyond the planned two — the same lemma family this task extends generically.
- **Task 508** collapsed the consequence layer onto `SetConsequenceOnFrames`/
  `SetSemanticConsequenceOn`, with the frame condition as an **explicit argument**. That is
  precisely why `compact_of_modelExistence` needs no `.apply` adapter where the two hand-written
  bridges each needed a class-specific one.

Effort calibration from 508: the mechanical portion of a collapse of this size runs ~4-6 hours
when the target text is pre-compiled, and the documentation tail is consistently underestimated.
This plan allocates a full hour to Phase 5 accordingly.

### Roadmap Alignment

No `specs/ROADMAP.md` in this repository; `roadmap_flag` not set. No roadmap phases added.

## Goals & Non-Goals

**Goals**:

- Define `SatisfiableSet`, `ModelExistence`, `Compact`, `StrongCompleteness` once, indexed by
  `FrameClass`, in `Metalogic/SetConsequence.lean` beside `SetSemanticConsequenceOn`.
- Recover all ten existing per-class names as instantiations with statements unchanged (eight by
  `rfl`, two by an absorbed binder slot).
- Replace the four duplicated theorems with `strongCompleteness_of_compact` and
  `compact_of_modelExistence`, preserving the `engine` parameter.
- Add the generic `ValidIn.of_not` to `Semantics/Validity.lean`.
- Leave the tree sorry-free, `lake build` green, every currently-provable result still provable
  with an **unchanged axiom profile**.
- Record the exact shape the Dedekind follow-on task inherits.

**Non-Goals**:

- **Discharging anything.** `ModelExistenceBase`/`ModelExistenceDense` keep their current
  ultraproduct proofs. The ultraproduct chain owns that obligation.
- Stating `CompactDedekindDense` / `StrongCompletenessDedekindDense` in the tree. Those are the
  follow-on task's Part 1. This task only *enables* them and records their shape.
- Removing the `engine` parameters. They came from task 493 and stay live by explicit instruction.
- Renaming `.Dedekind` to `.Complete`. That rename was considered and **rejected**.
- Touching `ValidDedekind := ValidOnFrames TaskFrame.IsComplete` (`Validity.lean:698`). It is
  deliberately not a `ValidIn` — the bare Complete clause, which `ℤ` satisfies — and is not part
  of this family.
- Fixing the two pre-existing gate failures recorded below.
- Making `probe_509b_negative_control.lean` compile. See the standing warning in Phase 0.

## Phase 0 — Standing warnings (read before starting any phase)

**The negative control is supposed to fail.**
`specs/509_.../reports/probe_509b_negative_control.lean` is an **annotated expected-to-fail**
file. It records which call-site shapes break under the collapse and Lean's exact error text, so
the implementer does not rediscover them. It is not broken work. **Do not try to make it
compile, do not "repair" it, and do not treat its failure as a task defect.** Its §B4 and §B5
sub-sections do succeed and are informative; the rest is the control.

**The build-guard has a silent no-op mode.** From task 508's run:
`lake-build-guard.sh build --timeout 1800 --` with nothing after the `--` invokes bare `lake`,
prints help, and **exits 0 without building**. Always name build targets explicitly. Treat a
dropped job count, or a suspiciously fast green, as a signal to re-run rather than as success.

**Pre-existing gate failures — reasoned exclusions, confirmed present before any change:**

| Gate | Failure | Status |
|------|---------|--------|
| `scripts/check-module-invariants.sh` C6 | 4 unreachable live modules absent from `scripts/module-invariants-manifest.txt` | Pre-existing; out of scope |
| `scripts/readme-lint.sh` check 1 | `MISSING: FormalSystem/Semantics/Ultraproduct/README.md` (4 `.lean` files) | Pre-existing; out of scope |

Acceptance is measured against **these as baseline**, not against a clean run. A **C14 or C15
regression WOULD be this task's defect** and must be fixed, not excluded.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Deleting the four theorems breaks `#print axioms` at `StrongCompleteness.lean:1047-1049` | H | H (certain if unhandled) | Phase 4 rewrites that block in the same commit as the deletion; called out explicitly in its task list |
| Implementer re-derives instead of transplanting, drifting from the verified text | H | M | Every phase names its probe source section; deviation from probe text requires a recorded reason |
| Implementer tries to fix the negative control | M | M | Phase 0 standing warning; restated in Phases 3 and 6 |
| Binder-shape break at `SatisfiableBaseSet`/`SatisfiableDiscreteSet` leaves the tree red between commits | M | M | Phase 3 is `atomic-batch`: redefinition and all six call-site repairs land together |
| Axiom profile drifts (a `Classical` leak or `sorryAx`) | H | L | Phase 6 audits all seven declarations against the recorded C14 baseline; probe already reports them clean |
| Silent no-op build passes as green | H | M | Explicit targets required; Phase 6 records the job count |
| Documentation tail under-scoped (research listed ~7 sites; the real count is ~31) | M | M | Phase 5 carries a complete greped inventory, and closes with a zero-hit grep |
| `inferInstance` invisibility recurs at a site not yet enumerated | M | L | Phase 3 verification greps every bare `inferInstance` in the two touched modules |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3 | 2 |
| 3 | 4 | 1, 3 |
| 4 | 5 | 3, 4 |
| 5 | 6 | 5 |

Phases within the same wave can execute in parallel. Phases 1 and 2 touch disjoint files
(`Semantics/Validity.lean` vs `Metalogic/SetConsequence.lean`) and are genuinely independent.

**Sequencing note — why redefinition (Phase 3) precedes theorem collapse (Phase 4).** The
opposite order looks natural but costs work. `compact_of_modelExistence` is stated over
`ModelExistence fc`; today's `ModelExistenceBase` is *not* defeq to `ModelExistence .Base` (one
extra `∃ _ : True` binder). Collapsing the theorems first would therefore require a throwaway
transport theorem at Base — exactly `probe_509.lean`'s `modelExistenceBase'`, which exists in the
probe only so the probe needs no tree edit. Redefining first makes `ModelExistenceBase` *be*
`ModelExistence .Base`, and the bridge then applies directly with no transport.

---

### Phase 1: Add the generic `ValidIn.of_not` [COMPLETED]

**Goal**: Supply the one prerequisite that is missing tree-wide, so Phase 4's
`compact_of_modelExistence` has its contrapositive available.

**Context**: `Semantics/Validity.lean` has all four per-class contrapositives —
`valid.of_not:405`, `ValidDense.of_not:548`, `ValidDiscrete.of_not:623`,
`ValidDedekindDense.of_not:774` — and both generic adapters `ValidIn.of_forall_total:494` and
`ValidIn.apply_total:501`, but **no generic `ValidIn.of_not`**. This is the only edit this task
makes outside `FormalSystem/Metalogic/`.

**Tasks**:
- [x] Read `FormalSystem/Semantics/Validity.lean:481-510` to confirm the surrounding adapter
      block's shape and docstring idiom.
- [x] Add `ValidIn.of_not` immediately after `ValidIn.apply_total` (currently ending `:504`),
      transplanted from `probe_509.lean` Part D (there named `ValidIn_of_not`; **rename to the
      dotted `ValidIn.of_not`** to match the file's namespace convention):
      ```lean
      theorem ValidIn.of_not {fc : ProofSystem.FrameClass} {φ : Formula} (h : ¬ ValidIn fc φ) :
          ¬ ∀ (F : TaskFrame), fc.Sat F → ∀ (M : TaskModel F) (τ : WorldHistory F),
              τ.IsTotal → ∀ t : F.Duration, TruthAt M τ t φ :=
        fun h' => h (ValidIn.of_forall_total h')
      ```
- [x] Give it a docstring in the file's established idiom, cross-referencing the four per-class
      `of_not` lemmas as its instantiations (mirroring how `ValidIn.of_forall_total`'s docstring
      relates to `ValidOnFrames.of_forall_total`).

**Timing**: 0.25 hours

**Depends on**: none

**Verification Tier**: local

**Files to modify**:
- `FormalSystem/Semantics/Validity.lean` — insert one theorem plus docstring after `:504`

**Verification**:
- `lake build FormalSystem.Semantics.Validity` green (explicit target).
- `grep -n "ValidIn.of_not" FormalSystem/Semantics/Validity.lean` returns the new declaration.
- No change to any existing declaration in the file; `git diff --stat` shows insertion only.

---

### Phase 2: Add the indexed family and its binder adapters (additive only) [COMPLETED]

**Goal**: Introduce the four `FrameClass`-indexed definitions and the three `SatisfiableSet`
binder adapters into `Metalogic/SetConsequence.lean` **without touching any existing
declaration**, so the build stays green throughout.

**Context**: `SetConsequence.lean` (445 lines) already carries task 508's collapsed consequence
layer: `SetConsequenceOnFrames:91`, `SetSemanticConsequenceOn:98`, the four per-class
abbreviations at `:103/:107/:112/:117`, and the eight `.of_forall`/`.apply` adapters at
`:129-195`. The new definitions belong beside `SetSemanticConsequenceOn`; the new adapters belong
beside the eight existing ones, whose shape they mirror exactly.

`SatisfiableSet` must use `fc.Sat F` (`Semantics/FrameClassValidity.lean:112`) rather than an
inlined binder list — that is the whole point of the collapse and what makes the Dedekind row
free.

**Tasks**:
- [x] Transplant the four definitions from `probe_509.lean` Part A into `SetConsequence.lean`,
      placed after `SetSemanticConsequenceDedekindDense` (`:117`) and before the adapter block
      (`:128`): `SatisfiableSet`, `ModelExistence`, `Compact`, `StrongCompleteness`.
- [x] Write a docstring for each in the file's established idiom, stating explicitly for
      `Compact` and `StrongCompleteness` that the per-class names below are `rfl`-recoveries.
- [x] Transplant the three adapters from `probe_509c.lean` §C0 into the adapter block, after
      `SetSemanticConsequenceDedekindDense.apply` (`:188`): `SatisfiableSet.base_of_forall`,
      `SatisfiableSet.dense_of_forall`, `SatisfiableSet.discrete_of_forall`.
- [x] Add the Dedekind adapter `SatisfiableSet.dedekind_of_forall` from
      `probe_509b_negative_control.lean` §B6 (the §B6 block itself is one of the control file's
      *succeeding* fragments; take the code as written). Adding it here — rather than leaving it
      for the follow-on task — costs four lines and completes the adapter row.
- [x] Add, immediately below the four definitions, a `#check`-free comment block recording that
      `Compact .Base = CompactBase`, `Compact .Dense = CompactDense`,
      `Compact .Discrete = CompactDiscrete`, and the three `StrongCompleteness` counterparts, are
      all `rfl` — with the note that this is what task 507's `valid := ValidIn .Base` bought.

**Timing**: 1 hour

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: This phase is estimated at roughly 120 lines including docstrings, and at
**zero** modifications to existing declarations. Confirm at implementation time with
`git diff --stat FormalSystem/Metalogic/SetConsequence.lean` (expect insertions only, deletions
0) and by checking that `lake build` succeeds with no error anywhere else in the tree — a purely
additive phase cannot break a downstream module.

**Files to modify**:
- `FormalSystem/Metalogic/SetConsequence.lean` — insert four definitions after `:117` and four
  adapters after `:188`; no existing line changed

**Verification**:
- `lake build FormalSystem.Metalogic.SetConsequence` green (explicit target).
- Full `lake build` green — nothing downstream can have moved.
- Temporary scratch check (do not commit) confirming the six `rfl` claims compile, e.g. in a
  scratch file: `example : Compact FrameClass.Base = CompactBase := rfl` and its five siblings,
  exactly as in `probe_509.lean` Part B.
- `git diff --numstat` shows 0 deletions in `SetConsequence.lean`.

---

### Phase 3: Redefine the ten per-class names as instantiations, and repair both friction points [COMPLETED]

**Goal**: Turn the ten hand-written per-class definitions into instantiations of the Phase 2
family, and land — in the same commit — the six call-site repairs that the two changed binder
shapes require.

**Context**: The ten names and their current lines in `SetConsequence.lean`:

| Row | `.Base` | `.Dense` | `.Discrete` |
|---|---|---|---|
| `StrongCompleteness*` | `:310` | `:361` | `:415` |
| `Compact*` | `:319` | `:368` | `:441` |
| `Satisfiable*Set` | `:327` | `:376` | `:429` |
| `ModelExistence*` | `:342` | `:390` | *correctly absent — refuted* |

Eight are `rfl`-recoveries. Exactly two shift, and they shift the way task 507 already shifted
`valid` — an added frame-condition slot:

- `SatisfiableBaseSet` gains one `∃ _ : True` binder.
- `SatisfiableDiscreteSet` re-nests: `IsSuccArchDiscrete` (`Semantics/FrameProperty.lean:118`) is
  a plain `def` wrapping `∃ (_ : SuccOrder D) (_ : PredOrder D), _ ∧ _`, and the anonymous
  constructor does **not** unfold it, so today's flat 10-component tuples stop elaborating.

**Friction point 1 — `SatisfiableDiscreteSet`, four tuple sites.**
`probe_509b_negative_control.lean` §B1-B3 records these failing verbatim with Lean's exact errors.
`probe_509c.lean` §C1/§C1'/§C2 records the verified repairs. Two routes, both verified:

- *Nesting route*: insert exactly one nesting pair at each site.
- *Adapter route*: call `SatisfiableSet.discrete_of_forall` (added in Phase 2) so the sites keep
  reading in the pre-collapse binder shape.

**Take the adapter route** for the two introduction sites (`:197`, `:258`, `:288`) and the
nesting route for the `rintro` elimination at `:230`. This is the convention tasks 507 and 508
established — adapters absorb the added slot at introduction, `rintro` patterns re-nest — and it
keeps `DiscreteNonCompactness.lean`'s proof text closest to what it is today.

**Friction point 2 — `Compactness.lean:113`'s bare `inferInstance`.**
Against `Sat .Dense F`, instance search fails: `Sat .Dense F` unfolds to `TaskFrame.IsDense F`
(`FrameProperty.lean:71`), whose head symbol is not `DenselyOrdered`, so the instance is
invisible. This is the *same* invisibility already documented on
`SetSemanticConsequenceDense.of_forall` (`SetConsequence.lean:143`). Type-ascribe it, per
`probe_509c.lean` §C3. `choose` and the `haveI : ∀ i, DenselyOrdered …` step both still work
unchanged (`probe_509c.lean` §C4).

**Tasks**:
- [x] In `SetConsequence.lean`, replace the six `rfl`-recoverable definitions with
      instantiations: `StrongCompletenessBase/Dense/Discrete := StrongCompleteness FrameClass.X`,
      `CompactBase/Dense/Discrete := Compact FrameClass.X`. Statements are unchanged on the nose.
- [x] Replace `ModelExistenceBase:342` and `ModelExistenceDense:390` with
      `ModelExistence FrameClass.Base` / `ModelExistence FrameClass.Dense`.
- [x] Replace `SatisfiableBaseSet:327`, `SatisfiableDenseSet:376`, `SatisfiableDiscreteSet:429`
      with `SatisfiableSet FrameClass.X`. Preserve each docstring's mathematical content; add one
      sentence to the Base and Discrete docstrings recording the absorbed binder slot and naming
      the adapter that restores the old shape.
- [x] `Compactness.lean:85` — add `trivial` in second position of the `refine ⟨frame, model,
      hist, …⟩` tuple, for the `Sat .Base` slot. The rest of the ultraproduct proof is verbatim
      (`probe_509b_negative_control.lean` §B4 compiles it clean).
- [x] `Compactness.lean:113` — replace bare `inferInstance` with the ascribed form from
      `probe_509c.lean` §C3:
      ```lean
          (inferInstance : DenselyOrdered
            (uShiftSet (idxUF Γ) (fun i => ShiftSet.ofModel (F i) (M i))).frame.Duration),
      ```
      and extend the `modelExistenceDense` docstring (`:100-106`) to record *why* the ascription
      is needed, cross-referencing the `SetSemanticConsequenceDense.of_forall` precedent.
- [x] `DiscreteNonCompactness.lean:197` (inside `archWitness_finitely_satisfiable:194`) — route
      the `refine ⟨FrameOver.natFrame (D := ℤ), inferInstance ×4, zModel, …⟩` through
      `SatisfiableSet.discrete_of_forall`, per `probe_509c.lean` §C1'.
- [x] `DiscreteNonCompactness.lean:230` (inside `archWitness_not_satisfiable:229`) — re-nest the
      `rintro`: `rintro ⟨F, ⟨_, _, _, _⟩, M, τ, hτ, t, h⟩`, per `probe_509c.lean` §C2.
- [x] `DiscreteNonCompactness.lean:258` and `:288` — the two `absurd ⟨…⟩` tuples inside
      `discrete_consequence_not_compact:250` and `strongCompletenessDiscrete_refuted:280`. Route
      through the adapter, or insert one nesting pair; both verified.
- [x] Do **not** touch `discrete_consequence_not_compact`'s or
      `strongCompletenessDiscrete_refuted`'s *statements*. Their `CompactDiscrete` /
      `StrongCompletenessDiscrete` targets are defeq; only the internal tuples move.

**Timing**: 1.25 hours

**Depends on**: 2

**Verification Tier**: full

**Commit Mode**: atomic-batch — the binder-shape change and its six call-site repairs cannot be
separated without leaving the tree red between commits.

**Scope Hypothesis**: Exactly six call sites need repair — `Compactness.lean:85`, `:113`, and
`DiscreteNonCompactness.lean:197`, `:230`, `:258`, `:288` — and no other site in the tree consumes
the two changed binder shapes.

**Scope Hypothesis — outcome: FALSIFIED. Four further sites found and repaired in this phase**,
per this hypothesis's own "repair it in this phase rather than deferring" instruction:

| Site | What broke | Repair |
|---|---|---|
| `DiscreteNonCompactness.lean:261`, `:291` | the two `obtain ⟨F, _, _, _, _, M, …⟩` *eliminations* of `archWitness_finitely_satisfiable`; the plan enumerated only introduction sites | one nesting pair each, `⟨F, ⟨_, _, _, _⟩, M, …⟩` |
| `DiscreteNonCompactness.lean:263` | `hvalid.apply` — `hc _ _ hcons` now yields `ValidIn .Discrete φ`, not `ValidDiscrete φ`, so dot notation resolves on `ValidIn`, which has no `.apply` | spelled out as `ValidDiscrete.apply hvalid F M τ hτ t`; the argument is accepted by defeq |
| `Compactness.lean:84` | `choose F M τ hτ t ht` — `SatisfiableBaseSet` gained the `∃ _ : True` slot, so `choose` must bind one more component | `choose F _hF M τ hτ t ht` |

Also recorded: this phase's heading and the plan's prose say **ten** per-class names, but the
phase's own table enumerates **eleven** (3 `StrongCompleteness*` + 3 `Compact*` + 3
`Satisfiable*Set` + 2 `ModelExistence*`). All eleven were redefined; "ten" is an arithmetic slip
in the plan, not a descoping. Confirm before editing with
`grep -rn "SatisfiableBaseSet\|SatisfiableDenseSet\|SatisfiableDiscreteSet" --include=*.lean
FormalSystem/ Tests/` (expected: `SetConsequence.lean` definitions, `DiscreteNonCompactness.lean`
uses, `Compactness.lean` uses, one prose mention at `Semantics/Ultraproduct/Carrier.lean:15`, and
**nothing in `Tests/`**). If the grep surfaces a seventh site, repair it in this phase rather
than deferring.

**Files to modify**:
- `FormalSystem/Metalogic/SetConsequence.lean` — ten definitions become instantiations
- `FormalSystem/Metalogic/Compactness.lean` — `:85` gains `trivial`; `:113` ascribed; docstring
  at `:100-106` extended
- `FormalSystem/Metalogic/DiscreteNonCompactness.lean` — four tuple sites reshaped

**Verification**:
- Full `lake build` green with explicit targets. **Do not** invoke
  `lake-build-guard.sh build --timeout 1800 --` with an empty target list.
- `#print axioms` at `DiscreteNonCompactness.lean:295-300` and `Compactness.lean:159-164` still
  report exactly `[propext, Classical.choice, Quot.sound]` for all twelve audited names.
- `grep -n "inferInstance" FormalSystem/Metalogic/Compactness.lean
  FormalSystem/Metalogic/DiscreteNonCompactness.lean` — every surviving bare `inferInstance` is
  at a site that still elaborates (the build proves this; the grep is to make the reviewer look).
- `grep -rn "sorry" --include=*.lean FormalSystem/Metalogic/` returns nothing new.
- `probe_509b_negative_control.lean` is **untouched and still failing**. That is correct.

---

### Phase 4: Collapse the four theorems into two, and rewire the axiom-audit block [COMPLETED]

**Goal**: Replace the two duplicated reductions and the two duplicated bridges with one of each,
rewire their four call sites, and — critically — rewrite the `#print axioms` block that names
three of the four deleted theorems.

**Context**: The four theorems, re-verified:

| Theorem | Line | Note |
|---|---|---|
| `strongCompletenessBase_of_compact` | `StrongCompleteness.lean:347` | byte-identical four-line proof to... |
| `strongCompletenessDense_of_compact` | `:375` | ...this one |
| `compactBase_of_modelExistence` | `:414` | identical to the next apart from `valid.of_not` vs `ValidDense.of_not` and one witness-tuple component |
| `compactDense_of_modelExistenceDense` | `:462` | |

`derivable_foldr_imp_iff` (`:297`) is **already generic in `fc`**, so
`strongCompleteness_of_compact` is the existing proof with the class tag lifted to a variable.
`hcons F hF M τ hτ t` applies **directly** in `compact_of_modelExistence` — no `.apply` adapter —
because task 508 made `SetSemanticConsequenceOn fc` expose `fc.Sat F` as an explicit argument.
Each hand-written bridge needed a class-specific `.apply`; the collapsed one needs none.

**Grep says no external consumer needs the old names** (`Tests/` is clean, and the only Lean call
sites are `Compactness.lean:127,131,142,149`), so prefer outright replacement over retaining
one-line corollaries.

**Tasks**:
- [x] Replace `strongCompletenessBase_of_compact:347` and `strongCompletenessDense_of_compact:375`
      with the single `strongCompleteness_of_compact`, transplanted from `probe_509.lean` Part C.
      **Keep the `engine` parameter** — it came from task 493 and stays live by explicit
      instruction.
- [x] Replace `compactBase_of_modelExistence:414` and `compactDense_of_modelExistenceDense:462`
      with the single `compact_of_modelExistence`, transplanted from `probe_509.lean` Part D.
      Substitute `ValidIn.of_not` (Phase 1) for the probe's local `ValidIn_of_not`.
- [x] Merge the two theorems' docstrings into one each, preserving the mathematical content of
      the originals — including the note at the current `:459` about what the Dense reduction
      needs beyond its engine.
- [x] Rewire `Compactness.lean:127` and `:131`:
      `theorem compactBase : CompactBase := compact_of_modelExistence modelExistenceBase` and the
      `.Dense` counterpart. After Phase 3 these apply directly, with **no transport theorem** —
      `probe_509.lean`'s `modelExistenceBase'` exists only so the probe needed no tree edit and
      must **not** be transplanted.
- [x] Rewire `Compactness.lean:142` and `:149` to
      `strongCompleteness_of_compact compactBase completeness_base` and the `.Dense` counterpart.
- [x] **Rewrite `StrongCompleteness.lean:1047-1049`** — the three `#print axioms` directives on
      deleted names. Replace with `#print axioms strongCompleteness_of_compact` and
      `#print axioms compact_of_modelExistence`. *(This is Defect 1 above; skipping it is a hard
      build break, not a documentation nit.)*
- [x] Update the audit prose at `StrongCompleteness.lean:1005-1021`, which narrates
      "`strongCompletenessBase_of_compact` is audited alongside them" and
      "`compactBase_of_modelExistence` and `compactDense_of_modelExistenceDense` are audited on
      the same footing ... counted separately from the fourteen above". Three reductions become
      two; the counts and names both move.
- [x] Optionally add `strongCompletenessDiscrete_of_compact` (`probe_509.lean` Part E) — the
      Discrete reduction still applies; only its antecedent is unavailable *and refuted*. Include
      it only if it earns a docstring explaining that it is a live reduction with a dead
      antecedent; otherwise omit rather than leave it unexplained. *(deviation: skipped —
      omitted under this item's own "otherwise omit" clause. Nothing consumes it, and the
      Discrete status it would record is already stated in `strongCompleteness_of_compact`'s
      docstring, which names `.Discrete` as the class where the reduction is live but the
      antecedent refuted.)*

**Timing**: 1 hour

**Depends on**: 1, 3

**Verification Tier**: full

**Commit Mode**: *(deviation: altered — folded into Phase 3's `atomic-batch` and committed with
it as one unit.)* Phase 3's redefinition of `SatisfiableBaseSet` / `SatisfiableDenseSet` breaks
the bodies of the four theorems Phase 4 deletes: `compactBase_of_modelExistence`'s
`refine ⟨F, M, τ, hτ, t, ?_⟩` loses its slot count and `compactDense_of_modelExistenceDense`'s
bare `inferInstance` goes invisible for the reason recorded under friction point 2. Committing
Phase 3 alone green would have required throwaway repairs to two theorems deleted minutes later
— the same throwaway-transport pattern this plan forbids for `modelExistenceBase'`. Every task
in both phases was executed as written and in the planned order (redefinition first, then
theorem collapse); only the commit boundary moved.

**Scope Hypothesis**: Four Lean call sites (`Compactness.lean:127,131,142,149`) and three
`#print axioms` lines are the complete set of *compiled* consumers of the deleted names; the
remaining ~24 references are prose, handled in Phase 5. Confirm before deleting with
`grep -rn "strongCompletenessBase_of_compact\|strongCompletenessDense_of_compact\|
compactBase_of_modelExistence\|compactDense_of_modelExistenceDense" --include=*.lean FormalSystem/
Tests/` and classify each hit as code or comment. Any hit inside a `#print`, `#check`, `example`,
or term position is a compiled consumer and belongs in this phase, not Phase 5.

**Files to modify**:
- `FormalSystem/Metalogic/StrongCompleteness.lean` — four theorems become two; `:1047-1049`
  rewritten; audit prose at `:1005-1021` updated
- `FormalSystem/Metalogic/Compactness.lean` — four call sites rewired

**Verification**:
- Full `lake build` green with explicit targets.
- `#print axioms compactBase`, `compactDense`, `strongCompletenessBase`, `strongCompletenessDense`
  (`Compactness.lean:159-164`) all report exactly `[propext, Classical.choice, Quot.sound]`.
- The two new declarations `strongCompleteness_of_compact` and `compact_of_modelExistence` report
  the same profile — matching `probe_509.lean` Part F.
- `grep -rn "strongCompletenessBase_of_compact\|compactBase_of_modelExistence" --include=*.lean
  FormalSystem/` returns only prose hits, all of which Phase 5 will clear.
- No `sorryAx` anywhere in `FormalSystem/Metalogic/`.

---

### Phase 5: Documentation and docstring sweep [COMPLETED]

**Goal**: Clear every stale reference. This surface is **substantially larger than research §5
reported** (Defects 2 and 3); the inventory below is greped from the live tree and is the one to
work from.

**A. Prose naming the four deleted theorems — in-tree `.lean` docstrings** (25 sites):

| File | Lines |
|---|---|
| `FormalSystem/Metalogic.lean` | `:111`, `:158-159`, `:162-163` |
| `FormalSystem/Metalogic/StrongCompleteness.lean` | `:135`, `:137`, `:309`, `:333`, `:445`, `:459`, `:658`, `:741`, `:822`, `:1013`, `:1016` |
| `FormalSystem/Metalogic/Compactness.lean` | `:49`, `:51`, `:126`, `:130`, `:137` |
| `FormalSystem/Metalogic/SetConsequence.lean` | `:56-58`, `:291`, `:317`, `:336`, `:352`, `:385` |

Note `Metalogic.lean:158-175` and `SetConsequence.lean:56-58` both narrate "the two reductions"
and "the two model-existence bridges" — each becomes **one**, so the prose needs rewriting, not
just renaming.

**B. Documentation files naming the deleted theorems**:
- `docs/project-info/known-limitations.md:44-46`
- `docs/reference/API_REFERENCE.md:716`, `:736`, `:737`
- `docs/user-guide/architecture.md:831-832`

**C. Stale `SetConsequence.lean:NNN` line citations** — already stale *today* (they cite
`:306/:314/:335/:352/:359/:379`; live values are `:310/:319/:342/:361/:368/:390`), and this task
moves them again:
- `docs/user-guide/architecture.md:823-829` — **seven rows**, not the three research §5 listed
- `docs/reference/API_REFERENCE.md:704-706`, `:736`, `:738`
- `docs/project-info/known-limitations.md:37`

**D. Name-only references that survive unchanged** (record as checked, edit only if the
surrounding claim became false): `README.md:164`,
`docs/project-info/implementation-status.md`, `docs/development/MODULE_ORGANIZATION.md`,
`FormalSystem/Semantics/Ultraproduct/Carrier.lean:15` (names `SatisfiableBaseSet`, which still
exists — but its binder description may now be one slot short, so read it).

**E. Line counts in `FormalSystem/Metalogic/README.md:142-147`.** These will move. Note that
`:143` records `StrongCompleteness.lean` at 943 lines against a live 1,060 — **pre-existing**
staleness from task 508, not caused by this task, but correct it while the file is open.

**Tasks**:
- [x] Sweep group A: rewrite each `.lean` docstring reference; convert "the two reductions" /
      "the two bridges" narration to the singular.
- [x] Sweep group B: update the three documentation files.
- [x] Sweep group C: re-derive every `SetConsequence.lean:NNN` citation by grep **after** Phases
      2-4 have settled the file, then write the corrected values.
- [x] Read group D's four sites; edit only where a claim became false. Record which were checked
      and left alone.
- [x] Recompute and correct all `FormalSystem/Metalogic/README.md` line counts for the four files
      this task touched.
- [x] Add to `FormalSystem/Metalogic/SetConsequence.lean`'s module docstring a short note that
      the family is now `FrameClass`-indexed, and that the Dedekind row is available by
      instantiation but deliberately unstated pending the follow-on task.

**Timing**: 1 hour

**Depends on**: 3, 4

**Verification Tier**: interface

**Scope Hypothesis**: The inventory above claims 25 in-tree docstring sites, 8 documentation
sites naming deleted theorems, 11 stale-citation sites, and 4 name-only sites.

**Scope Hypothesis — outcome: CONFIRMED in kind, and the closing grep is clean.** Re-running the
two greps at implementation time reproduced the inventory's *shape* exactly: the four deleted
names survived only in `Metalogic.lean`, `StrongCompleteness.lean`, `Compactness.lean` and
`SetConsequence.lean` in-tree, and in `API_REFERENCE.md`, `architecture.md` and
`known-limitations.md` under `docs/`. All were rewritten. The closing grep
(`--include=*.lean --include=*.md`, excluding `specs/` and `.lake/`) now returns **zero** hits
outside `specs/`; every remaining occurrence is in a frozen task artifact or review, which this
phase correctly does not touch.

Group D outcome — all four sites read, **none edited**, because no claim became false:

| Site | Claim | Still true? |
|---|---|---|
| `README.md:164` | "this tree contains no `CompactDedekind` definition and no refuting theorem" | Yes — `.Dedekind` is deliberately left unstated |
| `docs/project-info/implementation-status.md:68-69` | `SetConsequence.lean` "states `CompactBase`/`CompactDense` and their siblings" | Yes — they are still stated, now as instantiations |
| `docs/development/MODULE_ORGANIZATION.md:294-295` | "`CompactBase` and `CompactDense` state the two compactness properties" | Yes |
| `FormalSystem/Semantics/Ultraproduct/Carrier.lean:15` | "`SatisfiableBaseSet` binds the duration carrier existentially per instance" | Yes — the frame-condition slot was added beside that binder, not in place of it |

Line-count corrections applied in `FormalSystem/Metalogic/README.md`: `StrongCompleteness.lean`
943 -> 1,002 (the 943 was pre-existing staleness from task 508, not caused here),
`SetConsequence.lean` 445 -> 568, `DiscreteNonCompactness.lean` 334 -> 331, `Compactness.lean`
166 -> 179, root `Metalogic.lean` 226 -> 227. Confirm at
implementation time by re-running the two greps that produced it —
`grep -rn "strongCompletenessBase_of_compact\|strongCompletenessDense_of_compact\|
compactBase_of_modelExistence\|compactDense_of_modelExistenceDense" --include=*.lean --include=*.md
. | grep -v "^./specs/" | grep -v "^./.lake/"` and
`grep -rn "SetConsequence.lean:[0-9]" docs/ README.md FormalSystem/` — and reconcile any
difference before starting. Do **not** edit anything under `specs/` (task artifacts and reviews
are historical records and are correctly frozen).

**Files to modify**:
- `FormalSystem/Metalogic.lean`, `FormalSystem/Metalogic/StrongCompleteness.lean`,
  `FormalSystem/Metalogic/Compactness.lean`, `FormalSystem/Metalogic/SetConsequence.lean`,
  `FormalSystem/Metalogic/README.md`
- `docs/user-guide/architecture.md`, `docs/reference/API_REFERENCE.md`,
  `docs/project-info/known-limitations.md`
- `FormalSystem/Semantics/Ultraproduct/Carrier.lean` (only if its `SatisfiableBaseSet` description
  became inaccurate)

**Verification**:
- The group-A/B grep returns **zero hits outside `specs/`**.
- Every remaining `SetConsequence.lean:NNN` citation matches the live file, spot-checked by
  `sed -n 'NNNp'`.
- `scripts/readme-lint.sh` shows no *new* failure beyond the recorded
  `Semantics/Ultraproduct/README.md` baseline.
- `lake build` still green (docstring edits can break elaboration).

---

### Phase 6: Tree-wide acceptance [NOT STARTED]

**Goal**: Prove the three acceptance criteria — sorry-free, `lake build` green, every
currently-provable result still provable with an **unchanged axiom profile** — and record the
Dedekind handoff.

**Tasks**:
- [ ] Full `lake build` from clean, with **explicit targets**. Record the job count. A dropped
      job count or an implausibly fast green means re-run, not success.
- [ ] `grep -rn "sorry" --include=*.lean FormalSystem/` — no new occurrence versus baseline.
- [ ] Axiom audit: confirm every one of the following reports exactly
      `[propext, Classical.choice, Quot.sound]`, matching the C14 baseline and `probe_509.lean`
      Part F: `compactBase`, `compactDense`, `strongCompletenessBase`, `strongCompletenessDense`,
      `modelExistenceBase`, `modelExistenceDense`, `compact_of_modelExistence`,
      `strongCompleteness_of_compact`, plus the six audited names in
      `DiscreteNonCompactness.lean:295-300`.
- [ ] `scripts/check-module-invariants.sh` — compare against baseline. C6's four unmanifested
      unreachable modules are the **recorded pre-existing exclusion**. A **C14 or C15 regression
      is this task's defect** and must be fixed here, not excluded.
- [ ] `scripts/readme-lint.sh` — compare against baseline. The missing
      `FormalSystem/Semantics/Ultraproduct/README.md` is the recorded pre-existing exclusion.
- [ ] Confirm `probe_509b_negative_control.lean` is untouched. It is expected to fail; that is its
      purpose.
- [ ] Write the summary, including the downstream handoff block below verbatim.

**The Dedekind handoff (record in the summary).** The follow-on task's **Part 1 is four
`abbrev`s and two one-line theorems**, not a fourth hand copy of a ten-declaration group. All six
are **already compiled** in `probe_509.lean` Part E:

```lean
abbrev SatisfiableDedekindDenseSet : Set Formula → Prop := SatisfiableSet FrameClass.Dedekind
abbrev ModelExistenceDedekindDense : Prop := ModelExistence FrameClass.Dedekind
abbrev CompactDedekindDense        : Prop := Compact FrameClass.Dedekind
abbrev StrongCompletenessDedekindDense : Prop := StrongCompleteness FrameClass.Dedekind

theorem compactDedekindDense_of_modelExistence (h : ModelExistenceDedekindDense) :
    CompactDedekindDense := compact_of_modelExistence h

theorem strongCompletenessDedekindDense_of_compact (hc : CompactDedekindDense) :
    StrongCompletenessDedekindDense :=
  strongCompleteness_of_compact hc (fun ψ hψ => completeness_dedekind ψ hψ)
```

The engine is already available and already of exactly the right shape: `completeness_dedekind`
(`StrongCompleteness.lean:624`), since `ValidDedekindDense = ValidIn .Dedekind` definitionally.
Its consequence-relation counterpart `SetSemanticConsequenceDedekindDense` **already exists**
(`SetConsequence.lean:117`, with `.of_forall`/`.apply` at `:179`/`:188`) — task 508 landed it.
Dedekind is absent only from the compactness / satisfiability / model-existence /
strong-completeness rows.

**Why the follow-on's Part 2 stays genuinely hard.** The `.Dedekind` satisfiability slot is
`IsDedekind F = IsDense F ∧ IsComplete F` (`Semantics/FrameProperty.lean:172`) — an `And`, with no
successor structure at all. The `Order.succ^[n]` machinery that `archWitness_not_satisfiable`
(`DiscreteNonCompactness.lean:229`) turns on has nothing to act on, so `archWitness` **cannot be
reused** and a genuinely new non-compactness witness is required. The Dedekind adapter's binder
shape is `⟨F, ⟨inst, hlub⟩, M, τ, hτ, t, h⟩`, compiled in `probe_509b_negative_control.lean` §B6.

**Timing**: 0.75 hours

**Depends on**: 5

**Verification Tier**: full

**Files to modify**:
- `specs/509_parameterize_compactness_and_strong_completeness_family/summaries/01_frameclass-indexed-compactness-family-summary.md` (new)

**Verification**:
- All three acceptance criteria demonstrated with recorded command output, not asserted.
- The two pre-existing gate failures reproduce identically to their pre-change form.

---

## Testing & Validation

- [ ] `lake build` green with explicit targets, from clean, job count recorded.
- [ ] Zero `sorry` / `sorryAx` introduced anywhere under `FormalSystem/`.
- [ ] All fourteen audited declarations report exactly `[propext, Classical.choice, Quot.sound]`.
- [ ] The six `rfl` recoveries verified (`Compact`/`StrongCompleteness` at `.Base`/`.Dense`/
      `.Discrete`), plus `SatisfiableSet .Dense = SatisfiableDenseSet` and
      `ModelExistence .Dense = ModelExistenceDense`.
- [ ] The two non-defeq recoveries (`SatisfiableBaseSet`, `SatisfiableDiscreteSet`) verified
      propositionally equivalent, per `probe_509.lean` Part B.
- [ ] `discrete_consequence_not_compact` and `strongCompletenessDiscrete_refuted` still prove,
      with statements unchanged.
- [ ] `check-module-invariants.sh` and `readme-lint.sh` differ from baseline in no respect.
- [ ] Zero stale references outside `specs/`.

## Artifacts & Outputs

- Four `FrameClass`-indexed definitions and four binder adapters in
  `FormalSystem/Metalogic/SetConsequence.lean`.
- `ValidIn.of_not` in `FormalSystem/Semantics/Validity.lean` — the only edit outside
  `FormalSystem/Metalogic/`.
- `strongCompleteness_of_compact` and `compact_of_modelExistence` in
  `FormalSystem/Metalogic/StrongCompleteness.lean`, replacing four theorems.
- Ten per-class names preserved as instantiations, statements unchanged.
- Six repaired call sites across `Compactness.lean` and `DiscreteNonCompactness.lean`.
- An updated documentation surface across five `FormalSystem/` files and three `docs/` files.
- A summary carrying the Dedekind handoff block.

## Rollback/Contingency

Every phase is a self-contained commit ending at a green build, so `git revert` of any single
commit restores a working tree — with one exception: Phase 3 is `atomic-batch` and must be
reverted whole.

If Phase 3's binder-shape change proves more invasive than the six enumerated sites, the fallback
is to keep `SatisfiableBaseSet` and `SatisfiableDiscreteSet` as **standalone definitions** with
their current binder lists, plus propositional-equivalence lemmas to `SatisfiableSet .Base` /
`.Discrete` (both compiled in `probe_509.lean` Part B). That sacrifices two of the ten
instantiations while preserving the whole rest of the collapse, including both collapsed theorems
and the entire Dedekind handoff. It is a genuine partial win, not a failure state.

If the axiom profile shifts anywhere, stop and bisect against `probe_509.lean` Part F rather than
proceeding — the probe establishes that the target text is clean, so a shift means the transplant
diverged from the probe.
