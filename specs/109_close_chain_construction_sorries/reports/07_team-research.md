# Research Report: Task #109

**Task**: Close chain construction sorries for sorry-free completeness
**Date**: 2026-04-20
**Mode**: Team Research (4 teammates)
**Session**: sess_1745187600_b947d9

## Summary

Four teammates conducted first-principles research into the 11 sorry sites blocking sorry-free `bx_completeness`. The breakthrough finding: **the codebase contains TWO canonical model constructions, and 6 rounds of research have been trying to fix the wrong one.** The sorry-free `bx_fmcs` construction in CanonicalModel.lean, combined with schedule surjectivity and the F-obligation monotonicity contrapositive, provides a clean proof strategy for `fwd_chain_forward_F` that avoids the Lindenbaum opacity problem entirely. The defect-directed `fwd_chain_of_sigma` in RootScopedChain.lean is provably unfixable due to `Classical.choice` opacity in the BX11 fold.

## Key Findings

### 1. BREAKTHROUGH: Two Canonical Model Constructions (Teammate C)

The codebase has two independent canonical model constructions in the same directory:

| Construction | File | Chain Type | Step Function | Sorries |
|---|---|---|---|---|
| `bx_fmcs` / `int_chain` | CanonicalModel.lean | Schedule-based | `fwd_succ` (simple Lindenbaum with schedule target) | **ZERO** |
| `dd_bfmcs` / `fwd_chain_of_sigma` | RootScopedChain.lean | Defect-directed | `preserving_fwd_step` (BX11 fold + Classical.choice) | **5 critical** |

All 6 prior research rounds focused exclusively on fixing `fwd_chain_of_sigma`. Nobody asked whether `dd_countermodel` could be rewired to use `bx_fmcs` instead.

**Why `bx_fmcs` is better**: It uses a deterministic schedule (`schedule : Nat -> Formula`) that is surjective above every index (every formula appears infinitely often). At each step, `fwd_succ` resolves the scheduled formula if its F-obligation is present, via `fwd_succ_resolves`. There is no BX11 fold, no Classical.choice opacity fight.

### 2. The Schedule + Monotonicity Proof Strategy (Teammates C, D)

For the `bx_fmcs` construction, `fwd_chain_forward_F` can be proved by:

1. **F(psi) in chain(n)** (hypothesis)
2. **By `schedule_surjective_above`**: exists m >= n with schedule(m) = psi
3. **Case 1**: F(psi) still in chain(m). Then chain(m+1) = fwd_succ(chain(m), psi). Since F(psi) in chain(m), `fwd_succ_resolves` gives psi in chain(m+1). **Done.**
4. **Case 2**: F(psi) NOT in chain(m). By `fwd_chain_F_obligation_monotone` contrapositive: F(psi) dropped at some step k (n < k <= m). By `defect_one_step_preservation`: if F(psi) in chain(k-1) and F(psi) NOT in chain(k), then psi in chain(k). **Done.**

This proof strategy is clean, avoids Classical.choice opacity, and uses only already-proved infrastructure. The key insight (Teammate C, Assumption 3) is exploiting the **contrapositive** of F-obligation monotonicity: if F(phi) drops, then phi MUST have appeared at the drop step.

### 3. `fwd_chain_of_sigma` is Provably Unfixable (All Teammates)

All 4 teammates independently confirmed: `fwd_chain_forward_F` CANNOT be proved for the defect-directed chain. The reasons are:

- **Classical.choice opacity** (Teammates A, B, C): The BX11 fold produces a Lindenbaum seed where `Classical.choice` selects which defect is resolved. No argument can force a SPECIFIC defect to be resolved.
- **F(phi) -> G(F(phi)) is NOT valid** (Teammate A): On irreflexive linear orders, F-obligations are not automatically preserved by g_content propagation. `discharge_single_step` for a different target can destroy F(chi) without producing chi.
- **50+ rounds of evidence** (Teammate B): Task 93 and 109 combined have exhaustively explored every descent argument, enriched seed variant, and hybrid chain design. ALL fail at the same fundamental wall.

### 4. Non-Critical Sorries are Dead Code or Provably False (Teammates C, D)

| Sorry | File | Status | Reason |
|---|---|---|---|
| `bx_le_refl` | Frame.lean:205 | FALSE | Requires BX1 (removed) |
| `until_backward_refl_mcs` | TruthLemma.lean:293 | FALSE | Requires reflexive Until intro |
| `since_backward_refl_mcs` | TruthLemma.lean:317 | FALSE | Dual of above |
| `refl_intro_until_mcs` | Construction.lean:161 | FALSE | Same as TruthLemma version |
| `refl_intro_since_mcs` | Construction.lean:207 | FALSE | Dual |
| `F_of_mem` / `P_of_mem` | Realization.lean:67,73 | FALSE | Requires BX1 |
| `enriched_seed_consistent_*` | Realization.lean:197,249 | FALSE | Requires BX1 |
| `sigma_le_refl` | SigmaOrdering.lean:82 | FALSE | Requires BX1 |

None of these are on the critical path to `bx_completeness`. They should be deleted or marked as explicitly irreflexive-incompatible.

### 5. The Truth Lemma is NOT the Bottleneck (Teammate D)

The truth lemma architecture is sound. All formula cases are proved. The 2 sorry sites in TruthLemma.lean are dead code. The bottleneck is the 3 BFMCS coherence properties passed to `dd_countermodel`:

- `dd_bfmcs_restricted_tc` (F/P resolution) - **addressable via schedule + monotonicity**
- `dd_bfmcs_restricted_buc` (backward Until introduction) - **hardest problem**
- `dd_bfmcs_restricted_fuc` (forward Until elimination) - **depends on tc + guard persistence**

### 6. Sorry #4 (Backward Until Introduction) is the Hardest Problem (All Teammates)

All teammates agree: backward Until/Since coherence (`dd_bfmcs_restricted_buc`) is fundamentally harder than F-resolution. It requires:

> Given `psi in chain(s)` and `phi in chain(r)` for all r in [t,s), derive `(phi U psi) in chain(t)`

This is Until introduction from semantic witnesses. Under irreflexive semantics, BX8 is removed, so no axiom directly introduces Until. The step transfer `phi AND F(phi U psi) -> phi U psi` is NOT derivable from BX. This may need a separate task or a fundamentally different approach (possibly semantic completeness).

## Synthesis

### Conflicts Resolved

**Conflict 1: Which chain to use?**
- Teammate A proposed redesigning `fwd_chain_of_sigma` with round-robin discharge
- Teammate C proposed switching to `bx_fmcs` entirely
- **Resolution**: Teammate C's approach is superior. The round-robin discharge has a genuine F-preservation gap (Teammate A confirmed this in their own analysis). The `bx_fmcs` schedule approach avoids the gap entirely. Evidence: C's proof sketch uses only already-proved lemmas, while A's approach needs a new `extended_discharge_step` with unproven consistency.

**Conflict 2: Is BX12 the right path?**
- Teammate B recommended GHR/Reynolds quasimodel pattern via BX12
- Teammate C said the BXPoint-to-chain-index bridge is unnecessary if using `bx_fmcs`
- **Resolution**: BX12 is mathematically correct but architecturally wrong for the current codebase. Rewiring `dd_countermodel` to `bx_fmcs` is simpler than building a BXPoint-to-chain bridge. However, BX12 may still be useful for Until coherence (sorry #5).

**Conflict 3: Can any descent argument work?**
- Teammate B said NO descent arguments can work (exhaustively proven)
- Teammate C said descent is unnecessary — the schedule + monotonicity contrapositive gives a dichotomy
- **Resolution**: Both are correct. No descent argument works for `fwd_chain_of_sigma`. The `bx_fmcs` approach is NOT a descent argument — it's a dichotomy (F persists until scheduled → resolved, or F drops → already resolved).

### Gaps Identified

1. **Can `dd_countermodel` be rewired to use `bx_fmcs`?** This is the critical unverified claim. The `dd_countermodel` currently takes `dd_bfmcs` which is built from `fwd_chain_of_sigma`. Rewiring requires:
   - `bx_fmcs` provides `restricted_temporally_coherent` (provable via schedule + monotonicity)
   - `bx_fmcs` provides `restricted_forward_until_since_coherent` (partially provable, guard persistence needs work)
   - `bx_fmcs` provides `restricted_backward_until_since_coherent` (hardest, may need fundamentally new approach)

2. **Does `defect_one_step_preservation` hold for `bx_fmcs`'s `fwd_succ`?** The current proof is for `preserving_fwd_step`. The analogous result for `fwd_succ` needs to be verified or reproved.

3. **Until guard persistence** (sorry #5): Even with F-resolution solved, showing phi holds at ALL intermediate chain points between t and the Until witness s requires g_content propagation of Until formulas, which is not guaranteed.

4. **Backward Until introduction** (sorry #4): No clear path identified. May require semantic completeness approach (GHR style) or a separate task.

### Recommendations

**Primary Path (HIGH confidence)**: Rewire `dd_countermodel` to use `bx_fmcs` and prove `restricted_tc` via schedule + monotonicity contrapositive.

**Phases**:
1. **Verify rewiring feasibility**: Check that `bx_fmcs` type-checks where `dd_bfmcs` currently appears in `dd_countermodel`. Identify any structural mismatches.
2. **Prove `fwd_chain_forward_F` for `bx_fmcs`**: Use schedule surjectivity + F-obligation monotonicity contrapositive (the proof sketch from Teammate C).
3. **Prove backward P-resolution**: Symmetric argument using backward schedule + H-obligation monotonicity.
4. **Prove forward Until/Since coherence**: BX10 gives F(psi), then F-resolution gives psi at some s > t. Guard persistence via BX5 (self-accumulation) + BX9 (Until elimination).
5. **Address backward Until/Since coherence**: This is the hardest piece. Options: (a) prove directly from chain structure + BX axioms, (b) add auxiliary chain construction for Until witnesses, (c) defer to semantic completeness approach.
6. **Delete dead code**: Remove all provably-false sorry sites (Frame.lean, TruthLemma reflexive cases, Realization.lean, SigmaOrdering.lean).

**Fallback Path (MEDIUM confidence)**: If rewiring fails (structural mismatch), pursue semantic completeness (Goldblatt/GHR style) where canonical model worlds = full MCS space, avoiding chain construction entirely. This is the most principled solution per the ROADMAP but requires significant re-engineering.

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Contribution |
|----------|-------|--------|------------|-----------------|
| A | Primary semantics analysis | completed | medium | Exhaustive first-principles analysis confirming F-preservation gap; proved `F(phi) -> G(F(phi))` is NOT valid |
| B | Task 93 review + patterns | completed | medium-high | Catalog of 50+ rounds of dead ends; literature alignment (GHR/Reynolds); reusable infrastructure inventory |
| C | Critic / gap analysis | completed | high | **BREAKTHROUGH**: identified `bx_fmcs` as the correct construction; schedule + monotonicity proof sketch |
| D | Truth lemma end-to-end | completed | medium | Completeness chain map; confirmed truth lemma is NOT bottleneck; ROADMAP alignment analysis |

## References

### Codebase
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean` — Sorry-free `bx_fmcs` construction
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` — Defect-directed `dd_bfmcs` with 5 critical sorries
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalChain.lean` — Base chain infrastructure
- `Theories/Bimodal/Semantics/Truth.lean` — Irreflexive truth_at definition
- `Theories/Bimodal/Metalogic/BXCanonical/RestrictedParametricTruthLemma.lean` — Truth lemma
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` — `bx_completeness`

### Literature
- Goldblatt (1992) — G-content ordering, schedule-based canonical model
- GHR (1994, Ch. 6) — Quasimodel approach, defect-count descent
- Reynolds (1996) — Quasimodel unraveling for first-order temporal logic
- Burgess (1982/1984) — Full MCS space canonical model

### Prior Research
- Task 93 (51 rounds): Irreflexive semantics transition, forward_F obstruction discovery
- Task 109 reports 01-06: Defect-directed chain analysis, BX11/BX12 analysis, all approaches cataloged
- Task 109 handoffs: Phase-level gap analysis, BX11 case analysis, fwd_chain_forward_F impossibility proof
