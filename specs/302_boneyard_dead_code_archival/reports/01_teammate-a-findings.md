# Teammate A Findings: Dead Code Identification

**Task**: 302 — Boneyard Dead Code Archival
**Angle**: Systematic dead code identification across `Theories/Bimodal/`
**Date**: 2026-06-16

---

## Key Findings

### 1. BXCanonical Path — Partially Live, Partially Dead

The ROADMAP declares BXCanonical (task 109) as "dead code — its ~17 sorries assume reflexive G/H semantics," but the reality is more nuanced after recent refactoring:

**LIVE within BXCanonical (do NOT archive):**
- `Frame.lean` (710 lines, 1 sorry: `bx_le_refl:205`) — used by TruthLemma and OrderedSeedConsistency
- `TruthLemma.lean` (302 lines) — `bot_not_in_mcs` and `imp_iff_mcs` are called by `WeakCanonical/Transfer.lean` (live path)
- `CanonicalChain.lean` (110 lines) — imported by OrderedSeedConsistency (live)
- `OrderedSeedConsistency.lean` (254 lines) — `temp_linearity_mcs` called by `WeakCanonical/ReflexiveCanonical.lean` (live)
- `CanonicalModel.lean` (794 lines) — imported by `Chronicle/ChronicleToCountermodelBasic.lean` (live)
- `Filtration/DefectChain.lean` (112 lines) — imported by CanonicalChain (live)
- `Quasimodel/SubformulaClosure.lean` (112 lines) — imported by HintikkaPoint (live chain)
- `Quasimodel/HintikkaPoint.lean` (144 lines) — imported by Quasimodel/Construction (live)
- `Quasimodel/Construction.lean` (841 lines, 0 actual sorries) — imported by DefectChain (live)
- `Quasimodel/Realization.lean` (493 lines) — imported by LocusControl (live)
- `Quasimodel/LocusControl.lean` (49 lines) — imported by BXCanonical.lean aggregator (live)
- All `Chronicle/` files — these ARE the live completeness path

**DEAD within BXCanonical:**
- `Quasimodel/EnrichedClosure.lean` (158 lines) — **zero importers anywhere in live code**. Only referenced in comments in Construction.lean and Realization.lean.

### 2. Dead Code Blocks INSIDE ChronicleToCountermodel.lean (in-file dead code)

The section `/-! ## Gap Elimination and IsSuccArchimedean — DEAD CODE (task 301) -/` at lines 55-77 identifies:

- `succ_reaches_dom_N` (private, lines 83-400) — dead BX pipeline stage induction, ~318 lines with 2 sorry stubs at lines 221, 377
- `chronicle_gap_contradiction` (private, lines 526-829) — dead gap elimination (sorry at line 534, 548, 789, 809), ~303 lines
- `succ_cofinal` (private, lines 821-828) — dead cofinality; delegates to `chronicle_gap_contradiction`
- `limitDomSubtype_isSuccArchimedean` (def, lines 837-854) — dead IsSuccArchimedean via sorry chain; marked "SUPERSEDED by axiom (task 155)"

**Total in-file dead code in ChronicleToCountermodel.lean**: approximately 700 lines (sorry-laden), lines 83-854

These functions are dead because:
- `limitDomSubtype_isSuccArchimedean` → `succ_embed_surjective` → `cantor_bfmcs_discrete_restricted_tc/fuc` → `countermodel_discrete_enriched` (private, **never called**)
- `countermodel_discrete` in Transfer.lean (deprecated, sorry'd at line 1297) is the other consumer — but it's itself dead code marked DEPRECATED

**Also dead in ChronicleToCountermodel.lean:**
- `z1_formula`, `z1_derivation`, `z1_in_mcs` (private, lines 399-412) — defined but never called anywhere in the file or project (~13 lines)

### 3. Dead `countermodel_discrete_enriched` (Completeness.lean)

- `Metalogic/BXCanonical/Completeness.lean` lines 223-250: `private theorem countermodel_discrete_enriched` — defined but **never called**. The doc comment says it was used but `completeness_discrete` actually calls `countermodel_discrete_reynolds_v2` (ReynoldsBridge.lean).

### 4. Deprecated `countermodel_discrete` and related chain (Transfer.lean)

- `WeakCanonical/Transfer.lean` lines 1249-1298: `theorem countermodel_discrete` — explicitly marked DEPRECATED, direct sorry (`sorry` at line 1297). Used only by `completeness` (not `completeness_discrete`), and the `completeness` theorem's BX path is itself marked dead in ROADMAP.

- `WeakCanonical/ChronicleExtraction.lean` lines 168-200: `extract_chronicle_as_prior` — has `sorry` at line 190, documented as dead code ("NOT on the critical path... used ONLY by `countermodel_discrete_reynolds` (Transfer.lean:1004), which has an unsolvable sorry").

- `WeakCanonical/IntegerModel/ShiftAndGlue.lean` lines 885-906: `chronicle_is_good` — documented as NOT on critical path (uses `IsSuccArchimedean` via dead sorry chain). Lines 929-930: `chronicle_is_good_direct` — documented as used ONLY by `countermodel_discrete_reynolds` (deprecated path).

### 5. Dead Kamp Files — Import Chain

These 5 files form an isolated dead subgraph (not imported by any live code):

| File | Lines | Sorries | Status |
|------|-------|---------|--------|
| `Kamp/NegationClosure5.lean` | 1027 | in comments | Dead — only imported by NegationClosureProp42 |
| `Kamp/NegationClosureProp42.lean` | 165 | 0 | Dead — only imported by FoToVecEA |
| `Kamp/FoToVecEA.lean` | 223 | 0 | Dead — not imported by any live file |
| `Kamp/RabinovichNegation.lean` | 273 | sorries | Dead — only imported by RabinovichGeneralized |
| `Kamp/RabinovichGeneralized.lean` | 516 | sorries | Dead — not imported by any live file |
| `Kamp/RabinovichWiring.lean` | 365 | sorries | Dead — not imported by any live file |
| `Kamp/RabinovichProp42.lean` | 108 | sorries | Dead — not imported by any live file |

**Total**: ~2677 lines of dead Kamp code

Note: `NegationClosure.lean` (1837 lines) is imported ONLY by `RabinovichProp42` (dead) and `FoToVecEA` (dead), so it is also dead.

**Total if NegationClosure included**: ~4514 lines of dead Kamp code

### 6. Dead EFGames Files — Stavi Discrete Path

These 3 files form a dead subgraph (not imported by any live code):

| File | Lines | Notes |
|------|-------|-------|
| `EFGames/DiscreteStaviCompleteness.lean` | 496 | Not imported by any live code |
| `EFGames/NFGameBridge.lean` | 1240 | Only imported by DiscreteStaviCompleteness |
| `EFGames/DiscreteGameTransfer.lean` | 1470 | Only imported by DiscreteStaviCompleteness |

**Total**: ~3206 lines of dead Stavi discrete path code

### 7. Already-Archived Items in Boneyard

The following are already in `Theories/Bimodal/Boneyard/` and need no further action:
- `DeadChronicleGapElimination/GapElimination.lean` — archived copy of chronicle_gap_contradiction chain (added task 301)
- `VecEADecomposition/VecEADecomposition.lean` — archived syntactic VBracketFormula negation (2 sorries)
- `BXPipelineDeadCode/ReynoldsModelSurgery.lean`, `BXPipelineGapAnalysis/ChronicleNoGaps.lean` — gap analysis dead ends
- `ChainCompleteness/`, `StrictSemanticsLegacy/`, `ScheduleBasedBFMCS/`, etc. — various prior approaches

Also in `/home/benjamin/Projects/BimodalLogic/Boneyard/` (top-level):
- `DeadConvergenceProof/limit_dom_succ_iterates.lean`
- `DeadConvergenceProof/succ_cofinal_convergence.lean`

### 8. `countermodel_discrete_reynolds` v1 (Transfer.lean)

- `WeakCanonical/Transfer.lean` lines 1203-1248: `theorem countermodel_discrete_reynolds` — **no callers**. The `completeness_discrete` uses `countermodel_discrete_reynolds_v2` (in ReynoldsBridge.lean). This v1 function is dead code (~45 lines), carries no sorry but is unused.

---

## Summary Table of Dead Code Candidates

| Item | File | Lines | Sorries | Category |
|------|------|-------|---------|----------|
| `Quasimodel/EnrichedClosure.lean` | BXCanonical/Quasimodel | 158 | 0 | Standalone dead file |
| Dead gap elimination block | ChronicleToCountermodel.lean:83-854 | ~700 | 6 | In-file dead block |
| `z1_formula/z1_derivation/z1_in_mcs` | ChronicleToCountermodel.lean:399-412 | ~13 | 0 | In-file dead helpers |
| `countermodel_discrete_enriched` | BXCanonical/Completeness.lean:223-250 | ~28 | 0 | In-file dead private fn |
| `countermodel_discrete` (deprecated) | WeakCanonical/Transfer.lean:1249-1298 | ~50 | 1 | In-file deprecated |
| `countermodel_discrete_reynolds` v1 | WeakCanonical/Transfer.lean:1203-1248 | ~45 | 0 | In-file dead fn |
| `extract_chronicle_as_prior` | WeakCanonical/ChronicleExtraction.lean:168-200 | ~33 | 1 | In-file dead fn |
| `chronicle_is_good` | IntegerModel/ShiftAndGlue.lean:885-906 | ~22 | 0 | In-file dead fn |
| `chronicle_is_good_direct` | IntegerModel/ShiftAndGlue.lean:929-~1000 | ~70 | 0 | In-file dead fn |
| `NegationClosure.lean` | Kamp/ | 1837 | 2 | Dead file (only imported by dead files) |
| `NegationClosure5.lean` | Kamp/ | 1027 | 0 | Dead file |
| `NegationClosureProp42.lean` | Kamp/ | 165 | 0 | Dead file |
| `FoToVecEA.lean` | Kamp/ | 223 | 0 | Dead file |
| `RabinovichNegation.lean` | Kamp/ | 273 | sorries | Dead file |
| `RabinovichGeneralized.lean` | Kamp/ | 516 | sorries | Dead file |
| `RabinovichWiring.lean` | Kamp/ | 365 | sorries | Dead file |
| `RabinovichProp42.lean` | Kamp/ | 108 | sorries | Dead file |
| `DiscreteStaviCompleteness.lean` | EFGames/ | 496 | sorries | Dead file |
| `NFGameBridge.lean` | EFGames/ | 1240 | sorries | Dead file |
| `DiscreteGameTransfer.lean` | EFGames/ | 1470 | sorries | Dead file |

**Total dead file lines**: ~8900 lines
**Total in-file dead blocks**: ~960 lines (across 6 files)

---

## Recommended Approach

### Phase 1 — Standalone Dead Files (simple moves)
1. Archive `Quasimodel/EnrichedClosure.lean` → `Boneyard/BXCanonicalQuasimodel/EnrichedClosure.lean`
2. Archive `Kamp/NegationClosure.lean`, `NegationClosure5.lean`, `NegationClosureProp42.lean`, `FoToVecEA.lean` → `Boneyard/KampNegationClosurePath/`
3. Archive `Kamp/RabinovichProp42.lean`, `RabinovichNegation.lean`, `RabinovichGeneralized.lean`, `RabinovichWiring.lean` → `Boneyard/RabinovichPath/`
4. Archive `EFGames/DiscreteStaviCompleteness.lean`, `NFGameBridge.lean`, `DiscreteGameTransfer.lean` → `Boneyard/StaviDiscretePath/`

### Phase 2 — In-file Dead Blocks (surgical extraction)
1. Remove dead sorry chain from `ChronicleToCountermodel.lean` (lines 55-854): extract `succ_reaches_dom_N`, `chronicle_gap_contradiction`, `succ_cofinal`, `limitDomSubtype_isSuccArchimedean` → `Boneyard/DeadChronicleGapElimination/` (already has a file there — merge or create new file)
2. Remove `countermodel_discrete_enriched` from `BXCanonical/Completeness.lean` (private, never called)
3. Remove deprecated `countermodel_discrete` from `Transfer.lean` (sorry'd, deprecated)
4. Remove dead v1 `countermodel_discrete_reynolds` from `Transfer.lean` (unused, superseded by v2)
5. Remove `extract_chronicle_as_prior` from `ChronicleExtraction.lean` (dead, sorry'd)
6. Remove `chronicle_is_good` and `chronicle_is_good_direct` from `ShiftAndGlue.lean` (dead path)
7. Remove `z1_formula/z1_derivation/z1_in_mcs` from `ChronicleToCountermodel.lean` (unused private helpers)

### Constraints
- BXCanonical/**non-Chronicle** files that ARE live: Frame.lean, TruthLemma.lean, CanonicalChain.lean, OrderedSeedConsistency.lean, CanonicalModel.lean, DefectChain.lean, Quasimodel/* (except EnrichedClosure), BXCanonical.lean aggregator. Do NOT archive these.
- The sorry chain in ChronicleToCountermodel.lean (succ_reaches_dom_N onwards) is in a LIVE file — must edit the file, not move the whole file.
- `BXCanonical/Completeness.lean` is live — only the private `countermodel_discrete_enriched` should be removed.

---

## Evidence

1. `grep -rn "EnrichedClosure"` — no `import` found; only in comments in Construction/Realization
2. `grep -rn "import.*FoToVecEA"` — zero results from live code
3. `grep -rn "import.*RabinovichGeneralized"` — zero results from live code
4. `grep -rn "import.*DiscreteStaviCompleteness"` — zero results from live code
5. `completeness_discrete` proof at Completeness.lean:310-374 calls `countermodel_discrete_reynolds_v2`, not `countermodel_discrete_enriched`
6. ChronicleToCountermodel.lean:55-77 documents its own dead code block (task 301)

---

## Confidence Level

- **BXCanonical live/dead split**: HIGH — verified by tracing import graph
- **Kamp dead files (NegationClosure chain, Rabinovich chain)**: HIGH — zero importers found
- **EFGames Stavi discrete path**: HIGH — zero importers found
- **In-file dead blocks in ChronicleToCountermodel**: HIGH — documented by the file itself and call graph tracing
- **countermodel_discrete_enriched dead**: HIGH — private function with zero callers confirmed
- **chronicle_is_good/chronicle_is_good_direct dead**: MEDIUM-HIGH — documented in comments but should verify at extraction time
- **z1_formula dead**: HIGH — private, only 4 lines of definition with no callers
