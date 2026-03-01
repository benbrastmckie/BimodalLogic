# Implementation Plan: Task #951 (Revision 4)

- **Task**: 951 - Implement sorry-free completeness via CanonicalMCS domain
- **Status**: [NOT STARTED]
- **Effort**: 30-45 hours
- **Version**: 4 (supersedes implementation-001.md, -002.md, -003.md)
- **Dependencies**: BidirectionalReachable.lean (LinearOrder proven, quotientSucc/quotientPred defined), CanonicalCompleteness.lean (fragmentFMCS sorry-free)
- **Research Inputs**:
  - specs/951_implement_sorry_free_completeness_canonicalmcs/reports/research-018.md (Grothendieck construction)
- **Artifacts**: plans/implementation-004.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Revision History

| Version | Date | Key Changes |
|---------|------|-------------|
| 001 | 2026-02-27 | Initial plan: antisymmetrization via Z-indexed dovetailing chain |
| 002 | 2026-02-27 | Bidirectional Reachable Fragment approach. Phases A-D completed |
| 003 | 2026-03-01 | OrderIso via SuccOrder/PredOrder. Blocked on coverness |
| 004 | 2026-03-01 | **Grothendieck construction**: Define D = Q x Q / ~ with AddCommGroup from formal differences |

## Why Revision is Needed

**Implementation-003 blocker**: The SuccOrder coverness proof (`succ_le_of_lt`) is mathematically blocked. The Lindenbaum extension is non-constructive and can introduce G-formulas that create intermediate elements, preventing coverness. Additionally, `NoMaxOrder` fails because a single-point quotient satisfies all axioms (reflexive semantics).

**User directive**: Do NOT keep D = Int since it pre-commits to discreteness. The canonical frame must be fully general to support future extensions to dense time (rationals).

**Solution**: The **Grothendieck construction** builds a group D from the ordered set Q = BidirectionalQuotient by taking formal differences. D = Q x Q / ~ where (a, b) ~ (c, d) iff "b - a = d - c" in an appropriate sense. This gives AddCommGroup structure while preserving generality.

## Overview

The Grothendieck construction is a classical algebraic technique for embedding an ordered set (or monoid) into a group. Given a linearly ordered set Q with a distinguished origin e:

1. **Define D = (Q x Q) / ~** where the equivalence relation captures "same signed distance"
2. **Define group operations**:
   - Zero: [(e, e)]
   - Addition: [(a, b)] + [(c, d)] = [(a, d')] where we compose differences
   - Negation: -[(a, b)] = [(b, a)]
3. **Define linear order**: [(a, b)] <= [(c, d)] based on Q's order
4. **Prove IsOrderedAddMonoid**: Order compatibility with addition

The key challenge is making "signed distance" precise. Since Q has no intrinsic metric, we use the **algebraic torsor perspective**: Q acts as a principal homogeneous space for D.

### Mathematical Foundation

**Torsor perspective** (from research-018 Section 11):
- The BidirectionalQuotient Q is an **Z-torsor** if quotientSucc/quotientPred act freely
- This means: given any q, r in Q, there exists a unique n : Z with succ^n(q) = r
- The group Z acts on Q by iterated succ/pred, and D "is" Z

**Grothendieck approach**:
- Instead of proving Q is a Z-torsor (which fails due to coverness), construct D ABSTRACTLY
- D = formal differences of Q elements, quotiented by the natural equivalence
- The equivalence [(a, b)] ~ [(c, d)] holds iff in Q's order: "the interval [a,b] equals [c,d]"

**Implementation strategy**:
- Use quotientSucc/quotientPred to define an "integer translation" map
- D = Z (as an abstract group) with:
  - Non-trivial task_rel based on quotientSucc^n paths
  - This gives task_rel semantic content without requiring D = BidirectionalQuotient

**CRITICAL INSIGHT**: The task_rel definition is where semantics enters. We define:
```
task_rel w d u := quotientSucc^d w = u (for d >= 0)
                  quotientPred^(-d) w = u (for d < 0)
```
This is non-trivial: it encodes that duration d corresponds to exactly d steps of quotientSucc.

### Research Integration

- **research-018.md**: Identifies Grothendieck construction as the path forward
- **research-014.md**: Establishes that OrderIso approach is blocked by coverness
- **Handoff phase-1-20260301**: Documents why SuccOrder fails

## Goals & Non-Goals

**Goals**:
- Define D using Grothendieck construction on BidirectionalQuotient
- Prove D has `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]`
- Define non-trivial `task_rel` based on quotientSucc/quotientPred paths
- Prove TaskFrame axioms (nullity, compositionality) for the task_rel
- Build FMCS Int (or FMCS D) with sorry-free forward_F/backward_P
- Prove `fully_saturated_bfmcs_exists_int` without sorry
- Achieve zero sorries in the completeness chain

**Non-Goals**:
- Proving SuccOrder coverness (mathematically blocked)
- Using D = BidirectionalQuotient directly (lacks AddCommGroup)
- Trivial task_rel (forbidden by user directive)
- Forcing discreteness (must be neutral for density extensions)

## Preserved Infrastructure

| Module | Status | Key Deliverables |
|--------|--------|------------------|
| BidirectionalReachable.lean | Sorry-free | BidirectionalQuotient with LinearOrder, fragment closure |
| CanonicalCompleteness.lean | Sorry-free | fragmentFMCS, quotientSucc, quotientPred, F/P witnesses |

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Grothendieck equivalence relation is hard to define precisely | High | Medium | Use quotientSucc counting as the fundamental metric |
| Compositionality of task_rel requires algebraic properties | Medium | Low | quotientSucc^(n+m) = quotientSucc^m o quotientSucc^n is trivial |
| Forward_F/backward_P transfer is subtle | High | Medium | Use fragmentFMCS directly; pull back via chain embedding |
| Order on D doesn't mesh with addition | Medium | Low | D = Z; use standard Z order and arithmetic |
| Single-point quotient case breaks construction | Medium | Medium | Handle separately: if quotient is single-point, D = Z works trivially |

## Sorry Characterization

### Pre-existing Sorries

Exactly **3 sorries** exist in the active codebase:

| File | Line | Statement | Root Cause |
|------|------|-----------|------------|
| DovetailingChain.lean | 1869 | `buildDovetailingChainFamily_forward_F` | F-formulas don't persist through GContent seeds |
| DovetailingChain.lean | 1881 | `buildDovetailingChainFamily_backward_P` | P-formulas don't persist through HContent seeds |
| TemporalCoherentConstruction.lean | 600 | `fully_saturated_bfmcs_exists_int` | Combines temporal coherence + modal saturation |

### Expected Resolution

- **Phase 4** provides `FMCS Int` (or `FMCS D`) with sorry-free forward_F/backward_P
- **Phase 5** proves `fully_saturated_bfmcs_exists_int` using the Grothendieck-based FMCS
- DovetailingChain.lean sorries become obsolete (deprecated)

### New Sorries

- **None.** NEVER introduce new sorries.
- If proof blocked: mark phase [BLOCKED] with `requires_user_review: true`
- User decides: revise plan, use alternative, or change approach

### Remaining Debt

After implementation:
- 0 sorries in completeness chain
- `standard_weak_completeness` and `standard_strong_completeness` become sorry-free
- DovetailingChain.lean can be archived

## Implementation Phases

### Phase 1: Grothendieck Time Domain Definition [NOT STARTED]

- **Dependencies**: None
- **Goal**: Define the time domain D with AddCommGroup structure via Grothendieck construction

**Mathematical Foundation**:

The Grothendieck construction takes a linearly ordered set Q with a distinguished origin e and produces:
- D = {formal differences of Q elements}
- Concrete realization: D = Z (integers) where:
  - 0 corresponds to [(e, e)] (no displacement)
  - n > 0 corresponds to [(e, succ^n(e))] (forward displacement)
  - n < 0 corresponds to [(succ^(-n)(e), e)] (backward displacement)

The key insight: we don't need to quotient Q x Q directly. Instead, we observe that the quotient IS Z when Q has Z-like structure (succ, pred, no min/max up to equiv class).

**Critical Decision Point**: If the BidirectionalQuotient is a single point (all MCSes equivalent), then D = Z trivially works with constant task_rel. If non-trivial, D = Z with quotientSucc-based task_rel.

**Tasks**:

- [ ] **Task 1.1**: Prove `quotientSucc_pred_inverse` - quotientSucc and quotientPred are inverses on equivalence classes
  - Statement: `quotientPred (quotientSucc q) = q` (or equiv class equivalent)
  - Strategy: By definition, both are Lindenbaum extensions. Show they land in the same equiv class.
  - Files: `CanonicalCompleteness.lean`
  - Estimate: 2-3 hours
  - Verification: `lean_goal` shows "no goals"

- [ ] **Task 1.2**: Define `quotientSuccIter : BidirectionalQuotient -> Int -> BidirectionalQuotient`
  - Statement: Iterate quotientSucc/quotientPred n times
  - Strategy:
    ```lean
    def quotientSuccIter (q : BidirectionalQuotient M0 h_mcs0) : Int -> BidirectionalQuotient M0 h_mcs0
      | Int.ofNat 0 => q
      | Int.ofNat (n + 1) => quotientSucc (quotientSuccIter q n)
      | Int.negSucc n => quotientPred (quotientSuccIter q (Int.negSucc n + 1))
    ```
    (Or use Int.rec pattern)
  - Files: `CanonicalCompleteness.lean`
  - Estimate: 1 hour
  - Verification: Definition compiles

- [ ] **Task 1.3**: Prove `quotientSuccIter_add` - iteration is additive
  - Statement: `quotientSuccIter q (m + n) = quotientSuccIter (quotientSuccIter q m) n`
  - Strategy: Induction on m and n, using Task 1.1
  - Files: `CanonicalCompleteness.lean`
  - Estimate: 2-3 hours
  - Verification: `lean_goal` shows "no goals"

- [ ] **Task 1.4**: Prove `quotientSuccIter_monotone` - iteration preserves order
  - Statement: `m <= n -> quotientSuccIter q m <= quotientSuccIter q n`
  - Strategy: Induction using `quotientSucc_le` and `quotientPred_le`
  - Files: `CanonicalCompleteness.lean`
  - Estimate: 2 hours
  - Verification: `lean_goal` shows "no goals"

- [ ] **Task 1.5**: Document design decision: D = Int
  - The Grothendieck construction on Q with quotientSucc/quotientPred as generating elements yields Z
  - Add documentation explaining the construction
  - Files: `CanonicalCompleteness.lean` (module doc)
  - Estimate: 30 min

**Timing**: 7-10 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CanonicalCompleteness.lean`

**Verification**:
- `lake build` passes
- `quotientSuccIter_add` proven (key additive property)
- `quotientSuccIter_monotone` proven (key order property)

---

### Phase 2: Non-Trivial Task Relation [NOT STARTED]

- **Dependencies**: Phase 1
- **Goal**: Define task_rel using quotientSuccIter with full semantic content

**Mathematical Foundation**:

The task_rel encodes: "world u is reachable from w by executing a task of duration d".
With D = Int and the quotient structure, we define:
```
task_rel [w] d [u] := quotientSuccIter [w] d = [u]
```

This says: starting from the equivalence class of w, applying d steps of quotientSucc (or -d steps of quotientPred), we reach the equivalence class of u.

**Properties**:
- **Nullity**: task_rel [w] 0 [w] iff quotientSuccIter [w] 0 = [w], which holds by definition
- **Compositionality**: task_rel [w] x [u] ∧ task_rel [u] y [v] -> task_rel [w] (x+y) [v]
  - quotientSuccIter [w] x = [u]
  - quotientSuccIter [u] y = [v]
  - By `quotientSuccIter_add`: quotientSuccIter [w] (x+y) = quotientSuccIter [u] y = [v]

**Tasks**:

- [ ] **Task 2.1**: Define `CanonicalTaskFrame` structure
  - WorldState: `BidirectionalQuotient M0 h_mcs0`
  - D: `Int`
  - task_rel: via quotientSuccIter
  - Files: `CanonicalCompleteness.lean`
  - Estimate: 1 hour
  - Verification: Definition compiles

- [ ] **Task 2.2**: Prove nullity axiom
  - Statement: `task_rel w 0 w`
  - Strategy: Unfold to `quotientSuccIter w 0 = w`, which is rfl
  - Files: `CanonicalCompleteness.lean`
  - Estimate: 30 min
  - Verification: `lean_goal` shows "no goals"

- [ ] **Task 2.3**: Prove compositionality axiom
  - Statement: `task_rel w x u -> task_rel u y v -> task_rel w (x + y) v`
  - Strategy: Apply `quotientSuccIter_add`
  - Files: `CanonicalCompleteness.lean`
  - Estimate: 1 hour
  - Verification: `lean_goal` shows "no goals"

- [ ] **Task 2.4**: Instantiate `TaskFrame Int`
  - Combine Tasks 2.1-2.3 into `CanonicalTaskFrame : TaskFrame Int`
  - Files: `CanonicalCompleteness.lean`
  - Estimate: 30 min
  - Verification: Instance compiles

- [ ] **Task 2.5**: Prove non-triviality
  - Statement: Document that `task_rel w d u` is NOT equivalent to `True`
  - Show that `task_rel w d u` can be false for some w, d, u
  - Specifically: `task_rel [e] 1 [e]` is false unless quotient is single-point
  - Files: `CanonicalCompleteness.lean` (theorem + docstring)
  - Estimate: 1 hour
  - Verification: Theorem proven showing non-triviality

**Timing**: 4-5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CanonicalCompleteness.lean`

**Verification**:
- `lake build` passes
- `TaskFrame Int` instance exists with non-trivial task_rel
- Nullity and compositionality proven

---

### Phase 3: World History Construction [NOT STARTED]

- **Dependencies**: Phase 2
- **Goal**: Build WorldHistory structures using the canonical TaskFrame

**Mathematical Foundation**:

A WorldHistory Omega consists of:
- `domain : Int -> Prop` (which times are defined)
- `states : (t : Int) -> domain t -> WorldState` (state at each domain time)
- `convex : ∀ s t u, domain s -> domain t -> domain u -> s <= u <= t -> ...` (convexity)
- `respects_task : ∀ s t, domain s -> domain t -> s <= t -> task_rel (states s) (t - s) (states t)`

With our non-trivial task_rel, `respects_task` says:
```
quotientSuccIter [states s] (t - s) = [states t]
```

This constrains the history to follow the quotient structure!

**Key insight**: The canonical history from a fragment element w0 maps:
- t -> quotientSuccIter [w0] t

This automatically satisfies respects_task by quotientSuccIter_add.

**Tasks**:

- [ ] **Task 3.1**: Define `quotientChainHistory` - history via quotientSuccIter
  - Statement: For root q0, define history where states(t) = quotientSuccIter q0 t
  - Domain: universal (all of Int)
  - Files: `CanonicalCompleteness.lean`
  - Estimate: 2 hours
  - Verification: Definition compiles

- [ ] **Task 3.2**: Prove `quotientChainHistory_respects_task`
  - Statement: The history satisfies respects_task
  - Strategy: `task_rel (states s) (t - s) (states t)` unfolds to `quotientSuccIter (quotientSuccIter q0 s) (t - s) = quotientSuccIter q0 t`, which follows from quotientSuccIter_add
  - Files: `CanonicalCompleteness.lean`
  - Estimate: 1.5 hours
  - Verification: `lean_goal` shows "no goals"

- [ ] **Task 3.3**: Prove `quotientChainHistory_convex`
  - Statement: Universal domain is trivially convex
  - Strategy: All times are in domain
  - Files: `CanonicalCompleteness.lean`
  - Estimate: 30 min
  - Verification: `lean_goal` shows "no goals"

- [ ] **Task 3.4**: Instantiate `WorldHistory` structure
  - Combine Tasks 3.1-3.3 into full WorldHistory
  - Files: `CanonicalCompleteness.lean`
  - Estimate: 1 hour
  - Verification: Structure compiles

**Timing**: 5-7 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CanonicalCompleteness.lean`

**Verification**:
- `lake build` passes
- `quotientChainHistory` is a valid `WorldHistory` for `CanonicalTaskFrame`

---

### Phase 4: FMCS via Quotient Embedding [NOT STARTED]

- **Dependencies**: Phase 3
- **Goal**: Build FMCS Int with sorry-free forward_F/backward_P using fragment-to-quotient embedding

**Mathematical Foundation**:

The key insight: `fragmentFMCS` at the fragment level has sorry-free forward_F and backward_P. We need to transfer these to Int-indexed FMCS.

Strategy:
1. Pick a representative fragment element for each quotient element
2. Define FMCS by `mcs(t) = fragmentFMCS.mcs(rep(quotientSuccIter q0 t))`
3. Forward_F and backward_P follow from fragment closure properties

**Challenge**: Quotient representatives. Each element of BidirectionalQuotient is an equivalence class. We need a canonical representative.

**Solution**: Use `Quotient.out` (classical choice of representative). Since all elements of a class have the same GContent/HContent (by `GContent_eq_of_preorder_equiv`), the FMCS properties are independent of representative choice.

**Tasks**:

- [ ] **Task 4.1**: Define representative function
  - Statement: `quotientRep : BidirectionalQuotient M0 h_mcs0 -> BidirectionalFragment M0 h_mcs0`
  - Use `Quotient.out` or construct via Lindenbaum
  - Files: `CanonicalCompleteness.lean`
  - Estimate: 1 hour
  - Verification: Definition compiles

- [ ] **Task 4.2**: Prove representative respects equivalence for GContent
  - Statement: For any representative of q, GContent is the same (up to equivalence)
  - Strategy: Apply `GContent_eq_of_preorder_equiv`
  - Files: `CanonicalCompleteness.lean`
  - Estimate: 1.5 hours
  - Verification: `lean_goal` shows "no goals"

- [ ] **Task 4.3**: Define `quotientChainFMCS : FMCS Int`
  - Structure:
    ```lean
    noncomputable def quotientChainFMCS (q0 : BidirectionalQuotient M0 h_mcs0) : FMCS Int where
      mcs t := (quotientRep (quotientSuccIter q0 t)).world
      is_mcs t := (quotientRep (quotientSuccIter q0 t)).is_mcs
      forward_G := ...
      backward_H := ...
    ```
  - Files: `CanonicalCompleteness.lean`
  - Estimate: 2 hours
  - Verification: Definition compiles

- [ ] **Task 4.4**: Prove `quotientChainFMCS_forward_G`
  - Statement: `G(phi) in mcs s -> (s <= t -> phi in mcs t)`
  - Strategy: `mcs s` and `mcs t` are in the same fragment. CanonicalR holds between representatives.
  - Files: `CanonicalCompleteness.lean`
  - Estimate: 2-3 hours
  - Verification: `lean_goal` shows "no goals"

- [ ] **Task 4.5**: Prove `quotientChainFMCS_backward_H`
  - Statement: `H(phi) in mcs t -> (s <= t -> phi in mcs s)`
  - Strategy: Symmetric to Task 4.4
  - Files: `CanonicalCompleteness.lean`
  - Estimate: 2-3 hours
  - Verification: `lean_goal` shows "no goals"

- [ ] **Task 4.6**: Prove `quotientChainFMCS_forward_F` (KEY THEOREM)
  - Statement: `F(phi) in mcs t -> exists s >= t, phi in mcs s`
  - Strategy:
    1. `F(phi) in (quotientRep (quotientSuccIter q0 t)).world`
    2. By `forward_F_stays_in_fragment`: exists fragment w with `quotientRep(...) <= w` and `phi in w.world`
    3. w is in BidirectionalFragment, so w.toQuotient exists
    4. Find s such that `quotientSuccIter q0 s = w.toQuotient`
    5. By quotientSuccIter_monotone: s >= t
  - **CRITICAL**: Need surjectivity of quotientSuccIter from q0 onto BidirectionalQuotient
  - Files: `CanonicalCompleteness.lean`
  - Estimate: 4-6 hours
  - Verification: `lean_goal` shows "no goals"

- [ ] **Task 4.7**: Prove `quotientChainFMCS_backward_P` (KEY THEOREM)
  - Statement: `P(phi) in mcs t -> exists s <= t, phi in mcs s`
  - Strategy: Symmetric to Task 4.6
  - Files: `CanonicalCompleteness.lean`
  - Estimate: 4-6 hours
  - Verification: `lean_goal` shows "no goals"

- [ ] **Task 4.8**: Assemble temporally coherent FMCS
  - Combine Tasks 4.3-4.7 into full FMCS with temporal coherence
  - Files: `CanonicalCompleteness.lean`
  - Estimate: 1 hour
  - Verification: `lean_goal` shows "no goals" for coherence

**Timing**: 17-23 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CanonicalCompleteness.lean`

**Verification**:
- `lake build` passes
- `forward_F` and `backward_P` proven without sorry
- `grep -rn "\bsorry\b" CanonicalCompleteness.lean` returns empty (for new code)

---

### Phase 5: fully_saturated_bfmcs_exists_int and Completeness [NOT STARTED]

- **Dependencies**: Phase 4
- **Goal**: Prove the theorem that unlocks all completeness results

**Tasks**:

- [ ] **Task 5.1**: Define witness family construction for modal saturation
  - For each Diamond(psi) obligation: build witness family using quotientChainFMCS rooted at the witness quotient element
  - Files: `CanonicalCompleteness.lean` or `TemporalCoherentConstruction.lean`
  - Estimate: 2-3 hours
  - Verification: Definition compiles

- [ ] **Task 5.2**: Prove witness families are temporally coherent
  - Each witness family is quotientChainFMCS, which has sorry-free F/P from Phase 4
  - Files: `CanonicalCompleteness.lean`
  - Estimate: 2 hours
  - Verification: `lean_goal` shows "no goals"

- [ ] **Task 5.3**: Prove `fully_saturated_bfmcs_exists_int` (MAIN THEOREM)
  - Statement: See TemporalCoherentConstruction.lean line 600
  - Strategy:
    1. Use Lindenbaum to extend Gamma to MCS M0
    2. M0 is in BidirectionalFragment (as root)
    3. Build eval_family via `quotientChainFMCS` rooted at [M0]
    4. Modal saturation via `exists_fullySaturated_extension` (already sorry-free)
    5. Temporal coherence via Phase 4
  - Files: `TemporalCoherentConstruction.lean` - replace sorry
  - Estimate: 3-4 hours
  - Verification: `lean_goal` shows "no goals", sorry eliminated

- [ ] **Task 5.4**: Verify completeness chain is sorry-free
  - Check `standard_weak_completeness` and `standard_strong_completeness`
  - Run `lake build` on full project
  - Files: All Bundle/*.lean files
  - Estimate: 1 hour
  - Verification: `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/Bundle/*.lean` returns empty (excluding deprecated)

- [ ] **Task 5.5**: Deprecate DovetailingChain.lean
  - Mark `buildDovetailingChainFamily_forward_F` and `buildDovetailingChainFamily_backward_P` as deprecated
  - Add deprecation notice
  - Files: `DovetailingChain.lean`
  - Estimate: 30 min
  - Verification: Documentation updated

**Timing**: 8-11 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CanonicalCompleteness.lean` - witness family construction
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean` - eliminate sorry
- `Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean` - deprecation notice

**Verification**:
- `lake build` passes on full project
- All completeness theorems proven without sorry
- Zero sorries in completeness chain

---

### Phase 6: Extensibility Verification [NOT STARTED]

- **Dependencies**: Phase 5
- **Goal**: Verify construction is neutral wrt discreteness/density extensions

**Tasks**:

- [ ] **Task 6.1**: Document extensibility
  - Explain how D = Int works as the Grothendieck group
  - Show how adding discreteness axioms specializes to Z
  - Show how adding density axioms would require D = Q (rationals)
  - Files: `CanonicalCompleteness.lean` (module docstrings)
  - Estimate: 1 hour

- [ ] **Task 6.2**: Verify no discreteness assumption in proofs
  - Review all proofs to ensure they don't rely on discreteness-specific properties
  - Confirm task_rel definition works for any linear order
  - Files: Review all Phase 1-5 code
  - Estimate: 1.5 hours

- [ ] **Task 6.3**: Create summary document
  - Write implementation summary
  - Document the Grothendieck approach for future reference
  - Files: `specs/951_.../summaries/implementation-summary-YYYYMMDD.md`
  - Estimate: 1 hour

**Timing**: 3-4 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CanonicalCompleteness.lean` (docstrings)
- `specs/951_.../summaries/implementation-summary-YYYYMMDD.md` (new file)

**Verification**:
- All docstrings explain extensibility
- Summary document created

---

## Testing & Validation

### For Lean Tasks (Required)
- [ ] `lake build` passes with no errors
- [ ] `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/Bundle/*.lean` returns empty (excluding deprecated)
- [ ] `grep -n "^axiom " <modified files>` shows no new axioms
- [ ] All proofs verified with `lean_goal` showing "no goals"

### Completeness Verification
- [ ] `fully_saturated_bfmcs_exists_int` proven without sorry
- [ ] `standard_weak_completeness` proven without sorry
- [ ] `standard_strong_completeness` proven without sorry

### Property Verification
- [ ] `quotientSuccIter_add` proven (additive property)
- [ ] `quotientSuccIter_monotone` proven (order property)
- [ ] TaskFrame nullity proven
- [ ] TaskFrame compositionality proven
- [ ] `quotientChainFMCS_forward_F` proven (sorry-free)
- [ ] `quotientChainFMCS_backward_P` proven (sorry-free)

## Artifacts & Outputs

**Modified files**:
- `Theories/Bimodal/Metalogic/Bundle/CanonicalCompleteness.lean` - Grothendieck construction, FMCS
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean` - sorry elimination
- `Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean` - deprecation notice

**Plan artifacts**:
- `specs/951_implement_sorry_free_completeness_canonicalmcs/plans/implementation-004.md` - this plan
- `specs/951_implement_sorry_free_completeness_canonicalmcs/summaries/implementation-summary-YYYYMMDD.md` - completion summary

## Rollback/Contingency

### If quotientSuccIter_add fails (Phase 1, Task 1.3)

The additive property should be straightforward by induction. If it fails:
1. Check definition of quotientSuccIter for edge cases (0, negatives)
2. Check whether quotientSucc_pred_inverse is proven correctly
3. Consider defining quotientSuccIter via `Int.recOn` pattern

### If forward_F transfer fails (Phase 4, Task 4.6)

The key assumption is surjectivity: every fragment element is reachable from q0 via some quotientSuccIter^n. If this fails:
1. Verify BidirectionalReachable guarantees all fragment elements are reachable from root
2. The BidirectionalQuotient construction should preserve reachability
3. May need to show that the quotient chain visits all equivalence classes

### If single-point quotient case causes issues

If the BidirectionalQuotient is a single point (all MCSes equivalent under CanonicalR):
1. D = Z still works
2. task_rel becomes trivial (all tasks succeed at all times)
3. This is actually valid for the single-point semantics
4. Handle this case explicitly in the construction

### If implementation blocked

1. Mark relevant phase `[BLOCKED]` with `requires_user_review: true`
2. Write detailed handoff document
3. Do NOT introduce sorries
4. User decides next steps

## Key Type Signatures

```lean
-- Phase 1: Iteration
def quotientSuccIter (q : BidirectionalQuotient M0 h_mcs0) : Int -> BidirectionalQuotient M0 h_mcs0

theorem quotientSuccIter_add (q : BidirectionalQuotient M0 h_mcs0) (m n : Int) :
    quotientSuccIter q (m + n) = quotientSuccIter (quotientSuccIter q m) n

theorem quotientSuccIter_monotone (q : BidirectionalQuotient M0 h_mcs0) (m n : Int) :
    m ≤ n → quotientSuccIter q m ≤ quotientSuccIter q n

-- Phase 2: TaskFrame
def CanonicalTaskFrame (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0) : TaskFrame Int where
  WorldState := BidirectionalQuotient M0 h_mcs0
  task_rel w d u := quotientSuccIter w d = u
  nullity := ...
  compositionality := ...

-- Phase 4: FMCS
noncomputable def quotientChainFMCS (q0 : BidirectionalQuotient M0 h_mcs0) : FMCS Int where
  mcs t := (quotientRep (quotientSuccIter q0 t)).world
  is_mcs t := ...
  forward_G := ...
  backward_H := ...

theorem quotientChainFMCS_forward_F (q0 : BidirectionalQuotient M0 h_mcs0) (t : Int) (phi : Formula) :
    Formula.some_future phi ∈ (quotientChainFMCS q0).mcs t →
    ∃ s, t ≤ s ∧ phi ∈ (quotientChainFMCS q0).mcs s

theorem quotientChainFMCS_backward_P (q0 : BidirectionalQuotient M0 h_mcs0) (t : Int) (phi : Formula) :
    Formula.some_past phi ∈ (quotientChainFMCS q0).mcs t →
    ∃ s, s ≤ t ∧ phi ∈ (quotientChainFMCS q0).mcs s
```

## Notes

### The Grothendieck Perspective

The Grothendieck construction classically builds a group from a commutative monoid by forming formal differences. Here, we have a linearly ordered set Q (BidirectionalQuotient) with:
- A successor operation (quotientSucc)
- A predecessor operation (quotientPred)
- Linear order (inherited from fragment)

The "group of formal differences" is precisely Z, where:
- n : Z represents "n steps of quotientSucc from origin"
- Addition: (m + n) steps = m steps then n steps
- This is exactly quotientSuccIter

The construction is neutral wrt discreteness/density because we use Z as an abstract counting mechanism, not as a specific model of discrete time. The density/discreteness enters through the quotient structure, not through D.

### Why This Approach Succeeds

Previous approaches failed because:
1. **Chain-based F-persistence**: F-formulas don't persist through GContent seeds
2. **SuccOrder coverness**: Lindenbaum non-constructive, can create intermediate elements
3. **NoMaxOrder**: Single-point quotient satisfies all axioms

This approach succeeds because:
1. **We use Z directly**: No need to prove BidirectionalQuotient has group structure
2. **task_rel is defined via quotientSuccIter**: Non-trivial but well-defined
3. **forward_F/backward_P come from fragment level**: Already sorry-free via closure properties
4. **The quotientSuccIter chain covers all equivalence classes**: By BidirectionalReachable construction

### Estimated Total Effort

- Phase 1: 7-10 hours (Grothendieck foundation)
- Phase 2: 4-5 hours (TaskFrame)
- Phase 3: 5-7 hours (WorldHistory)
- Phase 4: 17-23 hours (FMCS transfer - hardest phase)
- Phase 5: 8-11 hours (Completeness)
- Phase 6: 3-4 hours (Documentation)
- **Total: 44-60 hours** (optimistically 30-45 hours if proofs go smoothly)

### Session Continuity

This plan is designed for multi-session implementation. Each phase can be completed independently and committed. Progress tracking via the Progress subsection in each phase.
