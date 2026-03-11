# Research Report: Archimedean Axiom, Parametric Base Completeness, and Extensible Architecture

**Task**: 956 -- Construct D as translation group from syntax
**Report**: research-014
**Date**: 2026-03-09
**Session**: sess_1773190000_d5e6f7
**Status**: Findings ready for planning
**Effort**: Medium (mathematical analysis + codebase + literature review)
**Dependencies**: research-012, research-013
**Sources/Inputs**: Codebase (Validity.lean, Soundness.lean, Axioms.lean, Derivation.lean, CanonicalCompleteness.lean, FragmentCompleteness.lean, BidirectionalReachable.lean), Web research (SEP Temporal Logic, Wikipedia Archimedean property, Chicago REU compactness paper), prior reports (research-012, research-013)
**Artifacts**: This report
**Standards**: report-format.md, return-metadata-file.md

---

## 1. Executive Summary

- **Q1 (Archimedean Axiom)**: The Archimedean property is **not first-order definable** in the language of ordered groups, hence **not expressible as a temporal modal axiom schema**. This is a fundamental result from model theory (compactness argument). No modal axiom or finite set of modal axioms can force Archimedeanness. However, Archimedeanness is not needed for the density path (Q), and for the discrete path (Z), it follows from the construction rather than from an axiom.

- **Q2 (Parametric Base Completeness)**: TM is complete for validity over ALL reflexive transitive linear orders, which is exactly what the parametric `valid` definition quantifies over. The canonical model construction produces SOME ordered abelian group D -- the BidirectionalFragment/Quotient -- and completeness follows regardless of what D turns out to be. The existing sorry at `fragmentChainFMCS_forward_F` is the specific obstacle: the Int-indexed chain may miss fragment witnesses.

- **Q3 (Extensible Architecture)**: Yes, the base completeness proof can be structured for clean extension. The key insight: work at the **fragment level** (BidirectionalFragment/Quotient) rather than at the Int-chain level. The fragment is already sorry-free for forward_F/backward_P. Adding DN or DF adds properties (DenselyOrdered or SuccOrder) to the fragment quotient. The concrete isomorphism (to Q or Z) then provides the specific D.

---

## 2. Q1: Can an Archimedean Axiom Be Added to TM?

### 2.1 The Archimedean Property Is Not First-Order Definable

**Theorem (standard model theory)**: The Archimedean property for ordered groups (or ordered fields) is NOT expressible in first-order logic.

**Proof via compactness**: Let T be the first-order theory of ordered abelian groups. Add a constant symbol c and the axiom set Sigma = T union {0 < c} union {c < 1, c < 1+1, c < 1+1+1, ...} (i.e., "c is positive but less than every natural number"). Every finite subset of Sigma is satisfiable (take any Archimedean group and interpret c as something sufficiently small). By the Compactness Theorem, Sigma itself has a model -- which is a non-Archimedean ordered abelian group satisfying T. Therefore no first-order theory can exclude non-Archimedean models.

**Reference**: This argument appears in [Call, "The Compactness Theorem and Applications"](https://math.uchicago.edu/~may/REU2013/REUPapers/Call.pdf) and is standard material in any model theory textbook (see Chang & Keisler, or Marker's *Model Theory: An Introduction*).

### 2.2 What About a Modal Axiom Schema?

Modal temporal axiom schemata are translated to first-order frame conditions via the Sahlqvist correspondence or related results. Since:

1. Each modal/temporal axiom schema corresponds to a first-order frame condition (for Sahlqvist formulas), or to a second-order condition (for non-Sahlqvist formulas).
2. The Archimedean property is not first-order definable.
3. Modal axiom schemata that are Sahlqvist (which includes all TM axioms: T, 4, B, K, linearity, density, discreteness) correspond to first-order conditions.

It follows that the Archimedean property **cannot be captured by any Sahlqvist axiom schema**. Whether there exists a non-Sahlqvist temporal formula whose frame condition exactly characterizes Archimedeanness is more subtle, but the answer is effectively negative for practical purposes:

- **Goldblatt-Thomason theorem**: A first-order definable class of frames is modally definable iff it is closed under generated subframes, disjoint unions, bounded morphisms, and reflects ultrafilter extensions. The Archimedean frames do not form a first-order definable class, so this theorem does not directly apply.
- **Second-order character**: Archimedeanness is inherently second-order (quantifying over natural numbers). No finite set of propositional modal formulas can capture a second-order property.

**Bottom line**: There is no temporal axiom or axiom schema that can be added to TM to force D to be Archimedean.

### 2.3 But Archimedeanness Is Not Needed

This negative result does not block the layered architecture because:

1. **Density path (D = Q)**: Archimedeanness is NOT needed. Cantor's theorem (`Order.iso_of_countable_dense`) requires only countability + density + no endpoints. Q happens to be Archimedean, but this fact is not used in the proof.

2. **Discrete path (D = Z)**: Archimedeanness IS needed to apply `orderIsoIntOfLinearSuccPredArch`. But Archimedeanness follows from the **canonical model construction** (the BidirectionalFragment is countable and each element is reached in finitely many CanonicalR steps from the root), NOT from an axiom. It is a property of the SPECIFIC model built, not a property forced on ALL models.

3. **Parametric base (all D)**: Archimedeanness is irrelevant. TM is complete for ALL linear orders, Archimedean or not.

### 2.4 Pros and Cons of a Hypothetical Archimedean Axiom

Even though no single axiom can force Archimedeanness, one could consider an **infinite axiom schema** or **rule**:

| Approach | Pros | Cons |
|----------|------|------|
| Infinite axiom schema: for each n, add "F^n(bot) -> bot" variants | Would exclude some non-Archimedean models | Infinitely many axioms; non-standard proof system; changes the logic fundamentally |
| Second-order axiom | Precisely captures Archimedeanness | Not expressible in the propositional temporal language; requires quantification over formulas or natural numbers |
| Induction rule (omega-rule) | Standard in some proof theory | Not finitary; incompatible with standard completeness proofs |

**Recommendation**: Do NOT pursue an Archimedean axiom. Archimedeanness is a property of the canonical model construction, not of the logic. The layered architecture handles this correctly: density forces Q (Archimedean by construction), discreteness forces Z (Archimedean by construction), and the base layer is parametric.

---

## 3. Q2: Parametric Base Completeness

### 3.1 What the Codebase Currently Has

The existing `valid` definition in `Validity.lean` (lines 71-75):

```lean
def valid (phi : Formula) : Prop :=
  forall (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    (F : TaskFrame D) (M : TaskModel F)
    (Omega : Set (WorldHistory F)) (h_sc : ShiftClosed Omega)
    (tau : WorldHistory F) (h_mem : tau in Omega) (t : D),
    truth_at M Omega tau t phi
```

This quantifies over ALL D with the required algebraic structure. Soundness is proven against this definition (Soundness.lean, sorry-free, 344 lines).

### 3.2 Is TM Already Complete for Parametric Validity?

**Yes, in principle.** The representation theorem for TM states:

> **TM completeness**: phi is a theorem of TM if and only if phi is valid on all reflexive, transitive, linear frames (with or without endpoints, with arbitrary D).

This is the established result from Burgess (1982), later refined by Xu (1988) and Venema (1993). The class of frames is exactly "all reflexive transitive linear orders without endpoints" -- which matches what TM axioms (T, 4, linearity) force. The base logic (without DN or DF) is complete for this entire class.

The parametric validity `valid phi` quantifies over all D satisfying `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]`. Every such D gives a reflexive transitive linear order (via its own ordering), so `valid phi` is equivalent to "phi is valid on all reflexive transitive linear frames with ordered abelian group D."

### 3.3 How the Canonical Model Construction Works Parametrically

The canonical model construction does NOT need to produce a specific D. The construction works as follows:

1. **Start with a consistent formula phi** (i.e., TM does not prove neg(phi)).
2. **Extend {phi} to an MCS M_0** using Lindenbaum's lemma.
3. **Build the BidirectionalFragment from M_0**: This produces a preorder on MCSes, sorry-free for forward_F and backward_P at the fragment level.
4. **Take the Antisymmetrization**: This gives `BidirectionalQuotient M_0 h_mcs0`, a linear order (proven sorry-free in the codebase).
5. **The quotient IS the temporal domain**: The quotient has `NoMinOrder`, `NoMaxOrder`, `LinearOrder`.

At this point, the canonical model EXISTS with temporal domain T = BidirectionalQuotient. The truth lemma can be proven at this level. The question "what is D?" does not arise at the parametric level -- D can be anything, and the canonical model provides one specific linear order T.

### 3.4 The Gap: Fragment-to-Int Conversion

The current obstacle is in `FragmentCompleteness.lean` (lines 460-461, 471):

```lean
theorem fragmentChainFMCS_forward_F ... := by sorry
theorem fragmentChainFMCS_backward_P ... := by sorry
```

These sorries arise from the **Int-chain construction**: the attempt to convert the fragment-level FMCS (which is sorry-free) to an `FMCS Int`. The problem is documented in the file (lines 511-540): the chain may "jump past" a fragment witness, causing F-persistence to fail.

**Key insight**: This obstacle is an artifact of requiring D = Int (i.e., D = Z). If we work at the fragment level (or quotient level), these sorries do not exist. The fragment FMCS has sorry-free forward_F, backward_P, forward_G, backward_H (lines 73-113 of CanonicalCompleteness.lean).

### 3.5 Parametric Completeness Architecture

The correct architecture for parametric completeness is:

```
Level 1: Fragment FMCS (sorry-free)
  - Domain: BidirectionalFragment M_0 h_mcs0
  - forward_F, backward_P: sorry-free (from fragment closure)
  - forward_G, backward_H: sorry-free (from CanonicalR)

Level 2: Quotient FMCS
  - Domain: BidirectionalQuotient M_0 h_mcs0 (Antisymmetrization)
  - LinearOrder: sorry-free
  - NoMinOrder, NoMaxOrder: provable from mcs_has_F_top/mcs_has_P_top

Level 3: Validity
  - D = T (the quotient is both the temporal domain and the duration group)
  - AddTorsor D T: D acts on itself by addition (addGroupIsAddTorsor)
  - TaskFrame D: constructed from the quotient with its order structure
```

At Level 2, D is the quotient itself. This is a valid choice because:
- It is a linear order (proven)
- It has no min/max (provable)
- It can be given a group structure (but this requires more work -- see Section 5)

### 3.6 The Group Structure Issue

The gap in the parametric approach is: the BidirectionalQuotient is a LinearOrder, but it is NOT automatically an AddCommGroup. Making it into one requires:

1. **Choosing a base point**: Pick the equivalence class of M_0 as "zero"
2. **Defining addition**: This is non-trivial. The quotient has no natural group operation from the canonical model construction alone.

This is precisely why the concrete instantiation (D = Z or D = Q) matters: we use the isomorphism T ≃o Z or T ≃o Q to TRANSFER the group structure from Z or Q to T, rather than constructing it on T directly.

**However, for COMPLETENESS (not for the representation theorem)**, the group structure is NOT needed. Completeness says: if phi is valid on all task frames (with arbitrary D), then TM proves phi. The contrapositive: if TM does not prove phi, then there exists SOME task frame falsifying phi. The canonical model provides the falsifying frame -- but we need it to be a TaskFrame, which requires D and AddTorsor D T.

### 3.7 Resolution: Two Statements of Completeness

There are two distinct completeness statements:

**Frame completeness (achievable parametrically)**:
> phi is a theorem of TM iff phi is valid on all reflexive, transitive, linear frames without endpoints.

This does NOT require D or AddTorsor. The canonical model provides a falsifying frame (a linear order with a valuation). This is the standard completeness result from the literature.

**Task-semantic completeness (requires concrete D)**:
> phi is a theorem of TM iff valid phi (where valid quantifies over TaskFrame D with AddTorsor D T, ShiftClosed Omega, etc.)

This requires building a TaskFrame, which requires D and the torsor structure. For this, a concrete D is needed.

**Bridge between the two**: Task-semantic validity implies frame validity (every TaskFrame gives a linear frame). The converse requires showing that every linear frame can be equipped with a TaskFrame structure, which requires finding a suitable D. This is possible for any countable linear order without endpoints, using Morel's classification and the layered approach from research-013.

### 3.8 Answer to Q2

**Yes, TM is complete for parametric validity, but with a nuance**:

1. **Frame completeness** (phi valid on all reflexive transitive linear orders iff TM proves phi) is achievable parametrically. The canonical model provides the falsifying linear order. No specific D is needed.

2. **Task-semantic completeness** (valid phi iff TM proves phi, where valid uses TaskFrame/AddTorsor) requires a BRIDGE showing that linear frames can be enhanced with TaskFrame structure. This bridge requires choosing a concrete D for the canonical model.

3. The codebase uses task-semantic validity (with D and TaskFrame). So completeness requires producing a TaskFrame, which means eventually choosing D. But the CORE of the proof (MCS construction, truth lemma, fragment coherence) is parametric.

4. The existing fragment-level infrastructure (CanonicalCompleteness.lean) is sorry-free and provides the parametric core. The sorries are all in the Int-chain conversion.

---

## 4. Q3: Extensible Architecture

### 4.1 The Fragment-First Architecture

The key architectural insight is: **work at the fragment/quotient level first, then specialize**.

```
                      Fragment Level (sorry-free)
                     /          |         \
                    /           |          \
               No axiom      Add DN      Add DF
               (base TM)     (density)   (discrete)
                  |             |            |
            Quotient T     Quotient T    Quotient T
            (linear)     (linear+dense) (linear+succ/pred)
                  |             |            |
              abstract D    T ≃o Q        T ≃o Z
              (frame        D = Q         D = Z
              completeness)
```

### 4.2 What Changes When DN Is Added

When the density axiom DN: `Fp -> FFp` is added to TM:

1. **Proof system**: Add `Axiom.density (phi : Formula) : Axiom (Formula.some_future phi |>.imp (Formula.some_future (Formula.some_future phi)))` to Axioms.lean.

2. **Soundness**: Prove DN is sound for `valid_dense` (validity restricted to DenselyOrdered D). This is straightforward: in a dense frame, if t < s then exists u with t < u < s.

3. **Canonical model**: The BidirectionalQuotient inherits DenselyOrdered from DN. **Proof sketch**: If q1 < q2 in the quotient, there exist representatives w1, w2 with CanonicalR w1 w2 and not CanonicalR w2 w1. From the FMCS, there exists phi with F(phi) in w1 and phi in w2. By DN, FF(phi) in w1, meaning F(F(phi)) in w1. By forward_F, there exists an intermediate w3 with F(phi) in w3 and w1 <= w3. Since F(phi) in w3, there exists w4 >= w3 with phi in w4. The key is showing w3 is strictly between w1 and w2 in the quotient.

4. **Isomorphism**: Once DenselyOrdered is proven on the countable quotient (which has NoMinOrder, NoMaxOrder), Cantor's theorem gives T ≃o Q.

5. **D = Q**: Set D = Q, transfer AddTorsor via the isomorphism, and the TaskFrame is constructed.

### 4.3 What Changes When DF Is Added

When the discreteness axiom DF: `(F top & phi & H phi) -> FH phi` is added:

1. **Proof system**: Add DF to Axioms.lean. DP is derived via temporal_duality (see research-013 Section 3.3).

2. **Soundness**: Prove DF sound for `valid_discrete` (validity restricted to SuccOrder D).

3. **Canonical model**: The BidirectionalQuotient gets SuccOrder from DF (and PredOrder from DP). Archimedeanness (IsSuccArchimedean) follows from the countable construction.

4. **Isomorphism**: `orderIsoIntOfLinearSuccPredArch` gives T ≃o Z.

5. **D = Z**: Set D = Z, transfer AddTorsor, construct TaskFrame.

### 4.4 The Core Completeness Lemma

The "core completeness lemma" shared by all three layers is:

```
lemma core_completeness :
  TM-consistent phi ->
  exists (T : Type) (inst_lo : LinearOrder T)
    (inst_no_min : NoMinOrder T) (inst_no_max : NoMaxOrder T)
    (fmcs : FMCS T),
    fmcs.mcs 0 contains phi
    AND fmcs has forward_F, backward_P, forward_G, backward_H
    AND (truth_lemma: phi in fmcs.mcs t iff phi is true at t in the canonical model)
```

This lemma is the parametric base. It says: every consistent formula has a model on SOME linear order T.

**Layer 0 (TM)**: The core lemma gives a model on an abstract T. Frame completeness follows.

**Layer 1 (TM + DN)**: The same core lemma, PLUS the canonical model construction proves DenselyOrdered T from DN. Cantor's theorem gives T ≃o Q, and D = Q follows.

**Layer 2 (TM + DF)**: The same core lemma, PLUS the construction proves SuccOrder + PredOrder + IsSuccArchimedean T from DF. The Z-isomorphism gives D = Z.

### 4.5 What "Extends Naturally" Means

The extension is clean because:

1. **The core lemma does not change**: The fragment-level FMCS construction, truth lemma, and modal saturation are the same for all three layers. No code is duplicated.

2. **DN/DF add properties to the quotient**: These are ADDITIONAL theorems about the same quotient, not modifications of existing proofs.

3. **The isomorphism is a SEPARATE step**: Once DenselyOrdered or SuccOrder is proven, the isomorphism application is independent of the completeness proof.

4. **TaskFrame construction is uniform**: Given D, T, and AddTorsor D T, building the TaskFrame follows the same pattern for both Q and Z.

### 4.6 Concrete Architecture in Lean

```lean
-- Base layer: parametric
-- In a new file: Theories/Bimodal/Metalogic/Representation/Core.lean
theorem core_representation (phi : Formula) (h_cons : SetConsistent {phi}) :
    exists (T : Type) (_ : LinearOrder T) (_ : NoMinOrder T) (_ : NoMaxOrder T)
      (V : T -> String -> Prop),
      -- phi is satisfied at time 0 in this frame
      sorry -- THE core theorem, NO D needed

-- Dense layer: extends core
-- In: Theories/Bimodal/Metalogic/Representation/Dense.lean
theorem dense_representation (phi : Formula)
    (h_cons : SetConsistent_in_TM_plus_DN {phi}) :
    exists (V : Q -> String -> Prop),
      -- phi is satisfied at time 0 in a Q-indexed model
      sorry -- Uses core_representation + DenselyOrdered proof + Cantor

-- Discrete layer: extends core
-- In: Theories/Bimodal/Metalogic/Representation/Discrete.lean
theorem discrete_representation (phi : Formula)
    (h_cons : SetConsistent_in_TM_plus_DF {phi}) :
    exists (V : Z -> String -> Prop),
      -- phi is satisfied at time 0 in a Z-indexed model
      sorry -- Uses core_representation + SuccOrder proof + Z-iso
```

---

## 5. Relationship Between Frame Completeness and Task-Semantic Completeness

### 5.1 The Semantic Gap

The codebase defines `valid` with TaskFrame (requiring D, AddCommGroup, etc.), but the core completeness theorem is for LINEAR FRAMES (requiring only LinearOrder on T). The gap is:

| Concept | Frame Completeness | Task-Semantic Completeness |
|---------|-------------------|--------------------------|
| Domain | T : LinearOrder | T with AddTorsor D T |
| Group | Not needed | D : OrderedAddCommGroup |
| Validity | For all linear T | For all D and TaskFrame D |
| Canonical model | BidirectionalQuotient | BidirectionalQuotient + D |
| What's proven | phi true in linear model | phi true in TaskFrame model |

### 5.2 Bridging the Gap

To bridge from frame completeness to task-semantic completeness:

**Direction 1** (soundness direction, already proven): Every TaskFrame gives a linear frame. So task-semantic validity implies frame validity.

**Direction 2** (completeness direction, the gap): Every linear frame (without endpoints) can be equipped with TaskFrame structure. This requires:
- Choosing D such that T is an AddTorsor over D
- For T = Q: D = Q, torsor structure from addGroupIsAddTorsor
- For T = Z: D = Z, torsor structure from addGroupIsAddTorsor
- For abstract T: Need T to admit a free transitive abelian group action, which requires T to have a specific order type (see Morel's classification, research-011)

**Direction 2 is exactly where DN/DF help**: They force T into an order type (Q or Z) that admits a natural group structure.

### 5.3 Implication for the Parametric Approach

For the base layer (no DN/DF), task-semantic completeness is MORE than frame completeness:

- Frame completeness says: if phi is not provable, there exists a linear frame falsifying phi.
- Task-semantic completeness says: if phi is not provable, there exists a TaskFrame (with D) falsifying phi.

For frame completeness to imply task-semantic completeness, we need: "every linear frame without endpoints can be enhanced with a TaskFrame structure." This is TRUE for countable linear orders (which the canonical model always is), because countable linear orders without endpoints are classified by Morel's theorem, and each type either:
- Is Q (admits D = Q), or
- Is Z (admits D = Z), or
- Is some product (may not admit D as an ordered abelian group -- this is the non-Archimedean gap)

For the third case, we can always EXTEND the model: add DN or DF as an axiom to TM, and the resulting canonical model has D = Q or D = Z. But this changes the logic.

**Pragmatic resolution**: Prove frame completeness first (parametric, no D). Then prove the bridge for dense and discrete cases separately. This gives task-semantic completeness for TM + DN and TM + DF, which covers all practical use cases.

---

## 6. ROAD_MAP.md Reflection

### Pitfalls Checked

| Dead End | Relevance | Impact on Recommendations |
|----------|-----------|--------------------------|
| CanonicalReachable/CanonicalQuotient | HIGH | BidirectionalFragment replaces this; fragment-first architecture uses the bidirectional approach |
| Single-Family BFMCS modal_backward | Low | Multi-family approach is orthogonal to parametric D question |
| Non-Standard Validity Completeness | MEDIUM | The distinction between frame completeness and task-semantic completeness is exactly the gap this dead end exposed. Must use standard validity. |
| Constant Witness Family | Low | Resolved by dovetailing chain; not relevant to parametric D |

### Strategy Alignment

| Strategy | Status | Relevance |
|----------|--------|-----------|
| Indexed MCS Family | ACTIVE | Compatible: fmcs works parametrically over any index type |
| Representation-First | CONCLUDED | The "representation theorem" = frame completeness + D-construction. Layered approach decomposes this cleanly. |
| Algebraic Verification | PAUSED | Orthogonal: algebraic completeness gives frame completeness but not D-construction |

### Key Insight

The F-persistence obstacle (sorry at `fragmentChainFMCS_forward_F`) is specifically a problem of converting BidirectionalFragment-indexed FMCS to Int-indexed FMCS. If we work at the fragment/quotient level and prove completeness THERE first, the sorry disappears. The Int-chain conversion is only needed for the D = Z instantiation (discrete path).

For the density path (D = Q), the fragment quotient is directly isomorphic to Q via Cantor's theorem, and the Int-chain construction is BYPASSED entirely.

---

## 7. Context Extension Recommendations

### Discovered Concepts Requiring Documentation

| Concept | Report Section | Currently Documented? | Gap Type |
|---------|----------------|----------------------|----------|
| Archimedeanness is not first-order definable | Section 2.1 | No | extension |
| Frame completeness vs task-semantic completeness | Section 5 | No | new_file |
| Fragment-first architecture (avoiding Int-chain) | Section 4 | No | extension |
| Core completeness lemma (shared across layers) | Section 4.4 | No | extension |

### New Context File Recommendations

| Filename | Directory | Content Scope | Priority | Create Task? |
|----------|-----------|---------------|----------|--------------|
| `completeness-architecture.md` | `domain/` | Frame completeness vs task-semantic completeness, fragment-first approach, layered extension pattern | High | No |

### Existing Context File Extensions

| File | Section to Add/Modify | Content to Add | Priority | Create Task? |
|------|----------------------|----------------|----------|--------------|
| `metalogic-concepts.md` | Completeness | Frame completeness vs task-semantic completeness distinction | Medium | No |
| `kripke-semantics-overview.md` | Temporal Frame Properties | Archimedeanness: not first-order, not modal, follows from construction | Medium | No |

### Summary

- **New files needed**: 1
- **Extensions needed**: 2
- **Tasks to create**: 0
- **High priority gaps**: 1

---

## 8. Decisions

1. **Do NOT pursue an Archimedean axiom.** Archimedeanness is a model-construction property, not a logical axiom. It is not first-order definable, hence not expressible as a temporal axiom schema.

2. **TM IS complete for parametric validity (frame completeness).** The canonical model provides an abstract linear order. The existing fragment-level infrastructure is sorry-free.

3. **Task-semantic completeness requires concrete D**, but this is a SEPARATE step from the core completeness proof. The bridge is provided by DN (forcing Q) or DF (forcing Z).

4. **The fragment-first architecture enables clean extension.** The core completeness lemma works at the fragment/quotient level. DN adds DenselyOrdered, DF adds SuccOrder/PredOrder. Each extension adds theorems about the same quotient, not new constructions.

5. **The Int-chain obstacle is BYPASSED by the density path.** The fragment quotient is directly isomorphic to Q, eliminating the need for the `buildFragmentChain` construction.

6. **Frame completeness should be proven first, then the bridge to task-semantic completeness.** This separates concerns: the core proof is parametric, and the D-construction is a separate module.

---

## 9. Risks and Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Fragment-quotient approach requires new BFMCS infrastructure | Medium | Medium | Much of the infrastructure exists (CanonicalCompleteness.lean has fragment FMCS sorry-free) |
| DenselyOrdered proof on quotient from DN | Low-Medium | Medium | Proof sketch in research-012 Section 3.3 is clear; builds on existing infrastructure |
| Truth lemma at the quotient level (not Int level) | Medium | High | Need to refactor truth_at to accept non-Int domains, or prove truth lemma at fragment level and transfer |
| The "bridge" from frame completeness to task-semantic completeness | Medium | Medium | Well-understood for Q and Z; non-Archimedean case is deferred |
| Quotient group structure construction | Medium | Low | Use isomorphism to Q or Z to transfer group structure; avoid constructing group on quotient directly |

---

## 10. Appendix

### Search Queries Used

1. "Archimedean property temporal logic modal axiom expressible first-order definable ordered group"
2. "temporal logic completeness parametric duration group base layer extension dense discrete axiom"
3. "Archimedean property not first-order compactness argument ordered field group"
4. "temporal logic completeness linear order Kt.3 Burgess axiomatization density discreteness extension"

### Web Sources

- [Temporal Logic -- Stanford Encyclopedia of Philosophy](https://plato.stanford.edu/entries/logic-temporal/) -- Axiomatizations for Z, Q, R; base logic Lt
- [The Compactness Theorem and Applications (Call, UChicago REU)](https://math.uchicago.edu/~may/REU2013/REUPapers/Call.pdf) -- Archimedean property not first-order definable
- [Archimedean group -- Wikipedia](https://en.wikipedia.org/wiki/Archimedean_group) -- Holder's theorem, classification
- [Completeness of Ordered Fields (arxiv 1101.5652)](https://arxiv.org/pdf/1101.5652) -- Second-order characterization
- [Venema, "Temporal Logic" (Chapter 10, Handbook of Philosophical Logic)](https://staff.science.uva.nl/y.venema/papers/TempLog.pdf) -- Completeness proofs for temporal logics

### Codebase Files Examined

- `Theories/Bimodal/Semantics/Validity.lean` -- Parametric validity definition (lines 71-75)
- `Theories/Bimodal/Metalogic/Soundness.lean` -- Sorry-free soundness (344 lines)
- `Theories/Bimodal/ProofSystem/Axioms.lean` -- 18 axiom constructors, no DN/DF
- `Theories/Bimodal/ProofSystem/Derivation.lean` -- temporal_duality rule (line 136)
- `Theories/Bimodal/Metalogic/Bundle/CanonicalCompleteness.lean` -- Fragment FMCS (sorry-free forward_F/backward_P)
- `Theories/Bimodal/Metalogic/Bundle/FragmentCompleteness.lean` -- Int-chain construction (2 sorries at forward_F/backward_P)
- `Theories/Bimodal/Metalogic/Bundle/BidirectionalReachable.lean` -- Fragment infrastructure
- `Theories/Bimodal/Metalogic/Completeness.lean` -- MCS properties, modal closure

### Prior Research Reports

- research-012: Density path rehabilitation, D = Q construction, Holder's theorem bypass
- research-013: Layered architecture, Archimedean dichotomy, parametric validity analysis

### References

- Burgess, J.P. (1982). "Axioms for tense logic I." Notre Dame J. Formal Logic.
- Goldblatt, R. (1992). Logics of Time and Computation. CSLI Publications.
- Venema, Y. "Temporal Logic." Chapter 10 in Handbook of Philosophical Logic.
- Chang, C.C. and Keisler, H.J. (1973). Model Theory. North-Holland.
- Marker, D. (2002). Model Theory: An Introduction. Springer.
- Goldblatt-Thomason theorem: characterization of modally definable frame classes.
- Sahlqvist correspondence: modal axioms with first-order frame conditions.
- Morel's classification: countable linear orders without endpoints.
- Cantor's theorem: countable dense unbounded linear orders are unique (up to isomorphism).

---

## 11. Artifacts

- **This report**: `specs/956_construct_d_as_translation_group_from_syntax/reports/research-014.md`
- **Key referenced files**:
  - `Theories/Bimodal/Semantics/Validity.lean` -- Parametric validity
  - `Theories/Bimodal/Metalogic/Bundle/CanonicalCompleteness.lean` -- Sorry-free fragment FMCS
  - `Theories/Bimodal/Metalogic/Bundle/FragmentCompleteness.lean` -- Int-chain (2 sorries)
  - `Theories/Bimodal/ProofSystem/Axioms.lean` -- Current axiom system

---

## 12. Next Steps

1. **Decision**: Accept fragment-first architecture; prove frame completeness parametrically before task-semantic completeness.
2. **Priority 1**: Prove truth lemma at the fragment/quotient level (avoiding Int-chain).
3. **Priority 2**: Add DN axiom; prove DenselyOrdered on quotient from DN.
4. **Priority 3**: Apply Cantor's theorem; set D = Q; bridge to task-semantic completeness.
5. **Deferred**: DF axiom + discrete path (DP derived via temporal_duality).
6. **Do NOT add**: Archimedean axiom (not expressible in temporal logic).
