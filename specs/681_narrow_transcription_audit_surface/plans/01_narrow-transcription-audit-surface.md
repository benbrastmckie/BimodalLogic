# Implementation Plan: Narrow the transcription audit surface

- **Task**: 681 - Narrow transcription audit surface
- **Status**: [IMPLEMENTING]
- **Effort**: 15 hours
- **Dependencies**: None
- **Research Inputs**: `specs/681_narrow_transcription_audit_surface/reports/01_narrow-transcription-audit-surface.md`
- **Artifacts**: plans/01_narrow-transcription-audit-surface.md (this file); summaries/01_narrow-transcription-audit-surface-summary.md
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Research settled what is and is not available here. Exactly one definition-to-theorem conversion
remains (*Limit* over a discrete duration order, already compiled clean), the four frame
constraints are pairwise irreducible and that irreducibility is *provable* rather than merely
assertable, and the cross-repository citation table has silently drifted by exactly +38 lines in
four rows because no gate in either repository reads it. This plan lands the one conversion, lands
the sixteen-theorem independence matrix that makes the four-condition audit row provably
irreducible, replaces the hand-maintained line-numbered cross-repository table with a generated
manifest plus a gate that fails loudly here when a declaration moves, and writes the exact
inspection-only residue — 24 Lean definitions, named not line-numbered — into a durable
name-keyed record on this side.

Done means: `lake build` green and sorry-free with zero warnings, the new independence module
compiling warning-free under the package linter set, `scripts/check-module-invariants.sh` passing
including the new manifest-freshness assertion, and
`docs/reference/transcription-audit-surface.md` stating the residue count plainly with every row
keyed by declaration name.

### Research Integration

The report supplies verified material, not candidate material: four `lean_run_code` snippets ran
against the live build, and `sep_of_succOrder` plus the `ofIntAction` smart constructor compiled
clean. Five findings shape the phase structure.

- **The conversion is real but touches a different surface than the task description assumes.**
  The report separates *Surface A* (Lean definitions a human reads against paper text — what the
  consuming document's audit tabulates) from *Surface B* (facts a particular certified frame
  supplies by hand). The one available conversion shrinks Surface B from four `ShiftSet` axiom
  fields to three. Surface A stays at 24 definitions. This plan keeps the two apart everywhere and
  never reports a Surface B win as an audit narrowing.
- **The narrowing programme is already far advanced.** Five conversions have landed
  (`TaskFrame.nullity_of_serial_limit` for *Limit*'s `⊇` half; `TaskFrame.comp_of` /
  `interpolates_of_comp`; `TaskFrame.saturation_of_fib_subsingleton`; `ShiftSet.shRel_serial` /
  `shRel_comp`; the consuming document's own Corollary 2.1 for `app:auto_existence`). None is
  re-attempted below.
- **The bound on the conversion is itself already a theorem.**
  `ShiftSet.SepNotDerivable.sep_not_derivable` refutes the separation condition for `ℚ` acting on
  `ℚ ⧸ DyadicGroup`, so *Limit* is derivable over discrete duration orders and provably not in
  general. Phase 1 therefore adds a theorem and a constructor and must **not** attempt to delete
  the `sep` field, which the reverse representation (`ShiftSet.ofModel`) genuinely needs.
- **The bare-relation constraint predicates are `D`-typed, not `TemporalOrder`-typed.**
  `TaskFrame.Serial`, `Compositional`, `Limit` and `Saturation` all take `{W : Type}`
  `(R : W → D → W → Prop)` against the section bundle
  `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]`, and
  `intOrder := ⟨ℤ⟩` is `@[reducible]` with `(↑intOrder : Type) = ℤ` by `rfl`. Stating every
  witness at `D := ℤ` is therefore *already* a statement about the certificate's own time
  structure, and it dissolves the report's single largest tactical risk — `omega` being blind to
  `↑intOrder`-typed hypotheses — at the level of the statement rather than by patching tactics.
  This is the one place this plan deliberately improves on the report's probe shape.
- **The citation drift is structural and will recur.** Check C20's declaration-span assertion
  already encodes the right convention and would have caught this drift, but its live scope is
  this repository's own files. `docs/reference/paper-definitions-of-record.md` and
  `docs/theorem-index.md` have each independently arrived at the same remedy — cite names, never
  line numbers, and re-derive any line-numbered view mechanically. Phases 6 and 7 apply that
  remedy to the cross-repository Lean side.

### Prior Plan Reference

No prior plan for this task. This is artifact round 1.

### Roadmap Alignment

No `roadmap_path` was provided with this dispatch and no roadmap flag was set; `specs/ROADMAP.md`
was not consulted and is not written to.

### Scope Boundary: the Consuming Repository Is Not Edited

The adequacy document that carries the drifted table is owned by the consuming repository. Nothing
in this plan edits it, and no phase writes outside this repository. The corrections that belong
over there are *recorded here* — in `docs/reference/transcription-audit-surface.md`, Phase 8 — in
the form the "record on this side only" convention already established for this task family:
declaration names plus the generated manifest, so the consuming side can apply them by mechanical
lookup rather than by re-deriving them.

## Goals & Non-Goals

**Goals**:

- Derive the paper's *Limit*, transcribed over a shift action, as a theorem from the zero-shift
  law alone whenever the duration order is discrete: `sep_of_succOrder`, plus a smart constructor
  `ofIntAction` that supplies the separation field from it, and consume both in the certificate
  path so the standard shift set's *Limit* obligation becomes kernel-checked rather than
  hand-proved.
- Land a machine-checked pairwise-independence matrix for the four `def:frame` constraints over
  the certificate's own time structure: four witness relations `emptyRel`, `totalRel`, `rayRel`,
  `driftRel`, sixteen theorems (`emptyRel_compositional`, `emptyRel_limit`,
  `emptyRel_saturation`, `emptyRel_not_serial`, `totalRel_compositional`, `totalRel_serial`,
  `totalRel_saturation`, `totalRel_not_limit`, `rayRel_compositional`, `rayRel_serial`,
  `rayRel_limit`, `rayRel_not_saturation`, `driftRel_serial`, `driftRel_limit`,
  `driftRel_saturation`, `driftRel_not_compositional`) with the non-additive duration
  reindexing `drift` they rest on, and one aggregate statement
  `constraints_pairwise_independent`, so that "the four-condition audit row cannot be shrunk to
  three" is a theorem rather than a claim.
- Replace the hand-maintained cross-repository line-numbered citation table with a generated
  manifest and a gate that fails loudly in this repository when a cited declaration moves.
- State the inspection-only residue plainly and exactly — as a count, with every row keyed by
  declaration name — including the three notions the consuming document's audit does not currently
  reach, so a reader sees the size of the informal surface rather than being told it is small.

**Non-Goals**:

- Editing the consuming repository. Its adequacy document is read-only input here; the
  corrections it needs are recorded on this side (see Scope Boundary above).
- Deleting the separation field from the shift-set structure. It is genuinely required over dense
  duration orders and the refutation is already in the tree.
- Shrinking the time-structure audit row. Four Mathlib classes stand against the paper's four
  adjectives one-to-one and the pinned Mathlib carries no bundled class to collapse them into;
  Phase 8 records this as a closed question so a later pass does not re-derive it as an
  opportunity.
- Re-attempting any of the five conversions that have already landed.
- Reducing the residue by deleting audit rows. The honest direction is the other one: the record
  written here is *larger* than the consuming document's, by three rows.
- Wiring the Comparator compare step, or promoting any advisory check to a hard gate beyond the
  one new manifest-freshness assertion.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `omega` blind to `↑intOrder`-typed hypotheses (the report's dominant tactical failure) | M | H | State every witness at `D := ℤ`, never at `↑intOrder`. The bare-relation predicates are `D`-typed and `(↑intOrder : Type) = ℤ` by `rfl`, so this is the same statement with a working arithmetic front end. Record the reason in the module header so a later editor does not "tidy" it back. |
| `SuccOrder ↑intOrder` does not synthesise | M | H | Use the explicit `@ … (inferInstanceAs (SuccOrder ℤ)) (inferInstanceAs (NoMaxOrder ℤ))` form already established at `WitnessFamily.std_isZTime`, whose module header records why `haveI` fails there. Import `Mathlib.Data.Int.SuccPred`. |
| Rewriting the standard shift set breaks downstream proofs that `simp [std]` through its fields | H | M | The rewrite must leave every field *value* unchanged — only the separation field's provenance changes. Verify by full `lake build` plus `check_certificate` still executing, not by the module build alone; hence Verification Tier `full` on Phase 1. |
| Deleting the hand proof invalidates a cited range in the consuming document | M | H | Phase 8 records the invalidated range explicitly as a correction row; Phases 6-7 make the same class of drift detectable next time. Do not fix it silently. |
| The *Compositionality* witness is the one not yet written | M | M | It is a functional relation, so three constraints come free by existing helpers (`saturation_of_fib_subsingleton`, `limit_of_succOrder`, surjectivity for *Seriality*). If it resists, the honest outcome is `[COMPLETED WITH EXCLUSIONS]` on Phase 4 with three independence results and an explicit gap recorded — never a `sorry`, and never a weakened restatement. |
| A new module escapes the library root, the aggregator, or `FormalSystem.Init` reachability | H | M | Phase 2 adds the import to `FormalSystem/Semantics.lean`, regenerates the root with `lake exe mk_all --lib FormalSystem`, and closes on C33 + C24 passing, not on a local build. |
| The generated manifest itself becomes a C20 violation | M | M | Emit it as JSON at `scripts/lean-citation-manifest.json`. C20 scans only `.lean`, `.md`, `.typ` and `.sh`; publication scope is `README.md`, `docs/`, `typst/` and the `FormalSystem/` READMEs. A `.json` file under `scripts/` is outside both. Confirm at implementation time rather than assuming. |
| Line numbers quoted from the research report have drifted again by implementation time | L | H | Every line number below is a hypothesis carried by a **Scope Hypothesis** line; re-derive each from the declaration name before acting on it. The record written in Phase 8 is name-keyed precisely so it cannot acquire this risk. |
| Concurrent sibling tasks share this working tree this cycle | M | H | Re-read every file immediately before editing; stage only this task's own hunks with an explicit file list, never a directory or glob pathspec; never run `git-snapshot.sh` in its reverting default mode; treat a build failure outside this task's files as possibly a sibling's in-flight edit and report rather than repair it. |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3 | 2 |
| 3 | 4 | 3 |
| 4 | 5 | 4 |
| 5 | 6 | 1, 5 |
| 6 | 7, 8 | 6 |
| 7 | 9 | 7, 8 |

Phases within the same wave can execute in parallel. Phases 3, 4 and 5 are serialised although
all three extend the same new module: they edit one file, and the independence matrix of Phase 5
quantifies over all four witnesses. Phases 7 and 8 are genuinely parallel — one edits
`scripts/` plus `docs/development/MODULE_INVARIANTS.md`, the other `docs/reference/`.

### Phase 1: Derive *Limit* over a discrete duration order, and consume it [COMPLETED]

**Goal**: Move the paper's *Limit*, transcribed over the shift action, from a hand-supplied field
of the certificate's standard shift set to a kernel-checked consequence of the zero-shift law,
without removing the field that the dense case genuinely needs.

**Tasks**:

- [x] Re-read `FormalSystem/Semantics/ShiftSet.lean` immediately before editing (sibling tasks
      share this tree). Locate the `SepNotDerivable` section, whose docstring already frames the
      general-versus-discrete distinction, and site the new declarations beside it.
- [x] Add `ShiftSet.sep_of_succOrder`, transcribed from the report's verified snippet:
      `{D : TemporalOrder} [SuccOrder (↑D : Type)] [NoMaxOrder (↑D : Type)] {Ω : Type}`
      `(sh : Ω → ↑D → Ω) (hz : ∀ w, sh w 0 = w)`, concluding the separation shape, proved by
      `TaskFrame.limit_of_succOrder (R := fun w y u => u = sh w y) (fun w u h => by rw [h, hz])`.
      Its docstring must record (a) that this is `def:frame#Limit`'s transcription over a shift
      action, derived rather than assumed; (b) that the derivation is bounded by
      `ShiftSet.SepNotDerivable.sep_not_derivable`, so the field survives; and (c) a `Paper:` line
      citing `def:frame#Limit`.
- [x] Add `ShiftSet.ofIntAction`, a smart constructor for `ShiftSet intOrder` taking the carrier,
      its nonemptiness, the shift, the two action laws and the valuation, and supplying the
      separation field from `sep_of_succOrder`. Use the explicit
      `@ … (inferInstanceAs (SuccOrder ℤ)) (inferInstanceAs (NoMaxOrder ℤ))` application form and
      add `import Mathlib.Data.Int.SuccPred` if it is not already present transitively; state in
      the docstring why the explicit form is needed (`SuccOrder ↑intOrder` does not synthesise
      because `intOrder.carrier` is not syntactically `ℤ` for instance search).
- [x] Verify the two new declarations compile and report no unexpected axioms
      (`#print axioms`; `sorryAx` must not appear). Commit this green sub-step.
- [x] Re-read `FormalSystem/Metalogic/Decidability/WitnessFamily/Std.lean`, then rewrite
      `WitnessFamily.std` to be built by `ofIntAction`, deleting the hand separation proof (the
      `Int.abs_lt_one_iff` block) and leaving every other field value byte-identical. `std` must
      remain non-`@[reducible]` — the module header records that reducibility breaks synthesis of
      `ShiftSet.frame_isRegular`.
- [x] Confirm `WitnessFamily.std_isZTime`, `std_sat_ztime`, `std_sat_base`, `sh_surj`, `sh_fst`
      and `sh_snd` all still compile unchanged, and that nothing downstream was relying on the
      deleted proof term's shape. *(deviation: altered — five of the six compile byte-identically;
      `sh_surj`'s `simp [std]` needed `; rfl` appended, because a projection of `ofIntAction` is
      not reduced by unfolding `std` alone. Two `@[simp]` projection lemmas
      `ShiftSet.ofIntAction_sh` / `ofIntAction_A` were added so that `ofIntAction` behaves under
      `simp` exactly as the hand-written structure instance it replaces; the residual `rfl` closes
      a goal whose two sides are defeq but not syntactically equal.)*
- [x] Update the `ShiftSet.lean` module header's "Four axioms in place of six frame fields"
      section: over a discrete duration order the axiom burden is three, not four, and the
      separation field is discharged by `sep_of_succOrder` rather than by hand. Keep the general
      statement (four fields) correct for a general duration order — this is the Surface A / B
      distinction, and the header must not blur it.
- [x] Run the full gate set for this phase: `lake build` (zero `error:`, zero `warning:`), the
      package linter set over both modified modules, and the certificate executable still
      accepting whatever it accepted before. *(deviation: altered — `lake build` is green with
      zero `error:` and zero `warning:` (2739 jobs) and both modified modules are silent under the
      package linter set. The certificate acceptance suite
      `BimodalToolsTest.CertificateImportTest` could NOT be run: `BimodalTools/CertificateImport.lean`
      currently carries a concurrent sibling task's uncommitted, non-compiling new declaration
      `refutes_of_countermodel` (an `Application type mismatch` at its own line 639, in code added
      by that sibling's diff and absent from HEAD), so the failure is outside this task's scope and
      would occur identically without this task's changes. The `std` consumer that the certificate's
      semantic guarantee actually routes through — `WitnessFamily/Agreement.lean` — was built
      separately and is green.)*

**Timing**: 2 hours

**Depends on**: none

**Verification Tier**: full

**Scope Hypothesis**: the report locates the separation field at `Semantics/ShiftSet.lean:115`,
the refutation at `:520`, `TaskFrame.limit_of_succOrder` at `Semantics/TaskFrame.lean:1591`, and
the hand proof at `WitnessFamily/Std.lean:71-77` (the consuming document cites this range as
`73-80`). Confirm each by declaration name — `grep -n` for the identifier, not the line — before
editing; treat any mismatch as drift to record in Phase 8, not as a blocker.

**Files to modify**:

- `FormalSystem/Semantics/ShiftSet.lean` — add `sep_of_succOrder` and `ofIntAction`; update the
  axiom-count paragraph of the module header
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Std.lean` — build `std` through
  `ofIntAction`, delete the hand separation proof, adjust the module header's account of which
  imports are load-bearing if the import set changes

**Verification**:

- `lake build` exits 0 with zero `error:` and zero `warning:` lines
- Both modified modules are silent under
  `lake env lean -D weak.linter.mathlibStandardSet=true -D autoImplicit=false`
- `#print axioms` on `WitnessFamily.std_sat_ztime` is unchanged from its pre-phase value, and
  reports no `sorryAx`
- `grep -c sorry` remains 0 in both modified files

---

### Phase 2: Open the frame-constraint independence module and land two witnesses [COMPLETED]

**Goal**: Create the module that makes the four-condition audit row provably irreducible, wire it
into the library the way this repository's invariants require, and land the two witnesses whose
constraint proofs are already fully verified.

**Tasks**:

- [x] Create `FormalSystem/Semantics/FrameConstraintIndependence.lean` with the standard
      copyright header, `import FormalSystem.Semantics.TaskFrame`, and
      `import Mathlib.Data.Int.SuccPred`. Do **not** site this under
      `FormalSystem/Metalogic/Independence/`: that directory means *proof-system axiom*
      independence and invariant C34a flags the collision risk explicitly.
- [x] Write the module docstring: what the module establishes (each of `def:frame`'s four
      constraints is independent of the other three, over the very time structure the certificate
      uses), why it is stated at `D := ℤ` rather than `↑intOrder` (`intOrder := ⟨ℤ⟩` is
      `@[reducible]` and `(↑intOrder : Type) = ℤ` by `rfl`, so this *is* the `intOrder` statement,
      and `omega` can see it), and what it does not establish (nothing about the definitional
      audit surface — it bounds how far the four-clause row can be compressed, not how many
      definitions a reader must inspect). *(deviation: altered — the docstring additionally
      carries a section "This is not the tree's first independence matrix", required by this
      phase's own Scope Hypothesis. `StateTopology/ConstraintWitnesses.lean`'s header already
      claims a **complete** independence matrix: `voidRel` (character-identical to `emptyRel`) for
      *Seriality*, `bumpRel` for *Compositionality*, `SeparatingFrame.srel` for *Saturation* at
      bare `ℤ`, and the four-state funnel for *Limit* — the last under `[DenselyOrdered ↑D]`, so
      not over `ℤ`. The new module cites all four rows by name and states plainly that what it adds
      is the first **aggregate** statement, the first *Limit* refutation over discrete time, and
      import-light reachability from the `Semantics.lean` aggregator, which the topology-carrying
      witnesses deliberately do not have. Three of the four rows therefore re-prove, at a different
      witness, something the tree already knew; that duplication is recorded rather than glossed.)*
- [x] Add `emptyRel : Bool → ℤ → Bool → Prop := fun _ _ _ => False` with
      `emptyRel_compositional`, `emptyRel_limit`, `emptyRel_saturation` and
      `emptyRel_not_serial`. The three positive proofs go by `simp` over the relation plus `Fib`
      and `Seg`; the refutation is `intro h; obtain … := h true 0 le_rfl`.
- [x] Add `totalRel : Bool → ℤ → Bool → Prop := fun _ _ _ => True` with
      `totalRel_compositional`, `totalRel_serial` (via `TaskFrame.serial_of_total`),
      `totalRel_saturation` and `totalRel_not_limit`, the last using the report's corrected tactic
      line `fun x hx => ⟨0, by simpa using hx, trivial⟩`. Record in the docstring why the carrier
      is `Bool` and not `Unit`: `FrameOver.trivialFrame` already carries the total relation on
      `Unit`, where *Limit* holds by `limit_of_subsingleton`, so a two-point carrier is what makes
      the refutation possible.
- [x] Add the import line to `FormalSystem/Semantics.lean` in sorted position, and a bullet in
      that aggregator's module docstring in the established idiom.
- [x] Regenerate the library root: `lake exe mk_all --lib FormalSystem`, then confirm C33 passes
      and `lake exe checkInitImports` (C24) still reports every module reaching
      `FormalSystem.Init`. *(deviation: altered — `mk_all` globs the filesystem, so it also emitted
      `import FormalSystem.SourceLanguage` and `import FormalSystem.SourceLanguage.Sentence` for a
      concurrent sibling task's **untracked** new files. Both lines were removed from the generated
      root before committing, leaving exactly the one line this module causes: C33 scans tracked
      files and passes on that shape (575 imports), and committing a root that imports untracked
      modules would have been a broken commit and an over-stage of a sibling's work. C24 exits 0.)*
- [x] Run `lake build` and the package linter set over the new module; commit.

**Timing**: 2 hours

**Depends on**: none

**Verification Tier**: full

**Scope Hypothesis**: this phase asserts that `emptyRel` and `totalRel` need exactly four theorems
each, and that no frame-constraint independence record already exists in the tree. Confirm the
second by `grep -rn "pairwise_independent\|constraint.*independen"` over `FormalSystem/` before
writing — `Semantics/StateTopology/ConstraintWitnesses.lean` carries *constraint failure*
witnesses (`GhostRay.frame_not_limit`, `RationalTwoOrigins.not_rel_saturation`) and any overlap
with them must be cited rather than duplicated.

**Files to modify**:

- `FormalSystem/Semantics/FrameConstraintIndependence.lean` — new module: header, docstring,
  `emptyRel` and `totalRel` with their eight theorems
- `FormalSystem/Semantics.lean` — import line plus docstring bullet
- `FormalSystem.lean` — regenerated, never hand-edited

**Verification**:

- `lake build` exits 0 with zero `error:` and zero `warning:` lines
- The new module is silent under the package linter set
- `bash scripts/check-module-invariants.sh` passes C8, C24, C33 and the copyright-header check
- `grep -c sorry` is 0 in the new module

---

### Phase 3: The *Saturation* witness [COMPLETED]

**Goal**: Land the upward-ray relation, which satisfies *Compositionality*, *Seriality* and
*Limit* and refutes *Saturation* — the witness that stops the fourth constraint being absorbed
into the other three.

**Tasks**:

- [x] Re-read the module, then add
      `rayRel : ℤ → ℤ → ℤ → Prop := fun w x u => (x = 0 ∧ u = w) ∨ (0 < x ∧ w ≤ u) ∨ (x < 0 ∧ u ≤ w)`,
      stated at `D := ℤ` throughout.
- [x] Prove `rayRel_compositional`, `rayRel_serial` and `rayRel_limit` by `rcases` plus `omega`,
      which works at `ℤ` — this is where the statement-level mitigation pays off. Where a vacuous
      branch still resists, use explicit `lt_irrefl` / `le_trans` steps rather than reaching for a
      coercion lemma. *(deviation: altered — one auxiliary lemma `rayRel_def` (a plain `Iff.rfl`,
      deliberately **not** `@[simp]`) was added, and the definition is opened with `rw [rayRel_def]`
      rather than `simp only [rayRel]`. Measured reason: `simp only [rayRel]` collapses the
      reflexive conjunct `w = w` to `True`, and `omega` then reports "No usable constraints found"
      — simping the definition open destroys the very arithmetic front end that stating the witness
      at `ℤ` was meant to provide. `rayRel_serial` is an explicit term proof rather than
      `rcases` + `omega`, for the same reason. The docstring on `rayRel_def` records this so a
      later editor does not convert it to a simp lemma.)*
- [x] Prove `rayRel_not_saturation` with the report's verified construction: the family
      `{TaskFrame.Fib rayRel w 1}`, shown `⊇`-directed with `Set.subset_inter_iff`, every member a
      nonempty fibre, and `⋂₀` empty. `simp only [Set.mem_setOf_eq]` is needed before `omega`.
      *(deviation: altered — the directedness step uses `simp only [Set.mem_inter_iff,
      TaskFrame.mem_Fib, rayRel_def]` on a pointwise membership goal rather than
      `Set.subset_inter_iff` on the set inclusion, and the two membership steps use
      `rw [TaskFrame.mem_Fib, rayRel_def]` in place of `simp only [Set.mem_setOf_eq]`, for the
      omega-and-`True` reason recorded on the previous item. The construction — family, directing
      witness at `max w₁ w₂`, nonempty fibres, empty `⋂₀` refuted at `a + 1` — is the report's
      unchanged.)*
- [x] Docstring: name which constraint fails and why (fibres of a positive duration are upward
      rays, whose directed intersection recedes to infinity), and state that the failure is *not*
      a completeness failure — contrast `RationalTwoOrigins.not_rel_saturation`, which is, so a
      reader does not conflate the two mechanisms.
- [x] `lake build`, linter set, commit.

**Timing**: 2 hours

**Depends on**: 2

**Verification Tier**: local

**Files to modify**:

- `FormalSystem/Semantics/FrameConstraintIndependence.lean` — `rayRel` and its four theorems

**Verification**:

- The module builds with zero `error:` and zero `warning:` lines and is silent under the package
  linter set
- `#print axioms rayRel_not_saturation` reports no `sorryAx`
- The final gate set still runs at the end of Phase 5 and Phase 9; `local` here governs in-phase
  granularity only

---

### Phase 4: The *Compositionality* witness [COMPLETED]

**Goal**: Land the one witness the report designed but did not write: a functional but
non-additive shift, which satisfies *Seriality*, *Limit* and *Saturation* and refutes
*Compositionality*.

**Tasks**:

- [x] Add `drift : ℤ → ℤ`, the identity except at `1`, where it takes the value `5`, with a
      docstring stating that non-additivity at a single point is the whole content of the
      refutation.
- [x] Add `driftRel : ℤ → ℤ → ℤ → Prop := fun w x u => u = w + drift x`.
- [x] Prove `driftRel_saturation` from `TaskFrame.saturation_of_fib_subsingleton` composed with
      `TaskFrame.fib_subsingleton_of_functional` (the relation is functional, so every fibre is a
      subsingleton), `driftRel_limit` from `TaskFrame.limit_of_succOrder` with the zero-duration
      hypothesis discharged by `drift 0 = 0`, and `driftRel_serial` from surjectivity (successor
      `w + drift x`, predecessor `w - drift x`).
- [x] Prove `driftRel_not_compositional`: at `x = y = 1`, composition gives `w + 10` while the
      single step of duration `2` gives `w + 2`, and `10 ≠ 2`.
- [x] Docstring: record that this witness is functional *on purpose* — functionality is what makes
      three of the four constraints free, isolating *Compositionality* as the only thing the
      witness has to break. *(deviation: altered — the docstring additionally names
      `StateTopology.bumpRel`, the already-landed witness for this same row, and says how the two
      differ (clause boundary at `|d| ≥ 2` versus non-additivity), per Phase 2's Scope Hypothesis
      finding.)*
- [x] `lake build`, linter set, commit.

**Timing**: 2 hours

**Depends on**: 3

**Verification Tier**: local

**Files to modify**:

- `FormalSystem/Semantics/FrameConstraintIndependence.lean` — `drift`, `driftRel` and the four
  theorems

**Verification**:

- The module builds clean and is silent under the package linter set
- No `sorry` and no `sorryAx` anywhere in the module
- If the refutation genuinely resists, close this phase `[COMPLETED WITH EXCLUSIONS]` with a
  `#### Reasoned Exclusions` record naming the missing witness, the reason, and the evidence — and
  carry the gap explicitly into Phase 5's aggregate statement and Phase 8's record. A `sorry` or a
  weakened restatement is not an acceptable outcome here.

---

### Phase 5: The independence matrix, and its records [COMPLETED]

**Goal**: State the pairwise-independence result as one citable theorem, and put it on every
surface this repository requires a new public result to appear on.

**Tasks**:

- [x] Add `constraints_pairwise_independent`: a four-way conjunction of existentials, each
      supplying a carrier and a relation satisfying three of `TaskFrame.Compositional`,
      `TaskFrame.Serial`, `TaskFrame.Limit`, `TaskFrame.Saturation` and refuting the fourth, all
      at `D := ℤ`. Its proof is sixteen references to the theorems of Phases 2-4 and nothing else.
- [x] Docstring: state exactly what this licenses and what it does not. It licenses "the
      four-clause frame-condition row cannot be compressed to three, over the certificate's own
      time structure". It does **not** license any claim about the definitional audit surface —
      the report's Surface A / Surface B distinction, which this docstring must name, because
      conflating them is the specific error this whole task exists to avoid.
- [x] Check whether any declaration in this module carries a bracketed binder supplying a bundling
      class; if so, give it a `Constraints consumed:` marker in the form
      `docs/development/REFERENCE_NORMAL_FORM.md` section 3 defines, so C34a/C34b are satisfied by
      construction rather than after a gate failure. Bare-relation statements carry no such binder
      and need no marker. *(checked: no declaration in the module carries any bracketed binder —
      every statement is at a concrete `Bool` or `ℤ` carrier — so no marker is needed. C34a passes
      with 43 honest markers and C34b with no unmarked binder-carrying claim.)*
- [x] Add rows to `docs/theorem-index.md` for the aggregate theorem and the four refutations,
      fully qualified, with `Paper: def:frame` where applicable and no line numbers (the ledger's
      own stated convention). *(deviation: altered — C15 rejected the first attempt: it requires
      each indexed declaration's own doc comment to carry `Paper: <anchor>` on a **standalone
      line**, and the module had been written with the anchor inline at the end of a sentence
      (`... Paper: `def:frame#Limit`. -/`). All nineteen `Paper:` mentions in the module were
      normalised to the standalone form; C15 now passes on all 210 rows. The five rows themselves
      are as planned.)*
- [x] Add the module to `FormalSystem/Semantics/README.md` in the established idiom, and refresh
      that README's `Last verified` date (2026-09-23 -> 2026-09-27).
- [x] Run the whole gate set: `lake build`, the package linter set,
      `bash scripts/check-module-invariants.sh` (C14 documented-count assertions and C15's
      theorem-index anchoring in particular), `bash scripts/readme-lint.sh`,
      `bash scripts/check-copyright-headers.sh`, `bash scripts/check-metalogic-cycles.sh`.
      *(deviation: altered — the module builds clean and is linter-silent; `readme-lint.sh`,
      `check-copyright-headers.sh` and `check-metalogic-cycles.sh` all exit 0; C3, C14, C15, C20,
      C33, C34a and C34b all pass. `check-module-invariants.sh` exits 1 on three findings, none of
      them closable in this phase: **C13** flags the not-yet-written
      `docs/reference/transcription-audit-surface.md`, which Phase 8 creates; **INV** flags 5 stale
      generated inventory blocks, four of them in files a concurrent sibling task has modified in
      this shared tree; **C28** flags 2 new `linter.style.longLine` warnings in
      `BimodalTools/TranslateSentenceMain.lean`, a sibling's new untracked file. None is this
      task's to fix here.)*

**Timing**: 1.5 hours

**Depends on**: 4

**Verification Tier**: local

**Scope Hypothesis**: this phase asserts that five theorem-index rows and one README entry are the
whole documentation surface a new leaf module in `FormalSystem/Semantics/` owes. Confirm by
running `scripts/check-module-invariants.sh` and `scripts/readme-lint.sh` and reading their
output, not by assuming the list is complete; add whatever else they name.

**Files to modify**:

- `FormalSystem/Semantics/FrameConstraintIndependence.lean` — the aggregate theorem
- `docs/theorem-index.md` — rows for the new public results
- `FormalSystem/Semantics/README.md` — module entry and `Last verified` date

**Verification**:

- `bash scripts/check-module-invariants.sh` passes, C15's theorem-index assertion included
- `bash scripts/readme-lint.sh` exits 0
- `constraints_pairwise_independent` type-checks and reports no `sorryAx`

---

### Phase 6: Generate the cross-repository citation manifest [COMPLETED]

**Goal**: Make the line-numbered view of this repository's declarations a *generated* artifact, so
a table living in another repository can cite names and include a manifest instead of trusting
line numbers no gate reads.

**Tasks**:

- [x] Write `scripts/export-lean-citations.py`: read a list of fully qualified declaration names,
      resolve each to its file and line by importing `scripts/lib/lean_citations.py`'s
      `decl_spans` and `candidates` — never a fresh parser, so the exporter and C20's third
      assertion cannot disagree about where a declaration lives — and emit JSON.
- [x] Emit to `scripts/lean-citation-manifest.json`, carrying for each entry: the fully qualified
      name, the file path, the keyword line, the span, and a resolution status. A name resolving to
      zero or to several declarations is an explicit error entry and a non-zero exit, never a
      silently omitted row. *(deviation: altered — `decl_spans` reports a declaration's name as
      *written*, i.e. local to its enclosing `namespace`, so the exporter additionally tracks each
      file's `namespace`/`section`/`end` stack to recover the fully qualified name and matches on
      that; `candidates` is consulted only as a fallback, to report an ambiguity precisely rather
      than to guess. Spans still come from `decl_spans` alone, so the exporter and C20 cannot
      disagree about where a declaration lives. Separately, three residue rows name a **structure
      field** (`FrameOver.worldNonempty`, `TaskModel.valuation`, and `TruthCorr`'s fields), which
      opens no declaration span — C20's own output counts such citations as "not checkable, not
      failed" rather than failing them. A seed line therefore writes `Parent.Name#field`: the parent
      resolves as a declaration and the field is carried as metadata, so every seeded name resolves
      to exactly one declaration and no row is silently dropped.)*
- [x] Seed the name list with every declaration the consuming document's citation table cites,
      taken from the research report's enumeration: the `WitnessFamily` standard-shift-set group,
      the frame-class membership group, the four `Metalogic/Independence/ZTimeSharpness.lean`
      declarations whose citations drifted by +38, and the 24 residue declarations of Phase 8's
      record. Keep the list in a plain, reviewable input file rather than inside the script.
- [x] Run the exporter and confirm every seeded name resolves. Any name that does not is either a
      rename this repository made and never propagated — record it for Phase 8 — or a typo in the
      seed list. *(result: 53 seeded names, all 53 resolved; nothing to record for Phase 8 as a
      rename. Second run byte-identical to the first.)*
- [x] Document the exporter in `scripts/README.md` (one row under "Other utilities" and two under "Allowlists, manifests, and other data files").

**Timing**: 1.5 hours

**Depends on**: 1, 5

**Verification Tier**: local

**Scope Hypothesis**: this phase asserts that a `.json` manifest under `scripts/` is outside C20's
scope in both directions — its scanner reads only `.lean`, `.md`, `.typ` and `.sh`, and its
publication scope is `README.md`, `docs/`, `typst/` and the `FormalSystem/` READMEs. Confirm by
running `bash scripts/check-module-invariants.sh` after the manifest exists and reading C20's
three assertions, not by trusting this sentence. If a `.json` file turns out to be in scope, keep
the manifest but move it out of any scanned root rather than weakening C20.

**Files to modify**:

- `scripts/export-lean-citations.py` — new exporter
- `scripts/lean-citation-manifest.json` — new generated manifest
- the seed name list (new plain-text input beside the exporter)
- `scripts/README.md` — inventory entry

**Verification**:

- The exporter runs from a clean checkout and exits 0 with every seeded name resolved
  — **confirmed**: `export-lean-citations: 53 seeded name(s) resolved`, exit 0
- Re-running it twice produces a byte-identical manifest (it must be deterministic, or the
  freshness gate of Phase 7 is unusable) — **confirmed** by `diff -q` on two consecutive runs
- A deliberately misspelled name in the seed list produces a named error entry and a non-zero
  exit — **confirmed**. Seeding `FormalSystem.Semantics.TaskFrame.Saturatoin` in place of
  `...Saturation` gives exit 1 and, on stderr:

  ```
  export-lean-citations: UNRESOLVED: FormalSystem.Semantics.TaskFrame.Saturatoin -- no declaration with this fully qualified name
  export-lean-citations: 1 of 53 seeded name(s) did not resolve
  ```

  with the manifest carrying `"status": "unresolved"` and a `detail` for that entry and
  `"resolved": 52, "total": 53`.
- C20's scope hypothesis **confirmed after the fact, not assumed**: with the `.json` manifest in
  place, C20's three assertions report the same counts as before it (tier 1: 1028; tier 2: zero;
  declaration span: 886) and all pass

---

### Phase 7: Gate the manifest's freshness [NOT STARTED]

**Goal**: Make a rename or a docstring sweep in this repository fail loudly *here* rather than
silently rotting a table in another repository.

**Tasks**:

- [ ] Determine the next free invariant number by reading
      `docs/development/MODULE_INVARIANTS.md` and `scripts/check-module-invariants.sh` (C34a/C34b
      are the highest recorded; the next is expected to be C35 but must be confirmed, not
      assumed).
- [ ] Add the check to `scripts/check-module-invariants.sh` in the established idiom: re-run the
      exporter's resolution in-process and compare against the committed manifest, failing with a
      per-entry diagnostic naming the declaration, the recorded location and the current one.
      Anti-silence in the same shape the neighbouring checks use: an empty name list, zero
      declaration spans, or zero entries compared is a broken matcher and exits non-zero in every
      mode.
- [ ] Make it build-free (a pure `python3` scan over source text) so it runs under `--no-build`
      and therefore in CI, matching the reason C33 and C34 are build-free.
- [ ] Add the invariant's row to `docs/development/MODULE_INVARIANTS.md`: what it asserts and the
      evidence for why it exists — four rows drifted by exactly +38 lines and landed inside a
      different theorem, invisible to every gate in either repository, because C20's live scope is
      this repository's own files.
- [ ] Run the deliberate negative test this repository requires of a new gate: move a cited
      declaration (or edit a docstring above one), confirm the check fails and names the entry,
      restore, confirm it passes again. Record both outputs.

**Timing**: 1.5 hours

**Depends on**: 6

**Verification Tier**: local

**Scope Hypothesis**: this phase asserts the next invariant number is C35 and that one check block
plus one documentation row is the whole wiring cost. Confirm the number against both files before
writing; if it is taken, use the next free one and keep the row adjacent to C20's, since the two
are about the same failure.

**Files to modify**:

- `scripts/check-module-invariants.sh` — the new check block
- `docs/development/MODULE_INVARIANTS.md` — the new invariant row

**Verification**:

- `bash scripts/check-module-invariants.sh` passes with the new assertion reporting a non-zero
  entry count
- `bash scripts/check-module-invariants.sh --no-build` runs the new check (it must not join the
  not-in-CI set)
- The negative test fails loudly and names the moved declaration; the restored state passes

---

### Phase 8: State the residue, exactly and by name [NOT STARTED]

**Goal**: Write the durable, name-keyed record of what remains inspection-only, so a reader can
see the exact size of the informal surface instead of being told it is small — and record the
corrections the consuming side owes its own table, without editing that repository.

**Tasks**:

- [ ] Create `docs/reference/transcription-audit-surface.md` in the idiom of
      `docs/reference/state-topology-appendix-support.md`: a "What this is" opening, an audience
      line, an explicit "How rows are keyed" statement (by declaration name and paper anchor,
      never by line number — the line-numbered view is `scripts/lean-citation-manifest.json`, and
      it is generated), and a pointer to `docs/theorem-index.md` as the per-declaration authority.
- [ ] Write the two-surface distinction first, because every number below depends on it: the
      definitional surface (Lean definitions a human reads against paper text) versus a particular
      construction's axiom burden. State plainly that this task's one conversion shrank the second
      from four axiom fields to three over a discrete duration order and left the first unchanged.
- [ ] Write the residue table: the report's 24 rows, each keyed by declaration name and paper
      anchor, with no line numbers. State the count in the surrounding prose as a count.
- [ ] Mark the three rows the consuming document's audit does not currently reach —
      `FrameOver.worldNonempty` (a nonempty world set, whose own docstring records that an empty
      carrier satisfies all four axioms vacuously while validating falsehood),
      `PartialHistory.WorldHistory` and its totality predicate (quantified over by the box clause),
      and `TruthCorr` (reachable only if the general time-shift lemma is cited rather than the
      instantiated one) — and say explicitly that recording them makes the stated residue
      *larger*, which is the honest direction.
- [ ] Record the corrections the consuming table needs, as a table of declaration names with the
      manifest as the resolution source: the four drifted citations, the range invalidated by
      Phase 1's deletion, the two ranges worth tightening, and the softened *Limit* verdict (only
      the `⊆` half is transcribed; the `⊇` half is `TaskFrame.nullity_of_serial_limit`, derived).
      Do not write line numbers into this document — name the declaration and point at the
      manifest.
- [ ] Record the two closed questions so a later pass does not re-open them as opportunities: the
      time-structure row is already one-to-one against the paper's four adjectives and the pinned
      Mathlib offers no bundled class to collapse it into; and the four-clause constraint row is
      provably incompressible, citing `constraints_pairwise_independent`.
- [ ] Record what the independence matrix does *not* do: the ten definitions standing behind the
      four constraint clauses (the supporting fibre and segment vocabulary) are named rather than
      inlined on purpose, and should be counted at ten rather than at four.
- [ ] Add the row to `docs/reference/README.md` under "Records of Record".

**Timing**: 1.5 hours

**Depends on**: 6

**Verification Tier**: prose

**Scope Hypothesis**: this phase asserts the residue is exactly 24 definitions and that 20 of the
24 cited locations in the consuming table still resolve while 4 do not. Both are the research
report's measurements and both must be re-confirmed before the document states them — the 24 rows
against the tree by name (every row's declaration must exist), and the citation verdicts against
the manifest produced in Phase 6. If a count has moved, the document states the new one and says
so; it must not restate a number this task did not re-derive.

**Files to modify**:

- `docs/reference/transcription-audit-surface.md` — new record
- `docs/reference/README.md` — index row under "Records of Record"

**Verification**:

- Every declaration named in the residue table resolves in the tree (check by name, via the
  manifest)
- Zero `file.lean:NNN` citations anywhere in the new document — C20 tier 2 is enforced by default
  over `docs/`, and this document's whole design is name-keyed
- `bash scripts/check-module-invariants.sh` passes C12, C13, C15 and C20 over the new document
- `bash scripts/readme-lint.sh docs` exits 0

---

### Phase 9: Full gate set and final verification [NOT STARTED]

**Goal**: Close the task on the complete gate set, with the residue claim re-verified end to end
rather than inherited from the research report.

**Tasks**:

- [ ] `lake build` and `lake build BimodalTest`, both exiting 0 with zero `error:` and zero
      `warning:` lines.
- [ ] Every modified `FormalSystem/**` module silent under
      `lake env lean -D weak.linter.mathlibStandardSet=true -D autoImplicit=false`.
- [ ] `grep -rn sorry` over every modified Lean file returns nothing, and `#print axioms` on the
      new public results reports no `sorryAx`.
- [ ] `bash scripts/check-module-invariants.sh` passes in full, the new manifest-freshness
      assertion included, and again under `--no-build`.
- [ ] `bash scripts/check-paper-definitions.sh` reports no pinned anchor moved and
      `docs/reference/paper-definitions-of-record.md` is unmodified.
- [ ] `bash scripts/check-metalogic-cycles.sh`, `bash scripts/check-copyright-headers.sh`,
      `bash scripts/readme-lint.sh` and `bash scripts/check-evidence-probes.sh` all exit 0.
- [ ] Re-run the exporter and confirm the committed manifest is byte-current.
- [ ] Confirm the diff touches only the files this plan names, plus
      `specs/681_narrow_transcription_audit_surface/**` — and nothing belonging to a sibling task
      sharing this tree.
- [ ] Write the summary, stating: the residue count and that it did not change, the axiom burden
      that did, which independence witnesses landed, and any exclusion recorded in Phase 4.

**Timing**: 1 hour

**Depends on**: 7, 8

**Verification Tier**: full

**Files to modify**:

- `specs/681_narrow_transcription_audit_surface/summaries/01_narrow-transcription-audit-surface-summary.md`

**Verification**:

- Every gate above exits 0, with its output recorded in the summary rather than asserted
- The summary states the inspection-only residue as a number and names the three rows the
  consuming document's audit does not reach

---

## Lean Challenge Statements

```lean
import FormalSystem.Semantics.TaskFrame
import FormalSystem.Semantics.ShiftSet
import Mathlib.Data.Int.SuccPred

namespace FormalSystem.Semantics

namespace ShiftSet

/-- *Limit*, transcribed over a shift action, is a **theorem** over a discrete duration order:
the zero-shift law alone forces a point lying in every arbitrarily small shift-neighbourhood of
`w` to be `w`. Bounded by `ShiftSet.SepNotDerivable.sep_not_derivable`, which refutes the same
shape over a dense duration order, so the `sep` field survives. Paper: `def:frame#Limit`. -/
theorem sep_of_succOrder {D : TemporalOrder} [SuccOrder (↑D : Type)] [NoMaxOrder (↑D : Type)]
    {Ω : Type} (sh : Ω → ↑D → Ω) (hz : ∀ w, sh w 0 = w) :
    ∀ w u, (∀ x : ↑D, 0 < x → ∃ y, |y| < x ∧ u = sh w y) → u = w := sorry

/-- A shift set over `intOrder` from the action data alone: the separation field is supplied by
`sep_of_succOrder` rather than by hand, so a certified construction over discrete time carries
three axioms in place of four. -/
def ofIntAction (Carrier : Type) (carrier_nonempty : Nonempty Carrier)
    (sh : Carrier → ↑intOrder → Carrier) (sh_zero : ∀ w, sh w 0 = w)
    (sh_add : ∀ w a b, sh (sh w a) b = sh w (a + b))
    (A : FormalSystem.Syntax.Atom → Carrier → Prop) : ShiftSet intOrder := sorry

end ShiftSet

namespace FrameConstraintIndependence

/-- The empty relation on a two-point carrier: *Seriality* fails, the other three hold. -/
def emptyRel : Bool → ℤ → Bool → Prop := sorry

theorem emptyRel_compositional : TaskFrame.Compositional emptyRel := sorry

theorem emptyRel_limit : TaskFrame.Limit emptyRel := sorry

theorem emptyRel_saturation : TaskFrame.Saturation emptyRel := sorry

theorem emptyRel_not_serial : ¬ TaskFrame.Serial emptyRel := sorry

/-- The total relation on a two-point carrier: *Limit* fails, the other three hold. The carrier
is `Bool` rather than `Unit` precisely so that *Limit* can fail — over a subsingleton it holds by
`TaskFrame.limit_of_subsingleton`, which is why `FrameOver.trivialFrame` is not this witness. -/
def totalRel : Bool → ℤ → Bool → Prop := sorry

theorem totalRel_compositional : TaskFrame.Compositional totalRel := sorry

theorem totalRel_serial : TaskFrame.Serial totalRel := sorry

theorem totalRel_saturation : TaskFrame.Saturation totalRel := sorry

theorem totalRel_not_limit : ¬ TaskFrame.Limit totalRel := sorry

/-- Upward rays on the integers: a positive duration reaches every later state. *Saturation*
fails — the fibres of a positive duration form a `⊇`-directed family of nonempty upward rays with
empty intersection — while the other three hold. The failure is a *recession* failure, not a
completeness failure; contrast `StateTopology.RationalTwoOrigins.not_rel_saturation`. -/
def rayRel : ℤ → ℤ → ℤ → Prop := sorry

theorem rayRel_compositional : TaskFrame.Compositional rayRel := sorry

theorem rayRel_serial : TaskFrame.Serial rayRel := sorry

theorem rayRel_limit : TaskFrame.Limit rayRel := sorry

theorem rayRel_not_saturation : ¬ TaskFrame.Saturation rayRel := sorry

/-- A non-additive reindexing of durations: the identity except at `1`. Non-additivity at a
single point is the whole content of the *Compositionality* refutation below. -/
def drift : ℤ → ℤ := sorry

/-- A functional but non-additive shift: `w ⇒_x u` iff `u = w + drift x`. *Compositionality*
fails; the other three are free from functionality plus surjectivity plus discreteness, which is
why the witness is functional on purpose. -/
def driftRel : ℤ → ℤ → ℤ → Prop := sorry

theorem driftRel_serial : TaskFrame.Serial driftRel := sorry

theorem driftRel_limit : TaskFrame.Limit driftRel := sorry

theorem driftRel_saturation : TaskFrame.Saturation driftRel := sorry

theorem driftRel_not_compositional : ¬ TaskFrame.Compositional driftRel := sorry

/-- **Each of `def:frame`'s four constraints is independent of the other three**, over `ℤ` — the
duration type `intOrder` is, reducibly and by `rfl`, so this is independence over the very time
structure the certificate uses. Consequence for the transcription audit: the four-clause frame
condition cannot be compressed to three, so that row of the audit is provably irreducible. This
bounds how far the *clause count* can fall; it says nothing about how many *definitions* a reader
must inspect, which is a different surface. -/
theorem constraints_pairwise_independent :
    (∃ (W : Type) (R : W → ℤ → W → Prop),
        TaskFrame.Compositional R ∧ TaskFrame.Limit R ∧ TaskFrame.Saturation R ∧
          ¬ TaskFrame.Serial R) ∧
    (∃ (W : Type) (R : W → ℤ → W → Prop),
        TaskFrame.Compositional R ∧ TaskFrame.Serial R ∧ TaskFrame.Saturation R ∧
          ¬ TaskFrame.Limit R) ∧
    (∃ (W : Type) (R : W → ℤ → W → Prop),
        TaskFrame.Compositional R ∧ TaskFrame.Serial R ∧ TaskFrame.Limit R ∧
          ¬ TaskFrame.Saturation R) ∧
    (∃ (W : Type) (R : W → ℤ → W → Prop),
        TaskFrame.Serial R ∧ TaskFrame.Limit R ∧ TaskFrame.Saturation R ∧
          ¬ TaskFrame.Compositional R) := sorry

end FrameConstraintIndependence

end FormalSystem.Semantics
```

## Testing & Validation

- [ ] `lake build` and `lake build BimodalTest` exit 0 with zero `error:` and zero `warning:`
      lines, at every phase boundary.
- [ ] Every modified `FormalSystem/**` module is silent under
      `lake env lean -D weak.linter.mathlibStandardSet=true -D autoImplicit=false` — the package's
      own linter set, which plain `lake env lean` does not apply.
- [ ] Zero `sorry` in every modified Lean file, and `#print axioms` on
      `constraints_pairwise_independent`, `sep_of_succOrder` and
      `WitnessFamily.std_sat_ztime` reports no `sorryAx`.
- [ ] `bash scripts/check-module-invariants.sh` passes in full, including C8, C14, C15, C20, C24,
      C33, C34a/C34b and the new manifest-freshness assertion; and again under `--no-build`.
- [ ] `bash scripts/check-paper-definitions.sh` reports no pinned anchor moved, with
      `docs/reference/paper-definitions-of-record.md` unmodified.
- [ ] `bash scripts/check-metalogic-cycles.sh`, `bash scripts/check-copyright-headers.sh`,
      `bash scripts/readme-lint.sh`, `bash scripts/readme-lint.sh docs` and
      `bash scripts/check-evidence-probes.sh` all exit 0.
- [ ] `scripts/export-lean-citations.py` runs to a byte-identical manifest on a second run, every
      seeded name resolving; a deliberately misspelled name produces a named error and a non-zero
      exit.
- [ ] The new invariant's negative test fails loudly and names the moved declaration; the restored
      state passes.
- [ ] `docs/reference/transcription-audit-surface.md` contains zero `file.lean:NNN` citations and
      every declaration it names resolves in the tree.
- [ ] `git diff` across the task's commits touches only:
      `FormalSystem/Semantics/ShiftSet.lean`,
      `FormalSystem/Semantics/FrameConstraintIndependence.lean`,
      `FormalSystem/Semantics.lean`, `FormalSystem.lean`,
      `FormalSystem/Semantics/README.md`,
      `FormalSystem/Metalogic/Decidability/WitnessFamily/Std.lean`,
      `docs/theorem-index.md`, `docs/reference/transcription-audit-surface.md`,
      `docs/reference/README.md`, `docs/development/MODULE_INVARIANTS.md`,
      `scripts/check-module-invariants.sh`, `scripts/export-lean-citations.py`,
      `scripts/lean-citation-manifest.json`, the exporter's seed list, `scripts/README.md`, and
      `specs/681_narrow_transcription_audit_surface/**`.

## Artifacts & Outputs

- `specs/681_narrow_transcription_audit_surface/plans/01_narrow-transcription-audit-surface.md`
  (this file)
- `specs/681_narrow_transcription_audit_surface/summaries/01_narrow-transcription-audit-surface-summary.md`
- `FormalSystem/Semantics/FrameConstraintIndependence.lean` — new module: four witness relations,
  sixteen theorems, one aggregate independence statement
- `FormalSystem/Semantics/ShiftSet.lean` — `sep_of_succOrder`, `ofIntAction`, corrected
  axiom-count paragraph
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Std.lean` — the standard shift set built
  through the smart constructor, hand separation proof deleted
- `scripts/export-lean-citations.py` + `scripts/lean-citation-manifest.json` + the seed name list
  — the generated line-numbered view that replaces a hand-maintained cross-repository table
- `scripts/check-module-invariants.sh` — the manifest-freshness assertion
- `docs/reference/transcription-audit-surface.md` — the name-keyed record of the inspection-only
  residue, the two-surface distinction, the corrections the consuming table owes, and the two
  closed questions
- `docs/theorem-index.md`, `docs/reference/README.md`, `docs/development/MODULE_INVARIANTS.md`,
  `FormalSystem/Semantics/README.md`, `FormalSystem/Semantics.lean`, `FormalSystem.lean` —
  record and wiring updates

## Rollback/Contingency

Every phase commits only at a green sub-step, so the cheapest rollback is always
`git revert` of the phase's own commits — no working-tree discard is needed and none should be
attempted while sibling tasks share this tree.

- **Phase 1 regresses the certificate path**: revert the `Std.lean` commit alone. The new theorem
  and constructor in `ShiftSet.lean` are additive and harmless on their own, so the conversion can
  be retried later without re-deriving anything.
- **Phase 4's witness resists**: do not roll back. Close the phase
  `[COMPLETED WITH EXCLUSIONS]` with a `#### Reasoned Exclusions` record, weaken Phase 5's
  aggregate statement to the three witnesses that landed, and say so in Phase 8's record and the
  summary. Three independence results plus a named gap is the honest outcome; a `sorry` is not.
- **The new invariant proves too noisy**: leave the exporter and manifest in place and gate the
  assertion behind an `ENFORCE_` variable defaulting to `0`, in the shape C20's own tiers already
  use, rather than deleting the check. The manifest is useful even ungated.
- **A genuine whole-tree rollback is ever required**: take a durable checkpoint first with
  `bash .claude/scripts/git-snapshot.sh 681 --allow-out-of-scope`, per
  `context/contracts/recovery.md`'s rollback rung. Note that this default mode reverts; it is for
  that deliberate scenario only, and never as a routine start-of-phase precaution — an ordinary
  defensive checkpoint uses `--no-revert`.
