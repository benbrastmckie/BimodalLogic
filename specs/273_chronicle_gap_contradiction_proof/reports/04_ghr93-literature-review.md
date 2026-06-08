# GHR93 Literature Review: EF Game Composition and the Bridge Lemma Sorry

## 1. Summary of GHR93's Proof Strategy for the Bridge Lemma

### The Overall Architecture

GHR93 (Section 8) proves Theorem 3: {U, S, U', S'} is expressively complete for all linear time. The proof has four main layers:

1. **Custom EF Games** (Definition 8.7): A modified 2-round game `G_{n;r}(M, xy; N, x'y')` where V first chooses n points in `[x,y]_r` (including gaps up to rank r), then chooses one point in `[x',y']` (not a gap), and Duplicator responds with matching points preserving rank-r temporal formulas and gap/non-gap status.

2. **Decomposition Formulas** (Definition 8.8): An `n;r-decomposition formula` describes a configuration of n points between x and y, specifying their temporal rank-r types, gap status, and the types of all intermediate points. Lemma 11 proves that Duplicator winning the game is equivalent to agreement on all decomposition formulas.

3. **The Key Theorem** (Theorem 6, the "Bridge Theorem"): For all n, if Duplicator wins `G_{1+3n; r+4n}(M, xy; N, x'y')` (the "forward" game), then Duplicator also wins `G_{n;r}(N, x'y'; M, xy)` (the "backward" game). This is proved by induction on n with four cases depending on the structural character of the last point alpha_n chosen by Spoiler.

4. **Composition** (Proposition 7): Given m pre-selected points in each structure with matching interval games, Duplicator wins the full `G_n` game on the pointed structures. This composes the interval-level strategies into a global strategy.

### How the Proof Works Step by Step

**Proposition 6** establishes that if x in M and y in N agree on all temporal formulas of rank `g(n+1)+1`, then Duplicator has winning strategies for the "forward" games `G_{n;r}(M, -inf x; N, -inf y)` and `G_{n;r}(M, x inf; N, y inf)`.

**Proposition 7** is the composition lemma. Given increasing tuples x_1 < ... < x_m in M and y_1 < ... < y_m in N with Duplicator winning both forward and backward interval games `G_{f(n+1);r}(M, x_i x_{i+1}; N, y_i y_{i+1})` and `G_{f(n+1);r}(N, y_i y_{i+1}; M, x_i x_{i+1})`, Duplicator wins `G_{n+1}((M,x),(N,y))`. The proof works by:
- When Spoiler plays alpha in interval (x_i, x_{i+1}), Duplicator lists all decomposition formulas true at the interval boundaries and uses her winning strategy to find a response e in the corresponding interval of N.
- By Lemma 11, the decomposition formula agreement gives Duplicator sub-interval strategies. By Theorem 6, the forward strategies yield backward strategies. The induction hypothesis then gives Duplicator a strategy for the remaining n rounds.

**Theorem 6** (the backward game theorem) is the heart. Its proof by induction on n has:
- **Case I**: alpha_0 < d (the "split point" c/d). Both sub-intervals contain at most n of Spoiler's points, so Duplicator uses her interval strategies sigma and tau directly.
- **Case II**: All points in (d, y'), alpha_n is a non-gap point. Duplicator uses the rank-r formula B = X_{alpha_n} to locate a matching point e_n via `U(B,A)` transfer at rank r+4, then plays sub-interval strategies.
- **Case III**: alpha_n is a gap defined on the left. Uses `left(B,D)` formulas (Definition 8.5) to handle gap-definability transfer. The key formula delta = A /\ left(B,D) witnesses the gap's neighborhood structure.
- **Case IV**: alpha_n is a gap not defined on the left. Uses `right(B,D)` formulas. The formula delta captures the neighborhood from the other side.

### The "4-Variable Existential Transfer"

This is not a single named concept in GHR93 but rather the mechanism by which Proposition 7's composition works. When composing interval strategies:

1. Given m distinguished points, Spoiler plays a new point alpha.
2. Alpha falls in some interval (x_i, x_{i+1}).
3. To find the Duplicator's response, Proposition 7 uses up to `(1+3f(n)) * (j+k) + 1` points from the interval game's first round, where j and k are the number of decomposition formulas.
4. The interval game's winning strategy provides a response point e that preserves all decomposition formulas at the interval level.
5. Theorem 6 converts the forward interval strategy into backward interval strategies, enabling the recursion.

The "4 variables" arise because at the quantifier transfer step, Duplicator must handle a new witness w being added to the existing 3-point configuration (u, x, t), making 4 variables total. This is the step that requires sub-interval matching for the new 4-point configuration, which is handled by recursion in the game argument.

## 2. Comparison with the Lean Formalization's Approach

### What the Formalization Does

The Lean code in `StaviCompleteness.lean` does NOT directly formalize the GHR93 game argument. Instead, it takes a different (but mathematically equivalent) approach:

1. **Normal Form (NF) approach**: Rather than games, it uses `NormalForm sig k n` -- a depth-k n-variable normal form that captures the complete rank-k type of an n-tuple of points.

2. **`nf_characteristic`**: Assigns to each n-tuple of points its unique depth-k NF (the "characteristic NF").

3. **`nf_fraisse_compression`** (Theorem at line 2006): The key compression lemma. It states that if two n-variable environments agree on atoms AND the existential transfer holds at each depth j < k, then their depth-k n-var NFs are equal. This is the NF-theoretic version of "Duplicator wins the EF game implies same type."

4. **`nf_2var_from_interval_data`** (Theorem at line 2448, the "Bridge Lemma"): If two 2-variable environments (x,t) in M and (x',t') in M' have:
   - Same depth-k 1-var NFs at x/x' and t/t'
   - Same ordering
   - Same interval type sets (depth-k 1-var NFs realized between them)
   - Same type sets above max and below min
   
   Then their depth-k 2-var NFs are equal. This corresponds to GHR93 Proposition 7 + Lemma 11 specialized to the 2-variable case.

5. **`nf_2var_existential_transfer`** (Theorem at line 2214): The existential transfer needed by `nf_fraisse_compression` for the 2-variable case. Given zone-matching data for (x,t)/(x',t'), for each depth-j (2+1)-var NF chi:
   ```
   (exists u, nf_eval_nf M j 3 (u::x::t) chi) <->
   (exists u', nf_eval_nf M' j 3 (u'::x'::t') chi)
   ```

### How They Relate

| GHR93 Concept | Lean Formalization |
|---|---|
| Rank-r temporal formula type | `NormalForm sig r 1` |
| n;r-decomposition formula | `NormalForm sig r n` |
| Duplicator wins G_{n;r} | `nf_characteristic M r n env = nf_characteristic M' r n env'` |
| Lemma 11 (game <-> decomposition) | `nf_fraisse_compression` |
| Proposition 7 (composition) | `nf_2var_from_interval_data` (specialized to 2 vars) |
| Theorem 6 (forward -> backward) | Implicit in the NF structure (not needed separately) |
| `left(A,D)`, `right(A,D)` | Not formalized (not needed in NF approach) |

The NF approach has a significant advantage: it avoids formalizing the full game infrastructure (game positions, strategies, winning conditions) and the complex case analysis of Theorem 6 (Cases I-IV). Instead, it reduces everything to:
- Atom agreement (straightforward)
- Existential transfer at each depth (the hard part)

### Key Structural Difference

GHR93 proves the composition by running actual game strategies. The Lean formalization instead proves it by structural induction on the NF depth k:
- Base case k=0: only atoms matter, and atom agreement is given.
- Inductive step k+1: needs atoms (given) plus existential transfer at each depth j < k+1.

The existential transfer at depth j requires finding a witness u' in M' matching a witness u in M. The zone-matching lemma (`zone_match_witness`) provides u' with matching 1-var NF, correct orderings, and correct interval type agreement. But to conclude that the (j+1)-var configuration (u,x,t)/(u',x',t') has the same depth-j NF, one needs the same existential transfer property at depth j -- this is the recursive step that creates the sorry.

## 3. Analysis of the 3 Sorry Sites

### Sorry Site 1: Line 2353 (Forward direction of `nf_2var_existential_transfer`)

**Context**: Inside the forward direction (M -> M') of the existential transfer, after:
- Zone-matching has found u' with same 1-var NF and correct orderings
- 3-var atom agreement has been proved for (u,x,t)/(u',x',t')
- The case j = 0 has been handled (pure atom transfer)
- For j = j'+1: atoms are transferred, and the quantifier part is reduced to:

```
(exists w, nf_eval M j' 4 (w::u::x::t) sub_nf) <->
(exists w', nf_eval M' j' 4 (w'::u'::x'::t') sub_nf)
```

**What's Missing**: This is a 4-variable existential transfer at depth j' for the 3-point configuration (u,x,t)/(u',x',t'). The proof needs to show that zone-matching works at this deeper level -- i.e., that the sub-interval type data for ALL pairs in the 3-point configuration are preserved. The issue is that zone-matching gives us:
- u and u' have the same 1-var depth-k NFs
- x and x' have the same 1-var depth-k NFs
- t and t' have the same 1-var depth-k NFs
- orderings among all 6 pairs agree

But the sub-interval types for the 3-point configuration require knowing `interval_nf_types M k u x = interval_nf_types M' k u' x'` and `interval_nf_types M k u t = interval_nf_types M' k u' t'`, which are NOT directly given by the hypotheses. The hypotheses only give interval types for (x,t)/(x',t').

### Sorry Site 2: Line 2435 (Backward direction of `nf_2var_existential_transfer`)

**Context**: Symmetric to Sorry Site 1, but for the M' -> M direction. After zone-matching in the reverse direction finds u in M matching u' in M', the same 4-variable existential transfer issue arises.

### Sorry Site 3: Line 2805 (`nf_exist_sf_guarded_backward`)

**Context**: The backward direction of the guarded existence formula. Given that the temporal formula (Until/Since with interval guard) holds at t, the proof must extract a witness x and show that `nf_eval_nf M k 2 (x::t) sub_nf` holds.

**What's Missing**: This sorry is a CONSEQUENCE of the bridge lemma sorry. The comment at lines 2803-2804 states: "The bridge lemma is sorry'd (nf_2var_from_interval_data), so this proof is sorry'd as well. When the bridge is proved, this proof completes."

The chain is: `nf_exist_sf_guarded_backward` needs `nf_2var_from_interval_data` (bridge lemma), which needs `nf_2var_existential_transfer` (which has the actual mathematical content sorry'd at lines 2353 and 2435).

### Summary of Dependencies

```
sorry @ 2805 (nf_exist_sf_guarded_backward)
  depends on:
    nf_2var_from_interval_data (bridge lemma, line 2448)
      depends on:
        nf_fraisse_compression (line 2006, proved)
        nf_2var_existential_transfer (line 2214)
          sorry @ 2353 (forward, 4-var transfer at depth j')
          sorry @ 2435 (backward, 4-var transfer at depth j')
```

So there are really only TWO independent sorry sites (lines 2353 and 2435), which are the forward and backward directions of the same mathematical claim. The third sorry (line 2805) is downstream.

## 4. Assessment of Difficulty to Close the Gaps

### The Core Mathematical Issue

The sorry at line 2353 requires proving:
```
(exists w, nf_eval M j' 4 (w::u::x::t) sub_nf) <->
(exists w', nf_eval M' j' 4 (w'::u'::x'::t') sub_nf)
```

This is a **recursive instance** of the bridge lemma, but at one more variable (4 instead of 3) and one lower depth (j' < j < k). The issue is that the current proof structure attempts to prove the 2-var bridge lemma with hypotheses about the (x,t) interval only, but the 3-var existential transfer needs sub-interval data for ALL pairs among (u,x,t).

### Why This Is Hard

1. **Missing sub-interval data**: The bridge lemma hypotheses provide `interval_nf_types` for (x,t)/(x',t'), but when u is zone-matched into this interval, the sub-interval types (x,u)/(x',u') and (u,t)/(u',t') are NOT known to match. The zone-matching guarantees u' has the same 1-var NF type as u and correct orderings, but this alone does not guarantee sub-interval type matching.

2. **The GHR93 resolution**: In the paper, this problem is resolved by the game composition argument (Proposition 7), which works differently. Proposition 7 doesn't need explicit sub-interval type data; instead, it uses the fact that Duplicator has a winning strategy for the whole interval game, and the response point e inherits the correct interval structure from the game strategy. The game automatically decomposes: when Spoiler plays into a sub-interval, Duplicator uses the restriction of her whole-interval strategy.

3. **Structural mismatch**: The Lean formalization has set up the bridge lemma with explicit interval-type hypotheses (a "data-driven" approach), but the 4-variable recursive step needs data that isn't available from the outer hypotheses. GHR93 avoids this by using strategies (a "strategy-driven" approach) where sub-interval data is implicitly provided by the strategy restriction.

### Possible Resolution Approaches

**Approach A: Strengthen the Hypotheses (Induction on Variables)**

Add to the bridge lemma hypotheses the full interval type data for ALL pairs among the points. This would mean the existential transfer for n-var at depth j gets hypotheses about (n+1)-var interval data. The induction would be on k (depth) with an inner induction on the number of variables. This is feasible but would require restructuring `nf_2var_existential_transfer` to carry richer hypotheses.

Estimated effort: 300-500 lines of new infrastructure (defining n-var interval data, proving zone-matching preserves it) plus restructuring the existing proof.

**Approach B: Formalize a Restricted Game Argument**

Instead of the full GHR93 game, formalize a restricted "strategy" that, given zone-matching, constructs the right sub-interval decomposition. This would involve:
- Defining a notion of "interval strategy" 
- Proving that zone-matching + interval type agreement implies interval strategy existence for sub-intervals
- Using interval strategies to transfer existential witnesses

Estimated effort: 500-800 lines.

**Approach C: Prove a Stronger Zone-Matching Lemma**

Strengthen `zone_match_witness` so that the matched u' not only has the same 1-var NF and orderings but also satisfies sub-interval type matching. This would require choosing u' more carefully -- not just any point with the right 1-var NF type, but one that additionally splits the interval in a type-preserving way.

The key insight from the composition method (Libkin Lemma 3.7, Thomas 1997): when splitting a linear order at a point, the type of the whole is determined by the types of the parts. If two intervals have the same type set, and we pick u, u' with the same 1-var NF from them, then the sub-intervals (lo, u)/(lo', u') and (u, hi)/(u', hi') inherit type-set agreement from the parent interval's type-set agreement.

This is the most promising approach. The argument is:
- `interval_nf_types M k x t` = set of 1-var depth-k NFs realized in (x,t)
- Zone-matching picks u' with same NF as u, same orderings
- Claim: `interval_nf_types M k x u = interval_nf_types M' k x' u'`
- Proof: Any NF tau realized in (x,u) is also realized in (x,t) (since u is between x and t). By hypothesis, tau is realized in (x',t'). The witness v' in (x',t') with NF tau could be on either side of u'. But because we have ALL NF types from (x,t) available in (x',t'), and the orderings of u relative to x and t match, we can argue that the sub-interval types split correctly.

HOWEVER, this argument has a subtle gap: knowing that tau is realized somewhere in (x',t') does not tell us whether it's realized in (x',u') vs (u',t'). The argument would need an additional invariant -- perhaps matching the set of 2-var NF types `interval_2var_nf_types` (which the code already defines at line 1847) rather than just 1-var types.

Estimated effort: 200-400 lines if the 2-var interval types approach works, but may require replacing `interval_nf_types` with `interval_2var_nf_types` throughout the bridge lemma hypotheses.

**Approach D: Direct Induction on k Without Sub-Interval Matching**

The NF structure has a natural induction on k. At depth 0, no quantifiers, so only atoms matter -- done. At depth k+1, the NF has atoms plus quantifier data at depth k. The quantifier data asks about existence of points with certain depth-k (n+1)-var NFs. By induction, the depth-k bridge lemma holds (with weaker hypotheses at depth k). The depth-(k+1) bridge lemma can then be proved using the depth-k result.

This approach would restructure the proof as induction on k inside `nf_2var_existential_transfer`, with the j < k bound replaced by a direct k-induction. The base case k = 0 is already proved. The step case uses: at depth k, existential transfer at depth j < k follows from the induction hypothesis at depth k-1 (since the sub-interval matching at depth j only needs depth-(j-1) agreement, which is implied by depth-k hypotheses via monotonicity).

Estimated effort: 300-500 lines. This is probably the cleanest approach.

### Difficulty Rating

| Factor | Assessment |
|---|---|
| Mathematical clarity | The argument is clear from GHR93; the gap is in translation to the NF framework |
| Technical complexity | Medium-high: requires careful induction management and possibly hypothesis restructuring |
| Risk of structural mismatch | Medium: the current proof structure may need modification, not just gap-filling |
| Lines of code estimate | 300-800 depending on approach |
| Overall difficulty | **Hard but tractable** -- not a fundamental obstacle, but not a routine fill-in either |

## 5. Alternative Approaches Suggested by the Literature

### Alternative 1: Bypass the Full Bridge Lemma via Prior Expressiveness

The sorry chain is:
```
completeness_discrete -> no_gaps_discrete_model_surgery -> gap_prior_UZ_contradiction
  -> US_expressively_complete_over_prior -> stavi_expressive_completeness
  -> nf_characterizable_by_stavi -> nf_2var_existence_characterizable
  -> nf_exist_sf_guarded_backward -> nf_2var_from_interval_data
  -> nf_2var_existential_transfer (SORRY)
```

`US_expressively_complete_over_prior` is about expressive completeness of {U,S} over **Prior structures** (discrete linear orders isomorphic to Z). This is GHR94 Chapter 10's Theorem 10.2.10 (Separation Theorem for integer time), which is MUCH simpler than the general Stavi completeness (GHR93 Theorem 3).

The integer-time separation proof (Section 10.2) uses only syntactic rewriting -- the 8 eliminations of Lemma 10.2.3 -- with no game theory at all. It is a purely combinatorial argument about pulling U out from under S and vice versa. No EF games, no composition, no bridge lemma.

**Key question**: Does `US_expressively_complete_over_prior` actually need the full `stavi_expressive_completeness` (which requires the bridge lemma), or could it be proved directly via the integer-time separation argument?

Looking at the code: `PriorExpressiveness.lean` imports `StaviCompleteness.lean` and uses `stavi_expressive_completeness`. But the separation proof for integer time (GHR94 10.2) does NOT use Stavi connectives or EF games -- it is a self-contained syntactic argument that only needs {U, S}.

If `US_expressively_complete_over_prior` were proved via the separation method (GHR94 10.2) instead of via Stavi completeness (GHR93 Section 8), the bridge lemma sorry would be entirely bypassed for the completeness_discrete application.

**Feasibility**: The separation proof is conceptually simpler but technically verbose -- the 8 elimination cases each produce multi-line equivalences. Formalizing it would require ~1000-2000 lines of equivalence proofs but would be entirely routine (each step is a semantic argument about U, S truth conditions over integers). No game theory infrastructure needed.

### Alternative 2: Weaker Bridge Lemma for Discrete Time

For the specific use case in `gap_prior_UZ_contradiction`, the structures involved are **discrete** (Prior/integer-like). Over discrete time:
- There are no gaps (every bounded set has a supremum/infimum in the order)
- The EF game composition is simpler: Theorem 6's Cases III and IV (gap cases) never arise
- Sub-interval matching is simpler because intervals in discrete orders are finite or omega-like

A weaker bridge lemma that only works for gap-free discrete orders would avoid the full generality of GHR93 Section 8. This would still require the NF transfer machinery but the sub-interval matching becomes trivial: in a discrete order, the interval type set is determined by the sequence of NF types between x and t, and zone-matching can be done by exact position matching.

**Feasibility**: High. The discrete case is essentially Proposition 6 + composition on a discrete structure, which is much simpler. Estimated 200-400 lines.

### Alternative 3: Direct Model-Theoretic Argument

Instead of proving expressive completeness to get the temporal formula needed in `gap_prior_UZ_contradiction`, prove the model-surgery contradiction directly using model-theoretic methods (back-and-forth, compactness, or direct construction). This would avoid the expressive completeness route entirely.

The argument in `gap_prior_UZ_contradiction` uses expressive completeness to turn a FO formula rho into a temporal formula R, which is then used to derive a contradiction from the gap structure. If one could prove the specific FO property (that the gap class is definable by a temporal formula) without going through full expressive completeness, the bridge lemma sorry would be irrelevant.

**Feasibility**: Uncertain. Depends on the specific formula rho and whether a direct temporal definition can be constructed ad hoc.

### Alternative 4: Use the Existing `stavi_expressive_completeness` but With a Different `nf_2var_existence_characterizable`

The sorry in `nf_exist_sf_guarded_backward` could potentially be avoided if the backward direction could be proved without the bridge lemma. The forward direction (nf_eval -> formula truth) is already proved. If the characterizing formula were defined differently -- perhaps using a more discriminating temporal formula that encodes the full 2-var NF directly rather than just the atom-compatible 1-var NFs -- then the backward direction might be provable without the bridge lemma.

**Feasibility**: Low. The fundamental issue is that temporal formulas can only "see" one point at a time (they evaluate at a single time point), so recovering the 2-var NF from temporal formula truth inherently requires the bridge lemma's argument that 1-var data determines 2-var data.

### Recommendation

**Primary recommendation**: Approach Alternative 1 (bypass via integer-time separation). This completely avoids the bridge lemma sorry for the specific use case and uses a well-understood, purely syntactic proof technique. The formalization effort is large but straightforward.

**Secondary recommendation**: Approach C or D from Section 4 (strengthen zone-matching or restructure the induction). These close the actual sorry and benefit the full Stavi completeness theorem, which may be needed for future work beyond completeness_discrete.

**Tertiary recommendation**: Alternative 2 (discrete-only bridge lemma) as a middle ground -- proves the bridge lemma but only for the case actually needed.
