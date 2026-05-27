# Report 42: Path A Dependency Analysis -- Can Phase 6 Be Implemented Independently of sel_pn_ord?

**Task**: 155 (reynolds_pipeline_activation)
**Date**: 2026-05-27
**Focus**: Trace the exact dependency chain between `nf_characterizable_by_stavi` (Phase 6) and `sel_pn_ord` sorries (Phase 3C) to determine whether Path A is viable.

---

## 1. Import Chain Trace

### 1.1 StaviCompleteness.lean Import Tree (Complete)

```
StaviCompleteness.lean
  └── Decomposition.lean
        └── CustomGame.lean
              └── GapDetection.lean
                    └── TypeFormulas.lean
                          └── Defs.lean
                                ├── StaviConnectives.lean
                                │     └── Table.lean
                                │           ├── MonadicFO.lean
                                │           │     └── (Mathlib: Fintype.Card, SuccPred, Fin.Tuple, Finset, Finite.Card, Positivity)
                                │           └── Syntax.Formula
                                └── NormalForm.lean
                                      └── MonadicFO.lean (shared)
```

### 1.2 Expressiveness Directory Import Tree (Complete)

```
Theorem6.lean
  └── CaseAnalysis.lean          <-- contains sel_pn_ord sorry (lines 1435, 1804, 2015, 2068)
        └── SplitPoint.lean
              └── DConsistencyTransport.lean
                    └── Claim1.lean
                          ├── StaviCompleteness.lean  <-- !! IMPORTS FROM EFGames !!
                          ├── Automation.EFGameTactics
                          ├── Mathlib.Data.Finset.Sort
                          └── Mathlib.Data.Fintype.Pigeonhole
```

### 1.3 Key Observation: Dependency Direction

The dependency is **unidirectional**:

```
Expressiveness/Claim1.lean  ──imports──>  EFGames/StaviCompleteness.lean
```

There is **NO reverse import**. The EFGames directory has zero imports from the Expressiveness directory. Verified by:
- `grep -r "import.*Expressiveness" EFGames/` returns empty
- `grep -r "import.*CaseAnalysis\|import.*Theorem6\|import.*SplitPoint" EFGames/` returns empty
- No cross-references to any Expressiveness names in EFGames code (only a documentation comment mentioning `ghr93_case_II` in CustomGame.lean:1589)

---

## 2. Dependency Verdict

### Does `nf_characterizable_by_stavi` depend on `sel_pn_ord`?

**NO.** There is no import path from `nf_characterizable_by_stavi` to `sel_pn_ord`.

**Proof**: 
1. `nf_characterizable_by_stavi` is defined in `EFGames/StaviCompleteness.lean`
2. `sel_pn_ord` is a local `have` binding inside `ghr93_case_II` in `Expressiveness/CaseAnalysis.lean`
3. The complete transitive import closure of StaviCompleteness.lean is: `{Decomposition, CustomGame, GapDetection, TypeFormulas, Defs, StaviConnectives, NormalForm, Table, MonadicFO, Syntax.Formula}` plus Mathlib imports
4. None of these files are in the `Expressiveness/` directory
5. The `Expressiveness/` directory imports FROM `EFGames/`, not the other way around

### Axiom Verification

| Theorem | File | Axioms | sorryAx? |
|---------|------|--------|----------|
| `nf_characterizable_by_stavi` | EFGames/StaviCompleteness.lean | propext, sorryAx, Classical.choice, Quot.sound | YES (from its own sorry at line 1567) |
| `stavi_expressive_completeness` | EFGames/StaviCompleteness.lean | propext, sorryAx, Classical.choice, Quot.sound | YES (inherits from nf_characterizable_by_stavi) |
| `ghr93_game_iff_decomposition` | EFGames/Decomposition.lean | propext, Classical.choice, Quot.sound | NO |
| `nf_base_sf_correct` | EFGames/StaviCompleteness.lean | propext, Classical.choice, Quot.sound | NO |
| `ghr93_inductive_step` | Expressiveness/CaseAnalysis.lean | propext, sorryAx, Classical.choice, Quot.sound | YES (from sel_pn_ord) |
| `ghr93_forward_to_backward` | Expressiveness/Theorem6.lean | propext, sorryAx, Classical.choice, Quot.sound | YES (inherits from CaseAnalysis) |
| `infimum_gap` | Expressiveness/Claim1.lean | propext, Classical.choice, Quot.sound | NO |

**Critical finding**: The `sorryAx` in `nf_characterizable_by_stavi` comes ONLY from its own sorry at line 1567. It does NOT inherit any `sorryAx` from `sel_pn_ord` or any other Expressiveness sorry. The EFGames infrastructure is completely sorry-free (all 5 supporting files have zero active sorries).

---

## 3. Axiom Propagation Analysis

### 3.1 Current State

If `sel_pn_ord` is sorry'd:
- `ghr93_case_II` has sorryAx
- `ghr93_inductive_step` has sorryAx (uses case II)
- `ghr93_forward_to_backward` has sorryAx (uses inductive step)
- `ghr93_forward_to_backward_rank_varying` has sorryAx

BUT: None of this propagates to `nf_characterizable_by_stavi` because there is no import path.

### 3.2 If Phase 6 Were Closed

If `nf_characterizable_by_stavi` were proved (sorry at line 1567 closed):
- `stavi_expressive_completeness` would become sorry-free (it's already proved from `nf_characterizable_by_stavi`)
- The EFGames directory would be entirely sorry-free
- `sel_pn_ord` in CaseAnalysis.lean would remain sorry'd, unaffected
- `ghr93_forward_to_backward` would still have sorryAx (from CaseAnalysis)

### 3.3 If sel_pn_ord Were Closed (Without Phase 6)

If `sel_pn_ord` were proved (all CaseAnalysis sorries closed):
- `ghr93_inductive_step` would become sorry-free
- `ghr93_forward_to_backward` would become sorry-free
- `nf_characterizable_by_stavi` would be UNAFFECTED (still has its own sorry)

---

## 4. The Deeper Question: Proof Content Dependencies

### 4.1 Import Independence vs. Proof-Content Dependence

The import chain proves that Phase 6 can be WORKED ON independently (no compilation dependency). But can it be COMPLETED independently?

The sorry at line 1567 says it needs:
1. Custom EF games G_{n;r} with forward-to-backward theorem (Thm 6)
2. Composition lemma (Prop 7) composing strategies on sub-intervals
3. Four cases for the main induction (atoms, Until, Since, Stavi gaps)
4. Gap detection formulas (Lemma 9) for Stavi connective cases

The research report 38 (Proposition 7 Composition) describes the critical path as:

```
Proposition 7 (MISSING, in EFGames)
  -> Close Case I sorry in CaseAnalysis.lean
  -> Close Cases II, III/IV sorries (includes sel_pn_ord)
  -> Complete main induction
  -> Build StaviFormula for depth-(k+1) NFs
  -> Close nf_characterizable_by_stavi sorry
```

### 4.2 Is the CaseAnalysis Step NECESSARY?

**The report 38 critical path conflates two things**:

1. **The existing Expressiveness/CaseAnalysis.lean**: This file implements Cases I-IV of the GHR93 main induction as used by `ghr93_forward_to_backward`. It lives in the Expressiveness directory and feeds into Theorem6.lean.

2. **The case analysis needed by nf_characterizable_by_stavi**: The sorry at line 1567 also needs a case analysis (the same four cases from GHR93 Section 8). But this case analysis is for a DIFFERENT theorem -- it's for showing that Stavi-n-equivalence implies game wins, which feeds into showing that NFs are characterizable.

**These are the same mathematical argument but could be formalized in two separate locations.**

### 4.3 Two Parallel Formalizations of Theorem 6

The codebase already contains two parallel formalizations:

| Aspect | EFGames (Phase 6) | Expressiveness (Phase 3C) |
|--------|-------------------|---------------------------|
| Theorem 6 infrastructure | CustomGame.lean (strategy restriction) | Theorem6.lean (forward-to-backward) |
| Cases I-IV | NOT YET FORMALIZED | CaseAnalysis.lean (with sel_pn_ord sorry) |
| Import chain | EFGames only | Expressiveness -> EFGames |
| Sorry status | 1 sorry (nf_characterizable) | Multiple sorries (sel_pn_ord, etc.) |

**The nf_characterizable_by_stavi sorry needs its OWN case analysis that would live entirely within the EFGames directory.** It does NOT need to import or reference the CaseAnalysis.lean in the Expressiveness directory.

### 4.4 Could the Proof Reuse Expressiveness/CaseAnalysis?

In principle, one could import CaseAnalysis.lean into StaviCompleteness.lean and reuse the existing case analysis. But:
- This would create a CIRCULAR dependency: CaseAnalysis -> Claim1 -> StaviCompleteness would become CaseAnalysis -> Claim1 -> StaviCompleteness -> CaseAnalysis
- Therefore it is impossible without restructuring
- The proof must be self-contained within EFGames

---

## 5. Feasibility Assessment

### 5.1 Can Phase 6 Be Implemented First?

**YES, with caveats.**

**What's needed** to close the sorry at line 1567:
1. **Composition lemma (Prop 7)**: ~250-390 lines. Can be added to EFGames (new file or extending Decomposition.lean). Entirely self-contained -- uses only existing EFGames infrastructure.
2. **Case analysis for the main induction**: This is the same mathematical content as CaseAnalysis.lean but must be formalized WITHIN the EFGames module. Estimated ~300-600 lines.
3. **NF existence formula builder**: ~550-780 lines. Uses the above plus the IH.

**Total estimated effort**: 1100-1770 lines (from report 38).

### 5.2 Risk: Duplicated Effort

If Phase 6 implements its own case analysis within EFGames, and Phase 3C later closes the CaseAnalysis.lean sorries, there will be two parallel formalizations of the same mathematical content:
- `EFGames/` version: used by `nf_characterizable_by_stavi`
- `Expressiveness/` version: used by `ghr93_forward_to_backward`

This is a code quality concern but NOT a correctness concern. The mathematical content is the same; the Lean proofs would be similar but adapted to their respective module contexts.

### 5.3 Alternatively: Factor Out Shared Infrastructure

A cleaner approach would be to factor the case analysis into a shared module that both EFGames and Expressiveness can import. This would require:
- Moving the case analysis core out of `Expressiveness/CaseAnalysis.lean`
- Placing it in a new shared file (e.g., `WeakCanonical/Shared/CaseAnalysis.lean`)
- Having both `EFGames/StaviCompleteness.lean` and `Expressiveness/CaseAnalysis.lean` import from it

This is a restructuring effort that might be worth doing but is separate from the dependency question.

---

## 6. Summary

### Answers to Research Questions

| Question | Answer |
|----------|--------|
| Does `nf_characterizable_by_stavi` depend on `sel_pn_ord` via imports? | **NO** -- completely separate import chains |
| Does `sorryAx` propagate from `sel_pn_ord` to `nf_characterizable_by_stavi`? | **NO** -- the only `sorryAx` in nf_characterizable is from its own sorry |
| Can Phase 6 be implemented independently? | **YES** -- but requires its own case analysis (~1100-1770 lines total) |
| Would closing Phase 6 fix `sel_pn_ord`? | **NO** -- they are independent problems |
| Would `sel_pn_ord` sorry affect a completed Phase 6? | **NO** -- no axiom propagation path exists |
| Is Path A viable? | **YES** -- Phase 6 can proceed first; the circularity feared in the problem statement does NOT exist |

### The Non-Circularity Explained

The feared circularity was:
```
Phase 3C (sel_pn_ord) -> formula materialization -> nf_characterizable (Phase 6) -> main induction -> Cases I-IV -> sel_pn_ord
```

This circularity does NOT exist because:
1. `nf_characterizable_by_stavi` does NOT import CaseAnalysis.lean
2. The import goes the OTHER direction: CaseAnalysis -> Claim1 -> StaviCompleteness
3. The "main induction" and "Cases I-IV" needed by Phase 6 must be formalized WITHIN EFGames (not reusing Expressiveness/CaseAnalysis)
4. Each module has its own independent path to the mathematical content

### Path A Action Plan

1. Implement Proposition 7 (composition lemma) in `EFGames/Composition.lean` (~250-390 lines)
2. Implement the four-case analysis within EFGames (new file or section, ~300-600 lines)
3. Build the depth-(k+1) NF existence formula and prove correctness (~550-780 lines)
4. Close the sorry at StaviCompleteness.lean:1567
5. Verify with `lean_verify` that `nf_characterizable_by_stavi` has no `sorryAx`
6. `stavi_expressive_completeness` becomes sorry-free automatically (already proved from nf_characterizable)
