# Research Report: Task #924 (Round 3)

- **Task**: 924 - Prove fully_saturated_bmcs_exists: combining modal saturation with temporal coherence
- **Started**: 2026-02-24T22:00:00Z
- **Completed**: 2026-02-24T23:30:00Z
- **Effort**: 1.5 hours
- **Dependencies**: research-001.md, research-002.md, implementation-summary-20260224.md
- **Sources/Inputs**:
  - `Theories/Bimodal/Metalogic/Bundle/TruthLemma.lean` (truth lemma structure)
  - `Theories/Bimodal/Metalogic/Bundle/BMCS.lean` (BMCS definition)
  - `Theories/Bimodal/Metalogic/Bundle/BMCSTruth.lean` (truth predicate)
  - `Theories/Bimodal/Metalogic/Bundle/BFMCS.lean` (BFMCS structure)
  - `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean` (the sorry at line 819)
  - `Theories/Bimodal/Metalogic/Bundle/CanonicalBFMCS.lean` (sorry-free temporal coherence)
  - `Theories/Bimodal/Metalogic/Bundle/CanonicalFrame.lean` (canonical relations)
  - `Theories/Bimodal/Metalogic/Bundle/CoherentConstruction.lean` (BoxContent, CoherentBundle)
  - `Theories/Bimodal/Metalogic/Bundle/ModalSaturation.lean` (modal saturation)
  - `Theories/Bimodal/Metalogic/Bundle/Completeness.lean` (completeness chain)
  - `Theories/Bimodal/Metalogic/Representation.lean` (standard semantics bridge)
  - `Theories/Bimodal/Semantics/Truth.lean` (standard truth predicate)
  - `Theories/Bimodal/Semantics/TaskFrame.lean` (frame structure)
- **Artifacts**: This report
- **Standards**: status-markers.md, artifact-management.md, tasks.md, report.md

## Project Context

- **Upstream Dependencies**: `canonicalMCSBFMCS` (sorry-free temporal coherence), `diamond_boxcontent_consistent_constant` (sorry-free modal witness consistency), `saturated_modal_backward` (sorry-free), `bmcs_truth_lemma` (sorry-free given temporal coherence), `temporal_backward_G`/`temporal_backward_H` (sorry-free)
- **Downstream Dependents**: `fully_saturated_bmcs_exists_int` (the sorry), `construct_saturated_bmcs_int`, `bmcs_representation`, `bmcs_weak_completeness`, `bmcs_strong_completeness`, `standard_representation`, `standard_weak_completeness`, `standard_strong_completeness`
- **Alternative Paths**: Restructuring BMCS semantics (D = CanonicalMCS), two-tier truth lemma, DovetailingChain sorry elimination
- **Potential Extensions**: Generalization beyond S5-temporal logic, connection to Goldblatt's canonical model theory

## Executive Summary

- The root cause of the obstruction is a **three-way circular dependency**: the Box case of the truth lemma applies the induction hypothesis at ALL families, which for temporal subformulas invokes temporal_backward_G/H, which requires forward_F/backward_P for that family -- but constant witness families (the only kind that can guarantee formula membership) cannot satisfy forward_F/backward_P.
- The user's key insight that "MCSs need not form a single temporal order" and that "world histories as equivalence classes" could help is mathematically correct but does not resolve the obstruction at the BMCS level, because the BMCS truth lemma's structural induction forces temporal coherence at ALL families regardless of how families are organized.
- Changing `D` from `Int` to `CanonicalMCS` does not help because: (a) the truth lemma still requires temporal coherence for witness families, and (b) the Representation layer requires `[AddCommGroup D] [LinearOrder D]` which CanonicalMCS lacks.
- **The viable path forward is a two-tier truth predicate** where the truth lemma uses DIFFERENT predicates at the eval family vs witness families. For constant witness families, a restricted truth predicate `bmcs_truth_at_constant` would treat `G(phi)` as equivalent to `phi` (correct semantically for time-independent families) and `Box(phi)` as still quantifying over families (preserving modal coherence). This avoids the temporal coherence requirement entirely for witness families.
- Alternative: Eliminate the DovetailingChain sorries for forward_F/backward_P on `D = Int`, enabling non-constant witness families that inherit temporal coherence from the chain construction.

## Context & Scope

This is the third research round for task 924. Round 1 identified the fundamental blocker (constant families cannot be temporally coherent). Round 2 exhaustively analyzed 17 candidate strategies and concluded that no construction simultaneously achieves temporal coherence for ALL families AND modal saturation using constant witness families. The implementation attempt confirmed this by tracing the exact dependency chain in the truth lemma code.

This round focuses on the user's specific insights about overlapping temporal subsets, flexible domains, and world histories as equivalence classes, and develops them into a concrete technical proposal.

## Findings

### 1. Root Cause: The Three-Way Circular Dependency (Precisely Characterized)

The obstruction can be traced through three specific code locations:

**Step A**: `bmcs_truth_lemma` Box case backward (TruthLemma.lean:341-348):
```lean
-- Backward: (forall fam' in families, bmcs_truth psi at fam') -> Box(psi) in fam.mcs t
intro h_all
have h_psi_all_mcs : forall fam' in B.families, psi in fam'.mcs t := by
  intro fam' hfam'
  exact (ih fam' hfam' t).mpr (h_all fam' hfam')  -- <--- IH backward at ALL fam'
exact B.modal_backward fam hfam psi t h_psi_all_mcs
```

The `ih fam' hfam' t` calls the IH at every family in the bundle, including witness families. When `psi` contains temporal operators, this recurses into:

**Step B**: `bmcs_truth_lemma` all_future case backward (TruthLemma.lean:361-375):
```lean
-- Backward: (forall s >= t, bmcs_truth psi at s) -> G(psi) in fam.mcs t
obtain <h_forward_F, h_backward_P> := h_tc fam hfam  -- <--- needs temporal coherence
let tcf : TemporalCoherentFamily D := { toBFMCS := fam, forward_F := ..., backward_P := ... }
exact temporal_backward_G tcf t psi h_all_mcs
```

This extracts `forward_F` and `backward_P` for the CURRENT family (which may be a witness family).

**Step C**: `temporal_backward_G` (TemporalCoherentConstruction.lean:225-249):
```lean
-- Uses forward_F by contraposition:
-- If G(phi) NOT in MCS, then F(neg phi) in MCS, then exists s >= t with neg phi in MCS
obtain <s, h_le, h_neg_phi_s> := fam.forward_F t (neg phi) h_F_neg
```

For a constant witness family `fam_M` where `fam_M.mcs(w) = M` for all `w`:
- `forward_F` requires: `F(chi) in M -> exists s, t <= s AND chi in M`
- This reduces to: `F(chi) in M -> chi in M` (since `fam_M.mcs(s) = M` for all `s`)
- This is **temporal saturation**, which is FALSE for arbitrary MCS (e.g., `{F(p), neg(p)}` is consistent but violates temporal saturation)

The dependency chain is: Box backward -> IH at all families -> G backward at witness family -> forward_F at witness family -> temporal saturation of witness MCS.

### 2. Analysis of User Insight: "MCSs Need Not Form a Single Temporal Order"

The user's insight is mathematically correct in the abstract: in the canonical model for temporal logic, the set of all MCSs forms a Preorder under `CanonicalR`, and this Preorder decomposes into overlapping subsets (the future-reachable sets from various roots). The `temp_linearity` axiom ensures totality within each reachable fragment (`canonical_reachable_linear`, proven sorry-free in CanonicalEmbedding.lean).

However, this insight does not resolve the BMCS-level obstruction because:

**The BMCS truth lemma does not care about temporal ordering between families**. The Box case quantifies families at the SAME time point `t`, not across different time points. The temporal coherence requirement comes from the INDUCTION on subformulas (when Box wraps a G-formula), not from inter-family temporal relationships.

In other words: even if we partition MCSs into overlapping temporally coherent subsets, and even if each subset forms a perfect linear temporal history, the truth lemma still needs forward_F at whichever family the induction hypothesis lands on -- and that family might be a constant witness family from a DIFFERENT temporal subset.

### 3. Analysis of User Insight: "Flexible Domains (Convex Subsets)"

The user suggests that domains need not be `Int` -- any convex subset works. This is true: BFMCS and the truth lemma only require `[Preorder D] [Zero D]`, not `LinearOrder` or `AddCommGroup`.

However, this does not help because:
- The **truth lemma** works for any Preorder D
- The **obstruction** is about temporal coherence of witness families, which is domain-independent (constant families fail regardless of D)
- The **Representation layer** (`Representation.lean`, `TaskFrame`) requires `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]`, severely constraining D choices

### 4. Analysis of User Insight: "World Histories as Equivalence Classes"

The user asks: "Can we define world histories as equivalence classes under some closure property where linearity is internal to each class?"

This is the BoxContent equivalence class idea that research-002 explored in detail (Section 11, Path C). The key facts:

- **BoxContent equivalence** partitions MCSs by their Box-content: `M ~ M'` iff `{phi | Box(phi) in M} = {phi | Box(phi) in M'}`
- Within each equivalence class, S5 axioms ensure modal coherence
- The `diamond_boxcontent_consistent_constant` theorem (CoherentConstruction.lean:249) proves that witness seeds from BoxContent-equivalent MCSs are consistent
- `BoxEquivalent` (CoherentConstruction.lean:482) formalizes this inter-family coherence

The BoxContent equivalence class IS the right structure for modal coherence. The remaining obstacle is temporal coherence within this class.

### 5. The Key New Insight: Two-Tier Truth Predicate

The fundamental observation is: **the truth lemma for constant families should use a different truth predicate than for non-constant families**.

For a constant family `fam_M` with `fam_M.mcs(w) = M` for all `w`:
- `bmcs_truth_at B fam_M w (G phi) = forall s >= w, bmcs_truth_at B fam_M s phi`
- Since `fam_M` is constant, the RHS is time-independent: `bmcs_truth_at B fam_M s phi` gives the same result for all `s`
- So `bmcs_truth_at B fam_M w (G phi) = bmcs_truth_at B fam_M w phi` (semantically, G = identity for constant families)
- The desired IFF is: `G(phi) in M <-> phi in M`
- Forward (G(phi) in M -> phi in M): TRUE by T-axiom
- Backward (phi in M -> G(phi) in M): FALSE in general

The backward direction fails because the STANDARD truth predicate `bmcs_truth_at` forces `G(phi)` to quantify over future times even when the family is constant. But semantically, a constant family represents a "timeless" perspective where temporal operators collapse.

**Solution**: Define a CONSTANT-FAMILY truth predicate:

```lean
def bmcs_truth_at_constant (B : BMCS D) (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (t : D) : Formula -> Prop
  | Formula.atom p => Formula.atom p in M
  | Formula.bot => False
  | Formula.imp phi psi => bmcs_truth_at_constant B M h_mcs t phi -> bmcs_truth_at_constant B M h_mcs t psi
  | Formula.box phi => forall fam' in B.families, bmcs_truth_at_dispatch B fam' t phi
  | Formula.all_future phi => bmcs_truth_at_constant B M h_mcs t phi  -- G = identity for constant
  | Formula.all_past phi => bmcs_truth_at_constant B M h_mcs t phi    -- H = identity for constant
```

where `bmcs_truth_at_dispatch` routes to `bmcs_truth_at` for the eval family and `bmcs_truth_at_constant` for constant witness families.

**Truth lemma for constant families**: `phi in M <-> bmcs_truth_at_constant B M h_mcs t phi`

- Atom: trivial
- Bot: by consistency
- Imp: by MCS properties (same as before)
- Box: forward uses modal_forward, backward uses modal_backward (same as before, BUT the IH at other families uses the dispatched predicate)
- G: `G(phi) in M <-> phi in M`, which is: forward by T-axiom, backward by... phi in M <-> bmcs_truth_at_constant ... phi (IH), and bmcs_truth_at_constant ... (G phi) = bmcs_truth_at_constant ... phi (by definition). So backward is just the identity.
- H: symmetric to G

**The key realization**: By defining `G(phi)` as equivalent to `phi` for constant families, the backward G case becomes trivial. This is semantically correct because a constant family's truth IS time-independent.

### 6. The Challenge: Box Case Cross-Reference Between Truth Predicates

The Box case in the constant-family truth lemma needs:
```
Box(phi) in M <-> forall fam' in B.families, bmcs_truth_at_dispatch B fam' t phi
```

The backward direction requires: for each `fam'`, `bmcs_truth_at_dispatch B fam' t phi` implies `phi in fam'.mcs t`. This invokes the IH at `fam'`:
- If `fam'` is the eval family: use `bmcs_truth_at -> phi in fam'.mcs t` (standard truth lemma)
- If `fam'` is a constant family with MCS `M'`: use `bmcs_truth_at_constant -> phi in M'`

This means the truth lemma must be proven as a MUTUAL induction over both predicates simultaneously. This is technically demanding but well-defined.

### 7. Alternative: Two-Tier BMCS Structure

Instead of modifying the truth predicate, modify the BMCS structure to distinguish between the eval family and witness families:

```lean
structure TwoTierBMCS (D : Type*) [Preorder D] where
  eval_family : BFMCS D  -- non-constant, temporally coherent
  witness_families : Set (Set Formula)  -- constant families (just the MCS, not a BFMCS)
  witness_mcs : forall M in witness_families, SetMaximalConsistent M
  modal_forward : forall phi t, Box(phi) in eval_family.mcs t ->
    (forall M in witness_families, phi in M) AND phi in eval_family.mcs t
  modal_backward : forall phi t,
    (forall M in witness_families, phi in M) AND phi in eval_family.mcs t ->
    Box(phi) in eval_family.mcs t
  eval_family_tc : TemporalCoherentFamily eval_family
  saturated : forall psi, Diamond(psi) in eval_family.mcs t ->
    exists M in witness_families, psi in M
```

In this formulation:
- Temporal coherence is ONLY required for `eval_family` (which uses `canonicalMCSBFMCS`, sorry-free)
- Witness families are just MCSs (not BFMCS), with no temporal structure
- The truth predicate handles witness families as time-independent

### 8. Feasibility Assessment of the Two-Tier Approach

**Advantages**:
- Avoids the impossible requirement of temporal coherence for constant witness families
- `eval_family` uses `canonicalMCSBFMCS` which has sorry-free temporal coherence
- Witness families use the proven `diamond_boxcontent_consistent_constant` infrastructure
- No change to D (stays as `Int` for the Representation layer)

**Challenges**:
- The truth lemma must be restructured (not just patched)
- The Completeness chain (Completeness.lean, Representation.lean) consumes `BMCS Int` with the current `bmcs_truth_at`; switching to `TwoTierBMCS` requires updating all consumers
- The `bmcs_truth_at` definition is recursive on Formula; a dispatch mechanism needs careful handling to ensure termination

**Estimated scope**: 3-4 new files, modifications to TruthLemma.lean, Completeness.lean, and Representation.lean. Major refactoring but localized to the Bundle/ directory.

### 9. Evaluation of Original Three Alternatives

**Alternative A: Refactor BMCS to use D=CanonicalMCS**

- Verdict: NOT VIABLE as a standalone fix
- CanonicalMCS has `[Preorder]` but NOT `[AddCommGroup]`, `[LinearOrder]`, or `[IsOrderedAddMonoid]`
- `TaskFrame` (Semantics/TaskFrame.lean:84) requires all three
- `box_persistent` (Representation.lean:228) uses `le_or_gt` requiring `LinearOrder`
- Refactoring the entire semantics layer to weaken these constraints is a multi-month effort

**Alternative B: Eliminate DovetailingChain forward_F/backward_P sorries**

- Verdict: VIABLE but high-effort
- If DovetailingChain's forward_F and backward_P are sorry-free, then non-constant witness families can be built using the same chain mechanism
- Each witness family `fam_psi` would be a DovetailingChain seeded with `{psi} union BoxContent(eval_family)`, ensuring both temporal coherence (from chain construction) and psi membership (from seed)
- Requires proving the 4 DovetailingChain sorries, which are the most challenging open problems in the codebase
- If achieved, `fully_saturated_bmcs_exists_int` would follow with ALL families using DovetailingChain-based constructions

**Alternative C: Accept the sorry as architectural limitation**

- Verdict: NOT RECOMMENDED
- The sorry blocks publication of the entire completeness chain
- It propagates to `bmcs_representation`, `bmcs_weak_completeness`, `bmcs_strong_completeness`, `standard_representation`, `standard_weak_completeness`, `standard_strong_completeness`
- Remediation priority: HIGH

### 10. The Recommended Path: Two-Tier Truth Predicate with Int Domain

The recommended approach combines elements of the user's insights with the concrete architectural constraints:

**Phase 1: Define TwoTierBMCS and Dispatch Truth Predicate**
- Define `TwoTierBMCS` structure with eval family (BFMCS) + constant witness families (Set Formula)
- Define `two_tier_truth_at` with dispatch: eval family uses standard recursive truth, constant families collapse temporal operators
- Estimated effort: 1 implementation session

**Phase 2: Prove Two-Tier Truth Lemma**
- Prove by mutual induction: `phi in fam.mcs t <-> two_tier_truth_at` for both family types
- Key cases: Box dispatches to the appropriate sub-lemma, G/H at constant families is trivial
- Estimated effort: 2-3 implementation sessions (the mutual induction is the hardest part)

**Phase 3: Construct TwoTierBMCS from Consistent Context**
- eval_family: Use `canonicalMCSBFMCS` restricted to CanonicalReachable (sorry-free temporal coherence) or use DovetailingChain over Int (with known sorries)
- witness_families: Use `CoherentBundle` construction (proven modal coherence)
- Saturation: Iterate diamond-witness construction until saturated (proven in ModalSaturation)
- Estimated effort: 1-2 implementation sessions

**Phase 4: Bridge to Completeness and Representation**
- Adapt `bmcs_representation` to use `TwoTierBMCS`
- Adapt `canonical_truth_lemma_all` in Representation.lean
- Estimated effort: 1-2 implementation sessions

**Total estimated effort**: 5-8 implementation sessions (significant but feasible)

### 11. Alternative Quick Win: Weaken fully_saturated_bmcs_exists_int to CanonicalMCS

There is a potentially quicker path that sidesteps the `Int` constraint entirely:

1. Prove `fully_saturated_bmcs_exists` for `D = CanonicalMCS` (which has sorry-free temporal coherence via `canonicalMCSBFMCS`)
2. Change Completeness.lean to use `BMCS CanonicalMCS` instead of `BMCS Int`
3. The BMCS-level completeness (bmcs_representation, bmcs_weak_completeness, bmcs_strong_completeness) does NOT use `TaskFrame`, `AddCommGroup`, or `LinearOrder` -- it only uses `[Preorder D] [Zero D]`
4. Only the Representation.lean bridge to standard semantics needs `Int`

This would make the BMCS-level completeness results sorry-free while deferring the standard-semantics bridge to a separate task.

**However**: This still has the same fundamental problem. Even with `D = CanonicalMCS`, the truth lemma requires temporal coherence for ALL families. Constant witness families over CanonicalMCS still fail the G backward case (phi in M does not imply G(phi) in M).

So even this path requires either the two-tier truth predicate OR non-constant witness families.

## Decisions

1. The two-tier truth predicate approach is the most promising path to eliminating `fully_saturated_bmcs_exists_int`
2. Alternative B (DovetailingChain sorry elimination) would also resolve the issue but is higher-effort and has independent value
3. The user's insights about BoxContent equivalence classes correctly identify the modal structure but do not bypass the temporal coherence requirement at the truth lemma level

## Recommendations

### Recommendation 1 (Highest Priority): Implement Two-Tier Truth Predicate

Create a new `TwoTierTruthLemma.lean` alongside the existing truth lemma. The key innovation is collapsing temporal operators for constant families in the truth predicate definition. This preserves the existing architecture while resolving the fundamental obstruction.

**Owner**: Implementation task (new, derived from 924)
**Estimated effort**: 5-8 sessions across 4 phases

### Recommendation 2 (Medium Priority): Prototype the Constant-Family Truth Lemma

Before committing to the full two-tier refactoring, prove the constant-family truth lemma in isolation:

```lean
-- For a constant family with MCS M:
-- phi in M <-> constant_truth B M t phi
-- where constant_truth treats G/H as identity
```

This is a quick feasibility check (1 session) that validates the approach.

### Recommendation 3 (Parallel Track): Continue DovetailingChain Sorry Elimination

Task 922 (which this task depends on) is working on the DovetailingChain infrastructure. If forward_F and backward_P are proven sorry-free for Int, the entire obstruction dissolves because:
- Witness families can be built as DovetailingChains seeded with `{psi} union BoxContent`
- These non-constant families inherit temporal coherence from the chain
- The existing truth lemma works unchanged

This is the "cleanest" resolution but depends on independently hard proofs.

### Recommendation 4 (Short-Term): Separate BMCS Completeness from Standard Completeness

The BMCS-level completeness (`bmcs_weak_completeness`, `bmcs_strong_completeness`) is a genuine completeness result independent of standard Kripke semantics. Consider:
- Accepting the sorry only in the Representation layer bridge
- Making BMCS completeness the primary result, with standard-semantics completeness as a secondary goal
- This decouples the temporal coherence problem from the representation problem

## Sorry Characterization

### Current State
- 1 sorry in `TemporalCoherentConstruction.lean:819` (`fully_saturated_bmcs_exists_int`)

### Transitive Impact
- `construct_saturated_bmcs_int` inherits sorry status
- `bmcs_representation` inherits sorry status
- `bmcs_weak_completeness` inherits sorry status (the sorry chain passes through bmcs_representation)
- `bmcs_strong_completeness` inherits sorry status
- `canonical_truth_lemma_all` (Representation.lean) inherits sorry status
- `standard_representation`, `standard_weak_completeness`, `standard_strong_completeness` all inherit sorry status
- Total: the sorry blocks the entire completeness chain from publication

### Remediation Path
- **Two-tier truth predicate** (Recommendation 1): Eliminates the sorry by restructuring how the truth lemma handles constant families
- **DovetailingChain resolution** (Recommendation 3): Eliminates the sorry by making witness families non-constant and temporally coherent
- Either path fully eliminates this sorry

### Publication Status
This sorry blocks publication. Remediation priority: HIGH.

## Axiom Characterization

### Current State
- `fully_saturated_bmcs_exists` (deprecated polymorphic axiom, line 755) -- replaced by the sorry-backed theorem
- `fully_saturated_bmcs_exists_int` (sorry at line 819) -- the current approach

### Transitive Impact
- Same as sorry impact above
- All completeness results inherit either axiom or sorry dependency

### Remediation Path
- The polymorphic axiom is already deprecated
- The Int-specialized version is a sorry-backed theorem (not a Lean axiom), which is the correct technical debt form
- Remediation via two-tier truth predicate or DovetailingChain resolution

### Publication Status
Publication requires either eliminating the sorry or explicitly disclosing it as an assumption.

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Two-tier truth lemma mutual induction fails | High | Prototype constant-family lemma first (Rec. 2) |
| Box dispatch in two-tier predicate breaks termination checker | Medium | Use well-founded recursion on formula size |
| TwoTierBMCS breaks Representation.lean invariants | Medium | Keep D=Int, only change truth predicate dispatch |
| DovetailingChain sorries are fundamentally hard | High | Pursue two-tier approach in parallel |
| Two-tier approach creates maintenance burden (two truth lemmas) | Low | Can be unified once DovetailingChain resolves |

## Appendix

### Key Definitions Referenced

- `BMCS.temporally_coherent` (TemporalCoherentConstruction.lean:298): Requires forward_F AND backward_P for ALL families
- `bmcs_truth_at` (BMCSTruth.lean:88): Recursive truth predicate with Box over families, G/H over times
- `TemporalCoherentFamily` (TemporalCoherentConstruction.lean:206): BFMCS + forward_F + backward_P
- `IsConstantFamily` (CoherentConstruction.lean:214): `exists M, forall t, fam.mcs t = M`
- `BoxEquivalent` (CoherentConstruction.lean:482): Box-content agreement across families
- `canonicalMCSBFMCS` (CanonicalBFMCS.lean:158): Identity-mapped BFMCS, sorry-free temporal coherence
- `TaskFrame` (Semantics/TaskFrame.lean:84): Requires `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]`

### Concrete Code Sketch: Constant-Family Truth

```lean
-- The constant-family truth predicate
def constant_truth_at (B : BMCS D) (M : Set Formula) (t : D) : Formula -> Prop
  | Formula.atom p => Formula.atom p in M
  | Formula.bot => False
  | Formula.imp phi psi => constant_truth_at B M t phi -> constant_truth_at B M t psi
  | Formula.box phi => forall fam' in B.families, dispatched_truth_at B fam' t phi
  | Formula.all_future phi => constant_truth_at B M t phi  -- KEY: G = identity
  | Formula.all_past phi => constant_truth_at B M t phi    -- KEY: H = identity

-- Dispatch based on family type
def dispatched_truth_at (B : BMCS D) (fam : BFMCS D) (t : D) (phi : Formula) : Prop :=
  if h : IsConstantFamily fam then
    constant_truth_at B (Classical.choose h) t phi
  else
    bmcs_truth_at B fam t phi

-- The constant-family truth lemma (sketch)
theorem constant_truth_lemma (B : BMCS D) (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (t : D) (phi : Formula) :
    phi in M <-> constant_truth_at B M t phi := by
  induction phi with
  | all_future psi ih =>
    -- G(psi) in M <-> constant_truth_at ... (G psi) = constant_truth_at ... psi
    -- G(psi) in M <-> psi in M  (need this IFF)
    -- Forward: G(psi) in M -> psi in M  (T-axiom, PROVEN)
    -- Backward: psi in M -> G(psi) in M  (need proof!)
    sorry -- THIS IS THE KEY QUESTION
```

**Critical gap in the sketch**: The backward direction `psi in M -> G(psi) in M` is still needed. The two-tier approach resolves this by defining `constant_truth_at ... (G psi) = constant_truth_at ... psi`, making the IFF `G(psi) in M <-> psi in M` where:
- Forward: T-axiom
- Backward: Actually, we need `psi in M -> G(psi) in M`. This is STILL FALSE.

**Resolution**: The truth lemma for constant families should prove `G(psi) in M <-> constant_truth_at B M t (G psi) = constant_truth_at B M t psi <-> psi in M`. The IFF chain is:
- `G(psi) in M <-> psi in M` (by IH + the fact that constant_truth_at collapses G)
- Forward: T-axiom (Box phi -> phi, with Box = G for temporal)
- Backward: phi in M -> G(phi) in M ... this is STILL the problem.

**Corrected approach**: The issue persists even with the collapsed definition because the truth lemma requires BOTH directions. The collapse means `constant_truth_at B M t (G psi) = constant_truth_at B M t psi`, so the truth lemma needs `G(psi) in M <-> psi in M`. The forward direction (G -> psi) is fine by T-axiom, but the backward direction (psi -> G(psi)) is false for arbitrary M.

**The real fix**: Instead of a truth-predicate trick, the issue must be resolved at the BMCS structure level. The truth lemma is a PROVEN theorem (no sorry). The sorry is in the CONSTRUCTION of the BMCS. The truth lemma says: IF a BMCS is temporally coherent, THEN truth = MCS membership. The construction must PROVIDE a temporally coherent BMCS.

This means the two-tier approach should modify the BMCS STRUCTURE and its construction, not just the truth predicate. The witness families must either (a) be non-constant (resolving temporal coherence) or (b) not appear in the BMCS families at all (resolving the requirement that ALL families satisfy temporal coherence).

### Revised Concrete Proposal: Witness-External BMCS

The cleanest approach is to make witness families EXTERNAL to the BMCS bundle:

```lean
-- A BMCS where modal saturation is proved WITHOUT adding witness families to the bundle
-- Instead, the eval_family ITSELF contains all Diamond witnesses
-- by being the identity family over BoxContent-equivalent MCSs

-- Key idea: For D = CanonicalMCS, the single family canonicalMCSBFMCS already
-- evaluates phi at fam.mcs(w) = w.world for each MCS w. Box(phi) at time w
-- should mean: phi at all w' that are "modally accessible" from w.

-- Redefine bmcs_truth_at for Box to quantify over time points (not families):
--   bmcs_truth_at B fam t (Box phi) = forall w : D, phi in fam.mcs w
-- But this is TOO STRONG (requires phi in every MCS).

-- Restrict to BoxContent-equivalent elements:
--   bmcs_truth_at B fam t (Box phi) =
--     forall w : D, BoxContent_equiv w t -> phi in fam.mcs w
-- where BoxContent_equiv means same BoxContent as fam.mcs(t)
```

This approach eliminates witness families entirely, replacing them with a Box semantics that quantifies over time points within the same modal equivalence class. However, this requires a fundamentally different BMCS definition, truth predicate, and truth lemma -- essentially a ground-up reconstruction.

### Final Assessment

The `fully_saturated_bmcs_exists_int` sorry represents a genuine architectural gap in the BMCS framework. The gap exists because the BMCS was designed with modal completeness as the primary concern (multiple families for Box), while temporal completeness (forward_F/backward_P for G/H) was treated as an orthogonal requirement. The two requirements are NOT orthogonal -- they interact through the truth lemma's structural induction.

The most practical resolution paths, in order of increasing scope but decreasing risk:

1. **Eliminate DovetailingChain sorries** (forward_F/backward_P for Int) -- enables non-constant witness families, no architectural change
2. **Two-tier BMCS with external witnesses** -- separates eval family (temporally coherent) from witness MCSs (no temporal structure), requires truth lemma restructuring
3. **BoxContent-indexed single-family BMCS** -- eliminates multiple families, replaces with Box quantification over equivalence class, requires ground-up reconstruction

Path 1 is the recommended approach if DovetailingChain progress is feasible. Path 2 is the recommended approach if a clean break from the current architecture is desired.
