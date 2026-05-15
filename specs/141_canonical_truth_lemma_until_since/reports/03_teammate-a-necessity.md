# Research Report: Task #141 -- Architectural Necessity Analysis

**Task**: 141 -- Canonical truth lemma Until/Since and ReflexiveCanonical infrastructure
**Date**: 2026-05-14
**Mode**: Teammate A -- Necessity and architectural path analysis

## Key Findings

### 1. The WeakCanonical truth_lemma Is NOT Architecturally Necessary

The `WeakCanonical.truth_lemma` is defined but **never called** by any theorem outside `TruthLemma.lean`. Specifically:

- `bx_completeness` (Completeness.lean:129) calls `doets_countermodel_discrete` for the discrete case.
- `doets_countermodel_discrete` (Transfer.lean:110-136) immediately falls back to `dd_countermodel_chronicle_discrete` (the Burgess chronicle construction).
- `dd_countermodel_chronicle_discrete` (ChronicleToCountermodel.lean:3285-3312) uses the **parametric truth lemma** via `fully_restricted_parametric_representation_from_neg_membership`, not the WeakCanonical truth lemma.
- The parametric truth lemma (ParametricTruthLemma.lean:337-372) handles Until/Since via `h_fuc`/`h_buc` (forward/backward Until/Since coherence), which are properties of the BFMCS constructed from the Burgess chronicle -- NOT from the ReflCanDomain model.

**Zero consumers**: `grep -rn "WeakCanonical.truth_lemma\|WeakCanonical.reflCanTruth"` across the entire codebase returns zero hits outside `TruthLemma.lean` itself.

### 2. reflCanR_linear Is NOT Currently Consumed

`grep -rn "reflCanR_linear"` returns only its definition at `ReflexiveCanonical.lean:134`. No theorem, lemma, instance, or definition anywhere references it.

### 3. The Sorries DO NOT Block bx_completeness (Verified)

Verification via `lean_verify`:
- `bx_completeness` has `sorryAx` -- but it comes from OTHER sources
- `dd_countermodel_chronicle_discrete` has `sorryAx` -- from `succ_cofinal` (ChronicleToCountermodel.lean:1514), NOT from WeakCanonical
- `doets_countermodel_discrete` has `sorryAx` -- inherited from `dd_countermodel_chronicle_discrete`

The sorry chain for the discrete branch is:
```
bx_completeness
  -> doets_countermodel_discrete (WeakCanonical/Transfer.lean)
    -> dd_countermodel_chronicle_discrete (Chronicle/ChronicleToCountermodel.lean)
      -> cantor_bfmcs_discrete_restricted_tc
        -> succ_embed_surjective
          -> limitDomSubtype_isSuccArchimedean
            -> succ_cofinal  <-- THIS IS THE SORRY (line 1514)
      -> cantor_bfmcs_discrete_restricted_fuc
        -> succ_embed_surjective (same dependency)
```

Additionally, `existsTask_transitive` (Bundle/CanonicalFrame.lean:259) has a trivially fixable sorry (`sorry /- BX: derive temp_4 from BX1 -/` should be `DerivationTree.axiom [] _ (Axiom.temp_4 phi)`). This contributes to sorry contamination but is NOT task 141 scope.

### 4. The TODO.md Sorry Count Is INCORRECT

TODO.md claims "14 sorries remain on bx_completeness critical path" and lists "6 in TruthLemma.lean (Until/Since -- task 141), 2 in ReflexiveCanonical.lean (reflCanR_linear, canS5R_symm -- task 141)" as being on the critical path.

**This is wrong.** None of the 7 remaining WeakCanonical sorries (1 in ReflexiveCanonical + 6 in TruthLemma) are on the `bx_completeness` critical path. They are dead code with respect to the completeness theorem.

The ACTUAL critical path sorries for the discrete branch are:
1. `succ_cofinal` (ChronicleToCountermodel.lean:1514) -- the SuccArchimedean gap
2. `succ_embed_squeeze` boundary case (ChronicleToCountermodel.lean:1297) -- related to succ_cofinal
3. `existsTask_transitive` (Bundle/CanonicalFrame.lean:259) -- trivially fixable

### 5. Even the Reynolds Pipeline Will NOT Need the WeakCanonical Truth Lemma

Transfer.lean comments (lines 96-105) describe the Reynolds pipeline's truth transfer as going through:
1. `chronicle_is_good` (k-equivalence to Z-structure)
2. `table` correctness (monadic FO satisfaction, task 140)
3. Z-model packaging as TaskFrame Int

This path uses the **parametric truth lemma**, not the WeakCanonical truth lemma. The monadic FO truth transfer layer (Table.lean, task 140) operates at a completely different abstraction level from the ReflCanDomain MCS-membership model.

## Architectural Analysis

### The WeakCanonical Module's Actual Purpose

The WeakCanonical module serves as:

1. **ChronicleExtraction.lean**: Extracts the Burgess chronicle as a `ChronicleAsPriorModel` with Corollary 3 conditions. This IS used (by the Reynolds pipeline comments, but not yet activated).

2. **FrameProperties.lean**: Proves Z1, Prior-UZ/SZ, seriality in the canonical frame. These are correct theorems but currently unused since the pipeline falls back to the chronicle.

3. **NEquivalence.lean / OrderedSum.lean / IntegerModel.lean / Table.lean**: The Reynolds compression pipeline (tasks 139/140). These ARE the architecturally important parts.

4. **ReflexiveCanonical.lean + TruthLemma.lean**: A SECOND truth lemma alongside the parametric truth lemma. This is architecturally redundant. The parametric truth lemma already handles all formula cases including Until/Since via BFMCS coherence properties.

### Why Two Truth Lemmas Exist

The parametric truth lemma (Algebraic module) works with BFMCS families on a fixed domain D (like Int). It requires three coherence conditions:
- Temporal coherence (TC): F(phi) in mcs(t) implies witness exists
- Forward Until/Since coherence (FUC): U(phi,psi) in mcs(t) implies witness+guard
- Backward Until/Since coherence (BUC): contrapositive of FUC

These conditions are proved for `cantor_bfmcs_discrete` using the chronicle's C4/C5 properties (sorry-free) plus `succ_embed_surjective` (sorry via succ_cofinal).

The WeakCanonical truth lemma works with `ReflCanDomain` (MCS as a type) and `reflCanTruth` (a recursive semantic function). It attempts to prove truth directly by structural induction on formulas. The Until/Since cases fail because the g_content-based relation lacks the interval structure that Burgess chronicles provide.

The parametric approach is strictly more powerful: it factors the Until/Since truth through explicit coherence hypotheses that the chronicle construction can discharge, while the direct ReflCanDomain approach tries to prove everything from scratch and hits a structural wall.

### The Correct Architectural Path to Sorry-Free bx_completeness

The path is through the **BXCanonical/Chronicle** construction, NOT through WeakCanonical truth lemma:

**Discrete branch** (the one task 141 targets):
1. Fix `succ_cofinal` (ChronicleToCountermodel.lean:1514) -- this eliminates the sorry in `limitDomSubtype_isSuccArchimedean`, which unblocks `succ_embed_surjective`, which unblocks TC+FUC for `cantor_bfmcs_discrete`, which makes `dd_countermodel_chronicle_discrete` sorry-free.
2. Fix `existsTask_transitive` (1-line fix, Bundle/CanonicalFrame.lean:259).
3. The WeakCanonical truth lemma sorries are irrelevant to this path.

**Dense branch**: `dd_countermodel_chronicle_dense` has its own sorry chain through Cantor iso and density. Separate from task 141.

**Mixed branch**: `dd_countermodel_chronicle_mixed_sorry` is a full sorry. Task 142.

## Mathematical Necessity

### Is reflCanR_linear Mathematically True?

**Yes.** The canonical temporal frame IS linear (connected). This follows from BX11 (temp_linearity): `F(neg psi) AND F(neg chi) -> F(neg psi AND chi) OR F(neg chi AND psi)`. The proof sketch in the codebase comments is correct:
1. Assume tempR_fwd x y and tempR_fwd x z but not tempR_fwd y z and not tempR_fwd z y.
2. Get witnesses from non-inclusion of g_contents.
3. Derive F(neg psi) and F(neg chi) at x.
4. Apply BX11 to force ordering, contradiction.

The proof is ~50 lines and uses only sorry-free infrastructure. But it has no downstream consumer.

### Should the WeakCanonical Truth Lemma Hold?

**The atom/bot/imp/box/G/H cases are already proved sorry-free.** These are the standard MCS truth lemma cases.

**The Until/Since cases CANNOT hold in the current ReflCanDomain model** (as demonstrated in the 02_openguard-blocker-research report). The fundamental issue is that `tempR_fwd` (g_content inclusion) lacks the interval structure needed for the Until guard condition. This is not a missing lemma -- it is a structural mismatch between the model and the proof technique.

If a truth lemma for Until/Since is desired for the ReflCanDomain, the model would need to be enriched with chronicle-like gap-content structure (essentially reimplementing Burgess inside ReflCanDomain). This would provide no benefit over the existing chronicle construction.

### Are There "Nearby Alternatives That Are True"?

**Yes, for reflCanR_linear**: The theorem is true and provable with existing infrastructure.

**For the Until/Since truth lemma**: The "nearby alternative" is the **parametric truth lemma** (ParametricTruthLemma.lean), which IS sorry-free for all cases INCLUDING Until/Since. It operates at a different abstraction level (BFMCS families with explicit coherence conditions) but serves the same architectural purpose (connecting MCS membership to semantic truth). The parametric truth lemma IS the correct formalization of the Until/Since truth correspondence for this project.

## Recommended Path

### Immediate Actions (High Value, Low Effort)

1. **Update TODO.md sorry count**: Remove the 7 WeakCanonical sorries from the "bx_completeness critical path" count. The actual count is lower (approximately 7-8 across succ_cofinal, existsTask_transitive, mixed case, and dense branch sorries).

2. **Fix existsTask_transitive** (1 line, Bundle/CanonicalFrame.lean:259): Replace `sorry` with `DerivationTree.axiom [] _ (Axiom.temp_4 phi)`. This eliminates a real sorry on the critical path.

3. **Close reflCanR_linear** (optional, ~50 lines): If desired for mathematical completeness of the ReflCanDomain module, this is provable. But it has no impact on bx_completeness.

### Strategic Recommendation

**Deprioritize task 141 entirely for sorry-free bx_completeness.** The 7 sorries in WeakCanonical are dead code. The effort should focus on:

- **Task 139**: FO satisfaction for monadic structures (3 sorries in NEquivalence.lean). These ARE on the Reynolds pipeline path.
- **Task 140**: Truth transfer and succ_cofinal elimination (2 sorries). These ARE critical path.
- **Task 142**: Mixed-case countermodel (1 sorry). This IS critical path.
- **succ_cofinal** (may be part of task 140 or needs its own task): This is the REAL blocker for discrete sorry-free completeness.

### If Task 141 Must Be Retained

If the task is retained for mathematical hygiene (not for sorry-free bx_completeness), the scope should be revised to:
1. Close `reflCanR_linear` (~50 lines)
2. Document the Until/Since cases as architecturally infeasible in the current model
3. Mark the WeakCanonical truth lemma as a "reference implementation" that handles all cases except Until/Since under open-guard semantics
4. Note that the parametric truth lemma handles all cases

## Confidence Level

- **Critical path analysis**: HIGH. Verified via `lean_verify` tool and manual dependency tracing. The WeakCanonical truth lemma is definitively dead code for bx_completeness.
- **Mathematical correctness of reflCanR_linear**: HIGH. Proof sketch is standard, infrastructure exists.
- **Until/Since structural impossibility**: HIGH. Confirmed by 02_openguard-blocker-research and independent literature analysis. The gap-content structure is absent.
- **Parametric truth lemma as correct alternative**: HIGH. It handles Until/Since via BFMCS coherence, which the chronicle construction discharges.
- **TODO.md sorry count correction**: HIGH. The count of 14 critical-path sorries includes 8 that are NOT on the critical path.
