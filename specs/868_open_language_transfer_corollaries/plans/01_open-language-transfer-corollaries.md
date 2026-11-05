# Implementation Plan: Open-Language Transfer Corollaries

- **Task**: 868 - Open-language transfer corollaries (completeness and decidability reductions at ZTime and RTime)
- **Status**: [IMPLEMENTING]
- **Effort**: 5 hours
- **Dependencies**: None
- **Research Inputs**: specs/868_open_language_transfer_corollaries/reports/01_open-language-transfer-corollaries.md
- **Artifacts**: plans/01_open-language-transfer-corollaries.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Nine declarations land in `FormalSystem/Metalogic/Expressiveness/OpenFutureElimination.lean`,
each one a term-mode one-liner over the already-landed `openValidIn_ztime_iff_tr` /
`openValidIn_rtime_iff_tr`, carrying decidability and completeness of open-language (L^▷) validity
back to their L⁺ counterparts. Every statement in this plan is probe-verified: two probe files
compiled against the built tree at exit 0, and the axiom profiles below were measured by
`#print axioms` in that same run. After the declarations, the host module's docstring, the C14
axiom baselines, and four documentation surfaces are brought into agreement, then the full gate
set runs.

The reduction is the deliverable. No antecedent is discharged, no proof system for L^▷ is built,
and nothing is claimed at `.Base` or `.Dense`.

### Research Integration

Four research findings shape this plan decisively:

1. **The naive uniform decidability shape is vacuous and is rejected.** A
   `Decidable (OpenValidIn FrameClass.ZTime φ)` whose hypothesis is
   `∀ ψ, Decidable (PlusValidZTime ψ)` is forced `noncomputable` (its body must evaluate
   `tr hsep φ`, and `tr` is `noncomputable`), and a `noncomputable` declaration of that type is
   inhabited by `Classical.dec` with *no hypothesis at all* — probe 02 compiles exactly that
   witness (`vacuousUniform`). The hypothesis would do no work. Two shapes escape, both compiling
   as plain computable `def`s: the **per-formula** reduction, and the **generic** reduction over
   an explicit translation function. Both land; the vacuous one is rejected *in the module
   docstring* so a later dispatch cannot "simplify" into it.
2. **A third undischarged antecedent must be named**, beyond the two the task description names.
   Besides separation and the L⁺ facts, these reductions inherit an **effectiveness** gap: `tr`
   is noncomputable as defined, so nothing here yields a decision *procedure* for L^▷, nor a
   *recursive* axiomatization of it.
3. **`Decidable`-valued results in this tree are `def`s, never `instance`s**, with a recorded
   rationale (`WitnessFamily/Compression/Assembly.lean`: a global instance "would change instance
   resolution repository-wide"). The task description's phrase "a `Decidable` instance" is
   therefore implemented as a `Decidable`-valued `def`.
4. **`decidable_of_iff`'s first explicit argument must be supplied by hand.** `PlusValidZTime` is
   a plain `def`, so instance search does not unfold it: a `letI := hdec` whose type mentions
   `PlusValidZTime` fails to discharge a `Decidable (PlusValidIn FrameClass.ZTime …)` goal
   (probe 01 hit this exact error). Pass the proposition explicitly; do not write `_`.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` was provided in this dispatch's delegation context and no roadmap flag is set,
so no roadmap consultation applies.

## Goals & Non-Goals

**Goals**:

- `decidableOpenValidIn_of_translation` -- the generic decidability reduction, primary row.
- `openDecider` -- the `Bool`-level twin of that reduction.
- `openDecider_correct` -- its correctness statement.
- `exists_translation_ztime` -- `tr hsep` inhabits the translation slot at `.ZTime`.
- `exists_translation_rtime` -- the `.RTime` mirror.
- `decidableOpenValidZTimeOfTr` -- the per-formula decidability reduction at `.ZTime`.
- `decidableOpenValidRTimeOfTr` -- the per-formula decidability reduction at `.RTime`.
- `openComplete_of_plusComplete_in` -- the completeness reduction, generic in the L⁺ relation.
- `openValid_of_plusSound` -- the soundness mirror, free from the same `iff`.

**Non-Goals**:

- Discharging any antecedent: separation, `Decidable PlusValidZTime` / `Decidable PlusValidRTime`,
  completeness of any L⁺ proof system, or effectiveness of `tr`.
- Building a proof system, axiomatization, soundness or completeness result for L^▷ itself.
- Any statement at `.Base` or `.Dense`, where the translation does not exist.
- Touching any `Independence/` module.
- Adding these rows to `FormalSystem/MainResults.lean` (the elimination layer is deliberately off
  it, for the reason already recorded there).

## Lean Challenge Statements

```lean
import FormalSystem

namespace FormalSystem.Metalogic.Expressiveness

open FormalSystem.Syntax
open FormalSystem.Semantics
open FormalSystem.PlusLanguage
open FormalSystem.OpenLanguage
open FormalSystem.ProofSystem

def decidableOpenValidIn_of_translation (fc : FrameClass) (T : OpenFormula → PlusFormula)
    (hT : ∀ φ : OpenFormula, OpenValidIn fc φ ↔ PlusValidIn fc (T φ))
    (hdec : ∀ ψ : PlusFormula, Decidable (PlusValidIn fc ψ)) (φ : OpenFormula) :
    Decidable (OpenValidIn fc φ) := sorry

def openDecider (T : OpenFormula → PlusFormula) (d : PlusFormula → Bool) :
    OpenFormula → Bool := sorry

theorem openDecider_correct (fc : FrameClass) (T : OpenFormula → PlusFormula)
    (hT : ∀ φ : OpenFormula, OpenValidIn fc φ ↔ PlusValidIn fc (T φ))
    (d : PlusFormula → Bool) (hd : ∀ ψ : PlusFormula, d ψ = true ↔ PlusValidIn fc ψ)
    (φ : OpenFormula) : openDecider T d φ = true ↔ OpenValidIn fc φ := sorry

theorem exists_translation_ztime (hsep : SeparationOver TaskFrame.IsZTime) :
    ∃ T : OpenFormula → PlusFormula,
      ∀ φ : OpenFormula, OpenValidIn FrameClass.ZTime φ ↔
        PlusValidIn FrameClass.ZTime (T φ) := sorry

theorem exists_translation_rtime (hsep : SeparationOver TaskFrame.IsRTime) :
    ∃ T : OpenFormula → PlusFormula,
      ∀ φ : OpenFormula, OpenValidIn FrameClass.RTime φ ↔
        PlusValidIn FrameClass.RTime (T φ) := sorry

def decidableOpenValidZTimeOfTr
    (hsep : SeparationOver TaskFrame.IsZTime) (φ : OpenFormula)
    (hdec : Decidable (PlusValidIn FrameClass.ZTime (tr hsep φ))) :
    Decidable (OpenValidIn FrameClass.ZTime φ) := sorry

def decidableOpenValidRTimeOfTr
    (hsep : SeparationOver TaskFrame.IsRTime) (φ : OpenFormula)
    (hdec : Decidable (PlusValidIn FrameClass.RTime (tr hsep φ))) :
    Decidable (OpenValidIn FrameClass.RTime φ) := sorry

theorem openComplete_of_plusComplete_in {fc : FrameClass} (T : OpenFormula → PlusFormula)
    (hT : ∀ φ : OpenFormula, OpenValidIn fc φ ↔ PlusValidIn fc (T φ))
    (Der : PlusFormula → Prop)
    (hcomp : ∀ ψ : PlusFormula, PlusValidIn fc ψ → Der ψ)
    (φ : OpenFormula) (hv : OpenValidIn fc φ) : Der (T φ) := sorry

theorem openValid_of_plusSound {fc : FrameClass} (T : OpenFormula → PlusFormula)
    (hT : ∀ φ : OpenFormula, OpenValidIn fc φ ↔ PlusValidIn fc (T φ))
    (Der : PlusFormula → Prop)
    (hsound : ∀ ψ : PlusFormula, Der ψ → PlusValidIn fc ψ)
    (φ : OpenFormula) (hd : Der (T φ)) : OpenValidIn fc φ := sorry

end FormalSystem.Metalogic.Expressiveness
```

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| A vacuous `Decidable` row lands (the `noncomputable` + `Classical.dec` shape) | H | M | Every `Decidable`-valued declaration MUST compile **without** the `noncomputable` keyword. A `noncomputable Decidable` is an automatic Phase 1 blocker, not a fix-with-a-keyword. The rejected shape is recorded in the module docstring so it cannot be reintroduced as a "simplification". |
| A row reads as unconditional | H | M | Every row's first explicit argument is a hypothesis (`hsep`, or `T`/`hT`, or `hdec`/`hcomp`/`hsound`), mirroring `openValidIn_ztime_iff_tr`. Every theorem-index Statement cell opens with "Given …". No docstring or README cell may read as if decidability or completeness of L^▷ has been established at any class. |
| C15 second-assertion failure: a theorem-index row whose declaration docstring lacks a `Paper:` line | H | M | `Paper: — (formalization-native; …)` on every new declaration, matching the two landed transfer rows in the same module. C15's `DECL` regex accepts `def` as well as `theorem`, so the `def`-valued rows are checked too. |
| C14 baseline drift: appending to only one heredoc, or at mismatched positions | H | M | Append in matched pairs at the same trailing position in **both** `C14_BASELINE` (around line 2212) and `C14LEAN` (around line 2481), directly after the existing four `Expressiveness` lines (`openTruthAt_iff_tr`, `openValidIn_ztime_iff_tr`, `openValidIn_rtime_iff_tr`, `ofutP_of_futDet` at baseline lines 2351-2354 and `#print axioms` lines 2621-2624), then re-measure. The comparison is exact string equality. |
| `openDecider` has no axiom dependency, so it cannot be baselined at all | M | H (certain) | `C14_OUT` is built by `… \| grep 'depends on axioms'`, which **filters out** the `'…' does not depend on any axioms` line entirely. A baseline line for `openDecider` can therefore never match, and a `#print axioms` line for it in `C14LEAN` would be a silent no-op. Omit `openDecider` from **both** heredocs, and give it no theorem-index row: it is a definition, not a result; `openDecider_correct` carries the row. |
| Concurrency with siblings 864 and 866, both dispatched this cycle with undeclared file scope | M | M | Re-read every target file immediately before editing it. Stage individual files by explicit path, never a directory or glob. Never run `git-snapshot.sh` in its reverting default mode. Treat a build failure outside this task's file set as possibly a sibling's in-flight edit; if a foreign commit or foreign uncommitted modification is observed, STOP and report after checking `git log`. |
| Phase-2 docstring edit breaks module elaboration | L | L | A Lean `/-! … -/` block elaborates; the phase's declared `local` tier builds the module rather than resting on a diff read-through. |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4 | 1, 3 |
| 4 | 5 | 2, 3, 4 |

Phases within the same wave can execute in parallel.

### Phase 1: Land the Nine Reduction Declarations [COMPLETED]

**Goal**: The nine declarations of `## Lean Challenge Statements` exist in the host module,
sorry-free, with hypothesis-leading signatures and a `Paper:` line on each docstring.

**Tasks**:

- [x] Re-read `FormalSystem/Metalogic/Expressiveness/OpenFutureElimination.lean` immediately
      before editing (sibling concurrency).
- [x] Add a new `/-! ## Transfer corollaries: decidability and completeness reductions -/` section
      at the end of the namespace body, after `ofutP_of_futDet` and before
      `end FormalSystem.Metalogic.Expressiveness`.
- [x] Add `decidableOpenValidIn_of_translation` with body
      `letI := hdec (T φ); decidable_of_iff (PlusValidIn fc (T φ)) (hT φ).symm`. It MUST compile
      as a plain `def` -- no `noncomputable`. *(deviation: altered — renamed to `decidableOpenValidInOfTranslation`; the planned snake_case name is rejected by gates C26 and C16's `defsWithUnderscore` linter)*
- [x] Add `openDecider` with body `fun φ => d (T φ)`, and `openDecider_correct` with body
      `(hd (T φ)).trans (hT φ).symm`.
- [x] Add `exists_translation_ztime` with body `⟨tr hsep, openValidIn_ztime_iff_tr hsep⟩`, and
      `exists_translation_rtime` with body `⟨tr hsep, openValidIn_rtime_iff_tr hsep⟩`.
- [x] Add `decidableOpenValidZTimeOfTr` and `decidableOpenValidRTimeOfTr`, each with body
      `letI := hdec; decidable_of_iff (PlusValidIn FrameClass.<C> (tr hsep φ)) (openValidIn_<c>_iff_tr hsep φ).symm`.
      Supply `decidable_of_iff`'s first explicit argument by hand -- `_` fails instance search
      because `PlusValidZTime` is a plain `def`. Both MUST compile as plain `def`s.
- [x] Add `openComplete_of_plusComplete_in` with body `hcomp _ ((hT φ).mp hv)`, and
      `openValid_of_plusSound` with body `(hT φ).mpr (hsound _ hd)`.
- [x] Give every one of the nine a `/-- … -/` docstring whose **first clause names the
      hypothesis**, and which carries a
      `Paper: — (formalization-native; the manuscript sets the restricted modals aside and states
      no translation for them)` line, matching the two landed transfer rows in this same module.
      No docstring may read as if decidability or completeness of L^▷ is established.
- [x] Confirm no new `import` line was added: the module's import surface stays byte-identical.
- [x] Grep the module for `sorry`, `noncomputable def ` on any `Decidable`-valued declaration, and
      the prohibited vacuous shapes (`:= True`, `:= trivial`, `:= Unit`). All must be absent.

**Timing**: 1.25 hours

**Depends on**: none

**Verification Tier**: local

**Tier Justification**: The edit is additive within one file and changes no existing signature, so
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Expressiveness.OpenFutureElimination`
covers its whole blast radius; no downstream module can see anything that did not exist before.

**Scope Hypothesis**: Nine declarations, in one file, with no new import. Confirm at
implementation time by counting the added `def`/`theorem` keywords in the diff and by
`git diff --stat` showing exactly one `.lean` file changed, and confirm the import claim by
`git diff` showing no change above the `/-!` module docstring.

**Files to modify**:

- `FormalSystem/Metalogic/Expressiveness/OpenFutureElimination.lean` - a new trailing section
  carrying the nine declarations and their docstrings.

**Verification**:

- Scoped guarded build green:
  `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Expressiveness.OpenFutureElimination`.
- `lean_verify` (or `#print axioms`) on each of the nine reports zero `sorry`.
- **Blocking check**: no `Decidable`-valued declaration carries `noncomputable`. If Lean demands
  it, the statement shape is wrong -- mark the phase `[BLOCKED]` and raise it rather than adding
  the keyword.
- `grep -n 'Paper:' ` over the added section shows nine `Paper:` lines.

---

### Phase 2: Amend the Host Module Docstring [COMPLETED]

**Goal**: The module docstring states what is proved -- the reduction -- names every undischarged
antecedent including the effectiveness gap, and records the rejected vacuous shape.

**Tasks**:

- [x] Re-read the module immediately before editing (sibling concurrency).
- [x] Extend `## What is proved here` with a bullet for the transfer corollaries, phrased as a
      *reduction* conditional on its hypotheses.
- [x] Add the nine declarations to `## Main Results`.
- [x] Extend `## What is NOT proved here` with all three undischarged antecedents:
      (a) `Decidable PlusValidZTime` / `Decidable PlusValidRTime`, stated nowhere in this tree;
      (b) completeness of any L⁺ proof system at either class, open at every frame class;
      (c) the **effectiveness** gap -- `tr` is noncomputable as defined, so neither a decision
      *procedure* for L^▷ nor a *recursive* axiomatization of it follows from anything here. The
      separation hypothesis that `tr` itself rests on is already named in this section and is
      inherited unchanged by every new row.
- [x] Restate the existing sentence "Nothing here claims a completeness or a decidability result
      for the open-future language or for L⁺" so it stays true and precise under the new rows:
      what is claimed is a *reduction*, with each antecedent undischarged.
- [x] Record the rejected shape explicitly: a uniform
      `Decidable (OpenValidIn FrameClass.ZTime φ)` taking `∀ ψ, Decidable (PlusValidZTime ψ)` is
      forced `noncomputable` and is then inhabited by `Classical.dec` with no hypothesis at all,
      so it carries no content and must not be reintroduced as a simplification of the
      per-formula rows.
- [x] Confirm `## Where it does not apply` still correctly bars `.Base` and `.Dense`, and that no
      new row contradicts it.

**Timing**: 0.75 hours

**Depends on**: 1

**Verification Tier**: local

**Tier Justification**: The edit is confined to the `/-! … -/` module docstring of one file, which
does elaborate, so the scoped guarded build of that single module
(`… -- build FormalSystem.Metalogic.Expressiveness.OpenFutureElimination`) is the cheapest check
that actually covers it -- a diff read-through would not catch a malformed docstring.

**Files to modify**:

- `FormalSystem/Metalogic/Expressiveness/OpenFutureElimination.lean` - module docstring only.

**Verification**:

- Scoped guarded build green (same invocation as Phase 1).
- Read the amended docstring end to end and confirm no sentence can be read as asserting
  decidability or completeness of L^▷ at any class.
- Confirm all three undischarged antecedents plus separation are named by name.

---

### Phase 3: Re-measure and Pin the C14 Axiom Baselines [COMPLETED]

**Goal**: Eight matched baseline pairs are appended to both C14 heredocs, carrying **measured**
axiom profiles, with the explanatory comment block amended to match.

**Tasks**:

- [x] Re-read `scripts/check-module-invariants.sh` immediately before editing.
- [x] Append eight `#print axioms FormalSystem.Metalogic.Expressiveness.<name>` lines to the
      `C14LEAN` heredoc (around line 2481), directly after the existing
      `ofutP_of_futDet` line (around line 2624) -- for the eight declarations **excluding**
      `openDecider`.
- [x] Append eight matching lines at the **same trailing position** in the `C14_BASELINE` heredoc
      (around line 2212), after the existing `ofutP_of_futDet` baseline line (around line 2354).
- [x] Do **not** add `openDecider` to either heredoc. `C14_OUT` is built by
      `… | grep 'depends on axioms'`, which discards the `'…' does not depend on any axioms` line,
      so a baseline line for it could never match and a `#print axioms` line for it would be a
      silent no-op.
- [x] Run `bash scripts/check-module-invariants.sh`, read the reported C14 divergence, and copy
      the **measured** lines verbatim into `C14_BASELINE`. Never type an axiom profile by hand.
- [x] Amend the explanatory comment block above the heredocs (around lines 2162-2175): the count
      ("Eight further matched pairs sit in the open-modal neighbourhood …") changes, the new rows
      are described, and the WHAT THESE LINES DO NOT ASSERT paragraph is extended to state that
      the new pins assert axiom profiles only -- no decidability and no completeness claim for
      L^▷ at any class, and no antecedent discharged.
- [x] Re-run `bash scripts/check-module-invariants.sh` and confirm C14 PASS.

**Timing**: 1 hour

**Depends on**: 1

**Verification Tier**: local

**Tier Justification**: The edit is confined to `scripts/check-module-invariants.sh`, and
`bash scripts/check-module-invariants.sh` run in full is the complete check of that script's own
content -- there is no cheaper covering check and no other file observes the change.

**Scope Hypothesis**: Eight matched pairs (nine declarations minus `openDecider`), appended in two
places in one file. Confirm at implementation time by `grep -c` for the eight names in the script
returning 16 total occurrences, and by C14 reporting PASS on the second run.

**Files to modify**:

- `scripts/check-module-invariants.sh` - the `C14_BASELINE` heredoc, the `C14LEAN` heredoc, and the
  explanatory comment block above them.

**Verification**:

- `bash scripts/check-module-invariants.sh` exits 0 with C14 PASS.
- Expected measured values (predictions from the probe run under the probe namespace, **not** a
  substitute for re-measurement under the final names):
  `decidableOpenValidIn_of_translation` `[propext]`; `openDecider_correct` `[propext]`;
  `exists_translation_ztime` / `exists_translation_rtime`
  `[propext, Classical.choice, Quot.sound]`; `decidableOpenValidZTimeOfTr` /
  `decidableOpenValidRTimeOfTr` `[propext, Classical.choice, Quot.sound]`;
  `openComplete_of_plusComplete_in` `[propext]`; `openValid_of_plusSound` `[propext]`.
  A `[propext]`-only profile is a strict subset of `pcq` and is not a regression.
- Confirm by `git diff` that the two heredocs received the same eight names in the same order.

---

### Phase 4: Bring the Four Documentation Surfaces Into Agreement [COMPLETED]

**Goal**: The theorem index, the Expressiveness README, the Expressiveness aggregator, and the
OpenLanguage README all state the reduction honestly and none of them contradicts another.

**Tasks**:

- [x] Re-read each target file immediately before editing it (sibling concurrency).
- [x] `docs/theorem-index.md`, Expressiveness band: add one row per result for the eight
      declarations that carry a C14 pin (not `openDecider`). Every Statement cell opens with
      "Given …", naming the hypothesis first. The Axioms cell carries the **measured** value from
      Phase 3 plus `pinned:C14`.
- [x] Amend the Expressiveness band preamble (around lines 600-606). Two clauses are now false:
      "The six open-future-elimination rows that follow them" (the count changes) and "no
      completeness or decidability claim for the open-future language is made here **or anywhere
      else**". Replace the second with the precise statement: what is stated is a *reduction* of
      open-language completeness and decidability to their L⁺ counterparts, every antecedent of
      which is undischarged -- so no completeness or decidability result for L^▷ is asserted at
      any class.
- [x] `FormalSystem/Metalogic/Expressiveness/README.md`: update the `OpenFutureElimination.lean`
      line count in the module table (currently `413`) to the measured new value, and amend the
      Key Results bullet (around line 53), which carries the same "no completeness or decidability
      claim is made" sentence, to the reduction statement.
- [x] `FormalSystem/Metalogic/Expressiveness.lean`: amend item 10 of `## Submodules` (around line
      54) and the `## Main Exports` paragraph (around lines 58-64) to name the transfer corollaries
      as conditional reductions. Do **not** add them to `FormalSystem/MainResults.lean` -- the
      elimination layer is deliberately off it, which also keeps C21 untouched.
- [x] `FormalSystem/OpenLanguage/README.md`: line 17 ("L^▷ is **semantic only**: it has no proof
      system, and no axiomatization, soundness or completeness claim is made for `▷` or `◁`") and
      the exclusion-table row ("An axiomatization, soundness or completeness result for `▷` and
      `◁` | **Excluded.**") both remain **true** -- no proof system for L^▷ is built. Add a
      one-clause cross-reference to the conditional reduction in
      `Metalogic/Expressiveness/OpenFutureElimination.lean` so the two surfaces cannot be read as
      contradicting each other.
- [x] Do not touch any `Independence/` module.

**Timing**: 1 hour

**Depends on**: 1, 3

**Verification Tier**: local

**Tier Justification**: These edits change no code semantics; the only machine-checked surfaces
they touch are the C15 theorem-index round-trip and the `Expressiveness.lean` docstring
elaboration, both covered by `bash scripts/check-module-invariants.sh` together with
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Expressiveness`.

**Scope Hypothesis**: Eight new theorem-index rows and four files touched. Confirm at
implementation time by C15's second assertion reporting PASS (it walks every row and requires a
`Paper:` line at each named declaration) and by `git diff --stat` naming exactly these four files.

**Files to modify**:

- `docs/theorem-index.md` - eight new Expressiveness-band rows plus the band preamble.
- `FormalSystem/Metalogic/Expressiveness/README.md` - module-table line count and the Key Results
  bullet.
- `FormalSystem/Metalogic/Expressiveness.lean` - `## Submodules` item 10 and `## Main Exports`.
- `FormalSystem/OpenLanguage/README.md` - a one-clause cross-reference beside the existing
  semantic-only statement.

**Verification**:

- `bash scripts/check-module-invariants.sh` exits 0 with both C15 assertions PASS and C14 PASS.
- Scoped guarded build of `FormalSystem.Metalogic.Expressiveness` green.
- Read all four surfaces plus the Phase 2 docstring together and confirm no cell, bullet, or
  sentence reads as if decidability or completeness of the open language has been established at
  any class, and that none of the four contradicts another.
- Confirm the Expressiveness-band preamble no longer asserts a stale row count.

---

### Phase 5: Full Gate Sweep [NOT STARTED]

**Goal**: The complete gate set is green against its pre-task baselines, with zero sorry and zero
vacuous definitions.

**Tasks**:

- [ ] Guarded **scoped** build:
      `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Expressiveness.OpenFutureElimination`.
- [ ] Guarded **unscoped** build:
      `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build`. Detach as a
      shell-level background job and block on it with the bounded single-call idiom
      (`context/patterns/bounded-build-waiter.md`); never `Bash(run_in_background: true)`.
- [ ] `bash scripts/check-module-invariants.sh` -- green, including C14 and both C15 assertions.
- [ ] `bash scripts/check-metalogic-cycles.sh` -- green, all three assertions PASS (it was green
      before this task; the host module's import surface is unchanged, so no perturbation is
      expected).
- [ ] `bash .claude/scripts/verify-deploy.sh` -- the complete gate set this repository aggregates.
- [ ] Zero-debt sweep: `grep -rn 'sorry' ` over the changed `.lean` files returns nothing, and no
      added declaration matches a prohibited vacuous shape (`:= True`, `:= trivial`, `:= Unit`).
- [ ] Confirm no `Decidable`-valued declaration carries `noncomputable`.
- [ ] Commit with explicit per-file staging (`git add -- <path> …`), never a directory or glob, and
      review `git status --short` and `git diff --staged` first. If a foreign commit or foreign
      uncommitted modification is visible, STOP and report after checking `git log`.

**Timing**: 1 hour

**Depends on**: 2, 3, 4

**Verification Tier**: full

**Files to modify**:

- None. This phase runs gates and commits; any edit it provokes belongs to the phase that owns the
  file.

**Verification**:

- The complete gate set: `bash .claude/scripts/verify-deploy.sh` green, plus
  `bash scripts/check-module-invariants.sh` and `bash scripts/check-metalogic-cycles.sh` green
  against their pre-task baselines, plus the guarded unscoped `lake build` green.
- Zero sorry and zero vacuous definitions in the changed files.
- `git log` confirms exactly this task's commits and no foreign work was staged.

## Testing & Validation

- [ ] All nine declarations compile; the seven non-`openDecider`-only results carry measured C14
      pins.
- [ ] No `Decidable`-valued declaration requires `noncomputable`.
- [ ] Zero `sorry`, zero vacuous definitions.
- [ ] Every landed row's first explicit argument is a hypothesis.
- [ ] No docstring, README cell, theorem-index cell, or comment reads as if decidability or
      completeness of the open language has been established at any class.
- [ ] All three undischarged antecedents (L⁺ decidability, L⁺ completeness, effectiveness of `tr`)
      plus the inherited separation hypothesis are named in the module docstring.
- [ ] Nothing is claimed at `.Base` or `.Dense`.
- [ ] No `Independence/` module touched; no new `import` in the host module.
- [ ] `check-module-invariants.sh` and `check-metalogic-cycles.sh` green against pre-task baselines.

## Artifacts & Outputs

- Nine new declarations in `FormalSystem/Metalogic/Expressiveness/OpenFutureElimination.lean`,
  with an amended module docstring.
- Eight matched C14 baseline pairs in `scripts/check-module-invariants.sh`.
- Eight new theorem-index rows plus an amended Expressiveness-band preamble in
  `docs/theorem-index.md`.
- Amended `FormalSystem/Metalogic/Expressiveness/README.md`,
  `FormalSystem/Metalogic/Expressiveness.lean`, and `FormalSystem/OpenLanguage/README.md`.

## Rollback/Contingency

Every phase's edits are confined to files no other phase owns, so a phase can be reverted
independently by `git revert` of its own commit. The declaration set itself is additive: removing
the trailing section from the host module and the matched pairs from both C14 heredocs restores
the pre-task state exactly, since no existing declaration, signature, or import is modified.

Contingency branches:

- **A `Decidable`-valued declaration will not compile without `noncomputable`** (Phase 1): the
  statement shape is wrong, not the keyword. Mark the phase `[BLOCKED]`, report the goal state,
  and do not add the keyword -- that lands the vacuous shape this task exists to avoid.
- **C14 reports a divergence that re-measurement does not resolve** (Phase 3): the matched pairs
  are at mismatched positions or in only one heredoc. Re-check both insertion points before
  touching any measured value.
- **`check-metalogic-cycles.sh` regresses** (Phase 5): an import was added to the host module
  against this plan's explicit constraint. Remove it; the parametric `Der : PlusFormula → Prop`
  shape needs no import, which is why it was chosen.

Under sibling concurrency, never use `git-snapshot.sh` in its reverting default mode; an ordinary
defensive checkpoint uses `bash .claude/scripts/git-snapshot.sh 868 --no-revert`.

## Decisions

One deliberate scope decision is recorded here for the implementer's benefit:

**The named-Prop layer (`PlusComplete`, `OpenCompleteViaTranslation`,
`openCompleteViaTranslation_of_plusComplete`) is excluded.** The research report verified these
compile and offered them as the `TMMinusComplete`-style option for making the open antecedent
nameable. They are excluded because they mention `PlusDerivable`, which is **not reachable** from
`FormalSystem.OpenLanguage` (verified: unknown identifier), so landing them requires
`import FormalSystem.PlusLanguage.Derivation` in the host module. Keeping the completeness rows
parametric in an abstract `Der : PlusFormula → Prop` leaves the module's import surface
byte-identical, so `check-metalogic-cycles.sh` assertion B cannot be perturbed -- and the
parametric rows already carry the full reduction content. The `PlusDerivable` instantiation is a
one-liner any downstream consumer can write at the point of use.
