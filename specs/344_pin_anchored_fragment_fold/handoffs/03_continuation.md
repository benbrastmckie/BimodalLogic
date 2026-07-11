# Task 344 — Continuation Handoff (dispatch 3 → dispatch 4)

- **Session**: sess_1783723095_edd5a7_344
- **Status at handoff**: Phase 1 [PARTIAL] — two green, axiom-clean, committed lemmas landed
  (`kvE2_sepBundleL_sound_frag`, `kvE2_sepBundleR_sound_frag`). Tree green
  (`lake build …SharedWitness` succeeds; the only `sorry` warnings are pre-existing in
  `EANegation.lean:834/1129`, NOT in 344's file). Additive-only below the TASK 344 banner
  (`SW:10037`); zero existing decls modified.
- **Commits this dispatch**: `90debe333` (closers, initial ∀-x1 form) → `7816c494a`
  (closers refactored to explicit pin-parts — the directly-consumable form; USE THIS).

## What is LANDED (dispatch 3) — the continuation-inlining step (recipe step 3)

Both closers live at the end of `SharedWitness.lean` (search `sound_frag`). They inline the
`kvE_subBracket2V_sound_of_parts` continuation with the four gate conjuncts supplied AT the pin
`x1` as **explicit hypotheses** (never a ∀-anchor — the pin-specific `h_fwd` is never demanded at
an arbitrary anchor, dissolving report §1's refutation). Verified signatures:

```
kvE2_sepBundleL_sound_frag (atomMap) (h_surj) (σ) (M) (w x t) (hwt : w < t)
  (x1) (hx1w : x1 < w)
  (hbelow : ∀ χ, σ.2 (nf0_assemble kvE_sub2_zXU χ σ.1) = true →
      ∃ u, x < u ∧ u < x1 ∧ (⟨nf_depth0_char_formula atomMap h_surj χ⟩).eval_at M atomMap u)
  (h_atom : nf_eval_nf M 0 4 [x1,w,x,t] σ.1)
  (h_off  : ∀ τ, nf0_dropFresh τ ≠ σ.1 → σ.2 τ = false)
  (h_fwd  : ∀ zs χ, (∃ v, zoneHolds M [x1,w,x,t] zs v ∧ nf_eval_nf M 0 1 (fun _=>v) χ)
              → σ.2 (nf0_assemble zs χ σ.1) = true)
  (h_bwd  : ∀ zs χ, zs ≠ kvE_sub2_zXU → σ.2 (nf0_assemble zs χ σ.1) = true
              → ∃ v, zoneHolds M [x1,w,x,t] zs v ∧ nf_eval_nf M 0 1 (fun _=>v) χ)
  : ∃ x1', nf_eval_nf M 1 4 [x1',w,x,t] σ
```
`kvE2_sepBundleR_sound_frag`: mirror, `(hxw : x < w)`, pin `(hwx1 : w < x1) (hx1t : x1 < t)`,
`hbelow` over zone `kvE2_sep_zWX1` with `w < u ∧ u < x1`, backward exception zone `kvE2_sep_zWX1`.
Env is `[x1,w,x,t]` in BOTH (coord0 = pin, coord1 = w, coord2 = x, coord3 = t).

**Consequence**: the gate producer no longer has to re-prove the fold continuation. It only has to
extract the pin + `hbelow` and DERIVE the four conjuncts at the pin, then `exact
kvE2_sepBundleL_sound_frag atomMap h_surj σ M w x t hwt x1 hx1w hbelow h_atom h_off h_fwd h_bwd`.

## What REMAINS — the gate producer `kvE2_sepGateAtPin_fragL` (dispatch 4, the crux)

This is the irreducible hard core (why dispatches 1–2 investigated, not landed). NO WALL — the
recipe is sound; it is LENGTH (segment re-extraction + forward trichotomy, ~150–250 lines).

### Target (per report §2 sketch, `reports/01_…:104-120`) and the exact hcorrK shape
```
hcorrK : ∀ (σ : NormalForm sig 1 4) (a : M.carrier),
  (⟨charK (nfk_projFresh σ)⟩ : TemporalPred).eval_at M atomMap a →
  nf_eval_nf M 1 1 (fun _ => a) (nfk_projFresh σ)      -- fresh point's k=1 type at the anchor
```
Recommended internal conclusion for `kvE2_sepGateAtPin_fragL` (feeds the landed closer directly):
`∃ x1, x < x1 ∧ x1 < w ∧ (four conjuncts at [x1,w,x,t])` for the fragment's σ0 — OR just conclude
`∃ x1', nf_eval_nf M 1 4 [x1',w,x,t] σ` by calling the closer inline. Either is fine; kit_sound_frag
(Phase 2) needs the folded `∃ x1', nf_eval_nf` form (SW:9834-9836), so calling the closer inline is
the shortest path.

### Derivation recipe (all channels have a landed lemma — see `handoffs/02_continuation.md` §2)
1. `by_cases hg : kvE2_sepGate qnf`. Fail branch: `rw [kvE2_sepBody_gate_fail …] at h; simp
   [VVecEA2.holds] at h` (copy `kvE2_sepBody_extract` `SW:8429-8430`).
2. `rw [kvE2_sepBody_holds_iff … hg …] at h; obtain ⟨wo, hwo, hd⟩ := h`.
3. **Re-run the `kvE2_sepDisjunct'_extract` preamble on `hd` KEEPING the segments** — copy
   `SW:8249-8340` but change line `8273` `obtain ⟨ws, hmono, hrange, hpt, -, -, -⟩` to
   `obtain ⟨ws, hmono, hrange, hpt, hseg0, hsegMid, hsegLast⟩` and DO NOT discard the last three.
   The three seg clauses are `IntervalPattern.holds_eq_succ` components 4/5/6
   (`ExistsForallNF.lean:197-203`): `hseg0` on `(x, ws[0])`, `hsegMid i` on `(ws[i], ws[i+1])`,
   `hsegLast` on `(ws[last], t)`. Their `beta` is `kvE2_sepSegs charBase qnf lL lR i`
   (`SW:1171-1175`), which under `hfrag` (`kvE2_sepPos qnf = [σ0]`) reduces to a single
   `kvE2_sepSegLForSub charBase lL i σ0` (`SW:1127-1135`) = `kvE2_sepSegForm σ0 kvE_sub2_zXU`
   for cuts BEFORE σ0's `lX1` block, `… kvE_sub2_zUW` AFTER (left region); `… kvE_sub2_zWT`
   (right region, `kvE2_sepSegRForSub` `SW:1140-1148`).
4. Pin `x1 := ws ⟨iσ, …⟩` where `iσ` is σ0's `lX1` tie-class index — reuse `SW:8297-8309`
   verbatim (σ0's `lX1` slot → its tie class → `ws` witness). `hbelow` = the zXU below-witness
   clause `SW:8311-8340` (already produces `∃ u, x<u ∧ u<x1 ∧ charBase χ at u`, exactly the
   closer's `hbelow`).
5. **h_off** (trivial): `kvE2_sepHgate_offFiber qnf hg σ0 hσ0` (`SW:6658`); `hσ0 : qnf.2 σ0 = true`
   from `hσ` via `kvE2_sepPos` membership (`List.mem_filter`).
6. **h_atom** (`nf_eval_nf M 0 4 [x1,w,x,t] σ0.1`): coord-0 predicate bits from
   `hcorrK σ0 x1 hanchor` (gives `nf_eval_nf M 1 1 (fun _=>x1) (nfk_projFresh σ0)`, reconstruct
   into σ0.1's coord-0 via `nf0_assemble`/`nfk_projFresh` defeq); coords w/x/t from
   `kvE2_sepPtW`/`EpL`/`EpR` head conjuncts via `nfPred_correct` — COPY the arity-3 pattern
   `SW:9963-9977` (adapt to arity-4 `match a`); order bits from `x<x1<w<t` — COPY `SW:9982-9991`
   pattern (arity-4). `hanchor := kvE2_sepPtX1L_anchor … x1 hpt_x1` where `hpt_x1` is the pin's
   own point-type from the `hpt'` reads (`SW:8305-8310` gives σ0's folded fresh type at `ws iσ`).
7. **h_fwd** (THE crux, ~100–150 lines): `intro zs χ ⟨v, hzone_v, hχ_v⟩`; by_contra `hbit : … = false`.
   Trichotomy on `v` vs the bracket witnesses (from `hzone_v : zoneHolds [x1,w,x,t] zs v` locating
   `v`, and `hmono`/`hrange` locating the ws):
   - **v in an open sub-interval** (segment-interior): the relevant seg clause (`hseg0`/`hsegMid`/
     `hsegLast`) gives `kvE2_sepSegForm σ0 (zXU|zUW|zWT) at v`; `kvE2_sepSegForm_excludes charBase
     σ0 zs χ M atomMap v hSeg (hbit-as-kvE2_sepBits-false)` gives `¬ charBase χ at v` —
     contradiction with `hχ_v` (bridge `nf_eval M 0 1 v χ ↔ charBase χ at v` via `nfPred_correct`).
     NOTE `kvE2_sepBits σ0 zs χ = σ0.2 (nf0_assemble zs χ σ0.1)` (`SW:152-154`) = `hbit` def-eq.
   - **v = a below-witness `ws j`** (bit-TRUE slot for some χ_j): use `nf_eval_unique M 0 1
     (fun _=>v) χ χ_j` (`NormalForm.lean:245`) — both χ and χ_j realized at v force `χ = χ_j`,
     so `bit(zs,χ)=bit(zs,χ_j)=true`, contradicting `hbit=false`. (χ_j read from the slot
     enumeration / `hpt'` at that witness index.)
   - **v = x1 / w / x / t (at-zone)** or **v in an inconsistent zone**: at-zones close via the
     biconditional literals in `kvE2_sepPtX1L`/`PtW`/`EpL`/`EpR`; inconsistent zones are vacuous
     via `kvE_sub2V_zone_consistent` (`SubBracket2V.lean:1535`, private — use its contrapositive
     as at `SubBracket2V.lean:1677-1681`) + `kvE2_sepHgate_innerNine` (`SW:6669`).
8. **h_bwd** (`∀ zs χ, zs ≠ zXU → bit=true → ∃ v, zoneHolds ∧ nf_eval`): σ0's own slot channel.
   zUW/zWT witnesses come from the ABOVE-witness clauses the current extract DROPS — re-derive
   them the same way `SW:8311-8340` derives the zXU below-witnesses, but for `lUW`/`lWT` slots
   (mirror `kvE2_sepBundleR_sound`'s `SW:9761-9774` zoneHolds `match i`). at-zones via literals.

### Then Phases 2 & 3 (mechanical byte-mirrors, dispatch 4 or 5)
- **Phase 2** `kvE2_sepBody_kit_sound_frag`: copy `kvE2_sepBody_kit_sound` (`SW:9787-9848`) verbatim,
  replace `hgateL`/`hgateR` params with `hfrag`+`hcorrK`, and replace the two `exact
  kvE2_sepBundle{L,R}_sound …` calls with `kvE2_sepGateAtPin_frag{L,R} … σ hσ hz`. Under `hfrag`
  the pos list is `[σ0]` so the per-σ obligations are the single σ0. Conclusion byte-identical to
  `SW:9830-9839`.
- **Phase 3** `kvE2_outer_fold_frag`: copy `kvE2_outer_fold` (`SW:9897-10035`) verbatim, replace
  `hgateL`/`hgateR`/`hbdry` with `hfrag`+`hcorrK`, call `kvE2_sepBody_kit_sound_frag` at
  `SW:9959-9960`, thread `hexcl` verbatim (`SW:9952-9956`). `hbdry` branch (`SW:10035`) is vacuous
  under `hfrag`: every positive σ is interior (zXW3 ∨ zWT3), so `by tauto`/`hfrag`-derived
  contradiction closes it.

## Guards (unchanged, HARD)
- Additive-only below `SW:10037`; `#print axioms` via `lake env lean` (NOT `lean_verify`) =
  `{propext, Classical.choice, Quot.sound}` per landed lemma; NO `sorry`/`admit`/vacuous on live
  paths at any commit; NEVER the ∀-anchor extractor; every conjunct AT the pin, never `∀ a`;
  `hcorrK`/`hexcl` stay undischarged hypotheses. Per green milestone: `lake build …SharedWitness` +
  axiom check + commit `task 344 phase {P}: {name}` with `Session: sess_1783723095_edd5a7_344`.
- If a GENUINE wall appears (a goal no landed lemma closes): capture the exact `lean_goal` state,
  commit green work, mark the plan item [BLOCKED], STOP.
