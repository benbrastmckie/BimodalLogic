# Omega-Chain Construction Internals: succ_cofinal Gap Elimination

**Task**: 155 (reynolds_pipeline_activation)
**Date**: 2026-05-22
**Focus**: Construction-level infrastructure for closing succ_cofinal Step 9

---

## 1. Available Lean Infrastructure

### Construction Definitions
| Name | Location | Signature |
|------|----------|-----------|
| `omega_chain` | ChronicleConstruction.lean:253 | `Nat → { χ : Chronicle // χ.c0 ∧ χ.c2' }` |
| `omega_chain_val` | :265 | `Nat → Chronicle` (extract chronicle at stage n) |
| `omega_chain_elim_result` | :286 | `EliminationResult` at stage n |
| `limit_dom` | :551 | `{ x : ℚ \| ∃ n, x ∈ omega_chain_val(n).dom }` |
| `limit_f` | :560 | MCS assignment: `ℚ → Set Formula` |
| `limitDomSubtype_succ` | ChronicleToCountermodel.lean:882 | Successor on limit domain (discrete case) |
| `limitDomSubtype_pred` | (nearby) | Predecessor on limit domain |

### Resolution Lemmas
| Name | Location | Statement |
|------|----------|-----------|
| `limit_F_resolution` | ChronicleConstruction.lean:689 | F(φ) ∈ f(x) → ∃ y > x, φ ∈ f(y) |
| `limit_P_resolution` | :710 | P(φ) ∈ f(x) → ∃ y < x, φ ∈ f(y) |
| `limit_satisfies_c5_strong` | (nearby) | U(η,ξ) ∈ f(x) → ∃ y > x, η ∈ f(y), ξ at intermediates |
| `limit_satisfies_c5'_strong` | (nearby) | S(η,ξ) ∈ f(x) → ∃ y < x, η ∈ f(y), ξ at intermediates |
| `limit_satisfies_c4` | (nearby) | ¬U(η,ξ) ∈ f(x), η ∈ f(y) → ∃ z between, ¬ξ ∈ f(z) |

### Truth Transfer (Available at Sorry Site)
| Name | Statement |
|------|-----------|
| `backward_G` | ψ ∈ f(y) for ALL y > x → G(ψ) ∈ f(x) |
| `backward_F` | φ ∈ f(y) for SOME y > x → F(φ) ∈ f(x) |
| `backward_P` | φ ∈ f(y) for SOME y < x → P(φ) ∈ f(x) |
| `orbit_below_L` | domain points below L (real value) are orbit points |
| `h_lt_pred_chain` | all orbit < all pred-chain elements |
| `h_pred_chain_ge_L` | pred-chain real values ≥ L |
| `h_discrete` | U(⊤,⊥) ∈ f(x) for all x (immediate successor exists) |

### Axioms Available (in every MCS via theorem_in_mcs)
| Axiom | Statement | Effect |
|-------|-----------|--------|
| `Prior-UZ` | F(φ) → U(φ, ¬φ) | Nearest-future: if φ eventually, ¬φ at intermediates up to first φ |
| `Prior-SZ` | P(φ) → S(φ, ¬φ) | Past dual |

## 2. The Gap Scenario

When succ_cofinal fails (the sorry case): orbit `{s^n(a)}` converges to real value L from below, pred-chain `{p^k(pb)}` has values ≥ L from above. No domain point at L.

Key structural facts:
- Between consecutive orbit points `s^n(a)` and `s^{n+1}(a)`: NO other domain points (immediate successor property from h_discrete + c5_strong)
- Between consecutive pred-chain points `p^{k+1}(pb)` and `p^k(pb)`: NO other domain points (immediate predecessor property)
- The gap at L: orbit {val < L} has no max; pred-chain {val ≥ L} forms a descending sequence to L

## 3. Burgess A7a — NOT Available

Burgess 1984 (p.31) proves gap elimination for COMPLETE orders using axiom A7a:
```
A7a: Fp ∧ FG(¬p) → F(HFp ∧ G(¬p))
```
This axiom is for complete/continuous orders (class ℱ₇). It is NOT in our axiom set (we have Prior-UZ for discrete orders, not A7a for complete orders). The Burgess gap lemma does NOT apply.

## 4. Constant-MCS Analysis

### Why Temporal Axioms Fail

In the **constant-MCS case** (all domain points have identical MCS B):
- F(φ) ∈ B ↔ φ ∈ B (future witnesses always exist with same MCS)
- G(φ) ∈ B ↔ φ ∈ B (same reasoning)
- U(φ, ψ) ∈ B iff ψ ∈ B (witness exists at next point with same MCS)
- Prior-UZ: F(φ) → U(φ, ¬φ). With constant MCS: if φ ∈ B then F(φ) ∈ B, and U(φ, ¬φ) requires ¬φ ∈ B. But ¬φ ∉ B if φ ∈ B. So Prior-UZ gives: if φ ∈ B then ¬φ ∈ B — contradiction. So if φ ∈ B then F(φ) ∉ B? No: F(φ) = ¬G(¬φ). G(¬φ) ∈ B ↔ ¬φ ∈ B. If φ ∈ B: ¬φ ∉ B, so G(¬φ) ∉ B, so F(φ) = ¬G(¬φ) ∈ B. Then Prior-UZ: F(φ) → U(φ, ¬φ) ∈ B. And U(φ, ¬φ) requires witness y with ¬φ(y) and φ at intermediates. With constant MCS: ¬φ(y) means ¬φ ∈ B, but φ ∈ B and ¬φ ∉ B. Contradiction!

**KEY INSIGHT**: The constant-MCS case with φ ∈ B and ¬φ ∉ B makes U(φ, ¬φ) UNSATISFIABLE. But Prior-UZ says F(φ) → U(φ, ¬φ) ∈ B, and F(φ) ∈ B. So U(φ, ¬φ) ∈ B. But U(φ, ¬φ) requires a witness with ¬φ, and no such witness exists in the constant-MCS model. This means the limit construction's c5_strong resolution for U(φ, ¬φ) at orbit points MUST add a point with ¬φ, which has a DIFFERENT MCS from B.

**Therefore**: The constant-MCS case CANNOT arise in the limit construction when φ ∈ B and ¬φ ∉ B for some φ. Since B is an MCS (contains either φ or ¬φ for every φ, and contains at least one non-trivial formula like the negation of the input formula), there always exists such a φ.

### The Non-Constant-MCS Consequence

If the MCSs are NOT constant across orbit + pred-chain: there exists a discriminating formula φ₀ (φ₀ ∈ f(orbit_point) but φ₀ ∉ f(pred_chain_point), or vice versa). Use this to derive a contradiction via backward_G/F and limit_F_resolution:

1. φ₀ ∈ f(x) for orbit point x, φ₀ ∉ f(z) for pred-chain point z
2. By backward_G: if φ₀ held at ALL points above x, then G(φ₀) ∈ f(x). But φ₀ ∉ f(z), so G(φ₀) ∉ f(x). So ¬G(φ₀) = F(¬φ₀) ∈ f(x).
3. By Prior-UZ: U(¬φ₀, ¬(¬φ₀)) = U(¬φ₀, φ₀) ∈ f(x).
4. By c5_strong: ∃ y > x with φ₀(y) and ¬φ₀ at intermediates.
5. Since ¬φ₀ at all intermediates between x and y: all orbit points between x and y have ¬φ₀. But x has φ₀. So y > succ(x) = next orbit point (which has ¬φ₀). 
6. If y is below L: y is an orbit point with φ₀. But ¬φ₀ at all intermediates — so there are orbit points between x and y with ¬φ₀, and y has φ₀. This is fine (φ₀ alternates among orbit points).
7. If y is above L: y is a point where φ₀ holds. Need: some z between orbit and y (above L) with ¬φ₀. This z would fill the gap.

This doesn't immediately close the gap. But it shows the MCSs MUST vary.

## 5. Proposed Strategy: Prior-UZ Contradiction

**Claim**: The constant-MCS gap scenario is impossible due to Prior-UZ.

**Proof sketch**:
1. Assume constant MCS B at all domain points in [a, pb].
2. B is an MCS, so ∃ φ with φ ∈ B (take any atom or its negation).
3. F(φ) ∈ B (future witnesses exist with same MCS, so φ holds at them).
4. Prior-UZ: U(φ, ¬φ) ∈ B.
5. c5_strong resolves U(φ, ¬φ) at orbit point x: ∃ y > x with ¬φ ∈ f(y).
6. But f(y) = B (constant MCS). So ¬φ ∈ B.
7. But φ ∈ B and ¬φ ∈ B → B is inconsistent. Contradiction with B being an MCS.

**Wait**: Step 5 uses c5_strong which gives ¬φ ∈ f(y). But in the constant-MCS case, f(y) = B, so ¬φ ∈ B. Combined with φ ∈ B: B is inconsistent. But B is an MCS (consistent by definition).

**This IS the contradiction!** The constant-MCS case is impossible because Prior-UZ + c5_strong force both φ and ¬φ into the same MCS.

## 6. Implementation Plan

1. Show constant-MCS is impossible via Prior-UZ contradiction (~30-50 lines):
   - Pick any φ (e.g., some atom in the input formula)
   - F(φ) ∈ B → U(φ, ¬φ) ∈ B → c5_strong gives ¬φ ∈ B → inconsistency

2. With non-constant MCS, find discriminating formula φ₀ between orbit and pred-chain (~20-30 lines):
   - ∃ orbit point x, pred-chain point z: f(x) ≠ f(z)
   - Extract φ₀ ∈ f(x) \ f(z) or φ₀ ∈ f(z) \ f(x)

3. Use backward_G/F + Prior-UZ + c5_strong to derive contradiction (~100-200 lines):
   - Apply U(φ₀, ¬φ₀) resolution; witness must cross the gap
   - Show the witness location contradicts orbit_below_L or pred-chain structure

**Total estimate**: 150-280 lines.

**Key risk**: Step 3 might be more subtle than sketched. The U(φ₀, ¬φ₀) witness y could be on the same side of the gap as x, not crossing it. Need careful case analysis.

## 7. Summary

| Finding | Detail |
|---------|--------|
| Burgess A7a | NOT available (for complete orders, not discrete) |
| Prior-UZ | Available and is the key tool |
| Constant-MCS | IMPOSSIBLE: Prior-UZ forces φ ∧ ¬φ via c5_strong |
| Non-constant case | Has discriminating formula; needs case analysis |
| F-resolution | Exists: `limit_F_resolution` gives future witnesses |
| Construction level | Needed only for non-constant case witness location |
| **Estimate** | 150-280 lines |
