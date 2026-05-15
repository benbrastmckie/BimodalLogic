# Teammate B Findings: Alternative Approaches for Mixed-Case Countermodel

**Task**: 142 - mixed_case_countermodel
**Date**: 2026-05-15
**Teammate**: B (Alternative Approaches)
**Confidence Level**: Medium (overall)

---

## Alternative 1: Mosaic Method (Caleiro-Vigano-Volpe 2013)

### Description

The Caleiro-Vigano-Volpe paper treats exactly the combination of linear tense operators (G, H, F, P, U, S) with an orthogonal S5-like path quantifier (forall/exists). Their approach builds "vertical" (temporal) and "horizontal" (modal) mosaics. A mosaic is a pair of formula sets (points) satisfying local coherence conditions. A saturated set of mosaics (SSM) is equivalent to the existence of a model.

Their completeness proof (Theorem 3.13) works by:
1. Starting from an SSM for Gamma
2. Building a chronicled frame step-by-step via defect elimination (curing vertical/horizontal defects)
3. Taking the omega-limit to obtain the final structure
4. The structure is a C-D-frame with a chronicle, from which a model is extracted

### Feasibility Assessment

**Relevance to our problem**: The Caleiro approach handles general linear time (class C = ()) without density/discreteness assumptions. Their base construction (D = (), no interaction axioms) works for ALL linear orders. This is directly relevant because:

- Their logic L(C, (Dsj+Wdc+Mb)) with C = () corresponds to bundled Ockhamist frames on arbitrary linear orders
- Our TaskFrame semantics is closely related to Kamp frames / Ockhamist frames
- The equivalence ≃ in their framework corresponds to our box/diamond quantification over histories in Omega

**Critical gap**: Their paper explicitly notes (Section 2, paragraph on T×W frames) that their Ockhamist frames differ from T×W frames (Thomason 1984) in that Ockhamist frames have multiple independent timelines, while T×W frames have a single linear order synchronized across branches. Our TaskFrame semantics is closer to T×W: all histories share the same temporal domain D. The Caleiro construction builds a frame where DIFFERENT branches (≃-classes) can have DIFFERENT linear order structures. This is exactly what we need for the mixed case (some branches dense, others discrete), but the resulting model would NOT be a TaskFrame model where all histories share domain D.

**Interaction axioms**: Their BX-like axioms fall under the "interaction properties" (Wdc, Sdc, Mb). The paper states (Section 1): "Though our mosaic definitions do not lead to a proof of decidability when interactions between the vertical and horizontal components are considered, they still allow for giving non-analytic but interesting tableau systems." For the full Ockhamist logic with interactions, they achieve completeness (Theorem 3.13) but NOT decidability. Our BX axioms (AK12: box(Pp) -> P(box(p)), etc.) are interaction axioms, so the mosaic method's power may be limited here.

**Codebase alignment**: The existing codebase has no mosaic infrastructure. Building it would require:
- New definitions for vertical/horizontal mosaics
- Saturation conditions
- Defect elimination procedure
- Omega-limit construction
- Extraction of TaskFrame model from the mosaic structure

The fundamental problem remains: the mosaic construction produces a frame where different ≃-classes can live on different linear orders, but TaskFrame requires a single domain type D.

### Estimated Effort
80-120 hours (essentially a parallel proof architecture)

### Blockers/Risks
- **Critical**: The mosaic construction does NOT produce a TaskFrame model directly. The model it builds has heterogeneous temporal structures across branches.
- **High**: Massive new infrastructure with no existing codebase support
- **Medium**: Interaction axiom handling is only partially developed in the paper

### Confidence Level: **Low**

The mosaic method is mathematically elegant but architecturally incompatible with the existing TaskFrame/BFMCS infrastructure.

---

## Alternative 2: Eliminate the Three-Way Split (Universal Construction)

### Description

Instead of splitting Dense/Discrete/Mixed, build a SINGLE construction that works for ANY MCS A, regardless of F'T/U(T,bot) membership. The Burgess chronicle construction for the base logic J0 works on arbitrary linear orders.

### Feasibility Assessment

**Chronicle construction analysis**: Reading `ChronicleConstruction.lean`, the Burgess omega-chain construction:
- Starts from `singleton_chronicle A` at rational 0 (line 64)
- Lives entirely in Rat (`limit_dom : Set Rat`, line 551)
- `limit_f : Rat -> Set Formula` is defined for ALL rationals (line 560)
- `limit_forward_G` (line 1035) and `limit_backward_H` (line 1089) hold for all domain points

**Key observation**: The chronicle construction itself is UNIVERSAL -- it works for any MCS A. The density/discreteness split only arises when we try to build a Cantor isomorphism (`cantor_iso_dense`, line 223 of ChronicleToCountermodel.lean), which requires `DenselyOrdered (LimitDomSubtype A h_mcs)`.

**Why the split was introduced**: The problem is mapping `limit_dom` (a countable subset of Rat) onto ALL of Rat (or all of Int). For dense chronicles, `LimitDomSubtype ≃o Rat` via Cantor's theorem. For discrete chronicles, the succ-based embedding maps to Int. But neither mapping works for the "other" type.

**Could we use limit_dom directly as D?**

The sorry signature requires:
```lean
∃ (D : Type) (_ : AddCommGroup D) (_ : LinearOrder D) (_ : IsOrderedAddMonoid D)
  (_ : Nontrivial D) ...
```

`LimitDomSubtype A h_mcs` is a subtype of Rat. It has:
- `LinearOrder`: inherited from Rat (yes)
- `Nontrivial`: has 0 and at least one other point (yes)
- `AddCommGroup`: **NO**. If x, y are in limit_dom, x + y need not be in limit_dom
- `IsOrderedAddMonoid`: requires AddCommGroup (no)

**Could we embed limit_dom into Rat and use Rat?** Yes, limit_dom is already in Rat. But the issue is that `limit_f` is only defined on `limit_dom`, not all of Rat. For the FMCS we need `mcs : Rat -> Set Formula` satisfying forward_G for ALL rationals, not just domain points.

This is exactly the gap-filling problem that the 01 report identified. The universal construction approach reduces to: "how do we extend limit_f from limit_dom to all of Rat while preserving coherence?"

**The deep mathematical issue**: For a DISCRETE chronicle with U(T,bot), the limit domain has gaps (consecutive points with no points between). Filling these gaps with valid MCS values while maintaining forward_G is non-trivial because G(phi) at a gap point requires phi at ALL future points, including other gap points. See Section 4.3-4.5 of the 01 report for the detailed analysis of why naive gap-filling fails.

### Estimated Effort
This IS the primary approach (Teammate A's territory). From our perspective: the universal construction is the right direction but the gap-filling problem is the hard part.

### Blockers/Risks
- Gap-filling for discrete limit domains while preserving forward_G
- Need to define MCS values at non-domain rationals consistently

### Confidence Level: **Medium-High** (as a direction, not as an immediate solution)

---

## Alternative 3: Product/Coproduct Domain

### Description

Use D = Rat x Int, D = Rat ⊕ Int, or a more sophisticated ordered sum as the universal domain.

### Feasibility Assessment

**Option A: D = Rat x Int (Product)**

Lean/Mathlib provides `Prod.instAddCommGroup` and `Prod.instLinearOrder` for product types. However:
- `Rat x Int` with lexicographic ordering is a linear order with AddCommGroup
- The problem: `ShiftClosed Omega` requires time-shifting histories by arbitrary D-values. With D = Rat x Int, shifts are pairs (q, n), which is awkward for temporal reasoning
- More fundamentally, the TaskFrame semantics interprets "future" as d > 0 in the domain D. With lex product, (0, 1) > (0, 0) and (-epsilon, 0) < (0, 0), giving a timeline that interleaves rational and integer dimensions in a non-standard way
- `Nontrivial` holds trivially

**Option B: D = Rat ⊕ Int (Coproduct/Sum)**

Lean/Mathlib provides `Sum.instLinearOrder` for `Sum α β` with lex ordering (all of α before all of β). But:
- `Sum Rat Int` with lex would put ALL rationals before ALL integers -- not useful
- No natural AddCommGroup on `Sum Rat Int`
- Even with a custom ordering, the algebraic structure doesn't compose well

**Option C: Ordered Sum (Doets-style)**

Reading `WeakCanonical/OrderedSum.lean` (lines 1-76):
- `doets_lemma_1_4` is sorried (depends on EF-game formalization)
- `doets_lemma_1_5` is sorried (bypassed for discrete case)
- The ordered sum infrastructure works at the level of `OrderedMonadicStructure`, not `TaskFrame`
- These theorems preserve k-equivalence, which is useful for truth transfer but doesn't directly produce a TaskFrame

**The fundamental algebraic problem**: ANY choice of domain D must have `AddCommGroup D` and `LinearOrder D` with `IsOrderedAddMonoid D`. The standard choices satisfying all of these are:
- Rat (dense, ordered field)
- Int (discrete, ordered ring)
- Real (dense, ordered field)
- Subgroups of the above

Product types like `Rat x Int` satisfy these but create awkward temporal semantics. Custom types would need proofs of all algebraic properties from scratch.

**Observation from `ParametricCanonicalTaskFrame`** (ParametricCanonical.lean:198): The TaskFrame is PARAMETRIC in D. It works for any D satisfying the constraints. The task_rel is based on `ExistsTask` which depends on MCS properties, not on D specifically. This means the FRAME doesn't care about D -- only the HISTORIES and TRUTH EVALUATION care about the temporal ordering.

### Estimated Effort
40-60 hours for product approach, 60+ hours for custom ordered sum approach

### Blockers/Risks
- **Critical for Coproduct**: No natural AddCommGroup
- **High for Product**: Awkward temporal semantics with 2D time
- **High for Ordered Sum**: Existing infrastructure is sorried, operates at wrong abstraction level

### Confidence Level: **Low**

Product/coproduct approaches introduce complexity without solving the core gap-filling problem.

---

## Alternative 4: Doets-Style Transfer (Reynolds Pipeline)

### Description

The discrete case uses a Reynolds/Doets pipeline: extract a chronicle, prove it's "good", then transfer truth to a Z-model via k-equivalence. Could a similar pipeline work for the mixed case?

### Feasibility Assessment

**Existing pipeline** (Transfer.lean):
- Chronicle extraction from MCS with box(next_top) (discrete case)
- `chronicle_is_good` proved via `one_class` + `very_good_implies_good`
- The pipeline produces a ZStructure (carrier = Int) with k_equiv to the chronicle
- Truth transfer via k-equivalence (still has sorries in `k_type_of`)

**Could this work for mixed case?**

The Reynolds pipeline assumes the chronicle satisfies specific properties:
1. Countable discrete order without endpoints
2. Prior-UZ/SZ valid everywhere (discreteness axioms)
3. Gap elimination (no definable equivalence partitions)

For the MIXED case:
- The root MCS A has NEITHER box(F'T) NOR box(U(T,bot))
- By MCS completeness, A has either F'T or U(T,bot) (but not boxed)
- A's chronicle may be dense or discrete locally, but box-equivalent MCS's have MIXED density

**The k-equivalence approach**: Doets Lemma 1.4 says k-equivalence is preserved by ordered sums. If we decompose the mixed chronicle into intervals (some dense, some discrete), we could replace each interval with a k-equivalent standard interval (from Rat or Int) and glue them together. The resulting ordered sum would be k-equivalent to the original.

**Problem**: The ordered sum would be a custom linear order, not Rat or Int. We'd still need D with AddCommGroup, which ordered sums of Rat and Int intervals don't naturally have.

**The deeper issue**: The Reynolds pipeline targets a SPECIFIC domain (Int). The Doets machinery proves that truth is preserved under replacement of k-equivalent components. But the TARGET must already be determined. For the mixed case, the target would be a mixed linear order -- and we don't have a standard choice.

### Estimated Effort
50-70 hours (requires completing OrderedSum sorries + building mixed pipeline)

### Blockers/Risks
- **Critical**: OrderedSum.lean has sorried key theorems (doets_lemma_1_4, 1_5)
- **Critical**: No standard domain D to target
- **High**: k_type_of itself is sorried in NEquivalence.lean
- **Medium**: The existing pipeline has several sorry-propagation paths

### Confidence Level: **Low**

The Doets pipeline is powerful but not ready (too many upstream sorries) and doesn't resolve the domain type problem.

---

## Alternative 5: Weaken the Existential (Custom Domain D)

### Description

The conclusion is existential: ∃ D ... ¬truth_at. We don't need D = Rat or D = Int. We could define a CUSTOM type D.

### Feasibility Assessment

**Minimal requirements on D** (from TaskFrame.lean:93):
```lean
structure TaskFrame (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
```

Plus `Nontrivial D` from the sorry signature.

**Option A: D = Rat (the simplest)**

Rat is the most natural universal domain because:
1. `limit_dom` is already a subset of Rat (the chronicle construction lives in Rat)
2. `AddCommGroup Rat`, `LinearOrder Rat`, `IsOrderedAddMonoid Rat`, `Nontrivial Rat` all hold
3. The dense case already uses D = Rat successfully

The ONLY problem: for discrete box-equivalent MCS's N, we can't build a Cantor isomorphism because N's limit domain is not dense.

But we CAN still define `mcs : Rat -> Set Formula` for a discrete chronicle by:
- Embedding the discrete limit domain into Rat (it's already there!)
- Extending to all of Rat via some gap-filling strategy

This is the gap-filling-on-Rat approach (Teammate A's territory). The key insight: the FMCS forward_G and backward_H conditions are EASIER to satisfy than full truth correctness. We only need the RESTRICTED truth lemma, which tracks formulas in `deferralClosure(phi)`.

**Option B: D = custom subgroup of Rat**

Define D as the subgroup of Rat generated by all limit domain points across all box-equivalent MCS's. This would be a countable additive subgroup of Rat. Every countable subgroup of Rat is either:
- Dense in Rat (if it contains rationals with unbounded denominators)
- Isomorphic to Z (if it's cyclic)
- Some intermediate subgroup

For the mixed case, the generated subgroup would likely be dense (since it contains points from dense chronicles). So D would be isomorphic to Rat anyway, making this equivalent to Option A.

**Option C: D = OrderDual Int or other standard type**

Int suffices for the discrete case. Could we use Int for the mixed case too? For dense box-equivalent MCS's N with F'T, N's chronicle has a dense limit domain. We'd need to embed a dense countable order into Int, which is impossible (Int is discrete).

So D = Int doesn't work for the mixed case either.

**Option D: D = Rat with a "lazy" BFMCS**

Key insight from `BFMCS.lean` (line 84-98): The BFMCS requires:
- `families : Set (FMCS D)` -- a SET of families
- `modal_forward` / `modal_backward` -- coherence conditions

What if we build a BFMCS on Rat where:
- Dense families use the existing `rooted_cantor_fmcs_dense` (works)
- Discrete families use a gap-filled FMCS on Rat (needs new infrastructure)

The gap-filled FMCS for a discrete MCS N would:
1. Build N's chronicle (limit domain in Rat)
2. Embed the discrete limit domain into Rat (it's already there)
3. For rationals NOT in limit_dom, assign MCS values from the "nearest" domain point
4. Prove forward_G for the extended assignment

This is feasible IF the gap-filling preserves the restricted truth conditions. The restricted truth lemma (`RestrictedParametricTruthLemma.lean`) only needs:
- `B.restricted_temporally_coherent root` -- temporal coherence for formulas in `deferralClosure(root)`
- forward_G/backward_H for formulas in the deferral closure

**Critical question**: Does the gap-filling need to preserve truth for ALL formulas, or only for `deferralClosure(phi)`?

Answer: Only `deferralClosure(phi)`. The restricted truth lemma at line 104 takes `h_rtc : B.restricted_temporally_coherent root` and `h_sub : φ ∈ subformulaClosure root`. So we only need coherence for the subformula closure of the target formula.

This means: for a discrete chronicle whose limit domain has gaps, we can fill the gaps with MCS values that are "wrong" for U(T,bot) and F'T but "correct" for all formulas in `deferralClosure(phi)` (assuming U(T,bot) and F'T are NOT in the deferral closure).

**BUT**: What if U(T,bot) IS in `deferralClosure(phi)`? Then we'd need correct truth values for U(T,bot) at gap points, which is impossible in a dense model.

**Escape hatch**: If phi does NOT contain U(T,bot) as a subformula, the gap-filling works. If phi DOES contain U(T,bot), then... we need a different approach. However, the key insight from the 01 report (Section 3.3): U(T,bot) = Until(top, bot). This would be in deferralClosure(phi) only if phi has Until(top, bot) as a subformula. For the completeness theorem, phi is arbitrary, so we can't exclude this case.

**Further escape**: Even if U(T,bot) is in deferralClosure(phi), the restricted truth lemma only needs F-resolution for formulas in deferralClosure(phi). For U(T,bot), F-resolution at a gap point q means: if F(U(T,bot)) in mcs(q), there exists q' > q with U(T,bot) in mcs(q'). If we ensure the gap-filled MCS at q doesn't have F(U(T,bot)), this is vacuously satisfied. But MCS completeness means either F(U(T,bot)) or G(neg(U(T,bot))) is in every MCS...

This gets complicated. The key technical question is whether the gap-filling can satisfy the RESTRICTED temporal coherence conditions for the FULL subformula closure of any phi.

### Estimated Effort
20-40 hours (for D = Rat with gap-filling, building on existing infrastructure)

### Blockers/Risks
- **Medium-High**: Gap-filling must preserve restricted temporal coherence
- **Medium**: Need to handle the case where U(T,bot) is in deferralClosure(phi)
- **Low**: All algebraic infrastructure for Rat already exists

### Confidence Level: **Medium-High**

D = Rat with gap-filling is the most promising alternative. It aligns with existing infrastructure and avoids new algebraic machinery.

---

## Final Ranking

| Rank | Alternative | Confidence | Effort | Feasibility |
|------|------------|------------|--------|-------------|
| 1 | **Alt 5D: D = Rat with gap-filled BFMCS** | Medium-High | 20-40h | Most promising. Builds on existing Rat infrastructure. Gap-filling is the core technical challenge. |
| 2 | **Alt 2: Universal construction (eliminate split)** | Medium-High | 30-50h | Same underlying idea as Alt 5D. The three-way split is an artifact of the formalization. |
| 3 | **Alt 4: Doets-style transfer** | Low | 50-70h | Powerful but too many upstream sorries. Not ready for mixed case. |
| 4 | **Alt 3: Product/Coproduct domain** | Low | 40-60h | Awkward algebraic structure. Doesn't solve core problem. |
| 5 | **Alt 1: Mosaic method** | Low | 80-120h | Architecturally incompatible with TaskFrame/BFMCS. |

## Key Insight

All approaches converge on the same core technical challenge: **defining `mcs : Rat -> Set Formula` for a discrete chronicle such that the RESTRICTED temporal coherence conditions hold for `deferralClosure(phi)`**.

The most promising path is D = Rat with gap-filling, which:
1. Reuses all existing Rat infrastructure (AddCommGroup, LinearOrder, etc.)
2. Reuses the Burgess chronicle (which already lives in Rat)
3. Only needs to solve the gap-filling problem for discrete families
4. Can exploit the restricted truth lemma to avoid full coherence

The critical open question is: can gap-filling preserve restricted temporal coherence for formulas in `deferralClosure(phi)` when phi contains Until(top, bot) as a subformula? If yes, the solution is 20-40 hours. If no, we need a deeper analysis of which formulas can appear in deferralClosure and whether a case split on phi's structure is viable.
