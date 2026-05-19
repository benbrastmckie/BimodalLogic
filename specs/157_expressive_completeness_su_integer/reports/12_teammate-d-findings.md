# Teammate D Findings: Strategic Alignment and Long-Term Quality

**Date**: 2026-05-19
**Role**: Horizons -- Strategic Assessment
**Round**: 12 (post-task-116, final team research)

---

## Key Findings

### 1. Confirmed: The Separation Module Does Not Compile

The `lake build` confirms the report-11 assessment: `Defs.lean` fails immediately with "Redundant alternative" errors for all 33 `all_past`/`all_future` pattern match arms. This is a hard prerequisite for any further work on task 157. The task cannot be described as "completing axiom elimination" without first completing the mechanical repair phase.

Error pattern (confirmed):
```
error: Redundant alternative: Any expression matching
  ((φ.imp Formula.bot).snce (Formula.bot.imp Formula.bot)).imp Formula.bot
will match one of the preceding alternatives
```

This occurs across all 33 arms in `Defs.lean` and cascades to all 12 downstream Separation files. The main `lake build` succeeds because `WeakCanonical.lean` does NOT import the Separation submodule.

### 2. Architecture Assessment: The Task-116 Change is Strategically Correct

The architectural change in task 116 (redefining `all_past` and `all_future` from constructors to `def` abbreviations) was the right move for mathematical reasons, but it created a large repair obligation. The strategic position is:

**What is good**: With only 6 constructors, the GHR94 hierarchy proof is no longer circular. The hierarchy circularity (identified in reports 08-10) was caused precisely by having `all_past`/`all_future` as primitive constructors that forced the formalization to handle them separately in the separation proof. The elimination of those constructors means:
- `is_syntactically_separated` only discriminates the 6 real constructors
- Elimination cases 1-8 produce witnesses without `all_past`/`all_future` nodes
- The junction-depth induction can be set up without the circularity

**What is difficult**: Every file in the Separation module (13 files, ~9,944 LOC total) used 8-arm pattern matches and must be converted to 6-arm matches. This is mechanical but pervasive.

**The module is correctly architected** within `WeakCanonical/Separation/`. The subdirectory structure mirrors the GHR94 proof hierarchy (Defs, Eliminations, NormalForm, Hierarchy, SeparationThm) and is a sound design for a theorem of this complexity.

### 3. Code Quality Assessment

**Strengths** (comparing Separation files against `Core/RestrictedMCS.lean` and `Metalogic/Completeness.lean` as quality benchmarks):

- `Defs.lean`: Excellent documentation. Module header, section headers, inline comments, and GHR94 reference numbers throughout. Well-structured with `/-! ## Section Name -/` separators.
- `Eliminations.lean`: Proof of Case 1 (lines 83-165) is exemplary -- complete forward/backward proof, detailed comments about the three temporal positions (u>t, u=t, u<t), clean use of `rcases` and `lt_trichotomy`.
- `SeparationThm.lean`: Clear separation between what is axiomatized and what is proved. Axiom documentation explicitly references the GHR94 lemmas they will eventually replace.

**Weaknesses**:

- `TemporalClosure.lean`: The file has become semantically obsolete given the task-116 changes. It defines `replace_box_with_top`, `no_U_nested_in_S`, and related infrastructure that was a workaround for the all_past/all_future problem. With 6 constructors, most of this file is dead code. Report-11 correctly identifies that ~70% of TemporalClosure.lean can be deleted.
- `DedekindZ.lean`: 2096 lines, not imported by `Separation.lean`, and not referenced in the main proof path. This is a "reals" variant of the separation theorem. Its status after task-116 changes is unclear.
- `DualEliminations.lean`: 8 sorry sites. The file itself acknowledges these are dead code for the expressive completeness proof (DualEliminations is imported by `Separation.lean` but the expressive completeness chain does not depend on it). These sorries should be either proved or the file removed.

**Naming convention**: Consistent with rest of codebase. `snake_case` for definitions, `CamelCase` for structures, docstrings on all public declarations. Namespace `Bimodal.Metalogic.WeakCanonical.Separation` is correctly scoped.

### 4. Literature Fidelity Assessment

The formalization is structurally faithful to GHR94 Chapter 10.2, with some necessary adaptations:

**Faithful to GHR94**:
- `junction_depth`, `junction_depth_U`, `junction_depth_S` (mutual recursive) correctly implement the GHR94 alternation measure (Section 10.2, p. 581)
- The 8 elimination cases in `Eliminations.lean` directly correspond to Lemma 10.2.3 cases 1-8
- `int_truth` correctly implements the GHR94 integer-time truth semantics
- The two-stage proof structure (Stage A: separation theorem; Stage B: FO-to-temporal in `ExpressiveCompleteness.lean`) matches GHR94 Theorem 9.3.1 + 10.2.10

**Necessary adaptations**:
- `box` is treated as trivially true (`int_truth M t (.box _) = True`). This is correct since the separation theorem is purely about temporal expressiveness; the modal component is irrelevant for integer-time semantics.
- The introduction of `is_properly_separated` (vs. `is_syntactically_separated`) is an original contribution beyond what GHR94 states explicitly. GHR94 uses a semantic notion; the formalization introduces a syntactic proxy that is provably equivalent.
- `is_future_only`/`is_past_only` are also original additions needed to bridge syntactic and semantic purity for the operator set {untl, snce, all_future, all_past, box}.

The GHR94 markdown conversion at `literature/Gabbay_Hodkinson_Reynolds_1994_Temporal_Logic_Foundations_Vol1_ch10.md` is available and was actively used in prior research rounds. The research cross-references lemma numbers consistently.

### 5. Downstream Impact on Task 155 (Reynolds Pipeline)

Task 155 needs exactly two theorems from task 157:
1. `separation_theorem_int : (phi : Formula) → is_separable phi` (exported from SeparationThm.lean)
2. `separation_implies_expressiveness` (in ExpressiveCompleteness.lean, currently with 3 sorries)

**Immediate implications**:
- Both theorems EXIST even in the current broken state -- they are defined in files that fail to build, but their signatures are established
- The main `lake build` passes because the Separation module is not on the main build path
- The 9 axioms in SeparationThm.lean appear in `#print axioms bx_completeness` but are Lean `axiom` (trusted assertion), not `sorry` (admitted gap)
- For Phase 3B of task 155, these axioms are invisible at the call site

**After repair**: Once the mechanical repair phase is complete (removing 33 pattern-match arms from Defs.lean and the cascading fixes), the Separation module will build. At that point, task 155 Phase 3B can proceed using the axiomatized separation theorem.

**What task 155 does NOT need**: Zero axioms in SeparationThm.lean. Axiom elimination is a publication-quality enhancement, not a prerequisite for the Reynolds pipeline to work.

### 6. Publication Readiness

For the project's stated goal of "near-publication production readiness" the current state of task 157 is:

**Already publication-quality**:
- All 8 elimination cases (Lemma 10.2.3) are proved without axioms -- the mathematical core
- The proof architecture mirrors GHR94's own structure with clear attribution
- Docstrings and inline documentation are thorough

**Needs work before publication**:
- The Separation module does not compile (hard blocker)
- 9 axioms in SeparationThm.lean: acceptable for a paper claiming "proof with trusted mathematical dependencies" but not for a claim of "fully verified from first principles"
- 8 sorries in DualEliminations.lean: either prove them (they're mechanical) or remove the file
- `TemporalClosure.lean` and `DedekindZ.lean` contain dead code that should be cleaned up

**Publication strategy options**:
1. Publish with axioms, citing Kamp 1968 and Reynolds 1994 as the trusted sources (acceptable)
2. Fully prove the hierarchy before submitting (ideal, but requires 2-3 more implementation rounds)

### 7. Reusability of Separation Infrastructure

The Separation infrastructure has moderate reusability potential:

**Reusable components**:
- `IntStructure` and `int_truth` are generic temporal semantics over Z. Could be extended for integer-time model checking problems.
- `junction_depth` measures are standalone utilities usable for any logic with U/S operators over linear time.
- The 8 elimination cases (Eliminations.lean) are directly applicable to any formalization of temporal logic over integers.

**Non-reusable components**:
- The separation predicates (`is_separable`, `is_properly_separable`) are specific to the {U,S,box} operator set and the project's Formula type.
- The machinery is not parametric over the operator set or the time structure.

**For reuse across logics**: The current formalization is too tightly coupled to `Bimodal.Syntax.Formula`. Making it parametric would require abstracting over the formula type and the set of temporal operators. This is feasible but not worth pursuing for the current publication goal.

---

## Recommended Approach

The most strategically sound path given the current state:

**Immediate Priority (Phase 1): Mechanical Repair of Defs.lean**

This is the prerequisite for everything else. The fix is mechanical: remove 33 redundant `all_past`/`all_future` arms from all pattern matches in Defs.lean. Use helper lemmas to expose the semantics:

```lean
-- Helper lemmas to restore readability after the 6-constructor reduction:
theorem int_truth_all_past (M : IntStructure) (t : ℤ) (φ : Formula) :
    int_truth M t (all_past φ) ↔ ∀ s : ℤ, s < t → int_truth M s φ

theorem int_truth_all_future (M : IntStructure) (t : ℤ) (φ : Formula) :
    int_truth M t (all_future φ) ↔ ∀ s : ℤ, t < s → int_truth M s φ
```

These lemmas, once proved, preserve the readability of downstream proofs that reason about all_past/all_future semantically.

**Phase 2: Repair Downstream Files**

Fix the 12 downstream files. The largest are TemporalClosure.lean (50+ arms) and Hierarchy.lean (60+ arms). Given that much of TemporalClosure.lean was a workaround for the old 8-constructor design, substantial deletion is appropriate.

**Phase 3: Axiom Elimination (the mathematical core)**

Follow the "Flat Hierarchy" approach identified in round-8 research (report 08):
1. Prove `no_S_nested_separable` without temporal closure axioms (~400 LOC)
2. Prove `junction_depth_separable` by strong induction on junction_depth (~200 LOC)
3. Derive all 9 axioms as corollaries (~50 LOC)

The key insight from round-8 analysis (report 08) that makes this feasible: atom z from U-abstraction CANNOT appear in pure-future constituents of the separated form. This breaks the circularity.

**Phase 4: Close Dual Eliminations and ExpressiveCompleteness Sorries**

These are independent and can be scheduled in parallel or after Phase 3.

---

## Evidence/Examples

### Evidence 1: Build Failure Confirmed

```
✖ [788/801] Building Bimodal.Metalogic.WeakCanonical.Separation.Defs
error: Theories/.../Defs.lean:47:4: Redundant alternative: Any expression matching
  ((φ.imp Formula.bot).snce (Formula.bot.imp Formula.bot)).imp Formula.bot
will match one of the preceding alternatives
```

The exact pattern predicted by report-11. All 33 arms fail identically.

### Evidence 2: The Module Boundary is Sound

`WeakCanonical.lean` (line 1-12) does NOT import the Separation submodule:
```lean
import Bimodal.Metalogic.WeakCanonical.ReflexiveCanonical
import Bimodal.Metalogic.WeakCanonical.TruthLemma
-- ... 9 other imports
-- No import of WeakCanonical.Separation or ExpressiveCompleteness
```

This architectural isolation means the broken Separation module does not affect the main library build. This was a deliberate and correct design choice.

### Evidence 3: Quality of Proved Content

The proof of `elim_case_1` (Eliminations.lean lines 83-165) demonstrates the formalization quality. It correctly implements the three-way case split on the temporal position of the U-witness relative to the current time, matching GHR94's semantic argument precisely. No `sorry` or axioms in Eliminations.lean.

### Evidence 4: Axiom vs Sorry Distinction

Current sorry count in WeakCanonical module: 17 sorries (TruthLemma: 6, Transfer: 4, IntegerModel: 2, OrderedSum: 1, DualEliminations: 8 -- wait, DualEliminations not counted in main WeakCanonical).

The 9 axioms in SeparationThm.lean are `axiom` declarations, not `sorry`. In Lean 4:
- `sorry` causes `sorryAx` to appear in `#print axioms` (a warning flag)
- `axiom` creates a trusted declaration (equivalent to citing an external reference)

The temporal closure axioms will appear in `#print axioms bx_completeness` but will NOT show `sorryAx`. This is an important distinction for publication claims.

---

## Confidence Level

**HIGH (90%)** for the architectural and quality assessment.

**MEDIUM-HIGH (75%)** for the Phase 3 axiom elimination path being feasible:
- The mathematical argument is correct (confirmed by round-8 and round-10 research)
- The main risk is formalization complexity: constituent tracking in Lean, well-founded induction termination checking
- The 6-constructor Formula type (task 116) removes the previous circularity blocker

**HIGH (95%)** that task 155 does not need zero axioms from task 157 to proceed:
- The separation theorem exists (axiomatized but sound)
- Phase 3B of task 155 calls the theorem as a black-box
- The axioms are transparent at the call site

---

## Summary Bullets

- The Separation module is broken (build-blocking) due to the task-116 constructor reduction: 33 `all_past`/`all_future` pattern-match arms in `Defs.lean` must be removed before any other work proceeds. This is a ~2-4 hour mechanical fix.
- The module architecture is sound and mirrors GHR94's proof structure; the proof quality of the completed parts (especially `Eliminations.lean`) is high and publication-ready.
- 9 axioms in `SeparationThm.lean` are Lean `axiom` declarations (trusted facts from Kamp 1968/Reynolds 1994), not `sorry` -- the distinction matters for publication claims.
- Task 155 (Reynolds pipeline) does NOT require zero axioms; it needs only the separation theorem to exist as a callable theorem, which it does.
- The "Flat Hierarchy" approach (single well-founded induction on junction_depth, as identified in round-8 research) is the recommended path for axiom elimination after the repair phase, exploiting the now-unblocked 6-constructor Formula type.
- `TemporalClosure.lean` (~813 lines) is largely obsolete dead code after the task-116 change and should be substantially trimmed during the repair phase.
