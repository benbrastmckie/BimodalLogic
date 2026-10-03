# Implementation Plan: Task #563 — the interval site and the behavior presheaf

- **Task**: 563 - formalize_interval_site_and_behavior_presheaf
- **Status**: [IMPLEMENTING]
- **Effort**: 5 hours
- **Dependencies**: None
- **Research Inputs**: `specs/563_formalize_interval_site_and_behavior_presheaf/reports/01_interval-site-behavior-presheaf.md`
- **Artifacts**: plans/01_interval-site-behavior-presheaf.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Site the interval site `Int(D)` and the behavior presheaf `Beh(F)` as a new
`FormalSystem/Semantics/Presheaf/` cluster built on `PartialHistory` (hence strictly below
`Truth.lean`), delivering the section type `Beh F l`, restriction along `Tr p`, presheaf
functoriality (`restrict_id`/`restrict_comp`, and their site-indexed forms
`restrictTr_id`/`restrictTr_comp`), and the Germs clause as `germEquiv : Beh F 0 ≃ F.WorldState`.
Every mathematical obligation is **already compiled sorry-free** in this task's own probes, so the
work is siting, naming, docstrings and gate compliance — not discovery. Definition of done:
three new `.lean` files plus a `README.md`, `lake build FormalSystem` green with no new `sorry`,
and `check-module-invariants.sh` / `readme-lint.sh` / `check-copyright-headers.sh` all green.

### Research Integration

The report at `reports/01_interval-site-behavior-presheaf.md` is integrated wholesale, and it
**corrects the dispatch on four counts** that this plan is built against rather than around:

1. The probe the dispatch names (`specs/553_…/probes/04_presheaf-skeleton.lean`) is **archived**
   and **does not compile**: `ConvexHistory` was deleted (commit `0688a7a3c`) and
   `ShiftSet.wh_ext` removed (commit `60d65a1d3`). The source of record for this plan is
   therefore **`specs/563_formalize_interval_site_and_behavior_presheaf/probes/03_siting-rehearsal.lean`**
   (226 lines, 0 `sorry`, compiles warning-free, exit 0) plus
   `probes/02_site-probe.lean` for the coverage trio — both in this task's own directory.
2. `Beh F l` is a **subtype of `PartialHistory F`**, with convexity derived (`Beh.isConvex`)
   rather than carried as a field. This is forced by the live tree and shrinks the proof.
3. The dispatch's `% TODO: review in full` note on `app:Structure` is **stale**: the appendix is
   now **commented out in its entirety** under an explicit `% SECTION CUT` record, carrying a
   bare `% CHECK`. The module docstrings must flag *that* state, not the weaker TODO wording.
4. The dispatch paraphrases C24 as "every module stays in the root closure"; the actual C24
   assertion is the `FormalSystem.Init` import. Both are satisfied, by different mechanisms
   (explicit `import FormalSystem.Init`; regenerated root).

Two gate prerequisites the report identified are Phase 1 of this plan, deliberately **before**
any docstring exists that cites them: four `KNOWN-ANCHORS` rows (C15) and two `references.bib`
entries (C31). Both go red the moment a citation lands without them.

### Prior Plan Reference

No prior plan. This is round 1 for this task.

### Roadmap Alignment

No `roadmap_path` was provided in this dispatch and no roadmap phases are included. The task's
own position in the categorical front is recorded by the dispatch: this is the cheapest task on
that front and it gates the Sheaf (564), Totality/Directed Gluing, Possible Worlds and
Determinism clauses (565–567), the reflection automorphism (617) and 618; task 616 depends on
`Int(D)` from here for its twisted-arrow isomorphism.

## Goals & Non-Goals

- **Goals**: `comp_shift`, `id_shift`, `id_comp`, `comp_id`, `comp_assoc`, `le_of_hom`,
  `cover_germ_composites`, `partialHistory_ext`, `mem_dom`, `isConvex`, `domain_eq_interval`,
  `restrict_domain`, `restrict_states`, `restrict_id`, `restrict_comp`, `restrictTr_id`,
  `restrictTr_comp`, `germ_ofGerm`, `ofGerm_germ`
- **Goals (not challenge-pinned)**: the definitional carriers, whose bodies the snapshot
  matcher would erase — `Interval`, `Obj`, `Tr`, `Tr.id`, `Tr.comp`, `lres`, `rres`, `coverLeft`,
  `coverRight`, `Beh`, `restrict`, `restrictTr`, `germ`, `ofGerm`, and the Germs clause
  `germEquiv : Beh F 0 ≃ F.WorldState`; the two namespace-local extensionality lemmas `Tr.ext`
  and `Beh.ext`, which share the bare name `ext` and would collide in the challenge module's
  single open namespace; and the plumbing — the cluster aggregator, `Presheaf/README.md`, the
  regenerated library root, the `Semantics.lean` front-door import, the four `KNOWN-ANCHORS`
  rows and the two `references.bib` entries.
- **Non-Goals**: `glue_seam` and the Sheaf clause (task 564 owns `Presheaf/Sheaf.lean`; the port
  is verified in `probes/01_port-probe.lean` and reported there for 564's benefit, not
  implemented here); `BD⁺`, the duration monoid, the twisted-arrow category and
  `lem:interval-twisted-arrow` (task 616, per the dispatch's 2026-10-02 scope correction);
  reflection, the converse frame `F⁻` and the reflection automorphism (task 617); any
  `Mathlib.CategoryTheory` import or `Category` instance; any edit to
  `FormalSystem/Semantics/PartialHistory.lean` (task 565 carries a hard constraint to leave it
  untouched, and consolidating `partialHistory_ext` into it is recorded as a deliberate
  deferral); any row in `docs/theorem-index.md`; any attempt to *pin* the paper anchors, which
  `check-paper-definitions.sh --resolve` structurally cannot do for a commented-out label.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| **C15 red**: `def:interval-site`, `def:behavior-presheaf`, `app:presheaf-dictionary` and `app:Structure` have no row in `docs/reference/paper-definitions-of-record.md`, and all four are unresolvable (the appendix is commented out in full) | H | H (certain, if ordered wrong) | Phase 1 adds all four as **`DANGLING`** rows before any Lean file exists. The record's own definition of `DANGLING` explicitly covers "it was commented out", and requires every in-tree citation to say so **at the citation site** — so each docstring citation carries that fact. Do **not** try to pin: `--resolve` cannot produce text for a commented-out anchor |
| **C15 red via a fifth anchor**: a docstring that mentions any other `app:`/`def:`/`lem:` label from the cut block (`def:conduche`, `def:path-category`, `cor:path-fibration`, `lem:factorization-linear`, `lem:interval-twisted-arrow`) pulls in an unrecorded anchor | M | M | Cite **only** the four anchors Phase 1 records. Verify with `check-module-invariants.sh --no-build` at the end of every Lean phase, not only at the end |
| **C31 red**: `schultz2020` and `johnstone1999` are absent from the root `references.bib` | H | H (certain, if ordered wrong) | Phase 1 appends both, transcribed from the paper's own `possible_worlds.bib` (bibliographic detail in the report's **External Resources**) — no entry is invented, honouring REFERENCE_NORMAL_FORM's prohibition |
| **Stale prose in the anchor record**: the "Twelve new appendix anchors deliberately NOT pinned" paragraph asserts "**None of them is cited anywhere in this repository and none has a Lean counterpart**", which this task falsifies for two of the twelve | M | H (certain) | Phase 1 updates that paragraph in the same edit that adds the rows. Leaving it would make the record state the opposite of the tree |
| **C34b trigger**: `ofGerm`, `germ_ofGerm`, `ofGerm_germ` and `germEquiv` all carry a `[F.IsRegular]` bracketed binder; a `/--` block that pairs a constraint name (`Compositionality`/`Seriality`/`Limit`/`Saturation`, or `Serial`/`Compositional`/`Saturated`) with a negation or consumption word demands a marker line | M | M | Write **no** `Constraints consumed:` marker, and keep every mention of the frame constraints in the `/-!` **module** docstring, whose span C34b does not read. Keep the four declarations' own `/--` blocks free of constraint vocabulary. (The alternative honest discharge — a binder-free twin with a byte-identical signature line — costs ~10 lines and nothing requires it) |
| **C33 red**: three new `.lean` files, and the repository-root `FormalSystem.lean` must be byte-for-byte `lake exe mk_all --lib FormalSystem` | H | H (certain, if skipped) | Regenerate the root in **every** phase that adds a file (Phases 2 and 3), and confirm with `check-module-invariants.sh --no-build` before committing that phase |
| **INV red**: the root `README.md` carries `<!-- BEGIN GENERATED: inventory dir=FormalSystem rows=totals desc=no -->`, whose file and line totals change | M | H (certain) | Phase 4 runs `check-module-invariants.sh --emit-inventory` and then `--emit-inventory --check` to prove no byte would change. The new `Presheaf/README.md` opts into its own block the same way |
| **`readme-lint.sh` check 1 is gated**: every directory containing `.lean` files needs a `README.md`, and check 3 (also gated) requires every relative link in it to resolve | M | M | `Presheaf/README.md` is a Phase 2 deliverable, not a nicety, and lands in the same phase as the first `.lean` file in the directory. Keep its cross-links repository-relative or correctly `../`-depthed and run `readme-lint.sh FormalSystem` in Phases 2, 3 and 4 |
| **Mathlib `linter.style.header` under CI `--wfail`** runs on every module the generated root directly imports, and requires the copyright block, then imports, then the module docstring as the first command | M | M | Copy the header shape from `FormalSystem/Semantics/Ultraproduct/IndexFilter.lean` verbatim (`/- Copyright (c) 2026 … -/`, blank line, imports, `/-! … -/`), and run `bash scripts/check-copyright-headers.sh --strict FormalSystem` in Phase 4 |
| **Namespace collision**: `restrict`, `germ`, `Interval` and `Tr` are generic names; a flat `namespace FormalSystem.Semantics` would shadow-collide `restrict` with `PartialHistory.restrict` | M | M | Use the **nested** `namespace FormalSystem.Semantics.Presheaf`, on the `Semantics/Ultraproduct/` precedent. Verified collision-free by probe 03 |
| **`Beh`'s `rfl`s are fragile to a definitional change**: the domain-side goals discharge by `Iff.rfl`/`rfl` only because the membership condition is a pointwise `Iff` against the *definitional* interval predicate | M | L | Keep the subtype condition as `∀ t, τ.domain t ↔ (0 ≤ t ∧ t ≤ l)`. Do **not** restate it as `τ.val.domain = Interval 0 l`; expose that equality as the derived `Beh.domain_eq_interval` instead |
| **Shared-touch contention on the cluster aggregator**: task 616 will add `Presheaf/Duration.lean` and must then edit `Presheaf.lean`, which the collision gate cannot see | L | M | Unavoidable and accepted: this task *creates* `Presheaf.lean`, and 616 adding one import line to it is the minimal possible contact. Phase 4 deliberately takes the `Semantics.lean` front-door import **now** so that 616 never needs to touch the front aggregator at all — see the Phase 4 note on where this diverges from the report's recommendation |
| **Concurrent sibling on a shared tree**: task 718 is dispatched this same cycle (declared scope `specs/718_omega_sequence_decidability_full_lplus/`) | L | M | No file overlap. Re-read every file immediately before editing it; stage only this task's own hunks with an explicit multi-file `git add -- a b c` (never a directory or glob pathspec); never run `git-snapshot.sh` in its reverting default mode |
| **Foreign uncommitted modifications already in the tree**: `FormalSystem/README.md` and `FormalSystem/Metalogic/README.md` are modified, outside both this task's and 718's scope | L | H (observed) | Already inspected by research: benign "Last verified" date stamps advanced to 2026-10-02 plus a `def:BX` drift note. **Left exactly as found — not reverted, not staged.** Phase 4's inventory re-emit touches the root `README.md` and `FormalSystem/README.md`; stage only the generated-block hunks, and if a conflict appears, STOP and report rather than reconciling |
| **Deployed `.claude/` tree is stale** for `core filetypes formal lean literature memory typst` | L | H (declared) | Every command this plan emits is a repository script under `scripts/`, verified against the repository's own sources, not against a deployed extension file |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |

Phases within the same wave can execute in parallel. This plan is fully sequential by
construction: Phase 2's docstrings cite what Phase 1 records, Phase 3's module imports Phase 2's,
and Phase 4 wires and gates what Phases 2–3 built.

### Phase 1: Gate prerequisites — anchor rows and bibliography [COMPLETED]

**Goal**: Make C15 and C31 able to stay green the moment a docstring cites the paper anchors and
the two published sources. No Lean in this phase.

**Tasks**:
- [x] Append two entries to the root `references.bib`, at the end of the file (the file is
      append-ordered, not alphabetical): `@article{schultz2020, …}` for P. Schultz, D. I. Spivak
      and C. Vasilakopoulou, *Dynamical Systems and Sheaves*, Applied Categorical Structures 28
      (2020), 1–57, doi `10.1007/s10485-019-09565-x`; and `@article{johnstone1999, …}` for
      P. T. Johnstone, *A Note on Discrete Conduché Fibrations*, Theory and Applications of
      Categories 5 (1999), no. 1, 1–11. Transcribe both from the paper's own
      `possible_worlds.bib` as the report records them — invent nothing
- [x] Add four rows inside the `<!-- KNOWN-ANCHORS:BEGIN -->` / `END` fence of
      `docs/reference/paper-definitions-of-record.md`, each with status **`DANGLING`** and a note
      recording that `app:Structure` was cut from the paper in full under an explicit
      `% SECTION CUT` record and carries a bare `% CHECK`: `app:Structure`,
      `app:presheaf-dictionary`, `def:behavior-presheaf`, `def:interval-site`. Keep the block's
      existing ASCII sort order within the `DANGLING` group
- [x] In the same file, amend the "**Twelve new appendix anchors deliberately NOT pinned**"
      paragraph: its claim that "None of them is cited anywhere in this repository and none has a
      Lean counterpart" is falsified for `def:interval-site` and `def:behavior-presheaf` by this
      task. Record that both are now cited, that each has a `DANGLING` `KNOWN-ANCHORS` row, and
      that they are still deliberately unpinned because `--resolve` cannot resolve a
      commented-out label
- [x] Commit this phase on its own, staging exactly the two files with an explicit pathspec list *(deviation: altered — the new rows cite the `FormalSystem/Semantics/Presheaf/` paths that Phases 2-3 create, so **C12** (slash-shaped source paths in `docs/`) reports 5 unresolved paths at the end of this phase alone. Transient by construction: the plan's ordering puts the anchor rows before the citing docstrings, and either ordering carries a one-commit transient — this one lands on C12 rather than on C15. Re-verified green at the end of Phase 3. The pre-existing `check-paper-definitions.sh` `def:BX` drift (`SU` renamed `US` upstream) is unrelated and untouched.)*

**Timing**: 0.75 hours

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: this phase asserts **four** anchors needing rows and **two** bibkeys
needing entries. Confirm at implementation time, after the rows land, by running
`bash scripts/check-module-invariants.sh --no-build` and reading the C15 and C31 lines: C15 must
report zero unknown anchors and C31 zero unresolved keys. The four-anchor count is a hypothesis
about what the Phase 2–3 docstrings will cite; if a docstring ends up naming a fifth label from
the cut block, the row count was an undercount and the row must be added in that phase, not
deferred.

**Files to modify**:
- `references.bib` - append the `schultz2020` and `johnstone1999` entries
- `docs/reference/paper-definitions-of-record.md` - four `DANGLING` `KNOWN-ANCHORS` rows, plus the
  correction to the twelve-anchor paragraph

**Verification**:
- `bash scripts/check-module-invariants.sh --no-build` — C15 and C31 both green (no Lean file
  cites the anchors yet, so this phase can only keep them green, never turn them green; the point
  is to prove the rows parse inside the fence and the bibkeys are well-formed)
- `bash scripts/check-paper-definitions.sh` — still the quiet case-(a) pass, exit 0; adding
  `KNOWN-ANCHORS` rows must not disturb the `FILE_CHECKSUM`/`PINNED_COMMIT` sentinels
- `grep -c '^@' references.bib` reports 79 (was 77)

---

### Phase 2: `Presheaf/Site.lean`, the cluster aggregator and the README [COMPLETED]

**Goal**: The interval site `Int(D)` lands as a module stated over a bare `TemporalOrder` with no
task frame, beside a Tier-1 sibling aggregator and a gated `README.md`, with the library root
regenerated.

**Tasks**:
- [x] Create `FormalSystem/Semantics/Presheaf/Site.lean`: copyright block, then
      `import FormalSystem.Init` and `import FormalSystem.Semantics.TemporalOrder`, then a
      **Tier-3** module docstring (Title + scope paragraph, `## Main Definitions`,
      `## Main Results`, `## Implementation Notes`, `## References`, in that order per
      `docs/reference/docstring-standard.md`), then
      `namespace FormalSystem.Semantics.Presheaf`
- [x] Lift the site content verbatim from `probes/03_siting-rehearsal.lean`'s Site rehearsal plus
      `probes/02_site-probe.lean`'s coverage trio: `Interval`, `Obj`, `Tr` (+ `Tr.ext`), `Tr.id`,
      `Tr.comp`, `@[simp] comp_shift`, `@[simp] id_shift`, `id_comp`, `comp_id`, `comp_assoc`,
      `le_of_hom`, `lres`, `rres`, `coverLeft`, `coverRight`, `cover_germ_composites`. Give every
      public declaration a `/--` docstring
- [x] Record the **concrete-structures decision** in `Site.lean`'s `## Implementation Notes`: no
      `Mathlib.CategoryTheory` dependency, because the live tree imports no category theory at
      all, `def:interval-site`'s content is three composition laws plus a coverage, and the
      concrete route keeps `Site.lean` buildable from `TemporalOrder` alone. State that the
      decision is **reversible without changing any definition** — `Tr.id`/`Tr.comp`/`id_comp`/
      `comp_id`/`comp_assoc` are exactly a `Category` instance's fields — and that task 616's own
      plan should reconcile with this rather than re-litigate it (name the decision by its content
      in the docstring, never by a task number: `.claude/rules/no-task-references-in-deliverables.md`
      forbids task-number citations under `FormalSystem/`, and C9 gates it)
- [x] Record the **paper-state flag** in `Site.lean`'s docstring: `app:Structure` is commented out
      in the paper in full under an explicit `% SECTION CUT` record and carries a bare `% CHECK`,
      so `def:interval-site` and `app:presheaf-dictionary` resolve against
      `docs/reference/paper-definitions-of-record.md` and not against a live `\label{}`, and the
      material is unreviewed by the author
- [x] Write `## References` in the normal form of `docs/development/REFERENCE_NORMAL_FORM.md`:
      bibliographic entries as `* [P. Schultz, D. I. Spivak and C. Vasilakopoulou, *Dynamical
      Systems and Sheaves*][schultz2020], Defs. 3.1.1–3.1.2, Notation 3.1.7, Defs. 3.2.1–3.2.2`
      and the Johnstone entry; paper anchors as `* JPL paper \`def:interval-site\` — …` with the
      `DANGLING` fact stated at the citation site; module cross-references as backticked
      repository-relative paths
- [x] End the file with
      `assert_not_exists FormalSystem.ProofSystem.Axiom FormalSystem.ProofSystem.DerivationTree`,
      after the closing `end FormalSystem.Semantics.Presheaf` — this **locks** the layering
      positively (it was never at risk, since nothing imports the cluster into `Truth.lean`).
      Precedent: `TaskFrame.lean`, `FrameProperty.lean`, `TruthTransport.lean`
- [x] Create `FormalSystem/Semantics/Presheaf.lean`: copyright block, `import
      FormalSystem.Semantics.Presheaf.Site`, and a **Tier-1** aggregator docstring with a
      `## Modules` list, on the `FormalSystem/Semantics/Ultraproduct.lean` pattern. (C8 requires
      exactly this sibling file and forbids `Presheaf/Presheaf.lean`)
- [x] Create `FormalSystem/Semantics/Presheaf/README.md` to the required sections of
      `docs/reference/readme-standard.md`: `# Presheaf` title, scope paragraph, a module inventory
      wrapped in `<!-- BEGIN GENERATED: inventory dir=FormalSystem/Semantics/Presheaf -->` /
      `<!-- END GENERATED -->`, Key Definitions and Results, a cross-links footer whose every
      relative link resolves, and a `*Last verified: YYYY-MM-DD*` line
- [x] Regenerate the library root: `lake exe mk_all --lib FormalSystem`
- [x] Emit the inventory block: `bash scripts/check-module-invariants.sh --emit-inventory`
- [x] Commit, staging exactly this phase's files plus `FormalSystem.lean` *(deviation: altered — Phase 4's two `FormalSystem/Semantics/README.md` `## Contents` rows were pulled forward into this phase and staged here. The gated **INV** check reports `Presheaf.lean is live but has no row` / `Presheaf/ is live but has no row` the moment the cluster exists, so Phase 2 cannot end green without them. Same final state, earlier commit; Phase 4 keeps the `Semantics.lean` import and the two regenerated inventory blocks.)*

**Timing**: 1.5 hours

**Depends on**: 1

**Verification Tier**: full

**Scope Hypothesis**: this phase asserts **17 declarations** in `Site.lean` (the list above) and
roughly **120 lines of Lean plus a ~60-line docstring**. Confirm by
`grep -cE '^\s*(@\[[^]]*\]\s*)?(theorem|def|abbrev|structure)\b' FormalSystem/Semantics/Presheaf/Site.lean`
against the enumerated list, and by `wc -l`. An overcount closes as a Reasoned Exclusion; an
undercount means a declaration the probes carry was dropped and must be restored.

**Files to modify**:
- `FormalSystem/Semantics/Presheaf/Site.lean` - new: the interval site `Int(D)`
- `FormalSystem/Semantics/Presheaf.lean` - new: Tier-1 cluster aggregator
- `FormalSystem/Semantics/Presheaf/README.md` - new: directory README with a gated inventory block
- `FormalSystem.lean` - regenerated by `lake exe mk_all --lib FormalSystem`

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem` — exit 0
- No new `sorry`: `grep -rn 'sorry' FormalSystem/Semantics/Presheaf/` returns nothing
- `bash scripts/check-module-invariants.sh --no-build` — C8, C9, C15, C26, C31, C33 and INV all
  green
- `bash scripts/readme-lint.sh FormalSystem` — exit 0 (check 1 and check 3 are the gated ones)
- `lake env lean` on the file compiles warning-free, so no `scripts/warning-budget.txt` row is
  needed

---

### Phase 3: `Presheaf/Behavior.lean` — the sections, the presheaf action and the Germs clause [COMPLETED]

**Goal**: `Beh F l`, restriction along `Tr p`, presheaf functoriality in both the raw-data and
the site-indexed forms, and `Beh(F)(0) ≃ W` land as a module, and the cluster aggregator reaches
them.

**Tasks**:
- [x] Create `FormalSystem/Semantics/Presheaf/Behavior.lean`: copyright block, then
      `import FormalSystem.Init`, `import FormalSystem.Semantics.PartialHistory` and
      `import FormalSystem.Semantics.Presheaf.Site`, then a **Tier-3** module docstring, then
      `namespace FormalSystem.Semantics.Presheaf`
- [x] Lift verbatim from `probes/03_siting-rehearsal.lean`'s Behavior rehearsal:
      `partialHistory_ext`; then under `namespace Beh` — `Beh`, `mem_dom`, `isConvex`,
      `domain_eq_interval`, `restrict`, `restrict_domain`, `restrict_states`, `ext`,
      `restrict_id`, `restrict_comp`, `restrictTr`, `restrictTr_id`, `restrictTr_comp`, `germ`,
      `ofGerm`, `germ_ofGerm`, `ofGerm_germ`, `germEquiv`. Give every public declaration a `/--`
      docstring
- [x] Keep `Beh`'s subtype condition as the pointwise `Iff`
      `∀ t, τ.domain t ↔ (0 ≤ t ∧ t ≤ l)`. The domain-side obligations of `restrict`, `ofGerm`
      and `restrict_domain` discharge by `Iff.rfl`/`rfl` **only** in this form; restating it as a
      domain equality breaks them. `Beh.domain_eq_interval` is the derived equality
- [x] Keep the `/--` blocks of `ofGerm`, `germ_ofGerm`, `ofGerm_germ` and `germEquiv` free of the
      constraint vocabulary (`Compositionality`, `Seriality`, `Limit`, `Saturation`, `Serial`,
      `Compositional`, `Saturated`) and write **no** `Constraints consumed:` marker. All four
      carry an `[F.IsRegular]` binder, which is exactly C34b's trigger population; put the
      `*Seriality*`/`*Limit*` discussion in the `/-!` module docstring, whose span C34b does not
      read
- [x] Record in `## Implementation Notes`: (a) `partialHistory_ext` lives here rather than in
      `PartialHistory.lean` — a **deliberate deferral**, because the history module is outside
      this cluster's remit and a sibling task carries a hard constraint to leave it untouched;
      the deleted `ShiftSet.wh_ext` had already called the consolidation "a clean follow-up";
      (b) Lean generates no `PartialHistory.ext`, because the `states` field is dependent on
      `domain`, which is why a local extensionality lemma is needed at all; (c) convexity is
      *derived* (`Beh.isConvex`), not a field, because `PartialHistory.lean` deliberately carries
      convexity as a predicate and there is no `ConvexHistory` structure; (d) `restrict_id` and
      `restrict_comp` are genuinely new content at the partial-history level — `ShiftSet`'s
      `ts_zero`/`ts_add` are the corresponding facts for **total** histories only
- [x] Write `## References` in normal form, with the `def:behavior-presheaf` anchor cited as
      `DANGLING` at the citation site and `[…][schultz2020]` §3.2 Def. 3.2.1 for the source
- [x] End the file with the same `assert_not_exists` pair as `Site.lean`
- [x] Add `import FormalSystem.Semantics.Presheaf.Behavior` to
      `FormalSystem/Semantics/Presheaf.lean` and extend its `## Modules` list
- [x] Update `FormalSystem/Semantics/Presheaf/README.md`'s Key Definitions / Key Results for the
      new module
- [x] Regenerate the library root (`lake exe mk_all --lib FormalSystem`) and re-emit the
      inventory block (`check-module-invariants.sh --emit-inventory`)
- [x] Commit, staging exactly this phase's files plus `FormalSystem.lean` *(deviation: altered — two extra files staged. `typst/generated/status.typ`: the pre-commit `typst-sync-check.sh` Check 2 gate blocks any commit that changes the live `.lean` file/line counts without regenerating it, so it is regenerated (`--fix`) and staged in every phase that adds a module. `FormalSystem/Semantics/README.md`: its `Presheaf/` row, pulled forward in Phase 2, is extended here for `Behavior.lean`. Also: the probe's two `show` tactic calls fired `linter.style.show` twice under the library's lean options, falsifying the phase's warning-free premise; both are now `change` — the linter's own remedy, identical tactic semantics — so C28 is green and no `scripts/warning-budget.txt` row was added.)*

**Timing**: 1.5 hours

**Depends on**: 2

**Verification Tier**: full

**Scope Hypothesis**: this phase asserts **18 declarations** in `Behavior.lean` (the list above)
and roughly **130 lines of Lean plus a ~70-line docstring**, every proof already compiled in
probe 03. Confirm the declaration count the same way as Phase 2, and confirm the "already
proved" premise by diffing the lifted proof terms against
`probes/03_siting-rehearsal.lean` — any proof that needs *new* tactic work is a signal that the
lift drifted and should be re-read against the probe rather than re-proved.

**Files to modify**:
- `FormalSystem/Semantics/Presheaf/Behavior.lean` - new: `Beh`, the presheaf action, the Germs
  clause
- `FormalSystem/Semantics/Presheaf.lean` - add the `Behavior` import and its `## Modules` entry
- `FormalSystem/Semantics/Presheaf/README.md` - Key Definitions / Key Results for `Behavior.lean`
- `FormalSystem.lean` - regenerated by `lake exe mk_all --lib FormalSystem`

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem` — exit 0
- No new `sorry` anywhere under `FormalSystem/Semantics/Presheaf/`
- `bash scripts/check-module-invariants.sh --no-build` — C8, C9, C15, C26, C31, C33, C34a, C34b
  and INV all green
- `bash scripts/readme-lint.sh FormalSystem` — exit 0
- Spot-check the four deliverables the dispatch names actually exist and are sorry-free:
  `#print axioms FormalSystem.Semantics.Presheaf.Beh.restrict_id` and the same for
  `restrict_comp`, `restrictTr_comp`, `germEquiv` (equivalently
  `lean_verify` on each fully qualified name)

---

### Phase 4: Front-door wiring, inventory re-emit and the full gate pass [NOT STARTED]

**Goal**: The cluster is reachable from the `Semantics` front aggregator and documented in its
Contents table, every generated inventory block in the tree is byte-current, and the whole gate
surface is green with the task's own evidence recorded.

**Note on a deliberate divergence from the research report.** The report recommended leaving
`FormalSystem/Semantics.lean` and `FormalSystem/Semantics/README.md` untouched, to keep
aggregator contention in one place. This plan takes both now, for a reason the report's own
analysis supports: the contention the report is guarding against is on the **cluster** aggregator
`Presheaf.lean`, which a follow-on duration-monoid task must edit in any case, and taking the
front-door import here means that task never has to touch the **front** aggregator at all. The
import is also weightless — the cluster needs only `Init` and `PartialHistory`, carries no
`Mathlib.Topology`-style payload, and sits strictly below `Truth.lean` — so the import-weight
rationale that keeps `StateTopology/` deliberately outside this aggregator does not apply. Both
files are therefore declared in **Files to modify** as an explicit `file_scope` widening, on top
of Phase 1's.

**Tasks**:
- [ ] Re-read `FormalSystem/Semantics.lean` immediately before editing (a sibling task is live in
      this tree this cycle), then add `import FormalSystem.Semantics.Presheaf` in the aggregator's
      existing ordering, below the `PartialHistory` imports it depends on
- [ ] Extend the `## Submodules` prose in `FormalSystem/Semantics.lean`'s docstring with one
      sentence locating the cluster
- [ ] Add two rows to `FormalSystem/Semantics/README.md`'s hand-maintained `## Contents` table —
      `Presheaf.lean` (aggregator) and `Presheaf/` (the cluster) — matching the shape of the
      existing `Ultraproduct.lean` / `Ultraproduct/` pair. Re-read this file immediately before
      editing: it is **not** one of the two files already modified in the working tree, but
      `FormalSystem/README.md` (which Phase 4 also touches, via the generated block) **is**
- [ ] Run `bash scripts/check-module-invariants.sh --emit-inventory`, then
      `bash scripts/check-module-invariants.sh --emit-inventory --check` and confirm it reports
      that no rewrite would change a byte. The root `README.md`'s
      `rows=totals` block and `FormalSystem/README.md`'s `rows=loose` block are both in scope of
      the emit; stage **only** the generated-block hunks in `FormalSystem/README.md`, never the
      pre-existing foreign "Last verified" modification
- [ ] Run the full gate set below and record each exit code in the task summary
- [ ] Commit, staging exactly this phase's files

**Timing**: 1.25 hours

**Depends on**: 3

**Verification Tier**: full

**Scope Hypothesis**: this phase asserts that exactly **two** generated inventory blocks change
(`README.md` `rows=totals`, and `FormalSystem/README.md` `rows=loose` only if the loose-file set
at the `FormalSystem` root changed — it should **not**, since all three new files are nested).
Confirm by running the emit and reading `git diff --stat` before staging: a third changed block,
or a changed `rows=loose` table, means the hypothesis was wrong and the diff must be read in full
before anything is committed.

**Files to modify**:
- `FormalSystem/Semantics.lean` - add the `Presheaf` import and a `## Submodules` sentence
- `FormalSystem/Semantics/README.md` - two `## Contents` rows
- `README.md` - regenerated `rows=totals` inventory block
- `FormalSystem/README.md` - regenerated inventory block, if and only if the emit changes it

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem` — exit 0
- `bash scripts/check-module-invariants.sh` — full pass **with** the build, exit 0 (this is the
  run that exercises C1/C2/C6/C16/C24/C25/C36b, which `--no-build` skips)
- `bash scripts/check-module-invariants.sh --emit-inventory --check` — exit 0, no byte would change
- `bash scripts/readme-lint.sh FormalSystem` — exit 0
- `bash scripts/check-copyright-headers.sh --strict FormalSystem` — exit 0
- `bash scripts/check-paper-definitions.sh` — exit 0
- Zero `sorry` and zero new axiom under `FormalSystem/Semantics/Presheaf/`

---

## Lean Challenge Statements

**Authoring note.** The snapshot matcher recognizes `theorem|lemma|def|instance` followed by a
*simple* name, forces that body to `sorry`, and discards everything between the `:=` and the next
matched declaration. The block below is shaped so nothing is lost: every definitional carrier
sits in the **preamble**, before the first `theorem`, and is written as `abbrev` or `structure`
(neither is matched, so bodies survive and they stay out of the identifier set). The library
declares each carrier with `def` instead — `Obj` stays an `abbrev` there too. No pinned theorem
name is dotted, and no `namespace`/`end` sits between two theorems, so the final namespace is
left open on purpose; in the library the site theorems live in
`FormalSystem.Semantics.Presheaf.Tr` and the behavior theorems in
`FormalSystem.Semantics.Presheaf.Beh`, with `partialHistory_ext` at
`FormalSystem.Semantics.Presheaf`. Binder names are immaterial; binder types, hypotheses and
conclusions are the contract.

Two deliberate absences, both named under **Goals (not challenge-pinned)**: the extensionality
lemmas `Tr.ext` and `Beh.ext` share the bare name `ext` and would collide here, and `germEquiv`
is an `Equiv`-valued `def` whose body the matcher would erase.

**Verified**: this exact block was compiled against the live tree with `lake env lean` and
returns exit 0 with 19 `declaration uses 'sorry'` warnings and no errors — one per pinned
identifier, and no more.

```lean
import FormalSystem.Init
import FormalSystem.Semantics.PartialHistory

namespace FormalSystem.Semantics.Presheaf

variable {D : TemporalOrder}

/-- Challenge carrier; `def` in the library. -/
abbrev Interval (p q : ↑D) : ↑D → Prop := fun z => p ≤ z ∧ z ≤ q

/-- Challenge carrier; `abbrev` in the library too. -/
abbrev Obj (D : TemporalOrder) : Type := TemporalOrder.PositiveCone D

/-- Challenge carrier; `structure` in the library too. -/
structure Tr (l' l : Obj D) where
  shift : ↑D
  shift_nonneg : 0 ≤ shift
  shift_add_le : shift + l'.val ≤ l.val

namespace Tr

/-- Challenge carrier; `def` in the library. -/
abbrev id (l : Obj D) : Tr l l := ⟨0, le_refl 0, by rw [zero_add]⟩

/-- Challenge carrier; `def` in the library. -/
abbrev comp {l'' l' l : Obj D} (f : Tr l' l) (g : Tr l'' l') : Tr l'' l :=
  ⟨f.shift + g.shift, add_nonneg f.shift_nonneg g.shift_nonneg, by
    calc f.shift + g.shift + l''.val = f.shift + (g.shift + l''.val) := by rw [add_assoc]
      _ ≤ f.shift + l'.val := add_le_add (le_refl _) g.shift_add_le
      _ ≤ l.val := f.shift_add_le⟩

end Tr

/-- Challenge carrier; `def` in the library. -/
abbrev lres {l l' : Obj D} (h : l'.val ≤ l.val) : Tr l' l :=
  ⟨0, le_refl 0, by rw [zero_add]; exact h⟩

/-- Challenge carrier; `def` in the library. -/
abbrev rres {l l' : Obj D} (h : l'.val ≤ l.val) : Tr l' l :=
  ⟨l.val - l'.val, sub_nonneg.mpr h, by rw [sub_add_cancel]⟩

/-- Challenge carrier; `def` in the library. -/
abbrev coverLeft (l : Obj D) (p : ↑D) (hp : 0 ≤ p) (hpl : p ≤ l.val) : Tr ⟨p, hp⟩ l :=
  ⟨0, le_refl 0, by rw [zero_add]; exact hpl⟩

/-- Challenge carrier; `def` in the library. -/
abbrev coverRight (l : Obj D) (p : ↑D) (hp : 0 ≤ p) (hpl : p ≤ l.val) :
    Tr ⟨l.val - p, sub_nonneg.mpr hpl⟩ l :=
  ⟨p, hp, by rw [add_sub_cancel]⟩

variable {F : TaskFrame}

/-- Challenge carrier; `def` in the library. -/
abbrev Beh (F : TaskFrame) (l : F.Duration) : Type :=
  { τ : PartialHistory F // ∀ t, τ.domain t ↔ (0 ≤ t ∧ t ≤ l) }

/-- Challenge carrier; `def` in the library. -/
abbrev restrict {l : F.Duration} (p l' : F.Duration) (hp : 0 ≤ p) (hl' : 0 ≤ l')
    (hple : p + l' ≤ l) (τ : Beh F l) : Beh F l' :=
  ⟨{ domain := fun z => 0 ≤ z ∧ z ≤ l'
     nonempty_domain := ⟨0, le_refl 0, hl'⟩
     states := fun z hz =>
       τ.val.states (p + z) ((τ.property (p + z)).mpr
         ⟨add_nonneg hp hz.1, le_trans (add_le_add (le_refl p) hz.2) hple⟩)
     respects_task := by
       intro s t hs ht
       have h := τ.val.respects_task (p + s) (p + t)
         ((τ.property (p + s)).mpr
           ⟨add_nonneg hp hs.1, le_trans (add_le_add (le_refl p) hs.2) hple⟩)
         ((τ.property (p + t)).mpr
           ⟨add_nonneg hp ht.1, le_trans (add_le_add (le_refl p) ht.2) hple⟩)
       rwa [add_sub_add_left_eq_sub] at h },
   fun _ => Iff.rfl⟩

/-- Challenge carrier; `def` in the library. -/
abbrev restrictTr {l' l : Obj F.Duration} (f : Tr l' l) (τ : Beh F l.val) : Beh F l'.val :=
  restrict f.shift l'.val f.shift_nonneg l'.property f.shift_add_le τ

/-- Challenge carrier; `def` in the library. -/
abbrev germ (τ : Beh F 0) : F.WorldState :=
  τ.val.states 0 ((τ.property 0).mpr ⟨le_refl 0, le_refl 0⟩)

/-- Challenge carrier; `def` in the library. -/
abbrev ofGerm (F : TaskFrame) [F.IsRegular] (w : F.WorldState) : Beh F 0 :=
  ⟨{ domain := fun t => 0 ≤ t ∧ t ≤ 0
     nonempty_domain := ⟨0, le_refl 0, le_refl 0⟩
     states := fun _ _ => w
     respects_task := by
       intro s t hs ht
       have hs0 : s = 0 := le_antisymm hs.2 hs.1
       have ht0 : t = 0 := le_antisymm ht.2 ht.1
       subst hs0; subst ht0
       simpa [sub_self] using (F.nullity_identity w w).mpr rfl },
   fun _ => Iff.rfl⟩

/-! Pinned statements begin here. -/

theorem comp_shift {l'' l' l : Obj D} (f : Tr l' l) (g : Tr l'' l') :
    (Tr.comp f g).shift = f.shift + g.shift := sorry

theorem id_shift (l : Obj D) : (Tr.id l).shift = 0 := sorry

theorem id_comp {l' l : Obj D} (f : Tr l' l) : Tr.comp (Tr.id l) f = f := sorry

theorem comp_id {l' l : Obj D} (f : Tr l' l) : Tr.comp f (Tr.id l') = f := sorry

theorem comp_assoc {l₃ l₂ l₁ l : Obj D} (f : Tr l₁ l) (g : Tr l₂ l₁) (h : Tr l₃ l₂) :
    Tr.comp (Tr.comp f g) h = Tr.comp f (Tr.comp g h) := sorry

theorem le_of_hom {l' l : Obj D} (f : Tr l' l) : l'.val ≤ l.val := sorry

theorem cover_germ_composites (l : Obj D) (p : ↑D) (hp : 0 ≤ p) (hpl : p ≤ l.val) :
    (Tr.comp (coverLeft l p hp hpl) (rres (l' := (⟨0, le_refl 0⟩ : Obj D)) hp)).shift
      = (Tr.comp (coverRight l p hp hpl)
          (lres (l' := (⟨0, le_refl 0⟩ : Obj D)) (sub_nonneg.mpr hpl))).shift := sorry

theorem partialHistory_ext {σ τ : PartialHistory F} (hd : σ.domain = τ.domain)
    (hs : ∀ (r : F.Duration) (h : σ.domain r) (h' : τ.domain r), σ.states r h = τ.states r h') :
    σ = τ := sorry

theorem mem_dom {l : F.Duration} (τ : Beh F l) {t : F.Duration} (h0 : 0 ≤ t) (hl : t ≤ l) :
    τ.val.domain t := sorry

theorem isConvex {l : F.Duration} (τ : Beh F l) : τ.val.IsConvex := sorry

theorem domain_eq_interval {l : F.Duration} (τ : Beh F l) : τ.val.domain = Interval 0 l := sorry

theorem restrict_domain {l : F.Duration} (p l' : F.Duration) (hp : 0 ≤ p) (hl' : 0 ≤ l')
    (hple : p + l' ≤ l) (τ : Beh F l) (z : F.Duration) :
    (restrict p l' hp hl' hple τ).val.domain z = (0 ≤ z ∧ z ≤ l') := sorry

theorem restrict_states {l : F.Duration} (p l' : F.Duration) (hp : 0 ≤ p) (hl' : 0 ≤ l')
    (hple : p + l' ≤ l) (τ : Beh F l) (z : F.Duration)
    (hz : (restrict p l' hp hl' hple τ).val.domain z) (hpz : τ.val.domain (p + z)) :
    (restrict p l' hp hl' hple τ).val.states z hz = τ.val.states (p + z) hpz := sorry

theorem restrict_id {l : F.Duration} (hl : 0 ≤ l) (τ : Beh F l) :
    restrict 0 l (le_refl 0) hl (by rw [zero_add]) τ = τ := sorry

theorem restrict_comp {l : F.Duration} (p l' p' l'' : F.Duration)
    (hp : 0 ≤ p) (hl' : 0 ≤ l') (hple : p + l' ≤ l)
    (hp' : 0 ≤ p') (hl'' : 0 ≤ l'') (hple' : p' + l'' ≤ l')
    (τ : Beh F l) :
    restrict p' l'' hp' hl'' hple' (restrict p l' hp hl' hple τ)
      = restrict (p + p') l'' (add_nonneg hp hp') hl''
          (by
            rw [add_assoc]
            exact le_trans (add_le_add (le_refl p) hple') hple) τ := sorry

theorem restrictTr_id {l : Obj F.Duration} (τ : Beh F l.val) :
    restrictTr (Tr.id l) τ = τ := sorry

theorem restrictTr_comp {l'' l' l : Obj F.Duration} (f : Tr l' l) (g : Tr l'' l')
    (τ : Beh F l.val) :
    restrictTr (Tr.comp f g) τ = restrictTr g (restrictTr f τ) := sorry

theorem germ_ofGerm (F : TaskFrame) [F.IsRegular] (w : F.WorldState) :
    germ (ofGerm F w) = w := sorry

theorem ofGerm_germ [F.IsRegular] (τ : Beh F 0) : ofGerm F (germ τ) = τ := sorry
```

## Testing & Validation

- [ ] `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem` exits
      0 at the end of Phases 2, 3 and 4 (baseline of record: exit 0, 2807 jobs)
- [ ] Zero `sorry` and zero new axiom under `FormalSystem/Semantics/Presheaf/`, confirmed by grep
      and by `lean_verify` / `#print axioms` on `Beh.restrict_id`, `Beh.restrict_comp`,
      `Beh.restrictTr_comp` and `Beh.germEquiv`
- [ ] `bash scripts/check-module-invariants.sh` full pass (with build) exits 0 — the
      task-specific rows are C8 (sibling aggregator, no `Presheaf/Presheaf.lean`), C9 (no
      task-number citation under `FormalSystem/`), C15 (all four anchors recorded), C24 (`Init`
      import), C26 (no non-trailing underscore in a `def`/`abbrev` name), C31 (both bibkeys
      resolve), C33 (root byte-current), C34a/C34b (no constraint-claim marker needed), INV
      (generated blocks current)
- [ ] `bash scripts/check-module-invariants.sh --emit-inventory --check` exits 0
- [ ] `bash scripts/readme-lint.sh FormalSystem` exits 0 (checks 1 and 3 are gated; check 2's
      `NOT LISTED` and check 4's date warnings are reported, not gated)
- [ ] `bash scripts/check-copyright-headers.sh --strict FormalSystem` exits 0
- [ ] `bash scripts/check-paper-definitions.sh` exits 0, still the quiet case-(a) pass
- [ ] The layering lock holds: both new modules end with
      `assert_not_exists FormalSystem.ProofSystem.Axiom FormalSystem.ProofSystem.DerivationTree`
      and the build accepts it, so the cluster is provably below `Truth.lean`
- [ ] No `scripts/warning-budget.txt` row is added — both modules compile warning-free

## Artifacts & Outputs

- `FormalSystem/Semantics/Presheaf/Site.lean` — the interval site `Int(D)`: `Interval`, `Obj`,
  `Tr` (+ `ext`, `id`, `comp`, `comp_shift`, `id_shift`, `id_comp`, `comp_id`, `comp_assoc`,
  `le_of_hom`), `lres`, `rres`, `coverLeft`, `coverRight`, `cover_germ_composites`
- `FormalSystem/Semantics/Presheaf/Behavior.lean` — `partialHistory_ext`, `Beh` and its API
  (`mem_dom`, `isConvex`, `domain_eq_interval`, `ext`), the presheaf action (`restrict`,
  `restrict_domain`, `restrict_states`, `restrict_id`, `restrict_comp`, `restrictTr`,
  `restrictTr_id`, `restrictTr_comp`), and the Germs clause (`germ`, `ofGerm`, `germ_ofGerm`,
  `ofGerm_germ`, `germEquiv`)
- `FormalSystem/Semantics/Presheaf.lean` — Tier-1 cluster aggregator
- `FormalSystem/Semantics/Presheaf/README.md` — directory README with a gated inventory block
- `FormalSystem.lean` — regenerated library root (3 new import lines)
- `references.bib` — two new entries (`schultz2020`, `johnstone1999`)
- `docs/reference/paper-definitions-of-record.md` — four `DANGLING` `KNOWN-ANCHORS` rows and the
  corrected twelve-anchor paragraph
- `FormalSystem/Semantics.lean`, `FormalSystem/Semantics/README.md` — front-door import and
  Contents rows
- `README.md` (and `FormalSystem/README.md` if the emit changes it) — regenerated inventory blocks
- `specs/563_formalize_interval_site_and_behavior_presheaf/summaries/01_interval-site-behavior-presheaf-summary.md`

## Rollback/Contingency

Every phase ends green and is committed on its own, so the contingency for a failed phase is to
leave the previous phase's commit standing and stop — never a whole-task revert.

- **Phase 1 fails** (a row or entry does not parse): the two files are text-only and the edit is
  additive; remove the added lines and re-run
  `bash scripts/check-module-invariants.sh --no-build`.
- **Phase 2 or 3 fails to build**: the new files are *new*, so deletion is a complete rollback —
  remove the file, re-run `lake exe mk_all --lib FormalSystem`, and the tree returns to the
  previous phase's state. Prefer this to editing a half-lifted module back into shape.
- **Phase 4 fails**: the two front-door edits are one import line and two table rows; revert those
  hunks and re-run the emit.
- **If an uncommitted-work rollback is genuinely needed** (not a routine checkpoint): take a
  snapshot first per `context/contracts/recovery.md`'s rollback rung, which names the invocation
  shape and its out-of-scope override flag, then run the destructive command. Do **not** emit a
  bare reverting `git-snapshot.sh` as a precaution; a defensive, non-reverting checkpoint before
  risky work is `bash .claude/scripts/git-snapshot.sh 563 --no-revert`.
- **Territory caution**: a sibling task is live in this working tree this cycle, and two
  `README.md` files carry pre-existing foreign modifications. A rollback that discards
  working-tree changes would take those with it. Stage and revert by explicit pathspec only, and
  if a foreign commit or an unexplained modification appears, STOP and report it after checking
  `git log` rather than reconciling it.
