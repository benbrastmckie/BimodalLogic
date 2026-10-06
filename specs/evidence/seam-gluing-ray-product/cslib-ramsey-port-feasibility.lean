/-
Probe 736: **is the cslib ω-automata stack portable to this pin, and does its Ramsey theorem
subsume this tree's?**  A feasibility probe for the cslib inventory's central structural claim.

**What this establishes (High, machine-checked).**

(1) PORT FEASIBILITY.  `infinite_pigeonhole_principle` and `infinite_graph_ramsey` --
Ching-Tsun Chou's `Cslib/Foundations/Combinatorics/InfiniteGraphRamsey.lean`, present in
upstream `leanprover/cslib` -- compile on THIS tree's pin (Lean `v4.33.0-rc1`, Mathlib
`79d0395a`), `sorry`-free, from Mathlib alone.  No `Cslib.*` import, no `module` /
`public import` / `@[expose] public section` preamble, no cslib lint infrastructure.  The
cslib file's own non-Mathlib imports (`Cslib.Init`, `Cslib/Foundations/Lint/Basic.lean`,
56 lines between them) are style and linter infrastructure, not mathematics, and are dropped
here without loss.  The port's whole substantive cost is the 147 lines of that one file.

(2) SUBSUMPTION, THE DIRECTION THAT MATTERS.  `repo_ramsey_from_cslib_ramsey` derives the exact
statement of this tree's `Nat.exists_strictMono_const_pair_colour`
(`FormalSystem/ForMathlib/Combinatorics/InfiniteRamseyPairs.lean`, consumed under the alias
`infinite_ramsey_pairs` by `FormalSystem/Metalogic/WeakCanonical/GroupModel/RamseyFactorization.lean`)
FROM the ported `infinite_graph_ramsey`, through the two glue steps the shape difference forces:
an UNORDERED-to-ORDERED pair bridge (`min'`/`max'` of a two-element `Finset`), and a monotone
enumeration of an infinite `Set ℕ` (`Nat.nth`).  So cslib's theorem is strictly the more general
statement and the in-tree one is a corollary of it.

That subsumption is a MACHINE CHECK, not an eyeball comparison: Part 3 writes the in-tree
theorem's statement once as `RepoRamseyStatement` and discharges that one type twice -- once
from `Nat.exists_strictMono_const_pair_colour` and once from `repo_ramsey_from_cslib_ramsey`.
Had the two statements drifted in any argument, implicit, or instance, one ascription would
fail to elaborate.

(3) THE CONVERSE FAILS, AND WHY.  No derivation in the other direction is attempted here, and
none is possible: the in-tree theorem fixes `Vertex := ℕ`, fixes `C : Type` (not `Type*`), and
takes its colouring CURRIED on ordered pairs (`ℕ → ℕ → C`), whereas cslib quantifies over an
arbitrary `[Infinite Vertex]` and colours unordered `Finset Vertex`.  Recovering a general
`Vertex` would need a bijection with `ℕ`, which `[Infinite Vertex]` does not supply.

**What this does NOT establish, and explicitly refuses to claim.**

NOT that the port should be made.  Feasibility is not advisability: this file is one 147-line
leaf of a 47-module, 7,526-line cslib closure, and says nothing about the rest of it.  On the
two live consumers' actual shape -- `RamseyFactorization.lean` instantiates
`infinite_ramsey_pairs` TWICE with opposite orientations (`segZ sig c a b` and
`segZ sig c (-b) (-a)`), i.e. in the curried ordered form -- replacing the in-tree module by a
port plus this file's glue is a net ADDITION of lines, not a saving.  Subsumption is a fact
about the statements; it is not a recommendation.

NOT a faithful line-by-line transcription of cslib's proof.  The STATEMENTS of both ported
theorems are transcribed verbatim up to the `Set.restrict`/`Set.domRestrict` rename below.  The
PROOFS follow cslib's strategy (a good-selection chain, then a second pigeonhole over the
colours of the chain), but the chain's `⋂ m < n` bookkeeping is replaced here by a direct
antitone-chain argument, and cslib's `grind` calls by explicit terms.  Equal strength, different
bookkeeping -- not evidence about how cslib's own proof scripts fare on this pin.

NOT portability of anything else in cslib.  In particular NOT of
`Cslib/Computability/Automata/NA/BuchiCompl.lean`: that file's three main theorems
(`complement_language_sub`, `complement_language_sup`, `complement_language_eq`) are
`proof_wanted`, which emits no declaration at all -- machine-checked here only in the negative
sense that nothing in this file depends on them.

NOT any complexity bound, upper or lower.  NOT any claim that these shapes discriminate between
the four candidate devices; `Probe732Device` settled that they do not.

**Port friction, as measured not conjectured.**  cslib pins Mathlib `169c26b5` (2026-07-20),
this tree `79d0395a` (2026-07-16): 76 commits apart, cslib ahead.  cslib's pinned Mathlib HEAD
commit IS `refactor: rename restrict to domRestrict (#25980)`, and the first line of the first
ported proof below breaks on exactly that rename -- `s.domRestrict f` upstream is
`s.restrict f` here.  `Set.Infinite.diff` is additionally deprecated here in favour of
`Set.Infinite.sdiff`.  Both fixes are one-token; the point is that a 4-day, 76-commit rev skew
already produced one hard break in 147 lines.

**Provenance.**  `Cslib/Foundations/Combinatorics/InfiniteGraphRamsey.lean`, author Ching-Tsun
Chou, Apache 2.0, present in `leanprover/cslib` upstream `main` at `ea16de32a` and locally
modified in the fork.  Its own docstring: "This result really should be in Mathlib, but
currently it is not."  Confirmed absent from Mathlib at this pin: a sweep of all 8,268 Mathlib
source files finds no Ramsey theorem declaration (`Combinatorics/Hindman.lean` and
`Combinatorics/HalesJewett.lean` mention Ramsey theory only in prose).
-/
import Mathlib.Algebra.Order.Group.Nat
import Mathlib.Data.Fintype.Pigeonhole
import Mathlib.Data.Set.Finite.Basic
import Mathlib.Data.Set.Lattice
import Mathlib.Data.Nat.Nth
import FormalSystem.ForMathlib.Combinatorics.InfiniteRamseyPairs

namespace Probe736

open Function Set

/-! ## Part 1: the cslib statements, ported -/

/-- Ported from cslib `Cslib.infinite_pigeonhole_principle` (statement verbatim; `s.domRestrict f`
there is `s.restrict f` at this pin). -/
theorem infinite_pigeonhole_principle {X Y : Type*} [Finite Y] (f : X → Y) {s : Set X}
    (h_inf : s.Infinite) : ∃ y, ∃ t, t.Infinite ∧ t ⊆ s ∧ ∀ x ∈ t, f x = y := by
  have := h_inf.to_subtype
  obtain ⟨y, h_inf'⟩ := Finite.exists_infinite_fiber (s.restrict f)
  have h_inf_iff := Equiv.infinite_iff <|
    Equiv.subtypeSubtypeEquivSubtypeInter (· ∈ s) (fun x ↦ f x = y)
  refine ⟨y, {x | x ∈ s ∧ f x = y}, infinite_coe_iff.mp <| h_inf_iff.mp h_inf', ?_, ?_⟩
  · intro x hx; exact hx.1
  · intro x hx; exact hx.2

private structure InfVSet (Vertex : Type*) where
  set : Set Vertex
  inf : set.Infinite

private structure Selection (Vertex Color : Type*) where
  vs : InfVSet Vertex
  v : Vertex
  c : Color

variable {Vertex Color : Type*} [Finite Color] (color : Finset Vertex → Color)

open scoped Classical in
/-- A good selection: an infinite subset, a distinguished vertex outside it but inside the
ambient set, and one colour for every edge from that vertex into the subset. -/
private def GoodSelection (ivs : InfVSet Vertex) (S : Selection Vertex Color) : Prop :=
  S.vs.set ⊆ ivs.set ∧ S.v ∈ ivs.set \ S.vs.set ∧ ∀ u ∈ S.vs.set, color {S.v, u} = S.c

private lemma goodSelection_exists (ivs : InfVSet Vertex) :
    ∃ S : Selection Vertex Color, GoodSelection color ivs S := by
  classical
  obtain ⟨v, h_v⟩ := Set.Infinite.nonempty ivs.inf
  obtain ⟨c, vs, h_inf, h_vs, h_col⟩ :=
    infinite_pigeonhole_principle (fun u => color {v, u})
      (Set.Infinite.sdiff ivs.inf (finite_singleton v))
  refine ⟨{ vs := InfVSet.mk vs h_inf, v := v, c := c }, ?_, ?_, h_col⟩
  · intro x hx; exact (h_vs hx).1
  · exact ⟨h_v, fun hmem => (h_vs hmem).2 rfl⟩

variable [Infinite Vertex]

private noncomputable def goodSelectionSeq : ℕ → Selection Vertex Color
  | 0 => Classical.choose (goodSelection_exists color (InfVSet.mk univ infinite_univ))
  | n + 1 => Classical.choose (goodSelection_exists color (goodSelectionSeq n).vs)

private lemma seq_zero_spec :
    GoodSelection color (InfVSet.mk univ infinite_univ) (goodSelectionSeq color 0) :=
  Classical.choose_spec (goodSelection_exists color (InfVSet.mk univ infinite_univ))

private lemma seq_succ_spec (n : ℕ) :
    GoodSelection color (goodSelectionSeq color n).vs (goodSelectionSeq color (n + 1)) :=
  Classical.choose_spec (goodSelection_exists color (goodSelectionSeq color n).vs)

private noncomputable abbrev seqV (n : ℕ) : Vertex := (goodSelectionSeq color n).v
private noncomputable abbrev seqC (n : ℕ) : Color := (goodSelectionSeq color n).c
private noncomputable abbrev seqS (n : ℕ) : Set Vertex := (goodSelectionSeq color n).vs.set

/-- The chain of infinite vertex sets is antitone.  (cslib tracks this through
`⋂ m < n, (goodSelectionSeq m).vs.set`; the direct chain suffices.) -/
private lemma seqS_antitone {m n : ℕ} (h : m ≤ n) : seqS color n ⊆ seqS color m := by
  induction n with
  | zero => cases Nat.le_zero.mp h; exact fun _ hx => hx
  | succ n ih =>
    rcases Nat.lt_or_ge m (n + 1) with hlt | hge
    · exact fun x hx => ih (Nat.lt_succ_iff.mp hlt) ((seq_succ_spec color n).1 hx)
    · cases Nat.le_antisymm h hge; exact fun _ hx => hx

open scoped Classical in
/-- Every distinguished vertex colours all edges into its own set with its own colour. -/
private lemma seq_edge_colour (n : ℕ) :
    ∀ u ∈ seqS color n, color {seqV color n, u} = seqC color n := by
  cases n with
  | zero => exact (seq_zero_spec color).2.2
  | succ n => exact (seq_succ_spec color n).2.2

/-- A later distinguished vertex lies in every earlier vertex set. -/
private lemma seqV_mem_earlier {m n : ℕ} (h : m < n) : seqV color n ∈ seqS color m := by
  obtain ⟨k, rfl⟩ : ∃ k, n = k + 1 := ⟨n - 1, by omega⟩
  exact seqS_antitone color (by omega) (seq_succ_spec color k).2.1.1

/-- A distinguished vertex is never in its own vertex set. -/
private lemma seqV_notMem_own (n : ℕ) : seqV color n ∉ seqS color n := by
  cases n with
  | zero => exact (seq_zero_spec color).2.1.2
  | succ n => exact (seq_succ_spec color n).2.1.2

private lemma seqV_injective : Injective (seqV color) := by
  intro m n hmn
  by_contra hne
  rcases Nat.lt_or_ge m n with h | h
  · exact seqV_notMem_own color m (hmn ▸ seqV_mem_earlier color h)
  · exact seqV_notMem_own color n (hmn ▸ seqV_mem_earlier color (by omega : n < m))

open scoped Classical in
/-- Pairs of distinguished vertices are coloured by the earlier index's colour. -/
private lemma seqV_pair_colour {m n : ℕ} (h : m < n) :
    color {seqV color m, seqV color n} = seqC color m :=
  seq_edge_colour color m _ (seqV_mem_earlier color h)

/-- **Infinite Ramsey for graphs** -- ported from cslib `Cslib.infinite_graph_ramsey`
(statement verbatim).  If the edges of an infinite complete graph get finitely many colours,
some colour has an infinite monochromatic vertex set. -/
theorem infinite_graph_ramsey :
    ∃ c : Color, ∃ s : Set Vertex, s.Infinite ∧
      ∀ e : Finset Vertex, e.card = 2 → ↑e ⊆ s → color e = c := by
  classical
  obtain ⟨c', s', h_s'_inf, -, h_s'_col⟩ :=
    infinite_pigeonhole_principle (seqC color) (s := (univ : Set ℕ)) infinite_univ
  refine ⟨c', seqV color '' s',
    h_s'_inf.image (injOn_of_injective (seqV_injective color)), ?_⟩
  intro e he_card he_sub
  obtain ⟨x, y, hxy, he⟩ := Finset.card_eq_two.mp he_card
  subst he
  obtain ⟨m, hm, hmx⟩ := he_sub (show x ∈ (↑({x, y} : Finset Vertex) : Set Vertex) by simp)
  obtain ⟨n, hn, hny⟩ := he_sub (show y ∈ (↑({x, y} : Finset Vertex) : Set Vertex) by simp)
  subst hmx; subst hny
  have hmn : m ≠ n := fun h => hxy (by rw [h])
  rcases Nat.lt_or_ge m n with h | h
  · rw [seqV_pair_colour color h]; exact h_s'_col m hm
  · rw [Finset.pair_comm, seqV_pair_colour color (by omega : n < m)]; exact h_s'_col n hn

/-! ## Part 2: the in-tree theorem is a corollary -/

section Subsumption

variable {C : Type} [Finite C]

/-- The unordered-to-ordered bridge: on a two-element `Finset ℕ` with `a < b`, `min'` is `a`
and `max'` is `b`.  This is the shape difference between cslib's `Finset Vertex → Color`
colourings and this tree's curried `ℕ → ℕ → C` ones. -/
private lemma pair_min'_max' {a b : ℕ} (hab : a < b) (h : ({a, b} : Finset ℕ).Nonempty) :
    ({a, b} : Finset ℕ).min' h = a ∧ ({a, b} : Finset ℕ).max' h = b := by
  refine ⟨le_antisymm (Finset.min'_le _ a (by simp)) (Finset.le_min' _ _ _ ?_),
    le_antisymm (Finset.max'_le _ _ _ ?_) (Finset.le_max' _ b (by simp))⟩
  · intro z hz
    simp only [Finset.mem_insert, Finset.mem_singleton] at hz
    rcases hz with rfl | rfl
    · exact le_refl _
    · exact hab.le
  · intro z hz
    simp only [Finset.mem_insert, Finset.mem_singleton] at hz
    rcases hz with rfl | rfl
    · exact hab.le
    · exact le_refl _

/-- **The subsumption result.**  The exact statement of this tree's
`Nat.exists_strictMono_const_pair_colour`, derived from the ported cslib
`infinite_graph_ramsey` -- so the in-tree module's theorem is a corollary of cslib's, and the
two are not independent results.

The two glue steps are the only content: the unordered/ordered pair bridge
(`pair_min'_max'`) and the monotone enumeration of an infinite `Set ℕ` (`Nat.nth`). -/
theorem repo_ramsey_from_cslib_ramsey (c : ℕ → ℕ → C) :
    ∃ g : ℕ → ℕ, StrictMono g ∧ ∃ τ : C, ∀ i j : ℕ, i < j → c (g i) (g j) = τ := by
  classical
  -- `c 0 0` inhabits `C`, which is what makes the junk branch below definable.
  obtain ⟨τ, s, hs_inf, hs_col⟩ := infinite_graph_ramsey (Vertex := ℕ) (Color := C)
    (fun e => if h : e.Nonempty then c (e.min' h) (e.max' h) else c 0 0)
  refine ⟨Nat.nth (· ∈ s), Nat.nth_strictMono hs_inf, τ, ?_⟩
  intro i j hij
  have hmono : Nat.nth (· ∈ s) i < Nat.nth (· ∈ s) j := Nat.nth_strictMono hs_inf hij
  have hmem_i := Nat.nth_mem_of_infinite hs_inf i
  have hmem_j := Nat.nth_mem_of_infinite hs_inf j
  have hne : Nat.nth (· ∈ s) i ≠ Nat.nth (· ∈ s) j := Nat.ne_of_lt hmono
  have hnonempty : ({Nat.nth (· ∈ s) i, Nat.nth (· ∈ s) j} : Finset ℕ).Nonempty :=
    ⟨Nat.nth (· ∈ s) i, by simp⟩
  have hcol := hs_col {Nat.nth (· ∈ s) i, Nat.nth (· ∈ s) j} (Finset.card_pair hne) (by
    intro z hz
    simp only [Finset.coe_insert, Finset.coe_singleton, Set.mem_insert_iff,
      Set.mem_singleton_iff] at hz
    rcases hz with rfl | rfl
    · exact hmem_i
    · exact hmem_j)
  rw [dif_pos hnonempty] at hcol
  obtain ⟨hmin, hmax⟩ := pair_min'_max' hmono hnonempty
  rw [hmin, hmax] at hcol
  exact hcol

end Subsumption

/-! ## Part 3: the derived statement IS the in-tree theorem's statement -/

/-- The shared statement, written once.  The two `example`s below discharge *this same type*,
one from the in-tree module and one from the cslib port, which is what makes the subsumption
claim a machine check rather than an eyeball comparison: if the statements had drifted apart in
any argument, implicit, or instance, one of the two ascriptions would fail to elaborate. -/
private abbrev RepoRamseyStatement : Prop :=
  ∀ {C : Type} [Finite C] (c : ℕ → ℕ → C),
    ∃ g : ℕ → ℕ, StrictMono g ∧ ∃ τ : C, ∀ i j : ℕ, i < j → c (g i) (g j) = τ

/-- Discharged by the in-tree module. -/
example : RepoRamseyStatement := fun c => Nat.exists_strictMono_const_pair_colour c

/-- Discharged by the cslib port.  Same type as the line above. -/
example : RepoRamseyStatement := fun c => repo_ramsey_from_cslib_ramsey c

/-! ## Part 4: axiom profiles -/

-- Both ported theorems and the subsumption corollary stand on the three standard axioms only
-- (`propext`, `Classical.choice`, `Quot.sound`) -- no `sorryAx`, matching the profile the
-- same declarations have inside cslib itself.
#print axioms infinite_pigeonhole_principle
#print axioms infinite_graph_ramsey
#print axioms repo_ramsey_from_cslib_ramsey

end Probe736
