# Teammate B Findings: Alternative Approaches and Literature Review

**Task**: 93 - Complete BXCanonical embedding
**Role**: Alternative approaches, literature review, codebase infrastructure audit
**Date**: 2026-04-14

## Key Findings

1. **The literature handles forward_F semantically, not syntactically.** Every standard completeness proof for tense logic (Burgess 1984, Goldblatt 1992, Gabbay-Hodkinson-Reynolds 1994) constructs the canonical model on integer (or rational) time by building a chain of MCS where each step targets ONE formula at a time. The key semantic fact they exploit: in an integer model, the well-ordering of future witnesses is inherited from the integers. This is exactly what BX11 fails to provide syntactically (non-transitive, 3-cycles).

2. **Novel Approach: "One-at-a-time with compactness" (Approach 20).** Instead of trying to resolve all F-obligations simultaneously at each step, build a separate witness chain for EACH F-obligation independently, then use compactness/Konig's lemma to merge them into a single chain. This has NOT been tried.

3. **Novel Approach: "Until-based reformulation" (Approach 21).** Convert the forward_F problem into a forward-Until problem using BX12 (F(psi) -> top U psi). The Until eventuality resolution (`bx_until_eventuality_resolution`) is ALREADY PROVED sorry-free in Frame.lean. The obstacle (top U psi not in deferralClosure) may be circumventable.

4. **Novel Approach: "Contradiction via BX10 + BX9 induction" (Approach 22).** Use BX10 (phi U psi -> F(psi)) combined with BX9 induction to derive a structural contradiction from permanent non-resolution. This exploits the proved quasimodel/defect-chain infrastructure.

5. **The existing OrderedSeedConsistency infrastructure is underutilized.** `enriched_resolving_seed_consistent` and `two_defect_consistent_seed` provide the mathematical core for ordered resolution but have no downstream consumers for the forward_F proof itself.

## Literature Review

### Burgess 1984 ("Basic Tense Logic")

Burgess's completeness proof for tense logic over linear orders uses the **step-by-step construction method** (also called "construction by finite stages"):

1. Enumerate all formulas phi_0, phi_1, phi_2, ...
2. Start with a single MCS M_0
3. At stage n, consider formula phi_n:
   - If F(phi_n) is in some existing MCS M_k but no witness exists yet, extend the chain by adding a new MCS M' containing phi_n and g_content(M_k)
   - The new MCS is placed AFTER M_k in the linear order
4. Key property: each formula is considered infinitely often (the enumeration repeats)

**Critical observation**: Burgess's construction places new points *individually*. When building the successor to witness F(phi_n), the seed is simply `{phi_n} union g_content(M_k)` -- the SAME seed as `forward_temporal_witness_seed`. No BX11 fold is needed because each step only resolves ONE obligation. Other F-obligations are handled at OTHER steps.

**Why this works semantically but not syntactically for us**: In Burgess's construction, F-obligations at M_k that are NOT being resolved at step n persist to the newly added M' because the semantic truth of F(psi) at M_k depends on the ENTIRE future of the model, which is still being constructed. The construction is non-effective: it assumes that if F(psi) is in M_k, a witness will eventually be added at some later stage. This is guaranteed by the enumeration visiting psi infinitely often.

**The gap**: In our syntactic construction, each step FIXES the successor MCS. F(psi) either persists to the successor (via f_carry or BX11 fold) or is LOST (G(neg psi) appears). There is no "eventually we'll add a witness" -- the chain is fully determined at construction time.

### Goldblatt 1992 ("Logics of Time and Computation")

Goldblatt's treatment follows a similar pattern to Burgess but with the **bulldozing technique**:

1. Build the canonical frame with ALL maximal consistent sets as worlds
2. The canonical relation R is: w R v iff g_content(w) subset v
3. This gives a pre-order, not necessarily a linear order
4. **Bulldoze**: Transform the pre-order into a linear order by "unraveling" clusters into a linear chain on the integers (or rationals)

**Key insight**: In the canonical frame, if F(psi) is in w, then by `bx_forward_witness` there EXISTS some v >= w with psi in v. The existence is guaranteed by the consistency of `{psi} union g_content(w)`. No BX11 fold is needed.

**The gap**: Bulldozing assumes the ENTIRE canonical frame is available. In our construction, we build a SINGLE chain (indexed by Int), not the full canonical frame. The bulldozing technique cannot be directly applied because we need a specific linear chain, not the abstract pre-order.

### Gabbay, Hodkinson, Reynolds 1994 ("Temporal Logic", Vol. 1)

This work uses a technique based on **adequate sets** (relativized maximal consistent sets over a finite signature Sigma):

1. Fix an adequate set Sigma (closed under subformulas + temporal decomposition)
2. Build Sigma-maximal consistent sets (analogous to Hintikka points)
3. Construct a model by patching together finite chains

**Key technique for eventuality**: Since Sigma is finite, there are only finitely many Sigma-MCS. A model is built by finding a path through the finite graph of Sigma-MCS that satisfies all eventualities. This uses a Konig's-lemma-like argument: if F(psi) is in a Sigma-MCS and no witness exists along any finite path, then the set of witnessing extensions is empty, contradicting the consistency of the seed.

**Relevance**: This finite-signature approach is closest to our `deferralClosure(root)` / `sigma_list` approach. However, their construction works with Sigma-MCS (which are finitely many) rather than full MCS (which are uncountably many). The quasimodel infrastructure in `Quasimodel/` partially implements this approach.

### Xu 1988 ("On some U,S-tense logics")

Xu simplified Burgess's axiomatization for Since-Until logic. The completeness proof follows the same step-by-step paradigm. No new technique for eventuality resolution.

### Verbrugge (Completeness by Construction)

The "completeness by construction" approach (Verbrugge, in Festschrift D65) builds models incrementally at finite stages, with an enumeration where each formula appears infinitely often. At even stages, formulas are processed; at odd stages, density requirements are handled. The construction terminates by a compactness argument.

**Relevance**: This confirms that the standard technique handles one formula per stage and relies on infinite repetition to eventually handle all obligations.

## Novel Approaches (with Feasibility Analysis)

### Approach 20: One-at-a-time with independent chains + merging

**Idea**: For each psi in sigma_list with F(psi) in M_0, independently construct a chain witnessing psi using `discharge_single_step`. Then MERGE these chains into a single Int-indexed chain.

**Construction**:
- For each psi_i with F(psi_i) in M_0: build M_0 -> M_i' where psi_i in M_i' and g_content(M_0) subset M_i'
- Key: each M_i' is an independent Lindenbaum extension
- Merging: define chain(1) = M_1', chain(2) = M_2', etc. But this BREAKS g_content transitivity (g_content(M_1') is NOT guaranteed to be in M_2')

**Feasibility**: LOW. The merging step fails because independently-constructed MCS do not compose. g_content(M_i') subset M_{i+1}' requires M_{i+1}' to extend g_content(M_i'), but M_{i+1}' was constructed from g_content(M_0), not g_content(M_i').

**Confidence**: 10%

### Approach 21: Until-based reformulation via BX12

**Idea**: Use BX12 (F(psi) -> top U psi) to convert F-obligations into Until-obligations, then leverage the PROVED `bx_until_eventuality_resolution` infrastructure.

**Construction**:
1. F(psi) in chain(n) -> (top U psi) in chain(n) by BX12
2. `bx_until_eventuality_resolution` (Frame.lean:623, sorry-free) gives: if (phi U psi) in w and psi not in w, then there exists v >= w with psi in v and phi in w
3. Apply with phi = top: get v >= chain(n) with psi in v

**Obstacle 1**: `bx_until_eventuality_resolution` produces a BXPoint v, not a chain index. We need psi in chain(s) for some s > n, not just in some abstract BXPoint.

**Obstacle 2**: top U psi may not be in `deferralClosure(root)`, so the restricted coherence conditions don't apply.

**Obstacle 3**: `bx_until_eventuality_resolution` is a one-step result -- it finds a single BXPoint witness. The forward_F problem requires finding a witness WITHIN the specific chain being constructed.

**Possible fix for Obstacle 1**: Could we define chain(s) = v for some carefully chosen s? This would require showing that v is compatible with the existing chain (g_content chain(n) subset v, which is given, but also h_content(v) relating back properly).

**Feasibility**: LOW-MEDIUM. The obstacles are substantial but Obstacle 1 might be addressable if we're willing to modify the chain construction at a single point (approach 23 below).

**Confidence**: 20%

### Approach 22: Contradiction via BX10 + BX9 induction (indirect argument)

**Idea**: Prove forward_F by contradiction. Assume F(psi) in chain(n) but psi not in chain(s) for all s > n. Derive a contradiction using the BX axioms.

**Construction**:
1. Assume F(psi) in chain(n) and forall s > n, psi not in chain(s)
2. By F-obligation constancy: F(psi) in chain(m) for all m >= n
3. By BX12: (top U psi) in chain(m) for all m >= n
4. By BX9: (top U psi) in chain(m) and psi not in chain(m) implies top in chain(m) (trivially true) and ... what?
5. By BX5 (self-accumulation): (top U psi) in chain(m) implies (top and (top U psi)) U psi in chain(m)
6. By BX10: (phi U psi) -> F(psi). Already have F(psi) in chain(m).

**Problem**: The BX axioms for Until (BX5, BX6, BX9, BX10) decompose Until formulas but don't directly produce witnesses in the chain. BX9 gives `phi or psi` (already known: psi not in chain(m), so phi in chain(m)). BX10 gives F(psi) (already known). BX5 gives self-accumulation (strengthens the Until but doesn't resolve it). BX6 (absorption) goes the wrong direction.

**Key insight needed**: Is there an axiom or derivable theorem that connects PERSISTENT F(psi) (at all future chain points) with some contradiction? G(F(psi)) is not derivable from F(psi) alone (F(psi) -> G(F(psi)) is not valid in linear frames). So this approach seems stuck.

**Feasibility**: LOW. The BX axioms don't provide enough structure to derive a contradiction from persistent F without resolution.

**Confidence**: 15%

### Approach 23: Step function replacement (single index modification)

**Idea**: Instead of modifying the chain construction, prove forward_F using the EXISTING chain plus a "patching" argument. Given F(psi) in chain(n), find some s > n where we can REPLACE chain(s) with a modified MCS that contains psi, while maintaining all required coherence properties.

**Construction**:
1. F(psi) in chain(n). By F-obligation constancy, F(psi) in chain(s) for all s >= n.
2. At step s (where psi is the rrSchedule target), `enriched_fwd_step` gives chain(s+1) with psi in chain(s+1) OR F(psi) in chain(s+1)
3. If psi in chain(s+1): done
4. If F(psi) in chain(s+1): use `discharge_single_step` to get M' with psi in M' and g_content(chain(s)) subset M'
5. Define chain'(s+1) = M' (the replacement)
6. Need to show: all coherence properties still hold for chain' (g_content transitivity, F-obligation constancy, box stability)

**Obstacle**: Replacing chain(s+1) breaks the chain at s+1. chain(s+2) was built from chain(s+1), not from M'. So chain(s+2) no longer has the correct g_content relationship with chain'(s+1). This would require rebuilding chain(s+2), chain(s+3), etc. -- essentially constructing a new chain from s+1 onward.

**But**: We don't actually need psi in the SAME chain. We need psi in chain(s) for some s > n in the EXISTING chain. The replacement idea doesn't help because it creates a DIFFERENT chain.

**Feasibility**: VERY LOW. Patching a single point cascades into rebuilding everything downstream.

**Confidence**: 5%

### Approach 24: Choice function argument (Lindenbaum choice witnessing)

**Idea**: The Lindenbaum extension in `enriched_fwd_step` makes a non-deterministic choice (via `set_lindenbaum ... .choose`). Could we argue that SOME sequence of Lindenbaum choices yields a chain where forward_F holds?

**Construction**:
1. The chain construction uses `Classical.choice` (via `.choose`) at each step
2. Different choices lead to different chains
3. For any fixed psi with F(psi) in chain(n), there EXISTS a Lindenbaum extension at the next ψ-resolving step that puts psi directly in chain(s+1) (by the `enriched_fwd_fold_with_witness` guarantee)
4. But: the choice was already made when the chain was constructed. We need the SPECIFIC chain's properties.

**Problem**: This is equivalent to saying "there exists a chain with the forward_F property" -- which is exactly what we're trying to prove. The choice was already fixed by `Classical.choice`.

**Wait -- actually, this IS the key insight**: The theorem `enriched_fwd_step_resolves_one` guarantees that at EVERY resolving step, SOME formula w with F(w) in M is directly resolved (w in M'). The question is whether w = psi (the target formula) or w is some other formula.

If we could show that within |sigma_list| resolving steps, every formula in sigma_list must be the "directly resolved" witness at least once, then forward_F would follow. This is essentially Strategy C from the existing research.

**Feasibility**: This reduces to Strategy C. Not a new approach.

**Confidence**: N/A (same as Strategy C)

### Approach 25: Ultraproduct / compactness argument

**Idea**: Use model-theoretic compactness to bridge the semantic-syntactic gap. The semantic truth of forward_F in all integer models implies (by compactness) the existence of a syntactic proof. Could we extract this proof?

**Problem**: Compactness of propositional logic gives us that if forward_F holds semantically, then the formula `F(psi) -> F(F(psi))` (or some finite approximation) is derivable. But this is NOT what we need -- we need forward_F for the SPECIFIC chain construction, not as an abstract derivability result.

**Feasibility**: VERY LOW. Compactness operates at the wrong level of abstraction.

**Confidence**: 5%

### Approach 26: Backward chain leverage (h_content propagation)

**Idea**: Use the backward chain's h_content propagation to help the forward chain. If we could show that psi appears in the backward chain at some point, and then propagate this forward...

**Problem**: The backward and forward chains are independent constructions joined at M_0. There is no direct relationship between the backward chain's content and the forward chain's content, beyond sharing M_0. h_content propagation goes BACKWARD in time, not forward.

**Feasibility**: VERY LOW.

**Confidence**: 5%

## Codebase Infrastructure Audit

### Underutilized Infrastructure

1. **`OrderedSeedConsistency.lean`**: Contains `enriched_resolving_seed_consistent`, `ordered_two_defect_seed_consistent`, `temp_linearity_mcs`, `two_defect_consistent_seed`, and `no_new_f_defects`. These are all proved and sorry-free. They provide the mathematical foundation for ordered defect discharge but are not directly used in the forward_F proof path. The `two_defect_consistent_seed` theorem is particularly interesting: it shows that for ANY two F-defects, a consistent seed resolving at least one exists.

2. **`Quasimodel/Construction.lean`**: Contains the quasimodel chain infrastructure including `hintikka_step`, `UntilDefect`, `defect_count`, and `until_elim_mcs`. The defect-counting approach works for UNTIL formulas (finite signature, defect count decreases) but was attempted and failed for F-formulas (where "defect count" is not monotonically decreasing).

3. **`Filtration/DefectChain.lean`**: Contains `sigma_defect_count`, `defect_step_phi`, `defect_step_F_psi`, `defect_step_connect`, `defect_step_self_accum`. These provide the Until defect discharge building blocks. The `defect_step_F_psi` theorem (phi U psi in w -> F(psi) in w) links Until to F, but in the wrong direction for our needs.

4. **`Frame.lean` `bx_forward_witness`**: This is the fundamental ONE-STEP witness: F(psi) in w -> exists v >= w with psi in v. It is proved and sorry-free. The gap is that this gives an ABSTRACT BXPoint v, not a point in the specific chain.

5. **`Frame.lean` `bx_until_eventuality_resolution`**: PROVED sorry-free. Handles Until eventuality by finding a BXPoint witness. Again, abstract BXPoint, not chain-indexed.

### Available but Unused Axioms

The axiom system includes several axioms not currently used in the forward_F proof path:

- **BX7 (linear_until)**: (phi U psi) and (chi U theta) -> (phi U theta) or ... (4-way linearity for Until). Could be relevant if the Until reformulation (Approach 21) is pursued.
- **BX4 (connect_future)**: phi -> G(P(phi)). Establishes temporal connectedness. Used in defect_step_connect but not in the forward chain.
- **modal_future**: Box(phi) -> Box(G(phi)). Not relevant to forward_F.
- **temp_future**: Box(phi) -> G(Box(phi)). Box stability axiom; already used implicitly.

### Infrastructure Summary

| Component | Status | Relevance to forward_F |
|-----------|--------|----------------------|
| `forward_temporal_witness_seed_consistent` | Proved | Core: one-step witness seed |
| `enriched_resolving_seed_consistent` | Proved | Core: ordered seed with protection |
| `enriched_fwd_fold` / `enriched_fwd_fold_with_witness` | Proved | Core: BX11 fold with direct witness |
| `resolving_enriched_fwd_exists` | Proved | Core: enriched step existence |
| `enriched_fwd_step_preserves` | Proved | Core: F-preservation disjunction |
| `enriched_fwd_step_resolves_one` | Proved | Core: at least one formula resolved |
| `rr_fwd_chain_F_obligation_persists` | Proved | Core: F constancy forward |
| `rr_fwd_chain_F_obligation_backward` | Proved | Core: F constancy backward |
| `rr_fwd_chain_F_propagate` | Proved | Key: reduces to "cannot persist forever" |
| `target_stays_direct_in_fold` | Proved | Useful if BX11 minimum exists |
| `discharge_single_step` | Proved | One-step discharge |
| `no_new_f_defects` | Proved | F-obligation set non-growing |
| `bx_forward_witness` | Proved | Abstract one-step witness |
| `bx_until_eventuality_resolution` | Proved | Until eventuality (abstract) |
| `FF_imp_F` / `FF_imp_F_mcs` | Proved | Double-F collapse |
| `phi_in_mcs_imp_F_phi` | Proved | F-obligation non-shrinking |

## Recommended Approach

**Primary recommendation: Strategy C (as already identified) is the best remaining approach.**

After exhaustive review of the literature, 19 failed approaches, and 7 novel approaches analyzed above, Strategy C remains the strongest candidate. The key reasons:

1. It works with the EXISTING proved infrastructure (no chain replacement)
2. It avoids the BX11 non-transitivity / 3-cycle problem
3. It leverages the proved `rr_fwd_chain_F_propagate` reduction
4. It is the only approach that directly attacks the gap rather than trying to circumvent it

**Secondary recommendation: If Strategy C fails, investigate Approach 21 (Until reformulation) more carefully.** The existence of proved `bx_until_eventuality_resolution` is tantalizing. The obstacles (abstract BXPoint vs chain index, deferralClosure membership) are real but might be addressable with a modified restricted coherence notion.

**Confidence in Strategy C**: 55-60% (same as existing assessment)

**Confidence in any approach succeeding**: 65% (accounting for the possibility that Strategy C fails but Approach 21 or a hybrid works)

## The Semantic-Syntactic Gap (Precise Analysis)

### The Semantic Argument (How the Literature Does It)

In an integer model (Z, <), suppose F(psi) is true at time n. Then there exists s > n where psi is true at s. This s is a CONCRETE integer. The well-ordering of N guarantees a LEAST such s. At every point between n and s, F(psi) remains true (because s is still in the future). The model is FIXED: truth values don't change based on how we construct the model.

### The Syntactic Construction (Our Approach)

In our chain construction, chain(n) is an MCS. F(psi) in chain(n). We build chain(n+1) from chain(n) via `enriched_fwd_step`. The Lindenbaum extension (`set_lindenbaum`) makes a CHOICE of how to extend the consistent seed to a full MCS. This choice determines:
- Whether psi is in chain(n+1) or not
- Whether F(psi) is in chain(n+1) or not
- What OTHER formulas are in chain(n+1)

The BX11 fold guarantees a DISJUNCTION: psi in chain(n+1) OR F(psi) in chain(n+1). But the choice is FIXED once made. If the choice puts F(psi) in chain(n+1) (but not psi), we have no control over future choices either.

### Where Precisely the Gap Is

The gap is at the LINDENBAUM EXTENSION step. When we call `set_lindenbaum ({beta'} union g_content(M))`, the choice function picks ONE maximal consistent extension. The BX11 fold guarantees that beta' encodes a disjunction (psi or F(psi)), but the Lindenbaum extension resolves this disjunction ONE way.

In the semantic argument, there's no Lindenbaum step -- the model is given, and truth values are determined by the valuation. In the syntactic argument, we're CONSTRUCTING the model, and each construction step involves a non-deterministic choice that may go against us.

### Could the Gap Be Fundamental?

Possibly not. The key observation is that `enriched_fwd_step_resolves_one` guarantees that SOME formula is directly resolved at each step. The question is whether the "pigeonhole" argument works: with k = |sigma_list| formulas and each step resolving at least one, must every formula be resolved within finitely many steps?

The answer would be YES if the resolved formula were DIFFERENT at each step. But it could be the SAME formula resolved repeatedly (a formula chi that is always the BX11-earliest). The 3-cycle counterexample shows that "BX11-earliest" can cycle, so different formulas could take turns being resolved, but with psi never being the one chosen.

However: if psi is NEVER resolved (for all s > n), and the same finite set of formulas takes turns being resolved, then over k * |sigma_list| steps, each formula is the target at least k times. If the resolved formula is always from a strict subset that excludes psi, this means a strict subset of sigma_list is perpetually cycling through resolution while psi is perpetually deferred. Whether this leads to a contradiction depends on whether the BX11 fold structure allows such perpetual deferral.

**This is the precise open question that Strategy C must answer.**

## Appendix: Axioms Available in the Proof System

For reference, the complete list of BX axioms relevant to temporal reasoning:

| Axiom | Statement | Code Name |
|-------|-----------|-----------|
| BX1 | G(phi) -> phi | `temp_t_future` |
| BX1' | H(phi) -> phi | `temp_t_past` |
| BX2 | G(phi -> chi) -> (phi U psi -> chi U psi) | `left_mono_until` |
| BX3 | G(psi -> chi) -> (phi U psi -> phi U chi) | `right_mono_until` |
| BX4 | G(phi) -> G(G(phi)) | `temp_4` |
| BX4' | phi -> G(P(phi)) | `connect_future` |
| BX5 | (phi U psi) -> ((phi and (phi U psi)) U psi) | `self_accum_until` |
| BX6 | (phi U (phi and (phi U psi))) -> (phi U psi) | `absorb_until` |
| BX7 | (phi U psi) and (chi U theta) -> ... | `linear_until` |
| BX8 | psi -> (phi U psi) | `refl_intro_until` |
| BX9 | (phi U psi) -> (phi or psi) | `until_elim` |
| BX10 | (phi U psi) -> F(psi) | `until_F` |
| BX11 | F(A) and F(B) -> F(A and B) or F(A and F(B)) or F(F(A) and B) | `temp_linearity` |
| BX12 | F(psi) -> top U psi | `F_until_equiv` |
| TK | G(phi -> psi) -> (G(phi) -> G(psi)) | `temp_k_dist` |
