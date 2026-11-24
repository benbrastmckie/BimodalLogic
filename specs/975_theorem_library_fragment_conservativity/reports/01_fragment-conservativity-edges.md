# Research Report: Task #975

**Task**: 975 - Theorem library: fragment conservativity (milestone M22, lane metatheory)
**Started**: 2026-11-24T00:11:45Z
**Completed**: 2026-11-24T00:26:30Z
**Effort**: 12-16 hours for the edges recommended here (four phases); a further 8-15 hours for the temporal edges, proposed as a record of their own
**Dependencies**: None for the theorems; `theorem_library_layout_and_registry` (landed) for the generated table
**Sources/Inputs**: - Codebase (`BimodalLib/`, `FormalSystem/ProofSystem/`, `FormalSystem/Theorems/`, `FormalSystem/Metalogic/`), `records/theorem-library.md`, `records/proof-mode.md`, cslib at `/home/benjamin/Projects/cslib` (commit `3bdf16d9f`), compiled probes with `lake env lean` on scratch files
**Artifacts**: - `specs/975_theorem_library_fragment_conservativity/reports/01_fragment-conservativity-edges.md` (this report); `specs/975_theorem_library_fragment_conservativity/scratch/refute_temporal_base.lean`; `specs/975_theorem_library_fragment_conservativity/scratch/collapse_translation_check.lean`
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **One registered edge is false, and the refutation is machine-checked.**
  `temporalBooleanIntoTMBase` (`ConservativeEdge { temporal := true } .Base`) is refuted. The
  witness is NF, `X⊤ → G X⊤`: it lies in the temporal cell, TM derives it at `.Base`
  (`DerivedAxioms.discretePropagateFwd`, through NB, MF and MT), and it fails on the serial
  linear order `ℤ ⊕ₗ ℚ`, over which every derivation within the temporal cell at `.Base` is
  sound. A scratch file proves `¬ ConservativeEdge { temporal := true } FrameClass.Base` with no
  `sorry`, axioms `propext, Classical.choice, Quot.sound`.
- **The needed completeness theorems are not within reach, and they are not needed.** S5
  completeness and Burgess-Xu completeness restricted to a cell would each be a rerun of a
  canonical-model development (cslib's temporal one is about 9,000 lines). A syntactic
  translation replaces all three steps of the cslib method for every edge except the two out of
  `Boolean`: map the added operators to what they mean in the model that makes them trivial,
  and show by induction on the derivation that the translation of each axiom is derivable inside
  the cell. The only completeness then used is propositional completeness inside a cell.
- **Three edge groups are provable now**: `Boolean` into everything (stronger than registered:
  `ConservativeEdge {} fc` at all four classes), `ModalBoolean` with `□` into TM at all four
  classes, and the `□` cell into the `□, ⊡` cell as a corollary of the last and
  `plusDerivable_ofFormula_iff`. A compiled probe confirms that every axiom admissible at each
  class translates to an S5 validity under the translation proposed.
- **The temporal edge at `.Dense`, `.ZTime` and `.RTime` is expected true and should be its own
  record.** It goes by the translation `□φ ↦ △φ` and needs the S5 laws of `△` derived inside the
  temporal cell. The tree's temporal derivations do not carry cell membership and the S5 laws of
  `△` are not derived anywhere. At `.Base` the same translation proves a repaired edge: the
  temporal cell plus the single formula `X⊤ → △X⊤`.
- **Fragment proof systems**: each is a predicate on TM derivations (`BimodalLib.within`, already
  defined). The recommendation is to keep the registered statements over that predicate and
  prove them through an equivalent `Prop`-valued calculus, stated once over an abstract
  sublanguage.

## Context & Scope

The task is to settle each edge of the conservativity table in `records/theorem-library.md`:
prove it, refute it, or leave it a registered conjecture with a named obstruction. Research was
to state each fragment's proof system precisely, determine per edge whether the completeness
theorem the three-step method needs is within reach, and propose splitting an edge that is a
project in itself. Constraints: no unproved edge stated with `sorry`; nothing in `BimodalLib`
contains `sorry`, a new `axiom` or `native_decide`; `FormalSystem` never imports `BimodalLib`;
the edge from L⁻ into L is out of scope.

What was not done: no file in the tree was edited. The two scratch files under the task
directory were compiled with `lake env lean` and are evidence, not deliverables. The positive
edges are argued on paper and partly probed; none is proved in Lean yet.

## Findings

### The fragment proof systems, stated precisely

A fragment logic is a **predicate on TM derivations**, not a calculus of its own. It exists:
`BimodalLib.within c d` holds when every formula derived in `d` has profile included in the cell
`c`; `DerivableIn c fc φ` says `φ` has a closed derivation within `c` at class `fc`. A closed
derivation contains only empty contexts (weakening into `[]` forces `[]`), so the assumption
rule never fires.

Unfolded, `DerivableIn c fc` is the least set containing the axiom instances below and closed
under the rules below. `reflectTime` preserves the profile, so TR is available in every cell.

| Cell | Axiom constructors whose instances can lie in the cell | Rules |
|---|---|---|
| `{}` (`Boolean`) | `prop_k`, `prop_s`, `ex_falso`, `peirce` | MP (TR is the identity) |
| `{ box }` (`ModalBoolean`, `□`) | the four above, `modal_t`, `modal_5_collapse`, `modal_k_dist` | MP, necessitation |
| `{ temporal }` (`TemporalBoolean`) | the four above, `serial_future`, `left_mono_until_G`, `right_mono_until`, `enrichment_until`, `self_accum_until`, `absorb_until`, `linear_until`; at `.ZTime` `prior_UZ`; at `.Dense` and `.RTime` `dense_indicator`; at `.RTime` `prior_U_gap`, `sep` | MP, temporal necessitation, TR |
| `{ box, temporal }` | all seventeen | all |

Two constructors lie in no proper cell: `modal_future` (MF, `□φ → □Gφ`) and
`discrete_box_necessity` (NB, `X⊤ → □X⊤`). They are the whole of the interaction between the
families, and NB is what the refutation below turns on. The modal cell is the same at every
frame class, because no class-specific axiom is free of temporal operators.

The extended system has `withinP` and `DerivableInP` on the same pattern.

### The base-class temporal edge is refuted

`specs/975_theorem_library_fragment_conservativity/scratch/refute_temporal_base.lean` proves

```
theorem temporalEdge_base_refuted : ¬ ConservativeEdge { temporal := true } FrameClass.Base
```

in about 190 lines. Its parts:

1. `LTruth lt v φ t`: truth of a formula at a point of a strict order, with the tree's
   guard-first strict `untl`/`snce` clauses; `□` is read as the identity, which is harmless
   because no formula inside the temporal cell contains it.
2. `cell_sound`: a derivation at `.Base` within `{ temporal := true }` is true at every point of
   every transitive, trichotomous order with no greatest and no least point. The seven temporal
   axioms are verified directly; the box axioms and necessitation are excluded by the profile
   hypothesis; the class-specific axioms are excluded by `minFrameClass ≤ .Base`; TR goes by the
   converse order (`reflect_iff`).
3. `NF_fails`: on `ℤ ⊕ₗ ℚ`, the point `inl 0` has an immediate successor and the later point
   `inr 0` has none.
4. The witness is `DerivedAxioms.discretePropagateFwd`, whose own docstring already says that NF
   "is a derived theorem of TM, not of BX".

The mathematical content: the temporal cell at `.Base` is sound for all serial linear orders,
while TM at `.Base` is the logic of ordered abelian groups, which are homogeneous. NB is the
axiom that carries homogeneity, and it mentions `□`. This is the Until/Since counterpart of the
existing L⁻ result that the H/G fragment of TM at `.Base` needs the extra schema (Sp)
(`FragmentAxiomatization.lean`, `not_derivable_sp`).

Consequences for the library. NF, NA (`discretePropagateBwd`), NP (`discreteSymmFwd`) and the
entries derived from them are filed in `TemporalBoolean` at `Base` with a proof fragment of
`ModalTemporalBoolean`, and that proof cannot be lowered. `discretePropagateBwd`,
`discreteSymmBwd` and `discreteSymmFwd` are registered in
`BimodalLib/Theorems/TemporalBoolean/Base.lean`. This is the "recorded reason" the done-when
clause asks for.

The repaired statement at `.Base`: the temporal cell extended by the one closed formula
`X⊤ → △X⊤` (equivalently by NF and NA) is conserved by TM. It follows from the translation
`□ ↦ △` below, since the translation of NB is that formula.

### Whether the completeness theorems are within reach

| Needed by the three-step method | In the tree | Within reach |
|---|---|---|
| Propositional completeness inside a cell | `tautologyDerivable'` (Kalmár) yields a `DerivationTree` with no cell-membership statement | Yes: about 250 lines |
| S5 completeness for the `□` cell | Not stated. TM completeness is over the full language | Not cheaply; cslib's is about 1,500 lines over its own formula type. Not needed |
| Completeness of the temporal schemata alone, per class | Not stated. `BXCanonical/` builds MCSs over the full language | No. A rerun of the chronicle construction per class (the L⁻ `.Dense` row alone took about 2,500 lines). Not needed |

The obstacle is the same in each row and is specific to this formulation: a completeness theorem
here must produce a derivation that stays inside the cell, and no existing construction tracks
that. `deductionTheorem` is defined by well-founded recursion on height, and several helper
derivations are `private`, so cell membership of an existing derivation cannot be read off by
unfolding in general.

Two probes on that point:

- A closure lemma per combinator is easy. `within c (impTrans h1 h2)` from `within c h1`,
  `within c h2` and the three profile bounds closes by `simp [within, impTrans, *]` once
  `Profile.join` has a `join_le` simp lemma.
- Wholesale unfolding of `temporal4Derived` is blocked by its `private` helpers (`dneLiftF`,
  `fFToFTopAnd`, `fTopAndAbsorb`).

### The translation method

**Parametric statement.** Let `tr : Formula → Formula` commute with `imp` and `bot`, let `c` be
a cell and `fc` a class, and suppose:

1. for every axiom instance `a` admissible at `fc`, `tr a` is derivable within `c`;
2. derivability within `c` of `tr φ` gives that of `tr (□φ)`, of `tr (Gφ)` and of
   `tr φ.reflectTime`;
3. `tr φ = φ` whenever `profileF φ ≤ c`.

Then `ConservativeEdge c fc`. The proof is one induction on the derivation. Propositional axioms
need no work in (1): `tr` of a propositional axiom instance is the same axiom at translated
formulas.

This is the syntactic form of the record's three steps. The translation is the semantic bridge
read on formulas ("the model chosen to make the added operators trivial"), hypothesis (1) is
soundness of the larger logic in that model, and completeness of the smaller logic is replaced
by the explicit derivations (1) asks for. The tree has a precedent: the L^▷ over TM⁺ row is
"unconditional and syntactic, carrying no engine".

**The collapse translation** (edges out of `Boolean`, and `ModalBoolean` into TM). Erase the
temporal operators as they read on a constant history:

- dense reading, at `.Base`, `.Dense`, `.RTime`: `untl g e ↦ g ∧ e`, `snce g e ↦ g ∧ e`;
- discrete reading, at `.ZTime` (also sound at `.Base`): `untl g e ↦ e`, `snce g e ↦ e`;
- `□` kept for the modal edge, erased for the Boolean edges.

One reading does not serve every class: `dense_indicator` fails under the discrete reading and
`prior_UZ` under the dense one. `collapse_translation_check.lean` proves `tr_axiom_valid`: under
the stated reading, every axiom admissible at `fc` translates to a formula true at every world
of every S5 model, for both the kept and the erased `□`. It also proves `tr_reflect`
(`tr φ.reflectTime = tr φ`) and the two fixed-point lemmas for hypothesis (3).

What hypothesis (1) then costs inside the cell: `modal_t`, `modal_5_collapse` and `modal_k_dist`
translate to instances of themselves; MF and NB translate to formulas obtained from a tautology
by necessitation and K; every other axiom translates to a propositional tautology over the
cell's formulas. So the single lemma needed is **propositional completeness inside a cell**.

**The always translation** (`TemporalBoolean` into TM). `□φ ↦ △(tr φ)`, everything else fixed.
Temporal axioms translate to instances of themselves. What must be derived inside the temporal
cell:

| Obligation | Content | Status in the tree |
|---|---|---|
| `tr modal_t` | `△φ → φ` | `alwaysToPresent`, cell membership unproved |
| `tr modal_k_dist` | K for `△`, from K for G and H | `temporalKDistDerived` and mirror, cell membership unproved |
| `tr modal_5_collapse` | `¬△¬△φ → △φ`; needs linearity | not derived |
| `tr modal_future` | `△φ → △Gφ`; needs `temporal4Derived` and linearity | not derived |
| `tr discrete_box_necessity` | `X⊤ → △X⊤` | `.Dense`, `.RTime`: from `dense_indicator`. `.ZTime`: `X⊤` is a theorem by `serial_future`, `prior_UZ ⊤` and guard monotonicity. `.Base`: not derivable (the refutation) |
| necessitation | from `φ` infer `△φ` | TN, and TN between two TRs |
| TR | `tr φ.reflectTime` and `(tr φ).reflectTime` differ by the order of conjuncts in `△` | needs replacement of provable equivalents inside the cell |

### Edge by edge

| Edge | Verdict | Route | Evidence |
|---|---|---|---|
| L into L⁺ | proved (existing) | `plusDerivable_ofFormula_iff` | in `docs/theorem-index.md`, `pcq pinned:C14` |
| `Boolean` into `ModalBoolean` | provable now | collapse, `□` erased; in fact `ConservativeEdge {} fc` | `tr_axiom_valid` compiled |
| `Boolean` into `TemporalBoolean` | provable now | the same theorem | the same |
| `ModalBoolean` with `□` into TM, four classes | provable now | collapse, `□` kept | `tr_axiom_valid` compiled |
| `□` cell into `□, ⊡` cell | provable now | forget `withinP`, `plusDerivable_ofFormula_iff`, then the edge above | paper; needs only the modal edge, not the temporal one as the registered note says |
| `TemporalBoolean` into TM at `.Base` | **refuted** | NF on `ℤ ⊕ₗ ℚ` | `temporalEdge_base_refuted` compiled |
| `TemporalBoolean` into TM at `.Dense`, `.ZTime`, `.RTime` | open, expected true | always translation | paper only |
| repaired `.Base` edge (cell plus `X⊤ → △X⊤`) | open, expected true | always translation | paper only |

### Codebase Patterns

- `DerivedAxioms.discretePropagateFwd`, `ConnectDerived.discreteSymmFwd`,
  `ConnectDerived.discretePropagateBwd`: NF, NP, NA, each derived through NB.
- `Propositional/Decidable.lean` `derivable_tautology`: soundness plus the trivial-frame bridge
  for propositional formulas, at `.Base` over `ℤ`. Steps 1 and 2 of the cslib method for the
  Boolean edges exist at one class.
- `Propositional/Kalmar.lean`: the construction to copy for completeness inside a cell.
- `Expressiveness/Table.lean` `TemporalTruth`: an existing linear-order truth definition, tied to
  monadic structures; the scratch `LTruth` is simpler and self-contained.
- `MinusLanguage/MinusFrame.lean` and `SpCountermodel.lean`: the L⁻ precedent for a
  `TaskFrame`-free order semantics, converse-closed for TR, with a two-fibre countermodel.

### External Resources

- cslib `ConservativityLift.lean`, `Modal/Metalogic/ConservativeExtension.lean`,
  `Temporal/ConservativeExtension.lean`. All three results conserve over classical propositional
  logic only; cslib has no parametric lift for a modal or temporal base. See the next section.

### Recommendations

1. **Land the refutation of the `.Base` temporal edge**: the order semantics, cell soundness, the
   countermodel and the theorem, from the scratch file; set `temporalBooleanIntoTMBase` to
   `refuted` with a note naming the theorem. [VERIFIED: PASS -- `lake env lean` on
   `scratch/refute_temporal_base.lean`; `#print axioms` gives `propext, Classical.choice,
   Quot.sound`]
2. **Prove the collapse edges by the translation theorem with the readings above** (dense at
   `.Base`, `.Dense`, `.RTime`; discrete at `.ZTime`). [VERIFIED: PASS -- `tr_axiom_valid`,
   `tr_reflect`, `tr_fix_modal`, `tr_fix_bool` compile in
   `scratch/collapse_translation_check.lean`. This checks that the translated axioms are S5
   validities; it does not check that they are derivable inside the cell, which is
   recommendation 3]
3. **Build the cell calculus first**: a `Prop`-valued derivability relation over an abstract
   sublanguage `L : Formula → Prop` (closed under the parts of `imp`, containing `bot`, invariant
   under `reflectTime`), with contexts; its deduction theorem by plain induction; Kalmár on
   formulas with non-Boolean subformulas as the variables; and the equivalence with
   `DerivableIn c fc` at `L := fun ψ => profileF ψ ≤ c`. Do not prove `within` through the
   existing `deductionTheorem`. [No compiled gate applicable]
4. **Place the parametric theorems in `FormalSystem/Metalogic/Conservativity/`, over the abstract
   sublanguage, and the `within` statements in `BimodalLib`.** `within` and `Profile` live in
   `BimodalLib`, which `FormalSystem` cannot import, so the record's sentence that the theorems
   live under `FormalSystem/Metalogic/Conservativity/` can only hold for a statement that does
   not mention them. [No compiled gate applicable]
5. **Strengthen the two Boolean statements to `∀ fc, ConservativeEdge {} fc`** and derive the
   registered forms from it. [No compiled gate applicable]
6. **Split the temporal edges into a record of their own**: the always translation at `.Dense`,
   `.ZTime`, `.RTime`, and the repaired `.Base` edge. Keep the three registered conjectures
   `unsettled` with the note changed from "needs completeness of the temporal schemata" to the
   named obstruction: the S5 laws of `△`, `△φ → △Gφ` and replacement of equivalents must be
   derived inside the temporal cell. Register the repaired `.Base` edge as a new conjecture.
   [No compiled gate applicable]
7. **Give `within` a `Decidable` instance** so that closed registered entries (NF, NA, NP are
   closed) can be checked by `decide` for the "proof fragment larger than statement fragment"
   listing, and add the `Profile` simp lemmas (`join_le`, and one per formula constructor).
   [No compiled gate applicable]
8. **Do not pursue S5 or Burgess-Xu completeness inside a cell.** [No compiled gate applicable]

## Literature Proof Structure

**Source**: cslib, `Cslib/Logics/Propositional/Metalogic/ConservativityLift.lean`
(`evaluate_iff_of_classicalBridge`, `conservative_over_cpl`),
`Cslib/Logics/Modal/Metalogic/ConservativeExtension.lean`
(`modal_conservative_extension_param`), `Cslib/Logics/Temporal/ConservativeExtension.lean`
(`temporal_conservative_over_cpl`).
**Strategy**: semantic, by soundness, bridge and completeness; direct, no induction on
derivations.

### Step Map
1. Fix an embedding `emb` of propositional formulas into the target language and a satisfaction
   predicate `sat v` per propositional valuation `v` -- `conservative_over_cpl`, binders.
2. Bridge: `sat (emb ψ) ↔ PL.Evaluate v ψ` for every `ψ`, by structural induction from five
   per-connective hypotheses -- `evaluate_iff_of_classicalBridge`.
3. Soundness callback: derivability of `emb φ` gives `sat v (emb φ)` for every `v`, by the
   target's soundness at a model chosen per `v`: one world with total accessibility for modal,
   the constant model at `0 : ℤ` for temporal -- `h_sat`.
4. Completeness of the base: `prop_completeness` turns "true under every valuation" into a
   propositional derivation -- `conservative_over_cpl`, body.

### Dependencies
- Step 4 depends on Steps 2 and 3.
- Step 3 depends on a soundness theorem of the larger logic at the chosen model.

### Potential Formalization Challenges
- Step 1: cslib has a formula type per logic and an embedding. Here fragments are computed
  sublanguages of one type, so `emb` is the identity and the base logic is a restriction of
  derivations. Step 4 must therefore return a derivation inside the cell.
- Step 3: one model does not serve every frame class (the constant model over `ℤ` refutes
  `dense_indicator`; over a dense order it refutes `prior_UZ`).
- Step 4 beyond the propositional base: cslib never does this. Its three results all have
  classical propositional logic as the base. For a modal or temporal base the step needs a
  completeness theorem of that base, which is why the translation method is recommended instead.
- The method presupposes the edge is true. At `TemporalBoolean` into TM at `.Base` no model
  choice works, because the edge is false.

## Decisions

- The fragment proof system is a predicate on TM derivations (`within`), as registered; the
  `Prop`-valued calculus is an equivalent characterization used for proofs.
- The translation method is recommended over soundness, bridge and completeness for every edge
  whose base is not `Boolean`. This departs from the method named in the task description and in
  M22's done-when clause ("by soundness of the larger logic, a semantic bridge and completeness
  of the smaller"); the clause would need rewording when the record is cut.
- The `.Base` temporal edge is entered as refuted, not left open.
- The temporal edges at the other three classes are proposed as a separate record.
- No `user_decision` is set: the task description already prescribes what to do with a refuted
  edge and with an edge that is a project in itself.

## Risks & Mitigations

- **Propositional completeness inside a cell is the one unbuilt piece every provable edge rests
  on.** Mitigation: it is a copy of `Kalmar.lean` at `Prop` level with an inductive deduction
  theorem; if it stalls, the roughly fifteen translated axioms can be derived by hand instead.
- **The always-translation edges are unverified.** That △ is S5 over serial linear orders is
  standard, and the tree derives K, 4, connectedness and linearity from its axiom set, but the
  specific derivations do not exist and nothing here was compiled for them. Mitigation: they
  stay conjectures until proved.
- **`docs/theorem-index.md` pinning for declarations in `BimodalLib`.** Whether check C14 can pin
  a declaration outside `FormalSystem` was not checked. Mitigation: recommendation 4 keeps the
  indexed theorems in `FormalSystem`.
- **The design record's claim is false at one cell.** "Filing a statement at its smallest
  fragment is a theorem" fails for `TemporalBoolean` at `.Base` as the fragment logic is
  currently defined. The filing rule itself is unaffected; what changes is that the temporal
  cell at `.Base` is not a complete account of TM's temporal theorems without NF and NA.
  Mitigation: record it in `records/theorem-library.md` and `docs/reference/bimodal-lib.md`.
- **Generated status table.** The index prints conjectures with a status but has no edge table.
  Mitigation: the planner should decide whether the table is the conjecture listing filtered to
  edges or a small edge registry; the design for it was not researched here.

## Tactic Survey Results

| Goal | Tactic | Result | Premises/Config |
|------|--------|--------|-----------------|
| NF has profile within `{ temporal := true }` | `decide` | success | none |
| Validity of `prop_k`, `prop_s`, `peirce` on an order | `simp only [t_imp]; tauto` | success | none |
| Box axiom excluded from the temporal cell | `simp` | success | `profileF, Profile.join, LE.le, Profile.le` |
| Class axiom excluded at `.Base` | `decide` | fail (free variables) then success after `show ¬ (FrameClass.ZTime ≤ FrameClass.Base)` | none |
| Every axiom translates to an S5 validity | `cases` on both flags, the axiom and the class, then `simp_all <;> tauto` | success | unfold `tr`, the defined connectives, `Axiom.minFrameClass`, `LE.le` |
| `within c (impTrans h1 h2)` | `simp_all` with raw `Profile.le` | fail (profile arithmetic left) | none |
| `within c (impTrans h1 h2)` | `simp [within, impTrans, *]` | success | needs `join_le` and `imp_le` simp lemmas |
| Points of `ℤ ⊕ₗ ℚ` by cases | `induction r using Sum.Lex.rec` | fail | use `obtain ⟨r, rfl⟩ := toLex.surjective r; rcases r` |

## Context Extension Recommendations

- **Topic**: cell membership of derivations
- **Gap**: nothing documents that a `DerivationTree` produced by `deductionTheorem` or by a
  `private` helper cannot be shown to stay within a cell by unfolding.
- **Recommendation**: a short note under `.claude/context/project/lean4/patterns/` or in
  `docs/reference/bimodal-lib.md`, once the cell calculus exists.

## Appendix

### Scratch files

- `specs/975_theorem_library_fragment_conservativity/scratch/refute_temporal_base.lean`
- `specs/975_theorem_library_fragment_conservativity/scratch/collapse_translation_check.lean`

Both compile with `lake env lean <file>` from the repository root against the built
`BimodalLib`.

### Searches and reads

- `grep` for `discretePropagateFwd`, `discrete_box_necessity`, `LinearOrder` with `untl`,
  `always` among `FormalSystem/Theorems/`, `deductionTheorem` counts per theorem module.
- Read in full or in the relevant part: `BimodalLib/Conservativity.lean`, `Fragment.lean`,
  `Conjecture.lean`, `Conjectures/Conservativity.lean`; `ProofSystem/Axioms.lean`,
  `Derivation.lean`, `DerivedAxioms.lean`; `Decidability/Propositional/Kalmar.lean`,
  `Decidable.lean`; `Conservativity/README.md`, `Plus/Forward.lean`; `Metalogic/README.md`;
  `records/theorem-library.md`; M22 in `records/proof-mode.md`.
- No lean-lsp search tool was used; every name cited was confirmed by `grep` or by a compiled
  reference. `Dense ≤ RTime` is confirmed by the `example`s in `Axioms.lean`.

### Effort by phase

| Phase | Content | Estimate |
|---|---|---|
| A | Profile lemmas, cell calculus, equivalence with `within`, deduction theorem, propositional completeness inside a cell | 5-6 h, 400-500 lines |
| B | Translation theorem; Boolean and modal edges at four classes; the `□, ⊡` corollary | 3-4 h, about 250 lines |
| C | Refutation at `.Base` landed from the scratch file | 1-2 h, about 190 lines |
| D | Conjecture statuses, index, `docs/theorem-index.md` rows, `docs/` and `records/` revisions | 2-3 h |
| separate record | Always translation at three classes and the repaired `.Base` edge | 8-15 h, 600-1,000 lines |
