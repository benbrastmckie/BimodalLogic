# Teammate A Findings: Primary Approach for CanonicalEmbedding:418

## Summary

Deep analysis of the sorry at `CanonicalEmbedding.lean:418` reveals that **all model-construction approaches on D = Int are fundamentally blocked** by a cardinality mismatch: the backward truth bridge for G requires the history to visit all bx_le successors, which may be uncountably many (up to 2^aleph_0), but Int is countable. However, I identify **two viable approaches** and recommend a **proof-theoretic reduction via well-founded induction** that avoids model construction for G/H/box cases entirely.

## Key Findings

### 1. The Backward Truth Bridge is the Core Blocker

The sorry needs `False` from:
- `h_valid : valid (psi.imp chi)` (true in ALL models)
- `psi in w.formulas`, `chi not in w.formulas` (MCS w)
- Both psi, chi are USF

The standard proof instantiates `valid` at a specific model, shows `truth_at psi` (forward bridge), concludes `truth_at chi`, then derives `chi in w` (backward bridge).

The **forward bridge** for USF formulas on constant histories works:
- `G(alpha) in w -> alpha in w` (BX1/reflexivity) -> `truth_at alpha` (IH) -> `truth_at G(alpha)` (since truth is time-independent on constant histories)
- Time-independence is provable by induction: on `constant_history w`, `truth_at phi` at time t equals `truth_at phi` at time 0 for ALL USF phi

The **backward bridge** fails for G:
- `truth_at G(alpha)` on constant_history w = `truth_at alpha` (collapse)
- By IH backward: `alpha in w`
- Need: `G(alpha) in w`, which requires `alpha in v` for ALL `v >= w` (by `G_iff_mcs`)
- Only have `alpha in w`, not in all successors

**BUT the forward bridge for imp also requires the backward bridge for the antecedent** (to apply `imp_iff_mcs`). So even a "forward-only" approach fails:
- Forward for `(A -> B) in w`: Assume `truth_at A`. Need `truth_at B`.
- Route: `truth_at A -> A in w` (backward for A!) -> `B in w` (imp_iff_mcs) -> `truth_at B` (forward for B)

This means we cannot separate forward/backward bridges. The truth bridge for imp is inherently bidirectional.

### 2. Constant-History Model: What DOES Work

On `(canonical_valuation, modal_omega w, constant_history w, 0)`:

**Time-independence theorem** (provable for all USF formulas):
```
truth_at M Omega (constant_history w) t phi = truth_at M Omega (constant_history w) 0 phi
```
Proof by structural induction: atoms use same state (w) at all times; bot/imp structural; box quantifies over constant histories (time-independent by IH); G(alpha): truth at time t = forall s >= t, truth alpha at s = truth alpha at 0 (by IH time-independence); H symmetric.

**Temporal collapse** (consequence):
```
truth_at G(alpha) at constant_history w = truth_at alpha at constant_history w
truth_at H(alpha) at constant_history w = truth_at alpha at constant_history w
```

**Fragment truth iff** (already proved, sorry-free):
```
fragment_truth_iff : temporalFree phi -> phi in w <-> truth_at ... phi
```

**What this gives us**: On constant histories, evaluating a USF formula is EQUIVALENT to evaluating its "flattening" (removing all G/H). So `truth_at phi = truth_at flat(phi)` on constant histories, where `flat(G(alpha)) = flat(alpha)`, `flat(H(alpha)) = flat(alpha)`, and flat commutes with other constructors.

### 3. Model Construction on Large D (Feasible but Complex)

Since `valid` quantifies over ALL `D : Type`, we can choose D = R (reals) or any type with cardinality >= 2^aleph_0.

**Cardinality analysis**:
- `Formula` has `deriving Countable`, so |Formula| = aleph_0
- `BXPoint` subset of `Set Formula`, so |BXPoint| <= 2^aleph_0
- `canonical_task_frame` has `task_rel w d u = d != 0 or w = u`, meaning ANY function `D -> BXPoint` satisfies `respects_task` (for s < t: `t - s != 0` trivially)

A surjective history tau : R -> BXPoint visiting all bx_le successors would give a full bidirectional truth bridge. This requires:
- `AddCommGroup R`, `LinearOrder R`, `IsOrderedAddMonoid R` (available in Mathlib)
- A surjection from `{r : R | r >= 0}` to `{v : BXPoint | bx_le w v}` (exists by cardinality, constructible via Choice)
- Shift-closure of the resulting Omega
- A generalized `canonical_task_frame` for arbitrary D

**Estimated effort**: 20-40 hours. Requires importing `Mathlib.Analysis.SpecificLimits.Basic` or similar for R instances, and cardinal arithmetic for surjection existence.

**Risk**: The surjection existence via `Cardinal` theory is standard but might require significant Mathlib plumbing.

### 4. Proof-Theoretic Reduction (Recommended Approach)

**Core idea**: Replace structural induction with well-founded induction on `(td_consequent, sizeOf)` with lexicographic ordering, where `td_consequent(psi.imp chi) = temporal_depth(chi)` and `td_consequent` is 0 for non-imp formulas.

**Temporal depth**:
```
td(atom) = 0, td(bot) = 0
td(imp A B) = td(A) + td(B)  -- or could use max
td(box A) = 1 + td(A)
td(G A) = 1 + td(A)
td(H A) = 1 + td(A)
```

**Reduction rules** (each decreases the measure):

| Original | Reduction | Justification |
|----------|-----------|---------------|
| `valid(psi -> G(alpha))` | `valid(P(psi) -> alpha)` | Semantic: P(psi) at t => exists s <= t with psi at s; valid gives G(alpha) at s; reflexive gives alpha at t |
| `valid(psi -> H(alpha))` | `valid(F(psi) -> alpha)` | Mirror: F(psi) at t => exists s >= t with psi at s; valid gives H(alpha) at s; reflexive gives alpha at t |
| `valid(psi -> box(alpha))` | `valid(diamond(psi) -> alpha)` | Diamond(psi) at (tau,t) => exists sigma in Omega with psi at (sigma,t); valid gives box(alpha) at (sigma,t) => alpha at (tau,t) |

**Lifting** (from `|- P(psi) -> alpha` to `|- psi -> G(alpha)`):
1. `|- P(psi) -> alpha` (by IH)
2. `|- G(P(psi) -> alpha)` (temporal_necessitation)
3. `|- G(P(psi)) -> G(alpha)` (temp_k_dist + MP)
4. `|- psi -> G(P(psi))` (connect_future_thm, BX4 axiom)
5. `|- psi -> G(alpha)` (transitivity: compose 4 and 3)

Similarly for H (using past_necessitation, past_k_dist, connect_past_thm) and box (using necessitation, modal_k_dist, modal_b).

**Measure verification**:
- `psi.imp G(alpha)` has td_consequent = 1 + td(alpha)
- `P(psi).imp alpha` has td_consequent = td(alpha)
- First lex component strictly decreases. Check.

**USF preservation**: P(psi) = psi.neg.all_past.neg. If psi is USF, then P(psi) is USF (all_past is allowed, imp and bot are allowed). Similarly for F and diamond.

### 5. Base Case Analysis (td_consequent = 0)

When the consequent chi is temporal-free (td = 0), we need `|- psi -> chi` from `valid(psi -> chi)`.

**Case split on valid(chi)**:
- **valid(chi)**: chi is temporal-free and valid. By `fragment_completeness` (sorry-free): `|- chi`. Then `|- psi -> chi` by `prop_s`. Done.
- **not valid(chi)**: Then not valid(psi) either (proof: valid(psi) + valid(psi -> chi) => valid(chi), contradiction). Both not valid.

For the "not valid chi" sub-case:

**Sub-case: psi is also temporal-free**: Then `psi.imp chi` is temporal-free. Use `fragment_completeness` directly. Done.

**Sub-case: psi contains G/H/box**: This is the remaining gap. We have `valid(psi -> chi)` where chi is temporal-free, psi is USF with temporal operators, and neither is valid.

**Analysis of this sub-case**: After the proof-theoretic reductions, the antecedent psi has the form `P^j(F^k(diamond^l(original_psi)))` for various j, k, l >= 0. This is a deeply nested formula built from P, F, diamond wrappings.

**Resolution via case split on valid(chi)**: When valid(chi) holds, we're done. When not valid(chi):

The key observation is that the current STRUCTURAL induction proof handles the imp case with `by_cases valid psi`, not `by_cases valid chi`. If we change to `by_cases valid chi`:
- valid(chi): fragment_completeness gives `|- chi`, then `|- psi -> chi` by prop_s. This works FOR ALL chi, not just temporal-free!

So a MUCH SIMPLER fix might work: **Change the case split in the existing proof from `by_cases valid psi` to `by_cases valid chi`!**

### 6. THE SIMPLE FIX: Split on valid(chi) Instead of valid(psi)

In the EXISTING structural induction proof at line 389:

```lean
| imp psi chi ih_psi ih_chi =>
  by_cases h_chi_valid : valid chi
  -- Case A: chi valid. ih_chi gives |- chi. prop_s gives |- psi -> chi.
  · obtain <d_chi> := ih_chi h_usf.2 h_chi_valid
    exact <DerivationTree.modus_ponens [] _ _ (DerivationTree.axiom [] _ (Axiom.prop_s chi psi)) d_chi>
  -- Case B: chi not valid. Then psi -> chi is not derivable only if...
  · -- chi not valid. From valid(psi -> chi):
    -- For any model where chi is false, psi must also be false.
    -- Contrapositive: psi not derivable (if psi were derivable, then valid psi by soundness,
    -- then valid chi from valid(psi -> chi), contradiction).
    -- So psi not derivable.
    -- But we need |- psi -> chi.
    -- Approach: split on structure of chi
    sorry
```

Wait, Case B with "not valid chi" still has the same problem. We still need to show `|- psi -> chi` when chi is not valid.

UNLESS we can avoid Case B entirely by showing Case A always applies. But Case A requires valid(chi), which doesn't follow from valid(psi -> chi) alone.

Hmm, but wait. What if we combine BOTH case splits?

```lean
by_cases h_chi : valid chi
| yes => ih_chi gives |- chi, then |- psi -> chi by prop_s
| no =>
  by_cases h_psi : valid psi
  | yes => valid psi + valid(psi -> chi) => valid chi. Contradiction with h_chi.
  | no => -- Neither valid. SORRY
```

The "yes, no" case gives a contradiction, so it's handled. The "no, no" case remains.

In "no, no": not valid psi, not valid chi, valid(psi -> chi). This is the HARD case.

For this case: by soundness contrapositive, if `|- psi` then `valid psi`, contradiction. So `not |- psi`. Similarly `not |- chi`. And `valid(psi -> chi)` but we don't know if `|- psi -> chi`.

### 7. The "No, No" Case: Neither psi nor chi is Valid

This is genuinely the hard case. Let me analyze whether it can actually arise for USF formulas.

**Claim**: If `valid(psi -> chi)`, `not valid(psi)`, `not valid(chi)`, with psi and chi USF, then `|- psi -> chi`.

This claim is EXACTLY what standard completeness theorems prove. The standard proof builds a canonical model. For the USF fragment without Until/Since, the canonical model only needs the {atom, bot, imp, box, G, H} truth lemma.

The fact that this case exists is exactly why we need a model construction. No purely proof-theoretic argument can avoid it.

**However**: the proof-theoretic REDUCTION approach converts this case into one where the consequent is temporal-free. And when the consequent is temporal-free:

Build MCS w from (psi -> chi).neg: psi in w, chi not in w.

On constant_history w model: valid gives truth_at psi -> truth_at chi.

truth_at chi <-> chi in w (by fragment_truth_iff, since chi is temporal-free).

So truth_at psi -> chi in w. Since chi not in w: not truth_at psi.

But truth_at psi on constant_history = truth_at flat(psi) = flat(psi) in w (by fragment_truth_iff).

So flat(psi) not in w. But psi in w.

**KEY QUESTION**: Is `psi in w` with `flat(psi) not in w` actually consistent?

For psi WITHOUT top-level imp: flat preserves membership direction (phi in w -> flat(phi) in w) for atom, bot, G, H, box. The only failure is imp.

If the original formula's antecedent psi has no imp at top level (e.g., psi = G(alpha)): psi in w -> flat(psi) = flat(alpha) in w (by G in w -> alpha in w -> IH). Contradiction with flat(psi) not in w.

If psi has imp at top level (e.g., psi = A -> B):
- (A -> B) in w and flat(A -> B) = flat(A) -> flat(B) not in w
- This means: flat(A) in w but flat(B) not in w (by imp_iff_mcs for the flat formula)
- But (A -> B) in w means A in w -> B in w
- And flat(A) in w: does A in w follow? Only if flat(A) in w -> A in w (REVERSE of the direction we need)

The REVERSE direction `flat(phi) in w -> phi in w` is what we'd need: "if the weakened formula is in w, then the original is too." This is `alpha in w -> G(alpha) in w`, which is FALSE in general. So the reverse direction fails.

**CONCLUSION on the "no, no" case with temporal-free consequent**:

When `psi` is NOT an imp at top level (psi = atom, bot, G(alpha), H(alpha), box(alpha)):
- `psi in w -> flat(psi) in w` is provable (using BX1 for G, mirror for H, box_iff_mcs + IH for box, identity for atom/bot)
- Combined with `flat(psi) not in w`: contradiction. The sorry is closable!

When `psi` IS an imp at top level:
- The imp case can be "unrolled" as I showed earlier: if chi' = psi'.imp chi'', then chi' not in w implies psi' in w and chi'' not in w
- After full unrolling: the "effective antecedent" is a conjunction of formulas, and the "effective consequent" is non-imp
- The non-imp effective consequent can then be handled

But this unrolling changes the formula structure, and we'd need to track it carefully.

**ACTUALLY**: in the well-founded induction with the G/H/box peeling reductions, the PRODUCED antecedent P(psi), F(psi), diamond(psi) is NEVER a top-level imp (P(psi) = psi.neg.all_past.neg which is an imp at top level: H(neg psi) -> bot).

Wait: P(psi) = (psi -> bot).all_past -> bot = ((psi -> bot).all_past).imp bot. So P(psi) IS an imp at top level! The antecedent is (psi -> bot).all_past = H(neg psi), and the consequent is bot.

So P(psi) = H(neg psi) -> bot. flat(P(psi)) = flat(H(neg psi) -> bot) = flat(H(neg psi)) -> bot = flat(neg psi) -> bot = (flat(psi) -> bot) -> bot = neg neg flat(psi).

And P(psi) in w means H(neg psi) not in w (in MCS sense). P(psi) in w -> flat(P(psi)) in w = neg neg flat(psi) in w = flat(psi) in w? Only if P(psi) in w -> flat(psi) in w.

P(psi) in w means exists v <= w with psi in v. flat(psi) in w requires flat(psi) in w specifically.

**This does NOT follow in general.** P(psi) in w tells us about v, not w.

### 8. Revised Assessment: The Full Truth Bridge on Large D May Be Necessary

After exhaustive analysis, I conclude:

1. **Proof-theoretic reduction** (well-founded induction peeling G/H/box from consequent) works for the non-base cases.

2. **The base case** (temporal-free consequent) CAN be handled when `valid(chi)` (use `fragment_completeness`).

3. **The remaining gap** is: `valid(psi -> chi)`, chi temporal-free, psi USF with temporal operators, neither valid. The constant-history model gives `flat(psi) not in w`, and `psi in w`, but `psi in w -> flat(psi) in w` fails for imp-containing psi.

4. **Closing this gap** seems to require EITHER:
   - A model where the full truth bridge works (Large D approach, ~20-40 hours)
   - A proof-theoretic lemma: `|- psi -> flat(psi)` for USF psi (which would give `psi in w -> flat(psi) in w`). But `|- G(alpha) -> alpha` is BX1, and `|- (A -> B) -> (flat(A) -> flat(B))` follows if `|- flat(A) -> A` (then A, B in context gives flat(A) -> A -> B -> flat(B)... no, we need flat(A) -> A which is `alpha -> G(alpha)`, NOT derivable)

5. **Alternative**: Instead of `|- psi -> flat(psi)`, prove `|- flat(psi) -> psi` (the reverse). This IS derivable for G: `|- alpha -> G(alpha)`... NO, this is NOT derivable (alpha doesn't imply G(alpha)). But `|- flat(psi) -> psi` for psi = G(alpha) would require `|- alpha -> G(alpha)`, which fails.

So neither `|- psi -> flat(psi)` nor `|- flat(psi) -> psi` is derivable in general.

## Recommended Approach

### Primary: Well-Founded Induction + Large D for Base Case

Restructure `usf_completeness` using well-founded induction on `(td_consequent, sizeOf)`:

**Phase A**: Handle non-imp cases (atom, bot, G, H, box) as currently done.

**Phase B**: Handle imp Case A (valid chi) using `fragment_completeness` for temporal-free chi, or IH for USF chi.

**Phase C**: Handle imp Case B (not valid chi, not valid psi):
- If td(chi) > 0: Apply proof-theoretic reduction (peel G/H/box from chi), use IH on reduced formula
- If td(chi) = 0:
  - If valid(chi): Case A
  - If not valid(chi) and chi temporal-free: Use Large D model or fragment_completeness if psi also temporal-free

**Estimated effort**:
- Phase A + B: 4 hours (mostly restructuring existing proof)
- Phase C (proof-theoretic reduction): 8 hours (defining measure, proving reductions, lifting)
- Phase C (base case): 4-8 hours if psi is always reducible to temporal-free; 20-40 hours if Large D needed

### Alternative: Direct via fmp_contrapositive

The FMP is sorry-free and gives: if phi in S for all closure MCS S, then `|- phi`. We need `valid(psi -> chi) -> (psi -> chi) in S for all closure MCS S`. This is the filtration truth lemma, which is marked as infrastructure-only. Completing this would also close the sorry, but requires the same truth bridge work.

## Confidence Level

- **Proof-theoretic reduction (non-base cases)**: HIGH (95%). The semantic argument for validity reduction is clean, the lifting is standard.
- **Base case via valid(chi) split**: HIGH for valid(chi) sub-case.
- **Base case "no-no" sub-case**: MEDIUM (50%). May require Large D construction, which is feasible but labor-intensive.
- **Overall**: MEDIUM-HIGH (65%). The approach is sound but the base case gap needs either a clever insight or significant infrastructure.

## Open Questions

1. Can the "no-no" base case actually arise for formulas produced by the proof-theoretic reductions? If the reductions always produce antecedents where `psi in w -> flat(psi) in w` holds, the gap vanishes.

2. Is there a proof-theoretic lemma bridging `psi in w` and `flat(psi) in w` that doesn't require `|- psi -> flat(psi)` or `|- flat(psi) -> psi`? For instance, using the MCS properties more cleverly.

3. Can the constant-history model be replaced by a TWO-state model (not two-point history) where the truth bridge for a SPECIFIC finite set of formulas works? The number of sub-formulas is finite, so only finitely many BXPoints matter.

4. Does the FMP filtration truth lemma (in the Decidability/FMP/ module) provide a simpler path? It's marked as infrastructure-only but the FMP itself is sorry-free.
