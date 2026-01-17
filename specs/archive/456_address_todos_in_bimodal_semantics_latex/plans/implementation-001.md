# Implementation Plan: Task #456

- **Task**: 456 - Address TODOs in Bimodal Semantics LaTeX
- **Status**: [COMPLETED]
- **Effort**: 4 hours
- **Priority**: normal
- **Dependencies**: None
- **Research Inputs**: specs/456_address_todos_in_bimodal_semantics_latex/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: latex
- **Lean Intent**: false

## Overview

This plan addresses 20 TODO comments in `02-Semantics.tex` by organizing changes into 6 phases ordered to minimize conflicts.
The approach prioritizes structural changes first (reorganizing definitions), then terminology/notation changes, and finally cleanup of Lean-specific tables.
All changes align with the JPL paper notation and maintain semantic linefeeds per `.claude/rules/latex.md`.

### Research Integration

Key findings from research-001.md integrated:
- Use "sentence letters" consistently (never "atomic propositions")
- Use lowercase `x`, `y`, `z` for time variables
- Use paper's `\tau \approx_y^x \sigma` time-shift notation
- Remove Lean implementation tables
- Use natural sentences instead of em-dashes
- Specify types explicitly in quasi-formal style

## Goals & Non-Goals

**Goals**:
- Address all 20 TODO comments in `02-Semantics.tex`
- Align notation with JPL paper (line 862, 868, 889-898, 1877-1878)
- Maintain consistent type notation throughout
- Follow semantic linefeeds per latex.md rules
- Ensure document compiles without errors

**Non-Goals**:
- Modifying other subfiles (01-Syntax.tex, etc.)
- Adding new theorems or proofs not requested
- Changing Lean implementation to match LaTeX (only verify alignment exists)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Breaking LaTeX compilation | High | Medium | Test compile after each phase |
| Inconsistent notation across sections | Medium | Low | Apply terminology changes globally in dedicated phase |
| Definition changes that affect later theorems | Medium | Low | Do structural changes early, review theorem dependencies |
| Missing TODO | Low | Low | Cross-check against research report's 20-item list |

## Implementation Phases

### Phase 1: Task Frame Restructuring [COMPLETED]

**Goal**: Reorganize Task Frame definition with primitives table (TODOs 1-2)

**TODOs addressed**:
- TODO 1 (line 11): Restructure Task Frame with primitives table before definition
- TODO 2 (line 31): Remove Lean field table for Task Frame

**Timing**: 45 minutes

**Files to modify**:
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/latex/subfiles/02-Semantics.tex` - Task Frames subsection (lines 6-44)

**Steps**:
1. Add a primitives table before Definition [Task Frame] introducing:
   - $\worldstate$ : Type (world states)
   - $T$ : Type (temporal durations with ordered abelian group structure)
   - $w \taskto{x} u$ : $\worldstate \to T \to \worldstate \to \text{Prop}$ (task relation)
2. Revise Definition [Task Frame] to reference the primitives table, stating the type signature and then constraints with explicit types in quantifiers
3. Remove the Lean field table (lines 33-44)
4. Test compile to verify no errors

**Verification**:
- Definition uses types from primitives table
- No Lean-specific content in Task Frame section
- Document compiles successfully

---

### Phase 2: World History Restructuring [COMPLETED]

**Goal**: Merge definitions and remove Lean table (TODOs 3-7)

**TODOs addressed**:
- TODO 3 (line 59): Replace "respects the task relation" terminology (fold into definition)
- TODO 4 (line 69): Replace dashes with natural sentences
- TODO 5 (line 71): Specify type of world history explicitly
- TODO 6 (line 73): Fold "Respects Task" definition into World History definition
- TODO 7 (line 85): Remove Lean field table for World History

**Timing**: 45 minutes

**Files to modify**:
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/latex/subfiles/02-Semantics.tex` - World Histories subsection (lines 46-98)

**Steps**:
1. Keep Definition [Convex Domain] as is (lines 51-57)
2. Remove Definition [Respects Task] (lines 61-67) - content will be folded into World History
3. Rewrite Definition [World History] to:
   - State the type explicitly: $\tau : (t : T) \to \domain(t) \to \worldstate$
   - Use natural sentences instead of em-dashes
   - Include the task-respecting constraint directly (matching JPL paper line 868)
4. Remove the Lean field table (lines 87-98)
5. Test compile

**Verification**:
- Definition follows JPL paper line 868 structure
- No separate "Respects Task" definition
- No Lean-specific content in World History section
- Document compiles successfully

---

### Phase 3: Task Models and Propositions [COMPLETED]

**Goal**: Update terminology and define propositions (TODOs 8-11)

**TODOs addressed**:
- TODO 8 (line 102): Use "sentence letters" not "atomic propositions"
- TODO 9 (line 106): Define propositions as sets of world states
- TODO 10 (line 108): Replace dashes with natural sentences
- TODO 11 (line 113): Specify types explicitly in Task Model definition

**Timing**: 30 minutes

**Files to modify**:
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/latex/subfiles/02-Semantics.tex` - Task Models subsection (lines 100-122)

**Steps**:
1. Replace all instances of "atomic proposition(s)" with "sentence letter(s)" in this section:
   - Line 104: "assigns truth values to sentence letters at world states"
   - Line 110: Update terminology
   - Line 120: "assigns truth values to sentence letters at each world state"
2. Add a sentence defining propositions: "Propositions are subsets of $\worldstate$ representing instantaneous ways for the system to be."
3. Rewrite the explanatory text (around line 110) without em-dashes, using natural sentences
4. Rewrite Definition [Task Model] with explicit types:
   - $I : \worldstate \to \text{String} \to \text{Prop}$
   - Clarify that $I(w, p)$ indicates sentence letter $p$ is true at world state $w$
5. Test compile

**Verification**:
- No occurrences of "atomic proposition" in file
- Propositions defined as sets of world states
- Task Model definition has explicit types
- Document compiles successfully

---

### Phase 4: Truth Conditions and Time Variables [COMPLETED]

**Goal**: Update time variable notation throughout truth conditions (TODO 12)

**TODOs addressed**:
- TODO 12 (line 126): Use `x`, `y`, `z` for times; times not restricted to domain

**Timing**: 30 minutes

**Files to modify**:
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/latex/subfiles/02-Semantics.tex` - Truth Conditions subsection (lines 124-150)

**Steps**:
1. Update introductory text (lines 128-129):
   - Change "time $t$" to "time $x$"
   - Change "time $t$ within that history's domain" to "time $x : T$" (not restricted to domain)
2. Update Definition [Truth at a Point] (lines 131-145):
   - Change "time $t \in \domain(\tau)$" to "time $x : T$"
   - Change all $t$ to $x$ in the definition
   - Change all $s$ to $y$ in the tense operator clauses
   - Update tense operators to quantify over ALL times in $T$:
     - $\allpast$: "for all $y : T$ where $y < x$"
     - $\allfuture$: "for all $y : T$ where $x < y$"
3. Update follow-up text (lines 147-149) with new variable names
4. Test compile

**Verification**:
- All time variables use `x`, `y`, `z` convention
- Tense operators quantify over all times in $T$, not just domain
- Document compiles successfully

---

### Phase 5: Time-Shift Notation [COMPLETED]

**Goal**: Replace \leanTimeShift with paper notation (TODOs 13-17)

**TODOs addressed**:
- TODO 13 (line 154): Explain time-shift motivation (perpetuity theorems)
- TODO 14 (line 159): Use consistent type notation
- TODO 15 (line 160): Use `x` for duration offset, not Greek letters
- TODO 16 (line 163): Use paper's `\tau \approx_y^x \sigma` notation
- TODO 17 (line 176): Replace \leanTimeShift in theorems

**Timing**: 45 minutes

**Files to modify**:
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/latex/subfiles/02-Semantics.tex` - Time-Shift subsection (lines 152-184)

**Steps**:
1. Rewrite motivational text (lines 154-157) to explain perpetuity theorems:
   - Explain P1: $\nec\varphi \imp \always\varphi$ (necessary implies always)
   - Explain P2: $\sometimes\varphi \imp \poss\varphi$ (sometimes implies possible)
   - Reference JPL paper line 436 for intuitive justification
2. Rewrite Definition [Time-Shift] (lines 165-171):
   - Use paper notation: $\tau \approx_y^x \sigma$ (tau time-shifted from y to x equals sigma)
   - Use typed form: "For $\tau, \sigma \in \histories_{\taskframe}$ and $x, y : T$"
   - Define via order automorphism per JPL paper line 1877-1878
3. Rewrite preservation theorems (lines 178-184):
   - Replace $\leanTimeShift(\tau, \Delta)$ with paper notation
   - State theorems using $\tau \approx_y^x \sigma$ relation
4. Test compile

**Verification**:
- No occurrences of $\leanTimeShift$ in file
- Time-shift notation matches JPL paper def:time-shift-histories
- Perpetuity theorem motivation included
- Document compiles successfully

---

### Phase 6: Logical Consequence and Validity [COMPLETED]

**Goal**: Restate definitions with types and define validity (TODOs 18-20)

**TODOs addressed**:
- TODO 18 (line 190): Restate logical consequence with types
- TODO 19 (line 196): Define validity as consequence of empty set
- TODO 20 (line 198): Restate satisfiability with types

**Timing**: 30 minutes

**Files to modify**:
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/latex/subfiles/02-Semantics.tex` - Logical Consequence and Validity subsection (lines 186-207)

**Steps**:
1. Rewrite Definition [Logical Consequence] (lines 192-194):
   - Add explicit types in natural language form
   - "for every temporal type $T : \text{Type}$, frame $\taskframe : \text{TaskFrame}(T)$, model $\model : \text{TaskModel}(\taskframe)$, history $\tau \in \histories_{\taskframe}$, and time $x : T$"
   - Fix typo: "formals" -> "formulas"
2. Add new Definition [Validity] after logical consequence:
   - Define validity as consequence from empty set: $\models \varphi$ iff $\varnothing \models \varphi$
   - Note equivalence: true at every model-history-time triple
3. Rewrite Definition [Satisfiability] (lines 200-202):
   - Add explicit types in natural language form
   - Use $\models$ notation: "such that $\model, \tau, x \models \psi$ for all $\psi \in \context$"
4. Update time variables from $t$ to $x$ for consistency with Phase 4
5. Test compile

**Verification**:
- All definitions have explicit types
- Validity defined as consequence of empty set
- Satisfiability uses $\models$ notation
- Document compiles successfully

---

## Testing & Validation

- [ ] After each phase: `pdflatex 02-Semantics.tex` compiles without errors
- [ ] All 20 TODO comments addressed (search for `% TODO:` returns zero matches)
- [ ] No occurrences of "atomic proposition" (search confirms "sentence letters" used)
- [ ] No occurrences of `\leanTimeShift` (paper notation used instead)
- [ ] Time variables consistently use `x`, `y`, `z` in Truth Conditions and later sections
- [ ] Semantic linefeeds maintained (one sentence per line)
- [ ] Final full document build succeeds

## Artifacts & Outputs

- Modified: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/latex/subfiles/02-Semantics.tex`
- Summary: `specs/456_address_todos_in_bimodal_semantics_latex/summaries/implementation-summary-{DATE}.md` (on completion)

## Rollback/Contingency

If implementation introduces errors that cannot be resolved:
1. Revert to git HEAD for `02-Semantics.tex`
2. Apply phases one at a time with testing between each
3. If specific TODO proves problematic, document in summary and proceed with others
4. Final document should compile even if some TODOs remain partially addressed
