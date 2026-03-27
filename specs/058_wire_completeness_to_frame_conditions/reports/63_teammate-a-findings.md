# Research Report: Task #58 - Proof-Theoretic Cut Lemma Machinery

**Task**: 58 - wire_completeness_to_frame_conditions
**Focus**: Proof-theoretic cut lemma for BRS-containing derivations
**Date**: 2026-03-27
**Agent**: logic-research-agent (teammate A)

---

## Key Findings

### Finding 1: The Correct Proof Strategy is "Cut by Classical Case Analysis"

The deduction theorem approach alone cannot solve the problem because it produces `L' ⊢ psi.neg`, not `L' ⊢ bot`. The correct approach requires a classical case analysis pattern that the proof system already supports.

The key insight: for each BRS element `psi` in `L`, use the deferral disjunction `psi ∨ F(psi)` that is already in `u`. Since `F(psi) ∈ u` and `F(psi) ∈ u` implies `u ⊢ F(psi)`, and since `psi ∨ F(psi)` is in `u`, we can do case analysis.

However the most direct path avoids this entirely: **we already have `psi.neg ∈ u` by DRM maximality**. The correct transformation is:

Given `L ⊢ bot` where `L = L_u ∪ {psi}` (with `psi ∉ u`, hence `psi ∈ BRS`, hence `psi.neg ∈ u`):

1. By deduction theorem: `L_u ⊢ psi.neg` (i.e., `L_u ⊢ psi → bot`)
2. Since `psi.neg ∈ u`, we have `psi.neg ∈ u`
3. `L_u ⊆ u` (induction hypothesis)
4. Combine `L_u ⊢ psi.neg` and the fact that `psi.neg ∈ u` and `psi.neg` is derivable from `L_u ⊆ u` - here the issue is we want `L_u' ⊢ bot` for some `L_u' ⊆ u`

**The actual gap**: `L_u ⊢ psi.neg` does not give `L_u ⊢ bot`. We need a different mechanism.

### Finding 2: The Correct Cut Mechanism - Reusing the Derivation

The real cut-style argument uses the following pattern already present in `SetMaximalConsistent.closed_under_derivation` and `drm_closed_under_derivation`:

**Pattern**: To show `Γ ⊢ bot` from `Γ, A ⊢ bot` when `Γ ⊢ neg A`:
1. We have `Γ, A ⊢ bot`
2. By deduction theorem: `Γ ⊢ neg A`
3. If we ALSO separately know `Γ ⊢ A` (from somewhere), then `Γ ⊢ bot` by `derives_bot_from_phi_neg_phi`

But in our case, we DON'T have `Γ ⊢ psi` from `Γ ⊆ u`. We have `psi ∈ L` (in the original context), but `psi ∉ u`.

**The correct cut lemma** needed is the classical tautology:
```
⊢ (A → ⊥) → (¬A → ⊥) → ⊥
```
Which simplifies to: if we can derive `bot` from `A` AND from `¬A`, then we can derive `bot`.

This is exactly `classical_merge` applied with `Q = bot`:
```
classical_merge A bot : ⊢ (A → ⊥) → (¬A → ⊥) → ⊥
```

The proof strategy then becomes:
1. From `L ⊢ bot` where `psi ∈ L`: by deduction theorem, `L_rest ⊢ psi → bot` (i.e., `L_rest ⊢ psi.neg`)
2. Since `psi.neg ∈ u`: we need `L_rest ⊢ psi.neg → bot` (i.e., `L_rest ⊢ psi.neg.neg`) - but this requires `psi ∈ L_rest` which we may not have
3. This fails unless we apply classical_merge differently

**The actual correct approach**: Strong induction on the number of BRS elements. The base case (all elements in u) is immediate. The inductive step is:

Given `L ⊢ bot` with `psi ∈ L` where `psi ∉ u`:
- `psi.neg ∈ u` (by DRM maximality)
- Consider `L' = (L.erase psi) ++ [psi.neg]` - this list has ONE FEWER element not in `u`
- Show `L' ⊢ bot`

To show `L' ⊢ bot`:
- From `L = L_rest ++ [psi] ⊢ bot`: deduction theorem gives `L_rest ⊢ psi.neg`
- From `L' = L_rest ++ [psi.neg]`: assumption gives `L' ⊢ psi.neg`
- We need `L' ⊢ psi.neg.neg` to derive `bot` via `derives_bot_from_phi_neg_phi`
- But `psi.neg.neg` is NOT the same as `psi` in this system (no definitional double-neg elim)

This approach also fails.

### Finding 3: The Semantic Consistency Argument is the Right Path

After examining all proof-theoretic approaches, the fundamental obstacle is:

**Core issue**: In a Hilbert system, "no contradictory pairs" does NOT syntactically imply consistency. A set can contain formulas `{A, B, C, D}` where none are negations of each other, yet `{A, B, C, D} ⊢ bot` through a chain of implications. Only semantically satisfiable sets are guaranteed consistent.

This is why the standard completeness proof literature (Fitting, Blackburn, de Rijke) uses semantic arguments for MCS construction consistency. The typical approach:

1. The seed is satisfiable (there exists a world in the canonical model satisfying it)
2. Satisfiable sets are consistent (by soundness)
3. Therefore the seed is consistent

### Finding 4: There IS a Valid Proof-Theoretic Approach - Through DRM Closure

Examining `drm_closed_under_derivation` carefully reveals a viable path:

**Key observation**: The DRM `u` is itself consistent (`h_mcs.1.2`). The non-BRS part of the seed is `⊆ u`. The BRS part satisfies: for each `psi ∈ BRS`, `psi.neg ∈ u` and `psi` is NOT in `u`.

**Viable approach**: Prove `SetConsistent (seed)` by contradiction using `drm_closed_under_derivation`.

Assume `L ⊆ seed` with `L ⊢ bot`. Partition `L = L_u ∪ L_brs` where:
- `L_u ⊆ u` (non-BRS elements)
- `L_brs = {psi_1, ..., psi_k}` (BRS elements, each with `psi_i.neg ∈ u`)

Apply deduction theorem iteratively:
- `L_u ∪ {psi_1, ..., psi_k} ⊢ bot`
- `L_u ∪ {psi_1, ..., psi_{k-1}} ⊢ psi_k.neg`

Now `psi_k.neg ∈ deferralClosure` (since `psi_k ∈ BRS` implies `F(psi_k) ∈ u ⊆ deferralClosure`, so `psi_k ∈ subformulaClosure ⊆ closureWithNeg`, so `psi_k.neg ∈ closureWithNeg ⊆ deferralClosure`).

By `drm_closed_under_derivation h_mcs (L_u ∪ {psi_1,...,psi_{k-1}}) ⊢ psi_k.neg`:
Wait - this requires `L_u ∪ {psi_1,...,psi_{k-1}} ⊆ u`, which requires induction.

**The correct inductive argument**:

Claim: For any `k`, if `L_u ⊆ u` and `L_brs = {psi_1,...,psi_k}` each in BRS (so `psi_i.neg ∈ u`), and `L_u ∪ L_brs ⊢ bot`, then `L_u' ⊢ bot` for some `L_u' ⊆ u`.

Base `k = 0`: `L_u ⊆ u` and `L_u ⊢ bot`, contradicts `u` consistent. Done.

Step `k > 0`: `L_u ∪ {psi_1,...,psi_k} ⊢ bot`. By deduction theorem: `L_u ∪ {psi_1,...,psi_{k-1}} ⊢ psi_k.neg`. Now apply IH with `L_u' = L_u ∪ [psi_k.neg]` (since `psi_k.neg ∈ u`) and `L_brs' = {psi_1,...,psi_{k-1}}`. But we need `L_u' ∪ L_brs' ⊢ bot` (not `⊢ psi_k.neg`).

**This still fails** - the deduction theorem gives us `psi_k.neg` as a conclusion, not `bot`.

### Finding 5: The Classical Cut Lemma That Works

After careful analysis, the correct proof-theoretic tool needed is:

**Classical Cut (Case Analysis on A)**:
```
If Γ, A ⊢ C  and  Γ ⊢ A.neg  then  Γ ⊢ C
```

Proof in our system: This follows directly from modus_ponens since `A.neg = A.imp bot`, so `Γ ⊢ A.neg` and `Γ, A ⊢ C` gives (by deduction theorem) `Γ ⊢ A.imp C`, but we have `Γ ⊢ A.neg = A.imp bot`... and `bot → C` by EFQ. So:
1. `Γ ⊢ A.imp bot` (given)
2. `Γ ⊢ A.imp C` (from deduction theorem on `Γ, A ⊢ C`)
- This gives nothing new

**What actually works - the Full Cut**:

What we need is: if `Γ, A ⊢ bot` AND `Γ, A.neg ⊢ bot`, THEN `Γ ⊢ bot`. This is the "proof by cases on A":

```lean
-- classical case split (key lemma needed):
-- If [A] ++ Gamma ⊢ bot  and  [A.neg] ++ Gamma ⊢ bot  then  Gamma ⊢ bot
def proof_by_cases (Γ : Context) (A : Formula)
    (h1 : (A :: Γ) ⊢ Formula.bot)
    (h2 : (A.neg :: Γ) ⊢ Formula.bot) :
    Γ ⊢ Formula.bot
```

This follows from `classical_merge` and `lem`:
1. By deduction theorem from `h1`: `Γ ⊢ A.neg`
2. By deduction theorem from `h2`: `Γ ⊢ A.neg.neg`  (since `A.neg.neg = A.neg.imp bot`)

Wait, deduction theorem on `h2 : A.neg :: Γ ⊢ bot` gives `Γ ⊢ A.neg.imp bot = A.neg.neg`.

Then from `Γ ⊢ A.neg` and `Γ ⊢ A.neg.neg`: contradiction by `derives_bot_from_phi_neg_phi`.

**This IS the correct proof-by-cases for our setting**:

If `A :: Γ ⊢ bot` and `A.neg :: Γ ⊢ bot`, then:
1. `Γ ⊢ A.neg` (by deduction theorem on h1)
2. `Γ ⊢ A.neg.neg` (by deduction theorem on h2)
3. `Γ ⊢ bot` (by `derives_bot_from_phi_neg_phi Γ A.neg`)

This "proof by cases on A" is the cut lemma we need.

### Finding 6: Applying the Cut Lemma to Our Problem

Now apply this recursively. Let `L = L_u ++ L_brs` where `L_u ⊆ u` and `L_brs` has BRS elements with negations in `u`.

**Claim**: `L ⊢ bot` implies contradiction with `u` consistent.

**Proof by strong induction on `|L_brs|`**:

Base case (`|L_brs| = 0`): `L = L_u ⊆ u`, contradicts `u` consistent.

Inductive case (`|L_brs| = k+1`): Let `psi ∈ L_brs`. We have `psi ∉ u`, so `psi.neg ∈ u` (by DRM maximality).

Consider two sub-cases:
- Sub-case A: `psi ∈ L_u` (i.e., psi actually appears as a hypothesis from u also)
  - Then we have both `psi ∈ L_u ⊆ u` and `psi ∉ u` - contradiction. So this sub-case can't arise.

- Sub-case B: `psi ∉ L_u` (the typical case)
  - `L = L_u ++ [psi] ++ L_brs'` (where `L_brs' = L_brs.erase psi`)
  - We have `L ⊢ bot`
  - By deduction theorem: `L_u ++ L_brs' ⊢ psi.neg`
  - We also have `psi.neg ∈ u`
  - Construct `L'' = L_u ++ [psi.neg] ++ L_brs'`
  - Note: `psi.neg ∈ u` so `L'' = L_u' ++ L_brs'` where `L_u' = L_u ++ [psi.neg] ⊆ u`
  - **Need**: `L'' ⊢ bot`

Still stuck! We have `L_u ++ L_brs' ⊢ psi.neg` but not `L'' = L_u ++ [psi.neg] ++ L_brs' ⊢ bot`.

### Finding 7: The Fundamental Impossibility of Pure Proof-Theoretic Argument

After exhaustive analysis, the proof-theoretic approach has a fundamental gap: at each step of the induction, we reduce the number of non-u elements but we lose `⊢ bot` - we only get `⊢ psi.neg` as the derived conclusion.

**What can be proven purely proof-theoretically**:
- That `L ⊢ bot` implies `L_u ⊢ (psi_1.neg ∧ ... ∧ psi_k.neg)` for the k BRS elements (iterated deduction theorem)
- That each `psi_i.neg ∈ u` (by DRM maximality)
- That `L_u ∪ {psi_i.neg : i = 1..k} ⊆ u` (all elements now in u)

**What cannot be proven without more structure**:
- That `L_u ∪ {psi_i.neg} ⊢ bot`

The derivation `L ⊢ bot` depends on the SPECIFIC WAY `psi_i` was used. After replacing `psi_i` with `psi_i.neg`, the derivation may no longer lead to `bot` because `psi_i` and `psi_i.neg` have opposite "logical roles."

### Finding 8: The Semantic Path is Both Correct and Already Available

The semantic approach is not circular if done correctly:

**Key**: The proof system is SOUND for TM semantics. If a set is satisfiable (semantically consistent), it is proof-theoretically consistent.

For the seed `constrained_successor_seed_restricted phi u`:
- Non-BRS elements `⊆ u`, a DRM world
- BRS elements `psi` have `F(psi) ∈ u` (a current world `u` has a future with `psi`)
- `u` itself witnesses that there is a world satisfying the non-BRS elements
- The NEXT world (successor) should satisfy `psi` (since `F(psi) ∈ u`)

So the seed is semantically satisfiable (by the intended successor world), hence consistent by soundness.

**However**: This requires constructing the successor world first, which is circular in the completeness proof.

---

## Recommended Approach

### Primary Recommendation: Two-Phase Argument

The cleanest proof path that avoids circularity is:

**Phase A**: Establish a "derivation replacement lemma":
```
replace_brs_lemma: For any L ⊆ seed with L ⊢ bot,
  letting L_u = L ∩ u and L_brs = L \ u (which are all in BRS),
  there exists L_extra ⊆ u such that L_u ++ L_extra ⊢ bot
```

This requires showing that we can "witness" the BRS elements using their deferral disjunctions in `u`. Specifically, for `psi ∈ BRS`:
- `psi ∨ F(psi) ∈ u` (in `deferralDisjunctions`)
- `F(psi) ∈ u` (BRS first condition)
- From `F(psi) ∈ u` and `psi ∨ F(psi) ∈ u`: disjunction is trivially "witnessed" by the right disjunct
- So `u ⊢ F(psi)` (trivially, `F(psi) ∈ u`)

The key step: if we have `L_u ++ [psi] ⊢ bot`, we want `L_u ++ [something_in_u] ⊢ bot`.

**This requires**: Either `L_u ⊢ psi` (so we can drop it), or some "substitution in derivation" operation.

If `L_u ⊢ psi` then `L_u ⊢ bot` by modus ponens with `L_u ⊢ psi.neg` (from deduction theorem). But `psi.neg ∈ u` and `psi ∉ u` - so we'd need to know if `L_u ⊢ psi.neg` also holds, which it does by `drm_closed_under_derivation` applied to `L_u ⊆ u` deriving `psi.neg ∈ deferralClosure`.

Wait - this only works if `L_u ⊢ psi.neg` from first principles. We don't know `L_u ⊢ psi.neg` unless we can derive it.

**Simplest viable approach**: Use `drm_closed_under_derivation` to show that if `L_u ⊢ psi.neg`, then since `psi.neg ∈ deferralClosure`, we get `psi.neg ∈ u`. But we still need `L_u ⊢ psi.neg` to come from somewhere, not be assumed.

### Secondary Recommendation: Direct Proof via Classical Cut + DRM Consistency

**The actual viable proof**:

Given `L ⊆ seed` with `L ⊢ bot`, we prove `False` as follows.

Let `L_brs = L.filter (fun x => x ∉ u)` (all BRS elements in L).

We prove by induction on `L_brs.length`:

For each `psi ∈ L_brs`, since `psi ∉ u` and `psi ∈ BRS`, by DRM maximality `psi.neg ∈ u`.

Now apply the following lemma (which IS provable from the proof system):

```
cut_with_consistent_neg (key lemma):
  If u is DRM-consistent, L ⊆ seed, psi ∈ L, psi ∉ u, psi.neg ∈ u,
  and L ⊢ bot, then (L.erase psi) ++ (L_u_neg_psi) ⊢ bot for some L_u_neg_psi ⊆ u
```

But this is exactly what we can't prove without more.

**ACTUAL VIABLE PROOF** (after full analysis):

The correct insight comes from the `SetMaximalConsistent.closed_under_derivation` proof technique. That proof shows: if `S` is MCS, `L ⊆ insert φ S`, and `L ⊢ bot`, then either:
- `φ ∉ L`: then `L ⊆ S`, contradicts `S` consistent
- `φ ∈ L`: use deduction theorem, filter out `φ`, show `L_filt ⊆ S` derives `φ.neg`, combine with `S`-derivation of `φ`... wait this is the SAME pattern.

The proof in `closed_under_derivation` works because `φ` is BEING PROVED: `L ⊢ φ` is known, so `φ` and `φ.neg` both derivable from `S`, giving inconsistency.

**For our problem, we need to produce a `φ` and `φ.neg` both derivable from `u`**.

After all this analysis: the proof likely requires showing that the deferral disjunction `psi ∨ F(psi) ∈ u` combined with `F(psi) ∈ u` and the derivation `L ⊢ bot` can be used to produce a contradictory derivation from `u`.

Specifically:
1. `L ⊢ bot` with `psi ∈ L` (BRS element)
2. Deduction theorem: `L_rest ⊢ psi.neg`  (where `L_rest = L.erase psi`)
3. `L_rest ⊆ seed`; all non-BRS elements of `L_rest` are in `u`
4. **Key**: `psi ∨ F(psi) ∈ u` (deferral disjunction), so the seed already contains a "reason" why `psi` is resolvable

Now if we have `L_rest' ⊆ u` (after replacing BRS elements with their u-witnesses) such that `L_rest' ⊢ psi.neg`, then since `psi.neg ∈ deferralClosure`:
- `drm_closed_under_derivation h_mcs L_rest' h_sub h_deriv h_dc` gives `psi.neg ∈ u`
- But `psi.neg ∈ u` is already known from DRM maximality!

This is not a contradiction. We need `u ⊢ bot` to contradict `u` consistent.

---

## The Cleanest Proof Path (Final Assessment)

After thorough analysis, the cleanest proof that avoids all these loops is:

**Show directly that the seed ⊆ deferralClosure implies satisfiability via the canonical model construction, then use soundness.**

Alternatively, the proof can be restructured:

### Restructured Approach: Don't Prove Seed Consistency Directly

Instead of proving `SetConsistent (seed)` directly, prove it indirectly via Lindenbaum:

1. The seed is closed-restricted (all elements in `deferralClosure phi`) - this should be provable
2. The seed is "BRS-safely structured": we have `neg_not_in_seed_when_in_brs` ensuring no `{psi, psi.neg}` pairs
3. For single BRS elements `{psi}`: `{psi}` is consistent (since `psi ∈ deferralClosure` and we can extend it)
4. The non-BRS part `{non_BRS}` is consistent since `⊆ u`
5. **The join** `{non_BRS} ∪ {BRS}` may still be inconsistent via complex derivation

The "no contradictory pairs" argument cannot prove consistency in Hilbert systems without decidability or model theory.

### The Actual Recommendation

**Use `drm_restricted_lindenbaum` to bypass the consistency check**: Instead of proving the seed is consistent, prove it is "restrictedly consistent" (has no proof of bot from any finite subset within deferralClosure). This may have better proof-theoretic content because:
- The seed ⊆ deferralClosure (provable structurally)
- `deferral_restricted_lindenbaum` (already exists) can extend any restricted-consistent set

The key lemma needed:

```lean
-- Main missing lemma
lemma seed_restricted_consistent :
    ∀ L : List Formula,
    (∀ phi ∈ L, phi ∈ constrained_successor_seed_restricted phi u) →
    Consistent L
```

This requires either:
1. A "substitution in derivations" theorem showing BRS elements can be replaced
2. A semantic satisfiability argument
3. The "proof by cases on LEM" used to show every derivation from the seed can be "traced back" to u

---

## Evidence/Examples

### Example 1: Why Deduction Theorem Alone Fails

Suppose `L = {A, B, C}` with:
- `A ∈ u`, `B ∈ u`, `C ∉ u` (BRS element)
- `{A, B, C} ⊢ bot`

Deduction theorem gives: `{A, B} ⊢ C.neg` (i.e., `C → bot`).

Now, we want `L' ⊆ u` with `L' ⊢ bot`. We have `C.neg ∈ u` (DRM maximality).

`{A, B, C.neg} ⊆ u` and `{A, B} ⊢ C.neg`. But does `{A, B, C.neg} ⊢ bot`? Only if `{A, B} ⊢ C.neg` was itself a contradiction, i.e., if `{A, B, C.neg} ⊢ bot`. But `{A, B, C.neg} ⊆ u` is consistent (u is consistent)!

So the approach fails: the original derivation `{A, B, C} ⊢ bot` used `C` in an essential way that cannot be replicated with `C.neg`.

### Example 2: The Classical Cut That Works (When Both Branches Available)

```lean
-- Available in the proof system via classical_merge
-- ⊢ (A → ⊥) → (¬A → ⊥) → ⊥
-- Equivalently: if A :: Γ ⊢ ⊥ and A.neg :: Γ ⊢ ⊥, then Γ ⊢ ⊥
```

This works when we have BOTH branches. In the BRS case:
- Branch 1 (`psi ∈ L`): `L ⊢ bot` (assumed)
- Branch 2 (`psi ∉ L`): We'd need `L_with_neg_psi ⊢ bot` (not given)

The classical cut works in `closed_under_derivation` because the MCS has `S ⊢ phi` (from the derivation being proven), providing both `phi` and `phi.neg` derivable.

### Example 3: Lean Sketch of the Proof-by-Cases Lemma

```lean
-- This IS derivable and available in the system
noncomputable def proof_by_cases_bot (Γ : Context) (A : Formula)
    (h1 : (A :: Γ) ⊢ Formula.bot)
    (h2 : (A.neg :: Γ) ⊢ Formula.bot) :
    Γ ⊢ Formula.bot := by
  -- From h1: deduction theorem gives Γ ⊢ A.neg
  have d_neg_A : Γ ⊢ A.neg :=
    deduction_theorem Γ A Formula.bot h1
  -- From h2: deduction theorem gives Γ ⊢ A.neg.neg
  have d_neg_neg_A : Γ ⊢ A.neg.neg :=
    deduction_theorem Γ A.neg Formula.bot h2
  -- Both A.neg and A.neg.neg are derivable: contradiction
  exact derives_bot_from_phi_neg_phi d_neg_A d_neg_neg_A
```

This lemma IS provable. But using it in the BRS setting requires having `h2 : A.neg :: Γ ⊢ bot`, which we don't have.

### Example 4: Sketch of the Alternative via Derivation Replacement

A "cut admissibility" style argument would need:

```lean
-- Hypothetical "cut_with_proven" lemma (not in codebase)
-- If Γ ⊢ A (we can derive A) and Γ, A ⊢ C then Γ ⊢ C
def cut_with_proven (Γ : Context) (A C : Formula)
    (h_A : Γ ⊢ A) (h_AC : (A :: Γ) ⊢ C) : Γ ⊢ C := by
  have d_imp : Γ ⊢ A.imp C := deduction_theorem Γ A C h_AC
  exact DerivationTree.modus_ponens Γ A C d_imp h_A
```

This is trivially provable via modus ponens after deduction theorem. It says: if you can already derive A, then having A as a hypothesis is redundant. This IS the key lemma for our setting IF we can show `u ⊢ psi` for BRS elements.

But `psi ∉ u` and `psi.neg ∈ u`, so `u ⊢ psi` is impossible (u is consistent).

---

## Confidence Level

**Overall**: Medium-High confidence in the diagnosis, lower confidence in finding a clean proof.

### Diagnosis (High confidence)
- Pure "no contradictory pairs" arguments cannot prove consistency in Hilbert systems
- The deduction theorem approach produces implications, not ⊥
- The correct proof requires semantic satisfiability or a structural argument specific to the seed

### Recommended Proof Structure (Medium confidence)
The most promising approach is to reformulate the problem:

**Recommendation**: Prove that the seed has a "BRS-completion" that is DRM-consistent, by showing that replacing each BRS element `psi` with its negation `psi.neg` (which IS in u) gives a set `seed'` that:
1. `seed' ⊆ u` (all replacements land in u)
2. For any `L ⊆ seed` with `L ⊢ bot`, the corresponding `L' ⊆ seed'` also derives `bot` (via some cut principle)
3. But `L' ⊆ u` and `u` is consistent - contradiction

Step 2 requires the "derivation replacement" principle, which requires showing that the BRS element `psi` and its replacement `psi.neg` are used in a "swap-compatible" way. This may require showing that in ANY derivation from the seed of `bot`, the BRS elements `psi_i` appear ONLY as assumptions that are "discharged" via modus ponens with `psi_i → something`, and that switching to `psi_i.neg` propagates the contradiction to u.

**Most likely correct path**: This is genuinely hard to prove proof-theoretically and the literature's standard approach is semantic. The recommendation is to use a semantic argument combined with soundness, or to establish a specialized "BRS consistency" lemma via model-theoretic reasoning about the intended canonical successor world.

### Alternative Paths (Low-Medium confidence)
1. **Structural induction on derivation depth** with careful tracking of how BRS elements appear: complex but potentially viable
2. **Direct semantic argument**: Cleaner but requires more infrastructure
3. **Reformulation**: Avoid proving seed consistency directly; instead, show the Lindenbaum extension exists first and then derive the seed properties

---

## Appendix

### Available Proof System Tools

Key lemmas available in the codebase for this proof:

| Lemma | Location | Purpose |
|-------|----------|---------|
| `deduction_theorem` | Core/DeductionTheorem.lean | `A :: Γ ⊢ B` implies `Γ ⊢ A → B` |
| `derives_bot_from_phi_neg_phi` | Core/MaximalConsistent.lean | `Γ ⊢ A` and `Γ ⊢ A.neg` gives `Γ ⊢ bot` |
| `drm_closed_under_derivation` | Core/RestrictedMCS.lean | DRM closed under derivation for dc-formulas |
| `deferral_restricted_mcs_negation_complete` | Core/RestrictedMCS.lean | DRM: `psi ∈ sub → psi ∈ u ∨ psi.neg ∈ u` |
| `neg_not_in_seed_when_in_brs` | Bundle/SuccChainFMCS.lean | `psi ∈ BRS → psi.neg ∉ seed` |
| `brs_mutual_exclusion` | Bundle/SuccChainFMCS.lean | `psi ∈ BRS → psi.neg ∉ BRS` |
| `classical_merge` | Theorems/Propositional.lean | `⊢ (A → C) → ((¬A → C) → C)` |
| `de` | Theorems/Propositional.lean | Disjunction elimination |

### Missing Lemmas That Would Complete the Proof

1. **`derivation_cut_admissibility`**: If `Γ ⊢ A` and `A :: Γ ⊢ bot`, then `Γ ⊢ bot` (trivially via modus ponens - this EXISTS)
2. **`brs_element_derivable_from_u`**: This would say `u ⊢ psi` for BRS elements. This is FALSE (psi ∉ u).
3. **`seed_semantically_satisfiable`**: The seed has a model. This requires the successor world construction (circular in completeness proof).
4. **`no_cross_contradictions_implies_consistent`**: False in general for Hilbert systems.

### References

- Fitting, M. (1993). "Basic Modal Logic." Chapter on Canonical Models.
- Blackburn, de Rijke, Venema (2001). "Modal Logic." §4.2 on canonical model construction.
- Boolos (1993). "The Logic of Provability." On MCS construction.
- The standard pattern: prove seed satisfiable (semantic), then consistent (by soundness).
