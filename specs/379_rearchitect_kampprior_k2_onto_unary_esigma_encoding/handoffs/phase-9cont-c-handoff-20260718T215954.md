# Phase 9 continuation — sub-step 9(cont)-c handoff (Phase 9 COMPLETE)

## Immediate Next Action
Begin **Phase 10 (β — single-∃∀ negation over unordered pairs)** in a NEW
`Theories/Bimodal/Metalogic/WeakCanonical/Kamp/EFSatNegation.lean`. Its `[IN PROGRESS]` marker in
the plan is STALE — no file exists yet; the phase has not been started. First step (plan Task):
De Morgan the `augTarget_iff` decomposition of `¬efSat ψ` into the disjunction over ordered pairs
`(k,l)` plus the existence-sentence negation, reusing the Phase-6-migrated
`prop42_efSat_negation_general` as the per-pair base case and `augTarget_iff` (Lemma 3.2(2),
migrated Phase 5). Depends on Phase 9 (now complete) and Phase 6.

## Current State (this dispatch, all green + committed)
Sub-step 9(cont)-c COMPLETE — **Phase 9 is now fully landed sorry-free**. `conjInterleave_iff`
(both directions) and `veeConj` / `veeConj_iff` (Lemma 3.4-∧) are done. Added:

**`ConjInterleave.lean`** (§8–§9, all sorry-free; file now 987 lines):
- `exists_mergePair_of_mem` — reverse of `mergedFormula_mem_conjInterleave`: unfolds the
  `flatMap`/`toList.map`/`filter` bookkeeping to recover the merge datum `m` and its three filter
  conjuncts (`valid`, `pointConsistent`, `crossConsistent`) from a bare `φ ∈ conjInterleave`.
- `regions_of_pointSlot` — the mirror of `chain_interval_clause`: from a single point-slot clause
  (interval type holds at `y`'s point slot `⟨#{i | x i < y}, _⟩` for every non-chain `y`) recover
  the three `efSat` region clauses (before / between / after). Reusable for both projected chains.
- `conjInterleave_backward` — **the backward direction** of Lemma 3.2(1). From a satisfied disjunct
  `mergedFormula ψ₁ ψ₂ ψ₁.pin e₁ e₂` + witness `w`, project `xₖ i := w (eₖ i)`. Point types via
  `mergedPointType_left`/`_right`; pinning via the merge pin field + `hpin_comp` (chain 2). Interval
  regions recovered by a two-case split at each `y` in a ψₖ-open interval:
  - (a) `y` NOT a merged point ⇒ `chain_interval_clause` on `mergedFormula`/`w` gives
    `intervalHolds (S₁ ∩ S₂) y`; `intervalHolds_inter_left`/`_right` projects to `Sₖ`;
    `chainIntervalType_eq_pointSlot` places the ψₖ point slot.
  - (b) `y = w j` a merged interior existential point of the OTHER chain (`j = e_{3-k} i'` by joint
    surjectivity + `y` not a ψₖ-point) ⇒ `crossConsistent` (`hcc.1`/`hcc.2`) gives
    `ψ_{3-k}.pointType i' ∈ ψₖ.intervalType slot`; `mergedPointType_{left/right}` gives
    `unaryHolds (ψ_{3-k}.pointType i') y`; `intervalSlot_eq_pointSlot` places the slot.
  `regions_of_pointSlot` reassembles the three `efSat` region clauses.
- `conjInterleave_iff` — the full biconditional: backward = `conjInterleave_backward`,
  forward = `conjInterleave_forward` (landed 9(cont)-b).

**`VeeConj.lean`** (NEW, 80 lines, all sorry-free):
- `veeSat_flatMap` — push `veeSat` through a `flatMap` of ∨∃∀-formulas.
- `veeConj := Ψ₁.flatMap (fun ψ => Ψ₂.flatMap (fun φ => conjInterleave ψ φ ψ.pin φ.pin))`
  (noncomputable, since `conjInterleave` is).
- `veeConj_iff : veeSat (veeConj Ψ₁ Ψ₂) ↔ veeSat Ψ₁ ∧ veeSat Ψ₂` — proved by pushing `veeSat`
  through both `flatMap`s + `conjInterleave_iff` pointwise + nested-existential rearrangement.

Build: scoped `ConjInterleave` green (998 jobs); scoped `VeeConj` green (999 jobs); full
`lake build` EXIT 0 (1770 jobs). Sorry count in both files: **0**. `veeConj_iff` axioms =
`[propext, Classical.choice, Quot.sound]` (no `sorryAx`). `#print axioms
Bimodal.Metalogic.BXCanonical.completeness_discrete` =
`[propext, sorryAx, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler, Quot.sound]` —
**identical to baseline** (the `sorryAx` is the pre-existing on-path `KampPrior.lean:562`, Phase 13).
Both modules are orphan (off the live import path); no spine impact.

## Key Decisions
- **Structure-projection defeq friction**: `(mergedFormula …).pointType`/`.n` do not auto-reduce to
  `mergedPointType …`/`k` as omega/rw atoms. Fixed by (i) explicit-typing readback hypotheses
  (`have hpt : unaryHolds N (mergedPointType …) … := hwpt …`) so the projection coerces to the
  `mergedPointType` head that `mergedPointType_left/right` rewrites, and (ii) proving the merged-chain
  cardinality bound via `Nat.lt_succ_of_le` on the goal's own filter (no explicit `Fin (k+1)`
  annotation) to avoid the `(merged).n` vs `k` atom mismatch.
- **Reuse over reimplementation**: the landed 9(cont)-b infra (`chain_interval_clause`,
  `chainIntervalType_eq_pointSlot`, `intervalSlot_eq_pointSlot`, `strictMono_lt_iff_val_lt_filterCard`,
  `mergedPointType_left/right`) served the backward direction directly — no new order-theory needed;
  the only new machinery is the reverse-membership extraction and the reverse region splitter.
- **`regions_of_pointSlot` factored once, applied to both chains** — the three efSat region count
  computations mirror the forward `efSat` assembly, shared across ψ₁/ψ₂ rather than duplicated.
- Commit-per-green-substep: 4 commits (helpers, backward, iff, veeConj).

## Remaining (Phases 10–13, per reports/10 §5 step 6 + plan)
- **Phase 10 (β)**: `efSat_negation_general` in new `EFSatNegation.lean` — De Morgan `augTarget_iff`,
  trichotomy lemma, per-pair `prop42_efSat_negation_general`, existence-sentence negation, flatten via
  `veeSat_append`. STALE `[IN PROGRESS]` marker; not started.
- **Phase 11 (γ)**: `veeSat_negation` — `¬veeSat (∨φᵢ) = ⋀ᵢ ¬φᵢ`; per-disjunct β; reassemble `⋀` via
  the now-full `veeConj_iff`.
- **Phase 12 (δ)**: structural Prop 4.3 `translate` (MonadicFormula → VeeExistsForall); `and`-case
  consumes `veeConj_iff`.
- **Phase 13 (ζ)**: spine rewire; retires the pre-existing `KampPrior.lean:562` sorry.

## Sorry Inventory
See `.orchestrator-handoff.json` `sorry_inventory` — 1 entry (`KampPrior.lean:562`, pre-existing
on-path, Phase 13). No sorries in `ConjInterleave.lean` or `VeeConj.lean`. `conjInterleave_backward`,
`conjInterleave_iff`, `veeConj_iff` all landed sorry-free this dispatch.
