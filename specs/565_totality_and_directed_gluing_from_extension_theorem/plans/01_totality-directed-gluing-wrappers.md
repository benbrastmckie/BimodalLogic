# Implementation Plan: Totality and Directed Gluing as wrappers on the Extension Theorem

- **Task**: 565 - Prove `app:presheaf-dictionary`'s Totality and Directed Gluing clauses
- **Status**: [IMPLEMENTING]
- **Effort**: 4 hours
- **Dependencies**: 563 (interval site and behavior presheaf — landed)
- **Research Inputs**: `specs/565_totality_and_directed_gluing_from_extension_theorem/reports/01_totality-directed-gluing-wrappers.md`
- **Artifacts**: plans/01_totality-directed-gluing-wrappers.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Both clauses are consumers of `thm:extension`: translate a section onto its subinterval, extend
the result to a possible world, restrict back. Everything lands in one new module,
`FormalSystem/Semantics/Presheaf/Directed.lean`, parameterized on the extension property taken as
an explicit hypothesis so that the `[F.IsRegular]`, `Completion` and ℤ-time forms are one-line
corollaries and the `Classical.choice` in each clause is *attributable* rather than merely
present. Definition of done: both clauses proved, `lake build FormalSystem` green with no new
`sorry`, every row of the choice record re-measured with `lean_verify`, and the four-row record
written into the module docstring and the cluster README.

### Research Integration

`reports/01_totality-directed-gluing-wrappers.md` compiled every declaration this plan commits
to through `lean_run_code` against the live tree, so no step here is conjectural. The findings
this plan consumes directly:

- **F1/F2** — `place` (translate, against `Interval p (p + m)`, *not* `PartialHistory.timeShift`)
  and `ofWorld` (cut), with `restrict_ofWorld` as the bridge. Totality's conclusion is literally
  `Function.Surjective (Beh.restrict …)`.
- **F3** — the directed union `directedSup` is the one genuinely new piece of machinery;
  `PartialHistoryOrder.chainSup` is the shape to copy but is stated for `IsChain` and is not
  reusable for a `Directed` family.
- **F4** — Directed Gluing's hypothesis is the single `Directed (· ≤ ·) (place ∘ …)` the proof
  actually consumes, with `place_le_place` supplied as the bridge from the paper's
  two-hypothesis phrasing. A dependent-rewrite hazard (`rw [h i]` → "motive is not type
  correct") is reproduced there, with `states_eq_of_eq` as the remedy.
- **F5** — the choice record is a four-row table with exact measurements, and the
  `(add_le_add_iff_left p).mpr` trap silently destroys the attribution result while the build
  stays green.
- **F6/F7** — the convention gates (C15, C24, C26, C31, C33, C34a/b) and the three shared touches
  outside `file_scope`.

**One correction to the research recommendations, verified by compiled probe.** F4/Phase 1's
recommendation to restate `states_eq_of_eq` *locally* "so the new module need not import
`Sheaf.lean`" does not work: `Sheaf.lean`'s `states_eq_of_eq` sits at top level in the same
namespace `FormalSystem.Semantics.Presheaf`, and `FormalSystem.lean` imports both modules, so a
second declaration of that name is a hard error. Probed:

```
`FormalSystem.Semantics.Presheaf.states_eq_of_eq` has already been declared
```

The research's standalone `lean_run_code` probes could not have surfaced this, because a snippet
that does not import `Sheaf.lean` sees no collision. **Resolution**: import
`FormalSystem.Semantics.Presheaf.Sheaf` and reuse the existing lemma. The cost is nil —
`Sheaf.lean` itself imports only `FormalSystem.Init` and `Presheaf.Behavior`, both of which this
module needs anyway — and it removes a declaration rather than adding one. Fallback, if the
import is later judged undesirable: a distinct name (`beh_states_eq_of_eq`), never a same-name
restatement.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No roadmap context supplied to this dispatch.

## Goals & Non-Goals

- **Goals**: `place`, `place_mem`, `ofWorld`, `restrict_ofWorld`, `totality_of_isRestriction`,
  `totality_clause`, `totality_clause_site`, `totality_of_isZTime`, `totality_of_completion`,
  `directed_states_agree`, `directedSup`, `le_directedSup`, `place_le_place`,
  `directed_gluing_of_isRestriction`, `directed_gluing_unique`, `directed_gluing_clause`
- **Goals (non-Lean)**: record the choice split explicitly — in the module docstring and as a
  third recorded verdict in `FormalSystem/Semantics/Presheaf/README.md` — rather than leaving it
  implicit in the proof terms; amend the two now-false README claims; keep every convention gate
  green.
- **Non-Goals**:
  - Touching `FormalSystem/Semantics/PartialHistory.lean`,
    `FormalSystem/Semantics/PartialHistoryOrder.lean`, or anything under
    `FormalSystem/Semantics/Extension/`. This task consumes `thm:extension`; it does not restate,
    strengthen or reprove it.
  - Consolidating `directedSup` into `PartialHistoryOrder.lean` beside `chainSup` (its natural
    home) or deriving `chainSup` from it. Recorded as a follow-up; forbidden by the hard
    constraint.
  - Widening `file_scope` to include `FormalSystem/Semantics/Presheaf.lean` or
    `FormalSystem.lean`. The dispatch is explicit that doing so makes the collision gate defer
    this whole front every cycle.
  - Reviving `app:Structure` or `app:presheaf-dictionary` in the paper. Both are cut; the
    citations state the cut at the site.
  - Importing the binary *Sheaf* case's choice-freeness into the directed case.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `(add_le_add_iff_left p).mpr` drags `Classical.choice` into the engine, silently destroying the attribution result while the build stays green | H | M | Use `add_le_add (le_refl p) h` (the idiom `Beh.restrict` already uses) throughout. Phase 1 and Phase 2 verification re-measure every engine row with `lean_verify` rather than trusting the build |
| Aggregator edit clobbered by concurrently dispatched sibling 567, invisibly to the collision gate (neither task's `file_scope` names the aggregators) | H | M | Re-read `FormalSystem/Semantics/Presheaf.lean` and `FormalSystem.lean` immediately before editing; stage only this task's own hunks (explicit file lists, never a directory or glob `git add`); re-run `lake build` after each aggregator edit; on a foreign commit, foreign uncommitted modification, or a build not started here, check `git log` and STOP and report |
| C33 failure from forgetting the **root** aggregator `FormalSystem.lean` | H | M | Named explicitly as a Phase 1 task with the exact insertion point: between `FormalSystem.Semantics.Presheaf.Behavior` (`:577`) and `FormalSystem.Semantics.Presheaf.Ray` (`:578`) |
| Duplicate-declaration error from a local `states_eq_of_eq` | H | — | Already resolved: import `Presheaf.Sheaf` and reuse. Probe-confirmed above; the lemma is not in this plan's declaration set |
| Dependent-rewrite failure in the uniqueness proof ("motive is not type correct") | M | H | Reproduced in research F4; use `states_eq_of_eq` (now imported) plus `PartialHistory.states_eq_of_time_eq` instead of `rw [h i]` |
| `linter.style.show` tripping the per-file C28 budget | L | M | Use `change`, not `show`, wherever the goal is being restated |
| Scope creep into `PartialHistoryOrder.lean` to put `directedSup` "where it belongs" | M | M | Non-Goal above; consolidation recorded as a follow-up in the module's Implementation Notes |
| A README claim left false after landing (`"built on PartialHistory.lean alone"`; the cluster-wide no-`Classical.choice` sentence) | M | M | Both are Phase 2 deliverables, not polish, and both are listed as explicit tasks |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |

Phases within the same wave can execute in parallel. These two are strictly sequential: Phase 2's
declarations live in the module Phase 1 creates, and Phase 2's README record quotes measurements
Phase 1 produces.

---

### Phase 1: Totality [COMPLETED]

**Goal**: `FormalSystem/Semantics/Presheaf/Directed.lean` exists, carries the translate/cut
machinery and the Totality clause in its engine plus three instantiations, is wired into both
aggregators, and `lake build FormalSystem` is green with no new `sorry`.

**Tasks**:
- [x] Create `FormalSystem/Semantics/Presheaf/Directed.lean` with the cluster's established
      shape: copyright header (2026, Benjamin Brast-McKie, Apache 2.0), module docstring with
      `## Main Definitions` / `## Main Results` / `## Implementation Notes` / `## References`,
      and the closing `assert_not_exists FormalSystem.ProofSystem.Axiom
      FormalSystem.ProofSystem.DerivationTree`.
- [x] Imports: `FormalSystem.Init`, `FormalSystem.Semantics.Presheaf.Behavior`,
      `FormalSystem.Semantics.Presheaf.Sheaf`, `FormalSystem.Semantics.Extension.Extension`,
      `FormalSystem.Semantics.Extension.Completion`. All five verified acyclic — nothing in the
      `Extension/` chain imports anything under `Presheaf/`.
- [x] `place` and `place_mem`: the translate onto `Interval p (p + m)`, `respects_task` via
      `sub_sub_sub_cancel_right`. Do **not** route through `PartialHistory.timeShift`.
- [x] `ofWorld`: `PartialHistory.restrict h (Interval 0 l) ⟨0, le_refl 0, hl⟩`, with the `Beh`
      property discharged by `fun _ => Iff.rfl`.
- [x] `restrict_ofWorld`: the bridge, moving a state across `p + r - p = r` through
      `PartialHistory.states_eq_of_time_eq`.
- [x] `totality_of_isRestriction`: the binder-free engine, taking
      `∀ τ, PartialHistory.IsRestriction τ` as an explicit hypothesis.
      `Constraints consumed: None`.
- [x] `totality_clause` (`[F.IsRegular]`, via `PartialHistory.isRestriction_of_isRegular`),
      `totality_clause_site` (the same at `Beh.restrictTr f` for `f : Tr l' l`),
      `totality_of_isZTime` (via `extension_of_isZTime`), `totality_of_completion` (via
      `extension_of_completion`) — each a one-line delegation to the engine. C34a markers:
      the four-constraint list for `totality_clause`/`totality_clause_site`,
      `Compositionality, Seriality, Limit` for `totality_of_isZTime`, `Seriality, Limit` for
      `totality_of_completion`.
- [x] Throughout: `add_le_add (le_refl p) h`, never `(add_le_add_iff_left p).mpr h`. `change`,
      never `show`.
- [x] `## References` in the normal form of `docs/development/REFERENCE_NORMAL_FORM.md`, every
      key resolving in the root `references.bib` (`[schultz2020]`, not the paper's
      `Schultz2020`). `app:presheaf-dictionary` and `def:behavior-presheaf` cited with their
      `DANGLING` status stated at the site, copying `Behavior.lean`'s "Paper state: the source
      appendix is cut" paragraph as the form of record; `thm:extension` and `cor:occurrence`
      cited plainly.
- [x] Re-read `FormalSystem/Semantics/Presheaf.lean` immediately beforehand, then add the one
      `import FormalSystem.Semantics.Presheaf.Directed` line (sorted) plus a `## Modules` bullet.
- [x] Re-read `FormalSystem.lean` immediately beforehand, then add
      `import FormalSystem.Semantics.Presheaf.Directed` between `…Presheaf.Behavior` and
      `…Presheaf.Ray`. C33 asserts this file is byte-for-byte `lake exe mk_all --lib FormalSystem`
      output; omitting the line fails C33 **and** C24's root-closure walk.

**Timing**: 2 hours

**Depends on**: none

**Verification Tier**: full

**Scope Hypothesis**: this phase asserts **nine** new declarations (`place`, `place_mem`,
`ofWorld`, `restrict_ofWorld`, `totality_of_isRestriction`, `totality_clause`,
`totality_clause_site`, `totality_of_isZTime`, `totality_of_completion`) in exactly **one** new
file plus **two** aggregator one-liners, and that the import insertion point in
`FormalSystem.lean` is between lines 577 and 578. Confirm at implementation time by: counting the
declarations actually written against the `## Lean Challenge Statements` identifier set; running
`git diff --stat` to confirm no file outside the three named was touched; and re-reading
`FormalSystem.lean` around the insertion point *before* editing (the line numbers are a
pre-edit observation, not a guarantee — a sibling's landed edit can shift them).

**Files to modify**:
- `FormalSystem/Semantics/Presheaf/Directed.lean` - created; the whole Totality stack
- `FormalSystem/Semantics/Presheaf.lean` - one sorted `import` line, one `## Modules` bullet
  (SHARED TOUCH outside `file_scope` — sibling 567 needs the same line)
- `FormalSystem.lean` - one sorted `import` line (SHARED TOUCH outside `file_scope`; C33-gated
  byte-exact)

**Verification**:
- `lake build FormalSystem` green, via the detached guarded route
  (`context/project/lean4/operations/long-builds.md`, `context/patterns/bounded-build-waiter.md`
  — hard timeout, writer liveness via `kill -0` on the captured PID, one waiter per log). Re-run
  after *each* aggregator edit, not only once at the end.
- No new `sorry`: `scripts/check-module-invariants.sh`'s sorry inventory unchanged.
- `lean_verify FormalSystem.Semantics.Presheaf.totality_of_isRestriction` measures
  `[propext, Quot.sound]` — **no `Classical.choice`**. This is the attribution result; if
  `Classical.choice` appears, the `add_le_add_iff_left` trap has been hit and the phase is not
  complete.
- `lean_verify FormalSystem.Semantics.Presheaf.totality_clause` measures
  `[propext, Classical.choice, Quot.sound]`.
- `bash scripts/check-module-invariants.sh` green (C8, C15, C24, C26, C28, C31, C32, C33,
  C34a/b).
- Commit per green sub-step: the module once it builds, then each aggregator edit, with
  explicit per-file `git add` lists (never a directory or glob pathspec).

---

### Phase 2: Directed Gluing, and the choice record [COMPLETED]

**Goal**: the directed union and both halves of Directed Gluing land in the same module, the
four-row choice record is written explicitly in two places, the cluster READMEs stop asserting
things that are now false, and `lake build FormalSystem` is green with no new `sorry`.

**Tasks**:
- [x] `directed_states_agree`: two members of a `Directed (· ≤ ·)` family agree wherever both are
      defined. Copy `PartialHistoryOrder.chain_states_agree`'s proof, replacing `hc.total` with a
      common upper bound from `hdir`.
- [x] `directedSup` (`noncomputable`, as `chainSup` is): domain `fun t => ∃ i, (fam i).domain t`,
      states via `Classical.choose`, `respects_task` routed through a common upper bound of the
      two chosen witnesses. `[Nonempty I]` is required — `nonempty_domain` is a field and the
      empty family's union has empty domain. `Directed` needs no extra import; it arrives
      transitively through `Mathlib.Order.Zorn`.
- [x] `le_directedSup`.
- [x] `place_le_place`: the paper's "any two restrict a third" bridge, taking the shift-fit
      `p - p' + m ≤ m'` as an explicit named hypothesis rather than an inline `by` term.
- [x] `directed_gluing_of_isRestriction`: union the translates, extend to a possible world by the
      hypothesis, cut over `[0, l]`; `restrict_ofWorld` applies at every index because each
      translate is below the union and the union below the world. `Constraints consumed: None`.
- [x] `directed_gluing_unique` under `hcov`: at each `t ∈ [0, l]` pick a covering index and read
      both sections at `t - p i` through the imported `states_eq_of_eq`. **Do not** use
      `rw [h i]` — it fails with "motive is not type correct" on a goal whose domain witness
      mentions the rewritten section.
- [x] `directed_gluing_clause`: the `∃!` packaging at `[F.IsRegular]` under the covering
      hypothesis. C34a marker: the four-constraint list.
- [x] Module docstring: the four-row choice record as a table, stating that the engine rows are
      what make it a *record* rather than an observation — because the wrapper is measured
      choice-free with the extension property as a hypothesis, Totality's `Classical.choice` is
      attributable *exactly* to `thm:extension`, whereas Directed Gluing's is **doubly** sourced
      (the union is independently non-constructive). Note `app:gluing`'s ℚ counterexample as the
      reason *Saturation* is genuinely required in the directed case, so the non-constructivity
      is a mathematical obstruction rather than a Lean artifact. *(deviation: altered — rendered as a TWO-column table (Declaration | Measured axioms) plus a four-value legend and the prose readings, not a three-column one: three columns put four table rows past the 100-column `linter.style.longLine` budget, and markdown table rows cannot be wrapped. The record also carries eleven rows over four distinct axiom values rather than four rows, including one measurement the plan did not anticipate — `directed_gluing_of_isRestriction`, the Directed Gluing ENGINE, measures `Classical.choice` even with the extension property hypothesized away, which is sharper evidence for "doubly sourced" than the plan's table had)*
- [x] Module Implementation Notes: the `add_le_add_iff_left` measurement trap, and the recorded
      follow-up to consolidate `directedSup` into `PartialHistoryOrder.lean` beside `chainSup`.
- [x] `FormalSystem/Semantics/Presheaf/README.md`: amend the layering claim (the cluster is no
      longer "built on `Semantics/PartialHistory.lean` alone" — this module imports the
      `Extension/` cluster); amend the now-false sentence that `#print axioms` reports no
      `Classical.choice` on **any** declaration in the cluster. `Ray.lean`'s own narrower claim
      stays true and needs no change. *(deviation: altered — also changed the section heading `## Two recorded verdicts` to `## Recorded verdicts`: it already undercounted (four subsections), and adding a fifth would have left a demonstrably false count in a file this task was amending for exactly that kind of staleness)*
- [x] `FormalSystem/Semantics/Presheaf/README.md`: add the choice record as a third recorded
      verdict; extend `Key Definitions` and `Key Results`; regenerate the inventory block with
      `bash scripts/check-module-invariants.sh --emit-inventory`, **never** by hand. *(deviation: altered — the regeneration had to run in Phase 1 as well, because adding the module made the INV check fail immediately; it was re-run here once the module's line count changed)*
- [x] `FormalSystem/Semantics/README.md:63`: minimally extend the hand-written `Presheaf/` row.
      It already says "(2 files)" and names only `Site` and `Behavior`, so it is stale by two
      prior tasks; add `Directed` and correct the count. Minimal addition only — a rewrite would
      collide broadly.
- [x] `docs/reference/paper-definitions-of-record.md:2120` (optional): the
      `app:presheaf-dictionary` row's description currently names only *Germs* and *Sheaf* as
      formalized; adding *Totality* and *Directed Gluing* keeps the record true. The row is
      `DANGLING` and carries no hash, so editing the description is safe. *(done — the optional item was taken, not skipped)*

**Timing**: 2 hours

**Depends on**: 1

**Verification Tier**: full

**Scope Hypothesis**: this phase asserts **seven** new declarations (`directed_states_agree`,
`directedSup`, `le_directedSup`, `place_le_place`, `directed_gluing_of_isRestriction`,
`directed_gluing_unique`, `directed_gluing_clause`) and **two** now-false README sentences at the
stated locations (`Presheaf/README.md`'s "built on `Semantics/PartialHistory.lean` alone" and its
cluster-wide no-`Classical.choice` claim; `Semantics/README.md:63`'s "(2 files)" row). Confirm at
implementation time by: counting declarations against the `## Lean Challenge Statements`
identifier set; grepping each README for the quoted phrase *before* editing, to confirm the
sentence is still present and still worded as recorded (a sibling or a prior task may have
already amended it, in which case the edit is a no-op rather than a second amendment).

**Files to modify**:
- `FormalSystem/Semantics/Presheaf/Directed.lean` - the directed union, both halves of the
  clause, the `∃!` packaging, and the choice record in the docstring
- `FormalSystem/Semantics/Presheaf/README.md` - two amendments, the third recorded verdict,
  `Key Definitions`/`Key Results`, regenerated inventory block
- `FormalSystem/Semantics/README.md` - minimal extension of the `Presheaf/` row (SHARED TOUCH
  outside `file_scope`)
- `docs/reference/paper-definitions-of-record.md` - optional description update to the
  `app:presheaf-dictionary` row

**Verification**:
- `lake build FormalSystem` green, same detached guarded route as Phase 1.
- No new `sorry`.
- `lean_verify` reproducing **every** row of the choice record, not a sample:
  `sheaf_clause` → `[propext, Quot.sound]`; `totality_of_isRestriction` →
  `[propext, Quot.sound]`; `PartialHistory.extension` →
  `[propext, Classical.choice, Quot.sound]`; `totality_clause` →
  `[propext, Classical.choice, Quot.sound]`; `directedSup` → `[propext, Classical.choice]`;
  `directed_gluing_clause` → `[propext, Classical.choice, Quot.sound]`. A row that does not
  reproduce means the docstring table is wrong and the phase is not complete.
- `bash scripts/check-module-invariants.sh` green (C8, C15, C24, C26, C28, C31, C32, C33,
  C34a/b, INV — the inventory block must match the regenerated output).
- `bash .claude/scripts/check-task-references.sh` clean: no "task N" citations in any
  deliverable outside `specs/**`. The follow-up recorded in the Implementation Notes names the
  *file and declaration* (`PartialHistoryOrder.lean`, beside `chainSup`), never a task number.
- Commit per green sub-step, explicit per-file `git add` lists.

---

## Lean Challenge Statements

Every signature below was compiled standalone against the live tree (`lean_run_code`, 16
declarations, 16 `sorry` warnings and zero errors), so the statement set is pinned rather than
sketched. `states_eq_of_eq` is **imported from `Presheaf.Sheaf`, not declared here** — see the
Research Integration correction above.

```lean
import FormalSystem.Init
import FormalSystem.Semantics.Presheaf.Behavior
import FormalSystem.Semantics.Presheaf.Sheaf
import FormalSystem.Semantics.Extension.Extension
import FormalSystem.Semantics.Extension.Completion

namespace FormalSystem.Semantics.Presheaf

def place {F : TaskFrame} {m : F.Duration} (p : F.Duration) (hm : 0 ≤ m) (σ : Beh F m) :
    PartialHistory F := sorry

theorem place_mem {F : TaskFrame} {m : F.Duration} (p : F.Duration) (hm : 0 ≤ m) (σ : Beh F m)
    {t : F.Duration} (h0 : p ≤ t) (h1 : t ≤ p + m) : (place p hm σ).domain t := sorry

def ofWorld {F : TaskFrame} (h : WorldHistory F) (l : F.Duration) (hl : 0 ≤ l) : Beh F l := sorry

theorem restrict_ofWorld {F : TaskFrame} {l m : F.Duration} (p : F.Duration) (hp : 0 ≤ p)
    (hm : 0 ≤ m) (hfit : p + m ≤ l) (hl : 0 ≤ l) (σ : Beh F m) (h : WorldHistory F)
    (hext : place p hm σ ≤ h.val) :
    Beh.restrict p m hp hm hfit (ofWorld h l hl) = σ := sorry

theorem totality_of_isRestriction (F : TaskFrame)
    (hext : ∀ τ : PartialHistory F, PartialHistory.IsRestriction τ)
    {l m : F.Duration} (p : F.Duration) (hp : 0 ≤ p) (hm : 0 ≤ m) (hfit : p + m ≤ l) :
    Function.Surjective (Beh.restrict p m hp hm hfit : Beh F l → Beh F m) := sorry

theorem totality_clause (F : TaskFrame) [F.IsRegular] {l m : F.Duration} (p : F.Duration)
    (hp : 0 ≤ p) (hm : 0 ≤ m) (hfit : p + m ≤ l) :
    Function.Surjective (Beh.restrict p m hp hm hfit : Beh F l → Beh F m) := sorry

theorem totality_clause_site (F : TaskFrame) [F.IsRegular] {l' l : Obj F.Duration} (f : Tr l' l) :
    Function.Surjective (Beh.restrictTr f : Beh F l.val → Beh F l'.val) := sorry

theorem totality_of_isZTime (F : TaskFrame) (hZ : F.IsZTime)
    (hcomp : TaskFrame.Compositional F.TaskRel) (hser : TaskFrame.Serial F.TaskRel)
    (hlim : TaskFrame.Limit F.TaskRel) {l m : F.Duration} (p : F.Duration)
    (hp : 0 ≤ p) (hm : 0 ≤ m) (hfit : p + m ≤ l) :
    Function.Surjective (Beh.restrict p m hp hm hfit : Beh F l → Beh F m) := sorry

theorem totality_of_completion (F : TaskFrame) (hser : TaskFrame.Serial F.TaskRel)
    (hlim : TaskFrame.Limit F.TaskRel) (hC : PartialHistory.Completion F)
    {l m : F.Duration} (p : F.Duration) (hp : 0 ≤ p) (hm : 0 ≤ m) (hfit : p + m ≤ l) :
    Function.Surjective (Beh.restrict p m hp hm hfit : Beh F l → Beh F m) := sorry

theorem directed_states_agree {F : TaskFrame} {I : Type*} {fam : I → PartialHistory F}
    (hdir : Directed (· ≤ ·) fam) (i j : I) (t : F.Duration)
    (hi : (fam i).domain t) (hj : (fam j).domain t) :
    (fam i).states t hi = (fam j).states t hj := sorry

noncomputable def directedSup {F : TaskFrame} {I : Type*} [Nonempty I]
    (fam : I → PartialHistory F) (hdir : Directed (· ≤ ·) fam) : PartialHistory F := sorry

theorem le_directedSup {F : TaskFrame} {I : Type*} [Nonempty I] (fam : I → PartialHistory F)
    (hdir : Directed (· ≤ ·) fam) (i : I) : fam i ≤ directedSup fam hdir := sorry

theorem place_le_place {F : TaskFrame} {m m' : F.Duration} (p p' : F.Duration)
    (hm : 0 ≤ m) (hm' : 0 ≤ m') (σ : Beh F m) (σ' : Beh F m')
    (hple : p' ≤ p) (hsub : 0 ≤ p - p') (hshift : p - p' + m ≤ m')
    (hres : σ = Beh.restrict (p - p') m hsub hm hshift σ') :
    place p hm σ ≤ place p' hm' σ' := sorry

theorem directed_gluing_of_isRestriction (F : TaskFrame)
    (hext : ∀ τ : PartialHistory F, PartialHistory.IsRestriction τ)
    {I : Type*} [Nonempty I] {l : F.Duration}
    (p m : I → F.Duration) (hp : ∀ i, 0 ≤ p i) (hm : ∀ i, 0 ≤ m i)
    (hfit : ∀ i, p i + m i ≤ l) (σ : ∀ i, Beh F (m i))
    (hdir : Directed (· ≤ ·) fun i => place (p i) (hm i) (σ i)) :
    ∃ τ : Beh F l, ∀ i, Beh.restrict (p i) (m i) (hp i) (hm i) (hfit i) τ = σ i := sorry

theorem directed_gluing_unique {F : TaskFrame} {I : Type*} {l : F.Duration}
    (p m : I → F.Duration) (hp : ∀ i, 0 ≤ p i) (hm : ∀ i, 0 ≤ m i)
    (hfit : ∀ i, p i + m i ≤ l)
    (hcov : ∀ t, 0 ≤ t → t ≤ l → ∃ i, p i ≤ t ∧ t ≤ p i + m i)
    (σ : ∀ i, Beh F (m i)) (τ τ' : Beh F l)
    (h : ∀ i, Beh.restrict (p i) (m i) (hp i) (hm i) (hfit i) τ = σ i)
    (h' : ∀ i, Beh.restrict (p i) (m i) (hp i) (hm i) (hfit i) τ' = σ i) :
    τ = τ' := sorry

theorem directed_gluing_clause (F : TaskFrame) [F.IsRegular] {I : Type*} [Nonempty I]
    {l : F.Duration} (p m : I → F.Duration) (hp : ∀ i, 0 ≤ p i) (hm : ∀ i, 0 ≤ m i)
    (hfit : ∀ i, p i + m i ≤ l)
    (hcov : ∀ t, 0 ≤ t → t ≤ l → ∃ i, p i ≤ t ∧ t ≤ p i + m i)
    (σ : ∀ i, Beh F (m i))
    (hdir : Directed (· ≤ ·) fun i => place (p i) (hm i) (σ i)) :
    ∃! τ : Beh F l, ∀ i, Beh.restrict (p i) (m i) (hp i) (hm i) (hfit i) τ = σ i := sorry

end FormalSystem.Semantics.Presheaf
```

## Testing & Validation

- [x] `lake build FormalSystem` green at the end of every phase, and again after every aggregator
      edit, via the detached guarded route with a hard timeout and `kill -0` writer liveness.
- [x] No new `sorry` anywhere in `FormalSystem/` on either reading of the C3 baseline.
- [x] All six choice-record rows reproduced by `lean_verify`, including the two engine rows whose *(exceeded: all seventeen declarations in the record were measured, not six)*
      *absence* of `Classical.choice` is the task's analytic point.
- [x] `bash scripts/check-module-invariants.sh` green: C8 (module docstring), C15/C31
      (`## References` normal form, every key resolving in the root `references.bib`), C24 (root
      closure), C26 (no underscore in a `def`/`abbrev` name component — `place`, `ofWorld`,
      `directedSup` comply; `directed_sup` would not), C28 (lint budget), C32, C33 (`FormalSystem.lean`
      byte-exact against `lake exe mk_all --lib FormalSystem`), C34a/b (`Constraints consumed:`
      markers), INV (README inventory blocks).
- [x] `assert_not_exists FormalSystem.ProofSystem.Axiom FormalSystem.ProofSystem.DerivationTree`
      still passes in the new module — the whole new import closure was traced and contains
      nothing under `FormalSystem.ProofSystem.*`, so the cluster stays provably below
      `Semantics/Truth.lean`.
- [x] `bash .claude/scripts/check-task-references.sh` clean.
- [x] `git diff --stat` shows no file touched outside the six named across both phases. *(deviation: altered — nine files, not six. The three extra are machine-generated and gate-required rather than hand-authored: `README.md` and `FormalSystem/README.md` carry generated inventory blocks regenerated by `scripts/check-module-invariants.sh --emit-inventory` (the INV check fails otherwise), and `typst/generated/status.typ` carries the live file/line counts regenerated by `scripts/typst-sync-check.sh --fix` (a pre-commit hook blocks the commit otherwise). None was anticipated by the plan's file lists)*

## Artifacts & Outputs

- `FormalSystem/Semantics/Presheaf/Directed.lean` — new; 16 declarations, the choice record in
  its docstring
- `FormalSystem/Semantics/Presheaf.lean` — one import line, one `## Modules` bullet
- `FormalSystem.lean` — one import line
- `FormalSystem/Semantics/Presheaf/README.md` — two amendments, the third recorded verdict,
  extended `Key Definitions`/`Key Results`, regenerated inventory block
- `FormalSystem/Semantics/README.md` — minimally extended `Presheaf/` row
- `docs/reference/paper-definitions-of-record.md` — optional `app:presheaf-dictionary` row
  description update
- `specs/565_totality_and_directed_gluing_from_extension_theorem/summaries/01_*-summary.md` — the
  execution summary, including the follow-up record (consolidate `directedSup` into
  `PartialHistoryOrder.lean` beside `chainSup`, from which `chainSup` could then be derived)

## Rollback/Contingency

The new module is additive and self-contained, so the ordinary contingency is to revert the
three code touches and leave the tree exactly as it was. Both phases commit per green sub-step,
so the rollback target is always the last green commit of this task:

- **Phase 1 fails to build**: revert only this task's own commits (`git revert`, or
  `git checkout <last-green-sha> -- <the three paths>`). Do **not** revert the aggregator lines
  in isolation — removing the module while leaving its import, or vice versa, fails C33/C24 and
  leaves the tree redder than before.
- **Phase 2 fails to build**: Phase 1's commits stand on their own (Totality is a complete,
  gate-green result without Directed Gluing), so the contingency is to stop at Phase 1 and record
  Directed Gluing as the remaining scope, rather than to revert the module.
- **A working-tree rollback is genuinely needed**: take the snapshot first, per
  `context/contracts/recovery.md`'s rollback rung, with the task number explicit — never the
  bare no-argument form, and never `git-snapshot.sh` in its default reverting mode as a
  precautionary checkpoint. For an ordinary defensive checkpoint before risky work, use
  `--no-revert`.
- **A foreign change appears** (sibling 567 is dispatched on this same working tree): STOP and
  report after checking `git log` to confirm the work is not this task's own. Do not revert, do
  not "fix" it, and do not dismiss it as noise.
