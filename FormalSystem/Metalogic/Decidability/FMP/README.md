# FMP — Finite Model Property

Finite model property (FMP) proofs for TM bimodal logic variants.

The FMP states that if a formula is satisfiable, it is satisfiable in a finite model.
This directory proves FMP via filtration and closure-based model construction,
and is used by the tableau decision procedure.

## Modules

The Decls column is a declaration count, re-derivable by
`grep -cE '^(theorem|lemma|def|abbrev|instance|noncomputable def|structure) ' FILE`. It replaces
a line count, which rots on every edit and which every row of this table previously got wrong.

| File | Decls | Description |
|------|-------|-------------|
| `ClosureMCS.lean` | 16 | MCS theory restricted to subformula closure (foundation for filtration) |
| `Filtration.lean` | 29 | Filtration construction: quotienting a model by subformula closure equivalence |
| `FiniteModel.lean` | 13 | Finite model extraction and cardinality bounds |
| `FMP.lean` | 10 | Main FMP re-export and unified interface |
| `Periodicity.lean` | 7 | Pigeonhole, loop splicing, and bounded reachability over a finite carrier |
| `TruthPreservation.lean` | 16 | Truth preservation across the filtration quotient |

## Key Results

Every symbol below is a declaration in this directory and is sorry-free — as is all of
`FormalSystem/` outside `Boneyard/`, which check C3 of `scripts/check-module-invariants.sh`
pins by content as a structural-`sorry` inventory of zero.

- `fmp_contrapositive` (`FMP.lean`): `(∀ S : ClosureMCSBundle φ, φ ∈ S.carrier) → Derivable .Base [] φ`
  — the FMP-based completeness direction
- `mcs_finite_model_property` (`FMP.lean`):
  `¬Derivable .Base [] φ → ∃ S, φ ∉ S.carrier ∧ Finite (FilteredWorld φ)`
- `assignmentSpace_card` (`FMP.lean`): the assignment space has exactly `2 ^ |closure φ|` elements
- `filtered_world_bound` (`FMP.lean`): `Nat.card (FilteredWorld φ) ≤ 2 ^ |closure φ|`
- `fmp_size_bound` (`FMP.lean`): the FMP countermodel is finite and bounded by `2 ^ |closure φ|`
- `FilteredWorld.finite` (`FiniteModel.lean`): a `noncomputable instance` — the filtered world type
  is finite
- `filteredCharacteristicSet_injective` (`FiniteModel.lean`): the injection the cardinality bound
  rides
- `filtration_lemma_membership`, `filtration_imp_forward`, `filtration_box_forward`,
  `filtration_lemma_bot` (`TruthPreservation.lean`): the filtration lemma, one clause per
  connective. **These are statements about MCS membership, not about `TruthAt`** — see the next
  section, which explains why no `TruthAt`-shaped version of them is available on this frame. Read
  as membership facts they are exactly the truth-preservation content this directory supplies
- `exists_lt_iter_of_card_le` (`Periodicity.lean`): an iterate at least as long as the carrier
  passes through some state twice, and the loop can be excised — a strictly shorter iterate joins
  the same endpoints
- `exists_bounded_iter` (`Periodicity.lean`): whatever is reachable is reachable in fewer than
  `Nat.card W` steps. This is the bound a bounded graph search enumerates to. Note the quantifier
  placement: it is a statement about *reachability*, not about a fixed path — the fixed-path
  phrasing is false, and the module carries the counterexample

## These theorems are about MCS membership, not about truth

This directory contains **zero** occurrences of `TruthAt`, and that is structural rather than
incidental. `RefinedFilteredTaskFrame`'s task relation is
`refinedFilteredTaskRel := fun w d u => if d = 0 then w = u else True` — the **permissive**
relation, universal at every nonzero duration. All four of its `def:frame` axiom discharges go
through `TaskFrame.*_of_permissive`, i.e. they hold *because* the relation is universal.

The consequence, machine-checked: over `D = ℤ` the frame's one-step relation is the complete graph,
so by `mem_HF_iff_adjacent` its `H_F` is the entire function space `ℤ → FilteredWorld φ`. A truth
lemma of the form `TruthAt M τ t ψ ↔ ψ ∈ (τ.states t _).carrier` is therefore **false** on this
frame: the left side varies freely with `τ` while the right side is fixed by `τ.states t`, and
`someFuture χ` separates them.

Connecting these results to `TruthAt` requires first building a genuine filtered *task relation* on
`FilteredWorld φ` — one derived from the MCS structure — and re-discharging all four axioms for it.
That is open, and it is a filtration-construction problem, not a truth-lemma problem. Note that the
permissive route to *Spherical* and *Limit* is exactly what a non-universal relation would lose;
`TaskFrame.spherical_of_finite` (`Semantics/TaskFrame.lean`) is the replacement route for
*Spherical* at a finite carrier, and is already in place.

### "Rebuild the filtration" is not a refactor of this directory

It is worth stating the negative directly, because the directory's name invites the opposite
reading. A *semantic* finite model property — "if `φ` is refutable then it is refuted in some model
of bounded size" — needs a world space derived from a given **model**, a non-permissive relation,
and a truth lemma. This directory has none of the three: its world space is a quotient of
`ClosureMCSBundle`, i.e. of sets of formulas; its relation is the permissive one above; and there
is no truth lemma, by the argument just given. What it does supply to such an effort is the
**cardinality bookkeeping** — `filtered_world_bound` and `fmp_size_bound` — and nothing else.
Anyone budgeting that work should budget a construction with a different subject, not a
modification of these files.

### One correction to the axiom-re-discharge cost, above

The paragraph above says re-discharging the four axioms for a non-universal relation "is open".
That is right in general and **wrong over ℤ specifically**, and the difference is large enough to
matter to any cost estimate. `TaskFrame.ofStep` (`Semantics/IntNormalForm.lean`) discharges all
seven `TaskFrame` fields from a bare bi-serial relation on a finite nonempty carrier, whatever the
relation's shape, leaving exactly one genuine obligation: bi-seriality. So for a ℤ-frame on a
finite carrier the four `def:frame` axioms are essentially free.

The reason it does not apply here is that `RefinedFilteredTaskFrame` is **polymorphic in `D`**.
Two of `ofStep`'s seven discharges are ℤ-specific — `limit` via `TaskFrame.limit_of_succOrder`, and
`ofStep`'s own statement, which is at `TaskFrame ℤ`. Normalizing the duration type to ℤ first is
therefore what buys the cheap axioms; without it, each axiom is re-discharged by hand.
`Semantics/IntNormalForm.lean`'s module docstring carries both the normalization route and this
pricing.

Archived: the former `DenseFMP.lean`/`DiscreteFMP.lean` variant modules
(`fmp_dense`, `fmp_discrete`) had no live importers and were moved to
`FormalSystem/Boneyard/FMPVariants/`.

## Dependencies

- **Imports from** (outside this directory): `FormalSystem.Metalogic.Core.RestrictedMCS.Basic`,
  `FormalSystem.Metalogic.Core.MCSProperties`, `FormalSystem.Syntax.SubformulaClosure.Closure`,
  `FormalSystem.Metalogic.Soundness`, `FormalSystem.Semantics.Truth`,
  `FormalSystem.Semantics.Validity`, `FormalSystem.Semantics.IntNormalForm`,
  `FormalSystem.Theorems.Propositional.Core`, `FormalSystem.Theorems.TemporalDerived`
- **Imported by**: `FormalSystem.Metalogic.Decidability.Correctness`,
  `FormalSystem.Metalogic.Decidability.IntPresentation`,
  `FormalSystem.Metalogic.Decidability.BiLasso.GoodCycle`,
  `FormalSystem.Semantics.Extension.PeriodicExtension`

## Related Documentation

- [Decidability README](../README.md)
- [Core RestrictedMCS README](../../Core/RestrictedMCS/README.md)
- [SubformulaClosure README](../../../Syntax/SubformulaClosure/README.md)

---

*Last verified: 2026-08-24*
