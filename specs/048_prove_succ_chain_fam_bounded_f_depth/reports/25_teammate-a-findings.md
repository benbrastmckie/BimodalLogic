# Research Report: Mathematical Analysis of closureWithNeg Negation Closure

**Task**: 48 - prove_succ_chain_fam_bounded_f_depth
**Teammate**: A (math-research-agent)
**Date**: 2026-03-23
**Focus**: Analyze closure properties of `closureWithNeg` and find mathematically correct path forward

## Key Findings

1. **The claim in report #22 is FALSE**: `closureWithNeg` is NOT closed under negation
2. **Precise characterization**: `closureWithNeg` has a ONE-LAYER negation property, not full closure
3. **The boundary case IS reachable**: `FF(psi) in closureWithNeg \ subformulaClosure` can occur
4. **Alternative path exists**: Case splitting + structural analysis of F-formulas provides a fix

## Mathematical Analysis

### Definition Review

From `SubformulaClosure.lean:94-95`:
```lean
def closureWithNeg (phi : Formula) : Finset Formula :=
  (subformulaClosure phi) ∪ (subformulaClosure phi).image Formula.neg
```

From `Formula.lean:272`:
```lean
def neg (φ : Formula) : Formula := φ.imp bot
```

So `closureWithNeg(phi)` consists of exactly two sets:
- **Set A**: `subformulaClosure(phi)` - all subformulas of phi
- **Set B**: `{g.neg | g in subformulaClosure(phi)}` = `{g.imp bot | g in subformulaClosure(phi)}`

### What IS Guaranteed (One-Layer Negation)

**Theorem (Existing)**: `neg_mem_closureWithNeg` (line 109-113)
```
For psi in subformulaClosure(phi): psi.neg in closureWithNeg(phi)
```

This gives us: if `psi in Set A`, then `psi.neg in Set B` (hence in closureWithNeg).

### What is NOT Guaranteed (Counter-example)

**Claim**: `closureWithNeg` is NOT closed under negation.

**Proof**: Let `g in subformulaClosure(phi)` where `g` is NOT of the form `h.imp bot` for any `h in subformulaClosure(phi)`.

Then:
- `g.neg = g.imp bot in Set B` (by construction)
- `neg(g.neg) = (g.imp bot).imp bot`

For `(g.imp bot).imp bot` to be in `closureWithNeg`, we need EITHER:
1. `(g.imp bot).imp bot in subformulaClosure(phi)` - requires double negation as explicit subformula
2. `(g.imp bot).imp bot = h.neg` for some `h in subformulaClosure` - requires `h = g.imp bot`

Case 2 requires `g.imp bot in subformulaClosure(phi)`, which means `g.neg` must be a subformula of phi (not just a negation we added). This is NOT guaranteed.

**Concrete counter-example**: Let `phi = p.box` (box of atom p).
- `subformulaClosure(phi) = {p, p.box}`
- `closureWithNeg(phi) = {p, p.box, p.neg, p.box.neg}`
- `p.neg = p.imp bot`
- `neg(p.neg) = (p.imp bot).imp bot`
- Is `(p.imp bot).imp bot in closureWithNeg(phi)`?
  - Not in `{p, p.box}` (not a subformula)
  - Is it in `{h.imp bot | h in {p, p.box}}`? This is `{p.imp bot, p.box.imp bot}`
  - `(p.imp bot).imp bot` would require `h = p.imp bot`, but `p.imp bot not in subformulaClosure`

Therefore `neg(p.neg) not in closureWithNeg(phi)`. QED.

### Application to the Sorries

At lines 2360 and 3012, we have:
- `FF(psi) in deferralClosure` (given)
- Need: `neg(FF(psi)) in deferralClosure` to apply negation completeness

Since `deferralClosure = closureWithNeg ∪ deferralDisjunctionSet ∪ backwardDeferralSet`, and the deferral sets don't contain negations of F-formulas, we need `neg(FF(psi)) in closureWithNeg`.

**Key observation**: `FF(psi) = some_future(some_future(psi))` where:
```lean
def some_future (psi : Formula) : Formula := psi.neg.all_future.neg
```

So `FF(psi) = (F(psi).neg.all_future).neg = G(neg(F(psi))).neg` - this IS of the form `h.neg`!

This means: `FF(psi) in Set B` (the negation-image set) when it's in `closureWithNeg`.

### Structural Analysis of F-Formulas in closureWithNeg

**Theorem** (needs verification): If `FF(psi) in closureWithNeg(phi)`, then EITHER:
1. `FF(psi) in subformulaClosure(phi)` (Set A), OR
2. `FF(psi) = g.neg` for some `g in subformulaClosure(phi)` (Set B)

For case 2: `FF(psi) = g.neg` means `G(neg(F(psi))) = g`, so `g = GG'(psi')` for some structure.

**Critical insight**: If `FF(psi) in Set B`, then `GG'(...) in subformulaClosure`. But what is `neg(FF(psi))`?

`neg(FF(psi)) = (G(neg(F(psi))).neg).neg = G(neg(F(psi))).neg.neg`

For this to be in closureWithNeg, we need `G(neg(F(psi))).neg in subformulaClosure` (which is `FF(psi)`).

**Result**: If `FF(psi) in Set B \ Set A`, then `FF(psi) not in subformulaClosure`, so `neg(FF(psi)) not in closureWithNeg`.

### Is the Boundary Case Reachable?

**Question**: In the calling context (`restricted_bounded_witness`), can we ever have `FF(psi) in closureWithNeg \ subformulaClosure`?

Let me trace the call path:
1. `restricted_bounded_witness` (line 3967) works with formulas from `f_content(chain(k))`
2. `f_content` extracts inner formulas from F-formulas: `{chi | F(chi) in u}`
3. The iteration applies `iter_F d psi` where `d` counts F-nesting depth

**Analysis**: If `F(psi) in chain(k)`, then `F(psi) in deferralClosure`.
- If `F(psi) in closureWithNeg`, then either `F(psi) in subformulaClosure` or `F(psi) = g.neg` for some g.
- `F(psi) = G(neg(psi)).neg`, so if in Set B, then `G(neg(psi)) in subformulaClosure`.

For `FF(psi)` to be in `closureWithNeg`:
- Either `FF(psi) in subformulaClosure` (F(psi) is a proper subformula with another F above it)
- Or `GG(neg(F(psi))) in subformulaClosure`

The boundary case `FF(psi) in Set B \ Set A` requires `GG(neg(F(psi))) in subformulaClosure` but `FF(psi) not in subformulaClosure`.

**Verdict**: This IS reachable. Consider `phi = GG(neg(F(p)))` for atom p. Then:
- `GG(neg(F(p))) in subformulaClosure(phi)` (it IS phi)
- `FF(p) = GG(neg(F(p))).neg in closureWithNeg` (in Set B)
- But `FF(p) not in subformulaClosure(phi)` (no F-formulas are subformulas of phi)

## Recommended Approach

### Option 1: Case Split with Structural Analysis (RECOMMENDED)

Split the proof based on membership:

```lean
-- Case A: FF(psi) in subformulaClosure
-- Then: neg(FF(psi)) in closureWithNeg (by neg_mem_closureWithNeg)
-- Negation completeness applies, proceed as planned

-- Case B: FF(psi) in closureWithNeg \ subformulaClosure
-- Then: FF(psi) = g.neg for some g in subformulaClosure
-- This means: g = G(neg(F(psi))) = GG'(neg psi) in subformulaClosure
-- Use structural properties of GG formulas instead of negation completeness
```

For Case B, the key is that if `GG(neg(F(psi))) in subformulaClosure`, then the GG-content analysis gives us information about `neg(F(psi))` propagation that may suffice.

### Option 2: Strengthen Theorem Signatures

Add hypothesis `h_FF_sub : FF(psi) in subformulaClosure(phi)` to the theorems at lines 2360 and 3012, then prove callers can provide this.

**Risk**: May push the problem up to `restricted_bounded_witness`, which would need the same analysis.

### Option 3: Use Existing GG Handling

When `FF(psi) in Set B`, we have `GG(neg(F(psi))) in subformulaClosure`. The G-content propagation (`g_persistence` in Succ) may provide an alternative path:

- If `GG(chi) in u`, then by G-content: `G(chi) in v` for successor v
- This gives us `G(neg(F(psi))) in v` when `GG(neg(F(psi))) in u`
- Modal properties of G may give us `neg(F(psi)) in v` under certain conditions

## Evidence/Proofs

### Verified in Source Code

1. **Definition check**: `closureWithNeg` at `SubformulaClosure.lean:94-95` confirmed
2. **Negation definition**: `Formula.neg` at `Formula.lean:272` confirmed as `phi.imp bot`
3. **F-formula structure**: `some_future` at `SubformulaClosure.lean:408-409` confirmed as `psi.neg.all_future.neg`
4. **Existing lemma**: `neg_mem_closureWithNeg` (line 109) only works for subformulaClosure members
5. **No double-negation closure lemma exists**: Searched for `neg.*neg.*closureWithNeg` - not found

### Counter-example Verified

The counter-example `phi = p.box` is valid:
- `subformulaClosure(p.box) = {p, p.box}` (atoms and box)
- `closureWithNeg(p.box) = {p, p.box, p.imp bot, (p.box).imp bot}`
- `neg(p.imp bot) = (p.imp bot).imp bot` is NOT in this set

## Confidence Level

**HIGH** for the mathematical analysis:
- The counter-example is concrete and verifiable
- The structure of `closureWithNeg` is clear from the definition
- The claim in report #22 is definitively FALSE

**MEDIUM** for the recommended approach:
- Option 1 (case split) is mathematically sound but requires careful implementation
- The GG-content path in Case B needs verification against the actual Succ definition
- May discover additional complications when implementing

## Summary

The false claim that `closureWithNeg` is closed under negation blocked plan v12. The actual closure property is ONE-LAYER: negations of subformulaClosure members are included, but negations of those negations are NOT (unless they happen to be subformulas).

The fix requires splitting the proof based on whether `FF(psi) in subformulaClosure` or `FF(psi) in closureWithNeg \ subformulaClosure`. The second case must use structural properties of GG-formulas rather than negation completeness.
