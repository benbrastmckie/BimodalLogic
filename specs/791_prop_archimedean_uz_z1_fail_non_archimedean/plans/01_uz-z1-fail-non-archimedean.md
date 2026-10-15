# Implementation Plan: UZ and Z1 fail over every non-Archimedean Discrete order

- **Task**: 791 - Prove prop:archimedean in the generality the paper states it (UZ and Z1 fail over every non-Archimedean Discrete temporal order)
- **Status**: [NOT STARTED]
- **Effort**: 4 hours
- **Dependencies**: Task 788 (complete, at HEAD); tasks 789 and 790 (complete, committed earlier in this batch)
- **Research Inputs**: specs/791_prop_archimedean_uz_z1_fail_non_archimedean/reports/01_uz-z1-fail-non-archimedean.md
- **Artifacts**: plans/01_uz-z1-fail-non-archimedean.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

`prop:archimedean` asserts that neither Z1 nor UZ is valid over *any* Discrete temporal order that
is not Archimedean. The tree today machine-checks the failure at one concrete carrier in one
neighbouring language (`Conservativity/Z1Countermodel.lean`, L⁻ over `ℚ ×ₗ ℤ`) and restates the
general claim as prose in three docstrings without proving it. This plan lands the general,
carrier-generic result: both countermodels on `translationFrame D` along `translationHist D`, at an
arbitrary `(D : TemporalOrder)` with a least positive duration and `¬ Archimedean ↑D`, plus the
paper's own `⊭_D` shape, the bare-Discrete-class corollaries at `ℤ ×ₗ ℤ`, and the amendment of the
three prose sites that currently promise the theorem. Definition of done: `lake build FormalSystem`
green, `lean-sorry-census.sh FormalSystem` reports 0, `scripts/check-module-invariants.sh` exits 0,
`scripts/typst-sync-check.sh` exits 0, and every docstring claiming the general result cites the new
theorem by name.

### Research Integration

The research report compiled **both countermodels and all of the glue, sorry-free, against the real
project** (`lean_run_code`, five probes, zero diagnostics). Implementation here is transcription plus
docstrings, not discovery. Four report findings are load-bearing and are not re-litigated:

- **One new order lemma is needed and nothing else.** `¬ Archimedean D` plus a least positive `u`
  yields the paper's `y`; no Mathlib equivalent exists at a bare ordered abelian group
  (`archimedean_iff_nat_lt` and its family all need a `StrictOrderedSemiring`-flavoured carrier).
- **The hypothesis form is `IsLeast {z | 0 < z} u`, not `[SuccOrder ↑D]`.** It is the paper's own
  "there is a least duration `1 > 0`" verbatim, it is a `Prop` rather than data, and the dispatch's
  `SuccOrder` form is recovered as a one-line wrapper through `isLeast_pos_succ_zero`.
- **Both formulas stay at `Formula.atom p`, never schematic in `φ`** — forced for the reason
  `ZTimeSharpness.lean` already records: `Axiom.prior_UZ ⊥` has an unsatisfiable antecedent and so is
  valid everywhere, which would falsify a `∀ φ` form.
- **`Z1Countermodel.lean` stays as the concrete L⁻ witness and is not made an instance** of the
  general theorem (three measured reasons: different language, `tr_ne_untl` blocks the bridge,
  different valuation). Its only edit is a docstring cross-reference. See Decisions below.

Two report recommendations are **narrowed by this plan** on evidence read at plan-authoring time
rather than carried forward — see "Post-790 adjustments" below.

### Post-790 adjustments (read from the current tree, not from the report)

Task 790 rewrote `FormalSystem/Semantics/Correspondence/DurationFrames.lean` (now 801 lines) after
the research report was written, and landed two declarations that change this plan's shape:

- **`isDiscrete_iff_exists_isLeast_pos`** (`Semantics/Correspondence/DurationFrames.lean`) proves
  `(∀ x, (∃ y, x < y) → ∃ y', IsLeast {z | x < z} y') ↔ ∃ p, IsLeast {x | 0 < x} p`. This is
  exactly the report's `isLeast_pos_of_isDiscrete` and
  `isLeast_pos_of_translationFrame_isDiscrete` wrappers, already in the tree. **Neither wrapper is
  added**; the Discrete-hypothesis entry points below consume `(isDiscrete_iff_exists_isLeast_pos D).mp`
  instead. Adding them would duplicate a theorem landed three commits ago.
- **`succOrderOfIsLeastPos`** supplies the converse (`IsLeast` ⇒ `SuccOrder`) as an
  `@[instance_reducible] noncomputable def`, so the two directions of the least-positive/successor
  correspondence are both already available and neither needs restating.

Also from 790, and binding on this plan: **`translationFrame` depends on `Classical.choice`**, as
does every pre-existing declaration over it. No phase here states, verifies, or advertises a
no-choice-axiom criterion for any declaration over that frame; `lean_verify` is used for sorry
scanning only, never as an axiom-freedom gate.

### Prior Plan Reference

No prior plan. This is the task's first planning round.

### Roadmap Alignment

This dispatch carried no `roadmap_path`, so `specs/ROADMAP.md` was not consulted and no
roadmap-review or roadmap-update phase is included.

### Siting decision

**A new module, `FormalSystem/Metalogic/Independence/ArchimedeanSharpness.lean`, rather than an
extension of `ZTimeSharpness.lean`.** That module's docstring section "What is refuted is
discreteness, not the Archimedean property" explicitly disclaims the Archimedean story and assigns
it elsewhere ("The non-Archimedean discrete carriers are a different story, told by
`Independence/LexIntWitness.lean`"). Honouring that disclaimer with a redirect is a smaller and more
honest edit than rewriting the section, and the two modules then read as the two branches of the
duration dichotomy — dense in `ZTimeSharpness.lean`, least-positive here. **The cost, stated
plainly**: one more module in an already 28-module directory, and the two shape pins
(`Axiom.prior_UZ`, `CompletenessDerived.z1Thm`) are duplicated from `ZTimeSharpness.lean` so that
each module's generality claim is independently a compiler obligation.

The order lemma goes to `Semantics/DurationClassification.lean`'s `LeastPositive` section, which
already carries exactly the binder bundle it needs (`{D : Type} [AddCommGroup D] [LinearOrder D]
[IsOrderedAddMonoid D]`) and whose subject is the least-positive element. The report suggested
"beside `archimedean_of_succ`"; that declaration lives in the `SuccessorBranch` section, whose
subject is successor structure the new lemma does not mention, so the lemma is sited one section
earlier and its docstring points at `archimedean_of_succ` as the positive side of the same picture.

## Goals & Non-Goals

**Goals**:
- `exists_gt_nsmul_of_not_archimedean`, `translationFrame_isDiscrete`,
  `not_validOn_prior_UZ_nonArchimedean`, `not_validOn_z1_nonArchimedean`,
  `not_validOn_prior_UZ_discrete_nonArchimedean`, `not_validOn_z1_discrete_nonArchimedean`,
  `not_validOn_prior_UZ_succ_nonArchimedean`, `not_validOn_z1_succ_nonArchimedean`,
  `not_validOnFrameOver_prior_UZ_nonArchimedean`, `not_validOnFrameOver_z1_nonArchimedean`,
  `lexZOrder`, `translationFrame_lexZ_not_isZTime`, `not_validOnFrames_isDiscrete_prior_UZ`,
  `not_validOnFrames_isDiscrete_z1` — the identifier set pinned under
  `## Lean Challenge Statements` below, exactly, no more and no fewer
- Two anonymous `example` shape pins in the new module, copied from the existing sharpness module,
  tying the two refuted formulas to the axiom constructor and to the derived Z1 theorem. Anonymous
  by construction, so deliberately not in the pinned set above
- The three prose sites that today restate the paper's general claim without proving it — the
  sharpness module's Archimedean disclaimer, the conservativity module's "Two live-paper facts"
  section, and the `IsZTime` docstring — amended to cite the new theorems by name
- A recorded disposition for the concrete `ℚ ×ₗ ℤ` module: it stays as the concrete L⁻ witness, with
  a docstring cross-reference and no proof change, and its downstream consumers keep compiling
  because nothing they depend on is touched
- The post-788 `Axiom.z1` doc drift cleared at its 7 occurrences in 5 files (a droppable objective,
  independent of the mathematics — see Phase 3)

**Non-Goals**:
- Any edit to `/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex`, including
  the `% PORT:` marker under `prop:archimedean` and the `\leanproof{}` macro that will replace it.
  Settled in cycle 1 (see `.decisions.json`): the paper-side edit belongs to PossibleWorlds task
  172, and this task's job is to name the identifiers that citation will point at. The two names for
  the eventual `\leanproof{\texttt{...}}`: `not_validOnFrameOver_z1_nonArchimedean` and
  `not_validOnFrameOver_prior_UZ_nonArchimedean`, both in
  `FormalSystem.Metalogic.Independence`
- An L⁻ twin of the general countermodel. `MinusLanguage/Soundness.lean`'s
  `minus_soundness_ztime_succ` is generic over any regular frame with `SuccOrder` **and**
  `PredOrder` on the duration, so an L⁻ version *would* generalize `not_minus_derivable_z1` to every
  such carrier. It needs a `PredOrder` hypothesis the L-level results do not, and the dispatch's
  DELIVER names the L-level `ValidOn`. Recorded so the option is not lost; a separate task if wanted
- Any change to `FrameClass.ZTime`'s soundness story. The refuting frames are
  Discrete-but-not-`IsZTime`, so nothing here collides with `axiom_validIn_min`,
  `prior_UZ_validIn_iff_ztime` or `z1_validIn_iff_ztime`. `translationFrame_lexZ_not_isZTime` puts
  that non-collision on the record rather than in a reader's head
- `docs/theorem-index.md` rows for the new declarations. The analogous `ZTimeSharpness.lean` results
  (`not_validOn_z1_dense`, `prior_UZ_minFrameClass_sharp` and the rest) carry no rows either —
  verified by grep at plan time — so adding rows here would make this module the only indexed
  sharpness module, and C15's index assertion only constrains rows that exist
- A new `MANIFEST` row or a re-pin of the whole-file sentinels in
  `docs/reference/paper-definitions-of-record.md`. `prop:archimedean` already has a
  `KNOWN-ANCHORS` `LIVE-UNPINNED` row and is already cited by six live modules; only that row's
  prose needs the amendment Phase 3 carries, and `prop:` is outside C15's gated prefix set
- Absorbing the pre-existing `scripts/check-paper-definitions.sh` drift wave. Unrelated to this task
  and not a regression of it; that script is advisory in this plan's verification criteria
- Any edit to `FormalSystem/Metalogic/Independence/OrderTransfer.lean` or
  `FormalSystem/Metalogic/Independence/StateSetTruth.lean` — concurrent task 792's territory

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `typst/generated/status.typ` must be regenerated (a new `.lean` file moves `formalsystem-file-count` and `formalsystem-line-count`, which `typst-sync-check.sh` check 2 compares against a live regeneration) — and that file is inside concurrent task 792's declared `file_scope` | H | M | Regeneration is *absorbing*, not merging: `scripts/typst-status-counts.sh` overwrites the file from live source, so a sibling's already-committed change is reproduced rather than clobbered. Run it in Phase 4 only, re-read the file immediately before and inspect `git diff -- typst/generated/status.typ`: if the only changed lines are the two scale counts and the stamp, commit; if a foreign *uncommitted* modification is present, STOP and report per the dispatch's concurrency note. The generator needs a built library (it reads the axiom report with `#print axioms`), so it runs after Phase 4's full build, never before |
| `docs/reference/paper-definitions-of-record.md`'s `prop:archimedean` row says "this repository does NOT check it -- it is a pen-and-paper result". After this task that sentence is false. The file is inside concurrent task 792's declared `file_scope` | M | M | One-sentence prose edit inside the `KNOWN-ANCHORS` block, in Phase 3, under the same re-read-then-inspect protocol. Do **not** promote the row to a `MANIFEST` row and do **not** re-pin the whole-file `PINNED_COMMIT`/`FILE_CHECKSUM` sentinels — the row stays `LIVE-UNPINNED` because the tree still cites the anchor by name without quoting its text. If the file carries foreign uncommitted edits at that moment, close the objective as a reasoned exclusion with the collision as evidence rather than absorbing them |
| `FormalSystem/Metalogic/Independence/README.md` needs a thirteenth result entry and a `Twelve results` → `Thirteen results` count fix, and it too is inside task 792's declared `file_scope` | M | M | `readme-lint.sh` check 2 (file listed in its README) is REPORTED and **not gated**, so this edit is a quality obligation, not a gate. Same protocol; if the file is contended, record the entry as a reasoned exclusion. The matching entry in `Independence.lean`'s module docstring is **not** contended and lands regardless, so the result is never undocumented |
| `lean_local_search`'s index reported `warming` throughout research, so the report's absence findings rest on grep sweeps | L | L | Re-checked by grep at plan time: `exists_gt_nsmul_of_not_archimedean`, `translationFrame_isDiscrete` and `ArchimedeanSharpness.lean` do not exist anywhere under `FormalSystem/`. At implementation time re-run `lean_local_search` and treat an empty result as proof of absence only under `index: consulted` |
| C34b (`Constraints consumed:` honesty) fires on `not_validOn_*_succ_nonArchimedean`, the two declarations carrying a bracketed `[SuccOrder (D : Type)]` binder | M | M | C34b is bracketed-binder-only and its subject is a *constraint* claim (the four `def:frame` constraints), which a successor-order binder is not. If it does fire, the fix is a `Constraints consumed:` line naming none of the four plus the reason, not a restatement — do not switch to an explicit `(so : SuccOrder ↑D)` binder, which would break the verified `isLeast_pos_succ_zero` application |
| An implementer reads `ZTimeSharpness.lean`'s "no claim is made here that either axiom is refutable ... specifically over a non-Archimedean order" as a standing prohibition and marks the task blocked | M | L | That sentence scopes what *that module* claims, not what the tree may prove. Phase 3's redirect removes the ambiguity, and Phase 3 is in the same plan rather than deferred |
| A sibling's unguarded `lake` invocation collides with this task's build and the build is lost | M | M | Route every build through `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- ...`, detached, and read the verdict from the guard's exit status or its `result` subcommand — never from a pipe exit code. Treat a build failure in a file outside this task's own `Files to modify` as possibly a sibling's in-flight edit, not automatically a regression of this task |
| `push_neg` now emits a deprecation warning on every use, which C28's per-file warning budget would surface as noise | L | H | Measured during research: use `push Not`, which is already this tree's idiom (`ZTimeSharpness.lean` uses it). Likewise `le_or_gt`, never `le_or_lt` (`Unknown identifier` in this toolchain's ambient namespace) |
| `linarith` does not fire on a bare ordered abelian group | L | M | Recorded in `DurationClassification.lean`'s own docstrings. Every goal in the verified text closes by hand-chosen Mathlib lemmas; the Appendix of the research report is the authority for each one |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 1, 2, 3 |

Phases within the same wave can execute in parallel.

### Phase 1: The order lemma and the frame-property bridge [NOT STARTED]

**Goal**: the two pieces of glue the countermodels consume exist and compile — the paper's step 1
(`¬ Archimedean` yields a time beyond every multiple of the unit) and the fact that the translation
frame over a least-positive duration is `IsDiscrete`.

**Tasks**:
- [ ] Re-read `FormalSystem/Semantics/DurationClassification.lean` immediately before editing (a
      sibling may have touched it since this plan was written)
- [ ] Add `exists_gt_nsmul_of_not_archimedean` to the `LeastPositive` section, after
      `isGreatest_pred_of_isLeast_pos` and before `end LeastPositive`, at the section's existing
      `variable {D : Type} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]` bundle. The
      verified body (compiled, zero diagnostics):
      `by_contra hc` / `push Not at hc` / `refine hna ⟨fun x y hy => ?_⟩` /
      `obtain ⟨n, hn⟩ := hc x` / `exact ⟨n, hn.trans (nsmul_le_nsmul_right (hu.2 hy) n)⟩`
- [ ] Its docstring records: `Archimedean` is a `class`, so the negated hypothesis is opened by
      `by_contra` + `push Not` + anonymous-constructor reconstruction rather than destructured; and
      `archimedean_of_succ` in the `SuccessorBranch` section below is the positive side of the same
      picture. Use `push Not`, not the deprecated `push_neg`
- [ ] Add one `## Main results` bullet for it in the module docstring, in the list's existing voice
- [ ] Re-read `FormalSystem/Semantics/Correspondence/DurationFrames.lean`, then add
      `translationFrame_isDiscrete` to the "The translation frame's history and model" section,
      after `translation_realizes_allFuture`. Verified term-mode body:
      `fun x _ => ⟨x + u, isLeast_succ_of_isLeast_pos hu x⟩`
- [ ] Its docstring records three things: why it lives here and not beside
      `translationFrame_isRegular` in `Frames/Standard.lean` (that module's import list is
      deliberately `TaskFrame` and nothing else, and `TaskFrame.IsDiscrete` is not in its closure —
      its module docstring says why); that it is the frame-level reading of
      `(isDiscrete_iff_exists_isLeast_pos D).mpr`, which this file already carries; and that the
      *converse* reading needs no new lemma because `(isDiscrete_iff_exists_isLeast_pos D).mp` is it
- [ ] Cite declarations by name only — never `file.lean:NNN` (C20)

**Timing**: 0.75 hours

**Depends on**: none

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: the hypothesis is **2 files touched and 2 new declarations**, and that
`isLeast_succ_of_isLeast_pos` and the `LeastPositive` section's binder bundle are still where this
plan read them. Confirm immediately before editing with
`grep -n 'end LeastPositive\|isLeast_succ_of_isLeast_pos' FormalSystem/Semantics/DurationClassification.lean`
and `grep -n 'translation_realizes_allFuture' FormalSystem/Semantics/Correspondence/DurationFrames.lean`.

**Tier Justification**: both edits are purely additive with no change to any existing signature, and
`DurationFrames.lean` imports `DurationClassification.lean`, so the single scoped build
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Semantics.Correspondence.DurationFrames`
compiles both amended modules and is the covering check.

**Files to modify**:
- `FormalSystem/Semantics/DurationClassification.lean` - `exists_gt_nsmul_of_not_archimedean` in the `LeastPositive` section, plus one `## Main results` bullet
- `FormalSystem/Semantics/Correspondence/DurationFrames.lean` - `translationFrame_isDiscrete` in the translation-frame section

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Semantics.Correspondence.DurationFrames`
  exits 0, with the guard's exit status read directly (or via its `result` subcommand), never
  inferred from a pipe
- `bash .claude/scripts/lean-sorry-census.sh FormalSystem` reports `sorry_count: 0`
- `grep -n 'exists_gt_nsmul_of_not_archimedean' FormalSystem/Semantics/DurationClassification.lean`
  shows the declaration and its `## Main results` bullet
- `git diff --staged --stat` before each commit shows only this phase's two files

---

### Phase 2: The new module — both countermodels, their entry points, and the corollaries [NOT STARTED]

**Goal**: `prop:archimedean` is a theorem of this tree at an arbitrary non-Archimedean carrier with
a least positive duration, in the paper's own `⊭_D` shape and at the bare Discrete class, with the
non-collision against `IsZTime` on the record.

**Tasks**:
- [ ] Create `FormalSystem/Metalogic/Independence/ArchimedeanSharpness.lean` with the repository
      copyright header, imports
      (`FormalSystem.Semantics.Correspondence.DurationFrames`, `FormalSystem.Metalogic.Soundness`,
      `FormalSystem.Metalogic.CompletenessDerived`, `FormalSystem.Semantics.LexCarrier`),
      `open FormalSystem FormalSystem.Syntax FormalSystem.Semantics FormalSystem.ProofSystem`, and
      `namespace FormalSystem.Metalogic.Independence` — the header shape `ZTimeSharpness.lean` uses
- [ ] Module docstring: the paper's proof structure (one shared frame `translationFrame D`, one
      shared history `translationHist D`, one shared division of `D` into the near times
      `E = {z | 0 < z ∧ ∃ n : ℕ, z < n • u}` and its complement); that this is the least-positive
      branch of the duration dichotomy whose dense branch is `ZTimeSharpness.lean`; that a consumer
      holding `¬ DenselyOrdered ↑D` reaches the hypothesis through
      `duration_dense_or_least_pos` and needs no further wrapper here; and the choice-dependence
      note — `translationFrame` depends on `Classical.choice`, so nothing in this module is
      advertised as choice-free
- [ ] Transcribe the two anonymous `example` shape pins from `ZTimeSharpness.lean`'s pins section,
      against `Axiom.prior_UZ` and `FormalSystem.Metalogic.CompletenessDerived.z1Thm`, so this
      module's generality claim is independently a compiler obligation
- [ ] Transcribe `not_validOn_z1_nonArchimedean` and `not_validOn_prior_UZ_nonArchimedean` verbatim
      from the research report's Appendix ("Verified proof text") — both compiled sorry-free with
      zero diagnostics against these same imports. Reflow to the 100-column limit on transcription;
      do not restructure the proofs
- [ ] Per-theorem docstrings following the paper's step map: for Z1, `|p| = D \ E`, `FGp` at `0`
      from `y`, `G(Gp → p)` at `0` by the `z + u ∈ E` step fact, `¬Gp` at `0` from `u ∈ E`; for UZ,
      `|p| = {y + n • u | n : ℤ}`, `Fp` at `0`, and no `p`-time having a `¬p`-guarded initial
      segment because `y + (n−1) • u` is itself a positive `p`-time. Record that step 7 is stated
      contrapositively in the paper and read forwards in Lean — a presentation reordering, not a
      deviation
- [ ] Add the two Discrete-hypothesis entry points,
      `not_validOn_prior_UZ_discrete_nonArchimedean` and `not_validOn_z1_discrete_nonArchimedean`,
      taking `(hdisc : (translationFrame D).toTaskFrame.IsDiscrete)` and opening it with
      `obtain ⟨u, hu⟩ := (isDiscrete_iff_exists_isLeast_pos D).mp hdisc`. If that `.mp` does not
      unify through `TaskFrame.IsDiscrete`'s `def`, fall back to the report's verified route —
      `obtain ⟨q, hq⟩ := TaskFrame.exists_pos_of_nontrivial (D := (D : Type))` then `hdisc 0 ⟨q, hq⟩`
      — and say in the docstring which route was taken. These are what make the result stateable at
      the paper's own Discrete clause
- [ ] Add the two `SuccOrder` entry points, `not_validOn_prior_UZ_succ_nonArchimedean` and
      `not_validOn_z1_succ_nonArchimedean`, at `[SuccOrder (D : Type)]`, routed through
      `isLeast_pos_succ_zero`. These are the dispatch's stated hypothesis form; their docstrings
      record that the primary binder is deliberately the weaker `Prop`-valued `IsLeast`
- [ ] Add the paper-shape corollaries `not_validOnFrameOver_prior_UZ_nonArchimedean` and
      `not_validOnFrameOver_z1_nonArchimedean` — `¬ ∀ F : FrameOver D, F.toTaskFrame.ValidOn φ`,
      the idiom `validOn_df_iff_isDiscrete` renders `⊨_D` in — each `fun h => hfail (h (translationFrame D))`.
      Their docstrings name them as the two identifiers PossibleWorlds task 172 will cite in
      `\leanproof{\texttt{...}}`
- [ ] Add `noncomputable abbrev lexZOrder : TemporalOrder := TemporalOrder.of (ℤ ×ₗ ℤ)`, mirroring
      `ztimeSharpOrder` in `ZTimeSharpness.lean`, with a docstring recording that `LexInt.isLeast_pos`
      and `LexInt.not_archimedean` hold at `α ×ₗ ℤ` for any nontrivial `α` and that
      `Rigidity.lexRat_not_archimedean` is **not** usable here (`ℚ ×ₗ ℚ` is dense, hence has no least
      positive duration)
- [ ] Add `translationFrame_lexZ_not_isZTime`, verified body `rintro ⟨so, -, hsa, -⟩` then
      `exact LexInt.not_archimedean (@archimedean_of_succ (ℤ ×ₗ ℤ) _ _ _ so _ hsa)` (the pattern
      `LexIntWitness.lean`'s `lexIntStaticFrame_not_sat` already uses), and the two bare-Discrete-class
      corollaries `not_validOnFrames_isDiscrete_prior_UZ` / `not_validOnFrames_isDiscrete_z1` at
      `ValidOnFrames (fun F : TaskFrame => F.IsRegular ∧ F.IsDiscrete)`, instantiated at `lexZOrder`
      via `fun h => hfail (h _ ⟨inferInstance, translationFrame_isDiscrete _ LexInt.isLeast_pos⟩)`.
      Their docstrings must say, in the tree's own voice, that the witness frame is regular and
      `IsDiscrete` yet **not** `IsZTime`, so nothing here contradicts `prior_UZ_validIn_iff_ztime` or
      `z1_validIn_iff_ztime` — that is what `translationFrame_lexZ_not_isZTime` is for
- [ ] Add `import FormalSystem.Metalogic.Independence.ArchimedeanSharpness` to
      `FormalSystem/Metalogic/Independence.lean`'s import block (re-read the file first), then
      regenerate the library root with `lake exe mk_all --lib FormalSystem` and inspect
      `git diff -- FormalSystem.lean`: if the only added line is the new module's, commit; if a
      foreign import line appears, STOP and report rather than absorbing it
- [ ] Cite declarations by name only — never `file.lean:NNN` (C20). Give every declaration a
      docstring as it is written (C19), and keep lines inside the 100-column limit (C28)

**Timing**: 1.75 hours

**Depends on**: 1

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: the hypothesis is **14 new declarations across 2 new-or-amended Lean files
plus the generated root**, and that the research report's Appendix text compiles verbatim here —
carried from that report's five `lean_run_code` probes, which ran against
`FormalSystem.Semantics.Correspondence.DurationFrames` + `FormalSystem.Metalogic.Soundness` rather
than against this module's full import list. Confirm at implementation time by the scoped build
below plus
`grep -cE '^(theorem|noncomputable abbrev)' FormalSystem/Metalogic/Independence/ArchimedeanSharpness.lean`;
a wrapper that turns out to be one line of an existing lemma (as two of the report's four
hypothesis entry points already did — see "Post-790 adjustments") is dropped, not written twice.

**Tier Justification**: the new module is a leaf with no dependents in the tree and changes no
existing signature, so
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Independence`
(which compiles the new module through the amended aggregator) covers this phase's blast radius;
the generated root's byte-currency (C33) and the typst count freshness are cross-cutting and are
deferred to Phase 4's full gate by design.

**Files to modify**:
- `FormalSystem/Metalogic/Independence/ArchimedeanSharpness.lean` - new: both countermodels, two shape pins, four hypothesis entry points, the paper-shape and class-level corollaries, `lexZOrder`, the non-`IsZTime` lemma
- `FormalSystem/Metalogic/Independence.lean` - one import line
- `FormalSystem.lean` - regenerated by `lake exe mk_all --lib FormalSystem`

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Independence`
  exits 0, exit status read directly from the guard
- `bash .claude/scripts/lean-sorry-census.sh FormalSystem` reports `sorry_count: 0` — the module
  must never carry an intermediate `sorry`, since every proof body is already verified text
- `grep -c 'sorry' FormalSystem/Metalogic/Independence/ArchimedeanSharpness.lean` reports 0
- All 14 identifiers pinned under `## Lean Challenge Statements` resolve:
  `grep -nE 'not_validOn_(prior_UZ|z1)|not_validOnFrame|lexZOrder|translationFrame_lexZ_not_isZTime' FormalSystem/Metalogic/Independence/ArchimedeanSharpness.lean`
- `git diff -- FormalSystem.lean` adds exactly one import line

---

### Phase 3: Amend the prose that currently promises the theorem [NOT STARTED]

**Goal**: every docstring and README that today restates the paper's general claim without proving
it cites the new theorems instead, the concrete `ℚ ×ₗ ℤ` module's disposition is recorded at the
module itself, and the post-788 `Axiom.z1` drift is cleared.

**Tasks**:
- [ ] `FormalSystem/Metalogic/Independence/ZTimeSharpness.lean`, section "What is refuted is
      discreteness, not the Archimedean property": keep the section's point (what *that* module
      refutes is non-discreteness), and redirect its closing sentence from
      `Independence/LexIntWitness.lean` to `Independence/ArchimedeanSharpness.lean`, naming the two
      general theorems. The sentence "no claim is made here that either axiom is refutable ...
      specifically over a non-Archimedean order" is rewritten so it scopes that module's own
      statements and no longer reads as a standing prohibition
- [ ] `FormalSystem/Metalogic/Conservativity.lean`, section "Two live-paper facts bearing on the
      discrete rows", first bullet: the sentence restating `def:BX-z`'s every-non-Archimedean-order
      reasoning now cites `not_validOn_prior_UZ_nonArchimedean` and `not_validOn_z1_nonArchimedean`
      as the tree's own machine-checked form of it, instead of presenting it as paper prose the tree
      does not check
- [ ] `FormalSystem/Semantics/FrameProperty.lean`, the `TaskFrame.IsZTime` docstring: same
      amendment at the "the axioms `UZ` and `Z1` fail over every discrete temporal order that is not
      Archimedean" sentence — cite the two theorems by name
- [ ] `FormalSystem/Metalogic/Conservativity/Z1Countermodel.lean`: add a docstring cross-reference
      recording the disposition decision — that module stays the concrete L⁻ witness at
      `ℚ ×ₗ ℤ` and is **not** an instance of the general theorem, with the three measured reasons
      (different language: `MinusTruthAt` on `MinusFormula` versus `TruthAt` on `Formula`;
      `MinusLanguage.tr_ne_untl` makes `tr` of the L⁻ `Z1` syntactically distinct from L's, whose
      `FGp` is a top-level `untl`; and a different valuation — the ℚ-coordinate upper set versus the
      paper's `E`). No proof change in that file
- [ ] `FormalSystem/Metalogic/Independence.lean`'s module docstring: add the thirteenth result
      entry for `ArchimedeanSharpness.lean` and update the result count, matching the voice of the
      existing twelve
- [ ] `FormalSystem/Metalogic/Independence/README.md`: the matching thirteenth entry and the
      `Twelve results are carried here` count fix. Re-read immediately before editing — this file is
      inside concurrent task 792's declared `file_scope`; if it carries foreign uncommitted edits,
      close this one objective as a reasoned exclusion with the collision as evidence (check 2 of
      `readme-lint.sh` is reported, not gated) rather than absorbing them
- [ ] `docs/reference/paper-definitions-of-record.md`: amend the `prop:archimedean`
      `KNOWN-ANCHORS` row's prose, which currently says the repository does not check the anchor.
      Keep the row `LIVE-UNPINNED`; do not promote it to a `MANIFEST` row and do not re-pin the
      whole-file `PINNED_COMMIT`/`FILE_CHECKSUM` sentinels. Same 792 contention protocol as the
      README above
- [ ] Droppable objective, independent of the mathematics — clear the post-788 `Axiom.z1` drift at
      its 7 occurrences in 5 files, verified present by grep at plan time:
      `FormalSystem/ProofSystem/Axioms.lean` ("ZTime (2 axioms: prior_UZ, z1)" → the one ZTime
      constructor plus the derived `CompletenessDerived.z1Thm`; `status.typ`'s
      `ztime-only-count = 1` is the cross-check),
      `FormalSystem/Semantics/FrameProperty.lean` (the `IsZTime` docstring's "`Axiom.prior_UZ`,
      `DerivedAxioms.priorSZ` and `Axiom.z1` all carry `.ZTime`"),
      `FormalSystem/Metalogic/Conservativity.lean`,
      `FormalSystem/Metalogic/Independence.lean`, and
      `FormalSystem/Metalogic/Independence/StaticFrame.lean` (3 occurrences, including the
      `/-! ## Axiom.z1 -/` section heading — rename to the derived name, leaving
      `static_validates_z1`'s own identifier untouched). If this objective inflates the phase, close
      the phase `[COMPLETED WITH EXCLUSIONS]` with this item recorded; the mathematics does not
      depend on it
- [ ] Do not introduce any `file.lean:NNN` citation while editing (C20), and do not re-word any
      documented axiom or sorry count (C14)

**Timing**: 1 hour

**Depends on**: 2

**Verification Tier**: prose

**Commit Mode**: per-substep

**Scope Hypothesis**: the hypothesis is **7 `Axiom.z1` occurrences across 5 files** and **3 prose
sites** restating the general claim — both re-derived by grep at plan-authoring time against the
current tree, not carried from the research report (which reported 5 sites for the first figure and
is superseded here). Confirm immediately before editing with
`grep -rn 'Axiom\.z1' FormalSystem/` and treat any new occurrence as in scope for the same pass.

**Tier Justification**: every hunk lies inside a `/-! … -/` or `/-- … -/` comment region or in a
markdown file, so the `prose` row's hunk-by-hunk diff read-through over `git diff -U0` is the
covering check, with Phase 4's full build as the backstop for any hunk that escapes a comment
boundary.

**Files to modify**:
- `FormalSystem/Metalogic/Independence/ZTimeSharpness.lean` - the Archimedean-disclaimer section redirected to the new module
- `FormalSystem/Metalogic/Conservativity.lean` - the "Two live-paper facts" bullet now cites the new theorems; one `Axiom.z1` mention
- `FormalSystem/Semantics/FrameProperty.lean` - the `IsZTime` docstring's Archimedean sentence and its `Axiom.z1` mention
- `FormalSystem/Metalogic/Conservativity/Z1Countermodel.lean` - docstring cross-reference recording the disposition decision
- `FormalSystem/Metalogic/Independence.lean` - thirteenth result entry, count fix, one `Axiom.z1` mention
- `FormalSystem/Metalogic/Independence/README.md` - thirteenth result entry and count fix (792 contention protocol)
- `docs/reference/paper-definitions-of-record.md` - the `prop:archimedean` KNOWN-ANCHORS row's prose (792 contention protocol)
- `FormalSystem/ProofSystem/Axioms.lean` - the stale ZTime axiom-count line
- `FormalSystem/Metalogic/Independence/StaticFrame.lean` - 3 stale `Axiom.z1` mentions

**Verification**:
- `git diff -U0` read hunk by hunk: every changed line is inside a comment region or a markdown
  file, and no proof term or signature is touched
- `grep -rn 'Axiom\.z1' FormalSystem/` returns nothing (or, if the droppable objective was excluded,
  exactly the occurrences recorded in that phase's `#### Reasoned Exclusions` table)
- `grep -n 'ArchimedeanSharpness' FormalSystem/Metalogic/Independence/ZTimeSharpness.lean FormalSystem/Metalogic/Conservativity.lean FormalSystem/Semantics/FrameProperty.lean`
  shows the three redirects
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Semantics.FrameProperty`
  exits 0 — the one amended module deep in the import graph, as a cheap escaped-comment tripwire
- `git diff --staged --stat` before each commit shows only this phase's files

---

### Phase 4: Full gate set, generated-count regeneration, and final verification [NOT STARTED]

**Goal**: the repository is green under its complete gate set with the new module in the build
graph, and every generated count that the new file moves is regenerated from live source.

**Tasks**:
- [ ] Run the full guarded build first — `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build`
      — because the status-count generator reads the per-declaration axiom report out of a built
      library
- [ ] Regenerate `typst/generated/status.typ` with `bash scripts/typst-status-counts.sh`, then
      inspect `git diff -- typst/generated/status.typ` under the contention protocol in Risks: the
      expected change is `formalsystem-file-count`, `formalsystem-line-count` and the stamp
      commit/date, and nothing else
- [ ] Final `lake exe mk_all --lib FormalSystem` and the `git diff -- FormalSystem.lean` inspection
- [ ] Run the gate set below and fix only this task's own findings. A finding in a file outside this
      task's `Files to modify` across all four phases is possibly a sibling's in-flight edit and is
      reported, not silently repaired
- [ ] Record the two identifiers PossibleWorlds task 172 will cite
      (`not_validOnFrameOver_z1_nonArchimedean`, `not_validOnFrameOver_prior_UZ_nonArchimedean`,
      both in `FormalSystem.Metalogic.Independence`) in the completion summary, since the paper-side
      `% PORT:` marker is deliberately left to that task

**Timing**: 0.75 hours

**Depends on**: 1, 2, 3

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: the hypothesis is that **exactly two generated files move** — `FormalSystem.lean`
(one import line) and `typst/generated/status.typ` (two scale counts plus the stamp). Confirm by
running each generator and reading `git diff --stat` for those two paths before staging; any third
generated file that moves is reported, not absorbed.

**Files to modify**:
- `typst/generated/status.typ` - regenerated scale counts and stamp (792 contention protocol)
- `FormalSystem.lean` - regenerated

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build` (full project, unscoped)
  exits 0, exit status captured un-piped from the guard
- `bash .claude/scripts/lean-sorry-census.sh FormalSystem` reports `sorry_count: 0` with an empty
  inventory — the dispatch's "no new sorry" constraint, asserted at the end of the task as well as
  at the end of every phase
- `bash scripts/check-module-invariants.sh` exits 0 — C1, C3 (structural sorry inventory asserted by
  content), C9 (no task-number citations under `FormalSystem/`), C14 (documented axiom/sorry counts),
  C15 (the `prop:archimedean` citation resolves against its `KNOWN-ANCHORS` row), C16 (no env_linter
  finding beyond `scripts/nolints.json`), C19, C20 (no `file.lean:NNN` citation introduced), C24
  (the new module transitively imports `FormalSystem.Init`), C26, C28, C31, C32, C33 (byte-current
  generated root), C34a/C34b
- `bash scripts/typst-sync-check.sh` exits 0 — in particular check 2, count freshness, which the new
  `.lean` file is what moved
- `bash scripts/readme-lint.sh FormalSystem` exits 0 (checks 1 and 3 are the gated ones)
- `bash scripts/check-copyright-headers.sh --strict FormalSystem` exits 0 — the new module's header
- `bash .claude/scripts/verify-deploy.sh` — the complete repository gate set this tier requires —
  exits 0
- `bash scripts/check-paper-definitions.sh` is **advisory here only**: it is already red at HEAD with
  a pre-existing drift wave unrelated to this task. Assert only that the `prop:archimedean` row
  itself still resolves; do not absorb the drift wave or re-pin the whole-file sentinels
- Every command's exit status is checked directly; a diff of captured stdout against a baseline is
  not accepted as evidence for any of them
- `git log --oneline` shows this task's commits with no foreign commit interleaved into its range

## Lean Challenge Statements

The pinned set is the 14 identifiers named under `- **Goals**:`. One of them, `lexZOrder`, carries a
**real body** rather than `sorry`: it is a `TemporalOrder` abbreviation with no proof content, and a
`sorry` body for it makes `(lexZOrder : Type)` opaque, at which point none of the three statements
mentioning it elaborates at all. The two anonymous `example` shape pins the new module carries are
not pinnable here — an `example` declares no identifier — and are deliberately absent.

```lean
import FormalSystem.Semantics.Correspondence.DurationFrames
import FormalSystem.Metalogic.Soundness
import FormalSystem.Metalogic.CompletenessDerived
import FormalSystem.Semantics.LexCarrier

open FormalSystem FormalSystem.Syntax FormalSystem.Semantics FormalSystem.ProofSystem

namespace FormalSystem.Semantics

/-- The paper's step 1: `¬ Archimedean` plus a least positive `u` yields a time beyond every
multiple of `u`. -/
theorem exists_gt_nsmul_of_not_archimedean {D : Type} [AddCommGroup D] [LinearOrder D]
    [IsOrderedAddMonoid D] {u : D} (hu : IsLeast {z : D | 0 < z} u)
    (hna : ¬ Archimedean D) : ∃ x : D, ∀ n : ℕ, n • u < x := sorry

/-- The translation frame over a duration group with a least positive element satisfies
`def:frame-properties`' bare Discrete clause. -/
theorem translationFrame_isDiscrete (D : TemporalOrder) {u : (D : Type)}
    (hu : IsLeast {z : (D : Type) | 0 < z} u) :
    (translationFrame D).toTaskFrame.IsDiscrete := sorry

end FormalSystem.Semantics

namespace FormalSystem.Metalogic.Independence

/-- `Axiom.prior_UZ` fails on the translation frame over any non-Archimedean duration group with a
least positive element. -/
theorem not_validOn_prior_UZ_nonArchimedean (D : TemporalOrder) {u : (D : Type)}
    (hu : IsLeast {z : (D : Type) | 0 < z} u) (hna : ¬ Archimedean (D : Type)) (p : Atom) :
    ¬ (translationFrame D).toTaskFrame.ValidOn
        ((Formula.atom p).someFuture.imp
          (Formula.untl (Formula.atom p).neg (Formula.atom p))) := sorry

/-- Z1 (`CompletenessDerived.z1Thm`) fails on the same frame, same hypotheses. -/
theorem not_validOn_z1_nonArchimedean (D : TemporalOrder) {u : (D : Type)}
    (hu : IsLeast {z : (D : Type) | 0 < z} u) (hna : ¬ Archimedean (D : Type)) (p : Atom) :
    ¬ (translationFrame D).toTaskFrame.ValidOn
        (((Formula.atom p).allFuture.imp (Formula.atom p)).allFuture.imp
          ((Formula.atom p).allFuture.someFuture.imp (Formula.atom p).allFuture)) := sorry

/-- The same refutation from the paper's own Discrete hypothesis, read at the frame. -/
theorem not_validOn_prior_UZ_discrete_nonArchimedean (D : TemporalOrder)
    (hdisc : (translationFrame D).toTaskFrame.IsDiscrete) (hna : ¬ Archimedean (D : Type))
    (p : Atom) :
    ¬ (translationFrame D).toTaskFrame.ValidOn
        ((Formula.atom p).someFuture.imp
          (Formula.untl (Formula.atom p).neg (Formula.atom p))) := sorry

/-- The Z1 half at the Discrete hypothesis. -/
theorem not_validOn_z1_discrete_nonArchimedean (D : TemporalOrder)
    (hdisc : (translationFrame D).toTaskFrame.IsDiscrete) (hna : ¬ Archimedean (D : Type))
    (p : Atom) :
    ¬ (translationFrame D).toTaskFrame.ValidOn
        (((Formula.atom p).allFuture.imp (Formula.atom p)).allFuture.imp
          ((Formula.atom p).allFuture.someFuture.imp (Formula.atom p).allFuture)) := sorry

/-- The dispatch's `SuccOrder` hypothesis form, recovered through `isLeast_pos_succ_zero`. -/
theorem not_validOn_prior_UZ_succ_nonArchimedean (D : TemporalOrder) [SuccOrder (D : Type)]
    (hna : ¬ Archimedean (D : Type)) (p : Atom) :
    ¬ (translationFrame D).toTaskFrame.ValidOn
        ((Formula.atom p).someFuture.imp
          (Formula.untl (Formula.atom p).neg (Formula.atom p))) := sorry

/-- The Z1 half at the `SuccOrder` hypothesis. -/
theorem not_validOn_z1_succ_nonArchimedean (D : TemporalOrder) [SuccOrder (D : Type)]
    (hna : ¬ Archimedean (D : Type)) (p : Atom) :
    ¬ (translationFrame D).toTaskFrame.ValidOn
        (((Formula.atom p).allFuture.imp (Formula.atom p)).allFuture.imp
          ((Formula.atom p).allFuture.someFuture.imp (Formula.atom p).allFuture)) := sorry

/-- `prop:archimedean`'s own shape for UZ: not valid over `D`, i.e. not valid on every frame over
`D`. The identifier the paper's `\leanproof{}` cites. -/
theorem not_validOnFrameOver_prior_UZ_nonArchimedean (D : TemporalOrder) {u : (D : Type)}
    (hu : IsLeast {z : (D : Type) | 0 < z} u) (hna : ¬ Archimedean (D : Type)) (p : Atom) :
    ¬ ∀ F : FrameOver D, F.toTaskFrame.ValidOn
        ((Formula.atom p).someFuture.imp
          (Formula.untl (Formula.atom p).neg (Formula.atom p))) := sorry

/-- `prop:archimedean`'s own shape for Z1. -/
theorem not_validOnFrameOver_z1_nonArchimedean (D : TemporalOrder) {u : (D : Type)}
    (hu : IsLeast {z : (D : Type) | 0 < z} u) (hna : ¬ Archimedean (D : Type)) (p : Atom) :
    ¬ ∀ F : FrameOver D, F.toTaskFrame.ValidOn
        (((Formula.atom p).allFuture.imp (Formula.atom p)).allFuture.imp
          ((Formula.atom p).allFuture.someFuture.imp (Formula.atom p).allFuture)) := sorry

/-- The concrete non-Archimedean discrete carrier the class-level corollaries are read at. Carries a
real body deliberately: a `sorry` here makes every statement below opaque. -/
noncomputable abbrev lexZOrder : TemporalOrder := TemporalOrder.of (ℤ ×ₗ ℤ)

/-- The witness frame is regular and `IsDiscrete` yet **not** `IsZTime` — the non-collision with
`prior_UZ_validIn_iff_ztime` and `z1_validIn_iff_ztime`, on the record. -/
theorem translationFrame_lexZ_not_isZTime :
    ¬ (translationFrame lexZOrder).toTaskFrame.IsZTime := sorry

/-- UZ is not valid over the bare Discrete class of record. -/
theorem not_validOnFrames_isDiscrete_prior_UZ (p : Atom) :
    ¬ ValidOnFrames (fun F : TaskFrame => F.IsRegular ∧ F.IsDiscrete)
        ((Formula.atom p).someFuture.imp
          (Formula.untl (Formula.atom p).neg (Formula.atom p))) := sorry

/-- Z1 is not valid over the bare Discrete class of record. -/
theorem not_validOnFrames_isDiscrete_z1 (p : Atom) :
    ¬ ValidOnFrames (fun F : TaskFrame => F.IsRegular ∧ F.IsDiscrete)
        (((Formula.atom p).allFuture.imp (Formula.atom p)).allFuture.imp
          ((Formula.atom p).allFuture.someFuture.imp (Formula.atom p).allFuture)) := sorry

end FormalSystem.Metalogic.Independence
```

## Testing & Validation

- [ ] `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build` exits 0, read from
      the guard's own exit status or its `result` subcommand — never from a pipe exit code
- [ ] `bash .claude/scripts/lean-sorry-census.sh FormalSystem` reports `sorry_count: 0` at the end
      of every phase and at the end of the task
- [ ] `bash scripts/check-module-invariants.sh` exits 0
- [ ] `bash scripts/typst-sync-check.sh` exits 0 (check 2 is the one the new file moves)
- [ ] `bash scripts/readme-lint.sh FormalSystem` exits 0
- [ ] `bash scripts/check-copyright-headers.sh --strict FormalSystem` exits 0
- [ ] `bash .claude/scripts/verify-deploy.sh` exits 0
- [ ] All 14 pinned identifiers resolve at their recorded signatures; no declaration is a weaker
      same-named restatement (see `.claude/rules/plan-compliance.md`'s Statement Fidelity section,
      whose `lean-challenge-snapshot.sh --check` verdict is advisory, not a failure condition)
- [ ] No declaration over `translationFrame` is advertised as choice-free, in a docstring or in a
      verification criterion

## Artifacts & Outputs

- `FormalSystem/Metalogic/Independence/ArchimedeanSharpness.lean` — new module, both countermodels
  and their corollaries
- `FormalSystem/Semantics/DurationClassification.lean` — `exists_gt_nsmul_of_not_archimedean`
- `FormalSystem/Semantics/Correspondence/DurationFrames.lean` — `translationFrame_isDiscrete`
- `FormalSystem/Metalogic/Independence.lean`, `FormalSystem/Metalogic/Independence/README.md` —
  the thirteenth result documented
- `FormalSystem/Metalogic/Independence/ZTimeSharpness.lean`,
  `FormalSystem/Metalogic/Conservativity.lean`, `FormalSystem/Semantics/FrameProperty.lean`,
  `FormalSystem/Metalogic/Conservativity/Z1Countermodel.lean` — prose amended to cite the theorems
- `FormalSystem/ProofSystem/Axioms.lean`,
  `FormalSystem/Metalogic/Independence/StaticFrame.lean` — post-788 `Axiom.z1` drift cleared
- `docs/reference/paper-definitions-of-record.md` — the `prop:archimedean` row's prose
- `FormalSystem.lean`, `typst/generated/status.typ` — regenerated
- `specs/791_prop_archimedean_uz_z1_fail_non_archimedean/summaries/01_uz-z1-fail-non-archimedean-summary.md`
  — completion summary, naming the two identifiers PossibleWorlds task 172 will cite

## Rollback/Contingency

Every phase commits per green sub-step, so the cheap contingency is per-phase: a phase that cannot
close is marked `[BLOCKED]` in this plan with what was tried and the goal state reached, and the
earlier phases' commits stand on their own — Phase 1's two glue lemmas are independently useful,
and Phase 2's module is additive with no consumer, so neither leaves the tree in a half-state.

A `sorry` is never the contingency here: every proof body in Phase 2 is text that already compiled
sorry-free during research, so a failure to reproduce it is a transcription or import problem to
diagnose, not a proof gap to defer.

If a genuine whole-tree rollback is needed, take a snapshot first and then roll back — see
`context/contracts/recovery.md`'s rollback rung for the exact invocation shape, including its
out-of-scope override flag for the deliberate whole-tree case. Do not run the reverting default form
of the snapshot script as a routine start-of-phase checkpoint; an ordinary defensive checkpoint
before risky work uses `--no-revert`, which is durable without reverting the working tree.
