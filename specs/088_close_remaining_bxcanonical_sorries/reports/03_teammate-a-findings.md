# Teammate A Findings: Until/Since Proof System Audit

## Key Findings

### Finding 1: Until (untl) and Since (snce) ARE full formula constructors — fully present in syntax
**Confidence: High**

`Formula` in `Theories/Bimodal/Syntax/Formula.lean` (lines 79–83) has two primitive constructors:
- `| untl : Formula → Formula → Formula` — Until (φ U ψ)
- `| snce : Formula → Formula → Formula` — Since (φ S ψ)

These appear in every recursive function in Formula.lean (complexity, modalDepth, temporalDepth, atoms, beq_refl, swap_temporal, etc.). They are fully first-class and never excluded or commented out.

Derived operators built on them:
- `next φ := bot U φ` (line 330)
- `prev φ := bot S φ` (line 334)
- `swap_temporal` maps `untl ↔ snce` (lines 427–428)

### Finding 2: All BX axioms for Until/Since are present and uncommented
**Confidence: High**

`Theories/Bimodal/ProofSystem/Axioms.lean` contains 14 Until/Since axioms (BX2–BX12 paired as future/past):

| Axiom | Constructor | Formula |
|-------|-------------|---------|
| BX2 | `left_mono_until` | `G(φ→χ) → ((φ U ψ) → (χ U ψ))` |
| BX2' | `left_mono_since` | `H(φ→χ) → ((φ S ψ) → (χ S ψ))` |
| BX3 | `right_mono_until` | `G(φ→ψ) → ((χ U φ) → (χ U ψ))` |
| BX3' | `right_mono_since` | `H(φ→ψ) → ((χ S φ) → (χ S ψ))` |
| BX4 | `connect_future` | `φ → G(P(φ))` |
| BX4' | `connect_past` | `φ → H(F(φ))` |
| BX5 | `self_accum_until` | `(φ U ψ) → ((φ ∧ (φ U ψ)) U ψ)` |
| BX5' | `self_accum_since` | `(φ S ψ) → ((φ ∧ (φ S ψ)) S ψ)` |
| BX6 | `absorb_until` | `(φ U (φ ∧ (φ U ψ))) → (φ U ψ)` |
| BX6' | `absorb_since` | `(φ S (φ ∧ (φ S ψ))) → (φ S ψ)` |
| BX7 | `linear_until` | Linearity of Until witnesses |
| BX7' | `linear_since` | Linearity of Since witnesses |
| BX8 | `refl_intro_until` | `ψ → (φ U ψ)` |
| BX8' | `refl_intro_since` | `ψ → (φ S ψ)` |
| BX9 | `until_elim` | `(φ U ψ) → (φ ∨ ψ)` |
| BX9' | `since_elim` | `(φ S ψ) → (φ ∨ ψ)` |
| BX10 | `until_F` | `(φ U ψ) → F(ψ)` |
| BX10' | `since_P` | `(φ S ψ) → P(ψ)` |
| BX11 | `temp_linearity` | `F(φ) ∧ F(ψ) → ...` (future linearity) |
| BX11' | `temp_linearity_past` | Past dual of BX11 |
| BX12 | `F_until_equiv` | `F(φ) → (⊤ U φ)` |
| BX12' | `P_since_equiv` | `P(φ) → (⊤ S φ)` |

No axiom is commented out or removed. The system is fully axiomatized.

### Finding 3: Semantics for Until/Since are defined with reflexive witness semantics
**Confidence: High**

`Theories/Bimodal/Semantics/Truth.lean` (lines 128–131):
```lean
| Formula.untl φ ψ => ∃ s : D, t ≤ s ∧ truth_at M Omega τ s ψ ∧
    ∀ r : D, t ≤ r → r < s → truth_at M Omega τ r φ
| Formula.snce φ ψ => ∃ s : D, s ≤ t ∧ truth_at M Omega τ s ψ ∧
    ∀ r : D, s < r → r ≤ t → truth_at M Omega τ r φ
```

Until uses reflexive witness (s ≥ t) with open-left guard. Since uses reflexive witness (s ≤ t) with open-right guard. This is the standard "Burgess-Xu" combination that the axioms are sound for.

### Finding 4: BXCanonical infrastructure — what works vs. what is sorry'd
**Confidence: High**

**Working (sorry-free) infrastructure for Until/Since:**

- `Frame.lean`: `bx_until_eventuality_resolution` and `bx_since_eventuality_resolution` are defined as `noncomputable def` with `sorry` bodies — they have correct signatures but blocked proofs.
- `TruthLemma.lean`: `until_iff_mcs` and `since_iff_mcs` are FULLY PROVED (no sorry in TruthLemma.lean itself). They call the Frame.lean `sorry`'d helpers, so they compile but reduce to sorry transitively.
- `F_from_witness`, `P_from_witness` — sorry-free (TruthLemma.lean lines 226–263).
- `G_iff_mcs`, `H_iff_mcs`, `box_iff_mcs` — sorry-free.
- BX Forward/Backward witness construction: `bx_forward_witness`, `bx_backward_witness` — sorry-free (Frame.lean lines 164–185).
- `box_preserved_along_bx_le`, `bx_modal_equiv_of_bx_le` — sorry-free (Frame.lean lines 538–583).

**The 6 actual sorry sites in BXCanonical (task 88):**

1. `Frame.lean:653` — `bx_until_eventuality_resolution` (forward Until guard proof)
2. `Frame.lean:675` — `bx_until_backward` (backward Until from witness)
3. `Frame.lean:690` — `bx_since_eventuality_resolution` (forward Since guard proof)
4. `Frame.lean:704` — `bx_since_backward` (backward Since from witness)
5. `CanonicalEmbedding.lean:418` — `usf_completeness` imp Case B (backward truth bridge for G/H inside imp)
6. `Completeness.lean:160` — `bx_completeness` (main completeness theorem, depends on all of above)

### Finding 5: The fundamental blocker for Until/Since sorries
**Confidence: High**

The Frame.lean module docstring (lines 585–622) gives a clear mathematical diagnosis:

The 4 Until/Since Frame.lean sorries are ALL blocked by a single fundamental problem: **the X-vs-G mismatch**. The canonical ordering `bx_le` is defined via `g_content` (universal future, G formulas), but Until formula `φ U ψ ∈ w` does NOT imply `G(φ U ψ) ∈ w`. Therefore Until formulas do not propagate through the canonical ordering, making it impossible to prove intermediate-point guard conditions using the current `bx_le` definition.

Three solution approaches are analyzed in the docstring:
- **(A) Until-induction axiom**: Removed during BX refactoring — not available.
- **(B) Prove bx_le linearity from BX7**: Blocked — BX7 constrains Until-witness ordering, not g_content inclusion. No bridge exists.
- **(C) Chain-specific construction**: Blocked by same X-vs-G mismatch at the seed consistency level.

### Finding 6: Until/Since are fully functional for the representation theorem goal EXCEPT for the canonical model
**Confidence: High**

Until/Since are:
- Fully defined in syntax (constructors, derived operators, complexity measures)
- Fully axiomatized in the BX proof system (14 axiom constructors, all present)
- Fully defined in semantics (truth_at with reflexive witness semantics)
- Fully covered in `TruthLemma.lean` (both directions structured, modulo Frame.lean sorries)

What is NOT complete:
- The canonical model construction for Until/Since in Frame.lean (4 sorries)
- Therefore the full `bx_completeness` theorem (Completeness.lean:160)
- The `usf_completeness` imp Case B (CanonicalEmbedding.lean:418, orthogonal to Until/Since)

For any representation theorem that only requires:
- Syntactic well-formedness of Until/Since formulas
- BX axioms being provable
- Semantic truth definition

...Until/Since are fully functional. The gap is specifically in proving the completeness direction of the representation theorem via the canonical model.

## Evidence

| Finding | File | Lines |
|---------|------|-------|
| 1: Syntax constructors | `Theories/Bimodal/Syntax/Formula.lean` | 79–83 |
| 1: Derived operators next/prev | `Theories/Bimodal/Syntax/Formula.lean` | 330, 334 |
| 1: swap_temporal includes untl/snce | `Theories/Bimodal/Syntax/Formula.lean` | 427–428 |
| 2: All BX axioms present | `Theories/Bimodal/ProofSystem/Axioms.lean` | 125–264 |
| 3: Semantic truth definition | `Theories/Bimodal/Semantics/Truth.lean` | 128–131 |
| 4: until_iff_mcs (sorry-free structure) | `Theories/Bimodal/Metalogic/BXCanonical/TruthLemma.lean` | 281–308 |
| 4: since_iff_mcs (sorry-free structure) | `Theories/Bimodal/Metalogic/BXCanonical/TruthLemma.lean` | 315–358 |
| 4: Frame.lean sorry sites | `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean` | 653, 675, 690, 704 |
| 4: CanonicalEmbedding sorry | `Theories/Bimodal/Metalogic/BXCanonical/CanonicalEmbedding.lean` | 418 |
| 4: Completeness sorry | `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` | 160 |
| 5: X-vs-G mismatch diagnosis | `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean` | 585–622 |
| 5: Three blocked approaches | `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean` | 595–618 |

## Summary

Until and Since are **fully present and functional** in the proof system (syntax, axioms, semantics). The 4 core sorries in Frame.lean are all blocked by the X-vs-G mismatch: Until/Since formulas don't propagate through the `g_content`-based canonical ordering, making it impossible to prove guard conditions for intermediate points. The viable path forward requires either redefining `bx_le` using Until-based witness ordering or adopting a quasimodel/filtration approach. The `CanonicalEmbedding.lean:418` sorry (imp Case B) is orthogonal — it concerns G/H inside implications, not Until/Since directly.
