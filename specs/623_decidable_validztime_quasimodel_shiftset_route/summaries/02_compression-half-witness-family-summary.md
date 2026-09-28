# Implementation Summary: Task #623

- **Task**: 623 - Decidable `ValidZTime` via the quasimodel / ShiftSet witness-family route (the completeness/compression half)
- **Status**: [COMPLETED]
- **Started**: 2026-09-28T11:20:54-07:00
- **Completed**: 2026-09-28T12:05:00-07:00
- **Effort**: ~45 minutes wall clock (plan estimate: 63 hours)
- **Dependencies**: 534, 645, 665, 680, 688 — all complete
- **Artifacts**: plans/02_compression-half-witness-family.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

The completeness (compression) direction of the witness-family route is landed, and with it
`Decidable (ValidZTime φ)`. Every ℤ-time countermodel of `φ` now provably compresses to a
`WitnessFamily [] [φ]` whose three lasso segments are bounded by `compressionBound [] [φ]`, whose
box guess has the canonical enumerable shape `fun χ => decide (χ ∈ S)`, and which is a member of
the computable candidate list `cands φ`. Composed with the already-landed soundness half
(`WitnessFamily.refutes_of_certifies`, `decidableCertifies`), this gives an unconditional decision
procedure, measured at `[propext, Classical.choice, Quot.sound]` with zero `sorry`.

All twelve plan phases are complete. Nothing in the soundness half was redefined or re-proved.

## What Changed

New subdirectory `FormalSystem/Metalogic/Decidability/WitnessFamily/Compression/` (7 Lean modules
+ README, ~1,900 lines):

- `Compression/Types.lean` — `typeAtM` (the presentation-free type of a position of an arbitrary
  `FrameOver intOrder` model), `mem_typeAtM`, `typeAtM_subset`, `LocalCoherentSeqLab`,
  `FulfillingSeqLab`, `typeAtM_localCoherentSeqLab`, `typeAtM_fulfillingSeqLab`
- `Compression/Cycle.lean` — `TypeState`, `typeOfT`, `natCard_typeState`, `SeqStepT`,
  `iter_seqStepT`, `exists_iterT_lt_card`, `joinPathT` + its three lemmas,
  `exists_recurring_typeState`, `untlEventT`/`snceEventT`, `cycleBoundC`, `exists_base_cycleT`,
  `exists_good_cycle_of_typeSeq`
- `Compression/Fulfil.lean` — `untl_propagates_to_endC`, `snce_propagates_to_startC`,
  `lab_add_mul_nfC`, `lab_sub_mul_nbC`, `fulfillingSeqLab_of_good_cycles`
- `Compression/Extract.lean` — `getD_mapC`, `getD_range_mapC`, `typeOfT_unrollOf`, `reduce_emodC`,
  `emod_succ_congrC`, `periodic_rel_of_windowC`, `readout_backC`/`readout_midC`/`readout_fwdC`,
  `localCoherentSeqLab_of_edges`, `midBoundC`, `compressionBound`,
  `exists_labelledLasso_of_history_realized`, `exists_labelledLasso_of_history`,
  `localCoherentSeqLab_congr_bx`
- `Compression/Family.lean` — `Formula.boxArg?`, `boxedPart`, `mem_boxedPart`,
  `boxedPart_subset_closureOf`, `closureOf_nil_singleton`, `semanticConsequenceIn_nil_iff`,
  `exists_witnessFamily_of_not_validZTime`
- `Compression/Enumerate.lean` — `ListEnumC.ofLen`/`upTo` + four lemmas, `closureSubsetsOf`,
  `rawLabelledLassos`, `IsLabelledLasso`, `boundedLassos`, `mem_boundedLassos`,
  `boundedLassos_sound`, `cands`, `mem_cands_of_bounded`
- `Compression/Assembly.lean` — `validZTime_iff_noCertifiedCandidate`,
  `Compression.decidableValidZTime`, `decidableSemanticConsequenceNil`
- `Compression/README.md` — route, [GKWZ] terminology map, the duplication record with its
  retirement trigger, the widened `BiLasso/` dependency, and the grid-sweep/non-monotonicity note

Existing files modified:

- `FormalSystem.lean` — seven import lines, alphabetical
- `FormalSystem/Metalogic/Decidability/WitnessFamily.lean` — seven `Compression.*` imports, a
  `Compression/` submodule row, and the "completeness half is not here" sentence corrected
- `FormalSystem/Metalogic/Decidability/WitnessFamily/README.md` — the section heading and opening
  paragraph corrected, a `Compression/` module table added, `BiLasso/Unfold.lean` recorded in
  Dependencies
- `docs/theorem-index.md` — three rows in `### Decidability`

## Decisions

- **The compression runs on the type sequence, never the state sequence.** `typeAtM` is stated at
  an arbitrary `FrameOver intOrder` model with no presentation, which is what
  `WitnessFamily.LocalCoherentLab` (atom clause dropped) makes possible and what
  `validIn_iff_recurrenceFree` makes necessary.
- **The combinatorial core was transcribed, not instantiated.** Importing `BiLasso/GoodCycle.lean`
  would break the directory's stated dependency invariant; instantiating it at a one-state dummy
  `IntPresentation` would thread a semantically empty `P` through every statement and restrict the
  closure to `subformulaClosure φ`. Every new module records the duplication and the same named
  retirement trigger the rest of `WitnessFamily/` uses.
- **The lassos are built against the truth oracle and the family carries the canonical guess.**
  `exists_labelledLasso_of_history` demands an *unguarded* `hbx`, which the canonical
  `fun χ => decide (χ ∈ S)` cannot satisfy (it is false at globally true formulas outside the
  closure). So compression builds with `fun χ => decide (∀ σ v, TruthAt M σ v χ)` and transports
  local coherence onto the canonical guess via `localCoherentSeqLab_congr_bx`, the two agreeing
  exactly on the guarded `χ`. This is what makes the family enumerable.
- **`ListEnum` was transcribed as `ListEnumC`**, not imported (the plan left this choice to
  implementation time). Importing `BiLasso/Enumerate.lean` would pull the whole presentation layer
  in; the distinct namespace lets both copies coexist.

## Plan Deviations

- **Phase 2 / Phase 3** altered: written as a single creation of `Cycle.lean` (they share one
  file). Every declaration named by both phases is present and both gates were discharged by the
  same green scoped build.
- **Phase 7** altered: the pinned `exists_labelledLasso_of_history` signature is preserved
  verbatim and proved as a corollary of a **strengthened**
  `exists_labelledLasso_of_history_realized`, which additionally exports
  `∀ j, ∃ u, Λ.lab j = typeAtM M Γ Del τ u`. Phase 8's prose states `BoxFaithful`'s forward
  direction as "`S`'s defining property carried through `typeAtM`", which cannot be derived from
  `LocalCoherentSeqLab` alone — the Hintikka clauses contain no reflexivity clause linking
  `□χ ∈ lab t` to `χ ∈ lab t`. Adding a conjunct to the conclusion strengthens the theorem;
  nothing pinned was weakened.
- **Phase 10** altered: `closureSubsetsOf` is indexed by `φ : Formula` rather than by an abstract
  `C : Finset Formula`, for exactly the reason the plan's own bullet gives — `Finset.toList` is
  noncomputable, so an abstract `Finset` has no computable underlying list.
- **Phase 10** choice recorded: `ListEnum` transcribed as `ListEnumC` rather than imported.
- **Phase 11** altered: the decision procedure is declared as `Compression.decidableValidZTime`.
  `BiLasso/Assembly.lean` already declares
  `FormalSystem.Metalogic.Decidability.decidableValidZTime` (the `fmp`-conditional procedure) and
  a full build fails with `environment already contains …`. The plan's Non-Goals forbid editing
  `BiLasso/`, so the new, unconditional result takes a sub-namespace. Simple name, signature and
  `def`-not-`instance` status are unchanged; it is the only declaration in the subdirectory whose
  namespace differs.

## Verification

- Build: **Success** — full `lake build`, guard exit 0, zero `error:` lines over both captured
  streams, and every `Compression.*` module's `.olean` freshly built
- Sorry count: **0** (`lean-sorry-census.sh` over all four resolved source roots)
- Vacuous count: **1**, unchanged and pre-existing —
  `FormalSystem/Examples/TemporalStructures.lean:495`
  `theorem int_domain_universal (t : Int) : intTimeHistory.domain t := trivial`. Nothing in
  `Compression/` matches the pattern.
- Axiom count: **14 `axiom` declarations**, unchanged; `Compression/` declares none
- `#print axioms` (via `lean_verify`): `Compression.decidableValidZTime`,
  `validZTime_iff_noCertifiedCandidate` and `exists_witnessFamily_of_not_validZTime` each measure
  exactly `[propext, Classical.choice, Quot.sound]`
- `cands` computes: it elaborated as a plain `def` returning data, which Lean rejects for a
  non-computable body
- Tests: N/A (no new test module; the invariant harness is the gate)
- `bash scripts/check-module-invariants.sh`: **does not exit 0.** Every gate this task can move
  passes — **C1** (`lake build` exits 0, and `lake build BimodalTest` exits 0), **C3** (structural
  `sorry` inventory is zero across `FormalSystem/` and `BimodalTools/`), **C4** (all 2,680 import
  lines resolve), **C15** (all 213 theorem-index rows carry their anchor). Two findings this task
  caused were found and fixed: C15 on the three new rows (`Paper: —` lines added at each
  declaration) and C5 on `FormalSystem.Metalogic.Decidability.Compression`
  (added to `scripts/module-invariants-allowlist.txt`, the sanctioned namespace-is-not-a-module
  exemption, with a documented reason). The four remaining failures are **not** this task's — see
  Follow-ups.
- Files verified: Yes

## Impacts

- `ValidZTime` is now decidable **unconditionally**. The previously landed
  `BiLasso/Assembly.lean` route reached `Decidable (ValidZTime φ)` only under an `fmp` hypothesis
  that `Probe476.fmp_false` refutes; this route has no such hypothesis.
- `WitnessFamily/`'s README claim that the completeness half "is not here" is now false and has
  been corrected; downstream readers should be pointed at `Compression/`.
- `compressionBound` is available to the consuming model checker, with the non-monotonicity
  correction recorded at three sites (`Extract.lean`, `Enumerate.lean`, `Compression/README.md`):
  a bound alone does not transfer to a consumer that folds `back`/`mid`/`fwd` by exact modulus —
  the grid must be swept.
- `WitnessFamily/`'s dependency on `../BiLasso/` is widened from `{Periodic.lean}` to
  `{Periodic.lean, Unfold.lean}`.

## Follow-ups

- **`check-module-invariants.sh` has four remaining failures, none of them this task's.** All are
  either sibling tasks' in-flight work on this shared working tree or pre-existing staleness:
  - **C16** (`env_linter` `simpNF`): three findings at `WitnessFamily/Sharing/Frame.lean:177` and
    `WitnessFamily/Sharing/Histories.lean:80`, all naming `SharingSkeleton`, which entered the
    tree in commit `2328f2c0e` ("task 690 phases 4-5"). `Compression/` contributes zero linter
    findings.
  - **C5**: one unresolved path, `FormalSystem.PlusLanguage.PlusFormula` at
    `WitnessFamily/Sharing/README.md:188` — task 690's file.
  - **C6**: two unreachable live modules, `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Closure.lean`
    and `FormalSystem/PlusLanguage/Subformulas.lean` — both task 690's, one of them still
    untracked.
  - **INV** (stale generated inventory in `README.md`, `FormalSystem/README.md`,
    `FormalSystem/Metalogic/README.md`, `FormalSystem/PlusLanguage/README.md`): **already stale
    before this task started.** At `d139659eb`, the commit immediately preceding this task's first,
    `FormalSystem/Metalogic/README.md` recorded 87 `Decidability/` modules against an actual 96.
    Regeneration is a whole-tree operation whose output currently mixes this task's 7 modules with
    three siblings' concurrent ones (and emits a `<!-- TODO: add description -->` placeholder for
    a sibling's untracked file), so it was deliberately **not** run here: `--emit-inventory` should
    be run once, by whoever closes out the tree, after 623/684/690 have all landed.
- **The plan's own Testing checklist is self-inconsistent** on the `BiLasso/` dependency: it asks
  that `WitnessFamily/` import nothing from `BiLasso/` except `Periodic.lean`, while Phase 1
  transcribes a spike that uses `truth_untl_succ`/`truth_snce_pred` and Phase 4 prescribes
  `Int.rightInduction`/`Int.leftInduction` — all four live in `BiLasso/Unfold.lean`. The
  dependency set is now `{Periodic.lean, Unfold.lean}`; both are directory-independent and
  presentation-free, and nothing imports `BiLasso/Basic.lean`, `Annotation.lean`, `Decide.lean` or
  `IntPresentation.lean`. Either the invariant should be restated as "nothing from the
  presentation layer", or `Unfold.lean`'s four lemmas should be relocated outside `BiLasso/`.
- **General finite-premise consequence** `SemanticConsequenceIn FrameClass.ZTime Γ σ` for
  non-empty `Γ` remains undecided: it needs a context-conjunction deduction theorem and the tree
  has no `Context.conj`/`bigConj`.
- **The two `Decidable`s are `def`s, not `instance`s.** A caller wanting instance resolution must
  `letI` them locally. Promoting either to a global instance is a deliberate, separate decision.
- `Compression/` declares two `@[simp]` lemmas beyond the two the plan sanctions
  (`typeOfT_default`, `Formula.boxArg?_box`) and two instances (`instInhabitedTypeState`,
  `instDecidableIsLabelledLasso`). All four are keyed on definitions introduced here and cannot
  fire on any pre-existing term, but they are recorded rather than hidden.

## References

- `specs/623_decidable_validztime_quasimodel_shiftset_route/plans/02_compression-half-witness-family.md`
- `specs/623_decidable_validztime_quasimodel_shiftset_route/reports/02_compression-half-witness-family-route.md`
- `specs/623_decidable_validztime_quasimodel_shiftset_route/reports/01_stability-scope-decidability-findings.md`
- `specs/623_decidable_validztime_quasimodel_shiftset_route/evidence/02_semantic-side-spike.lean`
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Compression/README.md`
- `FormalSystem/Metalogic/Decidability/BiLasso/GoodCycle.lean`,
  `BiLasso/Extraction.lean`, `BiLasso/Enumerate.lean`, `BiLasso/Assembly.lean` (transcription
  sources; none modified)
