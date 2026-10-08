/-
Probe 711 (substrate, probe i): **the `k`-type summary substrate exercised end to end on a
concrete coloured `ℤ`-block** — a finitely presented INFINITE fibre with a per-time alphabet, the
regime `NoFiniteWidth.not_finite_width_fmp` (finite width refuted) and
`Probe732Device.not_lasso_sufficient_on_chain` (pigeonhole over states refuted) force.

**What is established (machine-checked).**

1. *The chain runs end to end on one concrete infinite fibre.* The signature has one predicate
   `p`; the block is `cPar : p` true at even times. An explicit cutting `W z := 2 * z` is
   exhibited — monotone, covering `ℤ`, with nonempty extremal segments — and its three segment
   type equations are PROVED (`cPar_seg_type`), giving `parFactorization : SegmentFactorization`
   with triple `(τmid, τmid, τmid)`. The cover theorem `family_cover` is then invoked on the same
   block, and the two agree: the Prop `family_cover sig1 k cPar` states is exactly the Prop the
   explicit factorization witnesses (`par_inFamily`, `par_family_cover_agrees`).
2. *The parity fixture's triple is degenerate, confirmed rather than assumed.* All three types
   coincide (`parFactorization_degenerate`, by `rfl`): every segment `[2z, 2z+2)` carries the
   pattern `(p, ¬p)`, so the family is `τmid^(ω*) · τmid · τmid^ω`. This is recorded, not
   smoothed over; it does not weaken the probe's central fact, which uses a second, DIFFERENT
   colouring.
3. *Two distinct blocks in one family are `k`-equal* — the probe's central fact and what makes
   saturation non-vacuous. The second block is `cOdd : p` true at odd times, cut at the odd
   times `W' z := 2 * z + 1`; its segments `[2z+1, 2z+3)` carry the same `(p, ¬p)` pattern, so
   `oddFactorization` has the same triple. `cPar ≠ cOdd` (`cPar_ne_cOdd`), yet
   `kTypeOf sig1 k (zFiber sig1 cPar) = kTypeOf sig1 k (zFiber sig1 cOdd)` for every `k`
   (`zFiber_cPar_eq_cOdd`), by `kTypeOf_zFiber_eq_of_inFamily`; the unbundled route through
   `kTypeOf_zFiber_eq_of_sameTriple` is exhibited too (`zFiber_cPar_eq_cOdd'`).
4. *The saturation theorem has an exhibited instance.* For every depth-`k` normal form `nf`, the
   target "the block satisfies `nf`" is `k`-type-determined (`determinedByKType_nfEval`), and
   `family_saturation` applied to it on the triple `(τmid, τmid, τmid)` gives the inside-or-disjoint
   dichotomy (`saturation_instance`); `target_eq_union_of_families` applied to the same target is
   `union_instance`. The branch of the dichotomy is NOT computed — `kTypeOf` is noncomputable —
   but its consequence on the two concrete blocks is: `cPar` and `cOdd` agree on every depth-`k`
   normal form (`cPar_cOdd_agree_on_nf`).
5. *Every segment-type equation is proved by an order isomorphism of segments*
   (`kTypeOf_segZ_shift`, via `k_equiv_of_iso`: a shift by `d` carrying the colouring), never by
   kernel evaluation of `kTypeOf`, which is `noncomputable` through `Classical.dec` and would not
   reduce by `decide`. No claim in this file rests on evaluating a `k`-type.

**What is NOT established.** No decidability of anything, and no complexity bound. No claim
that any `⊡` condition is a `k`-type-determined target: that is the MSO-to-ω-regular reduction,
unformalized in every proof assistant (cslib included), and the seam interface's bundle
`FormalSystem.Metalogic.Decidability.RaySummary.Presents` carries it as a hypothesis — this
probe does NOT exhibit an inhabitant of that bundle (it would need a regular `ℤ`-frame, a model
and a seam, which is the consumer's assembly work, not substrate work); the bridge
`plusStab_iff_seamSummary` is only cited (`#check`). No claim that `⊡(Fp)`/`⊡(Pp)` discriminate
between devices (`Probe732Device` settled they do not). No claim that the parity and odd fixtures'
`τmid` differs from any other type, nor that any two `k`-types in this file are DISTINCT — proving
a `k`-type inequality needs a distinguishing normal form, which this probe does not build. No
adequacy claim beyond these two fixtures.

**Axiom record.** Every theorem below: `[propext, Classical.choice, Quot.sound]` (see the
`#print axioms` foot); no `sorryAx`. The `Classical.choice` is inherited from `k_equiv_of_iso`,
the order-isomorphism machinery, and the Ramsey cover.

**Compile line.** `lake env lean specs/evidence/seam-gluing-ray-product/ktype-summary-substrate-probe.lean`
(wired into `scripts/check-evidence-probes.sh`).
-/
import FormalSystem

namespace Probe711Substrate

open FormalSystem.Metalogic.WeakCanonical FormalSystem.Metalogic.Expressiveness

/-! ## The fixture: one predicate, two colourings, two cuttings -/

/-- One unary predicate `p`. -/
def sig1 : MonadicSignature := ⟨Unit⟩

instance : Fintype sig1.preds := inferInstanceAs (Fintype Unit)
instance : DecidableEq sig1.preds := inferInstanceAs (DecidableEq Unit)
instance : Finite sig1.preds := inferInstanceAs (Finite Unit)

/-- `p` holds exactly at even times. -/
def cPar : sig1.preds → ℤ → Prop := fun _ t => t % 2 = 0

/-- `p` holds exactly at odd times — a DIFFERENT colouring with the same segment pattern once
the cutting is shifted by one. -/
def cOdd : sig1.preds → ℤ → Prop := fun _ t => t % 2 = 1

/-- The cutting at the even times: segments `[2z, 2z + 2)`. -/
def W (z : ℤ) : ℤ := 2 * z

/-- The cutting at the odd times: segments `[2z + 1, 2z + 3)`. -/
def W' (z : ℤ) : ℤ := 2 * z + 1

theorem W_mono : Monotone W := fun _ _ h => by simp only [W]; omega

theorem W_cover : ∀ t : ℤ, ∃ z, W z ≤ t ∧ t < W (z + 1) :=
  fun t => ⟨t / 2, by simp only [W]; omega, by simp only [W]; omega⟩

theorem W'_mono : Monotone W' := fun _ _ h => by simp only [W']; omega

theorem W'_cover : ∀ t : ℤ, ∃ z, W' z ≤ t ∧ t < W' (z + 1) :=
  fun t => ⟨(t - 1) / 2, by simp only [W']; omega, by simp only [W']; omega⟩

/-- `cPar ≠ cOdd`: they disagree at time `0`. -/
theorem cPar_ne_cOdd : cPar ≠ cOdd := by
  intro h
  have h0 := congr_fun (congr_fun h ()) 0
  simp [cPar, cOdd] at h0

/-! ## Segment types by order isomorphism, never by evaluation -/

/-- **Shifting a segment along a colouring-carrying translation preserves its `k`-type.** The
map `t ↦ t + d` is a strictly monotone surjection from `[a, b)` onto `[a + d, b + d)`, and `h`
says it carries `c` to `c'`; `k_equiv_of_iso` does the rest. This is the only way any segment
type equation is proved in this file. -/
theorem kTypeOf_segZ_shift (k : ℕ) (c c' : sig1.preds → ℤ → Prop) (a b d : ℤ)
    (h : ∀ t, c () t ↔ c' () (t + d)) :
    kTypeOf sig1 k (segZ sig1 c a b) = kTypeOf sig1 k (segZ sig1 c' (a + d) (b + d)) := by
  set g : (segZ sig1 c a b).carrier → (segZ sig1 c' (a + d) (b + d)).carrier :=
    fun s => ⟨s.1 + d, by obtain ⟨h1, h2⟩ := s.2; constructor <;> omega⟩ with hg
  have hgmono : StrictMono g := by
    intro s t hst
    have hst' : s.1 < t.1 := Subtype.coe_lt_coe.mpr hst
    exact Subtype.coe_lt_coe.mp (show s.1 + d < t.1 + d by omega)
  have hgsurj : Function.Surjective g := by
    intro t
    refine ⟨⟨t.1 - d, by obtain ⟨h1, h2⟩ := t.2; constructor <;> omega⟩, ?_⟩
    apply Subtype.ext
    change t.1 - d + d = t.1
    omega
  refine k_equiv_of_iso sig1 k _ _ (StrictMono.orderIsoOfSurjective g hgmono hgsurj) ?_
  intro p x
  rw [StrictMono.coe_orderIsoOfSurjective]
  change c p x.1 ↔ c' p (x.1 + d)
  cases p
  exact h x.1

/-- The one `k`-type every segment of both fixtures carries: that of `[0, 2)` under `cPar`. -/
noncomputable def τmid (k : ℕ) : KType sig1 k := kTypeOf sig1 k (segZ sig1 cPar (W 0) (W 1))

/-- Every `cPar`-segment `[2z, 2z + 2)` has type `τmid`: shift `[0, 2)` by `2z`. -/
theorem cPar_seg_type (k : ℕ) (z : ℤ) :
    kTypeOf sig1 k (segZ sig1 cPar (W z) (W (z + 1))) = τmid k := by
  have h := kTypeOf_segZ_shift k cPar cPar (W 0) (W 1) (2 * z)
    (fun t => by simp only [cPar]; omega)
  have h1 : W 0 + 2 * z = W z := by simp only [W]; ring
  have h2 : W 1 + 2 * z = W (z + 1) := by simp only [W]; ring
  rw [h1, h2] at h
  exact h.symm

/-- Every `cOdd`-segment `[2z + 1, 2z + 3)` has type `τmid`: shift `[0, 2)` under `cPar` by
`2z + 1`, which carries even to odd. -/
theorem cOdd_seg_type (k : ℕ) (z : ℤ) :
    kTypeOf sig1 k (segZ sig1 cOdd (W' z) (W' (z + 1))) = τmid k := by
  have h := kTypeOf_segZ_shift k cPar cOdd (W 0) (W 1) (2 * z + 1)
    (fun t => by simp only [cPar, cOdd]; omega)
  have h1 : W 0 + (2 * z + 1) = W' z := by simp only [W, W']; ring
  have h2 : W 1 + (2 * z + 1) = W' (z + 1) := by simp only [W, W']; ring
  rw [h1, h2] at h
  exact h.symm

/-! ## The explicit factorizations (step 3) and the cover (step 4) -/

/-- The explicit factorization of the parity block: cutting `W`, triple `(τmid, τmid, τmid)`. -/
noncomputable def parFactorization (k : ℕ) : SegmentFactorization sig1 k cPar where
  W := W
  mono := W_mono
  cover := W_cover
  τpos := τmid k
  τneg := τmid k
  pos_type := fun z _ => cPar_seg_type k z
  neg_type := fun z _ => cPar_seg_type k z
  strict_pos := by simp only [W]; omega
  strict_neg := by simp only [W]; omega
  τzero := τmid k
  zero_type := rfl

/-- **Confirmed, not assumed: the parity fixture's triple is degenerate** — all three types
coincide. -/
theorem parFactorization_degenerate (k : ℕ) :
    (parFactorization k).τneg = (parFactorization k).τzero ∧
      (parFactorization k).τzero = (parFactorization k).τpos :=
  ⟨rfl, rfl⟩

/-- The parity block is in the family `(τmid, τmid, τmid)`. -/
theorem par_inFamily (k : ℕ) : InFamily sig1 k (τmid k) (τmid k) (τmid k) cPar :=
  ⟨parFactorization k, rfl, rfl, rfl⟩

/-- The cover theorem and the explicit factorization agree: the Prop `family_cover sig1 k cPar`
proves is the Prop `par_inFamily` witnesses with a named triple. (The cover's own triple is an
existential produced through `Classical.choice`, so "agreement" is agreement of statements, not
a computed comparison of two triples.) -/
theorem par_family_cover_agrees (k : ℕ) :
    (∃ τneg τzero τpos : KType sig1 k, InFamily sig1 k τneg τzero τpos cPar) ∧
      (∃ τneg τzero τpos : KType sig1 k, InFamily sig1 k τneg τzero τpos cPar) :=
  ⟨family_cover sig1 k cPar, ⟨_, _, _, par_inFamily k⟩⟩

/-- The explicit factorization of the odd block: cutting `W'`, the SAME triple. -/
noncomputable def oddFactorization (k : ℕ) : SegmentFactorization sig1 k cOdd where
  W := W'
  mono := W'_mono
  cover := W'_cover
  τpos := τmid k
  τneg := τmid k
  pos_type := fun z _ => cOdd_seg_type k z
  neg_type := fun z _ => cOdd_seg_type k z
  strict_pos := by simp only [W']; omega
  strict_neg := by simp only [W']; omega
  τzero := τmid k
  zero_type := cOdd_seg_type k 0

/-- The odd block is in the same family. -/
theorem odd_inFamily (k : ℕ) : InFamily sig1 k (τmid k) (τmid k) (τmid k) cOdd :=
  ⟨oddFactorization k, rfl, rfl, rfl⟩

/-! ## The central fact (step 5a): two distinct blocks in one family are `k`-equal -/

/-- **Two distinct blocks in one family have equal `k`-type**, through `InFamily`. -/
theorem zFiber_cPar_eq_cOdd (k : ℕ) :
    kTypeOf sig1 k (zFiber sig1 cPar) = kTypeOf sig1 k (zFiber sig1 cOdd) :=
  kTypeOf_zFiber_eq_of_inFamily sig1 k (τmid k) (τmid k) (τmid k) cPar cOdd
    (par_inFamily k) (odd_inFamily k)

/-- The same fact through the unbundled `kTypeOf_zFiber_eq_of_sameTriple`, with the two
cuttings and the six type equations supplied explicitly. -/
theorem zFiber_cPar_eq_cOdd' (k : ℕ) :
    kTypeOf sig1 k (zFiber sig1 cPar) = kTypeOf sig1 k (zFiber sig1 cOdd) :=
  kTypeOf_zFiber_eq_of_sameTriple sig1 k cPar cOdd W W' (τmid k) (τmid k) (τmid k)
    W_mono W'_mono W_cover W'_cover
    (fun z _ => cPar_seg_type k z) (fun z _ => cPar_seg_type k z) (cPar_seg_type k 0)
    (fun z _ => cOdd_seg_type k z) (fun z _ => cOdd_seg_type k z) (cOdd_seg_type k 0)

/-! ## Saturation (step 5b) with an exhibited target -/

/-- **Saturation, instantiated.** For every depth-`k` normal form `nf`, the family
`(τmid, τmid, τmid)` is wholly inside or wholly disjoint from the target "the block satisfies
`nf`". Which branch holds depends on `nf` and is not computed here. -/
theorem saturation_instance (k : ℕ) (nf : NormalForm sig1 k 0) :
    (∀ c, InFamily sig1 k (τmid k) (τmid k) (τmid k) c →
        NfEvalNf (zFiber sig1 c) k 0 Fin.elim0 nf) ∨
      (∀ c, InFamily sig1 k (τmid k) (τmid k) (τmid k) c →
        ¬ NfEvalNf (zFiber sig1 c) k 0 Fin.elim0 nf) :=
  family_saturation sig1 k (determinedByKType_nfEval sig1 k nf) (τmid k) (τmid k) (τmid k)

/-- The consequence of the dichotomy on the two concrete blocks: `cPar` and `cOdd` agree on every
depth-`k` normal form. -/
theorem cPar_cOdd_agree_on_nf (k : ℕ) (nf : NormalForm sig1 k 0) :
    NfEvalNf (zFiber sig1 cPar) k 0 Fin.elim0 nf ↔ NfEvalNf (zFiber sig1 cOdd) k 0 Fin.elim0 nf :=
  determinedByKType_nfEval sig1 k nf cPar cOdd (zFiber_cPar_eq_cOdd k)

/-- The finite-family cover, instantiated at the same target. -/
theorem union_instance (k : ℕ) (nf : NormalForm sig1 k 0) :
    ∀ c, NfEvalNf (zFiber sig1 c) k 0 Fin.elim0 nf ↔
      ∃ τneg τzero τpos : KType sig1 k, InFamily sig1 k τneg τzero τpos c ∧
        (∀ c', InFamily sig1 k τneg τzero τpos c' → NfEvalNf (zFiber sig1 c') k 0 Fin.elim0 nf) :=
  target_eq_union_of_families sig1 k (determinedByKType_nfEval sig1 k nf)

/-! ## The seam interface, cited and not inhabited -/

-- The bridge exists and resolves; no `Presents` inhabitant is exhibited in this probe (see the
-- header's "What is NOT established").
#check @FormalSystem.Metalogic.Decidability.RaySummary.plusStab_iff_seamSummary

/-! ## Axiom record -/

#print axioms kTypeOf_segZ_shift
#print axioms parFactorization
#print axioms oddFactorization
#print axioms zFiber_cPar_eq_cOdd
#print axioms zFiber_cPar_eq_cOdd'
#print axioms saturation_instance
#print axioms cPar_cOdd_agree_on_nf
#print axioms union_instance

end Probe711Substrate
