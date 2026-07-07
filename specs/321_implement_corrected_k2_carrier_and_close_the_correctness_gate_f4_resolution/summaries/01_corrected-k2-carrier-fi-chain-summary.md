# Task 321 Implementation Summary — Corrected k=2 Carrier (nested F_i-chain), F4 Gate

- **Task**: 321 — implement corrected k=2 carrier and close the correctness gate (F4 resolution)
- **Status**: PARTIAL — Phase 1 complete; Phase 2 BLOCKED (design-spec gap + no k≥2 proof precedent)
- **Date**: 2026-07-07
- **Type**: lean4
- **Session**: sess_1783424133_5a7ad0_321
- **File**: `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge.lean` (byte-identical
  to green baseline — no landed asset edited; all scratch probes removed)

## Outcome

**Verdict: BLOCKED — escalate for design-spec amendment / dedicated proof-build task.** The task-320
design spec §5 (route b3 GO) is a *probe-level* spec that leaves two decisive gaps unresolved, both
established here with machine evidence. No `sorry`, no vacuous definition, and no invented
flat/single-point per-sub literal was landed (all OUT OF SCOPE per F3/F4 and the plan Non-Goals).

## Phases

- **Phase 1 — Baseline capture [COMPLETED]**: scoped `lake build
  Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge` green (1005 jobs, exit 0); task-320 probes
  present (`probe_P1`/`probe_P3`/`probe_P4`, :5634-5698); `git diff` clean on the Lean file; F4 ℤ
  counterexample recorded in-file (:5584-5595) as the Phase 8 oracle; do-not-edit assets snapshotted.
- **Phase 2 — Expose σ.2 [BLOCKED]**: see findings below.
- **Phases 3-9 — NOT STARTED**: gated behind the Phase 2 blocker.

## Machine-Grounded Findings

### Finding A — design-spec §5(1) signature is not realizable as written
`kvE_subBracket … (σ : NormalForm sig k 4)` with **general `k`** cannot read `σ.2`:
`error: Invalid projection … σ has type NormalForm sig k 4 which does not have fields`.
`NormalForm sig k 4` reduces to a pair only for a *literal successor* `k` (NormalForm.lean:134-136).
The successor-specialized `(σ : NormalForm sig (k+1) 4)` reading `σ.2` *does* build green (scratch
`scratch_innerSubs_succ`). But the general-`k` enriched body (`kvE'_body`/`kvE2_body`, subs
`σ : NormalForm sig k 4`) cannot call a successor-only sub-bracket without a `k`-matching
reformulation the spec does not provide. Both scratch probes were removed; file restored
byte-identical.

### Finding B — the concrete inner-NF → bracket encoding is under-specified and unvalidatable alone
§5(1) gives the shape ("σ's inner-witness structure as bracket witnesses between the honest anchor
pair, from σ.2") but not the Lean term mapping `σ.2 : NormalForm sig 0 5 → Bool` (k=2 gate) to
`pointTypes : Fin m → TemporalPred` / `segmentTypes : Fin (m+1) → TemporalPred`. Choosing this
encoding is the actual research contribution; landing an invented encoding whose correctness cannot be
checked without the (unbuilt) Phase 7-8 gate is precisely the under-proof-pressure construction the
plan's Risk row 2 forbids.

### Finding C — no proven k≥2 correctness precedent exists
The only landed proven `BracketCarrierCorrectVPrior` instances are for the *simple* `bracketEndChar_kv`
at k=0 (:4899) and k=1 (:4915). Both prior *enriched* k=2 gates — `bracketEndChar_kvE` (Phase 13.3,
:5203) and `bracketEndChar_kvE'` (Phase 13.35, :5532) — are NO-GO defect records (F1/F4). Phases 7-8
therefore require the first-ever proven k≥2 enriched-carrier correctness, with an unprobed reverse
direction (honest realization ⟹ sub-bracket holds) and an unbuilt `fChainPred → nf_eval_nf` semantic
bridge. Probes P3/P4 only establish the *abstract* recovery lemma on a generic `bf : BracketFormula
(n+1)`; they do not construct one from a sub's `σ.2` nor connect it to `nf_eval_nf`.

## What is needed to unblock
1. `/revise 321` (or a task-320 §5 amendment) supplying the concrete `kvE_subBracket` term: the exact
   `k`-matching (successor-sub) reformulation of `kvE2_body` AND the explicit `pointTypes`/
   `segmentTypes` construction from `σ.2`, with the intended `nf_eval_nf`-connection stated.
2. A realistic multi-phase proof-build plan for the Phase 7-8 gate acknowledging no k≥2 enriched
   precedent exists (not a single construction pass).

## Guards / integrity
- Do-not-edit landed assets: byte-identical (file unchanged vs. green baseline).
- No `sorry` on any live path; no new axiom; no vacuous definition; no flat/single-point carrier.
- G5 literature fidelity preserved (Rabinovich Def 3.1 / Prop 3.5 / Cor 5.4 grounding cited throughout
  the investigation); EANegation :1090/:1249 untouched; no provider-side pinning (Amendment F3).
