# Task 348 Phase 2 Progress — R2 GO/NO-GO Spike

## VERDICT: GO (conditional-complete under the pinned gate inventory)

One concrete future-side `zFutT3`-marked σ-clause, BOTH directions sorry-free and axiom-clean
`{propext, Classical.choice, Quot.sound}`. File:
`Theories/Bimodal/Metalogic/WeakCanonical/Kamp/ExteriorNegation.lean` (839 lines).

## The spike σ (`kvE2_futSpikeSigma qnf χmid χfr`)

Non-degenerate (R3): a `zFutT3`-marked depth-1 σ whose inner layer `σ.2` genuinely prescribes
depth-1 content across all nine `[x1,w,x,t]` zones — below-`t` zones tied to qnf's positive
layer via `kvE2_futAnyBit`, the gap `(t,x1)` all-and-only `χmid`, the fresh point `x1` of
profile `χfr`, the ray `(x1,∞)` empty. Both correctness proofs exercise the full
`nf_eval_depth1_fold_iff` fold over every `ZoneSpec 4 × NormalForm sig 0 1`.

## The clause (`kvE2_extNegFutSpike atomMap h_surj χmid χfr`)

`(kvE2_futSpikePos).neg` where `kvE2_futSpikePos = U(χmid ∧ U(χfr∧¬F⊤, χmid), χmid)` anchored at
`t` — the length-2 `Until`-navigated positive local-existence form (Lemma 5.3 / 7.10 shape). A
fixed syntactic object in `(atomMap, h_surj, χmid, χfr)` — model-independent.

## Delivered lemmas (all axiom-clean)

- `kvE2_futAnyBit` + `kvE2_futAnyBit_correct` — the model-independence CRUX: the syntactic
  Bool `kvE2_futAnyBit qnf zs χ` equals the semantic zone fact under realized qnf, FOR EVERY
  zs. This is the B.1-obstructed comparison that report-18 says is impossible for arbitrary
  clauses; proved outright here for the specific finite family.
- `kvE2_futSpikeSigma` / `kvE2_futSpikeSigma_bits` — the spike σ + fold-bit computation.
- `kvE2_extNegFutSpike_sound` — `clause@t ⇒ ∀x1>t ¬realize`; hypotheses `(hxw, hwt)` ONLY (the
  `hexclExt` binder inventory), no semantic hypothesis on M. Discharges `hexclExt` for the spike.
- `kvE2_extNegFutSpike_complete` — `(∀x1>t ¬realize) ⇒ clause@t`; hypotheses `(hxw, hwt, henv,
  hbelow)`. Reconstructs a full exterior realizer from a realized positive-existence form.
- Support: `kvE2_futSpikeSigma_atom`, `kvE2_futBelowClass`, `kvE2_futCharZone3'`/`4`,
  `futZoneBit_gap`/`selfx1`/`ray`/`below`, `kvE2_futZone4_of_above`/`below_iff`,
  `nf_depth0_char_correct'`, `nf_profile_unique`/`exists`/`nf_eval_profile_iff`.

## Why the pins are IRREDUCIBLE (the R2 finding)

The bare-binder converse `(∀x1>t ¬realize) → clause` is FALSE for every clause expressible at
`t`, via two machine-grade counterexample shapes (documented verbatim in the file header):
1. **Anchor-base escape** — a model whose `[w,x,t]` base differs from `qnf.1` makes σ
   unrealizable invisibly while the `(t,∞)`-side clause content is satisfiable. Closed by `henv`.
2. **Below-`t` bit-flip** — the realized characteristic with one at-or-below-`t` inner bit
   flipped is bit-false, `zFutT3`-marked, `(t,∞)`-realized, and `t`-indistinguishable. Closed
   by `hbelow` (+ the syntactic `kvE2_futAnyBit` comparison inside `σ.2`).
These pins are EXACTLY the gate-level hypotheses available at the sole consumption site
(SW:12788 forward direction / Phase-8 ⇐ half from realized qnf). Hence GO-conditional per the
plan's NO-GO-protocol step 2, adopted as the binding signature.

## BINDING SIGNATURE for Phases 3-6 (H6)

- `kvE2_extNegFut{Fut|Past} σ : Formula` = `(Until/Since-navigated positive local-existence
  form).neg`.
- `_sound` under `(hxw, hwt)` only; `_complete` under `(hxw, hwt, henv, hbelow)`.
- Any drift is churn (H6). `HasAttainedINF`/`prior_hasAttainedINF` NOT needed at this rung
  (finite chain + `¬F⊤` ray emptiness); Dedekind-completeness enters only if Phase 3 meets
  unbounded positive content (budgeted for Phase 3).

## Verification

- Scoped + full `lake build` green (1721 jobs). `grep sorry` = 0 (only "sorry-free" in docstring).
- `#print axioms` on `_sound`, `_complete`, `kvE2_futAnyBit_correct`, `kvE2_futSpikeSigma` =
  `{propext, Classical.choice, Quot.sound}`.
- Preserved assets untouched (SharedWitness/SubBracket2V/OuterGate read-only; new file only).

## Commits
- b93f8ff2e constructions + model-independence bridge
- 87d319eea soundness direction
- 8a5fcc6fe completeness atom-layer helper
- dd85dbd92 completeness direction — GO verdict
