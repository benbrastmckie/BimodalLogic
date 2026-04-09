# Teammate B Findings: Alternative Approaches to USF Completeness

**Task**: 86 — Close BXCanonical completeness sorries
**Date**: 2026-04-09
**Focus**: Alternative and unconventional approaches to close the sorry at CanonicalEmbedding.lean:418

## Key Findings

### 1. Sorry-Free FMP Completeness Already Exists

**This is the most significant finding.** The decidability module (`Theories/Bimodal/Metalogic/Decidability/`) is **entirely sorry-free** and provides:

```lean
-- Decidability/FMP/FMP.lean:206
theorem fmp_contrapositive (phi : Formula)
    (h_all_mcs : ∀ (S : ClosureMCSBundle phi), phi ∈ S.carrier) :
    Nonempty (DerivationTree [] phi)
```

This says: if φ is a member of every closure MCS (restricted to subformulaClosure φ), then φ is provable. The proof is sorry-free and goes through `mcs_finite_model_property` which constructs a finite countermodel from a non-provable formula.

**The gap to close**: We need `valid φ → ∀ (S : ClosureMCSBundle φ), φ ∈ S.carrier`. This requires showing that validity implies membership in every closure MCS — essentially a "restricted truth lemma" for closure MCS.

**Why this matters**: The closure MCS approach avoids the constant-history / dovetail-chain problem entirely. A closure MCS is NOT indexed by time — it's a single set of formulas restricted to the subformula closure. The truth lemma doesn't need temporal histories at all; it only needs to show that the MCS membership relation on the closure correctly reflects validity.

**Status assessment**: This route requires proving that for any closure MCS `S` (restricted MCS within the subformula closure), if φ is valid then φ ∈ S. The key challenge is that `valid` quantifies over ALL models, while `ClosureMCS` is a syntactic object. However, the closure MCS already has the MCS properties (negation completeness, closure under derivation) — the missing link is exactly the same as standard completeness. We'd need to show `valid φ → ⊢ φ` to conclude `φ ∈ S` (via `closed_under_derivation`), which is circular. So the FMP route provides `¬⊢ φ → ∃ S, φ ∉ S` but we still need the `valid φ → ⊢ φ` direction.

**Verdict**: The FMP gives us the `¬⊢ → ¬valid` direction (contrapositive), but ONLY if we can show "φ ∉ some closure MCS → φ not valid" (i.e., the closure MCS provides a countermodel). This is the Filtration Lemma (truth preservation), which is infrastructure-only in `TruthPreservation.lean` — the full proof requires modal/temporal MCS properties that haven't been completed.

### 2. Existing Completeness Modules: All Have Sorries or Gaps

| Module | Status | Gap |
|--------|--------|-----|
| `BaseCompleteness.lean` | Infrastructure only | No closed completeness theorem; re-exports truth lemma components |
| `DenseCompleteness.lean` | Infrastructure only | Domain mismatch (Int vs dense D); awaiting SuccChain |
| `DiscreteCompleteness.lean` | Infrastructure only | Blocked on SuccOrder/PredOrder for DiscreteTimelineQuot |
| `BXCanonical/Completeness.lean` | Sorry at line 153 | Full completeness needs G/H/U/S model construction |
| `Algebraic/` | Multiple sorries | DovetailedChain has X-vs-G mismatch; TenseS5Algebra has temp_a/temp_l sorries |

**No existing sorry-free completeness theorem can be composed with the sorry site.**

### 3. Conservative Extension Module: Not Applicable to USF

The `ConservativeExtension/` module provides:
- `ExtFormula` — extended formula type with fresh atom
- `embedFormula` / `unembedFormula` — embedding between Formula and ExtFormula
- `Lifting.lean` — substitution-based derivation projection

However, `ExtFormula` has **no Until/Since constructors** (it omits `untl`/`snce`). It also lacks G and H constructors — it only has `all_past` and `all_future`, which map directly. The conservative extension is designed for a different purpose (Goldblatt naming argument) and doesn't provide a completeness shortcut.

### 4. Proof-Theoretic Reduction: Flatten χ to temporal-free

The sorry comment mentions a "flatten(χ)" approach. The idea:

For a USF formula χ, define `flatten(χ)` by replacing every `G(α)` and `H(α)` with `α`:
- `flatten(G(α)) = flatten(α)`
- `flatten(H(α)) = flatten(α)`
- `flatten(ψ → χ) = flatten(ψ) → flatten(χ)`
- `flatten(□ψ) = □(flatten(ψ))`
- `flatten(atom p) = atom p`, `flatten(⊥) = ⊥`

**Key property**: `flatten(χ)` is temporal-free, so `fragment_truth_iff` applies.

**The reduction argument**: If `valid(ψ → χ)` then we want `⊢ (ψ → χ)`.
- From `valid(ψ → χ)` + BX1 (G(α) → α, H(α) → α), we can show `valid(flatten(ψ) → flatten(χ))`.
- Since `flatten(ψ → χ)` is temporal-free, `fragment_completeness` gives `⊢ flatten(ψ → χ)`.
- **The gap**: We need `⊢ flatten(ψ → χ) → ⊢ (ψ → χ)`. This would require:
  - `⊢ ψ → flatten(ψ)` (every formula implies its flattening) — TRUE by iterated BX1
  - `⊢ flatten(χ) → χ` (the flattening implies the original) — **FALSE in general**: `α` does not imply `G(α)`

So the flatten approach fails in the backward direction for χ: we can derive `flatten(χ) ∈ w` but not `χ ∈ w`. The comment at line 414 is exactly right.

### 5. Two-Point Model Construction

For USF formulas, G and H have simplified semantics: `G(α)` at time t means `α` holds at all times `≥ t`. On a two-point model `{t₀, t₁}` with `t₀ < t₁`:
- `G(α)` at `t₀` = `α` at `t₀` ∧ `α` at `t₁`
- `G(α)` at `t₁` = `α` at `t₁`
- `H(α)` at `t₀` = `α` at `t₀`
- `H(α)` at `t₁` = `α` at `t₀` ∧ `α` at `t₁`

This gives a non-trivial temporal structure, but the problem is we need TWO BXPoints (one for each time point), and the backward truth lemma requires G(α) ∈ w₁ to come from membership properties at BOTH points. The MCS at t₁ would need to contain all G-content of w₀, which is exactly the combined F-seed problem (Lindenbaum extension that includes g_content).

**Assessment**: The two-point model doesn't simplify the fundamental problem — it's just a dovetailed chain of length 2 and still requires the combined F-seed consistency argument.

### 6. Decidability FMP as Completeness Path: Detailed Analysis

The FMP module provides sorry-free:
1. `exists_mcs_with_negation`: If φ not provable, ∃ closure MCS containing ¬φ
2. `filtered_model_falsifies`: If φ not provable, ∃ closure MCS with φ ∉ S
3. `fmp_contrapositive`: If φ ∈ every closure MCS, then ⊢ φ
4. `FilteredWorld.finite`: The filtered model is finite
5. `characteristicSet_eq_iff_equiv`: MCS equivalence via characteristic sets

What's missing for FMP-based completeness:
- A **semantic evaluation on the filtered model** that connects `valid φ` to `φ ∈ S` for closure MCS
- This is the `filteredMcsTruth` infrastructure in `TruthPreservation.lean`, which has definitions but the full filtration lemma is incomplete
- The filtration lemma would need: for ψ in subformulaClosure(φ), `ψ ∈ S ↔ truth in the filtered model at [S]`
- This requires modal/temporal properties of closure MCS (box witness, G/H forward/backward)

**Key difference from the dovetailed chain**: The filtered model operates on a SINGLE time point (no temporal histories needed), but the temporal operators G/H still require inter-MCS relationships. In the filtered model, these become relationships between equivalence classes of closure MCS. The G/H cases of the filtration lemma face similar challenges to the direct approach — you still need to show that if G(α) holds at a closure MCS, then α holds at all "future" closure MCS (however "future" is defined in the filtered model).

## Recommended Approach

**Primary recommendation: Dovetailed chain (Teammate A's territory).**

The alternatives I investigated all eventually reduce to the same core problem:
- FMP filtration lemma needs temporal MCS properties (same difficulty)
- Flatten reduction fails in the backward direction
- Two-point model is just a short dovetailed chain
- Conservative extension doesn't apply
- No existing sorry-free completeness result can be composed

**Secondary recommendation: If the dovetailed chain is too complex, consider a proof-theoretic case split.**

The sorry at line 418 requires `False` from `valid(ψ → χ)` and `¬⊢(ψ → χ)` with `ψ,χ` USF. We could try:
1. Case-split on whether χ is temporal-free
2. If temporal-free: `fragment_completeness` applies to χ, then use prop_s to get ψ → χ
3. If χ contains G or H: the dovetailed chain is unavoidable

This would reduce the sorry to the strictly temporal case, potentially simplifying the chain construction.

## Evidence/Examples

- FMP sorry-free: `lake build Bimodal.Metalogic.Decidability` succeeds with 0 sorries
- `fmp_contrapositive` at `FMP.lean:206-211` — 6 lines, clean proof
- `fragment_completeness` at `CanonicalEmbedding.lean:310-321` — sorry-free for temporal-free fragment
- All other completeness modules have sorries (verified by grep across `Metalogic/`)

## Risks

1. **FMP filtration path**: Appears easier but the temporal MCS properties are unproven and may be equally hard
2. **Case split on temporal-free χ**: Only helps if temporal-free cases dominate; doesn't eliminate the hard case
3. **No shortcut exists**: All alternative approaches eventually face the same fundamental obstacle — connecting semantic truth under temporal operators to MCS membership

## Confidence Level

**High confidence** that:
- No existing sorry-free result can close the sorry by composition
- The flatten approach is provably insufficient (backward direction fails)
- The dovetailed chain is the standard and likely minimal approach

**Medium confidence** that:
- The FMP filtration path might be slightly easier than the dovetailed chain (fewer structural components, but same core difficulty)
- A case split reducing to temporal-free χ is implementable and useful as a partial step
