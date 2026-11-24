# Implementation Plan: Task #975

- **Task**: 975 - Theorem library: fragment conservativity (milestone M22, lane metatheory)
- **Status**: [IMPLEMENTING]
- **Effort**: 17 hours
- **Dependencies**: 971 (`theorem_library_layout_and_registry`, completed) for the generated table and the check on entries; none for the theorems
- **Research Inputs**: specs/975_theorem_library_fragment_conservativity/reports/01_fragment-conservativity-edges.md
- **Artifacts**: plans/01_fragment-conservativity-edges.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Every edge of the conservativity table is settled in one of the three ways the task allows. The
temporal edge at `.Base` is refuted (the scratch proof is landed). The edges out of `Boolean`,
the edge from the `□` cell into TM at all four classes, and the edge from the `□` cell into the
`□, ⊡` cell are proved, by one parametric translation theorem over a `Prop`-valued cell calculus
in `FormalSystem/Metalogic/Conservativity/Fragments/`, with the registered `within` statements
derived from it in `BimodalLib`. The temporal edges at `.Dense`, `.ZTime` and `.RTime`, and a
repaired `.Base` edge, stay registered conjectures with a named obstruction. The status table and
the listing of entries whose proof leaves their statement cell are rendered by `library_index`
from kernel-checked terms. Nine phases, run in sequence.

### Research Integration

From `reports/01_fragment-conservativity-edges.md`:

- **Refutation** (rec. 1): `¬ ConservativeEdge { temporal := true } .Base`, witness NF
  (`X⊤ → G X⊤`, `DerivedAxioms.discretePropagateFwd`) on `ℤ ⊕ₗ ℚ`. Compiled in
  `scratch/refute_temporal_base.lean`; it works directly over `DerivationTree` and `within`, so it
  lands in `BimodalLib` with no dependence on the cell calculus (Phase 1).
- **Translation method** (rec. 2, 3): a map `tr` commuting with `imp` and `bot`, with (1) every
  admissible axiom's translation derivable in the cell, (2) closure under the rules, (3) `tr`
  the identity on the cell, gives the edge by one induction on the derivation. The collapse
  translation uses the dense reading (`untl g e ↦ g ∧ e`) at `.Base`, `.Dense`, `.RTime` and the
  discrete reading (`untl g e ↦ e`) at `.ZTime`. `scratch/collapse_translation_check.lean` proves
  the translated axioms are S5 validities; it does not prove them derivable in the cell.
- **Propositional completeness inside a cell** (rec. 3) is the single unbuilt lemma every proved
  edge rests on: Kalmár at `Prop` level with non-Boolean subformulas as the variables, over a
  calculus whose deduction theorem is a plain induction. Not through `deductionTheorem`.
- **Placement** (rec. 4): `within` and `Profile` are in `BimodalLib`, which `FormalSystem` cannot
  import, and check C14 pins only declarations reachable from `import FormalSystem` (confirmed at
  planning: the `C14LEAN` source in `scripts/check-module-invariants.sh` imports `FormalSystem`
  alone). So the indexed theorems are stated in `FormalSystem` over an abstract sublanguage, and
  the `within` forms are corollaries in `BimodalLib`.
- **Strengthening** (rec. 5): the Boolean edges are proved as `∀ fc, ConservativeEdge {} fc`.
- **Split** (rec. 6, 8): the always-translation edges are not attempted; no S5 or Burgess-Xu
  completeness inside a cell is attempted.
- **Decidability of `within`** (rec. 7): via a computed proof profile (Phase 6), used by the
  listing in Phase 8.

### Premise Re-Validation

The dispatch flagged the task description for carried figures. Checked against the report and
the live tree at planning time:

| Claim in the description | Result |
|---|---|
| L into L⁺ is proved at all four classes (`plusDerivable_ofFormula_iff`) | Confirmed: row in `docs/theorem-index.md`, pinned in the C14 baseline |
| S5 completeness for the `□`-fragment is "not stated in the tree"; needed | Confirmed absent; **not needed** under the translation method |
| Completeness of the temporal schemata alone per class is "not stated in the tree"; needed | Confirmed absent; **not needed**, and the `.Base` edge it was to prove is false |
| The `□` into `□, ⊡` edge follows "from the others or directly" | Corrected: it needs only the modal edge and `plusDerivable_ofFormula_iff`, not the temporal edge |
| "every edge is proved, refuted or recorded as a conjecture" is reachable | Confirmed, with one refuted, four groups proved, four conjectures |
| `theorem_library_layout_and_registry` is a hard dependency for the table | Confirmed completed (task 971) |
| "Nothing in BimodalLib contains `sorry`, a new `axiom` or `native_decide`" | Standing constraint; C3 checks `sorry` across `BimodalLib/` |

Six candidate statements over the existing vocabulary were type-checked at planning time
(`lake env lean` on a scratch file importing `BimodalLib.Conservativity`); they are the Lean
Challenge Statements below.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

Milestone M22 in `records/proof-mode.md` ("Conservativity along every edge"), lane Metatheory.
No `roadmap_path` was dispatched and `roadmap_flag` is unset, so no roadmap phases are added.

## Goals & Non-Goals

**Goals**:
- `conservativeEdge_boolean` -- the Boolean cell is conserved by TM at every frame class.
- `derivableIn_boolean_of_box` -- the registered form of the edge from Boolean into ModalBoolean.
- `derivableIn_boolean_of_temporal` -- the registered form of the edge from Boolean into TemporalBoolean.
- `conservativeEdge_box` -- the cell with the box operator is conserved by TM at every frame class.
- `derivableIn_box_of_derivableInP` -- the cell with the box operator is conserved by the cell with both modal operators.
- `not_conservativeEdge_temporal_base` -- the temporal edge at the base class is refuted.

**Non-Goals**:
- The temporal edges at .Dense, .ZTime, .RTime and the repaired .Base edge (the always
  translation). They remain conjectures and are proposed as a record of their own.
- S5 completeness or Burgess-Xu completeness inside a cell.
- The edge from L⁻ into L.
- Lowering any existing reference proof into its statement cell.
- Any change to Formula, DerivationTree, Axiom or the existing deductionTheorem.

### Unpinned Deliverables

Deliverables that are not pinned statements, because they are stated over definitions this plan
introduces (listed here without identifiers so the Goals set equals the Challenge set):

1. The cell calculus over an abstract sublanguage, its deduction theorem, propositional
   completeness inside a sublanguage, and the parametric translation theorem, under
   `FormalSystem/Metalogic/Conservativity/Fragments/`.
2. The two indexed FormalSystem theorems (Boolean and modal edges at every class), each with a
   `docs/theorem-index.md` row and a C14 baseline line.
3. An edge registry in `BimodalLib` whose rows carry a proof, a refutation or a named
   obstruction, and a status table in `BimodalLib/INDEX.md` rendered from it.
4. A computed proof profile per registered theorem, a listing of the entries whose proof leaves
   their statement cell, and a check that fails when a listed entry has no recorded reason.
5. Conjecture statuses and notes updated; the repaired `.Base` edge registered as a conjecture.
6. `docs/` revised to describe what exists; the implemented part cut from `records/`.

## Decisions

- **Method.** The edges are proved by a syntactic translation and an induction on derivations,
  not by soundness, a semantic bridge and completeness of the smaller logic as the task
  description and M22's done-when clause name. Reason (research): the three-step method needs a
  completeness theorem that returns a derivation inside the cell, which no construction in the
  tree tracks, and for a modal or temporal base it is a rerun of a canonical-model development.
  The translation is the bridge read on formulas; the argument is still stated once in
  parametric form and instantiated per edge. Phase 9 rewords the two records accordingly.
- **Fragment proof system.** A predicate on TM derivations (`within`), as registered. The
  `Prop`-valued calculus is an equivalent characterization used for the proofs.
- **Where the theorems live.** Parametric and indexed theorems in `FormalSystem`, over an
  abstract sublanguage; `within` forms in `BimodalLib`. Forced by the one-way import and by C14.
- **Status table.** A small edge registry, not the conjecture listing filtered to edges. A row's
  verdict is a dependent value: `proved` carries a proof of the row's statement, `refuted` a
  proof of its negation, `open` an obstruction string. The index prints the constructor, so a
  row reads "proved" only when the kernel has checked a proof. The L into L⁺ edge, which is no
  conjecture, gets a row the same way. Conjecture constants are kept as the link from question
  to answer, with status `derived` or `refuted` and a note naming the theorem, as the
  `ConjectureStatus` docstrings prescribe.
- **Proof profile by evaluation.** The proof profile of a registered derivation is computed by
  running a `Profile`-valued function on the derivation term inside the index command. It is a
  report, like the rest of the index; no theorem depends on it and no `native_decide` is used.
  Contingency in Phase 8 if evaluation is not available for some rows.
- **Split of the temporal edges.** Recorded in `records/` and in the implementation summary as a
  proposed record; this plan creates no task.
- **Sequencing.** Every phase that adds Lean lines under `FormalSystem/` regenerates the same
  generated files (`FormalSystem.lean`, `typst/generated/status.typ`, the inventory blocks), and
  the `BimodalLib` phases share `BimodalLib.lean` and `BimodalLib/INDEX.md`. The phases are
  therefore a single chain, one per wave.

## Lean Challenge Statements

```lean
import BimodalLib.Conservativity

namespace BimodalLib

open FormalSystem.Syntax FormalSystem.ProofSystem FormalSystem.PlusLanguage

theorem conservativeEdge_boolean (fc : FrameClass) : ConservativeEdge {} fc := sorry

theorem derivableIn_boolean_of_box (fc : FrameClass) (φ : Formula) (hφ : profileF φ ≤ {})
    (h : DerivableIn { box := true } fc φ) : DerivableIn {} fc φ := sorry

theorem derivableIn_boolean_of_temporal (fc : FrameClass) (φ : Formula) (hφ : profileF φ ≤ {})
    (h : DerivableIn { temporal := true } fc φ) : DerivableIn {} fc φ := sorry

theorem conservativeEdge_box (fc : FrameClass) : ConservativeEdge { box := true } fc := sorry

theorem derivableIn_box_of_derivableInP (fc : FrameClass) (φ : Formula)
    (hφ : profileF φ ≤ { box := true })
    (h : DerivableInP { box := true, stab := true } fc (ofFormula φ)) :
    DerivableIn { box := true } fc φ := sorry

theorem not_conservativeEdge_temporal_base :
    ¬ ConservativeEdge { temporal := true } FrameClass.Base := sorry

end BimodalLib
```

In `derivableIn_boolean_of_box` and `derivableIn_boolean_of_temporal` the hypothesis `h` is used
only to obtain a TM derivation of `φ`; if the batch linter reports `unusedArguments` on either,
the remedy is a hand-inserted row in `scripts/nolints.json` next to an existing row of the same
shape, never `lake exe runLinter --update`.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Propositional completeness inside a sublanguage stalls (Phase 3) | H | M | Decision gate in Phase 3: derive the translated axioms by hand in Phase 5 instead (research counts about fifteen), and leave the Kalmár file out |
| The translated axioms are S5-valid (compiled) but a derivation inside the cell is harder than a tautology plus necessitation and K for MF and NB | M | L | Phase 5 handles MF and NB as two named lemmas before the case split; the modal cell has `modal_k_dist` and necessitation |
| A phase commit is refused by `.githooks/pre-commit` because `typst/generated/status.typ` drifted | M | H | Every phase that changes a `.lean` file under `FormalSystem/` runs `scripts/typst-sync-check.sh --fix` and stages the file in that phase |
| Drift in `status.typ` or the inventory blocks caused by another writer's uncommitted `.lean` files (the working tree was dirty at dispatch) | M | M | Attribute drift by `git status` before `--fix`; stage only this task's files; record a foreign drift as an issue, do not absorb it |
| `--wfail`: any linter warning fails CI (`show` used for defeq, `unusedVariables`, `longFile`) | M | M | Build with `--wfail` in every phase; use named `rfl` lemmas in place of `show`; keep each new file under 1500 lines |
| C26 rejects a `def`/`abbrev` with a non-trailing underscore when the scratch file is promoted (`Z_Q`) | L | H | Phase 1 renames on promotion (`Z_Q` to `ZQ`); theorems are exempt |
| C15 requires a `Paper:` line in the docstring of each indexed declaration; C14 and the index rows must agree | M | M | `Paper: —` lines written when the theorems are declared (Phase 5); rows and both C14 heredocs edited together in Phase 9 |
| Evaluating the proof profile fails for some rows (a `noncomputable` derivation, or a timeout) | M | M | Phase 8 contingency: such a row is listed as "proof profile not computed" and requires a recorded reason like any other listed row |
| More temporal entries than NF, NA, NP and their consequences have a proof that uses `□` | L | M | Phase 8 measures the list before any reason is written; reasons are per cell and class where the cause is shared |
| Task 977 (blocked) declares overlapping scope: `FormalSystem.lean`, `README.md`, `FormalSystem/Metalogic/README.md`, `FormalSystem/Metalogic/Conservativity/README.md`, `typst/generated/status.typ` | L | L | All overlap is generated surfaces or a README; regenerate rather than hand-merge |
| The repaired `.Base` conjecture is stated in a form that is not the intended logic | M | M | Phase 7 states it in existing vocabulary and records in its note exactly which reading was taken; it is a conjecture, so nothing rests on it |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |
| 6 | 6 | 5 |
| 7 | 7 | 6 |
| 8 | 8 | 7 |
| 9 | 9 | 8 |

Phases within the same wave can execute in parallel. Here each wave holds one phase; see the
Sequencing decision.

### Phase 1: Land the refutation of the temporal edge at the base class [COMPLETED]

**Goal**: `not_conservativeEdge_temporal_base` in `BimodalLib`, with the order semantics, cell
soundness and the countermodel it rests on.

**Tasks**:
- [x] Create `BimodalLib/Conservativity/TemporalBase.lean` from
  `specs/975_theorem_library_fragment_conservativity/scratch/refute_temporal_base.lean`. The
  promotion is not verbatim: move from `namespace Scratch` to `BimodalLib`; rename the `Z_Q`
  abbreviation to `ZQ` (C26); rename the final theorem to `not_conservativeEdge_temporal_base`;
  replace any `show` used for a definitional equality by a named `rfl` lemma; replace
  `import Mathlib.Tactic` by the specific imports needed if the build accepts it.
- [x] Add the copyright header and a module docstring stating: what `LTruth` is, that `□` is read
  as the identity and why that is harmless inside the cell, the witness NF and where TM derives
  it, and that the temporal cell at `.Base` is sound for every serial linear order while TM at
  `.Base` is not.
- [x] Add a docstring to every declaration.
- [x] Add the import to `BimodalLib.lean`.
- [x] `lake build BimodalLib --wfail`.
- [x] Confirm `#print axioms BimodalLib.not_conservativeEdge_temporal_base` gives
  `propext, Classical.choice, Quot.sound` (run from a scratch file under the task directory, not
  left in the module).
- [x] Confirm the module contains no `sorry`, `axiom` or `native_decide`.

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: local

**Tier Justification**: `lake build BimodalLib --wfail` covers the edit, a new leaf module imported only by the library root `BimodalLib.lean`.

**Files to modify**:
- `BimodalLib/Conservativity/TemporalBase.lean` - new: order semantics, cell soundness, countermodel, refutation
- `BimodalLib.lean` - import the new module

**Verification**:
- `lake build BimodalLib --wfail` exits 0.
- The axiom set of `BimodalLib.not_conservativeEdge_temporal_base` is exactly `propext, Classical.choice, Quot.sound`.
- `grep -nE '\bsorry\b|native_decide|^axiom ' BimodalLib/Conservativity/TemporalBase.lean` prints nothing.
- `bash scripts/check-copyright-headers.sh --strict BimodalLib` passes for the new file.

---

### Phase 2: The cell calculus over an abstract sublanguage [COMPLETED]

**Goal**: A `Prop`-valued derivability relation restricted to a sublanguage, with its basic
lemmas and a deduction theorem by plain induction, in `FormalSystem`.

**Tasks**:
- [x] Create `FormalSystem/Metalogic/Conservativity/Fragments/Calculus.lean`. Before defining a
  sublanguage predicate, check for an existing one to reuse
  (`FormalSystem/Metalogic/Decidability/Propositional/Decidable.lean`,
  `.../Verified/Termination/MintBound/BoxFree.lean`).
- [x] Define the closure conditions on a sublanguage `L : Formula → Prop`: contains `bot`; `imp`
  is in `L` exactly when both parts are; invariant under `reflectTime`. State them as a structure
  or class so the theorems take one hypothesis.
- [x] Define the calculus as an inductive `Prop` indexed by `L`, a frame class, a context and a
  formula, on the pattern of `DerivationTree`, with the side condition that every derived formula
  is in `L` and with the necessitation rules and TR restricted to the empty context. Name
  `def`s and the inductive in lowerCamelCase or UpperCamelCase with no non-trailing underscore.
- [x] Prove: the conclusion is in `L`; monotonicity in `L`; weakening of contexts; a cell
  derivation yields `Nonempty (DerivationTree fc Γ φ)`.
- [x] Prove the deduction theorem by induction on the derivation (no well-founded recursion).
- [x] Create `FormalSystem/Metalogic/Conservativity/Fragments.lean` (umbrella, imports
  `Calculus`) and `FormalSystem/Metalogic/Conservativity/Fragments/README.md`.
- [x] Add `import FormalSystem.Metalogic.Conservativity.Fragments` to
  `FormalSystem/Metalogic/Conservativity.lean` (import line only; its docstring is revised in
  Phase 9).
- [x] Regenerate: `lake exe mk_all --lib FormalSystem`; `lake build`;
  `bash scripts/typst-sync-check.sh --fix`; `bash scripts/check-module-invariants.sh --emit-inventory`.
  Stage the regenerated files with this phase.
- [x] If the new upward-import check fires (`scripts/check-metalogic-cycles.sh`), stop and record
  it: no import in this plan is expected to be upward (`Metalogic` is layer 3, `Theorems` layer 2,
  `ProofSystem` below).

**Timing**: 2 hours

**Depends on**: 1

**Verification Tier**: local

**Tier Justification**: `lake build FormalSystem.Metalogic.Conservativity.Fragments --wfail` covers the edit, new modules whose only dependent is the `Conservativity.lean` umbrella, which is built by the same `lake build`.

**Scope Hypothesis**: `--emit-inventory` is expected to rewrite the inventory blocks of `README.md`, `FormalSystem/Metalogic/README.md` and `FormalSystem/Metalogic/Conservativity/README.md` only; confirm with `git status --short` after the run and stage exactly the files it changed that are attributable to this phase's new modules.

**Files to modify**:
- `FormalSystem/Metalogic/Conservativity/Fragments/Calculus.lean` - new: sublanguage conditions, cell calculus, deduction theorem
- `FormalSystem/Metalogic/Conservativity/Fragments.lean` - new umbrella
- `FormalSystem/Metalogic/Conservativity/Fragments/README.md` - new
- `FormalSystem/Metalogic/Conservativity.lean` - import line
- `FormalSystem.lean` - regenerated by `mk_all`
- `typst/generated/status.typ` - regenerated line and file counts
- `README.md` - regenerated inventory block
- `FormalSystem/Metalogic/README.md` - regenerated inventory block
- `FormalSystem/Metalogic/Conservativity/README.md` - regenerated inventory block

**Verification**:
- `lake build FormalSystem.Metalogic.Conservativity.Fragments --wfail` exits 0.
- `bash scripts/typst-sync-check.sh --counts-only` exits 0 before the commit.
- `bash scripts/check-module-invariants.sh --emit-inventory --check` exits 0.
- `bash scripts/check-metalogic-cycles.sh` reports no new upward edge.
- The new files contain no `sorry`, `axiom` or `native_decide`.

---

### Phase 3: Propositional completeness inside a sublanguage [NOT STARTED]

**Goal**: Every propositional tautology over formulas of `L`, with the non-Boolean subformulas
as variables, is derivable in the cell calculus of `L`.

**Tasks**:
- [ ] Create `FormalSystem/Metalogic/Conservativity/Fragments/PropComplete.lean`.
- [ ] Define the valuation of a formula under an assignment of truth values to its non-Boolean
  subformulas (atoms, `box`, `untl`, `snce` formulas), and "tautology" as true under every such
  assignment.
- [ ] Port the construction of
  `FormalSystem/Metalogic/Decidability/Propositional/Kalmar.lean` to the cell calculus: the
  signed-literal context, the Kalmár lemma by induction on the formula, elimination of one
  variable at a time using the Phase 2 deduction theorem. Derive the propositional combinators
  needed inside the calculus; do not transport existing `DerivationTree` combinators.
- [ ] State the main theorem with `L φ` as hypothesis and conclusion in the calculus from the
  empty context.
- [ ] Add the import to `Fragments.lean`; regenerate `FormalSystem.lean`, `status.typ` and the
  inventory blocks as in Phase 2.
- [ ] **Decision gate.** If the main theorem is not proved within the phase's budget plus one
  hour: commit what is green, record the obstruction with `issue-record.sh`, mark the phase
  `[PARTIAL]`, and proceed to Phase 4. Phase 5 then discharges its obligations by hand-derived
  lemmas per translated axiom shape instead of by this theorem.

**Timing**: 2 hours

**Depends on**: 2

**Verification Tier**: local

**Tier Justification**: `lake build FormalSystem.Metalogic.Conservativity.Fragments --wfail` covers the edit, one new module with no dependent outside the `Fragments` umbrella.

**Scope Hypothesis**: Research estimates about 250 lines for this file by analogy with `Kalmar.lean` (298 lines); the estimate is unverified. Confirm by the build; a file approaching 1500 lines is split, not baselined.

**Files to modify**:
- `FormalSystem/Metalogic/Conservativity/Fragments/PropComplete.lean` - new
- `FormalSystem/Metalogic/Conservativity/Fragments.lean` - import
- `FormalSystem.lean` - regenerated
- `typst/generated/status.typ` - regenerated
- `README.md` - regenerated inventory block
- `FormalSystem/Metalogic/README.md` - regenerated inventory block
- `FormalSystem/Metalogic/Conservativity/README.md` - regenerated inventory block

**Verification**:
- `lake build FormalSystem.Metalogic.Conservativity.Fragments --wfail` exits 0.
- The main theorem's axiom set is within `propext, Classical.choice, Quot.sound`.
- `bash scripts/typst-sync-check.sh --counts-only` and `bash scripts/check-module-invariants.sh --emit-inventory --check` exit 0.
- Or, on the decision gate: the obstruction is recorded and the green part builds.

---

### Phase 4: The parametric translation theorem and the collapse translation [NOT STARTED]

**Goal**: The argument stated once: a translation satisfying three hypotheses gives
conservativity of a sublanguage; and the collapse translation with its structural lemmas.

**Tasks**:
- [ ] Create `FormalSystem/Metalogic/Conservativity/Fragments/Translation.lean`. State the
  theorem for `tr : Formula → Formula` commuting with `imp` and `bot`, a sublanguage `L` and a
  class `fc`, under: (1) for every axiom instance admissible at `fc`, its translation is cell
  derivable; (2) cell derivability of `tr φ` gives that of `tr (□φ)`, of `tr (Gφ)` and of
  `tr φ.reflectTime`; (3) `tr φ = φ` when `L φ`. Conclusion: a formula of `L` with a closed TM
  derivation at `fc` is cell derivable. Proof by induction on the derivation, generalized over
  the context as far as the closed case needs.
- [ ] Create `FormalSystem/Metalogic/Conservativity/Fragments/Collapse.lean`. Define the collapse
  translation with the two flags of the scratch file (dense or discrete reading; `□` kept or
  erased), port `tr_reflect` and the two fixed-point lemmas from
  `scratch/collapse_translation_check.lean`, restated over the Phase 2 sublanguage predicates in
  place of `profileF`, and prove hypothesis (2) for both targets (it reduces to necessitation in
  the modal cell and to the identity where the operator is erased).
- [ ] Do not port `STruth` or `tr_axiom_valid`; they were evidence that the route is sound and
  are not used by the proof.
- [ ] Add both imports to `Fragments.lean`; regenerate as in Phase 2.

**Timing**: 1.5 hours

**Depends on**: 3

**Verification Tier**: local

**Tier Justification**: `lake build FormalSystem.Metalogic.Conservativity.Fragments --wfail` covers the edit, two new modules with no dependent outside the `Fragments` umbrella.

**Files to modify**:
- `FormalSystem/Metalogic/Conservativity/Fragments/Translation.lean` - new: parametric theorem
- `FormalSystem/Metalogic/Conservativity/Fragments/Collapse.lean` - new: collapse translation and lemmas
- `FormalSystem/Metalogic/Conservativity/Fragments.lean` - imports
- `FormalSystem.lean` - regenerated
- `typst/generated/status.typ` - regenerated
- `README.md` - regenerated inventory block
- `FormalSystem/Metalogic/README.md` - regenerated inventory block
- `FormalSystem/Metalogic/Conservativity/README.md` - regenerated inventory block

**Verification**:
- `lake build FormalSystem.Metalogic.Conservativity.Fragments --wfail` exits 0.
- The parametric theorem mentions no specific translation, cell or frame class in its statement.
- `bash scripts/typst-sync-check.sh --counts-only` and `bash scripts/check-module-invariants.sh --emit-inventory --check` exit 0.

---

### Phase 5: The Boolean and modal edges in FormalSystem [NOT STARTED]

**Goal**: Two theorems, each at every frame class: the Boolean sublanguage and the `□`
sublanguage are conserved by TM. These are the declarations `docs/theorem-index.md` will cite.

**Tasks**:
- [ ] Create `FormalSystem/Metalogic/Conservativity/Fragments/Edges.lean`.
- [ ] Prove hypothesis (1) of the translation theorem for the collapse translation: for each
  axiom constructor admissible at `fc`, under the reading for `fc` (dense at `.Base`, `.Dense`,
  `.RTime`; discrete at `.ZTime`), the translation is cell derivable. `modal_t`,
  `modal_5_collapse`, `modal_k_dist` translate to instances of themselves when `□` is kept. MF
  and NB get one named lemma each (a tautology, then necessitation and K when `□` is kept; a
  tautology when erased). Every other constructor is a tautology by Phase 3, or by a hand
  derivation if Phase 3 took its decision gate.
- [ ] Instantiate the translation theorem twice per reading and assemble the two class-generic
  theorems by cases on `fc`.
- [ ] Give each of the two theorems, and the parametric theorem of Phase 4, a docstring with a
  `Paper: —` line stating that the result is the formalization's own (C15).
- [ ] Add the import to `Fragments.lean`; regenerate as in Phase 2.

**Timing**: 2 hours

**Depends on**: 4

**Verification Tier**: local

**Tier Justification**: `lake build FormalSystem.Metalogic.Conservativity.Fragments --wfail` covers the edit, one new module with no dependent outside the `Fragments` umbrella until Phase 6.

**Scope Hypothesis**: Research counts seventeen axiom constructors, of which two (MF, NB) lie in no proper cell and the class-specific ones are `prior_UZ`, `dense_indicator`, `prior_U_gap`, `sep`. Confirm the constructor list by a `cases` on `Axiom` in the proof; the case split, not this count, is the authority.

**Files to modify**:
- `FormalSystem/Metalogic/Conservativity/Fragments/Edges.lean` - new: the two edge theorems
- `FormalSystem/Metalogic/Conservativity/Fragments.lean` - import
- `FormalSystem.lean` - regenerated
- `typst/generated/status.typ` - regenerated
- `README.md` - regenerated inventory block
- `FormalSystem/Metalogic/README.md` - regenerated inventory block
- `FormalSystem/Metalogic/Conservativity/README.md` - regenerated inventory block

**Verification**:
- `lake build FormalSystem.Metalogic.Conservativity.Fragments --wfail` exits 0.
- Both edge theorems are stated for an arbitrary `fc : FrameClass` and have axiom set within `propext, Classical.choice, Quot.sound`.
- No `sorry`, `axiom` or `native_decide` under `FormalSystem/Metalogic/Conservativity/Fragments/`.
- `bash scripts/typst-sync-check.sh --counts-only` and `bash scripts/check-module-invariants.sh --emit-inventory --check` exit 0.

---

### Phase 6: The `within` forms in BimodalLib [NOT STARTED]

**Goal**: The five positive Challenge statements, derived from the Phase 5 theorems through the
equivalence of `DerivableIn` with the cell calculus; and a computed proof profile that decides
`within`.

**Tasks**:
- [ ] In `BimodalLib/Fragment.lean`: simp lemmas for `Profile` (`join_le`, the profile of each
  formula constructor, reflexivity and transitivity of `≤`), and the invariance of `profileF`
  under `reflectTime` if not present.
- [ ] In `BimodalLib/Conservativity.lean`: `proofProfile`, the join of the profiles of every
  formula derived in a derivation; `within c d ↔ proofProfile d ≤ c`; a `Decidable (within c d)`
  instance from it. Revise the module docstring sentence "Nothing here is proved about these
  predicates" to state what the module now holds.
- [ ] Create `BimodalLib/Conservativity/Proved.lean`: the sublanguage `fun ψ => profileF ψ ≤ c`
  satisfies the Phase 2 closure conditions; `DerivableIn c fc φ` iff `φ` is cell derivable from
  the empty context at that sublanguage (both directions, by induction on the derivation and on
  the cell derivation).
- [ ] Prove `conservativeEdge_boolean` and `conservativeEdge_box` from the Phase 5 theorems.
- [ ] Prove `derivableIn_boolean_of_box` and `derivableIn_boolean_of_temporal` by forgetting
  `within` and applying `conservativeEdge_boolean`.
- [ ] Prove `derivableIn_box_of_derivableInP` by forgetting `withinP`, applying
  `plusDerivable_ofFormula_iff`, then `conservativeEdge_box`.
- [ ] Signatures must match the Lean Challenge Statements exactly.
- [ ] Add the import to `BimodalLib.lean`. `lake build BimodalLib BimodalLibTest --wfail`.
- [ ] `bash scripts/library-index.sh --check` (no row or conjecture changes in this phase, so the
  index is expected unchanged; if it differs, regenerate and stage `BimodalLib/INDEX.md`).

**Timing**: 2 hours

**Depends on**: 5

**Verification Tier**: interface

**Tier Justification**: `lake build BimodalLib BimodalLibTest --wfail` covers the edit, new simp lemmas and an instance in `Fragment.lean` and `Conservativity.lean` whose dependents are all inside those two libraries.

**Files to modify**:
- `BimodalLib/Fragment.lean` - `Profile` simp lemmas
- `BimodalLib/Conservativity.lean` - `proofProfile`, the `within` characterization, `Decidable` instance, docstring
- `BimodalLib/Conservativity/Proved.lean` - new: bridge to the cell calculus and the five theorems
- `BimodalLib.lean` - import
- `BimodalLib/INDEX.md` - regenerated only if `--check` reports a difference
- `scripts/nolints.json` - one hand-inserted row per `unusedArguments` finding on a pinned signature, only if the batch linter reports one

**Verification**:
- `lake build BimodalLib BimodalLibTest --wfail` exits 0.
- Each of the five theorems has axiom set within `propext, Classical.choice, Quot.sound`.
- The six Challenge identifiers are all declared in namespace `BimodalLib` with the pinned signatures.
- `bash scripts/library-index.sh --check` exits 0.

---

### Phase 7: The edge registry, the conjectures and the generated status table [NOT STARTED]

**Goal**: A status table in `BimodalLib/INDEX.md` rendered from rows that carry a proof, a
refutation or an obstruction; conjecture statuses brought in line.

**Tasks**:
- [ ] Create `BimodalLib/Conservativity/Table.lean`: a verdict type indexed by a statement
  (`proved` with a proof, `refuted` with a proof of the negation, `open` with an obstruction
  string); a row type holding the edge's description (smaller cell, larger cell, optional frame
  class), its statement, its verdict and the name of the declaration or conjecture that answers
  or states it.
- [ ] Register the rows: L into L⁺ (proved, `plusDerivable_ofFormula_iff`); Boolean into
  ModalBoolean; Boolean into TemporalBoolean; `□` cell into TM; `□` cell into `□, ⊡` cell;
  temporal cell into TM at `.Base` (refuted); at `.Dense`, `.ZTime`, `.RTime` (open); the
  repaired `.Base` edge (open).
- [ ] In `BimodalLib/Conjectures/Conservativity.lean`: set the four proved conjectures to
  `.derived` and `temporalBooleanIntoTMBase` to `.refuted`, each note naming the theorem; change
  the three remaining temporal notes to the obstruction research names (the S5 laws of `△`,
  `△φ → △Gφ`, and replacement of provable equivalents must be derived inside the temporal cell;
  no completeness theorem is needed); correct the note of `modalBooleanBoxIntoBoxStab`; rewrite
  the module docstring's method paragraph.
- [ ] Register the repaired `.Base` edge as a new conjecture, in existing vocabulary and with no
  new calculus. Suggested statement: every formula of the temporal cell that TM derives at
  `.Base` is derivable within the cell from the always-closure of `X⊤ → △X⊤` as an antecedent.
  Record in the note which rendering was chosen and why it is the cell extended by that formula.
- [ ] In `BimodalLib/Index.lean`: a section "Conservativity edges" rendering one table row per
  registered edge, the status read from the verdict's constructor; add it to `library_index`.
- [ ] Add `Tests/BimodalLibTest/EdgeTableTest.lean` (the rendered section lists every registered
  edge; a row cannot be `proved` without a proof term) and import it in `Tests/BimodalLibTest.lean`.
- [ ] Add the import to `BimodalLib.lean`; `lake build BimodalLib BimodalLibTest --wfail`;
  `bash scripts/library-index.sh` and stage `BimodalLib/INDEX.md`.

**Timing**: 2 hours

**Depends on**: 6

**Verification Tier**: interface

**Tier Justification**: `lake build BimodalLib BimodalLibTest --wfail` followed by `bash scripts/library-index.sh --check` covers the edit, a change to the `library_index` command whose only consumers are the generated index and the `BimodalLibTest` index tests.

**Scope Hypothesis**: The conjecture count in `BimodalLib/INDEX.md` is expected to go from 9 to 10 and the edge table to hold ten rows; both are read off the regenerated index, not asserted.

**Files to modify**:
- `BimodalLib/Conservativity/Table.lean` - new: verdict and row types, the registered edges
- `BimodalLib/Conjectures/Conservativity.lean` - statuses, notes, the new conjecture, docstring
- `BimodalLib/Index.lean` - the edge section
- `BimodalLib.lean` - import
- `BimodalLib/INDEX.md` - regenerated
- `Tests/BimodalLibTest/EdgeTableTest.lean` - new
- `Tests/BimodalLibTest.lean` - import

**Verification**:
- `lake build BimodalLib BimodalLibTest --wfail` exits 0.
- `bash scripts/library-index.sh --check` exits 0 after regeneration.
- `BimodalLib/INDEX.md` has an edge section in which every edge of the task description appears with status proved, refuted or open, and every open row names an obstruction.
- No conjecture for a proved or refuted edge still reads `unsettled`.

---

### Phase 8: Proof fragments of the registered theorems [NOT STARTED]

**Goal**: The index lists every registered theorem whose reference proof leaves its statement
cell, each with a reason, and the library fails to build when a listed entry has none.

**Tasks**:
- [ ] In `BimodalLib/Index.lean` (or a new `BimodalLib/ProofFragment.lean` if the addition
  exceeds about 150 lines): for each registry row, compute `proofProfile` of the registered
  derivation at the row's own frame class and at the schema-variable assignment, by evaluating
  the term inside the command.
- [ ] Measure first: print the rows whose proof profile is not included in the statement profile,
  by fragment and class. Record the count in the phase notes before writing any reason.
- [ ] Add a command recording a reason for a named registered theorem (a string constant keyed
  by the row), and a check command, on the pattern of `assert_registry_complete`, that fails
  when a listed row has neither a proved edge in the Phase 7 registry for its statement cell and
  class nor a recorded reason. A proved edge supplies the reason "the proof can be lowered" with
  the edge theorem's name.
- [ ] Record reasons for the listed rows no proved edge covers: for `TemporalBoolean` at `Base`,
  that the edge is refuted and, for NF, NA, NP and what is derived from them, that the proof
  cannot be lowered; for the other three classes, that lowering depends on the registered
  conjecture, named.
- [ ] Render the listing as a section of the index; run the check from
  `BimodalLib/Theorems/Complete.lean` (or beside it) so that `lake build BimodalLib` enforces it.
- [ ] Add `Tests/BimodalLibTest/ProofFragmentTest.lean` with a fixture row that has a proof
  outside its cell and no reason, asserting the check fails on it; import it.
- [ ] **Contingency.** If evaluation fails for some rows (a `noncomputable` derivation, a
  timeout): list each such row as "proof profile not computed" and subject it to the same
  check. If evaluation fails for all rows, fall back to kernel reduction with `decide` on
  `proofProfile d ≤ c` for the closed rows, and record what could not be computed.
- [ ] `lake build BimodalLib BimodalLibTest --wfail`; `bash scripts/library-index.sh`; stage
  `BimodalLib/INDEX.md`.

**Timing**: 2 hours

**Depends on**: 7

**Verification Tier**: interface

**Tier Justification**: `lake build BimodalLib BimodalLibTest --wfail` followed by `bash scripts/library-index.sh --check` covers the edit, a new index section and a build-time check whose consumers are the library root and the `BimodalLibTest` tests.

**Scope Hypothesis**: Research expects the listed rows outside proved cells to be NF, NA, NP and their consequences in `TemporalBoolean` (`discretePropagateBwd`, `discreteSymmBwd`, `discreteSymmFwd` are named). This is unmeasured; the measuring task above is the authority, and the registry held 190 closed derivations at the last recorded census, itself to be re-read from `assert_registry_complete`.

**Files to modify**:
- `BimodalLib/Index.lean` - proof-profile computation, listing section
- `BimodalLib/ProofFragment.lean` - new, only if the addition is split out
- `BimodalLib/Theorems/Complete.lean` - run the check
- `BimodalLib/Theorems/TemporalBoolean/Base.lean` - recorded reasons
- `BimodalLib/Theorems/TemporalBoolean/ZTime.lean` - recorded reasons, if any row is listed
- `BimodalLib/Theorems/TemporalBoolean/Dense.lean` - recorded reasons, if any row is listed
- `BimodalLib/Theorems/TemporalBoolean/RTime.lean` - recorded reasons, if any row is listed
- `BimodalLib/Theorems/ModalTemporalBoolean/Base.lean` - recorded reasons, if any row is listed
- `BimodalLib.lean` - import, if a module is added
- `BimodalLib/INDEX.md` - regenerated
- `Tests/BimodalLibTest/ProofFragmentTest.lean` - new
- `Tests/BimodalLibTest/Fixtures/UnrecordedProofFragment.lean` - new fixture
- `Tests/BimodalLibTest.lean` - import

**Verification**:
- `lake build BimodalLib BimodalLibTest --wfail` exits 0.
- The fixture test shows the check failing on a row with no reason.
- `BimodalLib/INDEX.md` lists every row whose proof leaves its statement cell, each with a reason; `bash scripts/library-index.sh --check` exits 0.
- No `native_decide` anywhere under `BimodalLib/`.

---

### Phase 9: Theorem index, documentation, records and the closing gate [NOT STARTED]

**Goal**: Each proved edge is in `docs/theorem-index.md` with a pinned axiom set; `docs/`
describes what exists; the implemented part is cut from `records/`; the task's touched paths
pass their gates.

**Tasks**:
- [ ] `docs/theorem-index.md`: rows for the two Phase 5 edge theorems and the parametric
  translation theorem (fully qualified names, file path, frame class `—`, `pcq pinned:C14`),
  beside the existing `plusDerivable_ofFormula_iff` row.
- [ ] `scripts/check-module-invariants.sh`: add the same three declarations to both halves of
  the C14 pair (the `C14BASE` expected lines and the `C14LEAN` `#print axioms` lines), in the
  position the existing ordering dictates. The refutation and the `within` forms are in
  `BimodalLib`, outside what C14 can pin; state that in the docs, do not add rows for them.
- [ ] `FormalSystem/Metalogic/Conservativity/README.md` and the docstring of
  `FormalSystem/Metalogic/Conservativity.lean`: a section on the fragment edges (the calculus,
  the translation theorem, the two edges, the pointer to `BimodalLib` for the refutation and the
  table). Complete `FormalSystem/Metalogic/Conservativity/Fragments/README.md`.
- [ ] `docs/reference/bimodal-lib.md`, `BimodalLib/README.md`, `BimodalLib/Conjectures/README.md`:
  the edge registry and its table, the proof-fragment listing and check, the refutation and what
  it means for filing at `TemporalBoolean` over `Base`, how to record a reason, the changed
  conjecture set. `Tests/README.md` if it lists the test modules.
- [ ] `records/theorem-library.md`: cut the conservativity table and the three-step method text
  that is now implemented; keep what is not built (the temporal edges at three classes and the
  repaired `.Base` edge, with the obstruction), point to `BimodalLib/INDEX.md` for the status,
  and correct the claim that filing at the smallest fragment is a theorem at every cell.
- [ ] `records/proof-mode.md`, M22: reword the done-when clause to the translation method, and
  replace the filed-record sentence about two completeness theorems by the proposed record for
  the temporal edges (the always translation at `.Dense`, `.ZTime`, `.RTime` and the repaired
  `.Base` edge).
- [ ] State the current design only in every file outside `specs/`: no task numbers, no "no
  longer", "previously" or version framing.
- [ ] If any `.lean` docstring changed line counts under `FormalSystem/`: rerun
  `bash scripts/typst-sync-check.sh --fix` and `--emit-inventory`, and stage the results.
- [ ] Run the scoped gates listed under Verification over the task's touched paths.
- [ ] Record the proposed follow-up record (temporal edges) in the implementation summary.

**Timing**: 2 hours

**Depends on**: 8

**Verification Tier**: full

**Files to modify**:
- `docs/theorem-index.md` - three rows
- `scripts/check-module-invariants.sh` - C14 baseline pair
- `FormalSystem/Metalogic/Conservativity/README.md` - fragment-edge section
- `FormalSystem/Metalogic/Conservativity.lean` - docstring
- `FormalSystem/Metalogic/Conservativity/Fragments/README.md` - completed
- `docs/reference/bimodal-lib.md` - edges, proof fragments, conjectures
- `BimodalLib/README.md` - module table
- `BimodalLib/Conjectures/README.md` - conjecture set
- `Tests/README.md` - test modules, if listed there
- `records/theorem-library.md` - cut the implemented part
- `records/proof-mode.md` - M22
- `typst/generated/status.typ` - regenerated if a FormalSystem docstring moved the line count
- `README.md` - regenerated inventory block, if moved
- `FormalSystem/Metalogic/README.md` - regenerated inventory block, if moved

**Verification**:
- Scoped touched-path checks, run in this dispatch and observed green:
  - `lake build --wfail`, `lake build BimodalLib BimodalLibTest --wfail`.
  - `bash scripts/check-module-invariants.sh`: C14, C15, C33, C26, C3 and the inventory check pass; any failure is judged against the pre-task commit, and a finding that names no file this task touched is recorded as pre-existing, not fixed here.
  - `bash scripts/library-index.sh --check`, `bash scripts/typst-sync-check.sh --counts-only`, `bash scripts/check-metalogic-cycles.sh`.
  - `bash scripts/check-copyright-headers.sh --strict FormalSystem BimodalTools BimodalLib` and `bash scripts/readme-lint.sh FormalSystem BimodalTools BimodalLib`, judged on the files and directories this task added.
  - `bash .claude/scripts/check-task-references.sh` finds no task-number reference in any file this task touched outside `specs/`.
- The complete gate set (`bash scripts/verify-all.sh` and the deploy gate set) is owed once per orchestration invocation and is deferred to the orchestration close; this phase does not run it independently. In a standalone, non-orchestrated run, this phase runs `bash scripts/verify-all.sh` directly.
- Done-when, checked item by item: every edge is proved, refuted or a conjecture with a named obstruction (edge section of `BimodalLib/INDEX.md`); the table is generated (`library-index.sh --check`); each proved edge is in `docs/theorem-index.md` with a pinned axiom set; no entry has a proof outside its statement cell without a reason (the build-time check).

## Testing & Validation

- [ ] `lake build --wfail` and `lake build BimodalLib BimodalLibTest --wfail` are green.
- [ ] All six Challenge identifiers exist with the pinned signatures and axiom set within `propext, Classical.choice, Quot.sound`.
- [ ] No `sorry`, new `axiom` or `native_decide` in `BimodalLib/` or under `FormalSystem/Metalogic/Conservativity/Fragments/`.
- [ ] No module under `FormalSystem/` imports `BimodalLib` (B3).
- [ ] `bash scripts/library-index.sh --check` is green; the index has the edge table and the proof-fragment listing.
- [ ] The proof-fragment check fails on the fixture and passes on the library.
- [ ] `bash scripts/check-module-invariants.sh` shows no new finding relative to the pre-task commit.
- [ ] `records/theorem-library.md` no longer carries the implemented table; `docs/reference/bimodal-lib.md` describes it.

## Artifacts & Outputs

- `FormalSystem/Metalogic/Conservativity/Fragments.lean` and `Fragments/{Calculus,PropComplete,Translation,Collapse,Edges}.lean`, `Fragments/README.md`
- `BimodalLib/Conservativity/{TemporalBase,Proved,Table}.lean`; additions to `BimodalLib/Fragment.lean`, `BimodalLib/Conservativity.lean`, `BimodalLib/Index.lean`, `BimodalLib/Conjectures/Conservativity.lean`
- `BimodalLib/INDEX.md` with the edge table and the proof-fragment listing
- `Tests/BimodalLibTest/{EdgeTableTest,ProofFragmentTest}.lean` and one fixture
- Three rows in `docs/theorem-index.md` and their C14 baseline lines
- Revised `docs/reference/bimodal-lib.md`, READMEs, `records/theorem-library.md`, `records/proof-mode.md`
- `specs/975_theorem_library_fragment_conservativity/summaries/01_fragment-conservativity-edges-summary.md`, naming the proposed record for the temporal edges

## Rollback/Contingency

Each phase is one commit and adds files or additive declarations; reverting a phase's commit
removes it without touching earlier phases, provided the generated files are regenerated
afterwards (`mk_all`, `typst-sync-check.sh --fix`, `--emit-inventory`, `library-index.sh`).

- Phase 1 stands alone: if every later phase fails, the refutation and one conjecture status
  change are still a correct, shippable result.
- If Phase 3 takes its decision gate, Phase 5 proceeds by hand derivations. If Phase 5 then
  cannot close one of the two edges, that edge keeps its conjecture with status `unsettled` and
  a note naming the axiom whose translation was not derived; Phases 6 to 9 proceed with the
  edges that are proved, the edge row is `open`, and the Challenge statements that depend on the
  missing edge are reported as not met. No statement is admitted with `sorry`.
- If Phase 8's evaluation route fails entirely and the kernel fallback covers only part of the
  registry, the listing is shipped with the uncomputed rows named, and the done-when clause on
  proof fragments is reported as partly met.
- A rollback that discards working-tree changes is preceded by
  `bash .claude/scripts/git-snapshot.sh 975`; an ordinary checkpoint before risky work uses
  `--no-revert`.
