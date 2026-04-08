# Research Report: Task #85 - Teammate C Findings

**Task**: 85 - Until/Since chain coherence approaches
**Direction**: DIRECTION 3 - Quasimodel replacement + critical analysis of ALL three directions + gap identification
**Teammate**: C
**Date**: 2026-04-08

## Executive Summary

After deep reading of the codebase, I identify that the project has **two parallel completeness architectures** with different sorry profiles, and the key blocker in both is the same fundamental problem: **propagating Until/Since formulas through canonical model points that are related by the g_content ordering but not by x_content determinism**. I find one critical gap in prior research (the BX4 replacement invalidates the Burgess-Xu axiom 4 derivation strategy), one overlooked approach (FMP-based completeness is closer to viable than recognized), and provide concrete analysis of each direction.

## Key Findings

### Finding 1: Two Parallel Architectures with Converging Sorry Sites

The codebase has two independent completeness paths:

**Path A: Bundle/BFMCS path** (Bundle/CanonicalConstruction.lean -> BaseCompleteness.lean)
- Uses Int-indexed FMCS families with g_content/h_content linking
- Sorry sites: forward_F (eventuality resolution), backward Until/Since step transfer
- Key file: `Bundle/UntilSinceCoherence.lean:111-138` - parameterized backward Until that is sorry-free IF step transfer is provided

**Path B: BXCanonical path** (BXCanonical/Frame.lean -> BXCanonical/Completeness.lean)
- Uses BXPoint (bare MCS) with bx_le ordering (g_content subset)
- Sorry sites: `Frame.lean:553,575,590,604` - 4 sorry sites for Until/Since eventuality resolution and backward direction
- Plus `Completeness.lean:144` - the final completeness sorry (model construction)

Both architectures converge on the **identical mathematical gap**: given `phi U psi in w` with `psi not in w`, construct a witness `v >= w` (in the g_content ordering) with `psi in v` and the guard `phi` satisfied at all intermediate points.

### Finding 2: The BX4 Replacement KILLS the Burgess-Xu Axiom 4 Derivation Strategy

**This is a critical gap in prior research (task 83 report 35).**

Report 35 recommended deriving the original Burgess-Xu axiom 4:
```
alpha AND (chi U psi) -> chi U (psi AND (chi S alpha))
```
from BX1-BX10 to obtain enriched Until witnesses with Since guards.

However, the Soundness.lean comment at lines 397-401 is explicit:

> **Note on BX4**: The standard Burgess-Xu BX4 (`phi AND (chi U psi) -> chi U (psi AND (chi S phi))`) is **not valid** under the half-open guard convention [t, s) / (s, t] used here because the Since guard at the Until witness s requires chi(s), which the half-open Until guard excludes.

The half-open guard semantics (Until guard is `[t, s)` not `[t, s]`, Since guard is `(s, t]` not `[s, t]`) means:
- `chi U psi` at t has witness s >= t with psi(s) and chi(r) for t <= r < s
- `chi S alpha` at s requires alpha at some s' <= s with chi on (s', s]
- At the Until witness s, chi(s) is NOT guaranteed (only chi on [t, s), not at s itself)
- So `psi AND (chi S alpha)` at s requires chi(s) which we do not have

**Conclusion**: The Burgess-Xu axiom 4 is **semantically invalid** in this system. It cannot be derived from BX1-BX10 because it is not even true. This direction is provably blocked.

**However**, note that BX8 gives reflexive Until introduction: `psi -> (phi U psi)`. Under the reflexive Until semantics (witness s >= t, not s > t), the guard interval [t, s) is empty when s = t. So the "reflexive witness" case where s = t always works. The issue is specifically with **strict witness** cases where s > t.

### Finding 3: The BXCanonical Sorry Sites Are Structurally Simpler Than Bundle Sorries

The BXCanonical path (`Frame.lean:501-605`) has a cleaner sorry structure. The blocking comment at line 522-523 states:

> The forward direction (eventuality resolution) requires showing that at intermediate points u in [w, v), the formula phi holds. The key difficulty is propagating phi U psi to intermediate points: **phi U psi in w does not imply G(phi U psi) in w**, so the formula does not propagate forward through g_content.

This is the precise mathematical statement of the gap. In the BXCanonical architecture, the question is: given `phi U psi in w` and `psi not in w`, and having found v >= w with psi in v (via BX10 + bx_forward_witness), can we show phi holds at all intermediate u where w <= u < v?

What we have:
- BX9: `phi U psi -> phi OR psi`. Since psi not in w: phi in w.
- BX5: `phi U psi -> (phi AND (phi U psi)) U psi` (self-accumulation)
- BX4: `phi U psi -> G(P(phi U psi))` (connectedness, our BX4)

So `P(phi U psi) in u` for all u >= w. This tells us that **somewhere in the past of u, phi U psi held**. But it does NOT tell us that phi U psi holds at u itself.

**Gap**: The standard Burgess proof uses Until-induction (not in BX), and the alternative would be linearity of bx_le on intervals (from BX7), which is also not established.

### Finding 4: Linearity of bx_le from BX7 Is the Real Missing Piece

BX7 (linearity of Until) states:
```
(phi U psi) AND (chi U theta) ->
  ((phi AND chi) U (psi AND theta)) OR
  ((phi AND chi) U (psi AND chi)) OR
  ((phi AND chi) U (phi AND theta))
```

This axiom encodes that Until witnesses are linearly ordered. In semantic terms: if `phi U psi` at t has witness s1, and `chi U theta` at t has witness s2, then s1 <= s2 or s2 <= s1.

For the canonical model, this should translate to: **bx_le is a total preorder** (any two bx_le-related points are comparable). If we can prove that bx_le is linear (total), then:

1. Given w <= u <= v (in bx_le), any point u' with w <= u' is either u' <= v or v <= u'.
2. This enables the inductive argument: if phi U psi propagates via P(phi U psi) to all future points, and the ordering is linear, we can restrict to the interval [w, v].

**Concrete approach**: Prove from BX7 that for any two BXPoints w, v with bx_le w v, and any u with bx_le w u, either bx_le u v or bx_le v u.

**Sketch**:
- Suppose phi U psi in w (witness = v) and chi U theta in w (witness = u).
- By BX7, one of three cases holds. Each case gives a combined Until formula whose witness ordering constrains the relationship between u and v.
- The key is translating BX7's formula-level linearity into bx_le ordering linearity.

**Problem**: BX7 operates on formulas, not on canonical model points directly. The translation requires: "if phi U psi in w with semantic witness v, then for any canonical point u between w and v, phi in u". This is circular -- we need the guard to establish the witness pattern, but we need the witness pattern to establish linearity.

### Finding 5: FMP-Based Completeness Is Closer Than Recognized

The FMP path (Decidability/FMP/) has only **1 sorry** in the main code:
- `TruthPreservation.lean:263` - `temp_4 removed in BX`

This is a trivial sorry! The BX axiom system **includes** temp_4 as an explicit axiom (`Axiom.temp_4`). The sorry at line 263 was left during the BX refactoring but should be directly fixable:

```lean
-- Current (sorry):
have h_temp_4_thm : [] |- (psi.all_future).imp (psi.all_future.all_future) :=
  sorry /- temp_4 removed in BX -/

-- Fix:
have h_temp_4_thm : [] |- (psi.all_future).imp (psi.all_future.all_future) :=
  DerivationTree.axiom [] _ (Axiom.temp_4 psi)
```

However, FMP as currently structured gives **decidability** (exists finite model falsifying non-theorems) but NOT completeness directly. The FMP theorem `mcs_finite_model_property` says: if phi is not provable, there exists a finite closure MCS where phi is false. This is not the same as: if phi is valid in all models, then phi is provable.

To get completeness from FMP, you need:
1. FMP: non-provable -> falsifiable in finite model (**have this**, modulo 1 trivial sorry)
2. Finite model truth lemma: MCS membership = truth in finite model (**partially have**)
3. Bridge: truth in finite model = truth in TaskModel

The gap is step 3: the filtered model uses `ClosureMCSBundle` as world states, but the connection to actual TaskModel truth evaluation is not established. This is a **significantly different** gap from the canonical model sorries -- it's about model construction (embedding closure MCS into TaskFrame), not about Until/Since coherence.

### Finding 6: The UntilSinceCoherence Parameterized Approach Is the Right Architecture

`Bundle/UntilSinceCoherence.lean` provides the cleanest decomposition of the problem. The `backward_until_from_step` theorem (lines 111-138) is **fully proved** and requires only:

```lean
h_step : forall r : Int, Formula.untl phi psi in fam.mcs (r + 1) ->
  phi in fam.mcs r -> Formula.untl phi psi in fam.mcs r
```

This "step transfer" property is the **atomic** obligation. Any chain construction that can provide this step transfer immediately gets sorry-free backward Until/Since. The problem reduces to: **for a single step**, if `phi U psi` is in the successor MCS and `phi` is in the current MCS, show `phi U psi` is in the current MCS.

For deterministic chains (x_content linking), this is trivial because `X(phi U psi) in M iff phi U psi in x_content(M)`. But for g_content-linked chains, we only know `G(phi U psi) in M -> phi U psi in successor(M)`, not the reverse.

### Finding 7: The Hybrid Chain Idea Has a Concrete Obstruction

The task asks about building a chain that is "mostly deterministic but takes carefully controlled detours." The obstruction is:

1. A deterministic chain from MCS M has `chain(n+1) = x_content(chain(n))`.
2. Under BX reflexive semantics, `X(alpha) = bot U alpha` and `X(alpha) -> alpha` (by BX9). So `x_content(M) = {alpha | X(alpha) in M}`. But `X(alpha) in M iff (bot U alpha) in M`, and by BX9 `bot U alpha -> bot OR alpha = alpha`. So `alpha in x_content(M)` requires `X(alpha) in M`, which by BX8 requires just `alpha in M`. This means **x_content(M) = M** under reflexive semantics!

Wait -- this is stated in the UntilSinceCoherence.lean docstring (line 33-34):
> Under BX reflexive semantics, x_content(M) = M (since X(alpha) <-> alpha), so the deterministic chain is **constant** and backward Until is trivially satisfied.

If the deterministic chain is constant (every step is the same MCS), then it trivially satisfies Until persistence but **cannot resolve any eventualities** -- F(psi) in chain(t) requires psi in some chain(s) with s > t, but if chain(s) = chain(t) for all s, then psi must already be in chain(t).

This is why the deterministic chain path in the Boneyard was deprecated. The reflexive semantics makes x_content trivial, removing the discrete-chain structure that the old completeness proof relied on.

### Finding 8: The Two-Chain Splice Has a Precise Formulation

The splice idea: given F(psi) in chain(t), build a witness MCS W with psi in W and g_content(chain(t)) subset W, then start a new deterministic chain from W.

Under reflexive semantics, the "new deterministic chain from W" is just the constant chain at W (since x_content(W) = W). So the splice is:
- chain(t) for all times <= t
- W for all times > t

The issue: this works for a single eventuality but does NOT work for multiple simultaneous eventualities. If F(psi1) and F(psi2) are both in chain(t) with psi1 not in chain(t) and psi2 not in chain(t), we need witnesses at potentially different future times. One splice point cannot resolve both unless psi1 and psi2 can be in the same witness MCS.

**Key insight**: The forward witness seed `{psi} union g_content(M)` is consistent (proved sorry-free in WitnessSeed.lean). But `{psi1, psi2} union g_content(M)` may NOT be consistent. So we may need DIFFERENT witness MCS for different eventualities, leading back to the dovetailed chain construction and its sorry sites.

### Finding 9: The "Pull Before Push" Philosophy Needs Revision for BX

The task mentions the "pull-before-push" philosophy from task 83 report 30. Under the BX axiom system with reflexive semantics, this philosophy needs refinement:

- **Push**: G(phi) in M -> phi in successor(M) (g_content propagation). This works.
- **Pull**: phi in successor(M) -> G(phi) in M? No -- this is the backward direction, which requires the contrapositive argument via forward_F.
- **Duration resolution**: F(psi) in M -> psi in some future MCS. This works (witness seed consistency).
- **Gap**: Universal operators G/H at the model level, not at the MCS level.

The real issue is not push vs pull but the **scope** of the linking relation. The g_content/h_content linking gives ONE-STEP forward/backward propagation of universals. Until/Since require MULTI-STEP propagation with a specific guard pattern. The gap is between the one-step granularity of the chain construction and the multi-step nature of Until witnesses.

## Concrete Proof Sketches

### Sketch A: BX7 Linearity -> bx_le Totality (Most Promising for BXCanonical Path)

**Goal**: Prove that for any three BXPoints w, u, v with bx_le w u and bx_le w v, either bx_le u v or bx_le v u.

**Approach**:
1. Suppose bx_le w u (g_content(w) subset u.formulas) and bx_le w v (g_content(w) subset v.formulas).
2. We want: g_content(u) subset v.formulas OR g_content(v) subset u.formulas.
3. Suppose neither. Then exists alpha with G(alpha) in u, alpha not in v. And exists beta with G(beta) in v, beta not in u.
4. Since alpha not in v: neg(alpha) in v (MCS). Since beta not in u: neg(beta) in u (MCS).
5. From G(alpha) in u and neg(beta) in u: construct `G(alpha) AND neg(beta)` in u.
6. From G(beta) in v and neg(alpha) in v: construct `G(beta) AND neg(alpha)` in v.
7. Now use BX4 connectedness and BX7 linearity to derive a contradiction.

**Problem**: Step 7 is where the argument breaks down. BX7 talks about Until linearity, not G linearity. We need to convert G-statements to Until-statements: G(alpha) iff not F(neg alpha) iff not (top U neg alpha). The negation makes it difficult to apply BX7 directly.

**Alternative for step 7**: Use temporal connectedness BX4: `alpha -> G(P(alpha))`. If alpha in u and G(alpha) in u but alpha not in v, then since bx_le w u and bx_le w v, we have... this doesn't immediately help.

**Assessment**: This direction requires substantial new derivation infrastructure. Plausible but non-trivial. Estimated effort: several hundred lines of Lean.

### Sketch B: Transfinite Induction on Eventuality Depth (For Bundle Path)

**Goal**: Provide the step transfer property for `backward_until_from_step`.

**Approach**: Instead of building a chain where step transfer holds by construction, prove it for the existing chain using a well-founded induction on the "depth" of the Until formula.

For formula `phi U psi`:
- If `phi U psi in fam.mcs(r+1)` and `phi in fam.mcs(r)`, need `phi U psi in fam.mcs(r)`.
- By BX5: `phi U psi in fam.mcs(r+1)` implies `(phi AND (phi U psi)) U psi in fam.mcs(r+1)`.
- By BX9: `phi U psi -> phi OR psi`. If psi in fam.mcs(r+1), done (use BX8 at r).
- If phi in fam.mcs(r+1) and phi U psi in fam.mcs(r+1) but psi not in fam.mcs(r+1):
  Need to propagate backward.

**Problem**: This reduces to the same step transfer at position r+1, so it's circular.

**Assessment**: Not viable without additional structure.

### Sketch C: FMP Completeness (Alternative to Canonical Model)

**Goal**: Prove completeness via FMP rather than canonical model.

**Steps**:
1. Fix the trivial sorry in TruthPreservation.lean:263 (use Axiom.temp_4)
2. Establish filtered model truth lemma: for closure MCS S and phi in closure, phi in S iff phi true at S in filtered TaskModel
3. Derive completeness: if phi valid, then phi true in all models including filtered model, so phi in all closure MCS, so phi provable (contrapositive of FMP)

**Key gap**: Step 2 requires embedding FilteredWorld into a TaskModel. The filtered "worlds" are equivalence classes of closure MCS. The temporal ordering on these worlds must be defined (likely: [S] <= [T] iff g_content(S) intersect closure subset T), and truth preservation must be proved for this ordering.

The Until/Since truth preservation for filtered models is the key challenge. For filtration to work for Until, we need: `phi U psi` true at [S] in filtered model iff `phi U psi in S`. The forward direction (membership -> truth) requires a witness world [T] >= [S] with psi in T and phi on the guard interval. The backward direction (truth -> membership) requires the BX axioms.

**Assessment**: This approach still faces the Until coherence issue, but in a **finite** setting where we can potentially use the finiteness to our advantage (e.g., induction on the number of worlds between [S] and [T]).

## Gaps in Prior Research

### Gap 1 (CRITICAL): Burgess-Xu Axiom 4 Is Invalid in This System

As detailed in Finding 2, the standard Burgess-Xu axiom 4 (`alpha AND (chi U psi) -> chi U (psi AND (chi S alpha))`) is semantically invalid under the half-open guard convention. Task 83 report 35's recommendation to derive this axiom is impossible -- not because it's hard to derive, but because it's **false**. Any direction that depends on this derivation is blocked.

### Gap 2: x_content Triviality Under Reflexive Semantics Was Not Fully Appreciated

Prior research (task 83) discussed the "enriched seed" approach and its failure due to G-liftability. But the deeper issue is that under reflexive semantics, `x_content(M) = M` (since X(alpha) = bot U alpha and BX9 gives bot U alpha -> alpha). This makes deterministic chains constant, fundamentally changing the proof architecture. The old deterministic chain completeness (in Boneyard/) relied on non-trivial x_content, which only exists under strict/discrete semantics.

### Gap 3: BX7 Linearity Has Not Been Explored for Canonical Ordering

Prior research focused on (1) enriched seeds, (2) dovetailed chains, (3) restricted chains. None of the 43 rounds explored using BX7 (linearity of Until) to establish totality of the canonical temporal ordering. The comment in Frame.lean:512-513 mentions this as option (B) but no attempt was made.

### Gap 4: FMP Path Has a Trivially Fixable Sorry

The `sorry /- temp_4 removed in BX -/` in TruthPreservation.lean:263 is trivially fixable since temp_4 IS an axiom in the BX system. This was apparently missed during the BX refactoring. Fixing it brings the FMP path to 0 sorries in its core logic (the remaining gap is the model construction bridge).

## Cross-Direction Analysis

### Direction 1 (Axiomatic Derivation): Partially Blocked

If "axiomatic derivation" means deriving Burgess-Xu axiom 4, this is blocked (see Gap 1).

However, if it means deriving **different** useful properties from BX5+BX6+BX7, it remains open. Specifically:
- Can we derive `phi U psi -> G(phi U psi OR psi)` from BX axioms? This would enable forward propagation of the Until formula through g_content.
- BX5 gives `phi U psi -> (phi AND (phi U psi)) U psi`. By BX10, `(phi AND (phi U psi)) U psi -> F(psi)`. By BX4, `phi U psi -> G(P(phi U psi))`. But none of these give `G(phi U psi OR psi)`.

### Direction 2 (Chain Construction): Facing Fundamental Limits

The chain construction approach tries to build an Int-indexed family satisfying all coherence properties simultaneously. Under reflexive semantics:
- Deterministic chains are constant (x_content = identity)
- Dovetailed chains break Until persistence at splice points
- Restricted chains have bounded deferral issues

All chain approaches face the same problem: the chain linking (g_content or h_content) propagates universal formulas one step, but Until requires coordinated multi-step patterns.

### Direction 3 (This Direction): BXCanonical + BX7 Linearity Is Most Promising

The BXCanonical architecture avoids the chain construction entirely. Instead of building an Int-indexed family, it works with the abstract space of all MCS ordered by g_content. The Until/Since truth lemma operates on this abstract space.

The key advantage: the BXCanonical path has **only 5 sorry sites** (4 in Frame.lean, 1 in Completeness.lean), and all 4 Frame.lean sorries reduce to the single question of linearity/interval structure of bx_le.

If bx_le can be shown to be a total preorder (any two comparable points are linearly ordered), the eventuality resolution becomes:
1. phi U psi in w, psi not in w. By BX10: F(psi) in w.
2. By bx_forward_witness: exists v >= w with psi in v.
3. By linearity: for any u with w <= u <= v, u is on a linear segment.
4. On this segment, BX4 and BX7 give the guard condition.

### How Directions Interact

- Direction 1 (axiomatic) feeds into Direction 3: any new BX-derived theorems about Until propagation directly help the BXCanonical path.
- Direction 2 (chain) is largely independent and faces its own structural issues.
- Direction 3 (BXCanonical + linearity) subsumes Direction 1 if BX7 linearity can be established, since the eventuality resolution argument would use BX5+BX6+BX7 directly rather than derived theorems.

## F_until_equiv Impact

The `F_until_equiv` axiom (`F(psi) <-> top U psi`) was removed in the BX refactoring. Under reflexive Until semantics, `top U psi` means: exists s >= t with psi(s) and top on [t, s). The guard (top) is trivially satisfied, so `top U psi` is equivalent to `F(psi) = exists s >= t, psi(s)`.

**Impact on Direction 1**: F_until_equiv is derivable from BX8+BX10:
- Forward: `top U psi -> F(psi)` is BX10 instantiated.
- Backward: `F(psi) = not G(not psi)`. If F(psi) holds, exists s >= t with psi(s). Since top is always true, top holds on [t, s). So `top U psi`.

Actually, the backward direction requires an axiom that converts `exists s >= t, psi(s)` to `top U psi`. This IS exactly what F_until_equiv provides. Under BX, we can derive `psi -> top U psi` from BX8 (taking the witness at t itself). But `F(psi) -> top U psi` requires: knowing psi holds at some future s, derive top U psi at t. This is NOT derivable from BX8 alone (BX8 only gives the reflexive case s = t).

**Conclusion**: F_until_equiv is NOT trivially derivable from BX1-BX10 in the non-trivial direction (`F(psi) -> top U psi`). Its removal may have created a gap that was not fully appreciated. The old completeness proof relied on converting F-obligations to Until-obligations, and without F_until_equiv, this conversion is lost.

**Impact on all directions**: Any approach that needs to convert `F(psi) in M` to `top U psi in M` (to leverage Until's structural properties) is blocked without F_until_equiv. The BXCanonical path works directly with F and does not need this conversion, which is another argument in its favor.

## Confidence Levels

| Direction | Viability | Confidence |
|-----------|-----------|------------|
| Burgess-Xu axiom 4 derivation | **Blocked** (semantically invalid) | 95% |
| Chain construction (enriched seed) | **Blocked** (x_content trivial) | 90% |
| Chain construction (dovetailed) | **Blocked** (Until persistence breaks) | 90% |
| BXCanonical + BX7 linearity | **Open, most promising** | 50% viability |
| FMP-based completeness | **Open, alternative path** | 40% viability |
| New axiom (Until-induction) | **Viable but changes the system** | 70% if acceptable |

## Recommendation

### Primary: Pursue BXCanonical + BX7 Linearity

1. **Immediate**: Attempt to prove bx_le totality from BX7. This is the single most impactful result. If it succeeds, all 4 Frame.lean sorry sites can likely be resolved.

2. **Concrete first step**: Prove that for any BXPoint w and formula `phi U psi in w` with `psi not in w`, the set `{chi | G(chi) in w} union {phi, phi U psi}` is consistent. This would give a successor MCS that contains both the g_content of w AND the Until formula, enabling one step of propagation.

3. **Key lemma to attempt**: From BX5 (self-accumulation) and BX6 (absorption), derive that `phi U psi in M` and `phi in M` and `psi not in M` implies `phi U psi in any MCS extending g_content(M) union {phi}`.

### Secondary: Fix the FMP Sorry and Explore FMP Completeness

The `sorry /- temp_4 removed in BX -/` in TruthPreservation.lean:263 is a trivial fix (temp_4 IS a BX axiom). Fix it and then explore whether the FMP path can be extended to full completeness. The FMP approach works in a finite setting where inductive arguments are more tractable.

### Tertiary: Consider Adding Until-Induction as a Derived Rule

If BX7 linearity fails to give bx_le totality, the nuclear option is to add Until-induction as an axiom:
```
(psi OR (phi AND G(alpha -> X(alpha)))) AND (alpha) -> alpha OR (phi U psi)
```
and prove it sound. This is the standard Burgess axiom that was removed in the BX refactoring. Adding it back would resolve all sorry sites but changes the axiom system.

## Appendix

### Files Read
- `Theories/Bimodal/ProofSystem/Axioms.lean` - BX axiom system (33 constructors)
- `Theories/Bimodal/Semantics/Truth.lean:120-131` - Reflexive Until/Since semantics
- `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean:420-605` - Sorry sites (4)
- `Theories/Bimodal/Metalogic/BXCanonical/TruthLemma.lean:120-320` - Truth lemma structure
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` - Top-level completeness (1 sorry)
- `Theories/Bimodal/Metalogic/Bundle/UntilSinceCoherence.lean` - Parameterized step transfer
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherence.lean` - Forward/backward G/H lemmas
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` - Chain construction (20 sorries)
- `Theories/Bimodal/Metalogic/Bundle/WitnessSeed.lean` - Witness seed consistency (sorry-free)
- `Theories/Bimodal/Metalogic/Algebraic/DovetailedChain.lean` - Deprecated, 12 sorries
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` - Ultrafilter chain (18 sorries)
- `Theories/Bimodal/Metalogic/Algebraic/ParametricRepresentation.lean` - Parametric completeness
- `Theories/Bimodal/Metalogic/Decidability/FMP/FMP.lean` - Finite Model Property
- `Theories/Bimodal/Metalogic/Decidability/FMP/TruthPreservation.lean:240-272` - 1 sorry (trivial)
- `Theories/Bimodal/Metalogic/Soundness.lean:380-728` - BX axiom soundness proofs
- `Theories/Bimodal/Theorems/TemporalDerived.lean` - BX-derived temporal theorems

### Sorry Census (Metalogic/ only)
- Total: 145 occurrences across 28 files
- BXCanonical path: 5 sorry sites (4 in Frame.lean, 1 in Completeness.lean)
- Bundle path: ~40+ sorry sites across SuccChainFMCS, UltrafilterChain, DovetailedChain
- FMP path: 1 sorry site (trivially fixable)
- Other: ConservativeExtension (~39), Soundness (4), misc

### Search Queries Used
- Grep for `sorry` across Metalogic/, BXCanonical/, Decidability/
- Grep for `F_until_equiv`, `Burgess.*Xu.*axiom.*4`, `since_guard`
- Glob for Metalogic/**/*.lean, Theorems/**/*.lean
