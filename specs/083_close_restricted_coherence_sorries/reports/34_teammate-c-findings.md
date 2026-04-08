# Research Report: Task #83 -- Literature Study on Burgess-Xu Canonical Completeness

**Task**: 83 - close_restricted_coherence_sorries
**Role**: Teammate C -- Literature survey on published completeness proofs
**Started**: 2026-04-07T00:00:00Z
**Completed**: 2026-04-07T01:00:00Z
**Effort**: medium
**Dependencies**: None
**Sources/Inputs**: Web search, codebase analysis, Stanford Encyclopedia of Philosophy, academic paper metadata
**Artifacts**: This report
**Standards**: report-format.md

## Executive Summary

- The Burgess-Xu axiom system (BX1-BX7 with mirrors) is the standard axiomatization for reflexive Since/Until over linear orders; our Lean formalization faithfully reproduces it
- The canonical model completeness proof for Until requires **eventuality resolution**: showing that if phi U psi is in MCS w and psi is not in w, there exists a future MCS v where psi holds
- Published proofs universally use a **chain construction + Zorn's lemma** (or equivalent) approach, not a direct finite construction
- The key proof technique: BX5 (self-accumulation) ensures phi U psi **persists** along any chain of MCS where psi fails; BX6 (absorption) creates a **contradiction** if the eventuality persists forever, forcing psi to appear at the chain's limit or beyond
- No prior formalization of Until/Since canonical completeness exists in any proof assistant (Lean, Coq, Isabelle, Agda)
- The backward direction uses BX4 (connectedness) and induction/contrapositive arguments

## Context and Scope

We are formalizing the completeness theorem for bimodal logic TM (S5 modal + linear temporal with Until/Since) in Lean 4. The BX canonical model construction is partially complete:

**Completed in codebase**:
- BXPoint structure wrapping MCS (`Frame.lean`)
- Canonical ordering bx_le via g_content inclusion
- Reflexivity (from BX1), transitivity (from temp_4)
- Modal equivalence and S5 modal witness construction
- Forward/backward temporal witnesses for F/P (Lindenbaum extension of witness seeds)
- Truth lemma for atom, bot, imp, box, G, H cases
- Consistency of neg-phi when phi is not derivable
- Completeness theorem statement with sorry for model construction

**Remaining sorries** (4 in TruthLemma.lean, 1 in Completeness.lean, 1 in Frame.lean):
1. `until_iff_mcs` forward direction (psi not in w case) -- eventuality resolution
2. `until_iff_mcs` backward direction -- witness implies membership
3. `since_iff_mcs` forward direction (mirror of Until)
4. `since_iff_mcs` backward direction (mirror)
5. `bx_completeness` -- canonical TaskModel embedding
6. `bx_modal_witness` full modal equivalence (Frame.lean line ~440)

## Findings

### Literature Overview

#### Burgess 1982/1984

**Primary reference**: Burgess, J.P. "Axioms for Tense Logic I: 'Since' and 'Until'", Notre Dame Journal of Formal Logic 23(4), pp. 367-374, 1982. Expanded in "Basic Tense Logic", Handbook of Philosophical Logic, vol. II, pp. 89-133, 1984.

Burgess provided the first complete axiomatization for the Since-Until tense logic over the class of all reflexive linear orderings. His completeness proofs are described as "relatively simple modifications of the usual proofs for ordinary tense logic without S and U" (Burgess 1982, p. 367). The key innovation was identifying the correct set of axioms that make the canonical model work.

Burgess's axiom system corresponds exactly to our BX1-BX7 (with mirrors for Since). The reflexive semantics (G phi means "at all present-or-future times phi") is critical -- the strict semantics requires additional axioms (later provided by Venema 1993 and Reynolds 1994/1996).

#### Xu 1988

**Reference**: Xu, M. "On some U,S-tense logics", Journal of Philosophical Logic 17, pp. 181-202, 1988.

Xu simplified Burgess's axiomatization. The key simplification was in the interaction axioms between Until and Since. Our BX4 (connectedness: phi -> G(P(phi))) corresponds to one of Xu's simplified axioms, replacing a more complex Until-Since interaction axiom from Burgess's original system.

#### Goldblatt 1992

**Reference**: Goldblatt, R. "Logics of Time and Computation", 2nd edition, CSLI Lecture Notes no. 7, 1992.

Goldblatt covers Until in Part II of his book (temporal logic of programs). His treatment uses canonical models for the basic temporal operators G/H and extends to Until via the programs-and-computation perspective. The completeness argument follows the standard canonical model approach with additional "unraveling" for the Until case, but his primary focus is on the Next-Until fragment rather than the full Since-Until system.

#### Gabbay, Hodkinson, Reynolds 1994

**Reference**: Gabbay, D.M., Hodkinson, I., Reynolds, M. "Temporal Logic: Mathematical Foundations and Computational Aspects", Volume 1, Oxford University Press, 1994.

This is the definitive reference for Until/Since completeness over linear orders. Chapter treatments cover:
- Full axiomatization with completeness proofs
- Multiple proof techniques (canonical model, filtration, quasimodels)
- Treatment of both reflexive and irreflexive semantics
- First-order extensions

Gabbay and Hodkinson (1990) specifically developed the Hilbert-style axiomatisation for Until/Since over the real numbers using an irreflexivity rule, with independence and completeness for single formulas proved.

#### Venema 1993

**Reference**: Venema, Y. "Completeness via Completeness", in de Rijke (ed.), Diamonds and Defaults, Synthese Library, Springer, 1993.

Venema's key contribution was showing how three notions of completeness interweave for the Since/Until formalism: (1) Dedekind-completeness of time flows, (2) expressive/functional completeness of temporal operators, and (3) axiomatization completeness. He extended the Burgess-Xu system to strict linear orderings by adding axioms for discreteness, well-orderings, and the natural numbers.

#### Hodkinson and Reynolds 2007

**Reference**: Hodkinson, I. and Reynolds, M. "Temporal Logic", Chapter 11 in Blackburn et al. (eds.), Handbook of Modal Logic, Elsevier, 2007.

Survey chapter covering canonical model techniques for temporal logics. Discusses the separation property and its relationship to completeness.

### Eventuality Resolution Techniques

This is the central technical challenge. All published proofs for the Until truth lemma forward direction follow essentially the same pattern:

#### The Standard Technique (Burgess/Xu/Goldblatt/GHR)

**Goal**: Given MCS w with phi U psi in w and psi not in w, find MCS v with bx_le w v, psi in v, and phi in all u between w and v.

**Step 1: Construct a chain of MCS where phi U psi persists**

Starting from w, build a chain of MCS (w = w_0 <= w_1 <= w_2 <= ...) such that:
- phi U psi is in each w_i
- psi is not in each w_i (until we find the witness)
- phi is in each w_i (from the negation of psi and the axioms)

The construction at each step uses BX5 (self-accumulation):

```
phi U psi -> (phi AND phi U psi) U psi         [BX5]
```

This means: if phi U psi holds at w_i, then at w_i we also have (phi AND phi U psi) U psi. Since psi is not yet at w_i, we can derive that phi holds at w_i (from the "guard" of the Until), AND phi U psi persists forward.

More precisely: from phi U psi in w and psi not in w, we derive:
1. phi in w (because phi U psi and not-psi implies phi must hold at the current point -- this follows from the reflexive semantics and BX1)
2. F(phi U psi) in w (the eventuality persists into the strict future, derivable from BX5 + not-psi)

**Step 2: Use Zorn's lemma to obtain a maximal chain**

Consider the partially ordered set of all consistent extensions of g_content(w) that contain phi U psi but not psi. Apply Zorn's lemma: every chain has an upper bound (the union of a chain of consistent sets is consistent -- this is the standard chain lemma).

The maximal element of such a chain gives us an MCS v_max where:
- bx_le w v_max (since g_content(w) is included)
- phi U psi in v_max
- phi in all points between w and v_max (by BX5's self-accumulation)

**Step 3: Show psi must hold at or just beyond v_max (BX6 argument)**

This is where BX6 (absorption) plays its critical role. BX6 states:

```
phi U (phi AND phi U psi) -> phi U psi          [BX6]
```

The contrapositive of BX6 gives: if phi U psi fails, then phi U (phi AND phi U psi) also fails.

The argument by contradiction:
- Suppose psi is NOT in v_max (the maximal element).
- Then by BX5, we have (phi AND phi U psi) U psi in v_max.
- Since psi is not in v_max, the eventuality must be realized further along.
- By the witness seed construction (Lindenbaum extension), there exists v > v_max with psi in v.
- But we need phi to hold between w and v. By the self-accumulation, phi AND phi U psi holds at all points between w and v_max, so phi holds there. At v_max itself, phi holds (from BX5 + psi not in v_max). So phi holds on the entire interval [w, v).

**Alternative argument (without explicit Zorn's on the chain)**: Some formulations use a more direct approach:

From phi U psi in w with psi not in w:
1. By BX5: (phi AND phi U psi) U psi in w
2. Since psi not in w: F(psi) in w (derivable from phi U psi, since the eventuality must be realized)
3. By the forward witness construction (Lindenbaum), there exists v >= w with psi in v
4. Need to show phi holds on [w, v) -- this uses BX7 (linearity) and BX4 (connectedness)

The key insight is that F(psi) is derivable from phi U psi. Under reflexive semantics:
```
phi U psi -> psi OR F(psi)                      [derivable from BX1 + definitions]
```
If psi is not in w, then F(psi) must be in w. The existing `bx_forward_witness` in Frame.lean can then construct the witness v.

The harder part is establishing that phi holds on [w, v). This is where the self-accumulation axiom BX5 is essential: it ensures that phi U psi (and hence phi, when psi fails) persists at all intermediate points.

#### Comparison of Approaches

| Approach | Used by | Zorn? | Complexity |
|----------|---------|-------|------------|
| Maximal chain + BX6 contradiction | Burgess 1982, Goldblatt 1992 | Yes | High |
| Direct witness + BX5 persistence | Xu 1988, some textbooks | No (uses Lindenbaum only) | Medium |
| Filtration + finite model | Reynolds 2003 (for decidability) | No | Different goal |
| Quasimodel construction | Aguilera et al. 2022 | No | For non-classical variants |

### The BX5/BX6 Argument in Detail

#### BX5: Self-Accumulation

```
phi U psi -> (phi AND phi U psi) U psi
```

**Role in the proof**: BX5 enriches the guard of the Until formula. When phi U psi holds at point t, not only does phi hold at intermediate points, but phi U psi ALSO holds at those intermediate points. This "self-referential" property means the eventuality propagates forward automatically.

**In the canonical model**: If phi U psi is in MCS w, and we move to any MCS v with w <= v where psi has not yet been realized, then phi U psi must still be in v (assuming v is on the "path" toward the witness). This is because BX5 ensures the conjunction phi AND phi U psi holds at all intermediate points.

**Formal argument**: From phi U psi in w:
1. By BX5: (phi AND phi U psi) U psi in w
2. For any v with w <= v and psi not in v:
   - phi AND phi U psi must hold at v (it is the "guard" of the enriched Until)
   - In particular, both phi in v AND phi U psi in v
3. This gives us the persistence of the eventuality along the chain

#### BX6: Absorption

```
phi U (phi AND phi U psi) -> phi U psi
```

**Role in the proof**: BX6 prevents infinite deferral. If the eventuality phi U psi could be deferred indefinitely (always saying "phi holds now, and phi U psi holds further on"), BX6 ensures this two-step pattern collapses.

**Contrapositive**: not(phi U psi) -> not(phi U (phi AND phi U psi)). If phi U psi fails, you cannot even get phi U (phi AND phi U psi).

**In the canonical model**: Suppose for contradiction that no MCS v >= w has psi in v (while phi U psi persists). Then at every future point, we have phi AND phi U psi. This means phi U (phi AND phi U psi) holds at w. By BX6, phi U psi holds at w -- which it already does, so no immediate contradiction. The real contradiction comes from the structure of the canonical ordering: if psi is "never" reached, the chain of points with phi U psi but not psi forms an open set, and its "closure" (via Zorn or compactness) must also satisfy phi U psi but not psi. BX6 combined with BX5 then gives a contradiction because the limit point would satisfy phi U (phi AND phi U psi) but also (by the Zorn argument) the eventuality cannot be realized.

#### BX7: Linearity

```
phi U psi AND chi U theta ->
  (phi AND chi) U (psi AND theta) OR
  (phi AND chi) U (psi AND chi) OR
  (phi AND chi) U (phi AND theta)
```

**Role**: BX7 ensures that Until witnesses are linearly ordered. If two Until formulas hold simultaneously, their witnesses must be comparable. This is essential for the canonical model to have a linear temporal ordering on the witnesses.

### Backward Direction

The backward direction shows: if there exists v >= w with psi in v and phi on [w, v), then phi U psi in w.

**Published technique**: Contrapositive argument using BX4 (connectedness).

Suppose phi U psi is NOT in w. Then neg(phi U psi) is in w (by MCS completeness). We need to show there is no valid witness.

The argument proceeds by showing that for any v >= w:
1. If psi is in v, then there must exist some u in [w, v) where phi fails
2. This uses BX4: phi -> G(P(phi)), which ensures "backward visibility" -- the present is always in the past of the future

A direct proof (non-contrapositive) uses induction on the structure of the witness:
1. If v = w (reflexive case): psi in w, so phi U psi in w by BX1 (reflexivity gives G(phi) -> phi, and dually phi U psi when psi holds now)
2. If v > w: Need to derive phi U psi in w from:
   - phi in w
   - phi U psi in w' for some w' with w < w' <= v (inductive step)

   This uses BX3 (right monotonicity) and BX4 (connectedness) to "push" the Until formula backward from v to w.

The exact derivation: From phi in w and F(phi U psi) in w (derivable from the witness structure), use BX4 + BX2 + BX3 to derive phi U psi in w. The key step is showing that phi AND F(psi) implies phi U psi under appropriate conditions, which requires the connectedness axiom.

### Formalization Precedents

**No prior formalization of Until/Since canonical completeness exists in any proof assistant.**

Closest related work:
1. **Doczkal and Smolka (2014/2016)**: Completeness and decidability for CTL in Coq/Ssreflect. Uses tableau-based approach, not canonical models. CTL includes temporal operators but the proof technique is fundamentally different (history-augmented tableaux, inductive semantics).

2. **ljt12138 (Lean 3)**: Formalization of PAL + modal logic S5 in Lean 3. Covers S5 canonical model with truth lemma but no temporal operators.

3. **Coalition Logic in Lean 4 (ITP 2024)**: Soundness and completeness for coalition logic axiomatization in Lean 4. Uses canonical model construction with MCS, truth lemma by induction. Relevant as a template for our work but no temporal operators.

4. **AFP/Isabelle**: Linear Temporal Logic entry covers syntax and semantics but NOT completeness. Normalization procedures and model checking, not axiomatic completeness.

5. **kuco23/Temporal-Logic (Agda)**: Natural deduction for temporal logic in Agda. Soundness proved, completeness not addressed.

6. **Open Logic Project**: Canonical model completeness for normal modal logics, pedagogical. No Until/Since treatment.

**Our formalization would be the first mechanized completeness proof for a temporal logic with Until/Since via canonical models.**

### Recommended Approach for Our Formalization

Based on the literature survey, here is the recommended strategy for closing the remaining sorries:

#### For the Forward Direction (phi U psi in w, psi not in w):

**Option A: Direct witness via F(psi) (Simpler, Recommended)**

1. Derive F(psi) from phi U psi (this is provable from the axioms: phi U psi -> psi OR F(psi) under reflexive semantics; since psi not in w, F(psi) must be in w)
2. Use existing `bx_forward_witness` to get MCS v >= w with psi in v
3. Show phi holds on [w, v) using BX5 (self-accumulation):
   - From phi U psi in w and BX5: (phi AND phi U psi) U psi in w
   - For any u with w <= u < v: if psi not in u, then phi AND phi U psi in u (from the enriched Until guard)
   - In particular, phi in u
4. This requires proving that the canonical ordering on BXPoints is compatible with the Until semantics, which is what BX7 (linearity) provides

**Option B: Zorn's lemma chain (More faithful to literature, more complex)**

1. Define the set S = {T : Set Formula | SetConsistent T AND g_content(w) subset T AND phi U psi in T AND psi not in T}
2. Show S is nonempty (w's formulas satisfy it)
3. Show chains in S have upper bounds (union of chain of consistent sets is consistent)
4. Apply Zorn to get maximal element M
5. Extend M to MCS v_max
6. Show either psi in v_max (done) or derive contradiction via BX6

**Recommendation**: Option A is significantly simpler and avoids a separate Zorn application beyond Lindenbaum. The key step that needs formal verification is deriving F(psi) from phi U psi when psi is absent. This should be derivable as follows:

```
phi U psi                                    -- hypothesis
-> (phi AND phi U psi) U psi                 -- BX5
-> psi OR F(psi)                             -- derivable: A U B -> B OR F(B) under reflexive semantics
```

The derivation of `A U B -> B OR F(B)` under reflexive semantics:
- `A U B -> G(A -> A U B) -> ...` -- this gets complicated
- Actually simpler: `A U B -> B OR (A AND F(A U B))` is derivable from BX5 + BX1
- Then `F(A U B) -> F(B OR F(B))` by monotonicity, and iterate...

Actually, deriving F(psi) from phi U psi is the non-trivial part. The cleanest approach uses:
```
phi U psi -> (phi AND phi U psi) U psi       [BX5]
```
In the canonical model, (phi AND phi U psi) U psi in w with psi not in w means the enriched guard holds at w, so F(psi) must hold (the Until requires a future witness). Under reflexive semantics, `A U B` means there exists t >= now with B at t and A on [now, t). If B is not at now, then t > now, so F(B) holds.

This is formally: `phi U psi AND NOT psi -> F(psi)`. To derive this:
- By BX1 (reflexivity): G(phi) -> phi, so we have `psi -> phi U psi` (reflexive witness)
- Contrapositively, the interesting direction needs more work.

The cleaner derivation uses BX3 (right monotonicity with `phi -> psi = (psi -> TOP)` or similar) combined with the definition of F.

**For the Lean implementation**: The recommended path is:

1. **Prove `until_implies_psi_or_F_psi`**: Derive `phi U psi -> psi OR F(psi)` as a theorem from the BX axioms
2. **Use existing infrastructure**: `bx_forward_witness` already handles F(psi) in w -> exists v >= w with psi in v
3. **Prove interval guard**: Show phi on [w, v) using BX5 + the canonical ordering properties
4. **For backward direction**: Prove by contrapositive using BX4

#### For the Backward Direction:

Use the contrapositive approach:
1. Assume NOT(phi U psi) in w (so neg(phi U psi) in w)
2. Show for any v >= w: either psi not in v, or there exists u in [w, v) with phi not in u
3. This uses BX4 (connectedness) and properties of the canonical ordering

Alternatively, a direct inductive approach:
1. When v = w: psi in w directly gives phi U psi in w (reflexive witness, derived from BX1/BX3)
2. When v > w: use phi in w, phi in all intermediate u, and phi U psi derivable from the interval structure

#### For the Completeness Theorem Wiring:

1. Build canonical TaskModel from BXPoints (embed into TaskFrame)
2. Show truth lemma (all cases, including the newly proved Until/Since)
3. Apply contrapositive: non-derivable phi gives consistent {neg phi}, extend to MCS w_0, show phi false at w_0 in canonical model

## Decisions

1. **Option A (direct witness via F(psi)) is recommended** over Option B (Zorn's chain) for the forward direction, as it reuses existing infrastructure and is simpler to formalize
2. **The key missing theorem** is `phi U psi -> psi OR F(psi)` (or equivalently, `phi U psi AND NOT psi -> F(psi)`)
3. **Since cases mirror Until** and should be proved by dual arguments
4. **The backward direction** should use a direct approach via BX4 rather than contrapositive, as the direct approach is more natural for formalization

## Risks and Mitigations

| Risk | Severity | Mitigation |
|------|----------|------------|
| Deriving F(psi) from phi U psi may require complex intermediate lemmas | Medium | Break into small steps; use existing Combinators.lean and Perpetuity.lean infrastructure |
| The interval guard (phi on [w,v)) may need BX7 (linearity) in ways not yet formalized | Medium | BX7 is already an axiom; derive needed instances |
| The backward direction for Until may require subtle use of connectedness | Medium | Study BX4 interaction with canonical ordering carefully |
| Modal equivalence sorry in Frame.lean (line ~440) blocks completeness | High | This is a separate concern from Until/Since but must be resolved |
| Canonical TaskModel embedding (sorry in Completeness.lean) requires packaging BXPoints into TaskFrame | High | This is structural work; the mathematical content is in the truth lemma |

## Key References

1. Burgess, J.P. (1982). "Axioms for Tense Logic I: 'Since' and 'Until'". Notre Dame Journal of Formal Logic 23(4), pp. 367-374.
   - [Project Euclid](https://projecteuclid.org/euclid.ndjfl/1093870149)

2. Burgess, J.P. (1984). "Basic Tense Logic". In Gabbay & Guenthner (eds.), Handbook of Philosophical Logic, vol. II, pp. 89-133.
   - [Springer](https://link.springer.com/chapter/10.1007/978-94-009-6259-0_2)

3. Xu, M. (1988). "On some U,S-tense logics". Journal of Philosophical Logic 17, pp. 181-202.
   - [PhilPapers](https://philpapers.org/rec/XUOSU)

4. Goldblatt, R. (1992). "Logics of Time and Computation", 2nd edition. CSLI Lecture Notes no. 7.
   - [CSLI Publications](https://csli.sites.stanford.edu/publications/csli-lecture-notes/logics-time-and-computation)

5. Venema, Y. (1993). "Completeness via Completeness". In de Rijke (ed.), Diamonds and Defaults, Synthese Library, Springer.
   - [Springer](https://link.springer.com/chapter/10.1007/978-94-015-8242-1_12)

6. Gabbay, D.M., Hodkinson, I., Reynolds, M. (1994). "Temporal Logic: Mathematical Foundations and Computational Aspects", Volume 1. Oxford University Press.
   - [Oxford Academic](https://academic.oup.com/book/53043)

7. Reynolds, M. (1996). "Axiomatising first-order temporal logic: Until and since over linear time". Studia Logica 57, pp. 279-302.
   - [Springer](https://link.springer.com/article/10.1007/BF00370836)

8. Hodkinson, I. and Reynolds, M. (2007). "Temporal Logic". Chapter 11 in Blackburn et al. (eds.), Handbook of Modal Logic, Elsevier.

9. Stanford Encyclopedia of Philosophy, "Temporal Logic", supplement on Burgess-Xu system.
   - [SEP](https://plato.stanford.edu/entries/logic-temporal/burgess-xu.html)

10. Doczkal, C. and Smolka, G. (2014/2016). "Completeness and Decidability Results for CTL in Coq". ITP 2014 / Journal of Automated Reasoning.
    - [Springer](https://link.springer.com/article/10.1007/s10817-016-9361-9)

## Appendix

### Search Queries Used

1. `Burgess "basic tense logic" 1984 completeness until canonical model eventuality resolution`
2. `Xu axiomatization until since tense logic completeness canonical model self-accumulation`
3. `temporal logic until operator canonical model completeness proof Zorn's lemma eventuality`
4. `Goldblatt "logics of time and computation" until truth lemma canonical model chapter completeness`
5. `Gabbay Hodkinson Reynolds "temporal logic mathematical foundations" until eventuality canonical model`
6. `formalization temporal logic completeness proof assistant Coq Isabelle Lean until operator`
7. `Venema "temporal logic" chapter completeness until since canonical model self-accumulation`
8. `Burgess 1982 "axioms for tense logic" since until Notre Dame completeness proof technique`
9. `Archive Formal Proofs temporal logic completeness Isabelle AFP linear temporal`
10. `Doczkal Smolka temporal logic completeness Coq constructive decidability`
11. `Lean formalization modal logic completeness canonical model maximal consistent set truth lemma`
12. `Hodkinson Reynolds "separation past present future" temporal logic`
13. `Venema 1993 "completeness via completeness" temporal logic until since`

### BX Axiom System (from our Axioms.lean, matching Burgess-Xu)

| Axiom | Name | Formula |
|-------|------|---------|
| BX1 | temp_t_future | G(phi) -> phi |
| BX1' | temp_t_past | H(phi) -> phi |
| BX2 | left_mono_until | G(phi -> chi) -> (phi U psi -> chi U psi) |
| BX2' | left_mono_since | H(phi -> chi) -> (phi S psi -> chi S psi) |
| BX3 | right_mono_until | G(phi -> psi) -> (chi U phi -> chi U psi) |
| BX3' | right_mono_since | H(phi -> psi) -> (chi S phi -> chi S psi) |
| BX4 | connect_future | phi -> G(P(phi)) |
| BX4' | connect_past | phi -> H(F(phi)) |
| BX5 | self_accum_until | phi U psi -> (phi AND phi U psi) U psi |
| BX5' | self_accum_since | phi S psi -> (phi AND phi S psi) S psi |
| BX6 | absorb_until | phi U (phi AND phi U psi) -> phi U psi |
| BX6' | absorb_since | phi S (phi AND phi S psi) -> phi S psi |
| BX7 | linear_until | phi U psi AND chi U theta -> disjunction of three cases |
| BX7' | linear_since | phi S psi AND chi S theta -> disjunction of three cases |

### Confidence Level

**Medium-High**. The literature survey is comprehensive and the proof technique is well-understood from published sources. The main uncertainty is in the exact formalization details -- specifically, deriving `phi U psi -> psi OR F(psi)` from the BX axioms, and the precise interaction between BX5/BX6 and the canonical ordering in the formal setting. The fact that no prior formalization exists means we cannot consult existing mechanized proofs for guidance.
