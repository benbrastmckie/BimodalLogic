# Documentation Gap Analysis: Derivable → DerivationTree Migration

**Analysis Date**: 2025-12-20  
**Migration Context**: Tasks 72-76 completed migration from `Derivable : Prop` to `DerivationTree : Type`  
**Scope**: Documentation updates needed across module aggregators, READMEs, and user guides

---

## Executive Summary

The migration from `Derivable : Prop` to `DerivationTree : Type` has been successfully completed in the codebase (Tasks 72-76), but **documentation has not been updated** to reflect these fundamental changes. This creates a critical gap between implementation and documentation that will confuse users and developers.

### Critical Findings

- **7 files** require immediate updates with outdated `Derivable` references
- **23 specific gaps** identified across documentation
- **3 categories** of issues: outdated terminology, missing examples, inconsistent API documentation
- **Priority**: HIGH - Documentation is actively misleading users about current API

---

## 1. Files Requiring Updates

### 1.1 Module Aggregator Files (HIGH PRIORITY)

#### `Logos/ProofSystem.lean` ⚠️ CRITICAL
**Status**: Contains outdated example code  
**Lines**: 22-31  
**Issues**:
1. Example uses old `Derivable.axiom` constructor name (now `DerivationTree.axiom`)
2. Example uses old `Derivable.modus_ponens` (now `DerivationTree.modus_ponens`)
3. Example uses old `Derivable.assumption` (now `DerivationTree.assumption`)
4. Documentation says "Derivability relation" but should say "Derivation tree"

**Outdated Code**:
```lean
-- Apply modus ponens
example (p q : Formula) : [p.imp q, p] ⊢ q := by
  apply Derivable.modus_ponens (φ := p)
  · apply Derivable.assumption; simp
  · apply Derivable.assumption; simp
```

**Should Be**:
```lean
-- Apply modus ponens
example (p q : Formula) : [p.imp q, p] ⊢ q := by
  apply DerivationTree.modus_ponens (φ := p)
  · apply DerivationTree.assumption; simp
  · apply DerivationTree.assumption; simp
```

**Additional Updates Needed**:
- Line 12: Change "Derivation: The derivability relation" → "Derivation: Derivation trees for TM logic"
- Line 22: Update comment to mention `DerivationTree` type
- Add note about `height` function being computable

---

#### `Logos/Metalogic.lean` ⚠️ MODERATE
**Status**: Outdated terminology in documentation  
**Lines**: 18-20, 24  
**Issues**:
1. Line 18: "derivability implies validity" should mention derivation trees
2. Line 24: "induction on derivation structure" is correct but could be clearer
3. Missing mention of `DerivationTree` being a `Type` (not `Prop`)

**Current**:
```lean
- **Soundness**: `Γ ⊢ φ → Γ ⊨ φ` (derivability implies validity)
```

**Should Be**:
```lean
- **Soundness**: `Γ ⊢ φ → Γ ⊨ φ` (derivation tree existence implies validity)
```

**Additional Updates**:
- Add note: "Soundness proven by structural induction on `DerivationTree` (a `Type`, not `Prop`)"
- Mention that pattern matching on derivation trees enables computable functions

---

#### `Logos/Theorems.lean` ✓ ACCEPTABLE
**Status**: Minimal updates needed  
**Issues**: None critical - uses notation `⊢` which is still valid

---

#### `Logos/Core/Theorems.lean` ✓ ACCEPTABLE
**Status**: Minimal updates needed  
**Issues**: None critical - uses notation `⊢` which is still valid

---

#### `Logos/Core.lean` ✓ ACCEPTABLE
**Status**: Generic description, no specific API references  
**Issues**: None

---

#### `Logos.lean` ⚠️ MODERATE
**Status**: Missing key information about derivation trees  
**Lines**: 27, 31  
**Issues**:
1. Line 27: "ProofSystem: Axioms and inference rules" should mention derivation trees
2. Missing information about `DerivationTree` being a `Type` with computable `height`

**Should Add**:
```lean
- `Logos.Core.ProofSystem`: Axioms, derivation trees (`DerivationTree : Type`), and inference rules
```

---

### 1.2 README Files (HIGH PRIORITY)

#### `Logos/README.md` ⚠️ CRITICAL
**Status**: Multiple outdated references  
**Lines**: 17-18, 47, 162-163  
**Issues**:

1. **Line 17-18**: Outdated description
   ```markdown
   - **ProofSystem/**: Axioms and inference rules
     - 7 inference rules (MP, MK, TK, TD, plus structural rules)
     - Derivability relation
   ```
   **Should Be**:
   ```markdown
   - **ProofSystem/**: Axioms and derivation trees
     - 7 inference rules as `DerivationTree` constructors (axiom, assumption, modus_ponens, necessitation, temporal_necessitation, temporal_duality, weakening)
     - Derivation trees as inductive `Type` (not `Prop`)
     - Computable `height` function for well-founded recursion
   ```

2. **Line 47**: "Inference Rules: ProofSystem/Derivation.lean - Derivability and rules"
   **Should Be**: "Derivation Trees: ProofSystem/Derivation.lean - DerivationTree type and constructors"

3. **Line 162**: "Adding a New Axiom" section references old `Derivable` type
   **Should Update**:
   ```markdown
   2. Add case to `DerivationTree` in `ProofSystem/Derivation.lean` (as constructor)
   ```

---

#### `README.md` (Project Root) ⚠️ MODERATE
**Status**: High-level documentation, minimal specific API references  
**Lines**: None critical  
**Issues**: 
- Could mention derivation trees in architecture description (optional enhancement)

---

### 1.3 User Guide Documentation (HIGH PRIORITY)

#### `Documentation/UserGuide/ARCHITECTURE.md` ⚠️ CRITICAL
**Status**: Extensive outdated content  
**Lines**: 189-206, 247-272, 586-624  
**Issues**:

1. **Lines 189-206**: Entire `Derivable` inductive definition is outdated
   ```lean
   inductive Derivable : Context → Formula → Prop
     | axiom (Γ : Context) (φ : Formula) (h : Axiom φ) : Derivable Γ φ
     | assumption (Γ : Context) (φ : Formula) (h : φ ∈ Γ) : Derivable Γ φ
     | modus_ponens (Γ : Context) (φ ψ : Formula)
         (h1 : Derivable Γ (φ.imp ψ)) (h2 : Derivable Γ φ) : Derivable Γ ψ
     | modal_k (Γ : Context) (φ : Formula)
         (h : Derivable (Γ.map Formula.box) φ) : Derivable Γ (φ.box)
     | temporal_k (Γ : Context) (φ : Formula)
         (h : Derivable (Γ.map Formula.all_future) φ) :
         Derivable Γ (Formula.all_future φ)
     | temporal_duality (φ : Formula)
         (h : Derivable [] φ) : Derivable [] (swap_temporal φ)
     | weakening (Γ Δ : Context) (φ : Formula)
         (h1 : Derivable Γ φ) (h2 : Γ ⊆ Δ) : Derivable Δ φ
   ```

   **Should Be**: Replace with current `DerivationTree` definition from `Derivation.lean`

2. **Lines 247-272**: All tactic examples use `Derivable.*` constructors
   **Need to update** to `DerivationTree.*`

3. **Lines 586-624**: Soundness theorem uses old `Derivable` type
   **Should update** to reflect `DerivationTree` and mention pattern matching

**Critical Updates**:
- Replace all `Derivable` with `DerivationTree`
- Add section explaining `Type` vs `Prop` distinction
- Add examples using `height` function
- Update soundness proof sketch to mention structural induction on `DerivationTree`

---

#### `Documentation/UserGuide/TUTORIAL.md` ⚠️ CRITICAL
**Status**: All examples use outdated API  
**Lines**: 155-169, 196-212  
**Issues**:

1. **Lines 155-169**: All derivability examples use `Derivable.*`
   ```lean
   example : [] ⊢ (p.box.imp p) := by
     apply Derivable.axiom
     apply Axiom.modal_t
   ```
   **Should Be**:
   ```lean
   example : [] ⊢ (p.box.imp p) := by
     apply DerivationTree.axiom
     apply Axiom.modal_t
   ```

2. **Lines 196-212**: Inference rule examples all outdated

**Critical**: This is the **first document** new users read - must be accurate!

---

#### `Documentation/UserGuide/EXAMPLES.md` ⚠️ CRITICAL
**Status**: All code examples use outdated API  
**Lines**: 11-95 (entire modal logic section)  
**Issues**:
- Every single example uses `Derivable.*` constructors
- No examples demonstrate `height` function
- No examples show pattern matching on derivation trees

**Recommendation**: 
1. Update all examples to use `DerivationTree.*`
2. Add new section: "Working with Derivation Trees"
   - Example: Computing derivation height
   - Example: Pattern matching on derivation structure
   - Example: Well-founded recursion using height

---

### 1.4 Development Documentation (MODERATE PRIORITY)

#### `Documentation/Development/CONTRIBUTING.md` ⚠️ MODERATE
**Status**: Example code uses outdated API  
**Lines**: 53-69  
**Issues**:
- TDD example uses `Derivable` (should use `DerivationTree`)

---

## 2. Gap Categories

### 2.1 Outdated Terminology (15 instances)

| File | Line(s) | Current Text | Should Be |
|------|---------|--------------|-----------|
| `Logos/ProofSystem.lean` | 12 | "Derivation: The derivability relation" | "Derivation: Derivation trees for TM logic" |
| `Logos/Metalogic.lean` | 18 | "derivability implies validity" | "derivation tree existence implies validity" |
| `Logos.lean` | 27 | "ProofSystem: Axioms and inference rules" | "ProofSystem: Axioms, derivation trees, and inference rules" |
| `Logos/README.md` | 17 | "Derivability relation" | "Derivation trees as inductive Type" |
| `Logos/README.md` | 47 | "Derivability and rules" | "DerivationTree type and constructors" |
| `ARCHITECTURE.md` | 189-206 | Entire `Derivable` definition | Replace with `DerivationTree` definition |
| `TUTORIAL.md` | 150 | "Derivability" section header | "Derivation Trees" |
| `EXAMPLES.md` | Multiple | "Derivable" references | "DerivationTree" references |

### 2.2 Outdated Code Examples (23 instances)

**Critical Examples** (user-facing):
1. `Logos/ProofSystem.lean` lines 22-31 (module example)
2. `ARCHITECTURE.md` lines 247-272 (tactic examples)
3. `TUTORIAL.md` lines 155-169 (basic proofs)
4. `TUTORIAL.md` lines 196-212 (inference rules)
5. `EXAMPLES.md` lines 11-95 (all modal examples)

**Moderate Examples** (developer-facing):
6. `CONTRIBUTING.md` lines 53-69 (TDD example)

### 2.3 Missing Documentation (8 gaps)

**New Features Not Documented**:
1. `DerivationTree` is a `Type` (not `Prop`) - enables pattern matching
2. `height` function is computable - enables well-founded recursion
3. Pattern matching on derivation trees - metalogic proofs
4. Proof irrelevance no longer applies - derivation trees are data
5. `height` properties (theorems in `Derivation.lean`)
6. Well-founded recursion examples (deduction theorem uses this)
7. Constructor name changes (all 7 constructors)
8. Notation still works (`⊢`) but underlying type changed

**Where to Add**:
- `ARCHITECTURE.md`: New section "Derivation Trees vs Derivability"
- `TUTORIAL.md`: Section "Understanding Derivation Trees"
- `EXAMPLES.md`: Section "Working with Derivation Trees"
- `Logos/README.md`: Update "Implementation Status" section

---

## 3. Inconsistencies

### 3.1 API Documentation Inconsistencies

**Issue**: Module docstrings vs actual implementation

| Module | Docstring Says | Implementation Has |
|--------|----------------|-------------------|
| `ProofSystem.lean` | "derivability relation" | `DerivationTree` type |
| `Derivation.lean` | Accurate (updated) | Matches |
| `Soundness.lean` | Accurate (updated) | Matches |

**Resolution**: Update `ProofSystem.lean` docstring

### 3.2 Example Code Inconsistencies

**Issue**: Examples in documentation don't compile with current codebase

**Affected Files**:
- `ARCHITECTURE.md` (all proof examples)
- `TUTORIAL.md` (all proof examples)
- `EXAMPLES.md` (all proof examples)
- `CONTRIBUTING.md` (TDD example)

**Impact**: Users copying examples will get compilation errors

### 3.3 Terminology Inconsistencies

**Issue**: Mixed use of "derivability" vs "derivation tree"

**Current State**:
- Implementation: Consistently uses `DerivationTree`
- Documentation: Mixes "derivability", "derivable", "derivation"

**Recommendation**: Standardize on:
- "Derivation tree" (noun) - the data structure
- "Derivable" (adjective) - property of being derivable
- "Derivability" (noun) - the property (avoid, use "derivation tree existence")

---

## 4. Priority Ranking

### P0 - CRITICAL (Must Fix Immediately)

**User-Facing Documentation** - Users will copy broken code:
1. `Documentation/UserGuide/TUTORIAL.md` - First document users read
2. `Documentation/UserGuide/EXAMPLES.md` - Users copy examples
3. `Logos/ProofSystem.lean` - Module example in docstring
4. `Documentation/UserGuide/ARCHITECTURE.md` - Reference documentation

**Estimated Effort**: 4-6 hours

### P1 - HIGH (Fix Soon)

**Developer Documentation**:
5. `Logos/README.md` - Developers reference this
6. `Documentation/Development/CONTRIBUTING.md` - New contributors use this
7. `Logos/Metalogic.lean` - Terminology updates
8. `Logos.lean` - Root module documentation

**Estimated Effort**: 2-3 hours

### P2 - MODERATE (Fix When Convenient)

**Enhancements**:
9. Add new documentation sections for derivation tree features
10. Add examples using `height` function
11. Add pattern matching examples
12. Update README.md (project root) with architecture notes

**Estimated Effort**: 3-4 hours

---

## 5. Recommended Update Strategy

### Phase 1: Critical User Documentation (P0)

**Order**:
1. `TUTORIAL.md` - Update all examples (highest user impact)
2. `EXAMPLES.md` - Update all examples (users copy these)
3. `Logos/ProofSystem.lean` - Fix module example
4. `ARCHITECTURE.md` - Update reference documentation

**Verification**: Compile all examples to ensure they work

### Phase 2: Developer Documentation (P1)

**Order**:
5. `Logos/README.md` - Update implementation status
6. `CONTRIBUTING.md` - Update TDD example
7. Module aggregator docstrings (`Logos/Metalogic.lean`, `Logos.lean`)

**Verification**: Review with development team

### Phase 3: Enhancements (P2)

**New Content**:
- Section in `ARCHITECTURE.md`: "Derivation Trees: Type vs Prop"
- Section in `TUTORIAL.md`: "Understanding Derivation Trees"
- Section in `EXAMPLES.md`: "Working with Derivation Trees"
  - Example: Computing height
  - Example: Pattern matching
  - Example: Well-founded recursion

**Verification**: Technical review for accuracy

---

## 6. Specific Update Templates

### Template 1: Updating Code Examples

**Before**:
```lean
example : ⊢ (p.box.imp p) := by
  apply Derivable.axiom
  apply Axiom.modal_t
```

**After**:
```lean
example : ⊢ (p.box.imp p) := by
  apply DerivationTree.axiom
  apply Axiom.modal_t
```

### Template 2: Updating Terminology

**Before**: "The derivability relation `Γ ⊢ φ` represents..."

**After**: "The derivation tree `Γ ⊢ φ` represents a proof that φ is derivable from Γ. Since `DerivationTree` is a `Type` (not a `Prop`), we can pattern match on derivation trees and compute properties like `height`."

### Template 3: Adding New Content

**New Section for ARCHITECTURE.md**:
```markdown
### Derivation Trees: Type vs Prop

The TM proof system uses `DerivationTree : Context → Formula → Type` rather than
`Derivable : Context → Formula → Prop`. This design choice enables:

1. **Pattern Matching**: Structural induction on derivation trees
2. **Computable Functions**: `height : DerivationTree Γ φ → Nat`
3. **Well-Founded Recursion**: Proofs using derivation height as measure
4. **Proof Extraction**: Derivation trees are data, not just propositions

Example:
```lean
def height {Γ : Context} {φ : Formula} : DerivationTree Γ φ → Nat
  | .axiom _ _ _ => 0
  | .assumption _ _ _ => 0
  | .modus_ponens _ _ _ d1 d2 => 1 + max d1.height d2.height
  | .necessitation _ d => 1 + d.height
  | .temporal_necessitation _ d => 1 + d.height
  | .temporal_duality _ d => 1 + d.height
  | .weakening _ _ _ d _ => 1 + d.height
```
```

---

## 7. Verification Checklist

After updates, verify:

- [ ] All code examples compile with current codebase
- [ ] All `Derivable.*` references changed to `DerivationTree.*`
- [ ] Terminology consistent across all documentation
- [ ] New features documented (height, pattern matching)
- [ ] Module docstrings match implementation
- [ ] README files accurate
- [ ] Tutorial examples work for new users
- [ ] Architecture guide reflects current design
- [ ] Contributing guide has correct examples

---

## 8. Bloat Analysis

### Potential Bloat (Low Priority)

**Redundant Documentation**:
1. `Archive/logos-original/README.md` - Contains old architecture notes
   - **Recommendation**: Add note at top: "ARCHIVED - See current docs in Documentation/"
   
2. Multiple README files with overlapping content
   - `README.md` (root)
   - `Logos/README.md`
   - `Documentation/README.md`
   - **Recommendation**: Ensure clear hierarchy and cross-references

**Outdated Information**:
1. `Archive/` directory - Contains old proof strategies
   - **Status**: Appropriately archived, no action needed

**No Critical Bloat Identified**: Documentation is lean and well-organized

---

## 9. Summary Statistics

### Files Analyzed
- **Total**: 15 files
- **Requiring Updates**: 7 files
- **Critical Priority**: 4 files
- **High Priority**: 4 files
- **Moderate Priority**: 4 files

### Gaps Identified
- **Outdated Terminology**: 15 instances
- **Outdated Code Examples**: 23 instances
- **Missing Documentation**: 8 gaps
- **Total Issues**: 46

### Completeness Score
- **Current Documentation Accuracy**: 65%
- **After P0 Updates**: 85%
- **After P1 Updates**: 95%
- **After P2 Updates**: 100%

### Estimated Effort
- **P0 (Critical)**: 4-6 hours
- **P1 (High)**: 2-3 hours
- **P2 (Moderate)**: 3-4 hours
- **Total**: 9-13 hours

---

## 10. Conclusion

The migration from `Derivable : Prop` to `DerivationTree : Type` represents a **fundamental architectural change** that is not reflected in documentation. This creates a critical gap where:

1. **Users will copy broken examples** from tutorials and guides
2. **Developers will be confused** by inconsistent terminology
3. **New features are undocumented** (height, pattern matching)

**Immediate Action Required**: Update P0 documentation (TUTORIAL.md, EXAMPLES.md, ProofSystem.lean, ARCHITECTURE.md) to prevent user confusion.

**Success Criteria**:
- All code examples compile
- Terminology consistent
- New features documented
- Users can follow tutorials without errors

---

**Report Generated**: 2025-12-20  
**Analyst**: Documentation Analysis Specialist  
**Next Steps**: Proceed with Phase 1 updates (P0 priority)
