# Implementation Plan: Boneyard Archive Hygiene — No Live Imports
- **Task**: 359 - boneyard_archive_hygiene_no_live_imports
- **Status**: [COMPLETED]
- **Effort**: 5 hours
- **Dependencies**: None (task 385 archival work is complete and is a preserved asset, not a blocker)
- **Research Inputs**: reports/01_boneyard-hygiene-audit.md (fully integrated; specs are settled — do NOT re-litigate)
- **Artifacts**: plans/01_boneyard-hygiene-plan.md (this file)
- **Standards**:
  - .claude/context/formats/plan-format.md
  - .claude/rules/artifact-formats.md
  - .claude/rules/state-management.md
  - .claude/rules/no-task-references-in-deliverables.md
  - .claude/extensions/lean/context/contracts/reference-grounding.md (Tier 3)
- **Type**: lean4 (hard mode)

## Overview

The charter's headline invariant — no live imports into either Boneyard — ALREADY HOLDS
(research report §(a): 3 grep patterns, 0 hits; the "~3 remaining live imports" charter text
predates the Kamp archival that moved both importers). The promotion list is EMPTY and is
closed by verification alone. Remaining work is: (1) archive the dead 4-decl CarrierK1V
`endInterval` skeleton to the Kamp Boneyard; (2) retire the EANegation sorried pair plus its
dead support closure (making `EANegation.lean` sorry-free) with the impossibility note and
Rabinovich labels preserved verbatim; (3) mechanically normalize `#exit` placement and
`ARCHIVED (Boneyard)` headers across all Boneyard files; (4) reconcile both Boneyard README
inventories and run the final verification gate.

**Definition of done**: all five gates in "Testing & Validation" pass, in particular full-tree
`lake build` + `lake build BimodalTest` GREEN and the `completeness_discrete` axiom baseline
byte-identical to `[propext, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler,
Quot.sound]` with no `sorryAx`.

### Research Integration

- `reports/01_boneyard-hygiene-audit.md` — sole grounding source (Tier 3,
  implementation-backed; every load-bearing claim in this plan cites a report section). All
  decl lists, line numbers, consumer evidence, and destinations below are copied from the
  report's verified tables, not re-derived.

### Source-to-Implementation Mapping (Tier 3)

| Report finding | Report section | Plan phase |
|---|---|---|
| Promotion list EMPTY (invariant already holds) | §(a) | Phase 4 (re-verify gate only; no code work) |
| B1: CarrierK1V `endInterval` skeleton (4 decls, :2144–:2216) | §(b) Tier 1 B1 | Phase 1 |
| B2: EANegation pair + 3-decl dead closure; impossibility note :1047–:1090 | §(b) Tier 1 B2, §(d) | Phase 2 |
| B3: sorry-free warm-up trio (planner's choice) | §(b) Tier 1 B3 | Phase 2 (INCLUDED — settled below) |
| Tier-2 sweep (~16 decls, 8 files, mixed confidence) | §(b) Tier 2 | DESCOPED (Non-Goals, with rationale) |
| `#exit` + header normalization census (83 TB / 60 KB files) | §(c) | Phase 3 |
| README/inventory reconciliation + tombstones | §(c) | Phase 4 |
| Definition-of-done gates | §(e) | Phase 4 + per-phase verification |

### Preserved Assets

The following prior work is complete and must not regress:

| Component | Location | Status | Verified |
|-----------|----------|--------|----------|
| Kamp Boneyard structure + README (task 385) | `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/Boneyard/` | [COMPLETED] | 2026-07-24 (report §(a), §(c)) |
| Archived importers `Prop43.lean`, `NfMultiAnchorBridgeRetired/NavigatedEndChar.lean` (385 phase 2) | `Kamp/Boneyard/` | [COMPLETED] | 2026-07-24 (report claim table) |
| Live superseding lemma `VVecEA2.negFix_iff` (sorry-free, 9 consumer files) | `EANegationFix/VecEANegFix.lean:177` | [COMPLETED] | 2026-07-24 (report §(b) B2) |
| Live replacement `endIntervalStepPrior` | `EndIntervalConsumerK.lean:55` | [COMPLETED] | 2026-07-24 (report §(b) B1) |
| Axiom baseline of `completeness_discrete` | `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean:242` | [BASELINE] | 2026-07-24 (lean_verify, report §(e).3) |

## Postmortem Constraints

Binding rules for all implementation dispatches. No prior failed attempts exist for this task;
rules derive from the research report's risk factors, the task-385 division-of-labor contract,
and known repo failure modes (orphan-manufacturing excisions; axiom-baseline drift).

**Do NOT**:
- Move whole files, or touch any file archived by the prior Kamp archival pass — this task
  works at declaration level inside live files plus Boneyard-internal tidying only (report,
  Executive Summary item on division of labor).
- Touch `VVecEA2.singleton` (:2122) or `VVecEA2.singleton_holds` (:2128) in CarrierK1V — live
  consumers at `EndIntervalConsumerK.lean:78,:230-231,:332`. A naive "move the whole file tail
  from :2122" is the documented counterexample (report claim table).
- Edit `WeakCanonical/Transfer.lean` `countermodel_discrete` (:1277) — the only load-bearing
  sorry in Metalogic — or anything in `Bundle/SuccRelation.lean` (report §(b) MUST NOT list).
- Delete anything from either Boneyard (permanent-archive charter); tombstone READMEs are
  retained and marked, never removed.
- Repair stale imports inside Boneyard files — standing policy in both READMEs: "stale imports
  in never-built code are cosmetic" (report §(c)).
- Place `#exit` before the import block — that form is a Lean 4 header syntax error; the
  convention is after-imports (report §(c) rationale).
- Write task numbers ("task 359", "task 385", etc.) into ANY `Theories/**/*.lean` file or any
  README content — `.claude/rules/no-task-references-in-deliverables.md`. Breadcrumbs cite
  durable anchors: file paths, declaration names, section headings.
- Re-litigate the promotion list or re-audit consumers for Tier-1 items — the report's
  zero-consumer evidence is fresh (this session, High confidence). Re-verification budget is
  the cheap per-phase gates only.
- Introduce any new `sorry`, any new axiom, or any change that alters the
  `completeness_discrete` axiom list.
- Attempt to prove either retired sorried theorem — they are archived precisely because the
  backward direction is unprovable at the `BracketFormula` level (report §(b) B2).

**MUST preserve**:
- The impossibility note at `EANegation.lean:1047–:1090` and both Rabinovich docstrings
  (:820–:833 "Lemma 5.1 (Rabinovich 2014, pp.7-11)…"; :1118–:1128 "Corollary 5.4…") —
  verbatim, moved with the archived code (charter requirement, report §(b) B2).
- The EANegation live keep-set: `fChainFrom`, `fChainPred`, `fChainFrom_base`,
  `fChainFrom_step`, `bracket_implies_fChainPred`, `BracketFormula.prepend`, `prepend_holds`,
  `prepend_holds_inv`, `orderedPointsExist`, `orderedPointsExist_decompose`,
  `VBracketFormula.prependAll`, `neg_orderedPointsExist_is_vbracket`,
  `IntervalPattern.allBetaTrue`, `BracketFormula.allTrue` (each 1–8 external consumer files).
- The axiom baseline (Preserved Assets table) — byte-identical after every phase that builds.
- All existing informative Boneyard file headers (Phase 3 only ensures the marker line is
  present; it never replaces existing content).

**Design decisions are SETTLED** (do not re-open without concrete counterexample):
1. **Tier-2 sweep DESCOPED** — see Non-Goals. Rationale: 3 of 8 report rows are only
   review-verified (Medium confidence) with a mandatory per-decl re-grep, i.e. an open-ended
   verification surface that fails the bounded-unit test for this plan; the charter marks the
   sweep OPTIONAL.
2. **B3 micro-tier INCLUDED in Phase 2** — the warm-up trio (`neg_orderedPointsExist_zero_false`,
   `neg_orderedPointsExist_one`, `neg_orderedPointsExist_one_is_bracket`) is archived into the
   same destination file. Rationale: this task's purpose is removing zero-consumer orphans;
   leaving a freshly-verified dead pair behind contradicts it; report confirms zero build risk.
3. **`#exit` placement: immediately after the import block** in all Boneyard files (report §(c)
   rationale: before-imports is a header syntax error; after-imports guarantees zero
   declarations elaborate on accidental import).
4. **Header placement refinement**: the `ARCHIVED (Boneyard)` module docstring `/-! … -/` is
   placed AFTER the import block (before `#exit`), not before imports — same
   syntactic-validity argument as decision 3 (a module docstring is a command and may not
   precede `import`). Files with no imports place it at the top. Files that already have a
   module docstring after imports get the marker line prepended inside the existing docstring.
5. **Destinations fixed** (report §(b)): B1 →
   `Kamp/Boneyard/NfMultiAnchorBridgeRetired/EndIntervalSkeleton.lean`; B2+B3 →
   `Kamp/Boneyard/EANegationVBracketBackward.lean`.

## Goals & Non-Goals

- **Goals**:
  - Archive the CarrierK1V `endInterval` 4-decl dead skeleton to the Kamp Boneyard (B1).
  - Retire the EANegation sorried pair + 3-decl dead support closure + B3 warm-up trio,
    leaving `EANegation.lean` sorry-free with breadcrumbs and preserved impossibility notes (B2/B3).
  - Normalize `#exit` (after-imports) and `ARCHIVED (Boneyard)` headers across all Boneyard
    `.lean` files (census baseline: 83 TB + 60 KB, plus the 2 files this task creates).
  - Reconcile both Boneyard README inventories (TB recount 67→measured, tombstone section; KB
    additions for the 2 new files).
  - Re-verify all definition-of-done gates (report §(e)), including the empty-promotion-list
    invariant and the frozen axiom baseline.
- **Non-Goals**:
  - **Tier-2 dead-sorried-decl sweep (~16 decls across 8 live files) — explicitly DESCOPED.**
    Rationale: mixed evidence quality (TruthLemma 5 decls, ChronicleToCountermodel pair, and
    SuccExistence trio are review-verified only, Medium confidence, with mandatory per-decl
    re-grep before each excision — report §(b) Tier 2 and claim table). This is follow-up-task
    material; the report's Tier-2 table with destinations is the ready-made charter for it.
    Recommend recording it as a follow-up in the completion summary.
  - Promoting any declaration out of a Boneyard (nothing to promote — promotion list empty).
  - Fin/non-Fin twin consolidation and per-k `kampPrior` arm cleanup (live-code refactoring,
    report §(b) "Explicitly out of scope").
  - Repairing stale imports inside Boneyard files.
  - Proving anything: no proof construction anywhere in this task.

## Risks & Mitigations

- **Risk**: excision leaves fresh zero-consumer orphans (the defect class this task removes).
  **Mitigation**: removal sets are the report's verified dead *closures* (B1: 4 decls; B2: 5
  decls; B3: 3 decls), not just the chartered items; keep-sets are pinned in Postmortem
  Constraints.
- **Risk**: axiom baseline drift (e.g. accidental edit on the live path).
  **Mitigation**: `lean_verify` gate after each live-file-touching phase (1, 2) and again in
  Phase 4; excised code is dead, so any drift indicates an out-of-scope edit — stop and revert
  the offending hunk.
- **Risk**: line numbers in the report drift if the tree changed since research (same day,
  HEAD f67b72c89). **Mitigation**: each excision phase first confirms the anchor declaration
  names/lines with a grep before editing; if anchors moved, re-locate by declaration name (the
  decl *names* are the contract, line numbers are hints).
- **Risk**: the Phase 3 mechanical script corrupts a file (e.g. misparses an import block).
  **Mitigation**: script operates only under `Boneyard/` directories (never-compiled code —
  zero build blast radius); dry-run diff review on 5 sample files before full application;
  full `lake build` after as a no-change sanity check; git diff review before commit.
- **Risk**: task-number references leak into `.lean`/README breadcrumbs.
  **Mitigation**: breadcrumb texts are given verbatim in the phase specs below and cite only
  file paths and declaration names; the advisory hook `validate-no-task-references.sh` provides
  a second net.

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3 | 1, 2 |
| 3 | 4 | 1, 2, 3 |

Phases within the same wave can execute in parallel. Phases 1 and 2 have disjoint file
territories (CarrierK1V/InteriorGateGeneralK + one new KB file vs. EANegation + one new KB
file) and are logically independent; HOWEVER, if dispatched in the same worktree they MUST
serialize their `lake build` / `lean_verify` gate steps (no concurrent lake builds). Default
execution: sequential 1 → 2.

### Phase 1: Archive CarrierK1V endInterval skeleton to Kamp Boneyard [COMPLETED]

- **Goal:** Move the dead 4-decl `endInterval` tail block out of live `CarrierK1V.lean` into a
  new Kamp Boneyard file; live tree builds green with axiom baseline unchanged.
- **Bounded unit:** one excision (one source file, one new archive file, one stale-prose
  touch-up). Estimated output: ~160 lines (≈120 moved + header/breadcrumb/prose edits).
  Fixed, finite attempt surface — passes the H8 bounded-unit test.
- **Tasks:**
  - [x] Anchor check (read-only): confirm the 4 decls and the framing doc block exist where
        expected in `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/CarrierK1V.lean`:
        `endIntervalStep` (:2144), `endInterval` (:2159), `EndIntervalCorrect` (:2179),
        `endInterval_zero_correct` (:2199), framing doc block ≈:2100–:2143; confirm
        `VVecEA2.singleton` (:2122) / `VVecEA2.singleton_holds` (:2128) are OUTSIDE the block
        to be removed. Command:
        `grep -n "endIntervalStep\|def endInterval\|EndIntervalCorrect\|endInterval_zero_correct\|VVecEA2.singleton" Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/CarrierK1V.lean`
  - [x] Create `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/Boneyard/NfMultiAnchorBridgeRetired/EndIntervalSkeleton.lean`
        containing, in order: (a) the original import line(s) needed by the moved code (copied
        from CarrierK1V; staleness acceptable per policy), (b) module docstring beginning
        `ARCHIVED (Boneyard) — never compiled. Superseded endInterval skeleton; live
        replacement is EndIntervalConsumerK.endIntervalStepPrior / the consumer-side reshape.
        Do not import from live code.`, (c) `#exit`, (d) the Phase-framing doc block
        (≈:2100–:2143, minus the `VVecEA2.singleton` pair) and the 4 moved decls verbatim.
  - [x] Delete the moved block from `CarrierK1V.lean` (framing doc block + 4 decls; KEEP the
        `VVecEA2.singleton` pair and everything before it). Leave this breadcrumb comment at
        the excision site (verbatim; no task numbers):
        `-- The endInterval skeleton (endIntervalStep, endInterval, EndIntervalCorrect,`
        `-- endInterval_zero_correct) formerly here was superseded dead code; it is archived at`
        `-- Boneyard/NfMultiAnchorBridgeRetired/EndIntervalSkeleton.lean. The live replacement`
        `-- is endIntervalStepPrior in EndIntervalConsumerK.lean.`
  - [x] Update stale prose in `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/InteriorGateGeneralK.lean:18`
        ("can fill the `endIntervalStep` body") to reference the consumer-side reshape
        (`endIntervalStepPrior` in `EndIntervalConsumerK.lean`) instead. Check :59 mention for
        the same staleness while there; comment-only edits.
  - [x] Verify (all must pass before commit):
        1. `lake build` GREEN (full tree).
        2. `grep -rn "endIntervalStep\|EndIntervalCorrect\|endInterval_zero_correct" Theories/ Tests/ --include="*.lean" | grep -v "/Boneyard/"`
           → only comment/docstring mentions remain (no code references).
        3. `lean_verify` on `Bimodal.Metalogic.BXCanonical.completeness_discrete` → exactly
           `[propext, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler, Quot.sound]`,
           no sorryAx, no warnings.
  - [x] Commit (green): `task 359 phase 1: archive CarrierK1V endInterval skeleton`
- **Done when:** all three verification checks pass and the commit lands.
- **Timing:** ~1 hour
- **Depends on:** none

### Phase 2: Retire EANegation sorried pair + dead support closure [COMPLETED]

- **Goal:** Excise the 5-decl removal set (B2) plus the 3-decl warm-up trio (B3, settled
  decision 2) from `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/EANegation.lean` into a new
  Kamp Boneyard file, preserving the impossibility note (:1047–:1090) and both Rabinovich
  docstrings verbatim; `EANegation.lean` becomes sorry-free; build green, axioms unchanged.
- **Bounded unit:** one excision (one source file, one new archive file). Estimated output:
  ~550 lines — EXCEEDS the ~300-line advisory, accepted under H8's primary criterion: it is
  one mechanical move of a verified-dead closure with a fixed, finite attempt surface (no
  proof work, no open-ended search); splitting it would cut a single dead closure across two
  dispatches and risk an intermediate orphan state.
- **Removal set** (report §(b) B2 + B3; names are the contract, lines are hints):
  | Decl | Anchor | Sorries |
  |---|---|---|
  | `BracketFormula.partialBracketExist` | :573 | 0 |
  | `neg_partialBracketExist_sufficient` | :725 | 0 |
  | `neg_bracket_zero_is_vbracket` | :770 | 0 |
  | `neg_bracket_is_vbracket` (+ docstring :820–:833, impossibility note :1047–:1090) | :820–:1120 | 1 (:1090) |
  | `neg_partialBracketExist_is_vbracket` (+ docstring :1118–:1128) | :1118–:1251 (EOF) | 1 (:1249) |
  | `neg_orderedPointsExist_zero_false` (B3) | :74 | 0 |
  | `neg_orderedPointsExist_one` (B3) | :82 | 0 |
  | `neg_orderedPointsExist_one_is_bracket` (B3) | :106 | 0 |
- **Tasks:**
  - [x] Anchor check (read-only): confirm all 8 decls at/near their anchors and confirm the
        file's ONLY two `sorry` tokens are :1090 and :1249:
        `grep -n "sorry" Theories/Bimodal/Metalogic/WeakCanonical/Kamp/EANegation.lean` and
        `grep -n "partialBracketExist\|neg_bracket_zero_is_vbracket\|neg_bracket_is_vbracket\|neg_partialBracketExist\|neg_orderedPointsExist_zero_false\|neg_orderedPointsExist_one" Theories/Bimodal/Metalogic/WeakCanonical/Kamp/EANegation.lean`
  - [x] Create `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/Boneyard/EANegationVBracketBackward.lean`
        containing, in order: (a) `import` of the live modules the moved code referenced
        (minimally `Theories/Bimodal/...Kamp.EANegation`'s own imports as needed — staleness
        acceptable), (b) module docstring beginning `ARCHIVED (Boneyard) — never compiled.`
        and stating: retired because the backward direction is unprovable at the
        `BracketFormula` level (see the preserved impossibility note inside
        `neg_bracket_is_vbracket` below); superseded by the sorry-free `VVecEA2.negFix_iff`
        (`EANegationFix/VecEANegFix.lean`) and the model-dependent closure lemmas in
        `EANegationClosure.lean`; Rabinovich provenance labels preserved. (c) `#exit`, (d) the
        8 moved decls verbatim — including, unmodified: the :1047–:1090 impossibility comment,
        the :820–:833 "Lemma 5.1 (Rabinovich 2014, pp.7-11)…" docstring, and the :1118–:1128
        "Corollary 5.4…" docstring.
  - [x] Delete the 8 decls (with their docstrings/comments) from `EANegation.lean`. Do NOT
        touch any keep-set decl (Postmortem Constraints). Leave one breadcrumb comment at the
        former :820 site (verbatim; no task numbers):
        `-- The backward-direction theorems neg_bracket_is_vbracket and`
        `-- neg_partialBracketExist_is_vbracket (with their support closure) were retired to`
        `-- Boneyard/EANegationVBracketBackward.lean: unprovable at the BracketFormula level;`
        `-- superseded by VVecEA2.negFix_iff (EANegationFix/VecEANegFix.lean) and the closure`
        `-- lemmas in EANegationClosure.lean.`
  - [x] Update the module docstring of `EANegation.lean`: note the file is now sorry-free and
        where the retired backward-direction material lives (same durable anchors as the
        breadcrumb; no task numbers).
  - [x] Verify (all must pass before commit):
        1. `grep -c "sorry" Theories/Bimodal/Metalogic/WeakCanonical/Kamp/EANegation.lean` → 0
           (token scan; confirm no `sorry` remains outside comments —
           `grep -n "sorry" …` and eyeball).
        2. `lake build` GREEN (full tree) — in particular the two live importers
           `EANegationFix/OnBuilder.lean` and `EANegationClosure.lean` still compile.
        3. `grep -rn "neg_bracket_is_vbracket\|neg_partialBracketExist" Theories/ Tests/ --include="*.lean" | grep -v "/Boneyard/"`
           → no code references (breadcrumb comment mentions only).
        4. `lean_verify` on `Bimodal.Metalogic.BXCanonical.completeness_discrete` → baseline
           list byte-identical, no sorryAx.
  - [x] Commit (green): `task 359 phase 2: retire EANegation backward-direction closure`
- **Done when:** all four verification checks pass and the commit lands.
- **Timing:** ~1.5 hours
- **Depends on:** none (same wave as Phase 1; serialize build gates if same worktree)

### Phase 3: Boneyard #exit and header normalization (mechanical pass) [COMPLETED]

- **Goal:** Every `.lean` file under both Boneyards (census baseline 83 TB + 60 KB, plus the 2
  files created in Phases 1–2 = 145) has (a) an `ARCHIVED (Boneyard)` module-docstring marker
  and (b) exactly one `#exit` immediately after its import block — per settled decisions 3–4.
- **Bounded unit:** one scripted transformation over a fixed file set. ~145 files touched but
  each receives 1–5 mechanical lines; the script is the single artifact (~80–120 lines).
  Fixed, finite surface — passes the bounded-unit test. Zero build blast radius (never-built
  files only).
- **Boneyard roots:** TB = `Theories/Bimodal/Boneyard/`, KB =
  `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/Boneyard/`.
- **Tasks:**
  - [x] Re-run the census to fix the exact work list (idempotent; report baseline: TB 19
        exit-before-imports / 24 after / 40 none; KB 0 `#exit`):
        classify each `find <root> -name "*.lean"` file by first-`#exit` vs first-`import`
        position and by presence of an `ARCHIVED (Boneyard)` line.
        *(deviation: altered — fresh comment-aware census measured 14 exit-before / 29
        exit-after / 100 no-exit / 2 already-conforming = 145; the report baseline counted
        `import` tokens inside block comments as import lines. Work list fixed from the
        fresh census, as the task directs.)*
  - [x] Write a scratch Python script (in the scratchpad or `specs/359_.../`, NOT in
        `Theories/`) that, for each Boneyard `.lean` file:
        1. If a `#exit` appears before the import block: remove it.
        2. Locate the end of the import block (last leading `import` line; treat
           leading comments as part of the preamble; files with no imports → position 0).
        3. Ensure a module docstring `/-! … -/` at that position whose first content line
           starts `ARCHIVED (Boneyard) — never compiled.`; if a module docstring already
           exists there, prepend the marker line inside it, preserving all existing content;
           otherwise insert the minimal header from the report §(c) convention (one-line
           reason may be generic: `archived material; see the Boneyard README inventory`).
        4. Ensure exactly one `#exit` immediately after that docstring (insert if absent,
           relocate if it was elsewhere after imports — keep a single `#exit`; additional
           later `#exit` tokens may remain, they are unreachable and harmless).
  - [x] Dry-run: print unified diffs for 5 sample files covering all census classes
        (exit-before, exit-after, no-exit, KB no-exit, already-headered); review before
        applying to all files. *(deviation: altered — 9 samples reviewed: the 5 planned
        classes plus edge cases: comment-embedded `import` tokens, top-of-file docstring,
        and no-import files.)*
  - [x] Apply to all files under both roots (including the 2 new files from Phases 1–2 —
        idempotent no-ops if they already conform). 143 files changed; the 2 Phase 1–2
        files were already conforming no-ops.
  - [x] Verify (all must pass before commit):
        1. Census re-run: 100% of Boneyard `.lean` files classify as "marker present" AND
           "#exit after imports"; 0 files with `#exit` before imports. (145/145 CONFORMS.)
        2. `git diff --stat` touches ONLY paths under the two Boneyard roots. (143 Boneyard
           files; only pre-existing baseline modifications + this plan file elsewhere.)
        3. `lake build` GREEN (no-change sanity check; Boneyard is not built). (GREEN,
           1789 jobs; `completeness_discrete` axiom baseline byte-identical, no sorryAx.)
  - [x] Commit (green): `task 359 phase 3: normalize Boneyard #exit placement and headers`
- **Done when:** census shows 100% conformance, diff is Boneyard-only, build green.
- **Timing:** ~1.5 hours
- **Depends on:** 1, 2

### Phase 4: README reconciliation and final verification gate [COMPLETED]

- **Goal:** Both Boneyard READMEs match the tree; all definition-of-done gates (report §(e))
  pass on the final tree.
- **Bounded unit:** two README edits + a fixed 5-gate checklist. Estimated output: ~120 lines.
- **Tasks:**
  - [x] TB `Theories/Bimodal/Boneyard/README.md`: recount the inventory from the tree
        (`find` per subdirectory; report measured 83 `.lean` files vs the README's claimed
        67 / ~39,619 lines — recompute both counts) and fix the totals row + per-subdir rows.
        *(deviation: altered — measured totals 83 files / 51,243 lines; also added 4 missing
        inventory rows (DeadChronicleGapElimination, KampBypassArchive, RestrictedMCSDeferral,
        VecEADecomposition) and corrected UltrafilterFrame to 3 files, required for the table
        to actually match the tree.)*
  - [x] TB README: add a **Tombstones** section listing the 9 README-only subdirectories
        (`BundleTemporalCoherence/`, `BX1DependentCode/`, `ClosedGuardLegacy/`,
        `NonBurgessSeed/`, `OpenGuardInvalid/`, `StageInductionGapAnalysis/`,
        `TAxiomDependentCode/`, `UltrafilterDeadCode/`, `XuLemma321Legacy/`), and mark each
        such subdirectory README's first line:
        `TOMBSTONE — code deleted; README retained as historical record.` (do NOT delete
        anything; no task numbers anywhere).
  - [x] KB `Kamp/Boneyard/README.md`: extend the inventory with the two files this task
        created — `EANegationVBracketBackward.lean` (retired backward-direction closure;
        superseded by `VVecEA2.negFix_iff` and `EANegationClosure.lean`) and
        `NfMultiAnchorBridgeRetired/EndIntervalSkeleton.lean` (superseded `endInterval`
        skeleton; live replacement `endIntervalStepPrior`). Durable anchors only.
  - [x] Final verification gate (ALL must pass; report §(e)) — all 5 gates PASS:
        1. `grep -rn "^import.*Boneyard" Theories/ Tests/ --include="*.lean" | grep -v "/Boneyard/"`
           → empty (no-live-imports invariant).
        2. `lake build` AND `lake build BimodalTest` → GREEN.
        3. `lean_verify` on `Bimodal.Metalogic.BXCanonical.completeness_discrete` → exactly
           `[propext, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler, Quot.sound]`,
           no sorryAx (the two `Lean.*` entries are the known native_decide caveat — part of
           the baseline, not a regression).
        4. `grep -rn "task [0-9]" Theories/ --include="*.lean"` and a scan of both edited
           READMEs → no task-number references introduced by this task.
        5. Spot-check: the impossibility note (:1047–:1090 content) and both Rabinovich labels
           appear verbatim in `Kamp/Boneyard/EANegationVBracketBackward.lean`.
  - [x] Commit (green): `task 359 phase 4: reconcile Boneyard READMEs; final verification`
- **Done when:** all 5 gates pass and the commit lands.
- **Timing:** ~1 hour
- **Depends on:** 1, 2, 3

## Planned Strategic Sorries

Not applicable — `skeleton: false`. This plan covers its full (post-descoping) scope in 4
bounded phases; no strategic-sorry division points. (The Tier-2 sweep is a descoped non-goal,
not a division point: no sorry is planted for it.)

## Testing & Validation

- [x] Per-phase: `lake build` GREEN after every phase that edits any file (Phases 1–4).
- [x] Per live-edit phase (1, 2) and final (4): `lean_verify` axiom-baseline gate on
      `Bimodal.Metalogic.BXCanonical.completeness_discrete` — byte-identical list, no sorryAx.
- [x] Phase 2: `EANegation.lean` sorry-token count = 0; both live importers compile.
- [x] Phase 3: census 100% conformance; `git diff` confined to Boneyard roots.
- [x] Phase 4: the 5-gate final checklist (incl. `lake build BimodalTest` and the
      no-live-imports grep) — all PASS 2026-07-24.
- [x] Global: no test files are modified; `Tests/BimodalTest/` is exercised via
      `lake build BimodalTest` only.

## Artifacts & Outputs

- plans/01_boneyard-hygiene-plan.md (this file)
- summaries/01_boneyard-hygiene-summary.md (written by the implementer)
- New: `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/Boneyard/NfMultiAnchorBridgeRetired/EndIntervalSkeleton.lean`
- New: `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/Boneyard/EANegationVBracketBackward.lean`
- Modified: `CarrierK1V.lean`, `InteriorGateGeneralK.lean` (comment only), `EANegation.lean`,
  ~145 Boneyard `.lean` files (mechanical), both Boneyard `README.md`s, 9 tombstone READMEs.

## Rollback/Contingency

- Phases commit independently at green; any regression is isolated to at most one phase's
  commit — revert that single commit (`git revert <sha>`) and re-dispatch the phase.
- If a Phase 1/2 excision unexpectedly breaks the build (contradicting the zero-consumer
  evidence): do NOT force it — restore the removed decl(s), record the surviving consumer
  as a report contradiction in the summary, and narrow the removal set to what builds green.
  Never resolve a breakage by editing keep-set or MUST-NOT-touch files.
- If the axiom gate ever deviates: the change came from an out-of-scope edit (excised code is
  dead); locate via `git diff`, revert the offending hunk before proceeding.
- Before any intentional destructive rollback on a dirty tree, snapshot first via
  `bash .claude/scripts/git-snapshot.sh` (git-workflow rule).
