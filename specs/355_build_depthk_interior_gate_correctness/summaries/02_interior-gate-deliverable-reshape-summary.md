# Implementation Summary (round 2): Task 355 — depth-k interior gate correctness (deliverable reshape)

- **Task**: 355 (lean4) — Build the depth-k INTERIOR gate correctness lemma for general k, by recursion
- **Plan**: `plans/02_interior-gate-deliverable-reshape.md` (v2)
- **Status**: COMPLETED — all 8 phases green and committed; re-frozen obligation-carrying DoD fully delivered
- **Session**: sess_1783905345_4b66bc
- **Module (sole Lean write target)**: `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/InteriorGateGeneralK.lean`

## Phases executed this dispatch

### Phase 7 — ∀-k obligation-carrying recursion close
Assembled the general-k obligation-carrying interior-gate correctness from delivered green assets, by
`Nat.casesOn` (a case assembly, NOT IH-threading — the step does not consume the arity-3 IH; interior
content is provider-realized per Phases 4/5).

- `InteriorGateAllK` (def, `:1239`) — the **k-cased motive**:
  - `k = 0` → `BracketCarrierCorrectVPrior atomMap (bracketEndChar_kv atomMap h_surj charF 0)` (clean,
    obligation-free — the k=0 carrier is information-complete; F1 lossiness bites only at k ≥ 2).
  - `k = n+1` → the obligation-carrying biconditional carrying `P`/`hcharK`/`h_UZ`/`h_SZ`/`hreal`/
    `hexcl`/`hexclExt`, copied verbatim from the delivered step's obligation shape.
- `bracketEndChar_kv_correct_prior` (theorem, `:1288`) — `∀ k, InteriorGateAllK atomMap h_surj charF k`:
  - `k = 0` → discharged verbatim by `interiorGateTarget_zero` (defeq, no weakening needed).
  - `k = n+1` → discharged verbatim by `bracketEndChar_kv_step_correct` at `n`.

**Deviation from plan (altered, documented)**: plan Phase 7 proposed a flat uniform ∀-k signature with
explicit `hreal`/`hexcl`/`hexclExt` binders. That hits the plan's own R1 typing tension — the
obligations reference `qnf.1` and `igFoldBit qnf`, which only typecheck at successor depth. The
well-typed realization is the **k-cased motive** above (no `True`/vacuous branch; k=0 carries the
genuine clean predicate). The `k = 1` rung (`interiorGateTarget_one`) is subsumed by the successor
branch at `n = 0` (the step is fully general in its `{k}`), so it is not special-cased. This is a
shape refinement, not a re-scope — the ∀-k obligation-carrying deliverable is fully delivered, not
blocked. The Phase-7 BLOCKED contingency was NOT triggered.

### Phase 8 — Axiom audit + full-tree build + consumability doc
- **Axiom audit** (`lean_verify`): all four deliverables report EXACTLY `[propext, Classical.choice,
  Quot.sound]` — `interiorGateTarget_zero`, `interiorGateTarget_one`, `bracketEndChar_kv_step_correct`,
  `bracketEndChar_kv_correct_prior`.
- **Full-tree `lake build`**: GREEN (1724 jobs).
- **Frozen files**: all 13 byte-identical (`git diff --stat` EMPTY vs baseline) — 7 providers
  (SharedWitness, SubBracket2V, OuterGate, ExteriorBracket, ExteriorZoneTriage, ExteriorNegation,
  ExteriorNegationPast) + KampPrior + ExteriorBracketK + PriorInterface + CarrierKv + CarrierK1V +
  ExteriorBracketAssembleK.
- **Guards**: module sorry-free (0 code sorry/admit), 0 vacuous defs, forbidden `nf_char3_deeper_split`
  absent; G1-G5 satisfied (interior content provider-realized, fold bit fiber-existential, anchors
  ⊆ {x,t}, no simp/omega/aesop chain shortcut — the wrapper is pure term-mode `Nat.casesOn`).
- **Consumability shape doc** (`:1322`): a documented `example` + `## Phase 8 — consumability shape`
  doc-comment recording the seven-obligation interface a downstream consumer (task 349) must supply:
  `P`, `hcharK`, `h_UZ`, `h_SZ`, `hreal`, `hexcl`, `hexclExt`. No consumer wiring attempted (out of
  scope; touches frozen files).

## Final deliverable

`bracketEndChar_kv_correct_prior` (`InteriorGateGeneralK.lean:1288`):
```
∀ {sig} (atomMap : Formula → sig.preds) (h_surj) (charF) (k : Nat),
  InteriorGateAllK atomMap h_surj charF k
```
Axioms: `[propext, Classical.choice, Quot.sound]`. Sorry-free.

## Verification results
| Check | Result |
|-------|--------|
| Deliverable axioms | `[propext, Classical.choice, Quot.sound]` (all 4) |
| Module sorry/admit | 0 |
| Vacuous defs | 0 |
| Forbidden `nf_char3_deeper_split` | absent |
| Frozen 13 files byte-identical | YES |
| Full-tree `lake build` | GREEN (1724 jobs) |

## Out-of-task-355 follow-ups (for `/spawn` under parent task 349)
1. **Consumer reshape** (task-349 scope): replace frozen unconditional `EndIntervalCorrect`
   (`CarrierK1V.lean:2179`) with an obligation-carrying `EndIntervalCorrectPrior` over `endInterval`
   whose `Nat.rec` step is `bracketEndChar_kv_step_correct` (base `endInterval_zero_correct`,
   `CarrierK1V.lean:2199`), routing obligation discharge up to `KampPrior.lean` (nf_nvar_exist_all_depths,
   :330+). Touches task-349 byte-frozen files.
2. **General-k `hexclExt` exterior-adjacency discharge** (exterior-bracket-layer scope): an atomic
   `bracketEndChar_kv_hexclExt_discharge` via Rabinovich Lemma 7.6 adjacent-bracket composition,
   consumed by the open `sorry` at `KampPrior.lean:351` (general-k+1).

## Commits
- `a1cc9b501` task 355 phase 7: forall-k obligation-carrying recursion close (InteriorGateAllK)
- `b263e3f1d` task 355 phase 8: axiom audit + full-tree green + consumability shape
