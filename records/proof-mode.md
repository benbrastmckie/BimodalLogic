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
