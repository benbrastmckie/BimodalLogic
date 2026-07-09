# Implementation Summary: Per-slot global-index carrier enrichment (task 340)

- **Task**: 340 — Per-slot global-index carrier enrichment for value-faithful slot order
- **Status**: PARTIAL (Phases 1-4 + Phase-6 verification complete; Phase 5 handed off to task 337 boundary)
- **Session**: sess_1783561356_89aa2d_340
- **File**: `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness.lean`
- **Result**: sorry-free in scope, axiom-clean, full `lake build` green (1720 jobs), F1-F7/LITMUS preserved

## What was delivered

The blocker (report 06): task 339's 2-level region-primary merge key cannot express the honest
`a < u' < b` cross-region interleaving (owner σ's `lUW` slot, region 2, landing below owner τ's
anchor `lX1`, region 1). Region rank was PRIMARY, so region-1 always preceded region-2 regardless
of owner data. This task replaces that key with a single **per-slot global index**.

### Phase 1 — Design gate (PASS, terminality established)
Chosen representation: per-owner payload `ℕ` → `ℕ × ℕ × ℕ` = `(i₀,i₁,i₂)`, the global indices of the
owner's region-rank-0/1/2 slots. Per-slot reader `giOf wo s = tuple(owner).get(regionRank s)`;
single-level merge `decide (giOf a ≤ giOf b)`. Validated via `lean_run_code`: `a<u'<b` expressible
(σ=(0,2,3), τ=(1,4,5) ⟹ σ.lUW idx 3 < τ.lX1 idx 4), DecidableEq/decide-able, consistency ⟹
same-owner monotonicity, placeholder `(k,n+k,2n+k)` reproduces 339's region-primary order exactly.
Terminality: a total order on the full multiset subsumes both above- and below-anchor
interleavings — no fifth carrier layer needed.

### Phase 2 — Behavior-preserving carrier type migration (green, sorry-0)
Payload `ℕ`→`ℕ×ℕ×ℕ`. New defs `kvE2_sepPlaceholderTuple`, `kvE2_sepIdxTuples`,
`kvE2_sepPlaceholderTuple_mem`. Enumeration `kvE2_sepOrderTypes` ranges tuples over
`kvE2_sepIdxTuples n`. Readers `kvE2_sepOwnerRank`/`kvE2_sepOrderOwners` project `i₀` (= old owner
rank; merge behavior identical). Model/coincident orders supply placeholder `(k,n+k,2n+k)`.
Generalized `kvE2_sepOrderTypes_mem_aux` to a tuple function `gt`; re-proved `owners_aux`,
model/coincident `mem_orderTypes`, `arr'_sound`. Behavior identical to 339.

### Phase 3 — Single-level global-index merge key (green, sorry-0)
Added `kvE2_sepSlotGIdx` (per-slot reader); collapsed `kvE2_sepSlotMergeLe` to
`decide (giOf a ≤ giOf b)`, dropping the region-primary lex. Membership route
(`kvE2_sepSlotsLOf/ROf_mem`) unchanged (mergeSort_perm, comparator-agnostic). New example proves the
below-anchor `a<u'<b` case is now expressible; a second example shows same-owner region monotonicity.

### Phase 4 — Validity linear-extension consistency conjunct (green, sorry-0)
Added `kvE2_sepConsistentTuple t := decide (t.1<t.2.1 ∧ t.2.1<t.2.2)` (per-owner `i₀<i₁<i₂`, reads
no zone bit). `kvE2_sepDisjValid` now 3 conjuncts: (i) per-owner F5 zone read, (ii) per-owner
consistency, (iii) `i₀`-Nodup cross-owner total order. Re-proved `kvE2_sepBody_complete`,
`kvE2_sepCoincidentOrder_mem_arr'` (337-P1), `kvE2_sepArr'_sound`. Both model and coincident orders
remain provable `kvE2_sepArr'` members (no-collapse preserved).

### Phase 6 — Verification (complete for Phases 1-4 scope)
Full project build green (1720 jobs, no downstream regression). Axiom-clean
`{propext, Classical.choice, Quot.sound}` (no `sorryAx`) on `kvE2_sepBody_extract`,
`kvE2_sepDisjunct_extract`, `kvE2_sepBody_complete`, `kvE2_sepCoincidentOrder_mem_arr'`,
`kvE2_sepArr'_mem_modelOrder`, `kvE2_sepSlotsLOf_mem`. LITMUS/F4/F5 clean. Preserved Assets verified.

## What remains — Phase 5 (handed off)

Threading the honest bundle's cross-owner value order into a value-faithful completeness witness.
`kvE2_sepCoincidentOrder : qnf → KvE2SepWeakOrder` is **model-independent**, but the honest value
order depends on `M`. A faithful Phase 5 is a model-DEPENDENT lemma exhibiting
`∃ wo ∈ kvE2_sepArr' qnf` whose per-slot index tuples match `M`'s order on the extracted anchors —
which IS task 337's monotone-witness construction. The carrier delivered here already supports it:
the enumeration ranges over all order-consistent tuples (so the honest `wo` exists) and validity
admits it (consistency from M transitivity, Nodup from M distinctness). Best co-designed with 337.
No `sorry`/vacuous placeholder was inserted.

## Impact on the 340→337→335 chain

The load-bearing unblock is delivered: the carrier now EXPRESSES the `a<u'<b` interleaving that
broke 339, with a single-level per-slot global index and a linear-extension validity conjunct. Task
337's `.holds` builder can now select the honest-value-order `wo` from the enumeration and construct
the monotone witness. The remaining Phase 5 (value-faithful completeness witness) is co-located with
337's construction.
