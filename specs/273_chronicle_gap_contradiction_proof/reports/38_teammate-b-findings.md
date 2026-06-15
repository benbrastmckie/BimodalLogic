# Teammate B Findings: Alternative Approaches (BracketFormula, Hybrid, Direct)

## Key Findings

### Approach B: BracketFormula k (Sorting Witnesses) -- MOST PROMISING

**IntervalPattern.holds Requirements (ExistsForallNF.lean:106-132)**:
For `n+1` witnesses, `IntervalPattern.holds` requires:
```
exists (witnesses : Fin (n + 1) -> M.carrier),
  (forall i j : Fin (n + 1), i < j -> witnesses i < witnesses j) AND
  (forall i : Fin (n + 1), z0 < witnesses i AND witnesses i < z1) AND
  (forall i : Fin (n + 1), (pat.alpha i).eval_at M atomMap (witnesses i)) AND
  [segment type conditions on intervals between consecutive witnesses]
```

**The Sorting Feasibility**:
Mathlib provides `Tuple.sort` (in `Mathlib.Data.Fin.Tuple.Sort`) which gives a permutation `sigma : Perm (Fin n)` such that `f . sigma` is monotone. Key lemmas:
- `Tuple.monotone_sort`: `Monotone (f . (Tuple.sort f))`
- `Monotone.strictMono_of_injective` (in `Mathlib.Order.Monotone.Defs`): given `Monotone f` and `Injective f`, yields `StrictMono f`

Additionally, `Finset.orderEmbOfFin` (in `Mathlib.Data.Finset.Sort`) provides an order embedding `Fin k ↪o alpha` for a finset of size k, giving a strictly monotone enumeration directly.

**The Real Problem with Approach B is NOT sorting -- it is the alpha assignment**:
IntervalPattern.holds assigns `alpha i` (point type) to the `i`-th witness in order. If we have k positive between_tx SSNs, each with a different characteristic formula `char_y_j`, we need to assign them to ordered witnesses. After sorting witnesses into w_0 < w_1 < ... < w_{k-1}, the alpha assignment must match: `alpha i` = characteristic of the witness that ended up at position i.

But in the BACKWARD direction (nf_eval -> holdsLeft), `h_eval_quant` gives one witness per SSN, and we know they are distinct (different SSNs can have different y-predicates, but two SSNs could potentially share the same witness point). The witnesses may not even be distinct, let alone injectable into a strictly ordered sequence.

However: at depth 0, two witnesses y1, y2 satisfying different SSN characteristics (different predicate patterns) at the same point would require conflicting predicate truth values, so they ARE distinct. This means h_eval_quant gives k DISTINCT witnesses in (t,x).

**Approach B verdict**: Technically feasible but requires:
1. A proof that between_tx SSN witnesses are distinct (via predicate incompatibility)
2. Sorting via Tuple.sort + Monotone.strictMono_of_injective
3. Constructing the alpha permutation (matching SSN to sorted witness position)
4. Rebuilding the BracketFormula with k witnesses and correct alpha/beta assignments
5. Changing `enriched_vecEA2_until` from returning `VecEA2 0` to `VecEA2 k`
6. Proving the segment type conditions (seg_guard holds between consecutive sorted witnesses)
7. Modifying `forward_nf_eval_of_holdsLeft` and `backward_holdsLeft_of_nf_eval`

This is a MAJOR refactor of the VecEA2 construction. The backward direction would become more complex because it needs to extract individual SSN witnesses from the ordered bracket witnesses.

**BUT there is a much simpler realization**: The translateLeft mechanism for VecEA2 uses `bracketBuildRight` which creates NESTED Until formulas:
```
seg_guard Until (char_y1 AND seg_guard Until (char_y2 AND ... Until (char_x AND rest)))
```
This nesting naturally produces strictly ordered witnesses bounded in (t, x). So using BracketFormula k > 0 is EQUIVALENT to nested Until -- it is not a separate approach from what Approach A (nested Until) would produce.

### Approach C: Hybrid n=0 + Until in endpointLeft -- NOT VIABLE

**VecEA2.holdsLeft structure (VecEATranslation.lean:250-256)**:
```
holdsLeft at t = endpointLeft.eval_at t AND
  exists z1 > t, endpointRight.eval_at z1 AND bracket.holds t z1
```

**Key constraint**: endpointLeft is evaluated at t BEFORE the existential witness z1 (= x) is chosen. It is independent of x.

**TemporalPred type**: Just a wrapper around `Formula` -- no restrictions on formula complexity. endpointLeft CAN contain Until/Since formulas.

**Why it fails**: For between_tx (t < y < x), we need "exists y with t < y < x". If we put `Formula.untl char_y Formula.top` in endpointLeft (evaluated at t), this says "exists y > t with char_y(y)" -- but provides NO upper bound y < x. The endpointLeft formula cannot reference x because x has not been chosen yet.

Putting the constraint at endpointLeft fails for the SAME reason that putting it at endpointRight fails: a formula evaluated at a single point can enforce only a one-sided bound. Only the bracket formula on (t, x) has access to BOTH endpoints.

**Approach C verdict**: NOT viable. The fundamental issue is that between_tx requires BOTH endpoints to be known, which only the bracket (or nested Until evaluated from t reaching through to x) can provide.

### Approach D: Direct Formula (bypass VecEA2) -- POSSIBLE BUT EQUIVALENT TO B

**Downstream interface**: `existPart_succ_n1_bypass_k0` returns `exists (A : Formula), ...`. Consumers (RabinovichNegation.lean:270, NfCharFormula.lean:641-650) only need a `Formula` -- they don't depend on VecEA2 structure.

**What enriched_bypass_until produces**: Via `VVecEA2.translateLeft`, it produces a Formula. The VecEA2 is only an intermediate structure used to organize the proof.

**A direct Formula for between_tx**:
For k positive between_tx SSNs with characteristics char_y1, ..., char_yk:
```
Formula.untl
  (char_y1 AND Formula.untl
    (char_y2 AND Formula.untl
      (... AND Formula.untl (char_x AND rest) seg_guard)
    seg_guard)
  seg_guard)
```
evaluated at t. This gives: exists w1 > t with char_y1(w1) AND seg_guard on (t, w1) AND exists w2 > w1 with char_y2(w2) AND seg_guard on (w1, w2) AND ... AND exists x' > w_{k-1} with char_x(x') AND seg_guard on (w_{k-1}, x').

This is EXACTLY what `bracketBuildRight` produces from a BracketFormula k!

**Approach D verdict**: Technically possible but would duplicate the bracketBuildRight correctness proof. No benefit over Approach B -- it IS Approach B without the VecEA2 wrapper.

**What would change if bypassing VecEA2**:
1. Need to write `bracketBuildRight` correctness from scratch (already exists in VecEATranslation.lean)
2. Need to handle the disjunction over nf_x values directly
3. Loss of the clean VecEA2 decomposition used elsewhere in the proof
4. Would still need to prove the same semantic equivalences

## Recommended Approach

**APPROACH B (BracketFormula k)** is the correct and minimal fix, but it should be understood as using the EXISTING VecEA2/BracketFormula infrastructure with k > 0 instead of k = 0.

The specific change required:
1. In `enriched_vecEA2_until`, change from `BracketFormula.trivial seg_guard` (n=0) to a `BracketFormula k` where k = number of positive between_tx SSNs
2. Set `alpha i` = `char_y_i` for the i-th positive between_tx SSN (in some fixed enumeration order)
3. Set `beta i` = `seg_guard` for all segment types
4. Remove the `Formula.snce char_y Formula.top` encoding from endpointRight
5. The VecEA2.translateLeft mechanism will automatically produce the correct nested Until formula

**Why this works**: The BracketFormula.holds for k > 0 requires witnesses to be strictly increasing and bounded in (t, x). This is exactly the "t < y < x" constraint that Since/Until at a single point cannot express.

**The backward direction** (nf_eval -> holdsLeft) needs:
- Prove h_eval_quant gives k distinct witnesses (via predicate incompatibility at depth 0)
- Sort them using Tuple.sort or Finset.orderEmbOfFin
- Map sorted positions to the SSN enumeration

**The forward direction** (holdsLeft -> nf_eval) becomes EASIER:
- BracketFormula.holds gives k strictly ordered witnesses in (t, x) with correct point types
- Each witness directly satisfies its SSN via the alpha assignment
- No more Since formula decomposition needed -- witnesses are already bounded

**Estimated complexity**: Medium. The VecEA2 infrastructure handles translation. Main work is:
1. Constructing BracketFormula k with correct alpha/beta (~30-50 lines)
2. Witness distinctness proof for backward direction (~40-60 lines)
3. Sorting + alpha mapping for backward direction (~30-50 lines)
4. Forward direction simplification (removes sorry, ~20-30 lines simpler than current)
5. Mirror for Since direction (~similar effort)

## Evidence/Examples

**IntervalPattern.holds for n=0 vs n=k** (ExistsForallNF.lean):
- n=0 (current): `forall y, z0 < y -> y < z1 -> beta(y)` -- only universal quantification in interval
- n=k (proposed): `exists witnesses, strictly_ordered AND in (z0,z1) AND alpha_i at witness_i AND beta on segments` -- existential witnesses bounded in interval

**VecEA2.translateLeft** (VecEATranslation.lean:246-247):
```lean
noncomputable def VecEA2.translateLeft {n : Nat} (vea : VecEA2 n) : Formula :=
  Formula.and vea.endpointLeft.formula (bracketBuildRight vea.bracket vea.endpointRight)
```
`bracketBuildRight` with k-witness bracket produces nested Until with k intermediate witnesses.

**Mathlib tools for sorting** (available in project's Mathlib):
- `Tuple.sort` at `Mathlib.Data.Fin.Tuple.Sort` -- gives permutation to monotone
- `Monotone.strictMono_of_injective` at `Mathlib.Order.Monotone.Defs` -- injective + monotone = strictly monotone
- `Finset.orderEmbOfFin` at `Mathlib.Data.Finset.Sort` -- direct strictly monotone enumeration of finset

**Sorry locations and their resolution under Approach B**:
1. `forward_nf_eval_of_holdsLeft` (line 2205): RESOLVED -- bracket witnesses are bounded in (t,x) by construction
2. `existPart_succ_n1_bypass_k0_since` forward (line 2380): RESOLVED -- mirror of above
3. `existPart_succ_n1_bypass_k0_since` backward (line 2382): RESOLVED -- sorting gives ordered witnesses

## Confidence Level

**HIGH** -- The analysis is grounded in:
1. Precise type signatures from the codebase (IntervalPattern.holds, VecEA2.holdsLeft, BracketFormula)
2. Verified existence of Mathlib sorting lemmas (Tuple.sort, Finset.orderEmbOfFin, Monotone.strictMono_of_injective)
3. The mathematical correctness is guaranteed by the VecEA2/BracketFormula infrastructure which already handles the nested Until translation
4. The fundamental insight (only bracket has access to both endpoints) rules out Approaches C and D as independently viable
5. Approach B uses existing proven infrastructure (VecEATranslation.lean) rather than requiring new correctness proofs
