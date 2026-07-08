# Implementation Summary: Joint Slot-Level Sorted Realization (task 334)

- **Status**: PARTIAL — Phase 1 complete; Phase 2 (crux) BLOCKED; Phases 3-7 not started.
- **Session**: sess_1783529677_8c950d
- **Build**: GREEN — `lake build …SharedWitness` exit 0.
- **File touched**: `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness.lean` (only).

## What landed (green + committed)

1. **Phase 1 — arrangement-aware filter switch** (`kvE2_sepSlotLe` now the `if sub=sub then rank
   else kvE2_sepCompat` form). Applied the `phase1-switch-and-repairs.patch` mechanical renames by
   hand on HEAD: `kvE2_sepSlotLe_of_rank → _same` (+`hsub`), `_of_sub_ne → _of_ne_compat` (+`hc`),
   added `kvE2_sep_pairwise_rank_same`, split `kvE2_sepSlotsL/RFor_pairwise` into `_rankPairwise` +
   thin wrapper, fixed the `kvE2_sep_index_lt_of_rank_lt` `rw`. The two now-false identity-arrangement
   lemmas `kvE2_sepSlotsL_valid`/`_valid` carry CLEARLY-LABELED scaffold sorries (2, not 3 — see
   Deviations).
2. **Phase 2 — reduced crux lemma** `kvE2_sepFreshAnchor_ne_baseChiPoint` (sorry-free, axiom-clean
   `[propext, Classical.choice, Quot.sound]`): `p ≠ x1_σ` FROM `χ ≠ nf0_projFresh σ.1`, via
   `nf_eval_nf0_cons_factor` (extracts `x1_σ`'s own base type) + `nf_eval_unique`. This is the honest
   distinctness engine; the UNCONDITIONAL form the joint sort needs is not provable (see blocker).

## What is BLOCKED (Phase 2 crux — make-or-break)

The joint mergeSort-by-`pt` construction requires an UNCONDITIONAL `p ≠ x1_σ` at the fresh-anchor
boundary. This reduces exactly to the base-vs-base inequality `χ ≠ nf0_projFresh σ.1`, which is NOT
dischargeable for arbitrary cross-owner base types: distinct positive owners may carry the same base
type, and a foreign owner's χ-witness may coincide exactly with another owner's fresh anchor `x1_σ`.
In that coincidence the arrangement is genuinely INVALID — `x1_σ` lies in NEITHER of σ's open zones
`(x,x1_σ)`/`(x1_σ,w)`, so neither Case-A nor Case-B compat can be discharged via the fold ⇐ (which
requires STRICT open-interval membership). No fresh-vs-base type-separation lemma exists in
`WeakCanonical/`, and the research's "E[Σ]-atom incompatible with a base type at a point" intuition
is UNSOUND (`charK = existF` is existential — a point may satisfy both). Full detail in the plan's
Phase-2 **BLOCKER** note and `handoffs/02_phase2-crux-blocker.md`.

## Sorry inventory (honest)

| line | declaration | kind |
|------|-------------|------|
| ~897 | `kvE2_sepSlotsL_valid` | Phase-1 scaffold (false post-switch; removed by Phase 6) |
| ~904 | `kvE2_sepSlotsR_valid` | Phase-1 scaffold (false post-switch; removed by Phase 6) |
| ~2058 | `kvE2_sepSingleton_coverage_left` | pre-existing strategic (task-333 Phase 4) |
| ~2190 | `kvE2_sepBody_singleton_complete_left` | pre-existing strategic (task-333 Phase 5) |

0 vacuous defs. 0 new axioms. NOTE: `kvE2_sepBody_nonvacuous` now transitively depends on the 2
scaffold sorries (the plan's intended Phase-1 intermediate state) — it was axiom/sorry-clean at
baseline and is restored to clean only by completing Phases 4-6, which the crux blocks.

## Plan Deviations

- **Phase 1**: 2 scaffold sorries instead of 3 — `kvE2_sepBody_nonvacuous` compiles unchanged by
  referencing the two sorried `_valid` lemmas, so no third scaffold sorry is needed.
- **Phase 2**: the planned "E[Σ]-atom vs nf0-base semantic separation" was DISPROVED as unsound; the
  correct route is a base-vs-base reduction. The reduced lemma landed sorry-free; the unconditional
  lemma is unprovable, triggering escalation.

## Recommended next action

Escalate: spawn a research sub-task on the fresh-anchor / base-χ coincidence (candidate directions in
the plan blocker). Do NOT proceed to Phases 3-7 or weaken the filter to vacuity. Optionally revert the
Phase-1 switch to restore `kvE2_sepBody_nonvacuous` to sorry-free if a clean baseline is preferred
while the crux is researched.
