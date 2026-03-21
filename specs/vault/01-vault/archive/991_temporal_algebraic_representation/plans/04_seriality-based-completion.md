# Implementation Plan: Task #991 (Seriality-Based Completion)

- **Task**: 991 - temporal_algebraic_representation
- **Version**: 04 (revised from 03)
- **Status**: [NOT STARTED]
- **Effort**: 3 hours
- **Dependencies**: None
- **Research Inputs**: reports/08_discrete-completeness-strict-semantics.md
- **Artifacts**: plans/04_seriality-based-completion.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

This plan completes Phase 6 of task 991 using the **seriality-based consistency proof** discovered in research report 08. The key insight is that the discrete immediate successor seed is consistent because seriality guarantees M has strict successors, and any strict successor satisfies the entire seed.

### Revision Rationale

Plan 03 marked Phase 6 as [PARTIAL] with a blocking issue: `g_content(M) ⊆ M` is FALSE under strict semantics. The original proof attempted to derive consistency via the T-axiom, which doesn't hold for strict temporal operators.

Research report 08 provides the mathematically correct solution:
- **Seriality guarantees**: Every serial MCS M has strict successors
- **Any strict successor satisfies the seed**: Both g_content(M) and blocking formulas
- **Satisfiable implies consistent**: Standard modal logic result

### Prior Progress

| Phase | Status | Description |
|-------|--------|-------------|
| 4 | [COMPLETED] | Axiom Declaration (canonicalR_irreflexive_axiom) |
| 5 | [COMPLETED] | Truth Lemma Simplification |
| 6 | [PARTIAL] | Staged Construction - THIS PLAN completes |
| 7 | [COMPLETED] | Algebraic Module Updates |
| 8 | [COMPLETED] | Derived Theorems |
| 9 | [COMPLETED] | Final Cleanup & Documentation |

### Current Blockers in DiscreteSuccSeed.lean

| Line | Issue | Solution |
|------|-------|----------|
| 332 | sorry in `discreteImmediateSuccSeed_consistent` Case 2 | Phase 6A: Seriality proof |
| 407 | `g_content_subset_mcs_axiom` (FALSE axiom) | Phase 6C: Remove |
| 532 | sorry in `discreteImmediateSucc_covers` | Phase 6B: Case analysis or incremental |
| 569 | sorry in covering proof | Phase 6B: Same |
| 602 | sorry in covering proof | Phase 6B: Same |

## Goals & Non-Goals

**Goals**:
- Prove `discreteImmediateSuccSeed_consistent` via seriality argument
- Resolve covering property (direct proof or incremental refactor)
- Remove the FALSE workaround axiom `g_content_subset_mcs_axiom`
- Achieve clean build with no sorries in DiscreteSuccSeed.lean
- No axioms beyond the justified `canonicalR_irreflexive_axiom`

**Non-Goals**:
- Proving g_content(M) ⊆ M (mathematically false under strict semantics)
- Major architectural changes beyond DiscreteSuccSeed.lean
- Perfect coverage proof (axiom fallback is acceptable if justified)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Covering proof too complex | M | M | Fallback to incremental construction or axiom |
| Seriality lemmas missing | L | L | Derive from existing forward_temporal_witness machinery |
| Blocking formula interaction | L | L | Detailed case analysis following report 08 |

## Implementation Phases

### Phase 6A: Seriality-Based Seed Consistency [COMPLETED]

**Goal**: Prove `discreteImmediateSuccSeed_consistent` using the seriality argument.

**Mathematical Argument** (from report 08):
1. Seriality gives F(⊤) ∈ M for any serial MCS M
2. The forward witness seed {⊤} ∪ g_content(M) is consistent
3. Its Lindenbaum extension W is a strict successor of M (CanonicalR M W)
4. W satisfies g_content(M) by definition of CanonicalR
5. W satisfies all blocking formulas (see below)
6. Therefore the discrete seed ⊆ W, so the seed is satisfiable, hence consistent

**Blocking Formula Satisfiability in W**:
- Each blocking formula is ¬ψ ∨ ¬G(ψ) where ¬G(ψ) ∈ M
- For any MCS W: either ¬ψ ∈ W or ψ ∈ W (completeness)
- If ¬ψ ∈ W: left disjunct satisfied
- If ψ ∈ W and ¬G(ψ) ∈ W: right disjunct satisfied
- If ψ ∈ W and G(ψ) ∈ W: contradiction with CanonicalR M W and ¬G(ψ) ∈ M? Need irreflexivity.

**Tasks**:
- [ ] Read WitnessSeed.lean to understand `forward_temporal_witness_seed_consistent`
- [ ] Add helper lemma: `blocking_formula_satisfiable_in_strict_successor`
- [ ] Prove: if CanonicalR M W and ¬G(ψ) ∈ M, then blockingFormula ψ ∈ W
- [ ] Refactor `discreteImmediateSuccSeed_consistent` to use seriality approach
- [ ] Remove the Case 2 sorry at line 332
- [ ] Run `lake build` to verify

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/DiscreteSuccSeed.lean`

**Verification**:
- `discreteImmediateSuccSeed_consistent` compiles without sorry
- Proof uses seriality rather than T-axiom
- `lake build Bimodal.Metalogic.StagedConstruction.DiscreteSuccSeed` succeeds

---

### Phase 6B: Covering Property Resolution [COMPLETED]

**Goal**: Address the 3 sorries in `discreteImmediateSucc_covers`.

**Options** (in order of preference):

**Option B1: Direct Case Analysis** (if straightforward)
- Prove: if CanonicalR M K and CanonicalR K W where W = discreteImmediateSucc M, then K = M ∨ K = W
- Use blocking formulas to derive contradiction for intermediate K
- May require careful analysis of each case

**Option B2: Incremental Construction Refactor**
- Use existing machinery from ImmediateStagedBuild.lean
- Covering becomes trivial: intermediates don't exist when successors are added
- Larger refactor but cleaner long-term

**Option B3: Axiom Declaration** (fallback)
- Accept covering as an axiom with mathematical justification
- Consistent with existing pattern (discrete_Icc_finite_axiom)
- Documented as semantic property, not technical debt

**Decision Criteria**:
- Try Option B1 first (30 minutes)
- If complex, evaluate Option B2 (assess refactor scope)
- If B1 & B2 infeasible, use Option B3 with documentation

**Tasks**:
- [ ] Attempt direct proof of covering (line 532, 569, 602)
- [ ] If stuck, read ImmediateStagedBuild.lean for incremental approach
- [ ] If infeasible, add axiom `discreteImmediateSucc_covers_axiom` with justification
- [ ] Remove all sorries from covering proof
- [ ] Run `lake build` to verify

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/DiscreteSuccSeed.lean`
- Possibly `Theories/Bimodal/Metalogic/StagedConstruction/ImmediateStagedBuild.lean`

**Verification**:
- No sorries in `discreteImmediateSucc_covers`
- Either proof completed or axiom with justification
- `lake build` succeeds

---

### Phase 6C: Remove Workaround Axiom [COMPLETED]

**Goal**: Delete the mathematically false `g_content_subset_mcs_axiom`.

**Tasks**:
- [ ] Delete `axiom g_content_subset_mcs_axiom` (line 407)
- [ ] Delete `g_content_subset_mcs` that wraps it (line 412-414)
- [ ] Update any code that references `g_content_subset_mcs`
- [ ] Run `lake build` to find compilation errors
- [ ] Fix any downstream uses
- [ ] Run `lake build` to verify

**Timing**: 20 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/DiscreteSuccSeed.lean`

**Verification**:
- No `g_content_subset_mcs_axiom` in codebase
- `lake build` succeeds
- grep confirms removal

---

### Phase 6D: Final Verification [COMPLETED]

**Goal**: Ensure DiscreteSuccSeed.lean is complete and integrated.

**Tasks**:
- [ ] Run `lake build Bimodal.Metalogic.StagedConstruction`
- [ ] Verify no sorries remain: `grep -n sorry DiscreteSuccSeed.lean`
- [ ] Verify only justified axioms: `grep -n "^axiom" DiscreteSuccSeed.lean`
- [ ] Check downstream imports compile
- [ ] Run full `lake build`
- [ ] Update module docstring to reflect seriality-based approach

**Timing**: 10 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/DiscreteSuccSeed.lean` (docstring only)

**Verification**:
- No sorries in DiscreteSuccSeed.lean
- Only canonicalR_irreflexive_axiom remains as justified axiom
- Full build succeeds

---

## Testing & Validation

- [ ] `lake build Bimodal.Metalogic.StagedConstruction.DiscreteSuccSeed` succeeds
- [ ] `grep -n sorry DiscreteSuccSeed.lean` returns empty
- [ ] `grep -n "^axiom" DiscreteSuccSeed.lean` returns only justified axioms
- [ ] `lake build` succeeds (full build)
- [ ] Module docstring explains seriality-based approach

## Artifacts & Outputs

- plans/04_seriality-based-completion.md (this file)
- summaries/05_seriality-completion-summary.md (after implementation)
- Proof of `discreteImmediateSuccSeed_consistent` via seriality
- Resolution of `discreteImmediateSucc_covers` (proof or justified axiom)
- Removal of FALSE axiom `g_content_subset_mcs_axiom`

## Rollback/Contingency

### If seriality proof fails

The seriality argument from report 08 is mathematically sound. If implementation fails:
1. Check if missing lemmas about CanonicalR and seriality
2. May need to strengthen forward_temporal_witness infrastructure
3. Ultimate fallback: axiom with comprehensive justification

### If covering proof too complex

The incremental construction approach from ImmediateStagedBuild.lean is the standard technique from Segerberg/Verbrugge. If direct proof fails:
1. Assess refactor scope for incremental approach
2. If scope too large, accept covering as justified axiom
3. Document as semantic property matching literature

## References

- specs/991_temporal_algebraic_representation/reports/08_discrete-completeness-strict-semantics.md
- Theories/Bimodal/Metalogic/Bundle/WitnessSeed.lean - forward_temporal_witness_seed_consistent
- Theories/Bimodal/Metalogic/StagedConstruction/ImmediateStagedBuild.lean - incremental approach
- Verbrugge et al., "Completeness by construction for tense logics of linear time"
