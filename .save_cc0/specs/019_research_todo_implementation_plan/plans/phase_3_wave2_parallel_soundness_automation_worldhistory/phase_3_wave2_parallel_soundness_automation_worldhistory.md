# Phase 3: Wave 2 Parallel - Soundness, Automation, WorldHistory [COMPLETE]

## Metadata
- **Date**: 2025-12-02 (Revised: 2025-12-03 - Transport lemmas complete, Truth.lean fully proven)
- **Parent Plan**: TODO Implementation Systematic Plan
- **Phase Number**: 3
- **Dependencies**: Phase 1 (Wave 1 - High Priority Foundations)
- **Estimated Hours**: 35-52 hours sequential, ~25-38 hours parallel (reduced after axiom fix)
- **Actual Hours**: ~8-10 hours (transport lemmas and Truth.lean completion)
- **Complexity**: Medium (reduced from High after axiom alignment)
- **Status**: [COMPLETE] - All transport lemmas proven, Truth.lean 0 sorry
- **Sub-Phases**: 3 (parallel execution)

## Paper Correspondence

**Key Requirement**: All proofs must maintain close correspondence to the JPL paper appendix:
- `/home/benjamin/Documents/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex`

**Relevant Paper Sections**:
- **Definition 12 (def:time-shift-histories, line 1873)**: Time-shift between world histories
- **Lemma 5 (app:auto_existence, line 1879)**: Existence of time-shifted histories
- **Lemma 6 (lem:history-time-shift-preservation, lines 1913-1980)**: Truth preservation under time-shift
- **Theorem 8 (thm:bimodal-axioms-valid, lines 2343-2357)**: MF and TF validity proofs

---

## Implementation Progress (2025-12-03)

### Completed Work

#### Task 3A.1: TL Axiom Proof ✅ COMPLETE
**File**: `Logos/Metalogic/Soundness.lean`

**What was done**:
1. Added classical logic helper `and_of_not_imp_not` to extract conjunction from negated implication encoding
2. Completed proof of `temp_l_valid` using:
   - `simp only [Formula.always, Formula.and, Formula.neg, truth_at]` to unfold conjunction encoding
   - Classical extraction via `and_of_not_imp_not` to get `h_past`, `h_now`, `h_future`
   - Case split using `Int.lt_trichotomy r t` for three cases (r < t, r = t, t < r)

**Paper Correspondence**: Follows paper proof at line 2334 - given `always φ` (φ at all times), proving `Future Past φ` is immediate since any past time of any future time is still "all times."

#### Task 3A.2: Time-Shift Infrastructure ✅ COMPLETE
**File**: `Logos/Semantics/WorldHistory.lean`

**What was implemented**:
```lean
/-- Time-shifted history construction.
Given history σ and shift offset Δ, construct τ where:
- τ.domain z ↔ σ.domain (z + Δ)
- τ.states z = σ.states (z + Δ)
-/
def time_shift (σ : WorldHistory F) (Δ : Int) : WorldHistory F where
  domain := fun z => σ.domain (z + Δ)
  states := fun z hz => σ.states (z + Δ) hz
  respects_task := by
    -- Duration (t - s) is preserved under translation: (t + Δ) - (s + Δ) = t - s
    intros s t hs ht hst
    have h_shifted : (s + Δ) ≤ (t + Δ) := Int.add_le_add_right hst Δ
    have h_duration : (t + Δ) - (s + Δ) = t - s := by omega
    rw [← h_duration]
    exact σ.respects_task (s + Δ) (t + Δ) hs ht h_shifted
```

**Paper Correspondence**: Matches Definition 12 (def:time-shift-histories) at line 1873:
- `τ ≈_y^x σ` witnessed by `ā(z) = z - x + y`
- `dom(σ) = ā⁻¹(dom(τ))`
- `σ(z) = τ(ā(z))` for all z ∈ dom(σ)

**Also added**:
- `time_shift_domain_iff`: Domain membership equivalence
- `time_shift_inverse_domain`: Double shift cancellation

#### Task 3A.4: MF Axiom Proof ✅ COMPLETE
**File**: `Logos/Metalogic/Soundness.lean` (lines 400-423)

**What was done**:
Proved `modal_future_valid` using time-shift preservation:
```lean
theorem modal_future_valid (φ : Formula) : ⊨ ((φ.box).imp ((φ.future).box)) := by
  intro F M τ t ht
  unfold truth_at
  intro h_box_phi σ hs s hs' hts
  have h_shifted_domain : (WorldHistory.time_shift σ (s - t)).domain t := by
    simp only [WorldHistory.time_shift]
    have : t + (s - t) = s := by omega
    rw [this]; exact hs'
  have h_phi_at_shifted := h_box_phi (WorldHistory.time_shift σ (s - t)) h_shifted_domain
  have h_preserve := TimeShift.time_shift_preserves_truth M σ t s h_shifted_domain hs' φ
  exact h_preserve.mp h_phi_at_shifted
```

#### Task 3A.5: TF Axiom Proof ✅ COMPLETE
**File**: `Logos/Metalogic/Soundness.lean` (lines 452-475)

**What was done**:
Proved `temp_future_valid` using time-shift preservation (symmetric to MF).

**Key Achievement**: All 10 TM axioms now have validity lemmas!

#### Task 3A.6: Transport Lemmas ✅ COMPLETE (2025-12-03)
**File**: `Logos/Semantics/WorldHistory.lean`

**Lemmas implemented**:

| Lemma | Purpose |
|-------|---------|
| `states_eq_of_time_eq` | States equal when times provably equal (proof irrelevance) |
| `time_shift_time_shift_states` | Double shift (Δ, -Δ) returns original states |
| `time_shift_congr` | Shifting by equal amounts gives equal histories |
| `time_shift_zero_domain_iff` | Domain unchanged by shift of 0 |
| `time_shift_time_shift_neg_domain_iff` | Double shift domain equals original |
| `time_shift_time_shift_neg_states` | Double shift states equal original |

#### Task 3A.7: Time-Shift Preservation Lemma ✅ COMPLETE (2025-12-03)
**File**: `Logos/Semantics/Truth.lean`

**What was done**:
1. Added `truth_proof_irrel` - Truth independent of domain membership proof
2. Added `truth_history_eq` - Truth preserved under history equality
3. Added `truth_double_shift_cancel` - **Key lemma** for transporting truth across double time-shift
4. Completed all 6 cases of `time_shift_preserves_truth`:
   - **Atom**: Uses `states_eq_of_time_eq` with `x + (y - x) = y`
   - **Bot**: Trivial (both sides are `False`)
   - **Imp**: IH on both subformulas
   - **Box**: Uses `truth_double_shift_cancel` for backward direction
   - **Past**: Bijection between times via time arithmetic + `truth_proof_irrel`
   - **Future**: Symmetric to past case

**Sorry removed**: 4 (was 4, now 0 in Truth.lean)

---

### Sub-Phase 3B: Automation (Task 7) [DEFERRED]

Automation tactics are lower priority than completing soundness proofs.
See stage files for detailed plans when ready.

### Sub-Phase 3C: WorldHistory Fix (Task 8) ✅ DOCUMENTED

The `universal` constructor has a `sorry` because it requires reflexive frame property.
**Decision**: Document limitation and leave sorry (chosen option 2).

**Documentation in place**:
- Detailed docstring explaining frame constraint requirement
- Examples of reflexive vs non-reflexive frames
- Impact on semantics explained
- Future work options documented

---

## Technical Notes

### Dependent Type Challenges

The time-shift preservation proof involves dependent types that complicate proof transport:
- `truth_at M τ t ht φ` depends on `ht : τ.domain t`
- When shifting histories, domain proofs must be transported
- Lean's proof irrelevance helps but requires careful `convert` tactics

**Key Insight (2025-12-03)**: Lean 4 has proof irrelevance for `Prop`-valued types, so when
`t₁ = t₂` (as `Int`), then `ht₁ : σ.domain t₁` and `ht₂ : σ.domain t₂` are definitionally
equal after `subst`. This means `states_eq_of_time_eq` works with just `subst h; rfl`.

### Key Realization: truth_double_shift_cancel

The `truth_double_shift_cancel` lemma is more powerful than case-splitting on formula structure in the main theorem. It provides a general transport principle that handles all formula constructors uniformly via structural induction:

```lean
theorem truth_double_shift_cancel (M : TaskModel F) (σ : WorldHistory F) (Δ : Int) (t : Int)
    (ht : σ.domain t) (ht' : (WorldHistory.time_shift (WorldHistory.time_shift σ Δ) (-Δ)).domain t)
    (φ : Formula) :
    truth_at M (WorldHistory.time_shift (WorldHistory.time_shift σ Δ) (-Δ)) t ht' φ ↔
    truth_at M σ t ht φ
```

### Classical Logic in Conjunction Handling

The formula encoding `φ ∧ ψ := ¬(φ → ¬ψ)` requires classical reasoning to extract components.
The helper `and_of_not_imp_not` uses `Classical.byContradiction` for this.

### Build Status

Current state (2025-12-03 post-completion):
- `lake build` succeeds ✅
- Sorry markers:
  - Soundness.lean: 3 (modal_k, temporal_k, temporal_duality inference rules)
  - Truth.lean: **0** ✅
  - WorldHistory.lean: 1 (universal helper - documented limitation)
- **All 8 TM axiom proofs are complete** ✅
- **time_shift_preserves_truth fully proven** ✅

---

## Success Criteria

- [x] Axiom definitions aligned with paper (Formula.lean, Axioms.lean)
- [x] TL axiom documentation updated (Soundness.lean)
- [x] MF/TF axiom documentation updated with paper proof references
- [x] lake build succeeds
- [x] TL axiom proof completed (conjunction handling)
- [x] Time-shift infrastructure implemented in WorldHistory.lean
- [x] MF axiom soundness proven using time-shift ✅ (2025-12-03)
- [x] TF axiom soundness proven using time-shift ✅ (2025-12-03)
- [x] Transport lemmas implemented in WorldHistory.lean (Task 3A.6) ✅ (2025-12-03)
- [x] Time-shift preservation lemma completed in Truth.lean (Task 3A.7) ✅ (2025-12-03)
- [x] Sub-Phase 3B automation phases deferred (documented)
- [x] Sub-Phase 3C WorldHistory documented (limitation accepted)

---

## Summary of Current Sorry Markers (5 total, down from 8)

| File | Line | Case | Status |
|------|------|------|--------|
| ~~Truth.lean~~ | ~~196~~ | ~~atom~~ | ✅ PROVEN |
| ~~Truth.lean~~ | ~~255~~ | ~~box~~ | ✅ PROVEN |
| ~~Truth.lean~~ | ~~262~~ | ~~past~~ | ✅ PROVEN |
| ~~Truth.lean~~ | ~~268~~ | ~~future~~ | ✅ PROVEN |
| Soundness.lean | 551 | modal_k | Deferred (frame constraint) |
| Soundness.lean | 569 | temporal_k | Deferred (frame constraint) |
| Soundness.lean | 584 | temporal_duality | Deferred (semantic duality) |
| WorldHistory.lean | 119 | universal | Documented limitation |

**Total sorry in Logos/**: 5 (in core files) + 4 (in Automation stubs) = 9

---

## Artifacts

- **Summary**: [lean_proof_phase3_transport.md](../summaries/lean_proof_phase3_transport.md)
- **Files Modified**:
  - `Logos/Semantics/WorldHistory.lean` (lines 200-260: 6 transport lemmas)
  - `Logos/Semantics/Truth.lean` (lines 162-538: helper lemmas + completed proof)

---

## Phase 3 Completion Summary

| Component | Status | Sorry Before | Sorry After | Change |
|-----------|--------|--------------|-------------|--------|
| Task 3A.1 (TL axiom) | ✅ COMPLETE | 0 | 0 | - |
| Task 3A.2 (Time-shift infra) | ✅ COMPLETE | 0 | 0 | - |
| Task 3A.4 (MF axiom) | ✅ COMPLETE | 0 | 0 | - |
| Task 3A.5 (TF axiom) | ✅ COMPLETE | 0 | 0 | - |
| Task 3A.6 (Transport lemmas) | ✅ COMPLETE | 0 | 0 | - |
| Task 3A.7 (Truth.lean) | ✅ COMPLETE | 4 | 0 | **-4** |
| Sub-Phase 3B (Automation) | ⏳ DEFERRED | 4 | 4 | - |
| Sub-Phase 3C (WorldHistory) | ✅ DOCUMENTED | 1 | 1 | - |

**Net sorry reduction**: 4 (in Truth.lean)

**Phase 3A Status**: ✅ **COMPLETE**
