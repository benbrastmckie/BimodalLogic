# Task 335 Phase D — Fragment Gate Hand-off for 309 (v8) and 348

- **Session**: sess_1783796165_b5b482_335
- **Date**: 2026-07-11
- **Delivered by**: task 335 Phase D (plan `plans/06_fragment-gate-v6.md`), commit `147af2fbe`
- **Build**: `lake build …NfMultiAnchorBridge.OuterGate` green; full-project green. Axiom check
  via `lake env lean` `#print axioms`: `{propext, Classical.choice, Quot.sound}` for
  `bracketEndChar_kvE2_correct_two_prior_frag`, `_sound_two_prior_frag`,
  `_complete_two_prior` — no `sorryAx` on the interior+boundary path.
- **Frozen-file gate**: `SharedWitness.lean` / `SubBracket2V.lean` byte-unchanged from their
  post-347 state (341's gate + 347's R1 landings intact). All 335 code is in `OuterGate.lean`.

## (1) What 309 consumes — the k=2 interior+boundary GO gate

`bracketEndChar_kvE2_correct_two_prior_frag` (`OuterGate.lean:359`) provides the k=2
interior+boundary GO gate for **309 Phases 13.4/14** and the **`KampPrior.lean:351`** wiring
point, *under `kvE2_sepFragment qnf`* (`OuterGate.lean:210` — interior-singleton
`kvE2_sepPosI qnf = [σ0]`, realizable per `kvE2_sepFragment_realizable`, SW:10265):

```
(hypotheses: provider shape atomMap/h_surj/P + six order bits + M + h_UZ/h_SZ + x t
 + hfrag + hrealI + hrealB + hexcl + hexclExt) :
(bracketEndChar_kvE2 atomMap h_surj P qnf).holds M atomMap x t ↔
  ∃ w : M.carrier, nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf
```

The ⇐ direction is UNCONDITIONAL (Phase 2, `bracketEndChar_kvE2_complete_two_prior`,
`OuterGate.lean:147`); the fragment/interior restriction gates only ⇒. Mirrors
`bracketEndChar_kv_correct_one_prior` (`PriorInterface.lean:95`).

**The realization obligation is indexed by `kvE2_sepPosI`** (`SharedWitness.lean:211` — the
two-zone interior filter of `kvE2_sepPos`), **bounded and jointly-ordered** (Rabinovich
Cor 5.4 ⇐, p.9 l.263–273: `(∃z)^{<z1}_{>z0}` bounded interior witnesses). Verbatim
(`OuterGate.lean:374`, identical at `:288` on the sound half):

```lean
(hrealI : ∀ w : M.carrier, x < w → w < t →
  (kvE2_sepPtW (nf_depth0_char_formula atomMap h_surj) (fun χ => P.existF 0 χ) qnf).eval_at
    M atomMap w →
  ∀ σ ∈ kvE2_sepPosI qnf,
    ∃ x1 : M.carrier, (x < x1 ∧ x1 < t) ∧
      nf_eval_nf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
```

For the n=1 fragment singleton the joint-order coupling of multiple interior witnesses is
vacuous; the shape is recorded interval-bounded so task 348 and the `On` lift consume it
unchanged. NOT the retired global/unbounded `kvE2_sepPos` shape (the phantom obligation
globalized past the bracket — 347 MUST-CHECK 2; `nf_eval_nf`, NormalForm.lean:203–207,
quantifies unbounded, Cor 5.4 does not).

The two remaining provider-side obligations 309's Phase-14 provider discharges alongside
`hrealI`:

- `hrealB` (`OuterGate.lean:380`): the NON-interior-marked remainder of `kvE2_sepPos` (the
  boundary/at-point positives `nf_exists_unique` forces), landed unbounded fold shape —
  realized at the anchors via the endpoint/pivot literals; the interval bound applies ONLY to
  the interior index.
- `hexcl` (`OuterGate.lean:387`): the cone-restricted (`x ≤ x1 ≤ t`) negative-sub exclusion.

## (2) What 348 owns — the exterior-marked `hexclExt` binder (verbatim)

The **provider hand-off to task 348** (`prop43_exterior_reflatten`). Post-347 NARROWED shape
(exterior-marked σ only — the interior-marked slice of the strictly-exterior case is discharged
in-line by the fold via `kvE2_sepInterior_exterior_notRealizable`, SW:12627, task-347 R1
`d370d438e`/`3b8aee3c4`). Verbatim from `SharedWitness.lean:12665` (fold) /
`OuterGate.lean:312`/`:393` (gate), at `charK := fun χ => P.existF 0 χ`:

```lean
(hexclExt : ∀ w : M.carrier, x < w → w < t →
  (kvE2_sepPtW (nf_depth0_char_formula atomMap h_surj) (fun χ => P.existF 0 χ) qnf).eval_at
    M atomMap w →
  ∀ σ : NormalForm sig 1 4, qnf.2 σ = false →
    ¬ (nf0_zoneSpec σ.1 = kvE2_sep_zXW3 ∨ nf0_zoneSpec σ.1 = kvE2_sep_zWT3) →
    ∀ x1 : M.carrier, ¬ (x ≤ x1 ∧ x1 ≤ t) →
      ¬ nf_eval_nf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
```

Faithful mechanism: **Rabinovich Prop 4.3 re-flatten / Lemma 7.6 adjacency** — the exterior
arrangements `x1 < x` / `x1 > t` belong to the **adjacent** intervals `(−∞, x)` / `(t, ∞)`,
handled by separate exterior brackets **composed with the interior `(x,t)` bracket at the
anchors `x, t`** — NOT an exterior-completeness proof on the interior bracket (retired phantom
framing; 347 report 01 §C2/§7; `bracketEndChar_kv_factors` arity-1 information ceiling,
`CarrierKv.lean:422`). Do NOT attempt to discharge this binder from the interior bracket's
hypotheses — machine-confirmed impossible (335 handoff `02`/`03_continuation.md`).

## (3) Consumption shape for 309

309 consumes an **interior+boundary gate + adjacent exterior bracket, seam at `x, t`** — NOT a
single all-arrangement `(x,t)` gate. The `KampPrior.lean:351` wiring (follow-on R-B) threads
`ExistProviders` through `nf_nvar_exist_all_depths`; at k=2 the rung is
`bracketEndChar_kvE2_correct_two_prior_frag` with `hrealI`/`hrealB`/`hexcl` discharged by the
Phase-14 provider instantiation and `hexclExt` supplied by 348's exterior composition.

## (4) Deferred: multi-positive / full `On`

The multi-positive-sub / full `On` case stays DEFERRED to the 321-N2 successor (carrier
redefinition with bit-compatibility filtering, O4 SW:6763–6770). The fragment predicate
`kvE2_sepFragment` (interior singleton) is the sanctioned k=2 scope; `hrealI`'s
interval-bounded, jointly-ordered shape is already stated so the `On` generalization only
extends the index list, not the binder shape.

## (5) Flag for 309's reviser

Check whether the ∀k lift (309 Phase 14) composes with a **fragment-scoped** k=2 rung: the
k=2 gate is conditional on `kvE2_sepFragment qnf` (plus the provider obligations above), while
the k ≤ 1 rungs (`bracketEndChar_kv_correct_zero_prior`/`_one_prior`) are unconditional. The
lift's induction must either (a) restrict the k=2 induction step to fragment `qnf` (and route
non-fragment `qnf` through the 321-N2 successor), or (b) thread the fragment hypothesis + the
provider obligations through the `Nat.rec`. This is a 309-plan decision, not a 335 defect.
