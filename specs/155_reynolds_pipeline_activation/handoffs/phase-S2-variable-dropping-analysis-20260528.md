# Phase S2: Variable Dropping and Interval Splitting Analysis

## Session: sess_1748390400_s2xfer
## Date: 2026-05-28

## Status: BLOCKED - Mathematical obstacle identified

## Summary

Extensive analysis (7000+ words of mathematical reasoning) confirms that the 4-variable existential transfer at depth j' inside `nf_2var_existential_transfer` cannot be closed using the existing infrastructure. The fundamental obstacle is **interval splitting**: proving that sub-interval type data is preserved when a zone-matched point splits an interval.

## The Sorry Goal (unchanged from S1)

At line 2335 (forward) and 2417 (backward) in StaviCompleteness.lean:

```
(exists w', nf_eval_nf M' j' 4 (w'::u'::x'::t') sub_nf) <->
(exists w,  nf_eval_nf M  j' 4 (w ::u ::x ::t)  sub_nf)
```

Context: bridge hypotheses at depth k for (x,t)/(x',t'), zone-matched u/u' with depth-k 1-var NF agreement, j'+1 < k.

## Approaches Analyzed and Why They Fail

### 1. Zone matching on (x,t) for the new point w

Zone matching gives w' with correct orderings relative to x' and t', and same depth-k 1-var NF. BUT: the ordering w' vs u' is NOT determined when w and u are in the same zone of (x,t). The interval types for (x,t) only record WHICH types appear, not their spatial arrangement within the interval.

**Concrete counterexample**: In M, x < w < u < t with types A, B, C, D. In M', the same types exist between x' and t', but a B-type point might be above u' instead of below it.

### 2. Using u's depth-k NF to find w' < u'

The depth-k NF of u has quantifier data about depth-(k-1) 2-var NFs (v, u). From this, exists v' < u' with same depth-(k-1) 2-var NF. By the **variable dropping lemma** (proved correct in analysis), v' has the same depth-(k-1) 1-var NF as w. But we need depth-k NF AND x' < v'.

**Variable dropping lemma** (validated): from shared depth-j n-var NF, any sub-tuple has the same depth-j m-var NF (m <= n). This is a key result but only helps with the 1-var extraction, not the positional constraint.

### 3. Using x's depth-k NF to find w' > x'

Symmetric to approach 2: get v'' > x' with same depth-(k-1) 1-var NF. But v'' might not satisfy v'' < u'.

### 4. Combining witnesses from u's and x's NFs

Two witnesses: v' < u' (from u's NF) and v'' > x' (from x's NF). Both have same depth-(k-1) 1-var NF as w. But neither is guaranteed to be in the target interval (x', u').

### 5. Full interval bridge to find w' in (x', t')

Bridge at depth k+1 gives w' with x' < w' < t' and same depth-(k+1) NF. Hence same depth-k NF. But w' is NOT guaranteed to be below u'.

### 6. Fraisse compression approach

Prove 3-var NF agreement at depth j'+1 between (u,x,t)/(u',x',t'). This requires 4-var transfer at depths < j'+1, which is exactly what we're proving. Circular.

### 7. IH from induction on k (restructured theorem)

Restructure as induction on k. IH at k gives bridge result at depth k. But establishing bridge at depth k for sub-pairs (x,u)/(x',u') requires interval types at depth k for the sub-interval, which is the interval splitting problem.

## The Root Cause: Interval Splitting

**Interval splitting** asks: given bridge at depth d for (x,t)/(x',t') and zone-matched u with x < u < t, prove:

```
interval_nf_types M d' x u = interval_nf_types M' d' x' u'
```

for some d' related to d.

**This is NOT derivable from the current hypotheses** because:

1. `interval_nf_types` records a SET of NF types present in an interval, not their spatial arrangement.
2. The "below u" types from u's NF include types below x (outside the target interval).
3. The "above x" types from x's NF include types above u (outside the target interval).  
4. The intersection of "below u" and "above x" types is NOT equal to the types between x and u (a type might have one witness below u and another above x, with no single witness between x and u).
5. The full interval types at depth d for (x,t) include types in the sub-interval AND outside it, with no way to distinguish.

## The Mathematical Resolution

The standard EF game argument (GHR93 Proposition 7) works because:

1. **In GHR93**: types are COMPLETE rank-r Stavi types that encode EVERYTHING about temporal neighborhoods. The game maintains a BIJECTION between matched points with preserved orderings and types. Interval splitting is implicit because the game position encodes the full configuration.

2. **In our NF framework**: the 1-var NF at depth k is an INCOMPLETE description that doesn't encode interactions with specific other points. The `interval_nf_types` set loses spatial information. Zone matching relative to the base pair is insufficient for multi-variable transfer.

The correct fix requires ONE of:

### Option A: Strengthen the zone matching (RECOMMENDED, ~200-300 lines)

Prove a **splitting zone match** that finds u' satisfying:
```
interval_nf_types M (k-1) x u = interval_nf_types M' (k-1) x' u'
interval_nf_types M (k-1) u t = interval_nf_types M' (k-1) u' t'
```

This loses ONE depth level (from k to k-1) per split. The proof:
- From u's depth-k NF quantifier part: which depth-(k-1) 2-var NFs are realized.
- Use the variable dropping lemma to extract depth-(k-1) 1-var NFs.
- The "directional" 2-var NFs (v < u vs v > u) split into "below u" and "above u" types at depth k-1.
- Combined with the full interval types at depth k-1 (from depth_decrease), this gives the sub-interval types at depth k-1.

**Problem**: as analyzed, the intersection of "below u" and "interval(x,t)" is NOT equal to "interval(x,u)". A different argument is needed.

**Possible resolution**: Instead of using the interval type SET, define a STRONGER splitting invariant that records which 2-var NFs of (v, u) with v between x and u are realized. This directional data IS extractable from u's depth-k NF and the interval types at depth k.

### Option B: Replace interval_nf_types with a stronger invariant (~300-400 lines)

Replace `interval_nf_types` (a `Finset` of 1-var NFs) with a richer structure that records directional information: for each NF type tau and reference point r, whether a tau-point exists above/below r within the interval. This captures the spatial arrangement needed for interval splitting.

### Option C: Direct EF game formalization (~400-500 lines)

Define game positions as sorted sequences of matched points with a bridge invariant. Prove the strategy lemma (Duplicator can always respond). Derive NF agreement from the game result.

This is the most principled approach but requires the most infrastructure.

## The Variable Dropping Lemma (Proved Correct)

A key positive result from this analysis: **depth-j n-var NF agreement implies depth-j m-var NF agreement for any sub-tuple (m <= n)**, with NO depth loss.

**Proof sketch** (by induction on j):
- Base j = 0: n-var atoms include all m-var atoms (just restrict atom assignments).
- Step j+1: n-var quantifier (about (n+1)-var extensions at depth j) determines m-var quantifier (about (m+1)-var extensions at depth j) because each (m+1)-var extension corresponds to a specific (n+1)-var extension (fixing the extra n-m variables). By IH at j, the (n+1)-var NF agreement gives (m+1)-var NF agreement for the sub-tuple extension.

This lemma is NOT currently formalized but would be useful for any approach.

## Immediate Next Action

The implementer should:
1. Choose between Options A, B, or C above
2. If Option A: prove the directional splitting variant of interval types
3. Restructure `nf_2var_existential_transfer` with well-founded induction on k
4. Close the sorry using the splitting + IH

## Key Files

- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean` (sorries at lines 2335, 2417)
- `Theories/Bimodal/Metalogic/WeakCanonical/NormalForm.lean` (NF definitions, nf_agreement_monotone)

## Proof State at Sorry Sites

Forward (line 2335):
```
h_nf_u : nf_characteristic M k 1 u = nf_characteristic M' k 1 u'
h_ux : u < x <-> u' < x'
h_xu : x < u <-> x' < u'
h_ut : u < t <-> u' < t'
h_tu : t < u <-> t' < u'
h_3var_atoms : forall a, atom_eval M (u::x::t) a <-> atom_eval M' (u'::x'::t') a
hj : j' + 1 < k
hu_quant : forall sub_nf, (exists w, nf_eval_nf M j' 4 (w::u::x::t) sub_nf) <-> chi.2 sub_nf = true
sub_nf : NormalForm sig j' (2+1+1)
goal: (exists w', nf_eval_nf M' j' 4 (w'::u'::x'::t') sub_nf) <-> 
      (exists w, nf_eval_nf M j' 4 (w::u::x::t) sub_nf)
```

Backward (line 2417): symmetric (M <-> M').
