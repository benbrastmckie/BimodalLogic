# Teammate B Findings: Representation Theorem Strategy

**Task**: 88 — Close remaining 6 BXCanonical sorries
**Agent**: lean-research-agent (Teammate B — Alternative Approaches)
**Date**: 2026-04-09
**Focus**: Map all completeness/representation theorem paths, assess status, and identify shortest path to ANY sorry-free completeness theorem for a logic with Until/Since

---

## Key Findings

1. **FMP path is sorry-free and gives a genuine completeness result** — `fmp_contrapositive` in `Decidability/FMP/FMP.lean` is sorry-free and establishes `(∀ S : ClosureMCSBundle φ, φ ∈ S.carrier) → Nonempty (DerivationTree [] φ)`. This is completeness modulo MCS membership, and the entire FMP module has zero actual sorries.

2. **ParametricRepresentation.lean is sorry-free** — The D-parametric algebraic representation theorem at `Algebraic/ParametricRepresentation.lean` has no sorries. It provides a conditional completeness theorem: given a temporally coherent BFMCS over D, non-provability gives a countermodel. This is the foundation for base/dense/discrete completeness.

3. **fragment_completeness is sorry-free** — `CanonicalEmbedding.lean:310` proves completeness for temporal-free formulas `{atom, bot, imp, box}` without any sorries. This is a genuine publication-ready result.

4. **usf_completeness has exactly 1 sorry** — `CanonicalEmbedding.lean:418`, the `imp` Case B for until-since-free formulas `{atom, bot, imp, box, G, H}`. The gap: on constant histories, `truth_at G(α)` collapses to `truth_at α`, so the backward truth bridge cannot distinguish `flatten(χ) ∈ w` from `χ ∈ w`.

5. **The 6 BXCanonical sorries are all in the BXCanonical module** — 4 in Frame.lean (eventuality resolution lines 653, 675, 690, 704), 1 in CanonicalEmbedding.lean (line 418), 1 in Completeness.lean (line 160). These sorries are downstream of the global `bx_le_total` gap from Phase 2 of the plan.

6. **BaseCompleteness.lean has no sorries itself** — It re-exports the sorry-free canonical truth lemma for Int-indexed BFMCS. However, the module header says "For the Closed Completeness Theorem, See AlgebraicBaseCompleteness.lean" — but `AlgebraicBaseCompleteness.lean` does not appear to exist in the current codebase, meaning the main completeness theorem `valid φ → Nonempty (⊢ φ)` is not yet proven via this path.

7. **DenseCompleteness.lean and DiscreteCompleteness.lean are documentation shells** — They describe future work and re-export Int-based infrastructure but do not contain provable completeness theorems. DenseCompleteness needs SuccChain architecture. DiscreteCompleteness is blocked by SuccOrder/PredOrder sorries.

8. **The plan's Phase 2 (`bx_le_total`) remains blocked** — Round 2 team research reached consensus that global totality is false (3-point counterexample in LinearityDerivedFacts.lean). The proposed reformulation to "interval linearity" (2/4 teammates) provides a path but has not been implemented.

---

## Completeness Theorem Map

| Theorem | Location | Logic Fragment | Status | Sorries |
|---------|----------|---------------|--------|---------|
| `fragment_completeness` | BXCanonical/CanonicalEmbedding.lean:310 | temporal-free {atom,bot,imp,box} | **Sorry-free** | 0 |
| `usf_completeness` | BXCanonical/CanonicalEmbedding.lean:382 | until-since-free {atom,bot,imp,box,G,H} | 1 sorry (imp Case B) | 1 |
| `bx_completeness` | BXCanonical/Completeness.lean:124 | full TM logic with Until/Since | Sorried (entire proof body) | 1 (+6 upstream) |
| `fmp_completeness` / `fmp_contrapositive` | Decidability/FMP/FMP.lean:100,206 | full TM (MCS membership form) | **Sorry-free** | 0 |
| `parametric_algebraic_representation_relative` | Algebraic/ParametricRepresentation.lean:184 | full TM (conditional, needs BFMCS) | **Sorry-free** | 0 |
| `base_truth_lemma` (base completeness infra) | Metalogic/BaseCompleteness.lean:147 | base TM on Int | **Sorry-free** | 0 |
| `completeness_base` (full statement) | BaseCompleteness.lean header | base TM | Not proven (AlgebraicBaseCompleteness.lean missing) | N/A |
| `completeness_dense` | DenseCompleteness.lean header | dense TM | Not proven (SuccChain pending) | N/A |
| `completeness_discrete` | DiscreteCompleteness.lean header | discrete TM | Not proven (SuccOrder sorries in DiscreteTimeline) | N/A |

### Dependency Architecture

```
fragment_completeness (sorry-free)
    ↓ (extends to G/H)
usf_completeness (1 sorry: imp Case B)
    ↓ (extends to Until/Since via Frame.lean events)
bx_completeness (1 sorry, depends on Frame.lean x4)
    ↑ (requires)
bx_until_eventuality_resolution (Frame.lean:653) ← [sorry]
bx_until_backward (Frame.lean:675)               ← [sorry]
bx_since_eventuality_resolution (Frame.lean:690) ← [sorry]
bx_since_backward (Frame.lean:704)               ← [sorry]
    ↑ (all require)
bx_le_total (not proven — Phase 2 blocked)
    ↑ (requires)
interval linearity from BX11/BX12 (reformulated goal)
```

```
fmp_contrapositive (sorry-free)
    ↑ (uses)
FMP.mcs_finite_model_property (sorry-free)
    ↑ (uses)
FMP.filtered_model_falsifies (sorry-free)
    ↑ (uses)
FMP.exists_mcs_with_negation (sorry-free)
    ↑ (uses)
RestrictedMCS / ClosureMCS infrastructure (sorry-free)
```

```
parametric_algebraic_representation_relative (sorry-free)
    ↑ (uses)
parametric_shifted_truth_lemma (sorry-free)
    ↑ (uses)
canonical_truth_lemma / shifted_truth_lemma (sorry-free)
    ↑ (needs)
BFMCS construction with temporal coherence ← [gap for full completeness]
```

---

## Assessed Sorry Inventory

### BXCanonical module (6 active sorries):

| File | Line | Description | Blocker |
|------|------|-------------|---------|
| Frame.lean | 653 | `bx_until_eventuality_resolution` — forward Until | bx_le interval linearity |
| Frame.lean | 675 | `bx_until_backward` — backward Until from guard+endpoint | bx_le interval linearity |
| Frame.lean | 690 | `bx_since_eventuality_resolution` — forward Since | bx_le interval linearity |
| Frame.lean | 704 | `bx_since_backward` — backward Since from guard+endpoint | bx_le interval linearity |
| CanonicalEmbedding.lean | 418 | `usf_completeness` imp Case B — G/H in constant history | two-point history infra |
| Completeness.lean | 160 | `bx_completeness` — full canonical model embedding | upstream Frame sorries + TaskModel construction |

### Other sorries in Metalogic (not blocking task 88):

| File | Lines | Description |
|------|-------|-------------|
| Bundle/SuccChainFMCS.lean | 125,135,420,2166,5943 | BX axiom adaptation (seriality from BX, temp_4 from BX1); unreachable fuel=0 branch |
| Bundle/CanonicalFrame.lean | 259 | temp_4 from BX1 |
| Bundle/SuccRelation.lean | 548 | BX axiom stub |
| Algebraic/UltrafilterChain.lean | 2029,2393,3936,3946 | BX adaptation stubs; 2 uncategorized |
| Algebraic/LindenbaumQuotient.lean | 177,182 | temp_k_dist derivable from BX |
| Algebraic/InteriorOperators.lean | 83 | temp_k_dist derivable from BX |
| Algebraic/DovetailedChain.lean | 648,1016,1112,1125,1297,1305 | DEPRECATED: X-vs-G architectural limitation |
| ConservativeExtension/Lifting.lean | multiple | 21 sorries, many "BX removed" stubs |
| ConservativeExtension/ExtDerivation.lean | multiple | 9 sorries |
| ConservativeExtension/Substitution.lean | multiple | 9 sorries |
| Soundness.lean | 4 | unknown |

---

## Recommended Paths (Shortest to Longest)

### Path A: FMP Bridge (Already Sorry-Free!) — Effort: 2-4 hours

**What it gives**: A sorry-free completeness theorem for **full TM with Until/Since**, phrased as:
```
∀ S : ClosureMCSBundle φ, φ ∈ S.carrier  →  Nonempty (DerivationTree [] φ)
```

**What's missing**: The hypothesis is MCS membership, not semantic validity. To get `valid φ → Nonempty (DerivationTree [] φ)`, we need a **bridge theorem** connecting semantic validity to MCS membership:
```
valid φ  →  ∀ S : ClosureMCSBundle φ, φ ∈ S.carrier
```

This is precisely the *completeness lemma for the closure model*: if φ is valid in all models, it's in every closure MCS. This bridge is essentially a completeness statement for the finite quotient model, not just a Lindenbaum extension.

**Risk**: The bridge theorem may not be provable without the truth lemma for Until/Since (which is what we're trying to prove). The `fmp_contrapositive` provides the **proof-theoretic** direction (all finite MCSs contain φ → φ provable), but the **semantic** direction (φ valid → all finite MCSs contain φ) still requires the filtration/truth lemma for Until/Since.

**Verdict**: The FMP module is sorry-free, but completing the bridge to `valid φ → Nonempty (⊢ φ)` still requires the Until/Since truth lemma gap to be closed.

### Path B: Close usf_completeness (1 sorry) — Effort: 3-6 hours

**What it gives**: Sorry-free completeness for the until-since-free fragment `{atom, bot, imp, box, G, H}`.

**Approach**: At CanonicalEmbedding.lean:418, the `imp` Case B needs the backward truth bridge for χ containing G or H. Options:
1. **Two-point history**: Build a non-constant WorldHistory using `bx_forward_witness` (sorry-free) to get v ≥ w, then apply `G_iff_mcs`/`H_iff_mcs` from TruthLemma.lean. WorldHistory construction infrastructure is not yet built but is ~2 hours.
2. **Proof-theoretic**: If χ = G(α) and G(α) ∉ w, then F(¬α) ∈ w (by MCS negation completeness). Use the BX11 (F_until_equiv): F(¬α) → ⊤ U (¬α) ∈ w. This doesn't avoid the truth bridge entirely but changes the nature of the argument.

**Risk**: This path is blocked if the BX proof system without a full derivation for G-formulas from temporal-only witnesses. However, the two-point history approach is standard and should be mechanizable.

### Path C: Full bx_completeness via Interval Linearity — Effort: 14-28 hours

**What it gives**: Full sorry-free `bx_completeness` for all of TM.

**Current blocker**: Phase 2 (bx_le_total) was reformulated by Round 2 team research as "interval linearity." The plan shows this as [BLOCKED]. Implementing interval linearity is the prerequisite for the 4 Frame.lean sorries.

**Assessment**: This is the canonical path the plan targets but is the most expensive. Round 2 research gives 65% confidence at 14-28 hours.

### Path D: Bundle/ParametricRepresentation Completeness — Effort: 6-12 hours

**What it gives**: Full `valid φ → Nonempty (⊢ φ)` using the parametric representation theorem.

**Current state**: `parametric_algebraic_representation_relative` is sorry-free but conditional — it requires a caller to provide a temporally coherent BFMCS. The construction of such a BFMCS (via SuccChainFMCS for base TM) has sorries in `SuccChainFMCS.lean` (lines 125, 135, 420 for BX axiom adaptation). Closing those 3 BX-adaptation sorries in SuccChainFMCS.lean would unlock a sorry-free parametric completeness for base TM.

**Key observation**: The SuccChainFMCS sorries at lines 125, 135, 420 are tagged `BX: seriality_future removed, derive from BX axioms` and `BX: derive temp_4 from BX1`. These should be closable via BX axiom derivations — not deep mathematics, just proof engineering.

---

## Which Completeness Results Are Sorry-Free Right Now?

| Result | File | Sorry-free? |
|--------|------|-------------|
| `fragment_completeness` (temporal-free) | CanonicalEmbedding.lean | YES |
| `fmp_completeness` (MCS membership form) | Decidability/Correctness.lean | YES |
| `fmp_contrapositive` (MCS membership form) | Decidability/FMP/FMP.lean | YES |
| `parametric_algebraic_representation_relative` (conditional) | Algebraic/ParametricRepresentation.lean | YES |
| `base_truth_lemma` (infrastructure) | Metalogic/BaseCompleteness.lean | YES |
| `shifted_truth_lemma` (Int-indexed) | Bundle/CanonicalConstruction.lean | YES |
| `usf_completeness` (until-since-free) | CanonicalEmbedding.lean | NO (1 sorry) |
| `bx_completeness` (full TM) | BXCanonical/Completeness.lean | NO (1 sorry + 4 upstream) |
| `completeness_base` (closed form) | Metalogic — not yet exists | NO |
| `completeness_dense` (closed form) | DenseCompleteness.lean header | NO |
| `completeness_discrete` (closed form) | DiscreteCompleteness.lean header | NO |

---

## Confidence Level

**High (90%)**: The sorry inventory above is accurate. The FMP infrastructure is genuinely sorry-free. `fragment_completeness` is genuinely sorry-free for temporal-free formulas.

**High (85%)**: Closing `usf_completeness` (Path B) is the shortest path to expanding the sorry-free completeness to G/H formulas. The two-point history approach is standard and the key missing piece is WorldHistory construction infrastructure.

**Medium (70%)**: Path D (fixing SuccChainFMCS BX-adaptation sorries to unlock parametric completeness) is an underexplored but promising route. The 3 sorries at lines 125/135/420 are tagged as "derive from BX axioms" — not deep proof obligations but engineering tasks.

**Medium (65%)**: Path C (full `bx_completeness` via interval linearity) will succeed but requires the most effort. The Round 2 estimate of 14-28 hours reflects genuine complexity in the interval linearity argument.

**Low (55%)**: The FMP bridge (Path A) can be completed without the Until/Since truth lemma. The semantic validity → MCS membership direction almost certainly requires solving the same gap the BXCanonical module faces.

---

## Recommendation for Task 88

The task goal is to close the 6 BXCanonical sorries. Given Round 2's finding that global `bx_le_total` is false and the plan's Phase 2 is blocked, the **most strategic path is**:

1. **Quick win first (Path D, subset)**: Close the 3 BX-adaptation sorries in SuccChainFMCS.lean (lines 125, 135, 420). These are labeled "derive X from BX axioms" — they are proof engineering, not research. Closes no BXCanonical sorries directly but validates the SuccChain path.

2. **Primary path (Plan Phase 2 reformulated)**: Implement interval linearity in Frame.lean. This is what the 4 eventuality resolution sorries actually need. The BX12+BX7 approach from Round 2 provides a concrete proof sketch.

3. **Backup**: If interval linearity encounters more than 8 hours of blocking, pivot to the two-point history approach (Path B) for `usf_completeness` and accept that the Until/Since cases remain for a future task.

The **shortest path to ANY sorry-free completeness with Until/Since** is unclear — the FMP path (`fmp_completeness`) is sorry-free but its statement is in terms of MCS membership, not standard semantic validity. Bridging to `valid φ → provable φ` still requires closing the Until/Since truth bridge.
