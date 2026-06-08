# Research Report: Complete Derived Operator Enumeration (Task 285)

**Date**: 2026-06-07
**Task**: #285 — Complete derived operator enumeration for dataset generation
**Dependencies**: Tasks 274, 275, 276, 278
**Status**: PLANNED

---

## Executive Summary

The formula enumerator (`FormulaEnumerator.lean`) currently generates 8 binary temporal operators and 4 unary temporal operators as first-class targets. However, **7 derived operators** defined in `Formula.lean` are never generated as explicit targets:

- **Modal**: `diamond` (◇φ = ¬□¬φ)
- **Temporal unary**: `always` (△φ = Hφ ∧ φ ∧ Gφ), `sometimes` (▽φ = ¬△¬φ), `next` (○φ = U(φ, ⊥)), `prev` (●φ = S(φ, ⊥)), `weak_future` (G'φ = φ ∧ Gφ), `weak_past` (H'φ = φ ∧ Hφ)

These operators are semantically significant (especially `always`/`sometimes`, which are the primary universal/existential temporal quantifiers in the JPL paper) and their absence means the dataset never contains formulas in their "native" derived-operator form. Adding them would improve dataset coverage of the full operator language, but carries a **formula count explosion risk** that must be managed carefully.

---

## 1. Current Enumerator Coverage

### Already generated as first-class targets (14 operators)

| Operator | Lean Name | Type | Overhead | In enum? |
|----------|-----------|------|----------|----------|
| Implication | `imp` | Binary | 1 | ✅ Primitive |
| Bottom | `bot` | Atom | 1 | ✅ Primitive |
| Box | `box` | Unary | 1 | ✅ Primitive |
| Until | `untl` | Binary | 1 | ✅ Primitive |
| Since | `snce` | Binary | 1 | ✅ Primitive |
| Some Future (F) | `some_future` | Unary | 1 | ✅ Task 274 |
| Some Past (P) | `some_past` | Unary | 1 | ✅ Task 274 |
| All Future (G) | `all_future` | Unary | 1 | ✅ Task 274 |
| All Past (H) | `all_past` | Unary | 1 | ✅ Task 274 |
| Release (R) | `release` | Binary | 1 | ✅ Task 275 |
| Weak Until (WU) | `weak_until` | Binary | 1 | ✅ Task 275 |
| Trigger (T) | `trigger` | Binary | 1 | ✅ Task 276 |
| Weak Since (WS) | `weak_since` | Binary | 1 | ✅ Task 276 |
| Strong Release (M) | `strong_release` | Binary | 1 | ✅ Task 276 |
| Strong Trigger (ST) | `strong_trigger` | Binary | 1 | ✅ Task 276 |

### Missing from enumerator (7 operators)

| Operator | Lean Name | Definition | Type | Priority | Notes |
|----------|-----------|------------|------|----------|-------|
| Diamond | `diamond` | `φ.neg.box.neg` | Unary modal | **High** | Dual of □; fundamental in S5 |
| Always | `always` | `φ.all_past.and (φ.and φ.all_future)` | Unary temporal | **High** | △φ; JPL paper primary quantifier |
| Sometimes | `sometimes` | `φ.neg.always.neg` | Unary temporal | **High** | ▽φ; dual of △; JPL primary |
| Next | `next` | `Formula.untl φ Formula.bot` | Unary temporal | Medium | ○φ; discrete-time operator |
| Previous | `prev` | `Formula.snce φ Formula.bot` | Unary temporal | Medium | ●φ; discrete-time operator |
| Weak Future | `weak_future` | `φ.and φ.all_future` | Unary temporal | Low | G'φ; reflexive variant of G |
| Weak Past | `weak_past` | `φ.and φ.all_past` | Unary temporal | Low | H'φ; reflexive variant of H |

---

## 2. Impact Analysis

### Formula count impact

Adding each unary operator at complexity budget `n` multiplies the formula count at that level by the branching factor. With 3 atoms and existing 4 temporal unary operators (F, P, G, H), the current branching is:

- At each unary position: box + 4 temporal = 5 choices
- Adding diamond + always + sometimes + next + prev + weak_future + weak_past = 7 more unary choices
- New branching: 5 + 7 = **12 unary choices**
- **Formula count multiplier: ~2.4× per level where unary operators appear**

For c6 specifically (the level where this matters most):
- Current: 146,700 formulas at level 6 alone
- With all 7 new unary operators: potentially **350K+ formulas at level 6**
- Total c3–c6: potentially **400K+ formulas**

This would make c6 exhaustive generation **impractical** (400K × 1s timeout = ~111 hours).

### Semantic value

| Operator | Why it matters |
|----------|---------------|
| **Diamond** | S5 completeness requires ◇φ ↔ ¬□¬φ interaction. Dataset lacks explicit diamond formulas. |
| **Always/Sometimes** | JPL paper §sec:Appendix defines △ and ▽ as primary temporal quantifiers. The paper's axiomatization uses △ extensively (e.g., △φ → G(Hφ)). Currently the dataset only has G/H/F/P, not △/▽. |
| **Next/Prev** | Discrete-time temporal logics use X/Y as primitive operators. Their absence limits applicability to discrete verification domains. |
| **Weak Future/Past** | Reflexive variants G'/H' recover reflexive-universal reading from irreflexive G/H. Useful for comparing frame classes. |

---

## 3. Recommended Implementation Strategy

### Phase 1: High-priority operators only (diamond, always, sometimes)

Add only the 3 operators with the highest semantic value. This limits the branching factor increase from 5 → 8 unary choices (1.6× instead of 2.4×).

- `diamond`: overhead 1, gated by `modalBudget > 0`
- `always`: overhead 3 (because `always φ = Hφ ∧ φ ∧ Gφ` requires `and` which is `imp`-based, or we can treat it as overhead 1 with pattern-aware complexity)
- `sometimes`: overhead 3 (similar)

Actually, `always` and `sometimes` have **complexity 3** in their expanded form (they contain two `and` operations, each of which is `imp`-based). If we add them with pattern-aware complexity (treating them as costing 1 like F/P/G/H), the formula count increase is manageable.

### Phase 2: Medium-priority (next, prev)

Add `next` (○φ) and `prev` (●φ) as unary operators with overhead 1. These are discrete-time operators and add relatively few formulas because they require `temporalBudget > 0` and their semantics is tightly constrained.

### Phase 3: Low-priority (weak_future, weak_past)

Add `weak_future` (G'φ = φ ∧ Gφ) and `weak_past` (H'φ = φ ∧ Hφ). These are essentially reflexive variants of G and H. They can be derived from existing operators, so their value is lower. They can be deferred or added only under a special flag.

---

## 4. Complexity-Aware Enumeration

To prevent formula count explosion, the new operators should use **pattern-aware complexity** (task 274 convention) where the derived operator's "syntactic weight" is treated as 1, not its full expanded complexity.

| Operator | Expanded complexity | Pattern-aware complexity | In enum? |
|----------|---------------------|--------------------------|----------|
| `F φ` | 3 (U(φ, ⊤)) | 1 | ✅ |
| `P φ` | 3 (S(φ, ⊤)) | 1 | ✅ |
| `G φ` | 4 | 1 | ✅ |
| `H φ` | 4 | 1 | ✅ |
| `◇ φ` | 4 (¬□¬φ) | 1 | ❌ |
| `△ φ` | 7 (Hφ ∧ φ ∧ Gφ) | 1 | ❌ |
| `▽ φ` | 10 (¬△¬φ) | 1 | ❌ |
| `○ φ` | 3 (U(φ, ⊥)) | 1 | ❌ |
| `● φ` | 3 (S(φ, ⊥)) | 1 | ❌ |

If all new operators use pattern-aware complexity = 1, they fit naturally into the existing `sizeBudget - overhead` framework without disproportionately inflating the formula count.

---

## 5. Integration Points

### FormulaEnumerator.lean
Add new branches in `enumExactHelper` after the existing `F/P/G/H` block (lines 184–213):

```lean
-- Derived unary modal operators: diamond
let (derivedModal, cache1b) := if modalBudget > 0 then
  let diamondOverhead := 1
  let (diamondFormulas, c) := if sizeBudget > diamondOverhead then
    let childSize := sizeBudget - diamondOverhead
    let (children, c) := enumExactHelper atoms (modalBudget - 1) temporalBudget childSize cache1a
    (children.map Formula.diamond, c)
  else (#[], cache1a)
  (diamondFormulas, c)
else (#[], cache1a)
```

And for temporal:
```lean
-- always, sometimes, next, prev
let (derivedTemporal2, cache1c) := if temporalBudget > 0 then
  -- always(child), sometimes(child), next(child), prev(child)
  ...
```

### DatasetGenerator.lean prefilter
Add structural recognition for the new operators (if needed):
- `diamond` shape: `imp (box (imp φ bot)) bot`
- `always` shape: `imp (imp (all_past φ) (imp φ (imp (all_future φ) bot))) bot`
- (These shapes are already partially recognized by the existing polarity/conjunct analysis, but explicit shape recognizers would help.)

### InterestingnessMetrics.lean
Ensure `hasModalOperator` and `hasTemporalOperator` recognize the new derived forms. `hasDiamond` already exists (line 120). `hasAlways` and `hasSometimes` may need to be added.

---

## 6. Verification Plan

1. **Count test**: Generate c4 with and without new operators. Compare formula counts.
2. **Soundness test**: Every `always` formula generated should be structurally equivalent to `Hφ ∧ φ ∧ Gφ`.
3. **Prefilter test**: New operators should be recognized by `structuralPrefilterWithAxiom` where applicable.
4. **Build test**: `lake build` passes with no errors.

---

## 7. Risks and Mitigations

| Risk | Mitigation |
|------|------------|
| Formula count explosion | Add operators in 3 phases; use pattern-aware complexity; cap with `--max-formulas` |
| Prefilter false positives | New operators are derived from primitives, so existing prefilter logic already applies to their expanded forms |
| Dataset bloat | Use stratified mode for c6+; keep exhaustive mode for c5 and below |
| Decision procedure timeouts | `always`/`sometimes` formulas may be harder for the tableau — monitor timeout rate |

---

## 8. References

- `Theories/Bimodal/Syntax/Formula.lean` — Derived operator definitions (lines 376–501)
- `Theories/Bimodal/Automation/FormulaEnumerator.lean` — `enumExactHelper` (lines 154–269)
- `Theories/Bimodal/Automation/DatasetGenerator.lean` — Prefilter (lines 598–634)
- `Theories/Bimodal/Automation/InterestingnessMetrics.lean` — `hasDiamond` (line 120)
- Task 274 research report — Pattern-aware complexity convention
- JPL paper §sec:Appendix — `△φ` and `▽φ` definitions
