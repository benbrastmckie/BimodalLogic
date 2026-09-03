# Implementation Summary: Core MCS API Consolidation

- **Task**: 526 — Consolidate the maximal-consistent-set API in `FormalSystem/Metalogic/Core/`
- **Plan**: `specs/526_core_mcs_api_consolidation/plans/01_core-mcs-api-consolidation.md`
- **Status**: COMPLETED — all 11 phases `[COMPLETED]`
- **Type**: lean4

## What Landed

| Phase | Outcome | Commit |
|-------|---------|--------|
| 1 | Three new `Core/MCSProperties.lean` declarations in one edit | `a53a1d1a9` |
| 2 | One generic Zorn lemma + two instantiations; four dead superset definitions deleted | `dc837b505` |
| 3 | Four boundedness lemmas retired to `Boneyard/RestrictedMCSBoundedness/` | `4bebf5796` |
| 4 | One `bot_not_mem`; four copies deleted, nine call sites re-pointed | `1f240e3f8` |
| 5 | `someFuture_mono` / `somePast_mono` + the 13-site sweep | `3e1dc615d` |
| 6 | `DerivationTree.ofWeakeningNil` + height lemmas, and the BaseLanguage twin | `40e4cc3e4` |
| 7 | `mp_of_theorem` sweep A — 57 sites, 2 files | `12b3429cb` |
| 8 | `mp_of_theorem` sweep B — 57 sites, 3 files | `37219eda3` |
| 9 | `mp_of_theorem` sweep C — 38 sites, 4 files | `26ec53ef1` |
| 10 | `mp_of_theorem` sweep D — 44 sites, 16 files | `1619eb9c1` |
| 11 | `Core/README.md` refresh, `mcs_auto` rejection record, final gate | this commit |

New declarations: `exists_maximal_of_chainClosed`, `SetConsistent.bot_not_mem`,
`SetMaximalConsistent.bot_not_mem`, `SetMaximalConsistent.mp_of_theorem`, `someFuture_mono`,
`somePast_mono`, `DerivationTree.ofWeakeningNil` (+2 height lemmas) and its BaseLanguage twin.

## Acceptance Criteria

| Criterion | Result | Evidence |
|-----------|--------|----------|
| One Zorn lemma in `Core/` | PASS | `exists_maximal_of_chainClosed`; both Lindenbaums are instantiations |
| Four boundedness lemmas retired | PASS | 0 live references; archived with README + inventory row |
| One `bot_not_mem` in the live tree | PASS | `grep -rn bot_not_in_mcs FormalSystem \| grep -v Boneyard` → 0 |
| Zero inline `right_mono_until`-with-top in `Bundle/` | PASS | 0 occurrences of `right_mono_until` in `Bundle/` at all |
| `Transfer.lean` no longer imports BXCanonical *for a one-liner* | PASS | one-liner dependency gone; import retained for 7 `imp_iff_mcs` sites + `ChronicleAsPriorModel` |
| Zero composite `implication_property … theorem_in_mcs …` in consumers | PASS | repo-wide scan → 2, both inside `mp_of_theorem`'s own declaration |
| `mcs_auto` decision recorded | PASS | `Core/README.md` "Decision Record" — decision = reject, blockers named |
| No `MCSAesop.lean` / Aesop rule set / `mcs_auto` macro | PASS | none in the tree; the only `declare_aesop_rule_sets` is the pre-existing, unrelated `TMLogic` set in `Automation/AesopRuleSet.lean` |
| `lake build` green | PASS | `Build completed successfully (2522 jobs)`, guarded + detached |
| C2 axiom baseline unchanged | PASS | `PASS C2 all four flagship axiom sets match baseline` |
| Zero structural `sorry`, zero new axioms | PASS | `PASS C3 structural sorry inventory is ZERO`; zero real `axiom` declarations in the live tree |
| Full invariants gate | PASS | `ALL CHECKS PASSED` — B0, C1–C15, C9D |

## Scope Findings (implementer's scan is authoritative)

The `mp_of_theorem` sweep covered **196 genuine sites across 25 files**, matching report §5's 197
rather than the planning re-scan's 174. The re-scan's regex undercounted for two reasons, both
regex limitations rather than tree drift: a *parenthesized* MCS argument (`(h_mcs t)`) defeats its
`\S+`, and the dot-notation surface form `h_mcs.implication_property (theorem_in_mcs h_mcs d) x`
is invisible to it entirely — that second form accounts for all 11 sites in
`WeakCanonical/ReflexiveCanonical.lean`, which the re-scan scored at 8. A paren-matching parser
handling both surface forms was used instead.

Five consumer files appeared that neither the report nor the re-scan listed:
`Bundle/RealExtensionBundle.lean` (3), `Chronicle/ChronicleMonadicBridge.lean` (3),
`WeakCanonical/IntegerModel/ReynoldsBridge.lean` (1), `WeakCanonical/GroupModel/CountermodelBase.lean` (1),
`Chronicle/ChronicleToCountermodel.lean` (1).

`bot_not_in_mcs` likewise had **nine** external call sites, not the six the plan enumerated: three
more live in `WeakCanonical/IntegerModel/ReynoldsBridge.lean`.

## Plan Deviations

- **Phase 3 — altered**: the plan cited "sibling-aggregator convention per invariant C8" for the
  new Boneyard module, but C8 explicitly skips `Boneyard`. Followed the archive's own documented
  standard (`Boneyard/README.md`, "How to Archive Files") instead: a subdirectory with a
  `README.md` and the `.lean` file, a Directory Inventory row, and refreshed archive counts
  (162→163 files, 90,535→90,797 lines, 36→37 subdirectories).
- **Phase 4 — altered**: `WeakCanonical/TruthLemma.lean`'s `ReflCanDomain` copy had *zero* call
  sites, so it was deleted outright rather than re-pointed as the plan anticipated; and the
  BXCanonical copy had nine call sites, not six.
- **Phase 4 — altered**: `Transfer.lean` keeps its BXCanonical import (7 live `imp_iff_mcs` uses
  plus `ChronicleAsPriorModel`). The criterion is about the *one-liner* dependency, which is gone.
- **Phase 5 — altered** (recorded by the earlier dispatch): `Automation/ProofStepExport.lean:60`'s
  list documents exported `mkEntry` rows, not every computable theorem, so it needed no edit.
- **Phase 8 — altered**: the criterion "`right_mono_until` still absent from `RRelation.lean`" is
  stricter than the tree. That file keeps 7 occurrences — 4 docstring mentions and 3 genuine axiom
  applications whose third argument is not `Formula.top`, which were never in scope. Phase 5's 4
  with-top blocks are confirmed gone, replaced by 4 `someFuture_mono` uses.
- **Phase 10 — altered**: the criterion "a repo-wide scan returns 0" is unachievable as written —
  `mp_of_theorem`'s own body *is* the composite. The scan correctly settles at 2, both inside that
  one declaration. Every consumer site is 0.

## Notes for Future Work

One transformation defect was found and fixed mid-flight, worth recording because it is silent:
when a collapsed application is wrapped onto a continuation line, the continuation must be
indented strictly more than the **innermost open tactic keyword** on that line, not merely more
than the line's leading whitespace. A `      · have h := <expr>` shape puts `have` at column 8, so
a continuation at column 8 parses as a *new tactic* — it broke `CanonicalModel.lean:750` with a
misleading "unknown tactic" / "don't know how to synthesize implicit argument" cascade. The three
affected files were restored from `HEAD` via `git show` (no destructive git), the indent rule
re-anchored on the keyword, and all 43 wrapped sites across the task re-validated.
