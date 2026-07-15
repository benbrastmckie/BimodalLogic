# Task 370 — M2 De-folded Interior Carrier (Option B): Phase 3 Summary

Session: sess_1784093800_976134 · Agent: lean-implementation-hard-agent (H2/H9) · 2026-07-14

## Phase executed

**Phase 3 — Render-free endpoint→arity-4 extraction (replaces `igFoldBit_realize_iff`) [COMPLETED]**
— THE load-bearing decircularizing move the whole M2 redesign exists for.

## What landed

Two render-FREE de-folded endpoint→arity-4 realizer extraction lemmas, both additive in
`InteriorGateGeneralK.lean` (after the Phase-2 Fib region; pure additions 87/0):

| Lemma | File:line | Reads realizer off | Conclusion |
|-------|-----------|--------------------|------------|
| `bracketEndChar_kvFib_realize_futT` | IGGK:~1556 | de-folded RIGHT endpoint `igEpRFib`@t, literal `untl (charFib σ) ⊤` | `∃ x1 > t, nf_eval_nf M k 4 [x1,w,x,t] σ` |
| `bracketEndChar_kvFib_realize_pastX` | IGGK:~1591 | de-folded LEFT endpoint `igEpLFib`@x, literal `snce (charFib σ) ⊤` | `∃ x1 < x, nf_eval_nf M k 4 [x1,w,x,t] σ` |

Both take (i) the de-folded endpoint eval and (ii) a render-FREE characteristic-soundness seam
`hcharFib : ∀ τ x1, temporal_truth M atomMap x1 (charFib τ) → nf_eval_nf M k 4 [x1,w,x,t] τ`
(the arity-4 analog of `interiorGate_hck` / `P.correct`; supplied by the provider `P` at Phase 7).
**Neither signature contains a `nf_eval_nf M _ 3 [...] qnf` render hypothesis** — the decircularizing
property mandated by the plan.

## Why this decircularizes (the load-bearing point)

- The frozen bridge `igFoldBit_realize_iff` (IGGK:563) turns fold content into a model realizer only
  by consuming the deep render `nf_eval_nf M (k+1) 3 [w,x,t] qnf` as an explicit hypothesis — the very
  render this content is upstream of (`ExteriorGateAssembleK:337-338`). Firing the leaf
  `kampPrior_hreal_supply` (InteriorHrealSupplyK:53-116) from it is therefore CIRCULAR
  (machine-confirmed in that leaf's body).
- The frozen `igFoldBit` lossily `∃`-projects the arity-4 fiber to `(zone, χ:NF k 1)`; the de-folded
  sibling `igFoldBitFib` keeps the whole `σ:NF k 4` live, and the de-folded endpoint predicates carry
  the FULL arity-4 characteristic formula `charFib σ` in their per-σ literals. So the σ-realizer is
  readable DIRECTLY off the endpoint eval (native `until`/`since` firing → `charFib σ` satisfied →
  `hcharFib`), with no render. This is precisely the "only decircularizing edit" the research report
  (reports/01 §"M1 corroboration") identified.

## Proof method

`simp only [igEpRFib/igEpLFib, TemporalPred.eval_at]` → `formula_conjList_iff` to enter the endpoint
conjunction; `List.mem_append_*` + `List.mem_map` (with `igLit` reduced under the zone bit `hz`) to
select the marked-σ literal; `simp only [temporal_truth]` to fire the native `untl`/`snce` semantics
(`∃ s, t<s ∧ temporal_truth s (charFib σ) ∧ …`); close via `hcharFib`. No literature step shortcut
(the temporal firing is native semantics; fiber content rides the full-arity `charFib σ` literal).

## Verification

- `lake build Bimodal.…InteriorGateGeneralK` — GREEN (3.6s).
- `lean_verify` on both lemmas — axioms `{propext, Classical.choice, Quot.sound}`, **NO `sorryAx`**.
- No render hypothesis in either signature (verified by source scan).
- `git diff --numstat`: `InteriorGateGeneralK.lean` 87/0 (pure additions); `CarrierKv.lean` and
  `KampPrior.lean` 0/0. Frozen `bracketEndChar_kv` (CarrierKv:238-249), both `rfl` bridges
  (IGGK:339-351, CarrierKv:294-351), and pre-existing sorries KampPrior:519/:522 byte-identical.
- No new sorries introduced; no vacuous defs; no new axioms.

## Sorry inventory (unchanged this phase — all pre-existing, untouched)

- `kampPrior_hreal_supply` (InteriorHrealSupplyK:116) — strategic, Phase 7.
- `kvE_hexclDeepFut_supply` general-m (ExteriorDeepExclSupplyK:105) — strategic, Phase 8.
- `kvE_hexclDeepPast_supply` general-m (ExteriorDeepExclSupplyK:133) — strategic, Phase 8.

## Plan deviations

Split the single "render-free extraction lemma" into a future/past mirror pair
(`…_futT` / `…_pastX`) because Phase 7's discharge needs both exterior arms; annotated inline in the
plan's Phase-3 task list. No fallback ladder invoked — the render-free extraction proved cleanly
through the de-folded carrier, so no churn against the frozen defeq and no strategic sorry needed.

## Next

Phase 4 (de-folded `step_complete` analog, IGGK:693). Do NOT start it in this dispatch (single-phase
focus). Phase 5's `step_sound` analog will consume these extraction lemmas in place of the folded
`hreal` hypothesis; Phase 7 supplies `hcharFib` from the provider `P`.
