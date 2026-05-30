# Implementation Plan: Task #216

- **Task**: 216 - Natural-language paraphrase augmentation for bmlogic-bench
- **Status**: [NOT STARTED]
- **Effort**: 10 hours
- **Dependencies**: None
- **Research Inputs**: specs/216_nl_paraphrase_augmentation/reports/01_team-research.md
- **Artifacts**: plans/01_nl-paraphrase-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: general
- **Lean Intent**: false

## Overview

Add natural-language paraphrase fields (`nl_paraphrase`, `nl_paraphrase_method`) to all 727 bmlogic-bench records using a hybrid approach: a recursive Python AST-walker with derived-operator detection handles depth <= 2 formulas (635 records, 87.3%) rule-based, while LLM-assisted generation with human verification handles depth >= 3 (92 records, 12.7%). The implementation lives entirely in Python post-processing scripts within `data/scripts/`, producing an updated `bmlogic-bench.jsonl` with backward-compatible optional fields.

### Research Integration

Key findings from team research (4 teammates):
- **AST structure**: 6 primitive tags (`atom`, `bot`, `imp`, `box`, `untl`, `snce`) with derived operators (negation, eventually, globally, etc.) encoded as patterns
- **Derived operator detection is mandatory**: 364 negation patterns, 53 eventually patterns, 63 top patterns exist; without detection, rule-based output is incomprehensible
- **Schema**: Single `nl_paraphrase` + `nl_paraphrase_method` (Option A from research) for v1
- **Prior art**: No existing dataset covers S5 modal + temporal Until/Since -- this is a novel contribution
- **Critical design decisions**: Until/Since phrasing, variable naming (use abstract p/q/r), falsum handling

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROADMAP.md found.

## Goals & Non-Goals

**Goals**:
- All 727 bmlogic-bench records have non-null `nl_paraphrase` field
- Rule-based paraphrases for depth <= 2 are grammatically correct and semantically faithful
- Depth >= 3 records have LLM-assisted paraphrases with quality spot-checks
- Generation code published at `data/scripts/generate_paraphrases.py`
- `nl_paraphrase_method` field records generation method per record
- Backward-compatible: fields are optional, existing tools unaffected

**Non-Goals**:
- Multiple paraphrases per formula (future extension)
- NL-to-AST round-trip verification parser
- Internationalization or multilingual paraphrases
- Changes to Lean source code or build pipeline
- Extension to bmlogic-c5/c7 datasets (Phase 2 per strategic plan)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Until/Since phrasing ambiguity (English "until" is semantically different from formal U) | H | H | Choose explicit phrasing with glossary comment; prioritize precision over naturalness |
| Derived operator detection misses edge cases | M | M | Comprehensive test suite with all 8+ derived operator patterns; validate against formula_str |
| High-impCount depth-2 records produce unreadable NL (~51 records with impCount >= 5) | M | H | Flag in quality review; escalate to LLM-assisted if unreadable |
| LLM-assisted generation introduces semantic errors | H | M | Human review of all 92 depth >= 3 records; cross-check with formula_str |
| Grammar checker false positives on formal language | L | M | Use LanguageTool with custom dictionary for logical terms |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 3, 4 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Derived Operator Detector and Template Table [IN PROGRESS]

**Goal**: Build the pattern-matching infrastructure that recognizes derived operators from primitive AST encodings and define the NL template table for all operators.

**Tasks**:
- [ ] Create `data/scripts/generate_paraphrases.py` with module structure and CLI entrypoint
- [ ] Implement AST loading from JSONL (parse `formula_ast` field)
- [ ] Implement derived operator detection patterns:
  - Negation: `imp(phi, bot)` -> "it is not the case that phi"
  - Top: `imp(bot, bot)` -> "a tautology" (or suppress in context)
  - Conjunction: `imp(imp(phi, imp(psi, bot)), bot)` -> "phi and psi"
  - Disjunction: `imp(imp(phi, bot), psi)` -> "phi or psi"
  - Biconditional: conjunction of two implications
  - Diamond (possibility): `imp(imp(box(imp(phi, bot)), bot), _)` pattern -> "it is possible that phi"
  - Eventually (F): `untl(bot_to_bot, phi)` where guard is tautology -> "eventually phi"
  - Globally (G): negation of eventually of negation -> "always phi"
  - Past (P): `snce(bot_to_bot, phi)` -> "at some past time phi"
  - Historically (H): negation of past of negation -> "at all past times phi"
  - Next (X): `untl(bot, phi)` -> "at the next moment phi"
  - Yesterday (Y): `snce(bot, phi)` -> "at the previous moment phi"
- [ ] Define NL template table mapping each primitive and derived operator to English templates
- [ ] Define Until/Since phrasing: "phi until psi" = "psi will hold at some future time, and phi holds at every intermediate time" (with configurable short form "phi holds until psi becomes true")
- [ ] Define variable naming convention: use atom names directly (p, q, r) as "proposition p", "proposition q"
- [ ] Define falsum handling: render as "a contradiction" in isolation, suppress in operator-detection contexts
- [ ] Write unit tests for derived operator detection (at least 20 test cases covering all patterns)
- [ ] Validate detection against full dataset: count how many records have each derived operator

**Timing**: 2.5 hours

**Depends on**: none

**Files to modify**:
- `data/scripts/generate_paraphrases.py` - New file: main generation script
- `data/scripts/test_paraphrases.py` - New file: unit tests

**Verification**:
- All 12+ derived operator patterns correctly detected on synthetic AST examples
- Unit tests pass
- Detection statistics printed for full 727-record dataset match research expectations (364 negations, 53 eventually, 63 top)

---

### Phase 2: Rule-Based NL Generator for Depth <= 2 [NOT STARTED]

**Goal**: Implement the recursive AST walker that produces English paraphrases for all 635 depth <= 2 records.

**Tasks**:
- [ ] Implement recursive `ast_to_nl(node, context)` function that:
  - First attempts derived operator matching (highest precedence)
  - Falls back to primitive operator templates
  - Tracks nesting depth for parenthetical grouping decisions
  - Uses context parameter for natural phrasing (e.g., "if...then" vs bare implication)
- [ ] Implement depth-aware smoothing: at depth 0-1 use natural phrasing ("if p then q"), at depth 2 add structural markers ("moreover, it holds that...")
- [ ] Handle bimodal interaction formulas (239 records with both modal and temporal operators)
- [ ] Handle atom rendering: bare atom names for simple propositions ("p holds", "q holds")
- [ ] Generate paraphrases for all 635 depth <= 2 records
- [ ] Flag records with impCount >= 5 for quality review (51 records)
- [ ] Write output with `nl_paraphrase_method: "rule-based"` field
- [ ] Cross-validate: ensure formula_str can be reconstructed conceptually from NL (manual spot-check of 20 records)

**Timing**: 2.5 hours

**Depends on**: 1

**Files to modify**:
- `data/scripts/generate_paraphrases.py` - Add walker and generation logic
- `data/scripts/test_paraphrases.py` - Add integration tests for representative formulas

**Verification**:
- All 635 depth <= 2 records produce non-empty NL paraphrases
- No Python exceptions during generation
- Manual review of 20 random samples confirms semantic correctness
- Flagged high-impCount records identified for Phase 4 review

---

### Phase 3: LLM-Assisted Generation for Depth >= 3 [NOT STARTED]

**Goal**: Generate paraphrases for the 92 depth >= 3 records using LLM assistance with structured prompting.

**Tasks**:
- [ ] Design prompt template for LLM paraphrase generation:
  - Include formula_str, formula_ast, and the rule-based NL of sub-formulas as context
  - Specify output format: single English sentence, no formal symbols
  - Include 3-5 few-shot examples from validated depth <= 2 outputs
- [ ] Implement LLM generation function with retry logic and validation
- [ ] Generate paraphrases for all 92 depth >= 3 records
- [ ] Write output with `nl_paraphrase_method: "llm-assisted"` field
- [ ] Produce review file (`data/scripts/review_depth3.json`) with formula_str, generated NL, and confidence scores for human verification
- [ ] Handle edge cases: if LLM produces formal symbols or incomplete output, flag for manual review

**Timing**: 2 hours

**Depends on**: 2

**Files to modify**:
- `data/scripts/generate_paraphrases.py` - Add LLM generation module
- `data/scripts/review_depth3.json` - New file: generated review artifact for human verification
- `data/scripts/prompt_template.txt` - New file: LLM prompt template (versionable)

**Verification**:
- All 92 depth >= 3 records produce non-empty NL paraphrases
- Review file generated with all records for human inspection
- No formal symbols (box, diamond, U, S, imp, bot) appear in generated NL text

---

### Phase 4: Quality Validation and Corrections [NOT STARTED]

**Goal**: Validate all 727 paraphrases for grammar and semantic correctness; correct failures.

**Tasks**:
- [ ] Run automated grammar check on all 727 paraphrases (LanguageTool or equivalent Python library)
- [ ] Define custom dictionary/exceptions for logical terms (proposition, tautology, contradiction)
- [ ] Review and correct grammar failures
- [ ] Spot-check semantic correctness: stratified sample of 50 rule-based records (by operator type and depth)
- [ ] Human review all 92 LLM-assisted paraphrases (mark as approved or flag for revision)
- [ ] Re-check flagged high-impCount records (51 records): escalate unreadable ones to LLM-assisted method
- [ ] Update `nl_paraphrase_method` for any records that changed generation method
- [ ] Record validation statistics: grammar pass rate, semantic accuracy, escalation count

**Timing**: 1.5 hours

**Depends on**: 3

**Files to modify**:
- `data/scripts/generate_paraphrases.py` - Add validation functions
- `data/scripts/validate_paraphrases.py` - New file: standalone validation script
- `data/scripts/review_depth3.json` - Update with approval/revision status

**Verification**:
- Grammar check passes on >= 95% of records (remaining are acceptable formal-language patterns)
- All 92 LLM-assisted records have been human-reviewed
- Validation statistics documented

---

### Phase 5: Integration and Dataset Update [NOT STARTED]

**Goal**: Write final augmented dataset, update validate.py schema, update README, and ensure backward compatibility.

**Tasks**:
- [ ] Write updated `data/bmlogic-bench.jsonl` with `nl_paraphrase` and `nl_paraphrase_method` fields added to all 727 records
- [ ] Update `data/bmlogic-bench_metadata.json` to document new fields
- [ ] Update `data/hf-dataset/validate.py`: add `nl_paraphrase` and `nl_paraphrase_method` to optional fields check (NOT required fields, preserving backward compatibility)
- [ ] Update `data/README.md` with field documentation and generation methodology
- [ ] Update `data/hf-dataset/README.md` (dataset card) with new field descriptions
- [ ] Verify `data/scripts/generate_splits.py` still works unchanged (backward compatibility)
- [ ] Run full validate.py to confirm no regressions
- [ ] Add generation script usage documentation to script header docstring
- [ ] Ensure `data/scripts/generate_paraphrases.py` has CLI with `--input`, `--output`, `--method` flags

**Timing**: 1.5 hours

**Depends on**: 3, 4

**Files to modify**:
- `data/bmlogic-bench.jsonl` - Add nl_paraphrase and nl_paraphrase_method fields
- `data/bmlogic-bench_metadata.json` - Document new fields
- `data/hf-dataset/validate.py` - Add optional field validation
- `data/README.md` - Document new fields and methodology
- `data/hf-dataset/README.md` - Update dataset card
- `data/scripts/generate_paraphrases.py` - Finalize CLI interface and docstring

**Verification**:
- `python data/hf-dataset/validate.py` passes with 0 failures
- `python data/scripts/generate_splits.py` still produces correct output
- All 727 records in updated JSONL have non-null nl_paraphrase
- Fields are truly optional: removing them from a record does not break validate.py

---

## Testing & Validation

- [ ] Unit tests for all derived operator detection patterns pass
- [ ] All 727 records have non-null `nl_paraphrase` field
- [ ] All 727 records have non-null `nl_paraphrase_method` field (values: "rule-based" or "llm-assisted")
- [ ] Grammar check passes on >= 95% of records
- [ ] Manual semantic spot-check of 50+ rule-based records confirms correctness
- [ ] All 92 LLM-assisted records have been human-reviewed
- [ ] `python data/hf-dataset/validate.py` passes
- [ ] `python data/scripts/generate_splits.py` produces unchanged output
- [ ] Backward compatibility: existing code that reads bmlogic-bench.jsonl without expecting new fields still works

## Artifacts & Outputs

- `data/scripts/generate_paraphrases.py` - Main generation script (published)
- `data/scripts/test_paraphrases.py` - Unit and integration tests
- `data/scripts/validate_paraphrases.py` - Quality validation script
- `data/scripts/prompt_template.txt` - LLM prompt template
- `data/scripts/review_depth3.json` - LLM review artifact
- `data/bmlogic-bench.jsonl` - Updated dataset with new fields
- `data/bmlogic-bench_metadata.json` - Updated metadata
- `specs/216_nl_paraphrase_augmentation/plans/01_nl-paraphrase-plan.md` - This plan

## Rollback/Contingency

- The original `data/bmlogic-bench.jsonl` is tracked in git; rollback via `git checkout HEAD~1 -- data/bmlogic-bench.jsonl`
- New fields are optional: removing them restores backward compatibility without code changes
- If LLM-assisted generation proves unreliable, depth >= 3 records can use rule-based output with a quality warning flag
- If grammar validation tooling is unavailable, substitute with basic sentence-structure heuristics (capitalization, period, no dangling operators)
