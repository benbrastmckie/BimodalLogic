# Teammate A Findings: Primary Implementation Approach

**Task**: 117 — Remove Cantor isomorphism and build countermodel on limit domain
**Date**: 2026-05-08
**Focus**: Primary approach analysis — type constraints, architecture, and feasibility

## Key Findings

### 1. Type Constraint Chain: AddCommGroup is the Blocker

The parametric infrastructure requires `D` to satisfy:
- `AddCommGroup D` — from `ParametricCanonicalTaskFrame` (`ParametricCanonical.lean:198`)
- `LinearOrder D` — from `ParametricCanonicalTaskFrame` and `FMCS D`
- `IsOrderedAddMonoid D` — from `ParametricCanonicalTaskFrame`
- `Nontrivial D` — from the existential in `dd_countermodel_chronicle` (`ChronicleToCountermodel.lean:684`)

**`FMCS D` and `BFMCS D` only need `[Preorder D]`** (`FMCSDef.lean:77`, `BFMCS.lean:53`). The heavy constraints come from the parametric canonical frame and truth lemma.

**`LimitDomSubtype A h_mcs = {q : Rat // q ∈ limit_dom A h_mcs}`** naturally has `LinearOrder` (inherited from Rat), `Countable`, `NoMinOrder`, `NoMaxOrder`, and `Nonempty` — all sorry-free.

**Critical problem**: `LimitDomSubtype` does NOT naturally have `AddCommGroup`. The sum of two elements in `limit_dom` is not guaranteed to be in `limit_dom`. The `ParametricCanonicalTaskFrame` construction uses duration arithmetic (`d - s`, `t + d`) pervasively, so removing the `AddCommGroup` constraint would require rewriting the entire parametric canonical frame infrastructure, which is a massive change affecting many files.

### 2. The Cantor Isomorphism's Role

The Cantor iso serves one critical purpose: it maps `LimitDomSubtype` (which lacks `AddCommGroup`) to `Rat` (which has `AddCommGroup`), making the parametric infrastructure applicable. The iso preserves order, so temporal coherence properties transfer.

Without the iso, we need `AddCommGroup` on the domain type, which `LimitDomSubtype` cannot provide.

### 3. Alternative: Keep D = Rat, Redefine the FMCS Directly

Instead of changing `D` from `Rat` to `LimitDomSubtype`, we can keep `D = Rat` but redefine how the FMCS is constructed:

**Current approach**: `cantor_fmcs` defines `mcs(q) = limit_f(cantor_iso.symm(q).val)` — uses Cantor iso to make every rational a domain point.

**Alternative**: Define `limit_fmcs` with `mcs(q) = limit_f(nearest_dom_point(q))` for non-domain rationals. But this requires proving forward_G/backward_H for these extended points, which is non-trivial.

**Actually, the current FMCS already works this way** for forward_G/backward_H — the Cantor iso just provides a cleaner mapping. The real value of the Cantor iso is in the Until/Since coherence proofs.

### 4. Guard Condition: The Core Semantic Insight

The guard condition in `restricted_forward_until_since_coherent` (`TemporalCoherence.lean:535-544`) is:
```
∀ r : D, t < r → r < s → ψ ∈ fam.mcs r
```

When `D = Rat` (current): this quantifies over ALL rationals between `t` and `s`, including non-domain rationals. The FMCS must assign proper MCS values to these points, and the guard must hold there.

When `D = LimitDomSubtype` (proposed): this quantifies only over domain points between `t` and `s`. The guard exactly matches `limit_g`:
```
limit_g(x,z) = {φ | ∀ y ∈ limit_dom, x < y → y < z → φ ∈ limit_f(y)}
```

This is the semantic insight: on `LimitDomSubtype`, the guard condition is automatically correct by definition of `limit_g`. No extension to non-domain points needed.

### 5. The DenselyOrdered → Sorry Chain

The chain from sorry to `DenselyOrdered`:
1. `limitDomSubtype_denselyOrdered` (`ChronicleToCountermodel.lean:98-106`) uses `limit_dom_dense`
2. `limit_dom_dense` (`ChronicleConstruction.lean:746-778`) is sorry-free itself
3. But `limit_dom_dense` is used in the density case of `eliminate_potential_counterexample` at CE:3535
4. The density case at CE:3535 needs `SetConsistent (χ.g pc.x pc.y)` at CE:3561 (the sorry at CE:3570)
5. `DenselyOrdered` is required by `cantor_iso` at `ChronicleToCountermodel.lean:189-192` via `Order.iso_of_countable_dense`

**If we remove `cantor_iso`, we don't need `DenselyOrdered`, which means `limit_dom_dense` is unused, which means the density counterexample kind is unnecessary, which means the sorry at CE:3570 is unreachable.**

BUT: the density case is part of the `PotentialCounterexampleKind` enum (CE:570-576) and the `EliminationResult` structure (CE:638-640). Removing it requires modifying these types and all their constructors throughout CE (3783 lines).

### 6. Feasibility Assessment for `D = LimitDomSubtype`

To make `D = LimitDomSubtype` work, we need `AddCommGroup (LimitDomSubtype A h_mcs)`, which requires:
- `Add`: `a + b` where both `a.val` and `b.val` are in `limit_dom` — need `a.val + b.val ∈ limit_dom` (NOT true in general)
- `Neg`: `-a` where `a.val ∈ limit_dom` — need `-a.val ∈ limit_dom` (NOT true in general)
- `Zero`: `0 ∈ limit_dom` — TRUE (from `zero_mem_limit_dom`)

**This is not achievable** without artificially closing `limit_dom` under addition and negation, which would fundamentally change the construction and require re-proving all chronicle properties.

## Recommended Approach

**Do NOT try to make `D = LimitDomSubtype` directly.** The `AddCommGroup` constraint from the parametric infrastructure is a hard blocker.

Instead, consider one of these approaches:

### Option A: Refactor the Parametric Infrastructure (Large)
Remove the `AddCommGroup` requirement from `ParametricCanonicalTaskFrame` and the truth lemma. This requires redesigning how durations/shifts work throughout the parametric layer. Very invasive but conceptually clean.

### Option B: Construct AddCommGroup on a New Domain (Medium)
Build a domain type that IS an `AddCommGroup` but avoids the `DenselyOrdered` requirement. For example:
- Use `D = Rat` but define the FMCS without the Cantor iso
- Extend `limit_f` to all of Rat using g-content or some MCS extension
- Prove coherence directly on this extension

The challenge: proving Until/Since guard conditions for non-domain rationals.

### Option C: Remove Density from CE, Keep Cantor Iso (Smallest)
Instead of removing the Cantor iso, remove the `density` case from `PotentialCounterexampleKind`. If the chronicle construction never inserts density points, then `DenselyOrdered` on `LimitDomSubtype` is vacuously true (or not needed), and the sorry disappears.

**Wait**: This won't work because `DenselyOrdered` is needed for `cantor_iso` regardless of whether density points are inserted. The `Order.iso_of_countable_dense` theorem requires the source type to be `DenselyOrdered`.

### Option D: Build BFMCS Directly on LimitDomSubtype Without Parametric Layer (Medium-Large)
Bypass the parametric canonical frame entirely. Build a `TaskFrame` and `TaskModel` directly on `LimitDomSubtype` without requiring `AddCommGroup`. This requires:
1. A custom `TaskFrame (LimitDomSubtype A h_mcs)` 
2. A custom `TaskModel` 
3. A custom truth lemma (or showing the existing one generalizes)

**This is potentially the right approach** but requires understanding what the `TaskFrame` actually needs.

## Evidence/Examples

| File | Line | Relevance |
|------|------|-----------|
| `ParametricCanonical.lean` | 198 | `AddCommGroup D` required |
| `RestrictedParametricTruthLemma.lean` | 37 | `AddCommGroup D` required |
| `FMCSDef.lean` | 77 | `FMCS D` only needs `Preorder D` |
| `BFMCS.lean` | 53 | `BFMCS D` only needs `Preorder D` |
| `ChronicleToCountermodel.lean` | 82-84 | `LimitDomSubtype` definition |
| `ChronicleToCountermodel.lean` | 189-192 | `cantor_iso` requires `DenselyOrdered` |
| `ChronicleToCountermodel.lean` | 684-688 | `dd_countermodel_chronicle` existential needs `AddCommGroup`, `LinearOrder`, etc. |
| `CounterexampleElimination.lean` | 570-576 | `PotentialCounterexampleKind` enum with `.density` |
| `CounterexampleElimination.lean` | 3570 | The sorry: `SetConsistent (χ.g pc.x pc.y)` |
| `ChronicleConstruction.lean` | 884-887 | `limit_g` definition matches guard condition exactly |
| `TemporalCoherence.lean` | 535-544 | Guard condition: `∀ r : D, t < r → r < s → ...` |

## Confidence Level

**High** on the analysis of type constraints and the `AddCommGroup` blocker.

**Medium** on the recommended approach — Option D (bypass parametric layer) is promising but needs investigation of `TaskFrame` requirements.

**Key uncertainty**: Whether `TaskFrame` and `TaskModel` can be constructed without `AddCommGroup`, or whether `AddCommGroup` is architecturally fundamental to the semantics. The `TaskFrame` definition needs to be examined to determine this.
