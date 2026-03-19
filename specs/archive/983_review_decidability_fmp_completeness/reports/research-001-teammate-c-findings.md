# Gap Analysis: Decidability and FMP for Publication

**Task**: 983 - Review decidability results and FMP for publication
**Analyst**: Teammate C (Gap Analysis)
**Date**: 2026-03-16
**Confidence Level**: HIGH (based on comprehensive codebase analysis)

## Executive Summary

The ProofChecker codebase has **strong decidability infrastructure** (sorry-free tableau procedure) but **significant gaps in FMP formalization**. For publication-quality decidability results alongside soundness and completeness:

1. **Decidability soundness**: PROVEN (sorry-free)
2. **Decidability completeness**: INCOMPLETE (requires FMP)
3. **Finite Model Property**: STATED BUT NOT PROVEN (critical gap)
4. **Dense completeness wiring**: 3 sorries in domain connection

## Gap Analysis

### Gap 1: FMP Not Proven (CRITICAL)

**What Exists**:
- `finite_model_property` theorem STATED in documentation
- Subformula closure machinery (`Syntax/SubformulaClosure.lean`)
- Signed formula types (`Decidability/SignedFormula.lean`)
- Finite world state concept mentioned in typst documentation

**What's Missing**:
- **No proven FMP theorem**: The statement "if satisfiable, satisfiable in a finite model bounded by 2^|closure(phi)|" is documented but NOT formalized
- **No filtration construction**: Standard technique for FMP not implemented
- **No finite model bound proof**: No Lean theorem establishing model size bounds
- **FMP archived to Boneyard**: The `FMP/` directory was archived (Task 948) due to non-standard validity definitions (`fmp_valid` != `valid`)

**Impact**: Decidability completeness cannot be proven without FMP. The tableau procedure returns "valid" or "invalid" but completeness (invalid => satisfiable) requires FMP.

**Severity**: CRITICAL for publication

---

### Gap 2: Decidability Completeness Not Proven

**What Exists**:
- `decide` function (sorry-free)
- `decide_sound` theorem: "if returns valid, formula is valid" (PROVEN)
- Countermodel extraction from open branches
- Tableau termination via fuel-based saturation

**What's Missing**:
- `decide_complete`: "if formula is satisfiable, returns invalid" (NOT PROVEN)
- Connection between open saturated branch and actual model existence
- Proof that saturation implies all relevant formulas explored

**Dependencies**: FMP (Gap 1)

**Severity**: HIGH - cannot claim full decidability without this

---

### Gap 3: Dense Completeness Wiring (3 Sorries)

**What Exists**:
- `dense_completeness_components_proven`: All individual components sorry-free
  - `cantor_iso`: TimelineQuot ≃o Q (PROVEN)
  - `bmcs_truth_lemma`: MCS membership <-> semantic truth (PROVEN)
  - `temporal_coherent_family_exists_CanonicalMCS` (PROVEN)

**What's Missing**:
- **Domain mismatch**: BFMCS uses `D = CanonicalMCS`, TaskFrame uses `D = TimelineQuot`
- 3 sorries in `FrameConditions/Completeness.lean` for final wiring
- No transfer theorem connecting the two domains

**Impact**: Dense completeness is "morally proven" but not formally connected

**Severity**: MEDIUM - doesn't block decidability, affects completeness claim

---

### Gap 4: Discrete Completeness Has Axiom Debt

**What Exists**:
- `discrete_Icc_finite_axiom`: Technical debt axiom from Task 979
- Task 981 in progress to remove this via blocking formula seed approach
- SuccOrder/PredOrder from discreteness axiom (partial)

**What's Missing**:
- Covering lemma proof
- Axiom-free interval finiteness
- LocallyFiniteOrder derivation from DF axiom

**Impact**: Publication using discrete completeness requires disclosing axiom

**Severity**: MEDIUM (Task 981 actively addressing)

---

### Gap 5: No Complexity Analysis

**What Exists**:
- Documentation claims PSPACE-completeness
- Time complexity stated as O(2^n)
- Space complexity stated as O(n)

**What's Missing**:
- No Lean formalization of complexity bounds
- No proof that tableau procedure runs in polynomial space
- No PSPACE-completeness proof

**Severity**: LOW for initial publication (can cite literature)

---

## Recommended Methods to Fill Gaps

### Method 1: Filtration for FMP (RECOMMENDED)

**Technique**: Filtration constructs finite models by quotienting infinite canonical models by subformula equivalence.

**Why Suitable**:
- Standard technique for S5 + temporal logics
- Works well with existing MCS infrastructure
- Natural fit for closure-based approach already in codebase

**Implementation Outline**:
1. Define filtration equivalence: `w ~ v` iff `forall psi in closure(phi), w |= psi <-> v |= psi`
2. Prove equivalence classes bounded by `2^|closure(phi)|`
3. Define filtered accessibility relations preserving truth
4. Prove truth preservation lemma for filtration
5. Conclude: satisfiable in canonical => satisfiable in filtered model

**Estimated Effort**: 15-25 hours

**References**: Blackburn et al. "Modal Logic" Ch. 2.3, Gabbay "Temporal Logic" Ch. 5

---

### Method 2: Mosaic Method (ALTERNATIVE)

**Technique**: Build finite models from "mosaics" (local descriptions of possible worlds and their relations).

**Why Consider**:
- Provides decidability + FMP simultaneously
- Works well for combining modal + temporal
- More direct than filtration for bimodal logics

**Drawbacks**:
- Larger implementation effort
- Less standard for this logic class
- Would require significant new infrastructure

**Estimated Effort**: 30-50 hours

**References**: Marx "Mosaics for description logics"

---

### Method 3: Direct Finite Depth Construction

**Technique**: Construct finite models directly by limiting temporal depth.

**Why Consider**:
- Modal depth bounds enable direct construction
- Natural for tableau-based approach
- Could integrate with existing decidability infrastructure

**Drawbacks**:
- Requires careful temporal depth tracking
- May complicate proofs

**Estimated Effort**: 20-30 hours

---

### Method 4: Domain Transfer for Dense Completeness (Task 982)

**Technique**: Build FMCS directly over TimelineQuot OR prove quotient transfer theorem.

**Why Suitable**:
- Components already proven
- Clear path forward documented in research-001.md
- 3-4 hours estimated

**References**: Task 982 research report

---

## Priority Roadmap

### Phase 1: Dense Completeness Wiring (HIGH PRIORITY)
**Effort**: 3-4 hours
**Task**: 982 (already researched)
**Rationale**: Achieves sorry-free dense completeness with minimal effort

**Deliverables**:
- Wire CanonicalMCS to TimelineQuot
- Zero sorries in completeness chain
- Publication-ready dense completeness theorem

---

### Phase 2: FMP via Filtration (CRITICAL)
**Effort**: 15-25 hours
**New Task Required**: ~985

**Substeps**:
1. Define filtration equivalence relation (3 hrs)
2. Prove bound on equivalence classes (2 hrs)
3. Construct filtered model structure (5 hrs)
4. Prove truth preservation (5 hrs)
5. Connect to decidability completeness (5 hrs)

**Deliverables**:
- `finite_model_property : satisfiable phi -> exists M : FiniteModel, M |= phi`
- Model size bound theorem
- FMP as corollary of filtration

---

### Phase 3: Decidability Completeness (HIGH)
**Effort**: 5-10 hours (after Phase 2)
**Dependencies**: Phase 2 (FMP)

**Substeps**:
1. Connect open saturated branch to FMP countermodel (3 hrs)
2. Prove tableau exhaustiveness (3 hrs)
3. State and prove `decide_complete` (4 hrs)

**Deliverables**:
- `decide_complete : satisfiable phi -> decide phi = invalid _`
- Full decidability theorem
- Correctness for countermodel extraction

---

### Phase 4: Remove Discrete Axiom Debt (MEDIUM)
**Effort**: 7 hours (per Task 981 plan)
**Task**: 981 (in progress)

**Deliverables**:
- Remove `discrete_Icc_finite_axiom`
- Axiom-free discrete completeness
- No disclosures needed for publication

---

### Phase 5: Documentation and Publication (LOW)
**Effort**: 10-15 hours

**Substeps**:
1. Update typst documentation with proven results
2. Write FMP section with formalization details
3. Document decidability completeness
4. Prepare publication-quality summary

---

## Effort Estimates Summary

| Phase | Description | Effort | Dependencies | Priority |
|-------|-------------|--------|--------------|----------|
| 1 | Dense completeness wiring | 3-4 hrs | None | HIGH |
| 2 | FMP via filtration | 15-25 hrs | None | CRITICAL |
| 3 | Decidability completeness | 5-10 hrs | Phase 2 | HIGH |
| 4 | Remove discrete axiom | 7 hrs | None (parallel) | MEDIUM |
| 5 | Documentation | 10-15 hrs | Phases 1-3 | LOW |

**Total to publication-ready decidability**: 40-60 hours

---

## Publication Quality Standards

For publication-quality decidability/FMP results, the following standards must be met:

### Must Have
- [ ] FMP theorem formally proven (not just stated)
- [ ] Decidability completeness proven
- [ ] Zero sorries in decidability chain
- [ ] Zero custom axioms in decidability chain

### Should Have
- [ ] Dense completeness wired (0 sorries)
- [ ] Complexity bounds documented (can cite literature)
- [ ] Clean API for decidability (`decide`, `isValid`, `isSatisfiable`)

### Nice to Have
- [ ] Formalized complexity analysis
- [ ] Discrete completeness axiom-free
- [ ] Mosaic alternative proof

---

## Recommendations

1. **Prioritize FMP via filtration** (Phase 2) as the critical blocking work. Without FMP, decidability is incomplete.

2. **Complete Phase 1 first** (3-4 hours) for quick win on dense completeness.

3. **Run Phase 4 in parallel** - Task 981 is independent and already in progress.

4. **Consider mosaic method only if** filtration proves unexpectedly difficult for the bimodal case.

5. **Publication can proceed with**:
   - Decidability soundness (proven)
   - Dense completeness (after Phase 1)
   - FMP/decidability completeness (after Phases 2-3)
   - Discrete completeness with disclosed axiom OR after Phase 4

---

## Artifacts

This report is the primary output for Teammate C gap analysis.

**Related Files**:
- `Metalogic/Decidability/` - Current decidability infrastructure
- `Metalogic/Decidability/Correctness.lean` - Soundness proof location
- `Metalogic/StagedConstruction/Completeness.lean` - Dense completeness components
- `specs/982_wire_dense_completeness_domain_connection/` - Task 982 research
- `specs/981_remove_axiom_technical_debt_from_task_979/` - Task 981 (axiom removal)

**Next Steps**:
1. Team lead should create Task ~985 for FMP formalization
2. Prioritize Phase 1 (dense wiring) for immediate progress
3. Begin Phase 2 (filtration) as primary decidability work
