# Dead Chronicle Gap Elimination (Archived)

**Original location**: `FormalSystem/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean`,
plus (for the newest file) `FormalSystem/Metalogic/WeakCanonical/Transfer.lean`.

Dead code from the BX chronicle gap-elimination pipeline. None of it is on any live call path to
`completeness_discrete`, which uses the Reynolds pipeline (`countermodel_discrete_reynolds_v2`,
`WeakCanonical/IntegerModel/ReynoldsBridge.lean`) instead.

## Correction to the Earlier Record

An earlier archival pass produced `GapElimination.lean` here and listed
`chronicle_gap_contradiction`, `succ_cofinal`, and `limitDomSubtype_isSuccArchimedean` among the
archived declarations. **That was inaccurate**: those three were *copied* into the archive but
were never excised from live code, and remained compile-live in `ChronicleToCountermodel.lean`
long after this README claimed otherwise. The root `Boneyard/README.md` inherited the same
error, describing the "`chronicle_gap_contradiction` sorry chain" as archived while the sorry was
still being reported by `lake build`.

That is now actually true. `ChronicleGapChainExcision.lean` (below) excises the full closure from
live code, and `lake build` reports no sorry in `ChronicleToCountermodel.lean`.

## File Inventory

| File | Decls | Sorries | Source |
|------|------:|--------:|--------|
| `GapElimination.lean` | see below | 2 | `Chronicle/ChronicleToCountermodel.lean` (earlier pass; partly a copy, not an excision) |
| `TransferDead.lean` | — | — | `WeakCanonical/Transfer.lean` (`countermodel_discrete_enriched` and neighbours) |
| `ChronicleGapChainExcision.lean` | 10 | 1 | `Chronicle/ChronicleToCountermodel.lean` (9) + `WeakCanonical/Transfer.lean` (1) |

### `GapElimination.lean` (earlier pass)

Contains `succ_reaches_dom_N` (dead BX pipeline stage induction, sorry) and the Z1 axiom helpers
`z1_formula`, `z1_derivation`, `z1_in_mcs`. `succ_reaches_dom_N` was genuinely excised; the Z1
helpers were genuinely removed. The gap-chain declarations it also lists were not.

### `ChronicleGapChainExcision.lean` (the real excision)

The `sorryAx` closure, moved as ONE unit across two files. Piecemeal excision breaks
`lake build`; the whole closure must travel together.

```
chronicle_gap_contradiction  (private; the sole `sorry` token in the chain)
  → succ_cofinal                        (private)
  → limitDomSubtype_isSuccArchimedean
  → succ_embed_surjective               (letI binding inside its proof)
  → cantor_bfmcs_discrete_restricted_tc  and  cantor_bfmcs_discrete_restricted_fuc
  → dd_countermodel_chronicle_discrete   (Chronicle; 0 consumers)
  → countermodel_discrete_reynolds       (Transfer.lean; 0 consumers)
```

Two adjacent sorry-free private helpers, `limit_f_some_future_of_lt` and
`limit_f_not_G_neg_of_mem`, sat inside the same contiguous section with no call sites outside
it and moved with it — 10 declarations in all. The closure did **not** grow during excision:
`lake build` was green on the first attempt after the tails came out, so the audited fixpoint
was already closed. (Contrast the `StaviDiscretePath` precedent, where a 16-declaration audited
closure grew to 24.)

## Why It Is Dead

Both heads of the chain have zero consumers; the only surviving references anywhere were prose
in comments. A whole-environment `Lean.collectAxioms` scan over 19,442 `Bimodal.*` constants
isolated the 8 tainted names as a closed island — nothing outside it inherited their taint.

The retention rationale recorded in `ChronicleToCountermodel.lean` ("excising any of them breaks
`lake build` — keep them") named a consumer, `countermodel_discrete_enriched`, that had itself
already been archived to the sibling `TransferDead.lean` in this directory. Once that consumer
was gone, both surviving heads were dead.

`Transfer.lean` separately claimed `countermodel_discrete_reynolds` "is now sorry-free".
`#print axioms` refuted this: it was `sorryAx`-tainted via
`cantor_bfmcs_discrete_restricted_tc`/`_fuc`. The sorry-free discrete theorem is the
differently-named `countermodel_discrete_reynolds_v2`. Both claims were corrected in live code
when this excision landed.

## Correction to the "Sorry Chain" Section

The earlier version of this README ended the chain with:

> `succ_embed_surjective` (still in live code, now uses axiom instead)

Both halves were wrong. `succ_embed_surjective` never used an axiom — it obtained
`IsSuccArchimedean` from a `letI` binding of `limitDomSubtype_isSuccArchimedean`, inheriting the
`sorryAx` taint through it. And it is no longer in live code: it moved with the rest of the
closure.

## Orphans Deliberately Left Live

Removing this closure orphaned several **sorry-free** declarations. They were deliberately left
in live code — removing sorry-free declarations widens the diff without retiring a sorry, and
orphan cleanup is a separate, optional concern:

- `cantor_bfmcs_discrete_restricted_buc` — both of its consumers
  (`dd_countermodel_chronicle_discrete`, `countermodel_discrete_reynolds`) left, but it is
  sorry-free
- `succ_embed_squeeze`, `succ_embed_squeeze_strict`, `succ_embed_no_gap` — fed
  `succ_embed_surjective`
- the surrounding collapse machinery and `limitDomSubtype_succOrder` /
  `limitDomSubtype_predOrder`, which stay reachable from the live `cantor_bfmcs_discrete` /
  `rooted_succ_discrete_fmcs` path

## What Stayed

`WeakCanonical.countermodel_discrete` sits immediately after the archived
`countermodel_discrete_reynolds` in `Transfer.lean` and was **not** archived. It is a live proof
obligation, not dead code: it is the sole `sorryAx` source reaching `BXCanonical.completeness`,
and it carries a *direct terminal* sorry (axiom set `[propext, sorryAx]` — no inherited taint).

Discharging it requires a genuinely new construction. The BX-pipeline route archived here is
provably unavailable: it terminates in `succ_cofinal`, refuted by the ℤ+ℤ counterexample
documented in `../BXPipelineGapAnalysis/` (two copies of ℤ with constant MCS satisfy all
`PriorModelData` hypotheses yet have a Dedekind gap).

## Build Policy

Never compiled. `ChronicleGapChainExcision.lean` follows the `SorriedDeclExcisions` structure:
imports verbatim (union of the two source files' import blocks), an
`ARCHIVED (Boneyard) — never compiled.` docstring, `#exit`, then the code verbatim with a
source-file banner before each group. `GapElimination.lean` does not compile standalone either —
it was extracted from the middle of a namespace block.
