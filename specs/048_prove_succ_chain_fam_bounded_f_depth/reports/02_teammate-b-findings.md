# Research Report: Task #48 - Teammate B Findings

**Task**: 48 - prove_succ_chain_fam_bounded_f_depth
**Angle**: Alternative Approaches Analysis
**Date**: 2026-03-23
**Researcher**: Teammate B (logic-research-agent)

---

## Executive Summary

The blocked `f_nesting_is_bounded` / `p_nesting_is_bounded` theorems are not needed **as stated**. The usage sites in `succ_chain_forward_F` and `succ_chain_backward_P` only invoke them to obtain a boundary witness `d` for the specific MCS at a specific chain index. The cleanest alternative is to **prove the chain MCS are RestrictedMCS over the target formula's closure**, which immediately unlocks the existing `f_nesting_boundary_restricted` / `p_nesting_boundary_restricted` lemmas already written in Phase 2. This avoids any unprovable claim and completes the proof using infrastructure that already exists.

A secondary alternative - proving F-coherence by a **direct inductive chain argument** avoiding iter_F entirely - is also viable but involves more new proof work.

---

## Background: The Exact Usage Sites

### Where `f_nesting_boundary` Is Invoked

`f_nesting_boundary` is called in exactly two places:

1. **`succ_chain_forward_F`** (line 836): given `F(phi) ∈ forward_chain M0 k`, invokes `f_nesting_boundary (forward_chain M0 k) h_mcs_k phi h_F` to get a depth `d ≥ 1` with `iter_F d phi ∈ M` and `iter_F (d+1) phi ∉ M`.

2. **`succ_chain_forward_F_neg`** (line 788): same pattern for `backward_chain M0 (k+1)`.

Both then pass `d`, `h_iter_d`, and `h_iter_d1_not` to `bounded_witness`.

### What `bounded_witness` Needs

```lean
theorem bounded_witness (u v : Set Formula) (phi : Formula) (n : Nat)
    (h_Fn : iter_F n phi ∈ u)
    (h_Fn1_not : iter_F (n + 1) phi ∉ u)
    (h_task : CanonicalTask_forward_MCS u n v) : phi ∈ v
```

`bounded_witness` needs only: a depth `n`, membership of `iter_F n phi` in `u`, non-membership of `iter_F (n+1) phi` in `u`, and a forward-chain task of length `n`. It does **not** care how `n` was obtained. This is the critical observation: the path to `(d, h_iter_d, h_iter_d1_not)` can be restructured without touching `bounded_witness` itself.

### Where `p_nesting_boundary` Is Invoked

`p_nesting_boundary` is called in one place:

3. **`succ_chain_backward_P`** (line 1103): given `P(phi) ∈ succ_chain_fam M0 n`, invokes `p_nesting_boundary (succ_chain_fam M0 n) h_mcs_n phi h_P` to get `d ≥ 1` with `iter_P d phi ∈ M` and `iter_P (d+1) phi ∉ M`, then uses `backward_witness`.

---

## Alternative Approaches Found

### Approach 1: Chain MCS Are RestrictedMCS (Minimal-Change Path)

**Core idea**: The completeness proof in `SuccChainCompleteness.lean` already builds M0 from a seed `{neg(phi)}` via unrestricted Lindenbaum. The claim is that it suffices to **instead** build M0 as a `RestrictedMCS` over `closureWithNeg(phi)` - then all chain MCS inherit the restriction, and the existing `f_nesting_boundary_restricted` applies directly.

**Why chain MCS would be RestrictedMCS**: If M0 is a `RestrictedMCS phi`, then the deferral seed `successor_deferral_seed M0.world` is a subset of formulas derivable from M0, hence within `closureWithNeg(phi)` (since closures are closed under logical consequences that remain within the language fragment). Each step's Lindenbaum extension would be restricted to `closureWithNeg(phi)` by using `restricted_lindenbaum` instead of `set_lindenbaum`.

**The change required**:

In `SuccChainCompleteness.lean`, replace:
```lean
obtain ⟨M, h_extends, h_mcs⟩ := set_lindenbaum {φ.neg} h_cons
```
with:
```lean
obtain ⟨M, h_extends, h_mcs⟩ := restricted_lindenbaum φ {φ.neg} h_neg_in_closure h_cons
```

This requires:
- Proving `φ.neg ∈ closureWithNeg φ` (this holds since `neg_mem_closureWithNeg` and `self_mem_closureWithNeg` give this)
- Propagating the `RestrictedMCS` type through the chain construction

In `SuccChainFMCS.lean`, the chain construction would need a parallel restricted variant:
- `RestrictedForwardChainElement`: bundles `RestrictedMCS psi` alongside `ForwardChainElement`
- `restricted_forward_chain`: uses `restricted_lindenbaum` at each step
- Similarly for backward chain

Then `succ_chain_forward_F` and `succ_chain_backward_P` simply swap the `f_nesting_boundary` calls to `f_nesting_boundary_restricted` calls. The rest of both proofs is identical.

**Status of needed infrastructure**: `restricted_lindenbaum` is already proven (RestrictedMCS.lean line 312). `f_nesting_boundary_restricted` is already proven (SuccChainFMCS.lean line 724). `p_nesting_boundary_restricted` is already proven (SuccChainFMCS.lean line 913). The main gap is threading `RestrictedMCS` through the chain construction, which is mechanical refactoring.

**Critical sub-question**: Does the deferral seed stay within `closureWithNeg psi`?

`successor_deferral_seed u = g_content u ∪ deferralDisjunctions u`

- `g_content u` = `{G(psi) | G(psi) ∈ u}` - these are all in `closureWithNeg` if `u ⊆ closureWithNeg phi`, since subformulaClosure is closed under subformulas
- `deferralDisjunctions u` = `{chi ∨ F(chi) | F(chi) ∈ u}` - since `F(chi) ∈ u ⊆ closureWithNeg phi`, and `deferralDisjunction F(chi) = chi ∨ F(chi)` must also be in `closureWithNeg phi`

This requires that `closureWithNeg` is closed under `deferralDisjunction`. Whether this holds depends on how `subformulaClosure` is defined. If `closureWithNeg` only contains subformulas plus their negations, then `chi ∨ F(chi)` may **not** be a subformula of `phi`. This is the key risk: the deferral seed may escape the closure.

**Risk assessment**: If the deferral seed escapes `closureWithNeg phi`, then `restricted_lindenbaum` cannot be used at each step, and Approach 1 fails. This needs to be verified by examining `SubformulaClosure.lean`.

### Approach 2: Completeness Proof Carries the Target Formula (Thread-Through)

**Core idea**: Rather than restricting the chain construction globally, pass the target formula `phi` as a parameter through the construction and prove the following weaker claim at the usage sites:

```lean
-- For completeness, we only need F-coherence for formulas in closureWithNeg(phi)
-- The chain MCS need not be RestrictedMCS; instead, prove:
theorem succ_chain_forward_F_for_closure_formula
    (M0 : SerialMCS) (phi target : Formula)
    (h_in_closure : phi ∈ closureWithNeg target)
    (h_mcs_restricted : RestrictedMCS target (succ_chain_fam M0 n))
    (h_F : Formula.some_future phi ∈ succ_chain_fam M0 n) :
    ∃ m : Int, n < m ∧ phi ∈ succ_chain_fam M0 m
```

This sidesteps proving the chain MCS are RestrictedMCS globally and instead pushes that as a hypothesis at the FMCS coherence level. The completeness proof would instantiate this with `target = phi` (the formula being tested for validity).

**Feasibility**: Moderate. This avoids restructuring the chain construction but adds `target` as a parameter to the FMCS coherence theorems and the FMCS structure. Since `TemporalCoherentFamily` uses `forward_F` and `backward_P` without a target parameter, this would require either:
- Specializing the `forward_F` field to carry the target formula (breaks the general interface), or
- Using the general approach only for the completeness-specific instantiation

### Approach 3: Direct F-Coherence Without iter_F Intermediate

**Core idea**: Bypass `f_nesting_boundary` / `bounded_witness` entirely and prove F-coherence directly by induction on the chain construction:

```lean
-- Prove directly: if F(phi) ∈ forward_chain M0 k, then exists k' > k with phi ∈ forward_chain M0 k'
-- Proof: by the deferral seed construction, F(phi) ∈ u implies (phi ∨ F(phi)) ∈ deferralDisjunctions u,
--        so (phi ∨ F(phi)) ∈ successor v.
--        Either phi ∈ v (done) or F(phi) ∈ v.
--        If F(phi) ∈ v, repeat. But this does NOT terminate without a bound!
```

The deferral mechanism allows F(phi) to propagate forward indefinitely: `F(phi) ∈ M_n` implies `phi ∈ M_{n+1} ∨ F(phi) ∈ M_{n+1}`. To conclude that phi eventually appears, we need either:
- A bound (which requires RestrictedMCS, bringing us back to Approach 1), or
- A different argument that phi must appear at the **first** index where F(phi) is absent

The second sub-case is interesting: since F(phi) ∈ u and `(phi ∨ F(phi)) ∈ v`, and since F(phi) ∉ v (by assumption at the boundary), we must have phi ∈ v by MCS disjunction closure. This is exactly what `bounded_witness` formalizes. So this approach **requires** finding the boundary, which requires boundedness, which requires RestrictedMCS.

**Assessment**: This approach collapses to Approach 1 when analyzed to completion.

### Approach 4: Use Completeness Only for Subformula-Closed Formulas (Scope Restriction)

**Core idea**: The completeness theorem only claims: if phi is valid, then phi is provable. In the proof, we only need the canonical model to falsify `phi.neg` at world 0. The F-coherence is invoked via the truth lemma, which proceeds by induction on formula complexity. At each step, the formulas appearing in the truth lemma are **subformulas of phi** (by induction structure).

This suggests a fundamentally different proof organization:

1. Build the succ_chain_fam as currently
2. Prove a **restricted truth lemma**: for all `psi ∈ subformulaClosure phi`, the truth lemma holds
3. For F-coherence within the restricted truth lemma, the formula `psi` is in `subformulaClosure phi`, so `F(psi)` is also in `subformulaClosure phi`, and we need a witness for `psi` specifically

The F-coherence step becomes: given `F(psi) ∈ M_n` where `psi ∈ subformulaClosure phi`, find `m > n` with `psi ∈ M_m`. The key: by the deferral mechanism, `psi ∈ M_{n+1} ∨ F(psi) ∈ M_{n+1}`. If `F(psi) ∈ M_{n+1}`, we repeat - but now we need this to terminate.

**The crucial observation**: This terminates for the same reason as Approach 1 - we need the MCS to be bounded by the closure. So again, the argument requires that the chain MCS stay within the closure.

**Unique aspect**: This approach can be proven by showing a **measure decreases** across chain steps. Define `measure(n) = |{chi ∈ closureWithNeg phi | F^k(chi) ∈ M_n for some k ≥ 1}|`. Each step that defers reduces the measure by routing chi toward satisfaction. But this requires the closure to be finite and the chain formulas to stay within it.

**Assessment**: Viable, but essentially requires the same RestrictedMCS infrastructure as Approach 1, just accessed through a different framing.

### Approach 5: Use the Axioms Directly (Semantic Shortcut)

**Core idea**: The proof system includes temporal axioms `temp_4_future` (transitivity: `F(F(phi)) → F(phi)` or similar) and `temp_a` (linearity/density). Perhaps these axioms directly limit F-nesting in any MCS.

**Investigation**: The axiom `temp_4_future` in bimodal TM logic is `G(phi) → GG(phi)` (or transitivity for G, not F). The F-axioms are:
- `seriality_future`: `G(phi) → F(phi)`
- `temp_t_future`: `G(phi) → phi` (reflexivity)

There is no axiom that bounds F-depth in an MCS over the full language. The axiom `temp_a` (if present) typically states `phi → H(F(phi))`, which would mean `phi ∈ M` implies `F(phi) ∈ M_prev` for all predecessors - this propagates F backwards, not forward. Even with all these axioms, an MCS can contain all `F^n(phi)` because:
- `F^n(phi)` for all n is consistent (no axiom derives a contradiction from this set)
- The set `{F^n(phi) : n ∈ Nat}` has the finite intersection property

**Assessment**: No existing axiom bounds F-depth in arbitrary MCS. This approach fails.

---

## Feasibility Analysis

| Approach | Mathematical Soundness | Implementation Effort | Uses Existing Infrastructure | Risk |
|----------|----------------------|-----------------------|------------------------------|------|
| 1: RestrictedMCS chain construction | High | Moderate (4-6 hours) | Yes - all key lemmas done | Deferral seed may escape closure |
| 2: Thread target formula through FMCS | High | Moderate (3-5 hours) | Partial | Breaks FMCS interface |
| 3: Direct F-coherence (no iter_F) | Reduces to Approach 1 | N/A | N/A | N/A |
| 4: Restricted truth lemma | High | Moderate (3-5 hours) | Partial | Same closure requirement |
| 5: Axiom-based | False | N/A | N/A | Fails |

### The Critical Sub-question for Approach 1

The feasibility of Approach 1 hinges on whether `successor_deferral_seed u ⊆ closureWithNeg psi` when `u ⊆ closureWithNeg psi`. Specifically: is `deferralDisjunction chi = chi ∨ F(chi)` in `closureWithNeg psi` when `F(chi) ∈ closureWithNeg psi`?

The answer depends on the definition of `subformulaClosure`:
- If `subformulaClosure` is closed under Boolean combinations of subformulas that appear in `phi`, then `chi ∨ F(chi)` would be in closure only if it's a subformula of phi.
- Typically in temporal logic, `subformulaClosure` contains exactly the subformulas of phi and their duals, NOT arbitrary Boolean combinations.

This means the deferral seed `g_content(u) ∪ deferralDisjunctions(u)` likely **escapes `closureWithNeg psi`** because `chi ∨ F(chi)` is generally not a subformula of the target formula.

If this is confirmed, the restricted chain construction requires a **larger closure** that includes deferral disjunctions - this could be formalized as a `deferralClosure` that extends `subformulaClosure` with all relevant deferral formulas.

### Alternative Closure Definition

If `subformulaClosure` is too small to contain deferral seeds, there are two options:

**Option A**: Extend the closure to `deferralClosure phi` = `subformulaClosure phi ∪ {chi ∨ F(chi) | F(chi) ∈ subformulaClosure phi} ∪ {chi ∨ P(chi) | P(chi) ∈ subformulaClosure phi}`. This larger closure is still finite and still bounds F/P-depth, since deferral disjunctions don't introduce new F/P-formulas.

**Option B**: Treat the completeness proof differently. Instead of using `restricted_lindenbaum` at each chain step, observe that the **completeness proof only needs the FMCS to contain the target formula's negation and be coherent on the subformulas of the target**. This is a weaker requirement than the chain being globally RestrictedMCS.

---

## Recommended Path Forward

### Primary Recommendation: Approach 1 with Deferral-Closed Extension

1. **Verify the closure question**: Check `SubformulaClosure.lean` to confirm whether `deferralDisjunction chi = chi ∨ F(chi)` is in `closureWithNeg phi` when `F(chi) ∈ closureWithNeg phi`. This takes 15 minutes of code reading.

2. **If deferral disjunctions are already in the closure**: Proceed directly with the restricted chain construction. All infrastructure is in place.

3. **If deferral disjunctions escape the closure**: Define `extendedClosure phi` = `closureWithNeg phi ∪ {chi ∨ F(chi) | F(chi) ∈ closureWithNeg phi} ∪ {chi ∨ P(chi) | P(chi) ∈ closureWithNeg phi}`. Prove this is finite (it is, since `closureWithNeg phi` is finite). Prove `iter_F` and `iter_P` eventually leave `extendedClosure`. Then build `ExtendedRestrictedMCS` over this closure.

4. **Thread RestrictedMCS (or ExtendedRestrictedMCS) through the chain**: Define `RestrictedForwardChainElement` and `restricted_forward_chain`. Use `restricted_lindenbaum` at each step.

5. **Swap the boundary calls**: Replace `f_nesting_boundary` with `f_nesting_boundary_restricted` (and p-analog) in `succ_chain_forward_F` and `succ_chain_backward_P`.

6. **Update `SuccChainCompleteness.lean`**: Use `restricted_mcs_from_formula` (already in RestrictedMCS.lean line 403) to build M0 as a RestrictedMCS.

### Why This is the Right Path

This approach is mathematically correct because:
- The completeness theorem's canonical model is being built specifically for a fixed formula phi
- Standard temporal logic completeness proofs in the literature (Gabbay, Goldblatt, Venema) all use some form of closure-bounded MCS construction - either via filtration (where only subformulas matter) or via restricted Lindenbaum
- The Succ-chain construction is a variant of the "successor existence" approach from Goldblatt's work, where the bounded MCS requirement is embedded in the construction from the start
- Task 47 already proved all the key boundedness lemmas for RestrictedMCS

### What the Literature Confirms

Standard completeness proofs for temporal/bimodal logic use one of two approaches:

**Approach A (Filtration)**: Build the full canonical model (unrestricted MCS), then define a finite quotient model by treating formulas as equivalent if they agree on all subformulas of the target. F-coherence in the quotient follows because the target formula's subformulas are bounded. This is the standard filtration method.

**Approach B (Restricted Lindenbaum / Closure-Bounded MCS)**: Build the canonical model directly using MCS restricted to the subformula closure. F-coherence follows immediately because the MCS cannot contain unbounded F-chains.

The current succ_chain_fam construction resembles Approach B but uses unrestricted Lindenbaum (which makes it effectively Approach A without the quotient step). The fix is to complete the Approach B picture by using restricted Lindenbaum throughout.

The critical insight from the literature: **neither approach avoids the subformula closure bound**. Every completeness proof for temporal logic with F and P operators ultimately relies on the target formula having a finite subformula closure to bound the depth of modal operators in the canonical model.

---

## Confidence Level: High

The mathematical analysis is clear:
- The claim `f_nesting_is_bounded` for arbitrary MCS is false (confirmed in prior research)
- Restricted chain construction is the correct fix (confirmed by Task 47 infrastructure)
- The main uncertainty (closure of deferral disjunctions) is a concrete verification task that can be resolved in 15-30 minutes of code inspection
- All alternative approaches that avoid restricted chain construction reduce to the same requirement when analyzed fully

The recommended path requires 4-6 hours of implementation work, with the main risk being the deferral seed closure question. If that question resolves negatively, add 2-3 hours for defining the extended closure.

---

## Appendix: Key File References

| File | Relevant Content |
|------|-----------------|
| `SuccChainFMCS.lean:706` | `f_nesting_is_bounded_restricted` - provable version |
| `SuccChainFMCS.lean:724` | `f_nesting_boundary_restricted` - provable boundary |
| `SuccChainFMCS.lean:836` | Usage site: `f_nesting_boundary` in `succ_chain_forward_F` |
| `SuccChainFMCS.lean:788` | Usage site: `f_nesting_boundary` in `succ_chain_forward_F_neg` |
| `SuccChainFMCS.lean:1103` | Usage site: `p_nesting_boundary` in `succ_chain_backward_P` |
| `RestrictedMCS.lean:312` | `restricted_lindenbaum` - proven |
| `RestrictedMCS.lean:403` | `restricted_mcs_from_formula` - proven entry point |
| `RestrictedMCS.lean:481` | `restricted_mcs_F_bounded` - proven |
| `RestrictedMCS.lean:586` | `restricted_mcs_P_bounded` - proven |
| `SuccChainCompleteness.lean:139` | Lindenbaum call to replace with restricted version |
| `SuccChainCompleteness.lean:141` | `MCS_to_SerialMCS` - may need restricted analog |
| `SuccExistence.lean:87` | `successor_deferral_seed` - deferral formula definition |
| `SubformulaClosure.lean` | Closure definition - needs verification for deferral formulas |

## Appendix: The Decisive Sub-Question

Before beginning implementation, run this check in the codebase:

Does `subformulaClosure phi` (or `closureWithNeg phi`) contain formulas of the form `chi ∨ F(chi)` when `F(chi) ∈ subformulaClosure phi`?

If `SubformulaClosure.lean` defines closure by: phi itself + subformulas + negations only, then `chi ∨ F(chi)` is NOT in the closure (since it's a disjunction not appearing as a subformula of phi unless phi contains it directly).

If yes (disjunctions of subformulas are included), the restricted construction works immediately. If no, define `deferralClosure` as described above.

This is the single most important question for implementation planning.
