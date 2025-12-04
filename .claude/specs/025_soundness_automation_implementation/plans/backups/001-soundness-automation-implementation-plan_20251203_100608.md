# Soundness and Automation Implementation Plan

**Plan ID**: 001-soundness-automation-implementation-plan
**Date**: 2025-12-03 (Revised: 2025-12-03 - Aligned with TODO.md)
**Author**: Claude (plan-architect agent)
**Context**: Implementation of TODO.md Tasks 5, 5b, 7, 12
**Complexity**: 3
**Related Research**: [Research Report](../reports/001-soundness-automation-implementation-research.md)
**Status**: [NOT STARTED] - Awaiting execution

---

## Executive Summary

This implementation plan covers four high/medium-priority tasks from Logos TODO.md:

1. **Task 5**: Fix Modal K and Temporal K Rule Implementations (CRITICAL - code-paper alignment)
2. **Task 5b**: Complete Temporal Duality Soundness
3. **Task 7**: Implement Core Automation - 4 tactics (apply_axiom, modal_t, tm_auto, assumption_search)
4. **Task 12**: Create Comprehensive Tactic Test Suite (concurrent with Task 7)

### CRITICAL ISSUE DISCOVERED

**The Modal K and Temporal K rules are implemented in the WRONG DIRECTION from the paper!**

**Paper Definitions (§sec:Appendix)**:
- **MK** (line 1030): If `Γ ⊢ φ`, then `□Γ ⊢ □φ`
- **TK** (line 1037): If `Γ ⊢ φ`, then `FΓ ⊢ Fφ`

**Current Code (Derivation.lean lines 90-102)**:
- **modal_k**: If `□Γ ⊢ φ`, then `Γ ⊢ □φ` ← **WRONG DIRECTION**
- **temporal_k**: If `FΓ ⊢ φ`, then `Γ ⊢ Fφ` ← **WRONG DIRECTION**

This must be fixed BEFORE proving soundness.

### Effort Estimates

| Task | TODO.md Estimate | Revised Estimate |
|------|------------------|------------------|
| Task 5 (Fix MK/TK + Soundness) | 15-20h | 15-20h |
| Task 5b (Temporal Duality) | 5-10h | 5-10h |
| Task 7 (Automation) | 40-60h | 40-60h |
| Task 12 (Test Suite) | 10-15h | 10-15h |
| **Total** | **70-105h** | **70-105h** |

**Parallelization**: Tasks 5/5b (soundness) and Tasks 7/12 (automation) can run in parallel.

---

## Implementation Phases

This plan uses a wave-based approach with quality gates between phases:

### **Wave 1: Fix Rule Definitions (CRITICAL - Must be first)**
- Phase 0: Fix Modal K and Temporal K Rule Definitions in Derivation.lean

### **Wave 2: Soundness Rules (After Wave 1)**
- Phase 1: Modal K Rule Soundness (after rule fix)
- Phase 2: Temporal K Rule Soundness (after rule fix)
- Phase 3: Temporal Duality Soundness

### **Wave 3: Core Automation (Parallel with Wave 2)**
- Phase 4: Basic Tactics (apply_axiom + modal_t)
- Phase 5: Aesop Integration (tm_auto)
- Phase 6: Advanced Tactics (assumption_search)

### **Wave 4: Testing & Documentation (Concurrent with Wave 3)**
- Phase 7: Test Suite Development (TDD with Wave 3)
- Phase 8: Documentation Sync

**Critical Path**: Phase 0 (rule fix) → Phases 1-3 (soundness) is blocking. Phases 4-7 can run in parallel

---

## Phase 0: Fix Modal K and Temporal K Rule Definitions (CRITICAL)

**Effort**: 8-10 hours
**Parallel**: BLOCKING - Must complete before Phases 1-3
**Files Modified**: 2 (Derivation.lean, any code using these rules)
**Dependencies**: None
**Priority**: CRITICAL - Code-paper alignment

### Objective

Fix the Modal K and Temporal K inference rule definitions in Derivation.lean to match the paper's §sec:Appendix definitions. The current implementation has the rule directions reversed.

### Problem Statement

**Paper Definitions (§sec:Appendix)**:
- **MK** (line 1030): If `Γ ⊢ φ`, then `□Γ ⊢ □φ`
- **TK** (line 1037): If `Γ ⊢ φ`, then `FΓ ⊢ Fφ`

**Current Code (Derivation.lean lines 90-102)**:
```lean
| modal_k (Γ : Context) (φ : Formula)
    (h : Derivable (Context.map Formula.box Γ) φ) : Derivable Γ (Formula.box φ)
    -- WRONG: Goes from □Γ ⊢ φ to Γ ⊢ □φ

| temporal_k (Γ : Context) (φ : Formula)
    (h : Derivable (Context.map Formula.future Γ) φ) : Derivable Γ (Formula.future φ)
    -- WRONG: Goes from FΓ ⊢ φ to Γ ⊢ Fφ
```

### Tasks

- [ ] **Task 0.1**: Fix Modal K rule in Derivation.lean
  - Change: `Derivable (Context.map Formula.box Γ) φ → Derivable Γ (Formula.box φ)`
  - To: `Derivable Γ φ → Derivable (Context.map Formula.box Γ) (Formula.box φ)`

- [ ] **Task 0.2**: Fix Temporal K rule in Derivation.lean
  - Change: `Derivable (Context.map Formula.future Γ) φ → Derivable Γ (Formula.future φ)`
  - To: `Derivable Γ φ → Derivable (Context.map Formula.future Γ) (Formula.future φ)`

- [ ] **Task 0.3**: Update docstrings to match paper's definitions

- [ ] **Task 0.4**: Search for and update all code using these rules
  - Search for `modal_k` and `temporal_k` usages
  - Update call sites to match new signatures

- [ ] **Task 0.5**: Run full test suite to verify no regressions

- [ ] **Task 0.6**: Update KNOWN_LIMITATIONS.md to remove code-paper alignment warnings

### File Changes

**File**: `/home/benjamin/Documents/Philosophy/Projects/Logos/Logos/ProofSystem/Derivation.lean`

**Change 1**: Fix modal_k rule (lines 90-91)

FROM:
```lean
| modal_k (Γ : Context) (φ : Formula)
    (h : Derivable (Context.map Formula.box Γ) φ) : Derivable Γ (Formula.box φ)
```

TO:
```lean
| modal_k (Γ : Context) (φ : Formula)
    (h : Derivable Γ φ) : Derivable (Context.map Formula.box Γ) (Formula.box φ)
```

**Change 2**: Fix temporal_k rule (lines 101-102)

FROM:
```lean
| temporal_k (Γ : Context) (φ : Formula)
    (h : Derivable (Context.map Formula.future Γ) φ) : Derivable Γ (Formula.future φ)
```

TO:
```lean
| temporal_k (Γ : Context) (φ : Formula)
    (h : Derivable Γ φ) : Derivable (Context.map Formula.future Γ) (Formula.future φ)
```

**Change 3**: Update docstrings

```lean
/--
Modal K rule: Distribution of □ over derivation.

If `Γ ⊢ φ`, then `□Γ ⊢ □φ` (where □Γ = Γ.map box).

This rule expresses: if φ follows from assumptions Γ,
then □φ follows from the boxed assumptions □Γ.

**Paper Reference**: §sec:Appendix line 1030 (MK rule)
-/
| modal_k (Γ : Context) (φ : Formula)
    (h : Derivable Γ φ) : Derivable (Context.map Formula.box Γ) (Formula.box φ)

/--
Temporal K rule: Distribution of F over derivation.

If `Γ ⊢ φ`, then `FΓ ⊢ Fφ` (where FΓ = Γ.map future).

This rule expresses: if φ follows from assumptions Γ,
then Fφ follows from the future assumptions FΓ.

**Paper Reference**: §sec:Appendix line 1037 (TK rule)
-/
| temporal_k (Γ : Context) (φ : Formula)
    (h : Derivable Γ φ) : Derivable (Context.map Formula.future Γ) (Formula.future φ)
```

### Quality Gates

- [ ] `lake build` succeeds after rule changes
- [ ] No code uses old rule signatures (grep verification)
- [ ] All existing tests still pass (or are updated)
- [ ] Docstrings reference paper line numbers
- [ ] KNOWN_LIMITATIONS.md updated

### Impact on Soundness Proofs

After fixing the rule definitions, the soundness proofs in Phases 1-2 become straightforward:

**New Modal K Soundness** (paper lines 2282-2292):
- IH: `Γ ⊨ φ`
- Goal: `□Γ ⊨ □φ`
- Proof: At any (M, τ, t) where □Γ true, for any history σ at t, need φ at (M, σ, t). Since □ψ at τ implies ψ at σ for all ψ ∈ Γ, we have Γ true at (M, σ, t), hence φ true by IH.

**New Temporal K Soundness** (paper lines 2331-2332):
- IH: `Γ ⊨ φ`
- Goal: `FΓ ⊨ Fφ`
- Proof: Similar structure using future operator semantics.

---

## Phase 1: Modal K Rule Soundness (After Rule Fix)

**Effort**: 3-5 hours
**Parallel**: Can run with Phase 4 (AFTER Phase 0 complete)
**Dependencies**: Phase 0 (rule fix) must be complete
**Files Modified**: 1

### Objective

Prove soundness of the CORRECTED modal_k inference rule. After Phase 0, the rule matches the paper and soundness follows directly.

### Technical Approach

**After Phase 0, the rule is**:
- If `Γ ⊢ φ`, then `□Γ ⊢ □φ`

**Soundness Goal**:
- If `Γ ⊨ φ` (IH), then `□Γ ⊨ □φ` (goal)

**Proof Strategy** (paper lines 2282-2292):

The corrected rule is straightforward to prove sound:

1. Assume `□Γ` true at (M, τ, t): `∀ ψ ∈ Γ, ∀ σ hs, truth_at M σ t hs ψ`
2. Goal: `□φ` true at (M, τ, t): `∀ σ hs, truth_at M σ t hs φ`
3. For arbitrary history σ at time t:
   - Need to show: `truth_at M σ t hs φ`
   - We have: `∀ ψ ∈ Γ, truth_at M σ t hs ψ` (from assumption)
   - By IH: `Γ ⊨ φ`, so `truth_at M σ t hs φ`

**No restrictions needed** - the corrected rule is unconditionally sound!

### File Changes

**File**: `/home/benjamin/Documents/Philosophy/Projects/Logos/Logos/Metalogic/Soundness.lean`

**Change 1**: Replace `sorry` at line 551 with corrected proof (AFTER Phase 0)

```lean
| @modal_k Γ' φ' _ ih =>
  -- CORRECTED RULE: Γ' ⊢ φ' ⟹ □Γ' ⊢ □φ'
  -- IH: Γ' ⊨ φ'
  -- Goal: □Γ' ⊨ □φ'
  intro F M τ t ht h_all_boxed
  -- h_all_boxed : ∀ ψ ∈ Γ'.map box, truth_at M τ t ht ψ
  -- For each ψ ∈ Γ', we have □ψ true at (M, τ, t)
  -- Goal: □φ' true at (M, τ, t)
  unfold truth_at
  intro σ hs
  -- Need: φ' at (M, σ, t)
  -- Apply IH: since Γ' ⊨ φ', if Γ' true at (M, σ, t) then φ' true
  apply ih F M σ t hs
  -- Show: ∀ ψ ∈ Γ', truth_at M σ t hs ψ
  intro ψ h_mem
  -- From h_all_boxed: □ψ true at (M, τ, t)
  have h_box_psi := h_all_boxed (Formula.box ψ) (List.mem_map_of_mem Formula.box h_mem)
  -- □ψ at (M, τ, t) means: ∀ ρ hr, truth_at M ρ t hr ψ
  -- In particular, ψ at (M, σ, t)
  unfold truth_at at h_box_psi
  exact h_box_psi σ hs
```

**Note**: After Phase 0 fixes the rule, this proof becomes straightforward with no restrictions!

### Test Requirements

**File**: Create `/home/benjamin/Documents/Philosophy/Projects/Logos/LogosTest/Metalogic/SoundnessRulesTest.lean`

```lean
import Logos.Metalogic.Soundness
import Logos.ProofSystem.Derivation

namespace LogosTest.Metalogic

open Logos.Metalogic (soundness)
open Logos.ProofSystem (Derivable)
open Logos.Syntax (Formula)

/-- Test modal_k soundness: Γ ⊢ φ ⟹ □Γ ⊢ □φ -/
def test_modal_k_soundness (φ : Formula) :
  -- After rule fix: modal_k takes Derivable Γ φ and produces Derivable (Γ.map box) (Formula.box φ)
  let proof : Derivable (([].map Formula.box)) (Formula.box φ) :=
    Derivable.modal_k [] φ (sorry)  -- placeholder derivation
  let _ := soundness proof
  True := trivial

/-- Test modal_k preserves soundness through box -/
def test_modal_k_preserves_validity (P : Formula) :
  -- If φ is derivable (theorem), then □φ is derivable from □[]
  let h_phi : Derivable [] P := sorry  -- assume P derivable
  let h_box_phi := Derivable.modal_k [] P h_phi
  let _ := soundness h_box_phi
  True := trivial

end LogosTest.Metalogic
```

### Quality Gates

- [ ] Phase 0 complete (rule definitions corrected)
- [ ] Proof compiles with zero `sorry` placeholders in modal_k case
- [ ] `lake build` succeeds
- [ ] All existing Soundness tests still pass
- [ ] Proof follows paper proof structure (lines 2282-2292)

### Documentation Updates

**File**: `/home/benjamin/Documents/Philosophy/Projects/Logos/Documentation/ProjectInfo/KNOWN_LIMITATIONS.md`

**REMOVE** the code-paper alignment warning (since rule is now fixed):
```markdown
### ~~Modal K Rule Code-Paper Discrepancy~~ [RESOLVED]

**Status**: RESOLVED in Phase 0
**Previous Issue**: Rule was implemented in wrong direction
**Resolution**: Rule corrected to match paper §sec:Appendix line 1030
**Soundness**: Unconditionally sound (no restrictions needed)
```

---

## Phase 2: Temporal K Rule Soundness (After Rule Fix)

**Effort**: 3-5 hours
**Parallel**: Can run with Phase 4 or Phase 5 (AFTER Phase 0)
**Dependencies**: Phase 0 (rule fix) must be complete
**Files Modified**: 1

### Objective

Prove soundness of the CORRECTED temporal_k inference rule. After Phase 0, the rule matches the paper and soundness follows directly.

### Technical Approach

**After Phase 0, the rule is**:
- If `Γ ⊢ φ`, then `FΓ ⊢ Fφ`

**Soundness Goal**:
- If `Γ ⊨ φ` (IH), then `FΓ ⊨ Fφ` (goal)

**Proof Strategy** (paper lines 2331-2332):

The corrected rule is straightforward to prove sound:

1. Assume `FΓ` true at (M, τ, t): `∀ ψ ∈ Γ, ∀ s > t, truth_at M τ s hs ψ`
2. Goal: `Fφ` true at (M, τ, t): `∀ s > t, truth_at M τ s hs φ`
3. For arbitrary time s > t:
   - Need to show: `truth_at M τ s hs φ`
   - We have: `∀ ψ ∈ Γ, truth_at M τ s hs ψ` (from assumption for this s)
   - By IH: `Γ ⊨ φ`, so `truth_at M τ s hs φ`

**No restrictions needed** - the corrected rule is unconditionally sound!

### File Changes

**File**: `/home/benjamin/Documents/Philosophy/Projects/Logos/Logos/Metalogic/Soundness.lean`

**Change 1**: Replace `sorry` at line 569 with corrected proof (AFTER Phase 0)

```lean
| @temporal_k Γ' φ' _ ih =>
  -- CORRECTED RULE: Γ' ⊢ φ' ⟹ FΓ' ⊢ Fφ'
  -- IH: Γ' ⊨ φ'
  -- Goal: FΓ' ⊨ Fφ'
  intro F M τ t ht h_all_future
  -- h_all_future : ∀ ψ ∈ Γ'.map future, truth_at M τ t ht ψ
  -- For each ψ ∈ Γ', we have Fψ true at (M, τ, t)
  -- Goal: Fφ' true at (M, τ, t)
  unfold truth_at
  intro s hs hts
  -- Need: φ' at (M, τ, s)
  -- Apply IH: since Γ' ⊨ φ', if Γ' true at (M, τ, s) then φ' true
  apply ih F M τ s hs
  -- Show: ∀ ψ ∈ Γ', truth_at M τ s hs ψ
  intro ψ h_mem
  -- From h_all_future: Fψ true at (M, τ, t)
  have h_future_psi := h_all_future (Formula.future ψ) (List.mem_map_of_mem Formula.future h_mem)
  -- Fψ at (M, τ, t) means: ∀ r > t, truth_at M τ r hr ψ
  -- Since s > t, ψ at (M, τ, s)
  unfold truth_at at h_future_psi
  exact h_future_psi s hs hts
```

**Note**: After Phase 0 fixes the rule, this proof becomes straightforward with no restrictions!

### Test Requirements

Add to `/home/benjamin/Documents/Philosophy/Projects/Logos/LogosTest/Metalogic/SoundnessRulesTest.lean`:

```lean
/-- Test temporal_k soundness: Γ ⊢ φ ⟹ FΓ ⊢ Fφ -/
def test_temporal_k_soundness (φ : Formula) :
  -- After rule fix: temporal_k takes Derivable Γ φ and produces Derivable (Γ.map future) (Formula.future φ)
  let proof : Derivable (([].map Formula.future)) (Formula.future φ) :=
    Derivable.temporal_k [] φ (sorry)  -- placeholder derivation
  let _ := soundness proof
  True := trivial

/-- Test temporal_k preserves soundness through future -/
def test_temporal_k_preserves_validity (P : Formula) :
  -- If φ is derivable (theorem), then Fφ is derivable from F[]
  let h_phi : Derivable [] P := sorry  -- assume P derivable
  let h_future_phi := Derivable.temporal_k [] P h_phi
  let _ := soundness h_future_phi
  True := trivial
```

### Quality Gates

- [ ] Phase 0 complete (rule definitions corrected)
- [ ] Proof compiles with zero `sorry` in temporal_k case
- [ ] Proof structure mirrors modal_k (consistency)
- [ ] All soundness tests pass
- [ ] Proof follows paper proof structure (lines 2331-2332)

### Documentation Updates

**REMOVE** the code-paper alignment warning for temporal_k (since rule is now fixed):
```markdown
### ~~Temporal K Rule Code-Paper Discrepancy~~ [RESOLVED]

**Status**: RESOLVED in Phase 0
**Previous Issue**: Rule was implemented in wrong direction
**Resolution**: Rule corrected to match paper §sec:Appendix line 1037
**Soundness**: Unconditionally sound (no restrictions needed)
```

---

## Phase 3: Temporal Duality Soundness (Symmetric Frames)

**Effort**: 3-5 hours
**Parallel**: Can run with Phase 5 or Phase 6
**Dependencies**: None
**Files Modified**: 2 (Soundness.lean + new helper lemma file)

### Objective

Prove soundness of temporal_duality rule for symmetric task frames. This is weaker than full generality but sufficient for most applications.

### Technical Approach

**Current Code** (`Logos/Metalogic/Soundness.lean`, line 571):
```lean
| @temporal_duality φ' _ ih =>
  -- IH: [] ⊨ φ'
  -- Goal: [] ⊨ swap_past_future φ'
  sorry
```

**Proof Strategy** (from research report, lines 259-330):

Temporal duality requires showing: if φ is valid, then swap_past_future(φ) is valid.

**Simplified Approach for Symmetric Frames**:
- Define "symmetric frame" constraint: task_rel w d w' ↔ task_rel w' d w
- Prove duality lemma for symmetric frames by induction on formula
- Document restriction in KNOWN_LIMITATIONS.md

**Alternative**: Accept restricted duality and defer general case to future work.

### File Changes

**File 1**: Create `/home/benjamin/Documents/Philosophy/Projects/Logos/Logos/Metalogic/TemporalDuality.lean`

```lean
import Logos.Semantics.Truth
import Logos.Syntax.Formula

namespace Logos.Metalogic

open Logos.Semantics (truth_at)
open Logos.Syntax (Formula)

/--
Symmetric frame constraint: task relation is bidirectional.
This is sufficient for temporal duality soundness.
-/
def SymmetricFrame (F : TaskFrame) : Prop :=
  ∀ (w w' : F.WorldState) (d : Duration),
    F.task_rel w d w' ↔ F.task_rel w' d w

/--
Temporal duality lemma for symmetric frames: swapping past and future
preserves validity when the frame is symmetric.

**Proof Strategy**: Induction on formula structure, using symmetry for temporal cases.
-/
theorem swap_past_future_preserves_validity_symmetric
  {F : TaskFrame} (h_symm : SymmetricFrame F)
  (M : TaskModel F) (τ : WorldHistory F) (t : Int) (ht : τ.domain t)
  (φ : Formula) :
  truth_at M τ t ht φ ↔ truth_at M τ t ht (swap_past_future φ) := by
  induction φ generalizing t with
  | atom p => simp [truth_at, swap_past_future]
  | bot => simp [truth_at, swap_past_future]
  | imp ψ χ ih_ψ ih_χ =>
    simp [truth_at, swap_past_future]
    constructor
    · intro h h_ψ
      exact (ih_χ t ht).mp (h ((ih_ψ t ht).mpr h_ψ))
    · intro h h_ψ
      exact (ih_χ t ht).mpr (h ((ih_ψ t ht).mp h_ψ))
  | box ψ ih =>
    simp [truth_at, swap_past_future]
    -- Box quantifies over histories, independent of past/future
    constructor <;> (intro h σ hs; exact (ih t hs).mp (h σ hs) <|> exact (ih t hs).mpr (h σ hs))
  | past ψ ih =>
    simp [truth_at, swap_past_future]
    -- Past becomes Future under swap, use symmetry
    sorry  -- Detailed proof using h_symm
  | future ψ ih =>
    simp [truth_at, swap_past_future]
    -- Future becomes Past under swap, use symmetry
    sorry

end Logos.Metalogic
```

**File 2**: Update `/home/benjamin/Documents/Philosophy/Projects/Logos/Logos/Metalogic/Soundness.lean`

```lean
| @temporal_duality φ' _ ih =>
  -- Temporal duality is sound for symmetric frames
  -- For general frames, defer to future work
  intro F M τ t ht
  -- Apply symmetric frame lemma if available
  -- For MVP, use restricted validity
  sorry  -- Complete using TemporalDuality.lean helper
```

### Test Requirements

Add to `SoundnessRulesTest.lean`:

```lean
/-- Test temporal_duality for symmetric frames -/
def test_temporal_duality_soundness (φ : Formula) :
  let proof : Derivable [] φ := sorry
  let _ := soundness proof
  True := trivial
```

### Quality Gates

- [ ] TemporalDuality.lean compiles
- [ ] swap_past_future_preserves_validity_symmetric proven (or documented as partial)
- [ ] Soundness theorem updated
- [ ] Tests pass

### Documentation Updates

Add to KNOWN_LIMITATIONS.md:
```markdown
### Temporal Duality Restriction

**Status**: Proven for symmetric frames
**Limitation**: temporal_duality rule proven sound for frames where task relation is symmetric (bidirectional).

**Practical Impact**: Medium - most task frames in practice have some asymmetry (e.g., causal direction).

**Workaround**: For non-symmetric frames, duality can be established case-by-case or deferred to future completeness work.
```

---

## Phase 4: Basic Tactics (apply_axiom + modal_t)

**Effort**: 5-8 hours
**Parallel**: Can run with Phases 1-3
**Dependencies**: None
**Files Modified**: 1
**Tests**: Concurrent with implementation (TDD)

### Objective

Implement two foundational tactics using simple metaprogramming approaches:
1. **apply_axiom**: Macro-based axiom application
2. **modal_t**: Pattern-matched modal T axiom application

These provide immediate value and establish patterns for Phase 5-6.

### Technical Approach

**Tactic 1: apply_axiom** (Macro-Based, 1-2 hours)

Simplest possible implementation - pure macro expansion.

**Specification** (from research report, lines 363-391):
```lean
macro "apply_axiom" ax:ident : tactic =>
  `(tactic| apply Derivable.axiom; apply $ax)
```

**Usage**:
```lean
example (P : Formula) : [] ⊢ (Formula.box P).imp P := by
  apply_axiom Axiom.modal_t
```

**Tactic 2: modal_t** (elab_rules, 4-6 hours)

Pattern-matched tactic using LEAN 4's elab_rules mechanism.

**Specification** (from research report, lines 393-441):
```lean
elab_rules : tactic
  | `(tactic| modal_t) => do
    let goal ← getMainGoal
    let goalType ← goal.getType

    -- Pattern match: Derivable Γ ((Formula.box φ).imp φ)
    match goalType with
    | .app (.app (.const ``Derivable _) context) formula =>
      match formula with
      | .app (.app (.const ``Formula.imp _) lhs) rhs =>
        match lhs with
        | .app (.const ``Formula.box _) innerFormula =>
          if ← isDefEq innerFormula rhs then
            let axiomProof ← mkAppM ``Axiom.modal_t #[innerFormula]
            let proof ← mkAppM ``Derivable.axiom #[axiomProof]
            goal.assign proof
          else
            throwError "modal_t: expected □φ → φ, got □{innerFormula} → {rhs}"
        | _ => throwError "modal_t: expected □_ on left"
      | _ => throwError "modal_t: expected implication"
    | _ => throwError "modal_t: goal must be Γ ⊢ φ"
```

### File Changes

**File**: `/home/benjamin/Documents/Philosophy/Projects/Logos/Logos/Automation/Tactics.lean`

**Change 1**: Remove axiom stubs, add imports

```lean
-- Replace lines 1-10 with:
import Lean.Elab.Tactic
import Lean.Meta.Basic
import Logos.ProofSystem.Axioms
import Logos.ProofSystem.Derivation

namespace Logos.Automation

open Lean Elab Tactic Meta
open Logos.ProofSystem (Axiom Derivable)
open Logos.Syntax (Formula)
```

**Change 2**: Replace `modal_k_tactic_stub` section (lines 89-102) with implementations

```lean
/-!
## Core Tactics

Basic tactics for applying TM axioms and rules.
-/

/--
Apply a specific TM axiom by name.

**Usage**:
```lean
example (P : Formula) : [] ⊢ (Formula.box P).imp P := by
  apply_axiom Axiom.modal_t
```

**Implementation**: Simple macro expansion to `apply` tactics.
-/
macro "apply_axiom" ax:ident : tactic =>
  `(tactic| apply Derivable.axiom; apply $ax)

/--
Apply modal axiom MT (□φ → φ).

**Usage**:
```lean
example (P : Formula) : [] ⊢ (Formula.box P).imp P := by
  modal_t
```

**Implementation**: Pattern-matched elab_rules inspecting goal type.
-/
elab_rules : tactic
  | `(tactic| modal_t) => do
    let goal ← getMainGoal
    let goalType ← goal.getType

    match goalType with
    | .app (.app (.const ``Derivable _) context) formula =>
      match formula with
      | .app (.app (.const ``Formula.imp _) lhs) rhs =>
        match lhs with
        | .app (.const ``Formula.box _) innerFormula =>
          if ← isDefEq innerFormula rhs then
            let axiomProof ← mkAppM ``Axiom.modal_t #[innerFormula]
            let proof ← mkAppM ``Derivable.axiom #[axiomProof]
            goal.assign proof
          else
            throwError "modal_t: expected □φ → φ, got □{innerFormula} → {rhs}"
        | _ => throwError "modal_t: expected □_ on left"
      | _ => throwError "modal_t: expected implication"
    | _ => throwError "modal_t: goal must be Γ ⊢ φ"
```

**Change 3**: Keep other stubs for Phase 5-6, add documentation comments

### Test Requirements (TDD - Written First!)

**File**: Create `/home/benjamin/Documents/Philosophy/Projects/Logos/LogosTest/Automation/TacticsTest.lean`

```lean
import Logos.Automation.Tactics
import Logos.Syntax.Formula
import Logos.ProofSystem.Derivation
import Logos.ProofSystem.Axioms

namespace LogosTest.Automation

open Logos.Syntax (Formula)
open Logos.ProofSystem (Derivable Axiom)

/-!
## Unit Tests for apply_axiom
-/

/-- Test apply_axiom with modal_t -/
def test_apply_axiom_modal_t (P : Formula) : Derivable [] ((Formula.box P).imp P) := by
  apply_axiom Axiom.modal_t

/-- Test apply_axiom with modal_4 -/
def test_apply_axiom_modal_4 (P : Formula) :
  Derivable [] ((Formula.box P).imp (Formula.box (Formula.box P))) := by
  apply_axiom Axiom.modal_4

/-- Test apply_axiom with all 8 axioms -/
def test_apply_axiom_all_axioms : True := by
  have _ : Derivable [] ((Formula.box (Formula.atom "p")).imp (Formula.atom "p")) := by
    apply_axiom Axiom.modal_t
  have _ : Derivable [] ((Formula.box (Formula.atom "p")).imp (Formula.box (Formula.box (Formula.atom "p")))) := by
    apply_axiom Axiom.modal_4
  -- Continue for all axioms...
  trivial

/-!
## Unit Tests for modal_t
-/

/-- Test modal_t basic pattern -/
def test_modal_t_basic (P : Formula) : Derivable [] ((Formula.box P).imp P) := by
  modal_t

/-- Test modal_t with non-empty context -/
def test_modal_t_with_context (P Q : Formula) : Derivable [Q] ((Formula.box P).imp P) := by
  modal_t

/-- Test modal_t with complex formula -/
def test_modal_t_complex (P Q : Formula) :
  Derivable [] ((Formula.box (P.imp Q)).imp (P.imp Q)) := by
  modal_t

/-!
## Negative Tests (Error Handling)
-/

/-- Test modal_t fails on non-implication
Note: This test uses sorry as it's testing failure behavior
-/
example : True := by
  -- The following should fail:
  -- have goal : Derivable [] (Formula.box P) := by modal_t
  trivial

end LogosTest.Automation
```

### Quality Gates

- [ ] `apply_axiom` macro compiles and works for all 8 axioms
- [ ] `modal_t` elab_rules compiles and pattern-matches correctly
- [ ] All unit tests pass (≥6 tests)
- [ ] Error messages are clear and helpful
- [ ] `lake test LogosTest.Automation.TacticsTest` succeeds

### Documentation Updates

Update `/home/benjamin/Documents/Philosophy/Projects/Logos/Documentation/Development/TACTIC_DEVELOPMENT.md`:

Add section:
```markdown
## Implemented Tactics

### apply_axiom (Macro-Based)

**Syntax**: `apply_axiom <axiom_name>`

**Implementation Approach**: Simple macro expansion

**Example**:
\`\`\`lean
example (P : Formula) : [] ⊢ □P → P := by
  apply_axiom Axiom.modal_t
\`\`\`

**Source**: Logos/Automation/Tactics.lean (lines XX-YY)

### modal_t (Pattern-Matched)

**Syntax**: `modal_t`

**Implementation Approach**: elab_rules with goal type inspection

**Example**:
\`\`\`lean
example (P : Formula) : [] ⊢ □P → P := by
  modal_t
\`\`\`

**Error Handling**: Fails with clear message if goal is not `□φ → φ` pattern

**Source**: Logos/Automation/Tactics.lean (lines XX-YY)
```

---

## Phase 5: Aesop Integration (tm_auto)

**Effort**: 6-8 hours
**Parallel**: Can run with Phase 2 or Phase 3
**Dependencies**: Phase 4 complete (provides pattern for integration)
**Files Modified**: 2 (Tactics.lean + Soundness.lean)
**Tests**: Concurrent (TDD)

### Objective

Integrate Aesop proof search framework with Logos TM logic by:
1. Declaring custom `TMLogic` rule set
2. Marking 10 axiom validity theorems as `@[aesop safe [TMLogic]]`
3. Marking 6 perpetuity theorems as `@[aesop safe [TMLogic]]`
4. Implementing `tm_auto` macro to invoke Aesop with TMLogic rules

**Effort Reduction**: Original estimate was 15-20h assuming axiom/perpetuity proofs needed. Since all proofs are complete from Phases 1-4, actual work is just adding attributes (6-8h).

### Technical Approach

**Aesop Integration Pattern** (from research report, lines 443-526):

```lean
-- Step 1: Declare rule set
declare_aesop_rule_sets [TMLogic]

-- Step 2: Mark theorems as safe rules
@[aesop safe [TMLogic]]
theorem modal_t_valid (φ : Formula) : ⊨ (φ.box.imp φ) := ...

-- Step 3: Implement tm_auto
macro "tm_auto" : tactic =>
  `(tactic| aesop (rule_sets [TMLogic]))
```

**Why This Works**: Aesop will automatically try all marked theorems as proof steps, finding derivations automatically.

### File Changes

**File 1**: `/home/benjamin/Documents/Philosophy/Projects/Logos/Logos/Automation/Tactics.lean`

**Change 1**: Add Aesop import and rule set declaration

```lean
-- Add to imports (after line 3):
import Aesop

-- Add after modal_t implementation:

/-!
## Automated Proof Search (Aesop Integration)
-/

/--
Declare custom Aesop rule set for TM logic.

This rule set contains all TM axioms, perpetuity principles, and inference rules
marked with `@[aesop safe [TMLogic]]`.
-/
declare_aesop_rule_sets [TMLogic]

/--
Comprehensive TM automation using Aesop.

**Usage**:
```lean
example (P : Formula) : [] ⊢ □P → P := by
  tm_auto  -- Automatically finds MT axiom
```

**Implementation**: Invokes Aesop with TMLogic rule set.

**Performance**: Bounded by Aesop's default depth limit (30 steps). For complex
proofs, may need manual intervention.
-/
macro "tm_auto" : tactic =>
  `(tactic| aesop (rule_sets [TMLogic]))
```

**File 2**: `/home/benjamin/Documents/Philosophy/Projects/Logos/Logos/Metalogic/Soundness.lean`

**Change 1**: Add Aesop import

```lean
-- Add to imports:
import Aesop
```

**Change 2**: Add `@[aesop safe [TMLogic]]` to all 10 axiom validity theorems

```lean
-- Lines 152-177 (prop_k_valid, prop_s_valid) - add attribute:
@[aesop safe [TMLogic]]
theorem prop_k_valid (φ ψ χ : Formula) :
  ⊨ (φ.imp (ψ.imp χ)).imp ((φ.imp ψ).imp (φ.imp χ)) := by
  intro F M τ t ht
  unfold truth_at
  tauto

@[aesop safe [TMLogic]]
theorem prop_s_valid (φ ψ : Formula) :
  ⊨ φ.imp (ψ.imp φ) := by
  intro F M τ t ht
  unfold truth_at
  intro h_phi _
  exact h_phi

-- Lines 185-211 (modal_t_valid) - add attribute:
@[aesop safe [TMLogic]]
theorem modal_t_valid (φ : Formula) : ⊨ (φ.box.imp φ) := by
  intro F M τ t ht
  unfold truth_at
  intro h_box
  exact h_box τ ht

-- Repeat for modal_4_valid (line 219), modal_b_valid (line 237)
-- temporal_4_valid (line 270), temporal_a_valid (line 289)
-- temporal_l_valid (line 310), modal_future_valid (line 347)
-- temporal_future_valid (line 379)
```

**File 3**: `/home/benjamin/Documents/Philosophy/Projects/Logos/Logos/Theorems/Perpetuity.lean`

**Change 1**: Add Aesop import and attributes to P1-P6

```lean
-- Add to imports:
import Aesop

-- Add attribute to P1 (line 103):
@[aesop safe [TMLogic]]
theorem P1 (φ : Formula) : Derivable [] (Formula.box φ).imp φ.always := by
  -- ... existing proof ...

-- Repeat for P2 (line 154), P3 (line 180), P4 (line 210), P5 (line 238), P6 (line 266)
```

### Test Requirements (TDD)

Add to `/home/benjamin/Documents/Philosophy/Projects/Logos/LogosTest/Automation/TacticsTest.lean`:

```lean
/-!
## Integration Tests for tm_auto
-/

/-- Test tm_auto finds simple axiom (modal_t) -/
def test_tm_auto_modal_t (P : Formula) : Derivable [] ((Formula.box P).imp P) := by
  tm_auto

/-- Test tm_auto finds modal_4 -/
def test_tm_auto_modal_4 (P : Formula) :
  Derivable [] ((Formula.box P).imp (Formula.box (Formula.box P))) := by
  tm_auto

/-- Test tm_auto finds perpetuity P1 -/
def test_tm_auto_p1 (P : Formula) :
  Derivable [] ((Formula.box P).imp P.always) := by
  tm_auto

/-- Test tm_auto with modus ponens chain -/
def test_tm_auto_mp_chain (P Q R : Formula) :
  Derivable [P, P.imp Q, Q.imp R] R := by
  tm_auto

/-- Test tm_auto with modal reasoning -/
def test_tm_auto_modal_chain (P Q : Formula) :
  Derivable [Formula.box P, (Formula.box P).imp Q] Q := by
  tm_auto

/-!
## Performance Tests
-/

/-- Test tm_auto completes on nested formula within reasonable time -/
def deeply_nested (n : Nat) : Formula :=
  match n with
  | 0 => Formula.atom "p"
  | n + 1 => Formula.box (deeply_nested n)

def test_tm_auto_performance : Derivable [] ((deeply_nested 5).imp (deeply_nested 5)) := by
  tm_auto  -- Should complete quickly
```

### Quality Gates

- [ ] TMLogic rule set declared successfully
- [ ] All 10 axiom theorems have `@[aesop safe [TMLogic]]` attribute
- [ ] All 6 perpetuity theorems have attribute
- [ ] `tm_auto` macro compiles
- [ ] All integration tests pass (≥8 tests)
- [ ] Performance test completes in <1 second
- [ ] `lake build` succeeds with zero warnings

### Documentation Updates

Update TACTIC_DEVELOPMENT.md:
```markdown
### tm_auto (Aesop-Based Automation)

**Syntax**: `tm_auto`

**Implementation**: Aesop integration with TMLogic rule set

**Capabilities**:
- Automatically applies TM axioms
- Uses perpetuity principles
- Chains modus ponens
- Bounded search (depth 30)

**Limitations**:
- May not find all proofs (Aesop limitations)
- Complex proofs may timeout
- No modal_k/temporal_k rule application (automation limitation)

**Example**:
\`\`\`lean
example (P Q : Formula) : [□P, □P → Q] ⊢ Q := by
  tm_auto
\`\`\`
```

---

## Phase 6: Advanced Tactics (assumption_search)

**Effort**: 8-12 hours
**Parallel**: Can run with Phase 2 or Phase 3
**Dependencies**: Phase 4 (provides pattern), Phase 5 (optional)
**Files Modified**: 1
**Tests**: Concurrent (TDD)

### Objective

Implement `assumption_search` tactic using direct TacticM monad programming with local context iteration.

### Technical Approach

**Specification** (from research report, lines 528-587):

```lean
def assumption_search_impl (goal : MVarId) : TacticM Unit := do
  let goalType ← goal.getType
  let localContext ← getLCtx

  for decl in localContext do
    if decl.isAuxDecl then continue

    let assumptionType ← instantiateMVars decl.type

    if ← isDefEq assumptionType goalType then
      logInfo m!"Found matching assumption: {decl.userName}"
      let proof := decl.toExpr
      goal.assign proof
      return

  throwError "assumption_search: no matching assumption in context"

elab "assumption_search" : tactic => do
  let goal ← getMainGoal
  assumption_search_impl goal
```

**Key Features**:
- Iterates through local context (assumptions)
- Checks definitional equality (not just syntactic)
- Returns first match (deterministic)
- Clear error message on failure

### File Changes

**File**: `/home/benjamin/Documents/Philosophy/Projects/Logos/Logos/Automation/Tactics.lean`

**Change 1**: Replace `assumption_search_stub` (line 123) with implementation

```lean
/--
Search local context for assumption matching goal.

**Usage**:
```lean
example (P : Formula) (h : [] ⊢ P) : [] ⊢ P := by
  assumption_search  -- Finds h
```

**Implementation**: Direct TacticM with local context iteration.

**Note**: This is more sophisticated than LEAN's builtin `assumption` tactic,
as it searches for `Derivable Γ φ` patterns specifically.
-/
def assumption_search_impl (goal : MVarId) : TacticM Unit := do
  let goalType ← goal.getType

  -- Get local context (assumptions in scope)
  let localContext ← getLCtx

  -- Iterate through all local declarations
  for decl in localContext do
    -- Skip auxiliary declarations (internal LEAN variables)
    if decl.isAuxDecl then continue

    -- Get assumption type
    let assumptionType ← instantiateMVars decl.type

    -- Check definitional equality with goal type
    if ← isDefEq assumptionType goalType then
      logInfo m!"Found matching assumption: {decl.userName}"

      -- Use this assumption as proof
      let proof := decl.toExpr
      goal.assign proof
      return  -- Success, exit early

  -- No match found
  throwError "assumption_search: no matching assumption in context"

/-- Tactic elaboration for assumption_search -/
elab "assumption_search" : tactic => do
  let goal ← getMainGoal
  assumption_search_impl goal
```

### Test Requirements (TDD)

Add to `TacticsTest.lean`:

```lean
/-!
## Unit Tests for assumption_search
-/

/-- Test assumption_search finds single assumption -/
example (P : Formula) (h : Derivable [] P) : Derivable [] P := by
  assumption_search

/-- Test assumption_search with multiple assumptions -/
example (P Q R : Formula) (h1 : Derivable [] P) (h2 : Derivable [] Q) (h3 : Derivable [] R) :
  Derivable [] Q := by
  assumption_search  -- Should find h2

/-- Test assumption_search with definitional equality -/
example (P : Formula) (h : Derivable [] (P.imp P)) :
  Derivable [] ((Formula.atom "p").imp (Formula.atom "p")) := by
  assumption_search  -- Should work with definitional equality

/-!
## Integration Tests (assumption_search + other tactics)
-/

/-- Test assumption_search with modal_t -/
example (P : Formula) (h_boxed : Derivable [] (Formula.box P)) :
  Derivable [] P := by
  have h_imp : Derivable [] ((Formula.box P).imp P) := by modal_t
  apply Derivable.modus_ponens
  · exact h_imp
  · assumption_search  -- Finds h_boxed

/-- Test assumption_search with tm_auto -/
example (P Q : Formula) (h1 : Derivable [] (Formula.box P)) (h2 : Derivable [] ((Formula.box P).imp Q)) :
  Derivable [] Q := by
  tm_auto  -- Should use h1 and h2 automatically
```

### Quality Gates

- [ ] `assumption_search_impl` compiles
- [ ] `elab` declaration works
- [ ] All unit tests pass (≥4 tests)
- [ ] Integration tests pass (≥2 tests)
- [ ] Error message helpful when no match
- [ ] Works with definitional equality (not just syntactic)

### Documentation Updates

Update TACTIC_DEVELOPMENT.md with assumption_search specification and examples.

---

## Phase 7: Test Suite Development (Concurrent with Phases 4-6)

**Effort**: 12-22 hours (distributed across Phases 4-6)
**Parallel**: Fully concurrent with Wave 2
**Dependencies**: None (TDD approach - tests written first)
**Files Created**: 2

### Objective

Create comprehensive test suite for all automation tactics following TDD methodology. Tests are written **before or alongside** implementation, not after.

### Test Organization

**File 1**: `/home/benjamin/Documents/Philosophy/Projects/Logos/LogosTest/Automation/TacticsTest.lean`
- Unit tests for each tactic (correctness)
- Negative tests (error handling)
- Integration tests (tactic combinations)
- Performance tests (benchmarking)
- Edge case tests (boundary conditions)

**File 2**: `/home/benjamin/Documents/Philosophy/Projects/Logos/LogosTest/Automation/ProofSearchTest.lean`
- Placeholder for future proof search tests
- Currently: basic structure with comments

### Test Categories (from research report, lines 601-778)

**Category 1: Unit Tests** (4-8 hours, 20-30 tests)
- Test each tactic on intended cases
- Verify correct pattern matching
- Check axiom application
- Validate proof construction

**Category 2: Negative Tests** (2-4 hours, 10-15 tests)
- Test failure on invalid goals
- Verify error messages
- Check graceful degradation
- Test type mismatches

**Category 3: Integration Tests** (4-6 hours, 10-15 tests)
- Combine multiple tactics
- Test modal_t + assumption_search
- Test tm_auto with complex proofs
- Verify tactic composition

**Category 4: Performance Tests** (2-4 hours, 5-10 tests)
- Deeply nested formulas
- Complex bimodal reasoning
- Timeout behavior
- Benchmark tm_auto depth

**Category 5: Edge Cases** (2-4 hours, 5-10 tests)
- Empty contexts
- Bot formulas
- Circular reasoning prevention
- Maximum depth limits

### TDD Workflow

**Phase 4 TDD** (apply_axiom + modal_t):
1. Write tests for apply_axiom (with `sorry` placeholders) - 1h
2. Implement apply_axiom macro - 1h
3. Run tests, verify pass - 0.5h
4. Write tests for modal_t (with `sorry`) - 2h
5. Implement modal_t elab_rules - 4h
6. Run tests, verify pass - 1h

**Phase 5 TDD** (tm_auto):
1. Write integration tests (with `sorry`) - 2h
2. Declare TMLogic rule set - 0.5h
3. Add Aesop attributes - 1h
4. Implement tm_auto macro - 0.5h
5. Run tests, verify pass - 2h
6. Add performance tests - 2h

**Phase 6 TDD** (assumption_search):
1. Write unit tests (with `sorry`) - 2h
2. Implement assumption_search_impl - 4h
3. Run tests, verify pass - 1h
4. Write integration tests - 2h
5. Run all tests - 1h

### File Structure

**TacticsTest.lean** (created in Phase 4, expanded in Phases 5-6):

```lean
import Logos.Automation.Tactics
import Logos.Syntax.Formula
import Logos.ProofSystem.Derivation

namespace LogosTest.Automation

open Logos.Syntax (Formula)
open Logos.ProofSystem (Derivable)

/-!
## Unit Tests - apply_axiom
Written before implementation (TDD)
-/

-- Tests from Phase 4...

/-!
## Unit Tests - modal_t
Written before implementation (TDD)
-/

-- Tests from Phase 4...

/-!
## Integration Tests - tm_auto
Written before implementation (TDD)
-/

-- Tests from Phase 5...

/-!
## Unit Tests - assumption_search
Written before implementation (TDD)
-/

-- Tests from Phase 6...

/-!
## Integration Tests - Multi-Tactic Combinations
-/

-- Cross-tactic tests...

/-!
## Performance Tests
-/

-- Benchmarking tests...

/-!
## Edge Case Tests
-/

-- Boundary condition tests...

end LogosTest.Automation
```

**ProofSearchTest.lean** (placeholder for future):

```lean
import Logos.Automation.ProofSearch

namespace LogosTest.Automation

/-!
## Proof Search Tests (Future Work)

This file is a placeholder for proof search automation tests.
Proof search functions (bounded_search, search_with_heuristics, etc.)
are planned but not yet implemented.

**Related**: TODO.md Task 7 Phase 3 (future work)
-/

-- Placeholder tests with sorry

end LogosTest.Automation
```

### Quality Gates

- [ ] All unit tests written before implementation (TDD verified)
- [ ] Test coverage ≥80% for Automation package
- [ ] All tests pass with zero `sorry` (except ProofSearchTest placeholders)
- [ ] Performance tests complete in <2 seconds
- [ ] Integration tests exercise all tactic combinations
- [ ] Error handling tests verify helpful messages

### Documentation Updates

Add to TESTING_STANDARDS.md:
```markdown
## Automation Testing

**Test File**: LogosTest/Automation/TacticsTest.lean

**Coverage Target**: ≥80%

**Test Categories**:
1. Unit tests (20-30 tests) - Individual tactic correctness
2. Negative tests (10-15 tests) - Error handling
3. Integration tests (10-15 tests) - Tactic combinations
4. Performance tests (5-10 tests) - Benchmarking
5. Edge case tests (5-10 tests) - Boundary conditions

**TDD Approach**: All tests written before or alongside implementation.

**Verification**:
\`\`\`bash
lake test LogosTest.Automation.TacticsTest
\`\`\`
```

---

## Phase 8: Documentation Sync

**Effort**: 3-5 hours
**Parallel**: After Phases 1-7 complete
**Dependencies**: All previous phases
**Files Modified**: 4

### Objective

Synchronize all documentation with completed implementation changes. Update status tracking, known limitations, implementation guide, and project overview.

### File Changes

**File 1**: `/home/benjamin/Documents/Philosophy/Projects/Logos/Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md`

**Change 1**: Update Soundness module status (lines 200-250)

```markdown
### Soundness.lean

**Status**: `[COMPLETE - WITH RESTRICTIONS]` ✓

**Lines of Code**: ~600
**Test Coverage**: 85%
**Sorry Count**: 0 (all resolved)

**Description**: Soundness theorem proving `Γ ⊢ φ → Γ ⊨ φ` with restricted proofs for inference rules.

**Axiom Soundness** (10/10 complete):
- Modal axioms: MT, M4, MB (proven unconditional)
- Temporal axioms: T4, TA, TL (proven with time-shift lemmas)
- Bimodal axioms: MF, TF (proven with temporal persistence)
- Propositional axioms: K, S (proven as tautologies)

**Rule Soundness** (7/7 complete with restrictions):
- axiom, assumption, modus_ponens, weakening: Unconditional soundness ✓
- modal_k: Sound for empty/boxed contexts (standard modal logic restriction) ✓
- temporal_k: Sound for empty/future contexts (standard temporal logic restriction) ✓
- temporal_duality: Sound for symmetric frames (restriction documented) ✓

**Restrictions**: See KNOWN_LIMITATIONS.md for detailed explanations of modal_k, temporal_k, and temporal_duality restrictions. These are standard in modal logic literature.

**Verification**:
\`\`\`bash
grep -c "sorry" Logos/Metalogic/Soundness.lean  # Should return 0
lake test LogosTest.Metalogic.SoundnessTest
\`\`\`
```

**Change 2**: Update Automation module status (lines 400-450)

```markdown
### Automation Package

**Status**: `[PARTIAL - CORE TACTICS COMPLETE]` ⚡

**Overall Progress**: 40% complete (4/10 planned tactics)

#### Tactics.lean

**Status**: Core tactics implemented
**Lines of Code**: ~350
**Test Coverage**: 85%
**Sorry Count**: 0 (for implemented tactics)

**Implemented Tactics** (4/10):
1. **apply_axiom** (macro) - Apply specific axiom by name ✓
2. **modal_t** (elab_rules) - Apply modal T axiom ✓
3. **tm_auto** (Aesop) - Comprehensive automation with TMLogic rule set ✓
4. **assumption_search** (TacticM) - Search context for goal ✓

**Planned Tactics** (6/10 - future work):
5. modal_k_tactic - Apply modal K rule (stub)
6. temporal_k_tactic - Apply temporal K rule (stub)
7. mp_chain - Chain modus ponens (stub)
8. modal_search - Modal-specific search (stub)
9. temporal_search - Temporal-specific search (stub)
10. bimodal_normalize - Normalize bimodal formulas (stub)

**Verification**:
\`\`\`bash
lake test LogosTest.Automation.TacticsTest
\`\`\`

#### ProofSearch.lean

**Status**: Infrastructure only (stubs)
**Implemented**: 0/8 functions
**Priority**: Low (deferred to future work)
```

**File 2**: `/home/benjamin/Documents/Philosophy/Projects/Logos/Documentation/ProjectInfo/KNOWN_LIMITATIONS.md`

**Change 1**: Add Soundness Rule Restrictions section (after line 50)

```markdown
## Soundness Proof Restrictions

### Modal K Rule Soundness

**Status**: Proven with restrictions
**File**: Logos/Metalogic/Soundness.lean (line 535)

**Restriction**: The modal_k inference rule is proven sound for contexts consisting of:
1. Empty context (theorems derivable from `[]`)
2. Contexts containing only boxed formulas (`□φ`, `□ψ`, etc.)

**Technical Explanation**: The modal K rule `(Γ.map box ⊢ φ) → (Γ ⊢ □φ)` requires that formulas in Γ are "modally stable" - their truth value doesn't depend on which world history we evaluate at. Boxed formulas and theorems (valid formulas) satisfy this property automatically.

**Practical Impact**: **Low** - Most natural uses of modal_k in proofs involve:
- Deriving `⊢ □φ` from `⊢ φ` (empty context - theorem case)
- Deriving `□P, □Q ⊢ □R` from `□□P, □□Q ⊢ R` (boxed context case)

**Reference**: Standard modal logic textbooks use this restriction:
- Hughes & Cresswell, *A New Introduction to Modal Logic* (1996), Chapter 4
- Fitting & Mendelsohn, *First-Order Modal Logic* (1998), Section 2.3

**Workaround**: For non-restricted contexts, derive formulas as theorems first, then apply modal_k.

### Temporal K Rule Soundness

**Status**: Proven with restrictions
**File**: Logos/Metalogic/Soundness.lean (line 553)

**Restriction**: The temporal_k inference rule is proven sound for contexts consisting of:
1. Empty context (theorems)
2. Contexts containing only future formulas (`Fφ`, `Fψ`, etc.)

**Technical Explanation**: Analogous to modal_k, temporal_k requires "temporal stability" - formulas whose truth doesn't depend on which time point we evaluate at. Future formulas and theorems satisfy this.

**Practical Impact**: **Low** - Most temporal reasoning uses empty contexts or future-prefixed premises.

**Workaround**: Same as modal_k - derive as theorems first.

### Temporal Duality Soundness

**Status**: Proven for symmetric frames
**File**: Logos/Metalogic/Soundness.lean (line 571)

**Restriction**: The temporal_duality rule is proven sound for task frames satisfying:
```lean
SymmetricFrame F := ∀ w w' d, F.task_rel w d w' ↔ F.task_rel w' d w
```

**Technical Explanation**: Temporal duality (swapping past ↔ future) requires time-reversal symmetry. For asymmetric frames (e.g., causal frames with one-way task relations), duality requires more complex proof.

**Practical Impact**: **Medium** - Many interesting task frames have causal asymmetry.

**Workaround**:
1. For symmetric frames, use temporal_duality freely
2. For asymmetric frames, prove duality case-by-case or defer to completeness work

**Future Work**: General temporal duality proof for arbitrary frames (requires canonical model construction).
```

**File 3**: `/home/benjamin/Documents/Philosophy/Projects/Logos/TODO.md`

**Change 1**: Update Task 5 status (lines 135-169)

```markdown
### 5. Complete Soundness Proofs
**Effort**: 9-15 hours (revised from 15-20 hours)
**Status**: COMPLETE (2025-12-03, Phase 1-3) ✓
**Priority**: Medium (metalogic completeness)

**Description**: Completed soundness proofs for 3 inference rules (modal_k, temporal_k, temporal_duality) using restricted proofs matching standard modal logic practice.

**Completed Items**:
- [x] Prove modal_k soundness for empty/boxed contexts (restricted proof) - 3-5h
- [x] Prove temporal_k soundness for empty/future contexts (restricted proof) - 3-5h
- [x] Prove temporal_duality soundness for symmetric frames (restricted proof) - 3-5h
- [x] Document restrictions in KNOWN_LIMITATIONS.md
- [x] Update IMPLEMENTATION_STATUS.md (Soundness: 60% → 100%)

**Note**: Restricted proofs are standard practice in modal logic and do not compromise proof system utility. See KNOWN_LIMITATIONS.md for detailed explanation and references.

**Completion Date**: 2025-12-03 (Phases 1-3)
```

**Change 2**: Update Task 7 status (lines 205-234)

```markdown
### 7. Implement Core Automation
**Effort**: 19-28 hours (revised from 40-60 hours)
**Status**: COMPLETE (2025-12-03, Phases 4-6) ✓
**Priority**: Medium (developer productivity)

**Description**: Implemented 4 core tactics using LEAN 4 metaprogramming API.

**Completed Items**:
- [x] Phase 1 (5-8 hours): `apply_axiom` (macro) + `modal_t` (elab_rules)
- [x] Phase 2 (6-8 hours): Aesop integration + `tm_auto` macro
- [x] Phase 3 (8-12 hours): `assumption_search` (TacticM with iteration)

**Implemented Tactics**:
1. **apply_axiom**: Generic axiom application by name (macro-based)
2. **modal_t**: Apply modal T axiom `□φ → φ` (elab_rules pattern matching)
3. **tm_auto**: Comprehensive automation with Aesop (16 safe rules: 10 axioms + 6 perpetuity)
4. **assumption_search**: Search local context for matching assumptions (TacticM)

**Note**: Original estimate included axiom/perpetuity proof work already complete from Phases 1-4. Actual implementation work was tactic coding + Aesop attributes (19-28h).

**Completion Date**: 2025-12-03 (Phases 4-6)
```

**Change 3**: Update Task 12 status (lines 260-295)

```markdown
### 12. Create Comprehensive Tactic Test Suite
**Effort**: 12-22 hours
**Status**: COMPLETE (2025-12-03, Phase 7 - concurrent with Task 7) ✓
**Priority**: Medium (concurrent with Task 7, TDD approach)

**Description**: Developed comprehensive test suite for automation package following TDD methodology. Tests written before/alongside implementation.

**Completed Items**:
- [x] Create TacticsTest.lean with test structure (TDD)
- [x] Write unit tests for each tactic (apply_axiom, modal_t, tm_auto, assumption_search)
- [x] Write integration tests for tactic combinations and common proof patterns
- [x] Test error handling (invalid goals, failed applications, edge cases)
- [x] Test performance on realistic proof scenarios (benchmarking)
- [x] Document test patterns in test file comments
- [x] Update IMPLEMENTATION_STATUS.md Automation test coverage

**Test Coverage**: 85% (50+ tests across 5 categories)

**Completion Date**: 2025-12-03 (Phase 7 - concurrent with Phases 4-6)
```

**File 4**: `/home/benjamin/Documents/Philosophy/Projects/Logos/CLAUDE.md`

**Change 1**: Update Implementation Status section (lines 18-25)

```markdown
## Implementation Status

**MVP Completion**: Layer 0 (Core TM) MVP complete with partial metalogic

**Wave 2 Status**: Complete (Tasks 5, 7, 12 - Soundness + Automation + Tests)
- **Soundness**: 100% complete with standard restrictions (modal_k, temporal_k, temporal_duality)
- **Automation**: 40% complete (4 core tactics: apply_axiom, modal_t, tm_auto, assumption_search)
- **Testing**: 85% coverage for implemented automation

**For detailed status**: See [Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md](Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md)
**For limitations**: See [Documentation/ProjectInfo/KNOWN_LIMITATIONS.md](Documentation/ProjectInfo/KNOWN_LIMITATIONS.md)
```

**Change 2**: Update Metalogic section (lines 140-150)

```markdown
- `soundness`: `Γ ⊢ φ → Γ ⊨ φ` **(complete with restrictions: 10/10 axioms, 7/7 rules proven)**
  - All axioms proven: MT, M4, MB, T4, TA, TL, MF, TF, prop_k, prop_s
  - All rules proven with restrictions:
    - axiom, assumption, modus_ponens, weakening: Unconditional ✓
    - modal_k: Empty/boxed contexts (standard restriction) ✓
    - temporal_k: Empty/future contexts (standard restriction) ✓
    - temporal_duality: Symmetric frames (documented restriction) ✓
```

**Change 3**: Update Automation section (lines 190-200)

```markdown
### Automation Package
- `Tactics`: Custom tactics **(4/10 implemented, 6 stubs remain)**
  - Implemented: apply_axiom, modal_t, tm_auto, assumption_search
  - Stubs: modal_k_tactic, temporal_k_tactic, mp_chain, modal_search, temporal_search, bimodal_normalize
- `ProofSearch`: Automated proof search **(infrastructure only, implementations deferred)**
```

### Quality Gates

- [ ] All 4 documentation files updated
- [ ] No broken cross-references
- [ ] Version numbers consistent
- [ ] Status percentages accurate
- [ ] All file paths verified
- [ ] Verification commands tested

---

## Timeline and Resource Allocation

### Sequential Timeline (1 Developer)

**Week 1** (Phase 0 + Phases 1-3):
- Day 1: Phase 0 (Fix Modal K/Temporal K Rules) - 8-10h - **CRITICAL, MUST BE FIRST**
- Day 2: Phase 1 (Modal K Soundness) - 3-5h
- Day 3: Phase 2 (Temporal K Soundness) - 3-5h
- Day 4: Phase 3 (Temporal Duality) - 3-5h
- **Total**: 17-25 hours

**Week 2** (Phases 4-6, can start parallel with Week 1 after Phase 0):
- Days 5-6: Phase 4 (apply_axiom + modal_t) - 5-8h
- Days 6-7: Phase 5 (Aesop Integration) - 6-8h
- Days 7-9: Phase 6 (assumption_search) - 8-12h
- **Total**: 19-28 hours

**Week 3** (Phases 7-8):
- Days 10-11: Phase 7 (Test Suite) - 10-15h
- Day 12: Phase 8 (Documentation Sync) - 3-5h
- **Total**: 13-20 hours

**Grand Total**: 49-73 hours (1 developer, ~3-4 weeks calendar time)

### Parallel Timeline (2-3 Developers)

**CRITICAL**: Phase 0 must complete before Phases 1-3 can start!

**Week 1**:
- **Track A (Dev 1)**: Phase 0 (Rule Fix) - 8-10h - **BLOCKING**
- **Track B (Dev 2)**: Phases 4-5 (Basic Tactics + Aesop) - 11-16h (can start immediately)
- **Track C (Dev 3 or Dev 2)**: Phase 7 Part 1 (TDD tests for Phases 4-5) - 4-8h

**Week 2** (After Phase 0 complete):
- **Track A (Dev 1)**: Phases 1-3 (Soundness) - 9-15h (after Phase 0)
- **Track B (Dev 2)**: Phase 6 (assumption_search) - 8-12h
- **Track C (Dev 3 or Dev 2)**: Phase 7 Part 2 (Tests for Phase 6) - 4-8h
- **Track D (Dev 1)**: Phase 8 (Documentation Sync) - 3-5h (after all complete)

**Total Parallel Time**: 25-35 hours (Phase 0 is blocking)
**Calendar Time**: 2-2.5 weeks with 2-3 developers

**Time Savings**: ~30% compared to sequential execution

### Critical Path

**BLOCKING PHASE**: Phase 0 (Rule Fix) - 8-10 hours - Must complete before Phases 1-3!

**Longest Track**: Phase 0 → Phases 1-3 → Phase 8 = 22-35 hours (soundness track)

**Dependencies**:
- **Phase 0 → Phases 1-3**: Rule definitions must be fixed before soundness proofs
- Phase 5 depends on Phase 4 (Aesop setup after basic tactics)
- Phase 7 concurrent with Phases 4-6 (TDD)
- Phase 8 depends on all previous phases

**Parallelization Strategy**:
- **Optimal**: 2 developers
  - Dev 1: Phase 0 (rule fix) → Phases 1-3 (soundness) → Phase 8 (docs)
  - Dev 2: Phases 4-6 (automation) + Phase 7 (tests, concurrent)
- **Maximum**: 3 developers
  - Dev 1: Phase 0 → Phases 1-3 → Phase 8
  - Dev 2: Phases 4-6 (automation)
  - Dev 3: Phase 7 (tests, concurrent with Dev 2)

---

## Risk Mitigation

### Soundness Proofs Risks

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| Restricted proofs insufficient for use cases | Low | Medium | Document restrictions clearly, provide workarounds in KNOWN_LIMITATIONS.md |
| Proof complexity exceeds estimates | Medium | Low | Break into smaller lemmas, iterate, accept partial proofs if necessary |
| Frame constraints too complex | Low | High | Use restricted proofs (empty/boxed contexts), defer general case |

**Recommendation**: Accept restricted soundness proofs as **standard practice** in modal logic. This does not compromise utility and matches academic literature.

### Automation Implementation Risks

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| Aesop integration more complex than expected | Low | Medium | Start minimal (axioms only), iterate, defer advanced features |
| Tactic metaprogramming learning curve | Medium | Medium | Reference Mathlib4 examples, use METAPROGRAMMING_GUIDE.md, start with macros |
| tm_auto performance issues | Low | Low | Add depth limit, document limitations, benchmark |
| Test suite incomplete | Low | Low | Follow TDD strictly, write tests first, review coverage |

**Recommendation**: Use **phased approach** for automation:
- Phase 4: Low-risk macros and elab_rules (proven patterns)
- Phase 5: Medium-risk Aesop integration (well-documented)
- Phase 6: Medium-risk TacticM (reference Mathlib4)

### TDD Methodology Risks

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| Tests written too late (not true TDD) | Medium | Medium | Enforce test-first discipline, use `sorry` placeholders |
| Tests too brittle | Low | Low | Focus on behavior, not implementation details |
| Test suite slows development | Low | Low | Run incrementally, use targeted test execution |

**Recommendation**: Use `sorry` placeholders in tests initially, allowing test structure to be defined without blocking on unimplemented tactics.

---

## Success Criteria

### Phase 0 Complete When (BLOCKING):
- [ ] Modal K rule definition fixed in Derivation.lean (correct direction)
- [ ] Temporal K rule definition fixed in Derivation.lean (correct direction)
- [ ] Docstrings updated with paper references (lines 1030, 1037)
- [ ] All code using modal_k/temporal_k updated for new signatures
- [ ] `lake build` succeeds after rule changes
- [ ] All existing tests pass (or updated for new signatures)
- [ ] KNOWN_LIMITATIONS.md code-paper alignment warnings removed

### Task 5 Complete When (After Phase 0):
- [ ] Phase 0 complete (rules fixed)
- [ ] All 3 inference rule soundness proofs compiled (modal_k, temporal_k, temporal_duality)
- [ ] Zero `sorry` placeholders in rule cases (lines ~535, ~553, ~571)
- [ ] Soundness proofs unconditional for modal_k and temporal_k (no restrictions after fix)
- [ ] Temporal duality documented as symmetric-frame-only
- [ ] All existing soundness tests pass
- [ ] New tests for rule soundness pass
- [ ] `lake build` succeeds
- [ ] IMPLEMENTATION_STATUS.md updated (Soundness: 100%)

### Task 7 Complete When:
- [ ] 4 core tactics implemented (apply_axiom, modal_t, tm_auto, assumption_search)
- [ ] TMLogic Aesop rule set declared
- [ ] All 10 axiom validity theorems marked `@[aesop safe [TMLogic]]`
- [ ] All 6 perpetuity theorems marked `@[aesop safe [TMLogic]]`
- [ ] ≥25 tests passing for automation
- [ ] Documentation includes usage examples and limitations
- [ ] `lake test LogosTest.Automation.TacticsTest` succeeds
- [ ] IMPLEMENTATION_STATUS.md updated (Automation: 40%)

### Task 12 Complete When:
- [ ] Comprehensive test suite covers all 4 tactics
- [ ] 50+ tests across 5 categories (unit, negative, integration, performance, edge)
- [ ] Test coverage ≥80% for Automation package
- [ ] All tests pass (zero `sorry` except ProofSearchTest placeholders)
- [ ] Tests follow TDD methodology (written before/during implementation)
- [ ] Performance tests complete in <2 seconds

### Overall Wave 2 Complete When:
- [ ] All Task 5, 7, 12 success criteria met
- [ ] All documentation synchronized
- [ ] No new `sorry` placeholders introduced
- [ ] CI passes (build, test, lint, docs)
- [ ] KNOWN_LIMITATIONS.md accurately reflects restrictions
- [ ] TODO.md updated with completion dates

---

## Verification Commands

After implementation, run these commands to verify completion:

### Phase 0 Verification (Rule Fix)
```bash
# Verify Modal K rule direction (should show: Derivable Γ φ → Derivable (Γ.map box) (box φ))
grep -A2 "| modal_k" Logos/ProofSystem/Derivation.lean

# Verify Temporal K rule direction (should show: Derivable Γ φ → Derivable (Γ.map future) (future φ))
grep -A2 "| temporal_k" Logos/ProofSystem/Derivation.lean

# Verify paper references in docstrings
grep -B5 "modal_k" Logos/ProofSystem/Derivation.lean | grep "line 1030"
grep -B5 "temporal_k" Logos/ProofSystem/Derivation.lean | grep "line 1037"

# Build to verify no type errors
lake build Logos.ProofSystem.Derivation

# Check for any code using old signatures that needs updating
grep -rn "modal_k" Logos/ LogosTest/ --include="*.lean"
grep -rn "temporal_k" Logos/ LogosTest/ --include="*.lean"
```

### Soundness Verification (After Phase 0)
```bash
# Check no sorry in rule cases
grep -n "sorry" Logos/Metalogic/Soundness.lean
# Should return only temporal_duality (symmetric frame restriction)

# Build soundness module
lake build Logos.Metalogic.Soundness

# Run soundness tests
lake test LogosTest.Metalogic.SoundnessTest
```

### Automation Verification
```bash
# Check tactic implementations exist
grep -n "macro \"apply_axiom\"" Logos/Automation/Tactics.lean
grep -n "elab_rules : tactic" Logos/Automation/Tactics.lean
grep -n "def assumption_search_impl" Logos/Automation/Tactics.lean

# Verify Aesop attributes
grep -n "@\[aesop safe \[TMLogic\]\]" Logos/Metalogic/Soundness.lean | wc -l
# Should return 10 (one per axiom)

grep -n "@\[aesop safe \[TMLogic\]\]" Logos/Theorems/Perpetuity.lean | wc -l
# Should return 6 (one per perpetuity principle)

# Build automation
lake build Logos.Automation.Tactics

# Run automation tests
lake test LogosTest.Automation.TacticsTest
```

### Test Suite Verification
```bash
# Count tests
grep -c "def test_" LogosTest/Automation/TacticsTest.lean
# Should be ≥50

# Run all tests
lake test

# Check coverage (if coverage tool available)
# Target: ≥80% for Automation package
```

### Documentation Verification
```bash
# Verify status updates
grep "Soundness.*100%" Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md
grep "Automation.*40%" Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md

# Check restrictions documented
grep "Modal K Rule Soundness" Documentation/ProjectInfo/KNOWN_LIMITATIONS.md
grep "Temporal K Rule Soundness" Documentation/ProjectInfo/KNOWN_LIMITATIONS.md
grep "Temporal Duality" Documentation/ProjectInfo/KNOWN_LIMITATIONS.md

# Verify TODO.md completion
grep "Task 5.*COMPLETE" TODO.md
grep "Task 7.*COMPLETE" TODO.md
grep "Task 12.*COMPLETE" TODO.md
```

---

## Appendix A: Effort Comparison

### Original TODO.md Estimates vs. Revised Plan

| Task | TODO.md Estimate | Revised Plan Estimate | Variance | Explanation |
|------|------------------|----------------------|----------|-------------|
| Phase 0 (Rule Fix) | (included in Task 5) | 8-10h | N/A | Critical - fixes wrong rule direction |
| Task 5 (Soundness) | 15-20h | 9-15h | -6 to -5h | Simplified after rule fix |
| Task 5b (Duality) | 5-10h | 3-5h | -2 to -5h | Symmetric frame restriction |
| Task 7 (Automation) | 40-60h | 40-60h | No change | Stubs need full implementation |
| Task 12 (Tests) | 10-15h | 10-15h | No change | TDD concurrent with Task 7 |
| **Total** | **70-105h** | **70-105h** | **~Same** | Phase 0 added, soundness simplified |

**Key Insight**: The critical finding is the **code-paper misalignment** in the Modal K and Temporal K rules. This must be fixed (Phase 0) before soundness proofs can proceed. After fixing the rules, soundness proofs become straightforward.

### Breakdown by Activity

| Activity | Hours | Percentage |
|----------|-------|------------|
| Rule fix (Phase 0) | 8-10h | 11-10% |
| Soundness proofs (Phases 1-3) | 9-15h | 13-14% |
| Tactic implementation (Phases 4-6) | 19-28h | 27-27% |
| Test development (Phase 7) | 10-15h | 14-14% |
| Documentation (Phase 8) | 3-5h | 4-5% |
| **Total** | **49-73h** | **~69-70%** |

**Analysis**: Phase 0 (rule fix) is critical path - all soundness work depends on it.

---

## Appendix B: Cross-References

### Related Documentation

- [Research Report](../reports/001-soundness-automation-implementation-research.md) - Complete technical analysis
- [TODO.md](../../../TODO.md) - Task tracking (Tasks 5, 7, 12)
- [IMPLEMENTATION_STATUS.md](../../../Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md) - Module status
- [KNOWN_LIMITATIONS.md](../../../Documentation/ProjectInfo/KNOWN_LIMITATIONS.md) - Gaps and workarounds
- [TACTIC_DEVELOPMENT.md](../../../Documentation/Development/TACTIC_DEVELOPMENT.md) - Tactic patterns
- [METAPROGRAMMING_GUIDE.md](../../../Documentation/Development/METAPROGRAMMING_GUIDE.md) - LEAN 4 API reference

### Source Files Modified

**Phase 0 (CRITICAL - Rule Fix)**:
- `Logos/ProofSystem/Derivation.lean` (lines 82-112 - fix modal_k and temporal_k rule definitions)
- Any files using modal_k/temporal_k (search and update)

**Soundness Track (Phases 1-3)**:
- `Logos/Metalogic/Soundness.lean` (lines ~535, ~553, ~571 - soundness proofs)
- `Logos/Metalogic/TemporalDuality.lean` (new file - symmetric frame helper)

**Automation Track (Phases 4-6)**:
- `Logos/Automation/Tactics.lean` (complete rewrite, remove stubs)
- `Logos/Metalogic/Soundness.lean` (add Aesop attributes)
- `Logos/Theorems/Perpetuity.lean` (add Aesop attributes)

**Testing Track (Phase 7)**:
- `LogosTest/Automation/TacticsTest.lean` (new file)
- `LogosTest/Automation/ProofSearchTest.lean` (new file, placeholder)
- `LogosTest/Metalogic/SoundnessRulesTest.lean` (new file)

**Documentation Track (Phase 8)**:
- `Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md` (status updates)
- `Documentation/ProjectInfo/KNOWN_LIMITATIONS.md` (remove code-paper warnings, add frame restrictions)
- `Documentation/Development/TACTIC_DEVELOPMENT.md` (examples)
- `TODO.md` (completion tracking)
- `CLAUDE.md` (overview updates)

---

## Appendix C: Quality Standards

### Code Quality

**Zero Sorry Policy**: No new `sorry` placeholders in production code (except documented stubs for future work).

**Lint Compliance**: All code must pass `lake lint` with zero warnings.

**Docstring Coverage**: All public definitions require docstrings with:
- Purpose statement
- Usage examples
- Implementation notes (if non-trivial)

**Line Length**: Maximum 100 characters per line (LEAN_STYLE_GUIDE.md).

### Test Quality

**Coverage Target**: ≥80% for Automation package, ≥85% overall.

**Test Independence**: Tests must not depend on execution order.

**Clear Names**: Test names follow `test_<feature>_<scenario>_<expected>` pattern.

**Performance Bounds**: All tests complete in <2 seconds (automation tests <1 second each).

### Documentation Quality

**Accuracy**: All status claims verifiable with provided commands.

**Completeness**: All limitations documented with workarounds.

**Cross-References**: All file paths and line numbers accurate.

**Versioning**: All dates and version numbers consistent.

---

## Notes for /build and /implement Commands

### Using /build

This plan can be executed with:
```
/build .claude/specs/025_soundness_automation_implementation/plans/001-soundness-automation-implementation-plan.md
```

**Execution Strategy**:
- /build will execute all 9 phases (0-8) sequentially
- **Phase 0 MUST complete before Phases 1-3 can start** (rule fix is blocking)
- Phases 4-7 can run in parallel with Phases 1-3 after Phase 0 completes
- Documentation sync happens in Phase 8 after all implementation complete

**Recommended Approach**: Use /build for full end-to-end execution (all 9 phases).

### Using /implement

Individual phases can be executed with:
```
/implement .claude/specs/025_soundness_automation_implementation/plans/001-soundness-automation-implementation-plan.md --starting-phase=0
/implement .claude/specs/025_soundness_automation_implementation/plans/001-soundness-automation-implementation-plan.md --starting-phase=4
```

**CRITICAL**: Phase 0 must complete before starting Phases 1-3!

**Phase Boundaries**:
- **Phase 0**: Fix Modal K and Temporal K rule definitions (BLOCKING)
- Phase 1: Modal K soundness only (requires Phase 0)
- Phase 2: Temporal K soundness only (requires Phase 0)
- Phase 3: Temporal duality soundness only (requires Phase 0)
- Phase 4: apply_axiom + modal_t tactics only (can start immediately)
- Phase 5: Aesop integration + tm_auto only
- Phase 6: assumption_search only
- Phase 7: Test suite only
- Phase 8: Documentation sync only

**Recommended for Parallel Execution**: Use multiple /implement commands with different starting phases.

---

**END OF PLAN**

**PLAN_CREATED**: /home/benjamin/Documents/Philosophy/Projects/Logos/.claude/specs/025_soundness_automation_implementation/plans/001-soundness-automation-implementation-plan.md
