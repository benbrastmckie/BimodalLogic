# Research Report: Task #93

**Task**: 93 - Close TaskModel embedding sorry (sole remaining active-path sorry)
**Date**: 2026-04-15
**Mode**: Team Research (4 teammates)

## Summary

Four teammates independently analyzed the recommended approaches from the v17 implementation summary. The team converges on a critical finding: **Strategy C (direct witness contradiction on the existing chain) is mathematically invalid at 10-20% confidence, down from the prior 60% estimate.** Permanent BX11 displacement of a formula is semantically impossible (on integer models, F(ψ) at every time forces ψ at infinitely many times), but is syntactically consistent with the chain construction because `.choose` in Lindenbaum extension is unconstrained. The forward_F sorry is a genuine mathematical gap in the chain definition — not in the proof architecture, which is sound.

The most viable long-term path is a **modified chain construction** that controls the Lindenbaum choice to guarantee target resolution, accepting the ~30 theorem re-proof cost. Teammate D identifies a "never-resolved count" termination measure as the most promising approach for an ordered-discharge chain.

## Key Findings

### Primary Approach (from Teammate A)

All three recommended approaches from the implementation summary have serious obstacles:

1. **Approach A (target-prioritized fold)**: Reduces the multi-step fold Case 3 problem to a single BX11 application (target vs compound), but the obstruction persists — the final BX11 between target and compound can still fire Case 3, giving `F(target) ∈ M'` instead of `target ∈ M'`. **Confidence: 35%.**

2. **Approach B (iterative refinement)**: Mathematically sound (Lindenbaum can always extend `{ψ} ∪ g_content(M)` consistently), but requires chain redefinition. **Confidence: 20%.**

3. **Approach C (different chain with discharge_single_step)**: Fatal F-propagation gap — at non-target resolving steps, Lindenbaum can add `G(¬ψ)`, permanently killing `F(ψ)`. Same core gap relocated. **Confidence: 10%.**

All three Strategy C attack vectors fail:
- **Vector A (visit-step)**: Permanent displacement is consistent with BX axioms; cycling displacing formulas yield no contradiction.
- **Vector B (pigeonhole)**: Resolution is non-monotone; resolved formulas can become defects again.
- **Vector C (discharge_single_step)**: Architecturally impossible — chain already defined with `enriched_fwd_step`.

### Alternative Approaches (from Teammate B)

Literature review confirms all standard completeness proofs (Burgess 1984, Goldblatt 1992, Gabbay-Hodkinson-Reynolds 1994) handle forward_F semantically. No published proof addresses this syntactically. Seven novel approaches analyzed (Approaches 20-26), none clearly superior. The most interesting is **Approach 21 (Until reformulation via BX12)**: `F(ψ) → ⊤ U ψ` by BX12, then leverage proved `bx_until_eventuality_resolution`. Obstacles: produces abstract BXPoints not chain indices; `⊤ U ψ` may not be in `deferralClosure(root)`. Confidence: 20%.

The **precise semantic-syntactic gap**: In semantic proofs, F-witnesses have well-ordered temporal structure inherited from the integers. In the syntactic construction, each Lindenbaum extension is an independent `.choose` call unconstrained by future requirements. The chain construction lacks the "eventual completeness" that integer models provide.

### Gaps and Shortcomings (from Critic)

**The definitive negative result**: Permanent BX11 displacement is **syntactically consistent** with the chain construction.

Concrete scenario (σ_list = [ψ, χ]):
- At every visit step for ψ: BX11 Case 3 fires, χ displaces ψ. χ ∈ M', ψ ∉ M'.
- At visit steps for χ: χ may be resolved. F(χ) persists by constancy.
- ψ is perpetually unresolved. No contradiction arises.

The `.choose` in `set_lindenbaum` is the source of non-determinism. The fold itself is deterministic given the MCS (BX11's 3-way disjunction resolves to exactly one case in each MCS). But the Lindenbaum extension can perpetually select the F(ψ) disjunct over the ψ disjunct.

**The f_carry seed is correctly dead.** The counterexample (`G(F(α) → ¬ψ) ∈ M`, `F(α) ∈ M`, `F(ψ) ∈ M`) is tight and no modification avoids it without a G-lift argument that is not derivable in BX.

**Overlooked structural fact**: The fold processes formulas in **list order**, creating systematic bias. If ψ appears later in σ_list than χ, and Case 3 fires for `(current_compound, χ)`, then χ consistently displaces the compound containing ψ. However, BX11 case outcomes depend on the MCS content, which changes between steps.

### Strategic Horizons (from Teammate D)

**Architecture is sound (95% confidence).** The forward_F problem is construction-level, not architectural. 6,400+ lines of sorry-free infrastructure are correct and reusable under any fix.

**Restructuring is NOT recommended (90% confidence).** Six alternative architectures evaluated (filtration, quasimodel, BX11-compatible enumeration, two-pass, compactness, Henkin-style); none viable without 30+ hour investments and uncertain outcomes.

**The "Any Choice Works" question**: Answer is **NO**. BX axioms do not force eventual resolution through arbitrary Lindenbaum choices. The fix MUST control the choice.

**Most promising fallback**: Modified ordered-discharge chain with **"never-resolved count"** termination measure: `|{χ ∈ S | χ has never appeared in any chain step up to n}|`. This count strictly decreases at each step (at least one formula is newly resolved) and S is finite, guaranteeing termination. Requires threading a global invariant through the recursion. **Confidence: 55-65%**, but requires chain replacement (~30 theorem re-proofs).

## Synthesis

### Conflicts Resolved

| Conflict | Teammate A | Teammate B | Teammate C | Teammate D | Resolution |
|----------|-----------|-----------|-----------|-----------|------------|
| Strategy C confidence | 5% (vectors), 35% (approach A) | 55-60% | 10-15% | 35-40% | **15-20%** — Teammate C's concrete counterexamples are dispositive. B's higher estimate reflects optimism about the "open question" without addressing C's counterexample. |
| Chain replacement cost-benefit | Recommends with reluctance | Recommends Strategy C first | Necessary (the only viable option) | Recommends Strategy C first, then chain replacement | **Strategy C first (5h cap), then chain replacement** — consensus on try-then-pivot. |
| Most promising alternative | Approach A variant | Approach 21 (Until via BX12) | Option 3 (seed consistency) or Option 4 (tree of MCS) | Ordered-discharge with never-resolved count | **Ordered-discharge chain** — D's never-resolved count is the most concrete and mathematically grounded fallback. |

### Gaps Identified

1. **The "never-resolved count" approach needs validation.** D proposes `|{χ ∈ S | χ never appeared in chain steps 0..n}|` as a termination measure. This is promising but unvalidated: threading this global invariant through the chain recursion requires careful Lean formalization. The key question: can we define the chain and prove the invariant simultaneously, or does the invariant create a circular dependency with the chain definition?

2. **Approach 21 (Until reformulation) deserves deeper investigation.** The proved `bx_until_eventuality_resolution` is tantalizing. The obstacles (abstract BXPoint vs chain index) might be addressable by defining the chain step to use the BXPoint witness directly.

3. **No teammate analyzed whether `enriched_fwd_step`'s BX11 fold could be MODIFIED** to guarantee target resolution in a subset of cases sufficient for forward_F. For example: if the fold processes target LAST (instead of FIRST), then target enters Case 1 or Case 2 of BX11 (never Case 3, since it's the right operand). This would give `target ∈ M'` deterministically. **This warrants investigation.**

### Recommendations

**Immediate (5 hours max)**: Attempt Strategy C one final time, focusing on whether the **fold processing order** can be exploited. If target is processed last in the BX11 fold, Case 3 cannot fire for target (Case 3 puts the LEFT operand under F, not the right). This is a variant of Approach A but potentially much simpler — it may only require reordering the fold's argument list.

**Fallback (15-20 hours)**: Implement ordered-discharge chain with "never-resolved count":
1. Redefine `enriched_fwd_step` to use `discharge_single_step` for the target while preserving F-obligations via a separate mechanism
2. Define chain with explicit "never-resolved" tracking
3. Prove forward_F via well-founded induction on never-resolved count
4. Re-prove ~30 downstream theorems (mostly mechanical, leveraging existing infrastructure)

**Strategic**: Accept that chain redefinition is likely necessary. Budget 15-20 hours. The 6,400 lines of sorry-free infrastructure remain valid regardless.

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Primary approach analysis (Strategy C deep dive) | completed | Medium (35% for best approach) |
| B | Literature review and novel approaches | completed | Medium (55-60% for Strategy C, but see conflict resolution) |
| C | Critic — counterexamples and feasibility | completed | High (10-15% for Strategy C, strong evidence) |
| D | Horizons — long-term architecture | completed | High (95% architecture sound, 55-65% ordered-discharge) |

## References

### Key Source Files
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` — 6 sorry sites (lines 1275, 1306, 1313, 1366, 1371, 1376)
- `Theories/Bimodal/Metalogic/BXCanonical/OrderedSeedConsistency.lean` — Underutilized seed consistency proofs
- `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean` — `bx_until_eventuality_resolution` (proved, sorry-free)
- `Theories/Bimodal/ProofSystem/Axiom.lean` — BX axiom definitions

### Key Proved Infrastructure
- `enriched_fwd_step_preserves` — F-preservation disjunction
- `enriched_fwd_step_resolves_one` — At least one formula resolved per step
- `rr_fwd_chain_F_propagate` — Reduces forward_F to "cannot persist forever"
- `target_stays_direct_in_fold` — Deterministic when target is bx11_earlier than all others
- `forward_temporal_witness_seed_consistent` — One-step witness seed consistency
- `enriched_resolving_seed_consistent` — Ordered seed with protection
- `bx_until_eventuality_resolution` — Until eventuality resolution (abstract BXPoints)

### Literature
- Burgess 1984: Step-by-step construction, one formula per stage, semantic witness ordering
- Goldblatt 1992: Bulldozing technique, canonical frame → linear order
- Gabbay-Hodkinson-Reynolds 1994: Adequate sets, finite-signature Σ-MCS, König's lemma
- Xu 1988: Simplified axiomatization for Since-Until logic

### Prior Task 93 Artifacts Referenced
- Report 17: Round-robin chain history (19 failed approaches)
- Plan v17: Strategy C primary, 3 attack vectors
- Summary 17: Implementation blocked, 6 helpers proved, 7 approaches rejected
- Handoff 02: forward_F analysis, BX11 non-transitivity
- Report 16: 3-cycle counterexample, Strategy C proposal
