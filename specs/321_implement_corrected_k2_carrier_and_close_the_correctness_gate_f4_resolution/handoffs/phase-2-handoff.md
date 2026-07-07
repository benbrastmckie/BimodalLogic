# Task 321 — Phase 2 Handoff (BLOCKED)

## Immediate next action
`/revise 321` — amend the design spec (task-320 report §5) to close the two gaps below, OR
`/spawn 321` — decompose the Phase 7-8 correctness-gate proof as its own task.

## Current state
- **Phase 1**: COMPLETE. Scoped build green (1005 jobs). `git diff` clean on
  `NfMultiAnchorBridge.lean`. F4 ℤ counterexample recorded in-file (:5584-5595). Task-320 probes
  present (:5634-5698).
- **Phase 2**: BLOCKED. See plan file's Phase 2 BLOCKER section for the full record.
- **Phases 3-9**: NOT STARTED (gated behind Phase 2).
- **Lean file**: byte-identical to the green baseline commit. No `sorry`, no vacuous def, no flat
  carrier, no new axiom. All scratch probes removed.

## Key decisions / findings (machine-grounded)
1. `σ.2` on `σ : NormalForm sig k 4` (general `k`) → Lean error "does not have fields"
   (`NormalForm sig k 4` reduces to a pair only for a literal successor `k`;
   NormalForm.lean:134-136). Successor form `(σ : NormalForm sig (k+1) 4)` builds green.
2. The design spec §5(1) general-`k` `kvE_subBracket` signature is therefore unrealizable as written;
   a `k`-matching (successor-sub) reformulation of `kvE'_body`/`kvE2_body` is required but not supplied.
3. The concrete `pointTypes`/`segmentTypes` encoding from `σ.2` is under-specified; inventing it is
   unvalidatable without the Phase 7-8 gate and risks the F3/F4-refuted flat variant.
4. No proven k≥2 enriched-carrier `BracketCarrierCorrectVPrior` exists (only simple
   `bracketEndChar_kv` at k=0/k=1, :4899/:4915; enriched k=2 gates :5203/:5532 are NO-GO F1/F4).

## What to resume with (once unblocked)
- A concrete `kvE_subBracket` Lean term (successor-sub, explicit inner-NF → bracket encoding).
- Then Phases 3-6 (kvE_subChain + recovery lemma via `bracket_implies_fChainPred`; kvE2_body splice;
  bracketEndChar_kvE2 + two_eq).
- Then Phases 7-8 (novel k=2 gate proof — treat as multi-phase; no reusable precedent).

## Reference anchors
- Design spec: `specs/320_.../reports/02_jointpinning-probe-results.md` §5.
- Machinery: `BracketFormula` (VecEAFormula:128), `fChainFrom`/`fChainPred`/
  `bracket_implies_fChainPred` (EANegation:552-698), `nf_eval_nf` (NormalForm:198-207),
  `BracketCarrierCorrectVPrior`/`ExistProviders` (NfMultiAnchorBridge:4853-4888),
  `kvE'_body`/`kvE_pinDisjunct`/`kvE_exclConj` (:5374-5530).
