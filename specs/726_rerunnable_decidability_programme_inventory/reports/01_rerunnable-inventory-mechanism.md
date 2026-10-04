# Research Report: Task #726

**Task**: 726 - Rerunnable decidability programme inventory
**Started**: 2026-10-04
**Completed**: 2026-10-04
**Effort**: medium
**Dependencies**: None
**Sources/Inputs**: - `docs/theorem-index.md` (Decidability section)
  - `scripts/check-module-invariants.sh` (C2, C14, C36 checks)
  - `scripts/check-evidence-probes.sh` (WIRED, WIRED_REPO, DEFERRED arrays)
  - `FormalSystem/Metalogic/Decidability/Correctness.lean` ("Retired as vacuous" section)
  - `specs/archive/721_decidability_programme_review_l_and_lplus/reports/01_decidability-programme-review.md` (baseline)
  - `specs/ROADMAP.md` (Maintenance section)
  - `specs/TODO.md` entries for tasks 726, 728
**Artifacts**: - this report
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- The three named machine sources mechanically support three of the four statuses directly:
  PROVED (source 1, `docs/theorem-index.md`'s Decidability rows), NOT ESTABLISHED (source 3,
  `Correctness.lean`'s "Retired as vacuous" section), and REFUTED (source 2,
  `check-evidence-probes.sh`'s `WIRED`/`WIRED_REPO` arrays). **WITHDRAWN cannot be freshly
  regenerated from the three sources alone** — the baseline's WITHDRAWN entries draw on module
  headers and READMEs outside all three sources, and one of its four entries
  (`exists_tailStable_repr`) names a declaration that was deleted from the tree entirely, so no
  live-tree scan can rediscover it. WITHDRAWN must be carried forward from the recorded baseline
  and re-verified, not regenerated. See Findings §4.
- I ran the designed pinned-cell cross-check live against the current tree: 45 Decidability rows,
  44 carrying a `pinned:C2`/`pinned:C14` tag plus the one documented `no axioms` exception, **zero
  mismatches**. The "found by hand on three rows in 2026-10-03" defect this task is motivated by
  is already repaired; the mechanism's job is to keep catching this class going forward, not to
  fix a currently-broken state. See Findings §1.
- Doing that cross-check correctly requires reusing a fix the repository already made once and
  documented: a naive `[^']+`-style apostrophe-exclusion regex silently truncates (and therefore
  misses) any Lean identifier with a trailing prime (`not_plusValidZTime_neg_θ'`), because the
  baseline heredoc line itself ends in two apostrophes — the identifier's own and the shell
  quote's. `check-module-invariants.sh`'s own C36 check hit this and fixed it with a greedy `.+`
  capture (lines ~6705-6716); reusing that exact regex is cheaper and safer than re-deriving it in
  a second script. See Findings §2.
- The REFUTED source has already drifted since the recorded baseline: `WIRED` now has 12 entries
  where the baseline's own prose says "eleven `WIRED` plus three `WIRED_REPO`" — one new probe,
  `seam-gluing-ray-product/backward-dual-asymmetric-fixture`, has landed since. This is exactly
  the kind of drift the regeneration mechanism exists to surface as a diff rather than leave to
  archaeology. See Findings §3.
- Task 728 (the phantom-declaration-citation sweep) is itself mid-research this same cycle and
  has not landed any checker yet, so there is no overlap to resolve right now; the two checks
  remain correctly distinct by design regardless (index-row-vs-invariants-baseline here, versus
  backticked-name-vs-definition-site there). See Findings §5.
- `specs/ROADMAP.md`'s Maintenance section already names task 726 as interim owner and already
  points at the correct (now-archived) baseline path — nothing to edit there this phase; the
  hand-off to the mechanism as owner is a plan/implementation-phase edit once the script exists.
- **Recommendation: a standing script under `scripts/`** (e.g.
  `scripts/generate-decidability-inventory.sh`), not a `/review` step. Reasons in Findings §6 and
  Recommendations.

## Context & Scope

This is the **research** dispatch for task 726: designing, not yet building, the regeneration
mechanism. The task names three machine sources and one baseline to diff against, and asks the
research phase to choose an implementation shape and say why. I read all three sources in full,
located and read the archived baseline report, confirmed the current state of the companion task
(728) to rule out duplication, and live-tested the exact cross-check logic the task's HARD
CONSTRAINTS call for (catching a `pinned:C14` cell with no baseline behind it) against the
present tree, rather than only describing it abstractly. No code was written as a deliverable of
this phase; the concrete regexes and line anchors below are what a planner/implementer should
use directly.

## Findings

### 1. Source 1 — `docs/theorem-index.md`'s Decidability section

The section runs from the `### Decidability` heading to the next `### ` heading
(`docs/theorem-index.md:145`–`194`, 45 data rows after the header/separator rows). Every row has
six `|`-delimited cells: `Paper label | Statement | Lean name | File | Frame class | Axioms`. The
file's own header is explicit about what membership in this table means: *"Every declaration
listed here is machine-pinned, with one deliberate exception that is not a gap"* — the one
exception is `PlusSlicedCertificate.FiniteCarrier.θ_eq_ofFormula`, proved by `decide`, whose
Axioms cell reads literally `no axioms (proved by `decide`; absent from the C2 baseline by
construction, ...)` and carries no `pinned:` token at all. Of the other 44 rows, every one carries
either `pinned:C2` or `pinned:C14` in the Axioms cell. This means **table membership itself is the
mechanical proxy for PROVED**: a row is PROVED (compiles, in the Lake build graph) by virtue of
being listed here at all, under this file's own stated charter as "the single per-theorem status
ledger." The generator's job for this source is not to *decide* PROVED-ness but to *verify the pin
claim* each row makes.

Live cross-check (ran against the current tree, not simulated): extracted the Lean name and
`pinned:` tag from all 44 tagged rows, extracted the C2 baseline (`AXIOM_BASELINE`, the heredoc
bounded by `<<'BASELINE'` / `BASELINE` at `scripts/check-module-invariants.sh:1113`–1231`, 50
names — matching the script's own "`all fifty pinned axiom sets match baseline`" message) and the
C14 baseline (`C14_BASELINE`, bounded by `<<'C14BASE'` / `C14BASE` at lines 2057–2260, 202 names),
and checked every tagged row's name against the baseline its tag names. **Result: 0 mismatches.**
This confirms both that the design works and that the specific defect class (a `pinned:C14` claim
with nothing behind it) is currently clean.

### 2. The apostrophe-regex pitfall, already fixed once in this repo

My first pass at the baseline-name extraction used `^'([^']+)' depends on axioms` and produced 2
false-positive "mismatches," both on `FiniteCarrier`-namespace declarations ending in a Lean prime
(`not_plusValidZTime_neg_θ'`, `no_finite_carrier_sat'`). The baseline heredoc line for such a name
is `'FormalSystem...neg_θ'' depends on axioms: ...` — the declaration's own trailing prime
immediately followed by the heredoc's closing quote, i.e. two apostrophes in a row. A
`[^']+`-style class stops at the first one and the whole line fails to match, silently.

This is not a new discovery: `check-module-invariants.sh`'s C36 check hit exactly this and
documents the fix in its own comment (lines ~6705–6716, reproduced here because it is the
precedent a new script must follow rather than rediscover):

> "The captured name is delimited greedily up to the LAST `' depends on axioms` on the line, not
> by a no-apostrophe character class: this tree names declarations with a trailing prime
> (`not_plusValidZTime_neg_θ'`), and a `[^']+` class stops at that prime, so the whole line fails
> to match and a declaration the C2 baseline really does pin is reported as "pinned by neither C2
> nor C14"."

The fix is `re.findall(r"^'(.+)' depends on axioms", block, re.M)` (greedy `.+`, not `[^']+`).
Using this exact pattern made my cross-check's false positives disappear. **A new generator must
reuse this regex verbatim**, not re-derive a parser from scratch.

### 3. Source 2 — `check-evidence-probes.sh`'s `WIRED`/`WIRED_REPO` arrays

`WIRED` (`scripts/check-evidence-probes.sh:173`–186) currently has 12 entries (paths under
`specs/evidence/`); `WIRED_REPO` (lines 224–228) has 3 (full repo-relative paths, each with a
named blocker recorded in the preceding comment, per the file's own convention: "`WIRED_REPO`
exists only so that a probe stranded outside the collection is still guarded rather than left to
rot unwatched"). The script's own header states what every wired probe *is*: "a `sorry`-free Lean
file whose theorems REFUTE something the plan for the decision layer once proposed" — so,
unlike source 1, where the generator must verify a claim, here the file's own charter directly
supports classifying every `WIRED ∪ WIRED_REPO` entry as a REFUTED-category member without further
adjudication.

The baseline report (§1.4) describes the REFUTED set at the time it was written as "eleven `WIRED`
plus three `WIRED_REPO`" (14 total). The live tree now has 12 `WIRED` entries (15 total) — one
more than the baseline recorded. The newest-looking entry, by its position at the end of the
array and the preceding comment's description (a "backward dual," an "asymmetric fixture," and an
explicit "Honest limit" / "follow-up" framing), is
`seam-gluing-ray-product/backward-dual-asymmetric-fixture`. This is a concrete, already-observable
instance of exactly the drift the task exists to catch mechanically: the recorded baseline is
stale by one REFUTED-category entry today, before any new review cycle has even run.

Two caveats for the design:
- Not every `WIRED` entry is a *refutation of a Lean declaration the project once stated*; several
  of the `seam-gluing-ray-product/*` probes (`stab-fibre-is-ray-product`,
  `stab-depth-stratification`, `finite-graph-stab-summary`, `mosaic-germ-amalgamation`,
  `path-quantifier-alternation`) are classified under the baseline's §1.1 **PROVED**, not §1.4
  REFUTED — they establish positive characterization results, read as probes because they live
  outside the Lake build graph, not because their content is a refutation. The generator should
  not try to re-derive this PROVED/REFUTED split from probe content (that would be adjudication);
  it should simply report "wired probe, outside the build graph" as its own status dimension,
  separate from PROVED-in-build-graph/REFUTED-in-build-graph, and let a human reconcile which
  historical bucket (as the baseline did) each probe belongs to when the two disagree. This is a
  genuine limit of what the three sources support, not an oversight to fix.
- The comment table directly above `WIRED=( ... )` (the `# probe ... | the decision it holds in
  place` ASCII table) is multi-line, continuation-indented free text. It is tempting to parse it
  for the REFUTED-category description text, but doing so reliably is a second, fragile parser
  for prose that does not follow the same fixed-grammar discipline as the C2/C14 heredocs. I
  recommend the generator **not** parse this table; it should emit the probe's path (and whether
  it still compiles, which `check-evidence-probes.sh` already tells you by its own exit status)
  and point at the comment table for rationale, rather than re-extract it.

### 4. Source 3 — `Correctness.lean`'s "Retired as vacuous" section, and why it only anchors NOT ESTABLISHED

The section header is `## `validity_decidable` / `validity_has_decision_procedure` — Retired as
vacuous` (`FormalSystem/Metalogic/Decidability/Correctness.lean:192`). It documents, in order:
what the two retired theorem *names* used to claim and why their proofs did not support the name
(excluded middle and a non-constructive existential, dressed up as decidability); what actually
holds now (`decide_sound`, `sound_of_isValid` and the rule-soundness half); and, under the
sub-heading **"What is still owed, and is deliberately not stated here"**, the exact open
obligation: `⊨ φ → isValid φ fc = true` (tableau completeness), hence the biconditional and the
four frame-class `Decidable` instances, pending `valid_iff_allClosed`. This paragraph is the
single NOT ESTABLISHED anchor the dispatch names source 3 for, and it is exactly what the baseline
report's §1.2 records as its first (and primary) NOT ESTABLISHED row.

**This section is not, by itself, the WITHDRAWN anchor**, despite its own heading using the word
"Retired." The dispatch text is precise about this: it names source 3 only as "the NOT ESTABLISHED
anchor." Checking the baseline's §1.3 WITHDRAWN table against the three named sources confirms
why a broader claim would be wrong:

| Baseline WITHDRAWN entry | Where it actually lives |
|---|---|
| `not_exists_plusCertifies_pumpTarget` (pumpTarget compression failure) | `docs/theorem-index.md` (source 1, `pinned:C2`) + `PlusWitnessFamily/Compression/README.md` header |
| `not_exists_hopFree_plusCertifies_hopTarget` (hop-free strategy) | `docs/theorem-index.md` (source 1, `pinned:C2`) |
| `exists_tailStable_repr` | **No declaration of this name exists anywhere in the tree.** Only prose references survive, in `PlusSlicedCertificate.lean:149`, `PlusSlicedCertificate/Fixture.lean:788,796`, and `PlusSlicedCertificate/README.md:87,133` — none of which is `Correctness.lean` |
| The five retired `share`-congruence declarations | `PlusWitnessFamily/Incompleteness.lean` header (a different file's own "retired" framing, not `Correctness.lean`'s) |

I confirmed all four rows against the live tree: the first two are still present and still
`pinned:C2` in `docs/theorem-index.md` today (so a fresh, source-1-only read would classify them
PROVED, not WITHDRAWN); `exists_tailStable_repr` is genuinely absent from every `.lean` file (only
the three prose-reference files above mention it); the five-declaration quintet's retirement is
recorded in a fourth file, not `Correctness.lean`.

**Conclusion: WITHDRAWN cannot be freshly regenerated from the three named sources.** It requires
either (a) narrative/historical framing scattered across module headers and READMEs the dispatch
does not name as a source, or (b) in `exists_tailStable_repr`'s case, knowledge of a declaration
that no longer exists to be found by any live-tree scan at all. The only sound mechanical design
is to **carry WITHDRAWN forward from the recorded baseline** (§1.3 of the archived 721 report) as
a fixed, baseline-sourced list, and have the generator do presence/pin *verification* against it
(flagging if a previously-withdrawn name has reappeared, lost its pin, or — for names still live
— drifted from its baseline-recorded tier), rather than trying to produce WITHDRAWN rows from
scratch. This is consistent with the HARD CONSTRAINTS ("must not assert any status the three
sources do not support") and with the ACCEPTANCE criterion's own separate requirement to diff
against the baseline — the diff step is not just a sanity check here, it is the *only* mechanism
by which WITHDRAWN persists across runs at all.

### 5. Task 728 status — no duplication risk yet

`specs/TODO.md:52` and `:172` show task 728 ("Sweep phantom declaration citations") is currently
`[RESEARCHING]` — the same lifecycle stage as this task, in the same orchestration cycle (it is
listed as a concurrent sibling in this dispatch's Territory block). It has not landed any checker.
There is nothing to reuse yet, and nothing this task has built duplicates it: 728's checker
targets backticked names in task descriptions and `docs/` against `FormalSystem/` definition
sites; this task's pinned-cell cross-check targets `docs/theorem-index.md` rows against
`check-module-invariants.sh`'s C2/C14 *baselines* specifically. Different inputs, different
targets, as the dispatch itself states. No action needed beyond noting this for the planner, in
case 728 lands first and a later dispatch should re-confirm no drift occurred.

### 6. Implementation shape — standing script, with a direct precedent already in the tree

`check-module-invariants.sh`'s **C36** check (lines ~6630–6770) is close kin to what this task
needs: it reads its *own* source text to extract the C2/C14 baselines (the exact heredoc-anchor
regex discussed in §2), cross-references a hand-maintained inventory file
(`scripts/certificate-witness-inventory.txt`) against the built library, and reports pinned/
unpinned, stale, and malformed rows — all inside a single Python block invoked from the bash
script via a here-string. This is a directly reusable pattern, not just a parsing-regex precedent:
a new script can use the identical "`bash` driver, inline `python3` payload, read my own
companion scripts' heredocs by path" shape.

Weighing the two options the dispatch names:

- **A `/review` step.** `/review`'s existing Step 2.5 (`roadmap-integration.sh`) is the closest
  existing precedent, and both files live in the **core** extension's source store
  (`/home/benjamin/.config/nvim/agent-system/extensions/core/`, confirmed via
  `.claude-extensions.json`'s `source_dir`). This dispatch's own deploy-freshness-context flags
  `core` (along with `filetypes formal lean typst`) as **currently stale** in the deployed
  `.claude/` tree relative to that source store — meaning any edit under `.claude/commands/
  review.md` right now would be silently discarded on the next regeneration, and even a correct
  source-store edit would not take effect in this repo's deployed tree until a redeploy. A
  `/review` step also only runs when `/review` is invoked, and inherits all of `/review`'s own
  state-management and task-creation machinery for a job that is really "run a script and read
  its stdout."
- **A standing script under `scripts/`.** Runs with zero agent-system dependency, from a fresh
  clone, with no deploy/stale-tree risk at all; sits next to and follows the exact convention of
  the three sources it reads (`check-module-invariants.sh`, `check-evidence-probes.sh`); is
  trivially the thing `/review` (or anything else) could shell out to later, without the reverse
  being true; and matches the task's own framing — "a runnable mechanism," "the next review is a
  diff" — most literally: `bash scripts/generate-decidability-inventory.sh [--diff]` is runnable
  today, by a human or an agent, independent of which extensions are loaded or how stale the
  deployed `.claude/` tree is.

**Recommendation: a standing script**, e.g. `scripts/generate-decidability-inventory.sh`. If a
`/review` integration is wanted later, it is a thin, optional second step that shells out to this
script — not a reason to make the script itself live in the source store.

### 7. `specs/ROADMAP.md` Maintenance section — already correct for this phase

`specs/ROADMAP.md:342`-350 already reads: *"Nobody owns the periodic re-run of the decidability
inventory until task 726 lands; its baseline is section 1 of
`specs/archive/721_decidability_programme_review_l_and_lplus/reports/01_decidability-programme-review.md`
(moved into the archive when that task was archived)."* This already names task 726 as interim
owner and already points at the correct, current (archived) baseline path — both exactly what the
dispatch's "ALSO" instruction asks for at this stage. No edit is needed in the research phase; the
remaining half of that instruction — naming *the mechanism* as owner once it exists — is a
plan/implementation-phase edit (replace "task 726" with the script's path once it is landed and
tested).

## Decisions

- Treat `docs/theorem-index.md` Decidability-row membership as the mechanical proxy for PROVED;
  the generator's job on source 1 is pin-claim verification, not status adjudication.
- WITHDRAWN is carried forward from the recorded baseline (§1.3 of the archived 721 report) and
  re-verified for continued presence/absence and pin status; it is never freshly derived from the
  three named sources, because at least one baseline entry (`exists_tailStable_repr`) names a
  declaration no live-tree scan can find, and the rest are sourced from module headers outside all
  three named sources.
- Reuse `check-module-invariants.sh`'s own C2/C14 heredoc-extraction regex
  (`re.findall(r"^'(.+)' depends on axioms", block, re.M)`) verbatim, including its greedy-`.+`
  fix for trailing-prime Lean identifiers, rather than re-deriving a parser.
- Do not parse the free-text comment table above `WIRED=( ... )` in `check-evidence-probes.sh`;
  emit probe paths and point at that table for rationale instead of re-extracting its prose
  mechanically.
- Confirmed no overlap with task 728 (phantom-citation sweep): it has not landed a checker this
  cycle, and the two checks target different things by the dispatch's own design.
- Recommend the standing-script implementation shape over a `/review` step, primarily because the
  `core` extension's source store is currently stale relative to the deployed tree (so a
  `/review`-step edit would need a redeploy to take effect here) and because a dependency-free
  script matches "runnable mechanism" and "the next review is a diff" more literally.
- No edit to `specs/ROADMAP.md`'s Maintenance section this phase: it already correctly names task
  726 as interim owner and already points at the current baseline path.

## Recommendations

1. **Location and shape**: `scripts/generate-decidability-inventory.sh`, a bash driver with an
   inline `python3` payload (the C36 pattern), parallel in structure to
   `check-module-invariants.sh` and `check-evidence-probes.sh`, not wired into
   `.github/workflows/ci.yml` as a blocking gate (see point 6).
2. **Source 1 parsing**: locate `### Decidability` and the next `### ` heading in
   `docs/theorem-index.md`; parse `|`-delimited rows, skipping the header/separator rows; extract
   column 3 (Lean name, strip backticks) and column 6 (Axioms cell); extract a `pinned:(C\d+)` tag
   via regex; treat the single literal `no axioms (proved by `decide`...)` cell as a documented,
   non-defect exception (pass it through unchanged), not an UNKNOWN.
3. **Baseline extraction**: read `scripts/check-module-invariants.sh`'s own text; extract the
   `<<'BASELINE' ... BASELINE` heredoc (C2) and the `<<'C14BASE' ... C14BASE` heredoc (C14) with
   `re.search(r"<<'TAG'\n(.*?)\nTAG\n", text, re.S)`; extract names from each with the greedy
   `re.findall(r"^'(.+)' depends on axioms", block, re.M)` pattern — never a `[^']+` class (see
   Findings §2 for why, and cite C36's own comment as the precedent).
4. **Pin cross-check**: for every tagged Decidability row, verify its Lean name is a member of the
   baseline set its tag names (C2 or C14); this is the one mechanical defect class the HARD
   CONSTRAINTS license the generator to *fail* on (a `pinned:CN` claim with nothing behind it in
   baseline `CN`) — everything else in this design is additive/informational, never a hard
   failure, because every other judgment call documented above (REFUTED-vs-PROVED split among
   wired probes, WITHDRAWN classification) needs a human, not a script.
5. **Source 2 (REFUTED) generation**: list `WIRED` and `WIRED_REPO` array contents verbatim
   (simple bash-array extraction, e.g. `grep -A N` between the `WIRED=(`/`WIRED_REPO=(` and the
   matching `)`, or a small sed/awk block); report each probe's path and, optionally, whether
   `check-evidence-probes.sh` currently reports it PASS/FAIL (shell out to it, or re-run its
   `check_probe` logic) — do not attempt to parse the preceding comment table for rationale text.
6. **Source 3 (NOT ESTABLISHED) generation**: locate the literal heading
   `` ## `validity_decidable` / `validity_has_decision_procedure` — Retired as vacuous `` in
   `FormalSystem/Metalogic/Decidability/Correctness.lean`; capture the paragraph following
   `**What is still owed, and is deliberately not stated here.**` up to the closing `-/`; if the
   heading text is not found verbatim, emit UNKNOWN for this category rather than guessing at a
   substitute anchor (mirrors C36's own "anti-silence guard" pattern of failing loudly when an
   expected anchor is missing, rather than silently reporting zero findings).
7. **WITHDRAWN carry-forward**: hardcode (or parse once, read-only) the four baseline §1.3 entries
   from the archived 721 report as a fixed list; for each, mechanically check current-tree
   presence (grep across `FormalSystem/` and `docs/theorem-index.md`) and pin status where
   applicable; report drift (reappeared, newly unpinned, or — expected — still confirmed absent)
   rather than re-deriving the category.
8. **Diff mode**: accept `--baseline PATH` (default: the path `specs/ROADMAP.md`'s Maintenance
   section currently names, i.e.
   `specs/archive/721_decidability_programme_review_l_and_lplus/reports/01_decidability-programme-review.md`)
   and report added/removed PROVED rows, added/removed REFUTED probes (I already found one real
   instance of this: `seam-gluing-ray-product/backward-dual-asymmetric-fixture`), and any
   WITHDRAWN-entry drift, in addition to the pin-mismatch check from point 4.
9. **Exit status discipline**: exit non-zero only on a pin-cross-check failure (point 4) or a
   missing-anchor condition (point 6's anti-silence guard, point 2's missing `### Decidability`
   heading); all diff output (new/removed rows, REFUTED-array growth) is informational and exits
   0, mirroring the distinction between a HARD STOP check (C2/C14 themselves) and an informational
   report.
10. **ROADMAP.md follow-up** (plan/implement phase, not this report): once the script is landed
    and tested, edit the Maintenance section to replace "until task 726 lands" / "task 726" with
    the script's path as periodic-re-run owner.

## Risks & Mitigations

- **Risk**: the `WIRED`/`WIRED_REPO` comment table is free-form, continuation-indented prose with
  no fixed grammar; a parser against it would be brittle and would itself need maintenance.
  **Mitigation**: do not parse it (Recommendation 5); report paths and point at the table.
- **Risk**: `docs/theorem-index.md`'s `### Decidability` heading text, or the heredoc tag names in
  `check-module-invariants.sh`, could be renamed in a future edit, silently producing zero rows.
  **Mitigation**: fail loudly (non-zero exit, explicit message) when an expected anchor is not
  found verbatim, following C36's own "anti-silence guard" precedent, rather than silently
  reporting an empty inventory.
- **Risk**: Unicode handling (`θ`, `Φ`, combining vs. precomposed forms) across files edited at
  different times could cause spurious cross-check mismatches. **Mitigation**: read every source
  as UTF-8 text and compare raw Python strings with no normalization step — this is what I did in
  the live test in Findings §1, and it produced zero false positives once the regex itself (§2)
  was corrected.
- **Risk**: treating every `WIRED` probe as REFUTED (per the script's own header framing) risks
  contradicting the baseline's own more careful PROVED/REFUTED split among the
  `seam-gluing-ray-product/*` probes. **Mitigation**: report "wired probe, outside build graph" as
  a distinct, source-2-only status dimension rather than claiming REFUTED for probes the baseline
  classified PROVED; surface the disagreement for a human to reconcile rather than silently
  picking a side.

## Context Extension Recommendations

- **Topic**: the decidability-inventory regeneration mechanism and its carry-forward-WITHDRAWN
  design.
  **Gap**: no existing context file under `.claude/context/project/lean4/` documents this pattern
  (heredoc self-parsing for baseline cross-checks, the carry-forward status category) as a
  reusable technique for future similar inventories.
  **Recommendation**: once the script lands and is stable, add a short pointer (not a full guide)
  from `domain/decidability-provenance.md` (already referenced in `.claude-extensions.json`'s
  `lean` extension file list) to the new script, so a future reviewer finds it without
  re-deriving this research.

## Appendix

### Search queries / commands used

```
grep -n "Decidability" docs/theorem-index.md
grep -n "C14BASE\|C2BASE\|C2_BASELINE" scripts/check-module-invariants.sh
grep -n "pass C2 \|fail C2 \|flagship" scripts/check-module-invariants.sh
sed -n '1060,1245p' scripts/check-module-invariants.sh      # C2 baseline + check body
sed -n '2057,2500p' scripts/check-module-invariants.sh      # C14 baseline + check body
sed -n '6690,6780p' scripts/check-module-invariants.sh      # C36, the regex-pitfall precedent
sed -n '173,228p' scripts/check-evidence-probes.sh          # WIRED / WIRED_REPO arrays
grep -n "Retired as vacuous" FormalSystem/Metalogic/Decidability/Correctness.lean
grep -n "726\|728" specs/TODO.md
grep -n "Maintenance" specs/ROADMAP.md
jq -r '.extensions.core.source_dir, .extensions.core.installed_files[]' .claude-extensions.json
```

### Live cross-check script (ad hoc, not committed — for the planner's reference)

A Python snippet was run directly against the tree to validate the design in Findings §1–2: it
extracted the 45 Decidability rows, extracted the C2/C14 baselines via the greedy-`.+` regex, and
confirmed 0 pin mismatches with that regex (versus 2 false positives with a naive `[^']+`
regex). This snippet is reproducible from the exact regexes and line anchors given in
Recommendations 2–4 above; it was not saved as a repository file since this is a research, not
implementation, dispatch.

### B. Task records read (read-only)

- `specs/TODO.md` entries for tasks 726 (`:83`, `:208`–226) and 728 (`:52`, `:172`–204)
- `specs/ROADMAP.md:342`–350 (Maintenance section)
- `specs/archive/721_decidability_programme_review_l_and_lplus/reports/01_decidability-programme-review.md`
  (full file read; §1 used as the baseline this task diffs against)
