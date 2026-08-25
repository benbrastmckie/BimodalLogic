# Implementation Summary: Immediate documentation-correction pass

- **Task**: 472 - Immediate documentation correction pass
- **Plan**: specs/472_immediate_documentation_correction_pass/plans/01_documentation-correction-pass.md
- **Research**: specs/472_immediate_documentation_correction_pass/reports/01_documentation-correction-verification.md
- **Type**: lean4
- **Outcome**: all ten phases completed
- **Session**: sess_1787618565_717c84

## What this pass did

Corrected the nine verified false/stale documentation claims (a)-(i) plus the additional in-scope
defects found in the same blocks. Prose and docstrings only: no declaration, signature, import, or
tactic was changed, nothing was proved, and no `sorry` was closed or introduced.

## Baseline (Phase 1)

Reconfirmed at the HEAD this pass ran against, and reproduced the research report's baseline
exactly:

- `lake build` exit 0 (2462 jobs); `lake build BimodalTest` exit 0 (2512 jobs).
- `check-module-invariants.sh --no-build` ALL CHECKS PASSED.
- C3: exactly one structural `sorry`, in `theorem countermodel_discrete`
  (`FormalSystem/Metalogic/WeakCanonical/Transfer.lean`), asserted by content.
- C2 axiom baseline (recorded verbatim from `scripts/check-module-invariants.sh`):
  - `BXCanonical.completeness` -> `[propext, sorryAx, Classical.choice, Quot.sound]`
  - `BXCanonical.completeness_dense` -> `[propext, Classical.choice, Quot.sound]`
  - `BXCanonical.completeness_discrete` -> `[propext, Classical.choice, Quot.sound]`
  - `BXCanonical.Chronicle.countermodel_dense` -> `[propext, Classical.choice, Quot.sound]`
- All six ABSENT symbols returned zero declaration hits; all five ABSENT files did not exist.

**No divergence from the report's baseline was found.**

## Per-item record

### (a) `FormalSystem/Metalogic/Decidability.lean` — `## Status` block

The three-bullet block attributed Hilbert-system results to the tableau engine. Replaced with a
block that names the subject and the theorem for each claim:

- Proof-system soundness is `Metalogic.soundness` (`Γ ⊢[Base] φ → Γ ⊨ φ`), with `decide_sound` the
  empty-context corollary the `.valid` witness consumes.
- Proof-system completeness distinguishes `completeness_dense` / `completeness_discrete` (proved
  **and** sorry-free) from `completeness` at `.Base` (proved, `sorryAx`-dependent), citing C2 as the
  authority. "BFMCS" attributed to `Metalogic/Bundle/`, not to `Decidability/`.
- This directory's own procedure: `ruleSound_of_mem_allRulesForFC` landed; `valid_iff_allClosed`,
  the `isValid φ fc = true ↔ ⊨ φ` biconditional, and the `Decidable (⊨ φ)` instances **open**, with
  the pointer to `Correctness.lean`'s "Retired as vacuous" section.
- **Extra defect**: "Proof extraction: Partial (axiom instances only)" -> "Partial", with the five
  strategies named (`tryAxiomProof`, `matchDerived`, the closure-based `.axiomNeg` filter,
  `buildCompositionalProof`, `enhancedSearch`). Strategy count re-derived from `extractProof`'s body
  before writing "five"; it is five.

### (b) `FormalSystem/Metalogic/Decidability/Verified/README.md` — Layout table

Rebuilt against the live tree. Re-derived at implementation time: **21** live `.lean` files, **all
21** imported by the `Decidability.lean` aggregator (checked file-by-file). Two-value vocabulary:

- `landed` — path exists AND is imported by the aggregator (21 rows).
- `not built` — no such path exists (5 rows, under their own subheading).

Both values are mechanically checkable and neither asserts schedule or intent; `planned` and
`deferred` are gone. Contents column lifted from the aggregator's own module docstring, except
`Termination/MintBound.lean`, which the aggregator docstring does not describe — its Contents cell
was written from that file's own module docstring instead. `Bridge/Omega.lean`'s successor
(`Bridge/RegionFrame.lean`) is named in the Contents column rather than given a third status. The
false "a path exists here only once its contents do" sentence is gone. Added a note that
`Decidable.lean`'s `landed` marker is a claim about the path, not about what the theorem names
inside it prove. Added a "Related Documentation" section and a `Last verified` stamp.

### (c) `FormalSystem/Metalogic/Decidability/FMP/README.md` — Key Results

- Deleted `filtration_is_finite` and `truth_preserved_under_filtration` (zero occurrences in the
  tree).
- Replaced with verified-present results, each with its file: `fmp_contrapositive`,
  `mcs_finite_model_property`, `assignmentSpace_card`, `filtered_world_bound`, `fmp_size_bound`
  (`FMP.lean`); `FilteredWorld.finite`, `filteredCharacteristicSet_injective` (`FiniteModel.lean`);
  `filtration_lemma_membership`, `filtration_imp_forward`, `filtration_box_forward`,
  `filtration_lemma_bot` (`TruthPreservation.lean`); `exists_lt_iter_of_card_le`,
  `exists_bounded_iter` (`Periodicity.lean`, kept verbatim).
- Stated explicitly that the four `filtration_*` theorems are **MCS membership** facts, not
  `TruthAt` facts, making the file's existing "about MCS membership, not about truth" section
  checkable.
- **Kept** the zero-`TruthAt` claim unchanged (true of the code; the single grep hit is the
  self-referential sentence in `FMP.lean` prose) and the `refinedFilteredTaskRel` note.
- **Extra defect**: Lines column replaced with a Decls column, re-derived at implementation time
  with the plan's grep: ClosureMCS 16, Filtration 29, FiniteModel 13, FMP 10, Periodicity 7,
  TruthPreservation 16. The command that reproduces them is stated in the file.
- **Extra defect**: Dependencies section's pre-rename `Bimodal.*` paths replaced with the live
  `FormalSystem.*` paths, re-derived from the directory's actual imports and importers (which brings
  them under C5's guard).
- **Extra defect**: stale `Last verified` footer refreshed.

### (d) `FormalSystem/Metalogic/Decidability/DecisionProcedure.lean` — `decideAuto`

Replaced "this ensures termination for all formulas" with what is actually guaranteed:

- `decideAuto` terminates because it is a total function at a finite fuel figure; `.fuelExhausted`
  is one of `DecisionResult`'s four constructors and no theorem rules it out.
- What is bounded, with all three hypothesis families named:
  `expandBranchWithFuel_isSome_of_stock` (no splitting via `NoSplit P fc`, confined stock `C` and
  label set `L`, fuel `> 2 * C.card * L.card`, and `branchesUsed + fuel ≤ maxBranches`), derived
  from `expandBranchWithFuel_isSome_of_noSplit`.
- `soundFuel` is a capped runtime default `min (n * 2 ^ n) 100000`, dominated by `soundFuel'`
  (`soundFuel_le_soundFuel'`), which is itself the single-world figure only (`chain_le_soundFuel'`
  needs `hL`, not dischargeable in general); `chain_le_worlds_bounded` / `worldFuel'` is the figure
  that takes the world dimension as a dimension.
- Subset blocking kept as a **measured** behaviour with its witness named (`buildTableau
  ((G p) → □(G p)) n .Base` is `none` for every `n ≤ 24`, `hasOpen` for every `n ≥ 25`).
- `buildTableau_isSome` is not cited anywhere.

### (e) `FormalSystem/Metalogic/Decidability/Verified/Decidable.lean`

Re-derived at implementation time: **36** `ruleSound_*` declarations, of which 2 are helpers
(`ruleSound_base_mono`, `ruleSound_of_mem_allRulesForFC`), giving **34** per-rule instances. Split
by carrier, re-derived by grep: **27** at `carrierBase`, **1** at `carrierDense` (`densityRule`),
**3** at `carrierDiscrete`, **3** at `carrierDedekind`. These match the report's figures exactly.

- `## Status` rewritten as a landed/open split, listing the 34 instances by carrier plus the 7.2
  assembly, all sorry-free; the "not landed" half lifted from `ruleSound_of_mem_allRulesForFC`'s own
  docstring (`valid_iff_allClosed`; `serialityRule` and `timeLinearity`, stages 2 and 3 of
  `expandOnce`).
- The "blocked on a defect in `RuleSound`'s own statement" paragraph is retained as a past-tense
  record with the closure noted, per the file's own "read in the past tense" convention.
- **Extra defect**: the section header ``## `untlNeg` and `snceNeg` — BLOCKED, two independent
  engine defects`` retitled to "the three engine defects, and how each was closed", and its status
  paragraphs converted to past tense. `ruleSound_untlNeg` and `ruleSound_snceNeg` are proved earlier
  in the same file; the resolution was retirement of the PASSIVE arms, which the file records at
  "`untlNeg` and `snceNeg` — provable once the PASSIVE arms are retired" and in
  `exists_gt_not_untl_disj`'s docstring.
- **All counterexample material preserved verbatim**: the `ℤ` Defect-1 counterexample, the
  `{1/n}` retraction, the formalization trap, and the PASSIVE-arm refutation model. Only claims
  about *current* status were changed.

### (f) `FormalSystem/Metalogic/WeakCanonical.lean`

Re-ran the C3-shaped structural-sorry scan over `FormalSystem/Metalogic/WeakCanonical/` (Boneyard
excluded): exactly one hit, in `Transfer.lean`.

- The five "documented sorries" bullets deleted (including the one naming `chronicle_is_good`, which
  is not a declaration anywhere in the tree).
- Replaced with the grounded statement: the subtree carries exactly one structural `sorry`,
  `countermodel_discrete` in `WeakCanonical/Transfer.lean`, asserted by C3 **by content** — no line
  number recorded.
- Noted that `completeness_discrete` routes around it via `countermodel_discrete_reynolds_v2`
  (`IntegerModel/ReynoldsBridge.lean`) and is proved *and* sorry-free per C2, versus
  `completeness` at `.Base` which is proved but `sorryAx`-dependent.
- **Extra defect**: architecture line 2 ("atom/bot/imp proved, rest sorried") corrected —
  `G_backward_mcs` and `H_backward_mcs` exist in `TruthLemma.lean` and the file has no `sorry`.
- **Extra defect**: architecture line 7 ("Table: ... (deferred)") corrected — `table`,
  `table_depth_bound`, `TemporalTruth` and `table_correctness` are all landed in `Table.lean`
  (verified by declaration grep).
- **Extra defect**: architecture line 8's `chronicle_is_good` replaced with
  `countermodel_discrete_reynolds_v2`.
- **Extra defect**: the interim-fallback paragraph deleted (the chronicle chain is archived, as the
  same docstring says eight lines earlier, and there are no Phase 3-5 sorries left).
- `## Main Export` left byte-identical.

### (g) `FormalSystem/Metalogic/WeakCanonical/RealModel/ShuffleReal.lean`

Read both declarations before writing: `doets_lemma_1_5`'s body is
`kEquiv_orderedSum_of_kEquiv_colour k m m' hcol` (a term, not a `sorry`), and
`kEquiv_shuffle_shuffleReal`'s signature takes `(k) (N) (hγ) (hσ)` with no `hcol`.

- "stated but not proved ... carried as a documented strategic `sorry`" replaced with:
  `doets_lemma_1_5` is proved, via `kEquiv_orderedSum_of_kEquiv_colour` (`MixedSum.lean`), with
  `BackAndForth.lean`'s `BackForth` / `kEquiv_iff_backForth` and `MixedSum.lean`'s `Mixed` /
  `backForth_of_mixed` supplying the engine (all four verified present).
- **Extra defect**: the second paragraph corrected — the coloured-index `≡ₖ` fact is proved by
  `kEquiv_colourStructure` (`ColourOrders.lean`), and the `hcol` hypothesis is gone.
- **Extra defect**: the trailing "The only thing this theorem is still conditional on is
  `doets_lemma_1_5` itself" sentence deleted.
- Stated that the module is sorry-free and unconditional, anchored to C3.
- **Extra defect (beyond the plan's list)**: the nonexistent symbol `sum_nf_agree` was cited in the
  rewritten passage (only `sum_nf_agree_sentence`, private, exists); the citation was dropped in
  favour of `doets_lemma_1_4`.
- Doets/Reynolds provenance prose kept.

### (h) `FormalSystem/Metalogic/Soundness.lean`

Re-derived the constructor list from `ProofSystem/Derivation.lean`: exactly seven (`axiom`,
`assumption`, `modus_ponens`, `necessitation`, `temporal_necessitation`, `temporal_duality`,
`weakening`).

- Numbered list item 6 ("IRR rule: Sound by construction (see IRRSoundness.lean)") deleted, and the
  list rewritten to enumerate the seven constructors the induction actually cases on — which also
  restored the missing `assumption` case.
- `[IRRSoundness.lean](./IRRSoundness.lean)` deleted from `## References`.
- The three `irr_sound_dense_at_domain` prose notes rewritten. A **fourth** stale IRR site was found
  and fixed (`soundness_dense`'s docstring, "Note on IRR rule"), which the plan's count of three did
  not include.
- **Extra defect**: the same block's "Non-domain case: a known semantic gap (sorried)" claim was
  also false — `soundness_dense_valid` is sorry-free — and was removed with the surrounding note.
- **Extra defect**: `[architecture.md](../../../docs/user-guide/architecture.md)` corrected to
  `../../docs/user-guide/architecture.md`; verified by `test -f` from `FormalSystem/Metalogic/`.
- "All soundness theorems are sorry-free" and the three `(sorry-free)` annotations left untouched.

### (i) `FormalSystem/Metalogic/WeakCanonical/PriorExpressivenessDense.lean`

- The "carries this module's only `sorry`" bullet replaced: the module is sorry-free (C3), and
  `kampFaithfulExpressiveCompleteness_open` is a retained alias for
  `kampFaithfulExpressiveCompleteness` at the same type with no weakening, contributing no `sorryAx`
  downstream.
- Stale site 1: the `KampFaithfulExpressiveCompleteness` bullet no longer says "stated as a type
  rather than proved"; the four sorry-free rungs are named (`Kamp.kampArm_zeta_faithful`,
  `Kamp.aggOdPopFold_iff_faithful`, the `Kamp/NfMultiAnchorBridge/` bridge and trichotomy files, and
  `Kamp/KampPriorFaithful.lean` — all verified present).
- Stale site 2: "**Rests on one open obligation**" replaced with "Unconditional and sorry-free".
- Stale site 3: `uSExpressivelyCompleteOverDensePrior_at_denseWindow`'s docstring re-tensed; the
  parametric-in-`H` form is now described as the stronger statement rather than as honesty about an
  open gap.
- The Reynolds Theorem 3 pinning point is kept and strengthened: being **unconditional** is what
  makes it Theorem 3 outright rather than Theorem 3 modulo an obligation. Supporting citations kept
  (`semanticPriorU_not_implies_semanticPriorUZ` exhibiting `denseRayFlow`;
  `uSExpressivelyCompleteOverDensePrior_not_by_reuse`).
- All three `PriorDefsDense.lean:372` citations replaced with a symbol reference. The theorem is at
  line 373 — re-confirmed at implementation time.
- The section header "## The open obligation" retitled "## The obligation, stated".
- Line citations converted **only** inside rewritten passages, per the plan; the other 27 file-wide
  citations were left alone.

## Plan Deviations

- **Phase 5, extra correction (added)**: the section "The fresh-time producers' ordering obligation
  is not discharged by freshness alone" claimed both remedies were "escalated rather than taken".
  Remedy 2 *was* taken, in its membership form: `OrdWithin b ord` is a hypothesis of `RuleSound`
  (verified by reading `def RuleSound`). A closure note was added rather than deleting the record.
  This was not a plan task, but the Status-block rewrite points at that section as a past-tense
  record, and leaving a present-tense "not taken" claim there would have made the new pointer false.
- **Phase 7, extra correction (added)**: one further live-wrong line citation,
  `doets_lemma_1_4` (`OrderedSum.lean:41`), in `doets_lemma_1_5`'s own docstring — the theorem is at
  line 46. Converted to a symbol reference. Strictly this sits just outside the rewritten passage,
  but it is the same symbol the rewritten passage cites, and leaving the file self-inconsistent on
  one citation of one symbol was the worse outcome.
- **Phase 7, extra correction (added)**: the rewritten passage cited `sum_nf_agree`, which is not a
  declaration (only the private `sum_nf_agree_sentence` exists). Citation dropped.
- **Phase 8, count divergence from the plan**: the plan's Scope Hypothesis asserted three
  `irr_sound_dense_at_domain` prose sites. Those three were fixed, and a **fourth** stale IRR site
  ("Note on IRR rule" in `soundness_dense`'s docstring) was found by grepping for `IRR` rather than
  for the symbol name, and was fixed too.
- **Phase 3, source divergence**: the plan said to lift every Contents cell from `Decidability.lean`'s
  aggregator docstring, which the research report said covers all 21 files. It covers 20 —
  `Termination/MintBound.lean` has no bullet there. That one cell was written from MintBound's own
  module docstring instead.
- **No phase was skipped, deferred, or blocked.**

## Verification (Phase 10)

- `lake build` exit 0 (2464 jobs; the count is above Phase 1's 2462 because concurrent tasks added
  modules outside this `file_scope`, not because of anything here).
- `lake build BimodalTest` exit 0 (2514 jobs).
- `bash scripts/check-module-invariants.sh` — **ALL CHECKS PASSED** (B0, C1-C11). C2's four flagship
  axiom sets are byte-identical to Phase 1's recording, including the
  `completeness` / `completeness_dense` / `completeness_discrete` `sorryAx` distinction. C3 still
  reports the sole structural `sorry` in `theorem countermodel_discrete`.

**Note on transient failures during the gate.** Three runs during this pass reported
`error: no such file or directory (error code: 4294967294)` — one `lake build`, one
`lake build BimodalTest`, and one C6 entry (`BimodalTest.Metalogic.PeriodicExtensionAxiomTest`).
All three were races against concurrent `lake` invocations from other tasks running in the same
working tree; each passed on an immediate re-run with no intervening edit, and the flagged module
builds clean in isolation. None involved a file in this task's `file_scope`. The results recorded
above are the clean re-runs.
- Nonexistent-declaration sweep: every backticked identifier added by this pass across the nine
  files was extracted from `git diff` and resolved — as a declaration, as a `TableauRule` or
  `DerivationTree` constructor, as a filename or module path, as a bound variable, as a Lean builtin
  (`sorry`, `sorryAx`, `True`, `Unit`), or as a deliberate absence statement (`valid_iff_allClosed`,
  `validity_decidable`, `validity_has_decision_procedure`, and `Verified/README.md`'s five
  `not built` rows).
- Zero occurrences of `filtration_is_finite`, `truth_preserved_under_filtration`,
  `buildTableau_isSome`, `chronicle_is_good`, `irr_sound_dense_at_domain`, or `IRRSoundness` in any
  added line.
- Zero newly introduced `.lean:NNN` line-number citations in any added line; three live-wrong ones
  removed (`PriorDefsDense.lean:372` x3) plus one more (`OrderedSum.lean:41`).
- Zero task-number citations under `FormalSystem/` (C9).
- Diff confined to the nine `file_scope` files plus `specs/472_*` artifacts.

## Files Modified

- `FormalSystem/Metalogic/Decidability.lean`
- `FormalSystem/Metalogic/Decidability/DecisionProcedure.lean`
- `FormalSystem/Metalogic/Decidability/Verified/README.md`
- `FormalSystem/Metalogic/Decidability/Verified/Decidable.lean`
- `FormalSystem/Metalogic/Decidability/FMP/README.md`
- `FormalSystem/Metalogic/WeakCanonical.lean`
- `FormalSystem/Metalogic/WeakCanonical/RealModel/ShuffleReal.lean`
- `FormalSystem/Metalogic/Soundness.lean`
- `FormalSystem/Metalogic/WeakCanonical/PriorExpressivenessDense.lean`
- `specs/472_immediate_documentation_correction_pass/plans/01_documentation-correction-pass.md`
- `specs/472_immediate_documentation_correction_pass/summaries/01_documentation-correction-summary.md`

## Follow-Ups (recorded, not done — out of `file_scope`)

- `FMP/FMP.lean`'s module docstring lists `finite_model_property` under "Main Results"; no such
  declaration exists (the theorem is `mcs_finite_model_property`). Same defect class as item (c).
- `NEquivalence.lean` carries the comment "sum_nf_agree, which has 4 remaining sorries"; C3 says
  there are none, and `sum_nf_agree` is not a declaration.
- Broken relative doc links inside `.lean` docstrings are invisible to C5, which lints markdown
  only. The `architecture.md` depth error fixed under item (h) is one instance; a C5 extension
  covering `.lean` docstring links would catch the class.
- `PriorExpressivenessDense.lean` still carries the other 27 line-number citations, all currently
  resolving. A repo-wide line-citation lint would retire the failure mode outright.
