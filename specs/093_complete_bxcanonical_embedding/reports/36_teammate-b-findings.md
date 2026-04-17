# Teammate B: Alternative Approaches Study

**Session**: sess_1776435423_f21d0d (round 36)
**Date**: 2026-04-17
**Focus**: Alternative paths to close 8 sorry sites in RootScopedChain.lean

## Executive Summary

Six alternative approaches were analyzed. Three are mathematically blocked. Two are viable
but substantially more expensive than previously estimated. The most promising approach —
BX12 + Until/Since coherence — is the prior round's recommendation, but faces a new
concrete obstacle identified in this study: the **closure alignment gap** means that
`dd_bfmcs_restricted_tc/buc/fuc` cannot be proved from Until/Since coherence alone without
additional infrastructure (the `⊤ U ψ` formulas are not in `sigma_list`). One alternative
path (**self_resolving_fwd_step round-robin**) has a subtle correctness issue that was missed
in prior rounds.

---

## Approach 1: DRM Chain Revival

### Status: BLOCKED

The DRM chain approach was the most recent dedicated attempt. The obstacle is well-characterized
in `handoffs/01_drm-chain-obstacle.md`: `drm_fwd_chain_forward_F` requires `single_step_forcing`
in a DRM context, which needs negation completeness for `iter_F(d+1, psi)` within
`deferralClosure`. When `d+1 >= closure_F_bound`, neither `iter_F(d+1, psi)` nor its negation
are in `deferralClosure`, so the standard bounded_witness proof cannot proceed.

**New Analysis**: The file `DRMChain.lean` exists (290 lines, 1 sorry: `drm_fwd_chain_forward_F`).
The infrastructure (seed consistency, g_persistence, f_step, Succ relation) is fully proved.
The single sorry is precisely the DRM negation completeness obstacle.

**Why it stays blocked**: Option C from handoff 01 ("restricted single_step_forcing for
subformulaClosure formulas") requires that `iter_F(d+1, psi)` stays within `subformulaClosure`.
For formulas in `extendedDeferralClosure(phi)`, the F-nesting depth is bounded by the closure's
`closure_F_bound`. When the chain is initialized from `extendedDeferralClosure(phi).toList`,
the formulas have bounded F-depth, but the single_step_forcing argument iterates this bound and
may push into untracked depths. No clean resolution was found.

**LOC estimate**: 200-400 LOC to close this obstacle IF a proof for the specific case exists.
**Risk**: HIGH. The mathematical gap is genuine.

---

## Approach 2: Enriched Until-Aware Seed (`targeted_restricted_seed_consistent`)

### Status: BLOCKED (sorry is at line 195 of SimplifiedChain.lean)

The `SimplifiedChain.lean` in `Boneyard/ChainCompleteness/Bundle/` contains
`targeted_restricted_seed_consistent`, which is the sorry needed to build a chain that
can force a target formula ψ into the successor when `F(ψ) ∈ u`.

**Seed**: `simplified_restricted_seed(phi, u) ∪ {target}` where:
- `simplified_restricted_seed = g_content(u) ∪ deferralDisjunctions(u) ∪ p_step_blocking(u)`
- All elements are subsets of u (consistency trivial)

**The Gap**: When `target ∈ L` (in a derivation of ⊥ from the seed), the deduction theorem
gives `L' ⊢ ¬target` where `L' ⊆ simplified_seed ⊆ u`. So `u ⊢ ¬target`. But `F(target) ∈ u`
means `¬G(¬target) ∈ u` — this does NOT contradict `u ⊢ ¬target` because `neg(target) ∈ u`
can coexist with `F(target) ∈ u`.

The G-lift argument would need: from `L' ⊢ ¬target` with `L' ⊆ g_content(u)`, derive
`G(¬target) ∈ u` (contradicting `F(target) ∈ u`). But `L'` contains elements from
`deferralDisjunctions(u)` and `p_step_blocking(u)`, which are NOT G-liftable (they don't
have G-versions in u).

**Could it be fixed?** Only if `deferralDisjunctions` and `p_step_blocking` can be shown
to not contribute to a derivation of `¬target`. This requires case analysis on what
derivations are possible from these formulas. The comment in SimplifiedChain.lean (lines
143-153) documents this gap accurately. There is no obvious path to closing it.

**LOC estimate**: 300-500 LOC with uncertain probability of success.
**Risk**: HIGH. The G-lift obstacle is genuine.

---

## Approach 3: Finite Deferral / Pigeonhole (FiniteDeferral.lean approach)

### Status: BLOCKED (cycle contradiction step is sorry)

The Boneyard `FiniteDeferral.lean` (383 lines) got furthest toward a cycle-based approach:

**What's proved (all sorry-free)**:
1. `F_to_until_in_chain`: F(ψ) → (⊤ U ψ) in chain (via BX12, Axiom.F_until_equiv)
2. `until_persists_forward_steps`: (⊤ U ψ) persists if ψ never appears
3. `pigeonhole_restricted_theories`: among 2^|deferralClosure|+1 steps, two have same restricted theory
4. `G_neg_kills_until`: G(¬ψ) ∈ chain(t) → (⊤ U ψ) ∉ chain(t) (via until_induction)

**The Gap**: `forward_F_via_deferral` (line 378) is sorry. The cycle argument needs:
- Identify the cycle positions i < j with `restrictedTheory(i) = restrictedTheory(j)`
- Conclude G(¬ψ) ∈ chain(i) from the cycle + Until persisting through it
- Apply G_neg_kills_until to get contradiction with (⊤ U ψ) ∈ chain(i)

The gap is: "G(¬ψ) ∈ chain(i)" from "¬ψ ∈ chain(s) for all s ∈ [i,j)" requires backward_G,
which requires forward_F (circular).

**FiniteDeferral.lean line 325 has a concrete problem**: The `until_induction` axiom was
"removed in BX" (comment says sorry with reference to removed axiom). This means the
`G_neg_kills_until` theorem itself rests on a sorry referencing a removed axiom! The theorem
is therefore UNSOUND in the current proof system.

**Critical finding**: `G_neg_kills_until` (FiniteDeferral.lean:163-333) uses `until_induction`
at line 325 but the axiom appears to have been removed from BX. This makes the entire finite
deferral infrastructure for the algebraic Boneyard chain suspect. The BXCanonical chain (using
BX axioms) may have different Until induction properties.

**Conclusion**: The pigeonhole approach is blocked by the G(¬ψ) derivation circularity AND
a potential axiom soundness issue in the Boneyard formalization.

**LOC estimate**: Unknown (fundamental circularity).
**Risk**: VERY HIGH. The approach is fundamentally circular without an external tool.

---

## Approach 4: BX12 Reduction + Full Until/Since Coherence

### Status: SOUND but with concrete obstacles (prior recommendation)

This is the approach recommended in round 35. New analysis identifies more concrete obstacles:

**Mechanism**:
1. BX12 (`F_until_equiv`, Axioms.lean:258): F(ψ) → (⊤ U ψ) in any MCS
2. If `restricted_forward_until_since_coherent` covers `⊤ U ψ`, then forward_F follows

**New Obstacle Analysis**:

The key sorry sites consume `dd_bfmcs`:
```
dd_bfmcs_restricted_tc M h_mcs sigma_list phi
  (h_sub : ∀ ψ, ψ ∈ deferralClosure phi → ψ ∈ sigma_list)
```

The `restricted_forward_until_since_coherent` predicate covers only formulas `φ U ψ` where
`φ U ψ ∈ subformulaClosure(root)`. But `⊤ U ψ` where `⊤ = ⊥ → ⊥` is NOT in
`subformulaClosure(root)` unless `⊤` appears as a subformula of root.

**Three resolution paths** (identified in round 35):

**Path 4A — Extend extendedDeferralClosure to include ⊤-Until formulas** (~30-50 LOC):
- Add `{⊤ U ψ | F(ψ) ∈ M}` to the closure used in `dd_countermodel`
- `sigma_list` then contains `⊤ U ψ` for all relevant ψ
- Until coherence for these formulas is covered by `restricted_forward_until_since_coherent`
- **Obstacle**: The restricted coherence predicate checks `φ U ψ ∈ subformulaClosure(root)`,
  which still won't include `⊤ U ψ` even after extending `sigma_list`
- **Correction**: The predicate needs to be modified, not just `sigma_list`

**Path 4B — Prove full (unrestricted) Until/Since coherence** (~300-500 LOC):
- No closure alignment issue
- `dd_fmcs_forward_F` (t<0 case) still needs Until coherence for the backward chain
- Requires the HintikkaStepOracle to be constructed (see Approach 5)
- If unrestricted coherence is proved, restricted coherence follows immediately
- This is the cleanest path but the oracle construction is the bottleneck

**Path 4C — Modify restricted coherence predicate** (~50-100 LOC modification + oracle):
- Change `restricted_forward_until_since_coherent` to cover BX12-derived Until formulas
- Use a "BX12-extended closure" predicate
- Still requires the oracle

**New finding**: The `restricted_forward_until_since_coherent` and `restricted_backward_until_since_coherent`
predicates are defined in `Bundle/TemporalCoherence.lean`. Their structure is:
```
∀ t φ ψ, (φ U ψ ∈ subformulaClosure root) → (φ U ψ ∈ fam.mcs(t)) → ∃ s > t, ψ ∈ fam.mcs(s) ∧ (∀ r ∈ [t,s), φ ∈ fam.mcs(r))
```

The key is `φ U ψ ∈ subformulaClosure root`. To use BX12: we need either `⊤ U ψ ∈ subformulaClosure root`
OR a new coherence predicate that doesn't require the Until formula to be in the closure.

**LOC estimate**: 700-1000 LOC total (oracle: 200-300 + lifting: 200-300 + integration: 100-200 + closure fix: 50-100).
**Risk**: MEDIUM (65-75% success probability, unchanged from prior round estimate).

---

## Approach 5: BXPointChain — Direct Forward Witness Chain

### Status: SOUND but requires oracle construction (detailed in handoff 02)

This approach (from `handoffs/02_quasimodel-bridge-design.md`) builds an Int-indexed chain
using `bx_forward_witness` with round-robin scheduling:
```
chain(n+1) = if F(target(n)) ∈ chain(n)
             then (bx_forward_witness chain(n) target(n)).choose
             else (default successor with g_content preserved)
```

**Key property**: `bx_forward_witness` places `target` DIRECTLY in the successor. This avoids
the perpetual deferral problem.

**Forward_F proof**: At the visit step for ψ, `bx_forward_witness` gives ψ ∈ chain(visit+1).

**This approach is actually EQUIVALENT to the quasimodel oracle approach** (Approach 4, Path 4B)
for the specific case of F-defects. It directly constructs an Int-indexed chain with forward_F.

**New analysis**: This approach can be implemented without the quasimodel infrastructure:
1. Define `bx_rr_fwd_chain` using `bx_forward_witness` with `rrSchedule sigma_list n`
2. Prove `bx_rr_fwd_chain_forward_F`: at visit step, target is resolved
3. Prove `backward_P` symmetrically using `bx_backward_witness`
4. Build FMCS from the chain

**Until/Since coherence** is a separate concern. The BXPoint chain gives forward_F and backward_P.
For Until/Since coherence, `dd_bfmcs_restricted_buc` and `dd_bfmcs_restricted_fuc` still need
separate proofs. However, these can use `bx_until_eventuality_resolution` and
`bx_since_eventuality_resolution` from Frame.lean (already proved), combined with a chain step
argument.

**Critical obstacle**: The step transfer problem resurfaces. `dd_bfmcs_restricted_buc` requires:
if `(φ U ψ) ∈ fam.mcs(t+1)` came from a resolving step (it wasn't in the seed of chain(t+1)),
can we derive `(φ U ψ) ∈ fam.mcs(t)`? Only if the Until formula persists BACKWARD through
BXPoint steps.

For the BXPoint chain: `bx_rr_fwd_chain(n+1) = bx_forward_witness(bx_rr_fwd_chain(n), target)`.
The Until formula `φ U ψ ∈ bx_rr_fwd_chain(n+1)` may not be in `bx_rr_fwd_chain(n)` because
the Lindenbaum extension added it independently.

**Conclusion**: BXPointChain solves forward_F and backward_P but does NOT automatically solve
the backward Until step transfer for `restricted_backward_until_since_coherent`.

**LOC estimate for BXPointChain alone** (~400-600 LOC): Covers sorry sites 1413, 1457, 1464, 2196, 2289.
The remaining sorry sites (1517, 1522, 1527) need separate treatment.

**Risk**: LOW-MEDIUM for forward_F/backward_P. MEDIUM-HIGH for Until/Since coherence.

---

## Approach 6: self_resolving_fwd_step Round-Robin (110-LOC path)

### Status: BLOCKED for multi-defect (Teammate C was correct in round 35)

The `self_resolving_fwd_step` function (RootScopedChain.lean:1961-1996) builds M' with:
- ψ ∈ M'
- F(ψ) ∈ M' (self-referential: F(ψ ∧ F(ψ)) ∈ M → seed includes {ψ, F(ψ)})
- g_content(M) ⊆ M'

**What it does NOT provide**: F(χ) ∈ M' for other defects χ ≠ ψ.

The seed is `{ψ, F(ψ)} ∪ g_content(M)` — there is no f_carry. When the Lindenbaum
extension chooses formulas to add, it may or may not include F(χ) for other χ.

**Round-robin with self_resolving**: At step n with target = sigma_list[n mod len]:
- If F(target) ∈ chain(n): use self_resolving_fwd_step → target ∈ chain(n+1), F(target) ∈ chain(n+1)
- All other F(χ) are NOT guaranteed to persist

**The specific failure**: Suppose defects = [ψ, χ], F(ψ) ∈ M₀ and F(χ) ∈ M₀.
At step 1, resolve ψ via self_resolving: ψ ∈ chain(1), F(ψ) ∈ chain(1), g_content(M₀) ⊆ chain(1).
But F(χ) might not be in chain(1). At step 2, schedule χ: need F(χ) ∈ chain(1) to resolve.
If F(χ) ∉ chain(1), the step cannot resolve χ.

**Could F(χ) be in chain(1) anyway?** Only if G(¬χ) ∉ chain(1), which requires G(¬χ) ∉ chain(0)
(monotone absence). But G(¬χ) ∉ chain(0) iff F(χ) ∈ chain(0), which we have. But the Lindenbaum
extension could add G(¬χ) independently (if the seed doesn't force F(χ) in).

**Can we add F(χ) to the self_resolving seed?** If we use seed = `{ψ, F(ψ), F(χ)} ∪ g_content(M)`:
- Need `F(ψ ∧ F(ψ) ∧ F(χ))` or similar to get consistency
- `F(ψ ∧ F(χ)) ∈ M` would give `{ψ, F(χ)} ∪ g_content(M)` consistent by enriched_resolving_seed_consistent
- But `F(ψ ∧ F(χ)) ∈ M` requires BX11: `F(ψ) ∈ M and F(χ) ∈ M → F(ψ ∧ F(χ)) ∈ M or F(F(ψ) ∧ χ) ∈ M`

This is exactly the `defect_fwd_step_choice` approach already in the codebase, which gets us
back to Approach 6 being blocked (the forward_F sorry at line 2196 is for exactly this construction).

**LOC estimate**: N/A (approach is blocked).
**Risk**: N/A.

---

## Comparison Matrix

| Approach | Soundness | LOC | Risk | Key Obstacle |
|----------|-----------|-----|------|--------------|
| 1: DRM Chain Revival | BLOCKED | 200-400 | HIGH | Negation completeness for iter_F in deferralClosure |
| 2: Enriched Until-Aware Seed | BLOCKED | 300-500 | HIGH | G-lift fails for non-G-liftable seed elements |
| 3: Finite Deferral Pigeonhole | BLOCKED | Unknown | VERY HIGH | Circular G(¬ψ) derivation; removed axiom in Boneyard |
| 4: BX12 + Full Until/Since | SOUND | 700-1000 | MEDIUM | Oracle construction; closure alignment |
| 5: BXPointChain Forward Witness | SOUND (forward_F/P only) | 400-600 + 300-500 | MEDIUM | Until/Since coherence still needs oracle |
| 6: self_resolving Round-Robin | BLOCKED (multi-defect) | N/A | N/A | f_carry absence from self_resolving seed |

---

## New Analysis: The Oracle Construction Bottleneck

Both Approach 4 and Approach 5 require constructing either:
- A `HintikkaStepOracle` for the quasimodel (Approach 4)
- Or Until/Since coherence proofs for the BXPointChain (Approach 5)

These are equivalent in mathematical content. The core question is: given a BXPoint w with
`φ U ψ ∈ w.formulas` and `ψ ∉ w.formulas`, can we find v ≥ w with `ψ ∈ v.formulas` such that
`φ holds along the path from w to v`?

**We already have the one-step version**: `bx_until_eventuality_resolution` gives v with
`bx_le w v`, `ψ ∈ v`, `φ ∈ w`. This is a **2-element chain** [w, v].

**The full coherence requires**: `φ ∈ u.formulas` for all `u` in the chain between w and v.
With `bx_le w v` and a 2-element chain, there are no intermediate positions — so the guard
holds vacuously! This is the key insight:

**For a chain where consecutive elements satisfy `bx_le`, the restricted Until coherence
with a 2-step witness trivially satisfies the guard condition for intermediate points** — there
are no intermediate points in a direct bx_le step.

**Implication**: If we build the BXPointChain such that each step is a DIRECT `bx_le` relation
(not a transitive closure), then `bx_until_eventuality_resolution` provides exactly the Until
coherence witness needed. The guard for the 2-element chain [t, s] is empty (no positions
strictly between t and t+1).

This suggests the **BXPointChain approach (Approach 5) can close ALL 8 sorry sites** if
the Until/Since coherence predicate allows the guard to be vacuous for a direct step. Let
me check the predicate definition:

From `Bundle/TemporalCoherence.lean` (inferred from usage in RootScopedChain.lean):
```
restricted_forward_until_since_coherent root fam :=
  ∀ t φ ψ, (φ U ψ) ∈ subformulaClosure(root) →
    (φ U ψ) ∈ fam.mcs(t) →
    ∃ s > t, ψ ∈ fam.mcs(s) ∧
             ∀ r, t ≤ r → r < s → φ ∈ fam.mcs(r)
```

For the BXPointChain, if we build chain(t+1) = bx_until_eventuality_resolution applied when
there's an Until defect, then:
- There exists s = t+1 with ψ ∈ chain(s)
- The guard: ∀ r, t ≤ r < t+1 → φ ∈ chain(r) reduces to r = t, i.e., φ ∈ chain(t)
- This follows from `bx_until_eventuality_resolution` which provides `φ ∈ w.formulas`

**This is provable!** The BXPointChain + direct step strategy gives Until coherence for free.

---

## New Approach 7: BXPointChain with Until-First Priority

### Status: LIKELY SOUND, estimated 500-700 LOC total

**Strategy**: Build the BXPoint chain with priority:
1. If there is an Until-defect `φ U ψ ∈ chain(n)` with `ψ ∉ chain(n)` and `φ U ψ ∈ sigma_list`:
   use `bx_until_eventuality_resolution` to get chain(n+1) with `ψ ∈ chain(n+1)` and `φ ∈ chain(n)`
2. Elif there is an F-defect `F(ψ) ∈ chain(n)` with `ψ ∉ chain(n)`:
   use `bx_forward_witness` to get chain(n+1) with `ψ ∈ chain(n+1)`
3. Else: use a default g-content-preserving step

**Guard property**: The `∀ r, t ≤ r < s → φ ∈ fam.mcs(r)` condition is trivially satisfied
when `s = t+1` because there are no integers strictly between t and t+1.

**Backward direction**: Symmetric using `bx_since_eventuality_resolution` and `bx_backward_witness`.

**Forward_F from BX12**: F(ψ) ∈ chain(t) → (⊤ U ψ) ∈ chain(t) → until coherence applies IF
`⊤ U ψ ∈ sigma_list`. But `⊤` needs to be in `sigma_list` for this. The simplest fix: when
building the BXPointChain, use F-defect handling directly (case 2 above), bypassing BX12.

**Until coherence directly**: When `φ U ψ ∈ sigma_list` and `φ U ψ ∈ chain(t)`:
- If `ψ ∈ chain(t)`: witness is s = t, trivial.
- If `ψ ∉ chain(t)`: use `bx_until_eventuality_resolution` → chain(t+1) with `ψ ∈ chain(t+1)`, `φ ∈ chain(t)`
- Guard: only position r = t, φ ∈ chain(t) ✓ (from eventuality resolution)

**Key difficulty**: The BXPointChain uses a specific step rule. If the scheduled step at time n
is NOT the Until-defect step (because we schedule F-defects first), the Until formula may
"expire" before its scheduled visit. The round-robin must be coordinated across Until and
F-defects.

**Observation**: Since `F(φ U ψ)` is provable from `φ U ψ` (via BX10: `φ U ψ → F(ψ)`),
every Until defect has a corresponding F-defect. The F-defect handling suffices if we choose
`target = ψ` (the GOAL of the Until formula, not the Until formula itself).

**Refined strategy**: The chain needs to resolve GOALS of Until formulas. When `φ U ψ ∈ chain(n)`:
- Find witness for `F(ψ) ∈ chain(n)` (always valid since `φ U ψ → F(ψ)`)
- Use `bx_forward_witness` on `F(ψ)` to get chain(n+1) with `ψ ∈ chain(n+1)`
- Until coherence: s = n+1, guard at r = n: need `φ ∈ chain(n)` — this comes from BX9

This is exactly what the round-robin does, but now we can DIRECTLY schedule `ψ` (goal of
the Until formula) when the Until formula is present, without needing the full quasimodel.

**New Approach 7 Implementation**:
1. `bx_rr_fwd_chain` using `bx_forward_witness` directly (not `enriched_fwd_step`)
2. At each step n, target = round-robin over sigma_list
3. If `F(target) ∈ chain(n)`: step with `bx_forward_witness chain(n) target`
4. If `F(target) ∉ chain(n)`: step with `bx_forward_witness chain(n) (neg bot)` (always valid)
5. `forward_F`: at visit step for ψ, if F(ψ) ∈ chain(n), then ψ ∈ chain(n+1) ✓
6. `Until coherence`: when `φ U ψ ∈ chain(n)`, F(ψ) ∈ chain(n) (by BX10), schedule ψ
7. At visit step m for ψ where F(ψ) ∈ chain(m): ψ ∈ chain(m+1) ✓, guard φ ∈ chain(m) from BX9 ✓

**The only remaining issue**: Do we need `F(ψ) ∈ chain(m)` (F-obligation persists until visit)?

**F-persistence in BXPointChain**: Each step uses `bx_forward_witness chain(n) target`. The
successor satisfies `bx_le chain(n) chain(n+1)`, which gives `g_content(chain(n)) ⊆ chain(n+1)`.
If `G(¬ψ) ∉ chain(n)` (i.e., F(ψ) ∈ chain(n)), does this persist?

`bx_le w v` means `g_content(w) ⊆ v.formulas`. If G(¬ψ) ∈ w, then ¬ψ ∈ v (by g_content
propagation). This means if G(¬ψ) ∈ chain(n), then G(¬ψ) may NOT be in chain(n+1) (it's not
in g_content). So F(ψ) can both appear and disappear across BXPoint steps!

**Wait**: this means F(ψ) ∈ chain(n) is NOT preserved by `bx_le` steps. This is the same
obstruction as before, now in the BXPoint chain.

**The critical difference from rr_fwd_chain**: When we use `bx_forward_witness chain(n) target`:
- If `target = ψ`: ψ ∈ chain(n+1) directly, so F(ψ) ∈ chain(n+1) (by `phi_in_mcs_imp_F_phi`)
- If `target ≠ ψ`: F(ψ) might not be in chain(n+1)

So the BXPointChain approach has THE SAME F-persistence problem as the other approaches,
unless F(ψ) is scheduled before G(¬ψ) can be introduced.

**Key property needed**: G(¬ψ) ∉ chain(n) → G(¬ψ) ∉ chain(n+1). This is equivalent to asking:
if G(¬ψ) is NOT in the seed `{target, F(target)} ∪ g_content(chain(n))`, will the Lindenbaum
extension avoid it? There is no guarantee.

Actually, `no_new_f_defects` (RootScopedChain.lean:1170-1186) shows exactly this pattern
FOR `enriched_fwd_step`: `G(¬ψ) ∈ chain(n)` implies `F(ψ) ∉ chain(n+1)`. But the
CONTRAPOSITIVE isn't what we need. We need: `F(ψ) ∈ chain(n)` implies `F(ψ) ∈ chain(n+1)`.

**`rr_fwd_chain_F_obligation_persists`** (RootScopedChain.lean:1160-1168) PROVES this for
`enriched_fwd_step`! The proof: `enriched_fwd_step_preserves` gives `ψ ∈ M' OR F(ψ) ∈ M'`,
then `phi_in_mcs_imp_F_phi` converts the first disjunct.

This means: **F-obligations ARE preserved by `enriched_fwd_step`** (the existing chain step).
The BXPointChain using `bx_forward_witness` does NOT have this property since its seed doesn't
include f_carry.

**Verdict on Approach 7**: The F-persistence guarantee comes from `enriched_fwd_step`, not
from `bx_forward_witness`. We need `enriched_fwd_step` for F-persistence, but `enriched_fwd_step`
can defer the target. The existing `defect_fwd_chain` already uses this and remains sorry.

**Assessment**: Approach 7 reduces to the same obstruction as the existing defect_fwd_chain sorry.

---

## Summary of New Insights

1. **The FiniteDeferral Boneyard's `G_neg_kills_until` may be unsound** — it references
   a removed `until_induction` axiom. This contamination does not affect the BXCanonical
   chain (different axiom system), but marks the Boneyard approach as suspect.

2. **For the BXPointChain + direct `bx_forward_witness` approach**: F-obligations are NOT
   automatically preserved. The enriched_fwd_step has F-preservation by construction
   (via BX11 fold), which is precisely what makes it hard to prove forward_F for its target.

3. **The 2-element Until coherence observation is correct**: if chain(n+1) is built using
   `bx_until_eventuality_resolution` from chain(n) with defect `φ U ψ`, then:
   - ψ ∈ chain(n+1), φ ∈ chain(n), and the guard is vacuous (no r with n ≤ r < n+1)
   - This proves restricted Until coherence for THAT specific step

4. **The core remaining gap** is F-persistence across resolving steps for NON-TARGET formulas.
   This is the depth-0 base case sorry at line 1413.

---

## Recommendation

**Primary Recommendation: Hybrid BXPointChain + Quasimodel Until**

Build TWO separate components:
1. **Forward_F / Backward_P** (~400-500 LOC): Use `self_resolving_fwd_step` applied INFINITELY
   many times via a new chain construction. Each step: use `self_resolving_fwd_step chain(n) ψ`
   where ψ = round-robin target. This gives `ψ ∈ chain(n+1) AND F(ψ) ∈ chain(n+1)`.
   But non-target F(χ) is not preserved...

   **Alternative for forward_F only**: Build a SEPARATE single-target chain for EACH ψ with
   `F(ψ) ∈ M₀`. Use `self_resolving_fwd_step M₀ ψ` repeatedly. The chain is:
   `chain_ψ(0) = M₀, chain_ψ(n+1) = self_resolving_fwd_step chain_ψ(n) ψ`
   Then `ψ ∈ chain_ψ(1)` directly! But this needs chain_ψ to be part of the same Int chain...

   **Simplest forward_F proof** (not through dd_fmcs): Notice that `dd_countermodel` uses
   `dd_bfmcs_restricted_tc` which requires forward_F for ALL formulas in sigma_list. But:
   what if we replace `dd_bfmcs` entirely with a new BFMCS built from BXPoint families?

2. **Until/Since coherence** (~300-400 LOC): Use the 2-element step observation. For the
   Int chain, at any time t where `φ U ψ ∈ chain(t)` and `ψ ∉ chain(t)`, insert a step
   where `bx_until_eventuality_resolution chain(t)` gives chain(t+1) with `ψ ∈ chain(t+1)`.

The overall architecture remains the BX12 + quasimodel strategy from round 35, but with the
specific recognition that the BXPoint 2-element step gives Until coherence "for free."

**Estimated effort**: 700-900 LOC, 15-25 hours.
**Success probability**: 60-70% (slightly lower than round 35 due to better understanding
of the F-persistence obstacle).

---

## Confidence Level

**MEDIUM** — based on deep code reading of all relevant files. The main uncertainty is whether
the hybrid BXPointChain can be wired into `dd_bfmcs` without breaking existing sorry-free
infrastructure. The mathematical arguments are sound; the implementation risk is in the
precise interfaces.

Key files examined:
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` (2291 lines)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/Construction.lean` (887 lines)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/Realization.lean` (444 lines)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/Frame.lean` (673 lines)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/CanonicalChain.lean` (157 lines)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Boneyard/ChainCompleteness/Algebraic/FiniteDeferral.lean` (383 lines)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Boneyard/ChainCompleteness/Bundle/SimplifiedChain.lean` (206 lines)
- `/home/benjamin/Projects/ProofChecker/specs/093_complete_bxcanonical_embedding/handoffs/01_drm-chain-obstacle.md`
- `/home/benjamin/Projects/ProofChecker/specs/093_complete_bxcanonical_embedding/handoffs/02_quasimodel-bridge-design.md`
- `/home/benjamin/Projects/ProofChecker/specs/093_complete_bxcanonical_embedding/reports/35_team-research.md`
