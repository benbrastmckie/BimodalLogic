# Mathematical Obstructions Analysis: Task #58

**Task**: Wire Completeness to Frame Conditions
**Agent**: Teammate C (Mathematical Obstructions)
**Date**: 2026-03-26
**Session**: sess_1774547973_caf33a

## Executive Summary

This report provides rigorous mathematical analysis of four key obstructions blocking the completeness proof. The core finding: **G(phi) -> Box(G(phi)) is NOT derivable**, and this single fact explains why bundle-level temporal coherence cannot be upgraded to family-level temporal coherence. The imp case bidirectionality is inherent to the proof structure. The semantic-syntactic gap requires the truth lemma as bridge. The f_nesting failure is fundamental for arbitrary MCS but resolvable via restricted MCS.

---

## Obstruction 1: G(phi) -> Box(G(phi)) is NOT Derivable

### Mathematical Evidence

**Countermodel Construction**:

Define a two-family bundle over Int:
- **Family fam1**: Atom p TRUE at all times t in Z
- **Family fam2**: Atom p FALSE at all times t >= 1, TRUE at t <= 0

Evaluation at (fam1, t=0):
- G(p) is TRUE: For all s >= 0, p is true in fam1 at s (p is true everywhere in fam1)
- Box(G(p)) is FALSE: Consider sigma = fam2. At (fam2, t=0), G(p) requires p true at all s >= 0. But p is false in fam2 at s=1. Hence G(p) is false at (fam2, 0).

Therefore: `truth_at G(p) at (fam1, 0)` but `NOT truth_at Box(G(p)) at (fam1, 0)`.

**Syntactic Argument**:

Examining TM axioms (from ProofSystem):
1. **TF (temp_future)**: Box(phi) -> G(Box(phi)) -- gives G from Box
2. **MF (modal_future)**: Box(phi) -> Box(G(phi)) -- gives Box(G) from Box
3. **Necessitation**: If phi is a theorem, then Box(phi) is a theorem

None of these introduce Box from G. The axioms that mention both Box and G all require Box as INPUT:
- TF: Box(phi) -> G(Box(phi))
- MF: Box(phi) -> Box(G(phi))

There is no axiom of form G(phi) -> Box(...).

### Why This Matters for Completeness

The truth lemma backward G case (ParametricTruthLemma.lean:280-289) uses `temporal_backward_G`:

```lean
obtain ⟨h_forward_F, h_backward_P⟩ := h_tc fam hfam
let tcf : TemporalCoherentFamily D := { ... forward_F := h_forward_F, backward_P := h_backward_P }
exact temporal_backward_G tcf t psi h_all_mcs
```

The `temporal_backward_G` lemma (TemporalCoherence.lean:165-178) works by contraposition:
1. Assume G(phi) NOT in fam.mcs t
2. By MCS maximality: neg(G(phi)) in fam.mcs t
3. By temporal duality: F(neg(phi)) in fam.mcs t
4. **By forward_F**: exists s > t with neg(phi) in fam.mcs s (SAME FAMILY!)
5. But backward IH gives phi in fam.mcs s for all s > t -- contradiction

Step 4 requires **forward_F** (same-family F-witness). The bundle-level construction only provides:
```
F(phi) in fam.mcs t -> exists fam' in bundle, exists s > t, phi in fam'.mcs s
```

To transfer phi from fam' to fam, we would need:
- G(phi) true in fam' implies G(phi) true in fam
- This would require Box(G(phi)) in fam'.mcs for all s >= some threshold
- Which requires G(phi) -> Box(G(phi)), which is NOT derivable

### Implications

| Approach | Status | Reason |
|----------|--------|--------|
| Upgrade bundle-level to family-level | BLOCKED | Would require G -> Box(G) |
| Use bundle-level directly | INSUFFICIENT | Truth lemma needs same-family witnesses |
| Restricted Omega per family | POSSIBLE | Avoids the transfer problem |

**Confidence Level**: HIGH (95%)

---

## Obstruction 2: Imp Case Bidirectionality is Inherent

### Mathematical Evidence

From ParametricTruthLemma.lean:200-245, the imp case forward direction:

```lean
| imp psi chi ih_psi ih_chi =>
  ...
  constructor
  · -- Forward: (psi -> chi) in MCS and truth psi -> truth chi
    intro h_imp h_psi_true
    -- By IH backward: psi in MCS
    have h_psi_mcs : psi ∈ fam.mcs t := (ih_psi fam hfam t).mpr h_psi_true  -- <-- USES .mpr (backward)
    -- By MCS modus ponens: chi in MCS
    have h_chi_mcs : chi ∈ fam.mcs t := SetMaximalConsistent.implication_property h_mcs h_imp h_psi_mcs
    -- By IH forward: truth chi
    exact (ih_chi fam hfam t).mp h_chi_mcs
```

The forward direction for implication has this structure:
1. Assume (psi -> chi) in MCS and assume truth(psi)
2. Need to show truth(chi)
3. Step: Convert truth(psi) to psi in MCS -- **requires backward IH**
4. Step: Apply MCS modus ponens to get chi in MCS
5. Step: Convert chi in MCS to truth(chi) -- uses forward IH

### Why This Cannot Be Avoided

The proof of `(psi -> chi) in MCS implies (truth(psi) -> truth(chi))` fundamentally needs to:
1. Take a semantic hypothesis: truth(psi)
2. Derive a semantic conclusion: truth(chi)

But the MCS property `(psi -> chi) in MCS` is syntactic. The only way to use it is:
- Get psi in MCS (syntactic)
- Apply modus ponens in MCS
- Get chi in MCS (syntactic)
- Convert back to truth(chi)

The conversion from truth(psi) to psi in MCS IS the backward direction of the induction hypothesis.

### Attempted Restructurings

**Attempt 1: Forward-only with negation**
- Could try: if truth(psi), show directly that NOT truth(chi) leads to contradiction
- Problem: Still need to show that NOT truth(chi) implies something in MCS
- This would require backward IH on chi.neg

**Attempt 2: Direct semantic argument**
- Could try: define truth independently of MCS
- Problem: The canonical model construction DEFINES truth via MCS membership
- The whole point is `valuation := fun M p => atom p in M.val`

### Implications

The truth lemma is **inherently bidirectional**. Any proof structure must handle:
- Forward: MCS membership -> truth
- Backward: truth -> MCS membership

These are proven simultaneously via mutual induction. Claims that "forward-only suffices" are incorrect.

**Confidence Level**: HIGH (100% - verified directly in code)

---

## Obstruction 3: Semantic vs Syntactic Gap

### The Gap Precisely Defined

**Semantic side** (`valid_over` from Validity.lean):
```lean
def valid_over (D : Type) ... (φ : Formula) : Prop :=
  ∀ (F : TaskFrame D) (M : TaskModel F) (Omega : Set (WorldHistory F))
    (τ : WorldHistory F) (t : D),
    τ ∈ Omega → truth_at M Omega τ t φ
```

This quantifies over ALL TaskModels, ALL histories, ALL times.

**Syntactic side** (MCS membership):
```lean
phi ∈ M  -- where M is SetMaximalConsistent
```

This is membership in a particular set of formulas.

### The Bridge: Truth Lemma

The truth lemma creates the connection:
```lean
phi ∈ fam.mcs t <-> truth_at CanonicalModel CanonicalOmega (parametric_to_history fam) t phi
```

But this only relates MCS membership to truth in ONE specific model (the canonical model), not ALL models.

### Why the Canonical Model is Special

**Property 1: Universality**
- The canonical model contains ALL MCSes (via boxClassFamilies)
- Every consistent formula has an MCS containing it
- Therefore, if phi is NOT provable, neg(phi) is consistent, some MCS M contains neg(phi)

**Property 2: Counter-model Witness**
- If phi is valid_over, then phi is true in the canonical model
- By truth lemma: phi is in every MCS at every time
- Contrapositive: if some MCS lacks phi, then phi is NOT valid_over

**The Exact Gap**:
```
valid_over phi
= ∀ Model M, ∀ τ, ∀ t, truth_at M τ t phi
⊃ truth_at CanonicalModel (parametric_to_history fam) t phi  [canonical model is ONE model]
<-> phi ∈ fam.mcs t  [truth lemma]
```

The gap is that valid_over requires truth in ALL models, but we only have a truth lemma for the canonical model.

### Bridging the Gap

**Direction 1: valid_over -> phi provable** (completeness)
- By contrapositive: if NOT provable, then NOT valid_over
- If NOT provable, neg(phi) consistent, extend to MCS M
- M is part of canonical model
- neg(phi) in M means phi NOT in M
- By truth lemma: phi NOT true at (M, 0) in canonical model
- Hence phi NOT valid_over (canonical model is a counterexample)

This direction works once we have the truth lemma.

**Direction 2: phi provable -> valid_over** (soundness)
- Proven separately via soundness theorem
- Axioms are valid, rules preserve validity

### The Model-Theoretic Glue Sorry

The sorry in `bundle_validity_implies_provability` (Completeness.lean:186-214) is exactly this gap:
- We have `valid_over Int phi` as hypothesis
- We need to derive that phi is provable
- The algebraic path (`bundle_completeness_contradiction`) shows: if phi not provable, then NOT (all MCS contain phi)
- Need: valid_over implies all MCS contain phi

This requires showing the canonical model IS a valid TaskModel over Int.

**Confidence Level**: HIGH (95%)

---

## Obstruction 4: The f_nesting_is_bounded Failure

### The Exact Definition

From SuccChainFMCS.lean:715-726:
```lean
theorem f_nesting_is_bounded_restricted (phi : Formula) (M : Set Formula)
    (h_mcs : RestrictedMCS phi M)
    (h_F : Formula.some_future phi ∈ M) :
    ∃ n, n ≥ 2 ∧ iter_F n phi ∉ M
```

Where `iter_F`:
```lean
def iter_F : Nat -> Formula -> Formula
  | 0, phi => phi
  | n + 1, phi => Formula.some_future (iter_F n phi)
```

So `iter_F n phi = F(F(F(...F(phi)...)))` with n applications of F.

### Why Boundedness Fails for Arbitrary MCS

**Counterexample Construction**:

Consider the set `S = {F^n(p) | n in Nat}` where `F^n(p) = iter_F n p`.

**Claim**: S is finitely consistent.

**Proof**: Any finite subset {F^{n_1}(p), ..., F^{n_k}(p)} is satisfiable on integers:
- Let m = max(n_1, ..., n_k)
- Model: p true at position m, false elsewhere
- At position 0: F^{n_i}(p) is true for each n_i (witness: position n_i <= m where we traverse to p's truth at m)

By Lindenbaum, S extends to an MCS M.

**Consequence**: M contains F^n(p) for ALL n in Nat. Hence iter_F has no bound in M.

### Why Restricted MCS Works

For RestrictedMCS:
```lean
structure RestrictedMCS (phi : Formula) (M : Set Formula) where
  mcs : SetMaximalConsistent M
  subset : M ⊆ closureWithNeg phi
```

The closure of a formula phi has bounded size (at most 2 * |subformulas(phi)|).

Therefore, iter_F eventually leaves the closure:
- iter_F 0 phi = phi (in closure if F(phi) in closure)
- iter_F 1 phi = F(phi) (might be in closure)
- iter_F k phi = F^k(phi) for some k, this is NOT a subformula of phi

Once iter_F leaves closureWithNeg(phi), it cannot be in M (since M ⊆ closureWithNeg(phi)).

### Implications for Completeness

| Approach | F-nesting | Status |
|----------|-----------|--------|
| Arbitrary MCS | Unbounded | SuccChain approach FAILS |
| RestrictedMCS | Bounded | SuccChain works BUT limited scope |
| Omega-enumeration | Resolved by construction | Bundle-level coherence only |
| Fair-scheduling | Each obligation eventually met | Would give family-level coherence |

The f_nesting failure means:
1. **SuccChainTemporalCoherent is FALSE** for arbitrary MCS
2. **Family-level forward_F cannot be proven** via the SuccChain approach
3. **Bundle-level is achievable** via omega-enumeration (but insufficient for truth lemma)

### The Fair-Scheduling Alternative

A potential resolution: instead of deterministic successor choice, use fair scheduling:
1. Enumerate all F-obligations in M: {F(phi_i) | i in Nat}
2. At step 2i, force-resolve obligation F(phi_i)
3. This ensures EVERY obligation gets resolved eventually

This would give family-level forward_F by construction. The challenge: maintaining consistency across forced resolutions.

**Confidence Level**: HIGH (100% - counterexample is explicit)

---

## Synthesis: What Each Obstruction Rules Out

### Obstruction Interaction Map

```
                     +---> Blocks bundle->family upgrade
                     |
G -> Box(G) INVALID -+---> Blocks cross-family F transfer
                     |
                     +---> Forces same-family witnesses for truth lemma
                            |
                            v
                     Imp bidirectionality +---> Truth lemma MUST be bidirectional
                            |
                            v
                     Truth lemma needs h_tc +---> h_tc needs family-level forward_F
                            |
                            v
                     f_nesting unbounded +---> SuccChain can't give family-level forward_F
                            |
                            v
                     BLOCKED: Family-level temporal coherence via SuccChain
```

### What IS Achievable

1. **Bundle-level temporal coherence**: PROVEN (`boxClassFamilies_bundle_temporally_coherent`)
2. **Algebraic completeness**: PROVEN (`bundle_completeness_contradiction`)
3. **MCS containment -> NOT provable**: PROVEN
4. **NOT provable -> neg consistent**: PROVEN

### What IS NOT Achievable (Currently)

1. **Family-level temporal coherence**: Blocked by f_nesting + G->Box(G)
2. **Full truth lemma**: Blocked by family-level temporal coherence
3. **Model-theoretic glue**: Blocked by full truth lemma

### The Remaining Gap

The algebraic path proves:
```
¬([] ⊢ phi) -> ∃ M (MCS), phi ∉ M
```

The semantic completeness needs:
```
valid_over Int phi -> [] ⊢ phi
```

The connection requires:
```
valid_over Int phi -> ∀ M (MCS), phi ∈ M
```

Which is the contrapositive of:
```
∃ M (MCS), phi ∉ M -> ¬(valid_over Int phi)
```

This would follow from: "canonical model is a valid TaskModel over Int" + truth lemma.

---

## Recommendations

### Option 1: Fix Family-Level Temporal Coherence (Hard)

**Approach**: Fair-scheduling construction
- Enumerate F-obligations
- Force-resolve each in turn
- Maintain consistency via careful MCS extension

**Difficulty**: HIGH
**Payoff**: Complete resolution of all obstructions

### Option 2: Per-Family Omega (Medium)

**Approach**: For each family fam, define Omega_fam restricted to that family
- Temporal witnesses are same-family by construction
- Box still quantifies over multiple families via family-to-family agreement

**Difficulty**: MEDIUM (requires re-architecting the Box case)
**Payoff**: Avoids the cross-family transfer problem

### Option 3: Accept Bundle-Level + Model Glue (Easiest)

**Approach**: Prove the canonical model is a valid TaskModel
- Show BFMCS_Bundle satisfies TaskFrame constraints
- Show parametric_to_history gives valid WorldHistory
- Connect truth_at to MCS membership directly

**Difficulty**: LOW (infrastructure, not conceptual)
**Payoff**: Completes the proof with current architecture

---

## References

- `TemporalCoherence.lean:165-178` - temporal_backward_G proof structure
- `ParametricTruthLemma.lean:200-245` - imp case showing .mpr usage
- `UltrafilterChain.lean:1816-1822` - boxClassFamilies_temporally_coherent SORRY
- `UltrafilterChain.lean:2730` - boxClassFamilies_bundle_temporally_coherent (sorry-free)
- `SuccChainFMCS.lean:715-726` - f_nesting_is_bounded_restricted
- `SuccChainFMCS.lean:39-47` - f_nesting_is_bounded limitation documented
- `Completeness.lean:186-214` - bundle_validity_implies_provability (model-theoretic glue sorry)
