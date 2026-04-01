# Teammate A Findings: Constrained Successor Infrastructure Analysis

## Research Run 5 — Can `constrained_successor_from_seed` solve the F/P witness problem?

---

## Key Findings

### 1. The restricted seed includes f_content directly, forcing ONE-STEP resolution

The `constrained_successor_seed_restricted` (SuccExistence.lean:356) is:
```
g_content(u) ∪ deferralDisjunctions(u) ∪ p_step_blocking_formulas_restricted(phi, u)
             ∪ boundary_resolution_set(phi, u) ∪ f_content(u)
```

The critical addition is **`f_content(u)`** as the fifth component. This means: if `F(psi) ∈ u`, then `psi` is directly in the seed, so `psi ∈ successor`. Every F-obligation resolves in exactly ONE step — no deferral possible.

This is proven sorry-free in `constrained_successor_restricted_f_content_persistence` (SuccChainFMCS.lean:2153-2159):
```
f_content u ⊆ constrained_successor_restricted phi u h_mcs h_F_top
```
which is just transitivity: `f_content ⊆ seed ⊆ successor`.

### 2. The unrestricted seed does NOT include f_content — only deferral disjunctions

The `constrained_successor_seed` (SuccExistence.lean:411) is:
```
g_content(u) ∪ deferralDisjunctions(u) ∪ p_step_blocking_formulas(u)
```

No `f_content(u)`. The F-step is only guaranteed via deferral disjunctions: `psi ∨ F(psi)` in the seed means either `psi ∈ v` (resolved) or `F(psi) ∈ v` (deferred). This is why the unrestricted chain cannot guarantee forward_F — F-obligations can be deferred indefinitely.

### 3. Why the restricted chain avoids the G-lift problem entirely

The constrained_successor_seed_restricted consistency proof (SuccChainFMCS.lean:1790-2082) has a **sorry** at line 2082. However, the sorry is specifically in the case where BRS elements (boundary_resolution_set) interact with the rest of the seed. The proof strategy is:

- Non-BRS elements (g_content, deferralDisjunctions, p_step_blocking_restricted) are all subsets of u, hence consistent
- BRS elements have F(psi) ∈ u, so their negations aren't in g_content (since F(psi) = neg(G(neg(psi))) means G(neg(psi)) ∉ u)
- The gap is proving that mixing BRS with non-BRS doesn't create derivable contradictions

**Crucially, there is NO H-blocker G-lift problem here.** The seed never tries to G-lift H-blocking formulas. The p_step_blocking_formulas are `H(neg(phi))` terms that are already in `u` (proven at SuccExistence.lean:162-171). The G-lift problem from plan 04 arose from trying to wrap controlled-seed elements in G() — the constrained successor approach never does this.

### 4. Why restriction to deferralClosure is needed

`DeferralRestrictedMCS` (DRM) restricts the MCS to formulas within `deferralClosure(phi)`, a finite set. This enables:

- **F-nesting boundedness**: `deferral_restricted_mcs_F_bounded` proves that F-iterations hit a boundary within `deferralClosure`. For unrestricted MCS, an MCS can contain `{F^n(p) | n ∈ Nat}` — unbounded F-nesting makes the bounded_witness argument impossible.
- **Boundary resolution**: When `FF(chi) ∉ deferralClosure`, the `boundary_resolution_set` forces `chi` into the successor directly, preventing infinite deferral at the closure boundary.
- **Finite closure properties**: DRM has negation completeness within `deferralClosure` and maximality within the closure, sufficient for disjunction elimination.

### 5. The restricted chain achieves sorry-free forward_F

`restricted_forward_chain_forward_F` (SuccChainFMCS.lean:2930-2934) is completely sorry-free:
```lean
theorem restricted_forward_chain_forward_F ... :
    ∃ m : Nat, n < m ∧ psi ∈ restricted_forward_chain phi M0 m :=
  ⟨n + 1, by omega, restricted_forward_chain_F_resolves phi M0 n psi h_F⟩
```

The witness is always `m = n + 1`. This works because f_content is in the seed, so every F-obligation resolves in exactly one step.

### 6. The precise gap for unrestricted MCS

The existing `SuccChainFMCS` (unrestricted) has:
- **Sorry-free**: forward_G (g_content propagation), backward_H (h_content propagation)
- **Has sorry / missing**: forward_F, backward_P

The gap is that `constrained_successor_from_seed` (unrestricted, line 519) uses only `deferralDisjunctions` for F-step, allowing indefinite deferral. Adding `f_content(u)` to the unrestricted seed would require proving `g_content(u) ∪ deferralDisjunctions(u) ∪ p_step_blocking(u) ∪ f_content(u)` is consistent, which fails because `f_content(u)` is NOT generally a subset of `u` (we have `F(psi) ∈ u` but `psi` may not be in `u`).

For DRM, adding `f_content(u)` works because: if `F(psi) ∈ u` and `psi ∉ u`, then by DRM maximality, `psi.neg ∈ u` (if `psi ∈ deferralClosure`). But `F(psi) = neg(G(neg(psi)))`, so `G(neg(psi)) ∉ u`, meaning `neg(psi) ∉ g_content(u)`. This avoids direct contradictions in the seed. The full consistency proof is where the sorry at line 2082 lives.

### 7. Sorry inventory in the restricted construction

| Location | Line | Status | Impact |
|----------|------|--------|--------|
| `g_content_union_brs_consistent` | 1734 | sorry | Not used by main path |
| `augmented_seed_consistent` | 1763 | sorry | Absorbed into seed (BRS ⊆ seed), delegates to seed consistency |
| `constrained_successor_seed_restricted_consistent` | 2082 | **sorry** | **BLOCKS the restricted construction** |
| `restricted_backward_bounded_witness_fueled` (fuel=0) | 5386 | sorry | Semantically unreachable (fuel always sufficient) |
| `restricted_combined_bounded_witness_fueled` (fuel=0) | 5544 | sorry | Semantically unreachable |
| `restricted_combined_bounded_witness_P_fueled` (fuel=0) | 5740 | sorry | Semantically unreachable |

**The critical sorry is line 2082** — proving the restricted seed is consistent. All other sorries are either unused or in semantically unreachable branches.

### 8. Could we build the dovetailed chain using constrained_successor_from_seed?

**No, not directly.** The unrestricted `constrained_successor_from_seed` lacks `f_content` in the seed, so F-obligations can be deferred indefinitely. Adding `f_content` to the unrestricted seed breaks consistency (finding 6).

**Yes, using the restricted version.** The `RestrictedTemporallyCoherentFamily` (SuccChainFMCS.lean:5847) already packages the restricted chain with forward_F and backward_P. The construction:
1. Start from `DeferralRestrictedSerialMCS` containing `neg(phi)` (built by `build_restricted_serial_mcs_from_neg_consistent`, line 2419)
2. Build forward chain via `constrained_successor_restricted` (keeps DRM property)
3. Build backward chain via `constrained_predecessor_restricted` (symmetric)
4. Combine into Int-indexed family via `restricted_succ_chain_fam`

This is already implemented. The only blocker is the seed consistency sorry (line 2082).

---

## Recommended Approach

### Primary: Close the seed consistency sorry (line 2082)

The constrained_successor_seed_restricted_consistent proof needs a "substitution lemma" that transforms a derivation `L ⊢ bot` (where L ⊆ seed) into a derivation from a subset of u. The key insight already identified in the code comments (lines 1900-1918):

**Strong induction on the number of non-u elements in L:**
- Base: All of L ⊆ u, contradicts u's consistency
- Step: Pick `psi ∈ L` with `psi ∉ u`. Then `psi.neg ∈ u` (by DRM maximality). Use the derivation-theoretic lemma: if `Gamma, A ⊢ bot` then `Gamma, neg(A) ⊢ bot` in classical logic (via `A ∨ neg(A)` and proof by cases). Replace `psi` with `psi.neg` in L, reducing the non-u count.

The required metatheorem is: **In classical Hilbert logic, if `L ⊢ bot` and we replace any `A ∈ L` with `neg(A)`, the resulting list still derives `bot`** (using excluded middle `A ∨ neg(A)`). This is a standard result but needs formalization.

### Secondary: Lift restricted chain to full TemporalCoherentFamily

Once the restricted construction is sorry-free, use `DeferralRestrictedSerialMCS.extendToMCS` (line 2975) to extend each DRM to a full MCS, then use the `extendToMCS_transfer_back` property (line 3039) to transfer coherence from the restricted chain to the extended chain.

This lifting path is already sketched in the codebase and appears mechanically straightforward once the seed consistency is resolved.

---

## Evidence/Examples

- **f_content in seed**: SuccExistence.lean:350-357, specifically `∪ f_content u` at line 357
- **One-step resolution**: SuccChainFMCS.lean:2153-2159 (`f_content_persistence`)
- **Forward_F sorry-free**: SuccChainFMCS.lean:2930-2934
- **Seed consistency sorry**: SuccChainFMCS.lean:2082
- **BRS consistency sorry**: SuccChainFMCS.lean:1734
- **Unrestricted seed (no f_content)**: SuccExistence.lean:411-412
- **Transfer-back property**: SuccChainFMCS.lean:3039-3055
- **DRM to MCS extension**: SuccChainFMCS.lean:2975-2996

---

## Confidence Level

**HIGH** that the restricted construction is the correct path forward.

**Justification:**
1. The restricted chain already has sorry-free forward_F and backward_P proofs — the ONLY blocker is seed consistency
2. The seed consistency proof strategy is clearly identified (substitution lemma via excluded middle)
3. The substitution lemma is a standard metatheorem in classical logic — the challenge is formalization, not mathematical correctness
4. The transfer-back property for lifting DRM to MCS is already proven
5. The F-persistence problem from plan 04 is completely solved by including f_content in the seed
6. The H-blocker G-lift problem from plan 04 does not arise — p_step_blocking formulas are already in u

**MEDIUM** confidence on the difficulty of closing the seed consistency sorry — the substitution lemma requires careful formalization of derivation tree manipulation, which is technically demanding but mathematically sound.
