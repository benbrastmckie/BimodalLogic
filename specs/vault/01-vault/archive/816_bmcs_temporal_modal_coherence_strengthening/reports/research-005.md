# Research Report: Task #816 - Publication Best Practices for Sorry Handling

**Task**: 816 - bmcs_temporal_modal_coherence_strengthening
**Started**: 2026-02-02T12:00:00Z
**Completed**: 2026-02-02T12:45:00Z
**Effort**: Medium (research-focused)
**Dependencies**: None
**Sources/Inputs**:
- Mathlib contribution guidelines
- Archive of Formal Proofs submission requirements
- ITP/CPP conference standards
- Academic literature on formal verification and omega-rule limitations
- Codebase analysis (TruthLemma.lean, Completeness.lean)
**Artifacts**:
- This report (specs/816_bmcs_temporal_modal_coherence_strengthening/reports/research-005.md)
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **Recommendation**: Option B - Provide the forward direction only (sorry-free)
- The forward direction suffices for completeness and is fully verified
- Mathlib and AFP have strict no-sorry policies for contributions
- Well-documented partial results are acceptable in academic publications
- The omega-rule limitation is a fundamental theoretical constraint, not fixable by better proof engineering

## Context & Scope

The Truth Lemma in `Theories/Bimodal/Metalogic/Bundle/TruthLemma.lean` currently states:

```lean
theorem bmcs_truth_lemma (B : BMCS D) (fam : IndexedMCSFamily D) (hfam : fam ∈ B.families)
    (t : D) (φ : Formula) :
    φ ∈ fam.mcs t ↔ bmcs_truth_at B fam t φ
```

The biconditional has:
- **Forward direction** (MCS membership -> truth): FULLY PROVEN (sorry-free)
- **Backward direction** (truth -> MCS membership): Contains 2 sorries in temporal cases (G and H)

The backward direction sorries stem from the omega-rule limitation: finitary proof systems cannot capture the infinitary inference "if phi holds at all times t+1, t+2, ..., then G phi holds at t."

The completeness theorems in `Completeness.lean` only require the forward direction and are therefore **sorry-free**.

### Research Questions

1. What are publication best practices for Lean 4 proofs in 2026?
2. Should the Truth Lemma retain sorries or be reformulated as forward-only?
3. How do formal verification communities handle fundamental limitations?

## Findings

### 1. Mathlib Contribution Guidelines

From the [Mathlib contribution guide](https://leanprover-community.github.io/contribute/index.html):

> "It is essential that everything in the master branch compiles without errors, and there are no sorrys."

> "A WIP (= work in progress) PR still needs some foundational work (e.g. maybe it contains sorrys) before getting reviewed."

**Key takeaway**: Mathlib has a strict **no-sorry policy** for merged contributions. Work-in-progress PRs with sorries are acceptable during development but cannot be merged.

### 2. Archive of Formal Proofs (AFP) Standards

From the [AFP submission guidelines](https://www.isa-afp.org/submission/):

> "No use of the commands `sorry` or `back`."

The AFP explicitly prohibits sorry statements. Submissions must be complete, verified proofs.

**Key takeaway**: For formal proof archives and libraries, **sorry is categorically disallowed**.

### 3. ITP/CPP Academic Publication Standards

From surveying ITP (Interactive Theorem Proving) and CPP (Certified Programs and Proofs) conference papers:

- **Complete proofs are strongly preferred** but not absolutely required
- **Well-documented partial results** with acknowledged limitations are acceptable
- The key criterion is **honest disclosure** of what is and isn't verified

From the [CPP conference](https://sigplan.org/Conferences/CPP/):
> "CPP spans areas of computer science, mathematics, logic, and education" with "rigorous, lightweight double-blind peer review."

Published examples show that formal verification papers often:
1. Prove key results fully
2. Document auxiliary lemmas that are admitted or assumed
3. Clearly state what aspects are verified vs. assumed

### 4. The Omega-Rule: A Fundamental Limitation

The omega-rule is well-documented in proof theory literature:

From [Sundholm's thesis on the omega-rule](https://www.researchgate.net/publication/327363833_Sundholm_Thesis_Proof_Theory_a_survey_of_the_omega-rule):
> "An important technique for investigating derivability in formal systems of arithmetic has been to embed such systems into semiformal systems with the omega-rule."

From [Hilbert's Program and The Omega-Rule](https://www.cmu.edu/dietrich/philosophy/docs/tech-reports/34_Ignjatovic.pdf):
> The omega-rule is inherently **infinitary** - it requires an infinite number of premises to derive a single conclusion.

From [recent philosophical work](https://academic.oup.com/pq/advance-article/doi/10.1093/pq/pqaf059/8209660):
> "It's generally thought that we finite beings can't follow infinitary rules of inference like the omega rule."

**Key insight**: The omega-rule limitation is not a gap in proof engineering - it is a **fundamental theoretical constraint** on finitary proof systems. No amount of clever tactics can eliminate the need for infinitely many witnesses.

### 5. Existing Formalizations of Modal Logic Truth Lemmas

From [CPP 2025 publication on Isabelle/HOL modal logic](https://dl.acm.org/doi/10.1145/3703595.3705882):
> "This framework formalizes the family of normal modal logics in Isabelle/HOL... defines an abstract canonical model and proves a truth lemma for any logic in the family."

From [Lean PAL+S5 formalization](https://github.com/ljt12138/Formalization-PAL):
> Complete proofs of completeness theorems via canonical model construction.

These existing formalizations typically avoid the omega-rule issue by:
1. Working with finitary modal logics (no temporal quantification over infinite time)
2. Using finite model constructions where applicable
3. Explicitly documenting when infinite models are assumed

### 6. Forward-Direction-Only Publications

From compiler correctness literature:
> "This work was proved correct only in the forward direction."
> "The correctness proof only holds for terminating evaluations... Leroy et al. present an approach using coinduction that allows them to avoid proving the backwards case."

**Precedent**: It is accepted practice to prove only the direction needed for the main theorem, especially when the reverse direction is either unnecessary or requires fundamentally different techniques.

## Analysis of Options

### Option A: Keep Biconditional with Documented Sorries

**Statement**:
```lean
theorem bmcs_truth_lemma : φ ∈ fam.mcs t ↔ bmcs_truth_at B fam t φ
```

**Pros**:
- Mathematically elegant, states the full classical result
- Documents where omega-saturation would be needed
- Allows future extension if omega-saturation is added

**Cons**:
- Contains `sorry` - cannot be submitted to Mathlib or AFP
- Academic reviewers may question the verification claim
- sorry taints dependent theorems (even if those theorems don't use that direction)
- Lean's `#print axioms` will show sorry for the entire development

### Option B: Provide Forward Direction Only (Recommended)

**Statement**:
```lean
theorem bmcs_truth_lemma_forward : φ ∈ fam.mcs t → bmcs_truth_at B fam t φ
-- OR
theorem mcs_membership_implies_truth : φ ∈ fam.mcs t → bmcs_truth_at B fam t φ
```

**Pros**:
- **Completely sorry-free** - can be submitted to Mathlib/AFP
- Suffices for completeness theorem (completeness only needs forward direction)
- Honest about what is actually verified
- Clean `#print axioms` output
- Standard practice in formal verification (prove what's needed)

**Cons**:
- Less elegant than the biconditional
- Doesn't capture the full classical truth lemma

### Option C: Hybrid Approach

**Statement**:
```lean
-- Main theorem (sorry-free)
theorem bmcs_truth_lemma_forward : φ ∈ fam.mcs t → bmcs_truth_at B fam t φ

-- Conjectured converse (with sorry, clearly marked)
theorem bmcs_truth_lemma_backward [OmegaSaturated fam] :
    bmcs_truth_at B fam t φ → φ ∈ fam.mcs t := sorry
```

**Pros**:
- Forward direction is clean and usable
- Backward direction is explicit about assumptions
- Documents the theoretical structure
- Type-level marker (`OmegaSaturated`) makes assumption explicit

**Cons**:
- Still has sorry in codebase
- More complex API surface
- Requires defining `OmegaSaturated` typeclass

## Recommendations

### Primary Recommendation: Option B

**Restructure the Truth Lemma to provide only the forward direction.**

Rationale:
1. The completeness theorems (the actual deliverables) only need the forward direction
2. A sorry-free development is significantly more valuable for publication
3. This is standard practice in formal verification
4. The omega-rule limitation is fundamental, not fixable

### Implementation Guidance

1. **Rename the current forward direction**:
   ```lean
   /-- If φ is in the MCS at time t, then φ is true there.
       This direction suffices for completeness. -/
   theorem mcs_membership_implies_truth (B : BMCS D) (fam : IndexedMCSFamily D)
       (hfam : fam ∈ B.families) (t : D) (φ : Formula) :
       φ ∈ fam.mcs t → bmcs_truth_at B fam t φ
   ```

2. **Update Completeness.lean** to use the new name (trivial change)

3. **Document the limitation** in the module docstring:
   ```lean
   /-!
   # BMCS Truth Lemma (Forward Direction)

   The classical truth lemma is a biconditional:
     φ ∈ mcs t ↔ truth_at t φ

   We prove only the forward direction, which suffices for completeness.

   The backward direction would require omega-saturation of the MCS construction,
   which is a fundamental limitation of finitary proof systems (the omega-rule).
   This is not a gap in our proof engineering but a theoretical boundary.
   -/
   ```

4. **Optionally keep backward direction as a conjecture** in a separate file:
   ```lean
   -- OmegaSaturation.lean
   /-- Conjecture: Truth implies membership, given omega-saturation.
       This is the converse of mcs_membership_implies_truth. -/
   axiom truth_implies_mcs_membership_conjecture (B : BMCS D) ... :
       bmcs_truth_at B fam t φ → φ ∈ fam.mcs t
   ```

### Publication Strategy

For academic publication:

1. **State clearly**: "We prove completeness using the forward direction of the truth lemma."
2. **Acknowledge the limitation**: "The converse direction would require omega-saturation."
3. **Emphasize the achievement**: "The key BOX case is fully verified, resolving the main completeness obstruction."
4. **Reference the omega-rule literature**: Sundholm, Buchholz, et al.

## Decisions

1. **Recommend Option B**: Forward-direction-only Truth Lemma
2. **Rationale**: Sorry-free codebase is more valuable than elegant but unverified biconditional
3. **Trade-off accepted**: Lose biconditional elegance; gain publishability

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| Reviewers expect biconditional | Document limitation prominently; cite omega-rule literature |
| Future work needs backward direction | Structure allows easy addition if omega-saturation added |
| Perceived as incomplete | Emphasize: completeness theorem is fully proven |
| Confusion about what's verified | Clear separation of verified vs. conjectured |

## References

### Mathlib/Lean Community
- [Mathlib Contribution Guide](https://leanprover-community.github.io/contribute/index.html)
- [Mathlib Style Guidelines](https://leanprover-community.github.io/contribute/style.html)
- [Mathematics in Lean](https://leanprover-community.github.io/mathematics_in_lean/C01_Introduction.html)

### Archive of Formal Proofs
- [AFP Submission Guidelines](https://www.isa-afp.org/submission/)

### Academic Conferences
- [CPP Conference](https://sigplan.org/Conferences/CPP/)
- [ITP 2024](https://drops.dagstuhl.de/entities/document/10.4230/LIPIcs.ITP.2024.28)

### Omega-Rule Literature
- [Sundholm: A survey of the omega-rule](https://www.researchgate.net/publication/327363833_Sundholm_Thesis_Proof_Theory_a_survey_of_the_omega-rule)
- [Hilbert's Program and The Omega-Rule (CMU)](https://www.cmu.edu/dietrich/philosophy/docs/tech-reports/34_Ignjatovic.pdf)
- [Can we follow the omega rule?](https://academic.oup.com/pq/advance-article/doi/10.1093/pq/pqaf059/8209660)
- [Infinitary Logic (Wikipedia)](https://en.wikipedia.org/wiki/Infinitary_logic)

### Modal Logic Formalizations
- [Isabelle/HOL Framework for Synthetic Completeness Proofs (CPP 2025)](https://dl.acm.org/doi/10.1145/3703595.3705882)
- [Lean PAL+S5 Formalization](https://github.com/ljt12138/Formalization-PAL)

## Appendix

### Search Queries Used
1. "Lean 4 Mathlib sorry best practices publication guidelines 2026"
2. "Mathlib contribution guidelines sorry admitted lemmas"
3. "Archive of Formal Proofs submission guidelines sorry admitted axiom requirements"
4. "omega rule proof theory infinitary logic finitary limitations"
5. "Lean formal proof publication peer review ITP CPP conference standards"
6. "truth lemma modal logic formal verification Lean Coq Isabelle publication"

### Codebase Files Examined
- `Theories/Bimodal/Metalogic/Bundle/TruthLemma.lean` - Main truth lemma implementation
- `Theories/Bimodal/Metalogic/Bundle/Completeness.lean` - Completeness theorems (uses forward direction only)
