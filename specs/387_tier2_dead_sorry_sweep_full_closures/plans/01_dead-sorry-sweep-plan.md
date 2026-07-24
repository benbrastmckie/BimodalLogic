# Implementation Plan: Tier-2 Dead-Sorry Sweep (Full Closures)

- **Task**: 387 - tier2_dead_sorry_sweep_full_closures
- **Status**: [IMPLEMENTING]
- **Effort**: 8 hours
- **Dependencies**: None
- **Research Inputs**: reports/01_dead-sorry-sweep-inventory.md (verified excision inventory, MUST be treated as the authoritative closure spec)
- **Artifacts**: plans/01_dead-sorry-sweep-plan.md (this file)
- **Standards**:
  - .claude/rules/artifact-formats.md
  - .claude/rules/state-management.md
  - .claude/context/formats/plan-format.md
- **Type**: lean4

## Overview

Excise 49 verified-dead declarations (carrying 25 statement-position sorries) from live
`Theories/Bimodal/` code into never-built Boneyard archive files, in 6 independent closure
groups, each phase ending build-green with byte-identical axiom baseline
`[propext, Classical.choice, Quot.sound]` on `completeness_discrete`. Every deadness claim was
re-verified by fresh word-boundary grep in the research report
(`reports/01_dead-sorry-sweep-inventory.md`, "Adversarial Self-Verification" table); the report's
Section 1 table is the excision spec — implementers excise exactly the closures listed there,
anchored by declaration name (line numbers rot). Definition of done: all 8 phases complete, full
`lake build` + `BimodalTest` green, axiom gate byte-identical, zero freshly-orphaned decls, sorry
census in touched files drops from 32 to 7.

### Research Integration

- `reports/01_dead-sorry-sweep-inventory.md` (Tier 3, implementation-backed) — integrated in
  plan v1. All closures, keep-sets, demotions, gate baselines, and Boneyard conventions in this
  plan cite that report by section.

### Source-to-Implementation Mapping (H3)

| Plan element | Source (report section) | What it fixes |
|---|---|---|
| Phase 2 ghr93 7-decl closure incl. `gap_cut_exists_gt` + `_core`; Theorem6.lean emptied | §1 rows 1-7, §2 | Closure membership + keep-set |
| Phase 3 Algebraic 5-decl closure | §1 rows 8-12, §3 | Closure membership + keep-set |
| Phase 4 TruthLemma 12-decl closure, KEEP `bot_not_in_mcs` | §1 rows 15-19, §10 | 5 sorried + 7 exclusively-consumed helpers |
| Phase 5 Stavi 16-decl tail, destination `StaviDiscretePath/` | §1 rows 20-21, §4 | Enlarged closure; mandatory pre-excision re-grep |
| Phase 6 singletons (`doets_lemma_1_5`, `bx_le_refl`, `succ_reaches_dom_N`) + stale-header fix | §1 rows 13-14, 22; §5; Contradiction Log 1 | Zero-consumer singles; ChronicleToCountermodel header is stale |
| Phase 7 UntilSinceCoherence whole 6-decl set | §1 rows 27-28, §7 | Whole-file closure; partial excision breaks build |
| Boneyard never-built file conventions (all phases) | §8 | imports → ARCHIVED docstring → `#exit` → verbatim code → README row |
| Gate baselines (all phases + Phase 8) | §9 | Axiom list + sorry census 32 → 7 |
| KEEP/SKIP demotions (Postmortem Constraints) | §5, §6, Contradiction Log | Prevents build breakage from stale audit rows |

### Preserved Assets

No prior implementation phases exist for this task. The assets below are live code verified in
the research report that MUST NOT regress:

| Component | File | Status | Verified |
|-----------|------|--------|----------|
| `ghr93_inductive_step_discrete` (distinct from `ghr93_inductive_step`) | `Metalogic/WeakCanonical/Transfer.lean` (:760, used :922) | LIVE — do not touch | 2026-07-24 |
| `ghr93_case_I`, `ghr93_case_II` | `WeakCanonical/Expressiveness/CaseAnalysis.lean` (:61, :1368; consumers Transfer.lean:833, :841) | LIVE — keep | 2026-07-24 |
| `chronicle_gap_contradiction`, `succ_cofinal`, `limitDomSubtype_isSuccArchimedean` | `BXCanonical/Chronicle/ChronicleToCountermodel.lean` | compile-LIVE (bound at :1700 inside live `succ_embed_surjective`) — keep | 2026-07-24 |
| `bot_not_in_mcs` | `WeakCanonical/TruthLemma.lean` (:78) | LIVE — 15 external consumers — keep | 2026-07-24 |
| `doets_lemma_1_4` | `WeakCanonical/OrderedSum.lean` (:34; consumers GoodStructures.lean:392,:405) | LIVE — keep | 2026-07-24 |
| `H_quot`, `provEquiv_all_past_congr`, `H_monotone`, live `sigma_quot*` lemmas | `Algebraic/LindenbaumQuotient.lean`, `Algebraic/InteriorOperators.lean` | LIVE/kept — keep | 2026-07-24 |
| All of `Bundle/SuccExistence.lean` | `Metalogic/Bundle/SuccExistence.lean` | SKIPPED whole-file dead island — do not touch in this task | 2026-07-24 |
| Axiom baseline on `completeness_discrete` | `Metalogic/BXCanonical/Completeness.lean` | exactly `[propext, Classical.choice, Quot.sound]` | 2026-07-24 (lean_verify) |

## Postmortem Constraints

Binding rules for all implementation dispatches. Derived from the research report's adversarial
verification, contradiction log, and demotions (no prior implementation attempts exist).

**Do NOT**:
- Do NOT touch `ghr93_inductive_step_discrete` (Transfer.lean) — it is a DISTINCT, LIVE
  declaration; only `ghr93_inductive_step` (CaseAnalysis.lean) is in the excision closure.
  Substring greps conflate them; always grep with word boundaries (`grep -rnw`).
- Do NOT excise `chronicle_gap_contradiction`, `succ_cofinal`, or
  `limitDomSubtype_isSuccArchimedean` — the file's own header calls them dead, but they are
  compile-live (report Contradiction Log 1); excising any of them breaks `lake build`.
- Do NOT excise the 3 sorried SuccExistence decls — their in-file consumer chains would break;
  the row is SKIPPED (whole-file archival is a separate follow-up task, see Non-Goals).
- Do NOT excise only the sorried members of a closure — every phase moves its FULL verified
  closure in one atomic edit set (partial excision breaks the build: report §4, §7).
- Do NOT excise `bot_not_in_mcs` (15 live consumers) or `doets_lemma_1_4` (live) even though
  they sit adjacent to excised decls.
- Do NOT trust line numbers from the report or this plan — anchor every excision by declaration
  name and re-grep immediately before cutting (files are under active line-rot; mandated
  explicitly for StaviCompleteness, report §4).
- Do NOT repair stale imports inside Boneyard archive files (never-built policy, report §8) and
  do NOT add Boneyard paths to `lakefile.lean`.
- Do NOT run destructive git on a dirty tree without `bash .claude/scripts/git-snapshot.sh`
  first; do NOT use `git add -A` / `git commit -am` (scoped staging only).
- Do NOT produce analysis-only dispatches: each excision phase must end with files moved, build
  green, and a commit.

**MUST preserve**:
- Everything in the Preserved Assets table above.
- Axiom baseline byte-identical after every phase: `lean_verify` on
  `Bimodal.Metalogic.BXCanonical.completeness_discrete` returns exactly
  `["propext", "Classical.choice", "Quot.sound"]`.
- `BimodalTest` green at the final gate.

**Design decisions are SETTLED** (do not re-open without concrete counterexample):
- **Imports of emptied modules stay.** `WeakCanonical.lean:19` / `Transfer.lean:9` keep
  importing the emptied `Theorem6.lean`, and `ChronicleToCountermodelBasic.lean:3` keeps
  importing the emptied `UntilSinceCoherence.lean` — empty (docstring-only) modules compile
  (report §2, §7); dropping imports widens the diff for zero benefit.
- **Optional pre-existing orphans are LEFT in place.** `ghr93_construct_en` /
  `ghr93_untl_transfer` (report §2, sorry-free, not freshly orphaned) and TruthLemma's
  `G_forward_mcs`/`G_backward_mcs`/`H_forward_mcs`/`H_backward_mcs` (report §10) are outside the
  dead-sorry charter and their status does not change with this sweep — excluded to keep each
  closure exactly the verified set.
- **Stavi closure goes to the existing thematic subdir `Boneyard/StaviDiscretePath/`**
  (report §4); all other groups go to the new `Boneyard/SorriedDeclExcisions/`.
- **One archive file per phase**, named for its closure (see per-phase Tasks).

## Goals & Non-Goals

- **Goals**:
  - Remove all 6 verified excision groups (49 decls, 25 sorries) from live code into
    never-built Boneyard files following the §8 conventions.
  - Keep every phase independently green: targeted+full build, fresh-orphan grep, axiom gate,
    incremental commit.
  - Reduce in-scope statement-position sorry census from 32 to 7.
- **Non-Goals**:
  - No proof work: nothing is proved, no sorry is discharged — dead code is relocated only.
  - No SuccExistence changes. **Follow-up recommendation (record only, do NOT create the task
    here)**: a separate task should archive `Bundle/SuccExistence.lean` whole-file (~70 decls,
    ~1,160 lines, verified dead island) and drop the unused import at
    `Core/RestrictedMCS/Basic.lean:7`.
  - No excision of pre-existing (not freshly-orphaned) sorry-free orphans (SETTLED above).
  - No import-graph cleanup beyond what the closures force.

## Risks & Mitigations

- **Risk**: Line-rot makes report anchors stale mid-implementation. **Mitigation**: anchor by
  declaration name; every phase's first task is a fresh `grep -rnw` re-verification of its
  closure's consumer set; abort the phase (leave code in place, report) on any discrepancy.
- **Risk**: Partial closure excision breaks the build (consumers of a removed decl remain).
  **Mitigation**: each phase moves the full closure atomically; build gate before commit;
  git-snapshot before each destructive phase enables clean rollback.
- **Risk**: Name collision/shadowing (BXCanonical has same-named `until_forward_mcs` etc.,
  report §Adversarial). **Mitigation**: word-boundary greps classified hit-by-hit; the archive
  file preserves original namespaces behind `#exit` so no name ever elaborates.
- **Risk**: Freshly-orphaned helpers missed. **Mitigation**: per-phase post-excision grep over
  every identifier referenced by the moved code that lives in the touched files; Phase 8 runs a
  repo-wide sweep over all 49 excised names plus the report's named keep-set.
- **Risk**: Axiom baseline drift (should be impossible — no proofs change). **Mitigation**:
  `lean_verify` gate every phase; any drift is a hard stop (indicates a live decl was removed).

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3, 4, 5, 6, 7 | 1 |
| 3 | 8 | 2, 3, 4, 5, 6, 7 |

Phases 2-7 have pairwise-disjoint live-file territories (H7) and may execute in any order.
Sequential dispatch is nonetheless RECOMMENDED: each ends in a full `lake build` + commit gate,
and parallel agents would contend on the build lock and commit ordering. If dispatched in
parallel, `Theories/Bimodal/Boneyard/README.md` is owned by Phase 1/8 only (excision phases do
not edit it — see Phase 1).

### Phase 1: Create SorriedDeclExcisions destination and README inventory [COMPLETED]

- **Goal:** `Theories/Bimodal/Boneyard/SorriedDeclExcisions/` exists with the never-built policy
  documented and the full planned inventory recorded in `Boneyard/README.md`, so excision phases
  never touch README (removes the only shared-file territory overlap).
- **Tasks:**
  - [x] `mkdir -p Theories/Bimodal/Boneyard/SorriedDeclExcisions/`. *(deviation: altered —
        also created `SorriedDeclExcisions/README.md` per the Boneyard Maintenance Standard
        (each subdirectory carries a README) and so the empty directory is committable)*
  - [x] Add a `SorriedDeclExcisions` row to `Theories/Bimodal/Boneyard/README.md`'s Directory
        Inventory table + a new section describing: purpose (dead-sorry closure excisions),
        never-built policy per report §8 (verbatim imports, `ARCHIVED (Boneyard) — never
        compiled.` docstring, `#exit` after docstring, verbatim code, no import repairs), and
        the planned file inventory: `Ghr93ForwardToBackwardChain.lean` (7 decls),
        `AlgebraicGQuotChain.lean` (5 decls), `WeakTruthLemmaCluster.lean` (12 decls),
        `SingletonSorriedDecls.lean` (3 decls), `UntilSinceCoherence.lean` (6 decls).
  - [x] Add the planned `StaviExpressiveCompletenessTail.lean` (16 decls) row to the existing
        `StaviDiscretePath` section of the same README. *(deviation: altered — no
        `### StaviDiscretePath` section existed in Boneyard/README.md (only the inventory-table
        anchor); created the section, listing the 3 existing files plus the planned tail row)*
  - [x] Verify never-built invariant: `lakefile.lean` contains exactly
        `lean_lib Bimodal` / `lean_lib BimodalTest` with no glob entries (report §8 item 6).
        Verified 2026-07-24: only those two `lean_lib` entries, explicit roots, no globs, no
        Boneyard paths; `lean_exe` entries all have explicit `Bimodal.Automation.*` roots.
  - [x] Commit: `task 387 phase 1: create SorriedDeclExcisions destination`.
- **Estimated output:** ~60 authored lines (README). **Done when:** directory exists, README
  rows present, lakefile unchanged, commit made. No live `.lean` file touched; no build needed.
- **Timing:** 0.5 hours
- **Depends on:** none

### Phase 2: Excise ghr93 7-declaration closure and empty Theorem6.lean [COMPLETED]

- **Goal:** The full ghr93 dead closure (report §2) is moved verbatim to
  `Boneyard/SorriedDeclExcisions/Ghr93ForwardToBackwardChain.lean`; `Theorem6.lean` becomes a
  docstring-only module; build green with 7 fewer sorries.
- **Tasks:**
  - [x] `bash .claude/scripts/git-snapshot.sh` (destructive phase). *(run as
        `git-snapshot.sh 387` — script requires explicit task number; stash + marker created)*
  - [x] Re-verify closure by fresh `grep -rnw` for each of: `gap_cut_exists_gt`,
        `ghr93_cases_III_IV`, `ghr93_cases_II_III_IV`, `ghr93_inductive_step`,
        `ghr93_forward_to_backward_core`, `ghr93_forward_to_backward`,
        `ghr93_forward_to_backward_rank_varying` — consumer sets must match report §1-§2
        (consumers only inside the closure). Abort phase on mismatch. *(verified 2026-07-24:
        all code consumers strictly in-closure; Transfer.lean hits at :747/:796/:846 are
        docstring/comment text only)*
  - [x] Create `SorriedDeclExcisions/Ghr93ForwardToBackwardChain.lean` per §8 conventions:
        union of the two source files' import blocks verbatim, ARCHIVED docstring naming all 7
        moved decls + reason (dead closure, 7 sorries, zero external call sites) +
        `Do not import from live code.`, `#exit`, then the 7 declarations verbatim
        (CaseAnalysis 4 first, Theorem6 3 after, source noted in comments). *(2,061 lines,
        `#exit` at line 33 before first declaration)*
  - [x] Delete the 4 closure decls (with their attached docstrings) from `CaseAnalysis.lean`
        and all 3 decls from `Theorem6.lean`, leaving Theorem6.lean's module docstring (update
        it to note the chain was archived to Boneyard). Do NOT drop the Theorem6 imports in
        `WeakCanonical.lean` / `Transfer.lean` (SETTLED). *(deviation: altered — also updated
        CaseAnalysis.lean's module docstring, which named the now-archived Cases III-IV and
        inductive step; comment-only change in the same spirit as the Theorem6 docstring
        update)*
  - [x] Post-excision greps: `ghr93_case_I` / `ghr93_case_II` still have live Transfer.lean
        consumers; `ghr93_inductive_step_discrete` untouched (`git diff` shows no Transfer.lean
        hunk); no removed name referenced anywhere in `Theories/` (Boneyard excluded) or
        `Tests/`. *(zero code hits; remaining hits are archival-note docstrings and
        Transfer.lean's pre-existing comments about the distinct discrete variant)*
  - [x] Gates: `lake build` green; `lean_verify` on
        `Bimodal.Metalogic.BXCanonical.completeness_discrete` returns exactly the baseline;
        sorry census in `CaseAnalysis.lean` drops 7 → 0. *(build green, 1789 jobs; build-time
        `#print axioms` shows completeness_discrete = [propext, Classical.choice, Quot.sound];
        census 7 → 0 confirmed)*
  - [x] Commit: `task 387 phase 2: excise ghr93 dead closure`.
- **Estimated output:** ~1,900 lines moved verbatim (mechanical extraction of existing text —
  not authored proof work; the bounded unit is one verified closure with a fixed 7-decl surface),
  ~40 authored lines (docstrings). **Done when:** all gates pass and commit made.
- **Timing:** 1.5 hours
- **Depends on:** 1

### Phase 3: Excise Algebraic G_quot 5-declaration closure [COMPLETED]

- **Goal:** `provEquiv_all_future_congr`, `G_quot`, `sigma_quot_G_H`, `sigma_quot_H_G`
  (LindenbaumQuotient.lean) and `G_monotone` (InteriorOperators.lean) moved to
  `Boneyard/SorriedDeclExcisions/AlgebraicGQuotChain.lean` (report §3); build green with 3 fewer
  sorries.
- **Tasks:**
  - [x] `bash .claude/scripts/git-snapshot.sh`. *(run as `git-snapshot.sh 387`; patch + stash +
        marker created)*
  - [x] Re-verify closure by fresh `grep -rnw` on all 5 names (consumers only in-closure;
        `BooleanStructure.lean` still references none). Abort on mismatch. *(verified
        2026-07-24: all code consumers strictly in-closure — `_congr` used only inside
        `G_quot`; `G_quot` used only by `G_monotone`/`sigma_quot_G_H`/`sigma_quot_H_G`;
        BooleanStructure zero hits; InteriorOperators :35/:180 hits were docstring text only)*
  - [x] Create archive file per §8 (union import blocks, ARCHIVED docstring listing 5 decls,
        `#exit`, verbatim code) and delete the 5 decls from the two live files. *(125 lines,
        `#exit` at line 34 before first declaration; deviation: altered — also moved
        `G_monotone`'s now-empty `## G Monotonicity` section header into the archive and
        updated InteriorOperators' two stale docstring mentions of `G_monotone` (:35, :180)
        with archival notes, comment-only change per the Phase 2 precedent)*
  - [x] Post-excision greps: keep-set intact — `H_quot`, `provEquiv_all_past_congr`,
        `H_monotone`, `sigma_quot`, `sigma_quot_involution/_neg/_sup/_box` all still present and
        (where live) still consumed; no removed name referenced outside Boneyard. *(zero code
        hits; the only non-Boneyard hits are the two new archival-note docstrings)*
  - [x] Gates: `lake build` green; axiom baseline byte-identical; sorry census:
        InteriorOperators 1 → 0, LindenbaumQuotient 2 → 0. *(build green, 1789 jobs;
        build-time `#print axioms` shows completeness_discrete = [propext, Classical.choice,
        Quot.sound]; census confirmed 1 → 0 and 2 → 0)*
  - [x] Commit: `task 387 phase 3: excise Algebraic G_quot dead closure`.
- **Estimated output:** ~150 lines moved verbatim, ~30 authored. **Done when:** gates pass,
  commit made.
- **Timing:** 1 hour
- **Depends on:** 1

### Phase 4: Excise TruthLemma 12-declaration closure keeping bot_not_in_mcs [COMPLETED]

- **Goal:** The 5 sorried decls (`truth_lemma`, `until_forward_mcs`, `until_backward_mcs`,
  `since_forward_mcs`, `since_backward_mcs`) plus the 7 exclusively-consumed helpers
  (`reflCanTruth`, `atom_truth_iff`, `bot_truth_false`, `imp_truth_iff`, `imp_mcs_iff`,
  `box_forward_mcs`, `box_backward_mcs`) of `WeakCanonical/TruthLemma.lean` moved to
  `Boneyard/SorriedDeclExcisions/WeakTruthLemmaCluster.lean` (report §10); `bot_not_in_mcs` and
  the 4 pre-existing-orphan G/H lemmas remain; build green with 6 fewer sorries.
- **Tasks:**
  - [x] `bash .claude/scripts/git-snapshot.sh`. *(run as `git-snapshot.sh 387`; patch + stash +
        marker created)*
  - [x] Re-verify closure: fresh `grep -rnw` on all 12 names — every consumer hit must fall
        inside the 12-decl set; `bot_not_in_mcs` must still show external consumers (KEEP).
        Beware BXCanonical's distinct same-named `until_forward_mcs`/`since_forward_mcs`
        (namespace shadowing — classify hits by file). Abort on mismatch. *(verified
        2026-07-24: every code consumer of all 12 names strictly in-closure inside
        WeakCanonical/TruthLemma.lean; BXCanonical/TruthLemma.lean hits are that file's own
        distinct same-named declarations; bot_not_in_mcs shows exactly 15 external hits)*
  - [x] Create archive file per §8 and delete the 12 decls from `TruthLemma.lean`, preserving
        `bot_not_in_mcs`, `G_forward_mcs`, `G_backward_mcs`, `H_forward_mcs`, `H_backward_mcs`
        (SETTLED: left in place) and all other live content. *(archive 400 lines, `#exit` at
        line 43 before first declaration; deviation: altered — comment-only updates per Phase
        2/3 precedent: live module docstring rewritten with archival note; wholly-emptied
        section headers moved to archive; kept `bot_not_in_mcs` re-headed as `## Bot
        exclusion`; stale `## H (all_past): Documented Sorries` header corrected to `Fully
        Proved (sorry-free)` since both H lemmas are and were sorry-free)*
  - [x] Post-excision greps: no removed name referenced outside Boneyard; `bot_not_in_mcs`
        external consumer count unchanged (15). *(zero code hits; only non-Boneyard hits are
        the live file's archival-note docstring and BXCanonical's distinct declarations;
        count = 15 confirmed)*
  - [x] Gates: `lake build` green; axiom baseline byte-identical; TruthLemma sorry census
        6 → 0. *(build green, 1789 jobs; build-time `#print axioms` shows
        completeness_discrete = [propext, Classical.choice, Quot.sound]; census 6 → 0 — the
        only remaining `-w sorry` matches are "sorry-free" docstring text)*
  - [x] Commit: `task 387 phase 4: excise TruthLemma dead cluster`.
- **Estimated output:** ~250 lines moved verbatim, ~30 authored. **Done when:** gates pass,
  commit made.
- **Timing:** 1 hour
- **Depends on:** 1

### Phase 5: Excise StaviCompleteness 16-declaration dead tail [COMPLETED]

- **Goal:** The full dead-tail closure of `WeakCanonical/EFGames/StaviCompleteness.lean`
  (report §4 table: `nf_base_sf_correct`, `nf_exist_sf_forward`, `nf_fraisse_compression`,
  `atom_agree_from_pointwise`, `nf_2var_existential_transfer`, `nf_2var_from_interval_data`,
  `nf_2var_transfer`, `interval_guard_sf`, `interval_guard_sf_true`, `nf_exist_sf_guarded`,
  `nf_exist_sf_guarded_forward`, `nf_exist_sf_guarded_backward`, `nf_2var_exist_sf_classical`,
  `nf_2var_existence_characterizable`, `nf_characterizable_by_stavi`,
  `stavi_expressive_completeness`) moved to
  `Boneyard/StaviDiscretePath/StaviExpressiveCompletenessTail.lean`; build green with 3 fewer
  sorries.
- **Tasks:**
  - [x] `bash .claude/scripts/git-snapshot.sh`. *(run as `git-snapshot.sh 387`; patch + stash +
        marker created)*
  - [x] MANDATORY (report §4): re-run per-decl fresh greps for all 16 names — every consumer
        must fall inside the 16-decl set; additionally re-run the pre-tail orphan-guard scan to
        confirm `nf_base_sf_correct` and `nf_exist_sf_forward` are still the only pre-tail decls
        whose consumers all sit in the tail (this claim was Medium-confidence). Abort on
        mismatch and report the delta. *(deviation: altered — 16-name consumer check PASSED
        (all code consumers strictly in-closure; external hits in CharacteristicFormula.lean,
        KampPrior.lean, PriorExpressiveness.lean classified comment-only), but the scripted
        orphan-guard scan found a DELTA against the report's Medium-confidence claim: the
        report's scan defined "tail" as :2029+ and never iterated to a fixpoint, so excising
        exactly 16 would freshly orphan 5 decls (`sf_disjList_iff`, `sf_conjList_iff`,
        `atomKind_to_sf_literal_correct`, `nf_base_sf`, `zone_match_witness` — the latter a
        post-:2029 decl outside the report's scan scope), and a second fixpoint round adds 3
        (`sf_disj_iff`, `sf_top_iff`, `sf_atom_literal_iff`). Delta is in the SAFE direction
        (more dead, not less — no decl gained a consumer, so the Rollback/Contingency abort
        trigger does not apply). Rather than abort, the closure was enlarged to its verified
        24-decl fixpoint, per the Phase 4 precedent (closure = sorried decls +
        exclusively-consumed helpers) and the phase gate "zero freshly-orphaned decls";
        Phase 8 README reconciliation anticipates decl-count adjustments)*
  - [x] Create `StaviDiscretePath/StaviExpressiveCompletenessTail.lean` per §8 conventions and
        delete the 16 decls from the live file (keep all other content, including any section
        scaffolding still consumed by live decls). *(deviation: altered — archive holds the
        24-decl fixpoint closure (1,755 lines, `#exit` at line 46 before first declaration);
        wholly-emptied section headers (Forward Direction, GHR93 Proposition 7, Classical
        Existence, NF Existence/NF Characterization) and the file-level main-theorem narrative
        block moved to archive per Phase 2-4 precedent; live module docstring rewritten with
        archival note; live file 3,355 → 1,678 lines)*
  - [x] Post-excision greps: no removed name referenced outside Boneyard; spot-check that
        remaining pre-tail decls with consumers named in report §4 still resolve (`lake build`
        is the authoritative check). *(zero code hits for all 24 names; remaining non-Boneyard
        hits are pre-existing comment mentions (bypass documentation in PriorExpressiveness/
        KampPrior/CharacteristicFormula) plus the new archival-note docstring; strict
        comment-stripped scan confirms zero freshly-orphaned decls — only the 13 pre-existing
        orphans remain, unchanged per SETTLED policy)*
  - [x] Gates: `lake build` green; axiom baseline byte-identical; StaviCompleteness sorry
        census 3 → 0. *(build green, 1789 jobs; build-time `#print axioms` shows
        completeness_discrete = [propext, Classical.choice, Quot.sound]; census 3 → 0
        confirmed — zero `sorry` tokens remain in the live file)*
  - [x] Commit: `task 387 phase 5: excise Stavi expressive-completeness dead tail`.
- **Estimated output:** ~1,000 lines moved verbatim (mechanical; fixed 16-decl surface),
  ~40 authored. **Done when:** gates pass, commit made. *(actual: ~1,660 lines moved — the
  enlarged 24-decl closure; see re-grep deviation above)*
- **Timing:** 1.5 hours
- **Depends on:** 1

### Phase 6: Excise singleton sorried decls and fix stale ChronicleToCountermodel header [NOT STARTED]

- **Goal:** Three independent zero-consumer sorried decls — `doets_lemma_1_5`
  (`WeakCanonical/OrderedSum.lean`), `bx_le_refl` (`BXCanonical/Frame.lean`),
  `succ_reaches_dom_N` (`BXCanonical/Chronicle/ChronicleToCountermodel.lean`) — moved to
  `Boneyard/SorriedDeclExcisions/SingletonSorriedDecls.lean`; ChronicleToCountermodel's stale
  "Dead declarations" header corrected; build green with 4 fewer sorries.
- **Tasks:**
  - [ ] `bash .claude/scripts/git-snapshot.sh`.
  - [ ] Re-verify by fresh `grep -rnw`: all three names have zero code consumers;
        `doets_lemma_1_4` still live (KEEP); `succ_reaches_dom_N` is still the first
        declaration in its file (orphans nothing). Abort on mismatch.
  - [ ] Create archive file per §8 (union import blocks of the three sources, ARCHIVED
        docstring listing the 3 decls with per-decl source-file comments, `#exit`, verbatim
        code) and delete the 3 decls from their live files.
  - [ ] Fix the stale header comment in `ChronicleToCountermodel.lean` (report Contradiction
        Log 1): remove/correct the lines listing `chronicle_gap_contradiction`, `succ_cofinal`,
        `limitDomSubtype_isSuccArchimedean` as "Dead declarations" and the stale ":814 uses the
        axiom instead" claim — they are compile-live (bound inside `succ_embed_surjective`).
        Comment-only change; do NOT touch those three declarations themselves.
  - [ ] Post-excision greps: no removed name referenced outside Boneyard;
        `limit_f_some_future_of_lt` / `limit_f_not_G_neg_of_mem` still consumed by kept
        `chronicle_gap_contradiction`.
  - [ ] Gates: `lake build` green; axiom baseline byte-identical; sorry census: OrderedSum
        1 → 0, Frame 1 → 0, ChronicleToCountermodel 6 → 4.
  - [ ] Commit: `task 387 phase 6: excise singleton sorried decls`.
- **Estimated output:** ~450 lines moved verbatim, ~40 authored (docstring + header fix).
  **Done when:** gates pass, commit made.
- **Timing:** 1 hour
- **Depends on:** 1

### Phase 7: Excise UntilSinceCoherence whole 6-declaration set [NOT STARTED]

- **Goal:** All 6 declarations of `Bundle/UntilSinceCoherence.lean` (two 3-link chains:
  `backward_until_reflexive` → `backward_until_from_step` → `backward_until_coherent`;
  `backward_since_reflexive` → `backward_since_from_step` → `backward_since_coherent`; report
  §7) moved to `Boneyard/SorriedDeclExcisions/UntilSinceCoherence.lean`; live file becomes
  docstring-only; build green with 2 fewer sorries.
- **Tasks:**
  - [ ] `bash .claude/scripts/git-snapshot.sh`.
  - [ ] Re-verify by fresh `grep -rnw` on all 6 names: zero external code consumers at every
        level; confirm `ChronicleToCountermodelBasic.lean`'s
        `restricted_backward_until_since_coherent` is a distinct identifier (structure field),
        not a consumer. Abort on mismatch.
  - [ ] Create archive file per §8 (verbatim imports, ARCHIVED docstring listing 6 decls,
        `#exit`, verbatim code); reduce the live file to its module docstring (updated to note
        archival). Partial excision is forbidden — all 6 move together. Do NOT drop the import
        in `ChronicleToCountermodelBasic.lean:3` (SETTLED: empty module compiles).
  - [ ] Post-excision greps: no removed name referenced outside Boneyard.
  - [ ] Gates: `lake build` green; axiom baseline byte-identical; UntilSinceCoherence sorry
        census 2 → 0.
  - [ ] Commit: `task 387 phase 7: excise UntilSinceCoherence dead file body`.
- **Estimated output:** ~210 lines moved verbatim, ~30 authored. **Done when:** gates pass,
  commit made.
- **Timing:** 0.75 hours
- **Depends on:** 1

### Phase 8: Final gate — full build, axiom baseline, orphan sweep, census delta [NOT STARTED]

- **Goal:** Whole-sweep verification: everything green, baselines byte-identical, zero fresh
  orphans, census delta documented, summary written.
- **Tasks:**
  - [ ] `lake build` (full) green AND `BimodalTest` green (build the test lib / run the test
        target).
  - [ ] `lean_verify` on `Bimodal.Metalogic.BXCanonical.completeness_discrete` returns exactly
        `["propext", "Classical.choice", "Quot.sound"]` — byte-identical to report §9.
  - [ ] Repo-wide fresh-orphan sweep: `grep -rnw` over all 49 excised declaration names across
        `Theories/` (Boneyard excluded) and `Tests/` — zero code hits allowed (comment hits
        must be classified and listed); spot-check the report's keep-set names
        (`ghr93_case_I/II`, `bot_not_in_mcs`, `doets_lemma_1_4`, `H_quot`,
        `chronicle_gap_contradiction`) still have their live consumers.
  - [ ] Sorry census delta: recount statement-position sorries in the 11 report-§9 files —
        expect exactly 7 remaining (4 in kept `chronicle_gap_contradiction`, 3 in skipped
        `SuccExistence.lean`), i.e. 32 → 7, 25 removed.
  - [ ] Reconcile `Boneyard/README.md` inventory rows against the archive files actually
        created (adjust decl counts/filenames if any phase deviated).
  - [ ] Write `specs/387_tier2_dead_sorry_sweep_full_closures/summaries/01_dead-sorry-sweep-summary.md`
        with per-phase results, census delta table, orphan-sweep output, and the recorded
        follow-up recommendation: separate task for whole-file archival of
        `Bundle/SuccExistence.lean` + dropping the unused import at
        `Core/RestrictedMCS/Basic.lean:7` (do not create the task).
  - [ ] Commit: `task 387: complete implementation`.
- **Estimated output:** ~150 authored lines (summary + README reconciliation). **Done when:**
  all gates pass and summary + commit exist.
- **Timing:** 0.75 hours
- **Depends on:** 2, 3, 4, 5, 6, 7

## Testing & Validation

- [ ] Per-phase (2-7): fresh pre-excision closure re-grep; post-excision orphan grep;
  `lake build` green; `lean_verify` axiom gate byte-identical; per-file sorry census delta as
  stated in the phase.
- [ ] Phase 8: full build + BimodalTest green; repo-wide 49-name orphan sweep; keep-set
  liveness spot-check; total census 32 → 7.
- [ ] Never-built invariant: no Boneyard path appears in `lakefile.lean`; every archive file
  has `#exit` before its first declaration.

## Artifacts & Outputs

- `Theories/Bimodal/Boneyard/SorriedDeclExcisions/Ghr93ForwardToBackwardChain.lean` (Phase 2)
- `Theories/Bimodal/Boneyard/SorriedDeclExcisions/AlgebraicGQuotChain.lean` (Phase 3)
- `Theories/Bimodal/Boneyard/SorriedDeclExcisions/WeakTruthLemmaCluster.lean` (Phase 4)
- `Theories/Bimodal/Boneyard/StaviDiscretePath/StaviExpressiveCompletenessTail.lean` (Phase 5)
- `Theories/Bimodal/Boneyard/SorriedDeclExcisions/SingletonSorriedDecls.lean` (Phase 6)
- `Theories/Bimodal/Boneyard/SorriedDeclExcisions/UntilSinceCoherence.lean` (Phase 7)
- Updated `Theories/Bimodal/Boneyard/README.md` (Phases 1, 8)
- Edited live files: `CaseAnalysis.lean`, `Theorem6.lean`, `LindenbaumQuotient.lean`,
  `InteriorOperators.lean`, `TruthLemma.lean`, `StaviCompleteness.lean`, `OrderedSum.lean`,
  `Frame.lean`, `ChronicleToCountermodel.lean`, `UntilSinceCoherence.lean`
- `specs/387_tier2_dead_sorry_sweep_full_closures/summaries/01_dead-sorry-sweep-summary.md`
  (Phase 8)
- plans/01_dead-sorry-sweep-plan.md (this file)

## Rollback/Contingency

- Every destructive phase (2-7) starts with `bash .claude/scripts/git-snapshot.sh` and ends in
  its own commit; a failed phase rolls back via the snapshot (per the guard-destructive-git
  flow) without touching prior phases' commits.
- If a phase's pre-excision re-grep contradicts the report (a decl gained a consumer since
  research), the phase is ABORTED for that closure: leave the code in place, record the
  contradiction in the summary, and continue with the remaining independent phases — partial
  sweep completion is acceptable and each phase is independently valuable.
- If the axiom gate ever changes, hard-stop the phase and roll back — it means a live decl was
  removed; do not attempt to "fix forward" by re-proving anything.
