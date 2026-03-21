# Phase 3 Handoff: forward_F Coverage Argument

**Task**: 916
**Phase**: 3 (Prove Coverage Argument / forward_F)
**Date**: 2026-02-20
**Session**: sess_1771634621_f7a06b
**Status**: PARTIAL - Mathematical obstruction identified

## Immediate Next Action

**Replace the flat chain construction with an omega^2 inner chain construction.**

The current flat chain (one formula processed per step via Encodable enumeration) is mathematically insufficient for forward_F. The forward_F property requires that for every F(psi) in M_t, psi appears in some M_s with s > t. The flat chain places psi at a FIXED step (encodeFormula(psi) + 1) which may be BEFORE t, and psi does not persist through the chain (it's not in GContent).

## Current State

**File**: `Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean`
**Lines of interest**: 1617 (forward_F sorry), 1624 (backward_P sorry)
**Build status**: Clean build (2 sorries, same as before Phase 3)

### Changes Made in This Session

1. **Moved formula enumeration** (`formulaEncodable`, `decodeFormula`, `encodeFormula`, `decodeFormula_encodeFormula`) to BEFORE the dovetail chain definitions (from line ~990 to line ~479).

2. **Added `Classical.propDecidable` attribute** before the chain definitions (needed for decidable set membership in match expressions).

3. **Added witness placement to `dovetailForwardChainMCS`**: The forward chain now processes `decodeFormula(n)` at step n+1, placing psi in the seed if `F(psi) ∈ chain(n)`. Similarly for `dovetailBackwardChainMCS` with P-formulas. This matches the `witnessForwardChainMCS`/`witnessBackwardChainMCS` structure.

4. **Made `witnessForwardChainMCS`/`witnessBackwardChainMCS` aliases** for `dovetailForwardChainMCS`/`dovetailBackwardChainMCS` (for backward compatibility with Phase 1/2 lemma names).

5. **Fixed all proofs** that unfold the chain definitions (GContent_extends, HContent_extends, witness_placed, etc.). All compile without sorry.

6. **Removed duplicate definitions** from the omega^2 section (formulaEncodable, decodeFormula, encodeFormula were previously defined in both locations).

### Verified Properties

- `lake build` succeeds with only the 2 pre-existing sorries (forward_F, backward_P)
- All Phase 1/2 lemmas still compile (coverage_of_le, F_persists, G_neg_persists, etc.)
- All forward_G, backward_H, cross-sign propagation proofs unaffected

## Mathematical Obstruction

### Why the Flat Chain Fails

The flat chain processes formula `decodeFormula(n)` at step n+1. Each formula is processed exactly ONCE (at step `encodeFormula(psi) + 1`). Given `F(psi) in chain(n)`:

1. **Case encodeFormula(psi) = n**: Witness fires at step n+1. psi in chain(n+1). s = n+1 > n. **WORKS.**

2. **Case encodeFormula(psi) < n**: By coverage_of_le, psi in chain(encodeFormula(psi)+1). But encodeFormula(psi)+1 <= n, so s <= n. psi does NOT persist through the chain (it's not a G-formula, so not in GContent). **FAILS - no s > n.**

3. **Case encodeFormula(psi) > n**: F(psi) may not persist from step n to step encodeFormula(psi). G(neg(psi)) can enter via GContent at any step (since G(G(neg(psi))) might be in chain(n), and G(G(neg(psi))) and F(psi) = neg(G(neg(psi))) can coexist in an MCS). **FAILS - F(psi) persistence not guaranteed.**

### Why F(psi) Doesn't Persist

`F(psi) = neg(G(neg(psi)))`. At step n+1, `G(neg(psi))` enters chain(n+1) if `G(G(neg(psi))) in chain(n)` (because `G(neg(psi)) in GContent(chain(n))`).

Key: `G(G(neg(psi)))` and `F(psi) = neg(G(neg(psi)))` CAN coexist in an MCS! In temporal logic with strict future:
- G(G(neg(psi))) = "at all future t, at all t' > t, neg(psi)"
- F(psi) = "at some future t, psi"
- Compatible: psi at time 1, neg(psi) at all times > 1

The 4-axiom gives `G(phi) -> G(G(phi))` but NOT `G(G(phi)) -> G(phi)`.

### Why Omega^2 Pairing Doesn't Help Either

Using `decodeFormula(Nat.unpair(n).2)` processes each formula infinitely often. But G(neg(psi)) can still enter at step n+1 (via GContent) before the next processing step for psi. The gap between consecutive processing steps can be arbitrarily large.

## Correct Approach: Inner Chain Construction

### Architecture

```
chain(n+1):
  -- Build inner chain starting from GContent(chain(n))
  inner(0) = Lindenbaum(GContent(chain(n)))
  inner(k+1):
    let psi_k = decodeFormula(k)
    if F(psi_k) in inner(k):
      Lindenbaum({psi_k} union GContent(inner(k)))
    else:
      Lindenbaum(GContent(inner(k)))

  -- chain(n+1) = inner(N) for sufficiently large N
  -- OR: chain(n+1) extends the union of all inner steps
```

### Why This Works for forward_F

Given `F(psi) in chain(n)`:
1. chain(n+1) extends GContent(chain(n))
2. F(psi) in chain(n) => neg(G(neg(psi))) in chain(n) => G(neg(psi)) not in chain(n)
3. {psi} union GContent(chain(n)) is consistent (by temporal_witness_seed_consistent)
4. At inner step encodeFormula(psi)+1, the inner chain processes psi
5. Since the inner chain starts from GContent(chain(n)), and F(psi) might or might not be in inner(0)...

Actually wait, this has the SAME problem. F(psi) in chain(n) does NOT imply F(psi) in inner(0) = Lindenbaum(GContent(chain(n))).

### Revised Approach: Witness-Augmented Seed

```
chain(n+1) = Lindenbaum(WitnessSeed(chain(n)))

WitnessSeed(M) = {psi : F(psi) in M and encodeFormula(psi) = rank(M)} union GContent(M)
```

where rank(M) is some function that cycles through all formulas. But we can't include ALL F-witnesses simultaneously (they might be inconsistent - e.g., F(p) and F(neg(p)) both in M but {p, neg(p)} inconsistent).

### Correct Revised Approach: One Witness Per Step

```
chain(0) = Lindenbaum(base)
chain(n+1):
  let psi_n = decodeFormula(n)
  if F(psi_n) in chain(n):
    Lindenbaum({psi_n} union GContent(chain(n)))
  else:
    Lindenbaum(GContent(chain(n)))
```

This is exactly our current construction! The issue is proving forward_F for encodeFormula(psi) < n.

### The Missing Piece

For `encodeFormula(psi) < n` and `F(psi) in chain(n)`:
- psi was witnessed at step encodeFormula(psi)+1
- psi in chain(encodeFormula(psi)+1) but NOT in chain(n+1)
- We need psi at some step > n

**Key realization**: We should output `s` as `encodeFormula(psi) + 1` ONLY when `encodeFormula(psi) + 1 > n`. For the case where `encodeFormula(psi) + 1 <= n`, we need the witness to fire AGAIN.

**This requires processing each formula infinitely often, AND ensuring the witness fires at a step > n.**

### Proposed Solution: Changed Enumeration

Instead of `decodeFormula(n)`, use `decodeFormula(n mod (n+1))` or similar cycling scheme. This doesn't work because it doesn't cover all formulas.

### Actually Correct Solution

Use `decodeFormula(n)` but recognize that the Encodable enumeration maps ALL naturals to formulas (it's surjective). So encodeFormula(psi) is the UNIQUE pre-image. But we need psi to be processed MULTIPLE times.

**The real fix**: Use a surjection that hits each formula infinitely often. For example, `decodeFormula(Nat.unpair(n).2)`. Then formula psi is processed at steps `Nat.pair(k, encodeFormula(psi)) + 1` for all k = 0, 1, 2, ....

Given F(psi) in chain(n), take k large enough that `m = Nat.pair(k, encodeFormula(psi)) > n`. At step m, either F(psi) in chain(m) (witness fires at m+1 > n) or G(neg(psi)) in chain(m).

If G(neg(psi)) in chain(m): let j be the first step > n where G(neg(psi)) enters. Then F(psi) in chain(j-1). We need j-1 to be a processing step for psi AND j-1 > n.

**This is NOT guaranteed.**

### The Fundamental Issue

The fundamental issue is that F(psi) can die at ANY step (when G(neg(psi)) enters via GContent). The witness can only fire when psi is being processed. Between the death of F(psi) and the next processing step, psi cannot be witnessed.

### True Solution

The true solution requires one of:
1. **Modify the seed** at step n+1 to include psi when F(psi) in chain(n) AND encodeFormula(psi) = n. This is our current construction. It only works for one specific psi per step.

2. **Use a directed limit construction**: Build an inner chain at each step that processes ALL formulas. Take the limit (using Zorn's lemma on the directed system of inner MCSes). This is the textbook approach but requires proving the directed system has an upper bound.

3. **Use Classical.choice** to directly construct the witness MCS for each F(psi): Since {psi} union GContent(chain(n)) is consistent, there exists an MCS M' extending it. Use M' as the next step. But this only witnesses ONE formula per step, and we need the construction to be uniform.

4. **Countable choice / dependent choice**: Enumerate all F-obligations and process them one at a time, building an omega chain. This is essentially the omega^2 approach.

## Recommendation

Approach 4 is most viable. The construction:

```lean
-- At step n+1, process the (n mod (max_formula_index + 1))-th formula
-- Wait, this doesn't work for the same reasons.
```

Actually, I believe the correct approach is:

**Define chain using well-ordering of formulas in the MCS:**

At step n+1:
- Compute round = n / totalFormulas, index = n % totalFormulas (conceptually)
- Process formula with index `index`

But Formula is infinite, so totalFormulas is infinite.

**Simplest working approach**: Abandon the flat chain. Prove forward_F by constructing the witness MCS directly using Classical.choice:

```lean
lemma forward_F : F(psi) in chain(n) -> exists s > n, psi in chain(s) := by
  -- Use temporal_witness_seed_consistent to show {psi} union GContent(chain(n)) is consistent
  -- Lindenbaum gives MCS M' extending {psi} union GContent(chain(n))
  -- But M' is NOT chain(n+1)! It's a separate MCS.
  -- We need psi in chain(s), not in some arbitrary MCS.
  sorry
```

This doesn't work because the witness MCS is not part of the chain.

## What NOT to Try

1. **Flat chain with single formula enumeration**: Proven insufficient (encodeFormula(psi) < n case).
2. **Omega^2 pairing alone**: Same fundamental issue (gap between processing steps).
3. **F(psi) persistence argument**: F(psi) does NOT persist (G(G(neg(psi))) can coexist with F(psi) in an MCS, causing G(neg(psi)) to enter at the next step).
4. **Coverage_of_le for arbitrary n**: Only gives psi at step encodeFormula(psi)+1, which may be <= n.

## Critical Context

1. The 2 sorries (forward_F, backward_P) are the ONLY remaining obstacles to replacing the `temporal_coherent_family_exists` AXIOM with a THEOREM.
2. The forward_G and backward_H proofs (600+ lines) are fully proven and work with the current chain structure.
3. The coverage lemmas from Phase 2 (coverage_of_le, F_persists, G_neg_persists) are all correct but insufficient for forward_F.
4. The `temporal_witness_seed_consistent` lemma is the mathematical foundation - it proves {psi} union GContent(M) is consistent when F(psi) in M.
5. The issue is structural: how to BUILD a LINEAR chain that places witnesses at the right times.

## References

- Plan: specs/916_implement_fp_witness_obligation_tracking/plans/implementation-003.md
- Research: specs/916_implement_fp_witness_obligation_tracking/reports/research-003.md
- Target file: Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean
- Key lemma: `forward_temporal_witness_seed_consistent` (line ~398)
- Coverage lemma: `witnessForwardChain_coverage_of_le` (line ~1528)
