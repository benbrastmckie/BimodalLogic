# Implementation Plan: Task #456

- **Task**: 456 - Replace paper-citation footnotes with `#leansrc` Lean references
- **Status**: [IMPLEMENTING]
- **Effort**: 7 hours
- **Dependencies**: None (sibling tasks 446, 447, 452, 453 touch the same file but own disjoint territory)
- **Research Inputs**: `specs/456_leansrc_references_replace_paper_citations/reports/01_leansrc-references.md`
- **Artifacts**: plans/01_leansrc-conversion.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: typst
- **Lean Intent**: false

## Overview

`typst/FormalFoundations.typ` carries a 41-site block-trailing footnote apparatus whose only job
is to point back at anchors in an external paper. This plan removes that apparatus, replaces it
where a machine-checked counterpart exists with a standalone `#leansrc(module, name)` block, and
leaves the paper cited exactly once — in the abstract block on the first page. The work is
decomposed into a read-only Lean-binding verification pass, three edit passes matching the
research report's three footnote classes, a citation-relocation pass, and a final gate phase that
also performs the one and only git staging operation.

The file has substantial uncommitted working-tree changes belonging to sibling tasks. Every
decision below about locating edit sites, snapshotting sibling territory, and staging is driven by
that fact.

### Research Integration

The research report supplies four things this plan consumes directly and does not re-derive:

1. **`leansrc` binding resolution** — `template.typ`'s block form (line 27 import) shadows
   `shared-notation.typ`'s inline form (line 26 wildcard import), verified by compile +
   `pdftotext`. Consequence for the implementer: **do not delete or reorder the line-27
   `#import "template.typ"` line**, and expect `#leansrc` to render as a standalone
   `> Module.name.` raw block.
2. **The 41-site inventory**, classified 16 PURE BOOKKEEPING / 18 SUBSTANTIVE / 7 LEAN-PATH, each
   locatable by its block title string. Phases 4, 5, and 6 execute one class each.
3. **The document-item → `FormalSystem/` declaration mapping** with `[confirmed]` /
   `[plausible]` / `[needs verification]` / `[none]` confidence tags. Phase 2 promotes every
   non-`[confirmed]` entry to confirmed-or-dropped before any block is written.
4. **Placement rules** — `#leansrc` is a standalone block immediately after the item it
   documents; multiple declarations become stacked calls; a surviving trimmed footnote goes
   *after* the block; never attach a block to a `#proof[...]` or a `#remark[...]`.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

`specs/ROADMAP.md` exists but was not passed as `roadmap_path` and no roadmap flag was set for
this dispatch. No roadmap phases are included and ROADMAP.md is not read or written by this plan.

## Decisions Encoded (do not re-open during implementation)

These are settled. The implementer executes them; it does not re-litigate them.

- **D1 — The single surviving paper citation goes in the abstract block**
  (`#abstract-block[...]`, located by the literal `*Abstract.* This report states what is proved`),
  not in the `#definition("Language")` footnote. The research leaned the other way and left the
  call to the planner; this plan overrides it. Rationale: the complaint being fixed is that
  citations live in dangling footnotes, so the one survivor must not be a footnote. The paper's
  URL (`https://benbrastmckie.com/publications/possible_worlds.pdf`) travels with it.
- **D2 — Items with no Lean counterpart get no `#leansrc` block, and that absence is a recorded
  decision, not an oversight.** Per the research these are: Temporal Order (a typeclass
  assumption bundle, no named structure); S5 and BX as single declarations (scattered `Axiom`
  constructors — 17+ stacked calls would be worse than none); and the entire *Strongest Objective
  Modality* subsection (Strongest Objective Normal Modal Operator, Existence, Uniqueness and
  logic, Orthogonality — higher-order philosophical scaffolding with nothing formalized against
  it); plus Irregular World and The price of irregular worlds. A later reader finding these five
  document items blockless should read this bullet, not file a bug.
- **D3 — No `#leansrc` pair is written before it is verified to resolve.** Phase 2 re-derives every
  module string directly from the target file's `namespace FormalSystem....` line and confirms the
  declaration name at its definition site. A pair that cannot be confirmed produces no block; it
  is recorded as dropped, with the reason, in the Phase 2 binding table.
- **D4 — Uniform anchor-removal rule.** In every in-scope footnote, backticked paper-anchor keys
  matching `` `def:…` ``, `` `thm:…` ``, `` `lem:…` ``, `` `cor:…` ``, `` `app:…` ``,
  `` `sub:…` ``, and the bare `Pthm:NN` form are removed along with the citation, and the
  surrounding sentence is minimally rewritten so it still reads. This settles the two open calls
  the research flagged: the `Pthm:13, Pthm:14, Pthm:18, Pthm:20` prefix on `#proposition("Collapse")`
  **is** stripped, and the "re-verified verbatim against the live paper on 2026-08-13" provenance
  clause on `#definition("Irregular World")` **is** dropped (keep the cosets-not-subgroups
  substance). This rule does **not** reach into the out-of-scope mid-paragraph footnotes, which
  use anchors as informal in-prose cross-references (e.g. `` (`cor:spherical-finite`) `` at the
  Spherical footnote) and carry no paper citation.
- **D5 — Citations that are not `@brastmckie2026possibleworlds` survive untouched.**
  Specifically `@scott1970advice` in the Truth footnote, and `@doets1987` /
  `@reynolds1992` / `@gabbayhodkinsonreynolds1994` in the Reynolds-pipeline footnote. These are
  live external references, not part of the bookkeeping being removed.
- **D6 — One structural exception to "out of scope: the 9 mid-paragraph footnotes."** See
  "Constraint Conflict C1" below. The mid-paragraph footnote on the sentence ending
  `lacking one.` (opening `` `thm:BLplus-PastFuture`, `thm:BLplus-NextPrevious`.
  @brastmckie2026possibleworlds ``) receives SUBSTANTIVE treatment in Phase 5. The other **8**
  mid-paragraph footnotes are untouched.

## Constraint Conflict C1 — resolved, flagged for the user

Two stated constraints cannot both hold literally. Recording this rather than silently choosing.

**Measured facts** (counted on the working tree at plan time):

- `grep -c brastmckie2026possibleworlds typst/FormalFoundations.typ` → **36**, one occurrence per
  line, 36 lines.
- **34** of those are block-trailing (the in-scope apparatus).
- **1** is the mid-paragraph footnote on `lacking one.` — a live, rendering footnote.
- **1** is inside the commented-out `lem:step` block, which is sibling territory and must stay
  byte-identical.

So: with the commented block frozen and the mid-paragraph footnote untouched, the floor for
`grep -c` after this task is **3** (frozen comment + mid-paragraph + the new abstract citation) —
not the stated **1**.

**Resolution.** The citation gate is the load-bearing requirement; "don't touch the mid-paragraph
footnotes" was a research-derived classification, and the `lacking one.` footnote is structurally
a §2b SUBSTANTIVE site that merely happens to attach mid-paragraph — it opens with the identical
`` anchor. @citation `` bookkeeping prefix. It is therefore brought in scope (D6). The commented
block stays frozen because that constraint was stated with specific emphasis and overrides.

**The gate is restated as two mechanical checks that are both satisfiable and faithful:**

```bash
# G2a: exactly one LIVE (uncommented) citation, and it is the abstract's
grep -vE '^[[:space:]]*//' typst/FormalFoundations.typ \
  | grep -c 'brastmckie2026possibleworlds'          # MUST be 1

# G2b: exactly two total, the second being the frozen commented-out one
grep -c 'brastmckie2026possibleworlds' typst/FormalFoundations.typ   # MUST be 2
grep -n 'brastmckie2026possibleworlds' typst/FormalFoundations.typ \
  | grep -c '^[0-9]*:[[:space:]]*//'                # MUST be 1
```

If the user prefers the literal `grep -c … == 1`, the only way to reach it is to also strip the
commented block's citation — which contradicts the byte-identical constraint. Raise it, do not
decide it unilaterally at implementation time.

## Goals & Non-Goals

**Goals**:
- Remove all 34 block-trailing `@brastmckie2026possibleworlds` citations and the 16
  pure-bookkeeping footnotes that carry nothing else.
- Preserve, verbatim minus the stripped bookkeeping prefix, the commentary in the 18 substantive
  footnotes and the 7 Lean-path footnotes.
- Add a verified `#leansrc(module, name)` block after every document item with a confirmed
  `FormalSystem/` counterpart, following the existing placement convention.
- Leave the paper cited exactly once, live, in the abstract block, with its URL.
- Leave sibling territory (12 `// FIX:` tags, the commented-out `lem:step` block, 8 mid-paragraph
  footnotes) provably untouched.

**Non-Goals**:
- Rewriting, expanding, or reformatting any prose beyond the minimal sentence repair D4 requires.
- Resolving any `// FIX:` tag. Those belong to tasks 446 and 447.
- Adding `#leansrc` blocks to `#proof[...]` or `#remark[...]` blocks.
- Adding `#leansrc` for declarations Phase 2 cannot confirm (D3).
- Committing or staging any sibling working-tree content (see the staging contract below).

## Territory and Staging Contract

### Locate by content, never by line number

Every edit site in this plan is identified by a **quoted anchor string** (a block title, a
distinctive opening clause, or a verbatim footnote fragment). Line numbers appearing anywhere in
this plan or in the research report are plan-time observations only and **will** be stale by the
time the implementer reaches a site: this task's own edits shift them, and tasks 446/447/452/453
will shift them again afterwards. Never `sed -n 'Np'` your way to a site. Grep for the anchor
string, confirm exactly one match, then edit.

### Why no blanket `git add`

`typst/FormalFoundations.typ` carries ~86 insertions / 75 deletions of uncommitted sibling work
relative to HEAD. The working tree is authoritative — nothing in this plan may discard it.
Therefore **no `git checkout`, no `git restore`, no `git stash`, and no
`git add typst/FormalFoundations.typ`**: a blanket stage would sweep the siblings' unrelated
content into this task's commits.

Instead, this task's hunks are staged as a **minimal cached patch** — the same mechanism the prior
task in this batch used — which writes only to the index and never to the working tree:

```bash
BASE=specs/456_leansrc_references_replace_paper_citations/baselines
git diff --no-index --unified=3 "$BASE/FormalFoundations.pre-456.typ" typst/FormalFoundations.typ \
  | sed -e '1,2s|^--- .*|--- a/typst/FormalFoundations.typ|' \
        -e '1,4s|^+++ .*|+++ b/typst/FormalFoundations.typ|' \
  > "$BASE/456-only.patch"

git apply --cached --3way --check "$BASE/456-only.patch"   # gate: must pass before applying
git apply --cached --3way          "$BASE/456-only.patch"
git diff --cached -- typst/FormalFoundations.typ           # REVIEW: must contain ONLY 456 hunks
```

`--check` failing means this task's hunks overlap a region the siblings also modified. **Do not
force it.** Fall back: commit the `specs/**` artifacts only, leave `typst/FormalFoundations.typ`
entirely unstaged, and say so plainly in the summary — the working tree keeps the finished work
and the user resolves the overlap. Losing a commit is recoverable; clobbering sibling work is not.

Per-phase commits stage `specs/**` artifacts only. The typst file is staged exactly once, in
Phase 7, from the single Phase 1 baseline. Rationale: an incremental per-phase cached patch would
be built against a moving index baseline and is not reproducibly reviewable.

### Mechanical sibling-territory protection

Phase 1 captures a full pre-edit copy of the file into
`specs/456_.../baselines/FormalFoundations.pre-456.typ` (committed as a task artifact, so it
survives across separate `/implement` dispatches — a scratchpad copy does not). Phase 7 then runs
two checks:

1. **Content invariant (must be an empty diff).** `grep -n -B2 -A2 -- '// FIX:'` with the
   line-number prefix stripped, diffed before against after. An empty diff proves all 12 tags and
   their immediate context survived byte-identical, in the same order, with none added or lost.
   `grep -c -- '// FIX:'` must also still be 12.
2. **Position invariant (must be an empty intersection).** Parse the `@@ -a,b +c,d @@` hunk headers
   of `diff -u baselines/FormalFoundations.pre-456.typ typst/FormalFoundations.typ` and assert no
   hunk's old-side range contains any baseline `// FIX:` line number, nor any line of the
   commented-out `lem:step` block. This proves no protected line was edited *in place*, which is
   what "position survived" actually means here.

**Why the raw line-numbered snapshot cannot be diffed directly.** 22 of the in-scope edit sites
sit above the last `// FIX:` tag, so every tag's absolute line number necessarily shifts. A raw
`grep -n` diff would fail on shifted numbers alone and prove nothing about whether the tags were
edited. Checks (1) and (2) together are strictly stronger than the naive comparison: (1) proves
content and ordering, (2) proves no in-place modification. This is a refinement of the requested
check, not a relaxation of it — recorded here so a later reader does not mistake it for one.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Cached patch fails `--check` because 456 hunks overlap sibling-modified regions | M | M | Documented fallback: leave typst unstaged, commit specs only, report to user. Never `--force`, never `git add` the file. |
| An edit lands inside the commented-out `lem:step` block (it contains a footnote matching several search patterns) | H | M | Every Phase 4/5/6 search must be run with `grep -n` and the match inspected for a leading `//` before editing. Phase 7 position invariant catches it if it slips through. |
| A `#leansrc` pair is written that does not resolve | M | M | D3: Phase 2 gates every pair; Phase 7 re-verifies every pair in the finished file independently of the Phase 2 table. |
| A block title string matches more than one site (e.g. two `#theorem("Decidability")`-like blocks) | M | M | Each edit requires confirming the grep returns exactly one match before editing; if 2+, disambiguate with a second anchor from the footnote body. |
| Stripping the bookkeeping prefix leaves an ungrammatical sentence fragment | L | H | D4 mandates minimal sentence repair; Phase 7 reads the rendered PDF text (`pdftotext`) for the edited footnotes. |
| A new typst warning hides behind the two known thmbox warnings | M | L | Phase 1 captures the exact baseline (exit 0, exactly 2 warnings, both `unknown font family: new computer modern sans` at `thmbox.typ:148` and `:169`); Phase 7 compares warning count and text, not just exit code. |
| Sibling task edits the file concurrently mid-implementation | M | L | Phase 7 re-runs the full gate set immediately before staging; if the baseline diff shows unexplained hunks, stop and report. |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4 | 2, 3 |
| 4 | 5 | 4 |
| 5 | 6 | 5 |
| 6 | 7 | 6 |

Phases within the same wave can execute in parallel. Wave 2's two phases have disjoint territory
(Phase 2 is read-only over `FormalSystem/`; Phase 3 edits only the abstract block and the Language
footnote). Serial execution of wave 2 is equally acceptable and slightly safer.

Phases 4 → 5 → 6 are serialized deliberately: they all edit the same file, and serializing them
keeps the incremental snapshot chain (`baselines/step-N.typ`) linear and reviewable.

---

### Phase 1: Baseline capture and territory snapshot [COMPLETED]

**Goal**: Establish every "before" artifact the later phases and the final gates compare against.
No edit to `typst/FormalFoundations.typ` in this phase.

**Tasks**:
- [ ] `mkdir -p specs/456_leansrc_references_replace_paper_citations/baselines`
- [ ] Copy the file: `cp typst/FormalFoundations.typ specs/456_.../baselines/FormalFoundations.pre-456.typ`
- [ ] Confirm the index is clean for this file: `git diff --cached --stat -- typst/FormalFoundations.typ` is empty (index == HEAD). Record the sibling delta for the record:
      `git diff --stat -- typst/FormalFoundations.typ`
- [ ] Capture the compile baseline into `baselines/compile-baseline.log`:
      `typst compile typst/FormalFoundations.typ /tmp/ff-baseline.pdf 2>&1`
      Confirm exit 0, exactly 2 lines matching `^warning:`, both `unknown font family: new computer modern sans`, at `thmbox.typ:148:26` and `thmbox.typ:169:26`.
- [ ] Capture the FIX-tag content snapshot into `baselines/fix-context.before.txt`:
      `grep -n -B2 -A2 -- '// FIX:' typst/FormalFoundations.typ | sed 's/^[0-9]*[-:]//'`
- [ ] Capture the FIX-tag line numbers into `baselines/fix-lines.before.txt`:
      `grep -n -- '// FIX:' typst/FormalFoundations.typ` — confirm 12 entries.
- [ ] Capture the commented-out `lem:step` block into `baselines/commented-lemstep.before.txt`: the contiguous run of `^//`-prefixed lines containing the string `` `lem:step` ``, extracted by content (walk outward from the match to the first non-`//` line in each direction), stored without line numbers.
- [ ] Capture the citation census into `baselines/citations.before.txt`:
      `grep -n 'brastmckie2026possibleworlds' typst/FormalFoundations.typ` — confirm 36 entries, of which exactly 1 is comment-prefixed.
- [ ] Capture the existing `#leansrc` call list into `baselines/leansrc.before.txt` — confirm 6 calls (the research's "7 existing sites" counts the three completeness theorems' shared pattern; the literal grep returns 6 lines).

**Timing**: 0.5 hours

**Depends on**: none

**Verification Tier**: prose

**Scope Hypothesis**: This phase asserts 12 `// FIX:` tags, 36 citation occurrences (1
commented), 6 existing `#leansrc` calls, and exactly 2 compile warnings. All four are counted
mechanically by this phase's own commands. Any count that comes out different means the working
tree moved since plan time — **stop, report the delta, and do not proceed to Phase 2**; the
per-site inventory in Phases 4-6 would be built on a stale map.

**Files to modify**:
- `specs/456_.../baselines/*` — new baseline artifacts (created, not modified)
- `typst/FormalFoundations.typ` — **read only, not modified**

**Verification**:
- All eight baseline files exist and are non-empty.
- The four asserted counts match: 12 / 36 (1 commented) / 6 / 2.
- `git status --short -- typst/FormalFoundations.typ` still shows ` M` (unstaged), never `M ` or `MM`.

---

### Phase 2: Verify every `#leansrc` binding against `FormalSystem/` [NOT STARTED]

**Goal**: Turn the research report's mixed-confidence mapping into a binary
confirmed/dropped table. Read-only over `FormalSystem/`. Produces the single input Phases 4-6
consult before writing any block.

**Tasks**:
- [ ] For every proposed pair, re-derive the module string **from the target file's own
      `namespace FormalSystem....` line**, not from the research report's guess: strip the leading
      `FormalSystem.`, and account for nested `namespace` blocks reopened inside the file. Confirm
      the declaration name at its `def`/`theorem`/`structure`/`lemma`/`inductive` site.
- [ ] Carry the 20 `[confirmed]` pairs through with a spot re-check (they are already grep-verified;
      re-confirm 3 at random rather than all 20).
- [ ] Resolve every `[plausible]` / `[needs verification]` entry:
      - `spherical_of_finite` — top-level `Semantics` namespace or nested in `TaskFrame`?
      - `DenseTemporalFrame` / `DiscreteTemporalFrame` / `DedekindTemporalFrame` — confirm the
        *structures* exist in `FrameConditions/FrameClass.lean`, not just the `.mk'` lemmas.
        Search separately for a "Deterministic" counterpart; if absent, record `[none]`.
      - `FrameClass` — confirm the enclosing namespace at its declaration (could be
        `ProofSystem.Axioms` or bare `ProofSystem`).
      - Soundness — determine whether `soundness_over` is a genuine umbrella covering all five
        systems. If yes, one call; if no, stack `soundness_linear`, `soundness_dense`,
        `soundness_discrete`, `soundness_Int`.
      - Correspondence (DF/DN/CO ↔ Discrete/Dense/Complete) — open the candidates in
        `Metalogic/SoundnessLemmas/{DenseValidity,FrameClassVariants,CoValidity}.lean` and
        `FrameConditions/{Validity,Compatibility}.lean`. If nothing states the biconditional,
        record `[none]`.
      - Perpetuity/Collapse — **verify each of the four biconditionals against the Lean theorem's
        actual statement, not its name.** `perpetuity_2` / `perpetuity3` / `perpetuity4` /
        `modal5` form a numbered family that may not align 1:1 with the paper's
        sometimes-box / always-box / box-always-box / diamond-sometimes ordering. Any pair that
        cannot be content-matched is dropped.
      - `singletonChronicle` / `omegaChain` — confirm the namespace in
        `Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean` directly.
      - Reynolds pipeline — confirm namespaces for `one_class`, `VeryGood`, `good`,
        `limitdom_is_good`, `truth_transfer` in their four files.
      - Real-model construction — the footnote names *files*, not declarations. Grep each of
        `RealModel/{DoetsTheorem,Shuffle,ShuffleReal,EpsilonDense,OrderIsoReal}.lean` for its
        principal top-level declaration.
      - Lindenbaum–Tarski algebra — same: grep
        `Algebraic/{LindenbaumQuotient,BooleanStructure,InteriorOperators,UltrafilterMCS}.lean`
        for principal declarations. Module `Metalogic.Algebraic` is already confirmed.
- [ ] Resolve the entries the research left unsearched, recording `[none]` where nothing exists:
      Defined Operators, Separation (task topology T1/R0), Incompleteness at the base level,
      Decidability, Dichotomy, Task Topology, Language (`Syntax/Formula.lean`),
      Failure of a uniform finite model property.
- [ ] Confirm `completeness` in `Metalogic/BXCanonical/Completeness.lean` and
      `countermodel_discrete_reynolds_v2` (module — `Metalogic.WeakCanonical` vs a sub-namespace).
- [ ] Write `specs/456_.../baselines/leansrc-bindings.md`: one row per document item, columns
      *document anchor string* / *`#leansrc` call(s) to write, verbatim* / *CONFIRMED or DROPPED* /
      *evidence (file:line of the `namespace` line and of the declaration)* / *reason if dropped*.

**Timing**: 1.5 hours

**Depends on**: 1

**Verification Tier**: prose

**Scope Hypothesis**: The research proposes on the order of 35-40 individual `#leansrc` pairs
across ~30 document items, of which ~20 are `[confirmed]`. Neither figure is load-bearing — the
phase is done when every row in the table reads CONFIRMED or DROPPED with evidence, whatever the
final tally. Confirm by checking the table has no row lacking an evidence cell.

**Files to modify**:
- `specs/456_.../baselines/leansrc-bindings.md` — new; the binding table
- `FormalSystem/**` — **read only**
- `typst/FormalFoundations.typ` — **not touched in this phase**

**Verification**:
- Every row is CONFIRMED (with `file:line` evidence for both namespace and declaration) or DROPPED
  (with a reason).
- Zero rows carry `[plausible]`, `[needs verification]`, or any hedge.
- `lake env lean` / `lean_local_search` / `lean_hover_info` may substitute for grep; either way the
  evidence cell names a concrete file and line.
- `git status --short -- typst/FormalFoundations.typ` unchanged from Phase 1.

---

### Phase 3: Relocate the single paper citation to the abstract block [NOT STARTED]

**Goal**: Execute D1 — put the one surviving citation, with the paper's URL, in the abstract block,
and reduce the `#definition("Language")` footnote to its substantive remainder.

**Tasks**:
- [ ] Locate the abstract block by the literal string `*Abstract.* This report states what is proved`
      (confirm exactly one match).
- [ ] Add one sentence to the abstract block stating the document's relationship to the paper and
      carrying the citation and URL. Suggested wording, adjust to fit the surrounding register:
      *"This document reports what is machine-checked in `FormalSystem/`, following the
      presentation of Brast-McKie's task-frame semantics @brastmckie2026possibleworlds, available
      at #link("https://benbrastmckie.com/publications/possible_worlds.pdf")."* Place it as the
      opening or closing sentence of the abstract — not mid-paragraph — so it reads as a
      provenance note rather than an aside.
- [ ] Confirm `#link` (or whatever link form the document already uses) is available in scope;
      grep the file for an existing URL rendering and match it rather than inventing a form.
- [ ] Locate the Language footnote by `` `def:BLplus-language` ``. Strip the leading
      `` `def:BLplus-language`. @brastmckie2026possibleworlds `` prefix per D4, and remove the
      trailing URL clause now that the URL lives in the abstract. Keep verbatim: *"The paper's base
      language $BL$ takes the one-place $allpast$ and $allfuture$ as primitive instead; it embeds
      into $BLplus$ under @def-operators, and is not used below."*
- [ ] If Phase 2 CONFIRMED a Lean counterpart for the Language definition, add its `#leansrc`
      block after the `#definition("Language")` block and before the footnote-bearing text, per
      placement rule 4. If DROPPED, add nothing (D2/D3).
- [ ] Snapshot: `cp typst/FormalFoundations.typ specs/456_.../baselines/step-3.typ`

**Timing**: 0.5 hours

**Depends on**: 1

**Verification Tier**: local

**Scope Hypothesis**: This phase asserts the live citation count lands at **35** afterwards.
Derived from Phase 1's census: 36 total, minus 1 commented = 35 live; minus this phase's 1 strip,
plus this phase's 1 addition = 35. Confirm it by re-running the G2a command, not by assuming it —
a mismatch here means Phase 1's census was already stale and Phases 4-6 would inherit the error.
The full intended chain across phases is 35 → 35 → 19 → 1 → 1 (Phases 1/3/4/5/6).

**Files to modify**:
- `typst/FormalFoundations.typ` — abstract block gains one sentence; Language footnote loses its
  bookkeeping prefix and URL clause

**Verification**:
- `typst compile typst/FormalFoundations.typ` exits 0, still exactly 2 warnings, both the known
  thmbox font warnings (compare against `baselines/compile-baseline.log`).
- The abstract block contains exactly one `@brastmckie2026possibleworlds` and the paper URL.
- The Language footnote contains no `` `def:BLplus-language` `` and no
  `@brastmckie2026possibleworlds`.
- Live citation count is now 35 (`grep -vE '^[[:space:]]*//' | grep -c` → 35): 33 block-trailing
  still to strip in Phases 4-5, plus the mid-paragraph one, plus the new abstract one. (The
  7 LEAN-PATH sites handled in Phase 6 carry no paper citation and never enter this count.)

---

### Phase 4: PURE BOOKKEEPING — delete 16 footnotes, insert confirmed blocks [NOT STARTED]

**Goal**: Delete outright the 16 footnotes that contain nothing but anchors and a citation, and
place a verified `#leansrc` block after each item whose Phase 2 row reads CONFIRMED.

**Tasks**:

For each row below: grep the anchor string, confirm exactly one match, confirm the match is **not**
inside a `//`-prefixed comment, delete the entire `#footnote[...]` construct (including the
preceding `]` stays, the `#footnote[` through its matching `]` goes), then insert the block(s) from
the Phase 2 table on their own line immediately after the item's closing `]`.

| # | Anchor string to grep | `#leansrc` disposition |
|---|---|---|
| 1 | `#definition("Defined Operators")` | Per Phase 2 row; likely DROPPED |
| 2 | `#definition("Temporal Order")` | **No block** — D2, no bundled Lean declaration |
| 3 | `#definition("Directed Family")` | `#leansrc("Semantics.TaskFrame", "DirectedFamily")` |
| 4 | `#lemma("Nullity")` | `#leansrc("Semantics.TaskFrame", "nullity")` |
| 5 | `#definition("History")` | `#leansrc("Semantics", "PartialHistory")` then `#leansrc("Semantics", "WorldHistory")` (stacked) |
| 6 | `#theorem("Extension")` | `#leansrc("Semantics.PartialHistory", "extension")` |
| 7 | `#corollary("Occurrence")` | `#leansrc("Semantics.PartialHistory", "occurrence")` |
| 8 | `#theorem("Separation")` | Per Phase 2 row |
| 9 | `#definition("Validity and Consequence")` | `#leansrc("Semantics", "valid")` then `#leansrc("Semantics", "SemanticConsequence")` |
| 10 | `#definition("S5")` | **No block** — D2, MK/MT/M5 are three `Axiom` constructors, not a declaration |
| 11 | `#proposition("Correspondence")` | Per Phase 2 row; DROPPED unless a biconditional was located |
| 12 | `#theorem("Incompleteness at the base level")` | Per Phase 2 row |
| 13 | `#theorem("Decidability")` — disambiguate on the footnote body `` `cor:tm-decidability` `` and the statement "Whether TM, ... are decidable is open." | Per Phase 2 row |
| 14 | `#theorem("Dichotomy")` | Per Phase 2 row |
| 15 | `#remark` opening `The phenomenon is not special to task semantics` | **No block** — placement rule 5 forbids attaching to a `#remark` |
| 16 | `#definition("Strongest Objective Normal Modal Operator")` | **No block** — D2 |

- [ ] Execute all 16 rows.
- [ ] Snapshot: `cp typst/FormalFoundations.typ specs/456_.../baselines/step-4.typ`

**Timing**: 1.0 hours

**Depends on**: 2, 3

**Verification Tier**: local

**Scope Hypothesis**: 16 sites. Confirm by counting deletions against the Phase 1 citation census:
after this phase the live citation count must have dropped by exactly 16 relative to the end of
Phase 3 (**35 → 19**). A different delta means a site was missed or a footnote was over-deleted.

**Files to modify**:
- `typst/FormalFoundations.typ` — 16 footnotes deleted, N `#leansrc` blocks inserted

**Verification**:
- `typst compile` exits 0; warning set identical to baseline.
- Live citation count is 19.
- None of the 16 anchor strings has a trailing `#footnote[` any more.
- `grep -c -- '// FIX:'` still 12; commented `lem:step` block byte-identical to
  `baselines/commented-lemstep.before.txt`.
- Every newly inserted `#leansrc` pair appears as CONFIRMED in `baselines/leansrc-bindings.md`.

---

### Phase 5: SUBSTANTIVE — strip prefixes from 18 footnotes, insert confirmed blocks [NOT STARTED]

**Goal**: Strip the `` anchor. @citation `` bookkeeping prefix from the 18 block-trailing
substantive footnotes plus the one mid-paragraph site brought in scope by D6, keeping their
commentary verbatim per D4/D5, and place confirmed blocks.

**Tasks**:

| # | Anchor string to grep | Prefix to strip | `#leansrc` disposition |
|---|---|---|---|
| 1 | `#definition("Task Relation")` | `` `def:task-relation`. @brastmckie… `` | `#leansrc("Semantics.TaskFrame", "Fib")`, `("Semantics.TaskFrame", "cone")`, `("Semantics.TaskFrame", "Seg")` — stacked, or a single grouped block per placement rule 2 if Fiber/Cone/Segment/Frame read as one run |
| 2 | `#definition("Frame")` | `` `def:frame`. @brastmckie… `` | `#leansrc("Semantics", "TaskFrame")` |
| 3 | `#definition("Task Topology")` | `` `def:task-topology`. @brastmckie… `` | Per Phase 2 row |
| 4 | `#definition("Model")` | `` `def:BL-semantics`. @brastmckie… `` | `#leansrc("Semantics", "TaskModel")` |
| 5 | `#definition("Truth")` | `` `def:BL-semantics`, `def:BLplus-semantics`. @brastmckie… `` | `#leansrc("Semantics", "TruthAt")` — **keep `@scott1970advice`** (D5) |
| 6 | `#definition("Frame Properties")` | `` `def:frame-properties`. @brastmckie… `` | Per Phase 2 row (Dense/Discrete/Dedekind structures; Deterministic likely DROPPED) |
| 7 | `#definition("BX")` | `` `def:BX`. @brastmckie… `` | **No block** — D2 |
| 8 | figure/table `The three frame-class extensions` | `` `def:TMplus`, `def:TMplus-f`, `def:TMplus-d`, `def:TMplus-c`. @brastmckie… `` | Per Phase 2 row (`FrameClass`) |
| 9 | `#theorem("Soundness")` | `` `thm:TM-soundness`. @brastmckie… `` | Per Phase 2 row (umbrella or stacked) |
| 10 | `#proposition("Collapse")` | `Pthm:13, Pthm:14, Pthm:18, Pthm:20,` **and** the trailing `@brastmckie…` — D4 strips the `Pthm:` keys | Per Phase 2 row (content-matched perpetuity theorems only) |
| 11 | `#remark` opening `No conservativity claim is made` | `` `def:TMplus`. @brastmckie… `` | **No block** — placement rule 5 |
| 12 | `#proposition("Failure of a uniform finite model property` | `` `cor:tm-decidability`'s proof. @brastmckie… `` | Per Phase 2 row |
| 13 | `#definition("Irregular World")` | The whole `Quoted in substance from the live footnote at `sub:Extension`… re-verified verbatim against the live paper on 2026-08-13.` provenance clause — D4 drops it | **No block** — D2 |
| 14 | `#proposition("The price of irregular worlds")` | `@brastmckie…` and the `` `sub:Extension` `` anchor keys; keep the prose sense of "the paper's own" | **No block** — D2 |
| 15 | `#theorem("Existence")` | `` `thm:exist`. @brastmckie… `` | **No block** — D2 |
| 16 | `#theorem("Uniqueness and logic")` | `` `lem:uniq`, `thm:s4`, `thm:sym`. @brastmckie… `` — keep the following sentence but replace the bare `` `lem:uniq` `` reference with "the uniqueness lemma" | **No block** — D2 |
| 17 | `#proposition("Orthogonality")` | `The live Stability footnote following its semantic clause. @brastmckie…` | **No block** — D2 |
| 18 | (Language — already done in Phase 3) | — | — |
| 19 | Mid-paragraph, sentence ending `lacking one.` (D6) | `` `thm:BLplus-PastFuture`, `thm:BLplus-NextPrevious`. @brastmckie… `` | **No block** — mid-paragraph, no item to attach to |

- [ ] Execute all rows, keeping every commentary sentence verbatim except for the minimal repair
      D4 requires when the stripped prefix leaves a dangling fragment.
- [ ] Snapshot: `cp typst/FormalFoundations.typ specs/456_.../baselines/step-5.typ`

**Timing**: 1.5 hours

**Depends on**: 4

**Verification Tier**: local

**Scope Hypothesis**: 18 block-trailing sites (one already consumed in Phase 3, so 17 remain here)
plus 1 mid-paragraph site = 18 edits in this phase. Confirm by the citation census: live count must
go **19 → 1** exactly, the survivor being the abstract's. Any residue means a site was missed; any
undershoot means an out-of-scope footnote was edited.

**Files to modify**:
- `typst/FormalFoundations.typ` — 18 footnote prefixes stripped, N `#leansrc` blocks inserted

**Verification**:
- `typst compile` exits 0; warning set identical to baseline.
- Live citation count is **1**, the abstract's:
  `grep -vE '^[[:space:]]*//' typst/FormalFoundations.typ | grep -c 'brastmckie2026possibleworlds'` → 1.
- `@scott1970advice` still present exactly once.
- `grep -c -- '// FIX:'` still 12; commented block byte-identical.
- `pdftotext` the compiled output and read the 18 affected footnotes: each reads as a grammatical
  sentence with no leading orphaned punctuation.

---

### Phase 6: LEAN-PATH — convert 7 footnotes to `#leansrc` blocks [NOT STARTED]

**Goal**: Convert the 7 footnotes that already read as Lean-source notes into `#leansrc` blocks,
preserving their genuinely substantive commentary as trimmed footnotes placed *after* the blocks.

**Tasks**:

| # | Anchor string to grep | Blocks to write (per Phase 2 table) | Footnote to keep, trimmed |
|---|---|---|---|
| 1 | `#theorem("Base-class completeness (outstanding)")` | `#leansrc("Metalogic.BXCanonical", "completeness")` and the confirmed module for `countermodel_discrete_reynolds_v2` | Keep the whole `sorryAx` dependency analysis — it is substantive, not bookkeeping. `countermodel_discrete` stays named in the prose as dead code but gets **no** block of its own. |
| 2 | `#definition("Consistent and Maximal Consistent Sets")` | `#leansrc("Metalogic.Core", "SetConsistent")`, `#leansrc("Metalogic.Core", "SetMaximalConsistent")` | "Consistency is defined on finite subsets, so the set-level layer is finitary even though the sets themselves are infinite." |
| 3 | `#definition("Bundled Family of MCSs")` | `#leansrc("Metalogic.Bundle", "BFMCS")` | "…the structure also designates an evaluation family, the one containing the original consistent set." Keep — it describes a field the name does not reveal. |
| 4 | `#definition("Chronicle")` | `#leansrc(…, "singletonChronicle")`, `#leansrc(…, "omegaChain")` — module per Phase 2 | "Countability of the enumeration is what makes an $omega$-chain sufficient." |
| 5 | `#definition("The Reynolds pipeline")` | Four blocks: `one_class`, `VeryGood`/`good`, `limitdom_is_good`, `truth_transfer` — modules per Phase 2 | **Must survive (D5)**: "The decomposition technique is Doets's @doets1987; the step-by-step k-equivalence argument for Until/Since is Reynolds's @reynolds1992, as developed in Gabbay, Hodkinson, and Reynolds @gabbayhodkinsonreynolds1994." |
| 6 | `#definition("The real-model construction")` | Blocks for the principal declaration of each of the five `RealModel/` files, per Phase 2; DROPPED files get no block | "The basis is the Reynolds triple Prior-U, Prior-S, and Sep, with CO derived." |
| 7 | `#definition("The Lindenbaum--Tarski Algebra")` | Blocks for the principal declarations in the four `Algebraic/` files, per Phase 2 (`FlowFrame.lean` already has a live block at the Truth Lemma site — do not duplicate it) | "All five measure sorry-free." |

- [ ] Execute all 7 rows. Blocks first, trimmed footnote after, per placement rule 4.
- [ ] Snapshot: `cp typst/FormalFoundations.typ specs/456_.../baselines/step-6.typ`

**Timing**: 1.25 hours

**Depends on**: 5

**Verification Tier**: local

**Scope Hypothesis**: 7 sites, expanding to roughly 15-18 `#leansrc` calls depending on how many
of the `RealModel/` and `Algebraic/` declarations Phase 2 confirmed. The 7 is firm (it is the count
of footnotes with no paper citation, cross-checked in Phase 1: 41 block-trailing minus 34 with a
citation). The call count is not — confirm against the Phase 2 table, not against this estimate.

**Files to modify**:
- `typst/FormalFoundations.typ` — 7 footnotes trimmed, N `#leansrc` blocks inserted

**Verification**:
- `typst compile` exits 0; warning set identical to baseline.
- `@doets1987`, `@reynolds1992`, `@gabbayhodkinsonreynolds1994` all still present.
- No `.lean` file path remains inside any of the 7 footnotes (the paths are now carried by the
  blocks).
- `grep -c -- '// FIX:'` still 12; commented block byte-identical.

---

### Phase 7: Final gates, minimal cached-patch staging, summary [NOT STARTED]

**Goal**: Run the full gate set on the finished file, prove sibling territory survived, stage this
task's hunks only, and write the summary.

**Tasks**:
- [ ] **G1 — Compile.** `typst compile typst/FormalFoundations.typ /tmp/ff-456.pdf 2>&1 | tee /tmp/ff-456.log`.
      Assert: exit 0; `grep -c '^error:' /tmp/ff-456.log` is 0; `grep -c '^warning:' /tmp/ff-456.log`
      is exactly 2; and `diff <(grep '^warning:' /tmp/ff-456.log) <(grep '^warning:' baselines/compile-baseline.log)`
      is empty — so a genuinely new diagnostic cannot hide behind the two known thmbox warnings.
- [ ] **G2 — Citation count.** Run G2a and G2b from "Constraint Conflict C1": exactly 1 live
      occurrence (in the abstract block, with the URL) and exactly 2 total (the second inside the
      frozen commented block). Record the C1 deviation from the literally-stated `== 1` gate
      prominently in the summary.
- [ ] **G3 — Every `#leansrc` pair resolves.** Independently of the Phase 2 table: extract every
      `#leansrc("MOD", "NAME")` pair from the finished file with a grep, and for each one confirm a
      declaration `NAME` exists under a `namespace FormalSystem.MOD` (or a nesting that composes to
      it) in `FormalSystem/`. This must be a fresh check, not a re-read of the Phase 2 table —
      the table proves the *intended* pairs resolve; this proves the *written* pairs do.
      Any non-resolving pair is removed before staging, and its removal is recorded.
- [ ] **G4 — FIX-tag content invariant.** `grep -n -B2 -A2 -- '// FIX:' typst/FormalFoundations.typ | sed 's/^[0-9]*[-:]//'`
      diffed against `baselines/fix-context.before.txt` — **must be empty**. Plus
      `grep -c -- '// FIX:'` is 12.
- [ ] **G5 — FIX-tag position invariant.** Parse the `@@ -a,b +c,d @@` headers of
      `diff -u baselines/FormalFoundations.pre-456.typ typst/FormalFoundations.typ` and assert no
      hunk's old-side range `[a, a+b)` contains any line number in `baselines/fix-lines.before.txt`,
      nor any line of the commented-out `lem:step` block. **Must be an empty intersection.**
- [ ] **G6 — Commented block frozen.** Re-extract the `lem:step` commented run by content and diff
      against `baselines/commented-lemstep.before.txt` — must be byte-identical, and G5 must show
      it was not inside any hunk (proving position as well as content).
- [ ] **G7 — Out-of-scope footnotes intact.** Confirm the 8 remaining mid-paragraph footnotes are
      unchanged: locate each by its distinctive opening (`The development has separately
      machine-checked`, `multiFamGen_spherical`, `limit_satisfies_c5_strong`, `Kamp's 1968
      dissertation`, `Both in \`Metalogic/Decidability/Correctness.lean\``, `*Predicativity*`,
      `An earlier unpublished draft`, `The development records an explicit non-compactness
      witness`) and diff each against the baseline copy.
- [ ] **Stage.** Build and apply the minimal cached patch exactly as specified in the "Territory
      and Staging Contract" section. Run `git apply --cached --3way --check` first. Review
      `git diff --cached -- typst/FormalFoundations.typ` line by line and confirm every hunk is
      this task's. On `--check` failure, take the documented fallback: stage `specs/**` only, leave
      the typst file unstaged, and say so in the summary and in the final report to the user.
- [ ] Commit: `task 456: complete implementation` with the session ID in the body. Stage
      `specs/456_.../**` and, if the patch applied, the cached typst hunks. **Never**
      `git add typst/FormalFoundations.typ`, `git add -A`, or `git commit -am`.
- [ ] Write `specs/456_.../summaries/01_leansrc-conversion-summary.md`: sites edited per class,
      blocks written vs. dropped (with reasons, so D2/D3 absences are on the record), the C1
      citation-gate deviation, gate results, and whether staging succeeded or fell back.

**Timing**: 0.75 hours

**Depends on**: 6

**Verification Tier**: full

**Scope Hypothesis**: G7 asserts 8 surviving out-of-scope mid-paragraph footnotes, derived as
9 mid-paragraph sites minus the one brought in scope by D6. Confirm by enumerating them from the
baseline copy and matching each against the finished file, not by trusting the arithmetic — the
research's count of 9 is itself a plan-time observation.

**Files to modify**:
- `specs/456_.../summaries/01_leansrc-conversion-summary.md` — new
- `specs/456_.../baselines/456-only.patch` — new; the staged patch, kept as evidence
- git index only (never the working tree)

**Verification**:
- G1 through G7 all pass. Any failure stops the phase — do not stage on a red gate.
- `git status --short` shows no unexpected staged file.
- `git diff --cached` contains no sibling hunk.

---

## Testing & Validation

- [ ] `typst compile typst/FormalFoundations.typ` exits 0.
- [ ] Compile stderr is exactly the two baseline `unknown font family: new computer modern sans`
      warnings from `thmbox.typ:148:26` and `:169:26`, compared as text and not merely counted.
- [ ] Exactly 1 live `@brastmckie2026possibleworlds`, in the abstract block, with the paper URL;
      exactly 2 total, the other inside the frozen commented block (C1).
- [ ] Every `#leansrc(module, name)` pair in the finished file resolves to a real declaration in
      `FormalSystem/`, checked fresh against the file rather than against the planning table.
- [ ] The 12 `// FIX:` tags are unchanged in content and were not inside any diff hunk.
- [ ] The commented-out `lem:step` block is byte-identical and untouched by any hunk.
- [ ] The 8 out-of-scope mid-paragraph footnotes are byte-identical.
- [ ] `@scott1970advice`, `@doets1987`, `@reynolds1992`, `@gabbayhodkinsonreynolds1994`,
      `@kamp1968`, `@burgess1982axioms`, `@bacon2022necessities` and every other non-paper citation
      still present.
- [ ] `git diff --cached` contains only this task's hunks.

## Artifacts & Outputs

- `typst/FormalFoundations.typ` — 41 block-trailing footnotes plus 1 mid-paragraph footnote
  processed; N verified `#leansrc` blocks added; single paper citation in the abstract
- `specs/456_.../baselines/FormalFoundations.pre-456.typ` — pre-edit baseline (territory evidence)
- `specs/456_.../baselines/leansrc-bindings.md` — verified binding table
- `specs/456_.../baselines/compile-baseline.log`, `fix-context.before.txt`, `fix-lines.before.txt`,
  `commented-lemstep.before.txt`, `citations.before.txt`, `leansrc.before.txt`
- `specs/456_.../baselines/step-{3,4,5,6}.typ` — incremental snapshots
- `specs/456_.../baselines/456-only.patch` — the staged minimal patch
- `specs/456_.../summaries/01_leansrc-conversion-summary.md`

## Rollback/Contingency

The working tree is the only copy of the sibling tasks' uncommitted work, so rollback is by
**forward restoration from the baseline, never by destructive git**.

- **Mid-phase failure**: `baselines/FormalFoundations.pre-456.typ` and the `step-N.typ` snapshots
  reconstruct any earlier state with a plain `cp`. Never `git checkout`, `git restore`,
  `git reset --hard`, or `git stash` on this file — every one of those would discard sibling work.
- **Compile breaks and the cause is not obvious**: `cp` the most recent green `step-N.typ` back
  over the file, re-run G1, and redo the failing phase in smaller increments.
- **`git apply --cached --check` fails**: this is an expected branch, not a failure. Commit
  `specs/**` only, leave the typst file unstaged, and report the overlap to the user.
- **A gate fails after staging** (should not happen — G1-G7 precede staging): `git restore --staged
  typst/FormalFoundations.typ` unstages without touching the working tree and is explicitly safe.
