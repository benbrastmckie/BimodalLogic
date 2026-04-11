# Teammate B Findings: Alternative Approaches to Closing the 6 Sorry Locations

- **Task**: 98 — Research filtration / quasimodel pivot for Until/Since truth lemma
- **Angle**: Alternative approaches — restructuring, empty-interval tricks, bx_le redefinition, direct Until propagation, published strategies
- **Artifact number**: 02b
- **Date**: 2026-04-10

---

## Key Findings

### 1. Published Proof Strategy Analysis: What Burgess/Reynolds Actually Do

**Burgess 1984** proves completeness for tense logic of linear time using an
*Until-induction axiom*: `(ψ ∨ (φ ∧ X(θ)) → θ) → (φ U ψ → θ)`, where X is the
next-step operator. This axiom is sound only over *discrete* linear orders (Z or N), not
over dense or continuous orders. The BX refactoring deliberately removed Until-induction
because TM targets general linear orders (including the reals). Burgess's technique does
not apply here as-is.

**Reynolds 1996** (*Axiomatising first-order temporal logic: Until and since over linear
time*, Studia Logica) handles completeness via a *separation argument*: every formula is
equivalent to a Boolean combination of "pure future" and "pure past" subformulas. This
changes the inductive structure of the truth lemma entirely — the canonical model proof
never needs to propagate Until across `bx_le` because the formula is first simplified to
one that does not require it. This technique requires the full apparatus of Kamp's
theorem and is not easily retrofitted to the current BX Lean proof structure.

**Verbrugge 2007** (*Completeness by construction for tense logics of linear time*)
uses a *constructive* chain approach in the spirit of Burgess: the canonical model is
built as an explicit ω-sequence (or ω × ω-sequence for the full language), not as an
abstract set of all MCSes with `g_content ⊆` ordering. Until persistence along the
chain is built into the *construction rule* for generating each next MCS from the
previous one (using an X-like step function). There is no abstract `bx_le` relation
at all in that framework.

**Conclusion**: All three published sources achieve the Until truth lemma by a route
that *avoids* the `g_content ⊆` ordering altogether. None of them prove `φ ∈ u` given
`bx_le u' u` and `φ ∈ u'` — they never face this step because their canonical models
have explicit next-step links, not abstract set-inclusion ordering.

The core obstruction is structural: the `bx_le := g_content ⊆` ordering was chosen
specifically to make the G/H truth lemmas easy, but it creates a one-way propagation
wall for non-G-wrapped formulas. Fixing this within the current framework requires one
of the four approaches analyzed below.

---

### 2. Approach Analysis: Proof Restructuring to Avoid Guard-Lifting

**Can we choose a different witness `v` that makes the guard vacuously true?**

The guard is `∀ u, bx_le w u → bx_le u v ∧ ¬bx_le v u → φ ∈ u`. If we could find a
`v` with `bx_le w v` and `ψ ∈ v` such that no `u` with `bx_le w u ∧ bx_le u v ∧
¬bx_le v u` exists, the guard would be vacuously true. This is the *minimal witness*
strategy.

**Problem with minimality**: A "minimal" `v` among all BXPoints with `bx_le w v` and
`ψ ∈ v` would give a vacuous guard only if there is literally no point strictly between
`w` and `v` in the `bx_le` pre-order. However:

1. `bx_le` is not a total pre-order, so "minimal" is not well-defined in general (there
   may be incomparable elements below `v`).
2. Zorn's lemma (or its dual for minimal elements) gives a `bx_le`-minimal element in
   the *downward closure* of the witnesses, but minimality in a partial order does not
   imply there is no element strictly below.
3. Even if we could extract a minimal future witness `v` using BX7 + BX11, the
   minimality would be among formula-level witnesses (F-content), not among BXPoint
   pairs. The Realization.lean comments (line 48–51) confirm that BX7 is
   "formula-level linearity on Until resolution inside one MCS" and "does not deliver a
   BXPoint-level minimum selector."

**Verdict**: Proof restructuring via minimal-witness selection is **not viable** in the
current MCS-level framework. BX7 and BX11 cannot be promoted from formula-level to
BXPoint-level ordering.

---

### 3. Approach Analysis: Empty-Interval Trick via BX10 + BX11

**Idea**: If we can show `bx_le w v` where there exists no `u` with `bx_le w u ∧
bx_le u v ∧ ¬bx_le v u` (i.e., the interval is empty), the guard is vacuously true.

**Formal setup**: From `φ U ψ ∈ w` and `h_not_psi : ψ ∉ w`:
- BX10: `F(ψ) ∈ w`. Use `bx_forward_witness` to get `v` with `bx_le w v` and `ψ ∈ v`.
- BX11: `F(ψ) ∧ F(χ)` at `w` gives one of three F-disjuncts. But the "three disjuncts"
  of BX11 give an existential F-witness that is *jointly reachable* — they say nothing
  about whether the interval between `w` and the selected `v` is empty.

**Why this fails**: The only way to guarantee an empty interval is to show that `v`
is `bx_le`-immediate above `w` (a successor in the partial order). In a dense order
(the intended frame class includes ℝ and ℚ), no successor exists. Even in the general
MCS pre-order, BX lacks any successor axiom. The axiom BX12 (`F(φ) → ⊤ U φ`) connects
F to Until at the *formula* level but does not make BXPoint intervals empty.

**Verdict**: The empty-interval trick is **not applicable** without a successor axiom,
and adding one would restrict the frame class to discrete orders, contradicting TM's
intent.

---

### 4. Approach Analysis: Redefining bx_le

The Realization.lean docstring (lines 52–59) lists "Restructured canonical model: Define
`bx_le` differently (e.g., using Until-witness ordering)" as option 3 for closing the
sorries. Here is a concrete analysis.

**Layered definition proposal** (from Task 92 spawn analysis Task 2):
```
bx_le' w v := g_content(w) ⊆ v.formulas ∧ until_compatible w v
```
where `until_compatible w v` means: `∀ φ ψ, (φ U ψ) ∈ w.formulas → (φ U ψ) ∈ v.formulas ∨ ψ ∈ v.formulas`.

**Analysis of `until_compatible`**:

1. **Reflexivity**: `bx_le' w w` holds iff `until_compatible w w` holds.
   `until_compatible w w` means `(φ U ψ) ∈ w → (φ U ψ) ∈ w ∨ ψ ∈ w`. This is trivially
   true. So `bx_le'` remains reflexive. ✓

2. **Transitivity**: `bx_le' w u ∧ bx_le' u v → bx_le' w v`.
   - `g_content(w) ⊆ u ∧ g_content(u) ⊆ v` gives `g_content(w) ⊆ v` by existing
     transitivity (temp_4). ✓
   - For `until_compatible w v`: given `(φ U ψ) ∈ w`, we need `(φ U ψ) ∈ v ∨ ψ ∈ v`.
     From `until_compatible w u`: `(φ U ψ) ∈ u ∨ ψ ∈ u`.
     - Case `ψ ∈ u`: from BX4', `H(F(ψ)) ∈ u`, and from `g_content(u) ⊆ v`... wait,
       `H(F(ψ))` is NOT of the form `G(χ)`, so it does NOT propagate via `g_content`.
       We cannot derive `ψ ∈ v ∨ (φ U ψ) ∈ v` from `ψ ∈ u` and `bx_le u v`.
     - Case `(φ U ψ) ∈ u`: from `until_compatible u v`: `(φ U ψ) ∈ v ∨ ψ ∈ v`. ✓
   - **Transitivity fails in the `ψ ∈ u` case**. To fix this, we would need
     `until_compatible` to also propagate `ψ` forward — but `ψ` can be any formula,
     including an atom, so propagating all formulas forward would make `bx_le'` total,
     which contradicts MCS independence.

3. **Breaks G/H truth lemmas?**: `bx_G_forward` uses only `g_content(w) ⊆ v`, which
   is preserved in `bx_le'`. So G/H truth lemmas remain intact. But:
   - `bx_G_backward` constructs a BXPoint from `{¬φ} ∪ g_content(w)`. The extended
     point `u` satisfies `g_content(w) ⊆ u` (so `bx_le w u`), but does it satisfy
     `until_compatible w u`? We would need to check that for each `(φ U ψ) ∈ w`, either
     `(φ U ψ) ∈ u` or `ψ ∈ u`. This is NOT guaranteed by the Lindenbaum construction
     from `{¬φ} ∪ g_content(w)` alone.
   - Fixing this requires enriching the seed further, cascading changes through
     `bx_forward_witness`, `bx_G_backward`, `enriched_seed_consistent_until`, and
     potentially all of `Frame.lean`.

4. **Does it close the sorry?**: In `until_eventuality_resolution`, the guard step
   would use `bx_le' u' u` (which includes `until_compatible u' u`) to derive `(φ U ψ)
   ∈ u ∨ ψ ∈ u`. With `ψ ∉ u` (needed for strict interval), this gives `(φ U ψ) ∈ u`.
   Then BX9 gives `φ ∨ ψ ∈ u`, and `ψ ∉ u` gives `φ ∈ u`. **This would close the
   sorry!** — but only if transitivity and seed-consistency issues are resolved.

**Verdict**: Redefining `bx_le` with `until_compatible` is a viable strategy in
principle but has a transitivity gap in the `ψ ∈ u` case and requires auditing all
seed-consistency lemmas. The cascade cost is moderate (not the full filtration cascade).

---

### 5. Approach Analysis: Direct Until Propagation via BX4 + BX5

**Idea**: Show `(φ U ψ) ∈ w ∧ bx_le w u → (φ U ψ) ∈ u ∨ ψ ∈ u` using BX4 + BX5.

This would amount to an axiom `G((φ U ψ) → ((φ U ψ) ∨ ψ))`, which is equivalent to
`G(¬(φ U ψ) → ¬(φ U ψ))` — tautologically true but useless — or really
`(φ U ψ) → G((φ U ψ) ∨ ψ)`, which says "the Until eventuality persists forward until ψ
appears."

**Is `(φ U ψ) → G((φ U ψ) ∨ ψ)` derivable from BX1–BX12?**

Semantically: `φ U ψ` at `t` means `∃ s ≥ t, ψ(s) ∧ ∀ r ∈ [t,s), φ(r)`. For any
`t' ≥ t` with `t' < s`, we have `ψ ∉ t'` and `φ U ψ` holds at `t'` (with the same
witness `s`). For `t' = s`, `ψ` holds. For `t' > s`, we need `φ U ψ` OR `ψ` — but
neither is guaranteed (the eventuality may have been discharged and there's no further
obligation). So `(φ U ψ) → G((φ U ψ) ∨ ψ)` is **semantically FALSE** in general: take
`t=0, s=1, t'=2` with `ψ` true at 1 only and `φ U ψ` false at 2.

**Countermodel**: At time 0: `φ U ψ` holds (witness `s=1`). G says this holds at all
future times. At time 2: `¬(φ U ψ)` and `¬ψ`, so `G((φ U ψ) ∨ ψ)` fails at time 0.

**Verdict**: `(φ U ψ) → G((φ U ψ) ∨ ψ)` is **not a valid formula** and is not
derivable from BX1–BX12. Direct Until propagation via BX4+BX5 is impossible.

**What BX5 actually gives**: BX5 (self-accumulation) says `(φ U ψ) → ((φ ∧ (φ U ψ))
U ψ)`. This is useful locally at `w` (gives a richer Until at `w`) but still cannot
propagate the Until formula to future MCSes via `g_content`.

**What BX4 gives**: BX4 (`φ → G(P(φ))`) applied to `(φ U ψ) ∈ w` gives
`G(P(φ U ψ)) ∈ w`. So `P(φ U ψ) ∈ u` for all `bx_le w u`. This gives a *backward*
witness `u'` with `bx_le u' u` and `(φ U ψ) ∈ u'`. But then we need `(φ U ψ) ∈ u`
or `φ ∈ u` — and we're back to the same lifting problem.

---

### 6. Most Promising Approach: Quasimodel with Sigma-Hintikka One-Step Relation

The existing codebase (`Quasimodel/Construction.lean`, `HintikkaPoint.lean`,
`SubformulaClosure.lean`) has scaffolding for a Hintikka-point quasimodel approach.
The key insight is:

**The `hintikka_step` relation** (Construction.lean:46–51) encodes Until persistence
*by definition*:
```lean
def hintikka_step (h1 h2 : HintikkaPoint Sigma) : Prop :=
  -- G-propagation: G(χ) ∈ h1 → χ ∈ h2
  -- H-backward: H(χ) ∈ h2 → χ ∈ h1
  -- Until defect propagation: if φ U ψ ∈ h1 and ψ ∉ h1, then φ ∈ h1 ∧ (φ U ψ) ∈ h2
```

The third clause is exactly `until_compatible` — but now as a *definitional property of
the one-step relation*, not as something to be derived from `g_content ⊆`. The guard
proof in the quasimodel context reduces to: if `hintikka_step h1 h2` and `(φ U ψ) ∈ h1`
and `ψ ∉ h1`, then `φ ∈ h1` by the third clause of `hintikka_step`.

**Why this works**: The quasimodel uses a *different ordering* (`hintikka_step*`, the
transitive closure of `hintikka_step`) on Hintikka points. This ordering has Until
persistence built in, so the guard follows immediately. The `g_content ⊆` obstruction
does not arise because the reachability relation on Hintikka points is defined with
Until in mind.

**The missing piece**: The realization lifting step — taking a Hintikka chain
(finite sequence of Hintikka points with defect discharge) and producing a sequence of
BXPoints connected by `bx_le` — is still open. Specifically, proving that:
- The Lindenbaum extension of a Hintikka point to a full BXPoint exists;
- Consecutive Hintikka points `(h1, h2)` with `hintikka_step h1 h2` correspond to
  BXPoints `(w1, w2)` with `bx_le w1 w2`;
- The guard property on the Hintikka chain lifts to the BXPoint chain.

The lifting works for G-content (already proved in `bx_G_forward`/`bx_G_backward`),
and for the `hintikka_step` Until clause, it works because the Hintikka point has `φ
∈ h1` *definitionally* — this is in `h1.formulas`, and when `h1` is realized as a
BXPoint `w1` with `h1 = sigma_signature w1`, we have `φ ∈ w1.formulas`. No lifting
across `bx_le` is needed.

---

### 7. Summary Evaluation of All Approaches

| Approach | Viable? | Complexity | Notes |
|---|---|---|---|
| Proof restructuring (minimal witness) | No | — | BX7/BX11 are formula-level, not BXPoint-level |
| Empty-interval trick | No | — | Requires successor axiom; TM targets dense orders |
| Redefine bx_le with until_compatible | Partial | High | Transitivity gap; seed-consistency cascade |
| Direct Until propagation (BX4+BX5) | No | — | Target formula is semantically invalid |
| Quasimodel Hintikka one-step approach | Yes | Medium | Already scaffolded; realization lifting is missing |

---

## Recommended Approach

**Use the existing quasimodel scaffold** (`hintikka_step` + `sigma_signature`) as the
bridge.

The recommended path is:

1. In `until_eventuality_resolution`, instead of working directly at the BXPoint level,
   project to Sigma-Hintikka points, construct the finite defect-discharge chain, then
   realize back to BXPoints.
2. The guard on the Hintikka chain follows from `hintikka_step`'s third clause: if
   `hintikka_step h1 h2` and `(φ U ψ) ∈ h1` and `ψ ∉ h1`, then `φ ∈ h1`.
3. The guard on the BXPoint sequence follows because `sigma_signature w1 = h1` implies
   `φ ∈ w1.formulas` (directly, not via `bx_le` propagation).
4. For `until_backward`, the contradiction argument works similarly: the enriched
   Lindenbaum seed is already proved consistent in `enriched_seed_consistent_until`;
   the remaining gap (`¬bx_le v u`) can be handled by showing the Hintikka projection
   of `u` is in the defect-discharge chain, giving `φ U ψ ∈ u` from the chain
   construction, contradicting `¬(φ U ψ) ∈ u`.

**Key lemma needed** (the core gap): A *realization theorem* stating:
> If `h0 → h1 → ... → hk` is a defect-discharging Hintikka chain (from
> `Construction.lean`) for `(φ U ψ) ∈ h0` with `ψ ∈ hk`, then there exist BXPoints
> `w0, w1, ..., wk` with `bx_le wi w(i+1)` for each `i`, `sigma_signature wi = hi`,
> `φ ∈ wi.formulas` for `i < k`, and `ψ ∈ wk.formulas`.

This is the "realization lifting lemma" described in `Realization.lean`'s module doc.
The proof combines:
- Lindenbaum extension: each `hi` extends to a BXPoint `wi` (trivially, via
  `set_lindenbaum` on the Hintikka seed `hi ∪ g_content(wi_prev)`).
- `bx_le wi w(i+1)`: from `G(χ) ∈ wi` and `hintikka_step hi h(i+1)` (first clause).
- `φ ∈ wi.formulas`: from `φ ∈ hi.formulas` (by `hintikka_step` third clause) and
  `sigma_signature wi = hi`.

The only *open* sub-step is proving that the Lindenbaum extensions can be chosen
consistently so that `sigma_signature wi = hi`. This requires that the enriched seed
`hi ∪ g_content(wi_prev)` is consistent, which is the "combined seed consistency"
problem.

**Combined seed consistency** is the one remaining hard sub-problem: showing that
`hi.formulas ∪ g_content(wi_prev.formulas)` is SetConsistent for consecutive chain
steps. This is not trivial because `hi` may contain formulas (like `φ` from the Until
guard) that are not in `g_content(wi_prev)` and whose consistency with `g_content`
content must be verified via BX axioms.

---

## Evidence and Supporting Examples

### Evidence that hintikka_step closes the guard:

From `Construction.lean:50–51`:
```lean
(∀ φ ψ : Formula, Formula.untl φ ψ ∈ h1.formulas → ψ ∉ h1.formulas →
  φ ∈ h1.formulas ∧ Formula.untl φ ψ ∈ h2.formulas)
```

If we have a chain step `hintikka_step h1 h2` with `(φ U ψ) ∈ h1` and `ψ ∉ h1`, then
`φ ∈ h1` — this is the guard directly, with zero proof effort.

### Evidence that sigma_signature preserves membership:

From `HintikkaPoint.lean:154–157`:
```lean
theorem sigma_signature_mem {w : BXPoint} {Sigma : Finset Formula}
    {h_neg : ∀ f ∈ Sigma, Formula.neg f ∈ Sigma} {f : Formula} :
    f ∈ (sigma_signature w Sigma h_neg).formulas ↔ f ∈ Sigma ∧ f ∈ w.formulas
```

So if `φ ∈ hi.formulas` and `wi` realizes `hi` (`sigma_signature wi Sigma = hi`), then
`φ ∈ wi.formulas`.

### Evidence from boneyard that chain approach works for discrete case:

From `DeterministicChain.lean:244–273` (`until_persists_chain`): in the discrete chain,
Until persistence uses the `x_content` (next-step) linkage:
```
(φ U ψ) ∈ chain(n) ∧ ψ ∉ chain(n+1) → φ ∈ chain(n+1) ∧ (φ U ψ) ∈ chain(n+1)
```
This relies on `until_unfold_x_in_mcs` (which requires the X/next-step operator BX2).
The Hintikka-step approach achieves the same effect without X, by encoding the
persistence directly into the one-step relation.

---

## Confidence Level

**High confidence** (85%) on the following:
1. Approaches 1–4 (restructuring, empty interval, direct propagation, BX11) cannot
   close the 6 sorries without structural changes to the proof.
2. The `hintikka_step` construction provides the correct fix: Until persistence is
   definitionally baked in, avoiding the `g_content` propagation wall.
3. The `sigma_signature` → BXPoint realization works for the guard step (φ ∈ hi →
   φ ∈ wi).

**Medium confidence** (65%) on:
4. The `until_compatible` redefinition of `bx_le` can be made to work (transitivity
   gap is fixable, but cascade cost is unclear).
5. Combined seed consistency for the realization lifting lemma is the one remaining
   hard sub-problem, and it may require a new Lindenbaum argument.

**Low confidence** (40%) on:
6. The quasimodel realization lifting lemma can be proved without adding new axioms or
   changing the `bx_le` definition. It may require BX5-style enrichment in the seed
   consistency argument, and the details have not been worked out.

---

## Appendix: Summary of Axioms Used

| Axiom | Used for | Closes sorry? |
|---|---|---|
| BX4 `connect_future` | Gives `G(P(φ U ψ)) ∈ w`, hence `P(φ U ψ) ∈ u` | No (gives backward witness, not φ) |
| BX5 `self_accum_until` | Gives `(φ ∧ (φ U ψ)) U ψ ∈ w` | No (result not G-liftable) |
| BX7 `linear_until` | Formula-level Until ordering in one MCS | No (formula-level, not BXPoint-level) |
| BX9 `until_elim` | `(φ U ψ) ∈ u → φ ∈ u ∨ ψ ∈ u` | Yes, **IF** `(φ U ψ) ∈ u` is established |
| BX10 `until_F` | `(φ U ψ) ∈ w → F(ψ) ∈ w` | No (gives existence of v, not guard) |
| BX11 `temp_linearity` | F-witnesses linearly ordered | No (formula-level, not BXPoint-level) |
| `hintikka_step` clause 3 | `(φ U ψ) ∈ h1 ∧ ψ ∉ h1 → φ ∈ h1` | **YES** — closes guard definitionally |
