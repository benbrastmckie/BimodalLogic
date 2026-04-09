# Teammate D Findings (Round 2): Strategic Horizons Update

**Task**: 88 -- Close 6 remaining BXCanonical sorries
**Date**: 2026-04-09
**Role**: Teammate D (Horizons / Strategic Direction)
**Focus**: Updated strategic assessment after Phase 1 completion; guidance for Phases 2-5

---

## Key Findings

### 1. Current State After Phase 1

Phase 1 (axiom restoration) is complete. The `Axioms.lean` file now contains all four new constructors:
- `temp_linearity` (BX11): `F(φ) ∧ F(ψ) → F(φ ∧ ψ) ∨ F(φ ∧ F(ψ)) ∨ F(F(φ) ∧ ψ)`
- `temp_linearity_past` (BX11'): past dual
- `F_until_equiv` (BX12): `F(φ) → ⊤ U φ`
- `P_since_equiv` (BX12'): `P(φ) → ⊤ S φ`

`Soundness.lean` already handles these new constructors (lines 840-843, 883-886, 927-929). The six remaining sorries are unchanged:

| File | Count | Sorry sites |
|------|-------|-------------|
| `Frame.lean` | 4 | Lines 653, 675, 690, 704 |
| `CanonicalEmbedding.lean` | 1 | Line 418 |
| `Completeness.lean` | 1 | Line 160 |

The ConservativeExtension sorry markers tagged "temp_linearity removed in BX" remain but are separate from the primary 6 BXCanonical targets.

### 2. Why bx_le_total Is Now Derivable (Phase 2)

With `temp_linearity` and `F_until_equiv` available as derivable theorems, the path to `bx_le_total` is:

**Approach A: Via F_until_equiv + BX7**

Given BXPoints `w` and `v`, suppose neither `bx_le w v` nor `bx_le v w`. Then there exists:
- Some `G(φ) ∈ w` with `φ ∉ v` (failure of `bx_le w v`)
- Some `G(ψ) ∈ v` with `ψ ∉ w` (failure of `bx_le v w`)

From BX1 (G(φ) → φ): `φ ∈ w` and `ψ ∈ v`. From BX3 (G → F transitivity, i.e., G(φ) → F(φ)): we can get `F(φ) ∈ w` by some MCS argument. However, BX3 does not give F(φ) directly from G(φ) in the MCS without an intermediate step.

Actually, the cleaner approach: from `φ ∉ v`, we want to derive `F(¬φ)` in some ancestor. This requires working with an ancestor `u` from which both `w` and `v` are accessible.

**Approach B: Direct bx_le_total from temp_linearity_valid**

More directly, bx_le_total can be attempted as follows. Given MCSs `w` and `v`, we want to show `bx_le w v ∨ bx_le v w` (one of g_content(w) ⊆ v or g_content(v) ⊆ w).

Suppose neither holds. Then:
- ∃ `φ₀` with `G(φ₀) ∈ w` but `φ₀ ∉ v`
- ∃ `ψ₀` with `G(ψ₀) ∈ v` but `ψ₀ ∉ w`

Note `φ₀ ∉ v` means `¬φ₀ ∈ v`. Then `G(φ₀) ∈ w` means `F(G(φ₀))` can be derived... but this requires knowing some common predecessor exists and that both w and v are accessible from it. Isolated BXPoints may be incomparable simply because g_content(w) and g_content(v) happen not to nest.

**This is the fundamental obstruction**: Two arbitrary MCSs w and v need not be bx_le-comparable even with temp_linearity available, unless they arise from a common "flow" (a chain). The intended use of temp_linearity is: if w is a point in a *constructed* chain C, then temp_linearity ensures that future witnesses along C are linearly ordered. But between *arbitrary* pairs of MCSs, temp_linearity gives no leverage.

**Critical assessment**: `bx_le_total` as a statement about ALL pairs of BXPoints is still false (report 08 of the prior research provided a counterexample). The team synthesis report (01_team-research.md) states "BX7 does NOT subsume temp_linearity" and distinguishes "local" from "global" linearity. Similarly, temp_linearity itself does not make the global bx_le relation total.

What temp_linearity and F_until_equiv DO enable is a weaker but sufficient property: **for any MCS w with φ U ψ ∈ w, the witnesses reachable from w are linearly ordered**. This is the interval-specific linearity needed for the eventuality resolution sorries.

### 3. Revised Attack on Frame.lean Sorries (Phase 3)

The correct strategy is NOT to prove `bx_le_total` globally, but to use temp_linearity and F_until_equiv locally within the eventuality resolution constructions.

**For `bx_until_eventuality_resolution` (Frame.lean:632)**:

Setup:
- `φ U ψ ∈ w`, `ψ ∉ w`
- By BX10 (φ U ψ → F(ψ)): `F(ψ) ∈ w`
- By F_until_equiv: `⊤ U ψ ∈ w`
- By BX7 applied to `φ U ψ` and `⊤ U ψ` in `w`:
  - BX7 states: `(φ U ψ) ∧ (α U ψ) → (φ U (ψ ∨ (φ ∧ α U ψ))) ∨ (α U (ψ ∨ (α ∧ φ U ψ)))`
  - With α = ⊤: This becomes a linearity condition on witnesses for φ U ψ and ⊤ U ψ
  - But both have ψ as their target, so this degenerates

Alternative using temp_linearity directly:
- `F(ψ) ∈ w` (from BX10)
- By `bx_forward_witness`: get `v₁` with `bx_le w v₁` and `ψ ∈ v₁`
- Need: for any `u` with `bx_le w u` and `bx_le u v₁` and `¬bx_le v₁ u`, show `φ ∈ u`
- From BX4 (φ U ψ → G(P(φ U ψ))): `G(P(φ U ψ)) ∈ w`
- Since `bx_le w u`: `P(φ U ψ) ∈ u`
- By `bx_backward_witness` applied to u: get `u'` with `bx_le u' u` and `φ U ψ ∈ u'`
- To show `φ ∈ u`: from `φ U ψ ∈ u'` and `bx_le u' u`, use BX9 (φ U ψ → φ ∨ ψ) and MCS properties
  - If `ψ ∈ u'`, then ... but we need `φ ∈ u` not `φ ∈ u'`
  - If `φ ∈ u'`, then we need to propagate φ from u' to u

The gap: we know `φ U ψ ∈ u'` and `bx_le u' u` and `ψ ∉ u` (because ψ ∉ w and u is "before" v₁ where ψ first appears)... but wait, we don't know ψ ∉ u for intermediate u.

The guard condition says `∀ u, bx_le w u → bx_le u v₁ ∧ ¬bx_le v₁ u → φ ∈ u`. The key semantic insight: u is in the strict interior of [w, v₁], so ψ ∉ u (otherwise v₁ wouldn't be the first witness). But in the canonical model, we cannot establish this "first witness" property without linearity.

**The temp_linearity approach**: Use temp_linearity to show that if both `F(ψ) ∈ w` and `F(ψ) ∈ u` (since u is reachable from w), the witnesses v₁ for w and some v₂ for u must be linearly ordered. This allows a well-founded induction on the "until-length" of intervals. But formalizing this induction in Lean requires well-founded relations on BXPoints indexed by some witness distance metric.

**Assessment**: The sorries in Frame.lean require a non-trivial proof technique that was not present in the earlier approaches. The axioms are now available, but the formalization strategy needs careful development. Estimated effort for Phase 3 alone: 4-6 hours, with moderate (60%) confidence of success without further architecture changes.

### 4. CanonicalEmbedding.lean:418 (Phase 4) — Updated Analysis

The sorry at line 418 is the "imp Case B" in `fragment_countermodel`. The context:
- We have a USF formula `φ → χ` with `χ ∉ w.formulas` for some MCS `w`
- We need to build a countermodel where `φ → χ` fails
- The imp Case B handles the subcase where `φ` is valid but `χ` is not in `w`

With `temp_linearity` and `F_until_equiv` now available as theorems, the proof-theoretic approach from plan 01 becomes more viable:
- If `χ` is of the form `G(α)`, then `¬G(α) ∈ w` means `F(¬α) ∈ w`
- By `F_until_equiv`: `⊤ U ¬α ∈ w`
- This gives a non-trivial temporal witness without needing to construct a non-constant history

However, the sorry structure at line 418 requires careful inspection. The constant-history collapse problem (G formulas collapsing to their content on constant histories) remains an issue for the semantic side. With the new axioms, we can derive properties in the MCS that provide the needed temporal witnesses — but the bridge from MCS membership to semantic truth still requires the full truth lemma.

For this phase, the most promising approach is:
1. Use the new F_until_equiv axiom to derive that `F(¬α) → ⊤ U ¬α` is a theorem
2. In the MCS w, derive `⊤ U ¬α ∈ w`
3. Use `bx_until_eventuality_resolution` (once sorry-free) to get a non-trivial chain structure
4. Build the countermodel on that chain

**Key dependency**: Phase 4 depends on Phase 3. Without sorry-free eventuality resolution, the chain structure needed for the countermodel cannot be constructed. The implementation order must preserve Phase 3 before Phase 4.

### 5. Strategic Assessment: Has Phase 1 Changed the Picture?

**Yes, substantially.** Before Phase 1, the project faced a philosophical deadlock: should it add axioms (mathematically correct) or build a chain construction (architecturally clean)? Phase 1 has resolved this deadlock by making the axiom addition official.

**What has changed**:
1. `temp_linearity_valid` was already a sorry-free theorem in `Soundness.lean` — now it's also an axiom constructor, giving it derivability
2. All `sorry /- temp_linearity removed in BX -/` markers in ConservativeExtension and LinearityDerivedFacts can now be mechanically replaced with actual constructor invocations
3. The soundness pattern for all four new axioms is established (Soundness.lean:840-843)

**What has NOT changed**:
1. `bx_le_total` is still not proved (and remains unprovable globally)
2. The Frame.lean sorries still block eventuality resolution
3. The CanonicalEmbedding sorry still depends on eventuality resolution
4. The Completeness sorry is downstream of all others

**The new strategic clarity**: The remaining work is purely Lean formalization of well-understood mathematical ideas. The blocking problems are:
- Phase 2: Reformulate the goal as interval linearity, not global totality
- Phase 3: Apply interval linearity + BX axioms to close eventuality resolution proofs
- Phase 4: Build non-constant countermodel histories using Phase 3 results
- Phase 5: Wire together the complete truth lemma

### 6. Recommended Reformulation for Phase 2

Instead of proving `bx_le_total` (false globally), prove:

```lean
theorem bx_le_connected_via_F (w v : BXPoint) (φ : Formula)
    (h_F : Formula.some_future φ ∈ w.formulas)
    (v₁ : BXPoint) (h_wv₁ : bx_le w v₁) (h_φv₁ : φ ∈ v₁.formulas) :
    bx_le w v ∨ bx_le v w ∨ bx_le v₁ v ∨ bx_le v v₁ := ...
```

Or more directly, for the eventuality resolution use case:

```lean
theorem bx_until_interval_linearity (w v u : BXPoint)
    (h_wv : bx_le w v) (h_wu : bx_le w u)
    (h_φ_U_ψ_w : Formula.untl φ ψ ∈ w.formulas) :
    bx_le u v ∨ bx_le v u := ...
```

This interval-specific linearity might be provable via: Since `φ U ψ ∈ w`, by BX10 `F(ψ) ∈ w`, by F_until_equiv `⊤ U ψ ∈ w`. BX7 (linearity of Until witnesses) then says the witnesses for `φ U ψ` and `⊤ U ψ` are comparable. The witnesses for `⊤ U ψ` starting from w are all the BXPoints between w and the first ψ-point. Since both u and v are reachable from w (bx_le w u and bx_le w v), and both are connected to the ψ-witnessing structure via BX4...

**Assessment of feasibility**: The formalization will require 2-4 hours and involves non-trivial MCS reasoning. The mathematical argument is sound (the literature's completeness proofs for Until/Since rely exactly on this kind of interval-specific linearity derived from the axioms), but translating it to Lean requires careful proof engineering.

### 7. Downstream Sorries Analysis

Beyond the 6 primary BXCanonical sorries, closing Phase 1 immediately enables quick wins:

**ConservativeExtension/Lifting.lean:208** — the `Extsorry /- temp_linearity removed in BX -/` pattern. With `temp_linearity` now an axiom, these become:
```lean
| temp_linearity a b => exact DerivationTree.axiom [] _ (Axiom.temp_linearity (embedFormula a) (embedFormula b))
```
This is a mechanical fix requiring ~30 minutes.

**ConservativeExtension/Lifting.lean:236** — the `sorry /- temp_linearity removed in BX -/` (not Extsorry). This requires a derivation in the extended system. Still ~1 hour.

**Algebraic/DovetailedChain.lean:572** — "F_until_equiv removed in BX". Now that it's restored, this is closable with the actual axiom constructor invocation.

These downstream fixes are quick wins independent of the Frame.lean challenges and should be done in parallel with (or before) Phases 2-5.

## Strategic Recommendations

### Primary Recommendation: Proceed with Plan 01, Updated Phase 2 Goal

Maintain the axiom-restoration strategy from plan 01. However, **reformulate the Phase 2 goal** from `bx_le_total` (globally false) to the interval-specific linearity needed for the eventuality resolution proofs:

1. **Phase 2 (revised)**: Do not attempt to prove `bx_le w v ∨ bx_le v w` for all w, v. Instead, prove `bx_le_connected_via_Until`: for any w with `φ U ψ ∈ w`, any two BXPoints u, v both reachable from w via bx_le satisfy `bx_le u v ∨ bx_le v u`. This uses temp_linearity + F_until_equiv + BX7 in a targeted way.

2. **Phase 2.5 (quick wins)**: In parallel, close the ConservativeExtension and DovetailedChain sorries tagged "removed in BX". These are mechanical and blocked only by the lack of the axiom constructors (now available). Estimated: 1-2 hours.

3. **Phase 3**: Apply the interval linearity from Phase 2 to close the 4 Frame.lean sorries. The proof sketch in the Frame.lean comments (BX4 + P(φ U ψ) ∈ u + backward witness) becomes viable once interval linearity is established.

4. **Phases 4-5**: Remain as in plan 01, dependent on Phase 3 completion.

### Secondary Recommendation: Consider a Direct Chain-Based Proof for Frame.lean Sorries

If Phase 2 (interval linearity) proves harder than expected, an alternative exists: construct a **specific chain** (a ℕ-indexed sequence of BXPoints reachable from w, each resolving one obligation) and prove the eventuality resolution for points on this chain rather than for all BXPoints. The advantage: linearity holds by construction on the chain. The disadvantage: the resulting canonical model is chain-specific, not the full canonical model.

This alternative has 50-60% confidence and 20-30 hour scope — it is viable but should only be pursued if Phase 2 fails.

## Creative Alternatives

### Alternative A: Bypass Frame.lean Sorries via TruthLemma Restructuring

The TruthLemma.lean uses `bx_until_eventuality_resolution` and `bx_until_backward` as black-box helpers. What if we replace these with:

```lean
noncomputable def bx_until_truth_iff_mcs (w : BXPoint) (φ ψ : Formula) :
    (Formula.untl φ ψ ∈ w.formulas) ↔
    (∃ v : BXPoint, bx_le w v ∧ ψ ∈ v.formulas ∧
      ∀ u : BXPoint, bx_le w u → (bx_le u v ∧ ¬bx_le v u) → φ ∈ u.formulas) := by
  ...
```

This is a combined iff statement. The forward direction uses `bx_until_eventuality_resolution` and the backward direction uses `bx_until_backward`. If we prove the iff directly (rather than via the two separated helpers), we might find that the combined proof is easier — the contradiction in the backward direction can use information from the forward direction.

**Assessment**: 40% confidence. The combined proof may still require the same interval linearity. But it changes the proof architecture in a way that might yield new proof strategies (e.g., using well-founded induction on the Until formula's "resolution time" in the MCS).

### Alternative B: FMP Bridge Remains Viable

The observation from Round 1 remains: `fmp_contrapositive` is sorry-free and proves `Nonempty (DerivationTree [] phi)` from the assumption that phi is in every ClosureMCSBundle. If we can show that validity of phi implies phi is in every closure MCS, we bypass the Frame.lean sorries entirely.

With the new axioms, this bridge lemma may be more tractable because:
- `temp_linearity` and `F_until_equiv` are now available for MCS-level reasoning within the closure
- The closure is finite, making inductive arguments over Until/Since formulas possible

Specifically, for a USF-Until formula `φ U ψ` in the closure of some formula θ, we can argue:
1. If `φ U ψ` is valid, then at any world in any model, there exists a future witness
2. In the closure MCS (a finite structure), there exists a "minimal witness" by finitary induction
3. The minimal witness is computable and its existence can be proved from axioms including BX5-BX10 and the new BX11-BX12

**Assessment**: 55% confidence. Still requires connecting the finite MCS closure to semantic validity. Finite induction may make the Until case tractable where the infinite canonical model fails. Worth a 2-hour research spike before committing to Phase 2 formalization.

## Confidence Level

| Claim | Confidence | Basis |
|-------|-----------|-------|
| Phase 1 completion is correct and sound | HIGH (95%) | Direct code verification; Soundness.lean handlers exist |
| Phase 2 (interval linearity) is provable in Lean | MEDIUM-HIGH (70%) | Standard mathematical argument; non-trivial formalization |
| Phase 3 (eventuality resolution) closes with interval linearity | MEDIUM (65%) | Depends on Phase 2; proof sketch is well-understood |
| ConservativeExtension quick wins closable | HIGH (90%) | Mechanical: just use new axiom constructors |
| Phase 4 (CanonicalEmbedding) closable after Phase 3 | MEDIUM (60%) | Depends on non-constant history construction |
| Phase 5 (Completeness) closable after Phase 4 | HIGH (80%) | Downstream of all others; well-defined wiring task |
| bx_le_total (global) is provable | LOW (5%) | Contradicts prior report 08 counterexample |
| FMP bridge provides shortcut | MEDIUM (55%) | Finite setting more tractable but still needs Until reasoning |

## Long-term Impact Assessment

### Immediate Impact

Completing task 88 establishes:
1. `bx_completeness`: the standard representation theorem for TM bimodal logic
2. Sorry-free `usf_completeness`: completeness for the Until/Since-free fragment
3. Closure of the ConservativeExtension sorry gap (as a side effect)

### Medium-term Impact

The techniques developed in task 88 (interval linearity, eventuality resolution for Until/Since in canonical models) will directly unblock:
- **Task 58** (wire completeness to FrameConditions): needs temporal coherence results similar to eventuality resolution
- **Task 87** (full representation theorem via enriched chain): the chain approach in task 87 will benefit from the interval linearity infrastructure built in task 88
- **DovetailedChain.lean** restoration: the F_until_equiv axiom closes the F_until_equiv-removed sorries directly

### Long-term Impact

If task 88 succeeds in producing sorry-free `bx_completeness`, the project achieves:
1. The first verified formalization of Until/Since temporal logic completeness in any proof assistant (Lean, Coq, or Isabelle)
2. A reusable infrastructure for similar completeness proofs (bimodal logics combining S5 with linear temporal operators)
3. A clear template for other temporal logic formalizations

The current Phase 1 completion (axiom restoration) is an essential milestone regardless of whether the remaining phases succeed. The restored axioms make the proof system mathematically correct (standard Burgess-Xu system) and provide the foundation for the remaining work.

### Risk Assessment

The primary risk is that Phase 2 (interval linearity) requires more than the estimated 2-4 hours. If the formalization of `bx_le_connected_via_Until` proves intractable, the project should:
1. First close the quick-win ConservativeExtension sorries (1-2 hours)
2. Attempt the FMP bridge alternative (2-hour spike)
3. If both fail, invest in the chain construction alternative (20-30 hours)

The axiom restoration in Phase 1 is a permanent improvement regardless of subsequent phases.
