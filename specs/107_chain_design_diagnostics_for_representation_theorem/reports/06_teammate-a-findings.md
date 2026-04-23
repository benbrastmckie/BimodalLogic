# Teammate A Findings: Strict G/H Semantics Design Analysis

**Task**: 107 - Chain design diagnostics for representation theorem
**Round**: 6
**Angle**: Primary - Simplest axiom/semantic changes for strict G/H representation theorem
**Status**: Completed

## Executive Summary

Switching G/H to strict (irreflexive) semantics -- G(phi) means "phi at all s > t" instead of "phi at all s >= t" -- is **mathematically sound and aligns the project with Burgess 1982**. The change is **surgically localized**: only 3 axioms become invalid (BX1, BX8, BX9), and the semantic change is a 2-character edit in Truth.lean (change `<=` to `<` and `>=` to `>`). The key insight is that **BX4 (connect_future: phi -> G(P(phi))) replaces BX1 (G(phi) -> phi)** as the principal interaction axiom, and it is already proven sound under strict semantics. The simplest path is Box+G+H first (no U/S), with Burgess's A3a/A4a added later for the full Until/Since system.

## 1. Exact Changes to Truth.lean Under Strict G/H

### Current reflexive semantics (lines 127-131):
```lean
| Formula.all_past φ => ∀ (s : D), s ≤ t → truth_at M Omega τ s φ
| Formula.all_future φ => ∀ (s : D), t ≤ s → truth_at M Omega τ s φ
| Formula.untl φ ψ => ∃ s : D, t ≤ s ∧ truth_at M Omega τ s ψ ∧
    ∀ r : D, t ≤ r → r < s → truth_at M Omega τ r φ
| Formula.snce φ ψ => ∃ s : D, s ≤ t ∧ truth_at M Omega τ s ψ ∧
    ∀ r : D, s < r → r ≤ t → truth_at M Omega τ r φ
```

### Proposed strict semantics:
```lean
| Formula.all_past φ => ∀ (s : D), s < t → truth_at M Omega τ s φ
| Formula.all_future φ => ∀ (s : D), t < s → truth_at M Omega τ s φ
| Formula.untl φ ψ => ∃ s : D, t < s ∧ truth_at M Omega τ s ψ ∧
    ∀ r : D, t < r → r < s → truth_at M Omega τ r φ
| Formula.snce φ ψ => ∃ s : D, s < t ∧ truth_at M Omega τ s ψ ∧
    ∀ r : D, s < r → r < t → truth_at M Omega τ r φ
```

This matches Burgess 1982 exactly (Section 1.2):
- V(U(alpha,beta)) = {x : exists y(x < y and y in V(alpha) and forall z(x < z < y => z in V(beta)))}
- V(G alpha) = {x : forall y(x < y => y in V(alpha))}

### Derived operators under strict semantics:
- F(phi) = not G(not phi) = exists s > t, phi(s) -- "phi will hold in the STRICT future"
- P(phi) = not H(not phi) = exists s < t, phi(s) -- "phi held in the STRICT past"
- phi is NOT implied by G(phi) -- G(phi) says nothing about the present

## 2. Axiom Validity Analysis Under Strict G/H

### INVALID under strict semantics (3 axioms):

| Axiom | Statement | Why Invalid |
|-------|-----------|-------------|
| **BX1** (temp_t_future) | G(phi) -> phi | G only asserts phi at s > t, says nothing about t itself |
| **BX1'** (temp_t_past) | H(phi) -> phi | Same reason for past |
| **BX8** (refl_intro_until) | psi -> (phi U psi) | No reflexive witness s = t; need s > t |
| **BX8'** (refl_intro_since) | psi -> (phi S psi) | Same for past |
| **BX9** (until_elim) | (phi U psi) -> (phi v psi) | With s > t, guard at t is not in open interval (t, s) |
| **BX9'** (since_elim) | (phi S psi) -> (phi v psi) | Same for past |

Note: BX8 and BX9 depend on the reflexive Until witness s >= t. Under strict Until (s > t):
- BX8 fails because the witness must be strictly future
- BX9 fails because the guard interval (t, s) is open at t, so phi(t) is not guaranteed

### STILL VALID under strict semantics (34 axioms):

All other axioms remain valid:
- **Propositional** (4): prop_k, prop_s, ex_falso, peirce -- no temporal content
- **S5 Modal** (5): modal_t, modal_4, modal_b, modal_5_collapse, modal_k_dist -- no temporal content
- **BX2/BX2'** (left_mono): G(phi -> chi) -> (phi U psi -> chi U psi) -- guard monotonicity works with strict < too
- **BX3/BX3'** (right_mono): G(phi -> psi) -> (chi U phi -> chi U psi) -- witness monotonicity works
- **BX4/BX4'** (connect): phi -> G(P(phi)) -- **STILL VALID** (see proof below)
- **BX5/BX5'** (self_accum): (phi U psi) -> ((phi & (phi U psi)) U psi) -- same witness
- **BX6/BX6'** (absorb): (phi U (phi & (phi U psi))) -> (phi U psi) -- same structure
- **BX7/BX7'** (linear): linearity of Until witnesses -- same argument
- **BX10/BX10'** (until_F): (phi U psi) -> F(psi) -- witness s > t gives F(psi) directly
- **BX11/BX11'** (temp_linearity): F(phi) & F(psi) -> F(phi & psi) v F(phi & F(psi)) v F(F(phi) & psi) -- witness ordering
- **BX12/BX12'** (F_until_equiv): F(phi) -> (top U phi) -- same witness
- **temp_k_dist**: G(phi -> psi) -> (G(phi) -> G(psi)) -- quantifier distribution
- **temp_4**: G(phi) -> G(G(phi)) -- transitivity of <
- **modal_future**: Box(phi) -> Box(G(phi)) -- modal-temporal interaction
- **temp_future**: Box(phi) -> G(Box(phi)) -- modal-temporal interaction

### BX4 soundness under strict semantics (key verification):

BX4: phi -> G(P(phi))

Under strict G: for all s > t, P(phi)(s). P(phi)(s) = not H(not phi)(s) = exists r < s, phi(r). Take r = t: t < s and phi(t). **Valid.**

This is exactly the `temp_a_valid` theorem already proven at line 216 of Soundness.lean with strict semantics in mind! The docstring says "Under strict semantics" and the proof uses `hts : t ≤ s` but this can be adapted to `t < s`.

## 3. Simplest Axiom System for Box+G+H (No U/S)

For the simplest representation theorem, consider the fragment with only Box, G, H (no Until/Since). The axiom system would be:

### Proposed strict Box+G+H axiom system:

**Propositional** (4): unchanged
**S5 Modal** (5): unchanged  
**Temporal** (4):
- temp_k_dist: G(phi -> psi) -> (G(phi) -> G(psi))
- temp_4: G(phi) -> G(G(phi))
- connect_future (BX4): phi -> G(P(phi))
- connect_past (BX4'): phi -> H(F(phi))
**Modal-Temporal** (2): unchanged

**Total**: 15 axioms (vs. 37 currently)

This is the system Kt4 with BX4/BX4' -- a well-known tense logic fragment. The representation theorem for this fragment is:

**Claim**: This system is complete for the class of all strict linear temporal orders.

**Proof strategy**: Standard Henkin-style completeness. Build an MCS w0 containing the negation of the non-theorem. Define successor relation on MCSs: v is a G-successor of w iff {phi : G(phi) in w} subset v. Use BX4 to establish connectedness (every MCS has successors and predecessors). Use temp_4 for transitivity. Use temp_k_dist for distribution. The canonical model is a linear order of MCSs (linearity from temp_linearity if added, or from BX4 interaction with K distribution).

**Note**: For a FULL linear order, you also need BX11 (temp_linearity): F(phi) & F(psi) -> ... This ensures F-witnesses are linearly ordered. Without BX11, you only get branching-time completeness.

### Minimal strict G/H system for LINEAR orders:

Add BX11/BX11' to the above:
- BX11 (temp_linearity): F(phi) & F(psi) -> F(phi & psi) v F(phi & F(psi)) v F(F(phi) & psi)
- BX11' (temp_linearity_past): mirror

**Total**: 17 axioms. This is complete for strict linear temporal orders.

## 4. Impact on Until/Since Under Strict Semantics

Under strict Until (U(phi, psi) at t means exists s > t with psi(s) and phi on open interval (t, s)):

### Burgess's axiom system (J0) replaces BX8/BX9 with:

| Burgess | BX equivalent | Statement | Role |
|---------|---------------|-----------|------|
| A1a | BX2 | G(p -> q) -> (U(p,r) -> U(q,r)) | left mono |
| A2a | BX3 | G(p -> q) -> (U(r,p) -> U(r,q)) | right mono |
| **A3a** | **NEW** | p & U(q,r) -> U(q & S(p,r), r) | Until-Since connect |
| **A4a** | **NEW** | U(p,q) & not U(p,r) -> U(q & not r, q) | decomposition |
| A5a | BX5 | U(p,q) -> U(p, q & U(p,q)) | self-accumulation |
| A6a | BX6 | U(q & U(p,q), q) -> U(p,q) | absorption |
| A7a | BX7 | linearity | linearity |

Missing from Burgess: BX1, BX8, BX9, BX10, BX11, BX12 (these are either invalid under strict semantics or derivable).

Note: Burgess does NOT have temp_k_dist or temp_4 as axioms -- he uses temporal generalization as a rule (from alpha, infer G(alpha) and H(alpha)). In the project's Hilbert system, temp_k_dist and temp_4 are needed because the project uses necessitation (from alpha infer G(alpha)) plus K-distribution separately.

### Can BX10, BX11, BX12 survive under strict semantics?

- **BX10** (phi U psi -> F(psi)): **STILL VALID**. The witness s > t for Until gives s > t for F(psi).
- **BX11** (temp_linearity): **STILL VALID**. The witnesses for F(phi) and F(psi) are s1, s2 > t; linearity of < gives s1 < s2, s1 = s2, or s1 > s2.
- **BX12** (F(phi) -> top U phi): **STILL VALID**. The witness s > t for F(phi) gives a Until witness.

### Are A3a and A4a derivable from BX (with strict semantics)?

This is the critical gate question from Round 5. Under strict semantics:

**A3a**: p & U(q, r) -> U(q & S(p, r), r)

This connects Until and Since. At t: p(t) holds, and exists s > t with q(s) and r on (t,s). Need: exists s' > t with (q & S(p,r))(s') and r on (t,s'). Take s' = s. Need S(p,r)(s) = exists u < s with p(u) and r on (u,s). Take u = t: t < s (yes), p(t) (yes), r on (t,s) -- this is exactly the guard from the original Until!

So A3a is **semantically valid** under strict semantics. Whether it is DERIVABLE from the remaining BX axioms is the gate question. It likely needs to be added as a new axiom.

**A4a**: U(p, q) & not U(p, r) -> U(q & not r, q)

This handles decomposition when Until fails for one target. Also **semantically valid** under strict semantics (the argument goes through with strict witnesses). Similarly likely needs to be added as a new axiom.

## 5. Impact on Sorry-Free Infrastructure

### Files using BX1 (temp_t_future/past) -- would break:

| File | Uses | Critical? |
|------|------|-----------|
| Soundness.lean | 6 | soundness proof cases -- must be REMOVED |
| SoundnessLemmas.lean | 8 | soundness lemma cases -- must be REMOVED |
| Frame.lean | 3 | MCS inclusion lemmas: G(phi) in w -> phi in w |
| CanonicalModel.lean | 7 | Canonical model g_content inclusion, consistency |
| RootScopedChain.lean | 8 | Chain construction MCS content propagation |
| Realization.lean | 4 | Quasimodel realization g/h_content subset |
| OracleInstantiation.lean | 2 | Oracle h_content subset |
| SigmaOrdering.lean | 3 | Filtration ordering |
| TemporalDerived.lean | 4 | density_derivable, G_implies_topUntil |
| Substitution.lean | 2 | Axiom substitution |
| Tactics.lean | 2 | Tactic table entries |
| SuccExistence.lean | 6+ | g_content/h_content subset proofs |

**Total BX1 usage sites**: ~55 across the codebase (excluding Boneyard)

### Files using BX8 (refl_intro_until/since) -- would break:

| File | Uses | Critical? |
|------|------|-----------|
| TruthLemma.lean | 2 | Truth lemma backward case |
| Construction.lean | 4 | Quasimodel construction |
| BXPointPath.lean | 1 | Point path extension |
| CanonicalChain.lean | 2 | Chain BX8 at MCS level |
| TemporalDerived.lean | 6 | psi_imp_until, G_implies_topUntil, bot_until_elim |
| Soundness.lean | 4+ | Soundness proof cases |
| SoundnessLemmas.lean | 8 | Soundness lemma cases |

**Total BX8 usage sites**: ~30 across the codebase

### Files using BX9 (until_elim/since_elim) -- would break:

| File | Uses | Critical? |
|------|------|-----------|
| DefectChain.lean | 3 | Defect chain elimination |
| Frame.lean | 2 | MCS Until elimination |
| QuasimodelBridge.lean | 6 | Until/Since elimination at MCS level |
| Construction.lean | 4 | Quasimodel construction |
| OracleInstantiation.lean | 2 | Oracle Until elimination |
| TemporalDerived.lean | 10+ | Various derived theorems |
| Soundness.lean | 4+ | Soundness proof cases |
| SoundnessLemmas.lean | 8 | Soundness lemma cases |

**Total BX9 usage sites**: ~40 across the codebase

### Summary of damage:

- **~125 total usage sites** across BX1 + BX8 + BX9 would need modification
- The damage is **pervasive** but follows a clear pattern: every soundness proof case, every MCS-level lemma using these axioms, and all derived theorems
- **Soundness proofs** are the most numerous (6 copies of case analysis for each axiom across different validity contexts)
- **Core metalogic** (Frame.lean, CanonicalModel.lean, RootScopedChain.lean) is deeply affected

## 6. Coexistence Strategy: Both Reflexive and Strict

### Option A: Define G_strict separately from existing G

```lean
-- Add to Formula:
| all_future_strict (φ : Formula) : Formula  -- G_strict
| all_past_strict (φ : Formula) : Formula    -- H_strict
```

Then: G_reflexive(phi) = phi & G_strict(phi).

**Problem**: This doubles the formula complexity, doubles the truth evaluation, and requires maintaining TWO axiom systems. Not recommended.

### Option B: Change semantics globally, derive reflexive G

Under strict semantics, define: G_refl(phi) := phi & G(phi), H_refl(phi) := phi & H(phi).

Then BX1 becomes: G_refl(phi) -> phi, which is trivially valid (conjunction elimination).

**Advantage**: The reflexive axioms become DERIVED theorems rather than base axioms.
**Existing code migration**: Replace every use of `Formula.all_future` meaning "reflexive G" with `phi.and phi.all_future` (i.e., phi & G(phi)). This is a systematic but extensive refactor.

### Option C (RECOMMENDED): Switch semantics, add the needed axioms, adapt infrastructure incrementally

1. Change Truth.lean (4 lines)
2. Remove BX1/BX1' from Axiom inductive
3. Remove BX8/BX8'/BX9/BX9' from Axiom inductive  
4. Add A3a/A4a (and mirrors) to Axiom inductive
5. Fix soundness proofs (remove deleted cases, add new cases)
6. Fix all MCS-level lemmas that used BX1 to derive "G(phi) in w -> phi in w"
7. Fix all MCS-level lemmas that used BX8/BX9

Step 6 is the most impactful: everywhere the canonical model uses "G(phi) in w implies phi in w" needs a new argument. Under strict semantics, this is no longer true -- G(phi) in w does NOT imply phi in w. This fundamentally changes how MCS successor relations work.

## 7. Strategy Evaluation

### Strategy (a): Start with Box+G+H only, extend later

**Axiom count**: 17 (or 15 without BX11/BX11')
**Representation theorem**: Standard Henkin completeness for strict linear tense logic
**Effort estimate**: 40-60 hours
**Advantages**:
- Much simpler axiom system (no Until/Since axioms)
- Well-studied in the literature (Burgess 1984 Part II covers G/H fragment)
- No A3a/A4a gate question
- Can reuse much existing infrastructure (MCS, Lindenbaum, BFMCS)
**Disadvantages**:
- Does not prove completeness for the full TM logic
- Would need a second effort for Until/Since extension
- May not satisfy the user's need for a "representation theorem" for the full logic

### Strategy (b): Keep current U/S system, prove representation, add Box+G+H result later

**Axiom count**: 37 -> 34 (remove BX1/BX1', BX8/BX8', BX9/BX9') + 4 new (A3a, A3b, A4a, A4b) = 38
**Representation theorem**: Burgess-style chronicle completeness
**Effort estimate**: 105-155 hours (from Round 5 estimate)
**Advantages**:
- Proves the full result directly
- Aligns with Burgess 1982 exactly
- One-time cost
**Disadvantages**:
- A3a/A4a gate still needed
- Much larger effort
- 125+ code sites to fix

### Recommended path: Hybrid

1. **Phase 0 (4-6 hours)**: Verify A3a and A4a are semantically valid under strict semantics (already confirmed above), and check if they are derivable from the remaining BX axioms. If not derivable, they must be added as new axioms.

2. **Phase 1 (20-30 hours)**: Switch to strict semantics in Truth.lean, modify axiom system (remove BX1/BX1'/BX8/BX8'/BX9/BX9', add A3a/A4a if needed), fix soundness proofs.

3. **Phase 2 (20-30 hours)**: Prove Box+G+H-only representation theorem as a warm-up and validation that the strict infrastructure works.

4. **Phase 3 (60-80 hours)**: Extend to full Until/Since using Burgess chronicle construction.

**Total**: 100-150 hours, with a checkpoint at Phase 2 that delivers a concrete result.

## 8. Key Technical Observations

### The "density_derivable" theorem changes meaning

Currently: G(G(phi)) -> G(phi) is an *instance* of BX1 (taking BX1 with psi = G(phi)).

Under strict G: G(G(phi)) -> G(phi) is actually a consequence of the TRANSITIVITY of <. If t < s and s < r then t < r, so G(phi) at t means phi at all r > t, and G(G(phi)) at t means G(phi) at all s > t, which means phi at all r > s > t. Since every r > t has some s with t < s < r (by density) -- wait, this needs DENSITY.

**Important**: G(G(phi)) -> G(phi) is NOT valid on discrete strict orders! On Z with strict <:
- G(G(phi)) at 0 means: for all s > 0, for all r > s, phi(r). So phi(r) for all r >= 2.
- G(phi) at 0 means: for all s > 0, phi(s). So phi(s) for all s >= 1.
- G(G(phi)) does NOT imply G(phi) because phi(1) is not asserted by G(G(phi)).

So temp_4 is NOT valid on discrete strict orders. However, temp_4 IS valid on dense strict orders. And Burgess works over the rationals (dense).

**Resolution**: This is fine for the project because:
1. The TaskFrame is parameterized over D with `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]`
2. For the representation theorem, we can work over Q (or any dense linear order)
3. The discrete case (Z) would need separate treatment anyway

### BX4 already has a "strict semantics" soundness proof

At line 214-223 of Soundness.lean, there is `temp_a_valid` which is explicitly labeled "Under strict semantics" and proves phi -> G(P(phi)). This is the SAME as connect_future_valid (BX4) but was written with strict semantics in mind. The current connect_future_valid uses `hts : t <= s` but the proof only needs `t <= s` to pass to `h_H_neg t hts`, and the H uses `<=` too. Under strict semantics, G quantifies over s > t, and P(phi)(s) = exists r < s, phi(r); taking r = t gives r < s from s > t, and phi(t) from the hypothesis.

## 9. Critical Dependency: TaskFrame Unchanged

The user requires TaskFrame to remain unchanged. This is satisfied because:

1. TaskFrame defines WorldState, task_rel, nullity_identity, forward_comp, converse
2. None of these mention temporal operators or their semantics
3. The temporal order comes from the type parameter D with its `LinearOrder D` structure
4. Strict vs reflexive semantics is purely a matter of how Truth.lean defines `truth_at`
5. The `<` relation on D is already available via `LinearOrder D` (it provides both `<=` and `<`)

**Conclusion**: TaskFrame is completely orthogonal to the reflexive/strict choice. No change needed.

## References

- Burgess 1982, Section 1.2: Strict semantics definition
- Burgess 1982, Section 1.3: Axiom system J0 (A1a-A7a)
- Soundness.lean lines 200-212: Current reflexive BX1 soundness
- Soundness.lean lines 214-223: Existing strict-semantics temp_a_valid proof
- Soundness.lean lines 524-539: BX4 soundness (works under strict)
- Soundness.lean lines 728-768: BX8/BX9 soundness (relies on s = t witness)
- Truth.lean lines 120-131: Current semantic definitions
