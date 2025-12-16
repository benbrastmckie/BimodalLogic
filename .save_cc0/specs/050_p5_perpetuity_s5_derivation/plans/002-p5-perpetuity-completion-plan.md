# Implementation Plan: P5 Perpetuity Theorem Completion

## Metadata

- **Feature**: Complete P5 and P6 perpetuity theorem derivations (remove final sorry, convert axioms to theorems)
- **Status**: [COMPLETE]
- **Priority**: High
- **Complexity**: 3 (Medium-High)
- **Estimated Hours**: 6-10
- **Created**: 2025-12-09
- **Lean File**: /home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Theorems/Perpetuity.lean
- **Lean Project**: /home/benjamin/Documents/Philosophy/Projects/ProofChecker

## Executive Summary

This plan completes the P5 (`◇▽φ → △◇φ`) and P6 (`▽□φ → □△φ`) perpetuity theorem derivations by:
1. Adding `swap_temporal_diamond` lemma to show temporal swap distributes over diamond
2. Fixing the `sorry` in `persistence` theorem (line 1026)
3. Converting P5 from axiom to theorem
4. Converting P6 from axiom to theorem

**Key Insight**: The previous plan (001) correctly identified that `◇φ → □◇φ` is derivable from MB + M4 + MK. This has been implemented as `modal_5`. The remaining blocker is proving that `swap_temporal` distributes over `diamond`, enabling the past component of the persistence lemma.

## Research Summary

Based on analysis in reports:
- `001-s5-axiom-analysis.md`: Confirmed `◇φ → □◇φ` derivable from MB + M4 + MK (now proven as `modal_5`)
- `002-proof-strategy.md`: Detailed derivation strategy (diamond_4 → modal_5 → persistence → P5)
- `003-project-structure.md`: File locations and dependencies

**Current State** (as of 2025-12-09):
- `diamond_4`: ✓ PROVEN (line 469)
- `modal_5`: ✓ PROVEN (line 564)
- `persistence`: PARTIAL (1 sorry at line 1026 - swap_temporal simplification)
- `perpetuity_5`: AXIOM (line 1082) - needs conversion to theorem
- `perpetuity_6`: AXIOM (line 1149) - needs conversion to theorem

## Success Criteria

- [ ] `swap_temporal_diamond` lemma proven with zero sorry
- [ ] `past_k_dist_direct` helper lemma proven (alternative to current approach)
- [ ] `persistence` theorem completes with zero sorry (removes 1 existing sorry)
- [ ] P5 converted from axiom to theorem with zero sorry
- [ ] P6 converted from axiom to theorem with zero sorry
- [ ] `lake build` succeeds
- [ ] `lake test` passes
- [ ] Total axiom count in Perpetuity.lean reduced from 4 to 2 (keep pairing, dni, future_k_dist)
- [ ] Documentation updated (Summary section, SORRY_REGISTRY)

---

## Phase 1: Temporal-Diamond Distribution Lemma [COMPLETE]
implementer: lean
dependencies: []
lean_file: /home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Syntax/Formula.lean

### Description
Prove that `swap_temporal` distributes over the `diamond` operator. This is needed to simplify `past_mt` in the persistence lemma.

### Theorem Specification
- [ ] `theorem swap_temporal_diamond`
  - Goal: `(φ.diamond).swap_temporal = (φ.swap_temporal).diamond`
  - Strategy: Unfold definitions and apply structural equality
  - Complexity: Simple
  - Dependencies: None (structural lemma on Formula type)

### Implementation Details
```lean
/--
Temporal swap distributes over diamond: `swap(◇φ) = ◇(swap φ)`.

Since `diamond φ = φ.neg.box.neg`, and `swap_temporal` recurses through
`imp` and `box` without changing their structure (only swapping all_past/all_future),
we have:
- `swap(φ.neg.box.neg) = swap(φ.neg).box.neg = (swap φ).neg.box.neg = (swap φ).diamond`

Note: `neg φ = φ.imp bot` and `swap_temporal bot = bot`, so
`swap_temporal (φ.neg) = (swap_temporal φ).neg`.
-/
theorem swap_temporal_diamond (φ : Formula) :
    φ.diamond.swap_temporal = φ.swap_temporal.diamond := by
  -- Expand diamond definition: diamond φ = φ.neg.box.neg
  -- neg φ = φ.imp bot, so diamond φ = (φ.imp bot).box.imp bot
  simp only [diamond, neg, swap_temporal]
  -- swap_temporal (φ.imp bot) = (swap_temporal φ).imp (swap_temporal bot)
  -- swap_temporal bot = bot
  -- swap_temporal ((...).box) = (swap_temporal (...)).box
  -- Therefore: swap_temporal (φ.diamond) = (swap_temporal φ).diamond
  rfl
```

### Success Criteria
- [ ] Theorem compiles without sorry
- [ ] `#check swap_temporal_diamond` shows expected type

### Location
Add to Formula.lean after `swap_temporal_involution` (around line 232)

---

## Phase 2: Swap-Temporal Negation Lemma [COMPLETE]
implementer: lean
dependencies: [1]
lean_file: /home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Syntax/Formula.lean

### Description
Prove helper lemma that `swap_temporal` distributes over negation. This supports Phase 1 if the `rfl` proof doesn't work directly.

### Theorem Specification
- [ ] `theorem swap_temporal_neg`
  - Goal: `(φ.neg).swap_temporal = (φ.swap_temporal).neg`
  - Strategy: Unfold neg definition, apply swap_temporal
  - Complexity: Simple
  - Dependencies: None

### Implementation Details
```lean
/--
Temporal swap distributes over negation: `swap(¬φ) = ¬(swap φ)`.

Since `neg φ = φ.imp bot` and `swap_temporal bot = bot`:
`swap(φ.imp bot) = (swap φ).imp bot = (swap φ).neg`
-/
theorem swap_temporal_neg (φ : Formula) :
    φ.neg.swap_temporal = φ.swap_temporal.neg := by
  simp only [neg, swap_temporal]
```

### Success Criteria
- [ ] Theorem compiles without sorry
- [ ] Type signature matches expected

### Location
Add to Formula.lean after `swap_temporal_involution` (around line 232)

---

## Phase 3: Complete Persistence Lemma [COMPLETE]
implementer: lean
dependencies: [1, 2]
lean_file: /home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Theorems/Perpetuity.lean

### Description
Fix the `sorry` at line 1026 in the `persistence` theorem by using the new `swap_temporal_diamond` lemma to simplify the swapped modal-temporal expression.

### Theorem Specification
- [ ] Fix `theorem persistence` (existing, line 976)
  - Goal: Remove sorry at line 1026
  - Strategy: Use `swap_temporal_diamond` to show the swapped expression equals `(φ.diamond.box.imp φ.diamond).all_past`
  - Complexity: Medium
  - Dependencies: `swap_temporal_diamond`, `swap_temporal_neg`, `past_k_dist`

### Implementation Details
The current proof has:
```lean
have past_mt : ⊢ ((φ.diamond.box.swap_temporal.imp φ.diamond.swap_temporal).all_future).swap_temporal :=
  Derivable.temporal_duality _ future_mt_swap
-- Need to show this equals (φ.diamond.box.imp φ.diamond).all_past
sorry  -- TODO: simplify swapped diamond expressions
```

The fix:
```lean
-- Using swap_temporal_diamond and swap_temporal_neg:
-- φ.diamond.swap_temporal = φ.swap_temporal.diamond
-- φ.diamond.box.swap_temporal = φ.swap_temporal.diamond.box (swap commutes with box)
--
-- So the formula structure is:
-- ((φ.swap_temporal.diamond.box.imp φ.swap_temporal.diamond).all_future).swap_temporal
-- = (φ.swap_temporal.diamond.box.imp φ.swap_temporal.diamond).all_past  (by swap on all_future)
--
-- We need: (φ.diamond.box.imp φ.diamond).all_past
-- This requires showing swap_temporal applied to φ.swap_temporal gives φ back

-- Alternative approach: Use MT directly on φ.diamond without going through swap
have mt_direct : ⊢ φ.diamond.box.imp φ.diamond := box_to_present φ.diamond
-- Use temporal_k directly (not through swap):
have future_mt_direct : ⊢ (φ.diamond.box.imp φ.diamond).all_future :=
  Derivable.temporal_k [] _ mt_direct
-- Apply temporal duality
have past_mt_via_swap : ⊢ ((φ.diamond.box.imp φ.diamond).all_future).swap_temporal :=
  Derivable.temporal_duality _ future_mt_direct
-- Now simplify: swap(G(A)) = H(swap(A))
-- And swap(A.imp B) = (swap A).imp (swap B)
-- So we get: H(swap(□◇φ → ◇φ))
-- Using swap_temporal_diamond: swap(◇φ) = ◇(swap φ)
-- And box commutes with swap
-- swap(□◇φ → ◇φ) = □◇(swap φ) → ◇(swap φ)
simp only [Formula.swap_temporal, swap_temporal_diamond] at past_mt_via_swap
-- This gives us H(□◇(swap φ) → ◇(swap φ))
-- But we need H(□◇φ → ◇φ)
-- The key insight: we apply this to φ, not swap φ!

-- CORRECT APPROACH: Don't use swap at all for the past component
-- Instead, directly derive H(□◇φ → ◇φ) using past_k_dist on MT
have mt_for_past : ⊢ φ.diamond.box.imp φ.diamond := box_to_present φ.diamond
-- Need to lift this to past: H(□◇φ → ◇φ)
-- This requires a "past necessitation" or using the existing axiom approach

-- CLEANEST APPROACH: Show that from modal_5, we can get the result directly
-- ◇φ → □◇φ → H□◇φ → H◇φ using H(□◇φ → ◇φ)
-- The H distribution is via past_k_dist axiom (already available)

-- Use past_k_dist: H(A → B) → (HA → HB)
have pk : ⊢ (φ.diamond.box.imp φ.diamond).all_past.imp
             (φ.diamond.box.all_past.imp φ.diamond.all_past) :=
  past_k_dist φ.diamond.box φ.diamond

-- We need ⊢ H(□◇φ → ◇φ) to apply pk
-- This comes from temporal_k applied to MT:
-- temporal_k: if Γ ⊢ φ then GΓ ⊢ Gφ (for future)
-- By temporal duality: if Γ ⊢ φ then HΓ ⊢ Hφ (for past)
-- With empty context: if ⊢ φ then ⊢ Hφ

-- Wait - we need to check what temporal_k actually gives us
-- Looking at the code: temporal_k lifts to G (future), not H (past)
-- The temporal_duality rule converts between them

-- Let me trace through more carefully:
-- 1. mt_direct : ⊢ □◇φ → ◇φ
-- 2. future_mt : ⊢ G(□◇φ → ◇φ)  [via temporal_k]
-- 3. past_mt : ⊢ swap(G(□◇φ → ◇φ)) = H(swap(□◇φ → ◇φ))  [via temporal_duality]
-- 4. swap(□◇φ → ◇φ) = swap(□◇φ) → swap(◇φ)
-- 5. swap(□◇φ) = □(swap(◇φ)) = □(◇(swap φ))  [box commutes, swap_temporal_diamond]
-- 6. swap(◇φ) = ◇(swap φ)  [swap_temporal_diamond]
-- 7. So past_mt : ⊢ H(□◇(swap φ) → ◇(swap φ))

-- This is for (swap φ), not φ! The temporal duality changes the formula.

-- SOLUTION: Don't use swap for past. Instead:
-- Use the fact that mt_direct works for any formula, including swap φ
-- Then apply temporal_k and temporal_duality correctly

-- Actually, the REAL solution is to note that we already have:
-- mt : ⊢ φ.diamond.box.imp φ.diamond (line 1014)
-- We need to get: ⊢ H(□◇φ → ◇φ)
-- This requires "past necessitation" which temporal_k doesn't directly give

-- The fix is to realize temporal_k gives G-necessitation, and
-- temporal_duality converts between G and H at the formula level.
-- So to get H(A) from ⊢ A, we:
-- 1. Apply temporal_k to swap(A): ⊢ G(swap A)
-- 2. Apply temporal_duality: ⊢ swap(G(swap A)) = H(A)

-- Let's trace this with A = □◇φ → ◇φ:
-- swap(□◇φ → ◇φ) = □◇(swap φ) → ◇(swap φ)  [by swap_temporal_diamond]
-- temporal_k gives: ⊢ G(□◇(swap φ) → ◇(swap φ))
-- temporal_duality gives: ⊢ H(□◇(swap swap φ) → ◇(swap swap φ))
--                       = ⊢ H(□◇φ → ◇φ)  [by swap_temporal_involution]

-- This IS correct! We just need to use swap_temporal_involution properly
simp only [Formula.swap_temporal_involution, swap_temporal_diamond] at past_mt_via_swap
-- Now past_mt_via_swap : ⊢ (φ.diamond.box.imp φ.diamond).all_past
```

### Success Criteria
- [ ] `persistence` theorem compiles without sorry
- [ ] Sorry count in Perpetuity.lean decreases from 1 to 0

### Location
Modify existing `persistence` theorem at line 976

---

## Phase 4: Derive P5 as Theorem [COMPLETE]
implementer: lean
dependencies: [3]
lean_file: /home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Theorems/Perpetuity.lean

### Description
Convert P5 from axiom to theorem by composing P4 with the completed persistence lemma.

### Theorem Specification
- [ ] `theorem perpetuity_5` (replace existing axiom at line 1082)
  - Goal: `⊢ φ.sometimes.diamond.imp φ.diamond.always`
  - Strategy: Compose P4 (`◇▽φ → ◇φ`) with persistence (`◇φ → △◇φ`)
  - Complexity: Simple
  - Dependencies: `perpetuity_4`, `persistence`

### Implementation Details
```lean
/--
P5: `◇▽φ → △◇φ` (persistent possibility)

If it's possible that φ happens sometime, then it's always possible.

**Derivation**: Composition of P4 and persistence lemma:
1. P4: `◇▽φ → ◇φ` (possibility of occurrence)
2. Persistence: `◇φ → △◇φ` (possibility is perpetual)
3. By transitivity: `◇▽φ → △◇φ`

This completes the derivation that was previously blocked by the
persistence lemma, which required `modal_5` (`◇φ → □◇φ`).
-/
theorem perpetuity_5 (φ : Formula) : ⊢ φ.sometimes.diamond.imp φ.diamond.always := by
  have p4 : ⊢ φ.sometimes.diamond.imp φ.diamond := perpetuity_4 φ
  have pers : ⊢ φ.diamond.imp φ.diamond.always := persistence φ
  exact imp_trans p4 pers
```

### Success Criteria
- [ ] Theorem compiles without sorry
- [ ] Remove `axiom perpetuity_5` declaration (line 1082)
- [ ] Existing tests still pass

### Location
Replace axiom at line 1082 with theorem

---

## Phase 5: Derive P6 as Theorem [COMPLETE]
implementer: lean
dependencies: [4]
lean_file: /home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Theorems/Perpetuity.lean

### Description
Convert P6 from axiom to theorem. P6 states that if necessity occurs at some time, it's always necessary.

### Theorem Specification
- [ ] `theorem perpetuity_6` (replace existing axiom at line 1149)
  - Goal: `⊢ φ.box.sometimes.imp φ.always.box`
  - Strategy: Direct derivation using TF and modal reasoning
  - Complexity: Medium-High
  - Dependencies: TF axiom, modal_5, temporal_k, combine_imp_conj_3

### Approach Analysis

**Option A: Via P5 + Duality** (Complex)
1. P5 for `¬φ`: `◇▽¬φ → △◇¬φ`
2. Apply operator duality theorems (requires proving them first)
3. Contraposition

**Option B: Direct Derivation** (Simpler)
1. Key insight: If `□φ` holds at any time, by TF it propagates to all future times
2. By temporal duality, it also holds at all past times
3. So from `▽□φ`, we get `△□φ`
4. Necessitate appropriately

### Implementation Details
```lean
/--
Helper: Box implies boxed-always: `□φ → □△φ`.

This is P3 which is already proven.
-/
-- Already have: perpetuity_3

/--
Helper: From `□φ`, derive `△□φ` (necessity at one time implies necessity at all times).

Proof:
1. TF: `□φ → G□φ` (necessity persists to future)
2. TD of TF: `□φ → H□φ` (necessity extends to past)
3. Identity: `□φ → □φ` (present)
4. Combine: `□φ → H□φ ∧ □φ ∧ G□φ = △□φ`
-/
theorem box_to_always_box (φ : Formula) : ⊢ φ.box.imp φ.box.always := by
  -- Future: □φ → G□φ (TF axiom)
  have h_future : ⊢ φ.box.imp φ.box.all_future :=
    Derivable.axiom [] _ (Axiom.temp_future φ)

  -- Past: □φ → H□φ (temporal duality of TF)
  have tf_swap : ⊢ φ.swap_temporal.box.imp φ.swap_temporal.box.all_future :=
    Derivable.axiom [] _ (Axiom.temp_future φ.swap_temporal)
  have h_past_swap : ⊢ (φ.swap_temporal.box.imp φ.swap_temporal.box.all_future).swap_temporal :=
    Derivable.temporal_duality _ tf_swap
  simp only [Formula.swap_temporal, Formula.swap_temporal_involution] at h_past_swap
  have h_past : ⊢ φ.box.imp φ.box.all_past := h_past_swap

  -- Present: □φ → □φ (identity)
  have h_present : ⊢ φ.box.imp φ.box := identity φ.box

  -- Combine: □φ → H□φ ∧ □φ ∧ G□φ
  exact combine_imp_conj_3 h_past h_present h_future

/--
P6: `▽□φ → □△φ` (occurrent necessity is perpetual)

If necessity occurs at some time (past, present, or future), then it's always necessary.

**Derivation Strategy**:
1. From `box_to_always_box`: `□φ → △□φ`
2. Lift to sometimes: From `▽□φ`, at some time `□φ` holds
3. By step 1, at that time `△□φ` holds
4. But `△□φ` means `□φ` at ALL times, so `△□φ` holds globally
5. Necessitate: `□△φ`

The key insight is that `△□φ` at any time implies `△□φ` globally (since △ is about all times).

Alternative formulation using P3:
1. P3: `□φ → □△φ`
2. From `▽□φ`, at some time t, `□φ` holds
3. By P3, at time t, `□△φ` holds
4. But `□△φ` is time-independent (it's a boxed formula about all times)
5. So `□△φ` holds at all times

Actually, we need to be more careful. Let me use the direct approach:

From `▽□φ`, we know `¬△¬□φ` (sometimes = not always not).
We want `□△φ` = `□(H φ ∧ φ ∧ G φ)`.

Approach via contraposition of P1:
1. P1 for formula `φ`: `□φ → △φ`
2. P1 for formula `□φ`: `□□φ → △□φ`
3. From M4: `□φ → □□φ`
4. Compose: `□φ → △□φ`
5. This is `box_to_always_box`, which we proved above

Now to get from `▽□φ` to `□△φ`:
6. `box_to_always_box`: `□φ → △□φ`
7. Contrapose: `¬△□φ → ¬□φ`, i.e., `▽¬□φ → ◇¬φ`
   Wait, that's not quite right...

Let me think again. We have `▽□φ = ¬△¬□φ`.

Actually, the cleaner approach uses P5:
1. P5: `◇▽ψ → △◇ψ`
2. Set `ψ = □φ`: `◇▽□φ → △◇□φ`
3. By MB on `□φ`: `□φ → □◇□φ`
4. From `▽□φ`, at some time `□φ` holds
5. By step 3, at that time `□◇□φ` holds
6. `□◇□φ` is time-independent (modal), so it holds always

Hmm, this is getting complex. Let me try the P1-based approach more carefully:

From P1: `□φ → △φ` (necessary implies always)
Instantiate with `□φ`: `□□φ → △□φ`
From M4: `□φ → □□φ`
Compose: `□φ → △□φ` (this is box_to_always_box)

Now, `▽□φ = ¬△¬□φ`. We want `□△φ`.

The key is that `△□φ` is a *temporal* statement, and if it holds at any time,
it holds at all times (since it's about all times by definition).

So from `▽□φ`:
- At some time t, `□φ` holds
- By `box_to_always_box`, at time t, `△□φ` holds
- Since `△□φ` = `H□φ ∧ □φ ∧ G□φ`, this means `□φ` holds at all times from t's perspective
- But this IS all times globally (H covers past, G covers future)
- So `△□φ` holds globally
- Can we box this? Need `□△φ`

The issue: `△□φ` at time t gives us `□φ` at all times, but `□△φ` means
"necessarily, □φ at all times", which quantifies over world histories.

In S5, `□φ` at one time implies `□φ` at all times within a fixed world history
(by time-independence of modal facts in task semantics). This needs the TF axiom.

Actually, the simplest derivation:
1. `box_to_always_box`: `□φ → △□φ`
2. Necessitate (modal_k): `□(□φ → △□φ)`
3. MK distribution: `□□φ → □△□φ`
4. M4: `□φ → □□φ`
5. Compose: `□φ → □△□φ`, i.e., `□φ → □△φ` (since we're boxing φ)

Wait, `□△□φ` ≠ `□△φ` in general. Let me reconsider.

The goal is `▽□φ → □△φ`, i.e., `sometimes (box φ) → box (always φ)`.
Expanded: `¬△¬□φ → □(H φ ∧ φ ∧ G φ)`

Hmm, the LHS has `□φ` and the RHS has `△φ = H φ ∧ φ ∧ G φ` (not `△□φ`).

So P6 relates `▽□φ` to `□△φ` where the inner formulas differ!
`▽□φ` = sometimes (necessarily φ)
`□△φ` = necessarily (always φ)

This is actually simpler:
1. P1: `□φ → △φ` (necessarily φ implies always φ)
2. From `▽□φ`, at some time t, `□φ` holds
3. By P1, at time t, `△φ` holds
4. `△φ` = `H φ ∧ φ ∧ G φ` means φ at all times
5. Since φ at all times from any temporal perspective is the same,
   `△φ` is time-independent
6. So `△φ` holds globally (i.e., at all times)
7. In particular, for any world history σ, `△φ` holds
8. So `□△φ` holds (necessarily always φ)

But step 7→8 is the tricky part. We need to lift from "△φ in current history"
to "□△φ" (in all histories).

The key insight: In TM task semantics, `△φ` is purely temporal (about time),
while `□` is modal (about world histories). If `△φ` holds at one world history,
does it hold at all?

Actually, this requires the S5 property: if `△φ` holds in one history, and
the modal accessibility is an equivalence relation (S5), then either `△φ`
holds in all histories or we need more structure.

Let me look at what we can derive:
- From `▽□φ`, at time t: `□φ` holds
- `□φ` is time-independent in TM (TF gives `□φ → G□φ`, TD gives `□φ → H□φ`)
- So `□φ` holds at all times: `△□φ`
- But `△□φ ≠ □△φ` necessarily

Wait, but P1 gives us `□φ → △φ` (strip the box, get the temporal version).
So from `□φ` at all times, we get `△φ` at all times.
Hmm, but that's `△△φ`, which equals `△φ` (always is idempotent temporally).

Let me try: From `△□φ` (box φ at all times), apply P1 pointwise:
- At each time t, `□φ` holds (from △□φ)
- At each time t, `△φ` holds (from P1)
- So `△△φ` holds, but this is just `△φ`
- Actually we get `△φ` holds at ALL times
- Which means `△(△φ)` = `△φ` (temporal idempotence)

Still not getting `□△φ`. The issue is that `□△φ` requires "in all world histories,
φ at all times", not just "φ at all times in the current history".

Let me try the semantic approach: In task semantics with S5 modal structure,
if `▽□φ` at (M,τ,t), then there exists time s where `□φ` at (M,τ,s).
`□φ` at (M,τ,s) means: for all histories σ at time s, φ holds.
By TF, `□φ` propagates to all future times.
By TD of TF, `□φ` propagates to all past times.
So `□φ` holds at all times in τ.
But does `□φ` hold at all times in all histories σ?

The S5 property says: accessibility is an equivalence relation.
So from (M,τ,s), we can access any history σ.
At (M,σ,s), does `□φ` hold? We need to check if `□φ` is "transferred" across histories.

In TM, the modal and temporal dimensions are somewhat independent.
`□φ` at (M,τ,s) means φ at (M,σ,s) for all σ.
This is a statement about all histories at a FIXED time s.

For `□△φ` at (M,τ,t), we need: for all σ, `△φ` at (M,σ,t).
I.e., for all σ, φ at (M,σ,s) for all times s.

From `▽□φ` at (M,τ,t):
- At some time r, `□φ` at (M,τ,r)
- So for all σ, φ at (M,σ,r)
- By TF (for each σ): φ at (M,σ,s) for all s > r
- By TD of TF (for each σ): φ at (M,σ,s) for all s < r
- So for all σ, `△φ` at (M,σ,t)
- Which is `□△φ` at (M,τ,t)

This derivation is semantically valid! Let me translate to syntactic proof:

1. From `▽□φ`, at some time `□φ` holds
2. `□φ → △φ` (P1)
3. For any history σ, if `□φ` at (σ,t), then `△φ` at (σ,t)
4. But we need to show this for ALL histories...

Actually, the syntactic derivation is trickier because we can't directly
"apply P1 in each history". We need to use modal reasoning.

Key: If `□φ` at time t (in τ), then `□φ` at time t in ANY history σ
(because □ quantifies over histories at fixed time, and S5 gives equivalence).

Wait, that's not quite right either. `□φ` at (τ,t) means φ at (σ,t) for all σ.
This says nothing about `□φ` at (σ,t) for a specific σ ≠ τ.

Hmm, the accessibility relation in S5 is symmetric and transitive, so
if w can access w', then w' can access w.
`□φ` at w means: for all w' accessible from w, φ at w'.
In S5 with universal access, `□φ` at w means φ at all worlds.

So if `□φ` at (τ,t), then φ at (σ,t) for all σ.
To check `□φ` at (σ,t): φ at (ρ,t) for all ρ? Yes, same set of histories!
So `□φ` at (τ,t) iff `□φ` at (σ,t) for any σ.

This means `□φ` is actually history-independent at a fixed time!
And if `□φ` holds at any time (by ▽□φ), then by TF/TD, `□φ` holds at all times.
So `△□φ` holds.

Now apply P1 inside the □:
`□φ → △φ` (P1)
If `△□φ`, then at each time t, `□φ`.
At each time t, `□φ → △φ`, so `△φ`.
But this gives `△φ` at each time, i.e., `△△φ` = `△φ`.

To get □△φ:
`□(□φ → △φ)` (necessitate P1)
`□□φ → □△φ` (MK distribution)
`□φ → □□φ` (M4)
`□φ → □△φ` (compose)

And we have `△□φ` from above. Does `△□φ` imply `□φ`? Yes, by definition
(△ includes present).

So: `▽□φ → △□φ → □φ → □△φ`. But wait, `△□φ → □φ` loses information.

Let me reconsider:
- `△□φ` means H(□φ) ∧ □φ ∧ G(□φ)
- We want `□△φ` = `□(H φ ∧ φ ∧ G φ)`

Actually the RHS is about `φ`, not `□φ`.

P6: `▽□φ → □△φ` where:
- LHS: ▽(□φ) = sometimes (necessarily φ)
- RHS: □(△φ) = necessarily (always φ)

These are DIFFERENT formulas inside!

OK so the derivation is:
1. From `▽□φ`: at some time, `□φ` holds
2. Apply P1 (`□φ → △φ`): at that time, `△φ` holds
3. `△φ` at any time means φ at all times
4. If φ at all times in τ, does □△φ hold?

Step 4 is the crux. `□△φ` at (τ,t) means: for all σ, `△φ` at (σ,t).
`△φ` at (σ,t) means: φ at (σ,s) for all s.

From `▽□φ` at (τ,t): exists r, `□φ` at (τ,r).
`□φ` at (τ,r) means: φ at (σ,r) for all σ.

The TF axiom: `□φ → G□φ`, meaning if `□φ` at (τ,r), then `□φ` at (τ,s) for all s > r.
I.e., φ at (σ,s) for all σ and all s > r.
Similarly by TD, φ at (σ,s) for all σ and all s < r.
Combined: φ at (σ,s) for all σ and all s.
This is `△φ` at (σ,t) for all σ, which is `□△φ` at (τ,t).

So the derivation:
1. `▽□φ` (assumption)
2. At some time r, `□φ` holds
3. TF: `□φ → G□φ`, so at r, `G□φ` holds, meaning `□φ` at all s > r
4. TD: `□φ → H□φ`, so at r, `H□φ` holds, meaning `□φ` at all s < r
5. Combined: `△□φ` (□φ at all times)
6. At each time s, `□φ` holds
7. P1: `□φ → △φ`, so at each time s, `△φ` holds
8. But `△φ` is time-independent (it's about all times)
9. So `△φ` holds globally at (τ,t)
10. For `□△φ`: need △φ at all histories σ at time t

Actually steps 6-9 are about the SAME history τ.
The key insight from steps 3-5 is that `□φ` (which quantifies over histories)
holds at all times. This means:
- At each time s: for all σ, φ at (σ,s)
- Combining: for all s and all σ: φ at (σ,s)
- For any specific σ: φ at (σ,s) for all s, i.e., `△φ` at (σ,*)
- So `△φ` at (σ,t) for all σ
- Which is `□△φ` at (τ,t)

So semantically, P6 follows from P1 + TF + TD (temporal duality).

Syntactic proof:
1. `box_to_always_box (φ)`: `□φ → △□φ` [proven above, uses TF + TD + P1 ideas]
   Wait, that gives `△□φ`, not what we want.

Let me reconsider the helper lemma.

Actually, the semantic argument says:
- From `□φ` at one time, we get `□φ` at all times (TF + TD)
- `△□φ`
- From `□φ` at each time, apply MT inside: φ at each time in each history
- So `△φ` at each history
- `□△φ`

The syntactic version:
1. `□φ → G□φ` (TF)
2. `□φ → H□φ` (TD of TF)
3. `□φ → △□φ` (combine)
4. `△□φ → □φ` (from definition, △ includes present)
5. Actually, from △□φ, we have □φ at each time
6. MT: `□φ → φ`
7. At each time: `□φ → φ`
8. `G(□φ → φ)` (lift via temporal_k)
9. `G□φ → Gφ` (via future_k_dist)
10. Similarly: `H□φ → Hφ`
11. From △□φ = H□φ ∧ □φ ∧ G□φ:
12. Hφ (from H□φ via step 10)
13. φ (from □φ via MT)
14. Gφ (from G□φ via step 9)
15. So △φ = Hφ ∧ φ ∧ Gφ
16. We've shown: △□φ → △φ
17. Need to lift: □(△□φ → △φ) and then distribute

Hmm, this is getting complex. Let me try a cleaner approach.

From `▽□φ`, we want `□△φ`.

Use P5 structure: P5 is `◇▽ψ → △◇ψ`.
P6 is `▽□φ → □△φ`.

P5 and P6 are "dual" in some sense:
- P5: possible-sometimes → always-possible
- P6: sometimes-necessary → necessary-always

Contrapositive of P5 for `¬φ`:
P5(¬φ): `◇▽¬φ → △◇¬φ`
Contrapose: `¬△◇¬φ → ¬◇▽¬φ`
I.e., `▽□φ → □△φ` (using dualities)

Wait, let's check the duality:
- `¬△◇¬φ = ▽¬◇¬φ = ▽□φ` (since ¬◇¬ = □)
- `¬◇▽¬φ = □¬▽¬φ = □△φ` (since ¬▽¬ = △)

So P6 IS the contrapositive of P5(¬φ) under duality!

The derivation is:
1. P5 for `¬φ`: `◇▽¬φ → △◇¬φ`
2. Contrapose: `¬△◇¬φ → ¬◇▽¬φ`
3. By duality: `▽□φ → □△φ` (P6)

Checking the dualities more carefully:
- `¬△ψ = ▽¬ψ` (definition of ▽)
- `¬◇ψ = □¬ψ` (definition of ◇)
- `¬▽ψ = △¬ψ` (definition of ▽)

Step 2: `¬△◇¬φ → ¬◇▽¬φ`
LHS: `¬△◇¬φ = ▽¬◇¬φ = ▽□φ` (since ¬◇¬φ = □φ)
RHS: `¬◇▽¬φ = □¬▽¬φ = □△φ` (since ¬▽¬φ = △φ)

This checks out.

Now we need to prove the duality identities:
1. `¬◇¬φ = □φ` (definitionally true since ◇φ = ¬□¬φ)
2. `¬▽¬φ = △φ` (definitionally true since ▽φ = ¬△¬φ)
-/

/--
P6: `▽□φ → □△φ` (occurrent necessity is perpetual)

If necessity occurs at some time (past, present, or future), then it's always necessary.

**Derivation**: Contraposition of P5 applied to `¬φ` with operator duality:
1. P5 for `¬φ`: `◇▽¬φ → △◇¬φ`
2. Contrapose: `¬△◇¬φ → ¬◇▽¬φ`
3. Apply dualities:
   - `¬△◇¬φ = ▽¬◇¬φ = ▽□φ` (since `¬◇¬ψ = □ψ`)
   - `¬◇▽¬φ = □¬▽¬φ = □△φ` (since `¬▽¬ψ = △ψ`)
4. Result: `▽□φ → □△φ`
-/
theorem perpetuity_6 (φ : Formula) : ⊢ φ.box.sometimes.imp φ.always.box := by
  -- P5 for ¬φ: ◇▽¬φ → △◇¬φ
  have p5_neg : ⊢ φ.neg.sometimes.diamond.imp φ.neg.diamond.always := perpetuity_5 φ.neg

  -- Contrapose: ¬△◇¬φ → ¬◇▽¬φ
  have contraposed : ⊢ φ.neg.diamond.always.neg.imp φ.neg.sometimes.diamond.neg :=
    contraposition p5_neg

  -- Now we need to show the formula structure matches:
  -- φ.neg.diamond.always.neg = φ.box.sometimes
  -- φ.neg.sometimes.diamond.neg = φ.always.box

  -- Let's verify:
  -- φ.neg.diamond = (φ.neg).neg.box.neg = φ.box.neg.neg... wait
  -- Actually: diamond ψ = ψ.neg.box.neg
  -- So: φ.neg.diamond = φ.neg.neg.box.neg = φ.box.neg (using DNE at type level)
  -- Hmm, but we don't have DNE at the formula STRUCTURE level

  -- Let me reconsider. The dualities need to be proven as derivability
  -- relations, not structural equalities.

  -- Actually, we need lemmas showing:
  -- ⊢ ¬△◇¬φ → ▽□φ (or the reverse)
  -- ⊢ ¬◇▽¬φ → □△φ (or the reverse)

  -- These require proving the duality principles as derivable implications.
  -- This is complex because it involves multiple nested operators.

  -- ALTERNATIVE: Derive P6 directly using semantic reasoning encoded syntactically
  --
  -- From the semantic analysis:
  -- 1. If ▽□φ, at some time □φ holds
  -- 2. By TF, □φ at all future times
  -- 3. By TD, □φ at all past times
  -- 4. So △□φ (□φ at all times)
  -- 5. At each time, □φ → φ (MT), so φ at each time in each history
  -- 6. So △φ at each history
  -- 7. So □△φ

  -- This requires:
  -- a) ▽□φ → △□φ (sometimes-box to always-box)
  -- b) △□φ → □△φ (always-box to box-always)

  -- Part (a): We essentially proved this as box_to_always_box + some glue
  -- Part (b): Uses the fact that □ at all times means □△

  sorry -- Complex derivation - defer to implementation
```

### Success Criteria
- [ ] Theorem compiles without sorry
- [ ] Remove `axiom perpetuity_6` declaration (line 1149)
- [ ] Existing tests still pass

### Location
Replace axiom at line 1149 with theorem

### Note
P6 derivation is complex. If direct derivation proves too difficult, an acceptable alternative is:
1. Add helper lemmas for operator duality (`neg_diamond_neg_eq_box`, `neg_sometimes_neg_eq_always`)
2. Use P5 + contraposition + duality (as sketched above)

---

## Phase 6: Documentation and Tests [COMPLETE]
implementer: software
dependencies: [4, 5]
lean_file: none

### Description
Update documentation and add/update tests for the completed theorems.

### Tasks
- [ ] Update Summary section in Perpetuity.lean (lines 1154-1238)
  - Update sorry count from 1 to 0
  - Change P5 from "AXIOMATIZED" to "FULLY PROVEN"
  - Change P6 from "AXIOMATIZED" to "FULLY PROVEN"
  - Update axiom count (remove perpetuity_5, perpetuity_6 from axiom list)
- [ ] Update module docstring (lines 1-60)
  - P5 and P6 now derived theorems, not axioms
- [ ] Update SORRY_REGISTRY.md
  - Remove persistence sorry entry
- [ ] Update IMPLEMENTATION_STATUS.md
  - Update perpetuity principles status
- [ ] Update TODO.md (if applicable)
- [ ] Add/verify tests in PerpetuityTest.lean for:
  - [ ] `swap_temporal_diamond`
  - [ ] `swap_temporal_neg`
  - [ ] Complete `persistence` (no sorry)
  - [ ] `perpetuity_5` as theorem
  - [ ] `perpetuity_6` as theorem

### Success Criteria
- [ ] `lake build` succeeds
- [ ] `lake test` passes
- [ ] `lake lint` shows no new warnings
- [ ] Documentation accurately reflects implementation status

---

## Risk Assessment

### High Risk Items
1. **Phase 5 (P6 Derivation)**: Complex duality reasoning may require additional helper lemmas
   - Mitigation: Can fall back to axiomatizing P6 if derivation proves intractable
   - Alternative: Implement operator duality lemmas first

### Medium Risk Items
1. **Phase 3 (persistence fix)**: simp lemma behavior with swap_temporal_diamond
   - Mitigation: Manual unfolding if simp doesn't work

2. **Formula structure matching**: Verify `swap_temporal_diamond` proof actually compiles
   - Mitigation: Test in isolation first

### Low Risk Items
1. **Phases 1, 2**: Simple structural lemmas
2. **Phase 4 (P5)**: Straightforward composition once persistence works
3. **Phase 6**: Documentation updates are straightforward

## Estimated Total Effort

| Phase | Estimated Hours | Risk | Dependencies |
|-------|-----------------|------|--------------|
| Phase 1: swap_temporal_diamond | 0.5-1 | Low | None |
| Phase 2: swap_temporal_neg | 0.5 | Low | Phase 1 |
| Phase 3: persistence fix | 1-2 | Medium | Phases 1, 2 |
| Phase 4: P5 theorem | 0.5-1 | Low | Phase 3 |
| Phase 5: P6 theorem | 2-4 | High | Phase 4 |
| Phase 6: Documentation | 1-2 | Low | Phases 4, 5 |
| **Total** | **6-10.5** | Medium | - |

## Verification Commands

```bash
# After each Lean phase:
lake build Logos.Core.Theorems.Perpetuity

# After Phase 1-2 (Formula.lean changes):
lake build Logos.Core.Syntax.Formula

# After all phases:
lake build
lake test
lake lint

# Check sorry count:
grep -c "sorry" Logos/Core/Theorems/Perpetuity.lean
# Expected: 0

# Check axiom count in Perpetuity module:
grep -c "^axiom" Logos/Core/Theorems/Perpetuity.lean
# Expected: 3 (pairing, dni, future_k_dist - NOT perpetuity_5, perpetuity_6)
```

## Appendix: Formula Structure Reference

For debugging formula structure issues:

```lean
-- diamond φ = φ.neg.box.neg = (φ.imp bot).box.imp bot
-- sometimes φ = φ.neg.always.neg
-- always φ = φ.all_past.and (φ.and φ.all_future)
--          = φ.all_past.and (φ.and φ.all_future)
--          = (φ.all_past.imp (φ.and φ.all_future).neg).neg

-- swap_temporal preserves:
--   atom, bot, imp structure, box structure
-- swap_temporal swaps:
--   all_past ↔ all_future

-- Key identities:
-- swap_temporal (φ.neg) = (swap_temporal φ).neg  [Phase 2]
-- swap_temporal (φ.diamond) = (swap_temporal φ).diamond  [Phase 1]
-- swap_temporal (φ.always) = (swap_temporal φ).always  [follows from above]
-- swap_temporal (φ.sometimes) = (swap_temporal φ).sometimes  [follows from above]
```
