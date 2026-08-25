# Implementation Plan: Discrete non-compactness witness

- **Task**: 425 - Machine-check the Discrete non-compactness witness
- **Status**: [IMPLEMENTING]
- **Effort**: 4.5 hours
- **Dependencies**: 361, 423
- **Research Inputs**: specs/425_machine_check_discrete_non_compactness_witness/reports/01_discrete-non-compactness-witness.md
- **Artifacts**: plans/01_discrete-non-compactness-witness.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

The research pass did not merely survey this problem — it **constructed and compiled the entire
proof**. All three acceptance theorems (`archWitness_finitely_satisfiable`,
`archWitness_not_satisfiable`, `discrete_consequence_not_compact`) plus two new next-step truth
lemmas compiled with zero errors, zero warnings and zero sorries against the built tree, each at
exactly `[propext, Classical.choice, Quot.sound]`. This plan is therefore a **transcription and
placement** plan, not a discovery plan: every phase below moves verified text from report §3 into
the tree at the location report §4 identifies, and verifies that it still compiles there.

Definition of done: the three acceptance theorems land sorry-free in
`FormalSystem/Metalogic/DiscreteNonCompactness.lean`, `#print axioms` reports exactly
`[propext, Classical.choice, Quot.sound]` on each, and `lake build` is green.

### Research Integration

Report §3 carries line-for-line reusable proof text for every declaration. The implementer's
default action at each phase is to **copy it verbatim**; deviation from it is a defect, not a
judgement call. Four findings from the report govern the work directly:

1. **`Formula.next` is guard-first.** The current tree has
   `Formula.next φ = Formula.untl Formula.bot φ` at `FormalSystem/Syntax/Formula.lean:511`. The
   task description and the archived design document `02_compactness-route.md` both quote the
   stale swapped form (`untl φ bot`) and the stale line number `:490`; they predate
   `specs/decisions/untl-snce-argument-order.md`. The in-tree docstrings at
   `StrongCompleteness.lean:60` and `:417` are **already correct** — no docstring correction is
   owed by this task, and the implementer must not "fix" them toward the stale form.
2. **Import-cycle constraint.** `discrete_consequence_not_compact` consumes `truthAt_foldr_imp`
   (`StrongCompleteness.lean:148`), so the witness cannot live in `SetConsequence.lean`. It goes
   in a new module downstream of `StrongCompleteness.lean`.
3. **Three elaboration traps**, each with a machine-verified fix, are reproduced in the phases
   that hit them (numeral elaboration at `natFrame.WorldState`; `haveI` defeq breakage on
   destructured instance binders; the asymmetric `iterate_succ_apply` / `iterate_succ_apply'`
   rewrite pair).
4. **`Formula.complexity` is unusable** as a size measure (it is pattern-aware and charges
   overhead for `always`/`sometimes`/`weakFuture`/`weakPast` expansions), which is why a
   dedicated `nextDepth`/`witIdx` pair exists in Phase 3.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROADMAP.md consulted for this task (no `roadmap_path` supplied).

## Goals & Non-Goals

**Goals**:
- Add the Discrete satisfiability/compactness vocabulary (`SatisfiableDiscreteSet`,
  `CompactDiscrete`) beside the existing Dense analogues.
- Land `truthAt_next_iff` and `truthAt_next_iterate` — the first semantic characterisation of
  `Formula.next` anywhere in the tree.
- Land the three acceptance theorems sorry-free with a clean axiom audit.
- Deliver the task sentence's "hence strong completeness is refuted for that class" as an actual
  theorem (Phase 5), rather than leaving it as prose.
- Close the loop on the module prose at `StrongCompleteness.lean:56-62` and `:411-421`, which
  currently promises theorems that do not exist.

**Non-Goals**:
- Any analogous **Dedekind** non-compactness witness. Explicitly out of scope; that class's
  non-compactness is already established and belongs to separate in-flight work. Nothing in the
  research report proposes one, and nothing in this plan may introduce one.
- Discharging `CompactDense` or `ModelExistenceDense`. The Dense obligations are untouched.
- Promoting `truthAt_next_iff` / `truthAt_next_iterate` to `FormalSystem/Semantics/Truth.lean`.
  The report identifies that as their eventual natural home but recommends against it now
  (editing a near-root module triggers a full-tree rebuild for a single consumer). A docstring
  note records the intent instead.
- Marking `truthAt_next_iff` `@[simp]`.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Transcription drift from report §3 (retyping instead of copying) | H | M | Copy verbatim; report §8 states any failure is a transcription error, not a mathematical gap. Diff against §3 before declaring a phase green. |
| Implementer "helpfully" adds `haveI := i1` after destructuring instance binders | H | M | Report §3 Layer 0 documents this as a build-breaking anti-pattern (`haveI` drops the value, destroying defeq with the instances baked into `F`/`M`'s types). Phase 4 restates it as a MUST NOT. |
| Numeral elaboration failure in the ℤ model (`OfNat … WorldState`) | M | M | Both fixes are pre-recorded in Phase 3: ascribe the `ite` **body** to `Nat`; annotate the `valuation` **lambda binder**. Ascribing an existing fvar does not work. |
| Symmetric `iterate_succ_apply` rewrite in `truthAt_next_iterate` | M | M | Phase 2 states the asymmetry explicitly: unprimed on the formula side, primed on the time side. |
| Stale `Formula.next` argument order propagated from the task description into new code | H | L | Correction stated in Overview and restated in Phase 2's tasks; `nextDepth`'s equation `| Formula.untl Formula.bot φ => …` fails to fire if the order is wrong, so Phase 3 catches it. |
| Task-number citation lands in a `FormalSystem/**` file | M | L | `check-module-invariants.sh` C9 asserts zero task-number citations under `FormalSystem/`; Phase 6 runs it. Also a repo rule (`no-task-references-in-deliverables.md`). |
| Phase 5's refutation theorem was never compiled (sketch only) | L | M | Phase 5 is isolated *after* the acceptance gate, and carries a documented `[COMPLETED WITH EXCLUSIONS]` escape path so it can never endanger the three-theorem acceptance set. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3 | 2 |
| 3 | 4 | 1, 3 |
| 4 | 5 | 4 |
| 5 | 6 | 5 |

Phases within the same wave can execute in parallel. Phases 1 and 2 are territory-disjoint:
Phase 1 owns `FormalSystem/Metalogic/SetConsequence.lean`; Phase 2 owns the new module and
`FormalSystem/Metalogic.lean`.

---

### Phase 1: Discrete satisfiability and compactness vocabulary [COMPLETED]

**Goal**: `SatisfiableDiscreteSet` and `CompactDiscrete` exist in `SetConsequence.lean` beside
their Dense counterparts, with the module docstring widened to admit them.

**Tasks**:
- [x] Add `SatisfiableDiscreteSet` and `CompactDiscrete` verbatim from report §3 Layer 0, placed
      in the `## Strong completeness, compactness and model existence` region alongside
      `StrongCompletenessDense` (`:192`), `CompactDense` (`:199`), `SatisfiableDenseSet` (`:207`)
      and `ModelExistenceDense` (`:219`).
- [x] Give each a docstring in the register of its Dense sibling: `SatisfiableDiscreteSet` is
      `FormulaSatisfiable` with `ValidDiscrete`'s binder list (`Semantics/Validity.lean:243`) in
      place of `ValidDense`'s and the conclusion generalised to `∀ ψ ∈ Γ`.
- [x] Widen the module docstring's scope sentence (currently "…strong completeness, compactness,
      satisfiability and model existence for `FrameClass.Dense`", `:20`) to name Discrete.
- [x] Record the asymmetry that matters, in the docstring: `CompactDense` names an **open
      obligation**, whereas `CompactDiscrete` is **refuted downstream**. The existing "no
      compactness result is proved here" sentence (`:22-24`) needs the same qualification so it
      does not read as claiming the Discrete question is also open.
- [x] Confirm no import change is required (`IsSuccArchimedean` is already in scope via
      `SetSemanticConsequenceDiscrete` at `:85`).

**Timing**: 0.75 hours

**Depends on**: none

**Verification Tier**: interface

**Scope Hypothesis**: The phase asserts (a) two new declarations and zero import changes, and
(b) that both names are fresh tree-wide. Confirm at implementation time with
`grep -rn "SatisfiableDiscreteSet\|CompactDiscrete" FormalSystem/` returning only the new
occurrences, and by the module building with its import block unchanged. If either name
collides, stop and report rather than renaming silently.

**Files to modify**:
- `FormalSystem/Metalogic/SetConsequence.lean` - two new `def`s plus docstring widening.

**Verification**:
- `lake build FormalSystem.Metalogic.SetConsequence` succeeds.
- Build the enumerated direct dependents of `SetConsequence` (find them with
  `grep -rln "import FormalSystem.Metalogic.SetConsequence" FormalSystem/`) to confirm the two
  new names in the `FormalSystem.Metalogic` namespace shadow nothing downstream.
- Both `def`s elaborate: the five anonymous class binders (`(_ : SuccOrder D)`,
  `(_ : PredOrder D)`, `(_ : IsSuccArchimedean D)`, `(_ : IsPredArchimedean D)`,
  `(_ : Nontrivial D)`) are machine-verified to elaborate as written.

---

### Phase 2: New module, next-step truth lemmas, aggregator registration [NOT STARTED]

**Goal**: `FormalSystem/Metalogic/DiscreteNonCompactness.lean` exists, imports
`FormalSystem.Metalogic.StrongCompleteness`, hosts `truthAt_next_iff` and
`truthAt_next_iterate`, and is re-exported from `FormalSystem/Metalogic.lean`.

**Tasks**:
- [ ] Create `FormalSystem/Metalogic/DiscreteNonCompactness.lean` with the repository's standard
      copyright header (copy the four-line form used by `SetConsequence.lean`) and
      `import FormalSystem.Metalogic.StrongCompleteness`. This import — not
      `SetConsequence` — is the one that matters: it is what makes `truthAt_foldr_imp`
      (`StrongCompleteness.lean:148`) reachable in Phase 4, and it was the missing piece in
      research probe 5.
- [ ] Write the module docstring: what the module establishes (the Discrete consequence relation
      is not compact), the witness set in prose, and a note that `truthAt_next_iff` /
      `truthAt_next_iterate` are pure semantics whose natural eventual home is
      `FormalSystem/Semantics/Truth.lean`'s `Truth` namespace, deferred until a second consumer
      appears. **No task-number citations** anywhere in this file.
- [ ] Open the `FormalSystem.Metalogic` namespace and declare the shared variable block
      `{D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]`.
- [ ] Transcribe `truthAt_next_iff` verbatim from report §3 Layer 1, with binders
      `[SuccOrder D] [NoMaxOrder D]`. Do **not** mark it `@[simp]` — it would rewrite `next`
      occurrences inside the proof-theoretic reasoning in
      `FormalSystem/Theorems/DiscreteUnfolding.lean` if the lemma is ever promoted upstream.
- [ ] Transcribe `truthAt_next_iterate` verbatim. The inductive step uses **asymmetric**
      rewrites: `Function.iterate_succ_apply` on the formula side
      (`next^[k+1] φ = next^[k] (next φ)`) and `Function.iterate_succ_apply'` on the time side
      (`succ^[k+1] t = succ (succ^[k] t)`). Using the same one on both sides produces a measured
      type mismatch at the `exact`.
- [ ] Add `import FormalSystem.Metalogic.DiscreteNonCompactness` to `FormalSystem/Metalogic.lean`
      beside the existing `import FormalSystem.Metalogic.StrongCompleteness` (`:9`).

**Timing**: 1 hour

**Depends on**: none

**Verification Tier**: interface

**Files to modify**:
- `FormalSystem/Metalogic/DiscreteNonCompactness.lean` - new file.
- `FormalSystem/Metalogic.lean` - one added import line.

**Verification**:
- `lake build FormalSystem.Metalogic.DiscreteNonCompactness` succeeds with zero warnings.
- `lake build FormalSystem.Metalogic` succeeds (aggregator picks up the new module).
- `#print axioms FormalSystem.Metalogic.truthAt_next_iff` and `…truthAt_next_iterate` both report
  exactly `[propext, Classical.choice, Quot.sound]`.
- `NoMaxOrder D` is inferrable from the Discrete binder list — machine-verified in research, and
  matching the in-tree precedent at `FormalSystem/Metalogic/Soundness.lean:420` and `:433`.

---

### Phase 3: Witness set, index functions, and the ℤ model [NOT STARTED]

**Goal**: The witness set, its computable index function, and the concrete ℤ frame/model/history
all live in the new module and compile.

**Tasks**:
- [ ] Transcribe `archWitness` from report §3 Layer 2:
      `{(Formula.atom p).someFuture} ∪ {ψ | ∃ n : ℕ, ψ = (Formula.next^[n] (Formula.atom p)).neg}`.
- [ ] Transcribe `nextDepth` and `witIdx` with their equation-compiler patterns exactly as
      written. `nextDepth`'s first equation is `| Formula.untl Formula.bot φ => nextDepth φ + 1`
      — **guard-first**; the swapped form silently never fires.
- [ ] Transcribe `nextDepth_next_iterate` and `witIdx_neg_next_iterate`.
- [ ] Add a docstring on `witIdx` recording *why* it exists: membership in `archWitness` gives
      only `∃ n, ψ = ¬Xⁿ p` per element, and `archWitness_finitely_satisfiable` needs a single
      threshold over an arbitrary list, so the existential must be turned into a computable
      index. Record that `Formula.complexity` (`Syntax/Formula.lean:224`) is **not** usable here:
      it is pattern-aware and therefore not a monotone structural size.
- [ ] Transcribe the ℤ layer: `zHistory`, `zModel`, `zHistory_total`, `zTruth_atom`,
      `succ_iterate_zero_int` from report §3 Layer 3, on `TaskFrame.natFrame`
      (`Semantics/TaskFrame.lean:1288`).
- [ ] Apply both numeral-elaboration fixes exactly: `states := fun t _ => (if N < t then 1 else 0 : Nat)`
      (ascribe the **body**) and `valuation := fun (w : Nat) _ => w = 1` (annotate the **lambda
      binder**). `fun w _ => (w : Nat) = 1` does **not** work — ascription on an existing fvar
      does not retarget numeral elaboration.
- [ ] Add a short comment recording why `TaskFrame.natFrame` is the right frame: its relation
      `TaskRel w d u := d ≠ 0 ∨ w = u` is permissive, so an arbitrary state function respects it,
      which a non-constant history requires. `WorldHistory.universalNatFrame` is constant-state
      and `staticFrame`'s relation forces constant histories; neither works.

**Timing**: 1 hour

**Depends on**: 2

**Verification Tier**: local

**Files to modify**:
- `FormalSystem/Metalogic/DiscreteNonCompactness.lean` - append Layers 2 and 3.

**Verification**:
- `lake build FormalSystem.Metalogic.DiscreteNonCompactness` succeeds with zero warnings and no
  `sorry`.
- The equation compiler accepts `nextDepth` and `witIdx` without a well-foundedness complaint
  (machine-verified in research probe 1).
- Spot-check that `nextDepth_next_iterate` actually reduces: if it does not, the `untl` argument
  order in `nextDepth` is wrong.

---

### Phase 4: The three acceptance theorems and the axiom audit [NOT STARTED]

**Goal**: `archWitness_finitely_satisfiable`, `archWitness_not_satisfiable` and
`discrete_consequence_not_compact` all land sorry-free with a clean axiom audit — the task's
stated acceptance criteria, met.

**Tasks**:
- [ ] Transcribe `archWitness_finitely_satisfiable` verbatim from report §3 Layer 4. It uses
      `(L.map witIdx).sum` as the threshold `N` and Mathlib's
      `List.single_le_sum (fun _ _ => Nat.zero_le _)` for `witIdx ψ ≤ N` — simpler than a
      `foldr max` helper and requiring no auxiliary lemma. Do not substitute a `max`-based bound.
- [ ] Transcribe `archWitness_not_satisfiable` verbatim. The reachability step is
      `(Order.succ_le_of_lt hts).exists_succ_iterate` — the same idiom already used at
      `FormalSystem/Metalogic/SoundnessLemmas/FrameClassVariants.lean:748`, `:767`, `:828`,
      `:865`, `:877`. This is precisely where `IsSuccArchimedean` does its work.
- [ ] **MUST NOT**: destructure the `SatisfiableDiscreteSet` existential with *named* instance
      binders and re-install them with `haveI`. `haveI` drops the value, so the re-synthesised
      instance is no longer defeq to the one baked into `F`/`M`'s types, producing
      "synthesized type class instance is not definitionally equal…". Use bare `_` binders
      (`rintro ⟨D, _, _, _, _, _, _, _, _, F, M, τ, hτ, t, h⟩`) and let synthesis find the
      originals. This is measured, not theoretical.
- [ ] Transcribe `discrete_consequence_not_compact` verbatim, with the concrete atom
      `p : Atom := ⟨"p", none⟩` (`Atom` is a plain structure at `Syntax/Atom.lean:75`, so no
      `Nonempty Atom` plumbing is needed).
- [ ] Add a module-level Axiom Audit docstring section recording the five `#print axioms` results,
      in the register used by `FormalSystem/Metalogic/BXCanonical/Completeness.lean`.

**Timing**: 1 hour

**Depends on**: 1, 3

**Verification Tier**: full

**Scope Hypothesis**: The phase asserts that all three theorems compile **verbatim** from report
§3 Layer 4 with no repair. Confirm by transcribing without edits first and building; any required
edit is a transcription defect against §3 and must be identified as such (diff against the report)
before being applied. If a genuine mathematical gap appears — which report §8 states is
impossible — stop and report rather than inserting a `sorry`.

**Files to modify**:
- `FormalSystem/Metalogic/DiscreteNonCompactness.lean` - append Layer 4 and the audit docstring.

**Verification**:
- Full `lake build` exits 0.
- `#print axioms` on each of `archWitness_finitely_satisfiable`, `archWitness_not_satisfiable`,
  `discrete_consequence_not_compact` reports exactly `[propext, Classical.choice, Quot.sound]` —
  the identical set carried by `completeness_dense` / `completeness_discrete` /
  `consequence_completeness_dedekind`. No `sorryAx`.
- `grep -n "sorry" FormalSystem/Metalogic/DiscreteNonCompactness.lean` returns nothing.

---

### Phase 5: Strong-completeness refutation for `FrameClass.Discrete` [NOT STARTED]

**Goal**: Deliver the task sentence's "hence strong completeness is refuted for that class" as an
actual theorem rather than prose.

**Tasks**:
- [ ] Add `StrongCompletenessDiscrete` to `SetConsequence.lean` beside `StrongCompletenessDense`
      (`:192`), as
      `∀ (Γ : Set Formula) (φ : Formula), SetSemanticConsequenceDiscrete Γ φ → SetDerivable FrameClass.Discrete Γ φ`.
- [ ] Prove `strongCompletenessDiscrete_refuted : ¬ StrongCompletenessDiscrete` in the new module:
      take `Γ = archWitness p`, `φ = ⊥`; the finitary derivation cites some `L ⊆ Γ`; feed
      `archWitness_finitely_satisfiable`'s model to `soundness_discrete`
      (`FormalSystem/Metalogic/Soundness.lean:1393`), whose binder list is exactly what
      `SatisfiableDiscreteSet` unpacks to, to derive `TruthAt … ⊥`.
- [ ] Update the `SetConsequence.lean` docstring asymmetry note from Phase 1 to mention the new
      `StrongCompletenessDiscrete` statement and that it is refuted, not open.
- [ ] `#print axioms FormalSystem.Metalogic.strongCompletenessDiscrete_refuted`.

**Timing**: 0.75 hours

**Depends on**: 4

**Verification Tier**: full

**Scope Hypothesis**: The phase asserts this is "~6 lines on top of what is already proved".
Unlike everything in report §3, **this proof was NOT compiled during research** — report §5 marks
it a sketch. Confirm the estimate by building; do not assume it. **Escape path**: if the proof
does not close within the phase budget, close the phase `[COMPLETED WITH EXCLUSIONS]` with a
`#### Reasoned Exclusions` record naming the two declarations, the reason (uncompiled sketch that
exceeded budget), and the evidence (the failing goal state), and revert the partial edit so the
tree stays green. The three-theorem acceptance set is already met at Phase 4 and must not be put
at risk here. Do **not** land a `sorry` for this.

**Files to modify**:
- `FormalSystem/Metalogic/SetConsequence.lean` - one new `def` plus docstring touch-up.
- `FormalSystem/Metalogic/DiscreteNonCompactness.lean` - one new theorem.

**Verification**:
- Full `lake build` exits 0.
- `#print axioms` on `strongCompletenessDiscrete_refuted` reports exactly
  `[propext, Classical.choice, Quot.sound]`, or the phase closes with exclusions per above.

---

### Phase 6: Documentation closure and final gate [NOT STARTED]

**Goal**: The prose that promised these theorems now points at them, and the repository's own
invariant harness passes.

**Tasks**:
- [ ] Update the `FrameClass.Discrete` bullet in `StrongCompleteness.lean`'s module docstring
      (`:56-62`) so the informal argument cites the now-existing theorems by name. The prose
      itself stays — this task adds the theorems it promised, it does not delete the promise.
      Leave the `Formula.next φ = Formula.untl Formula.bot φ` rendering **as-is**: it is already
      correct.
- [ ] Update the reserved section comment at `StrongCompleteness.lean:411-421` the same way,
      pointing at `FormalSystem/Metalogic/DiscreteNonCompactness.lean`.
- [ ] Add a bullet to `FormalSystem/Metalogic.lean`'s "Publication-Ready Results" list recording
      `discrete_consequence_not_compact` as SORRY-FREE with its axiom set, and mention
      `DiscreteNonCompactness.lean` in the "Key Components" list beside the
      `StrongCompleteness.lean` entry.
- [ ] Verify no task-number citation entered any `FormalSystem/**` file.

**Timing**: 0.75 hours

**Depends on**: 5

**Verification Tier**: full

**Files to modify**:
- `FormalSystem/Metalogic/StrongCompleteness.lean` - docstring/comment cross-references only.
- `FormalSystem/Metalogic.lean` - docstring bullets only.

**Verification**:
- Full `lake build` exits 0.
- `bash scripts/check-module-invariants.sh` passes — in particular C4 (every
  `import FormalSystem.*` resolves, covering the new aggregator import), C5 (every module-shaped
  `FormalSystem.*` path in non-specs markdown resolves), C8 (aggregator convention: the new file
  is a loose top-level module in `Metalogic/`, adds no directory, and so must not perturb it),
  and C9 (zero task-number citations under `FormalSystem/`).
- `#print axioms` re-run on all five (six with Phase 5) new declarations; results captured for the
  implementation summary.

---

## Testing & Validation

- [ ] `lake build` exits 0 on the whole tree.
- [ ] `archWitness_finitely_satisfiable`, `archWitness_not_satisfiable`,
      `discrete_consequence_not_compact` each `#print axioms` to exactly
      `[propext, Classical.choice, Quot.sound]`.
- [ ] `truthAt_next_iff`, `truthAt_next_iterate` likewise.
- [ ] `strongCompletenessDiscrete_refuted` likewise, or an explicit `#### Reasoned Exclusions`
      record under Phase 5.
- [ ] Zero `sorry` in `FormalSystem/Metalogic/DiscreteNonCompactness.lean`.
- [ ] Zero new `sorry` anywhere: `check-module-invariants.sh` C3 asserts exactly one structural
      `sorry` tree-wide, located by content, and that count must not change.
- [ ] `bash scripts/check-module-invariants.sh` exits 0.
- [ ] No Dedekind non-compactness declaration was introduced (out-of-scope guard):
      `grep -rn "Dedekind" FormalSystem/Metalogic/DiscreteNonCompactness.lean` returns nothing.

## Artifacts & Outputs

- `FormalSystem/Metalogic/DiscreteNonCompactness.lean` (new) — two truth lemmas, the witness set
  and its index functions, the ℤ model, the three acceptance theorems, and (Phase 5) the
  strong-completeness refutation.
- `FormalSystem/Metalogic/SetConsequence.lean` (modified) — `SatisfiableDiscreteSet`,
  `CompactDiscrete`, `StrongCompletenessDiscrete`, widened docstring.
- `FormalSystem/Metalogic.lean` (modified) — aggregator import plus docstring bullets.
- `FormalSystem/Metalogic/StrongCompleteness.lean` (modified) — docstring cross-references only.
- `specs/425_machine_check_discrete_non_compactness_witness/summaries/01_*-summary.md` — captured
  `#print axioms` output for every new declaration.

## Rollback/Contingency

Every phase is additive and confined to four files, one of which is new. To revert: delete
`FormalSystem/Metalogic/DiscreteNonCompactness.lean`, drop its import line from
`FormalSystem/Metalogic.lean`, and `git checkout` the two docstring-modified files. Nothing
existing depends on the new declarations, so the tree returns to its pre-task state with no
downstream repair. Per-phase commits (per the Commit-Per-Green-Substep Mandate) make partial
rollback to any green boundary straightforward.

If Phase 4 fails to compile, report §8's zero-debt statement applies: the discrepancy is a
transcription error against report §3, not a mathematical gap, and the scratch probe is
reproducible with `lake env lean` against the built tree. Diff the transcription against §3
before attempting any repair, and never insert a `sorry`.
