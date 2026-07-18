# Phase 9 continuation — sub-step 9(cont)-b handoff

## Immediate Next Action
Sub-step 9(cont)-c: prove the full `conjInterleave_iff` biconditional's **backward** direction and
add `veeConj` / `veeConj_iff` (Lemma 3.4-∧) in a NEW `VeeConj.lean`. The forward direction and all
reusable rank/slot infrastructure are now LANDED sorry-free.

## Current State (this dispatch, all green + committed)
Sub-step 9(cont)-b COMPLETE: `conjInterleave_forward` is retired — LANDED sorry-free. Added to
`ConjInterleave.lean` (§6c + §7), all sorry-free:
- `strictMono_lt_iff_val_lt_filterCard` — **the order-theoretic crux**: for `x : Fin m → α` strict
  mono into a linear order, `x a < y ↔ a.val < #{i | x i < y}` (the down-set `{i | x i < y}` is an
  initial segment, so its cardinality is the threshold position). Proof via `Finset.Iic`/`Iio`
  inclusions + `Fin.card_Iic`/`Fin.card_Iio`. This is the sanctioned "large order-theoretic build";
  no one-shot Mathlib lemma exists.
- `chain_interval_clause` — packages the three `efSat` region clauses (before x₀ / open (x_{i-1},xᵢ) /
  after xₙ) into ONE statement: any point `y ≠` all chain points satisfies `ψ.intervalType` at its
  point slot `⟨#{i | x i < y}, _⟩`. Case split on the count via the crux.
- `intervalHolds_conj_of_both` — both chains' completions at a real point collapse to a common
  `S₁ ∩ S₂` witness via `nf_eval_unique`.
- `chainIntervalType_eq_pointSlot` — count-match bridge: `chainIntervalType ψ e t = ψ.intervalType`
  (point slot of y) when `t.val = #{j | w j < y}` (pointwise `(e i).castSucc < t ↔ x i < y`).
- `intervalSlot_eq_pointSlot` — interior-point count-match bridge (supplies `crossConsistent_of_holds`'s
  `hiv₁`/`hiv₂`).
- `conjInterleave_forward` — full realized rank merge: `S := mergedSet`, `w := S.orderEmbOfFin`,
  `eₖ := (S.orderIsoOfFin).symm ∘ ⟨xₖ ·, _⟩`; discharges `valid` (joint surjectivity via
  `rank_orderEmbOfFin`, pin-compat), `pointConsistent` (`pointConsistent_of_holds`),
  `crossConsistent` (`crossConsistent_of_holds` + the two interval bridges), and
  `efSat (mergedFormula …)` (point types via `mergedPointType_left/right`; the three merged interval
  regions via a local `merged_clause` combining the bridges + `chain_interval_clause` +
  `intervalHolds_conj_of_both`); assembled by `mergedFormula_mem_conjInterleave`.
- added import `Mathlib.Order.Interval.Finset.Fin`.
- dropped `{r}` (unused) from `intervalHolds_conj_of_both`.
- updated `conjInterleave_forward` docstring + module contents note (removed "tracked strategic sorry").

Build: scoped `ConjInterleave` green (998 jobs); full `lake build` EXIT 0 (1770 jobs). Sorry count in
`ConjInterleave.lean`: **0**. Only remaining task-379 on-path sorry: `KampPrior.lean:562` (Phase 13).
`#print axioms Bimodal.Metalogic.BXCanonical.completeness_discrete` = `[propext, sorryAx,
Classical.choice, Lean.ofReduceBool, Lean.trustCompiler, Quot.sound]` — identical to baseline (the
`sorryAx` is the pre-existing KampPrior.lean:562). `ConjInterleave.lean` is an orphan module off the
live import path; no spine impact.

## Key Decisions
- The audit's crux `w a < y ↔ a.val < #{j | w j < y}` was generalized to any strict-mono `x : Fin m → α`
  (`strictMono_lt_iff_val_lt_filterCard`) — proving it once for arbitrary `x` covers BOTH the merged
  chain `w` (region placement) and each source chain `xₖ` (point-slot placement).
- Region unification: all three `efSat` interval regions (before/between/after) route through ONE
  `merged_clause` by reducing each to `t.val = #{j | w j < y}` (the merged slot value = count of merged
  points below y), computed per-region from the crux applied to `w`.
- `let`-bound `w`, `e₁`, `e₂` (not `set`) so the `orderEmbOfFin`/`orderIsoOfFin` helper lemmas apply
  up to defeq without unfolding friction.
- Commit-per-green-substep: 5 commits (crux, chain_interval_clause, conj+chainIntervalType bridges,
  intervalSlot bridge, forward retirement).

## Remaining (9(cont)-c then Phases 10-13), per reports/10 §5 steps 5-6
- **9(cont)-c**: `conjInterleave_iff` full biconditional.
  - Forward: `conjInterleave_forward` (now landed).
  - Backward: from a disjunct `mergedFormula ψ₁ ψ₂ ψ₁.pin e₁ e₂` + witness `w` (with the filter
    guaranteeing `m.valid ∧ pointConsistent ∧ crossConsistent`), project `xₖ i := w (eₖ i)`. For each
    ψₖ:
    - StrictMono xₖ (eₖ strict mono ∘ w strict mono); pin (`env v = w(eₖ(ψₖ.pin v))`); point types via
      `mergedPointType_left`/`_right`.
    - interval clauses: for `y` in a ψₖ open interval, split the region into (a) merged **open
      sub-intervals** — carry `S₁∩S₂ ⊆ Sₖ`, discharge by `intervalHolds_inter_left`/`_right` +
      `intervalHolds_mono`; and (b) merged **interior existential points** of the other chain `e_{3-k} i'`
      — discharge by the `crossConsistent` membership (`ψ_{3-k}.pointType i' ∈ ψₖ.intervalType slot`)
      collapsed through `nf_eval_unique` to `intervalHolds (ψₖ.intervalType slot) (w (e_{3-k} i'))`.
    - The slot-correspondence infrastructure landed this dispatch (`chainIntervalType_eq_pointSlot`,
      `intervalSlot_eq_pointSlot`, the crux) is directly reusable for the backward region bookkeeping
      (they are stated as equalities/iffs, usable in both directions).
  - **Sizing note (H8):** the backward direction is a comparably large independent build to the forward
    (~200 lines) — the region decomposition (which merged points lie in a given ψₖ interval; splitting
    the ψₖ open interval at interior merged points) is new machinery. Kept as its own dispatch per H8
    to avoid an unclean stop; the forward build already filled this dispatch's budget cleanly.
- **9(cont)-c cont / Phase 9 tail**: `veeConj` (distribute ∧ over disjuncts via `conjInterleave` per
  pair) + `veeConj_iff` (full biconditional) in a NEW `VeeConj.lean` (create only at that point).
- **Phases 10-13 (β/γ/δ/ζ)**: spine consumers of the now-full `veeConj_iff`; ζ retires
  `KampPrior.lean:562`.

## Sorry Inventory
See `.orchestrator-handoff.json` `sorry_inventory` — 1 entry (`KampPrior.lean:562`, pre-existing
on-path, Phase 13). `conjInterleave_forward` is REMOVED from the inventory (retired this dispatch).
