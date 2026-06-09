# Phase 1 Handoff: v14 Arity-Parametric Transfer (Blocked)

**Task**: 273
**Session**: sess_1781031097_68830a
**Timestamp**: 2026-06-09T20:52:10Z
**Status**: BLOCKED at Phase 1

## Immediate Next Action

Implement the 2-var interval type machinery (5 lemmas, ~300-500 lines) to break
the circularity between zone matching, interval data, and the existential transfer.

## Current State

- **File**: `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean`
- **Sorry sites**: Lines 2405, 2487, 2857 (unchanged from before this session)
- **No code changes made**: The analysis phase revealed that the plan's approach is
  correct but the implementation requires solving a non-trivial "NF projection"
  sub-problem first.

## Key Findings

### The Arity Escalation Problem (Confirmed)

The sorry at line 2405 needs 4-var transfer at depth j' for config (u,x,t)/(u',x',t')
where j'+1 < k. Zone matching u from (x,t) gives u' with matching 1-var NF and orderings
relative to x',t'. But proving 4-var transfer for the 3-point config requires interval
data for ALL pairs (u,x), (x,t), (u,t). Only (x,t) data is available from hypotheses.

### Why Simpler Approaches Fail

1. **nf_fraisse_compression alone**: Off-by-one problem. NF equality at depth j needs
   transfer at depth j-1. Transfer at depth j-1 needs zone matching. Zone matching needs
   interval data. Can't avoid zone matching.

2. **Strong induction without interval data**: Zone matching is needed at every recursive
   level. Without interval data for the extended config, can't zone-match.

3. **Deriving interval data from pairwise NFs**: Pairwise 1-var NFs at endpoints do not
   determine interval structure. This is the fundamental v12 blocker.

### The 2-var Interval Type Resolution (from GHR93)

In GHR93 Proposition 7, the hypothesis is interval game strategies (= 2-var NF equality)
for adjacent pairs. Zone matching with 2-var types gives sub-interval game strategies
automatically (Lemma 11). In NF terms:

- Hypothesis: `interval_2var_nf_types M D lo hi = interval_2var_nf_types M' D lo' hi'`
- Zone match: find u' with `nf_characteristic M D 2 (u, hi) = nf_characteristic M' D 2 (u', hi')`
- Sub-interval: derive `interval_2var_nf_types M (D-1) u hi = interval_2var_nf_types M' (D-1) u' hi'`
- Depth budget: D decreases by 1 at each step; transfer depth j also decreases by 1

The depth budget approach is well-founded because j decreases to 0 (atoms at any arity).

### The NF Projection Sub-Problem

The key missing lemma (step 3 above) requires proving that `nf_characteristic M D 2 (u, hi)`
determines `interval_2var_nf_types M (D-1) u hi`. This requires:

1. The quant component of the depth-D 2-var NF encodes depth-(D-1) 3-var NFs of (w, u, hi)
2. From the depth-(D-1) 3-var NF of (w, u, hi), extract the depth-(D-1) 2-var NF of (w, hi)
3. Step 2 is the "NF projection" lemma: projecting away a variable from a multi-var NF

The NF projection is non-trivial because the depth-(D-1) 3-var NF of (w, u, hi) encodes
atoms and quantifier structure involving ALL three variables, while the depth-(D-1) 2-var
NF of (w, hi) only involves two. The projection requires showing that the 3-var data
determines the 2-var data (which it does, because the 2-var NF is a function of the model
state, which the 3-var NF fully characterizes relative to all three points).

## Existing Infrastructure

- `interval_2var_nf_types` (line 1847): Already defined, currently unused
- `zone_match_witness` (line 2044): 1-var zone matching for 2-point configs
- `nf_fraisse_compression` (line 2006): The core compression lemma
- `atom_agree_from_pointwise` (line 2216): Atom agreement at any arity
- `nf_agreement_monotone`: Depth monotonicity for NF agreement
- `nf_char_depth_decrease`: 1-var NF depth decrease
- `interval_nf_types_depth_decrease` (line 1904): 1-var interval depth decrease

## Implementation Roadmap

1. **NF projection lemma** (~80-120 lines): Prove that the depth-D n-var NF of a tuple
   determines the depth-D (n-1)-var NF of any sub-tuple. This is the hardest part.
   Approach: by induction on D, using the fact that the atoms are projectable and the
   quant component projects via existential quantification over the dropped variable.

2. **interval_2var_nf_types_depth_decrease** (~30 lines): Analogous to interval_nf_types_depth_decrease.

3. **sub_interval_2var_from_nf_match** (~50-80 lines): From 2-var NF equality at depth D,
   derive interval_2var_nf_types at depth D-1 for the sub-interval. Uses NF projection.

4. **zone_match_witness_2var** (~60-80 lines): Like zone_match_witness but using 2-var types.

5. **multi_arity_transfer** (~100-150 lines): The main theorem by Nat.strongRecOn on j,
   with interval_2var_nf_types at depth j as hypothesis, universally over n.

6. **Bridge and sorry filling** (~50-80 lines): Derive initial interval_2var_nf_types from
   1-var data at depth 0 (base case), then apply multi_arity_transfer at the sorry sites.

Total: ~370-510 lines.

## Decisions Made

- The approach from plan v14 is correct: arity-parametric induction with 2-var interval types.
- The NF projection lemma is the critical path item that was not identified in the plan.
- No code was committed because the analysis revealed the full scope of the sub-problem.
