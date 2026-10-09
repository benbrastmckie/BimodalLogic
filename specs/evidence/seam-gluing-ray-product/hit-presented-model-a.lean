/-
Probe 745 (requirement (C) of the ray-product verdict), **the record's satisfiability half, in
full.** What is landed here, in the order the file presents it: the fixture (model A of the B2b
verdict probe, transcribed); the **rigidity** result that makes the rest possible — every step
path of model A through the seam `(t, a)` is either the constant `a`-path or an `a`-then-`b` jump
path whose jump time is `≥ t`; its restatement as an identification of the seam's SPLICES
(`splice_classify`: every spliced history at the seam is `stayA` itself or `jump w` for some
`w ≥ t`); the explicit read-out of `clTrace` over the five-letter closure alphabet of `Fp` on
both of those families; the **truncation bound** `hitCl_eq_truncated`, which replaces the seam's
infinite ray index by an unexhibited finite window; the finite labelled presentation `QA`/`labOf`/
`stepOf` with its labelling bridge; the **run characterization** identifying the presentation's
anchored runs with exactly that window; and the headline.

**The headline.** `hitPresented_modelA`: for every `t : ℤ` and every depth `1 ≤ k` there EXISTS
an `L : ℕ` with `HitPresented MA stayA t Fp (labOf L) (stepOf L) k`. The `L` is NEVER exhibited.
So the Hit-level hypothesis named in `Probe735.not_presented`'s header is SATISFIABLE on fixture
model A, while NO computable bound is delivered — requirement (C)'s two halves separate here, and
only the first is landed. The section "What `hitPresented_modelA` does NOT say", at the headline
itself, is the full list of what that theorem withholds; read it before citing this file.

**The fixture.** Model A of `quasistate-does-not-determine-hit.lean` and of
`presented-not-complete.lean` (three states on `Fin 3`, `p` at `b` only, steps `a→a, a→b, b→b`),
transcribed and never imported, as this collection's convention requires; closure
`cl = {p, Fp}` with `Fp := someFuture (.atom pa)`. Bi-serial, built by `FrameOver.ofSlicedStep`,
regular through `FrameOver.ofSlicedStep_isRegular`. The seam is `(t, a)` on the constant history
`stayA`.

**The argument, in two sentences.** The sliced step relation `RA t u v := v = u ∨ v = b` makes a
step path's time component advance by exactly one (so it is pinned by its value at `t`), makes `a`
reachable only from `a` (so the slice is pinned at `a` everywhere at or before the seam), and
makes `b` absorbing (so once the slice is `b` it stays `b`). Taking `Nat.find` of the first
forward index at which the slice is `b` therefore turns the path into `jump w` for `w ≥ t`, and
the absence of such an index leaves the constant `a`-path. Transporting that classification across
`seamOmegaEquiv`/`pathFibreEquiv` and lifting the resulting state-wise equality with
`WorldHistory.ext_state` restates it as an identification of the seam's splices; and since the
closure of `Fp` has four members (`#eval (plusSubformulaClosure Fp).card` = 4, so `(clSig Fp).preds`
has those four letters plus the marker `now`), `clTrace` on either family is a five-case read-out
with no semantic content left in it.

**What is NOT established.** No bound of any kind — the headline carries an unexhibited `∃ L`
extracted from `Set.Finite.bddAbove`, i.e. from `Classical.choice`, and nothing in this file would
make such an `L` effective. Forward-only: nothing about
`⊡(P p)`, because the fixture is forward-only and there is still no backward Bool-fixture bridge
(`Probe719Backward.pastStab_iff_allBwdPathsMeet` on the asymmetric fixture remains the only
backward fixture result, and no symmetry is implied here). No decidability of anything:
`Decidable (PlusValidZTime φ)` is NOT stated in any form, conditional or otherwise, and no claim
is made that L⁺ is decidable, qualified or not. No complexity bound, upper or lower. Nothing
about general regular `ℤ`-models (see the next paragraph). Nothing about models whose slices are
infinite: this fixture's slice is `Fin 3` while its carrier `ℤ × Fin 3` is infinite, which is the
shape `NoFiniteWidth.not_finite_width_fmp` leaves standing, so no finite-fibre or finite-width
assumption is made or needed anywhere in this file.

**This does NOT generalize.** Model A's splices are eventually constant in BOTH directions, and
that is exactly what lets a finite presentation realize finitely many of them exactly. For a
general regular `ℤ`-model the route needs one lasso per family triple, and the `⊆` direction of
that route is open. The classification below is a fact about `RA` specifically — it is read off
`v = u ∨ v = b` — and nothing in it survives replacement of the fixture.

**This does NOT weaken or retire `Probe735.not_presented`.** That probe refutes an equality of
TRACE sets (`RaySummary.Presented`); this record establishes an equality of FAMILY-TRIPLE sets
(`RaySummary.HitPresented`). The presentation this record builds is deliberately NOT `Presented`
— it realizes only finitely many of the seam's traces — so there is no conflict: both hold
simultaneously on the same fixture, at the same seam, for the same `φ`. Task 735's verdict and
its wired probe stand unchanged.

**The decision held in place.** The Hit-level hypothesis named in `Probe735.not_presented`'s
header is SATISFIABLE, not refuted: the forward-type observation that blocked the transfer of
735's refutation is real, so the obstruction that killed `Presented` does not reach `HitPresented`,
and the route through (C) is not closed by 735. The companion decision is that satisfiability
buys NO bound, and it is recorded in this header's "Bound verdict" paragraph below rather than
left to a later phase.

**Bound verdict: BLOCKED, with the obligation named.** Requirement (C)'s second half asks for
`Fintype.card Q` below a COMPUTABLE bound in `φ`. This file does not deliver it, and the
obstruction is specific. `hitCl_eq_truncated` below replaces the seam's infinite ray index by a
finite window by applying `Set.Finite.bddAbove` to the offsets realized in `HitCl`, whose
finiteness comes from `finite_family_triples`; that argument exhibits no `L` at all — not a bad
bound, not a non-elementary one, not even a fixture-specific one. So every cardinality figure
downstream of it (`card_QA`'s `Fintype.card (QA L) = L + 6`, `jump_window_card`'s `L + 1`) is a
function of a number nothing produces. The in-tree entry point for an EFFECTIVE bound is
`kTypeOf_listSeg_append_congr` (`RaySummary/Compose.lean`), which makes
`m ↦ kTypeOf sig k (listSeg (List.replicate m ℓ))` a morphism into the finite alphabet
`kType_finite` bounds; the threshold consequence is not in the tree, and
`KTypeSummary/Saturation.lean` holds no block-length threshold lemma (re-derived by grep at the
time of writing: its four theorems are `kTypeColouring_eq_of_matching_segments`,
`kEquiv_zFiber_of_matching_segments`, `kTypeOf_zFiber_eq_of_sameTriple` and
`kTypeOf_zFiber_eq_of_inFamily`, none of them about thresholds, block lengths or periodicity). The
single missing obligation, STATED AND NOT PROVED, and deliberately not landed as a `sorry`
anywhere in this tree:

    theorem kTypeOf_listSeg_replicate_eventually_periodic (sig : MonadicSignature)
        [Fintype sig.preds] [DecidableEq sig.preds] (k : ℕ) (ℓ : sig.preds → Bool) :
        ∃ m₀ p, 0 < p ∧ ∀ m, m₀ ≤ m →
          kTypeOf sig k (listSeg (List.replicate (m + p) ℓ))
            = kTypeOf sig k (listSeg (List.replicate m ℓ))

provable from `kTypeOf_listSeg_append_congr` plus `kType_finite` by finite-semigroup idempotence.
It is the named unit of successor work, not a discharged one.

**And the honest note on "machine-checked", stated rather than smoothed over.** A claim that NO
computable bound exists is not a Lean-statable property of this development, so the bound half
cannot be machine-checked the way the satisfiability half was. What IS machine-checked is
narrower, and is exactly these two things: the headline's `∃ L` shape, which puts the
non-exhibition in the STATEMENT rather than in prose, and its axiom foot, which carries
`Classical.choice`. That substitution — axiom foot plus a named, stated-not-proved obligation, in
place of a theorem asserting impossibility — is the recorded one, and nothing here asserts
impossibility.

**Axiom record**, as OBSERVED from the `#print axioms` foot rather than predicted. Every pinned
declaration reports `[propext, Classical.choice, Quot.sound]` — `path_classify`, `stayA`, `jump`,
`splice_classify`, `clTrace_stayA_eq`, `clTrace_jump_eq`, `hitCl_eq_truncated`, `labOf`,
`labOf_inl_iff_clTrace_stayA`, `labOf_inr_iff_clTrace_jump`, `runTrace_mem_of_isRun`,
`exists_isRun_runTrace` and the headline `hitPresented_modelA` — with the single exception of
`stepOf`, which is `[propext]` alone, it being a decidable `Bool`-valued table. No `sorryAx`
anywhere, and no fourth axiom. `Classical.choice` enters at four places and nowhere else:
`FrameOver.worldHistoryOfStepPath` and the `Nat.find`/`by_cases` bookkeeping in `path_classify`
(as in every probe of this collection), the `choose!` offset function in `hitCl_eq_truncated`,
and `Set.Finite.bddAbove` in the same proof — that last one is why the headline's `L` is an
existential with no number behind it. Nothing in this file is left unproved: zero sorries.

**Compile line.**
`lake env lean specs/evidence/seam-gluing-ray-product/hit-presented-model-a.lean`
— or, as the guard runs it, `bash scripts/check-evidence-probes.sh`, whose `WIRED` list now
carries `seam-gluing-ray-product/hit-presented-model-a` with its own table entry. This file sits
outside the Lake build graph, so `lake build` never compiles it; the guard is what keeps it from
rotting. The two library declarations it discharges on the fixture, `HitPresented` and
`hitPresented_of_presented`, are axiom-pinned in
`Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` (which cannot import this file, for the
same out-of-graph reason), and `hitPresented_of_presented` carries a `docs/theorem-index.md` row
stating what the result does and does not deliver.
-/
import FormalSystem

open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.PlusLanguage
open FormalSystem.PlusLanguage.PlusFormula
open FormalSystem.Metalogic.WeakCanonical FormalSystem.Metalogic.Expressiveness
open FormalSystem.Metalogic.Decidability.RaySummary

namespace Probe745

/-! ## The fixture (model A of the B2b verdict probe, re-declared) -/

abbrev St := Fin 3

def a : St := 0
def b : St := 1

def pa : Atom := ⟨"p", none⟩

abbrev Fp : PlusFormula := someFuture (.atom pa)

/-- Fixture model A's sliced step relation: stay, or jump to `b`. -/
def RA : ℤ → St → St → Prop := fun _ u v => v = u ∨ v = b

theorem RA_fwd : ∀ (t : ℤ) (w : St), ∃ u, RA t w u := fun _ w => ⟨w, Or.inl rfl⟩
theorem RA_bwd : ∀ (t : ℤ) (w : St), ∃ v, RA (t - 1) v w := fun _ w => ⟨w, Or.inl rfl⟩
theorem RA_aa : ∀ t, RA t a a := fun _ => Or.inl rfl
theorem RA_ab : ∀ t, RA t a b := fun _ => Or.inr rfl
theorem RA_bb : ∀ t, RA t b b := fun _ => Or.inl rfl

abbrev FA : FrameOver intOrder := FrameOver.ofSlicedStep RA RA_fwd RA_bwd

instance instFARegular : FA.IsRegular := FrameOver.ofSlicedStep_isRegular RA RA_fwd RA_bwd

theorem ab_ne : a ≠ b := by decide

/-- `p` holds exactly at `b`. -/
def MA : TaskModel FA.toTaskFrame where
  valuation q _ := q.2 = b

/-- The constant history at `a`. -/
noncomputable def stayA : WorldHistory FA.toTaskFrame :=
  FrameOver.worldHistoryOfStepPath FA (fun z => (z, a)) (by
    intro z
    exact (FrameOver.ofSlicedStep_step RA RA_fwd RA_bwd _ _).mpr ⟨rfl, RA_aa z⟩)

theorem stayA_state (z : ℤ) : stayA.state z = (z, a) := rfl

/-- The history at `a` up to `w` and at `b` from `w + 1`. -/
noncomputable def jump (w : ℤ) : WorldHistory FA.toTaskFrame :=
  FrameOver.worldHistoryOfStepPath FA (fun z => (z, if w < z then b else a)) (by
    intro z
    refine (FrameOver.ofSlicedStep_step RA RA_fwd RA_bwd _ _).mpr ⟨rfl, ?_⟩
    show RA z (if w < z then b else a) (if w < z + 1 then b else a)
    by_cases h : w < z
    · rw [if_pos h, if_pos (by omega)]
      exact RA_bb z
    · rw [if_neg h]
      by_cases h' : w < z + 1
      · rw [if_pos h']
        exact RA_ab z
      · rw [if_neg h']
        exact RA_aa z)

theorem jump_state (w z : ℤ) : (jump w).state z = (z, if w < z then b else a) := rfl

theorem p_iff (σ : WorldHistory FA.toTaskFrame) (z : ℤ) :
    PlusTruthAt MA σ z (.atom pa) ↔ (σ.state z).2 = b := Iff.rfl

theorem Fp_iff (σ : WorldHistory FA.toTaskFrame) (z : ℤ) :
    PlusTruthAt MA σ z Fp ↔ ∃ s, z < s ∧ (σ.state s).2 = b :=
  PlusTruth.someFuture_iff _ _ _ _

theorem jump_p_iff (w z : ℤ) : PlusTruthAt MA (jump w) z (.atom pa) ↔ w < z := by
  rw [p_iff, jump_state]
  by_cases h : w < z
  · simp [h]
  · simp [h, a, b]

theorem jump_Fp (w z : ℤ) : PlusTruthAt MA (jump w) z Fp := by
  rw [Fp_iff]
  refine ⟨max w z + 1, by omega, ?_⟩
  rw [jump_state]
  show (if w < max w z + 1 then b else a) = b
  rw [if_pos (by omega)]

/-! ## Step-path rigidity on model A at the seam `(t, a)`

Everything in this section is a fact about `RA` — read off `v = u ∨ v = b` — and nothing in it
survives replacement of the fixture. -/

theorem stepA {g : ℤ → ℤ × St} (hg : IsStepPath FA g) (z : ℤ) :
    (g (z + 1)).1 = (g z).1 + 1 ∧ RA (g z).1 (g z).2 (g (z + 1)).2 :=
  (FrameOver.ofSlicedStep_step RA RA_fwd RA_bwd _ _).mp (hg z)

/-- The time component advances by one, so it is pinned by its value at `t`. -/
theorem time_eq {g : ℤ → ℤ × St} (hg : IsStepPath FA g) (t : ℤ) (ht : (g t).1 = t) :
    ∀ z, (g z).1 = z := by
  have key : ∀ n : ℤ, (g (t + n)).1 = t + n := by
    intro n
    induction n using Int.induction_on with
    | zero => simpa using ht
    | succ i ih =>
      have := (stepA hg (t + i)).1
      rw [ih] at this
      rw [show t + ((i : ℤ) + 1) = t + (i : ℤ) + 1 by ring, this]
    | pred i ih =>
      have := (stepA hg (t + (-(i : ℤ) - 1))).1
      rw [show t + (-(i : ℤ) - 1) + 1 = t + -(i : ℤ) by ring, ih] at this
      omega
  intro z
  have := key (z - t)
  simpa using this

/-- Backward from the seam the slice is pinned at `a`: in `RA`, `a` is reachable only from `a`. -/
theorem bwd_a {g : ℤ → ℤ × St} (hg : IsStepPath FA g) (t : ℤ) (ht : (g t).2 = a) :
    ∀ z ≤ t, (g z).2 = a := by
  have key : ∀ n : ℕ, (g (t - n)).2 = a := by
    intro n
    induction n with
    | zero => simpa using ht
    | succ i ih =>
      have h := (stepA hg (t - (i + 1 : ℕ))).2
      push_cast at h ih ⊢
      rw [show t - ((i : ℤ) + 1) + 1 = t - (i : ℤ) by ring, ih] at h
      rcases h with h | h
      · exact h.symm
      · exact absurd h ab_ne
  intro z hz
  have := key (t - z).toNat
  rwa [show t - ((t - z).toNat : ℤ) = z by omega] at this

/-- Forward from the seam the slice is `a` or `b`. -/
theorem fwd_dichotomy {g : ℤ → ℤ × St} (hg : IsStepPath FA g) (t : ℤ) (ht : (g t).2 = a) :
    ∀ n : ℕ, (g (t + n)).2 = a ∨ (g (t + n)).2 = b := by
  intro n
  induction n with
  | zero => exact Or.inl (by simpa using ht)
  | succ i ih =>
    have h := (stepA hg (t + (i : ℕ))).2
    push_cast at h ih ⊢
    rw [show t + ((i : ℤ) + 1) = t + (i : ℤ) + 1 by ring]
    rcases h with h | h
    · rw [h]; exact ih
    · exact Or.inr h

/-- `b` absorbs. -/
theorem fwd_absorb {g : ℤ → ℤ × St} (hg : IsStepPath FA g) (z : ℤ) (h : (g z).2 = b) :
    (g (z + 1)).2 = b := by
  have h2 := (stepA hg z).2
  rcases h2 with h2 | h2
  · rw [h2, h]
  · exact h2

/-- **The seam's step paths, classified.** Every step path through `(t, a)` is the constant
`a`-path or an `a`-then-`b` jump path with jump time `w ≥ t`. This is the rigidity the rest of
the record rests on: the seam's splices form a one-parameter family indexed by `w ≥ t`, plus the
constant path, and nothing else. -/
theorem path_classify {g : ℤ → ℤ × St} (hg : IsStepPath FA g) (t : ℤ)
    (ht1 : (g t).1 = t) (ht2 : (g t).2 = a) :
    (∀ z, g z = (z, a)) ∨ ∃ w : ℤ, t ≤ w ∧ ∀ z, g z = (z, if w < z then b else a) := by
  have htime := time_eq hg t ht1
  have habs : ∀ (m : ℕ) (z : ℤ), (g z).2 = b → (g (z + m)).2 = b := by
    intro m
    induction m with
    | zero => intro z h; simpa using h
    | succ i ih =>
      intro z h
      have hstep := fwd_absorb hg (z + i) (ih z h)
      rwa [show z + ((i + 1 : ℕ) : ℤ) = z + (i : ℤ) + 1 by push_cast; ring]
  by_cases h : ∃ n : ℕ, (g (t + n)).2 = b
  · right
    classical
    set n0 : ℕ := Nat.find h with hn0
    have hspec : (g (t + (n0 : ℤ))).2 = b := Nat.find_spec h
    have hmin : ∀ m : ℕ, m < n0 → (g (t + (m : ℤ))).2 ≠ b := fun m hm => Nat.find_min h hm
    have hn0pos : 0 < n0 := by
      rcases Nat.eq_zero_or_pos n0 with h0 | h0
      · exfalso
        rw [h0] at hspec
        simp only [Nat.cast_zero, add_zero] at hspec
        exact ab_ne (ht2.symm.trans hspec)
      · exact h0
    refine ⟨t + (n0 : ℤ) - 1, by omega, ?_⟩
    intro z
    refine Prod.ext (htime z) ?_
    by_cases hz : t + (n0 : ℤ) - 1 < z
    · rw [if_pos hz]
      have := habs (z - (t + (n0 : ℤ))).toNat (t + (n0 : ℤ)) hspec
      rwa [show t + (n0 : ℤ) + ((z - (t + (n0 : ℤ))).toNat : ℤ) = z by omega] at this
    · rw [if_neg hz]
      by_cases hzt : z ≤ t
      · exact bwd_a hg t ht2 z hzt
      · have hlt : (z - t).toNat < n0 := by omega
        rcases fwd_dichotomy hg t ht2 (z - t).toNat with hc | hc
        · rwa [show t + (((z - t).toNat : ℕ) : ℤ) = z by omega] at hc
        · exact absurd (show (g (t + (((z - t).toNat : ℕ) : ℤ))).2 = b from hc) (hmin _ hlt)
  · left
    simp only [not_exists] at h
    intro z
    refine Prod.ext (htime z) ?_
    by_cases hzt : z ≤ t
    · exact bwd_a hg t ht2 z hzt
    · rcases fwd_dichotomy hg t ht2 (z - t).toNat with hc | hc
      · rwa [show t + (((z - t).toNat : ℕ) : ℤ) = z by omega] at hc
      · exact absurd hc (h _)

/-! ## From step paths to splices

`path_classify` classifies bare step paths; what the later phases consume is a classification of
the seam's SPLICES — the histories `spliced stayA t bf` obtained by gluing a backward and a forward
ω-sequence out of the seam state. The transport is `seamOmegaEquiv`'s `.symm`, whose `.2` field is
exactly the seam condition `σ.state t = stayA.state t`, plus `WorldHistory.ext_state` to lift the
state-wise equality that `path_classify` delivers to an equality of histories. -/

/-- **The seam's splices, identified as histories.** Every ray pair through the seam `(t, a)` of
`stayA` splices to `stayA` itself or to `jump w` for some `w ≥ t`. This is `path_classify` read
through `seamOmegaEquiv`: `WorldHistory.path` is `WorldHistory.state` by definition, so the
splice's path is a step path through `(t, a)`, and `WorldHistory.ext_state` turns the pointwise
classification into an equality of possible worlds. The seam's splice family is therefore the
one-parameter family `{jump w | w ≥ t}` together with `stayA`, and nothing else. -/
theorem splice_classify (t : ℤ) (bf : SeqPair FA (stayA.state t)) :
    spliced stayA t bf = stayA ∨ ∃ w : ℤ, t ≤ w ∧ spliced stayA t bf = jump w := by
  have hseam : (spliced stayA t bf).state t = stayA.state t :=
    ((seamOmegaEquiv t (stayA.state t)).symm bf).2
  have hpath : IsStepPath FA (spliced stayA t bf).path :=
    (spliced stayA t bf).isStepPath
  have hst : ∀ z, (spliced stayA t bf).path z = (spliced stayA t bf).state z := fun _ => rfl
  have ht1 : ((spliced stayA t bf).path t).1 = t := by
    rw [hst, hseam, stayA_state]
  have ht2 : ((spliced stayA t bf).path t).2 = a := by
    rw [hst, hseam, stayA_state]
  rcases path_classify hpath t ht1 ht2 with h | ⟨w, hw, h⟩
  · exact Or.inl (WorldHistory.ext_state fun z => by rw [← hst, h z, stayA_state])
  · exact Or.inr ⟨w, hw, WorldHistory.ext_state fun z => by rw [← hst, h z, jump_state]⟩

/-! ## The closure alphabet of `Fp`, enumerated

`Fp` is `someFuture (.atom pa)`, i.e. `untl ⊤ (atom p)` with `⊤ := ⊥ → ⊥`, so
`PlusFormula.subformulas Fp` is `[Fp, atom p, ⊤, ⊥, ⊥]` and its `toFinset` has FOUR members:

    #eval (plusSubformulaClosure Fp).card   -- 4

(re-derived at implementation time, not carried; the live `#eval` is kept at the foot of this
section so a reader can re-run it). `(clSig Fp).preds` is that four-member subtype plus the marker
`Unit`, so the alphabet has exactly FIVE letters, and `letter_cases` below is the exhaustion that
makes the read-out's case analysis demonstrably complete. -/

theorem cl_Fp : Fp ∈ plusSubformulaClosure Fp := by decide
theorem cl_p : PlusFormula.atom pa ∈ plusSubformulaClosure Fp := by decide
theorem cl_top : PlusFormula.top ∈ plusSubformulaClosure Fp := by decide
theorem cl_bot : PlusFormula.bot ∈ plusSubformulaClosure Fp := by decide

/-- **The alphabet, exhausted.** Every letter of `clSig Fp` is the marker `now` or one of the four
closure letters. The four-case read-out below is complete because of this. -/
theorem letter_cases (q : (clSig Fp).preds) :
    q = clNow Fp ∨ q = clLetter Fp cl_Fp ∨ q = clLetter Fp cl_p
      ∨ q = clLetter Fp cl_top ∨ q = clLetter Fp cl_bot := by
  rcases q with ⟨psi, hpsi⟩ | ⟨⟩
  · have : psi = Fp ∨ psi = PlusFormula.atom pa ∨ psi = PlusFormula.top
        ∨ psi = PlusFormula.bot := by
      simp only [List.mem_toFinset, Fp, someFuture, PlusFormula.top, PlusFormula.subformulas,
        List.mem_cons, List.mem_append, List.not_mem_nil, or_false] at hpsi ⊢
      tauto
    rcases this with rfl | rfl | rfl | rfl
    · exact Or.inr (Or.inl rfl)
    · exact Or.inr (Or.inr (Or.inl rfl))
    · exact Or.inr (Or.inr (Or.inr (Or.inl rfl)))
    · exact Or.inr (Or.inr (Or.inr (Or.inr rfl)))
  · exact Or.inl rfl

theorem now_ne_Fp : clNow Fp ≠ clLetter Fp cl_Fp := clNow_ne_clLetter Fp cl_Fp
theorem now_ne_p : clNow Fp ≠ clLetter Fp cl_p := clNow_ne_clLetter Fp cl_p
theorem now_ne_top : clNow Fp ≠ clLetter Fp cl_top := clNow_ne_clLetter Fp cl_top
theorem now_ne_bot : clNow Fp ≠ clLetter Fp cl_bot := clNow_ne_clLetter Fp cl_bot

theorem Fp_ne_p : clLetter Fp cl_Fp ≠ clLetter Fp cl_p := by
  simp only [ne_eq, clLetter_inj]; decide
theorem Fp_ne_top : clLetter Fp cl_Fp ≠ clLetter Fp cl_top := by
  simp only [ne_eq, clLetter_inj]; decide
theorem Fp_ne_bot : clLetter Fp cl_Fp ≠ clLetter Fp cl_bot := by
  simp only [ne_eq, clLetter_inj]; decide
theorem p_ne_top : clLetter Fp cl_p ≠ clLetter Fp cl_top := by
  simp only [ne_eq, clLetter_inj]; decide
theorem p_ne_bot : clLetter Fp cl_p ≠ clLetter Fp cl_bot := by
  simp only [ne_eq, clLetter_inj]; decide
theorem top_ne_bot : clLetter Fp cl_top ≠ clLetter Fp cl_bot := by
  simp only [ne_eq, clLetter_inj]; decide

/-! ## The closure-letter read-out on the two splice families

With `splice_classify` the seam has only two kinds of splice, and with `letter_cases` the alphabet
has only five letters, so `clTrace` on either family is settled letter by letter. Nothing here
evaluates a `kTypeOf` and nothing runs `decide` over `KType`: these are read-outs of `PlusTruthAt`
through `clTrace_letter`/`clTrace_now` only. -/

theorem stayA_p_false (z : ℤ) : ¬ PlusTruthAt MA stayA z (.atom pa) := by
  rw [p_iff, stayA_state]
  exact ab_ne

theorem stayA_Fp_false (z : ℤ) : ¬ PlusTruthAt MA stayA z Fp := by
  rw [Fp_iff]
  rintro ⟨s, _, hs⟩
  rw [stayA_state] at hs
  exact ab_ne hs

theorem clTrace_stayA_now (t z : ℤ) : clTrace MA Fp t stayA (clNow Fp) z ↔ z = t :=
  clTrace_now MA Fp t stayA z

theorem clTrace_stayA_Fp (t z : ℤ) : ¬ clTrace MA Fp t stayA (clLetter Fp cl_Fp) z :=
  fun h => stayA_Fp_false z ((clTrace_letter MA Fp t stayA cl_Fp z).mp h)

theorem clTrace_stayA_p (t z : ℤ) : ¬ clTrace MA Fp t stayA (clLetter Fp cl_p) z :=
  fun h => stayA_p_false z ((clTrace_letter MA Fp t stayA cl_p z).mp h)

theorem clTrace_stayA_top (t z : ℤ) : clTrace MA Fp t stayA (clLetter Fp cl_top) z :=
  (clTrace_letter MA Fp t stayA cl_top z).mpr (PlusTruth.top_true MA stayA z)

theorem clTrace_stayA_bot (t z : ℤ) : ¬ clTrace MA Fp t stayA (clLetter Fp cl_bot) z :=
  fun h => PlusTruth.bot_false MA stayA z ((clTrace_letter MA Fp t stayA cl_bot z).mp h)

theorem clTrace_jump_now (w t z : ℤ) : clTrace MA Fp t (jump w) (clNow Fp) z ↔ z = t :=
  clTrace_now MA Fp t (jump w) z

theorem clTrace_jump_Fp (w t z : ℤ) : clTrace MA Fp t (jump w) (clLetter Fp cl_Fp) z :=
  (clTrace_letter MA Fp t (jump w) cl_Fp z).mpr (jump_Fp w z)

theorem clTrace_jump_p (w t z : ℤ) :
    clTrace MA Fp t (jump w) (clLetter Fp cl_p) z ↔ w < z :=
  (clTrace_letter MA Fp t (jump w) cl_p z).trans (jump_p_iff w z)

theorem clTrace_jump_top (w t z : ℤ) : clTrace MA Fp t (jump w) (clLetter Fp cl_top) z :=
  (clTrace_letter MA Fp t (jump w) cl_top z).mpr (PlusTruth.top_true MA (jump w) z)

theorem clTrace_jump_bot (w t z : ℤ) : ¬ clTrace MA Fp t (jump w) (clLetter Fp cl_bot) z :=
  fun h => PlusTruth.bot_false MA (jump w) z ((clTrace_letter MA Fp t (jump w) cl_bot z).mp h)

/-- **The read-out on `stayA`, assembled.** `stayA` never reaches `b`, so both `p` and `Fp` are
false along it everywhere: only the marker (at `t`) and `⊤` (everywhere) hold. -/
theorem clTrace_stayA_apply (t : ℤ) (q : (clSig Fp).preds) (z : ℤ) :
    clTrace MA Fp t stayA q z ↔ (q = clNow Fp ∧ z = t) ∨ q = clLetter Fp cl_top := by
  constructor
  · intro h
    rcases letter_cases q with rfl | rfl | rfl | rfl | rfl
    · exact Or.inl ⟨rfl, (clTrace_stayA_now t z).mp h⟩
    · exact absurd h (clTrace_stayA_Fp t z)
    · exact absurd h (clTrace_stayA_p t z)
    · exact Or.inr rfl
    · exact absurd h (clTrace_stayA_bot t z)
  · rintro (⟨rfl, hz⟩ | rfl)
    · exact (clTrace_stayA_now t z).mpr hz
    · exact clTrace_stayA_top t z

/-- **The read-out on `jump w`, assembled.** `jump w` is at `b` from `w + 1` on, so `p` holds
exactly after `w` and `Fp` holds everywhere (`b` is absorbing, so a later `b` always exists). The
only `w`-dependence in the whole trace is the `p` letter's threshold — which is what makes
distinct `w` give distinct traces, and what the later phases' presentation has to reproduce. -/
theorem clTrace_jump_apply (w t : ℤ) (q : (clSig Fp).preds) (z : ℤ) :
    clTrace MA Fp t (jump w) q z ↔
      (q = clNow Fp ∧ z = t) ∨ q = clLetter Fp cl_top ∨ q = clLetter Fp cl_Fp
        ∨ (q = clLetter Fp cl_p ∧ w < z) := by
  constructor
  · intro h
    rcases letter_cases q with rfl | rfl | rfl | rfl | rfl
    · exact Or.inl ⟨rfl, (clTrace_jump_now w t z).mp h⟩
    · exact Or.inr (Or.inr (Or.inl rfl))
    · exact Or.inr (Or.inr (Or.inr ⟨rfl, (clTrace_jump_p w t z).mp h⟩))
    · exact Or.inr (Or.inl rfl)
    · exact absurd h (clTrace_jump_bot w t z)
  · rintro (⟨rfl, hz⟩ | rfl | rfl | ⟨rfl, hz⟩)
    · exact (clTrace_jump_now w t z).mpr hz
    · exact clTrace_jump_top w t z
    · exact clTrace_jump_Fp w t z
    · exact (clTrace_jump_p w t z).mpr hz

/-- The function-level form: trace equality against `stayA` is now a rewrite. -/
theorem clTrace_stayA_eq (t : ℤ) :
    clTrace MA Fp t stayA = fun q z => (q = clNow Fp ∧ z = t) ∨ q = clLetter Fp cl_top := by
  funext q z
  exact propext (clTrace_stayA_apply t q z)

/-- The function-level form: trace equality against `jump w` is now a rewrite. -/
theorem clTrace_jump_eq (w t : ℤ) :
    clTrace MA Fp t (jump w)
      = fun q z => (q = clNow Fp ∧ z = t) ∨ q = clLetter Fp cl_top ∨ q = clLetter Fp cl_Fp
          ∨ (q = clLetter Fp cl_p ∧ w < z) := by
  funext q z
  exact propext (clTrace_jump_apply w t q z)

/-! ## The truncation bound

`hitCl_eq_iUnion` presents `HitCl` as a union over the seam's ray pairs — an INFINITE index, since
`SeqPair FA (stayA.state t)` is not finite. `splice_classify` collapses that index to the
one-parameter family `{jump w | w ≥ t}` together with `stayA`, which is still infinite. The
truncation below replaces it by a FINITE index: `stayA` together with the finitely many `jump w`
for `t ≤ w ≤ t + L`.

**Where the non-constructivity enters, named exactly.** `L` is produced by `Set.Finite.bddAbove`
applied to the image, under a `choose!`-extracted offset function, of the set
`HitCl MA stayA t Fp k` — finite by `hitCl_finite`, which is `hitSig_finite`, which rests on
`finite_family_triples` and `kType_finite`. Two separate uses of choice sit in that sentence:
`choose!` picks a witnessing ray pair (hence, through `splice_classify`, a jump time) for each
member, and `Set.Finite.bddAbove` asserts only that SOME upper bound of the resulting offsets
exists. Neither exhibits anything. So NO computable bound follows from this proof — not a bad
one, not a non-elementary one, and not even on this fixture, where the model is three states on
`Fin 3`. That is why the statement carries an `∃ L` prefix rather than a supplied `L`: a version
with a computed or exhibited `L` would be a strictly STRONGER theorem, and this record does not
establish it. The in-tree entry point for an effective bound is `kTypeOf_listSeg_append_congr`;
the eventual-periodicity/threshold consequence that would convert this route from
non-constructive to effective is not in this tree, and is recorded as the successor obligation
rather than assumed, cited or `sorry`-ed here.

Nothing in this section evaluates a `kTypeOf`, runs `decide` over `KType`, or attempts to make
`L` computable. -/

/-- Every `jump w` with `w ≥ t` passes through the seam `(t, a)` of `stayA`: at `t` itself the
jump has not yet happened, so the state is `a`. -/
theorem jump_seam {w t : ℤ} (hw : t ≤ w) : (jump w).state t = stayA.state t := by
  rw [jump_state, stayA_state, if_neg (by omega : ¬ w < t)]

/-- **Converse of `splice_classify`**: every history through the seam IS the splice of some ray
pair. This is `seamOmegaEquiv`'s `symm_apply_apply` and nothing more; it is what makes the `⊇`
direction of the truncation immediate, since `stayA` and every `jump w` with `w ≥ t` are then
genuine splices rather than merely candidates. -/
theorem exists_splice_eq (t : ℤ) (σ : WorldHistory FA.toTaskFrame)
    (h : σ.state t = stayA.state t) :
    ∃ bf : SeqPair FA (stayA.state t), spliced stayA t bf = σ := by
  refine ⟨seamOmegaEquiv t (stayA.state t) ⟨σ, h⟩, ?_⟩
  exact congrArg Subtype.val
    ((seamOmegaEquiv t (stayA.state t)).symm_apply_apply ⟨σ, h⟩)

/-- The seam's realized family triples, covered by offsets: every member of `HitCl` already lies
in the family triples of `stayA`'s trace or of `jump (t + n)`'s trace for some natural `n`. This
is `hitCl_eq_iUnion` followed by `splice_classify`, with the jump time re-expressed as a natural
offset from `t` (possible because `splice_classify` delivers `t ≤ w`). -/
theorem hitCl_covered (t : ℤ) (k : ℕ) :
    ∀ x ∈ HitCl MA stayA t Fp k,
      ∃ n : ℕ, x ∈ familyTriples (clSig Fp) k (clTrace MA Fp t stayA)
        ∨ x ∈ familyTriples (clSig Fp) k (clTrace MA Fp t (jump (t + (n : ℤ)))) := by
  intro x hx
  rw [hitCl_eq_iUnion] at hx
  obtain ⟨bf, hbf⟩ := Set.mem_iUnion.mp hx
  rcases splice_classify t bf with h | ⟨w, hw, h⟩
  · exact ⟨0, Or.inl (by rwa [h] at hbf)⟩
  · refine ⟨(w - t).toNat, Or.inr ?_⟩
    rw [show t + (((w - t).toNat : ℕ) : ℤ) = w by omega]
    rwa [h] at hbf

set_option linter.unusedVariables false in
/-- **The truncation bound.** `HitCl` at the seam `(t, a)` of `stayA` is exactly the family
triples of `stayA`'s closure trace together with those of finitely many `jump w`.

The `∃ L` is essential and is the recorded result: `L` comes from `Set.Finite.bddAbove` on the
image of a `choose!`-extracted offset function over the finite set `HitCl MA stayA t Fp k`, so it
is never exhibited and NO computable bound follows. See this section's header for the two places
choice enters.

`hk` is carried because it is part of this record's pinned Challenge signature and because
`HitPresented` needs it downstream; the truncation argument itself does not use it, since
`HitCl` is defined at every depth. The linter suppression above is scoped to this one
declaration and exists only so the pinned signature can be reproduced verbatim rather than
renamed to `_hk`. -/
theorem hitCl_eq_truncated (t : ℤ) (k : ℕ) (hk : 1 ≤ k) :
    ∃ L : ℕ, HitCl MA stayA t Fp k
      = familyTriples (clSig Fp) k (clTrace MA Fp t stayA)
        ∪ ⋃ w ∈ Set.Icc t (t + (L : ℤ)),
            familyTriples (clSig Fp) k (clTrace MA Fp t (jump w)) := by
  classical
  -- One witnessing offset per member, by choice; `choose!` makes the function total.
  choose! off hoff using hitCl_covered t k
  -- The offsets of the FINITELY many members are bounded above -- `Set.Finite.bddAbove` is where
  -- the second (and fatal, for any bound) use of choice sits: it exhibits no `L`.
  obtain ⟨L, hL⟩ := ((hitCl_finite MA stayA t Fp k).image off).bddAbove
  refine ⟨L, Set.Subset.antisymm ?_ ?_⟩
  · intro x hx
    have hxL : off x ≤ L := hL ⟨x, hx, rfl⟩
    rcases hoff x hx with h | h
    · exact Or.inl h
    · refine Or.inr (Set.mem_iUnion₂.mpr ⟨t + (off x : ℤ), ⟨by omega, by omega⟩, h⟩)
  · rintro x (h | h)
    · obtain ⟨bf, hbf⟩ := exists_splice_eq t stayA rfl
      exact (hitCl_eq_iUnion MA stayA t Fp k).symm ▸ Set.mem_iUnion.mpr ⟨bf, by rw [hbf]; exact h⟩
    · obtain ⟨w, hw, hx⟩ := Set.mem_iUnion₂.mp h
      obtain ⟨bf, hbf⟩ := exists_splice_eq t (jump w) (jump_seam hw.1)
      exact (hitCl_eq_iUnion MA stayA t Fp k).symm ▸ Set.mem_iUnion.mpr ⟨bf, by rw [hbf]; exact hx⟩

/-! ## The presentation data

The presentation is TWO DISJOINT GADGETS over one state type, one gadget per trace shape the
truncation bound left standing:

* **Gadget 1** (`Fin 3`, embedded by `Sum.inl`) carries the `stayA` trace. `0 = s_pre` (before
  the seam), `1 = s_now` (the seam), `2 = s_post` (after it). Nothing in gadget 1 ever reads `p`
  or `Fp` -- which is exactly `clTrace_stayA_apply`, where only the marker (at `t`) and `⊤`
  (everywhere) hold.
* **Gadget 2** (`Fin (L + 3)`, embedded by `Sum.inr`) carries the `jump w` traces for
  `t ≤ w ≤ t + L`. `0 = j_pre`, `1 = j_now`, `2 … L+1 = j_mid_1 … j_mid_L` (one mid state per
  unit of delay between the seam and the jump), `L+2 = j_post`, the only state reading `p`. `Fp`
  is read EVERYWHERE in gadget 2 -- which is exactly `clTrace_jump_apply`: `b` absorbs, so from
  any point of a `jump` history a later `b` exists. The `L` mid states are what let the ONE
  gadget cover all `L + 1` thresholds `w ∈ [t, t + L]`: the run dwells `w - t` steps on the mid
  chain before falling into `j_post`.

No `stepOf` edge crosses the summands (`stepOf_no_cross`), so a run lives entirely inside one
gadget -- the exclusion Phase 6's run characterization turns on. Both `stepOf` and `labOf` are
`def`, never `noncomputable def`: `HitPresented` is a proposition ABOUT `hitOf lab step`, and
`hitOf` is a `Finset`, so the presentation data has to compute.

`labOf` is an explicit flag table, NOT `decide` of `clTrace`: the table's five branches are read
directly against `letter_cases`, which keeps the axiom foot free of the semantics and makes the
bridge below a case split rather than a re-derivation.

**The alphabet figure, re-derived and not carried.** `(plusSubformulaClosure Fp).card = 4` was
re-run at implementation time and is recorded as the `#guard` below (a `#guard` failure is a
compile error, so this is checked on every compile, unlike the bare `#eval` left at the foot).
Table completeness does not actually rest on that figure, though: `letter_cases` is the
machine-checked exhaustion of `(clSig Fp).preds`, and the table has exactly one branch per its
five cases. -/

#guard (plusSubformulaClosure Fp).card = 4

/-- The presentation's state type: gadget 1 (`Fin 3`) for `stayA`, gadget 2 (`Fin (L + 3)`) for
the `jump w` with `t ≤ w ≤ t + L`. `Fintype` and `DecidableEq` come from the `Sum` and `Fin`
instances; nothing here is hand-rolled. -/
abbrev QA (L : ℕ) := Fin 3 ⊕ Fin (L + 3)

/-- The state count. `L + 6` is NOT a bound: `L` is the unexhibited witness of
`hitCl_eq_truncated`, so this is a function of something never produced. -/
theorem card_QA (L : ℕ) : Fintype.card (QA L) = L + 6 := by
  rw [Fintype.card_sum, Fintype.card_fin, Fintype.card_fin]
  omega

#guard Fintype.card (QA 2) = 8

/-! ### The step relation -/

/-- The step relation: two gadgets, no edge between them.

Gadget 1: `s_pre → s_pre`, `s_pre → s_now`, `s_now → s_post`, `s_post → s_post`.

Gadget 2: `j_pre → j_pre`, `j_pre → j_now`, then from any of `j_now … j_mid_L` either one step
further along the mid chain or straight to `j_post`, and `j_post → j_post`. -/
def stepOf (L : ℕ) : QA L → QA L → Bool
  | .inl i, .inl j =>
      decide ((i.val = 0 ∧ j.val = 0) ∨ (i.val = 0 ∧ j.val = 1) ∨ (i.val = 1 ∧ j.val = 2)
        ∨ (i.val = 2 ∧ j.val = 2))
  | .inr i, .inr j =>
      decide ((i.val = 0 ∧ j.val = 0) ∨ (i.val = 0 ∧ j.val = 1)
        ∨ (1 ≤ i.val ∧ i.val ≤ L + 1 ∧ j.val = i.val + 1)
        ∨ (1 ≤ i.val ∧ i.val ≤ L + 1 ∧ j.val = L + 2)
        ∨ (i.val = L + 2 ∧ j.val = L + 2))
  | _, _ => false

@[simp] theorem stepOf_inl_inr (L : ℕ) (i : Fin 3) (j : Fin (L + 3)) :
    stepOf L (Sum.inl i) (Sum.inr j) = false := rfl

@[simp] theorem stepOf_inr_inl (L : ℕ) (i : Fin (L + 3)) (j : Fin 3) :
    stepOf L (Sum.inr i) (Sum.inl j) = false := rfl

/-- **No step crosses the two gadgets.** A `stepOf` edge has both endpoints in gadget 1 or both
in gadget 2. Phase 6's cross-gadget exclusion is this lemma, and nothing else. -/
theorem stepOf_no_cross (L : ℕ) (q r : QA L) (h : stepOf L q r = true) :
    (∃ i j : Fin 3, q = Sum.inl i ∧ r = Sum.inl j)
      ∨ (∃ i j : Fin (L + 3), q = Sum.inr i ∧ r = Sum.inr j) := by
  rcases q with i | i
  · rcases r with j | j
    · exact Or.inl ⟨i, j, rfl, rfl⟩
    · simp at h
  · rcases r with j | j
    · simp at h
    · exact Or.inr ⟨i, j, rfl, rfl⟩

/-- Gadget 1's step table, as an `↔` on the index values. -/
theorem stepOf_inl_inl_iff (L : ℕ) (i j : Fin 3) :
    stepOf L (Sum.inl i) (Sum.inl j) = true ↔
      ((i.val = 0 ∧ j.val = 0) ∨ (i.val = 0 ∧ j.val = 1) ∨ (i.val = 1 ∧ j.val = 2)
        ∨ (i.val = 2 ∧ j.val = 2)) := by
  simp only [stepOf, decide_eq_true_eq]

/-- Gadget 2's step table, as an `↔` on the index values. -/
theorem stepOf_inr_inr_iff (L : ℕ) (i j : Fin (L + 3)) :
    stepOf L (Sum.inr i) (Sum.inr j) = true ↔
      ((i.val = 0 ∧ j.val = 0) ∨ (i.val = 0 ∧ j.val = 1)
        ∨ (1 ≤ i.val ∧ i.val ≤ L + 1 ∧ j.val = i.val + 1)
        ∨ (1 ≤ i.val ∧ i.val ≤ L + 1 ∧ j.val = L + 2)
        ∨ (i.val = L + 2 ∧ j.val = L + 2)) := by
  simp only [stepOf, decide_eq_true_eq]

/-! ### The flag table -/

/-- The `now` marker is read at the seam state of each gadget, and nowhere else. -/
def isNowState (L : ℕ) : QA L → Bool
  | .inl i => decide (i.val = 1)
  | .inr i => decide (i.val = 1)

/-- The `Fp` letter is read throughout gadget 2 and nowhere in gadget 1. -/
def isJumpState (L : ℕ) : QA L → Bool
  | .inl _ => false
  | .inr _ => true

/-- The `p` letter is read at `j_post` only. -/
def isPostState (L : ℕ) : QA L → Bool
  | .inl _ => false
  | .inr i => decide (i.val = L + 2)

/-- **The flag table** over the five letters of `clSig Fp`, written out branch by branch rather
than as `decide` of `clTrace`: `now` at the two seam states, `⊤` everywhere, `⊥` nowhere, `Fp`
throughout gadget 2, `p` at `j_post`. -/
def labOf (L : ℕ) : QA L → (clSig Fp).preds → Bool := fun q ℓ =>
  if ℓ = clNow Fp then isNowState L q
  else if ℓ = clLetter Fp cl_top then true
  else if ℓ = clLetter Fp cl_Fp then isJumpState L q
  else if ℓ = clLetter Fp cl_p then isPostState L q
  else false

/-! The Phase 3 letter disequalities, in the direction `labOf`'s `if`-chain resolves them. -/

theorem top_ne_now : clLetter Fp cl_top ≠ clNow Fp := now_ne_top.symm
theorem Fp_ne_now : clLetter Fp cl_Fp ≠ clNow Fp := now_ne_Fp.symm
theorem p_ne_now : clLetter Fp cl_p ≠ clNow Fp := now_ne_p.symm
theorem bot_ne_now : clLetter Fp cl_bot ≠ clNow Fp := now_ne_bot.symm
theorem top_ne_Fp : clLetter Fp cl_top ≠ clLetter Fp cl_Fp := Fp_ne_top.symm
theorem p_ne_Fp : clLetter Fp cl_p ≠ clLetter Fp cl_Fp := Fp_ne_p.symm
theorem bot_ne_Fp : clLetter Fp cl_bot ≠ clLetter Fp cl_Fp := Fp_ne_bot.symm
theorem bot_ne_top : clLetter Fp cl_bot ≠ clLetter Fp cl_top := top_ne_bot.symm
theorem bot_ne_p : clLetter Fp cl_bot ≠ clLetter Fp cl_p := p_ne_bot.symm

@[simp] theorem labOf_now (L : ℕ) (q : QA L) : labOf L q (clNow Fp) = isNowState L q := by
  simp [labOf]

@[simp] theorem labOf_top (L : ℕ) (q : QA L) : labOf L q (clLetter Fp cl_top) = true := by
  simp [labOf, top_ne_now]

@[simp] theorem labOf_Fp (L : ℕ) (q : QA L) : labOf L q (clLetter Fp cl_Fp) = isJumpState L q := by
  simp [labOf, Fp_ne_now, Fp_ne_top]

@[simp] theorem labOf_p (L : ℕ) (q : QA L) : labOf L q (clLetter Fp cl_p) = isPostState L q := by
  simp [labOf, p_ne_now, p_ne_top, p_ne_Fp]

@[simp] theorem labOf_bot (L : ℕ) (q : QA L) : labOf L q (clLetter Fp cl_bot) = false := by
  simp [labOf, bot_ne_now, bot_ne_top, bot_ne_Fp, bot_ne_p]

/-- **Gadget 1's flags, assembled.** Set this beside `clTrace_stayA_apply`: the same two
disjuncts, with `z = t` replaced by `i = s_now`. -/
theorem labOf_inl (L : ℕ) (i : Fin 3) (ℓ : (clSig Fp).preds) :
    labOf L (Sum.inl i) ℓ = true ↔ (ℓ = clNow Fp ∧ i.val = 1) ∨ ℓ = clLetter Fp cl_top := by
  rcases letter_cases ℓ with rfl | rfl | rfl | rfl | rfl
  · simp [isNowState, now_ne_top]
  · simp [isJumpState, Fp_ne_now, Fp_ne_top]
  · simp [isPostState, p_ne_now, p_ne_top]
  · simp
  · simp [bot_ne_now, bot_ne_top]

/-- **Gadget 2's flags, assembled.** Set this beside `clTrace_jump_apply`: the same four
disjuncts, with `z = t` replaced by `i = j_now` and `w < z` by `i = j_post`. -/
theorem labOf_inr (L : ℕ) (i : Fin (L + 3)) (ℓ : (clSig Fp).preds) :
    labOf L (Sum.inr i) ℓ = true ↔ (ℓ = clNow Fp ∧ i.val = 1) ∨ ℓ = clLetter Fp cl_top
      ∨ ℓ = clLetter Fp cl_Fp ∨ (ℓ = clLetter Fp cl_p ∧ i.val = L + 2) := by
  rcases letter_cases ℓ with rfl | rfl | rfl | rfl | rfl
  · simp [isNowState, now_ne_top, now_ne_Fp, now_ne_p]
  · simp [isJumpState]
  · simp [isPostState, p_ne_now, p_ne_top, p_ne_Fp]
  · simp
  · simp [bot_ne_now, bot_ne_top, bot_ne_Fp, bot_ne_p]

/-! ### The labelling bridge

The two lemmas below are the phase's point: they turn Phase 6's run-trace comparison into a
rewrite. Each says that a state of one gadget reads EXACTLY the closure letters that the
corresponding history reads at the corresponding time, under the only two correspondences the
gadget has: `j_now` ↔ the seam `z = t`, and `j_post` ↔ past the jump, `w < z`. -/

/-- **The labelling bridge, gadget 1.** A gadget-1 state sitting at `s_now` exactly when
`z = t` reads the same letters as `stayA` at `z`. -/
theorem labOf_inl_iff_clTrace_stayA (L : ℕ) (t z : ℤ) (i : Fin 3) (hnow : i.val = 1 ↔ z = t)
    (ℓ : (clSig Fp).preds) :
    labOf L (Sum.inl i) ℓ = true ↔ clTrace MA Fp t stayA ℓ z := by
  rw [labOf_inl, clTrace_stayA_apply]
  constructor
  · rintro (⟨hl, hi⟩ | hl)
    · exact Or.inl ⟨hl, hnow.mp hi⟩
    · exact Or.inr hl
  · rintro (⟨hl, hz⟩ | hl)
    · exact Or.inl ⟨hl, hnow.mpr hz⟩
    · exact Or.inr hl

/-- **The labelling bridge, gadget 2.** A gadget-2 state sitting at `j_now` exactly when `z = t`
and at `j_post` exactly when `w < z` reads the same letters as `jump w` at `z`. -/
theorem labOf_inr_iff_clTrace_jump (L : ℕ) (t w z : ℤ) (i : Fin (L + 3))
    (hnow : i.val = 1 ↔ z = t) (hp : i.val = L + 2 ↔ w < z) (ℓ : (clSig Fp).preds) :
    labOf L (Sum.inr i) ℓ = true ↔ clTrace MA Fp t (jump w) ℓ z := by
  rw [labOf_inr, clTrace_jump_apply]
  constructor
  · rintro (⟨hl, hi⟩ | hl | hl | ⟨hl, hi⟩)
    · exact Or.inl ⟨hl, hnow.mp hi⟩
    · exact Or.inr (Or.inl hl)
    · exact Or.inr (Or.inr (Or.inl hl))
    · exact Or.inr (Or.inr (Or.inr ⟨hl, hp.mp hi⟩))
  · rintro (⟨hl, hz⟩ | hl | hl | ⟨hl, hz⟩)
    · exact Or.inl ⟨hl, hnow.mpr hz⟩
    · exact Or.inr (Or.inl hl)
    · exact Or.inr (Or.inr (Or.inl hl))
    · exact Or.inr (Or.inr (Or.inr ⟨hl, hp.mpr hz⟩))

/-- The function-level form of the gadget-1 bridge: trace equality against `stayA` is a rewrite,
given only the seam correspondence. -/
theorem runTrace_inl_eq (L : ℕ) (t : ℤ) (ρ : ℤ → Fin 3) (hnow : ∀ z, (ρ z).val = 1 ↔ z = t) :
    runTrace (labOf L) (fun z => Sum.inl (ρ z)) = clTrace MA Fp t stayA := by
  funext ℓ z
  exact propext (labOf_inl_iff_clTrace_stayA L t z (ρ z) (hnow z) ℓ)

/-- The function-level form of the gadget-2 bridge: trace equality against `jump w` is a
rewrite, given the seam and threshold correspondences. -/
theorem runTrace_inr_eq (L : ℕ) (t w : ℤ) (ρ : ℤ → Fin (L + 3))
    (hnow : ∀ z, (ρ z).val = 1 ↔ z = t) (hp : ∀ z, (ρ z).val = L + 2 ↔ w < z) :
    runTrace (labOf L) (fun z => Sum.inr (ρ z)) = clTrace MA Fp t (jump w) := by
  funext ℓ z
  exact propext (labOf_inr_iff_clTrace_jump L t w z (ρ z) (hnow z) (hp z) ℓ)


/-! ## The run characterization

The presentation's anchored runs trace EXACTLY the truncated family — `stayA` together with the
`jump w` for `t ≤ w ≤ t + L`, and nothing else. This is the step the research left uncompiled and
the one the whole result turns on: `hitCl_eq_truncated` says the seam's realized triples come from
that family, `mem_hitOf_iff` says `hitOf (labOf L) (stepOf L) (clNow Fp) k` collects the family
triples of the presentation's RUN traces, and the two sides meet only if the run traces are the
same family.

**The three excluded run shapes, each discharged by its own named lemma rather than by prose.**
A run that never leaves a `pre` state (`no_run_const_pre`: `IsRun`'s second clause forces the
marker at `z = t`, so no constant non-`now` run exists); a run that crosses the two gadgets
(`isLeft_const_of_isRun`, which is Phase 5's `stepOf_no_cross` and nothing else); a run that loops
inside gadget 2's mid chain (`inr_no_back_edge`: from a mid state the index strictly increases,
and `j_post` is the only self-loop reachable from a mid state).

**What the trace comparison actually consumes, stated honestly.** Phase 5 built `labOf` so that
gadget 1 reads only `isNowState` and gadget 2 reads only `isNowState` and `isPostState`. So the
trace equalities need exactly two correspondences — `j_now ↔ z = t` (which is `IsRun`'s own second
clause, free) and `j_post ↔ w < z` (which is `inr_post_threshold`) — and the gadget-1 rigidity
lemmas below (`inl_bwd_pre`, `inl_fwd_post`, `inl_run_pinned`) are NOT consumed by it. They are
landed because they are the plan's route and because they are the record that the presentation
admits no spurious gadget-1 run: without them "the gadget-1 run traces `stayA`" would be true of
a presentation that also admitted runs nobody classified. `inr_bwd_pre` IS consumed, by
`inr_post_threshold`'s `z ≤ t` case. -/

/-- **Counterexample 1 discharged.** A run cannot sit forever at a state that does not read the
`now` marker — in particular not at `s_pre` and not at `j_pre`. `IsRun`'s second clause forces the
marker at `z = t`, and that is the whole argument. -/
theorem no_run_const_pre (L : ℕ) (t : ℤ) (ρ : ℤ → QA L)
    (hρ : IsRun (labOf L) (stepOf L) (clNow Fp) t ρ) (q : QA L)
    (hq : isNowState L q = false) (hconst : ∀ z, ρ z = q) : False := by
  have h := (hρ.2 t).mpr rfl
  rw [hconst t, labOf_now, hq] at h
  simp at h

/-- **Counterexample 2 discharged.** No run crosses the two gadgets: `stepOf_no_cross` makes
`Sum.isLeft` constant along a `step`-chain, so a run lives entirely in gadget 1 or entirely in
gadget 2. -/
theorem isLeft_const_of_isRun (L : ℕ) {ρ : ℤ → QA L}
    (hstep : ∀ z, stepOf L (ρ z) (ρ (z + 1)) = true) (t : ℤ) :
    ∀ z, (ρ z).isLeft = (ρ t).isLeft := by
  have one : ∀ z : ℤ, (ρ (z + 1)).isLeft = (ρ z).isLeft := by
    intro z
    rcases stepOf_no_cross L (ρ z) (ρ (z + 1)) (hstep z) with ⟨i, j, h1, h2⟩ | ⟨i, j, h1, h2⟩
    · rw [h1, h2]; rfl
    · rw [h1, h2]; rfl
  have key : ∀ n : ℤ, (ρ (t + n)).isLeft = (ρ t).isLeft := by
    intro n
    induction n using Int.induction_on with
    | zero => simp
    | succ i ih =>
        rw [show t + ((i : ℤ) + 1) = t + (i : ℤ) + 1 by ring, one, ih]
    | pred i ih =>
        have h := one (t + (-(i : ℤ) - 1))
        rw [show t + (-(i : ℤ) - 1) + 1 = t + -(i : ℤ) by ring] at h
        exact h.symm.trans ih
  intro z
  have := key (z - t)
  rwa [show t + (z - t) = z by ring] at this

/-- **Counterexample 3 discharged.** Gadget 2 has no back edges: from a mid state (`1 ≤ i`) the
index strictly increases, unless the state is already `j_post`, which self-loops. So no run loops
inside the mid chain, and the forward walk from `j_now` is bounded. -/
theorem inr_no_back_edge (L : ℕ) (i j : Fin (L + 3))
    (h : stepOf L (Sum.inr i) (Sum.inr j) = true) (hi : 1 ≤ i.val) :
    i.val < j.val ∨ (i.val = L + 2 ∧ j.val = L + 2) := by
  have h1 := (stepOf_inr_inr_iff L i j).mp h
  omega

/-! ### Confining a run to one gadget -/

/-- A run confined to gadget 1 is the `Sum.inl` of an index function. -/
theorem exists_left_index (L : ℕ) (ρ : ℤ → QA L) (h : ∀ z, (ρ z).isLeft = true) :
    ∃ σ : ℤ → Fin 3, ∀ z, ρ z = Sum.inl (σ z) := by
  refine ⟨fun z => Sum.elim id (fun _ => 0) (ρ z), fun z => ?_⟩
  show ρ z = Sum.inl (Sum.elim id (fun _ => 0) (ρ z))
  rcases hz : ρ z with i | i
  · simp
  · have hi := h z; rw [hz] at hi; simp at hi

/-- A run confined to gadget 2 is the `Sum.inr` of an index function. -/
theorem exists_right_index (L : ℕ) (ρ : ℤ → QA L) (h : ∀ z, (ρ z).isLeft = false) :
    ∃ σ : ℤ → Fin (L + 3), ∀ z, ρ z = Sum.inr (σ z) := by
  refine ⟨fun z => Sum.elim (fun _ => 0) id (ρ z), fun z => ?_⟩
  show ρ z = Sum.inr (Sum.elim (fun _ => 0) id (ρ z))
  rcases hz : ρ z with i | i
  · have hi := h z; rw [hz] at hi; simp at hi
  · simp

/-! ### Gadget 1: the run is rigid -/

/-- **Gadget 1, backward from the seam.** The only `stepOf` predecessor of `s_now` is `s_pre`, and
`s_pre`'s only predecessor is itself, so a gadget-1 run is constant at `s_pre` strictly before the
seam. -/
theorem inl_bwd_pre (L : ℕ) {σ : ℤ → Fin 3}
    (hstep : ∀ z, stepOf L (Sum.inl (σ z)) (Sum.inl (σ (z + 1))) = true)
    {t : ℤ} (ht : (σ t).val = 1) : ∀ z, z < t → (σ z).val = 0 := by
  have key : ∀ n : ℕ, (σ (t - 1 - (n : ℤ))).val = 0 := by
    intro n
    induction n with
    | zero =>
        simp only [Nat.cast_zero, sub_zero]
        have h := (stepOf_inl_inl_iff L (σ (t - 1)) (σ (t - 1 + 1))).mp (hstep (t - 1))
        rw [show t - 1 + 1 = t by ring] at h
        omega
    | succ m ih =>
        rw [show t - 1 - (((m + 1 : ℕ) : ℤ)) = t - 1 - ((m : ℕ) : ℤ) - 1 by push_cast; ring]
        have h := (stepOf_inl_inl_iff L (σ (t - 1 - ((m : ℕ) : ℤ) - 1))
          (σ (t - 1 - ((m : ℕ) : ℤ) - 1 + 1))).mp (hstep (t - 1 - ((m : ℕ) : ℤ) - 1))
        rw [show t - 1 - ((m : ℕ) : ℤ) - 1 + 1 = t - 1 - ((m : ℕ) : ℤ) by ring] at h
        omega
  intro z hz
  have := key (t - 1 - z).toNat
  rwa [show t - 1 - (((t - 1 - z).toNat : ℕ) : ℤ) = z by omega] at this

/-- **Gadget 1, forward from the seam.** `s_now`'s only continuation is `s_post`, and `s_post`
absorbs, so a gadget-1 run is constant at `s_post` strictly after the seam. -/
theorem inl_fwd_post (L : ℕ) {σ : ℤ → Fin 3}
    (hstep : ∀ z, stepOf L (Sum.inl (σ z)) (Sum.inl (σ (z + 1))) = true)
    {t : ℤ} (ht : (σ t).val = 1) : ∀ z, t < z → (σ z).val = 2 := by
  have key : ∀ n : ℕ, (σ (t + 1 + (n : ℤ))).val = 2 := by
    intro n
    induction n with
    | zero =>
        simp only [Nat.cast_zero, add_zero]
        have h := (stepOf_inl_inl_iff L (σ t) (σ (t + 1))).mp (hstep t)
        omega
    | succ m ih =>
        rw [show t + 1 + (((m + 1 : ℕ) : ℤ)) = t + 1 + ((m : ℕ) : ℤ) + 1 by push_cast; ring]
        have h := (stepOf_inl_inl_iff L (σ (t + 1 + ((m : ℕ) : ℤ)))
          (σ (t + 1 + ((m : ℕ) : ℤ) + 1))).mp (hstep (t + 1 + ((m : ℕ) : ℤ)))
        omega
  intro z hz
  have := key (z - t - 1).toNat
  rwa [show t + 1 + (((z - t - 1).toNat : ℕ) : ℤ) = z by omega] at this

/-- **Gadget 1's run is rigid.** `s_pre` strictly before the seam, `s_now` at it, `s_post`
strictly after — so gadget 1 carries exactly one anchored run, the one `stayRun` exhibits below.
Not consumed by the trace comparison (see this section's header); landed as the record that there
is no unclassified gadget-1 run. -/
theorem inl_run_pinned (L : ℕ) {σ : ℤ → Fin 3}
    (hstep : ∀ z, stepOf L (Sum.inl (σ z)) (Sum.inl (σ (z + 1))) = true)
    {t : ℤ} (ht : (σ t).val = 1) :
    ∀ z, (σ z).val = if z < t then 0 else if z = t then 1 else 2 := by
  intro z
  by_cases h1 : z < t
  · rw [if_pos h1]; exact inl_bwd_pre L hstep ht z h1
  · rw [if_neg h1]
    by_cases h2 : z = t
    · rw [if_pos h2, h2]; exact ht
    · rw [if_neg h2]; exact inl_fwd_post L hstep ht z (by omega)

/-! ### Gadget 2: the threshold -/

/-- **Gadget 2, backward from the seam.** The only `stepOf` predecessor of `j_now` is `j_pre`, and
`j_pre`'s only predecessor is itself, so a gadget-2 run is constant at `j_pre` strictly before the
seam. This is what keeps `j_post` out of `(-∞, t]`. -/
theorem inr_bwd_pre (L : ℕ) {σ : ℤ → Fin (L + 3)}
    (hstep : ∀ z, stepOf L (Sum.inr (σ z)) (Sum.inr (σ (z + 1))) = true)
    {t : ℤ} (ht : (σ t).val = 1) : ∀ z, z < t → (σ z).val = 0 := by
  have key : ∀ n : ℕ, (σ (t - 1 - (n : ℤ))).val = 0 := by
    intro n
    induction n with
    | zero =>
        simp only [Nat.cast_zero, sub_zero]
        have h := (stepOf_inr_inr_iff L (σ (t - 1)) (σ (t - 1 + 1))).mp (hstep (t - 1))
        rw [show t - 1 + 1 = t by ring] at h
        omega
    | succ m ih =>
        rw [show t - 1 - (((m + 1 : ℕ) : ℤ)) = t - 1 - ((m : ℕ) : ℤ) - 1 by push_cast; ring]
        have h := (stepOf_inr_inr_iff L (σ (t - 1 - ((m : ℕ) : ℤ) - 1))
          (σ (t - 1 - ((m : ℕ) : ℤ) - 1 + 1))).mp (hstep (t - 1 - ((m : ℕ) : ℤ) - 1))
        rw [show t - 1 - ((m : ℕ) : ℤ) - 1 + 1 = t - 1 - ((m : ℕ) : ℤ) by ring] at h
        omega
  intro z hz
  have := key (t - 1 - z).toNat
  rwa [show t - 1 - (((t - 1 - z).toNat : ℕ) : ℤ) = z by omega] at this

/-- **Gadget 2's forward branching: `L + 1` continuations and no more.** `n` steps after the seam
the index is either already absorbed at `j_post` or still on the mid chain at `1 + n`. At
`n = L + 1` the mid-chain alternative IS `j_post` (`1 + (L + 1) = L + 2`), so every gadget-2 run
has reached `j_post` within `L + 1` steps — the finite forward branching that lands the threshold
`w` of `inr_post_threshold` inside `[t, t + L]`. -/
theorem inr_fwd_index (L : ℕ) {σ : ℤ → Fin (L + 3)}
    (hstep : ∀ z, stepOf L (Sum.inr (σ z)) (Sum.inr (σ (z + 1))) = true)
    {t : ℤ} (ht : (σ t).val = 1) :
    ∀ n : ℕ, (σ (t + (n : ℤ))).val = L + 2 ∨ (σ (t + (n : ℤ))).val = 1 + n := by
  intro n
  induction n with
  | zero => simp only [Nat.cast_zero, add_zero]; omega
  | succ m ih =>
      rw [show t + (((m + 1 : ℕ) : ℤ)) = t + ((m : ℕ) : ℤ) + 1 by push_cast; ring]
      have h := (stepOf_inr_inr_iff L (σ (t + ((m : ℕ) : ℤ)))
        (σ (t + ((m : ℕ) : ℤ) + 1))).mp (hstep (t + ((m : ℕ) : ℤ)))
      have hb := (σ (t + ((m : ℕ) : ℤ))).isLt
      omega

/-- **`j_post` absorbs**: its only `stepOf` successor is itself. -/
theorem inr_absorb (L : ℕ) {σ : ℤ → Fin (L + 3)}
    (hstep : ∀ z, stepOf L (Sum.inr (σ z)) (Sum.inr (σ (z + 1))) = true)
    (z : ℤ) (h : (σ z).val = L + 2) : (σ (z + 1)).val = L + 2 := by
  have h1 := (stepOf_inr_inr_iff L (σ z) (σ (z + 1))).mp (hstep z)
  omega

/-- `j_post` absorbs for any number of steps. -/
theorem inr_absorb_add (L : ℕ) {σ : ℤ → Fin (L + 3)}
    (hstep : ∀ z, stepOf L (Sum.inr (σ z)) (Sum.inr (σ (z + 1))) = true) :
    ∀ (n : ℕ) (z : ℤ), (σ z).val = L + 2 → (σ (z + (n : ℤ))).val = L + 2 := by
  intro n
  induction n with
  | zero => intro z h; simpa using h
  | succ m ih =>
      intro z h
      rw [show z + (((m + 1 : ℕ) : ℤ)) = z + ((m : ℕ) : ℤ) + 1 by push_cast; ring]
      exact inr_absorb L hstep _ (ih z h)

/-- **The threshold, extracted.** A gadget-2 run reaches `j_post` within `L + 1` steps of the seam
(`inr_fwd_index`), never leaves it (`inr_absorb_add`), and never visits it at or before the seam
(`inr_bwd_pre` strictly before, `IsRun`'s marker at the seam itself). So its `j_post` indicator is
the indicator of `(w, ∞)` for exactly one `w ∈ [t, t + L]` — the jump time of the history whose
trace the run reproduces. `Nat.find` supplies `w`; no bound on `L` is produced or implied here,
and `L` itself remains the unexhibited witness of `hitCl_eq_truncated`. -/
theorem inr_post_threshold (L : ℕ) {σ : ℤ → Fin (L + 3)}
    (hstep : ∀ z, stepOf L (Sum.inr (σ z)) (Sum.inr (σ (z + 1))) = true)
    {t : ℤ} (hnow : ∀ z, (σ z).val = 1 ↔ z = t) :
    ∃ w : ℤ, t ≤ w ∧ w ≤ t + (L : ℤ) ∧ ∀ z, ((σ z).val = L + 2 ↔ w < z) := by
  classical
  have ht : (σ t).val = 1 := (hnow t).mpr rfl
  have hLp : (σ (t + (((L + 1 : ℕ)) : ℤ))).val = L + 2 := by
    rcases inr_fwd_index L hstep ht (L + 1) with h | h
    · exact h
    · omega
  have hex : ∃ n : ℕ, (σ (t + (n : ℤ))).val = L + 2 := ⟨L + 1, hLp⟩
  obtain ⟨n₀, hspec, hmin⟩ :
      ∃ n₀ : ℕ, (σ (t + (n₀ : ℤ))).val = L + 2
        ∧ ∀ m : ℕ, m < n₀ → (σ (t + (m : ℤ))).val ≠ L + 2 :=
    ⟨Nat.find hex, Nat.find_spec hex, fun m hm => Nat.find_min hex hm⟩
  have hpos : 1 ≤ n₀ := by
    rcases Nat.eq_zero_or_pos n₀ with h0 | h0
    · rw [h0] at hspec
      simp only [Nat.cast_zero, add_zero] at hspec
      omega
    · exact h0
  have hle : n₀ ≤ L + 1 := by
    by_contra hgt
    exact hmin (L + 1) (by omega) hLp
  refine ⟨t + (n₀ : ℤ) - 1, by omega, by omega, ?_⟩
  intro z
  constructor
  · intro hz
    by_contra hc
    simp only [not_lt] at hc
    by_cases hzt : z < t
    · exact absurd (inr_bwd_pre L hstep ht z hzt) (by omega)
    · by_cases hzt' : z = t
      · rw [← hzt'] at ht; omega
      · refine hmin (z - t).toNat (by omega) ?_
        rwa [show t + (((z - t).toNat : ℕ) : ℤ) = z by omega]
  · intro hz
    have habs := inr_absorb_add L hstep (z - (t + (n₀ : ℤ))).toNat (t + (n₀ : ℤ)) hspec
    rwa [show t + (n₀ : ℤ) + (((z - (t + (n₀ : ℤ))).toNat : ℕ) : ℤ) = z by omega] at habs

/-! ### The `⊆` direction -/

/-- **Run characterization, `⊆`.** Every anchored run of the presentation traces `stayA` or one
`jump w` with `t ≤ w ≤ t + L`, and nothing else. Routed exactly as the three excluded shapes and
the threshold above: `isLeft_const_of_isRun` confines the run to one gadget, `IsRun`'s own second
clause supplies the seam correspondence in both, `inr_post_threshold` supplies gadget 2's
threshold, and the trace comparison itself is Phase 5's `runTrace_inl_eq`/`runTrace_inr_eq` — a
rewrite, not a re-derivation. -/
theorem runTrace_mem_of_isRun (t : ℤ) (L : ℕ) (ρ : ℤ → QA L)
    (hρ : IsRun (labOf L) (stepOf L) (clNow Fp) t ρ) :
    runTrace (labOf L) ρ = clTrace MA Fp t stayA
      ∨ ∃ w : ℤ, t ≤ w ∧ w ≤ t + (L : ℤ)
          ∧ runTrace (labOf L) ρ = clTrace MA Fp t (jump w) := by
  obtain ⟨hstep, hnow⟩ := hρ
  have hnow' : ∀ z, isNowState L (ρ z) = true ↔ z = t := by
    intro z; rw [← labOf_now L (ρ z)]; exact hnow z
  have hconst := isLeft_const_of_isRun L hstep t
  by_cases hleft : (ρ t).isLeft = true
  · obtain ⟨σ, hσ⟩ := exists_left_index L ρ (fun z => (hconst z).trans hleft)
    have hnowσ : ∀ z, (σ z).val = 1 ↔ z = t := by
      intro z
      have h := hnow' z
      rw [hσ z] at h
      simpa [isNowState] using h
    left
    rw [show ρ = fun z => Sum.inl (σ z) from funext hσ]
    exact runTrace_inl_eq L t σ hnowσ
  · have hfalse : (ρ t).isLeft = false := by simpa using hleft
    obtain ⟨σ, hσ⟩ := exists_right_index L ρ (fun z => (hconst z).trans hfalse)
    have hnowσ : ∀ z, (σ z).val = 1 ↔ z = t := by
      intro z
      have h := hnow' z
      rw [hσ z] at h
      simpa [isNowState] using h
    have hstepσ : ∀ z, stepOf L (Sum.inr (σ z)) (Sum.inr (σ (z + 1))) = true := by
      intro z; rw [← hσ z, ← hσ (z + 1)]; exact hstep z
    obtain ⟨w, hw1, hw2, hw3⟩ := inr_post_threshold L hstepσ hnowσ
    right
    refine ⟨w, hw1, hw2, ?_⟩
    rw [show ρ = fun z => Sum.inr (σ z) from funext hσ]
    exact runTrace_inr_eq L t w σ hnowσ hw3

/-! ### The `⊇` direction: the witnessing runs

Gadget 1 carries exactly one anchored run (`inl_run_pinned`), and `stayRun` is it. Gadget 2
carries `L + 1`: for each `w ∈ [t, t + L]` the run `jumpRun L t w` walks the mid chain for `w - t`
steps after the seam and then drops into `j_post`. The `min` in `jumpRun` keeps the index inside
`Fin (L + 3)` with no side condition; `jumpRun_val` shows it is the identity on the intended
range, so the `min` is bookkeeping and not a truncation of the construction. -/

/-- The gadget-1 run: `s_pre`, `s_now` at the seam, `s_post`. -/
def stayRun (t : ℤ) (z : ℤ) : Fin 3 :=
  if z < t then 0 else if z = t then 1 else 2

@[simp] theorem stayRun_val (t z : ℤ) :
    (stayRun t z).val = if z < t then 0 else if z = t then 1 else 2 := by
  unfold stayRun
  split_ifs <;> rfl

theorem stayRun_now (t : ℤ) : ∀ z, (stayRun t z).val = 1 ↔ z = t := by
  intro z
  rw [stayRun_val]
  split_ifs with h1 h2
  · exact iff_of_false (by decide) (by omega)
  · exact iff_of_true rfl h2
  · exact iff_of_false (by decide) h2

theorem stayRun_isRun (L : ℕ) (t : ℤ) :
    IsRun (labOf L) (stepOf L) (clNow Fp) t (fun z => Sum.inl (stayRun t z)) := by
  refine ⟨fun z => ?_, fun z => ?_⟩
  · simp only [stepOf_inl_inl_iff, stayRun_val]
    split_ifs <;> omega
  · simp only [labOf_now, isNowState, decide_eq_true_eq]
    exact stayRun_now t z

/-- The gadget-2 run with threshold `w`. -/
def jumpRun (L : ℕ) (t w : ℤ) (z : ℤ) : Fin (L + 3) :=
  ⟨min (if z < t then 0 else if z ≤ w then (z - t + 1).toNat else L + 2) (L + 2), by omega⟩

theorem jumpRun_val (L : ℕ) (t w : ℤ) (_hw : t ≤ w) (hwL : w ≤ t + (L : ℤ)) (z : ℤ) :
    (jumpRun L t w z).val
      = if z < t then 0 else if z ≤ w then (z - t + 1).toNat else L + 2 := by
  have h : (jumpRun L t w z).val
      = min (if z < t then 0 else if z ≤ w then (z - t + 1).toNat else L + 2) (L + 2) := rfl
  rw [h]
  split_ifs <;> omega

theorem jumpRun_now (L : ℕ) (t w : ℤ) (hw : t ≤ w) (hwL : w ≤ t + (L : ℤ)) :
    ∀ z, (jumpRun L t w z).val = 1 ↔ z = t := by
  intro z
  rw [jumpRun_val L t w hw hwL]
  split_ifs with h1 h2
  · exact iff_of_false (by decide) (by omega)
  · constructor <;> intro h <;> omega
  · exact iff_of_false (by omega) (by omega)

theorem jumpRun_post (L : ℕ) (t w : ℤ) (hw : t ≤ w) (hwL : w ≤ t + (L : ℤ)) :
    ∀ z, (jumpRun L t w z).val = L + 2 ↔ w < z := by
  intro z
  rw [jumpRun_val L t w hw hwL]
  split_ifs with h1 h2
  -- `split_ifs` has already reduced `0 = L + 2` to `False` in this branch.
  · exact iff_of_false not_false (by omega)
  · exact iff_of_false (by omega) (by omega)
  · exact iff_of_true rfl (by omega)

theorem jumpRun_isRun (L : ℕ) (t w : ℤ) (hw : t ≤ w) (hwL : w ≤ t + (L : ℤ)) :
    IsRun (labOf L) (stepOf L) (clNow Fp) t (fun z => Sum.inr (jumpRun L t w z)) := by
  refine ⟨fun z => ?_, fun z => ?_⟩
  · simp only [stepOf_inr_inr_iff, jumpRun_val L t w hw hwL]
    split_ifs <;> omega
  · simp only [labOf_now, isNowState, decide_eq_true_eq]
    exact jumpRun_now L t w hw hwL z

/-- **Run characterization, `⊇`.** The presentation realizes `stayA`'s trace and every `jump w`
trace with `t ≤ w ≤ t + L`. Together with `runTrace_mem_of_isRun` this makes the run traces
EXACTLY the truncated family of `hitCl_eq_truncated`. -/
theorem exists_isRun_runTrace (t : ℤ) (L : ℕ) :
    (∃ ρ : ℤ → QA L, IsRun (labOf L) (stepOf L) (clNow Fp) t ρ
        ∧ runTrace (labOf L) ρ = clTrace MA Fp t stayA)
      ∧ ∀ w : ℤ, t ≤ w → w ≤ t + (L : ℤ) →
          ∃ ρ : ℤ → QA L, IsRun (labOf L) (stepOf L) (clNow Fp) t ρ
            ∧ runTrace (labOf L) ρ = clTrace MA Fp t (jump w) := by
  refine ⟨⟨fun z => Sum.inl (stayRun t z), stayRun_isRun L t,
    runTrace_inl_eq L t (stayRun t) (stayRun_now t)⟩, fun w hw hwL => ?_⟩
  exact ⟨fun z => Sum.inr (jumpRun L t w z), jumpRun_isRun L t w hw hwL,
    runTrace_inr_eq L t w (jumpRun L t w) (jumpRun_now L t w hw hwL)
      (jumpRun_post L t w hw hwL)⟩

/-- **Gadget 2's branching is exactly `L + 1`, counted rather than asserted.**
`inr_post_threshold` sends every gadget-2 run to a threshold in `[t, t + L]` and
`exists_isRun_runTrace` realizes every member of that interval, so the realized thresholds are
exactly `Finset.Icc t (t + L)` — whose cardinality is `L + 1`. This is the branching figure the
phase's scope hypothesis names, and it is what makes `exists_isRun_runTrace` surject onto the
truncation window. It is NOT a bound on anything: `L` is still the unexhibited witness of
`hitCl_eq_truncated`. -/
theorem jump_window_card (t : ℤ) (L : ℕ) : (Finset.Icc t (t + (L : ℤ))).card = L + 1 := by
  rw [Int.card_Icc]
  omega

-- The same branching figure, computed at `L = 2`: `j_post` (index `L + 2 = 4`) is directly
-- reachable from exactly the `L + 1 = 3` mid-chain states `j_now, j_mid_1, j_mid_2`, besides its
-- own self-loop. (`Finset.Icc` on `ℤ` is not compilable, so the window itself is witnessed by
-- `jump_window_card` above rather than by a `#guard`.)
#guard ((List.finRange 5).filter
    (fun i => stepOf 2 (Sum.inr i) (Sum.inr (4 : Fin 5)) && !decide (i.val = 4))).length = 3

/-! ## Assembly: the headline

One composition, and no new mathematical content. `hitCl_eq_truncated` (Phase 4) supplies the
`L` and rewrites the seam side into a finite family of family-triple sets; `mem_hitOf_iff`
(library, `RaySummary/HitOf.lean`, re-resolved by name) rewrites the presentation side into
run-existence, and that rewrite is the only place `1 ≤ k` is consumed; the run characterization
(Phase 6) then identifies the two sides' trace arguments in both directions —
`runTrace_mem_of_isRun` for `⊆`, `exists_isRun_runTrace` for `⊇`.

Note the shape of the bridge. `mem_hitOf_iff` is stated membership-wise with
`InFamily sig k x.1 x.2.1 x.2.2 (runTrace lab ρ)` on the right, and `familyTriples sig k c` is
`{x | InFamily sig k x.1 x.2.1 x.2.2 c}`, so the two sides meet at `InFamily` with the trace as
the only differing argument — which is exactly what Phase 6's two directions supply. Nothing here
compares TRACE SETS, and that is the whole reason the Hit level survives: trace-set equality is
what `Probe735.not_presented` refutes. -/

/-- **The headline.** `HitPresented` holds on fixture model A at the seam `(t, a)` of `stayA`
with `φ := Fp`, at every depth `k ≥ 1`, for an UNEXHIBITED `L` — so the Hit-level hypothesis is
satisfiable where `Presented` is refuted (`Probe735.not_presented`), and no computable bound is
delivered. Nothing about `PlusValidZTime`, nothing about `⊡(P p)`, nothing about general regular
ℤ-models. -/
theorem hitPresented_modelA (t : ℤ) (k : ℕ) (hk : 1 ≤ k) :
    ∃ L : ℕ, HitPresented MA stayA t Fp (labOf L) (stepOf L) k := by
  obtain ⟨L, hL⟩ := hitCl_eq_truncated t k hk
  refine ⟨L, ?_⟩
  show HitCl MA stayA t Fp k = ↑(hitOf (labOf L) (stepOf L) (clNow Fp) k)
  rw [hL]
  ext x
  rw [Finset.mem_coe, mem_hitOf_iff (labOf L) (stepOf L) (clNow Fp) k t hk x]
  constructor
  · rintro (hx | hx)
    · obtain ⟨⟨ρ, hρ, htr⟩, -⟩ := exists_isRun_runTrace t L
      exact ⟨ρ, hρ, by rw [htr]; exact hx⟩
    · obtain ⟨w, hw, hx⟩ := Set.mem_iUnion₂.mp hx
      obtain ⟨-, hjump⟩ := exists_isRun_runTrace t L
      obtain ⟨ρ, hρ, htr⟩ := hjump w hw.1 hw.2
      exact ⟨ρ, hρ, by rw [htr]; exact hx⟩
  · rintro ⟨ρ, hρ, hx⟩
    rcases runTrace_mem_of_isRun t L ρ hρ with h | ⟨w, hw1, hw2, h⟩
    · exact Or.inl (by rw [← h]; exact hx)
    · exact Or.inr (Set.mem_iUnion₂.mpr ⟨w, ⟨hw1, hw2⟩, by rw [← h]; exact hx⟩)

/-! ### What `hitPresented_modelA` does NOT say

* **No `L` is exhibited, so no bound is delivered.** The `∃ L` is inherited verbatim from
  `hitCl_eq_truncated`, whose `L` is a `Set.Finite.bddAbove` upper bound on a `choose!`-extracted
  offset function — two uses of `Classical.choice`, neither of which produces a number. In
  particular `card_QA` reads `Fintype.card (QA L) = L + 6`, a function of that unexhibited `L`,
  so it is NOT a bound in `Fp`: requirement (C) asks for `Fintype.card Q` below a COMPUTABLE
  bound in `φ`, and this record does not deliver that half. `jump_window_card`'s `L + 1` is in
  the same position and is a count of realized thresholds, not a bound either.
* **The presentation is deliberately NOT `Presented`.** It realizes only the finitely many seam
  traces inside the truncation window, so the TRACE-set equality `Probe735.not_presented`
  refutes is false of it. Both facts hold of this same fixture, at this same seam, for this same
  `φ`; task 735's verdict and its wired probe stand unchanged, and nothing here retires them.
* **Forward-only.** Nothing about `⊡(P p)`: the fixture is forward-only and there is still no
  backward Bool-fixture bridge (`Probe719Backward.pastStab_iff_allBwdPathsMeet` on the asymmetric
  fixture remains the only backward fixture result). No symmetry is implied or available.
* **Nothing about deciding validity.** `Decidable (PlusValidZTime φ)` is not stated here in any
  form, conditional or otherwise, and no claim is made that L⁺ is decidable, qualified or not.
  (C) alone does not reach validity: (C) and (S) together still speak of ONE seam, and the lift
  to validity is (W).
* **One fixture, one seam, one `φ`.** Model A under `[F.IsRegular]`, for the fragment L⁺, over
  the `ℤ` time axis, at the seam `(t, a)` of `stayA`, with `φ := Fp`. Nothing about general
  regular `ℤ`-models — see the file header's "This does NOT generalize", whose reason is that
  model A's splices are eventually constant in both directions.
-/

-- The closure-size figure the case split rests on, left live so a reader can re-run it.
#eval (plusSubformulaClosure Fp).card

#print axioms path_classify
#print axioms stayA
#print axioms jump
#print axioms splice_classify
#print axioms clTrace_stayA_eq
#print axioms clTrace_jump_eq
#print axioms hitCl_eq_truncated
#print axioms labOf
#print axioms stepOf
#print axioms labOf_inl_iff_clTrace_stayA
#print axioms labOf_inr_iff_clTrace_jump
#print axioms runTrace_mem_of_isRun
#print axioms exists_isRun_runTrace
#print axioms hitPresented_modelA

end Probe745
