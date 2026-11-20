# Derivation proof mode: goals and milestones

This is a goals document for the derivation proof mode. It states the aim, what is merged, the
directions still to develop, and a set of milestones with the dependencies between them. It is
not a schedule: batch order and batch rationale live in `specs/ROADMAP.md`.

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
- **No axiom audit.** No test states which axioms a proof-mode derivation depends on, though
  `Tests/BimodalTest/WalkthroughAxioms.lean` shows the pattern for other proofs.
- **Thin error testing.** 65 error sites against 2 negative tests, neither checking the message.
- **No reference-manual coverage.** The paper sources do not mention the mode.
- **Two copies of every rule.** Each rule is proved once for TM and once for TM⁺.

One structural fact shapes the work ahead. `ORGANISATION.md` places `FormalSystem/Theorems/` at
layer 2 and `FormalSystem/Automation/` and `FormalSystem/Metalogic/` at layer 3, and each layer
imports downward. No file under `FormalSystem/Theorems/` imports `FormalSystem.Automation`. So a
pure rule can never depend on a tactic, proofs under `FormalSystem/Theorems/` cannot be written
in the proof mode, and proof-mode proofs belong at layer 3 or above: `FormalSystem/Examples/`,
the tests, or a new directory.

## Dimensions

Each dimension below gives a done-state, the filed records that cover it (named by slug), and
the gap.

1. **Bimodal scope rules.** Done: every TM interaction principle (modal 4 and 5, MF, TF, the
   always and sometimes operators) is usable inside a scope without leaving the mode. Covered by
   `proof_mode_s5_aware_box_scopes`, `proof_mode_cross_modal_scopes_mf_tf` and
   `proof_mode_always_sometimes_scopes`. Gap: none identified.
2. **Linear-time rules.** Done: a three-way linearity case split, and introduction, unfolding
   and induction for Until and Since. Covered by `proof_mode_linearity_case_tactic` and
   `proof_mode_until_since_intro_unfold_induction`. Gap: whatever the temporal adequacy report
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
5. **Evidence and adoption.** Done: adequacy is measured against existing proofs, and real
   proofs are written in the mode. Covered by `proof_mode_reprove_perpetuity` and
   `proof_mode_reprove_temporal_slice` for the measurement. Where proof-mode
   proofs live and which new work must use the mode is covered by
   `proof_mode_adoption_after_perpetuity_verdict`. Gap: none identified.
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

- **Trust and cost.** Done: tests state the axiom set of representative proof-mode derivations,
  and there is a baseline for the size of the derivation terms the tactics build and for their
  elaboration time. `lintro` discharges through the deduction theorem, which transforms a whole
  derivation, so cost on long scripts is an open question. Covered by
  `proof_mode_axiom_audit_and_cost_baseline`.
- **Dual verification.** Done: a leaf the mode cannot close can be handed to the ModelChecker
  for a countermodel, and proof-mode scripts are available to the dataset tooling in
  `BimodalTools/`. The countermodel half is covered by
  `proof_mode_countermodels_for_unclosed_leaves`, after the architecture report; the dataset
  half has no filed record.

## Milestones

Twenty milestones, M0 to M15, with M6, M9 and M14 split into parts. Each block has the same six
fields. A **hard dependency** is one without which the milestone's result cannot be stated or
proved. A **sequencing-only dependency** is an order kept for another reason: the two pieces of
work edit the same files, or running later saves rework.

Every milestone has a filed record, and the filed dependency edges are exactly the hard
dependencies plus the sequencing-only dependencies listed in each block. A sequencing edge is
filed for one of three reasons: two records edit the same family files, the later record is
cheaper once the earlier has landed, or an adequacy gate should be able to hold the record. No
edge is filed merely because two records touch the test suite or the guide: M0 gives each tactic
family its own test file and guide page, and every record declares a `file_scope`.

### M0: Shared-file de-contention

- **Aim**: Let two proof-mode milestones run at once without editing the same file.
- **Done when**: the acceptance tests are split into one file per tactic family under a
  `ProofMode` test directory with the 31 existing examples passing unchanged; the usage guide is
  split or sectioned so each family has its own file or clearly bounded section; and every filed
  proof-mode record declares a `file_scope`.
- **Hard dependencies**: none.
- **Sequencing-only dependencies**: none.
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
  then `proof_mode_always_sometimes_scopes`.

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

### M3: Gate one, Perpetuity adequacy

- **Aim**: Measure whether proof-mode scripts are shorter than the existing Perpetuity proofs.
- **Done when**: the supporting lemmas of `FormalSystem/Theorems/Perpetuity/` are re-proved in
  the mode in a module under `FormalSystem/Examples/`, alongside the originals and without citing
  them, and a report opens with an explicit GO or RE-PLAN verdict backed by per-declaration
  measurements.
- **Hard dependencies**: M1, M2. The gate measures exactly that rule set.
- **Sequencing-only dependencies**: M13, so that the gate report can quote a cost figure.
- **Lane**: Evaluation.
- **Filed record**: `proof_mode_reprove_perpetuity`.

### M4: Linear-time rules

- **Aim**: Give the mode linearity reasoning and full Until and Since rules.
- **Done when**: a tactic opens the three ordered cases for two eventualities or two Until or
  Since facts, in both time directions and both languages; Until and Since have introduction,
  one-step unfolding at `ZTime`, and an induction rule of which `forwardInvariantRule` is an
  instance; and `linvariant` is expressed through that induction rule.
- **Hard dependencies**: M3 with a GO verdict. Both records read the gate-one report first.
- **Sequencing-only dependencies**: inside M4, the case split is filed before the Until and
  Since rules. For introduction and unfolding this is sequencing only: the principles they rest on
  (`left_mono_until_G`, `unfoldForward`, `unfoldBackward`, `unfoldBackwardSince`) take no
  linearity premise. For the induction rule it is undetermined, because the rule's formula is
  not yet stated.
- **Lane**: Rule theory, then Elaborators.
- **Filed record**: `proof_mode_linearity_case_tactic`, then
  `proof_mode_until_since_intro_unfold_induction`.

### M5: Gate two, temporal slice

- **Aim**: Measure the temporal rule set against existing proofs and list what it lacks.
- **Done when**: a slice fixed in advance (at least four declarations from each of
  `FormalSystem/Theorems/TemporalDerived.lean`, `FormalSystem/Theorems/ConnectDerived.lean` and
  `FormalSystem/Theorems/LinearityDerived.lean`, including `tempLinearity`) is re-proved in the
  mode, and a report gives the same measurements as gate one plus every missing rule, each
  either added or named with a proposed follow-up description.
- **Hard dependencies**: M4. The slice includes a linearity proof and Until proofs.
- **Sequencing-only dependencies**: none.
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
  `FormalSystem/Metalogic/Conservativity/MinusDeduction.lean`, at layer 3, so the instance cannot
  sit under `FormalSystem/Theorems/` as the TM and TM⁺ rules do.

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
- **Filed record**: `proof_mode_leads_to_invariance_library`.

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
- **Done when**: the guide states where proof-mode proofs live, which kinds of new derivation
  are to be written in the mode, and what "default" means given the layer order; and at least
  one module outside the tests and the two adequacy modules is proved in the mode.
- **Hard dependencies**: M3 with a GO verdict.
- **Sequencing-only dependencies**: none.
- **Lane**: Research and writing, then Evaluation.
- **Filed record**: `proof_mode_adoption_after_perpetuity_verdict`.

### M13: Trust and cost baseline

- **Aim**: Know what proof-mode derivations depend on and what they cost.
- **Done when**: a test module asserts the axiom set of at least one derivation per tactic
  family in TM and TM⁺, on the pattern of `Tests/BimodalTest/WalkthroughAxioms.lean`; and a
  recorded baseline gives derivation-term size and elaboration time for the acceptance examples
  and for one long script with nested `lintro`, with the command that reproduces it.
- **Hard dependencies**: none.
- **Sequencing-only dependencies**: M0, for the test layout. M3 is ordered after it.
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

### M14b: Countermodel bridge

- **Aim**: Hand an unclosed leaf to the ModelChecker.
- **Done when**: a failed leaf can be exported in a form the ModelChecker accepts, and a
  countermodel it returns is reported against the leaf. A countermodel is a diagnostic; it never
  closes a goal.
- **Hard dependencies**: M11, whose report fixes the division of labour.
- **Sequencing-only dependencies**: M14a, so that an unclosed leaf is measured against the full closer.
- **Lane**: Research and writing, then Elaborators.
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

## Dependency picture

Hard dependencies only.

```
M1 --+
     +--> M3 (gate) --+--> M4 --> M5 (gate) --+--> M8 --> M9a
M2 --+                |      |                +--> M10 --> M11 --> M14b
 |                    |      +--------------------^
 |                    +--> M12                +--> M15
 +--> M14a

No hard predecessor: M0, M1, M2, M6a, M6b, M6c, M7, M9b, M13
```

Filed edges, hard and sequencing together, as five streams that join at M8.

```
M0 --+--> M1 (three records) --+
     +--> M2 ------------------+--> M3 (gate) --+--> M4 --> M5 (gate) --+
     +--> M13 -----------------+                +--> M7 ----------------+
     +--> M6a ----------------------------------+--> M6b --> M6c -------+--> M8
                                                +--> M12

M8 --+--> M9a   (also after M9b, which has no predecessor)
     +--> M10 --> M11 --+
     +--> M14a ---------+--> M14b
     +--> M15
```

What can run at once: M0 and M9b from the start; then M1, M2, M13 and M6a; after a GO verdict
M4, M7, M6b then M6c, and M12; after M8 the four branches above.

M10 depends on M4 directly and through M5. The milestones with no hard predecessor:

- M0 restructures tests and documentation and needs no rule.
- M1 extends the merged scope rules.
- M2 rests on `propDecide`, which is in the library.
- M6a, M6b and M6c work on the elaborators as they stand.
- M7 exposes principles the library has, behind the certificate pattern `lstep` has.
- M9b is metatheory about two calculi.
- M13 measures the merged tactics.

## Gates

**Gate one (M3)** is kept exactly as filed. GO requires the proof-mode scripts to be shorter in
aggregate and for a clear majority of declarations, with no declaration needing a raw term-mode
escape longer than its original. Otherwise the verdict is RE-PLAN: the report recommends how
each later record should change, and the work stops for user review so that no later record is
dispatched on an unrevised plan.

- On GO, M4 and M12 open.
- On RE-PLAN, every milestone after M3 is held until its record is revised: M4, M5, M6b, M6c,
  M7, M8, M9a, M10, M11, M12, M14a, M14b and M15. This includes M6b, M6c and M7, which have no
  hard dependency on M3 and carry a filed edge on it for this reason.
- M0, M6a, M9b and M13 do not wait on the verdict. They change no rule and no tactic.

**Gate two (M5)** has no verdict as filed. Its output is a measured report and a missing-rule
list, each item either added in M5 or named with a proposed description. M8, M10 and M15 wait on
it because each takes the rule set after gate two as its input. M6c is ordered after gate one only.

Nothing in this document weakens gate one. The work that runs before the verdict is M0, M6a,
M9b and M13, which lie outside the measured rule set, and M1 and M2, which are the rule set.

## Lanes

Five lanes, by the kind of work and the files it touches.

| Lane | Works in | Milestones |
|---|---|---|
| Rule theory | `FormalSystem/Theorems/ProofMode/` | M1, M4, M7, M8, M9a, M10 (the pure rules) |
| Elaborators | `FormalSystem/Automation/ProofMode/`, tests, guide | M0, M2, M6a, M6b, M6c, M14a, and the tactic half of M1, M4, M7, M8, M10, M14b |
| Evaluation | `FormalSystem/Examples/`, `docs/development/` | M3, M5, M13, the second half of M12 |
| Metatheory | the language directories, `FormalSystem/Metalogic/` | M9b, the first half of M14a |
| Research and writing | `docs/`, `typst/` | M11, M12, M14b (design), M15 |

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

These need a ruling from the user. Nothing in this document decides them.

1. **Is the linearity case split needed for Until and Since induction?** Introduction and
   unfolding do not need it. The induction rule's formula is not stated yet, so this part of the
   edge inside M4 is undetermined. It is settled when the plan for
   `proof_mode_until_since_intro_unfold_induction` states the rule.
2. **What does "default" mean for M12?** Proofs under `FormalSystem/Theorems/` cannot be written
   in the mode. The candidates are: new example and case-study modules must use it; new derived
   theorems get a proof-mode companion under `FormalSystem/Examples/`; or the mode stays optional
   and M12 only fixes where its proofs live.
3. **Where does the Minus instance live?** Its deduction theorem is at layer 3, so either the
   instance sits at layer 3 or `FormalSystem/Metalogic/Conservativity/MinusDeduction.lean`, which
   imports only the Minus derivation module, moves down. This bears on how M8 lays out the
   interface.
4. **Does `records/` get a row in `ORGANISATION.md`?** The directory holds this document and has
   no entry in the "Everything else" table there.

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

Each record's description states its milestone, its stream, and which of its edges are hard and
which are sequencing only.

## Using this document with the roadmap

`/roadmap` builds its picture from the open records and their dependencies. It does not read
this file unless told to. Name it in a quoted instruction when the batches should follow the
streams above:

```
/roadmap "re-batch the proof-mode records against records/proof-mode.md: keep the batch
boundary at the Perpetuity adequacy gate, and place records with no dependency on the gate in
their own batches"
```

Changing one of the four positions listed under Open decisions means adding or removing a filed
edge, and removal is a step the roadmap agent's contract does not cover.
