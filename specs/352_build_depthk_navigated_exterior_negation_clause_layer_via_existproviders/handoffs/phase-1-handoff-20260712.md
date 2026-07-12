# Task 352 Phase 1 Handoff (GO/NO-GO gate) — 2026-07-12

## Immediate Next Action (Phase 2, wave 2)

Dispatch Phase 2 (shared navigation and fiber-partition layer) as an additive tail of
`Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorFiberK.lean`:
- Fiber partition of `kvE_fiber` elements by zone classification and fresh profile
  (`nfk_projFresh`-keyed, navigation-only per G6), producing per-bucket sub-lists consumed
  by `kvE_fiberPosOn` (whose correctness lemma `kvE_fiberPosOn_correct` is already proved
  for ARBITRARY sub-lists — bucket honesty lemmas via `kvE_subBit_iff`,
  ExteriorBracketK.lean:314, are the Phase-2 work).
- Chain-assembly ordering helpers (template `kvE2_futGapList`/`kvE2_futRayList` :890/:895,
  element source swapped to fiber buckets).
- `{α : Type}`-generic min-pick replica (template `kvE2_futMinPick`,
  ExteriorNegation.lean:1146-1149, private — replicate, do not import).
- Q4 check: every `nf0_zoneSpec` read on `σ.1` (atom layer) only.

After Phase 2, `ExteriorFiberK.lean` is FROZEN for waves 3-5 (H7).

## Current State

- **Phase 1 [COMPLETED], VERDICT: GO.** Phases 2-6 [NOT STARTED].
- Sorry count: 0 in both new modules (docstring "sorry-free" mentions only).
- Build: scoped `lake build` green for both
  `...NfMultiAnchorBridge.ExteriorFiberK` and `...ExteriorFiberProbeK` (first-attempt green).
- Axioms: exactly `[propext, Classical.choice, Quot.sound]` on `kvE_fiberPos_correct`,
  `kvE_fiberPos_separates_F2`, `kvE_fiber_separates_pair`, `kvE_sepPos_separates_qnf_pair`
  (lean_verify) — in particular the probe does NOT inherit the KampPrior
  `nf_nvar_exist_all_depths` n≥1 strategic sorries (no `sorryAx`).
- Frozen diffs: EMPTY on all 7 frozen providers + KampPrior.lean + RefutationF2.lean +
  ExteriorBracketK.lean + PriorInterface.lean + Lemma32Reduction.lean at both commits.
- Commits: `db075f83b` (phase 1.1), phase 1.2 commit follows this handoff.

## Landed Interface (what Phases 2-4 consume)

`ExteriorFiberK.lean` (139 lines):
- `kvE_fiber (σ : NormalForm sig (k+1) 4) : List (NormalForm sig k 5)` + `kvE_fiber_mem`
  (Fintype-backed filter, mirrors `kvE_sepPos`/`kvE2_futGapList` conventions).
- `kvE_fiberPosOn (P : ExistProviders sig atomMap k) (l : List (NormalForm sig k 5)) : Formula`
  — bucketed `formula_disjList (l.map (P.existF 4))`; `kvE_fiberPos P σ` = whole-fiber form.
- `kvE_fiberPosOn_correct` / `kvE_fiberPos_correct` — UZ/SZ-conditional:
  `temporal_truth M atomMap t _ ↔ ∃ s ∈ l (resp. σ.2 s = true), ∃ env : Fin 4 → M.carrier,
  nf_eval_nf M k 5 (insertEnv env t) s`.

`ExteriorFiberProbeK.lean` (probe-local, GO gate): three separation theorems as above.

## Key Decisions

1. **Exact correctness statement shape** (plan left it "fixed by implementer against
   `P.correct`"): `∃ s ∈ l / σ.2 s = true ∧ ∃ env : Fin 4 → M.carrier, nf_eval_nf M k 5
   (insertEnv env t) s` — `P.correct 4` distributed verbatim over `formula_disjList_iff`;
   no reshaping, so 349 Phase 2 consumes the provider's own anchor convention.
2. **Bucketed correctness proved for arbitrary sub-lists** (not just fiber sub-lists) —
   strictly more general, zero extra cost, and lets Phase-2 buckets avoid re-proving.
3. **Probe provider instance** = `nf_nvar_exist_depth0_tl_fn` (NfDepth0Generalized:1615,
   unconditional correctness, sorry-free) wrapped as `ExistProviders p2sig p2atomMap 0`
   verbatim (postmortem rule 11). No KampPrior import (avoids the import cycle AND the
   n≥1 strategic sorries).
4. **Semantic separation quantity** = the e*-bucketed content disjunction
   (`kvE_fiberPosOn p2P ((kvE_fiber σ).filter (· = e*))`) at t = 18: whole-fiber values
   agree on the pair at t=18 (both subs have realized fiber elements), so the separating
   observable is the bucket at the distinguishing entry — matching how the clause layer
   actually consumes content (per-zone/per-bucket disjuncts).
5. **Marginal-agreement half** stated in the NEW layer's own vocabulary
   (`p2_sub_atom_eq`, `p2_zone_agree`, `p2_projFreshD_agree` via `kvE_projFreshD_zero`)
   rather than replicating the ~150-line depth-1 `f2_sub_proj_eq`; the frozen
   `f2_carrier_eq` is cited, not replicated (plan's replication list did not include it).

## Sorry Inventory

`[]` (empty — clean phase).

## References

- Plan: specs/352_.../plans/01_depthk-clause-layer.md (Phase 2 section for next dispatch;
  Postmortem Constraints + Constraints bind all dispatches)
- Rabinovich Def 7.5 / Def 4.1/7.7 rows of the Source-to-Implementation Mapping (content
  channel citations, carried in ExteriorFiberK docstrings)
