# Research Report: Enumerate Derived Temporal Operators

**Task**: 272
**Date**: 2026-06-03
**Session**: sess_1780516521_ff6a96

## Executive Summary

This report catalogs all derived temporal operators currently defined in the BimodalLogic formalization, identifies gaps relative to standard temporal/bimodal logic literature, and proposes new derived operators needed to unlock further bimodal proofs.

---

## 1. Current State of Temporal Operators

### 1.1 Primitive Constructors (in Formula.lean)

The `Formula` inductive type has 6 constructors:

| Constructor | Notation | Semantics |
|-------------|----------|-----------|
| `atom` | p | Propositional atom |
| `bot` | bottom | Falsum |
| `imp` | phi -> psi | Implication |
| `box` | box phi | Modal necessity (S5) |
| `untl` | U(phi, psi) | Until (Burgess: event phi, guard psi) |
| `snce` | S(phi, psi) | Since (Burgess: event phi, guard psi) |

### 1.2 Derived Operators Already Defined (in Formula.lean)

| Operator | Name | Definition | Status |
|----------|------|------------|--------|
| `top` | Verum | `bot.imp bot` | Defined |
| `neg` | Negation | `phi.imp bot` | Defined |
| `and` | Conjunction | `(phi.imp psi.neg).neg` | Defined |
| `or` | Disjunction | `phi.neg.imp psi` | Defined |
| `diamond` | Possibility | `phi.neg.box.neg` | Defined |
| `some_future` | F (Eventually) | `untl phi top` | Defined |
| `some_past` | P (Previously) | `snce phi top` | Defined |
| `all_future` | G (Globally) | `(some_future phi.neg).neg` | Defined |
| `all_past` | H (Historically) | `(some_past phi.neg).neg` | Defined |
| `always` | triangle (Omnitemporal) | `phi.all_past.and (phi.and phi.all_future)` | Defined |
| `sometimes` | nabla (Sometime) | `phi.neg.always.neg` | Defined |
| `next` | X (Next) | `untl phi bot` | Defined |
| `prev` | Y (Previous) | `snce phi bot` | Defined |
| `weak_future` | G' (Reflexive Future) | `phi.and phi.all_future` | Defined |
| `weak_past` | H' (Reflexive Past) | `phi.and phi.all_past` | Defined |
| `swap_temporal` | Temporal Duality | Swaps untl/snce recursively | Defined |

### 1.3 Additional Derived Operators (in ModalS5.lean)

| Operator | Name | Definition | Status |
|----------|------|------------|--------|
| `iff` | Biconditional | `(A.imp B).and (B.imp A)` | Defined |

---

## 2. Current Proof Library Inventory

### 2.1 Perpetuity Principles (P1-P6) -- ALL PROVEN (zero sorry)

| Theorem | Statement | File |
|---------|-----------|------|
| `perpetuity_1` | box phi -> always phi | Principles.lean |
| `perpetuity_2` | sometimes phi -> diamond phi | Principles.lean |
| `perpetuity_3` | box phi -> box (always phi) | Principles.lean |
| `perpetuity_4` | diamond (sometimes phi) -> diamond phi | Principles.lean |
| `perpetuity_5` | diamond (sometimes phi) -> always (diamond phi) | Principles.lean |
| `perpetuity_6` | sometimes (box phi) -> box (always phi) | Bridge.lean |

### 2.2 Temporal Derived Theorems (TemporalDerived.lean) -- ALL PROVEN

30 theorems across 5 categories:

- **G/H Distribution** (4): G_distribution, H_distribution, G_transitivity, H_transitivity
- **Temporal Monotonicity** (6): F_mono, P_mono, G_mono, H_mono, until_mono_guard, since_mono_guard, until_mono_event, since_mono_event
- **Temporal Duality** (2): F_neg_G, P_neg_H
- **G/H Distribution Variants** (4): G_and_intro, H_and_intro, G_imp_trans, H_imp_trans
- **Future-Past Interaction Chains** (4): connect_future_G, connect_past_H, connect_future_chain, connect_past_chain

### 2.3 Modal S5 Theorems (ModalS5.lean) -- PARTIAL

| Theorem | Statement | Status |
|---------|-----------|--------|
| `t_box_to_diamond` | box A -> diamond A | Proven |
| `box_disj_intro` | (box A or box B) -> box (A or B) | Proven |
| `box_contrapose` | box (A -> B) -> box (neg B -> neg A) | Proven |
| `t_box_consistency` | neg box (A and neg A) | Proven |
| `box_conj_iff` | box (A and B) <-> (box A and box B) | Proven |
| S4 nested modality theorems | Various | NOT STARTED |

### 2.4 Propositional Theorems (Propositional/) -- PROVEN

Full classical propositional library including: ecq, raa, efq, ldi, rdi, lce, rce, classical_merge, iff_intro, iff_elim_left, iff_elim_right, De Morgan laws, contraposition.

---

## 3. Gap Analysis: Missing Derived Operators

### 3.1 Missing Temporal Operators (HIGH PRIORITY)

These are standard operators from temporal logic literature that have no definition in the project:

#### 3.1.1 Release Operator (R)

**Definition**: `R(phi, psi) := neg (U(neg phi, neg psi))`

Semantics: "psi holds at all times until and including when phi first becomes true (or forever if phi never holds)." The Release operator is the dual of Until.

**Why needed**: Release is used extensively in temporal logic proofs about safety properties. It appears in temporal duality theorems and simplifies reasoning about "phi holds until released by psi."

#### 3.1.2 Weak Until (W)

**Definition**: `W(phi, psi) := U(phi, psi).or (G psi)` or equivalently `R(phi, phi.and psi)`

Semantics: "psi holds until phi becomes true, OR psi holds forever." Unlike Until, Weak Until does not require phi to eventually hold.

**Why needed**: Weak Until eliminates the eventuality requirement of Until, which is important for expressing liveness-without-guarantee properties.

#### 3.1.3 Trigger (T) -- Past dual of Release

**Definition**: `T(phi, psi) := neg (S(neg phi, neg psi))`

Semantics: Past-directed dual of Release, analogous to how Since is the past dual of Until.

**Why needed**: Completes the duality picture for past operators.

#### 3.1.4 Weak Since (WS)

**Definition**: `WS(phi, psi) := S(phi, psi).or (H psi)`

Semantics: Past dual of Weak Until.

**Why needed**: Completes the weak/strong duality picture.

### 3.2 Missing Bimodal Combination Operators (MEDIUM PRIORITY)

These combine modal and temporal operators in standard ways:

#### 3.2.1 Necessary-Always (box_always)

**Definition**: Already expressible as `phi.box.always` or `phi.always.box`.

**Note**: P3 (`box phi -> box (always phi)`) and P1 (`box phi -> always phi`) already relate these. However, a named abbreviation `necessary_always phi := (always phi).box` would improve readability.

#### 3.2.2 Possible-Sometimes (diamond_sometimes)

**Definition**: Already expressible as `phi.diamond.sometimes` or `phi.sometimes.diamond`.

**Note**: P4 (`diamond (sometimes phi) -> diamond phi`) and P2 (`sometimes phi -> diamond phi`) already relate these.

### 3.3 Missing Structural Theorems (HIGH PRIORITY)

These are theorems about existing operators that are not yet proven:

#### 3.3.1 Until Unfolding

**Target**: `U(phi, psi) <-> phi.or (psi.and (U(phi, psi).some_future))`

This is the key fixpoint characterization of Until. Under the BX axiom system, it should be derivable from BX5 (self-accumulation) and BX10 (eventuality extraction).

#### 3.3.2 Since Unfolding

**Target**: `S(phi, psi) <-> phi.or (psi.and (S(phi, psi).some_past))`

Past dual of Until Unfolding.

#### 3.3.3 G/H Induction Principles

**Target (G-induction)**: `(phi.and G(phi -> G'(phi))) -> G(phi)` where G'(phi) = phi.and G(phi).

Under irreflexive semantics, this replaces the standard reflexive G-induction.

#### 3.3.4 Temporal Necessitation for H

**Status**: Already defined as `past_necessitation` in GeneralizedNecessitation.lean.

#### 3.3.5 Weak Future/Past Properties

The operators `weak_future` (G' = phi and G phi) and `weak_past` (H' = phi and H phi) are defined but have NO proven properties. Needed:

- `box phi -> weak_future phi` (from box_to_present + box_to_future)
- `box phi -> weak_past phi` (from box_to_present + box_to_past)
- `weak_future phi -> phi` (left conjunction elimination)
- `weak_future phi -> all_future phi` (right conjunction elimination)
- `always phi <-> (weak_past phi).and (all_future phi)` (restructuring)

#### 3.3.6 Next/Prev Properties

The operators `next` (X) and `prev` (Y) are defined but have NO proven properties. Needed:

- `next phi -> some_future phi` (X implies F, from BX10 with psi=bot)
- `prev phi -> some_past phi` (Y implies P, from BX10' with psi=bot)
- `swap_temporal_next`/`swap_temporal_prev` (already proven in Formula.lean)
- Under discrete axioms: `G phi <-> phi.and (next (G phi))` (discrete G-unfolding)
- Under discrete axioms: `H phi <-> phi.and (prev (H phi))` (discrete H-unfolding)

#### 3.3.7 Always/Sometimes Duality

**Target**: `sometimes phi <-> neg (always (neg phi))` (definitional, but should be a simp lemma)
**Target**: `always phi -> phi` (from conjunction elimination on Hphi and phi and Gphi)
**Target**: `phi -> sometimes phi` (from disjunction introduction)

#### 3.3.8 Modal-Temporal Interaction (TF derived)

**Status**: `temp_future_derived` is already proven in Combinators.lean: `box phi -> G (box phi)`.

The past dual `box phi -> H (box phi)` is proven as `box_to_past (box phi)` composed with `modal_4`.

---

## 4. Task 271 Dependency Analysis

Task 271 completed the "active Until-negative rule for dense countermodel construction" in the tableau decision procedure. This is in the Decidability/Tableau.lean module and does not directly affect the syntactic proof system in Theorems/. However, it ensures the decision procedure correctly handles Until/Since negation patterns, which validates that the BX axiom system correctly captures these operators' behavior.

Task 272 can proceed independently -- the derived temporal operators are purely syntactic definitions and theorems in the proof system.

---

## 5. Prioritized Recommendations

### Tier 1: Quick Wins (definition + 1-3 line proofs)

1. **Define `release`**: `def release (phi psi : Formula) := (untl phi.neg psi.neg).neg`
2. **Define `weak_until`**: `def weak_until (phi psi : Formula) := (untl phi psi).or psi.all_future`
3. **Define `trigger`**: `def trigger (phi psi : Formula) := (snce phi.neg psi.neg).neg`
4. **Define `weak_since`**: `def weak_since (phi psi : Formula) := (snce phi psi).or psi.all_past`
5. **Prove `always_to_present`**: `always phi -> phi` (conjunction elimination)
6. **Prove `present_to_sometimes`**: `phi -> sometimes phi` (DNI on `always (neg phi)`)
7. **Prove `weak_future_left`**: `weak_future phi -> phi` (conjunction elimination)
8. **Prove `weak_future_right`**: `weak_future phi -> all_future phi` (conjunction elimination)
9. **Prove `weak_past_left`**: `weak_past phi -> phi` (conjunction elimination)
10. **Prove `weak_past_right`**: `weak_past phi -> all_past phi` (conjunction elimination)

### Tier 2: Medium Effort (5-20 line proofs)

11. **Prove `next_imp_some_future`**: `next phi -> some_future phi` (from BX10 with guard=bot)
12. **Prove `prev_imp_some_past`**: `prev phi -> some_past phi` (from BX10' with guard=bot)
13. **Prove `box_imp_weak_future`**: `box phi -> weak_future phi` (combine box_to_present + box_to_future)
14. **Prove `box_imp_weak_past`**: `box phi -> weak_past phi` (combine box_to_present + box_to_past)
15. **Prove `always_imp_all_future`**: `always phi -> all_future phi` (conjunction elimination chain)
16. **Prove `always_imp_all_past`**: `always phi -> all_past phi` (conjunction elimination chain)
17. **Prove Release duality**: `release phi psi <-> neg (untl (neg phi) (neg psi))`
18. **Prove `release_imp_weak_until`** structural relationship

### Tier 3: Substantial Effort (20+ line proofs)

19. **Until unfolding (forward)**: `U(phi, psi) -> phi.or (psi.and F(U(phi, psi)))` (from BX5 + BX10)
20. **Until unfolding (backward)**: requires careful axiom combination
21. **G-induction for discrete frames**: `(phi.and G(phi -> next phi)) -> G phi` (from Prior axioms + Z1)
22. **H-induction for discrete frames**: past dual of G-induction

### Tier 4: New Simp Lemmas

23. **`@[simp] sometimes_def`**: `sometimes phi = (always (neg phi)).neg`
24. **`@[simp] always_components`**: Characterize always in terms of H, phi, G
25. **`@[simp] release_def`**: Unfold release to its Until-based definition
26. **`@[simp] weak_until_def`**: Unfold weak_until

---

## 6. Impact on Bimodal Proofs

### What "unlocks" bimodal proofs means:

The current proof library has strong foundations (P1-P6, 30 temporal derived theorems, full propositional library) but lacks:

1. **Release/Weak Until**: Without these, proofs about safety properties and liveness-without-guarantee cannot be expressed in the object language. Many bimodal theorems about program correctness use these operators.

2. **Conjunction elimination for always/weak operators**: The `always` and `weak_future`/`weak_past` operators are defined as conjunctions, but there are no extraction lemmas. This means any proof that needs to go from `always phi` to `G phi` (or `H phi` or just `phi`) cannot proceed.

3. **Next/Prev properties**: Without `next phi -> F phi` and discrete unfolding properties, proofs about discrete temporal reasoning are blocked.

4. **Until/Since unfolding**: The fixpoint characterization is essential for inductive reasoning about eventuality properties.

### Estimated impact:

- Tier 1 items unlock approximately 10-15 new proof patterns
- Tier 2 items unlock approximately 5-10 additional bimodal interaction proofs
- Tier 3 items unlock inductive temporal reasoning (crucial for completeness arguments)

---

## 7. File Locations for Implementation

| Category | Target File |
|----------|-------------|
| New operator definitions | `Theories/Bimodal/Syntax/Formula.lean` (in the `Formula` namespace) |
| Structural simp lemmas | `Theories/Bimodal/Syntax/Formula.lean` (alongside existing swap_temporal lemmas) |
| Proof-system theorems | `Theories/Bimodal/Theorems/TemporalDerived.lean` (extend existing file) |
| Next/Prev properties | `Theories/Bimodal/Theorems/TemporalDerived.lean` (new section) |
| Release/WeakUntil properties | New file `Theories/Bimodal/Theorems/TemporalStructural.lean` or extend TemporalDerived.lean |
| Always/Sometimes properties | `Theories/Bimodal/Theorems/TemporalDerived.lean` (new section) |
| Discrete-frame properties | New file or extend LinearityDerivedFacts.lean (frame-class-specific) |
