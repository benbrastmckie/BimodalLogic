# Research Report: Alternative Proof Strategies for Blocked Modal Theorems

## Executive Summary

This report documents alternative proof strategies discovered through online research to complete the blocked modal theorems from Plan 059. The key insight is that `□(A → B) → (◇A → ◇B)` IS a valid theorem (unlike the invalid `(A → B) → (◇A → ◇B)`), and this provides a foundation for completing all three blocked theorems.

## Background: The Original Blocking Issue

Plan 059 discovered a fundamental limitation:

**Invalid Theorem**: `(φ → ψ) → (◇φ → ◇ψ)` (diamond_mono_imp)
- Counter-model exists in S5
- The meta-rule `if ⊢ φ → ψ then ⊢ ◇φ → ◇ψ` IS valid
- The object-level implication is NOT valid

This blocked:
1. `diamond_disj_iff` - formula alignment issues
2. `s4_diamond_box_conj` - required conditional diamond monotonicity
3. `s5_diamond_conj_diamond` - S5 distribution

## Key Discovery: Valid K Distribution for Diamond

### Theorem: `□(A → B) → (◇A → ◇B)`

This IS derivable from axiom K using duality and contraposition.

**Proof Sketch** (from [Stanford Encyclopedia of Philosophy - Modal Logic](https://plato.stanford.edu/entries/logic-modal/)):

1. Start with K axiom: `□(A → B) → (□A → □B)`
2. Substitute `¬B` for `A` and `¬A` for `B`: `□(¬B → ¬A) → (□¬B → □¬A)`
3. `(A → B) ↔ (¬B → ¬A)` (contraposition equivalence)
4. Using duality `◇X = ¬□¬X`:
   - `□¬B = ¬◇B`
   - `□¬A = ¬◇A`
5. So: `□(A → B) → (¬◇B → ¬◇A)`
6. Contraposing the consequent: `□(A → B) → (◇A → ◇B)`

**Source**: [Modal Logic - Wikipedia](https://en.wikipedia.org/wiki/Modal_logic), [Modal Logic Tutorial](https://mally.stanford.edu/tutorial/modal.html)

## Alternative Proof Strategies

### Strategy 1: For `diamond_disj_iff` - Using Duality and Box Conjunction

**Theorem**: `⊢ iff (A.or B).diamond (A.diamond.or B.diamond)`

**New Approach**:
1. Use duality: `◇(A ∨ B) = ¬□¬(A ∨ B)`
2. Apply De Morgan: `¬(A ∨ B) = (¬A ∧ ¬B)`
3. So: `◇(A ∨ B) = ¬□(¬A ∧ ¬B)`
4. By `box_conj_iff` (already proven): `□(¬A ∧ ¬B) ↔ (□¬A ∧ □¬B)`
5. So: `◇(A ∨ B) = ¬(□¬A ∧ □¬B)`
6. Apply De Morgan again: `¬(□¬A ∧ □¬B) = (¬□¬A ∨ ¬□¬B)`
7. By duality: `(¬□¬A ∨ ¬□¬B) = (◇A ∨ ◇B)`

**Key Insight**: The proof should work through negation transformations rather than trying to use monotonicity directly. The formula alignment issue can be resolved by working entirely through double negation and De Morgan laws.

**Required Infrastructure**:
- `demorgan_conj_neg` (PROVEN in Phase 1)
- `demorgan_disj_neg` (PROVEN in Phase 1)
- `box_conj_iff` (PROVEN)
- `contrapose_biconditional`: If `⊢ A ↔ B` then `⊢ ¬A ↔ ¬B`

**Source**: [Modal Logic - Routledge Encyclopedia](https://www.rep.routledge.com/articles/thematic/modal-logic/v-1/sections/propositional-s5)

### Strategy 2: For `s4_diamond_box_conj` - Using S5 Modal Collapse

**Theorem**: `⊢ (◇A ∧ □B) → ◇(A ∧ □B)`

**New Approach** (using S5 properties):
1. From `□B`, derive `□□B` via axiom 4 (transitivity)
2. In S5, `□B ↔ ◇□B` holds (via `modal_5_collapse`)
3. Key insight from [Modal Logic - Stanford](https://plato.stanford.edu/entries/logic-modal/): In S5, □B holds at all worlds in the equivalence class
4. So if `◇A` (A is true at some world w'), then `□B` also holds at w'
5. Therefore `A ∧ □B` is true at w', giving `◇(A ∧ □B)`

**Formal Proof**:
1. Have `◇A ∧ □B` as hypothesis
2. From `□B`, derive `□(A → (A ∧ □B))` using:
   - `pairing`: `A → □B → (A ∧ □B)`
   - But we need `□B` as a premise, not in the formula
   - Use S5: `□B → □□B` (axiom 4)
   - Then `□B` is accessible from any world where `◇A` holds
3. Use `□(A → (A ∧ □B)) → (◇A → ◇(A ∧ □B))` (valid K distribution!)
4. Apply modus ponens

**Critical Insight**: The key is that `□(A → B) → (◇A → ◇B)` IS valid, so we can use it if we can get `□(A → (A ∧ □B))` from `□B`.

**Lemma Needed**: `box_imp_box_conj_intro`
```
⊢ □B → □(A → (A ∧ □B))
```

This can be derived using:
- `pairing`: `⊢ A → B → (A ∧ B)`
- Substitute `□B` for `B`: `⊢ A → □B → (A ∧ □B)`
- `box_mono` on `□B → (A → (A ∧ □B))` after flip: `⊢ □(□B → (A → (A ∧ □B)))`
- Wait - we need the box outside the implication...

**Alternative Approach**: Use S5's `modal_5_collapse` directly
1. From `□B`, derive `□◇□B` via `modal_b`
2. This gives us that `□B` is possible everywhere
3. Combined with `◇A`, we can derive `◇(A ∧ □B)`

**Source**: [S5 Modal Logic - Wikipedia](https://en.wikipedia.org/wiki/S5_(modal_logic))

### Strategy 3: For `s5_diamond_conj_diamond` - Using Mutual S5 Properties

**Theorem**: `⊢ iff ((A.and B.diamond).diamond) (A.diamond.and B.diamond)`

**Forward Direction**: `◇(A ∧ ◇B) → (◇A ∧ ◇B)`
1. `◇(A ∧ ◇B)` means at some world w: `A ∧ ◇B`
2. From `A` at w: `◇A` (reflexivity via T)
3. From `◇B` at w: need to show `◇B` at actual world
4. In S5: `◇B → □◇B` (axiom 5)
5. So `◇B` at w implies `◇B` at all accessible worlds including original

**Backward Direction**: `(◇A ∧ ◇B) → ◇(A ∧ ◇B)`
1. From `◇A` and `◇B`
2. Using S5: `◇B → □◇B` (axiom 5)
3. So `◇B` holds necessarily
4. Apply `□(A → (A ∧ ◇B)) → (◇A → ◇(A ∧ ◇B))` (valid K distribution)
5. Need to show `□(A → (A ∧ ◇B))` from `□◇B`

**Key Lemma**: From `□◇B`, derive `□(A → (A ∧ ◇B))`
- By `pairing`: `⊢ A → ◇B → (A ∧ ◇B)`
- Flip to: `⊢ ◇B → (A → (A ∧ ◇B))`
- Apply `box_mono`: `⊢ □◇B → □(A → (A ∧ ◇B))`

This works!

**Source**: [Modal Logic - Boxes and Diamonds](https://bd.openlogicproject.org/)

## Recommended Implementation Order

### Phase 1: K Distribution Helper (NEW)

**Theorem**: `k_dist_diamond`
```lean
theorem k_dist_diamond (A B : Formula) :
    ⊢ (A.imp B).box.imp (A.diamond.imp B.diamond)
```

**Proof Strategy**:
1. K axiom: `□(¬B → ¬A) → (□¬B → □¬A)`
2. Contraposition: `(A → B) ↔ (¬B → ¬A)`
3. Duality transformations

### Phase 2: Biconditional Negation Helper

**Theorem**: `contrapose_iff`
```lean
theorem contrapose_iff {A B : Formula} (h : ⊢ iff A B) : ⊢ iff A.neg B.neg
```

### Phase 3: Complete diamond_disj_iff

Using duality transformations rather than direct monotonicity.

### Phase 4: Helper Lemma for s4_diamond_box_conj

**Theorem**: `box_s_intro` or similar
```lean
theorem box_s_intro (B : Formula) : ⊢ B.box.imp (A.imp (A.and B.box)).box
```

This uses the combination of `pairing`, `theorem_flip`, and `box_mono`.

### Phase 5: Complete s4_diamond_box_conj

Using `k_dist_diamond` + `box_s_intro` pattern.

### Phase 6: Complete s5_diamond_conj_diamond

Using `modal_5` + `k_dist_diamond` pattern.

## Risk Assessment

### Low Risk
- `k_dist_diamond`: Well-documented derivation from K axiom
- `diamond_disj_iff`: Clear duality path through proven infrastructure

### Medium Risk
- `s4_diamond_box_conj`: Requires careful box lifting pattern
- `s5_diamond_conj_diamond`: Complex composition of S5 axioms

### High Risk
- None identified - all strategies use valid modal logic principles

## Conclusion

The discovery that `□(A → B) → (◇A → ◇B)` IS valid (unlike the invalid `(A → B) → (◇A → ◇B)`) provides a clear path forward. The key is to "box the implication" before applying monotonicity-like reasoning.

All three blocked theorems can be completed by:
1. First proving `k_dist_diamond` as infrastructure
2. Then using box-lifting patterns to convert hypotheses into boxed implications
3. Applying `k_dist_diamond` to get the diamond conclusions

## References

1. [Modal Logic - Wikipedia](https://en.wikipedia.org/wiki/Modal_logic)
2. [Modal Logic - Stanford Encyclopedia of Philosophy](https://plato.stanford.edu/entries/logic-modal/)
3. [S5 Modal Logic - Wikipedia](https://en.wikipedia.org/wiki/S5_(modal_logic))
4. [Modal Logic - Routledge Encyclopedia](https://www.rep.routledge.com/articles/thematic/modal-logic/v-1)
5. [FormalizedFormalLogic/Foundation - GitHub](https://github.com/FormalizedFormalLogic/Foundation)
6. [Boxes and Diamonds: An Open Introduction to Modal Logic](https://bd.openlogicproject.org/)
7. [Modal Logic Tutorial - Stanford](https://mally.stanford.edu/tutorial/modal.html)
