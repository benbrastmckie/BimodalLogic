# Handoff — task 340 after Phase 4 (Phases 1-4 + Phase-6 verification complete)

## Immediate Next Action
Resume task 337's `.holds` builder together with task 340 Phase 5. The enriched carrier now
expresses the honest `a<u'<b` interleaving; 337 selects the honest-value-order `wo` from the
enumeration and builds the monotone witness (this IS the value-faithful completeness of Phase 5).

## Current State
- File: `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness.lean`
- Phases 1,2,3,4: COMPLETE (green, sorry-0, axiom-clean). Phase 6 verification COMPLETE for this scope.
- Phase 5: handed off (model-dependent, = 337 construction).
- Full `lake build` green (1720 jobs). Sorry count in scope: 0.
- Committed: 4 green milestone commits (phases 1,2,3,4) on `main`.

## Key Definitions Delivered (all in SharedWitness.lean)
- `KvE2SepWeakOrder = List (NormalForm sig 1 4 × KvE2SepSpikeOrderType × (ℕ × ℕ × ℕ))` — payload now carries per-slot index tuple `(i₀,i₁,i₂)`.
- `kvE2_sepPlaceholderTuple n k := (k, n+k, 2n+k)` — region-primary placeholder; `kvE2_sepIdxTuples n` — finite tuple range (components < 3n); `kvE2_sepPlaceholderTuple_mem`.
- `kvE2_sepSlotGIdx wo s` — per-slot global-index reader (owner tuple component at slot region rank).
- `kvE2_sepSlotMergeLe wo a b := decide (kvE2_sepSlotGIdx wo a ≤ kvE2_sepSlotGIdx wo b)` — single-level.
- `kvE2_sepConsistentTuple t := decide (t.1<t.2.1 ∧ t.2.1<t.2.2)` — linear-extension conjunct.
- `kvE2_sepDisjValid` — 3 conjuncts: per-owner F5 zone read; `all kvE2_sepConsistentTuple`; `i₀`-Nodup.
- `kvE2_sepOwnerRank`/`kvE2_sepOrderOwners` project `i₀`.

## Key Decisions
- Single per-slot global index (dropped region-primary lex). Tuple `ℕ×ℕ×ℕ` (finite, DecidableEq).
- Behavior-preserving Phase 2 via placeholder `(k,n+k,2n+k)` (giOf = rank·n + k = region-primary).
- Consistency conjunct = per-owner `i₀<i₁<i₂` (linear extension) + `i₀`-Nodup (cross-owner order).
- Phase 5 value-faithful witness is per-M → co-design with 337 (model-independence of the carrier).

## Sorry Inventory
Empty (no sorry, no vacuous placeholder anywhere in scope).

## Resume Guidance for Phase 5 / task 337
Build a model-dependent lemma `∃ wo ∈ kvE2_sepArr' qnf, (kvE2_sepSlotsLOf wo) monotone in M's value
order`: extract all owners' anchors/witnesses (honest bundles L/R), assign each slot its rank in M's
sorted order as the tuple components (a valid tuple in `kvE2_sepIdxTuples`), prove consistency (M
transitivity), Nodup (M distinctness), and that the merge order equals M's value order. Then feed to
`kvE2_sepBody_holds_iff.mpr` via the boundary-linked realization engine.
