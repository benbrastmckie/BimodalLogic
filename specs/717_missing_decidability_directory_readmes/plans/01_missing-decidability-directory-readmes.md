# Implementation Plan: Task #717

- **Task**: 717 - Write the three missing directory READMEs that fail `scripts/readme-lint.sh` in CI
- **Status**: [IMPLEMENTING]
- **Effort**: 4.5 hours
- **Dependencies**: None
- **Research Inputs**: specs/717_missing_decidability_directory_readmes/reports/01_missing-decidability-directory-readmes.md
- **Artifacts**: plans/01_missing-decidability-directory-readmes.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Three directories under `FormalSystem/Metalogic/Decidability/` contain Lean modules but no
`README.md`, so `scripts/readme-lint.sh` Check 1 reports `Missing READMEs: 3` and exits 1 inside
the CI `readme-lint` step. The work is to author exactly those three files — nothing else is
required to flip the gate — at the depth of the named sibling exemplar
`WitnessFamily/Compression/README.md` (purpose statement, route narrative, per-module table, scope
boundaries), plus the `*Last verified:*` stamp the parent `PlusWitnessFamily/README.md` carries.
No Lean source is edited and `lake build` is not required. Definition of done:
`bash scripts/readme-lint.sh FormalSystem BimodalTools` exits 0, with
`bash scripts/check-module-invariants.sh --emit-inventory --check` still reporting `PASS INV`.

### Research Integration

Findings carried directly into the phases below:

- **Only Checks 1 and 3 are gated.** Check 1 (missing README) and Check 3 (broken relative
  markdown link) fail the build; Check 2 (`NOT LISTED`) and Check 4 (date stamps) are reported but
  never affect the exit code. The gate therefore flips as soon as the three files exist *and*
  introduce no unresolvable link.
- **Check 3's link scan is code-fence-blind.** It greps `\[.*?\]\(\K[^)]+` over the whole file and
  skips only `http://`/`https://`, so any `]` immediately followed by `(` — including inside a
  ```` ```lean ```` fence or in notation such as `f[a](root)` — is treated as a link and can turn
  CI red. This is the single realistic failure mode and drives the authoring rule and the
  per-phase verification in every phase below.
- **House style is the exemplar's structure plus the parent's stamp.** The two written standards
  (`docs/development/DIRECTORY_README_STANDARD.md`, `docs/reference/readme-standard.md`) disagree
  on the module-table shape and on whether a stamp is required, and neither in-tree exemplar
  follows either literally. Resolution: exemplar sections, a `| Module | Contents |` table with no
  `Lines` column, and a `*Last verified: YYYY-MM-DD*` footer (the 51-occurrence dominant form).
- **No `<!-- BEGIN GENERATED: inventory -->` or `<!-- INVENTORY: hand-maintained -->` marker.**
  `INV` currently passes; a marker opts the file into exhaustiveness checking for no gate benefit,
  and the route-ordered table these directories need is not the shape the generator emits.
- **C9 binds `FormalSystem/**`**: zero task-number citations, and no plan/phase numbering
  transcribed from module headers (`FixtureStable.lean`'s docstring contains a sub-phase number
  that must not be copied).
- **Per-directory content sources are already located.** `Limits/` and `Compression/` from their
  own module docstrings; `PlusSlicedCertificate/`'s route narrative and 23 of 25 module
  descriptions from the re-export docstring in
  `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate.lean`, with `HalfRun.lean` and
  `FixtureStable.lean` read directly because the re-export has no dedicated bullet for them.
- **One framing trap.** The exemplar's directory *yields* decidability; the L⁺ twin's compression
  theorem is **refuted outright** by `Limits/NoCertificate.lean`'s
  `not_exists_plusCertifies_pumpTarget`, and `Extract.lean` retains a correct-but-unused alignment
  half (~620 lines) that C17's dead-declaration census is expected to report. Mirroring the
  exemplar's conclusion into `Compression/README.md` would document a false claim.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` was provided in the dispatch context; no roadmap phases are included and
`specs/ROADMAP.md` is not read or written by this plan.

## Goals & Non-Goals

**Goals**:
- `bash scripts/readme-lint.sh FormalSystem BimodalTools` exits 0.
- Three new `README.md` files exist, each at exemplar depth: purpose statement, route narrative in
  dependency order, a `| Module | Contents |` table naming every `.lean` basename in that
  directory, explicit scope boundaries, a dependencies block, a related-documentation link footer,
  and a `*Last verified:*` stamp.
- `bash scripts/check-module-invariants.sh --emit-inventory --check` still reports `PASS INV`.
- Each new file is free of `NOT LISTED` and `MISSING DATE`/`STALE DATE` lines (ungated, but these
  are the very directories the task exists to document).
- Every substantive claim in the three files is traceable to a module docstring or a named
  declaration; the proved / refuted / **open** distinction is preserved rather than smoothed over.

**Non-Goals**:
- No Lean source edits, no new declarations, no `sorry`, no axiom. `lake build` is not part of the
  acceptance criterion.
- The 28 `STALE DATE` and 3 `MISSING DATE` warnings elsewhere in the tree, and the ~94 Check 2
  `Files not listed (info)` warnings outside the three target directories.
- Adding a `Lines` column, or opting any file into a generated/hand-maintained inventory block.
- Reconciling the two competing README standards in `docs/`; this plan records the de facto house
  style it follows and changes neither document.

## Lean Challenge Statements

```lean
-- None. This task introduces no Lean declarations: it writes three markdown files and edits no
-- `.lean` source. The identifier set declared here is empty, matching the empty identifier set
-- named under `- **Goals**:` above.
```

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| A `]` followed by `(` in notation or inside a fenced Lean block is read as a broken link, turning the gate red | H | M | Authoring rule: never let `]` be immediately followed by `(` except in a verified relative link or an `http(s)` URL. Prefer backticked module names over links. Every phase's verification reads the `--- Check 3 ---` section, not just the summary line. |
| Mirroring the exemplar's "completeness half, giving decidability" framing into `Compression/README.md` documents a claim the tree refutes | H | M | Phase 2 states the withdrawal explicitly, citing `Limits/NoCertificate.lean`'s `not_exists_plusCertifies_pumpTarget`, and explains why the alignment half is retained and unused. |
| Condensing the 25-module closing record collapses the refuted/open distinction | H | M | Phase 3 keeps "what is proved / what is refuted / what is **open**" as a named section: the sliced FMP is **open**, the finite-carrier FMP is **refuted**, the doubly-exponential slice width is a research finding and **not a theorem**. |
| A task number or a transcribed sub-phase number leaks in, failing C9 | M | L | Phase 4 greps all three files for task/phase numbering; `FixtureStable.lean`'s docstring sub-phase reference is explicitly not transcribed. |
| A stated sorry/axiom count contradicts C14 | L | L | Measured: all three directories are sorry-free and axiom-free (the single `grep` hit is prose in `EmbedComplete.lean`'s docstring). "Sorry-free" is the only count asserted. |
| `*Last verified:*` predates the commit, producing a fresh `STALE DATE` | L | M | Stamp with the actual implementation/commit date; Phase 4 re-checks with `git log -1 --format=%cs` per directory after the files land. |
| A module was added or renamed since research, leaving a `NOT LISTED` row | L | L | Each authoring phase re-lists its directory with `ls *.lean` immediately before writing the table (see that phase's Scope Hypothesis). |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2, 3 | -- |
| 2 | 4 | 1, 2, 3 |
| 3 | 5 | 4 |

Phases within the same wave can execute in parallel. Wave 1's three phases each own exactly one
new file in a distinct directory and share no target, so they are safe to dispatch concurrently.

### Phase 1: Limits/README.md — the two incompleteness refutations [COMPLETED]

**Goal**: Author `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Limits/README.md`
(70-100 lines) documenting the three modules and, above all, what the two refutations do *not*
say.

**Tasks**:
- [ ] `ls FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Limits/*.lean` and confirm exactly
      three basenames: `Targets.lean`, `HopFree.lean`, `NoCertificate.lean`.
- [ ] Read each of the three module docstrings for content and for the scope-boundary sentences to
      carry over.
- [ ] Write the purpose paragraph: this directory records the limits of the
      `PlusSharingWitnessFamily` certificate class — it states no positive result and is consumed
      by the re-export `PlusWitnessFamily.lean`.
- [ ] Write `## The route` as a **branching** narrative, not a chain: `Targets` supplies the two
      limit targets and states no limit itself; `HopFree` and `NoCertificate` are parallel
      siblings over different targets and different hypothesis classes. Record that
      `NoCertificate.lean` re-derives rather than imports the three shared opening steps, because
      `hopClosure p` and `pumpClosure p` are distinct `Finset PlusFormula` values with no
      transporting membership fact.
- [ ] Write the `| Module | Contents |` table with one row per basename, naming the principal
      declarations: `Targets.lean` (`hopTarget`, `pumpTarget`, `hopClosure`, `pumpClosure`, the
      two non-validities, the two shared antecedents); `HopFree.lean`
      (`not_plusCertifies_hopTarget_of_hopFree`, `not_exists_hopFree_plusCertifies_hopTarget`, the
      pigeonhole over `lassos.length + 1` state paths); `NoCertificate.lean`
      (`not_exists_plusCertifies_pumpTarget`, under no hypothesis, at any time, lasso count or
      segment length).
- [ ] Write `## What is refuted, and what is not`: `HopFree` bounds a *strategy*, not the class —
      it does not say `TransId.lean` is wrong, does not say the six-condition class is incomplete,
      and does not say `hopTarget p` is unrefutable. For `NoCertificate`: the defect is not a
      missing bound and no bound repairs it; weakening (C2') is not an option while
      `plusRefutes_of_certifies` is to survive; `plusTruth_iff_mem` and `plusRefutes_of_certifies`
      are untouched.
- [ ] Record provenance: both refutations are transcriptions of compiled probes, now parametric in
      the atom.
- [ ] Write `## Dependencies` (imports: `Targets` by both; `HopFree` also `../TransId`;
      `NoCertificate` also Mathlib pigeonhole/ring/WLOG. Imported by: the re-export
      `PlusWitnessFamily.lean`, `PlusSlicedCertificate/Sound.lean`, `PlusSlicedCertificate.lean`,
      `PlusWitnessFamily/Compression/Extract.lean`) and `## Related Documentation` with the three
      verified relative links below.
- [ ] Append `*Last verified: <implementation date>*`.
- [ ] From the file's own directory, `test -e` each relative link target before considering the
      phase done.

**Timing**: 0.75 hours

**Depends on**: none

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: This directory holds exactly 3 `.lean` modules (`Targets`, `HopFree`,
`NoCertificate`) and the file needs exactly 3 relative links (`../README.md`,
`../../README.md`, `../../WitnessFamily/Compression/README.md`). Confirm at implementation time
with `ls FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Limits/*.lean` and a `test -e` on
each link target resolved from the README's own directory; if the module set differs, add or
remove table rows to match what is on disk before proceeding.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Limits/README.md` - new file, 70-100 lines

**Verification**:
- `bash scripts/readme-lint.sh FormalSystem BimodalTools | grep -A5 -- '--- Check 3 ---'` reports
  no `BROKEN` line for this file.
- `bash scripts/readme-lint.sh FormalSystem BimodalTools | grep 'PlusWitnessFamily/Limits'` shows
  no `MISSING`, no `NOT LISTED`, no `MISSING DATE`/`STALE DATE` row.
- Every `.lean` basename in the directory appears in the table.
- No `]` is immediately followed by `(` anywhere in the file except in a resolvable relative link:
  `grep -n ']\s*(' <file>` reviewed by hand.

---

### Phase 2: Compression/README.md — the L⁺ twin whose theorem was withdrawn [COMPLETED]

**Goal**: Author
`FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Compression/README.md` (100-140 lines),
mirroring the named exemplar's *structure* while **inverting its conclusion**.

**Tasks**:
- [ ] `ls FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Compression/*.lean` and confirm
      exactly five basenames: `Types`, `Cycle`, `Fulfil`, `Extract`, `Saturate`.
- [ ] Re-read the exemplar `FormalSystem/Metalogic/Decidability/WitnessFamily/Compression/README.md`
      for section order and house voice; re-read the five module docstrings for content.
- [ ] Purpose paragraph: this is the L⁺ twin of the `Formula`-side compression half. State up
      front, not in a footnote, that the L⁺ compression theorem **does not exist and cannot exist
      for the landed certificate class** — `Limits/NoCertificate.lean`'s
      `not_exists_plusCertifies_pumpTarget` refutes it outright, under no hypothesis.
- [ ] Write `## The route` as the strict chain `Types → Cycle → Fulfil → Extract → Saturate`, each
      importing exactly its predecessor, with `Cycle` and `Extract` additionally importing their
      `Formula`-side counterparts for the generic lemmas they reuse rather than transcribe.
- [ ] Write the `| Module | Contents |` table with one row per basename, naming principal
      declarations and, per module, what is **reused by import** versus **transcribed**:
      `Types` (`plusTypeAtM`, `PlusLocalCoherentSeqLab`, `PlusFulfillingSeqLab`, and the three
      truth lemmas with no L⁺ counterpart elsewhere: `plusBox_const`, `plusTruth_untl_succ`,
      `plusTruth_snce_pred`); `Cycle` (`PlusTypeState`, `plusJoinPathT`,
      `exists_recurring_plusTypeState`, derived bound with `k = C.card`; reuses the abstract
      pigeonhole pair by import); `Fulfil` (the four propagation/offset lemmas and
      `plusFulfillingSeqLab_of_good_cycles`; mentions no `⊡`); `Extract` (`plusMidBoundC`,
      `plusCompressionBound`, `plusTypeOfT_unrollOf`; reuses eight readout lemmas by import; holds
      the retained-and-unused alignment half); `Saturate` (the (C5) demand's semantics).
- [ ] Write the retained-and-unused section: the alignment block has no consumer in this tree and
      is expected to have none; it is kept because it is correct and non-trivial and deleting it
      would erase the record of what the withdrawn route required; C17's dead-declaration census
      is **expected** to report it.
- [ ] Write the design-decision sections: no clause is added to either sequence predicate by the
      L⁺ re-index (five clauses and two clauses respectively, unchanged — `⊡` is not an
      eventuality, has no one-step unfolding, and (C5) is a family condition across the
      `share`-class at one time, so it cannot be stated at a bare label sequence); the bound's
      shape is unchanged despite the larger closure, since the `stab` tier enlarges `C.card` but
      contributes no excursion and so no accounting term; the duplication is forced because
      `Formula` and `PlusFormula` are separate inductives sharing no supertype, with the named
      retirement trigger being a shared periodic-label presentation; the `snce` propagation lemma
      is stated separately rather than derived by duality because the tree has no `PlusFormula`
      duality operation.
- [ ] Write `## What is out of scope` and `## Dependencies` (imported by `PlusWitnessFamily.lean`,
      `PlusSlicedCertificate/Position.lean`, `PlusSlicedCertificate/Sound.lean`,
      `PlusSlicedCertificate.lean`), then `## Related Documentation` with verified relative links,
      then `*Last verified: <implementation date>*`.
- [ ] From the file's own directory, `test -e` each relative link target.

**Timing**: 1 hour

**Depends on**: none

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: This directory holds exactly 5 `.lean` modules in the strict chain
`Types → Cycle → Fulfil → Extract → Saturate`, and `Extract.lean`'s alignment half is still
present and still unconsumed. Confirm with `ls .../Compression/*.lean`, with each module's
`import` lines read directly, and by re-reading `Extract.lean`'s docstring paragraph on the
alignment half; if the alignment half has since acquired a consumer, say so accurately instead of
repeating the research-time claim.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Compression/README.md` - new file, 100-140 lines *(deviation: altered — landed at 158 lines; the withdrawal statement and the retained-and-unused section needed the extra prose)*

**Verification**:
- `bash scripts/readme-lint.sh FormalSystem BimodalTools | grep -A5 -- '--- Check 3 ---'` reports
  no `BROKEN` line for this file.
- `bash scripts/readme-lint.sh FormalSystem BimodalTools | grep 'Compression'` shows no `MISSING`,
  no `NOT LISTED`, no `MISSING DATE`/`STALE DATE` row for the `PlusWitnessFamily/Compression`
  path.
- The file nowhere asserts that this directory yields decidability or that an L⁺ compression
  theorem holds; the refutation is named with its theorem (`not_exists_plusCertifies_pumpTarget`).
- Every `.lean` basename appears in the table; `grep -n ']\s*(' <file>` reviewed by hand.

---

### Phase 3: PlusSlicedCertificate/README.md — 25 modules in six layers [COMPLETED]

**Goal**: Author `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/README.md` (160-220
lines): the six-layer route, a 25-row module table, and a closing
proved / refuted / **open** record that preserves every distinction the re-export docstring draws.

**Tasks**:
- [ ] `ls FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/*.lean` and confirm 25
      basenames against the re-export's import list.
- [ ] Read the module docstring of `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate.lean`
      — the primary content source, carrying the route and 23 of the 25 module descriptions.
- [ ] Read `PlusSlicedCertificate/HalfRun.lean` (lines 1-48) and
      `PlusSlicedCertificate/FixtureStable.lean` (lines 1-55) directly — the re-export has no
      dedicated bullet for either.
- [ ] Purpose paragraph: a **time-sliced** bi-serial labelled graph presenting a frame on the
      infinite carrier `ℤ × Fin n` with finite fibres; why this subtree exists beside
      `PlusWitnessFamily/` (all-threads fulfilment; the finite carrier; the disappearance of
      absolute-time alignment); soundness is not at issue in either direction.
- [ ] Write `## The route` as six named layers in dependency order, taken from the re-export's
      layering-ordered import list: (1) the object and its frame — `Basic`, `Frame`;
      (2) declarative liveness — `Splice`, `Position`, `Live`, `Canon`; (3) the window and the
      fixture that fixes its width — `Window`, `Fixture`; (4) tail stability — `Stable`, `Tail`,
      `FixtureStable`; (5) computed liveness and the bridge — `Timed`, `Fixpoint`, `Computed`,
      `Fold`, `Unroll`, `LiveFix`, `Bridge`, `HalfRun`; (6) the checker, its two theorems, and the
      embedding — `Check`, `Sound`, `Complete`, `Embed`, `EmbedComplete`, `Examples`. *(deviation: altered — the
      per-module `import` lines contradict this grouping, so the Scope Hypothesis's "follow the
      imports" direction was taken: `Fixture` imports `Bridge` and `Stable` imports `Fixture`, so
      the computed-liveness machinery precedes the width fixture rather than following it. Landed
      grouping: (1) `Basic`, `Frame`, `Window`; (2) `Position`, `Live`, `Canon`, `Splice`;
      (3) `Timed`, `Fixpoint`, `Computed`, `Fold`, `Unroll`, `LiveFix`; (4) `Bridge`;
      (5) `Fixture`, `Stable`, `Tail`, `FixtureStable`, `HalfRun`; (6) `Check`, `Sound`,
      `Complete`, `Embed`, `EmbedComplete`, `Examples`)*
- [ ] Write the `| Module | Contents |` table with all 25 rows, describing each module by its
      **role in the route** with its principal declarations named — not as a flat declaration
      dump, so the table survives a single-file addition. Include the two modules the re-export
      omits: `FixtureStable` (the verdict *against* `exists_tailStable_repr`:
      `Fixture.not_tailStable_cert`, `Fixture.ΦBack_L₀_inter_ne_cert`, `Fixture.not_tailStable`)
      and `HalfRun` (one-directional liveness from an explicit half-line).
- [ ] Note the deliberate negatives where they exist: `Computed` **claims no equality** with
      `Live`; `AUFix` in `Fixpoint` is deliberately unused; `decidableTailStable` is a
      residue-indexed demand.
- [ ] Write `## What is proved, what is refuted, and what is open` with the three kept distinct:
      **proved** — soundness (`plusTruthAt_iff_canAt`, `plusRefutes_of_certifies` landing
      `PlusWitnessFamily.PlusRefutes Γ Del` unchanged), relative completeness
      (`exists_plusSlicedCertificate_of_tailStable_countermodel`), the embedding
      (`WitnessFamily.sliced`, `sliced_biSerial`); **refuted** — the finite-carrier FMP for this
      certificate shape, unconditionally, with restriction to the CTL-like fragment not rescuing
      it because the `⊡`-free non-validity that defeats it already lies inside that fragment; and
      `exists_tailStable_repr` is false and is therefore not stated in any weakened form;
      **open** — the sliced finite model property, which no module states, implies, or treats as
      settled either way. State separately that the doubly-exponential expected slice width is a
      research finding and **not a theorem**: no slice-width bound, no tail-period bound and no
      complexity claim is proved anywhere in this subtree.
- [ ] Record the nine conjuncts of `Check.Certifies` as a named count, and the STANDING RULE from
      `FixtureStable.lean` — any probe of a `TailStable`-like demand must carry **both** an `untl`
      and a `snce`, with the two smallest witnesses kept as a permanent regression pair in
      `EmbedComplete.lean`'s `BotTargets` namespace — rephrased without its source docstring's
      sub-phase numbering.
- [ ] Write `## Dependencies` (all 25 imported by the re-export
      `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate.lean`, which
      `FormalSystem/Metalogic/Decidability.lean` imports) and `## Related Documentation` with
      verified relative links, then `*Last verified: <implementation date>*`.
- [ ] From the file's own directory, `test -e` each relative link target.

**Timing**: 1.75 hours

**Depends on**: none

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: This directory holds exactly 25 `.lean` modules, grouping into the six
layers above in the order the re-export's import list states, and the subtree is sorry-free and
axiom-free (the single `sorry` grep hit is prose inside `EmbedComplete.lean`'s docstring). Confirm
with `ls .../PlusSlicedCertificate/*.lean | wc -l`, by diffing that basename set against the
re-export's import list, and with
`grep -rn 'sorry' FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/*.lean` before
asserting "sorry-free". The layer grouping is a reading of the import order, not a claim the tree
mechanically enforces — if a module's imports contradict the layer it is placed in, follow the
imports.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/README.md` - new file, 160-220 lines *(deviation: altered — landed at 224 lines)*

**Verification**:
- `bash scripts/readme-lint.sh FormalSystem BimodalTools | grep -A5 -- '--- Check 3 ---'` reports
  no `BROKEN` line for this file.
- `bash scripts/readme-lint.sh FormalSystem BimodalTools | grep 'PlusSlicedCertificate'` shows no
  `MISSING`, no `NOT LISTED`, no `MISSING DATE`/`STALE DATE` row.
- All 25 `.lean` basenames appear in the table (count the rows).
- The open / refuted / research-finding three-way distinction is present as a named section with
  all three cases explicit.
- `grep -n ']\s*(' <file>` reviewed by hand; no notation-shaped bracket-paren pair remains.

---

### Phase 4: Gate verification and cross-file audit [IN PROGRESS]

**Goal**: Confirm the acceptance criterion holds and that the three new files introduce no new
warning, no C9 violation and no stale stamp.

**Tasks**:
- [ ] `bash scripts/readme-lint.sh FormalSystem BimodalTools; echo "exit=$?"` — must print
      `exit=0` with `Missing READMEs: 0` and `Broken file references: 0`.
- [ ] Read the full `--- Check 3 ---` section of that output, not only the summary counters.
- [ ] `bash scripts/check-module-invariants.sh --emit-inventory --check` — must still report
      `PASS INV`.
- [ ] `bash scripts/readme-lint.sh FormalSystem BimodalTools | grep -E 'PlusSlicedCertificate|PlusWitnessFamily/(Compression|Limits)'`
      — must show no `NOT LISTED` and no `MISSING DATE`/`STALE DATE` line for the three new files.
- [ ] C9 audit: grep all three new files for task-number and phase-number citations
      (`grep -nEi 'task [0-9]|phase [0-9]|sub-phase' <the three files>`) and remove any hit.
- [ ] Confirm each file carries `*Last verified: YYYY-MM-DD*` in the dominant form, with the date
      equal to the implementation/commit date; after committing, cross-check with
      `git log -1 --format=%cs -- <each directory>`.
- [ ] Confirm no `.lean` file under `FormalSystem/` was modified: `git status --short` shows only
      the three new `README.md` paths (plus `specs/**` task bookkeeping).

**Timing**: 0.5 hours

**Depends on**: 1, 2, 3

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: Exactly three new files are expected in the diff and the whole-tree counters
are expected to move only by those three (`Missing READMEs: 3 → 0`, `Total READMEs found: 72 →
75`, `Broken file references: 0 → 0`). Confirm by comparing the counter block against those
research-time baselines; a counter that moved in any other way means something outside this task's
scope was touched and must be investigated before the phase closes.

**Files to modify**:
- none planned - verification only; edits occur here only to fix a finding, and land in the file the finding names

**Verification**:
- `bash scripts/readme-lint.sh FormalSystem BimodalTools` exits 0 (the task's stated acceptance
  criterion).
- `bash scripts/check-module-invariants.sh --emit-inventory --check` exits 0 with `PASS INV`.
- Zero task-number or phase-number hits in the three new files.

---

### Phase 5: List the two subtrees in their parent READMEs (optional, non-gating) [NOT STARTED]

**Goal**: Silence the Check 2 `NOT LISTED` warnings for the two subtrees in
`FormalSystem/Metalogic/Decidability/README.md`, and name `Compression` in
`FormalSystem/Metalogic/Decidability/PlusWitnessFamily/README.md`. This phase affects no gate and
may be dropped without reopening the task.

**Tasks**:
- [ ] Add four rows to `Decidability/README.md`'s Modules table — `PlusWitnessFamily.lean`,
      `PlusWitnessFamily/`, `PlusSlicedCertificate.lean`, `PlusSlicedCertificate/` — mirroring the
      existing `WitnessFamily/` and `BiLasso/` rows (which carry file counts and sorry status).
- [ ] Re-count the file counts at edit time rather than reusing a plan-time number.
- [ ] Add one line to `PlusWitnessFamily/README.md` naming `Compression` (it currently names
      `Limits` but never `Compression`).
- [ ] Refresh the `*Last verified:*` stamp on any file edited here.

**Timing**: 0.5 hours

**Depends on**: 4

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: Four new rows in `Decidability/README.md` and one new line in
`PlusWitnessFamily/README.md`. Confirm at implementation time by reading the existing
`WitnessFamily/` and `BiLasso/` rows for the column set actually in use, and by re-running
`ls` for each referenced directory's file count; if the table's columns differ from the
research-time reading, follow the table.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/README.md` - four Modules-table rows for the two subtrees
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/README.md` - one line naming `Compression`; refresh stamp

**Verification**:
- `bash scripts/readme-lint.sh FormalSystem BimodalTools; echo "exit=$?"` still prints `exit=0`.
- The `NOT LISTED` lines for `PlusWitnessFamily` and `PlusSlicedCertificate` under
  `Decidability/README.md` are gone.
- No new `BROKEN` line appears in `--- Check 3 ---`.

## Testing & Validation

- [ ] `bash scripts/readme-lint.sh FormalSystem BimodalTools` exits 0 (acceptance criterion).
- [ ] `bash scripts/check-module-invariants.sh --emit-inventory --check` exits 0 with `PASS INV`.
- [ ] The `--- Check 3 ---` section contains no `BROKEN` line attributable to any new or edited
      file.
- [ ] No `NOT LISTED`, `MISSING DATE` or `STALE DATE` line for the three target directories.
- [ ] `git status --short` shows no modified `.lean` file.
- [ ] No task-number or phase-number citation in any file written under `FormalSystem/`.
- [ ] `lake build` is explicitly **not** required: no Lean source is edited.

## Artifacts & Outputs

- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Limits/README.md` (new, 70-100 lines)
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Compression/README.md` (new, 100-140 lines)
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/README.md` (new, 160-220 lines)
- Optionally (Phase 5): edits to `FormalSystem/Metalogic/Decidability/README.md` and
  `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/README.md`
- `specs/717_missing_decidability_directory_readmes/summaries/01_*-summary.md` at completion

## Rollback/Contingency

All work is additive markdown in files that did not previously exist (Phases 1-3) plus two
small, reviewable edits to existing READMEs (Phase 5). Reverting is therefore cheap and does not
require discarding any uncommitted Lean work:

- **Per-file revert**: delete the offending new `README.md`. The repository returns to its
  current state — gate red with `Missing READMEs: N` — which is the pre-task baseline, not a
  regression.
- **Phase 5 revert**: `git revert` that phase's commit; it is independent of the gate-flipping
  commits by construction, which is why it is sequenced last.
- **If a working-tree rollback that would discard uncommitted changes is genuinely needed**, take
  a snapshot first per `context/contracts/recovery.md`'s rollback rung, and use its documented
  invocation shape (including the out-of-scope override flag where the revert must span the whole
  tree). Do not emit a bare reverting snapshot as a routine start-of-phase precaution; an ordinary
  defensive checkpoint before risky work uses the non-reverting `--no-revert` form instead.
- **If a module's purpose genuinely cannot be determined** from its docstring, mark the task
  `[BLOCKED]` rather than shipping a placeholder table row. Research found no such case: all 33
  modules carry substantive docstrings.
