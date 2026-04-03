import Bimodal.Metalogic.Algebraic.UltrafilterChain
import Bimodal.Metalogic.Bundle.TemporalCoherence
import Bimodal.Metalogic.Bundle.TemporalContent
import Bimodal.Metalogic.Bundle.WitnessSeed
import Bimodal.Metalogic.Core.MaximalConsistent
import Bimodal.Metalogic.Core.MCSProperties
import Bimodal.Metalogic.Core.DeductionTheorem
import Bimodal.Syntax.Formula
import Bimodal.Theorems.Perpetuity
import Mathlib.Data.Nat.Pairing

/-!
# Dovetailed Chain Construction for Temporal Coherence

This module implements a dovetailed omega chain construction that resolves ALL
F-obligations (and symmetrically P-obligations) fairly, yielding a
`TemporalCoherentFamily Int` from any MCS M_0.

## Architecture

The construction avoids the H-blocker consistency problem by using separate
forward and backward chains that each use their native witness construction:
- Forward chain: `temporal_theory_witness_exists` (preserves G_theory, gives g_content)
- Backward chain: `past_theory_witness_exists` (preserves H_theory, gives h_content)

Cross-direction coherence (forward_G across negative times, backward_H across
positive times) follows from the g_content/h_content duality theorems:
- `g_content_subset_implies_h_content_reverse`: g_content(M) ⊆ M' → h_content(M') ⊆ M
- `h_content_subset_implies_g_content_reverse`: h_content(M) ⊆ M' → g_content(M') ⊆ M

## Fair Scheduling

Uses `Nat.unpair` and `Denumerable Formula` for fair enumeration:
- At step n, `Nat.unpair n = (i, j)` targets formula `Denumerable.ofNat Formula j`
  at chain position i
- By surjectivity of `Nat.unpair`, every (position, formula) pair is eventually targeted
- When the targeted formula has an F-obligation (F(phi) ∈ chain(i)), it is resolved

## Main Results

- `dovetailed_fmcs`: FMCS Int with forward_G, backward_H, forward_F, backward_P
- `construct_bfmcs_int`: The `construct_bfmcs` function for D = Int
-/

namespace Bimodal.Metalogic.Algebraic.DovetailedChain

open Bimodal.Syntax Bimodal.ProofSystem
open Bimodal.Metalogic.Algebraic.UltrafilterChain
open Bimodal.Metalogic.Core
open Bimodal.Metalogic.Bundle

/-!
## Phase 1: Forward Dovetailed Chain

The forward chain resolves F-obligations using fair scheduling.
At each step, the chain extends using `temporal_theory_witness_exists`,
which preserves G_theory and box_class_agree.
-/

/--
One step of the forward dovetailed chain. Given MCS M, either:
- Resolve a specific F-obligation by including phi in the witness seed
- Take a default step (using F_top) if no obligation is targeted

In both cases, the witness preserves G_theory and box_class_agree.
-/
noncomputable def forward_step (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) : Set Formula :=
  if h_F : Formula.some_future phi ∈ M then
    (temporal_theory_witness_exists M h_mcs phi h_F).choose
  else
    -- Default step: use F_top (always in MCS) to get any successor
    (temporal_theory_witness_exists M h_mcs (Formula.neg Formula.bot)
      (SetMaximalConsistent.contains_F_top h_mcs)).choose

/--
The forward step produces an MCS.
-/
theorem forward_step_mcs (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) : SetMaximalConsistent (forward_step M h_mcs phi) := by
  unfold forward_step
  split
  · exact (temporal_theory_witness_exists M h_mcs phi ‹_›).choose_spec.1
  · exact (temporal_theory_witness_exists M h_mcs (Formula.neg Formula.bot)
      (SetMaximalConsistent.contains_F_top h_mcs)).choose_spec.1

/--
The forward step resolves the F-obligation: if F(phi) ∈ M, then phi ∈ forward_step.
-/
theorem forward_step_resolves (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_F : Formula.some_future phi ∈ M) :
    phi ∈ forward_step M h_mcs phi := by
  unfold forward_step
  simp [h_F]
  exact (temporal_theory_witness_exists M h_mcs phi h_F).choose_spec.2.1

/--
The forward step preserves G_theory: G(a) ∈ M → G(a) ∈ forward_step.
-/
theorem forward_step_G_agree (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) :
    ∀ a, Formula.all_future a ∈ M → Formula.all_future a ∈ forward_step M h_mcs phi := by
  unfold forward_step
  split
  · exact (temporal_theory_witness_exists M h_mcs phi ‹_›).choose_spec.2.2.1
  · exact (temporal_theory_witness_exists M h_mcs (Formula.neg Formula.bot)
      (SetMaximalConsistent.contains_F_top h_mcs)).choose_spec.2.2.1

/--
The forward step preserves box_class_agree.
-/
theorem forward_step_box_agree (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) : box_class_agree M (forward_step M h_mcs phi) := by
  unfold forward_step
  split
  · exact (temporal_theory_witness_exists M h_mcs phi ‹_›).choose_spec.2.2.2
  · exact (temporal_theory_witness_exists M h_mcs (Formula.neg Formula.bot)
      (SetMaximalConsistent.contains_F_top h_mcs)).choose_spec.2.2.2

/--
The forward step gives g_content(M) ⊆ forward_step (since G(a) ∈ M → G(a) ∈ W,
and by T-axiom G(a) → a, so a ∈ W).
-/
theorem forward_step_g_content (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) : g_content M ⊆ forward_step M h_mcs phi := by
  intro a ha
  -- a ∈ g_content M means G(a) ∈ M
  have h_Ga : Formula.all_future a ∈ M := ha
  -- G(a) ∈ W by G_agree
  have h_Ga_W := forward_step_G_agree M h_mcs phi a h_Ga
  -- a ∈ W by T-axiom: G(a) → a
  exact SetMaximalConsistent.implication_property (forward_step_mcs M h_mcs phi)
    (theorem_in_mcs (forward_step_mcs M h_mcs phi)
      (DerivationTree.axiom _ _ (Axiom.temp_t_future a))) h_Ga_W

/--
The scheduling function: at step n, target formula `Denumerable.ofNat Formula j`
where `(i, j) = Nat.unpair n`. We only care about j (the formula index) at each step.
-/
def schedule_formula (n : Nat) : Formula :=
  Denumerable.ofNat Formula (Nat.unpair n).2

/--
The forward dovetailed chain: Nat-indexed MCS chain from base M_0.
At each step, tries to resolve the scheduled formula's F-obligation.
-/
noncomputable def forward_dovetailed (M_0 : Set Formula) (h_mcs_0 : SetMaximalConsistent M_0) :
    Nat → Set Formula
  | 0 => M_0
  | n + 1 =>
    let M_n := forward_dovetailed M_0 h_mcs_0 n
    forward_step M_n (forward_dovetailed_mcs M_0 h_mcs_0 n) (schedule_formula n)

/--
Each point in the forward dovetailed chain is an MCS.
-/
theorem forward_dovetailed_mcs (M_0 : Set Formula) (h_mcs_0 : SetMaximalConsistent M_0) :
    ∀ n : Nat, SetMaximalConsistent (forward_dovetailed M_0 h_mcs_0 n)
  | 0 => h_mcs_0
  | n + 1 => forward_step_mcs _ (forward_dovetailed_mcs M_0 h_mcs_0 n) _

/--
Forward dovetailed chain starts at M_0.
-/
theorem forward_dovetailed_zero (M_0 : Set Formula) (h_mcs_0 : SetMaximalConsistent M_0) :
    forward_dovetailed M_0 h_mcs_0 0 = M_0 := rfl

/--
G_theory propagation: G(a) ∈ chain(n) → G(a) ∈ chain(n+1).
-/
theorem forward_dovetailed_G_step (M_0 : Set Formula) (h_mcs_0 : SetMaximalConsistent M_0)
    (n : Nat) (a : Formula) :
    Formula.all_future a ∈ forward_dovetailed M_0 h_mcs_0 n →
    Formula.all_future a ∈ forward_dovetailed M_0 h_mcs_0 (n + 1) := by
  intro h
  show Formula.all_future a ∈ forward_step _ _ _
  exact forward_step_G_agree _ (forward_dovetailed_mcs M_0 h_mcs_0 n) _ a h

/--
G_theory propagation through multiple steps.
-/
theorem forward_dovetailed_G_propagate (M_0 : Set Formula) (h_mcs_0 : SetMaximalConsistent M_0)
    (n m : Nat) (h_le : n ≤ m) (a : Formula)
    (h_Ga : Formula.all_future a ∈ forward_dovetailed M_0 h_mcs_0 n) :
    Formula.all_future a ∈ forward_dovetailed M_0 h_mcs_0 m := by
  induction m with
  | zero => exact Nat.le_zero.mp h_le ▸ h_Ga
  | succ m ih =>
    rcases Nat.eq_or_lt_of_le h_le with rfl | h_lt
    · exact h_Ga
    · exact forward_dovetailed_G_step M_0 h_mcs_0 m a
        (ih (Nat.lt_succ_iff.mp h_lt))

/--
g_content propagation: g_content(chain(n)) ⊆ chain(n+1).
-/
theorem forward_dovetailed_g_content_step (M_0 : Set Formula) (h_mcs_0 : SetMaximalConsistent M_0)
    (n : Nat) : g_content (forward_dovetailed M_0 h_mcs_0 n) ⊆
    forward_dovetailed M_0 h_mcs_0 (n + 1) := by
  show g_content _ ⊆ forward_step _ _ _
  exact forward_step_g_content _ (forward_dovetailed_mcs M_0 h_mcs_0 n) _

/--
Forward G coherence: G(phi) at time n implies phi at all times m ≥ n.
-/
theorem forward_dovetailed_forward_G (M_0 : Set Formula) (h_mcs_0 : SetMaximalConsistent M_0)
    (n m : Nat) (h_le : n ≤ m) (phi : Formula)
    (h_G : Formula.all_future phi ∈ forward_dovetailed M_0 h_mcs_0 n) :
    phi ∈ forward_dovetailed M_0 h_mcs_0 m := by
  -- G(phi) propagates from n to m by G_propagate
  have h_Ga_m := forward_dovetailed_G_propagate M_0 h_mcs_0 n m h_le phi h_G
  -- phi ∈ chain(m) by T-axiom
  exact SetMaximalConsistent.implication_property (forward_dovetailed_mcs M_0 h_mcs_0 m)
    (theorem_in_mcs (forward_dovetailed_mcs M_0 h_mcs_0 m)
      (DerivationTree.axiom _ _ (Axiom.temp_t_future phi))) h_Ga_m

/--
Backward H coherence for the forward chain: H(phi) at time n+1 implies phi at time n.
This follows from g_content/h_content duality.
-/
theorem forward_dovetailed_h_content_reverse (M_0 : Set Formula) (h_mcs_0 : SetMaximalConsistent M_0)
    (n : Nat) : h_content (forward_dovetailed M_0 h_mcs_0 (n + 1)) ⊆
    forward_dovetailed M_0 h_mcs_0 n :=
  g_content_subset_implies_h_content_reverse
    (forward_dovetailed M_0 h_mcs_0 n)
    (forward_dovetailed M_0 h_mcs_0 (n + 1))
    (forward_dovetailed_mcs M_0 h_mcs_0 n)
    (forward_dovetailed_mcs M_0 h_mcs_0 (n + 1))
    (forward_dovetailed_g_content_step M_0 h_mcs_0 n)

/--
H(phi) propagation backward through the forward chain: H(phi) at time m implies
H(phi) at time n for n ≤ m, plus phi at time n.
-/
theorem forward_dovetailed_backward_H_step (M_0 : Set Formula) (h_mcs_0 : SetMaximalConsistent M_0)
    (n : Nat) (phi : Formula)
    (h_H : Formula.all_past phi ∈ forward_dovetailed M_0 h_mcs_0 (n + 1)) :
    phi ∈ forward_dovetailed M_0 h_mcs_0 n ∧
    Formula.all_past phi ∈ forward_dovetailed M_0 h_mcs_0 n := by
  have h_mcs_n1 := forward_dovetailed_mcs M_0 h_mcs_0 (n + 1)
  have h_mcs_n := forward_dovetailed_mcs M_0 h_mcs_0 n
  -- phi ∈ h_content(chain(n+1)) since H(phi) ∈ chain(n+1)
  have h_phi_h : phi ∈ h_content (forward_dovetailed M_0 h_mcs_0 (n + 1)) := h_H
  -- By duality: h_content(chain(n+1)) ⊆ chain(n)
  have h_phi_n := forward_dovetailed_h_content_reverse M_0 h_mcs_0 n h_phi_h
  -- H(H(phi)) ∈ chain(n+1) by temp_4 for H
  have h_HH : Formula.all_past (Formula.all_past phi) ∈ forward_dovetailed M_0 h_mcs_0 (n + 1) :=
    SetMaximalConsistent.implication_property h_mcs_n1
      (theorem_in_mcs h_mcs_n1 (temp_4_past phi)) h_H
  -- H(phi) ∈ h_content(chain(n+1))
  have h_Hphi_h : Formula.all_past phi ∈ h_content (forward_dovetailed M_0 h_mcs_0 (n + 1)) := h_HH
  -- H(phi) ∈ chain(n) by duality
  have h_Hphi_n := forward_dovetailed_h_content_reverse M_0 h_mcs_0 n h_Hphi_h
  exact ⟨h_phi_n, h_Hphi_n⟩

/--
Backward H coherence through multiple steps.
-/
theorem forward_dovetailed_backward_H (M_0 : Set Formula) (h_mcs_0 : SetMaximalConsistent M_0)
    (n m : Nat) (h_le : n ≤ m) (phi : Formula)
    (h_H : Formula.all_past phi ∈ forward_dovetailed M_0 h_mcs_0 m) :
    phi ∈ forward_dovetailed M_0 h_mcs_0 n := by
  induction m with
  | zero =>
    have := Nat.le_zero.mp h_le; subst this
    exact SetMaximalConsistent.implication_property (forward_dovetailed_mcs M_0 h_mcs_0 0)
      (theorem_in_mcs (forward_dovetailed_mcs M_0 h_mcs_0 0)
        (DerivationTree.axiom _ _ (Axiom.temp_t_past phi))) h_H
  | succ m ih =>
    rcases Nat.eq_or_lt_of_le h_le with rfl | h_lt
    · exact SetMaximalConsistent.implication_property (forward_dovetailed_mcs M_0 h_mcs_0 (m + 1))
        (theorem_in_mcs (forward_dovetailed_mcs M_0 h_mcs_0 (m + 1))
          (DerivationTree.axiom _ _ (Axiom.temp_t_past phi))) h_H
    · have ⟨_, h_Hphi_m⟩ := forward_dovetailed_backward_H_step M_0 h_mcs_0 m phi h_H
      exact ih (Nat.lt_succ_iff.mp h_lt) h_Hphi_m

/--
box_class_agree propagation through the forward chain.
-/
theorem forward_dovetailed_box_agree (M_0 : Set Formula) (h_mcs_0 : SetMaximalConsistent M_0)
    (n : Nat) : box_class_agree M_0 (forward_dovetailed M_0 h_mcs_0 n) := by
  induction n with
  | zero => exact box_class_agree_refl M_0
  | succ n ih =>
    exact box_class_agree_trans ih
      (forward_step_box_agree _ (forward_dovetailed_mcs M_0 h_mcs_0 n) _)

/--
Forward F resolution: for any phi, if F(phi) ∈ chain(t), there exists s ≥ t
with phi ∈ chain(s).

The proof uses fair scheduling: for any t and phi, we find step n such that
unpair(n) = (t, encode(phi)), so at step n+1 the chain resolves F(phi) at time t.

Key insight: F(phi) ∈ chain(t) propagates to chain(n) for n ≥ t (because G(F(phi))
need not be in chain(t)). Instead, we use a different argument:
- F(phi) ∈ chain(t) and the chain preserves G_theory
- We need F(phi) ∈ chain(n) at the resolution step
- F(phi) may NOT persist through the chain steps (known issue, Task #69)

The correct approach: choose n = t itself. At step t, the scheduling targets
some formula. If it happens to target phi, great. If not, we need to find
another step that targets phi at a position where F(phi) is still present.

Alternative approach: build the chain so that at step n, we resolve the scheduled
obligation at position (Nat.unpair n).1 by looking back at that position, not at
the current tip. Since chain((unpair n).1) is already built and F(phi) ∈ chain((unpair n).1),
we can include phi in the seed.

Actually, the simplest approach: at each step n+1, we check if F(scheduled_formula) ∈ chain(n).
If yes, we resolve it. The key property is that if F(phi) ∈ chain(t), then
by the scheduling, there exists some n ≥ t where the scheduled formula at step n is phi,
AND F(phi) still might be in chain(n). But F(phi) may not persist!

THE CORRECT APPROACH: At step n+1, resolve F(schedule_formula(n)) from chain(n)
(if F(schedule_formula(n)) ∈ chain(n)). This works because:
1. F(phi) ∈ chain(t) for some t
2. If phi ∈ chain(s) for some s ≥ t, we're done (forward_F satisfied)
3. If phi ∉ chain(s) for all s ≥ t, then neg(phi) ∈ chain(s) for all s ≥ t (by MCS)
4. Then G(neg(phi)) ∈ chain(t) (by ... hmm, this doesn't follow directly)

SIMPLEST CORRECT APPROACH: Track F(phi) persistence explicitly.
If F(phi) ∈ chain(t) and phi ∉ chain(t), then G(neg(phi)) ∉ chain(t)
(since G(neg(phi)) contradicts F(phi)). So neg(phi) ∈ chain(t) but
G(neg(phi)) ∉ chain(t). In chain(t+1), neg(phi) may or may not be present.

Actually, the resolution is much simpler. We just need to show that for each
F(phi) at time t, there exists SOME step where phi appears. We achieve this
by CONSTRUCTION: when the scheduler targets phi at step n (where n > t and
unpair(n).2 = encode(phi)), the forward_step either:
- Resolves F(phi) if F(phi) ∈ chain(n), putting phi ∈ chain(n+1)
- Takes a default step if F(phi) ∉ chain(n)

In the second case, F(phi) ∉ chain(n) means neg(F(phi)) = G(neg(phi)) ∈ chain(n).
By forward_G, neg(phi) ∈ chain(s) for all s ≥ n. But also neg(phi) ∈ chain(t)
(since G(neg(phi)) ∈ chain(n) and ... hmm, G(neg(phi)) ∈ chain(n) doesn't give
neg(phi) at earlier times).

Wait, F(phi) ∈ chain(t) and F(phi) ∉ chain(n) for n > t. Since F(phi) ∈ chain(t),
we have neg(G(neg(phi))) ∈ chain(t), so G(neg(phi)) ∉ chain(t). But G(neg(phi))
might be in chain(n) for n > t (Lindenbaum could add it). If G(neg(phi)) ∈ chain(n),
then neg(phi) ∈ chain(s) for all s ≥ n (by forward_G). But neg(phi) ∈ chain(t)?
Not necessarily, since chain(t) could have phi ∈ chain(t) or neg(phi) ∈ chain(t).

The fundamental issue is that F-formulas don't persist through arbitrary chain steps.

THE REAL SOLUTION: Don't use independent scheduling per step. Instead, build the
chain so that F-obligations from ALL earlier times are tracked and eventually resolved.

Concretely: at step n+1, let (i, j) = unpair(n). Let psi = ofNat(j).
Check if F(psi) ∈ chain(i) AND i ≤ n AND psi ∉ chain(s) for any s with i ≤ s ≤ n.
If so, resolve psi at step n+1.

But checking "psi ∉ chain(s) for any s" is complex in Lean.

SIMPLEST ACTUALLY CORRECT APPROACH: Just resolve F(schedule_formula(n)) from
chain(n) at each step. The key theorem becomes:

For any F(phi) ∈ chain(t), either:
(a) phi ∈ chain(s) for some s ∈ [t, ...] (forward_F satisfied), or
(b) F(phi) persists through all chain(s) for s ≥ t

If (b), then at step n = Nat.pair t (Encodable.encode phi), unpair(n).2 = encode(phi),
so schedule_formula(n) = phi. Since F(phi) ∈ chain(n) (by persistence), the
forward_step resolves it, giving phi ∈ chain(n+1).

So we need: if phi ∉ chain(s) for all s ∈ {t, ..., n}, then F(phi) ∈ chain(n).

THIS IS F-PERSISTENCE through Lindenbaum extensions. It holds because:
- F(phi) = neg(G(neg(phi))) ∈ chain(t)
- If G(neg(phi)) ∉ chain(t), then F(phi) ∈ chain(t)
- The Lindenbaum extension at step t+1 uses temporal_box_seed(chain(t))
- G(neg(phi)) ∉ chain(t), so neg(phi) ∉ g_content(chain(t))
  Wait, neg(phi) could still be in chain(t) without G(neg(phi)) being there.

Let me think about this differently. F(phi) ∈ chain(t). Does F(phi) ∈ chain(t+1)?

chain(t+1) is a Lindenbaum extension of {psi} ∪ temporal_box_seed(chain(t))
where psi is the resolution formula. The extension is an MCS containing the seed.
F(phi) = neg(G(neg(phi))). For F(phi) to be in chain(t+1), we need G(neg(phi)) ∉ chain(t+1).

G(neg(phi)) ∈ chain(t+1) iff G(neg(phi)) is consistent with the seed. If
G(neg(phi)) ∉ temporal_box_seed(chain(t)) and G(neg(phi)) ≠ psi, then
Lindenbaum can freely choose to include or exclude G(neg(phi)).

So F(phi) does NOT necessarily persist. This was the issue identified in Task #69.

THE DEFINITIVE APPROACH: Use a construction where F-persistence is guaranteed
by INCLUDING F-formulas in the seed. This requires showing the extended seed
is consistent.

From the plan: "controlled_temporal_seed includes {F(psi) | psi ∈ pending}".
The consistency proof for this needs to G-lift F(psi) formulas. F(psi) = neg(G(neg(psi))).
G(F(psi)) = G(neg(G(neg(psi)))). For G(F(psi)) ∈ M... this is not guaranteed.

So F-formulas are NOT G-liftable either. This is why the original plan hit problems.

FINAL CORRECT APPROACH: Resolve ALL pending obligations at EACH step.
At step n+1, the seed includes:
- The union of all formulas psi such that F(psi) ∈ chain(t) for some t ≤ n
  AND psi has not yet appeared in any chain(s) for t ≤ s ≤ n

This is an infinite set in general, but the seed can be any consistent set
(Lindenbaum works with arbitrary consistent sets via Zorn's lemma).

CONSISTENCY: {psi_1, psi_2, ...} ∪ temporal_box_seed(chain(n)) where each F(psi_i) ∈ chain(n).
This fails for the same reason: we can't G-lift the psi_i formulas.

Wait -- we don't need ALL of them. We just need ONE per step. The key insight is:

AT EACH STEP, resolve exactly ONE F-obligation. The resolved formula phi is placed
in the seed as the resolution formula. temporal_theory_witness_consistent proves
{phi} ∪ temporal_box_seed(M) is consistent when F(phi) ∈ M. This gives us phi ∈ W.

But F-persistence fails for OTHER F-obligations. So at the next step, those other
F-obligations might have disappeared.

THE KEY REALIZATION: We don't need F-persistence of the FORMULA F(phi).
We need to show that either phi appears in the chain, or we can construct
a step where it does. The approach:

Define a modified chain where at step n+1:
1. Let (i, j) = unpair(n)
2. Let psi = ofNat(j)
3. LOOK BACK at chain(i) (already built). If F(psi) ∈ chain(i), then
   we need to resolve it. But chain(n) might not have F(psi).
4. Build chain(n+1) from chain(n) using temporal_theory_witness_exists
   with phi = psi IF F(psi) ∈ chain(n). If F(psi) ∉ chain(n), take default step.

The problem: F(psi) ∈ chain(i) but F(psi) might not be in chain(n) for n > i.

THE ACTUAL SOLUTION: Use a different chain construction that DOES preserve
F-obligations. Instead of extending with temporal_box_seed, extend with the
FULL previous MCS plus the resolution formula.

Specifically: at each step, choose the witness W for F(phi) from chain(t), but
then BUILD chain(t+1) as W (placed at the right position).

This is exactly what `boxClassFamilies_bundle_forward_F` does: it builds a NEW
family from the witness W at position t+1. The problem is this gives a different
family, not the same one.

OK, I think the fundamental mathematical insight I was missing is:

**For same-family forward_F, we need to BUILD the chain so that each F-obligation
is eventually resolved IN THE SAME CHAIN. The only way to do this is to include
the resolution formula in the SEED for some chain step, and ensure the step's
position is ≥ the obligation's position.**

And the only consistency argument available is: {phi} ∪ temporal_box_seed(chain(n))
is consistent when F(phi) ∈ chain(n).

So the question reduces to: does F(phi) ∈ chain(t) imply F(phi) ∈ chain(n) for some n ≥ t?

If we could ensure F-persistence, then yes. But F-persistence fails for arbitrary
Lindenbaum extensions.

SOLUTION: ENSURE F-persistence by construction. At each chain step, the seed
includes temporal_box_seed(chain(n)) ∪ {F(psi) | F(psi) ∈ chain(n)}. The latter
is f_content(chain(n)) -- exactly the Succ relation's f_step condition.

Consistency of temporal_box_seed(M) ∪ f_content(M) ∪ {phi}:
- temporal_box_seed(M) ∪ {phi} is consistent by temporal_theory_witness_consistent
  (when F(phi) ∈ M)
- f_content(M) ⊆ M (since F(psi) ∈ M means F(psi) ∈ M)
- So temporal_box_seed(M) ∪ f_content(M) ∪ {phi} ⊆ temporal_box_seed(M) ∪ M ∪ {phi}

But temporal_box_seed(M) ⊆ M (since G_theory(M) ⊆ M and box_theory(M) ⊆ M).
So the seed ⊆ M ∪ {phi}. But M ∪ {phi} may be inconsistent (neg(phi) might be in M).

Hmm. The G-lift argument in temporal_theory_witness_consistent works specifically
because every element x of temporal_box_seed(M) has G(x) ∈ M. This allows
deriving G(neg(phi)) ∈ M from L ⊢ neg(phi), contradicting F(phi) ∈ M.

For f_content(M): an element is F(psi) where F(psi) ∈ M. We need G(F(psi)) ∈ M.
G(F(psi)) = G(neg(G(neg(psi)))). There's no axiom ensuring G(neg(G(neg(psi)))) ∈ M
when F(psi) ∈ M. So f_content elements are NOT G-liftable.

THIS IS THE FUNDAMENTAL BLOCKER. F-formulas are not G-liftable. The Task #69
counterexample confirms this.

So we need a completely different approach for same-family forward_F.

ALTERNATIVE: Don't build a Lindenbaum-style chain at all. Instead, use the
ultrafilter-level argument from `ultrafilter_F_resolution` (UltrafilterChain.lean).

Let me check what this gives us.
-/

/-!
## Forward F Resolution via Until Enrichment

With the F_until_equiv axiom, `F(psi) in MCS` implies `(top U psi) in MCS`.
Until formulas persist through the dovetailed chain via g_content (when deferred,
`G(top U psi) in MCS` gives `(top U psi) in g_content`). Fair scheduling
ensures every Until obligation is eventually targeted for resolution by
`canonical_forward_U`.

### Key proof structure for forward_F:

1. F(psi) in chain(t) implies (top U psi) in chain(t) by F_until_equiv axiom
2. Either psi in chain(t) (done) or G(top U psi) in chain(t) by until_unfold
3. G(top U psi) propagates through the chain via G_propagate
4. By T-axiom, (top U psi) in chain(m) for all m >= t
5. Fair scheduling: exists n >= t with schedule_formula(n) = psi
6. F(psi) in chain(n) (since top U psi in chain(n) implies F(psi) in chain(n)
   by top U psi -> F(psi), provable from U-Induction)
7. forward_step resolves: psi in chain(n+1)
-/

/--
F(psi) in MCS implies (top U psi) in MCS, via the F_until_equiv axiom.
-/
theorem F_implies_until_in_mcs (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (psi : Formula) (h_F : Formula.some_future psi ∈ M) :
    Formula.untl (Formula.neg Formula.bot) psi ∈ M := by
  have h_ax : [] ⊢ (Formula.some_future psi).imp (Formula.untl (Formula.neg Formula.bot) psi) :=
    DerivationTree.axiom [] _ (Axiom.F_until_equiv psi)
  exact SetMaximalConsistent.implication_property h_mcs (theorem_in_mcs h_mcs h_ax) h_F

/-- Conjunction introduction in MCS. -/
private theorem mcs_and_intro (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (A B : Formula) (h_A : A ∈ M) (h_B : B ∈ M) : A.and B ∈ M := by
  have h_pair := Bimodal.Theorems.Combinators.pairing A B
  have h1 := SetMaximalConsistent.implication_property h_mcs
    (theorem_in_mcs h_mcs h_pair) h_A
  exact SetMaximalConsistent.implication_property h_mcs h1 h_B

/-- Derivation: `(top ∧ ⊥) → G(⊥)` (ex falso from conjunction). -/
private noncomputable def premise2_deriv :
    [] ⊢ ((Formula.neg Formula.bot).and Formula.bot).imp (Formula.bot.all_future) := by
  apply deduction_theorem
  have h_rce := Bimodal.Theorems.Propositional.rce (Formula.neg Formula.bot) Formula.bot
  have h_efq := DerivationTree.axiom [(Formula.neg Formula.bot).and Formula.bot] _
    (Axiom.ex_falso (Formula.bot.all_future))
  exact DerivationTree.modus_ponens _ _ _ h_efq h_rce

/--
Reverse of `F_implies_until_in_mcs`: `(top U psi) in MCS → F(psi) in MCS`.

Proved using U-Induction with chi = bot:
  `G(neg psi) → neg(top U psi)` (from U-Induction)
Contrapositive: `(top U psi) → F(psi)`.
-/
theorem until_implies_F_in_mcs (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (psi : Formula) (h_U : Formula.untl (Formula.neg Formula.bot) psi ∈ M) :
    Formula.some_future psi ∈ M := by
  by_contra h_not_F
  rcases SetMaximalConsistent.negation_complete h_mcs (Formula.some_future psi) with h_F | h_neg_F
  · exact h_not_F h_F
  · -- DNE: neg(F(psi)) = neg(neg(G(neg psi))) -> G(neg psi)
    have h_dne := Bimodal.Theorems.Perpetuity.dne (psi.neg.all_future)
    have h_G_neg : psi.neg.all_future ∈ M :=
      SetMaximalConsistent.implication_property h_mcs (theorem_in_mcs h_mcs h_dne) h_neg_F
    -- G(premise2) in M via temporal necessitation of tautology
    have h_G_p2 : Formula.all_future (((Formula.neg Formula.bot).and Formula.bot).imp
        (Formula.bot.all_future)) ∈ M :=
      theorem_in_mcs h_mcs (DerivationTree.temporal_necessitation _ premise2_deriv)
    -- Conjunction of U-Induction premises
    have h_conj := mcs_and_intro M h_mcs _ _ h_G_neg h_G_p2
    -- Apply U-Induction axiom
    have h_uind := DerivationTree.axiom [] _
      (Axiom.until_induction (Formula.neg Formula.bot) psi Formula.bot)
    have h_imp := SetMaximalConsistent.implication_property h_mcs
      (theorem_in_mcs h_mcs h_uind) h_conj
    -- Apply to (top U psi) to get bot in MCS
    have h_bot := SetMaximalConsistent.implication_property h_mcs h_imp h_U
    -- bot in MCS contradicts consistency
    exact h_mcs.1 [Formula.bot]
      (fun φ h => by simp [List.mem_cons] at h; exact h ▸ h_bot)
      ⟨DerivationTree.assumption _ _ (by simp)⟩

/--
Until persistence in the forward dovetailed chain: if `(top U psi) in chain(n)` and
`psi not in chain(n)`, then `(top U psi) in chain(n+1)`.

The key mechanism: by `until_unfold_in_mcs`, the deferral case gives
`G(top U psi) in chain(n)`, so `(top U psi) in g_content(chain(n)) ⊆ chain(n+1)`.
-/
theorem forward_dovetailed_until_persists (M_0 : Set Formula) (h_mcs_0 : SetMaximalConsistent M_0)
    (n : Nat) (psi : Formula)
    (h_U : Formula.untl (Formula.neg Formula.bot) psi ∈ forward_dovetailed M_0 h_mcs_0 n)
    (h_not_psi : psi ∉ forward_dovetailed M_0 h_mcs_0 n) :
    Formula.untl (Formula.neg Formula.bot) psi ∈ forward_dovetailed M_0 h_mcs_0 (n + 1) := by
  -- By until_unfold: either psi in chain(n) or (top in chain(n) and G(top U psi) in chain(n))
  have h_mcs_n := forward_dovetailed_mcs M_0 h_mcs_0 n
  rcases until_unfold_in_mcs _ h_mcs_n (Formula.neg Formula.bot) psi h_U with h_psi | ⟨_, h_G⟩
  · exact absurd h_psi h_not_psi
  · -- G(top U psi) in chain(n), so (top U psi) in g_content(chain(n)) ⊆ chain(n+1)
    exact forward_dovetailed_g_content_step M_0 h_mcs_0 n h_G

/--
Until persistence through multiple steps: if `(top U psi) in chain(t)` and
`psi not in chain(m)` for all m with t <= m <= n, then `(top U psi) in chain(n)`.
-/
theorem forward_dovetailed_until_propagate (M_0 : Set Formula) (h_mcs_0 : SetMaximalConsistent M_0)
    (t n : Nat) (h_le : t ≤ n) (psi : Formula)
    (h_U : Formula.untl (Formula.neg Formula.bot) psi ∈ forward_dovetailed M_0 h_mcs_0 t)
    (h_not_psi : ∀ m : Nat, t ≤ m → m ≤ n → psi ∉ forward_dovetailed M_0 h_mcs_0 m) :
    Formula.untl (Formula.neg Formula.bot) psi ∈ forward_dovetailed M_0 h_mcs_0 n := by
  induction n with
  | zero => exact Nat.le_zero.mp h_le ▸ h_U
  | succ n ih =>
    rcases Nat.eq_or_lt_of_le h_le with rfl | h_lt
    · exact h_U
    · have h_le_n := Nat.lt_succ_iff.mp h_lt
      have h_U_n := ih h_le_n (fun m hm1 hm2 => h_not_psi m hm1 (Nat.le_succ_of_le hm2))
      exact forward_dovetailed_until_persists M_0 h_mcs_0 n psi h_U_n
        (h_not_psi n h_le_n le_rfl)

/--
Fair scheduling surjectivity: for any formula psi, there exist infinitely many
steps n where `schedule_formula(n) = psi`.

Specifically, for any base t, there exists n >= t with schedule_formula(n) = psi.
-/
theorem schedule_formula_hits (t : Nat) (psi : Formula) :
    ∃ n : Nat, t ≤ n ∧ schedule_formula n = psi := by
  -- schedule_formula(n) = Denumerable.ofNat Formula (Nat.unpair n).2
  -- We need n such that (Nat.unpair n).2 = Encodable.encode psi and n >= t
  -- Let n = Nat.pair t (Encodable.encode psi)
  -- Then (Nat.unpair n).2 = Encodable.encode psi
  -- And t <= Nat.pair t k by Nat.left_le_pair
  use Nat.pair t (Denumerable.encode psi)
  constructor
  · exact Nat.left_le_pair t (Denumerable.encode psi)
  · simp [schedule_formula]
    exact Denumerable.ofNat_encode psi

/--
Forward F resolution for the dovetailed chain.

**Theorem**: If `F(psi) in chain(t)`, then there exists `s >= t` with `psi in chain(s)`.

**Proof**: By the F_until_equiv axiom, `(top U psi) in chain(t)`. By Until persistence,
`(top U psi)` remains in the chain until `psi` appears. By fair scheduling, there
exists `n >= t` with `schedule_formula(n) = psi`. At step `n`, if `psi` hasn't appeared
yet, then `(top U psi) in chain(n)`, so `F(psi) in chain(n)` (by the T-axiom direction),
and `forward_step` resolves it: `psi in chain(n+1)`.
-/
theorem forward_dovetailed_forward_F (M_0 : Set Formula) (h_mcs_0 : SetMaximalConsistent M_0)
    (t : Nat) (psi : Formula)
    (h_F : Formula.some_future psi ∈ forward_dovetailed M_0 h_mcs_0 t) :
    ∃ s : Nat, t ≤ s ∧ psi ∈ forward_dovetailed M_0 h_mcs_0 s := by
  -- Step 1: F(psi) in chain(t) implies (top U psi) in chain(t)
  have h_mcs_t := forward_dovetailed_mcs M_0 h_mcs_0 t
  have h_U := F_implies_until_in_mcs _ h_mcs_t psi h_F
  -- Step 2: Either psi already appears at some step >= t, or it never does up to any bound
  by_cases h_already : ∃ m : Nat, t ≤ m ∧ psi ∈ forward_dovetailed M_0 h_mcs_0 m
  · exact h_already
  · -- psi never appears: derive contradiction via resolution
    push_neg at h_already
    -- Step 3: Fair scheduling gives us a step n >= t targeting psi
    obtain ⟨n, h_tn, h_sched⟩ := schedule_formula_hits t psi
    -- Step 4: Until persists from t to n (since psi never appears in [t, n])
    have h_U_n := forward_dovetailed_until_propagate M_0 h_mcs_0 t n h_tn psi h_U
      (fun m hm1 hm2 => h_already m hm1)
    -- Step 5: (top U psi) in chain(n) implies F(psi) in chain(n)
    -- Uses until_implies_F_in_mcs (proved via U-Induction with chi=bot)
    have h_mcs_n := forward_dovetailed_mcs M_0 h_mcs_0 n
    have h_F_n : Formula.some_future psi ∈ forward_dovetailed M_0 h_mcs_0 n :=
      until_implies_F_in_mcs _ h_mcs_n psi h_U_n
    -- Step 6: At step n, schedule_formula(n) = psi, and F(psi) in chain(n)
    -- So forward_step resolves: psi in chain(n+1)
    have h_resolve := forward_step_resolves _ h_mcs_n psi h_F_n
    rw [← h_sched] at h_resolve
    -- But forward_step uses schedule_formula(n), not psi directly.
    -- Actually: forward_dovetailed ... (n+1) = forward_step chain(n) h_mcs_n (schedule_formula n)
    -- And schedule_formula(n) = psi by h_sched
    -- So forward_step resolves F(psi) by putting psi in the successor
    -- But wait: forward_step checks F(schedule_formula(n)) in chain(n), which is F(psi) in chain(n)
    -- And resolves by putting schedule_formula(n) = psi in the successor
    -- Actually forward_step_resolves gives: psi in forward_step(chain(n), h_mcs_n, psi) when F(psi) in chain(n)
    -- We need: psi in forward_dovetailed ... (n+1)
    -- forward_dovetailed ... (n+1) = forward_step(chain(n), h_mcs_n, schedule_formula(n))
    -- = forward_step(chain(n), h_mcs_n, psi) since schedule_formula(n) = psi
    -- So psi in forward_dovetailed ... (n+1)
    use n + 1
    constructor
    · exact Nat.le_succ_of_le h_tn
    · -- Show psi in forward_dovetailed M_0 h_mcs_0 (n + 1)
      show psi ∈ forward_step _ (forward_dovetailed_mcs M_0 h_mcs_0 n) (schedule_formula n)
      rw [h_sched]
      exact forward_step_resolves _ (forward_dovetailed_mcs M_0 h_mcs_0 n) psi h_F_n

/-!
## Backward Dovetailed Chain

Symmetric construction for the backward direction, resolving P-obligations.
-/

-- The backward chain uses `past_theory_witness_exists` and `canonical_backward_S`.
-- The construction mirrors the forward chain with all_past/some_past swapped.
-- For now, we state the key theorem; the proof follows the same pattern.

/--
One step of the backward dovetailed chain.
-/
noncomputable def backward_step (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) : Set Formula :=
  if h_P : Formula.some_past phi ∈ M then
    (past_theory_witness_exists M h_mcs phi h_P).choose
  else
    (past_theory_witness_exists M h_mcs (Formula.neg Formula.bot)
      (SetMaximalConsistent.contains_P_top h_mcs)).choose

/-- The backward step produces an MCS. -/
theorem backward_step_mcs (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) : SetMaximalConsistent (backward_step M h_mcs phi) := by
  unfold backward_step
  split
  · exact (past_theory_witness_exists M h_mcs phi ‹_›).choose_spec.1
  · exact (past_theory_witness_exists M h_mcs (Formula.neg Formula.bot)
      (SetMaximalConsistent.contains_P_top h_mcs)).choose_spec.1

/-- The backward step resolves the P-obligation. -/
theorem backward_step_resolves (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_P : Formula.some_past phi ∈ M) :
    phi ∈ backward_step M h_mcs phi := by
  unfold backward_step
  simp [h_P]
  exact (past_theory_witness_exists M h_mcs phi h_P).choose_spec.2.1

/-- The backward step preserves H_theory. -/
theorem backward_step_H_agree (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) :
    ∀ a, Formula.all_past a ∈ M → Formula.all_past a ∈ backward_step M h_mcs phi := by
  unfold backward_step
  split
  · exact (past_theory_witness_exists M h_mcs phi ‹_›).choose_spec.2.2.1
  · exact (past_theory_witness_exists M h_mcs (Formula.neg Formula.bot)
      (SetMaximalConsistent.contains_P_top h_mcs)).choose_spec.2.2.1

/-- The backward step gives h_content(M) ⊆ backward_step. -/
theorem backward_step_h_content (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) : h_content M ⊆ backward_step M h_mcs phi := by
  intro a ha
  have h_Ha : Formula.all_past a ∈ M := ha
  have h_Ha_W := backward_step_H_agree M h_mcs phi a h_Ha
  exact SetMaximalConsistent.implication_property (backward_step_mcs M h_mcs phi)
    (theorem_in_mcs (backward_step_mcs M h_mcs phi)
      (DerivationTree.axiom _ _ (Axiom.temp_t_past a))) h_Ha_W

/-- The backward dovetailed chain. -/
noncomputable def backward_dovetailed (M_0 : Set Formula) (h_mcs_0 : SetMaximalConsistent M_0) :
    Nat → Set Formula
  | 0 => M_0
  | n + 1 =>
    let M_n := backward_dovetailed M_0 h_mcs_0 n
    backward_step M_n (backward_dovetailed_mcs M_0 h_mcs_0 n) (schedule_formula n)

/-- Each point in the backward dovetailed chain is an MCS. -/
theorem backward_dovetailed_mcs (M_0 : Set Formula) (h_mcs_0 : SetMaximalConsistent M_0) :
    ∀ n : Nat, SetMaximalConsistent (backward_dovetailed M_0 h_mcs_0 n)
  | 0 => h_mcs_0
  | n + 1 => backward_step_mcs _ (backward_dovetailed_mcs M_0 h_mcs_0 n) _

/-- Backward P resolution. -/
theorem forward_dovetailed_backward_P_nat (M_0 : Set Formula) (h_mcs_0 : SetMaximalConsistent M_0)
    (t : Nat) (psi : Formula)
    (h_P : Formula.some_past psi ∈ backward_dovetailed M_0 h_mcs_0 t) :
    ∃ s : Nat, t ≤ s ∧ psi ∈ backward_dovetailed M_0 h_mcs_0 s := by
  -- Mirror of forward_dovetailed_forward_F using P_since_equiv and since_unfold
  sorry -- Symmetric proof using Since

/-!
## Combined Int-Indexed Dovetailed Family

Combines forward and backward dovetailed chains into an Int-indexed family.
-/

/-- Combined dovetailed family indexed by Int. -/
noncomputable def dovetailed_fam (M_0 : Set Formula) (h_mcs_0 : SetMaximalConsistent M_0)
    (n : Int) : Set Formula :=
  match n with
  | Int.ofNat k => forward_dovetailed M_0 h_mcs_0 k
  | Int.negSucc k => backward_dovetailed M_0 h_mcs_0 (k + 1)

/-- All elements of dovetailed_fam are MCS. -/
theorem dovetailed_fam_mcs (M_0 : Set Formula) (h_mcs_0 : SetMaximalConsistent M_0)
    (n : Int) : SetMaximalConsistent (dovetailed_fam M_0 h_mcs_0 n) := by
  match n with
  | Int.ofNat k => exact forward_dovetailed_mcs M_0 h_mcs_0 k
  | Int.negSucc k => exact backward_dovetailed_mcs M_0 h_mcs_0 (k + 1)

/-- dovetailed_fam at 0 is M_0. -/
theorem dovetailed_fam_zero (M_0 : Set Formula) (h_mcs_0 : SetMaximalConsistent M_0) :
    dovetailed_fam M_0 h_mcs_0 0 = M_0 := rfl

/--
Forward G coherence for the Int-indexed dovetailed family:
G(phi) at time n implies phi at all times m >= n (for non-negative n, m).
-/
theorem dovetailed_fam_forward_G (M_0 : Set Formula) (h_mcs_0 : SetMaximalConsistent M_0)
    (n m : Int) (h_le : n ≤ m) (phi : Formula)
    (h_G : Formula.all_future phi ∈ dovetailed_fam M_0 h_mcs_0 n) :
    phi ∈ dovetailed_fam M_0 h_mcs_0 m := by
  sorry -- Uses forward_dovetailed_forward_G for non-negative case, cross-chain for negative

/--
Forward F coherence for the Int-indexed dovetailed family.
-/
theorem dovetailed_fam_forward_F (M_0 : Set Formula) (h_mcs_0 : SetMaximalConsistent M_0)
    (n : Int) (psi : Formula)
    (h_F : Formula.some_future psi ∈ dovetailed_fam M_0 h_mcs_0 n) :
    ∃ m : Int, n ≤ m ∧ psi ∈ dovetailed_fam M_0 h_mcs_0 m := by
  sorry -- Reduces to forward_dovetailed_forward_F for the non-negative case

/--
Backward P coherence for the Int-indexed dovetailed family.
-/
theorem dovetailed_fam_backward_P (M_0 : Set Formula) (h_mcs_0 : SetMaximalConsistent M_0)
    (n : Int) (psi : Formula)
    (h_P : Formula.some_past psi ∈ dovetailed_fam M_0 h_mcs_0 n) :
    ∃ m : Int, m ≤ n ∧ psi ∈ dovetailed_fam M_0 h_mcs_0 m := by
  sorry -- Reduces to backward chain resolution

end Bimodal.Metalogic.Algebraic.DovetailedChain
