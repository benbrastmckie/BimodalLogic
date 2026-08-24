# Implementation Plan: Task #423

- **Task**: 423 - Land the set-based consequence layer (SetDerivable and per-class SetSemanticConsequence*)
- **Status**: [IMPLEMENTING]
- **Effort**: 3 hours
- **Dependencies**: None
- **Research Inputs**: `specs/423_land_set_based_consequence_layer_setderivable_and_per_class_setsemanticconsequence/reports/01_set-consequence-layer-research.md`
- **Artifacts**: plans/01_set-consequence-layer.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Create `FormalSystem/Metalogic/SetConsequence.lean` holding 19 new declarations — the finitary
`SetDerivable` relation, the four per-class `SetSemanticConsequence*` predicates, ten basic
lemmas, and four strong-completeness/compactness/model-existence vocabulary definitions — then
add the import plus the single theorem `strongCompletenessDense_of_compact` to
`FormalSystem/Metalogic/StrongCompleteness.lean`. This is vocabulary only: it proves no
compactness result and closes no existing sorry. The governing design document is
`specs/archive/361_strong_completeness_architecture_and_weak_terminus_gap_analysis/design/01_set-consequence-layer.md`
(hereafter **design/01**), sections 2–5; section 7 records what is deliberately out of scope.

### Research Integration

The research report is unusually load-bearing here: its section 2 contains the **complete module
text, empirically verified to compile** against the live oleans via `lean_run_code`, with zero
diagnostics and no `sorryAx` on any of the 19 declarations. Two divergences from design/01 drive
the plan:

- **D1 (critical)** — design/01 §3/§5 write every binder list with an `(Omega : Set (WorldHistory F))
  (_ : ShiftClosed Omega) (τ : WorldHistory F) (_ : τ ∈ Omega)` block against a five-ary `TruthAt`.
  The live tree has no `ShiftClosed` outside `Boneyard/`, `TruthAt` is four-ary (`TruthAt M τ t φ`),
  and every validity predicate now uses the single totality binder `(_ : τ.IsTotal)`. Transcribing
  design/01 verbatim would fail to elaborate at all. **Where design/01 and `Validity.lean` disagree,
  `Validity.lean` wins** — acceptance criterion 3 binds against the current file. The in-tree
  template for exactly this surgery is `SemanticConsequenceDedekindDense`
  (`FormalSystem/Metalogic/StrongCompleteness.lean:129`), which is `ValidDedekindDense`'s binder
  list with the premise hypothesis inserted; the only difference here is `Γ : Set Formula` rather
  than `Γ : Context`.
- **D2 (blocking)** — design/01 §5's `strongCompletenessDense_of_compact` uses
  `derivable_foldr_imp_iff`, which lives **only** in `StrongCompleteness.lean` (:222), the module
  that imports `SetConsequence.lean`. Placing the theorem in the new module is an import cycle.
  Research recommends **Option C**: keep the three §5 definitions plus `StrongCompletenessDense`
  in `SetConsequence.lean` and place the one theorem in `StrongCompleteness.lean` below
  `derivable_foldr_imp_iff`. Both files are in `file_scope`, so no scope widening is needed, and
  both edits are pure additions. This plan adopts Option C. Option M (relocating the three
  `foldr_imp` lemmas downward) is **not** taken — it costs docstring bookkeeping at
  `StrongCompleteness.lean:93`, `:95`, and `:371` for no gain. Under no circumstances duplicate
  those lemmas into both files.

Design/01 §4's three flagged elaboration risks were all settled empirically by the research and
are pre-resolved in the phase text below: (1) `hd.weaken hL` does **not** go through, but
`hd.weaken (fun _ hx => hL _ hx)` does; (2) `not_setConsistent_of_setDerivable_bot` needs **no**
`simp only [Core.Consistent]` unfold; (3) `DerivationTree.assumption` is arity-3 as design/01
guessed (`ProofSystem/Derivation.lean:105`), so the fragment compiles as written.

The four `Validity.lean` line hints in the task description were re-verified by symbol this
session and are all correct: `valid` :94, `ValidDense` :206, `ValidDiscrete` :222,
`ValidDedekindDense` :310. Design/01's own table (79/169/187/276) has drifted — do not use it.
The `Type` (not `Type*`) doc-comment is at `Validity.lean:92`.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No roadmap context was provided in this delegation; `specs/ROADMAP.md` was not loaded for this
plan.

## Goals & Non-Goals

**Goals**:
- Create `FormalSystem/Metalogic/SetConsequence.lean` with all 19 declarations at zero sorries.
- Carry design/01's docstrings across, D1-corrected (Omega/ShiftClosed references edited out) and
  with cited line numbers refreshed against the current tree.
- Add `import FormalSystem.Metalogic.SetConsequence` plus `strongCompletenessDense_of_compact` to
  `FormalSystem/Metalogic/StrongCompleteness.lean`.
- Satisfy all five design/01 §6 acceptance criteria, including a real `lake build`.

**Non-Goals**:
- Proving any compactness result. `CompactDense` is a `Prop` definition, never discharged here.
- Closing any existing sorry anywhere in the tree.
- `SetSemanticConsequenceDedekind` (against `ValidDedekind`, now at `Validity.lean:275`) —
  out of scope per design/01 §7.
- `consequence_completeness_*` for Base/Dense/Discrete.
- Relocating `truthAt_foldr_imp` (`StrongCompleteness.lean:147`) — it is not needed by anything
  in scope and stays put.
- Editing `FormalSystem/Metalogic.lean`. It already imports `StrongCompleteness`, so the new
  module is transitively reachable from the library root; the aggregator is outside `file_scope`.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Implementer transcribes design/01 §3/§5 verbatim, reintroducing `Omega`/`ShiftClosed` | H | M | Phase 1 and 3 text below is the D1-corrected version; slice binder blocks mechanically from `Validity.lean`, never from design/01 |
| Wrong `_` count in the four `_mono` `intro` patterns (Base 4, Dense 5, Discrete 8, DedekindDense 5 + named `hlub`) | M | H | Research names this the likeliest slip; Phase 2 records the counts explicitly and each lemma builds before the next is added |
| `strongCompletenessDense_of_compact` placed in `SetConsequence.lean`, creating an import cycle | H | M | D2 is called out in Overview, Phase 3 non-goals, and Phase 4 goal; the theorem is Phase 4's sole deliverable |
| A `BXCanonical` import creeps in via a convenience fix | M | L | Acceptance criterion 2 is a hard grep in Phase 5; nothing in the module needs it |
| `Type*` used instead of bare `Type` | M | L | All four `Validity.lean` sources use bare `Type` (doc-comment at :92); mechanical slicing preserves this |
| `Validity.lean` line hints drift before implementation | L | L | Re-verify all four by symbol, not by line number, before slicing |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |

Phases within the same wave can execute in parallel. This plan is strictly sequential: phases 1–3
all append to the same new file (same-file serialization), phase 4 consumes the definitions phase
3 lands, and phase 5 is the terminal gate.

---

### Phase 1: Create SetConsequence.lean — header, imports, SetDerivable, four per-class predicates [COMPLETED]

**Goal**: The new module exists and builds, containing design/01 §2 (`SetDerivable`) and §3 (the
four `SetSemanticConsequence*` predicates), D1-corrected.

**Tasks**:
- [ ] Create `FormalSystem/Metalogic/SetConsequence.lean` with the standard copyright header
      (copy the 5-line block from `FormalSystem/Metalogic/StrongCompleteness.lean:1-5`).
- [ ] Write the import block, exactly: `FormalSystem.Syntax.Formula`,
      `FormalSystem.Semantics.Truth`, `FormalSystem.Semantics.Validity`,
      `FormalSystem.ProofSystem.Derivable`, `FormalSystem.Metalogic.Core.MaximalConsistent`.
      **No `FormalSystem.Metalogic.BXCanonical` import** — nothing here needs one.
      (`Semantics.Validity` alone would suffice transitively, but the explicit list documents
      intent and matches design/01 §1 minus its now-gone `ShiftClosed` entry.)
- [ ] Add `namespace FormalSystem.Metalogic` and
      `open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.ProofSystem`.
- [ ] Write the module docstring, adapting design/01's, stating this is a vocabulary-only layer.
- [ ] Write `SetDerivable` (design/01 §2, unchanged):
      `def SetDerivable (fc : FrameClass) (Γ : Set Formula) (φ : Formula) : Prop := ∃ L : List Formula, (∀ ψ ∈ L, ψ ∈ Γ) ∧ Derivable fc L φ`
- [ ] Locate `valid`, `ValidDense`, `ValidDiscrete`, `ValidDedekindDense` in
      `FormalSystem/Semantics/Validity.lean` **by symbol** (hints only: :94, :206, :222, :310).
- [ ] For each, slice the binder block mechanically — from the line after the `def` header to the
      line before `TruthAt M τ t φ` — and paste it under the new `def` name, inserting only
      `(∀ ψ ∈ Γ, TruthAt M τ t ψ) →` before the conclusion. Preserve the source's
      line-continuation and indentation verbatim, including `ValidDense`'s and
      `ValidDedekindDense`'s wrapping of `[Nontrivial D]` onto its own line. Use bare `Type`,
      never `Type*`.
- [ ] Confirm the four resulting headers are `SetSemanticConsequenceBase`,
      `SetSemanticConsequenceDense`, `SetSemanticConsequenceDiscrete`,
      `SetSemanticConsequenceDedekindDense`, each `(Γ : Set Formula) (φ : Formula) : Prop`.
- [ ] Carry design/01 §3's per-definition docstrings across, editing out every `Omega` /
      `ShiftClosed` / `τ ∈ Omega` reference and refreshing cited line numbers.
- [ ] Add `end FormalSystem.Metalogic`.
- [ ] `lake build FormalSystem.Metalogic.SetConsequence`.

**Timing**: 0.75 hours

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: This phase asserts 5 declarations (`SetDerivable` plus 4
`SetSemanticConsequence*` predicates) and a 5-entry import list. Confirm at implementation time by
counting `^def ` occurrences in the new file (expect exactly 5) and `^import ` (expect exactly 5).
The four `Validity.lean` line hints are a hypothesis about the current tree, not a fact: re-verify
each by symbol before slicing, and if a line has drifted, trust the symbol.

**Files to modify**:
- `FormalSystem/Metalogic/SetConsequence.lean` - new file; header, imports, namespace,
  `SetDerivable`, four `SetSemanticConsequence*` definitions.

**Verification**:
- `lake build FormalSystem.Metalogic.SetConsequence` succeeds with zero errors.
- `grep -c 'import FormalSystem.Metalogic.BXCanonical' FormalSystem/Metalogic/SetConsequence.lean`
  returns `0`.
- `grep -c 'Type\*' FormalSystem/Metalogic/SetConsequence.lean` returns `0`.
- `grep -c 'Omega\|ShiftClosed' FormalSystem/Metalogic/SetConsequence.lean` returns `0`.
- Diff each new binder block against its `Validity.lean` source; the only difference is the
  inserted premise hypothesis line.

---

### Phase 2: Add the ten basic lemmas (design/01 §4) [COMPLETED]

**Goal**: All ten §4 lemmas are present, proved, and building — with the three design/01
elaboration risks resolved as the research determined.

**Tasks**:
- [ ] Add `setDerivable_mono` (`obtain ⟨L, hL, hd⟩ := h; exact ⟨L, fun ψ hψ => h_sub (hL ψ hψ), hd⟩`).
- [ ] Add the four sibling `_mono` lemmas. These are **not** verbatim copies of one another: each
      `intro` pattern carries one `_` per instance binder —
      `setSemanticConsequenceBase_mono` takes **4**, `..._Dense_mono` **5**, `..._Discrete_mono`
      **8**, and `...DedekindDense_mono` **5 plus a named `hlub`** (its LUB hypothesis is
      explicit, so it must be threaded to `h` as `h D hlub F M τ hτ t`). Research flags a wrong
      count here as the likeliest transcription slip.
- [ ] Add `setDerivable_iff_exists_finite`, proved by `Iff.rfl`.
- [ ] Add `setDerivable_of_derivable` (`⟨Γ, fun _ hψ => hψ, h⟩`), taking `Γ : Context` to
      `Core.contextToSet Γ`.
- [ ] Add `derivable_of_setDerivable_contextToSet`. **Risk 1 resolution**: bare `hd.weaken hL`
      does not elaborate; use `hd.weaken (fun _ hx => hL _ hx)`. (`Derivable.weaken` is
      `ProofSystem/Derivable.lean:147`; `Core.contextToSet Γ = {φ | φ ∈ Γ}` at
      `MaximalConsistent.lean:123`, so eta-expansion is all that is needed.)
- [ ] Add `setDerivable_of_mem`:
      `⟨[φ], by simpa using h, ⟨DerivationTree.assumption _ _ (by simp)⟩⟩`. **Risk 3 resolution**:
      `DerivationTree.assumption` is arity 3 (`ProofSystem/Derivation.lean:105`) and `Derivable`
      is `Nonempty (DerivationTree ...)` (`Derivable.lean:69`), so the outer `⟨…⟩` is
      `Nonempty.intro`.
- [ ] Add `not_setConsistent_of_setDerivable_bot`. **Risk 2 resolution**: no
      `simp only [Core.Consistent]` unfold is needed — `exact fun hcons => hcons L hL hd`
      elaborates as written, since `Core.SetConsistent` (`MaximalConsistent.lean:96`) and
      `Consistent` (`:67`) unfold definitionally.
- [ ] Carry design/01 §4's docstrings across, D1-corrected.
- [ ] `lake build FormalSystem.Metalogic.SetConsequence`.

**Timing**: 0.75 hours

**Depends on**: 1

**Verification Tier**: local

**Scope Hypothesis**: This phase asserts exactly 10 lemmas and specific `intro`-underscore counts
(4/5/8/5+hlub). Confirm by counting `^theorem ` in the new file after this phase (expect exactly
10) and by letting the build — not inspection — adjudicate each `intro` pattern; if a count is
wrong the error is a binder-arity mismatch at that lemma, fix it there rather than adjusting the
`h` application.

**Files to modify**:
- `FormalSystem/Metalogic/SetConsequence.lean` - append the ten §4 lemmas.

**Verification**:
- `lake build FormalSystem.Metalogic.SetConsequence` succeeds with zero errors and zero warnings.
- `grep -c 'sorry' FormalSystem/Metalogic/SetConsequence.lean` returns `0`.
- No lemma is stubbed with `trivial`, `True`, or any vacuous body.

---

### Phase 3: Add the four §5 vocabulary definitions [COMPLETED]

**Goal**: `StrongCompletenessDense`, `CompactDense`, `SatisfiableDenseSet`, and
`ModelExistenceDense` land in `SetConsequence.lean` as pure vocabulary.

**Tasks**:
- [ ] Add `StrongCompletenessDense : Prop` —
      `∀ (Γ : Set Formula) (φ : Formula), SetSemanticConsequenceDense Γ φ → SetDerivable FrameClass.Dense Γ φ`.
      Note `FrameClass` (`ProofSystem/Axioms.lean:519`) has constructors
      `Base | Dense | Discrete | Dedekind` — there is **no** `.DedekindDense` constructor;
      `FrameClass.Dense` is correct here.
- [ ] Add `CompactDense : Prop`, concluding
      `∃ L : List Formula, (∀ ψ ∈ L, ψ ∈ Γ) ∧ ValidDense (L.foldr Formula.imp φ)`.
- [ ] Add `SatisfiableDenseSet (Γ : Set Formula) : Prop`. This is `FormulaSatisfiable`
      (`Validity.lean:190`) with `(_ : DenselyOrdered D)` inserted in `ValidDense`'s binder
      position and the conclusion generalised to `∀ ψ ∈ Γ, TruthAt M τ t ψ`. The existentials over
      instance-valued binders are precedented by `FormulaSatisfiable` itself and are not an
      elaboration risk.
- [ ] Add `ModelExistenceDense : Prop`, quantifying over finite sublists via `{ψ | ψ ∈ L}`.
- [ ] Carry design/01 §5's docstrings across for these four, D1-corrected.
- [ ] **Do not** add `strongCompletenessDense_of_compact` here — it needs
      `derivable_foldr_imp_iff`, which lives only in `StrongCompleteness.lean` (:222), the module
      that imports this one. Adding it here is an import cycle (D2). It is Phase 4's deliverable.
- [ ] `lake build FormalSystem.Metalogic.SetConsequence`.

**Timing**: 0.5 hours

**Depends on**: 2

**Verification Tier**: local

**Scope Hypothesis**: This phase asserts 4 definitions, bringing the module to 19 declarations
total (5 + 10 + 4). Confirm by counting `^def ` (expect 9 cumulative) and `^theorem ` (expect 10)
in the new file.

**Files to modify**:
- `FormalSystem/Metalogic/SetConsequence.lean` - append the four §5 definitions.

**Verification**:
- `lake build FormalSystem.Metalogic.SetConsequence` succeeds.
- `grep -c 'derivable_foldr_imp' FormalSystem/Metalogic/SetConsequence.lean` returns `0`
  (confirming no cycle-inducing reference slipped in).
- Total declaration count in the module is 19.

---

### Phase 4: Wire StrongCompleteness.lean — import plus strongCompletenessDense_of_compact [COMPLETED]

**Goal**: `StrongCompleteness.lean` imports the new module and hosts the one §5 theorem, per
Option C.

**Tasks**:
- [ ] Add `import FormalSystem.Metalogic.SetConsequence` to `StrongCompleteness.lean`'s import
      block (currently lines 7–10).
- [ ] Locate `derivable_foldr_imp_iff` **by symbol** (hint: :222) and add
      `strongCompletenessDense_of_compact` below it, verbatim from design/01 §5:
      hypotheses `(hc : CompactDense)` and
      `(engine : ∀ ψ : Formula, ValidDense ψ → Derivable FrameClass.Dense [] ψ)`, concluding
      `StrongCompletenessDense`; proof
      `intro Γ φ h; obtain ⟨L, hL, hvalid⟩ := hc Γ φ h; exact ⟨L, hL, (derivable_foldr_imp_iff L φ).mpr (engine _ hvalid)⟩`.
- [ ] Add a docstring noting that `BXCanonical.completeness_dense` (`Completeness.lean:256`) has
      exactly the `engine` hypothesis shape, so the hypothesis is live for the downstream Dense
      branch — but do **not** consume it here.
- [ ] Make no deletions, no relocations, and no docstring churn elsewhere in the file. In
      particular do **not** move `derivable_of_derivable_foldr_imp`,
      `derivable_foldr_imp_of_derivable`, or `derivable_foldr_imp_iff` into `SetConsequence.lean`
      (that is Option M, rejected), and do **not** duplicate them.
- [ ] `lake build FormalSystem.Metalogic.StrongCompleteness`.

**Timing**: 0.5 hours

**Depends on**: 3

**Verification Tier**: interface

**Files to modify**:
- `FormalSystem/Metalogic/StrongCompleteness.lean` - one added import line; one added theorem
  after `derivable_foldr_imp_iff`.

**Verification**:
- `lake build FormalSystem.Metalogic.StrongCompleteness` succeeds.
- Build the one enumerated direct dependent, `FormalSystem/Metalogic.lean`, which already imports
  `StrongCompleteness` and needs no edit.
- `git diff --stat FormalSystem/Metalogic/StrongCompleteness.lean` shows insertions only, zero
  deletions.
- `grep -c 'truthAt_foldr_imp' FormalSystem/Metalogic/StrongCompleteness.lean` is unchanged from
  its pre-edit value (the lemma stayed put).

---

### Phase 5: Acceptance gate — all five design/01 §6 criteria [COMPLETED]

**Goal**: Every acceptance criterion in the task description is demonstrated by a command whose
output is recorded, not by assertion.

**Tasks**:
- [ ] **Criterion 1** — zero sorries and zero vacuous placeholders. `grep -rn 'sorry' ` over both
      files returns nothing; read every declaration body and confirm it has real content.
- [ ] **Criterion 2** —
      `grep -c 'import FormalSystem.Metalogic.BXCanonical' FormalSystem/Metalogic/SetConsequence.lean`
      returns `0`.
- [ ] **Criterion 3** — for each of the four `SetSemanticConsequence*` definitions, diff its
      binder list against its `Validity.lean` source (`valid`, `ValidDense`, `ValidDiscrete`,
      `ValidDedekindDense`) and confirm the sole difference is the inserted premise hypothesis.
      Confirm bare `Type` throughout (the "deliberate" doc-comment is at `Validity.lean:92`).
- [ ] **Criterion 4** — run `#print axioms` on all 19 new declarations plus
      `strongCompletenessDense_of_compact`. Expect `[propext]` on most and
      `[propext, Quot.sound]` on `setDerivable_of_mem`; **no `sorryAx` anywhere**.
- [ ] **Criterion 5** — full `lake build` from the repository root succeeds. This is the one
      criterion that could not be pre-verified from snippets during research; it must actually be
      run.
- [ ] Confirm the out-of-scope list is genuinely untouched: no `SetSemanticConsequenceDedekind`,
      no compactness proof, no `consequence_completeness_*` additions, no `truthAt_foldr_imp`
      relocation, no edit to `FormalSystem/Metalogic.lean`.

**Timing**: 0.5 hours

**Depends on**: 4

**Verification Tier**: full

**Scope Hypothesis**: This phase asserts a 20-declaration axiom sweep (19 in the new module plus
`strongCompletenessDense_of_compact`) and a specific expected axiom profile. Confirm the count
against the actual declaration list extracted from the two files rather than from this number;
the axiom profile is a research observation, so an extra benign axiom (e.g. `Classical.choice`
arriving through a dependency) is acceptable — only `sorryAx` is a failure.

**Files to modify**:
- None. This phase is verification only.

**Verification**:
- `lake build` from the repository root exits 0.
- All five criteria have recorded command output, not a claim.
- If any criterion fails, the phase does not close; fix in the owning phase's file and re-run the
  gate.

---

## Testing & Validation

- [ ] `lake build` succeeds from the repository root with zero errors.
- [ ] Zero `sorry` occurrences in `SetConsequence.lean` and in the `StrongCompleteness.lean` diff.
- [ ] `#print axioms` reports no `sorryAx` on any of the 20 new declarations.
- [ ] `grep -c 'import FormalSystem.Metalogic.BXCanonical' FormalSystem/Metalogic/SetConsequence.lean`
      returns `0`.
- [ ] `grep -c 'Type\*' FormalSystem/Metalogic/SetConsequence.lean` returns `0`.
- [ ] Each of the four `SetSemanticConsequence*` binder lists diffs against its `Validity.lean`
      source with only the premise hypothesis inserted.
- [ ] `git diff` touches exactly the two files in `file_scope` and no others.

## Artifacts & Outputs

- `FormalSystem/Metalogic/SetConsequence.lean` — new module, 19 declarations, zero sorries.
- `FormalSystem/Metalogic/StrongCompleteness.lean` — one added import, one added theorem
  (`strongCompletenessDense_of_compact`), insertions only.
- Recorded acceptance-gate output for all five design/01 §6 criteria.

## Rollback/Contingency

Both edits are additive and confined to two files. To revert: delete
`FormalSystem/Metalogic/SetConsequence.lean` and `git checkout --
FormalSystem/Metalogic/StrongCompleteness.lean`. Nothing else in the tree depends on the new
module, and `FormalSystem/Metalogic.lean` is untouched, so the tree returns to its pre-task build
state with no further cleanup.

If Phase 4 unexpectedly reveals a cycle or scope problem that Option C does not resolve, the
documented fallback is Option M from the research report — relocate
`derivable_of_derivable_foldr_imp`, `derivable_foldr_imp_of_derivable`, and
`derivable_foldr_imp_iff` from `StrongCompleteness.lean` into `SetConsequence.lean` (verified to
reproduce character-for-character in the new import context) and transcribe §5 verbatim, then
update the three docstring citations at `StrongCompleteness.lean:93`, `:95`, and `:371`. Move or
don't — never duplicate into both files.
