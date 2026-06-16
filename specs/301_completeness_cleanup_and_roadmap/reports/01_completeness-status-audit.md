# Completeness Status Audit & Cleanup Plan

## Summary

Task 273 (BracketFormula k encoding fix) closed all k=0 KampBypass sorries across
Until, Since, and Eq directions (~1400 lines of sorry-free proofs). An import audit
reveals the completeness picture is simpler than previously understood: only ONE sorry
blocks `completeness_discrete`, and several tasks are now obsolete.

## Current Sorry Status of `completeness_discrete`

**Sole real blocker**: `existPart_succ_n1_bypass` k>0 (KampBypass.lean:4486)

Call chain:
```
completeness_discrete
  → countermodel_discrete_reynolds_v2
    → limitdom_is_good
      → no_gaps_discrete_model_surgery
        → US_expressively_complete_over_prior
          → kamp_prior_expressive_completeness
            → existPart_succ_n1_bypass (k>0 sorry)
```

**Dead code sorry**: `chronicle_gap_contradiction` (ChronicleToCountermodel.lean:537)
appears in `#print axioms` only because `Completeness.lean` imports
`ChronicleToCountermodel.lean` for `mcs_mixed_case_absurd` (which is itself sorry-free).
It is NOT on the live call path. Moving `mcs_mixed_case_absurd` to a different file would
eliminate this phantom dependency.

## Literature Alignment

The codebase follows **Reynolds 1994** for the discrete completeness architecture:

| Layer | Source | File | Status |
|-------|--------|------|--------|
| 1. Expressive completeness | Rabinovich 2014 / GHR94 Ch.10 | KampBypass.lean, KampPrior.lean | **1 sorry** (k>0) |
| 2. Model surgery | Reynolds 1994 §7 | GoodStructuresModelSurgery.lean | **Sorry-free** (2167 lines) |
| 3. Integer model transfer | Reynolds 1994 §8 | ReynoldsBridge.lean | **Sorry-free** |

The BX Chronicle path (ChronicleToCountermodel.lean) is an alternative construction NOT
used by the live `completeness_discrete` path. It was the original approach but has been
superseded by the WeakCanonical/Reynolds pipeline.

## k>0 Sorry Analysis

In Rabinovich 2014, the k>0 case is handled by Proposition 4.2 / Lemma 5.1 — closure of
V-exists-forall formulas under negation via structural induction on witness count n. The
key step: when negating an exists-forall formula with n witnesses, each insertion point
creates sub-interval negation problems with fewer witnesses.

The formalization's BracketFormula encoding creates an explicit depth parameter k that
requires its own induction, whereas the literature handles all depths uniformly via
formula-structure induction. The k=0 infrastructure (complete and sorry-free) provides
the template. Estimated effort: ~200-400 lines.

## Task Triage

### Tasks to Abandon

| Task | Name | Status | Reason |
|------|------|--------|--------|
| **155** | reynolds_pipeline_activation | [IMPLEMENTING] | Mega-task with 67 plan versions. Scope fully carved into 273 (completed) + new k>0 task. No longer actionable as a unit. |
| **268** | reynolds_pipeline_bridge | [RESEARCHED] | Proposed bypassing chronicle_gap_contradiction. Audit shows this sorry is dead code — no bypass needed. |
| **200** | ghr93_case_ii_elegance_rewrite | [NOT STARTED] | Cosmetic rewrite of a path that works. Low priority, not on critical path. |
| **254** | update_stale_metadata_post_202 | [NOT STARTED] | Metadata cleanup subsumed by this cleanup task. |
| **176** | relocate_chronicle_and_archive_dead_bxcanonical | [NOT STARTED] | Partially subsumed by this task's Boneyard archival scope. |

### Tasks to Revise

| Task | Name | Current | Revision |
|------|------|---------|----------|
| **95** | completeness_verification_audit | Depends on 155 | Update dependency to depend on new k>0 task instead |
| **299** | refactor_discrete_game_transfer | Depends on chain being sorry-free | Keep, but update dependency |

### New Tasks to Create

| Task | Description | Priority | Estimated Effort |
|------|-------------|----------|-----------------|
| **Import refactor** | Move `mcs_mixed_case_absurd` out of ChronicleToCountermodel.lean to eliminate phantom sorry dependency | Quick win | ~30 min |
| **k>0 depth induction** | Close `existPart_succ_n1_bypass` k>0 via Rabinovich §5 Lemma 5.1 interval-splitting induction | **Critical** — sole blocker for completeness_discrete | ~200-400 lines |

## Repository Cleanup Scope

### Dead Code → Boneyard/

1. **BXCanonical path** (if not already archived): `Theories/Bimodal/Metalogic/BXCanonical/` —
   17 sorries that are mathematically false under irreflexive semantics (per ROADMAP.md)
2. **ChronicleToCountermodel.lean** portions: `chronicle_gap_contradiction`, `succ_cofinal`,
   `limitDomSubtype_isSuccArchimedean`, `succ_embed_surjective` — all dead code for the
   discrete case. Keep `mcs_mixed_case_absurd` (move to appropriate file first).
3. **VecEADecomposition.lean sorries**: Confirmed quarantined as dead code by task 273 research.
4. **Stavi path** (`StaviCompleteness.lean`): The live path now uses Kamp/Rabinovich, not
   Stavi/GHR93 EF games. The Stavi path has its own sorry chain. Candidate for Boneyard.

### File Factoring

- **KampBypass.lean** (4488 lines): Oversized. Factor into:
  - `KampBypassUntil.lean` — Until direction proofs
  - `KampBypassSince.lean` — Since direction proofs  
  - `KampBypassCore.lean` — Shared infrastructure, eq case, main theorem

### ROADMAP.md Updates Needed

The current ROADMAP.md (last substantive update ~2026-05-29) is significantly outdated:
- States "Two independent sorry chains must both be closed" — audit shows only ONE chain matters
- Critical path description references tasks 273 → 202, but 273 is now complete and 202 is obsolete
- Does not reflect the finding that `chronicle_gap_contradiction` is dead code
- `succ_cofinal` discussion takes up most of the ROADMAP but is now irrelevant
- Should reflect: sole blocker = k>0 existPart_succ_n1_bypass, ~200-400 lines from done

## Priority Order

1. **This task (301)**: Cleanup, archival, task triage, ROADMAP update
2. **Import refactor**: Move `mcs_mixed_case_absurd`, clean phantom dependency
3. **k>0 depth induction**: The one remaining sorry — close it
4. **Task 95**: Verification audit to confirm completeness_discrete is sorry-free
5. **Task 299**: Refactor DiscreteGameTransfer once chain is clean
