# Phase 2 Partial Handoff (Plan v12)

## Session
- Session ID: sess_1748545200_orch202
- Date: 2026-05-29
- Agent: lean-implementation-agent (plan v12)
- Phase: 2 (Reynolds Model Surgery)

## What Was Done

### 1. Created ReynoldsModelSurgery.lean (350 lines)

File: `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/ReynoldsModelSurgery.lean`

Contents (all sorry-free EXCEPT `no_gaps_faithful`):
- **PriorModelData**: Structure bundling ChronicleAsPriorModel fields MINUS `domain_succ_archimedean`. Avoids the circularity where proving IsSuccArchimedean requires the gap-free property.
- **priorModelAsMonadicStructure**: Converts PriorModelData to OrderedMonadicStructure (predicate p holds at x iff atomMap(p) in fmcs(x)).
- **effectiveFormula_raw**: Local copy of `effectiveFormula` from Transfer.lean (needed to avoid circular import: Transfer -> ChronicleToCountermodel).
- **temporal_truth_effective_raw**: Faithfulness bridge -- temporal_truth = MCS membership of effective formula. Sorry-free, 70 lines, structural induction on Formula.
- **semantic_prior_UZ_raw**: Semantic Prior-UZ for PriorModelData monadic structure. Sorry-free, 25 lines.
- **semantic_prior_SZ_raw**: Semantic Prior-SZ for PriorModelData monadic structure. Sorry-free, 25 lines.
- **no_gaps_faithful**: IsEmpty (Gap M.domain) for any PriorModelData. **SORRY** -- body is the full Reynolds model surgery argument (Lemmas 6-13).
- **prior_model_is_succ_archimedean**: IsSuccArchimedean for any PriorModelData. Proof by contradiction: NOT archimedean => Gap exists (inline gap construction, 50 lines) => contradiction with no_gaps_faithful.

### 2. Modified chronicle_gap_contradiction (ChronicleToCountermodel.lean)

- Replaced bare `sorry` with structured proof:
  - Constructs PriorModelData from chronicle's raw hypotheses (limit_f, limit_c0, limit_satisfies_c5_strong, etc.)
  - C4/C5 fields: sorry-free wrapping of limit_satisfies_c4/c5_strong
  - **Prior-UZ/SZ fields: SORRY** -- need `h_fc : FrameClass.Discrete <= fc` which is not in scope
  - Applies prior_model_is_succ_archimedean, derives contradiction with bounded orbit

### 3. Import Design (Circular Dependency Avoidance)

ReynoldsModelSurgery.lean imports:
- PriorExpressiveness (for semantic_prior_UZ/SZ types)
- EFGames/Defs (for Gap type)
- Core/MCSProperties (for SetMaximalConsistent.negation_complete etc.)
- BXCanonical/TruthLemma (for bot_not_in_mcs, imp_iff_mcs)

It deliberately does NOT import ChronicleExtraction, NEquivalence, Transfer, or ChronicleNoGaps, allowing ChronicleToCountermodel to import it without circular dependency.

## Remaining Sorries

### Sorry 1: no_gaps_faithful (ReynoldsModelSurgery.lean:315)
- **What**: Reynolds Theorem 14 body (Lemmas 6-13)
- **Why blocked**: Full model surgery requires ~400-600 lines of formal proof
- **What's needed**: Contemporaneous equivalence, gap formula R, R-interval properties, class homogeneity, bad interval propagation, model surgery truth preservation (7 cases), final contradiction

### Sorry 2-3: Prior-UZ/SZ in chronicle_gap_contradiction (ChronicleToCountermodel.lean:1549, 1552)
- **What**: `prior_UZ_in_limit_domain` needs `h_fc : FrameClass.Discrete <= fc`
- **Why blocked**: `h_fc` is available at top-level callers (e.g., extract_chronicle_as_prior) but not threaded through chronicle_gap_contradiction -> succ_cofinal -> limitDomSubtype_isSuccArchimedean
- **Fix**: Add `h_fc` parameter to these three functions. Invasive (many callers) but straightforward.

## Immediate Next Action

Two independent paths to resolve all sorries:

1. **Resolve Sorry 2-3 (easy, ~30 min)**: Propagate `h_fc` through chronicle_gap_contradiction, succ_cofinal, limitDomSubtype_isSuccArchimedean, and succ_embed_surjective. This is purely mechanical signature changes.

2. **Resolve Sorry 1 (hard, ~8-12 hours)**: Formalize Reynolds Lemmas 6-13 inside no_gaps_faithful. The infrastructure (PriorModelData, faithfulness bridge, semantic Prior-UZ/SZ) is ready. The proof structure follows Reynolds 1994 Sections 6-7 exactly.

## Key Decisions

1. **PriorModelData vs explicit hypotheses**: Chose a structure to bundle hypotheses rather than 15+ explicit parameters. This makes the theorem statement cleaner and is consistent with ChronicleAsPriorModel.

2. **effectiveFormula_raw duplication**: Reproduced the definition locally rather than refactoring Transfer.lean imports. This is a pragmatic choice to avoid touching the import graph.

3. **Sorry placement**: Centralized the mathematical content sorry in `no_gaps_faithful` rather than in `chronicle_gap_contradiction`. This makes the sorry's mathematical meaning clear (Reynolds Theorem 14 body).

## Build Status
- `lake build` passes with zero errors
- ReynoldsModelSurgery.lean: 1 sorry warning (no_gaps_faithful)
- ChronicleToCountermodel.lean: 2 sorry warnings (succ_reaches_dom_N existing sorry, chronicle_gap_contradiction)
