# Task 335 — Continuation Handoff (BLOCKED at Phase 4, escalated to user)

- **Session**: sess_1783723095_edd5a7_335
- **Date**: 2026-07-10
- **Status**: partial — Phase 3 landed (green, committed); Phases 4a/4b/4c BLOCKED; Phase 5 not startable.
- **Build**: `lake build …NfMultiAnchorBridge.OuterGate` green. `SharedWitness.lean`/`SubBracket2V.lean`
  byte-unchanged. Zero sorries on any live path. No new axioms.

## Per-phase outcome

| Phase | Status | Notes |
|-------|--------|-------|
| 1 (def + `rfl` bridge) | COMPLETED (pre-existing) | untouched |
| 2 (⇐ completeness) | COMPLETED (pre-existing) | untouched |
| 3 (retire BLOCKED note + citation hygiene) | COMPLETED (this session) | committed `5689db302`; `grep md: OuterGate.lean` = 0 |
| 4a (`hgateL`/`hgateR`) | BLOCKED | plan premise "bounded" is wrong; same root cause as 4b |
| 4b (`hbdry`/`hexcl`) | BLOCKED | the make-or-break; underdetermined — see below |
| 4c (wrap via fold) | BLOCKED | reduction typechecks; the four family goals are the blocker |
| 5 (assemble + docstring) | NOT STARTED | gated on 4c |

## The blocker (recorded after a genuine attempt)

The Phase-4c reduction TYPECHECKS:
```
intro h_holds
rw [bracketEndChar_kvE2_two_eq] at h_holds
refine kvE2_outer_fold atomMap h_surj (fun χ => P.existF 0 χ) qnf
  h_xy h_yt h_xt h_yx h_ty h_tx M x t h_holds ?hgateL ?hgateR ?hbdry ?hexcl
```
Order bits are accepted (defeq `qnf.atom_assgn (.order …)` = `qnf.1 (.order …)` at k=2); `h_holds :
VVecEA2.holds M atomMap (kvE2_sepBody (nf_depth0_char_formula atomMap h_surj) (fun χ ↦ P.existF 0 χ)
qnf) x t` is in context for all four goals. It leaves exactly the four family goals (verbatim shapes at
`SharedWitness.lean:9911-9956`). None closes.

Captured goal (hgateL, abbreviated — full transcript is the fold signature SW:9911-9928):
```
⊢ ∀ w, x < w → w < t → (kvE2_sepPtW …).eval_at M atomMap w →
   ∀ σ ∈ kvE2_sepPos qnf, nf0_zoneSpec σ.1 = kvE2_sep_zXW3 →
   ∀ a, x < a → a < t → { formula := P.existF 0 (nfk_projFresh σ) }.eval_at M atomMap a →
     a < w ∧ w < t ∧ nf_eval_nf M 0 4 [a,w,x,t] σ.1 ∧
     (∀ τ, nf0_dropFresh τ ≠ σ.1 → σ.2 τ = false) ∧
     (∀ zs χ, (∃ v, zoneHolds [a,w,x,t] zs v ∧ nf_eval_nf M 0 1 (fun _=>v) χ) →   -- FORWARD (the wall)
                σ.2 (nf0_assemble zs χ σ.1) = true) ∧
     (∀ zs χ, zs ≠ kvE_sub2_zXU → σ.2 (nf0_assemble zs χ σ.1) = true → ∃ v, zoneHolds … ∧ nf_eval …)
```

### Why it does not close (multiply confirmed)
1. FORWARD clause `(∃ v, zoneHolds [a,w,x,t] zs v ∧ nf_eval_nf M 0 1 v χ) → σ.2 (nf0_assemble zs χ σ.1)
   = true` — its ONLY producer is `nf_eval_depth1_fold_iff` (`CarrierKv.lean`, cited `SubBracket2.lean:519`)
   applied to σ's OWN honest realization `nf_eval_nf M 1 4 [x1,w,x,t] σ` — exactly what soundness must
   produce. Circular.
2. `kvE2_sepBody_extract` (SW:8410), the ONLY `.holds` extractor, yields only endpoints + pivot `w` +
   the interior BUNDLES `kvE2_sepBundleL/R` (anchor + `zXU`-below witnesses) — never the full per-σ
   `nf_eval_nf M 1 4 …` nor the gate clauses. No `.holds → per-σ realization` lemma exists.
3. `ExistProviders.correct` at `P.existF 0` → only `nf_eval_nf M 1 1 (fun _=>a) (nfk_projFresh σ)` (the
   projected fresh arity-1 type), strictly weaker than σ's arity-4 content = the `(outer zone, projected
   1-type)` loss machine-certified by `bracketEndChar_kv_factors` (`CarrierKv.lean:422`, docstring:
   "refutes the unconditional k≥2 soundness direction").
4. FORWARD is refutable in a rich model for arbitrary `qnf` (`σ.2` need not mark every realizable
   `(zs,χ)`), so no discharge exists — this is not a missing-lemma gap.
5. 333 landed `kvE2_outer_fold` taking all four families as HYPOTHESES (never derived).

## Classification (both branches of the plan's escalation apply)

- **(a) SharedWitness reshape — 333 TERRITORY**: `kvE2_outer_fold`/`kvE2_sepBody` must be reshaped so
  the gate is derived from `.holds` internally or weakened to what the carrier pins. 335 must NOT edit
  `SharedWitness.lean`. Re-open/coordinate 333 or spawn a 333-scoped task. Further delays 341.
- **(b) Unmet A1-conditionality — 309-relevant**: dischargeability needs a STRONGER provider contract
  (higher-arity `charK` pinning σ's full arity-4 content — changes `ExistProviders`/`KampPrior`) or a
  CONDITIONAL gate — and a conditional gate FAILS the UNCONDITIONAL `BracketCarrierCorrectVPrior` that
  309 needs.

## Resume plan (for the successor, once the user/orchestrator decides a branch)

- If branch (a): spawn/coordinate a 333-scoped task to reshape `kvE2_outer_fold` so it internalizes the
  gate derivation (or restates the four families as consequences of `.holds`). Then 335 Phase 4c becomes
  the thin wrapper the plan originally imagined, and Phase 5 assembles `_correct_two_prior`.
- If branch (b): decide whether task 309 accepts a conditional gate (it does not, per its unconditional
  requirement) or whether the provider contract is strengthened upstream (KampPrior). This is a
  design decision for the user, not an implementation step.
- Do NOT attempt to close the four families from the current inputs — it is refuted, not merely hard.
- `OuterGate.lean` is at Phase-3-green; the in-source BLOCKER note (end of file) mirrors this handoff.
