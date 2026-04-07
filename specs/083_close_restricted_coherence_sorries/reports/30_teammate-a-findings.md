# Teammate A Findings: The Quasimodel Approach (GHR 1994)

**Task**: 83 -- Close Restricted Coherence Sorries
**Date**: 2026-04-07
**Angle**: Quasimodel approach for completeness via representation
**Session**: sess_1775620000_qa30tm

---

## Key Findings

### Finding 1: Report 24 Was Partially Wrong About Reflexive Semantics

Report 24 (Section 1.1) stated TM uses "strict temporal semantics" where "G(phi) -> phi is NOT valid." This is **incorrect for the current codebase**. The project was refactored to use **reflexive G/H semantics**:

- `truth_at` (Truth.lean:125-126): `all_future phi` uses `t <= s` (reflexive), `all_past phi` uses `s <= t` (reflexive)
- T-axioms `temp_t_future` and `temp_t_past` (Axioms.lean:266-277) are included: `G(phi) -> phi` and `H(phi) -> phi`
- FMCS forward_G (FMCSDef.lean:110): uses `t <= t'` (reflexive)
- Until/Since remain strict: `untl` uses `t < s`, `snce` uses `s < t`

This is the "mixed" semantics: reflexive G/H, strict U/S. Report 24's Section 1.9 actually acknowledges this ("published proofs handle this... under reflexive temporal semantics") and states "strict semantics of TM breaks this." But TM's G/H ARE reflexive -- the only strict operators are U/S.

**Impact**: This means the standard quasimodel approach from GHR 1994 is CLOSER to applicable than report 24 concluded. The key properties that GHR relies on -- g_content(M) subset M, and G(phi) in M implies phi in M -- DO hold in this project. However, the Until-through-detours problem (Section 1.5 of report 24) persists because it depends on U/S strictness, not G/H reflexivity.

### Finding 2: The Core Obstacle is Until, Not G/H

Under reflexive G/H, the quasimodel approach works cleanly for the G/H/F/P fragment. The obstruction is exclusively in the Until/Since operators:

1. **G/H fragment**: If we had a logic with only G, H, F, P (no U, S), the quasimodel construction would work. A "run" through the quasimodel would be a sequence of MCS connected by g_content containment, and F-witnesses would be guaranteed by the Lindenbaum extension step. Backward-G works because of forward-F via contraposition.

2. **Until breaks detours**: When the quasimodel path "detours" to resolve an F-obligation (jumping to a witness MCS instead of following x_content), Until persistence breaks. Specifically: `(phi U psi) in M_n` gives `X(psi or (phi and (phi U psi))) in M_n`, so the disjunction is in `x_content(M_n)`. But if `path(n+1) = witness_MCS` instead of `x_content(M_n)`, we only get `g_content(M_n) subset witness_MCS`, and the disjunction is NOT necessarily in `g_content(M_n)`.

3. **Why reflexive G/H doesn't help**: g_content(M) = {phi | G(phi) in M}. Under reflexive semantics, g_content(M) subset M (by temp_t_future). But `(phi U psi) in M` does NOT imply `G(phi U psi) in M`. The formula phi U psi says "psi holds at some STRICTLY future time with phi in between." The formula G(phi U psi) says "at all times >= t, psi eventually holds strictly later." These are different -- the first is a single eventuality, the second is perpetual eventuality.

### Finding 3: The GHR 1994 Quasimodel for Until Uses a Different Strategy

In GHR 1994 (Chapter 6), the quasimodel construction for Until does NOT use the "detour to witness" strategy at all. Instead, it uses:

**The "pre-run" strategy**: Rather than building a single chain and detouring, GHR builds *multiple alternative runs* and stitches them together.

Concretely, for a formula phi_0 that is consistent:

**Step 1 (Types)**: Define the set of "types" as ClosureMCS (maximal consistent subsets of the Fischer-Ladner closure FL(phi_0)). This is a finite set. Each type is a maximally consistent set of formulas from FL(phi_0).

**Step 2 (Runs)**: A "run" is a Z-indexed sequence of types sigma: Z -> Types, such that:
- **X-coherence**: For all t, x_content(sigma(t)) intersect FL(phi_0) = sigma(t+1). That is, sigma(t+1) is the restriction of x_content(sigma(t)) to the closure.
- **F-coherence**: For every t and every F(psi) in sigma(t), there exists s > t with psi in sigma(s).
- **Box-coherence**: All types in the run agree on Box formulas restricted to FL(phi_0).

**Step 3 (Existence of F-coherent runs)**: This is the key step. For each type T containing phi_0, construct an F-coherent run through T. The construction is:
1. Start with T at position 0.
2. Build forward deterministically: sigma(t+1) = x_content_restricted(sigma(t)).
3. By finiteness of Types, the sequence of types is eventually periodic.
4. In the periodic part, every F(psi) obligation that persists indefinitely creates a contradiction via the `until_induction` axiom (within the RESTRICTED closure).

**Step 4 (Key insight)**: The until_induction axiom, when applied within the restricted closure FL(phi_0), gives G-formulas *restricted to FL(phi_0)*. The backward-G step within the restricted theory does NOT require full forward_F -- it only requires RESTRICTED forward_F, which is guaranteed by the finiteness of the type sequence.

### Finding 4: The Restricted Backward-G Does NOT Require Forward_F

This is the critical insight that all prior reports missed.

**Claim**: Within the restricted theory (formulas in FL(phi_0)), backward-G CAN be established without forward_F, using the following argument:

**Setup**: We have a sequence of restricted theories (types) sigma(0), sigma(1), ..., each a subset of FL(phi_0). The sequence is eventually periodic (by finiteness). Suppose phi in sigma(n) for all n >= t.

**To show**: G(phi) in sigma(t), where G(phi) is understood as membership in the restricted theory (i.e., G(phi) in FL(phi_0) AND G(phi) in the full MCS extending sigma(t)).

**Issue**: This requires connecting restricted membership to full MCS membership. But in the restricted world, we do NOT need full G(phi) in the MCS. We need the truth lemma to work ONLY for formulas in FL(phi_0).

**The restricted truth lemma argument**: For the restricted/finite model built from the type sequence:
- The "model" has finitely many worlds (the types in the periodic sequence).
- G(phi) at time t in the restricted model means phi at all s >= t. If phi is in every type from position t onward, then by definition of truth in the restricted model, G(phi) is true at t.
- The restricted truth lemma says: for formulas in FL(phi_0), truth in the restricted model iff membership in the type. This is proven by induction on formula structure within FL(phi_0).
- The backward-G case uses: if G(phi) is true at t (i.e., phi true at all s >= t), then G(phi) must be in sigma(t). Proof: if G(phi) NOT in sigma(t), then neg(G(phi)) in sigma(t), i.e., F(neg(phi)) in sigma(t). F(neg(phi)) means exists s >= t (reflexive!) with neg(phi) in sigma(s). But phi is in sigma(s) for all s >= t. So sigma(s) contains both phi and neg(phi), contradicting consistency.

**Wait -- this requires neg(phi) in sigma(s) from F(neg(phi))**. Under reflexive semantics, F(neg(phi)) in sigma(t) means: either neg(phi) in sigma(t) (s = t), or there exists s > t with neg(phi) in some future type.

The key question: does F(neg(phi)) in sigma(t) guarantee a witness in the restricted type sequence? **This is restricted forward_F**, which for the periodic sequence is guaranteed by finiteness: if F(neg(phi)) persists forever in the type sequence without finding a witness for neg(phi), we get a contradiction from until_induction (since F(psi) = top U psi in the Until-enriched fragment, and persistent unresolved Until leads to contradiction by the standard argument).

**But this IS the forward_F circularity!** We are using restricted forward_F to prove backward_G which is needed for the restricted truth lemma which is needed for restricted forward_F.

### Finding 5: The Quasimodel Approach Has the Same Circularity

After rigorous analysis, the quasimodel approach faces the **same fundamental circularity** as the deterministic chain approach, even under reflexive G/H semantics:

1. Restricted truth lemma needs backward-G for formulas in FL(phi_0).
2. Backward-G (even restricted) needs forward-F (even restricted).
3. Forward-F needs the Until truth lemma (to show (phi U psi) true at t implies witness exists).
4. Until truth lemma needs restricted forward-F.

The circularity is: forward_F -> backward_G -> forward_F.

Under the quasimodel approach, the circularity appears at a different point (in the construction of F-coherent runs rather than in the truth lemma), but it is the same structural obstacle.

### Finding 6: The Only Escape -- Simultaneous Construction

The GHR 1994 approach actually breaks the circularity in a way not captured by the report 24 analysis. Here is the key:

**GHR does NOT prove forward_F as a lemma.** Instead, they construct F-coherent runs DIRECTLY, using a *selection function* argument:

**Step 1**: For each type T in the Fischer-Ladner closure, define the "defect" of T as the set of F(psi) obligations in T that are not yet resolved.

**Step 2**: Build the run greedily: at each step, choose the successor type that resolves the "most urgent" defect (by some priority ordering).

**Step 3**: Show that every defect is eventually resolved by the finite deferral argument: if F(psi) persists forever, the type sequence cycles, and the until_induction axiom applied to chi = bot (with G(neg(psi)) obtained from the cycle) gives a contradiction.

**The circularity-breaking insight**: The until_induction axiom IS the way to break the circularity. Specifically:

`G(psi -> chi) AND G((phi AND X(chi)) -> chi) -> ((phi U psi) -> X(chi))`

With phi = top, psi = psi, chi = bot:
- G(psi -> bot) = G(neg(psi))
- (top AND X(bot)) -> bot is equivalent to X(bot) -> bot. Since bot U bot is absurd (requires strict future witness of bot, which never holds), X(bot) = bot U bot is always false. So X(bot) -> bot is a theorem.
- G(theorem) is a theorem.
- So: G(neg(psi)) -> ((top U psi) -> X(bot))
- Since X(bot) is always false: G(neg(psi)) -> neg(top U psi)

This is G_neg_kills_until (already sorry-free in FiniteDeferral.lean).

**The problem remains**: How to get G(neg(psi)) in the type at position t of the cycle. Under reflexive semantics, G(neg(psi)) at t means neg(psi) at all s >= t. If neg(psi) is in every type from t onward (which it is, since psi never appears in the cycle), then G(neg(psi)) SHOULD be in the type at t.

**But "neg(psi) in every type" is a META-level statement**, not an OBJECT-level one. To get G(neg(psi)) into the type, we need the backward-G direction of the truth lemma.

### Finding 7: The Real GHR Solution -- Build G-Formulas Into Types

The actual GHR approach builds the G-closure directly into the type construction:

**Definition (GHR-style saturated types)**: A type T (subset of FL(phi_0)) is *saturated* if:
1. T is propositionally consistent
2. T is closed under subformula-respecting implications
3. **G-saturation**: If G(psi) in FL(phi_0) and psi in T, and psi in ALL types reachable from T via x_content_restricted, then G(psi) in T.
4. **Until-coherence**: (phi U psi) in T implies X(psi or (phi and (phi U psi))) in T.

Condition 3 is the key: it builds the backward-G property INTO the type definition. This avoids deriving backward-G as a lemma -- it is ASSUMED as part of what it means to be a type.

**But condition 3 is circular**: To check whether G(psi) should be in T, we need to know ALL types reachable from T, which requires knowing the types that T transitions to, which requires knowing those types' G-formulas, which requires...

**GHR breaks this circularity** using a FINITE FIXPOINT argument:

1. Start with "naive types" -- just maximally propositionally consistent subsets of FL(phi_0).
2. Define the x_content_restricted successor function on naive types.
3. Compute the set of "reachable types" from each naive type (finite graph reachability).
4. Add G(psi) to any type T where psi appears in ALL types reachable from T.
5. This may change the successor function (adding G(psi) might change x_content_restricted), so iterate.
6. The iteration terminates because FL(phi_0) is finite and we only ever ADD formulas to types (monotone operation on a finite lattice).

**This is a greatest fixpoint construction** on the lattice of type assignments.

### Finding 8: Formalization Cost Estimate

To formalize the GHR quasimodel approach in this codebase:

**New definitions needed** (~300 lines):
1. `ClosureType`: Maximally consistent subsets of FL(phi_0) -- essentially `ClosureMCS` from Decidability/FMP/ClosureMCS.lean (may be reusable)
2. `x_content_restricted`: x_content projected to FL(phi_0)
3. `type_graph`: Finite directed graph of type transitions
4. `reachable_types`: Reachable types from a given type in the graph
5. `saturated_type`: Type with G-saturation property
6. `saturation_fixpoint`: Greatest fixpoint construction
7. `quasimodel_run`: Z-indexed sequence of saturated types

**New lemmas needed** (~800-1200 lines):
1. `x_content_restricted_well_defined`: x_content_restricted preserves type-ness (~50 lines)
2. `saturation_terminates`: Fixpoint iteration terminates (~100 lines, finiteness argument)
3. `saturated_type_consistent`: Saturated types are consistent (~80 lines)
4. `G_saturation_correct`: If psi in all reachable types, G(psi) in current type (~60 lines)
5. `F_coherent_run_exists`: Every F-obligation is resolved in the run (~200 lines, this is the finite deferral + fixpoint argument)
6. `until_coherent_run`: Until persistence holds in the run (~100 lines)
7. `restricted_truth_lemma_saturated`: Truth lemma for saturated types (~200 lines)
8. `run_to_FMCS`: Convert a run to an FMCS Int (~80 lines)
9. `run_to_BFMCS`: Convert runs to BFMCS with modal coherence (~150 lines)
10. `quasimodel_completeness`: Wire to existing parametric representation (~50 lines)

**Reusable infrastructure**:
- `deferralClosure` / `closureWithNeg` from SubformulaClosure.lean
- `ClosureMCS` from Decidability/FMP/ClosureMCS.lean
- `SetMaximalConsistent` and all MCS properties
- `x_content_mcs` / `y_content_mcs` from TemporalContent.lean
- `until_unfold_in_mcs`, `until_persists_chain_general` from FiniteDeferral.lean
- `G_neg_kills_until` from FiniteDeferral.lean
- `parametric_algebraic_representation_conditional` from ParametricRepresentation.lean

**Total estimate**: 1100-1500 lines of new code.

### Finding 9: The Hardest Lemma

The hardest lemma to formalize is `F_coherent_run_exists`: proving that every F-obligation in a run of saturated types is eventually resolved.

**Proof sketch**:
1. Assume F(psi) in sigma(t) but psi not in sigma(s) for all s > t.
2. By F_until_equiv: (top U psi) in sigma(t).
3. By until persistence: (top U psi) in sigma(n) for all n >= t.
4. The type sequence is eventually periodic (finite types, deterministic successor on the finite graph).
5. In the periodic part: neg(psi) in every type, (top U psi) in every type.
6. By G-saturation of the saturated types: G(neg(psi)) in sigma(t). (Because neg(psi) is in ALL types reachable from sigma(t), and G-saturation says this implies G(neg(psi)) in sigma(t).)
7. By G_neg_kills_until: G(neg(psi)) and (top U psi) are inconsistent. But sigma(t) contains both. Contradiction with consistency of sigma(t).

Step 6 is where the G-saturation fixpoint does the heavy lifting. The circularity is broken because G(neg(psi)) is not DERIVED from forward_F -- it is BUILT INTO the type by the saturation construction.

**The subtlety**: Step 6 requires that neg(psi) is in ALL types reachable from sigma(t) in the type graph. The "reachable" relation is defined on the type graph AFTER saturation. Adding G(neg(psi)) to sigma(t) might change the successor of sigma(t) (because x_content_restricted depends on the content of the type). This is why the fixpoint argument is needed -- the saturation and the successor function must converge together.

**Difficulty level**: HIGH. The greatest fixpoint on a finite lattice is well-understood mathematically, but formalizing it in Lean 4 requires careful handling of Fintype instances, monotone operators, and termination.

---

## Recommended Approach

### Strategy: GHR-style Quasimodel with Saturated Types

**Phase 1: Closure Types** (~200 lines)
- Define ClosureType as maximally consistent subsets of an extended Fischer-Ladner closure (reuse/extend ClosureMCS)
- Prove basic properties (consistency, completeness within closure, finiteness)
- Define x_content_restricted and prove it preserves ClosureType

**Phase 2: Saturation Fixpoint** (~400 lines)
- Define the G-saturation operator on type assignments
- Prove monotonicity (adding G-formulas is monotone)
- Prove termination (finite lattice has finite ascending chains)
- Prove saturated types are consistent (key: G(phi) is consistent with any set that doesn't contain neg(G(phi)), and if phi is in all reachable types, then neg(G(phi)) would mean F(neg(phi)), but neg(phi) is in no reachable type, contradiction)

**Phase 3: F-Coherent Runs** (~300 lines)
- Define runs as Z-indexed sequences of saturated types with x_content linkage
- Prove F-coherence using the G-saturation + G_neg_kills_until argument
- Prove Until/Since coherence from x_content linkage (reuse until_persists machinery)

**Phase 4: BFMCS Construction** (~200 lines)
- Extend runs to full MCS (Lindenbaum extension of each restricted type)
- Prove temporal coherence (forward_G, backward_H from run coherence)
- Prove forward_F, backward_P from run F-coherence
- Construct BFMCS bundle with modal coherence
- Wire to parametric_algebraic_representation_conditional

**Total**: ~1100 lines, with high confidence of success.

### Alternative: Direct Forward_F via Saturation

Instead of building the full quasimodel infrastructure, directly prove `deterministic_forward_F` using a saturation argument:

1. The deterministic chain from M_0 exists (sorry-free).
2. Restrict to deferralClosure(psi) -- the restricted theories cycle (sorry-free).
3. At the cycle, apply a LOCAL saturation argument: show that the cycle's restricted theories, when G-saturated, contain G(neg(psi)).
4. Conclude contradiction via G_neg_kills_until.

**This is essentially the FiniteDeferral approach with the missing step (G(neg(psi)) derivation) filled by the saturation construction rather than by backward_G.**

Estimated: ~400-600 lines. Lower risk than full quasimodel because it reuses the existing deterministic chain.

---

## Evidence/Examples

### Example: Forward_F for an Atom

Let psi = atom(p). Assume F(p) in chain(0) but p not in chain(n) for any n > 0.

1. (top U p) in chain(0) by F_until_equiv.
2. (top U p) in chain(n) for all n >= 0 by until_persists.
3. neg(p) in chain(n) for all n > 0.
4. Restricted theories on deferralClosure(p) cycle: exists i < j with restrictedTheory(i) = restrictedTheory(j).
5. neg(p) in every type in the cycle.
6. **Saturation step**: neg(p) is in ALL types reachable from the cycle start. By G-saturation, G(neg(p)) should be in the type at the cycle start.
7. But G(neg(p)) is a formula OUTSIDE deferralClosure(p) in general (it IS in deferralClosure if we use the current definition which includes closureWithNeg, which includes G-wrapped formulas of subformulas).

Actually, checking: is G(neg(p)) in deferralClosure(p)? neg(p) = p -> bot. all_future(p -> bot) = G(neg(p)). Is this in closureWithNeg(p)? closureWithNeg includes subformulas of p and their negations. The subformulas of p are just {p}. closureWithNeg(p) = {p, neg(p)}. G(neg(p)) is NOT in closureWithNeg(p). So G(neg(p)) is NOT in deferralClosure(p) as currently defined.

**This is a problem**: The saturation step requires G-formulas to be in the closure. The current deferralClosure is too small.

**Solution**: Use an EXTENDED closure that includes G-wrapped and H-wrapped versions of all formulas in the closure. This is standard in the GHR construction (Fischer-Ladner closure includes temporal unfoldings). The extended closure is still finite (at most a polynomial blowup).

---

## Gaps and Risks

### Gap 1: Extended Closure Definition

The current `deferralClosure` does not include G-wrapped formulas. A new `extendedFischerLadnerClosure` would need to be defined, including:
- All subformulas of phi_0
- Negations of all subformulas
- G(psi) and H(psi) for every psi in the closure
- X(psi or (phi and (phi U psi))) for every (phi U psi) in the closure
- Deferral disjunctions

This closure is still finite (O(|phi_0|^2) in size). New definition: ~50 lines. But it invalidates the existing pigeonhole bounds in FiniteDeferral.lean (which use the current deferralClosure).

### Gap 2: x_content_restricted May Not Preserve Saturated Types

When we restrict x_content to the extended closure, the resulting type may lose formulas that were added by saturation. The saturation fixpoint must be recomputed after each x_content step. This is handled by the fixpoint construction, but it adds complexity.

### Gap 3: Saturated Type Consistency

Proving that saturated types are consistent is the most delicate step. Adding G(psi) to a type T might introduce inconsistency if T already contains neg(G(psi)) = F(neg(psi)). But if psi is in all reachable types, and T is consistent with psi, then... we need to show that F(neg(psi)) is NOT in T.

**Argument**: If F(neg(psi)) in T, then by F_until_equiv, (top U neg(psi)) in T. By Until persistence through the type graph, neg(psi) eventually appears in some reachable type. But psi is in ALL reachable types. If neg(psi) also appears in some reachable type, that type is inconsistent. Contradiction.

This argument works BUT uses Until persistence through the type graph, which requires the type graph to have x_content linkage. And x_content linkage depends on the type content, which depends on saturation. **More circularity.**

### Gap 4: The Fundamental Circularity Resurfaces

Even in the GHR quasimodel approach with saturated types, the circularity appears at a different level:

- **Saturation requires reachability**: G(psi) is added when psi is in all reachable types.
- **Reachability depends on type content**: The successor function x_content_restricted depends on which G-formulas are in the type.
- **Type content depends on saturation**: The G-formulas in the type depend on the saturation.

This is a genuine greatest fixpoint problem, not a simple induction. The mathematical solution exists (Knaster-Tarski theorem guarantees a fixpoint on the finite lattice of type assignments), but the fixpoint may be trivial (empty or inconsistent types).

**The key question**: Does the greatest fixpoint preserve consistency of types?

**Potential failure mode**: The greatest fixpoint might saturate types to the point of inconsistency. If adding G(neg(psi)) to a type T makes T inconsistent (because T contains F(neg(neg(psi))) = F(psi), and G(neg(psi)) contradicts (top U psi) in T via G_neg_kills_until), then the fixpoint would need to REMOVE (top U psi) from T, but types are maximal consistent subsets of the closure -- removing a formula changes the type.

**This means**: The saturation might NOT be a monotone operation on the space of individual types. It is monotone on the space of type ASSIGNMENTS (which type goes at which position), but individual types cannot have formulas added without potentially becoming inconsistent.

### Gap 5: The GHR Approach Uses Elimination, Not Saturation

Re-reading GHR 1994 more carefully, their approach is actually **eliminative** rather than **accumulative**:

1. Start with ALL possible types (maximally consistent subsets of the closure).
2. **Eliminate** types that have unfulfillable eventualities: if T has F(psi) but no reachable type has psi, eliminate T.
3. Iterate elimination until fixpoint.
4. This is a LEAST fixpoint on the set of remaining types.
5. Show that the initial type (containing phi_0) survives elimination.

This is a different approach from "add G-formulas to types." It removes bad types rather than enriching existing ones.

**Application to our problem**: In the eliminative approach:
1. Define all closure types (maximally consistent subsets of the extended FL closure).
2. Define the elimination: remove any type T such that there exists F(psi) in T but no type in the reachable set (through the type graph restricted to non-eliminated types) has psi.
3. Iterate until fixpoint. Since we only eliminate types (monotone on a finite set), this terminates.
4. Show that the type corresponding to M_0 restricted to the closure survives.
5. Every surviving type has all its F-obligations fulfillable within the surviving types.
6. Construct a run from surviving types.

**Step 4 is the key**: Why does the initial type survive? Because M_0 is consistent, and elimination only removes types with unfulfillable eventualities. If M_0's restricted type has F(psi), then by the consistency of M_0 and the F_until_equiv axiom, (top U psi) is in M_0, and by the richness of the type graph (which includes all consistent types, not just those on the deterministic chain), there should be a type containing psi reachable from M_0's type.

**But wait**: The type graph is defined by x_content_restricted. Is the type containing psi necessarily reachable from M_0's type via x_content? Not necessarily -- it may require a "detour" through a non-x_content step. And that is exactly the problem that broke the quasimodel approach in report 24.

### Risk Summary

| Risk | Severity | Mitigation |
|------|----------|------------|
| G-saturation circularity | HIGH | Greatest fixpoint on finite lattice (Knaster-Tarski), but consistency preservation is unclear |
| Extended closure size | MEDIUM | O(|phi_0|^2), manageable but requires new definitions |
| Until through type graph detours | HIGH | Same problem as report 24 Section 1.5 |
| Eliminative fixpoint: initial type survival | HIGH | Requires showing F-witnesses exist in the type graph |
| Formalization complexity | MEDIUM | ~1100-1500 lines, builds on existing infrastructure |

---

## Confidence Level

**LOW-MEDIUM** (35-45% probability of success)

The quasimodel approach, as rigorously analyzed above, faces the same fundamental circularity as the deterministic chain approach, but at a different level of abstraction. The circularity appears in the saturation/elimination fixpoint construction rather than in the truth lemma.

The approach COULD work if:
1. The greatest fixpoint on the finite lattice of type assignments preserves consistency AND
2. The initial type survives elimination AND
3. The type graph provides enough reachable types for all F-obligations

But each of these requires careful argument, and the interaction between G-saturation and Until persistence remains problematic.

**Comparison with report 24**: Report 24 concluded the quasimodel approach "FAILS for strict semantics" with 0% probability. My analysis shows this was based on a misidentification of the semantics (G/H are reflexive, not strict). The correct conclusion is that the approach faces serious obstacles but is not definitively blocked. The probability is higher than 0% but lower than the 50-60% estimated by the team research synthesis (report 29).

**Key uncertainty**: Whether the eliminative fixpoint (GHR-style) preserves the reachability of F-witnesses in the type graph, given that the type graph uses x_content_restricted (deterministic) rather than arbitrary successor. If x_content_restricted always provides a path to every F-witness within the surviving types, the approach works. If not, it fails at the same point as all other approaches.

---

## Appendix: Mathematical Detail of the GHR Quasimodel

### A.1 Fischer-Ladner Closure for TM

For a formula phi_0 in TM, define FL(phi_0) as the smallest set containing phi_0 and closed under:

1. If psi in FL(phi_0), every immediate subformula of psi is in FL(phi_0).
2. If psi in FL(phi_0), neg(psi) in FL(phi_0) (where neg(psi) = psi -> bot).
3. If (phi U psi) in FL(phi_0), then X(psi or (phi and (phi U psi))) in FL(phi_0).
4. If (phi S psi) in FL(phi_0), then Y(psi or (phi and (phi S psi))) in FL(phi_0).
5. If G(psi) in FL(phi_0), then psi in FL(phi_0).
6. If H(psi) in FL(phi_0), then psi in FL(phi_0).
7. If F(psi) in FL(phi_0), then (top U psi) in FL(phi_0) (by F_until_equiv).
8. If P(psi) in FL(phi_0), then (top S psi) in FL(phi_0) (by P_since_equiv).
9. **G-closure**: If psi in FL(phi_0), then G(psi) in FL(phi_0).
10. **H-closure**: If psi in FL(phi_0), then H(psi) in FL(phi_0).

Rules 9 and 10 are the key additions for the saturated type construction. They ensure that G-wrapped formulas are available in the closure for the saturation step.

**Finiteness**: |FL(phi_0)| = O(|phi_0|^2) because each subformula generates at most a constant number of additional formulas, and rules 9/10 at most double the closure.

### A.2 Types and the Type Graph

A **type** is a maximally consistent subset of FL(phi_0) -- that is, a set T subset FL(phi_0) such that:
- T is propositionally consistent (no derivation of bot from T using only propositional axioms)
- For every psi in FL(phi_0), either psi in T or neg(psi) in T (maximality within FL)

The **type graph** has types as vertices and edges T -> T' when T' = x_content_restricted(T), where x_content_restricted(T) = {psi in FL(phi_0) | X(psi) in T} (using X(psi) = bot U psi).

### A.3 The Eliminative Fixpoint

Define the elimination sequence:
- S_0 = all types
- S_{n+1} = {T in S_n | for all F(psi) in T, exists T' in S_n reachable from T via the type graph restricted to S_n, with psi in T'}
- S_omega = intersection of all S_n

By finiteness, the intersection is reached at some finite n.

**Properties of S_omega**:
- Every type in S_omega has all its F-obligations fulfillable within S_omega.
- If T in S_omega and T has (phi U psi), then either psi in some reachable type, or (phi U psi) persists forever in a cycle of types, all of which are in S_omega, and the cycle resolves via until_induction + G(neg(psi)) which IS in every type in the cycle (by G-closure + maximality: neg(psi) in every reachable type means G(neg(psi)) in T by the G-closure rule of FL combined with maximality).

**Wait**: I need to be more careful. Just because neg(psi) is in every reachable type does NOT automatically mean G(neg(psi)) is in T. G(neg(psi)) is in FL(phi_0) (by rule 9, if neg(psi) is in FL). For G(neg(psi)) to be in T (which is maximally consistent within FL), we need either G(neg(psi)) in T or neg(G(neg(psi))) in T. If neg(G(neg(psi))) = F(psi) in T, then psi must be fulfillable within S_omega (since T is in S_omega). If psi is fulfillable, then some reachable type has psi, contradicting "neg(psi) in every reachable type." So F(psi) cannot be in T, hence G(neg(psi)) must be in T.

**This argument works!** The key step is:
1. Assume neg(psi) in every type reachable from T in S_omega.
2. Either G(neg(psi)) in T or F(psi) in T (maximality in FL).
3. If F(psi) in T, then psi is fulfillable in S_omega (T survived elimination), so some reachable type has psi. Contradiction with step 1.
4. Therefore G(neg(psi)) in T.

**This breaks the circularity** because:
- The argument uses the ELIMINATIVE property of S_omega (every F-obligation is fulfillable).
- This property is established by the fixpoint construction, NOT by backward-G.
- The backward-G direction (getting G(neg(psi)) from pointwise neg(psi)) follows from the eliminative property + maximality in FL, without any separate backward-G lemma.

### A.4 Why This Breaks the Circularity (Detailed)

The circularity in the deterministic chain was: forward_F needs backward_G needs forward_F.

In the eliminative quasimodel:
- **forward_F** (F-obligations are fulfillable) is established by the eliminative fixpoint construction. Types that CANNOT fulfill their F-obligations are REMOVED.
- **backward_G** (G(neg(psi)) from pointwise neg(psi)) follows from maximality + the eliminative property. It does NOT need forward_F as a precondition -- it uses the eliminative property directly.

So the logical dependency is: fixpoint construction -> forward_F AND backward_G (independently).

**The fixpoint construction itself does not need forward_F or backward_G.** It is a purely combinatorial argument about reachability in a finite graph.

### A.5 The Remaining Question: Does the Initial Type Survive Elimination?

The above argument establishes that types in S_omega have the right properties. But we need to show that the initial type (M_0 restricted to FL) SURVIVES the elimination process.

**The problem**: T_0 (the initial type) survives elimination iff all its F-obligations are fulfillable in S_omega. But "fulfillable in S_omega" requires that the target formula appears in some reachable type IN S_omega. Types reachable from T_0 in S_omega are a SUBSET of types reachable in the full graph, because some reachable types may have been eliminated. So it is possible that T_0's F-obligation WAS fulfillable in the full graph but becomes unfulfillable after elimination.

**The GHR resolution**: GHR proves by induction on the elimination steps that no type is WRONGLY eliminated. The argument:
1. At elimination round 0, S_0 = all types.
2. Any type T with F(psi) has a reachable type T' with psi (in the full type graph). Why? Because if neg(psi) is in ALL reachable types from T, then by the A.4 argument, G(neg(psi)) in T. But G(neg(psi)) and (top U psi) are contradictory (G_neg_kills_until). If F(psi) in T then (top U psi) in T (by F_until_equiv in the restricted closure). So T is inconsistent -- but T is a type (consistent by definition). Contradiction. So neg(psi) CANNOT be in all reachable types.
3. Therefore, every type in S_0 has all F-obligations fulfillable. S_1 = S_0. The fixpoint is reached immediately.

**Wait -- this proves S_omega = S_0!** No types are eliminated! Every type has all its F-obligations fulfillable in the full type graph (no elimination needed).

**This IS the circularity-breaking result.** It says: for any type T in the extended FL closure, if F(psi) in T, then some type reachable from T (via x_content_restricted) contains psi. And since "reachable" means reachable via the type graph (deterministic x_content_restricted steps), this means the deterministic restricted chain from T eventually reaches a type containing psi.

**But wait -- is Step 2 actually correct?** Let me verify more carefully.

Step 2 claims: neg(psi) in ALL types reachable from T implies G(neg(psi)) in T. The argument: G(neg(psi)) in FL (by G-closure). By maximality of T in FL, either G(neg(psi)) in T or neg(G(neg(psi))) in T. neg(G(neg(psi))) = F(neg(neg(psi))). If F(neg(neg(psi))) in T, does neg(neg(psi)) appear in some reachable type? If so, that type has both neg(psi) (by assumption) and neg(neg(psi)), which is inconsistent -- impossible. So neg(neg(psi)) appears in NO reachable type. But does this mean F(neg(neg(psi))) in T is impossible?

F(neg(neg(psi))) in T means neg(G(neg(neg(psi)))) in T. By G_dne_theorem in the proof system: G(neg(neg(psi))) -> G(psi). Contrapositive: neg(G(psi)) -> neg(G(neg(neg(psi)))). So neg(G(psi)) in T implies neg(G(neg(neg(psi)))) in T, i.e., F(neg(neg(psi))) in T.

But we also need the reverse: does F(neg(neg(psi))) in T tell us that neg(neg(psi)) must be fulfillable? The eliminative argument says T survives iff ALL F-obligations in T are fulfillable. If F(neg(neg(psi))) in T and neg(neg(psi)) is in no reachable type, then T has an unfulfillable F-obligation.

So T has F(neg(neg(psi))) unfulfillable. If T also has F(psi) (which it does -- that's our original assumption), and F(psi) might also be unfulfillable (that's what we're trying to prove by contradiction)... then T has MULTIPLE unfulfillable F-obligations, and should be eliminated.

**But T was constructed as a consistent type.** Can a consistent type have an F-obligation that is unfulfillable in the type graph?

**Yes, it can.** The type graph is a RESTRICTED structure (types are max consistent subsets of FL, edges are x_content_restricted). A formula may be consistent in the full proof system but unfulfillable in the restricted type graph. For example, F(psi) in T means there EXISTS an MCS in the full language containing psi with the right g_content relationship. But the RESTRICTED type graph might not have a path from T to a type containing psi, because the path in the full language might go through MCS whose restrictions to FL are different from any x_content_restricted path from T.

**This is the fundamental gap.** The eliminative argument works IF the type graph (x_content_restricted) is rich enough to provide paths to all F-witnesses. But x_content_restricted is deterministic -- there is exactly ONE outgoing edge from each type. So the "reachable" set from T is just the deterministic chain of x_content_restricted successors, which is exactly the restricted chain from the deterministic construction.

**And proving that the deterministic restricted chain resolves all F-obligations IS the forward_F problem.**

### A.6 Honest Assessment of the Quasimodel Approach

After this detailed analysis, the quasimodel approach faces the same fundamental obstacle as all other approaches, but dressed in different clothes:

1. The A.4 argument (G(neg(psi)) from maximality) IS valid as a step in the proof.
2. But it requires that F(neg(neg(psi))) in T implies neg(neg(psi)) is fulfillable, which requires the eliminative property for F(neg(neg(psi))).
3. This creates a regress: fulfillability of F(neg(neg(psi))) requires either (a) neg(neg(psi)) in some reachable type, or (b) showing that F(neg(neg(psi))) leads to contradiction.
4. Option (a) requires neg(neg(psi)) in some type, which by DNE in the type is equivalent to psi in some type -- this is what we're trying to prove.
5. Option (b) applies the same argument recursively: neg(neg(neg(psi))) in no reachable type, so G(neg(neg(psi))) in T. By G_dne, G(psi) in T. Then: all_future(psi) in T, so psi in T (by temp_t_future). And F(psi) in T (our original assumption) is resolved at T itself (since psi in T and under reflexive semantics F(psi) at t includes witness s = t).

**Wait -- option (b) works!**

Let me trace through carefully:
1. neg(psi) in ALL types reachable from T.
2. neg(neg(psi)) in NO type reachable from T (would contradict neg(psi) by inconsistency).
3. G(neg(psi)) in FL. By maximality: G(neg(psi)) in T or F(neg(neg(psi))) in T.
4. If F(neg(neg(psi))) in T:
   a. neg(neg(neg(psi))) in ALL reachable types? neg(neg(neg(psi))) = neg(psi) -> bot -> bot -> bot... Actually: neg(neg(psi)) = (psi -> bot) -> bot. neg(neg(neg(psi))) = ((psi -> bot) -> bot) -> bot. Is this in all reachable types?
   b. We know neg(psi) in all reachable types. Is neg(neg(psi)) in all reachable types? NO -- neg(neg(psi)) and neg(psi) are contradictory, so neg(neg(psi)) is in NO reachable type (as noted in step 2).
   c. So there are reachable types with neg(neg(neg(psi))) = neg(neg(psi)).neg -- wait, I'm getting confused with the double negation.

Let me use cleaner notation. Let a = psi, b = neg(a) = a -> bot, c = neg(b) = b -> bot.

We have: b in ALL reachable types. c in NO reachable type (c and b contradict).

F(c) in T means: neg(G(neg(c))) in T = neg(G(b -> bot -> bot)) in T... actually F(c) = neg(all_future(c.neg)) = neg(all_future(c -> bot)).

Hmm, this is getting very syntactically convoluted. Let me try a different approach.

Under reflexive semantics, F(psi) at time t means exists s >= t with psi at s. The witness can be s = t itself. So F(psi) in MCS_t and psi in MCS_t is perfectly consistent -- it means the F-obligation is resolved by the present time.

**Key insight**: Under reflexive semantics, G(neg(psi)) in T and (top U psi) in T gives a contradiction (G_neg_kills_until). But also, under reflexive semantics, G(neg(psi)) in T implies neg(psi) in T (by temp_t_future). And (top U psi) in T requires a STRICT future witness (s > t), not at t itself. So G(neg(psi)) in T says neg(psi) at all times >= t, while (top U psi) requires psi at some time > t. These are contradictory.

Now, does the maximality argument give us G(neg(psi)) in T? Under the assumption that neg(psi) is in all types reachable from T (via x_content_restricted):

- G(neg(psi)) in FL (by G-closure).
- Either G(neg(psi)) in T or neg(G(neg(psi))) in T.
- neg(G(neg(psi))) in T means F(psi') in T where psi' = neg(neg(psi)).
- By DNE in MCS: neg(neg(psi)) is equivalent to psi (under classical logic, they are interderivable).
- **Key**: Does F(neg(neg(psi))) in T combined with DNE give us F(psi) in T?

No -- F(neg(neg(psi))) and F(psi) are DIFFERENT formulas syntactically. F(neg(neg(psi))) = neg(all_future(neg(neg(neg(psi))))). F(psi) = neg(all_future(neg(psi))). These are different formulas.

However, by the G_dne_theorem (already proved sorry-free in the codebase): G(neg(neg(psi))) -> G(psi). Contrapositive: neg(G(psi)) -> neg(G(neg(neg(psi)))). That is: F(neg(psi)) is implied by F(neg(neg(neg(psi)))). This is NOT what we need.

What we need: neg(G(neg(psi))) implies something useful. neg(G(neg(psi))) = F(neg(neg(psi))). In the MCS T, F(neg(neg(psi))) in T. By the `neg_all_future_to_some_future_neg` lemma (TemporalCoherence.lean:92-101): if neg(G(phi)) in MCS, then F(neg(phi)) in MCS. Applied with phi = neg(psi): if neg(G(neg(psi))) in T, then F(neg(neg(psi))) in T. This is what we already have.

Now, F(neg(neg(psi))) in T. Does this mean neg(neg(psi)) is fulfillable? In the restricted type graph, neg(neg(psi)) must appear in some reachable type. But neg(neg(psi)) and neg(psi) are contradictory, and neg(psi) is in every reachable type. So neg(neg(psi)) is in NO reachable type.

So F(neg(neg(psi))) in T is an F-obligation that CANNOT be fulfilled in the type graph. This means T is inconsistent within the restricted closure FL... or does it?

T is a maximal consistent subset of FL. F(neg(neg(psi))) in T is consistent with the other formulas in T. The RESTRICTED type graph just happens not to provide a witness. This does NOT make T inconsistent -- it makes the type graph incomplete for this F-obligation.

**This is the fundamental issue**: The restricted type graph (with deterministic x_content_restricted edges) may not provide witnesses for all F-obligations. The full MCS world DOES have witnesses (by Lindenbaum extension), but these witnesses may not correspond to types reachable via x_content_restricted.

**Conclusion of A.6**: The quasimodel approach, even with the eliminative fixpoint and G-closure, CANNOT break the forward_F circularity within the restricted type graph. The type graph's deterministic structure (x_content_restricted) is too constrained to guarantee F-witnesses.

The approach would require ENRICHING the type graph with non-deterministic edges (e.g., edges to Lindenbaum witness types), but this reintroduces the Until-through-detours problem from report 24 Section 1.5.

---

## Final Summary

The quasimodel approach from GHR 1994, rigorously analyzed for the specific logic TM as formalized in this codebase (reflexive G/H with strict U/S), **does not resolve the forward_F blocker** through the representation-based (canonical model) path. The circularity is structural:

1. Forward_F requires finding a witness in the deterministic chain (or type graph).
2. Proving the witness exists (by contradiction via G_neg_kills_until) requires G(neg(psi)) in the MCS/type.
3. Getting G(neg(psi)) requires either backward-G (which needs forward_F) or an eliminative fixpoint argument (which needs the type graph to provide F-witnesses, which IS forward_F).

The reflexive G/H semantics (correcting report 24's misidentification) makes g_content(M) subset M, but does NOT help with Until persistence through detours or with the backward-G derivation.

The quasimodel approach WOULD work if the type graph had non-deterministic edges (allowing detours to witness types), but this breaks Until persistence. The approach WOULD also work if the type graph's deterministic structure (x_content_restricted) guaranteed F-witness reachability, but proving this IS forward_F.

**Recommendation**: Investigate the decidability-based completeness path (Metalogic/Decidability/) as the highest-priority alternative. If that is far from complete, the quasimodel approach remains the most promising framework for a NEW proof, but requires ~1100-1500 lines and a novel insight for breaking the circularity that this analysis did not find.
