# Task 335 v5 — Fragment-Gate Implementation Summary (post-345)

- **Session**: sess_1783723095_edd5a7_335
- **Date**: 2026-07-10/11
- **Status**: partial — Phase B LANDED (⇒ soundness half); Phase C `hexcl` = NO-GO; Phase D BLOCKED.
- **Territory (H7)**: `OuterGate.lean` only. `SharedWitness.lean` / `SubBracket2V.lean` byte-unchanged
  (341 frozen-file gate intact).

## Phases executed

| Phase | Status | Outcome |
|-------|--------|---------|
| B | COMPLETED | `bracketEndChar_kvE2_sound_two_prior_frag` landed green + axiom-clean |
| C | BLOCKED (NO-GO) | `hexcl` machine-confirmed undischargeable |
| D | BLOCKED | gated on C |

## Theorems delivered (this session)

- **`bracketEndChar_kvE2_sound_two_prior_frag`** (`OuterGate.lean`, commit `c508e2a48`) — the ⇒
  soundness half of the k=2 fragment gate. Signature: provider shape (6 order bits + `M` +
  `h_UZ`/`h_SZ` + `x t`) + `hfrag : kvE2_sepFragment qnf` + `hexcl` (negative-sub exclusion family) ⟹
  `.holds → ∃ w, nf_eval_nf M 2 3 [w,x,t] qnf`. Consumes the task-344/345 symmetric-gate fold
  `kvE2_outer_fold_frag` (SW:12529); `hcorrK` discharged inline via `bracketEndChar_kvE2_hck.mp`;
  `hfrag` defeq to the fold's `kvE2_sepFragment_frag`. Axiom-clean `{propext, Classical.choice,
  Quot.sound}`, no `sorryAx`.

## Key decisions

- The pin-anchored **symmetric-gate fold** `kvE2_outer_fold_frag` (post-345) replaced the pre-345
  four-family `kvE2_outer_fold`. The FORWARD-conjunct wall that blocked the prior session no longer
  exists on this path — the interior-gate families are now internal to the fold. This resolved the
  Phase-B blocker recorded in `02_continuation.md`.
- `hexcl` was threaded as a Phase-B hypothesis (not discharged in B) because it is the designated
  Phase-C GO/NO-GO probe.

## Phase C NO-GO (machine-confirmed)

The `hexcl` obligation, after `intro w hxw hwt hptW σ hσneg x1 hreal`, is `⊢ False` with only
`hptW` (w's point type), `hσneg : qnf.2 σ = false`, `hreal : nf_eval_nf M 1 4 [x1,w,x,t] σ` — no
`.holds`, no disjunct. Five candidate closers fail (verbatim in `handoffs/03_continuation.md`):
`kvE2_sepSegForm_excludes` type-mismatches (needs the frozen `kvE2_sepDisjunct'` segment form at
`x1`, never provided); `aesop`/`tauto`/`simp_all` exhaust. Root cause = the
`bracketEndChar_kv_factors` (CarrierKv.lean:422) `(outer zone, projected 1-type)` information ceiling;
same as the pre-345 blocker, now isolated to the single `hexcl` family. `h_UZ`/`h_SZ` are
occurrence well-foundedness (PriorDefs.lean:22/33), not type-exclusion; `P.existF 0` is arity-1
projected. No landed producer exists.

## Final verification

- `lake build …NfMultiAnchorBridge.OuterGate`: green.
- `#print axioms bracketEndChar_kvE2_sound_two_prior_frag`: `{propext, Classical.choice, Quot.sound}`.
- Sorries on live paths: 0. Vacuous defs: 0. New axioms: 0.
- `SharedWitness.lean` / `SubBracket2V.lean`: byte-unchanged (`git status`).

## 309 impact

The k=2 fragment GO gate `bracketEndChar_kvE2_correct_two_prior_frag` is NOT delivered (Phase D
blocked). Available for 309: the ⇐ completeness half (Phase 2, unconditional) + the ⇒ soundness half
modulo `hexcl` (Phase B) + the `kvE2_sepFragment` predicate. The gap is exactly the negative-sub
exclusion, which requires SharedWitness territory (a segment-coverage extractor + a fold-signature
change to thread `.holds` into `hexcl`) or the successor carrier redefinition (321-N2). Both are
outside 335's OuterGate-only territory.

## Deferred / follow-on

- **Successor carrier redefinition** (321-N2): bit-compatibility filtering of the interleaving
  enumeration (O4 SW:6763-6770), O1b/O2/O3 rework — the faithful `hexcl` repair.
- **R-B** (KampPrior.lean:351 wiring): out of scope; awaits the full GO gate.
