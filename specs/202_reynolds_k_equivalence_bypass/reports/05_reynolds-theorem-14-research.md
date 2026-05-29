# Reynolds Theorem 14: Formalization Path for Task 202

## 1. Theorem 14 Statement

From Reynolds 1994, Section 7 (p. 129):

> **Theorem 14.** Suppose that ~ is a contemporaneous equivalence relation on a Prior structure M. Then the ~-classes do not end at gaps.

Formally: let M be a temporal structure satisfying Prior-UZ and Prior-SZ. Let ~_M be any contemporaneous equivalence relation (definable by a monadic FO formula ε(x,y), partitioning M into intervals, depending only on the substructure between x and y). Then for every ~_M-class C, C does not end at a Dedekind gap — i.e., C has no supremum/infimum that lies outside C while points arbitrarily close belong to C.

In the codebase, this is formalized as `no_gaps_discrete` in `GoodStructures.lean:820`, which states the equivalent discrete form: if a ≁_M b, then ∃c: a ~_M c ∧ ¬(a ~_M succ(c)). (The discrete case replaces "gap" with "successor boundary".)

## 2. How It Bypasses F-Persistence

**The key insight**: Theorem 14 operates at the *semantic/model-theoretic* level, not at the *syntactic/Lindenbaum* level. It never builds a chain via g_content or Lindenbaum extensions. Instead:

1. Start with the chronicle (a countable discrete Prior structure without endpoints)
2. Define ~_M via "very good" subintervals (Definition: a ~_M b iff M|[a,b] is "very good", meaning every sub-subinterval is k-equivalent to some Z-interval)
3. Theorem 14 proves ~_M has no gaps → combined with `no_boundary_at_successor` (trivially true: finite subintervals are always good), this gives the **one-class theorem** (Theorem 15/`one_class`): all points of M are in one ~_M-class
4. One class → M is very good → M is good → ∃ Z-interval N with M ≡_k N
5. Transfer ¬φ from M to N via k-equivalence (already implemented as `truth_transfer`)
6. Package N as a TaskFrame ℤ countermodel

**Why F-persistence is irrelevant**: This approach never constructs MCS chains. It takes the *already-built* chronicle (which has sorry-free BFMCS properties via `henkin_bfmcs` Phase 1) and proves a *model-theoretic* property about it. The F-persistence problem was about building coherent chains from MCS extensions — Theorem 14 sidesteps that entirely by working with the semantic structure.

## 3. Codebase Alignment

### Already Implemented (sorry-free)

| Component | Location | Status |
|-----------|----------|--------|
| `k_equiv`, `k_equiv_monotone` | `NEquivalence.lean:72-95` | ✅ Sorry-free |
| `KEquivalenceFramework` | `NEquivalence.lean:1084` | ✅ Sorry-free |
| `orderedSum_k_equiv_comp` (composition) | `NEquivalence.lean:1055` | ✅ Sorry-free |
| `contemp_equiv`, `contemp_equiv_is_equiv` | `GoodStructures.lean` | ✅ Sorry-free |
| `no_boundary_at_successor` | `GoodStructures.lean:849` | ✅ Sorry-free |
| `one_class` (Theorem 15) | `GoodStructures.lean:883` | ✅ Sorry-free (modulo `no_gaps_discrete`) |
| `very_good_implies_good` (Lemma 16) | `ShiftAndGlue.lean:829` | ✅ Sorry-free |
| `chronicle_is_good_direct` | `ShiftAndGlue.lean:939` | ✅ Sorry-free (modulo `no_gaps_discrete`) |
| `truth_transfer` | `Transfer.lean` | ✅ Sorry-free |
| `countermodel_discrete_reynolds` | `Transfer.lean:792` | Exists but has sorry (pipeline packaging) |
| `stavi_expressive_completeness` (Thm 9.3.1) | `StaviCompleteness.lean:3170` | ✅ Sorry-free |
| `US_expressively_complete_over_Z` (Thm 10.2.10) | `ExpressiveCompleteness/Theorem.lean:357` | ✅ Sorry-free |
| `flatten_stavi_correct` (U'≡⊥ on discrete) | `StaviConnectives.lean:492` | ✅ But requires `IsSuccArchimedean` |
| `stavi_U_truth` (U' FO semantics) | `StaviConnectives.lean:74` | ✅ Sorry-free |
| `ChronicleAsPriorModel` | `ChronicleExtraction.lean` | ✅ Sorry-free |
| `chronicleAsMonadicStructure` | `Transfer.lean` | ✅ Sorry-free |
| `henkin_bfmcs` (Phase 1 output) | `CanonicalModel.lean` | ✅ Sorry-free |

### The One Sorry: `no_gaps_discrete`

**Location**: `GoodStructures.lean:820-842`

**What it needs**: Reynolds Theorem 5 — US expressive completeness over *Prior structures* (not just ℤ). The codebase has `US_expressively_complete_over_Z` but this requires the carrier to literally be ℤ. Theorem 14 needs the result for arbitrary countable discrete orders satisfying Prior-UZ/SZ.

**The blocker comment** (lines 809-813):
> BLOCKED: Reynolds Theorem 5 (US expressive completeness over Prior structures in general) is not yet formalized. Our `US_expressively_complete_over_Z` covers only structures whose carrier IS ℤ, not general Prior structures. Resolution: formalize Reynolds Theorem 5 by showing U'(A,B) ≡ ⊥ and S'(A,B) ≡ ⊥ in any Prior structure (via Prior-U/S), then applying GHR94 Theorem 9.3.1.

### The Gap: Theorem 5 for General Prior Structures

Reynolds 1994, p. 123-124:

> **Theorem 5.** The language with U and S is expressively complete for the class of Prior structures.

Proof sketch: Show U'(A,B) ↔ ⊥ in all Prior structures (by Prior-U contradiction), then {U,S,U',S'} expressive completeness (Theorem 4 / GHR93 Thm 9.3.1) reduces to {U,S}.

The codebase already has `flatten_stavi_correct` showing U'≡⊥ on discrete orders, but it uses `IsSuccArchimedean` — which is exactly what we're trying to avoid. The fix: prove U'≡⊥ using the **Prior-UZ axiom directly** instead of archimedean well-founded descent.

## 4. Formalization Path

### Step 1: Prove U'≡⊥ on Prior structures without IsSuccArchimedean (~150 lines)

Create `stavi_false_on_prior` in `StaviConnectives.lean` or a new file:

```lean
theorem stavi_U_false_on_prior (M : OrderedMonadicStructure sig)
    [SuccOrder M.carrier] [PredOrder M.carrier]
    [NoMaxOrder M.carrier] [NoMinOrder M.carrier]
    (atomMap : Formula → sig.preds)
    (h_prior_UZ : semantic_prior_UZ M atomMap)
    (t : M.carrier) (A B : Formula) :
    ¬ stavi_U_truth M atomMap t A B
```

The argument follows Reynolds p. 123 directly: if U'(A,B)(t) holds, then B holds for a while up to a gap, then ¬B is true arbitrarily soon after the gap. Apply Prior-U to B: we get either a last point of B (impossible, B holds up to a gap) or a first point of ¬B ∧ K⁻(B). This first point starts a new segment contradicting Prior-U again.

**Key difference from `flatten_stavi_correct`**: uses Prior-UZ axiom hypothesis instead of `IsSuccArchimedean` for well-foundedness.

### Step 2: Derive US expressive completeness over Prior structures (~100 lines)

```lean
theorem US_expressively_complete_over_prior (M : OrderedMonadicStructure sig)
    [SuccOrder M.carrier] [PredOrder M.carrier]
    [NoMaxOrder M.carrier] [NoMinOrder M.carrier]
    (atomMap : Formula → sig.preds)
    (h_prior_UZ : semantic_prior_UZ M atomMap)
    (h_prior_SZ : semantic_prior_SZ M atomMap) :
    -- For any monadic FO sentence φ, exists temporal formula A
    -- such that temporal_truth M atomMap t A ↔ monadic_truth M t φ
    us_expressively_complete_at M atomMap
```

Compose: Stavi expressive completeness (existing) + U'≡⊥ + S'≡⊥ → {U,S} suffices.

### Step 3: Fill in `no_gaps_discrete` (~300-500 lines)

This is the bulk. Implement Reynolds Lemmas 6-13 + Theorem 14:

- **Lemma 6**: Define temporal R holding where ~_M-class ends at a gap (uses Step 2)
- **Lemma 7**: R-intervals are open with excluded endpoints (uses Prior-U)
- **Lemma 8**: No first/last class in R-interval
- **Lemma 9**: Classes in R-interval are elementarily equivalent
- **Lemma 10-11**: Bad point properties
- **Lemma 12**: Model surgery preserves temporal truth (key induction)
- **Lemma 13**: No bad points (contradiction via surgery)
- **Theorem 14**: No gaps

### Step 4: Close pipeline sorry in `countermodel_discrete_reynolds` (~100-200 lines)

The remaining sorry in `Transfer.lean:866` packages the Z-interval as a TaskFrame ℤ countermodel. This needs:
- Show Z-interval from `chronicle_is_good_direct` is unbounded
- Construct `TaskModel` with position-dependent atom valuation
- Prove `truth_at ↔ temporal_truth` correspondence

### Step 5: Rewire `completeness_discrete` (~50 lines)

Replace the current delegation to `dd_countermodel_chronicle_discrete` (which uses the sorry chain through `succ_cofinal`) with `countermodel_discrete_reynolds`.

**Total estimate**: 700-1050 lines, 15-25 hours.

## 5. Risk Assessment

### Low Risk
- Steps 1-2 (U'≡⊥, Prior expressive completeness): Well-understood argument, close to existing code
- Step 5 (rewiring): Mechanical

### Medium Risk
- Step 3 (Lemmas 6-13): The model surgery argument (Lemma 12) requires careful induction over formula structure with case analysis on whether points are in Q⁻, I, or Q⁺. This is ~300 lines of case analysis but conceptually straightforward — Reynolds' paper gives every case explicitly. The key question: does `temporal_truth` decompose cleanly for substructures? The existing `MonadicFO.lean` and `StaviConnectives.lean` infrastructure should support this.

### Higher Risk
- Step 3 (Lemma 6 specifically): Requires constructing a temporal formula R from a monadic FO formula ρ(x) via expressive completeness. The existing `US_expressively_complete_over_Z` constructs such formulas but only over ℤ. We need this for general Prior structures (Step 2). If the expressive completeness proof is constructive enough to extract R, this is fine. If it's purely existential (Classical.choice), we may need to work around non-computability.

### Potential Blockers
1. **Substructure evaluation**: Reynolds' proof assumes that temporal truth in a substructure M|S agrees with evaluation restricted to S. The codebase uses `OrderedMonadicStructure` which includes the carrier as part of the structure. We need clean restriction/substructure operations. `GoodStructures.lean` already has `subinterval` — verify it composes correctly with `temporal_truth`.

2. **Non-constructive expressive completeness**: If `US_expressively_complete_over_prior` only gives ∃A, not a computable A, the model surgery argument may need to be restructured. However, Reynolds' proof only needs existence (the surgery argument is semantic, not syntactic), so this should be fine.

3. **Prior-UZ semantic hypothesis discharge**: `chronicle_is_good_direct` needs to discharge the semantic Prior-UZ/SZ hypotheses for the chronicle structure. The existing code at `ShiftAndGlue.lean:945-983` marks this as partially addressed. The chronicle satisfies Prior-UZ/SZ syntactically (by axiom validity), and `chronicleAsMonadicStructure` + `chronicle_temporal_truth` should bridge syntactic to semantic. This bridge may need ~50 extra lines.
