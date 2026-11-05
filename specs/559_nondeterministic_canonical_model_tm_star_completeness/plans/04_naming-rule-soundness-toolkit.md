# Implementation Plan: Naming-rule soundness toolkit

- **Task**: 559 - Nondeterministic canonical model / TM⋆ completeness (narrowed to the naming-rule soundness toolkit)
- **Status**: [IMPLEMENTING]
- **Effort**: 12 hours
- **Dependencies**: None
- **Research Inputs**: `specs/559_nondeterministic_canonical_model_tm_star_completeness/reports/03_axiomatizability-rules-engine.md`, `specs/559_nondeterministic_canonical_model_tm_star_completeness/reports/04_semantics-first-task-frames.md`, `specs/559_nondeterministic_canonical_model_tm_star_completeness/probes/03_morphisms-clock-rule-lc-schema.lean`
- **Artifacts**: plans/04_naming-rule-soundness-toolkit.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Port report 03's four soundness facts — truth invariance under two-way bounded morphisms,
Gabbay's irreflexivity rule, the stronger clock rule, and the Auxiliary-Atoms expansion — from
the Mathlib-only probe `probes/03_morphisms-clock-rule-lc-schema.lean` into the library, stated
against the repository's own `FrameOver`/`WorldHistory`/`PlusTruthAt`. Invariance extends
`FormalSystem/Semantics/HistoryMorphism.lean`; the three naming/expansion results land in a new
`FormalSystem/Metalogic/NamingRules.lean`. Definition of done: the landed declarations compile
sorry-free with no new axiom, carry docstrings, hold a theorem-index row each under a new
*Naming rules and model transformations* subsection, and carry a re-measured C14 axiom baseline.

### Research Integration

Four findings from the pre-planning codebase sweep reshape the probe-to-library port and are
load-bearing for the phase breakdown below.

**(a) The clock product is already in the library, in a stronger form than the probe's.**
`FrameOver.translationProduct` (`FormalSystem/Semantics/Frames/TranslationProduct.lean`) is the
probe's `clockR`, over an arbitrary duration group rather than only `ℤ`, and it already carries
every fact the probe's `clock_irr_sound` consumes: `translationProduct_isRegular` (the probe's
`clock_DS`, strengthened to all four frame constraints), `translationProduct_sat` (the product
lies in exactly the same frame class), `clock_eq` (the clock is time plus a constant — the
probe's `clock_eq`), `liftModel`/`liftH`/`projH`/`liftH_through`, `plus_invariance` (the probe's
`tw_invariance` specialised to this projection), and `FrameOver.translationProductProj :
HistMorphism F.translationProduct F`. Deliverable items (2) and (3) therefore require no frame
construction at all.

**(b) `HistMorphism` already packages exactly what the probe's invariance induction consumes.**
`HistMap` carries `forth` and `lift`; `HistMorphism` adds `onto`. The probe derives `lift` from
its `forth`/`back` fields and `onto` from surjectivity, then runs a seven-case induction using
precisely those three facts. So the probe's `tw_invariance` ports as *truth invariance along a
`HistMorphism`*, with `HybridLanguage/HybridInvariance.lean`'s `regFree_invariance` as a
line-by-line template (its `box` case uses `onto`, its `stab` case uses `lift`). What is genuinely
absent is a direct `PlusTruthAt` statement: the existing general version is for `HybridFormula`,
and the existing `PlusTruthAt` version is specialised to the translation product.

**(c) The reflection convention collapses the probe's `forth` and `back` into one condition.**
`FrameOver.TaskRel` is the reflective extension of a positive-cone relation, so
`F.TaskRel w d u ↔ F.TaskRel u (-d) w` holds as the theorem `FrameOver.reflection`. The probe's
`back` field (lift a predecessor) is its `forth` field at a negative duration. A two-way bounded
morphism of task frames is therefore a *single* preimage-step condition quantified over all
durations, which is a simplification over the probe, not a complication.

**(d) A located obstruction for item (4), found at plan time.** The probe's `coneR` records the
step path as a `List W` with `y.2 = x.1 :: x.2`, so list length counts steps. `TaskFrame`s are
compositional — `TaskRel w (x + y) u ↔ ∃ v, TaskRel w x v ∧ TaskRel v y u`, every duration
subdivides — so a relation whose record counts steps cannot be a `FrameOver` relation as the
probe writes it. The probe's digraph has unit steps only and never meets this constraint. Phase 7
is scoped accordingly: reformulate the path record (`PartialHistory` is the candidate) within a
bounded budget, or close the phase as `[COMPLETED WITH EXCLUSIONS]` with the obstruction located,
per the dispatch's own guardrail.

### Prior Plan Reference

No prior plan. This round's dispatch supersedes three earlier research rounds whose content has
already landed (see the dispatch description); nothing from them is re-derived here.

### Roadmap Alignment

No `roadmap_path` was provided in this dispatch and no roadmap phases are included.

## Goals & Non-Goals

**Goals**:

- `TwoWayBounded` — two-way bounded morphisms of task frames over one temporal order
- `HistMorphism.plus_invariance` — L⁺ truth invariance along a history-lifting morphism (the
  `tw_invariance` port, deliverable item 1)
- `TwoWayBounded.exists_preimage_step` — the reflection-collapsed forth/back condition
- `TwoWayBounded.exists_histMorphism_of_isZTime` — a two-way bounded surjection over discrete
  time is a history-lifting morphism (the `lift_walk` port)
- `Fresh` — an atom does not occur in an L⁺ formula
- `plusTruthAt_congr_of_fresh` — L⁺ truth is unchanged by a valuation change at a fresh atom only
  (the `T_fresh` port)
- `nm`, `once`, `rigid`, `clockAnte` — the clock rule's antecedent
- `clock_irr_sound` — soundness of the clock rule (deliverable item 3)
- `irr_sound` — soundness of Gabbay's plain irreflexivity rule (deliverable item 2)
- `aa_expand` — the Auxiliary-Atoms expansion (deliverable item 4)

**Non-Goals**:

- Any completeness, decidability or axiomatizability claim. This task lands soundness lemmas and
  one model-transformation tool; the LC-schema and axiomatizability discussion in report 03 is
  out of scope, as is probe 03's Part I (`omega_limit`, `omega_chain`, `lcN_valid_full`).
- `probes/05_stab-definable-from-open-modals.lean`, owned by another live task.
- Any re-derivation of `plus_incomplete_base`, `hnOpen_openValid`, `hnStab_refuted_sinkFrame` or
  `stab_state_only`, all of which already hold in the library.
- Deriving `HistMap.lift` from a two-way bounded morphism over *dense* or *real* time. The
  construction needs a nearest-neighbour step; over dense time it would need a
  fiber-relative *Saturation* property that `forth`/`back` do not supply. Discrete time is where
  report 03's results live, and the generalisation is left explicitly unattempted.
- Adding `PlusFormula.atoms` (a `Finset Atom` function) to the syntax layer. `Fresh` is a
  naming-rule-local `Prop` on the seven constructors, declared in `NamingRules.lean` under its
  own namespace, so no declaration is injected into `FormalSystem.PlusLanguage` and no rebuild of
  the syntax layer's dependents is triggered.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Item (4) `aa_expand` does not port: the step-counting path record is not compositional (finding (d)) | M | H | Phase 7 is budget-bounded and has a sanctioned non-landing outcome — `[COMPLETED WITH EXCLUSIONS]` with a `#### Reasoned Exclusions` table locating the obstruction. Phases 1-6 and 8 do not depend on it |
| The `lift` derivation of Phase 3 needs a `SuccOrder`/`IsSuccArchimedean` induction whose shape is not yet pinned | M | M | Phase 2 isolates the one-step lemma first, so Phase 3 is a pure induction over an already-proved step. If the induction stalls, Phase 3 degrades to landing `TwoWayBounded` + the step lemma only, and `aa_expand` (its sole consumer) is already permitted to close with an exclusion |
| Adding `import FormalSystem.PlusLanguage.PlusTruth` to `HistoryMorphism.lean` widens the import surface of a module that nine others import | M | L | Verified no cycle: `PlusTruth`'s import closure is `{Semantics.Truth, Semantics.TruthClauses, Semantics.TaskModel, Semantics.PartialHistory, Syntax.Formula, Syntax.Context, PlusLanguage.Formula}`, none of which imports `HistoryMorphism`. Phase 1 declares `interface` tier and builds the enumerated dependents |
| `docs/theorem-index.md` is in concurrent sibling task 859's declared `file_scope` | M | M | Phase 8 re-reads the file immediately before editing, adds a new `###` subsection rather than editing existing rows, and stages only its own hunks with an explicit file list. A foreign commit or foreign modification observed there stops the phase and is reported |
| Numerals do not elaborate under an opaque `F.Duration` (`OfNat F.Duration 1` is data), so `s + 1` from the probe has no counterpart | L | H | Use `Order.succ` with an explicit `SuccOrder ↑D` instance binder, the idiom `Extension/Completion.lean`'s `extension_of_isZTime`/`hasNearest_of_succPred` already uses |
| The C14 axiom baseline is a heredoc pair compared by exact string equality, so a hand-typed profile silently breaks the build | H | L | Phase 8 measures every profile with `#print axioms` and pastes the measured output; the dispatch's "never type an axiom profile by hand" is treated as a hard constraint |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 4 | -- |
| 2 | 2, 5 | 1, 4 |
| 3 | 3, 6 | 2, 5 |
| 4 | 7 | 3, 5 |
| 5 | 8 | 3, 6, 7 |

Phases within the same wave can execute in parallel.

### Phase 1: L⁺ truth invariance along a history-lifting morphism [COMPLETED]

**Goal**: Land deliverable item (1), the load-bearing lemma: `PlusTruthAt` is invariant along any
`HistMorphism`, between the pulled-back model on the source and the given model on the image.

**Tasks**:

- [ ] Re-read `FormalSystem/Semantics/HistoryMorphism.lean` immediately before editing (concurrent
      siblings are dispatched this cycle)
- [x] Add `import FormalSystem.PlusLanguage.PlusTruth` and `open FormalSystem.PlusLanguage` *(deviation: altered — imported `FormalSystem.PlusLanguage.PlusValidity` instead, which re-exports `PlusTruth` and additionally supplies `TaskFrame.PlusValidOn`, without which `plusValidOn` cannot be stated; no cycle: `HistoryMorphism` is absent from PlusValidity's 28-module import closure)*
- [ ] Prove `HistMorphism.plus_invariance`: the seven-case induction on `PlusFormula`, with
      `HybridLanguage/HybridInvariance.lean`'s `regFree_invariance` as the template — `box` via
      `onto` + `WorldHistory.ext_state`, `stab` via `lift` at the present time, `atom` by `rfl`
      through `HistMap.pullM`/`HistMap.mapH_state`, the four remaining cases by congruence
- [x] Add the frame-validity corollary `HistMorphism.plusValidOn` (validity on the source frame
      follows from validity on the image frame), mirroring `plusValidOn_of_prod` *(deviation: altered — the parenthetical reads the direction backwards; only `source ⟹ image` holds, which is the direction `plusValidOn_of_prod` records and the one landed)*
- [ ] Extend the module docstring's *Main Results* list and the *History-lifting morphisms*
      narrative with the new invariance, stating that it is the L⁺ counterpart of the
      `HybridFormula` version and that the translation-product-specific `plus_invariance` is its
      intended instance
- [ ] `lean_verify FormalSystem.Semantics.HistMorphism.plus_invariance` — no sorry, no new axiom

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: interface

**Tier Justification**: The edit adds an import line to a module nine others import without
changing any existing signature, so the covering check is the scoped build of the changed module
plus its enumerated one-hop dependents:
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Semantics.HistoryMorphism FormalSystem.Semantics.Frames.TranslationProduct FormalSystem.HybridLanguage.HybridInvariance FormalSystem.HybridLanguage.HybridRecurrence FormalSystem.HybridLanguage.HybridTransposition FormalSystem.QuantLanguage.QuantInvariance FormalSystem.QuantLanguage.QuantRecurrence FormalSystem.Metalogic.Decidability.WitnessFamily.Sharing.Stability FormalSystem.Semantics`.

**Scope Hypothesis**: `HistoryMorphism.lean` has exactly nine direct importers (the eight modules
above plus `FormalSystem.lean`). Confirm at implementation time with
`grep -rn 'import FormalSystem.Semantics.HistoryMorphism' --include=*.lean .` and build whatever
that enumerates, rather than trusting this list.

**Files to modify**:

- `FormalSystem/Semantics/HistoryMorphism.lean` - new import, `HistMorphism.plus_invariance`,
  `HistMorphism.plusValidOn`, docstring additions

**Verification**:

- The scoped build above is green
- `lean_verify` reports `[propext, Classical.choice, Quot.sound]` and no sorry for both new
  declarations

---

### Phase 2: Two-way bounded morphisms and the one-step preimage lemma [COMPLETED]

**Goal**: Introduce the `TwoWayBounded` notion for task frames and prove that, under the
reflection convention, a single preimage-step condition quantified over all durations supplies
both of the probe's `forth` and `back` fields.

**Tasks**:

- [ ] Re-read `FormalSystem/Semantics/HistoryMorphism.lean`
- [ ] Declare `structure TwoWayBounded {D : TemporalOrder} {F' F : FrameOver D}
      (f : F'.WorldState → F.WorldState)` with two fields: `forth` (the task relation is carried
      forward, matching `HistMap.forth`) and `step` (every `F`-step out of an image state lifts:
      `F.TaskRel (f a) x v → ∃ b, F'.TaskRel a x b ∧ f b = v`)
- [ ] Prove `TwoWayBounded.exists_preimage_step` as the named, reusable form of `step`
- [ ] Prove `TwoWayBounded.exists_preimage_step_neg`: the backward half, obtained from `step` at
      `-x` through `FrameOver.reflection` — this is the lemma that discharges the probe's `back`
      field and is the content of finding (c)
- [ ] Prove `TwoWayBounded.ofHistMap` / `HistMap.twoWayBounded`-direction lemmas only insofar as
      they are needed by Phase 3; do not speculatively add both directions *(deviation: skipped — Phase 3 consumes neither direction; it builds a `HistMorphism` from `TwoWayBounded` directly, so both would be speculative, which this step's own "only insofar as they are needed" clause forbids)*
- [ ] Docstring the structure with the finding-(c) narrative: why a task-frame two-way bounded
      morphism needs one condition where a digraph one needs two
- [x] Record `FrameOver.translationProductProj`'s underlying `Prod.fst` as the intended instance
      in the docstring (do not re-prove it; `translationProductProj` already exists) *(deviation: altered — the docstring records it AND the phase's own verification criterion demands it be landed "as a worked instance, not as prose"; `FrameOver.translationProduct_twoWayBounded` therefore lands in `Frames/TranslationProduct.lean`, which the phase's Files-to-modify list omits, because `HistoryMorphism.lean` is below it in the import order)*

**Timing**: 1 hour

**Depends on**: 1

**Verification Tier**: local

**Tier Justification**: The phase adds new declarations to one module and changes no existing
signature and no import, so the covering check is the single-module build
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Semantics.HistoryMorphism`.

**Files to modify**:

- `FormalSystem/Semantics/HistoryMorphism.lean` - `TwoWayBounded`, `exists_preimage_step`,
  `exists_preimage_step_neg`, docstrings

**Verification**:

- The single-module build is green
- `lean_verify` on each new theorem: no sorry, no new axiom
- The structure is not vacuous: `FrameOver.translationProductProj`'s `Prod.fst` satisfies it (land
  this as a worked instance, not as prose)

---

### Phase 3: The lift construction over discrete time [COMPLETED]

**Goal**: Port `lift_walk`: a surjective two-way bounded morphism over discrete time yields a
`HistMorphism`, so `HistMap`'s `lift` field — primitive in the library today — becomes derivable
rather than assumed.

**Tasks**:

- [ ] Re-read `FormalSystem/Semantics/HistoryMorphism.lean`
- [ ] Study the discrete-time idiom already in the tree before writing anything:
      `FormalSystem/Semantics/Extension/Completion.lean`'s `extension_of_isZTime` and
      `hasNearest_of_succPred`, and how they thread `SuccOrder`/`PredOrder`/`IsSuccArchimedean`
      as explicit instance arguments rather than through instance search on an opaque
      `F.Duration`
- [ ] Prove the forward half: by `Order.succ` recursion from the anchor time, using Phase 2's
      `exists_preimage_step` at each step and `IsSuccArchimedean` to reach every later time
- [x] Prove the backward half symmetrically, by `Order.pred` recursion using
      `exists_preimage_step_neg` and `IsPredArchimedean` *(deviation: altered — both halves recurse on ℕ and are glued by one ℤ-indexed `chain`, with `Semantics/DurationClassification.lean`'s `intIso` supplying the index map; `IsSuccArchimedean` enters only through `intIso`, and `PredOrder`/`IsPredArchimedean` are carried as binders for the `IsZTime` reading of the name without being consumed. This also adds `import FormalSystem.Semantics.DurationClassification`, which the phase's no-import-change tier assumption did not anticipate; acyclic — `DurationClassification` imports only `TaskFrame`)*
- [ ] Assemble the two halves into a total state assignment and prove it respects the task
      relation at every pair of times (`F'.comp` composes the unit steps; this is the step the
      probe gets for free from `IsWalk` and the library does not)
- [ ] Prove `TwoWayBounded.exists_histMorphism_of_isZTime`: the assembled lift discharges
      `HistMap.lift`, and surjectivity of `f` plus the lift at an arbitrary anchor discharges
      `HistMorphism.onto`
- [ ] Docstring: state plainly that the construction is discrete-time-only and why (the dense
      case would need a fiber-relative *Saturation* that `forth`/`step` do not supply) — this is a
      scope statement, not an apology
- [ ] If the induction stalls after the budget below, stop: land `TwoWayBounded` and the step
      lemmas from Phase 2 and mark this phase `[BLOCKED]` with the goal state reached, per
      `plan-compliance.md`'s escalation requirement for `.lean` files

**Timing**: 2 hours

**Depends on**: 2

**Verification Tier**: local

**Tier Justification**: New declarations in one module with no signature or import change, so the
covering check is the single-module build
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Semantics.HistoryMorphism`.

**Scope Hypothesis**: this phase assumes the lift is constructible from `exists_preimage_step`
plus `Order.succ`/`Order.pred` Archimedean recursion and `F'.comp`, with no appeal to
*Saturation* in `F'`. Confirm by reaching a sorry-free proof; if *Saturation* turns out to be
needed, that is the located obstruction to record, not a reason to weaken the statement.

**Files to modify**:

- `FormalSystem/Semantics/HistoryMorphism.lean` - the two recursion halves,
  `TwoWayBounded.exists_histMorphism_of_isZTime`, docstrings

**Verification**:

- The single-module build is green
- `lean_verify FormalSystem.Semantics.TwoWayBounded.exists_histMorphism_of_isZTime`: no sorry, no
  new axiom
- Composed with Phase 1, the pair yields L⁺ invariance from `forth` + `step` + surjectivity alone;
  land that composition as a named corollary so the claim is machine-checked rather than asserted

---

### Phase 4: The `NamingRules` module and freshness [COMPLETED]

**Goal**: Create `FormalSystem/Metalogic/NamingRules.lean`, wire its import into the Metalogic
aggregator, and land the `T_fresh` port that both naming rules consume.

**Tasks**:

- [ ] Re-read `FormalSystem/Metalogic.lean` immediately before editing
- [ ] Create `FormalSystem/Metalogic/NamingRules.lean` with the standard copyright header, imports
      (`FormalSystem.Semantics.Frames.TranslationProduct`, `FormalSystem.PlusLanguage.PlusValidity`
      and whatever the proofs need), namespace `FormalSystem.Metalogic.NamingRules`, and a module
      docstring covering: what a naming rule is, why a time cannot be named globally but can be
      named within a stability cluster, the Reynolds/Gabbay sources, and a *Main Results* list
- [ ] Add `import FormalSystem.Metalogic.NamingRules` to `FormalSystem/Metalogic.lean` and add the
      matching entry to that file's module-docstring component list
- [ ] Define `Fresh (q : Atom) : PlusFormula → Prop` on the seven constructors
- [ ] Prove `plusTruthAt_congr_of_fresh`: two models agreeing at every atom other than `q` give
      the same truth value to every `q`-fresh formula, at every history and time. Template:
      `FormalSystem/Semantics/Truth.lean`'s `truthAt_atomFree_history_indep` for the induction
      shape; the `box` and `stab` cases are `forall_congr'`/`imp_congr` chains as in the probe's
      `T_fresh`
- [ ] Add the decidability/congruence helper lemmas the later phases actually need, and no others
- [ ] `lean_verify` both new declarations

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: interface

**Tier Justification**: Adding an import to the `FormalSystem/Metalogic.lean` aggregator makes the
new module part of every downstream build of that aggregator, so the covering check is the scoped
build of the new module plus the aggregator:
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.NamingRules FormalSystem.Metalogic`.

**Files to modify**:

- `FormalSystem/Metalogic/NamingRules.lean` - new module: header, imports, docstring, `Fresh`,
  `plusTruthAt_congr_of_fresh`
- `FormalSystem/Metalogic.lean` - one import line plus the matching docstring component entry

**Verification**:

- The scoped build above is green
- `lean_verify FormalSystem.Metalogic.NamingRules.plusTruthAt_congr_of_fresh`: no sorry, no new
  axiom
- `Fresh` is not vacuous: it rejects `PlusFormula.atom q` and accepts `PlusFormula.atom p` for
  `p ≠ q`, pinned as `example`s in the module

---

### Phase 5: The clock rule [COMPLETED]

**Goal**: Land deliverable item (3): an atom may be assumed to hold at exactly one time of every
history, with that time rigid under the stability modal.

**Tasks**:

- [ ] Re-read `FormalSystem/Metalogic/NamingRules.lean`
- [ ] Define the antecedent bundle as L⁺ formulas, using the derived connectives already in
      `PlusLanguage/Formula.lean` (`neg`, `and`, `or`, `someFuture`, `allFuture`, `somePast`,
      `allPast`, `always`): `nm q` (`q` now and at no other time of this history), `once q` (`q`
      at exactly one time of this history), `rigid q` (the time `q` holds is the same on every
      history through the current state), `clockAnte q` (`q` now, and everywhere `q` is a
      `⊡`-rigid name of one time)
- [ ] Prove the three auxiliary truth characterisations the soundness proof needs, over
      `F.translationProduct` with the valuation `q ↦ clock = 0`: `q` holds iff the clock reads
      zero; `nm q` holds wherever the clock reads zero (via `clock_eq`); `clockAnte q` holds at
      the anchor (the trichotomy-on-the-clock argument of the probe, with `Order.lt_trichotomy`
      on the duration group in place of the probe's `ℤ` version)
- [ ] Prove `clock_irr_sound (fc) (q) (φ) (hq : Fresh q φ) (hprem : PlusValidIn fc ((clockAnte q).imp φ)) : PlusValidIn fc φ`.
      Route: given a frame of the class, a model, a history and a time, instantiate the premise at
      `F.translationProduct` (in the class by `translationProduct_sat`, regular by
      `translationProduct_isRegular`) with the clock valuation and the lifted history
      (`liftH ... (0 - t)` placed by `liftH_through`); discharge the antecedent; then strip `q` by
      `plusTruthAt_congr_of_fresh` down to `liftModel`, and project by the library's existing
      `plus_invariance` plus `projH_liftH`
- [ ] Docstring the theorem with the semantic reading and the Reynolds/Gabbay attribution, and
      state explicitly that the proof reuses the library's translation product rather than
      building a clock product
- [ ] `lean_verify FormalSystem.Metalogic.NamingRules.clock_irr_sound`

**Timing**: 2 hours

**Depends on**: 4

**Verification Tier**: local

**Tier Justification**: New declarations confined to `NamingRules.lean` with no signature or
import change, so the covering check is the single-module build
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.NamingRules`.

**Scope Hypothesis**: this phase assumes the existing `plus_invariance`,
`translationProduct_sat`, `translationProduct_isRegular`, `clock_eq`, `liftH_through` and
`projH_liftH` cover every model-transformation step, so that no new frame construction is needed.
Confirm by reaching a sorry-free proof that cites only those; if a gap appears, record which fact
is missing rather than building a second clock product.

**Files to modify**:

- `FormalSystem/Metalogic/NamingRules.lean` - `nm`, `once`, `rigid`, `clockAnte`, the three
  auxiliary characterisations, `clock_irr_sound`, docstrings

**Verification**:

- The single-module build is green
- `lean_verify`: no sorry, no new axiom
- The rule is not vacuous: confirm `clockAnte q` is satisfiable on the translation product by
  exhibiting the anchor instance proved above, so the premise is not trivially unprovable

---

### Phase 6: Gabbay's plain irreflexivity rule [COMPLETED]

**Goal**: Land deliverable item (2) as a corollary: the clock antecedent implies `q ∧ H¬q`, so
soundness of the weaker rule follows from Phase 5.

**Tasks**:

- [ ] Re-read `FormalSystem/Metalogic/NamingRules.lean`
- [ ] Prove `irr_sound (fc) (q) (φ) (hq : Fresh q φ) (hprem : PlusValidIn fc (((atom q).and (atom q).neg.allPast).imp φ)) : PlusValidIn fc φ`
      by `clock_irr_sound`, discharging `q ∧ H¬q` from `clockAnte q` through the `once q`
      trichotomy exactly as the probe's `irr_sound` does, using `TruthClauses`' `and_iff`,
      `or_iff`, `allPast_iff`, `somePast_iff`, `someFuture_iff` and `always_iff_tri`
- [ ] Docstring with the attribution and the one-line reason the weaker antecedent suffices
- [ ] `lean_verify FormalSystem.Metalogic.NamingRules.irr_sound`

**Timing**: 0.5 hours

**Depends on**: 5

**Verification Tier**: local

**Tier Justification**: One new theorem in one module, no signature or import change, so the
covering check is the single-module build
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.NamingRules`.

**Files to modify**:

- `FormalSystem/Metalogic/NamingRules.lean` - `irr_sound` and its docstring

**Verification**:

- The single-module build is green
- `lean_verify`: no sorry, no new axiom

---

### Phase 7: The Auxiliary-Atoms expansion, or a located obstruction [COMPLETED WITH EXCLUSIONS]

**Goal**: Land deliverable item (4) — the forward-cone unravelling is a two-way-bounded-morphic
preimage whose forward cone is a tree, carrying a machine-state labelling — or record, precisely,
why it does not port.

**Tasks**:

- [ ] Re-read `FormalSystem/Metalogic/NamingRules.lean` and
      `FormalSystem/Semantics/PartialHistory.lean`
- [ ] Confirm or refute finding (d) against the real definitions: check whether a `FrameOver`
      relation can record the step path as the probe's `List W` does, given
      `TaskFrame.Compositional`. Record the verdict with the goal state that produced it
- [ ] If refuted (the list record does work), port `coneR`/`coneF`/`cone_twoWay`/`run`/`coneSt`
      and `aa_expand` directly, using Phase 2's `TwoWayBounded` and Phase 3's
      `exists_histMorphism_of_isZTime`, with `Order.succ` in place of the probe's `s + 1`
- [ ] If confirmed, attempt exactly one reformulation: record the path as a `PartialHistory` over
      the interval from the anchor rather than as a finite list, and check whether the machine run
      is still definable over discrete time (`Order.succ` recursion over an Archimedean interval).
      Do not attempt a third formulation
- [ ] On either success route: prove `aa_expand`, docstring it with the Reynolds 2001 attribution
      and the tree property of the forward cone, and `lean_verify` it
- [ ] On the obstruction route: land nothing speculative — no vacuous definition, no `sorry` — set
      the phase heading to `[COMPLETED WITH EXCLUSIONS]`, add the `#### Reasoned Exclusions` table
      below with the compositionality verdict and its evidence, and carry the same account into
      the task summary. A partial landing with an honest account is the dispatch's stated
      preference over a stalled task

#### Reasoned Exclusions

| Item | Reason | Evidence |
|------|--------|----------|
| `aa_expand` (deliverable item 4) | The forward-cone unravelling cannot be presented as a `FrameOver` within this phase's budget: `FrameOver.ofReflectiveRegular` demands *Saturation* of the presenting relation, and none of the three routes this tree has to *Saturation* applies to a path-recording relation on an unravelled carrier. The plan's own finding (d) predicted *Compositionality* as the blocker; that prediction is REFUTED (see the next row). | `FormalSystem/Semantics/TaskFrame.lean`'s `ofReflectiveRegular (W : Type) [Nonempty W] (R : W → ↑D → W → Prop) (hR : ...) (_hcomp : TaskFrame.Compositional R) (_hser : TaskFrame.Serial R) (_hlim : TaskFrame.Limit R) (_hsat : TaskFrame.Saturation R) : FrameOver D` — `_hsat` is a required argument. The unmeetable obligation, `#print TaskFrame.Saturation` at the unravelled carrier: `∀ (S : Set (Set (W ⊕ (W × List W)))), TaskFrame.DirectedFamily S → (∀ s ∈ S, (TaskFrame.IsFiber R s ∨ TaskFrame.IsSegment R s) ∧ s.Nonempty) → (⋂₀ S).Nonempty`. The three discharges, signatures read with `#check`: `saturation_of_finite : {W : Type} → [Finite W] → (R : W → D → W → Prop) → Saturation R` — unavailable, since `example (W : Type) [Nonempty W] : Infinite (W ⊕ (W × List W))` machine-checks and `FrameOver.worldNonempty` is a field, so every frame's carrier is nonempty; `saturation_of_fib_finite : (∀ (w : W) (x : D), (TaskFrame.Fib R w x).Finite) → TaskFrame.Saturation R` — unavailable, since `aa_expand`'s `F` is an arbitrary `FrameOver D`, which carries no finiteness field, and an unravelled fibre is in bijection with a fibre of the base; `saturation_of_deterministic : {F : TaskFrame} → F.Deterministic → TaskFrame.Saturation F.TaskRel` — unavailable, since the unravelling branches by construction. |
| Finding (d) itself — the plan-time claim that a step-counting path record "cannot be a `FrameOver` relation" because `TaskFrame`s are compositional | REFUTED against the real definitions. Over discrete time the durations are exactly the multiples of one step, so the number of steps is a function of the duration and `k = k₁ + k₂` subdivides. Composing single steps into the task the relation must carry at an *arbitrary* pair of times — the step finding (d) says a digraph gets for free and a task frame does not — is machine-checked, for exactly this shape of construction, by Phase 3. | `FormalSystem.Semantics.TwoWayBounded.exists_histMorphism_of_isZTime` and its private `chain_rel`, `FormalSystem/Semantics/HistoryMorphism.lean`: `intIso : ↑D ≃+o ℤ` makes `m • δ = intIso.symm m` exact, and `chain_rel` composes `k` single `δ`-tasks into the task at duration `(j - i) • δ` via `FrameOver.forward_comp` and `FrameOver.reflection`. |
| The one sanctioned reformulation (record the path as a `PartialHistory` over the interval from the anchor) | Attempted and rejected, by reasoning rather than by a machine proof, and recorded as such: the machine run stays definable by successor recursion, so the reformulation fixes nothing that was broken, while the carrier only grows (it embeds the finite-path carrier) and the fibre at `k` steps out of a recorded segment is in bijection with the set of `k`-step base paths out of its endpoint — the same set the list record gives. The *Saturation* obligation is therefore unchanged. Per the phase's own instruction, no third formulation was attempted. | `FormalSystem/Semantics/PartialHistory.lean`'s `structure PartialHistory` carries `domain`, `nonempty_domain`, `states` and an unconditional `respects_task`, and no finiteness; `FrameOver`'s own fields are `WorldState`, `worldNonempty` and `PosRel`, and no finiteness. |

**Nothing speculative was landed**: no `sorry`, no vacuous definition, and no new declaration at
all. The obstruction is recorded in `FormalSystem/Metalogic/NamingRules.lean`'s module docstring,
under *Not formalized* → *The Auxiliary-Atoms expansion, and where it stops*, so it travels with
the module rather than with this task's directory.

**Timing**: 2 hours (hard budget; the obstruction route closes the phase rather than extending it)

**Depends on**: 3, 5

**Verification Tier**: local

**Tier Justification**: Whichever route this phase takes, its edits are confined to
`NamingRules.lean` with no signature or import change, so the covering check is the single-module
build
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.NamingRules`.

**Scope Hypothesis**: finding (d) asserts that the probe's list-valued path record is
incompatible with `TaskFrame.Compositional`. This is a plan-time reading of the definitions, not a
machine-checked fact; the first task of this phase is to confirm or refute it against the real
`FrameOver.ofReflectiveRegular` obligations, and the phase's route is chosen by that verdict, not
by this hypothesis.

**Files to modify**:

- `FormalSystem/Metalogic/NamingRules.lean` - the cone construction and `aa_expand`, or (on the
  obstruction route) a docstring section recording the obstruction and no new declarations

**Verification**:

- The single-module build is green on either route
- Success route: `lean_verify FormalSystem.Metalogic.NamingRules.aa_expand` reports no sorry and
  no new axiom, and the cone frame is exhibited as regular and in the same frame class
- Obstruction route: the `#### Reasoned Exclusions` table is present with `Item`, `Reason` and
  `Evidence` columns, the `Evidence` cell quotes the specific unmeetable obligation, and no
  vacuous or `sorry`-bearing declaration was added

---

### Phase 8: Ledger, baseline, inventories and the full gate [COMPLETED WITH EXCLUSIONS]

**Goal**: Pin everything that landed: docstrings complete, a theorem-index row per result under a
new subsection, a measured C14 axiom baseline, regenerated directory inventories, and the full
gate set green.

**Tasks**:

- [ ] Re-read every file this phase touches immediately before editing. `docs/theorem-index.md` is
      in concurrent sibling task 859's declared `file_scope`: if a foreign commit or foreign
      uncommitted modification is observed there, stop and report after confirming via `git log`
      that the work is not this task's
- [ ] Run `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build` (full project)
      and confirm green before measuring anything
- [ ] Measure the axiom profile of every landed declaration with `#print axioms` — never typed by
      hand — and add the matching `#print axioms <fully-qualified-name>` lines to
      `scripts/check-module-invariants.sh`'s `C14LEAN` heredoc and the measured output lines to
      its `C14_BASELINE` heredoc, in the same order (the two are compared by exact string
      equality)
- [ ] Add a new `### Naming rules and model transformations` subsection to `docs/theorem-index.md`
      with one row per landed result, fully-qualified Lean names, path-only File cells, the
      `Frame class` cell, and `pcq pinned:C14` axiom cells matching the measured baseline. Omit a
      row for anything Phase 7 excluded, and instead record the exclusion wherever the ledger
      records refutations and gaps
- [ ] Update `FormalSystem/Semantics/README.md`'s `HistoryMorphism.lean` row to mention
      `TwoWayBounded`, the lift derivation and the L⁺ invariance
- [ ] Add a `NamingRules.lean` row to `FormalSystem/Metalogic/README.md`, then regenerate the
      directory inventories with `bash scripts/check-module-invariants.sh --emit-inventory` and
      apply what it emits rather than hand-editing any count
- [ ] Run `bash scripts/check-module-invariants.sh` and fix every finding it reports
- [ ] Run the full gate set: `bash .claude/scripts/verify-deploy.sh`
- [ ] Confirm no `sorry`, no new axiom and no vacuous definition anywhere in the landed work

#### Reasoned Exclusions

| Item | Reason | Evidence |
|------|--------|----------|
| The verification criterion "`bash scripts/check-module-invariants.sh` passes" | Not met, for a reason outside this task: the gate's only failing group is C16, whose single finding is on a declaration in a file this task never touched. Every other group passes (53 PASS), including C1, C2, C3, C5, C14 both halves, C15, C23, C33 and INV. Repairing another task's declaration was not in scope, and `lake exe runLinter --update` was deliberately NOT run, since it grandfathers every current finding including that genuine regression. | `FAIL  C16  env_linter batch reports new finding(s) beyond scripts/nolints.json's grandfathered baseline` -> `FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean:2136:1: error: @FormalSystem.Metalogic.Decidability.RaySummary.mem_cellAt_of_shift_of_hasForwardSlack 1 unused argument: argument 23: (hslk : ... ≤ c)`. `git status --short FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean` is empty (unmodified by this task); `git log --oneline -1` on it names earlier work. This task's own C16 finding — an unused `[IsPredArchimedean ↑D]` binder on `TwoWayBounded.exists_histMorphism_of_isZTime` — was fixed by dropping that binder and the redundant `[PredOrder ↑D]` with it: the invariants run before the fix reported `Found 2 errors`, the run after reports `Found 1 error`. |
| A theorem-index row for `aa_expand` | Phase 7 excluded `aa_expand`, so no row was added for it — a row for a declaration that did not land is worse than a missing row, which is this phase's own Scope Hypothesis. The new subsection carries ten rows, one per landed result. | `grep -c 'aa_expand' docs/theorem-index.md` is 0; the subsection's ten `Lean name` cells each resolve to an existing declaration, which C15 asserts for all 337 rows. |

**Three gate collisions resolved, each by the repository's own sanctioned route rather than by
weakening a check**: C5 flagged `FormalSystem.Semantics.HistMorphism` and
`FormalSystem.Semantics.TwoWayBounded` as unresolved module paths (they are namespaces named
after structures, not after modules), so both were added to
`scripts/module-invariants-allowlist.txt`, which exists for exactly that case. C15 requires a
row's declaration to appear in its file under its BARE base name, which forced the five dotted
declarations into explicit `namespace` blocks. That in turn made C23 see a new
outer-shadows-inner pair at `plus_invariance`, which was recorded in `SHADOW_PAIR_ALLOW` with its
reason, on the `Tw`/`Presheaf` precedent already in that set.

**Timing**: 1.5 hours

**Depends on**: 3, 6, 7

**Verification Tier**: full

**Scope Hypothesis**: the index subsection is expected to carry one row per landed Goals
identifier that is a theorem (up to seven rows, fewer if Phase 7 excludes `aa_expand`). Confirm
the exact row set against what actually compiled, not against this estimate — a row for a
declaration that did not land is worse than a missing row.

**Files to modify**:

- `docs/theorem-index.md` - new `### Naming rules and model transformations` subsection
- `scripts/check-module-invariants.sh` - `C14LEAN` and `C14_BASELINE` heredoc additions
- `FormalSystem/Metalogic/README.md` - new module row plus regenerated inventory counts
- `FormalSystem/Semantics/README.md` - updated `HistoryMorphism.lean` row
- `FormalSystem/Metalogic/NamingRules.lean` - docstring completion
- `FormalSystem/Semantics/HistoryMorphism.lean` - docstring completion

**Verification**:

- Full project build green: `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build`
- `bash scripts/check-module-invariants.sh` passes, C2/C14 included
- `bash .claude/scripts/verify-deploy.sh` passes
- Every theorem-index row added resolves to a declaration that exists, and every axiom cell
  matches the measured C14 baseline character for character

---

## Lean Challenge Statements

These fix the intended statement of each committed declaration before implementation. Binder
order, instance binders and namespace openings may be adjusted at implementation time to make the
block elaborate; the quantifier structure and the conclusion of each statement may not be
weakened (see `.claude/rules/plan-compliance.md`, *Statement Fidelity*).

```lean
import FormalSystem.Semantics.HistoryMorphism
import FormalSystem.PlusLanguage.PlusTruth

namespace FormalSystem.Semantics

open FormalSystem.PlusLanguage

/-- A two-way bounded morphism of task frames: the task relation is carried forward, and every
step out of an image state lifts. Under the reflection convention the backward condition is this
same field at a negative duration. -/
structure TwoWayBounded {D : TemporalOrder} {F' F : FrameOver D}
    (f : F'.WorldState → F.WorldState) : Prop where
  forth : ∀ a x b, F'.TaskRel a x b → F.TaskRel (f a) x (f b)
  step : ∀ a x v, F.TaskRel (f a) x v → ∃ b, F'.TaskRel a x b ∧ f b = v

theorem HistMorphism.plus_invariance {D : TemporalOrder} {F' F : FrameOver D}
    (g : HistMorphism F' F) (M : TaskModel F.toTaskFrame) :
    ∀ (φ : PlusFormula) (τ' : WorldHistory F'.toTaskFrame) (t : ↑D),
      PlusTruthAt (g.pullM M) τ' t φ ↔ PlusTruthAt M (g.mapH τ') t φ := sorry

theorem TwoWayBounded.exists_preimage_step {D : TemporalOrder} {F' F : FrameOver D}
    {f : F'.WorldState → F.WorldState} (h : TwoWayBounded f)
    (a : F'.WorldState) (x : ↑D) (v : F.WorldState) (hv : F.TaskRel (f a) x v) :
    ∃ b : F'.WorldState, F'.TaskRel a x b ∧ f b = v := sorry

theorem TwoWayBounded.exists_histMorphism_of_isZTime {D : TemporalOrder} {F' F : FrameOver D}
    [F'.IsRegular] [F.IsRegular] [SuccOrder ↑D] [PredOrder ↑D]
    [IsSuccArchimedean ↑D] [IsPredArchimedean ↑D]
    {f : F'.WorldState → F.WorldState} (h : TwoWayBounded f)
    (hs : Function.Surjective f) :
    ∃ g : HistMorphism F' F, g.toFun = f := sorry

end FormalSystem.Semantics
```

```lean
import FormalSystem.Semantics.Frames.TranslationProduct
import FormalSystem.PlusLanguage.PlusValidity

namespace FormalSystem.Metalogic.NamingRules

open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.PlusLanguage

/-- The atom `q` does not occur in the formula. -/
def Fresh (q : Atom) : PlusFormula → Prop
  | .atom p => p ≠ q
  | .bot => True
  | .imp a b => Fresh q a ∧ Fresh q b
  | .box a => Fresh q a
  | .untl a b => Fresh q a ∧ Fresh q b
  | .snce a b => Fresh q a ∧ Fresh q b
  | .stab a => Fresh q a

theorem plusTruthAt_congr_of_fresh {F : TaskFrame} (M M' : TaskModel F) (q : Atom)
    (hV : ∀ (w : F.WorldState) (p : Atom), p ≠ q → (M.valuation w p ↔ M'.valuation w p)) :
    ∀ φ : PlusFormula, Fresh q φ → ∀ (τ : WorldHistory F) (t : F.Duration),
      PlusTruthAt M τ t φ ↔ PlusTruthAt M' τ t φ := sorry

/-- `q` holds now and at no other time of this history. -/
def nm (q : Atom) : PlusFormula :=
  (PlusFormula.atom q).and ((PlusFormula.atom q).neg.allPast.and
    (PlusFormula.atom q).neg.allFuture)

/-- `q` holds at exactly one time of this history. -/
def once (q : Atom) : PlusFormula := ((nm q).or (nm q).somePast).or (nm q).someFuture

/-- The time at which `q` holds is the same on every history through the current state. -/
def rigid (q : Atom) : PlusFormula :=
  ((PlusFormula.atom q).someFuture.imp (PlusFormula.stab (PlusFormula.atom q).someFuture)).and
    ((PlusFormula.atom q).somePast.imp (PlusFormula.stab (PlusFormula.atom q).somePast))

/-- The clock rule's antecedent: `q` now, and everywhere `q` is a `⊡`-rigid name of one time. -/
def clockAnte (q : Atom) : PlusFormula :=
  (PlusFormula.atom q).and (PlusFormula.box ((once q).and (rigid q)).always)

theorem clock_irr_sound (fc : FormalSystem.ProofSystem.FrameClass) (q : Atom) (φ : PlusFormula)
    (hq : Fresh q φ) (hprem : PlusValidIn fc ((clockAnte q).imp φ)) :
    PlusValidIn fc φ := sorry

theorem irr_sound (fc : FormalSystem.ProofSystem.FrameClass) (q : Atom) (φ : PlusFormula)
    (hq : Fresh q φ)
    (hprem : PlusValidIn fc
      (((PlusFormula.atom q).and (PlusFormula.atom q).neg.allPast).imp φ)) :
    PlusValidIn fc φ := sorry

theorem aa_expand {D : TemporalOrder} (F : FrameOver D) [F.IsRegular]
    [SuccOrder ↑D] [PredOrder ↑D] [IsSuccArchimedean ↑D] [IsPredArchimedean ↑D]
    {Q I : Type} (p : Q → I → Q) (b₀ : Q) (idx : F.WorldState → I)
    (τ : WorldHistory F.toTaskFrame) (t : ↑D) :
    ∃ (F' : FrameOver D) (_ : F'.IsRegular) (g : HistMorphism F' F)
      (st : F'.WorldState → Q) (τ' : WorldHistory F'.toTaskFrame),
      Function.Surjective g.toFun ∧
      (∀ s, g.toFun (τ'.state s) = τ.state s) ∧
      st (τ'.state t) = b₀ ∧
      ∀ ρ' : WorldHistory F'.toTaskFrame, ρ'.state t = τ'.state t → ∀ s, t ≤ s →
        ∀ η' : WorldHistory F'.toTaskFrame, η'.state s = ρ'.state s →
          st (η'.state (Order.succ s)) = p (st (ρ'.state s)) (idx (g.toFun (ρ'.state s))) := sorry

end FormalSystem.Metalogic.NamingRules
```

## Testing & Validation

- [ ] Full project build green: `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build`
- [ ] `lean_verify` on every landed declaration reports no `sorry` and no axiom beyond
      `[propext, Classical.choice, Quot.sound]`
- [ ] No vacuous definition anywhere in the landed work (`def X := True`, `theorem X := trivial`
      and their variants are prohibited and are caught by the zero-debt gate)
- [ ] `bash scripts/check-module-invariants.sh` passes, including C2, C14 and the README
      inventory checks
- [ ] `bash .claude/scripts/verify-deploy.sh` passes
- [ ] Every theorem-index row added resolves to an existing declaration, with a fully-qualified
      name and a path-only File cell
- [ ] Every axiom cell in the new index rows matches the measured C14 baseline character for
      character, and no profile was typed by hand
- [ ] Non-vacuity is machine-checked, not asserted: `TwoWayBounded` has a worked instance,
      `Fresh` has its accept/reject `example`s, and `clockAnte` is exhibited as satisfiable

## Artifacts & Outputs

- `FormalSystem/Semantics/HistoryMorphism.lean` — extended with `TwoWayBounded`,
  `TwoWayBounded.exists_preimage_step`, `exists_preimage_step_neg`,
  `TwoWayBounded.exists_histMorphism_of_isZTime`, `HistMorphism.plus_invariance`,
  `HistMorphism.plusValidOn`, and docstrings
- `FormalSystem/Metalogic/NamingRules.lean` — new module: `Fresh`,
  `plusTruthAt_congr_of_fresh`, `nm`, `once`, `rigid`, `clockAnte`, `clock_irr_sound`,
  `irr_sound`, and `aa_expand` if it ports
- `FormalSystem/Metalogic.lean` — one import line plus the docstring component entry
- `docs/theorem-index.md` — new `### Naming rules and model transformations` subsection
- `scripts/check-module-invariants.sh` — measured C14 baseline additions
- `FormalSystem/Metalogic/README.md`, `FormalSystem/Semantics/README.md` — module rows and
  regenerated inventory counts
- A task summary recording what landed, and — if Phase 7 took the obstruction route — the located
  obstruction in full

## Rollback/Contingency

Each phase commits on its own green sub-steps, so the rollback unit is a phase, not the task.
Three graceful degradations are already built into the phase structure and are preferred to any
revert:

- Phase 3 stalling degrades to landing `TwoWayBounded` plus the step lemmas and marking the phase
  `[BLOCKED]` with the goal state reached.
- Phase 7 is permitted to close as `[COMPLETED WITH EXCLUSIONS]` with a located obstruction, which
  is the dispatch's own stated preference over a stalled task.
- A build error is fixed forward in the source. Uncommitted changes are never discarded to reach a
  passing build.

If a genuine whole-working-tree revert becomes necessary, follow
`context/contracts/recovery.md`'s rollback rung for the exact `git-snapshot.sh` invocation shape,
including its out-of-scope override flag. A bare precautionary checkpoint before risky work is
`bash .claude/scripts/git-snapshot.sh 559 --no-revert`, which is durable without reverting the
working tree — never the default reverting form.
