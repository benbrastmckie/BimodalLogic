# Dependency Analysis: Aesop, Mathlib, Batteries for Logos Project

**Research Complexity**: 2
**Date**: 2025-12-05
**Status**: Complete

## Executive Summary

This report analyzes the costs, benefits, and standard practices for managing dependencies on Aesop, Mathlib, and Batteries in the Logos bimodal logic proof system project. The key findings:

1. **Current Status**: Logos already depends on Mathlib (v4.14.0), which transitively includes Aesop and Batteries
2. **Critical Finding**: `LinearOrderedAddCommGroup` (used in TaskFrame.lean) exists only in Mathlib, not Lean 4 core
3. **Standard Practice**: For proof automation projects, using Mathlib is standard and recommended
4. **Recommendation**: Maintain Mathlib dependency; attempting "greater independence" would require reimplementing substantial algebra/order theory infrastructure with minimal benefit

---

## 1. What Are Aesop, Mathlib, and Batteries?

### 1.1 Aesop: Automated Proof Search

**Official Description**: Aesop (Automated Extensible Search for Obvious Proofs) is a white-box proof search tactic for Lean 4, broadly similar to Isabelle's `auto`.

**Key Features**:
- Best-first search strategy with customizable prioritization
- User-extensible rule sets via `@[aesop]` attribute
- Safe and unsafe rules for flexible automation
- White-box design: users can predict how rules will be applied
- Generates readable tactic scripts when finding proofs

**Recent Developments (2025)**:
- Paper on "Tactic Script Optimisation for Aesop" (CPP 2025) introduced script optimization
- Used by Mathlib tactics like `measurability` and `continuity`
- Supports special-purpose automation via custom rule sets

**Performance**:
- Canonical solver outperforms Aesop (84% vs 36% solve rate) but requires induction support
- Aesop generates scripts 18x shorter than Canonical on average
- Not based on machine learning (unlike LLM-based approaches)

**Dependencies**: Aesop currently depends only on Batteries (formerly Std4)

**Sources**:
- [GitHub - leanprover-community/aesop](https://github.com/leanprover-community/aesop)
- [Aesop: White-Box Best-First Proof Search for Lean](https://dl.acm.org/doi/10.1145/3573105.3575671)
- [Tactic Script Optimisation for Aesop](https://dl.acm.org/doi/10.1145/3703595.3705877)

### 1.2 Mathlib: The Mathematics Library

**Official Description**: User-maintained library for Lean theorem prover containing programming infrastructure, mathematics, and tactics.

**Scope**:
- **Order Theory**: Lattices, complete lattices, conditionally complete lattices, partial orders
- **Algebra**: Groups, rings, fields, modules with ordering structures (`LinearOrderedAddCommGroup`, etc.)
- **Topology**: Basic point-set topology
- **Analysis**: Real numbers, limits, continuity
- **Logic**: Propositional, first-order, modal logic foundations
- **Tactics**: `simp`, `norm_num`, `ring`, `field_simp`, and hundreds more

**Size and Build Considerations**:
- `.lake` directory: ~5GB when Mathlib is a dependency
- Without cached olean files: "very large" compile times (specific benchmarks not disclosed)
- With `lake exe cache get`: Builds complete quickly using precompiled files
- Updates ~20 times per day (high velocity development)
- Compressed files stored in `~/.cache/mathlib`

**Transitive Dependencies** (from Logos manifest):
- plausible (property-based testing)
- LeanSearchClient (proof search integration)
- import-graph (dependency visualization)
- ProofWidgets4 (interactive widgets)
- Aesop (proof automation)
- Qq (quote4 - quotation library)
- Batteries (standard library extensions)
- Cli (command-line interface library)

**Version Management Best Practices**:
- Pin specific versions in `lakefile.toml`: `rev = "v4.14.0"`
- Synchronize `lean-toolchain` with Mathlib's version: `curl https://raw.githubusercontent.com/leanprover-community/mathlib4/master/lean-toolchain -o lean-toolchain`
- Use `lake exe cache get` to download precompiled olean files (critical for reasonable build times)
- Update incrementally through tagged releases, not directly to master

**Sources**:
- [GitHub - leanprover-community/mathlib4](https://github.com/leanprover-community/mathlib4)
- [Using mathlib4 as a dependency](https://github.com/leanprover-community/mathlib4/wiki/Using-mathlib4-as-a-dependency)
- [Updating Dependencies in a Lean (+ Mathlib) Project](https://malv.in/posts/2024-12-09-howto-update-lean-dependencies.html)

### 1.3 Batteries: Standard Library Extensions

**Official Description**: The "batteries included" extended library for Lean programming language and theorem prover (formerly Std4).

**Purpose**:
- Data structures for computer science and mathematics applications
- Extensions beyond Lean 4's minimal core library
- Standard library functionality expected in modern programming languages

**Relationship to Core**:
- Lean 4 core library is intentionally minimal
- Batteries provides common data structures and utilities
- Transitively included when depending on Mathlib

**Usage**:
```lean
require std from git "https://github.com/leanprover/std4" @ "main"
```

**Note**: Documentation available as part of Mathlib 4 documentation.

**Sources**:
- [GitHub - leanprover-community/batteries](https://github.com/leanprover-community/batteries)
- [leanprover/std4](https://github.com/leanprover/std4)

---

## 2. Current Logos Dependencies

### 2.1 Declared Dependencies

From `lakefile.toml`:
```toml
[[require]]
name = "mathlib"
git = "https://github.com/leanprover-community/mathlib4.git"
rev = "v4.14.0"
```

**Single Direct Dependency**: Mathlib v4.14.0

### 2.2 Transitive Dependencies

From `lake-manifest.json` (9 packages total):
1. **mathlib** (direct)
2. **plausible** (inherited from mathlib)
3. **LeanSearchClient** (inherited from mathlib)
4. **importGraph** (inherited from mathlib)
5. **proofwidgets** (inherited from mathlib)
6. **aesop** (inherited from mathlib)
7. **Qq** (quote4, inherited from mathlib)
8. **batteries** (inherited from mathlib)
9. **Cli** (inherited from mathlib)

**Conclusion**: Logos already has Aesop and Batteries as transitive dependencies through Mathlib.

### 2.3 Actual Mathlib Usage

**Direct Import Analysis**:
```bash
$ find Logos -name "*.lean" -exec grep -l "^import Mathlib" {} \;
Logos/Core/Semantics/TaskFrame.lean
```

**Single Import**:
```lean
import Mathlib.Algebra.Order.Group.Defs
```

**Usage**: `LinearOrderedAddCommGroup` typeclass for temporal duration structure in TaskFrame.

**Critical Finding**: `LinearOrderedAddCommGroup` is NOT in Lean 4 core library - it is defined in Mathlib.

---

## 3. Costs and Benefits Analysis

### 3.1 Benefits of Mathlib Dependency

#### 3.1.1 Essential Infrastructure (Cannot Avoid)

**`LinearOrderedAddCommGroup` Requirement**:
- Logos uses `LinearOrderedAddCommGroup T` in TaskFrame structure
- This typeclass combines:
  - Additive commutative group (`AddCommGroup`)
  - Linear (total) order (`LinearOrder`)
  - Compatibility between order and addition
- **Location**: `Mathlib.Algebra.Order.Group.Defs`
- **Core Library Alternative**: None - would need to implement from scratch

**Implications**:
- Removing Mathlib dependency requires reimplementing `LinearOrderedAddCommGroup` and all supporting infrastructure
- This includes: `Group`, `AddGroup`, `CommGroup`, `AddCommGroup`, `PartialOrder`, `LinearOrder`, and order-algebra compatibility lemmas
- Estimated effort: 20-40 hours for basic implementation, more for lemma library

#### 3.1.2 Proof Automation Ecosystem

**Tactics Available**:
- `simp`: Extensible simplifier with thousands of lemmas
- `norm_num`: Numeric normalization
- `ring`: Ring theory solver
- `omega` (via `grind` in latest versions): Presburger arithmetic
- Domain-specific tactics: `measurability`, `continuity`, etc.

**Aesop Integration**:
- Mathlib provides Aesop rule sets for standard library
- Custom rule sets for TM logic can leverage Mathlib's patterns
- White-box search with predictable behavior

**Value for Logos**:
- Task 7 (Implement Core Automation): 30-40 hours remaining work
- `tm_auto` tactic planned to use Aesop integration
- Removing Aesop would require reimplementing proof search from scratch (60-80 additional hours)

#### 3.1.3 Standard Mathematical Definitions

**Order Theory**:
- `PartialOrder`, `LinearOrder`, `Lattice`, `CompleteLattice`
- Needed for temporal logic ordering constraints
- Hundreds of proven lemmas (transitivity, antisymmetry, etc.)

**Algebra**:
- Group theory infrastructure
- Needed for temporal duration addition
- Compatibility between order and algebraic operations

**Value**: Avoids reinventing well-tested definitions used by entire Lean community.

#### 3.1.4 Community Standard Practice

**Modal/Temporal Logic Projects**:
- [FormalizedFormalLogic/Foundation](https://github.com/iehality/lean4-logic): Uses Mathlib, covers modal logic, provability logic, first-order logic
- [lean4-pdl](https://github.com/m4lvin/lean4-pdl): Uses Mathlib for propositional dynamic logic
- [lean4-modallogic](https://github.com/SnO2WMaN/lean4-modallogic): Merged into FormalizedFormalLogic project (uses Mathlib)

**Standard Practice**: All major Lean 4 logic formalization projects depend on Mathlib.

**Sources**:
- [lean4-modallogic](https://github.com/SnO2WMaN/lean4-modallogic)
- [FormalizedFormalLogic/Foundation](https://github.com/iehality/lean4-logic)
- [lean4-pdl](https://github.com/m4lvin/lean4-pdl)

#### 3.1.5 Search and Discovery Tools

**Loogle**: Pattern-based search for Mathlib theorems
- Query by constant: `Real.sin`
- Query by lemma name: `"differ"`
- Query by subexpression: `_ * (_ ^ _)`
- Query by type: `(?a -> ?b) -> List ?a -> List ?b`

**Lean Search**: Semantic search via LeanSearchClient
- Natural language queries
- Proof state matching

**Value**: Finding relevant lemmas for soundness/completeness proofs.

### 3.2 Costs of Mathlib Dependency

#### 3.2.1 Disk Space

**Typical Size**:
- `.lake` directory: ~5GB
- `~/.cache/mathlib`: Compressed olean files (deletable)
- Project with Mathlib: "3GB of space" per project (varies)

**Mitigation**: Disk space is cheap; 5GB is acceptable for professional development.

#### 3.2.2 Build Time

**Without Cache**:
- "Very large times" to build (specific benchmarks not disclosed)
- Can prevent Lean from running properly in VS Code
- Not practically viable

**With Cache** (`lake exe cache get`):
- Fast builds using precompiled olean files
- Standard practice: always use cache
- Updates synchronized with Mathlib releases

**Mitigation**: `lake exe cache get` is mandatory and well-documented.

#### 3.2.3 Version Management Complexity

**Challenge**:
- Mathlib updates ~20 times per day
- Must synchronize `lean-toolchain` with Mathlib version
- Two projects depending on Mathlib will "with very high probability use distinct versions"

**Best Practices**:
- Pin specific versions: `rev = "v4.14.0"`
- Update incrementally through tagged releases
- Use `lake update` for controlled updates

**Current Status**: Logos already pins v4.14.0 - good practice.

#### 3.2.4 Transitive Dependency Bloat

**Current Transitive Count**: 9 packages (8 inherited)

**Assessment**:
- All inherited dependencies serve legitimate purposes (testing, search, visualization, automation)
- Batteries: Essential standard library extensions
- Aesop: Needed for planned automation (Task 7)
- ProofWidgets4: Interactive theorem proving (useful for development)
- Cli, importGraph, plausible: Development quality of life

**Bloat Concern**: Minimal - dependencies are well-justified.

### 3.3 Costs of Avoiding Mathlib (Independence Strategy)

#### 3.3.1 Reimplementation Effort

**Required Infrastructure**:

1. **Algebraic Hierarchy** (15-25 hours):
   - `Group`, `AddGroup`, `CommGroup`, `AddCommGroup`
   - Group axioms and basic lemmas
   - Subgroups, quotients (if needed for completeness)

2. **Order Theory** (15-25 hours):
   - `PartialOrder`, `LinearOrder`
   - Transitivity, antisymmetry, totality
   - Lattice structures (if needed)

3. **Ordered Algebra** (20-30 hours):
   - `LinearOrderedAddCommGroup` (combining above)
   - Compatibility lemmas between order and addition
   - Monotonicity, order preservation

4. **Proof Automation** (60-80 hours):
   - Reimplement proof search (Aesop alternative)
   - Custom simplifier rules
   - Modal/temporal reasoning tactics

**Total Effort**: 110-160 hours minimum

**Risk**:
- High probability of bugs in custom implementations
- Lack of community review and testing
- Incompatibility with future Lean ecosystem developments

#### 3.3.2 Loss of Community Interoperability

**Consequences**:
- Cannot leverage other Lean 4 logic projects (FormalizedFormalLogic, lean4-pdl)
- Cannot use Mathlib's modal logic results as building blocks
- Custom definitions incompatible with Mathlib-based projects
- Reduced collaboration potential

**Assessment**: Severe impact on research value and extensibility.

#### 3.3.3 Maintenance Burden

**Ongoing Costs**:
- Maintain custom algebra/order theory library
- Track Lean 4 language changes independently
- Update custom tactics with each Lean release
- Debug interaction with Lean core library changes

**Estimated Annual Effort**: 40-60 hours

**Sources**:
- [How to use the most bare essentials of Lean 4?](https://proofassistants.stackexchange.com/questions/2632/how-to-use-the-most-bare-essentials-of-lean-4)

---

## 4. Standard Practice in Lean 4 Community

### 4.1 Theorem Proving Projects

**Consensus**: Use Mathlib unless there are compelling reasons not to.

**Rationale**:
- "It is generally a good idea to use the Mathlib provided terminology"
- Identities like summing constants are "already covered by Mathlib"
- Powerful `simp` tactic uses "thousands of simp lemmas Mathlib has to offer"

**Bare-Bones Alternative**:
- "You can define your own version of Nat... or even your own version of `=`"
- "If you want to be really bare bones, you don't need tactics at all. You can just do term proofs."
- Recommended for: Learning type theory foundations, not practical theorem proving

**Sources**:
- [How to use the most bare essentials of Lean 4?](https://proofassistants.stackexchange.com/questions/2632/how-to-use-the-most-bare-essentials-of-lean-4)
- [Learning Lean 4](https://leanprover-community.github.io/learn.html)

### 4.2 Logic Formalization Projects

**Survey of Projects**:

| Project | Domain | Mathlib Dependency |
|---------|--------|-------------------|
| FormalizedFormalLogic | Modal, provability, FOL, arithmetic | Yes |
| lean4-pdl | Propositional dynamic logic | Yes |
| lean4-modallogic | Basic modal logic | Yes (via Foundation) |

**Pattern**: 100% of surveyed modal/temporal logic projects use Mathlib.

**Conclusion**: Using Mathlib is standard practice for logic formalization.

### 4.3 Dependency Management Philosophy

**Community Guidance**:
- "If your project depends on std4 or quote4, let mathlib4 pull them transitively. Don't require them in your lakefile.lean."
- Pin versions explicitly: `rev = "v4.14.0"`
- Use tagged releases for stability
- Always use `lake exe cache get`

**Current Logos Practice**: Already follows best practices (pinned v4.14.0).

---

## 5. Recommendations for Logos Project

### 5.1 Primary Recommendation: Maintain Mathlib Dependency

**Rationale**:
1. **Technical Necessity**: `LinearOrderedAddCommGroup` only exists in Mathlib
2. **Economic**: Reimplementation would cost 110-160 hours with high risk
3. **Standard Practice**: All similar projects use Mathlib
4. **Future Value**: Enables Aesop integration for Task 7 (tm_auto tactic)
5. **Ecosystem**: Maintains compatibility with Lean 4 community

**Cost**: Already paid (5GB disk, version management complexity)

**Benefit**: Access to 100+ hours of pre-built infrastructure

### 5.2 Optimization Strategy: Minimize Direct Mathlib Imports

**Current Status**: Only one direct import (`Mathlib.Algebra.Order.Group.Defs`)

**Best Practice**: Continue minimizing direct imports
- Use only what is needed
- Document each Mathlib import with justification
- Consider aliases for frequently used Mathlib types

**Example**:
```lean
-- Logos/Core/Semantics/TaskFrame.lean
import Mathlib.Algebra.Order.Group.Defs
-- Justification: LinearOrderedAddCommGroup for temporal duration structure
```

### 5.3 Dependency Hygiene Guidelines

#### 5.3.1 Import Discipline

**Rule**: Each Mathlib import must have documented justification.

**Template**:
```lean
import Mathlib.Path.To.Module
-- Justification: [Specific typeclass/theorem needed and why]
```

#### 5.3.2 Transitive Dependency Awareness

**Monitor**:
- Run `lake deps` to visualize dependency graph
- Periodically audit `lake-manifest.json` for unexpected additions
- Document rationale for each transitive dependency in CLAUDE.md

#### 5.3.3 Version Pinning Discipline

**Current Practice** (Good):
```toml
rev = "v4.14.0"
```

**Maintain**:
- Only update for specific reasons (bug fixes, needed features)
- Update incrementally through tagged releases
- Test thoroughly after each update
- Document update rationale in git commit message

### 5.4 Alternative Exploration (Low Priority)

**If Independence is a Research Goal**:

Consider implementing a **minimal algebra core** for pedagogical/research purposes while keeping Mathlib for practical work:

1. Create `Logos/Core/Foundations/` directory
2. Implement minimal `LinearOrderedAddCommGroup` from first principles
3. Prove equivalence to Mathlib version
4. Use Mathlib version for actual proofs
5. Reference foundations version in documentation

**Effort**: 30-50 hours
**Value**: Educational, demonstrates self-containment, research contribution
**Risk**: Low (parallel implementation, not replacement)

### 5.5 Aesop Integration Plan

**Context**: Task 7 (Implement Core Automation) is 33% complete, blocked on Aesop integration.

**Current Blocker**: "Aesop integration blocked by Batteries dependency breaking Truth.lean"

**Recommendation**:
1. Investigate Truth.lean compatibility issue (4-8 hours)
2. Fix type conflicts introduced by Batteries (likely namespace or typeclass collision)
3. Complete Aesop integration (6-8 hours)
4. Implement `tm_auto` tactic using Aesop rule sets

**ROI**: High - 15-20 hour investment enables comprehensive proof automation.

---

## 6. Specific Answers to Research Questions

### 6.1 What are the virtues of including dependencies?

**Virtues**:
1. **Technical Necessity**: `LinearOrderedAddCommGroup` exists only in Mathlib
2. **Proof Automation**: Aesop enables Task 7 (tm_auto tactic) with 60-80 hours savings
3. **Standard Definitions**: Community-vetted algebra/order theory infrastructure
4. **Interoperability**: Compatibility with other Lean 4 logic projects
5. **Ecosystem Access**: Search tools (Loogle, LeanSearch), tactics (simp, ring, omega)
6. **Development Velocity**: 100+ hours of infrastructure available immediately
7. **Quality Assurance**: Battle-tested code with community review

### 6.2 What are the costs of including dependencies?

**Costs**:
1. **Disk Space**: 5GB per project (`.lake` directory)
2. **Build Time**: Requires `lake exe cache get` for reasonable build times
3. **Version Management**: Must synchronize with Mathlib releases (~20/day)
4. **Complexity**: 9 transitive dependencies (though well-justified)
5. **Update Friction**: Must track Mathlib changes, update incrementally
6. **Learning Curve**: Must understand Mathlib organization and conventions

**Assessment**: All costs are manageable with standard practices (pinning, caching).

### 6.3 What are the prospects for building needed infrastructure?

**Feasibility Assessment**:

| Component | Effort | Feasibility | Recommendation |
|-----------|--------|-------------|----------------|
| LinearOrderedAddCommGroup | 20-40h | Possible | Don't - already in Mathlib |
| Full algebra hierarchy | 15-25h | Possible | Don't - maintenance burden |
| Order theory | 15-25h | Possible | Don't - reinventing wheel |
| Proof automation | 60-80h | Difficult | Don't - Aesop is better |
| **Total** | **110-160h** | **Not Recommended** | Use Mathlib |

**Conclusion**: Building from scratch is feasible but economically irrational.

### 6.4 What is considered standard practice?

**Standard Practice** (100% of surveyed projects):
1. Depend on Mathlib for algebra, order theory, tactics
2. Pin specific versions: `rev = "v4.14.0"`
3. Use `lake exe cache get` for builds
4. Update incrementally through tagged releases
5. Let Mathlib pull transitive dependencies (Batteries, Aesop)
6. Use Mathlib terminology and conventions

**Logos Current Status**: ✓ Already follows standard practice

**Sources**:
- [Using mathlib4 as a dependency](https://github.com/leanprover-community/mathlib4/wiki/Using-mathlib4-as-a-dependency)
- [FormalizedFormalLogic projects](https://github.com/iehality/lean4-logic)

### 6.5 Should you economize dependencies?

**Nuanced Answer**:

**Don't Economize** (recommended):
- Mathlib dependency is technically necessary
- Transitive dependencies (Aesop, Batteries) provide high value
- Community standard practice is to use Mathlib
- Cost-benefit analysis strongly favors keeping dependencies

**Do Economize** (implement these practices):
- Minimize direct Mathlib imports (current: 1 import - excellent)
- Document justification for each import
- Monitor transitive dependencies for unexpected additions
- Use specific Mathlib modules, not `import Mathlib` (blanket import)

**Conclusion**: Economize **granularity of imports**, not **total dependency count**.

---

## 7. Conclusion

### 7.1 Summary of Findings

1. **Logos already depends on Mathlib**, which transitively includes Aesop and Batteries
2. **`LinearOrderedAddCommGroup` exists only in Mathlib**, making the dependency technically necessary
3. **All Lean 4 modal/temporal logic projects use Mathlib** (standard practice)
4. **Reimplementing needed infrastructure would cost 110-160 hours** with high risk
5. **Current dependency management practices are excellent** (pinned version, minimal imports)

### 7.2 Final Recommendation

**Maintain Mathlib dependency with current best practices:**

✅ **Keep**:
- Mathlib v4.14.0 (pinned)
- Transitive dependencies (Aesop, Batteries, etc.)
- Minimal direct imports (currently 1)

✅ **Continue**:
- Pinning specific versions
- Using `lake exe cache get`
- Documenting import justifications
- Following community standards

✅ **Add**:
- Fix Truth.lean Batteries compatibility (Task 7 blocker)
- Complete Aesop integration for tm_auto tactic
- Monitor transitive dependencies periodically

❌ **Don't**:
- Attempt to remove Mathlib dependency
- Reimplement algebra/order theory infrastructure
- Build custom proof automation from scratch

### 7.3 Cost-Benefit Bottom Line

**Keeping Mathlib**:
- Cost: Already paid (5GB disk, version management)
- Benefit: 100+ hours of infrastructure, community compatibility, future automation

**Removing Mathlib**:
- Cost: 110-160 hours reimplementation + 40-60 hours annual maintenance
- Benefit: "Independence" (purely philosophical, no technical gain)
- Risk: Bugs, incompatibility, isolation from community

**Verdict**: Keeping Mathlib is the economically and technically rational choice.

---

## 8. References

### 8.1 Aesop Resources

- [GitHub - leanprover-community/aesop](https://github.com/leanprover-community/aesop)
- [Aesop: White-Box Best-First Proof Search for Lean](https://dl.acm.org/doi/10.1145/3573105.3575671)
- [Aesop Tactic in Lean](https://proofassistants.stackexchange.com/questions/2222/aesop-tactic-in-lean)
- [Tactic Script Optimisation for Aesop](https://dl.acm.org/doi/10.1145/3703595.3705877)

### 8.2 Mathlib Resources

- [GitHub - leanprover-community/mathlib4](https://github.com/leanprover-community/mathlib4)
- [Using mathlib4 as a dependency](https://github.com/leanprover-community/mathlib4/wiki/Using-mathlib4-as-a-dependency)
- [Updating Dependencies in a Lean (+ Mathlib) Project](https://malv.in/posts/2024-12-09-howto-update-lean-dependencies.html)
- [Mathlib Documentation](https://leanprover-community.github.io/mathlib4_docs/index.html)

### 8.3 Batteries Resources

- [GitHub - leanprover-community/batteries](https://github.com/leanprover-community/batteries)
- [leanprover/std4](https://github.com/leanprover/std4)

### 8.4 Best Practices Resources

- [How to use the most bare essentials of Lean 4?](https://proofassistants.stackexchange.com/questions/2632/how-to-use-the-most-bare-essentials-of-lean-4)
- [Learning Lean 4](https://leanprover-community.github.io/learn.html)
- [Lean projects](https://leanprover-community.github.io/install/project.html)

### 8.5 Logic Formalization Projects

- [FormalizedFormalLogic/Foundation](https://github.com/iehality/lean4-logic)
- [lean4-pdl](https://github.com/m4lvin/lean4-pdl)
- [lean4-modallogic](https://github.com/SnO2WMaN/lean4-modallogic)
- [Lean4 Logic Formalization Book](https://formalizedformallogic.github.io/Book/)

---

## Appendix A: Logos Current Dependency Graph

```
Logos (v0.1.0)
└── mathlib (v4.14.0) [DIRECT]
    ├── plausible [INHERITED]
    ├── LeanSearchClient [INHERITED]
    ├── importGraph [INHERITED]
    ├── proofwidgets [INHERITED]
    ├── aesop [INHERITED]
    │   └── batteries [INHERITED]
    ├── Qq (quote4) [INHERITED]
    ├── batteries [INHERITED]
    └── Cli [INHERITED]
```

**Total**: 1 direct, 8 transitive = 9 packages

## Appendix B: Mathlib Import Analysis

**Files Importing Mathlib**: 1 of 148 Lean files (0.68%)

**Import Location**:
```
Logos/Core/Semantics/TaskFrame.lean:1
```

**Import Statement**:
```lean
import Mathlib.Algebra.Order.Group.Defs
```

**Usage**:
```lean
structure TaskFrame (T : Type*) [LinearOrderedAddCommGroup T] where
  WorldState : Type
  task_rel : WorldState → T → WorldState → Prop
  nullity : ∀ w, task_rel w 0 w
  compositionality : ∀ w u v x y, task_rel w x u → task_rel u y v → task_rel w (x + y) v
```

**Assessment**: Minimal, justified, essential import.

## Appendix C: Task 7 Automation Roadmap

**Goal**: Implement `tm_auto` tactic for comprehensive TM proof automation

**Current Status** (from TODO.md):
- 4/12 tactics implemented (33% complete)
- Blocker: Aesop integration breaks Truth.lean

**Completed Tactics**:
1. `apply_axiom` (macro)
2. `modal_t` (macro)
3. `tm_auto` (native implementation, pre-Aesop)
4. `assumption_search` (elab)

**Remaining Work**:
1. Fix Truth.lean Batteries compatibility (4-8 hours)
2. Complete Aesop integration (6-8 hours)
3. Implement 8 remaining tactics (30-40 hours)
4. Expand test suite (5-10 hours)

**Total Remaining**: 45-66 hours

**Value**: Comprehensive proof automation for TM logic

**Dependencies**: Aesop (already available transitively via Mathlib)

---

**Report Status**: COMPLETE
**Recommendation**: Maintain current Mathlib dependency; economize import granularity, not dependency count.
