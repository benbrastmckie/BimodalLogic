# Goals, milestones and channels

This record sits above the other records. It states the goals the open work serves, the
milestones that reach each goal, what to do next, and how the work divides into two channels
that proceed in parallel without editing the same files. The detail of each milestone is in the
record that owns it: [proof-mode.md](proof-mode.md) for the derivation proof mode (its
milestones are cited here as "PM-M0" to "PM-M23"),
[proof-mode-architecture.md](proof-mode-architecture.md) for tiers and operator families, and
[theorem-library.md](theorem-library.md) for `BimodalLib`. Batch order is in `specs/ROADMAP.md`.
Work is named by slug throughout.

## Where it stands

Three stacked contributions from Tanner are open, each with changes requested:

| Contribution | Branch | Adds | What review settled |
|---|---|---|---|
| Rewriting | `feat/proof-mode-rewriting` | `lrewrite`, `lsimp`, the congruence kit | The kernel is right. Merge conditions: views split from rewriting, errors propagate, files by family |
| Temporal | `feat/proof-mode-temporal` | Until and Since introduction, folding and ZTime unfolding, `linduction`, `keeping`, time reflection, strict leads-to rules | Statements and frame gates are right; `keeping` is adopted. Split by family; the generalizing induction rule is open |
| Semantic | `feat/proof-mode-semantics` | Truth-at-a-point lemmas, transport, a semantic mode as overloads of the `l*` tactics | Not merged as it stands. The lemmas are wanted at once; the mode is re-sited as a tier of its own after a record |

Three facts fix the order of everything else.

1. **The derivation programme waits on the stack.** `proof_mode_split_shared_test_and_guide_files`
   (PM-M0) moves files the rewriting and temporal contributions edit, so it runs after each is
   merged or declined. Every pre-gate record (PM-M1, PM-M2, PM-M6a, PM-M13, PM-M16) files into the
   layout it produces. Until the stack resolves, no derivation-tier record can be implemented.
2. **The library does not wait on anything.** `theorem_library_layout_and_registry`,
   `theorem_library_fragment_conservativity`, `investigate_stability_as_modal_family`,
   `proof_mode_deduction_theorems_star_open` and `connective_signature_layer_shared_primitives`
   have no open predecessor and touch no file the stack touches, with one exception noted under
   join 4.
3. **The semantic lemmas do not wait on anything.** They are results about the semantics, they
   go under `FormalSystem/Semantics/`, and they depend on neither the tier ruling nor a record.

## What to do next

In priority order.

1. **Land the rewriting contribution on a narrowed set of merge conditions.** It is the base of
   the stack and the single blocker of the layout. The conditions that need the author's
   judgment are: rebase; the formula-equality path moved out of `lrewrite` and `lsimp` into
   `lunfold` and `lfold` over a view table, in a module that imports nothing from the rewriting
   machinery; supplied-rule errors propagate; the link from `docs/` into `specs/` removed. The
   filing requests (steps split by family, seed rules to `ModalBoolean`, one test file and one
   guide page per family) are mechanical and are carried by the layout record on the other
   channel. See open decision 1.
2. **Open the semantic lemmas as their own contribution.** It is independent of the stack's
   review, unblocks the countermodel half of the library, and is the cheapest merged result
   available.
3. **Start the library registry.** `theorem_library_layout_and_registry` is a hard dependency of
   gate one and of every later library record, and needs one ruling first (open decision 3).
4. **Land the temporal contribution**, split by family, with the carrying table agreed (join 2).
5. **Run the layout, then the pre-gate streams, to gate one.**
6. **Agree `records/semantic-proof-mode.md`**, then build the evaluator against the library's
   countermodels.

Items 1, 2 and 4 are Tanner's and items 3 and 5 are Benjamin's, so until the layout runs the
two channels share no file.

## Goals and milestones

Milestone ids are local to this record. "Channel" is T (Tanner) or B (Benjamin); "Waits on"
lists milestones here.

### Goal A: the derivation proof mode is how derivations are written

Aim and gates are in [proof-mode.md](proof-mode.md). Reached when gate two has reported and
adoption (PM-M12) holds.

| Id | Milestone | Done when | Channel | Waits on |
|---|---|---|---|---|
| A1 | Rewriting merged | The tactic half of PM-M17: `lrewrite` and `lsimp` hold logical steps only, the equality path is a views pair, rule errors reach the user | T | none |
| A2 | Temporal rules merged | Until and Since introduction, folding, ZTime unfolding, `keeping` over a carrying table, time reflection and the strict leads-to layer are in, with one frame-gate helper | T | A1 |
| A3 | Family layout | PM-M0, including the filing of everything A1 and A2 added | B | A1, A2 |
| A4 | Views tier | PM-M16: one view table, taking over the rows A1 contributes | B | A3 |
| A5 | Scope core, leaf closure, error coverage, cost baseline | PM-M1, PM-M2, PM-M6a, PM-M13 | B | A3; A4 for the always and sometimes record |
| A6 | Gate one | PM-M3: the report opens with GO or RE-PLAN | B | A5, B1 |
| A7 | Until and Since induction rule | The generalizing rule of PM-M4 is derived at `ZTime` as a pure rule with `forwardInvariantRule` an instance, or its proposed statement is refuted and replaced | T | none for the pure rule |
| A8 | Linear-time and frame rules | The rest of PM-M4 and PM-M7: linearity cases, `linvariant` through the induction rule, Dense and RTime rules | T | A6 with GO, A7 |
| A9 | Usability | PM-M6b, PM-M6c: nested patterns, goal display | B | A6 |
| A10 | Gate two | PM-M5: measured report and missing-rule list | B | A8, B3 |
| A11 | Second run with rewriting | The gate-one selection re-run with `lrewrite` and `lsimp` permitted, reported apart from the verdict | T scripts, B report | A6 |

A7 is the most valuable open mathematical item on the derivation side. Its pure rule sits under
`FormalSystem/Theorems/ProofMode/` at layer 2, imports no tactic, and can be derived while the
stack is in review.

### Goal B: `BimodalLib` is the evidence base

Aim and design are in [theorem-library.md](theorem-library.md).

| Id | Milestone | Done when | Channel | Waits on |
|---|---|---|---|---|
| B1 | Registry | PM-M18, `theorem_library_layout_and_registry` | B | open decision 3 |
| B2 | Conservativity and the place of `⊡` | PM-M22 and PM-M23: `theorem_library_fragment_conservativity`, `investigate_stability_as_modal_family` | B | none; the generated table waits on B1 |
| B3 | Tableau pipeline | PM-M19, `theorem_library_tableau_pipeline` | B | B1, the diagnostics half of A5 |
| B4 | Countermodel library | PM-M20, `theorem_library_countermodels`, each refutation checked | B | B1, B3; C3 for the evaluator-checked entries |
| B5 | Stability entries | PM-M21, `theorem_library_stability_entries` | B | A6, B4, D2 |

### Goal C: the semantic tier has its own automation

Satisfaction, `TruthAt M τ t A`, has no proof-theoretic counterpart. The tier's aim is an
evaluator for it and the checked refutations that follow, in a directory of its own under
`FormalSystem/Semantics/`, sharing only the views tier and the position and polarity planner
with the derivation mode, and meeting it in one soundness adapter under
`FormalSystem/Metalogic/`. No record owns this yet; C2 creates it.

| Id | Milestone | Done when | Channel | Waits on |
|---|---|---|---|---|
| C1 | Semantic lemmas | Covering-time Next and Previous, G/H persistence, F/P bind, the inclusive and weak Until and Since clauses, `rank_progress` and the transport structures are merged under `FormalSystem/Semantics/` with tests | T | none |
| C2 | Record agreed | `records/semantic-proof-mode.md` states the aim, the declarations the mode shortens, the measure and the milestones, and both collaborators accept it | B drafts, T reviews | none; better after C1 |
| C3 | Evaluator | Truth of an arbitrary formula at a named point of a named model is decided by recursion on the formula; the refutations in `PlusNonValidities.lean` and `StarNonValidities.lean` are re-done with it and compared with a control run using the lemmas alone | T | C1, C2 |
| C4 | Semantic mode and adapter | Own prefix and registry, no handler on `l*` syntax, no import of `FormalSystem/Automation/ProofMode/`; the adapter is the one module where the modes meet | T | C3, A4 |

### Goal D: TM and TM⁺ are instances, not copies

| Id | Milestone | Done when | Channel | Waits on |
|---|---|---|---|---|
| D1 | Signature layer | `connective_signature_layer_shared_primitives`: one class per primitive, the eighteen doubled derived operators written once | B | none; lands in the window of join 4 |
| D2 | One interface | PM-M8, `proof_mode_abstract_frontend_interface`: each rule proved once, the congruence kit and the single S5 step over `□` and `⊡` as its first generic pieces | assigned at gate two | A10, D1, A9 |
| D3 | Other languages | PM-M9b then PM-M9a: `proof_mode_deduction_theorems_star_open`, `proof_mode_instances_other_languages` | B | none for the deduction theorems; D2 for the instances |

### Goal E: specification reasoning and dual verification

PM-M10, PM-M11, PM-M14a, PM-M14b, PM-M15. All wait on D2. The leads-to library (PM-M10) builds
on the strict layer A2 contributes and is the natural continuation of channel T; the refutation
of unclosed leaves (PM-M14b) is where C3 and B4 meet the derivation mode. Not divided further
until gate two reports.

### Goal F: the metalogic fronts

One channel, B, outside the collaboration and outside every directory above. Listed so that the
picture is whole.

| Front | Head record that can run | Held by |
|---|---|---|
| L-plus decidability at integer time | `determinization_free_progress_measure_design`, `dense_time_certificate_dichotomy_gate` | `ladder_realization_theorem` rests behind a depth-0 gate no record owns; a ruling |
| Tableau decidability engine | none | `engine_totality_at_a_quantified_branch_budget` needs its scope ruled |
| Algebraic representation and MF rigidity | `ground_algebraic_representation_in_goldblatt_and_brv` | nothing; the chain to `formalize_mf_correspondence_rigidity` is serial |
| Hygiene | `support_zstd_compressed_jsonl_datasets` | the dataset chain waits on compute approval and a token |

The algebraic chain is self-contained metatheory with a ready head. It is the candidate for a
second line on channel T should the semantic tier stall on C2.

## Channels

The division follows the tier and family boundaries, so that after A3 the two channels own
different modules by name.

| | Channel T | Channel B |
|---|---|---|
| Tiers | Derivation (Temporal family, rewriting), Semantic | Views, Derivation (Boolean and Modal families), the library, evaluation |
| Directories | the `Temporal*` and rewriting modules of both ProofMode directories; `FormalSystem/Semantics/` | the `Boolean*` and `Modal*` modules; the views modules; `FormalSystem/Syntax/`; `BimodalLib/`; `BimodalTools/`; `docs/development/` |
| Works by | pull requests | filed records |
| Does not do | sweeps and gate reports on its own rules | rules in the Temporal family |

The author of a rule set does not write the report that measures it: channel B fixes each gate's
selection before any script exists, and channel T's rules are measured at gate two.

Order within each channel:

| Phase | Channel T | Channel B |
|---|---|---|
| While the stack is in review | A1; C1; A7 (pure rule) | B1; B2; D3 (deduction theorems); D1 research and plan; C2 draft; research and planning for A3 to A5 |
| Rewriting merged | A2 | D1 implementation |
| Temporal merged | C3 | A3, then A4 and A5 in their five streams; B3, B4 |
| Gate one | scripts for A11 | A6 |
| After GO | A8; C4 | A9; B5; A10 |

## Joins

The places where the channels meet, each with the agreement it needs.

1. **Stack into layout.** A3 runs after A1 and A2 are merged or declined and files what they
   added. Channel T leaves module placement to it; channel B changes no statement, proof or
   tactic behaviour while moving.
2. **One carrying table.** `keeping` carries `G` and `H` facts (A2); `□` facts carried by 4, 5,
   MF and TF are rows of the same table, added by `proof_mode_s5_aware_box_scopes` and
   `proof_mode_cross_modal_scopes_mf_tf` (A5). The table's shape is fixed in A2, before A5 adds
   rows. `ModalTemporalBoolean` is the one interaction both channels file into; rows are added
   one at a time and neither channel restructures it alone.
3. **One view table.** A1 contributes its first rows, A4 owns the tier. The position and polarity
   planner sits beside it, proof-free, and is what C4 shares.
4. **Signature layer window.** D1 rewrites the derived operators in `FormalSystem/Syntax/Formula.lean`
   and `FormalSystem/PlusLanguage/Formula.lean`, which every contribution reads. It is
   implemented after A1 merges and before A2 is rebased, so that the stack is rebased over it
   once. The single S5 step asked of A1 is stated over the necessity operator as a field and
   needs nothing from D1.
5. **Gate one admission.** Of channel T's rules only `G`/`H` carrying and whole-judgment time
   reflection may appear in gate-one scripts, each only once adopted into PM-M1 before the
   selection is fixed. `lrewrite` and `lsimp` are measured by A11.
6. **Evaluator and countermodels.** C3's client is B4. The record of C2 names the declarations;
   B4 states the grade at which an evaluator-checked refutation is admitted.
7. **The adapter.** `luse_derivation` and the soundness lemma live in one module under
   `FormalSystem/Metalogic/`, in the sound direction only. It is written with C4 and reviewed by
   channel B.

## Open decisions

1. **Which requests on the rewriting contribution are conditions of merging?** The option
   recommended above makes four conditions (rebase, views split, error propagation, the `specs/`
   link) and carries the filing by family in A3. Its merit is that the layout stops waiting on
   mechanical work by the contributor. The alternative keeps every request as a condition; its
   merit is that nothing lands in a layout that A3 then moves, and its cost is that A3 and all
   of A4 to A6 wait on it. The single S5 step, the option-exposed budgets, the `#guard_msgs`
   tests and a named client are either conditions or follow-ups under the same choice; the
   recommendation is conditions for the S5 step and the message tests, follow-ups for the rest.
   Benjamin's ruling, then stated on the contribution.
2. **Who writes `records/semantic-proof-mode.md` first?** Benjamin drafts and Tanner takes it
   apart, or the reverse. The recommendation is the former, written after C1 is open so that it
   cites merged lemma names. Tanner's choice.
3. **Is `BimodalLib` in `defaultTargets`?** Open decision of
   `theorem_library_layout_and_registry`; it holds B1's implementation.
4. **Evaluator with the lemmas or in a mode of its own?** Whether C3 is a decision procedure
   under `FormalSystem/Semantics/` beside the lemmas, with C4 a thin tactic layer over it, or
   the two are one module. The table above assumes the former. Settled in C2.
5. **`expand` and `contract` for the Until and Since steps.** Open decision 2 of
   [proof-mode-architecture.md](proof-mode-architecture.md); it should be ruled before A2 merges,
   since A2 introduces the keywords.
6. **Who builds the interface (D2)?** It rewrites both channels' rule modules and nothing else
   may edit the ProofMode directories beside it. Assigned when gate two reports, to whichever
   channel is then free, with the other reviewing.
