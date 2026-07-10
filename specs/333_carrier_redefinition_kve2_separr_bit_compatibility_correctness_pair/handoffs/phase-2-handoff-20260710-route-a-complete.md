# Task 333 Phase 2 Handoff — Route A COMPLETE (sess_1783679696_817168)

## Immediate Next Action

Dispatch **Phase 3** (per-σ kit application): thread the per-σ bundles produced by the now
hypothesis-free `kvE2_sepBody_extract` through `kvE2_sepBundleL_parts` (SW:5359) /
`kvE2_sepBundleR_parts` (SW:5376) into `kvE_subBracket2V_sound_of_parts`
(SubBracket2V.lean:1290, consume-only). No side-conditions to discharge — carrier membership
alone suffices. Watch item: the right-interior class kit application (MEDIUM risk; if it does
not discharge, add a kit-application lemma in `SharedWitness.lean` — never weaken a filter,
never assume `hgate`).

## Current State

- Phase 1: COMPLETED (`924d76c49`). Phase 2: **COMPLETED** this dispatch
  (`9efe8a8e0` = phase 2.1 green sub-step, `b896cad69` = phase 2 final).
- Landed, all sorry-free + axiom-clean (`[propext, Classical.choice, Quot.sound]`, no
  `sorryAx`, via `lean_verify`):
  - `kvE2_sepTieRuns_classIdx_lt` (public, ~SW:8230) — tie-class index order from strict
    key order; derived from the task-337 `kvE2_sepTieRuns_key_const` (SW:8140) /
    `kvE2_sepTieRuns_key_strictMono` (SW:8178) instead of duplicating the report-04 probe.
  - `kvE2_sep_gidx_lt_of_rank_lt` (private, after SW:4411) — contrapositive of the landed
    `kvE2_sep_rank_le_of_gidx_le`.
  - `kvE2_sepDisjunct'_extract` (public, after classIdx_lt) — the Route-A tie-admitting
    grouped extraction; only hypothesis about the order is `hwo : wo ∈ kvE2_sepArr' qnf`.
  - `kvE2_sepBody_extract` (public, replaced) — **binder list = plan signature (d) exactly:
    (charBase charK qnf M atomMap x t h). ZERO universal side-conditions.** Old
    side-condition version + singleton conversion deleted from the live route; old SW:6520
    site carries a NOTE pointer. `kvE2_sepTieGroupedL/R_of_nodup` and
    `kvE2_sepDisjunct'_map_singleton_iff` retained (completeness still uses them).
- Build: scoped `lake build Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.SharedWitness`
  exit 0 AND full `lake build` exit 0 (1720 jobs, no downstream regression).
- Audits: LITMUS 0 live hits; no new axioms; no vacuous defs; carrier
  (`kvE2_sepArr'`/`kvE2_sepDisjValid`/`kvE2_sepBody`) byte-identical; 6 preserved-asset
  lemmas byte-unchanged; code diff touches only `SharedWitness.lean`.

## Key Decisions

- (a1)/(a2) of the plan were discovered ALREADY LANDED (task 337, identical statements under
  the names `_key_const`/`_key_strictMono`); consumed, not duplicated (plan annotated).
- New (c)/(d) placed after SW:8178 (their dependency `kvE2_sepTieRuns_key_strictMono` sits
  there); "in place" honored interface-wise (same name/file, zero consumers — grep-verified:
  only docstring mentions at SW:2249/2266/4320/4483/4501/7108).
- `hreg` for same-owner pairs discharged by `rfl` (both `.lXU`/`.lX1` region-left true; both
  `.rWX1`/`.rX1` false); ranks 0 < 1 by `Nat.zero_lt_one` — exactly the flat-template reads.

## Sorry Inventory

Empty. No inherited sorries; none introduced. Territory (SharedWitness.lean) live-sorry
count: 0. (Repo-wide census hits are pre-existing in Boneyard/BXCanonical/Expressiveness
etc., untouched by this dispatch.)

## References

- Plan: `plans/06_route-a-grouped-extraction.md` (Phase 2 marked [COMPLETED], deviations
  annotated inline)
- Report 04 §Q1(a-d): signatures transcribed verbatim (modulo the (a1)/(a2) consumption)
- Flat template consumed: `kvE2_sepDisjunct_extract` SW:6359-6448 (untouched)
