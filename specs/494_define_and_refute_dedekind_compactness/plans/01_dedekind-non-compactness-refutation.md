# Implementation Plan: Task #494

- **Task**: 494 - define_and_refute_dedekind_compactness
- **Status**: [COMPLETED]
- **Effort**: 6 hours
- **Dependencies**: None outstanding (the compactness parameterization prerequisite has landed — the `FrameClass`-indexed family is live in `SetConsequence.lean`)
- **Research Inputs**: `specs/494_define_and_refute_dedekind_compactness/reports/01_dedekind-noncompactness-witness.md`
- **Artifacts**: plans/01_dedekind-non-compactness-refutation.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Settle `FrameClass.Dedekind` negatively and complete the four-class compactness picture. Part 1
is four one-line instantiations of the post-parameterization `FrameClass`-indexed family in
`SetConsequence.lean` (no fourth hand copy). Part 2 is the real content: a **new**
non-compactness witness, since `archWitness` does not port — it turns on `[SuccOrder]` +
`[IsSuccArchimedean]`, and over a densely ordered carrier `Formula.next φ = untl ⊥ φ` is
vacuously false at every point. The research pass built and machine-verified the complete module
out of tree (`lake env lean`, sorry-free, `#print axioms = [propext, Classical.choice,
Quot.sound]` on all four headline results). This plan **transcribes that verified reference and
re-verifies it in tree** — an out-of-tree verification is not an in-tree one — then reconciles
the documentation debt the result creates.

Definition of done: `dedekind_consequence_not_compact` and `strongCompletenessDedekind_refuted`
are sorry-free in tree, `lake build` is green, `#print axioms` on all four headline results
reports exactly `[propext, Classical.choice, Quot.sound]`, and no passage in `FormalSystem/`
still asserts that the tree contains no Dedekind refutation.

### Research Integration

The research report is treated as a **verified reference implementation to transcribe**, not a
sketch to re-derive. Its §7 module source is the authoritative text for Phases 2-4. Findings
carried directly into the phase structure:

- **Part 1 is free.** `SatisfiableSet` / `ModelExistence` / `Compact` / `StrongCompleteness` are
  live at `SetConsequence.lean:153,163,174,184`; the `.Dedekind` adapters
  (`SatisfiableSet.dedekind_of_forall:325`, `SetSemanticConsequenceDedekindDense.of_forall:271` /
  `.apply:280`) already exist. No new adapter, no new binder list.
- **The witness** is `{G(⊤ S ¬q), F(G ¬q)} ∪ {Xqⁿ⊤ : n ∈ ℕ}` with
  `Xq φ = untl ¬q (q ∧ φ)`. The infinite ω-family `{αₙ}` is load-bearing: it replaces the single
  formula `G(q → F q)` so that every *finite* subset stays Dedekind-satisfiable. A finite
  unsatisfiable set refutes nothing.
- **Two transcription hazards.** (a) The ℝ frame must come from `ShiftSet` — `natFrame` carries
  `[SuccOrder] [NoMaxOrder]` and does not elaborate over ℝ, and `staticFrame`'s task relation
  forces constant-state histories — and both `realOrder` and `rShift` must be `@[reducible]` or
  `DenselyOrdered (rShift q N).frame.Duration` fails to synthesize. (b)
  `haveI : DenselyOrdered F.Duration := hd` is required in both refutations, because
  `TaskFrame.IsDense` is a `def` whose head is not `DenselyOrdered` and a destructured
  `hd : F.IsDense` is invisible to instance search.
- **`archWitness` and its lemmas are not reused.** Only `DiscreteNonCompactness.lean`'s *file
  shape* (finitely-satisfiable half, then unsatisfiable half) carries over.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

`specs/ROADMAP.md` exists but no `roadmap_path` was passed in the delegation context, so no
roadmap phases are added. Read-only consultation shows this task advances the compactness/
strong-completeness leg recorded at `ROADMAP.md:74-75` ("Legs ... C/D (Discrete/Dedekind
non-compactness record, LaTeX alignment)") and falsifies the summary sentence at
`ROADMAP.md:96-97` ("Dedekind: Reynolds 1992 Theorem 7 is weak-only"). ROADMAP.md is **not**
modified by this plan; updating it is outside this task's scope.

## Goals & Non-Goals

**Goals**:
- Name the four `.Dedekind` members of the `FrameClass`-indexed family as single instantiations.
- Land a new, sorry-free non-compactness witness for `FrameClass.Dedekind` in a new module.
- Refute `CompactDedekind` and `StrongCompletenessDedekind` in tree.
- Audit axioms (`#print axioms`) on all four headline results and confirm zero `sorry`.
- Reconcile every in-tree passage that asserts no Dedekind refutation exists.

**Non-Goals**:
- Touching `DiscreteNonCompactness.lean`. It is named in `state.json`'s `file_scope` but the
  research establishes that **none** of its lemmas port; it contains no Dedekind claim
  (`grep -n Dedekind` returns nothing) and needs no edit. See File Scope Divergence below.
- Re-deriving the witness design. §6 of the research records four rejected alternatives with
  reasons; do not re-litigate them.
- Modifying `specs/ROADMAP.md`, the LaTeX paper (`possible_worlds.tex`), or any Base/Dense
  compactness result. The ultraproduct chain remains independent and untouched.
- Adding a `ModelExistenceDedekind`-based proof. `ModelExistenceDedekind` is defined (Part 1
  vocabulary) but nothing is proved about it here.

## File Scope Divergence (explicit)

`state.json`'s `file_scope` for this task names exactly two files. The plan's actual file set is
five. This divergence is recorded here so it is visible rather than silent:

| File | In declared `file_scope`? | This plan touches it? | Note |
|------|---------------------------|-----------------------|------|
| `FormalSystem/Metalogic/StrongCompleteness.lean` | yes | yes (Phase 5, docs only) | 5 doc hunks |
| `FormalSystem/Metalogic/DiscreteNonCompactness.lean` | yes | **no** | No lemma ports; contains no Dedekind claim |
| `FormalSystem/Metalogic/SetConsequence.lean` | **no** | yes (Phases 1, 5) | Part 1 lives here |
| `FormalSystem/Metalogic/DedekindNonCompactness.lean` | **no** | yes (Phases 2-4) | **New file** |
| `FormalSystem/Metalogic.lean` | **no** | yes (Phases 2, 5) | Import + 2 doc hunks |
| `FormalSystem/Metalogic/Compactness.lean` | **no** | yes (Phase 5, docs only) | 1 doc hunk (missed by research §8) |
| `FormalSystem/Metalogic/README.md` | **no** | yes (Phase 5) | Module table row + line count |

The implementer should expect the lock-overlap check to be computed against the two declared
paths only; the four additional `.lean` files and one `.md` file above are the real write set.

## Decision: at what generality is unsatisfiability stated

The research established (executive summary item 4) that the unsatisfiability half uses **only**
Dedekind completeness — density is never invoked — so the witness is unsatisfiable over every
`TaskFrame.IsComplete` frame, ℤ included. **Decision: state both, at the level the verified
source already does.**

- `dedWitness_core` takes `hlub : ∀ s : Set F.Duration, s.Nonempty → BddAbove s → ∃ x, IsLUB s x`
  with **no density binder**. That hypothesis is `TaskFrame.IsComplete F` unfolded verbatim
  (`Semantics/FrameProperty.lean:142`), so the general theorem is already stated; its docstring
  must say so explicitly, and must record that ℤ is covered.
- `dedWitness_not_satisfiable` — the headline — is stated at `SatisfiableDedekindSet`, i.e. at
  the Dedekind class.

**Reason**: (1) it costs zero additional proof — it is what the machine-verified module does;
(2) the headline names must match the task's acceptance criteria and mirror the Discrete file's
shape, which downstream docs cite; (3) stating the general fact once at the core, rather than
duplicating a class-specific proof, is exactly the systematicity discipline (review issue H3)
that rescoped Part 1 away from a fourth hand copy.

**Bounded refinement, Phase 2**: try restating the binder as `(hlub : F.IsComplete)`. Confirm
with `example (F : TaskFrame) : F.IsComplete = (∀ s : Set F.Duration, s.Nonempty → BddAbove s →
∃ x, IsLUB s x) := rfl`. If that `rfl` goes through, prefer the named form and delete the
`example`; if it does not, keep the unfolded form the research verified and record the reason in
the docstring. Do not spend more than one attempt on this.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Reducibility trap: dropping `@[reducible]` on `realOrder`/`rShift` breaks instance synthesis and `(0 : Carrier)` elaboration | H | M | Transcribe the attributes verbatim from research §7; the failure is named in §5 with its exact symptom |
| Instance-search trap: destructured `hd : F.IsDense` invisible to instance search | H | M | `haveI : DenselyOrdered F.Duration := hd` in **both** refutations; §5 confirms `haveI` is safe here (unlike the Discrete case) because no `DenselyOrdered` instance is baked into `F`'s or `M`'s type |
| Cast friction: `F.Duration.carrier` is `ℝ` only up to reducible unfolding; `norm_cast` does not see through it | M | H | Restate as explicit ℝ hypotheses (`have h' : ((k:ℤ):ℝ) < ((j:ℤ):ℝ) := h`) before `exact_mod_cast`; research flags ~3 such sites |
| New module is not built because `lake build` uses `roots := #[FormalSystem]`, not a glob | H | M | Add the `Metalogic.lean` import in **Phase 2**, not Phase 5, so the module enters the build closure the moment it exists. Chain confirmed: `FormalSystem.lean → FormalSystem/FormalSystem.lean:12 → Metalogic.lean` |
| Research §8's "six sites" is an undercount | M | H (confirmed) | A reproducible grep in Phase 5 replaces the fixed list; at least 13 hits across 4 files were found during planning, plus README. Phase 5 carries a Scope Hypothesis |
| Adding `Mathlib.Data.Real.Basic` inflates the `Metalogic` import closure | L | L | Already defused: `Semantics/ShiftSet.lean` imports `Mathlib.Data.Real.*`, so importing `ShiftSet` pulls it regardless. The explicit `Mathlib.Data.Real.Basic` line is redundant — the implementer may keep or drop it |
| Cosmetic `push_cast` warning in `rTruth_alpha` | L | H (known) | Drop the `⊢` from `by push_cast at hkN ⊢; omega` as research §7 notes |
| Uniqueness-of-next-`q`-point step fails to transcribe | H | L | Research reports it verified; fallback recorded in §6 (indexed atoms `c₀, c₁, …`) — but that fallback is **worse** and should be reached for only if the trichotomy argument genuinely fails |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |

Phases within the same wave can execute in parallel. This plan is fully sequential: Phases 2-4
all write the same new module, and Phase 5's doc claims are only made true by Phase 4.

---

### Phase 1: Part 1 — the four Dedekind instantiations [COMPLETED]

**Goal**: Name `StrongCompletenessDedekind`, `CompactDedekind`, `SatisfiableDedekindSet` and
`ModelExistenceDedekind` as single instantiations of the `FrameClass`-indexed family, and repair
the two `SetConsequence.lean` claims that naming them immediately falsifies.

**Tasks**:
- [x] Add the four defs to `SetConsequence.lean`, beside the Discrete block (which ends the file
      at `StrongCompletenessDiscrete` / `SatisfiableDiscreteSet` / `CompactDiscrete`, before
      `end FormalSystem.Metalogic`):
      `def StrongCompletenessDedekind : Prop := StrongCompleteness FrameClass.Dedekind`
      `def CompactDedekind : Prop := Compact FrameClass.Dedekind`
      `def SatisfiableDedekindSet (Γ : Set Formula) : Prop := SatisfiableSet FrameClass.Dedekind Γ`
      `def ModelExistenceDedekind : Prop := ModelExistence FrameClass.Dedekind`
- [x] Give each a docstring in the house style of the Discrete block. Mark
      `StrongCompletenessDedekind` and `CompactDedekind` as **false**, citing
      `strongCompletenessDedekind_refuted` / `dedekind_consequence_not_compact` as forward
      references. Note that `ModelExistenceDedekind` is vocabulary only — nothing is proved
      about it here.
- [x] Fix `SetConsequence.lean:22-30`: replace "The `.Dedekind` row is available by the same
      instantiation and is deliberately **left unstated here**: naming it is the follow-on
      task's business…" with the fact that all four rows are now named here.
- [x] Fix `SetConsequence.lean:322-324`: `dedekind_of_forall`'s docstring says the adapter was
      supplied "even though no `.Dedekind` name is stated in this layer yet" — drop the "yet"
      clause and point at the names now above it.
- [x] Leave `SetConsequence.lean:436-438` ("Dedekind (unavailable on its primary source's own
      terms)") **untouched** — it is still literally true until Phase 4 lands. It is reconciled
      in Phase 5.
- [x] `lake build` green. *(2514 jobs, exit 0)*

**Timing**: 0.75 hours

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis** *(confirmed at implementation time: four one-line `def`s elaborated with no additional hypotheses; no new adapter, no new binder list)*: asserts "four one-line `def`s, no new adapter, no new binder list".
Confirm at implementation time by checking that each `def` elaborates with no additional
hypotheses and that `SatisfiableSet.dedekind_of_forall` (`:325`) and
`SetSemanticConsequenceDedekindDense.of_forall` (`:271`) are used unchanged in Phase 3/4. If any
new adapter turns out to be required, stop and record why before writing it — that would
contradict the rescoping premise of this task.

**Files to modify**:
- `FormalSystem/Metalogic/SetConsequence.lean` — four defs plus docstrings appended to the
  per-class block; two module/decl docstring repairs at `:22-30` and `:322-324`

**Verification**:
- `lake build` exits 0
- `grep -n "CompactDedekind\|StrongCompletenessDedekind\|SatisfiableDedekindSet\|ModelExistenceDedekind" FormalSystem/Metalogic/SetConsequence.lean` returns all four
- No `sorry` introduced

---

### Phase 2: New module and the unsatisfiability half [COMPLETED]

**Goal**: Create `FormalSystem/Metalogic/DedekindNonCompactness.lean` with the witness
vocabulary, its semantic characterisation lemmas, and the unsatisfiability half — the part that
uses completeness only. Wire the module into the build closure.

**Tasks**:
- [x] Create `FormalSystem/Metalogic/DedekindNonCompactness.lean` with the project file header
      (copyright block, matching `DiscreteNonCompactness.lean:1-5`),
      `import FormalSystem.Metalogic.StrongCompleteness`, the `open` line and
      `namespace FormalSystem.Metalogic`.
- [x] Write a module docstring in `DiscreteNonCompactness.lean`'s shape: the witness, why
      `archWitness` does not port (`Formula.next` is vacuous on a densely ordered carrier; the
      `[SuccOrder]`/`[IsSuccArchimedean]` route is unavailable and *cannot* be made available —
      a densely ordered type with no maximum admits no `SuccOrder`), and the two halves.
- [x] Transcribe the witness vocabulary from research §7: `qNext`, `qAlpha`, `qGap`, `qBound`,
      `dedWitness`, `qDepth`, and `qDepth_qAlpha`.
- [x] Transcribe `truth_and_iff'` (local; `Truth.lean` supplies no unfolding lemma for
      `Formula.and`). Research §4 notes an identical `truth_and_iff` exists at
      `Semantics/Correspondence/DurationFrames.lean:299` and that importing it is legal —
      **use the three-line local copy** to avoid widening the import closure, and say so in a
      comment.
- [x] Transcribe `truthAt_qNext_iff`, `truthAt_qGap`, `truthAt_qBound`.
- [x] Transcribe `dedWitness_core` and `dedWitness_not_satisfiable`.
- [x] Apply the generality decision above *(deviation: altered — the bounded `(hlub : F.IsComplete)` refinement SUCCEEDED on the first attempt; the `private example ... := rfl` is retained in the file as the record rather than deleted, since it documents the definitional identity the named binder relies on)*: docstring `dedWitness_core` as the
      `TaskFrame.IsComplete` statement (density unused; ℤ covered), and attempt the one bounded
      `(hlub : F.IsComplete)` refinement described in that section.
- [x] Add `import FormalSystem.Metalogic.DedekindNonCompactness` to `FormalSystem/Metalogic.lean`
      beside the `DiscreteNonCompactness` import at `:10`. **This is required in this phase**:
      `lakefile.lean` declares `roots := #[FormalSystem]`, not a source glob, so an unimported
      module is never compiled by `lake build`.
- [x] `lake build` green. *(2515 jobs, exit 0; job count rose from 2514, confirming the module entered the build closure)*

**Timing**: 1.5 hours

**Depends on**: 1

**Verification Tier**: interface

**Files to modify**:
- `FormalSystem/Metalogic/DedekindNonCompactness.lean` (new) — header, imports, module docstring,
  witness vocabulary, `qDepth_qAlpha`, `truth_and_iff'`, three `truthAt_q*` lemmas,
  `dedWitness_core`, `dedWitness_not_satisfiable`
- `FormalSystem/Metalogic.lean` — one import line (prose bullets deferred to Phase 5)

**Verification**:
- `lake build` exits 0
- `grep -c sorry FormalSystem/Metalogic/DedekindNonCompactness.lean` is 0
- The module is genuinely in the build closure: confirm `lake build` reports work for
  `FormalSystem.Metalogic.DedekindNonCompactness`, or touch the file and rebuild to see it
  recompile

---

### Phase 3: The ℝ model and the finite-satisfiability half [COMPLETED]

**Goal**: Build the `ShiftSet`-based ℝ frame with `q` true exactly at integers `1..N` and prove
`dedWitness_finitely_satisfiable`.

**Tasks**:
- [x] Add `import FormalSystem.Semantics.ShiftSet` to the new module. `Mathlib.Data.Real.Basic`
      is redundant (ShiftSet already imports Real) — keep or drop, and note the choice.
- [x] Transcribe `@[reducible] noncomputable def realOrder : TemporalOrder := ⟨ℝ⟩`. **The
      `@[reducible]` is load-bearing** — cf. the `intOrder` discipline at
      `Semantics/TemporalOrder.lean:100-126`.
- [x] Transcribe `@[reducible] noncomputable def rShift`, discharging all seven `ShiftSet`
      fields (`Carrier`, `carrier_nonempty`, `sh`, `sh_zero`, `sh_add`, `sep`, `A`). For `sep`
      (the paper's *Limit*), instantiate at `x = |u - w|` and derive `|u-w| < |u-w|`.
- [x] Transcribe `rM`, `rH`, and `rTruth_atom` (via `ShiftSet.forward_repr` +
      `simp [ShiftSet.ShiftTruth]`).
- [x] Transcribe `rTruth_gap`, `rTruth_bound`, `rTruth_alpha`. Drop the stray `⊢` from
      `by push_cast at hkN ⊢; omega` in `rTruth_alpha` to silence the known cosmetic warning.
- [x] Transcribe `dedWitness_finitely_satisfiable`, using `SatisfiableSet.dedekind_of_forall`,
      `Real.exists_isLUB`, `ShiftSet.hist_isTotal`, `List.single_le_sum` and `qDepth_qAlpha` for
      the `n ≤ N` bound.
- [x] Add a short comment recording **why** the ω-family `{αₙ}` exists rather than the single
      formula `G(q → F q)`: a finite unsatisfiable set refutes nothing about compactness. This
      is the design decision research §6 flags as most likely to be lost.
- [x] `lake build` green, with no new warnings. *(deviation: altered — dropping the `⊢` from `rTruth_alpha`'s `push_cast at hkN ⊢` silenced the warning research predicted, but a SECOND, unpredicted `'push_cast' tactic does nothing` warning surfaced at `dedWitness_finitely_satisfiable`'s `(by push_cast; omega)`; replaced with `(by omega)`. Rebuild: 2515 jobs, exit 0, zero warnings from this file.)*

**Timing**: 1.5 hours

**Depends on**: 2

**Verification Tier**: local

**Scope Hypothesis** *(confirmed by count: FOUR sites, not three — `hr'` in `rTruth_gap`, `hy'` in `rTruth_bound`, and `hr'` + `hrs'` in `rTruth_alpha`. Recording the actual number as the plan directs rather than forcing the transcription to match the prediction.)*: research §5 asserts "three sites" need explicit-ℝ restatement before
`exact_mod_cast` because `norm_cast` cannot see through `F.Duration.carrier`. Confirm by count
at implementation time; if more or fewer sites need it, record the actual number — do not force
the transcription to match the predicted count.

**Files to modify**:
- `FormalSystem/Metalogic/DedekindNonCompactness.lean` — one added import, `realOrder`,
  `rShift`, `rM`, `rH`, four `rTruth_*` lemmas, `dedWitness_finitely_satisfiable`

**Verification**:
- `lake build` exits 0 with no warnings from this file
- `grep -c sorry` is 0
- Both `@[reducible]` attributes present:
  `grep -n "@\[reducible\]" FormalSystem/Metalogic/DedekindNonCompactness.lean` returns 2

---

### Phase 4: The two refutations, axiom audit, and sorry check [COMPLETED]

**Goal**: Land `dedekind_consequence_not_compact` and `strongCompletenessDedekind_refuted`, then
discharge the task's acceptance gate.

**Tasks**:
- [x] Transcribe `dedekind_consequence_not_compact` (refuting `CompactDedekind`), including
      `haveI : DenselyOrdered F.Duration := hd` before `ValidDedekindDense.apply`.
- [x] Transcribe `strongCompletenessDedekind_refuted` (refuting `StrongCompletenessDedekind`),
      including the same `haveI` before `soundness_dedekind`.
- [x] Docstring both in the shape of `discrete_consequence_not_compact` /
      `strongCompletenessDiscrete_refuted`, and record the axiom set inline as
      `DiscreteNonCompactness.lean` does.
- [x] **Sorry check** *(clean: the only `sorry` substring in either file is the word `sorryAx` inside the audit docstring)*: `grep -rn "sorry" FormalSystem/Metalogic/DedekindNonCompactness.lean
      FormalSystem/Metalogic/SetConsequence.lean` returns nothing.
- [x] **Axiom audit** *(deviation: altered — the temporary block was made PERMANENT, matching `DiscreteNonCompactness.lean`'s house style, which keeps live `#print axioms` commands plus an `## Axiom Audit` docstring. The plan's parenthetical explicitly sanctions this. Verbatim in-tree output recorded below.)*: add a temporary `#print axioms` block (or run via `lean_verify` /
      `lake env lean`) for all four headline results —
      `dedWitness_not_satisfiable`, `dedWitness_finitely_satisfiable`,
      `dedekind_consequence_not_compact`, `strongCompletenessDedekind_refuted` — and confirm
      each reports exactly `[propext, Classical.choice, Quot.sound]`. Record the verbatim output
      in the implementation summary. Remove the temporary block before closing the phase (or
      keep it as a commented-out audit block if that matches house style in
      `DiscreteNonCompactness.lean`).
- [x] `lake build` green. *(2515 jobs, exit 0)*

**Timing**: 0.75 hours

**Depends on**: 3

**Verification Tier**: full

**Files to modify**:
- `FormalSystem/Metalogic/DedekindNonCompactness.lean` — the two refutation theorems and their
  docstrings

**Verification**:
- `lake build` exits 0
- Zero `sorry` / `sorryAx` in the new module and in `SetConsequence.lean`
- `#print axioms` on all four headline results is exactly
  `[propext, Classical.choice, Quot.sound]` — this is a **standalone acceptance criterion**, not
  merely a build side effect. If any result carries a fifth axiom, the phase is not complete
- The full four-class picture now reads: Base/Dense open pending the ultraproduct chain,
  Discrete refuted, Dedekind refuted

**In-tree axiom audit, verbatim `lake build` output** (the module keeps its `#print axioms`
commands permanently, so this is emitted on every build):

```
'FormalSystem.Metalogic.qDepth_qAlpha' depends on axioms: [propext, Quot.sound]
'FormalSystem.Metalogic.dedWitness_core' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.dedWitness_not_satisfiable' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.dedWitness_finitely_satisfiable' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.dedekind_consequence_not_compact' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.strongCompletenessDedekind_refuted' depends on axioms: [propext, Classical.choice, Quot.sound]
```

All four headline results are exactly `[propext, Classical.choice, Quot.sound]`. `qDepth_qAlpha`
carries a strict *subset* (`[propext, Quot.sound]`) — a smaller dependency, not an extra axiom;
recorded literally rather than rounded up.

---

### Phase 5: Documentation reconciliation [COMPLETED]

**Goal**: No passage in `FormalSystem/` may still assert that the tree contains no Dedekind
refutation. This is documentation debt the preceding phases create, and it is the difference
between a correct tree and a tree that contradicts its own theorems.

**Tasks** — the sites research §8 enumerated:
- [x] `Metalogic/StrongCompleteness.lean:73-83` — the Dedekind row of the status ledger ("What
      this tree does **not** contain is a refutation…"). Rewrite to the Discrete row's shape,
      naming `dedekind_consequence_not_compact` and `strongCompletenessDedekind_refuted` and the
      new module. Preserve the Reynolds 1992 §9 Thm 7 citation as the *weak* completeness result
      — the refutation does not contradict it; it explains why only weak completeness is
      available.
- [x] `Metalogic/StrongCompleteness.lean:84-90` — "Three distinct statuses, which must not be
      collapsed." There are now **two**: Base/Dense proved, Discrete/Dedekind refuted. Rewrite
      the paragraph, including its closing sentence about `SetConsequence.lean` modelling the
      discipline.
- [x] `Metalogic/StrongCompleteness.lean:823` — second copy of the same claim ("Discrete is the
      one class in this development where 'machine-refuted' is the earned phrasing… Those three
      statuses must not be collapsed into one"). Discrete is no longer the *one* such class.
- [x] `Metalogic/SetConsequence.lean:436-438` — "Dedekind (unavailable on its primary source's
      own terms). The three must not be read as sharing a status." (Left deliberately untouched
      in Phase 1; now false.)
- [x] `Metalogic/SetConsequence.lean:22-30` and `:322-324` — **already discharged in Phase 1**;
      re-read to confirm they were not reverted, then check this item off.
- [x] `Metalogic.lean:10` — **already discharged in Phase 2** (the import). Re-read to confirm.
- [x] `Metalogic.lean:197` — extend the `DiscreteNonCompactness.lean` module bullet with its
      Dedekind sibling: the `{G(⊤ S ¬q), F(G ¬q)} ∪ {Xqⁿ⊤}` witness and the two refutations.

**Tasks** — three further sites found during planning that research §8 **missed**:
- [x] `Metalogic/StrongCompleteness.lean:460-463` — a third copy inside the numbered-list
      docstring ("At `FrameClass.Dedekind` it is **unavailable on the primary source's own
      terms** and nothing stronger… this tree contains no `CompactDedekind` definition and no
      refuting theorem for the class. Saying that the Dedekind consequence relation 'is not
      compact' would assert more than has been checked here"). Every clause of this is now
      false.
- [x] `Metalogic/StrongCompleteness.lean:543` — a fourth copy, in
      `consequence_completeness_dedekind`'s docstring ("*unproved*, with no refutation in this
      tree, in contrast to `FrameClass.Discrete` where it is machine-refuted"). The contrast has
      collapsed; rewrite so the sentence still correctly says this theorem is *not* strong
      completeness.
- [x] `Metalogic/Compactness.lean:65` — "`FrameClass.Dedekind` — unavailable on its primary
      source's own terms; see `FormalSystem/Metalogic.lean`." in the "Status of the four
      `FrameClass` cases" list.
- [x] `Metalogic.lean:115-116` — "**unavailable on the primary source's own terms**… this tree
      contains no `CompactDedekind` definition and no refuting theorem, so the class is
      *unproved* rather than refuted."

**Tasks** — the README (research §9 marked this **unverified**; planning confirmed it needs work):
- [x] `FormalSystem/Metalogic/README.md:144` — add a `DedekindNonCompactness.lean` row to the
      "Loose non-aggregator" table, beside the `DiscreteNonCompactness.lean` row, with its line
      count and role.
- [x] `FormalSystem/Metalogic/README.md:143` — update `SetConsequence.lean`'s line count (568
      before Phase 1) and extend its role text to mention the `.Dedekind` instantiations.
- [x] Check `FormalSystem/Semantics/README.md` for a Dedekind status claim. *(confirmed: `:17` and `:19` are unrelated to compactness status — **no change needed**)* Planning found only
      unrelated mentions (`:17`, `:19`); confirm and record "no change needed" rather than
      silently skipping.

**Closing sweep**:
- [x] Re-run the detector below and confirm every remaining hit is either a *correct* statement
      about weak completeness / `ValidDedekind` refutability, or has been rewritten:
      ```
      grep -rn "CompactDedekind\|no refutation\|left unstated\|unavailable on the primary source\|unavailable on its primary source\|unavailable on Reynolds" FormalSystem/ --include=*.lean --include=*.md
      ```
- [x] `lake build` green (Lean docstrings elaborate — a malformed `/--` breaks the build).

**Timing**: 1.25 hours

**Depends on**: 4

**Verification Tier**: local

**Scope Hypothesis** *(confirmed undercount, again)*: the plan enumerated **5** `StrongCompleteness.lean` hunks; the baseline grep surfaced a **6th** at `:515` (`completeness_dedekind_of_engine`'s docstring), which was reconciled with the rest. Baseline grep: 18 hits, 11 asserting no Dedekind refutation exists; post-edit grep: 13 hits, every one either a reference to the now-real name `CompactDedekind` or the single deliberate historical note at `StrongCompleteness.lean:107`. This phase asserts a site count. Research §8 claimed **six**; planning
found the detector grep above returning **13 hits across 4 `.lean` files**, plus 2 README hunks —
so §8 is a confirmed undercount and the enumerated list here (10 `.lean` hunks + 2 README + 1
README check) is itself only a hypothesis. Confirm at implementation time by running the grep
**before** editing to capture the baseline hit list, and **after** editing to show every
remaining hit is deliberate. Do not treat the checklist above as exhaustive; treat the grep as
authoritative and add any newly-surfaced site to the list.

**Files to modify**:
- `FormalSystem/Metalogic/StrongCompleteness.lean` — 5 doc hunks (`:73-83`, `:84-90`, `:460-463`,
  `:543`, `:823`)
- `FormalSystem/Metalogic/SetConsequence.lean` — 1 doc hunk (`:436-438`)
- `FormalSystem/Metalogic.lean` — 2 doc hunks (`:115-116`, `:197`)
- `FormalSystem/Metalogic/Compactness.lean` — 1 doc hunk (`:65`)
- `FormalSystem/Metalogic/README.md` — module table row + line count

**Verification**:
- `lake build` exits 0
- The detector grep returns no hit asserting the absence of a Dedekind refutation
- `grep -n "DedekindNonCompactness" FormalSystem/Metalogic/README.md FormalSystem/Metalogic.lean`
  returns hits in both

---

## Testing & Validation

- [x] `lake build` green at the close of **every** phase — no phase may leave the tree red
- [x] Zero `sorry` / `sorryAx` in `DedekindNonCompactness.lean` and `SetConsequence.lean`
- [x] `#print axioms dedWitness_not_satisfiable` = `[propext, Classical.choice, Quot.sound]`
- [x] `#print axioms dedWitness_finitely_satisfiable` = `[propext, Classical.choice, Quot.sound]`
- [x] `#print axioms dedekind_consequence_not_compact` = `[propext, Classical.choice, Quot.sound]`
- [x] `#print axioms strongCompletenessDedekind_refuted` = `[propext, Classical.choice, Quot.sound]`
- [x] All four Part 1 names resolve: `CompactDedekind`, `StrongCompletenessDedekind`,
      `SatisfiableDedekindSet`, `ModelExistenceDedekind`
- [x] `DiscreteNonCompactness.lean` is byte-identical to its pre-task state
      (`git diff --stat` shows no change to it)
- [x] The detector grep in Phase 5 shows no surviving "no Dedekind refutation" claim
- [x] No new build warnings attributable to the new module

## Artifacts & Outputs

- `FormalSystem/Metalogic/DedekindNonCompactness.lean` (new) — witness, both halves, both
  refutations
- `FormalSystem/Metalogic/SetConsequence.lean` — four `.Dedekind` instantiations + doc repairs
- `FormalSystem/Metalogic.lean` — import + doc repairs
- `FormalSystem/Metalogic/StrongCompleteness.lean` — status-ledger reconciliation
- `FormalSystem/Metalogic/Compactness.lean` — status-list reconciliation
- `FormalSystem/Metalogic/README.md` — module table update
- `specs/494_define_and_refute_dedekind_compactness/summaries/01_dedekind-non-compactness-summary.md`

## Rollback/Contingency

Each phase ends at a green commit, so rollback is `git revert` of the offending phase commit —
never a destructive reset on a dirty tree (see `.claude/rules/git-workflow.md`).

- **Phase 1 fails**: the four defs are the rescoping premise of this task. If they do not
  elaborate as one-line instantiations, the `FrameClass` parameterization is not in the state
  the research reports; stop and re-research rather than hand-writing a fourth binder list.
- **Phases 2-4 fail**: the module is self-contained and imported from exactly one line in
  `Metalogic.lean`. Removing that import plus the file restores the pre-task build. Phase 1 can
  stand alone — the four vocabulary defs are correct and useful even with no refutation, though
  Phase 5's doc reconciliation must then **not** be applied (the "unavailable / no refutation"
  claims stay true).
- **Phase 5 fails partway**: doc-only. Revert the phase commit; the theorems from Phases 1-4
  remain valid, leaving only stale prose — a known, recorded debt rather than a broken tree.
- **If `#print axioms` shows an unexpected axiom**: do not weaken the acceptance criterion. Trace
  the offending declaration, and if the extra axiom is genuinely unavoidable, record it as a
  deviation in the summary rather than silently accepting it.

#### Sites actually reconciled

| File | Hunks |
|------|-------|
| `Metalogic/StrongCompleteness.lean` | 6 (`:73-83`, `:84-90`, `:460-463`, **`:515` — not in the plan's list**, `:543`, `:823`) |
| `Metalogic/SetConsequence.lean` | 3 (module docstring + adapter block, both in Phase 1; `:436-438` here) |
| `Metalogic.lean` | 3 (import in Phase 2; `:115-117` and the two module bullets at `:190`/`:197` here) |
| `Metalogic/Compactness.lean` | 1 (`:65`) |
| `Metalogic/README.md` | 2 (new `DedekindNonCompactness.lean` row at 516 lines; `SetConsequence.lean` count 568 → 638) |
| `Semantics/README.md` | 0 — checked, no change needed |
