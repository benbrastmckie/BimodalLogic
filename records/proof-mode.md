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
   Gap: a TM⁺ closer, and closers built on the decision procedures in
   `FormalSystem/Metalogic/Decidability/`.
5. **Evidence and adoption.** Done: adequacy is measured against existing proofs, and real
   proofs are written in the mode. Covered by `proof_mode_reprove_perpetuity` and
   `proof_mode_reprove_temporal_slice` for the measurement. Gap: nothing says where proof-mode
   proofs live after the measurements, or which new work must use the mode.
6. **Architecture and language reach.** Done: each rule is proved once over an interface, and
   every object language with a derivation calculus has an instance or a stated reason for
   lacking one. Covered by `proof_mode_abstract_frontend_interface` and
   `proof_mode_instances_other_languages`. Gap: deduction theorems for the Star and Open
   calculi; the languages the usage guide lists as separate work (counterfactual, stored-index,
   metric).
7. **Usability.** Done: goals are readable, introduction patterns nest, every error message is
   tested, and the mode is documented in the guide and the reference manual. Covered by
   `proof_mode_goal_display_patterns_error_tests`. Gap: a reference-manual chapter, and a check
   that keeps error coverage from falling once it is complete.
8. **Specification reasoning.** Done: a library of safety and liveness rules, and a worked route
   from a transition system to a TM derivation. Covered by
   `proof_mode_leads_to_invariance_library` and
   `proof_mode_transition_systems_tm_specifications`. Gap: everything after the architecture
   report, which is left unfiled until that report exists.

Two further dimensions cut across the eight and have no filed record.

- **Trust and cost.** Done: tests state the axiom set of representative proof-mode derivations,
  and there is a baseline for the size of the derivation terms the tactics build and for their
  elaboration time. `lintro` discharges through the deduction theorem, which transforms a whole
  derivation, so cost on long scripts is an open question. Nothing has been measured.
- **Dual verification.** Done: a leaf the mode cannot close can be handed to the ModelChecker
  for a countermodel, and proof-mode scripts are available to the dataset tooling in
  `BimodalTools/`. Only the architecture report touches this, as one section.

## Milestones

Twenty milestones, M0 to M15, with M6, M9 and M14 split into parts. Each block has the same six
fields. A **hard dependency** is one without which the milestone's result cannot be stated or
proved. A **sequencing-only dependency** is an order kept for another reason: the two pieces of
work edit the same files, or running later saves rework.

The split between the two kinds is a proposed reading of the filed records' descriptions, checked
against the Lean sources where a rule is named. It is not a ruling. The filed records carry a
stricter order than the hard dependencies below: fourteen records in one chain, because each
edits `Tests/BimodalTest/Automation/ProofModeTest.lean`, the usage guide and both ProofMode
READMEs. Until M0 lands, every sequencing-only dependency binds exactly as a hard one does.

### M0: Shared-file de-contention

- **Aim**: Let two proof-mode milestones run at once without editing the same file.
- **Done when**: the acceptance tests are split into one file per tactic family under a
  `ProofMode` test directory with the 31 existing examples passing unchanged; the usage guide is
  split or sectioned so each family has its own file or clearly bounded section; and every filed
  proof-mode record declares a `file_scope`.
- **Hard dependencies**: none.
- **Sequencing-only dependencies**: none.
- **Lane**: Elaborators.
- **Filed record**: not filed.

### M1: Bimodal scope core

- **Aim**: Make the modal and bimodal interaction principles usable inside scopes.
- **Done when**: a □ scope carries `□A` and `◇A` intact on request, with the TM⁺ stability
  mirror; □ facts cross into G and H scopes by MF and TF in both time directions; always and
  sometimes have introduction, use and case rules; and the six perpetuity principles are derived
  by short scripts in the acceptance tests, citing nothing under
  `FormalSystem/Theorems/Perpetuity/`.
- **Hard dependencies**: none. The three records form an internal chain: each extends the scope
  rules the one before adds.
- **Sequencing-only dependencies**: none.
- **Lane**: Rule theory, then Elaborators.
- **Filed record**: `proof_mode_s5_aware_box_scopes`, then `proof_mode_cross_modal_scopes_mf_tf`,
  then `proof_mode_always_sometimes_scopes`.

### M2: Leaf closure

- **Aim**: Let automation close the leaves the mode leaves open.
- **Done when**: a closing tactic built on `propDecide` closes the propositional leaves in the
  acceptance tests, discharging object assumptions first; it fails with a clear message
  otherwise, including on a TM⁺ goal; it yields a native derivation only and adds no axiom.
- **Hard dependencies**: none.
- **Sequencing-only dependencies**: M1. The closer uses `propDecide` and deduction and no scope
  rule. It is ordered after M1 so that gate one measures the mode with leaves automated.
- **Lane**: Elaborators.
- **Filed record**: `proof_mode_close_leaves_with_automation`.

### M3: Gate one, Perpetuity adequacy

- **Aim**: Measure whether proof-mode scripts are shorter than the existing Perpetuity proofs.
- **Done when**: the supporting lemmas of `FormalSystem/Theorems/Perpetuity/` are re-proved in
  the mode in a module under `FormalSystem/Examples/`, alongside the originals and without citing
  them, and a report opens with an explicit GO or RE-PLAN verdict backed by per-declaration
  measurements.
- **Hard dependencies**: M1, M2. The gate measures exactly that rule set.
- **Sequencing-only dependencies**: none.
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
- **Sequencing-only dependencies**: M1 to M5. Each of those adds error sites; running later
  means one backfill instead of several.
- **Lane**: Elaborators.
- **Filed record**: `proof_mode_goal_display_patterns_error_tests` (part 1). The regression
  check is not in the filed description.

### M6b: Nested introduction patterns

- **Aim**: Let `lcases` and `lintro` take nested patterns.
- **Done when**: both tactics accept nested patterns, with tests and a guide section.
- **Hard dependencies**: none.
- **Sequencing-only dependencies**: M1 and M5, which change the same elaborator files.
- **Lane**: Elaborators.
- **Filed record**: `proof_mode_goal_display_patterns_error_tests` (part 2).

### M6c: Goal display

- **Aim**: Show named hypotheses and the object goal compactly.
- **Done when**: a goal view elides a hypothesis's object context only when it equals the goal's
  context, keeps a differing context visibly marked, and is documented in the guide.
- **Hard dependencies**: none.
- **Sequencing-only dependencies**: M5, so that the display is designed against real scripts.
- **Lane**: Elaborators.
- **Filed record**: `proof_mode_goal_display_patterns_error_tests` (part 3).

### M7: Frame coverage at Dense and RTime

- **Aim**: Expose the dense and real-time principles as proof-mode rules.
- **Done when**: DN at Dense, and PU, SEP and CO at RTime, each have a pure rule and a tactic
  whose frame certificate is solved when reflexive and otherwise shown as a goal, tested at a
  concrete and an abstract frame class in TM and TM⁺.
- **Hard dependencies**: none. `density` takes `Dense ≤ fc`, `coDerived` takes `RTime ≤ fc`,
  `prior_U_gap` and `sep` are axiom constructors at RTime, and the certificate pattern is the
  one `lstep` has.
- **Sequencing-only dependencies**: M4 and M6, as filed. Nothing in the deliverable uses an
  Until or Since rule from M4 or anything from M6.
- **Lane**: Rule theory, then Elaborators.
- **Filed record**: `proof_mode_dense_and_real_time_rules`.

### M8: One interface, rules proved once

- **Aim**: Prove each pure rule once over an object-level typeclass.
- **Done when**: TM and TM⁺ are two instances of the class; the duplicated TM⁺ rule proofs are
  deleted or reduced to instance fields; no elaborator names either language; and the acceptance
  suite passes unchanged.
- **Hard dependencies**: M5. The record says to extract the interface from the rule set as it
  stands after the adequacy tests.
- **Sequencing-only dependencies**: M7, as filed. Either order works, at different cost; see
  Open decisions.
- **Lane**: Rule theory and Elaborators together.
- **Filed record**: `proof_mode_abstract_frontend_interface`.

### M9a: Minus instance and language accounting

- **Aim**: Extend the mode to the other object languages that can support it.
- **Done when**: the Minus calculus has a proof-mode instance with acceptance tests, and every
  directory matching `FormalSystem/*Language/` is accounted for in the guide, by an instance or
  by a stated reason.
- **Hard dependencies**: M8.
- **Sequencing-only dependencies**: none.
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
- **Filed record**: not filed. M9a's record may propose it.

### M10: Safety and liveness library

- **Aim**: Provide the standard rules for invariance and leads-to.
- **Done when**: leads-to is defined as a named abbreviation with present-inclusive operators
  and related to the strict form `lprogress` uses; invariance, leads-to transitivity and
  disjunction, and finite-family well-founded progress exist as pure rules with tactics for TM
  and TM⁺; with worked examples and a guide section.
- **Hard dependencies**: M4 and M5. The library builds on the induction rule and on the
  missing-rule list.
- **Sequencing-only dependencies**: M9a, as filed. The done-when names TM and TM⁺ only and uses
  no other-language instance. M8 is optional: with it the rules are proved once, without it
  twice.
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
- **Filed record**: not filed.

### M13: Trust and cost baseline

- **Aim**: Know what proof-mode derivations depend on and what they cost.
- **Done when**: a test module asserts the axiom set of at least one derivation per tactic
  family in TM and TM⁺, on the pattern of `Tests/BimodalTest/WalkthroughAxioms.lean`; and a
  recorded baseline gives derivation-term size and elaboration time for the acceptance examples
  and for one long script with nested `lintro`, with the command that reproduces it.
- **Hard dependencies**: none.
- **Sequencing-only dependencies**: none. Landing before M3 gives the gate a cost figure.
- **Lane**: Evaluation.
- **Filed record**: not filed.

### M14a: Closers from the decision procedures

- **Aim**: Close non-propositional leaves with the proved decision procedures.
- **Done when**: it is established which procedures under `FormalSystem/Metalogic/Decidability/`
  return a derivation and not only a validity verdict; and for each that does, the leaf closer
  uses it and yields a native derivation, with tests and no `native_decide`.
- **Hard dependencies**: M2, which provides the closing tactic to extend.
- **Sequencing-only dependencies**: none.
- **Lane**: Metatheory, then Elaborators.
- **Filed record**: not filed.

### M14b: Countermodel bridge

- **Aim**: Hand an unclosed leaf to the ModelChecker.
- **Done when**: a failed leaf can be exported in a form the ModelChecker accepts, and a
  countermodel it returns is reported against the leaf. A countermodel is a diagnostic; it never
  closes a goal.
- **Hard dependencies**: M11, whose report fixes the division of labour.
- **Sequencing-only dependencies**: none.
- **Lane**: Research and writing, then Elaborators.
- **Filed record**: not filed.

### M15: Reference-manual chapter

- **Aim**: Document the mode in the paper sources.
- **Done when**: a chapter under `typst/` states the rules the tactics implement and the
  scope-safety guarantee, compiles, and passes the chapter-quality check.
- **Hard dependencies**: M5. The chapter documents the rule set as it stands after both gates.
- **Sequencing-only dependencies**: none.
- **Lane**: Research and writing.
- **Filed record**: not filed.

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
- On RE-PLAN, every filed milestone after M3 is held until its record is revised: M4, M5, M6a,
  M6b, M6c, M7, M8, M9a, M10 and M11. This includes M6 and M7, which have no hard dependency on
  M3. Running either before the verdict is possible in logic and carries the risk that a RE-PLAN
  changes it.
- M0, M9b and M13 do not wait on the verdict. They change no rule and no tactic.

**Gate two (M5)** has no verdict as filed. Its output is a measured report and a missing-rule
list, each item either added in M5 or named with a proposed description. M8, M10 and M15 wait on
it because each takes the rule set after gate two as its input. M6c is ordered after it by
preference.

Nothing in this document weakens gate one. The side branches proposed here are M0, M9b and M13,
which lie outside the measured rule set, and M2, M6 and M7 only once the user accepts the
sequencing readings.

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

The lanes are not safe to run in parallel today. Every filed record edits one test file and one
guide, and none declares a `file_scope`, so nothing can detect two records colliding. M0 is the
milestone that buys parallel lanes, and it has no predecessor.

## Open decisions

These need a ruling from the user. Nothing in this document decides them.

1. **Is the linearity case split needed for Until and Since induction?** Introduction and
   unfolding do not need it. The induction rule's formula is not stated yet, so this part of the
   edge inside M4 is undetermined. It is settled when the plan for
   `proof_mode_until_since_intro_unfold_induction` states the rule.
2. **Which of M7 and M8 goes first?** As filed, M7 comes first, so its rules are written twice
   (TM and TM⁺) and M8 then removes the copies. With M8 first, M7's rules are written once over
   the interface, but the interface is designed without having seen a Dense or RTime rule.
3. **Are the sequencing readings accepted?** Three were re-examined against the sources and read
   as sequencing only: M4 and M6 before M7; M9a before M10; and the case split before Until and
   Since introduction and unfolding. The others (M1 before M2, M1 to M5 before M6) rest on the
   records' descriptions alone.
4. **Are sequencing edges relaxed once M0 lands?** Relaxing one means removing a filed
   dependency between two records. The roadmap agent's contract covers adding edges and
   regrouping batches, not removing edges. Removal is a separate step by the user.
5. **What does "default" mean for M12?** Proofs under `FormalSystem/Theorems/` cannot be written
   in the mode. The candidates are: new example and case-study modules must use it; new derived
   theorems get a proof-mode companion under `FormalSystem/Examples/`; or the mode stays optional
   and M12 only fixes where its proofs live.
6. **Where does the Minus instance live?** Its deduction theorem is at layer 3, so either the
   instance sits at layer 3 or `FormalSystem/Metalogic/Conservativity/MinusDeduction.lean`, which
   imports only the Minus derivation module, moves down. This bears on how M8 lays out the
   interface.
7. **Does `records/` get a row in `ORGANISATION.md`?** The directory holds this document and has
   no entry in the "Everything else" table there.
8. **Do M6 and M7 run before gate one?** They have no hard dependency on it, but a RE-PLAN
   verdict may change them.

## Not yet filed

Seven milestones have no filed record. Each entry below is written to be passed to `/task` as it
stands.

**Proof mode: split the shared test and guide files (M0).** Every proof-mode record edits
`Tests/BimodalTest/Automation/ProofModeTest.lean`, `docs/user-guide/derivation-proof-mode.md`
and the READMEs in `FormalSystem/Automation/ProofMode/` and `FormalSystem/Theorems/ProofMode/`,
which forces the records into one chain. Split the acceptance tests into one file per tactic
family (basic, modal, temporal, discrete) in a new directory
`Tests/BimodalTest/Automation/ProofMode/`, keeping every existing example unchanged and
imported by `Tests/BimodalTest.lean`. Give the usage guide one clearly bounded section or file
per family. Then add a `file_scope` to every open record whose slug begins `proof_mode_`,
naming the family files it will edit. DONE WHEN: the 31 existing examples pass from the split
files, the guide's content is unchanged apart from its division, and every open proof-mode
record declares a `file_scope`. Hard dependencies: none. No Lean rule or tactic changes.

**Proof mode: deduction theorems for the Star and Open calculi (M9b).** A proof-mode instance
for an object language needs a deduction theorem, a generalized K rule per universal operator,
and context substitution. TM has them in `FormalSystem/Theorems/`, TM⁺ in
`FormalSystem/Theorems/ProofMode/PlusRules.lean`, and Minus in
`FormalSystem/Metalogic/Conservativity/MinusDeduction.lean`. `StarDerivationTree` and
`OpenDerivationTree` have none. Prove the three for each calculus, or, where one fails, write
down the rule of the calculus that blocks it. DONE WHEN: each of Star and Open has the three
results with no `sorry` and no new axiom, or a written obstruction in the usage guide. Expected
files: new modules under `FormalSystem/StarLanguage/` and `FormalSystem/OpenLanguage/`. Hard
dependencies: none. This is metatheory and needs no proof-mode interface.

**Proof mode: adoption after the Perpetuity adequacy verdict (M12).** FIRST read the adequacy
report produced by `proof_mode_reprove_perpetuity`; if its verdict is RE-PLAN, stop and report.
On GO, decide and write down in `docs/user-guide/derivation-proof-mode.md` where proof-mode
proofs live, which kinds of new derivation are to be written in the mode, and what "default"
means given that `FormalSystem/Theorems/` is below `FormalSystem/Automation/` in the layer
order and cannot import it. Then prove at least one module in the mode that is neither a test
nor an adequacy module, under `FormalSystem/Examples/`. DONE WHEN: the guide section exists and
the module builds. Hard dependency: `proof_mode_reprove_perpetuity` with a GO verdict. The
choice among the candidate meanings of "default" needs the user's ruling before implementation.

**Proof mode: axiom audit and cost baseline (M13).** No test states which axioms a proof-mode
derivation depends on, and nothing measures the derivation terms the tactics build. Add a test
module, on the pattern of `Tests/BimodalTest/WalkthroughAxioms.lean`, that asserts the axiom
set of at least one derivation per tactic family (basic, modal, temporal, discrete) in TM and
in TM⁺. Then record a baseline: derivation-term size and elaboration time for each acceptance
example and for one long script with at least five nested `lintro` steps, since `lintro`
discharges through the deduction theorem. Write the figures and the command that reproduces
them to a new file under `docs/development/`. DONE WHEN: the audit test passes in `lake test`
and the baseline file exists with its reproduction command. Hard dependencies: none. No tactic
or rule changes.

**Proof mode: leaf closers from the decision procedures (M14a).** The leaf closer added by
`proof_mode_close_leaves_with_automation` is propositional and TM-only. Research first: for
each decision procedure under `FormalSystem/Metalogic/Decidability/`, establish whether it
returns a native derivation or only a validity verdict; only the former can close a proof-mode
goal, because nothing semantic may stand in for a derivation. For each procedure that returns a
derivation, extend the leaf closer to use it on goals in its fragment. DONE WHEN: a written
table in the usage guide classifies each procedure, and each usable one closes at least one
non-propositional leaf in the tests, yielding a native derivation, with no `native_decide` and
no new axiom. Hard dependency: `proof_mode_close_leaves_with_automation`.

**Proof mode: countermodels for unclosed leaves (M14b).** This repository is paired with a
ModelChecker in a dual-verification design: derivations from one side, countermodels from the
other. Build the bridge at the point where it is most useful: a proof-mode leaf that no closer
proves. Export the leaf (context and goal formula) in a form the ModelChecker accepts, and
report a returned countermodel against the leaf. A countermodel is a diagnostic only and never
closes a goal. FIRST read the architecture report produced by
`proof_mode_transition_systems_tm_specifications` and follow its division of labour. DONE WHEN:
an export command exists with a test on a non-derivable leaf, and the usage guide documents the
round trip. Hard dependency: `proof_mode_transition_systems_tm_specifications`.

**Proof mode: reference-manual chapter (M15).** The paper sources under `typst/` do not mention
the derivation proof mode. Write a chapter that states the derivation rules the tactics
implement (context substitution, cut, generalized K for each universal operator, temporal bind
and progress, integer-time invariance, and the rules added since), the scope-safety guarantee
(a hypothesis keeps its source context in its type), and the frame restriction each rule
carries. Ground every stated rule in a named declaration under
`FormalSystem/Theorems/ProofMode/`. DONE WHEN: the chapter compiles and
`bash .claude/scripts/chapter-quality-check.sh` reports no blocking finding for it. Hard
dependency: `proof_mode_reprove_temporal_slice`, so that the chapter documents the rule set
after both adequacy measurements. Task type: typst.

## Using this document with the roadmap

`/roadmap` builds its picture from the open records and their dependencies. It does not read
this file unless told to. The document reaches the roadmap in three ways.

1. **Records filed from "Not yet filed".** Pass an entry to `/task`; the roadmap then places the
   new record in a batch like any other.
2. **A quoted instruction naming this file.** For example:

   ```
   /roadmap "re-batch the proof-mode records against records/proof-mode.md: keep the batch
   boundary at the Perpetuity adequacy gate, and place records with no hard dependency on the
   gate in a side batch"
   ```

3. **Edge changes by the user.** Relaxing a sequencing-only dependency means removing a filed
   edge, which the roadmap agent's contract does not cover. Do it after M0 lands and after open
   decision 3 is settled.

A reasonable order of use: file M0 and M13 first, since neither waits on anything; run
`/roadmap` with the instruction above; then settle the open decisions as the gates report.
