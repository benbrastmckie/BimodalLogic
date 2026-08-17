# Implementation Summary: Semantic FMP over ℤ-Time (finite WorldState)

- **Task**: 417 - `semantic_fmp_finite_worldstate_over_z`
- **Plan**: `specs/417_semantic_fmp_finite_worldstate_over_z/plans/03_semantic-fmp-z-time.md`
- **Outcome**: **PARTIAL** — 7 of 13 phases completed; 4 blocked, 2 blocked upstream of those
- **Session**: `sess_1786980263_7f034c`

## Headline

The **ℤ-frame normal form landed in full** and is the durable deliverable: over `D = ℤ` a task
frame is provably determined by its one-step relation, in both the decomposition and the synthesis
direction, and its total-history space is exactly the set of bi-infinite step-paths. On top of it,
`TaskFrame.spherical_of_finite`, a periodicity toolkit, and a computational `IntPresentation` all
landed sorry-free.

The **truth-lemma / semantic-FMP half did not land, and cannot land as planned.** Two independent
blockers were found and machine-checked, neither of which is a difficulty estimate:

1. `FiniteFilteredTaskFrame`'s task relation is a **permissive placeholder**, universal at every
   nonzero duration. The truth lemma Phase 7 was to state is *false* on it.
2. The `check` signature Phase 12 specifies is **not implementable**: satisfiability-at-a-state is
   not compositional over `Formula.imp`, so no formula-structural recursion computes it.

Both are recorded with reproducible Lean evidence under
`specs/417_semantic_fmp_finite_worldstate_over_z/evidence/`.

## Phase status

| Phase | Status | Outcome |
|-------|--------|---------|
| 1 — track paper anchors | COMPLETED | `lem:nesting`, `lem:nonempty` added; record moves 47 → 49 |
| 2 — `spherical_of_finite` | COMPLETED | Additive only, 93 insertions, 0 deletions |
| 3 — ℤ normal form, decomposition | COMPLETED | New module `Semantics/IntNormalForm.lean` |
| 4 — `mem_HF_iff_adjacent` | COMPLETED | `H_F` over ℤ is the bi-infinite step-paths |
| 5 — `ofStep` + witness promotion | COMPLETED | All seven fields discharged; `intBoolFrame` promoted |
| 6 — `box_const` | COMPLETED | `□` is a model constant |
| 7 — truth lemma statement | **BLOCKED** | The lemma is false on the named frame |
| 8 — periodicity toolkit | COMPLETED | New module `FMP/Periodicity.lean` |
| 9 — `untl`/`snce` fulfilment | **BLOCKED** | Upstream of 7; never entered |
| 10 — assemble semantic FMP | **BLOCKED** | Upstream of 7 and 9 |
| 11 — `IntPresentation` | COMPLETED | New module `Decidability/IntPresentation.lean` |
| 12 — `IntPresentation.check` | **BLOCKED** | Signature not implementable |
| 13 — `check_correct` and gates | **BLOCKED** | Upstream of 10 and 12; README bullet done |

## What landed

**`FormalSystem/Semantics/TaskFrame.lean`** (additive: 93 insertions, 0 deletions)
- `sInter_nonempty_of_directed_of_minimal` — the paper's constructive core, **axiom-free**, not
  even `propext`
- `spherical_of_finite` — every relation on a finite carrier is *Spherical*;
  `[propext, Classical.choice, Quot.sound]`, no Zorn route
- Docstrings carry the obstruction note (Lean's `Classical.choice` conflates LEM with AC, so the
  paper's ZF-vs-ZFC "choice-free" claim is not expressible in `#print axioms`; WLEM is derivable
  from `Spherical` at a finite carrier, so a choice-free proof provably does not exist) and the
  prohibition on re-deriving the existing class helpers through it

**`FormalSystem/Semantics/IntNormalForm.lean`** (new)
- `iter`, `iter_add` — the arithmetic core
- `TaskFrame.step`, `taskRel_natCast_iff_iter`, `taskRel_eq_iter` — decomposition, stated uniformly
  so the positive, negative, and zero cases fall out without the statement branching
- `IsStepPath`, `HF.path`, `HFofStepPath`, `mem_HF_iff_adjacent`,
  `isTotal_respects_iff_adjacent` — the history-space characterization
- `ofStepRel`, `ofStep` — synthesis, all seven fields discharged; `ofStep_step` confirms it
  recovers the relation it was given
- `flipFrame` — the two-state cycle
- Module docstring records the succ-Archimedean-to-ℤ binder-fit finding (see below)

**`FormalSystem/Semantics/Truth.lean`** (additive)
- `Truth.box_const`, `Truth.box_time_const`

**`FormalSystem/Examples/TemporalStructures.lean`**
- `intBoolFrame` — the canonical off-zero-universal two-state ℤ witness, promoted out of the test
  file, with its four axiom discharges. Its `spherical` discharge stays `spherical_of_permissive`
  (choice-free) rather than `spherical_of_finite`, and the docstring says why substituting would
  be a pure axiom-profile regression

**`FormalSystem/Metalogic/Decidability/FMP/Periodicity.lean`** (new)
- `exists_path_of_iter` / `iter_of_path`, `exists_repeat_of_card_lt`,
  `exists_repeat_of_isStepPath`, `exists_lt_iter_of_card_le`, `exists_bounded_iter`,
  `exists_bounded_iter_step`

**`FormalSystem/Metalogic/Decidability/IntPresentation.lean`** (new)
- `IntPresentation`, `toTaskFrame`, `toFiniteFrame`, `toModel`, `step_iff`, `isStepPath_iff`,
  `card_worldState`, `flipPresentation`

**Records and documentation**
- `specs/paper-definitions-of-record.md` — `lem:nesting`, `lem:nonempty` tracked; residual gap
  discharged
- `FormalSystem/Semantics/README.md`, `FMP/README.md`, `Decidability/README.md` updated

## The two blockers

### Phase 7 — the filtered frame carries axioms but not dynamics

`RefinedFilteredTaskFrame`'s relation is
`refinedFilteredTaskRel := fun w d u => if d = 0 then w = u else True`. All four of its `def:frame`
discharges go through `TaskFrame.*_of_permissive` — they hold *because* the relation is universal.

Machine-checked (`evidence/phase7-filtered-frame-is-universal.lean`, green via `lake env lean`):

1. the frame's one-step relation over ℤ holds for **all** pairs;
2. **every** `f : ℤ → FilteredWorld φ` is an `IsStepPath`, so by `mem_HF_iff_adjacent` its `H_F` is
   the entire function space;
3. `TaskRel w d u` holds for every `d ≠ 0` and every pair.

So `TruthAt M τ t ψ` varies freely with `τ` while `ψ ∈ (τ.states t _).carrier` is fixed by
`τ.states t`; `someFuture χ` separates them. The plan's premise that "the finite frame already
carries all four axioms — nothing new is constructed here" is true about the axioms and misleading
about everything else. `FMP/`'s zero occurrences of `TruthAt` — which the plan checked and treated
as a green light — is the same fact seen from the other side.

**To unblock**: build a genuine filtered *task relation* on `FilteredWorld φ`, derived from the MCS
structure, and re-discharge all four axioms for it. Note that the permissive route to *Limit* and
*Spherical* is exactly what is lost; `spherical_of_finite`, landed by this task, is the replacement
route for *Spherical*.

### Phase 12 — `check`'s signature is not implementable

`check (P) (w : Fin P.card) (φ) : Bool` recursing on `φ`, with Phase 13 pinning it to
`∃ τ, τ.IsTotal ∧ τ.states 0 _ = w ∧ TruthAt P.toModel τ 0 φ`, cannot exist. Truth of a temporal
formula is a property of a history, not of a state, and satisfiability-over-histories is not
compositional over `→`.

Machine-checked (`evidence/phase12-check-not-compositional.lean`, green): on a two-state
presentation with universal step relation and an atom `p` true only at state `0`,

- `Sat 1 (someFuture p)` holds and `Sat 0 p` holds — the `imp` clause sees the same first argument;
- `¬ Sat 1 ⊥` and `¬ Sat 0 ⊥` — it sees the same second argument;
- yet `Sat 1 (someFuture p → ⊥)` holds while `¬ Sat 0 (p → ⊥)`.

`no_compositional_imp` derives `False` from the existence of any `g` computing the `imp` case. The
universal reading `∀ τ` fails by the mirrored argument.

**To unblock**: index `check` by a **path** rather than a state — the standard ω-automata setup,
where the model-checked object is an ultimately-periodic lasso `(prefix, loop)`. Phase 8's
`exists_bounded_iter` and `exists_lt_iter_of_card_le` are precisely the lemmas that make lassos
sufficient, so that machinery is already in place; what is missing is the lasso datatype, the
recursion over it, and a restated correctness bridge. That is a re-plan of Phases 12–13.

## Plan Deviations

1. **Phase 1, provenance re-pin — skipped.** The paper moved, but per the record's own dirty-pin
   convention a re-pin is warranted only when a drift *correction* is absorbed; none was. The
   unabsorbed drift is recorded instead.
2. **Phase 1, anchor count — altered.** `cor:spherical-finite` was already tracked, so two anchors
   were added rather than three. This is the case the phase's Scope Hypothesis anticipated.
3. **Phase 5, citation target — altered.** The plan asked for the promoted witness's axiom
   discharges to cite `app:dense`/`app:deterministic`. `app:dense` is the *density correspondence
   theorem* and says nothing about frame axioms; **`app:deterministic` does not exist as a label at
   all** (`Deterministic` is a clause of `def:frame-properties`, a frame-class predicate). Cited
   `def:frame`'s four sub-anchors instead, matching every other frame in the tree; the reason is
   recorded in `intBoolFrame`'s docstring.
4. **Phase 8, bounded-witness statement — altered.** "Reachable *along the path* within a bound in
   `card W`" is **false for a fixed path** (counterexample in the module docstring: over `W = Fin 3`
   with `0 → 1`, `1 → 0`, `1 → 2`, the path `0,1,0,1,0,1,2,…` first reaches `2` at distance 6 >
   `card W = 3`). Stated as a reachability bound instead, which is both true and the form a bounded
   search needs.
5. **Phase 11, one field added.** `card_pos : 0 < card` is forced, not stylistic: `TaskFrame`'s
   `nonempty` field is mandatory, `Fin 0` is empty, and `fwd`/`bwd` are vacuous at `card = 0`, so
   the empty presentation would otherwise be legal and unusable.
6. **Per-phase `check-paper-definitions.sh` gate — not met, pre-existing.** The lint was already at
   case (c) before Phase 1 ran, with an identical drift set at every boundary. Following the plan's
   "pause and re-quote" instruction literally would have halted the task at Phase 1 with nothing
   delivered, in order to re-quote 19 blocks this task never cites. The drifted set was instead
   enumerated and confirmed disjoint from every anchor this task transcribes.
7. **Phase 13, retirement-note bullet — skipped.** It asked to record which part of the open
   obligation this task discharges. **None of it was discharged**, so the note was left unedited
   rather than amended with a false claim. Not overclaiming was that bullet's own constraint.

## Incidental findings worth keeping

- **The succ-Archimedean-to-ℤ transfer needs the *additive* iso, not the order iso.**
  `orderIsoIntOfLinearSuccPredArch` fits `ValidDiscrete`'s binder bundle verbatim but yields only
  `D ≃o ℤ`. `LinearOrderedAddCommGroup.int_orderAddMonoidIso_of_isLeast_pos` yields `D ≃+o ℤ` —
  what a duration transfer actually needs, since durations add — but does **not** fit the bundle:
  `Archimedean D` does not synthesize from `[IsSuccArchimedean D] [IsPredArchimedean D]`, and an
  `IsLeast {y | 0 < y} x` witness is additionally required. Both fits machine-checked. Recorded in
  `IntNormalForm.lean`'s module docstring.
- **`cor:tm-decidability` no longer resolves in the live paper.** It is one of two dangling recorded
  anchors (with `def:BL-model`). Phase 10's docstring bullet requires citing it, so any dispatch
  unblocking that phase must re-resolve the anchor first — the pinned text is stale, not merely
  drifted.

## Gate results

`lake build` green (2457 jobs). Live `sorry` count **exactly 1**
(`Metalogic/WeakCanonical/Transfer.lean`, invariant C3), unchanged from task start. Flagship axiom
sets unchanged. `check-task-references.sh` clean. No file under `/home/benjamin/Philosophy/Papers/`
modified.

Pre-existing failures, unchanged from the baseline measured before the first phase: `lake build
BimodalTest` (`#guard_msgs` mismatches in `BoxSpreadProbe.lean`, `RegionGateProbe.lean`,
`TableauConformance.lean` — none touched here; `TaskFrameTest.lean`, which was touched, builds
green), C6, C9, and `check-paper-definitions.sh` case (c).

## Recommended follow-ups

1. **Build a real filtered task relation on `FilteredWorld φ`** and re-discharge the four axioms
   for it. This is the prerequisite for any truth-connected FMP, and it is the whole of the Phase 7
   blocker.
2. **Re-plan `check` around a lasso presentation.** Phase 8's bounded-reachability machinery is
   already in place and is what makes lassos sufficient.
3. **Run a paper-reconciliation pass** over the 19 drifted anchors and the two dangling ones
   (`def:BL-model`, `cor:tm-decidability`).
4. Consider landing the `wlem_of_spherical` regression test that task 440's pass recommends, now
   that `spherical_of_finite` exists and its axiom profile is worth guarding.
