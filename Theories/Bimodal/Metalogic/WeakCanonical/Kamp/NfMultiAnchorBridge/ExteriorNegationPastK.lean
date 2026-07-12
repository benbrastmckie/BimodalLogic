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

end Bimodal.Metalogic.WeakCanonical.Kamp
