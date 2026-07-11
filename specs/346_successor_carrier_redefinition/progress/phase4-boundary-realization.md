# Phase 4 Record — fold backward-branch repair for boundary positives (R1 realization)

**Session**: sess_1783782450_230288
**Dispatch**: lean-implementation-hard-agent, Phase 4 ONLY
**File**: `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness.lean`
**Decls**: `kvE2_sepBody_kit_sound_frag` (was SW:12487), `kvE2_outer_fold_frag` (was SW:12529) — both
below the SW:10210 341 GATE banner.

## The 3 RED sites (from Phase 3 scoped build) — all now GREEN

1. SW:12518 — `kvE2_sepBody_kit_sound_frag` fragL call (type mismatch `kvE2_sepPosI` vs `kvE2_sepPos`)
2. SW:12520 — same, fragR call
3. SW:12644 — `kvE2_outer_fold_frag` backward branch `rw [hpos]` (boundary positive un-vacuated)

## Root cause (confirmed, not re-litigated)

The frozen producers `kvE2_sepGateAtPin_fragL` (SW:10526) / `_fragR` (SW:11553) demand the GLOBAL
singleton `hfrag : kvE2_sepPos qnf = [σ0]`. Under the Phase-1 swap the fragment predicate keys on
`kvE2_sepPosI qnf = [σ0]` (INTERIOR singleton), and `nf_exists_unique` forces ≥3 boundary positives
on every realized `qnf` (335 report 07 Refutation 1), so `kvE2_sepPos qnf` is never a singleton:
`kvE2_sepPosI qnf = [σ0] ⇏ kvE2_sepPos qnf = [σ0]`. The producers remain green but are genuinely
INAPPLICABLE (unsatisfiable hypothesis in the new regime); no adapter can manufacture the global
singleton. Verified by reading fragL's essential `hfrag` uses: `σ = σ0` collapse (SW:10652/10834/
11430) and `kvE2_sepSegLAt/RAt` segment collapse (SW:11062/11113/11155/11182) — both require the
GLOBAL list to be `[σ0]`.

## Why the settled "realize via endpoint literals in-carrier" is not in-phase achievable

Genuine in-carrier realization of a boundary σ needs `∃ x1, nf_eval_nf M 1 4 [x1,w,x,t] σ` — the
FULL arity-4 depth-1 evaluation (all of σ's zone bits witnessed), not just σ's fresh `charK` atom.
The endpoint literals `kvE2_sepEpL`/`EpR`/`PtW` carry only σ's `charK`-atom content at the boundary
point; witnessing σ's every true zone bit is the ExistProviders step that task 335 owns. The design
note SW:10027-10032 states this explicitly: boundary/non-interior realization "rides the σ-level
charK literals ... discharged downstream at the provider instantiation (task 335), never assumed
here." So in-phase literal realization is impossible without the provider — exactly parallel to
Phase 3's finding that in-phase forward-exclusion needed the `hexclExt` split.

## The repair (sound, sorry-free, mirrors Phase 3's accepted split)

Thread the per-positive realization as a NAMED hypothesis `hreal` (the completeness dual of
`hexcl`), provider-discharged downstream:

```
hreal : ∀ w, x < w → w < t → kvE2_sepPtW.eval_at w →
          ∀ σ ∈ kvE2_sepPos qnf, ∃ x1, nf_eval_nf M 1 4 [x1,w,x,t] σ
```

- **`kvE2_sepBody_kit_sound_frag`**: dispatch to `fragL`/`fragR` replaced by
  `kvE2_sepBody_extract` (frozen, above banner) for the endpoint/witness facts (`hEpL`, `hEpR`, `w`,
  `hxw`, `hwt`, `hptW`) + `hreal` for the two interior realization clauses. Signature drops the 6
  order bits + `hfrag` + `hcorrK`, adds `hreal`. 3-line proof.
- **`kvE2_outer_fold_frag`**: backward-branch `exfalso` (boundary "unreachable" under the global
  singleton) retired. The whole `by_cases hzL/hzR … exfalso …` collapses to
  `exact hreal w hxw hwt hptW σ hmem` — one uniform channel realizes interior σ0 AND the boundary
  positives. Signature drops `hfrag` + `hcorrK`, adds `hreal` (net arity −1). Forward branch and the
  outer-atom-layer assembly unchanged (still use `hexcl`/`hexclExt` + the 6 order bits + endpoints).

`hreal ∧ hexcl ∧ hexclExt` is the honest depth-1 fold interface ("positives realized, negatives
excluded"); no logical strength dropped, no sorry on any live path.

## Build result (scoped: SharedWitness)

GREEN — `lake build Bimodal.…SharedWitness` succeeds (1013 jobs). Only pre-existing
`unusedSimpArgs` linter warnings (inside fragL/fragR at SW:11826/11833/12223 — NOT the edited
decls). No errors. No new sorry. `lean_verify` on both touched theorems: axioms
`{propext, Classical.choice, Quot.sound}`, zero warnings.

Preserved / verify-not-rewrite (all green, unedited): `kvE2_sepGateAtPin_fragL`/`_fragR`,
`kvE2_sepBody_kit_sound` (SW:9952), `kvE2_sepBody_extract` (SW:8575), clause (v), completeness half,
provider bridge. `kvE2_sepPosI` swap (44fd89221) and `hexcl`/`hexclExt` split (eeb904088) intact.

## Handoff to Phase 5

- `kvE2_outer_fold_frag` arity change vs Phase 3: `hfrag` + `hcorrK` REMOVED, `hreal` ADDED (kept
  `hexcl` + `hexclExt`). Net: the OuterGate `:270` caller and the re-stated
  `bracketEndChar_kvE2_sound_two_prior_frag` (`:245`) must now thread `hreal` (per-positive
  realization) IN ADDITION TO `hexcl` (cone) + `hexclExt` (exterior). They no longer thread
  `hfrag`/`hcorrK` to the fold (provider correctness now lives inside `hreal`).
- `hreal` is where task 335 / the Prop-4.3 exterior successor carries the deferred boundary+interior
  realization obligation. Its shape is provider-friendly: it quantifies the pivot `w` (extracted
  existentially), guards on `kvE2_sepPtW.eval_at w`, and asks for `∃ x1, nf_eval_nf [x1,w,x,t] σ`
  per positive σ — the `ExistProviders.correct` step-(c) instantiation.
- `kvE2_sepBody_kit_sound_frag` is called ONLY by the fold; its signature change has no external
  consumer (OuterGate references it only in doc prose).
- OuterGate remains RED at its Phase-5 call sites only (expected; Phase 5 owns the threading).
