# Research Report: Task #48 - Teammate B Alternative Approaches

**Task**: 48 - prove_succ_chain_fam_bounded_f_depth
**Angle**: Alternative Approaches and Prior Art
**Date**: 2026-03-23
**Session**: sess_1774293750_5cd3b5
**Researcher**: Teammate B (math-research-agent)

---

## Executive Summary

The blocker in `p_step_blocking_for_deferral_restricted` arises because the theorem attempts to prove `p_step_blocking_formulas u <= u` for a `DeferralRestrictedMCS u`, but `p_step_blocking_formulas` ranges over ALL formulas, including those where `P(psi)` is not in `deferralClosure`. For such formulas, `H(neg psi)` is provably NOT in `deferralClosure`, making the inclusion false.

After analyzing four alternative approaches and reviewing prior art from modal logic completeness literature, I recommend **Alternative 2: Restricted P-step Blocking Definition** as the cleanest solution. This approach defines a filtered version of `p_step_blocking_formulas` that only considers formulas within the closure, avoiding the problematic case entirely.

---

## The Core Mathematical Problem

### Why The Current Theorem Fails

The sorry occurs at RestrictedMCS.lean:1124 in the else branch of a by_cases on `P(psi) in deferralClosure phi`.

**The Analysis in Code Comments (lines 1060-1119)**:

1. If `P(psi) NOT in deferralClosure`, then:
   - `P(psi) = neg(H(neg psi))` is NOT in closureWithNeg (since it would need to be a subformula or negation thereof)
   - Therefore `H(neg psi)` is NOT in subformulaClosure
   - And `H(neg psi)` is NOT in closureWithNeg (structural mismatch: all_past vs imp)
   - And `H(neg psi)` is NOT in deferralDisjunctionSet or backwardDeferralSet (those are imp formulas)
   - So `H(neg psi) NOT in deferralClosure phi`

2. Since `u <= deferralClosure phi`, we have `H(neg psi) NOT in u`

3. But `H(neg psi) in p_step_blocking_formulas u` by definition (when `P(psi) NOT in u` and `psi NOT in u`)

4. Therefore `p_step_blocking_formulas u` contains an element NOT in `u` -- the subset relation FAILS.

**Conclusion**: The theorem `p_step_blocking_for_deferral_restricted` is FALSE as stated for the case where blocking formulas escape the closure.

---

## Alternative Approaches Considered

### Alternative 1: Extend the Deferral Closure

**Idea**: Define a larger closure that includes all possible blocking formulas.

**Definition**:
```lean
def blockingExtendedClosure (phi : Formula) : Finset Formula :=
  deferralClosure phi ∪
  {H(neg psi) | P(psi) NOT in deferralClosure phi AND psi NOT in deferralClosure phi}
```

**Analysis**:
- This set is infinite in general (there are infinitely many psi where P(psi) is outside the closure)
- Even if we restrict to "formulas that could appear in the chain construction," we need to characterize that set, which is non-trivial
- The resulting closure would no longer bound F/P-nesting depth unless we prove the blocking formulas added have bounded depth

**Assessment**: REJECTED - Creates more problems than it solves. The closure becomes infinite or hard to characterize.

---

### Alternative 2: Restricted P-Step Blocking Definition (RECOMMENDED)

**Idea**: Redefine `p_step_blocking_formulas` to only include blocking formulas for `psi` where `P(psi)` is in the closure.

**Definition**:
```lean
def p_step_blocking_formulas_in_closure (phi : Formula) (u : Set Formula) : Set Formula :=
  {psi | exists chi : Formula,
         chi in subformulaClosure phi AND
         Formula.some_past chi NOT in u AND
         chi NOT in u AND
         psi = Formula.all_past (Formula.neg chi)}
```

**Why This Works**:
1. For `chi in subformulaClosure phi`:
   - `P(chi) in closureWithNeg phi` (since P(chi) = neg(H(neg chi)) and H(neg chi) is a subformula when P(chi) is)
   - Wait, this needs verification: `P(chi) in closureWithNeg` iff `P(chi) in subformulaClosure` OR `P(chi) = neg(g)` for some `g in subformulaClosure`
   - Actually: if `chi in subformulaClosure phi`, then `P(chi)` may or may not be in closureWithNeg

**Corrected Analysis**: The restriction should be to formulas where `P(chi) in deferralClosure phi`:

```lean
def p_step_blocking_formulas_closure_aware (phi : Formula) (u : Set Formula) : Set Formula :=
  {psi | exists chi : Formula,
         Formula.some_past chi in deferralClosure phi AND
         Formula.some_past chi NOT in u AND
         chi NOT in u AND
         psi = Formula.all_past (Formula.neg chi)}
```

**Why This Now Works**:
1. If `P(chi) in deferralClosure phi`, then by the existing proof (lines 959-1059 of RestrictedMCS.lean), we have `H(neg chi) in u` via negation completeness and double negation elimination.

2. For `P(chi) NOT in deferralClosure phi`, we simply don't include `H(neg chi)` in the blocking set.

**Impact on P-Step Property**:
The P-step property needs: `p_content(successor) <= u UNION p_content(u)`.

For any `P(chi) in successor`:
- Either `chi in u` (then `P(chi) in p_content(u)`)
- Or `chi NOT in u` and `P(chi) in u` (then `P(chi) in u`)
- Or `chi NOT in u` and `P(chi) NOT in u` (then blocking formula should prevent this)

For the blocking to work:
- If `P(chi) in deferralClosure phi`: blocking formula `H(neg chi)` is in seed, prevents `P(chi)` in successor
- If `P(chi) NOT in deferralClosure phi`: `P(chi)` cannot be in successor anyway since successor <= deferralClosure

**Conclusion**: The restricted definition is sufficient because formulas outside the closure cannot appear in the successor anyway.

**Assessment**: RECOMMENDED - Minimal change, mathematically correct.

---

### Alternative 3: Restructure Chain to Avoid P-Step Blocking Entirely

**Idea**: Use a different proof architecture that doesn't require the p_step_blocking property.

**Literature Pattern** (from Venema's "Temporal Logic" chapter):
Standard tense logic completeness uses filtration rather than direct chain construction:
1. Build unrestricted canonical model
2. Define equivalence: `u ~ v` iff they agree on subformulas of target
3. Take quotient model
4. P-step follows from quotient structure, not blocking formulas

**Analysis**:
- This codebase already has a filtration module (`FMP/Filtration.lean`)
- However, the current completeness proof uses the Succ-chain approach, not filtration
- Switching proof architectures would require major refactoring

**Assessment**: VIABLE but high effort - Would require rearchitecting the completeness proof.

---

### Alternative 4: Prove Chain Never Needs Non-Closure Blocking

**Idea**: Instead of changing the definitions, prove that for the specific chain construction used in completeness, the problematic case never arises.

**Argument Sketch**:
1. The chain starts from a seed `{neg phi}` for target formula `phi`
2. Each successor is built from formulas derivable from the current MCS
3. Any `P(psi)` that appears must come from some derivation
4. Derivations in the proof system preserve subformula structure
5. Therefore any `P(psi)` checked for blocking has `psi` derived from closure formulas

**Analysis**:
- This is essentially the hypothesis `h_seed_in_closure` in the blocker analysis plan (line 176-177 of plans/03_restricted-p-step.md)
- Proving this requires showing that derivations don't introduce new temporal operators beyond the closure
- This is non-trivial and may require deep analysis of the proof system

**Assessment**: VIABLE but requires significant new lemmas about derivation structure.

---

## Prior Art from Modal Logic Literature

### Venema's Approach (Temporal Logic, Ch. 10)

Venema uses the **standard filtration technique**:
- Define equivalence classes on canonical model worlds
- Each class is characterized by a subset of subformulas of the target
- Finite quotient model has bounded modal depth by construction

The key insight: never attempt to prove properties for arbitrary MCS; instead, work within the subformula-closed fragment from the start.

### Goldblatt's Approach (Logics of Time and Computation)

Goldblatt uses **bounded canonical models**:
- Define MCS restricted to closure sets
- Prove Lindenbaum lemma for closure-restricted consistency
- Chain construction stays within closure by design

This aligns with Alternative 2: restrict definitions to closure formulas rather than proving closure preservation.

### Blackburn, de Rijke, Venema (Modal Logic, Ch. 2.3)

The BdRV text emphasizes:
- Filtration is the standard technique for FMP
- For completeness without FMP, use "generated submodels" that are closure-bounded
- The subformula property is essential: all proofs ultimately rely on finite subformula closure

### Application to Current Blocker

The literature universally supports **working within the closure from the start** rather than proving closure preservation after the fact. Alternative 2 follows this pattern.

---

## Comparison with Primary Approach (Teammate A Analysis)

Teammate A's blocker analysis recommends Option A (prove the theorem with restricted formulas). This aligns with Alternative 2 here.

**Key Difference in Framing**:
- Teammate A frames it as "adding a hypothesis that blocking formulas are in closure"
- This analysis frames it as "redefining p_step_blocking_formulas to only include closure formulas"

Both approaches are mathematically equivalent. The definitional change (Alternative 2) is cleaner because:
1. It makes the restriction explicit in the type
2. It avoids carrying extra hypotheses through the proof
3. It matches the literature pattern of working within closure from the start

---

## Recommended Alternative: Restricted P-Step Blocking

### Implementation Steps

1. **Define restricted blocking set**:
```lean
def p_step_blocking_formulas_restricted (phi : Formula) (u : Set Formula) : Set Formula :=
  {psi | exists chi : Formula,
         Formula.some_past chi in deferralClosure phi AND
         Formula.some_past chi NOT in u AND
         chi NOT in u AND
         psi = Formula.all_past (Formula.neg chi)}
```

2. **Prove restricted blocking subset of u**:
```lean
theorem p_step_blocking_restricted_subset (phi : Formula) (u : Set Formula)
    (h_drm : DeferralRestrictedMCS phi u) :
    p_step_blocking_formulas_restricted phi u <= u
```
This follows directly from the existing proof in lines 959-1059 (the first branch of the by_cases).

3. **Define restricted constrained successor seed**:
```lean
def constrained_successor_seed_restricted (phi : Formula) (u : Set Formula) : Set Formula :=
  g_content u ∪ deferralDisjunctions u ∪ p_step_blocking_formulas_restricted phi u
```

4. **Prove restricted seed consistency**:
All three components are subsets of `u` (with the restricted blocking, this is now provable).

5. **Prove restricted seed gives P-step property**:
Show that successor built from restricted seed satisfies P-step.
Key argument: formulas outside closure cannot appear in successor, so restricting blocking doesn't lose anything.

6. **Update chain construction**:
Use `constrained_successor_seed_restricted` instead of `constrained_successor_seed`.

### Trade-offs

| Aspect | Restricted Definition | Current + Hypothesis |
|--------|----------------------|----------------------|
| Type signature | Cleaner (no extra hypothesis) | Requires threading hypothesis |
| Proof complexity | Simpler (case split eliminated) | Similar after adding hypothesis |
| Alignment with literature | Better (closure-bounded pattern) | Partial |
| Refactoring scope | Moderate (seed definition + callers) | Moderate (add hypothesis to callers) |

---

## Confidence Level: High

**Mathematical Soundness**: The restricted blocking definition is correct because:
1. Formulas outside `deferralClosure` cannot appear in any `DeferralRestrictedMCS`
2. Therefore blocking those formulas is unnecessary
3. The P-step property is preserved because the successor stays within `deferralClosure`

**Implementation Feasibility**: The change is localized to:
1. `p_step_blocking_formulas` definition in SuccExistence.lean
2. `constrained_successor_seed` definition and callers
3. The sorry at RestrictedMCS.lean:1124 becomes unreachable (removed with the restricted definition)

**Risk Assessment**: Low - The approach follows established patterns from modal logic literature.

---

## References

- [Temporal Logic - Yde Venema](https://staff.science.uva.nl/y.venema/papers/TempLog.pdf) - Standard filtration technique
- [Modal Logic - Blackburn, de Rijke, Venema](https://www.cambridge.org/core/books/abs/modal-logic/completeness/7CF04A550F7C253C42C16007CB7A5554) - Subformula closure approach
- [Temporal Logic (Stanford Encyclopedia)](https://plato.stanford.edu/entries/logic-temporal/) - Overview of tense logic semantics
- [Modal Logics with Transitive Closure: Completeness, Decidability, Filtration](http://www.aiml.net/volumes/volume13/Kikot-Shapirovsky-Zolin.pdf) - Advanced filtration techniques
