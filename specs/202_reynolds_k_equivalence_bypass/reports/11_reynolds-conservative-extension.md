# Reynolds Conservative Extension and Weak Semantics: Analysis for Task 202

**Task**: 202 - Reynolds k-equivalence bypass for sorry-free completeness_discrete
**Date**: 2026-05-29
**Purpose**: Investigate whether Reynolds' conservative extension / weak semantics approach provides a path around the Transfer.lean:1081 sorry, and clarify what Reynolds actually does in the discrete completeness proof.

---

## 1. What Reynolds Actually Does (1992/1994)

### 1.1 The Paper

The primary reference is Reynolds 1992, "An axiomatization for Until and Since over the reals without the IRR rule" (Studia Logica 51, pp. 165-193). The discrete completeness results appear in the Gabbay-Hodkinson-Reynolds book (1994) "Temporal Logic: Mathematical Foundations and Computational Aspects" (Oxford University Press), particularly Chapters 9-10 covering expressive completeness and Sections 6-8 of the completeness argument covering Prior structures, model surgery, and the one-class theorem.

### 1.2 Conservative Extension in this Codebase

The conservative extension infrastructure lives at `Theories/Bimodal/Metalogic/ConservativeExtension/` and consists of four files:

- **ExtFormula.lean**: Defines `ExtFormula` over `ExtAtom := Atom (+) Unit`. The fresh atom `Sum.inr ()` ("q") does not appear in any embedded formula. This is the standard Goldblatt/BdRV naming trick for eliminating the irreflexivity rule (IRR).

- **ExtDerivation.lean**: Mirrors the base proof system (`DerivationTree`) with `ExtDerivationTree` over `ExtFormula`. Defines `embedAxiom` and `embedDerivation` to lift base proofs into the extended system. The extended axiom system is identical to the base system (same schemas, just over `ExtFormula`).

- **Substitution.lean**: Defines `substFormula : ExtFormula -> ExtFormula` that replaces the fresh atom `q = Sum.inr ()` with `bot`. Proves axiom closure under this substitution.

- **Lifting.lean**: The main conservative extension result: `lift_derivation_qfree`. If the extended system derives `embedFormula phi` from `L.map embedFormula`, then the base system derives `phi` from `L`. The proof works by: (1) collecting all `Sum.inl` atoms from the derivation tree, (2) choosing a fresh atom `a` not among them, (3) applying `substFreshWith a` to replace `Sum.inr ()` with `Sum.inl a`, (4) unembedding the result to a base `DerivationTree`.

**Important**: This conservative extension is about the *irreflexivity rule* (IRR), NOT about adding new temporal operators or "weak" connectives. The extended language has the same operators (U, S, box, etc.) but with an extra atom that enables IRR-free axiomatization. The codebase already has this infrastructure fully implemented and sorry-free.

### 1.3 What "Weak Semantics" Means in the Codebase

The term "weak" in this codebase refers to the *reflexive canonical model* construction, NOT to a different semantic interpretation of temporal operators. Specifically:

- **`ReflexiveCanonical.lean`** defines `g_w_content` ("weak G-content"): the set `{ psi | psi AND G(psi) in x.val }`, as opposed to `g_content` ("strong G-content"): `{ psi | G(psi) in x.val }`. The "weak" version makes the accessibility relation *reflexive* (`reflCanR x y iff g_w_content x subseteq y.val`), while the "strong" version gives a strict (irreflexive) temporal relation.

- The point of using "weak" (reflexive) accessibility is that it bypasses the need for the IRR rule in the canonical model construction. In the standard approach, proving that the canonical temporal relation is irreflexive requires IRR. Reynolds' approach avoids this by working with a reflexive relation and then recovering the correct temporal behavior through the Prior axioms (UZ, SZ) and the model surgery argument.

- This is NOT about interpreting U or S differently. The truth conditions for U(phi, psi) and S(phi, psi) remain the standard strict-future / strict-past ones. The "weakness" is in the canonical model construction, not in the object-level semantics.

### 1.4 Reynolds' Completeness Strategy for Discrete Time

Reynolds' strategy for discrete (Z-indexed) completeness proceeds in stages:

**Stage A: Canonical Model (Burgess/Xu chronicle)**
- Start with an MCS A containing neg(phi) and box(next_top) (discreteness indicator).
- Build the Burgess chronicle: a countable discrete linear order without endpoints, with an MCS assigned to each point, satisfying temporal coherence conditions (C4, C5).
- The chronicle is a "Prior structure": Prior-UZ and Prior-SZ hold at every point.
- This is already implemented as `ChronicleAsPriorModel` in `ChronicleExtraction.lean`.

**Stage B: Expressive Completeness (Theorem 5)**
- Prove that {U, S} alone is expressively complete over Prior structures.
- The Stavi connectives U'(A,B) and S'(A,B) are always false on Prior structures (because Prior-UZ/SZ prevent the gap conditions that U'/S' detect).
- Since {U, S, U', S'} is expressively complete for all linear orders (Stavi/GHR93), and U'/S' are vacuous on Prior structures, {U, S} suffices.
- Already implemented in `PriorExpressiveness.lean` (Phase 1 of plan v9, COMPLETED).

**Stage C: Model Surgery -- No Gaps (Lemmas 6-13, Theorem 14)**
- Define "contemporaneous equivalence": a ~_M b iff every subinterval of [a,b] is "good" (k-equivalent to some Z-interval).
- Define a temporal formula R (via Theorem 5) that detects where an equivalence class ends at a Dedekind gap.
- Prove structural properties of R-intervals (Lemmas 7-9).
- Define "bad points" and prove model surgery preserves temporal truth (Lemma 12).
- Derive contradiction: bad points cannot exist in Prior structures (Lemma 13).
- Conclude: no gaps in equivalence classes (Theorem 14).
- NOT YET IMPLEMENTED. This is the content of plan v9, Phases 2-4.

**Stage D: One-Class Theorem (Theorem 15)**
- From Theorem 14 (no gaps) + no_boundary_at_successor (trivial: [c, succ(c)] is finite, hence good): all points are contemporaneously equivalent.
- Already implemented in `GoodStructures.lean` as `one_class`, sorry-free modulo `no_gaps_discrete`.

**Stage E: Z-Interval Countermodel**
- One class implies the chronicle is "very good" (every subinterval is good).
- Very good implies good (via shift-and-glue, Reynolds Lemma 16). Already implemented in `ShiftAndGlue.lean`.
- Good means the chronicle is k-equivalent to some Z-interval structure.
- Transfer neg(phi) from chronicle to Z-interval via k-equivalence. Already implemented as `truth_transfer` in `Transfer.lean`.

**Stage F: Packaging as TaskFrame**
- This is where the two pipelines diverge (see Section 3 below).

---

## 2. The Conservative Extension is NOT the Missing Ingredient

### 2.1 What the Question Assumed

The research question asked whether the conservative extension / weak semantics approach provides a way around the Transfer.lean:1081 sorry. The implicit assumption was that Reynolds' approach involves extending the logic with additional operators that have "weak" semantics, and that this extension somehow makes the Z-interval-to-TaskFrame packaging work.

### 2.2 Why This is Not the Case

The conservative extension in the codebase (ExtFormula, ExtDerivation, etc.) is about the **irreflexivity rule** for modal logic, not about temporal operators or countermodel construction. It adds a fresh atom `q` to enable IRR-free axiomatization. This has nothing to do with the Transfer.lean:1081 sorry, which is about packaging a Z-interval ordered monadic structure as a `TaskFrame Int`.

The "weak semantics" is about using a **reflexive** canonical accessibility relation instead of an irreflexive one. This is a technique for the canonical model construction (Stage A above), not for countermodel packaging (Stage F).

Reynolds' completeness proof does not involve any "weak" temporal operators or modified truth conditions. The temporal connectives U and S have their standard semantics throughout. The innovation is in the model-theoretic argument (model surgery) that eliminates gaps in the contemporaneous equivalence classes.

### 2.3 What Reynolds Actually Constructs as a Countermodel

Reynolds constructs a countermodel as follows:

1. Build the chronicle (a Prior structure, Stages A-B).
2. Prove all points are in one equivalence class (Stages C-D).
3. Show the chronicle is k-equivalent to a Z-interval (Stage E).
4. Transfer the negation of phi to the Z-interval.

At this point, Reynolds has: a Z-interval structure (an ordered monadic structure whose carrier is Z or an interval thereof) where neg(phi) holds at some point.

**In the paper**, this IS the countermodel. Reynolds works in a purely temporal setting where a countermodel is just a linear order with a valuation. There is no TaskFrame, no WorldHistory, no ShiftClosed Omega, no box quantification over multiple histories. The paper's "model" is simply a linearly ordered set with truth values for atoms at each point.

**In this codebase**, the semantics uses `TaskFrame D` with `WorldHistory`, `ShiftClosed Omega`, and box quantification. This is a richer semantic framework that combines S5 modal logic with temporal logic. The Transfer.lean:1081 sorry exists because packaging a Z-interval (which is a purely temporal structure) as a TaskFrame (which has modal structure) is fundamentally nontrivial.

---

## 3. The Transfer.lean:1081 Sorry: Why It Is NOT Fundamentally Unsolvable, But IS Correctly Bypassed

### 3.1 What the Sorry Requires

At Transfer.lean:1081, `countermodel_discrete_reynolds` has completed steps 1-7 (chronicle extraction, monadic structure, goodness proof, k-equivalence, truth transfer to Z-interval). It needs to package the result as:

```
exists (D : Type) ... (F : TaskFrame D) (TM : TaskModel F)
    (Omega : Set (WorldHistory F)) (_ : ShiftClosed Omega)
    (tau : WorldHistory F) (_ : tau in Omega) (t : D),
    not (truth_at TM Omega tau t phi)
```

The existing attempt uses `zIntervalTaskFrame` with `WorldState = Unit`, `task_rel = fun _ _ _ => True`, and a singleton `Omega = {zIntervalHistory}`. Under these choices, box quantification is transparent (`truth_at (.box psi) = truth_at psi`) because there is only one history. The sorry is in constructing a `TaskModel` and proving the truth correspondence `truth_at ↔ temporal_truth`.

### 3.2 Why Previous Attempts Failed

The handoff document `phase-4-5-handoff-20260529b.md` (referenced in plan v9) explored five alternative TaskFrame constructions and all failed. The core tension is:

1. **Position-dependent atoms**: The Z-interval has different atoms true at different integer positions. A `TaskModel` needs to reflect this.
2. **ShiftClosed Omega**: If Omega is shift-closed and atoms depend on position, different shifts produce different truth values, requiring multiple histories.
3. **Box quantification**: With multiple histories, `truth_at (.box psi)` quantifies over all histories in Omega, which breaks the 1-1 correspondence with `temporal_truth` on the Z-interval.

The singleton-Omega approach avoids problem 3 but makes problem 1 harder: the `TaskModel`'s valuation must somehow encode position-dependent atoms through a single history with constant WorldState.

### 3.3 The `z_interval_countermodel` Theorem at Transfer.lean:446

The existing theorem `z_interval_countermodel` DOES work, but it requires the caller to provide:
- A `TaskModel` (TM)
- A truth correspondence hypothesis: `h_truth_corr : forall psi t, truth_at TM ... t psi <-> temporal_truth (Z.toOrdered sig) atomMap_fwd t psi`

The theorem statement says: IF you can build a TM satisfying h_truth_corr, THEN you get the full existential package. The sorry at line 1081 is in constructing such a TM and discharging h_truth_corr.

**Is this fundamentally unsolvable?** No. With `WorldState = Unit`, singleton Omega, and transparent box, the truth correspondence reduces to showing `truth_at TM ... t psi <-> temporal_truth ... t psi` for all temporal subformulas. The `TaskModel` needs a valuation `v : Atom -> Int -> Prop` such that `v a t = Z.interp (atomMap_fwd (.atom a)) t`. This IS constructible. The difficulty is purely in the Lean formalization -- the definitions of `truth_at` involve `WorldHistory`, `domain`, `states`, etc., and threading through these requires careful matching.

### 3.4 Why the Bypass is Correct Anyway

Even though the Reynolds pipeline sorry may not be "fundamentally unsolvable" in the absolute sense, the plan v9 hybrid approach is the correct strategy because:

1. **Path A already exists and works**: The parametric canonical model (`dd_countermodel_chronicle_discrete`) correctly handles TaskFrame packaging. Its only sorry is `succ_cofinal`.

2. **Reynolds model surgery proves `no_gaps_discrete`**: This gives `one_class`, which gives `succ_cofinal` (via the archimedean bridge).

3. **Once `succ_cofinal` is proved, Path A becomes sorry-free**: No new TaskFrame construction needed.

4. **The Reynolds pipeline sorry (Transfer.lean:1081) is NOT on the critical path**: Even if it could be fixed, it would be redundant -- Path A already provides the countermodel.

---

## 4. Detailed Codebase Infrastructure Analysis

### 4.1 Conservative Extension (`ConservativeExtension/`)

| File | Lines | Sorries | Purpose |
|------|-------|---------|---------|
| ExtFormula.lean | 353 | 0 | Extended formula type, embedding, freshness |
| ExtDerivation.lean | 288 | 0 | Extended proof system, axiom/derivation embedding |
| Substitution.lean | ~150 | 0 | sigma[q -> bot] substitution, axiom closure |
| Lifting.lean | 697 | 0 | Conservative extension theorem: F+ -> F lifting |

**Status**: Fully implemented, sorry-free. This infrastructure is used for the IRR-free axiomatization. It is NOT related to the discrete completeness sorry.

### 4.2 WeakCanonical: The Reynolds/Doets Pipeline

| File | Lines | Sorries | On Critical Path? |
|------|-------|---------|-------------------|
| ReflexiveCanonical.lean | ~250 | 0 | NO (not called by active pipeline) |
| TruthLemma.lean | varies | yes | NO |
| FrameProperties.lean | varies | 0 | NO |
| ChronicleExtraction.lean | 256 | 0* | NO (* carries succ_cofinal through domain_succ_archimedean) |
| MonadicFO.lean | varies | 0 | YES (used by EF games, good structures) |
| NEquivalence.lean | ~1100 | 0 | YES (k-equivalence framework) |
| OrderedSum.lean | varies | 0 | YES (Doets composition) |
| Table.lean | varies | 0 | YES (temporal-to-FO translation) |
| StaviConnectives.lean | ~500 | 0 | YES (Stavi U'/S' semantics) |
| PriorExpressiveness.lean | 395 | 0 | YES (Theorem 5, COMPLETED) |
| Transfer.lean | 1111 | 1 | NO (sorry at line 1081, dead pipeline) |

### 4.3 IntegerModel: The Core Mathematical Content

| File | Lines | Sorries | On Critical Path? |
|------|-------|---------|-------------------|
| GoodStructures.lean | ~900 | 1 | YES (`no_gaps_discrete` at line 842) |
| ReynoldsNoGaps.lean | 114 | 0 | YES (archimedean specialization, sorry-free) |
| ShiftAndGlue.lean | ~1000 | 0 | YES (very_good -> good, cofinal sequences) |

### 4.4 The Active Pipeline (Path A)

```
completeness_discrete (Completeness.lean:308)
  -> countermodel_discrete_enriched (Completeness.lean:222)
    -> dd_countermodel_chronicle_discrete (ChronicleToCountermodel.lean:3285)
      -> cantor_bfmcs_discrete (sorry-free)
      -> cantor_bfmcs_discrete_restricted_tc (needs succ_embed_surjective)
      -> cantor_bfmcs_discrete_restricted_fuc (needs succ_embed_surjective)
        -> succ_embed_surjective (needs IsSuccArchimedean)
          -> limitDomSubtype_isSuccArchimedean (needs succ_cofinal)
            -> succ_cofinal (SORRY)
```

### 4.5 How Reynolds Results Feed Into Path A (Plan v9 Hybrid)

```
no_gaps_discrete (GoodStructures.lean:842, SORRY -- phases 2-4 of plan v9)
  -> one_class (GoodStructures.lean:883, sorry-free modulo above)
    -> [bridge lemma: one_class_implies_succ_cofinal, plan v9 Phase 5]
      -> succ_cofinal (PROVED from one_class, no longer sorry)
        -> limitDomSubtype_isSuccArchimedean (now sorry-free)
          -> succ_embed_surjective (now sorry-free)
            -> dd_countermodel_chronicle_discrete (now sorry-free)
              -> countermodel_discrete_enriched (now sorry-free)
                -> completeness_discrete (now sorry-free)
```

---

## 5. What Remains To Be Done

### 5.1 The One Real Obstacle: `no_gaps_discrete`

The sole mathematical obstacle is proving `no_gaps_discrete` at `GoodStructures.lean:842`. This requires Reynolds Lemmas 6-13 and Theorem 14 (model surgery argument). Plan v9 allocates Phases 2-4 (estimated 15 hours, 950 lines) for this.

### 5.2 Phase Status

| Phase | Content | Status | Estimated Lines |
|-------|---------|--------|-----------------|
| 0 | Dead code cleanup | NOT STARTED | ~0 new Lean lines |
| 1 | Theorem 5 (US expressive completeness over Prior) | COMPLETED | 395 lines |
| 2 | Lemmas 6-9 (gap formula R, R-interval properties) | NOT STARTED | ~450 lines |
| 3 | Lemmas 10-13 (model surgery) | NOT STARTED | ~500 lines |
| 4 | Theorem 14 + close no_gaps_discrete | NOT STARTED | ~60 lines |
| 5 | Bridge one_class -> succ_cofinal, close Path A | NOT STARTED | ~100 lines |

### 5.3 The Conservative Extension is Irrelevant to This Work

The `ConservativeExtension/` infrastructure is already complete and is not involved in the discrete completeness sorry chain. It serves the IRR-free axiomatization, which is a separate concern. No work on conservative extensions is needed for task 202.

### 5.4 The "Weak Semantics" (Reflexive Canonical Model) is Also Irrelevant

The reflexive canonical model in `ReflexiveCanonical.lean` is part of the dead Reynolds pipeline (Path C). The active pipeline (Path A) uses the parametric canonical model from `Algebraic/ParametricCanonical.lean`. No work on weak semantics is needed.

---

## 6. Answers to the Research Questions

### Q1: Reynolds' completeness strategy for discrete linear temporal logic

Reynolds' strategy is: (A) build a chronicle (Prior structure), (B) prove {U,S} expressive completeness over Prior structures, (C) use model surgery to prove no gaps in equivalence classes, (D) derive one-class theorem, (E) show chronicle is k-equivalent to Z-interval, (F) transfer truth. The completeness proof is contrapositive: non-derivable implies non-valid.

### Q2: What is the conservative extension?

In this codebase, the conservative extension adds a fresh atom `q = Sum.inr ()` to enable IRR-free axiomatization. It does NOT add new temporal operators or modify semantics. It is already fully implemented and sorry-free. It is NOT related to the discrete completeness sorry.

### Q3: How does Reynolds construct countermodels?

Reynolds constructs a Z-interval structure (a linearly ordered set with predicate interpretations) via the chronicle -> good -> Z-interval pipeline. In the paper, this IS the countermodel. In this codebase, the countermodel must be a `TaskFrame`, which is more complex. The active pipeline (Path A) uses the parametric canonical model for TaskFrame packaging; the Reynolds pipeline (Path C) attempts direct Z-interval packaging but has an unresolved sorry.

### Q4: Existing codebase infrastructure

- Conservative extension: fully implemented, sorry-free, NOT on critical path
- WeakCanonical/: extensive infrastructure, mostly sorry-free
- IntegerModel/: `no_gaps_discrete` is the sole sorry (line 842)
- Dense completeness: works via separate chronicle pipeline
- Discrete completeness: blocked on `succ_cofinal`, which is blocked on `no_gaps_discrete`

### Q5: Is the Transfer.lean:1081 sorry "fundamentally unsolvable"?

No, it is not fundamentally unsolvable in the mathematical sense. A TaskModel with singleton Omega and transparent box CAN be constructed for the Z-interval. However, it is correctly bypassed because Path A (the parametric canonical model) already provides TaskFrame packaging -- it just needs `succ_cofinal`, which Reynolds' model surgery results provide. The hybrid approach (prove no_gaps_discrete via Reynolds, derive succ_cofinal, close Path A) is simpler and more robust than fixing Transfer.lean:1081 directly.

### Q6: Does Reynolds' conservative extension / weak semantics provide a way around Transfer.lean:1081?

**No.** The conservative extension is about IRR elimination, not countermodel packaging. The "weak semantics" is about reflexive canonical accessibility, not temporal operator interpretation. Neither has anything to do with the Z-interval-to-TaskFrame packaging problem. The correct path is plan v9: prove no_gaps_discrete via model surgery (Lemmas 6-13, Theorem 14), derive one_class, derive succ_cofinal, close Path A.
