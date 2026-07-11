# Task 344 — Continuation Handoff (dispatch 6 → dispatch 7)

- **Session**: sess_1783723095_edd5a7_344
- **Status at handoff**: Phase 1 [PARTIAL]. Still exactly TWO leaf sorries in
  `kvE2_sepGateAtPin_fragL`: `h_fwd` (`SharedWitness.lean:10516`) and `h_bwd`
  (`SharedWitness.lean:10521`). HEAD `29f97d115` is green (`lake build` exit 0; only these two
  sorries on 344's path). **The `h_fwd` "crux of the crux" (single-σ `segsG`→`segForm` segment
  reduction) is now SOLVED and verified** — see the validated template below. This dispatch did
  not commit the h_fwd body (would have exceeded the 2-sorry cap mid-proof), but it fully
  de-risked the mechanism and landed the shared zone-determinacy helper.

## What LANDED this dispatch (committed `29f97d115`)

**`zoneHolds_unique`** (`SharedWitness.lean:10218`, additive below the banner, axiom-clean
`{propext, Classical.choice, Quot.sound}`): model-general zone-spec determinacy —
`zoneHolds M env za v → zoneHolds M env zb v → za = zb`. This is the shared closer that converts
`v`'s realized zone (`hzv`) into the specific `kvE_sub2_z*` spec needed by every `h_fwd` case.
Proof: `funext i` + `Bool.eq_iff_iff.mpr (ha1.symm.trans hb1)` per coordinate.

## The DECISIVE structural finding (resolves the 5-dispatch stall)

`kvE2_sepInnerConsistentL` (`SW:1220`) enumerates EXACTLY the **9 consistent zones** = the 9
positions of `v` relative to the ordered anchors `x < x1 < w < t` (5 open intervals + 4
at-points). `kvE2_sepHgate_innerNine` (`SW:6669`) forces `σ.2 (assemble zs χ σ.1) = false` for
every INCONSISTENT zone (so those have no realizer — vacuous for `h_fwd`). Therefore `h_fwd`'s
`v` (which realizes `zs` via `hzv`) always lands in one of these 9, and the four
`kvE2_sep_locate_witness` regions sub-split by comparing `v` to `x`/`t`:

| Zone (of the 9) | v position | locate region | Exclusion channel |
|---|---|---|---|
| `kvE_sub2_zXU` | `x<v<x1` | hlow (`x<v`) / mid | `kvE2_sepSegForm_excludes` (**validated**) |
| `kvE_sub2_zUW` | `x1<v<w` | mid | `kvE2_sepSegForm_excludes` (zUW segForm) |
| `kvE_sub2_zWT` | `w<v<t` | mid / hhigh (`v<t`) | `kvE2_sepSegForm_excludes` (zWT segForm) |
| `kvE2_sep_zPastX4` | `v<x` | hlow (`v<x`) | `hepL` `snce`-literal (below-x) |
| `kvE2_sep_zAtX4` | `v=x` | hlow (`v=x`) | `hepL` at-x literal |
| `kvE2_sep_zFutT4` | `t<v` | hhigh (`t<v`) | `hepR` `snce`-literal (above-t) |
| `zAtT4` | `v=t` | hhigh (`v=t`) | `hepR` at-t literal |
| `zAtX1` (`v=x1`) | witness | case 1 `v=ws j`, j=iσ | witness (nf_eval_unique) |
| `zAtW` (`v=w`) | witness | case 1 `v=ws j`, j=lenL | witness (nf_eval_unique) |
| interior `v=ws j` | witness | case 1 (other j) | witness (nf_eval_unique) |

`kvE_sub2_zXU/zUW/zWT` bit patterns (`SubBracket2.lean:123-132`); the 9 patterns are literally
listed in `kvE2_sepInnerConsistentL` (`SW:1220-1238`) in this order:
zPastX,zAtX,zXU,zAtX1,zUW,zAtW,zWT,zAtT,zFutT.

## VALIDATED h_fwd template (compiled GREEN this dispatch — paste & extend)

Open `h_fwd` with (`by_contra` gives `hbit : σ.2 (nf0_assemble zs χ σ.1) = false`, defeq
`kvE2_sepBits σ zs χ = false`, `SW:152`):

```lean
:= by
  rintro zs χ ⟨v, hzv, hχv⟩
  by_contra hbit
  rw [Bool.not_eq_true] at hbit
  have hχbase : (⟨charBase χ⟩ : TemporalPred).eval_at M atomMap v := by
    rw [hcb]; exact (nfPred_correct M atomMap h_surj χ v).mpr hχv
  rcases kvE2_sep_locate_witness M ws v with ⟨j, hjv⟩ | hlow | ⟨i, hi1, hi2⟩ | hhigh
  · sorry  -- WITNESS case
  · -- hlow : v < ws 0
    rcases lt_or_ge x v with hxv | hvx
    · -- x < v < ws 0 ⊆ (x, x1) : zXU  — FULLY VALIDATED BELOW
      have hvx1 : v < x1 := by
        rcases Nat.eq_zero_or_pos iσ with h0 | hpos0
        · have hx1e : x1 = ws ⟨0, by omega⟩ := by rw [hx1def]; exact congrArg ws (Fin.ext h0)
          rw [hx1e]; exact hlow
        · exact hlow.trans (hmono _ _ (Fin.mk_lt_mk.mpr hpos0))
      have hvw : v < w := hvx1.trans hx1w
      have hvt : v < t := hvw.trans hwt
      have hpos : zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) kvE_sub2_zXU v := by
        intro i
        match i with
        | ⟨0, _⟩ => exact ⟨iff_of_true hvx1 rfl, iff_of_false (lt_asymm hvx1) (by decide +revert)⟩
        | ⟨1, _⟩ => exact ⟨iff_of_true hvw rfl, iff_of_false (lt_asymm hvw) (by decide +revert)⟩
        | ⟨2, _⟩ => exact ⟨iff_of_false (lt_asymm hxv) (by decide +revert), iff_of_true hxv rfl⟩
        | ⟨3, _⟩ => exact ⟨iff_of_true hvt rfl, iff_of_false (lt_asymm hvt) (by decide +revert)⟩
      have hzeq : zs = kvE_sub2_zXU := zoneHolds_unique M _ v zs kvE_sub2_zXU hzv hpos
      have hsegF : (⟨kvE2_sepSegForm charBase σ kvE_sub2_zXU⟩ : TemporalPred).eval_at M atomMap v := by
        have hh := hseg0 v hxv hlow
        simp only [kvE2_sepSegsG, kvE2_sepSegLAt, hfrag, List.map_cons, List.map_nil,
          List.take_zero, List.flatten_nil, List.length_nil, List.take_nil,
          kvE2_sepSegLForSub, hz, if_pos rfl, List.contains_nil, Nat.zero_le,
          Bool.false_eq_true, if_false, if_true] at hh
        exact (formula_conjList_iff M atomMap v _).mp hh _ List.mem_cons_self
      have hbitX : kvE2_sepBits σ kvE_sub2_zXU χ = false := by rw [hzeq] at hbit; exact hbit
      exact kvE2_sepSegForm_excludes charBase σ kvE_sub2_zXU χ M atomMap v hsegF hbitX hχbase
    · sorry  -- v ≤ x : split v<x (zPastX, hepL snce) / v=x (zAtX, hepL at-x)
  · sorry  -- mid : ws i<v<ws(i+1); zone by index i vs iσ (pin) vs lenL (w) → zXU/zUW/zWT segForm
  · sorry  -- hhigh : v > ws last; split t<v (zFutT hepR) / v=t (zAtT hepR) / w<v<t (zWT segForm)
```

**Note**: in the h_fwd context I used a local `hzuniq`; NOW it is the landed top-level
`zoneHolds_unique M _ v za zb ha hb` (adjust arg order: `M env v za zb ha hb`).

## Remaining h_fwd sub-cases — concrete recipes

- **zUW mid** (`x1<v<w`): identical shape; `hpos` for `kvE_sub2_zUW`
  (`(F,T)(T,F)(F,T)(T,F)`); segForm from `hsegMid i v hi1 hi2` — the `segsG … (i+1)` left cut
  reduces (single-σ) to `if (lL.take (i+1)).contains (.lX1 σ) then segForm zUW else segForm zXU`;
  the pin slot `.lX1 σ` IS in `lL.take (i+1)` iff `i+1 > iσ`-position, i.e. `x1 < v`. So the
  `if` resolves via a `List.contains` fact about the pin's tie-group index; derive from
  `hiσ`/`hgetiσ` (`.lX1 σ ∈ (kvE2_sepTieGroupedL wo)[iσ]`). This index bookkeeping is the one
  non-trivial remaining step for mid; `hmono` gives the ordering `ws⟨iσ⟩ < v` ⇔ `iσ < i+1` cut.
- **zWT** (`w<v<t`): `hpos` for `kvE_sub2_zWT` (`(F,T)(F,T)(F,T)(T,F)`); right-region cut →
  `kvE2_sepSegRForSub` gives `segForm charBase σ kvE_sub2_zWT` for a zXW3 σ (`SW:1143`), no
  `.contains` split needed. From `hsegMid` (right cut) or `hsegLast`.
- **zPastX / zFutT / zAtX / zAtT** (exterior/boundary): `hepL` (`SW:1054`) is a
  `formula_conjList`; its flatMap over `kvE2_sepPosIn qnf zXW3 ++ … zWT3` = `[σ]` (single-σ)
  contributes, per χ, `kvE2_sepLit (kvE2_sepBits σ kvE2_sep_zPastX4 χ) (Formula.snce (charBase χ)
  Formula.top)` and `kvE2_sepLit (kvE2_sepBits σ kvE2_sep_zAtX4 χ) (charBase χ)`. With `hbit`
  (bit false for the matching zone) the `kvE2_sepLit false f = f.neg` literal gives `¬(snce …)`
  at x resp. `¬charBase χ` at x. For zPastX: `snce (charBase χ) top` at x means ∃ point `<x`
  with charBase χ; `v<x` + `hχbase` realizes it → contra the negated literal. Need the `snce`
  (Since) truth unfold + `formula_conjList_iff` membership extraction (mirror the
  `kvE2_sepSegForm_excludes` proof shape, `SW:6691-6696`). `hepR`/`zFutT4`/`zAtT4` mirror.
  Extract the σ-block from `hepL` via `kvE2_sepPosIn qnf kvE2_sep_zXW3 = [σ]` (needs `hfrag` +
  `kvE2_sepPosIn`-vs-`kvE2_sepPos` on the zXW3 class; see `kvE2_sepPosI`/`hσI`).
- **WITNESS** (`v = ws j`): `hpt j` gives `(map classType gL ++ ptW :: map classType gR)[j]`
  holds at `ws j = v`. Single-σ (`hfrag`): each class type is a meet of σ's slot types
  (`kvE2_sepClassType`, `SW:2109`; `kvE2_sepSlotType`, `SW:316` — `.lXU/.lUW/.lWT _ χ ↦
  ⟨charBase χ⟩`, `.lX1 σ ↦ pin type`). A member slot's `⟨charBase χ_j⟩` holds at v; that slot is
  bit-TRUE by construction (`kvE2_sepS` filters `kvE2_sepBits σ z χ`), and `nf_eval_unique M 0 1
  (fun _=>v) χ χ_j` (from `hχv` + `hχbase`↔`charBase χ_j` at v via `nfPred_correct`) forces
  `χ = χ_j`; the zone of that slot (`zXU`/`zUW`/`zWT`) equals `v`'s zone by `zoneHolds_unique`,
  so `kvE2_sepBits σ zs χ = true`, contra `hbit`. The pin slot `.lX1 σ` (j=iσ) and `ptW`
  (j=lenL) are the `zAtX1`/`zAtW` at-witness sub-cases — use `kvE2_sepPtX1L`/`kvE2_sepPtW`
  biconditional literals instead. This case is the last unvalidated one; the meet-membership
  extraction (`kvE2_sepClassType` → a single bit-true slot type at v) is the open sub-step.

## h_bwd (unchanged recipe from handoff 05, `SW:10521`)

`∀ zs χ, zs ≠ kvE_sub2_zXU → σ.2 (assemble zs χ σ.1)=true → ∃ v, zoneHolds ∧ nf_eval`.
Re-derive the zUW/zWT above-witness clauses as `hbelow` (`SW:10333-10363` pattern) does for zXU
below-witnesses, but with `.lUW`/`.lWT` slots; at-zones close via the endpoint/`ptW`/`ptX1`
biconditional literals. Mirror `kvE2_sepBundleR_sound`'s `match i` zoneHolds assembly
(`SW:9760-9776`). `kvE2_sepBundleL_sound_frag` (`SW:10082`) threads h_bwd for the `zs ≠
kvE_sub2_zXU` branch.

## Then Phases 2 & 3 (unchanged from 05)
- **Phase 2**: `kvE2_sepGateAtPin_fragR` (zWX1 mirror, `kvE2_sepBundleR_sound_frag` `SW:10131`) +
  `kvE2_sepBody_kit_sound_frag` (conclusion byte-identical to `kvE2_sepBody_kit_sound` `SW:9787`).
- **Phase 3**: `kvE2_sepGateAtPin_fragL/R` → `kvE2_outer_fold_frag` (copy `kvE2_outer_fold`
  `SW:9897-10035`, hgateL/hgateR/hbdry → hfrag+hcorrK, six order hyps verbatim, `hexcl`
  undischarged) + the 335 HANDBACK signature verification.

## Guards (unchanged, HARD)
Additive-only below `SW:10037`; zero existing decls modified; SharedWitness.lean only; NEVER the
∀-anchor; every conjunct AT the pin; `hcorrK`/`hexcl` undischarged; per green milestone
`lake build` + `#print axioms` == `{propext, Classical.choice, Quot.sound}` + incremental commit.
COMPLETION BAR: zero sorries in the TASK 344 banner section. To resume: read this file, paste the
validated zXU template into `h_fwd`, extend with the four recipes above.
