# Blocker Analysis: Task #324

**Parent Task**: #324 - redesign_k2_subbracket_arity4_correctness_pair
**Generated**: 2026-07-07
**Blocker**: The completeness converse of `kvE_subBracket2_sound` is machine-refuted (false `∀ M`
statement) over the current single-`BracketFormula` carrier. Report 02 (adversarial-verified)
establishes that only a redesign to a `VVecEA2` arrangement-disjunction carrier with three
per-region segment types (`segXU`/`segUW`/`segWT`) can support completeness, and that this
redesign — plus re-derivation of the full sound/complete pair — is its own task (4-5 one-dispatch
phases), not a Phase-6 continuation.

## Root Cause

Task 324's Phases 1-5 landed (commit `f77478f1c`, byte-identical, sorry-free, axiom-clean):
`kvE_subBracket2`/`kvE_subChain2` over codomain `Σ m, BracketFormula (m+1)` (NfMultiAnchorBridge.lean
:6120), the zone/reachability kit (:6200-6491), `kvE_subBracket2_sound` (:6530), and the
completeness *extraction* kit `kvE_subBracket2_complete_extract` (:6683).

Phase 6 (the completeness converse) was blocked and the blocker was independently
adversarially re-verified in report 02 (`reports/02_phase6-blocker-research.md`), which is the
authoritative, machine-grounded source for this analysis. Two independent, machine-confirmed
obstructions make the converse unprovable over the current carrier:

1. **Obstruction 1 — constant tri-zone `segExcl` segment type.** `IntervalPattern.holds`
   (ExistsForallNF.lean:106-132) requires each segment type to hold at *every* point of its open
   segment. `kvE_subBracket2.segmentTypes := fun _ => segExcl` (:6159) demands every interior
   point be fold-bit-positive in *all three* zones simultaneously. The completeness antecedent's
   depth-1 fold (`nf_eval_depth1_fold_iff` :5187, driven at :6683-6719) forces only
   zone-membership ↔ fold-bit for a point's *own* zone — never cross-zone positivity. An interior
   point realized only in `zXU` (e.g. in a dense model) survives the antecedent yet falsifies
   `segExcl`. This makes the converse a **false ∀-M statement**; a concrete Dedekind-complete-chain
   counterexample class is recorded in report 02 §Q1.
2. **Obstruction 2 — fixed filter-order `pointTypes`.** `kvE_subBracket2.pointTypes` is built from
   `Finset.univ.toList`-ordered `leftSlots`/`rightSlots` (:6139-6158), a fixed syntactic order.
   `IntervalPattern.holds` needs strictly-monotone witnesses positionally matching that fixed
   order (:117/:121); the model's realization order need not match it. Independently fatal.

Report 02 (Q2) additionally shows no rescue is available on the current carrier: the codomain
itself (`Σ m, BracketFormula (m+1)`, a single `IntervalPattern`) is structurally the wrong shape —
completeness for the landed k1v template (`bracketEndChar_k1v_complete` :2979) is provable
*only because* that carrier is a `VVecEA2` finite disjunction over arrangement permutations with
**per-side** segment types (`bracketFromLists.segmentTypes`, :1902), letting completeness (a)
select the model-sorted arrangement disjunct and (b) discharge each side's segment type because
every point of that side is genuinely zone-positive there. Neither device exists on
`kvE_subBracket2`. A gate-hypothesis rescue was also considered and rejected: since `.holds` is
the *conclusion* in completeness (unlike soundness, where it is the hypothesis), any hypothesis
strong enough to make it provable would itself assert the monotone-positional + per-segment
conditions — i.e. it would *be* the conclusion, trivializing the deliverable.

**Category**: Technical unknowns / design defect discovered only when the reverse (completeness)
direction was actually driven through — the same "type-checked-clean, semantically-gapped"
pattern that caused the original `kvE_subBracket` (task 321 Phase 8) blocker one level down. This
is a Phase-1 codomain design decision (per the binding constraint distinguishing blocker reports
from live edits), not something fixable within Phase 6.

## Proposed New Tasks

### New Task 1: Redesign k=2 sub-bracket to VVecEA2 arrangement-disjunction carrier with full soundness/completeness pair
- **Effort**: high (10-16 hours; realistic decomposition per report 02 is 4-5 one-dispatch phases)
- **Task Type**: lean4
- **Rationale**: This is the only task needed. Report 02's own Resolution Path (§"Resolution
  Path", step 2) specifies spawning exactly one redesign task carrying forward the corrected
  target definition (Q3), the preserved-asset accounting table, and Guards G1-G6 + Corrected
  Anchor-Cap + Amendment F3 verbatim. The redesign (carrier codomain change) and the correctness
  pair re-derivation (soundness must be re-derived because the landed `kvE_subBracket2_sound`
  binds the old single-bracket carrier; completeness is new) are tightly coupled — the carrier's
  shape *is* what the correctness pair proves properties of — so splitting construction from
  correctness would require the second task to consume an unvalidated carrier, repeating exactly
  the "type-check-then-discover-gap" failure this analysis is trying to prevent. One task, staged
  internally into phases (as task 324 itself was), is the minimal decomposition.
- **Depends on**: None (standalone against `nf_eval_nf M 1 4`, not wired into the outer gate;
  parent task 321 resumes via `/revise 321` only after this task completes)

## Dependency Reasoning

- **Single-task deliverable, no internal dependency graph**: There is only one new task. It is
  intentionally *not* split into "redesign carrier" + "prove correctness pair" sub-tasks because
  the report 02 postmortem (shared by both the original `kvE_subBracket` defect at task 321 and
  the `kvE_subBracket2` defect at task 324) is precisely that carrier constructions accepted on
  type-check/probe grounds *before* the correctness proof is driven through them have twice now
  concealed a fatal semantic gap. A second consuming task would inherit an unvalidated carrier
  with no mechanism to force proof-driven validation before consumption. Keeping construction and
  the full pair (soundness + completeness) in one task with one continuous dispatch chain is the
  structural fix for the two-strikes pattern, not merely a scoping convenience.
- **Why this is not 2+ independent tasks**: The three region segment types (`segXU`/`segUW`/`segWT`)
  and the two witness slots (`x1`, `w`) are a single interdependent design (report 02 Q3): the
  segment-type-per-region choice is only correct in the context of the specific per-region
  arrangement-disjunct structure, and the disjunct structure is only sized correctly once the
  segment types are fixed. These are not independently completable increments — an implementer
  deciding segment types cannot avoid also deciding the disjunct/arrangement shape they attach to,
  and vice versa. Same logic applies to soundness vs completeness: report 02 states soundness must
  be *re-derived* (not merely reused) because it currently binds the old bracket, so both
  directions are genuinely new proof obligations over the same fresh carrier, best driven by one
  agent holding the full carrier definition in working context.

## After Completion

Once the redesign task is complete, resume the parent task #321 with `/revise 321` (folding the
delivered `VVecEA2` carrier + soundness/completeness pair into a v4 phase decomposition that
re-points Phase 8 and subsequent phases at it), then `/implement 321`.

The blocker will be resolved because: the delivered task supplies a genuinely completeness-capable
carrier (arrangement disjunction over three per-region segment types, mirroring the proven-correct
k1v template one arity up) together with a freshly re-derived, machine-driven-through
soundness/completeness pair standalone against `nf_eval_nf M 1 4`. Task 321's Phase 8 (and its
downstream phases) can then consume this validated construction instead of the structurally
incomplete `kvE_subBracket2`, removing the root cause rather than patching around it.
