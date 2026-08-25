---
next_project_number: 477
---

# TODO

## Task Order

*Updated 2026-08-25. Generated from state.json dependency graph.*

**Dependency Waves**:
| Wave | Tasks | Blocked by | Topics |
|------|-------|------------|--------|
| 1 | 127,128,193,257,298,422,434,461,462,468,476 | -- | automation, dataset-enhancement, decidability, ... |
| 2 | 125,169,178,231,282,296,433,455,463 | 193,298,422,434,461,462,468 | algebraic-representation, code-quality, dataset-enhancement, ... |
| 3 | 95,219,362,464 | 169,231,463 | completeness, dataset-enhancement, decidability, ... |
| 4 | 465 | 464 | decidability |
| 5 | 428 | 433,465 | decidability |
| 6 | 429 | 428 | decidability |
| 7 | 410 | 429 | decidability |
| 8 | 411 | 410 | decidability |
| 9 | 430 | 411 | decidability |
| 10 | 177,412 | 193,430 | decidability, formula-refactor |

**Grouped by Topic** (indented = depends on parent):

### Algebraic Representation

125 [NOT STARTED] — Implement a Jonsson-Tarski representation theorem for TM logic: e

### Automation

193 [NOT STARTED] — Apply validity-intro and truth-simp macros to the soundness layer

### Code Quality

455 [NOT STARTED] — BACKLOG REALIGNMENT: bring specs/ROADMAP.md and every remaining a

### Completeness

95 [NOT STARTED] — Verify and record the final axiom/sorry status of the headline me

### Dataset Enhancement

257 [BLOCKED] — Complete the Hugging Face Hub migration for large dataset storage
298 [PARTIAL] — Fix c7 labeling bug at formula ~13750 that causes unbounded memor
  └─ 231 [NOT STARTED] — Build comprehensive automation so that every dataset regeneration
    └─ 219 [RESEARCHED] — Run bmlogic-bench through multiple LLMs to establish baseline dif
  └─ 282 [PARTIAL] — Flip complexity-9 dataset generation from stratified to exhaustiv
  └─ 296 [PARTIAL] — Re-add the 6 derived binary temporal operators (release, weak_unt

### Decidability

434 [PARTIAL] — Discharge `MintPaysForTime fc U Tmax`, defined at FormalSystem/Me
  └─ 433 [PARTIAL] — Discharge `PostBlockingSettles fc`, defined at FormalSystem/Metal
    └─ 428 [BLOCKED] — Engine totality at a quantified branch budget. Owns obstruction O
      └─ 429 [NOT STARTED] — Repair the truth-lemma side conditions. Owns obstructions O2 and 
        └─ 410 [PLANNED] — Track B part 1 for the TM tableau decidability program (parent: t
          └─ 411 [NOT STARTED] — Track B part 2 for the TM tableau decidability program (parent: t
            └─ 430 [NOT STARTED] — The semantic lift and the Track A assembly. Owns obstruction O4 o
              └─ 412 [NOT STARTED] — Track B finish for the TM tableau decidability program (parent: t
462 [NOT STARTED] — Land the engine-level assembly that lets `MintPaysForTimeFixed` b
  └─ 463 [NOT STARTED] — Decide `PostBlockingSettlesRun fc (mintAwareFuelAt U.card Tmax mi
    └─ 464 [NOT STARTED] — Design and land `gapPotential`, the density coordinate of the ter
      └─ 465 [NOT STARTED] — Complete the terminus restatement family at the repaired residual
        └─ 428 [BLOCKED] — Engine totality at a quantified branch budget. Owns obstruction O (see above)
468 [NOT STARTED] — PROGRAMME REALIGNMENT FROM A VERIFIED PROOF-STATE AUDIT: restruct
476 [NOT STARTED] — THE BOX-FAITHFUL SMALL-MODEL THEOREM.

### Formula Refactor

177 [NOT STARTED] — Update all documentation to match final codebase state after refa
178 [NOT STARTED] — Expand Examples/ with publication-quality demonstrations of the f

### Frame Extensions

127 [NOT STARTED] — Add time addition operator (+) to the bimodal logic TM. φ + ψ is 
128 [NOT STARTED] — Add topological open set (interior) operator for dense and contin

### Literature

461 [BLOCKED] — SCOPE 8 acquisition gap identified by task 457's research and re-

### Strong Completeness

422 [BLOCKED] — Construct the discrete-case analogue of the existing dense chroni
  └─ 169 [NOT STARTED] — Base (FrameClass.Base / general) WEAK completeness green: make th
    └─ 362 [NOT STARTED] — Implement the completeness capstone under the SETTLED TERMINOLOGY

## Tasks

### 476. Box faithful small model theorem
- **Effort**: large
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: decidability
- **Dependencies**: Task 475

**Description**: THE BOX-FAITHFUL SMALL-MODEL THEOREM.

CLASSIFICATION: OPEN MATHEMATICS. MULTI-MONTH. This is a genuine research problem in the same
category as the audit's R4 "semantic FMP" entry. IT MAY NOT BE RE-DESCRIBED AS ENGINEERING, AND IT
MAY NOT BE MERGED INTO THE BILASSO WIRING TASK OR THE CARRIER-NORMALIZATION TASK. Merging is
precisely how a research problem gets hidden behind an engineering description, and this task
exists partly to prevent that.

DO NOT BEGIN before the BiLasso wiring task and the carrier-normalization task (task 475) are
landed. Those two have standalone value; this one does not, and its cost is dominated by a problem
a two-day literature check might refute outright.

=== LITERATURE GATE -- RUN FIRST, AND IT IS EMPOWERED TO STOP THE TASK ===

Acquire Gabbay, Kurucz, Wolter, Zakharyaschev, *Many-Dimensional Modal Logics* (2003) and read its
temporal-products chapter. IF the two-dimensional `Until`/`Since` case is recorded there as
undecidable or as lacking the finite model property, THIS TASK IS REFUTED and must be REPORTED AS
SUCH rather than attempted. A negative result here is as valuable as a positive one and would
redirect the whole decidability front.

What is already firm from a prior search: products of THREE OR MORE modal logics are undecidable,
with no logic between K x K x K and S5 x S5 x S5 decidable, and S5 x S5 x S5 lacks the finite model
property. What is NOT settled: the two-dimensional case with `Until`/`Since`, which is what this
logic is closest to. Note that TM is in any case NOT a full product -- its second dimension is the
path space of a graph, not an arbitrary set of runs -- so a product-logic result would be evidence,
not a decision.

=== THE TARGET ===

Build `cands : Formula -> List IntPresentation` and prove

    not (ValidDiscrete phi) -> exists P in cands phi, exists w, SatAtState P w phi.neg

This is the SINGLE remaining obligation for decidability of `ValidDiscrete`. Everything else is
already compiled: given this hypothesis, `check`-over-`cands` is equivalent to `ValidDiscrete phi`
and `decidable_of_iff` reads the `Decidable` instance off it. There is no bridge theorem, no
transfer lemma, no enumeration over `Atom`, and no `Fin n`-from-`Finite` extraction anywhere in the
assembly; `check_correct` is the FINAL step.

=== THE CONSTRUCTION (the tractable part) ===

Build `cands phi` from the CLOSURE-TYPE SPACE: subsets of `subformulaClosure phi` satisfying the
local Hintikka conditions, with `step` given by `LocalCoherent`'s `untl`/`snce` unfolding clauses
(`BiLasso/Annotation.lean` already states them, and they relate the label at `t` to the label at
`t` plus-or-minus one only -- i.e. they ARE an adjacency relation), and the valuation read off the
state by deciding atom membership. Every ingredient is `Finset`/`Bool` data with `DecidableEq`.
Two real obligations, neither research-grade:

  1. `fwd`/`bwd` SERIALITY OF THE TYPE GRAPH. Not free: a Hintikka type may have no locally
     coherent successor, forcing an ITERATED PRUNING to a maximal serial subgraph. Standard,
     bounded, fiddly.
  2. INDEXING. `IntPresentation` demands `Fin card` specifically, so the type `Finset` must be
     listed and indexed. Mechanical.

Estimate for this part alone: two to four weeks.

DO NOT instead try "bound `card` by some `presentationBound phi`, then enumerate the presentations
up to that bound". That does not typecheck as stated: `IntPresentation.val : Atom -> Fin card ->
Bool` is a function on the `Infinite` type `Atom`, so presentations of a given `card` are not a
finite collection. Closing that would need a valuation-restriction lemma that is not in the tree.
The formula-indexed candidate list sidesteps the problem rather than solving it.

=== THE CRUX: BOX-FAITHFULNESS (the research part) ===

The `box` clause of `TruthAt` quantifies universally over ALL total histories. Two landed facts
make this a GLOBAL modality rather than a local one:

  - `Truth.box_const` (`Semantics/Truth.lean`): box truth is independent of both the history and
    the time. Its own docstring: "a model has one finite set of box facts, computed once."
  - `Extension.occurrence` (`cor:occurrence`): every state occurs at every time in some total
    history.

That collapse is why `BoxOracleSound P bx` types `bx` as `Formula -> Bool` -- one `Bool` per
formula, per model. It is also the obstruction:

  The box facts of the SOURCE model M and of the TARGET presentation P are each global constants
  of their own model, and they need not agree. P admits every path of its graph. The subgraph of
  types realized in M still generates paths that M does not realize, and along such a path a
  `box chi` true in M can fail. When it fails, the type-map image is no longer a `LocalCoherent`
  annotation, and the transfer breaks.

Restricting `cands phi` to realized-type subgraphs does NOT by itself close this: the subshift
generated by the realized edges properly contains the realized paths. So the residue is a genuine
BOX-FAITHFUL small-model theorem -- in effect a bounded-model property for LTL(Until, Since) over
bi-infinite paths of a graph, PLUS a universal path quantifier over the whole structure.

Is it true? Almost certainly -- the shape is the classical automata-theoretic bounded-model
setting, and the analogous results (CTL*-style satisfiability, LTL with a universal modality) are
decidable with finite/bounded model properties. Is it in reach? Not routinely. Neither Mathlib nor
this tree carries omega-automata, Buchi complementation, or any language-inclusion machinery, so a
Lean proof must be hand-rolled.

=== WHAT TO REUSE ===

`BiLasso/GoodCycle.lean`'s good-cycle argument, `cycleBound`, and `exists_annot_of_truth` are
exactly the fulfilment machinery a hand-rolled proof would reuse. Be clear-eyed that they operate
INSIDE a presentation, not across the model boundary, which is the whole difficulty.

=== DO NOT PROMISE A CHOICE-FREE RESULT ===

`wlem_of_spherical` (`Tests/BimodalTest/Semantics/SphericalFiniteAxiomTest.lean`) derives weak
excluded middle from `Spherical R` at the finite carrier `Bool` over `D = ZZ`, from
`[propext, Quot.sound]` alone. So NO finite-carrier frame with an arbitrarily shaped relation can
be choice-free, on any route. The cost is already paid by `IntPresentation.toTaskFrame`. Any spec
promising choice-freedom here is promising something proved impossible. Note the separate
distinction: `instDecidableSatAtState` COMPUTES (kernel-evaluated `#guard`s prove it) while
measuring `[propext, Classical.choice, Quot.sound]`. Computability and choice-freedom are different
properties.

---

### 475. Carrier normalization successor archimedean transfer
- **Effort**: medium
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Topic**: semantics
- **Dependencies**: None
- **Research**: [475_carrier_normalization_successor_archimedean_transfer/reports/01_carrier-normalization-transfer.md]
- **Plan**: [475_carrier_normalization_successor_archimedean_transfer/plans/01_carrier-normalization-int-transfer.md]
- **Summary**: [475_carrier_normalization_successor_archimedean_transfer/summaries/01_carrier-normalization-int-transfer-summary.md]

**Description**: CARRIER NORMALIZATION: THE SUCCESSOR-ARCHIMEDEAN TRANSFER.

CLASSIFICATION: ROUTINE ENGINEERING WITH ONE GENUINE LEMMA. The lemma is small and its route is
already written down in the tree; the transport is mechanical but wide. Estimate: days to two
weeks. This is NOT open mathematics.

=== THE TARGET ===

Prove that `ValidDiscrete phi` holds iff `phi` holds in every model over a ZZ-frame. That is, close
the gap between `Semantics/Validity.lean`'s `ValidDiscrete`, which quantifies over an arbitrary
duration type `D` carrying

    [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [SuccOrder D] [PredOrder D]
    [IsSuccArchimedean D] [IsPredArchimedean D] [Nontrivial D]

and the ZZ-specific machinery the rest of the tree is built on.

=== ONLY ONE DIRECTION NEEDS THIS ===

Record this before starting, because it changes what is worth doing first. In the SOUNDNESS
direction -- a countermodel presented over ZZ refutes `ValidDiscrete` -- ZZ instantiates that
entire binder bundle with ZERO instance work, so no carrier lemma is needed at all. That direction
is already compiled (5 lines; see the `evidence/` directory of the task that scoped this work). It
is the COMPLETENESS direction, where the `forall D` binder must be discharged for an ARBITRARY `D`,
that needs everything below.

=== STEP 1: THE LEMMA ===

Prove the successor-based analogue of `archimedean_of_lub`
(`FormalSystem/Semantics/DurationClassification.lean`). Verified 2026-08-24: that file's ENTIRE
theorem inventory is `archimedean_of_lub`, `complete_duration_discrete_or_dense`, and
`complete_not_dense_iso_int` -- all Dedekind-branch, all taking a least-upper-bound hypothesis.
There is no successor-based analogue in the tree.

The consumer fixes what the lemma must produce.
`LinearOrderedAddCommGroup.int_orderAddMonoidIso_of_isLeast_pos : D =+o ZZ` needs exactly two
inputs the `ValidDiscrete` bundle does not supply:

  (a) `Archimedean D` -- which does NOT synthesize from `[IsSuccArchimedean D]` plus
      `[IsPredArchimedean D]`; those are order-successor conditions, not the additive Archimedean
      property; and
  (b) an `IsLeast` witness for the set of strictly positive elements of `D` -- which is what the
      successor structure produces.

=== STEP 2: THE TRANSPORT ===

Transport `TaskFrame`, `TaskModel`, `WorldHistory`, and `TruthAt` along `D =+o ZZ`. Mechanical, but
it touches every semantic definition, so it is not a one-sitting job.

=== THE RECORDED WRONG TURN ===

`orderIsoIntOfLinearSuccPredArch` fits the `ValidDiscrete` bundle VERBATIM -- `NoMaxOrder D`,
`NoMinOrder D`, and `Nonempty D` all synthesize from it, and neither (a) nor (b) is needed. It is
therefore the tempting reach, and it is wrong: it yields only `D =o ZZ`, an ORDER isomorphism.
Durations ADD -- `TaskRel`'s Compositionality is stated at `x + y` -- so an order-only isomorphism
cannot carry a frame across. `Semantics/IntNormalForm.lean`'s module docstring carries the full
binder-fit finding for both Mathlib results; read it before starting.

=== WHY IT IS WORTH DOING ON ITS OWN ===

Independently valuable: it is a prerequisite for anything reasoning about the discrete class, and
it is also what buys the right to work over ZZ -- where `TaskFrame.ofStep` discharges all seven
`TaskFrame` fields from a bare bi-serial relation, leaving bi-seriality as the SOLE frame
obligation. A frame left polymorphic in `D` has neither `limit_of_succOrder` nor `ofStep` and pays
each axiom by hand. Estimates that price re-discharging the frame axioms as multi-month are
measuring the `D`-polymorphic case.

=== ACCEPTANCE ===

- `lake build` green; no new sorry; no new axiom.
- The successor-based lemma is stated and proved, and `int_orderAddMonoidIso_of_isLeast_pos`
  applies to it.
- `ValidDiscrete phi` iff `phi` holds in every ZZ-frame model, as a landed theorem.

---

### 474. Wire bilasso decision layer into live tree
- **Effort**: small
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Topic**: decidability
- **Dependencies**: None
- **Research**: [474_wire_bilasso_decision_layer_into_live_tree/reports/01_wire-bilasso-into-build-graph.md]
- **Evidence**: [474_wire_bilasso_decision_layer_into_live_tree/evidence/assembly-merged-verified.lean]
- **Plan**: [474_wire_bilasso_decision_layer_into_live_tree/plans/01_wire-bilasso-decision-layer.md]
- **Summary**: [474_wire_bilasso_decision_layer_into_live_tree/summaries/01_wire-bilasso-decision-layer-summary.md]

**Description**: WIRE THE BILASSO DECISION LAYER INTO THE LIVE TREE.

CLASSIFICATION: ROUTINE ENGINEERING. Hours, not days. No mathematics is attempted or required.

=== WHY ===

`FormalSystem/Metalogic/Decidability/BiLasso/` is 19 files, sorry-free, with its oleans built --
and it is UNREACHABLE from the Lake target roots, so `lake build` does not see it. The consequences
have already been paid once: the layer was omitted from a prior proof-state audit, and
`specs/ROADMAP.md` mentions BiLasso ZERO times (measured), so the project has been pricing
decidability without accounting for a landed asset. Wiring costs hours and removes the recurrence
of exactly that failure mode. Do not gate this on any research result.

=== WHAT TO DO ===

(1) Add ONE import of the re-export `FormalSystem.Metalogic.Decidability.BiLasso` to
    `FormalSystem/Metalogic/Decidability.lean`.

(2) In `scripts/module-invariants-manifest.txt`, DELETE EXACTLY 15 LINES, IN THE SAME COMMIT as
    (1). C6 fails if a manifest entry names a module that has become reachable, and the manifest's
    own block comment states the rule verbatim: "Registering the layer means adding one import of
    the re-export to `Decidability.lean` AND deleting every line of this block in the same commit
    -- C6 fails if a manifest entry names a module that has become reachable. Do not do one
    without the other."

    The 15 are the 14 modules `BiLasso.lean` imports -- Basic, Unfold, Periodic, Annotation,
    TruthLemma, Decide, Enumerate, Examples, SmallModel, Realized, GoodCycle, Extraction,
    BoxOracle, Check -- plus the aggregator's own line
    `FormalSystem.Metalogic.Decidability.BiLasso`, which becomes reachable from the new import.

    KEEP 4 LINES: `Extend`, `Successor`, `Orbit`, `Agreement`. That cluster is closed and stays
    unreachable -- `Agreement` has no importer anywhere in the tree, `Orbit` is imported only by
    `Agreement`, and `Extend`/`Successor` only by `Orbit`. It belongs to the
    effective-periodic-extension work, which the re-export deliberately does not carry.

    KEEP the `FormalSystem.Semantics.Extension.PeriodicExtension` line. It is a SEPARATE manifest
    block with its own rationale (deliberately unregistered in `FormalSystem/Semantics.lean`
    "while the bi-lasso decision layer above is in flight, so that no aggregator is edited by two
    concurrent lines of work at once"). Retiring it is a second, independent edit and is NOT part
    of this task.

    The 15/4/1 split was re-measured on 2026-08-24 by `grep '^import'
    FormalSystem/Metalogic/Decidability/BiLasso.lean` (14 imports) against `grep -v '^#'
    scripts/module-invariants-manifest.txt` (18 `BiLasso.*` submodule entries + the aggregator =
    19, plus `PeriodicExtension` = 20 across the two blocks). RE-MEASURE before editing; do not
    trust these counts if the tree has moved.

(3) LAND THE THREE COMPILED PROBES as live theorems. They are in
    `specs/469_eliminate_the_bridge_filtration_into_intpresentation/evidence/`:
      - `soundness-half-probe.lean` -- `not_validDiscrete_of_satAtState`, 5 lines
      - `decidability-assembly-family-probe.lean` -- `validDiscrete_iff_checkFamily`,
        `decidableValidDiscreteFamily`
      - `decidability-assembly-probe.lean` -- `validDiscrete_iff_check`, `decidableValidDiscrete`
        (the single-presentation variant)
    All three were recompiled with `lake env lean` on 2026-08-24: sorry-free, each measuring
    `#print axioms` = `[propext, Classical.choice, Quot.sound]`. They are drop-in. Landing them
    means a NEW MODULE under `BiLasso/` plus its own aggregator wiring, so budget that.

(4) Add BiLasso to `specs/ROADMAP.md` under the decidability front, stating its status honestly:
    landed sorry-free, model-checks a GIVEN presentation, and performs NO part of the
    finite-model step. Do not describe it as covering the semantic finite model property.

=== ACCEPTANCE ===

- `lake build` green.
- `scripts/check-module-invariants.sh` passes C1/C2/C3/C6, with no manifest entry naming a
  reachable module and no unreachable live module unmanifested.
- The sole structural sorry remains `countermodel_discrete` (`WeakCanonical/Transfer.lean`);
  the count does not increase.
- The three landed theorems measure `[propext, Classical.choice, Quot.sound]` -- do NOT expect or
  promise choice-freedom.

=== NON-GOALS ===

- Do not touch the `Extend`/`Successor`/`Orbit`/`Agreement` cluster or its manifest lines.
- Do not touch the `PeriodicExtension` manifest line.
- Do not attempt any part of the finite-model theorem.

---

### 473. Delete quarantined vacuous kamp pair
- **Effort**: low
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Topic**: code-quality
- **Dependencies**: Task 470
- **Plan**: [473_delete_quarantined_vacuous_kamp_pair/plans/02_delete-vacuous-kamp-pair.md]
- **Research**: [473_delete_quarantined_vacuous_kamp_pair/reports/01_delete-quarantined-vacuous-kamp-pair.md]
- **Summary**: [473_delete_quarantined_vacuous_kamp_pair/summaries/02_delete-vacuous-kamp-pair-summary.md]

**Description**: DELETE THE QUARANTINED VACUOUS KAMP PAIR, and keep the record that explains why it was vacuous.

=== WHAT AND WHY ===

`neg_2var_vec_ea` (`FormalSystem/Metalogic/WeakCanonical/Kamp/EANegationClosure.lean`) is VACUOUS:
its conclusion quantifies existentially over a `VVecEA2` that its hypotheses do not constrain, and
`Prop42Vacuity.prop42_conclusion_is_vacuous` derives that exact conclusion FROM NO HYPOTHESES via an
all-top witness. It is sorry-free and not unsound -- it simply says nothing. It was mis-adopted as a
landed asset at least twice, which is why the vacuity record exists.

VERIFIED 2026-08-24 by exhaustive grep over the non-Boneyard tree:
  - `neg_2var_vec_ea` has EXACTLY ONE code consumer: `reflatten_neg_step`
    (`Kamp/NfMultiAnchorBridge/NavigatedSpine.lean`), whose body is a bare re-export of it.
  - `reflatten_neg_step` has ZERO code consumers.
  - Every other occurrence of either symbol, repository-wide, is PROSE.
  - The spine's real negation step is `VVecEA2.negFix_iff` / `negFixFaithful_iff`, not this pair.

So the pair is dead weight that cannot reach `kampPriorExpressiveCompleteness` or any flagship
theorem. Deleting it removes a documented trap; it does not remove any content.

=== DELIVERABLES ===

(a) Delete `neg_2var_vec_ea` and `reflatten_neg_step`.

(b) RE-VERIFY THE ZERO-CONSUMER CLAIM YOURSELF FIRST, by symbol, before deleting anything. If you
    find a live consumer this description did not anticipate, STOP, do not delete, and report the
    consumer. A surprise consumer means the analysis above is wrong and the deletion is unsafe.

(c) KEEP `Prop42Vacuity.lean`. It is the machine-checked record of WHY this was vacuous, it is
    root-reachable so CI compiles it, and it is the guard against the same mistake recurring.
    Update only those of its cross-references that name the now-deleted declarations, and keep its
    explanation intact. Do the same for `Prop42Contentful.lean`, which carries the contentful
    biconditional shape a genuine Prop 4.2 would need -- it is the constructive half of the record.

(d) Sweep the PROSE references. Roughly a dozen sites across `EANegationClosure.lean`,
    `NavigatedSpine.lean`, `NfMultiAnchorBridge.lean`, `AggregateHookDischarge.lean`,
    `SubBracket2V.lean` and `Prop42*.lean` describe one or both symbols as landed Prop 4.2
    deliverables. Every one must now either be removed or rewritten to point at the vacuity record.
    A dangling prose reference to a deleted declaration is exactly the drift this repository keeps
    paying for.

(e) INCIDENTAL, FIX WHILE YOU ARE HERE: the anchors in that prose have rotted. Many sites cite
    `neg_2var_vec_ea` at `EANegationClosure.lean:722`; it is not there. `Prop42Vacuity.lean` cites
    `reflatten_neg_step` at `NavigatedSpine.lean:178`; it is not there either. Since the
    declarations are being deleted, replace these with symbol-name references to the vacuity record
    rather than new line numbers.

=== CONSTRAINTS ===

- `lake build` and `lake build BimodalTest` must both exit 0 after the deletion. If anything fails
  to compile, that IS the surprise consumer of (b) -- stop and report rather than patching around it.
- Check C2 must still report all four flagship axiom sets matching baseline, and C3 must still
  report exactly one live structural sorry (`countermodel_discrete`). Neither should move; if
  either does, something was load-bearing after all.
- Do NOT touch any file outside this task's file_scope. In particular the documentation-correction
  pass task owns `Decidability.lean`, `Verified/README.md`, `FMP/README.md`, `Soundness.lean`,
  `WeakCanonical.lean`, `RealModel/ShuffleReal.lean` and `PriorExpressivenessDense.lean` -- leave
  all of them alone.
- Prove nothing, close no sorry, and do NOT attempt to repair `neg_2var_vec_ea` into a contentful
  form. That would be a different task with real mathematical content; `Prop42Contentful.lean`
  already records the shape it would need.

Grounding: specs/reviews/review-2026-08-24.md, Addendum 1 item A-3, and task 468's audit finding F8
(which this supersedes: F8 records the lemma as "still live-consumed"; it is not, it is quarantined).

---

### 472. Immediate documentation correction pass
- **Effort**: medium
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Topic**: code-quality
- **Dependencies**: Task 470
- **Research**: [472_immediate_documentation_correction_pass/reports/01_documentation-correction-verification.md]
- **Plan**: [472_immediate_documentation_correction_pass/plans/01_documentation-correction-pass.md]
- **Summary**: [472_immediate_documentation_correction_pass/summaries/01_documentation-correction-summary.md]

**Description**: THE IMMEDIATE, UNGATED DOCUMENTATION-CORRECTION PASS. This is the first half of the DIVIDE of task
177 that task 468 Stage 3 directs. It is split out and un-gated deliberately: 177 sits behind
thirteen dependencies including the entire decidability chain, and 468 itself now sits behind two
probes and the boneyard consolidation. Every correction below misleads a reader TODAY. None of them
needs any of that work to land first.

MODEL: task 467, which did exactly this for one file (Decidability/README.md) and is archived. Read
its report, specs/467_update_decidability_readme/reports/01_decidability-readme-alignment.md,
before starting.

=== SCOPE: FALSE AND STALE CLAIMS, EACH VERIFIED ===

Each item names a file and the defect. Re-verify by symbol or by the named check before editing --
do not trust the line numbers in this description, and do not trust the prose you find in place.

(a) `Decidability.lean` -- its "## Status: Soundness: Proven / Completeness: Proven" block reads as
    TABLEAU soundness and completeness. It is neither; it refers to the Hilbert-system results.
    This is a genuine overclaim, the same class of defect task 467 corrected next door. Rewrite so
    the subject of each claim is explicit.

(b) `Verified/README.md` -- marks EIGHT files as "planned" that exist, compile, and are imported;
    OMITS eleven files that exist; and lists the genuinely-absent `Verified/Refutation/` subtree in
    the SAME register, so a reader cannot tell which sense of "planned" applies. Rebuild the file
    table against the live tree and give absent-by-design a distinct marker from
    not-yet-documented.

(c) `FMP/README.md` -- lists two "Key Results", `filtration_is_finite` and
    `truth_preserved_under_filtration`, that DO NOT EXIST as declarations. Verified 2026-08-24.
    Replace with what the directory actually proves. While there, note honestly that the directory
    contains ZERO occurrences of `TruthAt` and that its `refinedFilteredTaskRel` is permissive
    (universal at nonzero duration) -- the README already says the latter; keep it.

(d) `DecisionProcedure.lean` -- the `decideAuto` docstring claims blocking "ensures termination for
    all formulas". NO theorem supports this, and `decideAuto` runs at a figure BELOW the already-
    insufficient `soundFuel'`. State what is actually guaranteed.

(e) `Verified/Decidable.lean` -- its Status docstring still describes the fresh-time producers as
    blocked. They are proved. Correct it.

(f) `WeakCanonical.lean` -- lists five open sorries that no longer exist. Per check C3 the tree has
    exactly ONE live structural sorry, `countermodel_discrete` in `WeakCanonical/Transfer.lean`.

(g) `RealModel/ShuffleReal.lean` -- calls a lemma a "documented strategic sorry"; it is proved.

(h) `Soundness.lean` -- cites an IRR rule and an `IRRSoundness.lean` that do not exist.

(i) `PriorExpressivenessDense.lean` -- carries a SELF-CONTRADICTION: one passage states the module
    "carries this module's **only** `sorry`" and another, about 130 lines later, states "This
    module is now sorry-free". C3 confirms the second is correct. Also record, while there, that
    `uSExpressivelyCompleteOverPrior` (`PriorExpressiveness.lean`) is pinned at
    `SemanticPriorUZ`/`SemanticPriorSZ` and so is NOT Reynolds Theorem 3 -- the real Theorem 3 is
    `uSExpressivelyCompleteOverDensePrior` in this file. `semanticPriorU_not_implies_semanticPriorUZ`
    machine-witnesses the gap, so no dense caller can discharge the former's hypotheses.

=== NON-GOALS -- these belong to other tasks, do not do them here ===

- Do NOT touch `specs/ROADMAP.md`. That is task 468 Stage 4c, and it is a rewrite, not a patch.
- Do NOT touch `FormalSystem/Metalogic/Decidability/README.md`. Task 467 already did it.
- Do NOT delete `neg_2var_vec_ea` or `reflatten_neg_step`. That is its own task, which owns the
  Kamp files; touching them here would collide with it.
- Do NOT fix task 177's `file_scope`, and do NOT alter 177's dependencies or status. Task 468
  Stage 3 owns the residual scoping of 177, and task 470 item (G) owns the `file_scope` repair.
- Prove nothing. Close no sorry. This task changes prose and docstrings only.

=== CONSTRAINTS ===

- `lake build` and `lake build BimodalTest` must both still exit 0 at the end -- docstrings are
  compiled, so a malformed one breaks the build.
- Every claim you WRITE must be reproducible by `scripts/check-module-invariants.sh` (C2 axiom
  sets, C3 sorry inventory, C4/C5 reference resolution, C7 file counts). If a claim cannot be
  grounded in a check, do not write it.
- Prefer symbol names to line numbers in everything you write. Line-number rot is the observed
  failure mode across this repository -- roughly twelve sites currently cite `neg_2var_vec_ea` at a
  line it left long ago.
- Do not weaken a claim into vagueness to make it safe. "Proven" and "sorry-free" are DIFFERENT
  properties in this repository and the distinction is the point of the whole exercise; say which
  one holds.

=== VERIFICATION ===

- Both builds green; C1-C10 all pass.
- No file outside this task's file_scope modified.
- No remaining claim in the touched files that names a declaration which does not exist (spot-check
  each named symbol with grep or lean_local_search).

Grounding: specs/reviews/review-2026-08-24.md (issues C-1, H-3, L-2, A-4) and task 468 Stage 3.

---

### 470. Task graph and metadata repair
- **Effort**: low
- **Status**: [COMPLETED]
- **Task Type**: meta
- **Topic**: agent-system
- **Dependencies**: None
- **Research**: [470_task_graph_and_metadata_repair/reports/01_task-graph-metadata-repair.md]
- **Plan**: [470_task_graph_and_metadata_repair/plans/01_task-graph-metadata-repair.md]
- **Summary**: [470_task_graph_and_metadata_repair/summaries/01_task-graph-metadata-repair-summary.md]

**Description**: TASK-GRAPH AND TASK-METADATA REPAIR. Nine defects found by the 2026-08-24 programme review
(specs/reviews/review-2026-08-24.md), all mechanical, none requiring mathematics. Every one is a
correction to `specs/state.json` or to a task description; none changes any task's substance.

CONSTRAINTS THAT APPLY THROUGHOUT:
- All `specs/state.json` writes go through `.claude/scripts/state-write.sh`. TODO.md is regenerated
  via `generate-todo.sh` and is NEVER hand-edited.
- Do NOT transition any task to `completed`, `abandoned`, or `expanded`. Status changes are the
  user's decision. This task edits descriptions, dependencies, file_scope, topics, and counters
  only. Items (H) and (I) below are the sanctioned exception -- they invoke `/task --sync` and
  `/todo`, which own those transitions.
- Prefer symbol names to line numbers in every anchor written.

=== (A) task 421's acceptance criterion is FACTUALLY WRONG -- fix first, it blocks the front ===

421's acceptance reads: "the live non-Boneyard sorry count is unchanged at 2 (verify with:
`grep -rn --include='*.lean' -E '^\s*sorry\s*$' FormalSystem/ | grep -vc Boneyard`)".

The live count is ONE, not two. `scripts/check-module-invariants.sh` check C3 reports the sole
structural sorry as `countermodel_discrete` in `FormalSystem/Metalogic/WeakCanonical/Transfer.lean`
(re-confirmed 2026-08-24, full green run at commit 874f694a1). An agent running 421 to its stated
acceptance criterion will read a CORRECT tree as failing.

This matters more than its size: 421 is the FIRST task on the completeness critical path
(421 -> 422 -> 169), so it is the first thing a dispatch on that front hits.

FIX: change 2 to 1, and replace the inline `grep` with the C3 check. The inline grep is also
methodologically weaker -- C3 strips Lean block and line comments before counting, which matters
here because this repo's prose mentions the word `sorry` roughly ninety times.

=== (B) 465 -> 428: the two decidability chains must be joined ===

`434 -> 433 -> 428 -> 429 -> 410 -> 411 -> 430 -> 412` and `462 -> 463 -> 464 -> 465` are currently
two DISCONNECTED components of the dependency graph. They are not parallel tracks. Task 462's own
description says it is "the plumbing half of the residual task 434 left open at its Phase 8", and
463/464/465 continue over `PostBlockingSettlesRun`, `gapPotential`, and the terminus restatement
family -- i.e. over exactly the obligations 433 and 434 left open.

Because no edge joins them, `generate-todo.sh` places 462 in wave 1 and 428 in wave 3 with no
relation, so any scheduler reads them as independently startable.

FIX: add dependency edge `465 -> 428` (i.e. 428 gains 465 as a dependency). Then REVISE 433's and
434's descriptions to state that their residuals are owned downstream by 462-465, so a reader of
either does not re-attempt work that moved.

VERIFY the direction before writing: confirm from 462-465's descriptions that they are
predecessors of 428 and not successors. If the evidence says otherwise, record that and wire it the
way the evidence supports -- do not force the edge to match this description.

=== (C) un-gate task 426 -- a 4-8 hour probe sitting at wave 9 ===

426's recorded effort is 4-8 hours and its deliverable is an EXECUTABLE discrimination between two
hypotheses about `(G p) -> box (G p)`: (a) the branch saturates but needs more fuel, or (b) it never
saturates. Its dependencies `[165, 408-era chain..., 412, 428]` place it at WAVE 9, behind the
entire tableau chain -- i.e. behind the multi-year work its result is supposed to INFORM.

It probes the CURRENT engine. It needs none of that chain.

FIX: reduce 426's dependencies to `[]`. Do not change its scope.

=== (D) un-gate task 95 -- a confirmation pass at wave 10 ===

95 describes itself as "a narrow confirmation pass, not an investigation": re-run `#print axioms`
on the headline results once `countermodel_discrete` is closed, and record the outcome. Its
dependencies are `[165, 408, 412, 426, 428, 429, 430, 432, 433, 434, 448]`, placing it at WAVE 10.

Its ACTUAL prerequisite is task 169 alone -- 169 is what closes `countermodel_discrete`.

FIX: reduce 95's dependencies to `[169]`.

=== (E) undeclared topic ===

Task 451 carries `topic: "repo-hygiene"`, which is absent from the top-level `active_topics` array.
`generate-task-order.sh` renders it through its append-extras path and emits a one-time stderr
warning. It is the ONLY undeclared topic in the active set (verified 2026-08-24).

FIX: either add `repo-hygiene` to `active_topics`, or retopic 451 to the existing `code-quality`.
Pick one and say which, in the summary.

=== (F) two active tasks have NULL descriptions ===

Task 257 (`large_data_storage_huggingface`, status `blocked`) and task 282
(`exhaustive_enumeration_by_default`, status `partial`) have `description: null`. They carry only a
`project_name`.

This is a guaranteed first-contact failure: for a task with no artifacts, the `state.json`
description is the ENTIRE input its first dispatch receives.

FIX: reconstruct a real description for each from its task directory
(`specs/257_large_data_storage_huggingface/`, `specs/282_exhaustive_enumeration_by_default/`) and
from `specs/CHANGE_LOG.md`. If no recoverable intent exists for one of them, propose it for
abandonment in the summary WITH the argument -- do not transition it yourself.

=== (G) task 177's file_scope has an unresolvable entry and a duplicate ===

177's `file_scope` is `["README.md", "ROADMAP.md", "FormalSystem/", "FormalSystem/", "docs/"]`.
`ROADMAP.md` does not exist at the repository root -- the file is `specs/ROADMAP.md`.
`FormalSystem/` appears twice. `README.md` and `docs/` both resolve.

FIX: `["README.md", "specs/ROADMAP.md", "FormalSystem/", "docs/"]`.

NOTE: task 468 Stage 3 also names this repair as part of DIVIDING 177. Whichever task runs second
must find it already done and say so rather than re-applying it. Coordinate rather than duplicate.

=== (H) specs/state.json counters disagree with themselves ===

`metadata.total_tasks: 29` vs `task_counts.total: 44` vs 46 ACTUAL entries in `active_projects`.
`metadata.last_sync: 2026-06-08` (eleven weeks stale); `metadata.generated_at: 2026-01-20`.
Per-status counts are also wrong: `task_counts` claims `implementing: 2, partial: 1`; the actual
distribution is `not_started: 29, completed: 7, partial: 5, blocked: 3, planned: 1, researched: 1,
implementing: 0`. `task_counts` has no representation at all for `completed` or `blocked`.

FIX: run `/task --sync`. If it does not reconcile all three figures, record precisely which
survive and why.

=== (I) seven completed tasks remain in active_projects ===

432, 436, 457, 458, 459, 460, 467 have status `completed` but are still in `active_projects`. They
inflate every active-set count and participate in the wave computation.

FIX: run `/todo`. Note that item (B) above revises 433/434 and item (H) re-syncs counters -- run
`/todo` LAST so it archives against a corrected tree.

=== VERIFICATION ===

- `generate-todo.sh` regenerates cleanly with NO undeclared-topic warnings.
- Zero dependency edges that resolve in NEITHER `specs/state.json` NOR `specs/archive/state.json`.
  Note the union requirement: 21 edges (361, 414, 439, 448, 454, 452, 420, 165, 402, 131, 440, 441,
  375, 170, 408, 297, 343, 295, 274, 230, 437) resolve only in the archive. A scan of
  `active_projects` alone reports these as false dangling edges -- do not "fix" them.
- 421's acceptance criterion names C3 and the figure 1.
- 426 and 95 appear in wave 1 and wave 2 respectively after regeneration.
- No task transitioned to a terminal status except by `/task --sync` and `/todo`.

Grounding: specs/reviews/review-2026-08-24.md, issues H-1, H-2, H-6, M-1, M-2, M-3, M-4, M-6, L-4.
=== ITEMS B, C, D ARE ALREADY APPLIED (2026-08-24, after this task was written) ===

The dependency edits specified in items (B), (C) and (D) above were applied directly to
specs/state.json when the programme ordering was encoded into the graph. DO NOT RE-APPLY THEM, and
do NOT report them as failures when you find them already done. Verify and move on:

  (B) 465 -> 428 : APPLIED. 428 now carries dependencies [432,433,434,465].
      STILL OPEN under (B): the descriptions of 433 and 434 have NOT been revised to state that
      their residuals are owned downstream by 462-465. That revision is still yours to make.
      ALSO STILL OPEN, and added since: a FIFTH residual, `UnorderedSuccessorLabelClosed`
      (MintBound.lean:6199, carried live at :6215, refuted at :6238), is owned by NO task -- not by
      462, 463, 464 or 465. Task 468 amendment 10e directs that it be assigned. If 468 has not yet
      run when you reach this, leave it to 468; do not create a duplicate owner.
  (C) 426 un-gated : APPLIED. 426 now carries dependencies [470] only.
  (D) 95 re-gated : APPLIED. 95 now carries dependencies [169] only.

ITEM (A) IS NOT APPLIED AND REMAINS THE HIGHEST-PRIORITY PART OF THIS TASK. Task 421's acceptance
criterion still reads "the live non-Boneyard sorry count is unchanged at 2". The live count is ONE.
Only the dependency graph was touched; no task's acceptance criterion was edited. 421 is now
dependent on THIS task precisely so that its criterion is corrected before it runs.

Items (E), (F), (G), (H) and (I) are likewise untouched and remain in scope.

=== ADDITIONAL EDGES APPLIED AT THE SAME TIME (context, not work) ===

The following were also written directly and need no action from you; they are listed so you do not
mistake them for drift when auditing the graph:

  469 <- 470            cleanup precedes the route-decision probe
  426 <- 470            same
  451 <- 470            same
  193 <- 470            same
  421,423,424,413 <- 470  the completeness-front starters wait on this task (421 genuinely so:
                          this task fixes its acceptance criterion)
  468 <- [469,426,451]  the programme realignment must consume both probe verdicts, and must follow
                        the boneyard consolidation because 468 Stage 4c requires C7-grounded file
                        counts that 451 changes
  462 <- [469,470]      do not sink further cost into tableau termination continuation until 469
                        settles the route. NOTE 433 and 434 were deliberately NOT gated on 469:
                        they are `partial`, i.e. in flight, and finishing in-flight work is
                        distinct from starting the new continuation.
  125 <- 461            461 (Goldblatt acquisition) is a genuine prerequisite of 125 and the edge
                        was missing.
  231 <- 298            298 repairs the truncated c7 dataset; 231 automates metadata recomputation
                        and would otherwise propagate the truncation.

Grounding: specs/reviews/review-2026-08-24.md, Addendum 3.

---

### 469. Eliminate the bridge filtration into intpresentation
- **Effort**: medium
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Topic**: decidability
- **Dependencies**: Task 470
- **Plan**: [469_eliminate_the_bridge_filtration_into_intpresentation/plans/01_capture-verdict-and-followups.md]
- **Research**: [469_eliminate_the_bridge_filtration_into_intpresentation/reports/01_eliminate-the-bridge-verdict.md]
- **Summary**: [469_eliminate_the_bridge_filtration_into_intpresentation/summaries/01_capture-verdict-and-followups-summary.md]

**Description**: SCOPE AND PRICE THE BI-LASSO ROUTE TO DECIDABILITY OF `FrameClass.Discrete`, AND COMPARE IT
AGAINST THE TABLEAU ROUTE BEFORE FURTHER TABLEAU INVESTMENT.

This task does NOT prove the bridge. It establishes whether the bridge is provable, at what cost,
and on which side of the constructive line each half falls -- then states the comparison. It may
land the cheap half if that half turns out to be routine; it must not silently expand into the
research half.

=== 0. WHY THIS TASK EXISTS ===

`FormalSystem/Metalogic/Decidability/BiLasso/` (19 files, ~6,593 lines) is landed, sorry-free, and
UNREACHABLE -- imported only by its own aggregator `BiLasso.lean`, and carried in
`scripts/module-invariants-manifest.txt` as 20 known-unreachable modules. It was delivered by
archived task 417. Its main results, by symbol:

  - `SatAtState P w phi` (BiLasso/Check.lean) -- the specification:
      exists tau (htau : tau.IsTotal) t, tau.states t (htau t) = w AND TruthAt P.toModel tau t phi
  - `check_correct` -- `check P w phi = true <-> SatAtState P w phi`
  - `instDecidableSatAtState` -- the `Decidable` instance, recorded as carrying no `Classical.dec`
  - `truth_along_annot` / `truth_along_annot_at` (BiLasso/TruthLemma.lean) -- a genuine truth lemma
  - `exists_annot_of_truth` (BiLasso/Extraction.lean) -- the small-model theorem, windowed shape
  - `cycleBound` (BiLasso/GoodCycle.lean) -- an explicit closed bound
  - `BiLasso/Examples.lean` -- hand-proved and `#guard`-evaluated non-vacuity witnesses

`Check.lean`'s own docstring is precise about the limit: "`check P w phi` decides satisfiability of
`phi` AT THE STATE `w` OF THE PRESENTED Z-FRAME `P`. It does NOT decide the logic: nothing here
quantifies over frames."

Task 468's proof-state audit (reports/01_proof-state-audit-and-realignment-charter.md, finding F6)
concludes "FMP is syntactic, not semantic" on the basis of `Decidability/FMP/`. That conclusion did
not account for `Decidability/BiLasso/`, which is semantic AND computable. `specs/ROADMAP.md` does
not mention BiLasso anywhere. The consequence is that the project prices decidability at "several
person-years" via the tableau route while this asset sits unwired.

=== 1. THE TARGET SHAPE ===

The missing theorem is a bounded finite-presentation model property. Target shape (adjust the
bound's form as the work dictates; do not weaken the quantifier structure):

  theorem exists_bounded_presentation_of_not_validDiscrete (phi : Formula)
      (h : NOT ValidDiscrete phi) :
      exists (P : IntPresentation) (w : Fin P.card),
        P.card <= presentationBound phi AND SatAtState P w phi.neg

Together with `check_correct` and an enumeration of presentations up to that bound, this yields
decidability of `ValidDiscrete`.

=== 2. TWO FACTS THAT MAKE THIS CHEAPER THAN IT LOOKS (verified 2026-08-24, re-confirm) ===

(a) THE CARRIER HALF IS NOT OPEN WORK. `ValidDiscrete` (`FormalSystem/Semantics/Validity.lean`,
    symbol `ValidDiscrete`) quantifies over `D` with `AddCommGroup`, `LinearOrder`,
    `IsOrderedAddMonoid`, `SuccOrder`, `PredOrder`, `IsSuccArchimedean`, `IsPredArchimedean`,
    `Nontrivial`. Such a carrier is order-isomorphic to Z. Mathlib's
    `orderIsoIntOfLinearSuccPredArch` is ALREADY consumed in this tree for exactly that step --
    see the prose at `FormalSystem/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodelBasic.lean`
    (search the file for the symbol name) and
    `FormalSystem/Metalogic/WeakCanonical/IntegerModel/ShiftAndGlue.lean`.
    CONFIRM this by symbol before relying on it.

(b) WHAT REMAINS IS A FINITE-`WorldState` MODEL PROPERTY OVER Z, plus extraction of an adjacency-
    matrix presentation. `IntPresentation` (`Decidability/IntPresentation.lean`) is a finite
    adjacency matrix plus a valuation, with `toTaskFrame`, `toFiniteFrame`, `toModel`,
    `card_worldState`. `FiniteTaskFrame` (`FormalSystem/Semantics/TaskFrame.lean`) already exists
    with a `finite_world : Finite WorldState` field.

=== 3. THE LOAD-BEARING OBJECTION -- ADJUDICATE IT, DO NOT ASSUME PAST IT ===

`FormalSystem/Semantics/Extension/PeriodicExtension.lean`'s module docstring states outright:

  "No bridge from the first to the second is written anywhere, because extracting an equivalence to
   `Fin n` out of a `Prop`-level existential -- together with decidability of a `Prop`-valued
   relation -- is `Classical.choice` in its most literal role, and would produce a non-computable
   presentation, destroying precisely the property the effective version exists to obtain."

That passage is about a DIFFERENT theorem: extending a GIVEN history (`TaskFrame.extend_periodic`
vs `IntPresentation.extend_periodic`). For DECIDING VALIDITY the existential over bounded
presentations may be classical while the DECISION PROCEDURE enumerates data -- the procedure
enumerates presentations up to a bound and runs `check`, and never needs to extract a presentation
from a `Prop`. THIS TASK MUST CONFIRM THAT DISTINCTION RATHER THAN ASSUME IT, and must state
explicitly, per half, which side of the constructive line it falls on and what axioms it costs.
If the distinction does NOT hold, say so plainly and record it as a refutation -- a negative result
here is fully as valuable as a positive one and MUST NOT be left unstated.

=== 4. DELIVERABLES ===

(a) A verdict on the bridge: PROVABLE-ROUTINE / PROVABLE-HARD / REFUTED, with the argument.
(b) The constructive-line accounting of section 3, per half, with the expected axiom set of each.
(c) A cost comparison against the tableau route, in the same units the 468 audit used
    (days / weeks / months-and-genuinely-hard). The tableau route's own price is recorded in
    468's report R7 and in the C9 register inside
    `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean`. Do not restate those
    figures as verified -- re-derive or cite the check that produced them.
(d) If (a) is PROVABLE-ROUTINE: a follow-up task spec with full description, task_type, topic,
    effort, file_scope, dependencies, and an explicit routine-engineering vs open-mathematics
    classification. Do NOT hide a research problem behind an engineering description.
(e) An explicit statement of what wiring BiLasso into the live tree would cost, and whether the
    20 C6 manifest entries should be retired as part of it.

=== 5. NON-GOALS ===

- Does not prove the bridge (unless it turns out routine, in which case landing it is permitted --
  say so explicitly in the summary if that happens).
- Does not edit the tableau tree, and does not abandon the tableau route. This task informs a
  choice; it does not make it.
- Does not touch `PeriodicExtension.lean`'s existing theorems.

=== 6. CONSTRAINTS ===

- Prefer symbol names to line numbers in every anchor written. Line-number rot is the observed
  failure mode across this backlog.
- Every claim about build state, sorry counts, or axiom sets must cite the check that produced it
  (`scripts/check-module-invariants.sh` C2/C3, or `lean_verify` / `#print axioms`).
- Grounding: specs/reviews/review-2026-08-24.md, issue C-2.
=== 7. RE-SCOPE (2026-08-24, supersedes the framing of sections 1-3 above) ===

The target is NOT "prove a bridge theorem". It is: ELIMINATE THE NEED FOR ONE.

WHY. What sections 1-3 call "the bridge" is three separate gaps, and only one is a bridge:

  Gap 1, CARRIER (arbitrary discrete Archimedean D -> Z). NOT a bridge -- a missing semantic fact
    needed by anything reasoning about the discrete class. NOTE: section 2(a) above is WRONG and is
    corrected here. `orderIsoIntOfLinearSuccPredArch` is NOT sufficient: it delivers only an ORDER
    iso, and durations ADD -- Compositionality is stated at `x + y`. Per
    `FormalSystem/Semantics/IntNormalForm.lean`, the needed lemma is
    `LinearOrderedAddCommGroup.int_orderAddMonoidIso_of_isLeast_pos` (D orderadd-iso Z), which does
    not fit the ValidDiscrete binder bundle: `Archimedean D` does NOT synthesize from
    `[IsSuccArchimedean D] [IsPredArchimedean D]`, and an `IsLeast {y | 0 < y}` witness is also
    required. `Semantics/DurationClassification.lean` carries `archimedean_of_lub` for the Dedekind
    branch; the SUCCESSOR-BASED ANALOGUE IS NOT IN THE TREE. That lemma is real, bounded work.

  Gap 2, FINITE MODEL PROPERTY. NOT a bridge -- this IS the content of decidability. Unavoidable.

  Gap 3, REPRESENTATION (`FiniteTaskFrame` Prop-level vs `IntPresentation` data). THE ONLY GENUINE
    BRIDGE, and it is AVOIDABLE. `PeriodicExtension.lean` states the duplication outright:
    `TaskFrame.extend_periodic` and `IntPresentation.extend_periodic` are "two theorems, not one".

THE ROUTE. Two verified facts make elimination plausible:

  (i) The existing filtration world-space is ALREADY data-shaped.
      `filteredCharacteristicSet_injective` (FMP/FiniteModel.lean) injects `FilteredWorld phi` into
      `Finset (subformulaClosure phi)`; `filtered_world_bound` (FMP/FMP.lean) bounds it by
      2 ^ (subformulaClosure phi).card. The quotient is by agreement on a FINITE DECIDABLE set,
      hence computably enumerable.
  (ii) The `Classical.choice` objection in `PeriodicExtension.lean` concerns extracting `Fin n`
      from an ARBITRARY Prop-level `Finite`. A filtration quotient by agreement-on-a-finite-set is
      not that. CONFIRM this distinction holds before relying on it; if it does not, say so plainly.

AND THE FILTRATION MUST BE REBUILT ANYWAY, independent of representation: `FMP/README.md` records
refinedFilteredTaskRel as "fun w d u => if d = 0 then w = u else True" -- UNIVERSAL at nonzero
duration. Spherical and Limit hold BECAUSE the relation is universal, and a truth lemma is FALSE on
it (someFuture chi separates the sides). Verified: ZERO occurrences of `TruthAt` in all of `FMP/`.

THE RE-SCOPED QUESTION: can the rebuilt, NON-PERMISSIVE filtration be constructed to land in
`IntPresentation` DIRECTLY -- world-space as a `Finset` of closure-assignments, relation as the
adjacency matrix -- so that the filtration output IS the `check` input definitionally,
`check_correct` is the final step rather than the far side of a transfer, and NO BRIDGE THEOREM
EXISTS TO PROVE?

DELIVERABLES REPLACING SECTION 4(a)-(d): a verdict on that question with the argument; the
constructive-line accounting per half; the cost of the non-permissive relation (re-discharging all
four def:frame axioms is the multi-month piece and is unavoidable on ANY route -- do not price it
as if the refactor caused it); and a follow-up task spec if the answer is yes. Section 4(e) stands.

SCOPE CORRECTION: this does NOT unblock `countermodel_discrete`. Task 169's terminus is a BASE-class
countermodel over the NON-ARCHIMEDEAN carrier Q x_lex Z -- different class, different carrier,
reached by 421->422. Any claim that this work "serves both fronts" is too broad; it serves the FMP
result and decidability only. Grounding: specs/reviews/review-2026-08-24.md, Addendum 2.

---

### 468. Realign task programme from proof state audit
- **Effort**: high
- **Status**: [NOT STARTED]
- **Task Type**: meta
- **Topic**: decidability
- **Dependencies**: Task 469, Task 426, Task 451
- **Research**: [468_realign_task_programme_from_proof_state_audit/reports/01_proof-state-audit-and-realignment-charter.md]

**Description**: PROGRAMME REALIGNMENT FROM A VERIFIED PROOF-STATE AUDIT: restructure the active task set, its
dependency graph, and specs/ROADMAP.md so that they describe the work actually remaining to close
decidability of TM with a sound and complete tableau system, plus the adjacent metatheory
milestones.

The governing input is this task's own report artifact, reports/01_proof-state-audit-and-realignment-charter.md,
which records a four-front audit (decidability internals, tableau calculus, soundness/completeness
metatheory, backlog/roadmap state) verified against the Lean sources rather than against
documentation. Read it before acting. Its findings are the reference frame for every verdict this
task issues.

=== 0. WHY THIS TASK EXISTS ===

The audit established that the project's own tracking understates what remains, in ways that would
misdirect planning:

  - Decidability of TM is OPEN. No theorem anywhere takes `isValid` as its subject. The tableau
    calculus is real and sorry-free but is neither proven sound nor proven complete AS A THEOREM.
  - The gaps are invisible to every metric the project currently uses. The decidability tree has
    zero live `sorry` and zero `axiom` declarations. What is missing is (i) theorems never stated,
    (ii) conditional theorems whose hypotheses nobody can supply, and (iii) one subtree that does
    not exist on disk. A sorry-count of ONE is true and is not evidence of near-completion.
  - Several tasks are archived or marked `completed` over work that is demonstrably still open
    (see section 2c).

This task does not prove anything. It decides what the remaining tasks should BE.

=== 1. STAGE 0 -- ADJUDICATE TASK 455 FIRST ===

Task 455 (BACKLOG REALIGNMENT) predates the audit and overlaps this task. It was written as a
backward-looking description-rot sweep with four stages; this task is forward-looking programme
design. Both write specs/ROADMAP.md, so they must not run concurrently: 455 now carries
dependencies:[468] for that reason.

Before any other stage, decide 455's disposition and record the reasoning in the report:
  ABSORB   -- fold its four stages into this task's execution and propose 455 for abandonment.
  NARROW   -- keep 455 for the per-task anchor-rot sweep it specifies, and strip from it whatever
              this task supersedes. State the new boundary precisely.
  RETAIN   -- keep both as written, and justify why the duplicated ROADMAP work is worth it.
Do not transition 455's status; propose only (see section 6).

=== 2. STAGE 1 -- VERIFY AND EXTEND THE AUDIT ===

The report's findings were produced by parallel read-only agents. Before restructuring the backlog
on top of them, confirm the load-bearing ones directly, and extend where the audit was explicitly
uncertain:

(a) Confirm each of these against the live tree, citing symbol names (not line numbers):
    - No declaration takes `isValid` as its subject.
    - `ruleSound_of_mem_allRulesForFC` is not lifted through `expandOnceUnblocked` /
      `expandBranchWithFuel` / `buildTableau`; no `allClosed -> valid` exists.
    - `serialityRule` and `timeLinearity` fire from `expandOnce` stages 2/3 outside
      `allRulesForFC`, with no `RuleSound` obligation discharged at the firing site.
    - `FormalSystem/Metalogic/Decidability/Verified/Refutation/` does not exist.
    - `ProofExtraction.lean` contains zero theorems and `verifyProof` is constantly `true`.
    - `countermodel_discrete` (WeakCanonical/Transfer.lean) is the only live structural sorry.

(b) SETTLE THE HIGHEST-INFORMATION OPEN QUESTION. The audit could not determine whether the
    tableau completeness half is vacuous or merely unassembled. The four `not_valid*_of_hasOpen*`
    results each carry five decidable branch gates, and `boxAnchoredCheck` is documented as
    computing `false` on every multi-world branch the engine builds -- because the repair that
    fixed a genuine unsoundness (cross-world temporal copying, which closed the invalid
    `(G p) -> box (G p)`) removed the only route by which the anchor could be satisfied.
    Determine by execution (`#eval` / `#guard`, no proof required) whether all five gates can hold
    simultaneously on an engine-produced saturated open branch. This is cheap and it decides
    whether task 429 is a repair or a redesign. Record the verdict either way; a negative result is
    as valuable as a positive one and must not be left unstated.

(c) Re-derive the status of every task the audit flagged as claiming more than it delivered, and
    record a verdict for each:
    - 165 (archived completed) over obstructions O1-O4 still live as 428/429/430.
    - 432 (completed) whose summary states its reduction "is not a discharge".
    - 436 (completed) which left the density coordinate open, now 464.
    - 170 (archived completed) whose only remaining action was a clean-build re-verification that
      its own summary says was never run -- on which the "Dense weak completeness substantively
      closed" claim depends.
    - 177's file_scope entry `ROADMAP.md`, which does not resolve (the file is specs/ROADMAP.md),
      and its duplicated `FormalSystem/` entry.

=== 3. STAGE 2 -- RESTRUCTURE THE TASK SET ===

For every active task, and for the archived tasks named in 2c, issue one verdict with evidence.
Categories extend 455's vocabulary with the two it lacks:

  CURRENT    -- matches the tree and the audit. Say what was checked.
  REVISE     -- substance intact, description or anchors wrong. Give the corrected text.
  DIVIDE     -- the task bundles work at incompatible difficulty or readiness. Give the split.
  ADD        -- work the audit identified that no task covers. Give the new task's full spec.
  REMOVE     -- goal no longer serves the project, or is refuted. Argue it, propose abandonment.
  REOPEN     -- marked complete over work still open. Argue it, propose the correction.

Known candidates, non-exhaustive -- the survey must cover the whole active set, not just these:

  ADD, decidability -- no active task covers any of:
    - Lifting rule soundness through the engine to `allClosed -> valid` (real tableau soundness).
      Note 430 covers the semantic lift and Track A assembly; establish whether this is inside 430
      or a distinct predecessor, and wire accordingly.
    - Discharging `RuleSound` for `serialityRule` and `timeLinearity` at their firing site.
      Mechanical relative to the 34 already done; likely a predecessor of the soundness lift.
    - The `isValid = true -> valid` direction. Pure plumbing, hours, currently unstated.
    - A genuine SEMANTIC finite model property. `fmp_completeness` is syntactic (MCS-membership
      to derivability). A truth lemma is FALSE on `RefinedFilteredTaskFrame` because its task
      relation is permissive; `someFuture` separates the sides. This needs a non-permissive
      filtered relation with all four `def:frame` axioms re-discharged -- and the permissive route
      is exactly what currently delivers Spherical/Limit. Multi-month.
    - Proof-extraction completeness (eliminating `.extractionFailed`). May require redesigning the
      extractor to be provably total on closed tableaux.
    - A non-trivial `NoSplit` witness, or a `NoSplit`-free termination result. The only existing
      witness is the EMPTY BRANCH (`noSplit_nil`), which makes the conditional termination theorem
      near-contentless. Decide whether this is a task or a recorded limitation.
  ADD, metatheory -- repair or retire the live vacuous lemma `neg_2var_vec_ea`
    (Kamp/EANegationClosure.lean), whose conclusion is provable from no hypotheses and which is
    re-exported verbatim by `reflatten_neg_step`. The contentful biconditional shape is already
    written down in Prop42Vacuity.lean. It cannot corrupt the flagship theorems, but it is cited
    in prose as a landed Kamp deliverable.
  DIVIDE, documentation -- see section 4.
  REVISE -- 428's description still frames an unconditional `buildTableau_isSome` in places; the
    unconditional form is FALSE at the engine's `maxBranches := 50000` guard, at any fuel.
  ASSESS -- whether the split-arm fuel adequacy obligation is closable at all without an engine
    change. Fuel scales like `beta ^ depth` and `depth` is bounded by nothing proved. If it is not
    closable as specified, it needs a C9 register entry and a re-scoped task, not another attempt.

Every ADD must arrive with: full description, task_type, topic, effort, file_scope, dependencies,
and an explicit statement of whether it is routine engineering or open mathematics. The audit's
three-tier estimate (days / weeks / months-and-genuinely-hard) is the reference; do not create a
task that hides a research problem behind an engineering description.

=== 4. STAGE 3 -- THE DOCUMENTATION TASK ===

A documentation task IS already open: 177 ("Update all documentation to match final codebase
state"), covering README.md, module-level docstrings, ROADMAP.md, and the Axiom Reference. Do NOT
create a duplicate.

177 is, however, gated behind thirteen dependencies including the entire decidability chain
(426, 428, 429, 430, 432, 433, 434), which defers every documentation correction until after
multi-year work. The audit found doc drift that is actively misleading NOW:
  - `Decidability.lean`'s "## Status: Soundness: Proven / Completeness: Proven" block reads as
    tableau soundness and completeness. It is neither; it refers to the Hilbert-system results.
  - `Verified/README.md` marks eight files as "planned" that exist, compile, and are imported;
    omits eleven files; and lists the genuinely-absent Refutation subtree in the same register,
    so a reader cannot tell which "planned" means what.
  - `FMP/README.md` lists two "Key Results" (`filtration_is_finite`,
    `truth_preserved_under_filtration`) that do not exist as declarations.
  - `DecisionProcedure.lean`'s `decideAuto` docstring claims blocking "ensures termination for all
    formulas". No theorem supports this.
  - `Verified/Decidable.lean`'s Status docstring still describes the fresh-time producers as
    blocked; they are proved.
  - `WeakCanonical.lean` lists five open sorries that no longer exist; `ShuffleReal.lean` calls a
    proved lemma a "documented strategic sorry"; `Soundness.lean` cites an IRR rule and an
    `IRRSoundness.lean` that do not exist.

Therefore: DIVIDE 177. Propose an immediate, ungated correction pass covering the false and
stale claims above (task 467 has already done this for one file, Decidability/README.md, and is
the model), and retain the remainder of 177 as the final post-refactor polish with its existing
gating. Give both halves full specs and correct file_scope. Fix 177's unresolvable `ROADMAP.md`
anchor and its duplicated `FormalSystem/` entry as part of this.

=== 5. STAGE 4 -- DEPENDENCIES AND ROADMAP ===

(a) Wire every edge implied by the restructured set. The audit found the decidability critical
    path running ten waves deep (434 -> 433 -> 428 -> 429 -> 410 -> 411 -> 430 -> 412 -> 426 -> 95).
    Re-derive it after restructuring and state it explicitly. Where prose asserts one task gates
    another, ensure the edge exists, or downgrade the prose -- never leave both readings.
(b) Confirm zero dangling edges, and that active_topics matches the topics tasks carry.
(c) Rewrite specs/ROADMAP.md so it states, per front (decidability/tableau, weak completeness,
    strong completeness, Kamp, FMP, publication, dataset, hygiene): what is PROVEN, what is OPEN,
    what is REFUTED, and what the terminus looks like. Requirements:
    - Distinguish PROVEN from SORRY-FREE. They are not the same thing in this repo and conflating
      them is the specific failure this whole task exists to correct.
    - Give refuted routes explicit tombstones. The C9 register (a section inside
      Verified/Termination/MintBound.lean, 24 entries) is the model and should be cross-referenced,
      not duplicated.
    - Mark superseded historical blocks as historical, or delete them. The file currently layers
      four dated "current state" blocks and carries two self-labelled STALE sections.
    - Correct the Paper Alignment section, which lists six tasks as not-started/blocked that were
      all archived completed between 2026-08-13 and 2026-08-18, and carries no stale banner.
    - Ground every status claim in something `scripts/check-module-invariants.sh` can reproduce
      (C2 axiom sets, C3 sorry inventory, C4/C5 reference resolution, C7 file counts), and say
      which check grounds it.
(d) Repair specs/state.json's internal counter inconsistency (metadata.total_tasks 29 vs
    task_counts.total 44 vs 45 actual entries; metadata.last_sync two months stale), or record why
    it must be left to /task --sync.

=== 6. STAGE 5 -- REPORT ===

Extend this task's report artifact, or add a second one, containing:
  - the 455 disposition and its reasoning
  - the Stage 1 verification results, including the box-anchor execution verdict
  - the per-task verdict table (task, topic, verdict, evidence, action)
  - every new task's full spec, and every proposed removal with its argument
  - every dependency edge added or removed, with justification
  - the ROADMAP.md changes and the machine-checked source grounding each
  - the resulting critical path per front, with the routine/hard split made explicit
  - an explicit list of proposed status corrections (completions, abandonments, reopenings) for
    user decision

=== 7. CONSTRAINTS ===

- TASK STATUS IS NOT IN SCOPE. Descriptions, dependencies, file_scope, ROADMAP.md, and NEW task
  creation are in scope. Propose completions, abandonments, and reopenings in the report; do not
  transition any existing task to completed, abandoned, or expanded. That decision stays with the
  user. Creating new tasks IS permitted and expected.
- NO .lean PROOF EDITS. This task proves nothing and closes no sorry. The one execution permitted
  is the read-only `#eval`/`#guard` probe in Stage 1b; if it requires a scratch file, place it
  outside FormalSystem/ or delete it before completion.
- All specs/state.json writes go through .claude/scripts/state-write.sh; TODO.md is regenerated via
  generate-todo.sh, never hand-edited.
- Every claim about build state, sorry counts, or axiom sets must cite the check that produced it.
  Do not restate a status from another description as if it were verified -- that is the exact
  failure mode this task corrects.
- Prefer symbol names to line numbers in every anchor written. Line-number rot is the observed
  failure mode across this backlog.

=== 8. VERIFICATION ===

- Every active task has a verdict; none silently skipped. CURRENT still gets a row saying what was
  checked.
- Zero dangling dependency edges across active_projects.
- generate-todo.sh regenerates cleanly with no undeclared-topic warnings.
- scripts/check-module-invariants.sh C5 passes over the rewritten specs/ROADMAP.md.
- The Stage 1b box-anchor verdict is recorded, whichever way it went.
- ROADMAP.md contains no status claim that no check can reproduce.
- 177 is divided, or a written argument for leaving it whole is in the report.

=== 9. NON-GOALS ===

- Does not implement, research, or plan any surveyed or newly created task.
- Does not archive anything (that is /todo's job, after the user acts on the report).
- Does not attempt any of the mathematics it schedules.
- Does not edit Verified/README.md or the other drifted docs itself; it SCHEDULES that work as the
  divided half of 177.
=== 10. AMENDMENTS FROM THE 2026-08-24 PROGRAMME REVIEW (specs/reviews/review-2026-08-24.md) ===

Three corrections to the charter above, all established by direct verification against the live
tree at commit 874f694a1. Apply them; do NOT execute the superseded instructions they replace.

--- 10a. STAGE 1b IS ALREADY ANSWERED. Consume the measurement; do not re-run the probe. ---

Section 2(b) above designates the box-anchor question "the highest-information open question" and
directs settling it by `#eval`/`#guard`. THAT MEASUREMENT ALREADY EXISTS AND IS COMMITTED:

  specs/archive/418_fix_tableau_engine_crossworld_temporalcopy_unsoundness_in_boxnegdiamondpos/
    artifacts/boxanchored-finding.md

Task 418 Phase 5 ran it against the post-fix engine (its section 1.2, explicitly labelled
"measured, this phase -- not predicted"), and Phase 6 extended it corpus-wide (its section 6).

THE VERDICT IS NEGATIVE, AND BROADER THAN SECTION 2(b) ANTICIPATED. It is not `boxAnchoredCheck`
alone: the WHOLE decidable-branch-gate family collapses to `false` on any branch that mints a
world -- `boxAnchoredCheck`, `boxGridCheck`, `regionGate`, `regionLabelCheck`, and
`rayUpOk`/`rayDnOk`, each measured `true` before the fix and `false` after, on the same formulas.
The artifact's diagnosis: "a freshly minted box/diamond-witness world now carries only the witness
plus modal-universal content, and every branch-level gate that expected temporal content there
fails."

CONSEQUENCES FOR THIS TASK:
  - REPLACE Stage 1b's directive. Do not re-run the probe. Instead RE-VERIFY the artifact's
    headline rows still hold against the current engine (cheap -- the probes named in it are
    `BoxSpreadProbe`, `RegionGateProbe`, `RayRegionProbe`, `TemporalWitnessProbe`, all live in
    `Tests/BimodalTest/`), then RECORD the verdict and cite the artifact.
  - The question section 2(b) says the probe would settle -- "whether task 429 is a repair or a
    redesign" -- IS ALREADY DETERMINED: **redesign**. Any plan that budgets 429 as a repair is
    mis-priced. Wire that into the Stage 2 verdict for 429.
  - The artifact also carries information the charter does not, and it is GOOD news that must not
    be lost: repair options (a) "propagate T(box phi) itself to the fresh world" and (b) "copy
    T(G phi)/T(H phi) only when box-derived" "would restore the temporal content and so would
    likely restore this whole family at once". Option (a)'s proof obligation -- that `T(box phi)`
    at `(w,t)` entails `T(box phi)` at the minted `w'` -- is an S5 axiom-4/5 pattern the artifact
    judges "very likely sound", carrying named termination and fuel consequences that
    `Fuel.lean`'s bounds and the subformula property must absorb. Option (c) is recorded as
    **closed as formulated**, because `boxGridCheck` -- the check `truthAt_box_iff_base` actually
    consumes -- fails for the same reason the anchor does.
  - REVISE 429's description (Stage 2) to name option (a) as the recommended route with its
    `RuleSound` obligation and its fuel/termination consequences stated UP FRONT, so the redesign
    is scoped rather than rediscovered.

--- 10b. STRIKE THREE STAGE-2 CANDIDATES THAT EXISTING TASKS ALREADY OWN ---

Section 3's "Known candidates" list names three items as uncovered. Verified against the live
descriptions, all three are already owned. Creating tasks for them would duplicate; rewriting 428
would damage a correct description.

  - "Lifting rule soundness through the engine to `allClosed -> valid`" -- OWNED BY 430, whose
    description calls it "(b) THE SEMANTIC LIFT ... the LARGER of the two and is comparable in
    weight to a landed sub-phase, not to a wrapper."
  - "Discharging `RuleSound` for `serialityRule` and `timeLinearity` at their firing site" --
    OWNED BY 430, item (a), which quotes `Verified/Decidable.lean`'s own note that
    `ruleSound_of_mem_allRulesForFC` does not cover them.
  - "REVISE -- 428's description still frames an unconditional `buildTableau_isSome` in places" --
    STALE. 428's description opens: "THE REFUTED THEOREM, SETTLED: `buildTableau_isSome` in
    unconditional form is FALSE, not merely unproved, and is on a do-not-re-attempt register."
    It is already correct. Issue a CURRENT verdict for 428 on this point, not a REVISE.

The genuinely uncovered items from Recommendation R2 REMAIN in scope and must still be specced:
the `isValid phi fc = true -> models phi` plumbing bridge; proof-extraction completeness
(eliminating `.extractionFailed`); and the ungated documentation-correction pass of Stage 3.

--- 10c. STAGE 4(c) MUST SPLIT ROADMAP.md, NOT RE-BANNER IT ---

Stage 4(c) directs marking superseded blocks historical "or delete them". Re-bannering is not
sufficient, and the file's condition shows why. Verified 2026-08-24:

  - 1,930 lines; roughly THIRTY sections already carry `HISTORICAL` / `SUPERSEDED` / `STALE`
    banners. Adding a thirty-first does not make the file readable.
  - `## Overview` -- the section the file's own header declares current -- stacks at least FOUR
    dated "Current state" blocks. The one at the `**Current state** (2026-07-07 ...)` marker
    asserts `completeness_discrete` "is blocked by exactly TWO live sorries". Checks C2 and C3
    confirm it is AXIOM-CLEAN AND SORRY-FREE. The adjacent "Critical path" paragraph budgets
    "~11-18 focused dispatches to a sorry-free `completeness_discrete`" -- work already finished.
  - The same block calls the Stavi/EFGames chain "superseded ... and parked off the live path".
    It is LIVE: `FormalSystem/Metalogic/WeakCanonical.lean` imports
    `WeakCanonical.EFGames.StaviCompleteness`, and four further live modules import from
    `EFGames/`.
  - The trailing `## Task Cross-Reference` table (111 rows) carries statuses for tasks 60-117; the
    file footer reads "Last updated: 2026-06-16" while sections above it were edited 2026-08-17.
  - `roadmap-integration.sh` reports `phases=0 checkboxes=0 table_rows=111`: the file has NO
    machine-annotatable structure, so automated roadmap annotation is a structural no-op (this
    review's pass: 0 annotations, 1 skipped, `low_confidence`).

REQUIREMENTS ADDED TO STAGE 4(c):
  - Move the historical sediment to a SEPARATE `specs/ROADMAP-ARCHIVE.md`. `specs/ROADMAP.md` must
    contain exactly ONE current-state statement per front, with no dated block stack.
  - Retitle the file. It is "Roadmap: BX Completeness and Publication"; decidability is now the
    largest front and does not appear in the title.
  - `FormalSystem/Metalogic/Decidability/BiLasso/` appears NOWHERE in the roadmap. It is 19 files
    and ~6,593 lines, landed sorry-free by archived task 417, carrying `check_correct` and
    `instDecidableSatAtState` (no `Classical.dec`), and currently UNREACHABLE. Task 469 scopes the
    bridge from it to `ValidDiscrete`. The rewritten roadmap must state its status honestly under
    the decidability front. NOTE that this qualifies the audit's own finding F6 ("FMP is syntactic,
    not semantic"), which was reached from `Decidability/FMP/` and did not account for BiLasso.
  - Give the file a checkbox or phase structure so `roadmap-integration.sh` can annotate it, or
    record explicitly that it is intentionally unannotatable and why.

--- 10d. TASK 455 DISPOSITION -- INPUT TO STAGE 0, NOT A SUBSTITUTE FOR IT ---

Stage 0 owns this decision. The review's finding, offered as evidence only: 455's Stage 1 is
STRICTLY CONTAINED in Stage 4(c) above (455 requires grounding claims in C2/C3/C4/C5/C7; 4(c)
requires that PLUS the PROVEN-vs-SORRY-FREE distinction, refuted-route tombstones, and the C9
register cross-reference), and 455's Stages 2-4 are contained in this task's Stage 2, which extends
the verdict vocabulary with ADD and REOPEN. On that evidence the review recommends **ABSORB**.
Stage 0 must still reach and record its own verdict.

--- 10e. A FIFTH TERMINATION RESIDUAL EXISTS AND HAS NO OWNER (added 2026-08-24) ---

Section 3 above, and the standing account of the totality terminus throughout this backlog, treat
the residual set as FOUR: `UniverseClosed`, `DifficultyBounded`/`StepLengthBounded`,
`MintPaysForTime`, `PostBlockingSettles`. There are FIVE.

`UnorderedSuccessorLabelClosed` is defined at `Verified/Termination/MintBound.lean:6199`, is carried
as a live hypothesis by `buildTableauAt_isSome_at_seed_lengthBudget_signedUniverse` at `:6215`, and
`:6127` records it as "still a named residual". It additionally has an IN-TREE REFUTATION at `:6238`:
`¬ UnorderedSuccessorLabelClosed fc freshWorldLabels`.

Task 432 is marked `completed` over it; 432s own summary states "the residual is not discharged, so
removing it would be unsound" and that "freshLabelHeadroom_not_universal refutes the reduced
antecedent at every nonempty finite L".

VERIFIED 2026-08-24: NONE of tasks 462, 463, 464, 465 mentions `UnorderedSuccessorLabelClosed`.
It is unowned.

This bears directly on task 462, whose stated target is discharge at a NONEMPTY universe -- the same
setting in which `:6238` refutes this predicate. Sequence the two deliberately.

REQUIRED OF STAGE 2: either ADD a task owning the fifth residual, or fold it into 465 with an
explicit statement of which theorem still carries it and at which frame classes. Do not let the
four-residual framing persist unqualified in the rewritten ROADMAP.md -- correcting exactly this
class of understatement is why this task exists. Grounding: specs/reviews/review-2026-08-24.md, A-2.
--- 10f. STAGE 3 IS ALREADY HALF-EXECUTED (2026-08-24) ---

Stage 3 above directs DIVIDING task 177 into (i) an immediate, ungated correction pass and (ii) the
retained post-refactor polish. Half (i) HAS BEEN SPLIT OUT ALREADY, as task 472
(`immediate_documentation_correction_pass`), because this task is now gated behind two probes and
the boneyard consolidation -- which would have deferred those corrections yet again, the precise
failure Stage 3 exists to prevent.

DO NOT create a second immediate-correction task. Task 472 owns items (a) through (i) of the F10
drift list: `Decidability.lean`'s Status block, `Verified/README.md`, `FMP/README.md`,
`DecisionProcedure.lean`'s `decideAuto` docstring, `Verified/Decidable.lean`'s Status docstring,
`WeakCanonical.lean`, `RealModel/ShuffleReal.lean`, `Soundness.lean`, and
`PriorExpressivenessDense.lean`'s self-contradiction.

WHAT REMAINS OF STAGE 3 FOR THIS TASK:
  - Give the RETAINED half of 177 its corrected spec -- the post-refactor polish, under its
    existing gating, with 472's territory explicitly excluded so the two cannot collide.
  - Note that 177's `file_scope` repair (the unresolvable `ROADMAP.md` entry and the duplicated
    `FormalSystem/`) is owned by task 470 item (G). Verify it was done; do not redo it.
  - If 472 has already run when you reach this, verify its corrections held rather than re-issuing
    them.

Also note task 473 (`delete_quarantined_vacuous_kamp_pair`) now owns the `neg_2var_vec_ea` /
`reflatten_neg_step` deletion. That supersedes audit finding F8, which records the lemma as "still
live-consumed": verified 2026-08-24, it has one consumer which itself has none, so it is quarantined
and safely deletable. Do not schedule it again.

---

### 465. Complete terminus restatement family
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: decidability
- **Dependencies**: Task 462, Task 463, Task 464

**Description**: Complete the terminus restatement family at the repaired residuals. Task 433's Phase 6 landed EIGHT of the twenty-two restatements -- the four family roots and their four caller-facing seed forms -- and recorded the remaining FOURTEEN as a Reasoned Exclusion with the recipe written down: each is a `_lengthBudget` / `signedUniverse` substitution, "a one-line application of its family root".

This is deliberately MECHANICAL work with the recipe already recorded. Its value is uniformity: a caller reaching for a `_lengthBudget` or `signedUniverse` form of a repaired terminus should find it landed rather than having to re-derive it, and a half-populated family is a trap for a future reader who assumes an absent member is absent for a reason.

SCOPE: read Phase 6's Reasoned Exclusions section in specs/433_discharge_postblockingsettles_residual/plans/01_postblockingsettles-refute-or-prove.md for the enumerated list and the recipe. The family roots and existing members are the `buildTableauAt_isSome_*` declarations in MintBound.lean (the `_at`, `_selfGuarded`, `_fixed` and `_run` families, roughly :6308-:12240). Land the fourteen missing members following the naming convention the file already uses; do not invent a new convention.

WHY THIS RUNS LAST: it restates termini at the repaired residuals, so it must run after the residuals themselves are settled. If 462, 463 or 464 changes a predicate's shape or sheds a hypothesis, the restatements must reflect the settled form -- doing this work earlier would mean doing it twice. Before starting, RE-DERIVE the list of missing members from the file as it then stands rather than trusting the count of fourteen recorded here: earlier tasks may have landed some, or added new family roots.

PROHIBITED: no `sorry`; additive only; do not alter any previously-landed declaration; do not edit Fuel.lean, Saturation.lean or Tableau.lean; axioms within {propext, Classical.choice, Quot.sound}; full `lake build` green. If any of the fourteen turns out NOT to be a one-line application -- i.e. the recipe does not actually apply -- STOP on that member, record why, and do not force it; a member that needs real mathematics belongs in its own task, not smuggled in here.

Dependencies: 462, 463, 464 -- all three, so that the restatements are made against a settled set of residuals rather than a moving one.

---

### 464. Gappotential density measure component
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: decidability
- **Dependencies**: Task 462, Task 463

**Description**: Design and land `gapPotential`, the density coordinate of the termination measure. This is the one genuinely OPEN MATHEMATICAL question remaining on the totality terminus; it is research, not plumbing, and should be run with --lit.

THE PROBLEM, stated exactly. `densityRule` mints a fresh time while lying OUTSIDE BOTH `freshLabelRules` AND `selfGuardRules`. Consequently no disjunct of the current measure moves at a `densityRule` step, FOR ANY sigma WHATSOEVER. This has been open since C9 register entry 17 named it, and task 434's Phase 8 records the current state bluntly: `gapPotential` "remains implemented nowhere and assumed by nothing". Because `densityRule` is `denseRules`-gated, this blocks a nonempty `MintPaysForTimeFixed` discharge at `.Dense` and `.Dedekind` frame classes specifically; every frame class needs `gapPotential` for a fully general result.

SHAPE SUGGESTED BY PRIOR WORK (a starting point, NOT a specification to follow blindly): task 434 records the expectation that `gapPotential` is indexed by `U x U` and `denseRules`-gated. Validate or refute that shape as part of the research; if a different indexing is correct, say so and justify it.

HARD REQUIREMENT -- PRESERVATION ACROSS THE IDENTIFICATION ARM. Any candidate component must be preserved across `TimeOrdering.identifyTime`, which can LOWER `ord.timeCount`. This is the same maxTime-lowering mechanism that refuted earlier candidates; see `nextTime_reissues_retired_time` and `reuse_driven_through_engine`, and task 436's oriented-arm re-gate (`orientedGate*` family, :8592-8788) for how the analogous obstacle was handled for the self-guard component. A component that pays at `densityRule` steps but is destroyed by the identification arm is not a solution.

REFUTED ROUTES -- C9 register entries 14, 17, 18, 19, 20, 24. Read them ALL in full before designing anything. In particular entry 14 forbids BOTH (1) re-indexing `mintPotential` on `freshTimeRules` instead of `freshLabelRules` -- refuted by `witnessPresent_eq_false_of_not_freshLabel`, whose match has exactly eight arms so the three added columns are permanently false -- and (2) dropping disjunct 1's cardinality conjunct in favour of the ordering-rank conjunct alone -- refuted by `splitOrderedRank_lt_of_knownTimes_lt` plus `mintPaysForTime_rank_repair_false`. Neither may be re-attempted.

LITERATURE. Run with --lit against the sub-index curated for this line of work, drawing specifically on: venema_2001 section 5 (interval-based temporal logic) for the density/gap-guarded component itself; caleiro_2013 sections 6-7 (mosaic-method decidability for combined tense-and-modal logics) as a structural analogue for a combined-logic termination measure; gerth_1995 and baier_katoen_2008 (closure-set LTL tableau termination) as a model for a measure over an evolving, non-monotonically-changing time set; and massacci_2000 for rule-bounding technique.

DONE MEANS EITHER: (a) `gapPotential` defined, its payment at `densityRule` steps proved, its preservation across `identifyTime` proved, integrated into the measure, and a nonempty `MintPaysForTimeFixed` discharge extended to `.Dense` and `.Dedekind`; OR (b) a machine-checked impossibility result showing no such component exists at the current measure's shape, with the obstruction identified precisely and a C9 entry recording it. Outcome (b) is a genuine and valuable result, NOT a failure -- this repo's practice is that a proved refutation ranks with a proof, and several of this measure's real advances came from refutations.

PROHIBITED: no `sorry`, no vacuous or false predicate, no weakening presented as a repair (a direction lemma is a GATE, not a nicety -- C9 entry 7 exists because that mistake was made once); do not edit Fuel.lean, Saturation.lean or Tableau.lean (md5-pinned frozen); additive only in MintBound.lean; axioms within {propext, Classical.choice, Quot.sound}; full `lake build` green.

Dependencies: 462 is a REAL SEMANTIC dependency -- the engine-level assembly is what makes a per-rule payment usable at the successor, and `gapPotential`'s payment needs the same threading. 463 is a file_scope SERIALIZATION edge only (both edit MintBound.lean), with no mathematical content.

---

### 463. Postblockingsettlesrun verdict at terminus fuel
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: decidability
- **Dependencies**: Task 462

**Description**: Decide `PostBlockingSettlesRun fc (mintAwareFuelAt U.card Tmax mintBudget D beta)` -- the narrowed settlement residual task 433 landed -- at the terminus's OWN fuel figure. Nothing currently decides it in either direction, and task 433's C9 register entry 24 exists precisely so the narrowing is not mistaken for a proof.

WHY THIS MATTERS. `PostBlockingSettlesRun` (MintBound.lean:11961) is CARRIED as a hypothesis by the fully-repaired terminus `buildTableauAt_isSome_of_budget_fixed_run` (:12199), exactly as `ArmSettlement` is. Until it is decided, the repaired terminus rests on an unknown. Task 433 established the surrounding facts but deliberately stopped short of this verdict.

WHAT IS ALREADY DECIDED -- consume, do not repeat:
- `PostBlockingSettles fc` (the unnarrowed form, :5181) is REFUTED: `postBlockingSettles_fuel_zero_false` (false at the `fuel = 0` arm at every frame class) and `postBlockingSettles_fuel_gap_false` / `postBlockingSettles_gap_at_every_fuel` (fuel does not close the gap, at ANY fuel). The witness is `freshWorldBranch = [F(box p)@<0,0>]`: `.boxNeg` mints a fresh world, so `expandOnceNoFresh` skips it and reports `.saturated` while `findUnexpandedUnblockedWith` reports it.
- `PostBlockingSettlesAt fc` (:11539) holds OUTRIGHT for every `fc` (`postBlockingSettlesAt_holds`, :11721) -- but the bridge from `saturateBlocked ... = some (.inr (satBr, satOrd))` to its antecedents does NOT go through, because at `fuel = 0` that equation holds at every branch while carrying no saturation information (`labelFreeSaturatedExit_not_of_saturateBlocked_inr`).
- Task 433 PROVED that the only bridge shape that typechecks carries a hypothesis that is itself refutable (it composes with the settlement lemma to give the refuted `PostBlockingSettles fc`). Do NOT re-attempt that bridge; it is a weakening dressed as a repair.

STRUCTURE THIS AS A REFUTE-FIRST GATE with a BINARY verdict, in the style tasks 432, 433 and 436 used successfully. Both outcomes are first-class deliverables:
- TRUE: `PostBlockingSettlesRun` holds at the terminus's own fuel figure -- discharge it, and the repaired terminus sheds a hypothesis.
- FALSE: it is refutable at that figure -- land the machine-checked refutation with its witness, record a C9 entry, and name the minimal further narrowing as the next step. A proved refutation here is as valuable as a proof and MUST NOT be treated as failure.

EMPIRICAL WARNING FROM TASK 433. Across fourteen formula shapes, four frame classes and three fuel figures, `buildTableauAt`'s own guard NEVER fired -- the threaded tracker and the recomputed `armTracker` agreed everywhere -- so no probed run exercised the post-blocking arm at all. That is a fact about the probe's reach, not about the residual, but it means this path is essentially untested empirically. Do not treat "no counterexample found by probing" as evidence of truth; the verdict must be proved either way, and if the honest answer is "undecided by the means available", say so explicitly with evidence rather than guessing.

PROHIBITED: do not discharge via `ArmSettlement` (proved strictly too weak: `resolveOpenArm` tests `findClosure satBr` before its saturation test, `buildTableauAt` does not); do not edit Saturation.lean, Tableau.lean or Fuel.lean (md5-pinned frozen) -- use only their existing public interface; do not re-attempt anything in the C9 register; no `sorry`, no vacuous discharge. Sorry-free, axiom-free, additive only, full `lake build` green.

Dependencies: 462, as a file_scope SERIALIZATION edge only (both tasks edit MintBound.lean). There is no mathematical dependency on 462 -- this task's content is independent of the minting measure and may be reasoned about immediately.

---

### 462. Mintpaysfortime engine level assembly
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: decidability
- **Dependencies**: Task 469, Task 470

**Description**: Land the engine-level assembly that lets `MintPaysForTimeFixed` be discharged at a NONEMPTY universe. This is the plumbing half of the residual task 434 left open at its Phase 8; it is explicitly proof engineering, not open mathematics, and task 434's own handoff records it as "spawnable on its own".

THE GAP. Every per-rule payment `MintPaysForTimeFixed` needs is already landed in MintBound.lean, but each is stated AT THE PICK, while the predicate quantifies over `unorderedSuccessorBranches (expandOnceUnblocked b ord fc tr).1`. The missing work is threading the picked rule through `expandOnceUnblocked`'s three stages so the per-rule case split is available at the successor, for all thirty-six constructors at once.

WHAT ALREADY EXISTS -- consume, do not re-author:
- disjunct 2, the six rules in `freshLabelRules INTER freshTimeRules`: `mintPotential_lt_of_pick_linear_sigmaFixed` and `mintPotential_lt_of_pick_branching_sigmaFixed`, discharged from confinement plus `SigmaFixed` by `sigma_formula_hit_of_sigmaFixed`.
- disjunct 3, the two rules in `selfGuardRules`: `selfGuardPotential_lt_of_untlNeg` and `selfGuardPotential_lt_of_snceNeg`.
- disjunct 1, the twenty-seven rules outside `freshTimeRules`: `applyRule_emitted_time_dichotomy` (MintBound.lean:7048) plus `expandOnceUnblocked_ord_mono` (:1945).
- `MintPaysForTimeFixed` (:10499) and its direction lemma; `mintPaysForTimeFixed_signedUniverse_empty` (:11096) is the current boundary-only discharge this task is meant to supersede.

DONE MEANS: `MintPaysForTimeFixed fc (signedUniverse C L) Tmax` discharged at NONEMPTY `L`, at every frame class OUTSIDE `.Dense` and `.Dedekind`, landed sorry-free and axiom-free with `lake build` green. The `.Dense`/`.Dedekind` classes are deliberately EXCLUDED from this task's scope: they additionally require `gapPotential` for the density coordinate, which is a separate research task and must NOT be attempted here. State the frame-class restriction explicitly in the theorem, do not hide it.

PROHIBITED: do not re-attempt anything in the C9 do-not-re-attempt register (read entries in full first, especially 14, 17, 18, 19, 20); do not edit Fuel.lean, Saturation.lean or Tableau.lean (md5-pinned frozen); do not alter any previously-landed declaration; no `sorry`, no vacuous discharge, no predicate that is itself false. If the assembly turns out to need genuinely open mathematics rather than plumbing, STOP and record that finding with evidence rather than forcing it -- that outcome is a legitimate deliverable and should be recorded as a new C9 entry.

Dependencies: none. This task is unblocked today.

---

### 461. Acquire Goldblatt 1989 'Varieties of complex algebras' (Annals of Pure and Applied Logic)
- **Status**: [BLOCKED]
- **Task Type**: general
- **Topic**: literature
- **Dependencies**: Task 460
- **Research**: [461_acquire_goldblatt_1989_varieties_of_complex_algebras/reports/01_acquisition-feasibility.md]

**Description**: SCOPE 8 acquisition gap identified by task 457's research and re-confirmed at implementation time: this paper is absent from both the ~/Projects/Literature corpus and the Zotero library, and is named as a prerequisite by other tasks in this repo working on the Jonsson-Tarski representation theorem. Note: goldblatt_2003 already present in the corpus is a DIFFERENT paper (Erdos Graphs Resolve Fine's Canonicity Problem) -- do not conflate the two. Needed: locate and acquire a copy of Goldblatt 1989 (Annals of Pure and Applied Logic 44, pp. 173-242), add it to Zotero, then run a normal /literature ingest.

---

### 455. Survey and realign remaining tasks and roadmap
- **Status**: [NOT STARTED]
- **Task Type**: meta
- **Topic**: code-quality
- **Dependencies**: Task 452, Task 454, Task 468

**Description**: BACKLOG REALIGNMENT: bring specs/ROADMAP.md and every remaining active task into agreement with
the progress actually made and the goals actually remaining.

Ordering is not optional. Stage 1 (ROADMAP) produces the reference frame that Stages 2-4 judge
every task against. Do not begin surveying tasks before the roadmap states what remains.

=== 0. WHY THIS TASK EXISTS ===

A prioritization review (specs/reviews/review-2026-08-18.md) sampled a handful of tasks and found
description rot in most of what it touched: file:line anchors past end-of-file, an acceptance
criterion pinned to four line numbers that had all moved, a governing design built on a Lean
parameter deleted by a completed refactor, and a "gate" that gates nothing in the dependency
graph. That review corrected the six strong-completeness tasks on the critical path (its
predecessor task) and the two worst ROADMAP sections (its dependency). It did NOT sweep the
remaining backlog, and there is no reason to think the rot stopped at the sample.

The tree has moved a long way underneath these descriptions: the total-history-validity refactor,
the untl/snce guard-first argument-order migration (3,711 occurrences across 152 files), the
paper-refactor cluster, the bi-lasso decision layer, and the arrival of a sorry count of ONE. Many
task descriptions predate several of those.

=== 1. STAGE 1 -- REFINE specs/ROADMAP.md (do this FIRST) ===

The dependency task corrects two specific inverted sections (the Sorry Inventory's false 23-vs-1
count, and the "BXCanonical Path (DEAD CODE)" mislabel). That is triage, not completeness. This
stage finishes the job: make ROADMAP.md an accurate statement of WHAT REMAINS.

(a) Audit the whole file, not the two sections already fixed. It is ~1,770 lines and is
selectively maintained -- some sections were current as of 2026-08-10 while others had not been
touched since April. For every section, establish whether it describes (i) current reality,
(ii) settled history that should be explicitly marked historical, or (iii) a stale claim that must
be corrected or deleted. The 111 status-table rows are the roadmap-integration matching surface
and parse cleanly; treat them with care but do not assume they are current.

(b) Ground every status claim in a machine-checkable source. scripts/check-module-invariants.sh is
the generator of record: C2 for the flagship axiom sets, C3 for the live sorry inventory, C4/C5 for
reference resolution, C7 for file counts. A claim in ROADMAP.md that no check can reproduce is
either rewritten to be reproducible or removed.

(c) Add the missing forward-looking content. The file is heavy on how things were built and light
on what is left. It should state, per active front (strong completeness, decidability, FMP,
paper/publication, dataset, hygiene), what remains, what the terminus looks like, and what is
known to be blocked or refuted. Refuted routes deserve explicit tombstones -- the strong-
completeness cluster already carries at least one hard-won refutation (the Base-MCS to
Discrete-MCS transfer lemma, killed by a lex-order countermodel) whose whole value is that nobody
re-attempts it.

(d) Make the sections that rotted structurally harder to rot. Where a section restates a fact a
script can compute, say which script computes it and when it was last reconciled.

=== 2. STAGE 2 -- SURVEY EVERY REMAINING TASK ===

Cover every task in specs/state.json active_projects EXCEPT the six already re-issued by the
predecessor task (169, 362, 421, 422, 423, 424) and this task's own dependencies. At the time of
writing that is roughly 35 tasks across the topics: decidability, completeness, dataset-enhancement,
formula-refactor, frame-extensions, publication-quality, algebraic-representation, automation,
proof-system-infrastructure, repo-hygiene, code-quality.

For each task, produce a verdict in one of these categories, with evidence:

  CURRENT     -- description matches the tree; no change needed. Say what you checked.
  RE-ANCHOR   -- substance intact, citations drifted. List the drifted anchors and fix them.
  RE-SCOPE    -- the work is still wanted but the description's premise has moved (a vocabulary it
                 names is gone, a lemma it targets has been proved, a route it proposes is
                 refuted). State the new scope.
  SUPERSEDED  -- the work has been done, or subsumed by another task. Name what did it. Propose
                 completion or abandonment; do NOT change status unilaterally (see section 5).
  OBSOLETE    -- the goal itself no longer serves the project. Argue it and propose abandonment.

Specific checks each task must survive:
  - Every file:line and symbol it cites resolves in the live tree. Prefer symbol names over line
    numbers when rewriting; line-number anchors are the observed failure mode.
  - No dependency on a task that is archived-but-unsatisfying, and no dangling dependency. (All 41
    edges resolved as of 2026-08-18 -- confirm this still holds and keep it true.)
  - Acceptance criteria are still satisfiable. The observed failure was an acceptance criterion
    demanding byte-comparability against four specific line numbers, none of which still held the
    definitions.
  - Any "PRE-EXISTING RED" or baseline note it records still describes the current build. At least
    one task was found carrying a stale baseline naming a compile failure that no longer exists
    while the real failure had moved elsewhere.
  - Stated priority still reflects reality given what has since landed.

=== 3. STAGE 3 -- RECONCILE THE DEPENDENCY GRAPH ===

Descriptions and edges must agree. The observed failure mode was a task describing itself as a
"feasibility gate" while no task listed it as a dependency, so Kahn's algorithm in
generate-task-order.sh placed it in wave 1 alongside the work it claimed to gate.

  (a) For every task whose prose asserts it blocks, gates, or must precede other work, verify a
      corresponding edge exists. Add it, or downgrade the prose. Do not leave both readings.
  (b) Look for the converse: declared edges with no justification in either description.
  (c) Re-derive the wave structure afterwards and sanity-check it against the stated goals. If the
      capstone of a front is not downstream of that front's open work, something is miswired.
  (d) Confirm active_topics in state.json still matches the topics tasks actually carry
      (generate-task-order.sh warns on undeclared topics rather than failing).

=== 4. STAGE 4 -- REPORT ===

Deliver a survey artifact under this task's reports/ directory containing:
  - the per-task verdict table (task, topic, verdict, evidence, action taken)
  - every anchor corrected, with old -> new
  - every dependency edge added or removed, with justification
  - the ROADMAP.md changes and what machine-checked source grounds each
  - an explicit list of tasks proposed for completion or abandonment, for user decision
  - a short statement of the resulting critical path per front

=== 5. CONSTRAINTS ===

- Descriptions, ROADMAP.md, and dependency edges are in scope. TASK STATUS IS NOT. Propose
  completions and abandonments in the report; do not transition any task to completed, abandoned,
  or expanded. That decision stays with the user.
- No .lean edits. This task proves nothing and closes no sorry.
- All specs/state.json writes go through .claude/scripts/state-write.sh; TODO.md is regenerated via
  generate-todo.sh, never hand-edited.
- Do not re-touch the six tasks handled by the predecessor task. If the survey finds a defect in
  one of them, record it in the report rather than editing it, so the two passes cannot conflict.
- Every claim about build state, sorry counts, or axiom sets must cite the check that produced it.
  Do not restate a status from another description as if it were verified -- the stale-baseline
  finding above is exactly that failure.

=== 6. VERIFICATION ===

- scripts/check-module-invariants.sh C5 passes (module-shaped paths in markdown resolve), which
  covers the rewritten ROADMAP.md.
- Zero dangling dependency edges across active_projects.
- Every task in the survey has a verdict; no task is silently skipped. A task judged CURRENT still
  gets a row saying what was checked.
- generate-todo.sh regenerates cleanly with no undeclared-topic warnings.

=== 7. NON-GOALS ===
- Does not implement, research, or plan any surveyed task.
- Does not archive anything (that is /todo's job, after the user acts on the report).
- Does not restructure the topic taxonomy; it only reports desync.

---

### 451. Consolidate boneyard archives
- **Effort**: medium
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Topic**: repo-hygiene
- **Dependencies**: Task 470
- **Plan**: [451_consolidate_boneyard_archives/plans/01_consolidate-boneyard-archives.md]
- **Research**: [451_consolidate_boneyard_archives/reports/01_consolidate-boneyard-archives.md]
- **Summary**: [451_consolidate_boneyard_archives/summaries/01_consolidate-boneyard-archives-summary.md]

**Description**: CONSOLIDATE THE TWO BONEYARDS into a single archive tree under FormalSystem/Boneyard/, preserving git history via git mv, and add the missing infrastructure that keeps an UNCOMPILED archive honest.

=== 1. THE SITUATION (verified 2026-08-17) ===
The repository has two archive trees:
  FormalSystem/Boneyard/                                  93 .lean, 59,019 lines
  FormalSystem/Metalogic/WeakCanonical/Kamp/Boneyard/     63 .lean, 29,256 lines
Total archived: 156 files; live tree is 373 of 529.

The second is nested five levels deep and is easy to miss. Both READMEs already carry a "There Are TWO Boneyards" warning because past repository counts were wrong for exactly that reason -- a find/grep filter naming only the top-level archive silently counts ~29k archived lines as live code.

Neither archive is excluded in lakefile.lean. Exclusion works two ways: (i) nothing live imports either tree, so they are outside the import closure and never compiled; (ii) tooling filters on the NAME glob `-not -path '*/Boneyard/*'` (scripts/check-module-invariants.sh:63, scripts/readme-lint.sh at :50,:70,:102,:133,:154,:161,:165). Because the filter is by name, it already covers both trees -- so consolidation does NOT change the build. The case for it is navigability, documentation discipline, and eliminating a class of counting bug, not build correctness.

=== 2. PRE-VERIFIED SAFETY FACTS (do not re-litigate; re-confirm cheaply) ===
- ZERO live importers: `grep -rn "^import .*Boneyard" FormalSystem/ Tests/ --include=*.lean | grep -v "/Boneyard/"` is EMPTY. Also empty for any non-import textual reference to Kamp.Boneyard or Kamp/Boneyard from a live file. The top-level Boneyard likewise has no live importers.
- OUTBOUND imports are unaffected by the move. Kamp Boneyard files import three LIVE modules (FormalSystem.Metalogic.WeakCanonical.Kamp.EANegation, .EANegationClosure, .ESigmaCapture). Import statements name the IMPORTED module, which is not moving, so these keep resolving.
- NAMESPACES are not path-derived. The moved files declare `namespace FormalSystem.Metalogic.WeakCanonical`, `...Kamp`, `...Separation`, `RenderGate` -- none tied to the Boneyard path segment. No namespace edits are required.

=== 3. THE ONE REAL HAZARD ===
52 INTRA-ARCHIVE import lines inside the Kamp Boneyard name modules under `FormalSystem.Metalogic.WeakCanonical.Kamp.Boneyard.*` (e.g. Separation/DualEliminations.lean:16-18, Separation/Hierarchy/HierarchyDefs.lean:16-17, ArityReduction.lean:1). Every one of these breaks when the files move, because the MOVED files' module names change.

Because archived files are never compiled, a broken import here is SILENT -- no build, no test, and no existing check catches it. That is the defect this task must not introduce, and the reason deliverable 4 exists. (The top-level Boneyard has 47 analogous self-imports; those files are not moving and are unaffected, but the new checker must cover them too.)

=== 4. DELIVERABLES ===
(a) MOVE, with git mv exclusively -- never delete-and-re-add, never cp. History preservation is a hard requirement, not a preference: the whole point of a scrapyard is that `git log --follow` still explains why each file died. Target: FormalSystem/Boneyard/KampWeakCanonical/. PRESERVE the existing internal structure rather than flattening: ZetaProbes/, NfMultiAnchorBridgeRetired/, Separation/ (with Separation/DedekindZ/ and Separation/Hierarchy/), ExpressiveCompleteness/.
(b) RECONCILE with the existing FormalSystem/Boneyard/KampBypassArchive/ (13 files: KampBypass*.lean, KampForward, KampMutualInduction, NfCharFormula, PriorComposition{,_old}, GeneralExistPart). Kamp material has been migrated to the top-level archive before, so the result must be ONE coherent Kamp region, not two sibling directories that each look authoritative. Either nest both under a Kamp umbrella or state in writing why they stay separate.
(c) REWRITE the 52 intra-archive import lines to the new module paths. Mechanical, but every one must be verified to resolve -- see (d).
(d) NEW CHECKER: a script (or a new check group in scripts/check-module-invariants.sh) asserting that EVERY import line in every Boneyard file names a module that exists on disk -- whether it points at live code or at another archived file. This is the missing infrastructure. Uncompiled code has no compiler to catch rot, so the archive needs its own resolution check or it silently decays into unrevivable rubble. Wire it into the invariant script so it runs with everything else.
(e) UPDATE the B0 self-test (scripts/check-module-invariants.sh:70-74) from "exactly 2 directories" to 1. B0 is a PASS-asserting self-test and WILL fail loudly the moment anything moves -- that is correct behavior, not breakage. Also re-check the :20-22 comment block, whose two-Boneyard warning becomes obsolete.
(f) READMEs. Merge the two contradictory "There Are TWO Boneyards" sections into one accurate statement. NOTE THE DRIFT: FormalSystem/Boneyard/README.md records the Kamp archive as 62 files / 27,394 lines while the Kamp README records 63 / 29,256 and the filesystem agrees with the latter; the top-level README also states 59,010 lines for itself against an actual 59,019. Stale hand-maintained counts are part of what this task retires -- prefer counts the invariant script emits (C7) over numbers re-typed into prose.
(g) PER-APPROACH DOCUMENTATION, which is the user-facing point of the exercise. The top-level archive already has the right convention: one subdirectory per abandoned approach, each with a README explaining what it was, why it died, and what would have to change for it to be worth reviving (see ClosedGuardLegacy/, DenseChronicle/, UltrafilterFrame/, RoundRobinChain/, NonBurgessSeed/, StageInductionGapAnalysis/). The Kamp archive is largely flat under a single README. Bring it up to that convention. Every README must record the file's ORIGINAL PATH so provenance survives the move even for a reader who never runs git log.

=== 5. NON-GOALS ===
- Do NOT revive, repair, or compile any archived code. Archived files stay uncompiled and outside the import closure.
- Do NOT modify any live module. If a live module turns out to need a change, that is a separate task -- stop and report.
- Do NOT delete anything. This is a consolidation, not a purge. Deciding what deserves deletion is a different judgment call and is explicitly out of scope.
- Do NOT add the archive to lakefile.lean in any form.

=== 6. VERIFICATION CONTRACT ===
- `git log --follow` resolves through the move for a sampled file from each moved subdirectory. If it does not, the move was done wrong -- redo it with git mv.
- `git status` shows renames (R), not delete+add pairs, for all 63 files.
- lake build exits 0 and its output is UNCHANGED from before the move -- nothing live imports either archive, so a build difference means something was moved that should not have been.
- Repository live-sorry count stays at exactly 1 (countermodel_discrete, WeakCanonical/Transfer.lean), via scripts/check-module-invariants.sh, never naive grep.
- check-module-invariants.sh: B0 green at 1 directory; C7's live inventory unchanged (373 live .lean) since only archived files move.
- The new checker (d) is green, including the 47 pre-existing top-level self-imports.
- scripts/readme-lint.sh still skips the consolidated tree correctly (its six *Boneyard* guards match by name, so they should, but verify rather than assume).
- PRE-EXISTING RED, inherited not caused: C6 (SoundnessLemmas/CoValidity.lean:104 `simp` made no progress), C9 (task-number citation in WeakCanonical/PriorExpressivenessDense.lean:185), and `lake build BimodalTest` (#guard_msgs drift in RegionGateProbe, TableauConformance, BoxSpreadProbe). None are in scope here; do not attempt to fix them, but confirm they are no WORSE afterward.

---

### 434. Discharge mintpaysfortime residual
- **Effort**: 10-15 hours
- **Status**: [PARTIAL]
- **Task Type**: lean4
- **Topic**: decidability
- **Dependencies**: Task 436
- **Research**:
  - [428_engine_totality_at_a_quantified_branch_budget/reports/05_spawn-analysis.md]
  - [434_discharge_mintpaysfortime_residual/reports/01_spawn-inherited-research.md]
  - [434_discharge_mintpaysfortime_residual/reports/02_spawn-analysis.md]
- **Plan**: [434_discharge_mintpaysfortime_residual/plans/01_mintpaysfortime-time-analogue.md]
- **Summary**: [434_discharge_mintpaysfortime_residual/summaries/01_mintpaysfortime-time-analogue-summary.md]

**Description**: Discharge `MintPaysForTime fc U Tmax`, defined at FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean:3945, the open mathematical core among the four residual hypotheses on the totality terminus `buildTableauAt_isSome_of_budget` (MintBound.lean:4416). Two disjuncts to establish. First disjunct ('a step that does not raise the known-time count does not raise the rank'): the naive reading 'non-ruleMintsFreshLabel implies no new time' is FALSE -- `densityRule` interpolates a fresh time while deliberately absent from `ruleMintsFreshLabel` (it carries its own `existingIntermediates` guard), and the active-mode arms of `untlNeg`/`snceNeg` introduce times without being witness-guarded; the correct test is the ordering-length one `expandOnceNoFresh` already uses (`newOrd.constraints.length`), not the rule list. Establishing this disjunct means proving a time-dimension analogue of `applyRule_emitted_world_mem` keyed on that ordering-length test. Second disjunct (cashed at the once-only bound, carrying the sigma-hit obligation from `mintPotential_lt_of_pick_linear` / `_branching`): the formula the rule fires on must be `sigma sf` for some `sf in U`; this is entangled with the time-reuse question -- `Branch.nextTime = maxTime + 1` while `Branch.identifyTime` can LOWER `maxTime`, so whether the engine can re-issue a time an earlier identification retired is genuinely open (the live-times reformulation carries the identical obligation, confirming it is intrinsic rather than an artifact of the measure). Done means: a theorem proving `MintPaysForTime fc U Tmax` for a concrete, useful instantiation, landed sorry-free and axiom-free in MintBound.lean, with `lake build` green. Do not re-attempt anything in the do-not-re-attempt register at MintBound.lean:4455-4510 (eight entries; read before starting) -- in particular do not re-litigate `witnessPresent_identifyTime`'s unconditional form (entry 5, refuted by `witnessPresent_identifyTime_unconditional_false`) or `OrdTimesLeMaxTime` preservation across the identification arm (entry 7, refuted by `ordTimes_identifyTime_arm3_false`; the settled repair is `OrdTimesKnown`). This task's own residual work -- the engine-level assembly needed to make a per-rule payment usable at the successor (462), and the gapPotential density coordinate for .Dense/.Dedekind frame classes (464) -- has moved downstream to tasks 462 and 464; do not re-attempt those here.

---

### 433. Discharge postblockingsettles residual
- **Effort**: 6-10 hours
- **Status**: [PARTIAL]
- **Task Type**: lean4
- **Topic**: decidability
- **Dependencies**: Task 432, Task 434
- **Research**:
  - [428_engine_totality_at_a_quantified_branch_budget/reports/05_spawn-analysis.md]
  - [433_discharge_postblockingsettles_residual/reports/01_spawn-inherited-research.md]
- **Plan**: [433_discharge_postblockingsettles_residual/plans/01_postblockingsettles-refute-or-prove.md]
- **Summary**: [433_discharge_postblockingsettles_residual/summaries/01_postblockingsettles-summary.md]

**Description**: Discharge `PostBlockingSettles fc`, defined at FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean:4344, one of the four residual hypotheses on the totality terminus `buildTableauAt_isSome_of_budget` (MintBound.lean:4416). It states that the post-blocking pass leaves a branch the blocking-aware saturation test certifies -- i.e. `findUnexpandedUnblockedWith satBr satOrd fc (blockedTimes satBr satOrd fc (armTracker satBr)) = none` whenever `saturateBlocked ob fuel oOrd fc = some (.inr (satBr, satOrd))`. It subsumes `resolveOpenArm`'s own `none` arm via `armSettlement_of_postBlockingSettles` (MintBound.lean:4354) -- `ArmSettlement` alone is proved strictly too weak (`resolveOpenArm` tests `findClosure satBr` before its saturation test; `buildTableauAt` does not), so do not attempt to discharge via `ArmSettlement` instead. The relevant definitions are frozen (md5-pinned) in Saturation.lean (`saturateBlocked`, :431) and Tableau.lean (`blockedTimes`, :2104; `findUnexpandedUnblockedWith`, :2115) -- do not edit either file; the residual's own docstring states the gap ('whether the fuel-vs-condition gap can be closed by fuel alone') is exactly what Saturation.lean leaves open using only its existing public interface. Done means: either (a) a proof of `PostBlockingSettles fc` for the frame classes the terminus is meant to be used at, using only the public interface of the frozen files, landed sorry-free and axiom-free with `lake build` green; or (b), if (a) turns out to be genuinely impossible without touching the frozen files, a return to [BLOCKED] with the specific counterexample or obstruction found, analogous to the parent task's own refutation-driven repairs (e.g. `ordTimes_identifyTime_arm3_false`, MintBound.lean:1217) -- do not paper over with a vacuous definition (`lean4.md`'s Vacuous Definitions prohibition applies). This task's own residual work -- deciding PostBlockingSettlesRun at the terminus's own fuel figure, and completing the terminus restatement family -- has moved downstream to tasks 463 and 465 respectively; do not re-attempt those here.

---

### 430. Semantic lift and track a assembly valid iff allclosed
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: decidability
- **Dependencies**: Task 428, Task 429, Task 411

**Description**: The semantic lift and the Track A assembly. Owns obstruction O4 of the Phase 7.3 deadlock, then delivers what Phase 7.3 of task 165 was for. Grounding: specs/165_establish_semantic_finite_model_property/reports/09_phase7-deadlock-blocker-research.md.

THIS TASK CARRIES THE WORK MOVED OUT OF TASK 165's PHASE 7.3. Task 165 terminated with Phase 7 scoped to what it delivered (the truth lemma and Track A's conditional results); 7.3 -- `valid_iff_allClosed` and the `Decidable` instances -- was moved here rather than closed, because it is blocked on prerequisites no task owned.

O4 HAS TWO DISTINCT PIECES, per Verified/Decidable.lean:3062-3067: "It is not yet `valid_iff_allClosed` (7.3), which additionally needs the fuel/termination side and the truth-lemma gate, and it says nothing about the two rules scheduled outside `allRulesForFC` -- `serialityRule` and `timeLinearity` run as stages 2 and 3 of `expandOnce` and need their own obligations at the point where `expandOnce`, rather than `applyRule`, is the object."

(a) Two more `RuleSound`-analogues at the `expandOnce` level, for `serialityRule` and `timeLinearity`. These are deliberately outside `allRulesForFC`, so `ruleSound_of_mem_allRulesForFC` (landed, 34/34) does NOT cover them.
(b) THE SEMANTIC LIFT: the induction lifting single-step satisfiability preservation to the whole recursion, so that `.allClosed` yields a contradiction. This is the LARGER of the two and is comparable in weight to a landed sub-phase, not to a wrapper. Naming it inside "the two outside rules" understates it.

THEN, and only after (a), (b) and both predecessors: `valid_iff_allClosed` plus the four `Decidable` instances for validity over Base, Dense, Discrete and Dedekind.

WHAT IS ALREADY LANDED (do not re-prove): the rule half is done -- `ruleSound_of_mem_allRulesForFC` is a single landed induction over `mem_allRulesForFC_iff`, ledger complete at 34/34, from task 165 Phase 7.2.

PLAN AGAINST SIX ROWS, NOT EIGHT: the truth-lemma gate hypothesis hTW is discharged on SIX accepted TemporalWitnessProbe rows (A, B, C, D, E, F), not the historical eight -- rows I and K left when the PASSIVE arms of untlNeg/snceNeg were retired. See the banner at the head of Tests/BimodalTest/TemporalWitnessProbe.lean.

DO NOT write a conditional `valid_iff_allClosed` carrying hTW as an explicit hypothesis. Correctness.lean:98-105 refuses exactly this shape, and the O4(b) hypothesis would BE the conclusion's forward direction, making the theorem vacuous. Four vacuous theorems were deleted in 165's Phase 8; do not land a fifth.

DONE WHEN: `valid_iff_allClosed` and the four `Decidable` validity instances are landed unconditionally, sorry-free and axiom-clean outside Boneyard, lake build green.

---

### 429. Repair truth lemma side conditions boxanchored and temporalwitness
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: decidability
- **Dependencies**: Task 428

**Description**: Repair the truth-lemma side conditions. Owns obstructions O2 and O3 of the Phase 7.3 deadlock recorded in specs/165_establish_semantic_finite_model_property/reports/09_phase7-deadlock-blocker-research.md. THIS IS THE TASK WITH GENUINE OPEN MATHEMATICS IN IT and should be budgeted accordingly.

READ FIRST: specs/418_*/artifacts/boxanchored-finding.md -- it carries the measurement, the full carrier list, and the repair options. Then TruthLemma.lean:399-404 and BoxSaturation.lean:430-435, :574-580.

O2 -- `hBA` (`boxAnchoredCheck`) is no longer dischargeable on multi-world branches. BoxSaturation.lean:430-435: the two copy blocks "have since been removed as unsound ... They were the ONLY route by which T(G phi)/T(H phi) could reach a freshly minted world ... `boxAnchoredCheck` is therefore expected to compute `false` on multi-world branches now." :574-580: "a caller can no longer expect to discharge that hypothesis from a real run." TruthLemma.lean:399-404 names the repair as "an open design decision with its own soundness obligations" and lists THREE candidate routes: (a) propagate T(box phi) itself; (b) copy T(G phi)/T(H phi) only when box-derived; (c) restructure the `box` case to need no anchor.

CRITICAL CONSTRAINT: this was caused by task 418 (completed) removing a GENUINE UNSOUNDNESS. It is the cost of a correct fix, not a regression to revert. TruthLemma.lean:404 says "Do NOT reinstate the removed copies." Any repair must re-establish the anchor WITHOUT reinstating them.

O3 -- `hTW` (`temporalWitnessCheck`) is no longer dischargeable on any branch carrying a negative until with a known future time. TemporalWitnessProbe.lean:66-73: `untlNegFuture` demands F(event) at every known future time of every negative until; the PASSIVE arm's branch 1 was the ONLY producer of `not event` at an EXISTING time; that arm was retired as unsound (user-authorized rank 2), so the producer is gone. Measured cost: fourteen probe rows moved check=true -> check=false; the accepted set went from EIGHT rows to SIX (rows A, B, C, D, E, F; I and K left). :86-88: "it was already `false` on the branches the engine actually builds. What it removes is the last set of hand-built branches on which the hypothesis was discharged."

DO NOT REOPEN (settled by 165): guardWitnessed in any variant; restoring sat_untl_neg / sat_snce_neg (they are FALSE against the current engine, not merely unproved); reinstating the retired PASSIVE arms or the removed box copy blocks.

GOAL: choose among the three documented BoxAnchored repair routes and land it with its soundness obligations discharged; and re-establish a producer for `not event` at existing future times. Both must hold on branches the engine ACTUALLY builds, measured by the probes, not on hand-built branches.

DONE WHEN: `boxAnchoredCheck` and `temporalWitnessCheck` are dischargeable on real engine output for the relevant branch classes, evidenced by probe rows moving back to check=true; no unsound copy block or retired arm is reinstated; lake build green.

---

### 428. Engine totality at a quantified branch budget
- **Status**: [BLOCKED]
- **Task Type**: lean4
- **Topic**: decidability
- **Dependencies**: Task 432, Task 433, Task 434, Task 465
- **Plan**:
  - [428_engine_totality_at_a_quantified_branch_budget/plans/02_lexicographic-splitordered-measure.md]
  - [428_engine_totality_at_a_quantified_branch_budget/plans/03_mint-bound-irreflexivity-totality.md]
  - [428_engine_totality_at_a_quantified_branch_budget/plans/04_ordtimesknown-strengthening-totality.md]
  - [428_engine_totality_at_a_quantified_branch_budget/plans/01_budget-totality-engine-repair.md]
- **Summary**:
  - [428_engine_totality_at_a_quantified_branch_budget/summaries/02_lexicographic-splitordered-measure-summary.md]
  - [428_engine_totality_at_a_quantified_branch_budget/summaries/01_budget-totality-engine-repair-summary.md]
  - [428_engine_totality_at_a_quantified_branch_budget/summaries/04_ordtimesknown-strengthening-totality-summary.md]
- **Research**:
  - [428_engine_totality_at_a_quantified_branch_budget/reports/03_phase11-potential-obstruction.md]
  - [428_engine_totality_at_a_quantified_branch_budget/reports/04_witness-preservation-machine-checked.md]
  - [428_engine_totality_at_a_quantified_branch_budget/reports/01_budget-totality-refuted-and-repair.md]
  - [428_engine_totality_at_a_quantified_branch_budget/reports/02_splitordered-measure-blocker.md]
  - [428_engine_totality_at_a_quantified_branch_budget/reports/05_spawn-analysis.md]

**Description**: Engine totality at a quantified branch budget. Owns obstruction O1 of the Phase 7.3 deadlock recorded in specs/165_establish_semantic_finite_model_property/reports/09_phase7-deadlock-blocker-research.md section "The four obstructions" (read it first; do not re-derive the refutation).

THE REFUTED THEOREM, SETTLED: `buildTableau_isSome` in unconditional form is FALSE, not merely unproved, and is on a do-not-re-attempt register (165's plan 01_tableau-decidability-two-track.md:1405-1420, :1489-1493). The refutation is a property of the engine SIGNATURE, not a proof difficulty: `buildTableau` (Saturation.lean:928-951) calls `expandBranchWithFuel` at the default `maxBranches := 50000` (Saturation.lean:590), whose first line is `if branchesUsed >= maxBranches then none` (:594). A formula exploring more than 50000 branches returns `none` at ANY fuel whatsoever. Independently, `buildTableau`'s last arm returns `none` on a still-unsaturated branch (:950). Neither is fuel exhaustion, so no fuel figure rules them out. DO NOT attempt the unconditional form.

WHAT LANDED INSTEAD, and why it is unusable as-is: Verified/Termination/Fuel.lean:1587-1598 carries two hypotheses -- `(hP : NoSplit P fc)` and `(hbud : branchesUsed + fuel <= maxBranches)`. `NoSplit` excludes impPos, orPos, untlPos, untlNeg, sncePos, snceNeg, orderTrichotomy and every frame-class-gated splitting rule, i.e. it holds only on non-branching runs. 165's plan:1467-1468 records "Residual 2 (branching arms) -- isolated, not discharged."

GOAL: add a `maxBranches`-parameterised entry point ALONGSIDE `buildTableau` -- an ADDITION, never an edit to the existing default, because `maxBranches = 50000` is a deliberate runtime guard -- and prove totality against a quantified budget. Target shape:

  theorem buildTableau_isSome_of_budget (phi : Formula) (fc : FrameClass)
      (maxBranches : Nat) (hmb : <bound in phi> <= maxBranches) :
      (buildTableauAt phi (soundFuel' phi) fc maxBranches).isSome = true

THREE SUB-OBLIGATIONS:
1. Discharge the branching-arm residual that `NoSplit` currently hypothesises (Fuel.lean:1587, Saturation.lean:661-664, :686-689).
2. Supply the missing WORLD-COUNT dimension. 165's plan:1484-1488: "T1 bounds formulas and T2 bounds times; neither bounds worlds ... as defined, `soundFuel' = 2*n*2^(2n)` has no world factor at all." A branch bound that ignores worlds cannot bound branches.
3. Establish the `<bound in phi> <= maxBranches` side condition in a form callers can actually discharge.

COORDINATION: overlaps task 426's hypothesis (b) on the same file (Fuel.lean). Sequence with 426 or merge; do not both edit Fuel.lean concurrently. Task 412 consumes this theorem in place of the refuted `buildTableau_isSome`.

DONE WHEN: the budget-parameterised totality theorem is landed sorry-free with no `NoSplit` hypothesis, lake build green, and the world dimension is either supplied or its absence is proved harmless.

RETARGET DECISION (user-approved, post-research): the specified unconditional target shape is refuted (see reports/01_budget-totality-refuted-and-repair.md). Task WIDENED to own the validated certificate repair: swap findUnexpanded -> findUnexpandedUnblocked at resolveOpenArm's two decision points, discharge the accompanying soundness obligation on what .hasOpen certifies (shared with O2/O3), lift the proved saturateBlocked_isSome asset, close the world dimension via worldFuel'/WorldWitness, and land the budget-parameterised totality theorem against the repaired engine. The per-path budget finding (maxBranches >= 3*fuel linear invariant) supplies the side condition.

SECOND RETARGET DECISION (user-approved, post-research 03). The per-step framing of Phase 11 cannot be closed: reports/03_phase11-potential-obstruction.md section 4 is a proof about the SHAPE of the argument, not a report of a failed attempt. Route (a) (a lower bound on branch cardinality after identification) is DEAD by definition -- `Branch.identifyTime = (b.map relabel).eraseDups`, so all shrinkage comes from eraseDups and is bounded only by |U|. Route (b) (an independent mint bound) is the APPROVED path.

THE CHEAPER ALTERNATIVE IS EXPLICITLY REJECTED BY THE USER: do NOT carry the mint bound as a hypothesis in the shape `hT` has, and do NOT push the discharge obligation onto task 412. Do it the right way.

APPROVED WORK (route (b), ~6-7 phases, comparable in size to everything landed so far):
1. WITNESS PRESERVATION (~3 phases): the eight-rule case analysis of report 03 section 3 step 4, resting on the three lemmas already machine-checked in that report's section 1 (`mem_futureOf_of_mem_constraints`, `mem_pastOf_of_mem_constraints`, `identifyTime_no_collapse`).
2. RESTATEMENT (~1 phase): give `expandBranchWithFuel_isSome_of_budget` an explicit MINT-BUDGET PARAMETER, in the shape `branchesUsed`/`maxBranches` already establishes. This is what converts route (b)'s amortized bound into something the induction can carry; a per-step potential over (b, ord) provably cannot express it (report 03 section 4), and `maxTime` was checked and is not a usable proxy (arm 3 can lower it).
3. AMORTIZED INDUCTION (~2-3 phases): #mints <= 8*|U|; #identifications <= |knownTimes|_0 + #mints; total shrinkage <= #identifications * |U|; #extensions <= |U| + total shrinkage; then the terminus `buildTableauAt_isSome_of_budget`.

RESEARCH GATE -- MACHINE-CHECK BEFORE PLANNING. Report 03 marks two load-bearing claims UNCERTAIN, and the whole mint bound rests on both:
  (i) section 3 step 4, witness preservation across `.splitOrdered` arm 3 -- ARGUED, NOT MACHINE-CHECKED. The two modal rules are trivial (their witness sits at the same time as `sf`, so identification moves both together); THE SIX TEMPORAL ONES NEED THE REACHABILITY TRANSPORT and were not verified.
  (ii) section 3 step 3, "formulas are never deleted" -- read off the rule shapes, consistent with the landed `expandOnceUnblocked_card_lt` / `expandOnceUnblocked_split_card_lt`, but NOT PROVED.
Machine-check BOTH before any plan is written. This task has twice had a plan rest on an unverified lemma that later turned out FALSE (the unconditional `buildTableau_isSome`; then the `.splitOrdered` cardinality twin). A third occurrence is not acceptable. If witness preservation fails for any temporal rule, ROUTE (b) IS DEAD and that is a THIRD retarget decision requiring human approval -- report it plainly, do not work around it and do not substitute a weaker statement.

PRESERVED, DO NOT RE-PROVE: phases 1-10 of plans/02_lexicographic-splitordered-measure.md are landed, sorry-free, axiom-free, and green repo-wide. Consume those declarations. `buildTableau`, its `fuel := 1000` default, and `expandBranchWithFuel`'s `maxBranches := 50000` default stay BYTE-IDENTICAL. No `NoSplit` reintroduction; no admitted `WorldWitness` or `hT`; no `sorry`; no narrowing a statement into vacuity. The refuted unconditional `buildTableau_isSome` and the refuted `.splitOrdered` cardinality twin stay on the do-not-re-attempt register. `resolveOpenArmCancellable` in CancellableExpansion.lean remains a DECLARED, deliberately-unrepaired out-of-scope divergence. Task 412 must not be planned against `buildTableauAt_isSome_of_budget` until it lands; the Phase 3 assets (`BudgetedTableau`, `buildTableauAt`, `BudgetedTableau.upgrade`) are available and sorry-free meanwhile.

RESUME SEQUENCE: `/research 428` first (discharge the two uncertain claims above), then `/orchestrate 428`. The stale loop guard from the prior invocation has been removed so a restart gets a fresh cycle budget.

---

### 426. Settle anchor row countermodel or nontermination for g p box g p
- **Effort**: 4-8 hours
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Topic**: completeness
- **Dependencies**: Task 470
- **Plan**: [426_settle_anchor_row_countermodel_or_nontermination_for_g_p_box_g_p/plans/01_record-anchor-row-verdict.md]
- **Research**:
  - [426_settle_anchor_row_countermodel_or_nontermination_for_g_p_box_g_p/reports/01_settle-anchor-row-verdict.md]
  - [archive/418_fix_tableau_engine_crossworld_temporalcopy_unsoundness_in_boxnegdiamondpos/artifacts/after-verdicts.md]
- **Summary**: [426_settle_anchor_row_countermodel_or_nontermination_for_g_p_box_g_p/reports/02_measured-constants.md]

**Description**: Settle whether the tableau engine can positively refute (G p) -> square (G p), or whether that branch provably never saturates. Context: the cross-world temporal-copy unsoundness in boxNeg/diamondPos is fixed and the engine is sound, but the fix moved this formula from a WRONG answer to NO answer rather than to the intended positive refutation. Measured post-fix: decide returns .fuelExhausted (not .invalid), getCountermodel?.isSome = false, and buildTableau returns none at fuel 30, 60, 400 and 1000 -- so the fuel ceiling is not bracketed from above and there is no evidence a larger budget helps. Pre-fix the same formula returned .extractionFailed, which under this codebase R7 semantics asserts VALIDITY of an invalid formula; the current .fuelExhausted is the only constructor isUndecided recognises, so the present state is honest-but-incomplete rather than wrong. Two hypotheses to discriminate: (a) budget -- the branch does saturate but needs more fuel, in which case find and record the ceiling; (b) non-termination -- the branch never saturates, in which case this is a termination question for FormalSystem/Metalogic/Decidability/Verified/Termination/Fuel.lean, not a budget one, and the honest deliverable is a proof or argument that no finite fuel suffices. Discriminating between (a) and (b) is the primary deliverable; producing the countermodel is the secondary one and only applies under (a). The corpus already pins this outcome directly: CrossWorldPropagationProbe row F asserts the decide constructor and builds green at (false, false, true, false, true) -- update that row if the verdict moves. Do NOT reintroduce any temporal-copy propagation block into boxNeg/diamondPos to make the branch close; that is the exact unsoundness that was removed, and reverting it would restore a false claim of validity. Note the related but SEPARATE inheritance also recorded for the parent task: the decidable-branch-gate family (boxAnchoredCheck, boxGridCheck, regionGate, regionLabelCheck, rayUpOk/rayDnOk) now computes false on every multi-world branch; that is the truth-lemma side-condition problem and is not this task.

---

### 425. Machine check discrete non compactness witness
- **Effort**: high
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Topic**: strong_completeness
- **Dependencies**: Task 361, Task 423
- **Research**: [425_machine_check_discrete_non_compactness_witness/reports/01_discrete-non-compactness-witness.md]
- **Plan**: [425_machine_check_discrete_non_compactness_witness/plans/01_discrete-non-compactness-witness.md]
- **Summary**: [425_machine_check_discrete_non_compactness_witness/summaries/01_discrete-non-compactness-witness-summary.md]

**Description**: Convert the informal argument at FormalSystem/Metalogic/StrongCompleteness.lean:56-62 into a machine-checked theorem: the FrameClass.Discrete consequence relation is not compact, hence strong completeness is refuted for that class.

The witness is the premise set {F p} union {not X^n p : n in N} where X phi = Formula.next phi. Every finite subset is satisfiable over Z (place p beyond the largest n used); the whole set is unsatisfiable over any Archimedean discrete carrier, because the F p witness would lie at some finite successor distance, contradicting the corresponding not X^n p.

The load-bearing ingredient is already in the tree: Formula.next phi = Formula.untl phi Formula.bot (FormalSystem/Syntax/Formula.lean:490) genuinely is a next-step operator — through the untl clause of TruthAt, "exists s > t, phi(s) and for all r in (t,s), false" says exactly that s is the immediate successor. No extra hypothesis is needed for this. The "not satisfiable" half is where IsSuccArchimedean does its work, via Order.succ_iterate-style reachability lemmas in Mathlib.

This is the negative half of the per-class split and is independent of the compactness gate — it is not affected by whether Route B succeeds. It depends only on the set-based layer's vocabulary (SatisfiableDiscreteSet / CompactDiscrete are the Discrete analogues of SatisfiableDenseSet / CompactDense).

Explicitly out of scope: an analogous Dedekind non-compactness witness. That belongs to task 408 and the class's non-compactness is already established; duplicating it here would create scope overlap with an in-flight task for no gain.

Governing design document: specs/361_strong_completeness_architecture_and_weak_terminus_gap_analysis/design/02_compactness-route.md, section "Discrete non-compactness witness".

Acceptance: archWitness_finitely_satisfiable, archWitness_not_satisfiable, and discrete_consequence_not_compact all land sorry-free; #print axioms clean on each; lake build green.

---

### 424. Prove shift set representation theorem compactness feasibility gate
- **Effort**: high
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Topic**: strong_completeness
- **Dependencies**: Task 470
- **Plan**: [424_prove_shift_set_representation_theorem_compactness_feasibility_gate/plans/01_shift-set-representation-theorem.md]
- **Research**: [424_prove_shift_set_representation_theorem_compactness_feasibility_gate/reports/01_shift-set-representation-feasibility.md]
- **Summary**: [424_prove_shift_set_representation_theorem_compactness_feasibility_gate/summaries/01_shift-set-representation-theorem-summary.md]

**Description**: RE-ISSUED 2026-08-18 (description rewrite only; status remains `not_started` -- no work on the gate itself has been touched by this re-issue). Supersedes the 2026-08-10 exposure audit below: the predicted refactor has now LANDED and is ARCHIVED, so this task's governing design is re-stated against the settled, post-refactor Lean vocabulary.

=== 1. EXPOSURE VERDICT (2026-08-10, now SETTLED): YES -- this task's governing design was built on Lean vocabulary a sibling task has since eliminated ===

This task carries topic `strong_completeness`, not `paper-refactor`, so it sat outside the six-task paper-refactor cluster re-issue and was never checked against that cluster's findings at the time. That check found: task 424's governing design document stated its whole Representation Theorem (both directions -- the entire content of this gate) in terms of `TruthAt (M : TaskModel F) (Omega : Set (WorldHistory F)) ...`, i.e. the then-current Lean signature where `Box` quantified over an explicitly-supplied `Omega : Set (WorldHistory F)` parameter, and the reverse direction of the representation theorem literally set `Ω := Omega` -- identifying the shift-set carrier with that Lean parameter directly. `valid`, `SemanticConsequence`, and `satisfiable` were quantified/witnessed the same way, over an arbitrary shift-closed `Omega`, not fixed to the full total-history set.

Task 414 (`refactor_semantics_to_total_history_validity`) has now landed and is archived. Its charter was: "make totality-based validity THE validity of the repo, eliminating the Omega parameter from the semantics core," matching the paper's current `def:BL-semantics` box clause exactly -- `Box` now ranges over `H_F` (the full set of total world histories), with no externally-supplied `Omega`.

=== 2. WHAT IS CURRENTLY TRUE OF THE TREE (re-verified 2026-08-18) ===

Task 414 HAS landed (confirmed: `specs/archive/414_refactor_semantics_to_total_history_validity/` exists; task no longer in `active_projects`). `TruthAt` (`FormalSystem/Semantics/Truth.lean`, symbol `TruthAt`, currently near :159-167, hints only) now takes NO `Omega` parameter; its `box` clause is `∀ (σ : WorldHistory F), σ.IsTotal → TruthAt M σ t φ` (confirmed against the live definition). The old shift-closure hypothesis (see section 6 below for its retirement) has zero occurrences anywhere in `Truth.lean` (confirmed by grep). `valid`/`SemanticConsequence`/`satisfiable` (`FormalSystem/Semantics/Validity.lean`) are correspondingly Omega-free and totality-based.

=== 3. WHAT SURVIVES vs WHAT WAS RESTATED ===

**Survives unchanged**: the underlying MODEL-THEORETIC ARGUMENT -- that the task-model class is first-order axiomatizable over the two-sorted signature `<Ω, D; <, +, 0, sh, (A_p)>` because the frame's algebraic content reaches `TruthAt` only through the atom clause -- did not depend on whether `Box`'s quantifier domain was an explicit parameter or a fixed total-history set. Fixing `Omega := H_F` (all total histories) was always a special case of the general argument, not a different argument; Q1's structural evidence (design doc section "Q1 -- the compactness argument") and the four-step Route B plan (S1-S4) both survive intact, exactly as the 2026-08-10 audit predicted.

**Restated** (section 6 below, re-verified against the live tree 2026-08-18): the LITERAL Lean statement of both directions of the representation theorem -- this task's actual, sole acceptance criterion. The theorem SURVIVES AND SIMPLIFIES: it loses the `Omega` parameter and the old shift-closure hypothesis (section 6 below records its retirement) on both directions, gains no new hypothesis, and does NOT require its own research cycle -- this is exactly the totality-fixed special case the 2026-08-10 audit already predicted. The forward direction now carries one small new proof obligation that used to be free: showing the constructed frame's total-history set equals the shift-orbit range, a direct consequence of `TaskRel`'s functionality (not a new risk). Q1's verdict ("likely, not proved") and Route B's four-step plan are expected to survive under totality-fixed semantics unchanged, since `Omega = H_F` is the totality-fixed case already covered by the general argument above.

=== 4. DEPENDENCY: task 414 (discharged) ===

The 2026-08-10 audit added `414` to this task's `dependencies` (previously `[361]`, then `[361, 414]`) because this task's SOLE deliverable was stated directly against vocabulary task 414 was actively eliminating. Task 414 has now landed and archived, and this re-issue (section 6) restates the theorem against the post-refactor signature, so the wasted-work risk that motivated the `414` edge has been discharged by this re-issue. The edge itself is left in place as an accurate historical/ordering record (dependencies array unchanged by this re-issue: `[361, 414, 439, 454]`).

=== 5. GOVERNING DESIGN DOCUMENT -- PATH CORRECTED ===

Task 361 has completed and archived. The governing design document has moved from `specs/361_strong_completeness_architecture_and_weak_terminus_gap_analysis/design/02_compactness-route.md` to `specs/archive/361_strong_completeness_architecture_and_weak_terminus_gap_analysis/design/02_compactness-route.md` -- the same content, corrected path. Section references below (Representation theorem, Risks R3, GATING RULE) are unchanged in content except where section 6 below explicitly restates the theorem.

=== 6. THE RE-SCOPED REPRESENTATION THEOREM (re-verified against the live tree, 2026-08-18; supersedes the Omega-based statement of 2026-08-10 and earlier) ===

Prove, in both directions, that the task-model class is representable by shift sets `⟨Ω, D, sh, A⟩` (`D` an ordered abelian group, `Ω` a nonempty type with a `D`-action `sh : Ω → D → Ω`, `A : Atom → Ω → Prop`), against the current totality-based `TruthAt` (`FormalSystem/Semantics/Truth.lean`, symbol `TruthAt`, currently near :159-167; box clause quantifies over `∀ (σ : WorldHistory F), σ.IsTotal → TruthAt M σ t φ` -- no `Omega` parameter exists). Note: the shift-set carrier `Ω` in this paragraph is the paper-facing mathematical object, distinct from the old Lean parameter of the same name discussed in sections 1-3 above, which is exactly the coincidence-of-naming the 2026-08-10 audit had to disentangle and which no longer exists in the Lean signature at all.

Forward direction: build `WorldState := Ω`, `TaskRel w d u := (u = sh w d)`, `states σ t := sh σ t`, `domain := Set.univ`. This direction now carries one small new obligation that used to be free: prove the constructed frame's total-history set equals the shift-orbit range -- a direct consequence of `TaskRel`'s functionality, not a new risk.

Reverse direction: from `(F, M)` alone -- no `Omega`, no shift-closure hypothesis (`ShiftClosed` no longer exists as a Lean definition; it is RETIRED, NOT RENAMED -- no future implementer should go looking for it, and its former citation into `Truth.lean` is deleted outright by this re-issue) -- take `Ω := {τ : WorldHistory F // τ.IsTotal}`, `sh σ Δ := σ.val.timeShift Δ` (lands in `Ω` unconditionally via `WorldHistory.isTotal_timeShift`, currently near `FormalSystem/Semantics/WorldHistory.lean:486`, no side condition beyond `σ.IsTotal` itself), `A p σ := TruthAt M σ.val 0 (atom p)`. Compatibility is supplied by `FormalSystem.Semantics.TimeShift.time_shift_preserves_truth` (symbol `time_shift_preserves_truth`, currently near `Truth.lean:457`, signature `(M) (σ) (x y : D) (φ)`), now unconditional -- no `h_sc` argument.

Everything else in the governing design document (Q1's structural evidence, Route B's S1-S4 plan, risks R1-R4, the GATING RULE) survives unchanged -- none of it is stated in terms of `Omega`.

THIS TASK GATES: (i) authorization to create tasks S2-S5 (the ultraproduct carrier, the Łoś lemma for `TruthAt`, compactness of the Base/Dense consequence relations, and strong completeness for Dense and Base), which deliberately do NOT exist yet as tasks and so cannot carry a declared dependency edge; and (ii) leg B of task 362 specifically -- the genuine strong-completeness legs for Base/Dense -- which IS edge-representable and is wired as a `dependencies` edge from 362 to 424 (see task 362's own description). It does NOT gate legs A, C, or D of task 362, and it does NOT gate task 423, which is self-contained and proves no compactness result. Do not spawn, plan, or dispatch S2-S5 from within this task; that authorization activates only when this task lands sorry-free, per the GATING RULE below.

Gate-passed evidence standard, and nothing weaker: a sorry-free Lean statement of both directions, with #print axioms on each direction reporting no sorryAx. A statement that type-checks with a sorry body does not pass. Proving only the forward direction does not pass. A prose argument does not pass.

Cancel condition: if either direction is refuted, or the construction cannot be stated without an additional non-elementary hypothesis, then Route B (semantic compactness via ultraproduct) is REFUTED and the whole branch is cancelled, not retried. Record the refutation and re-open the compactness question; do not proceed to S2 hoping the gap can be patched downstream.

Governing design document: specs/archive/361_strong_completeness_architecture_and_weak_terminus_gap_analysis/design/02_compactness-route.md -- section "Representation theorem" for both directions (the reverse direction uses WorldHistory.timeShift and FormalSystem.Semantics.TimeShift.time_shift_preserves_truth, currently near `Truth.lean:457`), section "Risks" R3 for the Type vs Type* constraint (assert it EARLY, not at assembly time), and section "GATING RULE" for the full gate contract.

Acceptance: both directions sorry-free; #print axioms clean on each; lake build green; the task's summary states explicitly whether the gate PASSED or FAILED.

---

### 423. Land set based consequence layer setderivable and per class setsemanticconsequence
- **Effort**: high
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Topic**: strong_completeness
- **Dependencies**: Task 470
- **Summary**: [FormalSystem/Metalogic/SetConsequence.lean]
- **Plan**: [423_land_set_based_consequence_layer_setderivable_and_per_class_setsemanticconsequence/plans/01_set-consequence-layer.md]
- **Research**: [423_land_set_based_consequence_layer_setderivable_and_per_class_setsemanticconsequence/reports/01_set-consequence-layer-research.md]

**Description**: Create FormalSystem/Metalogic/SetConsequence.lean containing the finitary set-derivability relation SetDerivable, the four per-class SetSemanticConsequence* predicates, the basic lemmas, and the strong-completeness / compactness / model-existence statements. Then import it from FormalSystem/Metalogic/StrongCompleteness.lean.

This is vocabulary only. It proves no compactness result and closes no existing sorry. It is self-contained and unblocks two downstream branches (the Discrete non-compactness witness, and Dense strong completeness).

Governing design document: specs/archive/361_strong_completeness_architecture_and_weak_terminus_gap_analysis/design/01_set-consequence-layer.md — transcribe section 2 (SetDerivable), section 3 (the four per-class definitions), section 4 (basic lemmas), section 5 (StrongCompletenessDense, CompactDense, strongCompletenessDense_of_compact, SatisfiableDenseSet, ModelExistenceDense). Section 4's "Implementer notes" name three elaboration risks; section 7 records what is deliberately out of scope.

Acceptance (from design/01 section 6, all five required): zero sorries and zero vacuous placeholders; grep -c 'import FormalSystem.Metalogic.BXCanonical' on the new module returns 0; each SetSemanticConsequence* binder list is byte-comparable to its `FormalSystem/Semantics/Validity.lean` source (`valid`, `ValidDense`, `ValidDiscrete`, `ValidDedekindDense` — currently near :94, :206, :222, :310 respectively, hints only, re-verify by symbol before use) with only the premise hypothesis inserted, and uses `Type` not `Type*` (the "deliberate" doc-comment in the same file, currently near :92, records this); #print axioms on every new declaration reports no sorryAx; StrongCompleteness.lean imports the module and still builds.

---

### 422. Build discrete chronicle over non archimedean block carrier with restricted coherence
- **Effort**: high
- **Status**: [BLOCKED]
- **Task Type**: lean4
- **Topic**: strong_completeness
- **Dependencies**: Task 414, Task 420, Task 421, Task 439, Task 448
- **Research**: [422_build_discrete_chronicle_over_non_archimedean_block_carrier_with_restricted_coherence/reports/01_discrete-block-carrier-refutation.md]
- **Summary**: [422_build_discrete_chronicle_over_non_archimedean_block_carrier_with_restricted_coherence/verification/block_order_refutation.lean]

**Description**: Construct the discrete-case analogue of the existing dense chronicle machinery, over the non-Archimedean carrier Q x_lex Z confirmed by the predecessor task.

Deliverable (a): the analogue of `box_dense_gives_density` (`FormalSystem/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodelBasic.lean`; currently near :430, hint only) and `cantorIsoDense` (same file; currently near :231) for the "box U(T,F) in A" case — block decomposition of the chronicle order into Z-blocks, densification of the block order, and the isomorphism into Q x_lex Z.

Deliverable (b): the three restricted-coherence analogues, mirroring `cantor_bfmcs_dense_restricted_tc` (same file; currently near :624), `cantor_bfmcs_dense_restricted_buc` (currently near :675), `cantor_bfmcs_dense_restricted_fuc` (currently near :750) at the new carrier — all hints only, re-verify by symbol before use.

Why this carrier and not Z: succ_cofinal — the obligation that killed the old BX pipeline, refuted by the Z+Z counterexample in Boneyard/BXPipelineGapAnalysis/ — was only ever needed to force the chronicle into Z, i.e. to make it Archimedean. FrameClass.Base imposes no Archimedean-ness (`valid`, `FormalSystem/Semantics/Validity.lean`, currently near :94, has no IsSuccArchimedean binder — confirmed against the live definition). The Z+Z shape is not a counterexample here — it is the intended carrier. Do not re-attempt succ_cofinal.

PRINCIPAL RISK, unresolved at scoping time: it has NOT been verified that the chronicle's block order can always be densified without disturbing MCS-chain coherence. A countable discrete order without endpoints is a Z-indexed fibration over its block order, but making the total structure a group requires the block order to carry a compatible group structure. If this fails, escalate as [BLOCKED] with the failing coherence obligation named — do not paper over it with a sorry or a vacuous placeholder.

Governing design document: specs/archive/361_strong_completeness_architecture_and_weak_terminus_gap_analysis/design/03_weak-terminus-status.md, sections 5.4-5.7.

Acceptance: the block-carrier construction and all three restricted-coherence analogues are sorry-free; #print axioms on each reports no sorryAx; lake build green. This task does NOT close the `sorry` inside `WeakCanonical.countermodel_discrete` (`FormalSystem/Metalogic/WeakCanonical/Transfer.lean`; declaration currently near :1068, sorry token currently near :1084, hints only) — that is task 169's job, which consumes this output.

FOUR-AXIOM / TOTALITY EXPOSURE NOTE (added 2026-08-10; discharge recorded 2026-08-18): this task constructs a chronicle-backed frame while the paper-refactor cluster (tasks 420, 414, 415) refactors TaskFrame and validity underneath it. Once task 420 lands, TaskFrame carries the paper's FOUR def:frame axioms (biconditional Compositionality, Seriality, Limit, Spherical -- pinned in specs/paper-definitions-of-record.md) plus a Nonempty WorldState field and a [Nontrivial D] binder; any frame this task builds must discharge ALL of them, not just the current three structure fields. Once task 414 lands, `valid` / `SemanticConsequence` are Omega-free and totality-based, so the Validity.lean line citation above and the 'no IsSuccArchimedean binder' observation must be re-verified against the refactored signatures. Tasks 414 and 420 have both now landed and are archived; the re-verification obligation for the `valid`/Validity.lean citation and the 'no IsSuccArchimedean binder' observation above is discharged by this re-issue (re-confirmed against the live, post-refactor `valid` definition). Sequence this task after 420/414/415 or budget for the rebase.

---

### 421. Correct transfer route guidance and probe non archimedean discrete carrier
- **Effort**: medium
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Topic**: strong_completeness
- **Dependencies**: Task 470
- **Plan**: [421_correct_transfer_route_guidance_and_probe_non_archimedean_discrete_carrier/plans/01_transfer-route-and-carrier-probe.md]
- **Research**: [421_correct_transfer_route_guidance_and_probe_non_archimedean_discrete_carrier/reports/01_transfer-route-and-discrete-carrier.md]

**Description**: Two deliverables on the Base weak terminus, both small.

(a) Correct the refuted route guidance. The comment block opening "(i) a Base-MCS -> Discrete-MCS transfer lemma that lets countermodel_discrete_reynolds_v2 apply" in `FormalSystem/Metalogic/WeakCanonical/Transfer.lean` (currently near :1081-1083, hint only, re-verify by the comment's opening text before use) currently proposes that route. Route (i) is REFUTED and MUST NOT be re-attempted. The witness: over D := Z x_lex Z (lex, first coordinate dominant) with p true exactly at points >= (1,0), every point has an immediate successor so box U(T,F) holds; G(Gp -> p) holds at (0,0); FGp holds at (0,0) (witness (1,0)) but Gp fails there (witness (0,1)); hence Axiom.z1 p is false. So a Base-MCS containing box U(T,F) need not be Discrete-consistent and no Base-to-Discrete MCS transfer lemma can exist. Replace those comment lines with the refutation and point at route (ii). Docstring/comment-only — do not touch the `sorry` inside `WeakCanonical.countermodel_discrete` (declaration currently near :1068, `sorry` token currently near :1084, hints only) in this task.

(b) Probe the recommended carrier. Confirm AddCommGroup, LinearOrder, IsOrderedAddMonoid, Nontrivial all resolve for Q x_lex Z, and add a CarrierProbe-style example block (mirroring the pattern in the `section CarrierProbe ... end CarrierProbe` block of `FormalSystem/Metalogic/BXCanonical/CompletenessDedekind.lean`, currently near :69-105, hint only) showing the parametric canonical machinery elaborates at that carrier. This is a confirmation step, not a supply step: `Lex.isOrderedMonoid` (`@[to_additive]`) in `Mathlib/Algebra/Order/Monoid/Prod.lean` (currently near :52-59, hint only) declares `instance isOrderedMonoid ... : IsOrderedMonoid (a x_lex b)` in the `Lex` namespace, whose additive form supplies IsOrderedAddMonoid (a x_lex b). Confirm the instance actually fires for Q x_lex Z (in particular that AddLeftStrictMono Q is found) — the generated instance name was inferred from the attribute and not resolved by lookup.

Governing design document: specs/archive/361_strong_completeness_architecture_and_weak_terminus_gap_analysis/design/03_weak-terminus-status.md, section 5.3 (the refutation), 5.5 (the carrier), 5.6 (the Mathlib instance).

Acceptance: the refuted-route comment (the "(i) a Base-MCS ... (ii) a Henkin-style ..." block) no longer appears in `Transfer.lean`; the probe block elaborates; lake build is green; #print axioms on any new declaration shows no sorryAx; the live non-Boneyard sorry count is unchanged at 1 (verify with scripts/check-module-invariants.sh check C3, which reports the sole structural sorry as countermodel_discrete in FormalSystem/Metalogic/WeakCanonical/Transfer.lean).

---

### 413. Formalize tm conservativity bridge
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Topic**: completeness
- **Dependencies**: Task 439, Task 470
- **Research**: [413_formalize_tm_conservativity_bridge/reports/01_tm-conservativity-bridge.md]
- **Plan**: [413_formalize_tm_conservativity_bridge/plans/01_tm-conservativity-backward-bridge.md]
- **Summary**: [413_formalize_tm_conservativity_bridge/summaries/01_tm-conservativity-backward-bridge-summary.md]

**Description**: Formalize the TM+ over TM conservativity bridge in Lean 4 -- BACKWARD DIRECTION ONLY, plus a documented refutation record for the forward direction.

=== MOTIVATION (RESTATED 2026-08-24; the original clause was stale) ===

This task previously claimed it was "supplying the missing step in the paper's cor:tm-completeness route". That is NO LONGER TRUE of the live paper and must not be reinstated. The live cor:tm-completeness's four rows are BL+ systems only and it says nothing about TM. The footnote the original description quoted verbatim (about "a parametric variant of the semantics", a "shift-closed set of histories", and a "strand construction covering BL and BL+ only") does NOT exist in the live paper or in the pinned record.

The actual, current motivation: TM is the tense-primitive base language and BL+ is the until/since-primitive extension the repository formalizes. Nothing in the tree currently relates derivability in the two. This task builds that relation in the direction that is TRUE, and permanently records why the other direction is not.

=== THE ANCHOR IS HISTORICAL, NOT LIVE ===

\label{thm:ConservativeExtension} was DELETED from the paper on 2026-08-14 (commit c0116d04). Do NOT cite it as a live \label -- the "cite by \label only" rule cannot be satisfied for it. Cite the last revision that carried it, 58c7c0c0^ (2026-08-12), and mark every such citation explicitly as historical. Live anchors that DO resolve and may be cited normally: def:BL-language, def:BLplus-language, def:BLplus-defined, thm:BLplus-PastFuture, def:S5, def:BX, def:TMplus, def:TMplus-{f,d,c}, cor:tm-completeness, and the informal TM axiomatization in \S sub:Logic. Before consuming any semantic definition run `bash scripts/check-paper-definitions.sh` and cite specs/paper-definitions-of-record.md rather than the paper directly.

=== DELIVERABLE A: THE BRIDGE (backward direction, zero sorry) ===

1. `BaseLanguage/Formula.lean` -- `BLFormula` with primitive box/allPast/allFuture, `swapBL`, `DecidableEq`, `Countable`, reusing the existing `Atom`. NOTE: the paper writes \Past/\Future for the UNIVERSAL H/G and \past/\future for the existential P/F; getting this backwards transcribes a different logic.
2. `BaseLanguage/Axioms.lean` -- TM's 12 schemata/rules plus DF/DN/CO, with `minFrameClass`.
3. `BaseLanguage/Derivation.lean` -- `DerivationTree` mirroring the 7-rule shape, `Derivable`, notation. TM's TD rule is `swapBL`, NOT `swapTemporal`.
4. `BaseLanguage/Translation.lean` -- `tr`, `tr_swapBL`, range lemmas, `tr_injective`.
5. `Metalogic/Conservativity.lean` -- `translate` and `derivable_translate`, plus the four named row corollaries `ceb_backward`, `cef_backward`, `ced_backward`, `cec_backward`.
6. The DF derivation at Discrete -- ITS OWN PHASE (see below).

The backward direction is `TM |- phi  ==>  TM+ |- tr phi`. It holds unconditionally.

=== DELIVERABLE B: THE REFUTATION RECORD (documentation, not proof) ===

7. A module docstring in `Metalogic/Conservativity.lean` recording that the CONVERSE (forward) direction is REFUTED for the Base and Discrete rows and OPEN for the other two, so that no future dispatch re-attempts it. Use this repository's own axioms as the evidence:
   - CEF/Discrete: `Axiom.z1` (ProofSystem/Axioms.lean, minFrameClass = .Discrete) is built entirely from allFuture/someFuture/imp, so `z1 phi = tr (Z1 phi')` for the obvious BL formula. Hence `|-[Discrete] tr(Z1)` holds by a ONE-LINE axiom invocation while `TM_f |- Z1` is refuted by soundness over Z x_lex Z. The forward direction is false by construction of this repository's own axiom set, with no appeal to completeness.
   - CEB/Base: `Axiom.discrete_box_necessity` is the paper's TMP-NB (`X top -> box X top`) and `Axiom.modal_5_collapse` is M5; both fall to .Base via `minFrameClass`'s catch-all, so the paper's (Sp) derivation is available verbatim in `|-[FrameClass.Base]`.
   Cite the deleted-theorem provenance (58c7c0c0^), not a live \label.

=== THE ONE OPEN SUB-OBLIGATION: DF AT FrameClass.Discrete ===

CEF's backward direction needs `|-[Discrete] (H phi AND phi AND F top) -> F(H phi)`. Nothing in the tree proves this. Budget it its own dispatch -- it is the single largest unknown.

ROUTE A (REQUIRED -- syntactic): at the immediate successor s of t, every time < s is <= t, so `H phi AND phi` at t yields `H phi` at s. The pieces exist: `Theorems.DiscreteUnfolding.succIndicator : |-[Discrete] Formula.next Formula.top` gives X top; `Axiom.until_F` with guard bot gives `X psi -> F psi` at Base; the remaining step `H phi AND phi -> X(H phi)` is the past-dual of the one-step unfolding in `unfoldForward`/`unfoldTableForward`. Past duals are FREE -- `DerivationTree.temporal_duality` is a primitive rule applying to any theorem at any frame class, so no past-mirrored axiom is needed.

ROUTE B (fallback only, requires explicit approval before use): `tr(DF)` is valid over Z-time so `completeness_discrete` delivers derivability. Sorry-free, but it makes a proof-theoretic bridge depend on the completeness machinery it is meant to feed -- a presentational regression. Do not take Route B without escalating first.

=== ASSETS ALREADY IN THE TREE (verified 2026-08-24) ===

Base row: CPL/MP/MN/MK/MT/M5 direct; MF = `Axiom.modal_future` (exact syntactic match); TD = `DerivationTree.temporal_duality` + the commutation lemma `tr (swapBL phi) = swapTemporal (tr phi)` (prototyped, compiles clean); TK = `Theorems.TemporalDerived.gDistribution`; T4 = `Theorems.TemporalDerived.gTransitivity`; TB = `Axiom.serial_future` + MP; TA = `Axiom.connect_future` (exact syntactic match). TL is the ONLY Base-row friction: same three disjuncts as `Axiom.temp_linearity` but different order/association -- routine orElim/orIntro plumbing from `Theorems/Propositional/`.

Extension rows: CED's DN is `Axiom.density` (literally the same formula); CEC's CO is `Theorems.DedekindDerived.co_derived`, already sorry-free; CEF's DF is the open item above.

Prior art for SHAPE ONLY (do not reuse content): `FormalSystem/Boneyard/ConservativeExtension/` is an `#exit`-guarded mirrored-type + embedAxiom/embedDerivation skeleton.

Reuse `FrameClass`; do not clone it. Phrase all statements so they compose with the totality-based validity.

=== EXPLICITLY OUT OF SCOPE ===

- The FORWARD direction. Do not state it, and do not discharge it with a sorry -- that would place a sorry on a PROVABLY FALSE statement, which is an unsound placeholder, not deferred debt, and the zero-debt gate forbids it.
- Any BL-side semantics or soundness theorem.
- The two-fibre and Z x_lex Z countermodels. A machine-checked (rather than documented) refutation is separate task material and would consume non-Archimedean carrier work that is currently blocked.

=== ACCEPTANCE ===

- `lake build` green; no new sorry; no new axiom.
- Deliverable A items 1-6 land sorry-free; all four row corollaries stated and proved.
- Deliverable B docstring present, citing Axiom.z1 and Axiom.discrete_box_necessity by name.
- `#print axioms` clean on the four row corollaries.

---

### 412. Prove refutation core and decidability of provability with completeness corollaries
- **Effort**: 10-15 hours
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: decidability
- **Dependencies**: Task 165, Task 410, Task 411, Task 428, Task 430

**Description**: Track B finish for the TM tableau decidability program (parent: task 165; grounding: reports/02_tableau-decidability-hard-research.md sections 3.1, 8.3, 8.5). Create Verified/Refutation/Core.lean proving allClosed_derivable as ONE induction over allRulesForFC fc, discharging each rule by its admissibility lemma (predecessor tasks) and its ruleFrameClass r <= fc hypothesis via the RuleSpec GATE lemmas — Dense/Discrete/Dedekind instantiate the generic theorem, they do not re-prove it. Then Verified/Provable.lean: Decidable (Derivable fc [] phi) combining allClosed_derivable with Track A's buildTableau_isSome and not_valid_of_hasOpen; the completeness corollaries ValidFor fc phi -> Derivable fc [] phi; discharge the pre-existing sorry countermodel_discrete at FormalSystem/Metalogic/WeakCanonical/Transfer.lean:1242; and supply the Dedekind engine consumed by completeness_dedekind_of_engine (StrongCompleteness.lean:308, target ValidDedekindDense). Acceptance: zero sorries repo-wide outside Boneyard; lake build green; update typst/latex decidability chapters to record headline result 2.
RE-SCOPING ADDENDUM (2026-07-29, supersedes the buildTableau_isSome reference above): the scope text above depends on "Track A's buildTableau_isSome", which task 165 proved FALSE and placed on a do-not-re-attempt register (165's plan 01_tableau-decidability-two-track.md:1405-1420, :1489-1493). The refutation is a property of the engine signature, not a proof difficulty: buildTableau returns none whenever a formula explores more than maxBranches := 50000, at ANY fuel. Consequently this task's acceptance criterion "zero sorries repo-wide outside Boneyard" was UNREACHABLE AS SCOPED, independently of task 165's own status.

CORRECTED DEPENDENCE: consume the budget-parameterised totality theorem from task 428 (engine_totality_at_a_quantified_branch_budget) -- shape `buildTableau_isSome_of_budget phi fc maxBranches (hmb : <bound in phi> <= maxBranches)` -- in place of the unconditional buildTableau_isSome. Task 428 has been added as a predecessor. Do NOT attempt the unconditional form yourself.

ALSO NOTE: this task inherits obstructions O2 and O3 (the boxAnchoredCheck and temporalWitnessCheck truth-lemma side conditions) from Phase 7.3 of task 165 by way of not_valid_of_hasOpen. Those are owned by task 429. If your induction reaches a point where a truth-lemma gate hypothesis must be discharged on real engine output, that is 429's work, not this task's -- record it and coordinate rather than re-deriving it. Grounding for all of this: specs/165_establish_semantic_finite_model_property/reports/09_phase7-deadlock-blocker-research.md.

---

### 411. Prove hard admissibility lemmas for until since trichotomy discrete and dedekind rules
- **Effort**: 15-20 hours
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: decidability
- **Dependencies**: Task 165, Task 410

**Description**: Track B part 2 for the TM tableau decidability program (parent: task 165; grounding: reports/02_tableau-decidability-hard-research.md sections 3.2-3.3 and 10). First run a /literature acquisition pass for Reynolds 1992 and Reynolds 2003 (the untlNeg co-decomposition and the Dedekind gap axioms; report 02 section 10 flags in-repo literature as thin). Then prove the hard admissibility block in Verified/Refutation/Rules/{UntilSince,Trichotomy,Discrete,Dense,Dedekind}.lean: untlPos (branch 1 via until_F, branch 2 via self_accum_until — follow the axiom literally), untlNeg (Reynolds co-decomposition via absorb_until + left_mono_until_G; the single largest lemma — budget it its own dispatch), sncePos/snceNeg duals, orderTrichotomy (one-liner if Phase 2.2 kept branches syntactically equal to temp_linearity disjuncts — verify, do not assume), z1Rule (two-premise instance of z1 + two modus ponens, relies on same-label internalization from the predecessor task), densityRule/denseIndicatorClosure via density/dense_indicator, and the Dedekind rules via prior_U_gap/prior_S_gap/sep. Acceptance: all admissibility lemmas sorry-free; lake build green.

---

### 410. Internalize tableau branches and prove routine rule admissibility
- **Effort**: 12-18 hours
- **Status**: [PLANNED]
- **Task Type**: lean4
- **Topic**: decidability
- **Dependencies**: Task 165, Task 429
- **Research**: [410_internalize_tableau_branches_and_prove_routine_rule_admissibility/reports/01_internalize-routine-admissibility.md]
- **Plan**: [410_internalize_tableau_branches_and_prove_routine_rule_admissibility/plans/01_internalize-routine-admissibility.md]

**Description**: Track B part 1 for the TM tableau decidability program (parent: task 165, plan plans/01_tableau-decidability-two-track.md, research reports/02_tableau-decidability-hard-research.md sections 3.1-3.4). Create FormalSystem/Metalogic/Decidability/Verified/Internalize.lean defining Branch.internalize (world labels via box/diamond nesting, time labels via U/S guards realizing the branch TimeOrdering; SETTLED constraints: internalization design over substitution — no cut or uniform-substitution admissibility exists in the tree — and z1Rule's two premises must stay at the same label). Then prove the routine admissibility lemmas in Verified/Refutation/Rules/{Propositional,Modal,Temporal}.lean (~21 lemmas: 8 propositional, 4 S5 modal, 1 boxTemporal, 8 temporal universal/existential), each stated as rule_admissible per report 02 section 3.1 with hypothesis ruleFrameClass r <= fc, reusing Combinators.lean, ModalS5.lean, TemporalDerived.lean, GeneralizedNecessitation.lean, and DeductionTheorem.lean via DerivationTree.lift. Acceptance: all lemmas sorry-free, lake build green, RuleSpec GATE lemmas still green.

---

### 362. Completeness capstone consequence all classes strong where compact
- **Effort**: high
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: strong_completeness
- **Dependencies**: Task 361, Task 375, Task 169, Task 170, Task 424

**Description**: Implement the completeness capstone under the SETTLED TERMINOLOGY (2026-07-27): "strong completeness" is reserved for consequence from possibly-infinite premise sets (Γ : Set Formula) with finitary set-derivability; finite-context (Context = List Formula) consequence statements are inter-derivable with weak completeness via the deduction theorem and are named CONSEQUENCE completeness, never strong. (This task was formerly named "main_strong_completeness: finite-context strong completeness" — that framing was misleading and is retired. "main_strong_completeness" was never a Lean or LaTeX identifier; it was this task's own former title.)

SCOPE:
(A) Finite-context CONSEQUENCE completeness for all four frame classes. For each X ∈ {Base, Dense, Discrete}: define SemanticConsequenceX (Γ : Context) (paralleling the ValidX binder list), prove the semantic deduction lemma, and prove consequence_completeness_X : SemanticConsequenceX Γ φ → Derivable FrameClass.X Γ φ via (a) the semantic deduction lemma, (b) the class's weak completeness engine, (c) the fc-generic derivable_foldr_imp_iff. The Dedekind instance and all the generic lemmas (truthAt_foldr_imp, derivable_of_derivable_foldr_imp, derivable_foldr_imp_of_derivable, derivable_foldr_imp_iff) ALREADY EXIST in FormalSystem/Metalogic/StrongCompleteness.lean (landed by task 408 phase 2, reframed 2026-07-27) — follow its three-declaration shape and drop the Base/Dense/Discrete instances into that file's reserved sections. Weak completeness for each class stays re-exposed as the Γ=[] corollary (exactly one proof of the weak form per class, as a corollary). State conclusions as `Derivable` (definitionally Nonempty (DerivationTree ...), `FormalSystem/ProofSystem/Derivable.lean`; currently near :69, hint only), matching the existing weak termini.
(B) GENUINE strong completeness (Γ : Set Formula with finitary set-derivability) for Base and Dense ONLY, conditional on task 361's feasibility verdict and gated on the set-based model-existence theorem it scopes (every SetConsistent set satisfiable in a class frame). If 361 returns a non-compactness verdict for Base or Dense, record the counterexample and downgrade that leg to consequence-only, matching Discrete/Dedekind. Leg B — and only leg B — is additionally gated on task 424's shift-set Representation Theorem (semantic compactness via the ultraproduct route); legs A, C, and D do not depend on 424. The declared dependency edge on 424 (added by this re-issue) cannot express that partiality by itself, which is why it is stated here in prose.
(C) Discrete and Dedekind get NO strong form — both provably non-compact (Discrete: the {F p} ∪ {¬Xⁿ p : n} witness under IsSuccArchimedean, since next = untl φ bot is definable; Dedekind: Reynolds 1992 Thm 7 weak-only, restriction genuine). The StrongCompleteness.lean section headers already document this; optionally land the formalized Discrete non-compactness witness if 361 scoped it.
(D) LaTeX alignment: restate latex/subfiles/04-Metalogic.tex so "Strong Completeness and Compactness" (the `\subsubsection` heading currently near :267, with a backreference to the same phrase currently near :543 — hints only, re-verify by the phrase's exact text before use) is used ONLY for the Set Formula statement (stated for Base/Dense if reachable, with the non-compactness of Discrete/Dedekind recorded), presenting the finite-context result as consequence completeness derived from weak completeness; resolve that file's "Note on Infinite Contexts" TODO accordingly.

VERIFIED ANCHORS (re-checked 2026-08-18):
  - `FormalSystem/Metalogic/BXCanonical/Completeness.lean`: `completeness` (currently near :191 — the file also carries an unrelated second declaration named `completeness` near :26; this task's target is the Base-class terminus at :191), `completeness_dense` (currently near :250), `completeness_discrete` (currently near :291) — base validity predicate is lowercase `valid`; dense/discrete are `ValidDense`/`ValidDiscrete` (`FormalSystem/Semantics/Validity.lean`; currently near :94, :206, :222 respectively). All line numbers are hints only — re-verify by symbol before use.
  - FormalSystem/Metalogic/StrongCompleteness.lean — module docstring carries the per-class programme and reserved sections; Dedekind instance complete modulo its engine (`consequence_completeness_dedekind_of_engine`, currently near :274; `completeness_dedekind_of_engine`, currently near :308).
  - Syntactic deduction theorem: `FormalSystem.ProofSystem.Derivable.deduction` (`Metalogic/Core/DeductionTheorem.lean`; currently near :467, Prop-level), data-level `deductionTheorem` currently near :325, `deductionConverse` currently near :447.
  - Set-based MCS layer (for leg B): `SetConsistent`/`SetMaximalConsistent`/`set_lindenbaum`, `Metalogic/Core/MaximalConsistent.lean`; currently near :96/:103/:303. SetConsistent is already finitary (every finite sublist consistent).
  - Frame-class-agnostic `SemanticConsequence` (Γ : Context) exists in `Semantics/Validity.lean` (currently near :125) with notation `Γ ⊨ φ` (currently near :135) — it quantifies over ALL carriers and is NOT the per-class relation; per-class variants named in UpperCamel (Prop-valued definitions), theorem names snake_case.
  - Update the tracking table in FormalSystem/Metalogic.lean (the file at the FormalSystem/ root, NOT FormalSystem/Metalogic/Metalogic.lean, which does not exist).

Axioms exactly [propext, Classical.choice, Quot.sound] modulo whatever the underlying weak terminus already carries; leg A sorry-free once the three weak termini are green.

DEPENDENCY STATUS (re-verified 2026-08-18; dependencies array now includes 424, added by this re-issue): 375 (discrete weak terminus) COMPLETED — completeness_discrete/completeness_dense kernel-verify to the pristine axiom set. 169 (base weak) not_started. 170 (dense weak) not_started. 361 (terminology/architecture research + set-based layer design + Base/Dense compactness verdict) not_started. 424 (shift-set Representation Theorem, gate for the ultraproduct branch) not_started. Leg B is gated on both 361's verdict and 424's theorem, plus the model-existence tasks 361 spawns; legs A, C, and D are gated on neither.

---

### 298. Fix c7 labeling bug and regenerate dataset
- **Status**: [PARTIAL]
- **Task Type**: lean4
- **Topic**: dataset-enhancement
- **Dependencies**: Task 297, Task 343
- **Research**: [298_fix_c7_labeling_bug_and_regenerate_dataset/reports/01_c7-labeling-bug.md]
- **Plan**: [298_fix_c7_labeling_bug_and_regenerate_dataset/plans/01_c7-labeling-bug.md]
- **Summary**:
  - [298_fix_c7_labeling_bug_and_regenerate_dataset/summaries/01_c7-labeling-bug-summary.md]
  - [298_fix_c7_labeling_bug_and_regenerate_dataset/summaries/01_c7-labeling-bug-summary.md]

**Description**: Fix c7 labeling bug at formula ~13750 that causes unbounded memory growth in the decision procedure's timeout handling, then regenerate the full c7 dataset. During task 297 dataset regeneration, all 3 attempts to generate c7 stalled at exactly record 13,749 with RSS growing ~40MB/6s. The labeling function enters an apparent infinite loop or unbounded search for formula #13,750 in the sorted enumeration order. The timeout mechanism either does not fire or cannot interrupt the stuck state. Steps: (1) Identify the specific formula at position ~13,750 in the c7 enumeration. (2) Reproduce the hang in isolation with that formula. (3) Diagnose whether the decision procedure's timeout is failing to fire or the procedure is in an uninterruptible state. (4) Fix the timeout handling so it reliably terminates. (5) Regenerate the full c7 dataset (target: 77,272 records)

---

### 296. Re add derived binary operators with dedup fix
- **Status**: [PARTIAL]
- **Task Type**: lean4
- **Topic**: dataset-enhancement
- **Dependencies**: Task 295, Task 298
- **Research**: [296_re_add_derived_binary_operators_with_dedup_fix/reports/01_derived-binary-operators.md]
- **Plan**: [296_re_add_derived_binary_operators_with_dedup_fix/plans/01_derived-binary-operators-plan.md]
- **Summary**: [296_re_add_derived_binary_operators_with_dedup_fix/summaries/01_derived-binary-operators-summary.md]

**Description**: Re-add the 6 derived binary temporal operators (release, weak_until, trigger, weak_since, strong_release, strong_trigger) to the formula enumerator, adjusting canonicalization and/or the passesFilter gate so they survive deduplication and appear in the unique pipeline output. These operators were removed in task 295 because they inflated the enumeration space by ~40-60% without contributing unique formulas — their canonical representations collapsed with primitives. Potential approaches: (1) skip canonicalization for formulas containing derived binary operators, (2) canonicalize to the derived form instead of the primitive form, (3) lower or remove the passesFilter complexity gate for these operators, (4) add a fold-aware dedup stage that treats release(p,q) as distinct from neg(untl(neg p, neg q)). The goal is to have all 13 derived operators represented in the final dataset.

---

### 282. Exhaustive enumeration by default
- **Status**: [PARTIAL]
- **Task Type**: lean4
- **Topic**: dataset-enhancement
- **Dependencies**: Task 274, Task 298
- **Plan**: [282_exhaustive_enumeration_by_default/plans/01_exhaustive-enumeration-plan.md]
- **Research**: [282_exhaustive_enumeration_by_default/reports/01_exhaustive-enumeration-default.md]
- **Summary**: [282_exhaustive_enumeration_by_default/summaries/01_exhaustive-enumeration-summary.md]

**Description**: Flip complexity-9 dataset generation from stratified to exhaustive-by-default once feasibility is confirmed. Prior work (see plans/01_exhaustive-enumeration-plan.md, handoffs/phase-1-6-handoff-20260714.md) verified the 0-sentinel/.take-guard machinery is already correct and unlimited-capable, and corrected stale infeasibility claims in data/README.md and scripts/run_dataset_generation.sh. The next action is the deferred c9 feasibility probe (Plan Phase 2), followed -- pending a GO verdict and explicit user approval for the multi-hour compute -- by c8/c9 exhaustive regeneration and HF Hub republication (Phases 3, 4(rest), 5, 6(rest), 7).

---

### 257. Large data storage huggingface
- **Status**: [BLOCKED]
- **Task Type**: general
- **Topic**: dataset-enhancement
- **Dependencies**: None
- **Research**: [257_large_data_storage_huggingface/reports/01_large-data-storage.md]
- **Plan**: [257_large_data_storage_huggingface/plans/01_implementation-plan.md]
- **Summary**: [257_large_data_storage_huggingface/summaries/01_execution-summary.md]

**Description**: Complete the Hugging Face Hub migration for large dataset storage. Prior work (see plans/01_implementation-plan.md, summaries/01_execution-summary.md) removed Git LFS tracking from .gitattributes and rewrote data/README.md to point at HF Hub (logos-labs/bmlogic-bench) as the canonical source, but Phase 1 -- the actual upload to HF Hub via the existing data/hf-dataset/upload.py pipeline -- was never executed because it requires user HF authentication. This task is blocked on that credential; once supplied, run the upload, validate, and confirm data/hf-dataset/PUBLISHING.md's 'Migration Status' header reflects completion.

---

### 231. Dataset regeneration automation
- **Status**: [NOT STARTED]
- **Task Type**: general
- **Topic**: dataset-enhancement
- **Dependencies**: Task 230, Task 298

**Description**: Build comprehensive automation so that every dataset regeneration automatically updates all downstream artifacts and documentation fields. Supersedes task 227 scope. (1) Create data/scripts/sync-all.py master sync script that: (a) Scans all JSONL files and recomputes metadata JSON files (record counts, rule distributions, schema field lists, valid/invalid ratios, tier distributions, step statistics). (b) Updates specific fields in data/README.md: file inventory table (Records, Size columns), training record schema table (field count), proof steps statistics (records, theorems, rule distribution, steps per theorem), cross-logic split table (records, valid rates), NL paraphrase statistics. (c) Updates specific fields in data/dataset-card.md: overview table, all record counts, proof steps section, competitive position 'primary gaps' paragraph. (d) Recomputes SHA-256 hashes and contentSize for all distributions in croissant.json. (e) Regenerates bmlogic-bench-splits.json. (f) Validates all JSONL records against declared schemas (checks field presence, types, null patterns). (g) Checks train/benchmark formula overlap and reports contamination percentage. (h) Validates metadata key consistency (total_records not total_count). (2) Idempotent and safe to run after any regeneration command (lake exe dataset_generator, lake exe proof_extractor, lake exe benchmark_oracle, finalize_benchmark.py). (3) --dry-run mode that reports what would change. (4) --commit mode that creates structured git commit. (5) CI-friendly exit codes (0=clean, 1=staleness detected, 2=validation error). (6) Update data/README.md with pipeline documentation. (7) Integrate into agent context (.claude/context/project/dataset/) so /implement for dataset tasks runs sync-all as post-implementation step. Note: supersedes task 227 (dataset_pipeline_automation_croissant_sync) with broader scope covering README/dataset-card field updates and schema validation.
=== ITEM (7) TARGETS A DISPOSABLE DEPLOY ARTIFACT -- CORRECTED 2026-08-24 ===

Item (7) above says "Integrate into agent context (.claude/context/project/dataset/)". DO NOT WRITE
THERE. Verified 2026-08-24: `.claude/` in this repository is fully gitignored (`.gitignore:81`) with
zero tracked files, and is regenerated wholesale from a source store that is NOT in this repository
-- it lives at /home/benjamin/.config/nvim/agent-system/, a separate git repo. A file written to
`.claude/context/project/dataset/` will be silently destroyed on the user's next agent-system
reload.

Item (7) therefore CANNOT be completed from inside this repository. Two acceptable dispositions,
both of which require asking the user first:

  (a) DROP item (7) from this task's scope and record why. The other seven sub-targets of this task
      are ordinary repository work (`data/scripts/sync-all.py`, `data/README.md`,
      `data/dataset-card.md`, `croissant.json`, the splits file, schema validation, contamination
      check) and are unaffected. This is the recommended default -- it keeps the task in one repo.
  (b) Split item (7) into a task filed in the nvim repository's own tracker
      (/home/benjamin/.config/nvim/specs/state.json), targeting
      agent-system/extensions/<appropriate-extension>/context/, and committed there.

Do not silently satisfy item (7) by writing into `.claude/`.
=== ITEM (7) DROPPED FROM SCOPE -- 2026-08-24, user decision ===

Item (7) ("Integrate into agent context (.claude/context/project/dataset/) so /implement for
dataset tasks runs sync-all as post-implementation step") is REMOVED from this task's scope. It is
not a defect and not deferred -- it is out of scope here, permanently, and no successor task owns
it in this repository.

WHY. The disposition options recorded above were put to the user on 2026-08-24 and option (a) was
chosen. Three considerations decided it:

  1. `.claude/` here is gitignored (`.gitignore:81`, zero tracked files) and regenerated wholesale
     from /home/benjamin/.config/nvim/agent-system/, a separate git repo. A file written to
     `.claude/context/project/dataset/` is destroyed on the next agent-system reload.
  2. Filing it in the nvim tracker instead was considered and declined. There is no `dataset`
     extension in that source store (verified 2026-08-24: core, cslib, email, epidemiology,
     filetypes, formal, founder, latex, lean, literature, memory, nix, nvim, present, python,
     slidev, typst, web, z3), and a BimodalLogic-specific post-implementation hook placed in the
     shared global agent-system would deploy to every repository that loads it. It would have to be
     generalized into a repo-local hook mechanism first -- a different and larger piece of work
     than this task.
  3. The `.syncprotect` escape hatch (project root; honored by deploy-headless.sh and the picker's
     sync path) would survive a reload, but leaves the file untracked and unbacked-up in a repo
     where everything else is version-controlled.

WHAT REMAINS IN SCOPE. Items (1) through (6) and (8), unchanged and unaffected -- they are ordinary
repository work under `data/`: `data/scripts/sync-all.py`, `data/README.md`,
`data/dataset-card.md`, `croissant.json`, `bmlogic-bench-splits.json`, schema validation, the
train/benchmark contamination check, and the metadata-key consistency check. Do not treat the
removal of item (7) as reducing any of them.

IF THE HOOK IS WANTED LATER. `sync-all.py` is a plain script with CI-friendly exit codes (item 5).
Wire it from repository CI or run it manually after a regeneration. That reaches the same outcome
without depending on agent-system context at all.

---

### 219. Llm baseline difficulty calibration
- **Status**: [RESEARCHED]
- **Task Type**: general
- **Topic**: dataset-enhancement
- **Dependencies**: Task 231
- **Research**: [219_llm_baseline_difficulty_calibration/reports/01_llm-baseline-research.md]

**Description**: Run bmlogic-bench through multiple LLMs to establish baseline difficulty calibration. Evaluate at least 3 models (GPT-4o, Claude Sonnet, a 7B open model). Report zero-shot accuracy per difficulty tier (easy/medium/hard/very_hard), chain-of-thought vs direct label accuracy, error rate correlation with modal/temporal depth. Include random baseline (50% for balanced benchmark). Publish results in data/baselines/README.md with methodology. Both symbolic formula input and NL paraphrase input (if available from R1).

---

### 193. Codebase tactic refactor
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: automation
- **Dependencies**: Task 165, Task 402, Task 448, Task 470
- **Research**: [193_codebase_tactic_refactor/reports/01_codebase-refactor-seed.md]

**Description**: Apply validity-intro and truth-simp macros to the soundness layer.

RE-SCOPED 2026-07-26 by the codebase tactic survey (now archived at specs/archive/196_codebase_tactic_survey/reports/02_automation-survey.md section 6.3). The original charter targeted Theorems/ using tm_prove. Theorems/ is 7,017 lines - 3.8% of the tree, half the relative share the 2026-05 research assumed - and is sorry-free and stable; tm_prove (task 192) is abandoned; and the search-family tactics it would have fallen back on have zero adoption. The task keeps its kind (an application pass that reduces existing proof text) and replaces its target and its instrument.

Define a small family of syntactic macros and apply them mechanically to the three files that concentrate the codebase two highest-frequency verbatim proof repetitions. This is an APPLICATION task: the deliverable is measured reduction in existing proof text at named files, not the existence of a macro.

Macros to define (single-line `macro ... : tactic` declarations - no elaboration, no goal inspection):
  - intros_validity           for `intro F M Omega _h_sc τ _h_mem t`
  - intros_validity_framed    for the frame-condition-prefixed variant
  - simp_truth                for the recurring `simp only [TruthAt, Truth.future_iff, Truth.past_iff, Truth.some_future_iff, Truth.some_past_iff]` bundle
  - unfold_validity           composing intros_validity with simp_truth, for sites where the two appear consecutively

NAMING NOTE (2026-07-27): the simp head symbol is `TruthAt`, not the pre-upgrade `truth_at` -- the systematic Mathlib naming upgrade renamed it. The `Truth.*_iff` names above are unchanged (declared in FormalSystem/Semantics/Truth.lean at :220 some_future_iff, :239 some_past_iff, :258 future_iff, :278 past_iff).

Measured target sites (re-verified 2026-07-27 against the working tree, Boneyard/ excluded; counts unchanged from the 2026-07-26 measurement, only the paths and the simp head symbol were restated):
  - FormalSystem/Metalogic/SoundnessLemmas/DenseValidity.lean      - 92 `intro F M Omega`, 54 `simp only [TruthAt`
  - FormalSystem/Metalogic/SoundnessLemmas/FrameClassVariants.lean - 56 `intro F M Omega`, 30 `simp only [TruthAt`
  - FormalSystem/Metalogic/Soundness.lean                          -  0 `intro F M Omega`, 47 `simp only [TruthAt`

DO BOTH MACRO GROUPS AS ONE PASS over the same files, not two. Splitting them edits the same two files twice and forfeits the unfold_validity collapse.

COMPLETION CRITERION: `intro F M Omega` occurrences in the two SoundnessLemmas/ files reach zero; `simp only [TruthAt` occurrences across the three files fall by at least 80%; lake build green; executable sorry count unchanged at 1, located BY CONTENT in FormalSystem/Metalogic/WeakCanonical/Transfer.lean, never by line number. A task that ends with working macros and unchanged proof text has FAILED.

EXPLICITLY OUT OF SCOPE: Theorems/ refactoring, tm_prove, modal_search and every other search-family tactic, and any new elaborated tactic. See the survey report section 5 for the measured evidence (38 real proof-site invocations across ~5,800 lines of proof automation, all 38 in one file).

DEPENDENCY ON THE SYSTEMATIC MATHLIB NAMING UPGRADE -- NOW DISCHARGED (2026-07-27): this task rewrites proof bodies at roughly 330 sites, and the naming-upgrade task rewrote the same reference graph at 24,364 sites while moving every file from Theories/Bimodal/ to FormalSystem/. A mass proof rewrite must not race a mass rename, so this task was held until that rename landed. It HAS landed -- the naming-upgrade task is status `completed` -- so the precondition is satisfied and this task is NOT blocked. Every path in this description, and every entry in file_scope, is now stated in its post-rename FormalSystem/ form; `Theories/Bimodal/` appears above only as the historical source of that move, never as a path to open.

Inventory groups drawn on: survey report section 4.2 groups 2 (intros_validity, score 153) and 3 (simp_truth, score 72.7).

---

### 178. Publication examples and demo
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: formula-refactor
- **Dependencies**: Task 131, Task 193, Task 402

**Description**: Expand Examples/ with publication-quality demonstrations of the full verified pipeline. Complete worked example showing soundness-completeness-decidability on a concrete formula. Examples exercising each frame class with FrameClass-parameterized DerivationTree. Examples of the expressive completeness result. Update BimodalProofs.lean and TemporalStructures.lean. All examples sorry-free.

---

### 177. Update readme and module docstrings
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: formula-refactor
- **Dependencies**: Task 131, Task 193, Task 402, Task 426, Task 428, Task 429, Task 430, Task 432, Task 433, Task 434, Task 440, Task 441, Task 448

**Description**: Update all documentation to match final codebase state after refactoring. README.md axiom counts, architecture diagram, sorry obligations. Module-level docstrings for every file in the final structure. ROADMAP.md updates. Axiom Reference doc verification. This is the final documentation pass after all structural refactoring is complete.

---

### 169. Complete frame extension setup and soundness
- **Effort**: high
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: strong_completeness
- **Dependencies**: Task 361, Task 422, Task 448

**Description**: Base (FrameClass.Base / general) WEAK completeness green: make the empty-context theorem `completeness` (the Base-class terminus in `FormalSystem/Metalogic/BXCanonical/Completeness.lean`, signature `valid φ → Derivable FrameClass.Base [] φ`, currently near :191, hint only — the file has a second, unrelated declaration also named `completeness` currently near :26; this task's terminus is the one at :191 with the signature above) genuinely sorry-free.

CORRECTED SCOPE (2026-07-28, from task 361's design/03_weak-terminus-status.md): this task's earlier description named THREE open sorries. That was stale. `completeness` has EXACTLY ONE reachable sorry: the `sorry` inside `WeakCanonical.countermodel_discrete` in `FormalSystem/Metalogic/WeakCanonical/Transfer.lean` (declaration currently near :1068, sorry token currently near :1084, hints only). Machine-verified this session via `lean_verify`: `#print axioms completeness` = [propext, sorryAx, Classical.choice, Quot.sound], with that `sorry` the sole `sorryAx` source. The other two the old description named are gone from live code — the dense arm now runs through `countermodel_dense_enriched` (`Completeness.lean`; declaration currently near :135, called at its use site currently near :216), which is sorry-free, and the mixed case is closed by `Chronicle.mcs_mixed_case_absurd` (`MCSMixedCase.lean`, called from `Completeness.lean` currently near :226-227), also sorry-free. `dd_countermodel_chronicle_mixed_sorry` is archived.

ROUTE (settled by task 361, design/03 sections 5.3-5.7):
- Route (i) — a Base-MCS → Discrete-MCS transfer lemma letting `countermodel_discrete_reynolds_v2` apply (the route the Transfer.lean docstring currently proposes) — is REFUTED and MUST NOT be re-attempted. Witness: over `ℤ ×ₗ ℤ` with `p` true exactly at points ≥ (1,0), `□U(⊤,⊥)` holds everywhere while `Axiom.z1 p` is false at (0,0); so a Base-MCS containing `□U(⊤,⊥)` need not be Discrete-consistent.
- Route (iii) — reuse the existing ℚ dense chronicle — is BLOCKED: `box_dense_gives_density` (`FormalSystem/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodelBasic.lean`; currently near :430, hint only) is load-bearing for the ℚ Cantor isomorphism and is unavailable when the order is discrete.
- Route (ii) — direct construction over the NON-ARCHIMEDEAN discrete carrier `ℚ ×ₗ ℤ` — is RECOMMENDED. `FrameClass.Base` imposes no Archimedean-ness (`valid`, `FormalSystem/Semantics/Validity.lean`; currently near :94, hint only, has no `IsSuccArchimedean` binder), so the ℤ+ℤ shape that killed the old BX `succ_cofinal` pipeline is not a counterexample here — it is the intended carrier. Do not re-attempt `succ_cofinal`.

DEPENDENCIES: task 421 corrects the refuted route guidance in Transfer.lean and probes the carrier's Mathlib instances; task 422 builds the discrete chronicle over that carrier plus its three restricted-coherence analogues. THIS task consumes 422's output to close `countermodel_discrete`, delete the Transfer.lean sorry, and re-verify `#print axioms completeness` reports no `sorryAx`.

ROLE IN THE COMPLETENESS PROGRAMME (terminology settled 2026-07-27): this is the headline WEAK terminus for Base, consumed by the consequence-completeness capstone (task 362) as its single-formula engine. The weak engine yields only the finite-context consequence corollary (inter-derivable with weak completeness via the deduction theorem — deliberately NOT called "strong completeness"). Genuine STRONG completeness for Base (Γ : Set Formula) additionally requires semantic compactness, gated on task 424; that obligation is NOT discharged by this task.

Governing design document: specs/archive/361_strong_completeness_architecture_and_weak_terminus_gap_analysis/design/03_weak-terminus-status.md.

---

### 128. Open set operator dense continuous
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: frame-extensions
- **Dependencies**: None

**Description**: Add topological open set (interior) operator for dense and continuous temporal frames. On discrete ℤ the interior is trivial (discrete topology), but on dense ℚ and continuous ℝ it captures neighborhood-stable truth: Int(φ) true at t iff φ holds in an open neighborhood of t. Related to Dynamic Topological Logic (Kremer-Mints 2005), McKinsey-Tarski topological semantics for S4, and Fernandez-Duque intuitionistic temporal logic. Phase 1: add TopologicalSpace instance to TaskFrame for dense/continuous cases. Phase 2: add interior constructor to Formula with truth clause. Phase 3: axioms (S4-like: Int(φ)→φ, Int(φ)→Int(Int(φ))). Phase 4: interaction with temporal operators and S5 □. Note: DTL is not finitely axiomatizable (Fernandez-Duque 2014) — completeness may require non-standard techniques.

---

### 127. Time addition operator
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: frame-extensions
- **Dependencies**: None

**Description**: Add time addition operator (+) to the bimodal logic TM. φ + ψ is true at (τ, x) iff ∃ y,z with x = y+z, φ true at (τ,y), ψ true at (τ,z). This internalizes the AddCommGroup structure of D into the object language, extending expressive power from FO[<] to FO[<,+] (Presburger arithmetic). Related to arrow logic (Venema), relevant logic (Routley-Meyer ternary frames), and separation logic (BI). Phase 1: add tadd/tsub constructors to Formula, truth clause in semantics. Phase 2: basic axioms (associativity, commutativity, identity, inverse). Phase 3: soundness proofs. Phase 4: interaction with G/H/U/S/□. Completeness (ternary canonical model) and decidability are open research problems — defer to later phases.

---

### 125. Jonsson tarski representation bimodal sus
- **Status**: [NOT STARTED]
- **Task Type**: formal
- **Topic**: algebraic-representation
- **Dependencies**: Task 420, Task 439, Task 461

**Description**: Implement a Jonsson-Tarski representation theorem for TM logic: every STSA embeds into the complex algebra of a concrete frame. Phased approach: Phase 1 — Complex algebra Cm(F): define powerset STSA for TaskFrames with box/G/H/sigma operators derived from frame relations. Prove Cm(F) satisfies all STSA axioms. Phase 2 — Ultrafilter frame Uf(A): given abstract STSA A, construct frame whose worlds are ultrafilters with canonical relations R_G, R_H, R_Box (seed infrastructure from task 163 recovery of UltrafilterChain.lean). Prove Uf(A) satisfies TaskFrame axioms. Phase 3 — Embedding theorem: prove eta(a) = {U | a in U} is an injective STSA homomorphism A into Cm(Uf(A)). Phase 4 — Since/Until extension: extend STSA typeclass with binary untl/sinc operators and prove representation for the full operator signature. Start with basic {box, G, H} fragment (Phases 1-3) before tackling S/U (Phase 4). Prerequisites: resolve 6 algebraic sorries (temp_k_dist, temp_a, temp_l in TenseS5Algebra/InteriorOperators/LindenbaumQuotient); obtain 3 missing papers (Jonsson-Tarski 1951/52, BRV 2001 Ch.5, Goldblatt 1989). Task 992 research report (01_stsa-algebraic-analysis.md) maps ~80% of needed infrastructure. Architecture: restructure Algebraic/ into Core/ (shared STSA/Boolean/ultrafilter), Completeness/ (renamed existing), Representation/ (new J-T work).

FOUR-AXIOM EXPOSURE NOTE (added 2026-08-10): Phase 2's obligation 'Prove Uf(A) satisfies TaskFrame axioms' is about to get strictly harder. Once task 420 lands, TaskFrame carries the paper's four def:frame axioms (biconditional Compositionality, Seriality, Limit, Spherical -- pinned in specs/paper-definitions-of-record.md) plus a Nonempty WorldState field and a [Nontrivial D] binder. Spherical (every directed family of nonempty fibers and segments has nonempty intersection) for an ultrafilter frame is a genuinely nontrivial NEW obligation the current three-field structure does not anticipate -- scope Phase 2 against the four-axiom target, and note the paper's finite-W discharge pattern (subset-least member of a finite directed family) does NOT apply to ultrafilter frames, which are typically infinite.

---

### 95. Completeness verification audit
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: completeness
- **Dependencies**: Task 169

**Description**: Verify and record the final axiom/sorry status of the headline metalogical results, then close.

RE-SCOPED 2026-07-26. Most of this task's original content has been ANSWERED by the archivable-sorry review, which resolved the question definitively rather than partially. Do not re-derive it:

  - The discrete-case sorryAx trace is COMPLETE. `WeakCanonical.countermodel_discrete`
    (FormalSystem/Metalogic/WeakCanonical/Transfer.lean) is the SOLE sorryAx source reaching
    `BXCanonical.completeness`. This was established by a whole-environment
    `Lean.collectAxioms` scan, not by inference from names or file locations.
  - The tainted set is exactly 3 declarations: countermodel_discrete,
    completeness, completeness'. It was 47 before the archival.
  - `completeness_dense` and `completeness_discrete` are CLEAN.
  - The BX chronicle path named in the original charter
    (dd_countermodel_chronicle_discrete -> succ_embed_surjective ->
    chronicle_gap_contradiction) was dead code and has been ARCHIVED to
    FormalSystem/Boneyard/DeadChronicleGapElimination/. It is no longer in
    the build, so there is nothing left to trace along that path.
  - The dense and mixed chronicle countermodels were already confirmed
    sorry-free.

WHAT REMAINS -- a narrow confirmation pass, not an investigation:
  (1) Re-run `#print axioms` (or lean_verify) on the headline theorems and
      confirm the state above still holds. Record the result.
  (2) Confirm the live sorry count is exactly 1, located BY CONTENT in
      FormalSystem/Metalogic/WeakCanonical/Transfer.lean -- never by line number, it drifts
      with every edit to that file.
  (3) Record, in a durable location, that discharging countermodel_discrete is a
      genuine open construction rather than an oversight: the clean
      `countermodel_discrete_reynolds_v2` requires a Discrete-MCS, and the old
      BX route is PROVABLY unavailable (succ_cofinal is refuted by the Z+Z
      counterexample). Proving it belongs to its own task.

METHODOLOGY WARNING, established the hard way: do NOT build a reverse-dependency
graph over `ConstantInfo.value?` to decide what depends on what. Under Lean
4.33's module system imported THEOREM bodies are unavailable, so such a graph
silently under-reports -- it wrongly showed countermodel_discrete as having zero
consumers, which would have led to archiving the one sorry that breaks
completeness. Use `Lean.collectAxioms` plus textual analysis instead.

EXPECTED OUTCOME: this task most likely closes as verified-complete. If step (1)
or (2) diverges from the state above, that divergence IS the finding and should
be reported prominently rather than silently reconciled.
