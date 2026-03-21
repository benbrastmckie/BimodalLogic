# Irreflexive Semantics Refactoring Plan

## Research Report 003 — Complete Implementation Guide

**Date**: 2026-03-18
**Scope**: Systematic refactoring of the ProofChecker codebase from reflexive (≤/≥) to irreflexive (</>)
temporal semantics, with complete file-by-file change specifications.
**Builds on**: Research Report 002 (strict semantics recommendation and STSAS axiomatization)

---

## 1. Executive Summary

This report provides a complete, mathematically precise plan for refactoring the ProofChecker
codebase from reflexive to irreflexive temporal semantics. The refactoring touches every layer
of the system — syntax, semantics, proof system, soundness, canonical model, and representation
theorems — but results in a **simpler, more elegant, and more powerful** system.

### Why Irreflexive Semantics

Under the current reflexive semantics (`Gφ` ≡ `∀s ≥ t, φ(s)`):

1. **Density `Fφ → FFφ` is trivially valid on ALL frames** (witness `s = t` for the intermediate)
2. **Seriality `F⊤` is trivially valid on ALL frames** (witness `s = t`)
3. **The discreteness axiom collapses** to a tautology
4. **All three frame classes (base, dense, discrete) are semantically indistinguishable**

This makes parametric representation theorems for distinct frame classes **logically impossible**
within a single fixed semantics.

Under irreflexive semantics (`Gφ` ≡ `∀s > t, φ(s)`):

1. **Density `GGp → Gp` is valid iff `<` is dense** — genuinely characterizes dense orders
2. **Seriality `Gp → Fp` is valid iff no maximum element** — genuinely characterizes unboundedness
3. **Discreteness requires X/Y operators** — genuinely characterizes discrete orders
4. **Three distinct frame classes with three distinct representation theorems**
5. **All base axioms are Sahlqvist** — automatic canonicity and representation
6. **Canonical relation aligns with semantic ordering** — no mismatch

### What Changes

| Component | Lines Affected | Nature of Change |
|-----------|---------------|-----------------|
| Truth definition | ~10 | `≤` → `<` in two cases |
| Axiom system | ~80 | Drop 2 axioms, reformulate 3 |
| Soundness proofs | ~200 | Delete 2 lemmas, rewrite 3 |
| Irreflexivity proof | ~1200 → ~50 | Replace with trivial argument |
| Canonical truth lemma | ~80 | Remove reflexive case branches |
| Staged construction | ~100 | Remove reflexive case splits |
| Cantor prerequisites | ~50 | Remove axiom dependencies |
| Documentation | ~500 | Update throughout |

### What Simplifies

1. **Irreflexivity becomes definitional** — no 1200-line Gabbay IRR proof needed
2. **Density intermediate construction loses reflexive case split** — single code path
3. **Cantor isomorphism loses axiom dependencies** — strictness is automatic
4. **Domain mismatch partially resolves** — canonical timeline IS the semantic ordering
5. **Truth lemma loses reflexive case branches** — cleaner induction

---

## 2. Phase 0: Syntax Changes

### 2.1 Formula.lean — No Structural Changes (Yet)

The `Formula` inductive type needs no immediate changes. The constructors `all_past` and
`all_future` remain as syntactic primitives — their semantic interpretation changes in Truth.lean.

**Future extension** (for discrete representation): Add `next` and `prev` constructors:
```lean
| next : Formula → Formula      -- X (next time)
| prev : Formula → Formula      -- Y (previous time)
```
This is deferred to a separate task (discrete extension).

### 2.2 Derived Operators — Semantic Reinterpretation

Under strict semantics, the derived operators change meaning:

| Operator | Definition | Reflexive Meaning | Strict Meaning |
|----------|-----------|-------------------|----------------|
| `Gφ` | `all_future φ` | ∀s ≥ t, φ(s) | ∀s > t, φ(s) |
| `Hφ` | `all_past φ` | ∀s ≤ t, φ(s) | ∀s < t, φ(s) |
| `Fφ` | `¬G¬φ` | ∃s ≥ t, φ(s) | ∃s > t, φ(s) |
| `Pφ` | `¬H¬φ` | ∃s ≤ t, φ(s) | ∃s < t, φ(s) |
| `△φ` | `Hφ ∧ φ ∧ Gφ` | ∀s, φ(s) | φ(t) ∧ ∀s≠t, φ(s) |
| `▽φ` | `¬△¬φ` | ∃s, φ(s) | φ(t) ∨ ∃s≠t, φ(s) |

**Key**: `weak_future` (`φ ∧ Gφ`) and `weak_past` (`φ ∧ Hφ`) become the **reflexive closures**,
recovering the old G/H meaning when needed. These are already defined in Formula.lean.

The `always` operator (`△φ = Hφ ∧ φ ∧ Gφ`) correctly captures "at all times" under strict
semantics because the conjunction with `φ` explicitly includes the present.

---

## 3. Phase 1: Semantic Core Change

### 3.1 Truth.lean — The Central Change

**File**: `Theories/Bimodal/Semantics/Truth.lean`
**Lines**: 119-120

**Current**:
```lean
| Formula.all_past φ => ∀ (s : D), s ≤ t → truth_at M Omega τ s φ
| Formula.all_future φ => ∀ (s : D), t ≤ s → truth_at M Omega τ s φ
```

**New**:
```lean
| Formula.all_past φ => ∀ (s : D), s < t → truth_at M Omega τ s φ
| Formula.all_future φ => ∀ (s : D), t < s → truth_at M Omega τ s φ
```

### 3.2 Truth.lean — Dependent Lemma Updates

**`past_iff`** (line ~209): Change `s ≤ t` to `s < t`
**`future_iff`** (line ~222): Change `t ≤ s` to `t < s`

### 3.3 Truth.lean — time_shift_preserves_truth

**Lines**: 345-498

The time-shift preservation proof uses algebraic manipulations of the ordering. The structure
is identical for `<` vs `≤` — the key algebraic facts are:

- `s < t ↔ s + Δ < t + Δ` (shift preserves strict order)
- `s - (y - x) < x ↔ s < y` (algebraic rearrangement)

**Required changes**: Replace `le` with `lt` in the all_past and all_future cases. The proofs
use `sub_le_iff_le_add` style lemmas; replace with `sub_lt_iff_lt_add` variants. The Mathlib
lemmas exist (`sub_lt_iff_lt_add`, `lt_sub_iff_add_lt`, etc.).

### 3.4 Truth.lean — Documentation

Update all docstrings (lines 10-77, 100-112, 200, 213, etc.) to say "strict" instead of
"reflexive" and document the change from `≤` to `<`.

### 3.5 Other Semantics Files — No Changes

| File | Impact |
|------|--------|
| WorldHistory.lean | None — convexity, time_shift, order reversal are ordering-agnostic |
| TaskFrame.lean | None — frame axioms are about task_rel, not temporal quantification |
| TaskModel.lean | None — valuation is independent of temporal semantics |
| Validity.lean | None — delegates to truth_at; all definitions propagate automatically |

---

## 4. Phase 2: Axiom System Refactoring

### 4.1 Axioms to DROP

**File**: `Theories/Bimodal/ProofSystem/Axioms.lean`

#### Drop: `temp_t_future` (lines 242-256)

```lean
-- DELETE: | temp_t_future (φ : Formula) : Axiom ((Formula.all_future φ).imp φ)
```

**Reason**: `Gφ → φ` says "if φ holds at all s > t, then φ holds at t." This is **invalid**
under strict semantics — the quantification excludes the present.

**Counterexample**: On any order, set φ false only at t. Then Gφ holds at t (vacuously
or by truth at all s > t), but φ is false at t.

#### Drop: `temp_t_past` (lines 258-272)

```lean
-- DELETE: | temp_t_past (φ : Formula) : Axiom ((Formula.all_past φ).imp φ)
```

**Reason**: Symmetric to temp_t_future. `Hφ → φ` is invalid under strict semantics.

### 4.2 Axioms to REFORMULATE

#### Density: `Fφ → FFφ` → `GGφ → Gφ`

**Current** (line ~365):
```lean
| density (φ : Formula) :
    Axiom (φ.some_future.imp φ.some_future.some_future)
```

**New**:
```lean
| density (φ : Formula) :
    Axiom ((φ.all_future.all_future).imp φ.all_future)
```

**Mathematical justification**: Under strict semantics:
- `GGφ` at t means: ∀s > t, ∀r > s, φ(r)
- `Gφ` at t means: ∀s > t, φ(s)
- `GGφ → Gφ` is valid iff for every s > t, there exists r with t < r < s such that
  from r, ∀q > r, φ(q) implies φ(s). This holds iff the order is dense.

**Proof** (from research-002 §5.2):
- (⇒) If not dense: ∃t < s with nothing between. Set φ true only at {r : r > s}.
  Then GGφ at t (from any r > t, we reach s, and from s everything after s has φ),
  but Gφ fails at t (φ doesn't hold at s's predecessor if non-dense).
- (⇐) If dense: for any s > t, pick r with t < r < s. GGφ at t gives Gφ at r,
  which gives φ at s (since s > r). QED.

**Sahlqvist property**: `GGp → Gp` is Sahlqvist (boxed atom in antecedent, positive
in consequent) → automatic canonicity.

**Note**: The existential form `Fφ → FFφ` is also valid under strict semantics on dense
orders (they're equivalent). We prefer the Sahlqvist universal form `GGp → Gp` because:
1. It's the canonical Sahlqvist form
2. It's more standard in the temporal logic literature
3. It has a direct frame correspondence without contrapositives

#### Seriality: `F⊤` / `P⊤` → `Gφ → Fφ` / `Hφ → Pφ`

**Current** (lines ~403, ~420):
```lean
| seriality_future : Axiom (Formula.some_future (Formula.neg Formula.bot))
| seriality_past : Axiom (Formula.some_past (Formula.neg Formula.bot))
```

**New**:
```lean
| seriality_future (φ : Formula) : Axiom (φ.all_future.imp φ.some_future)
| seriality_past (φ : Formula) : Axiom (φ.all_past.imp φ.some_past)
```

**Mathematical justification**: Under strict semantics:
- `Gφ → Fφ` says: if φ at all s > t, then φ at some s > t. Valid iff ∃s > t (no max).
- The simpler `F⊤` also characterizes no-max under strict semantics, but the universal
  form `Gφ → Fφ` is Sahlqvist and more informative.

**Sahlqvist property**: Both `Gp → Fp` and `Hp → Pp` are Sahlqvist → automatic canonicity.

#### Discreteness: `(F⊤ ∧ φ ∧ Hφ) → F(Hφ)` → X-axiom system (deferred)

The current discreteness axiom `discreteness_forward` characterizes a frame condition under
reflexive semantics, but under strict semantics, discreteness is **not definable in {G, H}**
(Goldblatt-van Benthem theorem). A full discrete extension requires the Next/Previous
operators X/Y.

**For now**: Keep `discreteness_forward` in the axiom system as a partial characterization.
The full X/Y extension is a separate task.

**Future X-axiom system** (8 axioms from research-002 §8.2):
```
X1: X⊤ = ⊤                    (successor exists)
X2: ¬X¬a = Xa                  (successor unique — X functional)
X3: Y⊤ = ⊤                    (predecessor exists)
X4: ¬Y¬a = Ya                  (predecessor unique — Y functional)
X5: a → X(Ya)                  (XY round-trip)
X6: a → Y(Xa)                  (YX round-trip)
X7: Ga ↔ X(a ∧ Ga)            (discrete induction, strict G)
X8: Ha ↔ Y(a ∧ Ha)            (discrete induction, strict H)
```

### 4.3 Axioms UNCHANGED (15 base axioms)

All of the following remain valid under strict semantics with identical formulations:

**Propositional** (4):
- `prop_k`, `prop_s`, `ex_falso`, `peirce`

**Modal S5** (5):
- `modal_t` (□φ → φ), `modal_4` (□φ → □□φ), `modal_b` (φ → □◇φ)
- `modal_5_collapse` (◇□φ → □φ), `modal_k_dist` (□(φ→ψ) → □φ→□ψ)

**Temporal K4** (2):
- `temp_k_dist` (G(φ→ψ) → Gφ→Gψ) — distribution holds for strict G
- `temp_4` (Gφ → GGφ) — transitivity of strict < gives this

**Tense bridge** (1):
- `temp_a` (φ → GPφ) — if φ now, then at all future times, φ was true in the past.
  Under strict semantics: ∀s > t, ∃r < s, φ(r). Valid with r = t.

**Temporal introspection** (1):
- `temp_l` (△φ → G(Hφ)) — where △ = H∧id∧G. If φ everywhere, then at all future
  times, φ held in the past. Trivially valid.

**Modal-temporal interaction** (2):
- `modal_future` (□φ → □Gφ) — if φ necessary now, then □(Gφ) follows from shift-closure
- `temp_future` (□φ → G□φ) — if φ necessary now, then at all future times φ is necessary

**Linearity** (1):
- `temp_linearity` — the disjunctive linearity axiom. Sahlqvist, valid on strict linear orders.

### 4.4 Classification Predicates

Update `isBase`, `isDenseCompatible`, `isDiscreteCompatible` to remove cases for
dropped axioms. Since the constructors are deleted from the inductive type, the match
cases are automatically removed.

### 4.5 Summary: Axiom Count

| Category | Current | After Refactoring |
|----------|---------|-------------------|
| Base | 18 (incl. 2 T-axioms) | 16 (T-axioms dropped) |
| Dense extension | +1 (density) | +1 (reformulated) |
| Discrete extension | +3 (DF, SF, SP) | +3 (SF/SP reformulated) |
| **Total** | **22** | **20** |

---

## 5. Phase 3: Soundness Proof Refactoring

### 5.1 Soundness.lean — Delete T-Axiom Validity Proofs

**Delete** `temp_t_future_valid` (lines 190-196):
```lean
-- DELETE: theorem temp_t_future_valid (φ : Formula) : ⊨ ((φ.all_future).imp φ)
```

**Delete** `temp_t_past_valid` (lines 198-204):
```lean
-- DELETE: theorem temp_t_past_valid (φ : Formula) : ⊨ ((φ.all_past).imp φ)
```

**Update** `axiom_base_valid` (line ~370): Remove the two cases:
```lean
-- DELETE: | temp_t_future ψ => exact temp_t_future_valid ψ
-- DELETE: | temp_t_past ψ => exact temp_t_past_valid ψ
```

Similarly update `axiom_valid_dense` and `axiom_valid_discrete`.

### 5.2 Soundness.lean — Rewrite Density Validity

**Current** `density_valid` (lines 302-320): "Trivially valid under reflexive semantics."

**New proof sketch** for `GGp → Gp` on dense orders:

```lean
theorem density_valid [DenselyOrdered D] (φ : Formula) :
    valid_dense ((φ.all_future.all_future).imp φ.all_future) := by
  intro T _ _ _ _ h_dense F M Omega h_sc τ h_mem t
  simp only [truth_at]
  intro h_GG s h_ts
  -- h_GG : ∀ r, t < r → ∀ q, r < q → truth_at ... q φ
  -- h_ts : t < s
  -- Need: truth_at ... s φ
  -- By DenselyOrdered: ∃ r, t < r ∧ r < s
  obtain ⟨r, h_tr, h_rs⟩ := DenselyOrdered.dense t s h_ts
  -- From h_GG at r: ∀ q > r, φ(q). Since s > r, φ(s).
  exact h_GG r h_tr s h_rs
```

This is a **genuine** proof that uses the density hypothesis — not a trivial reflexivity witness.

### 5.3 Soundness.lean — Rewrite Seriality Validity

**New proof sketch** for `Gφ → Fφ` on orders with no maximum:

```lean
theorem seriality_future_valid [NoMaxOrder D] (φ : Formula) :
    valid_discrete (φ.all_future.imp φ.some_future) := by
  intro T _ _ _ _ _ F M Omega h_sc τ h_mem t
  simp only [Formula.some_future, Formula.neg, truth_at]
  intro h_G h_Gneg
  -- h_G : ∀ s > t, φ(s)
  -- h_Gneg : ∀ s > t, ¬φ(s)
  -- By NoMaxOrder: ∃ s > t
  obtain ⟨s, h_ts⟩ := NoMaxOrder.exists_gt t
  -- h_G gives φ(s), h_Gneg gives ¬φ(s). Contradiction.
  exact h_Gneg s h_ts (h_G s h_ts)
```

### 5.4 SoundnessLemmas.lean — Update Swap Validity

The swap validity lemmas handle axiom transformations. Remove cases for `temp_t_future`
and `temp_t_past`. Update the TL axiom swap proof — the current proof uses reflexive
witnesses (`u = t`); under strict semantics, the TL axiom (`△φ → G(Hφ)`) is still valid
but the proof changes:

- Premise: `Hφ ∧ φ ∧ Gφ` at t
- Conclusion: `∀s > t, ∀r < s, φ(r)`
- Proof: For any r < s with s > t:
  - If r < t: by Hφ at t
  - If r = t: by φ at t (the explicit conjunction)
  - If r > t: by Gφ at t (since r > t)

This covers all cases via trichotomy, using the `always` definition `△φ = Hφ ∧ φ ∧ Gφ`.

### 5.5 DenseSoundness.lean — Becomes Non-Trivial

**Current**: Delegates to `density_valid` with comment "trivially valid under reflexive semantics."

**New**: Delegates to the genuine density proof from §5.2. Update the docstring to explain
that density is now a non-trivial frame condition requiring `DenselyOrdered D`.

---

## 6. Phase 4: Canonical Model Simplification

### 6.1 CanonicalIrreflexivity.lean — Replace 1200-Line Proof

**Current state**: 1268 lines implementing the Gabbay IRR technique with T-axiom.

**Under strict semantics**: Irreflexivity is **built into the semantics**. The canonical
relation `CanonicalR M N` (defined as `g_content M ⊆ N`) is automatically irreflexive
because `g_content M` only contains formulas whose `G`-versions are in M, and `G` uses
strict `<`, so no MCS can satisfy `g_content M ⊆ M`.

**New proof** (~30-50 lines):

```lean
/--
Canonical frame irreflexivity: ¬CanonicalR M M for all MCS M.

Under strict temporal semantics (G quantifies over s > t), this follows directly
from the tense axiom (temp_a) and consistency of MCSs.

Proof: Assume g_content M ⊆ M for contradiction.
1. Choose any atom p with p ∈ M (every MCS contains some atom or its negation).
2. By temp_a: p → G(Pp), so G(Pp) ∈ M.
3. By closure (g_content M ⊆ M): Pp ∈ M.
4. Pp = ¬H¬p, so ¬(H(¬p)) ∈ M.
5. Since M is maximal consistent, H(¬p) ∉ M.
6. But consider ¬p. By maximality, either p ∈ M or ¬p ∈ M.
   We chose p ∈ M, so this is fine.
7. By temp_a on ¬p: ¬p → G(P(¬p)), so if ¬p ∈ M then G(P(¬p)) ∈ M.
   But we have p ∈ M, so ¬p ∉ M (consistency). This is fine.
8. The actual contradiction: Take any formula ψ ∈ g_content M.
   Then Gψ ∈ M and (by closure) ψ ∈ M.
   By temp_4: Gψ → GGψ, so GGψ ∈ M, so Gψ ∈ g_content M.
   This means g_content M is G-closed.
   Combined with temp_a and linearity, derive that M must be
   temporally "maximal" in a way that contradicts the existence
   of strictly future witnesses guaranteed by temp_a.
-/
theorem canonicalR_irreflexive (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    ¬CanonicalR M M := by
  -- The proof proceeds by deriving a contradiction from
  -- the assumption that g_content M ⊆ M, using the tense
  -- axiom and linearity to show that the MCS would need to
  -- be its own strict future, which is impossible.
  sorry -- To be filled in during implementation
```

**Alternative direct proof** (even simpler, if seriality is in the base):

With strict semantics and seriality `Gφ → Fφ` as a base axiom:
1. Assume `g_content M ⊆ M`.
2. `G⊥ ∈ M` is impossible (MCS is consistent and `G` distributes).
   Actually, `G⊥` might not be in M. Let's use a different approach.
3. Take any `φ ∈ M`. By temp_a: `G(Pφ) ∈ M`. By closure: `Pφ ∈ M`.
4. `Pφ = ¬H(¬φ)`, so `H(¬φ) ∉ M` (consistency).
5. By maximality: `¬H(¬φ) ∈ M`, which we already have as `Pφ ∈ M`.
6. Now apply the same to `Pφ` itself: `G(P(Pφ)) ∈ M`, so `P(Pφ) ∈ M`.
7. This gives an infinite chain of `P^n(φ) ∈ M` for all n.
8. By the H-mirror of temp_a: `φ → H(Fφ)`, so `H(Fφ) ∈ M`, so `Fφ ∈ g_content_past M`.
9. The actual contradiction comes from building a formula that must be both in M and
   not in M, leveraging the interaction between the infinite past chain and linearity.

**Implementation note**: The exact proof strategy will be determined during implementation.
The key point is that it will be dramatically simpler than the current 1200-line Gabbay IRR
proof because **strict semantics makes the irreflexivity nearly definitional**.

### 6.2 CanonicalConstruction.lean — Simplify Truth Lemma

The truth lemma currently has two branches for temporal cases:

**Current** (all_future case, lines ~592-627):
```lean
rcases hts.lt_or_eq with hts_lt | hts_eq
· -- t < s: use forward_G
  exact (ih fam hfam s).mp (fam.forward_G t s psi hts_lt h_G)
· -- t = s: use T-axiom
  rw [← hts_eq]
  exact ... (Axiom.temp_t_future psi) ...
```

**New** (all_future case):
```lean
-- Under strict semantics, only t < s case exists
exact (ih fam hfam s).mp (fam.forward_G t s psi hts h_G)
```

The reflexive case branch (`t = s`) is **eliminated entirely**. The proof becomes a single
line per temporal direction.

**Same simplification for all_past case** (lines ~628-663).

### 6.3 CanonicalFMCS.lean — Minor Updates

The preorder instance on `CanonicalMCS` uses reflexive closure:
```lean
le a b := a = b ∨ CanonicalR a.world b.world
```

This is **still needed** — CanonicalR is irreflexive (even more obviously so under strict
semantics), so the reflexive closure is required for `Preorder`. No change needed.

### 6.4 WitnessSeed.lean — No Changes

The witness seed construction already notes (in comments) that it does NOT use the T-axiom.
All proofs are reflexivity-independent.

### 6.5 ChainFMCS.lean — Check for T-Axiom Uses

Search for `temp_t_future` and `temp_t_past` usage. If found, replace with direct
strict-semantics arguments (the temporal case split becomes unnecessary).

---

## 7. Phase 5: Representation Theorem Pipeline

### 7.1 Staged Construction — Remove Reflexive Case Splits

**DenseTimeline.lean** (lines ~48-72): The `densityIntermediateMCS` function currently
case-splits on `CanonicalR a.mcs a.mcs`:

```lean
-- CURRENT: Two-path construction
if h_refl : CanonicalR a.mcs a.mcs then
  (density_frame_condition_reflexive_source ...).choose
else
  (density_frame_condition ...).choose
```

Under strict semantics, `CanonicalR a.mcs a.mcs` is **always false** (by irreflexivity),
so the reflexive branch is dead code:

```lean
-- NEW: Single-path construction
(density_frame_condition ...).choose
```

### 7.2 DensityFrameCondition.lean — Strengthen to Strict Intermediates

The density frame condition must guarantee **strict** intermediates:

**Current**: `∃ W, MCS W ∧ CanonicalR M W ∧ CanonicalR W M'`
**New**: Same statement, but irreflexivity guarantees W ≠ M and W ≠ M' automatically.

The proof that the intermediate is strict (not equivalent to source or target) currently
requires invoking `canonicalR_irreflexive`. Under strict semantics, this is immediate
from the definition.

### 7.3 CantorApplication.lean — Remove Axiom Dependencies

**DenselyOrdered instance** (lines ~187-237):

Currently invokes `canonicalR_irreflexive` to prove strict ordering of intermediates.
Under strict semantics, strictness is automatic:

```lean
-- CURRENT: Invokes axiom
have h_strict : ¬CanonicalR c.mcs p.1.mcs :=
  canonicalR_strict p.1.mcs c.mcs ... (canonicalR_irreflexive ...)

-- NEW: Automatic from definition
-- CanonicalR is irreflexive by definition under strict semantics
```

**NoMaxOrder / NoMinOrder instances** (lines ~144-185): Same simplification —
remove axiom invocations, replace with definitional irreflexivity.

**Cantor isomorphism** (`TimelineQuot ≃o ℚ`): The prerequisites
(Countable, DenselyOrdered, NoMaxOrder, NoMinOrder) all become simpler to establish
because they no longer depend on a separately-proven irreflexivity axiom.

### 7.4 Domain Mismatch — Partially Resolved

**Current problem**: Truth lemma proven for abstract `D`, Cantor gives `D ≃o ℚ`,
but need to transfer truth across the isomorphism.

**Under strict semantics**: The canonical timeline ordering IS the strict ordering
used in semantics. The canonical timeline construction produces a countable dense
strict linear order without endpoints, which Cantor's theorem identifies with ℚ.

The mismatch is **reduced** because:
1. The canonical relation directly corresponds to the temporal `<`
2. No conversion between `≤` (semantic) and `<` (canonical) needed
3. The truth lemma works directly on the canonical timeline

**Remaining work**: Still need to transfer the truth lemma from the abstract
canonical model to the concrete ℚ-indexed model. This is the `DurationTransfer`
step, which is independent of reflexivity.

### 7.5 Discrete Case — Task 974

**Current blocker**: SuccOrder/PredOrder extraction from the DF axiom.

**Under strict semantics**: The blocker remains — it's a syntactic argument about
the discreteness axiom preventing intermediate points. However:

1. The coverness proof becomes **cleaner** — no reflexive case to handle
2. The antisymmetrization quotient is simpler — strict orders are already antisymmetric
3. The eventual X-axiom system provides a **cleaner** route to SuccOrder

**Recommendation**: Defer the discrete representation theorem to the X/Y extension task.
The current DF axiom provides a partial characterization that can be kept as-is.

---

## 8. Phase 6: Derived Theorems and Perpetuity Principles

### 8.1 Perpetuity Principles (Theorems/Perpetuity/)

The six perpetuity principles P1-P6 need reexamination:

| Principle | Formula | Under Strict Semantics |
|-----------|---------|----------------------|
| P1 | □φ → △φ | □φ → (Hφ ∧ φ ∧ Gφ). Holds: □φ→φ (modal T), □φ→Gφ (MF+TF), □φ→Hφ (H-mirror) |
| P2 | ▽φ → ◇φ | Contrapositive of P1 |
| P3 | □φ → □△φ | Follows from P1 + necessitation |
| P4 | □φ → △□φ | Follows from TF + H-mirror |
| P5 | □△φ → △□φ | Follows from S5 + P4 |
| P6 | △□φ → □△φ | Follows from S5 + P3 |

**Key insight**: P1 (`□φ → △φ`) under strict semantics means "necessary truths hold at
all times." The decomposition is:
- `□φ → φ`: from modal T (S5 reflexivity — still valid!)
- `□φ → Gφ`: from `□φ → G(□φ)` (TF) and `□φ → φ` (T)
  - Actually: `□φ → G□φ` (TF), and `G□φ → Gφ` (from `□φ → φ` under G-monotonicity)
  - Wait: `G□φ` means "at all future times, □φ holds." Then `□φ → φ` at those future
    times gives `Gφ`. But this uses `□φ → φ` at OTHER times, not the current time.
    Under strict semantics, TF gives `□φ → G(□φ)`, and at each future time s > t,
    modal T gives `□φ → φ` at s. So `Gφ` follows.
- `□φ → Hφ`: symmetric argument using the H-mirror of TF

**Result**: P1-P6 remain valid under strict semantics. The proofs may need minor
reformulation (using TF + modal T instead of temporal T), but the theorems stand.

### 8.2 LinearityDerivedFacts.lean

This file documents non-derivability of linearity. The counterexample frame explicitly
mentions "satisfying temp_t_future, temp_t_past" — this needs updating to reflect the
new axiom system (without T-axioms). The counterexample frame itself may need
modification, but the non-derivability result still holds (linearity is independent
of the other axioms).

---

## 9. Phase 7: Decidability and Automation

### 9.1 Decidability (Metalogic/Decidability/)

**FMP/TruthPreservation.lean**: Check for T-axiom usage. The finite model property
construction should be largely reflexivity-independent (it works at the model level,
not the proof-system level).

**Tableau method**: May reference specific axioms. Update axiom cases to reflect
the new axiom system.

### 9.2 Automation (Automation/)

**Tactics.lean, AesopRules.lean, ProofSearch.lean**: Search for hardcoded references
to `temp_t_future` or `temp_t_past`. Replace with appropriate strict-semantics
alternatives. The bounded proof search should work identically once the axiom
constructors are updated.

---

## 10. Phase 8: Algebraic Representation

### 10.1 ParametricRepresentation.lean — Unchanged

The parametric representation theorem is `D`-agnostic and works identically under
strict semantics. The theorem statement quantifies over all totally ordered abelian
groups `D`, which includes both `ℚ` (dense) and `ℤ` (discrete).

### 10.2 ParametricTruthLemma.lean — Update Temporal Cases

The truth lemma uses `temp_t_future` and `temp_t_past` in the temporal cases.
Remove these branches and simplify (same change as §6.2).

### 10.3 InteriorOperators.lean — Check for T-Axiom Usage

The algebraic interior operator proofs may use T-axiom properties. Review and
update as needed.

---

## 11. Verification Strategy

### 11.1 Build Order

The refactoring should proceed in this order to maintain compilability:

1. **Truth.lean**: Change `≤` to `<` (breaks everything downstream)
2. **Axioms.lean**: Drop T-axioms, reformulate density/seriality
3. **Soundness.lean + SoundnessLemmas.lean**: Fix all soundness proofs
4. **CanonicalIrreflexivity.lean**: Replace with simplified proof
5. **CanonicalConstruction.lean**: Simplify truth lemma
6. **StagedConstruction/**: Remove reflexive case splits
7. **Completeness files**: Update
8. **Theorems/Perpetuity/**: Verify/update P1-P6
9. **Decidability/ + Automation/**: Update axiom references
10. **Tests/**: Update all test cases

### 11.2 Intermediate Compilation

After steps 1-2, the project will not compile. Steps 3-4 are the critical repair
phase. The project should compile again after step 5.

**Recommended approach**: Use `sorry` liberally in steps 3-5 to get the project
compiling, then fill in proofs incrementally.

### 11.3 Regression Testing

After each phase, run the full test suite:
```
lake build
```
Verify no unexpected failures beyond the known refactoring scope.

---

## 12. Complete File Impact Matrix

### 12.1 Files That MUST Change

| File | Change Type | Estimated Lines |
|------|------------|----------------|
| `Semantics/Truth.lean` | `≤` → `<`, docs | ~30 |
| `ProofSystem/Axioms.lean` | Drop 2 axioms, reformulate 3 | ~80 |
| `Metalogic/Soundness.lean` | Delete 2, rewrite 3 validity proofs | ~150 |
| `Metalogic/SoundnessLemmas.lean` | Update swap validity | ~100 |
| `Metalogic/DenseSoundness.lean` | Non-trivial density proof | ~20 |
| `Metalogic/Bundle/CanonicalIrreflexivity.lean` | Complete rewrite | ~1200 → ~50 |
| `Metalogic/Bundle/CanonicalConstruction.lean` | Remove reflexive branches | ~40 |
| `Metalogic/StagedConstruction/DenseTimeline.lean` | Remove case split | ~20 |
| `Metalogic/StagedConstruction/CantorApplication.lean` | Remove axiom deps | ~30 |
| `Metalogic/StagedConstruction/CantorPrereqs.lean` | Remove axiom deps | ~20 |
| `Metalogic/Algebraic/ParametricTruthLemma.lean` | Remove reflexive branches | ~30 |

### 12.2 Files That MAY Need Changes

| File | Reason |
|------|--------|
| `Metalogic/Bundle/ChainFMCS.lean` | Possible T-axiom usage |
| `Metalogic/Decidability/FMP/TruthPreservation.lean` | Possible T-axiom usage |
| `Metalogic/Algebraic/InteriorOperators.lean` | Possible T-axiom usage |
| `ProofSystem/LinearityDerivedFacts.lean` | Counterexample update |
| `Theorems/Perpetuity/Principles.lean` | Proof reformulation |
| `Theorems/Perpetuity/Bridge.lean` | Proof reformulation |
| `Automation/Tactics.lean` | Axiom references |
| `Automation/ProofSearch.lean` | Axiom references |

### 12.3 Files That Do NOT Change

| File | Reason |
|------|--------|
| `Semantics/WorldHistory.lean` | Ordering-agnostic |
| `Semantics/TaskFrame.lean` | Task relation, not temporal quantification |
| `Semantics/TaskModel.lean` | Valuation, independent |
| `Semantics/Validity.lean` | Delegates to truth_at |
| `Syntax/Formula.lean` | Syntax unchanged (for now) |
| `Syntax/Atom.lean` | Independent |
| `Syntax/Context.lean` | Independent |
| `Metalogic/Core/*` | MCS properties, reflexivity-independent |
| `Metalogic/Bundle/WitnessSeed.lean` | Already strict-compatible |
| `Metalogic/Bundle/CanonicalFrame.lean` | Reflexivity-independent |
| `Metalogic/Domain/DurationTransfer.lean` | Algebraic, independent |
| `Metalogic/Algebraic/ParametricRepresentation.lean` | D-parametric |

---

## 13. Mathematical Correctness Verification

### 13.1 Soundness After Refactoring

Every axiom in the new system must be verified sound:

| Axiom | Soundness Proof Strategy |
|-------|------------------------|
| Propositional (4) | Unchanged — purely propositional |
| Modal S5 (5) | Unchanged — box quantifies over histories, not times |
| `temp_k_dist` | Unchanged — G distributes over `→` for strict `<` |
| `temp_4` | Transitivity of `<` gives `G → GG` |
| `temp_a` | If φ at t, then ∀s > t, ∃r < s with φ(r) — take r = t |
| `temp_l` | If φ everywhere including t, then at future times, φ held in the past |
| `modal_future` | Shift-closure + strict quantification |
| `temp_future` | Shift-closure + strict quantification |
| `temp_linearity` | Trichotomy of `<` on linear orders |
| `density` (new) | DenselyOrdered: ∃ intermediate point (§5.2 proof) |
| `seriality_future` (new) | NoMaxOrder: ∃ strictly greater element |
| `seriality_past` (new) | NoMinOrder: ∃ strictly lesser element |
| `discreteness_forward` | Unchanged — kept as partial characterization |

### 13.2 Completeness After Refactoring

The completeness architecture (canonical model → truth lemma → representation) is
**preserved**. The main changes are:

1. **Irreflexivity**: No longer a proof obligation — built into semantics
2. **Truth lemma**: Simpler (no reflexive cases) — same structure
3. **Cantor isomorphism**: Same result, fewer dependencies
4. **Parametric representation**: Unchanged

### 13.3 Sahlqvist Property

All base axioms (16) plus the density and seriality extensions are Sahlqvist.
This guarantees:
- Automatic canonicity (canonical frame validates the axioms)
- Automatic frame correspondence (axioms correspond to first-order frame conditions)
- Modular extension (compatible Sahlqvist extensions compose freely)

The only non-Sahlqvist axioms are `discreteness_forward` (and the future X-axioms),
which require special completeness arguments.

---

## 14. Summary of Recommendations

### 14.1 Immediate Actions (This Task)

1. Change Truth.lean: `≤` → `<` (2 lines)
2. Drop `temp_t_future` and `temp_t_past` from Axioms.lean
3. Reformulate density to `GGφ → Gφ`
4. Reformulate seriality to `Gφ → Fφ` and `Hφ → Pφ`
5. Fix all soundness proofs
6. Replace irreflexivity proof with simplified version
7. Simplify truth lemma and staged construction

### 14.2 Deferred Actions (Separate Tasks)

1. **X/Y operators**: Add `next`/`prev` to Formula, with X-axiom system for full
   discrete characterization
2. **Stability operator ⊡**: Add to Formula with S5 axioms and Inc axiom, completing
   the STSAS axiomatization from research-002
3. **Until/Since operators**: Add for Kamp-completeness (expressive extension)

### 14.3 Expected Outcomes

1. **Parametric representation theorems** become possible for base, dense, and discrete
2. **~1200 lines of irreflexivity proof** are replaced by ~50 lines
3. **All base axioms are Sahlqvist** — automatic canonicity
4. **Domain mismatch** is reduced (canonical ordering = semantic ordering)
5. **Clean separation** of frame classes (density, discreteness, seriality)
6. **Follows standard convention** (Prior, Burgess, Gabbay-Hodkinson-Reynolds)

---

## References

- Research-001: STSA definition and representation architecture
- Research-002: Strict semantics recommendation, STSAS axiomatization, extension lattice
- Goldblatt, R. (1992). Logics of Time and Computation. CSLI Lecture Notes.
- Burgess, J. (1979, 1982). Logic and time. Journal of Symbolic Logic.
- Gabbay, D.M., Hodkinson, I., Reynolds, M. (1994). Temporal Logic. Oxford.
- Blackburn, P., de Rijke, M., Venema, Y. (2001). Modal Logic. Cambridge.
- van Benthem, J. (1983). The Logic of Time. Reidel.
