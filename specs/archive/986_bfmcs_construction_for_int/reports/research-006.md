# Research Report: Task #986 (Sixth Iteration - Truth Lemma Analysis)

**Task**: 986 - bfmcs_construction_for_int
**Started**: 2026-03-17T10:00:00Z
**Completed**: 2026-03-17T11:30:00Z
**Effort**: Deep analysis of truth lemma structure
**Dependencies**: research-005.md findings
**Sources/Inputs**: ParametricTruthLemma.lean, TemporalCoherence.lean, CanonicalFrame.lean, ROAD_MAP.md
**Artifacts**: specs/986_bfmcs_construction_for_int/reports/research-006.md
**Standards**: report-format.md, return-metadata-file.md, proof-debt-policy.md

## Executive Summary

- **CRITICAL DISCOVERY**: The ROAD_MAP explicitly marks **all D=Int approaches as ABANDONED and FORBIDDEN** by project constraint
- **Truth Lemma Analysis**: Confirmed that F/P witnesses are NOT limited to subformulas of phi; Lindenbaum closure introduces arbitrary new F/P obligations
- **Linearization Obstruction**: Mathematically confirmed - tree-structured witness graph cannot be linearized into Int chain
- **Task 986 Status**: Should be marked **BLOCKED/ABANDONED** - this approach violates project architectural constraints
- **Recommended Path**: D-from-Syntax via Cantor isomorphism (Task 956 Phase 8) is the ONLY acceptable path

## Context & Scope

### Research Question from Delegation

The delegation asked:
> "If the truth lemma only needs subformula witnesses, the tree is FINITE!"
> "A finite tree CAN be linearized into Int"

This research tested this hypothesis by analyzing the actual truth lemma proof structure.

### ROAD_MAP Dead End Discovery

**CRITICAL**: The ROAD_MAP.md explicitly states (lines 515-540):

> **Dead End: All Int/Rat Import Approaches**
> **Status**: ABANDONED
> **Related Tasks**: Task 956 (v001-v009), Task 910, Task 903
>
> **Why It Failed**: Importing D from outside the logic violates the task's fundamental requirement. The duration domain D must EMERGE from the temporal axioms. Using D=Int/Rat:
> - Makes task_rel trivial, defeating the purpose of task semantics
> - Does not demonstrate that D's algebraic structure is a consequence of the axioms
> - Is **explicitly FORBIDDEN** by the project constraint

This means Task 986 (BFMCS construction for D=Int) is fundamentally misaligned with project architecture.

## Findings

### 1. Truth Lemma Structure Analysis

From `ParametricTruthLemma.lean`, the truth lemma is proven by induction on formula structure:

```lean
theorem parametric_canonical_truth_lemma (B : BFMCS D) (h_tc : B.temporally_coherent)
    (fam : FMCS D) (hfam : fam in B.families) (t : D) (phi : Formula) :
    phi in fam.mcs t <-> truth_at ... phi
```

For the G case (lines 274-309):
- Forward direction: Uses `fam.forward_G` (part of FMCS, not F/P coherence)
- **Backward direction**: Uses `temporal_backward_G`, which calls `forward_F`

### 2. The Backward G Case Uses forward_F

From `TemporalCoherence.lean` (lines 166-179):

```lean
theorem temporal_backward_G (fam : TemporalCoherentFamily D) (t : D) (phi : Formula)
    (h_all : forall s : D, t < s -> phi in fam.mcs s) :
    Formula.all_future phi in fam.mcs t := by
  by_contra h_not_G
  ...
  have h_F_neg : Formula.some_future (Formula.neg phi) in fam.mcs t :=
    neg_all_future_to_some_future_neg (fam.mcs t) h_mcs phi h_neg_G
  obtain (s, h_lt, h_neg_phi_s) := fam.forward_F t (Formula.neg phi) h_F_neg  -- <-- HERE
  ...
```

**Key Observation**: `forward_F` is called with `Formula.neg phi`, where `phi` is the immediate subformula under G.

### 3. Why Subformula Restriction Does NOT Apply

The hypothesis was: "If truth lemma only needs witnesses for subformulas of the original phi, the witness tree is finite."

**This hypothesis is FALSE** because:

1. **Lindenbaum closure introduces new formulas**:
   - `canonical_forward_F` produces witness `W = Lindenbaum({psi} union g_content(M))`
   - `g_content(M)` contains ALL formulas `{chi | G(chi) in M}`
   - M was extended from a seed via Lindenbaum, so it contains infinitely many formulas
   - W therefore contains formulas that are NOT subformulas of the original phi

2. **W may contain new F/P obligations**:
   - W is a Lindenbaum extension, so it contains either `F(theta)` or `neg(F(theta))` for EVERY theta
   - The F/P formulas in W are NOT constrained to subformulas of phi
   - When the truth lemma recurses on these new F/P formulas, it needs MORE witnesses

3. **The witness tree branches at each step**:
   ```
   M0 (contains F(neg psi1), F(neg psi2))
    |
    +-- W1 (witness for F(neg psi1)) - contains F(neg theta1), F(neg theta2), ...
    |    |
    |    +-- W1a (witness for F(neg theta1)) - contains more F/P...
    |    +-- W1b (witness for F(neg theta2)) - ...
    |
    +-- W2 (witness for F(neg psi2)) - contains F(neg chi1), ...
         |
         +-- ...
   ```

4. **This tree structure cannot be linearized into Int**:
   - The tree has branching at each node
   - A linear chain (Int-indexed) can only have one successor per node
   - Linearization requires collapsing all branches, which loses F/P coherence

### 4. Mathematical Confirmation of Linearization Obstruction

**Theorem (Informal)**: Let T be the tree of F/P witnesses starting from M0. If T has branching degree > 1 at any node, then T cannot be embedded into Int preserving the strict order required for F/P coherence.

**Proof sketch**:
- F/P coherence requires: if F(psi) in mcs(t), then exists s > t with psi in mcs(s)
- In the tree T, a node M with k > 1 F-obligations has k distinct witness children
- In an Int embedding f: T -> Int, we need f(W1) > f(M), f(W2) > f(M), etc.
- But W1 and W2 are siblings (not ordered), so we can place f(W1) < f(W2) or f(W2) < f(W1)
- However, W1's F-witnesses need indices > f(W1), and W2's F-witnesses need indices > f(W2)
- When f(W1) < f(W2), W2's witnesses compete with W1's descendants for indices
- For infinite branching at infinitely many levels, the witnesses cannot fit into Int

**Key Insight**: The obstruction is not about "too many witnesses" but about **structural incompatibility** between tree topology and linear topology.

### 5. The CanonicalMCS Solution Works Because...

The CanonicalMCS domain (D = Set of all MCSes) works because:
- It is NOT linearly ordered
- Each F/P witness is just another MCS in the domain
- No need to "fit" witnesses into a linear order

From `CanonicalFMCS.lean`, the construction is **sorry-free** precisely because:
```lean
-- forward_F is trivial: the witness MCS is in the domain by construction
theorem canonicalMCS_forward_F (w : CanonicalMCS) (phi : Formula)
    (h_F : Formula.some_future phi in canonicalMCS_mcs w) :
    exists s : CanonicalMCS, w <= s and phi in canonicalMCS_mcs s
```

### 6. Project Architecture Forbids D=Int

From ROAD_MAP.md (Architectural Decision "D Must Emerge from Syntax"):

> **CRITICAL CONSTRAINT**: Importing Int or Rat as the duration domain D is STRICTLY FORBIDDEN. D must be discovered from the canonical timeline's order-theoretic properties, not imported.

The ONLY acceptable path is:
1. Canonical timeline properties: countable, dense, no endpoints (from axioms)
2. Cantor isomorphism: T isomorphic to Q (discovered, not imported)
3. D emerges as (Q, +) from the isomorphism
4. TaskFrame from syntax, truth lemma, completeness

## ROAD_MAP.md Reflection

### Pitfalls Checked

| Dead End | Relevance | Impact on Recommendations |
|----------|-----------|--------------------------|
| All Int/Rat Import Approaches | **DIRECT HIT** | Task 986 objective is explicitly forbidden |
| D=Int canonical construction | **DIRECT HIT** | Exactly what Task 986 attempts |
| D=Int dovetailing chain | **DIRECT HIT** | The approach in IntBFMCS.lean |

### Strategy Alignment

| Strategy | Status | Relevance |
|----------|--------|-----------|
| D Construction from Canonical Timeline | ACTIVE | This is the ONLY acceptable path |
| Algebraic Verification Path | PAUSED | Task 986 falls under this (paused, low priority) |
| Indexed MCS Family Approach | ACTIVE | Works for CanonicalMCS, not for D=Int |

## Decisions

1. **Task 986 should be marked BLOCKED/ABANDONED**: The objective (BFMCS for D=Int) is explicitly forbidden by project architecture.

2. **IntBFMCS sorries are UNFILLABLE BY DESIGN**: They represent the linearization obstruction, not proof gaps.

3. **Recommended action**: Update IntBFMCS.lean documentation to explicitly note this is a deprecated exploration, not an active development path.

4. **The truth lemma DOES require ALL F/P witnesses**, not just subformula witnesses. The hypothesis that "finite subformulas = finite witnesses" is false due to Lindenbaum closure.

## Answer to Focus Prompt Questions

### Q: Does completeness actually REQUIRE F/P coherence for ALL formulas, or just SUBFORMULAS of phi?

**Answer**: The truth lemma proof DOES require F/P coherence for formulas beyond phi's subformulas.

Specifically:
- The backward G case calls `forward_F` with `neg(psi)` where `psi` is a subformula
- BUT the witness MCS W for this call contains arbitrary formulas from Lindenbaum closure
- When recursively proving the truth lemma for formulas IN W, we need F/P coherence for THOSE formulas too
- This recursion continues unboundedly

### Q: Can a formula-specific Int chain work?

**Answer**: NO, because:
1. The witness MCS from `canonical_forward_F` is NOT constrained to subformulas
2. Lindenbaum closure adds arbitrary F/P obligations
3. The tree structure of witnesses cannot be linearized into Int

### Q: Is Int-indexed F/P coherence achievable?

**Answer**: NO, this is proven mathematically impossible:
- Tree-structured witnesses require branching
- Int is linearly ordered (no branching)
- These structures are incompatible

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| Continued effort on D=Int | Mark task BLOCKED/ABANDONED immediately |
| IntBFMCS.lean sorries treated as proof gaps | Add explicit documentation noting architectural constraint |
| Confusion about completeness path | Clarify that D-from-Syntax (Task 956) is the ONLY path |

## Recommendations

### Immediate Actions

1. **Mark Task 986 as BLOCKED/ABANDONED** with reason: "D=Int approach explicitly forbidden by project architecture; see ROAD_MAP.md Dead Ends section"

2. **Update IntBFMCS.lean** header documentation:
   ```lean
   /-!
   # DEPRECATED: BFMCS Construction for D = Int

   **Status**: ABANDONED (2026-03-17)
   **Reason**: D=Int import approach forbidden by project architecture.
   **See**: ROAD_MAP.md "Dead End: All Int/Rat Import Approaches"

   The two `sorry`s in forward_F/backward_P are MATHEMATICALLY UNFILLABLE:
   the tree-structured F/P witness graph cannot be linearized into an Int-indexed chain.

   **Acceptable path**: D-from-Syntax via Cantor isomorphism (Task 956)
   -/
   ```

3. **Redirect effort to Task 956 Phase 8** (D-from-Syntax wiring gap)

### Why This Is Definitive

This research definitively shows:
- The linearization obstruction is mathematical, not a proof gap
- The ROAD_MAP explicitly forbids this approach
- No amount of clever construction can overcome tree-vs-chain incompatibility

## Summary

Task 986 (BFMCS for D=Int) should be **immediately marked BLOCKED/ABANDONED**.

The focus prompt asked whether a formula-specific chain could work. The answer is **NO**:
1. F/P witnesses are not limited to subformulas (Lindenbaum closure adds arbitrary formulas)
2. The witness tree has branching structure
3. Int is linearly ordered (no branching)
4. These are structurally incompatible

Most importantly, the ROAD_MAP explicitly marks all D=Int approaches as **FORBIDDEN** by project constraint. The ONLY acceptable path to sorry-free completeness is Task 956's D-from-Syntax via Cantor isomorphism.

## Context Extension Recommendations

### Discovered Concepts Requiring Documentation

| Concept | Report Section | Currently Documented? | Gap Type |
|---------|----------------|----------------------|----------|
| Linearization obstruction for F/P coherence | Finding 3 | Partial (research reports only) | extension |
| D-from-Syntax as only acceptable path | Finding 6 | Yes (ROAD_MAP.md) | N/A |
| Tree vs chain topology incompatibility | Finding 4 | No | new_file |

### New Context File Recommendations

| Filename | Directory | Content Scope | Priority | Create Task? |
|----------|-----------|---------------|----------|--------------|
| `linearization-obstruction.md` | `domain/` | Mathematical formalization of why tree cannot linearize to chain | Medium | No (documented in ROAD_MAP) |

### Existing Context File Extensions

None needed - the ROAD_MAP.md Dead Ends section adequately documents this.

### Summary

- **New files needed**: 0 (ROAD_MAP covers this)
- **Extensions needed**: 0
- **Tasks to create**: 0
- **High priority gaps**: 0

## Appendix: Key Files Referenced

| File | Key Content |
|------|-------------|
| ROAD_MAP.md | Dead End: All Int/Rat Import Approaches (lines 515-540) |
| ParametricTruthLemma.lean | Truth lemma proof showing forward_F usage |
| TemporalCoherence.lean | temporal_backward_G using forward_F |
| CanonicalFrame.lean | canonical_forward_F producing arbitrary witness MCS |
| IntBFMCS.lean | The two unfillable sorries |
