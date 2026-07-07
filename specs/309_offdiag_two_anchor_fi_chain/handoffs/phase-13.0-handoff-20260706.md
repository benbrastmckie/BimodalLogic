# Task 309 Phase 13.0 Handoff — F2 decision probe (2026-07-06)

## VERDICT: F2 CONFIRMED (machine-checked)

The UZ/SZ-relativized k=2 correctness statement for the CURRENT carrier `bracketEndChar_kv`
(NfMultiAnchorBridge.lean:3630) is **FALSE**, for EVERY provider family `charF`. This is not an
analysis verdict: the refutation is a sorry-free checked theorem,
`Bimodal.Metalogic.WeakCanonical.Kamp.f2_relativized_refutation`
(NfMultiAnchorBridge.lean, F2 probe section, after the F1 record), with `lean_verify` axioms
exactly `[propext, Classical.choice, Quot.sound]`.

## Immediate Next Action (orchestrator routing)

**F2 CONFIRMED branch of the plan's three-way gate**: dispatch **Phase 13.1** (statement
surgery — `ExistProviders` bundle + `BracketCarrierCorrectVPrior` + relativized k≤1 lifts),
then the FULL ladder 13.2 → 13.3 → 13.4 → 14. Do NOT `/revise` to surgery-only; do NOT
dispatch 13.2-13.4 before 13.1; do NOT strengthen the kv gate (F1 item 4 stands).

## Current State

- Phase 13.0 [COMPLETED]; v6 heading count: 11 of 16 complete (1-5, 6.1, 9-12, 13.0).
- `lake build` full tree GREEN (1705 jobs).
- Diff for this dispatch: additive-only — 1 file (NfMultiAnchorBridge.lean), 822+ insertions,
  0 deletions. `bracketEndChar_kv` (:3630), `bracketEndChar_kv_factors` (:3838), the F1 record
  (:3871-3934), and all preserved assets byte-identical.
- New import added (additive, NOTE-documented, cycle-free): `...WeakCanonical.PriorDefs`
  into NfMultiAnchorBridge.lean (PriorDefs imports only Table — no cycle).
- Sorries in probe material: 0. New live-path sorries: 0.

## What was machine-checked (probe inventory, all private except the verdict theorem)

| Lemma | Content |
|---|---|
| `F2M`, `f2sig`, `f2atomMap`, `f2surj` | probe model `M* = (ℤ,<)`, `P = {0,10,20}` |
| `f2_UZ` / `f2_SZ` | `M*` satisfies `semantic_prior_UZ`/`semantic_prior_SZ` (PriorDefs:22/:33) — closes the F1-model escape route |
| `f2_char0_congr{,2,4,5}` | depth-0 characteristic congruence kit (P-pattern + order-pattern) |
| `f2qnf` / `f2sub1` / `f2sub2` / `f2qnf'` | the F-B pair: char type of `[15,2,18]`; `u₁=12` / `u₂=4` subs; `qnf'` = `qnf` with `sub₂` un-marked |
| `f2_estar_in_sub1` / `f2_estar_not_in_sub2` / `f2_sub_ne` | distinguishing entry `e*` = "`P z ∧ x < z < u`" |
| `f2_sub_atom_eq` / `f2_sub_proj_eq` | shared ordering/env channels; shared depth-1 fresh point type (realized-2-type transfer `f2_proj2_iff`) |
| `f2_hoff` / `f2_hb` / `f2_carrier_eq` | factorization hypotheses + `bracketEndChar_kv_factors` instance: carrier equality `kv qnf = kv qnf'` |
| `f2_sub1_forces` | any `qnf'`-witness has `w' ≥ 12` |
| `f2_sub2_transfer` + `f2_congr5_wshift` | `sub₂` realized at `u = 4` for ALL `12 ≤ w' ≤ 16` — the report-05 caveat resolved AFFIRMATIVELY (per-entry check succeeds) |
| `f2tau` + `f2_tau_marked'` | `w' = 17` killed by the empty `(17,18)` gap |
| `f2_no_witness` | NO `w'` realizes `qnf'` in `M*` |
| `f2_relativized_refutation` | **the verdict theorem** (public) |

## Key Decisions

1. **Full machine-check chosen over comment-record**: the plan allowed a verdict record with
   checked refutation lemmas; the probe closed the ENTIRE refutation in one run (no UNSETTLED
   branch needed, no bounded follow-up required).
2. **∀-charF form**: the refuted statement quantifies over ALL provider families with NO
   correctness hypothesis — the F1 mechanism never evaluates the carrier's formulas, only its
   factorization, so the refutation is provider-independent (strictly strongest form).
3. **Discreteness caveat resolution**: in ℤ the `sub₂` transfer works on `12 ≤ w' ≤ 16` (one
   point more than the report's density sketch) and the discrete-gap type `τ` covers `w' = 17`.
4. **Import decision**: `PriorDefs` imported into NfMultiAnchorBridge (cycle-free, verified;
   NOTE comment in house style at the import site).
5. **Elaboration pattern for the probe**: atoms hoisted as `private abbrev` (inline
   `⟨_, by omega⟩` indices leave metavariables that block `Fin.cons` reduction during
   unification); all `decide_eq_true/false`/`of_decide_eq_true` calls use explicit
   `(Classical.dec _)` instances; ℤ-typed existential binders keep `omega` operational.

## Sorry Inventory (unchanged — no new; inherited live-path baseline)

- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean:351` — strategic (task-309
  target); discharged by Phase 14 after the ladder lands.
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean:354` — deliberately remains;
  owned by task 305.
- (Pre-existing elsewhere: EANegation.lean:1090/:1249 and Bundle/Boneyard files — untouched,
  outside task 309 scope.)

## References

- Plan: `specs/309_offdiag_two_anchor_fi_chain/plans/06_offdiag-fi-chain-plan.md` (Phase 13.0
  heading now carries the verdict; Phase 13.1 is next).
- Report: `specs/309_offdiag_two_anchor_fi_chain/reports/05_k2-vocab-enrichment-redesign.md`
  (F-B — now machine-confirmed; F-C/F-D feed 13.1/13.2).
- F1 record: NfMultiAnchorBridge.lean:3871-3934 (unchanged); F2 record: bottom of the same
  file (verdict doc-block, N1/N2/N3-compliant).
- Commits this dispatch: 55498bf4c, 331b7744f, 9f09ca9a4, 0e794385d, + final phase commit.
