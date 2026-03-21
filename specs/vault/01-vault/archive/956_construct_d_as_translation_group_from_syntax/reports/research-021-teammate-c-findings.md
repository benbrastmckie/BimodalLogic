# Teammate C Findings: TM Bimodal Structure Analysis

**Task**: 956 - Construct D as translation group from syntax
**Date**: 2026-03-09
**Session**: sess_1773100541_8069e4
**Run**: 021
**Role**: Risk analysis - TM bimodal structure and its implications for D construction

---

## Key Findings

### 1. TM is a genuinely bimodal logic with orthogonal dimensions

The TM logic combines **S5 modal logic** (necessity/possibility, Box/Diamond) with **linear tense logic** (future/past, G/H/F/P). These two modalities operate on entirely different dimensions:

- **Modal dimension (Box/Diamond)**: Quantifies over histories (worldlines). Box phi = "phi holds along ALL admissible histories at the current time." The accessibility relation is an S5 equivalence relation (reflexive + symmetric + transitive, via axioms MT, MB, M4, M5-collapse).

- **Temporal dimension (G/H/F/P)**: Quantifies over times WITHIN a single history. G phi = "phi holds at all strictly future times along this history." The temporal order is linear (via temp_linearity axiom).

The interaction axioms MF (`Box phi -> Box(G phi)`) and TF (`Box phi -> G(Box phi)`) connect the two dimensions but do NOT merge them.

### 2. Semantic structure: Histories as functions from D to WorldState

From `WorldHistory.lean`:
- A history `tau` is a partial function from times `D` to world states `F.WorldState`
- The domain is a **convex** subset of D (no temporal gaps)
- The function must **respect the task relation**: for `s <= t` in domain, `task_rel (tau(s)) (t-s) (tau(t))`
- Truth of `Box phi` at `(tau, t)` = for ALL histories `sigma` in Omega, `phi` holds at `(sigma, t)` -- note the TIME is fixed, only the history changes
- Truth of `G phi` at `(tau, t)` = for ALL times `s > t`, `phi` holds at `(tau, s)` -- note the HISTORY is fixed, only the time changes

**Critical observation**: The modal and temporal dimensions are genuinely orthogonal in the truth definition. Box changes the history at a fixed time. G/H change the time along a fixed history.

### 3. D serves as the temporal axis, NOT the modal axis

D is the type parameter of `TaskFrame D`. It is:
- `AddCommGroup D` (abelian group for duration arithmetic)
- `LinearOrder D` (totally ordered)
- `IsOrderedAddMonoid D` (order compatible with addition)

D indexes the temporal dimension only. The modal dimension is handled by the set Omega of admissible histories (WorldHistory instances). D has NO direct connection to the modal structure.

### 4. The history dimension does NOT affect freeness requirements for D

The TranslationGroup construction defines D as order automorphisms of the canonical timeline T (BidirectionalQuotient). This construction operates entirely within the temporal dimension:
- T = antisymmetrization of the bidirectional MCS fragment (temporal ordering via GContent inclusion)
- D = Additive(T ≃o T) (order-preserving self-maps of T)

The modal dimension enters only when constructing the full canonical model:
- Each FMCS family in the BFMCS corresponds to one WorldHistory
- Multiple families are needed for modal saturation (Box semantics)
- But D is the SAME across all families -- it indexes time uniformly

**Impact on freeness**: The automorphisms in D act on the temporal order T. Histories (functions from T to WorldState) are separate objects. An automorphism d in D acts on a history tau by time-shifting: `(d.tau)(t) = tau(d^{-1}(t))`. The freeness question (is the action free? is eval-at-origin injective?) depends only on the structure of T, not on the histories.

### 5. The JPL paper uses D = Z (or Q) as a parameter

From the axiom file and representation module:
- The current Representation module uses `D = Int` (i.e., `canonicalFrame (B : BFMCS Int) : TaskFrame Int`)
- The task relation is TRIVIAL: `task_rel := fun _ _ _ => True`
- This means the task frame in the representation ignores D's algebraic structure entirely -- it is used ONLY as a time index

This is a significant simplification. The paper's TaskFrame definition requires compositionality (`task_rel w d1 u /\ task_rel u d2 v -> task_rel w (d1+d2) v`), which IS satisfied by the trivial relation, but it means the representation theorem does not USE the group structure of D for anything beyond time indexing.

### 6. The MF and TF axioms are the only modal-temporal bridge

The interaction axioms:
- **MF**: `Box phi -> Box(G phi)` -- if phi is necessary, then G(phi) is also necessary
- **TF**: `Box phi -> G(Box phi)` -- if phi is necessary, then at all future times Box(phi) holds

These are proven sound via `time_shift_preserves_truth`, which shows truth is invariant under time-shifting when Omega is shift-closed. The soundness proof for MF/TF requires `ShiftClosed(Omega)` but does NOT impose constraints on D's algebraic structure.

---

## Risk Analysis

### Risk 1: TranslationGroup approach -- Holder's theorem formalization

**What could go wrong**: The TranslationGroup D = Additive(T ≃o T) has AddGroup but needs AddCommGroup. This requires Holder's theorem: a linearly ordered group acting freely on a linearly ordered set is abelian. Formalizing Holder's theorem in Lean 4 / Mathlib is a substantial undertaking (it involves reasoning about Archimedean properties and the density of orbits).

**Severity**: HIGH. Without AddCommGroup, D cannot be a TaskFrame parameter.

**Mitigation**: Check if Mathlib already has Holder's theorem or related results. If not, consider bypassing by using the trivial task relation approach (where D's group structure is not meaningfully used).

### Risk 2: TranslationGroup approach -- homogeneity (transitivity of action)

**What could go wrong**: AddTorsor D T requires that for every a, b in T, there exists d in D with d.apply(a) = b. This is the transitivity of the automorphism group action, which requires the canonical timeline to be "homogeneous" -- every pair of points is related by some order automorphism. This is a strong property that depends on the specific structure of the BidirectionalQuotient.

**Severity**: HIGH. If the canonical timeline has "rigid" regions (e.g., a fixed point that every automorphism must preserve), transitivity fails.

**Evidence for concern**: The root MCS M0 is a distinguished point in the fragment. If the canonical timeline has asymmetric structure around the origin (e.g., the origin has different combinatorial properties than other points), not every translation will exist.

**Mitigation**: The formal displacements approach (research-020 Strategy I) avoids this by constructing D from syntactic translations rather than from automorphisms.

### Risk 3: Formal displacements approach -- semantic equivalence quantification

**What could go wrong**: The formal displacements construction defines D = Free(F,P) / semantic_equivalence, where two displacement sequences are equivalent if they produce the same temporal displacement in ALL models. This requires quantifying over ALL models of TM, which is a meta-theoretic definition that may not be directly expressible in Lean 4.

**Severity**: MEDIUM-HIGH. Lean 4 can express "for all TaskFrames D [instances] ..." but the type-level quantification over D makes this awkward.

**Mitigation**: Replace semantic equivalence with SYNTACTIC equivalence derived from the axioms (e.g., GG = G follows from temp_4). This gives a concrete quotient that can be constructed without quantifying over models.

### Risk 4: The trivial task relation makes D algebraically irrelevant

**What could go wrong**: The current representation uses `task_rel := fun _ _ _ => True`, which means the compositionality axiom is trivially satisfied regardless of D's group structure. This means D's algebraic properties (AddCommGroup, LinearOrder, IsOrderedAddMonoid) are imposed as TYPE-LEVEL constraints but never USED in the canonical model.

**Severity**: MEDIUM. This is not a bug, but it means any from-syntax construction of D must satisfy algebraic requirements that are never tested against the actual semantics. The requirements are purely definitional (matching the TaskFrame signature), not behavioral.

**Implication**: If we cannot construct D with full AddCommGroup from syntax, we could potentially weaken the TaskFrame definition (e.g., drop the group requirement and use only a linear order). But this would change the framework.

### Risk 5: Density blocker persists across all approaches

**What could go wrong**: Research-020 documents 4 sorries in DenseQuotient.lean related to proving that the BidirectionalQuotient is DenselyOrdered when the density axiom DN is present. The root cause is "Lindenbaum collapse" -- the inability to control which MCS Lindenbaum's lemma produces, leading to the risk that the intermediate MCS is quotient-equivalent to one of the endpoints.

**Severity**: HIGH for the TM+DN extension. Not a blocker for base TM.

**Evidence**: The DenseQuotient module uses a two-case proof strategy (Case A: GContent(b) not subset of b; Case B: GContent(b) subset of b). Both cases still have sorries.

### Risk 6: Bimodal structure creates no additional D constraints

**What could go wrong**: Nothing, actually. This is a POSITIVE finding. The bimodal structure does NOT impose additional constraints on D beyond what the temporal dimension alone requires. The modal dimension (Box/Diamond) operates orthogonally through the history set Omega, not through D.

**Severity**: NONE. This simplifies the D construction.

---

## The History Dimension

### How histories relate to D construction

1. **Histories are parameterized BY D, not contributors TO D**: A WorldHistory is a function `D -> WorldState` (partial, with convex domain). D is a prerequisite for defining histories, not something derived from them.

2. **The canonical model construction goes**: MCSes -> BFMCS (bundle of families) -> families become histories (via `canonicalHistory : BFMCS Int -> FMCS Int -> WorldHistory`) -> D = Int is chosen externally.

3. **If D = TranslationGroup**: The flow changes to: MCSes -> BidirectionalFragment -> BidirectionalQuotient = T -> D = Aut(T) -> histories are functions from T to WorldState. The histories still don't feed back into D's definition.

4. **Modal saturation creates more histories, not more time points**: The BFMCS construction adds witness families for Diamond obligations. Each new family adds a new WorldHistory (a new function from D to WorldState). But D itself -- the set of times -- remains the same across all families.

### What happens when automorphisms act on times

If D = Aut(T), an element d in D is an order automorphism of T. Given a history tau defined on T:
- The time-shifted history `d.tau` maps time t to state tau(d^{-1}(t))
- For ShiftClosed Omega: if tau is in Omega, then d.tau must be in Omega for all d
- The MF/TF axioms' soundness requires ShiftClosed Omega

**The critical issue**: The canonical Omega (histories from BFMCS families) is NOT shift-closed by D = Aut(T). It IS shift-closed by D = Int in the current representation (via `shiftClosedCanonicalOmega`). If D = TranslationGroup, shift-closure of the canonical Omega would require: for every family `fam` in the BFMCS and every automorphism `d` of T, the time-shifted family `t -> fam.mcs(d^{-1}(t))` must also be a family in the BFMCS.

This is a SIGNIFICANT requirement that the current BFMCS construction does not satisfy. The BFMCS is constructed for a specific D = Int, not for D = Aut(T).

---

## Evidence

### Codebase References

| File | Finding |
|------|---------|
| `Syntax/Formula.lean` | 6 constructors: atom, bot, imp, box, all_past, all_future. Box and temporal are independent primitives. |
| `Semantics/TaskFrame.lean` | TaskFrame parameterized by D with AddCommGroup + LinearOrder + IsOrderedAddMonoid. |
| `Semantics/Truth.lean` | Box quantifies over histories (Omega), G/H quantify over times (D). Orthogonal. |
| `Semantics/WorldHistory.lean` | Histories are partial functions D -> WorldState with convex domain and task_rel respect. |
| `ProofSystem/Axioms.lean` | 15 axiom schemata. Modal-temporal interaction only via MF and TF. |
| `Metalogic/Bundle/TranslationGroup.lean` | D = Additive(T ≃o T). AddGroup proven. AddCommGroup, LinearOrder, IsOrderedAddMonoid deferred. |
| `Metalogic/Representation.lean` | Canonical model uses D = Int, task_rel = True. |
| `Metalogic/Bundle/BFMCS.lean` | Bundle of families with modal coherence. Omega = families in bundle. |
| `Metalogic/Bundle/DenseQuotient.lean` | 4 sorries for DenselyOrdered on BidirectionalQuotient. |

### ROAD_MAP Dead Ends Checked

| Dead End | Relevance to D Construction |
|----------|----------------------------|
| Single-Family BFMCS modal_backward | HIGH: confirms multi-family is essential. D must support multi-family modal saturation. |
| Constant Witness Family | MEDIUM: confirms families must be time-varying. D must allow non-constant time indexing. |
| CanonicalReachable/CanonicalQuotient | HIGH: one-directional fragments fail for backward_P. D domain must be bidirectional. |
| Non-Standard Validity | HIGH: completeness must use standard validity, so D must integrate with standard TaskFrame/WorldHistory. |

---

## Confidence Level

**MEDIUM-HIGH** with justification:

- HIGH confidence in the orthogonality finding (modal vs temporal dimensions). The code is explicit and unambiguous.
- HIGH confidence that the history dimension does not constrain D construction.
- MEDIUM confidence in risk assessments for TranslationGroup blockers (Holder's theorem, homogeneity). These depend on mathematical properties of the BidirectionalQuotient that have not been fully explored.
- MEDIUM confidence in the shift-closure concern. This is a genuine issue if D != Int, but it may have a resolution via enlarged Omega construction (as done in shiftClosedCanonicalOmega for D = Int).

---

## Recommendations

### Critical Issues to Address

1. **Shift-closure compatibility**: If D is changed from Int to TranslationGroup (or any other syntactic construction), the shift-closed Omega construction must be revisited. The current `shiftClosedCanonicalOmega` constructs time-shifted histories as `time_shift (canonicalHistory fam) delta` for `delta : Int`. If D changes, this construction changes fundamentally. **Recommendation**: Verify that the time-shift-preserves-truth theorem works with the new D before committing to the TranslationGroup approach.

2. **The trivial task relation is both a feature and a risk**: Using `task_rel = True` means D's algebraic structure is never exercised in the canonical model. This is a feature (flexibility) but also a risk (the algebraic requirements could be unnecessary or impossible to satisfy from syntax). **Recommendation**: Investigate whether a weaker TaskFrame definition (without AddCommGroup) suffices for the completeness theorem.

3. **The density blocker is temporal, not bimodal**: The 4 sorries in DenseQuotient.lean are purely about the temporal order structure. The modal dimension plays no role and provides no additional leverage. **Recommendation**: Focus density efforts on the temporal structure alone; do not expect modal axioms to help.

4. **Consider K-Relational approach from research-020**: The recommendation from research-020 Section 10 to prove completeness for relational frames FIRST, then obtain TaskFrame via representation, aligns well with the bimodal structure analysis. The modal dimension works identically in both settings (Box quantifies over histories/families). Only the temporal dimension needs restructuring.

5. **The bimodal structure simplifies D construction**: Since D operates only in the temporal dimension, the D construction can be analyzed purely in terms of tense logic (G, H, F, P, CanonicalR, temp_4, temp_a, temp_linearity). The modal axioms (MT, MB, M4, MK, M5-collapse) and interaction axioms (MF, TF) are relevant only for the histories/Omega construction, not for D itself. **Recommendation**: Decouple the D construction analysis from the modal completeness analysis.
