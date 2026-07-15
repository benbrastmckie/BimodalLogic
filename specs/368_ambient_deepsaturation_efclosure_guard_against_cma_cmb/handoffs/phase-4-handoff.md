# Task 368 — Phase 4 Handoff (Adversarial re-plant probes, ambient side)

**Status**: COMPLETED (Gate 4a fired — candidate survives; ZERO redesign loops).
**Commit**: `c304fd2e5`. **Build**: green (1025 jobs). **Axioms**: floor `[propext, Classical.choice, Quot.sound]`, no sorryAx.

## Immediate Next Action

Phase 5 (production landing — the single production-touching phase). Snapshot first
(`bash .claude/scripts/git-snapshot.sh`), then promote the fully-adjudicated guard
`kvE_ambientDeepAnchorV0` verbatim into a NEW additive module `ExteriorAmbientDeepAnchorK.lean`
and restate rows 5/6/10-13 per the Phase-1 consumption-site map.

## Current State

Phase 4/6 complete, probe-only. The candidate ambient EF-closure guard is now fully adjudicated:
gates 2a/2b/2c (CM-A/CM-B rejected, m=0 inert), 3a/3b (honest preservation `_of_realized`,
supply route), and NEW gate 4a (depth-2 hereditary survivor + copy-plant collapse). Sorry count 0,
new axioms 0, production files touched 0.

## Key Decisions (Phase 4)

- **Depth-2 hereditary doppelganger** built as the m=2 depth-lift of the CM-A homogeneous
  deep-incomplete ambient (`q2A : NormalForm mAsig 4 3`, marks `{c2A(-1..3)}`, omits `c2A 4`).
  367's `[40,9,8,11]` discrete gap is realized as the empty ℤ interval `2 < r < v ≤ 3`
  (`c2A_gap_false`), now read off a depth-2 characteristic — the guard's heredity fires one fiber
  layer deeper. Homogeneous bucket collapse yields depth-0 AND depth-1 indistinguishability
  (strictly stronger than 367's matched zone-presence). Proof is a verbatim +1-depth replica of
  gate 2a — the `nf_eval_nf` `.1` atom-row accessor and `.2` characteristic marking are
  depth-uniform.
- **Copy-plant self-defeat** split into two certificates. The guard reads ONLY `qnf.2`, so a
  marking-copy PASSES it (`..._passes_guard`, reduces to gate 3a) — the guard alone cannot exclude
  the copy. The on-row anchoring clause pins `qs.1 = qnfBreal.1` (`..._collapses`, via
  `nf_eval_nf0_cons_factor`/`nf_eval_unique` — no guard unfolding), collapsing the fake to the
  honest ambient. Ambient analog of `kvE_probe367_copyPlant_collapses`.
- Prior-family cross-check and homogeneous/(ℚ,<) analytical-family closure recorded in the leaf
  docstring (Deliverables 3 and 4).

## Sorry Inventory

Empty (no sorries anywhere in the probe leaf).
