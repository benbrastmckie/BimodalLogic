# Task 35: Teammate B Research Findings
## Alternative Patterns, Prior Art, and Proof Techniques

**Focus**: Similar proven constructs, reusable patterns, Mathlib resources, and alternative approaches.

---

## Similar Proofs Found

### 1. `bounded_witness` — Exact F-direction Analog of `backward_witness`
**File**: `Theories/Bimodal/Metalogic/Bundle/CanonicalTaskRelation.lean:541-569`

The F-direction version is fully proven and provides a direct template for `backward_witness`.
The inductive structure is:
- Base (n=0): `iter_F 0 phi ∈ u` and chain of 0 steps means `u = v`, done.
- Inductive (n=k+1): use `single_step_forcing` to extract `iter_F k phi ∈ w`, use `succ_propagates_F_not` to show `iter_F (k+1) phi ∉ w`, recurse.

**Relevance**: `backward_witness` needs the same structure but with:
- `single_step_forcing_past` (already defined at `SuccRelation.lean:354`) instead of `single_step_forcing`
- `succ_propagates_P_not` (sorry at `CanonicalTaskRelation.lean:665`) instead of `succ_propagates_F_not`
- `h_p_step` (from `CanonicalTask_backward_MCS_P`) instead of the Succ f_step

The key insight from reading `backward_witness:706-720`: the inductive step comment correctly identifies that the proof should proceed as:
1. Obtain `(w, h_mcs_u, h_mcs_w, h_succ, h_p_step, h_chain)` from `step_inv`
2. The chain is `u -> w -> ... -> v` in Succ direction, so `iter_P k phi` needs to be in `w` (not `u`)
3. Apply `single_step_forcing_past` between `w` and `v` (the **last** link, not the first)

**Current blocker**: The comment at line 741-755 reveals a direction confusion. The induction should apply to the **last** step of the chain, not the first. The chain `CanonicalTask_backward_MCS_P u (k+1) v` means: there exists `w` with `Succ u w` (u is predecessor of w) and `CanonicalTask_backward_MCS_P w k v`. So `v` is the endpoint with the P-obligations, and we need to peel off the **innermost** step near `v`.

**Alternative fix**: Restructure the induction to peel from `v`'s side. See Section "Alternative Approaches" below.

### 2. `succ_propagates_F_not` — Exact Template for `succ_propagates_P_not`
**File**: `Theories/Bimodal/Metalogic/Bundle/CanonicalTaskRelation.lean:496-519`

The F-direction version (`succ_propagates_F_not`) is fully proven. The P-direction version (`succ_propagates_P_not`) at line 665 is also **already fully proven** (lines 676-689). The sorry comment is misleading — reading the code at `SuccRelation.lean:497` shows the sorry is in `single_step_forcing_past`, not in `succ_propagates_P_not`.

**Clarification**: `succ_propagates_P_not` at `CanonicalTaskRelation.lean:665` IS proven. The sorry is in `single_step_forcing_past` at `SuccRelation.lean:497`.

### 3. `predecessor_satisfies_p_step` — Template for P-step Infrastructure
**File**: `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean:573-597`

This is a fully-proven theorem showing that the predecessor construction satisfies P-step. It uses:
1. `pastDeferralDisjunction φ ∈ predecessor_deferral_seed` (from `pastDeferralDisjunctions_subset_predecessor_deferral_seed`)
2. Extension: the disjunction is in the predecessor MCS
3. MCS disjunction elimination: either `φ ∈ predecessor` or `P(φ) ∈ predecessor`

**Relevance**: This is the proof pattern for why `succ_chain_fam_p_step` (the third axiom) is semantically sound. The proof for the forward chain elements requires showing similar P-step properties hold for `successor_from_deferral_seed`-built worlds.

### 4. `single_step_forcing_past` — Template for Fixing `succ_propagates_P_not` in SuccRelation
**File**: `Theories/Bimodal/Metalogic/Bundle/SuccRelation.lean:354-497`

This is the sorry in `SuccRelation.lean:497`. The proof outline is documented at lines 336-349:
1. `PP(phi) ∉ v` → `neg(PP(phi)) ∈ v` by negation completeness
2. → `HH(neg(phi)) ∈ v` by `neg_PP_implies_HH_neg_in_mcs`
3. → `H(neg(phi)) ∈ h_content(v)`
4. → `H(neg(phi)) ∈ u` by `Succ_implies_h_content_reverse`
5. → `P(phi) ∉ u` by `H_neg_implies_not_P`
6. Then `phi ∈ p_content(v)` (since `P(phi) ∈ v`)
7. **Gap**: Need `p_content(v) ⊆ u ∪ p_content(u)` (P-step)
8. Since `P(phi) ∉ u`, conclude `phi ∈ u`

Steps 1-5 are all proven. Steps 6-8 require the P-step property. The comment at line 469 notes: "In the succ_chain construction, this is guaranteed by `predecessor_satisfies_p_step`."

**Key insight**: `single_step_forcing_past` requires a P-step hypothesis. It should be refactored to take `h_p_step : p_content v ⊆ u ∪ p_content u` as an explicit parameter, matching the pattern in `CanonicalTask_backward_MCS_P` which already carries `h_p_step`.

### 5. `succ_chain_forward_F` — Template for the Nesting Boundary Usage Pattern
**File**: `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean:638-675`

This fully proven theorem shows exactly how `f_nesting_boundary` is called and used:
```lean
obtain ⟨d, h_d_ge, h_iter_d, h_iter_d1_not⟩ := f_nesting_boundary (forward_chain M0 k) h_mcs_k phi h_F
```
The p-direction analog `succ_chain_backward_P` at line 799 follows the same pattern with `p_nesting_boundary`.

---

## Reusable Proof Patterns

### Pattern A: "Boundary via Negation Completeness"
Used throughout the codebase. The pattern for nesting boundaries:
```
If F(phi) ∈ M (MCS), then EITHER iter_F n phi ∈ M for ALL n (impossible by consistency)
OR there exists a minimal n where iter_F n phi ∈ M but iter_F (n+1) phi ∉ M.
```
This is the semantic content of `f_nesting_boundary` and `p_nesting_boundary`. The formalization requires `Nat.find` (well-founded minimum) or classical choice on the predicate `¬(iter_F n phi ∈ M)`.

**Lean 4 tool**: `Nat.find` with `Nat.find_spec` and `Nat.find_min` provides exactly this. Example pattern:
```lean
-- Given: h_F : F(phi) ∈ M (i.e., iter_F 1 phi ∈ M)
-- Define: p n := iter_F (n+1) phi ∉ M
-- Show: ∃ n, p n (by MCS consistency: if all iter_F n ∈ M, the set is inconsistent)
-- Then d := Nat.find ⟨0, h_base⟩ works via well-founded min
```
The non-triviality: we need to show the predicate is eventually true. This requires showing that unbounded F-nesting in one MCS would violate consistency (since M is consistent and finite derivation uses only finitely many assumptions).

**Approach via formula complexity**: `Formula.complexity` at `Theories/Bimodal/Syntax/Formula.lean:92` measures structural size. `iter_F n phi` has complexity `1 + complexity(iter_F (n-1) phi)`, growing with `n`. Since M is consistent, it cannot contain all `iter_F n phi` for all `n`; otherwise by the temp_4 axiom chain, we'd derive arbitrarily complex formulas, violating that any finite derivation from M uses only finitely many assumptions. However, this argument requires careful formalization.

**Simpler approach**: Use the fact that `iter_F n phi` and `(iter_F n phi).neg` cannot both be in M. By MCS, for each n, either `iter_F n phi ∈ M` or `iter_F n phi ∉ M`. The sequence eventually leaves M because M is determined by a consistent finite axiom system and F-chains must terminate.

### Pattern B: "Succ G-persistence + negation completeness cascade"
Used in `succ_propagates_F_not` (`CanonicalTaskRelation.lean:496`) and `succ_propagates_P_not` (`CanonicalTaskRelation.lean:665`). The proven 5-step chain:
1. `neg(FF(phi)) ∈ M` → `GG(neg(phi)) ∈ M` (via `neg_FF_implies_GG_neg_in_mcs`)
2. `GG(neg(phi)) ∈ M` → `G(neg(phi)) ∈ g_content(M)`
3. `Succ u w` → `G(neg(phi)) ∈ w` (G-persistence)
4. `G(neg(phi)) ∈ w` → `F(phi) ∉ w`

This same pattern works for P-direction: replacing G→H, F→P, and using `Succ_implies_h_content_reverse`.

### Pattern C: "P-step from predecessor construction"
In `SuccExistence.lean:573`, the P-step is derived from the `pastDeferralDisjunction` seed. The key is that the predecessor construction explicitly includes `φ ∨ P(φ)` for each `P(φ)` in the original world, ensuring resolution or deferral. The forward chain does NOT have P-step by construction but can be shown to have it via axiom (succ_chain_fam_p_step).

### Pattern D: "Induction with chain inversion at the endpoint"
For `backward_witness`, the correct pattern (matching `bounded_witness`) is:
- The chain encodes `u → w₁ → ... → v` in Succ direction
- P-obligations are in `v`; we need to resolve them by going backward
- The inductive step should peel off the link closest to `v`, not to `u`

This requires a `tail_inv` or `end_inv` for `CanonicalTask_backward_MCS_P`, analogous to `step_inv`. Currently only `step_inv` (peeling from the `u` end) exists at line 644. Adding a tail inversion would unblock `backward_witness`.

### Pattern E: "Contraction via weakening + induction on derivation"
For the contraction sorry in `SuccChainCompleteness.lean:109`. The context is:
- `L` is a list with all elements equal to `φ.neg`
- `L ⊢ bot`
- Need: `[φ.neg] ⊢ bot`

This is a structural lemma about the proof system. The `weakening` rule goes the wrong direction (adding assumptions), so we need the reverse: if `L ⊢ φ` and all elements of `L` are from `{ψ}`, then `[ψ] ⊢ φ`. This follows by induction on derivation height using:
- `derivation_exchange` (already in `MCSProperties.lean:61`) — same elements → same derivability
- The key: map each assumption `h : φ ∈ L` (where `L = [ψ, ψ, ..., ψ]`) to `φ = ψ`, then use assumption in `[ψ]`

The `derivation_exchange` lemma at `MCSProperties.lean:61` is **exactly the right tool**: if `∀ x, x ∈ Γ ↔ x ∈ Γ'`, then `Γ' ⊢ φ`. For `L` with all elements `φ.neg` and `Γ' = [φ.neg]`: `∀ x, x ∈ L ↔ x ∈ [φ.neg]` iff `∀ x, x = φ.neg`. This is true when `L` is a list of copies of `φ.neg`.

Actually `derivation_exchange` requires set equality, not multiset equality. Weakening handles `Γ ⊆ Δ`. The correct tool is: `[φ.neg] ⊆ L` (if `L` is non-empty with all `φ.neg`) is false (direction wrong), and `L ⊆ [φ.neg]` (as list membership, i.e., all elements equal `φ.neg`) is what we have. But `L ⊢ bot` and `L ⊆ [φ.neg]` as set membership means `contextAsSet L ⊆ contextAsSet [φ.neg]`, so by weakening on the SET level we can go from `[φ.neg] ⊢ bot` to `L ⊢ bot` — but we need the reverse.

**Correct approach for contraction**: Define the contraction lemma by induction on derivation height:
```lean
def contract {φ : Formula} (d : DerivationTree [φ, φ] ψ) : DerivationTree [φ] ψ
```
via induction on `d`, mapping assumption `φ ∈ [φ, φ]` to `φ ∈ [φ]`. This generalizes to arbitrary duplicate removal. Alternatively, for the specific case in `SuccChainCompleteness.lean:109`: note that `SetConsistent {φ.neg}` only requires that for any `L ⊆ {φ.neg}` AS A SET (not multiset), `L` is consistent. Lists from `{φ.neg}` as a set can only be lists of `φ.neg` repetitions. The `Consistent L` for `L = [φ.neg, φ.neg, ...]` follows directly from `Consistent [φ.neg]` via `derivation_exchange` since `contextAsSet [φ.neg, φ.neg, ...] = {φ.neg} = contextAsSet [φ.neg]`.

---

## Relevant Mathlib Resources

### For Nesting Boundary (`f_nesting_boundary`, `p_nesting_boundary`)
- **`Nat.find`** (`Mathlib.Data.Nat.Find`): Given `h : ∃ n, p n`, `Nat.find h` returns the minimum `n`. Properties: `Nat.find_spec`, `Nat.find_min`.
- **`Nat.lt_of_not_lt`**, **`Nat.not_lt`**: For deriving contradictions from "all F^n(phi) ∈ M"
- The key missing piece: showing that the predicate `∃ n, iter_F n phi ∉ M` is true. This requires:
  - MCS consistency (already available via `SetMaximalConsistent.1`)
  - A lemma: if `iter_F n phi ∈ M` for all `n`, then M is inconsistent

### For Contraction
- **`List.Sublist`**, **`List.subset_def`**: For reasoning about list containment
- **`List.dedup`**, **`List.dedup_sublist`**: Deduplicated lists are sublists
- The `derivation_exchange` lemma in `MCSProperties.lean:61` works at the set level and is the right tool.

### For backward_witness
- **`Finset.induction`** or **`List.induction`** applied to chain structure
- No specific Mathlib lemma needed — the proof is by induction on chain length, mirroring `bounded_witness`.

---

## Alternative Approaches Considered

### Alternative 1: Re-architect `backward_witness` induction direction
**Current issue**: `CanonicalTask_backward_MCS_P.step` peels from the `u` (far) end, but the P-obligations are at `v` (the near end). `bounded_witness` works because F-obligations are at `u` and the chain goes forward.

**Proposal**: Add a `tail_step` constructor or `tail_inv` theorem for `CanonicalTask_backward_MCS_P` that peels from the `v` end:
```
CanonicalTask_backward_MCS_P u (k+1) v ↔ ∃ w, Succ w v ∧ P-step(w,v) ∧ CanonicalTask_backward_MCS_P u k w
```
Then the induction becomes: `iter_P (k+1) phi ∈ v`, `iter_P (k+2) phi ∉ v`, peel the last link `w → v`, apply `single_step_forcing_past` to get `iter_P k phi ∈ w` (using P-step of `w → v`), apply `succ_propagates_P_not` to get `iter_P (k+1) phi ∉ w`, recurse.

This mirrors exactly the `bounded_witness` proof and should be straightforward.

**However**: This requires proving the tail_inv direction, which may require commutativity of the chain structure.

### Alternative 2: Use `single_step_forcing_past` with explicit P-step parameter
Instead of fixing `single_step_forcing_past` globally (which requires finding P-step from the Succ relation), provide a variant:
```lean
theorem single_step_forcing_past_pstep
    (u v : Set Formula) (h_mcs_u : ...) (h_mcs_v : ...)
    (h_p_step : p_content v ⊆ u ∪ p_content u)  -- explicit P-step
    (phi : Formula)
    (h_P : P(phi) ∈ v) (h_PP_not : PP(phi) ∉ v)
    (h_succ : Succ u v) : phi ∈ u
```
This version works because `CanonicalTask_backward_MCS_P` already carries `h_p_step`, so the proof of `backward_witness` can pass it directly.

**Confidence**: HIGH — this is the minimal change needed.

### Alternative 3: Prove `succ_chain_fam_p_step` from first principles
Rather than axiomatizing `succ_chain_fam_p_step`, prove it from the underlying chain construction:
- For `backward_chain` elements: use `backward_chain_p_step` (already proven at `SuccChainFMCS.lean:264`)
- For `forward_chain` elements: show P-step holds because `successor_from_deferral_seed` creates a world that implicitly satisfies P-step via the deferral seed structure

This would eliminate one axiom. However it requires analyzing `successor_from_deferral_seed` for P-step, which isn't immediately obvious.

### Alternative 4: Direct contradiction proof for nesting boundaries
For `f_nesting_boundary` and `p_nesting_boundary`, use classical minimum via `Nat.find`:

```lean
-- Prove: ∃ n ≥ 1, iter_F n phi ∉ M
-- Key lemma needed: ∀ n, iter_F n phi ∈ M → M is inconsistent (for large enough n)
-- More precisely: if all {iter_F n phi | n : Nat} ⊆ M, then M derives ⊥
```

The formal proof of the key lemma: if `M` contains `iter_F n phi` for all `n`, then consider the list `[iter_F 1 phi, ..., iter_F k phi]` for any `k`. These are pairwise inconsistent with some negation (by MCS consistency forcing neg(iter_F m phi) ∈ M for some m). More directly: by MCS maximality applied to `iter_F (k+1) phi` — either it's in M or its negation is. If both `iter_F k phi ∈ M` and `iter_F (k+1) phi ∈ M`, then by MP on `⊢ F^k(phi) → F^(k+1)(phi)` (provable from the axiom `phi → G(P(phi))` dual and F_4 chain), this is consistent in principle. The inconsistency must come from unboundedness combined with finiteness of derivations.

**Simpler approach**: The nesting boundary follows from the **formula depth bound**. In any MCS M over a language with `Formula.complexity`, `iter_F n phi` has strictly increasing complexity. Since any finite list from M derives only from formulas in M, and the set of formulas with complexity ≤ k is finite, for large enough n the formula `iter_F n phi` cannot be derived from smaller formulas, hence it must be absent from any consistent M (due to the finite basis of the proof system and the fact that M contains a contradiction-free subset). This argument requires:
1. Showing `iter_F n phi ∉ M` for `n > |formula_closure(phi)|` or similar
2. Or using consistency directly: `iter_F n phi ∈ M` and `(iter_F n phi).neg ∈ M` is impossible, and one of them must be absent.

The cleanest route: MCS contains either `iter_F n phi` or its negation. Assume all `iter_F n phi ∈ M`. By `temp_4` applied repeatedly, `iter_F n phi ∈ M` implies `iter_F (n+1) phi ∈ M` when `iter_F 1 phi ∈ M`... wait, that's the WRONG direction — we need it to stop, not go forever.

Actually, `iter_F n phi ∈ M` does NOT imply `iter_F (n+1) phi ∈ M` in general. So the boundary exists simply because MCS doesn't force upward closure of F-chains. The right argument: by temp_4, `F(phi) → FF(phi)` is a theorem, so `F(phi) ∈ M → FF(phi) ∈ M`. This means the sequence is UPWARD CLOSED in M! But then: if `F^k phi ∈ M` for all k, we need M to contain every `F^n phi`, which... could still be consistent (like the countable MCS over an infinite model).

**Conclusion**: The nesting boundary CANNOT be proven by MCS consistency alone. It requires additional structure about the CANONICAL nature of M — specifically, that M is constructed from a finite formula closure, so the chain must be bounded by the closure depth. This is the "filtration" argument.

For the canonical M with M0 as base: M0 is built from `{neg(phi)}` plus the Lindenbaum extension. The Lindenbaum process doesn't bound formula depth. So `f_nesting_boundary` may genuinely require the **temporal filtration** argument or a different canonical construction.

**Recommendation**: Keep `f_nesting_boundary` and `p_nesting_boundary` as axioms for now, as they are semantically justified but require deep filtration theory to prove formally.

---

## Recommendations for Teammate A's Analysis

### Item 1: `f_nesting_boundary` (axiom at SuccChainFMCS.lean:583)
- **Pattern to use**: `Nat.find` with predicate `p n := iter_F (n+1) phi ∉ M`
- **Missing piece**: Proof that `∃ n, p n` — this requires temporal filtration or a finiteness argument about MCS closure
- **Difficulty**: High — needs careful semantic argument about why F-chains must terminate in a consistent set built from finite axioms
- **Confidence**: Medium — axiom is justified but formal proof requires non-trivial infrastructure

### Item 2: `p_nesting_boundary` (axiom at SuccChainFMCS.lean:695)
- **Pattern**: Exact symmetric to `f_nesting_boundary` using `iter_P` and `neg_PP_implies_HH_neg_in_mcs`
- **Difficulty**: Same as `f_nesting_boundary`
- **Confidence**: Medium

### Item 3: `succ_chain_fam_p_step` (axiom at SuccChainFMCS.lean:335)
- **Pattern**: For backward chain: `backward_chain_p_step` (already proven at line 264) suffices. For forward chain: needs P-step from `successor_from_deferral_seed` structure.
- **Alternative**: The forward chain P-step can be derived if `succ_chain_fam_succ` already gives Succ, and we add: "for Succ pairs in succ_chain_fam, P-step holds." This requires analyzing `successorDeferralSeed` for P-step properties.
- **Difficulty**: Medium — the backward chain part is clear; forward chain part needs work
- **Confidence**: Medium-High

### Item 4: Box backward sorry (`SuccChainTruth.lean:254`)
- As noted in the file comment (lines 33-35): "For COMPLETENESS we only need the FORWARD direction." The sorry is explicitly documented as not needed.
- **Recommendation**: Add a `-- not needed for completeness` annotation and skip, OR prove it requires modal coherence (BFMCS structure) which is out of scope.
- **Confidence**: HIGH — can be left as documented sorry

### Item 5: Contraction sorry (`SuccChainCompleteness.lean:109`)
- **Tool**: `derivation_exchange` at `MCSProperties.lean:61`
- **Approach**: `contextAsSet L = contextAsSet [φ.neg]` when all elements of L equal `φ.neg`. Since `SetConsistent {φ.neg}` quantifies over lists-as-sets, and any list of `φ.neg` repetitions has the same set-image `{φ.neg}`, the argument should use `list_consistent_to_set_consistent` and the fact that `L ⊆ {φ.neg}` as a SET.
- **Code path**: `h_ctx_cons : ContextConsistent [φ.neg]` gives `¬∃ d : [φ.neg] ⊢ ⊥`. For the sorry: `h : L ⊢ bot` where all elements of L are `φ.neg`. Construct `d' : [φ.neg] ⊢ bot` via `derivation_exchange d (fun x => ...)`.
- **Difficulty**: Low — direct use of `derivation_exchange`
- **Confidence**: HIGH

### Item 6: `backward_witness` sorry (`CanonicalTaskRelation.lean:785`)
- **Critical insight**: The chain direction confusion must be resolved first.
- **Best approach**: Use Alternative 2 (add `single_step_forcing_past_pstep` with explicit P-step), then the induction mirrors `bounded_witness` exactly.
- **Or**: Prove `tail_inv` for `CanonicalTask_backward_MCS_P` and restructure the induction.
- **Difficulty**: Medium — once direction confusion is resolved
- **Confidence**: High

### Item 7: `succ_propagates_P_not` sorry (`SuccRelation.lean:497`)
- This is in `single_step_forcing_past`. The proof sketch is complete (lines 336-496 give full outline). The sorry is at the P-step step (step 6-8).
- **Solution**: The function signature should require `h_p_step : p_content v ⊆ u ∪ p_content u` as an explicit parameter. This parameter is always available in the call sites (backward chain has P-step by `predecessor_satisfies_p_step`; forward chain has it via `succ_chain_fam_p_step`).
- **Alternatively**: Use `succ_chain_fam_p_step` directly in the theorem signature.
- **Difficulty**: Low if P-step is a parameter; Medium if it must be derived from `Succ u v` alone
- **Confidence**: HIGH (with explicit P-step parameter)

---

## Confidence Assessment

| Item | Approach Confidence | Difficulty |
|------|--------------------|-----------|
| `f_nesting_boundary` | Medium — needs filtration argument | High |
| `p_nesting_boundary` | Medium — symmetric to above | High |
| `succ_chain_fam_p_step` | Medium-High — backward clear, forward needs work | Medium |
| Box backward | High — documented as not needed | Low |
| Contraction | High — `derivation_exchange` is the tool | Low |
| `backward_witness` | High — once direction fixed | Medium |
| `succ_propagates_P_not` | High — explicit P-step parameter | Low-Medium |

**Overall**: Items 4, 5, 7 are most tractable (documented approach, clear tools). Items 1, 2 are hardest (need filtration theory). Item 3 is medium. Item 6 needs direction fix first, then is tractable.

---

## Key Files for Reference

| File | Line | What |
|------|------|------|
| `Theories/Bimodal/Metalogic/Bundle/CanonicalTaskRelation.lean` | 541 | `bounded_witness` (F-direction template) |
| `Theories/Bimodal/Metalogic/Bundle/CanonicalTaskRelation.lean` | 496 | `succ_propagates_F_not` (F-direction template) |
| `Theories/Bimodal/Metalogic/Bundle/CanonicalTaskRelation.lean` | 665 | `succ_propagates_P_not` (already proven) |
| `Theories/Bimodal/Metalogic/Bundle/SuccRelation.lean` | 354 | `single_step_forcing_past` (has sorry at 497) |
| `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean` | 573 | `predecessor_satisfies_p_step` (P-step proven) |
| `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` | 638 | `succ_chain_forward_F` (nesting boundary usage) |
| `Theories/Bimodal/Metalogic/Core/MCSProperties.lean` | 61 | `derivation_exchange` (contraction tool) |
| `Theories/Bimodal/Syntax/Formula.lean` | 92 | `Formula.complexity` (depth measure) |
