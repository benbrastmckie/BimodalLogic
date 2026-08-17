# Implementation Plan: Semantic FMP over ℤ-Time (finite WorldState)

- **Task**: 417 - `semantic_fmp_finite_worldstate_over_z`
- **Status**: [IMPLEMENTING]
- **Effort**: 20 hours
- **Dependencies**: 414 (totality semantics — landed), 420 (four-axiom `TaskFrame` — landed), 438 (paper reconciliation — landed)
- **Research Inputs**: `specs/417_semantic_fmp_finite_worldstate_over_z/reports/02_semantic-fmp-rescoped-z-time.md` (authoritative for the ℤ-time spine; its Finding 2 `spherical_of_finite` transcription is **retracted**, see Research Integration); `specs/440_finite_frame_discharge_of_spherical_and_limit/reports/01_finite-spherical-limit-discharge.md` (cross-task; authoritative for everything Phase 2 touches); `reports/01_semantic-fmp-finite-worldstate.md` (superseded, retained as history)
- **Artifacts**: plans/03_semantic-fmp-z-time.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Deliver a `TruthAt`-connected finite model property for the **ℤ-time** discrete case, plus a
decidable model-checking presentation for finite-`W`-over-ℤ frames. The spine is a **ℤ-frame
normal form**: over `D = ℤ` every `TaskFrame` is determined by its one-step relation, `H_F` is
exactly the set of bi-infinite step-paths, and time-homogeneity makes the `□` clause a model
constant. The finite frame itself already exists (`FiniteFilteredTaskFrame ℤ φ`) and already
carries all four axioms — the truth lemma is the whole remaining mathematical job, and its
`untl`/`snce` eventuality-fulfilment core is isolated in a dedicated phase with a `[BLOCKED]`
escalation route rather than a `sorry` deferral.

**Definition of done**: the semantic FMP theorem over ℤ-time is machine-checked; `IntPresentation.check`
has a proved `= true ↔ TruthAt …` correctness bridge; the repository's live-`sorry` count is
still exactly 1 (`Metalogic/WeakCanonical/Transfer.lean`, invariant C3); `lake build` is green.

### Research Integration

The plan is written against report `02_semantic-fmp-rescoped-z-time.md` and adopts all six of its
Decisions. Two of its results are machine-checked and are transcribed rather than re-derived:
`iter`/`iter_add` (Phase 3) and the Seriality-independence counterexample (which fixes Seriality as
a genuine per-construction obligation, Phase 5). Its stale-name corrections are binding: use
`TaskFrame.limit_of_succOrder` (never `limit_nullity_of_succOrder`, which does not exist), and do
not attempt to reuse or repair `validity_decidable`, which has been deleted with a retirement note.

**Newly integrated (this revision)**:
`specs/440_finite_frame_discharge_of_spherical_and_limit/reports/01_finite-spherical-limit-discharge.md`.
Task 440's research pass examined the same Lean declarations this plan's Phase 2 targets and found
the previous plan version's Phase 2 defective in three independent ways. All three are repaired in
Phase 2 below, each with an inline record so the defect is not silently re-introduced by a later
reader:

1. **The transcribed proof does not compile.** Report `02_…`'s Finding 2 presented a
   `Set.Finite.exists_minimal`-based proof of `spherical_of_finite` as "machine-checked green,
   zero diagnostics, first attempt". **That claim is false.** `Set.Finite.exists_minimal` does not
   exist in this repository's pinned Mathlib (v4.33.0-rc1, resolved commit `79d0395a`), and neither
   does `Set.Finite.exists_minimal_wrt`. Finding 2's snippet is hereby **retracted as a preserved
   asset**; it must not be carried forward. Task 440 machine-checked a working replacement built on
   `exists_minimal_of_wellFoundedLT`, which is what Phase 2 now transcribes.
2. **The planned `spherical_of_subsingleton` consolidation is an axiom regression.** Dropped
   entirely; see Phase 2's Correction Record 2.
3. **The planned `Classical.choice`-freeness acceptance criterion is unsatisfiable.** Replaced with
   the two criteria task 440 established are both assertable and true; see Phase 2's Correction
   Record 3.

Task 440 additionally confirmed, against the live tree, that **task 420's frame-axiom-field
refactor has fully landed**: `TaskFrame` now carries `serial`, `limit`, `spherical`, `comp` (with
`interpolates` projected) *and* `nonempty` as structure fields, and `PartialHistory.extension`,
`.occurrence`, `.step`, `.hF_nonempty`, and `.isTotal_of_isMax` take **zero** axiom hypotheses.
This plan was already written against that post-420 world — Phase 5's seven-field discharge list,
Phase 7's use of hypothesis-free `PartialHistory.occurrence`, and Phase 7's "the finite frame
already carries all four axioms" premise are all confirmed correct, not merely assumed. No phase
required correction on this basis.

### Prior Plan Reference

`plans/02_semantic-fmp-z-time.md`. This revision is a **targeted Phase 2 repair**, not a re-plan.
The 13-phase structure, the six dependency waves, the ℤ-time target framing, Phase 9's binding
escalation contract, Phase 10's Discrete-class grep gate, and Phase 12's prohibition on reviving
`validity_decidable` are all carried forward unchanged. Outside Phase 2, only two consistency
edits were made — both in text that *cites* `spherical_of_finite` (Phase 5's field-discharge
bullet and the Artifacts & Outputs file list) — and neither re-scopes its phase.

### Roadmap Alignment

`specs/ROADMAP.md`'s `paper-refactor` cluster orders the work **420 → 414 → {415, 417} → 427**, and
records 417 as "semantic FMP, finite `WorldState` over `D = ℤ`, restated against the refactored
`TruthAt`, plus decidable model checking there" — which is exactly this plan's target, including the
ℤ-time (not Discrete-class) restriction. Both of 417's roadmap dependencies (420 and 414) have since
landed, so 417 is unblocked. The roadmap's **drift warning** for this cluster ("the paper's
definitions have moved through five waves in three days, twice *during* an in-flight dispatch";
treat a pinned SHA as a baseline to check, never a guarantee) is honoured by this plan's per-phase
`scripts/check-paper-definitions.sh` gate.

## Goals & Non-Goals

**Goals**:
- Establish a `TruthAt`-connected finite model property over **ℤ-time**: every formula satisfiable
  over ℤ-time is satisfiable in a model with finite `WorldState` over `D = ℤ`.
- Land the ℤ-frame normal form as reusable library content: `iter`/`iter_add`,
  `TaskFrame.step`/`taskRel_eq_iter` (decomposition), `TaskFrame.ofStep` (synthesis),
  `mem_HF_iff_adjacent`, and `box_const`.
- Land `TaskFrame.spherical_of_finite`, together with its axiom-free constructive core
  `sInter_nonempty_of_directed_of_minimal`, as general library lemmas (independently valuable to
  the sibling finite-carrier tasks).
- Deliver a computational presentation `IntPresentation` with a `Bool`-valued `check` and a proved
  `check … = true ↔ TruthAt …` correctness bridge, discharging part of the open obligation named
  in the `validity_decidable` retirement note.
- Keep the repository at exactly one live `sorry`.

**Non-Goals**:
- **No edits under `/home/benjamin/Philosophy/Papers/`.** The paper is read-only ground truth.
- No claim of decidability for TM or any of its variants. `cor:tm-decidability` states decidability
  is open; this work is a step toward it, not a proof of it.
- No FMP for the dense or complete frame classes, and no non-Archimedean carriers such as
  `ℤ ×_lex ℤ`.
- No deletion or rewrite of the existing syntactic closure-MCS FMP theorems in `FMP/`; this work
  adds the truth-connected layer above them.
- No revival of `validity_decidable` or `validity_has_decision_procedure`.
- No `sorry` anywhere, including as a temporary scaffold that a later phase would remove.
- **No consolidation of the existing `Spherical` class helpers.** `spherical_of_subsingleton`,
  `spherical_of_permissive`, and `spherical_of_eq` keep their current proof bodies and their
  current axiom profiles. `spherical_of_finite` is an *additional* route for relations of arbitrary
  shape, never a replacement. See Phase 2, Correction Record 2.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `untl`/`snce` eventuality fulfilment resists (six Boneyard precedents with sorries) | H | H | Isolated in Phase 9 with its own risk budget; pigeonhole/lasso machinery pre-landed in Phase 8 so Phase 9 is proof-assembly not tool-building; strategy stated up front; `[BLOCKED]` escalation for user review, **never** a `sorry` |
| Refuted Discrete-class target propagates back into the work | H | M | Target restated as ℤ-time in Overview, Goals, and every phase that names the theorem; Phase 10 verification includes a grep that no new declaration or docstring asserts the Discrete-class form |
| A dispatch trusts report `02_…`'s retracted `Set.Finite.exists_minimal` snippet and burns cycles debugging | H | M | Phase 2 Correction Record 1 names the non-existent lemma explicitly and carries the verified replacement proof inline, so no dispatch needs to consult the retracted snippet |
| A dispatch chases the impossible `Classical.choice`-free proof | H | M | Phase 2 Correction Record 3 states the WLEM impossibility result inline with its machine-checked derivation; the acceptance criterion asserts the *achievable* facts (axiom-free core, no Zorn) instead |
| Re-deriving an existing `Spherical` class helper regresses its axiom profile | M | M | Explicit Non-Goal above; Phase 2 verification carries a `spherical_of_subsingleton` = `[propext]` regression tripwire |
| `cor:spherical-finite` is untracked and could drift | M | M | Phase 1 tracks it before any phase quotes it; `scripts/check-paper-definitions.sh` re-run at every phase boundary |
| Task 440 also proposes tracking `cor:spherical-finite` in the record, and also edits `TaskFrame.lean` | M | M | Both edits are additive and mergeable; Phase 1 and Phase 2 each re-read the target file before writing and skip an anchor/declaration that is already present rather than duplicating it |
| Adding `Mathlib.Order.Minimal` + `Mathlib.Data.Fintype.Powerset` widens a low-level module's imports | L | M | `Mathlib.Data.Fintype.Powerset` is already used elsewhere in the tree (`FMP/FiniteModel.lean` cites `Set.instFinite`); Phase 2 keeps its `interface` tier precisely so the enumerated direct dependents of `TaskFrame.lean` are rebuilt after the import change |
| Transfer from abstract succ-Archimedean `D` to concrete `ℤ` is not in the tree | M | M | Mathlib supplies `LinearOrderedAddCommGroup.int_orderAddMonoidIso_of_isLeast_pos` and `orderIsoIntOfLinearSuccPredArch`; binder fit is verified early, in Phase 3, before anything depends on it |
| `Finite` vs `Fintype` mismatch blocks the checker late | M | M | `IntPresentation` carries `Fin card` by construction (Phase 11), sequenced after the normal form lands; `FiniteTaskFrame.finite_world : Finite` is never used to drive `decide` |
| Live `sorry` count regresses from 1 | M | L | Verify with the repo's own regex via `scripts/check-module-invariants.sh`, never naive grep (which over-counts doc-comment prose); checked at every phase close |
| Paper drifts again mid-task (this neighborhood moved three times in four days) | M | M | Re-run `scripts/check-paper-definitions.sh` at every phase boundary; a case-(b)-or-worse result pauses the phase and re-quotes before proceeding |
| Adapting `regionFrame` is attempted as a shortcut | M | L | `not_regionConstant_regionHistory` forecloses any lasso argument on that carrier; the plan builds fresh on the normal form and phases name this explicitly |

### Flagged, not acted on (deliberately out of scope)

Task 440's pass surfaced three items adjacent to this task's remit. They are recorded here rather
than folded into a phase, because acting on any of them would expand scope beyond the Phase 2
repair this revision exists to make:

1. **A `wlem_of_spherical` regression test.** Task 440 machine-checked the weak-excluded-middle
   derivation that proves the choice-free criterion unachievable, and recommends landing it under
   `Tests/` with its `[propext, Quot.sound]` profile pinned, as a permanent guard against a future
   agent "fixing" `spherical_of_finite`'s axiom profile. This plan records the impossibility
   *inline in Phase 2* and in the lemma's docstring; landing the test itself belongs to task 440,
   which owns that file.
2. **An explicit-argument variant `spherical_of_finite' (h : Finite W)`.** `FiniteTaskFrame`'s
   `finite_world` is a plain field, not an instance, so every direct use site needs
   `haveI := F.finite_world`. This plan is unaffected — Phase 5 reaches `spherical_of_finite`
   through `ofStep`'s own `[Finite W]` instance binder, and Phase 11 reaches it through `ofStep` —
   so the variant is not added here.
3. **Dropping `hF_nonempty`'s explicit `w` argument**, now that `F.nonempty` is a field. A real
   simplification 420 enabled but did not take; it is a signature change on a declaration this task
   only consumes, so it stays out.

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2, 3, 6 | -- |
| 2 | 4, 5 | 2, 3 |
| 3 | 7, 8, 11 | 4, 5, 6 |
| 4 | 9, 12 | 7, 8, 11 |
| 5 | 10 | 9 |
| 6 | 13 | 10, 12 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Track `cor:spherical-finite`, `lem:nesting`, `lem:nonempty` in the definitions record [COMPLETED]

**Goal**: This task quotes `cor:spherical-finite` verbatim as its transcription source while that
anchor is **untracked** by `specs/paper-definitions-of-record.md` — so the central citation is
unprotected by the drift lint. Close that gap before any phase relies on the quote.

**Tasks**:
- [x] Follow the record's own four-step extension protocol (its `## How to extend this record`
      section): resolve each anchor by `\label{}` name, never by line number.
- [x] For each of `cor:spherical-finite`, `lem:nesting`, `lem:nonempty`, run
      `bash scripts/check-paper-definitions.sh --resolve "ANCHOR|KIND|ENCLOSING|LOCATOR"` and record
      the printed text and sha256. *(deviation: altered — `cor:spherical-finite` was already
      resolved and tracked by task 440, so only the remaining two were resolved here; this is the
      two-anchor case the Scope Hypothesis anticipated.)*
- [x] Add one `### \`ANCHOR\`` entry per anchor quoting the resolved text verbatim (including any
      in-block `%%` editorial comments — they are literal source text and are hashed).
      `lem:nesting`'s hashed region additionally contains a single-`%` `% FIX:` authorial note,
      transcribed verbatim on the same grounds.
- [x] Add one row per anchor to the machine-readable manifest with the printed hash.
- [x] Update the record's "Known residual gap" prose: it currently names these three as untracked
      and notes that tracked `thm:extension` cross-references untracked `cor:spherical-finite`.
      That note is discharged by this phase.
- [ ] Re-pin the provenance table's file checksum and line count if the run reports the paper moved.
      *(deviation: skipped — the paper has moved, but per the record's own dirty-pin convention a
      re-pin is warranted only when a drift *correction* is absorbed, and this phase absorbs none.
      The unabsorbed drift is recorded instead, in the new coverage-extension section.)*
- [x] **Coordination check before writing**: task 440 proposes tracking the `cor:spherical-finite`
      third of this same gap (its report §6, resolved hash
      `76258a4c835d4fa0dde3fd037da52e706d0f20c9d7872ab523d3b81597b99b9d`). Re-read the record
      first; if that anchor is already present, leave it alone, add only the remaining two, and
      adjust the residual-gap prose to match what is actually there. Do not duplicate an entry or a
      manifest row. **Result**: already present at that exact hash; left untouched.

**Timing**: 1 hour

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: Exactly three anchors are added and the record's tracked count moves from 26
to 29. Confirm at implementation time by `grep -c` over the manifest rows before and after, and by
the record's own stated count in its coverage-extension prose. If task 440 landed
`cor:spherical-finite` first, the expected delta is two anchors, not three — confirm which case
holds by reading the record before editing. If the paper has since renamed or merged any of the
three, record what the paper actually says — never restate or "improve" it.

**Files to modify**:
- `specs/paper-definitions-of-record.md` - up to three new anchor entries, matching manifest rows, residual-gap prose discharged, provenance re-pin if needed

**Verification**:
- `bash scripts/check-paper-definitions.sh` (no arguments) reports the quiet case-(a) pass.
  **NOT MET — pre-existing, recorded, not caused by this task.** The lint reports **case (c)** both
  before and after this phase: 19 recorded blocks drifted and two recorded anchors
  (`def:BL-model`, `cor:tm-decidability`) no longer resolve. This state predates the task; the
  before/after drift sets are identical, so this phase introduced none of it. **Crucially, no
  anchor this task transcribes is in the drifted set** — `cor:spherical-finite`, `def:frame`,
  `def:frame#Spherical`, `def:directed`, `def:task-relation`, `cor:occurrence`, and
  `def:frame-properties` all still hash clean, as do the two anchors added here. See the
  task-level blocker note under Phase 10 for `cor:tm-decidability`, the one dangling anchor a
  later phase of this plan was going to cite.
- The three anchors each appear in both the entry section and the manifest, exactly once each.
  **MET** — `grep -c` over the three anchor names returns 3 manifest rows; manifest row count
  moved 47 → 49 (two added here, `cor:spherical-finite` pre-landed).
- No file under `/home/benjamin/Philosophy/Papers/` is modified (`git -C /home/benjamin/Philosophy/Papers/PossibleWorlds status --porcelain` unchanged from its pre-phase state).
  **MET** — that tree's only dirty paths are its own `specs/**` session artifacts; no `.tex` file
  is modified.

---

### Phase 2: Land `TaskFrame.spherical_of_finite` and its axiom-free core [COMPLETED]

**Goal**: Transcribe `cor:spherical-finite` into `FormalSystem/Semantics/TaskFrame.lean` as a
general library lemma, decomposed into an **axiom-free constructive core** plus the **one classical
step** the argument genuinely needs. This phase is **additive only**: no existing declaration's
signature, proof body, or axiom profile changes.

This phase was repaired after task 440's pass machine-checked three defects in the previous plan
version. The three correction records below are **binding and load-bearing**: each names something a
future reader is likely to "helpfully" restore. Do not restore any of them.

#### Correction Record 1 — the previously planned proof does not compile

The previous plan version instructed landing `spherical_of_finite` "with the report's verified proof
(`Set.Finite.exists_minimal` plus directedness)". **`Set.Finite.exists_minimal` does not exist in
this repository's pinned Mathlib** (v4.33.0-rc1, resolved commit `79d0395a`), and neither does
`Set.Finite.exists_minimal_wrt` — verified by `lean_local_search` and by direct grep over
`.lake/packages/mathlib/Mathlib/`. Report `02_…`'s claim that this proof was "machine-checked green,
zero diagnostics, first attempt" is **false**; the snippet is retracted and must not be carried
forward. Against this tree it produces:

```
error: failed to synthesize instance of type class Finite ↑S
error: Invalid field `exists_minimal`: The environment does not contain `Finite.exists_minimal`
```

The replacement below was machine-checked green by task 440 via `lean_run_code`. Transcribe it; do
not re-derive the argument and do not substitute a different minimal-element lemma without
re-verifying it against this Mathlib first.

```lean
omit [IsOrderedAddMonoid D] in
theorem spherical_of_finite {W : Type} [Finite W] (R : W → D → W → Prop) :
    TaskFrame.Spherical R := by
  intro S hdir hmem
  obtain ⟨hne, hd⟩ := hdir
  obtain ⟨Sstar, hStarMem, hStarMin⟩ :=
    exists_minimal_of_wellFoundedLT (α := Set W) (fun s => s ∈ S) hne
  have hsub : ∀ T ∈ S, Sstar ⊆ T := by
    intro T hT
    obtain ⟨S', hS'mem, hS'sub⟩ := hd Sstar hStarMem T hT
    have h1 : S' ⊆ Sstar := fun x hx => (hS'sub hx).1
    have h2 : Sstar ⊆ S' := hStarMin hS'mem h1
    exact fun x hx => (hS'sub (h2 hx)).2
  obtain ⟨x, hx⟩ := (hmem Sstar hStarMem).2
  exact ⟨x, fun T hT => hsub T hT hx⟩
```

**Two new imports are required** in `TaskFrame.lean`, both confirmed necessary by removing each and
observing the failure:
- `Mathlib.Order.Minimal` — supplies `exists_minimal_of_wellFoundedLT`.
- `Mathlib.Data.Fintype.Powerset` — supplies `Set.instFinite`, without which `WellFoundedLT (Set W)`
  does not synthesize.

The proof consumes only *finiteness*, *directedness*, and *member nonemptiness*; the
`IsFiber R s ∨ IsSegment R s` disjunct is never used, matching the paper's own
`%% CHANGE (sigma-elim)` remark that the finite-`W` argument is indifferent to member kind.

#### Correction Record 2 — do NOT re-derive `spherical_of_subsingleton` through this lemma

The previous plan version instructed re-deriving `spherical_of_subsingleton`'s **proof body** through
the new `spherical_of_finite` (on the reasoning that `Subsingleton W → Finite W`). **That step is
dropped entirely, and must not be reinstated.** Measured on the live tree:

```
lean_verify FormalSystem.Semantics.TaskFrame.spherical_of_subsingleton
→ axioms: ["propext"]
```

`spherical_of_subsingleton` is currently choice-free. Routing it through `spherical_of_finite` —
whose profile is `[propext, Classical.choice, Quot.sound]` — would **regress it to
`Classical.choice`** and propagate that regression to the three `Unit`-carriered universal frames
that consume it (`trivialFrame`, `intTimeFrame`, `genericTimeFrame`). The same argument forbids
re-deriving `spherical_of_permissive` or `spherical_of_eq` at finite carriers.

Consequently the previous version's associated grep-and-update step for `spherical_of_subsingleton`
call sites is also removed: it existed only to support the re-derivation, and with the re-derivation
gone there are no call sites to update.

`spherical_of_finite` earns its place as an **additional** route, not a consolidation: every
existing helper constrains the *relation shape* (`spherical_of_subsingleton` needs
`Subsingleton W`; `spherical_of_permissive` needs `R w d u ↔ (d ≠ 0 ∨ w = u)`; `spherical_of_eq`
needs `R w d u ↔ w = u`; `multiFamGen_spherical` needs the deterministic-shift carrier). None of
them applies to an *arbitrary* relation on a finite carrier — which is exactly what this task's
Phase 5 `ofStep` and a Z3-produced countermodel both are. Since 420 made `spherical` a mandatory
`TaskFrame` field, that gap is the lemma's whole value.

#### Correction Record 3 — the choice-free acceptance criterion is UNSATISFIABLE

The previous plan version required `lean_verify TaskFrame.spherical_of_finite` to show no
`Classical.choice` dependency. **That criterion can never pass, and this is a proved result, not a
difficulty estimate.** Task 440 machine-checked a derivation of **weak excluded middle**
(`¬¬P ∨ ¬P`) from `Spherical R` at the carrier `Bool` over `D = Int`, using a relation
`R w d u := (d = 0 ∧ w = u) ∨ (d = 3)` whose fibers include `{true}`, `{false}`, and `univ`:

```
#print axioms wlem_of_spherical
→ 'wlem_of_spherical' depends on axioms: [propext, Quot.sound]
```

`Bool` is finite. So a `Classical.choice`-free `spherical_of_finite` would, composed with
`wlem_of_spherical`, prove `¬¬P ∨ ¬P` for every `P` from `[propext, Quot.sound]` alone — i.e. in
Lean's intuitionistic core, where WLEM is not derivable. Therefore no `Classical.choice`-free proof
of `spherical_of_finite` exists.

**The paper is not wrong.** Its "choice-free" claim is about **ZF vs ZFC**: the argument does not
need the axiom of choice, given classical logic. Lean's `Classical.choice` is a different object —
the *single* axiom from which Lean derives **both** excluded middle (via Diaconescu) and AC — so
`#print axioms` has no vocabulary in which to express the paper's distinction. This is a mismatch
between the paper's metatheory and Lean's axiom accounting, not a defect in either, and it is
recorded rather than papered over.

**Replacement criterion** (both halves verified achievable by task 440):

1. The isolated core lemma `sInter_nonempty_of_directed_of_minimal` is **axiom-free** — not even
   `propext`. This is the paper's actual mathematical content ("directedness upgrades minimal to
   least; least is nonempty and equals the intersection") and it is fully constructive.
2. `spherical_of_finite` carries **no Zorn dependency** — specifically, no dependence on
   `PartialHistory.exists_maximal_extension`. *That* is the corollary's actual point, and the
   contrast `thm:extension` (which does go through Zorn) is drawn against.

Do not restore the `Classical.choice`-absence assertion in any form.

**Tasks**:
- [x] Add the two imports named in Correction Record 1 to `FormalSystem/Semantics/TaskFrame.lean`.
- [x] Land the axiom-free core `sInter_nonempty_of_directed_of_minimal` beside the existing
      `sInter_nonempty_of_directed_of_univ_or_singleton`:
      ```lean
      theorem sInter_nonempty_of_directed_of_minimal {W : Type} {S : Set (Set W)}
          (hd : ∀ S₁ ∈ S, ∀ S₂ ∈ S, ∃ S' ∈ S, S' ⊆ S₁ ∩ S₂)
          (hne : ∀ s ∈ S, s.Nonempty)
          {Sstar : Set W} (hStarMem : Sstar ∈ S)
          (hStarMin : ∀ ⦃T⦄, T ∈ S → T ⊆ Sstar → Sstar ⊆ T) :
          (⋂₀ S).Nonempty
      ```
- [x] Land `theorem TaskFrame.spherical_of_finite {W : Type} [Finite W] (R : W → D → W → Prop) :
      TaskFrame.Spherical R` with the verified proof body quoted in Correction Record 1, composing
      the classical minimal-element step with the core lemma.
- [x] Place both beside the existing family (`spherical_of_subsingleton`, `spherical_of_permissive`,
      `spherical_of_eq`) — **additively**. Do not touch their proof bodies (Correction Record 2).
- [x] Docstring on `spherical_of_finite` must cite `cor:spherical-finite` via
      `specs/paper-definitions-of-record.md`, not by paper line number, and must record that the
      argument is indifferent to the kind of member (matching the paper's own
      `%% CHANGE (sigma-elim)` note).
- [x] Docstring must carry the **obstruction note** from Correction Record 3, in the lemma's own
      words: the paper's "choice-free" is ZF-vs-ZFC; Lean's `Classical.choice` supplies LEM as well
      as AC; the corollary is not intuitionistically provable (weak excluded middle follows from
      `Spherical` at a finite carrier); what *is* preserved, and what the corollary is actually
      for, is the absence of Zorn.
- [x] Docstring must carry one line stating that the existing class helpers must **not** be
      re-derived from this lemma, with the `spherical_of_subsingleton = [propext]` measurement as
      the reason (Correction Record 2). A future reader who reaches for the consolidation should
      find this line before writing the edit.
- [x] **Coordination check before writing**: task 440 targets these same two declarations in this
      same file. Re-read `TaskFrame.lean` first; if either is already present, do not duplicate it —
      verify its proof and docstring meet this phase's criteria and record that the declaration was
      pre-landed. **Result**: neither was present; both were landed fresh by this phase. (Task 440
      had landed only the `cor:spherical-finite` record entry, not the Lean declarations.)

**Measured results**:
- `sInter_nonempty_of_directed_of_minimal` — `lean_verify` reports `axioms: []`. Axiom-free, not
  even `propext`, exactly as Correction Record 3's replacement criterion 1 requires.
- `spherical_of_finite` — `lean_verify` reports `axioms: [propext, Classical.choice, Quot.sound]`
  and no other axiom. Criterion 2 (no Zorn) holds structurally as well as measurably:
  `PartialHistory.exists_maximal_extension` lives in `Semantics/Extension/Extension.lean`, which
  *imports* `TaskFrame.lean`, so it is not even in scope at this declaration.
- Regression tripwire — `spherical_of_subsingleton` still reports exactly `[propext]`.
- `git diff --stat` on `TaskFrame.lean`: **93 insertions, 0 deletions**. The additive-only Scope
  Hypothesis holds; no existing declaration's signature or proof body changed.

**Explicitly not in this phase** (each removed for a recorded reason, not an oversight):
- Re-deriving `spherical_of_subsingleton`'s proof body through `spherical_of_finite`
  (Correction Record 2).
- The grep-and-update sweep over `spherical_of_subsingleton` call sites that existed only to
  support that re-derivation (Correction Record 2).
- Any assertion that `spherical_of_finite` is free of `Classical.choice` (Correction Record 3).

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: interface

**Scope Hypothesis**: The edit is **additive only** — two new declarations (~12 and ~10 lines) plus
two import lines, with **zero** signature changes and **zero** proof-body rewrites of existing
declarations. Confirm at implementation time by `git diff` on `TaskFrame.lean` showing only
additions plus the two import lines, and by enumerating and building the direct dependents of
`TaskFrame.lean` (`grep -rln "import FormalSystem.Semantics.TaskFrame" --include=*.lean`) — the
import widening, not a signature change, is why this phase stays at the `interface` tier. If any
dependent's elaboration changes, the additive assumption is falsified and the phase escalates to a
`full` gate.

**Files to modify**:
- `FormalSystem/Semantics/TaskFrame.lean` - two new imports (`Mathlib.Order.Minimal`,
  `Mathlib.Data.Fintype.Powerset`); add `sInter_nonempty_of_directed_of_minimal` and
  `spherical_of_finite`. No existing declaration is edited.

**Verification**:
- Module builds with zero diagnostics; each enumerated direct dependent of `TaskFrame.lean` builds.
- `lean_verify FormalSystem.Semantics.TaskFrame.sInter_nonempty_of_directed_of_minimal` reports the
  lemma **does not depend on any axioms** — not even `propext`. Record the output in the commit
  message.
- `lean_verify FormalSystem.Semantics.TaskFrame.spherical_of_finite` reports exactly
  `[propext, Classical.choice, Quot.sound]` and **no other axiom**; confirm in particular no
  dependence on `PartialHistory.exists_maximal_extension` (the Zorn instance). Record the actual
  axiom list in the commit message.
- **Regression tripwire**: `lean_verify FormalSystem.Semantics.TaskFrame.spherical_of_subsingleton`
  still reports exactly `["propext"]`. Any change here means Correction Record 2 was violated.
- An `example` confirms the bundled-structure application elaborates
  (`haveI := F.finite_world; exact spherical_of_finite F.TaskRel` for `F : FiniteTaskFrame D`);
  `finite_world` is a plain field, not an instance, so the `haveI` is required at every use site.
- Live-`sorry` count still 1 via `scripts/check-module-invariants.sh`.

---

### Phase 3: ℤ normal form, decomposition direction [COMPLETED]

**Goal**: Establish that over `D = ℤ` an arbitrary `TaskFrame ℤ` is determined by its one-step
relation. This is the plan's spine and every later phase consumes it.

**Tasks**:
- [x] New module (proposed `FormalSystem/Semantics/IntNormalForm.lean`).
- [x] Transcribe the machine-checked arithmetic core verbatim: `iter (R : W → W → Prop) : ℕ → W → W → Prop`
      and `iter_add : iter R (m + n) w u ↔ ∃ v, iter R m w v ∧ iter R n v u`.
- [x] Define `TaskFrame.step (F : TaskFrame ℤ) : F.WorldState → F.WorldState → Prop :=
      fun w u => F.TaskRel w 1 u`.
- [x] Prove `taskRel_eq_iter`: for all `d : ℤ`, `F.TaskRel w d u ↔ (0 ≤ d → iter F.step d.natAbs w u)`
      and the negative-`d` case via the `converse` field. State it as a single clean
      characterization; the sign split is an implementation detail of the proof, not of the
      statement, if a uniform form is available.
- [x] Derivation chain to follow (all field-carried, no new axioms): `⇒₀ = Eq` is the
      `nullity_identity` field; `⇒ₙ = step^n` for `n ≥ 0` by induction from `Compositional` at
      `x = n, y = 1`; negative durations by the `converse` field.
- [x] Verify the Mathlib succ-Archimedean-to-ℤ binder fit early in this phase (report's Risks row):
      confirm `LinearOrderedAddCommGroup.int_orderAddMonoidIso_of_isLeast_pos` and
      `orderIsoIntOfLinearSuccPredArch` have binders compatible with `ValidDiscrete`'s
      `[SuccOrder] [PredOrder] [IsSuccArchimedean] [IsPredArchimedean] [Nontrivial]`. Record the
      finding in the module docstring even if the transfer itself is not used until Phase 10.

**Timing**: 2 hours

**Depends on**: none

**Verification Tier**: local

**Files to modify**:
- `FormalSystem/Semantics/IntNormalForm.lean` (new) - `iter`, `iter_add`, `TaskFrame.step`, `taskRel_eq_iter`
- import-aggregator module (confirm which at implementation time) — **confirmed**:
  `FormalSystem/Semantics.lean`

**Verification**:
- New module builds with zero diagnostics. **MET** (`lake build FormalSystem.Semantics.IntNormalForm`
  green; the only diagnostics on the build path are pre-existing `unusedSectionVars` /
  `overlappingInstances` linter warnings inside `TaskFrame.lean`, none in the new module).
- `iter_add` and `taskRel_eq_iter` each `lean_verify` clean. **MET** — `iter_add` reports
  `[propext, Quot.sound]`; `taskRel_eq_iter` reports `[propext, Classical.choice, Quot.sound]`.
  Neither introduces a new axiom beyond Lean's standard three.
- Binder-fit finding for the Mathlib ℤ transfer is recorded in the module docstring. **MET** — and
  the finding is a *negative* one worth flagging: `orderIsoIntOfLinearSuccPredArch` fits
  `ValidDiscrete`'s binder bundle verbatim but yields only an **order** iso, while
  `LinearOrderedAddCommGroup.int_orderAddMonoidIso_of_isLeast_pos` yields the **additive** iso a
  duration transfer actually needs and does *not* fit the bundle (`Archimedean D` fails to
  synthesize from `[IsSuccArchimedean D] [IsPredArchimedean D]`, and an `IsLeast {y | 0 < y} x`
  witness is additionally required). Both fits were machine-checked before the module was written.

**Additional note**: `Mathlib.Algebra.Order.Group.Int` had to be imported — without it
`IsOrderedAddMonoid ℤ` does not synthesize, so `TaskFrame ℤ` will not even elaborate. No module in
the tree had previously named `TaskFrame ℤ` outside a context that already pulled that instance in
transitively.

---

### Phase 4: `mem_HF_iff_adjacent` — `H_F` over ℤ is the bi-infinite step-paths [COMPLETED]

**Goal**: Characterize the total-history space of an arbitrary `TaskFrame ℤ` as the set of
`τ : ℤ → WorldState` with `step (τ n) (τ (n+1))` for all `n`. This is what makes both the truth
lemma and the model checker tractable.

**Tasks**:
- [x] Prove the forward direction: a total `WorldHistory` on ℤ satisfies the adjacency condition
      (instantiate `respects_task` at consecutive times).
- [x] Prove the converse: any adjacency-satisfying `τ : ℤ → WorldState` yields a total
      `WorldHistory`; the all-pairs `respects_task` obligation follows from `taskRel_eq_iter` plus
      `iter_add`, by induction on the gap.
- [x] State the result as `mem_HF_iff_adjacent` over `TaskFrame.HF`, in whichever of the two
      equivalent forms (predicate on histories vs. membership in `HF`) elaborates most cleanly;
      supply the other as a one-line corollary.
- [x] Do **not** route through `regionFrame`. `not_regionConstant_regionHistory` machine-checks that
      no history on that carrier repeats a state, foreclosing every lasso argument on it; this phase
      exists precisely so later phases have an obstruction-free carrier.

**Timing**: 2 hours

**Depends on**: 3

**Verification Tier**: local

**Files to modify**:
- `FormalSystem/Semantics/IntNormalForm.lean` - `mem_HF_iff_adjacent` and its corollary form

**Verification**:
- Module builds with zero diagnostics; both directions are theorems, not `sorry`. **MET.**
- A smoke `example` instantiates the characterization at an existing ℤ frame in the tree and closes.
  **MET** — two `example`s in the module's `Smoke` section, both over
  `TaskFrame.staticFrame W (D := ℤ)`: one shows the constant path is an `IsStepPath`, the second
  runs it through `mem_HF_iff_adjacent` to produce an actual member of `H_F`.

**Chosen form**: the membership form is primary (`(∃ τ : F.HF, τ.path = f) ↔ IsStepPath F f`), with
the predicate-on-histories form supplied as the corollary `isTotal_respects_iff_adjacent`
(`(∀ s t, TaskRel (f s) (t - s) (f t)) ↔ IsStepPath F f`). Supporting declarations landed with
them: `IsStepPath`, `TaskFrame.HF.path`, `TaskFrame.HFofStepPath` (the construction),
`TaskFrame.iter_of_isStepPath` (the induction on the gap), and
`TaskFrame.respects_of_isStepPath`. `mem_HF_iff_adjacent` verifies at
`[propext, Classical.choice, Quot.sound]`. `regionFrame` is not touched anywhere in the module.

---

### Phase 5: `TaskFrame.ofStep` synthesis + promote `customFrame` into the library [COMPLETED]

**Goal**: The converse of Phase 3 — build a `TaskFrame ℤ` from a bi-serial relation on a finite
nonempty carrier — and validate it against the paper's own two-state witness.

**Tasks**:
- [x] Define `TaskFrame.ofStep {W : Type} [Finite W] [Nonempty W] (R₁ : W → W → Prop)
      (fwd : ∀ w, ∃ u, R₁ w u) (bwd : ∀ w, ∃ v, R₁ v w) : TaskFrame ℤ`.
- [x] Field discharges, per the report's axiom-discharge table: `nonempty` from the instance;
      `nullity_identity` free (`iter R 0 = Eq`); `comp` free via `iter_add`; `converse` free by
      construction; `limit` via `TaskFrame.limit_of_succOrder` (**this is the live name** —
      `limit_nullity_of_succOrder` does not exist and must not be written); `spherical` via
      `spherical_of_finite` from Phase 2. `ofStep`'s relation is arbitrary in shape, so
      `spherical_of_finite` is the only applicable route here — and it costs
      `Classical.choice` (Phase 2, Correction Record 3). That cost is accepted for `ofStep`
      specifically; it is **not** a licence to re-route frames whose relation *does* fit a
      choice-free class helper. In particular the promoted `customFrame` below keeps
      `spherical_of_permissive`.
- [x] `serial` is the **one genuine obligation**: it is exactly bi-seriality of `R₁`, and it is
      **not** free over ℤ. The report machine-checks a counterexample (`R w d u := (d = 0)` on
      `W = Unit` satisfies `nullity_identity`, `Compositional`, `converse`, `Limit`, and `Spherical`
      but fails `Serial`, and finiteness does not rescue it). Take `fwd`/`bwd` as hypotheses; do not
      attempt to derive them.
- [x] Add a module-level note recording that Seriality is free *from Occurrence*, never *from ℤ*.
- [x] Promote `customFrame` (`Tests/BimodalTest/Semantics/TaskFrameTest.lean`, `WorldState := Bool`,
      `TaskRel := fun w d u => d ≠ 0 ∨ w = u`) into the library as the paper's canonical
      off-zero-universal two-state ℤ witness, with axiom discharges cited to the paper's
      `app:dense`/`app:deterministic` proof text via the definitions record. Keep its existing
      permissive-class discharges (including `spherical_of_permissive`, which is choice-free here
      and strictly better than `spherical_of_finite` for this relation shape).
- [x] Leave the test file's coverage intact: the test may re-express `customFrame` as the library
      declaration or as an `ofStep` instance, but the existing test assertions must still run.
- [x] The task description's rebase CAUTION is a **negative finding** and needs no action: no
      two-state universal-relation frame exists in the tree; all three universal frames
      (`trivialFrame`, `intTimeFrame`, `genericTimeFrame`) are `Unit`-carriered and get *Limit* free
      by `limit_of_subsingleton`. Do not search for or "repair" a nonexistent violating frame.

**Timing**: 2 hours

**Depends on**: 2, 3

**Verification Tier**: interface

**Scope Hypothesis**: Promotion touches exactly two files (one library module, one test module) and
no other call site references `customFrame`. Confirm with
`grep -rn "customFrame" --include=*.lean` before editing; if the count exceeds the two files, widen
the phase's enumerated dependent set and rebuild each.

**Files to modify**:
- `FormalSystem/Semantics/IntNormalForm.lean` - `TaskFrame.ofStep` and its seven field discharges
- library home for the promoted witness (confirm at implementation time; `TaskFrame.lean` or `Examples/TemporalStructures.lean`)
- `Tests/BimodalTest/Semantics/TaskFrameTest.lean` - re-point `customFrame` at the library declaration

**Verification**:
- `ofStep` builds with zero diagnostics and all seven fields discharged without `sorry`. **MET.**
  Supporting declarations: `ofStepRel` (the generated relation, defined as `taskRel_eq_iter`'s
  conclusion so the two directions agree definitionally), `ofStepRel_of_nonneg`,
  `ofStepRel_of_nonpos`, `exists_iter_fwd`, `exists_iter_bwd`, plus `ofStep_taskRel` and
  `ofStep_step` (which confirms `ofStep` recovers the relation it was given).
- The promoted witness elaborates and its four axiom discharges are cited to record anchors.
  **MET, with a corrected citation target — see the deviation note below.**
- The promoted witness's `spherical` discharge is still `spherical_of_permissive`, not
  `spherical_of_finite` (axiom-profile guard, Phase 2 Correction Record 2). **MET** —
  `intBoolFrame_spherical := TaskFrame.spherical_of_permissive intBoolFrame_rel_iff`, and its
  docstring records why substituting the finite route would be a pure axiom-profile regression.
- Test suite still passes; `TaskFrameTest.lean` assertions unchanged in meaning. **MET** —
  `lake build BimodalTest.Semantics.TaskFrameTest` green; `customFrame` is now a definitional
  alias for the library declaration, so every existing assertion (`Iff.rfl`, `Or.inl (by decide)`,
  `customFrame.nullity`) still elaborates unchanged.
- **Scope Hypothesis confirmed**: `grep -rln customFrame --include=*.lean` returns exactly the two
  predicted files.

**DEVIATION (citation target, docstring only)** — the task step said to cite the promoted witness's
axiom discharges "to the paper's `app:dense`/`app:deterministic` proof text via the definitions
record". Neither is a valid source for an axiom discharge:
- `app:dense` is the **density correspondence theorem** (`\Future\Future φ → \Future φ` iff the
  frame is `Dense`). It says nothing about any frame's four axioms.
- **`app:deterministic` does not exist.** There is no such `\label{}` in the paper. `Deterministic`
  is a clause inside `def:frame-properties`, a frame-*class* predicate, not an axiom source.
The discharges are therefore cited to `def:frame`'s four sub-anchors — `def:frame#Seriality`,
`def:frame#Compositionality`, `def:frame#Limit`, `def:frame#Spherical` — which is what every other
frame in the tree cites and what the axioms actually come from. The mis-citation and its reason are
recorded in `intBoolFrame`'s own docstring so a later reader does not "restore" it.

**Library home confirmed**: `FormalSystem/Examples/TemporalStructures.lean`, as `intBoolFrame`
(naming consistent with the neighbouring `intNatFrame`/`intTimeFrame`). `TaskFrame.lean` was
rejected as a home because every frame there is duration-class-generic, whereas this is a concrete
`Bool`-over-ℤ witness.

**Also landed**: `flipFrame`, the two-state cycle synthesized by `ofStep` from
`fun w u : Bool => w ≠ u`, kept as a named definition in the module's `WorkedInstances` section —
it is the smallest carrier on which a lasso argument has anything to bite on, so Phases 8–9 have a
concrete instance to test against.

---

### Phase 6: `box_const` — `□` is a model constant [COMPLETED]

**Goal**: Prove `TruthAt M τ t φ.box ↔ TruthAt M σ s φ.box` for all total `τ, σ` and all `t, s`.
This dissolves the round-1 assessment that the box clause was the hardest case: the set of total
histories is uncountable even for finite `W`, but the box **predicate** is constant on it.

**Tasks**:
- [x] Prove `box_const` from time-homogeneity of `TaskRel` plus `WorldHistory.isTotal_timeShift`:
      `TruthAt M τ t (box φ)` unfolds to `∀ σ, σ.IsTotal → TruthAt M σ t φ`, which is already
      `τ`-independent by the clause itself; the `t`-independence comes from substituting the
      `(t - s)`-shift of an arbitrary total `σ`.
- [x] Note in the docstring that the `τ`-independence is definitional (the clause does not mention
      `τ`) and only the `t`-independence needs the shift argument — do not over-engineer the proof.
- [x] State it for a general `D` if the shift lemma supports it; specialize to ℤ only if a general
      statement does not elaborate.
- [x] Place under `namespace Truth` in `FormalSystem/Semantics/Truth.lean` (additive; no existing
      signature changes).

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: local

**Files to modify**:
- `FormalSystem/Semantics/Truth.lean` - `Truth.box_const` (additive)

**Verification**:
- Module builds with zero diagnostics; no existing declaration in `Truth.lean` changes signature.
  **MET** — the edit is purely additive (a new `namespace Truth` block appended after
  `end TimeShift`).
- `lean_verify` on `box_const` is clean. **MET** — `[propext, Classical.choice, Quot.sound]`.

**Placement note**: `box_const` is under `namespace Truth` as specified, but in a *reopened* block
after `end TimeShift` rather than inside the original `Truth` block (lines 159–336). Its proof
consumes `TimeShift.time_shift_preserves_truth`, which is declared later in the file, so the
original block is not a legal home for it. Stated for general `D` — the shift lemma supports it, so
no ℤ specialization was needed. A one-line `box_time_const` corollary fixes the history and varies
only the time.

**Hypothesis note**: the two `IsTotal` hypotheses are stated as the plan specifies but are not
consumed — history-independence is definitional, since the box clause does not mention `τ` at all.
They are named `_hτ`/`_hσ` and the docstring records the fact rather than silently dropping them,
which would have changed the planned signature.

---

### Phase 7: Truth-lemma target statement + atom, `⊥`, `→`, and `□` cases [NOT STARTED]

**Goal**: State the truth lemma for `FiniteFilteredTaskFrame ℤ φ` and discharge the four
non-eventuality cases. The finite frame **already exists** and already carries all four axioms
(`FMP/FiniteModel.lean`, the only live `FiniteTaskFrame` in the library) — nothing new is
constructed here.

**Tasks**:
- [ ] New module (proposed `FormalSystem/Metalogic/Decidability/FMP/TruthLemma.lean`).
- [ ] State the truth lemma: for `ψ` in the closure of `φ`, `TruthAt M τ t ψ` on the filtered model
      iff `ψ ∈ (τ.states t _).carrier` (the exact filtered-world/MCS form to be pinned against
      `FMP/Filtration.lean`'s `FilteredWorld` and `ClosureMCSSetoid` at implementation time).
- [ ] Confirm the premise the plan rests on before proving anything: `FMP/` still contains **zero**
      occurrences of `TruthAt` (`grep -rn "TruthAt" FormalSystem/Metalogic/Decidability/FMP/`). If
      this has changed, stop and report — the gap analysis would be stale.
- [ ] Discharge `Formula.atom` (via `Truth.atom_iff_of_domain`), `Formula.bot` (via
      `Truth.bot_false`), and `Formula.imp` (via `Truth.imp_iff`) — these are routine.
- [ ] Discharge `Formula.box` using `box_const` (Phase 6) plus `PartialHistory.occurrence`
      (`Semantics/Extension/Extension.lean`, `cor:occurrence` in frame-intrinsic form: for any world
      state and time there is a total history through it). Since 420 landed, `occurrence` takes only
      `(F : TaskFrame D) (w) (x)` — **zero** axiom hypotheses — so no axiom binders need threading.
      `occurrence` is what supplies the witness history the box clause quantifies over;
      `hF_nonempty` (likewise hypothesis-free) is available if a bare nonemptiness witness suffices.
- [ ] Leave `Formula.untl` and `Formula.snce` as explicitly named open goals **structured as
      separate lemmas with full statements** so Phase 9 has a fixed target. They must be genuine
      unproven lemma *statements* that Phase 9 fills — **not** `sorry`-ed declarations. If the
      induction cannot be structured to defer them without a `sorry`, split the induction so the
      eventuality cases are hypotheses of the main lemma and Phase 9 discharges them.

**Timing**: 2 hours

**Depends on**: 4, 6

**Verification Tier**: local

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/FMP/TruthLemma.lean` (new)

**Verification**:
- Module builds with zero diagnostics and **zero `sorry`** — verified with
  `scripts/check-module-invariants.sh`, not naive grep.
- The `untl`/`snce` obligations appear as named hypotheses or named unproven lemma statements, and
  the phase closes green because nothing is asserted that is not proved.
- `bash scripts/check-paper-definitions.sh` still case-(a) at phase close.

---

### Phase 8: Pigeonhole/lasso machinery over finite `W` and ℤ [NOT STARTED]

**Goal**: Build the reusable periodicity toolkit that Phase 9 and Phase 12 both consume. Landing it
separately shrinks the highest-risk phase from tool-building-plus-proof to proof-assembly. **No
such machinery exists anywhere in the tree** — no `UltimatelyPeriodic`, `EventuallyPeriodic`, or
lasso detection — so this is new construction.

**Tasks**:
- [ ] New module (proposed `FormalSystem/Metalogic/Decidability/FMP/Periodicity.lean`).
- [ ] Prove the core pigeonhole: on a bi-infinite step-path in a finite carrier, any window of
      length exceeding `card W` repeats a state.
- [ ] Derive the bounded-witness-distance lemma: if a state satisfying a property is reachable along
      the path at all, it is reachable within a bound expressible in `card W`.
- [ ] Derive the segment-splice lemma: a repeated state licenses excising or inserting the loop
      between its two occurrences, yielding another adjacency-satisfying path
      (`mem_HF_iff_adjacent`, Phase 4).
- [ ] State everything against `mem_HF_iff_adjacent`'s adjacency form so it applies to any
      `TaskFrame ℤ` with finite `WorldState`, not only to the filtered frame.

**Timing**: 2 hours

**Depends on**: 4

**Verification Tier**: local

**Scope Hypothesis**: Three lemmas (pigeonhole, bounded witness distance, splice) suffice for both
consuming phases. This is a hypothesis: Phase 9 may reveal a fourth obligation. Confirm by having
Phase 9 report which lemmas it actually consumed; if Phase 9 needs machinery not present here, add
it to this module rather than inlining it into the eventuality proof.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/FMP/Periodicity.lean` (new)

**Verification**:
- Module builds with zero diagnostics and zero `sorry`.
- Each lemma has a standalone `example` exercising it on a concrete small frame.

---

### Phase 9: `untl`/`snce` eventuality fulfilment — HIGHEST-RISK PHASE [NOT STARTED]

**Goal**: Discharge the two eventuality cases of the truth lemma. **This is the single largest risk
in the task.** Six previous attempts at precisely this machinery are archived in `Boneyard` with
sorries: `ScheduleBasedBFMCS/RootScopedChain.lean` (3), `QuasimodelOracle/RoundRobinChain.lean` (3),
`QuasimodelOracle/OracleStep.lean` (7), `QuasimodelOracle/OracleCoherence.lean` (6),
`SorriedDeclExcisions/BundleUntilSinceStep.lean` (7),
`SorriedDeclExcisions/WeakTruthLemmaCluster.lean` (6).

**Strategy, stated up front (do not improvise a different one without recording why)**:
1. Work in the adjacency presentation from Phase 4, never on `regionFrame` — that carrier's
   `not_regionConstant_regionHistory` forecloses lassos by construction.
2. Fulfil an `untl φ ψ` obligation at a filtered world by exhibiting a **bounded** forward witness,
   using Phase 8's bounded-witness-distance lemma with the bound in `card (FilteredWorld φ)`.
3. Use Phase 8's splice lemma to convert a witness reachable along *some* path into a witness along
   *the* path, keeping adjacency.
4. `snce` is the time-reversed mirror; derive it through the `converse` field rather than
   duplicating the argument, if the symmetry is expressible.
5. **Note the constructor-argument-order convention**: this repository's `untl`/`snce` are
   event-first/guard-second (`Formula.untl φ ψ` = "`φ` holds at some future `s`, `ψ` throughout
   between"), which reads backwards from a naive guard-first reading. See
   `specs/decisions/untl-snce-argument-order.md`. Getting this backwards is a silent, expensive
   failure mode.

**Tasks**:
- [ ] Discharge `Formula.untl` in `TruthLemma.lean` using Phase 8's machinery.
- [ ] Discharge `Formula.snce`, preferably by reversal rather than duplication.
- [ ] Record in the phase's progress notes which Phase 8 lemmas were actually consumed and which
      were missing (feeds Phase 8's Scope Hypothesis confirmation).

**Timing**: 2 hours budgeted; this phase is permitted to consume its full budget without closing

**Depends on**: 7, 8

**Verification Tier**: full

**Escalation contract (binding)**:
- **No `sorry`, under any framing.** Not a scaffold, not a placeholder, not a "to be removed in the
  next phase" marker. The zero-debt decision is explicit in the research report and this phase is
  the one it exists for.
- If the argument resists within the phase's budget: set this phase's heading to `[BLOCKED]`, write
  a blocker record naming the precise goal state that resisted, the Phase 8 lemmas that were
  insufficient, and the specific Boneyard file whose failure mode it most resembles, and **stop**.
  Escalate for user review. Do not proceed to Phase 10.
- A `[BLOCKED]` outcome here blocks Phases 10 and 13. Phases 11 and 12 remain independently
  completable and should be reported as such.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/FMP/TruthLemma.lean` - `untl` and `snce` cases
- `FormalSystem/Metalogic/Decidability/FMP/Periodicity.lean` - only if a missing lemma must be added

**Verification**:
- Full repository gate set: `lake build` green.
- `scripts/check-module-invariants.sh` reports live-`sorry` count still exactly 1.
- The truth lemma is a complete theorem with no remaining hypotheses standing in for the
  eventuality cases.

---

### Phase 10: Assemble the semantic FMP over ℤ-time [NOT STARTED]

**Goal**: State and prove the deliverable: every formula satisfiable over **ℤ-time** is satisfiable
in a model with finite `WorldState` over `D = ℤ`.

**Tasks**:
- [ ] New module (proposed `FormalSystem/Metalogic/Decidability/FMP/SemanticFMP.lean`).
- [ ] State the theorem in Lean's existing vocabulary: `ValidDiscrete` / `satisfiable ℤ` /
      `FormulaSatisfiable` (`Semantics/Validity.lean`). Lean's `ValidDiscrete` already quantifies
      over `[SuccOrder] [PredOrder] [IsSuccArchimedean] [IsPredArchimedean] [Nontrivial]` — the
      successor-Archimedean class, i.e. ℤ-time by Hölder — so the correct target is already
      expressible without new definitions.
- [ ] Prove it by composing: the syntactic closure-MCS FMP already in `FMP/`, the truth lemma
      (Phase 9), and `FiniteFilteredTaskFrame ℤ`'s finiteness.
- [ ] Docstring must state the scope honestly and cite the record: the target is **ℤ-time**, not the
      paper's broader `def:frame-properties` Discrete class; the Discrete-class form is **false**
      (`CO` is refutable on `ℤ ×_lex ℤ` yet valid in every model over `D = ℤ`); and
      `cor:tm-decidability` states decidability is **open**, so this theorem is a step toward an
      open result and backs no decidability claim.
- [ ] Add a cross-reference note at the head of `FMP/FMP.lean` (or the `FMP/README.md`) pointing
      from the syntactic theorems to the new truth-connected layer.

**Timing**: 2 hours

**Depends on**: 9

**Verification Tier**: full

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/FMP/SemanticFMP.lean` (new)
- `FormalSystem/Metalogic/Decidability/FMP/FMP.lean` or `FMP/README.md` - cross-reference note

**Verification**:
- `lake build` green; the theorem is `sorry`-free.
- Grep gate: no new declaration name or docstring in this task's touched files asserts the
  Discrete-class form. Search for `Discrete` in the diff and confirm every occurrence either says
  ℤ-time or explicitly records the refutation.
- `bash scripts/check-paper-definitions.sh` case-(a) at phase close.

---

### Phase 11: `IntPresentation` and `toFiniteFrame` [NOT STARTED]

**Goal**: A computational presentation of a finite-`W`-over-ℤ frame. `FiniteTaskFrame.finite_world`
is `Finite`, which is non-constructive and yields no enumeration, so it **cannot** drive `decide` —
a `Fintype`/`DecidableEq` presentation is required and is what this phase supplies.

**Tasks**:
- [ ] New module (proposed `FormalSystem/Metalogic/Decidability/IntPresentation.lean`).
- [ ] Define the structure along the report's recommended shape:
      `card : ℕ`, `step : Fin card → Fin card → Bool`, `val : Atom → Fin card → Bool`,
      `fwd : ∀ w, ∃ u, step w u = true`, `bwd : ∀ w, ∃ v, step v w = true`.
- [ ] `IntPresentation.toFiniteFrame : IntPresentation → FiniteTaskFrame ℤ` built through
      `TaskFrame.ofStep` (Phase 5) — do not re-discharge the seven fields by hand.
- [ ] `IntPresentation.toModel` supplying the valuation.
- [ ] Carry `Fin card` throughout; never route computation through `Finite`.

**Timing**: 1.5 hours

**Depends on**: 5

**Verification Tier**: local

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/IntPresentation.lean` (new)

**Verification**:
- Module builds with zero diagnostics.
- `#eval`-able smoke instance: the promoted two-state witness from Phase 5 expressed as an
  `IntPresentation` and its `toFiniteFrame` elaborating.

---

### Phase 12: `IntPresentation.check` — the Bool-valued decision procedure [NOT STARTED]

**Goal**: A computable `check` deciding truth of a formula at a state of an `IntPresentation`.

**Tasks**:
- [ ] `IntPresentation.check (P : IntPresentation) (w : Fin P.card) (φ : Formula) : Bool`.
- [ ] Atom/`⊥`/`→`: direct on `val`.
- [ ] `□`: decided **once per model**, not per history — `box_const` (Phase 6) makes the box facts a
      single finite set. Compute it once and reuse; do not re-derive per call site.
- [ ] `untl`/`snce`: bounded search over the finite step-graph, with the witness-distance bound from
      Phase 8's pigeonhole lemma.
- [ ] Keep `check` structurally terminating on the formula with the graph search as an inner bounded
      loop; if termination needs a measure, state it explicitly rather than relying on `decreasing_by`
      guesswork.
- [ ] Do **not** revive, reference, or repair `validity_decidable` / `validity_has_decision_procedure`.
      They are deleted, with a retirement note at `Metalogic/Decidability/Correctness.lean` recording
      that the former "was proved by `exact Classical.em (⊨ φ)`" and "is in no sense a decidability
      statement". `isValid` (`DecisionProcedure.lean`) remains a `Bool` with no correctness theorem;
      that bridge is Phase 13's business, not this phase's.

**Timing**: 2 hours

**Depends on**: 11

**Verification Tier**: local

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/IntPresentation.lean` - `check`

**Verification**:
- Module builds; `check` is computable and `#eval`s on the two-state witness for a handful of
  formulas covering all six constructors.
- Hand-computed expected values for those formulas match.

---

### Phase 13: `check_correct`, the `Decidable` instance, and final gates [NOT STARTED]

**Goal**: Prove the correctness bridge and close out the task.

**Tasks**:
- [ ] Prove `IntPresentation.check_correct : P.check w φ = true ↔ ∃ τ, τ.IsTotal ∧ τ.states 0 _ = … ∧
      TruthAt (P.toModel) τ 0 φ` (exact statement pinned at implementation time against Phase 11's
      `toModel`).
- [ ] Derive a genuine `Decidable` instance for truth-at-a-state on an `IntPresentation` from
      `check_correct` — an instance that produces a procedure, unlike the retired `validity_decidable`.
- [ ] Update the `Correctness.lean` retirement note: it names the still-open obligation
      (`isValid φ fc = true ↔ ⊨ φ`, plus `Decidable (⊨ φ)` for the four frame classes). Record
      precisely which part this task discharges (model checking on an `IntPresentation`) and which
      part remains open (validity over the frame classes). Do not overclaim.
- [ ] Update `FormalSystem/Semantics/README.md` and `FMP/README.md` to describe the new normal-form
      and truth-connected layers.
- [ ] Final gate sweep.

**Timing**: 2 hours

**Depends on**: 10, 12

**Verification Tier**: full

**Scope Hypothesis**: The repository's live-`sorry` count is exactly 1 at task end
(`Metalogic/WeakCanonical/Transfer.lean`, declared invariant C3), unchanged from task start.
Confirm with `scripts/check-module-invariants.sh` — **not** naive grep, which over-counts
doc-comment prose. Any deviation is a task-blocking regression, not a rounding difference.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/IntPresentation.lean` - `check_correct`, `Decidable` instance
- `FormalSystem/Metalogic/Decidability/Correctness.lean` - retirement-note update (prose only)
- `FormalSystem/Semantics/README.md`, `FormalSystem/Metalogic/Decidability/FMP/README.md`

**Verification**:
- `lake build` green across the whole repository.
- `bash scripts/check-module-invariants.sh` — live-`sorry` count exactly 1.
- `bash scripts/check-paper-definitions.sh` — case-(a) quiet pass.
- `bash scripts/check-task-references.sh` — no task-number references in deliverable files (all new
  Lean modules and READMEs are outside `specs/**`).
- Test suite green.
- `git -C /home/benjamin/Philosophy/Papers/PossibleWorlds status --porcelain` shows no change
  attributable to this task.

---

## Testing & Validation

- [ ] `lake build` green at every phase close, and at task end.
- [ ] `bash scripts/check-module-invariants.sh` reports exactly 1 live `sorry`
      (`Metalogic/WeakCanonical/Transfer.lean`, invariant C3) at every phase close.
- [ ] `bash scripts/check-paper-definitions.sh` reports the quiet case-(a) pass at every phase
      boundary. This neighborhood moved three times in four days; a case-(b)-or-worse result pauses
      the phase for re-quoting before proceeding.
- [ ] Axiom-profile assertions from Phase 2, each recorded in its commit message:
      `sInter_nonempty_of_directed_of_minimal` depends on **no axioms**; `spherical_of_finite`
      depends on exactly `[propext, Classical.choice, Quot.sound]` and on **no Zorn** route
      (`PartialHistory.exists_maximal_extension` absent). **No test asserts the absence of
      `Classical.choice` from `spherical_of_finite`** — that assertion is provably unsatisfiable
      (Phase 2, Correction Record 3).
- [ ] Axiom-profile regression tripwire: `spherical_of_subsingleton` still depends on exactly
      `["propext"]` at task end, and the three `Unit`-carriered universal frames that consume it
      are unchanged.
- [ ] `bash scripts/check-task-references.sh` clean — no task-number citations in any new Lean
      module, README, or docstring.
- [ ] Existing test suite (`Tests/BimodalTest/`) still passes, including `TaskFrameTest.lean` after
      the Phase 5 `customFrame` promotion.
- [ ] Smoke instances: the promoted two-state ℤ witness exercises `ofStep`, `mem_HF_iff_adjacent`,
      `IntPresentation.toFiniteFrame`, and `check` end to end.
- [ ] No new declaration or docstring asserts the refuted Discrete-class FMP; every `Discrete`
      occurrence in the diff either says ℤ-time or explicitly records the refutation.
- [ ] No file under `/home/benjamin/Philosophy/Papers/` is modified.

## Artifacts & Outputs

- `specs/paper-definitions-of-record.md` - up to three newly tracked anchors (`cor:spherical-finite`, `lem:nesting`, `lem:nonempty`; fewer if task 440 landed one first)
- `FormalSystem/Semantics/TaskFrame.lean` - `TaskFrame.sInter_nonempty_of_directed_of_minimal` (axiom-free core), `TaskFrame.spherical_of_finite`, plus the `Mathlib.Order.Minimal` and `Mathlib.Data.Fintype.Powerset` imports. No existing declaration edited.
- `FormalSystem/Semantics/IntNormalForm.lean` (new) - `iter`, `iter_add`, `TaskFrame.step`, `taskRel_eq_iter`, `mem_HF_iff_adjacent`, `TaskFrame.ofStep`
- `FormalSystem/Semantics/Truth.lean` - `Truth.box_const`
- library home for the promoted off-zero-universal two-state ℤ witness
- `FormalSystem/Metalogic/Decidability/FMP/Periodicity.lean` (new) - pigeonhole, bounded witness distance, splice
- `FormalSystem/Metalogic/Decidability/FMP/TruthLemma.lean` (new) - the truth lemma, all six constructors
- `FormalSystem/Metalogic/Decidability/FMP/SemanticFMP.lean` (new) - the semantic FMP over ℤ-time
- `FormalSystem/Metalogic/Decidability/IntPresentation.lean` (new) - `IntPresentation`, `toFiniteFrame`, `toModel`, `check`, `check_correct`, `Decidable` instance
- README and retirement-note updates
- `specs/417_semantic_fmp_finite_worldstate_over_z/summaries/03_semantic-fmp-z-time-summary.md`

## Rollback/Contingency

- Every phase commits independently at each green sub-step, so any single phase can be reverted with
  `git revert` without disturbing earlier landed work. The normal-form module (Phases 3-5) and
  Phase 2's two lemmas are additive and independently valuable to sibling tasks; they survive even
  if the truth lemma does not.
- **If Phase 9 escalates to `[BLOCKED]`**: Phases 1-8 and 11-12 remain landed and green. Phases 10
  and 13 are blocked. Set the task status to `[BLOCKED]` with a blocker record naming the resisting
  goal state, the Phase 8 lemmas that proved insufficient, and the most-similar Boneyard precedent.
  Do **not** land a `sorry` to unblock the downstream phases.
- **If Phase 2's imports break a downstream module**: revert the two imports and the two
  declarations together (they are one additive unit) and re-plan the import placement — e.g. a
  separate `Semantics/SphericalFinite.lean` module importing `TaskFrame.lean`. Do **not** work
  around the failure by re-deriving through an existing choice-free helper; that path is closed by
  Correction Record 2.
- If the paper drifts mid-task in a way that invalidates a tracked quote, pause, re-run the
  definitions lint, re-quote per the record's extension protocol, and only then resume. Never
  restate or "improve" a definition from memory.
- If `lake build` breaks, fix forward. Never discard uncommitted changes to reach a passing build.
