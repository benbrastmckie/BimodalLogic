# Implementation Summary: Task #801

- **Task**: 801 - Re-pin the BX/TM anchor wave in paper-definitions-of-record.md after the paper's post-788 revision, and verify in-tree axiom-membership prose matches
- **Status**: [COMPLETED]
- **Started**: 2026-10-15T20:19:21Z
- **Completed**: 2026-10-15T22:35Z
- **Effort**: ~4.3 hours (of which ~45 minutes was the single full guarded build)
- **Dependencies**: 791, 793
- **Artifacts**: plans/01_bx-tm-repin-and-membership-prose.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

The paper caught up to the tree, and this task absorbed that into the record and then made the
tree's prose say the same thing. Ten anchors were re-pinned and one retired dangling in
`docs/reference/paper-definitions-of-record.md` under a dated drift-correction entry whose
headline is a set identity: the paper's sixteen named primitive schemata plus the four CPL
constructors are now exactly `inductive Axiom`'s twenty constructors, key for key, so the
record's standing "proper subset, minus the nine" framing is retired rather than adjusted. The
judgment pass that follows corrected every in-tree claim *about the paper's* BX/TM axiom
membership — UE and UT are not paper keys at all, TC and TL are derived theorems of BX, NP/NF/NA
derived theorems of TM (not BX), Z1 of TM_z, DN of BX_d, and NB is an axiom of `def:TMplus`
alongside MF — together with five pre-788 count tables that no gate can see. No Lean declaration
was added, removed or restated.

## What Changed

**The record** — `docs/reference/paper-definitions-of-record.md`:
- Ten anchors re-pinned (prose fence, `sha256:` line and MANIFEST row each): `CO`, `def:BX`,
  `def:BX-z`, `def:BX-d`, `def:TMplus`, `app:discrete`, `def:id`, `thm:exist`, `lem:uniq`,
  `thm:s5`. `def:id` was re-pinned **five times**, for five successive revisions of the same block
  minutes apart while the correction was in flight (`f56301e5` → `b52579e8` → `18edbbea` →
  `58e1cdd6` → `09ab2f44`).
- `def:strongest` retired **DANGLING**: its `\label` is gone from the paper (succeeded by
  `def:key-terms`'s `\aitem{Str}`), so the MANIFEST row was removed, the prose entry retained and
  marked, and a `KNOWN-ANCHORS` `DANGLING` row added.
- New `### Drift correction (2026-10-15): the BX/TM demotion wave`, separating the **removal** of
  UE/UT from the **demotions** of TC/TL/NP/NF/NA/Z1/DN in a per-schema table, naming the five
  objective-modality anchors absorbed under the user's recorded authorization (and `thm:s5` as
  the fifth, measured not assumed), recording `CO`'s drift as a citation append and
  `app:discrete`'s as pure addition deferred to a separate task, and recording that
  `lem:derived-schemata` no longer exists with zero in-tree citations.
- The obsolete 2026-10-14 `**Amended by**` note rewritten to record the divergence as resolved.
- Three whole-file sentinels and the summary-table rows re-taken last, after the final round.

**Paper attributions** — `docs/theorem-index.md` (five anchor cells, derived-schemata lead-in);
`FormalSystem/ProofSystem/DerivedAxioms.lean` (UE, UT → no paper key; NF → `def:TMplus`);
`FormalSystem/Theorems/ConnectDerived.lean` (NP, NA → `def:TMplus`);
`FormalSystem/ProofSystem/Axioms.lean` (seven docstring defects: the anchor list, both "the paper
lists" passages, the stale Burgess/Xu-footnote premise, the "UT original to the paper" sentence,
the Density DN/NN conflation and the Base-23/Dense-2 count contradiction);
`FormalSystem/Theorems/LinearityDerived.lean`, `FormalSystem/Metalogic/CompletenessDerived.lean`,
`FormalSystem/ProofSystem/LinearityDerivedFacts.lean`, `FormalSystem/MinusLanguage/Axioms.lean`
(module-docstring membership claims); `docs/reference/axiom-reference.md` (the "minus the nine"
lead-in, the Base-categories Paper-keys column, the Paper Key Correspondence premise, a new "In
the paper" column across its seventeen rows, a new MF row, and the reconciliation arithmetic
re-derived rather than adjusted); `typst/FormalFoundations.typ` (BX block reduced to the live nine
keys with TC/TL restated as derived and UE/UT as tree-only; NB moved into the TM block alongside
MF with NP/NF/NA stated there as TM-derived; footnote key count corrected);
`typst/chapters/03-proof-theory.typ` ("sole bimodal interaction axiom" corrected, and the
`// CONFIRM(paper):` marker resolved to `// CONFIRMED(paper), 2026-10-15`).

**Verbatim-quotation repairs** — `FormalSystem/Syntax/Formula.lean` and
`FormalSystem/Theorems/DedekindDerived.lean` each labelled a quotation of `CO` "verbatim" and no
longer reproduced it, since `CO` gained `\leanfoot{DedekindDerived.coDerived}`. Both re-quoted,
each noting that the appended `\leanfoot` is the paper's own citation of this repository.

**Count tables** — `FormalSystem/ProofSystem/README.md` (the whole pre-788 29-constructor layer
table and its frame-classification paragraph, plus the `Axioms.lean` row's "minus the nine"
gloss); `README.md:223` (a decomposition summing to 29 under a "20 constructors" heading);
`FormalSystem/README.md` (line 111's "the paper lists as axioms", and the "TM Base (23
constructor axioms)" / "TM Dense (Base + 2 density constructors)" headings);
`docs/project-info/FEATURE_REGISTRY.md` (UE/UT as "paper schemata");
`docs/user-guide/architecture.md` ("bimodal interaction axioms (MF, TF)").

**Generated/derived** — `scripts/lean-citation-manifest.json` (regenerated by
`export-lean-citations.py`), five README inventory blocks (`check-module-invariants.sh
--emit-inventory`), `typst/generated/status.typ` (re-stamped by `typst-status-counts.sh`), and one
C20 declaration-span citation re-pointed in `FormalSystem/Metalogic/Decidability/Tableau.lean`.

## Decisions

- **`thm:s5` absorbed into the wave** though it was not in the user's authorized four. It drifted
  newly, in the same section of the same revision, with the same `$\Str^{\OO}_{L}$` →
  `$\vdash \Str^{\OO}$` change; `grep -rln thm:s5` over `FormalSystem/`, `docs/`, `typst/` and
  `README.md` returns the record file alone, which is the same measured basis the authorization
  rested on. Named explicitly in the drift-correction entry so the absorption is auditable.
- **`def:strongest` retired rather than re-pinned.** The plan expected it drifted; by
  implementation time its label was gone. Retired under the record's documented DANGLING
  convention, matching the `thm:s4`/`thm:sym` precedent.
- **`app:discrete`'s added independence claim not formalized and not rowed.** The authorization
  expressly did not extend to it; deferred as a separate question, and no `fn:static-frame` row
  added.
- **Re-pinning done mechanically, never by transcription.** Each OLD fence was asserted to
  re-hash to its recorded OLD sha256 before any write, and each NEW text was reconstructed from
  `--resolve` and asserted against the resolver's own sha. Eleven re-pins, no mis-placed write.
- **The acceptance claim is conditional by construction**, naming the absorbed revision, because
  the paper was being edited while the correction was being applied.
- **Tier 3 left untouched**, as the plan requires: TC → `def:BX`, TL → `def:BX`, DN →
  `def:BX-d`, Z1 → `def:BX-z` (twice) and the TR-mirror `Paper: —` are all intact.

## Plan Deviations

- **Phase 1** altered: the Scope Hypothesis was falsified in three ways and the measured wave
  adopted after recording the delta — the paper had moved an eighth time, `def:strongest` was
  dangling rather than drifted, and `thm:s5` had drifted newly. The six BX/TM-core hashes matched
  the hypothesis exactly, for a third independent measurement.
- **Phase 1** altered: the wave record was written to this dispatch's own scratchpad, not the
  planning session's path.
- **Phase 2** altered: the five re-pinned anchors were `CO`, `def:id`, `thm:exist`, `lem:uniq`
  and `thm:s5` — `thm:s5` in place of `def:strongest`, which was retired instead. Three stale
  prose headings corrected, one of them as part of that retirement.
- **Phase 3** altered: five prose-entry headings were corrected, not the one the plan named, and
  the drift-correction entry records two findings the plan had not anticipated — NP/NF/NA have
  lost `\aitem` status entirely and are now `\alabel`-tagged in a prose paragraph, and
  TC/TL/Z1/DN each now carry a `\leanfoot{…}` citation of this repository.
- **Phase 4** altered: `Axioms.lean` carried seven docstring defects rather than five, and four
  further files joined the batch for the same reason. The batch's first full build was cancelled
  once those additional Lean edits became necessary; the authoritative verdict is Phase 7's build
  over the final state.
- **Phase 5** altered: the Paper Key Correspondence table gained an "In the paper" column and an
  MF row beyond the planned six sites, and the `KNOWN-ANCHORS` row written in Phase 2 was
  corrected — `typst/FormalFoundations.typ` does **not** cite `def:strongest`; the only occurrence
  outside the record is the now-inert whitelist entry at `typst/sync-check-whitelist.txt:104`.
- **Phase 6** altered: three sites beyond the planned five, all caught by the Scope Hypothesis's
  own prescribed grep sweep.
- **Phase 7** altered: run against a scoped tier per this dispatch's batch-gate deferral, with the
  complete gate set deferred to the batch stage (see Verification).

## Verification

- Build: **Success.** `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build`,
  detached and un-piped. Verdict read at all three tiers: the guard's own `exit_status=0`
  (`state=complete`); `Build completed successfully (2859 jobs)` with **zero** `error:`
  occurrences over the captured streams; and `.olean` newer than source for all ten Lean modules
  this task touched (`Axioms.lean`, `DerivedAxioms.lean`, `LinearityDerivedFacts.lean`,
  `ConnectDerived.lean`, `LinearityDerived.lean`, `DedekindDerived.lean`,
  `CompletenessDerived.lean`, `MinusLanguage/Axioms.lean`, `Syntax/Formula.lean`,
  `Decidability/Tableau.lean`).
- Sorry count: 0 (`lean-sorry-census.sh` over the eight resolved source roots)
- Vacuous count: 1 — `FormalSystem/Examples/TemporalStructures.lean:495`,
  `int_domain_universal … := trivial`, **pre-existing and byte-identical at the baseline commit
  `90afe55a2`** (`git grep -c` confirms one hit there too). This task added no Lean declaration,
  so it neither introduced nor could remove it.
- Axiom count: 14 `^axiom ` lines across the source roots, **unchanged from `90afe55a2`** (same
  twelve files, same per-file counts).
- `bash scripts/check-paper-definitions.sh`: **exit 0, quiet case-(a) pass**, conditional on the
  absorbed revision — paper sha256
  `5362b6ba32825d32e73f8adeeeade63d2f8d556cebd9ba0603a595225b970245` (as recorded by the
  `FILE_CHECKSUM` sentinel, which is the authoritative value), 4079 lines, paper repo HEAD
  `bc010a06096299f605b12989461dc7ce86612b31`, working tree **dirty** against it. The run with the
  OLD sentinels still in place reported case (b) first, confirming full anchor validation ran
  before the sentinels moved.
- `bash scripts/check-module-invariants.sh --no-build`: exit 0, **no FAIL lines** — C14, C15, C20
  and C35 all PASS.
- `bash scripts/check-module-invariants.sh --emit-inventory`: clean (blocks regenerated in-phase).
- `python3 scripts/export-lean-citations.py --check`: exit 0, 86 seeded names resolve.
- `bash scripts/readme-lint.sh`: exit 0.
- `typst compile --root . typst/BimodalReference.typ`: exit 0.
  `typst compile --root . typst/FormalFoundations.typ`: exit 0.
- `bash scripts/typst-sync-check.sh`: exit 0.
- `bash scripts/typst-status-counts.sh`: `axiom_count` 20, `base_count` 16, `dense_only_count` 1,
  `ztime_only_count` 1, `rtime_only_count` 2 — the figures every corrected count table was
  re-derived against.
- `bash scripts/check-phantom-citations.sh`: exit 0.
  `bash scripts/check-copyright-headers.sh`: exit 0.
  `bash scripts/check-evidence-probes.sh`: exit 0 after the build released the shared build-guard
  lock — all 33 wired probes compile. Its first run FAILED as an **environment** failure (its own
  classification): it timed out after 600s waiting on the lock held by this dispatch's build and
  compile-checked no probe.
  `bash scripts/check-metalogic-cycles.sh`: **exit 1, inherited.** One surplus upward import edge,
  `FormalSystem.MinusLanguage.AxiomDischarge -> FormalSystem.Theorems.LinearityDerived`.
  `AxiomDischarge.lean` is untouched by this task and `git show 90afe55a2` gives a byte-identical
  import list, as does `scripts/measure-refactor-partitions.py`; the gate's inputs are therefore
  unchanged from the baseline commit and so is its verdict. The research report's claim that every
  gate but `check-paper-definitions.sh` was green at baseline did not hold for this one.
- `bash .claude/scripts/verify-deploy.sh --only-gate 4 .`: **not usable here** — exit 2 with
  "cannot attest: every gate selected by --only-gate 4 skipped or was deferred -- 0 check(s) ran".
  Gate 4 SKIPs outside the source store just as gate 3 does, which is the zero-check-under-filter
  condition the plan was trying to avoid by naming it. The substantive check ran instead through
  this repo's own lint: `bash .claude/scripts/check-task-references.sh` — **PASS, 0 unexempted
  task-reference occurrences** repo-wide outside `specs/`.
- Whole-task invariants: `grep -rn 'Paper: \`def:BX\`' FormalSystem/` returns exactly the TC and
  TL sites; `docs/theorem-index.md`'s `def:BX` cells are exactly TC and TL; no site calls MF the
  sole bimodal-interaction axiom and none asserts seventeen `def:BX` keys; the stale-literal sweep
  `grep -rnE "\b(23|29)\b[[:space:]]+(axiom|constructor|schema)"` returns only the record file's
  own 2026-09-17 historical figure and the annotation this task added marking it superseded; no
  in-tree site claims a verbatim quotation of a re-pinned anchor it does not reproduce (two `CO`
  sites did and were repaired).
- **Batch-gate deferral**: this phase discharged `**Verification Tier**: full` against a scoped
  tier, per this dispatch's directive. The complete gate set runs once for the whole batch at the
  end of the orchestrate invocation; it is deferred here, not forgiven.

## Impacts

- Every in-tree statement about the paper's BX/TM axiom membership is now true of the live paper,
  and the record's framing of the tree/paper relation is an identity rather than a containment —
  which removes the standing "proper subset, minus the nine" caveat from four documents.
- The five pre-788 count tables now agree with 788's 20-constructor system and with
  `typst-status-counts.sh`, closing a contradiction that sat directly under its own correct
  "20 constructors" sentence in two READMEs.
- `typst/chapters/03-proof-theory.typ`'s `// CONFIRM(paper):` marker is discharged: the claim it
  guarded is now exactly, newly true.
- The paper now cites this repository back, by `\leanfoot{…}`, at `CO`, `TC`, `TL`, `DN` and `Z1`.

## Follow-ups

- `app:discrete`'s added soundness claim — over ℤ the static frame validates `X⊤`, so extending
  TM by DN alone does not prove NN — is unformalized and unrowed. Deciding whether to formalize it
  (and whether `fn:static-frame` earns a row) is the separate question the user's recorded
  decision reserved.
- `typst/sync-check-whitelist.txt:104`'s `def:strongest` entry now suppresses nothing, since no
  typst chapter cites the anchor. Removing a dead whitelist entry is a whitelist-hygiene change,
  not part of this wave.
- C14's stale-literal set `{14,21,42,44,45}` and its markdown scope (`docs/` plus the root
  `README.md`) left all five of this task's count tables mechanically invisible. Widening either
  is a gate change and a separate task (research report recommendation 9).
- The paper is being actively revised: **six** distinct whole-file checksums were measured during
  this dispatch alone, five of them moving `def:id`. A re-red on a newly drifted anchor is expected rather than exceptional, and
  the drift-correction entry is written so a further absorption re-resolves into it.

## References

- `specs/801_repin_bx_tm_anchor_wave_post_788_paper_revision/plans/01_bx-tm-repin-and-membership-prose.md`
- `specs/801_repin_bx_tm_anchor_wave_post_788_paper_revision/reports/01_bx-tm-membership-prose-audit.md`
- `specs/801_repin_bx_tm_anchor_wave_post_788_paper_revision/reports/01_repin-bx-tm-anchor-wave.md`
- `specs/801_repin_bx_tm_anchor_wave_post_788_paper_revision/.decisions.json` (cycle 5, the
  Tier-D absorption authorization)
- `docs/reference/paper-definitions-of-record.md`, "Drift correction (2026-10-15): the BX/TM
  demotion wave"
- `specs/801_repin_bx_tm_anchor_wave_post_788_paper_revision/handoffs/` (phases 1-3)
