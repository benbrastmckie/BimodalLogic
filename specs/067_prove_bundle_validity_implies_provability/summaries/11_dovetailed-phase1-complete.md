# Implementation Summary: Task #67 Phase 1 - Dovetailed Chain Infrastructure

**Task**: 67 - prove_bundle_validity_implies_provability
**Plan**: 08_dovetailed-omega-fmcs.md
**Status**: Phase 1 COMPLETED, Phase 2 COMPLETED (incidentally), Phase 3 BLOCKED
**Session**: sess_1774812379_c05130

## What Was Done

### Phase 1: Dovetailed Forward Chain Infrastructure (COMPLETED)

#### 1. Added Denumerable Instance for Formula (Formula.lean)

```lean
-- Formula.atom is injective
theorem Formula.atom_injective : Function.Injective Formula.atom

-- Formula is infinite since Atom is infinite
instance : Infinite Formula := Infinite.of_injective Formula.atom Formula.atom_injective

-- Formula is denumerable (countable + infinite = bijection with Nat)
noncomputable instance : Denumerable Formula := Classical.choice (nonempty_denumerable Formula)
```

This enables `Denumerable.ofNat Formula : Nat -> Formula` for enumerating all formulas.

#### 2. Added Formula Enumeration and Selection (UltrafilterChain.lean)

```lean
-- The k-th formula in the enumeration
noncomputable def enumFormula (k : Nat) : Formula := Denumerable.ofNat Formula k

-- Select formula to resolve at step n based on unpair(n).2
noncomputable def selectFormulaToResolve (M_n : Set Formula) (n : Nat) : Formula :=
  @ite _ (Formula.some_future (enumFormula (Nat.unpair n).2) ∈ M_n) (Classical.propDecidable _)
    (enumFormula (Nat.unpair n).2)
    (Formula.neg Formula.bot)

-- Proof that selected formula has F in M_n
theorem selectFormulaToResolve_has_F : F(selectFormulaToResolve M_n n) ∈ M_n
```

#### 3. Updated Dovetailed Chain Construction (UltrafilterChain.lean)

Modified `omega_chain_true_dovetailed_forward_with_inv` to use formula enumeration:
- At step n+1, decode (t, k) = Nat.unpair n
- Let psi = enumFormula k
- If F(psi) ∈ chain(n), resolve psi; otherwise resolve F_top

#### 4. Proved Resolution Property

```lean
theorem omega_chain_true_dovetailed_forward_resolves :
    selectFormulaToResolve (omega_chain_true_dovetailed_forward M0 h_mcs0 n) n ∈
    omega_chain_true_dovetailed_forward M0 h_mcs0 (n + 1)
```

### Phase 2: Chain Properties (COMPLETED - Already Done)

The following were already proven as part of the existing invariant structure:
- `omega_chain_true_dovetailed_forward_mcs` - MCS at each index
- `omega_chain_true_dovetailed_forward_box_class` - box_class_agree preserved
- `omega_chain_true_dovetailed_forward_G_theory` - G-formulas propagate
- `omega_chain_true_dovetailed_forward_zero` - chain(0) = M0

### Phase 3: Fairness Lemma (BLOCKED)

**Blocker Identified**: F-formula persistence is NOT guaranteed.

The key issue:
1. F(phi) ∈ chain(t) does not imply F(phi) ∈ chain(n) for n > t
2. The witness construction (`temporal_theory_witness_exists`) does NOT preserve arbitrary F-formulas
3. F-formulas can be "lost" during chain extension

**Why F-persistence fails**:
- Witness W extends `{phi} ∪ G_theory(M) ∪ box_theory(M)`
- For F(psi) ∈ M with psi ≠ phi, G(neg(psi)) might be added during Lindenbaum extension
- If G(neg(psi)) ∈ W, then F(psi) ∉ W (since F = neg G neg)
- This "loses" the F-obligation

**Consequence**: The dovetailing ensures we CHECK for F(phi) at infinitely many steps, but F(phi) might not persist to those steps.

## Files Modified

1. **Theories/Bimodal/Syntax/Formula.lean**
   - Added `Formula.atom_injective` theorem
   - Added `Infinite Formula` instance
   - Added `Denumerable Formula` instance

2. **Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean**
   - Added `enumFormula` definition
   - Added `selectFormulaToResolve` definition with proof
   - Modified `omega_chain_true_dovetailed_forward_with_inv` for true dovetailing
   - Added `omega_chain_true_dovetailed_forward_resolves` theorem

## Verification

- `lake build` passes successfully
- All new code is sorry-free
- Existing sorry count in UltrafilterChain.lean: 28 (unchanged)

## Next Steps

The fairness lemma (Phase 3) requires a different approach. Options:

1. **Prove F-persistence via Succ relation**: Modify witness construction to guarantee F-formulas are either resolved or deferred (not lost). This requires changing `temporal_theory_witness_exists`.

2. **Use alternative chain construction**: The `omega_chain_resolving_at_1` construction exists and resolves a SPECIFIC phi at step 1. Could we build a Z_chain that uses this for each F-obligation?

3. **Bundle-level coherence**: Accept that family-level coherence is hard and prove completeness using bundle-level coherence (`bundle_forward_F` is already sorry-free).

4. **Segerberg bulldozing**: Follow the original technique more closely - ensure the seed for Lindenbaum includes ALL unresolved F-formulas (either resolve or defer each).

## Artifacts

- Plan: specs/067_prove_bundle_validity_implies_provability/plans/08_dovetailed-omega-fmcs.md
- This summary: specs/067_prove_bundle_validity_implies_provability/summaries/11_dovetailed-phase1-complete.md
