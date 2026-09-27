# Implementation Summary: Task #681

- **Task**: 681 - Narrow transcription audit surface
- **Status**: [COMPLETED]
- **Started**: 2026-09-27T11:43:00Z
- **Completed**: 2026-09-27T13:35:00Z
- **Effort**: ~1h50m
- **Dependencies**: None
- **Artifacts**: plans/01_narrow-transcription-audit-surface.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

All nine phases landed. The one available definition-to-theorem conversion is in and consumed by
the certificate path; the four-condition frame row is now provably irreducible as a single citable
theorem; the hand-maintained cross-repository line-numbered citation table is replaced by a
generated manifest with a gate (C35) that fails **in this repository** when a cited declaration
moves; and the inspection-only residue is written down exactly, by name, at 24 rows and 27
declarations.

**The residue did not change. The axiom burden did.** Those are two different surfaces and the
whole task turns on not conflating them. The definitional surface a human must read against paper
text is 24 rows before and after. What shrank is a particular construction's axiom burden: over a
discrete duration order a certified shift set now supplies **three** axiom fields instead of four.

## What Changed

### The conversion (Phase 1)

- `FormalSystem/Semantics/ShiftSet.lean` — added `sep_of_succOrder`, which derives *Limit*
  transcribed over a shift action (`def:frame#Limit`) from the zero-shift law alone whenever the
  duration carrier is a `SuccOrder`; `ofIntAction`, a smart constructor for `ShiftSet intOrder`
  supplying the `sep` field from it; and two `@[simp]` projection lemmas `ofIntAction_sh` /
  `ofIntAction_A` so the constructor behaves under `simp` like the structure instance it replaces.
  Added `import Mathlib.Data.Int.SuccPred`, and corrected the module header's axiom-count section:
  four fields in general, three over a discrete order, with the two counts kept apart.
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Std.lean` — `std` is now built through
  `ShiftSet.ofIntAction`, and the hand separation proof (the `Int.abs_lt_one_iff` block) is deleted.
  Every other field *value* is unchanged. The certificate's *Limit* obligation is now
  kernel-checked.

The `sep` field was **not** removed, and must not be:
`ShiftSet.SepNotDerivable.sep_not_derivable` refutes the same shape over a dense duration order, so
discreteness is the boundary of the derivation rather than a convenience hypothesis.

### The independence matrix (Phases 2-5)

- `FormalSystem/Semantics/FrameConstraintIndependence.lean` — new module. Four witness relations at
  `D := ℤ` and sixteen theorems: `emptyRel` (`Bool`, refutes *Seriality*), `totalRel` (`Bool`,
  refutes *Limit*), `rayRel` (`ℤ`, refutes *Saturation*), `driftRel` (`ℤ`, refutes
  *Compositionality*), each with the three positive results; plus `drift`, `rayRel_def`, and the
  aggregate `constraints_pairwise_independent`.
- `FormalSystem/Semantics.lean`, `FormalSystem.lean`, `FormalSystem/Semantics/README.md`,
  `docs/theorem-index.md` — import, docstring bullet, regenerated root, inventory row with a
  refreshed `Last verified` date, and five ledger rows.

**No `[COMPLETED WITH EXCLUSIONS]` was needed on Phase 4**: the *Compositionality* witness the plan
flagged as the one not yet written did not resist, and `driftRel_not_compositional` is proved.

### The generated citation manifest and its gate (Phases 6-7)

- `scripts/export-lean-citations.py` + `scripts/lean-citation-seeds.txt` ->
  `scripts/lean-citation-manifest.json`. 53 seeded fully qualified names, all resolving; spans come
  from `scripts/lib/lean_citations.py`'s `decl_spans`, the same reader C20 uses, so the exporter and
  that gate cannot disagree about where a declaration lives. Deterministic by construction.
- `scripts/check-module-invariants.sh` — new invariant **C35**, build-free and enforced, comparing a
  fresh in-process resolution against the committed manifest with a per-entry diagnostic.
- `docs/development/MODULE_INVARIANTS.md`, `scripts/README.md` — the invariant's row and the
  exporter's inventory rows.

### The record (Phase 8)

- `docs/reference/transcription-audit-surface.md` — new. The two-surface distinction first, then
  the 24-row residue table keyed by declaration name and paper anchor with **zero** line numbers,
  the corrections the consuming table owes, the two closed questions, and what the independence
  matrix does not do.
- `docs/reference/README.md`, `scripts/module-invariants-allowlist.txt` — index row, and the
  16 allowlist entries C5 needs once a `docs/` page names declarations in fully qualified form.

## Decisions

- **`D := ℤ`, not `↑intOrder`, throughout the new module.** The constraint predicates are `D`-typed
  and `(↑intOrder : Type) = ℤ` by `rfl`, so these *are* statements about the certificate's own time
  structure — and `omega` can see them, which it cannot through the `TemporalOrder` coercion. This
  dissolved the research report's single largest tactical risk at the level of the statement rather
  than by patching tactics.
- **`rayRel_def` plus `rw`, never `simp only [rayRel]`.** Measured, not guessed: `simp only` collapses
  the reflexive conjunct `w = w` to `True`, and `omega` then reports "No usable constraints found".
  The lemma is deliberately not `@[simp]` and its docstring records why.
- **Two `@[simp]` projection lemmas for `ofIntAction`** rather than editing downstream proofs, so a
  construction built through the constructor behaves under `simp` exactly as the hand-written
  structure instance did.
- **A field row in the seed list writes `Parent.Name#field`.** Three residue rows name a structure
  field, which opens no declaration span; C20's own output counts such citations as "not checkable,
  not failed". The parent resolves and the field is carried as metadata, so no row is silently
  dropped and no name fails to resolve.
- **The residue document names the existing independence witnesses rather than presenting the new
  module as the tree's first.** See Plan Deviations.

## Plan Deviations

- **Phase 1** altered: `sh_surj` needed `; rfl` appended (a projection of `ofIntAction` is not
  reduced by unfolding `std` alone); the certificate acceptance suite could not be run because a
  concurrent sibling task had a non-compiling new declaration in
  `BimodalTools/CertificateImport.lean` at the time — outside this task's scope, and it would have
  failed identically without this task's changes. `WitnessFamily/Agreement.lean`, the module through
  which the certificate's semantic guarantee actually consumes `std`, was built separately and is
  green.
- **Phase 2** altered, and this is the substantive one. The phase's own Scope Hypothesis required
  checking for an existing independence record and citing rather than duplicating any overlap. There
  is one, and it is complete: `FormalSystem/Semantics/StateTopology/ConstraintWitnesses.lean`'s
  header already claims a finished independence matrix — `voidRel` (character-identical to the
  plan's `emptyRel`) for *Seriality*, `bumpRel` for *Compositionality*, `SeparatingFrame.srel` for
  *Saturation* at bare `ℤ`, and the four-state funnel for *Limit*, the last under
  `[DenselyOrdered ↑D]` and so silent over `ℤ`. The research report's claim that "no such
  independence record exists in the tree today" is wrong. The new module was still built as the plan
  specifies — its `## Lean Challenge Statements` section fixes all sixteen signatures plus the
  aggregate, and `plan-compliance.md` makes those binding — but its header, the aggregator bullet,
  the ledger rows, the `Semantics/README.md` row and the residue document all cite the existing
  witnesses by name and state exactly what is new: the first **aggregate** statement, the first
  *Limit* refutation over **discrete** time, and import-light reachability from
  `FormalSystem/Semantics.lean`, which the topology-carrying witnesses deliberately do not have.
  Three of the four rows therefore re-prove, at a different witness, something the tree already knew.
  That is recorded, not glossed.
- **Phase 2** also altered: `lake exe mk_all --lib FormalSystem` globs the filesystem and emitted two
  import lines for a sibling task's then-untracked files. Both were removed before committing, so the
  committed root carries exactly the one line this module causes.
- **Phase 3** altered: one auxiliary lemma `rayRel_def` added, and `rayRel_serial` proved as an
  explicit term rather than by `rcases` + `omega`, for the `True`-and-`omega` reason above.
- **Phase 4** altered: the `driftRel` docstring additionally names `StateTopology.bumpRel` and how
  the two witnesses differ.
- **Phase 5** altered: C15 rejected the first attempt at the ledger rows. It requires
  `Paper: <anchor>` on a **standalone line** in the declaration's own doc comment, not inline at the
  end of a sentence; all nineteen `Paper:` mentions in the module were normalised.
- **Phase 6** altered: `decl_spans` reports a declaration's name as *written*, local to its enclosing
  `namespace`, so the exporter additionally tracks each file's `namespace`/`section`/`end` stack to
  recover the fully qualified name. Spans still come from `decl_spans` alone.
- **Phase 7** altered: the first version of C35 crashed comparing a `None` field against a string;
  fixed by normalising the sort key. The crash did make the gate fail loudly rather than pass
  silently, which is what its anti-silence design wants.
- **Phase 8** altered: a second limit on the independence matrix is recorded alongside the planned
  one (the duplication above); and `scripts/module-invariants-allowlist.txt` gained 16 entries, a
  file the plan did not anticipate, because C5 cannot distinguish a dotted declaration name from a
  module path. C35 resolves every one of those names by the same fully qualified name, which is a
  strictly stronger assertion than C5's path-shape resolution.
- **Phase 9** closed `[COMPLETED WITH EXCLUSIONS]` with a `#### Reasoned Exclusions` record: one
  gate, `check-paper-definitions.sh`, exits 1 on drift in the **live paper** outside this
  repository. See Verification.

## Verification

- **Build**: Success. `lake build` — 2741 jobs, exit 0, **0** `error:`, **0** `warning:`.
  `lake build BimodalTest` — 2802 jobs, exit 0, **0** `error:`, **0** `warning:`. Both through
  `lake-build-guard.sh`, detached.
- **Sorry count**: 0 (`lean-sorry-census.sh` over all four source roots: `sorry_count: 0`;
  `grep -rn sorry` over all four modified Lean files: 0 hits).
- **Vacuous count**: 0 attributable to this task. The grep returns one hit,
  `FormalSystem/Examples/TemporalStructures.lean`'s `int_domain_universal ... := trivial`, which
  this task never touched (last modified by an earlier task) and which is a correct proof of a
  genuinely-`True` goal, not a placeholder.
- **Axiom count**: 14, unchanged from the pre-task baseline, and **zero real `axiom` declarations**
  exist in the source roots (a grep requiring an identifier and a colon returns 0). The census
  briefly read 15: the extra hit was a docstring line of the new module that wrapped onto the word
  `axiom`. The docstring was reflowed and the site records why.
- **`#print axioms`**: `constraints_pairwise_independent`, `ShiftSet.sep_of_succOrder` and
  `WitnessFamily.std_sat_ztime` all report `[propext, Classical.choice, Quot.sound]`. **No
  `sorryAx`.** `emptyRel_not_serial` and `totalRel_not_limit` report `[propext]` alone.
- **Package linter set**: all four modified `FormalSystem/**` modules produce no output at all under
  `lake env lean -D weak.linter.mathlibStandardSet=true -D autoImplicit=false`.
- **`scripts/check-module-invariants.sh`**: `ALL CHECKS PASSED`, exit 0 — in **both** modes, with
  build and under `--no-build`. Includes
  `PASS C35  scripts/lean-citation-manifest.json is byte-current: all 53 seeded declaration(s)
  resolve at the recorded file, keyword line and span`, and `PASS C15  all 210 theorem-index row(s)
  carry their anchor`, `PASS C20` on all three tiers, `PASS C5`, `PASS C13`, `PASS C33`, `PASS C34a`,
  `PASS C34b`.
- **Other gates**: `check-metalogic-cycles.sh` 0, `check-copyright-headers.sh` 0,
  `readme-lint.sh` 0, `readme-lint.sh docs` 0, `check-evidence-probes.sh` 0.
- **C35 negative test**: inserting two lines above `ShiftSet.sep_of_succOrder` produced nine
  per-field diagnostics naming that declaration plus `ofIntAction` and
  `SepNotDerivable.sep_not_derivable`; restoring the file restored `PASS`. Both outputs are recorded
  verbatim in the plan.
- **Exporter negative test**: seeding `...TaskFrame.Saturatoin` gives exit 1, a named `UNRESOLVED`
  diagnostic, and `"resolved": 52, "total": 53` in the manifest. Two consecutive normal runs are
  byte-identical.
- **`check-paper-definitions.sh`**: exit **1**, and this is the one red gate. It reports
  `1 recorded definition(s) drifted` at anchor `def:id`, because the author edited a footnote of
  that definition in the live paper working tree — a file outside this repository.
  `docs/reference/paper-definitions-of-record.md` is unmodified by this task, `def:id` appears zero
  times in anything this task wrote, and all 61 paper-anchor citations resolve. Re-pinning it would
  accept a paper edit this task did not review.
- **Diff scope**: confirmed by unioning `git show --name-only` over this task's eight phase commits.
  Every path is one the plan names, plus this task's own `specs/` directory, plus
  `scripts/module-invariants-allowlist.txt`. Nothing belonging to a sibling task.
- **Files verified**: Yes.

### A note on the shared working tree

Three sibling tasks were dispatched into this same tree in the same cycle, and two of them completed
mid-run. Several gate failures observed during the run were theirs, not this task's, and each was
checked against `git log` and `git status` before being set aside rather than dismissed: a
non-compiling `refutes_of_countermodel` in `BimodalTools/CertificateImport.lean`; long-line warnings
in `BimodalTools/TranslateSentenceMain.lean`; five stale generated inventory blocks, which
predated this task (the root `README.md` rollup recorded 573 live `FormalSystem/` `.lean` files while
574 were tracked before this task's new module); and one `C1 lake build BimodalTest failed` from the
harness's **unguarded** build racing a sibling's commit — the guarded re-run was green. All of them
are resolved in the final all-passing run.

## Impacts

- Any construction of a `ShiftSet intOrder` can now use `ShiftSet.ofIntAction` and supply three
  axiom fields instead of four. `sep_of_succOrder` is available at any `SuccOrder` duration carrier,
  not only `ℤ`.
- `constraints_pairwise_independent` gives downstream prose a single citable theorem for "the
  four-clause frame condition cannot be compressed to three", replacing a claim in a module header.
- A rename or a docstring sweep touching any of 53 cited declarations now fails C35 here, rather
  than silently invalidating a table in another repository. The failure names the declaration and
  both locations.
- `docs/reference/transcription-audit-surface.md` is the durable answer to "how large is the
  inspection-only surface": 24 rows, 27 declarations, three of them rows the consuming audit does
  not currently reach.

## Follow-ups

- **The consuming repository's table still needs its corrections applied.** They are recorded by
  name in `docs/reference/transcription-audit-surface.md` with the manifest as resolution source;
  nothing in this task edits that repository, by design.
- **`check-paper-definitions.sh` is red** on paper-side drift at `def:id`. Someone who can review
  the paper edit should re-pin it.
- **The duplication between `FrameConstraintIndependence` and `StateTopology/ConstraintWitnesses`
  is real and recorded.** If the import-weight constraint on `FormalSystem/Semantics.lean` is ever
  relaxed, three of the four new witnesses could be retired in favour of citing the existing ones.
- **The residue can be narrowed further only by converting more definitions to theorems.** No such
  conversion is currently available: the time-structure row is one-to-one against the paper's four
  adjectives with no bundled Mathlib class to collapse it into, and the four-clause constraint row
  is now provably incompressible. Both are recorded as closed questions so a later pass does not
  re-derive them as opportunities.

## References

- `specs/681_narrow_transcription_audit_surface/plans/01_narrow-transcription-audit-surface.md`
- `specs/681_narrow_transcription_audit_surface/reports/01_narrow-transcription-audit-surface.md`
- `specs/681_narrow_transcription_audit_surface/handoffs/` — one per phase boundary
- `docs/reference/transcription-audit-surface.md` — the record this task exists to produce
- `docs/development/MODULE_INVARIANTS.md` — C20 and C35
