# Research Report: Task #93

**Task**: 93 - Close TaskModel embedding sorry (sole remaining active-path sorry)
**Date**: 2026-04-16
**Mode**: Team Research (1 teammate — Teammate A primary approach)

## Summary

This research round focused on studying the last implementation attempt (v18 Phase 1 partial) and all previous reports to identify the mathematically correct long-term approach to the forward_F blocker in RootScopedChain.lean.

**Core conclusion**: The forward_F problem is a genuine mathematical gap in the chain definition. The `.choose` in `set_lindenbaum` is unconstrained and can perpetually select `F(psi)` over `psi` at every visit step. 19 approaches are definitively ruled out; 2 remain viable.

**Immediate recommendation**: Attempt the **fold-order trick** (2-hour cap) — process `target` LAST in the BX11 fold so BX11 Case 3 makes target the direct witness rather than displacing it. This is the only remaining sub-30-LOC intervention and does not require chain replacement.

**Primary fallback**: Modified chain using `discharge_single_step` with **never-resolved count** as the well-founded termination measure (~15-20 hours, ~30 downstream theorem re-proofs).

## Key Findings

### Primary Approach Analysis (from Teammate A)

**The forward_F gap is a construction-level problem, not a proof-strategy failure.** The existing `enriched_fwd_step` guarantees only a disjunction (`target in M' OR F(target) in M'`); BX11 Case 3 can persistently displace the target at every scheduled visit step. The `.choose` in Lindenbaum is non-deterministic in a way that is consistent with perpetually deferring any specific formula.

**Two remaining viable approaches**:

1. **Fold-order trick** (2 hours, 40% confidence): Modify `enriched_fwd_fold_with_witness` so `target` is processed LAST. BX11 Case 3 places the LEFT operand under F and makes the RIGHT operand the direct witness. If target is rightmost, Case 3 makes target the direct witness in all three BX11 cases. The seed `F(beta_accumulated AND target) in M` is consistent by `enriched_resolving_seed_consistent`. This does not change the chain definition and requires no downstream re-proofs.

2. **Modified chain with never-resolved count** (15-20 hours, 55-65% confidence): Use `discharge_single_step` at each targeted step, guaranteeing `target in M'` by construction. The termination measure `|{chi in sigma_list | forall m <= n, chi not_in chain(m)}|` decreases by at least 1 at each targeted step, is bounded by `sigma_list.length`, and reaches 0 in finite steps. Well-founded induction on this count gives forward_F. Requires ~30 downstream theorem re-proofs.

**All 19 prior approaches and 3 recent proposals (bilateral pairs, BX12/Until, quasimodel bridge) are definitively ruled out.** The bilateral pairs approach is isomorphic to MCS and provides no new leverage. BX12 produces abstract BXPoints incompatible with chain indices. The quasimodel bridge faces `sigma_le` vs `g_content` incompatibility.

**Published completeness proofs (Burgess 1984, Goldblatt 1992, GHR 1994) avoid this problem** by working semantically on integer models where F-witnesses have well-ordered temporal structure. No published proof addresses this syntactic obstruction. The codebase's construction is the first Lean 4 formalization of BX completeness.

**Key structural facts established**:
- F-obligation set `{chi in sigma_list | F(chi) in chain(n)}` is exactly constant across all n (proved: `rr_fwd_chain_F_obligation_forward` + `rr_fwd_chain_F_obligation_backward`)
- 3-cycles exist in `bx11_earlier`, ruling out any global BX11 minimum argument
- `target_stays_direct_in_fold` is correctly proved but vacuously applicable when BX11 minimum doesn't exist

## Synthesis

### Conflicts Resolved

No conflicts — single-teammate round. Findings are consistent with all 19 prior research rounds.

### Gaps Identified

1. **Fold-order trick unvalidated**: The mathematical argument is sound but the Lean elaboration has not been attempted. The existing `resolving_enriched_fwd_exists` may need modification to accept target as the last element.

2. **Never-resolved count invariant formalization**: Threading the global never-resolved count through the chain recursion requires careful simultaneous induction. No concrete Lean proof sketch exists yet.

3. **Backward Until coherence (sorry 5) remains independent**: `dd_bfmcs_restricted_buc` is an independent obstacle. Closing sorries 1, 2, 3, 4, 6 would be a substantial publishable result even if sorry 5 remains.

### Recommendations

**Immediate (2 hours)**: Attempt fold-order trick. Modify the call in `enriched_fwd_step` to pass `target` as the last element of the formula list passed to `resolving_enriched_fwd_exists`. Verify that the resulting compound has the form `F(beta AND target) in M` and that `enriched_resolving_seed_consistent` applies.

**Primary (15-20 hours)**: If fold-order trick fails, implement modified chain with never-resolved count. Accept ~30 downstream re-proofs. The mathematical correctness is high confidence; the formalization cost is bounded.

**Do not attempt**: Bilateral pairs (isomorphic to MCS), BX12/Until reformulation (BXPoints vs chain indices), quasimodel bridge (sigma_le incompatibility), any of the 19 cataloged failed approaches.

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Primary approach analysis | completed | High (90% on diagnosis, Medium 50-60% on solution) |

## References

### Key Source Files
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` — 6 sorry sites (lines 1295, 1326, 1333, 1386, ~1390, ~1395)
- `Theories/Bimodal/Metalogic/BXCanonical/OrderedSeedConsistency.lean` — Sorry-free seed consistency proofs
- `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean` — `bx_until_eventuality_resolution` (proved, sorry-free)

### Key Proved Infrastructure
- `enriched_fwd_step_preserves` — F-preservation disjunction (line ~624)
- `enriched_fwd_step_resolves_one` — At least one formula resolved per step (line ~642)
- `rr_fwd_chain_F_propagate` — Reduces forward_F to "cannot persist forever" (line ~1227)
- `target_stays_direct_in_fold` — Deterministic when target is bx11_earlier than all others (line ~1029)
- `discharge_single_step` — Guaranteed target in M' with g_content preserved (line ~975)
- `rr_fwd_chain_F_obligation_forward` / `_backward` — F-obligation constancy (lines ~1162, ~1178)
- `rrSchedule_visits` — Every formula visited periodically (line ~559)

### Prior Task 93 Artifacts Referenced
- Report 17: Round-robin chain history (19 failed approaches)
- Report 18: Team research (Strategy C invalid, never-resolved count proposed)
- Report 19: Team research (bilateral pairs rejected, fold-order trick identified as gap)
- Summary 18: Phase 1 partial implementation (rrSchedule_visits added, 6 sorries unchanged)
- Plans 16, 17, 18: Strategy C, ordered-discharge, target-resolving chain approaches

### Literature
- Burgess, J.P. (1984). "Basic tense logic." (BX classical temporal completeness)
- Goldblatt, R. (1992). "Logics of Time and Computation." (Bulldozing technique)
- Gabbay, D., Hodkinson, I., Reynolds, M. (1994). "Temporal Logic: Mathematical Foundations." (Adequate sets, König's lemma)
- Xu, M. (1988). "On some U, S-tense logics." (Simplified BX axiomatization)
