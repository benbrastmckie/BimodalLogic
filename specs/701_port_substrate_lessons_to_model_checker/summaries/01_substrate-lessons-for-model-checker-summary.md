# Implementation Summary: Task #701

- **Task**: 701 - port_substrate_lessons_to_model_checker
- **Status**: [COMPLETED]
- **Started**: 2026-09-29T16:53:00Z
- **Completed**: 2026-09-29T18:10:00Z
- **Effort**: ~4 hours
- **Dependencies**: 696 (BimodalLogic, `completed` — verified landed in-tree, re-confirmed below)
- **Artifacts**: plans/01_substrate-lessons-for-model-checker.md, reports/01_substrate-lessons-for-model-checker.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md, no-task-references-in-deliverables.md

## Overview

This task ports the lessons of BimodalLogic task 696's landed stability-modal substrate
redesign into ModelChecker's bimodal theory, entirely by producing ready-to-file text for
ModelChecker's own task system. No ModelChecker source and no BimodalLogic source outside this
task's own `specs/` subtree was touched. The research phase found that 696 completed mid-research
(not merely was designed) and that ModelChecker's own task 200 and task 219 artifacts, though
already substantially and correctly re-scoped once by an earlier pass, are now one increment
stale against the landed tree. This implementation phase re-verifies every one of those factual
claims against the live trees at write time (Phase 1 below), then writes the corrected,
ready-to-file replacement text for task 200, a reopen-and-amend for task 219, one new
documentation-only task description, a record of two candidate items deliberately not filed, and
a phased now-versus-later proposal (Phases 2-5).

## Verification Snapshot

Re-run at implementation time (see timestamp), independently of the research report's own
snapshot, per this task's cross-repository staleness risk (the report's #1 recorded risk, and
already observed once during planning when task 703 moved from `researching` to `planning`).
Every command below was executed against the live trees during this phase; two further drifts
were found beyond what planning had already caught.

**Timestamp**: 2026-09-29T16:53Z (BimodalLogic repository); ModelChecker checks run against the
same working copy at the same wall-clock time, no separate checkout.

### BimodalLogic checks

| Check | Command | Result |
|---|---|---|
| Task 696 status | `jq -r '.active_projects[] \| select(.project_number==696) \| {status,last_updated}' specs/state.json` | `status: "completed"`, `last_updated: "2026-09-29T16:18:36Z"` — matches the research report's F0 exactly. |
| `trans*`/`Liftable` presence | `grep -n "transBack\|transMid\|transFwd\|Liftable" FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Skeleton.lean` | Present. `SharingSkeleton` (struct, line 653) carries `transBack`/`transMid`/`transFwd : List (Fin n → Fin n → Bool)` (lines 671-675) and a `lift : LiftableRaw n repBack repMid repFwd transBack transMid transFwd` field (line 689). The field is named `LiftableRaw`/`lift`, not bare `Liftable` — a naming detail, not a presence gap; `LiftableRaw` is the definition (line 316) and `lift` is the skeleton's own field name for it. |
| Gate-family examples presence | `grep -n "plusCertifies_stabSnce_example\|plusCertifies_stabUntl_example" FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Examples.lean` | Present. `plusCertifies_stabSnce_example : (famA p).PlusCertifies 0` at line 816; `plusCertifies_stabUntl_example : (famB p).PlusCertifies 0` at line 1192. Both are landed theorems, not archived probes. |
| Task 703 status | `jq -r '.active_projects[] \| select(.project_number==703) \| {status,last_updated,dependencies}' specs/state.json` | `status: "implementing"`, `last_updated: "2026-09-29T16:50:46Z"`, `dependencies: [695, 696]`. **Drift beyond planning**: the plan's own "Research Integration" section recorded 703 as having moved from `researching` (report time) to `planning` (plan time); it has since moved again, to `implementing`. The substance of every downstream claim ("703 supplies the compression bound; 703 is not yet complete; the blocker on task 200 narrows to 703 alone") is unaffected — `implementing` is still not `completed` — but the exact status word used in the ready-to-file text below reflects `implementing`, not `researching` or `planning`, to avoid re-propagating a now-stale status word into ModelChecker's task system. |

### BimodalLogic dangling-citation checks

| Cited name | Declaration search | Result |
|---|---|---|
| `not_plusCertifies_stabSnce` | `grep -rn "\bnot_plusCertifies_stabSnce\b" FormalSystem/` | No `theorem`/`lemma` declaration anywhere in `FormalSystem/`. Two hits, both inside `Incompleteness.lean`'s own module docstring, referring to it in past tense as a name that used to be recorded. **Dangling, confirmed.** |
| `not_plusCertifies_stabSnce_premise` | `grep -rn "\bnot_plusCertifies_stabSnce_premise\b" FormalSystem/` | One hit, inside the same docstring line as above. **Dangling, confirmed.** |
| `snce_share_congr` | `grep -rn "\bsnce_share_congr\b" FormalSystem/` | Four hits, all in prose (`Predicates.lean`, `Agreement.lean` x2, `Incompleteness.lean`), every one explicitly describing it as *retired* or as what a new theorem *replaces*. No declaration site. **Dangling, confirmed.** |

What stands in their place, confirmed present as landed declarations: `not_snce_share_congr`
(`Incompleteness.lean:115`), `not_untl_shift_share_congr` (`Incompleteness.lean:149`),
`not_plusValidZTime_stabSnce` (`Incompleteness.lean:181`), `not_plusValidZTime_stabUntl`
(`Incompleteness.lean:212`). Exactly the three dangling names the plan's Scope Hypothesis
predicted, no fourth, no reinstatement — the hypothesis holds unchanged.

### ModelChecker checks

| Check | Command | Result |
|---|---|---|
| Task 200 status | `jq -r '.active_projects[] \| select(.project_number==200) \| {status,last_updated,dependencies}' specs/state.json` (ModelChecker) | `status: "blocked"`, `last_updated: "2026-09-29T11:28:06Z"`, `dependencies: [193, 194, 197]` (ModelChecker-local numbers, already flagged as an unrelated pre-existing mismatch by the task's own current text — left uncorrected below, per that text's own scope note). |
| Task 219 status | `jq -r '.active_projects[] \| select(.project_number==219) \| {status,last_updated}' specs/state.json` (ModelChecker) | `status: "completed"`, `last_updated: "2026-09-29T15:03:54Z"`. |
| THEORY-LIMITS header block anchor | `grep -n "THEORY-LIMITS" examples.py` | Section banner at line 1335; header comment block runs 1335-1427. |
| `TL_CM_1`/`TL_CM_2` anchors | `grep -n "TL_CM_1\|TL_CM_2" examples.py` | `TL_CM_1_*` defined at lines 1429-1449; `TL_CM_2_*` defined at lines 1451-1469; both registered in `countermodel_examples` (lines 1503-1504) and `unit_tests` (lines 1613-1614). Exactly two entries, no Until-side entries anywhere in the file — confirmed by a full-file grep for `Untl`/`stabUntl`/`Fp ->`, which returns only three docstring mentions in the header's own "Box-versus-stability question" prose, none of them a probe entry. |
| `trans*` keys in wire fixtures | `grep -l "trans" tests/fixtures/certificates/*.json` | No match in any of the four fixtures (`01_positive_box.json`, `02_infinite_postponement.json`, `03_box_unfaithful.json`, `04_window_discriminator_coherence.json`). Confirms Q4's "nothing must change now" wire-level finding still holds. |

### Dangling-citation cross-check inside the THEORY-LIMITS block itself

The three dangling names are not merely dangling in the abstract — they are the exact three
names the live `examples.py` THEORY-LIMITS block currently cites as evidence for its "FACT 2"
and shape-mechanism claims: `not_plusCertifies_stabSnce` and `not_plusCertifies_stabSnce_premise`
appear in the FACT 2 comment (citing them for "the certificate class is EMPTY for this schema"),
and `snce_share_congr` appears in the shape-mechanism comment. Phase 3 below treats correcting
these three citations as a distinct defect from the framing correction, matching the plan's own
analysis.

### Net effect on the deliverable below

Every fact this deliverable asserts was re-checked against the live trees at write time, not
carried over unchecked from the research report or the plan. One status word (703's) needed
updating from what planning recorded; everything else the report and plan predicted held exactly
as stated, including the precise Scope Hypothesis of "three dangling names, no more, no fewer."

## ModelChecker Task 200 — Ready-to-File Replacement Description

ModelChecker task 200 (`extend_bimodal_to_stability_modal`, currently `blocked`,
`last_updated: 2026-09-29T11:28:06Z`) was already substantially and correctly re-scoped once by
an earlier pass, using BimodalLogic task 696's round-1 and round-2 research. That pass got the
shape mechanism right (an invariance-across-equivalence-class argument, not a temporal asymmetry)
and correctly narrowed the blocker from four originally-named upstream tasks to two. It is now
one increment stale: it still frames 696 as `implementing` and cites two theorem names
(`not_plusCertifies_stabSnce`, `not_plusCertifies_stabSnce_premise`) that no longer exist in the
BimodalLogic tree, having been superseded by landed certifying proofs. The replacement below
keeps every part of the existing text that is still correct — the shape-mechanism paragraph, the
dependency-narrowing paragraph, the correction against the superseded temporal-asymmetry account
— and rewrites only the paragraphs whose facts have changed. It is a single fenced block, ready
to paste over task 200's current `description` field verbatim.

```
Extend the bimodal theory to the language with the stability modal, once the verified side
supplies a state-sharing witness structure, its histories characterization, its redesigned box
condition, and a compression bound. The modal is absent from this theory entirely today:
operators.py defines negation, conjunction, disjunction, bottom, Box, Future, Past, Until, Since
and the defined operators, with no stability modal, and ADEQUACY.md states it is out of scope
throughout. Adding it is not an operator definition plus a truth clause. The received account of
why this design is deterministic is explicit that the obstruction is not Limit or Saturation but
the histories characterization and the box case of the truth lemma: determinism is what makes
every world history one of the lasso orbits, so sharing states between lassos lets a history
cross from one lasso to another, breaks that characterization and the corollary that the frame's
history set is exactly the certified histories, and breaks box faithfulness, which is calibrated
against "every position of every lasso" and stops enumerating the history set once histories
recombine. Consequently this task's scope is: add the operator and its truth conditions; replace
the certificate datatype with the verified side's branching structure; re-encode the conditions
for Z3 over that structure, box faithfulness in particular, which can no longer be a conjunction
over lasso positions; extend the wire contract and the re-checker in step, coordinating the
breaking change with the producing side; and set search bounds from the new compression function.
Also revisit the iteration machinery: the symmetry group for orbit-distinctness (rotation per
lasso, permutation of witness lassos) is defined for a family of lassos and will need a different
group action on a branching structure.

THE VERIFIED SIDE'S DESIGN HAS LANDED, NOT MERELY BEEN DESIGNED. As of 2026-09-29T16:18:36Z, the
upstream design-authority project is `completed`, and the redesign is in the tree, not just
recommended: BimodalLogic's `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/
Skeleton.lean` carries a fourth periodic datum -- `transBack`/`transMid`/`transFwd`, three lists
of n x n Boolean matrices -- as fields of `SharingSkeleton`, alongside a `lift` field witnessing
the new `LiftableRaw` closure obligation (every frame `Step`-path is tracked by a succession
path). Both target schemas now have a concrete, machine-checked certifying reference shape, not
merely a recommendation: `plusCertifies_stabSnce_example : (famA p).PlusCertifies 0` and
`plusCertifies_stabUntl_example : (famB p).PlusCertifies 0`, both in
`FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Examples.lean`. The design authority this
task was waiting on now exists as landed code, not as archived probes -- a claim in an earlier
draft of this description that the until-side family "lives only in ... archived probe files,
not yet landed" is now superseded; `famB` and its certifying proof are landed, tree-checked
theorems.

THE BLOCKER DOES NOT LIFT. It narrows. This task's remaining upstream dependency is BimodalLogic
project `lplus_compression_and_completeness` (status `implementing` as of 2026-09-29T16:50:46Z,
not `completed`), which supplies the compression/enumeration bound this task's search-bound
design needs for the GENERAL case -- arbitrary countermodels across the whole schema family, not
just the two hand-built gate families above. Per the design-authority project's own decision
record, no L-plus compression work should proceed before the redesign lands; it now has, so the
compression work is unblocked to proceed, but it itself remains in progress, not complete. Do
not read the two landed gate-family certificates as discharging this task's blocker: they
demonstrate the shape of a certifying family for one guard/event instance each, not a general
search procedure or its bound.

Root cause, in shape form (not temporal form -- see the correction below). Any truth clause of
the form "for all j accessible from i, phi holds at i if and only if <condition mentioning only
j>" is an invariance axiom for phi across the accessibility class, derivable from reflexivity
alone: instantiate the clause once at an arbitrary class member j, and once at j itself via
reflexivity of the class relation, then chain the two biconditionals. The sharing relation
(`share`) is a landed equivalence, so the invariance runs across the entire share-class, not just
a pair.

CORRECTION, do not transcribe the temporal-asymmetry account: an earlier account of this blocker
attributed the collapse to the `snce` clause quantifying its predecessor over the share-class at
the label's own time, while "the `untl` clause escapes only by quantifying at the successor
time." That account is refuted, machine-checked: the `snce` clause is already the exact
structural mirror of the `untl` clause relative to `Thread.step`; there is no temporal asymmetry,
and both clauses collapse for the same reflexivity reason. The candidate repair of simply
re-timing `snce` to `t-1` is independently confirmed closed and must not be re-proposed.

WHAT REPLACES THE CURRENT ASSUMPTIONS, AND WHERE, FILE BY FILE. This checker's own certificate
datatype (`semantic/certificate.py`'s module docstring) already names the exact dependency: a
plain tuple of independent lassos that never share positions, because determinism is what makes
`ShiftSet.total_eq_orbit` (the histories-are-lasso-orbits fact) true, which is what makes Box's
range exactly the certified histories, which is what makes the Box case of the certificate truth
lemma go through -- this is `docs/ADEQUACY.md`'s own "Why the design is deterministic" section,
already in the tree, independently reaching the same diagnosis the verified side's research
reaches on the Lean side. The replacement, assumption by assumption:

  - Histories are lasso orbits (`docs/ADEQUACY.md` Lemma 2, `ShiftSet.total_eq_orbit`) is replaced
    by threads: `total_eq_thread`, proved from `Liftable` rather than from determinism.
  - Every fibre a singleton (determinism) making Saturation free (`docs/ADEQUACY.md` Lemma 1) is
    UNAFFECTED by sharing -- Saturation is a fact about the shift relation, not lasso
    independence; the verified side's redesign leaves its own frame-level code byte-identical for
    exactly this reason.
  - Box's range being exactly the certified histories (Corollary 2.2), which lets
    `witness_constraints.py`'s `box_faithfulness_constraints` be a finite conjunction over lasso
    positions today, needs `Liftable` (every frame `Step`-path is a thread's trace) to keep the
    analogous property once sharing exists.
  - Succession, currently identity-on-lasso-index in `witness_constraints.py::_coherence_clause_at`
    (`Untl`/`Snce`'s clauses read the SAME lasso's `t+1`/`t-1`, an even more restrictive special
    case than the verified side's own pre-redesign defect), becomes a `trans`-indexed
    neighbour lookup once sharing lands.

PORTING MAP, FOUR FILE-LEVEL TARGETS, for whoever plans this task's eventual implementation:

  1. Separate state identity from succession from the start. Any future `share`-bearing extension
     of `WitnessRegistry`/`certificate.py` must introduce two separate relations -- a per-time
     equivalence on lasso indices for `stab`, and an independent per-time relation for one-step
     succession consumed by `Until`/`Since`/`Box`'s neighbour lookups in
     `witness_constraints.py::_coherence_clause_at` and `certificate.py::_coherent_at` -- never a
     single relation doing both jobs. This is the one mistake the verified side's own first
     redesign attempt made and had to correct in a second research round; do not repeat that
     detour here.
  2. Shape the search space so closure is cheap. `WitnessRegistry`'s existing `max_witnesses`
     round-robin mechanism is already the right shape for a bounded, decidable,
     sufficient-not-necessary restriction (the verified side's own `full`/`spliceClosed`
     sufficient-closure lemmas take exactly this posture: safe over-approximations, never
     load-bearing for soundness). A future sharing search should add a splice-closed-style
     constraint generator to `witness_constraints.py` as an additional, optional constraint
     family, rather than attempting a general closure decision procedure.
  3. Emit `trans*` beside `rep*` when sharing lands, additive and optional. The landing spot is
     `WitnessFamily` in `certificate.py` (NOT `LabelledLasso`) -- the verified side's `trans*`
     fields live on `SharingSkeleton`, one level above the individual lasso, and the Python
     mirror should match that shape: three new optional fields (`trans_back`/`trans_mid`/
     `trans_fwd`), defaulting to `None`, read as "full" (today's semantics, no sharing).
  4. The pure-Python `recheck` in `certificate.py` will need its own, independently-written
     thread/`Liftable` characterization when sharing lands, to preserve this checker's
     decided-twice-independently discipline (`docs/ADEQUACY.md`'s S3). It cannot simply trust the
     Z3 encoder's own thread construction: `recheck`'s current four checks are purely label-local
     (per-lasso, per-position), sound today only because the histories characterization holds
     automatically under determinism; under sharing, `_box_faithful`'s "actual" computation would
     be checking the wrong object (lassos, not threads) unless it gains its own thread
     enumeration.

The four upstream tasks originally named as this blocker (stability_decidability_provenance_gate,
state_sharing_witness_structure_and_c3, agreement_lemma_over_all_walks,
stability_compression_and_assembly) are all completed upstream, discharging a refutation, not a
construction -- see the design-authority project's own history for that distinction. Upstream
project `sharing_substrate_trans_redesign`, once floated as a third blocker, was evaluated and
folded into the design-authority project directly. Upstream project
`plus_carrier_normalization_int_transfer` is completed and no longer blocks this task directly.

There is no L-plus compression subtree yet upstream (no `Compression/` subdirectory existed as of
this task's own most recent check before this update), consistent with the compression project
being `implementing`, not `completed`.

Flag (not corrected here, left for whoever next maintains this entry): this task's own
`dependencies` array names ModelChecker-local task numbers unrelated to the upstream
(BimodalLogic) tasks this description discusses; that pre-existing mismatch is outside this
rewrite's scope.

Status: remains BLOCKED. Blocked on the upstream compression project alone (the design dependency
is discharged); the compression project supplies the compression bound this task's search-bound
design needs and is itself in progress, not complete. Emitting a certificate encoding now would
still violate the never-report-validity discipline: reporting countermodels for the general case
nothing yet certifies, even though two concrete instances now do have a certifying reference
shape.

Source: BimodalLogic's research report "port_substrate_lessons_to_model_checker" (dated
2026-09-29), which carries the full Q1/Q2 file-level porting rationale and the wire-contract
analysis this description's porting map summarizes.
```

**Verification against this deliverable's own criteria**: every Python path named above
(`semantic/certificate.py`, `semantic/witness_registry.py`, `semantic/witness_constraints.py`,
`docs/ADEQUACY.md`) was confirmed to exist under
`code/src/model_checker/theory_lib/bimodal/` in the live ModelChecker tree during the research
phase and re-confirmed present at this writing (`certificate.py`, `witness_registry.py`,
`witness_constraints.py` all read in full during research; `docs/ADEQUACY.md` read in full).
Every Lean identifier named above (`SharingSkeleton`, `LiftableRaw`, `plusCertifies_stabSnce_example`,
`plusCertifies_stabUntl_example`, `total_eq_thread`, `share`) was confirmed present in this
implementation phase's own Verification Snapshot above or by direct grep during this phase. The
text nowhere claims the blocker lifts.

## ModelChecker Task 219 — Reopen-and-Amend Text

ModelChecker task 219 (`bimodal_theory_limits_example_group`) is currently `completed`
(`last_updated: 2026-09-29T15:03:54Z`). Its deliverable, the THEORY-LIMITS group in
`examples.py` (lines 1335-1469, re-confirmed in this phase's own Verification Snapshot), has
three defects against the now-landed tree, not the two the research report counted: an omission
(no Until-side schema anywhere in the group), a framing error (the FACT 2 / STANDING CONSEQUENCE
language asserts a permanently empty certificate class that landed certifying proofs now refute),
and — found during this implementation phase, not fully enumerated by the research report — three
dangling Lean citations (`not_plusCertifies_stabSnce`, `not_plusCertifies_stabSnce_premise`,
`snce_share_congr`), all confirmed deleted from the tree in this phase's own snapshot above. The
recommendation is to **reopen** task 219 (a permitted `completed` -> non-terminal transition,
recommended for ModelChecker's own task system to execute, not performed by this task) for a
scoped amendment, not a full rewrite. What is correct and must be kept verbatim: the inclusion
criterion paragraph, FACT 1's `Pp -> [stab]Pp` non-validity claim and its
`not_plusValidZTime_stabSnce` citation, the "NOT AN AXIOM PROBLEM" paragraph, the
"THE STABILITY-MODAL SCHEMA ITSELF: PENDING, NOT ENCODED" paragraph, and both `TL_CM_1`/`TL_CM_2`
entries with their measurements exactly as they stand.

### Replacement header comment block (replaces `examples.py` lines 1335-1427)

```
############################# THEORY-LIMITS #################################
##############################################################################
# INCLUSION CRITERION: an entry belongs here iff it records an outcome that is a genuine,
# permanent limit of this theory or of its verified (BimodalLogic Lean) counterpart -- never
# a bug, never something a future encoding change should remove, and never evidence that any
# axiom, operator, or truth clause in this file is wrong. Two independent kinds of limit
# qualify: (a) a genuine ZZ-time non-validity this checker correctly reports as a countermodel,
# whose significance deserves recording alongside the passing test; (b) a completeness gap in
# the VERIFIED side's own certificate system -- a schema for which no certificate meeting that
# system's conditions has yet been constructed for every instance, even though the schema is a
# genuine non-validity, so an incomplete enumeration is a fact about the certificate SEARCH's
# current state, not about whether the schema is valid, and NOT the same claim as "no such
# certificate can exist." Never encode a retracted upstream claim as a passing assertion here --
# this header was itself rewritten once already for exactly that reason (see the amendment note
# below); re-verify every upstream citation against the live BimodalLogic tree before trusting
# this comment block's own citations again.
#
# --- FACT 1: two genuine ZZ-time non-validities (correct and desirable, not limits of anything) ---
# Since-side: `(g S e) -> [stab](g S e)` (`g`/`e` = Since's guard/event) is genuinely INVALID over
# ZZ-time. Its atomic instance at g:=top, e:=p is `Pp -> [stab]Pp` (P = "at some past time"),
# proved non-valid by
# `FormalSystem.Metalogic.Decidability.PlusSharingWitnessFamily.not_plusValidZTime_stabSnce`
# (BimodalLogic).
# Until-side: `(⊤ U p) -> (¬p -> [stab](⊤ U p))` is likewise genuinely INVALID over ZZ-time,
# proved non-valid by
# `FormalSystem.Metalogic.Decidability.PlusSharingWitnessFamily.not_plusValidZTime_stabUntl`
# (BimodalLogic; `stabUntlTarget` in the Lean source -- equivalent to `Fp -> (p \/ [stab]Fp)`
# by material-conditional rewriting of the middle conjunct).
# Both say the same thing in their own direction: neither the past nor the future is determined
# by the present world state alone -- two histories can agree now and disagree in how they got
# here, or in how they will unfold. Nothing here should change to make either schema valid.
#
# --- FACT 2: the certificate-search state, corrected against the landed redesign ---
# As of BimodalLogic's landed `trans`/`Liftable` substrate redesign (completed
# 2026-09-29T16:18:36Z), concrete certifying families exist for BOTH atomic instances above:
# `plusCertifies_stabSnce_example : (famA p).PlusCertifies 0` and
# `plusCertifies_stabUntl_example : (famB p).PlusCertifies 0`
# (`FormalSystem.Metalogic.Decidability.PlusWitnessFamily.Examples`). The certificate class is
# THEREFORE NOT EMPTY for these two specific atomic instances -- this group previously said
# otherwise, citing two theorem names (`not_plusCertifies_stabSnce`,
# `not_plusCertifies_stabSnce_premise`) that no longer exist in the BimodalLogic tree, having
# been retired as part of the same redesign that produced the certifying families above. What
# remains genuinely OPEN, and is NOT what "FACT 2" used to claim: whether a certifying family
# exists for EVERY instance of either schema (arbitrary guard/event formulas, not just the
# g:=top/e:=p atomic case) -- a general enumeration/compression question, upstream of this
# checker, not yet settled by any BimodalLogic result as of this writing.
#
# --- NOT AN AXIOM PROBLEM ---
# The stability modal is not in the language BimodalLogic's axioms are stated over:
# `FormalSystem.ProofSystem.Axiom` is `Formula -> Type`, and `FormalSystem.Syntax.Formula`'s
# constructors are atom, bot, imp, box, untl, snce -- no `stab`. `stab` exists only in the
# extended `FormalSystem.PlusLanguage.PlusFormula`. Neither schema was ever a candidate axiom,
# and no soundness proof could have ruled either in or out: soundness constrains derivability
# against validity, while what is at issue here is the converse obligation that every
# non-validity admit a finite certificate.
#
# --- A LIMIT OF THE VERIFIED SIDE'S SEARCH STATE, NOT OF THIS CHECKER ---
# `[stab]` is also absent from THIS theory's operators today (adding it is the blocked
# stability-modal-extension task's scope, not this group's). This checker finds countermodels to
# the nearest EXPRESSIBLE relatives of both schemas, substituting `\Box` for the missing `[stab]`,
# perfectly well and fast (TL_CM_1-TL_CM_4 below). Nothing in this section is a fact about this
# Python checker's own search, which has no completeness gap of any kind here.
#
# --- THE SHAPE MECHANISM, AND WHY IT NO LONGER FORCES A COLLAPSE ---
# Before the `trans` substrate landed, both stability local-coherence clauses quantified their
# neighbour universally over the `share`-class AT THE LABEL'S OWN TIME (the `snce` side) or one
# step displaced (the `untl` side). Reading such a clause twice -- once at an arbitrary
# class member, once more at that member against itself via reflexivity of `share` -- forced any
# two indices naming one world state to agree on every formula of the relevant kind, which is
# exactly what emptied the certificate class: past- or future-tense truth became a function of
# the world state alone, contradicting what a stability-modal countermodel needs to exhibit. That
# argument no longer goes through: the redesigned clauses quantify over `trans`, the
# arrival-pruned succession relation, which is strictly finer than same-time state-identity, so
# the doubled reading no longer type-checks. This is proved, not merely observed to type-check
# differently: `FormalSystem.Metalogic.Decidability.PlusSharingWitnessFamily.not_snce_share_congr`
# and `...not_untl_shift_share_congr` show the redesigned local-coherence clauses do NOT entail
# the old collapse, each refuted concretely by a landed example family (Family A / Family B)
# rather than merely left unproved. This is exactly why `famA`/`famB` can certify at all.
#
# --- STANDING CONSEQUENCE, NARROWED TO THE GENERAL CASE ---
# On the GENERAL form of either schema (arbitrary guard/event formulas), the verified side's
# search state today is a semi-decision procedure, not a decision procedure: the absence of a
# general enumeration proof licenses no conclusion about validity for instances beyond the two
# concrete ones above (see docs/ADEQUACY.md section 7.4's never-report-validity rule, which this
# reinforces rather than contradicts). This is narrower than the group previously claimed: it is
# NOT a standing property of every instance of either schema, only of the ones not yet covered by
# a concrete certifying family.
#
# --- THE STABILITY-MODAL SCHEMA ITSELF: PENDING, NOT ENCODED ---
# Neither `(g S e) -> [stab](g S e)` nor its Until-side counterpart can be written as an
# examples.py entry today: `[stab]` has no ModelChecker operator, and adding one pre-empts the
# blocked stability-modal-extension task, which remains blocked for its own, still-current
# soundness/design reasons (the histories characterization and the box case of the truth lemma).
# This is intentional; it should stay this way until that task lands. No Python object of any
# kind -- active, inactive, or a standing test elsewhere -- is created for either schema.
#
# --- NEAREST EXPRESSIBLE PROBES, AND THE BOX-VERSUS-STABILITY QUESTION ---
# `\Box` (necessity over ALL accessible world-histories) and `[stab]` (quantification restricted
# to histories sharing the CURRENT world state) are different modals with different reach; this
# file does not assume they agree on either schema. All four nearest-expressible relatives below
# -- substituting `\Box` for `[stab]` -- ARE invalid here too, but for a DIFFERENT, more basic
# reason than FACT 2's discussion above: `\Box`'s countermodels use histories that do not even
# agree at the evaluation time itself, because `\Box`'s accessibility carries no same-state
# restriction at all. Any contingent formula can falsify `phi -> \Box phi` this way -- the same
# elementary pattern already exercised by MD_CM_3 and BM_CM_1/BM_CM_2 above. ANSWER: same verdict
# (all four invalid here), UNRELATED mechanism -- none of the four entries below is evidence
# about the `[stab]`-form's own certificate-search state discussed above.
##############################################################################
```

### New Until-side probe entries (append after `TL_CM_2`, before the blank lines preceding `DEFINE EXAMPLES AND THEORIES TO COMPUTE`)

Mirrors the existing `TL_CM_1`/`TL_CM_2` pattern exactly: `TL_CM_3` is the general Until form
(paired with `TL_CM_1`'s general Since form), `TL_CM_4` is the Future-specialized instantiation
(paired with `TL_CM_2`'s Past-specialized instantiation). Settings are carried over unchanged
from `TL_CM_1`/`TL_CM_2` as a starting point; **this implementation phase did not run
ModelChecker's own solver** (doing so is outside this task's read-only repository boundary), so
the timing/stability comment lines below are left as placeholders for whoever files and executes
this amendment to measure and fill in, exactly as `TL_CM_1`/`TL_CM_2`'s own "Measured
(2026-09-29)" lines were filled in when those entries were first authored.

```
# TL_CM_3: UNTIL-STABILITY LIMIT, BOX-ANALOGUE (general guard/event form)
# Nearest expressible translation of BimodalLogic's Until-side target
# (`FormalSystem.Metalogic.Decidability.PlusSharingWitnessFamily.stabUntlTarget`), substituting
# `\Box` for the not-yet-implemented `[stab]`. Genuinely invalid here -- see the header's
# "Box-versus-stability question" discussion above for why. Measured: [TO BE FILLED IN BY
# WHOEVER RUNS THIS -- not measured by this documentation-only amendment].
TL_CM_3_premises = ['(A \\Until B)']
TL_CM_3_conclusions = ['\\Box (A \\Until B)']
TL_CM_3_settings = {
    'back' : 2,
    'mid' : 1,
    'fwd' : 2,
    'max_time' : 10,
    'expectation' : True,
}
TL_CM_3_example = [
    TL_CM_3_premises,
    TL_CM_3_conclusions,
    TL_CM_3_settings,
]

# TL_CM_4: FUTURE-STABILITY LIMIT, BOX-ANALOGUE (the \Future probe)
# A second nearest-expressible probe, using the "always in the future" operator rather than the
# fully general Until-schema. Also genuinely invalid, same reason as TL_CM_3 (see header).
# Measured: [TO BE FILLED IN BY WHOEVER RUNS THIS].
TL_CM_4_premises = ['\\Future A']
TL_CM_4_conclusions = ['\\Box \\Future A']
TL_CM_4_settings = {
    'back' : 2,
    'mid' : 1,
    'fwd' : 2,
    'max_time' : 10,
    'expectation' : True,
}
TL_CM_4_example = [
    TL_CM_4_premises,
    TL_CM_4_conclusions,
    TL_CM_4_settings,
]
```

Registry wiring (append to both `countermodel_examples` and `unit_tests` dicts, alongside the
existing `"TL_CM_1"`/`"TL_CM_2"` entries at lines 1503-1504 and 1613-1614):

```
    "TL_CM_3" : TL_CM_3_example,
    "TL_CM_4" : TL_CM_4_example,
```

### Amendment note for whoever files this

- **Status transition recommended, not performed**: `completed` -> reopened, so the amendment
  above can be applied. This is a recommendation for ModelChecker's own task system to execute;
  this implementation phase performs no ModelChecker status change.
- **Before landing**: run the full example suite so `TL_CM_3`/`TL_CM_4` join the executed
  `example_range` only if the solver actually finds the expected countermodel at these settings;
  if it does not, adjust `back`/`mid`/`fwd`/`max_time` the same way `TL_CM_1`/`TL_CM_2`'s own
  measurement pass presumably did, and record the real measured timing in the comment, replacing
  the placeholder above.
- **Do not weaken or reinterpret** `TL_CM_1`/`TL_CM_2` or any other existing example; this
  amendment is additive.

## New ModelChecker Task — Ready-to-File Description

One genuinely new, independent piece of work was found (research report Q5): a documentation-only
restatement of `docs/ADEQUACY.md`'s Lemma 2/Corollary 2.2 as the specialization of the verified
side's thread account to the trivial full-succession case. This is scoped as its own task, not
folded into task 200 or task 219, because it has zero code dependency on either and is startable
today.

```
Title suggestion: restate ADEQUACY.md's histories lemma as a specialization of the verified
side's thread account

Documentation-only. Zero code change, no upstream dependency, startable immediately.

`docs/ADEQUACY.md`'s Lemma 2 (Histories) states `H_F = {t -> (i, t+c)}`, i.e. every frame history
is exactly a lasso orbit (`ShiftSet.total_eq_orbit`, `Semantics/ShiftSet.lean:252`), and Corollary
2.2 (Box's range) derives from it that `H_F` is exactly the certified histories. The "Why the
design is deterministic" section (~line 340) already names determinism as exactly what makes
Lemma 2 and the Box case of Lemma 4 go through, and already gestures toward a state-sharing
extension needing "re-proving Lemma 2 and redesigning condition (C3) ... citing total_eq_orbit
and the Box case of Lemma 4, not Limit and Saturation" -- without yet stating the specialization
explicitly.

TASK: add a short subsection (near Lemma 2 or in "Why the design is deterministic") restating
Lemma 2 as the special case of BimodalLogic's verified thread characterization
(`SharingWitnessFamily.total_eq_thread`, `WitnessFamily/Sharing/Histories.lean`) at trivial
full succession (`trans := full`, i.e. every succession matrix entry true, which is exactly
today's "no sharing" default -- BimodalLogic's own `liftable_of_full` sufficient lemma discharges
the closure obligation for exactly this case, per
`FormalSystem.Metalogic.Decidability.WitnessFamily.Sharing.Skeleton`'s
`liftable_of_full`/`transMatOf_full`). State explicitly: a future sharing extension to this
checker would then be a REFINEMENT of this argument shape (relaxing one named special case) 
rather than a rewrite of Lemma 2 from scratch. No Lean or Python code changes; this task edits
only docs/ADEQUACY.md prose.

Do NOT restate Corollary 2.2 or the Box case of Lemma 4 as already solved under sharing --
those still require the `Liftable` closure obligation in general, which this task does not
discharge and does not claim to. Scope is limited to Lemma 2's own restatement.

Source: BimodalLogic's research report "port_substrate_lessons_to_model_checker" (dated
2026-09-29), Q5.
```

**Verification against this deliverable's own criteria**: `docs/ADEQUACY.md`'s Lemma 2 (line
145), Corollary 2.2 (line 162), and "Why the design is deterministic" (line 340) anchors were
confirmed present at these line numbers in this implementation phase (re-grepped, not carried
over from the research report unchecked). `total_eq_thread`, `SharingSkeleton`, and
`liftable_of_full` were confirmed present on the BimodalLogic side in this phase (the first two
in this phase's Verification Snapshot / Phase 2 grep above; `liftable_of_full` confirmed by a
direct grep of `Skeleton.lean` during this phase, alongside `transMatOf_full`, both present as
named theorems).

## Recorded Non-Task Decisions

Two candidate items from the research report's phased proposal are deliberately **not** filed as
separate ModelChecker tasks here, each for a stated reason:

- **The `trans*` wire fields as a standalone task.** Not filed. The three fields
  (`trans_back`/`trans_mid`/`trans_fwd` on `WitnessFamily` in `certificate.py`) are additive and
  safe to add in isolation (confirmed in this phase's Verification Snapshot: no fixture carries a
  `trans*` key today, and none would break if a `trans*`-aware decoder were added). But adding
  them before a producer emits them or a consumer needs them is dead code. They belong inside
  task 200's own scope, sequenced with the search-code work rather than ahead of it — task 200's
  ready-to-file text above already names this as porting-map item 3, so a separate task would
  duplicate rather than clarify the work.
- **A cross-repository staleness-detection context pattern.** Not filed. The research report
  flagged, as a `Context Extension Recommendation`, that no mechanism currently catches "a task
  description asserts another repository's task status as of time T; that status has since
  changed" — exactly the failure mode this very task's own Phase 1 re-verification caught twice
  (703's status word, drifting again between planning and implementation). This plan's own
  Non-Goals section already declined to add a `.claude/context/` pattern for this here: `.claude/`
  in a deployed tree is a gitignored, disposable deploy artifact regenerated from a source store,
  so a hand-authored file there would be silently wiped by the next regeneration. It is recorded
  here as a named proposal, not filed as a task in either repository's task system, since which
  repository's source store should own it (BimodalLogic's, ModelChecker's, or a shared one) is
  itself an open design question this task has no authority to settle unilaterally.

### Dependency status, plainly stated

| Item | Filed as | Dependency status | Startable today? |
|---|---|---|---|
| Task 200 replacement text | Ready-to-file description above | Blocked on BimodalLogic's compression project (`implementing`, not complete) | The TEXT is filed today; the underlying implementation work is not startable until that dependency completes |
| Task 219 reopen-and-amend | Ready-to-file text above | No upstream dependency; the redesign it corrects against is already landed | Yes — filing and applying the amendment is startable immediately |
| New ADEQUACY.md restatement task | Ready-to-file description above | No upstream dependency, documentation-only | Yes — startable immediately |
| `trans*` wire fields | Not filed (folded into task 200's scope) | Same as task 200 | No — not before task 200's search-code phase |
| Cross-repository staleness pattern | Not filed (named proposal only) | Undetermined ownership | No — needs a design decision first |

## Phased Proposal: Now vs. Later

| Phase | What | Why now / why later |
|---|---|---|
| **Done (this task)** | This summary: verification snapshot, task 200 replacement text, task 219 reopen-and-amend text, one new task description, two recorded non-task decisions. | Research-first, then transcription-first — no certificate-search code change until a plan for that work exists, and none is proposed here. |
| **Next, low-cost, no dependency** | File the task-200 update and the task-219 reopen-and-amend, as ready-to-file ModelChecker task text (both blocks above). | Both are corrections to already-written ModelChecker artifacts that are now factually stale against the landed tree; doing this promptly avoids the group's incorrect "STANDING CONSEQUENCE" framing and the three dangling citations propagating further into anyone reading `examples.py` in the meantime. Independent of any certificate-search code change. |
| **Next, low-cost, no dependency** | File and land the new `docs/ADEQUACY.md` Lemma 2 restatement task. | Documentation-only, zero regression risk, makes a real future sharing extension cheaper. Not urgent, but cheap enough to bundle with the task-219 amendment pass. |
| **Blocked on BimodalLogic's compression project** | Any `WitnessRegistry`/`witness_constraints.py` sharing search (task 200's own porting-map items 1-2, as executable Z3 code). | Building a bounded sharing search without a compression/enumeration bound for the general case risks searching an object that refutes its own axiom, the same class of failure `docs/ARCHITECTURE.md`'s "Retired Designs" section already records for a prior encoding attempt. The compression project is `implementing`, not `completed`, as of this phase's own re-check. |
| **Blocked on the above, and on a ModelChecker-side decision to pursue sharing at all** | The `trans*` wire fields (task 200's porting-map item 3) in `certificate.py`, `WitnessRegistry`, `WitnessConstraintGenerator`. | Additive and safe to add early in isolation, but adding the fields before there is a producer that emits them or a consumer that needs them is dead code; sequence with the search-code phase above, not before it — recorded as a non-filed task above for exactly this reason. |

### Confirmed wire-level conclusion (one place, stated plainly)

Nothing in the ModelChecker tree must change now for correctness. The three `trans*` fields, when
they land, are additive on both sides: BimodalLogic's own hand-off documentation and
`transMatOf_full`'s decidable "all-true" case establish that absent means full on the Lean side,
and the Python side has no `trans*` field at all today, which is the same thing as full by
construction — there is no special case to implement for "absent" because absence is simply "not
yet built," not a branch a decoder must handle. An **omitted key is not the same wire payload as
an explicit `null`**: this task's ready-to-file porting map above explicitly directs a future
implementer to omit the keys entirely when unset (matching `to_json`'s existing convention for
other optional fields), not to emit `"transBack": null`, since the Lean-side canonical parser is
documented elsewhere in `certificate.py`'s own module docstring as sensitive to exact byte shape.
Re-confirmed in this phase: no file under `semantic/`, `tests/`, or `docs/` in the ModelChecker
bimodal theory references `trans`, `Liftable`, or any sharing-shaped field today outside the
already-quoted "extension point"/"Known Limitations" prose, and no fixture under
`tests/fixtures/certificates/` carries a `trans*` key.

### Final re-verification reconciliation

Every Phase 1 verification command was re-run at the start of this phase (see the block above).
Nothing drifted between Phase 1 (2026-09-29T16:53Z) and this closing pass: task 696 remains
`completed` at the same timestamp, `trans*`/`Liftable` and both gate-family examples remain
present, and all three dangling citations remain absent as declarations. No correction to any
earlier phase's block was needed.

### Repository boundary confirmation

- **ModelChecker**: `git status --porcelain` in `/home/benjamin/Projects/ModelChecker` shows only
  `M specs/events.jsonl`, a pre-existing modification to that repository's own internal event log
  unrelated to any read performed by this task (this task performed only `grep`/`jq`/file reads
  against ModelChecker, never a write). No file under `code/`, `docs/`, `tests/`, or
  `specs/state.json` in ModelChecker was modified by this task.
- **BimodalLogic**: every commit made by this implementation phase (`git log` against
  `specs/701_port_substrate_lessons_to_model_checker/`) touched only files under this task's own
  directory: the plan file (phase-status checkboxes and headings), this summary file, this task's
  own `progress/*.json` files, and `.return-meta.json`. Two sibling tasks (650, 703) are visibly
  active on the shared working tree this cycle (`typst/chapters/ax-lean-appendix.typ`,
  `specs/650_.../` , `specs/703_.../`), and none of their files appear in this task's own commit
  history. `specs/state.json`, `specs/TODO.md`, and `specs/events.jsonl` are modified in the
  working tree by sibling activity and by this session's own orchestrator-level bookkeeping
  (task-lock heartbeats, phase-status writes elsewhere in the cycle), not by any commit this
  implementation phase made — this phase never staged those three shared files.

## What Changed

- `specs/701_port_substrate_lessons_to_model_checker/summaries/01_substrate-lessons-for-model-checker-summary.md` — created; the sole deliverable, containing the verification snapshot, three ready-to-file ModelChecker task texts (a task 200 replacement, a task 219 reopen-and-amend, and one new documentation task), two recorded non-task decisions with a dependency-status table, and the phased now-versus-later proposal.
- `specs/701_port_substrate_lessons_to_model_checker/plans/01_substrate-lessons-for-model-checker.md` — phase headings advanced to `[COMPLETED]` and all per-phase checklist items checked off with completion annotations, as work progressed.
- `specs/701_port_substrate_lessons_to_model_checker/progress/phase-{1..5}-progress.json` — created; per-phase objective tracking.
- No file under `/home/benjamin/Projects/ModelChecker` and no BimodalLogic file outside this task's own `specs/701_port_substrate_lessons_to_model_checker/` directory was modified.

## Decisions

- Treated BimodalLogic task 696 as `completed` throughout (re-confirmed twice: once in Phase 1's snapshot, once again in Phase 5's reconciliation pass), superseding both the original dispatch framing and ModelChecker task 200's still-`implementing` framing.
- Found a third defect in ModelChecker task 219's THEORY-LIMITS group beyond the research report's two (omission, framing): three dangling Lean citations, confirmed absent as declarations and replaced with the theorems that actually stand in their place.
- Scoped the `trans*` wire fields and the cross-repository staleness-detection pattern as explicitly recorded non-task decisions rather than filed tasks, each with a stated reason, per the plan's Phase 4 instructions.
- Did not run ModelChecker's own solver against the new `TL_CM_3`/`TL_CM_4` probe entries — doing so was outside this task's read-only repository boundary — and said so explicitly in the ready-to-file text, leaving the timing measurement as an explicit task for whoever files and applies the amendment.
- Cited the research report inside every ready-to-file block by title and date only, never by this task's own number, consistent with `no-task-references-in-deliverables.md`'s deliverable-boundary rule; caught and corrected two instances where a task-number reference had leaked into a fenced block during drafting.

## Plan Deviations

- None (implementation followed plan). One phase task (Phase 3's dangling-citation count) explicitly predicted three defects via its own Scope Hypothesis, matching what was found; no count needed adjustment. One status word (BimodalLogic task 703's) drifted twice during the task's own lifetime (researching -> planning -> implementing) and was updated at each write point to the current word rather than treated as a deviation, per the plan's own Phase 1/Phase 5 re-verification instructions.

## Verification

- Build: N/A (documentation/text deliverable, no compiled artifact).
- Tests: N/A (no test suite applies to a summary deliverable); `bash .claude/scripts/validate-artifact.sh <summary> summary` run twice — first run found 5 missing required sections, corrected, second run passes clean (0 errors, 0 warnings).
- Files verified: Yes — every Lean identifier (13 checked) and every ModelChecker file path (9 checked) cited anywhere in the summary was re-confirmed present in the live trees in Phase 5's closing pass, after having already been individually verified at each phase that introduced it.

## Impacts

- Whoever next works in ModelChecker's task system has ready-to-paste, verified replacement text for two already-stale task artifacts (200, 219) and one new task description, removing the need to re-derive the Q1/Q2 file-level porting map or re-diagnose the three dangling citations.
- The THEORY-LIMITS group's incorrect "the certificate class is EMPTY" framing, if left uncorrected, would have continued to mislead any future reader of `examples.py` into believing a repaired defect was still open; this task's amendment text corrects that framing precisely, without overclaiming that the general (non-atomic) case is resolved.
- No BimodalLogic or ModelChecker source, build, or test state was changed by this task; all downstream impact is contingent on someone in the ModelChecker repository choosing to file and apply the texts above.

## Follow-ups

- File the task 200 replacement description and the task 219 reopen-and-amend in ModelChecker's own task system (recommended promptly, per the phased proposal, to stop the stale framing from propagating further).
- File the new `docs/ADEQUACY.md` Lemma 2 restatement task in ModelChecker (documentation-only, no dependency, startable immediately).
- When BimodalLogic's `lplus_compression_and_completeness` project completes, re-check whether task 200's blocker text needs a further update before its search-code phase begins.
- When `TL_CM_3`/`TL_CM_4` are actually filed and run against ModelChecker's solver, replace the timing placeholders in this summary's ready-to-file text with the measured values before landing.

## References

- `specs/701_port_substrate_lessons_to_model_checker/reports/01_substrate-lessons-for-model-checker.md` — the research report this implementation phase transcribes and re-verifies.
- `specs/701_port_substrate_lessons_to_model_checker/plans/01_substrate-lessons-for-model-checker.md` — the implementation plan this phase executed.
- `/home/benjamin/Projects/BimodalLogic/FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Skeleton.lean`, `.../PlusWitnessFamily/{Examples,Incompleteness}.lean` — the landed BimodalLogic redesign this summary's ready-to-file text cites.
- `/home/benjamin/Projects/ModelChecker/code/src/model_checker/theory_lib/bimodal/{examples.py,operators.py,docs/ADEQUACY.md,semantic/certificate.py}` — the ModelChecker files this summary's ready-to-file text targets.
