# Research Report: Task #437

**Task**: Improve README consistency with recursive-semantics.md
**Date**: 2026-01-12
**Focus**: README/recursive-semantics consistency analysis

## Summary

The Logos README.md and recursive-semantics.md share substantial overlapping content, particularly the Extension Architecture diagram (nearly identical) and explanations of core concepts like bilateral propositions and state space. The README lacks any mention of the ModelChecker parallel implementation, which is documented elsewhere in the project (METHODOLOGY.md). Several internal discrepancies exist in the README regarding terminology and the operator reference tables.

## Findings

### Current README Structure

The README.md (221 lines) is organized into these sections:

1. **Header/Tagline** (lines 1-3) - Brief description of hyperintensional logic
2. **About Logos** (lines 5-12) - High-level overview of hyperintensionality
3. **Philosophy** (lines 13-23) - Why hyperintensionality matters
4. **Extension Architecture** (lines 25-61) - ASCII diagram showing layer dependencies
5. **Core Concepts** (lines 63-98) - Bilateral propositions, state space, task relation, world-histories
6. **Implementation Status** (lines 99-112) - Table of component statuses
7. **Directory Structure** (lines 113-138) - File tree of SubTheories/
8. **Operators Reference** (lines 140-179) - Tables for modal, temporal, counterfactual, store/recall, identity operators
9. **Building and Testing** (lines 181-196) - Build commands
10. **Related Documentation** (lines 198-215) - Links to other docs
11. **Navigation** (lines 217-221) - Parent directory links

### Recursive-Semantics Coverage

The recursive-semantics.md (591 lines) provides authoritative formal specifications:

1. **Introduction** (lines 1-61) - Extension dependency diagram (same as README)
2. **Constitutive Foundation** (lines 63-226) - Full formal semantics
   - Syntactic primitives
   - Constitutive frame definition
   - Constitutive model
   - Variable assignment
   - Verification/falsification clauses for all operators
   - Bilateral propositions with formal operations
   - Logical consequence definition
3. **Explanatory Extension** (lines 228-464) - Full formal semantics
   - Additional syntactic primitives
   - Core frame structure
   - State modality definitions
   - Task relation constraints
   - World-history definition
   - Truth conditions for all operators
   - Bimodal interaction principles
   - Counterfactual logic axiom schemata
4. **Epistemic/Normative/Spatial/Agential Extensions** (lines 467-577) - Stubs with [DETAILS] markers
5. **References** (lines 580-591)

### Redundancies Identified

1. **Extension Architecture Diagram** (MAJOR)
   - README lines 29-59 and recursive-semantics.md lines 20-50 contain nearly identical ASCII diagrams
   - Only superficial differences in formatting (dashes vs box-drawing characters)
   - Both explain the same dependency structure
   - **Recommendation**: README should reference recursive-semantics.md for the diagram rather than duplicate it

2. **Bilateral Propositions Definition**
   - README lines 65-71 define bilateral propositions
   - recursive-semantics.md lines 199-214 provides fuller formal treatment
   - Redundant explanations of the same concept
   - **Recommendation**: README should provide brief intuition and link to recursive-semantics.md for formal details

3. **State Space Description**
   - README lines 73-83 describe constitutive frame
   - recursive-semantics.md lines 82-95 provides formal definition
   - Both mention null state, full state, fusion
   - **Recommendation**: Consolidate; README keeps intuitive description, links for formal version

4. **Task Relation and World-Histories**
   - README lines 85-97 describe task relation and world-histories
   - recursive-semantics.md lines 243-289 provides full formal treatment
   - Overlapping explanations
   - **Recommendation**: README should summarize briefly and reference recursive-semantics.md

5. **Operator Tables**
   - README lines 144-179 list operators with symbols and readings
   - recursive-semantics.md has detailed truth conditions for each
   - layer-extensions.md lines 105-140 also has operator tables
   - Three-way redundancy
   - **Recommendation**: Keep README operator quick-reference, remove from elsewhere or clearly differentiate purpose

### Internal Discrepancies

1. **Symbol Notation Inconsistency** (README lines 146-147)
   - Uses "box" and "diamond" in Symbol column instead of actual symbols (which appear in recursive-semantics.md as Unicode)
   - Inconsistent with other operators which use symbolic notation (H, G, P, F)

2. **Temporal Operator Symbols** (README lines 157-158)
   - Uses `triangleleft` and `triangleright` spelled out instead of actual triangle symbols
   - recursive-semantics.md uses the proper Unicode (A S B notation vs triangleleft)

3. **Implementation Status Table** (README lines 101-112)
   - Lists "Foundation/Semantics" as separate from "Foundation" but directory structure shows Semantics.lean under Foundation/
   - Unclear why these are separated
   - "Explanatory/truthAt" label doesn't match actual file name (Truth.lean per directory structure)

4. **Operator Reference Incompleteness**
   - README Operators Reference (lines 140-179) is missing:
     - Causal operator (mentioned in layer-extensions.md as A -> B)
     - Derived temporal operators (always, sometimes)
     - Actuality predicate Act(t)
     - Universal quantifier
   - These are documented in recursive-semantics.md

5. **Directory Structure Path**
   - README line 116 shows `Logos/SubTheories/` as root
   - But the actual file path is `Theories/Logos/SubTheories/`
   - Minor discrepancy but could confuse navigation

### ModelChecker Integration

**Current State**: The README has ZERO mentions of ModelChecker. This is a significant omission given that:

1. **METHODOLOGY.md** (lines 123, 229) explicitly describes the dual verification approach:
   - Proof-checker (Lean): Verifies proofs syntactically
   - Model-checker (Z3/ModelChecker): Searches for countermodels semantically

2. **METHODOLOGY.md line 229** includes the specific link:
   > **ModelChecker**: https://github.com/benbrastmckie/ModelChecker - Z3-based semantic verification for Logos (v0.9.26)

3. **layer-extensions.md** (line 319) mentions model-checker implementation status:
   > | **Explanatory Extension** | Complete | Partial (model-checker) |

4. **GLOSSARY.md** (lines 158, 162) defines:
   - Dual Verification: Complementary syntactic and semantic verification
   - Semantic Verification: Model checking via Z3

**Opportunities for ModelChecker Links**:

1. **About Logos section** - Mention the dual implementation (Lean prover + Python model-checker)
2. **Implementation Status table** - Add column or note about model-checker implementation
3. **Related Documentation section** - Add direct link to ModelChecker repository
4. **Philosophy section** - Mention that hyperintensional logic is implemented in both theorem prover and model checker

## Recommendations

### High Priority

1. **Add ModelChecker Reference** (About Logos or new "Related Projects" section)
   - Add paragraph: "Logos is developed in parallel in two implementations: this Lean 4 proof-checker for syntactic verification, and the [ModelChecker](https://github.com/benbrastmckie/ModelChecker) Python library for Z3-based semantic verification (model checking)."
   - Add to Related Documentation: Link to ModelChecker repository

2. **Remove Redundant Extension Architecture Diagram**
   - Replace the 30-line ASCII diagram in README with:
     - Brief 2-3 sentence summary of the architecture
     - Link to recursive-semantics.md for the full diagram and formal details
   - This reduces README by ~30 lines and eliminates sync issues

3. **Fix Symbol Notation**
   - Replace "box" with actual Unicode or consistent notation
   - Replace "diamond" with actual Unicode
   - Replace "triangleleft/triangleright" with consistent symbols or notation
   - Consider using LaTeX-style notation consistently: `[]` for box, `<>` for diamond, `<|` and `|>` for since/until

### Medium Priority

4. **Consolidate Core Concepts**
   - Keep brief intuitive descriptions (2-3 sentences each)
   - Add "See [recursive-semantics.md](docs/research/recursive-semantics.md) for formal definitions"
   - Remove detailed explanations that duplicate recursive-semantics.md

5. **Fix Implementation Status Table**
   - Align component names with actual file names (Truth.lean not truthAt)
   - Add ModelChecker implementation status column or row
   - Clarify Foundation vs Foundation/Semantics distinction

6. **Complete Operator Reference**
   - Add missing operators (causal, derived temporal, actuality predicate)
   - Or explicitly note this is a "quick reference" subset and link to complete list

### Low Priority

7. **Fix Directory Structure Path**
   - Change `Logos/SubTheories/` to `Theories/Logos/SubTheories/` or use relative path

8. **Add Cross-Reference to layer-extensions.md**
   - This document provides application examples that README lacks
   - Medical planning example, legal evidence analysis example could enrich README understanding

## References

- `/home/benjamin/Projects/ProofChecker/Theories/Logos/README.md` - Main README under analysis
- `/home/benjamin/Projects/ProofChecker/Theories/Logos/docs/research/recursive-semantics.md` - Authoritative semantic specification
- `/home/benjamin/Projects/ProofChecker/Theories/Logos/docs/research/layer-extensions.md` - Extension architecture overview
- `/home/benjamin/Projects/ProofChecker/Theories/Logos/docs/user-guide/METHODOLOGY.md` - Contains ModelChecker reference
- `/home/benjamin/Projects/ProofChecker/Theories/Logos/docs/reference/GLOSSARY.md` - Term definitions

## Next Steps

The implementation plan should cover:

1. Add ModelChecker section/link to README (priority: high)
2. Replace Extension Architecture diagram with summary + link (priority: high)
3. Fix symbol notation inconsistencies in operator tables (priority: medium)
4. Consolidate Core Concepts section to reduce redundancy (priority: medium)
5. Fix Implementation Status table alignment issues (priority: medium)
6. Add missing operators to reference or note incompleteness (priority: low)
7. Fix directory structure path (priority: low)

Estimated effort: Small to medium - primarily editing existing content, no new documentation creation required.
