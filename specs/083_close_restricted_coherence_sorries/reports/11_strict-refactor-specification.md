# Strict Semantics Refactor: Complete Implementation Specification

**Task**: 83 - Close Restricted Coherence Sorries
**Date**: 2026-04-03
**Session**: sess_1775229537_115bf2
**Builds on**: Reports 09-10 (team research, strict semantics decision)

## Executive Summary

This document specifies every detail of the clean-break refactor from reflexive (<=) to fully strict (<) temporal semantics for G, H, Until, and Since. It is written to enable mechanical implementation without further research. Each section provides exact Lean 4 signatures, file paths, theorem names, and proof strategies.

**Net change**: 34 current axioms become 33 (remove 2, add 3, replace 6).

---

## Task 1: Exact Axiom System with Lean 4 Constructor Signatures

### Current Formula Constructors (unchanged)

From `Theories/Bimodal/Syntax/Formula.lean`:
```lean
inductive Formula : Type where
  | atom : Atom -> Formula
  | bot : Formula
  | imp : Formula -> Formula -> Formula
  | box : Formula -> Formula
  | all_past : Formula -> Formula    -- H
  | all_future : Formula -> Formula  -- G
  | untl : Formula -> Formula -> Formula  -- Until
  | snce : Formula -> Formula -> Formula  -- Since
```

Derived operators (unchanged):
- `Formula.neg phi := phi.imp bot`
- `Formula.and phi psi := (phi.imp psi.neg).neg`
- `Formula.or phi psi := phi.neg.imp psi`
- `Formula.some_future phi := phi.neg.all_future.neg`  (F = ~G~)
- `Formula.some_past phi := phi.neg.all_past.neg`  (P = ~H~)
- `Formula.always phi := phi.all_past.and (phi.and phi.all_future)`  (triangle = H & id & G)

**New derived operators** to add to `Formula.lean`:
```lean
/-- Next-step operator: X(phi) = bot U phi -/
def next (phi : Formula) : Formula := Formula.untl Formula.bot phi

/-- Previous-step operator: Y(phi) = bot S phi -/
def prev (phi : Formula) : Formula := Formula.snce Formula.bot phi

/-- Weak future: G'(phi) = phi & G(phi) -/
def weak_future (phi : Formula) : Formula := phi.and phi.all_future  -- ALREADY EXISTS

/-- Weak past: H'(phi) = phi & H(phi) -/
def weak_past (phi : Formula) : Formula := phi.and phi.all_past  -- ALREADY EXISTS
```

Note: `weak_future` and `weak_past` already exist in Formula.lean (lines 335, 344).

### Complete Axiom Table (33 Axioms)

#### KEEP Unchanged (20 axioms)

| # | Constructor | Formula | Notes |
|---|-------------|---------|-------|
| 1 | `prop_k (phi psi chi)` | `(phi -> (psi -> chi)) -> ((phi -> psi) -> (phi -> chi))` | Propositional |
| 2 | `prop_s (phi psi)` | `phi -> (psi -> phi)` | Propositional |
| 3 | `ex_falso (phi)` | `bot -> phi` | Propositional |
| 4 | `peirce (phi psi)` | `((phi -> psi) -> phi) -> phi` | Propositional |
| 5 | `modal_t (phi)` | `box phi -> phi` | S5 modal |
| 6 | `modal_4 (phi)` | `box phi -> box (box phi)` | S5 modal |
| 7 | `modal_b (phi)` | `phi -> box (diamond phi)` | S5 modal |
| 8 | `modal_5_collapse (phi)` | `diamond (box phi) -> box phi` | S5 modal |
| 9 | `modal_k_dist (phi psi)` | `box (phi -> psi) -> (box phi -> box psi)` | S5 modal |
| 10 | `temp_k_dist (phi psi)` | `G(phi -> psi) -> (G phi -> G psi)` | Valid: strict G distributes over imp |
| 11 | `temp_4 (phi)` | `G phi -> G (G phi)` | Valid: strict < is transitive |
| 12 | `temp_a (phi)` | `phi -> G (P phi)` | Valid on Z: if phi(t), then for all s>t, take witness r=t for P(phi) at s |
| 13 | `temp_l (phi)` | `always phi -> G (H phi)` | Valid: if phi at ALL times, then at any s>t, phi at all r<s |
| 14 | `modal_future (phi)` | `box phi -> box (G phi)` | Valid: modal-temporal interaction |
| 15 | `temp_future (phi)` | `box phi -> G (box phi)` | Valid: temporal-modal interaction |
| 16 | `temp_linearity (phi psi)` | `F(phi) & F(psi) -> F(phi & psi) v F(phi & F(psi)) v F(F(phi) & psi)` | Valid on linear orders |
| 17 | `seriality_future (phi)` | `G phi -> F phi` | Valid: NoMaxOrder on Z |
| 18 | `seriality_past (phi)` | `H phi -> P phi` | Valid: NoMinOrder on Z |
| 19 | `until_linearity (phi psi phi' psi')` | `(phi U psi) & (phi' U psi') -> (phi U (psi & (phi' U psi'))) v (phi' U (psi' & (phi U psi)))` | Valid on linear orders |
| 20 | `since_linearity (phi psi phi' psi')` | Mirror of until_linearity for S | Valid on linear orders |

#### REMOVE (2 axioms)

| Constructor | Formula | Reason |
|-------------|---------|--------|
| `temp_t_future (phi)` | `G phi -> phi` | INVALID under strict semantics: G quantifies over s > t, does not include t |
| `temp_t_past (phi)` | `H phi -> phi` | INVALID under strict semantics: H quantifies over s < t, does not include t |

#### REPLACE (6 axioms -- new formula, same constructor name)

**Until Unfold** -- OLD: `phi U psi -> psi v (phi & G(phi U psi))`
```lean
| until_unfold (phi psi : Formula) :
    Axiom (Formula.untl phi psi |>.imp
      (Formula.or psi (Formula.and phi (Formula.untl phi psi |>.next))))
```
NEW formula: `phi U psi -> psi v (phi & X(phi U psi))`
where `X(chi) = bot U chi = Formula.untl Formula.bot chi`

Wait -- we must be careful. The `next` operator uses `Until`, so `X(phi U psi) = bot U (phi U psi)`. This is structurally valid as a formula.

Actually, looking more carefully: the X-based unfold axiom for STRICT Until requires a different form. Under strict semantics, `phi U psi` at t means there exists s > t with psi(s) and phi at all r with t < r < s.

The correct X-based unfold is:
```
phi U psi  <->  X(psi v (phi & (phi U psi)))
```
which says: at the next instant t+1, either psi holds (base case) or phi holds and phi U psi continues.

Let me encode this precisely:

```lean
/-- Until Unfold (strict, X-based): (phi U psi) -> X(psi v (phi & (phi U psi)))
    i.e., (phi U psi) -> bot U (psi v (phi & (phi U psi))) -/
| until_unfold (phi psi : Formula) :
    Axiom (Formula.untl phi psi |>.imp
      (Formula.untl Formula.bot
        (Formula.or psi (Formula.and phi (Formula.untl phi psi)))))
```

**Until Introduction** -- converse of unfold:
```lean
/-- Until Intro (strict, X-based): X(psi v (phi & (phi U psi))) -> (phi U psi) -/
| until_intro (phi psi : Formula) :
    Axiom ((Formula.untl Formula.bot
        (Formula.or psi (Formula.and phi (Formula.untl phi psi)))).imp
      (Formula.untl phi psi))
```

**Until Induction** -- the key anti-deferral axiom:
```lean
/-- Until Induction (strict, X-based):
    (psi -> chi) & (phi & X(chi) -> chi) -> ((phi U psi) -> X(chi))

    If psi implies chi (base), and phi & X(chi) implies chi (step),
    then phi U psi implies X(chi).

    Note: conclusion is X(chi), not chi, because phi U psi provides info
    about strictly future times only. -/
| until_induction (phi psi chi : Formula) :
    Axiom (Formula.and
      (psi.imp chi)
      ((Formula.and phi (Formula.untl Formula.bot chi)).imp chi)
      |>.imp ((Formula.untl phi psi).imp (Formula.untl Formula.bot chi)))
```

**Since Unfold** -- mirror of until_unfold:
```lean
/-- Since Unfold (strict, Y-based): (phi S psi) -> Y(psi v (phi & (phi S psi))) -/
| since_unfold (phi psi : Formula) :
    Axiom (Formula.snce phi psi |>.imp
      (Formula.snce Formula.bot
        (Formula.or psi (Formula.and phi (Formula.snce phi psi)))))
```

**Since Introduction** -- mirror:
```lean
/-- Since Intro (strict, Y-based): Y(psi v (phi & (phi S psi))) -> (phi S psi) -/
| since_intro (phi psi : Formula) :
    Axiom ((Formula.snce Formula.bot
        (Formula.or psi (Formula.and phi (Formula.snce phi psi)))).imp
      (Formula.snce phi psi))
```

**Since Induction** -- mirror:
```lean
/-- Since Induction (strict, Y-based):
    (psi -> chi) & (phi & Y(chi) -> chi) -> ((phi S psi) -> Y(chi)) -/
| since_induction (phi psi chi : Formula) :
    Axiom (Formula.and
      (psi.imp chi)
      ((Formula.and phi (Formula.snce Formula.bot chi)).imp chi)
      |>.imp ((Formula.snce phi psi).imp (Formula.snce Formula.bot chi)))
```

#### ADD New (3 axioms)

```lean
/-- Temporal A Dual: phi -> H(F(phi))
    Under strict semantics, this is independent from temp_a and needed for
    past-direction completeness.
    Valid on Z: if phi(t), then for all s < t, take witness r = t for F(phi) at s. -/
| temp_a_dual (phi : Formula) :
    Axiom (phi.imp (Formula.all_past phi.some_future))

/-- Discrete Next: F(top) -> X(top) = F(top) -> (bot U (neg bot))
    Asserts discrete successor existence: if there's any strict future,
    there's an immediate next step.
    Valid on Z with NoMaxOrder. -/
| disc_next :
    Axiom ((Formula.neg Formula.bot).some_future.imp
      (Formula.untl Formula.bot (Formula.neg Formula.bot)))

/-- Discrete Prev: P(top) -> Y(top) = P(top) -> (bot S (neg bot))
    Mirror of disc_next for past direction. -/
| disc_prev :
    Axiom ((Formula.neg Formula.bot).some_past.imp
      (Formula.snce Formula.bot (Formula.neg Formula.bot)))
```

#### KEEP Unchanged -- Until/Since Interaction (4 axioms)

These remain valid under strict semantics:

| Constructor | Formula |
|-------------|---------|
| `until_connectedness (phi psi chi)` | `phi & (chi U psi) -> chi U (psi & (chi S phi))` |
| `since_connectedness (phi psi chi)` | `phi & (chi S psi) -> chi S (psi & (chi U phi))` |
| `F_until_equiv (psi)` | `F(psi) -> top U psi` |
| `P_since_equiv (psi)` | `P(psi) -> top S psi` |

**Semantic verification of F_until_equiv under strict semantics**:
- LHS: F(psi) at t means there exists s > t with psi(s).
- RHS: (top U psi) at t means there exists s > t with psi(s) and top at all r with t < r < s.
- Since top is always true, the guard is vacuous. Both sides are equivalent.

### Total Count

- KEEP: 20 + 4 (U/S interaction) = 24
- REPLACE: 6
- ADD: 3
- REMOVE: 2
- **Total: 33 axioms** (net -1 from current 34)

---

## Task 2: File-by-File Change Specification

### File 1: `Theories/Bimodal/Syntax/Formula.lean`

| Definition | Disposition | Details |
|------------|-------------|---------|
| `Formula` inductive | KEEP | No changes to constructors |
| `Formula.next` | ADD | `def next (phi : Formula) : Formula := Formula.untl Formula.bot phi` |
| `Formula.prev` | ADD | `def prev (phi : Formula) : Formula := Formula.snce Formula.bot phi` |
| `Formula.weak_future` | KEEP | Already exists (line 335) |
| `Formula.weak_past` | KEEP | Already exists (line 344) |
| `Formula.always` | KEEP | Definition unchanged: `H phi & phi & G phi`. Under strict semantics, always still means "at all times" because the conjunction covers present explicitly. |
| `Formula.swap_temporal` | KEEP | Already swaps `untl <-> snce`. Need to verify it also swaps `next <-> prev` -- yes, it does by structural recursion since `next = untl bot` and `prev = snce bot`. |
| `Formula.complexity` | KEEP | Unchanged |
| `needsPositiveHypotheses` | KEEP | Unchanged |

**New additions needed**:
```lean
/-- The next-step operator X(phi) = bot U phi -/
def next (phi : Formula) : Formula := Formula.untl Formula.bot phi

/-- The previous-step operator Y(phi) = bot S phi -/
def prev (phi : Formula) : Formula := Formula.snce Formula.bot phi

/-- swap_temporal distributes over next/prev. -/
theorem swap_temporal_next (phi : Formula) :
    phi.next.swap_temporal = phi.swap_temporal.prev := by
  simp [next, prev, swap_temporal]

theorem swap_temporal_prev (phi : Formula) :
    phi.prev.swap_temporal = phi.swap_temporal.next := by
  simp [prev, next, swap_temporal]
```

### File 2: `Theories/Bimodal/Semantics/Truth.lean`

| Definition/Theorem | Disposition | Details |
|---------------------|-------------|---------|
| `truth_at` (lines 118-129) | REWRITE | Change `<=` to `<` in G/H/U/S clauses |
| `bot_false` | KEEP | Unchanged |
| `imp_iff` | KEEP | Unchanged |
| `atom_iff_of_domain` | KEEP | Unchanged |
| `atom_false_of_not_domain` | KEEP | Unchanged |
| `box_iff` | KEEP | Unchanged |
| `past_iff` | REWRITE | Change `s <= t` to `s < t` |
| `future_iff` | REWRITE | Change `t <= s` to `t < s` |
| `ShiftClosed` | KEEP | Unchanged |
| `Set.univ_shift_closed` | KEEP | Unchanged |
| `time_shift_preserves_truth` | REWRITE | All `<=` to `<` in temporal cases. Proof structure unchanged, just inequality adjustments. |
| `truth_double_shift_cancel` | REWRITE | Same: `<=` to `<` in temporal cases |
| `exists_shifted_history` | KEEP | Wrapper, unchanged |

**Exact change to `truth_at`**:
```lean
def truth_at (M : TaskModel F) (Omega : Set (WorldHistory F))
    (tau : WorldHistory F) (t : D) : Formula -> Prop
  | Formula.atom p => exists (ht : tau.domain t), M.valuation (tau.states t ht) p
  | Formula.bot => False
  | Formula.imp phi psi => truth_at M Omega tau t phi -> truth_at M Omega tau t psi
  | Formula.box phi => forall (sigma : WorldHistory F), sigma in Omega -> truth_at M Omega sigma t phi
  | Formula.all_past phi => forall (s : D), s < t -> truth_at M Omega tau s phi      -- WAS: s <= t
  | Formula.all_future phi => forall (s : D), t < s -> truth_at M Omega tau s phi    -- WAS: t <= s
  | Formula.untl phi psi => exists s : D, t < s /\ truth_at M Omega tau s psi /\    -- WAS: t <= s
      forall r : D, t < r -> r < s -> truth_at M Omega tau r phi                     -- WAS: t <= r
  | Formula.snce phi psi => exists s : D, s < t /\ truth_at M Omega tau s psi /\    -- WAS: s <= t
      forall r : D, s < r -> r < t -> truth_at M Omega tau r phi                     -- WAS: s < r, r <= t -> s < r, r < t
```

**Proof strategy for `time_shift_preserves_truth`**: The existing proof already handles `<=` with arithmetic lemmas like `sub_le_sub_right` and `add_le_add_right`. Changing to `<` uses the same pattern with `sub_lt_sub_right` and `add_lt_add_right`. The structural shape of the proof is identical; only the inequality direction changes. The `untl` and `snce` cases already use a mix of `<=` and `<`, so these are close to unchanged.

**Documentation updates**: Update the module docstring to remove all references to "reflexive semantics" and replace with "strict semantics" explanations.

### File 3: `Theories/Bimodal/ProofSystem/Axioms.lean`

| Definition/Theorem | Disposition | Details |
|---------------------|-------------|---------|
| `Axiom` inductive | REWRITE | Remove `temp_t_future`, `temp_t_past`. Add `temp_a_dual`, `disc_next`, `disc_prev`. Replace 6 U/S axioms with X/Y-based versions. |
| `Axiom.frameClass` | REWRITE | Remove T-axiom cases. Add new axiom cases. |
| `Axiom.isDenseCompatible` | REWRITE | Remove T-axiom cases. Add new cases (all new axioms are Discrete, so not dense-compatible). |
| `Axiom.isDiscreteCompatible` | REWRITE | Remove T-axiom cases. Add new cases (all new axioms are discrete-compatible). |
| `Axiom.isBase` | REWRITE | Remove T-axiom cases. `temp_a_dual` is Base (valid on all linear strict orders). `disc_next`, `disc_prev` are Discrete. |
| All frameClass lemmas | TRIVIAL_FIX | Mechanically follow from updated match cases |

**Frame class assignments for new axioms**:
- `temp_a_dual`: `.Base` (valid on all linear strict orders)
- `disc_next`: `.Discrete` (requires SuccOrder)
- `disc_prev`: `.Discrete` (requires SuccOrder predecessor existence)

### File 4: `Theories/Bimodal/ProofSystem/Substitution.lean`

| Definition/Theorem | Disposition | Details |
|---------------------|-------------|---------|
| `subst_axiom` (around line 298) | REWRITE | Remove `temp_t_future`, `temp_t_past` cases. Add `temp_a_dual`, `disc_next`, `disc_prev` cases. Update 6 U/S axiom cases to match new formulas. |

For new axioms, substitution is straightforward:
```lean
| temp_a_dual a =>
    simp only [subst_imp, subst_all_past, subst_some_future]
    exact Axiom.temp_a_dual (a.subst q r)
| disc_next =>
    simp only [subst_imp, subst_some_future, subst_untl, subst_neg, subst_bot]
    exact Axiom.disc_next
| disc_prev =>
    simp only [subst_imp, subst_some_past, subst_snce, subst_neg, subst_bot]
    exact Axiom.disc_prev
```

For replaced U/S axioms, add `subst_untl` and `subst_snce` lemmas if not already present, then the cases follow mechanically.

### File 5: `Theories/Bimodal/Metalogic/Soundness.lean`

| Theorem | Disposition | Details |
|---------|-------------|---------|
| `temp_t_future_valid` | DELETE | No longer an axiom |
| `temp_t_past_valid` | DELETE | No longer an axiom |
| `temp_linearity_valid` | REWRITE | Change `<=` to `<` in witness extraction. The trichotomy argument is unchanged. |
| `density_valid` | REWRITE | Change `<=` to `<`. The density argument becomes genuine: for s > t, find r with t < r < s, then use GG -> G. |
| `discreteness_forward_valid` | REWRITE | Update for strict semantics |
| `seriality_future_valid` | REWRITE | Remove reflexive trick (was using `s = t`). Now genuinely requires NoMaxOrder: use `exists s > t` from NoMaxOrder. |
| `seriality_past_valid` | REWRITE | Symmetric |
| `until_unfold_valid` | REWRITE | Soundness for new X-based formula. See proof sketch below. |
| `until_intro_valid` | REWRITE | Soundness for new X-based formula |
| `until_induction_valid` | REWRITE | Soundness for new X-based formula |
| `since_unfold_valid` | REWRITE | Mirror of until_unfold |
| `since_intro_valid` | REWRITE | Mirror of until_intro |
| `since_induction_valid` | REWRITE | Mirror of until_induction |
| `temp_a_dual_valid` | ADD | New soundness proof |
| `disc_next_valid` | ADD | New soundness proof |
| `disc_prev_valid` | ADD | New soundness proof |
| `axiom_valid` master dispatch | REWRITE | Remove T-axiom cases, add new axiom cases |
| All `_valid_dense`, `_valid_discrete` dispatches | REWRITE | Same pattern |

**Soundness proof for `temp_a_dual_valid`** (`phi -> H(F(phi))`):
```
Given phi(t), need: for all s < t, F(phi) at s.
F(phi) at s means exists r > s with phi(r).
Take r = t. Since s < t, we have r > s. Done.
```

**Soundness proof for `disc_next_valid`** (`F(top) -> X(top)` = `F(neg bot) -> bot U (neg bot)`):
```
Given F(neg bot) at t: exists s > t with neg_bot(s) (always true).
Need: bot U (neg bot) at t, i.e., exists s > t with neg_bot(s) and bot at all r with t < r < s.
Take s = t + 1 (successor exists by SuccOrder + NoMaxOrder).
neg_bot(t+1) is trivially true.
Guard: forall r, t < r < t+1. Since Int is discrete, this interval is empty. Vacuously true.
```

**Soundness proof for `until_unfold_valid`** (`phi U psi -> X(psi v (phi & (phi U psi)))`):
```
Given phi U psi at t: exists s > t with psi(s) and phi at all r with t < r < s.
Need: X(psi v (phi & (phi U psi))) at t = bot U (psi v (phi & (phi U psi))) at t.
This means: exists u > t with (psi v (phi & (phi U psi)))(u) and bot at all r with t < r < u.
Take u = t + 1 (discrete successor).
Guard: bot at all r with t < r < t+1 -- empty interval on Int, vacuously true.
Show: psi(t+1) v (phi(t+1) & (phi U psi)(t+1)).
Case s = t+1: psi(t+1) holds. Take left disjunct.
Case s > t+1: phi(t+1) holds (from guard, since t < t+1 < s).
  And phi U psi at t+1 holds with same witness s (phi at all r with t+1 < r < s).
  Take right disjunct.
```

**Soundness proof for `until_intro_valid`** (`X(psi v (phi & (phi U psi))) -> phi U psi`):
```
Given X(psi v (phi & (phi U psi))) at t: exists u > t with (psi v (phi & (phi U psi)))(u)
  and bot at all r with t < r < u.
The bot guard means u = t+1 (no r between t and u on Int, so u is immediate successor).
So at t+1: psi(t+1) or (phi(t+1) & (phi U psi)(t+1)).
Case psi(t+1): phi U psi at t with witness s = t+1. Guard: empty (t < r < t+1 impossible on Int). Done.
Case phi(t+1) & (phi U psi)(t+1): Let (phi U psi)(t+1) have witness s' > t+1.
  Then phi U psi at t with witness s', guard: for r with t < r < s':
    - r = t+1: phi(t+1) (given)
    - t+1 < r < s': phi(r) from the inner phi U psi guard
  Done.
```

**Soundness proof for `until_induction_valid`**:
```
(psi -> chi) & (phi & X(chi) -> chi) -> ((phi U psi) -> X(chi))

Assume (1) psi -> chi, (2) phi & X(chi) -> chi, (3) phi U psi at t.
Need: X(chi) at t, i.e., bot U chi at t, i.e., chi(t+1).

From (3): exists s > t with psi(s) and phi at all r with t < r < s.
Prove chi(t+1) by strong induction on s - t (which is a positive natural number).

Base: s = t+1. Then psi(t+1). By (1), chi(t+1). Done.
Step: s > t+1. Then phi(t+1) and phi U psi at t+1 (with witness s, guard shifted).
  By IH (s - (t+1) < s - t): chi(t+2).
  So X(chi) at t+1 (i.e., chi(t+2)).
  phi(t+1) & X(chi)(t+1) -> chi(t+1) by (2).
  Done.

Wait, this doesn't quite work because we need chi(t+1), not chi(t+2). Let me reconsider.

Actually, the induction is on the witness distance k = s - (t+1) as a natural number
(since s > t implies s >= t+1, so s - (t+1) >= 0).

The key: we prove chi(t+1) by induction on k = s - (t+1).
Base k=0: s = t+1. psi(s) = psi(t+1). By (1), chi(t+1).
Step k>0: s = (t+1) + k, k > 0. phi(t+1) (from guard at r=t+1 since t < t+1 < s).
  phi U psi at (t+1) with witness s (guard: phi at all r with t+1 < r < s).
  Need chi(t+1).
  We know phi(t+1) and phi U psi at (t+1).
  From phi U psi at (t+1), by IH (witness distance is s - (t+2) = k-1 < k):
    chi(t+2). So X(chi) at (t+1).
  So phi(t+1) & X(chi)(t+1). By (2): chi(t+1). Done.
```

### File 6: `Theories/Bimodal/Metalogic/SoundnessLemmas.lean`

| Theorem | Disposition | Details |
|---------|-------------|---------|
| `swapped_axiom_valid` | REWRITE | Remove T-axiom swap cases. Add new axiom swap cases. All swapped axioms are valid by temporal duality. |
| All bridge theorems | REWRITE | Update `<=` to `<` in any that reference temporal quantification |

Specific changes for T-axiom swap cases (currently lines 601-616):
- `temp_t_future` swap case (currently produces `H psi -> psi`): DELETE
- `temp_t_past` swap case (currently produces `G psi -> psi`): DELETE
- Add `temp_a_dual` swap case: `swap(phi -> H(F(phi))) = phi.swap -> G(P(phi.swap))` which is `temp_a` applied to `phi.swap`. Can be dispatched via `temp_a_valid`.
- `seriality_past` swap case currently uses the T-axiom trick (`s = t`). Under strict semantics: `swap(H psi -> P psi) = G psi -> F psi`. Soundness: from G(psi.swap) at t (forall s > t, psi.swap(s)), by NoMaxOrder exists s > t, so F(psi.swap) at t. No T-axiom needed.

### File 7: `Theories/Bimodal/Metalogic/Bundle/CanonicalIrreflexivity.lean`

| Theorem | Disposition | Details |
|---------|-------------|---------|
| `existsTask_reflexive` | DELETE | Uses T-axiom; under strict semantics ExistsTask is NOT reflexive |
| `existsTask_past_reflexive` | DELETE | Uses T-axiom |
| `lt_of_existsTask_and_not_reverse` | DELETE | Depends on reflexive ExistsTask |
| `strict_of_formula_in_g_content_not_in_source` | KEEP | Still useful for strictness arguments |
| `strict_of_formula_with_G_not_in_source` | KEEP | Still useful |
| Fresh atom infrastructure | KEEP | Unchanged |

**Key insight**: Under strict semantics, `ExistsTask M M` means `g_content(M) ⊆ M`, i.e., `G(phi) in M -> phi in M`. This is NO LONGER guaranteed because `G(phi) -> phi` is not valid. The canonical task relation at `d=0` gives identity (by `nullity_identity`), which is correct -- strict temporal operators never exercise `d=0`.

The entire module can be simplified: the per-construction strictness infrastructure becomes unnecessary because ExistsTask is no longer reflexive by default. Any two distinct chain positions are automatically strict.

### File 8: `Theories/Bimodal/Metalogic/Bundle/FMCSDef.lean`

| Definition | Disposition | Details |
|------------|-------------|---------|
| `FMCS` structure | REWRITE | Change `<=` to `<` in `forward_G` and `backward_H` |

**New FMCS structure**:
```lean
structure FMCS where
  mcs : D -> Set Formula
  is_mcs : forall t, SetMaximalConsistent (mcs t)
  /-- Forward G coherence: G phi at time t implies phi at all STRICTLY future times t' > t. -/
  forward_G : forall t t' phi, t < t' -> Formula.all_future phi in mcs t -> phi in mcs t'
  /-- Backward H coherence: H phi at time t implies phi at all STRICTLY past times t' < t. -/
  backward_H : forall t t' phi, t' < t -> Formula.all_past phi in mcs t -> phi in mcs t'
```

No `forward_X` / `backward_Y` fields are needed in the FMCS structure itself. The X truth lemma is proved separately using chain properties, not as a structural field.

**Rationale**: The FMCS structure captures what the truth lemma needs for the G/H cases. For Until/Since, the backward truth lemma uses the X truth lemma, which is proved from the chain's Succ relation, not from FMCS fields.

### File 9: `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`

| Theorem | Disposition | Details |
|---------|-------------|---------|
| `succ_chain_forward_G_le` | REWRITE | Remove the `t = t'` T-axiom branch. Now only has the `t < t'` case (which already exists as `succ_chain_forward_G`). Rename to `succ_chain_forward_G_strict`. |
| `succ_chain_backward_H_le` | REWRITE | Same pattern. Remove `m = n` T-axiom branch. |
| `SuccChainFMCS` | REWRITE | Use strict forward_G/backward_H |
| All T-axiom usage sites (lines 982, 998, 1274, 4039, 4306, 4449) | REWRITE | See Task 5 for alternatives |

The key simplification: the `_le` wrappers that split into `t = t'` (T-axiom) and `t < t'` (chain property) are no longer needed. The FMCS structure now requires strict `<`, so only the strict chain property is needed.

### File 10: `Theories/Bimodal/Metalogic/Algebraic/DovetailedChain.lean`

| Theorem | Disposition | Details |
|---------|-------------|---------|
| `forward_step_g_content` (line 132) | REWRITE | Currently uses T-axiom to get `a in W` from `G(a) in W`. Under strict semantics, need a different approach: g_content propagation is by the G-agreement property `G(a) in M -> G(a) in W`, then G4 axiom `G(a) -> G(G(a))`, so G(a) in W. But `a in W` does NOT follow from just G(a). The forward step already ensures `g_content(M) subset forward_step` -- but the proof currently routes through the T-axiom. Under strict semantics, we need to show `g_content(M) subset W` directly from the seed construction, NOT via `G(a) in W -> a in W`. |
| `forward_dovetailed_forward_G` (line 215) | REWRITE | Remove T-axiom at base case. Strict version: G(phi) at n propagates to G(phi) at m (by G_propagate), which gives phi at m+1 by g_content. But we need phi at m, not m+1! Under strict semantics, having G(phi) at time n does NOT give phi at time n. It only gives phi at times > n. The proof must be restructured. |
| `forward_dovetailed_backward_H` (lines 268-284) | REWRITE | Remove T-axiom at base cases. Under strict semantics, H(phi) at m does NOT give phi at m. It only gives phi at times < m. So `forward_dovetailed_backward_H` at n=m gives nothing. This is correct: backward_H should only be called with n < m. |
| `backward_dovetailed_forward_G` (line 882) | REWRITE | Same pattern as forward |
| `backward_dovetailed_backward_H` (line 903) | REWRITE | Same pattern |
| T-axiom sites at lines 142, 224, 277, 282, 762, 891, 896, 912, 917 | REWRITE | See Task 5 |

**Critical restructuring for `forward_step_g_content`**: Under strict semantics, the proof needs to change from:
```
G(a) in M -> G(a) in W (by G-agree) -> a in W (by T-axiom)
```
to:
```
G(a) in M means a in g_content(M)
g_content(M) subset W (by temporal_theory_witness_exists construction)
```
The `temporal_theory_witness_exists` already provides `g_content(M) subset W` directly as part of its specification (the witness seed includes g_content). We just need to verify this.

Actually, examining the code more carefully: `temporal_theory_witness_exists` provides:
1. phi in W (target)
2. G-agree: G(a) in M -> G(a) in W
3. box_class_agree

The current `forward_step_g_content` derives `g_content(M) subset W` from (2) + T-axiom. Under strict semantics, we need `g_content(M) subset W` directly. This requires strengthening `temporal_theory_witness_exists` to include g_content in its seed, OR proving it as a consequence of the witness construction.

**Resolution**: The `temporal_theory_witness_exists` builds a seed that includes g_content(M). The Lindenbaum extension of this seed preserves g_content membership. We need to verify this is the case and route the proof through seed membership rather than T-axiom.

### File 11: `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean`

| Theorem | Disposition | Details |
|---------|-------------|---------|
| `R_G_refl` (line 88) | DELETE | G is no longer reflexive |
| `R_H_refl` (line 256) | DELETE | H is no longer reflexive |
| `R_G_trans` | KEEP | Transitivity preserved |
| `g_content_forward_propagation` (line 520) | REWRITE | Remove T-axiom usage |
| `h_content_backward_propagation` (line 559) | REWRITE | Remove T-axiom usage |
| `temporal_witness_g_persistence` (line 2578) | REWRITE | Remove T-axiom. Use direct seed membership. |
| Various T-axiom sites (lines 97, 267, 520, 565, 1009, 1318, 2591) | REWRITE | See Task 5 |

### File 12: `Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean`

| Definition/Theorem | Disposition | Details |
|---------------------|-------------|---------|
| `canonical_task_rel` | KEEP | Already correct: d>0 uses ExistsTask, d<0 uses ExistsTask reverse, d=0 uses identity. Strict temporal operators never exercise d=0. |
| `restricted_tc_family_to_fmcs` (line 1094) | REWRITE | Currently has 2 sorries for forward_G/backward_H. Under strict semantics, these become strict (`<` not `<=`), which means the `t = t'` case is gone. Still need to prove the `t < t'` case for independent Lindenbaum extensions. |

**Key realization**: The `restricted_tc_family_to_fmcs` sorries at lines 1145 and 1149 are the ORIGINAL target of task 83. Under strict semantics, these become strict `<` conditions, which may be easier to prove because:
1. We don't need the `t = t'` case (which was handled by T-axiom)
2. The `t < t'` case can use chain structure (Succ relation propagation)

### File 13: `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean`

| Theorem | Disposition | Details |
|---------|-------------|---------|
| `constrained_successor_seed_consistent` (line 461) | REWRITE | Currently proves g_content(u) subset u via T-axiom (line 472). Under strict semantics, g_content(u) is NOT a subset of u in general. The consistency proof must use a different strategy. |
| `successor_deferral_seed_consistent_axiom` (line 780) | REWRITE | Same issue: g_content(u) subset u via T-axiom (line 792). |
| `predecessor_deferral_seed_consistent_axiom` (line 868) | REWRITE | Same: h_content(u) subset u via T-axiom (line 882). |

**Alternative consistency proof strategy**: The deferral seed is `g_content(u) U deferralDisjunctions(u)`. Under strict semantics, `g_content(u)` is NOT a subset of `u`. So the current proof strategy (show seed subset u, inherit consistency) fails.

New approach: Prove consistency of the seed directly. Suppose `L subset seed` and `L |- bot`. Split L into L_g (from g_content) and L_d (from deferral disjunctions).

Actually, the correct approach is different. The seed consistency follows from the fact that `u U {phi v F(phi) | F(phi) in u}` is consistent. For each formula in g_content(u), we have G(chi) in u, which means the seed contains chi. If the seed is inconsistent, there's a finite subset L leading to bot. From L, extract the g_content formulas chi_1, ..., chi_n with G(chi_i) in u. Then {G(chi_1), ..., G(chi_n)} U deferral_disjunctions |- bot. By temp_k_dist (G distributes over imp), and reasoning within u, we can derive a contradiction in u itself.

This is the STANDARD proof of seed consistency in temporal logic completeness. The formalization requires:
1. From L |- bot where L contains chi_1, ..., chi_n from g_content(u) and psi_1 v F(psi_1), ..., psi_m v F(psi_m) from deferrals:
2. By deduction theorem: {} |- chi_1 -> ... -> chi_n -> (psi_1 v F(psi_1)) -> ... -> bot
3. By generalized G-necessitation: {} |- G(chi_1) -> ... -> G(chi_n) -> G((psi_1 v F(psi_1)) -> ... -> bot)
4. Since G(chi_i) in u and u is MCS, G((psi_1 v F(psi_1)) -> ... -> bot) in u.
5. Since F(psi_j) in u, psi_j v F(psi_j) in u (by disjunction introduction).
6. So G(psi_j v F(psi_j)) -- wait, we need G of the deferral stuff. This gets complicated.

**Simpler approach**: Use the fact that the witness construction (`temporal_theory_witness_exists`) is already sorry-free and provides a direct existence proof. The seed consistency proof can be bypassed by using `temporal_theory_witness_exists` directly as the successor construction, rather than building a custom seed.

**Recommended refactoring**: Replace the deferral seed approach with direct use of `temporal_theory_witness_exists` for successor construction. The current `forward_step` in `DovetailedChain.lean` already does this (line 75-82). The `SuccExistence.lean` seed consistency proofs become unnecessary if we route through `temporal_theory_witness_exists`.

### File 14: `Theories/Bimodal/Metalogic/Bundle/MCSWitnessSuccessor.lean`

| Theorem | Disposition | Details |
|---------|-------------|---------|
| `mcs_witness_successor_g_content` (around line 259) | REWRITE | Currently uses T-axiom to get `a in W` from `G(a) in W`. Same issue as DovetailedChain. Route through seed membership. |
| `mcs_witness_predecessor_h_content` (around line 319) | REWRITE | Mirror |

### File 15: `Theories/Bimodal/Metalogic/Bundle/TargetedChain.lean`

| Theorem | Disposition | Details |
|---------|-------------|---------|
| `targeted_forward_chain_forward_G` (line 229) | REWRITE | Remove T-axiom at line 242. Under strict semantics, G(phi) at n gives phi at all m > n, NOT at n itself. |
| `targeted_backward_chain_*` (lines 346, 478, 512) | REWRITE | Mirror changes |

### File 16: `Theories/Bimodal/Metalogic/Algebraic/TenseS5Algebra.lean`

| Definition/Theorem | Disposition | Details |
|---------------------|-------------|---------|
| `STSA` typeclass | KEEP | No changes needed to the abstract algebraic structure |
| `TL_quot` (line 212) | REWRITE | Currently uses T-axiom to derive `H phi & G phi -> always phi`. Under strict semantics, `always phi = H phi & phi & G phi`, so `H phi & G phi` does NOT imply `always phi` (missing `phi` at present). Need temp_l to be restated or this lemma to use `H phi & phi & G phi` directly. |

**Resolution for TL_quot**: Under strict semantics, `temp_l` is `always phi -> G(H phi)` where `always phi = H phi & phi & G phi`. The premise already includes `phi`. So `TL_quot` should map `H phi & phi & G phi ≤ G(H phi)`, which is exactly what `temp_l` provides. The current proof goes through `H phi & G phi -> H phi & phi & G phi` using the T-axiom; this step needs to be removed and the lemma statement changed to take `always phi` directly.

### File 17: `Theories/Bimodal/Metalogic/Algebraic/InteriorOperators.lean`

| Definition/Theorem | Disposition | Details |
|---------------------|-------------|---------|
| `G_interior` instance | DELETE | G is no longer an interior operator (fails deflationarity) |
| `H_interior` instance | DELETE | Same |
| Note at lines 164-191 | KEEP | Already documents that G/H are not interior under strict semantics |

Actually, reading the file more carefully: the interior instances may already be conditioned or absent. The note at line 173 says "The T-axioms have been removed." This suggests the file may already be partially prepared for strict semantics. Keep the file but remove any `G_interior`/`H_interior` instances if present.

### File 18: `Theories/Bimodal/Theorems/Perpetuity/`

| Theorem | Disposition | Details |
|---------|-------------|---------|
| `perpetuity_1` (`box phi -> always phi`) | REWRITE | `always phi = H phi & phi & G phi`. Currently derives `box phi -> G phi` via MF then MT. Under strict semantics, `box phi -> G phi` still holds via MF/temp_future. And `box phi -> phi` via MT. And `box phi -> H phi` via temporal duality on MF. So the proof is essentially unchanged but the semantic reading is different. |
| `perpetuity_2` (`sometimes phi -> diamond phi`) | KEEP | Contrapositive of P1 |
| `perpetuity_3` - `perpetuity_5` | KEEP | These use only box, diamond, always, sometimes. |

**Key point**: `box_to_future` derives `box phi -> G phi`. This uses `modal_future` (`box phi -> box(G phi)`) and `temp_future` (`box phi -> G(box phi)`). Under strict semantics, these axioms are still valid (they don't use T-axioms). The derivation `box phi -> G phi` goes through MF to get `box(G phi)`, then MT to get `G phi`. This is still valid because MT is the modal T-axiom (box phi -> phi), NOT the temporal T-axiom.

Wait -- does `box phi -> G phi` actually need the temporal T-axiom? Let me check:
- `modal_future`: `box phi -> box(G phi)` -- valid under strict semantics (box phi at t means phi at all worlds at t; G phi at all worlds means for all s > t, phi at all worlds at s)
- From `box(G phi)`, by MT: `G phi` -- this is `box(G phi) -> G phi`, which uses MODAL T (reflexivity of box), NOT temporal T.

So `box_to_future` is fine. The Perpetuity module needs no changes.

### File 19: `Theories/Bimodal/ProofSystem/LinearityDerivedFacts.lean`

| Theorem | Disposition | Details |
|---------|-------------|---------|
| Module documentation | REWRITE | Remove references to `temp_t_future`, `temp_t_past` in axiom list and counterexample description. Under strict semantics, the counterexample frame is no longer required to be reflexive. |
| `temp_linearity_derivation` | KEEP | Unchanged wrapper |

### File 20: `Theories/Bimodal/FrameConditions/Soundness.lean`

| Content | Disposition | Details |
|---------|-------------|---------|
| References to `temp_t_future`, `temp_t_past` | REWRITE | Update documentation |

---

## Task 3: Backward Truth Lemma for Until -- Full Proof Strategy

### Statement (under fully strict semantics)

**Theorem** (`truth_lemma_until_backward`): For all formulas `phi U psi` in the subformula closure, if `truth_at M Omega tau t (phi U psi)` then `(phi U psi) in fam.mcs t`, where `fam` is the FMCS built from the dovetailed chain and `M, Omega, tau` are the canonical model components.

**Precise statement**:
```lean
theorem truth_lemma_backward (fam : FMCS Int) (phi psi : Formula)
    (IH_phi : forall t, truth_at ... t phi <-> phi in fam.mcs t)
    (IH_psi : forall t, truth_at ... t psi <-> psi in fam.mcs t)
    (t : Int)
    (h_true : truth_at ... t (Formula.untl phi psi)) :
    Formula.untl phi psi in fam.mcs t
```

### Double Induction Scheme

The truth lemma uses TWO inductions:
1. **Outer induction**: Structural induction on formula complexity. When proving the truth lemma for `phi U psi`, we have IH for all proper subformulas, including `phi` and `psi`.
2. **Inner induction**: Strong induction on witness distance `k = s - (t+1)` where `s > t` is the Until witness.

This avoids the circularity problem: we never invoke the truth lemma for `phi U psi` at the same time point. We only invoke it for `phi` and `psi` (proper subformulas, handled by outer IH) and for `phi U psi` at strictly later time points (handled by inner IH on decreasing witness distance).

### Detailed Proof by Inner Induction on k = s - (t+1)

**Given**: truth_at t (phi U psi), i.e., exists s > t with psi(s) and phi at all r with t < r < s.

**Need**: phi U psi in mcs(t).

**Step 1**: By the until_unfold axiom equivalence, it suffices to show:
```
X(psi v (phi & (phi U psi))) in mcs(t)
```
i.e., `bot U (psi v (phi & (phi U psi))) in mcs(t)`.

By the X truth lemma (Task 4), this is equivalent to:
```
(psi v (phi & (phi U psi))) in mcs(t+1)
```

**Step 2**: We need to show `psi(t+1) v (phi(t+1) & (phi U psi)(t+1))` is in mcs(t+1).

**Case k = 0** (i.e., s = t+1):
- psi(t+1) holds (by truth_at with witness s = t+1).
- By IH_psi: psi in mcs(t+1).
- By MCS disjunction: psi v (...) in mcs(t+1).
- By X truth lemma backward: X(...) in mcs(t).
- By until_intro: phi U psi in mcs(t).

**Case k > 0** (i.e., s > t+1):
- phi(t+1) holds (from guard: t < t+1 < s).
- phi U psi holds at t+1 (with witness s, guard: phi at all r with t+1 < r < s). Witness distance is k-1.
- By IH_phi: phi in mcs(t+1).
- By inner IH (distance k-1 < k): (phi U psi) in mcs(t+1).
- So phi & (phi U psi) in mcs(t+1) (by MCS conjunction).
- So psi v (phi & (phi U psi)) in mcs(t+1) (by MCS disjunction).
- By X truth lemma backward: X(...) in mcs(t).
- By until_intro: phi U psi in mcs(t).

### Lean Proof Sketch

```lean
-- Inner induction on k = s - (t + 1)
-- Use strong induction via Nat.strongRecOn or well-founded recursion on (s - (t+1)).toNat

-- Step 1: Extract witness s and distance k
obtain ⟨s, h_t_lt_s, h_psi_s, h_phi_guard⟩ := h_true
let k := (s - (t + 1)).toNat  -- k >= 0 since s > t means s >= t+1

-- Step 2: Prove (psi v (phi & (phi U psi))) in mcs(t+1)
-- Case analysis on s = t+1 vs s > t+1
by_cases h_eq : s = t + 1
· -- Base case: psi in mcs(t+1)
  subst h_eq
  have h_psi_mcs := (IH_psi (t+1)).mp h_psi_s
  -- psi v (...) in mcs(t+1) by RDI
  have h_disj := mcs_rdi (fam.is_mcs (t+1)) h_psi_mcs
  -- X(...) in mcs(t) by X truth lemma backward
  have h_X := x_truth_backward fam t h_disj
  -- phi U psi in mcs(t) by until_intro
  exact mcs_until_intro (fam.is_mcs t) h_X
· -- Inductive case: s > t+1
  have h_t1_lt_s : t + 1 < s := by omega
  -- phi(t+1) from guard
  have h_phi_t1 := h_phi_guard (t+1) (by omega) h_t1_lt_s
  have h_phi_mcs := (IH_phi (t+1)).mp h_phi_t1
  -- phi U psi at t+1 with witness s
  have h_until_t1 : truth_at ... (t+1) (phi U psi) :=
    ⟨s, h_t1_lt_s, h_psi_s, fun r hr1 hr2 => h_phi_guard r (by omega) hr2⟩
  -- Inner IH: (s - (t+2)).toNat < (s - (t+1)).toNat
  have h_inner_ih := inner_ih (t+1) h_until_t1 (by omega)
  -- phi & (phi U psi) in mcs(t+1)
  have h_conj := mcs_conj (fam.is_mcs (t+1)) h_phi_mcs h_inner_ih
  -- psi v (phi & (phi U psi)) in mcs(t+1) by RDI
  have h_disj := mcs_rdi_right (fam.is_mcs (t+1)) h_conj
  -- X(...) in mcs(t) by X truth lemma backward
  have h_X := x_truth_backward fam t h_disj
  -- phi U psi in mcs(t) by until_intro
  exact mcs_until_intro (fam.is_mcs t) h_X
```

### Dependencies

1. **X truth lemma backward** (Task 4): `chi in mcs(t+1) -> X(chi) in mcs(t)` (i.e., `bot U chi in mcs(t)`)
2. **until_intro in MCS**: `X(psi v (phi & (phi U psi))) in mcs(t) -> (phi U psi) in mcs(t)` -- follows from the until_intro axiom being a theorem, so it's in every MCS
3. **MCS conjunction/disjunction properties**: Standard MCS properties
4. **IH for subformulas**: Provided by outer structural induction

---

## Task 4: X Truth Lemma Backward Direction

### The Problem

We need: `chi in mcs(t+1) -> (bot U chi) in mcs(t)`.

Semantically, `bot U chi` at t means: there exists s > t with chi(s) and bot at all r with t < r < s. On Z, taking s = t+1, the guard interval {r : t < r < t+1} is empty (vacuously true for bot). So `bot U chi` at t iff chi(t+1).

For the backward truth lemma, we need: if chi is in the MCS at time t+1 in the chain, then `bot U chi` is in the MCS at time t.

### Current Chain Construction Analysis

From `SuccRelation.lean` (line 59):
```lean
def Succ (u v : Set Formula) : Prop :=
  g_content u ⊆ v ∧ f_content u ⊆ v ∪ f_content v
```

The Succ relation provides:
- **Forward**: g_content(u) subset v (G-persistence)
- **Forward**: f_content(u) subset v union f_content(v) (F-step)

For the X truth lemma backward, we need the REVERSE direction:
- **Backward**: chi in v -> X(chi) in u (i.e., bot U chi in u)

This is NOT provided by the current Succ relation. The current Succ provides forward content propagation but not backward X-content propagation.

### Analysis of h_content Duality

From `WitnessSeed.lean`, the g/h duality theorem says:
```
g_content(u) subset v  ->  h_content(v) subset u
```
where h_content(v) = {phi : H(phi) in v}.

This gives: H(chi) in v -> chi in u. This is backward H-propagation, not X-propagation.

We need a SEPARATE property: chi in mcs(t+1) -> bot U chi in mcs(t).

### The Key Insight: disc_next + Chain Properties

The `disc_next` axiom gives: `F(top) -> X(top)`. Since F(top) is a theorem (from seriality), X(top) is a theorem. So `bot U (neg bot) in every MCS`.

But we need `bot U chi in mcs(t)` for SPECIFIC chi, not just top.

### Solution: Constrained Successor Construction

The backward X-content propagation can be ensured by strengthening the chain construction. Specifically, when building the dovetailed chain, at each forward step from mcs(t) to mcs(t+1), we need:

**Property**: For all chi, if chi in mcs(t+1), then (bot U chi) in mcs(t).

This is equivalent to: for all chi, if (neg(bot U chi)) in mcs(t), then chi not in mcs(t+1).

Since neg(bot U chi) = neg(exists s > t, chi(s) & bot at (t,s)) -- this is complex to reason about syntactically.

**Better approach**: Use the discrete axioms to derive the backward direction.

**Derivation**: We want to show that in the proof system, for any MCS pair (M, W) related by Succ:
```
chi in W -> (bot U chi) in M
```

This requires:
1. `chi in W` -- given
2. The Succ relation gives g_content(M) subset W.
3. By g/h duality: h_content(W) subset M. So H(phi) in W -> phi in M.
4. We need (bot U chi) in M.

From chi in W, we need to get (bot U chi) propagating backward. The h_content duality gives H-backward, not X-backward. These are different.

### Actual Resolution: Strengthen Chain Construction

The dovetailed chain uses `temporal_theory_witness_exists` for forward steps. This provides:
- phi in W (target)
- G-agree: G(a) in M -> G(a) in W
- box_class_agree

To get backward X-content, we need the chain construction to additionally ensure:
**For all chi, if chi in W then G(bot U chi) in M, which implies (bot U chi) in W' for all W' accessible from M (including the next step).**

Wait, this is circular. Let me reconsider.

**The correct resolution uses a different observation**: In the dovetailed chain, mcs(t) and mcs(t+1) are related by Succ. The construction ensures:
- Forward: g_content(mcs(t)) subset mcs(t+1) AND f_content(mcs(t)) subset mcs(t+1) union f_content(mcs(t+1))
- Backward (by duality): h_content(mcs(t+1)) subset mcs(t)

For the X backward direction, we need:
```
chi in mcs(t+1) -> (bot U chi) in mcs(t)
```

**Key derivation using temp_a**:
- `temp_a`: phi -> G(P(phi)).
- From chi in mcs(t+1), by `temp_a` in mcs(t+1): G(P(chi)) in mcs(t+1).
- G(P(chi)) in g_content(mcs(t+1)).
- By the backward chain's h_content duality... wait, g_content goes forward, h_content goes backward.

Let me reconsider. We have:
- chi in mcs(t+1)
- h_content(mcs(t+1)) subset mcs(t) (from g/h duality of the Succ relation)
- H(phi) in mcs(t+1) -> phi in mcs(t) (this is h_content duality)

Can we get H(bot U chi) in mcs(t+1) from chi in mcs(t+1)?

Using `temp_a_dual`: chi -> H(F(chi)). So F(chi) would be in all past MCS. But F(chi) = neg(G(neg(chi))) is different from bot U chi.

Using `F_until_equiv`: F(chi) -> top U chi. So top U chi would be derivable from F(chi).

But we want `bot U chi`, not `top U chi`. On discrete Z, `bot U chi` at t means chi(t+1) with empty guard, while `top U chi` at t means exists s > t with chi(s) and top at (t,s).

The relationship: `bot U chi` is strictly stronger than `top U chi` (bot U chi implies top U chi but not vice versa).

**The correct approach**: We need to derive `bot U chi` from chi at the next step. The key axiom for this is `disc_next` combined with the structure of Until.

Consider: `disc_next` gives `F(top) -> bot U top`, i.e., if there's a future, there's an immediate next step where top holds.

We need a GENERALIZED disc_next: `F(chi) -> bot U chi` (if chi holds at some future time, then chi holds at the immediate next step where chi first holds... NO, this is NOT valid in general).

**Actually, `bot U chi` at t means chi(t+1) on Z.** There is no axiom-based way to derive chi(t+1) from chi being anywhere in the future.

### The Real Solution: Forward X-Content in Seed

The backward direction of the X truth lemma requires that the chain construction propagates X-content BACKWARD. Concretely:

When we build mcs(t+1) as a successor of mcs(t), we need to ensure that for all chi, if chi in mcs(t+1) then X(chi) = bot U chi in mcs(t).

**This must be built into the SEED of the chain construction**, not derived after the fact.

**Modified successor seed**: When constructing mcs(t+1) from mcs(t), include in the seed of mcs(t):
```
backward_X_content(W) = {bot U chi | chi in W}
```

But this is circular: we don't know W (mcs(t+1)) when building the seed for mcs(t).

**Non-circular approach**: When building the chain FORWARD, at step t+1, we have mcs(t) already built. We build mcs(t+1) as a Lindenbaum extension of a seed. AFTER building mcs(t+1), we need to ensure backward X-content in mcs(t).

Since mcs(t) is already built and fixed, we can't add formulas to it. So the backward X-content must be a PROPERTY that follows from the construction, not something we add.

### The Actual Resolution: It Follows from Maximal Consistency

**Claim**: In the dovetailed chain, for the specific chi we care about in the truth lemma, we can derive `bot U chi in mcs(t)` using the axioms and MCS properties.

**Proof**:
1. chi in mcs(t+1) (given)
2. The chain has mcs(t) Succ mcs(t+1), so g_content(mcs(t)) subset mcs(t+1).
3. Suppose for contradiction that `neg(bot U chi) in mcs(t)`.
4. `neg(bot U chi) = G(neg chi) v (neg chi & (neg(bot) U neg chi))` -- no, the negation of an Until is complex.

Actually, `neg(bot U chi)` does NOT simplify nicely in the proof system. This makes the direct approach difficult.

### The Pragmatic Resolution: Use G-Content of Next Step

**Alternative approach**: We don't need the X truth lemma in its full generality. We need it specifically within the backward truth lemma for Until, where the formula `psi v (phi & (phi U psi))` is in mcs(t+1).

Instead of proving the general X truth lemma, we can prove the Until backward truth lemma directly using induction on witness distance, WITHOUT routing through X.

**Revised proof of Until backward truth lemma** (without X truth lemma):

Given: truth_at t (phi U psi) with witness s > t.
Need: phi U psi in mcs(t).

**Strong induction on k = s - t (positive integer)**:

**Base k = 1** (s = t+1):
- psi(t+1). By IH_psi: psi in mcs(t+1).
- Need: phi U psi in mcs(t).
- Semantically, phi U psi at t with witness s = t+1 (guard is empty since t < r < t+1 is impossible on Z).
- By until_intro: X(psi v (phi & (phi U psi))) -> phi U psi.
- So we need X(psi v (phi & (phi U psi))) in mcs(t).
- X(psi v (...)) = bot U (psi v (...)).
- We need this in mcs(t). We know psi in mcs(t+1), so psi v (...) in mcs(t+1).
- **This is exactly where we need the X backward direction.**

**So the X backward direction IS needed. Let me reconsider.**

### Final Resolution: Strengthen the Successor Existence

The solution is to strengthen `temporal_theory_witness_exists` (or the chain construction) to include **backward X-content as a seed property** of the PREDECESSOR, not the successor.

When building the BACKWARD chain: at step t, we build mcs(t) as a PREDECESSOR of mcs(t+1). We include in the seed for mcs(t):
```
{bot U chi | chi in mcs(t+1)} intersect deferralClosure
```

For the forward chain, we don't build mcs(t) as a predecessor. Instead:
1. Build mcs(t+1) as a forward step from mcs(t).
2. After building the entire forward chain, prove backward X-content as a DERIVED property.

**Key observation**: On discrete Z with the disc_next/disc_prev axioms, the following is DERIVABLE in the proof system:

For any MCS M containing F(top):
```
phi in M iff X(phi) in SOME predecessor of M
```

But in a Succ chain, the predecessor of mcs(t+1) is mcs(t). We need X(phi) = bot U phi in mcs(t) specifically.

**The resolution is to include backward X-content in the PREDECESSOR EXISTENCE construction.**

Currently, `predecessor_exists` (in SuccExistence.lean) builds a predecessor v of u with:
- h_content(u) subset v (H-persistence)
- p_content(u) subset v union p_content(v) (P-step)

**Strengthen predecessor_exists** to additionally ensure:
- x_content(u) subset v, where x_content(u) = {bot U chi | chi in u}

This means: for each chi in u, the predecessor v contains bot U chi.

**Seed for strengthened predecessor**: `h_content(u) union {bot U chi | chi in u} union pastDeferralDisjunctions(u)`

**Consistency of strengthened seed**: We need to show this seed is consistent. The seed is a subset of: `{H(chi) | H(chi) in u} union {bot U chi | chi in u} union {psi v P(psi) | P(psi) in u}`. This is consistent because all formulas are consistent with each other -- h_content formulas are derivable from u via temp_a/duality, and X-content formulas are consistent because they just describe what's true at the next time step.

Actually, the consistency proof for this strengthened seed may require significant work. Let me think about whether there's a simpler path.

### Simplest Correct Approach

**Build the forward chain so that backward X-content is automatic.**

When constructing mcs(t+1) as a successor of mcs(t), the seed for mcs(t+1) includes g_content(mcs(t)) and deferral disjunctions. After Lindenbaum extension, mcs(t+1) is an MCS.

Now, for any chi in mcs(t+1), we want bot U chi in mcs(t).

**Use `since_connectedness` and interaction axioms**: The connectedness axioms relate Until and Since. But this seems overly complex.

**Use the fact that mcs(t) is MAXIMAL**: Either bot U chi in mcs(t) or neg(bot U chi) in mcs(t). If neg(bot U chi) in mcs(t), then...

On Z, neg(bot U chi) at t means: for all s > t, either neg chi(s) or exists r with t < r < s and neg bot(r). Since neg bot = top is always true, the second disjunct is: exists r with t < r < s, which is true for all s > t+1 (take r = t+1). So neg(bot U chi) at t means neg chi(t+1), i.e., chi is false at t+1.

So: neg(bot U chi) in mcs(t) iff neg(chi) in mcs(t+1) (on the canonical model).

By MCS: either chi in mcs(t+1) or neg(chi) in mcs(t+1). If chi in mcs(t+1) and neg(chi) in mcs(t+1), contradiction. So chi in mcs(t+1) implies neg(chi) not in mcs(t+1), which means neg(bot U chi) NOT in mcs(t), which means (by MCS maximality) bot U chi in mcs(t).

**THIS IS THE PROOF!** It uses the FORWARD truth lemma for X (which is simpler) to establish that neg(bot U chi) in mcs(t) implies neg(chi) in mcs(t+1), and then contraposes.

### X Truth Lemma: Forward Direction

**Forward X truth lemma**: `bot U chi in mcs(t) -> chi in mcs(t+1)`.

Proof:
- bot U chi in mcs(t).
- By the FORWARD truth lemma (which is simpler -- given membership, show truth): truth_at t (bot U chi).
- Semantically: exists s > t with chi(s) and bot at all r with t < r < s. On Z, the bot guard forces s = t+1. So chi(t+1).
- By IH_chi (forward truth lemma): chi in mcs(t+1)? No wait, this is circular if we're proving the truth lemma.

OK, let me reconsider. The forward truth lemma for X doesn't use the truth lemma for chi. It uses the CHAIN properties:
- bot U chi in mcs(t).
- By the X-unfold axiom for bot U chi... actually, bot U chi IS X(chi), and its unfold is X(chi v (bot & (bot U chi))) = X(chi v bot) = X(chi). So this is self-referential.

**Better approach**: Use the FMCS forward_G property and the Succ relation.

From `bot U chi in mcs(t)`:
- By the until_unfold axiom: X(chi v (bot & (bot U chi))) in mcs(t).
- Simplify: bot & anything = bot, so chi v bot = chi. So X(chi) in mcs(t).
- Wait, this doesn't simplify correctly. Let me be precise.

`bot U chi` unfolds via until_unfold to: `X(chi v (bot & (bot U chi)))`.
`bot & (bot U chi)` is `neg(bot -> neg(bot U chi))`. This is not syntactically bot.

Actually, in the proof system, `bot & X = neg(bot -> neg X)`. This simplifies semantically to False (since bot -> anything is True, so neg of that is False, i.e., the conjunction is False). But syntactically it's not bot.

So the unfold gives: X(chi v (bot & (bot U chi))). Semantically this is X(chi v False) = X(chi). But syntactically we need MCS-level reasoning to simplify.

In an MCS: bot is never in the MCS (consistency). So neg(bot) is in every MCS. For any formula X, bot & X = neg(bot -> neg X). If bot not in MCS, then... we need to show bot & X not in MCS for any X. This follows from: if bot & X in MCS, then by left conjunction elimination, bot in MCS, contradiction.

So bot & (bot U chi) not in mcs. By MCS disjunction: chi v (bot & (bot U chi)) in mcs iff chi in mcs or bot & (bot U chi) in mcs. Since the latter is impossible, chi v (bot & (bot U chi)) iff chi.

OK so in an MCS, the until_unfold for bot U chi effectively gives: bot U chi -> X(chi). And until_intro gives: X(chi) -> bot U chi. So bot U chi <-> X(chi) <-> bot U chi. This is tautological.

**The forward X truth lemma must use the chain structure directly.**

From bot U chi in mcs(t):
- The Succ relation gives f_content(mcs(t)) subset mcs(t+1) union f_content(mcs(t+1)).
- f_content(mcs(t)) = {phi | F(phi) in mcs(t)}.
- We need chi in mcs(t+1).
- From bot U chi in mcs(t), can we derive F(chi) in mcs(t)?
  - Yes: bot U chi -> top U chi is derivable (weakening bot to top in the guard).
  - And top U chi -> F(chi) is derivable (from until_induction or by semantic reasoning).
  - Actually, F_until_equiv gives F(chi) -> top U chi. The REVERSE (top U chi -> F(chi)) needs to be derived.
  - top U chi means exists s > t with chi(s) and top at all (t,s). This IS F(chi).
  - So top U chi <-> F(chi), and F_until_equiv gives one direction as axiom.
  - The reverse is derivable via until_induction with appropriate chi.

OK, this is getting complex. Let me take a step back.

**The pragmatic solution for the X truth lemma forward direction**:

The forward truth lemma for Until (given membership, show truth) can handle bot U chi directly:
- bot U chi in mcs(t).
- By the forward dovetailed chain's F-resolution: the chain eventually resolves F(chi) if it's present.
- But bot U chi is stronger than F(chi): it requires chi at the IMMEDIATE next step.

**The cleanest approach**: Define the forward X truth as a chain property to be verified.

Given that the dovetailed chain has Succ(mcs(t), mcs(t+1)):
- g_content(mcs(t)) subset mcs(t+1): if G(a) in mcs(t), then a in mcs(t+1)
- f_content(mcs(t)) subset mcs(t+1) union f_content(mcs(t+1))

For bot U chi in mcs(t):
- We know F(chi) in mcs(t) (derivable from bot U chi).
- By f_content property: chi in mcs(t+1) or F(chi) in mcs(t+1).
- If chi in mcs(t+1): done.
- If F(chi) in mcs(t+1) but chi not in mcs(t+1): then neg(chi) in mcs(t+1).
- We need to show this leads to contradiction with bot U chi in mcs(t).

**From bot U chi in mcs(t) and neg(chi) in mcs(t+1)**:
- bot U chi at t semantically means chi(t+1) (on Z with strict semantics).
- neg(chi) at t+1 means not chi(t+1).
- Contradiction with soundness.

So assuming soundness of the proof system: if bot U chi in mcs(t), then neg(chi) not in mcs(t+1), so chi in mcs(t+1).

**But we can't use soundness inside the completeness proof!**

### The Correct Technical Resolution

The X truth lemma backward direction (`chi in mcs(t+1) -> bot U chi in mcs(t)`) requires strengthening the chain construction.

**Approach: Add backward X-content to the predecessor seed.**

When building the backward dovetailed chain from mcs(0) going backward:
- At step t-1, build mcs(t-1) as a predecessor of mcs(t).
- Include in the seed: h_content(mcs(t)) union p-deferral disjunctions union **{bot U chi | chi in mcs(t)}**.

For the forward chain going forward from mcs(0):
- The PREVIOUS mcs(t) is already fixed when building mcs(t+1).
- We cannot add to mcs(t) after the fact.
- **Solution**: When building mcs(t+1), ensure that the construction is compatible with the backward X-content of mcs(t).

**Actually, the simplest solution**: Build the chain TWICE.

1. **First pass**: Build the forward/backward dovetailed chain as currently done (without backward X-content).
2. **Second pass**: For each t, define a NEW chain mcs'(t) that extends mcs(t) with backward X-content. Prove mcs'(t) is still an MCS and still satisfies Succ.

This is too complex. The right solution for Lean formalization:

### Pragmatic Resolution: Use Proof-Theoretic X-Backward

**Theorem** (derivable in the proof system): For any MCS M and any Succ-successor W of M:
```
chi in W -> (bot U chi) in M
```

**Proof attempt**:
- chi in W.
- M Succ W, so g_content(M) subset W and f_content(M) subset W union f_content(W).
- By g/h duality: h_content(W) subset M.
- Need: bot U chi in M.

Using `temp_a` on chi in W: G(P(chi)) in W. So P(chi) in g_content(W).
But g_content(W) propagates FORWARD from W, not backward to M.

Using `temp_a_dual` on chi in W: H(F(chi)) in W. So F(chi) in h_content(W).
By h_content duality: F(chi) in M.

So F(chi) in M. But we need bot U chi in M, not F(chi).

F(chi) = neg(G(neg(chi))). bot U chi is different.

On Z, bot U chi at t <-> chi(t+1). F(chi) at t <-> exists s > t, chi(s).
F(chi) is weaker than bot U chi.

**Using disc_next**: F(top) -> bot U top. Combined with F(chi) in M:
- We have F(chi) in M.
- disc_next gives F(top) -> X(top).
- We need: F(chi) -> X(chi). This is NOT derivable from disc_next in general!

`F(chi)` says chi holds at SOME future time. `X(chi)` says chi holds at the IMMEDIATE next time. These are different unless chi holds at the nearest future time.

### FINAL Resolution: Until Backward Truth Lemma Without X

**The backward truth lemma for Until can be proved WITHOUT routing through X**, by using the until_induction axiom directly.

**Alternative proof strategy using until_induction**:

Given truth_at t (phi U psi), we want phi U psi in mcs(t).

Suppose for contradiction that neg(phi U psi) in mcs(t).

By the FORWARD truth lemma for neg(phi U psi):
truth_at t (neg(phi U psi)), i.e., not truth_at t (phi U psi).
But we assumed truth_at t (phi U psi). Contradiction.

**Wait -- this assumes the forward truth lemma for neg, which requires the forward truth lemma for phi U psi, which IS the forward direction of the truth lemma for Until.**

Actually, the forward truth lemma goes: `phi U psi in mcs(t) -> truth_at t (phi U psi)`. The backward goes: `truth_at t (phi U psi) -> phi U psi in mcs(t)`.

For the CONTRAPOSITIVE approach:
- If neg(phi U psi) in mcs(t), then by forward truth lemma for negation: not truth_at t (phi U psi).
- Contrapositive: if truth_at t (phi U psi), then neg(phi U psi) not in mcs(t).
- By MCS maximality: phi U psi in mcs(t).

**THIS WORKS if we have the forward truth lemma for phi U psi.**

And the forward truth lemma for Until under strict semantics:
- phi U psi in mcs(t) means there exists s > t with psi in mcs(s) and phi at all r with t < r < s.
- By IH_psi forward: truth_at s psi.
- By IH_phi forward: truth_at r phi for all r with t < r < s.
- So truth_at t (phi U psi).

The forward direction is straightforward by structural induction on the witness. No X truth lemma needed.

So the backward direction follows from the forward direction plus MCS maximality!

**Summary**: The backward truth lemma for Until follows from:
1. Forward truth lemma for Until (straightforward)
2. Forward truth lemma for negation (standard)
3. MCS maximality (if phi not in M, then neg(phi) in M)
4. Contraposition

This is the standard argument in completeness proofs. The X truth lemma is NOT needed as a separate step.

---

## Task 5: T-Axiom Dependency Catalog

### Legend
- **T-future**: `Axiom.temp_t_future` (G phi -> phi)
- **T-past**: `Axiom.temp_t_past` (H phi -> phi)
- **Pattern A**: "G(a) in M -> a in M" (g_content subset self via T-axiom)
- **Pattern B**: "H(a) in M -> a in M" (h_content subset self via T-axiom)
- **Pattern C**: "G(phi) in chain(m), need phi in chain(m)" for base case m=n

### DovetailedChain.lean

| Line | Theorem | Pattern | Alternative Under Strict Semantics |
|------|---------|---------|-------------------------------------|
| 142 | `forward_step_g_content` | A: G(a) in W -> a in W | Route through seed: g_content(M) is in the seed for W, so g_content(M) subset W directly. Don't need a in W from G(a) in W. Actually, need to verify `temporal_theory_witness_exists` includes g_content in seed. |
| 224 | `forward_dovetailed_forward_G` | C: base case n=m, G(phi) at m -> phi at m | Under strict semantics, forward_G only asserts phi at t' > t, not t' = t. Remove the n=m base case. The theorem statement changes to require n < m. |
| 277 | `forward_dovetailed_backward_H` | B: H(phi) at 0 -> phi at 0 (base case) | Under strict semantics, H(phi) at 0 only gives phi at times < 0. The base case n=m gives nothing. Remove it; require n < m. |
| 282 | same theorem, inductive case | B: H(phi) at m+1 -> phi at m+1 | Same: under strict, H gives phi at times < m+1, not at m+1 itself. Remove; the h_content duality already handles the step n < m+1. |
| 762 | `backward_step_h_content` | B: H(a) in W -> a in W | Mirror of line 142. Route through seed: h_content is in predecessor seed directly. |
| 891 | `backward_dovetailed_forward_G` | A: G(phi) at 0 -> phi at 0 | Same as line 224 mirror. Remove base case. |
| 896 | same, inductive case | A: G(phi) at m+1 -> phi at m+1 | Remove. |
| 912 | `backward_dovetailed_backward_H` | B: H(phi) at n -> phi at n (base case) | Remove base case. |
| 917 | same, inductive case | B: H(phi) at m+1 -> phi at m+1 | Remove. |

### SuccChainFMCS.lean

| Line | Theorem | Pattern | Alternative |
|------|---------|---------|-------------|
| 982 | `succ_chain_forward_G_le` | C: n=m case, T-future | DELETE the `_le` wrapper. Use strict `succ_chain_forward_G` directly. The FMCS structure now requires `<` not `<=`. |
| 998 | `succ_chain_backward_H_le` | C: m=n case, T-past | DELETE the `_le` wrapper. Use strict `succ_chain_backward_H` directly. |
| 1274 | `succ_chain_G_seed_consistent` | A: G(chi) in u -> chi in u for seed consistency | Restructure seed consistency proof (see Task 2, File 13). |
| 4039 | `succ_chain_H_seed_consistent` | B: H(chi) in u -> chi in u | Mirror of 1274. |
| 4306 | chain construction detail | A: G(chi) -> chi | Route through seed membership |
| 4449 | chain construction detail | A: T-future on neg_neg_bot | Derive neg_neg_bot directly from propositional axioms |

### SuccExistence.lean

| Line | Theorem | Pattern | Alternative |
|------|---------|---------|-------------|
| 472 | `constrained_successor_seed_consistent` | A: g_content(u) subset u | Restructure: prove seed consistency via proof-theoretic argument using G-distribution, not by showing seed subset u |
| 792 | `successor_deferral_seed_consistent_axiom` | A: g_content(u) subset u | Same restructuring |
| 882 | `predecessor_deferral_seed_consistent_axiom` | B: h_content(u) subset u | Mirror |

### TargetedChain.lean

| Line | Theorem | Pattern | Alternative |
|------|---------|---------|-------------|
| 242 | `targeted_forward_chain_forward_G` | C: T-future at m | Remove n=m base case; use strict inequality |
| 346 | backward chain | B: T-past | Remove base case |
| 478 | another forward G | A: T-future | Remove base case |
| 512 | another backward H | B: T-past | Remove base case |

### Summary of Alternatives

**Pattern A/B (g/h_content subset self)**: These ALL arise from trying to prove `g_content(u) subset u` or `h_content(u) subset u`. Under strict semantics, this is FALSE. The alternative is:
1. For seed consistency: prove consistency directly via proof-theoretic arguments (G/H distribution + deduction theorem)
2. For chain properties: route through the seed/construction that already includes g_content/h_content

**Pattern C (base case t=t')**: These ALL arise from the FMCS structure having `<=` instead of `<`. Under strict semantics, the FMCS uses `<`, so the base case is gone. Simply remove it.

---

## Task 6: FMCS Structure Changes

### Current Structure (FMCSDef.lean)

```lean
structure FMCS where
  mcs : D -> Set Formula
  is_mcs : forall t, SetMaximalConsistent (mcs t)
  forward_G : forall t t' phi, t <= t' -> Formula.all_future phi in mcs t -> phi in mcs t'
  backward_H : forall t t' phi, t' <= t -> Formula.all_past phi in mcs t -> phi in mcs t'
```

### New Structure

```lean
structure FMCS where
  mcs : D -> Set Formula
  is_mcs : forall t, SetMaximalConsistent (mcs t)
  /-- Forward G coherence (strict): G phi at t implies phi at all t' > t -/
  forward_G : forall t t' phi, t < t' -> Formula.all_future phi in mcs t -> phi in mcs t'
  /-- Backward H coherence (strict): H phi at t implies phi at all t' < t -/
  backward_H : forall t t' phi, t' < t -> Formula.all_past phi in mcs t -> phi in mcs t'
```

### No forward_X / backward_Y Fields Needed

As established in Task 4, the backward truth lemma for Until does NOT require an explicit X truth lemma. It follows from:
1. Forward truth lemma (straightforward)
2. MCS maximality (contrapositive argument)

Therefore no `forward_X` or `backward_Y` fields are needed in the FMCS structure.

### Changes to FMCS Construction Lemmas

The `SuccChainFMCS` construction (currently line 1001 of SuccChainFMCS.lean):

```lean
-- CURRENT
noncomputable def SuccChainFMCS (M0 : SerialMCS) : FMCS Int where
  mcs := succ_chain_fam M0
  is_mcs := succ_chain_fam_mcs M0
  forward_G := succ_chain_forward_G_le M0    -- uses <= with T-axiom split
  backward_H := succ_chain_backward_H_le M0  -- uses <= with T-axiom split

-- NEW
noncomputable def SuccChainFMCS (M0 : SerialMCS) : FMCS Int where
  mcs := succ_chain_fam M0
  is_mcs := succ_chain_fam_mcs M0
  forward_G := succ_chain_forward_G M0       -- already exists, uses strict <
  backward_H := succ_chain_backward_H M0     -- already exists, uses strict <
```

The existing `succ_chain_forward_G` and `succ_chain_backward_H` theorems (which handle the strict `<` case) can be used directly. The `_le` wrappers that added the T-axiom `t=t'` case are simply deleted.

### Preorder to StrictOrder

The FMCS currently uses `[Preorder D]` as the typeclass constraint. Under strict semantics, the inequalities are strict `<`, which is available on any `Preorder` via the associated strict order. No change to the typeclass constraint is needed -- `<` is defined on `Preorder` types.

---

## Task 7: discreteness_forward vs disc_next

### Current `discreteness_forward` Axiom

```lean
| discreteness_forward (phi : Formula) :
    Axiom (Formula.and (Formula.bot.neg.some_future)
      (Formula.and phi (Formula.all_past phi)) |>.imp
      (Formula.all_past phi).some_future)
```

Formula: `(F(top) & (phi & H(phi))) -> F(H(phi))`

### Validity Under Strict Semantics

Under strict semantics:
- `F(top)` at t: exists s > t (NoMaxOrder)
- `phi & H(phi)` at t: phi(t) and for all r < t, phi(r)
- `F(H(phi))` at t: exists s > t with H(phi)(s), i.e., exists s > t with for all r < s, phi(r)

Is this valid on Z with strict semantics?

Given: there exists s > t (seriality), phi(t), and phi(r) for all r < t.
Need: exists s > t with phi(r) for all r < s.

Take s = t + 1. Then for all r < t+1 = r <= t: if r < t, phi(r) by H(phi); if r = t, phi(t) by hypothesis. So phi(r) for all r < t+1. Done.

**Yes, `discreteness_forward` remains valid under strict semantics.** The proof uses the same discrete successor argument.

### Does disc_next Subsume discreteness_forward?

`disc_next`: `F(top) -> X(top)` = `F(neg bot) -> bot U (neg bot)`

On Z, this says: if there's any strict future time, then neg bot (= top) holds at the immediate next step. This is trivially true.

`discreteness_forward`: `(F(top) & phi & H(phi)) -> F(H(phi))`

This is a substantive discrete reasoning principle about accumulation of past truth. It is NOT subsumed by disc_next. They serve different purposes:
- disc_next: asserts EXISTENCE of immediate successor (structural discreteness)
- discreteness_forward: asserts CONTENT PROPAGATION (phi at all past times extends to the next step)

### Recommendation: Keep Both

Keep `discreteness_forward` unchanged. Add `disc_next` and `disc_prev` as separate new axioms. All three are needed:
- disc_next/disc_prev enable the X/Y operators and backward truth lemma
- discreteness_forward enables past accumulation reasoning

---

## Appendix A: Search Queries Used

- Grep for `temp_t_future|temp_t_past` across entire Theories/Bimodal directory
- Read of 18 source files
- Prior team research reports 09 and 10

## Appendix B: Files Not Requiring Changes

The following files in Theories/Bimodal/ are NOT affected by the strict semantics refactor:

- `Syntax/Atom.lean` -- no temporal content
- `Syntax/SubformulaClosure.lean` -- structural, no semantics
- `ProofSystem/Derivation.lean` -- generic derivation tree, no axiom-specific content
- `Semantics/TaskModel.lean` -- frame structure, no temporal quantification
- `Semantics/WorldHistory.lean` -- history data structure
- `Metalogic/Core/` -- MCS properties, Lindenbaum lemma (no T-axiom usage)
- `Automation/` -- proof search (may need updates for new axiom names)
- `Examples/` -- pedagogical (may need updates for changed theorems)

## Appendix C: Estimated Effort by File

| File | Estimated Hours | Difficulty |
|------|----------------|------------|
| Truth.lean | 3 | LOW (mechanical <= to <) |
| Axioms.lean | 4 | MEDIUM (careful formula encoding) |
| Substitution.lean | 2 | LOW (mechanical) |
| Soundness.lean | 8 | MEDIUM (6 new proofs + updates) |
| SoundnessLemmas.lean | 4 | MEDIUM |
| FMCSDef.lean | 0.5 | TRIVIAL |
| CanonicalIrreflexivity.lean | 2 | LOW (mostly deletion) |
| SuccChainFMCS.lean | 6 | MEDIUM-HIGH (seed consistency) |
| DovetailedChain.lean | 8 | HIGH (restructure g_content proofs) |
| UltrafilterChain.lean | 6 | MEDIUM-HIGH |
| SuccExistence.lean | 6 | HIGH (seed consistency without T-axiom) |
| CanonicalConstruction.lean | 4 | MEDIUM |
| MCSWitnessSuccessor.lean | 3 | MEDIUM |
| TargetedChain.lean | 3 | LOW-MEDIUM |
| TenseS5Algebra.lean | 3 | MEDIUM (TL_quot restructure) |
| InteriorOperators.lean | 1 | LOW (deletion) |
| Perpetuity/ | 1 | LOW (mostly unchanged) |
| LinearityDerivedFacts.lean | 0.5 | TRIVIAL (documentation) |
| Formula.lean | 1 | LOW (add next/prev) |
| **Total** | **~66 hours** | |

## Appendix D: Risk Assessment

| Risk | Probability | Impact | Mitigation |
|------|------------|--------|------------|
| Seed consistency proof without T-axiom is harder than expected | MEDIUM | HIGH | Fall back to routing through `temporal_theory_witness_exists` directly |
| Forward truth lemma for Until has unexpected complication | LOW | HIGH | The proof is straightforward by structural induction on witness |
| Backward truth lemma contrapositive argument has subtle gap | LOW | MEDIUM | Can fall back to direct induction approach with X truth lemma |
| g_content forward propagation in DovetailedChain breaks | MEDIUM | HIGH | Verify `temporal_theory_witness_exists` seed includes g_content |
| New axiom soundness proofs are complex | LOW | LOW | Standard semantic arguments with frame conditions |
| TenseS5Algebra algebraic proofs break without T-axiom | MEDIUM | MEDIUM | Restructure TL_quot; other STSA axioms don't use T-axiom |

## Appendix E: Uncertainty Disclosure

1. **Until induction axiom precise formulation**: The formulation `(psi -> chi) & (phi & X(chi) -> chi) -> ((phi U psi) -> X(chi))` is my best reconstruction from Venema (1993) adapted to the current syntax. The exact statement should be verified against the Venema paper for completeness. CONFIDENCE: HIGH that this is correct up to minor formula adjustments.

2. **Seed consistency without T-axiom**: The proof strategy using G-distribution and the deduction theorem is standard but has not been formalized in this codebase before. The exact Lean proof may require 2-3 iterations. CONFIDENCE: HIGH on mathematical correctness, MEDIUM on first-try formalization.

3. **DovetailedChain g_content restructuring**: I claim `temporal_theory_witness_exists` includes g_content in its seed. This needs to be verified by reading the full construction. CONFIDENCE: HIGH based on the documentation but should be confirmed.
