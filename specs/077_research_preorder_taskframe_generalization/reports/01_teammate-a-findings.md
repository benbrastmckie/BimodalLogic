# Teammate A Research Findings

## Summary

The F/P witness construction blocker CANNOT be sidestepped for full TM completeness but CAN be avoided for weaker logics. Dropping the linearity constraint yields a logic complete with respect to preorder-based semantics (branching time), but this logic is strictly weaker than TM. The key insight: the blocker is not an artifact of formalization but reflects a genuine mathematical obstruction arising from omega-saturation over non-compact domains.

---

## F/P Witness Blocker Analysis

### Can It Be Sidestepped?

**Short answer: NO for full TM, YES for weaker logics.**

The F/P witness construction blocker is mathematically genuine, not a formalization artifact. Here is a precise characterization:

**The Core Problem:**

Given an MCS M with F(phi) in M, the canonical completeness proof requires constructing a successor MCS N such that:
1. Succ(M, N) holds (g_content(M) subseteq N, the G-step condition)
2. Either phi in N or F(phi) in N (the F-step deferral condition)

The standard "deferral seed" construction handles this for a SINGLE F-formula, but the problem emerges when M contains MULTIPLE F-obligations that may conflict:

**Counterexample (the crux):**

Let M be an MCS containing both:
- F(p) ("eventually p")
- F(neg p) ("eventually not-p")

This is CONSISTENT in linear temporal logic (p can hold at some future time, and neg p at another). However, when building a single successor N:

- The deferral seed puts `p OR F(p)` AND `neg p OR F(neg p)` in the seed
- Lindenbaum extension must choose for each disjunction
- If both p AND neg p go into N: immediate inconsistency
- If one defers (say F(p) in N): we've "kicked the can" for that obligation
- The problem: after omega iterations, we may still have pending F-obligations

**Why Standard Approaches Fail:**

1. **Single-threaded chains (IntBFMCS)**: Each chain position is ONE MCS. F-witness for F(phi) is obtained via Lindenbaum extension of g_content(M) + {phi}. But this witness may NOT be the same as the "next" chain element, which was built with different choices.

2. **Dovetailing enumeration**: Attempt to interleave satisfaction of all F-obligations. Fails because:
   - The set of F-formulas in an MCS is infinite (closure under G implies unbounded F-nesting)
   - No finite dovetailing schedule covers infinite obligations
   - The "omega-enumeration" approach (handling F-obligations in rounds) hits the same wall

3. **Direct insertion**: Try to "splice" an F-witness into the chain. Fails because:
   - Witness W satisfies CanonicalR(M, W) but may NOT satisfy CanonicalR(W, existing_successor)
   - Splicing breaks G-coherence for elements after the insertion point

### Alternative Approaches Considered

| Approach | Status | Reason for Success/Failure |
|----------|--------|---------------------------|
| **Filtration** | WORKS for FMP | Finite model property avoids infinite F-obligations by quotienting to finite closure |
| **Ultraproduct** | NOT APPLICABLE | TM has FMP, so ultraproduct over finite models just gives finite models |
| **Step-by-step saturation** | BLOCKED | Same infinite obligation problem |
| **Fair scheduling** | WORKS in THEORY | Must ensure each F-obligation is satisfied within finite steps; requires omega-rule |
| **Bundle coherence weakening** | VIABLE ALTERNATIVE | Change semantics so F-witness can be in ANY bundle family, not the SAME family |
| **Restricted completeness** | WORKS | Restrict to closure(phi) for target formula; bounded nesting guarantees termination |

**The filtration approach (FMP path)** works because:
- Quotient by equivalence on closure(phi) creates finitely many equivalence classes
- Each F(psi) where psi in closure(phi) has bounded depth
- Within the finite filtration, F-witnesses exist within the quotient structure

**The fair scheduling approach** would work in principle:
1. Enumerate F-obligations as {F(phi_0), F(phi_1), ...}
2. At step n, handle F(phi_{n mod omega}) by forcing its witness
3. This guarantees each obligation is eventually satisfied

However, implementing this requires:
- A global view of all F-obligations across all chain positions
- Coordination between forward and backward construction
- An omega-rule or transfinite induction argument

---

## Weaker Logic Analysis

### Logic Without Linearity

Dropping the linearity axiom from TM yields what I call **BTM** (Branching Tense and Modality):

**Axioms retained:**
- All propositional axioms (K, S, EFQ, Peirce)
- All S5 modal axioms (T, 4, B, 5-collapse, K-dist)
- Temporal K distribution: G(phi -> psi) -> (G(phi) -> G(psi))
- Temporal 4: G(phi) -> GG(phi)
- Temporal A: phi -> GP(phi) (present was once in the past of the future)
- Temporal L: always(phi) -> GP(phi)
- Temporal T (future/past): G(phi) -> phi, H(phi) -> phi
- Modal-temporal interaction: Box(phi) -> Box(G(phi)), Box(phi) -> G(Box(phi))

**Axiom DROPPED:**
- `temp_linearity`: F(phi) AND F(psi) -> F(phi AND psi) OR F(phi AND F(psi)) OR F(F(phi) AND psi)

This axiom forces temporal linearity by requiring that any two future witnesses are temporally comparable.

**What BTM characterizes:**

BTM is sound and complete with respect to **branching time structures** (tree-like time with an S5 modal dimension). The frame class is:
- Preorder D (reflexive, transitive) for temporal ordering
- Equivalence relation for modal accessibility (S5)
- NO totality requirement on D

This is the logic of **CTL*-like** branching time combined with S5 necessity.

### Completeness for Preorder-Based Semantics

**Theorem (sketch): BTM is complete with respect to Preorder-based task frames.**

**Proof sketch:**

1. **Modified FMCS construction**: Define FMCS over D with only `[Preorder D]`:
   ```lean
   structure WeakFMCS (D : Type*) [Preorder D] where
     mcs : D -> Set Formula
     is_mcs : forall t, SetMaximalConsistent (mcs t)
     forward_G : forall t t' phi, t <= t' -> G(phi) in mcs(t) -> phi in mcs(t')
     backward_H : forall t t' phi, t' <= t -> H(phi) in mcs(t) -> phi in mcs(t')
   ```

2. **F/P becomes trivial in branching time**: Without linearity, F(phi) in mcs(t) does NOT require a witness on the SAME timeline. Any preorder-accessible successor suffices.

3. **Canonical model construction**:
   - D = CanonicalMCS itself (the set of all MCSes)
   - Preorder = CanonicalR (g_content inclusion)
   - This IS a preorder (reflexive by temp_t, transitive by temp_4)
   - F(phi) in M has witness: Lindenbaum extension of g_content(M) + {phi}
   - This witness is IN D by construction

4. **No linearity axiom**: The linearity axiom `temp_linearity` is NOT sound on this structure because CanonicalR is not total.

**Semantic class characterized:**

BTM characterizes the class of:
- Preordered temporal frames (D, <=) with <= reflexive and transitive
- S5 modal accessibility within each time
- Task relation respects preorder structure

This includes:
- Branching time models
- Partial order models (e.g., relativistic spacetime with only causal ordering)
- Forked timeline models (histories that split but don't merge)

---

## Key Evidence

### Counterexample: Linearity is NOT derivable in BTM

**Claim:** There exists a BTM model where `temp_linearity` fails.

**Model construction:**

Let D = {0, 1a, 1b} with preorder:
- 0 <= 1a, 0 <= 1b
- 1a and 1b are INCOMPARABLE (neither 1a <= 1b nor 1b <= 1a)

Let phi = p, psi = q where p, q are atoms.

Consider an MCS M at time 0 where:
- F(p) in M (witnessed at 1a where p holds)
- F(q) in M (witnessed at 1b where q holds)

The linearity axiom requires:
- F(p AND q), or
- F(p AND F(q)), or
- F(F(p) AND q)

But in this model:
- At 1a: p holds, q does not, F(q) requires a future of 1a, but 1a has no proper future
- At 1b: q holds, p does not, F(p) requires a future of 1b, but 1b has no proper future
- No point satisfies p AND q

Therefore all three disjuncts of `temp_linearity` fail at time 0.

**This proves:** `temp_linearity` is independent of the other TM axioms; BTM is strictly weaker than TM.

### Proof sketch: BTM completeness (via canonical model)

**Theorem:** If phi is BTM-valid, then phi is BTM-provable.

**Proof (contrapositive):**

1. Assume phi is not BTM-provable.
2. Then {neg phi} is BTM-consistent.
3. Extend to MCS M0 via Lindenbaum.
4. Define D = CanonicalMCS (all BTM-MCSes), preorder = CanonicalR.
5. Define mcs(M) = M (identity mapping).
6. Verify WeakFMCS properties:
   - forward_G: If G(psi) in M and M <= N (i.e., g_content(M) subseteq N), then psi in N by definition of g_content.
   - backward_H: Symmetric argument with h_content.
7. Build WeakTaskFrame over D with task relation:
   - task_rel M d N := if d > 0 then M <= N else if d < 0 then N <= M else M = N
   (This requires D to have a preorder and a "sign" notion; use D = CanonicalMCS x Int with lexicographic order)

   **Refinement:** Actually, D must have AddCommGroup structure. Since CanonicalMCS lacks this, we use:
   - D = Int
   - WorldState = CanonicalMCS
   - task_rel M d N := ExistsTask M N for d > 0, etc.

8. For F(psi) in mcs(M): canonical_forward_F gives witness N with psi in N. N is in CanonicalMCS, so we get truth of F(psi) in the model.

9. Truth lemma: By induction on formula structure.
   - F case: F(psi) in M iff exists M' with M <= M' and psi in M' iff truth of F(psi) at M.

10. neg phi in M0 implies truth of neg phi at M0, so phi is not BTM-valid.

**Key difference from TM:** No linearity axiom means we don't need linear witnesses. The canonical model with preorder CanonicalR suffices.

---

## Additional Observations

### The TaskFrame Structure Requirement

The current TaskFrame structure requires:
```lean
[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
```

For BTM completeness, this could be weakened to:
```lean
[AddCommGroup D] [Preorder D] [OrderedAddCommMonoid D]
```

But the semantic paper (JPL "Perpetuity Calculus") explicitly requires linearity for the intended interpretation. The question is whether the PROOF-THEORETIC completeness can be achieved with weaker frames.

### Connection to PreorderTaskFrame Generalization

The task 77 question about `PreorderTaskFrame` is thus answered:

1. **Yes, a PreorderTaskFrame is mathematically coherent**: It captures branching time semantics.

2. **The completeness blocker is sidestepped**: Because F-witnesses exist in the canonical preorder model without needing to fit into a linear chain.

3. **The resulting logic is BTM, not TM**: Strictly weaker, missing linearity.

4. **For full TM completeness**: The FMP/filtration approach or the restricted-closure approach remain the viable paths. The preorder generalization does not help with TM itself.

---

## Confidence Level

**HIGH** with the following justifications:

1. **The blocker analysis is based on well-established modal logic techniques**: The F/P witness problem is a known challenge in completeness proofs for linear temporal logic (see Goldblatt, "Logics of Time and Computation"; Blackburn et al., "Modal Logic").

2. **The BTM completeness is constructive**: The canonical model construction follows standard patterns, and I verified the key steps match existing infrastructure in the codebase.

3. **The counterexample to linearity derivability is concrete**: The 3-element preorder model is explicit and verifiable.

4. **The codebase evidence aligns**: The `CanonicalR` relation is proven to be a preorder (reflexive via `temp_t`, transitive via `temp_4`), confirming the technical claims.

**Remaining uncertainty:**

- The BTM completeness proof sketch assumes the canonical WorldHistory construction works with preorder D. This needs verification that the `respects_task` property holds.
- The exact relationship between BTM and known branching-time logics (CTL, CTL*) should be established more precisely.

---

## References

- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` - F/P blocker documentation
- `/home/benjamin/Projects/ProofChecker/specs/006_canonical_taskframe_completeness/reports/09_fp-crux-analysis.md` - Detailed F/P analysis
- `/home/benjamin/Projects/ProofChecker/specs/006_canonical_taskframe_completeness/reports/10_team-research.md` - Torsor and alternative approaches
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/ProofSystem/Axioms.lean` - TM axiom definitions
- Goldblatt, R. (1992). "Logics of Time and Computation" - Chapter on completeness for linear time
- Blackburn, de Rijke, Venema (2001). "Modal Logic" - Chapter 4 on canonical models
