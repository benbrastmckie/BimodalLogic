# Teammate B: Alternatives and Risk Analysis

## Summary

Option C (Restricted Construction Path) has significant gaps and risks. The single-formula restriction limits what can be proven, there are existing sorries in the chain construction, and the connection from `RestrictedTemporallyCoherentFamily` to `valid_over Int phi` requires non-trivial infrastructure that mirrors the existing bundle canonical construction. While Option C is still the most tractable path, Task 65's deliverables must be carefully scoped to avoid hidden assumptions.

## Key Findings

### 1. Restriction Limitation Analysis

**Can single-formula restriction suffice for proving `valid_over Int phi`?**

The answer is **yes, but with caveats**:

- `RestrictedTemporallyCoherentFamily phi` provides F/P coherence for formulas in `deferralClosure phi` (lines 4191-4202 of SuccChainFMCS.lean)
- `deferralClosure phi` is a finite set containing `subformulaClosure phi` plus deferral disjunctions (see SubformulaClosure.lean:649)
- The restricted truth lemma (RestrictedTruthLemma.lean:268-280) establishes equivalence **only for formulas in `subformulaClosure phi`**

**Critical insight**: The completeness argument is contrapositive:
1. If phi not provable, neg(phi) consistent
2. Build restricted chain from neg(phi)
3. neg(phi) in restricted chain at time 0
4. Need: restricted chain evaluates to false under valid_over

**The gap**: We need `valid_over Int phi` to apply to the restricted model. This means constructing a TaskModel where `truth_at M Omega tau t phi` is well-defined and connected to chain membership.

**Restriction suffices because**: The contrapositive only needs to establish `not(phi true at time 0 in restricted model)`. Since phi and neg(phi) are both in subformulaClosure(phi) (by reflexivity for phi, by closure_neg for neg(phi)), the restricted truth lemma covers exactly what we need.

### 2. Modal Coherence Gap

**Does the restricted construction preserve Box-class coherence?**

The restricted construction operates on a SINGLE chain, not a bundle of families. Examining the code:

```lean
-- SuccChainFMCS.lean:4191-4202
structure RestrictedTemporallyCoherentFamily (phi : Formula) where
  seed : DeferralRestrictedSerialMCS phi
  forward_F : forall n psi, F(psi) in chain(n) -> exists m > n, psi in chain(m)
  backward_P : forall n psi, P(psi) in chain(n) -> exists m < n, psi in chain(m)
```

**Key observation**: The restricted family has **no modal coherence property**. It does not promise:
- `Box(psi) in chain(n) -> psi in chain(n')` for other chains
- Any relationship with other box-class families

**Why this is actually OK**: The restricted construction is for a SINGLE formula phi. The canonical model built from it will have a SINGLE family in its bundle. The Box case of the truth lemma requires:
- Forward: `Box(psi) in chain(n) -> forall sigma in Omega, psi true at sigma(n)`
- Backward: `forall sigma in Omega, psi true at sigma(n) -> Box(psi) in chain(n)`

If Omega contains only histories from the single restricted family (and their shifts), Box-class coherence becomes **reflexive** - we only need to show psi in the same family at shifted times.

**Risk**: This requires careful construction of RestrictedOmega. It cannot be the full ShiftClosedCanonicalOmega from the bundle construction.

### 3. Potential Failure Modes

**Existing sorries in the chain**:

From SuccChainFMCS.lean, I found these sorries on the restricted path:
- Line 3420: `constrained_predecessor_restricted_f_step_forward` has sorry for "chi not in u, F(chi) not in u" case
- Lines 3973, 4154: Termination proofs use sorry

From RestrictedTruthLemma.lean:
- Lines 106, 115, 135: G/H propagation lemmas have sorries

**Edge cases**:

1. **Empty Omega degenerate case**: If the restricted construction produces an empty set of histories, validity becomes vacuously true. The construction guarantees at least one history (the seed chain), so this is not a concern.

2. **Degenerate formulas**: For `phi = bot`, `neg(phi) = neg(bot) = top` is provable, so the chain cannot be built (consistent extension fails). This is correct behavior.

3. **Nested modalities**: Consider `phi = Box(F(p))`. The deferralClosure includes:
   - Box(F(p)), F(p), p, neg(Box(F(p))), neg(F(p)), neg(p)
   - F(p) or F(F(p)) (deferral disjunction)

   The restricted chain must find F-witnesses for F(p). By construction, `forward_F` guarantees this.

4. **Cross-chain witnesses**: The restricted construction finds F-witnesses **within the same chain**. This is exactly what family-level coherence requires, and what the restricted construction provides.

### 4. Alternative Approaches

**Option B (Bundle-Level Truth Lemma)** remains viable:

The analysis states "viable but high effort (8-12 hours)". Key insight: if Omega spans ALL families, F-witnesses being in different families is acceptable because:
- Omega contains histories from all families
- Box quantifies over all histories in Omega
- F quantifies within a single history

Option B would require:
1. Proving bundle-level temporal coherence suffices for the truth lemma
2. Constructing Omega from all families
3. Connecting to valid_over

**Option D (Direct sorry elimination)** - alternative approach:

Instead of building full TaskModel infrastructure, directly prove the 3 sorries using the algebraic completeness:

```lean
-- bundle_completeness_contradiction already exists (sorry-free)
theorem bundle_completeness_contradiction (phi : Formula) (h_cons : consistent (neg phi)) :
    not (forall M, SetMaximalConsistent M -> phi in M)
```

The gap is connecting this to `valid_over Int phi`. One could prove:
```lean
valid_over Int phi -> forall M : SetMaximalConsistent, phi in M
```
directly, without building explicit TaskModel infrastructure.

### 5. Task Dependency Risks

**What Task 66 needs from Task 65**:

Task 66 scope (from TODO.md):
> Connect restricted completeness path to the 3 target sorries

The 3 target sorries are:
1. `bundle_validity_implies_provability` (line 186-214) - needs valid_over -> Nonempty derivation
2. `dense_completeness_fc` (line 115-120) - needs DenseCompletenessStatement
3. `discrete_completeness_fc` (line 158-163) - needs DiscreteCompletenessStatement

**Hidden assumptions**:

1. Task 65 must provide `RestrictedOmega` that is `ShiftClosed` (required by `valid_over`)
2. Task 65 must provide `restricted_truth_lemma_semantic` connecting chain membership to `truth_at`
3. Task 65 must handle the Box case properly with the single-family Omega

**Potential failure if Task 65 succeeds but Task 66 fails**:

If RestrictedTaskModel is constructed but doesn't satisfy `valid_over Int phi -> phi in chain(0)`, Task 66 cannot complete the contrapositive.

The key lemma needed:
```lean
theorem restricted_validity_gives_seed_membership (phi : Formula)
    (tc_fam : RestrictedTemporallyCoherentFamily phi)
    (h_valid : valid_over Int phi) :
    phi in restricted_succ_chain_fam phi tc_fam.seed 0
```

### 6. Counterexample Search

**Attempted counterexamples**:

1. **phi = Box(F(p))**: Mixed modal-temporal
   - neg(phi) = Diamond(G(neg(p)))
   - Build restricted chain for neg(phi)
   - Chain must contain Diamond(G(neg(p))) at time 0
   - By MCS maximality in the extended chain, either Box(F(p)) or Diamond(G(neg(p))) at each time
   - The restricted construction builds a DeferralRestrictedMCS containing neg(phi)
   - F-witnesses exist within deferralClosure
   - No counterexample found

2. **phi = F(Box(p))**: Temporal-modal
   - neg(phi) = G(Diamond(neg(p)))
   - Restricted chain built from neg(phi)
   - G(Diamond(neg(p))) at time 0 propagates forward via temp_4 axiom
   - Diamond(neg(p)) appears at all future times (via MCS maximality after Lindenbaum extension)
   - No counterexample found

3. **phi with deep F-nesting**: phi = F(F(F(F(p))))
   - deferralClosure includes all F^n(p) for n <= 4
   - Restricted construction handles bounded F-nesting by design
   - forward_F property guarantees witnesses
   - No counterexample found

**Conclusion**: No counterexamples found. The restricted construction appears mathematically sound for the completeness argument.

## Risk Assessment

**Overall approach viability: MEDIUM**

Justification:
- The mathematical approach is sound
- Existing sorries in the chain construction are concerning (3 in RestrictedTruthLemma, 3+ in SuccChainFMCS)
- The infrastructure gap (restricted chain -> TaskModel -> valid_over) is well-defined but requires careful implementation
- No blocking theoretical obstacles identified

## Critical Questions for Teammate A

1. **Regarding RestrictedOmega construction**: How exactly will RestrictedOmega be defined? Will it be `{time_shift (to_history restricted_fam) delta | delta : Int}` or something more complex?

2. **Regarding Box case in truth lemma**: The restricted construction has a single family. How does the Box case work when Omega only contains histories from one family?

3. **Regarding the 3 sorries in RestrictedTruthLemma.lean**: Are these blocking for the completeness proof, or can they be worked around?

4. **Regarding termination sorries**: The restricted chain construction has termination sorries (lines 3973, 4154). Do these affect soundness of the completeness argument?

5. **Regarding Lindenbaum extension**: The restricted truth lemma (line 268-280) works with Lindenbaum-extended chains. Does the Task 65 plan account for this?

## Recommendations

**PROCEED with modifications**

Justification:
1. Option C remains the most tractable path (4-6 hours estimate is reasonable IF existing infrastructure is reused)
2. The mathematical obstacles are engineering problems, not theoretical blockers
3. Alternative paths (B, D) would require similar or greater effort

**Required modifications**:

1. Task 65 scope should explicitly include:
   - Definition of RestrictedOmega (single-family shift-closure)
   - Proof that RestrictedOmega is ShiftClosed
   - Handling of the Box case with single-family semantics

2. Task 65 should document (not fix) existing sorries in the chain construction and their impact on the completeness proof

3. Consider proving `restricted_validity_gives_seed_membership` as a milestone before full TaskModel construction

4. Add explicit verification step: after Task 65 completes, verify that `valid_over Int phi` can be instantiated on the restricted model before proceeding to Task 66

## Confidence Level

**MEDIUM** (55-70%)

Justification:
- High confidence in mathematical correctness of the approach
- Medium confidence in implementation feasibility given existing sorries
- Low confidence in the 4-6 hour estimate (likely 6-10 hours accounting for sorries and edge cases)
- Uncertainty about whether all pieces will fit together until implementation
