# Task 309 Phase 13 Handoff (R3b — depth-k V-carrier correctness) — BLOCKED with finding F1

## Immediate Next Action

**NOT Phase 14.** Phase 13 is [BLOCKED]: the plan-v5 Phase-13 target theorem
`bracketEndChar_kv_correct` (unconditional `∀ k` correctness `↔` for the Phase-12 carrier) is
**FALSE at `k = 2`** — the soundness (LHS→RHS) direction. This is the gate-strength risk the
Phase-12 handoff flagged as Key Decision 3, now confirmed with a concrete countermodel. Next
action: `/revise 309` (plan v6) to redesign the depth-`k` carrier before Phase 13 can be
restated; Phase 14 must NOT be dispatched (it consumes the refuted deliverable).

## Finding F1 (full record: NfMultiAnchorBridge.lean:3871-3934; plan BLOCKER block under the Phase 13 heading)

- **Counterexample**: `M = (ℚ, <)`, one predicate `P = {q, p, r}`,
  `q < x < u₂ < p < u₁ < w < t < r`. `u₁, u₂` share their complete depth-1 1-type `χ`, but
  `sub₁ :=` type of `[u₁,w,x,t]` ≠ `sub₂ :=` type of `[u₂,w,x,t]` (the depth-0 5-type
  "`P z ∧ x < z <` fresh" separates them) — one `(zXW, χ, qnf.1)` fiber, two subs.
  `qnf :=` characteristic depth-2 3-type of `[w,x,t]` (realized); `qnf' := qnf` with `sub₂`
  un-marked. `bracketEndChar_kv_factors` (machine-checked, :3838) gives carrier equality
  `bracketEndChar_kv 2 qnf' = bracketEndChar_kv 2 qnf`; no `w'` realizes `qnf'` in `M`
  (dense-order argument); the two instances of the target `↔` are jointly contradictory.
  `qnf'` IS realizable in a discrete chain → no consistency side-hypothesis rescues it.
- **Isolation**: `k = 1` works because depth-0 fibers are singletons (`nf0_split_assemble`
  bijection, NfEFold:235); at `k ≥ 2` there is no pointwise assemble (D7, NfEFold:373) and the
  fiber-existential read (Phase-12 realization deviation 2) genuinely loses the joint deeper
  structure. Rabinovich's Prop 4.3 iteration ENRICHES the `α_j`/`β_j` vocabulary each round
  (Def 3.1 PDF p.4; Cor 5.4's `F_i` are TL formulas, PDF p.7); plain base-signature depth-`k`
  1-types (`nfk_projFresh`) cannot carry that structure.
- **NOT refuted**: the completeness direction (RHS→LHS) at all `k`, and the `k ≤ 1` instances.

## Landed Green This Dispatch (all sorry-free; full tree GREEN, 1705 jobs)

| Name | Loc | Role |
|------|-----|------|
| `bracketEndChar_kv_correct_zero` | NfMultiAnchorBridge.lean:3783 | recursion BASE: k=0 instance via singleton `VVecEA2.holds` reduction + `bracketEndChar_k0_correct` |
| `bracketEndChar_kv_correct_one` | :3811 | k=1 instance via the bridge `bracketEndChar_kv_one_eq` + `bracketEndChar_k1v_correct` (needs `h0 : charF 0 = nf_depth0_char_formula …`) |
| `bracketEndChar_kv_factors` | :3838 | machine-checked isolation: carrier factors through `(qnf.1, off-fiber Prop, fiber bits)` at every successor depth |
| finding F1 section comment | :3871-3934 | four-element defect record with N1/N2 citations |

`lean_verify` on all three = exactly `[propext, Classical.choice, Quot.sound]`.
Commits: `e5924f492` (13.1), `0f1826739` (13.2). No Phase-12 asset modified (KD3 honored: gate unchanged).

## Guidance for Plan v6 (revision scope, settled facts to carry)

1. Keep: `bracketEndChar_kv` k=0/k=1 behavior, the three lemmas above, the k1v kit, the fold
   engine. The `k ≤ 1` story is closed and sorry-free.
2. Redesign needed ONLY for `k ≥ 2`: the carrier must carry joint fresh-vs-anchor structure —
   candidate: inside-out iterated fold with vocabulary enrichment per round (the Def 4.1 p.6
   note at full strength), i.e. E[Σ]-atoms of round `j` become predicates of round `j+1`
   (Rabinovich's actual mechanism), rather than plain `NormalForm sig k 1` point types.
3. Any gate-strengthening patch on the CURRENT carrier is provably hopeless: honest
   characteristic types distinguish same-fiber subs (the discrete-chain realization of `qnf'`),
   so no syntactic gate separates them model-independently.
4. Phase 14's hook-discharge shape can survive: it needs SOME depth-`k` two-anchor carrier with
   the `BracketCarrierCorrectV` interface; only the internal construction changes.

## Sorry Inventory (no new; inherited live-path baseline)

- `Theories/.../Kamp/KampPrior.lean:351` — strategic (task-309 target); discharged only after
  the v6 revision lands a corrected R3b + R4.
- `Theories/.../Kamp/KampPrior.lean:354` — deliberately remains; owned by task 305.
- (Pre-existing elsewhere: EANegation.lean:1090/:1249 and Bundle/Boneyard files — untouched,
  outside task 309 scope.)

## References

- Plan: `specs/309_offdiag_two_anchor_fi_chain/plans/05_offdiag-fi-chain-plan.md` (Phase 13
  BLOCKER block + Guards preamble).
- Phase-12 handoff (Key Decision 3 = the anticipated defect):
  `handoffs/phase-12-handoff-20260706.md`.
- Literature: Rabinovich 2014 — Def 3.1 (p.4), Def 4.1 (p.5 + p.6 note), Prop 4.3 (p.6),
  Cor 5.4 (p.7), §5 bracket notation (p.7).
