# Research Report: Task #452

**Task**: 452 - correct_roadmap_sorry_inventory_and_bxcanonical_status
**Started**: 2026-08-18T06:00:00Z
**Completed**: 2026-08-18T06:24:00Z
**Effort**: research (no .lean edits; markdown correction task)
**Dependencies**: None
**Sources/Inputs**:
- `scripts/check-module-invariants.sh` (checks C2, C3, C5 — run live against HEAD)
- `lake build` (confirmed green, up to date)
- `specs/ROADMAP.md` (full read, 1770 lines)
- `git blame` / `git log -L` on ROADMAP.md section headers
- `FormalSystem/Metalogic.lean` module docstring (current architecture source of truth)
- Direct filesystem checks (`find`, `grep`) against `FormalSystem/`
**Artifacts**: this report
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **Deliverable (a) confirmed**: C3 verifies exactly **one** structural sorry in the live tree
  (`countermodel_discrete`, `FormalSystem/Metalogic/WeakCanonical/Transfer.lean:1068`). The
  "Sorry Inventory" section (ROADMAP.md:881-962) claims 23, tabulates 5 dead `RootScopedChain.lean`
  rows (file only exists under two Boneyard copies) and 18 more "Irreflexive-Consequence" rows
  that are equally unreconciled.
- **Deliverable (b) confirmed, and worse than scoped**: C2 verifies all four flagship BXCanonical
  theorems (`completeness`, `completeness_dense`, `completeness_discrete`,
  `Chronicle.countermodel_dense`) against the recorded axiom baseline — clean match, three of
  four axiom-set-clean. `FormalSystem/Metalogic/StrongCompleteness.lean` imports
  `BXCanonical.CompletenessDedekind` directly; `FormalSystem/Metalogic.lean`'s own current
  docstring calls `BXCanonical/` **"the wired entry point"** (20 files) for the Chronicle
  completeness route. The false "BXCanonical is dead code, ~17 sorries, mathematically false"
  claim is **not confined to line 624** — it is duplicated near-verbatim at ROADMAP.md:19-23 and
  :296, both inside the **Overview section that the file's own preamble (line 8-9) declares
  current**. Fixing only line 624 would leave the same false claim standing in the part of the
  document readers are told to trust.
- **Deliverable (c) sweep result**: everything from `## Active Metalogic Paths` (line 595) through
  the end of `## Task Cross-Reference` (line 1770) — roughly 1,175 of the file's 1,770 lines —
  was last touched between 2026-04-10 and 2026-06-16, predates the current three-route
  architecture (Chronicle inside BXCanonical for dense / Kamp-Reynolds `WeakCanonical` for
  discrete / `CompletenessDedekind` for the real-line route), and contains multiple further
  falsifiable claims beyond the two named sections (catalogued below with file:line and the
  live-tree fact that contradicts each). The `## Overview` (lines 1-343, excluding the two
  hits above) and `## Paper Alignment Programme` (line 1599+) sections are current,
  self-superseding "living log" style and were confirmed accurate — they are the model the
  corrected sections should follow.
- **C5 currently passes** (`all module-shaped paths in 1658 markdown files resolve`) — the
  RootScopedChain/Irreflexive-Consequence tables' `file:line` cells reference a real archived
  file (`RootScopedChain.lean` exists, just only under `Boneyard/`), which is a *class name* match,
  not a bare-word module path, so C5's regex-based check does not currently flag it. Any rewrite
  must still keep C5 green (no new unresolved `FormalSystem.*` paths).

## Context & Scope

Task 452 asks for a research report (this task is `task_type: markdown`, dispatched via
`skill-researcher` → `general-research-agent`) that corrects the factual record needed to
implement two ROADMAP.md fixes, plus a sweep report for a follow-on decision. Per the task's
NON-GOALS, no `.lean` edits and no archival were performed; this report does not edit
ROADMAP.md — it hands verified ground truth and a scoped defect catalog to `/plan`.

## Findings

### Verification runs (ground truth for the correction)

**C3 (sole structural sorry), run 2026-08-18 against `11ad049b8`:**
```
PASS  C3   sole structural sorry is in theorem countermodel_discrete (FormalSystem/Metalogic/WeakCanonical/Transfer.lean)
            enclosing declaration: theorem countermodel_discrete (A : Set Formula)
```
Full-tree `grep` for structural sorry shapes (`^\s*sorry$`, `:=\s*sorry$`, `exact sorry`,
`<;> sorry`) outside both Boneyards returns exactly this one hit, at line 1068 today (the
Overview section's own 2026-07-24 block records it at `:1277`, and a 2026-07-27 block at
`:1242` — the enclosing declaration is stable, the line number drifts with unrelated edits
elsewhere in the file; **cite the check, not a line number**, per deliverable (a)'s intent).

**C2 (four flagship axiom sets), run 2026-08-18 via `lake env lean` against the built library:**
```
'FormalSystem.Metalogic.BXCanonical.completeness' depends on axioms: [propext, sorryAx, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.BXCanonical.completeness_dense' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.BXCanonical.completeness_discrete' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.BXCanonical.Chronicle.countermodel_dense' depends on axioms: [propext, Classical.choice, Quot.sound]
```
Matches the script's recorded baseline exactly. `completeness`'s `sorryAx` is the same, single,
isolated sorry C3 found (via `WeakCanonical.countermodel_discrete`) — not a BXCanonical-internal
sorry.

**C5 (markdown module paths), run 2026-08-18:** `all module-shaped paths in 1658 markdown files
resolve (4 allowlisted)` — clean baseline before any edit. Preserve this after rewriting.

**Live BXCanonical inventory** (`find FormalSystem/Metalogic/BXCanonical -maxdepth 1
-name '*.lean'`): exactly 7 top-level files — `CanonicalChain.lean`, `CanonicalModel.lean`,
`CompletenessDedekind.lean`, `Completeness.lean`, `Frame.lean`, `OrderedSeedConsistency.lean`,
`TruthLemma.lean` — plus the `Chronicle/`, `Quasimodel/`, `Filtration/` subdirectories, matching
the task description's "7 live .lean files at the top level plus the Chronicle/ subtree."

**`RootScopedChain.lean` — the Sorry Inventory table's critical-path file:**
```
FormalSystem/Boneyard/ScheduleBasedBFMCS/RootScopedChain.lean   (226 lines)
FormalSystem/Boneyard/DefectDirectedChain/RootScopedChain.lean  (1564 lines)
```
No live copy exists. `RootScopedChain` is referenced 15 times across ROADMAP.md (lines 302, 308,
504, 649-667, 783, 885-896, 1359) — the defect is not confined to the "Critical Path" table; the
same dead reference recurs at 302-308 (inside the current Overview's *historical* summary block,
correctly labeled) and at 649-667/783 (inside the stale `Module Import Graph`, deliverable (c)).

### Architecture reality (`FormalSystem/Metalogic.lean` docstring — the current source of truth)

The live aggregator's own module docstring (dated by its content to the 2026-08 axiom-audit
work, i.e. after `StrongCompleteness.lean`/`CompletenessDedekind.lean` landed) states the
three-way completeness architecture directly:

1. **Dense case** (`Box(F'T) ∈ M`): countermodel on `ℚ` via Cantor isomorphism —
   `Chronicle/ChronicleToCountermodel.lean`, `Algebraic/FlowFrame.lean`.
2. **Discrete case** (`Box(U(T,⊥)) ∈ M`): countermodel on `ℤ` — `WeakCanonical/Transfer.lean`.
3. **Mixed case**: eliminated by `mcs_mixed_case_absurd`.

Plus the Dedekind route (no case split): `BXCanonical/CompletenessDedekind.lean`, "Reynolds
Section 9 Theorem 7." And explicitly: `**BXCanonical/** 20 files # Chronicle completeness
route -- the wired entry point`, versus `**WeakCanonical/** 135 files # Kamp/Reynolds route;
largest subtree in the repository`. `StrongCompleteness.lean:10` directly
`import`s `FormalSystem.Metalogic.BXCanonical.CompletenessDedekind`.

This is the opposite of ROADMAP.md's inherited framing (Chronicle as a *separate, sole* active
path, BXCanonical as its dead antagonist): Chronicle is a **subdirectory of BXCanonical**
(`BXCanonical/Chronicle/`), used specifically for the dense branch; BXCanonical as a whole is the
wired, live, flagship entry point for two of the completeness programme's three/four routes.

### Deliverable (c) sweep — defect catalog beyond the two named sections

All items below are prose claims about sorry counts, dead-code verdicts, or module status,
each checked against the live tree. `git blame` dates are the header line's last-touch date.

| Location | Date | Claim | Contradicted by |
|---|---|---|---|
| **19-23** (`## Overview`, self-declared **current**) | rolled into 2026-07-27 header edits | "The Chronicle path... is the primary and only active path. The BXCanonical path (task 109) is dead code — its ~17 sorries are mathematically false..." | Same defect as deliverable (b), but inside the block the file's own preamble (line 8-9) tells readers is current, not historical. `Chronicle/` is textually a subpath of `BXCanonical/`. Highest-priority fix — must not be left standing if only line 624 is corrected. |
| **296** (`## Overview`, "Planned evolution" subsection) | same as above | "**Sorry summary (dead code)**: ~17 sorries in the BXCanonical/Bundle/Quasimodel/Filtration pipeline are mathematically false... should be archived." | Same claim, third occurrence, same section. |
| **302-308** (Overview, sorry-count table) | same block | Table row: "Critical path (blocking `completeness`) — 5 — `RootScopedChain.lean` — **OPEN** (task 109)" | This table is already correctly labeled `**Sorry summary (HISTORICAL — see the 2026-07-07 "Current state" block above...)**` immediately above it (line 270-271) — **no edit needed**, cited here only because it is the fourth `RootScopedChain.lean` occurrence and confirms the file was already known-dead by 2026-07-07 in the author's own reasoning, which sharpens why 624/881/598 are simply un-synced rather than never-known. |
| **595-599** (`## Active Metalogic Paths` intro) | 2026-04-24 | "The **Chronicle** path... is the sole active completeness path. The BXCanonical path (task 109, abandoned) is dead code — its ~17 sorries..." | Same defect as (b), fourth occurrence; this is the paragraph directly introducing the section deliverable (b) targets — should be corrected in the same edit as line 624. |
| **631-711** (`## Module Import Graph`) | 2026-04-24 (parent header) | Full tree diagram rooted at `Metalogic/BXCanonical/BXCanonical.lean` showing `RootScopedChain.lean (1,487 lines, 5 sorries -- task 109)` as a live import of `Completeness.lean`, plus a closing line "**Total BXCanonical module: ~5,795 lines across 16 files, 19 sorries**" | `Completeness.lean` no longer delegates to `RootScopedChain` (dead, Boneyard-only, see above); current `Completeness.lean` docstring routes to `dd_countermodel`/Reynolds pipeline per the Overview's own 2026-07-24 block. The 16-file/19-sorry inventory is superseded by the 7-file top-level + Chronicle/Quasimodel/Filtration subtree structure and by C2/C3. |
| **712-789** (`## Canonical Model Construction (BXCanonical)`) | 2026-04-10/12 | Describes `bx_le_refl` as "sorry'd (intentionally invalid)" and frames the whole section around the RootScopedChain-delegating `Completeness.lean` | Partially still descriptively true of `Frame.lean`'s definitions (not sorry-count-bearing beyond what's noted), but the "Completeness Theorem" subsection's claim that `Completeness.lean` calls `dd_countermodel` (in `RootScopedChain.lean`) is the same dead reference. Lower priority — mostly definitional exposition, but the final paragraph needs the same fix as the Import Graph. |
| **790-880** (`## Quasimodel/Filtration Infrastructure`, `## How Until/Since Were Closed`) | 2026-04-12 | Frames Quasimodel/Filtration sorry counts (2+4+3=9 "irreflexive-consequence artifacts") as current work supporting the RootScopedChain chain | Same dead-dependency issue; these files still exist live under `BXCanonical/Quasimodel/` and `BXCanonical/Filtration/` but their described role (feeding `RootScopedChain.lean`) is gone. Needs a status re-check, not necessarily a rewrite, since deliverable non-goals exclude closing/reclassifying sorries — flag for follow-up, not blocking (a)/(b). |
| **881-962** (`## Sorry Inventory`) | 2026-04-20 | Deliverable (a) target — 23 sorries, dead `RootScopedChain.lean` table, 18-sorry Irreflexive-Consequence table | C3: exactly 1. Primary deliverable, see Executive Summary. |
| **963-1004** (`## Legacy Code Inventory`) | 2026-04-10 | Lists `Algebraic/LindenbaumQuotient.lean`, `Algebraic/InteriorOperators.lean`, `Bundle/SuccRelation.lean`, `Bundle/CanonicalFrame.lean` as archived to `Boneyard/StrictSemanticsLegacy/` alongside `UltrafilterChain.lean`/`DovetailedChain.lean`/`SuccChainFMCS.lean` (which genuinely are archived) | All four are **live**, not archived: `FormalSystem/Metalogic/Algebraic/LindenbaumQuotient.lean`, `.../InteriorOperators.lean`, `FormalSystem/Metalogic/Bundle/SuccRelation.lean`, `.../CanonicalFrame.lean` all exist outside any Boneyard today. `check-module-invariants.sh` C6 additionally flags `Algebraic.LindenbaumQuotient` and `Algebraic.InteriorOperators` as **unreachable-but-live** modules absent from `scripts/module-invariants-manifest.txt` (a live C6 FAIL today, orthogonal to this task but worth noting for whoever owns C6 remediation). |
| **1005-1077** (`## Burgess-Xu Until-Induction Technique`) | 2026-04-10 | Historical/definitional (axiom roles in the proof); no sorry-count or dead-code claim beyond what's covered above | No correction needed for this task's scope — content describes the axiom system's mathematical role, not current module status. |
| **1078-1438** (`## Dead Ends (Archived)`) | 2026-04-10 | Explicitly and correctly framed as historical anti-patterns ("preserved across the BX migration... remain valid as warnings") | **No edit needed** — this section is self-aware of its own historical status, unlike 595-963. One sub-item ("Current Strategy: Chronicle Construction (Task 107)", inside this section) says Chronicle is "the active completeness strategy" as distinct from BXCanonical and cites `RootScopedChain`-adjacent infrastructure as current — same class of defect, lower priority since the parent section is already marked historical. |
| **1441-1447** (`### Dense Completeness (task 68, 1 sorry)`) | 2026-04-10 | "`dense_completeness_fc` needs a separate proof... 1 sorry" | C2 confirms `completeness_dense` is sorryAx-free today (axioms `[propext, Classical.choice, Quot.sound]`), and the Overview's 2026-07-24 block independently states "`completeness_dense` byte-lists the same pristine set." This entry is stale and should be marked resolved or removed. |
| **1683-1699** (`### Critical Path: Single Sorry Chain`) | 2026-03-24 (parent header; content is task-301-era, dated 2026-06-16 per file footer) | "Only ONE sorry blocks `completeness_discrete`... `nf_nvar_exist_all_depths` (KampPrior.lean:212)" | `KampPrior.lean`'s own current comments state `nf_nvar_exist_all_depths` "is now sorry-free with axioms..." and "(now fully landed, sorry-free)". This is a **third**, independently-stale claim about where "the one sorry" lives (distinct from both the Sorry Inventory's 23-count claim and the Overview's correct current answer, `WeakCanonical.countermodel_discrete`). Recommend this whole subsection be superseded by a pointer to the Overview's current-state block rather than patched in place. |
| **1705-1709** (`### Sorry Cleanup: Zero Sorries for Publication`, items 4-6) | same | Item 6: "**Task 176**: Relocate Chronicle/ out of BXCanonical/, archive dead BXCanonical subtree." | Directly inverted by what actually happened: Chronicle stayed inside BXCanonical, and BXCanonical (not Chronicle) became the flagship. This is a recommendation that reads as a live action item but was superseded by the opposite architectural decision — actively misleading if followed today. |
| **1742-1762** (`## Task Cross-Reference` table) | 2026-04-10 (table structure); **"Updated 2026-05-05"** banner immediately above it | Row `109 \| [NOT STARTED] \| Close 23 BXCanonical sorries (5 critical-path + 18 irreflexive-consequence) \| 93` | Reasserts the 23-count in a third location (table form). Whether task 109's `state.json` status itself needs correction is outside this task's file scope (ROADMAP.md only), but the description text is the same defect. |

**Sections confirmed current / no defect found** (deliverable (c) explicitly asks for this too):
- `## Overview` lines 1-18, 24-269, 343 and its nested "Current state" blocks (self-superseding,
  each new block explicitly marks the prior one historical — this is the pattern the corrected
  Sorry Inventory / BXCanonical sections should imitate).
- `## Paper Alignment Programme` (line 1599+, re-issued 2026-08-10) — explicitly out of scope
  per the task's own verification note; confirmed untouched.
- The 111-row status tables (per task instructions, not touched/re-verified here — out of scope).

### Why this happened (for the report's "why it matters" framing, not an edit)

`git log -L 881,900:specs/ROADMAP.md` and the blame table above show the file was edited in
large, self-contained passes tied to specific tasks (91, 103, 106, 301, the 2026-07/08 axiom
audits) rather than incrementally kept in sync. The most recent passes (`## Overview`,
`## Paper Alignment Programme`) adopted a **self-superseding "Current state" block** convention
that correctly retires its own prior claims. The older passes (everything from `## Active
Metalogic Paths` onward) predate that convention and were never migrated to it, so they still
read as flat present-tense assertions with no internal signal that they are 3-4 months stale.

## Decisions

- Ground truth for the rewrite of deliverable (a): **1** live structural sorry —
  `countermodel_discrete` in `FormalSystem/Metalogic/WeakCanonical/Transfer.lean`, owned by the
  Base weak-completeness terminus (task 169/421/422 per the Overview's per-class table at line
  27-32), generated-of-record by `scripts/check-module-invariants.sh` check C3.
- Ground truth for the rewrite of deliverable (b): BXCanonical is live, wired, and the entry
  point for the Dense/Dedekind branches of the completeness programme; `Chronicle/` is one of
  its subdirectories, not a rival path. C2's four-theorem axiom baseline is the check of record.
- Recommend the implementation plan correct **all four** verbatim/near-verbatim occurrences of
  the "BXCanonical dead code, ~17 sorries" claim (lines ~19-23, ~296, ~598-599, ~624-630) as one
  coherent edit, not just line 624 — a partial fix leaves the same false claim in the
  Overview section the file tells readers to trust.
- Recommend the "Sorry Inventory" rewrite also fix the "Module Import Graph" (631-711) tree and
  its closing "~5,795 lines... 19 sorries" line, since it duplicates and technically justifies
  the same dead `RootScopedChain.lean` reference the Sorry Inventory table gets its numbers from.
- Recommend `## Legacy Code Inventory` (963-1004)'s four wrongly-archived file rows be corrected
  or flagged in the same pass, since it is a direct, checkable "module status" claim of exactly
  the class deliverable (c) asks to sweep for, and is cheap to fix (four `find` calls confirm
  the state; done in this report).
- Recommend `## Recommended Priority Order` (1683-1740) be the subject of a **separate follow-up
  task** rather than folded into 452's implementation: it contains a third independently-stale
  "sole sorry" narrative (`nf_nvar_exist_all_depths`), an inverted task-176 recommendation, and a
  stale `## Task Cross-Reference` table with task-status implications beyond ROADMAP.md's prose
  (crosses into `specs/state.json` territory for task 109's real status) — larger surface than
  this task's two named deliverables, better scoped on its own.

## Risks & Mitigations

- **Risk**: rewriting the Sorry Inventory table's file:line cells without checking C5 could
  introduce a new unresolved module path if a placeholder like `RootScopedChain.lean` is kept as
  a bare filename inside a code span that C5's regex treats as `FormalSystem.*`-shaped (it
  currently isn't, since C5 only matches dotted `FormalSystem.X.Y` paths, not bare filenames —
  confirmed by today's clean C5 baseline). Mitigation: re-run C5 after editing; keep any
  historical Boneyard reference qualified as `Boneyard/.../RootScopedChain.lean` (full path) or
  prose, not a bare dotted module name.
- **Risk**: scope creep from the deliverable-(c) sweep into `## Recommended Priority Order` and
  `## Task Cross-Reference`, whose fixes bleed into task-status (`state.json`) territory outside
  this task's ROADMAP.md-only, no-archival charter. Mitigation: the Decisions section above
  explicitly recommends spawning a follow-up task for that scope rather than absorbing it here.
- **Risk**: the historically-correct sections (`## Dead Ends (Archived)`, the Overview's own
  superseded "Current state" blocks) look similar in age/wording to the defective sections but
  should NOT be edited — they are already correctly labeled historical. Mitigation: the defect
  catalog table above explicitly marks each row "no edit needed" vs. "needs correction" so the
  planner does not over-correct.

## Context Extension Recommendations

- **Topic**: ROADMAP.md staleness class (prose sections asserting sorry counts / dead-code
  verdicts / module status that `check-module-invariants.sh` can contradict).
- **Gap**: there is no standing convention documented anywhere in `.claude/context/` for how
  ROADMAP.md's narrative sections should be kept in sync with `check-module-invariants.sh`, nor
  a note that the 111-row status tables are roadmap-integration's matching surface while the
  prose sections are not (this task's own description states this fact but it isn't recorded
  anywhere durable).
- **Recommendation**: after this task's implementation lands, consider a short addition to
  `.claude/context/project/lean4/` (or a ROADMAP.md-adjacent README) documenting the
  "self-superseding Current-state block" convention the Overview section already uses
  successfully, so future large-narrative-section rewrites (like the one this task performs)
  follow it from the start rather than drifting stale again over another 3-4 months.

## Appendix

### Commands run

```
bash scripts/check-module-invariants.sh --no-build
lake build   (confirmed already green, 2457 jobs, no rebuild needed)
lake env lean <scratch file with the 4 #print axioms lines from C2>
grep -n "^#\|^##" specs/ROADMAP.md
git blame -L <line>,<line> --date=short specs/ROADMAP.md   (per section header)
find FormalSystem -name 'RootScopedChain.lean'
find FormalSystem/Metalogic/BXCanonical -maxdepth 1 -name '*.lean'
grep -n "BXCanonical" FormalSystem/Metalogic/StrongCompleteness.lean
grep -n "17 sorries\|DEAD CODE\|dead code" specs/ROADMAP.md
grep -n "23 sorry\|Sorry Inventory\|19.*sorr" specs/ROADMAP.md
find FormalSystem -iname 'KampPrior.lean' -exec grep -n sorry {} \;
```

### Files referenced

- `specs/ROADMAP.md` (all line numbers above are current as of `11ad049b8`)
- `FormalSystem/Metalogic.lean`
- `FormalSystem/Metalogic/StrongCompleteness.lean`
- `FormalSystem/Metalogic/WeakCanonical/Transfer.lean`
- `FormalSystem/Metalogic/WeakCanonical/Kamp/KampPrior.lean`
- `scripts/check-module-invariants.sh`
- `scripts/module-invariants-manifest.txt`, `scripts/module-invariants-allowlist.txt`
