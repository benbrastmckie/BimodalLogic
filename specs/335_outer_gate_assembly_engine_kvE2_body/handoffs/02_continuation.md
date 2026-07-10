# Task 335 v5 — Fragment-Gate Continuation Handoff (Phase B BLOCKED, escalated)

- **Session**: sess_1783723095_edd5a7_335
- **Date**: 2026-07-10
- **Status**: partial — Phase A COMPLETED (green, committed); Phase B BLOCKED; Phases C/D NOT REACHED.
- **Build**: `lake build …NfMultiAnchorBridge.OuterGate` green. `SharedWitness.lean` /
  `SubBracket2V.lean` byte-unchanged (341 frozen-file gate intact). Zero sorries on live paths. No new axioms.

## Per-phase outcome

| Phase | Status | Notes |
|-------|--------|-------|
| 1 (def + `rfl` bridge) | COMPLETED (carryover) | untouched |
| 2 (⇐ completeness) | COMPLETED (carryover) | untouched |
| 3 (retire BLOCKED note + citation hygiene) | COMPLETED (carryover) | untouched |
| A (fragment predicate + `_frag` shells) | COMPLETED | `kvE2_sepFragment` committed green; sound shell typechecks but body undischargeable |
| B (`hgateL`/`hgateR` under `hfrag`) | **BLOCKED** | interior-gate FORWARD conjunct has no public producer |
| C (`hbdry`/`hexcl` GO/NO-GO) | NOT REACHED | `hbdry` discharged (vacuous); `hexcl` downstream of same gap |
| D (assemble + 309-v8 note) | NOT REACHED | gated on B∧C |

## Delivered (green, committed)

`kvE2_sepFragment {sig} (qnf : NormalForm sig 2 3) : Prop :=`
`  ∃ σ0, kvE2_sepPos qnf = [σ0] ∧ (nf0_zoneSpec σ0.1 = kvE2_sep_zXW3 ∨ nf0_zoneSpec σ0.1 = kvE2_sep_zWT3)`

Depends only on `qnf` (family-smuggling guard satisfied). This is the exactly-one-interior-positive
form (plan default, strongest residue-vanish guarantee, matches 321-N2 scope).

## The blocker (recorded after a genuine attempt)

The `_frag` sound theorem was set up over the landed fold:
```
intro h_holds
rw [bracketEndChar_kvE2_two_eq] at h_holds
refine kvE2_outer_fold atomMap h_surj (fun χ => P.existF 0 χ) qnf
  h_xy h_yt h_xt h_yx h_ty h_tx M x t h_holds ?hgateL ?hgateR ?hbdry ?hexcl
```
Reduction TYPECHECKS (order bits unify defeq `qnf.atom_assgn = qnf.1`), leaving the four families.

**`hbdry` DISCHARGES (vacuous under `hfrag`)** — verified green:
```
intro w hxw hwt hptW σ hσ hnon
obtain ⟨σ0, hpos, hz0⟩ := hfrag
rw [hpos, List.mem_singleton] at hσ; subst hσ
exact absurd hz0 hnon
```
So the fragment restriction DOES collapse the non-interior positive class (O4 SW:6785-6791 confirmed
at the goal level).

**`hgateL` BLOCKED.** After reducing to the sole `σ = σ0` and `refine ⟨?_, hwt, ?_, ?_, ?_, ?_⟩`,
the residual goals (verbatim `lean_goal`, hypotheses include `h_holds`, `hptW : ptW eval w`,
`hanchor : (P.existF 0 (nfk_projFresh σ)).eval_at M atomMap a`, `hxa : x < a`, `hat : a < t`,
`hz : nf0_zoneSpec σ.1 = kvE2_sep_zXW3`, `hpos : kvE2_sepPos qnf = [σ]`):

- `refine_1  ⊢ a < w`
- `refine_2  ⊢ nf_eval_nf M 0 4 (Fin.cons a (Fin.cons w (Fin.cons x fun x ↦ t))) σ.1`
- `refine_3  ⊢ ∀ τ, nf0_dropFresh τ ≠ σ.1 → σ.2 τ = false`   (off-fiber — derivable core `kvE2_sepHgate_offFiber`)
- `refine_4  ⊢ ∀ zs χ, (∃ v, zoneHolds M [a,w,x,t] zs v ∧ nf_eval_nf M 0 1 (fun _=>v) χ) →`
             `           σ.2 (nf0_assemble zs χ σ.1) = true`   (FORWARD — THE WALL)
- `refine_5  ⊢ ∀ zs χ, zs ≠ kvE_sub2_zXU → σ.2 (nf0_assemble zs χ σ.1) = true → ∃ v, zoneHolds … ∧ nf_eval …`
             (backward — derivable core `kvE2_sepHgate_innerNine` + `kvE_sub2V_zone_consistent`)

### Why refine_1 / refine_2 / refine_4 do not close (machine-confirmed)

1. **No public producer for the FORWARD conjunct.** `σ.2 (nf0_assemble zs χ σ.1) = true` occurs ONLY
   as a HYPOTHESIS across `kvE2_outer_fold` / `kvE2_sepBody_kit_sound` / `kvE2_sepBundleL_sound` /
   `kvE_subBracket2V_sound` / `_sound_of_parts` / `_sound_of_outer` (SW:9686-9944, SubBracket2V:1220-1511),
   NEVER as a conclusion. Every `_sound_of_*` lemma CONSUMES the full `hgate` (with FORWARD) and only
   PRODUCES the anchor + below-witnesses from `.holds` — it cannot produce FORWARD.
2. **The only exclusion channel fires only at segment-covered points.** `kvE2_sepSegForm_excludes`
   (SW:6683) needs the segment form to HOLD at the witness `v`; the segment content lives inside the
   frozen `kvE2_sepDisjunct'` and is DISCARDED by the public extractor `kvE2_sepBody_extract`
   (SW:8410 → bundles only). O4 failed-closer #4 (SW:6734-6739) already documents this leaves an
   unprovable goal at witness points.
3. **refine_1 / refine_2 are the O4 "second obstruction" (SW:6772-6778) at the goal level.** `a` is an
   ARBITRARY point realizing only the fresh atom (`hanchor`); nothing forces `a < w` nor `a ⊨ σ.1`
   full base without the frozen segment content.
4. `bracketEndChar_kv_factors` (`CarrierKv.lean:422`) machine-certifies the (outer zone, projected
   1-type) information ceiling — the FORWARD conjunct is underdetermined by the realized carrier content.

### Root classification

The O4 residue-vanish (SW:6785-6791) is a Phase-10 ROUTING verdict — it certifies the CROSS-σ residue
vanishes for one positive, but it is NOT a landed derivation. Formalizing "every witness is σ0's own
bit-true slot or a segment-covered point" STILL requires the frozen `kvE2_sepDisjunct'` segment
structure, which the public API does not expose. Closing it needs NEW `SharedWitness.lean` lemmas =
branch (a) (REFUTED, report 04) + violates 341's frozen-file gate. The plan's Phase-B territory guard
mandates STOP here.

## Resume options (for the user / successor — a design decision, not an implementation retry)

1. **Renegotiate the frozen-file gate**: spawn a 333/SharedWitness-territory task to land a PUBLIC
   single-positive segment-coverage extractor (`.holds → ∀ v in zone, segment form holds at v`, hence
   the FORWARD contrapositive). This lifts the residue-vanish verdict to a landed lemma. Coordinate
   with 341 (its frozen-file gate would need to admit the new lemma).
2. **SUCCESSOR carrier re-definition** (the 321-N2-named deferred task): bit-compatibility filtering of
   the interleaving enumeration (O4 SW:6763-6770) — a carrier redefinition with O1b/O2/O3 knock-on
   rework. This is the faithful repair but is a large multi-task effort.

Do NOT re-attempt the four families from the current inputs — refuted, not merely hard. Do NOT edit
`SharedWitness.lean` from 335's territory. `OuterGate.lean` is left at Phase-A-green (predicate + the
in-source Phase-B blocker note).
