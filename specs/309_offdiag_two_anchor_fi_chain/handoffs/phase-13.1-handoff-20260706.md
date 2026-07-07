# Task 309 Phase 13.1 Handoff — statement surgery (2026-07-06)

## Immediate Next Action (orchestrator routing)

Dispatch **Phase 13.2** (per-sub enriched carrier `bracketEndChar_kvE` — definition + concrete
k=2 instance; report 05 label 13.II-a). Preconditions are met: 13.1 landed GREEN and the 13.0
verdict was F2 CONFIRMED (full-ladder branch). Then 13.3 → 13.4 → 14.

## Current State

- Phase 13.1 [COMPLETED]; v6 heading count: **12 of 16** complete (1-5, 6.1, 9-12, 13.0, 13.1).
- `lake build` full tree GREEN (1709 jobs).
- Diff this dispatch: additive-only — 1 Lean file (NfMultiAnchorBridge.lean), 97 insertions,
  0 deletions. All preserved assets byte-identical (`bracketEndChar_kv` :3630+8=:3638 region,
  landed lifts, F1/F2 records, `BracketCarrierCorrectV`).
- Commit: `1a11acf6f` (`task 309 phase 13.1: statement surgery — …`).
- New sorries: 0. `lean_verify` on both `_prior` lifts: exactly
  `[propext, Classical.choice, Quot.sound]`.

## Deliverables landed (NfMultiAnchorBridge.lean, current line numbers)

| Item | Line | Notes |
|---|---|---|
| `import …Kamp.EANegationClosure` | :4 (+NOTE :6-12) | **LANDED cycle-free** (compile-verified; fallback NOT needed). Transitively supplies PriorINF (`HasAttainedINF`:202 / `prior_hasAttainedINF`:224) and the Lemma 5.1 / Cor 5.4 / Prop 4.2 negation-stack assets for 13.2-13.4 |
| Section doc (A1 §d + N1 split) | :4831 | |
| `structure ExistProviders` | :4853 | exact report-05 Pillar 1 signature (existF + UZ/SZ-conditional `correct` over `insertEnv`) |
| `def BracketCarrierCorrectVPrior` | :4875 | six order hypotheses via `NormalForm.atom_assgn` (defeq `qnf` at k=0 / `qnf.1` at k+1 — the only binder adjustment, documented); then `M`, `h_UZ`, `h_SZ`, `x t`, concluding the bracket-witness `↔` |
| `bracketEndChar_kv_correct_zero_prior` | :4895 | drop-hypotheses delegation to `bracketEndChar_kv_correct_zero` |
| `bracketEndChar_kv_correct_one_prior` | :4910 | drop-hypotheses delegation to `bracketEndChar_kv_correct_one`; retains `h0 : charF 0 = nf_depth0_char_formula …` |

Note: the top-of-file import block grew by 8 lines, so all pre-13.1 line references in earlier
handoffs/records shift by +8 in the current file (e.g. landed k=0/k=1 lifts now :3796/:3824).

## Phase-13.2 entry points

- **Target**: `noncomputable def bracketEndChar_kvE {sig} (atomMap …) (h_surj …)
  (P : ExistProviders sig atomMap k) : BracketEndCharCarrierV sig (k + 1)` — per-sub read of
  `qnf.2` over **positive subs** `σ : NormalForm sig k 4`, NOT through
  `(ZoneSpec 3 × NormalForm sig k 1)` fibers (plan :692-741; report 05 Pillar 2).
- **Consume, do NOT rebuild**: `ExistProviders` (:4853 — the provider parameter, A1);
  `bracketFromLists` (:1896 post-shift); `VVecEA2` machinery; `nf_quant_layer_fold_iff`
  (NfEFold:391) inside-out per amendment A2; `nf0_split_assemble` per plan.
- **Guards**: G2, G4, G6-as-amended, A1 (provider parameter), A2 (per-sub read + inside-out
  fold discharge; NO navigated arity-3/4 characteristic, NO third anchor).
- Do NOT edit `bracketEndChar_kv` (stays as landed k≤1 instance + F1 exhibit); do NOT edit
  `BracketCarrierCorrectV`/`BracketCarrierCorrectVPrior`.

## Key Decisions

1. **Import edge landed, not fallback**: static import-graph analysis (only KampPrior imports
   the Bridge; EANegationClosure's closure = EANegation, VecEAClosure, VecEAFormula, PriorINF,
   ExistsForallNF, PriorDefs, MonadicFO, Table) + compile verification. The 13.0 direct
   `PriorDefs` import is kept (additive discipline; now redundant but harmless).
2. **Uniform atom-layer access via `NormalForm.atom_assgn`** (NormalForm:151): the plan left
   the six order hypotheses' k-generic form open; `atom_assgn` gives the k0-mirror shape at
   every depth and reduces definitionally at the k=0/k=1 lift sites, so both lifts are pure
   term-mode applications of the landed lemmas (no rewriting needed).
3. **Plan-exact binder names kept** (`h_UZ`/`h_SZ` in the predicate): produces two cosmetic
   `unusedVariables` lint warnings at :4884-4885 — accepted to keep the normative report-05
   signature verbatim.
4. **Provider conditionality is use-site**: `BracketCarrierCorrectVPrior` takes no provider
   argument; A1's provider conditionality enters when the predicate is applied to the
   provider-parameterized `bracketEndChar_kvE` (13.2+), as documented in its doc-comment.

## Sorry Inventory (unchanged — no new; inherited live-path baseline)

- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean:351` — strategic (task-309
  target); discharged by Phase 14 after the ladder lands.
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean:354` — deliberately remains;
  owned by task 305.
- (Pre-existing elsewhere: EANegation.lean:1090/:1249 and Bundle/Boneyard files — untouched,
  outside task 309 scope.)

## References

- Plan: `specs/309_offdiag_two_anchor_fi_chain/plans/06_offdiag-fi-chain-plan.md`
  (Phase 13.1 heading carries the completion record; Phase 13.2 is next).
- Report: `specs/309_offdiag_two_anchor_fi_chain/reports/05_k2-vocab-enrichment-redesign.md`
  (Pillar 1 realized this phase; Pillar 2 feeds 13.2).
- Previous handoff: `handoffs/phase-13.0-handoff-20260706.md` (F2 verdict + probe inventory).
- Commit this dispatch: `1a11acf6f`.
