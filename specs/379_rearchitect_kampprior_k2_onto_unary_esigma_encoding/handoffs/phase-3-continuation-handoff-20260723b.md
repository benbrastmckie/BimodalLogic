# Phase 3/4 Continuation Handoff — sequencing RESOLVED (flip-last), re-encode next

- **Task**: 379 — rearchitect_kampprior_k2_onto_unary_esigma_encoding
- **Plan**: `plans/21_infinite-esigma-alphabet-optionA-v2.md`
- **Status at handoff**: green HEAD `8e02e8779` (Phases 1-2 `[COMPLETED]`; Phase 3 `[IN PROGRESS]`,
  partially advanced). Full `lake build` EXIT 0; `#print axioms completeness_discrete` byte-identical to
  baseline `[propext, sorryAx, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler, Quot.sound]`.
- **Session**: sess_1784829998_2462de
- **Date**: 2026-07-23

## FIRST DECISION POINT — RESOLVED (do NOT re-litigate)

**Sequencing decision (Phase 3↔4): the `sigE` summand flip lands LAST; re-encode the enumeration
surface FIRST.** Full rationale is recorded in the plan as a blockquote under the Phase 3 heading
("SEQUENCING DECISION"). Summary of the decisive finding:

- `UnaryType sig F := NormalForm (sigE sig F) 0 1` (in `ExistsForallFormula.lean:57`). Its
  `Fintype`/`DecidableEq` — load-bearing for `IntervalType := Finset (UnaryType)` (`:87`) and every
  `Finset.univ : Finset (UnaryType)` enumeration — derive ENTIRELY from `Fintype (sigE sig F).preds`,
  i.e. from the finite alphabet (`sigE_fintypePreds` in `ESigmaExpansion.lean:81`).
- Flipping the fresh summand `{A // A ∈ F}` → `Formula` deletes that `Fintype` and breaks the ENTIRE
  `UnaryType`/`IntervalType` surface AT ONCE (the whole ~18-file Phase-4 tree + ζ consumers). So the
  flip and the Phase-4 per-formula re-encode are INSEPARABLE; neither "Phase 3 alone green" nor
  "3+4a together green" is reachable.
- The ONLY green intermediate is **finite alphabet + per-formula `UnaryType`**: do the Phase-4 re-encode
  first WITH `sigE` STILL FINITE (the per-formula rep's `Fintype` comes from `M : Finset (AtomKind …)`,
  NOT the alphabet, so it builds green against the finite alphabet), THEN flip the summand as the small
  terminal green step of Phase 3.
- This is the sanctioned "summand change staged behind a `DecidableEq`-only path" (decidability survives
  the flip; only `Fintype`-finiteness is lost). Faithfulness unchanged — end-state is exactly Def 4.1
  infinite E[Σ] + per-formula rep; only the landing ORDER differs.

## What is done (committed green, HEAD `8e02e8779`)

- Spine-safety re-confirmed: `grep -rln 'sigE\|UnaryType\|IntervalType'` over `BXCanonical/` +
  `Decidability/` is EMPTY. The infinite re-index cannot reach the completeness spine.
- Deleted `ZetaReadbackClosure.lean` (`not_readbackClosed`) and `ZetaEngineClosure.lean`
  (`ReadbackClosed`/`*_of_closed`) — a leaf cluster imported by NOBODY, superseded by the adjudicated
  Option A decision. `OptionBLocalityProbe.lean` PRESERVED.
- Sequencing decision recorded in the plan; Phase-3 tasks 1 & 5 checked off with deviation annotations.

## Next work — the big unit: Phase 4 per-formula re-encode (with `sigE` STILL finite)

Execute in plan order 4a → {4b, 4c}, each landing green off-path (full `lake build` EXIT 0, axioms
byte-identical) and committed. This IS the bulk of the task (~1,500-2,500 lines; 4b is the hardest site).

1. **Phase 4a** (`IntervalType.lean`, `ExistsForallFormula.lean`): re-base `UnaryType`/`IntervalType`
   onto the Phase-1 per-formula representation (`InfAlphabetProbe.lean:86` —
   `UnaryTypeFin sig F M := {a // a ∈ M} → Bool`; `partialIntervalHolds` over `Finset (UnaryTypeFin …)`).
   Re-prove `ofComplete`/`intervalConj`/`intervalBot`/monotonicity + the `efSat` interval-clause bridges.
   Note: re-basing `UnaryType` changes its type signature → ripples through `ExistsForallFormula`
   (`.pointType`, `.intervalType`), `efSat`, and all consumers — expect a Phase-2-style cascade.
2. **Phase 4b** (`LiftPair.lean`, HARDEST — 70 `Finset.univ`): re-encode
   `charType`/`skelDisjunct`/`skelR_sat`/`liftPair_forward`/`liftPair_backward` onto per-formula finite
   atoms. **POST-GATE RISK lives here** (report 20 §3.3): the tuple skeleton disjunction
   `Finset.univ : Finset (Fin (K+1) → UnaryType)` was NOT exercised by the Phase-1 gate. If it cannot be
   re-encoded WITHOUT a full-alphabet `Finset.univ`, STOP and escalate (return-to-gate / `/research`) —
   do NOT force with a global `Finset.univ`. First-class fwd/bwd split fallback available.
3. **Phase 4c** (`Prop43Translate.lean`, `ConjInterleave.lean`): re-encode the remaining `Finset.univ`
   filters; re-establish `translate_correct` (six cases, preserving `StrictMono ψ.pin`) +
   `conjInterleave_iff`/`veeConj_iff`. File-disjoint from 4b (can parallelize).

**GUARDRAIL (critical under this decision):** because the alphabet is still finite during 4a-4c,
`Finset.univ : Finset (UnaryType …)` STILL COMPILES. You MUST route all point/interval finiteness
through per-formula `M`, NEVER a total `Finset.univ` over `UnaryType`/`AtomKind (sigE …)`. Any residual
alphabet-wide `Finset.univ` surfaces as RED at the terminal flip. Before the flip, grep-guard:
`grep -rn 'Finset.univ' Theories/.../Kamp/` and audit each remaining site is NOT typed at
`UnaryType`/`AtomKind (sigE …)`.

## Then — complete Phase 3 (terminal flip, small) and Phase 5

- **Complete Phase 3 (flip, LAST):** in `ESigmaExpansion.lean`, change `sigE`'s summand `{A // A ∈ F}`
  → `Formula`; DELETE `sigE_fintypePreds` (keep/adjust `sigE_decEqPreds` — `Formula` has `DecidableEq`);
  drop `hA : A ∈ F` from `esigmaPred` (→ `Sum.inr A`); update `canonExpand`/`atom_eval_new`/`ESigmaCapture`
  (`canonExpand_atom_named` no longer needs `A ∈ F`). Rebuild; if any re-encoded file breaks, that is the
  guardrail catching a residual alphabet-`Finset.univ` (fix per-formula, or return-to-gate if genuinely
  needs the full alphabet). Then finish check off Phase-3 tasks 2-4 and mark Phase 3 `[COMPLETED]`.
- **Phase 5 (terminal, live-path):** per plan — ζ re-wire (remove `hCapture`/`capFn`, capture discharged
  directly), construct ζ `canonExpand`, spine re-point (`kamp_prior_expressive_completeness` /
  `US_expressively_complete_over_prior` / `no_gaps_discrete_model_surgery`), correct the stale in-file
  audit block in `BXCanonical/Completeness.lean` (name `nf_nvar_exist_all_depths` by declaration), verify
  green with the `| _k+2` residual STILL PRESENT, then DELETE the residual arm LAST; confirm `sorryAx`
  gone from `completeness_discrete`.

## Reusable tooling (from Phase 2)

Guard-scripted instance-threader (idempotent) for cascades that need `[Fintype sig.preds]
[DecidableEq sig.preds]` after `{sig : MonadicSignature}` binders:

```python
import sys, re
path = sys.argv[1]
src = open(path).read()
ins = " [Fintype sig.preds] [DecidableEq sig.preds]"
pattern = re.compile(r'([{(]sig : MonadicSignature[})])(?!\s*\[Fintype sig\.preds\])')
new, n = pattern.subn(lambda m: m.group(1) + ins, src)
open(path, 'w').write(new); print(f"{path}: {n} binders threaded")
```

Bridge-instance lesson: instance search does NOT unfold semireducible `MonadicSignature`-valued defs
(`sigE`, `muSig`, `sigCex`, `mkSigFrom`) — an explicit bridge instance must sit next to the def. After
the flip, `sigE` will no longer have a `Fintype` bridge (correct); it keeps a `DecidableEq` bridge.

## Binding constraints (unchanged)

- Faithfulness to Rabinovich; NO novel mathematics, NO Feferman-Vaught, NO `chain_split`. Option A adjudicated.
- QUARANTINED, do not consume: `kampPrior_hreal_supply`, `charFib`, `igPtWFib`, `igEpLFib`, `igEpRFib`, `igFoldBitFib`.
- Do NOT touch `EANegation.lean:1090`/`:1249`. Retire `nf_nvar_exist_all_depths | _k+2` arm LAST (Phase 5).
- No NEW sorries/axioms; `#print axioms completeness_discrete` byte-identical each phase boundary
  (sorryAx disappears only when the DoD sorry is retired).
- No task-number references in `Theories/**/*.lean`; anchor by declaration name.
- Do NOT delete `OptionBLocalityProbe.lean`.
- Commit at each green boundary; never `git add -A`; never leave the tree dirty at exit (if mid-cascade
  when budget low: `git diff > handoffs/phaseN-wip.patch`, revert to green HEAD, hand off partial).
