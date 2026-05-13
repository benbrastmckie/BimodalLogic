# Research Report: Four-Tier Frame Hierarchy with Extension Axioms

- **Task**: 126 - frame_hierarchy_dense_discrete_integer_extensions
- **Date**: 2026-05-13
- **Session**: sess_1778657762_d3e9ec
- **Type**: Research — frame correspondence and axiom classification

## Executive Summary

The codebase currently has a three-way FrameClass enum (Base/Dense/Discrete) but no dense-specific or discrete-specific extension axioms — density and discreteness are detected from the MCS at completeness time via `next_top = U(⊤, ⊥)`. This report establishes the theoretical basis for a proper four-tier hierarchy where each extension adds axioms that characterize frame constraints via Sahlqvist-style correspondence.

## 1. Frame Correspondence Theory

### Tier 1a — Density Axiom: `GGp → Gp`

**Claim**: `GGp → Gp` is valid on a strict linear frame `(D, <)` if and only if `D` is DenselyOrdered.

**Proof (⇐, soundness)**: Suppose `D` is dense. Let `GGp` hold at `x`, meaning `p` at all `z > y` for all `y > x`. For any `y > x`, since `D` is dense, there exists `w` with `x < w < y`. Then `w > x`, so `Gp` at `w` (from `GGp` at `x`), which gives `p` at `y` (since `y > w`). So `p` at all `y > x`, i.e., `Gp` at `x`.

**Proof (⇒, correspondence)**: Suppose `D` is NOT dense. Then there exist adjacent `x < y` with no `z` satisfying `x < z < y`. Define valuation: `p` true at `t` iff `t > x` and `t ≠ y` (equivalently, `t > y` since no points between `x` and `y`). Wait — more carefully: `p` false at `y`, true at all `t > y`. Then at `x`: `Gp` requires `p` at all `t > x`. But `p` is false at `y` (the immediate successor of `x`), so `Gp` is false at `x`. And `GGp` at `x`: for all `t > x`, `Gp` at `t`. At `t = y`: `Gp` at `y` means `p` at all `s > y`, which is true. At `t > y`: `Gp` at `t` means `p` at all `s > t`, true (all such `s > y`). So `GGp` at `x` is true but `Gp` at `x` is false. `GGp → Gp` fails.

**Past dual**: `HHp → Hp` characterizes density for the past direction. Same argument mirrored.

**Codebase note**: Under strict semantics, `GGp` at `x` means `∀ y > x, ∀ z > y, p(z)`, which is equivalent to `∀ z > x, (∃ y, x < y < z) → p(z)` plus `p(z)` for all `z` that are immediate successors of `x`. On dense orders, every `z > x` has a `y` between, so this reduces to `∀ z > x, p(z) = Gp`. On discrete orders, `z = succ(x)` has no intermediate `y`, so `GGp` skips `succ(x)`.

### Tier 1b — Discreteness Axiom: `U(⊤, ⊥)` (next_top)

**Claim**: `next_top = U(⊤, ⊥)` is valid at point `x` iff `x` has an immediate successor.

**Proof**: Under Burgess convention `untl(event, guard)`: `U(⊤, ⊥)` at `x` means `∃ y > x` with `⊤` at `y` (trivial) and `⊥` at all `z` with `x < z < y` (no intermediate points). So `U(⊤, ⊥)` is true iff there exists `y > x` with no points strictly between `x` and `y` — i.e., `y` is the immediate successor of `x`.

**Frame-level**: `∀ x, U(⊤, ⊥)` valid at `x` iff every point has an immediate successor, i.e., the frame has a SuccOrder.

**Past dual**: `S(⊤, ⊥)` characterizes "every point has an immediate predecessor" (PredOrder).

**Codebase note**: `next_top` is already defined and used in the codebase for the discrete branch detection. The formula `□(next_top)` = "all S5-worlds have immediate successors" is the current case-split criterion in `bx_completeness`.

### Tier 2 — Integer Axioms: Prior-UZ + Z1

**Prior-UZ**: `F(φ) → U(φ, ¬φ)`. Under Burgess convention: if `φ` holds somewhere in the future, then there is a nearest future `φ`-point with `¬φ` at all intermediates. Valid iff every non-empty definable future set has a least element — characterizes upward well-ordering of definable sets, which is IsSuccArchimedean on discrete orders.

**Z1**: `G(Gφ→φ) → (FGφ→Gφ)`. Valid iff the frame is IsSuccArchimedean (no Z+Z gaps). The backward induction principle: if the "step-down" property holds at all future points and `φ` eventually always holds, then `φ` always holds.

**Combined**: Prior-UZ + Prior-SZ + Z1 characterize frames isomorphic to Z among discrete linear orders without endpoints. These are already `Axiom` constructors with `frameClass = .Discrete`.

### Mutual Exclusivity of Tiers 1a and 1b

Dense + discrete is inconsistent for nontrivial linear orders: if every point has an immediate successor (discrete) and between any two points there is a third (dense), then between `x` and `succ(x)` there exists `z`, contradicting `succ(x)` being the immediate successor. So `GGp → Gp` and `U(⊤, ⊥)` cannot both be valid on the same nontrivial frame.

## 2. Existing Codebase Infrastructure

### Current State

| Component | Location | Current | Needed |
|-----------|----------|---------|--------|
| `FrameClass` | Axioms.lean:407 | `.Base`, `.Dense`, `.Discrete` | Add `.Integer` |
| `Axiom.frameClass` | Axioms.lean:414 | Prior-UZ/SZ/Z1 → `.Discrete`, rest → `.Base` | Prior-UZ/SZ/Z1 → `.Integer`, density → `.Dense`, discreteness → `.Discrete` |
| `Axiom.isBase` | Axioms.lean:421 | Prior-UZ/SZ/Z1 → False | Same + density/discreteness → False |
| `Axiom.isDenseCompatible` | Axioms.lean:428 | Prior-UZ/SZ/Z1 → False | Same + discreteness → False |
| `Axiom.isDiscreteCompatible` | Axioms.lean:435 | All → True | density → False |
| `valid` | Validity.lean:73 | All linear orders | Unchanged (Tier 0) |
| `valid_dense` | Validity.lean:162 | DenselyOrdered | Unchanged (Tier 1a) |
| `valid_discrete` | Validity.lean:180 | SuccOrder + PredOrder + IsSuccArch + IsPredArch | **Split**: remove Archimedean for Tier 1b |
| `valid_integer` | — | Does not exist | **New**: Tier 2 with Archimedean |
| Soundness dispatch | Soundness.lean | 3 functions | 4 functions (add `axiom_valid_integer`) |
| Completeness | ChronicleToCountermodel.lean | 3-way split on `□(next_top)`/`□(¬next_top)` | Explicit 4-tier routing |

### New Axiom Constructors Needed

```lean
| density (φ : Formula) : Axiom (φ.all_future.all_future.imp φ.all_future)
| density_past (φ : Formula) : Axiom (φ.all_past.all_past.imp φ.all_past)
| discreteness : Axiom (Formula.untl Formula.top Formula.bot)
| discreteness_past : Axiom (Formula.snce Formula.top Formula.bot)
```

Note: `discreteness` may already be implicitly present as `next_top` is used in the codebase. The question is whether to make it an explicit `Axiom` constructor or treat it as a derived formula.

## 3. Literature References

- **Burgess 1982/1984**: Base temporal logic complete for all strict linear orders. No density or discreteness axioms in the base system.
- **van Benthem 1991**: Frame correspondence for temporal logic. `Gp → GGp` corresponds to transitivity (already built in); `GGp → Gp` corresponds to density.
- **Venema 1991**: Multi-dimensional modal logics. Frame correspondence for polyadic modalities including Until/Since.
- **Blackburn-de Rijke-Venema 2002, Section 4.3**: Sahlqvist correspondence theorem. `GGp → Gp` is a Sahlqvist formula, so correspondence is automatic. Section 7.2: completeness with Until/Since.
- **Goldblatt-Hodkinson-Venema 2003**: BAOs and canonical extensions. Frame correspondence via duality.
- **Reynolds 1994**: Axiomatisation of U and S over integer time. Prior-UZ characterizes well-ordered-upward definable sets.

## 4. Implementation Roadmap

### Phase 1: Add FrameClass.Integer and split valid_discrete (~100 lines)

- Add `.Integer` to `FrameClass` enum
- Create `valid_integer` by copying `valid_discrete` (keeps IsSuccArchimedean)
- Modify `valid_discrete` to remove IsSuccArchimedean/IsPredArchimedean (Tier 1b)
- Update `Axiom.frameClass`: Prior-UZ/SZ/Z1 → `.Integer`
- Add `Axiom.isIntegerOnly` predicate
- Update `isDiscreteCompatible` to return True for Integer axioms (since Integer ⊂ Discrete)

### Phase 2: Add density axiom constructors (~80 lines)

- Add `Axiom.density` and `Axiom.density_past` constructors
- Update `frameClass`, `isBase`, `isDenseCompatible`, `isDiscreteCompatible` for new constructors
- Prove soundness: `density_is_valid` using `DenselyOrdered.dense`
- Update pattern matches in `axiom_base_valid`, `axiom_valid_dense` (~4 sites)

### Phase 3: Add discreteness axiom constructors (~80 lines)

- Add `Axiom.discreteness` and `Axiom.discreteness_past` constructors (or formalize `next_top` as axiom)
- Update classification predicates
- Prove soundness: `discreteness_is_valid` using `SuccOrder.succ_le_iff`
- Update pattern matches (~4 sites)

### Phase 4: Update soundness dispatch (~120 lines)

- Create `axiom_valid_integer`: routes Integer-only axioms to their soundness proofs
- Update `axiom_valid_discrete`: now excludes Integer-only and Dense-only axioms
- Update `soundness_discrete` and create `soundness_integer`
- Prove `valid_discrete_implies_valid_integer` (containment)

### Phase 5: Frame correspondence proofs (~150 lines)

- `density_correspondence`: `GGp → Gp` valid on `(D, <)` ↔ `DenselyOrdered D`
- `discreteness_correspondence`: `U(⊤, ⊥)` valid at `x` ↔ `x` has immediate successor
- `prior_UZ_correspondence`: `F(φ) → U(φ, ¬φ)` valid on discrete `D` ↔ `IsSuccArchimedean D`
- `z1_correspondence`: `G(Gφ→φ)→(FGφ→Gφ)` valid on `D` ↔ `IsSuccArchimedean D`

### Phase 6: Update completeness routing (~100 lines)

- Update `bx_completeness` case split to reference axiom-level properties rather than formula detection
- The three-way split on `□(next_top)` / `□(¬next_top)` maps to: Dense extension → Q branch, Discrete extension → Z branch, Mixed → sorry
- Add `soundness_integer` and `completeness_integer` as the top-level results for Tier 2

**Total estimated effort**: 630 lines, ~15-25 hours

## 5. Risk Assessment

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Pattern match explosion when adding 4 new axiom constructors | M | H | Systematic: grep for `cases.*Axiom`, add arms. ~8 theorems × 4 constructors = 32 new match arms |
| `valid_discrete` (without Archimedean) breaks downstream | H | M | Careful: find all `valid_discrete` usage, update to `valid_integer` where Archimedean is needed |
| Density correspondence proof is subtle under strict semantics | L | L | Proof sketch verified above; the key insight is `succ(x)` is "skipped" by `GG` |
| Completeness for Tier 1b (discrete without integer) is new | M | M | Not required immediately — discrete completeness builds on Z which is already integer. The frame hierarchy is about classification, not new completeness results |
