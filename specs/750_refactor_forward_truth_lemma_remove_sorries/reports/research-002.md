# Research Report: Task #750 (Follow-up)

**Task**: Refactor forward Truth Lemma to remove sorries
**Date**: 2026-01-29
**Focus**: Semantic approach organization, mathematical correctness comparison, quality recommendations

## Summary

This follow-up report maps the semantic completeness architecture, compares the two approaches from a mathematical rigor perspective, and provides recommendations for producing the highest quality metalogic results. The semantic approach (`semantic_weak_completeness`) is mathematically cleaner and aligns more closely with standard modal logic completeness proofs because it eliminates the "truth bridge" gap by making truth definitionally equivalent to MCS membership.

## Findings

### 1. Architecture Map: Two Completeness Paths

The codebase has two parallel completeness architectures:

#### Path A: Syntactic/Universal Approach (TruthLemma.lean)

```
Completeness/WeakCompleteness.lean
    └── Representation/UniversalCanonicalModel.lean
        └── representation_theorem (2 sorries: h_no_G_bot, h_no_H_bot)
            └── truth_lemma_forward (uses truth_lemma_mutual)
                └── TruthLemma.lean (4 sorries: box cases, temporal backward)
                    └── IndexedMCSFamily.lean
                        └── CoherentConstruction.lean (~10 sorries)
```

**Characteristics**:
- Parametric over duration type D (any ordered abelian group)
- Uses `IndexedMCSFamily D` with temporal coherence conditions
- Truth is a separate predicate (`truth_at`) that must be connected to MCS membership
- Sorries arise from: (a) box operator universal quantification, (b) temporal backward directions (omega-rule), (c) coherent construction cross-origin cases

#### Path B: Semantic/FMP Approach (SemanticCanonicalModel.lean)

```
FMP/SemanticCanonicalModel.lean
    └── semantic_weak_completeness (SORRY-FREE)
        └── ClosureMaximalConsistent
            └── worldStateFromClosureMCS
                └── Closure.lean (projection from full MCS)
```

**Characteristics**:
- Fixed to bounded time domain `BoundedTime k = Fin(2k+1)`
- World states ARE closure-MCS projections (truth IS membership)
- No separate "truth bridge" needed
- Single non-critical sorry: `SemanticCanonicalFrame.compositionality` (not used in completeness)

### 2. Mathematical Correctness Comparison

#### Standard Modal Logic Completeness (Literature)

The canonical completeness proof in Blackburn et al. "Modal Logic" (Chapter 4) follows this structure:

1. **Lindenbaum Lemma**: Consistent sets extend to MCS
2. **Canonical Model**: Worlds = MCS, accessibility defined via modal formulas
3. **Truth Lemma**: `w |= phi <-> phi in w` (holds definitionally or by induction)
4. **Completeness**: If phi unprovable, then {~phi} consistent, extend to MCS w, then w |= ~phi

**Key insight**: In standard treatments, worlds ARE maximal consistent sets, so the truth lemma is trivial for atoms (valuation is defined as membership) and follows by induction.

#### Path A Assessment (Syntactic/Universal)

**Mathematical Issue**: The architecture introduces a *gap* between semantic truth (`truth_at`) and MCS membership that must be bridged. This creates the need for mutual induction where:
- Forward imp case needs backward IH (to go from `truth_at psi` to `psi in mcs`)
- Backward direction creates new proof obligations (omega-rule for temporal, universal quantification for box)

**Why this diverges from standard**: The world states are not directly the MCS - they have an MCS *embedded* in them, but truth is evaluated against the frame semantics, requiring explicit bridging.

**Sorries breakdown by type**:
| Type | Count | Removable? |
|------|-------|------------|
| Box cases | 2 | No - requires architectural change (modal accessibility) |
| Temporal backward | 2 | No - requires omega-rule or bounded domain |
| Coherence construction | ~10 | Complex - cross-origin and modal cases |
| representation_theorem | 2 | Yes - provable from MCS properties |

#### Path B Assessment (Semantic/FMP)

**Mathematical Strength**: This approach aligns exactly with standard completeness proofs because:
1. `FiniteWorldState` IS a truth assignment on closure
2. `worldStateFromClosureMCS` builds world state directly from MCS projection
3. `models psi h_mem` is defined as `assignment[psi] = true` which equals `psi in S` by construction
4. No separate "truth bridge" - the connection is definitional

**Why `semantic_weak_completeness` works without sorry**:
- Contrapositive: Assume phi unprovable
- Then {phi.neg} is consistent
- Extend to MCS M via Lindenbaum
- Project to `closureWithNeg` to get closure-MCS S
- Build `FiniteWorldState` from S
- phi.neg is in S, so phi.neg is true at the world state
- phi is false, contradicting validity

**Single non-critical sorry**: The `SemanticCanonicalFrame.compositionality` axiom is marked sorry because task relation composition can exceed the bounded time domain. This does NOT affect completeness because `semantic_weak_completeness` quantifies over `SemanticWorldState` directly, never invoking frame compositionality.

### 3. Which Approach is More Rigorous?

**Path B (Semantic) is mathematically superior** for several reasons:

1. **Definitional Connection**: Truth IS membership, eliminating the need for truth bridge proofs
2. **Alignment with Literature**: Matches standard Henkin-style completeness proofs
3. **Sorry-Free Core**: The completeness theorem itself has no sorries
4. **Cleaner Induction**: No mutual induction needed because backward direction is trivial
5. **Finite Model Property**: Comes "for free" from the bounded closure

**Path A has value for**:
- Parametric duration type (not just integers)
- Potential decidability/complexity analysis with unbounded time
- Educational exposition of indexed MCS families

### 4. Module Interaction Map

```
SemanticCanonicalModel.lean (FMP/*)
├── imports: FMP/FiniteWorldState.lean
│   ├── worldStateFromClosureMCS: closure-MCS -> FiniteWorldState
│   ├── models: truth as assignment lookup
│   └── FiniteHistory: sequence of world states
│
├── imports: FMP/Closure.lean
│   ├── closure, closureWithNeg: finite subformula set
│   ├── ClosureMaximalConsistent: maximal within closure
│   └── mcs_projection_is_closure_mcs: full MCS -> closure MCS
│
├── imports: FMP/BoundedTime.lean
│   └── BoundedTime k = Fin(2k+1): finite time domain
│
├── imports: Core/MaximalConsistent.lean
│   ├── SetMaximalConsistent: full MCS definition
│   └── set_lindenbaum: Lindenbaum's lemma
│
└── defines:
    ├── SemanticWorldState: quotient of history-time pairs
    ├── semantic_truth_at_v2: truth at semantic world state
    ├── semantic_truth_lemma_v2: membership <-> truth
    └── semantic_weak_completeness: the main theorem (sorry-free)
```

### 5. Focus Recommendations for Highest Quality Metalogic

#### Immediate Priority: Document the Sorry-Free Path

The highest quality metalogic result is already achieved via `semantic_weak_completeness`. The priority should be:

1. **Document clearly** in module headers that `semantic_weak_completeness` is the canonical completeness theorem
2. **Deprecate** or mark as "auxiliary" the sorried paths in TruthLemma.lean
3. **Verify** that downstream consumers (like `provable_iff_valid`) can be cleanly connected

#### Secondary: Fill Soundness Gap

The `WeakCompleteness.lean` file has a soundness sorry:
```lean
theorem soundness (Gamma : Context) (phi : Formula) :
    (DerivationTree Gamma phi) -> semantic_consequence Gamma phi := sorry
```

This should be provable - the proof exists in `Boneyard/Metalogic_v2/Soundness` but needs updating for reflexive temporal semantics. Filling this would make the full `provable_iff_valid` equivalence sorry-free.

#### Tertiary: Clean Up representation_theorem

The 2 sorries in `representation_theorem` (`h_no_G_bot`, `h_no_H_bot`) are provable from MCS properties:
- `G bot in MCS` implies `bot in MCS` (by T-axiom for box applied to G)
- Wait - TM doesn't have T for G! This is the issue.

**Resolution**: These can be proven by noting that `G bot` is inconsistent:
- Assume `G bot` is consistent
- Build a model where `G bot` is true at some time t
- This means `bot` is true at all times s > t
- But `bot` is never true - contradiction

This argument works and could remove these sorries.

#### Long-term: Unify the Two Paths

For maximum elegance, consider refactoring so that Path A uses Path B's approach:
- Replace `truth_at` with `models` in the `FiniteWorldState` sense
- Make the canonical model's world states BE closure-MCS projections
- This would unify the approaches and eliminate most sorries

### 6. Quality Assessment Matrix

| Criterion | Path A (TruthLemma) | Path B (Semantic) |
|-----------|---------------------|-------------------|
| Sorry count | ~18 total | 1 non-critical |
| Mathematical rigor | Good but gapped | Excellent |
| Alignment with literature | Divergent (truth bridge) | Standard (truth=membership) |
| Parametricity | Full (any D) | Limited (bounded time) |
| Maintainability | Complex | Simple |
| Documentation value | High (educational) | High (practical) |
| Completeness status | Proven with gaps | Fully proven |

## Recommendations

### Primary Recommendation: Adopt Semantic Approach as Canonical

1. Recognize `semantic_weak_completeness` as the primary completeness result
2. Update CLAUDE.md and module documentation to reflect this
3. Keep TruthLemma.lean for theoretical interest but mark it clearly as an alternative approach
4. Connect `semantic_weak_completeness` cleanly to `weak_completeness` via a bridge lemma

### Secondary: Fill Remaining Sorries

Priority order for filling sorries:
1. **Soundness** in WeakCompleteness.lean - makes `provable_iff_valid` complete
2. **h_no_G_bot, h_no_H_bot** in UniversalCanonicalModel.lean - simple consistency arguments
3. **Skip** the TruthLemma backward cases - not needed and architecturally difficult

### Tertiary: Consider Refactoring Task

Create a future task to:
- Unify the two approaches by making Path A use closure-MCS world states
- This would make the entire metalogic sorry-free except for the non-critical compositionality axiom

## References

- `Theories/Bimodal/Metalogic/FMP/SemanticCanonicalModel.lean` - sorry-free completeness
- `Theories/Bimodal/Metalogic/Representation/TruthLemma.lean` - mutual induction approach
- `Theories/Bimodal/Metalogic/README.md` - architectural overview
- `specs/750_refactor_forward_truth_lemma_remove_sorries/reports/research-001.md` - initial research
- Blackburn et al., Modal Logic, Chapter 4 (canonical model completeness)

## Next Steps

1. Update task 750's implementation plan to focus on documentation changes
2. Consider creating subtasks for:
   - Fill soundness sorry
   - Fill h_no_G_bot/h_no_H_bot sorries
   - Add bridge lemma connecting semantic_weak_completeness to weak_completeness
3. Mark TruthLemma.lean backward cases as intentionally sorried (architectural limitation)
