import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.ExteriorFiberK

/-! # Depth-`k` past-side zone/admissibility navigation layer (task 352, Phase 4.1)

The Past mirror of Phase 3.1: the depth-`k` analogs of the zone/admissibility layer on the
past exterior cone (`x1 < x`), built over `σ : NormalForm sig (k+1) 4` and parameterized
through the Phase-2 fiber-bucket navigation channel (`kvE_fiber`, `ExteriorFiberK.lean`) and
the landed determinacy core (`nf_eval_nfk_iff_efold`, `kvE_subBit_iff`). This layer is what
the past chain builder (Phase 4.2/4.3, `kvE_pastPos`/`kvE_extNegPast` + `_sound`/`_complete`)
consumes to know which zones a realized σ may prescribe subs in.

**Time-reversal dictionary (inherited, modulo depth).** The past side anchors at `x` with
exterior `x1 < x`; zone marking is `kvE2_sep_zPastX3` (`x1` strictly below all of `w, x, t`);
the six at-or-above-`x` couplings carry head coupling `(false, true)`. All of this is
depth-INDEPENDENT — it is a fact about `zoneHolds`/order over the fixed 4-anchor environment
`[x1, w, x, t]`, so the frozen k=2 public decls `kvE2_pastPossibleZones`
(`ExteriorNegationPast.lean:250`) and `kvE2_pastZoneClass` (`:264`), and the atom-layer bit
transfer `kvE2_zoneBit_below` (`ExteriorZoneTriage.lean:65`), are reused VERBATIM (they are
reachable public decls; importing is not editing — frozen `git diff` stays EMPTY). The Phase-3
Future side uses them symmetrically via `kvE2_futPossibleZones`/`kvE2_futZoneClass`.

**What is genuinely depth-`k` here (the novelty).** The frozen k=2 admissibility
(`kvE2_pastAdmissible`, `ExteriorNegationPast.lean:332`) reads σ's prescriptions through the
depth-0-hardwired coordinatization `σ.2 (nf0_assemble zs χ σ.1)` over the marginal profile
`χ : NormalForm sig 0 1`. At depth `k` that coordinatization is lossless ONLY at depth 0
(the F2 obstruction, postmortem rules 1-3), so `kvE_pastAdmissible` below reads the
**full fiber** instead: every positive fiber element `s : NormalForm sig k 5` (a full-arity
sub, `σ.2 s = true`) is read through its navigation coordinates `nfk_dropFresh s`
(atom-fiber label) and `nfk_zoneSpec s` (atom-layer zone, `nf0_zoneSpec s.atom_assgn`).
This is navigation-only (G6): NO content-bearing formula is rendered here — content is the
separate `kvE_fiberPosOn P (bucket)` channel used downstream in Phase 4.2/4.3.

**The three order-admissibility conditions** a realizer at exterior `x1 < x` FORCES on σ,
proved model-independently in `kvE_pastRealizer_admissible`:

1. **Zone marking** `nf0_zoneSpec σ.1 = kvE2_sep_zPastX3` — pure atom-layer fact
   (`kvE2_zoneBit_below`), identical to the frozen condition (1).
2. **Off-fiber falsity** — every positive fiber element sits on σ's atom fiber
   (`nfk_dropFresh s = σ.1`); the off-fiber clause of `nf_eval_nfk_iff_efold`.
3. **Order-possible zones** — every positive fiber element's zone
   (`nfk_zoneSpec s`) is one of the nine `kvE_pastPossibleZones` (via `kvE_pastZoneClass`
   applied to the realizer of `s`, whose zone is read back off its atom layer by
   `kvE_zoneHolds_of_atom`).

The frozen k=2 condition (4) (self-zone bit pattern `kvE2_pastSelfBit σ χ ↔ χ = fresh
profile`) is a CONTENT-pinning condition with no σ-syntactic depth-`k` target (the self
point's depth-`k` profile is model-determined, not encoded in σ); at depth `k` the self zone
is simply one of the nine possible zones and its content is carried by the full-fiber channel
`kvE_fiberBucket σ (self zone) χ` + `kvE_fiberPosOn` in Phase 4.2/4.3. `kvE_pastFreshProfile`
(the realizer's fresh-point atom-profile lemma, mirror of the reachable public
`kvE2_futFreshProfile`) is exposed here for that downstream self-point identification.

Purely additive NEW leaf module (H7 territory: this file only); no frozen file is touched;
`ExteriorFiberK.lean` is FROZEN and consumed unchanged (postmortem rules 5-6). -/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical
open Bimodal.Metalogic.WeakCanonical.Separation

/-! ## Possible zones and zone classification (depth-independent, reused from the frozen layer)

`ZoneSpec 4` and `zoneHolds` over the fixed 4-anchor environment `[x1, w, x, t]` carry no
depth index, so the depth-`k` past-side "possible zones" and their classification theorem ARE
the frozen k=2 public decls. Re-exposed here under the `kvE_past*` interface names the
depth-`k` chain builder (Phase 4.2/4.3) cites. -/

/-- **The nine order-possible past-exterior zone-4 specs** (`x1 < x < w < t`): the depth-`k`
    interface alias of the frozen public `kvE2_pastPossibleZones` (`ExteriorNegationPast.lean:250`).
    Depth-independent — a `ZoneSpec 4` list, no depth index. -/
def kvE_pastPossibleZones : List (ZoneSpec 4) := kvE2_pastPossibleZones

/-- **Zone-4 classification at exterior `x1`** (past side): any point's `zoneHolds` spec over
    `[x1, w, x, t]` (with `x1 < x < w < t`) is one of the nine `kvE_pastPossibleZones`. The
    depth-`k` interface wrapper of the frozen public `kvE2_pastZoneClass`
    (`ExteriorNegationPast.lean:264`); depth-independent (about points/zones/order only). -/
theorem kvE_pastZoneClass {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (v x1 w x t : M.carrier)
    (hxw : x < w) (hwt : w < t) (hx1x : x1 < x)
    (zs : ZoneSpec 4)
    (hz : zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) zs v) :
    zs ∈ kvE_pastPossibleZones :=
  kvE2_pastZoneClass M v x1 w x t hxw hwt hx1x zs hz

/-! ## Atom-layer zone read-back (reusable navigation leaf) -/

/-- **Zone read-back off a realized sub's atom layer**: a depth-`k` sub `s` realized at a
    witness `v` over `env` sits in the zone `nfk_zoneSpec s` of `v` relative to `env`. The
    zone channel is `nf0_zoneSpec s.atom_assgn` (atom layer, lossless — Q4 discipline), so its
    order bits ARE the actual order relations of `v` against the `env` points
    (`nf_eval_nf_atom_layer`). Navigation-only (no content); the depth-`k` analog of the
    read-back steps inside `kvE_subBit_iff` (`ExteriorBracketK.lean:332`). Reused by the
    admissibility proof below and available to Phase 4.2/4.3. -/
theorem kvE_zoneHolds_of_atom {sig : MonadicSignature} {k : Nat}
    (M : OrderedMonadicStructure sig) (env : Fin 4 → M.carrier) (v : M.carrier)
    (s : NormalForm sig k 5)
    (hv : nf_eval_nf M k 5 (Fin.cons v env) s) :
    zoneHolds M env (nfk_zoneSpec s) v := by
  have hatom5 := nf_eval_nf_atom_layer M (Fin.cons v env) s hv
  intro i
  have h1 := hatom5 (.order 0 i.succ (Fin.succ_ne_zero i).symm)
  have h2 := hatom5 (.order i.succ 0 (Fin.succ_ne_zero i))
  simp only [atom_eval, Fin.cons_zero, Fin.cons_succ] at h1 h2
  exact ⟨h1, h2⟩

/-! ## Realizer fresh-point profile (past side) -/

/-- **A realizer's fresh point carries σ's atom fresh profile** (past side): if σ's atom layer
    holds at `[x1, w, x, t]`, then the exterior anchor `x1` realizes the depth-0 fresh profile
    `nf0_projFresh σ.1`. Reads the atom layer only, so it reduces to the reachable public
    side-neutral `kvE2_futFreshProfile` (`ExteriorNegation.lean:996`) via the depth-1 atom
    carrier `⟨σ.1, fun _ => false⟩` (whose `.1` is σ's atom layer). Exposed for the Phase
    4.2/4.3 self-point identification. -/
theorem kvE_pastFreshProfile {sig : MonadicSignature} {k : Nat}
    (M : OrderedMonadicStructure sig) (σ : NormalForm sig (k + 1) 4)
    (x1 w x t : M.carrier)
    (hatomσ : ∀ a : AtomKind sig 4,
      atom_eval M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) a ↔ σ.1 a = true) :
    nf_eval_nf M 0 1 (fun _ => x1) (nf0_projFresh σ.1) :=
  kvE2_futFreshProfile M ⟨σ.1, fun _ => false⟩ x1 w x t hatomσ

/-! ## Depth-`k` past-side order-admissibility -/

/-- **Order-admissibility of σ** (past side, depth-`k`, syntactic, model-independent): the
    three order conditions a realizer at exterior `x1 < x` FORCES on σ — zone marking,
    off-fiber falsity, and order-possible zones — all read over the FULL fiber
    `NormalForm sig k 5` (navigation-only, G6; content is the separate `kvE_fiberPosOn`
    channel). The depth-`k` reformulation of `kvE2_pastAdmissible`
    (`ExteriorNegationPast.lean:332`): its marginal `σ.2 (nf0_assemble zs χ σ.1)` reads are
    replaced by direct full-fiber reads (the depth-0 assembly is F2-lossy at depth `k ≥ 1`),
    and its content-pinning self-zone condition (4) is subsumed by the full-fiber content
    channel downstream. -/
noncomputable def kvE_pastAdmissible {sig : MonadicSignature} {k : Nat}
    (σ : NormalForm sig (k + 1) 4) : Bool :=
  decide (nf0_zoneSpec σ.1 = kvE2_sep_zPastX3) &&
  ((Finset.univ.toList (α := NormalForm sig k 5)).all fun s =>
    decide (nfk_dropFresh s = σ.1) || !(σ.2 s)) &&
  ((Finset.univ.toList (α := NormalForm sig k 5)).all fun s =>
    (kvE_pastPossibleZones.any fun z => decide (nfk_zoneSpec s = z)) || !(σ.2 s))

/-- **A realizer forces order-admissibility** (past side, depth-`k`): if some exterior
    `x1 < x` realizes σ over `[x1, w, x, t]` (with `x < w < t`), then σ is order-admissible.
    Uses only the order bits — no semantic hypothesis on `M`. Structure mirrors
    `kvE2_pastRealizer_admissible` (`ExteriorNegationPast.lean:348`): the fold bridge
    `nf_eval_nfk_iff_efold` supplies the atom layer (condition 1 via `kvE2_zoneBit_below`),
    the off-fiber clause (condition 2), and the on-fiber existential biconditional (condition
    3, via `kvE_zoneHolds_of_atom` + `kvE_pastZoneClass`). -/
theorem kvE_pastRealizer_admissible {sig : MonadicSignature} {k : Nat}
    (M : OrderedMonadicStructure sig) (σ : NormalForm sig (k + 1) 4)
    (x1 w x t : M.carrier) (hxw : x < w) (hwt : w < t) (hx1x : x1 < x)
    (hnf : nf_eval_nf M (k + 1) 4
      (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ) :
    kvE_pastAdmissible σ = true := by
  obtain ⟨⟨hAtom, hfib⟩, hoff⟩ :=
    (nf_eval_nfk_iff_efold M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ).mp hnf
  rw [kvE_pastAdmissible]
  simp only [Bool.and_eq_true]
  refine ⟨⟨?_, ?_⟩, ?_⟩
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
  · -- (2) off-fiber bits false
    rw [List.all_eq_true]
    intro s _
    by_cases hd : nfk_dropFresh s = σ.1
    · rw [decide_eq_true hd, Bool.true_or]
    · rw [hoff s hd, Bool.not_false, Bool.or_true]
  · -- (3) every positive fiber element sits in an order-possible zone
    rw [List.all_eq_true]
    intro s _
    cases hb : σ.2 s with
    | false => rw [Bool.not_false, Bool.or_true]
    | true =>
      have hd : nfk_dropFresh s = σ.1 := by
        by_contra hne
        rw [hoff s hne] at hb
        exact Bool.noConfusion hb
      obtain ⟨v, hv⟩ := (hfib s hd).mpr hb
      have hzone := kvE_zoneHolds_of_atom M
        (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) v s hv
      have hmem := kvE_pastZoneClass M v x1 w x t hxw hwt hx1x (nfk_zoneSpec s) hzone
      rw [Bool.or_eq_true]
      exact Or.inl (List.any_eq_true.mpr ⟨nfk_zoneSpec s, hmem, decide_eq_true rfl⟩)

/-! ## Depth-`k` past-side chain-assembly navigation constants and helpers (Phase 4.2/4.3 prep)

The three exterior-zone-4 specs the past chain builder partitions σ's fiber by (the depth-`k`
analogs of the frozen `kvE2_pastGapBit`/`kvE2_pastRayBit`/`kvE2_pastSelfBit` head couplings,
`ExteriorNegationPast.lean:223/228/233`), instantiating the side-agnostic Phase-2
`kvE_fiberZoneList σ zs4`. Head coupling encodes the relation of a fiber element's fresh point
to the exterior anchor `x1`: `(false, true)` = strictly above `x1` (the gap `(x1, x)`),
`(true, false)` = strictly below `x1` (the ray `(−∞, x1)`), `(false, false)` = equal to `x1`
(the self point). All three are among the nine `kvE_pastPossibleZones` (navigation-only, G6). -/

/-- Gap zone-4 spec `(x1, x)`: fresh point strictly above `x1`, below `w, x, t`. -/
def kvE_pastGapZone : ZoneSpec 4 := Fin.cons (false, true) kvE2_sep_zPastX3

/-- Ray zone-4 spec `(−∞, x1)`: fresh point strictly below `x1` (hence below all of `w, x, t`). -/
def kvE_pastRayZone : ZoneSpec 4 := Fin.cons (true, false) kvE2_sep_zPastX3

/-- Self zone-4 spec: fresh point equal to `x1` (the endpoint). -/
def kvE_pastSelfZone : ZoneSpec 4 := Fin.cons (false, false) kvE2_sep_zPastX3

/-- The gap zone is order-possible (`kvE_pastPossibleZones` index 6). -/
theorem kvE_pastGapZone_mem : kvE_pastGapZone ∈ kvE_pastPossibleZones := by
  simp [kvE_pastGapZone, kvE_pastPossibleZones, kvE2_pastPossibleZones]

/-- The self zone is order-possible (`kvE_pastPossibleZones` index 7). -/
theorem kvE_pastSelfZone_mem : kvE_pastSelfZone ∈ kvE_pastPossibleZones := by
  simp [kvE_pastSelfZone, kvE_pastPossibleZones, kvE2_pastPossibleZones]

/-- The ray zone is order-possible (`kvE_pastPossibleZones` index 8). -/
theorem kvE_pastRayZone_mem : kvE_pastRayZone ∈ kvE_pastPossibleZones := by
  simp [kvE_pastRayZone, kvE_pastPossibleZones, kvE2_pastPossibleZones]

/-- **Generic maximal-witness pick** (past-side descending analog of the shared
    `kvE_minPick`, `ExteriorFiberK.lean:263`): from a nonempty list each of whose elements has
    some `M`-witness under `P`, extract one element with a `≤`-maximal witness dominated by a
    witness for every element. Byte-identical proof template of the frozen private
    `kvE2_pastMaxPick` (`ExteriorNegationPast.lean:484`), `{α : Type}`-generic so the past chain
    builder (which walks the gap top-down) can sort chosen occurrences by maximal extraction.
    The shared `ExteriorFiberK.lean` only exposed the ascending `kvE_minPick` (future side); this
    is the additive Past-territory descending counterpart. -/
theorem kvE_pastMaxPick {sig : MonadicSignature} {α : Type}
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

The past mirror of the Future generic `kvE_futChainG`/`BuildG`/`DestructG`
(`ExteriorNegationK.lean:216/229/293`): a `D`-guarded `Since` chain whose per-visited-item
rendering `itemF` and model-side occurrence predicate `Q` are ABSTRACT parameters (the depth-`k`
clause layer instantiates `itemF := fun s => P.existF 4 (renameNF rot5Fwd rot5Bwd s)` — the
Rabinovich re-anchoring bridge, Cor 5.4(2) — over fiber elements, guard G6). Byte-identical
descending port of the frozen private `kvE2_pastChain`/`Build`/`Destruct`
(`ExteriorNegationPast.lean:446/518/806`), with `nf_depth0_char_formula`/`nf_profile_unique`
abstracted to `itemF`/`huniq`. Min/max-witness sort via the landed `kvE_pastMaxPick`. -/

/-- Abstract `D`-guarded `Since` chain over a list of items, each rendered by `itemF`, visited in
    descending order and terminating in `endF`. Generic port of the frozen `kvE2_pastChain`. -/
noncomputable def kvE_pastChainG {α : Type}
    (itemF : α → Formula) (endF D : Formula) : List α → Formula
  | [] => Formula.snce endF D
  | a :: rest =>
      Formula.snce
        (formula_conjList [itemF a, kvE_pastChainG itemF endF D rest])
        D

/-- **Chain construction** (generic descending port of `kvE2_pastChainBuild`): from a `D`-uniform
    gap `(x1, x)`, an endpoint `endF` at `x1`, one occurrence in `(x1, s)` for each item in a
    nodup list `L` (via `Q`), the fact that occurrences force `itemF` (`hQF`), and item
    distinctness at a shared point (`huniq`), SOME permutation of `L` carries a true `D`-guarded
    `Since` chain at `s`. Max-witness sort via `kvE_pastMaxPick`. -/
theorem kvE_pastChainBuildG {sig : MonadicSignature} {α : Type} [DecidableEq α]
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (itemF : α → Formula) (endF D : Formula) (x x1 : M.carrier)
    (Q : α → M.carrier → Prop)
    (hQF : ∀ a : α, ∀ r : M.carrier, Q a r → temporal_truth M atomMap r (itemF a))
    (huniq : ∀ (a a' : α) (r : M.carrier), Q a r → Q a' r → a = a')
    (hD : ∀ r : M.carrier, x1 < r → r < x → temporal_truth M atomMap r D)
    (hend : temporal_truth M atomMap x1 endF) :
    ∀ (n : Nat) (L : List α), L.length ≤ n → L.Nodup →
      ∀ s : M.carrier, x1 < s → (∀ r : M.carrier, r < s → r < x) →
      (∀ a ∈ L, ∃ r : M.carrier, r < s ∧ x1 < r ∧ Q a r) →
      ∃ l : List α, l.Perm L ∧
        temporal_truth M atomMap s (kvE_pastChainG itemF endF D l) := by
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
    simp only [kvE_pastChainG]
    exact ⟨x1, hx1s, hend, fun r hx1r hrs => hD r hx1r (hbound r hrs)⟩
  | succ n ih =>
    intro L hlen hnd s hx1s hbound hocc
    by_cases hL : L = []
    · subst hL
      refine ⟨[], List.Perm.refl [], ?_⟩
      simp only [kvE_pastChainG]
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
      simp only [kvE_pastChainG]
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
theorem kvE_pastChainDestructG {sig : MonadicSignature} {α : Type}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (itemF : α → Formula) (endF D : Formula) :
    ∀ (l : List α) (s : M.carrier),
      (∀ a ∈ l, ∀ r : M.carrier,
        temporal_truth M atomMap r (itemF a) → temporal_truth M atomMap r D) →
      temporal_truth M atomMap s (kvE_pastChainG itemF endF D l) →
      ∃ x1 : M.carrier, x1 < s ∧ temporal_truth M atomMap x1 endF ∧
        (∀ r : M.carrier, x1 < r → r < s → temporal_truth M atomMap r D) ∧
        (∀ a ∈ l, ∃ r : M.carrier, x1 < r ∧ r < s ∧
          temporal_truth M atomMap r (itemF a)) := by
  intro l
  induction l with
  | nil =>
    intro s _ hch
    simp only [kvE_pastChainG] at hch
    obtain ⟨x1, hx1s, hend, hgap⟩ := hch
    exact ⟨x1, hx1s, hend, hgap, by simp⟩
  | cons a rest ih =>
    intro s himp hch
    simp only [kvE_pastChainG] at hch
    obtain ⟨r₀, hr₀s, hconj, hgap1⟩ := hch
    rw [formula_conjList_iff] at hconj
    have hitemr₀ : temporal_truth M atomMap r₀ (itemF a) := hconj _ (by simp)
    have hrest : temporal_truth M atomMap r₀ (kvE_pastChainG itemF endF D rest) :=
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

/-! ## The depth-`k` Past clause family (content via `kvE_fiberPosOnShift`, G6 + re-anchor)

The depth-`k` analogs of the frozen clause defs `kvE2_pastGapD`/`RayD`/`RayForm`/`End`/`Chain`/
`Pos`/`extNegPast` (`ExteriorNegationPast.lean:410-477`), symmetric with the Future depth-`k`
family (`ExteriorNegationK.lean:355-415`). Every content-bearing position renders the FULL fiber
element `s : NormalForm sig k 5` through the shared reindex bridge — `kvE_fiberPosOnShift P`
(disjunctions) or `P.existF 4 (renameNF rot5Fwd rot5Bwd s)` (per-item), which by
`kvE_fiberPosOnShift_correct`/`kvE_anchorBridge` renders content with the visited point as the
FRESH (index-0) fold witness, exactly σ's fold-layer convention (Rabinovich Def 7.5 /
Cor 5.4(2) re-anchoring — the re-dispatch that clears the env-pin blocker). Never a marginal
characteristic formula (postmortem rule 3 / guard G6). -/

/-- **Gap guard `D`** (depth-`k`, past): the shift-bridged full-fiber content disjunction over
    σ's gap-zone fiber elements — the `kvE_fiberPosOnShift`-rendered analog of `kvE2_pastGapD`
    (:410). Empty gap bucket gives `⊥`. Content channel = `kvE_fiberPosOnShift P` (G6). -/
noncomputable def kvE_pastGapD {sig : MonadicSignature}
    {atomMap : Formula → sig.preds} {k : Nat}
    (P : ExistProviders sig atomMap k) (σ : NormalForm sig (k + 1) 4) : Formula :=
  kvE_fiberPosOnShift P (kvE_fiberZoneList σ kvE_pastGapZone)

/-- **Ray disjunction** (depth-`k`, past): the shift-bridged full-fiber content disjunction over
    σ's ray-zone fiber elements. Analog of `kvE2_pastRayD` (:417). -/
noncomputable def kvE_pastRayD {sig : MonadicSignature}
    {atomMap : Formula → sig.preds} {k : Nat}
    (P : ExistProviders sig atomMap k) (σ : NormalForm sig (k + 1) 4) : Formula :=
  kvE_fiberPosOnShift P (kvE_fiberZoneList σ kvE_pastRayZone)

/-- **Exact-ray-content form** at the endpoint (depth-`k` analog of `kvE2_pastRayForm`, :426):
    every past point carries a ray fiber element (`¬P(¬D_ray)`), and each ray fiber element
    occurs (`P(P.existF 4 (renameNF s))` for each `s` in the ray zone list). Shift bridge
    throughout. -/
noncomputable def kvE_pastRayForm {sig : MonadicSignature}
    {atomMap : Formula → sig.preds} {k : Nat}
    (P : ExistProviders sig atomMap k) (σ : NormalForm sig (k + 1) 4) : Formula :=
  formula_conjList
    ((Formula.snce (kvE_pastRayD P σ).neg Formula.top).neg ::
      (kvE_fiberZoneList σ kvE_pastRayZone).map fun s =>
        Formula.snce (P.existF 4 (renameNF rot5Fwd rot5Bwd s)) Formula.top)

/-- **Endpoint description** at `x1` (depth-`k` analog of `kvE2_pastEnd`, :436): the self-zone
    fiber content (the endpoint's own shift-bridged full-fiber realization, at the self zone
    `kvE_pastSelfZone`) together with the exact ray content. -/
noncomputable def kvE_pastEnd {sig : MonadicSignature}
    {atomMap : Formula → sig.preds} {k : Nat}
    (P : ExistProviders sig atomMap k) (σ : NormalForm sig (k + 1) 4) : Formula :=
  formula_conjList
    [kvE_fiberPosOnShift P (kvE_fiberZoneList σ kvE_pastSelfZone),
     kvE_pastRayForm P σ]

/-- **`D`-guarded `Since` chain** over a list of gap fiber elements (depth-`k` analog of
    `kvE2_pastChain`, :446): the generic `kvE_pastChainG` instantiated with the shift-bridged item
    `fun s => P.existF 4 (renameNF rot5Fwd rot5Bwd s)`, the endpoint description, and the gap
    guard `D`. -/
noncomputable def kvE_pastChain {sig : MonadicSignature}
    {atomMap : Formula → sig.preds} {k : Nat}
    (P : ExistProviders sig atomMap k) (σ : NormalForm sig (k + 1) 4)
    (l : List (NormalForm sig k 5)) : Formula :=
  kvE_pastChainG (fun s => P.existF 4 (renameNF rot5Fwd rot5Bwd s))
    (kvE_pastEnd P σ) (kvE_pastGapD P σ) l

/-- **Positive local-existence form** for σ (depth-`k` analog of `kvE2_pastPos`, :461):
    admissibility-gated disjunction over the permutations of σ's gap-zone fiber list of
    `D`-guarded `Since` chains ending in the endpoint description. Inadmissible σ gives `⊥`. -/
noncomputable def kvE_pastPos {sig : MonadicSignature}
    {atomMap : Formula → sig.preds} {k : Nat}
    (P : ExistProviders sig atomMap k) (σ : NormalForm sig (k + 1) 4) : Formula :=
  if kvE_pastAdmissible σ = true then
    formula_disjList ((kvE_fiberZoneList σ kvE_pastGapZone).permutations.map
      (kvE_pastChain P σ))
  else Formula.bot

/-- **The Past-side complement clause family** (depth-`k`, the Phase-2 BINDING signature analog
    of `kvE2_extNegPast`, :473): the negation of the positive local-existence form. -/
noncomputable def kvE_extNegPast {sig : MonadicSignature}
    {atomMap : Formula → sig.preds} {k : Nat}
    (P : ExistProviders sig atomMap k) (σ : NormalForm sig (k + 1) 4) : Formula :=
  (kvE_pastPos P σ).neg

end Bimodal.Metalogic.WeakCanonical.Kamp
