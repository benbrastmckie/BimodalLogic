# Teammate A Findings: Architecture C -- Quasimodel Replacement

**Task**: 93 - Close BXCanonical embedding sorry
**Angle**: Primary -- Architecture C (Burgess 1984 proper canonical model construction)
**Date**: 2026-04-13

## Key Findings

### Finding 1: The Existing Quasimodel Infrastructure Is Substantial but Disconnected from CanonicalModel.lean

The codebase already has 1,931 lines of quasimodel infrastructure across 6 files:

| File | Lines | Content | Sorry-Free? |
|------|-------|---------|-------------|
| `Quasimodel/Construction.lean` | ~500 | `hintikka_step`, `QuasimodelChain`, `HintikkaStepOracle`, `hintikka_chain_exists`, `defect_count`, `hintikka_step_target_decrease`, `WitnessedHintikka`, `HintikkaRawChain`, `ChainWitnessed` | Yes |
| `Quasimodel/Realization.lean` | ~444 | `F_of_mem`, `P_of_mem`, `F_from_above`, BX axiom MCS lemmas (`until_elim_mcs`, `self_accum_mcs`, `until_F_mcs`, `connect_future_mcs`, `refl_intro_until_mcs`, etc.), `bigconj_intro`, `bigconj_mem_iff`, `enriched_seed_consistent_until/since`, `chain_step_seed_consistent_enriched`, eventuality resolution delegation | Yes |
| `Quasimodel/HintikkaPoint.lean` | ~100+ | `HintikkaPoint` structure, `sigma_signature`, `sigma_signature_consistent/maximal` | Yes |
| `Quasimodel/SubformulaClosure.lean` | ~50+ | `subformulas`, `ghEnrichment`, `SubformulaClosure` | Yes |
| `Quasimodel/EnrichedClosure.lean` | ~50+ | Fisher-Ladner style enrichment (`enrichedGNegBigconj`, `enrichedHNegBigconj`) | Yes |
| `Quasimodel/LocusControl.lean` | ~47 | Delegation wrappers (`bx_until_eventuality_resolution'`, `bx_since_eventuality_resolution'`) | Yes |
| `Frame.lean` | 673 | `BXPoint`, `bx_le`, eventuality resolution (`bx_until_eventuality_resolution`, `bx_since_eventuality_resolution`), all G/H/Box infrastructure | Yes |

**Critical observation**: All of this infrastructure is sorry-free and proved. However, none of it is consumed by `CanonicalModel.lean`. The quasimodel files were built for a realization-lifting approach that was ultimately blocked by the G-persistence obstacle documented in `Realization.lean:366-395`.

### Finding 2: Architecture C (Full Quasimodel Replacement) Has a Fatal Gap at the Same Point

A full Burgess 1984 quasimodel replacement would:
1. Build finite Hintikka chains for each Until/Since defect (Phase A)
2. Combine them into a single Z-indexed chain of MCS (Phase B)

Phase A is already mostly implemented. The gap is Phase B: **lifting a sequence of Hintikka points back to a Z-indexed chain of MCS with g_content/h_content propagation**.

The obstacle is documented precisely in `Realization.lean:366-395`:

> "**Obstacle**: `g_content(v_i) subset w_{i+1}.formulas` (required for seed consistency via `chain_step_seed_consistent_enriched`) fails for `G(chi) in v_i` with `G(chi) not in Sigma`."
>
> "**Further obstacle**: G-formulas do NOT persist through the Hintikka chain."
>
> "**Consequence**: Chain realization requires either (a) G-persistence in the Sigma-closure (not available for the enriched closure), or (b) a completely different approach."

This means a full quasimodel replacement would hit the SAME obstacle that blocked the realization lifting. The Hintikka chain (finite, Sigma-bounded) cannot be directly lifted to an MCS chain (infinite, full formula set) while preserving g_content/h_content propagation.

### Finding 3: The Scheduling Chain IS Correct for g_content/h_content -- The Problem Is Exclusively in the Coherence Proofs

The existing `int_chain` in CanonicalModel.lean correctly establishes:
- `g_content(chain(t)) subset chain(t+1)` -- proved at line 246
- `h_content(chain(t+1)) subset chain(t)` -- proved at line 269
- `box_stable_in_int_chain` -- proved at line 429
- All FMCS/BFMCS structure (modal_forward, modal_backward) -- proved at lines 511-563

These are ~400 lines of non-trivial proofs that would need to be REPLICATED in any replacement. A full quasimodel replacement does not avoid this work -- it adds to it.

### Finding 4: The Only Viable Quasimodel Contribution Is Approach A (Seed Enrichment with untilCarry)

Report 08's exhaustive analysis (1073 lines) systematically eliminates alternatives:
- Section 3.1-3.3: Quasimodel interleaving/unraveling fails (same seed consistency issues)
- Section 3.4-3.6: Direct replacement fails (Realization.lean obstacle)
- Section 3.7-3.9: fCarry in resolving seed is definitively inconsistent (concrete counterexample: `psi = G(neg(chi))` and `F(chi) in fCarry`)
- Section 3.10: The breakthrough -- F-formulas resolve via Until (BX12), no fCarry needed
- Section 4.2-4.5: Step transfer is NOT available from BX axioms alone, BUT untilCarry in non-resolving seed is provably safe

The recommendation converges on **Approach A**: add `restrictedUntilCarry(M, root)` to the existing `fwd_succ`/`bwd_pred` seeds.

### Finding 5: The Resolving-Branch Consistency of {psi} union g_content(M) union untilCarry(M, root) Is the Critical Unknown

Report 08 Section 5 gives the consistency proof attempt:

1. Suppose `L subset seed` derives `bot`. Partition `L = L_psi union L_g union L_u`.
2. By deduction: `L_g union L_u derives neg(psi)`.
3. Since `L_g union L_u subset M`, by MCS closure: `neg(psi) in M`.
4. Apply temporal K to `L_g` with iterated deduction on `L_u`: get `G(u_1 -> u_2 -> ... -> neg(psi)) in M`.
5. Need `G(u_j) in M` to unwrap via K-distribution. But `u_j = (phi_j U psi_j)` and `G(phi_j U psi_j)` is NOT guaranteed.

**The temporal K unwrapping fails at step 5.** The BX7/BX11 linearity argument (mentioned as fallback) would require complex derivation tree construction and is itself a research-grade open problem.

**Probability assessment**: 40-50% that the resolving-branch consistency can be proved. The argument in Report 08 Section 4.6 (using BX10 + BX11 to derive contradiction from `(a U neg(psi)) in M` with `F(psi) in M`) is promising but incomplete.

### Finding 6: The Plan v8 (Current Plan) Already Embodies Approach A, Not Architecture C

The current plan (plans/08_bxcanonical-embedding.md) explicitly states in Non-Goals:
> "Full quasimodel infrastructure (Approach C from Report 08)"

Plan v8 IS Approach A. It proposes:
- Phase 1: Define `restrictedUntilCarry`/`restrictedSinceCarry`
- Phase 2: Prove resolving-branch consistency (4-hour hard cutoff)
- Phase 3: Parameterize chain by root
- Phase 4: Prove Until persistence and step transfer
- Phase 5: Close the 3 restricted sorry sites
- Phase 6: Cleanup

**Plan v8 is the correct plan.** Architecture C (full quasimodel replacement) is NOT recommended.

## Recommended Approach

**Do NOT pursue Architecture C (full quasimodel replacement).** Instead, execute Plan v8 (Approach A) with the following refinements:

### Refinement 1: Non-Resolving-Only untilCarry as Fallback

If Phase 2 (resolving-branch consistency) fails within 4 hours, do NOT fall back to a parallel quasimodel chain. Instead, use a simpler fallback:

**Add untilCarry to the NON-RESOLVING branch only.** This is trivially consistent (subset of M). Until formulas persist through all non-resolving steps. At resolving steps, Until formulas MAY be lost, but the schedule ensures they are targeted infinitely often via the BX12 reduction (`F(psi) -> (top U psi)` when `(top U psi) in subformulaClosure(root)`).

The forward Until argument then becomes:
1. `(phi U psi) in chain(t)` with `phi in chain(t), psi not in chain(t)`.
2. By BX10: `F(psi) in chain(t)`.
3. `F(psi)` persists through non-resolving steps (via fCarry).
4. At the next resolving step for psi (schedule targets psi), `psi in chain(n+1)`.
5. Between t and n+1, at non-resolving steps, `(phi U psi)` persists (via untilCarry).
6. At resolving steps for other formulas between t and n, `(phi U psi)` may be lost... but we still have `F(psi)` surviving until step n.

**Problem**: Steps 5-6 still have the same gap -- we cannot guarantee `(phi U psi)` or `phi` persists through resolving steps for other formulas.

### Refinement 2: The Minimal Sufficient Approach

The truly minimal approach that avoids the resolving-branch consistency issue entirely:

**Add untilCarry to BOTH branches, but prove consistency of the resolving branch differently.** The key insight from the BX axiom analysis:

For the resolving branch, the seed is `{psi} union g_content(M) union untilCarry(M, root)`. ALL elements of `g_content(M) union untilCarry(M, root)` are in M (g_content via BX1, untilCarry directly). So the seed is `{psi} union S` where `S subset M`.

The existing `forward_temporal_witness_seed_consistent` proves `{psi} union g_content(M)` consistent. The proof works by showing `g_content(M) derives neg(psi) implies G(neg(psi)) in M implies contradiction with F(psi) in M`.

For the extended seed, the alternative proof route is:
1. Suppose `L subset {psi} union g_content(M) union untilCarry(M, root)` derives bot.
2. Case: psi not in L. Then L subset M, contradicting M consistent.
3. Case: psi in L. By deduction: `L\{psi} derives neg(psi)`. All of `L\{psi} subset M`, so `neg(psi) in M`.
4. Since `neg(psi) in M` and `F(psi) in M`, these are compatible (psi false now, true later).
5. For contradiction: we need to show that `L\{psi}` CANNOT actually derive `neg(psi)` using only the temporal K mechanism for g_content elements.

The crux: the derivation may use Until formulas from untilCarry to derive `neg(psi)` in ways that the temporal K argument cannot refute.

**I estimate this proof has a 40-50% success probability within the 4-hour cutoff.**

## Evidence/Examples

### Critical File References

- **Sorry sites**: `CanonicalModel.lean:497` (`bx_fmcs_forward_F`), `:503` (`bx_fmcs_backward_P`), `:621` (`bx_bfmcs_restricted_buc`), `:627` (`bx_bfmcs_restricted_fuc`), with `:603` (`bx_bfmcs_restricted_tc`) depending on the first two.
- **Realization obstacle**: `Realization.lean:366-395` -- documents why Hintikka chain realization fails.
- **Existing one-step resolution**: `Frame.lean:623-644` (`bx_until_eventuality_resolution`) -- sorry-free.
- **Step transfer API**: `UntilSinceCoherence.lean:111-138` (`backward_until_from_step`) -- proved, parameterized by step hypothesis.
- **Schedule surjectivity**: `CanonicalModel.lean:43-47` (`schedule_surjective_above`).
- **Seed consistency**: `WitnessSeed.lean` (`forward_temporal_witness_seed_consistent`) -- the temporal K argument.
- **BX12**: `CanonicalChain.lean:65-72` (`F_imp_top_until_mcs`) -- proved.

### Counterexample: fCarry in Resolving Seed

From Report 08 Section 3.9, confirmed by Report 07 Finding 2:
- Let `psi = G(neg(chi))` and `F(chi) in fCarry(M, root)`.
- Then `{G(neg(chi))} union {F(chi)}` contains both `G(neg(chi))` and `neg(G(neg(chi)))` (since `F(chi) = neg(G(neg(chi)))`).
- This is inconsistent.
- Therefore, fCarry CANNOT be added to the resolving seed.

### Counterexample: untilCarry in Resolving Seed (Potential)

From Report 08 Section 4.6:
- Let `psi = alpha` and `(neg(alpha) U chi) in untilCarry(M, root)`.
- By BX9: `(neg(alpha) U chi) -> neg(alpha) v chi`.
- In the seed: `{alpha, neg(alpha) U chi}`. From these, derive `chi` (not bot).
- So this specific case is NOT inconsistent.
- However, more complex interactions (e.g., `(neg(alpha) U neg(beta))` combined with `(neg(beta) U alpha)` and `psi = alpha`) could potentially derive bot. Analysis in Report 08 was inconclusive.

## Risks and Hard Lemmas

| Risk | Severity | Likelihood | Notes |
|------|----------|------------|-------|
| Resolving-branch consistency unprovable | CRITICAL | 40-50% | THE make-or-break proof. If fails, must fall back to a fundamentally different approach. |
| `(top U psi)` not in `subformulaClosure(root)` | HIGH | HIGH | BX12 gives `F(psi) -> (top U psi)`, but `(top U psi)` must be in the closure for restricted forward Until to apply. Closure definition needs extending. |
| Step transfer circularity | HIGH | MEDIUM | `backward_until_from_step` needs `(phi U psi) in chain(r+1) and phi in chain(r) -> (phi U psi) in chain(r)`. This requires untilCarry to be in the FORWARD seed (chain(r+1) built from chain(r)), which it is -- but the step transfer is from `chain(r+1)` BACK to `chain(r)`, not forward. The step transfer means: `(phi U psi)` was in the seed for `chain(r+1)` because it was in `untilCarry(chain(r), root)`, which requires `(phi U psi) in chain(r)`. Circular! |
| Root parameterization cascade | MEDIUM | LOW | Adding `root` parameter to ~15 definitions and ~20 lemmas. Straightforward but tedious. |

### The Hardest Lemma

**`restricted_resolving_seed_consistent`**: Prove that `{psi} union g_content(M) union restrictedUntilCarry(M, root)` is consistent when `F(psi) in M`.

This is the single hardest proof obligation. All other lemmas are either straightforward (seed inclusion) or follow from existing infrastructure.

### The Step Transfer Circularity (Critical)

The step transfer says: `(phi U psi) in chain(r+1) -> (phi U psi) in chain(r)` (when `phi in chain(r)` and `(phi U psi) in subformulaClosure(root)`).

If untilCarry is in the forward seed, then `(phi U psi) in chain(r+1)` holds because `(phi U psi)` was in `untilCarry(chain(r), root)`, which requires `(phi U psi) in chain(r)`. This is circular -- we need step transfer to prove `(phi U psi) in chain(r)`, but the construction already assumes it.

The resolution: step transfer is NOT about the chain construction. It is about the PROOF that `(phi U psi) in chain(r)` given the semantic witness pattern. The construction ensures `(phi U psi)` persists FORWARD (from chain(r) to chain(r+1)). The proof of backward Until uses `backward_until_from_step` which inducts from s down to t, using step transfer at each step. Since `(phi U psi)` persists forward, if `(phi U psi) in chain(r)` then `(phi U psi) in chain(r+1)`. The step transfer is: given `(phi U psi) in chain(r+1)` and `phi in chain(r)`, conclude `(phi U psi) in chain(r)`. This is NOT provided by forward persistence -- it is the REVERSE direction.

**The step transfer requires a separate proof.** The key mechanism: if `phi in chain(r)` and we KNOW `(phi U psi) in chain(r+1)` (induction hypothesis), we need `(phi U psi) in chain(r)`. By BX axioms on `chain(r)`: `phi in chain(r)` gives `F(phi U psi) in chain(r)` (via connect_past on chain(r+1) + backward H). Then `F(phi U psi) -> (top U (phi U psi))` by BX12. But getting from `(top U (phi U psi))` to `(phi U psi)` requires BX2 (left monotonicity) with `G(top -> phi)`, which we do not have.

**Alternative**: By BX axiom `or_until_in_mcs`: `psi in M v (phi and (phi U psi)) in M -> (phi U psi) in M`. If `phi in chain(r)` and `(phi U psi) in chain(r)` ... circular again.

The step transfer is genuinely hard and may require a novel BX axiom argument.

## Confidence Level

**LOW-MEDIUM** for Architecture C (full quasimodel replacement). The analysis shows it hits the same obstacles as the current approach, with additional complexity from the realization lifting gap.

**MEDIUM** for Plan v8 / Approach A (the current plan). The resolving-branch consistency proof is the critical unknown with ~40-50% success probability. If it succeeds, the remaining work is straightforward (~200-300 lines). If it fails, a fundamentally different approach is needed.

**Recommendation**: Execute Plan v8 as-is, with the 4-hour hard cutoff on Phase 2. Architecture C is NOT recommended as a replacement.
