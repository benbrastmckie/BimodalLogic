# Research Report: Task 335 — Plan-03 Currency Check Against the Post-Task-333 Codebase

- **Task**: 335 - outer_gate_assembly_engine_kvE2_body
- **Status**: [PLANNED] (verifying plan 03 currency after task 333 landed)
- **Date**: 2026-07-10
- **Session**: sess_1783723095_edd5a7_335
- **Type**: lean4 (research only — no source edits)
- **Report Kind**: plan-currency / interface-drift check
- **Reports Integrated**: plans/03_soundness-half-consume-333-lemmas.md; task 333 completion (commits `9370893b1`, `b3e2e6d03`, `ff54d45c5`)

## Executive Summary

Task 333 **completed** (git: `ff54d45c5 task 333: complete orchestration`) and landed
`kvE2_outer_fold` (`SharedWitness.lean:9897`, commit `9370893b1`, "green, axiom-clean"). Plan 03's
core premises are **confirmed current**: the deleted symbols really are gone, the carrier is the
faithful `kvE2_sepArr'`/`kvE2_sepBody`, the ⇐ completeness half is landed in `OuterGate.lean:139`,
and the citation rule holds. **However, plan 03's Phase 4 is materially UNDER-SCOPED.** The actual
`kvE2_outer_fold` signature does **not** yield a "thin wrapper": it takes **four provider-conditional
hypothesis families** (`hgateL`, `hgateR`, `hbdry`, `hexcl`) that task 333 deliberately **punted to
the task-335 provider instantiation** and did NOT discharge. Discharging `hbdry` (non-interior
positive realization) and `hexcl` (negative-sub exclusion) at `charK := fun χ => P.existF 0 χ` is the
real, non-trivial remaining work — and it is exactly the content that task 309's F3/F4 counterexample
found hard. Plan 03 should be revised (v4) before Phase 4 dispatch.

## What Plan 03 Got Right (confirmed current, do not re-litigate)

| Plan-03 claim | Verified against HEAD | Verdict |
|---|---|---|
| Deleted `kvE2_sepValid`/`kvE2_sepArrL`/`kvE2_sepArrR` have 0 decls | `kvE2_sepArrL` 9 occ / `kvE2_sepArrR` 2 occ — all comment/prose; `kvE2_sepValid` only matches the *unrelated* `kvE2_sepValid_tie_of_nodup` theorem (SW:1659), not a `kvE2_sepValid` carrier decl | CURRENT |
| Live carrier is `kvE2_sepArr'` + `kvE2_sepDisjValidOwner` + interior `kvE2_sepPosI` | `kvE2_sepArr'` 54 occ, `kvE2_sepDisjValidOwner` 12 occ, `kvE2_sepPosI` 230 occ (noncomputable def SW:211) | CURRENT |
| Phase 1 def + `rfl` bridge landed | `bracketEndChar_kvE2` `OuterGate.lean:62`, `bracketEndChar_kvE2_two_eq` `OuterGate.lean:73` (`:= rfl`) | CURRENT |
| Phase 2 ⇐ completeness landed | `bracketEndChar_kvE2_complete_two_prior` `OuterGate.lean:139`, plus `_hcb`/`_hck` bridges | CURRENT |
| `kvE2_sepBody_extract` produces the interior bundles | `kvE2_sepBody_extract` thm `SW:8410`, yields `kvE2_sepBundleL/R` for `zXW3`/`zWT3` interior subs | CURRENT |
| Primed order `kvE2_sepHonestOrder'` is the only correct order | `kvE2_sepHonestOrder'` 93 occ (SW:5974 region); the fold uses it internally | CURRENT |
| SharedWitness is sorry-free / axiom-clean; md:NN cites dangle | 8 `sorry|admit` string hits, **all inside prose comments** (SW:68/2558/2841/5276/6764/6783/6966/7047 — none a real tactic); 89 `md:NN` cites present as flagged | CURRENT |
| Target predicate `BracketCarrierCorrectVPrior` | `PriorInterface.lean:60`; k≤1 lifts at `:80`/`:95` | CURRENT |

The `bracketEndChar_kvE2_two_eq` `rfl` bridge, the `hcb`/`hck` char-formula bridges, and the honest
gate lemma `kvE2_sepGate_holds_of_honest` (used by Phase 2) are all present and consumable unchanged.

## The Drift: `kvE2_outer_fold`'s Real Signature (the load-bearing finding)

`kvE2_outer_fold` (`SharedWitness.lean:9897`) has this shape (abbreviated):

```
theorem kvE2_outer_fold … (charK) (qnf) (six order bits on qnf.1) (M) (x t)
    (h : (kvE2_sepBody (nf_depth0_char_formula …) charK qnf).holds M atomMap x t)
    (hgateL : ∀ w, x<w → w<t → …ptW… → ∀ σ ∈ kvE2_sepPos qnf, zXW3 → …interior LEFT gate…)
    (hgateR : ∀ w, x<w → w<t → …ptW… → ∀ σ ∈ kvE2_sepPos qnf, zWT3 → …interior RIGHT gate…)
    (hbdry  : ∀ w, x<w → w<t → …ptW… → ∀ σ ∈ kvE2_sepPos qnf,
                ¬(zXW3 ∨ zWT3) → ∃ x1, nf_eval_nf M 1 4 [x1,w,x,t] σ)
    (hexcl  : ∀ w, x<w → w<t → …ptW… → ∀ σ, qnf.2 σ = false →
                ∀ x1, ¬ nf_eval_nf M 1 4 [x1,w,x,t] σ) :
    ∃ w, nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf
```

The fold's own docstring (SW:9858-9878) states plainly that `hbdry` and `hexcl` are **not** proved
inside it: *"discharged downstream at the provider instantiation `charK := P.existF 0` (task 335),
never assumed here"* and *"`hexcl` … is provider-conditional in exactly the A1 sense
(`PriorInterface.lean:47-59`) and is threaded verbatim, never assumed and never discharged vacuously
here."* Likewise `hgateL`/`hgateR` are the interior gate families that the per-σ kit
(`kvE2_sepBundleL/R_parts` → `kvE_subBracket2V_sound_of_parts`, `SubBracket2V.lean:1025`) must feed.

**Consequence.** 335's `bracketEndChar_kvE2_sound_two_prior` is NOT `intro h; rw [two_eq]; apply
kvE2_outer_fold`. It must, at the instantiation `charBase = nf_depth0_char_formula atomMap h_surj`,
`charK = fun χ => P.existF 0 χ`, and using only the `BracketCarrierCorrectVPrior` context
(the six order bits + `h_UZ`/`h_SZ` + `x t` — see `PriorInterface.lean:60-73`), **construct all four
families**:

1. `hgateL`/`hgateR` — the interior LEFT/RIGHT gate obligations. Plausibly dischargeable from the
   landed `kvE2_sepBody_extract` bundles + the per-σ kit (`kvE2_sepBundleL/R_parts`,
   `kvE_subBracket2V_sound_of_parts`). This is what plan 03's Risk R2 ("thread the per-σ kit itself",
   split 4a/4b) anticipated — but it framed this as a contingency, not the baseline.
2. `hbdry` — non-interior positive-sub realization, riding the σ-level `charK` E[Σ] literals of
   `kvE2_sepEpL`/`kvE2_sepPtW`/`kvE2_sepEpR` typed into arity-4 depth-1 evaluations via
   `ExistProviders.correct` (`PriorInterface.lean:41-45`). **Open obligation at `P.existF 0`.**
3. `hexcl` — negative-sub exclusion, "provider-conditional in the A1 sense." **Open obligation.**

`BracketCarrierCorrectVPrior` does not carry `hbdry`/`hexcl` as hypotheses — so 335 must PROVE them,
not thread them. This is the substantive gap.

## Why This Matters (cross-reference to the 309 F3/F4 record)

`hexcl` (negative subs unrealized) and `hbdry` (positive-sub joint realization via a single
`t`-anchored provider literal) are precisely the two channels that task 309's F3/F4 verdict
(`309/reports/06_spawn-analysis-f4.md`) machine-refuted for the *flattened* carrier
`bracketEndChar_kvE'`: a single-point provider literal `P.existF 3 σ` could not force the joint
positions `e 1 = w`, `e 2 = x`, and the exclusion guard collapsed to `⊤` on-fiber. The faithful
carrier chain (333/334/342, route b3) was built specifically to fix this. **But `kvE2_outer_fold`
relocated `hbdry`/`hexcl` out of task 333's scope and into task 335's provider instantiation rather
than discharging them.** So the question "can the faithful carrier actually discharge exclusion at
`P.existF 0`?" is *still open* — it now lives in 335's Phase 4, not in a landed 333 theorem.

Plan 03's framing that "the O4 crux is DISSOLVED" (Overview §, citing 333 report 03) is correct about
the *forward-zone `hgate` conjunct being antecedent-only*, but it does NOT cover the `hbdry`/`hexcl`
discharge, which is a distinct obligation surfaced by the fold's final signature. Plan 03 conflates
"the O4 crux record is inert" with "Phase 4 is a thin wrapper." Only the first is established.

## What Remains To Implement (335)

- **Phase 3** (comment hygiene, retire the stale BLOCKED note `OuterGate.lean:172-201`, purge the
  `md:` cite): still valid and independent — can land immediately.
- **Phase 4** (⇒ soundness): re-scope. Realistically split into:
  - **4a** — discharge `hgateL`/`hgateR` from the landed extract + per-σ kit (bounded; the machinery
    exists).
  - **4b** — discharge `hbdry` and `hexcl` at `charK := P.existF 0` from `ExistProviders.correct` +
    `h_UZ`/`h_SZ`. **This is the genuine risk.** If `hexcl`/`hbdry` do NOT close from `P.correct`
    alone, that is a real blocker to record and escalate (the A1-sense provider conditionality may be
    insufficient, mirroring F4) — NOT a place to assume a hypothesis or vacuously close.
  - **4c** — wrap into `bracketEndChar_kvE2_sound_two_prior` via `rw [bracketEndChar_kvE2_two_eq]` +
    `kvE2_outer_fold`.
- **Phase 5** (assemble `bracketEndChar_kvE2_correct_two_prior`, axiom audit, docstring): unchanged in
  intent, gated on Phase 4.

**Recommendation**: `/revise 335` to a plan v4 that (a) records `kvE2_outer_fold` as LANDED (drop the
"EXTERNAL prerequisite: wait for 333" framing — that wait is over), and (b) rewrites Phase 4 around
the four-family discharge with the 4a/4b/4c split and an explicit escalation branch if `hbdry`/`hexcl`
do not close from the provider correctness. Then `/implement 335`.

## Cross-Task Coordination

- **Dependency ordering**: 333 (done) → **335** (this task, now unblocked to attempt Phase 4) →
  309 unblock + 341 refactor. 335 is on the critical path for both 309 and 341.
- **Files 335 touches**: `OuterGate.lean` ONLY (H7 territory; `SharedWitness.lean` is 333's, now
  frozen and consumable). Plan 03's Non-Goals and the `git status` gates are correct and should be
  preserved.
- **Staleness/conflict risk**: 341 refactors `SharedWitness.lean` AFTER 335 lands; 341 must NOT start
  until 335's `OuterGate.lean` work is complete (341's own hard sequencing constraint). 335 does not
  edit `SharedWitness.lean`, so it introduces no conflict with 333's frozen output — but if Phase 4b
  concludes a `SharedWitness.lean` decl must change shape, that is a 333-territory coordination point
  (re-open 333 or spawn), NOT a 335 edit, and it would further delay 341.
- **Feeds 309**: 335's `bracketEndChar_kvE2_correct_two_prior` (Phase 5) is the exact
  `BracketCarrierCorrectVPrior` GO gate that task 309 has been blocked waiting for (see the 309
  report). Until Phase 5 lands, 309 stays blocked.

## Open Questions / Risks

1. Does `hexcl` (negative-sub exclusion) close from `ExistProviders.correct` + `h_UZ`/`h_SZ` at
   `P.existF 0`? Unverified. This is the make-or-break for 335's soundness half and the residue of the
   309 F4 obstruction.
2. Does `hbdry` (non-interior positive realization) close likewise? Same risk class.
3. If either fails, is the fix a `SharedWitness.lean` re-shape (333 territory) or an added hypothesis
   on `bracketEndChar_kvE2_sound_two_prior` (which would make the k=2 gate conditional and NOT satisfy
   the unconditional `BracketCarrierCorrectVPrior` 309 needs)? This decision should be made explicitly
   in plan v4, not discovered mid-implementation.
