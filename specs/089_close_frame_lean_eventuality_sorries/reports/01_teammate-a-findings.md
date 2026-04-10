# Teammate A Findings: Mathematical Approaches to Eventuality Resolution

**Task**: 89 - Close 4 Frame.lean eventuality resolution sorries
**Date**: 2026-04-10
**Focus**: Primary mathematical approaches for closing the 4 Frame.lean sorries

## Key Findings

### 1. The Problem Is Structural, Not Technical

The 4 sorries in Frame.lean (`bx_until_eventuality_resolution`, `bx_until_backward`, `bx_since_eventuality_resolution`, `bx_since_backward`) share a single root cause: the **fundamental mismatch between the bx_le ordering (defined via g_content/G-formulas) and Until/Since witness semantics**.

Specifically:
- `bx_le w v` means `g_content(w) ⊆ v.formulas`, i.e., `forall phi, G(phi) in w -> phi in v`
- Until eventuality requires: given `phi U psi in w`, find `v >= w` with `psi in v` and `phi in u` for ALL `u` in `[w, v)`
- The guard quantifies over ALL BXPoints between w and v in the bx_le ordering
- But `phi U psi in w` does NOT imply `G(phi U psi) in w`, so the formula does not propagate through g_content

This is not fixable by better proof engineering -- it is a mathematical gap in the current formulation.

### 2. The Bundle Architecture Already Solved This (Differently)

The Bundle architecture (CanonicalConstruction.lean) handles Until/Since by:
- Working with Int-indexed FMCS families: `mcs : Int -> Set Formula`
- Taking `forward_until_since_coherent` and `backward_until_since_coherent` as **hypotheses**
- The truth lemma (lines 806-819) simply applies these hypotheses
- `backward_until_from_step` (UntilSinceCoherence.lean:111) proves backward Until coherence from a step-transfer property via Nat induction

**Critical observation**: The Bundle never proves `forward_until_since_coherent`. It is always an assumption. This means the exact same mathematical problem exists in both architectures -- Frame.lean is trying to prove it for BXPoint-based orderings, the Bundle assumes it for Int-indexed families.

### 3. Report 08 from Task 86 Conclusively Shows Global bx_le Linearity is False

The existing report at `specs/086_close_bxcanonical_completeness_sorries/reports/08_bxle-linearity-research.md` proved:
- Global bx_le linearity is false (incomparable MCS pairs exist)
- BX7 constrains Until-witness ordering within a single MCS, not g_content relationships between MCS
- No bridge exists between BX7 (Until linearity) and g_content inclusion ordering

---

## Approach Analysis

### Approach 1: Redefine bx_le via Until-Based Witnesses

**Idea**: Replace `bx_le w v := g_content(w) ⊆ v.formulas` with an ordering defined via Until witnesses, e.g., `bx_le_new w v := forall phi psi, (phi U psi) in w -> psi not-in w -> (phi U psi) in v or psi in v`.

**Analysis**:

*Reflexivity*: Would follow from BX8 (`psi -> phi U psi`) -- if psi in w, done; if psi not-in w, then `phi U psi in w` trivially.

*Transitivity*: Would require showing that if Until formulas resolve or propagate correctly through two steps. BX5 (self-accumulation: `phi U psi -> (phi and phi U psi) U psi`) could help, but this axiom strengthens the guard, not the eventuality.

*Box preservation*: Currently proved via `temp_future: box(phi) -> G(box(phi))`. With a different ordering, this would need reproof. The issue: `temp_future` gives G-content preservation. If bx_le is no longer g_content inclusion, this route is blocked.

*G-forward (truth lemma for G)*: Currently `G(phi) in w and bx_le w v -> phi in v` follows immediately from the definition. With a new ordering, this critical property would need a separate proof, likely requiring that the new ordering implies g_content inclusion.

**Verdict**: Any ordering weaker than g_content inclusion breaks the G truth lemma. Any ordering stronger than g_content inclusion makes existential witness construction harder. The ordering would need to be g_content inclusion PLUS additional structure -- but that's essentially what we already have plus the unsolved problem.

**Difficulty**: Very High. **Confidence**: 15%. Would require reproving ~10 sorry-free theorems (reflexivity, transitivity, box preservation, modal equivalence, G/H forward/backward). High risk of breaking more than it fixes.

### Approach 2: Quasimodel/Filtration Approach (GHR 1994 Style)

**Idea**: Instead of proving eventuality resolution within the current canonical frame (which quantifies over ALL BXPoints), construct a finite quasimodel or use filtration to work with a bounded set of MCS where linearity can be enforced.

**Analysis**:

The standard technique from Gabbay-Hodkinson-Reynolds (1994) and Goldblatt (1992) for Until completeness works roughly as follows:

1. Start with a consistent formula phi
2. Build a "mosaic" or "quasimodel" -- a finite collection of types (maximal consistent subsets of the subformula closure) arranged in a linear order
3. Eventualities (Until formulas) are resolved by construction: when building the model step-by-step, each Until deficiency is eliminated by extending the model

The key insight is that the construction works with **finitely many types** (subsets of subformula closure) rather than arbitrary MCS. This bounds the problem and allows step-by-step extension.

**What would change in the Lean formalization**:

- Would need a `SubformulaType` notion (finite subset of subformula closure)
- Would need a step-by-step model construction that resolves Until deficiencies
- The current BXCanonical architecture (global MCS + global bx_le) would be largely bypassed
- Essentially a new completeness proof path, not a fix to the existing one

**Relationship to existing code**: The Bundle architecture with Int-indexed FMCS is already close to this pattern. The FMCS assigns an MCS to each integer time. If we could construct an FMCS that satisfies `forward_until_since_coherent`, we'd have completeness. The quasimodel approach provides a recipe for this construction.

**Difficulty**: High (15-25h). **Confidence**: 60%. This is mathematically well-understood but requires significant new Lean infrastructure.

### Approach 3: Interval Linearity from BX7

**Idea**: Even though global bx_le linearity is false, prove that on intervals `[w, v]` where `phi U psi in w`, bx_le is linear using BX7.

**Analysis**:

BX7 says: `(phi U psi) and (chi U theta) -> ((phi and chi) U (psi and theta)) or ((phi and chi) U (psi and chi)) or ((phi and chi) U (phi and theta))`.

For this to give interval linearity, we'd need: given u1, u2 with `bx_le w u1`, `bx_le w u2`, `bx_le u1 v`, `bx_le u2 v`, show `bx_le u1 u2 or bx_le u2 u1`.

The problem is that BX7 operates on formulas within a single MCS, not on relationships between different MCS. Having `phi U psi in w` gives us formula-level information at w, not ordering information about arbitrary u1, u2 between w and v.

To bridge this, we'd need to show that the existence of two MCS u1, u2 in [w, v] implies some combined Until formula at w whose BX7 decomposition forces u1, u2 to be comparable. But:
- We cannot form `(T U chi_u1) and (T U chi_u2)` at w for characteristic formulas chi_u1, chi_u2 because MCS are infinite and have no finite characteristic formula
- Even with BX12 (`F(phi) -> T U phi`), we'd need F(chi_ui) in w, which requires chi_ui to be a single formula characterizing ui

**Verdict**: BX7 is fundamentally a formula-level axiom operating within a single MCS. It cannot produce ordering relationships between different MCS. The gap identified in report 08 (task 86) is real and unbridgeable.

**Difficulty**: N/A (blocked). **Confidence**: 0%. This approach is provably impossible within the current framework.

### Approach 4: Alternative Canonical Model Constructions from the Literature

**4a. Burgess (1982/1984) -- Step-by-Step Chain Construction**

Burgess's completeness proof for Until/Since over reflexive linear orders uses a step-by-step chain construction:

1. Start with a consistent set Gamma
2. Extend to MCS w0
3. Build a chain of MCS: ..., w_{-2}, w_{-1}, w_0, w_1, w_2, ...
4. At each step, the successor MCS is constructed to resolve one Until/Since deficiency
5. The successor seed includes: g_content(w_i) union {phi} (where phi is needed for eventuality resolution)
6. Consistency of the seed is proved using the axioms (BX10 for Until -> F(psi), then the seed {psi} union g_content(w) is consistent by the same argument as bx_forward_witness)

**Key insight for our formalization**: This is exactly the Bundle FMCS construction. The chain `Int -> MCS` IS an FMCS. The issue is proving `forward_until_since_coherent` -- that Until eventualities are resolved along this specific chain.

The standard proof technique:
- Given `phi U psi in w_i`, by BX9 either psi in w_i (done) or phi in w_i and phi U psi still holds
- The chain construction must ensure that `phi U psi` propagates forward until psi appears
- This is where the "unfolding" axiom BX5 (`phi U psi -> (phi and phi U psi) U psi`) and absorption BX6 (`phi U (phi and phi U psi) -> phi U psi`) come in
- BX10 (`phi U psi -> F(psi)`) ensures psi eventually appears (the chain can be constructed to resolve this F-eventuality)

**The missing piece for our formalization**: The chain construction must be done so that:
1. g_content propagates forward (already handled by g_content seed)
2. Until formulas propagate forward until resolved (requires enriching the seed with the Until formula itself)
3. The enriched seed {phi U psi} union g_content(w_i) is consistent

Point 3 is the critical gap. Can we show `{phi U psi} union g_content(w)` is consistent when `phi U psi in w`?

From `phi U psi in w`:
- By BX4: `G(P(phi U psi)) in w`, so `P(phi U psi) in g_content(w)`
- This means `P(phi U psi)` is in any MCS v with g_content(w) subset v
- But we need `phi U psi in v`, not just `P(phi U psi) in v`

The gap: `P(phi U psi) in v` gives `exists u <= v, phi U psi in u` -- the Until formula existed at some earlier point, not necessarily at v itself. There's no axiom that derives `phi U psi` from `P(phi U psi)` directly.

However, we could instead try: the seed is `g_content(w) union {phi, phi U psi}` when `phi U psi in w` and `psi not-in w`. From BX9, phi in w, so phi in g_content(w)? No -- phi in w does NOT mean G(phi) in w.

**Alternative**: Use `phi U psi in w` to derive `G(phi U psi) in w`? This is FALSE in general. Until formulas are not G-persistent.

**This is exactly the X-vs-G mismatch identified in Frame.lean's docstring.**

**4b. Goldblatt (1992) -- Uses Next Operator**

Goldblatt's construction works for DISCRETE temporal frames with a Next (X) operator. The chain is built step-by-step: `w_{i+1}` is constructed to contain the "next-time content" of `w_i`. The Until truth lemma uses:
- `phi U psi <-> psi or (phi and X(phi U psi))` (unfolding principle)
- Since X(phi U psi) propagates through the Next operator, which corresponds to the discrete chain step

**For our formalization**: Our logic TM does NOT have a Next operator. The ordering is dense (arbitrary linear orders), not discrete. This technique does not directly apply.

However, the Bundle FMCS over Int IS discrete. If we're building a completeness proof over Int, we effectively have a "next" operation (t + 1). The question is whether `phi U psi in fam.mcs t` implies we can construct `fam.mcs (t+1)` containing either psi or `phi and (phi U psi)`.

**4c. The "Dovetailing" Approach (Already Attempted in Codebase)**

The codebase has an existing `DovetailedChain.lean` in the Algebraic directory, which attempted exactly this: build an Int -> MCS chain that resolves all F-eventualities by dovetailing. This was blocked by the same issue: Until formulas don't propagate through g_content seeds.

**4d. The "Step-Transfer" Approach (Key Insight)**

Looking at `backward_until_from_step` in UntilSinceCoherence.lean, the backward direction only needs:

```
h_step : forall r, (phi U psi) in fam.mcs (r + 1) -> phi in fam.mcs r -> (phi U psi) in fam.mcs r
```

This is a single-step pullback property. If the chain is constructed so that:
1. g_content(fam.mcs r) subset fam.mcs (r+1) (forward G coherence)
2. h_content(fam.mcs (r+1)) subset fam.mcs r (backward H coherence)
3. For each step, the seed includes enough to derive Until-pullback

Then backward Until coherence follows from `backward_until_from_step`.

The forward direction (eventuality resolution) is harder: given `phi U psi in fam.mcs t`, find s >= t with psi in fam.mcs s and phi on [t, s).

---

## Recommended Approach

### The Viable Path: Enriched Chain Construction with BX-Derived Step Properties

**Core idea**: Build the FMCS (Int -> MCS) chain so that each step seed includes not just g_content but also selected Until/Since formulas. The enriched seed enables both forward eventuality resolution and backward step-transfer.

**Construction sketch**:

Given MCS w_0 containing phi U psi:

1. Define the successor seed: `Sigma(w) = g_content(w) union {chi | chi U theta in w and theta not-in w}` -- i.e., include all "guard" formulas from active Until obligations

2. Show this seed is consistent: if it were inconsistent, some finite L subset Sigma(w) derives bot. The g_content part is consistent (existing proof). For the guard part: from `chi U theta in w` and `theta not-in w`, BX9 gives `chi in w`. But we need `chi in Sigma(w)`, not just `chi in w`. Since Sigma(w) supset g_content(w), we need `G(chi) in w`, which we don't have.

**This fails for the same reason.**

### Revised Viable Path: Rewrite the 4 Sorries as Equivalences with the Bundle's forward_until_since_coherent

Instead of proving the Frame.lean sorries directly, **rewrite them** to show they are equivalent to the Bundle's forward/backward Until/Since coherence assumptions. Then either:

(a) Close the Frame.lean sorries by constructing a specific FMCS that satisfies forward_until_since_coherent (essentially reducing to the Bundle path), or

(b) Delete the Frame.lean sorries and reformulate the truth lemma to take forward_until_since_coherent as a hypothesis (as the Bundle already does), deferring the construction problem to the completeness theorem itself.

Option (b) is essentially what the Bundle architecture already does. The Frame.lean formulation is trying to prove something at the wrong level of abstraction.

### Most Promising Concrete Path: Prove Forward Until Coherence for a Specific Chain Construction

For the completeness proof, we only need ONE FMCS that satisfies all coherence conditions and contains a specific formula. The construction:

1. Start with MCS w_0 containing the target formula
2. Build the chain by dovetailing: enumerate all F-eventualities and Until-eventualities
3. At each step, resolve one eventuality by extending the seed
4. Use a priority scheme: Until eventualities take priority and are resolved by including psi in the next appropriate seed

The key insight that may break the deadlock: **for the chain construction, we don't need to prove the guard for ALL BXPoints in [w, v)** -- we only need it for **chain points**. The Bundle formulation already restricts the quantification to chain points (integers indexing the FMCS).

This means:
- Frame.lean's universal quantification (`forall u : BXPoint, bx_le w u -> ...`) is TOO STRONG
- The Bundle's chain quantification (`forall r : Int, t <= r -> r < s -> ...`) is exactly right
- We should prove forward_until_since_coherent for a specific chain construction, not for arbitrary BXPoints

**Difficulty**: High (15-20h). **Confidence**: 55%.

The hardest part is proving that the dovetailed chain resolves Until eventualities. Specifically, showing that `phi U psi in fam.mcs t` and `psi not-in fam.mcs t` implies:
- We can find s > t such that psi in fam.mcs s
- For all r in [t, s), phi in fam.mcs r

This requires the chain construction to propagate phi and phi U psi forward until psi is resolved, which requires the enriched seed approach -- and the enriched seed consistency is the fundamental blocker.

**Potential breakthrough**: Use BX12 (`F(phi) -> T U phi`) together with the fact that the chain construction already resolves F-eventualities. If `phi U psi in w` implies `F(psi) in w` (by BX10), and the chain resolves F(psi) by placing psi at some future chain point s, then we need to show phi holds at all chain points in [t, s). From BX9, phi or psi holds at each chain point with phi U psi. If the chain propagates phi U psi forward (via g_content + the formula being in the seed), then at each chain point before s, either psi appears (resolving early) or phi appears (maintaining the guard). This is essentially the standard "Until unfolding" argument, but it requires phi U psi to be in the chain seed at each step -- which is exactly the problem.

---

## Evidence/Examples

### Existing Codebase Evidence

1. **Frame.lean:653** -- The sorry has extensive comments documenting the X-vs-G mismatch
2. **Report 08 (task 86)** -- Proved global bx_le linearity is false
3. **Bundle CanonicalConstruction.lean** -- Sorry-free truth lemma that takes forward_until_since_coherent as hypothesis
4. **UntilSinceCoherence.lean** -- backward_until_from_step proves backward direction via Nat induction given step-transfer

### Literature Evidence

- Burgess (1982): Complete axiomatization uses step-by-step chain construction; completeness proof is "relatively simple modification" of standard tense logic proofs
- Goldblatt (1992): Uses Next operator for discrete frames; not directly applicable to dense orders
- Gabbay-Hodkinson-Reynolds (1994): Comprehensive treatment; quasimodel approach for real-number time
- Venema (1993): Extensions to strict linear orderings

### Dead End Evidence (12 Prior Approaches)

All 12 documented dead ends converge on the same blocker: Until formulas cannot be propagated through g_content-based seeds because `phi U psi in w` does not imply `G(phi U psi) in w`.

---

## Confidence Level

### Per-Approach Assessment

| Approach | Confidence | Effort | Key Risk |
|----------|-----------|--------|----------|
| 1. Redefine bx_le | 15% | 25-35h | Breaks G truth lemma; cascading reproofs |
| 2. Quasimodel/Filtration | 60% | 15-25h | Large new infrastructure; may hit same seed problem |
| 3. Interval linearity from BX7 | 0% | N/A | Provably blocked (formula-level vs MCS-level gap) |
| 4a. Burgess chain | 45% | 15-20h | Seed consistency is the same fundamental blocker |
| 4b. Goldblatt (discrete) | 30% | 10-15h | Requires Next operator not in our logic |
| 4d. Step-transfer chain | 55% | 15-20h | Most aligned with existing codebase |

### Overall Assessment

**The Frame.lean sorries as currently stated may be unprovable** because they quantify over ALL BXPoints in an interval, not just chain points. The universal quantification `forall u : BXPoint, bx_le w u -> bx_le u v and not bx_le v u -> phi in u.formulas` requires showing phi holds at arbitrary MCS between w and v, which requires global interval linearity of bx_le (proved false).

**The viable path forward is to change the formulation**, not to prove the current one. Options:
1. Replace Frame.lean's BXPoint-level eventuality resolution with Bundle-style chain-level coherence
2. Prove forward_until_since_coherent for a specific chain construction
3. Accept the Frame.lean sorries as an abstraction layer and prove completeness through the Bundle path

**Overall confidence that the completeness theorem is true**: 95% (the axiom system is standard and known to be complete).
**Overall confidence that the Frame.lean sorries as currently stated can be closed**: 10% (the universal quantification over arbitrary BXPoints is the fundamental issue).
**Overall confidence that completeness can be proved via the Bundle path**: 65% (requires proving forward_until_since_coherent for a specific chain, which has the seed consistency blocker, but the chain-only quantification is a significant simplification).
