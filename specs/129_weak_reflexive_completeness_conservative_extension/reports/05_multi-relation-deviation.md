# Report: Multi-Relation Architecture Deviation

**Task**: 129 — weak_reflexive_completeness_conservative_extension
**Date**: 2026-05-14
**Type**: Implementation deviation audit — needs review

---

## Summary

The implementation introduced three separate accessibility relations (`reflCanR`, `tempR_fwd`, `tempR_bwd`) where the plan called for a single reflexive preorder (`reflCanR`) with strict temporal semantics recovered by adding `y ≠ x`. The truth lemma for temporal connectives uses `tempR_fwd`/`tempR_bwd` directly rather than `reflCanR` with an irreflexivity condition.

## Plan's Original Conception

The plan (03_doets-reynolds-plan.md, Overview) states:

> "The approach builds a standard Henkin canonical model where the accessibility relation is reflexive (defined via G_w = phi AND G(phi))"

Phase 1, G case (line 108):

> "Forward: G(psi) in x implies for all y with x R y and y != x, psi in y (by definition of R using g_content, not g_w_content). Backward: G(psi) not-in x implies F(neg(psi)) in x, extend {chi | G(chi) in x} union {neg(psi)} to MCS y by Lindenbaum; y satisfies x R y and psi not-in y, and y != x (since neg(psi) in y)."

The conception was: one relation `reflCanR` (= g_w_content x ⊆ y.val), which is reflexive. Strict G is recovered as "G(psi) at x iff for all y with x R y and y ≠ x, psi at y." The truth lemma would use `reflCanR` everywhere with `y ≠ x` for strict temporal cases.

## What Was Built

`ReflexiveCanonical.lean` defines three relations:

| Relation | Definition | Purpose |
|----------|-----------|---------|
| `reflCanR` | g_w_content x ⊆ y.val | Frame preorder (reflexive, transitive) |
| `tempR_fwd` | g_content x ⊆ y.val | Temporal future accessibility (used by G, Until) |
| `tempR_bwd` | h_content y ⊆ x.val | Temporal past accessibility (used by H, Since) |

`reflCanTruth` in TruthLemma.lean uses all three:

```
| all_future φ => ∀ y, tempR_fwd x y → reflCanTruth y φ
| all_past φ   => ∀ y, tempR_bwd y x → reflCanTruth y φ
| untl ψ₁ ψ₂  => ∃ y, tempR_fwd x y ∧ reflCanTruth y ψ₁ ∧ (guard on tempR_fwd)
| snce ψ₁ ψ₂  => ∃ y, tempR_bwd y x ∧ reflCanTruth y ψ₁ ∧ (guard on tempR_bwd)
```

The bridge lemma `tempR_fwd_imp_reflCanR` proves the temporal relations imply the frame preorder, but the frame preorder is **not used** in the truth definition for temporal connectives.

## Analysis

### What's Better

1. **Algebraically cleaner**: `g_content`/`h_content` are standard Henkin content sets. The G-backward proof is a straightforward Lindenbaum extension. No `y ≠ x` case splitting needed.

2. **Matches existing BXCanonical patterns**: The BXCanonical/Frame.lean already has `g_content`/`h_content` based relations. The implementation reuses proven proof patterns directly.

3. **The reflexive frame preorder still exists**: `reflCanR` is proved reflexive and transitive. It's available for the Phase 3 "good/very good" framework which needs a preorder on the canonical model. The truth lemma just doesn't need it for temporal evaluation.

### What's Concerning

1. **Not a single canonical model**: The plan envisioned a model with ONE relation. The implementation has three. This changes what "the canonical model" means.

2. **Truth lemma complexity shifts, doesn't disappear**: The plan used `reflCanR` with `y ≠ x` — the complexity was in the irreflexivity condition. The implementation uses `tempR_fwd`/`tempR_bwd` — the complexity is in the content-set definitions. Both approaches ultimately need the same algebraic content (g_content closure, Lindenbaum).

3. **Is `reflCanR` still needed?**: The only place `reflCanR` appears in Phase 1 is to prove `tempR_fwd_imp_reflCanR` and `reflCanR_refl`/`reflCanR_trans`. If the truth lemma never uses it, and Phase 3's Reynolds construction is done at the monadic FO level (via tables), what role does the frame preorder actually play?

4. **Risk of semantic mismatch**: If `reflCanTruth` evaluates G via `tempR_fwd` but a different part of the construction evaluates it via `reflCanR` with `y ≠ x`, are they equivalent? This equivalence is not proved and may not hold.

## Recommendation

Two paths:

### Path A: Keep the multi-relation design (pragmatic)

- Accept `tempR_fwd`/`tempR_bwd` as the truth-evaluation relations
- Keep `reflCanR` as the frame preorder for Phase 3
- **Must prove**: `reflCanTruth x (all_future φ)` (via `tempR_fwd`) ↔ `∀y, reflCanR x y ∧ y ≠ x → reflCanTruth y φ` (the plan's original definition)
- This equivalence lemma is ~50 lines and proves the two approaches agree

### Path B: Return to single-relation design (faithful to plan)

- Replace `tempR_fwd`/`tempR_bwd` usage in truth lemma with `reflCanR` + `y ≠ x`
- The G/H backward proofs still work: extend `{¬ψ} ∪ g_content x` → MCS y, get `reflCanR x y` (via g_content→g_w_content inclusion?), prove `y ≠ x` (since `¬ψ ∈ y` but `ψ ∈ x` or unknown)
- This requires: `g_content x ⊆ g_w_content x` (false in general — g_w_content forces ψ into x while g_content only forces Gψ). The Lindenbaum extension gives a point in the g_content order, but we need it in the g_w_content order.

**Path A is the safer choice.** The multi-relation design is a reasonable implementation refinement — the truth lemma doesn't need the reflexive preorder for temporal connectives. The deviation needs an equivalence lemma but otherwise preserves the plan's mathematical intent.

## Decision Required

- Accept Path A (update plan to reflect multi-relation architecture + require equivalence lemma)?
- Or revert to Path B (single-relation)?
