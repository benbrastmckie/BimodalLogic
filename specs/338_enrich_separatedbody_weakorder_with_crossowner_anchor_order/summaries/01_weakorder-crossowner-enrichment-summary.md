# Implementation Summary: Cross-owner weak-order enrichment (task 338)

- **Task**: 338 — Enrich separated-body weak-order with cross-owner anchor order
- **Status**: COMPLETED (all 5 phases, sorry-free, axiom-clean, full build green)
- **Mode**: HARD (lean-implementation-hard-agent)
- **File modified**: `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness.lean` (only)

## Outcome

The task-334 weak-order carrier recorded only a per-owner placement tag relative to `w`, so two
owners whose fresh anchors interleave differently (`x1_σ < x1_τ` vs `x1_τ < x1_σ`) were
indistinguishable. This is now fixed: the carrier carries a genuine cross-owner order on the merged
anchor multiset, and `kvE2_sepBody` CONSUMES the weak-order value it previously discarded. This
unblocks task 337's `.holds` builder.

## Design (settled)

- **Enriched carrier**: `KvE2SepWeakOrder := List (NormalForm sig 1 4 × KvE2SepSpikeOrderType × ℕ)`.
  The 3-value `KvE2SepSpikeOrderType` placement tag is kept UNCHANGED (preserving F5 zone-key
  discipline and the entire spike-realization block 2336-2571 verbatim); the added ℕ is the
  orthogonal merged-chain RANK (cross-owner position). This minimized blast radius while genuinely
  adding cross-owner order.
- **Enumeration** (`kvE2_sepOrderTypes`): `foldr` over `kvE2_sepPos`, with the inner cartesian
  product now over `kvE2_sepSpikeOrderTypes.flatMap (tag) × (List.range n).flatMap (rank)`
  (`n = |pos|`). Distinct interleavings → distinct rank tuples → distinct members.
- **Cross-owner consistency conjunct**: `kvE2_sepDisjValid` conjoins the per-owner F5 read with
  `decide (wo.map (·.2.2)).Nodup` — distinct ranks = a genuine total order on the merged chain.
- **Model / coincidence orders**: built via `List.zipIdx` (ranks `0,1,…,n-1`, distinct hence
  order-consistent). Membership proven by a generalized `kvE2_sepOrderTypes_mem_aux` (induction +
  `List.mem_flatMap`/`mem_map`, threading the `zipIdx` start offset).
- **Phase 4 rewire**: `kvE2_sepBody` now maps `fun wo => kvE2_sepDisjunct … (kvE2_sepSlotsLOf wo)
  (kvE2_sepSlotsROf wo)`, where `kvE2_sepSlotsLOf/ROf wo` sequences the per-owner region blocks by
  `wo`'s rank via `kvE2_sepOrderOwners wo = (wo.mergeSort (·rank ≤ ·rank)).map Prod.fst` — never the
  discarded-`_wo` fixed `kvE2_sepSlotsL/R qnf` concatenation (the root bug SW:835-836).

## Phases executed

- **P1-P3** (one green pass, no transient sorries needed): enriched types; enumeration + rank
  semantics; membership (`kvE2_sepModelOrder_mem_orderTypes`,
  `kvE2_sepCoincidentOrder_mem_orderTypes`), coincidence validity + completeness
  (`kvE2_sepBody_complete` re-proved with the Nodup conjunct), strengthened `kvE2_sepArr'_sound`
  (now returns per-owner validity ∧ ranks-Nodup).
- **P4**: `kvE2_sepBody` rewire + helpers (`kvE2_sepOrderOwners`, `kvE2_sepSlotsLOf/ROf`,
  `kvE2_sepOrderTypes_owners`, `kvE2_sepMem_orderOwners`); re-proved `kvE2_sepBody_holds_iff`,
  `kvE2_sepBody_nonvacuous`, `kvE2_sepBody_extract` (hpairL/hpairR now universally quantified over
  `wo ∈ kvE2_sepArr'`). `kvE2_sepBody_gate_fail` unchanged.
- **P5**: verification (below).

## Verification results (Phase 5 gate)

- **sorry_count**: 0 (`lean-sorry-census.sh` on SharedWitness).
- **Vacuous definitions**: 0. **New axioms**: 0.
- **`lean_verify` axiom-clean** on `kvE2_sepBody`, `kvE2_sepBody_extract`, `kvE2_sepBody_holds_iff`,
  `kvE2_sepBody_nonvacuous`, `kvE2_sepArr'`, `kvE2_sepDisjValid`, `kvE2_sepBody_complete`,
  `kvE2_sepArr'_sound`, `kvE2_sepModelOrder_mem_orderTypes`, `kvE2_sepMem_orderOwners` →
  ⊆ `{propext, Classical.choice, Quot.sound}`, NO `sorryAx`.
- **Full `lake build`**: green (1720 jobs). External consumer OuterGate.lean unaffected.
- **No-collapse invariant**: BOTH `kvE2_sepModelOrder` (strict tags) and `kvE2_sepCoincidentOrder`
  are machine-checked members of `kvE2_sepOrderTypes`.
- **Cross-owner distinguishability**: a self-contained `example` proves the two interleavings
  `[(σ,c,0),(τ,c,1)]` and `[(σ,c,1),(τ,c,0)]` are unequal (both collapse to `[(σ,c),(τ,c)]` under
  the old type) — the defining property this task installs.
- **F5 / LITMUS**: `kvE2_sepDisjValidOwner` untouched (strict→OPEN `zXU`/`zUW`, coincident→CLOSED
  stub); the rank is an abstract ℕ compared only ℕ-to-ℕ (mergeSort), never an `x1 < e_i`
  relative-position literal on a raw chain.

## Preserved assets (non-regressed)

All Preserved-Assets-table statements hold. The coincidence discharges
(`kvE2_sepCoincidentAnchor_discharge`/`_R`), honest bundles (`kvE2_sepHonestBundleL`/`R`),
`kvE2_sepClosedLeafStub`, per-owner coincidence validators, and the entire spike-realization block
(2336-2571) are unchanged verbatim. `kvE2_sepBody_complete`'s conclusion (`kvE2_sepArr' qnf ≠ []`)
is preserved; its proof re-run through the enriched coincidence route.
