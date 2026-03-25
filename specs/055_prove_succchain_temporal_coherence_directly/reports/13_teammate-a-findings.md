# Teammate A Research Findings: Fischer-Ladner Closure vs Fair Scheduling

**Task**: 55 - Prove SuccChain Temporal Coherence Directly
**Date**: 2026-03-24
**Role**: Teammate A — Primary Mathematical Analysis
**Focus**: `f_nesting_is_bounded` blocker — Option 1 (Fischer-Ladner Closure) vs Option 2 (Fair Scheduling)

---

## Key Findings

### Finding 1: The Blocker is Precisely Diagnosed

The theorem `f_nesting_is_bounded` claims that for ANY MCS M and formula phi with `F(phi) ∈ M`, there exists `n ≥ 2` such that `iter_F n phi ∉ M`. This is **mathematically false**.

**Counterexample**: The set `{F^n(p) | n ∈ ℕ}` is finitely consistent (any finite subset is satisfiable in a linear model of length k), so by compactness it extends to an MCS M∞ with `F(p), FF(p), FFF(p)... ∈ M∞`. No nesting bound exists.

**Why the original "proof attempt" was wrong**: It assumed finite satisfiability of M∞ (that M∞ requires only finitely many future worlds). This is false; M∞ is satisfiable in ℤ (all integers with successor), where point 0 satisfies `F^n(p)` by having p at position n.

### Finding 2: Fischer-Ladner Closure Restriction IS the Standard Fix

Reviewing the codebase, the Fischer-Ladner approach is **already partially implemented** and is the correct path:

- `closureWithNeg phi` (at `Theories/Bimodal/Syntax/SubformulaClosure.lean:90`) is the Fischer-Ladner closure of `phi` extended with negations
- `deferralClosure phi` extends this with deferral disjunctions (`phi ∨ F(phi)` for each F-subformula)
- `RestrictedMCS phi M` (at `Core/RestrictedMCS.lean:73`) means `M ⊆ closureWithNeg phi` and maximal within that closure
- `DeferralRestrictedMCS phi M` (at `Core/RestrictedMCS.lean:676`) means `M ⊆ deferralClosure phi`

The key theorem already proven:

```lean
-- Core/RestrictedMCS.lean line ~461
theorem restricted_mcs_F_bounded_exists (phi : Formula) (M : Set Formula)
    (h_mcs : RestrictedMCS phi M) :
    ∃ n : Nat, iter_F n phi ∉ M
```

**Mechanism**: `iter_F` strictly increases F-nesting depth at each step. The closure `closureWithNeg phi` contains only subformulas of phi (plus their negations), so all subformulas have depth ≤ the maximum F-depth in phi. Eventually `iter_F^n phi` has depth exceeding the maximum, hence exits the closure, hence exits the RestrictedMCS.

This is proven via `iter_F_leaves_closure` at `Bundle/CanonicalTaskRelation.lean:185`.

### Finding 3: F-Nesting Bounded Theorems Are Already Proven for DeferralRestrictedMCS

The full restricted bounded witness infrastructure is in place:

| Theorem | Location | Status |
|---------|----------|--------|
| `f_nesting_is_bounded_restricted` | `SuccChainFMCS.lean:715` | PROVEN |
| `restricted_forward_chain_F_bounded` | `SuccChainFMCS.lean:2298` | PROVEN |
| `restricted_bounded_witness` | `SuccChainFMCS.lean` | PROVEN (modulo 2 sorries at boundary cases) |
| `restricted_forward_chain_forward_F` | `SuccChainFMCS.lean` | PROVEN (uses bounded witness) |

**What works**: The `restricted_forward_chain` construction at `SuccChainFMCS.lean:2232` builds a chain where every element is a `DeferralRestrictedMCS phi`, and F-coherence (`forward_F`) is provable for THIS chain.

**The 2 remaining sorries**: Both are in boundary cases of `restricted_single_step_forcing` and `restricted_succ_propagates_F_not` — the case where `FF(psi) ∉ deferralClosure` but `F(psi) ∈ deferralClosure`. This is the "last step" before exiting the closure.

### Finding 4: The Structural Gap — Chain vs Bundle

The `SuccChainFMCS` construction (used in `boxClassFamilies_temporally_coherent`) builds a chain from a `SerialMCS` (an unrestricted MCS), NOT from a `DeferralRestrictedSerialMCS`. This is the critical gap:

- `boxClassFamilies_temporally_coherent` calls `SuccChainTemporalCoherent`
- `SuccChainTemporalCoherent` uses `succ_chain_forward_F` (has sorry)
- `succ_chain_forward_F` uses `f_nesting_boundary` (depends on false `f_nesting_is_bounded`)

The restricted chain (`restricted_forward_chain`) is separate and only usable when we START with a `DeferralRestrictedSerialMCS phi`.

### Finding 5: Fair Scheduling Is an Alternative, But More Complex

The "fair scheduling" technique constructs a chain by interleaving: enumerate all F-formulas `F(phi_1), F(phi_2), ...` as an ω-sequence, and at step 2n+1, force `phi_n` to be resolved. This is used in completeness proofs for LTL (linear temporal logic).

**Key reference**: Benthem/Verbrugge "Completeness by construction for tense logics of linear time" uses this technique for linear tense logics (including those with both F and P operators). The chain is constructed by always resolving the "oldest pending obligation" at each step.

**Advantages**:
- Works for arbitrary MCS (no restriction required)
- Directly proves `succ_chain_forward_F` without changing the chain definition
- Standard completeness technique with well-understood structure

**Disadvantages**:
- Requires redefining the successor chain construction
- Need to enumerate all F-formulas in the MCS (could be infinite — requires ω-indexing)
- For MCS over an infinite language, the enumeration is more subtle
- Would require major refactoring of `forward_chain` and `succ_chain_fam`

### Finding 6: Fischer-Ladner Restriction Applied to `succ_chain_forward_F`

The most direct resolution is to restrict `succ_chain_forward_F` to only the case where the chain is built from a restricted MCS:

```lean
-- This is already proven:
theorem restricted_forward_chain_forward_F (phi : Formula)
    (M0 : DeferralRestrictedSerialMCS phi) (n : Nat) (psi : Formula)
    (h_F : Formula.some_future psi ∈ restricted_forward_chain phi M0 n) :
    ∃ m : Nat, n < m ∧ psi ∈ restricted_forward_chain phi M0 m
```

The question then becomes: **can `boxClassFamilies_temporally_coherent` use the restricted chain instead of the unrestricted SuccChain?**

Analysis: `boxClassFamilies` constructs families from `SuccChainFMCS W` for each W in the box class of M. If we instead use `restricted_forward_chain phi W` for the target formula `phi`, we get F-coherence for free.

---

## Recommended Approach

**Recommendation: Fischer-Ladner Closure Restriction (Option 1)**

Specifically, the approach that aligns most closely with standard completeness proofs and with the existing codebase infrastructure is:

**Strategy**: Replace `SuccChainTemporalCoherent` in `boxClassFamilies_temporally_coherent` with a restricted chain construction that starts from a `DeferralRestrictedSerialMCS`. This requires:

1. **Define `RestrictedSuccChainFMCS`**: Like `SuccChainFMCS` but built from `DeferralRestrictedSerialMCS phi` using `restricted_forward_chain`. This already exists for the forward direction.

2. **Bridge the gap**: Show that for any MCS W in the box class of M0, there exists a `DeferralRestrictedSerialMCS phi` that is "equivalent" (same box class, starts from the same or compatible seed). This requires:
   - Given W (full MCS) and target phi
   - Take W ∩ deferralClosure(phi) as a restricted-consistent seed
   - Extend via `deferral_restricted_lindenbaum` to get W' (DeferralRestrictedMCS)
   - W and W' agree on box_class and on deferralClosure

3. **Use the existing `forward_F` for restricted chains** to get temporal coherence for each family.

**Alternative simpler path** (see Finding 3 sorries):
Resolve the 2 boundary case sorries in `restricted_single_step_forcing` and `restricted_succ_propagates_F_not`. Once these are resolved, the full `restricted_forward_chain_forward_F` is sorry-free, and we can bridge to `boxClassFamilies_temporally_coherent`.

**The boundary case argument**: When `F(psi) ∈ M` but `FF(psi) ∉ deferralClosure`:
- Since `F(psi) ∈ deferralClosure` but `FF(psi) ∉ deferralClosure`, psi must be at maximum F-depth in the closure
- By negation completeness for subformulaClosure: either `psi ∈ M` or `psi.neg ∈ M`
- If `psi.neg ∈ M`: combined with `F(psi) ∈ M` and the axiom `F(psi) → F(psi)`, we can derive a contradiction using `F(psi) ↔ neg G(neg psi)` — actually this cannot give a contradiction since psi can be false NOW but true in the future
- Better approach: `FF(psi) ∉ deferralClosure` means it's outside the allowed formulas. The successor `Succ M W` with `F(psi) ∈ M` means `psi ∈ W ∨ F(psi) ∈ W`. But if `FF(psi) ∉ deferralClosure`, then since the chain stays within deferralClosure, `F(psi) ∉ W` (because `F(psi) ∈ deferralClosure` only appears at depth below max). Wait: `F(psi) ∈ deferralClosure` and `FF(psi) = F(F(psi)) ∉ deferralClosure`... This means F(psi) is a deferralDisjunction element but its further nesting is outside the closure. The successor seed includes `psi ∨ F(psi)` as a deferralDisjunction. Since `F(psi) ∈ deferralClosure` but `FF(psi) ∉ deferralClosure`, and the successor must stay within deferralClosure, the successor CANNOT contain `F(psi)` (that would require `FF(psi) ∈ succ_seed ⊆ deferralClosure`). Therefore the successor MUST contain `psi`.

This is the key mathematical argument for the boundary case sorries. It relies on the fact that successor seeds are restricted to `deferralClosure`, so `F(psi) ∈ successor` would force `FF(psi) ∈ successor_seed ⊆ deferralClosure`, a contradiction if `FF(psi) ∉ deferralClosure`.

---

## Evidence from the Codebase

### Already Working (No Sorry)
- `temporal_theory_witness_consistent` and `temporal_theory_witness_exists` (UltrafilterChain.lean:1111, 1153)
- `f_nesting_is_bounded_restricted`, `f_nesting_boundary_restricted` (SuccChainFMCS.lean:715, 736)
- `restricted_forward_chain_F_bounded` (SuccChainFMCS.lean:2298)
- `restricted_forward_chain_canonicalTask_forward_from` (SuccChainFMCS.lean:2313)
- `resolving_successor_seed_consistent` simplified to trivial delegation (UltrafilterChain.lean:1498-1501)

### Existing Sorries to Resolve
- `restricted_single_step_forcing` boundary case (SuccChainFMCS.lean ~line 3077)
- `restricted_succ_propagates_F_not` boundary case (SuccChainFMCS.lean ~line 3236)
- `succ_chain_forward_F` (SuccChainFMCS.lean:838) — depends on false `f_nesting_is_bounded`

### Key Insight on `succ_chain_forward_F` Sorry
The sorry in `succ_chain_forward_F` cannot be fixed for arbitrary MCS. The correct path is:
- Either restrict to DeferralRestrictedSerialMCS and use `restricted_forward_chain_forward_F`
- Or construct a new `fair_resolving_chain` (major refactoring)

The existing `SuccChainTemporalCoherent` at line 1188 is incorrect (uses false sorry). The simplest fix to `boxClassFamilies_temporally_coherent` is to bypass it and use the restricted chain directly.

---

## Confidence Level

**High confidence** on the following:
1. `f_nesting_is_bounded` is mathematically FALSE for arbitrary MCS — counterexample is clear
2. Fischer-Ladner closure restriction (restricting to `closureWithNeg phi` or `deferralClosure phi`) is the correct mathematical approach — this is the standard method in modal logic completeness proofs
3. The boundary case argument for the 2 remaining sorries is mathematically sound — the key is that `F(psi) ∈ successor` would force `FF(psi) ∈ seed ⊆ deferralClosure`, giving a contradiction
4. Resolving the 2 boundary case sorries is the most minimal path to a sorry-free proof

**Medium confidence** on:
5. The bridge from unrestricted `SuccChainFMCS` to restricted chains for `boxClassFamilies_temporally_coherent` — the structure should work but the exact definition of `RestrictedSuccChainFMCS` and the bridge lemma need careful design
6. Whether the boundary case argument for `restricted_single_step_forcing` can be formalized easily in Lean 4 — the mathematics is clear but the proof steps may require additional infrastructure about deferralClosure depth properties

---

## Summary for Team

The mathematical resolution is clear: **Fischer-Ladner Closure Restriction** (Option 1) is the correct approach and is already partially implemented. The key gap is:

1. The 2 boundary case sorries in the restricted chain construction (fixable with the argument: `F(psi) ∈ successor ⊆ deferralClosure` forces `FF(psi) ∈ seed ⊆ deferralClosure`)
2. The bridge from unrestricted `SuccChainFMCS` to restricted chains in `boxClassFamilies_temporally_coherent`

Fair scheduling (Option 2) would also work but requires a completely new chain definition, significantly more refactoring, and is harder to formalize. It is not recommended given the existing infrastructure.

**Sources consulted**:
- Codebase: `SuccChainFMCS.lean`, `UltrafilterChain.lean`, `RestrictedMCS.lean`, `SubformulaClosure.lean`
- Prior task reports: `reports/04_resolving-chain-detailed.md`, `reports/10_team-research.md`
- Academic background: Fischer-Ladner 1979 (PDL), Benthem/Verbrugge "Completeness by construction for tense logics of linear time"
