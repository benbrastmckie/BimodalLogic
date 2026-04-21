# Teammate D Findings: Horizons -- Strategy, Axiom Design, and Publication Path

## Key Findings

### 1. The BX Axiom System Does NOT Need Extension

After careful analysis of the axiom system (35 constructors across 4 layers), the semantics (`Truth.lean`), and the proof architecture, I conclude that the BX system is **axiomatically sufficient** for completeness over irreflexive linear temporal orders. No new axioms are needed.

**Candidate axioms assessed and rejected:**

| Candidate | Assessment | Reason |
|-----------|-----------|--------|
| **Discreteness** (`F(phi) -> X(phi)`) | REJECTED | BX is designed for ALL linear orders, not just discrete ones. Adding discreteness restricts the frame class and changes the theorem statement. X/Y are already definable (`bot U phi`, `bot S phi`) but unsatisfiable on dense orders. |
| **Density** (`GG(phi) -> G(phi)`) | REJECTED | Derivable from temp_4 under irreflexive semantics. Already a `FrameClass.Dense` extension point but not needed in the base system. |
| **Temporal induction** | REJECTED | No standard formulation for base Until-Since temporal logic. Would be a non-standard extension. |
| **Gabbay IRR rule** | NOT NEEDED | The IRR rule (`if p and H(neg p) -> A with p not in atoms(A), then A`) is needed for completeness of K4.3 (transitive + linear, no T-axiom). However, the BX system's seriality axioms + BX4/BX4' connectedness axioms provide the structural properties that IRR gives in the pure modal case. The typst notes (06-notes.typ:331) confirm: "No Gabbay IRR rule or fresh atom machinery needed" for the current approach. |
| **Next-step axiom** (`phi AND F(phi U psi) -> phi U psi`) | REJECTED | This would make Until step transfer trivial but is NOT valid on all linear orders (only discrete ones). It would change the logic. |

**The IRR infrastructure already exists** in the codebase (`ConservativeExtension/` module, `Atom.lean` fresh atom support, `Soundness.lean` IRR soundness), but it predates the BX axiom system and lacks Until/Since constructors. It is legacy infrastructure for a different proof architecture.

**Critical insight**: The BX system was specifically designed by Burgess (1982) and Xu (1988) to be complete for Until-Since tense logic over all linear orderings WITHOUT requiring the IRR rule. The axioms BX5 (self-accumulation), BX6 (absorption), BX7 (linearity), and BX10 (eventuality extraction) together provide the Until-induction mechanism that closes eventualities. The current obstruction is a **formalization gap**, not an **axiom gap**.

### 2. The Irreflexive Semantics Switch Was the Correct Strategic Decision

The switch from reflexive to irreflexive semantics (task 93) was architecturally sound:

- **Under reflexive semantics**: `phi -> F(phi)` is derivable (from BX1: `G(phi) -> phi`), causing defect oscillation. 36 dead ends documented in ROADMAP attest to this fundamental obstruction.
- **Under irreflexive semantics**: `phi -> F(phi)` is NOT derivable. Resolved defects do not re-enter. The active defect count can strictly decrease.

The cost was 18 "irreflexive-consequence" sorries, most of which are **mathematically false** (e.g., `bx_le_refl`, `g_content_subset_self`) and should be deleted, not proved. The benefit is that the core completeness argument becomes viable.

**The typst notes (06-notes.typ:292-312) document the project's oscillation** between reflexive and strict semantics across 4 switches. The current irreflexive choice aligns with the standard temporal logic tradition (Prior 1957-1968, Goldblatt, Blackburn-de Rijke-Venema) and enables frame-theoretic expressiveness that reflexive semantics sacrifices.

### 3. Alternative Proof Architectures: Assessment

#### 3a. Algebraic Completeness via Representation Theorems

The `Metalogic/Algebraic/` directory contains 12 files including `TenseS5Algebra.lean`, `BooleanStructure.lean`, `LindenbaumQuotient.lean`, `UltrafilterMCS.lean`, and the parametric representation infrastructure. However:

- The algebraic representation theorem (`ParametricRepresentation.lean`) is **already on the active path** -- it provides `parametric_algebraic_representation_conditional` which `dd_countermodel` uses.
- The algebraic approach does NOT bypass the chain construction. It provides the frame for the canonical model, but temporal coherence (F-resolution, Until coherence) still requires building a chain of MCSs.
- `AlgebraicRepresentation.lean` (ultrafilter-based) is a separate module not on the active path.

**Conclusion**: Algebraic completeness via representation theorems is not an alternative to the chain construction -- it is a layer that sits on top of it.

#### 3b. Completeness via Filtration

No `Metalogic/Filtration/` directory exists at the top level. The filtration infrastructure lives within `BXCanonical/Filtration/` (SigmaOrdering.lean, DefectChain.lean) and is part of the quasimodel defect-discharge mechanism, which is already sorry-free for Until/Since eventuality resolution.

The filtration approach could in principle provide a finite model property (FMP) route to completeness. The `Decidability/FMP/` module (6 files) exists and provides FMP infrastructure. However, the ROADMAP explicitly states: "Decidability-based completeness is explicitly excluded as a path to the representation theorem." The project goal is the **structural canonical model construction** (MCS-world correspondence, truth lemma), not bare `valid -> provable`.

#### 3c. Prime Filter Models

Not explored in the codebase. A prime filter model approach would replace MCSs with prime filters of the Lindenbaum algebra. This is algebraically equivalent (prime filters correspond to MCSs via Stone duality) and would face the same chain construction obstruction.

#### 3d. Step-by-Step (Goldblatt-style) Semantic Model Construction

The current approach IS essentially a step-by-step construction. The difference from Goldblatt (1992) is that Goldblatt constructs the model semantically (using model-theoretic witnesses from the completeness of sublogics), while the current approach constructs it syntactically (via Lindenbaum extensions). A semantic approach would require:

1. A completeness theorem for the Until-free fragment (G/H/Box only) as a base case
2. Adding Until/Since witnesses by model-theoretic extension

This is a viable alternative but would require substantial new infrastructure and is essentially a rewrite of the entire BXCanonical module (~5,800 lines).

### 4. The Defect Descent Argument Is Mathematically Sound

The ROADMAP's analysis (section "Irreflexive Semantics Strategy, Plan v48") lays out a clear argument:

1. `defect_step_early` gives: for each defect chi, either `chi in M'` (resolved) or `F(chi) in M'` (pending)
2. Under irreflexive semantics, resolved defects (`chi in M'`) do NOT generate `F(chi) in M'`
3. Active defects (those with `F(chi) in M` and `chi not in M`) strictly decrease
4. After at most `|sigma_list|` steps, all defects are resolved

The key mathematical fact: `chi in M'` does NOT imply `F(chi) in M'` because `chi -> F(chi)` is not derivable under irreflexive semantics. This breaks the defect oscillation that blocked all previous approaches.

**However, the formalization has a subtlety**: the definition of "active defect" matters. Dead end #33 in the ROADMAP warns that `active_defects` was defined as `{chi | F(chi) in M AND chi in sigma_list}` rather than `{chi | F(chi) in M AND chi not in M AND chi in sigma_list}`. The correct definition must track UNRESOLVED defects (F(chi) present but chi absent). With the correct definition, the descent argument works.

### 5. Publication Path Assessment

#### Strongest Result Path

**"BX is complete for irreflexive linear temporal logic with Until/Since"** -- this is the target theorem:

```
theorem bx_completeness (phi : Formula) :
    valid phi -> Nonempty (DerivationTree [] phi)
```

where `valid` quantifies over all task models with irreflexive linear temporal ordering.

This is publishable and novel:
- No existing Lean 4 formalization of bimodal temporal logic completeness
- No existing formalization in any proof assistant of BX completeness with Until/Since
- The irreflexive semantics choice aligns with the standard temporal logic tradition
- The canonical model construction via Hintikka-set quasimodel with defect-discharge is a clean proof architecture

#### Frame Class Characterization

The representation theorem goal ("TM is complete with respect to TaskFrames over totally ordered abelian groups") is stronger than bare completeness. It provides:
- MCS-world correspondence (canonical model)
- Truth lemma (membership iff semantic truth)
- Frame class characterization (what structures TM describes)

This is the scientific contribution -- it tells us what TM *is*, not merely that it is complete.

#### Publication Timeline

| Milestone | Dependency | Estimated Effort |
|-----------|-----------|-----------------|
| Close 5 critical-path sorries | Task 109, Phases 3-5 | Unknown (highly uncertain) |
| Close 14 irreflexive-consequence sorries | Phases 3-5 done | Medium (architectural cleanup) |
| `#print axioms` audit clean | All sorries closed | Small |
| Write completeness proof section | Clean audit | Medium |
| Submit paper | Proof section done | Large |

**Risk assessment**: The 36 documented dead ends suggest this problem is resistant to quick resolution. The irreflexive semantics switch (task 93) was a major architectural pivot designed to break the defect oscillation obstruction. If the finite descent argument can be formalized, completion is achievable. If not, the project may need another architectural pivot.

#### Is "BX + discreteness is complete for irreflexive discrete linear temporal logic" a fallback?

Yes, but it is a **weaker result**. Adding discreteness (`F(phi) -> X(phi)` where X = `bot U phi`) would:
- Restrict the frame class to discrete orders (Z-like)
- Make the X/Y operators genuine next/previous-step operators
- Make the Until step transfer trivially derivable (via X-based induction)
- Simplify the chain construction (deterministic via successor function)

This is publishable but less novel -- discrete temporal logic completeness is well-studied (Gabbay, Hodkinson, Reynolds 1994). The base BX result (over ALL linear orders) is more impressive.

**Recommendation**: Do NOT add discreteness. The base BX system is axiomatically sufficient. The obstruction is formalization, not mathematics.

### 6. Sorry-Free Infrastructure Inventory

The project has substantial sorry-free infrastructure that any approach must leverage:

| Component | Lines | Status | Role |
|-----------|-------|--------|------|
| Soundness (3 files) | ~1,200 | Sorry-free | Cross-validation |
| Quasimodel (6 files) | ~1,924 | Sorry-free core | Until/Since eventuality resolution |
| Frame.lean | ~726 | 1 sorry (bx_le_refl, intentionally false) | Points, ordering, witness lemmas |
| Completeness.lean | ~152 | Sorry-free | Top-level theorem, delegates to dd_countermodel |
| RestrictedParametricTruthLemma | ~200+ | Sorry-free | Truth lemma for specific formulas |
| ParametricRepresentation | ~200+ | Sorry-free | Canonical model representation |
| CanonicalChain.lean | ~160 | Sorry-free | MCS-level BX axiom lemmas |
| OrderedSeedConsistency | ~255 | Sorry-free | Seed consistency proofs |
| Decidability/FMP (6 files) | ~1,000+ | Sorry-free in active tree | Finite model property |

The sorry-free soundness proof is particularly valuable: if both soundness and completeness become sorry-free, their conjunction provides a consistency proof for the BX axiom system (no formula can be both provable and refutable).

## Strategic Recommendations

### Short-term (task 109)

1. **Do not change the BX axiom system.** The system is axiomatically sufficient.
2. **Focus exclusively on `fwd_chain_forward_F`** (RootScopedChain.lean:1079). This is the keystone. All other critical-path sorries are downstream.
3. **Use the correct active defect definition**: `{chi | F(chi) in M AND chi not_in M AND chi in sigma_list}`. This definition strictly decreases under the finite descent argument because:
   - Resolved defects (chi in M') are removed from the set
   - chi in M' does NOT imply F(chi) in M' (irreflexive semantics)
   - No new defects can enter (sigma_list is finite and fixed)
4. **Delete false lemmas** (bx_le_refl, g_content_subset_self, sigma_le_refl, etc.) rather than trying to prove them.

### Medium-term (6 months)

5. **After closing critical-path sorries**, address the 14 irreflexive-consequence sorries as architectural cleanup. Many are deletion + rewiring, not new proofs.
6. **Run `#print axioms bx_completeness`** to verify no hidden sorry dependencies through transitive imports (SuccRelation, SuccExistence, TemporalDerived).
7. **Write the completeness proof section** for the paper, using the canonical model construction as the primary contribution.

### Long-term (12 months)

8. **Dense completeness** (task 68) over rational numbers is an independent track worth pursuing after base completeness.
9. **Decidability** via FMP is mostly in place and provides an independent publication.
10. **Archive or delete** the ConservativeExtension module (4 files) -- it predates the BX system, lacks Until/Since, and is not on any active path.

## Axiom Design Analysis

### Current BX System Strengths

- **Complete for all linear orders**: Not restricted to discrete or dense
- **No IRR rule needed**: Seriality + connectedness provide the structural properties
- **Modular**: 4 clean layers (propositional, S5 modal, BX temporal, interaction)
- **Sound**: Sorry-free soundness proof across all 35 axioms
- **Until/Since native**: BX2-BX12 provide rich Until/Since manipulation

### Potential Extensions (for future work, not task 109)

| Extension | Axiom | Frame Class | Status |
|-----------|-------|-------------|--------|
| Density | `GG(phi) -> G(phi)` | Dense linear orders | Extension point in Axioms.lean |
| Discreteness | `F(phi) -> X(phi)` | Discrete linear orders | X/Y defined in Formula.lean |
| Confluence | Already given by linearity | -- | Built into BX7 |
| Well-ordering | `G(G(phi) -> phi) -> G(phi)` | Well-ordered | Not explored |

None of these are needed for base completeness.

## Publication Path Assessment

### Strongest Path: Base BX Completeness

**Theorem**: For all formulas phi, if phi is valid over all task models with irreflexive linear temporal ordering, then phi is BX-derivable.

**Novel contributions**:
1. First machine-checked completeness for bimodal tense logic with Until/Since
2. Canonical model via Hintikka-set quasimodel with defect-discharge
3. Irreflexive semantics treatment (aligning with Prior's tradition)
4. D-parametric representation theorem (uniform in the duration type)

**Target venue**: Journal of Automated Reasoning, or a modal logic venue (AiML, Advances in Modal Logic).

### Fallback: Partial Results

Even without full completeness, the project has publishable components:
- Sorry-free soundness for BX over irreflexive semantics
- Finite model property via filtration
- Quasimodel defect-discharge for Until/Since eventuality resolution (sorry-free)
- The D-parametric algebraic representation framework

## Confidence Level

**Medium-High** (same as previous round, with additional conviction)

- **High confidence** that the BX axiom system is sufficient (no extensions needed)
- **High confidence** that irreflexive semantics was the correct choice
- **High confidence** that the mathematical argument (finite descent on active defects) is sound
- **Medium confidence** that the formalization can carry it through without another pivot
- **Low confidence** in any time estimates (36 dead ends document the difficulty)
- **High confidence** in the publication value of the result if achieved
