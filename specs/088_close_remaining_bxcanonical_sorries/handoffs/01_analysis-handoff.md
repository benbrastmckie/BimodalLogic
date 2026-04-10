# Handoff: Task 88 - Close CanonicalEmbedding:418 Sorry

## Status
BLOCKED - The planned approach (two-point WorldHistory + USF truth bridge) has a fundamental gap.

## Problem Statement
Close the sorry at `CanonicalEmbedding.lean:418` in `usf_completeness`. The sorry is in the `imp` case B of the proof, where we have:
- `h_valid : valid (psi.imp chi)` -- psi -> chi is valid
- `h_psi_in : psi in w.formulas` -- psi is in MCS w
- `h_chi_not : chi not in w.formulas` -- chi is not in MCS w
- `h_usf : untilSinceFree (psi.imp chi)` -- both are USF
- Goal: `False`

## Approaches Analyzed

### 1. Two-Point WorldHistory (Plan v4 approach) -- BLOCKED
Build a history with `states 0 = w` and `states t = v` for `t > 0` where `bx_le w v`.

**Why it fails**: The backward truth bridge for G(alpha) requires `truth_at G(alpha) at 0 -> G(alpha) in w`. On a two-point history, `truth_at G(alpha) at 0` gives `alpha in w` and `alpha in v`, but `G(alpha) in w` requires `alpha in u` for ALL `u >= w`, not just w and v. The two-point history only visits two states.

The forward bridge (membership -> truth) works on any bx_le-monotone history. But the imp forward bridge requires the backward bridge for the antecedent (to go from `truth_at antecedent` to `antecedent in w`). So a forward-only bridge is insufficient.

### 2. Multi-Point WorldHistory -- BLOCKED (surjectivity)
Build a history that visits ALL bx_le successors of w.

**Why it fails**: The time domain D = Int is countable, but `{v | bx_le w v}` may be uncountable (BXPoint is Set Formula, which has cardinality up to 2^aleph_0). A surjection from Int to an uncountable set doesn't exist.

### 3. Using Large D -- FEASIBLE but complex
`valid` quantifies over ALL types D. Choose D large enough (e.g., D = free abelian group on BXPoint with lex order). Then build a surjective history.

**Why it's hard**: Requires constructing an AddCommGroup + LinearOrder + IsOrderedAddMonoid on a type large enough to index all BXPoints. This requires significant Mathlib infrastructure (ordered free abelian groups) not present in the project.

### 4. Constant History + Flattening -- BLOCKED
On constant histories, G/H collapse: `truth_at G(alpha) = truth_at alpha`. Define `flat(phi)` removing G/H. Then `truth_at phi = flat(phi) in w`.

**Why it fails**: From validity, `flat(psi) in w -> flat(chi) in w`. And `psi in w -> flat(psi) in w` requires `|- psi -> flat(psi)`, which fails for the imp case (needs `flat(antecedent) -> antecedent`, i.e., `alpha -> G(alpha)`, which is not derivable).

### 5. Proof-Theoretic Reduction -- PARTIALLY WORKS
Reduce `|- psi -> G(alpha)` to `|- psi -> alpha` (via IH), then lift using temporal necessitation + K-distribution. Use `connect_future` axiom (`phi -> G(P(phi))`).

**Key derivation for G case**:
1. `valid (psi -> G(alpha))` implies `valid (P(psi) -> alpha)` (semantic argument)
2. By WF IH on `P(psi).imp alpha` (smaller consequent temporal weight): `|- P(psi) -> alpha`
3. `|- G(P(psi) -> alpha)` (temporal necessitation)
4. `|- G(P(psi)) -> G(alpha)` (K-distribution)
5. `|- psi -> G(P(psi))` (connect_future axiom)
6. `|- psi -> G(alpha)` (composition)

Similarly for H using `connect_past` and `past_necessitation`/`past_k_dist`.
For box: use `modal_b` (`phi -> box(diamond(phi))`) and `diamond(psi) -> alpha`.

**Why it's incomplete**: The recursive reduction decreases the temporal weight of the CONSEQUENT but may increase the ANTECEDENT. At the base case (consequent has no G/H/box), we still need `|- psi' -> chi'` where psi' is complex (contains P, F, diamond) and chi' is propositional. The MCS + constant-history truth bridge fails here because the forward bridge for psi' with G/H inside imp-antecedent positions doesn't work on constant histories.

### 6. Case Split on valid(chi) -- PARTIAL PROGRESS
```
by_cases h_chi_valid : valid chi
- If valid chi: ih_chi gives |- chi, then |- psi.imp chi via prop_s. Done.
- If not valid chi: ...still stuck...
```
This handles the case where chi is valid but leaves the case where chi is not valid open.

## Recommended Next Steps

### Option A: Complete the Proof-Theoretic Approach (Highest Priority)
The recursive reduction (approach 5) is the most promising. The gap is at the base case. Two possible paths:

1. **Show the base case is vacuous**: Prove that when the consequent has no G/H/box, Case B1 (valid chi) always applies. I.e., prove: if `valid(psi -> chi)` and chi is propositional (no G/H/box), then either `valid(psi)` or `valid(chi)`. This would be a semantic lemma about propositional consequents.

2. **Handle the base case directly**: For the base case `valid(psi' -> chi')` with chi' propositional, prove the MCS contradiction using a different model than constant histories. Since chi' is propositional, the backward bridge for chi' works on ANY history. The issue is the forward bridge for psi'. If we can show psi' is "upward propositional" (its truth on constant histories only depends on propositional atoms, not on G/H structure), the bridge might work.

### Option B: Use Large Domain D
Implement the ordered free abelian group on BXPoint (or a suitable quotient) to get a domain large enough for surjective histories. This is the most mathematically clean approach but requires significant boilerplate.

### Option C: Restructure usf_completeness
Change the proof to use well-founded induction on `(temporal_weight_consequent, sizeOf)` instead of structural induction. Implement the recursive G/H/box reduction. Combine with the case-split approach for the base case.

## Key Lemmas Available
- `G_iff_mcs`: `G(phi) in w <-> forall v >= w, phi in v` (sorry-free)
- `H_iff_mcs`: `H(phi) in w <-> forall v <= w, phi in v` (sorry-free)
- `box_iff_mcs`: `box(phi) in w <-> forall v ~ w, phi in v` (sorry-free)
- `imp_iff_mcs`: `(phi -> psi) in w <-> (phi in w -> psi in w)` (sorry-free)
- `fragment_truth_iff`: Full iff bridge for temporal-free formulas (sorry-free)
- `connect_future_thm`: `|- phi -> G(P(phi))`
- `connect_past_thm`: `|- phi -> H(F(phi))`
- `past_necessitation`: `|- phi -> |- H(phi)`
- `past_k_dist`: `|- H(A -> B) -> (H(A) -> H(B))`
- `bx_G_backward`: `G(phi) not in w -> exists v >= w, phi not in v`
- `bx_H_backward`: `H(phi) not in w -> exists v <= w, phi not in v`

## Files Modified
None (the sorry remains as-is).

## Session
sess_1744300000_a8b3f1
