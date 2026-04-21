# Research Report: Task #109 — Deep Analysis of Approach Viability

**Task**: 109 — Close chain construction sorries
**Date**: 2026-04-20
**Mode**: Team Research (4 teammates)
**Session**: sess_1776739165_d98a94

## Summary

Four teammates conducted exhaustive analysis of the two approaches identified in the prior report (Sigma-restricted defect tracking and Step-indexed forced resolution), with a critic evaluating both and a horizons researcher comparing against the literature. The result is a definitive assessment: **both approaches as previously proposed are fatally flawed**, but the investigation uncovered a third approach (BX12 bridge) and a fourth approach (constructive discharge with negated-F guard) that are more promising.

The universal finding across all teammates is that `fwd_chain_forward_F` is UNPROVABLE for the current `preserving_fwd_step` chain construction without either (a) redesigning the chain or (b) reducing the problem to an already-solved one. The "BX11 perpetual deferral" obstruction is confirmed as genuine: the chain can cycle indefinitely with F(phi) persisting at every step without phi ever appearing directly. No descent argument on the active defect count works without a mechanism to force F(w) out of the successor MCS when w is resolved.

The most promising path forward is the **BX12 bridge**: since `F(phi) -> (T U phi)` is a direct BX axiom, F-eventuality reduces to Until-eventuality. The Until/Since eventuality infrastructure (closed by task 98) already handles Until-formulas. If the `bx_until_eventuality_resolution` machinery can be applied in the `fwd_chain_of_sigma` context, this closes sorry #1 with minimal new work (estimated 4-6 hours). The backup path is **constructive discharge with negated-F guard**: using seed `{phi, ¬F(phi)} ∪ g_content(M)` to produce a successor where phi is resolved AND F(phi) is forced out, enabling clean descent.

## Key Findings

### Universal Agreements (All 4 Teammates)

1. **`fwd_chain_forward_F` is UNPROVABLE for the current chain**. The `preserving_fwd_step` construction resolves SOME defect at each step but cannot control WHICH defect, and resolved defects can retain their F-obligations. No descent argument closes the gap without new infrastructure.

2. **"Resolution by absence of F-obligation" is INVALID** (B, C). `fwd_chain_forward_F` requires `exists m > n, phi in chain(m)` — a concrete witness of phi appearing directly. If F(phi) merely disappears from the chain, we get G(not phi) entering the chain, which means phi NEVER appears in any future step. This is the opposite of what we need.

3. **The BX11 perpetual deferral is a genuine obstruction** (all). BX11 case 2 (`F(beta and F(chi)) in M`) can fire indefinitely for a fixed pair, maintaining F(chi) in the chain even after chi is directly resolved. The code comment at RootScopedChain.lean:1125-1129 explicitly documents this.

4. **F-obligations are monotonically non-increasing** (`fwd_chain_F_obligation_monotone`, proved). Once F(chi) leaves the chain, it never returns. This is the key available tool for any descent argument.

5. **BX12 gives `F(phi) <-> (T U phi)`** (C, D confirmed). Both directions are derivable: BX12 gives F(phi) -> (T U phi), BX10 gives (T U phi) -> F(phi).

6. **A chain redesign is required** (A, B, C). No argument about the EXISTING `preserving_fwd_step` chain can prove `fwd_chain_forward_F`. The chain must be modified to guarantee resolution, or the problem must be reduced to an already-solved one.

### Approach 1 Assessment: Sigma-Restricted Defect Tracking — FATALLY FLAWED

**Core flaw (C, confirmed by A)**: The claim "phi in M' ∩ Sigma clears the defect regardless of F(phi)" is FALSE. `defect_step_choice_early` gives `w in M'` but NO guarantee that `F(w) not-in M'`. Under irreflexive semantics, `w in M'` and `F(w) in M'` are simultaneously consistent (w holds now AND at some strict future). So the resolved formula remains in active_defects.

**Monotonicity failure (A)**: The Sigma-restricted defect set D(k) = {chi in Sigma | F(chi) in chain(k) and chi not-in chain(k)} is NOT monotone non-increasing. A formula chi can be in chain(n) but disappear from chain(n+1) (Lindenbaum extensions don't preserve direct presence), causing chi to re-enter D(n+1).

**Circular framing (C)**: The Sigma closure adds no new mathematical content. `sigma_list` is already the parameter to `fwd_chain_of_sigma`. Redefining a "Sigma-restricted defect set" differently from `active_defects` (which already uses sigma_list) just renames the problem.

**Partial positive (A)**: `discharge_single_step` + BX10 can always resolve Until witnesses in one step (the oracle "always takes the left branch"). This partially resolves Gap G3 from prior research. However, the resulting MCS M' is not chain(n+1) — it's an arbitrary successor.

### Approach 2 Assessment: Step-Indexed Forced Resolution — FATALLY FLAWED AS STATED

**Core flaw (B, C)**: The descent argument relies on defect count strictly decreasing, but resolving w (putting w in M') does NOT force F(w) out of M'. The Lindenbaum extension is opaque — Classical.choice may or may not include F(w). Without `F(w) not-in M'`, the defect count does not decrease.

**F-persistence problem (B)**: If `F(phi) in chain(k)` and `phi not-in chain(k)` for all k >= n, then by `preserving_fwd_step_defect_preserved`, at each step either `phi in chain(k+1)` or `F(phi) in chain(k+1)`. The chain construction (via Classical.choice) can always choose the F(phi) branch indefinitely. This is not contradictory — just a valid chain that doesn't resolve phi.

**F-obligation loss during forced steps (B)**: Using `discharge_single_step` for phi_i loses F-obligations for other phi_j. By monotonicity, lost F-obligations never return. This means forced steps for non-target formulas can permanently destroy F(phi)'s obligation before phi's scheduled turn.

**Correct observation (B)**: `singleton_defect_resolved` (lines 1104-1113) correctly handles the single-defect case. The gap is reaching the singleton case — which requires strict decrease.

### `active_defects` Correction: WRONG (Teammate C)

**Prior research proposed**: Add `chi not-in M` to the `active_defects` filter. Teammate C shows this is WRONG under irreflexive semantics:

Under the project's irreflexive F semantics (BX8 removed, serial_future replaces reflexivity), `chi in M` does NOT satisfy `F(chi)` because the irreflexive future EXCLUDES the current time. So `chi in M` and `F(chi) in M` coexist without contradiction: chi holds now AND at some strict future. Adding `chi not-in M` to the defect filter would undercount defects and break existing theorems.

Furthermore, `fwd_chain_forward_F` requires `m > n` strictly. Even if `phi in chain(n)`, we still need phi at some strictly later step.

**Verdict**: Do NOT modify the `active_defects` definition.

### NEW Approach 3: BX12 Bridge (Teammate D — Highest Priority)

**The key insight**: BX12 gives `F(phi) -> (T U phi)`. At the MCS level, `F(phi) in M -> (T U phi) in M`. The Until/Since eventuality infrastructure (`bx_until_eventuality_resolution`, closed by task 98) already handles Until-eventualities via well-founded recursion on defect_count.

**If** `fwd_chain_forward_F` can be reduced to `bx_until_eventuality_resolution` via BX12, the sorry is closed with minimal new work.

**The challenge**: `bx_until_eventuality_resolution` works for the FULL canonical model (the `bx_le` ordering over all BXPoints), not for a specific Z-indexed chain. Reducing the chain result to the canonical model result requires showing `dd_chain(n)` lives IN the canonical model structure, or re-proving the quasimodel descent within the `fwd_chain_of_sigma` context.

**Estimated effort**: 4-6 hours if the bridge is viable.

**Strategic alignment (D)**: This mirrors how standard references (GHR 1994, Reynolds 1996) handle F-formulas — by reducing to Until within a finite Sigma closure. The project already solved Until/Since this way.

### NEW Approach 4: Constructive Discharge with ¬F(phi) Guard (Teammate D)

**The idea**: At the step resolving defect phi, use seed `{phi, ¬F(phi)} ∪ g_content(M)` instead of `{phi} ∪ g_content(M)`. This produces M' with:
- `phi in M'` (resolved)
- `F(phi) not-in M'` (F-obligation forced out — because `¬F(phi) in M'`)
- `g_content(M) subset M'` (temporal coherence)

**Consistency**: Under irreflexive semantics, `phi and ¬F(phi)` is satisfiable (phi holds now, not in any strict future). So `{phi, ¬F(phi)} ∪ g_content(M)` is consistent — UNLESS `G(phi -> F(phi)) in M`.

**The degenerate case**: If `G(phi -> F(phi)) in M`, then `phi -> F(phi) in g_content(M)`, so the seed `{phi, ¬F(phi)} ∪ g_content(M)` becomes inconsistent (it contains phi, ¬F(phi), and phi -> F(phi)). In this case, phi CANNOT be resolved without retaining F(phi) in the successor.

**How bad is the degenerate case?** `G(phi -> F(phi)) in M` means "at all future times, if phi holds then phi also holds at some even later time." This is consistent with phi eventually appearing — it just means phi keeps "regenerating" its own F-obligation. This case requires a different argument, possibly semantic, showing that the chain STILL eventually contains phi via the BX11 fold mechanism.

**Estimated effort**: 6-10 hours, with the degenerate case potentially adding significant complexity.

### Literature Comparison (Teammate D)

| Reference | Strategy | F-eventuality handling | Applicable? |
|-----------|----------|----------------------|-------------|
| Burgess (1982/1984) | Full MCS space | Lindenbaum on fresh witness set — full MCS space guarantees witness exists | No — we need Z-indexed chain |
| Goldblatt (1992) | G-content chain | Under reflexive semantics (avoids regeneration) | No — we use irreflexive semantics |
| GHR (1994) | Quasimodel defect-counting | Finite Sigma closure, well-founded recursion on defect_count | YES — this is what our Hintikka chain does for Until/Since |
| Reynolds (1996) | Quasimodel unraveling | Same defect-counting pattern | YES — same pattern |
| This project | Hintikka chain + dd_chain | Until/Since: solved. F/P: gap at `fwd_chain_forward_F` | The BX12 bridge would apply the same pattern to F |

**Key insight**: Standard references avoid this problem by either (a) not using a Z-indexed chain, or (b) reducing F to Until via finite defect counting. This project must use approach (b) since task frame semantics requires Z-indexing.

## Synthesis

### Conflicts Resolved

1. **Teammate A (Sigma-restricted viable) vs Teammate C (fatally flawed)**: C is correct. The Sigma-restricted framing does not add mathematical content beyond what `active_defects` already provides. The monotonicity failure (A's own finding at line 148: "D is NOT automatically monotone") confirms C's assessment. **Resolution**: Approach 1 is rejected.

2. **Teammate B (step-indexed is "right direction") vs Teammate C (descent argument unsound)**: Both are partially correct. Step-indexed forcing IS the right structural idea (targeted resolution of specific defects), but the specific descent argument as previously proposed is unsound because it cannot guarantee F(w) leaves the chain when w is resolved. **Resolution**: The step-indexed idea needs to be combined with a mechanism to force F(w) out — which is exactly Approach 4 (constructive discharge with ¬F(phi) guard).

3. **active_defects correction debate (A says fix, C says wrong)**: C is correct for irreflexive semantics. Under irreflexive F, `chi in M` and `F(chi) in M` coexist without contradiction. The correction would undercount defects. **Resolution**: Do NOT modify `active_defects`.

4. **BX12 bridge priority (D proposes, others don't consider)**: D's BX12 bridge is the most promising finding. Neither A, B, nor C explored this direction. The bridge leverages existing solved infrastructure (Until/Since eventuality resolution) and aligns with the standard literature (GHR/Reynolds). **Resolution**: BX12 bridge is primary recommendation.

### Gaps Identified

1. **BX12 bridge viability (CRITICAL)**: Does `bx_until_eventuality_resolution` apply in the `fwd_chain_of_sigma` context? This requires checking whether the `bx_le` ordering used by the canonical model is compatible with the chain's `dd_chain` structure. No teammate verified this.

2. **Constructive discharge degenerate case (HIGH)**: When `G(phi -> F(phi)) in M`, the seed `{phi, ¬F(phi)} ∪ g_content(M)` is inconsistent. This case needs separate handling. No teammate proposed a complete solution for this case.

3. **Sorry sites #2 and #3 (MEDIUM)**: The backward P-resolution (sorry #3) needs a symmetric `preserving_bwd_step`. Sorry #2 (F in backward region) may be solvable via `P(F(phi)) -> P(phi) v F(phi)` given sorry #1, but C notes this derivability is non-trivial.

4. **Sorry sites #4 and #5 (SEPARATE)**: Until/Since coherence (`dd_bfmcs_restricted_buc` and `dd_bfmcs_restricted_fuc`) are independent problems. All teammates agree these need a separate task.

5. **Realization.lean sorry sites are DEAD CODE (confirmed, all)**: Not on the critical path. The 4 sorry sites in Realization.lean are not called anywhere in the completeness proof.

### Recommendations

**Priority 1: BX12 Bridge (4-6 hours)**

Check whether `bx_until_eventuality_resolution` can close `fwd_chain_forward_F` via:
1. `F(phi) in chain(n)` -> `(T U phi) in chain(n)` (by BX12 + MCS modus ponens)
2. Apply existing Until-eventuality machinery to get phi at some future chain step
3. The key check: does the chain's structure satisfy the preconditions of the Until machinery?

This is the fastest path and most aligned with the project's existing infrastructure and the standard literature.

**Priority 2: Constructive Discharge with ¬F(phi) Guard (6-10 hours)**

If the BX12 bridge is blocked, redesign the chain to use `{phi, ¬F(phi)} ∪ g_content(M)` as the seed when resolving defect phi. This gives a clean descent: each resolution removes phi from active_defects permanently (since F(phi) is forced out).

Handle the `G(phi -> F(phi))` degenerate case by:
- Either proving this cannot occur for all defects simultaneously (combinatorial argument)
- Or using a semantic argument that even when `G(phi -> F(phi)) in M`, the BX11 fold eventually places phi directly

**Priority 3: Chain Redesign with BX11-Minimum Targeting (8-12 hours)**

If both above fail, use `target_stays_direct_in_fold` (already proved, lines 948-984) to redesign `preserving_fwd_step`. At each step, find the BX11-minimum of the defect set, resolve it directly, and preserve all other F-obligations. The descent argument tracks the BX11-minimum across rounds.

**Independent: Derive P(F(phi)) -> P(phi) v F(phi) (2-4 hours)**

This resolves sorry #2 given sorry #1. All teammates agree this is straightforward and useful regardless of which approach is taken for sorry #1.

**Separate Task: Sorry sites #4 and #5 (Until/Since coherence)**

All teammates agree `dd_bfmcs_restricted_buc` and `dd_bfmcs_restricted_fuc` are independent problems needing separate treatment.

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Contribution |
|----------|-------|--------|------------|-----------------|
| A | Sigma-restricted analysis | completed | medium (45-50%) | Proved Sigma-restricted defect set is NOT monotone; identified quasimodel bridge via discharge_single_step + BX10 |
| B | Step-indexed analysis | completed | low-medium (30-60%) | Proved "resolution by absence" is invalid; identified F-persistence problem; confirmed singleton_defect_resolved as viable base case |
| C | Critic | completed | high (code-level) | Found fatal flaws in both approaches; proved active_defects correction is WRONG; confirmed BX12 derivability |
| D | Strategic horizons | completed | medium-low (40%) | Proposed BX12 bridge (highest-priority new path); proposed constructive discharge with ¬F(phi) guard; literature comparison showing GHR/Reynolds pattern is the right model |

## References

- Burgess (1982/1984): "Axioms for Tense Logic" — canonical model over full MCS space
- Xu (1988): Simplified Burgess axiomatization
- Goldblatt (1992): "Logics of Time and Computation" — G-content ordering
- GHR (1994): Gabbay/Hodkinson/Reynolds "Temporal Logic" Vol 1 — quasimodel defect-counting
- Reynolds (1996): "Axiomatising first-order temporal logic" — quasimodel unraveling
- specs/109_close_chain_construction_sorries/reports/05_team-research.md — prior team research
- specs/109_close_chain_construction_sorries/handoffs/04_fwd-chain-analysis.md — prior analysis
- RootScopedChain.lean:1120-1134 — code comment documenting the gap and BX11 perpetual deferral
- Construction.lean:273-297 — hintikka_step_target_decrease (the solved Until analogue)
