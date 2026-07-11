# Task 344 — Continuation Handoff (dispatch 9 → dispatch 10)

- **Session**: sess_1783723095_edd5a7_344
- **Status at handoff**: **Phase 1 [COMPLETED]** — `kvE2_sepGateAtPin_fragL` is now fully
  sorry-free. `h_bwd` (the last Phase-1 sorry, `SharedWitness.lean:11076`) LANDED. HEAD
  `7c7aa84dc` is GREEN (`lake build …SharedWitness` exit 0). **344-section actual-sorry count = 0.**
  `#print axioms kvE2_sepGateAtPin_fragL == {propext, Classical.choice, Quot.sound}` (verified via
  `lake env lean`). Phases 2 & 3 NOT started — gated on `kvE2_sepGateAtPin_fragR` (see below).

## What LANDED this dispatch (committed `7c7aa84dc`)

`h_bwd` — the gate-honesty converse — proven by per-zone witness inversion. Structure (verbatim in
`SharedWitness.lean` ~11072-11290):

1. **zs-classification via gate clause (iv)**: `kvE2_sepGate`'s 4th conjunct
   (`hg.2.2.2 σ hσ0true hz zs χ hncons`) gives `¬InnerConsistentL zs → σ.2(assemble)=false`. So
   `by_contra` + that clause proves `hcons : kvE2_sepInnerConsistentL zs` (the abstract `zs` is one
   of the 9 named zones).
2. **`rcases hcons` into 9 disjuncts**, mapped to named constants (all syntactically-identical
   `Fin.cons` forms, so `have hz? : zs = <constant> := h` typechecks by defeq):
   `zPastX4, zAtX4, zXU(excluded), zAtX1L, zUW, zAtWL, zWT, zAtT4, zFutT4` (order = the disjunct
   order in `kvE2_sepInnerConsistentL`, `SharedWitness.lean:1221-1229`).
3. **zXU** closed by `exact absurd h hzsne` (excluded by the `zs ≠ kvE_sub2_zXU` hypothesis).
4. **6 endpoint/at-point zones** (zPastX4/zAtX4/zAtX1L/zAtWL/zAtT4/zFutT4): the owner-lit lemmas
   (`kvE2_sepEpL_owner_lits`/`kvE2_sepEpR_owner_lits`/`kvE2_sepPtW_owner_lit`/`kvE2_sepPtX1L_owner_lit`)
   with `bit = true` give `temporal_truth point <literal>` after `rw [hbitT]; simp only [kvE2_sepLit, if_true]`.
   snce/untl zones (zPastX4/zFutT4) `obtain ⟨s, hsx, hχs, -⟩` a witness `s` (semantics
   `Table.lean:182-193`: `snce φ ψ` = `∃ s < t, φ@s ∧ …`); the at-points use the point itself.
5. **2 interior zones** (zUW/zWT): the bracket-slot machinery.
   - **zUW** mirrors the landed `hbelow` (`SW:10464`) with the `.lUW` slot ABOVE the pin
     (`iσ < jχ`, `Nat.one_lt_two`, `kvE2_sep_lUW_mem_slotsLFor`); witness `ws ⟨jχ,_⟩`.
   - **zWT** uses the RIGHT group: builds `.lWT σ χ ∈ kvE2_sepSlotsRFor σ` inline
     (`rw [kvE2_sepSlotsRFor, if_pos hz]; exact List.mem_map_of_mem (List.mem_filter.mpr ⟨by simp, hbitT⟩)`),
     then `kvE2_sepSlotsROf_mem` → `kvE2_sepTieGroupedR_flatten` → group `jr` → witness
     `ws ⟨|mapgL|+1+jr, hK⟩` (copy the forward RIGHT extraction `SW:10836-10863`).
6. Base type at every witness: `kvE2_sepClassType_eval_mem … = (⟨charBase χ⟩).eval_at`, then a local
   `tonf` helper (`rw [hcb]; exact (nfPred_correct …).mp …`) converts to `nf_eval_nf`.

**KEY facts confirmed (do NOT re-derive):**
- `kvE2_sepBits σ zs χ` **is definitionally** `σ.2 (nf0_assemble zs χ σ.1)` (`SW:152-154`) — the
  owner-lit rewrites and `hbitT := hbit` steps rely on this defeq.
- `kvE2_sepGate` clause (iv) (`SW:1244-1246`) covers **only** `nf0_zoneSpec σ.1 = kvE2_sep_zXW3`
  (LEFT-interior). There is **NO** analogous zWT3/InnerConsistentR clause — this is the fragR blocker.

## THE Phase-2/3 BLOCKER — `kvE2_sepGateAtPin_fragR` (unlanded, needs NEW infrastructure)

Phases 2 & 3 are each tiny (drafts below, ready to paste), but BOTH consume
`kvE2_sepGateAtPin_fragR` for the `zWT3` disjunct of `kvE2_sepFragment_frag`
(`SW:10064` / `OuterGate.lean:194` allow σ0 = zXW3 **OR** zWT3). fragR is the RIGHT-geometry mirror
of fragL (which took dispatches 4-9). **Missing infrastructure that fragR needs (verified absent):**
- `kvE2_sepInnerConsistentR` (the 9-zone RIGHT classification; analog of `kvE2_sepInnerConsistentL`).
- `kvE2_sepPtX1R_owner_lit` (right pin at-`x1` literal; analog of `kvE2_sepPtX1L_owner_lit`).
- `kvE2_sep_rX1T_mem_slotsRFor` (`rWX1_mem` exists; `rX1T` and the classification helpers do not).
- **DESIGN GAP (do first)**: `kvE2_sepGate` has no exclusion clause for right-interior (zWT3) subs
  (clause iv is zXW3-only). fragR's `h_bwd` zs-classification therefore CANNOT reuse the clause-(iv)
  trick. Dispatch 10 must first determine where the right-interior zone exclusion comes from —
  either a different landed gate fact, or the fragR `h_bwd` derives InnerConsistentR from the bundle
  data directly. RESOLVE THIS before writing fragR's h_bwd. (The gate is a LANDED def — do NOT modify
  it; find the exclusion elsewhere or build it additively.)

fragR structure = mirror `kvE2_sepGateAtPin_fragL` (`SW:10371-11291`) with:
`hz : nf0_zoneSpec σ0.1 = kvE2_sep_zWT3`; pin `x1` with `w < x1 < t`; below-clause zone `kvE2_sep_zWX1`
(not zXU); closer `kvE2_sepBundleR_sound_frag` (`SW:10125`, ALREADY LANDED, takes h_atom/h_off/h_fwd/h_bwd
at the right pin, excludes `kvE2_sep_zWX1`); right slots `rWX1/rX1/rX1T` in `kvE2_sepSlotsRFor` under
`if_pos (zWT3)` (`SW:347-349`). The `hbelow` right-analog gives `w < u < x1`.

## Phase 2 — `kvE2_sepBody_kit_sound_frag` (READY once fragR lands)

Conclusion = **byte-identical** to `kvE2_sepBody_kit_sound` (`SW:9840-9849`). Hypotheses: the 6 qnf
order facts (`h_xy h_yt h_xt h_yx h_ty h_tx`, verbatim from fragL/outer_fold), `M x t`,
`hfrag : kvE2_sepFragment_frag qnf`, `hcorrK`, `h`. Proof:
```lean
  obtain ⟨σ0, hpos, hzone⟩ := hfrag
  rcases hzone with hzL | hzR
  · exact kvE2_sepGateAtPin_fragL atomMap h_surj charK qnf h_xy h_yt h_xt h_yx h_ty h_tx
      M x t σ0 hpos hzL hcorrK h
  · exact kvE2_sepGateAtPin_fragR atomMap h_surj charK qnf h_xy h_yt h_xt h_yx h_ty h_tx
      M x t σ0 hpos hzR hcorrK h
```
(Both fragL and fragR deliver the FULL kit conclusion — fragL's zWT3 clause is vacuous under hfrag,
fragR's zXW3 clause vacuous. So the rcases is exhaustive and each branch closes the whole goal.)

## Phase 3 — `kvE2_outer_fold_frag` (READY once Phase 2 lands)

Mirror `kvE2_outer_fold` (`SW:9907-10045`). Replace `hgateL`/`hgateR`/`hbdry` with
`hfrag : kvE2_sepFragment_frag qnf` + `hcorrK`; **thread `hexcl` verbatim** (`SW:9962-9966`, the FINAL
hyp). Same conclusion (`SW:9967-9968`). Proof body verbatim EXCEPT:
- `obtain ⟨hEpL, hEpR, w, hxw, hwt, hptW, hLreal, hRreal⟩ := kvE2_sepBody_kit_sound_frag atomMap
  h_surj charK qnf h_xy h_yt h_xt h_yx h_ty h_tx M x t hfrag hcorrK h` (replaces the kit_sound call).
- Forward atom-layer + `hexcl` branch (`SW:9971-10036`) copied verbatim.
- Backward non-interior branch (`SW:10045` `hbdry …`) is UNREACHABLE under hfrag — replace with:
```lean
  exfalso
  obtain ⟨σ0, hpos, hzone⟩ := hfrag
  rw [hpos] at hmem
  have hσ0 : σ = σ0 := List.mem_singleton.mp hmem
  subst hσ0
  rcases hzone with h | h
  · exact hzL h
  · exact hzR h
```
(so `hbdry` is not needed at all — the frag fold has hypotheses `hfrag + hcorrK + hexcl` only).

Then Phase-3 HANDBACK: verify the four signatures against `OuterGate.lean` (335 Phase B) — the
`kvE2_sepFragment_frag`/`OuterGate.kvE2_sepFragment` defeq bridge (`SW:10058-10067`), and the
`hcorrK`/`hexcl` obligations 335 discharges.

## Guards (unchanged, HARD)
Additive-only below `SW:10047` banner; zero existing decls modified; SharedWitness.lean only; NEVER
the ∀-anchor; `hcorrK`/`hexcl` undischarged; per green milestone `lake build …SharedWitness` +
`#print axioms == {propext, Classical.choice, Quot.sound}` + commit. COMPLETION BAR: zero sorries in
the TASK 344 banner section + all four target lemmas axiom-clean. To resume: fragR is the sole
blocker — resolve the right-interior zone-exclusion DESIGN GAP first, build the missing right-geometry
helpers, mirror fragL, then paste Phases 2 & 3 (above).
