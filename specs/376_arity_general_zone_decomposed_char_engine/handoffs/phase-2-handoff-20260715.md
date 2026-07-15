# Phase 2 Handoff — PARTIAL / BLOCKED (split-seam re-plan needed)

**Session**: sess_1784138518_4af6d5 · **Date**: 2026-07-15

## Immediate Next Action

Re-plan Phase 2 as a **split-seam** design (guard the soundness seam Block B only; leave the
completeness seam Block A UNGUARDED), OR first dispatch a bounded Phase-1-style probe certifying an
unguarded Block A `↔` is refutation-safe on the completeness side. Then re-implement `step_sound`
(Block B) + `bracketEndChar_kvExtFib_correct_prior` + `kampPrior_site_rungKFib_gate_match`
(binder-only forwards). The `realize_{futT,pastX}` + `kampPrior_hreal_supply` zone-guarding is
already landed and is consistent with either design.

## Current State

- Phase 1: COMPLETED (CLEARED).
- Phase 2: BLOCKED, with one green milestone landed (commit `3b75fc880`).
- Build: green. KampPrior census: 2 sorries (:519/:522), unchanged. Frozen diff: empty.
- Working tree: only specs artifacts uncommitted at handoff time (all .lean work is committed).

## What Landed (commit 3b75fc880)

`bracketEndChar_kvFib_realize_futT` / `_pastX` (IGGK) and `kampPrior_hreal_supply`
(InteriorHrealSupplyK) re-signed to the zone-guarded render-free soundness seam (Block B/C).
Guards supplied via the compiled probe proof + public `ext3_zoneHolds_cons_iff`.

## The Blocker (root cause, not a tactic failure)

`bracketEndChar_kvFib_step_complete`'s completeness proof discharges the FROZEN carrier's 7
segment/endpoint EXCLUSION obligations (IGGK:1932,1946,1968,1984,2009,2022,2046) by applying the
char seam's `charFib σ → nf_eval σ` direction to arbitrary (bit-false, possibly UNMARKED) σ.
Block A's `qnf.2 σ = true` mark guard removes that direction; the mark is genuinely unavailable in
a bit-false branch. That `⟹` direction IS the unguarded soundness transport the report §Q2.3 /
`seamPair_joint_refutation` refuted — so the guarded re-sign correctly breaks an exclusion proof
that relied on the refuted claim. The carrier `igSeg*` predicate (demanding `¬charFib σ` for every
bit-false σ) is frozen and out of Phase-2 scope.

## Key Decisions

- Kept the tree at the committed green milestone (reverted the experimental guarded `step_complete`
  binder rather than leave a red tree or introduce sorries — the plan's "no new sorries anywhere"
  constraint forbids a skeleton here).
- Escalated the seam-guarding scope as a plan-level decision (per `plan-compliance.md`: a `.lean`
  deviation must be raised as a blocker, not silently substituted) rather than unilaterally
  adopting the split-seam.

## Sorry Inventory

Unchanged from Phase 1: KampPrior.lean :519 and :522 (both strategic, pre-existing, follow-up
task 376 phases 5/8). No new sorry introduced.

## Do NOT

- Do NOT weaken any guard to force `step_complete` through (Phase-2 constraint).
- Do NOT edit the frozen carrier / `igSeg*` / defeq bridges to route the exclusion.
- Do NOT restate the completeness seam guarded before a probe certifies unguarded Block A is safe.
