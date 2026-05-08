# Teammate B Findings: Alternative Approaches

**Task**: 117 — Remove Cantor isomorphism, build countermodel on limit domain
**Focus**: Alternative approaches to eliminate the sorry at CE:3570
**Date**: 2026-05-08

## Key Findings

### 1. The sorry (`SetConsistent (χ.g pc.x pc.y)`) is UNPROVABLE in the current architecture

The sorry at `CounterexampleElimination.lean:3570` asks to prove that g-values in the omega chain are consistent (`SetConsistent`). However, g-values are constructed via `burgessR3Maximal_extension_exists` (`RRelation.lean:760-789`), which uses Zorn's lemma over `ClosedUnderDerivation` sets — NOT over `SetConsistent` sets.

`ClosedUnderDerivation` is strictly weaker than `SetConsistent`:
- CUD: closed under derivation (modus ponens), possibly inconsistent  
- SDC: CUD + consistent

The codebase explicitly acknowledges this at `ChronicleTypes.lean:356`: "The resulting B may or may not be consistent; at finite stages g-values can be Set.univ (inconsistent)."

**Conclusion**: Alternative 1 (prove the sorry directly) is NOT viable. The Zorn construction genuinely does not guarantee consistency of g-values. Threading `SetConsistent` through would require a fundamentally different Zorn construction over SDC sets, which is a substantial change with unclear downstream effects.

### 2. Using a different dense countable order is irrelevant

Alternative 2 fails because the problem is not "which dense order to map to" — the problem is that `DenselyOrdered` on `LimitDomSubtype` requires proving density of `limit_dom`, which requires the density case in `CounterexampleElimination`, which requires `SetConsistent g`. Any order isomorphic to `Rat` would face the same dependency chain. The Cantor isomorphism is a red herring; density itself is the problem.

### 3. `limit_dom_dense` is provable but depends on the sorry

`limit_dom_dense` (`ChronicleConstruction.lean:746-749`) works by appealing to the omega chain's density enumeration. The density case at CE:3535-3570 inserts midpoints between adjacent pairs. This insertion uses `lemma_2_6_splitting`, which requires `∃ β, β ∉ χ.g pc.x pc.y` — obtained via `BurgessR3Maximal_bot_not_mem` which needs `SetConsistent (χ.g pc.x pc.y)`.

There is no alternative path to density that avoids this sorry. The density of `limit_dom` IS the density insertion, and the density insertion IS the sorry.

### 4. The parametric truth lemma does NOT require DenselyOrdered — THIS IS THE KEY INSIGHT

The entire parametric infrastructure (`RestrictedParametricTruthLemma.lean:37`, `ParametricRepresentation.lean:96`) requires only:
- `AddCommGroup D`
- `LinearOrder D`  
- `IsOrderedAddMonoid D`

No `DenselyOrdered` anywhere in the truth lemma or representation theorem. The Cantor iso exists purely to make `BFMCS Rat` — giving every rational a meaning. But this is unnecessary: if we could build `BFMCS D` for ANY suitable `D`, the truth lemma works.

**However**, `LimitDomSubtype` cannot serve as `D` directly because it's not an `AddCommGroup` — addition of two limit_dom elements doesn't stay in limit_dom. The `time_shift` operation in `WorldHistory` (`WorldHistory.lean:238`) adds `Δ : D` to time points, and `ShiftClosed` requires the shifted histories to stay in `Omega`.

### 5. The correct approach: build FMCS/BFMCS directly over Rat WITHOUT the Cantor iso

The FMCS structure (`FMCSDef.lean:99`) only needs `mcs : D → Set Formula` with `forward_G` and `backward_H`. For `D = Rat`:
- Define `mcs(q) = limit_f(closest domain point to q)` or use the limit_g-based extension
- `forward_G` and `backward_H` work via `limit_satisfies_c5_strong` on domain points
- Non-domain points get MCS values via Lindenbaum extension of g_content

The current `cantor_f` already does something similar: `cantor_f(q) = limit_f(cantor_iso.symm(q).val)` — mapping every rational to a domain point. Without the iso, we need to assign MCS values to non-domain rationals directly.

The existing `limit_g` definition (`ChronicleConstruction.lean:884-887`) already handles this: `limit_g(x,z) = {φ | ∀ y ∈ limit_dom, x < y → y < z → φ ∈ limit_f(y)}`. For gaps where no `y` exists between x and z, this is `Set.univ` — and the truth lemma handles this vacuously.

## Alternative Approaches Analysis

| Alternative | Viable? | Effort | Risk |
|------------|---------|--------|------|
| 1. Prove sorry directly | **No** | N/A | Zorn doesn't guarantee consistency |
| 2. Different dense order | **No** | N/A | Same dependency chain |
| 3. Prove density differently | **No** | N/A | Density IS the sorry |
| 4. Build on LimitDomSubtype | **No** | N/A | Not an AddCommGroup |
| 5. Build FMCS Rat without Cantor iso | **Yes** | Medium | Need Lindenbaum extension for non-domain points |

### Recommended approach (convergent with primary approach)

Build `FMCS Rat` directly by:
1. For domain points: use `limit_f` (already sorry-free)
2. For non-domain points: use Lindenbaum extension of `limit_g` content
3. Prove `forward_G`/`backward_H` using limit chronicle properties
4. Density is irrelevant — non-domain rationals get MCS values from Lindenbaum
5. The density case in `eliminate_potential_counterexample` becomes DEAD CODE

The density case (CE:3535-3670) is only needed to establish `limit_dom_dense`, which is only needed for `DenselyOrdered LimitDomSubtype`, which is only needed for `cantor_iso`. Removing the Cantor iso makes the entire density elimination case dead code, and the sorry vanishes.

## Evidence/Examples

- `BurgessR3Maximal` defined at `ChronicleTypes.lean:358` — uses `ClosedUnderDerivation`, not `SetConsistent`
- Zorn construction at `RRelation.lean:760-789` — produces CUD, not SDC
- Acknowledgment at `ChronicleTypes.lean:356`: "g-values can be Set.univ (inconsistent)"
- Parametric truth lemma requires only `AddCommGroup D + LinearOrder D + IsOrderedAddMonoid D` (`RestrictedParametricTruthLemma.lean:37`)
- `limit_g` vacuously handles gaps: `ChronicleConstruction.lean:884-887`
- `valid` quantifies over all D: `Validity.lean:73-78` — countermodel just needs ANY suitable D
- `dd_countermodel_chronicle` currently returns `D = Rat`: `ChronicleToCountermodel.lean:684-689`

## Confidence Level

**High** — The analysis traces through concrete definitions and type signatures in the codebase. The unprovability of the sorry follows from the Zorn construction's type signature. The viability of the Cantor-free approach follows from the parametric truth lemma's type constraints (no DenselyOrdered needed).
