/-
# Probe: Lemma 3.2(2) anchor-split — the Phase 1 feasibility gate

Machine-checks the ONE step of the Rabinovich route that has no printed proof:
the `m -> m+1` generalization of Lemma 3.2(2) (PDF p.4, dismissed as "It is clear that").

Rabinovich PRINTS the split technique only at m=1 (PDF p.7, the psi_0 / psi_1 / phi
decomposition inside the proof of Prop 4.2). This probe establishes the general step.

## What is transcribed

`ChainOn a l betaLast b` transcribes Def 3.1's chain shape (PDF p.4) on a segment:
witnesses `x_0 < ... < x_n` strictly between `a` and `b`, with
  - `alpha_j` a UNARY point type at `x_j`, and
  - `beta_j` an interval type on the segment `(x_{j-1}, x_j)`.
Def 3.1's free-variable pinning `z_k = x_{i_k}` is transcribed the way Def 3.1
itself licenses it: as a point type `alpha_j := (· = c ∧ ...)`, since Def 3.1
requires only that each `alpha_j` be a one-variable quantifier-free formula.

## The gate claim

`chain_split`: a Def-3.1 chain containing a PINNED anchor `c` is equivalent to the
conjunction of (left segment ending at `c`) ∧ (point type at `c`) ∧ (right segment
starting at `c`). This is exactly Lemma 3.2(2)'s inductive step: each application
removes one free variable from the chain into its own ≤2-free-variable conjunct.

## The load-bearing structural fact

Every conjunct of Def 3.1 (PDF p.4) is either UNARY (`alpha_j(x_j)`, `z_k = x_{i_k}`)
or couples only CONSECUTIVE witnesses (`x_j > x_{j-1}`; `(∀y)^{<x_j}_{>x_{j-1}} beta_j(y)`).
There is NO conjunct joining non-adjacent points. So a Def 3.1 formula's constraint
graph is a PATH, and cutting at an anchor separates it into components sharing only
the cut vertex. Gluing is then unconditional.

Note the two things this probe does NOT need, both of which are predictions that
would FAIL if the gate hid a gap:
  - NO Dedekind completeness (matching Lemma 3.2 on p.4, which carries no such
    hypothesis — unlike Prop 4.2 on p.6, which explicitly requires it);
  - NO density, discreteness, or rigidity. `LinearOrder` alone.
-/

import Mathlib.Order.Basic
import Mathlib.Data.List.Basic

namespace Rabinovich377Probe

variable {T : Type*} [LinearOrder T]

/-- Def 3.1 chain shape (PDF p.4), segment form.

`ChainOn a l betaLast b` holds iff there are witnesses `a < x_0 < ... < x_n < b`
realizing the list `l` of `(beta_j, alpha_j)` obligations, with `betaLast` holding
on the final open segment `(x_n, b)`.

Each list entry `(beta, alpha)` says: `beta` holds on the open segment from the
PREVIOUS point up to the next witness, and `alpha` holds AT that witness. -/
def ChainOn (a : T) : List ((T → Prop) × (T → Prop)) → (T → Prop) → T → Prop
  | [], betaLast, b => ∀ y, a < y → y < b → betaLast y
  | (beta, alpha) :: rest, betaLast, b =>
      ∃ x, a < x ∧ x < b ∧ (∀ y, a < y → y < x → beta y) ∧ alpha x ∧
        ChainOn x rest betaLast b

/-- A pinned anchor: Def 3.1's `z_k = x_{i_k}` conjunct, as a one-variable
point type (which is exactly what Def 3.1, PDF p.4, permits `alpha_j` to be). -/
def pin (c : T) (alphaC : T → Prop) : (T → Prop) := fun x => x = c ∧ alphaC x

/-- The anchor sits strictly after the segment start: a chain that reaches a pinned
anchor `c` from `a` forces `a < c`. Needed to feed the split's order side-conditions. -/
theorem lt_of_chain_pin (a b c : T) (alphaC betaMid betaLast : T → Prop) :
    ∀ (l1 l2 : List ((T → Prop) × (T → Prop))),
      ChainOn a (l1 ++ (betaMid, pin c alphaC) :: l2) betaLast b → a < c := by
  intro l1
  induction l1 generalizing a with
  | nil =>
      intro l2 h
      obtain ⟨x, hax, _, _, ⟨hxc, _⟩, _⟩ := h
      exact hxc ▸ hax
  | cons hd tl ih =>
      intro l2 h
      obtain ⟨x, hax, _, _, _, hrest⟩ := h
      exact lt_trans hax (ih x l2 hrest)

/-- **The Phase 1 gate.** Lemma 3.2(2)'s inductive step (PDF p.4, "It is clear that"),
machine-checked in the general case that Rabinovich prints only at m=1 (PDF p.7).

A Def-3.1 chain through a pinned anchor `c` splits into, and glues back from, three
independent pieces: the left segment `a ⇝ c`, the point type at `c`, and the right
segment `c ⇝ b`. Iterating this once per free variable is the `m -> m+1` induction.

Hypotheses: `LinearOrder` only. No Dedekind completeness, no density, no rigidity. -/
theorem chain_split (a b c : T) (alphaC betaMid betaLast : T → Prop)
    (hcb : c < b) :
    ∀ (l1 l2 : List ((T → Prop) × (T → Prop))),
      a < c →
      (ChainOn a (l1 ++ (betaMid, pin c alphaC) :: l2) betaLast b ↔
        (ChainOn a l1 betaMid c ∧ alphaC c ∧ ChainOn c l2 betaLast b)) := by
  intro l1
  induction l1 generalizing a with
  | nil =>
      intro l2 hac
      constructor
      · rintro ⟨x, hax, _, hbeta, ⟨rfl, halpha⟩, hrest⟩
        exact ⟨hbeta, halpha, hrest⟩
      · rintro ⟨hbeta, halpha, hrest⟩
        exact ⟨c, hac, hcb, hbeta, ⟨rfl, halpha⟩, hrest⟩
  | cons hd tl ih =>
      intro l2 hac
      obtain ⟨beta, alpha⟩ := hd
      constructor
      · rintro ⟨x, hax, hxb, hbeta, halpha, hrest⟩
        have hxc : x < c := lt_of_chain_pin x b c alphaC betaMid betaLast tl l2 hrest
        obtain ⟨hleft, hmid, hright⟩ := (ih x l2 hxc).mp hrest
        exact ⟨⟨x, hax, hxc, hbeta, halpha, hleft⟩, hmid, hright⟩
      · rintro ⟨⟨x, hax, hxc, hbeta, halpha, hleft⟩, hmid, hright⟩
        exact ⟨x, hax, lt_trans hxc hcb, hbeta, halpha,
          (ih x l2 hxc).mpr ⟨hleft, hmid, hright⟩⟩

/-- Corollary: the split is arity-NON-INCREASING. The left conjunct's only free
points are `a` and `c`; the right conjunct's are `c` and `b`. Each application of
`chain_split` yields conjuncts with at most two free variables and NEVER produces a
term coupling three or more anchors jointly — this is Lemma 3.2(2)'s ≤2 cap (p.4).

Stated as the two-anchor instance Rabinovich prints on p.7 (psi_0 / phi / psi_1),
now obtained as an instance of the general step rather than as a separate argument. -/
theorem chain_split_p7_instance (z0 z1 b : T) (alpha1 betaMid betaLast : T → Prop)
    (l2 : List ((T → Prop) × (T → Prop))) (h01 : z0 < z1) (h1b : z1 < b) :
    ChainOn z0 ((betaMid, pin z1 alpha1) :: l2) betaLast b ↔
      ((∀ y, z0 < y → y < z1 → betaMid y) ∧ alpha1 z1 ∧ ChainOn z1 l2 betaLast b) :=
  chain_split z0 b z1 alpha1 betaMid betaLast h1b [] l2 h01

end Rabinovich377Probe

-- Axiom audit: the gate must rest on nothing beyond Lean's standard three.
#print axioms Rabinovich377Probe.chain_split
#print axioms Rabinovich377Probe.chain_split_p7_instance
#print axioms Rabinovich377Probe.lt_of_chain_pin
