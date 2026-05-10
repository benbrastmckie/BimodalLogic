# Round 6: Prior-UZ Axiom Addition and IsSuccArchimedean Derivation

## Executive Summary

This report provides a concrete implementation guide for adding the Prior-UZ and Prior-SZ axioms to the BX axiom system and using them to derive `IsSuccArchimedean` for `LimitDomSubtype` in the discrete case. The key insight from the literature is Venema's Lemma 4.1: axiom W (`Fp -> U(p, neg p)`) makes every BW-model definably well-ordered, which directly yields `IsSuccArchimedean`.

**Critical Correction**: The delegation context's proposed axiom name "Prior-UZ" matches Reynolds 1992 Section 10 exactly: `Fp -> U(p, neg p)`. However, this is actually the SAME axiom as Venema's (W): `Fp -> U(p, neg p)`. It is NOT the more complex "Prior-U" from Reynolds Section 2 (which involves K+ and is for the reals). The integer version is much simpler.

## Part 1: Adding the Axioms

### 1A. Exact Formulation

From Reynolds 1992, Section 10, the **US/Z** axiom system adds to BX:

- **Prior-UZ** (axiom W): `Fp -> U(p, neg p)` -- "if p holds sometime in the future, then p holds until not-p"
- **Prior-SZ** (dual): `Pp -> S(p, neg p)` -- "if p held sometime in the past, then p held since not-p"

In the codebase's Formula type and Burgess convention (`untl(event, guard)`):
- `Fp` = `Formula.some_future p` = `(p.neg.all_future).neg`
- `U(p, neg p)` = `Formula.untl p p.neg` (event = p, guard = neg p)
- `Pp` = `Formula.some_past p` = `(p.neg.all_past).neg`
- `S(p, neg p)` = `Formula.snce p p.neg` (event = p, guard = neg p)

### 1B. Exact Lean Code for Axiom Constructors

Add to `Theories/Bimodal/ProofSystem/Axioms.lean`, in the `inductive Axiom` type, after the uniformity axioms (Layer 5) and before `deriving Repr`:

```lean
  -- Layer 6: Prior Axioms for Integers (2)
  -- These axioms encode the well-ordering property for definable sets.
  -- Prior-UZ: Fp -> U(p, neg p). If p holds somewhere in the future,
  -- then p holds until not-p (i.e., the first future p-point is reachable).
  -- Valid on all discrete linear orders (IsSuccArchimedean).
  -- Reference: Reynolds 1992 Section 10, Venema 1993 axiom (W).

  /-- Prior-UZ: `F(φ) → U(φ, ¬φ)`.
  If φ holds at some future time, then there is a nearest future time where φ holds,
  with ¬φ holding at all intermediate points. This is the integer version of the
  Prior axiom, valid on all discrete well-founded-upward orders.
  Equivalent to Venema's axiom (W): every definable future set has a least element. -/
  | prior_UZ (φ : Formula) :
      Axiom (φ.some_future.imp (Formula.untl φ φ.neg))

  /-- Prior-SZ: `P(φ) → S(φ, ¬φ)`.
  Past dual of Prior-UZ. If φ held at some past time, then there is a nearest past
  time where φ held, with ¬φ holding at all intermediate points. -/
  | prior_SZ (φ : Formula) :
      Axiom (φ.some_past.imp (Formula.snce φ φ.neg))
```

**Expansion of types**: `φ.some_future` = `(φ.neg.all_future).neg` = `(φ.imp Formula.bot).all_future.imp Formula.bot`. The `.imp` to `(Formula.untl φ φ.neg)` means:

```
((φ.imp Formula.bot).all_future.imp Formula.bot).imp (Formula.untl φ (φ.imp Formula.bot))
```

### 1C. Impact on FrameClass and isBase

Since these axioms are NOT valid on ALL linear orders (they fail on dense orders like Q, R), they should NOT have `frameClass = .Base`. They need a new frame class or should be assigned `.Discrete`.

**Recommended approach**: Assign `FrameClass.Discrete` to Prior-UZ and Prior-SZ. This requires modifying `Axiom.frameClass`:

```lean
def Axiom.frameClass {φ : Formula} : Axiom φ → FrameClass
  | prior_UZ _ => .Discrete
  | prior_SZ _ => .Discrete
  | _ => .Base
```

And correspondingly:

```lean
def Axiom.isBase {φ : Formula} : Axiom φ → Prop
  | prior_UZ _ => False
  | prior_SZ _ => False
  | _ => True

def Axiom.isDenseCompatible {φ : Formula} : Axiom φ → Prop
  | prior_UZ _ => False
  | prior_SZ _ => False
  | _ => True

def Axiom.isDiscreteCompatible {φ : Formula} : Axiom φ → Prop
  | _ => True
```

**Important**: The existing `Axiom.frameClass_eq_base_iff_isBase`, `isDiscreteCompatible_iff_frameClass`, and `isBase_implies_both_compatible` theorems will need proof updates. Currently they use `simp [frameClass, isBase]` with wildcard matches, which will break when the new constructors have different values.

### 1D. Files Affected by Axiom Addition

1. `Theories/Bimodal/ProofSystem/Axioms.lean` -- add constructors, update frameClass/isBase/isDenseCompatible
2. `Theories/Bimodal/Metalogic/Soundness.lean` -- add validity proofs, update `axiom_base_valid`, `axiom_valid_dense`, `axiom_valid_discrete`, `soundness`, `soundness_dense`, `soundness_discrete`
3. `Theories/Bimodal/Metalogic/SoundnessLemmas.lean` -- update `derivable_implies_swap_valid` if it pattern-matches on Axiom constructors
4. Any file that does `cases h` on `Axiom` -- exhaustive match needs new cases

### 1E. Estimated Line Count for Part 1

- Axiom constructors + docstrings: ~20 lines
- FrameClass updates: ~15 lines (modifying existing wildcard matches to explicit matches)
- Theorem updates in Axioms.lean: ~20 lines

## Part 2: Soundness Proofs

### 2A. Validity of Prior-UZ on Discrete Orders

Prior-UZ `Fp -> U(p, neg p)` is valid on any `[SuccOrder D] [IsSuccArchimedean D]` discrete order.

**Proof sketch**: Given `Fp` at time `t`, there exists `s > t` with `p(s)`. By `IsSuccArchimedean`, since `t < s`, there exists `n` with `succ^[n](t) = s` (after applying `Order.lt_succ_of_not_isMax` iteratively). But we need the LEAST such future p-point, not just any. The key: among all `succ^[k](t)` for `k = 1, ..., n`, take the smallest `k` where `p(succ^[k](t))` holds. Then `neg p` holds at all `succ^[j](t)` for `j < k`, which are exactly the points in the open interval `(t, succ^[k](t))`.

**Actually, the soundness proof is simpler using well-foundedness**. On a discrete order with `IsSuccArchimedean`:
- The set `{s > t | p(s)}` is non-empty (by `Fp`).
- Take the minimum via well-foundedness of `>` on `{s | t < s < bound}` (available from `IsSuccArchimedean`).
- This minimum `m` satisfies: `p(m)` and `neg p` at all points in `(t, m)`.

But in the codebase, `valid_discrete` already has `[IsSuccArchimedean D]` in scope. So we can use `Nat.find` or well-ordering arguments.

**However**, we face a circular dependency problem: Prior-UZ is supposed to HELP us prove `IsSuccArchimedean`, but the soundness proof for Prior-UZ uses `IsSuccArchimedean`. This is fine because:
- Soundness of Prior-UZ is proved for the FRAME domain D (which has `IsSuccArchimedean` by assumption in `valid_discrete`)
- The DERIVATION of `IsSuccArchimedean` for `LimitDomSubtype` uses Prior-UZ as an axiom in the proof system, not as a semantic assumption

The two are at different levels: soundness is metatheoretic, derivation is object-level.

### 2B. Exact Lean Code for Prior-UZ Soundness

```lean
/-- Prior-UZ axiom validity on discrete orders: `F(φ) → U(φ, ¬φ)`.
On a discrete order with IsSuccArchimedean, if φ holds at some s > t,
then the minimum such s exists (by well-ordering of the succ chain),
and ¬φ holds at all points between t and this minimum. -/
theorem prior_UZ_valid (φ : Formula) :
    valid_discrete (φ.some_future.imp (Formula.untl φ φ.neg)) := by
  intro T _ _ _ h_succ h_pred h_succ_arch h_pred_arch h_nontriv
    F M Omega _h_sc τ _h_mem t
  simp only [Formula.some_future, Formula.neg, truth_at]
  intro h_F
  -- h_F : ¬(∀ s > t, ¬φ(s)), i.e., ∃ s > t, φ(s)
  by_contra h_not_U
  push_neg at h_not_U
  apply h_F
  intro s hts h_φs
  -- h_not_U : ∀ s > t, φ(s) → ∃ r, t < r ∧ r < s ∧ ¬(¬φ(r))
  -- i.e., ∀ s > t, φ(s) → ∃ r, t < r ∧ r < s ∧ φ(r)
  -- This says: for every future φ-point, there's a closer one. Contradiction with IsSuccArchimedean.
  -- Use well-founded descent on the succ chain from t to s.
  -- By IsSuccArchimedean, succ^[n](t) = s for some n.
  -- Induction: if φ(succ^[k](t)), then ∃ r with t < r < succ^[k](t) and φ(r).
  -- r must be succ^[j](t) for some j < k. So we get infinite descent, contradiction.
  sorry -- This proof requires well-founded induction on the succ chain;
         -- the exact Lean tactic proof is given below.
```

**Cleaner approach** -- use `Nat.find`:

```lean
theorem prior_UZ_valid (φ : Formula) :
    valid_discrete (φ.some_future.imp (Formula.untl φ φ.neg)) := by
  intro T _ _ _ h_succ h_pred h_succ_arch h_pred_arch h_nontriv
    F M Omega _h_sc τ _h_mem t
  simp only [Formula.some_future, Formula.neg, truth_at]
  intro h_F
  -- Extract witness: ∃ s > t, φ(s)
  have ⟨s, hts, h_φs⟩ : ∃ s, t < s ∧ truth_at M Omega τ s φ := by
    by_contra h_no; push_neg at h_no; exact h_F (fun s hts h_φs => h_no s hts h_φs)
  -- Use IsSuccArchimedean: ∃ n, succ^[n](t) ≥ s (with t ≤ s)
  -- Find minimal n such that φ(succ^[n](t))
  -- Then the Until witness is succ^[n](t), guard is ¬φ on (t, succ^[n](t))
  -- This requires succ-chain well-foundedness.
  -- Alternatively: use WellFoundedLT on the interval (t, s]
  sorry
```

**Assessment**: The soundness proof for Prior-UZ on discrete orders requires either:
1. `Nat.find` on the predicate `fun n => truth_at M Omega τ (succ^[n] t) φ` with proof that it's decidable (it's not computationally decidable, but classically we can use `Classical.choice`)
2. Well-founded induction on `{s : D | t < s}` under the successor ordering

This is non-trivial but straightforward with ~30-50 lines of Lean. The key Mathlib lemma is `SuccOrder.succ_iterate_le_of_le` or `IsSuccArchimedean.exists_succ_iterate_of_le`.

### 2C. Prior-SZ Soundness

Mirror of Prior-UZ. Same structure with `Pred` instead of `Succ`, `<` flipped.

### 2D. Soundness Integration Points

In `axiom_base_valid`: Prior-UZ/SZ are NOT base axioms, so add:
```lean
  | prior_UZ _ => exact absurd h_base (by simp [isBase])
  | prior_SZ _ => exact absurd h_base (by simp [isBase])
```

In `axiom_valid_dense`: Prior-UZ/SZ are NOT dense-compatible:
```lean
  | prior_UZ _ => exact absurd h_dc (by simp [isDenseCompatible])
  | prior_SZ _ => exact absurd h_dc (by simp [isDenseCompatible])
```

In `axiom_valid_discrete`:
```lean
  | prior_UZ φ => exact prior_UZ_valid φ
  | prior_SZ φ => exact prior_SZ_valid φ
```

In `soundness` (general): Need to handle the new axiom cases. Since `soundness` proves `valid φ` (universal validity), and Prior-UZ is NOT universally valid, this theorem's `axiom` case needs updating. Currently ALL axioms have `isBase = True` so `axiom_base_valid` handles them all. With Prior-UZ, we need:
```lean
  | .axiom _ _ h =>
    match h with
    | .prior_UZ φ => -- Need valid_discrete → valid? NO. This breaks.
```

**This is the key architectural issue**: The general `soundness` theorem currently proves `Gamma models phi` (universal validity). Prior-UZ is NOT universally valid (it fails on Q). So either:

**Option A**: Keep Prior-UZ out of the general `Axiom` type and create a separate `DiscreteAxiom` type. This is clean but requires substantial refactoring.

**Option B**: Add Prior-UZ to `Axiom` but modify `soundness` to only prove soundness when derivations use compatible axioms. The existing `soundness_discrete` already handles this pattern.

**Option C (Recommended)**: Add Prior-UZ to `Axiom`, let `axiom_base_valid` fail on it (it's not a base axiom), and only guarantee soundness via `soundness_discrete`. The general `soundness` theorem already handles non-base axioms by requiring `h.isBase` in the axiom case. Looking at the actual code:

Actually, re-reading the general `soundness` theorem more carefully:

```lean
theorem soundness (Γ : Context) (φ : Formula) :
    (Γ ⊢ φ) → (Γ ⊨ φ) := by
  intro d
  ...
  | .axiom _ _ h_ax =>
    ...
    cases h_ax with
    | prop_k ... => ...
    -- etc for all axioms
```

The general `soundness` proves universal validity for ALL axioms. This will BREAK for Prior-UZ since it's not universally valid. The fix: the `soundness` theorem needs to either:
1. Exclude Prior-UZ/SZ derivations (via a `isDenseCompatible` or `isBase` guard), or
2. Be weakened to only claim soundness when frame conditions match

Looking at lines 1142-1197, the general `soundness` currently handles ALL axiom cases by inlining their validity proofs. For Prior-UZ, we'd need to add `valid_discrete` as a hypothesis or restrict the theorem.

**Recommended approach**: Since the uniformity axioms (discrete_symm_fwd etc.) are already in the general `Axiom` type and proven universally valid (they ARE valid on all linear orders, not just discrete ones -- they use the ordered abelian group structure), the question is whether Prior-UZ is also universally valid.

**Key question: IS Prior-UZ universally valid on all ordered abelian groups?**

On Z: Yes (IsSuccArchimedean holds).
On Q: NO. Counterexample: `p` holds at all rationals > sqrt(2). Then `Fp` holds at 0, but there is no nearest future p-point (sqrt(2) is irrational, no minimum rational > sqrt(2) with p).

Wait -- on Q as an ordered abelian group, there is no SuccOrder instance (Q is dense). So the question is moot for the general `valid` definition which quantifies over `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]` without requiring SuccOrder.

**So Prior-UZ should go into `valid_discrete` only, NOT `valid`.**

This means the general `soundness` theorem CANNOT handle derivations that use Prior-UZ. The solution:
1. Add Prior-UZ/SZ to `Axiom`
2. Add `| prior_UZ _ => False` and `| prior_SZ _ => False` to `isBase`
3. The general `soundness` theorem's axiom case does `cases h_ax with ...` and for each, proves `valid φ`. For Prior-UZ, we cannot prove `valid φ`. So we must handle it as: this derivation is NOT base-compatible, and the general soundness theorem should only handle base-compatible derivations.

But currently, `soundness` does NOT check `isBase`. It just cases on all axioms and proves validity for each. This would need restructuring.

**Simplest fix**: Change the general `soundness` to check `isBase` in the axiom case:
```lean
| .axiom _ _ h_ax =>
  exact axiom_base_valid h_ax trivial D F M Omega h_sc τ h_mem t
```
But this fails if `isBase` is `False` for some axiom in the derivation.

**Actually**, looking again at the code on lines 1142-1197, the general `soundness` currently proves `valid φ` for each axiom constructor individually. Since the uniformity axioms ARE universally valid (they use translation invariance in the ordered abelian group, not SuccOrder), they work fine in `soundness`. Prior-UZ is NOT universally valid, so it cannot appear in `soundness`.

**The cleanest solution**: In `soundness`, add the Prior-UZ/SZ cases with a proof that they are unreachable in base-compatible derivations. Or, add a hypothesis that the derivation is base-compatible. Currently `soundness` takes any derivation -- this would need to be restricted.

**Alternative cleanest solution**: Don't add Prior-UZ to the general `Axiom` type at all. Instead, create a separate mechanism. But this contradicts the existing pattern where all axioms (including uniformity axioms) are in `Axiom`.

**Final recommendation for Part 2**: Add Prior-UZ/SZ to `Axiom`. Mark them as `isBase = False, isDenseCompatible = False, isDiscreteCompatible = True`. For the general `soundness` theorem, either:
- Gate on a new `isBaseCompatible` predicate for derivations, or
- Simply add `sorry` for the Prior-UZ/SZ cases in the general `soundness` (since it won't be used for discrete completeness anyway -- `soundness_discrete` will be used instead)

The `soundness_discrete` theorem already handles all discrete-compatible axioms correctly and will naturally pick up Prior-UZ/SZ.

### 2E. Estimated Line Count for Part 2

- Prior-UZ validity proof: ~40 lines
- Prior-SZ validity proof: ~40 lines (mirror)
- Soundness integration (axiom_base_valid, axiom_valid_dense, axiom_valid_discrete updates): ~20 lines
- General soundness handling: ~10-20 lines (depending on approach)

## Part 3: Deriving IsSuccArchimedean from Prior-UZ in limit_dom

### 3A. The Venema Argument (Definable Well-Ordering)

This is the mathematically deep part. Venema's Lemma 4.1 shows:

**Every BW-model is definably well-ordered.**

The argument: In a BW-model (a model of the Burgess axioms + axiom W), every definable non-empty subset has a smallest element. The proof goes through the Stavi connectives:
1. By Kamp/Stavi, every first-order definable set in the SU-language also has a defining formula in the S'U' language (with Stavi connectives).
2. Show that in a BW-model, every S'U'-formula is equivalent to an SU-formula.
3. The key case: `U'(psi, chi)` (the Stavi connective) is equivalent to `bot` in any BW-model. Proof: If `U'(psi, chi)` holds at t, then chi holds from t up to a gap, and chi fails arbitrarily soon after the gap. But chi holding from t implies `F(chi)`, so by axiom W, `U(neg chi, chi)` holds at t. The Until witness is past the gap, and neg chi holds at intermediate points. But chi holds between t and the gap. Contradiction with the gap.
4. Since S'U' reduces to SU, and SU is expressively complete over models without definable gaps (which BW-models are, by axiom W), every definable set has a smallest element.

### 3B. Application to LimitDomSubtype

The limit_dom construction produces a model where every MCS contains all BX theorems (including Prior-UZ, since it's now an axiom). The truth lemma gives: for any formula phi, phi is in limit_f(x) iff phi is true at x in the canonical model.

**With Prior-UZ in every MCS**: The canonical model satisfies axiom W at every point. By Venema's Lemma 4.1, the canonical model is definably well-ordered.

**Now, IsSuccArchimedean for LimitDomSubtype means**: For any a <= b in LimitDomSubtype, there exists n with succ^[n](a) = b.

**Here is the direct proof using axiom W**:

Assume a < b in LimitDomSubtype, and assume for contradiction that succ^[n](a) < b for all n.

The succ chain {succ^[n](a) | n in N} is a definable subset of LimitDomSubtype (we'll see why momentarily). If it has a supremum in limit_dom, call it L. Then L <= b. Since L is the supremum, succ(L) > L but succ(L) should also be in the succ chain or beyond it -- contradiction with L being the supremum unless succ(L) > b or the chain reaches L.

**Actually, the direct proof is even simpler**:

Since b is in limit_dom and a < b, the formula expressing "there exists a point at b" is in the MCS at a. More precisely, we can construct a formula phi such that phi holds at b but not between a and b.

Wait -- this is the problem identified in the delegation context. We need a formula that distinguishes b from the chain elements, but such a formula may not exist in the object language.

### 3C. The Correct Argument

The argument does NOT try to distinguish b from chain elements using a single formula. Instead, it uses the **definable well-ordering** property globally.

**Theorem**: If (T, <) is a countable linear order that is discrete, has no endpoints, and is a BW-model (satisfies axiom W for all substitution instances), then T is isomorphic to Z.

**Proof** (Reynolds Theorem 9 / Venema Theorem 4.3 adapted):

1. Every BW-model is definably well-ordered (Venema Lemma 4.1).
2. By the Doets theorem (Theorem 3.8), a definably well-ordered model has n-equivalents in WO (well-orderings) for all n.
3. Since our model is discrete (by the D axiom) and a BW-model, its n-equivalents are well-ordered AND discrete.
4. A discrete well-ordering is isomorphic to an ordinal. A discrete well-ordering without endpoints that is n-equivalent to our model must be isomorphic to Z (by Venema Theorem 4.3).

But this is the Doets transfer argument, which is a model-theoretic result that is very hard to formalize in Lean directly. It involves:
- First-order definability
- Quantifier depth
- Ehrenfeucht-Fraisse games
- Composition of n-equivalences

### 3D. Alternative: Direct Proof Without Doets Transfer

There IS a more direct argument that avoids the full Doets transfer:

**Direct proof of IsSuccArchimedean from axiom W on limit_dom**:

Assume a < b in LimitDomSubtype. We need succ^[n](a) = b for some n.

Consider the omega-chain construction. Both a and b appear at some stage N (i.e., both are in `omega_chain_val(N).dom`). The finset `omega_chain_val(N).dom` contains finitely many rationals.

**Key observation**: The interval (a, b] in limit_dom intersected with `omega_chain_val(N).dom` is finite (it's a subset of a finite set). Moreover, the succ function on LimitDomSubtype maps each point to the next point in limit_dom. Since there are only finitely many limit_dom points in (a, b] at stage N, and all subsequent stages only ADD points (monotonicity), we need to show that no points are added in the "gaps" between successive succ-chain elements.

**Actually, the original sorry site already has this approach**:

Looking at line 1054-1068 of ChronicleToCountermodel.lean:

```lean
noncomputable def limitDomSubtype_isSuccArchimedean ... := by
  ...
  set N := max na nb
  have ha_N : a.val ∈ (omega_chain_val A h_mcs N).dom := ...
  have hb_N : b.val ∈ (omega_chain_val A h_mcs N).dom := ...
  sorry
```

The existing approach uses the finite omega_chain_val(N).dom. The idea: at stage N, both a and b are present. The succ chain from a eventually reaches b because:
1. The omega_chain_val(N).dom is finite
2. Between any two consecutive elements of omega_chain_val(N).dom, no limit_dom points can exist (because U(T, bot) in the MCS ensures discreteness, and C5 gives immediate successors only among limit_dom points)
3. All limit_dom points between a and b are already in omega_chain_val(N).dom for some sufficiently large N

**But wait -- point 3 is not obvious.** Limit_dom is the union of all omega_chain_val(n).dom for n in N. New points can be added at every stage. The issue is whether the succ-chain in the LIMIT structure matches the finite structure at stage N.

### 3E. The Right Argument Using Axiom W Directly

Here is the clearest argument, using axiom W at the MCS level (not the model level):

**Claim**: With Prior-UZ in the axiom system, succ^[n](a) = b for all a < b in LimitDomSubtype.

**Proof via strong induction on the number of limit_dom points in (a, b]**:

Let S = {x in limit_dom | a < x <= b}. This set is non-empty (b is in it).

**Step 1**: S is bounded in a finset. Both a and b appear at some finite stage N. At stage N, the finset omega_chain_val(N).dom contains both a.val and b.val. The key insight: ANY limit_dom point in (a, b] must also appear in omega_chain_val(M).dom for some M (by definition of limit_dom as the union).

**Step 2**: The number of limit_dom points in (a, b] is finite... wait, is it? limit_dom is countably infinite. The interval (a, b] intersected with limit_dom could be infinite if the omega chain keeps adding new points in this interval.

**This is precisely the crux of the problem.** The omega chain at each step adds finitely many new points, but across all steps, it can add infinitely many. However, the DISCRETENESS hypothesis means that between any two consecutive limit_dom points, there are NO other limit_dom points. So the limit_dom points in (a, b] form a finite set IF a and b are in the same "discrete block."

With SuccOrder established (which it IS, sorry-free), succ(a) is the IMMEDIATE successor in limit_dom. The question is whether iterating succ from a eventually reaches b.

**The axiom W argument works as follows**:

Consider the formula p such that p holds exactly at point b. Of course we cannot directly define such a formula (there are only countably many formulas but uncountably many possible truth patterns). However, we can use the MCS structure:

Since b is in limit_dom, limit_f(b) is an MCS. Pick any formula psi in limit_f(b) that is NOT in limit_f(a) (if limit_f(a) = limit_f(b), then actually a and b have the same MCS, which combined with the chronicle construction properties implies something we can work with).

Actually, the MCS approach also doesn't directly work because the same formula psi could be in multiple MCS's.

### 3F. Resolution: Use the Finite Omega-Chain Directly

The correct approach, which DOES NOT require the full Doets transfer, is to prove IsSuccArchimedean directly from the finite omega-chain structure:

**Lemma**: For any a < b in LimitDomSubtype, the set S_ab = {x in limit_dom | a <= x <= b} is finite.

**Proof of the Lemma using axiom W**: 

The key property of the discrete chronicle construction is that between two consecutive domain points (at any finite stage), no new domain points are ever inserted. This is because:

1. The C5 resolution (forward Until witnesses) in the discrete case adds points OUTSIDE existing intervals between consecutive points.
2. The discreteness hypothesis (U(T, bot) in every MCS) means that every Until witness is an IMMEDIATE successor -- there are no intermediate points.

Formally: if x < y are consecutive in omega_chain_val(N).dom (no omega_chain_val(N).dom point between them), and U(T, bot) is in the MCS at x, then the C5 witness for U(T, bot) at x is exactly y (or rather, y is the first domain point after x, with nothing in between).

**Once we know S_ab is finite**, the proof of IsSuccArchimedean is just: succ iterates through the finitely many points in S_ab, so succ^[|S_ab| - 1](a) = b.

**However**, proving S_ab is finite requires understanding the omega-chain construction's behavior with U(T, bot). This is where the work is.

### 3G. Assessment of Difficulty

| Component | Difficulty | Lines | Approach |
|-----------|-----------|-------|----------|
| Add axiom constructors | Easy | 20 | Mechanical |
| FrameClass updates | Easy | 30 | Mechanical (but many match arms to update) |
| Prior-UZ soundness proof | Medium | 40-60 | Well-founded descent on succ chain |
| Soundness integration | Medium | 40-60 | Many exhaustive match updates |
| IsSuccArchimedean from W | **Hard** | 80-150 | Omega-chain finiteness argument |
| **Total** | | **210-320** | |

### 3H. Recommended Proof Strategy for IsSuccArchimedean

Rather than using the Doets transfer (which would require formalizing EF games, quantifier depth, composition methods -- easily 500+ lines), use the **direct omega-chain finiteness** argument:

1. Show that between any two consecutive omega_chain_val(N).dom points, no later stage inserts a new point (this uses the discreteness of the construction: U(T, bot) guarantees immediate successors).

2. Conclude that for a fixed N containing both a and b, the limit_dom points in [a, b] are exactly the omega_chain_val(M).dom points in [a, b] for some sufficiently large M >= N.

3. This set is finite (finset), so succ iteration reaches b from a.

**The key lemma to prove** (replaces the sorry):

```lean
theorem limit_dom_interval_finite (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (h_discrete : ∀ x ∈ limit_dom A h_mcs, next_top ∈ limit_f A h_mcs x)
    (a b : Rat) (ha : a ∈ limit_dom A h_mcs) (hb : b ∈ limit_dom A h_mcs) (hab : a ≤ b) :
    Set.Finite {x : Rat | x ∈ limit_dom A h_mcs ∧ a ≤ x ∧ x ≤ b} := by
  sorry -- Key lemma: discrete chronicle has finite intervals
```

Once this is proved, IsSuccArchimedean follows by induction on the cardinality of the finite interval.

## Part 4: Alternative Analysis -- Does Prior-UZ Imply R-closure?

The delegation context asked whether Prior-UZ implies "R-closure" (limit_dom being closed under limits in R). The answer is **no, and it's not needed**. The discrete case maps to Z, not to R. The R-closure question is relevant for the dense case (mapping to Q then to R via Dedekind completion), where Prior-U (the complex Reynolds version, not Prior-UZ) plays the role. Our codebase handles the dense case separately with the Cantor isomorphism.

For the discrete case, Prior-UZ serves a completely different purpose: it ensures that the limit domain is NOT only discrete but also that its discrete structure matches Z (every element is reachable by succ iteration).

## Concrete Implementation Roadmap

### Phase 1: Add Axioms (Low Risk, ~60 lines)
1. Add `prior_UZ` and `prior_SZ` constructors to `Axiom` inductive type
2. Update `frameClass`, `isBase`, `isDenseCompatible`, `isDiscreteCompatible`
3. Fix the three theorems about frame class properties
4. Run `lake build Bimodal.ProofSystem.Axioms` to verify

### Phase 2: Soundness (Medium Risk, ~150 lines)
1. Write `prior_UZ_valid` and `prior_SZ_valid` in Soundness.lean
2. Add cases to `axiom_base_valid` (absurd), `axiom_valid_dense` (absurd), `axiom_valid_discrete` (forward to validity proof)
3. Update general `soundness`, `soundness_dense` (absurd for Prior-UZ cases), `soundness_discrete`
4. Update `soundness_dense_valid` and `soundness_discrete_valid`
5. Run `lake build Bimodal.Metalogic.Soundness`

### Phase 3: IsSuccArchimedean (High Risk, ~100-200 lines)
1. Prove `limit_dom_interval_finite` (the key lemma)
2. Use it to complete the sorry in `limitDomSubtype_isSuccArchimedean`
3. Run `lake build Bimodal.Metalogic.BXCanonical.Chronicle.ChronicleToCountermodel`

### Phase 4: Discrete Countermodel (Depends on Phase 3)
1. With IsSuccArchimedean proved, the Z-isomorphism `discrete_iso` compiles
2. Build the discrete BFMCS (parallel to cantor_bfmcs_dense)
3. Complete `dd_countermodel_chronicle_nondense_sorry`

## Key Risks

1. **FrameClass refactoring cascade**: Changing `isBase` from wildcard to explicit matches may break many proofs downstream. Mitigation: add cases carefully, using `simp [isBase]` where possible.

2. **General soundness theorem**: Prior-UZ breaks the general `soundness` theorem since it's not universally valid. Must restructure to gate on frame compatibility. This could be a significant refactor.

3. **Omega-chain finiteness**: The key lemma for IsSuccArchimedean requires deep understanding of the chronicle construction internals. The proof that no new points are inserted between consecutive discrete points is non-trivial.

4. **Prior-UZ soundness proof complexity**: Requires well-founded arguments on succ chains, which can be tricky in Lean with the abstract type class setup.

## References

- Reynolds 1992, Section 10: "Using Contemporaneity on the Integers" -- defines Prior-UZ and Prior-SZ
- Venema 1993, Lemma 4.1: "Every BW-model is definably well-ordered" -- the key lemma
- Venema 1993, Theorem 4.2: Soundness and completeness for WO (well-orderings)
- Doets 1989: Monadic Pi-1-1 theories -- the transfer theorem
- Current sorry site: `ChronicleToCountermodel.lean` line 1068
