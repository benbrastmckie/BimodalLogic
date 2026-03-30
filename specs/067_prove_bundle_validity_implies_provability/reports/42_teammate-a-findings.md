# Teammate A Findings: g_nesting_depth Infrastructure

## Key Findings

### 1. Formula Structure for G vs F

`Formula.all_future` is a **primitive constructor** (not derived):
```
inductive Formula
  | all_future : Formula → Formula   -- G (universal future)
  | all_past   : Formula → Formula   -- H (universal past)
  | ...
```

`Formula.some_future` (F) is **derived**: `Fφ = ¬G¬φ = (G(φ.imp bot)).imp bot`
```lean
-- Lean encoding:
Formula.imp (Formula.all_future (Formula.imp φ Formula.bot)) Formula.bot
```

This is why `f_nesting_depth` has the complex pattern match:
```lean
def f_nesting_depth : Formula → Nat
  | .imp (.all_future (.imp inner .bot)) .bot => 1 + f_nesting_depth inner
  | _ => 0
```

But `g_nesting_depth` is **simpler** because G is primitive:
```lean
def g_nesting_depth : Formula → Nat
  | .all_future inner => 1 + g_nesting_depth inner
  | _ => 0
```

### 2. Nothing Exists Yet

Local search confirms: **no `g_nesting_depth`, `max_G_depth`, or `iter_G` exists** in the codebase.
All must be created.

### 3. The Sorry's Proof Requirement

The sorry at `SuccChainFMCS.lean:2949` is in Case 2 of `boundary_implies_k_plus_d_bounded`,
where `iter_F (d+1) theta ∉ chain(k')` (fresh entry at chain(k'+1)).

The proof comment (lines 2920-2949) states the required argument:
- If `iter_F d theta ∈ chain(k'+1)` entered "fresh" (not from f_content),
  it must be from `g_content`: `G(iter_F d theta) ∈ chain(k')`.
- G-persistence backwards: `G(G(iter_F d theta)) ∈ chain(k'-1)`, etc.
- Inductively: `G^m(iter_F d theta) ∈ chain(k'+1-m)`.
- At `m = k'+1`: `G^(k'+1)(iter_F d theta) ∈ chain(0) ⊆ deferralClosure`.
- `g_nesting_depth(G^(k'+1)(iter_F d theta)) = k'+1 + g_nesting_depth(iter_F d theta)`.
- But `g_nesting_depth(iter_F d theta) = 0` (F-formulas are imp-patterns, not raw all_future).
- So `g_nesting_depth(G^(k'+1)(iter_F d theta)) = k'+1`.
- Since all deferralClosure formulas have `g_nesting_depth ≤ max_G_depth_in_closure phi`:
  `k'+1 ≤ max_G_depth_in_closure phi`.

### 4. Relationship Between G-depth and F-depth

They are **independent** measures. Key facts:
- `f_nesting_depth(.all_future psi) = 0` (G-formula is not F-formula)
- `g_nesting_depth(iter_F d theta) = 0` (F-formula is an imp-pattern, not all_future)
- `g_nesting_depth(G^n(psi)) = n + g_nesting_depth(psi)`

### 5. Maximum G-depth in deferralClosure

The deferralClosure has four parts:
1. `closureWithNeg(phi)`: G-depth bounded by number of nested all_future in phi
2. `deferralDisjunctionSet(phi)`: `chi ∨ F(chi)` formulas, g_nesting_depth = 0
3. `backwardDeferralSet(phi)`: `chi ∨ P(chi)` formulas, g_nesting_depth = 0
4. `serialityFormulas`: includes `G_neg_neg_bot = all_future neg_neg_bot`, g_nesting_depth = 1;
   `neg_G_neg_neg_bot = (all_future neg_neg_bot).imp bot`, g_nesting_depth = 0

So `max_G_depth_in_closure phi = max((closureWithNeg phi).sup g_nesting_depth, 1)`.

The "+1" floor comes from `G_neg_neg_bot ∈ serialityFormulas ⊆ deferralClosure`.

### 6. Negations of G-formulas Have g_nesting_depth = 0

A key subtlety: `neg(G^n(psi)) = (G^n(psi)).imp bot`.
This matches the `imp` branch (default case `_ => 0`) in g_nesting_depth, not `all_future`.
So negated G-formulas have g_nesting_depth 0 - only raw all_future counts.

### 7. Proof Also Needs iter_G and a Key Backward-Trace Lemma

The proof requires an `iter_G` function analogous to `iter_F`:
```lean
def iter_G : Nat → Formula → Formula
  | 0, phi => phi
  | n + 1, phi => Formula.all_future (iter_G n phi)
```

And a key lemma: `g_nesting_depth (iter_G n phi) = n + g_nesting_depth phi`.

The backward-trace induction for the sorry also needs:
```lean
-- If psi ∈ chain(k'+1) entered fresh (not from f_content at k'),
-- then G(psi) ∈ chain(k') (because psi came from g_content(chain(k'))).
-- This is the CONVERSE of g_persistence. Does this hold?
```

**Critical issue**: G-persistence says `g_content(u) ⊆ successor(u)` (forward direction).
The backward direction needed is: if `psi ∈ successor(u)` and `F(psi) ∉ u`, then `G(psi) ∈ u`.
This is NOT directly available and may require examining the seed construction.

Looking at `constrained_successor_seed_restricted`, the seed is:
`g_content(u) ∪ deferralDisjunctions(u) ∪ p_step_blocking ∪ boundary_resolution_set(phi, u)`

For `iter_F d theta` to be in the successor but NOT from f_content, it must be in:
- The seed via `g_content`: i.e., `G(iter_F d theta) ∈ u`
- OR `deferralDisjunctions`: `(iter_F d theta) ∨ F(iter_F d theta)` - this puts `iter_F d theta` in
  only if `iter_F d theta ∨ F(iter_F d theta)` is in seed AND Lindenbaum resolves the disjunction
  to the left. This is possible but uncertain.
- OR boundary_resolution_set
- OR via Lindenbaum extension from the seed

The proof sketch at lines 2900-2935 acknowledges these cases and focuses on the "g_content" path.
A complete proof may need to handle the Lindenbaum case separately.

### 8. Alternative: Use |deferralClosure| as a Bound

A simpler alternative: every formula in `chain(k)` is in `deferralClosure phi` (by DRM property).
The chain consists of sets of formulas from the finite set `deferralClosure phi`.
So `restricted_forward_chain phi M0 k` is a finitely-supported sequence.

**However, this bounds the number of distinct chain worlds, not k directly.**
Two different chain positions can have the same world (set of formulas). This doesn't
immediately bound k.

### 9. What Placement in SubformulaClosure.lean Is Best

The infrastructure should be added to `SubformulaClosure.lean` right after the `p_nesting_depth`
section (around line 535). The file already has analogous blocks for f/p nesting depth:
- Lines 382-453: f_nesting_depth and max_F_depth_in_closure
- Lines 455-534: p_nesting_depth and max_P_depth_in_closure

A new section "G-Nesting Depth" should follow at ~line 535.

## Recommended Definitions (with exact Lean code)

### Definition 1: g_nesting_depth in SubformulaClosure.lean

```lean
/-!
## G-Nesting Depth

The G-nesting depth counts how many G (all_future) operators wrap a formula.
Unlike F-nesting depth, G is a primitive constructor so the definition is direct.
-/

/--
Count the G-nesting depth at the outermost level of a formula.

`g_nesting_depth (G(G(G(phi)))) = 3`
`g_nesting_depth (phi) = 0` when phi is not a raw G-formula

Note: This counts consecutive outermost all_future constructors only.
G is primitive (unlike F = neg ∘ all_future ∘ neg), so the pattern is simple.
-/
def g_nesting_depth : Formula → Nat
  | .all_future inner => 1 + g_nesting_depth inner
  | _ => 0

/-- g_nesting_depth is always non-negative (trivially true for Nat). -/
theorem g_nesting_depth_nonneg (phi : Formula) : g_nesting_depth phi ≥ 0 := Nat.zero_le _

/-- G-nesting depth of G(psi) is 1 + depth of psi. -/
theorem g_nesting_depth_all_future (psi : Formula) :
    g_nesting_depth (Formula.all_future psi) = 1 + g_nesting_depth psi := by
  simp only [g_nesting_depth]

/-- Atoms have G-nesting depth 0. -/
@[simp]
theorem g_nesting_depth_atom (a : Bimodal.Syntax.Atom) : g_nesting_depth (.atom a) = 0 := rfl

/-- Bot has G-nesting depth 0. -/
@[simp]
theorem g_nesting_depth_bot : g_nesting_depth .bot = 0 := rfl

/-- Imp formulas have G-nesting depth 0. -/
@[simp]
theorem g_nesting_depth_imp (psi chi : Formula) : g_nesting_depth (.imp psi chi) = 0 := rfl

/-- Box formulas have G-nesting depth 0. -/
@[simp]
theorem g_nesting_depth_box (psi : Formula) : g_nesting_depth (.box psi) = 0 := rfl

/-- all_past formulas have G-nesting depth 0. -/
@[simp]
theorem g_nesting_depth_all_past (psi : Formula) : g_nesting_depth (.all_past psi) = 0 := rfl

/-- F-formulas (some_future) have G-nesting depth 0. -/
theorem g_nesting_depth_some_future (psi : Formula) :
    g_nesting_depth (Formula.some_future psi) = 0 := by
  simp only [Formula.some_future, Formula.neg, g_nesting_depth]
```

### Definition 2: max_G_depth_in_closure in SubformulaClosure.lean

```lean
/-!
## Maximum G-Depth in Closure

The maximum G-nesting depth over all formulas in closureWithNeg(phi).
-/

/--
Maximum G-nesting depth of any formula in closureWithNeg(phi).
-/
def max_G_depth_in_closure (phi : Formula) : Nat :=
  (closureWithNeg phi).sup g_nesting_depth

/--
Every element of closureWithNeg has G-depth at most max_G_depth_in_closure.
-/
theorem g_depth_le_max {phi psi : Formula} (h : psi ∈ closureWithNeg phi) :
    g_nesting_depth psi ≤ max_G_depth_in_closure phi :=
  Finset.le_sup h

/--
Maximum G-nesting depth in deferralClosure equals max in closureWithNeg (or 1 for G_neg_neg_bot).

G_neg_neg_bot = all_future neg_neg_bot ∈ serialityFormulas has g_nesting_depth 1.
-/
theorem max_G_depth_deferralClosure_eq (phi : Formula) :
    (deferralClosure phi).sup g_nesting_depth = max (max_G_depth_in_closure phi) 1 := by
  apply le_antisymm
  · apply Finset.sup_le
    intro f hf
    unfold deferralClosure at hf
    simp only [Finset.mem_union] at hf
    rcases hf with ((hf_orig | hf_defer_F) | hf_defer_P) | hf_serial
    · exact le_max_of_le_left (g_depth_le_max hf_orig)
    · -- deferralDisjunctionSet: chi ∨ F(chi), g_nesting_depth = 0
      unfold deferralDisjunctionSet at hf_defer_F
      simp only [Finset.mem_image, Finset.mem_filter] at hf_defer_F
      obtain ⟨g, ⟨_, _⟩, hf_eq⟩ := hf_defer_F
      simp only [toFutureDeferral] at hf_eq
      split at hf_eq <;> simp_all [g_nesting_depth, Formula.or, Formula.neg]
    · -- backwardDeferralSet: chi ∨ P(chi), g_nesting_depth = 0
      unfold backwardDeferralSet at hf_defer_P
      simp only [Finset.mem_image, Finset.mem_filter] at hf_defer_P
      obtain ⟨g, ⟨_, _⟩, hf_eq⟩ := hf_defer_P
      simp only [toPastDeferral] at hf_eq
      split at hf_eq <;> simp_all [g_nesting_depth, Formula.or, Formula.neg]
    · -- serialityFormulas: max g_depth = 1 (from G_neg_neg_bot)
      simp only [serialityFormulas, Finset.mem_insert, Finset.mem_singleton] at hf_serial
      rcases hf_serial with rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl
      · -- F_top = some_future (neg bot), g_nesting_depth = 0
        simp [g_nesting_depth_some_future]
      · -- P_top, g_nesting_depth = 0
        simp [Formula.some_past, Formula.neg, g_nesting_depth]
      · -- neg bot = imp bot bot, g_nesting_depth = 0
        simp [Formula.neg, g_nesting_depth]
      · -- neg_neg_bot = imp (imp bot bot) bot, g_nesting_depth = 0
        simp [neg_neg_bot, Formula.neg, g_nesting_depth]
      · -- G_neg_neg_bot = all_future neg_neg_bot, g_nesting_depth = 1
        simp [G_neg_neg_bot, g_nesting_depth_all_future, neg_neg_bot, g_nesting_depth]
        exact le_max_of_le_right (by norm_num)
      · -- H_neg_neg_bot = all_past neg_neg_bot, g_nesting_depth = 0
        simp [H_neg_neg_bot, g_nesting_depth]
      · -- neg_G_neg_neg_bot = (all_future neg_neg_bot).imp bot, g_nesting_depth = 0
        simp [neg_G_neg_neg_bot, Formula.neg, g_nesting_depth]
      · -- neg_H_neg_neg_bot, g_nesting_depth = 0
        simp [neg_H_neg_neg_bot, Formula.neg, g_nesting_depth]
      · -- F_top_deferral = or (neg bot) F_top, g_nesting_depth = 0
        simp [F_top_deferral, Formula.or, Formula.neg, g_nesting_depth]
      · -- P_top_deferral, g_nesting_depth = 0
        simp [P_top_deferral, Formula.or, Formula.neg, g_nesting_depth]
  · apply max_le
    · apply Finset.sup_mono; exact closureWithNeg_subset_deferralClosure phi
    · calc 1 = g_nesting_depth G_neg_neg_bot := by simp [G_neg_neg_bot, g_nesting_depth_all_future, neg_neg_bot, g_nesting_depth]
        _ ≤ (deferralClosure phi).sup g_nesting_depth :=
            Finset.le_sup (G_neg_neg_bot_mem_deferralClosure phi)
```

### Definition 3: iter_G in CanonicalTaskRelation.lean (or SuccChainFMCS.lean)

```lean
/--
n-fold application of the G (all_future) operator.

- `iter_G 0 φ = φ`
- `iter_G (n+1) φ = G(iter_G n φ)`
-/
def iter_G : Nat → Formula → Formula
  | 0, phi => phi
  | n + 1, phi => Formula.all_future (iter_G n phi)

@[simp]
lemma iter_G_zero (phi : Formula) : iter_G 0 phi = phi := rfl

@[simp]
lemma iter_G_succ (n : Nat) (phi : Formula) :
    iter_G (n + 1) phi = Formula.all_future (iter_G n phi) := rfl

/-- G-nesting depth of iter_G n phi is n + g_nesting_depth phi. -/
lemma iter_G_g_nesting_depth (n : Nat) (phi : Formula) :
    Bimodal.Syntax.g_nesting_depth (iter_G n phi) = n + Bimodal.Syntax.g_nesting_depth phi := by
  induction n with
  | zero => simp only [iter_G_zero, Nat.zero_add]
  | succ k ih =>
    simp only [iter_G_succ, Bimodal.Syntax.g_nesting_depth_all_future, ih]
    omega

/-- F-nesting depth of iter_G n phi is 0 (G-formulas are not F-formulas). -/
lemma iter_G_f_nesting_depth (n : Nat) (phi : Formula)
    (h : Bimodal.Syntax.f_nesting_depth phi = 0) :
    Bimodal.Syntax.f_nesting_depth (iter_G n phi) = 0 := by
  induction n with
  | zero => simp [iter_G_zero, h]
  | succ k ih =>
    simp [iter_G_succ, Bimodal.Syntax.f_nesting_depth_all_future]
```

### Key Lemma Needed for the Sorry's Proof

The most critical infrastructure beyond these definitions is a backward-trace lemma for G in the restricted chain. The proof sketch in the sorry needs:

```lean
/--
If psi ∈ restricted_forward_chain phi M0 (k+1) and
F(psi) ∉ restricted_forward_chain phi M0 k, then
G(psi) ∈ restricted_forward_chain phi M0 k.

This is the "fresh entry via g_content" characterization.
-/
theorem restricted_forward_chain_fresh_entry_from_g_content (phi : Formula)
    (M0 : DeferralRestrictedSerialMCS phi) (k : Nat) (psi : Formula)
    (h_in : psi ∈ restricted_forward_chain phi M0 (k + 1))
    (h_not_f : Formula.some_future psi ∉ restricted_forward_chain phi M0 k) :
    Formula.all_future psi ∈ restricted_forward_chain phi M0 k := by
  sorry -- Requires analyzing the seed structure
```

**WARNING**: This lemma may be FALSE or very hard to prove, because the Lindenbaum extension
could add `psi` from a deferral disjunction `psi ∨ F(psi)` (picking the left disjunct without
`G(psi)` being in `u`). The presence of `boundary_resolution_set` in the seed is another route.

## Evidence/Examples

### F-depth vs G-depth separation

```
iter_F 3 theta = F(F(F(theta)))
  f_nesting_depth = 3
  g_nesting_depth = 0

iter_G 3 (iter_F 2 theta) = G(G(G(F(F(theta)))))
  f_nesting_depth = 0 (all_future, not some_future pattern)
  g_nesting_depth = 3
```

Wait - `f_nesting_depth(all_future inner) = 0` by `f_nesting_depth_all_future`.
And `g_nesting_depth(iter_F d theta) = 0` since iter_F builds imp-patterns.

### G_neg_neg_bot g_nesting_depth
```
G_neg_neg_bot = all_future neg_neg_bot = all_future ((bot.imp bot).imp bot)
g_nesting_depth G_neg_neg_bot = 1 + g_nesting_depth neg_neg_bot = 1 + 0 = 1
```

## Confidence Level

**High** for the definitions of `g_nesting_depth`, `max_G_depth_in_closure`, `iter_G`, and
`iter_G_g_nesting_depth`. These are straightforward analogs of existing f_nesting_depth infrastructure.

**Medium** for `max_G_depth_deferralClosure_eq`. The proof strategy mirrors `max_F_depth_deferralClosure_eq`
but the seriality formula case needs careful checking. G_neg_neg_bot has g_nesting_depth 1, providing
the floor of 1.

**Low** for the backward-trace lemma `restricted_forward_chain_fresh_entry_from_g_content`. This is
the most critical missing piece but may require examining whether deferral disjunctions could
provide a non-g_content route for fresh entries, potentially invalidating the backward-trace argument.

**Conclusion**: The `g_nesting_depth` infrastructure is straightforward to add. The deeper challenge
is the backward-trace characterization lemma. The sorry may require either:
1. Proving the backward trace (needs detailed analysis of the seed structure), or
2. An alternative proof that bounds k' by some other measure (e.g., |deferralClosure| is finite,
   so the chain must eventually cycle - but this requires a different argument for boundedness).
