# Critical Path to Sorry-Free bx_completeness

**Research Date**: 2026-05-14
**Scope**: Definitive sorry inventory for `Bimodal.Metalogic.BXCanonical.bx_completeness`
**Method**: Import tracing, grep-based sorry audit, manual call-chain analysis

---

## Key Findings

1. **bx_completeness has THREE branches**, each calling a different countermodel constructor:
   - Dense branch: `dd_countermodel_chronicle_dense` — **sorry-free**
   - Discrete branch: `doets_countermodel_discrete` (which delegates to `dd_countermodel_chronicle_discrete`) — **has a sorry via `succ_cofinal`**
   - Mixed branch: `dd_countermodel_chronicle_mixed_sorry` — **top-level sorry, unresolved**

2. **existsTask_transitive (Bundle/CanonicalFrame.lean:259)** IS on the critical path. It is used by `canonicalR_transitive` → `parametric_task_rel_forward_comp` → `ParametricCanonicalTaskFrame.forward_comp`, which is used by BOTH the dense and discrete countermodel constructors. The sorry is **trivially fixable**: the comment says "BX: derive temp_4 from BX1" but `temp_4` is a direct axiom `Axiom.temp_4 φ` used identically in `MCSProperties.lean:248` as `DerivationTree.axiom [] _ (Axiom.temp_4 φ)`.

3. **succ_cofinal (ChronicleToCountermodel.lean:1885)** is the primary hard sorry on the discrete critical path. It represents a genuine mathematical gap: showing that the succ-orbit from any `a` reaches any larger `b` in `LimitDomSubtype`. The "constant MCS" case evades Z1 (Doets maximum principle), and two of three sub-sorries in `succ_reaches_dom_N` (lines 1297, 1450) feed into it.

4. **dd_countermodel_chronicle_mixed_sorry (ChronicleToCountermodel.lean:3336)** is a complete top-level sorry for the mixed case. It requires novel techniques (ultraproducts, enriched frames, or new BX theorems). No formalization work has been done for it.

5. **WeakCanonical/TruthLemma.lean sorries (lines 426, 443, 479, 494, 548, 563)** and **BXCanonical/TruthLemma.lean sorries (lines 296, 321)** are NOT on the current critical path. The completeness proof bypasses the canonical model truth lemma entirely, using the parametric representation theorem + chronicle BFMCS construction. These are dead code relative to `bx_completeness`.

6. **RootScopedChain.lean sorries (lines 186, 193, 198)** are confirmed dead code — the chronicle path bypasses the schedule-based chain entirely.

7. **WeakCanonical/IntegerModel.lean sorries (lines 101, 139, 156, 213, 225)** are the Reynolds pipeline, which is structurally wired but currently falls back to the chronicle construction in `Transfer.lean:135`. These are NOT on the active critical path.

---

## Complete Sorry Inventory

### Active Critical Path Sorries

| File | Line | Theorem | Description | Difficulty |
|------|------|---------|-------------|-----------|
| `Bundle/CanonicalFrame.lean` | 259 | `existsTask_transitive` | `[] ⊢ G φ → G(G φ)` — derives Temporal 4 axiom; fix is `DerivationTree.axiom [] _ (Axiom.temp_4 phi)` | **Trivial (1 line)** |
| `Chronicle/ChronicleToCountermodel.lean` | 1297 | `succ_reaches_dom_N` (boundary case a > max(dom(N))) | Stage-induction boundary: a > max of dom(N), b = new point; succ(max_N_sub) may enter domain at later stage | **Hard** |
| `Chronicle/ChronicleToCountermodel.lean` | 1450 | `succ_reaches_dom_N` (boundary case a < min(dom(N))) | Stage-induction boundary: a below min(dom(N)), b in dom(N) | **Hard** |
| `Chronicle/ChronicleToCountermodel.lean` | 1514 | `succ_reaches_dom_N` (intermediate) | Companion to stage-induction boundary; real-analysis convergence argument | **Hard** |
| `Chronicle/ChronicleToCountermodel.lean` | 1885 | `succ_cofinal` | Gap elimination: succ-orbit from a reaches any b > a in LimitDomSubtype; constant-MCS case evades Z1; feeds `limitDomSubtype_isSuccArchimedean` and `succ_embed_surjective` | **Hard (architectural)** |
| `Chronicle/ChronicleToCountermodel.lean` | 3336 | `dd_countermodel_chronicle_mixed_sorry` | Mixed-case countermodel (neither □(F'T) nor □(U(T,bot)) in A); requires novel techniques | **Architectural / Research** |

### Active Critical Path Sorries (via indirect imports)

| File | Line | Theorem | Description | Difficulty |
|------|------|---------|-------------|-----------|
| `Bundle/CanonicalFrame.lean` | 259 | `existsTask_transitive` | (see above, confirmed on path via ParametricCanonical) | **Trivial** |

### Dead Code Sorries (NOT on critical path)

| File | Lines | Context |
|------|-------|---------|
| `BXCanonical/RootScopedChain.lean` | 186, 193, 198 | `bx_bfmcs_restricted_tc/buc/fuc` — schedule-based chain, bypassed by chronicle |
| `BXCanonical/TruthLemma.lean` | 296, 321 | `until_backward_refl_mcs`, `since_backward_refl_mcs` — irreflexive semantics issue |
| `WeakCanonical/TruthLemma.lean` | 426, 443, 479, 494, 548, 563 | Until/Since truth lemma for ReflCanDomain — not on chronicle path |
| `WeakCanonical/IntegerModel.lean` | 101, 139, 156, 213, 225 | Reynolds pipeline (finite_structures_good, very_good_implies_good, chronicle_is_good) — pipeline falls back to chronicle |
| `WeakCanonical/NEquivalence.lean` | 355, 379, 382 | Reynolds n-equivalence proofs |
| `WeakCanonical/OrderedSum.lean` | 47, 71 | Reynolds sum preservation |
| `WeakCanonical/Table.lean` | 62, 76 | Reynolds truth table |
| `BXCanonical/Quasimodel/Realization.lean` | 67, 73, 197, 249 | Under irreflexive semantics (BX1 removed) |
| `BXCanonical/Quasimodel/Construction.lean` | 150, 186 | Quasimodel path |
| `BXCanonical/Filtration/SigmaOrdering.lean` | 82, 99, 143 | Filtration path |
| `BXCanonical/Frame.lean` | 205 | `bx_le_refl` — irreflexive semantics |
| `Bundle/SuccExistence.lean` | 466, 771, 845 | Boundary resolution |
| `Bundle/SuccRelation.lean` | 548, 617 | Succ relation properties |
| `Algebraic/LindenbaumQuotient.lean` | 177, 182 | `temp_k_dist` (BX removed) |
| `Algebraic/InteriorOperators.lean` | 83 | `temp_k_dist` (BX removed) |
| `WeakCanonical/ReflexiveCanonical.lean` | 144 | Reflexive canonical domain |
| `BXCanonical/Chronicle/ChronicleToCountermodel.lean` | 839 | `dd_countermodel_chronicle_nondense_sorry` — dead stub, superseded by discrete path |

---

## Critical Path Diagram

```
bx_completeness (BXCanonical/Completeness.lean:129)
    |
    |--(Dense branch)-----> dd_countermodel_chronicle_dense
    |                           |
    |                           +--> cantor_bfmcs_dense (sorry-FREE)
    |                           +--> cantor_bfmcs_dense_restricted_tc (sorry-FREE)
    |                           +--> cantor_bfmcs_dense_restricted_buc (sorry-FREE)
    |                           +--> cantor_bfmcs_dense_restricted_fuc (sorry-FREE)
    |                           +--> ParametricCanonicalTaskFrame
    |                                   |
    |                                   +--> parametric_task_rel_forward_comp
    |                                           |
    |                                           +--> canonicalR_transitive
    |                                                   = existsTask_transitive
    |                                                   [SORRY LINE 259 -- TRIVIAL FIX]
    |
    |--(Discrete branch)--> doets_countermodel_discrete (WeakCanonical/Transfer.lean:110)
    |                           |
    |                           +--> (falls back to) dd_countermodel_chronicle_discrete
    |                                   |
    |                                   +--> cantor_bfmcs_discrete (sorry-FREE)
    |                                   +--> cantor_bfmcs_discrete_restricted_tc (sorry-FREE)
    |                                   +--> cantor_bfmcs_discrete_restricted_buc (sorry-FREE)
    |                                   +--> cantar_bfmcs_discrete_restricted_fuc (sorry-FREE)
    |                                   +--> succ_embed_surjective
    |                                           |
    |                                           +--> limitDomSubtype_isSuccArchimedean
    |                                                   |
    |                                                   +--> succ_cofinal
    |                                                           |
    |                                                           +--> [SORRY LINE 1885 -- HARD]
    |                                                           +--> succ_reaches_dom_N
    |                                                                   |
    |                                                                   +--> [SORRY LINE 1297 -- HARD]
    |                                                                   +--> [SORRY LINE 1450 -- HARD]
    |                                                                   +--> [SORRY LINE 1514 -- HARD]
    |                           +--> ParametricCanonicalTaskFrame
    |                                   --> existsTask_transitive [SORRY LINE 259]
    |
    +--(Mixed branch)-----> dd_countermodel_chronicle_mixed_sorry
                                [SORRY LINE 3336 -- ARCHITECTURAL]
```

---

## Recommended Priority Order

### Priority 1: Trivial Fix (1-2 hours)

**`existsTask_transitive` at `Bundle/CanonicalFrame.lean:259`**

Replace the sorry with:
```lean
DerivationTree.axiom [] _ (Axiom.temp_4 phi)
```

This is a one-line fix. The comment "BX: derive temp_4 from BX1" is misleading — `temp_4` is already a direct axiom in the `Axiom` inductive type (see `Axioms.lean:116`). Identical usage exists in `Core/MCSProperties.lean:248`.

This fix does NOT eliminate `sorryAx` from `bx_completeness` because the other sorries remain, but it closes a trivially correct sorry that was improperly deferred.

### Priority 2: Alternative Architecture for Discrete Case (medium-hard)

The `succ_cofinal` sorry (ChronicleToCountermodel.lean:1885) and its supporting stage-induction sorries (lines 1297, 1450, 1514) represent a genuine mathematical gap in the Burgess chronicle approach.

The analysis in the code (line 1139-1155) identifies three approaches, all blocked by the "constant MCS" case. The recommended resolution is **Task 129** (weak/reflexive completeness + conservative extension), which provides `IsSuccArchimedean` via a Henkin canonical model where every point is a distinct MCS, bypassing the gap scenario entirely.

Alternative: Directly prove `succ_cofinal` by:
(a) Establishing Z1 as a derivable schema (Doets maximum principle)
(b) Showing constant-MCS contradicts the omega-chain construction internally
(c) Stage-induction boundary proof via `omega_chain_dom_new_unique`

### Priority 3: Mixed Case (architectural research)

**`dd_countermodel_chronicle_mixed_sorry` at line 3336**

This requires either:
- New BX theorems that eliminate the mixed case (show that □(F'T) ∨ □(U(T,bot)) is derivable from BX axioms)
- Ultraproduct construction combining Q-model and Z-model
- Enriched frame semantics

This is a research-level problem and should be treated as a separate task (Task 142 is scoped for this).

---

## Confidence Level

**High confidence** on:
- Which sorries are on the active critical path (traced import graph manually)
- `existsTask_transitive` fix (identical pattern exists elsewhere in codebase)
- `succ_cofinal` being the core blocker for discrete case (extensively documented in-file)
- WeakCanonical TruthLemma sorries being dead code (Transfer.lean falls back to chronicle)
- Mixed case being unresolved (line 3336 is a stub `sorry`)

**Medium confidence** on:
- Whether fixing `existsTask_transitive` would cause any `#print axioms` change (it would not eliminate `sorryAx` because `succ_cofinal` and mixed case remain)
- The exact number of succ_reaches_dom_N sub-sorries contributing to `succ_cofinal` (lines 1297, 1450, 1514 all feed into `succ_cofinal` at 1885)

**Note on axiom audit**: The `#print axioms` audit in `BXCanonical/Completeness.lean` (lines 183-228) documents the state as of task 107. The current audit would still show `sorryAx` from the discrete path. The dense branch is provably sorry-free in principle once `existsTask_transitive` is fixed.
