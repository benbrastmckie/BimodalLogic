/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.Stable

/-!
# The Tail Collapse: Liveness Down Either Periodic Tail

`Stable.lean` proves the **forward** half of the tail collapse — a position live down a periodic
tail is in the reference set (`mem_L₀_of_live_tail`, `forall_mem_R₀_of_live_head`) — because that
half is the transfer's own soundness iterated and needs no construction. This module proves the
**reverse** half, which does: every member of the reference set is live at every time down the
tail, by an explicit three-region run.

## Why the reverse half needs a construction

`Live t p` is an existential over *fully fulfilling runs* of the certificate through `(t, p)`.
Nothing about membership in a computed `Finset` produces one, so the reverse half must build a run,
and the run it builds cannot be a single shifted walk: the slice sequence is `G.NB`-periodic only
on the negatives, so a run through a far-left time extends rightward into a region where the
periodicity fails. The construction is therefore in three regions, glued at two seams that are
*consistent* rather than welded —

* on the far side, the reference run of the member itself, **shifted** by the whole distance (a
  shift is not a run, but on this region every time and its shift lie in the periodic half, so
  `posAt_congr` and `succP_congr` transport both fields);
* in the middle, the finite transfer chain the one-period equation supplies, iterated to `k`
  periods and made explicit by `exists_chain_of_mem_iterBack` / `exists_chain_of_mem_iterFwd`;
* on the near side, the reference run of the chain's **endpoint**, which is a member of the
  reference set again and in general *not* the position we started from — which is why the
  construction needs two reference runs and not one.

Fulfilment is not spliced either: each half is read off the one region whose own reference run is
fully fulfilling and which is closed under the direction that half looks in
(`plusBwdFulfilling_of_le`, `plusFwdFulfilling_of_ge`).

## Why the two tails are separate constructions and not one symmetry argument

`PlusSlicedCertificate` is not symmetric under time reversal: `mid` sits at `[0, G.nm)`,
`slice_fwd` is stated at or past `G.nm` and `slice_neg` strictly below `0`, and `runOfPos` asks for
`succP` steps in the one direction the carrier fixes. The right-tail chain therefore runs along
`predP` and is converted by `mem_succP_iff_mem_predP`.

## What this module provides

- `PlusSlicedCertificate.exists_chain_of_mem_iterBack` / `exists_chain_of_mem_iterFwd` — the path
  an iterate witnesses, made explicit
- `PlusSlicedCertificate.tailPos` / `headPos` with their placement and seam lemmas — the
  three-region position families
- `PlusSlicedCertificate.live_of_mem_L₀_tail` / `live_of_mem_R₀_head` — the reverse half
- `PlusSlicedCertificate.tailStable_iff_window` / `tailStable_iff_window_fwd` — **the linchpin**,
  as a biconditional at every time down either periodic tail
- `PlusSlicedCertificate.liveAt_tail_eq_L₀` / `liveAt_winLo_eq_L₀` — the `Finset` equalities a
  checker reads
- `PlusSlicedCertificate.exists_win_live_eq` — every time has a window representative carrying the
  same slice **and** the same live set; this is what a clause stated at a window time costs to
  transport to an arbitrary time, and what the residue indexing of `TailStable` buys

## Tags

plus-language · certificate · time-sliced · liveness · tail-stability
-/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.PlusLanguage

namespace PlusSlicedCertificate

variable {Γ Del : PlusContext}

/-! ## The chain an iterate witnesses

`p ∈ G.iterBack t X k` is an existential about a path, unwound `k` times. This makes the path
explicit, because the converse half has to *walk* it and not merely know it is there. The hypothesis
`X ⊆ G.posAt t` is what pins the chain's last vertex to the reference slice; `L₀` satisfies it by
`liveAt_subset_posAt`.
-/

theorem exists_chain_of_mem_iterBack (G : PlusSlicedCertificate Γ Del) (t : ℤ)
    {X : Finset G.Pos} (hX : X ⊆ G.posAt t) (k : ℕ) {p : G.Pos}
    (hp : p ∈ G.iterBack t X k) :
    ∃ c : ℕ → G.Pos, c 0 = p ∧ c k ∈ X ∧ (∀ j ≤ k, c j ∈ G.posAt (t - (k : ℤ) + (j : ℤ))) ∧
      ∀ j < k, c (j + 1) ∈ G.succP (t - (k : ℤ) + (j : ℤ)) (c j) := by
  induction k generalizing p with
  | zero =>
    refine ⟨fun _ => p, rfl, hp, ?_, by omega⟩
    intro j hj
    have hj0 : j = 0 := by omega
    subst hj0
    simpa using hX hp
  | succ k ih =>
    rw [iterBack_succ, mem_stepBack] at hp
    obtain ⟨hppos, q, hq1, hq2⟩ := hp
    obtain ⟨c, hc0, hck, hcpos, hcstep⟩ := ih hq2
    refine ⟨fun j => Nat.rec p (fun i _ => c i) j, rfl, hck, ?_, ?_⟩
    · intro j hj
      match j with
      | 0 =>
        rw [show t - ((k + 1 : ℕ) : ℤ) + ((0 : ℕ) : ℤ) = t - (k : ℤ) - 1 from by push_cast; omega]
        exact hppos
      | (i + 1) =>
        have h := hcpos i (by omega)
        rw [show t - ((k + 1 : ℕ) : ℤ) + ((i + 1 : ℕ) : ℤ) = t - (k : ℤ) + (i : ℤ) from by
          push_cast; omega]
        exact h
    · intro j hj
      match j with
      | 0 =>
        rw [show t - ((k + 1 : ℕ) : ℤ) + ((0 : ℕ) : ℤ) = t - (k : ℤ) - 1 from by push_cast; omega]
        change c 0 ∈ G.succP (t - (k : ℤ) - 1) p
        rw [hc0]
        exact hq1
      | (i + 1) =>
        have h := hcstep i (by omega)
        rw [show t - ((k + 1 : ℕ) : ℤ) + ((i + 1 : ℕ) : ℤ) = t - (k : ℤ) + (i : ℤ) from by
          push_cast; omega]
        exact h

/-! ## The converse half: every member of `L₀` is live all the way down the tail

The construction, in the three regions the module header names.

* On `u ≤ t₀` (where `t₀ = -G.NB - k * G.NB`) the reference run of `p` itself, **shifted right by
  the whole distance**. A shift is not a run — `LabRun.agrees` and `LabRun.steps` are conditions at
  every time and the slice sequence is periodic only on the negatives — but on this region every
  time and its shift are negative, so `posAt_congr` and `succP_congr` transport both fields.
* On `t₀ ≤ u ≤ -G.NB` the finite `ΦBack`-chain that `G.ΦBack L₀ = L₀` supplies, iterated to `k`
  periods by `iterBack_L₀` and made explicit by `exists_chain_of_mem_iterBack`.
* On `-G.NB ≤ u` the reference run of the chain's **endpoint**, which is a member of `L₀` again and
  in general not `p`. That is why the construction needs two reference runs and not one.

The two seams are consistent rather than glued: at `t₀` the chain's first vertex *is* `p`, and at
`-G.NB` its last vertex *is* where the endpoint's run sits, so `tailPos_le` and `tailPos_ge` each
hold on a *closed* half-line and the case analysis never has a boundary to negotiate.

Fulfilment is not spliced either: `plusBwdFulfilling_of_le` reads the whole backward half off region
one and `plusFwdFulfilling_of_ge` the whole forward half off region three, because each region's own
reference run is fully fulfilling to begin with and each region is closed under the direction its
half looks in.
-/

section Tail

variable {G : PlusSlicedCertificate Γ Del}

/--
**The three-region position family.** `t₀` is the reference time the chain ends at, `m` the whole
shift, `Rp` the reference run through the chain's first vertex, `c` the chain, `Rq` the reference
run through its last.

**Reference-time-generic.** `t₀` was the fixed `-G.NB` when this family was first landed; the truth
lemma's `⊡` clause needs the construction at every residue reference time `-G.NB - r`, so the
reference time is a parameter and the `-G.NB` case is one instance among `G.NBnat` of them.
-/
def tailPos (G : PlusSlicedCertificate Γ Del) (t₀ : ℤ) (Rp Rq : G.LabRun) (c : ℕ → G.Pos)
    (m : ℕ) (u : ℤ) : G.Pos :=
  if u < t₀ - (m : ℤ) then Rp.pos (u + (m : ℤ))
  else if u ≤ t₀ then c (u - (t₀ - (m : ℤ))).toNat
  else Rq.pos u

theorem tailPos_left (G : PlusSlicedCertificate Γ Del) (t₀ : ℤ) (Rp Rq : G.LabRun)
    (c : ℕ → G.Pos) (m : ℕ) (u : ℤ) (hu : u < t₀ - (m : ℤ)) :
    G.tailPos t₀ Rp Rq c m u = Rp.pos (u + (m : ℤ)) := by
  rw [tailPos, if_pos hu]

theorem tailPos_mid (G : PlusSlicedCertificate Γ Del) (t₀ : ℤ) (Rp Rq : G.LabRun)
    (c : ℕ → G.Pos) (m : ℕ) (u : ℤ) (h1 : t₀ - (m : ℤ) ≤ u) (h2 : u ≤ t₀) :
    G.tailPos t₀ Rp Rq c m u = c (u - (t₀ - (m : ℤ))).toNat := by
  rw [tailPos, if_neg (by omega), if_pos h2]

theorem tailPos_right (G : PlusSlicedCertificate Γ Del) (t₀ : ℤ) (Rp Rq : G.LabRun)
    (c : ℕ → G.Pos) (m : ℕ) (u : ℤ) (hu : t₀ < u) :
    G.tailPos t₀ Rp Rq c m u = Rq.pos u := by
  rw [tailPos, if_neg (by omega), if_neg (by omega)]

/-- **On the whole closed left half-line the family is the shifted reference run**, the seam
included. -/
theorem tailPos_le (G : PlusSlicedCertificate Γ Del) (t₀ : ℤ) (Rp Rq : G.LabRun) (c : ℕ → G.Pos)
    (m : ℕ) (hc0 : c 0 = Rp.pos t₀) (u : ℤ) (hu : u ≤ t₀ - (m : ℤ)) :
    G.tailPos t₀ Rp Rq c m u = Rp.pos (u + (m : ℤ)) := by
  rcases lt_or_eq_of_le hu with h | h
  · exact G.tailPos_left t₀ Rp Rq c m u h
  · rw [G.tailPos_mid t₀ Rp Rq c m u (le_of_eq h.symm) (by omega),
      show u - (t₀ - (m : ℤ)) = 0 from by omega,
      show u + (m : ℤ) = t₀ from by omega]
    simpa using hc0

/-- **On the whole closed right half-line the family is the endpoint's reference run**, the seam
included. -/
theorem tailPos_ge (G : PlusSlicedCertificate Γ Del) (t₀ : ℤ) (Rp Rq : G.LabRun) (c : ℕ → G.Pos)
    (m : ℕ) (hcm : c m = Rq.pos t₀) (u : ℤ) (hu : t₀ ≤ u) :
    G.tailPos t₀ Rp Rq c m u = Rq.pos u := by
  rcases lt_or_eq_of_le hu with h | h
  · exact G.tailPos_right t₀ Rp Rq c m u h
  · rw [← h, G.tailPos_mid t₀ Rp Rq c m t₀ (by omega) le_rfl,
      show t₀ - (t₀ - (m : ℤ)) = (m : ℤ) from by omega]
    simpa using hcm

/-! ### The two hypotheses `runOfPos` asks for

Both need the reference time to be **negative**: the far region's shift is justified by
`slice_sub_mul_NB_of_neg`, and the whole region lies at or left of `t₀`, so `t₀ < 0` is exactly what
puts it inside the leftward periodic half.
-/

theorem tailPos_mem_posAt (G : PlusSlicedCertificate Γ Del) {t₀ : ℤ} (ht₀ : t₀ < 0)
    (Rp Rq : G.LabRun) (c : ℕ → G.Pos) (m k : ℕ) (hmc : (m : ℤ) = (k : ℤ) * G.NB)
    (hcpos : ∀ j ≤ m, c j ∈ G.posAt (t₀ - (m : ℤ) + (j : ℤ)))
    (hc0 : c 0 = Rp.pos t₀) (u : ℤ) :
    G.tailPos t₀ Rp Rq c m u ∈ G.posAt u := by
  by_cases h1 : u ≤ t₀ - (m : ℤ)
  · rw [G.tailPos_le t₀ Rp Rq c m hc0 u h1]
    have h := G.slice_sub_mul_NB_of_neg (show u + (m : ℤ) < 0 from by omega) k
    rw [← hmc, show u + (m : ℤ) - (m : ℤ) = u from by omega] at h
    rw [G.posAt_congr h]
    exact Rp.pos_mem_posAt _
  · by_cases h2 : u ≤ t₀
    · rw [G.tailPos_mid t₀ Rp Rq c m u (by omega) h2]
      have h := hcpos (u - (t₀ - (m : ℤ))).toNat (by omega)
      rw [show (((u - (t₀ - (m : ℤ))).toNat : ℕ) : ℤ) = u - (t₀ - (m : ℤ)) from
          Int.toNat_of_nonneg (by omega),
        show t₀ - (m : ℤ) + (u - (t₀ - (m : ℤ))) = u from by omega] at h
      exact h
    · rw [G.tailPos_right t₀ Rp Rq c m u (by omega)]
      exact Rq.pos_mem_posAt _

theorem tailPos_mem_succP (G : PlusSlicedCertificate Γ Del) {t₀ : ℤ} (ht₀ : t₀ < 0)
    (Rp Rq : G.LabRun) (c : ℕ → G.Pos) (m k : ℕ) (hmc : (m : ℤ) = (k : ℤ) * G.NB)
    (hcstep : ∀ j < m, c (j + 1) ∈ G.succP (t₀ - (m : ℤ) + (j : ℤ)) (c j))
    (hc0 : c 0 = Rp.pos t₀) (hcm : c m = Rq.pos t₀) (u : ℤ) :
    G.tailPos t₀ Rp Rq c m (u + 1) ∈ G.succP u (G.tailPos t₀ Rp Rq c m u) := by
  by_cases h1 : u + 1 ≤ t₀ - (m : ℤ)
  · rw [G.tailPos_le t₀ Rp Rq c m hc0 (u + 1) h1, G.tailPos_le t₀ Rp Rq c m hc0 u (by omega)]
    have hs0 := G.slice_sub_mul_NB_of_neg (show u + (m : ℤ) < 0 from by omega) k
    rw [← hmc, show u + (m : ℤ) - (m : ℤ) = u from by omega] at hs0
    have hs1 := G.slice_sub_mul_NB_of_neg (show u + (m : ℤ) + 1 < 0 from by omega) k
    rw [← hmc, show u + (m : ℤ) + 1 - (m : ℤ) = u + 1 from by omega] at hs1
    rw [G.succP_congr hs0 hs1 _]
    have h := Rp.pos_mem_succP (u + (m : ℤ))
    rwa [show u + (m : ℤ) + 1 = u + 1 + (m : ℤ) from by omega] at h
  · by_cases h2 : t₀ ≤ u
    · rw [G.tailPos_ge t₀ Rp Rq c m hcm (u + 1) (by omega), G.tailPos_ge t₀ Rp Rq c m hcm u h2]
      exact Rq.pos_mem_succP u
    · rw [G.tailPos_mid t₀ Rp Rq c m (u + 1) (by omega) (by omega),
        G.tailPos_mid t₀ Rp Rq c m u (by omega) (by omega),
        show (u + 1 - (t₀ - (m : ℤ))).toNat = (u - (t₀ - (m : ℤ))).toNat + 1 from by omega]
      have h := hcstep (u - (t₀ - (m : ℤ))).toNat (by omega)
      rw [show (((u - (t₀ - (m : ℤ))).toNat : ℕ) : ℤ) = u - (t₀ - (m : ℤ)) from
          Int.toNat_of_nonneg (by omega),
        show t₀ - (m : ℤ) + (u - (t₀ - (m : ℤ))) = u from by omega] at h
      exact h

/-! ### The headline

`live_of_mem_liveAt_tail` is the converse the module header names as the reverse half; with
`mem_liveAt_of_live_tail` it makes `tailStable_iff_window` a genuine biconditional at every time
down the periodic tail, at **every** residue reference time and not only at `-G.NB`.
-/

/--
**Every member of the live set at a stable reference time is live all the way down its periodic
tail.**

`t₀` is any negative window time whose live set the whole-period leftward transfer **contains**;
`hstab` is that inclusion at every number of periods, which `liveAt_refBack_subset_iterBack`
supplies at every residue reference time and `L₀_subset_iterBack` at `-G.NB`. The inclusion and
not the equation is what is asked for, because sub-phase 20.4 filtered the backward conjunct and
only its `⊇` half survives at `TailStable` — exactly as on the right tail, where
`live_of_mem_liveAt_head` already asks for the inclusion.
-/
theorem live_of_mem_liveAt_tail (G : PlusSlicedCertificate Γ Del) (hbox : G.BoxLabelFaithful)
    {t₀ : ℤ} (ht₀ : t₀ < 0) (hwin : t₀ ∈ G.winTimes)
    (hstab : ∀ j : ℕ, G.liveAt t₀ ⊆ G.iterBack t₀ (G.liveAt t₀) (j * G.NBnat)) (k : ℕ)
    {p : G.Pos} (hp : p ∈ G.liveAt t₀) : G.Live (t₀ - (k : ℤ) * G.NB) p := by
  obtain ⟨Rp, hRpf, hRpp⟩ := G.exists_path_of_live (G.live_of_mem_liveAt hbox hwin hp)
  have hmc : ((k * G.NBnat : ℕ) : ℤ) = (k : ℤ) * G.NB := by rw [NB, Nat.cast_mul]
  have hpm : p ∈ G.iterBack t₀ (G.liveAt t₀) (k * G.NBnat) := hstab k hp
  obtain ⟨c, hc0, hck, hcpos, hcstep⟩ :=
    G.exists_chain_of_mem_iterBack t₀ (G.liveAt_subset_posAt t₀) (k * G.NBnat) hpm
  obtain ⟨Rq, hRqf, hRqp⟩ := G.exists_path_of_live (G.live_of_mem_liveAt hbox hwin hck)
  set m := k * G.NBnat with hmdef
  have hc0' : c 0 = Rp.pos t₀ := by rw [hc0, hRpp]
  have hcm' : c m = Rq.pos t₀ := hRqp.symm
  have hP := G.tailPos_mem_posAt ht₀ Rp Rq c m k hmc hcpos hc0'
  have hS := G.tailPos_mem_succP ht₀ Rp Rq c m k hmc hcstep hc0' hcm'
  -- the readouts on the two closed half-lines
  have hlabR : ∀ v : ℤ, t₀ ≤ v → (G.tailPos t₀ Rp Rq c m v).2.1 = Rq.lab v := by
    intro v hv
    rw [G.tailPos_ge t₀ Rp Rq c m hcm' v hv]
    exact Rq.pos_snd v
  have hlabL : ∀ v : ℤ, v ≤ t₀ - (m : ℤ) → (G.tailPos t₀ Rp Rq c m v).2.1
      = Rp.lab (v + (m : ℤ)) := by
    intro v hv
    rw [G.tailPos_le t₀ Rp Rq c m hc0' v hv]
    exact Rp.pos_snd _
  -- the run
  have hfwd : PlusFwdFulfilling (fun v => (G.tailPos t₀ Rp Rq c m v).2.1) := by
    refine plusFwdFulfilling_of_ge (coherent_of_pos hbox hP hS)
      (fun v => G.pos_lab_sub (G.tailPos t₀ Rp Rq c m v)) t₀ ?_
    intro s hs g e hu
    rw [hlabR s hs] at hu
    obtain ⟨r, hr1, hr2, hr3⟩ := hRqf.1 s g e hu
    refine ⟨r, hr1, ?_, ?_⟩
    · rw [hlabR r (by omega)]; exact hr2
    · intro v hv1 hv2
      rw [hlabR v (by omega)]
      exact hr3 v hv1 hv2
  have hbwd : PlusBwdFulfilling (fun v => (G.tailPos t₀ Rp Rq c m v).2.1) := by
    refine plusBwdFulfilling_of_le (coherent_of_pos hbox hP hS)
      (fun v => G.pos_lab_sub (G.tailPos t₀ Rp Rq c m v)) (t₀ - (m : ℤ)) ?_
    intro s hs g e hu
    rw [hlabL s hs] at hu
    obtain ⟨r, hr1, hr2, hr3⟩ := hRpf.2 (s + (m : ℤ)) g e hu
    refine ⟨r - (m : ℤ), by omega, ?_, ?_⟩
    · rw [hlabL (r - (m : ℤ)) (by omega), show r - (m : ℤ) + (m : ℤ) = r from by omega]
      exact hr2
    · intro v hv1 hv2
      rw [hlabL v (by omega)]
      exact hr3 (v + (m : ℤ)) (by omega) (by omega)
  have hpos : (runOfPos hbox hP hS).pos (t₀ - (m : ℤ)) = p := by
    rw [runOfPos_pos, G.tailPos_le t₀ Rp Rq c m hc0' _ le_rfl,
      show t₀ - (m : ℤ) + (m : ℤ) = t₀ from by omega, hRpp]
  rw [← hmc, ← hpos]
  exact G.live_of_path (runOfPos hbox hP hS) ⟨hfwd, hbwd⟩ _

/-- **The reverse half at an arbitrary left residue reference time**, which is what the truth
lemma's `⊡` clause consumes off the window. -/
theorem live_of_mem_liveAt_refBack (G : PlusSlicedCertificate Γ Del) (hbox : G.BoxLabelFaithful)
    (hTS : G.TailStable) {r : ℕ} (hr : r < G.NBnat) (k : ℕ) {p : G.Pos}
    (hp : p ∈ G.liveAt (-G.NB - (r : ℤ))) :
    G.Live (-G.NB - (r : ℤ) - (k : ℤ) * G.NB) p :=
  G.live_of_mem_liveAt_tail hbox (G.refBack_neg r) (G.refBack_mem_winTimes hr)
    (G.liveAt_refBack_subset_iterBack hTS hr) k hp

/-- **Every member of `L₀` is live at every time down the periodic left tail** — the `r = 0`
instance. -/
theorem live_of_mem_L₀_tail (G : PlusSlicedCertificate Γ Del) (hbox : G.BoxLabelFaithful)
    (hTS : G.TailStable) (k : ℕ) {p : G.Pos} (hp : p ∈ G.L₀) :
    G.Live (-G.NB - (k : ℤ) * G.NB) p :=
  G.live_of_mem_liveAt_tail hbox (show -G.NB < 0 from by have := G.NB_pos; omega)
    G.neg_NB_mem_winTimes (fun j => G.L₀_subset_iterBack hTS j) k hp

end Tail

/-! ## The right tail

The mirror of everything above, and a **separate construction** rather than a symmetry argument:
`PlusSlicedCertificate` is not symmetric under time reversal (`mid` sits at `[0, G.nm)`, `slice_fwd`
is stated at or past `G.nm` and `slice_neg` strictly below `0`), and `runOfPos` asks for `succP`
steps in the one direction the carrier fixes. So the chain here runs along `predP` and is converted
by `mem_succP_iff_mem_predP`, which is exactly the adjointness that lemma was landed for.
-/

theorem exists_chain_of_mem_iterFwd (G : PlusSlicedCertificate Γ Del) (t : ℤ)
    {X : Finset G.Pos} (hX : X ⊆ G.posAt t) (k : ℕ) {q : G.Pos}
    (hq : q ∈ G.iterFwd t X k) :
    ∃ c : ℕ → G.Pos, c 0 = q ∧ c k ∈ X ∧ (∀ j ≤ k, c j ∈ G.posAt (t + (k : ℤ) - (j : ℤ))) ∧
      ∀ j < k, c (j + 1) ∈ G.predP (t + (k : ℤ) - (j : ℤ)) (c j) := by
  induction k generalizing q with
  | zero =>
    refine ⟨fun _ => q, rfl, hq, ?_, by omega⟩
    intro j hj
    have hj0 : j = 0 := by omega
    subst hj0
    simpa using hX hq
  | succ k ih =>
    rw [iterFwd_succ, mem_stepFwd] at hq
    obtain ⟨hqpos, p, hp1, hp2⟩ := hq
    obtain ⟨c, hc0, hck, hcpos, hcstep⟩ := ih hp2
    refine ⟨fun j => Nat.rec q (fun i _ => c i) j, rfl, hck, ?_, ?_⟩
    · intro j hj
      match j with
      | 0 =>
        rw [show t + ((k + 1 : ℕ) : ℤ) - ((0 : ℕ) : ℤ) = t + (k : ℤ) + 1 from by push_cast; omega]
        exact hqpos
      | (i + 1) =>
        have h := hcpos i (by omega)
        rw [show t + ((k + 1 : ℕ) : ℤ) - ((i + 1 : ℕ) : ℤ) = t + (k : ℤ) - (i : ℤ) from by
          push_cast; omega]
        exact h
    · intro j hj
      match j with
      | 0 =>
        rw [show t + ((k + 1 : ℕ) : ℤ) - ((0 : ℕ) : ℤ) = t + (k : ℤ) + 1 from by push_cast; omega]
        change c 0 ∈ G.predP (t + (k : ℤ) + 1) q
        rw [hc0]
        exact hp1
      | (i + 1) =>
        have h := hcstep i (by omega)
        rw [show t + ((k + 1 : ℕ) : ℤ) - ((i + 1 : ℕ) : ℤ) = t + (k : ℤ) - (i : ℤ) from by
          push_cast; omega]
        exact h

section Head

variable {G : PlusSlicedCertificate Γ Del}

/-- **The three-region position family on the right**, the mirror of `tailPos`, at an arbitrary
reference time `t₁`. -/
def headPos (G : PlusSlicedCertificate Γ Del) (t₁ : ℤ) (Rq Rp : G.LabRun)
    (c : ℕ → G.Pos) (m : ℕ) (u : ℤ) : G.Pos :=
  if t₁ + (m : ℤ) < u then Rq.pos (u - (m : ℤ))
  else if t₁ ≤ u then c (t₁ + (m : ℤ) - u).toNat
  else Rp.pos u

theorem headPos_far (G : PlusSlicedCertificate Γ Del) (t₁ : ℤ) (Rq Rp : G.LabRun)
    (c : ℕ → G.Pos) (m : ℕ) (u : ℤ) (hu : t₁ + (m : ℤ) < u) :
    G.headPos t₁ Rq Rp c m u = Rq.pos (u - (m : ℤ)) := by
  rw [headPos, if_pos hu]

theorem headPos_mid (G : PlusSlicedCertificate Γ Del) (t₁ : ℤ) (Rq Rp : G.LabRun)
    (c : ℕ → G.Pos) (m : ℕ) (u : ℤ) (h1 : u ≤ t₁ + (m : ℤ)) (h2 : t₁ ≤ u) :
    G.headPos t₁ Rq Rp c m u = c (t₁ + (m : ℤ) - u).toNat := by
  rw [headPos, if_neg (by omega), if_pos h2]

theorem headPos_near (G : PlusSlicedCertificate Γ Del) (t₁ : ℤ) (Rq Rp : G.LabRun)
    (c : ℕ → G.Pos) (m : ℕ) (u : ℤ) (hu : u < t₁) : G.headPos t₁ Rq Rp c m u = Rp.pos u := by
  rw [headPos, if_neg (by omega), if_neg (by omega)]

/-- **On the whole closed far half-line the family is the shifted reference run.** -/
theorem headPos_ge (G : PlusSlicedCertificate Γ Del) (t₁ : ℤ) (Rq Rp : G.LabRun) (c : ℕ → G.Pos)
    (m : ℕ) (hc0 : c 0 = Rq.pos t₁) (u : ℤ) (hu : t₁ + (m : ℤ) ≤ u) :
    G.headPos t₁ Rq Rp c m u = Rq.pos (u - (m : ℤ)) := by
  rcases lt_or_eq_of_le hu with h | h
  · exact G.headPos_far t₁ Rq Rp c m u h
  · rw [G.headPos_mid t₁ Rq Rp c m u (le_of_eq h.symm) (by omega),
      show t₁ + (m : ℤ) - u = 0 from by omega,
      show u - (m : ℤ) = t₁ from by omega]
    simpa using hc0

/-- **On the whole closed near half-line the family is the endpoint's reference run.** -/
theorem headPos_le (G : PlusSlicedCertificate Γ Del) (t₁ : ℤ) (Rq Rp : G.LabRun) (c : ℕ → G.Pos)
    (m : ℕ) (hcm : c m = Rp.pos t₁) (u : ℤ) (hu : u ≤ t₁) :
    G.headPos t₁ Rq Rp c m u = Rp.pos u := by
  rcases lt_or_eq_of_le hu with h | h
  · exact G.headPos_near t₁ Rq Rp c m u h
  · rw [h, G.headPos_mid t₁ Rq Rp c m t₁ (by omega) le_rfl,
      show t₁ + (m : ℤ) - t₁ = (m : ℤ) from by omega]
    simpa using hcm

theorem headPos_mem_posAt (G : PlusSlicedCertificate Γ Del) {t₁ : ℤ} (hnm : G.nm ≤ t₁)
    (Rq Rp : G.LabRun) (c : ℕ → G.Pos) (m k : ℕ) (hmc : (m : ℤ) = (k : ℤ) * G.NF)
    (hcpos : ∀ j ≤ m, c j ∈ G.posAt (t₁ + (m : ℤ) - (j : ℤ)))
    (hc0 : c 0 = Rq.pos t₁) (u : ℤ) :
    G.headPos t₁ Rq Rp c m u ∈ G.posAt u := by
  by_cases h1 : t₁ + (m : ℤ) ≤ u
  · rw [G.headPos_ge t₁ Rq Rp c m hc0 u h1]
    have h := G.slice_add_mul_NF_of_ge (show G.nm ≤ u - (m : ℤ) from by omega) k
    rw [← hmc, show u - (m : ℤ) + (m : ℤ) = u from by omega] at h
    rw [G.posAt_congr h]
    exact Rq.pos_mem_posAt _
  · by_cases h2 : t₁ ≤ u
    · rw [G.headPos_mid t₁ Rq Rp c m u (by omega) h2]
      have h := hcpos (t₁ + (m : ℤ) - u).toNat (by omega)
      rw [show (((t₁ + (m : ℤ) - u).toNat : ℕ) : ℤ) = t₁ + (m : ℤ) - u from
          Int.toNat_of_nonneg (by omega),
        show t₁ + (m : ℤ) - (t₁ + (m : ℤ) - u) = u from by omega] at h
      exact h
    · rw [G.headPos_near t₁ Rq Rp c m u (by omega)]
      exact Rp.pos_mem_posAt _

theorem headPos_mem_succP (G : PlusSlicedCertificate Γ Del) {t₁ : ℤ} (hnm : G.nm ≤ t₁)
    (Rq Rp : G.LabRun) (c : ℕ → G.Pos) (m k : ℕ) (hmc : (m : ℤ) = (k : ℤ) * G.NF)
    (hcpos : ∀ j ≤ m, c j ∈ G.posAt (t₁ + (m : ℤ) - (j : ℤ)))
    (hcstep : ∀ j < m, c (j + 1) ∈ G.predP (t₁ + (m : ℤ) - (j : ℤ)) (c j))
    (hc0 : c 0 = Rq.pos t₁) (hcm : c m = Rp.pos t₁) (u : ℤ) :
    G.headPos t₁ Rq Rp c m (u + 1) ∈ G.succP u (G.headPos t₁ Rq Rp c m u) := by
  by_cases h1 : t₁ + (m : ℤ) ≤ u
  · rw [G.headPos_ge t₁ Rq Rp c m hc0 (u + 1) (by omega), G.headPos_ge t₁ Rq Rp c m hc0 u h1]
    have hs0 := G.slice_add_mul_NF_of_ge (show G.nm ≤ u - (m : ℤ) from by omega) k
    rw [← hmc, show u - (m : ℤ) + (m : ℤ) = u from by omega] at hs0
    have hs1 := G.slice_add_mul_NF_of_ge (show G.nm ≤ u - (m : ℤ) + 1 from by omega) k
    rw [← hmc, show u - (m : ℤ) + 1 + (m : ℤ) = u + 1 from by omega] at hs1
    rw [G.succP_congr hs0 hs1 _]
    have h := Rq.pos_mem_succP (u - (m : ℤ))
    rwa [show u - (m : ℤ) + 1 = u + 1 - (m : ℤ) from by omega] at h
  · by_cases h2 : u + 1 ≤ t₁
    · rw [G.headPos_le t₁ Rq Rp c m hcm (u + 1) h2, G.headPos_le t₁ Rq Rp c m hcm u (by omega)]
      exact Rp.pos_mem_succP u
    · rw [G.headPos_mid t₁ Rq Rp c m (u + 1) (by omega) (by omega),
        G.headPos_mid t₁ Rq Rp c m u (by omega) (by omega),
        show (t₁ + (m : ℤ) - u).toNat
          = (t₁ + (m : ℤ) - (u + 1)).toNat + 1 from by omega]
      have hi : ((t₁ + (m : ℤ) - (u + 1)).toNat : ℤ)
          = t₁ + (m : ℤ) - (u + 1) := Int.toNat_of_nonneg (by omega)
      have harith : t₁ + (m : ℤ) - (t₁ + (m : ℤ) - (u + 1)) = u + 1 := by omega
      have hstep := hcstep (t₁ + (m : ℤ) - (u + 1)).toNat (by omega)
      rw [hi, harith] at hstep
      have hp1 : c ((t₁ + (m : ℤ) - (u + 1)).toNat + 1) ∈ G.posAt u := by
        have h := hcpos ((t₁ + (m : ℤ) - (u + 1)).toNat + 1) (by omega)
        rw [show (((t₁ + (m : ℤ) - (u + 1)).toNat + 1 : ℕ) : ℤ)
            = t₁ + (m : ℤ) - u from by push_cast [hi]; omega,
          show t₁ + (m : ℤ) - (t₁ + (m : ℤ) - u) = u from by omega] at h
        exact h
      have hp2 : c ((t₁ + (m : ℤ) - (u + 1)).toNat) ∈ G.posAt (u + 1) := by
        have h := hcpos ((t₁ + (m : ℤ) - (u + 1)).toNat) (by omega)
        rw [hi, harith] at h
        exact h
      exact (G.mem_succP_iff_mem_predP u _ _ hp1 hp2).mpr hstep

/--
**Every member of the live set at a reference time is live at every time up its periodic right
tail**, the mirror of `live_of_mem_liveAt_tail`.

`hstab` is the one-sided `⊇` half of the filtered forward equation, iterated — which is all this
direction consumes — and `liveAt_refFwd_subset_iterFwd` supplies it at every residue reference time.
-/
theorem live_of_mem_liveAt_head (G : PlusSlicedCertificate Γ Del) (hbox : G.BoxLabelFaithful)
    {t₁ : ℤ} (hnm : G.nm ≤ t₁) (hwin : t₁ ∈ G.winTimes)
    (hstab : ∀ j : ℕ, G.liveAt t₁ ⊆ G.iterFwd t₁ (G.liveAt t₁) (j * G.NFnat)) (k : ℕ)
    {q : G.Pos} (hq : q ∈ G.liveAt t₁) : G.Live (t₁ + (k : ℤ) * G.NF) q := by
  have hNF := G.NF_pos
  obtain ⟨Rq, hRqf, hRqp⟩ := G.exists_path_of_live (G.live_of_mem_liveAt hbox hwin hq)
  have hmc : ((k * G.NFnat : ℕ) : ℤ) = (k : ℤ) * G.NF := by rw [NF, Nat.cast_mul]
  have hqm : q ∈ G.iterFwd t₁ (G.liveAt t₁) (k * G.NFnat) := hstab k hq
  obtain ⟨c, hc0, hck, hcpos, hcstep⟩ :=
    G.exists_chain_of_mem_iterFwd t₁ (G.liveAt_subset_posAt t₁) (k * G.NFnat) hqm
  obtain ⟨Rp, hRpf, hRpp⟩ := G.exists_path_of_live (G.live_of_mem_liveAt hbox hwin hck)
  set m := k * G.NFnat with hmdef
  have hc0' : c 0 = Rq.pos t₁ := by rw [hc0, hRqp]
  have hcm' : c m = Rp.pos t₁ := hRpp.symm
  have hP := G.headPos_mem_posAt hnm Rq Rp c m k hmc hcpos hc0'
  have hS := G.headPos_mem_succP hnm Rq Rp c m k hmc hcpos hcstep hc0' hcm'
  have hlabF : ∀ v : ℤ, t₁ + (m : ℤ) ≤ v →
      (G.headPos t₁ Rq Rp c m v).2.1 = Rq.lab (v - (m : ℤ)) := by
    intro v hv
    rw [G.headPos_ge t₁ Rq Rp c m hc0' v hv]
    exact Rq.pos_snd _
  have hlabN : ∀ v : ℤ, v ≤ t₁ → (G.headPos t₁ Rq Rp c m v).2.1 = Rp.lab v := by
    intro v hv
    rw [G.headPos_le t₁ Rq Rp c m hcm' v hv]
    exact Rp.pos_snd v
  have hfwd : PlusFwdFulfilling (fun v => (G.headPos t₁ Rq Rp c m v).2.1) := by
    refine plusFwdFulfilling_of_ge (coherent_of_pos hbox hP hS)
      (fun v => G.pos_lab_sub (G.headPos t₁ Rq Rp c m v)) (t₁ + (m : ℤ)) ?_
    intro s hs g e hu
    rw [hlabF s hs] at hu
    obtain ⟨r, hr1, hr2, hr3⟩ := hRqf.1 (s - (m : ℤ)) g e hu
    refine ⟨r + (m : ℤ), by omega, ?_, ?_⟩
    · rw [hlabF (r + (m : ℤ)) (by omega), show r + (m : ℤ) - (m : ℤ) = r from by omega]
      exact hr2
    · intro v hv1 hv2
      rw [hlabF v (by omega)]
      exact hr3 (v - (m : ℤ)) (by omega) (by omega)
  have hbwd : PlusBwdFulfilling (fun v => (G.headPos t₁ Rq Rp c m v).2.1) := by
    refine plusBwdFulfilling_of_le (coherent_of_pos hbox hP hS)
      (fun v => G.pos_lab_sub (G.headPos t₁ Rq Rp c m v)) t₁ ?_
    intro s hs g e hu
    rw [hlabN s hs] at hu
    obtain ⟨r, hr1, hr2, hr3⟩ := hRpf.2 s g e hu
    refine ⟨r, hr1, ?_, ?_⟩
    · rw [hlabN r (by omega)]; exact hr2
    · intro v hv1 hv2
      rw [hlabN v (by omega)]
      exact hr3 v hv1 hv2
  have hpos : (runOfPos hbox hP hS).pos (t₁ + (m : ℤ)) = q := by
    rw [runOfPos_pos, G.headPos_ge t₁ Rq Rp c m hc0' _ le_rfl,
      show t₁ + (m : ℤ) - (m : ℤ) = t₁ from by omega, hRqp]
  rw [← hmc, ← hpos]
  exact G.live_of_path (runOfPos hbox hP hS) ⟨hfwd, hbwd⟩ _

/-- **The reverse half at an arbitrary right residue reference time**, the mirror of
`live_of_mem_liveAt_refBack`. -/
theorem live_of_mem_liveAt_refFwd (G : PlusSlicedCertificate Γ Del) (hbox : G.BoxLabelFaithful)
    (hTS : G.TailStable) {r : ℕ} (hr : r < G.NFnat) (k : ℕ) {q : G.Pos}
    (hq : q ∈ G.liveAt (G.NM + G.NF + (r : ℤ))) :
    G.Live (G.NM + G.NF + (r : ℤ) + (k : ℤ) * G.NF) q :=
  G.live_of_mem_liveAt_head hbox (G.nm_le_refFwd r) (G.refFwd_mem_winTimes hr)
    (G.liveAt_refFwd_subset_iterFwd hTS hr) k hq

/-- **Every member of `R₀` is live at every time up the periodic right tail** — the `r = 0`
instance. -/
theorem live_of_mem_R₀_head (G : PlusSlicedCertificate Γ Del) (hbox : G.BoxLabelFaithful)
    (hTS : G.TailStable) (k : ℕ) {q : G.Pos} (hq : q ∈ G.R₀) :
    G.Live (G.NM + G.NF + (k : ℤ) * G.NF) q :=
  G.live_of_mem_liveAt_head hbox
    (show G.nm ≤ G.NM + G.NF from by have := G.NF_pos; have := G.nm_le_NM; omega)
    G.nmAddNF_mem_winTimes (fun j => G.R₀_subset_iterFwd hTS j) k hq

end Head

/-! ## `tailStable_iff_window`

The plan's linchpin, now a genuine biconditional at every time down either periodic tail: under
tail-stability the computed reference set `L₀` **is** the true live set at every `-G.NB - k * G.NB`,
and `R₀` at every `G.NM + G.NF + k * G.NF`. The `→` direction is the transfer's soundness iterated
(`mem_L₀_of_live_tail`) and the `←` direction the three-region run (`live_of_mem_L₀_tail`); neither
is a `simp`, and neither would hold without the demand — `Fixture.live_not_determined_by_slice` is
a certificate where the two sides come apart at one period.
-/

/-- **The linchpin, on the left tail.** -/
theorem tailStable_iff_window (G : PlusSlicedCertificate Γ Del) (hbox : G.BoxLabelFaithful)
    (hTS : G.TailStable) (k : ℕ) (p : G.Pos) :
    p ∈ G.L₀ ↔ G.Live (-G.NB - (k : ℤ) * G.NB) p :=
  ⟨fun hp => G.live_of_mem_L₀_tail hbox hTS k hp, fun hp => G.mem_L₀_of_live_tail hTS k hp⟩

/-- **The linchpin, on the right tail.** -/
theorem tailStable_iff_window_fwd (G : PlusSlicedCertificate Γ Del) (hbox : G.BoxLabelFaithful)
    (hTS : G.TailStable) (k : ℕ) (q : G.Pos) :
    q ∈ G.R₀ ↔ G.Live (G.NM + G.NF + (k : ℤ) * G.NF) q :=
  ⟨fun hq => G.live_of_mem_R₀_head hbox hTS k hq, fun hq => G.mem_R₀_of_live_head hTS k hq⟩

/-- **The live set is the same at every period-multiple of the left tail.** The form a checker
reads: `liveAt` at any such time is literally `L₀`. -/
theorem liveAt_tail_eq_L₀ (G : PlusSlicedCertificate Γ Del) (hbox : G.BoxLabelFaithful)
    (hTS : G.TailStable) (k : ℕ) (hw : -G.NB - (k : ℤ) * G.NB ∈ G.winTimes) :
    G.liveAt (-G.NB - (k : ℤ) * G.NB) = G.L₀ := by
  ext p
  rw [G.mem_liveAt_iff_live hbox hw p]
  exact (G.tailStable_iff_window hbox hTS k p).symm

/-- **The window's own left endpoint is the `k = 1` instance**, with equality rather than the
inclusion `liveAt_winLo_subset_L₀` gives on its own. -/
theorem liveAt_winLo_eq_L₀ (G : PlusSlicedCertificate Γ Del) (hbox : G.BoxLabelFaithful)
    (hTS : G.TailStable) : G.liveAt G.winLo = G.L₀ := by
  have hw : -G.NB - ((1 : ℕ) : ℤ) * G.NB = G.winLo := by
    rw [show G.winLo = -2 * G.NB from rfl]; push_cast; omega
  rw [← hw]
  exact G.liveAt_tail_eq_L₀ hbox hTS 1 (by rw [hw]; exact G.winLo_mem_winTimes)

/-! ## Every time has a window representative with the same live set

`exists_win_live_eq` is the form the truth lemma's `⊡` clause consumes, and it is the one obligation
the residue indexing of `TailStable` exists to discharge. The clause is stated at a **window** time
against the computed `G.liveAt`, because that is the only form a checker can evaluate, while the
truth lemma needs it at an **arbitrary** `t` — the `U` / `S` cases send the induction to arbitrary
times and the `⊡` clause's time is pinned by the carrier element `(t, w)`, whose first component
*is* the time, so no shift normalizes it away.

What has to transport is not the slice: that folds freely by `exists_win_eq_slice`, and `slab_congr`
carries the labelling with it. It is the **liveness**, in both inclusions at once, and liveness is
not a function of the slice — `Fixture.live_not_determined_by_slice` is a certificate where two
times carry the same slice, the same positions, and different live sets. So the transport is exactly
what the demand has to buy, and it buys it one residue class at a time: the three regions below are
the residue decomposition itself.
-/

/--
**Every time has a window representative carrying both the same slice and the same live set.**

Left of `-G.NB` the representative is the time's own left residue reference time
(`exists_residue_back`), right of `G.NM + G.NF` its right one (`exists_residue_fwd`), and in between
the time is already a window time and is its own representative. The liveness equivalence is the
residue tail collapse read in both directions: `mem_liveAt_of_live_refBack` with
`live_of_mem_liveAt` for `→`, and `mem_liveAt_of_live` with `live_of_mem_liveAt_refBack` for `←`.
-/
theorem exists_win_live_eq (G : PlusSlicedCertificate Γ Del) (hbox : G.BoxLabelFaithful)
    (hTS : G.TailStable) (t : ℤ) :
    ∃ s : ℤ, s ∈ G.winTimes ∧ G.slice s = G.slice t ∧ ∀ p : G.Pos, (G.Live t p ↔ G.Live s p) := by
  have hB := G.NB_pos
  have hF := G.NF_pos
  have hM := G.NM_nonneg
  have hLo : G.winLo = -2 * G.NB := rfl
  have hHi : G.winHi = G.NM + 2 * G.NF := rfl
  by_cases hleft : t ≤ -G.NB
  · obtain ⟨r, k, hr, hteq⟩ := G.exists_residue_back hleft
    refine ⟨-G.NB - (r : ℤ), G.refBack_mem_winTimes hr, ?_, ?_⟩
    · rw [hteq]
      exact (G.slice_sub_mul_NB_of_neg (G.refBack_neg r) k).symm
    · intro p
      rw [hteq]
      exact ⟨fun hp => G.live_of_mem_liveAt hbox (G.refBack_mem_winTimes hr)
          (G.mem_liveAt_of_live_refBack hTS hr k hp),
        fun hp => G.live_of_mem_liveAt_refBack hbox hTS hr k
          (G.mem_liveAt_of_live (G.refBack_mem_winTimes hr) hp)⟩
  · by_cases hright : G.NM + G.NF ≤ t
    · obtain ⟨r, k, hr, hteq⟩ := G.exists_residue_fwd hright
      refine ⟨G.NM + G.NF + (r : ℤ), G.refFwd_mem_winTimes hr, ?_, ?_⟩
      · rw [hteq]
        exact (G.slice_add_mul_NF_of_ge (G.nm_le_refFwd r) k).symm
      · intro p
        rw [hteq]
        exact ⟨fun hp => G.live_of_mem_liveAt hbox (G.refFwd_mem_winTimes hr)
            (G.mem_liveAt_of_live_refFwd hTS hr k hp),
          fun hp => G.live_of_mem_liveAt_refFwd hbox hTS hr k
            (G.mem_liveAt_of_live (G.refFwd_mem_winTimes hr) hp)⟩
    · exact ⟨t, by rw [G.mem_winTimes]; omega, rfl, fun _ => Iff.rfl⟩

/-- **The computed live set transports off the window too**, the `Finset` form of
`exists_win_live_eq`'s third conjunct at a pair of window times. -/
theorem exists_win_liveAt_eq (G : PlusSlicedCertificate Γ Del) (hbox : G.BoxLabelFaithful)
    (hTS : G.TailStable) (t : ℤ) (ht : t ∈ G.winTimes) :
    ∃ s : ℤ, s ∈ G.winTimes ∧ G.slice s = G.slice t ∧ G.liveAt s = G.liveAt t := by
  obtain ⟨s, hs, hslice, hlive⟩ := G.exists_win_live_eq hbox hTS t
  refine ⟨s, hs, hslice, Finset.ext fun p => ?_⟩
  rw [G.mem_liveAt_iff_live hbox hs, G.mem_liveAt_iff_live hbox ht]
  exact (hlive p).symm

end PlusSlicedCertificate

end FormalSystem.Metalogic.Decidability
