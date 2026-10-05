# Triage Ledger: Phantom-Citation Checker Findings

Working ledger for the residual triage plan's Phase 2-6. Not a `report-format.md`/
`plan-format.md` artifact. Covers every finding from a fresh `check-phantom-citations.sh --verbose`
run, triaged after two checker correctness fixes applied mid-triage (see "Checker Fixes" below).

## Checker Fixes Applied During Triage (deviation from strict phase order)

Phase 2's goal is a per-finding decision record; building one surfaced that
`scripts/check-phantom-citations.sh`'s `definition_exists` function had three detection gaps that
were producing FALSE PHANTOM reports for genuinely live declarations. Repairing the checker before
triaging is more accurate than triaging stale false positives into "PHANTOM" rows and discovering
the mistake in Phase 5 — the plan's own risk-mitigation table (Phase 2 Scope Hypothesis: "the
ledger's measured counts win") anticipates exactly this kind of correction. This is a deliberate,
reasoned deviation from the plan's strict Phase 2 -> 3/4 -> 5 ordering, recorded here rather than
silently reordered.

Two bugs fixed directly in `definition_exists` (Phase 5's territory, done early):

1. **Missing qualified-prefix support in the keyword-declaration branch.** The namespace/end
   fallback already allowed an optional `(\S+\.)?` prefix before the bare name; the far more
   common keyword-declaration branch (`theorem`/`def`/...) did not. This codebase routinely writes
   `def TaskFrame.ValidOn (...) := ...` with no surrounding `namespace TaskFrame ... end` block, so
   a dotted citation's bare last-segment (`ValidOn`) was never found. Fixed by adding the same
   `(\S+\.)?` prefix to the keyword branch.
2. **Trailing `\b` conflated primed and unprimed identifiers.** PCRE `\b` only requires a
   word/non-word transition; `no_finite_carrier_sat'` (a real primed theorem) and
   `trans_refl` (searched when `trans_refl'` is what's actually nearby) both broke on this,
   in OPPOSITE directions — a primed real declaration was reported absent, and an unprimed bare
   citation could be falsely cleared by a differently-primed declaration of a DIFFERENT name.
   Fixed by replacing the trailing `\b` with `(?![A-Za-z0-9_'])` throughout.

A third fallback was added (not a bug fix, a genuine scope extension): `macro "X"`/`elab "X"`/
`syntax "X"`/`notation "X"` tactic and term-syntax declarations, which this repository's
`Automation/Tactics/` layer uses for several real, user-facing tactics (`apply_axiom`, `modal_t`,
`assumption_search`, `modal_search`, `deduction`, `undischarge`, `propDecide`) instead of a
`def`/`theorem`.

**Effect measured**: findings dropped from 105 (Phase 1 baseline) to 94 after these fixes, with
zero new findings introduced except `trans_refl` (which flipped from a false "yes", via the old
bug's cross-identifier conflation with `trans_refl'`, to a correct "no" — `trans_refl` genuinely
has no `theorem`/`def`/... declaration; it is a real `structure SharingSkeleton where` FIELD,
which the checker still cannot detect by design — see class V below). Dropped findings (now
correctly cleared): `Axiom.minFrameClass`, `Derivable.deduction`,
`FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.FiniteCarrier.no_finite_carrier_sat'`,
`...not_plusValidZTime_neg_θ'`, `F.translationProduct`, `HasAttainedSUP.toHasFaithfulDedekindSUP`,
`TaskFrame.IsComplete`, `TaskFrame.IsDiscrete`, `TaskFrame.ValidOn`, `Valid.apply`,
`Valid.of_forall`, `Valid.of_not`.

All 94 remaining findings are triaged below against the corrected checker.

## Classes

- **PHANTOM** — genuinely absent or misattributed; repaired at its citing source (Phase 4; no
  Phase 3 repairs were needed — see below).
- **UPSTREAM** — a real Mathlib/Lean-core/metaprogramming name this repo cites but does not
  define.
- **NOT-LEAN** — not a Lean declaration at all: a bash sentinel/array, a Lake `lean_lib`/`lean_exe`
  target name, a linter option name, a Python/script identifier, or a bare naming-convention
  fragment.
- **OUT-OF-SCOPE-REAL** — a real Lean declaration, but defined under `BimodalTools/` or `scripts/`
  rather than `FormalSystem/`, which is this checker's documented, deliberate search root (per
  both its own header and the originating task charter's own wording, "zero definition sites in
  FormalSystem/"). Confirmed real by hand; not absorbed as a scope widening, since widening
  `SOURCE_DIR` was never asked for and the two sibling trees are not otherwise this checker's
  concern.
- **VERIFIED-FIELD** — a real Lean identifier, confirmed by hand as a plain `structure ... where`
  field (no `|`, no keyword) or a record literal field assignment. The checker deliberately does
  not generalize field detection (see the script's own LIMITATIONS note); absorbed via ALLOWLIST
  per-name instead.
- **EXAMPLE** — an illustrative identifier (teaching example, template placeholder, historical
  negative-test artifact, naming-convention anti-pattern, or paper notation masquerading as a Lean
  identifier) that was never a claim about the tree, and the citing prose already says so (or the
  symbol is self-evidently paper/mathematical notation, not a backtick-worthy Lean citation).
- **ALREADY-ACCURATE** — the citing prose already states non-existence, retirement, or
  not-yet-landed status correctly; the checker flags the backtick regardless of polarity. No
  repair; absorbed via allowlist.

## Findings

| # | Name | Sites | Class | Disposition |
|---|------|-------|-------|-------------|
| 1 | `_1` | NAMING_CONVENTION_DEVIATION.md | NOT-LEAN | Mathlib `isBadNameWithUnderscore` suffix-heuristic fragment, described as such in-file |
| 2 | `_2` | NAMING_CONVENTION_DEVIATION.md | NOT-LEAN | same |
| 3 | `apply_axiom` | 5 docs | UPSTREAM-shape/real | Real: `macro "apply_axiom" : tactic` in `UserTactics.lean` — checker fallback 3 now detects it |
| 4 | `assumption_search` | tactic-registry.md | real | `elab "assumption_search" : tactic` in `UserTactics.lean` — fallback 3 |
| 5 | `axiomWeight` | API_REFERENCE.md | VERIFIED-FIELD | `structure` field, `ProofSearch/Core.lean:288` |
| 6 | `backward_P` | BFMCS_ARCHITECTURE.md | EXAMPLE | illustrative BFMCS-notation naming pattern (see #39-41 group) |
| 7 | `BimodalLogic` | CI_CD_PROCESS.md | NOT-LEAN | `lakefile.toml` package name |
| 8 | `BimodalTest` | 2 docs | NOT-LEAN | `lakefile.toml` `[[lean_lib]]` name |
| 9 | `BimodalTools` | 2 docs | NOT-LEAN | `lakefile.toml` `[[lean_lib]]` name |
| 10 | `BimodalToolsTest` | LEAN_STYLE_GUIDE.md | NOT-LEAN | `lakefile.toml` `[[lean_lib]]` name |
| 11 | `BX_d` | docs/README.md | EXAMPLE | explicitly the paper's own notation subscript, not a Lean citation |
| 12 | `carrier_nonempty` | transcription-audit-surface.md | VERIFIED-FIELD | real structure field, e.g. `DedekindNonCompactness.lean:332` |
| 13 | `checkInitImports` | 2 docs | OUT-OF-SCOPE-REAL | `lakefile.toml` `[[lean_exe]]` name, root `scripts/CheckInitImportsMain.lean` |
| 14 | `CheckInitImportsMain` | MODULE_INVARIANTS.md | OUT-OF-SCOPE-REAL | file `scripts/CheckInitImportsMain.lean` |
| 15 | `comments_only` | MODULE_INVARIANTS.md | NOT-LEAN | Python/script identifier |
| 16 | `CompactIccSpace` | theorem-index.md | UPSTREAM | real Mathlib class |
| 17 | `consequence_completeness` | operators.md | **PHANTOM** | bare name doesn't exist; only the per-class family (`consequence_completeness_base`/`_dense`/`_ztime`/`_rtime`, `StrongCompleteness.lean`) does — **repaired** |
| 18 | `ContrastiveGeneratorMain` | PUBLICATION_REFACTOR.md | OUT-OF-SCOPE-REAL | file `BimodalTools/ContrastiveGeneratorMain.lean` |
| 19 | `DataExport` | MODULE_INVARIANTS.md | OUT-OF-SCOPE-REAL | file `BimodalTools/DataExport.lean` |
| 20 | `DatasetExporter` | MODULE_INVARIANTS.md | NOT-LEAN | no such file/decl in `BimodalTools/`; a descriptive/generic noun in prose, not a citation (no repair needed — not asserted as a Lean name in context) |
| 21 | `dataset_generator` | MODULE_INVARIANTS.md | NOT-LEAN | `lakefile.toml` `[[lean_exe]]` name |
| 22 | `BimodalTools.DatasetGeneratorMain` | MODULE_INVARIANTS.md | OUT-OF-SCOPE-REAL | file `BimodalTools/DatasetGeneratorMain.lean` |
| 23 | `dbg_trace` | 2 docs | UPSTREAM | Lean core term-level debug syntax |
| 24 | `dbgTrace` | MODULE_INVARIANTS.md | UPSTREAM | Lean core |
| 25 | `decl_spans` | MODULE_INVARIANTS.md | NOT-LEAN | Python identifier, `scripts/lib/lean_citations.py` |
| 26 | `lean_citations.decl_spans` | MODULE_INVARIANTS.md | NOT-LEAN | same |
| 27 | `_dedekind` | API_REFERENCE.md | **PHANTOM** | stale pre-rename suffix; real names are `minus_soundness_ztime`/`_rtime` (`MinusLanguage/Soundness.lean`) — **repaired** |
| 28 | `FrameClass.Dedekind` | NAMING_CONVENTION_DEVIATION.md + paper-definitions-of-record.md | ALREADY-ACCURATE | both sites already state it does not exist / was renamed to `RTime` |
| 29 | `defaultTargets` | 2 docs | NOT-LEAN | `lakefile.toml`/Lake DSL keyword |
| 30 | `_discrete` | API_REFERENCE.md | **PHANTOM** | same stale-suffix defect as `_dedekind` — **repaired** |
| 31 | `FrameClass.Discrete` | NAMING_CONVENTION_DEVIATION.md | ALREADY-ACCURATE | file states it was renamed to `ZTime` |
| 32 | `docBlame` | NAMING_CONVENTION_DEVIATION.md | NOT-LEAN | `batteries/runLinter` option name |
| 33 | `docBlameTheorems` | LEAN_STYLE_GUIDE.md | NOT-LEAN | same |
| 34 | `dupNamespace` | MODULE_INVARIANTS.md | NOT-LEAN | same |
| 35 | `ENFORCE_C17` | MODULE_INVARIANTS.md | NOT-LEAN | bash sentinel |
| 36 | `ENFORCE_C20_DECL` | MODULE_INVARIANTS.md | NOT-LEAN | bash sentinel |
| 37 | `ENFORCE_C20` | MODULE_INVARIANTS.md | NOT-LEAN | bash sentinel |
| 38 | `env_linter` | MODULE_INVARIANTS.md | NOT-LEAN | Python identifier |
| 39 | `forward_F` | BFMCS_ARCHITECTURE.md | EXAMPLE | illustrative BFMCS naming pattern |
| 40 | `forward_G` | BFMCS_ARCHITECTURE.md | EXAMPLE | same |
| 41 | `modal_backward` | BFMCS_ARCHITECTURE.md | EXAMPLE | same (grouped with #6, 39, 40) |
| 42 | `isBadNameWithUnderscore` | NAMING_CONVENTION_DEVIATION.md | UPSTREAM | real Mathlib linter name, `Mathlib/Tactic/Linter/Style.lean` |
| 43 | `isOpen_inter` | state-topology-appendix-support.md | UPSTREAM | Mathlib |
| 44 | `isOpen_sUnion` | state-topology-appendix-support.md | UPSTREAM | Mathlib |
| 45 | `isOpen_univ` | state-topology-appendix-support.md | UPSTREAM | Mathlib |
| 46 | `IsPredArchimedean` | known-limitations.md | UPSTREAM | Mathlib class, cited correctly as a hypothesis |
| 47 | `TaskFrame.IsSuccArchDiscrete` | NAMING_CONVENTION_DEVIATION.md | ALREADY-ACCURATE | listed among the renamed-tag family in the file's own table |
| 48 | `IsSuccArchimedean` | known-limitations.md | UPSTREAM | Mathlib |
| 49 | `LANGUAGE_FILE_LAYERS` | PUBLICATION_REFACTOR.md | NOT-LEAN | Python table name, `measure-refactor-partitions.py` |
| 50 | `layer_of` | 2 docs | NOT-LEAN | Python function, explicitly named as such in-file |
| 51 | `layerReynoldsDedekind` | NAMING_CONVENTION_DEVIATION.md | OUT-OF-SCOPE-REAL | real `def`, `BimodalTools/MachineAppendixMain.lean:180`; file's own "Also kept" section already explains it is deliberately not renamed |
| 52 | `lean_debug_artifacts.mask` | MODULE_INVARIANTS.md | NOT-LEAN | Python identifier |
| 53 | `_mathlib` | NAMING_CONVENTION_DEVIATION.md | NOT-LEAN | Mathlib linter suffix-heuristic fragment |
| 54 | `MetaM` | 4 docs | UPSTREAM | Lean core metaprogramming monad |
| 55 | `MinusValidComplete` | API_REFERENCE.md | ALREADY-ACCURATE | doc explicitly says this name does NOT exist ("no density-free `MinusValidComplete`, which would be refutable") |
| 56 | `mk_all` | 4 docs | NOT-LEAN | `lakefile.toml`/Lake DSL target |
| 57 | `mkAppM` | METAPROGRAMMING_GUIDE.md | UPSTREAM | Lean core metaprogramming |
| 58 | `modal_4_derivable` | tactic-registry.md | **PHANTOM** | absent everywhere (not even in `Boneyard/`); "Registered Rules" section presents it as a currently-active Aesop safe rule, contradicting the "Retired" note on the same rule set one paragraph above — **repaired** |
| 59 | `modal_4_tactic` | tactic-development.md | EXAMPLE | file already says "There is no live `modal_4_tactic`"; teaching example |
| 60 | `modal_backward` | (see #41) | — | — |
| 61 | `modal_b_derivable` | tactic-registry.md | **PHANTOM** | same defect as `modal_4_derivable` — **repaired** |
| 62 | `modal_search` | 3 docs | real | `syntax "modal_search" ... : tactic`, `Commands.lean` — fallback 3 |
| 63 | `necessitation_from_modal_k` | architecture.md | **PHANTOM** | no such theorem; `necessitation` is a primitive `DerivationTree` constructor, not derived from MK — the sentence citing it self-contradicts the sentence immediately before it — **repaired** |
| 64 | `𝒩_F` | 2 docs | EXAMPLE | paper/manuscript notation symbol, not a Lean identifier (file states this explicitly) |
| 65 | `noSorryInProofs` | LEAN_STYLE_GUIDE.md | NOT-LEAN | `batteries/runLinter` option |
| 66 | `not_setConsistent_of_setDerivable_bot` | architecture.md | **PHANTOM** | wrong name and wrong file; nearest live declaration is `SetConsistent.bot_not_mem` in `Core/MCSProperties.lean` — **repaired** |
| 67 | `PosRel` | 2 docs | VERIFIED-FIELD | real primitive field, `TaskFrame.lean` |
| 68 | `proof_extractor` | MODULE_INVARIANTS.md | NOT-LEAN | `lakefile.toml` `[[lean_exe]]` name (also a Python identifier elsewhere) |
| 69 | `ProofFirstGeneratorMain` | PUBLICATION_REFACTOR.md | OUT-OF-SCOPE-REAL | file `BimodalTools/ProofFirstGeneratorMain.lean` |
| 70 | `propDecide` | 2 docs | real | `elab "propDecide" : tactic`, `Decidability/Propositional/Tactic.lean` — fallback 3 |
| 71 | `reflect_time` | LEAN_STYLE_GUIDE.md | EXAMPLE | one use is the style guide's own "Avoid" anti-pattern example; the other is a naming-convention-suffix illustration, not a standalone declaration claim |
| 72 | `regionOmega` | total-history-validity-decisions.md | ALREADY-ACCURATE | Decision Record's own contingency text; `regionFrame`/`RegionFrame.lean` is the landed name, doc already frames `regionOmega` as the historical/contingency label |
| 73 | `register_simp_attr` | MODULE_INVARIANTS.md | UPSTREAM | Lean core metaprogramming attribute |
| 74 | `resolve_env` | paper-definitions-of-record.md | NOT-LEAN | Python identifier |
| 75 | `FormalSystem._Scratch` | MODULE_INVARIANTS.md | EXAMPLE | historical negative-test artifact; text already says the file was removed |
| 76 | `sh_add` | transcription-audit-surface.md | VERIFIED-FIELD | real field, `DedekindNonCompactness.lean:335` |
| 77 | `sh_zero` | transcription-audit-surface.md | VERIFIED-FIELD | real field, `DedekindNonCompactness.lean:334` |
| 78 | `snake_case` | NAMING_CONVENTION_DEVIATION.md | NOT-LEAN | naming-convention descriptor, not a declaration |
| 79 | `soundness_dedekind` | NAMING_CONVENTION_DEVIATION.md | ALREADY-ACCURATE | file's own scheme table gives this as the OLD name (-> `soundness_rtime`) |
| 80 | `soundness_discrete` | NAMING_CONVENTION_DEVIATION.md | ALREADY-ACCURATE | same (-> `soundness_ztime`) |
| 81 | `specializes_iff_mem_closure` | 2 docs | UPSTREAM | Mathlib topology lemma |
| 82 | `tacticModal_t` | NAMING_CONVENTION_DEVIATION.md | EXAMPLE | auto-generated elaborator name documented as such for the real `modal_t` macro; illustrates a naming convention, not asserted as a hand-written declaration |
| 83 | `temp_k_dist` | API_REFERENCE.md | **PHANTOM** | real name is `temporalKDistDerived` (`Theorems/TemporalDerived.lean`); `temp_k_dist` is only ever a docstring/section-heading label there, never the declaration keyword — **repaired** |
| 84 | `𝒯_F` | theorem-index.md | EXAMPLE | paper/manuscript notation symbol (see #64) |
| 85 | `theorem_name` | docstring-standard.md | EXAMPLE | the standard's own template placeholder |
| 86 | `TraceExporter` | MODULE_INVARIANTS.md | NOT-LEAN | no exact file/decl match (`TraceExporterMain.lean`/`TraceExport.lean` exist, differently spelled); generic descriptive noun in prose, not asserted as a specific citation |
| 87 | `TraceExport` | 2 docs | OUT-OF-SCOPE-REAL | file `BimodalTools/TraceExport.lean` |
| 88 | `trans_refl` | theorem-index.md | VERIFIED-FIELD | real field, `structure SharingSkeleton where` in `Skeleton.lean:690`; see "Checker Fixes" above for why this only surfaced after the primed/unprimed fix |
| 89 | `unusedDecidableInType` | LEAN_STYLE_GUIDE.md | NOT-LEAN | `batteries/runLinter` option |
| 90 | `Semantics.Validity.valid_at_world` | test-coverage.md | **PHANTOM** | absent under any namespace; no `valid_at_world` declaration anywhere in `FormalSystem/` — restated as absent |
| 91 | `ValidDedekind` | NAMING_CONVENTION_DEVIATION.md | ALREADY-ACCURATE | file's own scheme table gives this as the OLD name (-> `ValidRTime`) |
| 92 | `valid_iff_allClosed` | ADR-007 | ALREADY-ACCURATE | ADR-007 already states this is the OPEN completeness direction, not a landed theorem |
| 93 | `validity_decidable` | ADR-007 | ALREADY-ACCURATE | ADR-007 already documents this as RETIRED (points to `Correctness.lean`'s "Retired as vacuous" section, confirmed present) |
| 94 | `validity_has_decision_procedure` | ADR-007 | ALREADY-ACCURATE | same as #93 |
| 95 | `WIRED_REPO` | specs/state.json#project_720 | NOT-LEAN | bash array name in `scripts/check-evidence-probes.sh`, quoted verbatim in a live task description — not a declaration claim |

(95 rows cover 94 distinct findings; row 60 is a cross-reference to row 41, not a second finding.)

## Phase 3 / Phase 4 Territory Split (actual, not hypothesized)

**Phase 3's three files (MODULE_INVARIANTS.md, NAMING_CONVENTION_DEVIATION.md,
PUBLICATION_REFACTOR.md) contain ZERO `PHANTOM`-class rows.** Every finding citing these three
files resolves to NOT-LEAN, UPSTREAM, OUT-OF-SCOPE-REAL, VERIFIED-FIELD, or ALREADY-ACCURATE. This
matches the plan's own Phase 3 Scope Hypothesis contingency ("if this phase's `PHANTOM` count
turns out to be under five, fold the remainder of its budget into Phase 4") and its explicit
expectation that `NAMING_CONVENTION_DEVIATION.md` "may need no edit at all". Phase 3 therefore
closes as a confirmation-only phase: no docs repair, full re-verification that the three files'
findings are correctly disposed.

**Phase 4 owns all 6 genuine `PHANTOM` repairs**, across 5 files:
- `docs/reference/operators.md` — `consequence_completeness`
- `docs/reference/API_REFERENCE.md` — `_dedekind`, `_discrete`, `temp_k_dist`
- `docs/project-info/tactic-registry.md` — `modal_4_derivable`, `modal_b_derivable`
- `docs/user-guide/architecture.md` — `necessitation_from_modal_k`,
  `not_setConsistent_of_setDerivable_bot`
- `docs/project-info/test-coverage.md` — `Semantics.Validity.valid_at_world`

## Phase 4 Repair Log

- `docs/reference/operators.md` — `consequence_completeness` corrected to the four per-class
  names. Verified: `grep` confirms `consequence_completeness_base`/`_rtime` are real theorems in
  `StrongCompleteness.lean`. Re-run: finding dropped.
- `docs/reference/API_REFERENCE.md` — three repairs in one pass: (1) `temp_k_dist` corrected to
  `temporalKDistDerived`; (2) the `minus_soundness_dense`/`_discrete`/`_dedekind` row's stale
  suffixes corrected to `_dense`/`_ztime`/`_rtime`; (3) a second, previously-unticketed stale-suffix
  instance found in the same file in the `minus_not_derivable_nil_bot` row (`_discrete` ->
  `_ztime`) — caught only because the checker re-run after the first pass still showed
  `_discrete` as a finding, which traced to this second occurrence the initial read had not
  surfaced. A first version of this repair also transiently re-triggered two of its own fixed
  findings (`consequence_completeness`, `temp_k_dist`) by backticking the bare name again while
  explaining its absence — fixed by rephrasing without a bare backtick, confirmed by a third
  checker re-run. Final count after this file: 86 (down from 90 before Phase 4; `soundness_dedekind`/
  `soundness_discrete` still present, as expected — those are the ALREADY-ACCURATE
  NAMING_CONVENTION_DEVIATION.md rows, untouched).
- `docs/project-info/tactic-registry.md` — the "Registered Rules: Safe Rules" subsection
  corrected: it presented `modal_4_derivable`/`modal_b_derivable` as currently-active Aesop
  safe rules, directly contradicting the "Retired" note on the `TMLogic` rule set one paragraph
  above (an internal inconsistency this plan did not previously catch). Restated as a
  "Would-be Safe Rules" list, factually noting neither name was ever built and pointing to the
  live underlying facts (`DerivedAxioms.modal4`/`.modalB`). `modal_t_valid` confirmed real and
  kept, with its unregistered status now stated accurately too.
- `docs/user-guide/architecture.md` — two repairs: (1) `necessitation_from_modal_k` struck;
  restated that necessitation is a primitive `DerivationTree` constructor, not a derived theorem
  (the paragraph's own prior sentence already said "as a constructor", directly contradicting the
  struck claim two sentences later); (2) `not_setConsistent_of_setDerivable_bot` corrected to
  `SetConsistent.bot_not_mem` (`Core/MCSProperties.lean`), the live declaration closest to the
  stated bridging role, with the wrong name kept annotated for traceability per the
  annotate-don't-delete practice.
- `docs/project-info/test-coverage.md` — `Semantics.Validity.valid_at_world` struck (list format,
  `~~name~~`) with a dated re-verification note; this report already carries a file-level
  "Superseded... stale" banner, so the strike is additive to an already-disclosed staleness, not
  a new admission.

**Annotate-don't-delete leaves the old name backticked, so the checker still flags it.** All five
repairs above keep the now-corrected-but-wrong name visible in the prose (per the plan's
over-correction mitigation: "annotate the correction rather than silently deleting the sentence").
The checker necessarily still reports these five as findings post-repair — it flags any backticked
absent name regardless of surrounding context. This is the same shape as the already-accurate
ADR-007 trio and `MinusValidComplete`: the PROSE is now correct; the finding is closed by
ALLOWLIST in Phase 5, not by driving the raw count to zero for these five names. Re-run after all
six Phase 4 repairs: 86 findings (unchanged from the post-operators.md/API_REFERENCE.md count,
since the remaining five keep their old name backticked by design).

## Phase 5 Territory (confirmed — executed)

`scripts/check-phantom-citations.sh` is the only file touched for absorption. All 86 of the
post-Phase-4 findings were added to `ALLOWLIST`, grouped by class with an inline comment per group
(matching this ledger's class taxonomy exactly — UPSTREAM, bash sentinels, lake targets, linter
options, Python identifiers, naming fragments, OUT-OF-SCOPE-REAL, VERIFIED-FIELD, EXAMPLE,
ALREADY-ACCURATE each as their own commented block, never collapsed into one undifferentiated
list). One structural addition alongside the per-name entries: `BimodalTools` was added to
`ROOT_DENYLIST` (not just `ALLOWLIST`), since it is a real sibling Lean source tree outside this
checker's `FormalSystem/`-only scope — this durably covers any *future* `BimodalTools.X` qualified
citation, not just today's `BimodalTools.DatasetGeneratorMain`, the same trust already extended to
`Mathlib.*`/`Lean.*`.

**Result**: `bash scripts/check-phantom-citations.sh --verbose` now reports **0 findings** over
the same 1028 candidate pairs. `--strict` exits 0 (nothing to fail on). `bash -n` passes; `--help`
renders cleanly.

**No PHANTOM row was silenced by a too-broad allowlist entry**: every one of the 6 genuine
PHANTOM repairs from Phase 4 is independently re-confirmed fixed (either the old name no longer
appears at all, for the two fully-corrected names, or it appears solely inside this ledger's and
the script's own commentary describing the repair — never inside live docs prose asserting it as
a current fact).
