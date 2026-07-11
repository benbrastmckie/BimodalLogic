# Task 344 — Continuation Handoff (dispatch 5 → dispatch 6)

- **Session**: sess_1783723095_edd5a7_344
- **Status at handoff**: Phase 1 [PARTIAL]. `kvE2_sepGateAtPin_fragL` `h_atom` conjunct is now
  **COMPLETE, sorry-free, green, committed** (`1cd512ebc`). The gate producer's two remaining
  conjuncts `h_fwd` and `h_bwd` are still `by sorry` (tracked leaf sub-sorries). HEAD is green
  (full `lake build` exit 0; the only `sorry` on 344's path is at
  `SharedWitness.lean:10224` = `kvE2_sepGateAtPin_fragL`).

## What LANDED this dispatch (committed `1cd512ebc`)

**`h_atom`** inside `kvE2_sepGateAtPin_fragL` — all 16 atom cases of
`nf_eval_nf M 0 4 [x1,w,x,t] σ.1` proved sorry-free. Key technique change from dispatch 4's
recipe (which did not compile): the `rw [hσ0eq]` + `simp [nf0_assemble]` route was **abandoned**
because `nf0_assemble`'s order branch (nested `Fin.cases` with motive) does NOT simp-reduce and
leaves `nf0_projFresh σ.1` as a free var, breaking `by decide`. Replaced with **per-atom
`congrFun` bridges**:

- **Pred coord 0** (x1): `hc0a` (from `hcorrK σ x1 hanchor`) + `hpf`
  (`(nfk_projFresh σ).1 = nf0_projFresh σ.1`); close with
  `simpa only [atom_eval, Fin.cons_zero, atomKind_castLE, Fin.castLE] using h1`.
- **Pred coords 1/2/3** (w/x/t): `e := congrFun hdrop (.pred p ⟨k,_⟩)`; normalize with
  `simp only [nf0_dropFresh, mergeNF, skipFin_zero_succ, Fin.succ_mk, Nat.reduceAdd] at e`
  → `e : σ.1 (.pred p ⟨k+1⟩) = qnf.1 (.pred p ⟨k⟩)`; `rw [e]`; then `hprojW/hprojX/hprojT`
  bridge via `simpa only [atom_eval, kvE2_sepProj3, Fin.cons_zero, Fin.cons_succ] using h1`.
- **Non-fresh order** (both idx ∈ {1,2,3}): `e := congrFun hdrop (.order ⟨i,_⟩ ⟨j,_⟩
  (Fin.ne_of_val_ne (show (i:ℕ) ≠ j by decide)))`;
  `simp only [nf0_dropFresh, mergeNF, skipFin_zero_succ, Fin.succ_mk, Nat.reduceAdd, h_<pair>] at e`
  (the `h_xy/h_yt/h_xt/h_yx/h_ty/h_tx` outer-order hyps rewrite `qnf.1(.order..)` to a Bool
  literal) → `e : σ.1 (.order ⟨i+1⟩ ⟨j+1⟩) = <bool>`; `rw [e]`; `simp only [atom_eval,
  Fin.cons_zero, Fin.cons_succ]`; `exact iff_of_true/false <model-order> (by decide)`.
- **Fresh-coupled order** (one idx = 0): prove
  `hbit : σ.1 (.order ⟨i,_⟩ ⟨j,_⟩ hne) = <bool>` (state it with the bound `hne` so `rw` matches)
  via `simpa only [nf0_zoneSpec, kvE2_sep_zXW3, Fin.isValue, Fin.succ_mk, Nat.reduceAdd,
  Fin.cons_zero, Fin.cons_succ] using congrArg Prod.fst/snd (congrFun hz ⟨k, by omega⟩)`; then
  `rw [hbit]; simp only [atom_eval, Fin.cons_zero, Fin.cons_succ]; exact iff_of_true/false … (by decide)`.

**Reusable lessons (candidate memories):**
1. `nf0_assemble`'s order atom does NOT simp-reduce; bridge each bit with `congrFun` on
   `nf0_dropFresh`/`nf0_zoneSpec` equalities, normalizing `.succ`→literal via
   `Fin.succ_mk` + `Nat.reduceAdd`, and canonicalizing Fin literals with `Fin.isValue`.
2. `by decide` on a Fin-indexed Bool fails ("Expected type must not contain free variables")
   when the atom carries a `by omega` proof or an unreduced `nf0_assemble`; get the bit to a
   plain Bool literal FIRST (via `rw [hbit]` where `hbit : … = true/false`), then `by decide`
   is closed.
3. A closed `≠` proof for Fin indices: `Fin.ne_of_val_ne (show (a:ℕ) ≠ b by decide)` — NOT
   `by decide` directly on `⟨a,_⟩ ≠ ⟨b,_⟩` (the `_` proofs are free vars).
4. Match-bound proof args (`hne`, `isLt`) are proof-irrelevant, so state helper equalities
   with `⟨i, by omega⟩`/`hne` and `rw` still matches the goal atom.

## What REMAINS — h_fwd and h_bwd (dispatch 6)

Both live inside `kvE2_sepGateAtPin_fragL`'s zXW3 branch, AFTER `h_atom`/`h_off`, with `ws`,
`hmono`, `hrange`, `hpt'`, `hseg0`/`hsegMid`/`hsegLast` (the KEPT `holds_eq_succ` segments),
`hxx1`/`hx1w`/`hwt`, `hbelow`, and the pin `x1 = ws ⟨iσ,_⟩` all in scope. `kvE2_sepBits σ zs χ`
is **def-eq** to `σ.2 (nf0_assemble zs χ σ.1)` (`SW:152`) — the goal bit.

### h_fwd (the crux) — `SharedWitness.lean` ~10496
`∀ zs χ, (∃ v, zoneHolds M [x1,w,x,t] zs v ∧ nf_eval_nf M 0 1 (fun _=>v) χ) →
σ.2 (nf0_assemble zs χ σ.1) = true`.
Sketch: `intro zs χ ⟨v, hzv, hχv⟩; by_contra hbit` (⟹ `kvE2_sepBits σ zs χ = false`). Apply
`kvE2_sep_locate_witness M ws v` (landed `ddf5eb916`, SW:10168) → 4 regions:
- **v = ws j** (a witness): j is σ's OWN bit-true slot for some χ_j (single-positive `hfrag` ⟹
  no cross-σ residue, O4 record SW:6785-6791); both χ, χ_j realized at v ⟹
  `nf_eval_unique M 0 1 (fun _=>v) χ χ_j` (`NormalForm.lean:245`) ⟹ χ=χ_j ⟹ bit true, contra.
- **v in an open segment** ((x,ws0)/(ws_i,ws_{i+1})/(ws_last,t)): the matching kept segment
  (`hseg0`/`hsegMid`/`hsegLast`) gives `kvE2_sepSegForm charBase σ <zXU|zUW|zWT>` at v via the
  `kvE2_sepSegsG`→per-σ split `kvE2_sepSegLForSub` (SW:1127-1135, before/after pin `lX1`);
  then `kvE2_sepSegForm_excludes charBase σ zs χ M atomMap v hSeg hbit` (SW:6683) gives
  `¬ charBase χ at v`; bridge `nf_eval χ v ↔ charBase χ at v` via `nfPred_correct` — contra `hχv`.
- **v at a boundary** (=x1/w/x/t): excluded by `zoneHolds` forcing strict inequalities, or via
  the `kvE2_sepPtX1L`/`PtW`/`EpL`/`EpR` biconditional literals / `kvE2_sepHgate_innerNine`
  (SW:6669) for inconsistent zones.

**Not yet read this dispatch** (needed for h_fwd): `kvE2_sepSegsG` (SW:2167), the
`kvE2_sepSegLForSub` before/after-pin split (SW:1127-1135), and how `hsegMid`'s
`kvE2_sepSegsG … ⟨idx+1⟩` maps to a single-σ `kvE2_sepSegForm charBase σ zs`. That decomposition
is the first thing to nail — it is the crux of the crux.

### h_bwd — `SharedWitness.lean` ~10501
`∀ zs χ, zs ≠ kvE_sub2_zXU → σ.2 (nf0_assemble zs χ σ.1) = true → ∃ v, zoneHolds ∧ nf_eval`.
σ's own slot channel: the zUW/zWT witnesses ride the ABOVE-witness clauses the current preamble
DROPS — re-derive as `hbelow` derives the zXU below-witnesses (`hbelow` body SW:10317-10347
pattern, but `lUW`/`lWT` slots instead of `lXU`); at-zones close via the literals. Mirror
`kvE2_sepBundleR_sound`'s `match i` zoneHolds assembly (SW:9760-9776). Note
`kvE2_sepBundleL_sound_frag` (SW:10066) already threads `h_bwd` for the `zs ≠ kvE_sub2_zXU`
branch — h_bwd must produce the witness for EVERY non-zXU zone the fragment can realize
(namely zUW, zWT, and at-zones).

## Then Phases 2 & 3 (unchanged from 04_continuation.md)
- **Phase 2** `kvE2_sepGateAtPin_fragR` (zWX1 mirror, calls `kvE2_sepBundleR_sound_frag` SW:10115)
  + `kvE2_sepBody_kit_sound_frag` (case-split σ's zone → zXW3 ∨ zWT3 → fragL/fragR; conclusion
  byte-identical to `kvE2_sepBody_kit_sound` SW:9787-9839). Both gate producers thread the SIX
  outer-order hyps (`h_xy/h_yt/h_xt/h_yx/h_ty/h_tx`, inserted between `qnf` and `M` — already in
  fragL's signature; `kvE2_outer_fold` SW:9902-9907 already has them to supply at the call site).
- **Phase 3** `kvE2_outer_fold_frag` — copy `kvE2_outer_fold` (SW:9897-10035), replace
  hgateL/hgateR/hbdry with hfrag+hcorrK, thread the six order hyps verbatim, `hexcl` verbatim
  undischarged. Plus the 335 HANDBACK signature verification (335 Phase B's six-conjuncts-at-pin
  consumption).

## Guards (unchanged, HARD)
Additive-only below `SW:10037`; zero existing decls modified; SharedWitness.lean only; NEVER the
∀-anchor; every conjunct AT the pin; hcorrK/hexcl undischarged; per green milestone `lake build`
+ `#print axioms` == `{propext, Classical.choice, Quot.sound}` (once sorry-free) + incremental
commit. To resume: read this file + the plan checklist (item 182) + the `h_fwd`/`h_bwd` `have`
blocks at SW:10496-10505; read `kvE2_sepSegsG`/`kvE2_sepSegLForSub` FIRST.
