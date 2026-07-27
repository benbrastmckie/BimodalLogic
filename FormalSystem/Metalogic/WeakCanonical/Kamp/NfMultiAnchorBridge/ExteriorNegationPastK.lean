/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.ExteriorFiberK
import FormalSystem.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.ExteriorFiberConsistencyK

/-! # Depth-`k` past-side zone/admissibility navigation layer

The Past mirror of Phase 3.1: the depth-`k` analogs of the zone/admissibility layer on the
past exterior cone (`x1 < x`), built over `σ : NormalForm sig (k+1) 4` and parameterized
through the Phase-2 fiber-bucket navigation channel (`kvEFiber`, `ExteriorFiberK.lean`) and
the landed determinacy core (`nf_eval_nfk_iff_efold`, `kvE_subBit_iff`). This layer is what
the past chain builder (Phase 4.2/4.3, `kvEPastPos`/`kvEExtNegPast` + `_sound`/`_complete`)
consumes to know which zones a realized σ may prescribe subs in.

**Time-reversal dictionary (inherited, modulo depth).** The past side anchors at `x` with
exterior `x1 < x`; zone marking is `kvE2SepZPastX3` (`x1` strictly below all of `w, x, t`);
the six at-or-above-`x` couplings carry head coupling `(false, true)`. All of this is
depth-INDEPENDENT — it is a fact about `zoneHolds`/order over the fixed 4-anchor environment
`[x1, w, x, t]`, so the frozen k=2 public decls `kvE2PastPossibleZones`
(`ExteriorNegationPast.lean:250`) and `kvE2_pastZoneClass` (`:264`), and the atom-layer bit
transfer `kvE2_zoneBit_below` (`ExteriorZoneTriage.lean:65`), are reused VERBATIM (they are
reachable public decls; importing is not editing — frozen `git diff` stays EMPTY). The Phase-3
Future side uses them symmetrically via `kvE2FutPossibleZones`/`kvE2_futZoneClass`.

**What is genuinely depth-`k` here (the novelty).** The frozen k=2 admissibility
(`kvE2PastAdmissible`, `ExteriorNegationPast.lean:332`) reads σ's prescriptions through the
depth-0-hardwired coordinatization `σ.2 (nf0Assemble zs χ σ.1)` over the marginal profile
`χ : NormalForm sig 0 1`. At depth `k` that coordinatization is lossless ONLY at depth 0
(the F2 obstruction, postmortem rules 1-3), so `kvEPastAdmissible` below reads the
**full fiber** instead: every positive fiber element `s : NormalForm sig k 5` (a full-arity
sub, `σ.2 s = true`) is read through its navigation coordinates `nfkDropFresh s`
(atom-fiber label) and `nfkZoneSpec s` (atom-layer zone, `nf0ZoneSpec s.atomAssgn`).
This is navigation-only (G6): NO content-bearing formula is rendered here — content is the
separate `kvEFiberPosOn P (bucket)` channel used downstream in Phase 4.2/4.3.

**The four order-admissibility conditions** a realizer at exterior `x1 < x` FORCES on σ,
proved model-independently in `kvE_pastRealizer_admissible`:

1. **Zone marking** `nf0ZoneSpec σ.1 = kvE2SepZPastX3` — pure atom-layer fact
   (`kvE2_zoneBit_below`), identical to the frozen condition (1).
2. **Off-fiber falsity** — every positive fiber element sits on σ's atom fiber
   (`nfkDropFresh s = σ.1`); the off-fiber clause of `nf_eval_nfk_iff_efold`.
3. **Order-possible zones** — every positive fiber element's zone
   (`nfkZoneSpec s`) is one of the nine `kvEPastPossibleZones` (via `kvE_pastZoneClass`
   applied to the realizer of `s`, whose zone is read back off its atom layer by
   `kvE_zoneHolds_of_atom`).
4. **Self-zone fresh-profile uniqueness** — all self-zone-prescribed depth-`k` fresh
   profiles coincide (`kvESubBit` at-most-one form), the exact mirror of
   `kvEFutAdmissible` conjunct 4 (`ExteriorNegationK.lean:95-98`).

The frozen k=2 condition (4) (self-zone bit pattern `kvE2PastSelfBit σ χ ↔ χ = fresh
profile`, which the frozen `kvE2PastAdmissible` carried symmetrically with the Future side)
survives at depth `k` in the weakened at-most-one form of condition 4 above: at depth `k` the
endpoint profile is fiber-borne (`nfkProjFresh s`), so uniqueness — not exact content — is
the σ-syntactic residue, while the content itself is carried by the full-fiber channel
`kvEFiberBucket σ (self zone) χ` + `kvEFiberPosOn` in Phase 4.2/4.3. NOTE (self-zone
restoration): condition 4 was initially DROPPED here as "subsumed by the full-fiber
content channel downstream" — machine-refuted (the self-zone counterexample: honest τ ⊕
one extra self-zone mark passes every downstream existential read while breaking per-σ
uniqueness); the conjunct is restored per report 03. `kvE_pastFreshProfile`
(the realizer's fresh-point atom-profile lemma, mirror of the reachable public
`kvE2_futFreshProfile`) is exposed here for that downstream self-point identification.

Purely additive NEW leaf module (H7 territory: this file only); no frozen file is touched;
`ExteriorFiberK.lean` is FROZEN and consumed unchanged (postmortem rules 5-6). -/

namespace FormalSystem.Metalogic.WeakCanonical.Kamp

open FormalSystem.Syntax
open FormalSystem.Metalogic.WeakCanonical
open FormalSystem.Metalogic.WeakCanonical.Separation

/-! ## Possible zones and zone classification (depth-independent, reused from the frozen layer)

`ZoneSpec 4` and `zoneHolds` over the fixed 4-anchor environment `[x1, w, x, t]` carry no
depth index, so the depth-`k` past-side "possible zones" and their classification theorem ARE
the frozen k=2 public decls. Re-exposed here under the `kvE_past*` interface names the
depth-`k` chain builder (Phase 4.2/4.3) cites. -/

/-- **The nine order-possible past-exterior zone-4 specs** (`x1 < x < w < t`): the depth-`k`
    interface alias of the frozen public `kvE2PastPossibleZones` (`ExteriorNegationPast.lean:250`).
    Depth-independent — a `ZoneSpec 4` list, no depth index. -/
def kvEPastPossibleZones : List (ZoneSpec 4) := kvE2PastPossibleZones

/-- **Zone-4 classification at exterior `x1`** (past side): any point's `zoneHolds` spec over
    `[x1, w, x, t]` (with `x1 < x < w < t`) is one of the nine `kvEPastPossibleZones`. The
    depth-`k` interface wrapper of the frozen public `kvE2_pastZoneClass`
    (`ExteriorNegationPast.lean:264`); depth-independent (about points/zones/order only). -/
theorem kvE_pastZoneClass {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (v x1 w x t : M.carrier)
    (hxw : x < w) (hwt : w < t) (hx1x : x1 < x)
    (zs : ZoneSpec 4)
    (hz : zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) zs v) :
    zs ∈ kvEPastPossibleZones :=
  kvE2_pastZoneClass M v x1 w x t hxw hwt hx1x zs hz

/-! ## Atom-layer zone read-back (reusable navigation leaf) -/

/-- **Zone read-back off a realized sub's atom layer**: a depth-`k` sub `s` realized at a
    witness `v` over `env` sits in the zone `nfkZoneSpec s` of `v` relative to `env`. The
    zone channel is `nf0ZoneSpec s.atomAssgn` (atom layer, lossless — Q4 discipline), so its
    order bits ARE the actual order relations of `v` against the `env` points
    (`nf_eval_nf_atom_layer`). Navigation-only (no content); the depth-`k` analog of the
    read-back steps inside `kvE_subBit_iff` (`ExteriorBracketK.lean:332`). Reused by the
    admissibility proof below and available to Phase 4.2/4.3. -/
theorem kvE_zoneHolds_of_atom {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    {k : Nat}
    (M : OrderedMonadicStructure sig) (env : Fin 4 → M.carrier) (v : M.carrier)
    (s : NormalForm sig k 5)
    (hv : NfEvalNf M k 5 (Fin.cons v env) s) :
    zoneHolds M env (nfkZoneSpec s) v := by
  have hatom5 := nf_eval_nf_atom_layer M (Fin.cons v env) s hv
  intro i
  have h1 := hatom5 (.order 0 i.succ (Fin.succ_ne_zero i).symm)
  have h2 := hatom5 (.order i.succ 0 (Fin.succ_ne_zero i))
  simp only [AtomEval, Fin.cons_zero, Fin.cons_succ] at h1 h2
  exact ⟨h1, h2⟩

/-! ## Realizer fresh-point profile (past side) -/

/-- **A realizer's fresh point carries σ's atom fresh profile** (past side): if σ's atom layer
    holds at `[x1, w, x, t]`, then the exterior anchor `x1` realizes the depth-0 fresh profile
    `nf0ProjFresh σ.1`. Reads the atom layer only, so it reduces to the reachable public
    side-neutral `kvE2_futFreshProfile` (`ExteriorNegation.lean:996`) via the depth-1 atom
    carrier `⟨σ.1, fun _ => false⟩` (whose `.1` is σ's atom layer). Exposed for the Phase
    4.2/4.3 self-point identification. -/
theorem kvE_pastFreshProfile {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    {k : Nat}
    (M : OrderedMonadicStructure sig) (σ : NormalForm sig (k + 1) 4)
    (x1 w x t : M.carrier)
    (hatomσ : ∀ a : AtomKind sig 4,
      AtomEval M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) a ↔ σ.1 a = true) :
    NfEvalNf M 0 1 (fun _ => x1) (nf0ProjFresh σ.1) :=
  kvE2_futFreshProfile M ⟨σ.1, fun _ => false⟩ x1 w x t hatomσ

/-! ## Depth-`k` past-side order-admissibility -/

/-- Self zone-4 spec: fresh point equal to `x1` (the endpoint). Hoisted above
    `kvEPastAdmissible` because the restored conjunct 4 reads it;
    layout now mirrors the Future file (`kvEFutSelfZone` before `kvEFutAdmissible`,
    `ExteriorNegationK.lean:70`). -/
def kvEPastSelfZone : ZoneSpec 4 := Fin.cons (false, false) kvE2SepZPastX3

/-- **Order-admissibility of σ** (past side, depth-`k`, syntactic, model-independent): the
    four order conditions a realizer at exterior `x1 < x` FORCES on σ — zone marking,
    off-fiber falsity, order-possible zones, and self-zone fresh-profile uniqueness — all
    read over the FULL fiber `NormalForm sig k 5` (navigation-only, G6; content is the
    separate `kvEFiberPosOn` channel). The depth-`k` reformulation of `kvE2PastAdmissible`
    (`ExteriorNegationPast.lean:332`): its marginal `σ.2 (nf0Assemble zs χ σ.1)` reads are
    replaced by direct full-fiber reads (the depth-0 assembly is F2-lossy at depth `k ≥ 1`),
    and its exactly-the-fresh-profile self-zone condition (4) by the weakened at-most-one
    form through the `kvESubBit` determinacy channel — the depth-`k` faithful replacement,
    byte-mirroring `kvEFutAdmissible` conjunct 4 (`ExteriorNegationK.lean:95-98`). Restored
    by the self-zone restoration (report 03): the earlier "subsumed downstream" drop was
    machine-refuted — downstream reads self marks only through the `kvEFiberPosOnShift`
    EXISTENTIAL, which cannot enforce per-σ uniqueness. -/
noncomputable def kvEPastAdmissible {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] {k : Nat}
    (σ : NormalForm sig (k + 1) 4) : Bool :=
  decide (nf0ZoneSpec σ.1 = kvE2SepZPastX3) &&
  ((Finset.univ.toList (α := NormalForm sig k 5)).all fun s =>
    (decide (nfkDropFresh s = show NormalForm sig 0 4 from σ.1) &&
      kvEFiberElemConsistent σ s) || !(σ.2 s)) &&
  ((Finset.univ.toList (α := NormalForm sig k 5)).all fun s =>
    (kvEPastPossibleZones.any fun z => decide (nfkZoneSpec s = z)) || !(σ.2 s)) &&
  ((Finset.univ.toList (α := NormalForm sig k 1)).all fun χ =>
    (Finset.univ.toList (α := NormalForm sig k 1)).all fun χ' =>
      !(kvESubBit σ kvEPastSelfZone χ) || !(kvESubBit σ kvEPastSelfZone χ') ||
        decide (χ = χ'))

/-- **A realizer forces order-admissibility** (past side, depth-`k`): if some exterior
    `x1 < x` realizes σ over `[x1, w, x, t]` (with `x < w < t`), then σ is order-admissible.
    Uses only the order bits — no semantic hypothesis on `M`. Structure mirrors
    `kvE2_pastRealizer_admissible` (`ExteriorNegationPast.lean:348`): the fold bridge
    `nf_eval_nfk_iff_efold` supplies the atom layer (condition 1 via `kvE2_zoneBit_below`),
    the off-fiber clause (condition 2), and the on-fiber existential biconditional (condition
    3, via `kvE_zoneHolds_of_atom` + `kvE_pastZoneClass`). Condition 4
    is the byte-level mirror of the Future branch (`kvE_futRealizer_admissible`,
    ExteriorNegationK.lean:170-199): `kvE_subBit_iff` (side-neutral) delivers realizing
    witnesses, the `(false, false)` self-zone head coupling forces both to the endpoint
    `x1`, and `nf_eval_unique` identifies the profiles — no order-direction hypothesis is
    consumed. -/
theorem kvE_pastRealizer_admissible {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] {k : Nat}
    (M : OrderedMonadicStructure sig) (σ : NormalForm sig (k + 1) 4)
    (x1 w x t : M.carrier) (hxw : x < w) (hwt : w < t) (hx1x : x1 < x)
    (hnf : NfEvalNf M (k + 1) 4
      (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ) :
    kvEPastAdmissible σ = true := by
  obtain ⟨⟨hAtom, hfib⟩, hoff⟩ :=
    (nf_eval_nfk_iff_efold M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ).mp hnf
  rw [kvEPastAdmissible]
  simp only [Bool.and_eq_true]
  refine ⟨⟨⟨?_, ?_⟩, ?_⟩, ?_⟩
  · -- (1) zone marking: pure atom-layer bit transfer
    refine decide_eq_true ?_
    funext i
    have hlt : x1 < (Fin.cons w (Fin.cons x (fun _ => t)) : Fin 3 → M.carrier) i := by
      match i with
      | ⟨0, _⟩ => exact hx1x.trans hxw
      | ⟨1, _⟩ => exact hx1x
      | ⟨2, _⟩ => exact hx1x.trans (hxw.trans hwt)
    rw [kvE2_zoneBit_below M x1 (Fin.cons w (Fin.cons x (fun _ => t))) σ.1 hAtom i hlt]
    match i with
    | ⟨0, _⟩ => rfl
    | ⟨1, _⟩ => rfl
    | ⟨2, _⟩ => rfl
  · -- (2) marked subs are on-fiber AND fiber-consistent (fiber-consistency conjunct; mirror of the
    -- Future branch — the guard is direction-agnostic, no order hypothesis consumed)
    rw [List.all_eq_true]
    intro s _
    rw [Bool.or_eq_true]
    by_cases hb : σ.2 s = true
    · refine Or.inl ?_
      rw [Bool.and_eq_true]
      by_cases hd : nfkDropFresh s = show NormalForm sig 0 4 from σ.1
      · -- See the mirror comment in ExteriorNegationK.lean.
        have hdec : decide (nfkDropFresh s = show NormalForm sig 0 4 from σ.1) = true :=
          decide_eq_true hd
        refine ⟨hdec, ?_⟩
        obtain ⟨v, hv⟩ := (hnf.2 s).mpr hb
        exact kvE_fiberElemConsistent_of_realized M _ v σ s hnf hv
      · exact absurd hb (by rw [hoff s hd]; exact Bool.false_ne_true)
    · exact Or.inr (by rw [Bool.not_eq_true] at hb; rw [hb]; rfl)
  · -- (3) every positive fiber element sits in an order-possible zone
    rw [List.all_eq_true]
    intro s _
    cases hb : σ.2 s with
    | false => rw [Bool.not_false, Bool.or_true]
    | true =>
      have hd : nfkDropFresh s = σ.1 := by
        by_contra hne
        rw [hoff s hne] at hb
        exact Bool.noConfusion hb
      obtain ⟨v, hv⟩ := (hfib s hd).mpr hb
      have hzone := kvE_zoneHolds_of_atom M
        (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) v s hv
      have hmem := kvE_pastZoneClass M v x1 w x t hxw hwt hx1x (nfkZoneSpec s) hzone
      rw [Bool.or_eq_true]
      exact Or.inl (List.any_eq_true.mpr ⟨nfkZoneSpec s, hmem, decide_eq_true rfl⟩)
  · -- (4) self-zone fresh-profile uniqueness (self-zone restoration; byte-level mirror of the
    -- Future conjunct-4 branch — machine-verified as report 03 §3.1; uses NO order
    -- hypotheses, only the side-neutral `kvE_subBit_iff`, the `(false, false)` self-zone
    -- head coupling, and `nf_eval_unique`)
    rw [List.all_eq_true]
    intro χ _
    rw [List.all_eq_true]
    intro χ' _
    by_cases hbχ : kvESubBit σ kvEPastSelfZone χ = true
    · by_cases hbχ' : kvESubBit σ kvEPastSelfZone χ' = true
      · obtain ⟨v, hzv, hvχ⟩ := (kvE_subBit_iff M _ σ hnf kvEPastSelfZone χ).mp hbχ
        obtain ⟨v', hzv', hv'χ'⟩ := (kvE_subBit_iff M _ σ hnf kvEPastSelfZone χ').mp hbχ'
        have hvx1 : v = x1 := by
          have h0 := hzv 0
          have hn1 : ¬ v < x1 := fun hlt => absurd (h0.1.mp hlt) Bool.false_ne_true
          have hn2 : ¬ x1 < v := fun hlt => absurd (h0.2.mp hlt) Bool.false_ne_true
          exact le_antisymm (not_lt.mp hn2) (not_lt.mp hn1)
        have hv'x1 : v' = x1 := by
          have h0 := hzv' 0
          have hn1 : ¬ v' < x1 := fun hlt => absurd (h0.1.mp hlt) Bool.false_ne_true
          have hn2 : ¬ x1 < v' := fun hlt => absurd (h0.2.mp hlt) Bool.false_ne_true
          exact le_antisymm (not_lt.mp hn2) (not_lt.mp hn1)
        rw [hvx1] at hvχ
        rw [hv'x1] at hv'χ'
        have hχχ' : χ = χ' := nf_eval_unique M k 1 (fun _ => x1) χ χ' hvχ hv'χ'
        rw [hbχ, hbχ', hχχ']
        simp
      · rw [Bool.not_eq_true] at hbχ'
        rw [hbχ']
        simp
    · rw [Bool.not_eq_true] at hbχ
      rw [hbχ]
      simp

/-! ## Depth-`k` past-side chain-assembly navigation constants and helpers (Phase 4.2/4.3 prep)

The three exterior-zone-4 specs the past chain builder partitions σ's fiber by (the depth-`k`
analogs of the frozen `kvE2PastGapBit`/`kvE2PastRayBit`/`kvE2PastSelfBit` head couplings,
`ExteriorNegationPast.lean:223/228/233`), instantiating the side-agnostic Phase-2
`kvEFiberZoneList σ zs4`. Head coupling encodes the relation of a fiber element's fresh point
to the exterior anchor `x1`: `(false, true)` = strictly above `x1` (the gap `(x1, x)`),
`(true, false)` = strictly below `x1` (the ray `(−∞, x1)`), `(false, false)` = equal to `x1`
(the self point). All three are among the nine `kvEPastPossibleZones` (navigation-only, G6). -/

/-- Gap zone-4 spec `(x1, x)`: fresh point strictly above `x1`, below `w, x, t`. -/
def kvEPastGapZone : ZoneSpec 4 := Fin.cons (false, true) kvE2SepZPastX3

/-- Ray zone-4 spec `(−∞, x1)`: fresh point strictly below `x1` (hence below all of `w, x, t`). -/
def kvEPastRayZone : ZoneSpec 4 := Fin.cons (true, false) kvE2SepZPastX3

-- `kvEPastSelfZone` (fresh point equal to `x1`) is hoisted above `kvEPastAdmissible`,
-- whose restored conjunct 4 reads it.

/-! The three memberships below reuse the certificates proved next to
    `kvE2PastPossibleZones` itself. `simp [kvEPastPossibleZones, kvE2PastPossibleZones]`
    cannot prove them: the list literal's entries are `Fin.cons p (zs3 : ZoneSpec 3)`, which
    is not type-correct at `implicit` transparency, so `simp` refuses to traverse it. `exact`
    checks at `default`, where `ZoneSpec` unfolds. -/

/-- The gap zone is order-possible (`kvEPastPossibleZones` index 6). -/
theorem kvE_pastGapZone_mem : kvEPastGapZone ∈ kvEPastPossibleZones :=
  kvE2_pastPossibleZones_mem_gap

/-- The self zone is order-possible (`kvEPastPossibleZones` index 7). -/
theorem kvE_pastSelfZone_mem : kvEPastSelfZone ∈ kvEPastPossibleZones :=
  kvE2_pastPossibleZones_mem_self

/-- The ray zone is order-possible (`kvEPastPossibleZones` index 8). -/
theorem kvE_pastRayZone_mem : kvEPastRayZone ∈ kvEPastPossibleZones :=
  kvE2_pastPossibleZones_mem_ray

/-- **Generic maximal-witness pick** (past-side descending analog of the shared
    `kvE_minPick`, `ExteriorFiberK.lean:263`): from a nonempty list each of whose elements has
    some `M`-witness under `P`, extract one element with a `≤`-maximal witness dominated by a
    witness for every element. Byte-identical proof template of the frozen private
    `kvE2_pastMaxPick` (`ExteriorNegationPast.lean:484`), `{α : Type}`-generic so the past chain
    builder (which walks the gap top-down) can sort chosen occurrences by maximal extraction.
    The shared `ExteriorFiberK.lean` only exposed the ascending `kvE_minPick` (future side); this
    is the additive Past-territory descending counterpart. -/
theorem kvE_pastMaxPick {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    {α : Type}
    (M : OrderedMonadicStructure sig) (P : α → M.carrier → Prop) :
    ∀ l : List α, l ≠ [] → (∀ a ∈ l, ∃ r, P a r) →
      ∃ a₀, a₀ ∈ l ∧ ∃ r₀, P a₀ r₀ ∧ ∀ a ∈ l, ∃ r, P a r ∧ r ≤ r₀ := by
  intro l
  induction l with
  | nil => intro h; exact absurd rfl h
  | cons a l ih =>
    intro _ hocc
    obtain ⟨r, hr⟩ := hocc a (by simp)
    by_cases hl : l = []
    · subst hl
      refine ⟨a, by simp, r, hr, fun b hb => ?_⟩
      rw [List.mem_singleton] at hb
      subst hb
      exact ⟨r, hr, le_refl r⟩
    · obtain ⟨a', ha'mem, r', hr', hmax⟩ :=
        ih hl (fun c hc => hocc c (List.mem_cons_of_mem a hc))
      rcases le_or_gt r' r with hle | hlt
      · refine ⟨a, by simp, r, hr, fun c hc => ?_⟩
        rcases List.mem_cons.mp hc with rfl | hc'
        · exact ⟨r, hr, le_refl r⟩
        · obtain ⟨r'', hr'', hle'⟩ := hmax c hc'
          exact ⟨r'', hr'', hle'.trans hle⟩
      · refine ⟨a', List.mem_cons_of_mem a ha'mem, r', hr', fun c hc => ?_⟩
        rcases List.mem_cons.mp hc with rfl | hc'
        · exact ⟨r, hr, hlt.le⟩
        · exact hmax c hc'

/-! ## Depth-`k` past-side generic `Since` chain device (Cor 5.4 `O_n`, time-reversed)

The past mirror of the Future generic `kvEFutChainG`/`BuildG`/`DestructG`
(`ExteriorNegationK.lean:216/229/293`): a `D`-guarded `Since` chain whose per-visited-item
rendering `itemF` and model-side occurrence predicate `Q` are ABSTRACT parameters (the depth-`k`
clause layer instantiates `itemF := fun s => P.existF 4 (renameNF rot5Fwd rot5Bwd s)` — the
Rabinovich re-anchoring bridge, Cor 5.4(2) — over fiber elements, guard G6). Byte-identical
descending port of the frozen private `kvE2PastChain`/`Build`/`Destruct`
(`ExteriorNegationPast.lean:446/518/806`), with `nfDepth0CharFormula`/`nf_profile_unique`
abstracted to `itemF`/`huniq`. Min/max-witness sort via the landed `kvE_pastMaxPick`. -/

/-- Abstract `D`-guarded `Since` chain over a list of items, each rendered by `itemF`, visited in
    descending order and terminating in `endF`. Generic port of the frozen `kvE2PastChain`. -/
noncomputable def kvEPastChainG {α : Type}
    (itemF : α → Formula) (endF D : Formula) : List α → Formula
  | [] => Formula.snce endF D
  | a :: rest =>
      Formula.snce
        (formulaConjList [itemF a, kvEPastChainG itemF endF D rest])
        D

/-- **Chain construction** (generic descending port of `kvE2_pastChainBuild`): from a `D`-uniform
    gap `(x1, x)`, an endpoint `endF` at `x1`, one occurrence in `(x1, s)` for each item in a
    nodup list `L` (via `Q`), the fact that occurrences force `itemF` (`hQF`), and item
    distinctness at a shared point (`huniq`), SOME permutation of `L` carries a true `D`-guarded
    `Since` chain at `s`. Max-witness sort via `kvE_pastMaxPick`. -/
theorem kvE_pastChainBuildG {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    {α : Type} [DecidableEq α]
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (itemF : α → Formula) (endF D : Formula) (x x1 : M.carrier)
    (Q : α → M.carrier → Prop)
    (hQF : ∀ a : α, ∀ r : M.carrier, Q a r → TemporalTruth M atomMap r (itemF a))
    (huniq : ∀ (a a' : α) (r : M.carrier), Q a r → Q a' r → a = a')
    (hD : ∀ r : M.carrier, x1 < r → r < x → TemporalTruth M atomMap r D)
    (hend : TemporalTruth M atomMap x1 endF) :
    ∀ (n : Nat) (L : List α), L.length ≤ n → L.Nodup →
      ∀ s : M.carrier, x1 < s → (∀ r : M.carrier, r < s → r < x) →
      (∀ a ∈ L, ∃ r : M.carrier, r < s ∧ x1 < r ∧ Q a r) →
      ∃ l : List α, l.Perm L ∧
        TemporalTruth M atomMap s (kvEPastChainG itemF endF D l) := by
  intro n
  induction n with
  | zero =>
    intro L hlen _ s hx1s hbound _
    have hL : L = [] := by
      cases L with
      | nil => rfl
      | cons a l => simp at hlen
    subst hL
    refine ⟨[], List.Perm.refl [], ?_⟩
    simp only [kvEPastChainG]
    exact ⟨x1, hx1s, hend, fun r hx1r hrs => hD r hx1r (hbound r hrs)⟩
  | succ n ih =>
    intro L hlen hnd s hx1s hbound hocc
    by_cases hL : L = []
    · subst hL
      refine ⟨[], List.Perm.refl [], ?_⟩
      simp only [kvEPastChainG]
      exact ⟨x1, hx1s, hend, fun r hx1r hrs => hD r hx1r (hbound r hrs)⟩
    · obtain ⟨a₀, ha₀mem, r₀, ⟨hr₀s, hx1r₀, hQ₀⟩, hmax⟩ :=
        kvE_pastMaxPick M
          (fun a r => r < s ∧ x1 < r ∧ Q a r) L hL hocc
      have hr₀x : r₀ < x := hbound r₀ hr₀s
      have hlen' : (L.erase a₀).length ≤ n := by
        have h1 := List.length_erase_of_mem ha₀mem
        have h2 : 0 < L.length := List.length_pos_of_mem ha₀mem
        omega
      obtain ⟨l', hl'perm, hl'truth⟩ := ih (L.erase a₀) hlen' (hnd.erase a₀) r₀ hx1r₀
        (fun r hr => hr.trans hr₀x)
        (fun a ha => by
          obtain ⟨hne, haL⟩ := (List.Nodup.mem_erase_iff hnd).mp ha
          obtain ⟨r, ⟨_, hx1r, hQr⟩, hler⟩ := hmax a haL
          refine ⟨r, lt_of_le_of_ne hler ?_, hx1r, hQr⟩
          intro he
          exact hne (huniq a a₀ r hQr (he ▸ hQ₀)))
      refine ⟨a₀ :: l', (hl'perm.cons a₀).trans (List.perm_cons_erase ha₀mem).symm, ?_⟩
      simp only [kvEPastChainG]
      refine ⟨r₀, hr₀s, ?_,
        fun r hr₀r hrs => hD r (hx1r₀.trans hr₀r) (hbound r hrs)⟩
      rw [formula_conjList_iff]
      intro f hf
      simp only [List.mem_cons, List.not_mem_nil, or_false] at hf
      rcases hf with rfl | rfl
      · exact hQF a₀ r₀ hQ₀
      · exact hl'truth

/-- **Chain destruction** (generic descending port of `kvE2_pastChainDestruct`): a true
    `D`-guarded `Since` chain at `s` yields an endpoint `x1 < s` satisfying `endF`, a `D`-uniform
    gap `(x1, s)` (given each visited item's `itemF` pointwise implies `D`), and one
    `itemF`-occurrence in `(x1, s)` for every item in the chain's list. -/
theorem kvE_pastChainDestructG {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    {α : Type}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (itemF : α → Formula) (endF D : Formula) :
    ∀ (l : List α) (s : M.carrier),
      (∀ a ∈ l, ∀ r : M.carrier,
        TemporalTruth M atomMap r (itemF a) → TemporalTruth M atomMap r D) →
      TemporalTruth M atomMap s (kvEPastChainG itemF endF D l) →
      ∃ x1 : M.carrier, x1 < s ∧ TemporalTruth M atomMap x1 endF ∧
        (∀ r : M.carrier, x1 < r → r < s → TemporalTruth M atomMap r D) ∧
        (∀ a ∈ l, ∃ r : M.carrier, x1 < r ∧ r < s ∧
          TemporalTruth M atomMap r (itemF a)) := by
  intro l
  induction l with
  | nil =>
    intro s _ hch
    simp only [kvEPastChainG] at hch
    obtain ⟨x1, hx1s, hend, hgap⟩ := hch
    exact ⟨x1, hx1s, hend, hgap, by simp⟩
  | cons a rest ih =>
    intro s himp hch
    simp only [kvEPastChainG] at hch
    obtain ⟨r₀, hr₀s, hconj, hgap1⟩ := hch
    rw [formula_conjList_iff] at hconj
    have hitemr₀ : TemporalTruth M atomMap r₀ (itemF a) := hconj _ (by simp)
    have hrest : TemporalTruth M atomMap r₀ (kvEPastChainG itemF endF D rest) :=
      hconj _ (by simp)
    obtain ⟨x1, hx1r₀, hend, hgap2, hocc⟩ :=
      ih r₀ (fun a' ha' => himp a' (List.mem_cons_of_mem a ha')) hrest
    refine ⟨x1, hx1r₀.trans hr₀s, hend, ?_, ?_⟩
    · intro r hx1r hrs
      rcases lt_trichotomy r r₀ with hlt | heq | hgt
      · exact hgap2 r hx1r hlt
      · exact heq ▸ himp a List.mem_cons_self r₀ hitemr₀
      · exact hgap1 r hgt hrs
    · intro a' ha'
      rcases List.mem_cons.mp ha' with rfl | hmem
      · exact ⟨r₀, hx1r₀, hr₀s, hitemr₀⟩
      · obtain ⟨r, hx1r, hrr₀, hitem⟩ := hocc a' hmem
        exact ⟨r, hx1r, hrr₀.trans hr₀s, hitem⟩

/-! ## The depth-`k` Past clause family (content via `kvEFiberPosOnShift`, G6 + re-anchor)

The depth-`k` analogs of the frozen clause defs `kvE2PastGapD`/`RayD`/`RayForm`/`End`/`Chain`/
`Pos`/`extNegPast` (`ExteriorNegationPast.lean:410-477`), symmetric with the Future depth-`k`
family (`ExteriorNegationK.lean:355-415`). Every content-bearing position renders the FULL fiber
element `s : NormalForm sig k 5` through the shared reindex bridge — `kvEFiberPosOnShift P`
(disjunctions) or `P.existF 4 (renameNF rot5Fwd rot5Bwd s)` (per-item), which by
`kvE_fiberPosOnShift_correct`/`kvE_anchorBridge` renders content with the visited point as the
FRESH (index-0) fold witness, exactly σ's fold-layer convention (Rabinovich Def 7.5 /
Cor 5.4(2) re-anchoring — the re-dispatch that clears the env-pin blocker). Never a marginal
characteristic formula (postmortem rule 3 / guard G6). -/

/-- **Gap guard `D`** (depth-`k`, past): the shift-bridged full-fiber content disjunction over
    σ's gap-zone fiber elements — the `kvEFiberPosOnShift`-rendered analog of `kvE2PastGapD`
    (:410). Empty gap bucket gives `⊥`. Content channel = `kvEFiberPosOnShift P` (G6). -/
noncomputable def kvEPastGapD {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    {atomMap : Formula → sig.preds} {k : Nat}
    (P : ExistProviders sig atomMap k) (σ : NormalForm sig (k + 1) 4) : Formula :=
  kvEFiberPosOnShift P (kvEFiberZoneList σ kvEPastGapZone)

/-- **Ray disjunction** (depth-`k`, past): the shift-bridged full-fiber content disjunction over
    σ's ray-zone fiber elements. Analog of `kvE2PastRayD` (:417). -/
noncomputable def kvEPastRayD {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    {atomMap : Formula → sig.preds} {k : Nat}
    (P : ExistProviders sig atomMap k) (σ : NormalForm sig (k + 1) 4) : Formula :=
  kvEFiberPosOnShift P (kvEFiberZoneList σ kvEPastRayZone)

/-- **Exact-ray-content form** at the endpoint (depth-`k` analog of `kvE2PastRayForm`, :426):
    every past point carries a ray fiber element (`¬P(¬D_ray)`), and each ray fiber element
    occurs (`P(P.existF 4 (renameNF s))` for each `s` in the ray zone list). Shift bridge
    throughout. -/
noncomputable def kvEPastRayForm {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    {atomMap : Formula → sig.preds} {k : Nat}
    (P : ExistProviders sig atomMap k) (σ : NormalForm sig (k + 1) 4) : Formula :=
  formulaConjList
    ((Formula.snce (kvEPastRayD P σ).neg Formula.top).neg ::
      (kvEFiberZoneList σ kvEPastRayZone).map fun s =>
        Formula.snce (P.existF 4 (renameNF rot5Fwd rot5Bwd s)) Formula.top)

/-- **Endpoint description** at `x1` (depth-`k` analog of `kvE2PastEnd`, :436): the self-zone
    fiber content (the endpoint's own shift-bridged full-fiber realization, at the self zone
    `kvEPastSelfZone`) together with the exact ray content. -/
noncomputable def kvEPastEnd {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    {atomMap : Formula → sig.preds} {k : Nat}
    (P : ExistProviders sig atomMap k) (σ : NormalForm sig (k + 1) 4) : Formula :=
  formulaConjList
    [kvEFiberPosOnShift P (kvEFiberZoneList σ kvEPastSelfZone),
     kvEPastRayForm P σ]

/-- **`D`-guarded `Since` chain** over a list of gap fiber elements (depth-`k` analog of
    `kvE2PastChain`, :446): the generic `kvEPastChainG` instantiated with the shift-bridged item
    `fun s => P.existF 4 (renameNF rot5Fwd rot5Bwd s)`, the endpoint description, and the gap
    guard `D`. -/
noncomputable def kvEPastChain {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    {atomMap : Formula → sig.preds} {k : Nat}
    (P : ExistProviders sig atomMap k) (σ : NormalForm sig (k + 1) 4)
    (l : List (NormalForm sig k 5)) : Formula :=
  kvEPastChainG (fun s => P.existF 4 (renameNF rot5Fwd rot5Bwd s))
    (kvEPastEnd P σ) (kvEPastGapD P σ) l

/-- **Positive local-existence form** for σ (depth-`k` analog of `kvE2PastPos`, :461):
    admissibility-gated disjunction over the permutations of σ's gap-zone fiber list of
    `D`-guarded `Since` chains ending in the endpoint description. Inadmissible σ gives `⊥`. -/
noncomputable def kvEPastPos {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    {atomMap : Formula → sig.preds} {k : Nat}
    (P : ExistProviders sig atomMap k) (σ : NormalForm sig (k + 1) 4) : Formula :=
  if kvEPastAdmissible σ = true then
    formulaDisjList ((kvEFiberZoneList σ kvEPastGapZone).permutations.map
      (kvEPastChain P σ))
  else Formula.bot

/-- **The Past-side complement clause family** (depth-`k`, the Phase-2 BINDING signature analog
    of `kvE2ExtNegPast`, :473): the negation of the positive local-existence form. -/
noncomputable def kvEExtNegPast {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    {atomMap : Formula → sig.preds} {k : Nat}
    (P : ExistProviders sig atomMap k) (σ : NormalForm sig (k + 1) 4) : Formula :=
  (kvEPastPos P σ).neg

/-! ## Soundness of the depth-`k` Past clause family

`kvE_extNegPast_sound`: if the complement clause of σ holds at the left anchor `x`, then no
exterior `x1 < x` realizes σ over `[x1, w, x, t]`. Depth-`k` port of `kvE2_extNegPast_sound`
(`ExteriorNegationPast.lean:581`): the fold decomposition `nf_eval_nfk_iff_efold` replaces the
depth-1 `nf_eval_depth1_fold_iff`; the content channel `kvEFiberPosOnShift` (rendered through
the Rabinovich re-anchoring bridge `kvE_anchorBridge`) replaces the marginal
`nfDepth0CharFormula`; visited points carry their canonical full-arity type
(`nfCharacteristic`) which the fold forces onto σ's positive fiber. Requires Prior (UZ/SZ)
structure for the `P.existF` content channel. -/

/-- A point strictly below `x` (with `x < w < t`) couples to `[x1, w, x, t]` as `zPastX3` below
    `w, x, t` and to `x1` by the given head pair (reachable local copy of the frozen private
    `kvE2_pastZone4_of_below`, `ExteriorNegationPast.lean:94`). -/
private theorem kvE_pastZoneBelow {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (v x1 w x t : M.carrier)
    (hxw : x < w) (hwt : w < t) (hvx : v < x)
    (p0 : Bool × Bool)
    (h0a : v < x1 ↔ p0.1 = true) (h0b : x1 < v ↔ p0.2 = true) :
    zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))
      (Fin.cons p0 kvE2SepZPastX3) v := by
  intro i
  match i with
  | ⟨0, _⟩ => exact ⟨h0a, h0b⟩
  | ⟨1, _⟩ =>
    exact ⟨iff_of_true (hvx.trans hxw) rfl,
           iff_of_false (lt_asymm (hvx.trans hxw)) Bool.false_ne_true⟩
  | ⟨2, _⟩ =>
    exact ⟨iff_of_true hvx rfl, iff_of_false (lt_asymm hvx) Bool.false_ne_true⟩
  | ⟨3, _⟩ =>
    exact ⟨iff_of_true (hvx.trans (hxw.trans hwt)) rfl,
           iff_of_false (lt_asymm (hvx.trans (hxw.trans hwt))) Bool.false_ne_true⟩

/-- **Carry lemma** (the depth-`k` full-fiber workhorse): under a realized σ (fold-decomposed
    into `hAtom`/`hfib`), any point `v` sitting in a zone `zs4` over σ's anchor environment
    carries a positive fiber element of σ in that zone — namely its canonical full-arity type
    `nfCharacteristic M k 5 (Fin.cons v env)`, whose atom env-restriction the fold pins to σ.1
    (`nf_eval_nf0_cons_factor` + `nf_eval_unique`), whose bit `hfib` forces true (v witnesses),
    and whose zone `zoneHolds_unique` pins to `zs4`. This is the content-channel witness both the
    gap guard and the endpoint description consume. -/
private theorem kvE_pastCarry {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    {k : Nat}
    (M : OrderedMonadicStructure sig) (σ : NormalForm sig (k + 1) 4)
    (env : Fin 4 → M.carrier)
    (hAtom : NfEvalNf M 0 4 env σ.1)
    (hfib : ∀ sub : NormalForm sig k 5, nfkDropFresh sub = σ.1 →
      ((∃ y : M.carrier, NfEvalNf M k 5 (Fin.cons y env) sub) ↔ σ.2 sub = true))
    (v : M.carrier) (zs4 : ZoneSpec 4) (hz : zoneHolds M env zs4 v) :
    ∃ s : NormalForm sig k 5, s ∈ kvEFiberZoneList σ zs4 ∧
      NfEvalNf M k 5 (Fin.cons v env) s := by
  refine ⟨nfCharacteristic M k 5 (Fin.cons v env), ?_,
    nf_characteristic_satisfies M k 5 (Fin.cons v env)⟩
  have hs : NfEvalNf M k 5 (Fin.cons v env) (nfCharacteristic M k 5 (Fin.cons v env)) :=
    nf_characteristic_satisfies M k 5 (Fin.cons v env)
  set s := nfCharacteristic M k 5 (Fin.cons v env) with hs_def
  have hatom_s := nf_eval_nf_atom_layer M (Fin.cons v env) s hs
  have hfac := (nf_eval_nf0_cons_factor M env v s.atomAssgn).mp hatom_s
  have hdrop : nfkDropFresh s = σ.1 :=
    nf_eval_unique M 0 4 env (nfkDropFresh s) σ.1 hfac.2.2 hAtom
  have hbit : σ.2 s = true := (hfib s hdrop).mp ⟨v, hs⟩
  have hzone : nfkZoneSpec s = zs4 :=
    zoneHolds_unique M env v (nfkZoneSpec s) zs4 hfac.1 hz
  rw [kvE_fiberZoneList_mem]
  exact ⟨hbit, hzone⟩

/-- **Family soundness** (depth-`k` Past, Cor 5.4(1) exterior analog, ⇒): if the complement
    clause of σ holds at the left anchor `x`, no exterior `x1 < x` realizes σ. Uses the order
    bits `hxw`/`hwt` and the Prior (UZ/SZ) structure (for the `P.existF` content channel); a
    realized exterior σ is forced `zPastX3`-marked and order-admissible. -/
theorem kvE_extNegPast_sound {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    {atomMap : Formula → sig.preds} {k : Nat}
    (P : ExistProviders sig atomMap k)
    (M : OrderedMonadicStructure sig)
    (h_UZ : SemanticPriorUZ M atomMap) (h_SZ : SemanticPriorSZ M atomMap)
    (σ : NormalForm sig (k + 1) 4)
    (w x t : M.carrier) (hxw : x < w) (hwt : w < t)
    (hcl : TemporalTruth M atomMap x (kvEExtNegPast P σ)) :
    ∀ x1 : M.carrier, x1 < x →
      ¬ NfEvalNf M (k + 1) 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ := by
  intro x1 hx1x hnf
  set env : Fin 4 → M.carrier := Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))
    with henv_def
  obtain ⟨⟨hAtom, hfib⟩, hoff⟩ := (nf_eval_nfk_iff_efold M env σ).mp hnf
  have hadm : kvEPastAdmissible σ = true :=
    kvE_pastRealizer_admissible M σ x1 w x t hxw hwt hx1x hnf
  -- the gap (x1, x) uniformly carries the gap guard D
  have hD : ∀ r : M.carrier, x1 < r → r < x →
      TemporalTruth M atomMap r (kvEPastGapD P σ) := by
    intro r hx1r hrx
    have hz : zoneHolds M env kvEPastGapZone r :=
      kvE_pastZoneBelow M r x1 w x t hxw hwt hrx (false, true)
        (iff_of_false (lt_asymm hx1r) (by decide)) (iff_of_true hx1r rfl)
    obtain ⟨s, hsmem, hs⟩ := kvE_pastCarry M σ env hAtom hfib r kvEPastGapZone hz
    rw [kvEPastGapD, kvE_fiberPosOnShift_correct P _ M h_UZ h_SZ r]
    exact ⟨s, hsmem, env, hs⟩
  -- endpoint description at x1
  have hend : TemporalTruth M atomMap x1 (kvEPastEnd P σ) := by
    rw [kvEPastEnd, formula_conjList_iff]
    intro f hf
    simp only [List.mem_cons, List.not_mem_nil, or_false] at hf
    rcases hf with rfl | rfl
    · -- self-zone content at x1
      have hz : zoneHolds M env kvEPastSelfZone x1 :=
        kvE_pastZoneBelow M x1 x1 w x t hxw hwt hx1x (false, false)
          (iff_of_false (lt_irrefl x1) (by decide)) (iff_of_false (lt_irrefl x1) (by decide))
      obtain ⟨s, hsmem, hs⟩ := kvE_pastCarry M σ env hAtom hfib x1 kvEPastSelfZone hz
      rw [kvE_fiberPosOnShift_correct P _ M h_UZ h_SZ x1]
      exact ⟨s, hsmem, env, hs⟩
    · -- exact ray content
      rw [kvEPastRayForm, formula_conjList_iff]
      intro g hg
      rcases List.mem_cons.mp hg with rfl | hg'
      · -- every past point carries a ray element
        intro hP
        obtain ⟨u, hux1, hnotD, -⟩ := hP
        apply hnotD
        have hz : zoneHolds M env kvEPastRayZone u :=
          kvE_pastZoneBelow M u x1 w x t hxw hwt (hux1.trans hx1x) (true, false)
            (iff_of_true hux1 rfl) (iff_of_false (lt_asymm hux1) (by decide))
        obtain ⟨s, hsmem, hs⟩ := kvE_pastCarry M σ env hAtom hfib u kvEPastRayZone hz
        rw [kvEPastRayD, kvE_fiberPosOnShift_correct P _ M h_UZ h_SZ u]
        exact ⟨s, hsmem, env, hs⟩
      · -- each ray element occurs at some u < x1
        obtain ⟨s, hsmem, rfl⟩ := List.mem_map.mp hg'
        rw [kvE_fiberZoneList_mem] at hsmem
        obtain ⟨hbit, hzone⟩ := hsmem
        have hdrop : nfkDropFresh s = σ.1 := by
          by_contra hne
          rw [hoff s hne] at hbit
          exact Bool.noConfusion hbit
        obtain ⟨v, hv⟩ := (hfib s hdrop).mpr hbit
        have hzv : zoneHolds M env (nfkZoneSpec s) v := kvE_zoneHolds_of_atom M env v s hv
        rw [hzone] at hzv
        have hvx1 : v < x1 := by
          have h := (hzv ⟨0, by omega⟩).1.mpr rfl
          rw [henv_def] at h; exact h
        refine ⟨v, hvx1, ?_, fun r _ _ => id⟩
        exact (P.correct 4 (renameNF rot5Fwd rot5Bwd s) M h_UZ h_SZ v).mpr
          ⟨env, (kvE_anchorBridge M env v s).mpr hv⟩
  -- each gap fiber element occurs in (x1, x) at its realized witness
  have hocc : ∀ s ∈ kvEFiberZoneList σ kvEPastGapZone, ∃ r : M.carrier,
      r < x ∧ x1 < r ∧ NfEvalNf M k 5 (Fin.cons r env) s := by
    intro s hsmem
    rw [kvE_fiberZoneList_mem] at hsmem
    obtain ⟨hbit, hzone⟩ := hsmem
    have hdrop : nfkDropFresh s = σ.1 := by
      by_contra hne
      rw [hoff s hne] at hbit
      exact Bool.noConfusion hbit
    obtain ⟨v, hv⟩ := (hfib s hdrop).mpr hbit
    have hzv : zoneHolds M env (nfkZoneSpec s) v := kvE_zoneHolds_of_atom M env v s hv
    rw [hzone] at hzv
    have hx1v : x1 < v := by
      have h := (hzv ⟨0, by omega⟩).2.mpr rfl
      rw [henv_def] at h; exact h
    have hvx : v < x := by
      have h := (hzv ⟨2, by omega⟩).1.mpr rfl
      rw [henv_def] at h; exact h
    exact ⟨v, hvx, hx1v, hv⟩
  have hnd : (kvEFiberZoneList σ kvEPastGapZone).Nodup := kvE_fiberZoneList_nodup σ _
  obtain ⟨l, hlperm, hltruth⟩ :=
    kvE_pastChainBuildG M atomMap
      (fun s => P.existF 4 (renameNF rot5Fwd rot5Bwd s))
      (kvEPastEnd P σ) (kvEPastGapD P σ) x x1
      (fun s r => NfEvalNf M k 5 (Fin.cons r env) s)
      (fun s r hQ => (P.correct 4 (renameNF rot5Fwd rot5Bwd s) M h_UZ h_SZ r).mpr
        ⟨env, (kvE_anchorBridge M env r s).mpr hQ⟩)
      (fun s s' r hQ hQ' => nf_eval_unique M k 5 (Fin.cons r env) s s' hQ hQ')
      hD hend
      (kvEFiberZoneList σ kvEPastGapZone).length (kvEFiberZoneList σ kvEPastGapZone)
      le_rfl hnd x hx1x (fun r hr => hr) hocc
  refine hcl ?_
  rw [kvEPastPos, if_pos hadm, formula_disjList_iff]
  exact ⟨_, List.mem_map.mpr ⟨l, List.mem_permutations.mpr hlperm, rfl⟩, hltruth⟩

end FormalSystem.Metalogic.WeakCanonical.Kamp
