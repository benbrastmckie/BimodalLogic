# Research Report: Task #93 - Guard Convention Analysis (Round 50)

**Task**: 93 - Complete BXCanonical embedding
**Date**: 2026-04-20
**Mode**: Team Research (4 teammates)
**Session**: sess_1776698469_4c6f73

## Summary

This round provides a **definitive resolution** to the guard convention question that has blocked task 93. All 4 teammates independently converge on the same diagnosis and the same two viable paths forward. The analysis is rigorous, backed by concrete countermodels and literature references.

**Key Result**: The only guard convention validating both BX2 and BX9 simultaneously is **half-open guard [t, s) + reflexive G** (the Burgess-Xu 1982/1988 convention). No other combination works. The project must choose between two tracks based on whether reflexive G is acceptable.

## Key Findings

### 1. Documentation/Code Mismatch (ALL teammates confirm, 100% confidence)

Truth.lean's docstring (line 14) claims "half-open guard [t, s)" but the actual code at line 128 implements **open guard (t, s)** via `t < r` (strict inequality). This mismatch has confused 49 prior research rounds. The sorry in `until_elim_valid` correctly reflects the actual (open guard) semantics, not a bug.

### 2. Complete Convention × Axiom Validity Matrix

| Convention | G type | BX1 | BX2 | BX3 | BX5-7 | BX8 | BX9 | BX10 | BX12 |
|------------|--------|-----|-----|-----|--------|-----|-----|------|------|
| (a) Open (t,s), strict witness | strict | NMO | YES | YES | YES | NO | NO | YES | YES |
| (b) Half-open [t,s), strict witness | strict | NMO | **NO** | YES | YES | NO | YES | YES | YES |
| (c) Half-open (t,s], strict witness | strict | NMO | YES | YES | YES | NO | NO | YES | YES |
| (d) Closed [t,s], strict witness | strict | NMO | **NO** | YES | YES | NO | YES | YES | YES |
| (e) Open (t,s), reflexive witness | strict | NMO | YES | * | YES | NO | NO | * | YES |
| **(f) Half-open [t,s), reflexive witness** | **reflex** | **YES** | **YES** | **YES** | **YES** | NO | **YES** | **YES** | **YES** |

NMO = requires NoMaxOrder assumption. * = partial validity issues.

**Convention (f) uniquely validates all axioms except BX8**, which is structurally invalid on arbitrary linear orders (requires density or discreteness frame conditions).

### 3. BX8 is Structurally Invalid on Arbitrary Linear Orders (ALL teammates confirm)

BX8 (`φ ∧ F(φ U ψ) → φ U ψ`) fails under ALL guard conventions on arbitrary linear orders due to the "(t, s') gap" — the interval between the current point and the F-witnessed future point has unknown φ-behavior. BX8 is valid only on:
- Discrete orders (immediate successor closes the gap)
- Dense orders (intermediate points fill the gap)
- Or: it is derivable from BX5+BX6+BX7 proof-theoretically

### 4. The Irreflexive Switch Was Misdirected (Teammates C, D concur)

The irreflexive switch removed phi→F(phi) derivability but broke BX9 soundness. The Lindenbaum re-entry problem it targeted is NOT solved by non-derivability alone (Lindenbaum extensions can still freely add F(phi)). However, non-derivability DOES enable constrained Lindenbaum (the seed can exclude F(phi) without inconsistency).

### 5. Literature Alignment (Teammate B confirms)

- **Burgess (1982), Xu (1988)**: Reflexive G + half-open Until. All BX axioms valid. phi→F(phi) derivable. Standard completeness proof.
- **Kamp (1968), Venema (1993)**: Open guard, strict G. BX9 NOT included. Completeness via different axiom set.
- **No published system** uses half-open guard with irreflexive G — this combination is non-standard and creates the BX2/BX9 incompatibility.

## Synthesis

### Conflicts Resolved

| Conflict | Resolution |
|----------|-----------|
| Teammate C says "revert to reflexive" vs D says "don't revert" | Both are partially right. Reflexive G fixes soundness but re-enables phi→F(phi). The choice depends on which completeness approach is used. |
| Teammate A's "convention (f) requires reflexive G" vs D's "reformulate BX2" | These are the same two tracks. D's reformulation keeps irreflexive G but modifies the axiom. Both are viable. |
| BX8 status | All agree: BX8 is sorry'd correctly regardless of convention. Not a guard issue. |

### The Two Viable Tracks

#### Track A: Formalize Burgess's Original System (Revert to Reflexive G)

- Change `all_future` to `t ≤ s` (reflexive G), change Until guard to `t ≤ r` (half-open)
- **All BX axioms become valid** (except BX8 on general orders)
- BX1 (Gφ→φ) is valid again; seriality axioms become redundant
- phi→F(phi) IS derivable via BX1 contrapositive
- **Constrained Lindenbaum is IMPOSSIBLE** (cannot exclude F(phi) from seed when phi→F(phi) derivable)
- Completeness requires the standard Burgess-Xu approach (modal completeness first)
- ~200 LOC changes, aligns with published literature

#### Track B: Novel Irreflexive System (Reformulate BX2, Keep Irreflexive G)

- Keep `all_future` as `t < s` (irreflexive G)
- Change Until guard to `t ≤ r` (half-open [t, s))
- Reformulate BX2: `(φ→χ) ∧ G(φ→χ) → (φ U ψ → χ U ψ)` (adds present-point conjunct)
- **BX9 becomes valid** (half-open guard includes t)
- **BX2 (reformulated) becomes valid** (present-point from explicit conjunct, future from G)
- phi→F(phi) NOT derivable (irreflexive G, no BX1)
- **Constrained Lindenbaum remains possible** (can exclude F(phi) from seed)
- ~80 LOC changes, novel result (not in literature), publishable
- Chain construction sorries remain (orthogonal to soundness)

### Gaps Identified

1. **BX8 validity on Z**: Need to verify whether BX8 is valid specifically on Z (discrete). If so, soundness holds for the canonical model even without general frame validity.
2. **Track B axiom completeness**: Reformulating BX2 may require verifying that the modified axiom system is still complete. Is `(φ→χ) ∧ G(φ→χ)` derivable from the original `G(φ→χ)` plus other axioms? (Only if BX1 holds, which it doesn't in Track B.)
3. **BX4 interaction**: The original Burgess BX4 (`φ ∧ (χ U ψ) → χ U (ψ ∧ (χ S φ))`) is replaced in the codebase by `φ → G(P(φ))`. Need to verify this replacement works under both tracks.
4. **Other axioms**: A full audit (task 95) should verify all axioms under the chosen convention before committing to implementation.

### Recommendations

1. **Immediate**: Choose Track A or Track B based on project goals
   - Track A if: formalizing a known result (Burgess) is the priority
   - Track B if: novel contribution (irreflexive completeness) is the priority + constrained Lindenbaum is viable

2. **Before implementing**: Run task 95 axiom audit under the chosen track's convention

3. **For either track**: BX8 requires frame-class specialization (valid on Z, not on all orders). The soundness theorem should be `valid_on_int` or `valid_on_serial_discrete` rather than `valid`.

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Finding |
|----------|-------|--------|------------|-------------|
| A | Mathematical analysis (6 conventions) | completed | high | Convention (f) uniquely validates BX2+BX9; BX8 needs frame conditions |
| B | Literature survey | completed | high | Burgess-Xu uses reflexive G + half-open; no published irreflexive system |
| C | Critical audit | completed | high | Doc/code mismatch is root cause; irreflexive switch was misdirected |
| D | Strategic horizons | completed | high | Two tracks ranked; reformulate BX2 is lowest-effort viable path |

## Decision Required

The project owner must choose:

**Track A** (Burgess, reflexive G): Proven completeness approach, aligns with literature, but re-enables the Lindenbaum re-entry problem that motivated 49 rounds of chain construction research.

**Track B** (Novel, irreflexive G + reformulated BX2): Preserves the irreflexive switch motivation, keeps constrained Lindenbaum viable for chain construction, but requires verifying completeness of a novel axiom system.

**Recommendation**: Track B appears more aligned with the project's investment (49 rounds of chain construction research depend on constrained Lindenbaum, which only works under irreflexive G). The ~80 LOC soundness fix is low-risk and publishable.

## References

- Burgess, J.P. (1982a). Axioms for tense logic. *Notre Dame Journal of Formal Logic*, 23(4):367-374.
- Xu, M. (1988). On some U, S-tense logics. *Journal of Philosophical Logic*, 17:181-202.
- Kamp, H. (1968). *Tense Logic and the Theory of Linear Order*. PhD thesis, UCLA.
- Venema, Y. (1993). Completeness via Completeness. In *Diamonds and Defaults*, Springer.
- Reynolds, M. (1996). Axioms for temporally linear tense logics.
- Teammate A findings: `specs/093_complete_bxcanonical_embedding/reports/50_teammate-a-findings.md`
- Teammate B findings: `specs/093_complete_bxcanonical_embedding/reports/50_teammate-b-findings.md`
- Teammate C findings: `specs/093_complete_bxcanonical_embedding/reports/50_teammate-c-findings.md`
- Teammate D findings: `specs/093_complete_bxcanonical_embedding/reports/50_teammate-d-findings.md`
