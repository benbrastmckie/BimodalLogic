# Task 344 — Continuation Handoff (dispatch 8 → dispatch 9)

- **Session**: sess_1783723095_edd5a7_344
- **Status at handoff**: Phase 1 [PARTIAL]. `kvE2_sepGateAtPin_fragL` now has exactly ONE leaf
  sorry: `h_bwd` (`SharedWitness.lean:11076`). The **WITNESS case of `h_fwd` is COMPLETE** —
  h_fwd is now fully sorry-free. HEAD is GREEN (`lake build …SharedWitness` exit 0); the
  344-section sorry count is **1** (down from 2 at dispatch-7 HEAD — debt strictly decreased).

## What LANDED this dispatch (committed)

Commits on top of `ad36e85c3`:
1. `task 344 phase 1.1: ptW/ptX1L owner-lit extraction helpers` — two additive helpers
   `kvE2_sepPtW_owner_lit`, `kvE2_sepPtX1L_owner_lit` (immediately above
   `kvE2_sepGateAtPin_fragL`, mirror `kvE2_sepEpL_owner_lits`). Green.
2. `task 344 phase 1.2: h_fwd WITNESS case complete` — the flagged crux. Also added helper
   `kvE2_sep_lUW_mem_slotsLFor` (next to `kvE2_sep_lXU_mem_slotsLFor`, ~5498). Green.

**WITNESS case structure (now landed, `SharedWitness.lean` ~10660-10874):** after `subst hjv`
(`v = ws j`), trichotomy on `j.val` vs `(kvE2_sepTieGroupedL wo).length`:
- **LEFT group** (`j < |gL|`): `hpt' j.val` reduced via `kvE2_sep_getElem_left` + `getElem_map`
  to `classType gL[j]`; take a member slot `s` (via `kvE2_sepTieGroupedL_ne_nil` + `List.head_mem`),
  `kvE2_sepClassType_eval_mem` gives `slotType s` at `ws j`; `s ∈ slotsLFor σ` via the frag
  reverse-membership `hLmem` (owner uniqueness `howner_eq` + `mergeSort_perm`); `rcases` the
  `.lXU`/`.lX1`/`.lUW` decomposition. `.lXU` → gidx(lXU)<gidx(lX1) (`kvE2_sep_gidx_lt_of_rank_lt`,
  `rfl`+`Nat.zero_lt_one`) → `classIdx_lt` → `j<iσ` → zXU; `.lUW` → `Nat.one_lt_two` → `iσ<j` →
  zUW; `.lX1` → `j=iσ` (via `kvE2_sepTieRuns_key_strictMono` + `pairwise_iff_getElem` trichotomy)
  → `ws j = x1` → zAtX1L via `kvE2_sepPtX1L_owner_lit`. Base-type match `χ'=χ` via `hχeq`
  (`nfPred_correct` + `nf_eval_unique`). Each zone closed by `zoneHolds_unique` + `hbit`.
- **`j = |gL|`**: `ws j = w`, AT-w via `kvE2_sepPtW_owner_lit` + zAtWL.
- **RIGHT group** (`j > |gL|`): canonical index `|mapgL|+1+jr` fed to `hpt'` (avoids the
  `rw`-motive trap of rewriting `j.val` in `ws ⟨j.val,_⟩`), `kvE2_sep_getElem_right`+`getElem_map`,
  then `ws ⟨…⟩ = ws j` via `congrArg ws (Fin.ext hKeq)`; `.lWT` slot → zWT.

**KEY LEAN GOTCHA discovered (record for dispatch 9):** `rw [← hlenL]` / `rw [List.length_map]`
FAILS with "motive is not type correct" whenever the rewritten length occurs in `j`'s `Fin`
type. Use `omega` (with `hlenL`/`hlenR` as equality hypotheses) for all `j.val < |mapgL|`-style
facts, and feed `hpt'` the CANONICAL index directly rather than `rw [hidx] at hptj`. Also: to
keep the outer `χ`, do `rw [hχ'eq] at hχ'S hsmem` — never `subst hχ'eq` (it eliminates `χ`, not `χ'`).

## THE ONE REMAINING BLOCKER — `h_bwd` (`SharedWitness.lean:11076`)

```
h_bwd : ∀ (zs : ZoneSpec 4) (χ : NormalForm sig 0 1), zs ≠ kvE_sub2_zXU →
    σ.2 (nf0_assemble zs χ σ.1) = true →
    ∃ v, zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) zs v ∧
         nf_eval_nf M 0 1 (fun _ => v) χ
```
This is the genuine "gate honesty" converse and is a SEPARATE substantial obligation
(comparable in size to the witness case just landed — ~150-200 lines). It is NOT derivable from
a lower lemma: every `kvE2_sepBundle*_sound` TAKES `h_bwd` as a hypothesis (`SW:9786`, `10119`,
`10168`; `SubBracket2.lean:511`) — the single-σ world got it from the canonical model; here it
must be built from the realized bracket data.

### Confirmed facts for dispatch 9 (do NOT re-derive)
- `nf0_zoneSpec_assemble zs χ r = zs` (`NfEFold:197`, used `CarrierKv.lean:314`): the assembled
  sub carries zone `zs`. `nf0_projFresh_assemble` gives `projFresh = χ`. `nf0_split_assemble`
  is the three-channel round trip. With `h_off` in scope, `bit = true → dropFresh(assemble) = σ.1`.
- `kvE_sub2_zoneHolds_cons_iff` (`SubBracket2.lean:538`) converts `zoneHolds [x1,w,x,t] zs v`
  to the four coordinate biconditionals — the arity-4 lift used to BUILD `zoneHolds` witnesses.
- The zXU below-witness template is the landed `hbelow` (`SW:~10456`): `.lXU` slot at group
  index `< iσ` → `ws` point in `(x,x1)`. Mirror it for the other zones.

### Per-zone recipe (8 non-zXU zones)
- **zUW** (`x1<v<w`): `bit true → .lUW σ χ ∈ slotsLFor σ` (`kvE2_sep_lUW_mem_slotsLFor`; NB the
  reverse needs `χ ∈ kvE2_sepS σ zUW` ⟸ `bit`, via `List.mem_filter.mpr`); its group index `jχ`
  satisfies `iσ < jχ < |gL|` (gidx(lX1)<gidx(lUW) + `classIdx_lt`); witness `ws jχ`, base type
  from `kvE2_sepClassType_eval_mem` at that point. Mirror `hbelow` with `.lUW`/`Nat.one_lt_two`.
- **zWT** (`w<v<t`): `.lWT σ χ ∈ slotsRFor σ` → right group index `jr` → witness `ws (|mapgL|+1+jr)`.
- **zAtX1L** (`v=x1`): `hpt_pin` gives `ptX1L` at `x1`; `kvE2_sepPtX1L_owner_lit` +
  `bit true → lit = charBase χ` → `charBase χ` at `x1`; witness `x1`, `nfPred_correct.mp`.
- **zAtWL** (`v=w`): `hptW` + `kvE2_sepPtW_owner_lit`, witness `w`.
- **zPastX4** (`v<x`) / **zAtX4** (`v=x`): from `hepL` — the REVERSE of `kvE2_sepEpL_owner_lits`
  (bit true → the `Since(charBase χ)⊤` / at-`x` literal HOLDS at `x`). Since gives `∃ u<x`;
  at gives `v=x`. Need a `kvE2_sepEpL_owner_lits`-style extractor returning the true-branch.
- **zAtT4** (`v=t`) / **zFutT4** (`t<v`): mirror via `hepR`.
- **Any other `zs`** (not one of the 9): `bit = true` must be IMPOSSIBLE. Derive `False` from the
  order-inconsistency of the assembled sub vs `σ.1`'s `zXW3` zoneSpec (via `dropFresh(assemble)=σ.1`
  + `nf0_zoneSpec_assemble`). THIS is the hardest sub-part — the zone-classification/exclusion.
  Suggest a dedicated helper `kvE2_sep_bit_true_zone_cases : bit σ zs χ = true → zs ∈ {9 zones}`
  proven once from `h_off` + assemble round trips, then `rcases` it.

RECOMMENDED first move dispatch 9: build the `zs`-classification helper (the exclusion of
invalid zones), then the 8 extractions are each ~15-20 lines mirroring `hbelow`/the boundary
cases. After `h_bwd` lands sorry-free, `exact kvE2_sepBundleL_sound_frag atomMap h_surj σ M w x t
hwt x1 hx1w hbelow h_atom h_off h_fwd h_bwd` closes Phase 1 (zero 344-section sorries).

## Then Phases 2 & 3 (unchanged from handoff 05/06/07)
- **Phase 2**: `kvE2_sepGateAtPin_fragR` (zWX1 mirror, `kvE2_sepBundleR_sound_frag` `SW:10131`) +
  `kvE2_sepBody_kit_sound_frag` (conclusion byte-identical to `kvE2_sepBody_kit_sound` `SW:9787`).
- **Phase 3**: `kvE2_outer_fold_frag` (copy `kvE2_outer_fold` `SW:9897-10035`,
  hgateL/hgateR/hbdry → hfrag+hcorrK, hexcl threaded verbatim) + 335 HANDBACK sig verification.

## Guards (unchanged, HARD)
Additive-only below `SW:10037`; zero existing decls modified; SharedWitness.lean only; NEVER the
∀-anchor; every conjunct AT the pin; `hcorrK`/`hexcl` undischarged; per green milestone
`lake build …SharedWitness` + `#print axioms` == `{propext, Classical.choice, Quot.sound}` +
incremental commit. COMPLETION BAR: zero sorries in the TASK 344 banner section.
To resume: read this file; `h_bwd` is the sole Phase-1 blocker — start with the zone-classification
helper, then the 8 per-zone extractions.
