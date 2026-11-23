# Derivation proof mode: goals and milestones

This is a goals document for the derivation proof mode. It states the aim, what is merged, the
directions still to develop, and a set of milestones with the dependencies between them. It is
not a schedule: batch order and batch rationale live in `specs/ROADMAP.md`. How rules and tactics are
organized, and where each contribution sits, is in
[proof-mode-architecture.md](proof-mode-architecture.md). The library of theorems,
countermodels and conjectures the mode is measured against, its organization by language
fragment, the pipeline that fills it and the diagnostics every stage reports are in
[theorem-library.md](theorem-library.md).

## Aim

The proof mode is a set of tactics that build native TM and TM⁺ derivation trees from named
assumptions and scoped rules. Today it is a tested frontend with no user. The aim is to make it
the ordinary way derivations in this repository are written, and then to carry it to
specification reasoning: safety and liveness arguments about systems described in TM. One rule
holds throughout: every tactic assembles `DerivationTree` or `PlusDerivationTree` constructors
and proved derivation rules, and no model, validity argument or completeness result stands in
for a derivation.

## Where it stands

Measured on the working tree.

| Item | Value |
|---|---|
| Tactics | 21 |
| Elaborator modules in `FormalSystem/Automation/ProofMode/` | 5 files, 1,013 lines |
| Pure-rule modules in `FormalSystem/Theorems/ProofMode/` | 8 files, 1,157 lines |
| TM⁺ copies of TM rules (the four `Plus*.lean` files) | 624 lines |
| `throwError` sites in the elaborators | 65 |
| Acceptance examples in `Tests/BimodalTest/Automation/ProofModeTest.lean` | 31 |
| Negative tests | 2, both `fail_if_success`; none asserts a message |
| `sorry`, `axiom` declarations, `native_decide` | none |
| Importers outside the two ProofMode directories | the aggregators and the test file only |
| `#print axioms` checks on proof-mode derivations | none |
| Coverage under `typst/` | none |

The 21 tactics by module: `lstart`, `lintro`, `lexact`, `lapply`, `lsplit`, `lhave`, `lcases`,
`lleft`, `lright` (Basic); `lmodal_intro`, `lmodal_use`, `lmodal_cases`, `ltemporal_intro`
(Modal); `ltemporal_cases`, `ladvance`, `ltemporal_use`, `lprogress`, `luntil`, `lsince`
(Temporal); `lstep`, `linvariant` (Discrete). The usage guide is
`docs/user-guide/derivation-proof-mode.md`; the module inventories are in
`FormalSystem/Automation/ProofMode/README.md` and `FormalSystem/Theorems/ProofMode/README.md`.

What the merged work established:

- **Scope safety by typing.** A named hypothesis is a Lean local whose type keeps its source
  object context, so `lexact` and `lapply` reject an assumption that is unavailable inside a new
  modal or temporal scope.
- **Integer-time invariance inside the calculus.** `forwardInvariantRule` in
  `FormalSystem/Theorems/ProofMode/Discrete.lean` derives `A → (A → X A) → G(A → X A) → G A` at
  `ZTime` from the axioms.
- **A TM⁺ rule base.** `FormalSystem/Theorems/ProofMode/PlusRules.lean` gives TM⁺ its own
  deduction theorem, substitution and contextual necessitation, and generalized K holds for all
  four universal operators.

What is missing:

- **No client.** Nothing outside the mode's own tests is proved with it.
- **No corpus.** The derived theorems under `FormalSystem/Theorems/` are not indexed by fragment
  or frame class, the tableau's verdicts are kept as dataset files and not as library entries,
  and refutations are scattered across the language directories.
- **No axiom audit.** No test states which axioms a proof-mode derivation depends on, though
  `Tests/BimodalTest/WalkthroughAxioms.lean` shows the pattern for other proofs.
- **Thin error testing.** 65 error sites against 2 negative tests, neither checking the message.
- **No reference-manual coverage.** The paper sources do not mention the mode.
- **Two copies of every rule.** Each rule is proved once for TM and once for TM⁺.

One structural fact shapes the work ahead. `ORGANISATION.md` places `FormalSystem/Theorems/` at
layer 2 and `FormalSystem/Automation/` and `FormalSystem/Metalogic/` at layer 3, and each layer
imports downward. No file under `FormalSystem/Theorems/` imports `FormalSystem.Automation`. So a
pure rule can never depend on a tactic, proofs under `FormalSystem/Theorems/` cannot be written
in the proof mode, and proof-mode proofs belong above layer 3. The theorem library is a Lake
library of its own that imports `FormalSystem`, so it sits above both the mode and the tableau,
and proof-mode proofs of library entries live there.

## Dimensions

Each dimension below gives a done-state, the filed records that cover it (named by slug), and
the gap.

1. **Bimodal scope rules.** Done: every TM interaction principle (modal 4 and 5, MF, TF, the
   always and sometimes operators) is usable inside a scope without leaving the mode. Covered by
   `proof_mode_s5_aware_box_scopes`, `proof_mode_cross_modal_scopes_mf_tf` and
   `proof_mode_always_sometimes_scopes`. Gap: none identified.
2. **Linear-time rules.** Done: a three-way linearity case split, and introduction, unfolding
   and induction for Until and Since. Covered by `proof_mode_linearity_case_tactic` and
   `proof_mode_until_since_intro_unfold_induction`. Gap: whatever the temporal sweep report
   lists as missing.
3. **Frame coverage.** Done: frame-specific rules at Dense and RTime as well as ZTime, each with
   its frame certificate solved or shown as a goal. Covered by
   `proof_mode_dense_and_real_time_rules`. Gap: none identified.
4. **Closure automation.** Done: the mode handles structure and a closer finishes the leaves.
   Covered by `proof_mode_close_leaves_with_automation`, which is propositional and TM-only.
   Closers built on the decision procedures in
   `FormalSystem/Metalogic/Decidability/` are covered by
   `proof_mode_decision_procedure_leaf_closers`, which also settles whether any serves TM⁺.
   Gap: a TM⁺ propositional closer.
5. **Evidence and adoption.** Done: `BimodalLib` holds theorems, countermodels and conjectures
   organized by language fragment, with the conservativity theorem for every edge between
   fragments; a selection of its theorems, chosen for what each tests, is proved again in the
   mode; the two proofs are compared by standard diagnostics; and the missing-rule list each
   sweep produces is what the mode works on next. Covered by `proof_mode_reprove_perpetuity` and
   `proof_mode_reprove_temporal_slice` for the first two sweeps, by
   `proof_mode_adoption_after_perpetuity_verdict` for which new work must use the mode, and by
   `investigate_stability_as_modal_family` for the place of `⊡`. The library itself is covered
   by `theorem_library_layout_and_registry`, `theorem_library_tableau_pipeline`,
   `theorem_library_countermodels`, `theorem_library_stability_entries` and
   `theorem_library_fragment_conservativity`. Gap: none identified.
6. **Architecture and language reach.** Done: each rule is proved once over an interface, and
   every object language with a derivation calculus has an instance or a stated reason for
   lacking one. Covered by `proof_mode_abstract_frontend_interface` and
   `proof_mode_instances_other_languages`. Deduction theorems for the Star and Open calculi are covered by
   `proof_mode_deduction_theorems_star_open`. Gap: the languages the usage guide lists as
   separate work (counterfactual, stored-index, metric).
7. **Usability.** Done: goals are readable, introduction patterns nest, every error message is
   tested, and the mode is documented in the guide and the reference manual. Covered by
   `proof_mode_error_message_coverage` (which includes the check that keeps coverage from
   falling), `proof_mode_nested_intro_patterns`, `proof_mode_goal_display` and
   `proof_mode_reference_manual_chapter`. Gap: none identified.
8. **Specification reasoning.** Done: a library of safety and liveness rules, and a worked route
   from a transition system to a TM derivation. Covered by
   `proof_mode_leads_to_invariance_library` and
   `proof_mode_transition_systems_tm_specifications`. Gap: everything after the architecture
   report, which is left unfiled until that report exists.

Two further dimensions cut across the eight.

- **Trust, cost and diagnostics.** Done: every stage, from enumeration through the tableau to
  the proof-mode re-proof, reports in one documented schema; tests state the axiom set of
  representative proof-mode derivations; and there is a baseline for the size of the derivation
  terms the tactics build and for their elaboration time. `lintro` discharges through the
  deduction theorem, which transforms a whole derivation, so cost on long scripts is an open
  question. Covered by `proof_mode_axiom_audit_and_cost_baseline`.
- **Dual verification.** Done: a leaf the mode cannot close is answered with a countermodel from
  the library or the tableau, or handed to the ModelChecker where neither reaches; and
  proof-mode scripts are available to the dataset tooling in `BimodalTools/`. The countermodel
  half is covered by `proof_mode_countermodels_for_unclosed_leaves`; the dataset half has no
  filed record.

## Milestones

Twenty-eight milestones, M0 to M23, with M6, M9 and M14 split into parts. Each block has the same six
fields. A **hard dependency** is one without which the milestone's result cannot be stated or
proved. A **sequencing-only dependency** is an order kept for another reason: the two pieces of
work edit the same files, or running later saves rework.

Every milestone but M17 has a filed record, and the filed dependency edges are exactly the hard
dependencies plus the sequencing-only dependencies listed in each block, with one exception: M22
carries an edge on M18 for its generated table, and its theorems do not wait on it. A sequencing edge is
filed for one of three reasons: two records edit the same family files, the later record is
cheaper once the earlier has landed, or an adequacy gate should be able to hold the record. No
edge is filed merely because two records touch the test suite or the guide: M0 gives each
operator family and interaction its own modules, test file and guide page, and every record
declares a `file_scope`.

### M0: Operator-family layout

- **Aim**: File every rule, tactic, test and guide page by the operator family or interaction its
  statement names, so that two milestones edit different files and a language extension adds
  modules without changing any.
- **Done when**: the pure-rule modules, the tactic modules, the acceptance tests and the guide
  pages follow the naming scheme of [proof-mode-architecture.md](proof-mode-architecture.md),
  with every existing example passing unchanged and no statement, proof or tactic behaviour
  changed; and every filed proof-mode record declares a `file_scope` in that layout.
- **Hard dependencies**: none.
- **Sequencing-only dependencies**: none. It moves files that open contributions edit, so it runs
  after they are merged or declined.
- **Lane**: Elaborators.
- **Filed record**: `proof_mode_split_shared_test_and_guide_files`.

### M1: Bimodal scope core

- **Aim**: Make the modal and bimodal interaction principles usable inside scopes.
- **Done when**: a □ scope carries `□A` and `◇A` intact on request, with the TM⁺ stability
  mirror; □ facts cross into G and H scopes by MF and TF in both time directions; always and
  sometimes have introduction, use and case rules; and the six perpetuity principles are derived
  by short scripts in the acceptance tests, citing nothing under
  `FormalSystem/Theorems/Perpetuity/`.
- **Hard dependencies**: none. The three records form an internal chain: each extends the scope
  rules the one before adds.
- **Sequencing-only dependencies**: M0, for the file layout.
- **Lane**: Rule theory, then Elaborators.
- **Filed record**: `proof_mode_s5_aware_box_scopes`, then `proof_mode_cross_modal_scopes_mf_tf`,
  then `proof_mode_always_sometimes_scopes`. Of the contributed temporal rules, `G`/`H` carrying,
  as rows of the carrying table, and whole-judgment time reflection are the only two that
  gate-one scripts may use, each only once it is adopted into this milestone before the gate-one
  selection is fixed.

### M2: Leaf closure

- **Aim**: Let automation close the leaves the mode leaves open.
- **Done when**: a closing tactic built on `propDecide` closes the propositional leaves in the
  acceptance tests, discharging object assumptions first; it fails with a clear message
  otherwise, including on a TM⁺ goal; it yields a native derivation only and adds no axiom.
- **Hard dependencies**: none.
- **Sequencing-only dependencies**: M0, for the file layout. The closer uses `propDecide` and deduction and no scope
  rule, so it runs beside M1; gate one still measures the mode with leaves automated because M3
  depends on both.
- **Lane**: Elaborators.
- **Filed record**: `proof_mode_close_leaves_with_automation`.

### M3: Gate one, first fragment sweep

- **Aim**: Measure the mode on the library fragments its first rule set covers.
- **Done when**: a selection of theorem entries from the library's `Boolean` and `ModalBoolean`
  fragments and from the Perpetuity section of `ModalTemporalBoolean`, the six principles
  included, is fixed before any script is written, with a stated reason for each entry: the
  rule, tactic or scope it exercises; the selection exercises every rule M1 and M2 provide;
  each entry is attempted in the mode under `BimodalLib/ProofMode/` against its registered statement,
  without citing its reference proof; every attempt has a diagnostic record; and a report opens
  with an explicit GO or RE-PLAN verdict backed by per-entry measurements and ends with the
  missing-rule list.
- **Hard dependencies**: M1, M2. The gate measures exactly that rule set. M18, which registers
  the entries, and M13, which fixes the records.
- **Sequencing-only dependencies**: none.
- **Lane**: Evaluation.
- **Filed record**: `proof_mode_reprove_perpetuity`.

### M4: Linear-time rules

- **Aim**: Give the mode linearity reasoning and full Until and Since rules.
- **Done when**: a tactic opens the three ordered cases for two eventualities or two Until or
  Since facts, in both time directions and both languages; Until and Since have introduction,
  one-step unfolding at `ZTime`, and an induction rule of which `forwardInvariantRule` is an
  instance; and `linvariant` is expressed through that induction rule.
- **Current state**: the temporal contribution, not yet merged, contributes Until and Since
  introduction, one-step unfolding at `ZTime`, `keeping` (carrying `G` and `H` facts across
  steps), whole-judgment time reflection, and the strict leads-to layer. Its one-step rules use
  `expand` and `contract`, which is the settled naming for this family — distinct from
  `lunfold`/`lfold`, the unrelated views pair of M16. The generalizing induction rule is a
  separate part of this milestone and remains open; see the proposed statement below.
- **Hard dependencies**: M3 with a GO verdict. Both records read the gate-one report first.
- **Sequencing-only dependencies**: inside M4, the case split is filed before the Until and
  Since rules. This is sequencing only for all three parts. The principles introduction and
  unfolding rest on (`left_mono_until_G`, `unfoldForward`, `unfoldBackward`,
  `unfoldBackwardSince`) take no linearity premise. The pure induction rule sits under
  `FormalSystem/Theorems/ProofMode/` at layer 2 and cannot import a tactic; what it takes of
  linearity is a theorem, `Axiom.linear_until` and `FormalSystem/Theorems/LinearityDerived.lean`,
  never the case-split tactic. This holds whatever the rule's formula is. The alternative leaves
  the induction rule's edge undecided until the rule is derived; its merit is caution about a
  formula nobody has derived, and it is rejected because the layer argument does not depend on
  the formula.
- **Lane**: Rule theory, then Elaborators.
- **Filed record**: `proof_mode_linearity_case_tactic`, then
  `proof_mode_until_since_intro_unfold_induction`.

The proposed statement of the induction rule, at `ZTime`, with guard `g`, event `e` (Lean
`Formula.untl g e`), strict operators and `X φ := untl ⊥ φ`:

```
⊢[ZTime] (X(e ∨ (g ∧ C)) → C) → G(X(e ∨ (g ∧ C)) → C) → (g U e → C)
```

The Since rule is its mirror by time reflection. Both a present premise and a `G` premise are
needed because `G` is strict, as in `forwardInvariantRule`. Putting `g := ⊤`, `e := ¬A` and
`C := ¬A` recovers `forwardInvariantRule` up to argument order: the premise body becomes
`X¬A → ¬A`, which at `ZTime` is `A → X A`, and the conclusion becomes `F¬A → ¬A`, that is
`A → G A`. The statement is proposed. It is argued by hand on ℤ and is not derived or
machine-checked; deriving it is the work of `proof_mode_until_since_intro_unfold_induction`.
Backward induction, from `G(Gφ → φ)` and `F(Gφ)` to `Gφ`, is in the library as
`futureBackwardInduction` and is a different rule: `forwardInvariantRule` is not an instance of
it, so it does not meet the done-when.

### M5: Gate two, temporal fragment sweep

- **Aim**: Measure the temporal rule set on the library and list what it lacks.
- **Done when**: a selection of theorem entries from `TemporalBoolean` and the rest of
  `ModalTemporalBoolean`, at Base and at ZTime, is fixed in advance with a stated reason for
  each, exercises every rule M4 provides, and includes at least four entries registered from
  each of `FormalSystem/Theorems/TemporalDerived.lean`,
  `FormalSystem/Theorems/ConnectDerived.lean` and `FormalSystem/Theorems/LinearityDerived.lean`
  with `tempLinearity` among them; each is attempted in the mode; and a report gives the same measurements
  as gate one plus every missing rule, each either added or named with a proposed follow-up
  description.
- **Hard dependencies**: M4. The set includes a linearity proof and Until proofs.
- **Sequencing-only dependencies**: M19, so that the set includes entries admitted from the
  tableau and not only hand proofs.
- **Lane**: Evaluation.
- **Filed record**: `proof_mode_reprove_temporal_slice`.

### M6a: Error-message coverage

- **Aim**: Test every error message the mode can produce.
- **Done when**: each `throwError` site in `FormalSystem/Automation/ProofMode/` has a negative
  test asserting its message with `#guard_msgs`, or is listed as unreachable with a reason, and a
  check fails when a site is added without a test.
- **Hard dependencies**: none.
- **Sequencing-only dependencies**: M0, for the test layout. It tests the merged tactics and changes no rule, so
  it does not wait on gate one. Once its check is in, each later record covers its own error
  sites as it adds them.
- **Lane**: Elaborators.
- **Filed record**: `proof_mode_error_message_coverage`.

### M6b: Nested introduction patterns

- **Aim**: Let `lcases` and `lintro` take nested patterns.
- **Done when**: both tactics accept nested patterns, with tests and a guide section.
- **Hard dependencies**: none.
- **Sequencing-only dependencies**: M6a, whose check the new error sites must pass, and M3: the gate can hold the
  record, and the edge places it after M1, which edits the same elaborators. It runs beside M4.
- **Lane**: Elaborators.
- **Filed record**: `proof_mode_nested_intro_patterns`.

### M6c: Goal display

- **Aim**: Show named hypotheses and the object goal compactly.
- **Done when**: a goal view elides a hypothesis's object context only when it equals the goal's
  context, keeps a differing context visibly marked, and is documented in the guide.
- **Hard dependencies**: none.
- **Sequencing-only dependencies**: M6b, stacked in the same stream; through it M3, whose module supplies real
  scripts to design the display against.
- **Lane**: Elaborators.
- **Filed record**: `proof_mode_goal_display`.

### M7: Frame coverage at Dense and RTime

- **Aim**: Expose the dense and real-time principles as proof-mode rules.
- **Done when**: DN at Dense, and PU, SEP and CO at RTime, each have a pure rule and a tactic
  whose frame certificate is solved when reflexive and otherwise shown as a goal, tested at a
  concrete and an abstract frame class in TM and TM⁺.
- **Hard dependencies**: none. `density` takes `Dense ≤ fc`, `coDerived` takes `RTime ≤ fc`,
  `prior_U_gap` and `sep` are axiom constructors at RTime, and the certificate pattern is the
  one `lstep` has.
- **Sequencing-only dependencies**: M3, so that the gate can hold the record. Nothing in the deliverable uses an
  Until or Since rule from M4 or anything from M6, so it runs beside M4 in its own family files.
- **Lane**: Rule theory, then Elaborators.
- **Filed record**: `proof_mode_dense_and_real_time_rules`.

### M8: One interface, rules proved once

- **Aim**: Prove each pure rule once over an object-level typeclass.
- **Done when**: TM and TM⁺ are two instances of the class; the duplicated TM⁺ rule proofs are
  deleted or reduced to instance fields; no elaborator names either language; and the acceptance
  suite passes unchanged.
- **Hard dependencies**: M5. The record says to extract the interface from the rule set as it
  stands after the adequacy tests.
- **Sequencing-only dependencies**: M7, so that the interface is extracted having seen a Dense and an RTime rule;
  M6b and M6c, because this milestone rewrites every elaborator. It is the one point where the
  streams join: nothing that edits either ProofMode directory runs beside it.
- **Lane**: Rule theory and Elaborators together.
- **Filed record**: `proof_mode_abstract_frontend_interface`.

### M9a: Minus instance and language accounting

- **Aim**: Extend the mode to the other object languages that can support it.
- **Done when**: the Minus calculus has a proof-mode instance with acceptance tests, and every
  directory matching `FormalSystem/*Language/` is accounted for in the guide, by an instance or
  by a stated reason.
- **Hard dependencies**: M8.
- **Sequencing-only dependencies**: M9b, which owns the Star and Open metatheory, so that the accounting here
  cites a theorem or a written obstruction.
- **Lane**: Rule theory.
- **Filed record**: `proof_mode_instances_other_languages`. The Minus deduction theorem is
  `FormalSystem/Metalogic/Conservativity/MinusDeduction.lean`, at layer 3. This milestone moves
  it to `FormalSystem/Theorems/`, with `MinusTemporalDerived.lean` if the rule module needs it,
  and the Minus pure-rule module sits under `FormalSystem/Theorems/ProofMode/` as the TM and TM⁺
  modules do. Both files import layer 0 only and every importer is at layer 3, so the move
  creates no upward edge. Two alternatives are rejected. The instance at layer 3, beside the
  theorem, moves no file and regenerates no inventory; it puts one language's rule module
  outside the Rule-theory lane and makes the naming scheme carry an exception. Moving the
  theorem into `FormalSystem/MinusLanguage/` leaves it at layer 3, because `ORGANISATION.md`
  gives a language-directory file the layer of its origin directory, as
  `MinusLanguage/Soundness.lean` has.

### M9b: Deduction theorems for Star and Open

- **Aim**: Supply the metatheory a Star or Open instance needs.
- **Done when**: each of the Star and Open calculi has a proved deduction theorem, generalized K
  and context substitution, or a written reason why it cannot.
- **Hard dependencies**: none. This is metatheory about the calculi and needs no interface.
- **Sequencing-only dependencies**: none.
- **Lane**: Metatheory.
- **Filed record**: `proof_mode_deduction_theorems_star_open`. Its Open half follows the standing
  ruling that places the L^▷ line behind L⁺ critical-path work.

### M10: Safety and liveness library

- **Aim**: Provide the standard rules for invariance and leads-to.
- **Done when**: leads-to is defined as a named abbreviation with present-inclusive operators
  and related to the strict form `lprogress` uses; invariance, leads-to transitivity and
  disjunction, and finite-family well-founded progress exist as pure rules with tactics for TM
  and TM⁺; with worked examples and a guide section.
- **Hard dependencies**: M4 and M5. The library builds on the induction rule and on the
  missing-rule list.
- **Sequencing-only dependencies**: M8, so that each rule is proved once over the interface. The done-when names
  TM and TM⁺ only and uses no other-language instance, so M9a is not a predecessor.
- **Lane**: Rule theory, then Elaborators.
- **Filed record**: `proof_mode_leads_to_invariance_library`. The contributed strict leads-to
  rules are the layer beneath the present-inclusive definition, labelled as the strict layer,
  and the inclusive rules are proved from them. Strict as the base matches the primitive
  operators and needs no unfolding of a definition; it is rejected because `G(φ → Fψ)` says
  nothing about the present, so reflexivity and introduction from an implication fail for it.

### M11: Transition-system architecture report

- **Aim**: Decide how a transition system is verified against a TM specification.
- **Done when**: a report under `docs/development/` gives a recommended architecture, the
  smallest worthwhile first case study, and proposed descriptions for the work that follows.
- **Hard dependencies**: M10, for the assessment of which rules carry the arguments.
- **Sequencing-only dependencies**: none. The survey of Veil and of the ModelChecker's role
  depends on no rule and can be drafted at any time.
- **Lane**: Research and writing.
- **Filed record**: `proof_mode_transition_systems_tm_specifications`.

### M12: Adoption

- **Aim**: Turn a GO verdict into a working practice.
- **Done when**: the guide states which kinds of new derivation are to be written in the mode
  and what "default" means given the layer order; a theorem entering the library is required to
  come with a proof-mode script or a recorded failure class; and at least one module outside the
  tests and the library's sweeps is proved in the mode.
- **Hard dependencies**: M3 with a GO verdict.
- **Sequencing-only dependencies**: none.
- **Lane**: Research and writing, then Evaluation.
- **Filed record**: `proof_mode_adoption_after_perpetuity_verdict`.

### M13: Diagnostics standard, trust and cost baseline

- **Aim**: Fix the records every stage reports in, and know what proof-mode derivations depend
  on and what they cost.
- **Done when**: the record schema of [theorem-library.md](theorem-library.md) exists with the
  command that emits the re-prove and compare records, and each field is documented under
  `docs/`; a test module asserts the axiom set of at least one derivation per tactic family in
  TM and TM⁺, on the pattern of `Tests/BimodalTest/WalkthroughAxioms.lean`; and a recorded
  baseline gives derivation-term size and elaboration time for the acceptance examples and for
  one long script with nested `lintro`, with the command that reproduces it.
- **Hard dependencies**: none.
- **Sequencing-only dependencies**: M0, for the test layout.
- **Lane**: Evaluation.
- **Filed record**: `proof_mode_axiom_audit_and_cost_baseline`.

### M14a: Closers from the decision procedures

- **Aim**: Close non-propositional leaves with the proved decision procedures.
- **Done when**: it is established which procedures under `FormalSystem/Metalogic/Decidability/`
  return a derivation and not only a validity verdict; and for each that does, the leaf closer
  uses it and yields a native derivation, with tests and no `native_decide`.
- **Hard dependencies**: M2, which provides the closing tactic to extend.
- **Sequencing-only dependencies**: M8, which rewrites the closer's elaborator. The research half depends on
  neither.
- **Lane**: Metatheory, then Elaborators.
- **Filed record**: `proof_mode_decision_procedure_leaf_closers`. Completeness of proof extraction is
  not a prerequisite: a closer may fail.

### M14b: Refutation of unclosed leaves

- **Aim**: Answer a leaf the mode cannot close with a countermodel.
- **Done when**: a failed leaf is looked up in the countermodel half of the library and, failing
  that, decided by the tableau, and a countermodel of a stated grade is reported against the
  leaf; a leaf outside the tableau's language can be exported in a form the ModelChecker
  accepts, and what it returns is reported the same way. A countermodel is a diagnostic; it
  never closes a goal.
- **Hard dependencies**: M20, which defines the entries and their grades. M11 for the
  ModelChecker half only: its report fixes the division of labour.
- **Sequencing-only dependencies**: M14a, so that an unclosed leaf is measured against the full closer.
- **Lane**: Library, then Elaborators.
- **Filed record**: `proof_mode_countermodels_for_unclosed_leaves`.

### M15: Reference-manual chapter

- **Aim**: Document the mode in the paper sources.
- **Done when**: a chapter under `typst/` states the rules the tactics implement and the
  scope-safety guarantee, compiles, and passes the chapter-quality check.
- **Hard dependencies**: M5. The chapter documents the rule set as it stands after both gates.
- **Sequencing-only dependencies**: M8, which deletes the TM⁺ rule copies and restates every rule over the
  interface; a chapter grounded in declaration names is written against the names that remain.
- **Lane**: Research and writing.
- **Filed record**: `proof_mode_reference_manual_chapter`.

### M16: Views tier

- **Aim**: Separate changing how a formula is written from proving anything.
- **Done when**: every defined operator in TM and TM⁺ has a row in one view table, and the pair
  `lunfold` and `lfold`, each taking a view name, folds and unfolds it using definitions and
  formula equalities only, with no axiom, rule, context or frame class; the table holds the rows
  contributed with M17; the operator matching the elaborators use rests on the same table; and
  the tier sits at layer 0 or 1, outside `FormalSystem/Automation/ProofMode/`, below the
  derivation tactics, and imports none of them.
- **Current state**: the table and the `lunfold`/`lfold` pair already exist on `main`, at
  `FormalSystem/Tactic/FormulaViews.lean`, placed at the layer-0-or-1 position the architecture
  record requires. It holds the seven rows the rewriting contribution added — `diamond`, `next`
  and `prev` for `Formula`, and `diamond`, `dstab`, `next` and `prev` for `PlusFormula`. The
  twenty further rows the temporal contribution adds (ten `Formula`, ten `PlusFormula`, the extra
  pair being `after`) and its retirement of `ltemporal_dual` live only on that contribution's
  branch and are not on `main`. What this record still owes independently of either contribution
  is completeness: most of `Formula`'s twenty-six and `PlusFormula`'s twenty-two defined
  operators, the Boolean derived connectives among them, have no row yet, and neither
  contribution closes that gap on its own; this milestone is done only once every defined
  operator has one.
- **Hard dependencies**: none.
- **Sequencing-only dependencies**: M0, for the layout. M17 is merged or declined before M0
  runs, so its rows exist when the tier is built. The always and sometimes part of M1 and
  M8 are ordered after it: both state rules about defined operators directly.
- **Lane**: Elaborators, in files at layer 0 or 1 and not in that lane's tactic directory.
- **Filed record**: `proof_mode_views_tier`.

### M17: Logical rewriting

- **Aim**: Replace a subformula under modal and temporal operators by a derivably implied or
  equivalent one, with the justification checked at every scope it passes.
- **Done when**: rewriting and a bounded simplifier exist as derivation-tier tactics over one
  congruence step per operator, separate from views: the formula-equality path is outside
  `lrewrite` and `lsimp` and is exposed through `lunfold` and `lfold`, with the first rows of
  the view table; errors from a supplied rule surface to the user; and at least one library
  entry in a sweep is shorter with them, shown by a second run of the gate-one selection with
  `lrewrite` and `lsimp` permitted and reported apart from the gate-one verdict.
- **Current client**: the statement of `Perpetuity.boxDne` is proved by two tactics,
  `lrewrite ← doubleNegation A (path := [boxBody])` then `lexact h`, against five steps in the
  hand proof. The saving is in the proof script and not in the proof term, which is larger for
  the rewrite variant. `boxDne` itself keeps its hand proof; the variant is an example in
  `Tests/BimodalTest/Automation/ProofModeModalBooleanTest.lean`. The full comparison waits on
  the M3 selection.
- **Hard dependencies**: none for the tactics. The second run waits on M3's sweep.
- **Sequencing-only dependencies**: none. It is merged or declined before M0 runs; M16 follows
  M0 and takes over the view rows contributed here.
- **Lane**: Rule theory, then Elaborators.
- **Filed record**: none; merged. Its tactics are outside the gate-one scripts and the gate's
  verdict.

### M18: Library layout and registry

- **Aim**: Give the theorem library its layout by fragment and register what is already proved.
- **Done when**: `BimodalLib` builds; the fragment of a formula is computed for `Formula` and
  `PlusFormula`; every closed derivation under `FormalSystem/Theorems/` outside its `ProofMode/`
  directory is registered with its statement fragment, frame class and substitution class, and a
  check fails when one is added unregistered; a re-proof is elaborated against the type of the
  registered statement; a conjecture can be registered as a statement with a status and no
  proof term; and a generated index lists the entries by fragment, with every box law that lacks
  its diamond dual.
- **Hard dependencies**: none.
- **Sequencing-only dependencies**: none. It edits no file under either ProofMode directory.
- **Lane**: Library.
- **Filed record**: `theorem_library_layout_and_registry`. `BimodalLib` is a Lake library
  outside `defaultTargets`, built by explicit target and by its own `--wfail` step in CI, as
  `BimodalTools` is, with an import-direction check that `FormalSystem` never imports it. A
  plain `lake build` compiles the published library and nothing else, and this library holds
  sweeps and enumerated entries. The alternative is a default target, under which a
  contributor's plain build would catch a re-proof that has drifted; it is rejected because CI
  catches the same drift and the default build would change its meaning.

### M19: Tableau pipeline into the library

- **Aim**: Fill the fragments the tableau covers from its verdicts.
- **Done when**: one command enumerates the formulas of `Boolean`, `ModalBoolean`,
  `TemporalBoolean` and `ModalTemporalBoolean` to a stated bound at each frame class the tableau
  accepts, and runs them through the stages of [theorem-library.md](theorem-library.md); each
  valid formula with an extracted derivation is admitted as a schema unless an existing entry
  subsumes it; every other verdict is registered as a conjecture with its reason; and each stage
  emits its diagnostic records.
- **Hard dependencies**: M18, for the registry, and M13, for the records.
- **Sequencing-only dependencies**: none. It reuses the enumerator and the decision entry points
  under `BimodalTools/` and adds no rule.
- **Lane**: Library.
- **Filed record**: `theorem_library_tableau_pipeline`.

### M20: Countermodel library

- **Aim**: Keep every refuted inference with a checked refutation.
- **Done when**: a countermodel entry records an inference, a frame class, a model and a proof
  of non-validity at one of the three grades; the hand-built refutations in the language
  directories and the independence results are registered; gated tableau refutations and
  accepted certificates are admitted; an ungated verdict stays a conjecture and is never
  admitted; a
  refuted near miss and the theorem it bounds name each other; and an inference can be looked up.
- **Hard dependencies**: M18.
- **Sequencing-only dependencies**: M19, which supplies the tableau-fed entries.
- **Lane**: Library.
- **Filed record**: `theorem_library_countermodels`.

### M21: Entries for the stability operator

- **Aim**: Populate and sweep the entries that name `⊡`, which the tableau does not reach.
- **Done when**: the collapse `φ ↔ ⊡φ` for state-local `φ` is a TM⁺ derivation; the S5 laws are
  entered for `⊡` and for `⟐` through the statement they share with `□` and `◇`; the pasting
  schemata, their consequences and the principles for `Will`, `will`, `Could` and `could` are
  entered with their substitution classes; each refutation in
  `FormalSystem/PlusLanguage/PlusNonValidities.lean` is paired with the theorem it bounds; and a
  sweep over a selection of these entries in TM⁺ produces a report with a missing-rule list.
- **Hard dependencies**: M18, and M1 for the `⊡` scopes.
- **Sequencing-only dependencies**: M3, so that the gate can hold the sweep; M8, so that the
  shared S5 statement is proved once; M20, for the pairing; M23, whose answer decides whether
  these entries are sections of the Modal fragments or fragments of their own.
- **Lane**: Library, then Evaluation.
- **Filed record**: `theorem_library_stability_entries`.

### M22: Conservativity along every edge

- **Aim**: Prove that each fragment's logic is conserved by every larger one, so that filing by
  smallest fragment is a theorem and not a convention.
- **Done when**: each edge in the conservativity table of
  [theorem-library.md](theorem-library.md) is proved, by soundness of the larger logic, a
  semantic bridge and completeness of the smaller, with the argument stated once in parametric
  form and instantiated per edge; or is refuted, with the countermodel entered; the table is
  generated from the theorems; and no theorem entry has a proof fragment larger than its
  statement fragment without a recorded reason.
- **Hard dependencies**: none for the theorems. M18 for the generated table and the check on
  entries.
- **Sequencing-only dependencies**: none. It works under `FormalSystem/Metalogic/` and edits no
  proof-mode file.
- **Lane**: Metatheory.
- **Filed record**: `theorem_library_fragment_conservativity`. Two edges
  need a completeness theorem the tree does not state, for S5 over the `□`-fragment and for the
  temporal schemata alone at each frame class, and each may be its own record.

### M23: The place of the stability operator

- **Aim**: Decide whether `⊡` belongs in the Modal family or in a family of its own.
- **Done when**: a report under `docs/development/` weighs the two layouts against the three
  facts about `⊡` in [theorem-library.md](theorem-library.md), states whether the operators of
  the Open and Nomic languages are further instances of the parameterized necessity laws,
  recommends one layout, and lists the changes to the two records and to the filed records if
  the recommendation is a separate family.
- **Hard dependencies**: none.
- **Sequencing-only dependencies**: none. M0, M8, M18 and M21 are cheaper to carry out once it
  has reported, and none waits on it: the design starts from `⊡` in Modal.
- **Lane**: Research and writing.
- **Filed record**: `investigate_stability_as_modal_family`.

## Dependency picture

Hard dependencies only.

```
M13 --+
M18 --+
M1 ---+--> M3 (gate) --+--> M4 --> M5 (gate) --+--> M8 --> M9a
M2 ---+                |      |                +--> M10 --> M11
 |                     |      +--------------------^
 |                     +--> M12                +--> M15
 +--> M14a

M18 --+--> M19   (also M13)
      +--> M20 --> M14b   (M11 for its ModelChecker half)
      +--> M21   (also M1)

No hard predecessor: M0, M1, M2, M6a, M6b, M6c, M7, M9b, M13, M16, M17, M18, M22, M23
```

Filed edges among M0 to M16, hard and sequencing together, as five streams that join at M8.

```
M0 --+--> M16 --> (M1, third record; M8)
     +--> M1 (three records) --+
     +--> M2 ------------------+--> M3 (gate) --+--> M4 --> M5 (gate) --+
     +--> M13 -----------------+                +--> M7 ----------------+
     +--> M6a ----------------------------------+--> M6b --> M6c -------+--> M8
                                                +--> M12

M8 --+--> M9a   (also after M9b, which has no predecessor)
     +--> M10 --> M11 --+
     +--> M14a ---------+--> M14b
     +--> M15
```

The library is a sixth stream beside these. M18 runs from the start and feeds M3; M19 and M20
follow it and run beside everything, since they edit `BimodalLib/` and `BimodalTools/` only; M21
follows gate one. M22 is metatheory and M23 is a report; both run from the start.

M17 has no filed record and so no filed edge. Its order is M17, then M0, then M16: M0 runs after
the open contributions are merged or declined, M17 among them, and M16 follows M0 and takes
over the view rows M17 contributes. Two other orders are rejected. Building M16 first and
rebasing M17 onto it lets the tier's owner design its surface, but it drops M16's edge on M0,
writes the tier in a layout M0 then moves, and holds a contribution on unscheduled work.
Merging M17 with `lrewrite` still handling formula equalities and separating later is the
fastest merge, and it puts one tactic name serving two tiers into the library.

What can run at once: M17, M9b, M18, M22 and M23 from the start, and M0 once M17 is merged or
declined; then M1, M2, M13, M6a and M16, with M19
and M20 once M13 and M18 have landed; after a GO verdict M4, M7, M6b then M6c, M12 and M21;
after M8 the four branches above.

M10 depends on M4 directly and through M5. The milestones with no hard predecessor:

- M0 moves files into the family layout and changes no rule.
- M1 extends the merged scope rules.
- M2 rests on `propDecide`, which is in the library.
- M6a, M6b and M6c work on the elaborators as they stand.
- M7 exposes principles the library has, behind the certificate pattern `lstep` has.
- M9b is metatheory about two calculi.
- M13 measures the merged tactics.
- M16 uses definitions only, and M17 uses rules the library has.
- M18 registers proofs that exist.
- M22 is metatheory about the fragments, and M23 is a report.

## Gates

**Gate one (M3)** keeps its criteria as filed and applies them to the gate's fixed selection of
library entries. The selection is made to test the rule set, each entry for a stated reason,
and is enlarged later only where a sweep shows something unexercised. GO requires the proof-mode scripts to be shorter than the hand proofs in
aggregate and for a clear majority of entries, with no entry needing a raw term-mode escape
longer than its hand proof. An entry whose only reference proof is extracted from the tableau
counts toward coverage and the missing-rule list and not toward the length comparison.
Otherwise the verdict is RE-PLAN: the report recommends how each later record should change, and
the work stops for user review so that no later record is dispatched on an unrevised plan.

- On GO, M4, M12 and M21 open.
- On RE-PLAN, every milestone after M3 is held until its record is revised: M4, M5, M6b, M6c,
  M7, M8, M9a, M10, M11, M12, M14a, M14b, M15 and M21. This includes M6b, M6c, M7 and M21,
  which have no hard dependency on M3 and carry an edge on it for this reason.
- M0, M6a, M9b, M13, M16, M17, M18, M19, M20, M22 and M23 do not wait on the verdict. M16 adds no
  rule: a view proves nothing. M17's tactics are outside the gate-one scripts and the verdict;
  only its second run of the selection follows the sweep. The library milestones add entries and records and no rule, M22
  is metatheory, and M23 is a report.

**Gate two (M5)** has no verdict as filed. Its output is a measured report and a missing-rule
list, each item either added in M5 or named with a proposed description. The sweep in M21 has
the same form. M8, M10 and M15 wait on
it because each takes the rule set after gate two as its input. M6c is ordered after gate one only.

Nothing in this document weakens gate one. The work that runs before the verdict is M0, M6a,
M9b, M13, M16, M17, M18, M19, M20, M22 and M23, which lie outside the measured rule set, and M1 and M2, which are the
rule set.

Every sweep is re-run by one command after any later change to the rule set. A fall in coverage
on a fragment already swept is a regression and is reported as one.

## Lanes

Six lanes, by the kind of work and the files it touches.

| Lane | Works in | Milestones |
|---|---|---|
| Rule theory | `FormalSystem/Theorems/ProofMode/` | M1, M4, M7, M8, M9a, M10 (the pure rules) |
| Elaborators | `FormalSystem/Automation/ProofMode/`, tests, guide | M0, M2, M6a, M6b, M6c, M14a, and the tactic half of M1, M4, M7, M8, M10, M14b |
| Evaluation | `BimodalLib/ProofMode/`, `BimodalLib/Diagnostics/`, `docs/development/` | M3, M5, M13, the sweep of M21, the second half of M12 |
| Library | `BimodalLib/Theorems/`, `BimodalLib/Countermodels/`, `BimodalLib/Conjectures/`, `BimodalTools/` | M18, M19, M20, the entries of M21, the lookup half of M14b |
| Metatheory | the language directories, `FormalSystem/Metalogic/` | M9b, M22, the first half of M14a |
| Research and writing | `docs/`, `typst/` | M11, M12, M14b (the ModelChecker half), M15, M23 |

M16 is Elaborators work filed outside that lane's directory: the views tier sits at layer 0 or
1, where [proof-mode-architecture.md](proof-mode-architecture.md) places it.

The finest joint is inside a milestone. Because `FormalSystem/Theorems/` cannot import
`FormalSystem/Automation/`, the pure rule for a milestone never depends on its tactic, so the
rule can land first and the tactic, tests and guide entry follow. The rule half edits only
`FormalSystem/Theorems/ProofMode/` and its README.

Every record declares a `file_scope` written against the layout M0 produces, so two records
that would collide are detected at dispatch. Three kinds of shared file remain and serialize
implementation without ordering it: the aggregator modules, the guide index and the two ProofMode
READMEs, each edited one line at a time; and the generated surfaces every Lean edit regenerates.
Research and planning are not serialized.

## Open decisions

Two questions are open. The first awaits the user's ruling; the second waits on a report.

1. **What does "default" mean for M12?** A policy on how contributors work, which the tree
   does not settle.

   | Option | What it requires | Evidence for | Evidence against |
   |---|---|---|---|
   | A | New example and case-study modules are written in the mode | `Examples/` is layer 4 and can import `FormalSystem/Automation/` | binds work outside the measure |
   | B | Every new derived theorem is registered in `BimodalLib` with a proof-mode script or a recorded failure class | `BimodalLib` sits above every layer; M12's done-when states this clause | the registry of M18 is not built |
   | C | The mode stays optional outside the library's sweeps | no burden on contributors | contradicts M12's done-when, which requires B and one module outside the tests and sweeps |

   Two facts hold whatever the ruling: proofs under `FormalSystem/Theorems/` cannot be written
   in the mode, layer 2 being below layer 3; and M12 hard-depends on a GO at gate one. The
   recommendation is B as the rule, A for `Examples/` and case studies, and
   `FormalSystem/Theorems/` exempt and said to be so, all contingent on a GO. M12's done-when
   excludes C, so the choice left is whether A is added to B. This awaits the user's ruling.
2. **Is `⊡` rightly in the Modal family?** The question of that name under "Open decisions" of
   [theorem-library.md](theorem-library.md), examined in `investigate_stability_as_modal_family`
   (M23). The records start from one family, and a recommendation for a separate family needs a
   ruling before the records change.

Four positions are taken by the filed edges and can each be reversed by changing one edge.

- **M7 before M8.** M7's rules are written twice (TM and TM⁺) and M8 then removes the copies, in
  exchange for an interface designed having seen a Dense and an RTime rule. The alternative
  writes M7 once over the interface.
- **M10 after M8.** The library's rules are proved once. The alternative starts M10 straight
  after M5 and proves each rule twice.
- **M6a before gate one; M6b, M6c and M7 after it.** M6a only tests what is merged. The other
  three add tactics that a RE-PLAN verdict could change.
- **M14a and M15 after M8.** Both name things M8 rewrites: the closer's elaborator, and the
  declaration names the chapter cites.

## Filed records

| Milestone | Record |
|---|---|
| M0 | `proof_mode_split_shared_test_and_guide_files` |
| M1 | `proof_mode_s5_aware_box_scopes`, `proof_mode_cross_modal_scopes_mf_tf`, `proof_mode_always_sometimes_scopes` |
| M2 | `proof_mode_close_leaves_with_automation` |
| M3 | `proof_mode_reprove_perpetuity` |
| M4 | `proof_mode_linearity_case_tactic`, `proof_mode_until_since_intro_unfold_induction` |
| M5 | `proof_mode_reprove_temporal_slice` |
| M6a | `proof_mode_error_message_coverage` |
| M6b | `proof_mode_nested_intro_patterns` |
| M6c | `proof_mode_goal_display` |
| M7 | `proof_mode_dense_and_real_time_rules` |
| M8 | `proof_mode_abstract_frontend_interface` |
| M9a | `proof_mode_instances_other_languages` |
| M9b | `proof_mode_deduction_theorems_star_open` |
| M10 | `proof_mode_leads_to_invariance_library` |
| M11 | `proof_mode_transition_systems_tm_specifications` |
| M12 | `proof_mode_adoption_after_perpetuity_verdict` |
| M13 | `proof_mode_axiom_audit_and_cost_baseline` |
| M14a | `proof_mode_decision_procedure_leaf_closers` |
| M14b | `proof_mode_countermodels_for_unclosed_leaves` |
| M15 | `proof_mode_reference_manual_chapter` |
| M16 | `proof_mode_views_tier` |
| M17 | none; merged |
| M18 | `theorem_library_layout_and_registry` |
| M19 | `theorem_library_tableau_pipeline` |
| M20 | `theorem_library_countermodels` |
| M21 | `theorem_library_stability_entries` |
| M22 | `theorem_library_fragment_conservativity` |
| M23 | `investigate_stability_as_modal_family` |

Each record's description states its milestone, its stream, and which of its edges are hard and
which are sequencing only.

## Using this document with the roadmap

`/roadmap` builds its picture from the open records and their dependencies. It does not read
this file unless told to. Name it in a quoted instruction when the batches should follow the
streams above:

```
/roadmap "re-batch the proof-mode records against records/proof-mode.md: keep the batch
boundary at gate one, and place records with no dependency on the gate in
their own batches"
```

Changing one of the four positions listed under Open decisions means adding or removing a filed
edge, and removal is a step the roadmap agent's contract does not cover.
