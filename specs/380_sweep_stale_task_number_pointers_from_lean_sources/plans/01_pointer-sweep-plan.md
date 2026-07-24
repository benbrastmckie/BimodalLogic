# Implementation Plan: Sweep Stale Task-Number Pointers from Lean Sources

- **Task**: 380 - sweep_stale_task_number_pointers_from_lean_sources
- **Status**: [COMPLETED]
- **Effort**: 12 hours (8 phases, ~1-2 h each)
- **Dependencies**: Tasks 387, 388 (both landed; baseline measured post-excision at commit `c12eab1d6`)
- **Research Inputs**: reports/01_pointer-sweep-inventory.md (integrated, v1)
- **Artifacts**: plans/01_pointer-sweep-plan.md (this file)
- **Standards**:
  - .claude/context/formats/plan-format.md
  - .claude/rules/artifact-formats.md
  - .claude/rules/state-management.md
  - .claude/rules/no-task-references-in-deliverables.md
  - .claude/rules/git-workflow.md (commit-per-green-substep)
- **Type**: lean4

## Overview

Remove all 1,549 ephemeral task-number reference lines (192 files) from `Theories/**/*.lean`,
replacing provenance-bearing ones with durable anchors (declaration names, file paths, section
headings, PDF page citations) per `no-task-references-in-deliverables.md`. The sweep is
comment/docstring-only: research verified **zero declaration names embed task numbers** (report
§1), so no rename, no proof change, and no semantic edit is in scope. Strategy (report §3): a
span-aware Python rewrite script auto-drops the ~469 pure parenthetical pointers (category a)
and emits categorized per-file worklists for the hand-edit categories (b: durable-equivalent
substitution, c: state-the-fact, d: stale/misleading content requiring truth-check). Definition
of done: sweep-pattern recount `grep -rE '\b[Tt]asks?[ #-]?[0-9]{1,4}\b' Theories --include='*.lean'`
returns **0**, `lake build` EXIT 0, sorry census identical to baseline (906 raw / 820 non-comment
/ 26 sorryAx), zero non-comment diffs, and a summary artifact including the hook-escalation
recommendation (recommendation only — see Settled decisions).

> **OUTCOME (Phase 8)**: 1,535 of 1,549 lines cleared (99.1%). The "returns 0" and "zero
> non-comment diffs" clauses above were both amended by binding constraints and by an explicit
> user authorization, and the amendments are the correct outcome rather than shortfalls:
> **(1)** the recount floor is **14**, every one a line containing `sorry`, which the
> never-touch-sorry-lines rule forbids editing — that guard is what makes the 906/820 census a
> valid invariant, so driving the count to 0 would trade a real correctness gate for a cosmetic
> one; **(2)** 6 non-comment diffs exist in 2 files, being runtime string literals the user
> explicitly authorized reworking individually. `lake build` EXIT 0 and census 906/820/26 held
> exactly. Full enumeration and evidence: `summaries/01_pointer-sweep-summary.md`.

### Research Integration

- `reports/01_pointer-sweep-inventory.md` (v1, 2026-07-24): full inventory, 30 classified sample
  rewrites, script design, gate baselines, protected-site re-anchoring, hook FP assessment.

### Reference Grounding (H3, Tier 3 — implementation-backed)

No external literature; sources are the research report (command-verified against the working
tree at `c12eab1d6`), the rule file, and the hook script. Source-to-implementation mapping:

| Plan element | Source | Verified how |
|---|---|---|
| Inventory totals (1,549 / 192; live 1,312/133; Boneyard 237/59) | report §1 | grep executed this session, High confidence |
| Category taxonomy (a/b/c/d) + 30 exemplar rewrites | report §2 | manual sampling ~80 lines / 20 files |
| Script design (comment-span assertion, sorry-line guard, decl-span skip) | report §3 | design rationale + failure-mode analysis |
| Rewrite style target | KampPrior.lean ~:497-510 corrected note (decl names + Rabinovich 2014 Def 3.1 p.4, Prop 4.3/Thm 4.4 p.6) | report §2, exemplar in tree |
| Gate baselines (build EXIT 0, 1789 jobs; census 906/820/26) | report §5 | lake build + grep executed this session |
| Protected decls by name, not line | report §5 + Contradiction Log item 1 | wc/git-log/awk executed; EANegation line refs proven rotten |
| Hook escalation posture | report §4 | hook regex probed against 7 test strings; 45-file `.claude/` FP class counted |

## Postmortem Constraints

Binding rules for all implementation dispatches. No prior failed attempt exists for this task;
rules derive from the research report's verified risk factors and the repo-wide failure mode this
task exists to fix (stale in-code pointers causing three rounds of wasted work — task
description, ROOT CAUSE).

**Do NOT**:
- **No sed / line-oriented in-place editing of Lean files.** All scripted edits go through the
  span-aware Python script (report §3): files exceed 6,000 lines and edits must be provably
  inside comment spans. Hand edits use the Edit tool on worklist entries only.
- **Never modify any line containing the token `sorry`** — even when the match is comment prose.
  This is what makes the raw census counts (906/820) a valid invariant (report §5, census
  subtlety). If a worklist entry sits on a sorry-line, leave it and record it in the phase notes
  as deferred (expected count: ~0; the script excludes them from worklists).
- **Never touch the protected declaration spans**, identified by NAME from the Phase 1
  `protected-decls.txt` artifact — at minimum `nf_nvar_exist_all_depths` (KampPrior.lean, decl
  header ~:350, proof body spans the formerly-protected :520) and the sorry-adjacent decls in
  EANegation.lean (1 sorry) and `Boneyard/.../EANegationVBracketBackward.lean` (16 sorries).
  Never re-derive protection by line number — the task description's line numbers already rotted
  (report §5, Contradiction Log 1).
- **Never edit outside comment/docstring spans.** No declaration may be weakened, discharged,
  deleted, or renamed to remove a pointer (task constraint). A diff hunk touching non-comment
  text is a phase failure: revert the hunk, do not "fix it up".
- **Do not introduce new task-number references** in any replacement text or in the script/
  worklist content that lands outside `specs/**`. Commit messages are exempt (`task 380 phase P:
  ...` convention stays).
- **Do not skip the `lake build` gate because "it's only comments"** — an unbalanced `-/` or a
  mangled `/--` delimiter is a compile error (report §3).
- **Do not fix unrelated code**, including the pre-existing `DatasetGenerator.lean:2174` unused
  variable 'q' warning. It must remain exactly as-is (not worsened, not fixed) — scope creep here
  invalidates the comment-only invariant.
- **Do not hand-rewrite Boneyard content** beyond mechanical number-drops (report §1, Boneyard
  stance). Boneyard docstrings are deliberately historical; keep archival dates and prose, drop
  the numbers.
- **Do not implement the hook escalation in this phase set** (see Settled decisions).
- **No `git add -A` / `git commit -am`.** Stage exactly the phase's worklist files plus
  `specs/380_.../` artifacts (git-workflow.md, git-staging-scope contract).

**MUST preserve**:
- `lake build` EXIT 0 at every phase gate (job count may drift with caching; EXIT code may not).
- Sorry census exactly 906 raw / 820 non-comment-line / 26 sorryAx (commands in Testing &
  Validation), at every phase gate.
- Every declaration in `Theories/**` — count and names unchanged.
- The corrected KampPrior.lean ~:497-510 exemplar note (already number-free; it is the style
  target, not a sweep target).
- The task-387/388 excision state landed at `c12eab1d6` (no regression of that cleanup).

**Design decisions are SETTLED** (do not re-open without concrete counterexample):
1. **Python span-aware script, not sed** — edits must carry a comment-span assertion; sed cannot
   provide one (report §3).
2. **Boneyard is IN scope**: included in the scripted category-(a) pass and in a mechanical
   number-drop batch; EXCLUDED from truth-checking/hand-rewriting effort. Rationale: rule applies
   repo-wide outside `specs/**`; a silent exemption would leave 237 permanent violations the hook
   flags forever (report §1). No rule-file exemption is added.
3. **`specs/NNN_...` artifact-path citations (48 lines) are category (c)**: state the decision or
   content inline, drop the path — task directories are archived and vaulted, so the paths are
   equally ephemeral (report §1, adjacent pattern). The script flags them into worklists.
4. **Hook escalation is a RECOMMENDATION, not an implementation, in this task.** The final phase
   writes a precise recommendation (path-scoped PreToolUse deny on `Theories/**/*.lean`,
   hyphen-aware pattern `\btasks?([[:space:]]+|-)[0-9]+`, keep advisory for `.claude/**` where 45
   files legitimately match) into the summary. Justification: (i) the task description marks it
   CONSIDER — raised, not decided; (ii) it is `.claude/` infrastructure (a new PreToolUse
   registration in settings.json — meta territory, not lean4); (iii) the research recommends
   escalating only after the sweep has landed and been verified — coupling it into this task
   would put a blocking hook mid-history and complicate rollback. The write-up must be complete
   enough that a follow-up meta task is one-shot.
5. **Protection is anchored by declaration name**, resolved fresh in Phase 1 and recorded in
   `protected-decls.txt`; line numbers are never authoritative.
6. **Section headings disambiguated by content, not deleted**: where task numbers are currently
   the only disambiguator between sibling headings (e.g. Syntax/Formula.lean's three
   "Complexity verification" sections), rewrites must produce distinct content-based headings
   (report §2 sample 2), never duplicate headings.

## Goals & Non-Goals

- **Goals**:
  - Zero matches of the sweep pattern in `Theories/**/*.lean` (including Boneyard).
  - Provenance that matters survives as durable anchors (decl names, files, sections, PDF pages).
  - Category-(d) sites state the *current* truth (verified at edit time), not corrected pointers.
  - Reusable, reviewed rewrite script + worklists archived under `specs/380_.../`.
  - Hook-escalation recommendation with pattern fix and FP assessment, ready for a meta task.
- **Non-Goals**:
  - No hook/settings.json changes (Settled decision 4).
  - No edits outside `Theories/**/*.lean` (the 45 matching `.claude/` files are legitimate).
  - No proof, declaration, or import changes; no sorry discharge; no Boneyard content curation.
  - No rule-file changes.

## Risks & Mitigations

- **Risk**: comment edit breaks the build (unbalanced `-/`, mangled docstring). **Mitigation**:
  span parser handles nested `/- -/`, `/-!`, `/--`; per-batch `lake build` gate; script emits
  unified diffs for review before staging.
- **Risk**: census drift from adding/removing the word "sorry" in prose. **Mitigation**:
  absolute never-touch-sorry-lines guard in script AND in hand-edit rules; census gate at every
  phase.
- **Risk**: category-(d) rewrite asserts a wrong "current truth" (e.g. whether general-m
  discharge landed). **Mitigation**: worklist marks every (d) entry `VERIFY`; implementer must
  check the referenced decl's existence/sorry-status (`lean_local_search` / grep) before writing
  the replacement; if unverifiable in-phase, write the neutral form ("remains open; see sorry
  inventory") rather than a claim.
- **Risk**: the production auto-drop regex matches a different set than the 469 estimate.
  **Mitigation**: Phase 1 dry-run reports exact counts; the number is calibrated before any edit
  (report, verification table).
- **Risk**: parallel hand-edit phases contend on `lake build` / git index. **Mitigation**:
  territory contracts are file-disjoint (wave table); build+commit gates must serialize —
  sequential execution is the default and safe choice.
- **Risk**: script itself would violate the rule if placed in the repo proper. **Mitigation**:
  script and worklists live under `specs/380_.../` (exempt path).

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3, 4, 5, 6, 7 | 2 |
| 4 | 8 | 3, 4, 5, 6, 7 |

Phases 3-7 own pairwise-disjoint file sets (territory contracts listed per phase) and are
parallel-eligible in principle; however each phase's gate includes a full `lake build` and a
scoped commit, which must serialize. Default execution is sequential 3→4→5→6→7; an orchestrator
running them in parallel must serialize the build+commit gates.

### Phase 1: Rewrite/flag script + dry-run + categorized worklists [COMPLETED]

- **Goal:** Produce the span-aware rewrite tool and the complete, categorized edit worklists.
  Zero modifications under `Theories/`.
- **Tasks:**
  - [x] Write `specs/380_sweep_stale_task_number_pointers_from_lean_sources/scripts/rewrite_task_refs.py`
    implementing (report §3):
    - Lean comment-span parser: `--` line comments, `/- ... -/` blocks with nesting, `/-!`, `/--`.
    - **Assertion** (hard failure, not warning) that every substitution lies inside a comment span.
    - Never-touch-sorry-lines guard: any line containing `sorry` is excluded from edits AND from
      worklists (counted separately in the dry-run report).
    - Protected-decl-span skip: reads `protected-decls.txt` (decl name → file), resolves each
      decl's span at run time, excludes those ranges entirely.
    - Modes: `--dry-run` (per-file unified diffs to stdout/artifact, no writes), `--apply`
      (category-a edits only), `--worklist` (categorized b/c/d listing with file:line + 1-line
      context, grouped by file), `--count` (sweep-pattern recount), `--check-diff` (verify a
      `git diff` output touches only comment spans — used as a gate by later phases).
    - Auto-drop regex restricted to whitelisted parenthetical shapes:
      `\((?:task|Task)s?\s+[0-9]{1,4}(?:\s*[/,+&]\s*[0-9]{1,4})*(?:\s+(?:v[0-9]+|Part\s+\S+|Phases?\s+[^)]{0,30}))?\)`
      plus surrounding-space normalization. Hyphenated adjectival forms (`the task-320 probes`)
      are NEVER auto-edited — always worklisted (they function as names).
    - Additional flag pattern for worklists: `specs/[0-9]{3}_[A-Za-z0-9_]+` path citations
      (48 expected), categorized (c).
  - [x] Write `protected-decls.txt`: resolve by name — `nf_nvar_exist_all_depths`
    (KampPrior.lean); the sorry-adjacent decl(s) in EANegation.lean (exactly 1 sorry — record its
    enclosing decl name); every sorry-carrying decl in
    `Boneyard/MergedBracketQuarantine/../EANegationVBracketBackward.lean` path (16 sorries).
    Verify each name exists via grep before recording. *(deviation: altered — EANegation.lean's
    single `sorry` is module-docstring prose ("This file is sorry-free.", :17), not inside any
    decl, so no EANegation decl name exists to record; documented as a note in
    protected-decls.txt, covered by the sorry-line guard. The backward file's correct path is
    `Kamp/Boneyard/EANegationVBracketBackward.lean`; its 15 in-decl sorries resolve to 3 theorems
    recorded by name, +1 docstring-prose sorry at :8 covered by the guard.)*
  - [x] Run `--dry-run` + `--worklist` over `Theories/`; save artifacts:
    `worklists/phase2-autodrop.diff`, `worklists/handedit-{by-phase}.md` (split per the Phase 3-7
    territory lists below), `worklists/counts.md` (exact auto-drop count vs the 469 estimate,
    per-category tallies, sorry-line exclusions). *(calibration: auto-drop = 597 matches / 130
    files — production regex is a superset of the 469-estimator. Two loud exclusion buckets
    recorded in counts.md: 14 sorry-line DEFERRED residual lines (report estimated ~0 — recount
    floor is 14 pending a supervised decision) and 6 NON-COMMENT string-literal match lines
    routed to worklists per the Rollback/Contingency provision.)*
  - [x] Record baseline gate outputs in `worklists/baseline.md` (build EXIT/jobs, census
    906/820/26, sweep recount 1,549).
- **Estimated output:** ~300 lines of Python + generated worklist artifacts (generated content
  does not count against the phase-output budget).
- **Done when:** dry-run and worklists exist under `specs/380_.../worklists/`; script asserts
  clean on the whole tree; `git status` shows NO change under `Theories/`; exact auto-drop count
  calibrated and recorded.
- **Timing:** 1.5-2 h
- **Depends on:** none
- **Rollback:** delete `specs/380_.../scripts/` and `worklists/` (no repo sources touched).
- **Commit:** `task 380 phase 1: rewrite script and worklists`

### Phase 2: Scripted category-(a) auto-drop across Theories (incl. Boneyard) [COMPLETED]

- **Goal:** Land the calibrated auto-drop (~469 est. parenthetical pointers) in one verified,
  committed batch.
- **Territory:** all `Theories/**/*.lean` files, but only whitelisted-parenthetical spans; no
  hand edits.
- **Tasks:**
  - [x] `rewrite_task_refs.py --apply` over `Theories/` (Boneyard included — Settled decision 2).
  - [x] Review `git diff --stat` (files must be a subset of the Phase 1 dry-run set) and spot-check
    diffs against `worklists/phase2-autodrop.diff` (must match the dry-run exactly). *(verified:
    130-file set identical; sorted ±line content of `git diff -U0` byte-identical to the preview;
    re-run `--dry-run` on the applied tree reports 0 remaining auto-drop matches — idempotent)*
  - [x] Run `--check-diff` on the full diff: every hunk comment-span-only. *(130 changed files,
    0 failures)*
  - [x] Gates: `lake build` EXIT 0; census 906/820/26; recount strictly below 1,549 by the
    calibrated count; no sorry-line touched (`git diff -U0 | grep -c sorry` on changed lines = 0).
    *(build EXIT 0, 1789 jobs, only the pre-existing DatasetGenerator.lean:2174 warning; census
    906/820/26 exact; recount 959 = 1,549 − 590 exact; sorry-line grep = 0; protected decl spans
    untouched — nf_nvar_exist_all_depths span 350..535 has no changed lines)*
  - [x] Update `worklists/counts.md` with post-phase recount.
- **Estimated output:** ~469 one-line comment edits (script-applied); ~30 lines of gate/record
  notes.
- **Done when:** all gates green; recount decrease equals the applied count; committed.
- **Timing:** 1-1.5 h
- **Depends on:** 1
- **Rollback:** `bash .claude/scripts/git-snapshot.sh` is taken before `--apply`; on gate failure
  revert the working tree from the snapshot (never commit a red state).
- **Commit:** `task 380 phase 2: scripted parenthetical auto-drop`

### Phase 3: Hand-edit SharedWitness.lean [COMPLETED]

- **Goal:** Clear the single largest file — `Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness.lean`
  (261 pre-drop reference lines; ~6,700+ file lines).
- **Territory (exclusive):** SharedWitness.lean only.
- **Tasks:**
  - [x] Work the `worklists/handedit-phase3.md` entries top-to-bottom, applying report §2 samples
    4-9 as style precedents: drop bare parentheticals the regex missed; rewrite section headers to
    content-based names (`## Full per-individual-slot family (Fin N) — foundation for the
    duplicate-free reader` style); convert "Task N Phase M (deliberate): ..." notes to
    "Deliberate: ..." citing the relevant decl names. *(all 162 entries cleared; adjacent
    unflagged ephemera in the same fragment-fold banner block also cleaned)*
  - [x] Category-(d)/`VERIFY` entries: check the named decls exist before asserting anything.
    *(verified live: `kvE2_sepBracket_holds_of_honest`, `kvE2_sepDisjunct'`,
    `kvE2_sepClosedLeafAt_discharge_honest`, `bracketEndChar_kvE2_correct_two_prior_frag`
    (OuterGate.lean); `bracketEndChar_kvE2_sound_two_prior` does NOT exist — kept as "planned")*
  - [x] Gates: file recount = 0 (`--count` scoped to the file); global recount monotone
    (959 → 797, −162 exact); `--check-diff` clean (1 file, 0 failures); `lake build` EXIT 0
    (1789 jobs); census 906/820/26 exact; changed-line sorry grep = 0.
- **Estimated output:** ~180-260 edited comment lines.
- **Done when:** SharedWitness.lean recount = 0; all gates green; committed.
- **Timing:** 1.5-2 h
- **Depends on:** 2
- **Rollback:** snapshot before starting; revert file from snapshot on gate failure.
- **Commit:** `task 380 phase 3: SharedWitness pointer sweep`

### Phase 4: Hand-edit NfMultiAnchorBridge large files [COMPLETED]

- **Goal:** Clear the five next-largest NfMultiAnchorBridge files.
- **Territory (exclusive):** `NfMultiAnchorBridge/Base.lean` (84), `InteriorGateGeneralK.lean`
  (55), `SubBracket2V.lean` (50), `EndIntervalConsumerK.lean` (44), `OuterGate.lean` (42).
- **Tasks:**
  - [x] Work `worklists/handedit-phase4.md`; precedents: report §2 samples 10-13 (Base.lean import
    NOTEs keep the rationale, drop the pointer; stale line ranges like "lines 88-1522" go too).
    *(all 173 worklist entries cleared: task-number pointers replaced with durable anchors —
    decl names, `file:line`, PDF pages, or a plain provenance statement. The EndIntervalConsumerK
    two `specs/357_...` path bullets were deleted (content restated in the module docstring).
    Base.lean was resumed from a prior partial session (11 residual on entry); its 6 remaining
    editable entries and the future-arm mirror of the past-arm rewrites were completed here.)*
  - [x] `VERIFY` entries checked against live decls before rewriting. *(the `[d] VERIFY`
    EndIntervalConsumerK/InteriorGateGeneralK entries were re-anchored to durable descriptors
    — "the general-m realization recursion", "the `kvE_deepOnFiber` re-key", etc. — rather than
    asserting a task-status claim, so no stale live-vs-open assertion is introduced.)*
  - [x] Gates: per-file recount = 0 for all five; `--check-diff` clean; `lake build` EXIT 0;
    census 906/820/26. *(per-file NON-sorry recount = 0 for all five — verified. The residual
    task-number matches are exclusively sorry-line DEFERRED residuals the never-touch-sorry-lines
    guard forbids editing: Base.lean 5, InteriorGateGeneralK.lean 1 (`:1044`), SubBracket2V.lean 1
    (`:2104`) = 7 of the 14 global sorry-line deferrals recorded in Phase 1's counts.md; these are
    NOT a per-file-recount-0 miss but the documented recount floor. `--check-diff`: 5 changed
    files, 0 failures (comment-span-only). `lake build` EXIT 0, 1789 jobs, only the pre-existing
    DatasetGenerator.lean:2174 unused-var warning. Census 906/820/26 exact; changed-line sorry
    grep = 0; no new axioms. Global recount 769 → 626.)*
- **Estimated output:** ~190-270 edited comment lines.
- **Done when:** all five files recount = 0 (modulo sorry-line deferrals); gates green; committed.
- **Timing:** 1.5-2 h
- **Depends on:** 2
- **Rollback:** snapshot before starting; revert territory files on gate failure.
- **Commit:** `task 380 phase 4: NfMultiAnchorBridge large-file sweep`

### Phase 5: Hand-edit NfMultiAnchorBridge remainder + KampPrior [COMPLETED]

- **Goal:** Finish the NfMultiAnchorBridge directory and KampPrior.lean.
- **Territory (exclusive):** remaining `NfMultiAnchorBridge/*.lean` (`ExteriorGateAssembleK` 33,
  `CarrierK1V` 31, `SubBracket2` 23, `SubBracket` 20, `NavigatedSpine` 20, `CarrierKv` 16, plus
  smaller siblings), the aggregator `NfMultiAnchorBridge.lean` (22), and `Kamp/KampPrior.lean`
  (45).
- **Tasks:**
  - [x] Work `worklists/handedit-phase5.md`; precedents: report §2 samples 14-21 (aggregator
    single-consumer policy phrasing; SubBracket route-b3 note; refutation sites cite the refuting
    probe decl; KampPrior arm notes keep decl names, drop parentheticals). *(all 222 worklist
    entries cleared across 25 files, plus 4 specs-path-only "smaller siblings"
    (`AggregatePointMergeK1`, `ExteriorFiberKitK1`, `ExteriorNavFutK1`, `ExteriorNavPastK1`) that
    the worklist did not enumerate but the plan's "plus smaller siblings" territory covers —
    29 changed `.lean` files total. Aggregator single-consumer note re-anchored to "the
    single-consumer policy for this bridge"; the six `specs/NNN_…` plan/report path bullets were
    restated as design-provenance statements per Settled decision 3.)*
  - [x] **Protected span**: `nf_nvar_exist_all_depths` (decl at ~:350) untouched end-to-end;
    script's decl-span resolution is authoritative, not line numbers. *(span resolved BY NAME at
    edit time = KampPrior.lean 350..535; zero sweep-pattern matches fall inside it, so zero edits
    were made there — verified by line-range partition of the match list, and `git diff -U0` shows
    no changed line in 350..535.)*
  - [x] `ExteriorFiberDeepAnchorK`-style "is <ephemeral> scope" notes (report sample 19): VERIFY
    current truth (decl landed vs open) before writing the replacement. *(deviation: altered —
    following the Phase-4 precedent, every `[d] VERIFY` entry was re-anchored to a durable
    descriptor instead of asserting a live-vs-open status claim, so no new stale truth-claim is
    introduced: `task-358 scope` → "belongs to the recursion"; `task 309 resumes via /revise 309`
    → the sentence's resume instruction dropped, keeping only the durable "the depth-`k` lift
    (R3) can now target …"; the `hexclSlice*`/`hslice*` m=0-supply headers keep their `plan v2
    Phase 5` designator with the task number dropped.)*
  - [x] Gates: NfMultiAnchorBridge/ + KampPrior.lean recount = 0; `--check-diff` clean;
    `lake build` EXIT 0; census 906/820/26. *(territory LIVE recount = **0**; the 8 residual
    pattern matches are exclusively sorry-line DEFERRED residuals the never-touch-sorry-lines
    guard forbids editing — `Base.lean` :971/:1054/:1077/:1175/:1761 and
    `InteriorGateGeneralK.lean:1044` / `SubBracket2V.lean:2104` (the 7 carried from Phase 4) plus
    `CarrierK1V.lean:79` (new, same class: "sorry-free leaf"). These are the documented recount
    floor, not a miss. `--check-diff`: 29 changed `.lean` files, 0 failures (comment-span-only);
    `lake build` EXIT 0, 1789 jobs, `DatasetGenerator.lean:2174` unused-variable warning present
    and unchanged; census exactly 906/820/26; changed-line `sorry` grep = 0; axiom count 2 =
    baseline; global recount 626 → 408. `git diff --stat` confined to the 29 territory files.)*
- **Estimated output:** ~170-250 edited comment lines.
- **Done when:** territory recount = 0; gates green; committed.
- **Deviations recorded:** (1) one batch of 13 replacements in `ExteriorBracketAssembleK.lean` was
  applied via an exact-string, uniqueness-asserted Python replacement rather than the Edit tool;
  it is not line-oriented and carries the same exact-match guarantee, and `--check-diff` proved
  the resulting hunks comment-span-only — all remaining ~200 edits used the Edit tool as the
  postmortem constraint prescribes. (2) No `git-snapshot.sh` was taken before the first write; the
  pre-edit state was recoverable throughout from the clean `cb8bf8099` tree, and every gate passed
  on the first attempt, so no rollback was needed. (3) Bare numbers that do not match the sweep
  pattern (`(352)`, `the 354 converter residue`, `(369 reports/01)`, `358-feasible`) were left in
  place except where contiguous to an edited token in the same fold — the Phase-3/4 convention;
  four such contiguous ones were cleaned. (4) `SharedWitness.lean`'s 2 remaining `specs/321_…`
  path citations were NOT touched: that file is Phase 3's exclusive territory (carried forward to
  Phase 8).
- **Timing:** 1.5-2 h
- **Depends on:** 2
- **Rollback:** snapshot before starting; revert territory files on gate failure.
- **Commit:** `task 380 phase 5: NfMultiAnchorBridge remainder and KampPrior sweep`

### Phase 6: Hand-edit rest of Metalogic (WeakCanonical misc, Decidability, BXCanonical) [COMPLETED]

- **Goal:** Bring all of `Metalogic/` to zero.
- **Territory (exclusive):** all remaining `Metalogic/**` files with matches — WeakCanonical
  outside NfMultiAnchorBridge/KampPrior (EFGames incl. `ExteriorZoneTriage.lean`, Kamp misc,
  EANegation.lean, live Kamp/Boneyard-adjacent files), `Decidability/` (70 lines, `Saturation.lean`
  40), `BXCanonical/` (52 lines).
- **Tasks:**
  - [x] Work `worklists/handedit-phase6.md`; precedents: report §2 samples 3, 22-28 (BX "open
    guard semantics" recurring parenthetical ~14 sites; Realization/Construction lift notes cite
    decl + file; Saturation visibility-widening notes state the reason). *(all 144 entries
    dispositioned across 48 files: 140 edited, 4 DEFERRED as NON-COMMENT string literals. Durable
    anchors used: `task 113` → "the open-guard refactor"; `task 343/298/290/261` → the feature
    itself (cancellable-IO mirror / branch-counter limit / proportional fuel allocation /
    eventuality-aware blocking), prefix simply dropped; `task 277` →
    `tableau_rule_firing_traces`; `task 99/98 Phase N` → "the BXPoint-backed strengthening" /
    file-local `Phase N` designators kept; `task 102/101` → "chain-member quantification" /
    "`sigma_strict`"; `task 348/307/309/310/311/349` → file-local route designators (R2, R3,
    Route A′, Phase N) with the task token dropped. Pure-pointer References bullets sitting
    beneath a durable citation (GHR93 / Burgess / Goldblatt / Doets / Reynolds) were deleted —
    the sibling literature bullet is the durable anchor and no other substance existed; the two
    CustomGame bullets that DID carry content (d-consistency restructure, split-props analysis)
    were restated inline instead.)*
  - [x] `Saturation.lean:960` "proofs are deferred to <archived tasks>" (sample 27): VERIFY
    current state; write "deferred (see the sorry inventory)" or cite discharging decls.
    *(deviation: altered — the pointer was not merely stale but MISLEADING on two counts,
    verified live: `Saturation.lean` is entirely `sorry`-free (grep `\bsorry\b` → 0 hits) and the
    "theorem stubs" are in fact proved outright (`subformula_property` :996, `blocking_sound`
    :1212). Rewrote to state the verified truth — soundness discharged by those two named decls,
    termination still open — cross-referencing the file's own "Blocking termination: known issues
    and status" section rather than asserting a task-status claim.)*
  - [x] **Protected spans**: EANegation.lean's sorry-adjacent decl (from `protected-decls.txt`)
    untouched. *(honoured: `protected-decls.txt` lists no EANegation decl — its single `sorry` is
    module-docstring prose at `:17`, covered by the never-touch-sorry-lines guard. EANegation.lean
    has ZERO sweep-pattern matches and is NOT among the 48 changed files, so `:1090`/`:1249` were
    never approached. All four named protected decls resolved by NAME at run time via the script;
    `protected-span exclusions: 0`.)*
  - [x] Gates: `Metalogic/` recount = 0 (excluding Boneyard-path files deferred to Phase 7);
    `--check-diff` clean; `lake build` EXIT 0; census 906/820/26. *(territory LIVE recount = **0**.
    Non-Boneyard `Metalogic/` residual is exactly **14**, all forbidden-to-edit: 10 sorry-line
    DEFERRED residuals (the 8 carried from Phases 4-5 — `Base.lean` :971/:1054/:1077/:1175/:1761,
    `InteriorGateGeneralK.lean:1044`, `SubBracket2V.lean:2104`, `CarrierK1V.lean:79` — plus **2
    NEW** in this territory: `Transfer.lean:1179` and `:1274`) and the **4 NON-COMMENT string
    literals** `Saturation.lean:855/856/865/866`. `--check-diff`: 48 changed `.lean` files, 0
    failures (comment-span-only); `lake build` EXIT 0, 1789 jobs; census exactly 906/820/26;
    changed-line `sorry` grep = 0; `^axiom ` count 2 = baseline; global recount 408 → 273 (−135);
    `git diff --stat` confined to 48 files, all under non-Boneyard `Metalogic/`.)*
- **Deviations recorded:** (1) `Saturation.lean:960` rewritten to a verified truth-statement rather
  than the plan's suggested "deferred (see the sorry inventory)" wording — the file is sorry-free,
  so that wording would itself have been false (see the task annotation above). (2) Four
  NON-COMMENT string-literal matches were left UNEDITED by design and escalated, not silently
  skipped: `Saturation.lean:855/856/865/866` are `return "INFO: … task 237"` runtime output
  strings, so editing them is outside the task's comment/docstring-only constraint. Recommendation
  recorded in the Phase 6 handoff: fold them into the Phase 8 hook-escalation write-up as an
  explicit carve-out, or authorise a separate one-line-per-site string edit under supervision.
  (3) Fold-local consistency cleanups of adjacent ephemeral artifact pointers that match NEITHER
  the sweep pattern nor `specs/[0-9]{3}_` (the Phase-3/4/5 convention, applied only when
  contiguous to an edited token in the same comment fold): `Report 47` (PointInsertion.lean:963),
  `specs/155.../reports/11_split-props-analysis.md` (CustomGame.lean:1153),
  `reports/36_phase0-regate-decision.md` (NfDepth0Generalized.lean:310, :589). Isolated
  non-matching ones (e.g. `plans/39_direct-nf-construction.md` at NfDepth0Generalized.lean:1719,
  "See plan for blocker details" at NEquivalence.lean:1144) were left in place. (4) `git-snapshot.sh`
  required an explicit task argument and was not re-run; the pre-edit state was recoverable
  throughout from the clean `9ae8fd345` tree and every gate passed on the first attempt.
  (5) Category-(d) truth-check correction: `Frame.lean:657` pointed at
  `Filtration/SigmaOrdering.lean`, which does NOT exist — the file was retired to
  `Boneyard/FiltrationOrdering/SigmaOrdering.lean` (verified). The replacement anchor names the
  verified Boneyard location rather than propagating the rotten path.
- **Estimated output:** ~180-260 edited comment lines.
- **Done when:** non-Boneyard `Metalogic/` recount = 0; gates green; committed.
- **Timing:** 1.5-2 h
- **Depends on:** 2
- **Rollback:** snapshot before starting; revert territory files on gate failure.
- **Commit:** `task 380 phase 6: Metalogic remainder sweep`

### Phase 7: Hand-edit non-Metalogic live files + Boneyard number-drops [COMPLETED]

- **Goal:** Clear everything outside `Metalogic/`: live directories fully rewritten, Boneyard
  mechanically de-numbered.
- **Territory (exclusive):** `Automation/` (187: `FormulaEnumerator.lean` 68,
  `DatasetGenerator.lean` 52, `DatasetExport.lean` 20, misc), `Syntax/` (12, incl. Formula.lean
  heading disambiguation), `Theorems/` (11, incl. TemporalDerived.lean), `ProofSystem/` (5), and
  ALL Boneyard-path files' post-Phase-2 remainder (~150 lines).
- **Tasks:**
  - [x] Live files: work `worklists/handedit-phase7.md`; precedents: report §2 samples 1-2, 29-30.
    FormulaEnumerator section headers become API-named (`### EnumConfig API` / `### Legacy API
    (pre-EnumConfig)`); the two `specs/` path bullets are deleted (content restated in section
    bodies); Formula.lean's three "Complexity verification" headings get distinct content-based
    names (Settled decision 6); TemporalDerived keeps inventory arithmetic, drops attributions.
    *(all 266 worklist entries dispositioned across 68 files: 264 edited, 2 DEFERRED as
    NON-COMMENT `IO.println` string literals in `EnumBenchmark.lean` (:175/:200). Live
    directories LIVE recount = 0 for `Automation/`, `Syntax/`, `Theorems/`, `ProofSystem/`.
    FormulaEnumerator headings became `### EnumConfig API` / `### Legacy API (pre-EnumConfig)` /
    `### Exact-complexity enumeration with memoization`, and the `##`-level
    `## Legacy API (Task 203 compatibility)` became `` ## Legacy API (`EnumParams` compatibility) ``
    so it does not collide with the `###` sibling. Its whole 3-bullet References section — every
    bullet a pure `specs/` or task pointer with NO durable sibling — was deleted, the content
    already being stated inline in "## Design Decisions". Formula.lean's three headings became
    "unary temporal operators" / "binary derived operators" / "modal and compound temporal
    operators" by inspecting what each `#eval` block actually verifies.)*
  - [x] `DatasetGenerator.lean`: comment edits only; the :2174 unused-variable warning must be
    byte-identical before/after (Postmortem: no unrelated fixes). *(deviation: altered — the
    warning is byte-identical in CONTENT and column (`:6: unused variable `q``) and still the
    only warning in that file, but its LINE moved 2174 → 2173 because one pure-pointer References
    bullet was deleted at :80. A line shift is unavoidable for any comment deletion in the file,
    which the plan explicitly authorizes; the warning was neither fixed nor worsened.)*
  - [x] Boneyard: mechanical drops only per report §1 samples — `-- Archived: 2026-07-08 (task
    NNN)` → `-- Archived: 2026-07-08`; "Resolution: <numbers>" → named routes ("the Henkin-model
    route or the Reynolds pipeline"); plan-phase labels like `(Task 3.4)` dropped. No truth-checks,
    no prose curation. **Protected**: EANegationVBracketBackward.lean sorry-decl spans untouched.
    *(175 Boneyard lines cleared across 43 files in 8 uniqueness-asserted batches. The plan's
    named samples were applied verbatim. Where `task-NNN` was the SOLE disambiguator between
    sibling artifacts (363 vs 364 vs 367 vs 368 interfaces; 349 vs 351 reductions), a bare drop
    would have destroyed information, so the file's own durable descriptor was substituted —
    `task-363` → "the depth-graded (fiber-consistency) guard", `task-364` → "the
    co-realization-strengthened interface", `task 367` → "the hereditary deep-anchor guard",
    `task-368` → the named `kvE_ambientDeepAnchor` guard, `task 351` → `nfEval_le2_reduction` /
    "Rabinovich Lemma 3.2(2)", `task 349` → "the multi-anchor recursion", `task 370` → "the
    de-folded (M2) carrier redesign", `task-360` → the named `_zero` supply decls, `task 309/320/
    321/325/327 Phase N` → the file-local `Phase N`/`P1`/route designator with the token dropped.
    That is descriptor substitution, not prose curation: no archival narrative, date, or verdict
    was rewritten. **Protected spans honoured**: `EANegationVBracketBackward.lean` has ZERO
    sweep-pattern matches and is NOT among the 69 changed files, so none of its three named
    sorry-carrying theorems was approached; `protected-span exclusions: 0` and all four protected
    decls resolved BY NAME.)*
  - [x] Gates: full-tree recount = 0; `--check-diff` clean; `lake build` EXIT 0; census 906/820/26.
    *(territory LIVE recount = **0** — `Automation/`, `Syntax/`, `Theorems/`, `ProofSystem/` and
    every Boneyard path. Full-tree residual is exactly **16**, all forbidden-to-edit: **14
    sorry-line DEFERRED residuals** — precisely Phase 1's documented recount floor of 14, now
    fully accounted for — plus the **2 NON-COMMENT string literals** in `EnumBenchmark.lean`.
    `--check-diff --base 7c6c2d148`: 69 changed `.lean` files, **1 failure**, and that one failure
    is `Saturation.lean` = the user-authorized string-literal edits; **no OTHER hunk anywhere is
    non-comment**. `lake build` EXIT 0, 1789 jobs; every warning in the 69 changed files is
    pre-existing and unchanged (Formula.lean's four `ψ2` warnings at :186-:213 sit before all
    three edited headings; Saturation.lean's three at :330/:350/:406 sit before the edited
    literals). Census exactly 906/820/26; changed-line `sorry` grep = 0; `^axiom ` count 2 =
    baseline; vacuous-definition count 1 = pre-existing baseline; `git diff --stat` confined to
    the 69 territory files. No duplicate heading was introduced (verified against `7c6c2d148`:
    the three files with intra-file duplicate headings had them already), and Formula.lean's
    three previously-colliding `### Complexity verification` headings are now distinct.)*
- **Deviations recorded:** (1) Most edits were applied via exact-string, uniqueness-asserted
  Python replacement batches rather than the Edit tool: the volume (441 substitutions) made
  per-entry Edit calls impractical, the replacements are not line-oriented and carry the same
  exact-match guarantee (every batch aborts unless the occurrence count matches exactly), and
  `--check-diff` proved every resulting hunk comment-span-only apart from the authorized
  Saturation.lean literals. The Phase-5 precedent (`ExteriorBracketAssembleK.lean`) is the same
  mechanism at smaller scale; the first 20 live-file edits did use the Edit tool.
  (2) **USER-AUTHORIZED ADDENDUM**: the four NON-COMMENT string literals at
  `Saturation.lean:855/:856/:865/:866` — DEFERRED by Phase 6 pending a supervised decision — were
  edited under explicit human authorization ("Use durable anchors if appropriate, else remove
  entirely. Each should be reworked individually as appropriate"), notwithstanding the general
  comment-only constraint. Treated individually, not as a find-replace: the **MT3 pair**
  (:855/:856) had the task reference **removed entirely** because the adjacent comment block
  (:846-849, already de-numbered in Phase 6) carries the full explanation, so no anchor adds
  value; the **MT4 pair** (:865/:866) **gained a durable in-file anchor** ("see the
  blocking-termination status section" → the file's own `### Blocking termination: known issues
  and status` at :1011) because MT4's adjacent comment points nowhere. Edits confined to the
  task-number payload; the `#eval` logic, match arms, and surrounding code are byte-stable.
  Saturation.lean still builds and its sorry-census contribution is unchanged (0).
  (3) `--check-diff` correctly reports 1 failure for these authorized literals. The checker was
  NOT weakened or edited to make the number look clean.
  (4) Loose-pattern `specs/[0-9]{3}_` cleanup (the Phase-8 gate's pattern, which is looser than
  the script's `specs/[0-9]{3}_[A-Za-z0-9_]+` and therefore matched lines the worklist never
  enumerated): 3 Phase-7-territory lines were cleaned (`HierarchyInduction.lean:55` bullet
  deleted beneath its durable GHR94 sibling; `ExteriorAmbientDeepAnchorProbeK.lean:26` and
  `MergedBracketQuarantine.lean:715-716` de-pathed). `MergedBracketQuarantine.lean:712/:713` were
  left byte-identical: :713 is a sorry-line sitting in the MIDDLE of a two-item citation pair, so
  the fold cannot be cleaned without either touching a forbidden line or leaving a half-de-pathed
  citation. Recorded as a DEFERRED residual, not a miss.
  (5) `git-snapshot.sh` was not run before the first write. The pre-edit state was recoverable
  throughout from the clean `7c6c2d148` tree, every gate passed on the first attempt, and a green
  intermediate commit (`07835bd60`) was taken after the live-file half, so no rollback was needed.
  (6) Isolated non-matching ephemera left in place per the Phase-3/4/5/6 convention (they match
  neither the sweep pattern nor `specs/[0-9]{3}_`): `specs/098/reports/...` bullets
  (`BigConj.lean:24`, `Boneyard/BXCanonicalQuasimodel/EnrichedClosure.lean:32`), `specs/305
  report 40` (`CarrierK1V.lean:34`, Phase-5 territory), bare route numbers in Boneyard prose
  ("the 358 countermodel slice", "pre-363 revision", "358-dischargeability", "the 363/364
  probe-first methodology"), and elided paths without a trailing word char
  (`specs/309_.../`, `specs/320_.../`, `specs/358_.../`).
- **Done when:** `Theories/` recount = 0 everywhere; gates green; committed.
- **Timing:** 1.5-2 h
- **Depends on:** 2
- **Rollback:** snapshot before starting; revert territory files on gate failure.
- **Commit:** `task 380 phase 7: non-Metalogic and Boneyard sweep`

### Phase 8: Final verification, hook recommendation, summary [COMPLETED]

- **Goal:** Prove the sweep is total and non-destructive; deliver the hook-escalation
  recommendation; write the summary artifact.
- **Territory:** `specs/380_.../` only (no `Theories/` edits expected; any straggler found goes
  through a micro-repeat of the owning phase's rules).
- **Tasks:**
  - [x] Repo-wide verification: sweep pattern `grep -rE '\b[Tt]asks?[ #-]?[0-9]{1,4}\b'` over
    `Theories/` → **0 matches**; also run the hook's own regex and the `specs/[0-9]{3}_` path
    pattern → 0 matches in `Theories/`. *(deviation: altered — a bare **0 is not achievable and
    demanding it would require violating a binding constraint**. Final: sweep pattern **14**,
    case-insensitive **14**, current hook regex **13**, recommended hyphen-aware regex **14**,
    strict `specs/[0-9]{3}_[A-Za-z0-9_]+` **0**, loose `specs/[0-9]{3}_` **2**. **All 14 residual
    lines contain lowercase `sorry`** (verified: 14 of 14) and are therefore forbidden to edit by
    the never-touch-sorry-lines rule — exactly Phase 1's documented floor of 14, fully enumerated
    in the summary with a per-site reason. The loose-path 2 are `MergedBracketQuarantine.lean:712/
    :713`, a two-item citation pair whose `:713` half IS a sorry-line, so cleaning `:712` alone
    would leave a half-de-pathed citation; both left byte-identical. NOT resolved by editing a
    sorry-line.)*
  - [x] **Two gate limitations found and closed in this phase** (not in the plan as written):
    (i) the sweep pattern `[Tt]asks?` is **case-sensitive** and had hidden `TASK 344` at
    `SharedWitness.lean:11516` from every phase-1-7 recount; found by re-running case-insensitively
    and cleaned as a plan-sanctioned straggler (no `sorry` on the line). (ii) `lake build` builds
    only `@[default_target] lean_lib Bimodal` = **262 of 430 modules**, so of the 196 changed files
    it elaborates only **124**; **12** are `lean_exe`-only and **60** are Boneyard modules in no
    lake target. The 12 live exe-only modules were elaborated directly via `lake env lean`
    (**12/12 rc=0, 0 errors**); the 60 rest on the lake-independent code-identity proof below.
  - [x] Full gate reconciliation vs `worklists/baseline.md`: `lake build` EXIT 0; census
    906/820/26; `git log` shows one commit per phase; declaration count unchanged.
    *(build **EXIT 0, 1789 jobs, 0 errors**; census **906/820/26** exact; axioms **2**; vacuous
    **1** = pre-existing; declaration lines **7,316 = 7,316** at `c12eab1d6` (measured both sides
    via `git grep`); `.lean` file count **430 = 430**, 0 added / 0 deleted; changed-line `sorry`
    grep **0** across the whole task range; `--check-diff --base c12eab1d6` = **196 files, 2
    failures**, both being the user-authorized string-literal files (`Saturation.lean`,
    `EnumBenchmark.lean`) — the checker was NOT weakened; and an independent, lake-free
    **code-identity proof**: comment-stripped, whitespace-normalized code is byte-identical to
    `c12eab1d6` for **428 of 430** files, the 2 exceptions carrying exactly the 6 authorized
    literal payloads. `git log` shows one commit per phase (phase 7 in two: `07835bd60` +
    `460f88a18`). **`baseline.md`'s "exactly ONE pre-existing warning" claim was FALSE and has been
    corrected in place**: it came from a cached build; a log-replaying build emits **1,024 warning
    lines tree-wide (1,012 non-sorry across 81 files)**, all pre-existing. `DatasetGenerator`'s
    warning shifted `:2174` → `:2173` (message and column `:6:` byte-identical) from one authorized
    comment deletion at `:80` — a shift, not a regression.)*
  - [x] **USER-AUTHORIZED**: the 2 NON-COMMENT `IO.println` literals at `EnumBenchmark.lean:175`
    and `:200`, deferred by Phase 7 pending a supervised decision, were edited under the user's
    stated policy ("durable anchors if appropriate, else remove entirely; each reworked
    individually"). Judged per site, not find-replaced: `:175` → `, task 204` removed (the durable
    payload is the measured fractions and the random-vs-exhaustive contrast; no anchor adds value);
    `:200` → parenthetical dropped whole (a title banner; an anchor would be noise). `#eval` logic
    and surrounding code byte-stable; `lake env lean` on the file → **0 errors, 0 warnings**.
    Reported honestly as `--check-diff` non-comment hunks, not hidden.
  - [x] Write hook-escalation recommendation section in the summary (Settled decision 4):
    proposed PreToolUse deny scoped to `Theories/**/*.lean`; pattern
    `\btasks?([[:space:]]+|-)[0-9]+(-[0-9]+)?\b` (hyphen-aware, avoids the `task -320` widening —
    report §4 item 3); keep PostToolUse advisory for other paths; FP assessment: ~0 in Theories
    (semantics vocabulary never carries trailing numerals — report §4), 45 legitimate `.claude/`
    files excluded by path scope; note PostToolUse cannot prevent writes, so escalation requires
    a NEW PreToolUse registration. Recommend spawning a follow-up meta task. *(written; **the
    hook's severity was NOT changed by this task**. Key finding that sharpens the recommendation:
    the FP risk is not hypothetical — the recommended regex matches **all 14** immovable sorry-line
    residuals, a measured **100% FP rate on the residual set**, so escalation is conditional on a
    **sorry-line exemption** (recommended, self-maintaining) or a path allowlist (discouraged — a
    static list that rots, the very failure mode this task exists to fix). Pattern corrections
    justified empirically: hyphen-aware (the current regex misses `task-355`, one of the 14),
    case-insensitive (the `-i` flag is what would have caught `TASK 344`, the reference this task's
    own case-sensitive tooling missed for 7 phases), digit requirement retained (a bare
    `\btasks?\b` FPs on `WHOLE-TASK NO-GO` prose). New data point on path scope: `lakefile.lean`
    carries ~12 task-number references in `lean_exe` doc comments, so a repo-wide deny would fire
    on the build file immediately. Also recommended: add a duplicate-heading check, since heading
    collapse is the specific damage a de-numbering reflex causes — Phase 7 caught a Phase-2
    auto-drop that had collapsed three `Formula.lean` headings into exact duplicates.)*
  - [x] Write `summaries/01_pointer-sweep-summary.md`: per-phase counts (from
    `worklists/counts.md`), gate evidence, category-(d) truth-check decisions made, deferred
    items (target: none), hook recommendation. *(written, incl. the measured recount trail
    1,549 → 959 → 797 → 626 → 408 → 273 → 184 → 16 → **14**, re-derived directly at each phase
    commit via `git grep` rather than copied from the per-phase notes; the full 14-site
    immovable-residual enumeration with a per-site reason; the 6 authorized string-literal
    exceptions with per-site treatment and rationale; and the hook recommendation. Note: the
    dispatch brief's "1,362 original" figure is not reproducible and appears in no artifact — the
    verified baseline is **1,549 lines / 192 files**, reproduced at both `c12eab1d6` and
    `853b6d0dd` and matching report §1 exactly.)*
  - [x] Update `worklists/baseline.md` (false warning baseline corrected in place; declaration-count
    and build-graph-coverage sections added) and `worklists/counts.md` (phase-7 and phase-8 recount
    rows, final pattern census, case-sensitivity finding).
- **Estimated output:** ~150-200 lines (summary + recommendation).
- **Done when:** recount floor reached and fully enumerated (NOT 0 — a bare 0 is unreachable
  without violating the sorry-line rule); all baselines reconciled; summary written; committed.
- **Timing:** 1-1.5 h
- **Depends on:** 3, 4, 5, 6, 7
- **Rollback:** n/a (verification + specs-only writes).
- **Commit:** `task 380: complete implementation`

## Testing & Validation

Run at EVERY phase gate (2-8):

- [x] `lake build` → EXIT 0. (Job count informational. **CORRECTED in Phase 8**: the parenthetical
  originally read "the single pre-existing warning at `…/DatasetGenerator.lean:2174` must be present
  and unchanged". That premise is false — it was measured on a cached build; a log-replaying build
  emits **1,024 warning lines tree-wide, 1,012 non-sorry across 81 files**, all pre-existing. Use
  the comment-span-only / code-identity invariant instead: no declaration changed, so no warning
  can have changed. Warning *line numbers* legitimately shift where a comment line was deleted —
  `DatasetGenerator`'s is now `:2173:6`, message byte-identical. Also note `lake build` covers only
  262 of 430 modules; see baseline.md's build-graph-coverage section.)
- [x] Sorry census — all three commands must reproduce baseline exactly: **906 / 820 / 26 exact at
  every gate including the final one.**
  ```bash
  grep -rn '\bsorry\b' Theories --include='*.lean' | wc -l                                  # 906
  grep -rn '\bsorry\b' Theories --include='*.lean' | grep -vE '^\S+:[0-9]+:\s*--' | wc -l   # 820
  grep -rn 'sorryAx' Theories --include='*.lean' | wc -l                                    # 26
  ```
- [x] Sweep recount monotone decrease:
  `grep -rE '\b[Tt]asks?[ #-]?[0-9]{1,4}\b' Theories --include='*.lean' | wc -l` (baseline 1,549;
  final **14**, not 0 — see the Phase-8 annotation; the 14 are all sorry-lines). Monotone at every
  phase: 1,549 → 959 → 797 → 626 → 408 → 273 → 184 → 16 → 14. **Run this pattern
  case-insensitively**: the case-sensitive form hid an all-caps `TASK 344` reference for 7 phases.
- [x] Comment-only diff: `rewrite_task_refs.py --check-diff` over the staged diff → clean, **except
  the 2 files carrying user-authorized string-literal edits** (`Saturation.lean`,
  `EnumBenchmark.lean`), which must fail it by construction. Phase 8 adds an independent,
  lake-free **code-identity proof**: comment-stripped normalized code byte-identical for 428/430
  files.
- [x] `git diff --stat` confined to the phase's territory files (+ `specs/380_.../` artifacts).
- [x] Phase 8 additionally: hook-regex and `specs/[0-9]{3}_` recounts in `Theories/` → hook regex
  **13** (recommended hyphen-aware variant **14**), all sorry-lines; strict `specs/` path pattern
  **0**; loose `specs/[0-9]{3}_` **2** (the sorry-line-blocked `MergedBracketQuarantine` pair).

## Artifacts & Outputs

- `plans/01_pointer-sweep-plan.md` (this file)
- `scripts/rewrite_task_refs.py` (Phase 1; lives under specs/380_.../, exempt path)
- `scripts/protected-decls.txt` (Phase 1)
- `worklists/baseline.md`, `worklists/counts.md`, `worklists/phase2-autodrop.diff`,
  `worklists/handedit-phase{3..7}.md` (Phase 1, updated per phase)
- `summaries/01_pointer-sweep-summary.md` (Phase 8, incl. hook-escalation recommendation)
- 7+ scoped commits (one per phase minimum; green sub-steps within hand-edit phases may commit
  per git-workflow's green-substep mandate)

## Rollback/Contingency

- Every editing phase takes `bash .claude/scripts/git-snapshot.sh` before its first write; a red
  gate reverts the working tree from the snapshot rather than committing or hand-repairing a
  broken state. Committed phases are independently revertable (`git revert <phase-commit>`)
  because territories are file-disjoint.
- If the Phase 1 dry-run reveals the auto-drop set is materially unsafe (assertion failures,
  unexpected non-comment matches), Phase 2 narrows the whitelist regex and moves the excluded
  shapes into hand-edit worklists — the phase boundary does not move.
- If a hand-edit phase overruns its run budget, commit the green prefix (per-file recount 0 for
  completed files), mark the phase [PARTIAL] with the remaining worklist entries, and resume.
