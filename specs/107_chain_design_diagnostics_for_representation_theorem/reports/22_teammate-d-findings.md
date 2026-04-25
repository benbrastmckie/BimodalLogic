# Teammate D: Infrastructure Reuse Analysis

**Task**: 107 — Chain Design Diagnostics for Representation Theorem
**Focus**: Map sorry-free infrastructure, assess reusability under each path
**Date**: 2026-04-24

---

## 1. Infrastructure Map: Sorry-Free Line Counts

### Chronicle/ Directory (3,472 lines total)

| File | Total Lines | Sorry Count | Sorry-Free Status |
|------|-------------|-------------|-------------------|
| ChronicleTypes.lean | 467 | 0 | **CLEAN** |
| RRelation.lean | 471 | 0 | **CLEAN** |
| PointInsertion.lean | 558 | 0 | **CLEAN** |
| CounterexampleElimination.lean | 696 | 2 | PARTIAL (C4 hard sub-cases) |
| ChronicleConstruction.lean | 857 | 1 | PARTIAL (g_content_chain_property) |
| ChronicleToCountermodel.lean | 423 | 9 | HEAVY SORRY (Phase 5 wiring) |

**Summary**: 3,472 lines, 12 sorry sites.
- **2,054 lines fully sorry-free** (ChronicleTypes + RRelation + PointInsertion + large portions of others)
- **1,418 lines with sorry dependencies** (CounterexampleElim partial, Construction chain prop, Countermodel wiring)

### Parametric Infrastructure (1,723 lines total)

| File | Total Lines | Sorry Count | Sorry-Free Status |
|------|-------------|-------------|-------------------|
| ParametricCanonical.lean | 244 | 0 | **CLEAN** |
| ParametricHistory.lean | 173 | 0 | **CLEAN** |
| ParametricTruthLemma.lean | 531 | 0 | **CLEAN** |
| ParametricRepresentation.lean | 300 | 0 | **CLEAN** |
| RestrictedParametricTruthLemma.lean | 475 | 0 | **CLEAN** |

**Summary**: 1,723 lines, **zero sorry sites**. Entire parametric stack is proven.

### Transitive Sorry Dependencies

The 12 sorry sites have a dependency structure:

1. **Root sorry**: `g_content_chain_property` (ChronicleConstruction.lean:748) -- the omega-chain does not maintain g_content(f(x)) subset f(y) for x < y
2. **Dependent**: `limit_forward_G`, `limit_backward_H` depend on #1
3. **Dependent**: `chronicle_fmcs.forward_G` and `.backward_H` (ChronicleToCountermodel.lean:192,196) depend on #2
4. **Dependent**: `box_stable_in_chronicle_fmcs` (line 234) needs forward_G/backward_H
5. **Dependent**: `chronicle_bfmcs_restricted_tc` (line 320,323) -- F/P resolution
6. **Dependent**: `chronicle_bfmcs_restricted_buc` (line 342,345) -- backward Until/Since
7. **Dependent**: `chronicle_bfmcs_restricted_fuc` (line 374,377) -- forward Until/Since
8. **Independent root**: `eliminate_C4_counterexample` sub-case 1a (line 289) -- delta in both endpoints
9. **Independent root**: `eliminate_C4'_counterexample` sub-case 1a (line 355) -- mirror

**Key insight**: There are really only **3 independent sorry roots**:
- `g_content_chain_property` (cascades to 7 downstream sorry sites)
- C4 counterexample "both delta" sub-case (2 sorry sites, symmetric pair)

---

## 2. Venema 1993 Reuse Assessment

### What Venema's Approach Entails

Venema 1993 does NOT build chronicles at all. The proof strategy is:

1. Start with Burgess's completeness for linear orders (system **B** = our BX minus density/well-order axioms)
2. Add axiom **W**: `F(p) -> U(p, neg p)` (well-ordering axiom)
3. Show every **BW**-model is "definably well-ordered" (Lemma 4.1)
4. Use Doets's theorem: definably well-ordered linear models have n-equivalent well-ordered models (Theorem 3.8)
5. Transfer satisfiability from the Burgess linear model to a well-ordered model

**Critical observation**: Venema's approach presupposes Burgess's completeness theorem for linear orders as a black box (Theorem 3.5). The chronicle construction IS Burgess's completeness proof for linear orders. So Venema does NOT bypass chronicles -- it USES them as input.

For our project, Venema is relevant if we want to extend from linear orders to well-orders or omega. But our BX logic targets general linear temporal orders with S5 modality. Venema's axiom W is not in our system. His approach is **not applicable** as a replacement path.

### Reuse Under Venema

| File | Reuse | Notes |
|------|-------|-------|
| ChronicleTypes.lean | N/A | Venema requires Burgess completeness anyway |
| RRelation.lean | N/A | Same |
| PointInsertion.lean | N/A | Same |
| CounterexampleElimination.lean | N/A | Same |
| ChronicleConstruction.lean | N/A | Same |
| ChronicleToCountermodel.lean | N/A | Same |
| Parametric*.lean | **FULLY REUSABLE** | Framework-independent |

**Verdict**: Venema is NOT an alternative path. It is an extension that would sit ON TOP of a working Burgess construction. All chronicle code remains necessary. The parametric infrastructure would be reused regardless.

---

## 3. Modified Burgess Reuse Assessment

### What "Modified Burgess" Means

Fix the current construction by:
- Closing `g_content_chain_property`: ensure the omega-chain maintains g_content(f(x)) subset f(y) for all x < y in the growing domain
- Closing the C4 "both delta" sub-case: use g_content chain property to derive G(delta) not in f(x) when delta not in g(x,y) subset f(y)
- Closing the 9 ChronicleToCountermodel sorry sites: derive restricted coherence from chronicle properties

### File-by-File Assessment

| File | Lines | Status | Under Modified Burgess |
|------|-------|--------|----------------------|
| ChronicleTypes.lean | 467 | CLEAN | **Survives as-is** |
| RRelation.lean | 471 | CLEAN | **Survives as-is** |
| PointInsertion.lean | 558 | CLEAN | **Survives as-is** |
| CounterexampleElimination.lean | 696 | 2 sorry | **Mostly survives** -- C4 hard sub-case closes once g_content chain property is established |
| ChronicleConstruction.lean | 857 | 1 sorry | **Needs modification** -- omega_chain must be restructured to maintain g_content invariant |
| ChronicleToCountermodel.lean | 423 | 9 sorry | **Needs modification** -- wiring proofs close once chronicle properties hold |
| Parametric*.lean | 1,723 | CLEAN | **Survives as-is** |

### What Needs to Change in ChronicleConstruction.lean

The core issue is `g_content_chain_property`. Three approaches were analyzed (documented in lines 706-742 of ChronicleConstruction.lean):

1. **Enlarged seed**: BLOCKED (F(eta) does not propagate forward through g_content)
2. **Modified insertion position**: Breaks backward direction
3. **Duality bridge**: Proven (g_content_sub_imp_h_content_sub, lines 618-654), but does not fix the construction issue

The **recommended fix** (from the code comments, line 735-742) is a two-pass approach at each omega-chain step:
- Pass 1: Insert witness point via current C5 elimination
- Pass 2: At the same step, extend the witness MCS to include g_content of all predecessors via secondary Lindenbaum extension

This requires rewriting `eliminate_C5_counterexample` and `eliminate_C5'_counterexample` to use an enlarged seed that includes g_content from the correct predecessor, not just the triggering point.

**Estimated modification**: ~200-400 lines changed/added in ChronicleConstruction.lean, ~50-100 lines in CounterexampleElimination.lean.

---

## 4. Parametric Infrastructure Compatibility

### The Interface

The parametric infrastructure (`Algebraic/Parametric*.lean` + `RestrictedParametricTruthLemma.lean`) provides:

- `BFMCS D` -- Bundled Family of MCS over duration type D
- `ParametricCanonicalTaskFrame D` -- Canonical TaskFrame
- `ParametricCanonicalTaskModel D` -- Canonical TaskModel
- `parametric_shifted_truth_lemma` -- MCS membership iff semantic truth
- `restricted_parametric_representation_from_neg_membership` -- Countermodel from neg-membership

The interface requires a `BFMCS Rat` satisfying:
1. `restricted_temporally_coherent root` -- F/P resolution within deferralClosure
2. `restricted_backward_until_since_coherent root` -- backward Until/Since
3. `restricted_forward_until_since_coherent root` -- forward Until/Since

### Compatibility with Modified Burgess

**Fully compatible**. The `ChronicleToCountermodel.lean` file already constructs `chronicle_bfmcs : BFMCS Rat` and attempts to prove the three restricted coherence conditions. The sorry sites are exactly the three coherence proofs plus their dependencies. Once the chronicle is fixed, these proofs complete the pipeline.

The architecture is:
```
chronicle construction (modified)
  -> limit_dom, limit_f (sorry-free core)
  -> g_content_chain_property (CLOSE THIS)
  -> chronicle_fmcs.forward_G/backward_H (follows)
  -> chronicle_bfmcs (BFMCS Rat)
  -> restricted coherence proofs (follow from chronicle properties)
  -> dd_countermodel_chronicle (plugs into ParametricRepresentation)
```

### Compatibility with Venema

As analyzed in Section 2, Venema does not bypass Burgess -- it layers on top. The parametric infrastructure would still be used via the same `BFMCS Rat -> ParametricRepresentation` pipeline. No incompatibility, but no savings either.

---

## 5. Cost Estimation

### Path A: Modified Burgess (Fix Current Construction)

| Category | Lines | Confidence |
|----------|-------|------------|
| **NEW code** (omega-chain invariant maintenance, enlarged seeds, two-pass elimination) | 300-500 | Medium |
| **MODIFIED code** (ChronicleConstruction.lean omega_chain, CounterexampleElimination.lean seeds) | 200-400 | Medium |
| **WASTED code** | 0 | High |
| **Reused as-is** | ~3,700 (all CLEAN code) | High |

**Net effort**: 500-900 new/modified lines. Estimated 20-40 hours.

**Key risk**: The g_content_chain_property fix may be harder than estimated. Three approaches have already been evaluated and found wanting (enlarged seed blocked, modified insertion position breaks backward). A fourth approach (two-pass with secondary Lindenbaum) is proposed but unproven. If this also fails, the cost could double.

### Path B: Venema Replacement

**Not viable as a replacement**. Venema uses Burgess completeness (our chronicle) as a black box. Would require:
- Everything in Path A (fix the chronicle construction)
- Additional ~500-1000 lines for well-ordering extension (axiom W, definable well-ordering, Doets theorem)
- No savings on current sorry sites

**Net effort**: Path A + 500-1000 additional lines for an orthogonal extension.

### Path C: Abandon Chronicle, Use Alternative Model Construction

This would mean replacing the Burgess chronicle approach entirely with a different model construction for linear temporal logic with Since and Until. Known alternatives:

1. **Gabbay-Hodkinson 1990**: Uses irreflexivity rule (non-orthodox). Would require adding IR to the proof system -- fundamental architectural change.
2. **Schedule-based chain** (existing `RootScopedChain.lean`): Has its own sorry sites for the same g_content propagation issue. Not a genuine alternative.
3. **Direct induction on formula complexity**: Standard approach for simple temporal logics, but Until/Since with their interval semantics make this extremely difficult without chronicle-like infrastructure.

**Verdict**: No viable alternative to the Burgess chronicle approach. Path A (Modified Burgess) is the only productive direction.

---

## 6. Summary Table

| Metric | Modified Burgess | Venema | Abandon/Replace |
|--------|-----------------|--------|-----------------|
| New lines | 300-500 | 800-1500 | 2000+ |
| Modified lines | 200-400 | 200-400 | N/A (rewrite) |
| Wasted lines | 0 | 0 | 2,000+ |
| Reused lines | ~3,700 | ~3,700 | ~1,723 (parametric only) |
| Risk | Medium (g_content fix uncertain) | High (all of Path A + more) | Very High |
| Confidence | Medium | Low | Very Low |

**Recommendation**: Modified Burgess is the only viable path. Focus all effort on closing `g_content_chain_property` -- this is the single root cause that cascades to 10 of the 12 sorry sites.

---

## 7. Confidence Level

**Medium confidence** in the Modified Burgess assessment. The uncertainty centers on whether the two-pass Lindenbaum approach for g_content chain maintenance actually works. The duality bridge (g_content(A) subset B iff h_content(B) subset A) is proven and available, which means only the forward direction needs direct construction. But three prior attempts at closing g_content_chain_property have failed, suggesting the problem is genuinely subtle.

The infrastructure mapping and sorry counts are **high confidence** -- these are direct observations from the codebase.
