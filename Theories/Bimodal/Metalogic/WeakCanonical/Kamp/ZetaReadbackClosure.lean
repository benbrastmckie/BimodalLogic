import Bimodal.Metalogic.WeakCanonical.Kamp.ZetaEngineClosure

/-!
# ζ readback-closure obstruction — the committed `ReadbackClosed` is unsatisfiable (OFF-PATH)

**Purpose.** This module is the machine-checked obstruction record for the readback-closed `F`
construction. The prior gating probe (`ZetaEngineClosure.lean`, RED verdict) established that a
*naive bottom-up* closure `F ↦ F ∪ {readbacks over F}` never reaches a fixpoint, because a
readback closure step strictly enlarges the `sigE` E[Σ] alphabet
(`esigma_alphabet_strict_mono`, `readback_closure_step_grows_alphabet`). The intended repair was a
JOINT fixpoint of formula-set ∧ alphabet, keyed on a fixed target formula (a Fischer–Ladner
closure). This file records the **deeper gap** that construction surfaces: for the closure
predicate as committed in `ZetaEngineClosure.lean`, **no finite `F : Finset Formula` can satisfy
`ReadbackClosed` at all** — not merely "not by bottom-up iteration", but not by any construction
whatsoever.

## The obstruction (machine-checked, `not_readbackClosed` below)

`ReadbackClosed atomMap h_surj` (`ZetaEngineClosure.lean`) has as its first conjunct

> `∀ ξ : ExistsForallFormula sig F 1, translateProp35 atomMap h_surj ξ ∈ F`.

The quantifier ranges over the ENTIRE type `ExistsForallFormula sig F 1`
(`ExistsForallFormula.lean`, Rabinovich Def 3.1, PDF p.4), whose `n : Nat` field — the number of
ordered existential points `x₀ < … < xₙ` — is **unbounded**. The readback
`translateProp35 atomMap h_surj ξ` is `translateEF1 ξ.n (ξ.pin 0) … …`
(`Prop35Assembly.lean`), and `translateEF1` assembles a `buildRight`/`buildLeft` Until/Since chain
with **one `untl` node per existential point to the right of the pinned variable**
(`ExistsForallNF.lean`, `buildRight`). Hence the readback image contains formulas of unbounded
`untl`-count: taking `ξ = psiConst sig F m` (the ∃∀-formula with `m+1` points, variable pinned at
`x₀`, constant point/interval types) gives `m ≤ numUntl (translateProp35 … (psiConst sig F m))`
(`le_numUntl_translateProp35`).

A finite `F` bounds `numUntl` above by `F.sup numUntl`. So `ReadbackClosed` would force
`m ≤ F.sup numUntl` for every `m : Nat` — impossible. Therefore `¬ ReadbackClosed atomMap h_surj`
for every `sig`, every finite `F`, and every `(atomMap, h_surj)` (`not_readbackClosed`).

## Why attempts (i) and (ii) do not reach it

- **(i) Joint fixpoint keyed on a target formula.** Rabinovich's Fischer–Ladner closure quantifies
  the alphabet over the *fixed target formula's* closure set — a FINITE, input-derived family of
  ∃∀-formulas of BOUNDED `n`. But the committed `ReadbackClosed` predicate has no target-formula
  parameter: its `∀ ξ` ranges over ALL of `ExistsForallFormula sig F 1`, unbounded `n` included.
  There is no hook in the predicate to restrict `ξ` to an input-derived family. So the faithful
  Rabinovich construction cannot even be *expressed* against this interface.
- **(ii) Depth-bounded readback termination.** Bounding the readback temporal depth likewise means
  restricting the `∀ ξ` to bounded-`n` witnesses. Same obstruction: the committed predicate admits
  no such restriction; `psiConst sig F m` for `m > d` violates any fixed depth `d`.

## Consequence — HARD STOP, surfaced for `/research`

Neither faithful attempt yields a `ReadbackClosed`-satisfying `F`, and this file proves the target
predicate is *outright unsatisfiable*. Per the plan's hard-stop clause, no `sorry`, `def := True`,
or vacuous `F := ∅` is introduced. The precise pivot for the research dispatch: the committed
`ReadbackClosed` **over-specifies** the closure obligation. Phase 13e-2's consumers
(`translateProp35_mem_F_of_closed`, the bracket/endpoint `*_of_closed` lemmas) only ever apply the
closure at the FINITE family of ∃∀-formulas actually fed to `hCapture`/`capFn` at the ζ sites
(`ZetaUniformExtract.lean`, `EFSatNegationGeneral.lean`) — an input-derived, bounded-`n` set. The
adequate predicate is a `ReadbackClosed` re-scoped to quantify over *that finite family* (or over
`ξ` whose `translateProp35` is a subformula of a Rabinovich Fischer–Ladner closure of the input),
which `F` = Fischer–Ladner closure discharges. Re-scoping the predicate touches both the committed
probe and Phase 13e-2's plan, i.e. a `/research` + `/revise`, not a 13e-1 construction.

## References
- Rabinovich, *A Proof of Kamp's Theorem* (2014): Def 4.1 (PDF p.5), Prop 4.3 (p.6),
  Thm 4.4 (p.6), and the Fischer–Ladner closure construction (finite closure-set + fixed E[Σ]
  alphabet). Cited by PDF page; the companion markdown transcription is corrupt.
- `ZetaEngineClosure.lean`: `ReadbackClosed`, the four `*_of_closed` conditional lemmas, and the
  bottom-up circularity (`esigma_alphabet_strict_mono`, `readback_closure_step_grows_alphabet`).
- `ExistsForallFormula.lean` (Def 3.1, p.4): `ExistsForallFormula` (the unbounded `n` field).
- `Prop35Assembly.lean` (Prop 3.5, p.5): `translateProp35`.
- `ExistsForallNF.lean`: `translateEF1`, `buildRight`, `buildLeft`.

This module is a pure off-path obstruction record. Nothing imports it; it does not touch the
completeness spine, and `KampPrior.lean:562` is untouched.
-/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax (Formula Atom)
open Bimodal.Metalogic.WeakCanonical

variable {sig : MonadicSignature} {F : Finset Formula}

/-! ## 1. A clean structural `untl`-counting measure

`numUntl` counts the genuine `Formula.untl` constructors. It is defined over the six real
`Formula` constructors, so the derived operators (`and`, `neg`, `top`, `or`), which reduce to
`imp`/`bot`, are seen through automatically. -/

/-- The number of `untl` (Until) constructors in a formula. -/
def numUntl : Formula → Nat
  | .atom _ => 0
  | .bot => 0
  | .imp a b => numUntl a + numUntl b
  | .box a => numUntl a
  | .untl a b => 1 + numUntl a + numUntl b
  | .snce a b => numUntl a + numUntl b

/-- `Formula.and` (`= (φ.imp ψ.neg).neg`) contributes no `untl` node of its own: its `untl`-count
is the sum of its arguments'. -/
@[simp] theorem numUntl_and (X Y : Formula) :
    numUntl (Formula.and X Y) = numUntl X + numUntl Y := by
  simp [Formula.and, Formula.neg, numUntl]

/-! ## 2. `buildRight` nests one `untl` per list element

The right Until-chain `buildRight L r` has at least `L.length` `untl` constructors: each cons of
`L` emits an outer `Formula.untl` (`ExistsForallNF.lean`). This is the structural source of the
unbounded readback size. -/

/-- The right Until-chain over a list `L` carries at least `L.length` `untl` constructors. -/
theorem length_le_numUntl_buildRight :
    ∀ (L : List (TemporalPred × TemporalPred)) (r : TemporalPred),
      L.length ≤ numUntl (buildRight L r)
  | [], _ => Nat.zero_le _
  | (a, b) :: rest, r => by
    have ih := length_le_numUntl_buildRight rest r
    have hstep : numUntl (buildRight ((a, b) :: rest) r)
        = 1 + (numUntl a.formula + numUntl (buildRight rest r)) + numUntl b.formula := by
      simp only [buildRight, numUntl, numUntl_and]
    rw [hstep, List.length_cons]
    omega

/-! ## 3. The unbounded-size readback witnesses

`psiConst sig F m` is the ∃∀-formula (Def 3.1, p.4) with `m+1` ordered existential points, the
single free variable pinned to `x₀`, and constant (trivial) point/interval types. Its Prop-3.5
readback (`translateProp35`) has `untl`-count at least `m`, so the readbacks are of unbounded
size. -/

/-- The ∃∀-formula with `m+1` ordered points, free variable pinned at `x₀`, trivial types. -/
def psiConst (sig : MonadicSignature) (F : Finset Formula) (m : Nat) :
    ExistsForallFormula sig F 1 where
  n := m
  pin := fun _ => ⟨0, Nat.succ_pos m⟩
  pointType := fun _ => NormalForm.base (fun _ => false)
  intervalType := fun _ => ∅

/-- The Prop-3.5 translation of `translateEF1 n k α β` has `untl`-count at least `n - k.val`: the
right chain alone contributes `n - k.val` `untl` nodes. -/
theorem sub_le_numUntl_translateEF1 (n : Nat) (k : Fin (n + 1))
    (alpha : Fin (n + 1) → TemporalPred) (beta : Fin (n + 2) → TemporalPred) :
    n - k.val ≤ numUntl (translateEF1 n k alpha beta) := by
  rw [translateEF1]
  simp only [numUntl_and]
  have hlen := length_le_numUntl_buildRight
    ((List.finRange (n - k.val)).map fun i =>
      (alpha ⟨k.val + 1 + i.val, by omega⟩, beta ⟨k.val + 1 + i.val, by omega⟩))
    (beta ⟨n + 1, by omega⟩)
  simp only [List.length_map, List.length_finRange] at hlen
  omega

/-- **Unbounded readback size.** The Prop-3.5 readback of `psiConst sig F m` has `untl`-count at
least `m`. Hence `{ translateProp35 … (psiConst sig F m) | m : Nat }` contains formulas of
arbitrarily large `untl`-count. -/
theorem le_numUntl_translateProp35
    (atomMap : Formula → (sigE sig F).preds)
    (h_surj : ∀ p : (sigE sig F).preds, ∃ a : Atom, atomMap (.atom a) = p)
    (m : Nat) :
    m ≤ numUntl (translateProp35 atomMap h_surj (psiConst sig F m)) := by
  have h := sub_le_numUntl_translateEF1 (psiConst sig F m).n ((psiConst sig F m).pin 0)
    (fun j => efPointTP atomMap h_surj ((psiConst sig F m).pointType j))
    (fun i => efIntervalSetTP atomMap h_surj ((psiConst sig F m).intervalSet i))
  rw [translateProp35]
  simpa using h

/-! ## 4. The obstruction: no finite `F` satisfies the committed `ReadbackClosed`

The first conjunct of `ReadbackClosed` forces every unbounded-size readback into the finite `F`,
capping `numUntl` above by `F.sup numUntl` — contradicting `le_numUntl_translateProp35`. -/

/-- **The committed `ReadbackClosed` predicate is unsatisfiable for every finite `F`.** For every
signature `sig`, every finite completeness set `F`, and every `(atomMap, h_surj)`, there is no
`ReadbackClosed atomMap h_surj` witness: the readbacks of `psiConst sig F m` (unbounded `untl`-
count) cannot all live in the finite `F`. This is the deeper gap the readback-closed-`F`
construction surfaces — the HARD STOP for `/research`, machine-checked, sorry-free. -/
theorem not_readbackClosed
    (atomMap : Formula → (sigE sig F).preds)
    (h_surj : ∀ p : (sigE sig F).preds, ∃ a : Atom, atomMap (.atom a) = p) :
    ¬ ReadbackClosed atomMap h_surj := by
  intro hClosed
  have hbound : ∀ m : Nat, m ≤ F.sup numUntl := by
    intro m
    have hmem : translateProp35 atomMap h_surj (psiConst sig F m) ∈ F := hClosed.1 (psiConst sig F m)
    have hle : m ≤ numUntl (translateProp35 atomMap h_surj (psiConst sig F m)) :=
      le_numUntl_translateProp35 atomMap h_surj m
    have hsup : numUntl (translateProp35 atomMap h_surj (psiConst sig F m)) ≤ F.sup numUntl :=
      Finset.le_sup hmem
    omega
  have hcontra := hbound (F.sup numUntl + 1)
  omega

end Bimodal.Metalogic.WeakCanonical.Kamp
