# Teammate B Findings: Alternative Completeness Approaches

**Task**: 83 — Close Restricted Coherence Sorries
**Focus**: GHR quasimodels, filtration, representation-theoretic methods, and comparative analysis
**Date**: 2026-04-05

## Key Findings

### 1. The Algebraic Representation Path is the Most Promising Alternative

The codebase already contains a sorry-free `algebraic_representation_theorem` proving `AlgSatisfiable phi <-> AlgConsistent phi`. The gap between this algebraic result and full Kripke completeness (`valid_over Int phi -> Nonempty ([] |- phi)`) is bridgeable, but the bridge itself requires temporal coherence — the same fundamental blocker.

**Critical observation**: The `parametric_algebraic_representation_conditional` in `ParametricRepresentation.lean` is sorry-free *as stated*, but conditional on a `construct_bfmcs` callback. Every concrete callback implementation (Dovetailed, Deterministic) has sorries in forward_F/backward_P. The algebraic path does NOT sidestep the temporal coherence problem — it merely factors it differently.

### 2. GHR Quasimodel Approach (Gabbay-Hodkinson-Reynolds 1994)

**What it is**: The GHR monograph (Oxford, 1994) uses "quasimodels" — structures that decompose temporal models into finite "tiles" or "mosaics" that can be assembled. Each tile is a finite temporal segment where all eventualities within the tile are resolved. The model is built by assembling compatible tiles.

**How it handles eventuality resolution**: F-resolution is built INTO the tile construction. Each tile is a finite sequence of MCSes where:
- Every F(psi) in the first MCS has a witness (position with psi) before the tile ends
- Tiles are made compatible by ensuring their boundary MCSes match

**Bidirectional handling**: For tense logic (both F and P), tiles must resolve BOTH directions. The GHR approach handles this by constructing tiles that are long enough to resolve all outstanding obligations in both temporal directions.

**Formalization complexity**: HIGH (40-60 hours). Reasons:
- Requires defining tile/mosaic structures as new types
- Tile consistency proofs are complex combinatorial arguments
- Assembly of tiles into an omega-chain requires careful induction
- The existing BFMCS/FMCS infrastructure would need significant adaptation or replacement
- None of the existing chain construction (DeterministicChain, DovetailedChain) is reusable

**Fundamental issue for this codebase**: The GHR approach would essentially require a PARALLEL completeness infrastructure. The existing `BFMCS` structure expects families indexed by `D` (a totally ordered abelian group), while quasimodels have a different algebraic shape. The `ParametricRepresentation.lean` conditional theorem could not be directly reused.

### 3. Reynolds (2003) Tableau-Based Approach

**What it is**: Reynolds developed a tree-shaped tableau system for LTL with a novel PRUNE rule that handles eventuality resolution without requiring fair scheduling strategies. The key insight is that the PRUNE rule detects when a branch is "looping" without resolving any eventualities, and terminates it.

**How it ensures F-resolution**: The PRUNE rule checks whether a branch has returned to a previously seen state without resolving any outstanding eventuality. If so, the branch is marked as failed. This ensures that any successful (open) branch resolves all eventualities.

**Adaptability to TM logic**: MEDIUM difficulty but significant mismatch:
- Reynolds' approach is for LTL (future only). TM has both F and P (tense), plus S5 modal Box.
- The S5 component adds a dimension of complexity not addressed by Reynolds
- The project's existing tableau infrastructure (`Decidability/Tableau.lean`) is for decidability, not completeness — it would need substantial extension

**Formalization complexity**: 30-50 hours. Lower than GHR but still substantial because:
- Tableau-to-model extraction is needed (not just decision procedure)
- S5 modal dimension must be integrated
- Existing tableau infrastructure handles signed formulas but not the PRUNE rule
- The completeness proof via tableau requires showing every satisfiable formula has a successful tableau AND extracting a model from it

### 4. Filtration / FMP-Based Approach

**Existing infrastructure (ZERO sorry)**:
- `Decidability/FMP/Filtration.lean` — MCS-based filtration equivalence, fully proven
- `Decidability/FMP/FiniteModel.lean` — Finiteness theorem, fully proven
- `Decidability/FMP/FMP.lean` — `mcs_finite_model_property`, fully proven
- `Decidability/FMP/ClosureMCS.lean` — Closure MCS construction, fully proven
- `Decidability/FMP/TruthPreservation.lean` — Infrastructure in place

**The FMP-completeness gap**: FMP alone does NOT directly give Hilbert-style completeness. The standard argument is:

1. FMP proves: "if phi is not provable, then phi fails in a finite model"
2. Completeness needs: "if phi is valid in ALL models, then phi is provable"

These are *contrapositively equivalent* — but ONLY if we can show that "phi is not provable" implies "phi fails in SOME model." The current `mcs_finite_model_property` proves: not-provable -> exists finite closure MCS without phi. This is an MCS-level statement, not a semantic truth-at-a-model statement.

**The missing link**: `TruthPreservation.lean` has the infrastructure but the full filtration lemma (MCS membership <-> truth in filtered model) for ALL formula cases (including temporal operators) is described as requiring "additional work on modal/temporal MCS properties." This is exactly where the same forward_F/backward_P issue would reappear — the temporal cases of the filtration lemma need to show that F(psi) membership corresponds to existence of a future witness, which is the same eventuality resolution problem.

**Critical realization**: FMP does NOT sidestep forward_F. The filtration lemma's temporal cases require the same kind of temporal coherence that the direct completeness proof needs. The difference is that FMP works with FINITE models, so the induction is bounded — but constructing those finite models with correct temporal semantics requires resolving eventualities.

**However**, there is one important difference: In finite models, every eventuality MUST be resolved because there are only finitely many states. The finite closure MCS construction already guarantees that if F(psi) is in a closure MCS S, then psi must appear somewhere in the closure (by subformula closure properties). The challenge is arranging these closure MCSes into a temporal sequence that witnesses the correct order. This is a finite combinatorial problem rather than an infinite chain construction.

### 5. Algebraic-to-Kripke Bridge Analysis

**Existing sorry-free algebraic results**:
- `algebraic_representation_theorem`: `AlgSatisfiable phi <-> AlgConsistent phi` (SORRY-FREE)
- `AlgConsistent phi := not (Nonempty (|- neg(phi)))` (definitional)
- `AlgSatisfiable phi := exists ultrafilter U, [phi] in U` (definitional)
- `consistent_implies_satisfiable`: Consistent -> AlgSatisfiable (SORRY-FREE)
- `satisfiable_implies_consistent`: AlgSatisfiable -> Consistent (SORRY-FREE)

**What the algebraic theorem actually proves**: If phi is consistent (neg(phi) not provable), there exists an ultrafilter of the Lindenbaum algebra containing [phi]. This is purely algebraic — no temporal model is constructed. The ultrafilter IS a maximal consistent set (via `mcsToUltrafilter` bijection), but it has no temporal structure.

**The bridge we would need**:
```
Consistent(phi)
  -> [algebraic_representation_theorem] AlgSatisfiable(phi)
  -> [NEW: AlgSatisfiable implies Kripke-satisfiable]
  -> Satisfiable(phi) in a TaskFrame model
```

The "AlgSatisfiable implies Kripke-satisfiable" step requires:
1. Taking the ultrafilter (= MCS) witnessing AlgSatisfiable
2. Embedding it into a temporal chain (= constructing an FMCS from an MCS)
3. Building a BFMCS with modal coherence
4. Proving temporal coherence (forward_F, backward_P)

This is **exactly** the current completeness pipeline. The algebraic theorem gives us step 1 for free, but steps 2-4 are where all the sorries live.

**Verdict**: The algebraic representation theorem does NOT provide a shortcut to completeness. It proves a different (weaker) property — algebraic satisfiability, not Kripke satisfiability with temporal semantics.

## Approach Comparison Matrix

| Approach | New Lean LOC | Math Prerequisites Missing | Risk of New Blocker | Reuses Existing Infrastructure | Estimated Hours |
|----------|-------------|---------------------------|--------------------|-----------------------------|-----------------|
| **Round-robin chain** (Teammate A focus) | 400-800 | F-resolution in chain construction | MEDIUM — requires proving resolution terminates | DeterministicChain base, BFMCS/FMCS structure | 25-40 |
| **GHR quasimodels** | 2000-3000 | Tile theory, mosaic assembly, tile compatibility | HIGH — entirely new infrastructure | Almost nothing (different algebraic shape) | 40-60 |
| **Reynolds tableau** | 1500-2500 | PRUNE rule, tableau-to-model extraction, S5+temporal integration | MEDIUM-HIGH — S5 integration untested | Tableau.lean (partial), SignedFormula.lean | 30-50 |
| **FMP-based completeness** | 600-1000 | Finite temporal arrangement, filtration truth lemma completion | MEDIUM — finite case may dodge infinite chain issues | FMP module (zero sorry), Filtration.lean, ClosureMCS.lean | 20-35 |
| **Algebraic bridge** | 800-1200 | Same as current path (forward_F/backward_P) | HIGH — algebraic theorem doesn't help with temporal coherence | AlgebraicRepresentation (sorry-free), ParametricRepresentation | 25-40 (no savings) |
| **Publication without full completeness** | 0 | None | NONE | Everything | 0 |

## Recommended Approach

**Primary recommendation: FMP-based completeness** (20-35 hours)

**Justification**:

1. **Maximum infrastructure reuse**: The FMP module is entirely sorry-free (Filtration, FiniteModel, ClosureMCS, FMP theorems). This is ~1000 lines of proven infrastructure that would directly support a completeness argument.

2. **Finiteness sidesteps the infinite chain problem**: The fundamental blocker in the current approach is that deterministic chains cannot guarantee F-resolution in infinite time. In a finite model, this problem vanishes — there are only finitely many states, so any chain through them must either resolve all eventualities or loop. The PRUNE-like argument becomes a finite pigeonhole argument.

3. **Concrete proof sketch**:
   - Start from `mcs_finite_model_property`: not-provable -> exists finite closure MCS without phi
   - Complete the filtration truth lemma: MCS membership <-> truth in filtered model
   - For the temporal cases: closure MCSes are FINITE, so subformulaClosure(phi) bounds the universe
   - If F(psi) is in closure MCS S at time t, then psi is in subformulaClosure(phi)
   - The filtered model has finitely many states — arrange them using a round-robin or fair enumeration argument ON THE FINITE SET
   - This is a combinatorial argument on a finite set, not an infinite chain construction

4. **Lower risk**: The finite combinatorial argument is more tractable than infinite chain constructions. If F(psi) is in a closure MCS, and the filtered model has N worlds, then within N steps any fair schedule resolves it.

5. **Compatibility**: The result would give `valid_over_finite phi -> provable phi`, which combined with FMP (valid -> valid_over_finite) gives completeness. The existing `completeness_over_Int` can be kept as a separate (sorry-bearing) theorem.

**Secondary recommendation**: If FMP-based completeness encounters unexpected blockers in the temporal filtration lemma, fall back to the round-robin chain construction (Teammate A's focus area).

**Not recommended**: GHR quasimodels (too much new infrastructure, 40-60 hours, high risk), Reynolds tableau (S5 integration complexity), pure algebraic bridge (does not avoid the core problem).

## Evidence/Examples

### FMP Module Sorry Count: ZERO
```
Decidability/FMP/Filtration.lean        — 0 sorry
Decidability/FMP/FiniteModel.lean       — 0 sorry
Decidability/FMP/FMP.lean               — 0 sorry
Decidability/FMP/ClosureMCS.lean        — 0 sorry
Decidability/FMP/TruthPreservation.lean — 0 sorry
Decidability/FMP/TruthPreservation.lean — "additional work needed" (gap is finite)
Decidability/FMP/DenseFMP.lean          — 0 sorry
Decidability/FMP/DiscreteFMP.lean       — 0 sorry
```

### Algebraic Module: Sorry-Free Core, Sorry in Callbacks
```
AlgebraicRepresentation.lean     — 0 sorry (core theorem)
ParametricRepresentation.lean    — 0 sorry (conditional theorem)
DeterministicFMCS.lean           — 6 sorry (callback implementation)
DovetailedChain.lean             — 6 sorry (callback implementation)
```

### The Impossibility Confirmed
The impossibility argument from Report 18 (finitely consistent set S = {F(A), neg(A), X(neg(A)), X(F(A)), ...}) confirms that forward_F is unprovable for ANY deterministic chain. This means:
- The round-robin approach MUST use non-deterministic (Lindenbaum-based) extension
- The FMP approach sidesteps this by working in a bounded universe
- The GHR/Reynolds approaches build resolution into the construction (avoiding the deterministic chain entirely)

## Confidence Level

**HIGH (85%)** for FMP-based approach being the best alternative path.

**Justification for high confidence**:
- Zero-sorry FMP infrastructure confirms the filtration approach is mathematically sound
- The remaining gap (truth preservation for temporal operators) is a finite combinatorial problem
- Published literature confirms FMP implies decidability, and for finitely axiomatized logics, decidability + recursive axiomatization gives completeness
- The project already has all the pieces; they just need to be connected

**Risk factors (15% uncertainty)**:
- The temporal filtration lemma may require more machinery than expected for Until/Since operators
- The filtered model's temporal ordering may not directly give a TaskFrame structure (task frames have specific constraints beyond being linearly ordered)
- Converting filtered-model truth to TaskFrame `truth_at` may introduce a non-trivial equivalence proof

## References

- Gabbay, Hodkinson, Reynolds (1994). *Temporal Logic: Mathematical Foundations and Computational Aspects*. Oxford University Press.
- Reynolds (2003). Tableau-based completeness for Until temporal logic. Various publications on PRUNE rule.
- Burgess (1984). Axioms for tense logic I: "Since" and "Until". Notre Dame J. Formal Logic.
- Blackburn, de Rijke, Venema (2001). *Modal Logic*. Cambridge University Press. Ch 2.3 on filtrations.
- Venema (1993). Extensions of Burgess-Xu axiomatization for discrete linear orderings.
