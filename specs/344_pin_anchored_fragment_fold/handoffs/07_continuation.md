# Task 344 — Continuation Handoff (dispatch 7 → dispatch 8)

- **Session**: sess_1783723095_edd5a7_344
- **Status at handoff**: Phase 1 [PARTIAL]. `kvE2_sepGateAtPin_fragL` now has exactly TWO leaf
  sorries: `h_fwd`'s **WITNESS case only** (`SharedWitness.lean:10623`) and `h_bwd`
  (`SharedWitness.lean:10813`). HEAD `e0d607927` is GREEN (`lake build ...SharedWitness` exit 0);
  the 344-section sorry count is **2 == the HEAD baseline** — debt did not increase.

## What LANDED this dispatch (committed `e0d607927`)

**h_fwd: 3 of 4 sub-cases fully proved and green** (`kvE2_sepGateAtPin_fragL`, the `refine_1`
zXW3 clause). The `by_contra hbit; rcases kvE2_sep_locate_witness M ws v` skeleton is in place;
only the FIRST rcases branch (WITNESS, `v = ws j`) is still `sorry`. Completed branches:

- **hlow / `x < v`** (zXU): the validated dispatch-6 template, verbatim.
- **hlow / `v ≤ x`** (boundary): `v < x` → zPastX4, `v = x` → zAtX4, both via `hepL` Since/at
  literals (`kvE2_sepEpL_owner_lits`).
- **mid** (`ws⟨i⟩ < v < ws⟨i+1⟩`): left cut → zUW (pin ≤ i) / zXU (pin > i) via
  `kvE2_sepSegLForSub` + the pin `contains` guard resolved by `kvE2_sep_pin_mem_take_flatten_iff`;
  right cut → zWT via `kvE2_sepSegRForSub`.
- **hhigh** (`ws⟨last⟩ < v`): `v < t` → zWT via `hsegLast`; `t < v` → zFutT4, `v = t` → zAtT4,
  both via `hepR` Until/at literals (`kvE2_sepEpR_owner_lits`).

**Three NEW reusable helper theorems** (additive, immediately above `kvE2_sepGateAtPin_fragL`,
all sorry-free/green):

1. `kvE2_sep_pin_mem_take_flatten_iff` (generic `List (List α)`): in a `Nodup`-flatten list of
   groups, an element known to live in group `k` is in the first `n` groups' flatten iff `k < n`.
   Resolves every `kvE2_sepSegLForSub`/`kvE2_sepSegRForSub` pin `contains` guard.
2. `kvE2_sepEpL_owner_lits`: from a realized `kvE2_sepEpL` at `x` and `σ ∈ kvE2_sepPosIn qnf
   kvE2_sep_zXW3`, extracts the per-owner zPastX4 Since-literal and zAtX4 at-literal.
3. `kvE2_sepEpR_owner_lits`: mirror at `t` — zAtT4 at-literal and zFutT4 Until-literal.

**Shared `have`s added at the top of the `h_fwd` body** (reuse them in the WITNESS case, they are
in scope): `hws_le` (index-monotone `a ≤ b → ws⟨a⟩ ≤ ws⟨b⟩`), `hlenL`
(`(kvE2_sepTieGroupedL wo).length = (map classType gL).length`), `hndL`
(`(kvE2_sepTieGroupedL wo).flatten.Nodup`, from `kvE2_sepSlotsLOf_nodup`), `hsc'`
(`.lX1 σ ∈ (kvE2_sepTieGroupedL wo)[iσ]`), `hσIn` (`σ ∈ kvE2_sepPosIn qnf kvE2_sep_zXW3`).

## KEY STRUCTURAL FACT (do NOT re-derive — verified this dispatch)

`nf_eval_depth1_fold_iff` (`CarrierKv.lean:466`) states, for `σ : NormalForm sig 1 n`:
`nf_eval_nf M 1 n env σ ↔ (atom-part ∧ (∀ zs χ, (∃v, zoneHolds env zs v ∧ nf_eval χ) ↔
σ.2 (nf0_assemble zs χ σ.1) = true) ∧ off-fiber)`. The middle conjunct IS `h_fwd`+`h_bwd`.
It is NOT a shortcut: it needs the FULL depth-1 realization `nf_eval_nf M 1 4 (x1,w,x,t) σ`,
which is exactly what the bracket data (`ws`/`hpt`/`hseg`) is proving. `h_atom` in context is
only `nf_eval_nf M 0 4 env σ.1` (the atom layer). So the segForm/endpoint/witness case analysis
is genuinely required. Route confirmed correct.

## WITNESS case recipe (`SharedWitness.lean:10623`) — the ONE remaining h_fwd sorry

Branch head: `· -- WITNESS case` with `⟨j, hjv⟩` in scope, `hjv : v = ws j`,
`j : Fin ((map classType gL).length + (map classType gR).length + 1)`. Goal `False`; `hbit :
σ.2 (nf0_assemble zs χ σ.1) = false` (defeq `kvE2_sepBits σ zs χ = false`); `hzv : zoneHolds …
zs v`; `hχbase : charBase χ eval_at v`; `hχv : nf_eval χ at v`.

Point type at the witness: `have hptj := hpt' j.val j.isLt` gives
`(map classType gL ++ ptW :: map classType gR)[j.val]` eval_at `ws⟨j.val,_⟩ = v`.
Reduce the getElem with `kvE2_sep_getElem_left/_mid/_right` (`SW:5450-5469`) + `List.getElem_map`.

v's zone is fixed by `j.val` vs `iσ` (=x1's index) and `mlL := (map classType gL).length`
(=w's index) via `ws` strict-mono (`hmono`) and `hjv`:
`j<iσ → zXU`, `j=iσ → zAtX1L (v=x1)`, `iσ<j<mlL → zUW`, `j=mlL → zAtWL (v=w)`, `mlL<j → zWT`.

**Two AT-witness sub-cases (CLEANEST — mirror the boundary cases):**
- `j = mlL` (v = w, zAtWL): point type = `kvE2_sepPtW` (`getElem_mid`). Write a helper
  `kvE2_sepPtW_owner_lit` (mirror `kvE2_sepEpL_owner_lits`) extracting the χ-literal
  `kvE2_sepLit (kvE2_sepBits σ kvE2_sep_zAtWL χ) (charBase χ)` from the `kvE2_sepPosIn qnf
  kvE2_sep_zXW3` flatMap block of `kvE2_sepPtW` (`SW:1100-1114`). `zoneHolds_unique` → `zs =
  zAtWL`, `hbit` → bit false → `charBase χ .neg` at w, `hχbase` (rewrite `v=w`) → contra.
- `j = iσ` (v = x1, zAtX1L): the pin slot `.lX1 σ ∈ c = gL[iσ]` (use `hsc`); `classType_eval_mem`
  gives `kvE2_sepPtX1L` at v. Write `kvE2_sepPtX1L_owner_lit` extracting
  `kvE2_sepLit (kvE2_sepBits σ kvE2_sep_zAtX1L χ) (charBase χ)` from `kvE2_sepPtX1L`
  (`SW:297-304` — `charK :: map χ' (lit (bits σ zAtX1L χ') (charBase χ'))`). Same contra shape.

**Three interior-witness sub-cases (zXU/zUW/zWT — THE flagged open sub-step):**
The group `c = gL[j]` (or `gR[j']`) is nonempty (`kvE2_sepTieGroupedL_ne_nil`,
`SW:2074`). Take `s ∈ c`; `classType_eval_mem … hptj (hs : s ∈ c)` gives `slotType s` at v.
`s ∈ gL.flatten = slotsLOf wo` (`kvE2_sepTieGroupedL_flatten`); for the frag case
`kvE2_sepOrderOwners wo = kvE2_sepPosI qnf = [σ]`, so `slotsLOf = mergeSort (slotsLFor σ)` →
`s ∈ slotsLFor σ` (perm), so `s ∈ {.lXU σ χ', .lX1 σ, .lUW σ χ'}` (left) / `{.lWT σ χ'}` (right).
For a 1-type slot `slotType = ⟨charBase χ'⟩` (`kvE2_sepSlotType`, `SW:316`), so `charBase χ'` at v;
with `hχbase` and `nf_eval_unique` (`NormalForm.lean:245`), **χ' = χ**. Slot membership in
`slotsLFor` ⟹ `χ' ∈ kvE2_sepS σ (zone)` ⟹ `kvE2_sepBits σ (zone) χ' = true`. The `.lX1` slot
occurs ONLY in group `iσ` (contra `j ≠ iσ`). Region↔zone match: a `.lXU` slot has `gidx < ` pin
gidx (`kvE2_sep_gidx_lt_of_rank_lt` `SW:4419`, rank .lXU=0 < .lX1=1 < .lUW=2), so its group index
`< iσ` (`kvE2_sepTieRuns_classIdx_lt` `SW:8198`) → `j < iσ` → v's zone IS zXU (consistent).
Mirror for `.lUW` (`iσ < j`) and `.lWT` (right region). **This is the exact machinery `hbelow`
uses in reverse at `SW:10333-10363` — copy that pattern.** `zoneHolds_unique` closes each by
turning `hbit` into `bits σ (zone) χ = false`, contradicting the derived `= true`.

RECOMMENDED: build two small extraction helpers (`kvE2_sepPtW_owner_lit`,
`kvE2_sepPtX1L_owner_lit`, ~15 lines each, mirror `kvE2_sepEpL_owner_lits`) and, for the interior
sub-cases, a content helper `∀ s ∈ gL[j], j<iσ → ∃ χ', s = .lXU σ χ' ∧ bits σ zXU χ' = true`
(and zUW mirror) proven from the sorted-gidx structure. Then the witness case is ~5 short bullets.

## h_bwd (`SW:10813`, unchanged) — see handoff 06 §"h_bwd"

`∀ zs χ, zs ≠ kvE_sub2_zXU → bits σ zs χ = true → ∃ v, zoneHolds ∧ nf_eval`. Recipe unchanged
from handoff 05/06: re-derive the zUW/zWT above-witness clauses as `hbelow` (`SW:10333-10363`)
does for zXU below-witnesses but with `.lUW`/`.lWT` slots; at-zones close via the
endpoint/`ptW`/`ptX1` biconditional literals; mirror `kvE2_sepBundleR_sound`'s `match i`
zoneHolds assembly (`SW:9760-9776`). Then `exact kvE2_sepBundleL_sound_frag atomMap h_surj σ M w
x t hwt x1 hx1w hbelow h_atom h_off h_fwd h_bwd` — Phase 1 COMPLETE (zero 344-section sorries).

## Then Phases 2 & 3 (unchanged from handoff 05/06)
- **Phase 2**: `kvE2_sepGateAtPin_fragR` (zWX1 mirror, `kvE2_sepBundleR_sound_frag` `SW:10131`) +
  `kvE2_sepBody_kit_sound_frag` (conclusion byte-identical to `kvE2_sepBody_kit_sound` `SW:9787`).
- **Phase 3**: `kvE2_outer_fold_frag` (copy `kvE2_outer_fold` `SW:9897-10035`,
  hgateL/hgateR/hbdry → hfrag+hcorrK, hexcl threaded verbatim) + 335 HANDBACK sig verification.

## Guards (unchanged, HARD)
Additive-only below `SW:10037`; zero existing decls modified; SharedWitness.lean only; NEVER the
∀-anchor; every conjunct AT the pin; `hcorrK`/`hexcl` undischarged; per green milestone
`lake build Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.SharedWitness` +
`#print axioms` == `{propext, Classical.choice, Quot.sound}` + incremental commit.
COMPLETION BAR: zero sorries in the TASK 344 banner section, all four target lemmas axiom-clean.
To resume: read this file; the witness case is the last h_fwd blocker — start with the two clean
AT-witness helpers, then the interior sub-cases via the `hbelow` gidx pattern.
