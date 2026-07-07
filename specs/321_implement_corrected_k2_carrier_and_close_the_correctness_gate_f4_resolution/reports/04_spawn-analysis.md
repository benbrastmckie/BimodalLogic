# Blocker Analysis: Task #321

**Parent Task**: #321 - Implement corrected k=2 carrier and close the correctness gate (F4 resolution)
**Generated**: 2026-07-07
**Blocker**: Phase 10 (Stage C soundness closure) is structurally blocked. The landed soundness
consumer `kvE_subBracket2V_sound_of_parts` (`NfMultiAnchorBridge.lean:7449`) requires a bundle
`(x1, hxx1, hx1t, hanchor, hbelow)`; the flat-spliced `fChainPred` joint channel can recover every
component except the upper bound `hx1t : x1 < t`, because `fChainFrom_base`/`_step`
(`EANegation.lean:585`/`:622`) assert `∃ s > x` with no upper bound.

**This analysis packages the authoritative divergence audit** already completed at
`specs/321_implement_corrected_k2_carrier_and_close_the_correctness_gate_f4_resolution/reports/03_divergence-audit-joint-channel.md`
(verdict: ESCALATE). That report performed the full H3/H4/H5 analysis (5-column lemma mapping,
adversarial self-verification, four-attempt divergence table, literature cross-check against
Rabinovich 2014). This document does not re-derive any of that; it re-states the verdict and
converts it into a single well-formed spawned-task definition per the `/spawn` contract.

## Root Cause

Root cause category: **Design ambiguity resolved to a structural (type-level) gap**, not a
missing-prerequisite or scope-creep issue. Per report 03 Determination 1-2:

- The outer carrier `kvE2_body : VVecEA2` is a disjunction of flat `VecEA2 n` brackets
  (`bracketFromLists`, `NfMultiAnchorBridge.lean:8244`) whose witness slots are
  `List TemporalPred` — single-point-evaluated formulas. `k1v_bracket_extract` (`:2150`) can only
  decompose such a bracket into single-point realizations (`∃u, p.eval_at u`), never into a nested
  `.holds`. This makes "Option 1" (carry a genuine sub-`.holds` in the outer witness list) **type-
  level impossible** — report 03 Determination 1, High confidence.
- "Option 2" (a standalone reverse `fChainPred → bracket` lemma under a different convention) is
  **also not viable alone**: the model-independent form is exactly the Cor 5.4 biconditional ruled
  unprovable at `EANegation.lean:1217-1249` (report 18 section 10.3); a model-dependent unfold can
  recover the anchor, `x < x1`, and `hbelow`, but the underlying `fChainFrom` chain is strictly
  upward and unbounded above, so it can **never** supply `x1 < t` — report 03 Determination 1-2 and
  H4 adversarial verification table, High confidence.
- The residual is isolated to **one irreducible datum**: `hx1t : x1 < t` at
  `kvE_subBracket2V_sound_of_parts` (`:7456`), used immediately at `:7482` to derive `x1 < w`.
  Bounding an interior temporal witness from above is a structural bracket operation (Rabinovich
  Lemma 5.1 shared-endpoint point-insertion split, `A_i⁻(z0,z) ∧ A_i⁺(z,z1)`, md:169-171) — not
  something a flat single-point formula slot can assert. This is the identical wall hit by tasks
  320 (b1/b2/b3 probes), 324 (superseded), and 325 (delivered the matched sub-`.holds` kit but left
  outer wiring out of scope) — report 03's H5 divergence table, four independent attempts.

Task 321 cannot resolve this in place: the fix requires a genuinely new lemma establishing
boundedness structurally (point-insertion composition), which report 03 scopes as a single
prerequisite deliverable.

## Proposed New Tasks

### New Task 1: Bounded point-insertion composition lemma for the k=2 sub-witness (supply `x1 < t` at the outer→sub wiring)

- **Effort**: 6-12 hours
- **Task Type**: lean4
- **Rationale**: This is the sole prerequisite identified by the divergence audit (report 03,
  Determination 3). It supplies the missing `hx1t : x1 < t` hypothesis — the one datum that
  `kvE_subBracket2V_sound_of_parts` needs and that the current flat-spliced `fChainPred` channel
  structurally cannot deliver — via a literature-grounded (Rabinovich Lemma 5.1) point-insertion
  composition rather than any flattening relapse.
- **Depends on**: None

## Dependency Reasoning

- **Task 1 has no dependencies**: it is a single, self-contained additive lemma consuming already-
  landed assets (`kvE_subBracket2V_sound_of_parts`, `neg_2var_vec_ea`/`neg_interval_formula`,
  `kvE2_joint_nonvacuous_at_honest`). No other new task is required to unblock it, and the audit's
  verdict is explicit that ONE prerequisite task suffices — a second task would only be warranted
  if the audit had identified a further independent gap, which it did not (Option 2 standalone was
  explicitly folded into this single escalation route rather than spun out separately).

## After Completion

Once the spawned task lands the bounded composition lemma, resume the parent task #321 by running
`/revise 321` to produce a v5 plan that re-points Phase 10 at the new lemma, feeding the already-
landed `kvE_subBracket2V_sound_of_parts`. Do NOT run `/implement 321` directly on the existing v4
plan — Phase 10 in v4 is the blocked step.

The blocker will be resolved because: the new lemma structurally derives `x1 < t` via the
Rabinovich Lemma 5.1 shared-endpoint composition (not from the unbounded `fChainFrom` chain),
completing the exact `(x1, hxx1, hx1t, hanchor, hbelow)` bundle `kvE_subBracket2V_sound_of_parts`
requires. Per report 03, Phases 12-14 (completeness, already closing via
`kvE_subBracket2V_complete`) remain unaffected **provided** the v5 revision does not alter the
`kvE_subChain2V` splice shape — the new lemma must consume the existing flat splice's extract
output, not require a new joint-channel shape.
