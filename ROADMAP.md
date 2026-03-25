# Roadmap: Completeness and Publication

## Overview

The repository has 98 `sorry` statements across 24 files. These fall into distinct categories:

| Category | Count | Files | Status |
|----------|-------|-------|--------|
| SuccChain FMCS | 24 | SuccChainFMCS.lean | **CRITICAL PATH** |
| Examples/pedagogical | 16 | Demo, ModalProofs, etc. | Expected |
| Perpetuity bridge lemmas | 16 | Perpetuity/Bridge, Principles | Derivation work |
| Completeness wiring | 9 | FrameConditions/Completeness, etc. | Blocked by SuccChain |
| Soundness extensions | 5 | Soundness.lean | Frame-dependent |
| FMP truth preservation | 4 | TruthPreservation.lean | Independent |
| RestrictedMCS | 4 | RestrictedMCS.lean | Definition fix |
| Infrastructure | 20 | Various | Mixed |

## The Completeness Gap (Priority 1)

### Architecture

```
⊬ φ → (Lindenbaum) → MCS M₀ ∋ φ.neg
     → (SuccChain) → FMCS family over Int        ← BLOCKED HERE
     → (Truth Lemma) → φ false at canonical model
     → ¬valid φ
```

The algebraic path (`Algebraic/ParametricRepresentation.lean`) is **sorry-free** through the
conditional representation theorem, but requires a `construct_bfmcs` callback that the
SuccChain construction is trying to provide.

### The Two Classes of Sorry

#### Class A: Solvable via MCS Double-Negation Elimination

**Sorries at SuccChainFMCS.lean:2359, 3011** — "Modal duality derivation"

These are blocked by the comment: "Formula.neg is φ.imp bot, so some_future and
all_future are NOT syntactic duals." But this is misleading — they ARE definitionally
equal via `rfl`:

```
F(ψ) = some_future(ψ) = ψ.neg.all_future.neg = neg(G(neg(ψ)))    -- rfl
```

Therefore:
```
neg(FF(ψ)) = neg(neg(G(neg(F(ψ)))))
```

And `SetMaximalConsistent.double_neg_elim` (TemporalCoherence.lean:124) gives:
```
neg(neg(X)) ∈ M → X ∈ M    -- for any MCS M
```

**Proof sketch for sorry at 2359**:
1. `FF(ψ) ∈ deferralClosure` and `FF(ψ) ∉ u` (given)
2. By negation completeness of restricted MCS: `neg(FF(ψ)) ∈ u`
3. `neg(FF(ψ)) = neg(neg(G(neg(F(ψ)))))` (definitional, since `FF(ψ) = neg(G(neg(F(ψ))))`)
4. By `double_neg_elim`: `G(neg(F(ψ))) ∈ u`
5. So `neg(F(ψ)) ∈ g_content(u)`
6. By Succ relation: `neg(F(ψ)) ∈ v`
7. From F-step: `ψ ∈ v ∨ F(ψ) ∈ v`
8. `F(ψ) ∉ v` (by MCS consistency with `neg(F(ψ)) ∈ v`)
9. Therefore `ψ ∈ v` ∎

**Estimated effort**: Small. All ingredients exist in the codebase.

#### Class B: Genuinely Hard — Boundary Cases at Deferral Closure Edge

**Sorries at SuccChainFMCS.lean:2979, 3025, 3096, 3675, 3903, 3915**

These arise when `FF(ψ) ∉ deferralClosure(φ)` (the target formula's closure). In this case:
- Negation completeness doesn't apply (formula outside the closure)
- We cannot derive `neg(FF(ψ)) ∈ u`
- The DNE argument from Class A breaks down
- The F-step may defer: `ψ ∈ v ∨ F(ψ) ∈ v`, and we can't rule out `F(ψ) ∈ v`

**Root issue**: The theorem `restricted_single_step_forcing` claims `ψ ∈ v` (at the
very next step), but when the F-obligation falls outside the closure, it may defer to
a later step. The claim may be **too strong** — the correct statement might be
"ψ eventually appears within the chain" rather than "ψ appears at step k+1."

**Two resolution strategies**:

1. **Weaken the theorem**: Prove `∃ d, ψ ∈ chain(k+d)` instead of `ψ ∈ chain(k+1)`.
   Since `deferralClosure(φ)` is finite, F-nesting depth is bounded, so deferral
   terminates in finitely many steps.

2. **Enlarge the closure**: Include all F-iterations of subformulas in the deferral
   closure, so FF(ψ) is always in scope. This changes `deferralClosure` but preserves
   finiteness since the subformula set is finite and F-nesting is bounded.

### Algebraic Perspective

The algebraic path (`Algebraic/`) provides sorry-free infrastructure:

```
LindenbaumQuotient → BooleanStructure → InteriorOperators
         → UltrafilterMCS → ParametricCanonical → ParametricTruthLemma
         → ParametricRepresentation (SORRY-FREE, conditional)
```

The gap is `construct_bfmcs`: given MCS M₀, produce a temporally coherent BFMCS.

#### Modal Completeness (Box Forward/Backward) — SOLVED

The **modal direction is complete**. `boxClassFamilies_modal_backward` (UltrafilterChain.lean:1678)
proves modal backward for the `boxClassFamilies` bundle construction. This theorem is sorry-free
and uses the contraposition argument:

1. If Box(phi) not in MCS, then Diamond(neg phi) in M0
2. `box_theory_witness_exists` provides W' with neg(phi) in W' and same box-class
3. The shifted chain from W' is in the bundle
4. If phi were in ALL families, it would be in W', contradiction

The `parametric_canonical_truth_lemma` (ParametricTruthLemma.lean:170) uses `B.modal_backward`
at line 269, which is populated by `boxClassFamilies_modal_backward` when constructing
via `construct_bfmcs`.

**Status**: Modal completeness (Box case) has no sorries. The remaining challenge is
**temporal coherence** (G/H backward), which requires the SuccChain or per-obligation
witness architecture work described above.

**Algebraic insight**: The SuccChain approach tries to build the FMCS by explicit
forward/backward enumeration. The algebraic approach could instead:

1. Take the Lindenbaum algebra `L = Formula / ≡`
2. The temporal operators G, H are interior operators on L (proven)
3. Ultrafilters of L correspond to MCSs (proven)
4. Define `mcs(t)` for each `t : D` using the **algebraic temporal shift**:
   an automorphism of L induced by temporal translation
5. The FMCS coherence conditions follow from algebraic properties

This avoids the F-nesting boundary entirely because the algebraic construction
doesn't enumerate F-obligations — it works at the level of the entire algebra.

**Key question**: Can the temporal shift automorphism be defined on the Lindenbaum
algebra? The G operator is deflationary (`G[φ] ≤ [φ]`), monotone, and idempotent.
If G determines a topology on L whose open sets are G-closed, then temporal
accessibility is a preorder on ultrafilters, and the FMCS construction is the
Stone-space unraveling.

## Other Open Items

### Perpetuity Principles (16 sorries in Bridge.lean + Principles.lean)
- P5 (`◇▽φ → △◇φ`) has 1 technical sorry
- Bridge lemmas need derivation work using combinators + modal axioms
- Independent of completeness

### Soundness Extensions (5 sorries in Soundness.lean)
- `density`: requires `DenselyOrdered D`
- `discreteness_forward`: requires `SuccOrder D`
- `seriality_future/past`: requires `NoMaxOrder/NoMinOrder D`
- These are frame-condition-dependent; architecture is sound

### ModalS4 Theorems (not started)
- 0/4 S4 nested modality theorems proven
- Independent of completeness

### FMP Truth Preservation (4 sorries)
- Filtration-based truth preservation for finite model property
- Independent track

## Recommended Priority Order

1. **Resolve Class A sorries** — modal duality via DNE (small, unblocks Class B thinking)
2. **Design solution for Class B** — either weaken theorem or enlarge closure
3. **Implement Class B solution** — complete `restricted_single_step_forcing`
4. **Wire through** — SuccChainCompleteness → FrameConditions/Completeness
5. **Perpetuity bridge lemmas** — derivation work
6. **Soundness extensions** — frame-condition instances
7. **ModalS4** — derived theorems
