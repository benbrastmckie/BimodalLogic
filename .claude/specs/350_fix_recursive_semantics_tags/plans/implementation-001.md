# Implementation Plan: Task #350

**Task**: Address all FIX tags in RECURSIVE_SEMANTICS.md systematically
**Version**: 001
**Created**: 2026-01-10
**Language**: markdown

## Overview

This plan systematically addresses 18 FIX tags in RECURSIVE_SEMANTICS.md through 6 phases, progressing from terminology changes through cross-document consistency updates. The implementation maintains document integrity by making changes in logical order: terminology first (affects most content), then notation, then content additions, structural changes, new extensions, and finally cross-document updates.

## Phases

### Phase 1: Terminology Changes

**Estimated effort**: 1 hour
**Status**: [NOT STARTED]

**Objectives**:
1. Rename "Layer" to "Extension" throughout document
2. Rename "Constitutive Layer" to "Constitutive Foundation"
3. Rename "Causal Layer" to "Core Extension"
4. Remove alliteration "Logos layered logic system"
5. Update section headers and references

**Files to modify**:
- `Documentation/Research/RECURSIVE_SEMANTICS.md` - All terminology changes

**Steps**:
1. Replace "Constitutive Layer" with "Constitutive Foundation" (preserve meaning)
2. Replace "Causal Layer" with "Core Extension"
3. Replace remaining "Layer" with "Extension" (except where contextually inappropriate)
4. Replace "Logos layered logic system" with "Logos system" or similar
5. Update section headers: "## Constitutive Layer:" → "## Constitutive Foundation:"
6. Update section headers: "## Causal Layer:" → "## Core Extension:"
7. Review all changes for consistency

**Verification**:
- No remaining "Layer" terminology (except quoted external sources)
- Document renders correctly in markdown preview
- Cross-references still valid

---

### Phase 2: Notation Changes

**Estimated effort**: 45 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Change variable assignment notation from "a̅" to "v" style
2. Rename "time vector" to "temporal index"
3. Change imposition notation from "⊳" to "→"

**Files to modify**:
- `Documentation/Research/RECURSIVE_SEMANTICS.md` - All notation changes

**Steps**:
1. Replace "a̅" with "v" for variable assignments (lines 88-96, etc.)
2. Update "a̅ : Var → S" to "v : Var → S"
3. Update all "a̅[v/x]" notation to "v[s/x]" (or clarify subscript style like v_1, v_2)
4. Replace "time vector v⃗" with "temporal index" (line 251+)
5. Update all subsequent references to time vector
6. Replace "t ⊳_w w'" with "t →_w w'" for imposition (line 335+)
7. Update imposition notation explanation to use "→"

**Verification**:
- No "a̅" notation remains
- No "time vector" terminology remains
- No "⊳" symbols remain
- Mathematical expressions render correctly

---

### Phase 3: Formatting Cleanup

**Estimated effort**: 30 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Remove all "**Note**:" labels
2. Integrate note content into surrounding text
3. Ensure consistent formatting throughout

**Files to modify**:
- `Documentation/Research/RECURSIVE_SEMANTICS.md` - All formatting fixes

**Steps**:
1. Line 215-217: Remove "**Note**:" label, integrate explanation into paragraph
2. Line 239-241: Remove "**Note**:" label, integrate world-history explanation
3. Line 262-264: Remove "**Note**:" label, integrate derivability note
4. Line 335-337: Remove label, integrate imposition explanation
5. Review document for any other "Note" labels
6. Ensure paragraph flow is maintained after label removal

**Verification**:
- No "**Note**:" labels remain
- Content is smoothly integrated
- No orphaned paragraphs

---

### Phase 4: Content Additions

**Estimated effort**: 2.5 hours
**Status**: [NOT STARTED]

**Objectives**:
1. Add frame/language correspondence explanation
2. Add non-modal frame clarification
3. Add containment constraint for functions
4. Add 1-place predicate intuition
5. Define essence and ground via identity with bilattice reference
6. Clarify identity sentences and evaluation overlap
7. Add universal quantifier and actuality predicate semantics

**Files to modify**:
- `Documentation/Research/RECURSIVE_SEMANTICS.md` - Content additions

**Steps**:

**Step 1** (Line 18): Add frame/language correspondence explanation:
```markdown
A frame provides semantic primitives used to interpret a formal language. Extending the expressive power of the language requires strategic extensions to the primitive semantic resources provided by the frame, including precisely the resources needed and nothing more, ensuring language and frame remain in step with each other.
```

**Step 2** (Line 58): Add non-modal frame note:
```markdown
The constitutive frame is non-modal: possibility and compatibility cannot be defined at this level since they require the task relation introduced in the Core Extension.
```

**Step 3** (Line 75): Add containment constraint:
```markdown
For any function f in v_F or f_F, and any n states a_1, ..., a_n, these states are all parts of f(a_1,...,a_n). However, f(a_1,...,a_n) may have additional parts beyond the input states.
```

**Step 4** (Line 84): Add 1-place predicate intuition:
```markdown
For 1-place predicates, v_F and f_F include functions taking an object (which is itself a state) as input, returning that object instantiating a verifying or falsifying property instance for the property in question.
```

**Step 5** (Line 153): Add essence/ground definitions with bilattice reference:
```markdown
**Essence and Ground**: These relations can be defined via identity:
- A ⊑ B (A is essential to B) := A ∧ B ≡ B
- A ≤ B (A grounds B) := A ∨ B ≡ B

Negation distributes so that A ⊑ B iff ¬A ≤ ¬B, and A ≤ B iff ¬A ⊑ ¬B. The space of bilateral propositions forms a non-interlaced bilattice (Ginsberg 1988, Fitting 1989-2002) where negation exchanges the two lattice orderings.
```

**Step 6** (Line 182): Add identity sentences clarification:
```markdown
Identity sentences are formed from non-identity (extensional) sentences: A ≡ B where A, B are atomic or built from ¬, ∧, ∨. The logical consequences holding between identity sentences are preserved by further extensions. However, the Constitutive Foundation lacks semantic resources to evaluate non-identity sentences, which depend on contingent states of affairs rather than purely structural relations in state space. The Core Extension adds these resources, though its definition of logical consequence differs, quantifying over world-histories and times in addition to models and variable assignments.
```

**Step 7** (Line 272): Add universal quantifier and actuality predicate:
```markdown
#### Universal Quantifier

| | Condition |
|---|-----------|
| M, τ, x, v, i⃗ ⊨ ∀y.A | iff M, τ, x, v[s/y], i⃗ ⊨ A for all s ∈ S |

#### Actuality Predicate

| Operator | Truth Condition |
|----------|-----------------|
| **Act(t)** | M, τ, x, v, i⃗ ⊨ Act(t) iff ⟦t⟧^v_M ⊑ τ(x) |

The actuality predicate checks whether a state is part of the current world-state. Combined with the universal quantifier, this enables restricting quantification to actually existing objects:

| | Condition |
|---|-----------|
| M, τ, x, v, i⃗ ⊨ ∀y(Act(y) → A) | Restricted to states that are parts of τ(x) |

The unrestricted universal quantifier validates the Barcan formulas, while the actuality-restricted quantifier does not.
```

**Verification**:
- All new content renders correctly
- Mathematical notation is consistent
- References are accurate

---

### Phase 5: Structural Changes

**Estimated effort**: 1.5 hours
**Status**: [NOT STARTED]

**Objectives**:
1. Move state modality definitions before constraints that reference them
2. Add Syntactic Primitives subsection for Core Extension
3. Use equivalent world-history definition from counterfactual_worlds.tex
4. Add Spatial Extension section
5. Add dependency diagram

**Files to modify**:
- `Documentation/Research/RECURSIVE_SEMANTICS.md` - Structural reorganization

**Steps**:

**Step 1** (Lines 204-230): Reorder definitions
- Move "State Modality Definitions" section (lines 218-230) to BEFORE the task relation constraints (lines 204-214)
- This ensures P (possible states) and maximal t-compatible parts are defined before Containment and Maximality constraints reference them

**Step 2** (Line 190): Add Syntactic Primitives subsection:
```markdown
### Syntactic Primitives

The Core Extension interprets the following additional syntactic primitives beyond those of the Constitutive Foundation:
- **Modal operators**: □ (necessity), ◇ (possibility)
- **Temporal operators**: H (always past), G (always future), P (some past), F (some future)
- **Extended temporal operators**: ◁ (since), ▷ (until)
- **Counterfactual conditional**: □→ (would-counterfactual)
- **Store/recall operators**: ↑ⁱ (store), ↓ⁱ (recall)

A well-formed sentence at this extension includes all Constitutive Foundation sentences plus those built using these operators according to their arities.
```

**Step 3** (Line 239): Add equivalent world-history definition:
```markdown
The set of maximal possible evolutions M_Z equals the set of world-histories H_Z. This equivalence (proven in Brast-McKie, "Counterfactual Worlds") shows that world-histories can be characterized as maximal elements among possible evolutions under the pointwise parthood ordering.
```

**Step 4**: Add Spatial Extension section (new section after Normative):
```markdown
## Spatial Extension

[DETAILS]

The Spatial Extension provides structures for reasoning about spatial relations and locations.

### Frame Extension

[DETAILS]

The spatial frame extends the Core Extension with:
- **Location space** L = set of spatial locations
- **Spatial relations**: adjacency, containment, distance

[QUESTION: What spatial primitives are required? Should locations be mereological (with parts) or set-theoretic?]

### Operators

| Operator | Intended Reading |
|----------|------------------|
| **Here(A)** | A holds at the current location |
| **Somewhere(A)** | A holds at some location |
| **Everywhere(A)** | A holds at all locations |
| **Near(A)** | A holds at an adjacent location |

[DETAILS: Full semantic clauses for spatial operators pending specification]
```

**Step 5**: Add dependency diagram after Introduction:
```markdown
### Extension Dependencies

The following diagram shows the dependency structure among extensions:

```
┌─────────────────────────────────────────────────┐
│           Constitutive Foundation               │
│         (hyperintensional base layer)           │
└─────────────────────┬───────────────────────────┘
                      │ required
                      ▼
┌─────────────────────────────────────────────────┐
│              Core Extension                     │
│    (modal, temporal, counterfactual operators)  │
└─────────────────────┬───────────────────────────┘
                      │
        ┌─────────────┼─────────────┐
        │ optional    │ optional    │ optional
        ▼             ▼             ▼
┌──────────────┐ ┌──────────────┐ ┌──────────────┐
│  Epistemic   │ │  Normative   │ │   Spatial    │
│  Extension   │ │  Extension   │ │  Extension   │
│ (belief,     │ │ (obligation, │ │ (location,   │
│  knowledge,  │ │  permission, │ │  spatial     │
│  probability)│ │  preference) │ │  relations)  │
└──────┬───────┘ └──────┬───────┘ └──────┬───────┘
       │                │                │
       └────────────────┼────────────────┘
                        │ at least one required
                        ▼
┌─────────────────────────────────────────────────┐
│             Agential Extension                  │
│           (multi-agent reasoning)               │
└─────────────────────────────────────────────────┘
```

The Constitutive Foundation and Core Extension form the required base. The Epistemic, Normative, and Spatial Extensions are modular plugins that can be combined in any subset. The Agential Extension requires at least one middle extension to be loaded.
```

**Verification**:
- Section order is logical
- Diagram renders correctly in markdown
- Cross-references updated

---

### Phase 6: Cross-Document Consistency

**Estimated effort**: 1.5 hours
**Status**: [NOT STARTED]

**Objectives**:
1. Update LAYER_EXTENSIONS.md with new terminology
2. Update METHODOLOGY.md with new terminology
3. Update GLOSSARY.md with new terminology and notation

**Files to modify**:
- `Documentation/Research/LAYER_EXTENSIONS.md`
- `Documentation/UserGuide/METHODOLOGY.md`
- `Documentation/Reference/GLOSSARY.md`

**Steps**:

**LAYER_EXTENSIONS.md**:
1. Update title: "Logos Layer Extensions" → "Logos Extensions"
2. Update overview to use "Extension" terminology
3. Update layer list to extension list with new names
4. Add Spatial Extension to the list
5. Update dependency explanation
6. Fix line 33 "Compatibility" reference (remove or clarify non-modal context)
7. Update all section headers

**METHODOLOGY.md**:
1. Search for "Layer" references and update to "Extension"
2. Update any numbered layer references (Layer 0, Layer 1, etc.)
3. Ensure operator groupings match new extension structure

**GLOSSARY.md**:
1. Update Layer Architecture section (lines 5-18)
2. Rename all layer entries to extension entries
3. Add Spatial Extension entry
4. Update "Variable Assignment" (line 128): change "a̅" to "v" notation
5. Update imposition entry (line 89): remove "⊳" or update to "→"
6. Add new terms: temporal index, actuality predicate
7. Update cross-references to RECURSIVE_SEMANTICS.md

**Verification**:
- All three documents use consistent terminology
- No orphaned "Layer" references
- Notation matches across documents
- Cross-references valid

---

## Dependencies

- No external dependencies
- Phase 6 depends on Phases 1-5 completion
- Phases 1-5 can be done sequentially on main document

## Risks and Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Breaking cross-references | Medium | Low | Verify all internal links after each phase |
| Inconsistent terminology | High | Medium | Use search to find all instances before replacement |
| Mathematical notation errors | High | Low | Preview markdown rendering after notation changes |
| Loss of content meaning | High | Low | Preserve original FIX comments until verified |

## Success Criteria

- [ ] All 18 FIX tags addressed and removed
- [ ] No "Layer" terminology in RECURSIVE_SEMANTICS.md (except quoted sources)
- [ ] No "a̅" notation anywhere
- [ ] No "time vector" terminology
- [ ] No "⊳" imposition symbols
- [ ] No "**Note**:" labels
- [ ] Spatial Extension section added
- [ ] Dependency diagram added
- [ ] LAYER_EXTENSIONS.md updated
- [ ] METHODOLOGY.md updated
- [ ] GLOSSARY.md updated
- [ ] All documents render correctly in markdown preview
- [ ] All cross-references valid

## Rollback Plan

Each phase modifies documentation only. If issues arise:
1. Use git to revert specific files
2. FIX tags preserved in comments until final verification
3. Can revert individual phases independently

## Estimated Total Effort

| Phase | Effort |
|-------|--------|
| Phase 1: Terminology | 1 hour |
| Phase 2: Notation | 45 min |
| Phase 3: Formatting | 30 min |
| Phase 4: Content | 2.5 hours |
| Phase 5: Structure | 1.5 hours |
| Phase 6: Cross-Document | 1.5 hours |
| **Total** | **7.75 hours** |
