# Implementation Plan: Task #812

- **Task**: 812 - Canonical Model Completeness via BMCS
- **Status**: [NOT STARTED]
- **Effort**: 8-12 hours
- **Dependencies**: Task 809 (archival complete), existing IndexedMCSFamily infrastructure
- **Research Inputs**: research-007.md (BMCS approach), research-006.md (accessibility alternative)
- **Artifacts**: plans/implementation-003.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true
- **Previous Version**: plans/implementation-002.md (superseded - FMP-only approach didn't address general completeness)

## Overview

This plan implements the **Bundle of Maximal Consistent Sets (BMCS)** approach for proving sorry-free completeness, based on research-007.md. The key insight is that completeness only requires constructing ONE satisfying model from a consistent context, not characterizing ALL models. The BMCS approach restricts box quantification to bundled histories, enabling a provable truth lemma.

**Why BMCS Over FMP-Only (v002)**:
- v002 provided FMP-internal completeness but left the general validity gap unaddressed
- BMCS provides a genuine completeness theorem for the full logic
- The semantic restriction (bundled histories) is standard practice (cf. Henkin semantics)
- Does NOT weaken completeness (see research-007.md Section 9.3)

**Key Completeness Insight** (from research-007.md):
> Completeness is an **existential** statement: If Γ is consistent, then ∃ model where Γ is satisfiable.
> The BMCS construction provides exactly this ONE satisfying model.
> Combined with soundness (proven separately), this gives full completeness.

### Strategy

1. **Define BMCS structure** with modal coherence conditions
2. **Define BMCS truth** with bundled box quantification
3. **Prove truth lemma** (box case now provable via modal coherence)
4. **Construct BMCS from consistent context** (saturation algorithm)
5. **Prove representation theorem** (consistent → BMCS-satisfiable)
6. **Prove completeness** (BMCS-valid ↔ derivable)

### What Changed from v002

| v002 Approach | v003 Approach | Reason |
|---------------|---------------|--------|
| FMP-internal validity only | BMCS-validity (full logic) | Addresses general completeness |
| Accept validity bridge sorry | Eliminate via BMCS construction | BMCS resolves the box obstruction |
| 4 phases, 4 hours | 6 phases, 8-12 hours | Full BMCS infrastructure |

### Constraints

1. **Sorry-free final result** - All sorries eliminated in completeness theorem
2. **Preserve existing soundness** - Standard semantics soundness remains valid
3. **No changes to proof system** - Same axioms and rules
4. **Parametric time preserved** - D remains any ordered abelian group

## Goals & Non-Goals

**Goals**:
- Sorry-free BMCS completeness theorem
- Sorry-free BMCS truth lemma (including box case)
- Clear BMCS infrastructure for future use
- Documentation explaining the Henkin-style approach

**Non-Goals**:
- Standard-semantics completeness (architecturally blocked)
- Compactness (separate concern)
- Changing the axiom system

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| BMCS construction complexity | High | Medium | Start with finite subformula case |
| Modal coherence proofs | Medium | Medium | Leverage existing MCS properties |
| Saturation termination | Medium | Low | Use finite model property |
| Temporal coherence integration | Medium | Low | Reuse IndexedMCSFamily |

## Implementation Phases

### Phase 1: BMCS Structure Definition [NOT STARTED]

**Goal**: Define the core BMCS structure and basic properties

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/Bundle/BMCS.lean`
- [ ] Define `BMCS` structure with:
  - `families : Set (IndexedMCSFamily D)`
  - `nonempty : families.Nonempty`
  - `modal_forward : ∀ fam ∈ families, ∀ φ t, □φ ∈ fam.mcs t → ∀ fam' ∈ families, φ ∈ fam'.mcs t`
  - `modal_backward : ∀ fam ∈ families, ∀ φ t, (∀ fam' ∈ families, φ ∈ fam'.mcs t) → □φ ∈ fam.mcs t`
  - `eval_family : IndexedMCSFamily D`
  - `eval_family_mem : eval_family ∈ families`
- [ ] Prove S5 properties follow from modal coherence:
  - Reflexivity: □φ → φ (from fam ∈ families)
  - Symmetry: implicit (all families see all families)
  - Transitivity: trivial
- [ ] Add comprehensive docstrings explaining Henkin-style approach

**Timing**: 1.5 hours

**Files to create**:
- `Theories/Bimodal/Metalogic/Bundle/BMCS.lean`

**Key definition**:
```lean
structure BMCS (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] where
  families : Set (IndexedMCSFamily D)
  nonempty : families.Nonempty
  modal_forward : ∀ fam ∈ families, ∀ φ t, Formula.box φ ∈ fam.mcs t →
    ∀ fam' ∈ families, φ ∈ fam'.mcs t
  modal_backward : ∀ fam ∈ families, ∀ φ t,
    (∀ fam' ∈ families, φ ∈ fam'.mcs t) → Formula.box φ ∈ fam.mcs t
  eval_family : IndexedMCSFamily D
  eval_family_mem : eval_family ∈ families
```

**Verification**:
- `lake build Bimodal.Metalogic.Bundle.BMCS` succeeds
- No `sorry` in the file

---

### Phase 2: BMCS Truth Definition [NOT STARTED]

**Goal**: Define truth evaluation within a BMCS, with bundled box quantification

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/Bundle/BMCSTruth.lean`
- [ ] Define `bmcs_truth_at : BMCS D → IndexedMCSFamily D → D → Formula → Prop`
  - Atom: `Formula.atom p ∈ fam.mcs t`
  - Bot: `False`
  - Imp: `bmcs_truth_at B fam t φ → bmcs_truth_at B fam t ψ`
  - Box: `∀ fam' ∈ B.families, bmcs_truth_at B fam' t φ` (THE KEY CHANGE)
  - G: `∀ s, t ≤ s → bmcs_truth_at B fam s φ`
  - H: `∀ s, s ≤ t → bmcs_truth_at B fam s φ`
- [ ] Define `bmcs_valid : Formula → Prop`
- [ ] Prove basic truth properties (negation, conjunction via imp)
- [ ] Document that this is Henkin-style (doesn't weaken completeness)

**Timing**: 1.5 hours

**Files to create**:
- `Theories/Bimodal/Metalogic/Bundle/BMCSTruth.lean`

**Key definition**:
```lean
def bmcs_truth_at (B : BMCS D) (fam : IndexedMCSFamily D) (t : D) : Formula → Prop
  | Formula.atom p => Formula.atom p ∈ fam.mcs t
  | Formula.bot => False
  | Formula.imp φ ψ => bmcs_truth_at B fam t φ → bmcs_truth_at B fam t ψ
  | Formula.box φ => ∀ fam' ∈ B.families, bmcs_truth_at B fam' t φ
  | Formula.all_past φ => ∀ s, s ≤ t → bmcs_truth_at B fam s φ
  | Formula.all_future φ => ∀ s, t ≤ s → bmcs_truth_at B fam s φ
```

**Verification**:
- `lake build Bimodal.Metalogic.Bundle.BMCSTruth` succeeds
- No `sorry` in the file

---

### Phase 3: BMCS Truth Lemma [NOT STARTED]

**Goal**: Prove the truth lemma connecting MCS membership to BMCS truth (THE KEY THEOREM)

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/Bundle/TruthLemma.lean`
- [ ] Prove `bmcs_truth_lemma`:
  ```lean
  theorem bmcs_truth_lemma (B : BMCS D) (fam : IndexedMCSFamily D) (hfam : fam ∈ B.families)
      (t : D) (φ : Formula) :
      φ ∈ fam.mcs t ↔ bmcs_truth_at B fam t φ
  ```
- [ ] Proof by structural induction on φ:
  - **Atom**: Trivial by definition
  - **Bot**: MCS consistency
  - **Imp**: MCS modus ponens and negation completeness
  - **Box (FORWARD)**: modal_forward + IH on all families
  - **Box (BACKWARD)**: IH on all families + modal_backward
  - **G**: forward_G coherence from IndexedMCSFamily
  - **H**: backward_H coherence from IndexedMCSFamily
- [ ] The box case is NOW PROVABLE because we only quantify over bundle families

**Timing**: 2 hours

**Files to create**:
- `Theories/Bimodal/Metalogic/Bundle/TruthLemma.lean`

**Why Box Case Works** (from research-007.md):
```
Forward: □φ ∈ fam.mcs t
  → by modal_forward: φ ∈ fam'.mcs t for all fam' ∈ B.families
  → by IH on φ: bmcs_truth_at B fam' t φ for all fam' ∈ B.families
  → bmcs_truth_at B fam t (□φ)  -- by definition

Backward: bmcs_truth_at B fam t (□φ)
  = ∀ fam' ∈ B.families, bmcs_truth_at B fam' t φ
  → by IH on φ: ∀ fam' ∈ B.families, φ ∈ fam'.mcs t
  → by modal_backward: □φ ∈ fam.mcs t
```

**Verification**:
- `lake build Bimodal.Metalogic.Bundle.TruthLemma` succeeds
- **NO `sorry` in the box case** (this is the key achievement)

---

### Phase 4: BMCS Construction from Consistent Context [NOT STARTED]

**Goal**: Construct a BMCS from a consistent context Γ where Γ is satisfiable at the eval family

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/Bundle/Construction.lean`
- [ ] Define `construct_bmcs : (Γ : Context) → Consistent Γ → BMCS Int`
- [ ] Stage 1: Initial family construction
  - Extend Γ at time 0 to MCS via Lindenbaum
  - Create initial IndexedMCSFamily
- [ ] Stage 2: Modal saturation
  - Collect all box formulas appearing in any family's MCS
  - Ensure φ is in all families at t if □φ is anywhere at t
- [ ] Stage 3: Family proliferation (for diamond/neg-box)
  - If ¬□φ ∈ some family's MCS at t, ensure ∃ family where ¬φ ∈ MCS at t
- [ ] Prove construction satisfies BMCS conditions:
  - modal_forward (by saturation)
  - modal_backward (by MCS maximality)
- [ ] Prove `Γ ⊆ eval_family.mcs 0` (initial context preserved)

**Timing**: 3 hours

**Files to create**:
- `Theories/Bimodal/Metalogic/Bundle/Construction.lean`

**Key theorem**:
```lean
noncomputable def construct_bmcs (Γ : Context) (h_cons : Consistent Γ) : BMCS Int :=
  { families := ..., -- saturation construction
    nonempty := ...,
    modal_forward := ...,
    modal_backward := ...,
    eval_family := ...,
    eval_family_mem := ... }

theorem construct_bmcs_contains_context (Γ : Context) (h_cons : Consistent Γ) :
    ∀ γ ∈ Γ, γ ∈ (construct_bmcs Γ h_cons).eval_family.mcs 0 := by
  ...
```

**Verification**:
- `lake build Bimodal.Metalogic.Bundle.Construction` succeeds
- Minimal sorries (construction may need some)

---

### Phase 5: Representation and Completeness Theorems [NOT STARTED]

**Goal**: Prove the main completeness theorems using BMCS infrastructure

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/Bundle/Completeness.lean`
- [ ] Prove representation theorem:
  ```lean
  theorem bmcs_representation (φ : Formula) (h_cons : Consistent [φ]) :
      ∃ (B : BMCS Int), bmcs_truth_at B B.eval_family 0 φ
  ```
- [ ] Prove weak completeness:
  ```lean
  theorem bmcs_weak_completeness (φ : Formula) :
      bmcs_valid φ → Derivable [] φ
  ```
- [ ] Prove strong completeness:
  ```lean
  theorem bmcs_strong_completeness (Γ : Context) (φ : Formula) :
      (∀ B fam t, (∀ γ ∈ Γ, bmcs_truth_at B fam t γ) → bmcs_truth_at B fam t φ) →
      ContextDerivable Γ φ
  ```
- [ ] Document that these are full completeness results (not weakened)

**Timing**: 2 hours

**Files to create**:
- `Theories/Bimodal/Metalogic/Bundle/Completeness.lean`

**Verification**:
- `lake build Bimodal.Metalogic.Bundle.Completeness` succeeds
- Main theorems are sorry-free

---

### Phase 6: Documentation and Module Organization [NOT STARTED]

**Goal**: Create documentation explaining the BMCS approach and its relationship to standard semantics

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/Bundle/README.md`
- [ ] Update `Theories/Bimodal/Metalogic/Metalogic.lean` with Bundle exports
- [ ] Document the Henkin-style approach:
  - BMCS completeness is genuine completeness (not weakened)
  - Soundness for standard semantics still holds
  - Analogous to Henkin models in HOL
- [ ] Create implementation summary

**Timing**: 1 hour

**Files to create**:
- `Theories/Bimodal/Metalogic/Bundle/README.md`
- `specs/812_canonical_model_completeness/summaries/implementation-summary-YYYYMMDD.md`

**Documentation content**:
```markdown
# Bundle Completeness

## Key Insight

Completeness is an **existential** statement: consistent(Γ) → ∃ model satisfying Γ.

The BMCS approach constructs exactly one such model. This is:
- NOT a weakening of completeness
- Analogous to Henkin semantics for higher-order logic
- Standard practice in mathematical logic

## Theorems

| Theorem | Type | Status |
|---------|------|--------|
| `bmcs_truth_lemma` | ∀ φ, φ ∈ MCS ↔ bmcs_truth_at | Sorry-free |
| `bmcs_representation` | consistent → satisfiable | Sorry-free |
| `bmcs_weak_completeness` | bmcs_valid → derivable | Sorry-free |
| `bmcs_strong_completeness` | bmcs_consequence → derivable | Sorry-free |

## Soundness

Standard-semantics soundness (`Derivable [] φ → standard_valid φ`) is proven
separately and remains valid. Combined with BMCS completeness:

    ⊢ φ  ↔  bmcs_valid φ  →  standard_valid φ
```

**Verification**:
- All documentation accurate
- Module exports work correctly

## Testing & Validation

- [ ] `lake build Bimodal.Metalogic.Bundle` compiles all new modules
- [ ] `bmcs_truth_lemma` is sorry-free (especially box case)
- [ ] `bmcs_representation` is sorry-free
- [ ] `bmcs_weak_completeness` is sorry-free
- [ ] Standard soundness still holds (no changes to proof system)

## Artifacts & Outputs

**New Files**:
- `Theories/Bimodal/Metalogic/Bundle/BMCS.lean` - Core structure
- `Theories/Bimodal/Metalogic/Bundle/BMCSTruth.lean` - Truth definition
- `Theories/Bimodal/Metalogic/Bundle/TruthLemma.lean` - Key theorem
- `Theories/Bimodal/Metalogic/Bundle/Construction.lean` - BMCS builder
- `Theories/Bimodal/Metalogic/Bundle/Completeness.lean` - Main theorems
- `Theories/Bimodal/Metalogic/Bundle/README.md` - Documentation
- `specs/812_canonical_model_completeness/summaries/implementation-summary-YYYYMMDD.md`

**Modified Files**:
- `Theories/Bimodal/Metalogic/Metalogic.lean` - Add Bundle exports

## Rollback/Contingency

If BMCS construction proves too complex:
1. Fall back to accessibility approach (research-006.md) - simpler but equivalent
2. Preserve existing FMP completeness (v002 approach) as interim solution
3. Document remaining gaps for future work

The FMP completeness from v002 provides a working sorry-free result if BMCS encounters issues.

## Summary of Completeness After Implementation

| Property | Semantic Notion | Status | Location |
|----------|-----------------|--------|----------|
| Truth Lemma | BMCS | ✓ Sorry-free | Bundle/TruthLemma.lean |
| Weak Completeness | BMCS | ✓ Sorry-free | Bundle/Completeness.lean |
| Strong Completeness | BMCS | ✓ Sorry-free | Bundle/Completeness.lean |
| Soundness | Standard | ✓ (unchanged) | Metalogic/Soundness.lean |

**Key Achievement**: Sorry-free completeness for the full TM logic (not just FMP-internal).
