# Teammate D (Horizons): Three Completeness Results Architecture

- **Task**: 117 - Remove Cantor isomorphism and build countermodel on limit domain
- **Focus**: Long-term architecture, strategic direction, three completeness results
- **Date**: 2026-05-09

---

## Q1: Three Completeness Results Architecture

### The Three Results

1. **Base**: BX + uniformity axioms -> complete for all AddCommGroup models (case split: Q or Z)
2. **Dense**: BX + uniformity + F'T + P'T -> complete for dense models (Q only)
3. **Discrete**: BX + uniformity + G'bot + H'bot -> complete for discrete models (Z only)

### Recommended Architecture: Option (c) -- Master Theorem with Corollaries

After studying Burgess 1982 Section 1.6 and the existing codebase structure, **option (c) is cleanest**.

**Rationale**:

1. **Burgess 1982 Section 1.6 says it directly**: "By adding extra axioms to J_0 we can get sound and complete axiomatizations for the S,U-tense logics of various subclasses of K_0." The variants are NOT independent theorems -- they are extensions of one construction. Burgess's proof literally uses the SAME construction with different axiom sets.

2. **The codebase already has the infrastructure for this**: The `Axiom` inductive, `FrameClass`, `isDenseCompatible`, `isDiscreteCompatible` classify axioms. The `valid_dense`, `valid_discrete` notions already exist in Soundness.lean. The parametric infrastructure (`ParametricCanonicalTaskModel D`) already abstracts over the carrier type D.

3. **The base case IS the master theorem**: The current plan's case-split (`F'T vs U(T,bot)`) already subsumes both dense and discrete. The base completeness theorem says "for any non-derivable phi, a countermodel exists over some AddCommGroup." The corollaries specialize:
   - Dense corollary: "if phi is non-derivable in BX + F'T + P'T, countermodel exists over Q"
   - Discrete corollary: "if phi is non-derivable in BX + G'bot + H'bot, countermodel exists over Z"

**Proposed file organization**:

```
Metalogic/BXCanonical/
  Completeness.lean           -- bx_completeness (master, case split)
  DenseCompleteness.lean      -- bx_dense_completeness (corollary: D = Rat)
  DiscreteCompleteness.lean   -- bx_discrete_completeness (corollary: D = Int)
  Chronicle/
    ChronicleToCountermodel.lean  -- dd_countermodel_chronicle_{dense,discrete}
```

The dense and discrete corollaries are 10-20 line files that:
1. Assume the extended axiom set (F'T or G'bot+H'bot)
2. Invoke the appropriate branch of the master case-split
3. Specialize the carrier type (Rat or Int)

This is cleanest for future extension because adding a new variant (e.g., first/last element) means:
- Adding axioms to the `Axiom` inductive
- Adding a soundness proof
- Adding a new branch in the chronicle case-split (or composing existing branches)
- Writing a new corollary file

### Why Not Options (a) or (b)

**Option (a) -- three separate theorems**: Would duplicate the shared chronicle infrastructure (Lindenbaum, MCS extension, chronicle conditions C0-C5). The construction is 95% identical across all three cases -- only the final countermodel carrier type differs.

**Option (b) -- one generic theorem with type-class parameters**: Premature generalization. The Q and Z cases have fundamentally different proofs (Cantor iso vs. Z-iso). Parameterizing over a type class that captures "is either Q or Z" would be artificial. The master theorem with corollaries achieves the same generality without forcing an artificial type-class hierarchy.

---

## Q2: Burgess's Approach to Variants

### How Faithfully Can We Reproduce Burgess?

**Very faithfully, with one important caveat.**

Burgess says variants are "routine exercises" because his construction has these properties:

1. **C0-C5 are axiom-agnostic**: The chronicle conditions (C0: MCS assignment, C1: DCS interval sets, C2/C2': R-relation, C3: interval consistency, C4/C5: counterexample elimination) work for ANY axiom system extending J_0. The proofs of Lemmas 2.4-2.10 use only J_0 axioms (A1-A7).

2. **The density/discreteness axioms only affect the FINAL MODEL**: Burgess adds F'T to get density and G'bot+H'bot to get discreteness. These axioms determine what kind of linear order X turns out to be, but the chronicle CONSTRUCTION is identical.

3. **The truth lemma (Claim 2.11) works for ANY linear order**: Burgess explicitly states "(+) holds for all alpha" without assuming density, discreteness, or any group structure. The truth lemma is a theorem about linear orders satisfying C0-C5.

**The caveat**: The codebase requires `AddCommGroup D` in the `valid` definition. Burgess doesn't need this -- his models are arbitrary linear orders. The AddCommGroup requirement comes from the `TaskFrame`/`ShiftClosed` infrastructure, which needs time-shift invariance for the modal semantics. This means the codebase CANNOT directly reproduce Burgess's construction: instead of building a model on X (an arbitrary countable linear order), it must embed X into a concrete AddCommGroup (Q or Z).

### Could We Have ONE Parameterized Construction?

**Yes, for the chronicle. No, for the countermodel embedding.**

The chronicle construction (ChronicleConstruction.lean) is ALREADY parameterized: it takes an MCS A and produces `limit_dom`, `limit_f`, `limit_g` satisfying C0-C5. This is shared by all variants.

The countermodel embedding (ChronicleToCountermodel.lean) CANNOT be unified because Q and Z require fundamentally different order isomorphisms:
- Dense: `LimitDomSubtype ≃o Q` via Cantor's theorem (countable dense linear order without endpoints)
- Discrete: `LimitDomSubtype ≃o Z` via `orderIsoIntOfLinearSuccPredArch` (successor/predecessor Archimedean)

A reasonable factoring: extract the shared parts of the BFMCS construction (shifted/rooted FMCS, box stability) into a helper module, then specialize the order iso in each case. The current plan already does this implicitly -- Phases 5 and 6 have parallel structure.

---

## Q3: Future Extensions

### Extensions Burgess Covers

Burgess Section 1.6 lists these additional variants:

| Postulates on < | Axioms for S, U |
|-----------------|-----------------|
| First Element   | FPHbot          |
| Last Element    | PFGbot          |
| No First Element | Ptop           |
| No Last Element  | Ftop           |

The "No First/Last Element" axioms are already subsumed by the seriality axioms (`serial_future`: T -> F(T), `serial_past`: T -> P(T)), which are in the current BX system. So the codebase already handles the "no endpoints" case.

The "First Element" and "Last Element" variants would require:
1. New axiom constructors in `Axiom`
2. Soundness proofs (straightforward)
3. Removing seriality from the relevant extended system
4. A new chronicle case where X has min/max elements

### Possible Combinations

Burgess states results for:
- All linear orders (base J_0) -- CURRENT TARGET
- Dense orders (J_0 + F'T)
- Discrete orders (J_0 + G'bot + H'bot)
- Any combination with first/last element axioms

This gives a matrix of 3 x 4 = 12 potential variants. The architecture should NOT try to handle all 12 now. Instead:

### Recommended Accommodation Strategy

**Layer 1 (current task 117)**: Base + dense + discrete, no endpoints. Three corollaries.

**Layer 2 (future task)**: Add first/last element variants. These compose cleanly:
- Dense + first element: J_0 + F'T + FPHbot
- Discrete + last element: J_0 + G'bot + H'bot + PFGbot
- etc.

The architecture accommodates this by:
1. Making the case split in `bx_completeness` extensible (currently: F'T vs U(T,bot))
2. Keeping the chronicle construction axiom-agnostic
3. Using the corollary pattern for each combination

**Layer 3 (distant future)**: Non-Archimedean variants, non-linear variants (branching time). These would require fundamentally different constructions and are out of scope for the current architecture.

### Dense + Discrete Combined

This is **impossible** for AddCommGroup models: a nontrivial ordered abelian group is either dense or discrete (Holder's theorem). However, for GENERAL linear orders (not necessarily groups), a linear order can have both dense and discrete regions. Since the codebase constrains D to AddCommGroup, this case is correctly excluded. No architectural accommodation needed.

---

## Q4: The Uniformity Axioms

### Current Axioms (4)

The four uniformity axioms in `Axioms.lean:332-362`:

1. `discrete_symm_fwd`: U(T,bot) -> S(T,bot)
2. `discrete_symm_bwd`: S(T,bot) -> U(T,bot)
3. `discrete_propagate_fwd`: U(T,bot) -> G(U(T,bot))
4. `discrete_propagate_bwd`: U(T,bot) -> H(U(T,bot))

### Are These the RIGHT Axioms?

**Yes, but with qualifications.**

These axioms encode the translation invariance of "gaps" in ordered abelian groups. In any ordered abelian group, if there is an empty open interval (t, t+d) for some d > 0, then by translating by any amount, (s, s+d) is also empty for all s. This is exactly what the four axioms say:
- Symmetry (1, 2): A forward gap implies a backward gap (and vice versa)
- Propagation (3, 4): A gap at one point implies a gap at all future/past points

### Could We Use FEWER Axioms?

**Potentially yes.** Let us check whether `discrete_propagate_bwd` is derivable from the other three + temporal duality.

**Analysis of discrete_propagate_bwd derivability**:

The temporal_duality rule swaps:
- G <-> H
- F <-> P
- U <-> S

Applying temporal_duality to `discrete_propagate_fwd` (U(T,bot) -> G(U(T,bot))):
- swap(U(T,bot)) = S(T,bot)
- swap(G(U(T,bot))) = H(S(T,bot))

So temporal_duality gives: S(T,bot) -> H(S(T,bot))

To get `U(T,bot) -> H(U(T,bot))` from this, we need:
1. `U(T,bot) -> S(T,bot)` (= `discrete_symm_fwd`)
2. `S(T,bot) -> H(S(T,bot))` (from temporal_duality of `discrete_propagate_fwd`)
3. `H(S(T,bot) -> U(T,bot))` (from `discrete_symm_bwd` under H)
4. Chain: U(T,bot) -> S(T,bot) -> H(S(T,bot)) -> H(U(T,bot)) ... but step 3 needs H distributing over implication, which requires `temp_k_dist_past` (H analog of K).

More precisely:
- From `discrete_symm_bwd`: S(T,bot) -> U(T,bot) is a theorem
- Temporal generalization: H(S(T,bot) -> U(T,bot)) is a theorem
- H distributes over ->: H(S(T,bot) -> U(T,bot)) -> (H(S(T,bot)) -> H(U(T,bot)))
- So: H(S(T,bot)) -> H(U(T,bot))
- Chain: U(T,bot) -> S(T,bot) -> H(S(T,bot)) -> H(U(T,bot))

**YES, `discrete_propagate_bwd` IS derivable** from:
- `discrete_symm_fwd` (axiom 1)
- `discrete_symm_bwd` (axiom 2)
- `discrete_propagate_fwd` (axiom 3)
- temporal_duality (inference rule)
- temporal generalization + K distribution (standard BX rules)

**Similarly, `discrete_symm_bwd` IS derivable** from `discrete_symm_fwd` + temporal_duality:
- temporal_duality of `discrete_symm_fwd` (U(T,bot) -> S(T,bot)):
  - swap: S(T,bot) -> U(T,bot) = `discrete_symm_bwd`

So we could use **only 2 axioms**: `discrete_symm_fwd` and `discrete_propagate_fwd`, deriving the other two via temporal duality and standard BX rules.

**However**, the current approach of 4 axioms is defensible:
1. It makes the axiom set mirror-symmetric (clear forward/backward pairing)
2. It avoids relying on the temporal_duality inference rule for basic axioms
3. It matches standard tense logic practice where mirror images are stated explicitly
4. The derived versions would still need to be formalized (non-trivial Lean proofs)

**Recommendation**: Keep all 4 axioms as currently implemented. The redundancy is harmless (it does not affect soundness or completeness), and the symmetric presentation is clearer for publication.

---

## Q5: Impact on Existing Results

### Impact on `bx_soundness`

**Already handled.** Phase 2 of plan 04 (completed) added soundness cases for all four uniformity axioms. The soundness proofs use AddCommGroup translation invariance. The `axiom_base_valid`, `axiom_valid_dense`, and `axiom_valid_discrete` matchers all use wildcard patterns (`| _ =>`), so the four new constructors compile without changes to the match expressions.

### Impact on `bx_decidability`

The decidability infrastructure (`Metalogic/Decidability/`) is NOT directly affected because:
1. The decision procedure (`DecisionProcedure.lean`) operates on the subformula closure, which is axiom-independent
2. The FMP modules (`DenseFMP.lean`, `DiscreteFMP.lean`) are already organized by frame class
3. The uniformity axioms don't change the subformula closure size (they use only `U(T,bot)`, `S(T,bot)`, and `G`/`H` applied to these)

However, adding uniformity axioms to the base system means the decidability theorem's axiom set is now larger. The `Tableau.lean` and related files may need an audit to confirm they handle the new axiom forms. This is NOT a blocker for task 117 -- it's a follow-up concern.

### Impact on Conservative Extension Results

The `ConservativeExtension/` module (4 files: ExtFormula.lean, ExtDerivation.lean, Substitution.lean, Lifting.lean) is NOT affected by adding axioms to the base system. The conservative extension infrastructure proves that formula extensions are conservative -- i.e., adding new FORMULAS (not new axioms) does not change derivability of base formulas. Adding new axioms is a different operation that does NOT interact with the conservative extension machinery.

**Caveat**: If the conservative extension results were used to prove that adding F'T or G'bot+H'bot to BX is conservative, then the base axiom change would matter. But no such result is currently formalized. The conservative extension module is about formula-level extension (adding new atoms/connectives), not axiom-level extension.

### Impact on Frame Condition Analysis

The `FrameConditions/` module (Compatibility.lean, FrameClass.lean, Soundness.lean, Validity.lean) defines frame classes and their compatibility with axioms. The `FrameClass` enum has `Base`, `Dense`, `Discrete` variants. The uniformity axioms are classified as `Base` (valid on all linear orders with AddCommGroup), so they don't affect the frame class architecture. No changes needed.

---

## Q6: Z-Chronicle Architecture

### Current State

The current plan (Phase 4) builds `discrete_iso : LimitDomSubtype ≃o Z` and then `discrete_fmcs : FMCS Int`. This has ONE sorry at `limitDomSubtype_isSuccArchimedean`.

### Options Analysis

**(a) Separate module `DiscreteChronicleConstruction.lean`**: AGAINST. The chronicle construction is axiom-agnostic. Dense and discrete use the SAME chronicle (ChronicleConstruction.lean). Only the countermodel conversion (ChronicleToCountermodel.lean) differs. A separate module would duplicate shared code.

**(b) Integrated into `ChronicleConstruction.lean`**: AGAINST. ChronicleConstruction.lean builds the omega-chain and proves C0-C5. It doesn't know about Q vs Z. Putting the Z-iso there would mix abstraction levels.

**(c) Parameterized version of the existing construction**: PARTIALLY -- but the right factoring is:

**Recommended**: Keep the current architecture with these refinements:

```
Chronicle/
  ChronicleTypes.lean           -- Shared types (unchanged)
  RRelation.lean                -- Shared R-relation (unchanged)
  PointInsertion.lean           -- Shared point insertion (unchanged)
  CounterexampleElimination.lean -- Shared CE (unchanged)
  ChronicleConstruction.lean    -- Shared omega-chain (unchanged)
  ChronicleToCountermodel.lean  -- BOTH cases (dense + discrete countermodels)
```

Having both dense and discrete countermodel constructions in the same file (ChronicleToCountermodel.lean) is defensible because:
1. They share imports and helper definitions
2. They have parallel structure (FMCS -> BFMCS -> countermodel)
3. The file is currently only 629 lines -- adding both cases would bring it to ~900-1100 lines, which is manageable
4. The master theorem in Completeness.lean needs to import BOTH, so keeping them together reduces import complexity

If the file grows beyond ~1200 lines, refactor into `DenseCountermodel.lean` and `DiscreteCountermodel.lean`. But premature splitting is worse than a slightly long file.

---

## Q7: Publication Readiness

### Is the Case Split an Artifact or Genuine Mathematics?

**Both, but in different senses.**

**The case split is a genuine mathematical fact**: In any ordered abelian group, either every element has an immediate successor (discrete: Z, Z/nZ) or between any two elements there is a third (dense: Q, R). This is NOT an artifact -- it is Holder's theorem applied to the Archimedean case. The case split reflects the dichotomy between the two fundamental classes of ordered groups.

**The need for the case split IS an artifact of the formalization**: Burgess 1982 builds a model on an arbitrary countable linear order X. He doesn't need to know whether X is dense or discrete. The truth lemma works for any X satisfying C0-C5. The case split is forced by the codebase's `AddCommGroup D` requirement in `valid`, which demands a concrete group-theoretic carrier. Burgess avoids this by not requiring group structure.

### Impact on Publication Clarity

**For a pure logic paper**: The case split is a minor blemish. A referee might ask "why can't you build the model directly on X?" and the answer is "because the semantic framework requires AddCommGroup for time-shift invariance of modal accessibility." This is a reasonable design choice with clear motivation (the TaskModel semantics needs shift operations for modal logic), but it adds complexity that Burgess avoids.

**For a formalization paper**: The case split is a FEATURE, not a bug. It demonstrates:
1. The interaction between abstract semantics (AddCommGroup) and concrete constructions (Q, Z)
2. The role of uniformity axioms in bridging the gap
3. The power of Lean's type system in enforcing semantic constraints that pen-and-paper proofs leave implicit

**Recommendation for publication**: Frame the case split as a consequence of the bimodal (modal + temporal) design. The modal component requires world-indexed semantics with time-shift closure, which necessitates group structure. The temporal component uses Burgess's chronicle construction, which produces countable linear orders. The case split is the natural meeting point: classify the group's order type (dense or discrete) and embed the chronicle accordingly.

### Elegance Assessment

The proof structure is:
1. Non-derivable phi -> consistent {neg phi}
2. Extend to MCS A0 (Lindenbaum)
3. Build chronicle on A0 (Burgess, axiom-agnostic)
4. Case split on A0's discreteness content:
   - F'T in A0: chronicle limit domain is dense, embed in Q via Cantor
   - U(T,bot) in A0: chronicle limit domain is discrete, embed in Z
5. Build BFMCS + parametric countermodel
6. Truth lemma -> contradiction with validity

This is clean, modular, and mathematically honest. The case split at step 4 is the only place where the "TM = S5 + temporal" bimodal design forces additional structure beyond what Burgess needs. This is an acceptable trade-off for a system that correctly handles modal-temporal interaction (the `modal_future` and `temp_future` axioms require the group structure that necessitates the case split).

---

## Synthesis: Architectural Recommendations

### Short-term (Task 117)

1. **Complete the discrete case** (resolve `IsSuccArchimedean` sorry)
2. **Complete BFMCS for both cases** (Phases 5-6)
3. **Wire the case-split completeness** (Phase 7)
4. **Keep ChronicleToCountermodel.lean as single file** (both cases, ~900-1100 lines)

### Medium-term (Post-117)

1. **Add dense/discrete corollary files** (DenseCompleteness.lean, DiscreteCompleteness.lean)
2. **Verify decidability still works** with the uniformity axioms
3. **Consider reducing to 2 axioms** (derive `discrete_symm_bwd` and `discrete_propagate_bwd` from temporal duality) -- but only if publication requires minimal axiom sets

### Long-term (Publication)

1. **Frame the three completeness results** as: base (subsumes both), dense (corollary), discrete (corollary)
2. **Document the AddCommGroup requirement** as the bridge between Burgess's abstract construction and the bimodal (TM) semantic framework
3. **Consider relaxing AddCommGroup** in `valid` to just `LinearOrder` -- this would eliminate the case split entirely, making the completeness proof a direct application of Burgess. However, this would break ShiftClosed and the modal semantics. Assess whether ShiftClosed can be reformulated without group structure.

---

## Appendix: Burgess Section 1.6 Analysis

Burgess's variant table (Section 1.6, page 2):

| Postulates on < | Axioms for S, U |
|-----------------|-----------------|
| Density         | F'T             |
| Discreteness    | G'bot /\ H'bot  |
| First Element   | FPHbot          |
| Last Element    | PFGbot          |
| No First Element | Ptop           |
| No Last Element  | Ftop           |

Mapping to codebase notation:
- F'T = neg(U(T, bot)) = neg(next_top) (already the `F'T` formula)
- G'bot = U(T, bot) = next_top (already defined)
- H'bot = S(T, bot) (derived from G'bot via `discrete_symm_fwd`)
- P'T = neg(S(T, bot)) = neg(prev_top) (density in past direction)
- FPHbot = F(P(H(bot))) (first element)
- PFGbot = P(F(G(bot))) (last element)
- Ptop = P(T) = serial_past (already in BX)
- Ftop = F(T) = serial_future (already in BX)

The uniformity axioms in the codebase encode that in an AddCommGroup, discreteness is UNIFORM: if there's a gap at one point, there's a gap everywhere. This is stronger than Burgess's G'bot + H'bot (which just says the gap exists at the current point). The uniformity is needed because the completeness proof must propagate the discreteness property from A0 to ALL domain points via `limit_forward_G`/`limit_backward_H`.

In Burgess's framework, G'bot + H'bot as axioms ensure they hold at every point in every model (axioms are universally valid). In the codebase, the axioms are added to the deductive system, so they appear in every MCS, achieving the same effect. The uniformity axioms go further: they ensure that the CHRONICLE construction produces a discrete limit domain (via propagation from A0 to all inserted points).
