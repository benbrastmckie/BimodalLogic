# Implementation Plan: Wire Dense Completeness Domain Connection (v7)

- **Task**: 982 - Wire dense completeness: connect CanonicalMCS-based BFMCS to TimelineQuot-based semantics
- **Status**: [PARTIAL]
- **Effort**: 8-12 hours (5 phases)
- **Dependencies**: Task 985 (parametric infrastructure - complete)
- **Research Inputs**:
  - research-009.md (W vs D semantics architecture - **primary**)
  - research-008.md (domain transfer analysis - context)
- **Artifacts**: plans/implementation-007.md (this file), supersedes implementation-001 through 006.md
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Revision History

**v007 (2026-03-17)**: **ARCHITECTURAL PIVOT** based on research-009. The key insight: TaskFrame semantics has TWO architecturally distinct components that previous approaches conflated:
- **W (World States)** = CanonicalMCS (the set of ALL MCSs)
- **D (Durations)** = TimelineQuot (constructed dense linear order)

WorldHistory `h : D → W` maps times to world states. Witnesses exist in W (all MCSs are available), NOT in Range(h). This makes the staged construction edge cases (m > 2k) irrelevant.

**v006**: SUPERSEDED. Attempted domain transfer via Rat, but found the same forward_F gaps propagate through any transfer.

**v005**: SUPERSEDED. Attempted direct staged construction proofs, blocked by F-content not transferring along CanonicalR chains.

## Executive Summary

### The Architectural Breakthrough (research-009)

The semantics separates:
- **D** (duration/time domain): Needs LinearOrder + DenselyOrdered
- **W** (world states): Space of possible world configurations

Previous approaches failed by conflating these or importing D externally:

| Previous Approach | Error |
|-------------------|-------|
| D = TimelineQuot, W = TimelineQuot | Conflated W and D; witnesses must be in Range(h) |
| D = Rat (imported) | Violates pure-syntax constraint |
| D = CanonicalMCS | Only Preorder, not LinearOrder |

### The Correct Separation

| Component | What It Is | In Implementation |
|-----------|------------|-------------------|
| **W** | Space of ALL world states | CanonicalMCS (all MCSs) |
| **D** | Time domain | TimelineQuot (constructed, dense, linear) |
| **h : D → W** | World history | Maps each time to an MCS |
| **Witnesses** | Exist in W | ALL MCSs available, not just Range(h) |

**Key insight**: Forward_F/backward_P witnesses don't need to be in TimelineQuot - they just need to exist in CanonicalMCS.

### Why This Resolves the Blocker

The staged construction blocker was:
```
F(φ) in fam.mcs(t) → ∃ s > t, φ in fam.mcs(s)
BUT: canonical_forward_F witness may not be in TimelineQuot
```

With W/D separation:
- The witness W from canonical_forward_F exists in CanonicalMCS (= W)
- W doesn't need to be in Range(h) - it just needs to be in W
- The truth lemma evaluates over W, not over Range(h)

## Goals & Non-Goals

**Goals**:
- Complete `dense_completeness_theorem` using W/D separated architecture
- Build TaskFrame with D = TimelineQuot, W = CanonicalMCS
- Prove truth lemma holds when witnesses are in W (not necessarily Range(h))
- Zero new sorries, **zero new axioms**

**Non-Goals**:
- Prove forward_F for TimelineQuot directly (unnecessary with W/D separation)
- Build BFMCS with all witnesses in TimelineQuot (unnecessary)
- Import D from Rat (violates pure-syntax)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| TaskFrame type parameters don't match | High | Low | Check TaskFrame has separate WorldState type |
| Truth lemma requires witnesses in Range(h) | High | Medium | Verify truth evaluation quantifies over W, not Range(h) |
| Modal saturation needs families in W | Medium | Medium | Use existing ModalSaturation infrastructure |
| Integration complexity | Low | Medium | Parametric infrastructure already D-generic |

## Implementation Phases

### Phase 1: Verify Semantics Architecture [COMPLETED]

- **Dependencies**: None
- **Goal**: Confirm TaskFrame and truth evaluation support W/D separation

**Key Verification Points:**

1. **TaskFrame structure**:
   ```lean
   -- Verify WorldState is separate type parameter
   #check @TaskFrame -- should have: D : Type*, WorldState : Type
   ```

2. **Truth evaluation quantification**:
   - Box: quantifies over histories (which map into W), not directly over W
   - G/H: quantifies over times in D
   - Witnesses for modal formulas: need to exist in W (accessible via some history)

3. **Check if existing BFMCS can use W = CanonicalMCS**:
   ```lean
   -- BFMCS.families : Set (FMCS D)
   -- Each FMCS.mcs : D → Set Formula
   -- The MCS at each time is in W = CanonicalMCS
   ```

**Tasks**:
- [ ] Read TaskFrame.lean to verify WorldState is separate from D
- [ ] Read Truth.lean to understand how Box quantifies (over histories or MCSs?)
- [ ] Determine if "witness in W" suffices or if "witness in Range(h)" is required
- [ ] Document the exact interface between D, W, and WorldHistory

**Timing**: 1.5 hours

**Files**:
- `Theories/Bimodal/Semantics/TaskFrame.lean` - READ
- `Theories/Bimodal/Semantics/Truth.lean` - READ
- `Theories/Bimodal/Semantics/WorldHistory.lean` - READ

**Verification**:
- Document findings in implementation summary
- If architecture doesn't support W/D separation: identify what changes are needed

---

### Phase 2: Build Separated TaskFrame [COMPLETED]

- **Dependencies**: Phase 1 (confirms architecture)
- **Goal**: Define TaskFrame with D = TimelineQuot, W = CanonicalMCS

**Construction:**

```lean
/-- TaskFrame with W = CanonicalMCS, D = TimelineQuot -/
def separatedCanonicalTaskFrame
    (root_mcs : Set Formula) (root_mcs_proof : SetMaximalConsistent root_mcs) :
    TaskFrame (TimelineQuot root_mcs root_mcs_proof) where
  WorldState := CanonicalMCS  -- ALL MCSs, not just TimelineQuot's
  task_rel := fun w d v => -- defined via CanonicalR and duration
    if d >= 0 then CanonicalR w.world v.world
    else CanonicalR v.world w.world
  nullity_identity := by ...
  forward_comp := by ...
  converse := by ...
```

**Key insight**: task_rel is defined in terms of CanonicalR over CanonicalMCS, not TimelineQuot's stage relation.

**Tasks**:
- [ ] Define `separatedCanonicalTaskFrame`
- [ ] Prove `nullity_identity`: d = 0 ⟹ w = v (CanonicalR is reflexive-ish)
- [ ] Prove `forward_comp`: task_rel compositions add durations
- [ ] Prove `converse`: task_rel with -d is converse

**Timing**: 2-3 hours

**Files**:
- `Theories/Bimodal/Metalogic/Algebraic/SeparatedTaskFrame.lean` - NEW

**Verification**:
- `lake build Bimodal.Metalogic.Algebraic.SeparatedTaskFrame` passes
- `grep -n "\bsorry\b" SeparatedTaskFrame.lean` returns empty

---

### Phase 3: Build WorldHistories Over Separated Frame [COMPLETED]

- **Dependencies**: Phase 2
- **Goal**: Construct WorldHistories that map TimelineQuot into CanonicalMCS

**Construction:**

```lean
/-- A WorldHistory over the separated TaskFrame.
    Maps each time t : TimelineQuot to an MCS in CanonicalMCS. -/
def timelineQuotHistory
    (root_mcs : Set Formula) (root_mcs_proof : SetMaximalConsistent root_mcs)
    (fam : FMCS (TimelineQuot root_mcs root_mcs_proof)) :
    WorldHistory (separatedCanonicalTaskFrame root_mcs root_mcs_proof) where
  domain := fun _ => True  -- full domain
  convex := by trivial
  states := fun t _ => ⟨fam.mcs t, fam.is_mcs t⟩  -- map time to MCS in CanonicalMCS
  respects_task := by ...  -- from forward_G/backward_H of FMCS
```

**Key point**: The history maps into CanonicalMCS (W), not just TimelineQuot.

**Tasks**:
- [ ] Define `timelineQuotHistory` from an FMCS
- [ ] Prove `respects_task` using forward_G/backward_H properties
- [ ] Define the shift-closed set of histories Ω
- [ ] Prove Ω is non-empty

**Timing**: 2 hours

**Files**:
- `Theories/Bimodal/Metalogic/Algebraic/SeparatedHistory.lean` - NEW

**Verification**:
- `lake build Bimodal.Metalogic.Algebraic.SeparatedHistory` passes
- `grep -n "\bsorry\b" SeparatedHistory.lean` returns empty

---

### Phase 4: Truth Lemma for Separated Frame [BLOCKED]

- **Dependencies**: Phase 3
- **Goal**: Prove truth lemma with witnesses in W (CanonicalMCS)

**The Critical Theorem:**

```lean
/-- Truth lemma for separated frame:
    φ in fam.mcs(t) ↔ truth_at M Ω (timelineQuotHistory fam) t φ

    The key difference from previous approaches:
    - Modal witnesses (for Diamond) come from CanonicalMCS (W)
    - They don't need to be in Range(timelineQuotHistory)
    - They're accessible via OTHER histories in Ω -/
theorem separated_truth_lemma
    (root_mcs : Set Formula) (root_mcs_proof : SetMaximalConsistent root_mcs)
    (B : BFMCS (TimelineQuot root_mcs root_mcs_proof))
    (φ : Formula) (fam : FMCS _) (hfam : fam ∈ B.families) (t : TimelineQuot _ _) :
    φ ∈ fam.mcs t ↔
    truth_at (separatedCanonicalModel ...) (separatedOmega ...)
             (timelineQuotHistory root_mcs root_mcs_proof fam) t φ := by
  induction φ generalizing t with
  | atom p => ...
  | neg φ ih => ...
  | and φ ψ ih1 ih2 => ...
  | box φ ih =>
    -- Diamond case: need witness history σ ∈ Ω with φ true at t
    -- Key: σ.states(t) can be ANY MCS in CanonicalMCS
    -- Use canonical_forward_F to get witness MCS
    -- Build witness history through that MCS
    ...
  | all_future φ ih =>
    -- F case: need witness time s > t with φ true at s
    -- Use timelineQuotFMCS's forward_G (already proven)
    ...
  | all_past φ ih =>
    -- P case: symmetric to F
    ...
```

**The Modal Case Resolution:**

When Diamond(ψ) ∈ fam.mcs(t):
1. By MCS properties, ψ is consistent with certain formulas
2. By Lindenbaum, extends to MCS W ∈ CanonicalMCS
3. Build a history σ ∈ Ω that passes through W at time t
4. By truth lemma on σ, ψ is true at t in σ
5. Hence Diamond(ψ) is true at t in the original history

**Tasks**:
- [ ] Define `separatedCanonicalModel` (valuation via MCS membership)
- [ ] Define `separatedOmega` (shift-closed histories)
- [ ] Prove `separated_truth_lemma` by induction
- [ ] Handle atom, neg, and, box, all_future, all_past cases
- [ ] For box: construct witness history through canonical MCS

**Timing**: 3-4 hours

**Files**:
- `Theories/Bimodal/Metalogic/Algebraic/SeparatedTruthLemma.lean` - NEW

**Verification**:
- `lake build Bimodal.Metalogic.Algebraic.SeparatedTruthLemma` passes
- `grep -n "\bsorry\b" SeparatedTruthLemma.lean` returns empty

---

### Phase 5: Complete Dense Completeness [NOT STARTED]

- **Dependencies**: Phase 4
- **Goal**: Wire together to complete `dense_completeness_theorem`

**Theorem Structure:**

```lean
theorem dense_completeness_theorem :
    (∀ (D : Type*) [AddCommGroup D] [LinearOrder D] [DenselyOrdered D]
       [NoMinOrder D] [NoMaxOrder D], valid_over D φ) →
    Nonempty ([] ⊢ φ) := by
  intro h_valid
  by_contra h_not_prov
  -- Step 1: φ.neg is consistent
  have h_cons := not_provable_implies_neg_consistent φ h_not_prov
  -- Step 2: Extend to MCS M₀
  obtain ⟨M₀, h_mcs, h_neg_in⟩ := set_lindenbaum {φ.neg} h_cons
  -- Step 3: Build TimelineQuot from M₀
  let D := TimelineQuot M₀ h_mcs
  -- Step 4: Build separated TaskFrame with D = TimelineQuot, W = CanonicalMCS
  let F := separatedCanonicalTaskFrame M₀ h_mcs
  -- Step 5: Build BFMCS and history
  let B := ... -- BFMCS with root at M₀
  let h := timelineQuotHistory M₀ h_mcs B.eval_family
  -- Step 6: By separated_truth_lemma, φ.neg is true at root
  have h_neg_true : truth_at (separatedCanonicalModel ...) (separatedOmega ...) h root φ.neg := by
    rw [← separated_truth_lemma]
    exact h_neg_in
  -- Step 7: Hence φ is false at root
  have h_false : ¬truth_at ... h root φ := by
    simp [truth_at, Formula.neg] at h_neg_true
    exact h_neg_true
  -- Step 8: Contradiction with h_valid (D = TimelineQuot is a dense linear order)
  have := h_valid D
  -- ... apply validity to get contradiction
  sorry -- connect to valid_over definition
```

**Tasks**:
- [ ] Define BFMCS construction for the separated frame
- [ ] Connect `valid_over` to `separatedCanonicalModel` truth
- [ ] Complete the completeness proof
- [ ] Resolve the original `timelineQuot_not_valid_of_neg_consistent` sorry
- [ ] Run full verification

**Timing**: 2 hours

**Files**:
- `Theories/Bimodal/FrameConditions/Completeness.lean` - MODIFIED
- `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotCompleteness.lean` - MODIFIED

**Verification**:
- `lake build` full project passes
- `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/Algebraic/*.lean` — verify empty for new files
- `grep -rn "^axiom " Theories/Bimodal/` — verify only `canonicalR_irreflexive`

---

## Testing & Validation

### For Lean Tasks (Required)
- [ ] `lake build` passes with no errors
- [ ] `grep -rn "\bsorry\b" <new files>` returns empty
- [ ] `grep -n "^axiom " <new files>` shows no new axioms
- [ ] All proofs verified with `lean_goal` showing "no goals"

### Mathematical Correctness Checklist
- [ ] TaskFrame properly separates W (CanonicalMCS) from D (TimelineQuot)
- [ ] WorldHistory maps D → W correctly
- [ ] Truth lemma handles Box via witnesses in W (not Range(h))
- [ ] Forward_F/backward_P use canonical witnesses from CanonicalMCS
- [ ] Modal saturation uses all MCSs available in W

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Algebraic/SeparatedTaskFrame.lean` - NEW
- `Theories/Bimodal/Metalogic/Algebraic/SeparatedHistory.lean` - NEW
- `Theories/Bimodal/Metalogic/Algebraic/SeparatedTruthLemma.lean` - NEW
- `Theories/Bimodal/FrameConditions/Completeness.lean` - MODIFIED
- `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotCompleteness.lean` - MODIFIED
- `specs/982_wire_dense_completeness_domain_connection/summaries/implementation-summary-{DATE}.md` - UPDATED

## Why This Approach is Correct

### The Semantics Enforces W/D Separation

TaskFrame explicitly has:
- `D` as type parameter (the duration domain)
- `WorldState` as field (the world state space)

These are intentionally separate. Previous approaches tried to use TimelineQuot for both, which forced witnesses to be in the domain of h.

### Modal Witnesses in W, Not Range(h)

The Box operator quantifies over histories σ ∈ Ω. Each history maps D → W. Different histories can pass through different MCSs at the same time t.

When Diamond(ψ) is true, there exists some history σ where ψ is true at t. The MCS σ.states(t) is in W (CanonicalMCS), not necessarily in the original history's range.

### Why This Avoids Edge Cases

The m > 2k edge case was:
- F(φ) in mcs(t) but no witness time s > t in TimelineQuot

With W/D separation:
- The witness for F(φ) is obtained via canonical_forward_F from CanonicalMCS
- The witness MCS exists in W
- It's placed at a time s > t via density of D
- The history through that MCS is in Ω

The witness MCS doesn't need to be "already in TimelineQuot" - it just needs to exist in CanonicalMCS.

**Progress:**

**Session: 2026-03-17, sess_1773756826_fa8a8c**
- Added: `SeparatedTaskFrame.lean` - TaskFrame with D = TimelineQuot, W = ParametricCanonicalWorldState
- Added: `SeparatedHistory.lean` - WorldHistory mapping TimelineQuot -> MCSs with shift-closed Omega
- Completed: Phase 1 (architecture verification), Phase 2 (TaskFrame), Phase 3 (WorldHistory)
- Blocked: Phase 4 - BFMCS coherence (forward_F/backward_P/modal_backward) not resolved by W/D separation
- Sorries: 0 added (existing sorries in ClosureSaturation.lean remain)
- Axioms: 0 added
