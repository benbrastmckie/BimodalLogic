# Research Report: Task 309 — Unblock Assessment After Task 333 Completion

- **Task**: 309 - offdiag_two_anchor_fi_chain
- **Status**: [BLOCKED] (deps [310,311,320,333] all completed — assessing whether 309 is now resumable)
- **Date**: 2026-07-10
- **Session**: sess_1783723095_edd5a7_309
- **Type**: lean4 (research only — no source edits)
- **Reports Integrated**: plans/07_offdiag-fi-chain-plan.md (v7); reports/06_spawn-analysis-f4.md (F4 verdict); task 333/335 current state
- **Parent**: 307

## Executive Summary

**Verdict: 309 is NOT yet unblocked. It remains blocked — now pending task 335, not task 333.** All
of 309's *listed* dependencies (310, 311, 320, 333) are complete, but the dependency list is stale:
it does not include the task that actually produces 309's missing deliverable. 309 halted at the F4
NO-GO (plan v7 Phase 13.35 — `reports/06_spawn-analysis-f4.md`): the flattened carrier
`bracketEndChar_kvE'` cannot carry the per-sub *joint* content (exclusion + positive pinning). The
recommended route-(b3) resolution — a faithful, non-flattened carrier — is exactly the
333/334/335/337/340/342 carrier chain that has been landing since. The concrete object 309 needs is
the **unconditional k=2 correctness GO gate** `bracketEndChar_kvE2_correct_two_prior`
(`BracketCarrierCorrectVPrior` for the faithful carrier). That theorem is **task 335's Phase 5
deliverable and is NOT yet landed** (only the ⇐ completeness half exists at `OuterGate.lean:139`; the
⇒ soundness + assembly are open). Task 333's `kvE2_outer_fold` (SW:9897) is a necessary intermediate,
but it **punts** the exclusion/boundary discharge to 335. So 333 completing is necessary but not
sufficient. Once 335 lands the GO gate, 309 needs a **v8 plan revision** to re-point off the
F4-refuted `kvE'` carrier onto the faithful `kvE2` carrier, then execute Phases 13.4 + 14.

## Where 309 Stopped (the F4 blocker, recap)

Plan v7 (`plans/07_offdiag-fi-chain-plan.md`) executed the one-round uniformization fallback
(Phase 13.25 add channels + Phase 13.35 re-run the k=2 gate). Phase 13.35 returned **NO-GO (F4)**,
the pre-committed second-and-last gate attempt. `reports/06_spawn-analysis-f4.md` root-caused it:

- **Channel (i) `kvE_pinDisjunct`** collapsed by `rfl` to positionally-vacuous content (discards the
  `witnessZone` field).
- **Persisting soundness crux**: the only per-sub joint channel `P.existF 3 σ` is a single-point
  `t`-anchored literal whose private existential `e` cannot be pinned to the honest anchors
  (`e 1 = w`, `e 2 = x` unpinnable).
- **Channel (ii) `kvE_exclConj`** guarded off (`⊤`) on-fiber, so exclusion never fires against the
  dishonest positive `σ''`.
- **Provider-independent ℤ counterexample** (`M = ℤ`, `x=10`, `t=20`, `σ'' = char [14,16,11,20]`):
  LHS holds at `(10,20)`, RHS fails for every `w'` — the statement is FALSE.

The spawn analysis recommended **route (b3)**: "build what Cor 5.4 actually builds" — a nested,
non-flattened per-sub bracket construction — via New Task 1 (de-risk) + New Task 2 (implement).

## The Resolution Path That Has Been Landing (333/334/… faithful carrier)

The faithful-carrier chain (`NfMultiAnchorBridge/SharedWitness.lean` + `OuterGate.lean`) is the
route-(b3) realization of 309's F4 recommendation:

- **334** [COMPLETED]: faithful carrier re-grounding — `kvE2_sepArr'` + `kvE2_sepDisjValidOwner`,
  deleting the flattened `kvE2_sepArrL/R/Valid/Singleton`.
- **342** [COMPLETED]: interior-restricted owner index `kvE2_sepPosI` (SW:211), tie-admitting orders,
  `hLR` deletion (survives only in the certificate `kvE2_sepHonest_hLR_absurd`, SW:5710).
- **337** [COMPLETED]: completeness engine `kvE2_sepBody_holds_of_honest` + the per-σ kit.
- **333** [COMPLETED]: `kvE2_sepBody_extract` (SW:8410) + `kvE2_outer_fold` (SW:9897) — the outer
  depth-2 fold `∃ w, nf_eval_nf M 2 3 [w,x,t] qnf`.
- **335** [PLANNED, NOT COMPLETE]: assembles the fold + carrier into the outer gate
  `bracketEndChar_kvE2` and the k=2 correctness theorem. ⇐ completeness landed
  (`bracketEndChar_kvE2_complete_two_prior`, `OuterGate.lean:139`); **⇒ soundness + the assembled
  `bracketEndChar_kvE2_correct_two_prior` are NOT landed.**

**Critical**: `kvE2_outer_fold` does NOT close the exclusion/boundary content. Its signature threads
`hbdry` (non-interior positive realization) and `hexcl` (negative-sub exclusion) as explicit
hypotheses, with the source docstring stating they are "discharged downstream at the provider
instantiation `charK := P.existF 0` (task 335)." Those two families are the direct descendants of
F4's failing channels. So the F4 obstruction is not yet provably resolved — it is relocated into
task 335's open Phase 4. **309's unblock is gated on 335 discharging `hbdry`/`hexcl` and landing the
unconditional GO gate.**

## What Concretely Unblocks 309

The single deliverable 309 needs is:

```
bracketEndChar_kvE2_correct_two_prior :
    BracketCarrierCorrectVPrior atomMap (bracketEndChar_kvE2 atomMap h_surj P)   -- UNCONDITIONAL
```

(the k=2 analog of the landed `bracketEndChar_kv_correct_one_prior`, `PriorInterface.lean:95`).

This must be **unconditional** in the `BracketCarrierCorrectVPrior` sense (six order bits + UZ/SZ + x,
t only). If 335 can only deliver it with an *added* hypothesis (e.g. a residual exclusion assumption
it cannot discharge), then 309 is still not satisfied and F4 has effectively recurred one level up —
a finding to escalate, not absorb.

## After 335 Lands: 309's Remaining Work (v8)

309's plan v7 targets are written against the **retired** `kvE'` carrier and must be re-pointed:

1. **`/revise 309` → plan v8**: re-point Phase 13.4 (general-k correctness) and Phase 14 (hook
   rewire) from `bracketEndChar_kvE'`/`kvE_pinDisjunct`/`kvE_exclConj` (F4 exhibits, retired) onto the
   faithful `bracketEndChar_kvE2` + `bracketEndChar_kvE2_correct_two_prior`. This is the same
   re-pointing pattern v6→v7 used. The v7 retired-deliverable-names discipline and G1-G6 guards carry
   forward unchanged.
2. **Phase 13.4** (general-k `BracketCarrierCorrectVPrior` for all depths): note the faithful carrier
   currently proves the k=2 gate specifically; the ∀k lift lives in KampPrior's `Nat.rec` (F-A).
   Confirm whether the faithful carrier generalizes past k=2 or whether 309 consumes it only at the
   k=2 rung of the recursion.
3. **Phase 14** (hook rewire): discharge the `KampPrior.lean:351` (a.k.a. the `:350` past/future arm
   per 309's own description — the line reference drifts 350/351 across artifacts; verify against HEAD
   before editing) depth-k≥2 Cor 5.4 converter sorry using the faithful gate. Definition of done:
   full `lake build` green, `#print axioms nf_nvar_exist_all_depths` = `{propext, Classical.choice,
   Quot.sound}`, live-path sorries reduced.

## Cross-Task Coordination

- **Dependency ordering**: 333 (done) → **335** (must land `bracketEndChar_kvE2_correct_two_prior`) →
  **309** (revise v8 + implement 13.4/14). 341 (refactor of `SharedWitness.lean`) is orthogonal to
  309's remaining work but must also wait for 335; if 341 runs before 309, 309's v8 must be written
  against the post-341 module layout (public API preserved, but import paths/line numbers shift).
- **Files 309 will touch**: `Kamp/NfZoneFlattenNavigable.lean`, `Kamp/KampPrior.lean` (the `:350`/`:351`
  rewire), and read-only consumption of `NfMultiAnchorBridge/OuterGate.lean` (the gate). 309 does NOT
  edit `SharedWitness.lean`.
- **Staleness risk**: 309's plan v7 is written against symbols that no longer exist as live carriers
  (`bracketEndChar_kvE'` is retained off-path as the F4 exhibit but is refuted). Do NOT resume
  `/implement 309` against v7 — it will re-attempt a machine-refuted target. A v8 revision is
  mandatory before implementation.
- **Recommendation**: keep 309 [BLOCKED] with the blocker updated to "pending task 335's
  `bracketEndChar_kvE2_correct_two_prior` (unconditional k=2 GO gate)"; consider adding 335 (and the
  337/340/342 carrier chain) to 309's dependency list so the stale [310,311,320,333] list reflects the
  true blocker.

## Open Questions / Risks

1. Will 335 discharge `hbdry`/`hexcl` at `P.existF 0` and deliver the gate **unconditionally**? If not,
   F4 recurs and 309 needs a deeper carrier revision (route b3 nested-bracket, still open).
2. Does the faithful carrier's k=2 gate lift to general k, or only supply the k=2 rung? Phase 13.4
   scope depends on this.
3. Line-number drift `KampPrior.lean:350` vs `:351` for the rewire target — verify against HEAD at
   revision time.
