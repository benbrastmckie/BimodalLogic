# Research Report: Task #157

**Task**: Formalize expressive completeness of {S,U} over integer time (GHR94 Ch 10)
**Date**: 2026-05-18
**Mode**: Team Research (4 teammates)
**Session**: sess_1779122477_2f6d41

## Summary

After 8 rounds of development, 7/8 elimination cases are proved non-circularly but Case 7 and the hierarchy theorem remain. All 4 teammates converged on the same diagnosis: (1) Case 7 is blocked because the implementation uses `neg_until_equiv` to expand ¬U, introducing a second U-type — but GHR94 Section 10.2.3 item 7 gives a direct decomposition that avoids this entirely; (2) the hierarchy theorem has failed 7+ times because the formalization uses opaque existentials for `is_separable`, making GHR94's "substitute into past constituents" step impossible — the proof must construct separated equivalents directly. The mathematical source (GHR94) is strictly non-circular; the circularity is a formalization artifact.

## Key Findings

### 1. Case 7 Has a Direct GHR94 Formula (HIGH CONFIDENCE — all 4 teammates agree)

GHR94 Lemma 10.2.3 item 7 (literature file lines 95-101) gives:

```
S(a∧U(A,B), q∨¬U(A,B))
↔ S(A∧(q∨¬U)∧S(a,B∧q), q∨¬U)          -- D1
  ∨ S(a,B∧q) ∧ A                         -- D2
  ∨ S(a,B∧q) ∧ B ∧ U(A,B)               -- D3
```

- **D2**: `S(a,B∧q)` is U-free (Case 0). `A` is an atom. Product is separable.
- **D3**: `S(a,B∧q)` is U-free (pure past). `B∧U(A,B)` is S-free (pure future). Product is separable.
- **D1**: `S(A∧(q∨¬U)∧S(a,B∧q), q∨¬U)`. The event contains `(q∨¬U)` as a factor. Use `since_distrib_or_left` to split:
  - `S(A∧q∧S(a,B∧q), q∨¬U)`: U-free event → **Case 4** (already proved)
  - `S(A∧¬U∧S(a,B∧q), q∨¬U)`: ¬U in event and guard → **Case 8** (already proved)

**This avoids `neg_until_equiv` entirely.** No second U-type U(¬A∧¬B, ¬A) is ever introduced. The current implementation's approach (expanding ¬U via `neg_until_equiv`) is the WRONG strategy for Case 7.

### 2. Current Code State (HIGH CONFIDENCE — verified by code audit)

| Component | Status | Details |
|-----------|--------|---------|
| Cases 1-4 (Eliminations.lean) | **PROVED** | 698 lines, sorry-free, no axiom deps |
| Case 5 (DedekindZ.lean) | **PROVED** | Non-circular via case3_equiv + snce_combined_U_separable |
| Case 6 (DedekindZ.lean) | **2 sorry** | L1617, L1625 in D3 of case6_branchB_separable |
| Case 7 (DedekindZ.lean) | **`all_separable _`** | L1659, fully circular |
| Case 8 (DedekindZ.lean) | **PROVED** | Non-circular via case8_equiv_Z |
| Hierarchy (Hierarchy.lean) | **Infrastructure only** | 1055 lines, abstract_untl/snce ready, no hierarchy theorem |
| SeparationThm.lean | **9 axioms** | 4 is_separable + 4 is_properly_separable + 1 atom preservation |
| ExpressiveCompleteness.lean | **Sorry-free** | Main theorem compiles |

### 3. Root Cause of All Hierarchy Failures (HIGH CONFIDENCE — unanimous)

The Lean formalization represents separability as an opaque existential:
```lean
def is_separable (φ : Formula) : Prop :=
  ∃ ψ, is_syntactically_separated ψ = true ∧ int_equiv φ ψ
```

GHR94's proof substitutes back into "past constituents" of the separated form — but with an existential, you have no syntactic access to the witness `ψ`. You can't identify which positions are "past constituents" vs "future constituents."

**Every failed approach** eventually reduces to: given separated `ψ`, substitute temporal formula for atom `z` in `ψ`, show result is separable. This requires `snce_separable` (an axiom) to handle S-terms containing `z`.

**GHR94's approach**: constructs `ψ` explicitly and substitutes into each past constituent INDEPENDENTLY, applying the IH to each one. No temporal closure is needed because each constituent's complexity measure is strictly lower.

### 4. GHR94's Hierarchy Is Strictly Non-Circular (HIGH CONFIDENCE)

The hierarchy is layered — each lemma uses ONLY the previous one:
1. **10.2.4** (Cases 1-8): Direct semantic equivalences, no induction
2. **10.2.5** (single U-type): Induction on S-nesting depth k above U(A,B)
3. **10.2.6** (multi U-type): Induction on count n of U-types
4. **10.2.7** (no_S_nested_in_U): Induction on U-nesting depth under S
5. **10.2.8** (all formulas): Induction on junction_depth

`snce_separable` is a CONSEQUENCE of 10.2.8, not a prerequisite. After proving `all_formulas_separable`, temporal closure follows trivially.

### 5. Case 6 Alternative (MEDIUM CONFIDENCE)

The 2 sorry in Case 6 D3 (Branch B) may be avoidable by switching to GHR94's direct Case 6 formula (10.2.3 item 6, literature lines 88-93):

```
S(a∧¬U, q∨U) ↔ S(a, q∧¬A) ∧ ¬A ∧ ¬(B∧U(A,B))
             ∨ S(¬B∧¬A∧(q∨U)∧S(a,q∧¬A), q∨U)
```

Then "eliminations (3) and (5)" finish. This is a cleaner decomposition than the current `neg_until_equiv` + U∧U' contradiction approach.

However, the current Case 6 proof is nearly complete (only D3's 2 sorry remain), so it may be faster to fix the existing approach.

### 6. The Axiom Dependency Structure (HIGH CONFIDENCE)

All 9 axioms derive from one core fact: `snce_separable`. The dependency chain:
- `snce_separable` → (by duality/expansion) `untl_separable`, `all_past_separable`, `all_future_separable`
- 4 `is_separable` axioms → (via syntactic→proper bridge) → 4 `is_properly_separable` axioms
- Atom preservation → follows from tracking atoms through the construction

So proving `all_formulas_separable` (which gives `snce_separable` for free) eliminates all 9 axioms.

## Synthesis

### Conflicts Resolved

| Conflict | Resolution |
|----------|------------|
| Hierarchy approach: 4-level (B) vs flat (D) | **4-level preferred**: matches GHR94 exactly, easier to verify against literature. Flat hierarchy is higher-risk but potentially simpler implementation. |
| Case 6 fix: finish existing (A) vs rewrite (B) | **Finish existing preferred**: only 2 sorry remain (~150 LOC needed). Rewrite is lower risk but higher effort. |
| Constructive witnesses: required (C) vs optional (D) | **Required for hierarchy**: all teammates agree the constituent-substitution step needs concrete formulas. Question is whether to use Subtype or track formulas externally. |

### Gaps Identified

1. **No one has attempted the hierarchy with constructive witnesses.** All 7 failed attempts used opaque existentials. The correct approach (constructing concrete separated formulas) has never been tried.

2. **Infrastructure for "past constituent extraction" is missing.** The hierarchy needs: given a syntactically separated formula ψ, decompose it into bool(atoms, future-terms, past-terms), substitute into past-terms, reassemble. This infrastructure doesn't exist in Hierarchy.lean.

3. **The plan (v11) needs revision for Phase 3 (Case 7) and Phase 4 (hierarchy).**

## Recommendations

### Priority 1: Case 7 via GHR94 10.2.3 Direct Formula (~200 LOC)

Prove the semantic equivalence:
```
S(a∧U, q∨¬U) ↔ S(A∧(q∨¬U)∧S(a,B∧q), q∨¬U) ∨ S(a,B∧q)∧A ∨ S(a,B∧q)∧B∧U
```

Then show each disjunct is separable:
- D2, D3: trivially separable (boolean combinations of past/future)
- D1: split via `since_distrib` into Case 4 + Case 8 (both already proved)

This eliminates the last `all_separable` use in DedekindZ.lean, making all 8 cases non-circular.

### Priority 2: Fix Case 6 D3 Sorry (~150 LOC)

Either:
- **(A)** Complete the existing d21-style sigma_B approach (2 sorry at L1617, L1625)
- **(B)** Rewrite Case 6 using GHR94 10.2.3 item 6 formula → Cases 3 + 5

### Priority 3: Hierarchy Theorem with Constructive Witnesses (~600-1000 LOC)

**Step 1**: Implement `no_S_nested_separable` (GHR94 Lemmas 10.2.5-10.2.7 combined)
- Does NOT need temporal closure axioms
- Combined induction on (U-count, S-nesting-above-U)
- Uses Cases 1-8 to eliminate U from S-formulas
- Uses atom-substitution trick (abstract n-1 U-types) for multi-U

**Step 2**: Implement `junction_depth_separable` (GHR94 Lemma 10.2.8)
- Strong induction on junction_depth
- JD ≥ 2: abstract S from U-args → apply no_S_nested_separable → substitute back into past constituents → IH

**Step 3**: Derive all 9 axioms as theorems from `all_formulas_separable`

**Key infrastructure needed**: A way to decompose a syntactically separated formula into its boolean structure (atoms, pure-future terms, pure-past terms) and substitute into past terms independently. Options:
- **(A)** Define `SepForm` inductive type with explicit structure (Teammate D's idea)
- **(B)** Use structural lemmas about `is_syntactically_separated` to extract constituents
- **(C)** Thread concrete formulas through the hierarchy, never using opaque existentials

### Minimum Viable Target

If the full hierarchy proves too complex: eliminate only the 4 `is_separable` axioms (highest value), leaving `is_properly_separable` and atom preservation as documented follow-up.

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Contribution |
|----------|-------|--------|------------|------------------|
| A | Code Audit | completed | high | Precise sorry/axiom counts, line numbers, dependency chain |
| B | GHR94 Literature | completed | high | Case 7 direct formula, constituent substitution explanation |
| C | Critic | completed | high | Root cause diagnosis (opaque existentials), self-contradiction detection |
| D | Strategic Horizons | completed | medium-high | Flat hierarchy architecture, minimum viable target, SepForm idea |

## References

- GHR94 Ch 10, Lemma 10.2.3 items 5-8 (Cases 5-8 semantic equivalences)
- GHR94 Ch 10, Lemmas 10.2.4-10.2.8 (hierarchy structure)
- GHR94 Ch 10, Section 10.3 (Dedekind specialization for K±/Γ± triviality)
- `phase-6B-analysis-20260518.md` (7 failed hierarchy approaches)
- `phase-2-3-handoff-20260518.md` (latest implementation state)
