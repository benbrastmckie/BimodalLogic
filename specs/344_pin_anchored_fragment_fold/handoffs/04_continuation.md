# Task 344 — Continuation Handoff (dispatch 4 → dispatch 5)

- **Session**: sess_1783723095_edd5a7_344
- **Status at handoff**: Phase 1 [PARTIAL]. One new green, axiom-clean, committed lemma landed
  (`kvE2_sep_locate_witness`, commit `ddf5eb916`). The gate producer `kvE2_sepGateAtPin_fragL`
  is **built to STAGE A** (all hard structural wiring validated/compiles) with h_atom ~90% and
  two conjuncts (h_fwd, h_bwd) still `sorry`. The WIP is preserved verbatim in
  `handoffs/gate-producer-wip.lean` (265 lines) and stashed
  (`git stash` entry "task344-d4-gate-producer-wip"). HEAD (`ddf5eb916`) is green + clean.

## What is LANDED and COMMITTED (dispatch 4)

`kvE2_sep_locate_witness` (`SharedWitness.lean`, end of file, `ddf5eb916`): model-general
point-location — for strictly-monotone `ws : Fin (k+1) → M.carrier` and any `v`, one of
`(∃ i, v = ws i) ∨ (v < ws 0) ∨ (∃ i:Fin k, ws i.cast < v < ws i.succ) ∨ (ws last < v)`.
Axiom-clean `{propext, Classical.choice, Quot.sound}`. This is the combinatorial core of the
h_fwd forward-zone trichotomy (converts an arbitrary interior model point into the
`holds_eq_succ` segment region that closes it). **hmono is NOT needed** — classification is pure
`Finset.max'` order theory.

## What is VALIDATED but NOT committed — `kvE2_sepGateAtPin_fragL` (WIP artifact)

`handoffs/gate-producer-wip.lean` holds the full gate producer. STAGE A **compiles** (verified via
`lake build` with only the two `sorry`s + h_atom order-case gaps): the inline preamble that
re-runs `kvE2_sepDisjunct'_extract` (SW:8249-8340) KEEPING the three `holds_eq_succ` segment
components, the pin extraction (`x1 = ws ⟨iσ,_⟩`), `hanchor` (charK anchor at pin via
`kvE2_sepPtX1L_anchor`), `hbelow` (the zXU below-witness clause), `h_off` (via
`kvE2_sepHgate_offFiber`), and the final `exact kvE2_sepBundleL_sound_frag …` call — ALL typecheck.
**The recipe is sound and the closer wiring works.**

### CRITICAL SIGNATURE CHANGE (must propagate to Phases 2/3)

The gate producer now takes the SIX outer-order hypotheses on `qnf.1`
(`h_xy/h_yt/h_xt/h_yx/h_ty/h_tx`, identical shape to `kvE2_outer_fold` SW:9902-9907), inserted
between `qnf` and `M`. Reason: h_atom's order bits AMONG the non-fresh coords (w,x,t) are NOT in
the endpoint predicates; they ride the OUTER order. `kvE2_outer_fold_frag` already has these, so
it supplies them at the call site — no new obligation for 335.

### h_atom RESOLUTION (the key finding, ~90% coded)

h_atom (`nf_eval_nf M 0 4 [x1,w,x,t] σ0.1`) IS derivable from `.holds` + hcorrK, via:
1. **Gate clause (i)**: `hg.1 σ0` with `qnf.2 σ0 = true` ⟹ `hdrop : nf0_dropFresh σ0.1 = qnf.1`.
   (Coded and compiles.)
2. **Fresh pred coord 0** (at x1): `hcorrK σ0 x1 hanchor` → atom layer; `(nfk_projFresh σ0).1
   (.pred p 0)` is **defeq** `σ0.1 (.pred p 0)` (nfk_take at index 0 = castLE identity). DONE.
3. **Non-fresh pred coords 1/2/3** (at w/x/t): `hprojW/hprojX/hprojT` (from PtW/EpL/EpR head
   conjuncts via `formula_conjList_iff …_ List.mem_cons_self` + `nfPred_correct`, copy of
   outer_fold SW:9963-9977) give `M.interp p ·  ↔ qnf.1(.pred p ⟨k⟩)`; bridge σ0.1 coord = qnf.1
   via `hdrop`. DONE (compiles).
4. **Fresh-coupled order bits** (0↔1/2/3): from `hz : nf0_zoneSpec σ0.1 = kvE2_sep_zXW3`. DONE
   (the two `iff_of_true/false … rfl` cases compile).
5. **Non-fresh order bits** (among 1/2/3): **THE ONLY REMAINING GAP.** `nf0_assemble`'s order
   case does NOT simp-reduce (nested `Fin.cases` with a motive), so the `rw [hσ0eq]` + `simp
   [nf0_assemble]` route leaves the bit un-reduced with `nf0_projFresh σ0.1` as a free var → the
   `by decide` errors ("Expected type must not contain free variables").

   **FIX (do this in dispatch 5)**: DROP `hσ0eq`/`rw [hσ0eq]`. Prove each bit via `congrFun`,
   mirroring `nf0_split_assemble`'s own proof (`NfEFold.lean:244,263` use
   `simp only [nf0_dropFresh, mergeNF, skipFin_zero_succ]`):
   ```
   have hz0  : ∀ j:Fin 3, σ0.1 (.order ⟨0,_⟩ j.succ (Fin.succ_ne_zero j).symm) = (kvE2_sep_zXW3 j).1 :=
     fun j => congrArg Prod.fst (congrFun hz j)
   have hz0' : ∀ j:Fin 3, σ0.1 (.order j.succ ⟨0,_⟩ (Fin.succ_ne_zero j)) = (kvE2_sep_zXW3 j).2 :=
     fun j => congrArg Prod.snd (congrFun hz j)
   have hdp  : ∀ p (j:Fin 3), σ0.1 (.pred p j.succ) = qnf.1 (.pred p j) := by
     intro p j; have := congrFun hdrop (AtomKind.pred p j)
     simpa only [nf0_dropFresh, mergeNF, skipFin_zero_succ] using this
   have hdo  : ∀ (i j:Fin 3) (hij:i≠j),
       σ0.1 (.order i.succ j.succ (fun he => hij (Fin.succ_injective he))) = qnf.1 (.order i j hij) := by
     intro i j hij; have := congrFun hdrop (AtomKind.order i j hij)
     simpa only [nf0_dropFresh, mergeNF, skipFin_zero_succ] using this
   ```
   Then in the `intro a; match a` (NO `rw [hσ0eq]`), each non-fresh order case is
   `rw [hdo ⟨i⟩ ⟨j⟩ (by decide), h_<pair>]; exact iff_of_true/false <model-order> rfl/(by decide)`,
   and the fresh cases use `rw [hz0 ⟨j⟩]`/`rw [hz0' ⟨j⟩]` then `simp [kvE2_sep_zXW3]` + iff.
   (`.succ` reduces `⟨i⟩.succ` to `⟨i+1⟩` reducibly, so the `rw`/pattern matches up to proof
   irrelevance.) Env `[x1,w,x,t]`: coord0=x1,1=w,2=x,3=t; model order `x<x1<w<t`.

## What REMAINS — the two conjuncts (dispatch 5)

Both live INSIDE the gate producer's zXW3 branch (after h_off/h_atom), with `ws`, `hmono`,
`hrange`, `hpt'`, `hseg0`/`hsegMid`/`hsegLast` (the KEPT segments), `hxx1`/`hx1w`/`hwt`, and the
pin `x1 = ws ⟨iσ,_⟩` all in scope.

- **h_fwd** (the crux): `∀ zs χ, (∃ v, zoneHolds [x1,w,x,t] zs v ∧ nf_eval χ v) → σ0.2 (nf0_assemble
  zs χ σ0.1) = true`. `intro zs χ ⟨v, hzv, hχv⟩; by_contra hbit`. Under `hfrag` the bracket
  witnesses are σ0's OWN slots only (O4 record SW:6785-6791: no cross-σ residue). Apply
  `kvE2_sep_locate_witness M ws v` to place v:
  - v = ws j (a witness): j is σ0's own bit-TRUE slot for some χ_j; both χ,χ_j realized at v ⟹
    `nf_eval_unique M 0 1 (fun _=>v) χ χ_j` (NormalForm.lean:245) ⟹ χ=χ_j ⟹ bit true, contra.
  - v in an open segment ((x,ws0)/(ws_i,ws_{i+1})/(ws_last,t)): the matching kept segment
    component (`hseg0`/`hsegMid`/`hsegLast`) gives `kvE2_sepSegForm charBase σ0 <zXU|zUW|zWT>` at
    v; `kvE2_sepSegForm_excludes charBase σ0 zs χ M atomMap v hSeg (hbit)` (SW:6683) gives
    `¬ charBase χ at v`; bridge `nf_eval χ v ↔ charBase χ at v` via `nfPred_correct` — contra.
    NB `kvE2_sepBits σ0 zs χ = σ0.2 (nf0_assemble zs χ σ0.1)` (SW:152, def-eq to hbit).
    Which segForm applies is keyed by whether v is before/after the pin (lX1) slot — the same
    `kvE2_sepSegLForSub` before/after split (SW:1127-1135); alignment is automatic because the
    segments come from the SAME realization as the pin.
  - v at a boundary (=x1/w/x/t): excluded by `zoneHolds` (an interior zone forces strict
    inequalities), or closes via the `kvE2_sepPtX1L`/`PtW`/`EpL`/`EpR` biconditional literals /
    `kvE2_sepHgate_innerNine` (SW:6669) for inconsistent zones.
- **h_bwd**: `∀ zs χ, zs ≠ kvE_sub2_zXU → σ0.2 (nf0_assemble zs χ σ0.1) = true → ∃ v, zoneHolds ∧
  nf_eval`. σ0's own slot channel: the zUW/zWT witnesses ride the ABOVE-witness clauses the
  current preamble drops — re-derive as `hbelow` derives the zXU below-witnesses (SW:8311-8340
  pattern, but lUW/lWT slots; mirror `kvE2_sepBundleR_sound`'s `match i` zoneHolds SW:9761-9774).
  at-zones via the literals.

## Then Phases 2 & 3 (unchanged from 03_continuation.md, plus the order-hyp thread)

- **Phase 2** `kvE2_sepGateAtPin_fragR` (zWX1 mirror) + `kvE2_sepBody_kit_sound_frag` — the latter
  case-splits σ0's zone (fragment predicate gives zXW3 ∨ zWT3) and calls fragL/fragR; conclusion
  byte-identical to `kvE2_sepBody_kit_sound` SW:9830-9839. Both gate producers now also thread
  the six order hyps.
- **Phase 3** `kvE2_outer_fold_frag` — copy `kvE2_outer_fold` (SW:9897-10035), replace
  hgateL/hgateR/hbdry with hfrag+hcorrK, feed the six order hyps (already present in
  kvE2_outer_fold's signature — thread verbatim) to the gate producers; `hexcl` verbatim,
  undischarged. Plus the 335 HANDBACK.

## Guards (unchanged, HARD)
Additive-only below `SW:10037`; `#print axioms` via `lake env lean` = `{propext,
Classical.choice, Quot.sound}` per landed lemma; NO sorry/vacuous on live paths at any COMMIT;
NEVER the ∀-anchor; every conjunct AT the pin; hcorrK/hexcl undischarged. To resume: `git stash
pop` (or paste `handoffs/gate-producer-wip.lean` above the file's final `end`), apply the h_atom
congrFun fix, then h_fwd/h_bwd.
