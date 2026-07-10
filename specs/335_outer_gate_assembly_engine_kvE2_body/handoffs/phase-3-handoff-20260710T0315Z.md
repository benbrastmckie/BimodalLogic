# Task 335 — Phase 3-5 BLOCKED Handoff

## Status
- Phase 1: COMPLETED (pre-landed)
- Phase 2 (⇐ completeness): COMPLETED, green, axiom-clean, committed
- Phase 3-5 (⇒ soundness + assembly): BLOCKED (hard)

## Phase 2 delivered (OuterGate.lean)
- `bracketEndChar_kvE2_complete_two_prior` — ⇐ half, consumes `kvE2_sepBody_holds_of_honest` (SW:9262)
- `bracketEndChar_kvE2_hcb`, `bracketEndChar_kvE2_hck` — char/provider bridges
- All axiom-clean `{propext, Classical.choice, Quot.sound}`; full `lake build` green.

## The blocker (grounded)
⇒ soundness `.holds ⟹ ∃ w, nf_eval_nf M 2 3 [w,x,t] qnf` is genuinely un-landed:
1. No landed depth-2 soundness map (`holds → nf_eval_nf M 2 3`); only completeness exists.
2. No depth-2 quant-layer fold: `nf_quant_layer_fold_iff` (NfEFold:391) is depth-0-inner only; k=2 quant layer ranges over depth-1 subs `σ : NormalForm sig 1 4`.
3. `kvE2_sepBody_extract` (SW:6356) un-consumed; its `hpairL/hpairR/hnd` side conditions open for the soundness path (wrong relation/order or completeness-only).
4. ROOT: multi-owner soundness `hgate` forward-zone conjunct (SubBracket2V:1873-1877) at a cross-σ slot point is **underdetermined by realized carrier content** — landed machine-checked FAIL: **O4 CRUX RECORD, SharedWitness.lean:6566-6659** (task 321 v7 Phase 9). Goal `σ.2 (nf0_assemble kvE_sub2_zXU χ σ.1) = true` cannot be derived; 5 closers fail (channel exhaustion).

## What would unblock (out of scope here)
Bit-compatibility filtering of the interleaving enumeration = REDEFINITION of `kvE2_sepValid`/`kvE2_sepArrL`/`kvE2_sepArrR` in `SharedWitness.lean` + O1b/O2/O3 rework. This edits a verified task-334/342 INPUT → needs explicit orchestrator re-authorization (task-337 `.rXW` precedent). Recommend: spawn a dedicated carrier-redefinition task (owned by the "Phase 10 decision gate" in the O4 record) OR re-authorize editing the carrier.

## Guardrails honored
No sorry / admit / vacuous close / assumed-hgate / interiority hypothesis. Additive: only OuterGate.lean changed; SharedWitness.lean & SubBracket2V.lean byte-unchanged; SW sorry count still 7 (all comments).
