# Blocker Analysis: Task #92

- **Parent Task**: 92 - implement_bx_until_truth_lemma
- **Generated**: 2026-04-10
- **Blocker**: Phase 0 diagnostic gate of the Burgess-Xu Until-induction plan
  failed on all six probes. Both Gap U5 (BX5 self-accumulation propagation
  along the Until chain) and B-GAP (BX4 connectedness in the backward
  direction) remain unrescued, and all four proposed rescue helpers
  (`bx_earliest_until_witness`, `bx_not_until_backward_pull`,
  `bx_earliest_since_witness`, `bx_not_since_backward_pull`) have no
  derivation from the current BX1-BX12 axiom set.

## Root Cause

The failure mode is **structural**, not tactical. It is the same obstruction
task 89 identified at 90% confidence, that task 90's "Burgess-Xu
Until-induction" recommendation renamed without refuting, and that the
`specs/092.../reports/03_phase0-diagnostic.md` probes have now verified
empirically at Lean goal-state level.

### The structural obstruction

`bx_le := g_content ⊆ (·)` only propagates formulas of the form `G(χ)` from
`w` to `u` when `bx_le w u`. The four Until/Since lemmas each have a
universal-guard clause of the form

```
∀ u : BXPoint, bx_le w u → bx_le u v ∧ ¬bx_le v u → φ ∈ u.formulas
```

(and its Since mirror), requiring that `φ` be propagated to arbitrary MCSes
`u` in the strict `bx_le`-interval `(w, v)`. The only axiom-derived way to
force `φ ∈ u` given `(φ U ψ) ∈ w` is:

1. Lift `(φ U ψ)` to a self-accumulated form `(φ ∧ (φ U ψ)) U ψ` in
   `w.formulas` via BX5. This works.
2. Propagate that form to `u`. This **fails**: the lifted formula is still
   an Until formula, not of shape `G(χ)`, so `g_content(w) ⊆ u.formulas`
   does not transport it.
3. At `u`, invoke BX9 `until_elim` on the propagated formula to derive
   `φ ∨ ψ ∈ u`, then rule out `ψ ∈ u` via an earliness argument to conclude
   `φ ∈ u`. Unreachable because step 2 fails.

### Why each rescue failed

| Rescue | Failure mode | Evidence |
|--------|-------------|----------|
| BX7 two-formula `(φ U ψ) ∧ (⊤ U ψ)` earliest-witness | BX7 is a **formula-level** linearity on Until resolution **inside one MCS**; it does not deliver a **BXPoint-level** minimum selector. "Earliest `v` with `ψ ∈ v`" is a property of an MCS, not a property of a formula. | Probe 2, `03_phase0-diagnostic.md` |
| BX4 `connect_future` forward-push of `¬(φ U ψ)` | Propagates `G(P(¬(φ U ψ)))` to `v`, yielding `P(¬(φ U ψ)) ∈ v`. A backward witness `u' ≤ v` then carries `¬(φ U ψ)`, but **nothing links `u'` to `w`'s future cone** — `bx_le w u'` is exactly the linearity gap task 90 claimed to bypass. BX4's own docstring disavows the Burgess-Xu Until-Since connectedness principle this argument requires. | Probe 3, `Axioms.lean:142-147`, `03_phase0-diagnostic.md` |
| BX4' `connect_past` at `v` | Yields `H(F ψ) ∈ v`. Pulling back to any `u ≤ v` gives `F ψ ∈ u`, but `bx_backward_witness` provides **no locus control**: it cannot be steered into `w`'s forward cone. | Probe 4, `Frame.lean:176` |
| BX11 `temp_linearity` | Formula-level linearity on `F`-witnesses inside one MCS. Plays **no constructive role** in the Burgess-Xu kernel; it does not bridge formula-level linearity to BXPoint-level comparability. | Probe 6 |
| Since mirror via `.symm`/`.dual` rename | The Since guard interval is anchored **between** `v` (past witness) and `w` (current), so the inner `u` is simultaneously future-of-`v` and past-of-`w`. Two different direction principles are mixed in one guard, so Since helpers cannot be mirror renames — they need standalone proofs. | Probe 6, Teammate C Issue 5 |
| Derived Until-persistence lemmas | `lean_local_search "until_persist"` only returned Boneyard/deprecated hits (DovetailedChain) or SuccRelation-based helpers that operate on step-relations, not `bx_le`. | Probe 5 |

### Why the Burgess-Xu approach as published does not apply here

Burgess 1982 and Xu 1988 prove canonical-model completeness for tense logics
of linear time. Their proofs implicitly assume that the canonical
accessibility relation on MCSes **is already a linear order** (because the
axiom set forces it). In the BX refactoring, `bx_le := g_content ⊆` was
deliberately chosen to keep the Box/G/H truth lemmas tractable — but this
definition is a **partial order**, not a linear one, and no axiom in BX1-BX12
forces it to be linear at the MCS level. The Burgess-Xu self-accumulation +
absorption trick is a proof-theoretic surrogate for *fixpoint unfolding in
one MCS*, not a substitute for *linearity of the MCS order*. Task 90's
recommendation smuggled the missing linearity back in as "by construction"
without exhibiting the construction. Task 92's Phase 0 empirically confirmed
that no such construction exists in the current axiom set.

## Proposed New Tasks

Any viable rescue must change at least one of:

1. The axiom set (strengthen BX).
2. The definition of `bx_le` (restructure the canonical order).
3. The model-theoretic target (quasimodel / filtration / Hintikka pivot).

Each of these is a genuine escape hatch, each has different soundness and
cascade-cost profiles, and none requires the others' implementation details
to be researched independently. The three tasks can run in parallel; after
all three complete, `/plan 92` re-runs and synthesizes the cheapest viable
path into a new task 92 plan.

### New Task 1: Research BX13 axiom candidates for Until propagation

- **Effort**: 6-10 hours
- **Language**: logic (logic-research-agent)
- **Rationale**: Investigate whether one or more new sound BX axioms
  ("BX13", "BX14") can close Gap U5 and B-GAP without breaking soundness
  over the intended frame class (general linear orders with reflexive
  Until/Since witnesses). Concrete candidates include: a "G-Until lift"
  `(φ U ψ) → G((φ U ψ) ∨ ψ)` (probably unsound but needs a countermodel);
  a "Until persistence under self-accumulation along future cone"
  `(φ U ψ) → G((φ U ψ) → (φ ∧ (φ U ψ)) U ψ)`; a "backward witness locus
  axiom" linking `P(¬(φ U ψ))` at `v` to `¬(φ U ψ)` at a `w`-reachable `u`.
  For each candidate, verify semantic validity (Kripke countermodel search
  or a proof of soundness over the task frame semantics) and confirm it
  actually closes at least one of the four sorries (probe at
  `Frame.lean:653, 675, 690, 704` via `lean_multi_attempt`). Definition
  of done: a report enumerating 3-6 candidate axioms, each classified
  as (sound + closes sorry), (sound + does not close), or (unsound with
  countermodel), plus a ranked shortlist of the ones worth adopting.
  Scope fence: do NOT modify `Axioms.lean`; this is pure research.
- **Depends on**: None

### New Task 2: Research layered `bx_le` redefinition

- **Effort**: 6-10 hours
- **Language**: logic
- **Rationale**: Task 90 rejected "Option A" (redefining `bx_le` using
  Until-based witness ordering) because a straightforward witness-based
  relation had non-equivalence and non-transitivity flaws. This task
  revisits that decision with a **layered** definition: e.g.,
  `bx_le' w u := g_content(w) ⊆ u.formulas ∧ until_compatible w u`,
  where `until_compatible` is a new predicate that tracks Until-witness
  ordering without breaking transitivity. Research whether such a layered
  definition (a) preserves `box_preserved_along_bx_le` and the Box/G/H
  truth lemmas at `Frame.lean:501-583`, (b) makes Gap U5 / B-GAP
  trivial or closable via existing BX axioms, and (c) is transitive and
  reflexive. Candidates to evaluate: Until-witness subset, finite-prefix
  agreement, interval-linearity closure. Definition of done: a report
  surveying 2-4 layered candidates, each with a decision matrix over
  (transitivity, reflexivity, Box-lemma preservation, Gap U5 closure,
  B-GAP closure), plus a recommendation or a formal rejection with
  cited obstruction. Scope fence: do NOT modify `Frame.lean`; research
  only.
- **Depends on**: None

### New Task 3: Research filtration / quasimodel pivot for Until/Since

- **Effort**: 8-12 hours
- **Language**: logic
- **Rationale**: Task 89 and Teammate B both noted that a **filtration
  of the canonical model** (common in LTL and Coalition Logic completeness
  proofs, e.g., LIPIcs.ITP.2024.28) or a **Hintikka-set quasimodel**
  (standard in tense-logic literature; Burgess 1984, Goldblatt 1992)
  would handle Until/Since truth via finite-subformula-closure reasoning,
  bypassing the `g_content`-propagation obstruction entirely. Teammate B
  estimated a ≥40h rebuild cost if adopted naively, because filtration
  would cascade-break `box_preserved_along_bx_le`, `bx_modal_equiv_of_bx_le`,
  `G_iff_mcs`, `H_iff_mcs`, and the existing truth-lemma infrastructure.
  This task researches (a) whether a **local** filtration at only the
  Until/Since-truth step is possible (keeping the Box/G/H layer intact),
  (b) what the minimum-viable Hintikka-set closure looks like for the
  BX axiom set, (c) whether the filtered/quasimodel target can prove
  the same semantic results task 92 needs (specifically, the Until/Since
  truth lemma used by `bx_completeness`), and (d) a realistic effort
  estimate for the pivot, revising Teammate B's 40-80h figure upward
  or downward based on the cascade audit. Definition of done: a report
  with (i) a filtration-vs-quasimodel comparison, (ii) a cascade-cost
  audit listing every existing theorem that would need to be re-proved
  or re-stated, (iii) a minimum-viable-pivot sketch, and (iv) a go/no-go
  recommendation.
- **Depends on**: None

## Dependency Reasoning

**Tasks 1, 2, and 3 are independent.** They investigate three orthogonal
escape hatches (axiom strengthening, definition restructuring, model-class
pivot). The implementation details of each do not affect how the others
should be researched:

- Task 1's candidate BX13 axioms are evaluated against the **current**
  `bx_le` definition and the **current** canonical-model target. Task 2's
  layered `bx_le` and Task 3's filtration target are irrelevant to
  whether a new axiom is sound and closes a sorry.
- Task 2's layered `bx_le` candidates are evaluated against the **current**
  axiom set and the **current** model target. Whether a new BX13 exists
  or a filtration works does not affect whether a layered definition is
  transitive or preserves Box.
- Task 3's filtration/quasimodel analysis starts from the **current**
  axiom set and the **current** `bx_le`. Changes proposed in Tasks 1 or 2
  would only enrich the pivot's options, not invalidate the cascade audit.

After all three complete, `/research 92` round 03 will have three new
reports. A subsequent `/plan 92` run will synthesize them into a new task
92 plan (replacing `02_burgess-xu-until-plan.md`), choosing whichever
direction has the best (soundness, cascade-cost, effort) profile. No
separate synthesis task is needed because `/plan` is the natural
synthesis step.

## After Completion

Once all three spawned tasks are complete, resume task 92 by running:

```
/research 92            # bring the three new reports into task 92's research set
/plan 92                # synthesize the three options into a revised plan
/implement 92           # execute the chosen option
```

The blocker will be resolved because at least one of the three research
directions must either produce a viable path (in which case task 92's new
plan targets that path) or collectively exhaust all remaining options (in
which case task 92 goes to `[ABANDONED]` with a formal impossibility proof
and the four sorries are reassigned to a larger scope-fence restructuring
task). Either outcome is scientifically correct and honors the zero-debt
policy.

## References

- `specs/092_implement_bx_until_truth_lemma/reports/03_phase0-diagnostic.md`
  — Phase 0 diagnostic with verbatim goal states and failed tactic transcripts
- `specs/092_implement_bx_until_truth_lemma/plans/02_burgess-xu-until-plan.md`
  — the blocked plan with its escalation clause
- `specs/092_implement_bx_until_truth_lemma/reports/02_teammate-c-findings.md`
  — critic teammate who predicted the Phase 0 failure
- `specs/092_implement_bx_until_truth_lemma/reports/02_teammate-b-findings.md`
  — alternatives teammate (rejected paths and prior art)
- `specs/090_research_bx_le_redefinition/reports/03_task92_recommendation.md`
  — task 90's original recommendation (now empirically invalidated)
- `Theories/Bimodal/ProofSystem/Axioms.lean:142-264` — BX4 through BX12 and
  primed duals
- `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean:585-704` — the four
  sorries and surrounding linearity-gap documentation
