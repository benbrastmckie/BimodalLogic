import Bimodal.Metalogic.WeakCanonical.Kamp.KampPrior

/-! # Task 376 — probe 08: is the arity-4 multi-anchor bridge needed at all?

Answers the dispatch question by locating the **unique surviving arity** for a characteristic
formula engine, and checking it against Rabinovich's own cap.

## What this probe establishes

1. `charSeam_forces_slot_locality` (sorry-free): **the arity-general obstruction.** For ANY
   arity `n`, ANY depth `k`, ANY engine `char : NormalForm sig k n → Formula` and ANY choice of
   evaluation slot, a completeness seam `truth (env slot) (char σ) ↔ nf_eval_nf M k n env σ`
   FORCES `nf_eval_nf M k n env σ` to depend on `env` only through `env slot`. The engine is
   never destructured: the argument is that a `Formula`'s truth at a point is a function of that
   point alone, so it cannot see `env` at any other position. This is the arity-general form of
   `endCharN0_correct_world_local_obstruction` (Base.lean:1839), which states the `n`-to-1 case.

2. `arity1_slot_locality_is_vacuous` (sorry-free): **at arity 1 the forced consequence is
   trivially true.** `Fin 1` is a subsingleton, so `env slot = env' slot → env = env'`. The
   obstruction of (1) has NO content at arity 1 — nothing is refuted.

3. `free_pos_ge2_slot_locality_has_content` (sorry-free): **with ≥ 2 FREE positions the forced
   consequence is a genuine, falsifiable constraint.** There exist `env ≠ env'` agreeing at any
   given slot. So (1) bites exactly when there is ≥ 1 free non-slot position — and
   `endCharN0_correct_infeasible` (Base.lean:1873) already exhibits a concrete model refuting it.

4. Two `example`s (Part 4) that ELABORATE against the real production types: **the live goal
   chain's actual arity requirement.** `nf_characterizable_temporal_prior` (KampPrior.lean:565)
   consumes `NormalForm sig k 1` and its induction step consumes `NormalForm sig k 2` via
   `nf_nvar_exist_all_depths_fn _ _ k 1`. Neither is arity 4.

## The conclusion these four compile to

A char engine is possible only when every non-slot position is BOUND — i.e. at ONE free
variable. That is exactly Rabinovich Prop 3.5 (PDF p.5): "Every ∨∃∀-formula **with one free
variable** is equivalent to a TL(Until,Since) formula." The paper caps at one free variable
because a TL formula is evaluated at ONE time point. The repo's
`charFib : NormalForm sig k 4 → Formula` asks a one-point object to define a condition with
THREE further free points (`w, x, t`), and report 06's `anchorMove_refutes_any_charEngine`
already refuted every engine of that shape.

**The refuted object is the free-anchor SEAM, not arity 4 per se** — see Part 3's scope
correction. A high-arity env under an `∃` is faithful (`zoneEnv3_arity_invariant`,
Base.lean:543-553).

Rabinovich never grows arity: Lemma 3.2(2) (p.4) caps free variables at 2 after every step, and
one-free-variable pieces are absorbed into the signature as E[Σ]-atoms (Def 4.1, p.5; the
mechanism is used explicitly on p.7: "The first two formulas are ∃∀-formulas with one free
variable. Therefore, by Proposition 3.5 they are equivalent to TL(Until,Since) formulas ...
Hence, their negations are equivalent to **atomic** ... formulas").

`NfEFold.lean:26` (`EAtomDom sig k n := ZoneSpec n × NormalForm sig k 1`) is the repo's own
transcription of that cap, and its docstring already names the defect:
"Rabinovich never grows arity with depth ... the arity-4 residual that NO-GOed task 309's k=1 gate".
-/

namespace Bimodal.Metalogic.WeakCanonical.Kamp.Probe376_08

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical

/-! ## Part 1: the arity-general obstruction

A `Formula` is a syntactic object; `temporal_truth M atomMap u φ` is a function of the single
world `u`. So if a char seam pins `char σ`'s truth AT `env slot` to a property of the WHOLE
`env`, that property cannot actually read `env` anywhere but `slot`. The engine `char` is
universally quantified and never inspected. -/

/-- **The arity-general char-seam obstruction (sorry-free).** ANY engine `char` satisfying the
completeness seam at slot `slot` forces `nf_eval_nf M k n env σ` to be a function of `env slot`
alone. Arity-general form of `endCharN0_correct_world_local_obstruction` (Base.lean:1839). -/
theorem charSeam_forces_slot_locality {sig : MonadicSignature} {k n : Nat}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (char : NormalForm sig k n → Formula) (slot : Fin n)
    (hchar : ∀ (σ : NormalForm sig k n) (env : Fin n → M.carrier),
      temporal_truth M atomMap (env slot) (char σ) ↔ nf_eval_nf M k n env σ) :
    ∀ (σ : NormalForm sig k n) (env env' : Fin n → M.carrier),
      env slot = env' slot →
      (nf_eval_nf M k n env σ ↔ nf_eval_nf M k n env' σ) := by
  intro σ env env' hslot
  rw [← hchar σ env, ← hchar σ env', hslot]

/-! ## Part 2: at arity 1 the forced consequence is vacuous — no obstruction -/

/-- **At arity 1 the obstruction has no content (sorry-free).** `Fin 1` is a subsingleton, so
agreeing at `slot` means being equal outright. `charSeam_forces_slot_locality` therefore forces
nothing at arity 1: its conclusion follows from `env = env'`. This is why
`nf_characterizable_temporal_prior` (KampPrior.lean:565) is GREEN at arity 1 — and why
Rabinovich caps at one free variable (Prop 3.5, PDF p.5). -/
theorem arity1_slot_locality_is_vacuous {carrier : Type} (env env' : Fin 1 → carrier)
    (slot : Fin 1) (hslot : env slot = env' slot) : env = env' := by
  funext i
  have hi : i = slot := Subsingleton.elim i slot
  rw [hi]
  exact hslot

/-! ## Part 3: at ≥ 2 FREE positions the forced consequence is falsifiable

**Scope correction (this probe's own adversarial finding — do not skip).** The refuted object is
NOT "arity 4" as such. `zoneEnv3_arity_invariant` (Base.lean:543-553, sorry-free) certifies that
in `nf_char3_deeper_split` (Base.lean:603) the arity-4 env `[w, y, x, t]` has `w` BOUND by the
enclosing `∃ w`: `Fin.tail (Fin.cons w (zoneEnv3 y x t)) = zoneEnv3 y x t`. Under an existential,
a high-arity env is faithful — it is `nf_eval_nf`'s own `succ` clause (NormalForm.lean:203-207),
and it is Rabinovich Lemma 3.2(3) (PDF p.4: "for every ∃∀-formula φ the formula ∃xφ is equivalent
to a ∃∀-formula") that licenses collapsing it back.

What is refuted is a **seam with FREE non-slot positions**: `charFib`'s seam
`∀ w, render w → ∀ σ u, truth u (charFib σ) ↔ nf_eval [u,w,x,t] σ` leaves `w, x, t` FREE
parameters. That is what `charSeam_forces_slot_locality` kills, and it kills it at every arity
`n ≥ 2` with ≥ 1 free non-slot position — not merely at 4. -/

/-- **With ≥ 2 free positions the obstruction has genuine content (sorry-free).** Given any two
distinct carrier points there are two arity-2 environments agreeing at slot `0` but differing at
slot `1`. `charSeam_forces_slot_locality` would force them to agree on every `nf_eval_nf` fact —
and `endCharN0_correct_infeasible` (Base.lean:1873) exhibits a concrete model (`Mcex` over
`Bool`) where they demonstrably do not. -/
theorem free_pos_ge2_slot_locality_has_content {carrier : Type} (a b : carrier) (hab : a ≠ b) :
    ∃ (env env' : Fin 2 → carrier), env 0 = env' 0 ∧ env ≠ env' := by
  refine ⟨fun _ => a, fun i => if i = 0 then a else b, rfl, ?_⟩
  intro h
  have h1 := congrFun h 1
  simp only [if_neg (by decide : ¬((1 : Fin 2) = 0))] at h1
  exact hab h1

/-! ## Part 4: what the LIVE goal chain actually requires

The chain to `completeness_discrete` (BXCanonical/Completeness.lean:276) runs
`US_expressively_complete_over_prior` → `kamp_prior_expressive_completeness` (KampPrior.lean:648)
→ `nf_characterizable_temporal_prior` (KampPrior.lean:565) → `nf_nvar_exist_all_depths`
(KampPrior.lean:346). The two `example`s below ELABORATE against the real production types and
pin the actual arities consumed. -/

/-- **The live chain's char node consumes arity 1 (elaborates).** `nf_characterizable_temporal_prior`
takes `NormalForm sig k 1` and returns a `Formula` correct at a single world `t` — exactly
Rabinovich Prop 3.5's one-free-variable cap (PDF p.5). -/
noncomputable example {sig : MonadicSignature} (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (k : Nat) (nf : NormalForm sig k 1) :
    { A : Formula //
      ∀ (M : OrderedMonadicStructure sig)
        (_h_UZ : semantic_prior_UZ M atomMap)
        (_h_SZ : semantic_prior_SZ M atomMap)
        (t : M.carrier),
        temporal_truth M atomMap t A ↔ nf_eval_nf M k 1 (fun _ => t) nf } :=
  nf_characterizable_temporal_prior atomMap h_surj k nf

/-- **The live chain's induction step consumes arity 2 (elaborates).** The `succ` arm of
`nf_characterizable_temporal_prior` calls `nf_nvar_exist_all_depths_fn atomMap h_surj k 1`,
whose sub-form argument is `NormalForm sig k 2`. Two free variables — exactly Rabinovich
Lemma 3.2(2)'s cap (PDF p.4). Arity 4 appears nowhere in this chain. -/
noncomputable example {sig : MonadicSignature} (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (k : Nat) (sub_nf : NormalForm sig k 2) : Formula :=
  nf_nvar_exist_all_depths_fn atomMap h_surj k 1 sub_nf

end Bimodal.Metalogic.WeakCanonical.Kamp.Probe376_08
