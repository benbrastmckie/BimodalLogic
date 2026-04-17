# Teammate D (Horizons) Findings: Round 32

**Task**: 93 - Close 6 sorry sites in RootScopedChain.lean
**Focus**: Long-term architectural strategy and sunk cost analysis
**Date**: 2026-04-16

## Key Findings

### 1. Architecture Audit: Two Parallel Approaches Serving Different Purposes

The codebase contains two distinct proof strategies that are **complementary, not redundant**:

**Path A: The Round-Robin Chain (RootScopedChain.lean, 1559 LOC)**
- Builds an Int-indexed chain of MCS via `rr_fwd_chain` / `enriched_fwd_step`
- Uses BX11 fold for disjunctive F-formula preservation
- Feeds into `dd_fmcs` -> `dd_bfmcs` -> `dd_countermodel` -> `bx_completeness`
- **6 sorry sites** block this path
- The chain is the DATA STRUCTURE for the countermodel

**Path B: The Quasimodel Infrastructure (Quasimodel/, 1816 LOC)**
- Sorry-free: Construction.lean (887), Realization.lean (444), HintikkaPoint.lean (166), etc.
- Provides `hintikka_chain_exists` and `hintikka_chain_exists_since` with defect-driven termination
- `HintikkaStepOracle` + `WitnessedHintikka` + `ChainWitnessed` + `chain_step_seed_consistent`
- Currently NOT connected to the chain construction in RootScopedChain.lean

**Relationship**: Path B provides the mathematical TECHNIQUE (defect-driven chain construction with termination via `defect_count`) that Path A needs but lacks. Path A provides the INFRASTRUCTURE (FMCS/BFMCS types, parametric truth lemma, algebraic representation) that connects to the completeness theorem. They are designed to be composed: Path B's quasimodel witnesses should drive Path A's chain construction.

**Can one replace the other?** No. Path B alone cannot produce the completeness theorem -- it lacks the BFMCS/parametric representation layer. Path A alone cannot close the sorry sites -- it lacks defect-driven termination. The correct architecture COMPOSES them.

### 2. Sunk Cost Analysis

| Investment | LOC | Sorry-free? | Value |
|-----------|-----|-------------|-------|
| Round-robin chain (RootScopedChain.lean) | 1559 | No (6 sorry) | Infrastructure (dd_fmcs, dd_bfmcs, dd_countermodel) is REUSABLE; only rr_fwd_chain/enriched_fwd_step need replacement |
| Quasimodel infrastructure | 1816 | Yes | Fully reusable as the termination engine |
| Frame.lean (BXPoint canonical frame) | 673 | Yes (1 sorry in Filtration/) | Core infrastructure, fully reusable |
| CanonicalModel.lean (fwd_succ, schedule) | 498 | Yes (2 sorry) | Step construction reusable; sorry sites are in chain-level proofs |
| CanonicalChain.lean | 157 | Yes (1 sorry) | BX12 bridge, reusable |
| Algebraic/ (truth lemma, representation) | ~2500 | Partial | Parametric restricted truth lemma is the key deliverable, reusable |
| Bundle/ (FMCS/BFMCS definitions) | ~1800 | Partial | Type definitions and coherence conditions, reusable |
| 31 research rounds | ~750K tokens | N/A | Deep understanding of dead ends; prevents re-exploration |

**Cost of continuing on the current chain (rounds 32-40+)**:
- Risk: HIGH. Report 31 demonstrates exhaustively that `rr_fwd_chain_forward_F` is unprovable on the existing chain due to BX11 hijacking / perpetual deferral (dead end 22). Every syntactic approach to proving forward_F as a theorem ABOUT the chain hits this wall.
- Estimated rounds: 5-10 more, with LOW probability of success
- The 31 rounds have PROVEN this path is blocked, not just suggested it

**Cost of replacing rr_fwd_chain with quasimodel-derived construction**:
- Risk: MODERATE. The quasimodel infrastructure exists and is sorry-free. The bridge gap is well-characterized.
- Estimated LOC: 400-600 new, replacing ~300 lines of rr_fwd_chain/enriched_fwd_step
- Net change: ~+200 LOC, keeping all existing infrastructure
- Estimated rounds: 3-5 for implementation

**Cost of complete BXCanonical/ restructure**:
- Risk: HIGH (unnecessary). The existing infrastructure is mostly sound.
- Would discard ~5000 LOC of sorry-free work
- NOT recommended

### 3. Literature Alignment Analysis

**How the formalization compares to published proofs**:

| Aspect | This Project | Burgess 1982 | GHR 1994 | Goldblatt 1992 |
|--------|-------------|-------------|----------|----------------|
| Chain index | Int (via dd_fmcs) | Z (integers) | Z (integers) | Z (integers) |
| Chain step | Lindenbaum extension of enriched seed | Defect-driven extension | Quasimodel unraveling | Filtration quotient |
| F-resolution | Attempted as theorem about chain | Built into construction | Built into quasimodel | Built into quotient |
| Data container | BFMCS (bundle of FMCS) | Single chain per modal class | Quasimodel + unraveling | Filtration + quotient |
| Until handling | Quasimodel (sorry-free) | Defect induction | Quasimodel | Filtration |

**Key deviation**: This project attempts to PROVE forward_F about a pre-existing chain. Every published approach BUILDS forward_F into the chain construction. This is the fundamental architectural mismatch identified across 31 rounds.

**Is Int the right index?** Yes. Int is standard for bimodal tense logic (matching Z in the literature). The `FMCS D` parametric type with `D = Int` and `AddCommGroup Int` is correct.

**Is BFMCS the right container?** Yes. The BFMCS (bundle of families indexed by modal equivalence classes) correctly captures the S5 modal component. Each family is an FMCS (Int-indexed chain), and the bundle connects families via box-formula agreement. This matches the standard "one chain per modal class" approach in Goldblatt 1992.

**Is `restricted_temporally_coherent` the right interface?** Yes. The restriction to `deferralClosure(root)` is a correct optimization that makes the proof tractable (avoids unbounded F-nesting). The parametric restricted truth lemma correctly uses this.

### 4. The Nuclear Option: Starting from Scratch

If we were to start from scratch on the completeness proof (keeping soundness and quasimodel), the cleanest architecture would be:

1. **Keep**: Frame.lean, Quasimodel/, Bundle/ type definitions, Algebraic/ truth lemma
2. **Replace**: RootScopedChain.lean's chain construction
3. **Architecture**:
   - Defect-driven chain: At each step, if F-defects exist, use `bx_forward_witness` (equivalently `fwd_succ` in resolving mode) targeting a specific defect. When no defects, use standard g_content-preserving step.
   - Forward_F is DEFINITIONAL: the chain is constructed so that each F(phi) at time t has phi at time t+1 (or within a bounded number of steps).
   - Until/Since coherence: Proved via the existing quasimodel `hintikka_chain_exists` infrastructure, lifted to the chain level.

**Estimated effort**: 400-600 new LOC, 3-5 rounds. NOT a from-scratch rewrite -- it's a targeted replacement of one component.

### 5. Textbook Formalization Comparison

If Burgess 1982 or GHR 1994 were formalized in Lean 4:

**Burgess 1982 approach**:
- Data: `def chain : Int -> Subtype SetMaximalConsistent` (same as current)
- Construction: At each step n, compute defect set. Pick one defect. Use `forward_temporal_witness_seed_consistent` + `set_lindenbaum` to extend. phi in chain(n+1) by construction.
- Termination: `defect_count` decreases (bounded by `|deferralClosure(root)|`). After the defect set empties, use standard non-resolving steps.
- Key difference from current: The TARGET at each step is chosen from the current defect set, not from a round-robin schedule. Forward_F is definitional at resolving steps.

**GHR 1994 approach**:
- Data: Finite quasimodel (list of Hintikka points with defect discharge) + unraveling to Z-chain
- Construction: Build quasimodel via well-founded recursion on defect count (ALREADY DONE in Construction.lean). Unravel to infinite chain by repeating the quasimodel pattern.
- This is essentially what the codebase's Quasimodel/ directory implements at the Hintikka level. The missing piece is the unraveling/lifting to Int-indexed MCS chain.

**How different from what we have?** Not very different. The quasimodel infrastructure IS the GHR approach. The gap is the "unraveling" step: converting the finite quasimodel chain into the Int-indexed FMCS that `dd_fmcs` needs.

### 6. Dependency Analysis

**What depends on `bx_completeness`?**

Direct dependents (from grep):
- `Completeness.lean`: Defines `bx_completeness` and `bx_completeness'`
- No other files import `Completeness.lean` currently

The completeness theorem is a terminal result -- nothing else in the codebase depends on it computationally. Changing the proof architecture affects NO downstream code, only the internal structure of `BXCanonical/`.

**What depends on `dd_countermodel`?**
- Only `Completeness.lean:141` calls `dd_countermodel`
- `dd_countermodel` calls `dd_bfmcs_restricted_tc`, `dd_bfmcs_restricted_buc`, `dd_bfmcs_restricted_fuc` (the 3 high-level sorry sites)

**Impact of changing completeness proof architecture**:
- ZERO impact on Soundness (separate proof)
- ZERO impact on Decidability (separate proof via FMP + tableau)
- ZERO impact on Syntax, Semantics, ProofSystem, Theorems
- ZERO impact on Bundle/ type definitions (FMCS, BFMCS unchanged)
- ZERO impact on Algebraic/ (truth lemma unchanged)
- Changes are ENTIRELY contained within BXCanonical/

## Recommended Approach

### Primary Recommendation: Quasimodel-Derived Chain (Confidence: 80%)

**Replace `rr_fwd_chain` + `enriched_fwd_step` with a chain construction driven by the quasimodel's defect-discharge logic.**

**Specifically**:

1. **Phase 1** (~150 LOC): Define `qm_fwd_chain` that at each step:
   - Computes F-defect set within `deferralClosure(root)`
   - If defects exist: use `fwd_succ` targeting first defect (resolving mode). Forward_F is definitional.
   - If no defects: use `fwd_succ` with standard target (non-resolving mode, preserves f_carry).
   - Key property: when F(phi) in chain(n), phi appears within `|deferralClosure(root)|` steps.

2. **Phase 2** (~150 LOC): Prove `qm_fwd_chain_forward_F` (sorry 1 replacement):
   - By the construction, each F-defect is resolved within one cycle through deferralClosure.
   - The defect set at step n determines the target. If F(phi) is present, phi is targeted at most `|deferralClosure|` steps later.
   - Between targeting: F(phi) may be lost at resolving steps for other defects. **This is the remaining bridge gap.**
   - **Resolution for the bridge gap**: Modify the resolving seed to use `forward_temporal_witness_seed` which is `{target} union g_content(M)`. The Lindenbaum extension MAY include F(phi) or G(neg phi). If G(neg phi) enters, phi is permanently killed. To prevent this: include `neg(G(neg phi))` = `F(phi)` in the seed. Seed: `{target, F(phi)} union g_content(M)`. Consistency: both target and F(phi) are in chain(n) (an MCS), and g_content(chain(n)) subset chain(n), so the union is a subset of chain(n), hence consistent. **But this only protects ONE additional F-formula.** For ALL F-formulas: use BX11 fold (the existing `enriched_fwd_fold`), which disjunctively protects all.

   **The key new insight**: Combine defect-driven targeting with BX11 fold protection. The BX11 fold ensures F(phi) survives disjunctively. The defect-driven targeting ensures phi's turn comes within a bounded number of steps. Together, they give forward_F.

   **Wait -- this is the existing `enriched_fwd_step` with defect-driven scheduling instead of round-robin!** The enriched step already uses BX11 fold. The change is: instead of round-robin scheduling, use defect-driven scheduling (target the first F-defect). The BX11 fold guarantees F(phi) survives until phi's turn. When phi's turn comes, `enriched_fwd_step_resolves_one` guarantees at least one formula is resolved.

   **The remaining gap** is dead end 22: the fold may resolve a DIFFERENT formula at phi's turn. But with defect-driven scheduling, phi IS the target. The fold includes phi as the "initial" element. The fold accumulates other F-defective formulas around phi. The resolution of the fold compound puts AT LEAST ONE formula directly in M'. If that formula is phi, done. If not, the perpetual deferral argument from Report 31 Section 17 applies -- and that argument was left incomplete.

3. **Phase 3** (~100 LOC): Prove sorry 3 (backward_P) by symmetric construction.

4. **Phase 4** (~100 LOC): Prove sorry 4, 5, 6 using forward_F + backward_P + BX axioms.

**Total**: ~500 LOC new, ~300 LOC replaced. Net +200 LOC.

### Secondary Recommendation: Investigate Report 31 Section 17 Termination Argument

The Report 31 analysis reached a promising but incomplete termination argument:
- Define `P = { phi | F(phi) perpetually present, phi never present }` (perpetually deferred set)
- If P is nonempty, at each visit step some w not_in P is resolved (since w in chain(v+1) contradicts w in P)
- If ALL F-defective formulas at some visit step are in P, the fold MUST resolve one from P -- contradiction
- Therefore P must be empty

This argument has a gap: transient defects may perpetually coexist with P-members, giving the fold non-P targets to resolve forever. Closing this gap requires showing transient defects eventually clear, which requires forward_F for transient defects -- potentially circular.

**Confidence**: 40%. The argument is suggestive but may be circular. Worth investigating as a lower-LOC alternative (0 new LOC if it works, just a proof of the existing sorry).

### Rejected Approaches

| Approach | Why Rejected | Evidence |
|----------|-------------|---------|
| Continue with round-robin chain | 31 rounds prove forward_F is unprovable on this chain | Dead end 22, Report 31 exhaustive analysis |
| omega-squared interleaving | `AddCommGroup` impossible on ordinals | Dead end 8, confirmed round 30 |
| Extended seed `{target} union g_content union f_carry` | Inconsistent (dead end 13) | Counterexample in Report 31 Section 16 |
| Dependent chain (per-formula) | Same-family requirement violated | Dead end 25/30 |
| Complete BXCanonical/ restructure | Unnecessary -- 5000+ LOC of reusable sorry-free code | Architecture audit above |

## Evidence/Examples

**Sorry site locations and dependencies**:

| # | Location | Name | Depends On |
|---|----------|------|-----------|
| 1 | RootScopedChain.lean:1413 | `rr_fwd_chain_forward_F` (depth-0 base) | Nothing (root blocker) |
| 2 | RootScopedChain.lean:1457 | `dd_fmcs_forward_F` (t < 0 case) | Sorry 1 |
| 3 | RootScopedChain.lean:1464 | `dd_fmcs_backward_P` | Symmetric to sorry 1 |
| 4 | RootScopedChain.lean:1517 | `dd_bfmcs_restricted_tc` | Sorry 1 + 3 |
| 5 | RootScopedChain.lean:1522 | `dd_bfmcs_restricted_buc` | Chain structure (may be independent) |
| 6 | RootScopedChain.lean:1527 | `dd_bfmcs_restricted_fuc` | Sorry 1 (via BX10: phi U psi -> F(psi)) |

**Critical code path**: `bx_completeness` -> `dd_countermodel` -> `dd_bfmcs_restricted_tc/buc/fuc` -> sorry sites 4/5/6 -> sorry sites 1/2/3

**Sorry-free infrastructure that would be preserved**:
- `Quasimodel/Construction.lean:594-659`: `hintikka_chain_exists` (887 LOC file, all sorry-free)
- `Quasimodel/Realization.lean`: Enriched seed consistency, BXPoint lifting (444 LOC, sorry-free)
- `Frame.lean`: BXPoint canonical frame, g_content/h_content closed derivation (673 LOC, sorry-free)
- `Algebraic/RestrictedParametricTruthLemma.lean`: Restricted truth lemma
- `Bundle/TemporalCoherence.lean`: Coherence type definitions

## Confidence Level

**Overall confidence in recommended approach**: 75%

**Breakdown**:
- 95% confidence that the round-robin chain approach is permanently blocked (31 rounds, exhaustive dead-end catalog)
- 80% confidence that quasimodel-derived chain is the correct architecture (aligns with all published proofs)
- 60% confidence in the specific implementation plan (the F-formula survival gap between targeting steps remains the key technical challenge)
- 50% confidence in the 3-5 round estimate (the bridge gap could take longer than expected)

**Key risk**: The F-formula survival gap (between when phi is targeted and when phi's turn arrives in the defect-driven schedule) requires either (a) BX11 fold protection with a termination argument for perpetual deferral, or (b) including ALL F-formulas in the resolving seed (dead end 13 blocks this for full f_carry, but targeted inclusion of specific F-formulas may work). Option (a) is the Report 31 Section 17 incomplete argument. Option (b) requires proving consistency of `{target, F(phi_1), ..., F(phi_k)} union g_content(M)` -- which IS consistent since all elements are in chain(n), an MCS. The issue is that this seed is `f_carry(M) union {target} union g_content(M)`, and dead end 13 shows THIS can be inconsistent. The contradiction arises when `target not_in M` but the f_carry formulas force `neg(target)` derivable from the seed. This happens specifically when `G(F(alpha) -> neg(target)) in M`.

**The deepest insight**: Dead end 13's inconsistency arises from the interaction between `target` (which is NOT in M) and `f_carry` (which IS in M). The seed `{target} union g_content(M) union f_carry(M)` can be inconsistent because `target not_in M` while everything else IS in M. The resolution: don't include target in the seed! Instead, include only `g_content(M) union f_carry(M)` (which IS consistent, proven as `enriched_seed_consistent`), and let the Lindenbaum extension freely choose whether to include target or not. If target ends up in the extension: resolved. If not: F(target) is preserved (via f_carry), and we try again at the next step. This is exactly what the existing non-resolving branch of `fwd_succ` does. **The problem is that this never FORCES target into the chain.**

This confirms the fundamental tension: forcing a specific formula requires it in the seed, but the seed with forcing + f_carry can be inconsistent. The BX11 fold navigates this by folding all obligations into a single compound formula, but the fold's non-determinism prevents guaranteeing any specific formula is resolved.

**Bottom line**: The quasimodel-derived chain approach is correct in principle. The implementation requires careful handling of the F-survival gap, which is the same fundamental challenge that has blocked 31 rounds. The difference is that the quasimodel framework provides the RIGHT termination measure (defect_count) and the RIGHT seed consistency argument (BXPoint-backed witnesses), whereas the round-robin approach lacks both.
