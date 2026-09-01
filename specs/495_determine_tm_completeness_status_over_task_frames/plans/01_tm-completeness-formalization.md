# Implementation Plan: TM completeness status over task frames

- **Task**: 495 - Determine TM completeness status over task frames
- **Status**: [IMPLEMENTING]
- **Effort**: 13.5 hours
- **Dependencies**: None (all prerequisites are sorry-free in-tree results)
- **Research Inputs**: `specs/495_determine_tm_completeness_status_over_task_frames/reports/01_tm-completeness-status.md`
- **Artifacts**: plans/01_tm-completeness-formalization.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: formal (deliverables are Lean 4)
- **Lean Intent**: true

## Overview

The research phase reached a definite negative verdict — **TM is not complete over task
frames** — and, more usefully, showed that the verdict is a *two-line consequence of theorems
already in this tree*: given `BXCanonical.completeness` and `blValid_iff_valid_tr`, "TM is
complete over task frames" and "forward conservativity holds at `FrameClass.Base`" are the same
proposition. This plan lands the machine-checkable portion of that finding and stops precisely
where the report showed the tree structurally cannot go.

Four Lean deliverables, one prose deliverable, and one explicit non-goal:

1. **The reduction** — `TMCompleteBase ↔ ForwardBase` (and its `.Discrete` mirror), an
   equivalence between two *unasserted* `Prop`s, so that no future dispatch can attempt TM
   completeness while believing it is honouring the forward-conservativity prohibition.
2. **The (Sp) validity result** — `□(DF φ) ∨ □(DN ψ)` is BL-valid on every task frame, for a
   purely order-theoretic reason; composing with `completeness` yields `⊢[Base] tr (Sp)`, the
   CEB analogue of `z1_translate`, without the source's TMP-NB/M5 derivation.
3. **`bl_soundness_discrete_succ`** — the binder-weakened BL soundness theorem (drop
   `IsSuccArchimedean`/`IsPredArchimedean`) whose only new mathematical content is the DF schema
   and its past-dual.
4. **The CEF closure** — the `Z1` countermodel at `ℚ ×ₗ ℤ`, giving forward conservativity
   refuted at `.Discrete` with *both* halves in-tree, and TM_f shown not weakly complete over
   ℤ-time.
5. **Prose correction** to `Conservativity.lean`, whose current "the missing prerequisite is now
   the countermodels alone" is too optimistic for the Base row.

**Non-goal, on the report's evidence, not on convenience**: CEB is not machine-checkable in this
tree. `BLTruthAt`/`bl_soundness` are `TaskFrame`-bound and TM⁺ is *unsound* on the two-fibre
class, so the composition route is unavailable in principle. It needs a new frame notion plus a
native BL soundness theorem — a separate task, proposed here but not scheduled.

**Definition of done**: `lake build` green; every new declaration `sorryAx`-free under
`#print axioms`; `Conservativity.lean`'s docstring row-accurate; and no forward-conservativity
theorem stated anywhere.

### Research Integration

Every phase below traces to a numbered section of
`reports/01_tm-completeness-status.md`, and each phase names its section. The report's
hand-verifications are treated as *specifications to be machine-checked*, never as established
results: the `Z1` countermodel evaluation (§6.1) and the Lemma A/B/C chain (§4.1) were verified
by hand only, and their in-Lean confirmation is the point of Phases 1, 3 and 7.

The report's own risk register (§8) is carried into Risks & Mitigations below, including the two
Mathlib gaps it found under the pinned version: no `Prod.Lex` `SuccOrder`/`PredOrder` instance,
and no counterpart to Lemma A.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

`specs/ROADMAP.md` was not supplied as a `roadmap_path` in the delegation context, so no roadmap
phases are added and ROADMAP.md is not modified by this plan. Read-only, for sequencing
awareness only: the roadmap's Phase 1 records Base/Dense/Discrete/Dedekind weak completeness as
DONE and axiom-clean, which is exactly the `BXCanonical.completeness` / `completeness_discrete`
footing Phases 4, 5 and 7 stand on. This task adds the *BL-side* (TM, not TM⁺) status that the
roadmap's completeness phase does not cover.

## Goals & Non-Goals

**Goals**:

- Pin "TM complete over task frames" and "forward conservativity at Base" as one proposition, in
  Lean, without asserting either.
- Land `BLValid (Sp φ ψ)` and `⊢[Base] tr (Sp φ ψ)` — the CEB witness's TM⁺ half.
- Land `bl_soundness_discrete_succ` at `[SuccOrder] [PredOrder]` only.
- Machine-check the `Z1` countermodel at `ℚ ×ₗ ℤ`, closing CEF's failing half and refuting TM_f's
  weak completeness over ℤ-time.
- Correct `Conservativity.lean`'s readiness claim to be row-dependent.

**Non-Goals**:

- **Any forward-conservativity theorem, `sorry`-ed or otherwise.** Non-negotiable, inherited
  from `Conservativity.lean`. It is provably false at two frame classes.
- **The CEB refutation.** Requires a frame notion outside `TaskFrame` plus a *native*
  (non-composed) BL soundness theorem over it — report §6.2. Propose as a follow-up task in
  Phase 8; do not attempt here.
- **Formalizing the Sahlqvist-canonicity characterization of TM's Kripke class** (report §5(i)).
  Textbook, unformalized, and a large separate development. Documented in Phase 8's prose as the
  principled answer with its provenance, never as a repository result.
- Modifying `specs/ROADMAP.md`.
- Any change to an existing theorem *statement*. Phases 3 and 6 add siblings; they do not
  re-bind `bl_soundness_discrete`.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `SuccOrder`/`PredOrder` for `Prod.Lex` absent from pinned Mathlib (report §8) | H | H — the report searched and found nothing | Phase 2 constructs both locally (`succ (q,n) = (q,n+1)`, `pred (q,n) = (q,n-1)`). **Documented fallback**: if the instance fights `Prod.Lex`'s order defeq, restate the DF lemma against a bare hypothesis `∀ t, ∃ s, t < s ∧ ∀ u, u < s → u ≤ t` and drop the `SuccOrder` binder entirely — this sidesteps the instance and is the report's own §8 mitigation. Taking the fallback changes Phase 6's binder bundle; record it in the phase's completion note. |
| Lemma A (every nontrivial totally ordered abelian group is densely ordered or has a least positive element) has no Mathlib counterpart under the pinned version | M | H | Prove locally in Phase 1, ~15 lines, no dependencies beyond `IsOrderedAddMonoid`. Note the tree's existing `complete_duration_discrete_or_dense` is **not** this lemma — it assumes the least-upper-bound property, which Lemma A must not. |
| The `temporal_duality` case of `bl_soundness_discrete_succ` is the only structurally new induction | M | M | Mirror `SoundnessLemmas/DenseValidity.lean`'s established per-axiom `…_swap` pattern. Cheap here: swaps of *Base* BL axioms are free via `bl_soundness_valid ∘ .temporal_duality`, so only `swapBL (df)` needs new content, and it is the `[PredOrder]` mirror of the `df` case. |
| Landing the reduction is misread as approaching forward conservativity | H | L | The reduction asserts neither side. Phase 4's docstring must state the prohibition explicitly and note that the reduction *strengthens* it by exposing a second phrasing of the forbidden claim. Phase 9 greps for any `sorry` adjacent to a `forward`-shaped statement. |
| The report's hand-verified `Z1` countermodel evaluation is wrong in a detail | M | L | Phase 7 machine-checks it. If the valuation `fun w _ => 1 ≤ w.2.1` does not give `BLTruthAt … (atom p) ↔ 1 ≤ t.1` definitionally, adjust the valuation rather than the carrier — the carrier's admissibility is independently probed in `DiscreteCarrierProbe.lean`. |
| Phase 6's axiom-case table assumes `Dense ≰ Discrete` and `Dedekind ≰ Discrete` kill `dn`/`co` | M | L | Already `decide`-checked in-tree (`BaseLanguage/Axioms.lean:162-168` shows the shape). Use the same `show … by decide` routing through the reduced frame class, since `decide` cannot act on a goal carrying a free `φ`. |
| Scope creep into the CEB native-soundness layer | M | M | It is an explicit Non-Goal. Phase 8 proposes it as a follow-up task; no phase here schedules it. |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2, 4 | -- |
| 2 | 3 | 1 |
| 3 | 5, 6 | 3 |
| 4 | 7 | 2, 4, 6 |
| 5 | 8 | 4, 5, 7 |
| 6 | 9 | 1, 2, 3, 4, 5, 6, 7, 8 |

Phases within the same wave can execute in parallel.

**Territory note for parallel waves.** Wave 1's three phases touch disjoint files:
Phase 1 owns `Semantics/DurationClassification.lean`; Phase 2 owns a new
`Semantics/LexCarrier.lean`; Phase 4 owns a new `Metalogic/TMCompletenessReduction.lean` plus a
single append to `Metalogic/BaseLanguageSoundness.lean`. Wave 3's two phases likewise: Phase 5
owns a new `Metalogic/SpWitness.lean`, Phase 6 owns `Semantics/BLValidity.lean` +
`Metalogic/BaseLanguageSoundness.lean`. Phase 4's `BaseLanguageSoundness.lean` append and Phase
6's must not run concurrently — they are in different waves, which is what keeps them serialized.

---

### Phase 1: Lemma A — the order-theoretic dichotomy [COMPLETED]

**Goal**: Prove that every nontrivial totally ordered abelian group is either densely ordered or
has a least strictly positive element, with no least-upper-bound and no Archimedean hypothesis.
This is the pivot of the whole (Sp) argument (report §4.1, Lemma A).

**Tasks**:
- [ ] Read `FormalSystem/Semantics/DurationClassification.lean` and confirm the new lemma is
      genuinely absent: `complete_duration_discrete_or_dense` assumes lub, and
      `isLeast_pos_succ_zero` assumes `[SuccOrder]`. Neither is Lemma A.
- [ ] State `duration_dense_or_least_pos` over `[AddCommGroup D] [LinearOrder D]
      [IsOrderedAddMonoid D] [Nontrivial D]`: `DenselyOrdered D ∨ ∃ d : D, IsLeast {x | 0 < x} d`.
- [ ] Prove it: if not densely ordered, obtain `a < b` with nothing strictly between; set
      `d := b - a`; show `0 < d`, and that `0 < c < d` gives `a < a + c < b`, contradiction.
- [ ] Add a module-docstring paragraph placing the new lemma against its two existing neighbours,
      stating explicitly which hypotheses it does *not* take and why that matters.

**Timing**: 1 hour

**Depends on**: none

**Verification Tier**: local

**Files to modify**:
- `FormalSystem/Semantics/DurationClassification.lean` — add `duration_dense_or_least_pos` plus
  docstring paragraph

**Verification**:
- `lake build FormalSystem.Semantics.DurationClassification` green
- `#print axioms duration_dense_or_least_pos` shows no `sorryAx`
- The statement's binder bundle contains no `lub` hypothesis and no `Archimedean`/`IsSuccArchimedean`

---

### Phase 2: `Prod.Lex` successor/predecessor infrastructure at `ℚ ×ₗ ℤ` [COMPLETED]

**Goal**: Supply the `SuccOrder` and `PredOrder` instances the pinned Mathlib lacks for
`Prod.Lex`, so the CEF countermodel carrier can discharge `bl_soundness_discrete_succ`'s binders
(report §6.1, closing paragraph).

**Tasks**:
- [ ] Confirm the Mathlib gap under the pinned version rather than assuming it: search for a
      `SuccOrder (α ×ₗ β)` / `PredOrder (α ×ₗ β)` instance. If one exists, this phase reduces to
      an instance-availability `example` and the remaining tasks are dropped.
- [ ] Construct `SuccOrder (ℚ ×ₗ ℤ)` with `succ (q, n) = (q, n + 1)`, via a
      `SuccOrder.ofSuccLeIff`-style construction.
- [ ] Construct the `PredOrder` mirror, `pred (q, n) = (q, n - 1)`.
- [ ] Record `example`s that `ℚ ×ₗ ℤ` is **not** `IsSuccArchimedean` — documentation only. This
      is never *needed* as a proof obligation (the binder is merely not assumed), but it is what
      makes the countermodel's point legible to a reader.
- [ ] Cross-reference `BXCanonical/DiscreteCarrierProbe.lean`, which already probes this carrier
      for the four `FrameClass.Base` binders, so the two modules read as one story.

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: the plan asserts (a) that no `Prod.Lex` `SuccOrder`/`PredOrder` instance
exists in the pinned Mathlib, and (b) that each construction is "short". Both are the report's
estimates, not facts. Confirm (a) by the search in task 1 before writing any instance; confirm
(b) by the construction itself, and if either instance exceeds ~40 lines or fights `Prod.Lex`'s
order defeq, stop and take the documented fallback in Risks (bare successor hypothesis, no
instance), recording the switch in the phase completion note.

**Files to modify**:
- `FormalSystem/Semantics/LexCarrier.lean` (new) — the two instances plus the non-Archimedean
  `example`s

**Verification**:
- `lake build FormalSystem.Semantics.LexCarrier` green
- `example : SuccOrder (ℚ ×ₗ ℤ) := inferInstance` and the `PredOrder` sibling both elaborate
- `example : ¬ IsSuccArchimedean (ℚ ×ₗ ℤ)` (or an equivalent recorded witness) elaborates

---

### Phase 3: DF and DN semantic lemmas, and their past-duals [COMPLETED]

**Goal**: Prove the four semantic facts that Phases 5 and 6 both consume — the shared
mathematical core of this task (report §4.1 Lemmas B and C, plus §6.1's past-dual obligation).

**Tasks**:
- [ ] **Lemma B, least-positive form**: if `F.Duration` has a least strictly positive element `d`,
      then `BLTruthAt M τ t (df-formula φ)` holds at every `M`, `τ`, `t`. Witness `F(Hφ)` at
      `s := t + d`; any `u < s` satisfies `u ≤ t` (else `0 < u - t < d`), so `φ(u)` follows from
      `Hφ` or from `φ` at `t`.
- [ ] **Lemma B, `SuccOrder` form**: the same conclusion under `[SuccOrder F.Duration]`, with
      `Order.succ t` as the witness. Derive it from the least-positive form via
      `DurationClassification.isLeast_pos_succ_zero` and `succ_eq_add_succ_zero` if that is
      cheaper than a second direct proof; otherwise prove directly.
- [ ] **Lemma C**: if `F.Duration` is densely ordered, `BLTruthAt M τ t (dn-formula ψ)` holds
      everywhere. Given `GGψ` at `t` and `t < s`, density supplies `t < r < s`; apply `GGψ` at `r`
      then `s`.
- [ ] **The past-dual of Lemma B**: `swapBL (df φ)` = `(Gφ ∧ φ ∧ P⊤) → P(Gφ)` is true everywhere
      under `[PredOrder F.Duration]`. The `Order.pred` mirror of the `SuccOrder` form.
- [ ] Use the existing `@[simp]` lemmas `BLTruth.past_iff`, `future_iff`, `someFuture_iff`,
      `somePast_iff`, `box_iff`, `and_iff`, `imp_iff` throughout rather than unfolding `BLTruthAt`.
- [ ] Pin each lemma's association to `BaseLanguage.Axiom.df`'s exact shape
      `((φ.allPast.and φ).and BLFormula.top.someFuture).imp φ.allPast.someFuture` — the
      association `((Hφ ∧ φ) ∧ F⊤)` is deliberate and matches `Theorems.DiscreteUnfolding.dfSchema`.

**Timing**: 2 hours

**Depends on**: 1

**Verification Tier**: local

**Files to modify**:
- `FormalSystem/Semantics/BLSchemaValidity.lean` (new) — the four lemmas

**Verification**:
- `lake build FormalSystem.Semantics.BLSchemaValidity` green
- Each lemma `sorryAx`-free
- The `df` lemma's statement is syntactically the `BaseLanguage.Axiom.df` formula (check by
  elaborating `example (φ : BLFormula) : … := df_lemma …` against the axiom's own formula)

---

### Phase 4: The completeness/conservativity reduction [COMPLETED]

**Goal**: Land `TMCompleteBase ↔ ForwardBase` and its `.Discrete` mirror as theorems, asserting
neither side, so that the identity of the two questions is machine-pinned (report §3, §7 item 3).

**Tasks**:
- [ ] Add `blValidDiscrete_iff_validDiscrete_tr` to `Metalogic/BaseLanguageSoundness.lean` — the
      mirror of the existing `blValid_iff_valid_tr` with `ValidDiscrete`/`BLValidDiscrete`'s four
      extra instance binders threaded. Same two-branch `constructor` proof off `truthAt_tr`.
- [ ] Create `Metalogic/TMCompletenessReduction.lean` with the two `Prop` abbreviations at Base
      (`TMCompleteBase`, `ForwardBase`), **neither asserted**.
- [ ] Prove `tmCompleteBase_iff_forwardBase`. Forward: `soundness` then `blValid_iff_valid_tr`.
      Backward: `blValid_iff_valid_tr` then `BXCanonical.completeness`.
- [ ] Repeat at `.Discrete` (`TMCompleteDiscrete`, `ForwardDiscrete`,
      `tmCompleteDiscrete_iff_forwardDiscrete`) against `soundness_discrete` /
      `completeness_discrete` / the new mirror lemma.
- [ ] Write the module docstring: state the forward-conservativity prohibition explicitly, note
      that this module *strengthens* it by exposing a second phrasing of the forbidden claim, and
      state that neither `Prop` is asserted anywhere. Record that the backward direction is where
      TM⁺'s completeness over all task frames does the work — `cor:tm-completeness` row 1,
      machine-checked in-tree.
- [ ] Add the new module to whatever aggregator `FormalSystem/Metalogic.lean` (or the nearest
      import hub) uses, matching the convention already used by its siblings.

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: interface

**Files to modify**:
- `FormalSystem/Metalogic/BaseLanguageSoundness.lean` — append `blValidDiscrete_iff_validDiscrete_tr`
- `FormalSystem/Metalogic/TMCompletenessReduction.lean` (new) — the two reductions
- The Metalogic aggregator/import hub — one import line

**Verification**:
- `lake build` of the changed module plus its direct dependents green
- `#print axioms tmCompleteBase_iff_forwardBase` and the `.Discrete` sibling: no `sorryAx`
- **Prohibition check**: `grep -n "sorry" FormalSystem/Metalogic/TMCompletenessReduction.lean`
  returns nothing, and neither `TMCompleteBase` nor `ForwardBase` (nor their Discrete siblings)
  appears as the conclusion of any `theorem` in the file

---

### Phase 5: The (Sp) witness — validity and the TM⁺ half of CEB [NOT STARTED]

**Goal**: Prove `BLValid (Sp φ ψ)` from Lemma A's dichotomy plus Lemmas B and C, then derive
`⊢[Base] tr (Sp φ ψ)` from `completeness` — the CEB analogue of `z1_translate`, obtained without
the source's TMP-NB/M5 derivation (report §4.1, §6.2 closing paragraph).

**Tasks**:
- [ ] Define `Sp (φ ψ : BLFormula) : BLFormula := (dfFormula φ).box.or ((dnFormula ψ).box)`,
      reusing the exact `Axiom.df` and `Axiom.dn` formula shapes from Phase 3.
- [ ] Prove `BLValid (Sp φ ψ)`: case-split on `duration_dense_or_least_pos F.Duration`; the
      least-positive branch gives the left disjunct at every history via Lemma B, the dense
      branch gives the right via Lemma C. Note in the proof comment that the `□` is discharged by
      the frame carrying **one** shared `Duration`, which is what makes the dichotomy a property
      of the frame rather than of a history.
- [ ] Derive `sp_translate : ProofSystem.Derivable FrameClass.Base [] (tr (Sp φ ψ))` via
      `blValid_iff_valid_tr` then `BXCanonical.completeness`.
- [ ] Document the sharpening from report §4.2: the *un-boxed* `DF φ ∨ DN ψ` is valid on every
      strict linear order whatsoever, so what (Sp) detects is modal rigidity, not a temporal
      property — a refuting structure must be one where different histories see differently-shaped
      time. Prove the un-boxed claim if it is cheap; otherwise record it as a docstring remark
      with its §4.2 argument, explicitly flagged as unformalized.
- [ ] Docstring: cite (Sp) as a *reconstruction*, not the source's formula —
      `thm:ConservativeExtension` was deleted from the paper at `b07ceb31`, and
      `Conservativity.lean`'s provenance section is the authority on that.

**Timing**: 1.5 hours

**Depends on**: 3

**Verification Tier**: local

**Files to modify**:
- `FormalSystem/Metalogic/SpWitness.lean` (new) — `Sp`, `blValid_sp`, `sp_translate`

**Verification**:
- `lake build FormalSystem.Metalogic.SpWitness` green
- `#print axioms blValid_sp` and `#print axioms sp_translate`: no `sorryAx`
- `sp_translate` does **not** transitively depend on `Axiom.discrete_box_necessity` or
  `Axiom.modal_5_collapse` — that independence is the point of taking the completeness route

---

### Phase 6: `bl_soundness_discrete_succ` — the binder-weakened soundness theorem [NOT STARTED]

**Goal**: Land BL soundness at `FrameClass.Discrete` under `[SuccOrder] [PredOrder]` only,
dropping `IsSuccArchimedean`/`IsPredArchimedean` (report §6.1). This is the single missing
prerequisite for CEF.

**Tasks**:
- [ ] Add `BLValidDiscreteSucc` to `Semantics/BLValidity.lean`, mirroring `BLValidDiscrete`'s
      shape minus the two Archimedean binders. Add the `blValid_implies_blValidDiscreteSucc`
      weakening lemma alongside the three existing `blValid_implies_*` siblings.
- [ ] State `bl_soundness_discrete_succ` in `Metalogic/BaseLanguageSoundness.lean`. **This one
      cannot be a composition** — `soundness_discrete` carries the very binders being dropped —
      so it is proved by induction on `BaseLanguage.DerivationTree FrameClass.Discrete`.
- [ ] Discharge the axiom cases per the report's table:
      - `minFrameClass = .Base`: `bl_soundness_valid` via `FrameClass.base_le`, then weaken
        `BLValid → BLValidDiscreteSucc`.
      - `dn` / `co`: impossible, `absurd h_fc (by decide)`, routed through `show` at the reduced
        frame class first (`decide` cannot act on a goal carrying a free `φ`).
      - `df`: Phase 3's `SuccOrder`-form Lemma B. The only new semantic content.
- [ ] Discharge `assumption`, `modus_ponens`, `weakening` structurally; `necessitation` and
      `temporal_necessitation` at the validity level, as in `bl_soundness`.
- [ ] Discharge `temporal_duality` by swap-strengthening the induction, mirroring
      `SoundnessLemmas/DenseValidity.lean`'s per-axiom `…_swap` pattern. Swaps of Base BL axioms
      are free via `bl_soundness_valid ∘ .temporal_duality`; only `swapBL (df)` needs content,
      supplied by Phase 3's `PredOrder` past-dual.
- [ ] Add the empty-context form `bl_soundness_discrete_succ_valid`, matching the four existing
      `bl_soundness_*_valid` siblings.
- [ ] Extend the module docstring's "four soundness theorems" section to explain why this fifth
      one is *not* a composition, and that the difference is exactly the two dropped binders.

**Timing**: 2 hours

**Depends on**: 3

**Verification Tier**: interface

**Scope Hypothesis**: the report asserts the induction's net new content is "two dual semantic
lemmas, everything else plumbing", and that the `dn`/`co` cases die by `decide`. Confirm the
second before writing the first: elaborate
`example (φ : BLFormula) : ¬ ((Axiom.dn φ).minFrameClass ≤ FrameClass.Discrete) := show ¬ (FrameClass.Dense ≤ FrameClass.Discrete) by decide`
and the `co` sibling. If either fails, the frame-class lattice does not have the shape the report
assumed and the axiom-case table must be re-derived before proceeding.

**Files to modify**:
- `FormalSystem/Semantics/BLValidity.lean` — `BLValidDiscreteSucc`, weakening lemma
- `FormalSystem/Metalogic/BaseLanguageSoundness.lean` — `bl_soundness_discrete_succ`, its
  empty-context form, docstring extension

**Verification**:
- `lake build` of both modules plus their enumerated direct dependents green
- `#print axioms bl_soundness_discrete_succ`: no `sorryAx`
- The theorem's binder bundle contains `[SuccOrder F.Duration] [PredOrder F.Duration]` and
  **neither** `IsSuccArchimedean` nor `IsPredArchimedean`
- `bl_soundness_discrete` is unchanged — `git diff` shows no edit to its statement

---

### Phase 7: The `Z1` countermodel and the two CEF deliverables [NOT STARTED]

**Goal**: Machine-check `¬ ⊢ᴮᴸ[Discrete] Z1 p` at the carrier `ℚ ×ₗ ℤ`, thereby closing CEF with
both halves in-tree and refuting TM_f's weak completeness over ℤ-time (report §6.1).

**Tasks**:
- [ ] Assemble the countermodel: `D := ℚ ×ₗ ℤ`,
      `F := multiFamTaskFrameGen (TemporalOrder.of D) Unit`, `τ := multiFamHistoryGen () 0`
      (total by `multiFamHistoryGen_total`), `M.valuation := fun w _ => 1 ≤ w.2.1`.
- [ ] Prove the valuation lemma `BLTruthAt M τ t (atom p) ↔ 1 ≤ t.1`.
- [ ] Prove `Gp ↔ p` pointwise: if `t.1 ≥ 1` every `s > t` has `s.1 ≥ 1`; if `t.1 < 1` then
      `s := (t.1, t.2 + 1) > t` has `s.1 < 1`.
- [ ] Evaluate the three remaining components at `(0,0)`: `G(Gp → p)` true, `F(Gp)` true
      (witness `(1,0)`), `Gp` false (witness `(0,1)`). Conclude `¬ BLTruthAt M τ (0,0) (Z1 p)`.
- [ ] **Deliverable 1** — `not_bl_derivable_z1 : ¬ BaseLanguage.Derivable FrameClass.Discrete [] (Z1 p)`,
      by `bl_soundness_discrete_succ` against the countermodel (the `SuccOrder`/`PredOrder`
      instances come from Phase 2). Combined with the existing `z1_translate`, this is CEF refuted
      with both halves machine-checked.
- [ ] **Deliverable 2** — `BLValidDiscrete (Z1 p)` from `z1_translate` + `soundness_discrete` +
      `truthAt_tr`; combined with Deliverable 1 this refutes the `.Discrete` row of Phase 4's
      reduction, i.e. TM_f is not weakly complete over ℤ-time. State the theorem as the negation
      of `TMCompleteDiscrete` (Phase 4's `Prop`), so the two phases visibly compose.
- [ ] Docstring: record that the refuting structure **is** a task frame — a lexicographic product
      of ordered abelian groups is an ordered abelian group — so the CEF refutation never leaves
      `TaskFrame`, and that this is precisely where the Base row differs. By Hölder (paper
      `def:TMplus-f`, line 4613) `ValidDiscrete` is validity over ℤ-time up to isomorphism, which
      is what makes Deliverable 2 the TM_f-vs-TM⁺_f completeness gap rather than a weaker claim.

**Timing**: 2 hours

**Depends on**: 2, 4, 6

**Verification Tier**: interface

**Scope Hypothesis**: the countermodel evaluation above is the report's *hand* verification. Every
one of the five bullet-point truth values is a hypothesis until Lean confirms it. If the valuation
`fun w _ => 1 ≤ w.2.1` does not yield the atom lemma definitionally, adjust the valuation, not the
carrier — the carrier's admissibility is independently witnessed in `DiscreteCarrierProbe.lean`.

**Files to modify**:
- `FormalSystem/Metalogic/Z1Countermodel.lean` (new) — the model, the evaluation, and both
  deliverables

**Verification**:
- `lake build` of the new module plus its direct dependents green
- `#print axioms not_bl_derivable_z1` and the TM_f-incompleteness theorem: no `sorryAx`
- Deliverable 2's statement is literally `¬ TMCompleteDiscrete` (or unfolds to it), confirming
  Phases 4 and 7 compose rather than restate

---

### Phase 8: Documentation corrections and the CEB follow-up proposal [NOT STARTED]

**Goal**: Bring `Conservativity.lean`'s prose in line with what is now true, correcting the
row-independent readiness claim the report found too optimistic (report §7).

**Tasks**:
- [ ] **Correction 1** — replace "the missing prerequisite is now the countermodels alone" and
      "narrowed from three items to one" with a row-dependent statement:
      - **CEF**: prerequisite was a *binder-weakened* BL soundness theorem, now landed as
        `bl_soundness_discrete_succ`; the countermodel is assembly over `multiFamTaskFrameGen` at
        `ℚ ×ₗ ℤ`. **Both halves are now machine-checked** — point at Phase 7's module.
      - **CEB**: prerequisite is a *frame notion outside `TaskFrame`* plus a **native** BL
        soundness theorem over it. `BLTruthAt`/`bl_soundness` do not supply this and cannot: (Sp)
        is BL-valid on every task frame (now a theorem, Phase 5), and TM⁺ is *unsound* on the
        two-fibre class, so `translate`-then-`soundness` is unavailable in principle.
- [ ] **Correction 2** — in the CEF section, record that the refuting structure is an ordinary
      `TemporalOrder`, not an exotic object, and cross-reference `DiscreteCarrierProbe.lean`.
- [ ] **Correction 3** — cross-reference `TMCompletenessReduction.lean` from the "Why it must not
      be `sorry`-ed" section, noting that TM completeness over task frames is now formally pinned
      as the same proposition and falls under the same prohibition.
- [ ] Update the CEB section to point at `SpWitness.lean` for the TM⁺ half, giving it the same
      standing `z1_translate` gives CEF's.
- [ ] Record the two live-paper facts: `def:TMplus-f` pins TM⁺_f's completeness class to ℤ-time
      via Hölder; and the **commented** line at `possible_worlds.tex:4614` states in the author's
      own words that TM_f is sound over the full discrete class with completeness there **open**.
      Cite the latter as the author's position while flagging that it is commented out and
      therefore not live text.
- [ ] Record report §5(i)'s Kripke-level answer (S5 ⊗ Kt4.3 + MF, complete by Sahlqvist
      canonicity) as the principled answer to "what is TM complete for", explicitly labelled
      standard-but-unformalized and *not* a repository result.
- [ ] Propose — do not create — a follow-up task for the CEB native BL soundness layer: a new
      frame notion, a new truth definition, a native soundness theorem over it (all 11 TM axiom
      schemata verified directly, plus MP, MN, temporal necessitation and TD), then the two-fibre
      instance. Record the proposal in this plan's completion note for the orchestrator to route.

**Timing**: 1 hour

**Depends on**: 4, 5, 7

**Verification Tier**: prose

**Files to modify**:
- `FormalSystem/Metalogic/Conservativity.lean` — module docstring only

**Verification**:
- Diff read-through confirms every changed hunk lies inside the `/-! … -/` module docstring; no
  theorem statement, no `def`, no proof term is touched
- `lake build FormalSystem.Metalogic.Conservativity` green (docstring edits still elaborate)
- The strings "the missing prerequisite is now the countermodels alone" and "narrowed from three
  items to one" no longer appear in the file
- Every module path named in the new prose exists on disk

---

### Phase 9: Tree-wide acceptance [NOT STARTED]

**Goal**: Confirm the whole tree is green, every new declaration is `sorryAx`-free, and the hard
constraint was honoured.

**Tasks**:
- [ ] Full `lake build` from a clean-ish state; zero errors.
- [ ] `#print axioms` (or `lean_verify`) on every new top-level declaration:
      `duration_dense_or_least_pos`, the four Phase 3 schema lemmas, the two Phase 4 reductions,
      `blValidDiscrete_iff_validDiscrete_tr`, `blValid_sp`, `sp_translate`,
      `bl_soundness_discrete_succ` and its valid-form, `not_bl_derivable_z1`, and the TM_f
      incompleteness theorem. Each must show exactly `[propext, Classical.choice, Quot.sound]`
      or a subset — no `sorryAx`.
- [ ] **Hard-constraint audit**: grep every file touched by this task for `sorry`, and confirm no
      theorem anywhere concludes `ProofSystem.Derivable fc [] (tr φ) → BaseLanguage.Derivable fc [] φ`
      or any approximation of it.
- [ ] Confirm no existing theorem *statement* changed: `git diff` over
      `BaseLanguageSoundness.lean`, `BLValidity.lean`, `DurationClassification.lean` shows
      additions and docstring text only.
- [ ] Update the affected `README.md` files under `FormalSystem/Semantics/` and
      `FormalSystem/Metalogic/` to list the new modules, matching each README's existing entry
      convention.
- [ ] Run `bash scripts/check-paper-definitions.sh` and record its output; the report notes it
      already reports two drifted and six dangling anchors, none consumed here — confirm this task
      added none.

**Timing**: 1 hour

**Depends on**: 1, 2, 3, 4, 5, 6, 7, 8

**Verification Tier**: full

**Files to modify**:
- `FormalSystem/Semantics/README.md` — new module entries
- `FormalSystem/Metalogic/README.md` — new module entries

**Verification**:
- `lake build` exits 0 with no errors
- No `sorryAx` in any new declaration's axiom set
- The hard-constraint grep returns nothing
- `check-paper-definitions.sh` output unchanged in kind from the report's recorded baseline

---

## Testing & Validation

- [ ] `lake build` green tree-wide after every phase that touches a `.lean` file
- [ ] Every new declaration `sorryAx`-free under `#print axioms`
- [ ] `bl_soundness_discrete_succ` demonstrably drops both Archimedean binders while
      `bl_soundness_discrete` is byte-identical to its pre-task form
- [ ] `not_bl_derivable_z1` composes with the existing `z1_translate` to give CEF with both
      halves in-tree
- [ ] Phase 7's Deliverable 2 is stated as the negation of Phase 4's `TMCompleteDiscrete`
- [ ] `sp_translate` does not transitively depend on `discrete_box_necessity` or
      `modal_5_collapse`
- [ ] **Hard constraint**: no forward-conservativity theorem is stated anywhere in the tree, and
      no `sorry` was added by this task

## Artifacts & Outputs

**New Lean modules**:
- `FormalSystem/Semantics/LexCarrier.lean` — `Prod.Lex` succ/pred instances at `ℚ ×ₗ ℤ`
- `FormalSystem/Semantics/BLSchemaValidity.lean` — DF/DN semantic lemmas and past-duals
- `FormalSystem/Metalogic/TMCompletenessReduction.lean` — the two unasserted-`Prop` equivalences
- `FormalSystem/Metalogic/SpWitness.lean` — `Sp`, `blValid_sp`, `sp_translate`
- `FormalSystem/Metalogic/Z1Countermodel.lean` — the countermodel and both CEF deliverables

**Modified Lean modules**:
- `FormalSystem/Semantics/DurationClassification.lean` — Lemma A
- `FormalSystem/Semantics/BLValidity.lean` — `BLValidDiscreteSucc` + weakening
- `FormalSystem/Metalogic/BaseLanguageSoundness.lean` — mirror bridge lemma,
  `bl_soundness_discrete_succ`, docstring
- `FormalSystem/Metalogic/Conservativity.lean` — module docstring corrections only

**Documentation**:
- `FormalSystem/Semantics/README.md`, `FormalSystem/Metalogic/README.md` — new module entries

**Proposed follow-up (not created by this plan)**:
- A CEB task: new frame notion outside `TaskFrame`, native BL truth definition, native BL
  soundness theorem, two-fibre instance. Sized roughly as `SoundnessLemmas/` on the BL⁺ side,
  though simpler because BL has no `untl`/`snce`.

## Rollback/Contingency

Every phase is additive except Phase 8, which touches a docstring only. Rollback is therefore
per-phase and clean:

- **Phases 1-3, 5, 7** — revert the phase's commit; the new module is deleted or the appended
  lemma removed. No existing declaration depends on them until the later phase that consumes
  them, so an early-wave rollback cascades only forward.
- **Phase 2 fallback** (not rollback): if the `Prod.Lex` instances fight the order defeq, switch
  to the bare successor hypothesis form recorded in Risks. This changes Phase 6's binder bundle;
  Phase 6 must then be re-planned before it starts, not patched mid-flight.
- **Phase 4** — the reduction is standalone; reverting it removes `TMCompletenessReduction.lean`
  and the one appended bridge lemma. Phase 7's Deliverable 2 would then need restating in its own
  terms.
- **Phase 6** — the highest-risk revert, since Phase 7 depends on it. If the `temporal_duality`
  case proves intractable, mark Phase 6 `[BLOCKED]` and stop: **do not** discharge it with
  `sorry`. A `sorry`-ed soundness theorem here would propagate into Phase 7's `not_bl_derivable_z1`
  and produce an unsound "refutation", which is exactly the failure mode
  `Conservativity.lean`'s prohibition exists to prevent.
- **Phase 8** — docstring-only; `git checkout` the single file restores it.

If the task is abandoned mid-flight, Phases 1-5 stand alone as useful results (a new
order-theoretic lemma, the schema semantics, the reduction, and the CEB TM⁺ half) even with
Phases 6-7 unlanded. Phase 8's docstring corrections must **not** be landed without Phase 7,
since they claim CEF is machine-checked.
