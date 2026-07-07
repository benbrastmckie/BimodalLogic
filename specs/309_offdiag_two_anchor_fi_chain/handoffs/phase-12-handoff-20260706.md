# Task 309 Phase 12 Handoff (R3a — depth-k V-carrier definition)

## Immediate Next Action (Phase 13, R3b)

Prove `bracketEndChar_kv_correct : BracketCarrierCorrectV`-shaped correctness for
`bracketEndChar_kv` (k0-mirror conditional form, six bracket-zone order hypotheses on the atom
layer), by recursion on `k`:
- Base `k = 0`: `bracketEndChar_kv … 0 qnf = ⟨[⟨1, bracketEndChar_k0 … qnf⟩]⟩` — reduce
  `VVecEA2.holds` on the singleton list and apply `bracketEndChar_k0_correct` (:1581).
- Step `k = 1` instance: rewrite via the documented bridge
  `bracketEndChar_kv_one_eq` (NfMultiAnchorBridge:3711, pointwise EQUALITY given
  `charF 0 = nf_depth0_char_formula atomMap h_surj`) and reuse `bracketEndChar_k1v_correct`
  (:3378) verbatim.
- General step `k + 1`: the carrier's fold bits are FIBER-EXISTENTIAL
  (`b zs χ = decide (∃ sub, qnf.2 sub = true ∧ nf0_zoneSpec (atom_assgn sub) = zs ∧
  nfk_projFresh sub = χ)`). The correctness step will need a depth-`k` analog of the
  engine facts: projection-commutes-with-realization for `nfk_take`/`nfk_projFresh`
  (induction on `k`, using `nf_eval_unique` for complete-type uniqueness), routed so the
  residual stays MONADIC over `[w,x,t]` (`nf_quant_layer_fold_iff` at the innermost layer).

## Current State

- Phase 12 COMPLETED (plan v5 heading updated; inline deviation note added under the heading).
- Full tree `lake build` GREEN (1705 jobs). 0 new sorries. `bracketEndChar_k1v` untouched.
- `lean_verify` on `bracketEndChar_kv` and `bracketEndChar_kv_one_eq`:
  exactly `[propext, Classical.choice, Quot.sound]`.
- New material: NfMultiAnchorBridge.lean:3438-3776 (~340 lines), all additive at end of file.

## New Declarations (Phase 13 consumes BY NAME)

| Name | Loc (approx) | Role |
|------|--------------|------|
| `atomKind_castLE` (private) | :3470 | atom reindex along `Fin.castLE` |
| `nfk_take` | :3480 | depth-`k` prefix restriction (recursion on `k`; fiber-existential quant layer) |
| `nfk_projFresh` | :3499 | depth-`k` monadic fresh-variable projection (`nfk_take` at prefix 1) |
| `nfk_projFresh_zero` (private) | :3507 | `nfk_projFresh = nf0_projFresh` at depth 0 |
| `kv_body` (private) | :3530 | shared successor-case body: params `charBase`, `charK`, `r`, `offFiber`, `b` |
| `bracketEndChar_kv` | :3630 | THE deliverable: `(k : Nat) → BracketEndCharCarrierV sig k`, param `charF : (j : Nat) → NormalForm sig j 1 → Formula` |
| `bracketEndChar_k1v_eq_kv_body` (private) | :3652 | `bracketEndChar_k1v qnf = kv_body … := rfl` (defeq) |
| `kv_body_gate_fail` (private) | :3668 | `¬ offFiber → kv_body … = ⟨[]⟩` |
| `bracketEndChar_kv_one_eq` | :3711 | documented k=1 bridge: pointwise EQUALITY with `bracketEndChar_k1v` given `h0 : charF 0 = nf_depth0_char_formula atomMap h_surj` |

## Key Decisions (settled in this dispatch — do not re-open without a counterexample)

1. **charF parameterization** (vs by-name `char_k1`): forced by the import cycle
   (KampPrior.lean:4 imports NfMultiAnchorBridge). Phase 14 instantiates at the KampPrior
   call site with `nf_characterizable_temporal_prior` (KampPrior:397; depth-0 case is
   `nf_depth0_char_formula`, satisfying the bridge's `h0` hypothesis by construction).
2. **Fiber-existential fold-bit read** (vs pointwise depth-`k` assemble): no pointwise
   assemble exists at `k ≥ 1` (D7, NfEFold:373) — deeper joint quant layers of an arity-4 sub
   are not determined by `(zs, χ, qnf.1)`. The fiber-existential read is the semantically
   forced on-fiber content of Def 4.1 at depth `k`; it agrees with `efold_of_nf1` at k=1 under
   the gate (split-kit bijection `nf0_split_assemble`).
3. **Gate shape preserved** (two conjuncts exactly, per plan): off-fiber falsity read at the
   ATOM-layer env restriction (`nf0_dropFresh (NormalForm.atom_assgn sub) ≠ qnf.1`) +
   order-conflict falsity. NOTE for Phase 13: at `k ≥ 1` the atom-layer off-fiber clause is
   WEAKER than full depth-`k` env-restriction coherence; if the soundness direction at `k ≥ 2`
   needs more (e.g. common-env-restriction coherence of true-marked subs), that is a Phase-13
   finding to report — do NOT silently change the Phase-12 gate.
4. **`open Classical in`** on `bracketEndChar_kv` and the bridge: `ZoneSpec` is a plain `def`,
   so no `DecidableEq (ZoneSpec 3)` synthesizes; the fold-bit `decide` uses
   `Classical.propDecidable` (identical instance at both sites keeps the calc `rfl` step).

## Sorry Inventory (no new; inherited live-path baseline)

- `Theories/.../Kamp/KampPrior.lean:351` — the `:351` arm of `nf_nvar_exist_all_depths`;
  strategic (pre-existing task target); discharged by Phase 14 (R4).
- `Theories/.../Kamp/KampPrior.lean:354` — deliberately remains; owned by task 305.

## References

- Plan: `specs/309_offdiag_two_anchor_fi_chain/plans/05_offdiag-fi-chain-plan.md` (Phase 13
  section + Guards G1-G6/N1-N5 preamble).
- Template proof: `bracketEndChar_k1v_correct` (:3378) + helper kit (:2028-2825).
- Literature: Rabinovich 2014 §5 (Lemma 5.1 md:134-152, Cor 5.4 md:154-157); Def 3.1/4.1,
  Lemma 3.2(2)/3.4, Prop 3.5/4.3 with the N1/N2 citation splits.
