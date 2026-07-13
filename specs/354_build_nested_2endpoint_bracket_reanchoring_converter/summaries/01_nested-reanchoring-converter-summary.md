# Task 354 — Nested 2-Endpoint Bracket Re-Anchoring Converter: Implementation Summary

- **Task**: 354 — Build the FAITHFUL nested 2-endpoint bracket re-anchoring converter
- **Status**: COMPLETED (all 6 phases green, sorry-free, axiom-clean, frozen-clean)
- **Type**: lean4
- **Plan**: plans/01_nested-reanchoring-converter.md
- **Research**: reports/01_nested-reanchoring-converter.md

## Outcome

Delivered the reverse-direction exterior converter that closes task 352's blocked `_complete`
halves, in two NEW sibling modules under
`Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/`:

- `ExteriorConverterK.lean` (227 lines) — Future `kvE_extNegFut_complete` + helpers.
- `ExteriorConverterPastK.lean` (196 lines) — Past `kvE_extNegPast_complete` + helpers.

Both primary theorems verify with axioms EXACTLY `[propext, Classical.choice, Quot.sound]`,
sorry-free. Full-project `lake build` green (1724 jobs). All 10 frozen files byte-identical.

## Deliverables (all green)

| Symbol | Module | Role |
|--------|--------|------|
| `kvE_extNegFut_complete` | ExteriorConverterK | Future reverse of `kvE_extNegFut_sound` |
| `kvE_extNegPast_complete` | ExteriorConverterPastK | Past reverse of `kvE_extNegPast_sound` |
| `kvE_futAtom_of_bundle` / `kvE_pastAtom_of_bundle` | both | atom layer at `[x1,w,x,t]` via the carried bundle |
| `kvE_futAdmissible_*` / `kvE_pastAdmissible_*` | both | off-fiber falsity / on-fiber recording readers |
| `kvE_futBundle_of_realizer` / `kvE_pastBundle_of_realizer` | both | Phase-5 outer-recursion discharge template (Option B) |

## Key construction

The `_complete` is the reverse of the green `_sound`: assume `kvE_futPos`/`kvE_pastPos` at the
anchor, destruct the Cor 5.4 chain (`kvE_futChainDestructG` / `kvE_pastChainDestructG`) to an
exterior endpoint `x1`, and reassemble `nf_eval_nf M (k+1) 4 [x1,w,x,t] σ` via
`nf_eval_nfk_iff_efold`:
- **atom layer** — recovered by routing ONE bit-true sub (always present because a reached
  endpoint forces the self-zone content nonempty) through the carried `hreal` bundle +
  `nf_eval_nf0_cons_factor` (`kvE_futAtom_of_bundle`);
- **fold biconditional forward** (`σ.2 s → ∃v`) — the carried `hreal` bundle;
- **fold biconditional backward** (`∃v → σ.2 s`) — the carried saturation residue `hsat`;
- **off-fiber falsity** — admissibility conjunct 2.

Contradicting the carried `hcl` closes the clause.

## Phase 3 branch decision — BRANCH B (carried residue)

The mandated Phase-3 probe determined the fiber-backward converse is **provably not derivable
in-module**: an unrecorded-but-realizable on-fiber sub (`σ.2 s = false` yet realizable at the
reconstructed anchor) would break the fold biconditional while leaving the recorded gap chain
intact, so the bare converse of `_sound` is FALSE. This is the F2 obstruction at arity 5 (task 352
report 03 Deliverable 2: env-free profiles do not generalize to `k ≥ 1`). Resolution: carry the
exterior-anchor saturation as ONE named hypothesis `hsat` (the depth-`k` `hexclExt` analog),
discharged one level up by the outer recursion / task-349 provider — NOT a sorry, NOT debt. Phase 5
proves the carried `hreal`/`hsat` pair is dischargeable from a genuine realizer
(`kvE_futBundle_of_realizer` / `kvE_pastBundle_of_realizer`). Phase 4 (Past) mirrored Branch B.

## Non-goals honored

- Did NOT re-attempt the flat `extF4` converter (task 353 refuted).
- Did NOT add an additive general-model realizability transfer lemma (task 352 refuted F2).
- Did NOT edit any frozen file; did NOT consume the DEAD Boneyard arity-3 carrier.
- Did NOT discharge `hreal`/`hsat` in-module (carried, F2); did NOT land any sorry/vacuous def.

## Plan Deviations

- **Phase 3 helper `kvE_futEnd_forces_atom`** — *altered*: superseded by the provable
  `kvE_futAtom_of_bundle` (bundle route recovers the atom layer without the env-free saturation the
  original signature assumed).
- **Phase 3 helper `kvE_futFiber_backward`** — *altered*: folded into the carried `hsat` residue
  (Branch B) rather than proved in-module (provably underivable — see Phase 3 decision).
- **Phase 2 helper `kvE_futReal_of_bundle`** — *skipped*: the `hreal` bundle feeds the fold
  biconditional's `←` direction directly; no separate per-gap-item adapter was needed.
- **Phase 1 signature** — *altered*: the carried saturation binder `hsat` (Branch B) was added to
  both `_complete` signatures beyond the research Deliverable-1 shape (which had only `hreal`).
- **Phase 5 Option B** — *altered*: realized as the anchor-determinacy discharge template
  (`kvE_*Bundle_of_realizer`) rather than a redundant `kvE_subBit_iff` below-`t` re-wrap
  (`kvE_subBit_iff` needs a realized σ; the below-`t` bucket read is already green infra).

## Verification

- `lake build` (full project): green, 1724 jobs.
- `lean_verify kvE_extNegFut_complete` → axioms `[propext, Classical.choice, Quot.sound]`, 0 sorry.
- `lean_verify kvE_extNegPast_complete` → axioms `[propext, Classical.choice, Quot.sound]`, 0 sorry.
- Frozen git-diff: EMPTY on all 10 frozen files.
- New source files: exactly the two new modules (423 insertions).
