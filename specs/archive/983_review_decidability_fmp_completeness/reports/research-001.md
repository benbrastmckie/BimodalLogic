# Research Report: Task #983 — Decidability and FMP Review

**Task**: 983 - Review decidability results and FMP for publication
**Date**: 2026-03-16
**Mode**: Team Research (3 teammates)
**Session**: sess_1773704373_51080a

---

## Summary

The ProofChecker codebase has a mature but **partially complete** decidability story.
Decidability soundness (the decision procedure correctly identifies valid formulae) is fully
proven and sorry-free. However, **decidability completeness** and the **Finite Model Property
(FMP)** are the two critical gaps blocking a publication-quality decidability claim. Dense
completeness has all components proven but is blocked by a domain wiring issue (3 sorries in
`FrameConditions/Completeness.lean`, Task 982). Discrete completeness carries axiom debt (Task
981, in progress). Soundness of the proof system is proven with 2 documented edge-case sorries.

The recommended path to publication-quality decidability results is:

1. **Complete dense wiring** (Task 982, 3–4 hrs) — quick win, clears 3 sorries
2. **Formalize FMP via filtration** (new task, 15–25 hrs) — critical blocker
3. **Prove decidability completeness** (new task, 5–10 hrs, depends on FMP)
4. **Remove discrete axiom debt** (Task 981, 7 hrs, parallel track)

Total estimated effort to publication-ready decidability: **40–60 hours**.

---

## Key Findings

### 1. What Is Currently Proven

| Result | Location | Status |
|--------|----------|--------|
| Decidability (tableau procedure) | `Metalogic/Decidability/` | **Sorry-free, axiom-free** |
| Decidability soundness (`decide_sound`) | `Decidability/Correctness.lean` | **Sorry-free** |
| Soundness of proof system (base axioms) | `Metalogic/Soundness.lean` | **2 sorries** (edge cases) |
| Base truth lemma | `Bundle/CanonicalConstruction.lean` | **Sorry-free** |
| Shifted truth lemma | `Bundle/CanonicalConstruction.lean` | **Sorry-free** |
| Dense Cantor isomorphism | `StagedConstruction/CantorApplication.lean` | **Sorry-free** |
| Dense temporal coherent FMCS | `StagedConstruction/Completeness.lean` | **Sorry-free** |
| Countermodel extraction (open branch) | `Decidability/CountermodelExtraction.lean` | **Sorry-free** |

The tableau decision procedure (`decide : Formula → DecisionResult`) is complete
infrastructure: it terminates (fuel-based saturation), extracts proofs from closed branches,
and extracts countermodels from open saturated branches. Soundness of the procedure is proven.

**Axiom dependencies**: Only standard Lean axioms (`propext`, `Classical.choice`,
`Quot.sound`). No custom axioms in the decidability or soundness modules. The one custom axiom
(`discrete_Icc_finite_axiom`) is confined to the discrete completeness module and is actively
being eliminated (Task 981).

### 2. Critical Gaps

#### Gap 1: Finite Model Property — NOT PROVEN (Critical)

**What exists**: SubformulaClosure machinery, signed formula types, countermodel extraction
structure. The FMP was previously attempted (see Boneyard, Task 948) but archived because the
attempt used a non-standard validity notion (`fmp_valid`) that did not match the project's
main validity definition (`valid`). The result was therefore disconnected from the main
decidability theorem.

**What is missing**: A formally proven theorem of the form:
```lean
theorem finite_model_property (φ : Formula) :
    ¬(⊨ φ) → ∃ M : FiniteModel, ¬(truth_at M ... φ)
```
along with an explicit model size bound (bounded by 2^|closure(φ)|).

**Impact**: Without FMP, `decide_complete` (if φ is valid, decide returns ProofFound) cannot
be formally established. The completeness of the tableau calculus connects to FMP: if φ is
satisfiable, the satisfying model can be made finite (via FMP), and the tableau will extract it.

**Note**: The `validity_decidable` theorem currently uses `Classical.em` (classical excluded
middle), which establishes decidability _as a proposition_ but not _computationally_. The
tableau procedure is the computational witness, but its completeness direction remains unproven.

#### Gap 2: Decidability Completeness — NOT PROVEN (High)

**What exists**: `decide_sound : decide φ = ProofFound d → ⊨ φ`

**What is missing**: `decide_complete : ⊨ φ → ∃ d, decide φ = ProofFound d`
(or equivalently: `¬(⊨ φ) → ∃ m, decide φ = CountermodelFound m`)

**Dependencies**: Requires FMP (Gap 1) for the countermodel direction.

#### Gap 3: Dense Completeness Wiring — 3 sorries (Medium)

All individual dense completeness components are proven sorry-free. The gap is a **domain
mismatch**: the truth lemma uses `D = CanonicalMCS` while `valid_dense` quantifies over all
`D` with `DenselyOrdered D` (including `TimelineQuot`). Three sorries in
`FrameConditions/Completeness.lean` need a transfer theorem or direct FMCS construction over
`TimelineQuot`. Task 982 has researched this and recommends building FMCS directly over
`TimelineQuot` using quotient representatives (Option D).

#### Gap 4: Discrete Completeness Axiom Debt (Medium, In Progress)

`discrete_Icc_finite_axiom` was introduced as technical debt in Task 979. Task 981 is
currently planned to remove it via a blocking formula seed construction. Until resolved,
discrete completeness claims in a publication would require axiom disclosure.

#### Gap 5: Soundness Edge Cases — 2 sorries (Low)

Two sorries in `Soundness.lean` (lines 573, 576):
- `temporal_duality` case: circular dependency issue (documented since Task 213)
- `irr` rule case: proof uses product frame construction in `IRRSoundness.lean`

These are well-understood and do not affect the 18 base axioms' soundness theorem.

---

## Literature Context

Standard results establish that all basic modal logics (K, K4, T, B, S4, S5) and tense logics
(Kt, Kt4, with dense or discrete extensions) have the FMP and are decidable. The ProofChecker
logic is a combined tense-modal logic, and its decidability/FMP should follow by standard
methods.

### Relevant Standard Results

| Logic | FMP | Decidability | Complexity | Method |
|-------|-----|--------------|------------|--------|
| K, K4, T, S4, S5 | Yes | Yes | PSPACE (NP for S5) | Filtration |
| Kt, Kt4 | Yes | Yes | PSPACE | Filtration |
| Kt.Dense | Yes | Yes | PSPACE | Filtration + density preservation |
| Kt.Discrete (over ℤ) | Yes | Yes | PSPACE | Filtration + discreteness |

**Key insight for ProofChecker**: The combined tense + modal logic studied here should be
PSPACE-complete (analogous to Kt + modal operators). The filtration technique handles the
bimodal case by quotienting w.r.t. the full subformula closure, preserving both temporal and
modal accessibility. Products of Kt with S5 preserve FMP (Gabbay, Kurucz, Wolter,
Zakharyaschev).

### Proof Method Recommendations

**Filtration** (strongly recommended):
- Define equivalence: `w ≡_Σ v ↔ ∀ ψ ∈ closure(φ), w ⊨ ψ ↔ v ⊨ ψ`
- Size bound: |W*| ≤ 2^|closure(φ)|
- Preservation: Filtration Lemma ensures truth is preserved across the quotient
- Compatibility: Works with MCS-based canonical model; quotient by formula-agreement

The existing `SubformulaClosure` machinery provides the formula set Σ. The MCS infrastructure
provides the canonical model. Filtration takes the quotient and establishes finiteness.

**Key references**:
- Blackburn, de Rijke, Venema (2001) *Modal Logic*, Ch. 2.3 — filtration and FMP
- Gabbay, Hodkinson, Reynolds (1994) *Temporal Logic* — tense logic completeness/decidability
- Sistla & Clarke (1985) — PSPACE-completeness of LTL (complexity baseline)

---

## Synthesis and Conflicts

### Resolved Conflicts

1. **"Decidability is proven"**: Teammate A reports the tableau procedure as sorry-free, but
   Teammate C clarifies the distinction between *soundness* (if returns valid → valid) and
   *completeness* (if valid → returns valid). Both are correct: soundness is proven, completeness
   is not. The `validity_decidable` theorem uses `Classical.em` and is logically trivial.

2. **"FMP is implicit"**: Teammate A notes FMP is "implicit in tableau completeness" via
   countermodel extraction. Teammate C clarifies this is insufficient for a publication
   claim — the FMP must be stated and proven explicitly with a finite model bound. The Boneyard
   history confirms a prior FMP attempt failed due to definition mismatch.

### Key Synthesis: Priority Hierarchy

For a publication making decidability claims alongside soundness and completeness, the
minimum required work is:
- Dense completeness wiring (Task 982) — unblocks completeness claim for dense frames
- FMP formalization via filtration — unblocks decidability completeness
- Decidability completeness proof — closes the computational decidability story

Discrete completeness and soundness edge cases are important but can be disclosed or deferred
in an initial publication.

---

## Priority Roadmap

### Immediate (Parallel Tracks)

**Track A — Dense Completeness (Task 982)**
- Effort: 3–4 hours
- Build FMCS over TimelineQuot directly, or prove domain transfer theorem
- Eliminates 3 sorries in `FrameConditions/Completeness.lean`
- Result: Sorry-free dense completeness theorem

**Track B — Discrete Axiom Removal (Task 981)**
- Effort: 7 hours (6 phases, planned)
- Blocking formula seed construction for SuccOrder
- Result: Axiom-free discrete completeness

### Phase 2 — FMP Formalization (New Task, ~985)

**Effort**: 15–25 hours
**Method**: Filtration

Sub-steps:
1. Define filtration equivalence relation using `SubformulaClosure` (3 hrs)
2. Prove equivalence classes bounded by 2^|closure(φ)| (2 hrs)
3. Construct filtered model structure (5 hrs)
4. Prove filtration truth preservation lemma (5 hrs)
5. Extract finite model from canonical model via filtration (5 hrs)
6. State and prove explicit FMP theorem (5 hrs)

### Phase 3 — Decidability Completeness (New Task, ~986)

**Effort**: 5–10 hours (after Phase 2)
**Dependencies**: FMP (Phase 2)

Sub-steps:
1. Connect open saturated branch to FMP countermodel (3 hrs)
2. Prove tableau exhaustiveness (2 hrs)
3. Prove `decide_complete` (5 hrs)

### Phase 4 — Documentation (New Task or Existing Docs)

**Effort**: 10–15 hours
- Update typst documentation with proven results
- Write FMP section with Lean formalization details
- Prepare publication-quality summary of decidability story

---

## Effort Summary

| Phase | Task | Effort | Priority | Status |
|-------|------|--------|----------|--------|
| Dense wiring | 982 | 3–4 hrs | HIGH | Researched |
| Discrete axiom | 981 | 7 hrs | MEDIUM | Planned |
| FMP filtration | ~985 | 15–25 hrs | **CRITICAL** | Not started |
| Decidability completeness | ~986 | 5–10 hrs | HIGH | Not started |
| Documentation | — | 10–15 hrs | LOW | Not started |
| **Total** | | **40–61 hrs** | | |

---

## Teammate Contributions

| Teammate | Focus | Status | Confidence |
|----------|-------|--------|------------|
| A (codebase-analyst) | Current codebase state, sorry/axiom inventory | Completed | High |
| B (literature-researcher) | Standard FMP/decidability results, proof methods | Completed | High |
| C (gap-analyst) | Gap identification, roadmap, method recommendations | Completed | High |

---

## Recommendations for New Tasks

Based on this research, the following tasks should be created:

1. **Task ~984**: Formalize FMP via filtration for the base bimodal tense logic
   - Language: lean
   - Effort: 15–25 hours
   - Approach: Filtration on canonical model using SubformulaClosure
   - Output: `finite_model_property` theorem with model size bound

2. **Task ~985**: Prove decidability completeness
   - Language: lean
   - Effort: 5–10 hours
   - Depends on: FMP task
   - Output: `decide_complete` theorem

These, combined with Task 982 (dense wiring) and Task 981 (axiom removal), yield a complete
publication-quality decidability story.

---

## Key References

1. Blackburn, P., de Rijke, M., Venema, Y. (2001). *Modal Logic*. Cambridge University Press.
   — Filtration and FMP for K, K4, S4, S5; standard publication reference.

2. Gabbay, D., Hodkinson, I., Reynolds, M. (1994). *Temporal Logic: Mathematical Foundations
   and Computational Aspects, Vol. 1*. Oxford University Press.
   — Completeness and decidability for Kt, Kt4; dense and discrete time.

3. Sistla, A. P., Clarke, E. M. (1985). The complexity of propositional linear temporal logics.
   *Journal of the ACM*, 32(3), 733–749.
   — PSPACE-completeness of LTL.

4. Goldblatt, R. (1987). *Logics of Time and Computation*. CSLI Publications.
   — Foundational tense logic semantics and canonical models.

5. Gabbay, D., Kurucz, A., Wolter, F., Zakharyaschev, M. (2003). *Many-Dimensional Modal
   Logics: Theory and Applications*. Elsevier.
   — FMP for products of modal and temporal logics.
