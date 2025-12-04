# README Reframe Research Report: Logos Focus on Proof-Checker

**Research Date**: 2025-12-03
**Complexity Level**: 3
**Workflow Type**: research-and-plan

## Executive Summary

This research analyzes the current README.md and identifies all model-builder references across the Logos repository to support reframing the document with:
- **Primary focus**: Proof-Checker (LEAN 4 syntactic verification)
- **Secondary integration**: Model-Checker (where relevant for training signal discussion)
- **Removal**: All model-builder references

### Key Findings

1. **Model-Builder References Found**: 9 occurrences across 4 files
2. **Current Narrative Problem**: README presents Logos as "third package" in 3-component architecture, creating confusion about project scope
3. **Logos Presentation**: README conflates Logos (the formal language) with a 3-package implementation architecture
4. **Recommended Approach**: Reframe Logos as the formal language implemented by Logos, with Model-Checker providing complementary verification

## 1. Current README.md Analysis

### 1.1 Document Structure

The current README.md (324 lines) has the following structure:

1. **Title & Introduction** (Lines 1-7): Introduces Logos as syntactic verification for "the Logos"
2. **Logos Section** (Lines 9-31): Describes TM operators, axioms, perpetuity principles
3. **Core Capabilities** (Lines 33-60): Lists 5 capabilities including dual verification
4. **Implementation Status** (Lines 62-100): MVP completion with partial metalogic
5. **Architecture & Extensibility** (Lines 102-153): **PROBLEMATIC SECTION** - presents 3-package architecture
6. **Installation** (Lines 154-174)
7. **Documentation** (Lines 176-209)
8. **Project Structure** (Lines 216-278)
9. **Related Projects** (Lines 280-286): **PROBLEMATIC SECTION** - lists model-builder
10. **License, Citation, Contributing** (Lines 288-323)

### 1.2 Problematic Narrative Elements

#### Problem 1: "Third Package" Framing (Lines 106-122)

```markdown
Logos is the third package in the Logos architecture, providing **syntactic verification** complementing:

1. **Model-Builder** (Design Phase): Transforms natural language → formal semantic models
   - Extracts formal language fragments (FLF)
   - Constructs semantic model structures (SMS)
   - Generates salient inferences (SRI)

2. **Model-Checker** ([v1.2.12](https://github.com/benbrastmckie/ModelChecker)): Semantic verification via Z3
   - Implements hyperintensional semantics
   - Generates counterexamples for invalid inferences
   - Provides corrective RL training signals

3. **Logos**: Syntactic verification via LEAN 4
   - Derives valid theorems from TM axioms
   - Provides proof receipts with mathematical certainty
   - Generates positive RL training signals
```

**Issue**: Positions Logos as subordinate component in larger system rather than primary implementation of Logos formal language.

#### Problem 2: Model-Builder in Related Projects (Lines 282-286)

```markdown
- **[Logos](https://github.com/benbrastmckie/Logos)** - Parent project for transparent AI reasoning with formal logic tools
- **[Model-Checker](https://github.com/benbrastmckie/ModelChecker)** - Z3-based semantic verification implementing hyperintensional semantics (v1.2.12)
- **Model-Builder** - Natural language to formal logic interface (design phase)
```

**Issue**: Includes model-builder in project ecosystem despite being outside scope.

#### Problem 3: Dual Verification Framing (Line 124)

```markdown
**Dual Verification Architecture**: Logos's syntactic proofs and Model-Checker's semantic countermodels create comprehensive learning signals for AI training without human annotation.
```

**Current**: Dual = Proof-Checker + Model-Checker (correct)
**Missing**: Clear emphasis that this is the complete verification architecture

### 1.3 Positive Elements to Preserve

1. **Logos as Formal Language** (Lines 1-3, 9-31): Clear presentation of TM operators, axioms, perpetuity principles
2. **Transparent Reasoning Focus** (Lines 35-40): Mathematical certainty, auditable inferences
3. **Self-Supervised Training** (Lines 42-46): Unlimited theorems, no human annotation
4. **Progressive Extension Strategy** (Lines 54-60, 142-151): Layer 0-3 roadmap
5. **Theoretical Innovation** (Lines 57-60): Task semantics, perpetuity principles, hyperintensional foundation

## 2. Model-Builder Occurrence Analysis

### 2.1 Complete List of Model-Builder References

| File | Line(s) | Context | Type |
|------|---------|---------|------|
| README.md | 108-111 | Architecture section numbered list | Primary reference |
| README.md | 284 | Related Projects bullet | Secondary reference |
| ARCHITECTURE.md | 966-982 | Model-Builder Integration section | Integration code example |
| ARCHITECTURE.md | 1172, 1177, 1182, 1189, 1194, 1199 | Operator alignment subsection | Comparison table |
| ARCHITECTURE.md | 1203-1225 | Integration Points with Model-Builder | Extended integration discussion |
| INTEGRATION.md | 15 | Architecture diagram | ASCII diagram |
| INTEGRATION.md | 31 | Integration Points table | Table entry |
| INTEGRATION.md | 129-136 | Inference Request structure | Code example |

### 2.2 Categorization by Impact

**High Impact (Must Remove)**:
1. README.md Line 108-111: Core narrative positioning
2. README.md Line 284: Ecosystem presentation
3. ARCHITECTURE.md Lines 1203-1225: Extended integration section

**Medium Impact (Should Revise)**:
4. ARCHITECTURE.md Lines 966-982: Integration code example
5. ARCHITECTURE.md Lines 1172-1199: Operator alignment table
6. INTEGRATION.md Line 15: Architecture diagram
7. INTEGRATION.md Line 31: Integration table

**Low Impact (Can Remove)**:
8. INTEGRATION.md Lines 129-136: Code example structure

### 2.3 Context Analysis for Each Occurrence

#### README.md (2 occurrences)

**Line 108-111**: Part of numbered list presenting "Logos architecture" as 3-package system
- **Problem**: Defines project scope incorrectly
- **Solution**: Reframe as "Logos implements Logos formal language, with Model-Checker providing complementary semantic verification"

**Line 284**: Related Projects section
- **Problem**: Suggests model-builder is related project
- **Solution**: Remove from list, keep only Model-Checker reference with appropriate context

#### ARCHITECTURE.md (7 occurrences)

**Lines 966-982**: "Model-Builder Integration" subsection with code example
- **Context**: Shows `verify_inference_for_model_builder` function
- **Problem**: Presents integration API that doesn't exist
- **Solution**: Remove section entirely

**Lines 1172-1199**: "Operator Layer Alignment" comparison table
- **Context**: Compares operators across Model-Builder, Proof-Checker, System
- **Problem**: Table implies model-builder is parallel implementation
- **Solution**: Reframe table to show "Logos Operator → Proof-Checker Implementation → System Semantics"

**Lines 1203-1225**: "Integration Points with Model-Builder" extended section
- **Context**: Describes SRI Evaluation stage integration
- **Problem**: Detailed integration design for non-existent component
- **Solution**: Remove section, replace with brief note about potential future natural language interfaces

#### INTEGRATION.md (3 occurrences)

**Line 15**: ASCII architecture diagram
- **Context**: Shows 3-box diagram with Model-Builder, Logos, Model-Checker
- **Problem**: Visual reinforcement of 3-component architecture
- **Solution**: Replace with 2-component diagram: Logos ↔ Model-Checker

**Line 31**: Integration Points table
- **Context**: Lists Model-Builder as integration point
- **Problem**: Implies active integration
- **Solution**: Remove row from table

**Lines 129-136**: InferenceRequest structure code example
- **Context**: Shows data structure for model-builder requests
- **Problem**: Implementation detail for non-existent integration
- **Solution**: Remove example or repurpose for generic inference API

## 3. Logos Conceptual Analysis

### 3.1 Current Logos Presentation Issues

**Conflation Problem**: README conflates two distinct concepts:
1. **Logos the Formal Language**: TM bimodal logic with layer extensions (correct)
2. **Logos the Software System**: 3-package architecture including model-builder (incorrect)

**Evidence from README Lines 104-106**:
```markdown
### Logos Ecosystem Integration

Logos is the third package in the Logos architecture...
```

**Evidence from LOGOS_PHILOSOPHY.md Lines 1-7**:
```markdown
# Logos: Formal Language of Thought for Verified AI Reasoning

Logos is a formal language of thought designed to enable verified AI reasoning through progressive operator extensibility.
```

**Correct Understanding**: Logos is the formal language, Logos is the implementation.

### 3.2 Recommended Logos Framing

**What Logos IS**:
- Formal language of thought with progressive operator extensibility
- Layer 0 (Core TM): Boolean + Modal + Temporal operators
- Layer 1-3 (Extensions): Explanatory + Epistemic + Normative operators
- Mathematical foundation for verified AI reasoning

**What Logos is NOT**:
- A 3-package software system
- A parent project containing Logos as subcomponent
- An ecosystem requiring model-builder for operation

**Logos's Relationship to Logos**:
- Logos IS the LEAN 4 implementation of Logos formal language
- Logos provides syntactic verification for Logos inferences
- Model-Checker provides complementary semantic verification (dual verification architecture)

### 3.3 Correct Narrative Structure

**Recommended Flow**:

1. **Introduce Logos**: LEAN 4 implementation of Logos formal language for verified AI reasoning
2. **Define Logos**: Formal language (TM bimodal logic) with progressive operator extensibility
3. **Explain Dual Verification**: Logos (syntactic) + Model-Checker (semantic) = complete verification
4. **Describe Training Signal**: How dual verification enables RL training without human annotation
5. **Detail Implementation**: Current Layer 0 status, planned Layer 1-3 extensions

**Key Positioning Statement**:
> Logos implements the Logos formal language—a bimodal logic combining tense and modality with progressive operator extensions for explanatory, epistemic, and normative reasoning. Built on LEAN 4, Logos provides syntactic verification complemented by the Model-Checker's semantic validation, creating a dual verification architecture for training AI systems to reason with mathematical certainty.

## 4. Documentation File Analysis

### 4.1 Files Referencing Model-Builder

**Primary Documentation**:
1. `/home/benjamin/Documents/Philosophy/Projects/Logos/README.md`
2. `/home/benjamin/Documents/Philosophy/Projects/Logos/Documentation/UserGuide/ARCHITECTURE.md`
3. `/home/benjamin/Documents/Philosophy/Projects/Logos/Documentation/UserGuide/INTEGRATION.md`

**Backup Files** (no changes needed):
- `.backups/README_backup_20251202.md`
- `.backups/README_20251202_140347.md`

**Spec Files** (historical artifacts, no changes needed):
- Multiple files in `.claude/specs/` directories

### 4.2 Files NOT Referencing Model-Builder (No Changes)

**Key Documentation Files Clean**:
- `/home/benjamin/Documents/Philosophy/Projects/Logos/CLAUDE.md` ✓
- `/home/benjamin/Documents/Philosophy/Projects/Logos/Documentation/UserGuide/LOGOS_PHILOSOPHY.md` ✓
- `/home/benjamin/Documents/Philosophy/Projects/Logos/Documentation/Research/DUAL_VERIFICATION.md` ✓
- `/home/benjamin/Documents/Philosophy/Projects/Logos/Documentation/UserGuide/TUTORIAL.md` ✓
- `/home/benjamin/Documents/Philosophy/Projects/Logos/Documentation/UserGuide/EXAMPLES.md` ✓

**Analysis**: Core documentation correctly focuses on Logos implementation without model-builder references.

## 5. Model-Checker Integration Analysis

### 5.1 Appropriate Model-Checker References

**Where Model-Checker SHOULD appear**:

1. **Dual Verification Architecture** (README, ARCHITECTURE.md, DUAL_VERIFICATION.md):
   - Training signal generation (proof receipts + counterexamples)
   - Complementary verification approach
   - RL training architecture

2. **Integration Guide** (INTEGRATION.md):
   - API for formula exchange
   - SMT-LIB export format
   - Coordinated verification workflow

3. **Capabilities Section** (README):
   - Self-supervised training data generation
   - Rapid prototyping (test theorems before proof attempts)
   - Counterexample learning

### 5.2 Model-Checker Context Framing

**Correct Framing**:
```markdown
Logos (syntactic verification) works in concert with the Model-Checker
(semantic verification) to create comprehensive training signals:

- **Proof-Checker**: Generates proof receipts for valid inferences (positive RL signal)
- **Model-Checker**: Generates counterexamples for invalid inferences (corrective RL signal)
```

**Incorrect Framing** (to avoid):
```markdown
Logos is one of three packages in the Logos ecosystem...
```

### 5.3 Training Signal Discussion

**Where to Mention Model-Checker for Training**:

**Section: Self-Supervised Training Data Generation**
- Proof receipts = positive reinforcement (Logos)
- Counterexamples = corrective feedback (Model-Checker)
- Unlimited training data without human annotation (dual verification)

**Section: Integrated Verification Architecture**
- Dual checking: syntactic + semantic
- Rapid prototyping: Model-Checker tests before proof attempts
- Counterexample learning: invalid reasoning generates corrective signals
- Scalable oversight: verification scales with computation

**Emphasis**: Model-Checker is a tool for semantic verification, not a co-equal architecture component.

## 6. Reframing Strategy

### 6.1 Title & Introduction Changes

**Current** (Lines 1-7):
```markdown
# Logos: Formal Verification for Transparent AI Reasoning

Logos provides syntactic verification for the Logos, a comprehensive
framework for transparent AI reasoning in interpreted formal languages...
```

**Proposed**:
```markdown
# Logos: LEAN 4 Implementation of Logos Formal Language

Logos is a LEAN 4 implementation of Logos—a formal language of thought
combining tense and modality for verified AI reasoning. The system implements
the bimodal logic TM (Tense and Modality) with progressive operator extensions,
enabling AI systems to reason with mathematical certainty through dual
verification: syntactic proofs (Logos) complemented by semantic
validation (Model-Checker).
```

**Rationale**:
- Clearly positions Logos as Logos implementation
- Introduces dual verification early
- Removes "the Logos" phrasing (sounds like external system)
- Focuses on what Logos IS rather than what it provides for something else

### 6.2 Architecture Section Rewrite

**Current** (Lines 104-124):
```markdown
### Logos Ecosystem Integration

Logos is the third package in the Logos architecture, providing
**syntactic verification** complementing:

1. **Model-Builder** (Design Phase): Transforms natural language → formal models
2. **Model-Checker** ([v1.2.12]...): Semantic verification via Z3
3. **Logos**: Syntactic verification via LEAN 4

**Dual Verification Architecture**: Logos's syntactic proofs and
Model-Checker's semantic countermodels create comprehensive learning signals...
```

**Proposed**:
```markdown
### Dual Verification Architecture

Logos implements Logos formal language with dual verification for
training AI systems without human annotation:

**Syntactic Verification** (Logos - LEAN 4):
- Derives valid theorems from TM axioms and inference rules
- Generates proof receipts providing mathematical certainty
- Produces positive RL training signals for valid inferences

**Semantic Verification** (Model-Checker - Z3):
- Searches for countermodels in finite state spaces
- Generates concrete scenarios showing why inferences fail
- Produces corrective RL training signals for invalid inferences

This complementary verification enables scalable oversight through computation
rather than human annotation, creating unlimited clean training data from
axiomatic foundations.

**For Model-Checker integration**: See [INTEGRATION.md](Documentation/UserGuide/INTEGRATION.md)
**For RL training architecture**: See [DUAL_VERIFICATION.md](Documentation/Research/DUAL_VERIFICATION.md)
```

**Rationale**:
- Removes 3-package numbered list
- Positions dual verification as THE architecture (not one of three components)
- Clearly explains complementary roles
- Points to integration and training docs for details

### 6.3 Related Projects Section Rewrite

**Current** (Lines 280-286):
```markdown
## Related Projects

- **[Logos](https://github.com/benbrastmckie/Logos)** - Parent project
- **[Model-Checker](https://github.com/benbrastmckie/ModelChecker)** - Z3-based semantic verification (v1.2.12)
- **Model-Builder** - Natural language interface (design phase)
- **FormalizedFormalLogic/Foundation** - LEAN 4 modal logic library
- **Mathlib4** - LEAN 4 mathematics library
```

**Proposed**:
```markdown
## Related Projects

- **[Model-Checker](https://github.com/benbrastmckie/ModelChecker)** - Z3-based semantic verification implementing hyperintensional semantics (v1.2.12), provides complementary countermodel generation for dual verification architecture
- **[LogicNotes](https://github.com/benbrastmckie/LogicNotes)** - Compressed overview of TM logic subsystems and theoretical foundations
- **FormalizedFormalLogic/Foundation** - LEAN 4 modal logic library (implementation patterns adopted)
- **Mathlib4** - LEAN 4 mathematics library (style conventions followed)
```

**Rationale**:
- Removes Logos as "parent project" (implies Logos is subcomponent)
- Removes Model-Builder entirely
- Adds LogicNotes for theoretical background
- Clarifies Model-Checker relationship (complementary tool, not co-equal package)

### 6.4 Logos Section Enhancement

**Current** (Lines 9-11):
```markdown
## Logos: Tense and Modal Reasoning

Layer 0 implements the foundational bimodal logic TM (Tense and Modality)...
```

**Proposed**:
```markdown
## Logos Formal Language: Tense and Modal Reasoning

Logos is a formal language of thought with progressive operator extensibility,
designed to enable verified AI reasoning across multiple domains. Logos
implements the core language (Layer 0: TM bimodal logic) with planned extensions
for explanatory, epistemic, and normative reasoning.

### Layer 0 (Core TM - Current Implementation)

The bimodal logic TM (Tense and Modality) combines S5 modal logic with linear
temporal logic through task semantics...
```

**Rationale**:
- Defines Logos clearly as formal language
- Positions Logos as implementation
- Maintains progressive extension narrative
- Clearer section hierarchy

## 7. Impact Assessment

### 7.1 Files Requiring Changes

**Critical Changes** (must update for consistency):
1. `README.md` - Primary narrative reframing
2. `Documentation/UserGuide/ARCHITECTURE.md` - Remove model-builder integration sections
3. `Documentation/UserGuide/INTEGRATION.md` - Update architecture diagram and integration points

**Total Lines to Modify**: ~150 lines across 3 files
**Estimated Complexity**: Medium (requires careful narrative restructuring)

### 7.2 Backward Compatibility Considerations

**Documentation Links**: All internal links remain valid (no file moves)
**External Links**: Model-Checker links unchanged
**API Surface**: No code changes required (only documentation)
**Version Impact**: Documentation update only, no semantic version change needed

### 7.3 Quality Assurance Checklist

- [ ] Remove all 9 model-builder occurrences
- [ ] Verify no broken internal links
- [ ] Check external links still valid
- [ ] Ensure consistent Logos framing across all docs
- [ ] Validate dual verification narrative coherence
- [ ] Confirm Model-Checker positioned as complementary tool (not co-equal package)
- [ ] Test all markdown rendering (headings, lists, code blocks)
- [ ] Spell-check all modified sections
- [ ] Verify backtick usage for formal symbols per standards

## 8. Recommendations

### 8.1 Primary Recommendation: Narrative Reframing

**Adopt the following core narrative**:

1. **What Logos IS**: LEAN 4 implementation of Logos formal language
2. **What Logos IS**: Formal language of thought (TM bimodal logic + progressive extensions)
3. **What Dual Verification IS**: Logos (syntactic) + Model-Checker (semantic) = complete verification
4. **What Model-Checker IS**: Complementary semantic verification tool for training signal generation
5. **What Model-Builder IS NOT**: Not part of Logos scope, not in Logos "architecture"

### 8.2 Documentation Consistency Guidelines

**Use this language**:
- ✓ "Logos implements Logos formal language"
- ✓ "Dual verification architecture (syntactic + semantic)"
- ✓ "Model-Checker provides complementary semantic validation"
- ✓ "Logos and Model-Checker create training signals together"

**Avoid this language**:
- ✗ "Logos is the third package in Logos architecture"
- ✗ "Logos ecosystem with three components"
- ✗ "Logos provides syntactic verification for the Logos"
- ✗ "Model-Builder integration" (in any context)

### 8.3 Section Ordering Recommendation

**Recommended README.md Structure**:

1. Title & Introduction (reframed)
2. Logos Formal Language (enhanced definition)
3. Dual Verification Architecture (replaces ecosystem section)
4. Core Capabilities (keep with minor edits)
5. Implementation Status (keep unchanged)
6. Theoretical Foundations (new section for task semantics, perpetuity, hyperintensional semantics)
7. Progressive Extension Strategy (Layer 0-3 roadmap)
8. Installation (keep unchanged)
9. Documentation (keep unchanged)
10. Project Structure (keep unchanged)
11. Related Projects (rewritten without model-builder)
12. License, Citation, Contributing (keep unchanged)

**Rationale**: Moves theoretical foundations earlier to establish credibility, positions dual verification as THE architecture immediately after language definition.

### 8.4 Long-Term Maintenance

**Document Standards**:
1. Add to CONTRIBUTING.md: "Model-builder is outside Logos scope. Do not add model-builder references to documentation."
2. Update documentation review checklist to flag any model-builder mentions
3. Add ARCHITECTURE.md note: "For natural language interfaces to Logos, see future extension plans in Research/ directory"

## 9. Next Steps for Plan Phase

### 9.1 Plan Document Should Include

1. **File-by-file change specifications**:
   - Exact line numbers to modify
   - Before/after text for each change
   - Rationale for each modification

2. **Section rewrite templates**:
   - New Introduction paragraph
   - New Architecture section
   - New Related Projects section
   - Enhanced Logos definition

3. **Verification checklist**:
   - All 9 model-builder references removed
   - Consistent narrative throughout
   - No broken links
   - Proper symbol backticking

4. **Testing procedures**:
   - Markdown rendering validation
   - Link checking
   - Spell-check
   - Grammar review

### 9.2 Implementation Phases

**Phase 1**: README.md reframing (critical)
- Lines 1-7: Title & introduction
- Lines 104-124: Architecture section → Dual verification
- Lines 280-286: Related projects

**Phase 2**: ARCHITECTURE.md cleanup
- Remove model-builder integration section (lines 966-982)
- Revise operator alignment table (lines 1172-1199)
- Remove integration points section (lines 1203-1225)

**Phase 3**: INTEGRATION.md updates
- Update architecture diagram (line 15)
- Revise integration table (line 31)
- Remove/repurpose code examples (lines 129-136)

**Phase 4**: Quality assurance
- Link checking
- Narrative consistency review
- Symbol backtick verification

## 10. Conclusion

This research has identified all model-builder references and analyzed the narrative structure needed to reframe README.md with appropriate Logos focus. The core issue is conflation of Logos (formal language) with a 3-package architecture, when the correct framing is:

**Logos** = Formal language of thought (TM bimodal logic)
**Logos** = LEAN 4 implementation of Logos
**Model-Checker** = Complementary semantic verification tool
**Dual Verification** = Logos + Model-Checker (complete architecture)

Removing model-builder and adopting this clear narrative will eliminate confusion and properly position Logos as the primary implementation of Logos formal language.

---

**REPORT_CREATED**: /home/benjamin/Documents/Philosophy/Projects/Logos/.claude/specs/031_readme_logos_proof_checker_reframe/reports/README_REFRAME_RESEARCH.md
