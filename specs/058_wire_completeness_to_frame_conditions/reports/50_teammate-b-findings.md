# Research Report: Option 1 - Family-Level Temporal Coherence Construction

**Task**: 58 - Wire Completeness to Frame Conditions
**Focus**: Family-level temporal coherence construction techniques
**Completed**: 2026-03-26
**Teammate**: B

## Executive Summary

- **`f_nesting_is_bounded` failure is MATHEMATICALLY CORRECT** - The claim is false for arbitrary MCS
- **SuccChain approach is fundamentally flawed** - It assumes bounded F-nesting, which doesn't hold
- **Omega-enumeration has DIFFERENT sorries** - Z_chain_forward_F/backward_P are unproven
- **Key insight**: The omega chain resolves F_top at each step, but NOT arbitrary F-obligations
- **Viable alternative**: Fair-scheduling chain that explicitly enumerates and resolves ALL F-obligations

**Confidence Level**: MEDIUM - The path requires new construction, not fixing existing code

## Key Findings

### 1. Why `f_nesting_is_bounded` Failed

The claim was:
```
f_nesting_is_bounded : For any MCS M, there exists n such that F^n(phi) ∉ M for all phi
```

**Why it's FALSE**:

Consider the formula set `S = {F^n(p) | n ∈ Nat}` for some atom p. This set is **finitely consistent**:
- Any finite subset involves formulas up to F^k(p) for some k
- This is satisfiable: put p at position k, F(p) at position k-1, etc.

By compactness (Lindenbaum), S extends to an MCS M where:
- F^n(p) ∈ M for ALL n
- The F-nesting depth is unbounded

**Key distinction**: `f_nesting_depth` (lines 395-397 in SubformulaClosure.lean) counts the outermost consecutive F-operators of a single formula. This IS bounded by formula size. But the **set** of F-formulas in an MCS can have unbounded maximum nesting.

The error was assuming:
```
max{f_nesting_depth(phi) | F^n(phi) ∈ M for some n} is bounded
```
This is FALSE for arbitrary MCS.

### 2. SuccChain Architecture Review

Location: `SuccChainFMCS.lean`

The SuccChain construction builds a family indexed by Int:
```lean
succ_chain_fam (M0 : SerialMCS) : Int → Set Formula
```

**Forward chain** (n >= 0):
- `forward_chain M0 n` uses `constrained_successor_from_seed`
- Each step takes a temporal witness that preserves F_top and P-step

**Backward chain** (n < 0):
- `backward_chain M0 n` uses `predecessor_from_deferral_seed`
- Each step takes a past witness that preserves P_top

**The problem** (lines 39-58 in SuccChainFMCS.lean):
```
The `succ_chain_forward_F` and `succ_chain_backward_P` theorems depend on
`f_nesting_is_bounded` and `p_nesting_is_bounded`, which are **mathematically
FALSE** for arbitrary MCS.
```

The SuccChain approach ASSUMED that:
1. Each F-obligation F(phi) eventually gets resolved
2. This happens within bounded time because F^n(phi) eventually leaves the closure

But (2) is FALSE when the MCS contains unboundedly nested F-formulas.

### 3. Omega-Enumeration Analysis

Location: `UltrafilterChain.lean:1865-2500`

The omega-enumeration approach was designed to fix SuccChain:

```lean
omega_chain_forward_with_inv (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0) :
    Nat → { W : Set Formula // OmegaForwardInvariant M0 W }
```

**Key construction** (lines 2031-2045):
```lean
| n + 1 =>
  let prev := omega_chain_forward_with_inv M0 h_mcs0 n
  let h_F_top : F_top ∈ M_n := SetMaximalConsistent.contains_F_top inv_n.is_mcs
  let witness := omega_step_forward M_n inv_n.is_mcs (Formula.neg Formula.bot) h_F_top
```

**The flaw**: The omega chain ONLY resolves F_top (= F(neg bot)) at each step!
- This keeps the chain extending indefinitely
- But it does NOT resolve arbitrary F(phi) obligations

**Z_chain_forward_F sorry** (lines 2424-2485):
```lean
-- The real issue: the current omega_chain_forward always resolves F_top,
-- not arbitrary F-obligations. We need to show that F(phi) eventually gets resolved.
sorry
```

The omega-enumeration as currently implemented does NOT achieve family-level forward_F!

### 4. What Would Fix This?

To achieve family-level temporal coherence, we need a chain where:
- EVERY F(phi) in the base MCS M0 eventually gets resolved within the SAME chain
- EVERY P(phi) in M0 eventually gets resolved backward within the SAME chain

**Option A: Fair-Scheduling Chain**

Enumerate ALL F/P-obligations and resolve them in turn:

```
Step 0: Base MCS M0
Step 2n: Resolve the n-th F-obligation from M0 (using temporal_theory_witness_exists)
Step 2n+1: Resolve the n-th P-obligation from M0 (using past_theory_witness_exists)
```

**Challenge**: M0 may have INFINITELY many F-obligations. But:
- Each F-obligation is a specific formula F(phi)
- We can enumerate formulas (they're finite syntax trees)
- Use a bijection Nat → Formula to dovetail

**The construction**:
```lean
fair_chain (M0 : Set Formula) (h_mcs : SetMaximalConsistent M0) : Int → Set Formula
  | 0 => M0
  | Int.ofNat (n + 1) =>
    let prev := fair_chain M0 h_mcs (Int.ofNat n)
    let obligation := nth_F_obligation M0 (n / 2)  -- Enumerate F-obligations
    if obligation is resolved in prev then
      take_any_successor prev
    else
      take_witness_for obligation
  | Int.negSucc n => ... -- symmetric for P-obligations
```

**Key insight**: Even if M0 has infinitely many F-obligations, each specific F(phi) has a fixed enumeration index. So F(phi) gets resolved at step 2 * (index_of F(phi)).

**Option B: Restricted Domain Construction**

For completeness of a SPECIFIC formula phi, only need the closure of phi:
- `closureWithNeg phi` is FINITE
- F-obligations within the closure ARE bounded
- `f_nesting_is_bounded_restricted` IS true for RestrictedMCS

This is what the code already has:
```lean
-- From RestrictedMCS.lean
restricted_lindenbaum : RestrictedMCS phi S
```

**Path forward**: Use restricted completeness for each formula, then generalize.

### 5. Formula Structure Analysis

**f_nesting_depth** (SubformulaClosure.lean:395-397):
```lean
def f_nesting_depth : Formula → Nat
  | .imp (.all_future (.imp inner .bot)) .bot => 1 + f_nesting_depth inner
  | _ => 0
```

This counts the outermost consecutive F-operators. For any single formula:
- `f_nesting_depth (F(F(F(p)))) = 3`
- `f_nesting_depth (F(p ∧ F(q))) = 1` (NOT 2)

**max_F_depth_in_closure** (SubformulaClosure.lean:445-446):
```lean
def max_F_depth_in_closure (phi : Formula) : Nat :=
  (closureWithNeg phi).sup f_nesting_depth
```

For RestrictedMCS built from closureWithNeg(phi), F-nesting IS bounded:
- iter_F_not_mem_closureWithNeg: `iter_F n phi ∉ closureWithNeg phi` for `n >= closure_F_bound phi`

**Key theorem** (CanonicalTaskRelation.lean:175-182):
```lean
theorem iter_F_not_mem_closureWithNeg (phi : Formula) (n : Nat) (h : n ≥ closure_F_bound phi) :
    iter_F n phi ∉ Bimodal.Syntax.closureWithNeg phi
```

This shows: within a fixed closure, F-obligations ARE eventually resolved.

### 6. Bundle-Level vs Family-Level

The codebase has TWO coherence levels:

**Bundle-level** (sorry-free):
```lean
bundle_forward_F : ∀ fam ∈ families, ∀ φ t, F(φ) ∈ fam.mcs t →
    ∃ fam' ∈ families, ∃ s > t, φ ∈ fam'.mcs s  -- DIFFERENT family!
```

**Family-level** (sorry at line 1822):
```lean
forward_F : ∀ t φ, F(φ) ∈ fam.mcs t → ∃ s > t, φ ∈ fam.mcs s  -- SAME family!
```

The truth lemma backward G case REQUIRES family-level:
```lean
-- ParametricTruthLemma.lean:280-289
obtain ⟨h_forward_F, h_backward_P⟩ := h_tc fam hfam
let tcf : TemporalCoherentFamily D := { toFMCS := fam, forward_F := h_forward_F, ... }
exact temporal_backward_G tcf t psi h_all_mcs
```

`temporal_backward_G` uses contraposition:
1. Assume G(phi) ∉ fam.mcs t
2. Then F(¬phi) ∈ fam.mcs t
3. By forward_F: ∃ s > t, ¬phi ∈ fam.mcs s (SAME fam!)
4. Contradiction with hypothesis

Step 3 REQUIRES same-family witnesses. Bundle-level gives ¬phi ∈ fam'.mcs s (different family), which doesn't contradict.

## Recommended Approach

### Strategy: Fair-Scheduling Chain Construction

1. **Define obligation enumeration**:
   ```lean
   def F_obligation_enum (M : Set Formula) : Nat → Option Formula
   -- Returns the n-th F(phi) in M, or none if fewer than n F-obligations
   ```

2. **Define fair chain**:
   ```lean
   def fair_chain_forward (M0 : Set Formula) (h_mcs : SetMaximalConsistent M0) : Nat → Set Formula
   | 0 => M0
   | n + 1 =>
     let prev := fair_chain_forward M0 h_mcs n
     match F_obligation_enum M0 (n / 2) with
     | some (F phi) =>
       if phi ∈ prev then take_successor prev
       else take_witness_for_F phi prev
     | none => take_successor prev
   ```

3. **Prove forward_F**:
   For any F(phi) ∈ M0, let k = index of F(phi) in enumeration.
   Then phi ∈ fair_chain_forward M0 (2k + 1).

4. **Extend to Int-indexed family**:
   Combine forward and backward fair chains.

### Alternative: Use Restricted Completeness

If the full fair-scheduling construction is too complex:

1. **Prove completeness for RestrictedMCS** (where boundedness holds)
2. **Show**: For any unprovable phi, RestrictedMCS gives countermodel
3. **Lift**: RestrictedMCS completeness implies full completeness

This avoids constructing unbounded families entirely.

## Evidence/Examples

### Example: Unbounded F-Nesting

MCS containing:
```
M = {p, F(p), F(F(p)), F(F(F(p))), ...}
```

This is satisfiable on Int:
- World 0: contains p, F(p), F(F(p)), ...
- World 1: contains p, F(p), F(F(p)), ...
- World n: contains p, F(p), F(F(p)), ...

Each F^n(p) is satisfied because p holds at ALL worlds.

The SuccChain approach fails because it assumes F-nesting is bounded, but this MCS has unbounded F-nesting depth across its F-formulas.

### Code Reference: The Sorry Chain

```
boxClassFamilies_temporally_coherent (line 1822)
  → depends on SuccChainTemporalCoherent (removed)
    → depends on succ_chain_forward_F (removed)
      → depends on f_nesting_is_bounded (FALSE)
```

The sorry at line 1822 is PERMANENT for the SuccChain approach.

### Code Reference: Omega Chain Gap

```
Z_chain_forward_F (line 2424)
  → needs phi ∈ Z_chain s for some s > t
  → but omega_chain_forward only resolves F_top
  → arbitrary F(phi) may NEVER be resolved
  → sorry at line 2485
```

## Risks and Mitigations

| Risk | Likelihood | Mitigation |
|------|------------|------------|
| Fair-scheduling construction complex | High | Start with restricted completeness |
| Enumeration of formulas tricky | Medium | Use existing Formula ordering |
| Box-class agreement breaks | Low | Already proven transitive |
| G-theory propagation through fair chain | Medium | Need careful tracking |

## Files Examined

- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` (lines 1780-2500)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` (lines 1-400)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/TemporalCoherence.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/CanonicalTaskRelation.lean` (lines 80-280)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Syntax/SubformulaClosure.lean` (lines 375-530)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Core/RestrictedMCS.lean`
- `/home/benjamin/Projects/ProofChecker/specs/058_wire_completeness_to_frame_conditions/reports/45_team-research.md`
- `/home/benjamin/Projects/ProofChecker/specs/058_wire_completeness_to_frame_conditions/reports/40_teammate-b-findings.md`

## Summary

The family-level temporal coherence construction is blocked by a genuine mathematical obstacle:

1. **SuccChain fails** because `f_nesting_is_bounded` is false for arbitrary MCS
2. **Omega-enumeration fails** because it only resolves F_top, not arbitrary F-obligations
3. **Fair-scheduling chain** could work by explicitly enumerating and resolving ALL obligations
4. **Restricted completeness** is a simpler alternative that avoids the unboundedness issue

The recommended path forward is:
1. First implement restricted completeness (where boundedness holds trivially)
2. Then either lift to full completeness OR implement fair-scheduling for general case

**Confidence**: MEDIUM - The mathematical analysis is solid, but implementation requires new construction.
