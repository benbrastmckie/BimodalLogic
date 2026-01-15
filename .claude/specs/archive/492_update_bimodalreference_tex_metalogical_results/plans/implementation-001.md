# Implementation Plan: Update BimodalReference.tex Metalogical Results

- **Task**: 492 - Update BimodalReference.tex with metalogical results
- **Status**: [NOT STARTED]
- **Effort**: 2.5 hours
- **Priority**: Medium
- **Dependencies**: Task 450 (completeness theorems), Task 473 (semantic approach), Task 487 (Boneyard)
- **Research Inputs**: .claude/specs/492_update_bimodalreference_tex_metalogical_results/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: latex
- **Lean Intent**: false

## Overview

The BimodalReference.tex documentation contains outdated information about the metalogical status of TM bimodal logic. The core completeness theorem (`semantic_weak_completeness`) is now fully proven via the semantic canonical model approach, yet the documentation still describes completeness as "axiomatized" or "pending." This plan updates four LaTeX files to accurately reflect the current state: completeness is established, the semantic approach provides the foundation, and specific theorems (Lindenbaum lemma, truth lemma, weak completeness, provability-validity equivalence) are proven.

**Focus**: Use timeless, present-tense language throughout. Avoid historical phrases like "now proven" or "recently established" - instead state what is the case (e.g., "The theorem states..." or "The proof establishes...").

### Research Integration

Research report research-001.md identifies:
- Four files requiring updates (BimodalReference.tex, 00-Introduction.tex, 04-Metalogic.tex, 06-Notes.tex)
- Specific outdated claims with recommended replacements
- Implementation status tables requiring correction
- A new proof strategy section to add

## Goals & Non-Goals

**Goals**:
- Update abstract and introduction to reflect completeness status accurately
- Rewrite the completeness section in 04-Metalogic.tex with correct theorem status
- Add proof strategy guidance explaining the semantic approach
- Update all implementation status tables to match actual Lean proofs
- Use timeless, present-tense language throughout

**Non-Goals**:
- Documenting the deprecated syntactic approach in detail (archived in Boneyard)
- Adding new mathematical content beyond what is proven
- Modifying the Lean code itself
- Adding content about future work or pending developments

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Over-claiming completeness (ignoring remaining sorries) | Medium | Medium | Be precise: note bridge sorries are type-level, not logical gaps |
| Inconsistent theorem names between LaTeX and Lean | Low | Medium | Cross-reference exact Lean names from research report |
| LaTeX build failures from syntax errors | Low | Low | Test build after each phase |
| Historical language creeping in | Medium | Medium | Review all changes for tense; use "is" not "was" or "now" |

## Implementation Phases

### Phase 1: Abstract and Introduction Updates [COMPLETED]

**Goal**: Update BimodalReference.tex abstract and 00-Introduction.tex to reflect that completeness is established.

**Tasks**:
- [ ] Edit BimodalReference.tex abstract: replace "Completeness infrastructure is in place but the core lemmas remain axiomatized" with accurate present-tense description
- [ ] Edit 00-Introduction.tex Project Structure section: replace "Soundness and deduction complete; completeness pending" with "Soundness, deduction, and semantic completeness are established"
- [ ] Verify no historical language ("now", "recently", "was proven") in edited text

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/latex/BimodalReference.tex` - Abstract section
- `Theories/Bimodal/latex/subfiles/00-Introduction.tex` - Project Structure section

**Verification**:
- Run `latexmk -pdf BimodalReference.tex` - compiles without error
- Grep for "pending", "axiomatized" in modified sections - none found
- Grep for "now proven", "recently" - none found

---

### Phase 2: Completeness Section Rewrite [COMPLETED]

**Goal**: Restructure and update the completeness subsection in 04-Metalogic.tex with accurate theorem status.

**Tasks**:
- [ ] Locate completeness section (lines ~77-108 per research)
- [ ] Update Lindenbaum lemma description: mark as proven (`set_lindenbaum`)
- [ ] Add semantic world state approach description (SemanticWorldState quotient construction)
- [ ] Update truth lemma: mark as proven (`semantic_truth_lemma_v2`)
- [ ] Update weak completeness: mark as proven (`semantic_weak_completeness`)
- [ ] Update strong completeness: note proven with bridge sorries (`main_strong_completeness`)
- [ ] Add finite model property statement (`finite_model_property`)
- [ ] Use present tense: "The Lindenbaum lemma establishes..." not "We have proven..."

**Timing**: 45 minutes

**Files to modify**:
- `Theories/Bimodal/latex/subfiles/04-Metalogic.tex` - Completeness subsection

**Verification**:
- Section compiles without LaTeX errors
- Each major theorem has status (Proven/Proven*/Statement) and Lean name
- No "Axiomatized" markers remain for proven theorems
- No temporal language in descriptions

---

### Phase 3: Proof Strategy Section [COMPLETED]

**Goal**: Add a new subsection explaining the semantic approach and why it succeeds.

**Tasks**:
- [ ] Add new subsection "Proof Strategy" after completeness or integrate into completeness section
- [ ] Explain semantic world state construction: equivalence classes of (history, time) pairs
- [ ] Explain key insight: truth lemma becomes straightforward when worlds are quotients
- [ ] Note that syntactic approach (negation-completeness) is superseded (code archived in Boneyard)
- [ ] Keep language descriptive and timeless: "The semantic approach defines..." not "We discovered..."

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/latex/subfiles/04-Metalogic.tex` - New subsection or expanded completeness section

**Verification**:
- Section compiles
- Explains quotient construction clearly
- References SemanticWorldState, SemanticCanonicalFrame
- No first-person narrative or temporal markers

---

### Phase 4: Implementation Status Tables [COMPLETED]

**Goal**: Update all implementation status tables to reflect actual Lean proof status.

**Tasks**:
- [ ] Update 04-Metalogic.tex table (lines ~196-213):
  - Lindenbaum Lemma: Proven (set_lindenbaum)
  - Canonical Frame: Proven (SemanticCanonicalFrame)
  - Truth Lemma: Proven (semantic_truth_lemma_v2)
  - Weak Completeness: Proven (semantic_weak_completeness)
  - Strong Completeness: Proven* (main_strong_completeness, *bridge sorries)
  - Provable iff Valid: Proven (main_provable_iff_valid)
  - Finite Model Property: Statement (finite_model_property)
  - Decidability: Soundness (decide_sound)
- [ ] Update 06-Notes.tex implementation status:
  - Change "Completeness: Infrastructure Only" to "Completeness: Proven (Semantic)"
  - Update or remove "70-90 hours" estimate (work is substantially done)
  - Add note on representation theory contribution
- [ ] Verify table formatting consistent

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/latex/subfiles/04-Metalogic.tex` - Implementation status table
- `Theories/Bimodal/latex/subfiles/06-Notes.tex` - Implementation status, completeness paragraph

**Verification**:
- Tables compile correctly
- All proven theorems marked "Proven" not "Axiomatized"
- Lean theorem names match codebase exactly

---

### Phase 5: Build Verification and Final Review [COMPLETED]

**Goal**: Verify complete document builds and review all changes for consistency.

**Tasks**:
- [ ] Run full LaTeX build: `latexmk -pdf BimodalReference.tex`
- [ ] Check for overfull/underfull hbox warnings
- [ ] Verify cross-references resolve
- [ ] Final review: search for temporal language ("now", "recently", "was proven", "have been")
- [ ] Final review: search for remaining "axiomatized" or "pending" markers that should be "proven"

**Timing**: 15 minutes

**Files to modify**:
- None (verification only)

**Verification**:
- PDF generates without errors
- No critical LaTeX warnings
- No temporal language in metalogic sections
- Consistent terminology throughout

## Testing & Validation

- [ ] `latexmk -pdf BimodalReference.tex` builds successfully
- [ ] No "Axiomatized" status for proven theorems (Lindenbaum, Truth Lemma, Weak Completeness)
- [ ] All Lean theorem names match actual codebase names
- [ ] No temporal language ("now", "recently", "was") in modified sections
- [ ] Proof strategy section clearly explains semantic quotient approach

## Artifacts & Outputs

- `plans/implementation-001.md` (this file)
- `summaries/implementation-summary-YYYYMMDD.md` (upon completion)
- Modified LaTeX files:
  - `Theories/Bimodal/latex/BimodalReference.tex`
  - `Theories/Bimodal/latex/subfiles/00-Introduction.tex`
  - `Theories/Bimodal/latex/subfiles/04-Metalogic.tex`
  - `Theories/Bimodal/latex/subfiles/06-Notes.tex`

## Rollback/Contingency

All modified files are under git version control. If changes introduce errors:
1. Use `git diff` to identify problematic changes
2. Use `git checkout -- <file>` to revert individual files
3. LaTeX errors are typically localized and can be fixed incrementally
4. No destructive changes are planned; this is documentation update only
