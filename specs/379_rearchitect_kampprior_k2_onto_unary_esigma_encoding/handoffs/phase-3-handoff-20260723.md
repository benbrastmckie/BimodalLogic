# Phase 3 Continuation Handoff — Re-index `sigE` onto the infinite `Formula` alphabet

- **Task**: 379 — rearchitect_kampprior_k2_onto_unary_esigma_encoding
- **Plan**: `plans/21_infinite-esigma-alphabet-optionA-v2.md`, Phase 3
- **Status at handoff**: Phase 2 `[COMPLETED]` and committed (green HEAD `c36281a91`); Phase 3 is the resume point.
- **Session**: sess_1784829998_2462de
- **Date**: 2026-07-23

## What is done (committed, green)

Phase 2 is fully complete and committed. The `[fintypePreds]`/`[decEqPreds]` instance fields are
removed from `MonadicSignature`; the whole abstract-`sig` `NormalForm`/`Fintype` surface (~45 files)
now threads explicit `[Fintype sig.preds] [DecidableEq sig.preds]` hypotheses. Full `lake build`
EXIT 0; no new sorries; `#print axioms completeness_discrete` byte-identical to baseline
`[propext, sorryAx, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler, Quot.sound]`; and an
infinite-alphabet signature (`preds := Formula`, `Infinite`) is now constructible.

**Do NOT re-do Phase 2.** Start from the committed green HEAD.

### Reusable tooling from Phase 2

A guard-scripted binder-threader was used to insert `[Fintype sig.preds] [DecidableEq sig.preds]`
after every `{sig : MonadicSignature}` / `(sig : MonadicSignature)` decl binder in a file (idempotent
— skips binders already followed by `[Fintype`). If Phase 3's re-index triggers another
instance-threading cascade, recreate it:

```python
import sys, re
path = sys.argv[1]
src = open(path).read()
ins = " [Fintype sig.preds] [DecidableEq sig.preds]"
pattern = re.compile(r'([{(]sig : MonadicSignature[})])(?!\s*\[Fintype sig\.preds\])')
new, n = pattern.subn(lambda m: m.group(1) + ins, src)
open(path, 'w').write(new)
print(f"{path}: {n} binders threaded")
```

Workflow that worked: `lake build` (full) → collect the one/two error files per wave → run the
threader on each → `lake build <module>` to confirm green → repeat. ~30 waves total for Phase 2.

### Key design lesson for Phase 3 (semireducible signature defs)

Instance search does NOT unfold semireducible `MonadicSignature`-valued `def`s (`sigE`, `muSig`,
`sigCex`, `mkSigFrom`). When a decl needs `Fintype (someSig sig).preds` / `DecidableEq (someSig
sig).preds`, an **explicit bridge instance** must be stated next to the signature def, e.g.:

```lean
instance muSig_fintypePreds (sig : MonadicSignature) [Fintype sig.preds] :
    Fintype (muSig sig).preds := inferInstanceAs (Fintype (sig.preds ⊕ Unit))
```

Bridge instances added in Phase 2 (do not remove): `sigE_fintypePreds`/`sigE_decEqPreds`
(`ESigmaExpansion.lean` — pre-existing from the foundational patch), `muSig_fintypePreds`/
`muSig_decEqPreds` (`EFGames/TypeFormulas.lean`), anonymous `Fintype/DecidableEq sigCex.preds`
(`NfMultiAnchorBridge/Base.lean`), `instFintypeMkSigFromPreds`/`instDecEqMkSigFromPreds`
(`Transfer.lean`).

## Phase 3 — what to do (from the plan)

Change `sigE sig F`'s fresh summand from `{A // A ∈ F}` (finite) to the full `Formula` type
(infinite E[Σ], Rabinovich Def 4.1 p.5). Concretely (plan §Phase 3 tasks):

1. Re-confirm spine-safety: `grep -rln 'sigE\|UnaryType\|IntervalType'` over `BXCanonical/` and
   `Decidability/` (expect empty) before committing the re-index.
2. Change `sigE`'s fresh summand `{A // A ∈ F}` → `Formula` (`ESigmaExpansion.lean`), constructed
   with the Phase-2 explicit-finiteness form. **NOTE:** `sigE_fintypePreds` currently reads
   `inferInstanceAs (Fintype (sig.preds ⊕ {A // A ∈ F}))` — once the summand is `Formula`,
   `(sigE sig F).preds = sig.preds ⊕ Formula` is NO LONGER a `Fintype` (Formula is infinite). This
   is the CRUX: the `sigE_fintypePreds` instance must be DELETED, and every downstream decl that
   depended on `Fintype (sigE ...).preds` (i.e. `Fintype (UnaryType)`, `Finset.univ` enumerations)
   breaks — but those are exactly the sites Phase 4 re-encodes onto per-formula-finite atom sets.
   Coordinate the Phase 3/Phase 4 boundary carefully: Phase 3 changes the type; Phase 4 fixes the
   enumeration surface. Expect Phase 3 alone to leave `IntervalType.lean` and its ~18-file consumer
   tree RED until Phase 4 — which conflicts with Phase 3's "full lake build EXIT 0" DoD. **Re-read
   the plan's Phase 3↔4 sequencing before starting; the DoD may require Phases 3 and 4a to land
   together, or the summand change to be staged behind a `DecidableEq`-only path.** This sequencing
   question is the first thing to resolve — possibly a `/research` or `/revise` question, not
   mechanical work.
3. Update `esigmaPred`/`oldPred`/`canonExpand` so `esigmaPred A` takes no `hA : A ∈ F` proof; the
   fresh atom's interp stays `sat A` (`ESigmaExpansion.lean`).
4. Update `ESigmaCapture` so `canonExpand_atom_named` no longer requires `A ∈ F`.
5. DELETE `ZetaReadbackClosure.lean` (`not_readbackClosed`) and `ZetaEngineClosure.lean`
   (`ReadbackClosed`/`*_of_closed`) — vacuous under infinite E[Σ]. **PRESERVE
   `OptionBLocalityProbe.lean`.**

## Binding constraints (unchanged)

- Faithfulness to Rabinovich; NO novel mathematics, NO Feferman-Vaught, NO chain_split. Option A.
- QUARANTINED, do not consume: `kampPrior_hreal_supply`, `charFib`, `igPtWFib`, `igEpLFib`,
  `igEpRFib`, `igFoldBitFib`.
- Do NOT touch `EANegation.lean:1090`/`:1249` (permitted sorries). Retire
  `nf_nvar_exist_all_depths | _k+2` arm sorry in `KampPrior.lean` LAST (Phase 5, terminal).
- No NEW sorries or axioms. No task-number references in `Theories/**/*.lean`.
- `#print axioms completeness_discrete` must stay byte-identical to baseline.

## Do NOT

- Do NOT re-introduce a global `Fintype preds` / `DecidableEq preds` field on `MonadicSignature`.
- Do NOT delete `OptionBLocalityProbe.lean`.
- Do NOT force Phase 3 green with a global `Finset.univ` over the now-infinite alphabet — that is the
  Phase-4 re-encoding's job; if Phase 3 cannot reach the stated DoD without it, that is a
  sequencing/return-to-plan signal, not a place to invent mathematics.
