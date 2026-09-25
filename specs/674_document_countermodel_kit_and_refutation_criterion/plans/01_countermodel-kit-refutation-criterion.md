# Implementation Plan: Task #674

- **Task**: 674 - Document the countermodel-construction kit and the frame-level refutation criterion in `FormalSystem/Metalogic/Independence/README.md`
- **Status**: [NOT STARTED]
- **Effort**: 3.0 hours
- **Dependencies**: Task 671 (remaining-rows sharpness work, already landed; README read as reconciled)
- **Research Inputs**: specs/674_document_countermodel_kit_and_refutation_criterion/reports/01_countermodel-kit-refutation-criterion.md
- **Artifacts**: plans/01_countermodel-kit-refutation-criterion.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Two new `##` sections are added to `FormalSystem/Metalogic/Independence/README.md`, inserted
between `## Key Results` and `## Dependencies`: a countermodel-construction kit (what to reach
for first, what to avoid, and three hard-won specifics) and a stated criterion for when
frame-level refutation is obstructed. The work is Markdown-only — no `.lean` file is edited, no
theorem is added or restated, and no `lake build` is run. The research round resolved every
declaration name against the tree and identified the one real gate risk (C20 tier 2 forbids
`file.lean:NNN` citations in any README under `FormalSystem/`), so the plan writes name-only
citations and closes with the gate suite.

### Research Integration

The research report supplies the verified declaration inventory (Finding 1), the corrected
fallback-route paths (Finding 3), the exact location of the frame-versus-model obstruction
(Finding 4), the gate coupling measured on the current tree (Finding 6), and the README's
present shape (Finding 7). Four of its findings change what the dispatch asked for, and this
plan adopts all four:

1. **No line numbers** (report R1/D1). The dispatch asks for line numbers; C20 tier 2 is gated by
   default and its `publication_scope` predicate covers every `README.md` under `FormalSystem/`.
   The current violation count in scope is zero. Citations are declaration names plus bare file
   names, and — where a docstring section is the target — the section heading. This serves the
   dispatch's actual requirement (actionable without opening task artifacts) and keeps the gate
   green.
2. **The clock frame is only half a dead end** (report R3/D2). Machine-checked this round: the
   clock frame validates `Axiom.z1` but *refutes* `Axiom.prior_UZ` via `CoNotPriorU.lean`'s own
   `clockModel` arc valuation. Writing the dispatch's symmetric "both frames validate both
   targets" claim would install a false warning. The section states the asymmetry.
3. **`Metalogic/Conservativity/MinusLanguageSoundness.lean` does not exist** (report D3).
   `minus_soundness_ztime_succ` lives in `FormalSystem/MinusLanguage/Soundness.lean`. The dotted
   form of the non-existent path would additionally fail check C5.
4. **INV is not the gate at risk** (report D4). The generated inventory blocks count `.lean` files
   only, so a Markdown-only edit cannot move a count. `--emit-inventory` is still run as a cheap
   (~1s) idempotent no-op, because the dispatch names it and it removes the question.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` was supplied in the dispatch context; no roadmap consultation was performed.

## Goals & Non-Goals

**Goals**:
- A `## Building a countermodel: what to reach for first` section that names the default route
  (`translationFrame` / `translationHist` / `translationModel` plus the `translation_realizes`
  layer), the L⁻ transfer as the explicitly-labelled fallback, the two dead-end frames stated
  accurately, and the three hard-won specifics (non-discreteness, shape pinning, `by decide` on
  `<`).
- A `## When frame-level refutation is obstructed, and when it is not` section stating the
  criterion as a criterion, with the operational consequence: choose the statement form before
  the proof starts.
- Both sections actionable from declaration names alone, with zero `file.lean:NNN` citations,
  zero task-number citations, and zero dotted module names that do not resolve.
- `scripts/check-module-invariants.sh` green, `scripts/readme-lint.sh` PASS, inventory blocks
  regenerated.

**Non-Goals**:
- Editing any `.lean` file, adding any theorem, or landing either of the research round's two
  verification probes.
- Creating a root `.context/` directory, or writing into the agent-system source store at
  `~/.config/nvim/agent-system`.
- Promoting the Section 2 criterion to the formal extension's logic domain (explicitly deferred
  by the dispatch's SCOPE paragraph to a later `/meta` round).
- Repointing the two stale `MinusLanguageSoundness.lean` docstring citations in
  `Metalogic/Conservativity.lean` and `Metalogic.lean` — that requires `.lean` edits and belongs
  to a separate task.
- Running `lake build`. The full invariants suite already exercises C1 against the built tree.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| A `file.lean:NNN` citation slips in and C20 tier 2 turns red | H | M | Phase 2 and 3 each close with a targeted grep for the C20 `CITE` pattern over the README; Phase 4's full run is the backstop, and the repair is mechanical (drop `:NNN`, keep the name) |
| The clock-frame paragraph repeats the dispatch verbatim and asserts a false warning | H | M | Phase 2 uses the report's R3 wording: `z1` validated, `prior_UZ` refuted, ruled out on cost not validity |
| A theorem name that does not exist in the tree is cited (e.g. `clock_validates_z1`, which was probed but never landed) | H | M | Phase 2 cites only the mechanism plus landed names (`clockFrame_looping`, `truthAt_add_nsmul`, `clock_atom_truth`); Phase 1 pre-verifies every name the sections will carry |
| A dotted `FormalSystem.*` name for a non-existent file breaks C5 | M | L | Slash paths and bare file names only; never the dotted `MinusLanguageSoundness` form |
| A task number or `specs/` provenance path is cited and breaks C9 | M | L | Durable anchors only — declaration names, file names, docstring section headings |
| The sections drift into restating theorems, breaching SCOPE | M | M | Both sections are navigational by construction; Phase 3's review step rejects any reproduced theorem statement beyond a name |
| An implementer runs `lake build` "to be safe" and burns a full rebuild | M | M | Phase 4 explicitly forbids it; C1 passes inside the ~1m41s invariants run without rebuilding |
| The README is assumed to have its pre-reconciliation shape | L | L | Phase 1 re-reads the file as it stands (eleven results, one inventory block, two trailing stamps) |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |

Phases within the same wave can execute in parallel. Phases 2 and 3 are logically independent
but are serialized because they edit the same file at adjacent insertion points.

---

### Phase 1: Re-verify anchors and capture the gate baseline [NOT STARTED]

**Goal**: Confirm every declaration name, file path and docstring-section heading the two
sections will cite still resolves, and record a green pre-edit baseline so any later gate failure
is attributable to this edit.

**Tasks**:
- [ ] Read `FormalSystem/Metalogic/Independence/README.md` in full as it now stands; note the
      insertion point between `## Key Results` and `## Dependencies`, and the two trailing
      `Last verified` stamps.
- [ ] Resolve each declaration the sections will name, using `lean_local_search` or
      `lean_declaration_file` (not the report's table on trust): `translationFrame`,
      `translationFrame_isRegular`, `translationFrame_taskRel`, `translationHist`,
      `translationModel`, `translationModel_atom`, `translation_realizes`,
      `translation_realizes_allPast`, `translation_realizes_allFuture`,
      `noMaxOrder_of_duration`, `not_validOn_prior_UZ_dense`, `not_validOn_z1_dense`,
      `ztimeSharpOrder`, `eq_base_of_lt_ztime`, `static_validates_z1`, `clockFrame`,
      `clockFrame_looping`, `truthAt_add_nsmul`, `clockModel`, `clock_atom_truth`,
      `MinusLanguage.tr_ne_untl`, `not_minus_derivable_z1`, `minus_soundness_ztime_succ`.
- [ ] Confirm the two path corrections hold: `minus_soundness_ztime_succ` is in
      `FormalSystem/MinusLanguage/Soundness.lean`, and
      `FormalSystem/Metalogic/Conservativity/MinusLanguageSoundness.lean` does not exist.
- [ ] Confirm the docstring section headings that will be cited by name exist verbatim:
      `CoNotPriorU.lean`'s *Why this is a statement about a model, not a frame*;
      `ZTimeSharpness.lean`'s *What is refuted is discreteness, not the Archimedean property*
      and *The frame-versus-model obstruction does not bite here*;
      `DenseRTimeSharpness.lean`'s *Shape pins* and *Order facts*.
- [ ] Read `scripts/check-module-invariants.sh`'s C20 block to confirm the `CITE` regex and the
      `publication_scope` predicate, and record the current in-scope violation count.
- [ ] Run the pre-edit baseline and record each result:
      `bash scripts/check-module-invariants.sh --emit-inventory --check`,
      `bash scripts/readme-lint.sh`, and `bash scripts/check-module-invariants.sh`.

**Timing**: 0.75 hours

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: the report asserts ~23 declaration names and 5 docstring section headings
all resolve, and that the in-scope C20 violation count is zero. Confirm each by direct
resolution; any name that fails to resolve is dropped from the sections rather than written on
faith, and a nonzero baseline violation count is recorded as pre-existing before proceeding.

**Files to modify**:
- None (read-only verification phase)

**Verification**:
- Every listed declaration resolved to a real file, with any discrepancy against the report's
  table written down.
- All three baseline commands green: `PASS INV`, `RESULT: PASS`, `ALL CHECKS PASSED`.
- C20 in-scope violation count recorded.

---

### Phase 2: Write Section 1 — the countermodel construction kit [NOT STARTED]

**Goal**: Insert `## Building a countermodel: what to reach for first` after `## Key Results`,
covering the default route, the labelled fallback, the two dead ends stated accurately, and the
three hard-won specifics.

**Tasks**:
- [ ] Write the **default route** subsection: `translationFrame D` + `translationHist D` +
      `translationModel D A`, with `translation_realizes`, `translation_realizes_allPast` and
      `translation_realizes_allFuture` as the ready-made atom-realisation bridges. State *why*
      it is the default — atoms are valued on world states, so a time-varying atom needs a
      history whose state varies with time, and the identity reference history is exactly that;
      `translationFrame_isRegular` is a global instance, so the `Sat` side condition is
      `inferInstance` at `.Base`, a pair at `.Dense`, a triple at `.RTime`.
- [ ] Write the four-step recipe explicitly: pick `A`; take
      `h (translationModel D A) (translationHist D) 0`; rewrite with the realisation lemma;
      derive the contradiction. Note the `haveI := noMaxOrder_of_duration D` opener (a plain
      lemma, deliberately not an instance) and the `DedekindNonCompactness` / `realOrder`
      ambiguity hazard on import.
- [ ] Write the **fallback route**, named as the fallback: the L⁻ transfer via
      `Z1Countermodel.lean`, `minus_soundness_ztime_succ` (in
      `FormalSystem/MinusLanguage/Soundness.lean`) and the `ℚ ×ₗ ℤ` carrier from
      `LexCarrier.lean`. State the `tr_ne_untl` obstruction (`MinusLanguage/Translation.lean`;
      `Formula.someFuture` is a top-level `untl` and nothing in the range of `tr` is) and the
      reason it never arises on the default route: nothing leaves the native language.
- [ ] Write the **dead ends** subsection asymmetrically. Static frame
      (`FrameOver.staticFrame`, `StaticFrame.lean`): time-invariant truth validates `Axiom.z1`
      outright — the landed `static_validates_z1`, on which `LexIntWitness.lean` depends. Clock
      frame (`clockFrame`, `ClockFrame.lean`): a dead end for `z1` *only* — period-1 truth
      (`clockFrame_looping`, `truthAt_add_period`, `truthAt_add_nsmul`) makes `Gφ`
      time-independent over the Archimedean `ℚ`, so `FGφ → Gφ` holds; state this as a mechanism,
      not as a theorem name, since no such theorem is in the tree. It is **not** a dead end for
      `prior_UZ` — `CoNotPriorU.lean`'s `clockModel` arc valuation refutes the atomic instance —
      and what rules it out there is cost, not validity, since it is pinned to `ℚ` and a quotient
      carrier.
- [ ] Write the three specifics: (a) non-discreteness, not non-Archimedean-ness, is what the
      `.ZTime` axioms fail over, and genericity in `D` is what converts one lemma per axiom into
      several frame classes via `ztimeSharpOrder` and `realOrder` — with the non-Archimedean
      discrete carriers named as the different story `LexIntWitness.lean` tells; (b) pin the
      shape, because `Axiom.prior_UZ ⊥` has an unsatisfiable antecedent and *is* `.Base`-valid,
      so every statement is at `Formula.atom p` and anonymous
      `example (φ : Formula) : Axiom (...) := Axiom.<ctor> φ` pins are standard practice (two in
      `ZTimeSharpness.lean`, three in `DenseRTimeSharpness.lean`), plus the guard-first /
      event-first rendering trap in `Axioms.lean`'s prose for `U`; (c) `by decide` fails on
      `FrameClass` `<` (only `≤` has a `DecidableRel`), the idiom is `absurd h.le (by decide)`,
      cited to `DenseRTimeSharpness.lean`'s *Order facts* note as the written-down place.
- [ ] Sweep the new section for forbidden content: no `file.lean:NNN`, no task numbers, no
      `specs/` paths, no dotted `FormalSystem.*` name that does not resolve, no reproduced
      theorem statement beyond a name.

**Timing**: 1.25 hours

**Depends on**: 1

**Verification Tier**: local

**Files to modify**:
- `FormalSystem/Metalogic/Independence/README.md` - insert one new `##` section between
  `## Key Results` and `## Dependencies`

**Verification**:
- `grep -nE '\b(([A-Za-z0-9_]+/)*[A-Za-z0-9_]+\.lean):([0-9]+)\b' FormalSystem/Metalogic/Independence/README.md`
  returns nothing.
- `bash scripts/readme-lint.sh` reports `RESULT: PASS`.
- Every declaration named in the section appears on Phase 1's resolved list.
- The clock-frame paragraph states the `z1` / `prior_UZ` asymmetry, not a symmetric claim.

---

### Phase 3: Write Section 2 — the frame-level refutation criterion [NOT STARTED]

**Goal**: Insert `## When frame-level refutation is obstructed, and when it is not` immediately
after Section 1, promoting the per-module aside into a stated criterion with an operational
consequence.

**Tasks**:
- [ ] Beat (i) — what is recorded and why: `CoNotPriorU.lean`'s *Why this is a statement about a
      model, not a frame* section records that frame-validity quantifies over **all** valuations,
      so on a densely ordered flow rich enough to realize an arbitrary set of times, frame-validity
      of `CO` already forces gap-freeness and hence forces Prior-U valid too. No frame-level
      countermodel can exist for any frame whatever; the theorem is therefore stated over a fixed
      `TaskModel`, matching Reynolds' printed caveat (1992, p.169), which that docstring already
      quotes.
- [ ] Beat (ii) — the criterion: the obstruction bites **only** when a statement must
      simultaneously *validate* something on a valuation-rich flow. A bare non-validity claim
      validates nothing and is therefore unobstructed. Cite `ZTimeSharpness.lean`'s
      *The frame-versus-model obstruction does not bite here* as the place this was first written
      down.
- [ ] Beat (iii) — the operational consequence: the unobstructed form is the frame-level
      `¬ F.ValidOn φ` / `¬ ValidIn fc φ`, which is **strictly stronger** than the model-fixed
      form, and it is the form the `.ZTime`, `.Dense` and `.RTime` non-validity results all take.
      Choose the statement form before the proof starts rather than discovering the distinction
      mid-proof.
- [ ] Close by naming the failure mode prevented: reading the `CoNotPriorU` docstring narrowly as
      a general prohibition on frame-level refutation, and paying again the cost of establishing
      that it does not apply.
- [ ] Update both trailing `Last verified` stamps to the edit date. Leave the pre-existing
      duplication as is unless collapsing it is clearly safe; neither gate reads it.
- [ ] Sweep the new section for the same forbidden content as Phase 2.

**Timing**: 0.75 hours

**Depends on**: 2

**Verification Tier**: local

**Files to modify**:
- `FormalSystem/Metalogic/Independence/README.md` - insert the second new `##` section after
  Section 1 and before `## Dependencies`; bump both `Last verified` stamps

**Verification**:
- The C20 `CITE` grep from Phase 2 still returns nothing over the whole file.
- `bash scripts/readme-lint.sh` reports `RESULT: PASS` (Check 3 resolves the existing relative
  links; no new relative link is added unless it resolves).
- The section states the criterion as a criterion — a reader can decide the statement form for a
  new refutation without opening any `.lean` file.
- No theorem is added or restated; both sections remain navigational.

---

### Phase 4: Regenerate inventories and run the gate suite [NOT STARTED]

**Goal**: Leave the repository with inventory blocks regenerated and both gates green, without a
rebuild.

**Tasks**:
- [ ] Run `bash scripts/check-module-invariants.sh --emit-inventory` (~1s). Expect a no-op:
      the generated blocks count `.lean` files only.
- [ ] `git diff --stat FormalSystem/` — confirm the only changed file is
      `FormalSystem/Metalogic/Independence/README.md`, and that the generated block inside it is
      unchanged (or, if changed, that the change is a genuine count correction and not a
      side effect of the prose edit).
- [ ] Run `bash scripts/readme-lint.sh` — expect `RESULT: PASS`.
- [ ] Run `bash scripts/check-module-invariants.sh` (~1m41s) — expect `ALL CHECKS PASSED`. If C20
      tier 2 reports a nonzero in-scope count, a line number slipped in: drop the `:NNN` and keep
      the name, then re-run.
- [ ] Do **not** run `lake build`. C1 passes inside the invariants run against the already-built
      tree. If a rebuild appears necessary, stop — something has left this task's scope.
- [ ] Commit the README (and any regenerated inventory block) with targeted staging.

**Timing**: 0.25 hours

**Depends on**: 3

**Verification Tier**: full

**Scope Hypothesis**: the report asserts `--emit-inventory` is a no-op for a Markdown-only edit
because `scan()` collects `.lean` files only. Confirm via `git diff --stat` after the run; if any
inventory count actually moved, investigate before committing rather than accepting the change.

**Files to modify**:
- Possibly `FormalSystem/Metalogic/Independence/README.md` (generated block only, expected
  unchanged); no other file expected to change.

**Verification**:
- `bash scripts/check-module-invariants.sh --emit-inventory --check` exits 0 with `PASS INV`.
- `bash scripts/readme-lint.sh` reports `RESULT: PASS`.
- `bash scripts/check-module-invariants.sh` reports `ALL CHECKS PASSED` (exit 0).
- `git status --short` shows only the intended README change staged.
- No `lake build` was run.

---

## Testing & Validation

- [ ] No `file.lean:NNN` citation anywhere in
      `FormalSystem/Metalogic/Independence/README.md` (C20 tier 2, gated by default).
- [ ] No task number, `specs/` path, or report path in either new section (C9).
- [ ] No dotted `FormalSystem.*` module name that does not resolve to a real file or directory
      (C5); in particular `MinusLanguageSoundness` never appears in dotted form.
- [ ] Every declaration named in either section resolved against the tree in Phase 1.
- [ ] The clock-frame paragraph states the `z1` / `prior_UZ` asymmetry.
- [ ] `bash scripts/check-module-invariants.sh` — `ALL CHECKS PASSED`.
- [ ] `bash scripts/readme-lint.sh` — `RESULT: PASS`.
- [ ] `bash scripts/check-module-invariants.sh --emit-inventory --check` — `PASS INV`.
- [ ] No `.lean` file modified; `git diff --name-only` lists the README alone.

## Artifacts & Outputs

- `FormalSystem/Metalogic/Independence/README.md` — two new `##` sections between `## Key Results`
  and `## Dependencies`, both `Last verified` stamps bumped.
- `specs/674_document_countermodel_kit_and_refutation_criterion/summaries/01_*-summary.md` —
  execution summary written at implementation close.

## Rollback/Contingency

The change is confined to one Markdown file and is fully reverted by
`git checkout HEAD -- FormalSystem/Metalogic/Independence/README.md` on a clean tree, or by
reverting the single commit if already committed. No Lean module, no generated artifact outside
this README, and no build state is touched, so nothing else needs unwinding.

If C20 tier 2 fails, the repair is mechanical: strip the offending `:NNN` suffix and keep the
declaration or file name. If any declaration cited in the sections turns out not to resolve,
remove that citation and restate the point in mechanism terms (the clock-frame validity claim is
already handled this way, since the probe that established it was never landed).
