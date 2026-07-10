# Task 333 Implementation Summary — Route A Grouped Extraction (plan 06, all phases)

- **Task**: 333 — carrier redefinition kvE2_sepArr bit-compatibility correctness pair
- **Plan**: `plans/06_route-a-grouped-extraction.md` (v4, Route A)
- **Status**: All 4 phases [COMPLETED]; build green; territory sorry-free; axiom-clean
- **Sessions**: multi-dispatch under `/orchestrate --hard` per-phase mode; Phase 4 by
  sess_1783679696_817168

## Phases Executed

| Phase | Deliverable | Commit(s) |
|---|---|---|
| 1 | R1 cleanup — delete dead `kvE2_sepBody_nonvacuous` | `924d76c49` |
| 2 | Route-A grouped extraction: tie-run lemmas, `kvE2_sepDisjunct'_extract`, hypothesis-free `kvE2_sepBody_extract` (zero universal side-conditions) | (phase-2 commits) |
| 3 | Per-σ kit application: `kvE2_sepBundleL_sound`, `kvE2_sepBundleR_sound` (geometry-correct right mirror), aggregate `kvE2_sepBody_kit_sound` | `0e156a7a8`, `163d6b700` |
| 4 | **`kvE2_outer_fold`** — the outer depth-2 fold (make-or-break) | `9370893b1` |

## Phase 4: theorems proved

**`kvE2_outer_fold`** (`SharedWitness.lean` tail, +187 lines): from
`(kvE2_sepBody (nf_depth0_char_formula …) charK qnf).holds M atomMap x t`, the six
`BracketCarrierCorrectVPrior` order-bit hypotheses, and four Amendment-F3 hypothesis
families quantified over the pivot (`hgateL`/`hgateR` verbatim kit shapes; `hbdry`
non-interior positive realization; `hexcl` outer exclusion), concludes
`∃ w, nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf` — the exact
`BracketCarrierCorrectVPrior` ⇒-RHS task 335 consumes.

Derived inside the proof (never assumed): pivot + bounds (Phase-3 kit); full outer atom
layer — predicate bits at `w`/`x`/`t` from the carrier's own point-type head conjuncts
(`kvE2_sepPtW`/`kvE2_sepEpL`/`kvE2_sepEpR` through `formula_conjList_iff` +
`nfPred_correct`; Def 3.1 point-type channel, Rabinovich 2014 p.4), order bits from
`x < w < t` against the six hypotheses; positive-sub zone classification via `kvE2_sepPos`
membership; both interior-class realizations via the Phase-3 kit.

## Plan Deviations

- **Phase 4, task 2 (annotated inline in the plan)**: `ExistProviders.correct` is not
  invoked inside the proof. The two residual quant-layer directions that require provider
  typing (`hbdry`, `hexcl`) are threaded as explicit F3 hypotheses instead. Grounding: the
  machine-checked information-loss record `bracketEndChar_kv_factors` (`CarrierKv.lean:422`)
  shows the depth-2 carrier pins per-σ content only up to (outer zone, projected 1-type),
  so these clauses are provider-conditional in exactly the A1 sense
  (`PriorInterface.lean:47-59`); their discharge belongs to the `charK := P.existF 0`
  instantiation (task 335). The conclusion is NOT weakened.
- Phase 3 deviation (carried from its handoff): right-interior class served by the
  geometry-correct mirror `kvE2_sepBundleR_sound` rather than a direct feed into the landed
  left closer (refuted by signature reads).

## Final Verification

- `lake build` (full project): **green**, 1720 jobs; scoped `…SharedWitness` green;
  downstream `…OuterGate` green (no regression).
- `lean_verify Bimodal.Metalogic.WeakCanonical.Kamp.kvE2_outer_fold`:
  `[propext, Classical.choice, Quot.sound]`, no `sorryAx`.
- Territory census (`NfMultiAnchorBridge/`): sorry_count **0**; live-sorry grep on
  `SharedWitness.lean`: 0 (3 pre-existing prose hits).
- LITMUS (`fChainPred|x1 < e`): **0 hits in added lines; zero-delta** (19 pre-existing
  prose hits file-wide).
- Vacuous defs added: 0 (repo's single hit pre-existing, outside territory). New axioms: 0.
  New `md:NN` citations: 0.
- Diff scope: Lean diff touches ONLY `SharedWitness.lean`; `OuterGate.lean`,
  `NavigatedSpine.lean`, `NfEFold.lean`, `SubBracket2V.lean`, and the carrier structure
  byte-identical.
- No-nesting / L-R confinement: no new point types or slot lists (consume-only assembly).

## Sorry Inventory

Empty — zero sorries on the territory module across all phases.

## Downstream (task 335 interface notice)

335 wraps `kvE2_outer_fold` for the OuterGate ⇒ path. Its obligations: derive
`kvE2_sepBody .holds` via `bracketEndChar_kvE2_two_eq`; discharge `hgateL`/`hgateR`
(carrier-derivable pieces in the SW Phase 9 O4 section, SW:6528ff) and the two new residual
families `hbdry`/`hexcl` at the provider instantiation (`ExistProviders.correct` + UZ/SZ).
If `hexcl` is not dischargeable from `P.correct` + UZ/SZ, strengthen the PROVIDER interface
(A1 conditionality) — never the carrier filter. Full notice:
`handoffs/phase-4-handoff-20260710-outer-fold.md`.
