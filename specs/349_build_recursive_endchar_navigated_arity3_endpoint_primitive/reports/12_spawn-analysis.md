# Blocker Analysis: Task #349

**Parent Task**: #349 - Build the recursive navigated arity-3 endpoint primitive `endChar`
**Generated**: 2026-07-13
**Blocker**: Plan v8 Phases 3-4 (the depth-k EXTERIOR bracket layer, D1-D4) are complete, green,
sorry-free, axiom-clean, and committed. Phases 5-7 (`endIntervalStep` body, step correctness,
recursion close) cannot proceed because the depth-k **INTERIOR gate correctness** —
`bracketEndChar_kv_correct` generalized to arbitrary `k` — is undelivered and is not a byproduct
of any completed or in-flight task.

## Root Cause

Task 349 plan v8 (`plans/08_consume-depthk-clause-layer.md`) Phase 5's RESUME POINT annotation
(line ~444) states the scope gap explicitly: the k=2 template routes interior content through the
interior gate `bracketEndChar_kvE2` (`OuterGate.lean:70`), whose correctness halves —
`bracketEndChar_kvE2_sound_two_prior_frag` (`OuterGate.lean:268`) and
`bracketEndChar_kvE2_complete_two_prior` (`OuterGate.lean:147`) — are hardwired to depth-1 subs
via `nf_depth0_char_formula`. The depth-k generalization of the carrier itself,
`bracketEndChar_kv` (`CarrierKv.lean:238`), already exists, but its correctness lemma
`bracketEndChar_kv_correct` is delivered only at the k=0 and k=1 rungs:
`bracketEndChar_kv_correct_zero` (`CarrierKv.lean:367`) and `bracketEndChar_kv_correct_one`
(`CarrierKv.lean:395`, mirroring the fixed-endpoint k=1 instance
`bracketEndChar_k1v_correct` at `CarrierK1V.lean:2041`). `CarrierKv.lean:22`'s own docstring
records this directly: "Correctness (`bracketEndChar_kv_correct`) is Phase 13 (R3b) and is NOT
attempted here."

This is a **root-cause category: Technical unknowns / undelivered open construction** — not a
missing prerequisite that some other in-flight task will supply. Verified by grep: no declaration
or stub named `bracketEndChar_kv_correct` (general-k) exists anywhere in
`NfMultiAnchorBridge/`, and the three recently-completed spawns (351 exterior determinacy core,
352 exterior negation clause layer, 354 nested re-anchoring converter) all target the *exterior*
clause/bracket layer that Phases 3-4 already consumed — none of them touch the *interior* gate.
The `endIntervalStep` hole at `CarrierK1V.lean:2144` is confirmed still the sanctioned `⟨[]⟩`
empty-disjunction placeholder (never faked), and the estimate in the plan's RESUME POINT
(~700-1300 new proof lines across Phases 5-7) confirms this is substantial, self-contained
recursive-Kamp construction work rather than a mechanical consumption step — exactly the profile
that should be spawned as its own task rather than absorbed into 349's own Phase 5 dispatch.

## Proposed New Tasks

### New Task 1: Build depth-k interior gate correctness (bracketEndChar_kv_correct, general k)

- **Effort**: high
- **Task Type**: lean4
- **Rationale**: This is the single undelivered piece blocking task 349 Phases 5-7. Task 349's
  `endIntervalStep` body (Phase 5) needs to source interior content at general depth k; without
  `bracketEndChar_kv_correct` (or an equivalently-named general-k interior gate correctness lemma)
  proved for arbitrary k, Phase 5 cannot supply a real (non-placeholder) step body, and Phases 6-7
  (step correctness, recursion close) have nothing to induct on. Isolating this as its own task
  matches the established pattern (351/352/354 were spawned for analogous undelivered-construction
  gaps in the exterior layer) and keeps 349's own Phase 5 dispatch a pure consumption step once
  this lemma lands, exactly mirroring how Phases 3-4 consumed 352/354's clause layer.
- **Depends on**: None (self-contained; the exterior bracket layer it will cite as a template is
  already committed and frozen-file-safe).

This is the only new task proposed. The blocker is fully characterized by a single missing lemma;
splitting it further (e.g. separating "state the general-k statement" from "prove it by recursion")
would violate the Task Minimization Principle — the statement and its recursive proof are not
separable into independently-useful deliverables the way the exterior sound/complete split was.

## Dependency Reasoning

No dependency edges are needed: this is a single-task spawn. The new task depends only on
already-committed, frozen artifacts (the k=1 carrier correctness at `CarrierK1V.lean:2041`, the
k=2 interior gate at `OuterGate.lean:70`/`:147`/`:268`, and task 349's own committed Phase 3-4
exterior bracket layer at `ExteriorBracketAssembleK.lean`), all of which it may cite and pattern-
match but must not edit (frozen-file discipline carried verbatim from 349).

The Component 4a file-footprint overlap check is vacuous here (only one new task, no pairwise
comparison possible).

## After Completion

Once the spawned task delivers `bracketEndChar_kv_correct` (general k) green, sorry-free, and
axiom-clean ([propext, Classical.choice, Quot.sound]), resume the parent task #349 with
`/implement 349`.

The blocker will be resolved because: task 349 Phase 5 can then fill the `endIntervalStep` body
(`CarrierK1V.lean:2144`) by citing the new general-k interior gate correctness lemma for the
interior-content half of the step (mirrored against Lemma 7.6 adjacency composition for the
exterior residue, already discharged by the committed D1-D4 bracket layer), and Phases 6-7 can
induct on it to close the step-correctness and recursion-close obligations, rather than being
blocked on an open, undelivered piece of mathematics.
