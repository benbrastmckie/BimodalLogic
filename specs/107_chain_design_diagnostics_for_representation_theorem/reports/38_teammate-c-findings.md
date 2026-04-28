# Teammate C (Critic) Findings: Task #107

**Role**: Critic — validate claims, find blind spots, audit assumptions
**Date**: 2026-04-28

## Key Findings

### 1. Sorry Count: Report 37 Undercounts Non-Chronicle Sorries

**Report 37 claim**: 11 chronicle-path sorries + 12 non-chronicle = 23 total.

**Actual count**:

| File | Count | Classification |
|------|-------|---------------|
| **Chronicle Path** | | |
| CounterexampleElimination.lean | 7 | 6 c2' + 1 density (lines 786, 824, 864, 902, 938, 970, 1086) |
| RRelation.lean | 2 | nested bridging, INVALID (lines 1177, 1191) |
| ChronicleToCountermodel.lean | 2 | FUC Until + Since (lines 615, 619) |
| **Chronicle subtotal** | **11** | **Matches report 37** |
| **Non-Chronicle BXCanonical** | | |
| RootScopedChain.lean | 3 | lines 186, 193, 198 |
| Filtration/SigmaOrdering.lean | 3 | lines 82, 99, 143 |
| TruthLemma.lean | 2 | lines 296, 321 |
| Frame.lean | 1 | line 205 |
| Quasimodel/Construction.lean | 2 | lines 150, 186 |
| Quasimodel/Realization.lean | 4 | lines 67, 73, 197, 249 |
| **Non-chronicle subtotal** | **15** | **Report 37 claims 12 — off by 3** |
| **Algebraic Path** | | |
| InteriorOperators.lean | 1 | line 83: `sorry /- temp_k_dist derivable from BX -/` |
| TenseS5Algebra.lean | 3 | lines 195, 278, 320: `sorry /- temp_a/temp_l removed in BX -/` |
| **Algebraic subtotal** | **4** | **Not mentioned in report 37** |
| **GRAND TOTAL** | **30** | **Report 37 says 23 — off by 7** |

**Note**: Completeness.lean's internal documentation (line 187) claims "4 total, on critical path" — this is STALE and contradicts the actual 11 chronicle sorry sites. This documentation hasn't been updated since task 107's implementation waves added the c2' sorry sites.

**Correction**: The true sorry count outside Boneyard is 30, not 23. The 4 algebraic sorry sites are on a separate path and could potentially be resolved independently.

**Confidence**: HIGH (verified by direct grep of all source files).

### 2. Axiom Inventory: Confirmed

The report's axiom assumptions are correct:

| Axiom | Status | Verified |
|-------|--------|----------|
| BX1/BX1' (serial_future/past) | Present | ✓ |
| BX2/BX2' (left_mono_until/since) | Present | ✓ |
| BX3/BX3' (right_mono_until/since) | Present | ✓ |
| BX4/BX4' (connect_future/past) | Present | ✓ |
| BX5/BX5' (self_accum_until/since) | Present | ✓ |
| BX6/BX6' (absorb_until/since) | Present | ✓ |
| BX7/BX7' (linear_until/since) | Present | ✓ |
| BX8/BX8' (until_step/since_step) | REMOVED | ✓ (not sound under half-open guard) |
| BX9/BX9' (until_elim/since_elim) | REMOVED | ✓ (unsound under open guard) |
| BX10/BX10' (until_F/since_P) | Present | ✓ |
| BX11/BX11' (temp_linearity) | Present | ✓ |
| BX12/BX12' (F_until_equiv/P_since_equiv) | Present | ✓ |

Total: 33 axiom constructors (4 prop + 5 modal + 22 temporal + 2 interaction).

**Note**: The Axioms.lean header says "26" temporal axioms but lists BX8/BX9 as removed, giving 22 temporal. The file header also says "37 constructors" but counts 33 in the actual inductive type. This is a minor documentation inconsistency.

**Confidence**: HIGH (read full Axioms.lean source).

### 3. B_sub_A_of_burgessR3: Genuinely Unrecoverable Under Open Guard

**Report 37 claim**: "may be false" under open guard.

**Analysis**: This is correct — the property is **provably unrecoverable** without BX9.

The property says: if `burgessR3(A, B, C)`, then `B ⊆ A`.

Under burgessR3, for β ∈ B and any γ ∈ C: `untl(β, γ) ∈ A`. The question is whether `β ∈ A` follows.

Available derivation paths from `untl(β, γ) ∈ A`:
- **BX10**: `untl(β,γ) → F(γ)`. Gives `F(γ) ∈ A`, tells us nothing about β.
- **BX5**: `untl(β,γ) → untl(β ∧ untl(β,γ), γ)`. Enriches the guard, doesn't extract β.
- **BX6**: `untl(β, β ∧ untl(β,γ)) → untl(β,γ)`. Goes the wrong direction.
- **BX4**: `β → G(P(β))`. Requires β ∈ A as a premise — circular.
- **BX2**: `(β→χ) ∧ G(β→χ) → (untl(β,γ) → untl(χ,γ))`. Transforms guard, doesn't extract it.

Without BX9 (`untl(β,γ) → β ∨ γ`), there is no axiom that extracts the guard formula from an Until formula. The Until connective is "opaque" — you can transform its components but cannot decompose it into its parts.

**Concrete countermodel sketch**: Consider a linear order with exactly two points {0, 1} where 0 < 1. Let A be an MCS at 0, B = {β}, C an MCS at 1. Under open guard, `untl(β,γ)` at 0 means: ∃ s > 0 with γ(s) and ∀ r ∈ (0,s): β(r). With the open interval (0,1), if there are no points strictly between 0 and 1, the guard is vacuously satisfied. So `untl(β,γ) ∈ A` is consistent with `β ∉ A` (β need not hold at point 0 itself, only in the open interval).

**Impact**: The v21 plan's consistency argument for D0 CANNOT use B_sub_A. Any revised plan MUST work without it. This is the single hardest mathematical obstacle.

**Confidence**: HIGH (mathematical analysis of axiom system, confirmed by task 113 Phase 3 removal).

### 4. Time Estimate: 69-90 Hours Is Optimistic

**Report 37 claim**: 69-90 hours, 60-70% confidence.

**Assessment**: This estimate is likely low by a factor of 1.5-2x.

Evidence:
1. **37 research rounds** with repeated "breakthrough → new blocker" pattern. The cycle time suggests each "simple" phase encounters unexpected obstacles.
2. **Phase 1 must be rebuilt from scratch** — report 37 estimates 28-35 hours for this alone, but the B_sub_A gap makes the consistency argument an open research problem, not just a coding task.
3. **The nested bridging fix (4-8h estimate)** is uncertain because no concrete alternative proof has been sketched. The lemma may require a fundamental restructuring of CounterexampleElimination.lean.
4. **FUC replacement (10-14h)** uses `rRelation_guard_continues'` which operates on the codebase's `rRelation`, NOT the Burgess `burgessR3`. The bridge between these two r-relation concepts is not formalized. This is a hidden complexity.

**Revised estimate**: 100-150 hours (4-6 months at 5-8h/week).

**Confidence**: MEDIUM (trajectory-based estimate, not bottom-up).

### 5. Hidden Dependencies: Clean

No references to removed infrastructure (`burgess_D0`, `B_sub_A_of_burgessR3`, `until_elim_mcs`, `rRelation_self_mcs`, `lemma_2_6_full`, etc.) were found outside the Boneyard. Task 113's cleanup was thorough.

**Confidence**: HIGH.

### 6. Density: Finite Stages Are Discrete, Limit Is Dense

**Report 37 claim**: "vague about density at finite stages."

**Clarification from source code**:

- **Finite stages** (`omega_chain_val n`): Domain is a **finite** set of rationals. Between any two adjacent points, there are NO intermediate domain points. The stage is discrete (actually worse — it's a finite linear order embedded in ℚ).
- **Limit** (`limit_dom`): The union of all finite stages IS dense (proved sorry-free as `limit_dom_dense` at ChronicleConstruction.lean:698). The proof works by showing that for any x < y in `limit_dom`, the density counterexample ⟨x, y, ⊥, ⊥, .density⟩ is eventually enumerated and processed, inserting z = (x+y)/2.
- **Lemma 2.6** (point insertion): Applied at **finite stages** where the domain is discrete. The Lemma 2.6 splitting creates a new DCS between two adjacent MCS points. It does NOT require density of the underlying domain. The density of the limit domain is a CONSEQUENCE of the omega-chain construction, not a prerequisite.

**Key insight**: The plan's Phase 1 (D0 consistency) operates at a finite stage. The D0 seed set construction does not need density. The `burgessR3Maximal_exists_from_seed` theorem (sorry-free) works at finite stages.

**Confidence**: HIGH (verified from source code).

### 7. rRelation vs burgessR3 Confusion — A Hidden Complexity

The codebase has TWO different r-relation concepts that are easily confused:

1. **`rRelation A B`** (codebase r-relation, obligation propagation): For all `γ U δ ∈ A`, either `δ ∈ B` or (`γ ∈ B` ∧ `γ U δ ∈ B`). Used in `rRelation_guard_continues'`.

2. **`burgessR3 A B C`** (Burgess r-relation, content-based): For all `β ∈ B, γ ∈ C`, `untl(β,γ) ∈ A` (and since mirror). Used in the chronicle construction.

The plan and reports sometimes conflate these. The FUC sorry sites (Phase 4) need a connection between the Cantor-embedded MCS assignments and the `rRelation` concept. But the chronicle's C3 condition (interval containment via DCS) provides this connection indirectly.

**This conceptual gap is not addressed anywhere in the plan or reports.**

**Confidence**: MEDIUM (the bridge may be straightforward but hasn't been formalized).

## Recommended Corrections

1. **Fix sorry count**: Report 37's "12 non-chronicle" should be "15 non-chronicle + 4 algebraic = 19 off-path". Grand total is 30, not 23.

2. **Update Completeness.lean documentation**: Its "4 total, on critical path" claim (line 187) is stale and misleading.

3. **State B_sub_A as definitively unrecoverable**: Report 37 hedges with "may be false." It IS unrecoverable under the current axiom system without BX9. The revised plan must treat this as a hard constraint, not a risk.

4. **Clarify the rRelation/burgessR3 bridge**: Any revised plan must explicitly address how the chronicle's `burgessR3`-based C3 condition translates to the `rRelation`-based guard propagation needed for FUC. This is a non-trivial formalization step.

5. **Increase time estimate**: 69-90h → 100-150h is more realistic given the trajectory. The B_sub_A gap and the r-relation bridge are research problems, not just coding tasks.

6. **Consider the algebraic path**: The 4 sorry sites in InteriorOperators.lean and TenseS5Algebra.lean use `sorry /- temp_X removed in BX -/` — these are lemmas that were provable under the OLD axiom system (which had temp_a, temp_l, etc.) but need new proofs under BX. They may be derivable from the current BX axioms; temp_k_dist is literally an axiom (BX constructor). If temp_a and temp_l are derivable from BX1-BX12, these 4 sorries could be closed in a few hours, independently of the chronicle path.

## Evidence/Examples

- Sorry count: grep -rn "sorry" across all Chronicle/ and BXCanonical/ files
- Axioms: Full read of Axioms.lean (313 lines)
- burgessR3 definition: ChronicleTypes.lean:305
- Density proof: ChronicleConstruction.lean:698-732
- rRelation_guard_continues': RRelation.lean:130-136
- Nested bridging sorry stubs: RRelation.lean:1169-1191
- FUC sorry sites: ChronicleToCountermodel.lean:615, 619

## Confidence Level

**Overall**: HIGH for factual findings (sorry counts, axiom inventory, density), MEDIUM for time estimates and strategic recommendations.
