# Implementation Plan: Task #897

- **Task**: 897 - fix_tags_constitutive_foundation_latex
- **Status**: [NOT STARTED]
- **Effort**: 2 hours
- **Dependencies**: Task 896 completed (notation-conventions.md documented)
- **Research Inputs**: specs/897_fix_tags_constitutive_foundation_latex/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: latex
- **Lean Intent**: false

## Overview

Fix five FIX:/NOTE: tags in `02-ConstitutiveFoundation.tex` that relate to improving the precision and completeness of the semantic interpretation formalism. The changes involve: (1) adding `\ext` macro and renaming `\sem` usages, (2) defining the `\interp{\cdot}` sentence interpretation function, (3) adding a remark about identity sentence propositions, and (4) expanding Remark 3.22 with formal homomorphism definition and precise language.

### Research Integration

Research report (research-001.md) provides:
- Confirmed line numbers for all 5 tags
- Detailed recommendations for each fix
- Dependency analysis showing macro rename should precede content additions
- Full LaTeX code snippets for the new remark and definition

## Goals & Non-Goals

**Goals**:
- Add `\ext` macro to logos-notation.sty for term extensions
- Replace all `\sem{...}` with `\ext{...}` in term extension contexts
- Define `\interp{\cdot}` sentence interpretation function before Remark 3.22
- Add remark explaining propositions expressed by identity sentences
- Extend Remark 3.22 to include `\equiv`, `\forall`, `\lambda`, `F(t_1,...,t_n)`
- Provide formal definition of the homomorphism from syntax to semantics
- Replace vague "directly mirrors" with precise mathematical language
- Remove all 5 FIX:/NOTE: comment tags after implementing fixes
- Verify LaTeX compiles without errors

**Non-Goals**:
- Refactoring other files that use `\sem` (out of scope for this task)
- Adding cross-references to Lean implementations (separate task if needed)
- Modifying the notation-conventions.md documentation (already complete from task 896)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `\ext` macro conflicts with existing package | M | L | Check for conflicts before adding; macro uses common `\llbracket ... \rrbracket` pattern |
| Definition numbering shifts | L | M | Use `\label` consistently; references via `\Cref` will auto-update |
| Quantifier interpretation clause complexity | M | M | Reference existing verification/falsification definitions rather than repeating |
| LaTeX compilation errors | M | L | Compile after each phase; incremental verification |

## Implementation Phases

### Phase 1: Add \ext Macro and Rename \sem Usages [NOT STARTED]

- **Dependencies:** None
- **Goal**: Add the `\ext` macro for term extensions and update all term extension usages from `\sem` to `\ext` in 02-ConstitutiveFoundation.tex

**Tasks**:
- [ ] Add `\ext` macro definition to logos-notation.sty (after line 210, alongside `\sem`)
- [ ] Add deprecation comment for `\sem` macro
- [ ] Replace `\sem{\cdot}` with `\ext{\cdot}` in Definition 3.8 (term extension, line 315)
- [ ] Replace `\sem{v}` with `\ext{v}` in Definition 3.8 (line 317)
- [ ] Replace `\sem{f(t_1, ...)}` with `\ext{f(t_1, ...)}` in Definition 3.8 (line 318)
- [ ] Replace `\sem{t_i}` with `\ext{t_i}` in Definition 3.8 (line 318)
- [ ] Replace `\sem{...}` with `\ext{...}` in Definition 3.11 (atomic formula, lines 361-362)
- [ ] Replace `\sem{...}` with `\ext{...}` in Definition 3.12 (lambda, lines 370-371)
- [ ] Remove NOTE: tag at line 585

**Timing**: 30 minutes

**Files to modify**:
- `/home/benjamin/Projects/Logos/Theory/latex/assets/logos-notation.sty` - Add `\ext` macro
- `/home/benjamin/Projects/Logos/Theory/latex/subfiles/02-ConstitutiveFoundation.tex` - Replace `\sem` with `\ext` in term contexts

**Verification**:
- LaTeX compiles without errors
- `\ext` appears in term extension contexts
- `\sem` deprecated but still defined for backward compatibility

---

### Phase 2: Define Sentence Interpretation Function [NOT STARTED]

- **Dependencies:** Phase 1
- **Goal**: Add formal definition of `\interp{\cdot}^\assignment_\model` as the sentence interpretation function, placed after Definition 3.21 and before Remark 3.22

**Tasks**:
- [ ] Create new definition block "Sentence Interpretation" after line 581 (after Definition 3.21)
- [ ] Define `\interp{\cdot}^\assignment_\model : \sent \to \props` as the interpretation function
- [ ] Include clauses for:
  - Atomic formulas `F(t_1, ..., t_n)` - map to bilateral proposition via verifier/falsifier sets
  - Lambda application `(\lambda v.\metaA)(t)` - substitution in interpretation
  - Universal quantification `\forall \metaA(v)` - map via verification/falsification clauses
  - Constants `\top`, `\bot` - map to extremal propositions
  - Negation `\neg\metaA` - propositional negation
  - Conjunction `\metaA \land \metaB` - propositional conjunction
  - Disjunction `\metaA \lor \metaB` - propositional disjunction
  - Identity `\metaA \equiv \metaB` - yields `\fal_\props` if equal, `\bot_\props` otherwise
- [ ] Reference `\ext{\cdot}` for term extensions within the definition
- [ ] Remove FIX: tag at line 583 (include \equiv clause) - addressed by this definition
- [ ] Remove NOTE: tag at line 585 (already removed in Phase 1)

**Timing**: 45 minutes

**Files to modify**:
- `/home/benjamin/Projects/Logos/Theory/latex/subfiles/02-ConstitutiveFoundation.tex` - Add sentence interpretation definition

**Verification**:
- New definition compiles without errors
- Definition appears before Remark 3.22
- All sentence forms covered in the definition

---

### Phase 3: Add Identity Sentence Remark [NOT STARTED]

- **Dependencies:** Phase 1
- **Goal**: Add a remark explaining that identity sentences express only trivial propositions (either `\bot` or `\fal`)

**Tasks**:
- [ ] Add new remark block after Definition 3.16 (line 494, after propositional identity definition)
- [ ] Explain that:
  - If `\metaA \equiv \metaB` holds (same verifiers/falsifiers), proposition is `\fal` (verified by null state)
  - If `\metaA \equiv \metaB` fails (different verifiers/falsifiers), proposition is `\bot` (falsified by null state)
  - This triviality reflects that identity claims assert nothing contingent
- [ ] Reference the extremal propositions from Definition 3.21
- [ ] Remove FIX: tag at line 496

**Timing**: 20 minutes

**Files to modify**:
- `/home/benjamin/Projects/Logos/Theory/latex/subfiles/02-ConstitutiveFoundation.tex` - Add remark after identity definition

**Verification**:
- Remark compiles without errors
- Explanation is mathematically precise
- FIX tag removed

---

### Phase 4: Update Remark 3.22 with Formal Homomorphism [NOT STARTED]

- **Dependencies:** Phase 2
- **Goal**: Expand Remark 3.22 to include formal homomorphism statement, additional operators, and precise language

**Tasks**:
- [ ] Update bullet list in Remark 3.22 (lines 591-596) to use `\interp{\cdot}` instead of `\sem{...}`
- [ ] Add clauses for:
  - `\interp{\metaA \equiv \metaB}` - identity interpretation
  - `\interp{F(t_1, ..., t_n)}` - atomic formula interpretation
  - `\interp{(\lambda v.\metaA)(t)}` - lambda interpretation
  - `\interp{\forall \metaA(v)}` - universal interpretation
- [ ] Add formal homomorphism statement after the bullet list:
  - Define `\interp{\cdot}` as homomorphism from `(\sent, \neg, \land, \lor, \top, \bot)` to `(\props, \neg, \land, \lor, \top_\props, \bot_\props)`
  - Explain structure preservation property
- [ ] Replace "directly mirrors" (line 601) with precise language:
  - "establishes a structure-preserving embedding from the syntactic algebra of sentences into the semantic algebra of propositions, ensuring that logical equivalences among sentences are reflected as identities among propositions"
- [ ] Remove FIX: tags at lines 599 and 600

**Timing**: 25 minutes

**Files to modify**:
- `/home/benjamin/Projects/Logos/Theory/latex/subfiles/02-ConstitutiveFoundation.tex` - Update Remark 3.22

**Verification**:
- Remark compiles without errors
- All operators covered
- Formal homomorphism clearly stated
- Vague language replaced with precise mathematical terminology
- All FIX tags in remark removed

---

### Phase 5: Final Verification and Cleanup [NOT STARTED]

- **Dependencies:** Phase 3, Phase 4
- **Goal**: Verify all tags removed, document compiles, and changes are consistent

**Tasks**:
- [ ] Run `grep -n "FIX:\|NOTE:" 02-ConstitutiveFoundation.tex` to confirm no tags remain in fixed locations
- [ ] Compile full document with `pdflatex`
- [ ] Review generated PDF for rendering issues
- [ ] Verify cross-references resolve correctly
- [ ] Check notation-conventions.md alignment (no changes needed, but verify consistency)

**Timing**: 15 minutes

**Files to modify**:
- None (verification only)

**Verification**:
- No FIX:/NOTE: tags at lines 496, 583, 585, 599, 600
- Document compiles without errors
- PDF renders correctly
- All new definitions/remarks properly numbered

## Testing & Validation

- [ ] LaTeX compiles without errors after each phase
- [ ] All 5 FIX:/NOTE: tags removed from target lines
- [ ] `\ext` macro works correctly in all term extension contexts
- [ ] `\interp{\cdot}` definition is well-formed and placed correctly
- [ ] Remark about identity propositions is mathematically accurate
- [ ] Homomorphism in Remark 3.22 is formally stated
- [ ] No "directly mirrors" phrase remains (replaced with precise language)
- [ ] Document cross-references resolve correctly

## Artifacts & Outputs

- Modified: `/home/benjamin/Projects/Logos/Theory/latex/assets/logos-notation.sty` (add `\ext` macro)
- Modified: `/home/benjamin/Projects/Logos/Theory/latex/subfiles/02-ConstitutiveFoundation.tex` (all 5 fixes)
- This plan: `specs/897_fix_tags_constitutive_foundation_latex/plans/implementation-001.md`
- Summary (after completion): `specs/897_fix_tags_constitutive_foundation_latex/summaries/implementation-summary-YYYYMMDD.md`

## Rollback/Contingency

If implementation causes issues:
1. Revert logo-notation.sty changes (restore original `\sem` without `\ext`)
2. Revert 02-ConstitutiveFoundation.tex to pre-implementation state via git
3. Restore FIX:/NOTE: tags if partial work needs to be abandoned
4. Document blocking issues for future attempt
