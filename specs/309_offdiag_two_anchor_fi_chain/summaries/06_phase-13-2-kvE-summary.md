# Task 309 Phase 13.2 Implementation Summary — per-sub enriched carrier `bracketEndChar_kvE`

## Metadata

- **Task**: 309 — offdiag_two_anchor_fi_chain
- **Phase**: 13.2 (single-phase hard-mode dispatch; report 05 label 13.II-a)
- **Date**: 2026-07-06
- **Session**: sess_1783391112_643ec1
- **Agent**: lean-implementation-hard-agent (H2 lean4 + H9 contracts active)
- **Plan**: plans/06_offdiag-fi-chain-plan.md (v6)
- **Commit**: `22334d430`

## Phase Executed

Phase 13.2 ONLY (per `phase_number` in the delegation context; stopped at completion —
13.3/13.4/14 remain for the orchestrator). v6 heading count: 13 of 16 complete.

## Definitions/Theorems Landed (NfMultiAnchorBridge.lean, additive, +283/-0)

| Name | Line | Kind |
|---|---|---|
| Section doc: construction + design record (A2, N1/N2, Def 3.1 md:61-74, G5 v6, exclusion design) | :4921 | `/-! -/` |
| `kvE_consistent` | :5000 | private def (seven consistent zones; literal-identical to `k1v_zone_consistent` RHS) |
| `kvE_gate` | :5015 | private def (per-sub two-conjunct gate) |
| `kvE_body` | :5036 | private noncomputable def (per-sub successor body) |
| `kvE_body_gate_fail` | :5130 | private theorem (off-gate `⟨[]⟩` computation) |
| `bracketEndChar_kvE` | :5150 | noncomputable def, `{k} (P : ExistProviders sig atomMap k) → BracketEndCharCarrierV sig (k+1)` |
| `bracketEndChar_kvE_two_eq` | :5167 | theorem (rfl k=2 instance bridge, P at depth 1) |
| `nf_eval_depth1_fold_iff` | :5187 | theorem (depth-1 per-sub obligation decomposition; wraps `nf_quant_layer_fold_iff`) |

## Design Decisions (this phase's design deliverable)

1. **Per-sub information channel (F1 fix, A2)**: every read of `qnf.2` is `q σ` at an
   individual sub — positive enumeration `pos`/`posIn` (filters), per-sub gate conjuncts,
   per-sub `epR` joint literals, per-sub witness slots. Fiber occupancy `hasPos` is DERIVED
   from the per-sub positive lists, never read from `qnf.2` through fibers. The two features
   that defeat the `bracketEndChar_kv_factors` (:3851) factorization: per-sub slot
   multiplicity + per-sub `P.existF 3 σ` literals.
2. **`epR`/`t` anchoring**: `insertEnv env t` places the provider anchor LAST
   (NfDepth0Generalized:42), and `t` is position 3 of the per-sub obligation env
   `[u,w,x,t]`; hence `P.existF 3 σ` literals live at the right endpoint (honest-true with
   witness `e = (u,w,x)`). Slot-point anchoring was analyzed and rejected (a slot point `u`
   sits at position 0, so `P.existF 3 σ` at `u` is not honest-true).
3. **Exclusion literal shapes**: honest-safe unary `hasPos`-guarded families only
   (segments/endpoint/w biconditionals in the `kv_body` shape but per-sub-derived). Uniform
   `¬(P.existF 3 σ)` literals for negative subs were rejected: they over-exclude through
   fake anchors (report 05 F-D model-dependent-negation gap) and would make 13.3
   completeness unprovable. Negative-sub joint content is 13.3 proof-side work
   (`prior_hasAttainedINF` + EANegationClosure stack).
4. **Plan deviation (documented, plan checklist annotated)**: "σ's inner existentials
   flattened as further bracket witnesses" is realized THROUGH the provider formula
   (the Phase-14 instantiation of `P.existF` is the Lemma-3.4 flattened TL form), not as
   additional slots: the depth-k A1 bundle supplies no depth-(k-1) converters, and
   13.3/13.4 must target one uniform-in-k definition.

## Final Verification Results

- `lake build` full tree: GREEN (1709 jobs); scoped module build GREEN first attempt.
- New sorries: 0 (live-path baseline unchanged: KampPrior:351/:354, tracked strategic).
- Vacuous definitions introduced: 0 (repo grep's single hit is pre-existing
  Examples/TemporalStructures.lean:269, a legitimate `trivial` proof).
- New axioms: 0 (repo `^axiom` hits are doc-comment prose only).
- `lean_verify` on `bracketEndChar_kvE`, `bracketEndChar_kvE_two_eq`,
  `nf_eval_depth1_fold_iff`: exactly `[propext, Classical.choice, Quot.sound]`.
- `VecEA2 1` regression in new block: none.
- Diff: additive-only (+283, 0 deletions); no preserved asset modified
  (`bracketEndChar_kv`/`kv_body`, k1v kit, fold assets, 13.1 interface untouched).

## Handoff

- `handoffs/phase-13.2-handoff-20260706.md` — Phase-13.3 entry points with the exact
  unfolding lemmas and literal shapes to consume (GO/NO-GO gate discipline, F-D constraint).
- `.orchestrator-handoff.json` — status `implemented`, sorry_inventory, verification block.
