/-
Probe 718 (R1 probe 3): **the path-quantifier alternation** — is determinization necessary?
Shows on the Phase-3 fixture that an EXISTENTIAL (nondeterministic) run-summary does **not**
compute `⊡`, so a UNIVERSAL summary — hence complementation, hence determinization — is
genuinely required for this fragment.

**Outcome: the inequivalence holds.** `existsSummary_true`: on the fixture, SOME forward root
path from any seam state reaches `p` (the path that steps straight to `true`). `decide_will`
(restated from `finite-graph-stab-summary.lean`; probes do not import each other, see that
file's own docstring on this point) shows `⊡(Fp)` is `False` at every seam state of the fixture.
So the existential summary is `True` everywhere a formula `⊡(Fp)` whose universal (`⊡`) form is
`False` everywhere — `exists_ne_stab` is the resulting inequivalence, `∀` seam state, needing no
automata theory, no Büchi construction, and no complementation machinery: an elementary
finite-case argument.

**What this licenses and does NOT license, stated explicitly.** This shows the quantifier over
the fibre is UNIVERSAL and that a nondeterministic per-path summary is therefore unsound for
it — exactly the gap a deterministic automaton running along each path would need to close. It
does **not** prove that Safra/Piterman determinization SPECIFICALLY is required (only that
*some* universal/complementation-shaped device is), and it commits to no complexity bound.

**The determinization-funding decision point.** Per this task's `.decisions.json`, the
ω-automata determinization substrate task is to be revived only after R1's falsification probes
1–3 land, funding it on evidence of necessity rather than expectation. This file is exactly that
evidence: Phases 2 and 3 found no obstruction to R1 (stratification licenses an alphabet; the
forward reachability characterization holds), and this phase shows the existential/universal gap
is real on the cheapest possible fixture. **Verdict: necessity demonstrated for this
fragment** — a universal (hence complementation-requiring) summary is needed; nothing here
funds the substrate task by itself, and no determinization work begins in this round or on the
strength of this file alone. Funding remains a filing action for the orchestrator or the user.

Compile-check from the repository root with:
  lake env lean specs/evidence/seam-gluing-ray-product/path-quantifier-alternation.lean
-/
import FormalSystem

open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.PlusLanguage
open FormalSystem.PlusLanguage.PlusFormula

namespace Probe718PathQuantifier

/-! ## The fixture, restated verbatim from `finite-graph-stab-summary.lean` -/

/-- The fixture's one-step relation: the **complete** graph on `Bool`, time-independent. -/
def Rf : ℤ → Bool → Bool → Prop := fun _ _ _ => True

theorem Rf_fwd : ∀ (t : ℤ) (w : Bool), ∃ u, Rf t w u := fun _ _ => ⟨true, trivial⟩
theorem Rf_bwd : ∀ (t : ℤ) (w : Bool), ∃ v, Rf (t - 1) v w := fun _ _ => ⟨true, trivial⟩

/-- The fixture frame: `Bool`, `Fintype`, `Nonempty`, bi-serial. -/
def Ff : FrameOver intOrder := FrameOver.ofSlicedStep Rf Rf_fwd Rf_bwd

instance : Ff.IsRegular := FrameOver.ofSlicedStep_isRegular Rf Rf_fwd Rf_bwd

/-- The distinguished atom: `p` holds exactly at `true`. -/
def pa : Atom := ⟨"p", none⟩

/-- The fixture model. -/
def Mf : TaskModel Ff.toTaskFrame where
  valuation q _ := q.2 = true

/-- A forward root path from `w₀`. -/
def IsFwdPath (w₀ : Bool) (g : ℕ → Bool) : Prop := g 0 = w₀ ∧ ∀ n, Rf 0 (g n) (g (n + 1))

/-- The universal (`⊡`-matching) summary: every forward root path meets `p`. -/
def AllPathsMeet (w₀ : Bool) : Prop := ∀ g : ℕ → Bool, IsFwdPath w₀ g → ∃ n, 0 < n ∧ g n = true

theorem will_iff_allPathsMeet (τ : WorldHistory Ff.toTaskFrame) (t : ℤ) :
    PlusTruthAt Mf τ t (.stab (someFuture (.atom pa))) ↔ AllPathsMeet (τ.state t).2 := by
  rw [PlusTruth.stab_iff]
  generalize hcw : τ.state t = cw
  obtain ⟨c, w₀⟩ := cw
  simp only at hcw ⊢
  constructor
  · intro h g hg
    obtain ⟨hg0, -⟩ := hg
    let h' : ℤ → Bool := fun z => if t ≤ z then g (z - t).toNat else w₀
    let f : ℤ → Ff.WorldState := fun z => (z + (c - t), h' z)
    have hstep : IsStepPath Ff f := by
      intro z
      refine (FrameOver.ofSlicedStep_step Rf Rf_fwd Rf_bwd (f z) (f (z + 1))).mpr ⟨?_, trivial⟩
      show z + 1 + (c - t) = z + (c - t) + 1
      ring
    have hft : f t = (c, w₀) := by
      have h1 : t + (c - t) = c := by ring
      have h2 : h' t = w₀ := by
        show (if t ≤ t then g (t - t).toNat else w₀) = w₀
        rw [if_pos le_rfl]
        simpa using hg0
      show (t + (c - t), h' t) = (c, w₀)
      rw [h1, h2]
    set σ := FrameOver.worldHistoryOfStepPath Ff f hstep with hσdef
    have hσt : σ.state t = (c, w₀) := hft
    have hagree : (c, w₀) = σ.state t := hσt.symm
    obtain ⟨s, hts, hs, -⟩ := h σ hagree
    have hts' : (t : ℤ) < (s : ℤ) := hts
    refine ⟨(s - t).toNat, by omega, ?_⟩
    have hval : (σ.state s).2 = true := hs
    have hσs : σ.state s = f s := rfl
    have hfs2 : (f s).2 = true := hσs ▸ hval
    have hs_eq : h' s = g (s - t).toNat := by
      show (if t ≤ s then g (s - t).toNat else w₀) = g (s - t).toNat
      rw [if_pos (le_of_lt hts)]
    show g (s - t).toNat = true
    rw [← hs_eq]
    exact hfs2
  · intro h σ hagree
    have hw₀ : σ.state t = (c, w₀) := hagree.symm
    have hstep : IsStepPath Ff σ.path := σ.isStepPath
    obtain ⟨n, hn, hgn⟩ := h (fun n => (σ.path (t + n)).2) ⟨by
        show (σ.path (t + (0 : ℕ))).2 = w₀
        have h0 : (t + ((0:ℕ):ℤ)) = t := by norm_num
        rw [h0]
        show (σ.state t).2 = w₀
        rw [hw₀], fun n => trivial⟩
    have hn' : (0 : ℤ) < (n : ℤ) := by exact_mod_cast hn
    refine ⟨t + n, by linarith, ?_, fun r _ _ => PlusTruth.top_true (M := Mf) (τ := σ) (t := r)⟩
    show (σ.state (t + n)).2 = true
    exact hgn

theorem not_allPathsMeet (w₀ : Bool) : ¬ AllPathsMeet w₀ := by
  intro h
  obtain ⟨n, hn0, hn⟩ := h (fun n => if n = 0 then w₀ else false) ⟨if_pos rfl, fun _ => trivial⟩
  rw [if_neg (by omega)] at hn
  simp at hn

/-- `⊡(Fp)` is decidably False at every seam state of the fixture. -/
theorem decide_will (τ : WorldHistory Ff.toTaskFrame) (t : ℤ) :
    ¬ PlusTruthAt Mf τ t (.stab (someFuture (.atom pa))) := by
  rw [will_iff_allPathsMeet]
  exact not_allPathsMeet _

/-! ## The existential summary, and the divergence -/

/-- The **existential** (nondeterministic) summary: SOME forward root path meets `p`. -/
def ExistsSummary (w₀ : Bool) : Prop := ∃ g : ℕ → Bool, IsFwdPath w₀ g ∧ ∃ n, 0 < n ∧ g n = true

/-- **The existential summary is True everywhere.** The straight-to-`true` continuation from any
seam state witnesses it: no branching search is needed to find it, since the fixture is total. -/
theorem existsSummary_true (w₀ : Bool) : ExistsSummary w₀ :=
  ⟨fun n => if n = 0 then w₀ else true, ⟨if_pos rfl, fun _ => trivial⟩, 1, one_pos, by
    show (if (1 : ℕ) = 0 then w₀ else true) = true
    rw [if_neg (by omega)]⟩

/-- A witness history/time at any given seam state, for stating the inequivalence against the
real `⊡` formula (not only against its `AllPathsMeet` surrogate). The constant path at `w₀`. -/
noncomputable def seamHist (w₀ : Bool) : WorldHistory Ff.toTaskFrame :=
  FrameOver.worldHistoryOfStepPath Ff (fun z => (z, w₀)) (fun z =>
    (FrameOver.ofSlicedStep_step Rf Rf_fwd Rf_bwd (z, w₀) (z + 1, w₀)).mpr ⟨rfl, trivial⟩)

theorem seamHist_state (w₀ : Bool) : (seamHist w₀).state 0 = (0, w₀) := rfl

/--
**THE INEQUIVALENCE.** At every seam state of the fixture, the existential summary and the
`⊡`-value diverge: the existential summary is `True`, the `⊡`-value is `False`. No automata
theory, no Büchi construction, no complementation machinery — an elementary finite-case
argument via `existsSummary_true` and `decide_will`.
-/
theorem exists_ne_stab (w₀ : Bool) :
    ¬ (ExistsSummary w₀ ↔ PlusTruthAt Mf (seamHist w₀) 0 (.stab (someFuture (.atom pa)))) := by
  intro hiff
  exact decide_will (seamHist w₀) 0 (hiff.mp (existsSummary_true w₀))

/-- Restated against the universal (`AllPathsMeet`) surrogate directly, without routing through
a specific history: the existential summary is `True`, the universal one `False`, at every
seam state. -/
theorem exists_ne_universal (w₀ : Bool) : ExistsSummary w₀ ∧ ¬ AllPathsMeet w₀ :=
  ⟨existsSummary_true w₀, not_allPathsMeet w₀⟩

end Probe718PathQuantifier

/-! ## Axiom record -/

#print axioms Probe718PathQuantifier.will_iff_allPathsMeet
#print axioms Probe718PathQuantifier.existsSummary_true
#print axioms Probe718PathQuantifier.exists_ne_stab
#print axioms Probe718PathQuantifier.exists_ne_universal
