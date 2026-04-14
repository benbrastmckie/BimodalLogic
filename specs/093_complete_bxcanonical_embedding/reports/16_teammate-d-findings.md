# Teammate D (Horizons) Findings — Round 16

**Task**: 93 - Close BXCanonical embedding (6 sorry sites in RootScopedChain.lean)
**Date**: 2026-04-14
**Focus**: Literature deep dive, mathematical foundations, creative alternatives, strategic assessment

## Key Findings

1. **The `{target} union g_content(M) union f_carry(M)` seed IS genuinely inconsistent** -- this was proved by counterexample in Report 07 (MCS containing F(G(neg chi)) and F(chi), resolving target = G(neg chi) produces seed with both G(neg chi) and F(chi) = neg G(neg chi)). This is NOT a conjecture; it is a confirmed dead end.

2. **No existing Lean 4 formalization of temporal logic completeness exists anywhere.** The FormalizedFormalLogic/Foundation project covers propositional, first-order, superintuitionistic, and standard modal logic completeness (Kripke semantics), but has NO temporal logic completeness. The LeanearTemporalLogic project formalizes LTL syntax/semantics only (no completeness proof). The Lentil project (TLA in Lean 4) focuses on model-checking, not completeness. **This project would be the first Lean 4 formalization of temporal logic completeness -- a publishable contribution.**

3. **The standard literature proofs (Burgess 1984, Goldblatt 1992, Xu 1988) all use a per-formula chain construction**, not a single global chain. The key insight: each F-defect is resolved independently, and the final model is assembled from pieces. However, these constructions work on paper because they can appeal to the Axiom of Choice freely -- the BX11 linearity axiom guarantees a total preorder on F-witnesses, and the literature implicitly assumes one can "pick the earliest" at each step.

4. **The Verbrugge-de Jongh-Veltman (2004) constructive method** builds models by explicit finite-stage construction rather than Lindenbaum extension. Their method for linear time tense logics constructs consecutive copies of Z. This is architecturally similar to the dd_chain approach but avoids the forward_F problem by constructing the chain FORWARD from the start, placing witnesses for F-formulas at explicitly chosen future positions. However, adapting this method would require a complete rewrite of the canonical model construction.

5. **BX11 ordering is NOT transitive** (confirmed in handoff 02_forward-F-analysis.md). A 3-cycle is possible: bx11_earlier M a b, bx11_earlier M b c, bx11_earlier M c a. This means a global "minimum" element may not exist. However, **this does not block the ordered discharge approach** -- what matters is that at each step, SOME element can be treated as earliest among the CURRENT active defects using target_stays_direct_in_fold.

6. **The `target_stays_direct_in_fold` theorem is already proved** (RootScopedChain.lean:1009-1045, sorry-free). The infrastructure for the ordered discharge approach is in place. The remaining gap is purely the chain-level argument connecting target_stays_direct_in_fold to forward_F.

## Literature Analysis

### What Burgess (1982/1984) Actually Does

Burgess's original completeness proof for the Since-Until logic proceeds as follows:

1. **Canonical frame**: Worlds are maximal consistent sets (MCS). The temporal ordering is defined via g_content inclusion (G(phi) in M implies phi in M', where M R M').

2. **Chain construction**: For each formula F(psi) in an MCS M, Burgess finds a successor M' with psi in M' and g_content(M) subset M'. This uses the standard "forward temporal witness seed" -- {psi} union g_content(M) is consistent when F(psi) in M.

3. **Multiple F-defects**: Burgess handles these using the linearity axiom (BX11). Given F(A) and F(B) in M, BX11 produces three cases: F(A and B), F(A and F(B)), or F(F(A) and B). In cases 1 and 2, A's witness comes first (or simultaneously); in case 3, B's witness comes first. This determines an ORDER of resolution.

4. **The "step lemma"**: At each step, resolve the earliest-witness defect. The enriched seed {psi, alpha} union g_content(M) is consistent (by enriched_resolving_seed_consistent, which IS proved in our codebase). The successor M' has psi in M' (guaranteed) and alpha in M' (guaranteed). When alpha = F(chi), this preserves F(chi) into M'.

5. **Termination**: Burgess argues that after finitely many steps, all F-defects from the ORIGINAL formula are resolved. The key: the formula set is FINITE (subformula closure), and each defect is resolved at most once before the chain stabilizes.

**Critical difference from our setup**: Burgess works with a FINITE subformula set and builds a FINITE prefix chain. Our sigma_list is finite too, but our chain is infinite (indexed by Nat or Int). The finiteness of sigma_list IS the correct termination measure.

### What Goldblatt (1992) Does

Goldblatt's Section 7 covers the temporal logic of concurrent programs with Until. His construction:

1. Uses a "dovetailing" enumeration to handle infinitely many F-formulas
2. At each step, resolves the next F-defect in the enumeration
3. F-formulas from earlier steps that were not yet resolved are CARRIED FORWARD via the BX11 fold
4. The chain is built over omega (natural numbers)

**Key insight from Goldblatt**: The construction does NOT require all F-defects to be resolved simultaneously. Instead, each defect is visited in round-robin fashion. When visited, BX11 determines whether it can be resolved NOW or must wait. The linearity axiom ensures that after at most |sigma| visits, every defect has been resolved.

**The subtle point Goldblatt handles implicitly**: When resolving defect A at step n, F(B) may be preserved as F(B) (Case 2 of BX11) or lost (Case 3). If lost, B must have been resolved EARLIER (at a step where B had the earliest witness). Goldblatt does not make this argument explicit because, on paper, the BX11 ordering is "obvious." Formalizing this requires exactly the `target_stays_direct_in_fold` theorem.

### Xu (1988) Simplification

Xu simplified Burgess's axiom system but used the same completeness proof strategy. The key axiom (BX11 / temp_linearity) is preserved. No new insight for the chain construction.

### Venema (1993) "Completeness via Completeness"

Venema's approach reduces completeness for Since-Until to completeness for the basic tense logic (with only F, P, G, H). The chain construction is inherited from the simpler logic. This is elegant but does not help with the specific forward_F obstruction -- the reduction still requires F-defect resolution in the base case.

### Verbrugge-de Jongh-Veltman (2004) Constructive Method

The Amsterdam constructive method builds models by EXPLICIT CONSTRUCTION rather than Lindenbaum extension. Key features:

1. Start with a finite set of formulas (subformula closure)
2. Build "atoms" -- maximal consistent subsets of the closure
3. Arrange atoms into a chain by explicit placement
4. F-witnesses are placed at specific future positions during construction
5. No Lindenbaum extension needed -- the model is finite

**Applicability to our problem**: This method would AVOID the BX11 fold entirely. F(psi) in atom A means we place an atom with psi at a later position. Multiple F-obligations are handled by placing witnesses in order.

**Downside**: Would require a complete rewrite of the canonical model construction (currently 2000+ lines across multiple files). The existing infrastructure (g_content, f_carry, enriched seeds, Lindenbaum) would be abandoned. Estimated 5000+ LOC and 100+ hours. NOT recommended for task 93.

## Novel Approaches

### Approach 1: Finite Chain Prefix + Identity Tail (Recommended)

Instead of proving forward_F for an infinite round-robin chain, build a FINITE chain of length |sigma_list| using `ordered_discharge_step`, then extend with an identity tail.

**Termination argument**: Define defect_count(M) = |{chi in sigma_list | F(chi) in M, chi not in M}|. At each step:
- The BX11-earliest defect psi is directly resolved (psi in M', by target_stays_direct_in_fold)
- If psi in M', then psi is no longer a defect in M'
- But wait -- can psi BECOME a defect again? Yes: psi in M' implies F(psi) in M' (by temp_t_future contrapositive... actually NO. temp_t_future is G(phi) -> phi. Its contrapositive is neg(phi) -> F(neg(phi)), not phi -> F(phi). So psi in M' does NOT imply F(psi) in M'.

**CRITICAL REALIZATION**: psi in M' does NOT imply F(psi) in M'. The implication goes the OTHER way: G(phi) -> phi (BX1), so neg(phi) -> neg(G(phi)) = F(neg(phi)). There is NO axiom phi -> F(phi) in BX. The formula psi can be in M' without F(psi) being in M'.

But `no_new_f_defects` (proved) says: if G(neg alpha) in M and g_content(M) subset M', then F(alpha) not in M'. This only shows that ABSENT F-formulas stay absent. It does NOT show that present-but-resolved defects disappear.

The question is: if F(psi) in M and psi in M' (resolved), does F(psi) in M' hold? Not necessarily -- F(psi) might or might not be in M'. But if F(psi) IS in M' AND psi IS in M', that is not a defect (psi is present).

Wait, I need to reconsider the defect definition. A "defect" is F(chi) in M AND chi NOT in M. If chi IS in M, that is NOT a defect even if F(chi) in M. So:
- At step n: M has defect psi (F(psi) in M, psi not in M)
- At step n+1: M' has psi in M'. Whether F(psi) in M' or not, psi is NOT a defect in M'.
- Can NEW defects appear? `no_new_f_defects` says: if F(alpha) NOT in M, then F(alpha) NOT in M' (when g_content(M) subset M'). So the F-obligation set only shrinks (or stays same).
- Combined: resolved defect psi is no longer a defect in M'. New F-obligations cannot appear. So defect count STRICTLY DECREASES.

**This makes the counting argument work!** After at most |sigma_list| steps, defect count reaches 0.

But there is a subtlety: do we need psi to be a defect at step n for the ordered_discharge_step to resolve it? If defects = [] (no defects), the identity step fires. If defects have 1+ elements, we pick the earliest and resolve it. The earliest might not be psi. So we need an argument that psi EVENTUALLY becomes the earliest and gets resolved.

Actually, with defect count strictly decreasing, after at most |sigma_list| steps ALL defects are gone. The terminal MCS T has no defects: for all chi in sigma_list, F(chi) in T implies chi in T. Now:
- F(psi) in chain(n) (the original hypothesis)
- F(psi) persists through the chain (by enriched_fwd_step_preserves: either psi in M' or F(psi) in M')
- At some step, either psi directly appears (done!) or F(psi) reaches the terminal T
- At terminal T: F(psi) in T implies psi in T (defect-free). Done!

**This is the clean argument.** It requires:
1. target_stays_direct_in_fold (PROVED)
2. Defect count strictly decreases (provable from no_new_f_defects + target resolution)
3. Terminal is defect-free (follows from 2)
4. F-preservation through chain (enriched_fwd_step_preserves, PROVED)
5. Defect-free terminal resolves F immediately (by definition)

### Approach 2: Change the Definition of Forward_F Target

Instead of proving forward_F for the existing rr_fwd_chain, DEFINE a new chain (ordered_fwd_chain) and prove forward_F for it. Then show that the rest of the infrastructure (dd_fmcs, dd_bfmcs) can be rebuilt on the new chain. This is the plan v15 approach and is architecturally sound.

### Approach 3: Semantic Bypass (Rejected)

Prove forward_F as a consequence of completeness -- circular and unsound.

### Approach 4: Dense Rationals Model (Rejected)

Use Q instead of Z. Forward_F might be easier because Q is dense. But the codebase is built on Int/Z, and changing would require massive refactoring. Also, density does not help with the core BX11 Case 3 problem.

### Approach 5: Weaken restricted_temporally_coherent (Not Recommended)

Remove forward_F from the definition and show the truth lemma still works. But forward_F IS needed for the truth lemma -- without it, F(psi) true at world w does not guarantee psi true at some future world.

## Strategic Assessment

### Long-Term Viability of the Ordered Discharge Approach

**Robustness**: HIGH. The approach is mathematically sound and follows the standard literature strategy. It does not depend on fragile assumptions about chain behavior. The key insight (target_stays_direct_in_fold) is a clean, self-contained theorem.

**Fragility**: LOW. The approach uses only standard tools (BX11, enriched seeds, Lindenbaum extension, g_content propagation). No novel axioms or definitions are needed upstream.

**Codebase impact**: MODERATE. Approximately 100-200 LOC for the new chain construction and forward_F proof. The existing infrastructure (enriched_fwd_fold, rr_fwd_chain, etc.) is preserved as-is; the new chain is an addition, not a replacement.

**Compilation time**: MINIMAL additional impact. The new definitions are structurally simple (Nat.rec with |sigma_list| iterations).

**Generalizability**: HIGH. The ordered discharge pattern generalizes to:
- Extensions of BX with additional temporal operators (new linearity axioms)
- Dense time logics (sigma_list would use a different enumeration)
- Multi-dimensional temporal logics (with separate F-operators per dimension)

**Publishability**: HIGH. This is the first Lean 4 formalization of temporal logic completeness with Until/Since operators. The ordered discharge approach with target_stays_direct_in_fold is a NOVEL CONTRIBUTION to the formalization literature -- the standard proofs elide this detail, and no previous formalization has confronted it.

### The Critical Realization (New in This Report)

The defect counting argument IS VALID after all. Previous reports (handoff 15, handoff 02) concluded that defect count does not decrease because "phi in M implies F(phi) in M for any MCS M." But this is WRONG:
- The claim was: "temp_t contrapositive gives phi -> F(phi)"
- temp_t is: G(phi) -> phi. Contrapositive: neg(phi) -> neg(G(phi)) = F(neg(phi)).
- This gives neg(phi) -> F(neg(phi)), NOT phi -> F(phi).
- There is NO BX axiom that derives phi -> F(phi).
- So resolving a defect (placing psi in M') does NOT force F(psi) into M'.

**The correct statement about F-obligation stability is**: If F(chi) NOT in M, then F(chi) NOT in M' (by no_new_f_defects via g_content propagation of G(neg chi)). The F-obligation SET {chi | F(chi) in M} can only SHRINK, not grow. And when a defect is resolved (psi placed in M'), even if F(psi) remains in M', it is no longer a DEFECT (because psi IS in M').

Wait, but the handoff says: "F-obligation set D(n) = {chi | F(chi) in chain(n)} is CONSTANT across steps. Reason: phi in M -> F(phi) in M for any MCS M (by contrapositive of temp_t: G(neg phi) -> neg phi)."

Let me recheck: temp_t is G(phi) -> phi. Contrapositive: neg(phi) -> neg(G(phi)). But neg(G(phi)) = F(neg(phi)), not F(phi). So the claim "phi -> F(phi)" is WRONG. The correct statement from temp_t contrapositive is: neg(phi) -> F(neg(phi)).

However, let me check if there's another path: Does BX4 (connect_future: phi -> G(P(phi))) give us phi -> F(phi)?
- BX4: phi -> G(P(phi)). This says if phi now, then at all future times, phi was true in the past. NOT the same as phi -> F(phi).

Does BX8 (refl_intro_until: psi -> (phi U psi)) give us phi -> F(phi)?
- BX8: psi -> (top U psi). By BX10: (top U psi) -> F(psi). So psi -> F(psi). YES!

**BX8 + BX10 gives psi -> F(psi).** So placing psi in M' DOES force F(psi) into M' (since M' is an MCS). The handoff's claim about "F-obligation set is constant" is CORRECT, but the justification should cite BX8 + BX10, not temp_t.

So: psi in M' implies (by BX8) (top U psi) in M', and (by BX10) F(psi) in M'. Therefore F(psi) in M'. The F-obligation set IS stable.

**But this does not kill the defect-count argument.** A defect is F(chi) in M AND chi NOT in M. When chi is resolved (chi in M'), F(chi) is in M' too, but chi IS in M', so it is NOT a defect. The defect-count {chi | F(chi) in M AND chi not in M} CAN decrease when chi gets placed into M'.

So the question is: at the ordered_discharge_step, is the resolved target psi guaranteed to be in M'? YES -- by target_stays_direct_in_fold. And can a NEW defect emerge (some chi' that was not a defect in M but becomes a defect in M')? Only if F(chi') in M' and chi' not in M'. F(chi') in M' requires either:
- F(chi') in M (carried forward) -- but then chi' was already an F-obligation in M
- chi' in M' (new, via BX8 + BX10) -- but then chi' IS in M', not a defect

So `no_new_f_defects` says F-obligations don't grow (from the G-propagation direction), and BX8+BX10 says new members of M' bring their own F with them (but are not defects since they are present).

**Net result**: at each ordered_discharge_step, the defect count |{chi | F(chi) in M, chi not in M}| strictly decreases by at least 1 (the earliest defect is resolved and becomes non-defect; no new defects can emerge because no new F-obligations appear). After at most |sigma_list| steps, defect count = 0.

### The Remaining Concern: Does F(psi) Survive to the Terminal?

The argument needs: F(psi) in chain(n) implies either psi in chain(s) for some n < s, OR F(psi) in chain(terminal).

`enriched_fwd_step_preserves` gives: F(psi) in chain(m) implies psi in chain(m+1) OR F(psi) in chain(m+1). By induction (rr_fwd_chain_F_propagate, PROVED): either psi appears at some intermediate step, or F(psi) reaches the terminal.

At the terminal (defect-free): F(psi) in terminal AND psi in terminal (since no defects). Wait -- "defect-free" means for all chi in sigma_list, F(chi) in terminal implies chi in terminal. So psi in terminal. But we need STRICT future witness (s > n), not s = terminal step. Since the terminal step index is > n (we can make the chain long enough), s > n is satisfied.

Actually, there is a subtlety with reflexive vs strict F. Looking at the semantics: F(phi) = neg(G(neg(phi))). G uses reflexive ordering (t <= s). So F(phi) at t means there exists s >= t with phi at s. The s = t case is included. So if F(psi) in terminal and psi in terminal, the witness s = terminal satisfies F at the terminal. But for the CHAIN, forward_F needs s > n (strict). The terminal step index IS > n as long as the chain has more than 0 steps past n.

OK wait, let me reread the theorem statement:
```
∃ s : Nat, n < s ∧ ψ ∈ (rr_fwd_chain M₀ h₀ sigma_list s).val
```

This needs STRICT n < s. If terminal step is at index T >= |sigma_list|, and n < T, then s = T works. If n >= T (identity tail), then chain(n) = terminal. F(psi) in terminal and psi in terminal by defect-free. s = n+1 works since chain(n+1) = terminal too (identity tail).

**The argument is complete.** The ordered discharge approach with finite prefix + defect-free terminal + identity tail resolves forward_F cleanly.

## Confidence Level

| Component | Confidence | Notes |
|-----------|------------|-------|
| `target_stays_direct_in_fold` | 100% | Already proved, sorry-free |
| `rr_fwd_chain_forward_F` (sorry #1) | 90% | Defect counting argument is sound; main risk is Lean formalization overhead |
| `dd_fmcs_forward_F` t >= 0 (sorry #2 partial) | 95% | Direct delegation to forward_F |
| `dd_fmcs_forward_F` t < 0 (sorry #2 remainder) | 60% | Requires backward chain F-propagation to M_0 |
| `dd_fmcs_backward_P` (sorry #3) | 80% | Symmetric to forward_F; needs h_content version |
| `dd_bfmcs_restricted_tc` (sorry #4) | 85% | Follows from forward_F + backward_P |
| `dd_bfmcs_restricted_fuc` (sorry #6) | 75% | Forward Until coherence via BX9/BX10 |
| `dd_bfmcs_restricted_buc` (sorry #5) | 45% | Independent, no known syntactic proof |
| Overall (5 of 6 sorries) | 85% | Solid path for all except backward Until |
| Overall (6 of 6 sorries) | 40% | backward Until remains high-risk |

## Recommendations

1. **Proceed with Plan v15** using the ordered discharge approach. The mathematical foundations are solid.

2. **Key implementation insight**: The defect-count argument IS the correct termination measure. Previous handoffs incorrectly claimed "phi -> F(phi) by temp_t contrapositive" -- the correct derivation is via BX8 + BX10, and while F-obligations are stable, DEFECTS (F(chi) in M AND chi NOT in M) strictly decrease.

3. **Prioritize forward_F (sorry #1)** -- all other sorries depend on it directly or indirectly.

4. **Spawn task 96 for backward Until** if Phase 6 is blocked after 2 hours.

5. **Publication opportunity**: This is the FIRST Lean 4 formalization of temporal logic completeness with Until/Since. The target_stays_direct_in_fold theorem and the ordered discharge chain construction are novel contributions that could be submitted to ITP or CPP.

## References

- Burgess, J.P. (1982) "Axioms for Tense Logic I: 'Since' and 'Until'" -- [ResearchGate](https://www.researchgate.net/publication/38355634_Axioms_for_tense_logic_I_Since''_and_until'')
- Burgess, J.P. (1984) "Basic Tense Logic" in Handbook of Philosophical Logic -- [Springer](https://link.springer.com/chapter/10.1007/978-94-009-6259-0_2)
- Goldblatt, R. (1992) "Logics of Time and Computation" 2nd ed. -- [Stanford CSLI](https://web.stanford.edu/group/cslipublications/cslipublications/site/0937073946.shtml)
- Xu, M. (1988) "On some U, S-tense logics" -- [PhilPapers](https://philpapers.org/rec/XUOSU)
- Venema, Y. (1993) "Completeness via Completeness: Since and Until" -- [UvA](https://staff.fnwi.uva.nl/y.venema/papers/vene-comp93.pdf)
- Verbrugge, R., de Jongh, D., Veltman, F. (2004) "Completeness by Construction for Tense Logics of Linear Time" -- [ILLC PDF](https://festschriften.illc.uva.nl/D65/verbrugge.pdf)
- FormalizedFormalLogic/Foundation (Lean 4) -- [GitHub](https://github.com/FormalizedFormalLogic/Foundation), [Book](https://formalizedformallogic.github.io/Book/)
- LeanearTemporalLogic (Lean 4 LTL) -- [GitHub](https://github.com/mrigankpawagi/LeanearTemporalLogic)
- Lentil (TLA in Lean 4) -- [GitHub](https://github.com/verse-lab/Lentil)
- Stanford Encyclopedia of Philosophy, Temporal Logic -- [SEP](https://plato.stanford.edu/entries/logic-temporal/)
