/-
THE CERTIFICATE PRESENTATION SEPARATES REALIZABLE-TYPE CANDIDATES FROM MERELY LOCALLY COHERENT
ONES ON THE COPRIME-CYCLE FIXTURE: the fulfilment condition is EXISTENTIAL and is decided inside
the candidate set by the existential dual of `AUFix` (`euStep`/`euIter`/`euLfp`, with
`eu_mem_lfp_iff_exists_path` reading it as a guarded-path statement); a set LOCAL COHERENCE
ACCEPTS is REJECTED by the certificate at the eventuality `ev = T U psi2` (`coh_accepts_Rev` and
`cert_rejects_Rev`, through the structural `rev_eu_lfp_empty`); the universal and the existential
operators are compiled as DIFFERENT on a cycle with an exit (`au_lfp_ne_eu_lfp_on_exit_graph`:
the universal fixpoint is `{3}`, the existential one is `Finset.univ`); the `box` and `stab`
clauses are PRESENT as checked biconditionals (`certStab`, `certBox`, both conjuncts of
`certAdm`) and are UNEXERCISED on this `stab`-free fixture
(`chi_closure_box_snce_stab_free`), so gate 8 is SIDESTEPPED, NOT passed; and ADEQUACY IS NOT
DISCHARGED -- that these conditions are SUFFICIENT for realizability is an argument in the
research round's report, explicitly marked uncompiled there, and is NOT a theorem here.

## What was asked

The predecessor round landed the set-valued countdown-profile presentation and ran the gate table
against it (`specs/evidence/seam-gluing-ray-product/closure-profile-gate-rerun.lean`,
`nside-modulus-gate.lean`), and the round after that EXHIBITED the adequacy gap rather than
merely scoping it (`realizable-type-adequacy-gap.lean`: a `coh6`-coherent 3-cycle carrying `ev`
at every position and `psi2` at none).  What those rounds left open, and what was asked here, is
the expensive half: a coherence relation that computes REALIZABLE types rather than merely
locally coherent ones, with `untl` fulfilment -- and the two gates a set-valued presentation has
that the tuple-shaped table has no rows for, NON-CIRCULARITY and STAB SELF-REFERENCE.

The research round re-costed that obligation against the tree and found its residue to be two
things: a STRENGTH CHOICE between a universal and an existential fulfilment condition, and ONE
MISSING ALGORITHM under the universal-rejecting half (generalized-Büchi nonemptiness per state, a
nested fixpoint nothing in this tree decides).  This file executes the route that avoids the
missing algorithm and nothing beyond it.

## The verdict

The strength choice is made and compiled, not left implicit.  The fulfilment condition is
EXISTENTIAL: `euLfp V succ isE isG` collects the positions from which SOME guarded path inside
`V` delivers the event at a strictly later index (`eu_mem_lfp_iff_exists_path`; `0 < n` and the
event at `f n` make this strict until, not weak until).  `ULive` is never transplanted, and
`au_lfp_ne_eu_lfp_on_exit_graph` compiles why: on the four-state graph `0 → 1 → 2 → 0` with the
exit `0 → 3` and the self-loop at the only event state, the landed UNIVERSAL operator returns
`{3}` and this file's EXISTENTIAL one returns `Finset.univ`.  A cycle with an exit under a
pending eventuality is exactly the mechanism `PlusWitnessFamily/Limits/NoCertificate.lean`
identifies as refuting a thread-universal fulfilment condition at L+, whose verdict on the
obvious repair is quoted exactly because it forecloses it: "The defect is not a missing bound and
no bound repairs it."

Route B (CHECK a guessed realizable set) is taken over Route A (DECIDE realizability).  The
certificate `certAdm R` conjoins six decidable fields on a candidate set `R`: local coherence
(`certLoc`), bi-infinity inside `R` (`certBiInf`), the EXISTENTIAL forward discharge of every
`untl` member through `euLfp R (succR R)` (`certFwd`, unfolded in `cert_fwd_iff_eu_lfp` so that
the "inside `R`" is visible in a signature and not only in a definition), its past-directed
mirror (`certBwd`), the `stab` biconditional against `R`'s own fibre (`certStab`), and the `box`
bit against `R` (`certBox`).  The existential fixpoint built here is NOT Route A's algorithm: it
decides ONE eventuality's bounded discharge inside the candidate set, never "does some chain
discharge every eventuality it carries".

The certificate is non-vacuous and it is strictly stronger than local coherence.  Non-vacuity
first: `cert_accepts_Rchi` lands `certAdm Rchi = true` on the `chi`-carrying 3-cycle, before every
negative statement about the certificate.  Then the separation: `coh_accepts_Rev` shows local
coherence and bi-infinity BOTH hold on the `ev`-carrying 3-cycle `Rev`, and `cert_rejects_Rev`
shows `certAdm Rev = false` -- because `rev_eu_lfp_empty` proves, through
`eu_lfp_eq_empty_of_no_event` rather than by brute force, that no guarded path inside `Rev`
delivers `psi2`.  `untl_propagates_along_coh` is the composition theorem the restriction to `R`
could have silently broken: an `untl` obligation carried at an interior position of a `coh`-chain
is either discharged inside the chain, with the guard holding at every strictly intermediate
position, or still carried at its end with the guard holding throughout.  No backward mirror is
stated, and that is deliberate: `linkPred` constrains no backward arm, so a backward propagation
theorem is not available from this relation and claiming one would be a strictly weaker statement
wearing a stronger name.

The restricted countdown profile survives the refinement.  `ProfR R k` iterates backward
reachability of `cohR R` -- the local relation with both endpoints confined to `R` -- from the
fibre `Ea ∩ R`.  On `Rchi` its period is exactly three (`profR_period_three`), its `a`-fibre is
nonempty at exactly the multiples of three (`profR_fibre_a_witness` with `profR_dvd_of_mem`), and
it separates the exact pair gate 6 used to refute the sixth index, for every modulus coprime to
three with no parameter to choose (`profR_separates_gate6_pair`).

## The figures, confirmed in the file rather than carried

Every number this round leans on is `#eval`-ed in the file, beside the theorem that depends on
it, rather than carried from an earlier record: the two exit-graph fixpoints are `{3}`
(universal) and `{0, 1, 2, 3} = Finset.univ` (existential); `plusSubformulaClosure chi` has 18
members; the `untl`-member counts of `Ta`, `Tb` and `Tc` are 0, 1 and 1, so condition (3) has
exactly TWO obligations on `Rchi` (`xxpa` in `Tb`, `xpa` in `Tc`) and both reach their events in
one step; and the restricted profile's three values are `{(a5, Ta)}`, `{(c5, Tc)}`,
`{(b5, Tb)}` at `k % 3 = 0, 1, 2`, printed by their object coordinate because printing a closure
type prints its whole formula set.  What IS carried, and is marked carried wherever it appears,
is every gate verdict read from an earlier probe's header rather than re-run here.

No `decide` in this file is ever applied to a goal quantifying over a candidate set or over
`ClType chi`: kernel-reducing even the three-element `Rchi` literal means deciding equality of
closure types and overruns the recursion depth at any budget worth setting.  `decide` closes
concrete closure memberships, concrete `coh6` facts, bounded quantifications over ONE closure
type, the 18-member closure and the four-state exit graph -- nothing else.  There is no
`native_decide` and no `set_option maxRecDepth` anywhere in the file.

## Gate 1 (the first region separation, on the next-deadline side): NOT ADDRESSED

Nothing here addresses it.  This datum reads the COUNTDOWN only; the next-deadline-side datum is
standing obligation (c) and is untouched.  The qualification is compiled elsewhere and is carried,
not re-run: the refuted tuple n-side coordinates PASS gates 1 and 2 and are still blind to the
shift the datum has to see (`nside-modulus-gate.lean`, Branch N-VERIFIED).  A gate probing one
coordinate certifies one coordinate only.

## Gate 2 (the second region separation): NOT ADDRESSED

Nothing here addresses it.  It reduces to adequacy, and adequacy's SUFFICIENCY half is not
discharged in this file; the same compiled n-side qualification applies and is carried.

## Gate 3 (the two-sided region refutation): CARRIED

Not re-run by anything in this file.  Its verdict is carried from the sixteenth probe's
`second_region_sets_agree` and `region_start_beyond_depth`, as the eighteenth probe's header
already records.  This datum has no region parameters for the gate to read.

## Gate 4 (the threshold coordinate): DISARMED BY CONSTRUCTION, carried

Carried from the eighteenth probe, re-run by nothing here: neither the countdown profile nor its
restriction `ProfR` carries a threshold parameter, so there is nothing for the gate to
instantiate.  The depth-`(T+1)` witness enlarges the closure rather than escaping a bound.

## Gate 5 (the modulus coordinate): DISARMED AND EXHIBITED, carried

Carried from the eighteenth probe (`reach5_eventually_constant`), re-run by nothing here: the
OBJECT's full-graph reach set is constant from threshold four -- period one -- while the profile's
`a`-fibre is nonempty at exactly the multiples of three.  The object's exhibited period does not
bind the profile.

## Gate 6 (pattern-definability of the sub-object): the separation SURVIVES the refinement

Gate 6's own row stands exactly as the eighteenth probe left it -- `prof6_separates_gate6_pair`
internalises it there, with no parameter to choose.  What this file adds is that restricting the
relation to the certificate's candidate set does NOT cost the separation:
`profR_separates_gate6_pair` re-runs it against `cohR Rchi`.  This is NOT a new gate-6 verdict
and must not be read as one.

## Gate 7 (non-circularity and non-vacuity): PASSED in its definability form, and witnessed

Every certificate field is a computable `Bool` built from `(Q5, step5, pend5, lab6, chi)` and the
candidate set alone.  No `WorldHistory`, `PlusTruthAt`, `tpOf`, `cellAt`, `anchorCells`, world,
model or cell appears in any declaration of this file -- no clause of the truth definition is
unfolded anywhere.  The self-referential bits (`stab`, `box`) are stated as CHECKED CONDITIONS on
the candidate datum, following `BiLasso/Annotation.lean`'s `BoxOracleSound` (a specification,
deliberately not a construction) and `PlusWitnessFamily/Predicates.lean`'s `StabFaithful`: that
is the settled in-tree pattern, and it resolves the DEFINITIONAL circularity.  Non-vacuity is
witnessed by `cert_accepts_Rchi`, landed before every negative statement.

## Gate 8 (`stab` self-reference): SIDESTEPPED on a `stab`-free fixture, NOT passed

`chi_closure_box_snce_stab_free` compiles the reason: `plusSubformulaClosure chi` has no `box`,
no `snce` and no `stab` member, so conditions (4), (5) and (6) are checked and vacuously
satisfied here.  The clauses are PRESENT -- `certStab` and `certBox` are conjuncts of `certAdm`,
and no datum of this file is stated without them -- but they are UNEXERCISED.  Gate 8 is the
standing `BoxStabFree` scope line of the whole anchor/run layer, now visible as a gate rather
than as a hypothesis: `RaySummary/Realize.lean` and the eighteenth probe buy their results at
exactly this place, by excluding `box` and `stab` from the closure.  Every `stab` verdict in this
line stays SIDESTEPPED.

## Gate 9 (the n-side modulus): OPEN

Raised in the nineteenth probe with its collision half compiled and its refuting half not
attempted.  Nothing here attempts it and nothing here closes it.

## What this does NOT say

  - **The conditions are NOT proved SUFFICIENT for realizability.**  Adequacy is not discharged.
     The dovetailing argument that Route B's six conditions suffice is an argument in the research
     round's report, marked uncompiled there, and is stated as a theorem nowhere in this file.
  - **This is NOT Route A, and nothing here decides generalized-Büchi nonemptiness.**  No theorem
     in this file quantifies over the SET of eventualities a state carries.  The existential
     fixpoint decides ONE eventuality's bounded discharge inside a candidate set; reading it as
     "adequacy decided" is a misreading the Overview, the verdict above and this bullet all
     foreclose.
  - **`(a5, evTa)` is NOT claimed non-realizable, and the countdown profile is NOT refuted.**
     `psi2` is deliverable on this object through the 2-cycle exit `a → d → a`, which `Rev`
     excludes by construction, so some other `coh6`-chain out of `(a5, evTa)` may well discharge
     `ev`.  What is rejected is `Rev` AS A CANDIDATE REALIZABLE SET.
  - **Gate 8 is SIDESTEPPED, not passed**, on a `stab`-free fixture; it is the standing
     `BoxStabFree` scope line of the anchor/run layer, not a presentation-specific obstruction.
  - **Gate 3 is CARRIED**; gates 1 and 2 are NOT ADDRESSED, with the compiled n-side
     qualification that the refuted tuple n-side coordinates pass gates 1 and 2 and remain blind
     to the shift the datum has to see; gate 9 is OPEN.  Gates 4 and 5 are carried from the
     eighteenth probe and re-run by nothing here.
  - **Obligations (b), (c) and (d) are untouched**: region-length pumping, the `Drift` coupling of
     the next deadline, and the `box`/`stab` letters through
     `box_mem_tpOf_iff`/`stab_mem_tpOf_iff`.
  - **Eventual periodicity of the UNRESTRICTED countdown is settled elsewhere** (the seventeenth
     probe, `closure-indexed-periodicity.lean`) and is neither re-derived nor claimed here.
     `profR_period_three` is a statement about the RESTRICTED relation on a three-element
     candidate set, not about the unrestricted countdown.
  - **No `ladderRealized` and no `LadderCons`, in any form.**  No declaration of this file is
     named `ladderRealized`, `LadderCons` or `ladderCons_localRun`, under those names or any
     others, and no same-named weaker substitute for any of them is stated -- hence none without
     the `box`/`stab` clause.  Nothing here is a factorization lemma, a cell index, or any part
     of one.
  - **No seventh tuple coordinate is proposed**, and no modulus, threshold or index is computed
     or claimed computable.  The tuple-widening line is spent and nothing here reopens it; the
     profile's period and the closure cardinality are FACTS ABOUT A FIXTURE, not index
     coordinates.
  - **The SET of cells was never in question.**  `anchorCells_finite` and `anchorCells_ncard_le`
     already bound it; only the computable INDEX is open, and this file does not close it.
  - **One fixture is one fixture.**  Every exhibit is on the coprime-cycle object with gate 6's
     labelling and gate 6's formula.  A gate probing one coordinate certifies one coordinate
     only, and a seventh mechanism may exist that none of this exercises.

Compile:
`lake env lean specs/evidence/seam-gluing-ray-product/realizable-type-certificate.lean`
-/
import FormalSystem.Metalogic.Decidability.RaySummary.AnchorLayer
import FormalSystem.Metalogic.Decidability.WitnessFamily.Sharing.Fulfil

open FormalSystem.Syntax FormalSystem.PlusLanguage FormalSystem.Metalogic.Decidability

namespace Probe809C

/-! ## The EXISTENTIAL until-fixpoint, at an arbitrary finite graph

The one-quantifier edit of `AUFix` (`WitnessFamily/Sharing/Fulfil.lean`): `∃ w ∈ succ v` in place
of `∀ w ∈ succ v`.  Every lemma below is the `AUFix` original read side by side, with the
quantifier changed and nothing else restructured -- which is the compiled form of the research
round's claim that `step_mono`/`iter`/`iter_stab`/`exists_stab`/`lfp_fixed`/`lfp_least`/
`mem_lfp_iff` read only monotonicity in `X`, never the quantifier.

The section mentions NO formula, NO label and NO object: the operator is language-agnostic, which
is the property that makes it the dual of `AUFix` rather than a fixture device.  The port lives
here rather than in `FormalSystem/` because this task's scope forbids library edits -- a
deliberate consequence, not an oversight. -/

variable {α : Type*} [DecidableEq α]

/--
One step of the EXISTENTIAL `E[g U e]` operator: the positions SOME successor of which either
delivers the event now, or carries the guard and is already known to deliver it later.
-/
def euStep (V : Finset α) (succ : α → Finset α) (isE isG : α → Bool) (X : Finset α) :
    Finset α :=
  V.filter (fun v => ∃ w ∈ succ v, isE w = true ∨ (isG w = true ∧ w ∈ X))

theorem eu_step_subset (V : Finset α) (succ : α → Finset α) (isE isG : α → Bool) (X : Finset α) :
    euStep V succ isE isG X ⊆ V := Finset.filter_subset _ _

/-- **The operator is monotone**, which is what makes the iteration a chain.  The only property
the iteration needs, and the only one the quantifier change could have broken. -/
theorem eu_step_mono (V : Finset α) (succ : α → Finset α) (isE isG : α → Bool)
    {X Y : Finset α} (h : X ⊆ Y) :
    euStep V succ isE isG X ⊆ euStep V succ isE isG Y := by
  intro v hv
  rw [euStep, Finset.mem_filter] at hv ⊢
  obtain ⟨hvV, w, hw, hcase⟩ := hv
  refine ⟨hvV, w, hw, ?_⟩
  rcases hcase with he | ⟨hg, hx⟩
  · exact Or.inl he
  · exact Or.inr ⟨hg, h hx⟩

/-- The iteration of the operator from `∅`. -/
def euIter (V : Finset α) (succ : α → Finset α) (isE isG : α → Bool) : ℕ → Finset α
  | 0 => ∅
  | n + 1 => euStep V succ isE isG (euIter V succ isE isG n)

theorem eu_iter_subset (V : Finset α) (succ : α → Finset α) (isE isG : α → Bool) :
    ∀ n, euIter V succ isE isG n ⊆ V
  | 0 => Finset.empty_subset _
  | _ + 1 => eu_step_subset _ _ _ _ _

theorem eu_iter_succ_mono (V : Finset α) (succ : α → Finset α) (isE isG : α → Bool) :
    ∀ n, euIter V succ isE isG n ⊆ euIter V succ isE isG (n + 1)
  | 0 => Finset.empty_subset _
  | n + 1 => eu_step_mono V succ isE isG (eu_iter_succ_mono V succ isE isG n)

theorem eu_iter_mono (V : Finset α) (succ : α → Finset α) (isE isG : α → Bool) {m n : ℕ}
    (h : m ≤ n) : euIter V succ isE isG m ⊆ euIter V succ isE isG n := by
  induction n with
  | zero =>
      have hm : m = 0 := Nat.le_zero.mp h
      subst hm
      exact Finset.Subset.refl _
  | succ k ih =>
      rcases Nat.lt_or_ge m (k + 1) with hlt | hge
      · exact subset_trans (ih (Nat.lt_succ_iff.mp hlt)) (eu_iter_succ_mono V succ isE isG k)
      · have hm : m = k + 1 := le_antisymm h hge
        subst hm
        exact Finset.Subset.refl _

/-- **Stabilization propagates**: once one step is fixed, every later index agrees with it. -/
theorem eu_iter_stab (V : Finset α) (succ : α → Finset α) (isE isG : α → Bool) {n : ℕ}
    (h : euIter V succ isE isG (n + 1) = euIter V succ isE isG n) :
    ∀ m, n ≤ m → euIter V succ isE isG m = euIter V succ isE isG n := by
  intro m
  induction m with
  | zero =>
      intro hm
      have hn : n = 0 := Nat.le_zero.mp hm
      subst hn
      rfl
  | succ k ih =>
      intro hm
      rcases Nat.lt_or_ge n (k + 1) with hlt | hge
      · have hk : n ≤ k := Nat.lt_succ_iff.mp hlt
        have hek : euIter V succ isE isG k = euIter V succ isE isG n := ih hk
        have hstep : euIter V succ isE isG (k + 1)
            = euStep V succ isE isG (euIter V succ isE isG n) := by
          rw [← hek]; rfl
        rw [hstep]
        exact h
      · have hn : n = k + 1 := le_antisymm hm hge
        subst hn
        rfl

/-- **The iteration stabilizes within `|V|` steps.**  The pigeonhole on the cardinality measure,
unchanged from `AUFix.exists_stab`. -/
theorem eu_exists_stab (V : Finset α) (succ : α → Finset α) (isE isG : α → Bool) :
    ∃ n ≤ V.card, euIter V succ isE isG (n + 1) = euIter V succ isE isG n := by
  by_contra hc
  push Not at hc
  have hcard : ∀ n, n ≤ V.card + 1 → n ≤ (euIter V succ isE isG n).card := by
    intro n
    induction n with
    | zero => intro _; exact Nat.zero_le _
    | succ k ih =>
        intro hk
        have hk' : k ≤ V.card := by omega
        have hne := hc k hk'
        have hsub := eu_iter_succ_mono V succ isE isG k
        have hss : euIter V succ isE isG k ⊂ euIter V succ isE isG (k + 1) :=
          Finset.ssubset_iff_subset_ne.mpr ⟨hsub, fun hcon => hne hcon.symm⟩
        have hlt := Finset.card_lt_card hss
        have hprev := ih (by omega)
        omega
  have h1 := hcard (V.card + 1) (le_refl _)
  have h2 : (euIter V succ isE isG (V.card + 1)).card ≤ V.card :=
    Finset.card_le_card (eu_iter_subset V succ isE isG _)
  omega

/-- **The `E[g U e]` fixpoint**: the iteration run to its stabilization bound. -/
def euLfp (V : Finset α) (succ : α → Finset α) (isE isG : α → Bool) : Finset α :=
  euIter V succ isE isG (V.card + 1)

theorem eu_lfp_subset (V : Finset α) (succ : α → Finset α) (isE isG : α → Bool) :
    euLfp V succ isE isG ⊆ V := eu_iter_subset _ _ _ _ _

/-- **It is a fixpoint.** -/
theorem eu_lfp_fixed (V : Finset α) (succ : α → Finset α) (isE isG : α → Bool) :
    euStep V succ isE isG (euLfp V succ isE isG) = euLfp V succ isE isG := by
  obtain ⟨n, hn, hstab⟩ := eu_exists_stab V succ isE isG
  have e1 : euIter V succ isE isG (V.card + 1) = euIter V succ isE isG n :=
    eu_iter_stab V succ isE isG hstab _ (by omega)
  have e2 : euIter V succ isE isG (V.card + 2) = euIter V succ isE isG n :=
    eu_iter_stab V succ isE isG hstab _ (by omega)
  change euIter V succ isE isG (V.card + 2) = euIter V succ isE isG (V.card + 1)
  rw [e1, e2]

/-- **It is the least pre-fixpoint**, which is what excludes the eventualities passed around a
cycle forever without ever being delivered. -/
theorem eu_lfp_least (V : Finset α) (succ : α → Finset α) (isE isG : α → Bool) {X : Finset α}
    (h : euStep V succ isE isG X ⊆ X) : euLfp V succ isE isG ⊆ X := by
  have key : ∀ n, euIter V succ isE isG n ⊆ X := by
    intro n
    induction n with
    | zero => exact Finset.empty_subset _
    | succ k ih => exact subset_trans (eu_step_mono V succ isE isG ih) h
  exact key _

/-- Membership in the fixpoint, unfolded one step. -/
theorem eu_mem_lfp_iff (V : Finset α) (succ : α → Finset α) (isE isG : α → Bool) (v : α) :
    v ∈ euLfp V succ isE isG ↔
      v ∈ V ∧ ∃ w ∈ succ v, isE w = true ∨ (isG w = true ∧ w ∈ euLfp V succ isE isG) := by
  constructor
  · intro hv
    rw [← eu_lfp_fixed V succ isE isG, euStep, Finset.mem_filter] at hv
    exact hv
  · intro hv
    rw [← eu_lfp_fixed V succ isE isG, euStep, Finset.mem_filter]
    exact hv

/-! ## What the fixpoint MEANS: a guarded path that delivers the event

The existential analogue of `AUFix.lfp_induction`, read as a path statement.  The path is
STRICTLY later: `0 < n` and the event is demanded at `f n`, so this is strict until and not weak
until.  Dropping `0 < n` would silently turn one into the other. -/

/-- Every iterate lies inside the fixpoint -- for EVERY index, not only the indices below the
stabilization bound.  This is what makes the backward direction of the path characterization need
no path-shortening argument. -/
theorem eu_iter_subset_lfp (V : Finset α) (succ : α → Finset α) (isE isG : α → Bool) (n : ℕ) :
    euIter V succ isE isG n ⊆ euLfp V succ isE isG := by
  obtain ⟨k, hk, hstab⟩ := eu_exists_stab V succ isE isG
  rcases Nat.lt_or_ge n (V.card + 1) with hlt | hge
  · exact eu_iter_mono V succ isE isG (by omega)
  · have e1 : euIter V succ isE isG n = euIter V succ isE isG k :=
      eu_iter_stab V succ isE isG hstab n (by omega)
    have e2 : euIter V succ isE isG (V.card + 1) = euIter V succ isE isG k :=
      eu_iter_stab V succ isE isG hstab _ (by omega)
    rw [euLfp, e1, e2]

/-- Forward: membership in an iterate exhibits a guarded path to the event. -/
theorem eu_iter_path (V : Finset α) (succ : α → Finset α) (isE isG : α → Bool) :
    ∀ (k : ℕ), ∀ v ∈ euIter V succ isE isG k,
      ∃ (n : ℕ) (f : ℕ → α), 0 < n ∧ f 0 = v ∧ (∀ i < n, f i ∈ V) ∧
        (∀ i < n, f (i + 1) ∈ succ (f i)) ∧ isE (f n) = true ∧
        (∀ i, 0 < i → i < n → isG (f i) = true) := by
  intro k
  induction k with
  | zero => intro v hv; simp only [euIter] at hv; exact absurd hv (by simp)
  | succ k ih =>
    intro v hv
    have hv' : v ∈ euStep V succ isE isG (euIter V succ isE isG k) := hv
    rw [euStep, Finset.mem_filter] at hv'
    obtain ⟨hvV, w, hw, hcase⟩ := hv'
    rcases hcase with he | ⟨hg, hwk⟩
    · refine ⟨1, fun i => if i = 0 then v else w, Nat.one_pos, by simp, ?_, ?_, ?_, ?_⟩
      · intro i hi
        have hi0 : i = 0 := by omega
        subst hi0; simpa using hvV
      · intro i hi
        have hi0 : i = 0 := by omega
        subst hi0; simpa using hw
      · simpa using he
      · intro i h0 hi; omega
    · obtain ⟨n, f, hn, hf0, hfV, hfs, hfe, hfg⟩ := ih w hwk
      refine ⟨n + 1, fun i => if i = 0 then v else f (i - 1), Nat.succ_pos _, by simp,
        ?_, ?_, ?_, ?_⟩
      · intro i hi
        cases i with
        | zero => simpa using hvV
        | succ j => simpa using hfV j (by omega)
      · intro i hi
        cases i with
        | zero => simpa [hf0] using hw
        | succ j => simpa using hfs j (by omega)
      · simpa using hfe
      · intro i h0 hi
        cases i with
        | zero => omega
        | succ j =>
          cases j with
          | zero => simpa [hf0] using hg
          | succ j' => simpa using hfg (j' + 1) (Nat.succ_pos _) (by omega)

/-- Backward: a guarded path of length `n` to the event puts its origin in the `n`-th iterate. -/
theorem eu_path_mem_iter (V : Finset α) (succ : α → Finset α) (isE isG : α → Bool) :
    ∀ (n : ℕ) (f : ℕ → α), 0 < n → (∀ i < n, f i ∈ V) → (∀ i < n, f (i + 1) ∈ succ (f i)) →
      isE (f n) = true → (∀ i, 0 < i → i < n → isG (f i) = true) →
      f 0 ∈ euIter V succ isE isG n := by
  intro n
  induction n with
  | zero => intro f h0 _ _ _ _; exact absurd h0 (by omega)
  | succ m ih =>
    intro f _ hV hs hE hG
    rcases Nat.eq_zero_or_pos m with hm | hm
    · subst hm
      show f 0 ∈ euStep V succ isE isG (euIter V succ isE isG 0)
      rw [euStep, Finset.mem_filter]
      exact ⟨hV 0 (by omega), f 1, hs 0 (by omega), Or.inl hE⟩
    · have key : f 1 ∈ euIter V succ isE isG m := by
        have h := ih (fun i => f (i + 1)) hm
          (fun i hi => hV (i + 1) (by omega))
          (fun i hi => hs (i + 1) (by omega))
          (by simpa using hE)
          (fun i h0 hi => hG (i + 1) (by omega) (by omega))
        simpa using h
      show f 0 ∈ euStep V succ isE isG (euIter V succ isE isG m)
      rw [euStep, Finset.mem_filter]
      exact ⟨hV 0 (by omega), f 1, hs 0 (by omega),
        Or.inr ⟨hG 1 (by omega) (by omega), key⟩⟩

/-- **THE FIXPOINT IS THE GUARDED-PATH OPERATOR.**  `v` is in the existential fixpoint exactly
when SOME path out of `v`, staying inside `V`, carries the guard at every strictly interior
position and delivers the event at a STRICTLY later index.  This is the condition the certificate
checks, and it is existential: one path suffices. -/
theorem eu_mem_lfp_iff_exists_path (V : Finset α) (succ : α → Finset α) (isE isG : α → Bool)
    (v : α) :
    v ∈ euLfp V succ isE isG ↔
      ∃ (n : ℕ) (f : ℕ → α), 0 < n ∧ f 0 = v ∧ (∀ i < n, f i ∈ V) ∧
        (∀ i < n, f (i + 1) ∈ succ (f i)) ∧ isE (f n) = true ∧
        (∀ i, 0 < i → i < n → isG (f i) = true) := by
  constructor
  · intro hv
    have hv' : v ∈ euIter V succ isE isG (V.card + 1) := hv
    exact eu_iter_path V succ isE isG (V.card + 1) v hv'
  · rintro ⟨n, f, hn, hf0, hfV, hfs, hfe, hfg⟩
    have h := eu_path_mem_iter V succ isE isG n f hn hfV hfs hfe hfg
    rw [hf0] at h
    exact eu_iter_subset_lfp V succ isE isG n h

/-- **The one negative lemma the rejection proof consumes.**  If `V` is closed under `succ` and no
member of `V` delivers the event, the existential fixpoint is EMPTY -- no amount of guarded
wandering inside `V` discharges anything.  Proved through `eu_lfp_least` at `X := ∅`, structurally
rather than by brute force. -/
theorem eu_lfp_eq_empty_of_no_event (V : Finset α) (succ : α → Finset α) (isE isG : α → Bool)
    (hclosed : ∀ v ∈ V, ∀ w ∈ succ v, w ∈ V) (hno : ∀ w ∈ V, isE w = false) :
    euLfp V succ isE isG = ∅ := by
  refine Finset.subset_empty.mp (eu_lfp_least V succ isE isG ?_)
  intro v hv
  rw [euStep, Finset.mem_filter] at hv
  obtain ⟨hvV, w, hw, hcase⟩ := hv
  rcases hcase with he | ⟨-, hx⟩
  · rw [hno w (hclosed v hvV w hw)] at he
    exact absurd he (by simp)
  · exact absurd hx (Finset.notMem_empty w)

/-! ## The universal and the existential operator are DIFFERENT: a cycle with an exit

The four-state graph `0 → 1 → 2 → 0` with the exit `0 → 3` and the self-loop `3 → 3` at the only
event state.  This is the mechanism the research round identified as the expensive thing to
rediscover: a pending eventuality on a cycle that has an exit.  The universal operator rejects
vertex `0` because the cycle branch never discharges; the existential operator accepts it because
the exit branch does. -/

def exitSucc : Fin 4 → Finset (Fin 4) := fun i =>
  if i = 0 then {1, 3} else if i = 1 then {2} else if i = 2 then {0} else {3}

def exitIsE : Fin 4 → Bool := fun i => i == 3

def exitIsG : Fin 4 → Bool := fun _ => true

/-! The two fixpoint values on this graph, confirmed by `#eval` before the inequality below was
proved: the UNIVERSAL fixpoint is `{3}` -- only the event state itself -- and the EXISTENTIAL one
is `{0, 1, 2, 3} = Finset.univ`.  Vertex `1` is the sharpest witness: every universal obligation
through it runs `1 → 2 → 0 → 1` forever, while the existential one reaches `3` through `0`. -/
#eval AUFix.lfp Finset.univ exitSucc exitIsE exitIsG
#eval euLfp Finset.univ exitSucc exitIsE exitIsG

/-- **THE UNIVERSAL AND THE EXISTENTIAL FULFILMENT CONDITIONS ARE DIFFERENT**, compiled on a cycle
with an exit.  This is the strength distinction the research round identified as the single most
expensive thing in this line to rediscover: the landed `AUFix` operator and the existential one
built above do NOT agree, so transplanting the universal condition onto the object-closure product
is not a conservative choice of presentation -- it rejects states the existential condition
accepts. -/
theorem au_lfp_ne_eu_lfp_on_exit_graph :
    AUFix.lfp Finset.univ exitSucc exitIsE exitIsG
      ≠ euLfp Finset.univ exitSucc exitIsE exitIsG := by decide

/-! ## The fixture: the coprime-cycle object, the closure carrier, and LOCAL coherence

Ported from `specs/evidence/seam-gluing-ray-product/closure-profile-gate-rerun.lean` (the
eighteenth probe) and `specs/evidence/seam-gluing-ray-product/realizable-type-adequacy-gap.lean`
(the twentieth), which themselves port the object layer from `ladder-joint-index-refutation.lean`
and the carrier from `closure-indexed-periodicity.lean`.  Probes do not import probes, so
everything used below is restated here.  Nothing in this section is new and nothing in it is
changed: `coh` carries exactly the clauses it carries there -- the object step, pending-ness of
BOTH endpoints, local coherence at both endpoints, and the one-step strict-until link -- and NO
fulfilment clause.  The fixture is label-generic, so the frame/regularity/history layer ports
verbatim.  The only edits are the four renames this round fixes: `B`/`C`/`Xpa`/`XXpa` become
`bb`/`cc`/`xpa`/`xxpa`. -/

def pA : Atom := ⟨"p", none⟩
def rA : Atom := ⟨"r", none⟩
def aA : Atom := ⟨"a", none⟩

theorem pA_ne_rA : pA ≠ rA := by simp [pA, rA]
theorem aA_ne_pA : aA ≠ pA := by simp [aA, pA]
theorem aA_ne_rA : aA ≠ rA := by simp [aA, rA]

def p : PlusFormula := .atom pA
def la : PlusFormula := .atom aA

/-- `k` nested nexts. -/
def nextPow : ℕ → PlusFormula → PlusFormula
  | 0, chi => chi
  | k + 1, chi => .untl .bot (nextPow k chi)

/-- The pending `a` state as a formula: `p AND l_a`. -/
def pa : PlusFormula := p.and la

/-- The PATTERN the 2-cycle exhibits and the 3-cycle does not. -/
def psi2 : PlusFormula := pa.and (nextPow 2 pa)

/-- Gate 6's constraint: the pattern fails here and at every strictly later instant. -/
def chi : PlusFormula := psi2.neg.and (PlusFormula.untl (.imp .bot .bot) psi2).neg

/-- Object states `(pending?, index)`; pending indices `0 = a`, `1 = b`, `2 = c`, `3 = d`. -/
abbrev Q5 : Type := Bool × Fin 4

def pend5 : Q5 → Bool := fun q => q.1

/-- Pending edges `a → b → c → a` and `a → d → a`. -/
def step5 : Q5 → Q5 → Bool := fun x y =>
  if x.1 then
    (if y.1 then
      ((x.2 == 0 && (y.2 == 1 || y.2 == 3)) || (x.2 == 1 && y.2 == 2) ||
        (x.2 == 2 && y.2 == 0) || (x.2 == 3 && y.2 == 0))
     else (y.2 == x.2))
  else (!y.1 && (y.2 == x.2))

/-- Gate 6's labelling: `d` is given `b`'s letter, so no set of atoms carves out the 2-cycle. -/
def lab6 : Q5 → Atom → Bool := fun q at_ =>
  if at_ = pA then q.1 else if at_ = rA then !q.1 else (q.2 == 0)

def a5 : Q5 := (true, 0)
def b5 : Q5 := (true, 1)
def c5 : Q5 := (true, 2)

/-- The closure component: a subset of `plusSubformulaClosure φ`. -/
abbrev ClType (φ : PlusFormula) : Type :=
  {T : Finset PlusFormula // T ∈ (plusSubformulaClosure φ).powerset}

/-- The product carrier: the object paired with the closure component. -/
abbrev ProdState (Q : Type) (φ : PlusFormula) : Type := Q × ClType φ

/-- One step of BACKWARD reachability in the product -- the operator the COUNTDOWN iterates. -/
def prodPreStep {Q : Type} [Fintype Q] [DecidableEq Q] {φ : PlusFormula}
    (pstep : ProdState Q φ → ProdState Q φ → Bool) (S : Finset (ProdState Q φ)) :
    Finset (ProdState Q φ) :=
  Finset.univ.filter (fun x => ∃ y ∈ S, pstep x y = true)

/-- The Hintikka condition for one closure formula at a labelled object state.  The modal arms and
both temporal arms are UNCONSTRAINED -- a deliberate over-approximation, and the reason gate 8 is
NOT ADDRESSED by this relation. -/
def locPred {Q : Type} (lab : Q → Atom → Bool) (q : Q) (T : Finset PlusFormula) :
    PlusFormula → Bool
  | ψ@(.atom a) => decide (ψ ∈ T) == lab q a
  | ψ@.bot => decide (ψ ∉ T)
  | ψ@(.imp α β) => decide (ψ ∈ T) == (!(decide (α ∈ T)) || decide (β ∈ T))
  | _ => true

/-- The STRICT-until unfolding across one step.  Every arm other than the
forward-until one is UNCONSTRAINED -- again a deliberate over-approximation; in particular the
BACKWARD temporal arm is constrained by nothing here, so the past direction is untouched and no
backward propagation theorem is available from this relation. -/
def linkPred (T T' : Finset PlusFormula) : PlusFormula → Bool
  | ψ@(.untl g e) =>
      decide (ψ ∈ T) == (decide (e ∈ T') || (decide (g ∈ T') && decide (ψ ∈ T')))
  | _ => true

/-- Local coherence of a product state: the Hintikka condition at every closure formula. -/
def locCoh {Q : Type} (lab : Q → Atom → Bool) (φ : PlusFormula) (x : ProdState Q φ) : Bool :=
  decide (∀ ψ ∈ plusSubformulaClosure φ, locPred lab x.1 x.2.1 ψ = true)

/-- The link condition across one step: the strict-until unfolding at every closure formula. -/
def untlLink (φ : PlusFormula) (T T' : ClType φ) : Bool :=
  decide (∀ ψ ∈ plusSubformulaClosure φ, linkPred T.1 T'.1 ψ = true)

/-- **The LOCAL coherence relation**, with NO fulfilment clause. -/
def coh {Q : Type} (step : Q → Q → Bool) (pend : Q → Bool) (lab : Q → Atom → Bool)
    (φ : PlusFormula) (x y : ProdState Q φ) : Bool :=
  step x.1 y.1 && pend x.1 && pend y.1 && locCoh lab φ x && locCoh lab φ y &&
    untlLink φ x.2 y.2

/-- The fixture instance: the coprime-cycle object, gate 6's labelling, gate 6's formula. -/
def coh6 : ProdState Q5 chi → ProdState Q5 chi → Bool := coh step5 pend5 lab6 chi

/-- A closure type from a membership list.  Built as a `filter`, never by `decide` on
`Finset.powerset`. -/
def mkT (L : List PlusFormula) : ClType chi :=
  ⟨(plusSubformulaClosure chi).filter (fun ψ => ψ ∈ L),
    Finset.mem_powerset.mpr (Finset.filter_subset _ _)⟩

/-- The fibre over the pending `a` state. -/
def Ea : Finset (ProdState Q5 chi) := Finset.univ.filter (fun x => x.1 = a5)

def top : PlusFormula := .imp .bot .bot
def xpa : PlusFormula := nextPow 1 pa
def xxpa : PlusFormula := nextPow 2 pa
def bb : PlusFormula := pa.imp xxpa.neg
def cc : PlusFormula := p.imp la.neg
/-- **The eventuality**: `T U psi2`, strictly in the future.  A member of
`plusSubformulaClosure chi`, because `chi` denies it. -/
def ev : PlusFormula := PlusFormula.untl top psi2
def evnn : PlusFormula := ev.neg.neg
def dd : PlusFormula := psi2.neg.imp evnn

def TaL : List PlusFormula := [chi, psi2.neg, ev.neg, top, bb, pa, xxpa.neg, p, la]
def TbL : List PlusFormula := [chi, psi2.neg, ev.neg, top, bb, xxpa, cc, p, la.neg]
def TcL : List PlusFormula := [chi, psi2.neg, ev.neg, top, bb, xxpa.neg, xpa, cc, p, la.neg]

def Ta : ClType chi := mkT TaL
def Tb : ClType chi := mkT TbL
def Tc : ClType chi := mkT TcL

def evTaL : List PlusFormula := [psi2.neg, ev, evnn, dd, top, bb, pa, xxpa.neg, p, la]
def evTbL : List PlusFormula := [psi2.neg, ev, evnn, dd, top, bb, xxpa, cc, p, la.neg]
def evTcL : List PlusFormula := [psi2.neg, ev, evnn, dd, top, bb, xxpa.neg, xpa, cc, p, la.neg]

def evTa : ClType chi := mkT evTaL
def evTb : ClType chi := mkT evTbL
def evTc : ClType chi := mkT evTcL

/-! The closure cardinality this round's gate work depends on, confirmed by `#eval` rather than
trusted: `plusSubformulaClosure chi` has 18 members. -/
#eval (plusSubformulaClosure chi).card

/-! ## Reading the local conditions and the link at one closure member

Each lemma below instantiates one of the six conditions `coh_iff` delivers, at a SINGLE closure
formula, with the membership side condition closed by `decide`, and turns the `Bool` equation into
the propositional fact the hand proofs use.  No `decide` below is ever applied to a goal
quantifying over `ClType chi`. -/

/-- **The unfolding lemma.**  The workhorse for every hand proof below. -/
theorem coh_iff {Q : Type} [Fintype Q] [DecidableEq Q] (step : Q → Q → Bool) (pend : Q → Bool)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (x y : ProdState Q φ) :
    coh step pend lab φ x y = true ↔
      step x.1 y.1 = true ∧ pend x.1 = true ∧ pend y.1 = true ∧
        (∀ ψ ∈ plusSubformulaClosure φ, locPred lab x.1 x.2.1 ψ = true) ∧
        (∀ ψ ∈ plusSubformulaClosure φ, locPred lab y.1 y.2.1 ψ = true) ∧
        (∀ ψ ∈ plusSubformulaClosure φ, linkPred x.2.1 y.2.1 ψ = true) := by
  simp [coh, locCoh, untlLink, Bool.and_eq_true, and_assoc]

theorem loc_bot {Q : Type} {lab : Q → Atom → Bool} {q : Q} {T : Finset PlusFormula}
    {φ : PlusFormula} (h : ∀ ψ ∈ plusSubformulaClosure φ, locPred lab q T ψ = true)
    (hm : PlusFormula.bot ∈ plusSubformulaClosure φ) : PlusFormula.bot ∉ T := by
  have h1 := h _ hm
  simp only [locPred, decide_eq_true_eq] at h1
  exact h1

theorem loc_atom {Q : Type} {lab : Q → Atom → Bool} {q : Q} {T : Finset PlusFormula}
    {φ : PlusFormula} (h : ∀ ψ ∈ plusSubformulaClosure φ, locPred lab q T ψ = true)
    (a : Atom) (hm : PlusFormula.atom a ∈ plusSubformulaClosure φ) :
    (PlusFormula.atom a ∈ T ↔ lab q a = true) := by
  have h1 := h _ hm
  simp only [locPred, beq_iff_eq] at h1
  by_cases hmem : PlusFormula.atom a ∈ T <;> simp_all

theorem loc_imp {Q : Type} {lab : Q → Atom → Bool} {q : Q} {T : Finset PlusFormula}
    {φ : PlusFormula} (h : ∀ ψ ∈ plusSubformulaClosure φ, locPred lab q T ψ = true)
    (α β : PlusFormula) (hm : α.imp β ∈ plusSubformulaClosure φ) :
    (α.imp β ∈ T ↔ (α ∉ T ∨ β ∈ T)) := by
  have h1 := h _ hm
  simp only [locPred, beq_iff_eq] at h1
  by_cases h2 : α.imp β ∈ T <;> by_cases h3 : α ∈ T <;> by_cases h4 : β ∈ T <;> simp_all

theorem loc_neg {Q : Type} {lab : Q → Atom → Bool} {q : Q} {T : Finset PlusFormula}
    {φ : PlusFormula} (h : ∀ ψ ∈ plusSubformulaClosure φ, locPred lab q T ψ = true)
    (hbot : PlusFormula.bot ∉ T) (α : PlusFormula)
    (hm : α.neg ∈ plusSubformulaClosure φ) : (α.neg ∈ T ↔ α ∉ T) := by
  have h1 : α.neg ∈ T ↔ (α ∉ T ∨ PlusFormula.bot ∈ T) := loc_imp h α .bot hm
  rw [h1]; tauto

theorem link_untl {T T' : Finset PlusFormula} {φ : PlusFormula}
    (h : ∀ ψ ∈ plusSubformulaClosure φ, linkPred T T' ψ = true)
    (g e : PlusFormula) (hm : PlusFormula.untl g e ∈ plusSubformulaClosure φ) :
    (PlusFormula.untl g e ∈ T ↔ (e ∈ T' ∨ (g ∈ T' ∧ PlusFormula.untl g e ∈ T'))) := by
  have h1 := h _ hm
  simp only [linkPred, beq_iff_eq] at h1
  by_cases h2 : PlusFormula.untl g e ∈ T <;> by_cases h3 : e ∈ T' <;> by_cases h4 : g ∈ T' <;>
    by_cases h5 : PlusFormula.untl g e ∈ T' <;> simp_all

/-! ## The restriction of the local relation to a candidate set

`cohR R` is LOCAL coherence with both endpoints constrained to lie in `R`.  This is the relation
the certificate's discharge conditions run their fixpoint over, which is the "inside `R`" the
research round insists on: no path outside `R` can discharge anything. -/

def cohR (R : Finset (ProdState Q5 chi)) (x y : ProdState Q5 chi) : Bool :=
  coh6 x y && decide (x ∈ R) && decide (y ∈ R)

/-- **The restriction is a restriction**: it implies the unrestricted relation and both
memberships, and adds nothing.  So every negative result proved through `coh6` transfers to
`cohR R`, and no positive one does. -/
theorem cohR_le_coh (R : Finset (ProdState Q5 chi)) (x y : ProdState Q5 chi)
    (h : cohR R x y = true) : coh6 x y = true ∧ x ∈ R ∧ y ∈ R := by
  simp only [cohR, Bool.and_eq_true, decide_eq_true_eq] at h
  exact ⟨h.1.1, h.1.2, h.2⟩

/-! ## The chain-to-ray composition theorem

The place the restriction to `R` could silently have failed: an `untl` obligation carried at an
interior position of a `coh`-chain must either be discharged inside the chain, with the guard
holding at every strictly intermediate position, or still be carried at the chain's end with the
guard holding throughout.  Stated generically over the object, the labelling and the formula, so
it covers `coh6` and -- through `cohR_le_coh` -- the restricted relation as well.

No backward mirror is stated: `linkPred` constrains no backward arm, so a backward propagation
theorem is not available from this relation, and claiming one would be a strictly weaker statement
wearing a stronger name. -/

theorem untl_propagates_along_coh {Q : Type} [Fintype Q] [DecidableEq Q]
    (step : Q → Q → Bool) (pend : Q → Bool) (lab : Q → Atom → Bool) (φ : PlusFormula)
    (g : ℕ → ProdState Q φ) (hg : ∀ k, coh step pend lab φ (g k) (g (k + 1)) = true)
    (u e : PlusFormula) (hmem : PlusFormula.untl u e ∈ plusSubformulaClosure φ)
    (i n : ℕ) (hin : i ≤ n) (hcar : PlusFormula.untl u e ∈ (g i).2.1) :
    (∃ j, i < j ∧ j ≤ n ∧ e ∈ (g j).2.1 ∧ ∀ r, i < r → r < j → u ∈ (g r).2.1) ∨
      (PlusFormula.untl u e ∈ (g n).2.1 ∧ ∀ r, i < r → r ≤ n → u ∈ (g r).2.1) := by
  obtain ⟨d, rfl⟩ : ∃ d, n = i + d := ⟨n - i, by omega⟩
  clear hin
  induction d with
  | zero => exact Or.inr ⟨hcar, fun r h1 h2 => absurd h1 (by omega)⟩
  | succ d ih =>
    rcases ih with hleft | hright
    · obtain ⟨j, hij, hjn, hej, hgj⟩ := hleft
      exact Or.inl ⟨j, hij, by omega, hej, hgj⟩
    · obtain ⟨hcarry, hguards⟩ := hright
      have hlink :=
        ((coh_iff step pend lab φ (g (i + d)) (g (i + d + 1))).mp (hg (i + d))).2.2.2.2.2
      rcases (link_untl hlink u e hmem).mp hcarry with he' | ⟨hu', hcarry'⟩
      · exact Or.inl ⟨i + d + 1, by omega, by omega, he', fun r h1 h2 => hguards r h1 (by omega)⟩
      · refine Or.inr ⟨hcarry', ?_⟩
        intro r h1 h2
        rcases Nat.lt_or_ge r (i + d + 1) with hlt | hge
        · exact hguards r h1 (by omega)
        · have hr : r = i + d + 1 := by omega
          subst hr
          exact hu'

/-! ## The certificate presentation: Route B, with seven decidable fields

Route B of the research round -- GUESS the realizable set `R ⊆ ProdState Q5 chi` and CHECK
decidable conditions on it -- rather than Route A, DECIDE realizability, whose missing piece is
generalized-Büchi nonemptiness per state: a nested fixpoint nothing in this tree decides.  The
shape is the one this tree already uses three times (`Cons`'s eleven fields, `AnchorCons`,
`PlusCertifies`'s six checked components), and the `box`/`stab` clauses follow
`BoxOracleSound`/`StabFaithful`/`AnchorCons`: a SPECIFICATION on the candidate datum, deliberately
not a bottom-up computation, which is what breaks the DEFINITIONAL circularity gate 8 names.

Every field below is a computable `Bool` built from `(Q5, step5, pend5, lab6, chi)` and the
candidate set alone.  No history, world, model or cell appears in any of them -- that is gate 7 in
its definability form -- and `cert_accepts_Rchi` lands a non-empty instance BEFORE every statement
about what the certificate rejects.

The fulfilment conditions are EXISTENTIAL and run INSIDE `R`: `certFwd` and `certBwd` run the
fixpoint at `V := R` with `succ := succR R` / `preR R`, so no path outside `R` can discharge
anything.  Weakening that to "a path somewhere in the carrier" would be strictly weaker and still
type-correct, which is why `cert_fwd_iff_eu_lfp` puts condition (3)'s quantifier structure inside
a THEOREM rather than leaving it only inside a definition.

The `stab` and `box` clauses are PRESENT as checked biconditionals and are not dropped because
this fixture makes them vacuous: `chi_closure_box_snce_stab_free` compiles the reason they are
unexercised here, which is why gate 8 stays SIDESTEPPED rather than passed. -/

def isUntl : PlusFormula → Bool
  | .untl _ _ => true
  | _ => false

def isSnce : PlusFormula → Bool
  | .snce _ _ => true
  | _ => false

def isBox : PlusFormula → Bool
  | .box _ => true
  | _ => false

def isStab : PlusFormula → Bool
  | .stab _ => true
  | _ => false

/-- The guard and the event of a binary temporal formula, in that order. -/
def argsOf : PlusFormula → PlusFormula × PlusFormula
  | .untl g e => (g, e)
  | .snce g e => (g, e)
  | _ => (.bot, .bot)

/-- The argument of a unary modal formula. -/
def argOf : PlusFormula → PlusFormula
  | .box σ => σ
  | .stab σ => σ
  | _ => .bot

/-- The successors of `x` INSIDE `R`. -/
def succR (R : Finset (ProdState Q5 chi)) (x : ProdState Q5 chi) :
    Finset (ProdState Q5 chi) :=
  R.filter (fun y => coh6 x y = true)

/-- The predecessors of `x` INSIDE `R`. -/
def preR (R : Finset (ProdState Q5 chi)) (x : ProdState Q5 chi) :
    Finset (ProdState Q5 chi) :=
  R.filter (fun y => coh6 y x = true)

/-- Condition (1): every member of the candidate set is locally coherent. -/
def certLoc (R : Finset (ProdState Q5 chi)) : Bool :=
  decide (∀ x ∈ R, locCoh lab6 chi x = true)

/-- Condition (2): every member has a successor AND a predecessor inside `R` -- bi-infinity, read
against `R` itself and not against the carrier. -/
def certBiInf (R : Finset (ProdState Q5 chi)) : Bool :=
  decide (∀ x ∈ R, 0 < (succR R x).card ∧ 0 < (preR R x).card)

/-- Condition (3): every forward eventuality carried by a member is discharged by a guarded
forward path INSIDE `R`.  EXISTENTIAL: one path suffices. -/
def certFwd (R : Finset (ProdState Q5 chi)) : Bool :=
  decide (∀ x ∈ R, ∀ ψ ∈ x.2.1, isUntl ψ = true →
    x ∈ euLfp R (succR R) (fun w => decide ((argsOf ψ).2 ∈ w.2.1))
                          (fun w => decide ((argsOf ψ).1 ∈ w.2.1)))

/-- Condition (4): the past-directed mirror of condition (3), through `preR R`. -/
def certBwd (R : Finset (ProdState Q5 chi)) : Bool :=
  decide (∀ x ∈ R, ∀ ψ ∈ x.2.1, isSnce ψ = true →
    x ∈ euLfp R (preR R) (fun w => decide ((argsOf ψ).2 ∈ w.2.1))
                         (fun w => decide ((argsOf ψ).1 ∈ w.2.1)))

/-- The `stab` biconditional at one member and one closure formula, read against `R`'s OWN fibre
over the member's object state. -/
def stabOk (R : Finset (ProdState Q5 chi)) (x : ProdState Q5 chi) (ψ : PlusFormula) : Bool :=
  decide (ψ ∈ x.2.1) == decide (∀ y ∈ R, y.1 = x.1 → argOf ψ ∈ y.2.1)

/-- Condition (5): the `stab` clause, PRESENT as a checked biconditional. -/
def certStab (R : Finset (ProdState Q5 chi)) : Bool :=
  decide (∀ x ∈ R, ∀ ψ ∈ plusSubformulaClosure chi, isStab ψ = true → stabOk R x ψ = true)

/-- Condition (6): the `box` clause, the global bit read against `R`, PRESENT as a checked
biconditional. -/
def certBox (R : Finset (ProdState Q5 chi)) : Bool :=
  decide (∀ x ∈ R, ∀ ψ ∈ plusSubformulaClosure chi, isBox ψ = true →
    (decide (ψ ∈ x.2.1) == decide (∀ y ∈ R, argOf ψ ∈ y.2.1)) = true)

/-- **THE CERTIFICATE**: a candidate realizable set is ADMISSIBLE when all six conditions hold.
The `stab` and `box` conjuncts are part of the certificate, not optional extras. -/
def certAdm (R : Finset (ProdState Q5 chi)) : Bool :=
  certLoc R && certBiInf R && certFwd R && certBwd R && certStab R && certBox R

/-- The `chi`-carrying 3-cycle of the eighteenth probe, as a candidate realizable set. -/
def Rchi : Finset (ProdState Q5 chi) := {(a5, Ta), (b5, Tb), (c5, Tc)}

theorem mem_Rchi (x : ProdState Q5 chi) :
    x ∈ Rchi ↔ (x = (a5, Ta) ∨ x = (b5, Tb) ∨ x = (c5, Tc)) := by
  simp [Rchi]

/-- **The closure of `chi` has no `box`, no `snce` and no `stab` member.**  So conditions (4), (5)
and (6) have NO CONTENT on this fixture: they are checked and vacuously satisfied.  This is the
compiled statement of the gate-8 sidestep -- the standing `BoxStabFree` scope line of the whole
anchor/run layer, which `Realize.lean` and the eighteenth probe buy their results under at exactly
the same place.  Gate 8 is SIDESTEPPED here, not passed. -/
theorem chi_closure_box_snce_stab_free :
    ∀ ψ ∈ plusSubformulaClosure chi,
      isBox ψ = false ∧ isSnce ψ = false ∧ isStab ψ = false := by decide

/-- **Condition (3), unfolded.**  The quantifier structure of the forward discharge condition,
stated as a theorem so that "inside `R`" is visible in a signature and not only in a definition:
the fixpoint runs at `V := R` with `succ := succR R`. -/
theorem cert_fwd_iff_eu_lfp (R : Finset (ProdState Q5 chi)) :
    certFwd R = true ↔
      ∀ x ∈ R, ∀ ψ ∈ x.2.1, isUntl ψ = true →
        x ∈ euLfp R (succR R) (fun w => decide ((argsOf ψ).2 ∈ w.2.1))
                              (fun w => decide ((argsOf ψ).1 ∈ w.2.1)) := by
  simp only [certFwd, decide_eq_true_eq]

/-! The three figures the non-vacuity witness below depends on, confirmed by `#eval` rather than
trusted: the closure of `chi` has 18 members, and the `untl` members of the three types number
`0`, `1` and `1` -- `Tb` carries `xxpa = .untl .bot xpa` and `Tc` carries `xpa = .untl .bot pa`,
so condition (3) has exactly two obligations on `Rchi` and both are discharged in one step. -/
#eval (Ta.1.filter (fun ψ => isUntl ψ = true)).card
#eval (Tb.1.filter (fun ψ => isUntl ψ = true)).card
#eval (Tc.1.filter (fun ψ => isUntl ψ = true)).card

/-! ### The six conditions on `Rchi`, one at a time

No `decide` below is ever applied to a goal quantifying over the candidate set: kernel-reducing
the three-element `Rchi` literal means deciding equality of closure types, which overruns the
recursion depth at any budget worth setting.  Each condition is therefore discharged by hand
through `mem_Rchi` and the per-state facts, exactly as this round's Risks table directs and as the
eighteenth probe does -- `decide` closes concrete closure memberships, concrete `coh6` facts and
bounded quantifications over ONE closure type, and nothing else. -/

theorem ta_untl_free : ∀ ψ ∈ Ta.1, isUntl ψ = false := by decide

theorem tb_untl_only : ∀ ψ ∈ Tb.1, isUntl ψ = true → ψ = xxpa := by decide

theorem tc_untl_only : ∀ ψ ∈ Tc.1, isUntl ψ = true → ψ = xpa := by decide

theorem certLoc_Rchi : certLoc Rchi = true := by
  simp only [certLoc, decide_eq_true_eq]
  intro x hx
  rcases (mem_Rchi x).mp hx with rfl | rfl | rfl
  · decide
  · decide
  · decide

theorem certBiInf_Rchi : certBiInf Rchi = true := by
  simp only [certBiInf, decide_eq_true_eq]
  intro x hx
  rcases (mem_Rchi x).mp hx with rfl | rfl | rfl
  · exact ⟨Finset.card_pos.mpr ⟨(b5, Tb), Finset.mem_filter.mpr
        ⟨by rw [mem_Rchi]; exact Or.inr (Or.inl rfl), by decide⟩⟩,
      Finset.card_pos.mpr ⟨(c5, Tc), Finset.mem_filter.mpr
        ⟨by rw [mem_Rchi]; exact Or.inr (Or.inr rfl), by decide⟩⟩⟩
  · exact ⟨Finset.card_pos.mpr ⟨(c5, Tc), Finset.mem_filter.mpr
        ⟨by rw [mem_Rchi]; exact Or.inr (Or.inr rfl), by decide⟩⟩,
      Finset.card_pos.mpr ⟨(a5, Ta), Finset.mem_filter.mpr
        ⟨by rw [mem_Rchi]; exact Or.inl rfl, by decide⟩⟩⟩
  · exact ⟨Finset.card_pos.mpr ⟨(a5, Ta), Finset.mem_filter.mpr
        ⟨by rw [mem_Rchi]; exact Or.inl rfl, by decide⟩⟩,
      Finset.card_pos.mpr ⟨(b5, Tb), Finset.mem_filter.mpr
        ⟨by rw [mem_Rchi]; exact Or.inr (Or.inl rfl), by decide⟩⟩⟩

/-- Condition (3) on `Rchi`: its two `untl` obligations -- `xxpa` in `Tb` and `xpa` in `Tc` --
reach their events in ONE step inside `Rchi`, and `Ta` carries no `untl` member at all. -/
theorem certFwd_Rchi : certFwd Rchi = true := by
  rw [cert_fwd_iff_eu_lfp]
  intro x hx ψ hψ huntl
  rcases (mem_Rchi x).mp hx with rfl | rfl | rfl
  · rw [ta_untl_free ψ hψ] at huntl
    exact absurd huntl (by simp)
  · have hb : ψ = xxpa := tb_untl_only ψ hψ huntl
    subst hb
    refine (eu_mem_lfp_iff Rchi (succR Rchi) _ _ (b5, Tb)).mpr
      ⟨by rw [mem_Rchi]; exact Or.inr (Or.inl rfl), (c5, Tc), ?_, Or.inl (by decide)⟩
    exact Finset.mem_filter.mpr ⟨by rw [mem_Rchi]; exact Or.inr (Or.inr rfl), by decide⟩
  · have hc : ψ = xpa := tc_untl_only ψ hψ huntl
    subst hc
    refine (eu_mem_lfp_iff Rchi (succR Rchi) _ _ (c5, Tc)).mpr
      ⟨by rw [mem_Rchi]; exact Or.inr (Or.inr rfl), (a5, Ta), ?_, Or.inl (by decide)⟩
    exact Finset.mem_filter.mpr ⟨by rw [mem_Rchi]; exact Or.inl rfl, by decide⟩

/-- Condition (4) on `Rchi`: VACUOUS, because the closure has no backward temporal member.  The
condition is checked, not omitted. -/
theorem certBwd_Rchi : certBwd Rchi = true := by
  simp only [certBwd, decide_eq_true_eq]
  intro x _ ψ hψ hsnce
  rw [(chi_closure_box_snce_stab_free ψ (Finset.mem_powerset.mp x.2.2 hψ)).2.1] at hsnce
  exact absurd hsnce (by simp)

/-- Condition (5) on `Rchi`: VACUOUS, because the closure has no `stab` member.  The condition is
checked, not omitted -- which is why gate 8 is SIDESTEPPED and not passed. -/
theorem certStab_Rchi : certStab Rchi = true := by
  simp only [certStab, decide_eq_true_eq]
  intro x _ ψ hψ hstab
  rw [(chi_closure_box_snce_stab_free ψ hψ).2.2] at hstab
  exact absurd hstab (by simp)

/-- Condition (6) on `Rchi`: VACUOUS, because the closure has no `box` member.  Checked, not
omitted. -/
theorem certBox_Rchi : certBox Rchi = true := by
  simp only [certBox, decide_eq_true_eq]
  intro x _ ψ hψ hbox
  rw [(chi_closure_box_snce_stab_free ψ hψ).1] at hbox
  exact absurd hbox (by simp)

/-- **THE NON-VACUITY WITNESS: the certificate ACCEPTS a non-empty candidate set.**  Landed BEFORE
every negative statement about the certificate, which is the discipline gate 7's non-vacuity
obligation asks for: a certificate that accepted nothing would make every rejection below vacuous.
All six conditions hold on the `chi`-carrying 3-cycle, with conditions (4), (5) and (6) vacuous by
`chi_closure_box_snce_stab_free` and condition (3) discharged by its two `untl` obligations
reaching their events in one step inside `Rchi`. -/
theorem cert_accepts_Rchi : certAdm Rchi = true := by
  simp only [certAdm, certLoc_Rchi, certBiInf_Rchi, certFwd_Rchi, certBwd_Rchi, certStab_Rchi,
    certBox_Rchi, Bool.and_self]

/-! ## The adequacy separation: a set LOCAL COHERENCE ACCEPTS and the CERTIFICATE REJECTS

The substantive deliverable of this round.  `Rev` is the twentieth probe's `ev`-carrying 3-cycle:
local coherence and bi-infinity hold on it, and the certificate rejects it at the eventuality `ev`
because no guarded path inside `Rev` ever delivers `psi2`.  The rejection is proved structurally,
through `eu_lfp_eq_empty_of_no_event`, rather than by brute force -- the mechanism, not the
number.

This is NOT a refutation of the countdown profile, and `(a5, evTa)` is NOT claimed
non-realizable: `psi2` is deliverable on this object through the 2-cycle exit `a → d → a`, which
`Rev` excludes by construction.  What is rejected is `Rev` AS A CANDIDATE REALIZABLE SET. -/

/-- The twentieth probe's `ev`-carrying 3-cycle, as a candidate realizable set. -/
def Rev : Finset (ProdState Q5 chi) := {(a5, evTa), (b5, evTb), (c5, evTc)}

theorem mem_Rev (x : ProdState Q5 chi) :
    x ∈ Rev ↔ (x = (a5, evTa) ∨ x = (b5, evTb) ∨ x = (c5, evTc)) := by
  simp [Rev]

/-- The converse of `cohR_le_coh`: the restricted relation is assembled from the unrestricted one
and the two memberships.  Used throughout below so that no goal ever kernel-reduces a candidate
set literal. -/
theorem cohR_mk (R : Finset (ProdState Q5 chi)) {x y : ProdState Q5 chi}
    (h : coh6 x y = true) (hx : x ∈ R) (hy : y ∈ R) : cohR R x y = true := by
  simp only [cohR, Bool.and_eq_true, decide_eq_true_eq]
  exact ⟨⟨h, hx⟩, hy⟩

theorem a_mem_Rchi : ((a5, Ta) : ProdState Q5 chi) ∈ Rchi := by
  rw [mem_Rchi]; exact Or.inl rfl

theorem b_mem_Rchi : ((b5, Tb) : ProdState Q5 chi) ∈ Rchi := by
  rw [mem_Rchi]; exact Or.inr (Or.inl rfl)

theorem c_mem_Rchi : ((c5, Tc) : ProdState Q5 chi) ∈ Rchi := by
  rw [mem_Rchi]; exact Or.inr (Or.inr rfl)

theorem a_mem_Rev : ((a5, evTa) : ProdState Q5 chi) ∈ Rev := by
  rw [mem_Rev]; exact Or.inl rfl

theorem b_mem_Rev : ((b5, evTb) : ProdState Q5 chi) ∈ Rev := by
  rw [mem_Rev]; exact Or.inr (Or.inl rfl)

theorem c_mem_Rev : ((c5, evTc) : ProdState Q5 chi) ∈ Rev := by
  rw [mem_Rev]; exact Or.inr (Or.inr rfl)

/-- **The countdown profile of the RESTRICTED relation**, from the fibre `Ea ∩ R`: the set of
members of `R` from which a `cohR R`-chain of length `k` reaches `R`'s own `a`-fibre.  Still
parameter-free: no threshold, no modulus, no clip bound. -/
def ProfR (R : Finset (ProdState Q5 chi)) (k : ℕ) : Finset (ProdState Q5 chi) :=
  (prodPreStep (cohR R))^[k] (Ea ∩ R)

theorem profR_succ (R : Finset (ProdState Q5 chi)) (k : ℕ) :
    ProfR R (k + 1) = prodPreStep (cohR R) (ProfR R k) := by
  simp only [ProfR, Function.iterate_succ_apply']

theorem mem_profR_succ (R : Finset (ProdState Q5 chi)) (x : ProdState Q5 chi) (k : ℕ) :
    x ∈ ProfR R (k + 1) ↔ ∃ y ∈ ProfR R k, cohR R x y = true := by
  rw [profR_succ]
  simp [prodPreStep]

/-- **The restricted countdown lives inside `R`.**  The compiled form of "`cohR` confines the
iteration": the backward-reachability operator of the restricted relation never leaves `R`, so its
value is determined by `R` alone -- three elements here -- rather than by the `2 ^ 18 × 8`
carrier. -/
theorem profR_step_eq (R S : Finset (ProdState Q5 chi)) :
    prodPreStep (cohR R) S = R.filter (fun x => ∃ y ∈ S, cohR R x y = true) := by
  ext x
  simp only [prodPreStep, Finset.mem_filter, Finset.mem_univ, true_and]
  constructor
  · rintro ⟨y, hy, hxy⟩
    exact ⟨(cohR_le_coh R x y hxy).2.1, y, hy, hxy⟩
  · rintro ⟨-, hex⟩
    exact hex

theorem mem_Ea (x : ProdState Q5 chi) : x ∈ Ea ↔ x.1 = a5 := by simp [Ea]

/-! ## Local coherence accepts `Rev`, and the certificate does not -/

theorem certLoc_Rev : certLoc Rev = true := by
  simp only [certLoc, decide_eq_true_eq]
  intro x hx
  rcases (mem_Rev x).mp hx with rfl | rfl | rfl
  · decide
  · decide
  · decide

theorem certBiInf_Rev : certBiInf Rev = true := by
  simp only [certBiInf, decide_eq_true_eq]
  intro x hx
  rcases (mem_Rev x).mp hx with rfl | rfl | rfl
  · exact ⟨Finset.card_pos.mpr ⟨(b5, evTb), Finset.mem_filter.mpr ⟨b_mem_Rev, by decide⟩⟩,
      Finset.card_pos.mpr ⟨(c5, evTc), Finset.mem_filter.mpr ⟨c_mem_Rev, by decide⟩⟩⟩
  · exact ⟨Finset.card_pos.mpr ⟨(c5, evTc), Finset.mem_filter.mpr ⟨c_mem_Rev, by decide⟩⟩,
      Finset.card_pos.mpr ⟨(a5, evTa), Finset.mem_filter.mpr ⟨a_mem_Rev, by decide⟩⟩⟩
  · exact ⟨Finset.card_pos.mpr ⟨(a5, evTa), Finset.mem_filter.mpr ⟨a_mem_Rev, by decide⟩⟩,
      Finset.card_pos.mpr ⟨(b5, evTb), Finset.mem_filter.mpr ⟨b_mem_Rev, by decide⟩⟩⟩

/-- **The half that makes the rejection informative rather than trivial**, so it lands first:
local coherence (condition 1) and bi-infinity (condition 2) BOTH hold on `Rev`. -/
theorem coh_accepts_Rev : certLoc Rev = true ∧ certBiInf Rev = true :=
  ⟨certLoc_Rev, certBiInf_Rev⟩

/-- **No guarded path inside `Rev` ever delivers `psi2`.**  Proved through
`eu_lfp_eq_empty_of_no_event` -- `succR Rev` never leaves `Rev` and no member of `Rev` contains
`psi2` -- and NOT by `decide`: the structural proof is what exhibits the mechanism rather than the
number. -/
theorem rev_eu_lfp_empty :
    euLfp Rev (succR Rev) (fun w => decide (psi2 ∈ w.2.1)) (fun w => decide (top ∈ w.2.1))
      = ∅ := by
  refine eu_lfp_eq_empty_of_no_event Rev (succR Rev) _ _ ?_ ?_
  · intro v _ w hw
    exact (Finset.mem_filter.mp hw).1
  · intro w hw
    rcases (mem_Rev w).mp hw with rfl | rfl | rfl
    · decide
    · decide
    · decide

/-- **THE SEPARATION.**  `Rev` is accepted by local coherence and REJECTED by the certificate: its
member `(a5, evTa)` carries the eventuality `ev = top U psi2`, and condition (3) demands a guarded
forward path inside `Rev` that delivers `psi2`, which `rev_eu_lfp_empty` shows does not exist.  So
the certificate presentation computes something STRICTLY STRONGER than local coherence, which is
what makes the whole exercise non-vacuous.

What this does NOT say: `(a5, evTa)` is not claimed non-realizable -- `psi2` is deliverable on
this object through the 2-cycle exit `a → d → a`, which `Rev` excludes by construction -- and the
countdown profile is not refuted. -/
theorem cert_rejects_Rev : certAdm Rev = false := by
  have hfwd : certFwd Rev = false := by
    rcases Bool.eq_false_or_eq_true (certFwd Rev) with h | h
    · exfalso
      have hin := (cert_fwd_iff_eu_lfp Rev).mp h (a5, evTa) a_mem_Rev ev (by decide) (by decide)
      rw [show (argsOf ev).2 = psi2 from rfl, show (argsOf ev).1 = top from rfl,
        rev_eu_lfp_empty] at hin
      exact absurd hin (Finset.notMem_empty _)
    · exact h
  simp only [certAdm, hfwd, Bool.and_false, Bool.false_and]

/-! ## The restricted countdown profile, and the gate-6 separation it survives

The predecessor round's gate-6 win, re-run against the SMALLER relation.  This is not a new
gate-6 verdict: it records that the separation SURVIVES the refinement to a candidate set, and
gate 6's own row stands exactly as the eighteenth probe left it. -/

theorem profR_zero : ProfR Rchi 0 = {(a5, Ta)} := by
  have h0 : ProfR Rchi 0 = Ea ∩ Rchi := rfl
  rw [h0]
  ext x
  rw [Finset.mem_inter, mem_Ea, mem_Rchi, Finset.mem_singleton]
  constructor
  · rintro ⟨h1, h2 | h2 | h2⟩
    · exact h2
    · rw [h2] at h1; exact absurd h1 (by decide)
    · rw [h2] at h1; exact absurd h1 (by decide)
  · rintro rfl
    exact ⟨rfl, Or.inl rfl⟩

/-! The three values of the restricted profile, confirmed by `#eval` before the periodicity Goal
below is proved.  The `#eval` runs through `profR_step_eq`'s right-hand side -- `Rchi.filter`,
three elements -- and prints the OBJECT coordinate of each, since printing a closure type would
print its whole formula set: the three values are `{(true, 0)} = {a5}`, `{(true, 2)} = {c5}` and
`{(true, 1)} = {b5}`, so the profile runs `{(a5, Ta)}`, `{(c5, Tc)}`, `{(b5, Tb)}` at
`k % 3 = 0, 1, 2`.  `#eval` on the `Finset.univ`-shaped `prodPreStep` is not attempted: enumerating
the `2 ^ 18 × 8` carrier is exactly the whole-carrier computation this round's Risks table
forbids. -/
#eval (Ea ∩ Rchi).image Prod.fst
#eval (Rchi.filter (fun x => ∃ y ∈ ({(a5, Ta)} : Finset (ProdState Q5 chi)),
  cohR Rchi x y = true)).image Prod.fst
#eval (Rchi.filter (fun x => ∃ y ∈ ({(c5, Tc)} : Finset (ProdState Q5 chi)),
  cohR Rchi x y = true)).image Prod.fst
#eval (Rchi.filter (fun x => ∃ y ∈ ({(b5, Tb)} : Finset (ProdState Q5 chi)),
  cohR Rchi x y = true)).image Prod.fst

theorem profR_one : ProfR Rchi 1 = {(c5, Tc)} := by
  ext x
  rw [mem_profR_succ, Finset.mem_singleton]
  constructor
  · rintro ⟨y, hy, hxy⟩
    rw [profR_zero, Finset.mem_singleton] at hy
    subst hy
    obtain ⟨hcoh, hxR, -⟩ := cohR_le_coh Rchi x (a5, Ta) hxy
    rcases (mem_Rchi x).mp hxR with rfl | rfl | rfl
    · exact absurd hcoh (by decide)
    · exact absurd hcoh (by decide)
    · rfl
  · rintro rfl
    refine ⟨(a5, Ta), ?_, cohR_mk Rchi (by decide) c_mem_Rchi a_mem_Rchi⟩
    rw [profR_zero]
    exact Finset.mem_singleton_self _

theorem profR_two : ProfR Rchi 2 = {(b5, Tb)} := by
  ext x
  rw [mem_profR_succ, Finset.mem_singleton]
  constructor
  · rintro ⟨y, hy, hxy⟩
    rw [profR_one, Finset.mem_singleton] at hy
    subst hy
    obtain ⟨hcoh, hxR, -⟩ := cohR_le_coh Rchi x (c5, Tc) hxy
    rcases (mem_Rchi x).mp hxR with rfl | rfl | rfl
    · exact absurd hcoh (by decide)
    · rfl
    · exact absurd hcoh (by decide)
  · rintro rfl
    refine ⟨(c5, Tc), ?_, cohR_mk Rchi (by decide) b_mem_Rchi c_mem_Rchi⟩
    rw [profR_one]
    exact Finset.mem_singleton_self _

theorem profR_three : ProfR Rchi 3 = {(a5, Ta)} := by
  ext x
  rw [mem_profR_succ, Finset.mem_singleton]
  constructor
  · rintro ⟨y, hy, hxy⟩
    rw [profR_two, Finset.mem_singleton] at hy
    subst hy
    obtain ⟨hcoh, hxR, -⟩ := cohR_le_coh Rchi x (b5, Tb) hxy
    rcases (mem_Rchi x).mp hxR with rfl | rfl | rfl
    · rfl
    · exact absurd hcoh (by decide)
    · exact absurd hcoh (by decide)
  · rintro rfl
    refine ⟨(b5, Tb), ?_, cohR_mk Rchi (by decide) a_mem_Rchi b_mem_Rchi⟩
    rw [profR_two]
    exact Finset.mem_singleton_self _

/-- **THE RESTRICTED PROFILE HAS PERIOD THREE**, with nothing to choose: the restricted relation
on `Rchi` is the 3-cycle, so the backward-reachability operator returns to its starting value
after three steps. -/
theorem profR_period_three (k : ℕ) : ProfR Rchi (k + 3) = ProfR Rchi k := by
  have h : ProfR Rchi (k + 3)
      = (prodPreStep (cohR Rchi))^[k] ((prodPreStep (cohR Rchi))^[3] (Ea ∩ Rchi)) := by
    rw [ProfR, Function.iterate_add_apply]
  have h3 : (prodPreStep (cohR Rchi))^[3] (Ea ∩ Rchi) = Ea ∩ Rchi := by
    show ProfR Rchi 3 = ProfR Rchi 0
    rw [profR_three, profR_zero]
  rw [h, h3]
  rfl

theorem profR_add_mul (k m : ℕ) : ProfR Rchi (k + 3 * m) = ProfR Rchi k := by
  induction m with
  | zero => rfl
  | succ m ih =>
    rw [show k + 3 * (m + 1) = k + 3 * m + 3 by ring, profR_period_three, ih]

/-- **And the `a`-fibre is nonempty at every multiple of three**, witnessed by the coherent
3-cycle the certificate accepts. -/
theorem profR_fibre_a_witness (k : ℕ) (hk : 3 ∣ k) : (a5, Ta) ∈ ProfR Rchi k := by
  obtain ⟨m, rfl⟩ := hk
  have h : ProfR Rchi (3 * m) = ProfR Rchi 0 := by
    rw [show 3 * m = 0 + 3 * m by ring, profR_add_mul]
  rw [h, profR_zero]
  exact Finset.mem_singleton_self _

/-- And it is EMPTY at every index that is not a multiple of three. -/
theorem profR_dvd_of_mem (n : ℕ) (h : (a5, Ta) ∈ ProfR Rchi n) : 3 ∣ n := by
  have hmod : ProfR Rchi n = ProfR Rchi (n % 3) := by
    conv_lhs => rw [show n = n % 3 + 3 * (n / 3) from by omega]
    rw [profR_add_mul]
  rw [hmod] at h
  have h3 : n % 3 = 0 ∨ n % 3 = 1 ∨ n % 3 = 2 := by omega
  rcases h3 with he | he | he
  · omega
  · rw [he, profR_one, Finset.mem_singleton] at h
    exact absurd (congrArg Prod.fst h) (by decide)
  · rw [he, profR_two, Finset.mem_singleton] at h
    exact absurd (congrArg Prod.fst h) (by decide)

/-- **THE PREDECESSOR ROUND'S GATE-6 SEPARATION SURVIVES THE REFINEMENT TO A CANDIDATE SET**, for
EVERY modulus coprime to three, with no parameter to choose.  This is not a new gate-6 verdict:
gate 6's own row stands as the eighteenth probe left it, and what is recorded here is that
restricting the relation to the certificate's candidate set does not cost the separation. -/
theorem profR_separates_gate6_pair (C P : ℕ) (hC : 3 ∣ C) (h3 : ¬ 3 ∣ (P + 1)) :
    ProfR Rchi C ≠ ProfR Rchi (C + (P + 1)) := by
  intro h
  have hmem : (a5, Ta) ∈ ProfR Rchi C := profR_fibre_a_witness C hC
  rw [h] at hmem
  have h1 : 3 ∣ C + (P + 1) := profR_dvd_of_mem _ hmem
  exact h3 (by omega)

end Probe809C

/-! ## Axiom check -/

#print axioms Probe809C.eu_step_mono
#print axioms Probe809C.eu_lfp_fixed
#print axioms Probe809C.eu_mem_lfp_iff
#print axioms Probe809C.eu_lfp_least
#print axioms Probe809C.eu_mem_lfp_iff_exists_path
#print axioms Probe809C.eu_lfp_eq_empty_of_no_event
#print axioms Probe809C.au_lfp_ne_eu_lfp_on_exit_graph
#print axioms Probe809C.untl_propagates_along_coh
#print axioms Probe809C.cohR_le_coh
#print axioms Probe809C.chi_closure_box_snce_stab_free
#print axioms Probe809C.cert_fwd_iff_eu_lfp
#print axioms Probe809C.cert_accepts_Rchi
#print axioms Probe809C.coh_accepts_Rev
#print axioms Probe809C.rev_eu_lfp_empty
#print axioms Probe809C.cert_rejects_Rev
#print axioms Probe809C.profR_period_three
#print axioms Probe809C.profR_fibre_a_witness
#print axioms Probe809C.profR_separates_gate6_pair
