# Phase 2 Record — Interior-singleton realizability witness

**Task:** 346 successor_carrier_redefinition
**Session:** sess_1783782450_230288
**Phase:** 2 (Wave 2). Depends on Phase 1 (swapped predicate — landed).
**Status:** COMPLETED — scoped `SharedWitness` build GREEN, axiom-clean, sorry-free.

## Deliverable

`kvE2_sepFragment_realizable` in
`Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness.lean`
(appended ~SW:10265, below the SW:10210 341 GATE banner):

```
theorem kvE2_sepFragment_realizable {sig : MonadicSignature} :
    ∃ qnf : NormalForm sig 2 3, kvE2_sepFragment_frag qnf
```

Plus a private `DecidableEq`-only helper `kvE2_nodup_filter_unique` (Nodup list + predicate true at
exactly one point ⇒ filter = singleton).

## What it proves / why non-vacuous

`kvE2_sepFragment_frag qnf` = `∃ σ0, kvE2_sepPosI qnf = [σ0] ∧ (nf0_zoneSpec σ0.1 = zXW3 ∨ = zWT3)`
(byte-identical to `OuterGate.kvE2_sepFragment`). The witness is the FIRST concrete satisfier of the
swapped (`kvE2_sepPosI`) predicate — the non-vacuity ground Phase 5 cites to replace the two
OuterGate VACUITY NOTEs.

Faithful to report 07 Refutation 1 / H4 #1: the witness `qnf` carries FOUR positive subs:
- `σ0` interior (`nf0_zoneSpec σ0.1 = kvE2_sep_zXW3`), and
- three forced characteristic positives at the at-point zones `zAtX3`/`zAtW3`/`zAtT3`.

Consequences made concrete:
- `kvE2_sepPos qnf` has FOUR elements ⇒ the OLD global-singleton predicate
  (`kvE2_sepPos qnf = [σ0]`) is FALSE for this qnf — matching the "≥3 forced boundary positives"
  unrealizability of the global demand.
- `kvE2_sepPosI qnf = [σ0]`: the interior filter excludes exactly the three at-point positives
  (each fails `zXW3 ∨ zWT3`, discharged by `decide`), leaving the single interior `σ0`.

This is the RE-SCOPE verdict as a machine-checked fact: interior-singleton is realizable where
global-singleton is not.

## Key implementation decisions / deviations

1. **Placement below the banner, stated over `kvE2_sepFragment_frag`.** The plan's "~SW:245" slot
   sits ABOVE the frozen SW:10210 banner (orchestrator constraint forbids edits there) and
   `OuterGate.kvE2_sepFragment` is not visible in `SharedWitness` (OuterGate imports SharedWitness —
   cycle). Both resolved by appending below the banner and using the byte-identical
   `kvE2_sepFragment_frag`; the OuterGate `rfl` defeq bridge lets Phase 5 consume it.

2. **Combinatorial, not model-realized.** `kvE2_sepFragment_frag` is a pure `qnf`-domain predicate
   (its own docstring: "depends only on qnf, never on a model or provider"). So `nf_exists_unique` /
   `OrderedMonadicStructure` are NOT required — the witness `qnf.2` is membership in `{σ0,σX,σW,σT}`
   and each sub's zone is pinned by `nf0_zoneSpec_assemble` (`NfEFold:197`). The report's x<w<t model
   shape is the conceptual justification, realized here as the zone-bit structure of the four subs.

3. **`DecidableEq`-only singleton collapse.** `List.filter_eq`/`List.count` need `BEq`+`LawfulBEq`,
   which `NormalForm sig 1 4` (a `→ Bool` function space) does not have. Replaced by the structural
   `kvE2_nodup_filter_unique` helper. The interior-filter/positivity composition is folded via
   `List.filter_filter` (which orders the combined predicate `interior && mem`), and the three
   at-point interiority-failure facts are `decide`-discharged after `rw [nf0_zoneSpec_assemble facts]`.

## Verification

- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.SharedWitness` — GREEN (exit 0).
- `lean_verify kvE2_sepFragment_realizable` — axioms `{propext, Classical.choice, Quot.sound}`, no
  warnings, no sorry.
- Additive only: no existing decl modified, no edit above the SW:10210 banner. The frozen
  producers (fragL/fragR/kit_sound/clause (v)) and the Phase-1/3/4 landed work are untouched.

## Phase 5 consumption note

Phase 5 (`OuterGate.lean`) can now replace both VACUITY NOTEs with a NON-VACUITY note citing
`kvE2_sepFragment_realizable`. The witness gives `∃ qnf, kvE2_sepFragment qnf` directly (defeq to
`∃ qnf, kvE2_sepFragment_frag qnf`). It establishes only the `hfrag`-satisfiability half of premise
non-vacuity; the full theorem premise set additionally needs a model + the `hexcl`/`hexclExt`/`hreal`
hypotheses (Phase 5 scope; exterior residue → Prop-4.3 successor).
