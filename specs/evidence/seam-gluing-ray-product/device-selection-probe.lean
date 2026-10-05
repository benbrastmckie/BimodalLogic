/-
Probe 732 (E3): **device-selection comparison** for the universal summary over the stab fibre —
which device, on what evidence, and what is NOT established.

**Outcome on the specified shapes (High, machine-checked): `⊡(Fp)` and `⊡(Pp)` are
device-inert on finite fixtures.** Over an arbitrary finite step graph the universal summary of
the `Fp` shape equals its restriction to ultimately periodic (lasso) root paths by pigeonhole
alone (`allPathsMeet_iff_lasso`; the `Pp` dual on the reversed step relation is
`allBwdPathsMeet_iff_lasso`), and the per-path acceptor for "eventually `p`" is a 2-state
DETERMINISTIC automaton (`detRun_accepts_iff`). On the real formula, on the Bool fixture the
necessity probe used, `stab_will_iff_lasso` restates `PlusTruthAt Mf τ t (.stab (someFuture
(.atom pa)))` as that lasso-restricted summary. All four candidate devices therefore coincide
on these shapes with the reachability summaries already recorded by
`Probe718FiniteGraph.will_iff_allPathsMeet` / `Probe718FiniteGraph.decide_will` (forward) and
`Probe719Backward.pastStab_iff_allBwdPathsMeet` (backward). The shapes do not discriminate.

**Falsifier (High, machine-checked).** `not_lasso_sufficient_on_chain`: on the infinite acyclic
fibre `⟨ℤ, b = a - 1⟩` the lasso-restricted summary is vacuously True while the universal summary
is False, so pigeonhole-tier lasso summaries are refuted as a device for infinite fibres — and
infinite fibres are unavoidable for complete certificate classes, by the in-tree
`FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.NoFiniteWidth.not_finite_width_fmp`
(the finite-width FMP refutation). Whatever the substrate uses must work over the TIME AXIS with
a finite alphabet of per-time summaries, not over states.

**Selection, scoped exactly.** On infrastructure and literature evidence — not on behavioural
discrimination, which the probed shapes cannot supply — the universal-summary substrate should
be built on the TIME-AXIS RAMSEY-COLOURED SUMMARY, candidate (d), via the in-tree
`FormalSystem.Metalogic.WeakCanonical.infinite_ramsey_pairs` (proved from scratch in
`RamseyFactorization.lean`; `#print axioms` = `[propext, Classical.choice, Quot.sound]`; absent
from Mathlib at pin `v4.33.0-rc1`), framed by the MSO-over-`⟨ℤ,<⟩` quasimodel route, candidate
(c): Hodkinson–Wolter–Zakharyaschev, APAL 106 (2000), Theorem 15 (§4; flows including `⟨ℤ,<⟩`),
and Gabbay–Kurucz–Wolter–Zakharyaschev 2003, Theorem 1.28 (MSO theory of `⟨ℤ,<⟩` decidable),
Lemma 11.23 (quasimodel existence as an MSO sentence), Theorem 13.6 (§13.2, S5 × linear time).
Route (c) is the frame because it covers the target flow exactly and needs no Safra
construction; (d) is the substrate because its one non-trivial ingredient already exists in
this tree on standard axioms, whereas (c)'s discharge theorem (Büchi's theorem) has no Lean
formalization and under the zero-debt policy could not be cited but would have to be proved.
Candidates (a) Safra/Piterman determinization and (b) Safraless procedures (Kupferman–Vardi,
FOCS 2005) are **not selected**: inert on the probed shapes (the acceptor is already
deterministic, so there is nothing to determinize and no complementation to avoid); no
ω-automata, Büchi, parity or Rabin infrastructure in Mathlib at the pin; no formalization of
Safra or Piterman determinization in any proof assistant; and (b)'s FOCS 2005 source is
WANTED in the Literature index (only its 2001 rank-construction core, Kupferman–Vardi "Weak
Alternating Automata Are Not That Weak", is in corpus).

**What this does NOT establish.** Any behavioural superiority of (d) over (c) — on the probed
shapes they, and (a) and (b), coincide; (c) and (d) are plausibly the same mathematics in two
wrappers (Büchi complementation is classically Ramsey-based), and that framing is Low-confidence
background, not a result of this file. Adequacy of (d) beyond the probed shapes `⊡(Fp)` /
`⊡(Pp)`. A frame-level `⊡(Pp)` bridge on this fixture: the `Pp` side is carried here at the
step-graph level by reversal (`allBwdPathsMeet_iff_lasso`), and the backward shape on the real
formula is fixed by `Probe719Backward.pastStab_iff_allBwdPathsMeet` on the asymmetric fixture,
not re-proved here. Any complexity bound: this file states no complexity bound; the argued
(not formalized) CTL* 2EXPTIME LOWER bound is a sanity ceiling any later procedure must clear,
never an upper-bound source. The selection is by evidence of what exists and what fails, not a
behavioural discrimination between devices. A selection reading "no candidate is adequate on this
evidence" was an admissible outcome of this probe; it was not reached, because candidate (d)'s
one non-trivial ingredient exists in this tree and route (c) covers the target flow exactly.

**No substrate work.** `detRun` is a counterexample to the need for determinization on these
shapes, not a component of anything; nothing here begins a determinization substrate or any
other substrate. The first behavioural discrimination between (c) and (d) lives on a finitely
presented INFINITE fibre with a per-time alphabet (the quasimodel setting), where (d) must
colour time pairs and (c) must write the MSO sentence; that is substrate work and belongs to
the substrate task, not here. A selection recorded on this scope leaves the substrate task's
blocked reason ("device not yet selected") dischargeable by its own revision, which this file
does not perform.

Compile-check from the repository root with:
  lake env lean specs/evidence/seam-gluing-ray-product/device-selection-probe.lean
-/
import FormalSystem

open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.PlusLanguage
open FormalSystem.PlusLanguage.PlusFormula

/-! The E3 device-selection comparison core. Over an ARBITRARY finite step graph, the universal
summary of the `Fp` shape reduces to ultimately periodic (lasso) paths by PIGEONHOLE ALONE -- no
Ramsey, no automata, no determinization. The per-path property "eventually P" is recognised by a
2-state DETERMINISTIC automaton, so Safra/Safraless have nothing to do on this shape. -/

namespace Probe732Device

variable {S : Type} [Finite S]

/-- A forward root path from `w₀` in the step graph `R`. -/
def IsPath (R : S → S → Prop) (w₀ : S) (g : ℕ → S) : Prop := g 0 = w₀ ∧ ∀ n, R (g n) (g (n + 1))

/-- Ultimately periodic: from index `i` on, period `p > 0`. -/
def IsLasso (g : ℕ → S) : Prop := ∃ i p : ℕ, 0 < p ∧ ∀ n, i ≤ n → g (n + p) = g n

/-- The universal (`⊡(Fp)`-shaped) summary: every root path meets `P` at a positive time. -/
def AllPathsMeet (R : S → S → Prop) (P : S → Prop) (w₀ : S) : Prop :=
  ∀ g, IsPath R w₀ g → ∃ n, 0 < n ∧ P (g n)

/-- The lasso index: identity below `j`, then wraps into the cycle `[i, j)`. -/
def lassoIdx (i j n : ℕ) : ℕ := if n < j then n else i + (n - i) % (j - i)

theorem lassoIdx_pos (i j n : ℕ) (hi : 0 < i) (hn : 0 < n) : 0 < lassoIdx i j n := by
  unfold lassoIdx; split_ifs <;> omega

theorem lassoIdx_lt (i j n : ℕ) (hij : i < j) : lassoIdx i j n < j := by
  unfold lassoIdx
  split_ifs with h
  · exact h
  · have := Nat.mod_lt (n - i) (by omega : 0 < j - i)
    omega

omit [Finite S] in
/-- Build the lasso from a path `g` and a repeat `g i = g j`, `0 < i < j`. -/
theorem exists_lasso_of_repeat (R : S → S → Prop) (w₀ : S) (g : ℕ → S) (hg : IsPath R w₀ g)
    (i j : ℕ) (hi : 0 < i) (hij : i < j) (hrep : g i = g j) :
    ∃ g', IsPath R w₀ g' ∧ IsLasso g' ∧ ∀ n, 0 < n → ∃ m, 0 < m ∧ g' n = g m := by
  refine ⟨fun n => g (lassoIdx i j n), ⟨?_, ?_⟩, ⟨j, j - i, by omega, ?_⟩, ?_⟩
  · show g (lassoIdx i j 0) = w₀
    simp [lassoIdx, show 0 < j by omega, hg.1]
  · intro n
    show R (g (lassoIdx i j n)) (g (lassoIdx i j (n + 1)))
    unfold lassoIdx
    by_cases h1 : n + 1 < j
    · rw [if_pos (by omega), if_pos h1]; exact hg.2 n
    · rw [if_neg h1]
      by_cases h0 : n < j
      · -- n = j - 1 : step from g (j-1) to g i = g j
        rw [if_pos h0]
        have hn : n = j - 1 := by omega
        have : (n + 1 - i) % (j - i) = 0 := by
          rw [show n + 1 - i = j - i by omega]; exact Nat.mod_self _
        rw [this, Nat.add_zero, hrep, hn]
        have := hg.2 (j - 1)
        rwa [show j - 1 + 1 = j by omega] at this
      · rw [if_neg h0]
        -- n ≥ j: both indices wrap
        have hrlt : (n - i) % (j - i) < j - i := Nat.mod_lt _ (by omega)
        have hmod : (n + 1 - i) % (j - i) = ((n - i) % (j - i) + 1) % (j - i) := by
          rw [show n + 1 - i = (n - i) + 1 by omega, Nat.mod_add_mod]
        by_cases hr1 : (n - i) % (j - i) + 1 < j - i
        · rw [hmod, Nat.mod_eq_of_lt hr1, ← Nat.add_assoc]; exact hg.2 _
        · have hr2 : (n - i) % (j - i) + 1 = j - i := by omega
          rw [hmod, hr2, Nat.mod_self, Nat.add_zero, hrep]
          have := hg.2 (i + (n - i) % (j - i))
          rwa [show i + (n - i) % (j - i) + 1 = j by omega] at this
  · intro n hn
    show g (lassoIdx i j (n + (j - i))) = g (lassoIdx i j n)
    unfold lassoIdx
    rw [if_neg (by omega), if_neg (by omega)]
    congr 2
    rw [show n + (j - i) - i = (n - i) + (j - i) by omega, Nat.add_mod_right]
  · intro n hn
    exact ⟨lassoIdx i j n, lassoIdx_pos i j n hi hn, rfl⟩

/-- **Lasso sufficiency for the `Fp` shape, by pigeonhole alone.** Over a finite step graph the
universal summary agrees with its restriction to ultimately periodic paths. -/
theorem allPathsMeet_iff_lasso (R : S → S → Prop) (P : S → Prop) (w₀ : S) :
    AllPathsMeet R P w₀ ↔ ∀ g, IsPath R w₀ g → IsLasso g → ∃ n, 0 < n ∧ P (g n) := by
  constructor
  · intro h g hg _; exact h g hg
  · intro h g hg
    by_contra hno
    simp only [not_exists, not_and] at hno
    -- pigeonhole on the shifted sequence so every repeat index is positive
    obtain ⟨a, b, hab, heq⟩ := Finite.exists_ne_map_eq_of_infinite (fun n => g (n + 1))
    rcases Nat.lt_or_gt_of_ne hab with hlt | hlt
    · obtain ⟨g', hg', hl, hm⟩ :=
        exists_lasso_of_repeat R w₀ g hg (a + 1) (b + 1) (by omega) (by omega) heq
      obtain ⟨n, hn, hPn⟩ := h g' hg' hl
      obtain ⟨m, hm0, hgm⟩ := hm n hn
      exact hno m hm0 (hgm ▸ hPn)
    · obtain ⟨g', hg', hl, hm⟩ :=
        exists_lasso_of_repeat R w₀ g hg (b + 1) (a + 1) (by omega) (by omega) heq.symm
      obtain ⟨n, hn, hPn⟩ := h g' hg' hl
      obtain ⟨m, hm0, hgm⟩ := hm n hn
      exact hno m hm0 (hgm ▸ hPn)

/-- The `Pp` (backward) shape is the same statement on the reversed graph: nothing new. -/
theorem allBwdPathsMeet_iff_lasso (R : S → S → Prop) (P : S → Prop) (w₀ : S) :
    AllPathsMeet (fun a b => R b a) P w₀ ↔
      ∀ g, IsPath (fun a b => R b a) w₀ g → IsLasso g → ∃ n, 0 < n ∧ P (g n) :=
  allPathsMeet_iff_lasso _ P w₀

/-! ## The per-path automaton for the `Fp` shape is already deterministic -/

/-- Two-state deterministic acceptor for "eventually `P`": state `true` = seen `P`. -/
def detRun (P : S → Prop) [DecidablePred P] (g : ℕ → S) : ℕ → Bool
  | 0 => false
  | n + 1 => detRun P g n || decide (P (g (n + 1)))

omit [Finite S] in
theorem detRun_true_iff (P : S → Prop) [DecidablePred P] (g : ℕ → S) (n : ℕ) :
    detRun P g n = true ↔ ∃ m, 0 < m ∧ m ≤ n ∧ P (g m) := by
  induction n with
  | zero => simp [detRun]
  | succ n ih =>
    simp only [detRun, Bool.or_eq_true, decide_eq_true_eq, ih]
    constructor
    · rintro (⟨m, hm0, hmn, hP⟩ | hP)
      · exact ⟨m, hm0, by omega, hP⟩
      · exact ⟨n + 1, by omega, le_rfl, hP⟩
    · rintro ⟨m, hm0, hmn, hP⟩
      rcases Nat.lt_or_eq_of_le hmn with h | h
      · exact Or.inl ⟨m, hm0, by omega, hP⟩
      · exact Or.inr (h ▸ hP)

omit [Finite S] in
/-- Acceptance (the run eventually reaches `true`) is exactly the per-path `Fp` property. No
nondeterminism is involved, so no determinization device acts on this shape. -/
theorem detRun_accepts_iff (P : S → Prop) [DecidablePred P] (g : ℕ → S) :
    (∃ n, detRun P g n = true) ↔ ∃ m, 0 < m ∧ P (g m) := by
  constructor
  · rintro ⟨n, hn⟩
    obtain ⟨m, hm0, -, hP⟩ := (detRun_true_iff P g n).mp hn
    exact ⟨m, hm0, hP⟩
  · rintro ⟨m, hm0, hP⟩
    exact ⟨m, (detRun_true_iff P g m).mpr ⟨m, hm0, le_rfl, hP⟩⟩

/-! ## The falsifier: pigeonhole-tier lasso sufficiency FAILS on an infinite acyclic fibre -/

/-- The descending chain on `ℤ`: the one-step relation `a → a - 1`. Acyclic and infinite. -/
def chainR (a b : ℤ) : Prop := b = a - 1

theorem chain_path_strictAnti (w₀ : ℤ) (g : ℕ → ℤ) (hg : g 0 = w₀ ∧ ∀ n, chainR (g n) (g (n + 1))) :
    ∀ n, g n = w₀ - n := by
  intro n
  induction n with
  | zero => simp [hg.1]
  | succ n ih => have := hg.2 n; unfold chainR at this; rw [this, ih]; push_cast; ring

/-- No forward path in the chain is a lasso. -/
theorem chain_no_lasso (w₀ : ℤ) (g : ℕ → ℤ) (hg : g 0 = w₀ ∧ ∀ n, chainR (g n) (g (n + 1))) :
    ¬ (∃ i p : ℕ, 0 < p ∧ ∀ n, i ≤ n → g (n + p) = g n) := by
  rintro ⟨i, p, hp, hper⟩
  have h := hper i le_rfl
  rw [chain_path_strictAnti w₀ g hg, chain_path_strictAnti w₀ g hg] at h
  push_cast at h
  omega

/-- **The falsifier.** On the infinite chain, with `P` never holding, the universal summary is
False (the chain itself avoids `P`) while its lasso restriction is vacuously True. Pigeonhole-tier
lasso sufficiency is therefore NOT a device for infinite fibres: the `⊡(Fp)`/`⊡(Pp)` shapes on
FINITE fixtures cannot see this, which is exactly why they do not discriminate the candidates. -/
theorem not_lasso_sufficient_on_chain (w₀ : ℤ) :
    ¬ ((∀ g : ℕ → ℤ, (g 0 = w₀ ∧ ∀ n, chainR (g n) (g (n + 1))) → ∃ n, 0 < n ∧ False) ↔
       (∀ g : ℕ → ℤ, (g 0 = w₀ ∧ ∀ n, chainR (g n) (g (n + 1))) →
          (∃ i p : ℕ, 0 < p ∧ ∀ n, i ≤ n → g (n + p) = g n) → ∃ n, 0 < n ∧ False)) := by
  intro hiff
  have hrhs : ∀ g : ℕ → ℤ, (g 0 = w₀ ∧ ∀ n, chainR (g n) (g (n + 1))) →
      (∃ i p : ℕ, 0 < p ∧ ∀ n, i ≤ n → g (n + p) = g n) → ∃ n, 0 < n ∧ False :=
    fun g hg hl => absurd hl (chain_no_lasso w₀ g hg)
  obtain ⟨_, _, h⟩ := hiff.mpr hrhs (fun n => w₀ - n) ⟨by simp, fun n => by unfold chainR; push_cast; ring⟩
  exact h

/-! ## The fixture, restated verbatim from `path-quantifier-alternation.lean`

Probes do not import each other (collection convention, see the `check-evidence-probes.sh`
header), so the shared two-state Bool fixture of the necessity probe is restated here verbatim
from `path-quantifier-alternation.lean`. The only change is the NAME of the fixture-level
universal summary: the sibling calls it `AllPathsMeet`, which in this namespace is already the
abstract `AllPathsMeet R P w₀` above, so here it is `AllFwdPathsMeet`. Its definition, and the
proof of `will_iff_allPathsMeet`, are unchanged. -/

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
def AllFwdPathsMeet (w₀ : Bool) : Prop := ∀ g : ℕ → Bool, IsFwdPath w₀ g → ∃ n, 0 < n ∧ g n = true

theorem will_iff_allPathsMeet (τ : WorldHistory Ff.toTaskFrame) (t : ℤ) :
    PlusTruthAt Mf τ t (.stab (someFuture (.atom pa))) ↔ AllFwdPathsMeet (τ.state t).2 := by
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

/-! ## The bridge: the fixture's summary IS the abstract summary on `Rf 0` -/

/-- `IsFwdPath w₀` is `IsPath (Rf 0) w₀` and `AllFwdPathsMeet w₀` is
`AllPathsMeet (Rf 0) (· = true) w₀`, definitionally -- the identification the research report
asserted, compiled. -/
theorem allFwdPathsMeet_iff_abstract (w₀ : Bool) :
    AllFwdPathsMeet w₀ ↔ AllPathsMeet (Rf 0) (fun b => b = true) w₀ := Iff.rfl

/-- **The headline inertness statement on the real formula.** On the fixture the necessity probe
used, `⊡(Fp)` at a seam state equals its restriction to ultimately periodic forward root paths.
Only pigeonhole is consumed (`allPathsMeet_iff_lasso`); on this shape all four candidate devices
coincide with this reachability summary. -/
theorem stab_will_iff_lasso (τ : WorldHistory Ff.toTaskFrame) (t : ℤ) :
    PlusTruthAt Mf τ t (.stab (someFuture (.atom pa))) ↔
      ∀ g, IsFwdPath (τ.state t).2 g → IsLasso g → ∃ n, 0 < n ∧ g n = true := by
  rw [will_iff_allPathsMeet, allFwdPathsMeet_iff_abstract, allPathsMeet_iff_lasso]
  exact Iff.rfl

/-! ## What the shape exercises of each device

On `⊡(Fp)` / `⊡(Pp)` over this fixture (or any finite step graph), one line per candidate:

- (a) Safra/Piterman determinization, (b) Safraless procedures: `detRun_accepts_iff` shows the
  per-path acceptor for "eventually `p`" is a 2-state DETERMINISTIC automaton -- there is no
  nondeterminism to determinize and no complementation to avoid, so neither device acts.
- (c) MSO over `<ℤ,<>` plus Büchi/Rabin: on a finite fixture the sentence "every forward root
  path meets `p`" is decided by the same finite reachability `allPathsMeet_iff_lasso` reduces to;
  there is nothing for the automata-theoretic discharge to absorb.
- (d) Ramsey-coloured summary: only the PIGEONHOLE tier is invoked
  (`Finite.exists_ne_map_eq_of_infinite`); `FormalSystem.Metalogic.WeakCanonical.infinite_ramsey_pairs`
  is never needed here.

The sibling results all four devices therefore coincide with on this fixture:
`Probe718FiniteGraph.will_iff_allPathsMeet` / `Probe718FiniteGraph.decide_will` (`⊡(Fp)` is
False at every seam state) for the forward shape, and
`Probe719Backward.pastStab_iff_allBwdPathsMeet` for the backward shape. -/

end Probe732Device

#print axioms Probe732Device.allPathsMeet_iff_lasso
#print axioms Probe732Device.allBwdPathsMeet_iff_lasso
#print axioms Probe732Device.detRun_accepts_iff
#print axioms Probe732Device.not_lasso_sufficient_on_chain
#print axioms Probe732Device.will_iff_allPathsMeet
#print axioms Probe732Device.allFwdPathsMeet_iff_abstract
#print axioms Probe732Device.stab_will_iff_lasso
