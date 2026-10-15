# Implementation Summary: Task #791

- **Task**: 791 - Prove prop:archimedean in the generality the paper states it (UZ and Z1 fail over every non-Archimedean Discrete temporal order)
- **Status**: [COMPLETED]
- **Started**: 2026-10-14T21:00:00Z
- **Completed**: 2026-10-14T23:05:00Z
- **Effort**: ~2 hours
- **Dependencies**: Task 788 (complete, at HEAD); tasks 789, 790, 792 (complete, committed earlier in this batch)
- **Artifacts**: plans/01_uz-z1-fail-non-archimedean.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

`prop:archimedean` is now a theorem of this tree at the generality the paper states it: neither
`UZ` nor `Z1` is valid over *any* discrete temporal order that fails to be Archimedean. Both
countermodels live on `translationFrame D` over an arbitrary `(D : TemporalOrder)` carrying a
least strictly positive duration with `¬ Archimedean ↑D`, and both turn on one division of the
carrier — the times within finitely many unit steps of `0`, and those beyond every multiple of
the unit. Before this task the tree machine-checked the failure at one concrete carrier in one
neighbouring language and restated the general claim as prose in three docstrings without proving
it; all three now cite the theorems by name.

## What Changed

- `FormalSystem/Semantics/DurationClassification.lean` — `exists_gt_nsmul_of_not_archimedean`
  proved: a least positive `u` plus `¬ Archimedean D` yields a time beyond every `n • u`. This is
  the paper's step 1 and the only new order lemma the development needed; no Mathlib equivalent
  exists at a bare ordered abelian group.
- `FormalSystem/Semantics/Correspondence/DurationFrames.lean` — `translationFrame_isDiscrete`
  proved: the translation frame over a duration group with a least positive element satisfies
  `def:frame-properties`' bare Discrete clause.
- `FormalSystem/Metalogic/Independence/ArchimedeanSharpness.lean` — **created**, 381 lines,
  12 declarations plus two anonymous `example` shape pins:
  - `not_validOn_prior_UZ_nonArchimedean`, `not_validOn_z1_nonArchimedean` — the two frame-level
    refutations at the primary `IsLeast {z | 0 < z} u` hypothesis;
  - `not_validOn_prior_UZ_discrete_nonArchimedean`, `not_validOn_z1_discrete_nonArchimedean` —
    the same, from the paper's own `TaskFrame.IsDiscrete` clause;
  - `not_validOn_prior_UZ_succ_nonArchimedean`, `not_validOn_z1_succ_nonArchimedean` — the same,
    from a `[SuccOrder ↑D]` instance, via `isLeast_pos_succ_zero`;
  - `not_validOnFrameOver_prior_UZ_nonArchimedean`, `not_validOnFrameOver_z1_nonArchimedean` —
    `prop:archimedean`'s own `⊭_D` shape;
  - `lexZOrder`, `translationFrame_lexZ_not_isZTime`,
    `not_validOnFrames_isDiscrete_prior_UZ`, `not_validOnFrames_isDiscrete_z1` — the concrete
    carrier `ℤ ×ₗ ℤ`, the record that its translation frame is Discrete yet **not** `IsZTime`, and
    non-validity over the bare Regular-and-Discrete class.
- `FormalSystem/Metalogic/Independence.lean`, `FormalSystem/Metalogic/Independence/README.md` —
  the thirteenth result documented in both lists, with the count fixed in both.
- `FormalSystem/Metalogic/Independence/ZTimeSharpness.lean`,
  `FormalSystem/Metalogic/Conservativity.lean`, `FormalSystem/Semantics/FrameProperty.lean` — the
  three prose sites that restated the paper's general claim without proving it now cite the new
  theorems and the new module by name.
- `FormalSystem/Metalogic/Conservativity/Z1Countermodel.lean` — the disposition record (see
  Decisions); no proof change.
- `FormalSystem/ProofSystem/Axioms.lean`, `FormalSystem/Semantics/FrameClassValidity.lean`,
  `FormalSystem/Semantics/FrameProperty.lean`, `FormalSystem/Metalogic/Conservativity.lean`,
  `FormalSystem/Metalogic/Independence.lean`,
  `FormalSystem/Metalogic/Independence/StaticFrame.lean`,
  `FormalSystem/MinusLanguage/Axioms.lean` — the post-788 `Axiom.z1` drift cleared at 9
  occurrences across 7 files.
- `docs/reference/paper-definitions-of-record.md` — the `prop:archimedean` `KNOWN-ANCHORS` row no
  longer says the repository does not check the anchor. The row stays `LIVE-UNPINNED`; it was not
  promoted to a `MANIFEST` row and the whole-file sentinels were not re-pinned.
- `FormalSystem.lean`, `typst/generated/status.typ`, `scripts/lean-citation-manifest.json`, and
  the generated inventory blocks in six READMEs — regenerated from live source.

## Decisions

- **The primary hypothesis is `IsLeast {z | 0 < z} u`, not `[SuccOrder ↑D]`.** It is the paper's
  own "there is a least duration `1 > 0`" verbatim, is `Prop`-valued rather than data, and so
  unifies with a witness from any source. The dispatch's `SuccOrder` form is carried as a wrapper
  over it rather than as the primary binder.
- **Both formulas stay at `Formula.atom p`, never schematic in `φ`.** Forced, for the reason
  `ZTimeSharpness.lean` already records: `Axiom.prior_UZ ⊥` has an unsatisfiable antecedent and so
  is valid everywhere, which would falsify a `∀ φ` form.
- **A new module rather than an extension of `ZTimeSharpness.lean`.** That module's docstring
  explicitly disclaims the Archimedean story; honouring the disclaimer with a redirect is a
  smaller and more honest edit than rewriting its section, and the two modules now read as the two
  branches of the duration dichotomy — dense there, least-positive here.
- **`Z1Countermodel.lean` stays the concrete L⁻ witness and is NOT made an instance of the
  general theorem.** Three measured reasons, recorded at that module: a different language
  (`MinusTruthAt` on `MinusFormula` versus `TruthAt` on `Formula`); `MinusLanguage.tr_ne_untl`
  makes `tr` of the L⁻ `Z1` syntactically distinct from L's, so the general refutation cannot be
  transported across `tr`; and a different valuation. Its downstream consumers
  (`tmMinusCompleteZTime_refuted`, the CEF deliverables) keep compiling because nothing they
  depend on was touched.
- **Nothing over `translationFrame` is advertised as choice-free.** That frame depends on
  `Classical.choice`, and the module docstring says so; `lean_verify` was not used as an
  axiom-freedom gate anywhere.
- **The Discrete entry points take the primary route.** `(isDiscrete_iff_exists_isLeast_pos D).mp`
  unifies through `TaskFrame.IsDiscrete` directly, so the plan's documented fallback through
  `TaskFrame.exists_pos_of_nontrivial` was not needed; the docstrings say which route was taken.

## Plan Deviations

- **Phase 1, altered**: `typst/generated/status.typ` was regenerated and staged with *every*
  `.lean` commit rather than once in Phase 4 as the plan wrote it. `.githooks/pre-commit` is a
  blocking, build-free gate that refuses any commit staging a `.lean` path while
  `typst-sync-check.sh` Check 2 has drifted, and Phase 1's additions moved
  `formalsystem-line-count` immediately. Every regeneration diff was inspected under the plan's
  contention protocol and carried only the scale counts plus the stamp.
- **Phase 2, altered**: the Discrete entry points used the plan's primary `.mp` route; the
  documented fallback was unused.
- **Phase 3, altered**: the `Axiom.z1` sweep found 9 in-scope occurrences across 7 files, not the
  plan's 7 across 5. `FormalSystem/Semantics/FrameClassValidity.lean` and
  `FormalSystem/MinusLanguage/Axioms.lean` carried occurrences the plan-time sweep missed, and
  were admitted under that phase's own "treat any new occurrence as in scope" rule.
  `FormalSystem/StarLanguage/Axioms.lean`'s two matches name `StarAxiom.z1` and `PlusAxiom.z1`,
  constructors that genuinely exist, so they are not drift and were deliberately left alone. The
  objective was completed in full, not dropped.
- **Phase 3, added**: five sibling READMEs beyond the plan's file list changed, all of them output
  of `check-module-invariants.sh --emit-inventory` — the inventory tables carry per-module line
  counts that this task's own edits moved. Mechanical, inspected hunk by hunk, and required for
  the INV check to pass. `FormalSystem/Metalogic/Independence/README.md`'s note that
  `BehSeparatedness.lean` is "deliberately not a thirteenth numbered result" became "not a
  fourteenth", which the renumbering forced.
- **Phase 3, added**: a drift-history sentence in `Independence.lean` and its README ("earlier
  revisions of the two drifted apart … reconciled to their union") was dropped rather than
  renumbered, since `.claude/rules/no-record-versioning-in-deliverables.md` forbids a deliverable
  from narrating its own draft history.
- **Phase 4, added**: `scripts/lean-citation-manifest.json` was regenerated with
  `scripts/export-lean-citations.py`. The `ZTimeSharpness.lean` docstring amendment shifted four
  recorded declaration spans, which C35 reported; the manifest is never edited by hand.

## Verification

- Build: **Success**. `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build`
  (full project, unscoped, detached, un-piped) — guard `state=complete`, `exit_status=0`, 2849
  jobs, the success line present, zero `error:` lines across both captured streams, and every
  module this task touched carries an `.olean` newer than its source.
- Sorry count: **0** (`lean-sorry-census.sh FormalSystem`, empty inventory) — asserted at the end
  of every phase and at the end of the task.
- Vacuous count: **0**. No `:= True` / `:= Unit` / `:= trivial` placeholder was written; no
  `sorry` was ever committed, since every proof body was text that had already compiled
  sorry-free during research.
- Axiom count: **unchanged**. No `axiom` declaration was added; C2 reports all fifty pinned axiom
  sets matching baseline and C14 reports every pinned declaration matching its axiom baseline.
- `bash scripts/check-module-invariants.sh` — **exit 0, ALL CHECKS PASSED**, including C1, C3,
  C9, C14, C15 (all 73 paper-anchor citations resolve), C16, C19, C20, C24, C26, C28, C31, C32,
  C33 (`FormalSystem.lean` byte-for-byte the generated root, 683 import lines), C34a/C34b, C35
  and INV.
- `bash scripts/typst-sync-check.sh` — **exit 0**, all 4 checks green (check 2, count freshness,
  is the one the new `.lean` file moved).
- `bash scripts/readme-lint.sh FormalSystem` — **exit 0**.
- `bash scripts/check-copyright-headers.sh --strict FormalSystem` — **exit 0**, 683 files, 0
  missing, 0 duplicate.
- `bash .claude/scripts/verify-deploy.sh` — **exit 0**, 15 checks, 0 failures.
- `lake exe mk_all --lib FormalSystem` re-run reports "No update necessary".
- All 14 pinned identifiers resolve at their recorded signatures; none is a weaker same-named
  restatement.
- Tests: N/A — this task adds no test; `check-module-invariants.sh`'s C1 also builds
  `BimodalTest` and reports exit 0.
- Files verified: Yes.
- **Advisory, and red for reasons outside this task**: `bash scripts/check-paper-definitions.sh`
  exits 1 on a pre-existing inherited drift wave at ten recorded `MANIFEST` anchors (CO, def:BX,
  def:BX-z, def:BX-d, def:TMplus, app:discrete, def:id, def:strongest, thm:exist, lem:uniq), all
  of which were already drifted before this batch began. `prop:archimedean` carries **no** drift
  verdict of its own, which is the only assertion this task's plan makes about that script. The
  wave was deliberately not absorbed and the whole-file sentinels were not re-pinned.

## Impacts

- `prop:archimedean` is citable from the paper as a machine-checked result. The two identifiers
  the eventual `\leanproof{\texttt{...}}` should name, both in `FormalSystem.Metalogic.Independence`:
  **`not_validOnFrameOver_prior_UZ_nonArchimedean`** and
  **`not_validOnFrameOver_z1_nonArchimedean`**.
- `def:BX-z`'s `ℤ`-time narrowing now rests on a theorem of this tree for its failure half, rather
  than on paper prose the tree took on trust. `Conservativity.lean`'s CEF story and
  `FrameProperty.lean`'s `IsZTime` docstring both say so.
- `translationFrame_lexZ_not_isZTime` puts the non-collision on the record: the refuting frames
  are Discrete but not `IsZTime`, so nothing here disturbs `axiom_validIn_min`,
  `prior_UZ_validIn_iff_ztime` or `z1_validIn_iff_ztime`.
- `exists_gt_nsmul_of_not_archimedean` and `translationFrame_isDiscrete` are available to any
  later module needing a non-Archimedean witness or the frame-level Discrete clause.
- Task 794 is gated behind this task and will edit `FormalSystem.lean` next; this task's
  root-module change is confined to the single import line registering the new module.

## Follow-ups

- The paper-side edit is deliberately **not** done here: the `% PORT:` marker under
  `prop:archimedean` in `possible_worlds.tex` and the `\leanproof{}` macro that replaces it belong
  to PossibleWorlds task 172, as settled in cycle 1. This task's job was to name the identifiers
  that citation will point at, which the Impacts section above does.
- An L⁻ twin of the general countermodel is possible and was deliberately not built.
  `MinusLanguage/Soundness.lean`'s `minus_soundness_ztime_succ` is generic over any regular frame
  with `SuccOrder` **and** `PredOrder` on the duration, so an L⁻ version would generalize
  `not_minus_derivable_z1` to every such carrier. It needs a `PredOrder` hypothesis the L-level
  results do not, and the dispatch's DELIVER named the L-level `ValidOn`. Recorded so the option
  is not lost; a separate task if wanted.
- The inherited `check-paper-definitions.sh` drift wave at the ten anchors named above remains
  open and is already seeded as its own task (801's report on the live BX/TM anchor drift wave).
- `docs/theorem-index.md` carries no rows for the new declarations, matching the existing
  `ZTimeSharpness.lean` sharpness results, which carry none either.

## References

- `specs/791_prop_archimedean_uz_z1_fail_non_archimedean/plans/01_uz-z1-fail-non-archimedean.md`
- `specs/791_prop_archimedean_uz_z1_fail_non_archimedean/reports/01_uz-z1-fail-non-archimedean.md`
  — its Appendix carried both countermodel proof bodies as text already compiled sorry-free by
  `lean_run_code`, which is why implementation was transcription rather than proof search
- `specs/791_prop_archimedean_uz_z1_fail_non_archimedean/handoffs/` — the three per-phase handoffs
- Commits: `7883f2c0a` (phase 1), `80215807b` (phase 2), `2253a509f` (phase 3), `9afba510e`
  (phase 4)
