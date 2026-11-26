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

A review round has reported on all five of Tanner's pull requests. One is merged; the other four
each have a stated path to landing.

| Contribution | Branch | Adds | State |
|---|---|---|---|
| Rewriting | `feat/proof-mode-rewriting` | `lrewrite` and `lsimp` holding logical steps only, the formula-equality path exposed as the views pair `lunfold` and `lfold` over a view table under `FormalSystem/Tactic/`, congruence steps, seed rules, tests and guide pages filed by operator family | Merged |
| Temporal | `feat/proof-mode-temporal` | Until and Since introduction, folding and ZTime unfolding, `linduction`, `keeping`, time reflection, strict leads-to rules | Open. Rebased onto `main` and re-reviewed at `5ecc91d63`; two small conditions of merging remain, the carrying table's key and visibility and the split of one acceptance example in `ProofModeTest.lean`. The `expand`/`contract` naming for the one-step rules is ruled — the contribution uses the two words throughout; the architecture record's own open decision on the point closes once this contribution merges |
| Semantic lemmas | `feat/pointed-semantic-lemmas` | Covering-time Next and Previous, G/H persistence, F/P witnesses, inclusive and weak Until and Since, `rank_progress`, pointed transport | Open, changes requested, with three posted conditions of merging: a rebase onto `main` with the generated files regenerated rather than hand-resolved, the `At` abbreviation made usable in tactic proofs, and tests for the untested lemmas plus one transport factory per family |
| Semantic record | `docs/semantic-proof-mode-record` | `records/semantic-proof-mode.md`: an evaluator for pointed truth and falsity, its countermodel clients, its measure | Open. Agrees with the other records on every point checked; three additions are asked before merging, an `## Open decisions` section, a stated adoption threshold, and two sentences of scope on why the evaluator has clients and what gap remains |
| Semantic mode | `feat/proof-mode-semantics` | A semantic mode as overloads of the `l*` tactics, and a soundness adapter | Open, recommended for closure. Its rewriting, lemmas and record are now carried by the other four contributions; what is its own is the rejected overload layer and `FormalSystem/Metalogic/ProofModeSoundness.lean`, which is reusable as written and returns with the fresh pull request the mode is asked to come back as |

Three facts fix the order of everything else.

1. **The derivation programme waits on the temporal contribution.**
   `proof_mode_split_shared_test_and_guide_files` (PM-M0) moves files that contribution edits, so
   it runs after it is merged or declined. Every pre-gate record (PM-M1, PM-M2, PM-M6a, PM-M13,
   PM-M16) files into the layout it produces. Until then no derivation-tier record can be
   implemented.
2. **The library does not wait on anything.** `theorem_library_layout_and_registry`,
   `theorem_library_fragment_conservativity`, `investigate_stability_as_modal_family`,
   `proof_mode_deduction_theorems_star_open` and `connective_signature_layer_shared_primitives`
   have no open predecessor and touch no file the temporal contribution touches, with one
   exception noted under join 4.
3. **The semantic lemmas do not wait on anything.** They are results about the semantics, they
   go under `FormalSystem/Semantics/`, and they depend on neither the tier ruling nor a record.

## What to do next

In priority order.

1. **Land the temporal contribution.** It is the single blocker of the layout. It is rebased onto
   `main` and re-reviewed at `5ecc91d63`; it merges once the carrying table's key is widened to
   `(source, target)` and made non-private (join 2), and once the one altered acceptance example
   in `ProofModeTest.lean` is split into the two cases it used to cover.
2. **Land the semantic lemmas.** They are independent of the temporal review, unblock the
   countermodel half of the library, and are the cheapest merged result available. The point
   that needs the author's judgment is `At`: either clause lemmas are restated at its level or
   it is documented as a statement vehicle only.
3. **Start the library registry.** `theorem_library_layout_and_registry` is a hard dependency of
   gate one and of every later library record, and needs one ruling first (open decision 1).
4. **Agree `records/semantic-proof-mode.md`**: an open-decisions section, a stated threshold for
   adopting the evaluator, and the reason the evaluator has clients at all, which is that the
   tableau does not reach `⊡`.
5. **Run the layout, then the pre-gate streams, to gate one.**
6. **Build the evaluator** against the library's countermodels.

Items 1, 2 and 6 are Tanner's, items 3 and 5 are Benjamin's and item 4 is joint, so until the
layout runs the two channels share no file.

## Goals and milestones

Milestone ids are local to this record. "Channel" is T (Tanner) or B (Benjamin), or "either"
where the milestone is open to whoever claims it and the "Done when" column is the standard;
"Waits on" lists milestones here.

### Goal A: the derivation proof mode is how derivations are written

Aim and gates are in [proof-mode.md](proof-mode.md). Reached when gate two has reported and
adoption (PM-M12) holds.

| Id | Milestone | Done when | Channel | Waits on |
|---|---|---|---|---|
| A1 | Rewriting merged | Reached. The tactic half of PM-M17: `lrewrite` and `lsimp` hold logical steps only, the equality path is a views pair, rule errors reach the user | T | none |
| A2 | Temporal rules merged | Until and Since introduction, folding, ZTime unfolding, `keeping` over a carrying table, time reflection and the strict leads-to layer are in, with one frame-gate helper | T | none |
| A3 | Family layout | PM-M0. A1 and A2 file their own rules, tests and guide pages by family, so what moves is what predates them: the shared guide, both ProofMode READMEs and the `Meta`, `Modal` and `Temporal` tactic modules | B | A2 |
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
temporal contribution is in review.

### Goal B: `BimodalLib` is the evidence base

Aim and design are in [theorem-library.md](theorem-library.md).

| Id | Milestone | Done when | Channel | Waits on |
|---|---|---|---|---|
| B1 | Registry | PM-M18, `theorem_library_layout_and_registry` | B | open decision 1 |
| B2 | Conservativity and the place of `⊡` | PM-M22 and PM-M23: `theorem_library_fragment_conservativity`, `investigate_stability_as_modal_family` | B | none; the generated table waits on B1 |
| B3 | Tableau pipeline | PM-M19, `theorem_library_tableau_pipeline` | B | B1, the diagnostics half of A5 |
| B4 | Countermodel library | PM-M20, `theorem_library_countermodels`, each refutation checked | B | B1, B3; C3 for the evaluator-checked entries |
| B5 | Stability entries | PM-M21, `theorem_library_stability_entries` | B | A6, B4, D2 |

### Goal C: the semantic tier has its own automation

Satisfaction, `TruthAt M τ t A`, has no proof-theoretic counterpart. The tier's aim is an
evaluator for it and the checked refutations that follow, in a directory of its own under
`FormalSystem/Semantics/`, sharing only the views tier and the position and polarity planner
with the derivation mode, and meeting it in one soundness adapter under
`FormalSystem/Metalogic/`. The evaluator sits under that directory beside the semantic lemmas,
with the semantic mode, C4, a thin tactic layer over it, rather than the two as one module. The
record that owns it is [semantic-proof-mode.md](semantic-proof-mode.md); C2 is its acceptance.

| Id | Milestone | Done when | Channel | Waits on |
|---|---|---|---|---|
| C1 | Semantic lemmas | Covering-time Next and Previous, G/H persistence, F/P bind, the inclusive and weak Until and Since clauses, `rank_progress` and the transport structures are merged under `FormalSystem/Semantics/` with tests | T | none |
| C2 | Record agreed | `records/semantic-proof-mode.md` states the aim, the declarations the mode shortens, the measure and the milestones, and both collaborators accept it | T drafts, B reviews | none; better after C1 |
| C3 | Evaluator | Truth or falsity of a formula at a named point of a named model is proved by recursion on the formula's truth clauses, from witnesses the caller supplies; it checks evidence and is not a decision procedure; the refutations in `PlusNonValidities.lean` and `StarNonValidities.lean` are re-done with it and compared with a control run using the lemmas alone | T | C1, C2 |
| C4 | Semantic mode and adapter | Own prefix and registry, no handler on `l*` syntax, no import of `FormalSystem/Automation/ProofMode/`; the adapter is the one module where the modes meet | T | C3, A4, D4 |

### Goal D: TM and TM⁺ are instances, not copies

| Id | Milestone | Done when | Channel | Waits on |
|---|---|---|---|---|
| D1 | Signature layer | `connective_signature_layer_shared_primitives`: one class per primitive, the seventeen doubled derived operators written once, with `Formula`, `PlusFormula` and `StarFormula` as instances; the inclusive and weak Until and Since, Release and Trigger defined once on the signature, with the interval clause lemmas of C1 stated about them; one `next` and `prev` encoding; operator recognition in `FormalSystem/Tactic/FormulaSyntax.lean` reads the signature and so reaches L⋆ | B | none; lands in the window of join 4 |
| D2 | One interface | PM-M8, `proof_mode_abstract_frontend_interface`: each rule proved once, the congruence kit and the single S5 step over `□` and `⊡` as its first generic pieces | assigned at gate two | A10, D1, A9 |
| D3 | Other languages | PM-M9b then PM-M9a: `proof_mode_deduction_theorems_star_open`, `proof_mode_instances_other_languages` | B | none for the deduction theorems; D2 for the instances |
| D4 | One soundness statement | `soundness_statement_over_truth_env`: pointed soundness with premises holds for TM, TM⁺ and TM⋆, the TM⋆ case being a new theorem beside `star_soundness_validIn`; it is stated once over `TruthEnv`, each language an instance; no module restates a language's soundness theorem under another name | either | none |

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
| Rewriting merged, temporal not yet | A2; C1; A7 (pure rule); C2 revisions | B1; B2; D3 (deduction theorems); D1; C2 review; research and planning for A3 to A5 |
| Temporal merged | C3 | A3, then A4 and A5 in their five streams; B3, B4 |
| Gate one | scripts for A11 | A6 |
| After GO | A8; C4 | A9; B5; A10 |

## Joins

The places where the channels meet, each with the agreement it needs.

1. **Temporal into layout.** A3 runs after A2 is merged or declined. Channel T files its own
   rules, tests and guide pages by family; A3 moves the shared files that predate the
   contributions, and channel B changes no statement, proof or tactic behaviour while moving.
2. **One carrying table.** `keeping` carries `G` and `H` facts (A2); `□` facts carried by 4, 5,
   MF and TF are rows of the same table, added by `proof_mode_s5_aware_box_scopes` and
   `proof_mode_cross_modal_scopes_mf_tf` (A5). A row is a `CarryRule` keyed by
   `(source, target)` — the operator of the fact carried and the scope entered — with the
   `(TM, TM⁺)` rule pair as its value and a `framed` flag for a row taking a leading
   `FrameClass.ZTime ≤ fc` certificate. The table, `carryRules`, is public in
   `Automation/ProofMode/Carrying.lean`, which both tactic families import. `ModalTemporalBoolean` is the one
   interaction both channels file into; rows are added one at a time and neither channel
   restructures it alone.
3. **One view table.** A1 contributes its first rows, A4 owns the tier. The position and polarity
   planner sits beside it, proof-free, and is what C4 shares.
4. **Signature layer window.** D1 rewrites the derived operators in `FormalSystem/Syntax/Formula.lean`
   and `FormalSystem/PlusLanguage/Formula.lean`, which every contribution reads. Its window is
   between A1 and A2: implemented before A2 is rebased, the temporal contribution is rebased
   over it once; implemented after A2 merges, it carries A2's operators too (open decision 2).
   The single S5 step of A1 is stated over the necessity operator as a field and needs nothing
   from D1.
5. **Gate one admission.** Of channel T's rules only `G`/`H` carrying and whole-judgment time
   reflection may appear in gate-one scripts, each only once adopted into PM-M1 before the
   selection is fixed. `lrewrite` and `lsimp` are measured by A11.
6. **Evaluator and countermodels.** C3's client is B4. The record of C2 names the declarations;
   B4 states the grade at which an evaluator-checked refutation is admitted.
7. **The adapter.** The soundness lemma is the one statement of D4, in the sound direction only,
   under `FormalSystem/Metalogic/`. The tactic that applies it is written with C4, in the same
   module, and reviewed by channel B. C4 does not wrap soundness per language; a language the
   statement does not yet cover is added as an instance of D4.

## Open decisions

1. **Is `BimodalLib` in `defaultTargets`?** Open decision of
   `theorem_library_layout_and_registry`; it holds B1's implementation.
2. **Does the signature layer land before or after the temporal contribution?** Join 4 states
   both orders. Before: one rebase of A2 over the rewritten derived operators, at the cost of
   holding A2, and with it the layout, until D1 is implemented. After: A2 merges at once and D1
   rewrites A2's operators with the rest. The recommendation is after, since A2 is the single
   blocker of the layout and D1 has no implementation yet.
