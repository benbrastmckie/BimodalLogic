import Bimodal.Metalogic.Bundle.SuccChainFMCS
import Bimodal.Metalogic.Bundle.SuccChainTaskFrame
import Bimodal.Semantics.WorldHistory

/-!
# WorldHistory from Succ-Chain

This module constructs a WorldHistory from the Succ-chain FMCS family.
The history uses the full Int domain (all times) and maps each time t
to the MCS at succ_chain_fam M0 t.

## Main Definitions

- `succ_chain_canonical_task`: Proof that chain structure implies CanonicalTask
- `succ_chain_history`: WorldHistory for CanonicalTaskTaskFrame

## Key Property

The chain structure directly gives CanonicalTask relationship:
- For n ≥ 0: CanonicalTask_forward through n Succ steps
- For n < 0: CanonicalTask_backward through |n| Pred steps

Since adjacent chain elements satisfy Succ, the CanonicalTask relation
(built from Succ chains) is satisfied by construction.

## References

- Task 14: SuccChainFMCS.lean, SuccChainTaskFrame.lean
- Bimodal.Semantics.WorldHistory
-/

namespace Bimodal.Metalogic.Bundle

open Bimodal.Syntax
open Bimodal.Metalogic.Core
open Bimodal.Semantics

/-!
## CanonicalTask from Chain Structure

The Succ-chain family satisfies CanonicalTask by construction:
adjacent elements are Succ-related, so chains give CanonicalTask_forward/backward.
-/

/--
Build CanonicalTask_forward from the Succ-chain.

For any n ≥ 0, we have CanonicalTask_forward (succ_chain_fam M0 s) n (succ_chain_fam M0 (s + n)).

The proof is by induction on n, using succ_chain_fam_succ for each step.
-/
theorem succ_chain_gives_canonical_forward (M0 : SerialMCS) (s : Int) (n : Nat) :
    CanonicalTask_forward (succ_chain_fam M0 s) n (succ_chain_fam M0 (s + n)) := by
  induction n generalizing s with
  | zero =>
    have h : s + (0 : Nat) = s := by omega
    rw [h]
    exact CanonicalTask_forward.base
  | succ n' ih =>
    -- CanonicalTask_forward s (n'+1) (s + n'+1)
    -- = step from s to s+1, then CanonicalTask_forward (s+1) n' (s+1+n')
    -- ih is now generalized over s, so ih (s+1) gives what we need
    have h_succ : Succ (succ_chain_fam M0 s) (succ_chain_fam M0 (s + 1)) := succ_chain_fam_succ M0 s
    have h_eq : s + (↑(n' + 1) : Int) = (s + 1) + ↑n' := by omega
    rw [h_eq]
    -- Need CanonicalTask_forward (s+1) n' ((s+1) + n')
    have ih' : CanonicalTask_forward (succ_chain_fam M0 (s + 1)) n' (succ_chain_fam M0 ((s + 1) + ↑n')) :=
      ih (s + 1)
    exact CanonicalTask_forward.step h_succ ih'

/--
Build CanonicalTask_backward from the Succ-chain.

For any n > 0, we have CanonicalTask_backward (succ_chain_fam M0 s) n (succ_chain_fam M0 (s - n)).

The proof uses that backward_chain_pred gives Succ in reverse direction.
-/
theorem succ_chain_gives_canonical_backward (M0 : SerialMCS) (s : Int) (n : Nat) :
    CanonicalTask_backward (succ_chain_fam M0 s) n (succ_chain_fam M0 (s - n)) := by
  induction n with
  | zero =>
    have h : s - (0 : Nat) = s := by omega
    rw [h]
    exact CanonicalTask_backward.base
  | succ n' ih =>
    have h_eq : s - (↑(n' + 1) : Int) = (s - ↑n') - 1 := by omega
    rw [h_eq]
    -- CanonicalTask_backward s (n'+1) (s - n' - 1)
    -- requires Succ (s-n'-1) w and CanonicalTask_backward s n' w
    -- We have ih: CanonicalTask_backward s n' (s - n')
    -- We need: Succ (s-n'-1) (s-n')
    -- Note: succ_chain_fam_succ gives Succ n (n+1)
    -- So Succ (s-n'-1) (s-n') follows from succ_chain_fam_succ (s-n'-1)
    have h_succ : Succ (succ_chain_fam M0 ((s - ↑n') - 1)) (succ_chain_fam M0 (s - ↑n')) := by
      have h := succ_chain_fam_succ M0 ((s - ↑n') - 1)
      have h2 : (s - ↑n' - 1) + 1 = s - ↑n' := by omega
      rw [h2] at h
      exact h
    exact CanonicalTask_backward.step h_succ ih

/--
CanonicalTask is satisfied by the Succ-chain for s ≤ t.

For any s ≤ t, we have CanonicalTask (succ_chain_fam M0 s) (t - s) (succ_chain_fam M0 t).

The proof uses:
- For t - s ≥ 0: CanonicalTask_forward via succ_chain_gives_canonical_forward
- For t - s < 0: CanonicalTask_backward (but this won't happen since s ≤ t)
-/
theorem succ_chain_canonical_task (M0 : SerialMCS) (s t : Int) (h_le : s ≤ t) :
    CanonicalTask (succ_chain_fam M0 s) (t - s) (succ_chain_fam M0 t) := by
  have h_diff_nonneg : 0 ≤ t - s := Int.sub_nonneg.mpr h_le
  obtain ⟨n, hn⟩ := Int.eq_ofNat_of_zero_le h_diff_nonneg
  -- t - s = n (as Nat), so t = s + n
  have h_t_eq : t = s + n := by omega
  subst h_t_eq
  -- CanonicalTask (fam s) (s + n - s) (fam (s + n))
  -- = CanonicalTask (fam s) n (fam (s + n))
  have h_diff : (s + ↑n) - s = ↑n := by omega
  rw [h_diff]
  -- For n : Nat, CanonicalTask _ n _ = CanonicalTask_forward _ n _
  simp only [CanonicalTask_of_nat]
  exact succ_chain_gives_canonical_forward M0 s n

/-!
## WorldHistory Construction

Build a WorldHistory from the Succ-chain family.
-/

/--
WorldHistory from a Succ-chain.

The history has:
- Domain: full Int (all times are in domain)
- States: succ_chain_fam M0 t for each time t
- Convexity: trivially satisfied (full domain)
- Respects task: follows from succ_chain_canonical_task
-/
noncomputable def succ_chain_history (M0 : SerialMCS) : WorldHistory CanonicalTaskTaskFrame where
  domain := fun _ => True
  convex := by
    intros x z _ _ y _ _
    trivial
  states := fun t _ => succ_chain_fam M0 t
  respects_task := by
    intros s t _ _ h_le
    -- Goal: CanonicalTaskTaskFrame.task_rel (states s _) (t - s) (states t _)
    -- = CanonicalTask (succ_chain_fam M0 s) (t - s) (succ_chain_fam M0 t)
    exact succ_chain_canonical_task M0 s t h_le

/--
The WorldHistory respects the task relation via CanonicalTask.
-/
theorem succ_chain_history_respects_task (M0 : SerialMCS) (s t : Int) (h_le : s ≤ t) :
    CanonicalTask (succ_chain_fam M0 s) (t - s) (succ_chain_fam M0 t) :=
  succ_chain_canonical_task M0 s t h_le

end Bimodal.Metalogic.Bundle
