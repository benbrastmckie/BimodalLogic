# Task 358 — Phase 2 handoff (v04 plan): G2 gate NO-GO / [BLOCKED]

**Session**: sess_1784045100_2e3ffe · **Date**: 2026-07-14 · **Plan**: plans/04_realizer-recursion-v04.md

## Immediate next action

`/spawn 358` an isolated interface-refinement task: strengthen task 363's fiber-consistency
mate check so it is not defeatable by a planted unrealizable interior mate (see "What is needed"
below). Do NOT re-attempt G2 (plan P2/P3) against the 363 interface as landed — it is
machine-refuted (route R2 probe, sorry-free).

## Verdict

**P2 = NO-GO ⇒ Phase 2 [BLOCKED].** The plan v04 re-key of the G2 exterior slice supply
(rows 8-11) to task 363's `kvE_fiberConsistent` guard does NOT close the m=1 doppelgänger
countermodel at binder strength. The countermodel ADAPTS via a planted interior mate.

## The residual hole (minimal failing obligation shape)

`kvE_fiberElemConsistent`'s mate check (`ExteriorFiberConsistencyK.lean:52-55`):
```
mergeNF e.atom_assgn ⟨1,_⟩ = s'.atom_assgn   -- over some σ-marked s'
```
compares ONLY atom rows — no realizability / consistency-nontriviality / fresh-projection
constraint on the mate `s'`. 363 rejected `σ = τ ⊕ s*` because `s*`'s inner witness `e_P` had
no atom-mate (`kvE_probe363_fake_elem_inconsistent`). Planting
`mate := (mergeNF e_P.atom_assgn ⟨1,_⟩, fun _ => false)` supplies exactly that missing atom row:
- on-fiber (drop-drop = doppelgänger 4-row = `τ.1`);
- vacuously elem-consistent (`.2` constantly false);
- interior-zoned (fresh `20 ∈ (15,18)` vs anchors `[25,15,2,18]`), so invisible to all three
  exterior zone lists ⇒ `σ₂ := τ ⊕ s* ⊕ mate` is slice-equal to `σ` and the `hsliceFut`
  conclusion still fails (`s*` pinned-unrealizable, `m1_no_marked_mate` carries over).

## Decisive certificate (sorry-free, green, floor axioms)

`Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorPinnedProbe358K.lean`
- `kvE_probe358_eP_atomMate_present` : `∃ s', m2sigma.2 s' = true ∧ mergeNF m2eP.atom_assgn ⟨1,_⟩
  = s'.atom_assgn` — the atom-mate 363 declared ABSENT for `e_P` is PRESENT in `σ₂`, negating the
  load-bearing step of `kvE_probe363_fake_elem_inconsistent`.
- lean_verify: `[propext, Classical.choice, Quot.sound]`, clean source scan, no `sorryAx`.
- Purely additive leaf module; NO production/frozen file touched (m=0 supply, k≤1 rungs, 363
  predicate/guard/probes all byte-unchanged).

## Not-fully-mechanized (deliverable of the escalation task, NOT this gate)

`kvE_futAdmissible σ₂ = true` in full (the σ₂-level universal: every `s*`-marked inner witness
has a mate). Argued by u-order-class enumeration in the probe docstring: u=20 (the P-collision in
the doppelgänger-sensitive region (15,21)) via the plant; every other order-class via an honest
`τ`-fiber under the doppelgänger order-remap (18↔21 depth-0 indistinguishable). This universal is
research-scale (per-class order-type + omega mate constructions) and is what the strengthened
interface must be built to make FALSE.

## What is needed (spawn target)

A 363-style interface restatement making the mate check reject the plant:
- **realizability-anchored**: the mate `s'` must be a genuinely realizable fiber (∃ model/env
  realizing it), not an atom-row plant — the plant's `.2 = fun _ => false` is unrealizable; OR
- **depth-recursive mate CONTENT comparison**: require the mate's `.2` marking (or fresh
  projection `nfk_projFresh`) to match, not only its depth-0 atom row `.atom_assgn`.
The plant is projection-VISIBLE (P at its fresh atom prefix), so a fresh-projection-aware guard
would separate it — that is the most promising direction and mirrors 363's own G1 separation.

## Scope note (G1 unaffected)

G1 (rows 5-6, interior) is NOT re-broken: the plant is projection-visible, so
`igFoldBit (qnf ⊕ σ₂) ≠ igFoldBit (honest qnf)` and 363's interior-leg separation
(`kvE_probe363_qnfG1_antecedent_fails`) stands. The blocker is exterior-leg (G2) only.

## Preserved / frozen (audited unchanged this session)

k≤1 arms, task 350 carriers, task 360 m=0 supply, task 363 predicate/guard/probes — no
production file touched; only the additive probe leaf added. KampPrior's two live sorries
(:519/:522) unchanged — NOT retired (blocked upstream on G2/G1 supply).
