# Teammate C Findings: TaskFrame-Specific Semantics and Completeness Under Reflexive Semantics

**Date**: 2026-03-21
**Focus**: TaskFrame semantics under reflexive interpretation and completeness prospects

---

## Key Findings

### 1. TaskFrame Architecture: NOT Standard Kripke Frames

**Critical Observation**: The codebase uses a **two-sorted** semantic architecture that is fundamentally different from standard Kripke frames:

```lean
-- From TaskFrame.lean:93-97
structure TaskFrame (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] where
  WorldState : Type
  task_rel : WorldState → D → WorldState → Prop
  nullity_identity : ∀ w u, task_rel w 0 u ↔ w = u
  forward_comp : ∀ w u v x y, 0 ≤ x → 0 ≤ y → task_rel w x u → task_rel u y v → task_rel w (x + y) v
  converse : ∀ w d u, task_rel w d u ↔ task_rel u (-d) w
```

**Key structural differences from Kripke frames**:

| Aspect | Kripke Frames | TaskFrame |
|--------|---------------|-----------|
| Primary sort | Single: worlds W | Two: WorldState W and Duration D |
| Accessibility | R ⊆ W × W | task_rel ⊆ W × D × W |
| Modality interpretation | Box = ∀ accessible worlds | Temporal = ∀ times in order on D |
| Frame structure | Accessibility relation | Time group structure on D |

The temporal modalities G and H do **not** quantify over worlds via an accessibility relation. They quantify over **time points** via the linear order on D.

### 2. G and H Under Reflexive Semantics: Definition Change

**Current Strict Semantics** (from Truth.lean:115-122):
```lean
def truth_at (M : TaskModel F) (Omega : Set (WorldHistory F))
    (τ : WorldHistory F) (t : D) : Formula → Prop
  | Formula.all_past φ => ∀ (s : D), s < t → truth_at M Omega τ s φ
  | Formula.all_future φ => ∀ (s : D), t < s → truth_at M Omega τ s φ
```

**Under Reflexive Semantics**:
```lean
-- PROPOSED CHANGE
  | Formula.all_past φ => ∀ (s : D), s ≤ t → truth_at M Omega τ s φ
  | Formula.all_future φ => ∀ (s : D), t ≤ s → truth_at M Omega τ s φ
```

**Critical Question**: Does TaskFrame have a `≤` relation?

**Answer**: **Yes, implicitly**. TaskFrame has `D : Type*` with `[LinearOrder D]`, which provides:
- `<` (strict order from LinearOrder)
- `≤` (non-strict order, derived: `a ≤ b ↔ a < b ∨ a = b`)

**The reflexive semantics would use the existing Mathlib order infrastructure** — no new definitions needed on TaskFrame itself.

### 3. WorldHistory Interaction

A key constraint: WorldHistory requires `respects_task` (lines 96-97):
```lean
respects_task : ∀ (s t : D) (hs : domain s) (ht : domain t),
    s ≤ t → F.task_rel (states s hs) (t - s) (states t ht)
```

**Under reflexive semantics**: This constraint is unchanged. The reflexivity of the *temporal order interpretation* (G/H including the present) is independent of the task relation constraint (which already uses `s ≤ t` non-strictly).

**No changes to WorldHistory.lean required** for switching to reflexive semantics.

### 4. Canonical Model Construction Under Reflexive Semantics

**The CanonicalR Definition** (from CanonicalFrame.lean):
```lean
def CanonicalR (M N : Set Formula) : Prop := g_content M ⊆ N
```
where `g_content M = {φ : G(φ) ∈ M}`.

**Under Strict Semantics**: G(φ) means "φ at all strictly future times s > t". So `g_content M ⊆ M` would mean M is its own strict future — requiring t > t, impossible.

**Under Reflexive Semantics**: G(φ) means "φ at all future-or-present times s ≥ t". So `g_content M ⊆ M` would mean "for all φ, if G(φ) ∈ M then φ ∈ M".

This is exactly the **T-axiom** (G(φ) → φ)! Under reflexive semantics:
- The T-axiom becomes valid
- CanonicalR(M, M) can hold (M is reflexively accessible to itself)
- But this is **expected** — the canonical model is now reflexive, matching the frame class

**Key insight**: Under reflexive semantics, irreflexivity of CanonicalR is **not required or expected**. The completeness target becomes reflexive frames.

### 5. Can We Prove CanonicalR Irreflexive Under Reflexive Semantics?

**Question from research focus**: "Can we prove CanonicalR is irreflexive from the T-axiom under reflexive semantics?"

**Answer**: **NO, and we shouldn't**. Under reflexive semantics:
- The T-axiom (G(φ) → φ) becomes derivable (an axiom, actually)
- CanonicalR(M, M) would imply: g_content(M) ⊆ M
- By T-axiom: for all φ, if G(φ) ∈ M then φ ∈ M (via modus ponens)
- This is **consistent** — reflexive semantics allows self-accessibility

**The previous research (Task 967)** used the T-axiom proof to show a **different** property — a naming-set-based contradiction. Looking at CanonicalIrreflexivity.lean lines 23-28:

```lean
-- 3. Build naming set `atomFreeSubset(M, p) ∪ {p, H(¬p)}`
-- 4. Show naming set is consistent (via IRR contrapositive)
-- ...
-- 6. From naming set: `p ∈ M'` and `H(¬p) ∈ M'`
-- 7. Apply T-axiom: `H(¬p) → ¬p`, so `¬p ∈ M'` (modus ponens)
-- 8. Both `p` and `¬p` in M' contradicts MCS consistency
```

**This proves irreflexivity via the naming set construction, not directly from T-axiom**. The T-axiom is used in step 7 to derive a contradiction within the extended MCS M'.

**However**, the current codebase (Task 991) uses **strict semantics**, so:
- T-axiom (G(φ) → φ, H(φ) → φ) is NOT valid
- The naming set proof breaks at step 7
- Hence the axiom `canonicalR_irreflexive_axiom`

### 6. Target Frame Class Under Each Semantics

| Semantics | T-axiom Valid? | Target Frame Class | Irreflexivity? |
|-----------|----------------|-------------------|----------------|
| Strict (s > t) | No | Irreflexive strict linear orders | Required (axiom) |
| Reflexive (s ≥ t) | Yes | Reflexive linear orders | Not applicable |

**Completeness Under Strict Semantics** (current):
- Target: all strict linear orders (no first/last element, irreflexive)
- Canonical model must be irreflexive
- Irreflexivity is modal non-definable → axiom needed

**Completeness Under Reflexive Semantics** (alternative):
- Target: all reflexive linear orders (or equivalently, preorders with antisymmetry)
- Canonical model can be reflexive
- T-axiom is valid → completeness proof simplifies
- The 1170-line naming-set infrastructure in CanonicalIrreflexivity.lean becomes usable

### 7. Literature on Temporal Logic Over Strict Orders

**Question**: "Are there completeness theorems in the literature for temporal logic over strict orders with reflexive modalities?"

**Clarification**: This question conflates two orthogonal choices:
1. **Strict vs reflexive semantics**: Does G(φ) mean "∀s > t" or "∀s ≥ t"?
2. **Strict vs non-strict orders**: Is the temporal order `<` (irreflexive) or `≤` (reflexive)?

**Standard configurations**:
- **Kt.Li (Goldblatt 1992)**: Strict semantics over strict linear orders — matches the codebase
- **S4.3 temporal interpretation**: Reflexive semantics over reflexive preorders
- **The JPL paper (referenced in Truth.lean)**: Strict semantics (lines 1857-1872)

**Key reference**: The codebase's design follows the JPL paper, which explicitly uses strict semantics (G/H quantify over s > t / s < t). Switching to reflexive semantics would deviate from the paper's specification.

### 8. What Would Need to Change for Reflexive Semantics?

If we wanted to support both strict and reflexive interpretations:

**Truth.lean changes**:
```lean
-- Option 1: Parameterize on strictness
inductive Strictness | Strict | Reflexive

def truth_at (strict : Strictness) ... : Formula → Prop
  | Formula.all_future φ =>
    match strict with
    | .Strict => ∀ (s : D), t < s → truth_at strict M Omega τ s φ
    | .Reflexive => ∀ (s : D), t ≤ s → truth_at strict M Omega τ s φ
```

**Axioms.lean changes**:
```lean
-- Under reflexive semantics, add T-axiom for temporal operators:
| temporal_t_future (φ : Formula) : Axiom (φ.all_future.imp φ)
| temporal_t_past (φ : Formula) : Axiom (φ.all_past.imp φ)
```

**CanonicalIrreflexivity.lean changes**:
- Under reflexive semantics: remove axiom, use the naming set proof
- Under strict semantics: keep axiom (current state)

**Frame class completeness**:
- Would need separate completeness theorems for reflexive vs strict frames
- Current infrastructure supports multiple frame classes (Base, Dense, Discrete)
- Could add Reflexive/Strict as an additional axis

---

## Recommended Approach

### Option A: Keep Strict Semantics + Axiom (Current State)

**Rationale**:
1. Matches JPL paper specification
2. Axiom is mathematically sound (Gabbay 1981)
3. No language/semantics changes needed
4. Irreflexivity is a semantic truth under strict interpretation

**Action**: Fix documentation in CanonicalIrreflexivityAxiom.lean (it incorrectly claims the theorem is "proven").

### Option B: Switch to Reflexive Semantics

**Rationale**:
1. Eliminates the axiom entirely
2. T-axiom becomes valid
3. Naming set proof in CanonicalIrreflexivity.lean works
4. Simpler canonical model construction

**Action**:
1. Modify Truth.lean: change `<` to `≤` in temporal operator definitions
2. Add temporal T-axioms to Axioms.lean
3. Verify all soundness proofs still hold
4. Re-enable naming set proof path

**Tradeoff**: Deviates from JPL paper; changes meaning of G/H; requires audit of all proofs depending on strict semantics.

### Option C: Support Both (Parameterized Design)

**Rationale**:
1. Maximum flexibility
2. Separate completeness theorems for each frame class
3. User chooses interpretation per use case

**Action**: Significant refactoring to parameterize strictness throughout the codebase.

---

## Evidence/Examples

### TaskFrame Does Not Define `≤` Explicitly
```lean
-- TaskFrame has lt : Time → Time → Prop as strict order
-- But with [LinearOrder D], ≤ is automatically available via:
-- le_of_lt : a < b → a ≤ b
-- lt_or_eq_of_le : a ≤ b → a < b ∨ a = b
```

### T-Axiom Under Reflexive Semantics
```
Claim: G(φ) → φ is valid when G(φ)(t) = ∀s ≥ t. φ(s)
Proof: If G(φ) at t, then φ(s) for all s ≥ t. Since t ≥ t, φ(t).
```

### Naming Set Proof Path (from CanonicalIrreflexivity.lean:23-28)
```
Under reflexive semantics:
  Step 6: p ∈ M' and H(¬p) ∈ M'
  Step 7: H(¬p) → ¬p (T-axiom valid), so ¬p ∈ M'
  Step 8: Contradiction in M' (both p and ¬p)
```

---

## Confidence Level

**High**:
- TaskFrame architecture analysis (two-sorted vs Kripke)
- Reflexive semantics makes T-axiom valid
- CanonicalR irreflexivity not needed under reflexive semantics
- The naming set proof would work under reflexive semantics

**Medium**:
- Full scope of changes needed for reflexive semantics switch
- Impact on downstream theorems (soundness, frame conditions)
- Whether JPL paper alignment is a hard requirement

**Low**:
- Whether there's a hybrid approach using both strict and reflexive
- Performance/complexity tradeoffs of parameterized design

---

## Summary

The codebase uses **TaskFrame** semantics (two-sorted, time group over D) rather than standard Kripke frames. The temporal operators G/H quantify over the time order on D, not an accessibility relation.

Under **strict semantics** (current): G/H use `<`, T-axiom invalid, irreflexivity required but non-definable → axiom needed.

Under **reflexive semantics** (alternative): G/H would use `≤`, T-axiom valid, irreflexivity not required, naming set proof works → axiom eliminated.

**The fundamental question is architectural**: Should the codebase use strict or reflexive temporal semantics? The JPL paper specifies strict. The axiom is the mathematically correct formalization of a semantic truth under strict interpretation.
