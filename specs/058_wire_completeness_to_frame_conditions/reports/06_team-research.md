# Team Research Report: Algebraic Perspective on Task Frame Completeness

**Task**: 58 - Wire completeness to FrameConditions
**Date**: 2026-03-25
**Mode**: Team Research (2 teammates)
**Session**: sess_1774460656_c52330
**Focus**: Three-place task relation vs two-place R_G; algebraic perspective on remaining gaps

---

## Summary

The user's concern about the construction being "too focused on a two-place relation between worlds" is addressed by a key clarification: **the Task Frame's `task_rel w d u` IS a two-place relation between worlds, parameterized by duration**. It is not a three-place relation R(t1, t2, w) in the interval-logic sense. The "three-place" appearance arises because WorldHistory encodes interval structure via `respects_task` at duration `d = t - s`.

The construction gap is precisely identified: a sorry-free `construct_bfmcs` is the sole missing piece. Strategy A (ultrafilter F-witness via filter extension) is unanimously recommended as the mathematically elegant, no-compromises path.

---

## Key Findings

### 1. The "Three-Place Relation" is a Misframing (Both Teammates Agree)

Both teammates independently confirmed: `task_rel : WorldState → D → WorldState → Prop` is **binary in world states, parameterized by duration**. The three arguments are (source_world, displacement, target_world) — fundamentally a groupoid action of (D, +, 0) on WorldState.

The paper's apparent R(t1, t2, w) structure is encoded in `WorldHistory.respects_task`:
```
For s ≤ t in domain: task_rel (states s) (t - s) (states t)
```

This collapses two time-points (s, t) into a single duration (t - s). The three-place perspective is a derived view, not the primitive structure.

### 2. Five Concrete Gaps Between R_G and task_rel (Teammate A)

| Gap | Description | Resolution |
|-----|-------------|------------|
| Type mismatch | R_G relates ultrafilters; task_rel relates world states | Bijection via mcsToUltrafilter (sorry-free) |
| Binary vs parameterized | R_G has no duration; task_rel parameterized by D | Sign-based dispatch: d>0 → ExistsTask, d=0 → =, d<0 → converse |
| Order-theoretic | R_G is preorder, not total order | FMCS threading onto Int supplies total order |
| Missing seriality | F-witness not free from R_G definition | Filter extension argument (new, ~100 LOC) |
| Duration information | ExistsTask loses specific duration | Acceptable for abstract completeness (only need existence) |

### 3. FrameConditions/Completeness.lean Status (Teammate B — Critical Finding)

Teammate B reports this file does NOT exist yet — the 3 sorries are in a file TO BE AUTHORED. All three theorems will call `parametric_algebraic_representation_conditional` (sorry-free), which requires a temporally coherent BFMCS as input. This simplifies the task: we're not fixing existing sorries, we're building the file fresh.

### 4. The Single Bottleneck: construct_bfmcs (Both Agree)

```
construct_bfmcs : MCS M → Σ' (B : BFMCS D) (h_tc : B.temporally_coherent) ...
```

The existing version in UltrafilterChain.lean:1853 is deprecated because:
```
construct_bfmcs → boxClassFamilies_temporally_coherent
    → SuccChainTemporalCoherent → f_nesting_is_bounded (MATHEMATICALLY FALSE)
```

`f_nesting_is_bounded` is false because {F^n(p) | n ∈ ℕ} is finitely consistent and extends to an MCS with unbounded F-nesting.

### 5. The Multi-Layer Algebraic Bridge (Teammate A)

The bridge from R_G to Task Frame passes through 5 layers:

```
Layer 1: Ultrafilter ↔ MCS          (bijection, sorry-free)
Layer 2: R_G temporal preorder       (sorry-free)
Layer 3: Succ relation → FMCS       (threading onto ℤ, needs F-witness)
Layer 4: WorldHistory from FMCS     (sorry-free: succ_chain_history)
Layer 5: Parametric canonical frame  (sorry-free: ParametricCanonicalTaskFrame)
```

The gap is at Layer 3: constructing the Int-indexed chain with temporal coherence.

### 6. Strategy A is the Elegant Path (Both Agree)

**The F-witness argument** (standard Jonsson-Tarski):
- F(psi) ∈ U means G(¬psi) ∉ U (ultrafilter consistency)
- Filter base B = {a | G(a) ∈ U} ∪ {psi} is proper (by contradiction via G-monotonicity + TA axiom)
- B extends to ultrafilter V with R_G(U, V) and psi ∈ V

**Why this avoids Strategy C's problems**:
- No seed consistency proofs needed (ultrafilters are already maximal)
- No f_nesting_is_bounded needed (filter extension handles each F-obligation individually)
- No boundary_resolution_set complexity
- Standard algebraic technique with clear correctness criteria

---

## Conflicts and Resolutions

### Conflict 1: Does FrameConditions/Completeness.lean Exist?

**Teammate A**: References the file as containing 3 sorries (from task description)
**Teammate B**: Reports the file does NOT exist yet; it's a target to be authored

**Resolution**: Teammate B's finding is more precise — they examined the actual filesystem. The task description's line numbers (108, 151, 170) refer to the PLANNED content, not existing code. This actually simplifies the task: we author the file fresh once construct_bfmcs is sorry-free.

### Conflict 2: LOC Estimates

**Teammate A**: ~500 LOC new code
**Teammate B**: ~600 LOC new code

**Resolution**: Minor discrepancy; ~500-600 LOC is a reasonable range for the ultrafilter chain construction.

---

## Synthesis: Why Strategy A is Mathematically Satisfying

The user asked for "a no-compromises solution that is mathematically elegant." Strategy A delivers because:

1. **It works at the right level of abstraction**: Ultrafilters on the Lindenbaum algebra are the natural "points" of the semantic space. The F-witness lemma is the natural completeness property of this space.

2. **It doesn't fight the type theory**: Strategy C requires proving that synthetic seed constructions don't create contradictions — essentially re-proving consistency at each extension step. Strategy A uses the ultrafilter extension theorem, which is a single, clean application of Zorn's lemma.

3. **Duration information is correctly handled**: The parametric_canonical_task_rel uses sign-based dispatch (d > 0 → ExistsTask, etc.). This is mathematically correct: for abstract completeness, we only need the EXISTENCE of a satisfying model, not a fully faithful duration encoding.

4. **The bridge layers compose cleanly**: Each layer (ultrafilter ↔ MCS → R_G → FMCS → WorldHistory → TaskFrame) has a sorry-free implementation. Only the F-witness step (Layer 3 entry) needs new code.

5. **It generalizes**: The same approach works for any STSA (Tense S5 Algebra), not just the Lindenbaum algebra of TM logic. This is the "correct" proof technique for this class of logics.

---

## Implementation Recommendations

### Phase 1: F-Witness Existence (~100 LOC)
File: `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean`

```lean
theorem ultrafilter_F_witness (U : Ultrafilter LindenbaumAlg) (psi : Formula)
    (h_F : ⟦Formula.some_future psi⟧ ∈ U.val) :
    ∃ V : Ultrafilter LindenbaumAlg, R_G U V ∧ ⟦psi⟧ ∈ V.val
```

### Phase 2: P-Witness via Sigma Duality (~50 LOC)
Use proven `sigma_quot` automorphism to derive backward witness.

### Phase 3: Ultrafilter Chain Construction (~150 LOC)
Build Int-indexed chain via iterated F/P-witness. Define `UltrafilterChain` structure.

### Phase 4: Convert to FMCS + BFMCS (~200 LOC)
Use `ultrafilterToMcs` to convert chain to FMCS. Prove temporal coherence. Assemble into BFMCS using existing `boxClassFamilies` infrastructure.

### Phase 5: Author FrameConditions/Completeness.lean (~100 LOC)
Create the file with `dense_completeness_fc`, `discrete_completeness_fc`, `completeness_over_Int` using `parametric_algebraic_representation_conditional`.

**Total**: ~600 LOC, 8 hours estimated

---

## Teammate Contributions

| Teammate | Focus | Status | Confidence | Key Contribution |
|----------|-------|--------|------------|------------------|
| A | Mathematical foundations | Completed | High | 5-gap analysis, groupoid action characterization, bridge layer decomposition |
| B | Codebase implementation | Completed | High | FrameConditions/Completeness.lean doesn't exist yet, sorry geography, parametric infrastructure confirmed sorry-free |

---

## References

### Teammate Reports
- `specs/058_wire_completeness_to_frame_conditions/reports/06_teammate-a-findings.md`
- `specs/058_wire_completeness_to_frame_conditions/reports/06_teammate-b-findings.md`

### Prior Research
- `specs/058_wire_completeness_to_frame_conditions/reports/05_elegant-approach-analysis.md` — Strategy A recommendation
- `specs/064_critical_path_review/reports/02_team-research.md` — Original strategy comparison

### Key Source Files
- `Theories/Bimodal/Semantics/TaskFrame.lean` — TaskFrame definition
- `Theories/Bimodal/Semantics/WorldHistory.lean` — WorldHistory with respects_task
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` — R_G, construct_bfmcs (deprecated)
- `Theories/Bimodal/Metalogic/Algebraic/ParametricRepresentation.lean` — Sorry-free representation theorem
