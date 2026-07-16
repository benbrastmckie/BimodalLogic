/-
# Probe: why `chain_split` cannot close the `KampPrior.lean:520` residual (Phase 9)

The plan's Phase 9 task 3 directs: "Try `chain_split` against the non-interval zones (1,2,4,5)
BEFORE anything else." This probe executes that instruction and records the result.

## Result: NOT APPLICABLE AT ANY ZONE — and the reason is a faithfulness boundary, not a gap.

`chain_split` (reports/01_lemma32-anchor-split-probe.lean) is axiom-free and correct. Its
gluing is licensed by ONE stated structural precondition, quoted verbatim from its own header:

  "Every conjunct of Def 3.1 (PDF p.4) is either UNARY (`alpha_j(x_j)`, `z_k = x_{i_k}`) or
   couples only CONSECUTIVE witnesses ... There is NO conjunct joining non-adjacent points.
   So a Def 3.1 formula's constraint graph is a PATH, and cutting at an anchor separates it
   into components sharing only the cut vertex. Gluing is then unconditional."

The `hreal`/`hrealI`/`hrealB` obligation that gates the k>=2 arm concludes in

  `nf_eval_nf M (k+1) 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) sigma`

i.e. an arity-4 `NormalForm sig (k+1) 4` over the env `[x1, w, x, t]` (index 0 = x1, 1 = w,
2 = x, 3 = t). This probe machine-checks that such an object VIOLATES chain_split's
precondition: its atom domain is `AtomKind sig 4`, whose `order` constructor
(`NormalForm.lean:60`) is

  `| order (i j : Fin n) (h : i ≠ j) : AtomKind sig n`

— an order atom for EVERY ordered pair `i ≠ j`. At n = 4 that is the COMPLETE directed graph
on {x1, w, x, t} (12 order atoms), not a path. Cutting at the anchor `w` (index 1) leaves the
edges x1<->x, x1<->t, and w<->t intact across the cut, so the cut does NOT separate the
constraint graph. chain_split's induction has no purchase — at the interval zones
(`igZXW`/`igZWT`) and the non-interval zones (`igZPastX`/`igZAtX`/`igZAtW`/`igZAtT`/`igZFutT`)
ALIKE. The zone partition is irrelevant to the obstruction: every zone's fiber is arity-4.

## This is not a missing lemma. It is the arity cap.

Rabinovich caps arity everywhere the method touches:
  - Def 3.1 (PDF p.4): alpha_j, beta_j are "quantifier free formulas with ONE variable".
  - Lemma 3.2(2) (PDF p.4): every ExistsForall-formula is equivalent to a conjunction of
    ExistsForall-formulas "with at most TWO free variables".
  - Def 4.1 (PDF p.5): E[Sigma] is a set of "UNARY predicate names".

There is no arity-4 joint type anywhere in the 16 pages. Lemma 3.2(2) exists precisely to
REDUCE to <=2 free variables so that joint types over many points are never needed. An
arity-4 fiber is therefore off-paper by construction, and `chain_split` — being faithful to
Def 3.1 — is at the faithful arity and cannot reach it. The non-applicability is a CORRECT
report of the faithfulness boundary, not a defect in chain_split.

This is the same defect for which task 376 was abandoned, verbatim from specs/state.json:
  "the arity-4 charFib has NO counterpart in Rabinovich's 16 pages -- Def 3.1 (p.4) caps point
   types at ONE variable, Def 4.1 (p.5) caps expansion atoms at unary -- so the engine was
   novel mathematics, and the refutations were the compiler correctly rejecting a false
   statement"

Per the binding constraint, NO Feferman-Vaught attempt is made here, and no novel composition
theorem is reached for. Probe STOPS at the boundary, as directed.
-/

import Mathlib.Data.Fin.Basic

namespace Rabinovich377Phase9Probe

/-! ## The precondition chain_split needs, stated as a predicate on a constraint graph. -/

/-- A constraint graph on `Fin n`: `Couples i j` means some conjunct jointly constrains
points `i` and `j`. `chain_split`'s license is that this relation is PATH-shaped. -/
abbrev Couples (n : Nat) := Fin n → Fin n → Prop

/-- chain_split's stated precondition: no conjunct joins non-adjacent points. Transcribed from
the probe header's "load-bearing structural fact". Adjacency is `|i - j| = 1`. -/
abbrev PathShaped {n : Nat} (C : Couples n) : Prop :=
  ∀ i j : Fin n, C i j → (i.val + 1 = j.val ∨ j.val + 1 = i.val)

/-- The constraint graph of an arity-`n` NormalForm: `AtomKind.order (i j) (h : i ≠ j)` supplies
an order atom for EVERY ordered pair, so the NF couples every distinct pair.
(Mirrors `NormalForm.lean:58-60` — reproduced here so the probe is standalone.) -/
abbrev nfCouples (n : Nat) : Couples n := fun i j => i ≠ j

/-- **The probe's verdict.** The arity-4 NF constraint graph is NOT path-shaped: the order atom
on the non-adjacent pair (0, 3) = (x1, t) couples the two points that a cut at the anchor
`w` (index 1) is supposed to separate. So `chain_split`'s precondition fails at the gate
obligation, at every zone. -/
theorem nf4_not_pathShaped : ¬ PathShaped (nfCouples 4) := by
  intro h
  -- x1 (index 0) and t (index 3) are coupled by an `order` atom, yet are non-adjacent.
  rcases h ⟨0, by omega⟩ ⟨3, by omega⟩ (by decide) with h1 | h1 <;> simp at h1

/-- The same failure witnessed at the OTHER pair that a cut at `w` must sever: x (index 2)
and t (index 3) are adjacent, but x1 (index 0) and x (index 2) are not — and are coupled.
Confirms the obstruction is not an artifact of one index choice. -/
theorem nf4_not_pathShaped_second_witness :
    nfCouples 4 ⟨0, by omega⟩ ⟨2, by omega⟩ ∧
      ¬ ((0 : Nat) + 1 = 2 ∨ (2 : Nat) + 1 = 0) := by
  refine ⟨by decide, by omega⟩

/-- By contrast, Def 3.1's own chain shape IS path-shaped — which is exactly why `chain_split`
succeeds there and only there. A 2-point (Lemma 3.2(2) cap) constraint graph is trivially a
path: with `n = 2` every distinct pair IS adjacent. This is the faithful arity. -/
theorem nf2_pathShaped : PathShaped (nfCouples 2) := by
  -- At arity 2 the only distinct pairs are (0,1) and (1,0), both adjacent.
  decide

end Rabinovich377Phase9Probe

-- Axiom audit: the verdict must rest on nothing beyond Lean's standard three.
#print axioms Rabinovich377Phase9Probe.nf4_not_pathShaped
#print axioms Rabinovich377Phase9Probe.nf4_not_pathShaped_second_witness
