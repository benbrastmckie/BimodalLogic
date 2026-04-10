# Task 92 — Teammate A (Primary Angle) Findings

- **Task**: 92 — Close four Until/Since truth-lemma sorries in
  `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean`
- **Role**: Primary Angle — validate and sharpen the task 90 recommendation
- **Date**: 2026-04-10
- **Author**: lean-research-agent (teammate a)
- **Status**: Research-only. No `.lean` edits.

## Summary

Walking the task 90 Burgess-Xu Until-induction sketch end-to-end against the
actual Lean types at `Frame.lean:653` and `:675` exposes **two
load-bearing steps that do not actually go through as written**. The axiom
inventory is complete, the vacuous-guard case at `u = w` and the reflexive
case at `u = v` both discharge cleanly from BX9 `until_elim` and reflexivity
of `bx_le`, and BX4 `connect_future` behaves as documented
(`φ → G(P(φ))`, `Axioms.lean:146`). However: (1) the forward-direction
sketch's step 4 asserts `(φ U ψ) ∈ u` for arbitrary u with `w ≤ u`, which
requires propagating an Until-formula through `g_content`, and there is no
such propagation lemma (Until is not preserved by `G` — we verified there is
no `G.*untl` or `all_future.*untl` lemma anywhere in the tree); (2) the
backward-direction sketch says to "propagate `¬(φ U ψ)` forward along `w` via
BX4 `connect_future`", but BX4 propagates into the **past operator** `P`
not into `¬(φ U ψ)` itself, so the forward propagation yields
`P(¬(φ U ψ)) ∈ u` at u ≥ w, not `¬(φ U ψ) ∈ u`. Pulling a witness back out
of the `P` reintroduces exactly the linearity gap the task 90 recommendation
claimed to eliminate. The task 90 recommendation is therefore **not yet a
complete proof sketch**; it is a correct setup of ingredients plus a
strategic direction, but the central propagation step is unresolved. I
propose two concrete alternative completion paths and flag the open
questions for the Critic teammate.

## Key Findings

1. **Axiom inventory matches task 90.** BX4 `connect_future`
   (`Axioms.lean:146`), BX4' `connect_past` (`:151`), BX5 `self_accum_until`
   (`:157`), BX6 `absorb_until` (`:169`), BX7 `linear_until` (`:180`),
   BX8 `refl_intro_until` (`:202`), BX9 `until_elim` (`:214`),
   BX10 `until_F` (`:226`), BX11 `temp_linearity` (`:240`), BX12
   `F_until_equiv` (`:258`) and all six primed duals are present and have
   the exact shapes task 90 cites. No axiom is missing. Verified by
   `Grep` on `Axioms.lean:140-264`.

2. **BX4 has a past operator, not a forward persistence shape.**
   `Axioms.lean:146`:
   ```
   connect_future : φ → G(P φ)       -- i.e. φ.imp (φ.some_past.all_future)
   ```
   This is NOT `φ → G(φ)`. Applied to `(φ U ψ) ∈ w` it yields
   `G(P(φ U ψ)) ∈ w`, hence `P(φ U ψ) ∈ u` for every `u` with `bx_le w u`.
   Applied to `¬(φ U ψ) ∈ w` it yields `P(¬(φ U ψ)) ∈ u` at every
   `u ≥ w`. The task 90 phrase "propagate `¬(φ U ψ)` forward along `w` via
   BX4" is misleading: you get a past-of-¬Until at every forward point, not
   the ¬Until itself. Cashing this `P` back into an MCS `u'` containing
   `¬(φ U ψ)` via `bx_backward_witness` yields a u' with
   `bx_le u' u ≤ v`, and re-establishes the original gap
   "need `w ≤ u'`".

3. **Goal shape at line 653 (verified via `lean_goal`):**
   ```
   w : BXPoint
   φ ψ : Formula
   h_until : φ.untl ψ ∈ w.formulas
   h_not_psi : ψ ∉ w.formulas
   ⊢ ∃ v, bx_le w v ∧ ψ ∈ v.formulas ∧
       ∀ (u : BXPoint), bx_le w u →
         bx_le u v ∧ ¬bx_le v u → φ ∈ u.formulas
   ```
   The guard is a universal over arbitrary MCSes `u` satisfying
   `bx_le w u ∧ bx_le u v ∧ ¬bx_le v u`. A vacuous-guard strategy
   requires no such `u` to exist, which cannot be enforced without BX7
   earliest-witness selection baked into `v`'s construction.

4. **Goal shape at line 675 (verified via `lean_goal`):**
   ```
   w : BXPoint
   φ ψ : Formula
   v : BXPoint
   h_wv : bx_le w v
   h_ψv : ψ ∈ v.formulas
   h_guard : ∀ (u : BXPoint), bx_le w u →
              bx_le u v ∧ ¬bx_le v u → φ ∈ u.formulas
   h_not_psi : ψ ∉ w.formulas
   ⊢ φ.untl ψ ∈ w.formulas
   ```

5. **The easy guard cases discharge cleanly.**
   - `u = w` case (reflexivity): `bx_le w w` by `bx_le_refl`. If
     `bx_le w v ∧ ¬bx_le v w`, then the guard at `u = w` gives `φ ∈ w`.
     And `¬bx_le v w` is forced whenever `v ≠ w` and `ψ ∈ v ∧ ψ ∉ w`
     (if `bx_le v w`, then since `H(ψ)` would need to hold at... no: the
     cleaner contrapositive is that `bx_le v w` would mean
     `g_content v ⊆ w`, which does not directly force `ψ ∈ w`; the forcing
     comes via `ψ ∈ v → G(?) ∈ v` which does not exist).
     **Caveat**: proving `¬bx_le v w` purely from `ψ ∈ v ∧ ψ ∉ w` is NOT
     immediate — `g_content v ⊆ w` is about `G`-formulas, not `ψ` itself.
     The correct approach is to note that we do not *need* `¬bx_le v w`
     separately: the forward-direction proof constructs `v` and can pick it
     to not satisfy `bx_le v w` by construction (e.g., via Lindenbaum seed
     including `¬G(ψ)` or similar). This is subtle and should be
     double-checked by the Critic.
   - `u = v` case: `¬bx_le v v` is false (reflexivity), so the guard
     conjunct `¬bx_le v u` never triggers at `u = v`. No obligation.

6. **BX9 `until_elim` gives `φ ∈ w` for free.** From `h_until : φ U ψ ∈ w`
   and `h_not_psi : ψ ∉ w`, applying `until_elim` and MCS disjunction gives
   `φ ∈ w`. This is the first line of any Lean tactic skeleton and is
   completely independent of all other machinery.

7. **`(φ U ψ) ∈ u` does not propagate via `g_content`.** I searched the
   entire tree for any lemma of the form
   `Formula.all_future (Formula.untl _ _)` or
   `G(φ U ψ)`-style persistence. None exists. Hits on
   `untl.*all_future` are all from axiom shapes of BX2/BX3 (monotonicity
   with a `G(φ → χ)` antecedent), not a pure `φUψ → G(φUψ)` fact. This
   pure persistence is in fact **not a theorem** of the BX system — the
   whole point of BX5/BX6 is that `φ U ψ` enriches its own guard at future
   points, not that the Until itself persists. So task 90 step 4's
   "(φ U ψ) ∈ u" does not follow from `w ≤ u`.

8. **BX5 + BX6 + BX10 only give `F(ψ)` at `w`, not properties at u.**
   Task 90 step 5 is correct for constructing `v`: BX5 upgrades
   `φ U ψ` to `(φ ∧ (φ U ψ)) U ψ ∈ w`; BX10 extracts `F(ψ) ∈ w`;
   `bx_forward_witness` produces a raw `v₀ ≥ w` with `ψ ∈ v₀`. What BX5
   does **not** give is any property of an arbitrary intermediate `u`.

9. **BX7 linear_until can pick an earliest witness in principle, but
   only when *two* Until formulas both hold at w.** The shape at
   `Axioms.lean:180`:
   ```
   (φ U ψ) ∧ (χ U θ) →
     ((φ∧χ) U (ψ∧θ)) ∨ ((φ∧χ) U (ψ∧χ)) ∨ ((φ∧χ) U (φ∧θ))
   ```
   The BX12 bridge `F(ψ) → (⊤ U ψ)` can supply the second Until: we have
   `⊤ U ψ ∈ w` and `φ U ψ ∈ w`. Applying BX7 with `χ = ⊤, θ = ψ` gives:
   ```
   ((φ ∧ ⊤) U (ψ ∧ ψ)) ∨ ((φ ∧ ⊤) U (ψ ∧ ⊤)) ∨ ((φ ∧ ⊤) U (φ ∧ ψ))
   ```
   Each disjunct reduces to `φ U ψ`-like shapes; this does NOT immediately
   yield an "earliest witness" in the metalogic. BX7 is an object-level
   conjunction-of-Untils fact, not a metalevel minimum-selector. There is
   no direct earliest-witness lemma.

10. **No linearity presupposition in BX7.** BX7 is sound on arbitrary
    linear orders (verified in `Soundness.lean`), but its **object-level
    conclusion** is just a three-way disjunction of compound Untils. It
    does not presuppose linearity of `bx_le`; it is an axiom about Until,
    not about the canonical ordering.

## Validated Proof Sketch

The task 90 sketch is **partially validated**. The sound portions:

- **(S1) BX9 `until_elim` → `φ ∈ w`.** Holds unconditionally.
- **(S2) BX10 + `bx_forward_witness` → raw `v₀ ≥ w` with `ψ ∈ v₀`.**
  Holds unconditionally.
- **(S3) BX5 `self_accum_until` → enriched Until `(φ ∧ (φ U ψ)) U ψ ∈ w`.**
  Holds by MCS closure under axioms.
- **(S4) BX12 `F_until_equiv` → `⊤ U ψ ∈ w`.** Holds: `F(ψ) ∈ w` (from
  BX10 on `φ U ψ ∈ w`), then BX12 gives the trivial-guard form.

The **unsound** portion as literally written:

- **(U5) "For u with `w ≤ u ≤ v ∧ ¬bx_le v u`, `(φ U ψ) ∈ u`."**
  There is no lemma for this and no derivable path. Would require either
  `G(φ U ψ) ∈ w` (false in general) or a construction where `u` is known
  to be on a `BX5`-trajectory along which the enriched Until is manually
  threaded (which is exactly the "Until-induction" removed in the BX
  refactor).

### Alternative completion path A — vacuous guard via Lindenbaum

Construct `v` as a Lindenbaum MCS over a seed that **forbids** strict
intermediate points. Concretely, seed `{ψ} ∪ g_content(w) ∪ { H(¬(ψ ∧ ¬ψ)) }`
or similar machinery to force `v` to be a **g_content**-immediate successor
of `w`. The guard then becomes vacuous because no `u` with
`bx_le w u ∧ bx_le u v ∧ ¬bx_le v u` exists. **Feasibility**:
immediate-successor MCSes in tense logic are notoriously hard to force via
Lindenbaum seeds alone; this would likely require new infrastructure and
is at the edge of the task 90 scope fence.

### Alternative completion path B — `φ` via contraposition through BX9 on `φUψ`

For each u in the strict interval, we need φ ∈ u. Suppose for contradiction
`¬φ ∈ u`. We have `P(φ U ψ) ∈ u` (from BX4 `connect_future` applied to
`φ U ψ ∈ w` and `w ≤ u`). By `bx_backward_witness` applied to u, there
exists `w' ≤ u` with `(φ U ψ) ∈ w'`. Via BX9 `until_elim`, either `φ ∈ w'`
or `ψ ∈ w'`. Neither case immediately contradicts `¬φ ∈ u` because `w'` and
`u` are not the same MCS. **This path also does not close without further
linearity / connectedness infrastructure.**

### Alternative completion path C — delegate via `until_elim` + extra axiom auditing

**Recommendation**: treat this task as a high-risk research item and
escalate via `/spawn 92` if the Critic teammate cannot close the gap at
step (U5) within a short investigation cycle. The escalation target is
**not** quasimodels (task 90 already ruled that out for scope), but rather
a search for a derived Until-forward persistence lemma — possibly via
`generalized_temporal_k` applied to a clever derivation tree involving
BX5+BX6+BX9.

## Tactic-level Skeleton (forward direction, with explicit gap)

```lean
noncomputable def bx_until_eventuality_resolution
    (w : BXPoint) (φ ψ : Formula)
    (h_until : Formula.untl φ ψ ∈ w.formulas)
    (h_not_psi : ψ ∉ w.formulas) :
    ∃ v : BXPoint, bx_le w v ∧ ψ ∈ v.formulas ∧
      ∀ u : BXPoint, bx_le w u → bx_le u v ∧ ¬bx_le v u →
        φ ∈ u.formulas := by
  -- Step 1 (S1): BX9 gives φ ∈ w.
  have h_bx9 : DerivationTree [] ((Formula.untl φ ψ).imp (Formula.or φ ψ)) :=
    DerivationTree.axiom _ _ (Axiom.until_elim φ ψ)
  have h_or : Formula.or φ ψ ∈ w.formulas :=
    SetMaximalConsistent.implication_property w.is_mcs
      (theorem_in_mcs w.is_mcs h_bx9) h_until
  have h_phi_w : φ ∈ w.formulas := by
    -- MCS disjunction split; ψ ∉ w forces φ ∈ w.
    sorry -- mechanical; use SetMaximalConsistent.or_mem_iff
  -- Step 2 (S2): BX10 gives F(ψ) ∈ w, then bx_forward_witness gives v₀.
  have h_bx10 : DerivationTree [] ((Formula.untl φ ψ).imp (Formula.some_future ψ)) :=
    DerivationTree.axiom _ _ (Axiom.until_F φ ψ)
  have h_Fψ : Formula.some_future ψ ∈ w.formulas :=
    SetMaximalConsistent.implication_property w.is_mcs
      (theorem_in_mcs w.is_mcs h_bx10) h_until
  obtain ⟨v₀, h_wv₀, h_ψ_v₀⟩ := bx_forward_witness w ψ h_Fψ
  -- Step 3 (S3): BX5 upgrades the Until.
  have h_bx5 : DerivationTree [] _ :=
    DerivationTree.axiom _ _ (Axiom.self_accum_until φ ψ)
  have h_self_accum : Formula.untl (Formula.and φ (Formula.untl φ ψ)) ψ ∈ w.formulas :=
    SetMaximalConsistent.implication_property w.is_mcs
      (theorem_in_mcs w.is_mcs h_bx5) h_until
  -- Step 4 (S4): BX12 gives ⊤ U ψ ∈ w.
  have h_bx12 : DerivationTree [] _ :=
    DerivationTree.axiom _ _ (Axiom.F_until_equiv ψ)
  have h_top_U_ψ :
      Formula.untl (Formula.bot.imp Formula.bot) ψ ∈ w.formulas :=
    SetMaximalConsistent.implication_property w.is_mcs
      (theorem_in_mcs w.is_mcs h_bx12) h_Fψ
  -- [GAP] — construct v such that the guard is discharged.
  -- Options attempted:
  --   (a) v := v₀ and discharge guard by propagating (φUψ) to u: UNSOUND
  --       (no G(φUψ) available).
  --   (b) v := Lindenbaum-minimum on g_content(w) ∪ {ψ}: needs new
  --       minimality lemma.
  --   (c) BX7 `linear_until` applied to `(φUψ) ∧ (⊤Uψ) ∈ w` to pick
  --       earliest ψ-witness — yields an object-level Until, not a
  --       metalevel minimum.
  refine ⟨v₀, h_wv₀, h_ψ_v₀, ?_⟩
  intro u h_wu ⟨h_uv, h_not_vu⟩
  -- Guard at u = w discharges via h_phi_w.
  -- Guard at u ≠ w requires [GAP].
  sorry
```

## Tactic-level Skeleton (backward direction, with explicit gap)

```lean
noncomputable def bx_until_backward
    (w : BXPoint) (φ ψ : Formula) (v : BXPoint)
    (h_wv : bx_le w v) (h_ψv : ψ ∈ v.formulas)
    (h_guard : ∀ u : BXPoint, bx_le w u →
                 bx_le u v ∧ ¬bx_le v u → φ ∈ u.formulas)
    (h_not_psi : ψ ∉ w.formulas) :
    Formula.untl φ ψ ∈ w.formulas := by
  -- The easy "existence" path gets φ ∈ w (via guard at u = w, assuming
  -- we can establish ¬bx_le v w) and ψ ∈ v and w ≤ v, but the
  -- object-level φ U ψ ∈ w requires a syntactic derivation we do not
  -- obviously have.
  by_contra h_neg
  have h_neg_U : (Formula.untl φ ψ).neg ∈ w.formulas := by
    cases SetMaximalConsistent.negation_complete w.is_mcs (Formula.untl φ ψ) with
    | inl h => exact absurd h h_neg
    | inr h => exact h
  -- Apply BX4 to ¬(φUψ): G(P(¬(φUψ))) ∈ w.
  have h_bx4 :
      DerivationTree []
        ((Formula.untl φ ψ).neg.imp
          ((Formula.untl φ ψ).neg.some_past.all_future)) :=
    DerivationTree.axiom _ _ (Axiom.connect_future (Formula.untl φ ψ).neg)
  have h_G_P_neg :
      Formula.all_future ((Formula.untl φ ψ).neg.some_past) ∈ w.formulas :=
    SetMaximalConsistent.implication_property w.is_mcs
      (theorem_in_mcs w.is_mcs h_bx4) h_neg_U
  -- Transport to v: P(¬(φUψ)) ∈ v.
  have h_P_v : (Formula.untl φ ψ).neg.some_past ∈ v.formulas :=
    bx_G_forward h_wv h_G_P_neg
  -- bx_backward_witness on v: ∃ u' ≤ v with ¬(φUψ) ∈ u'.
  obtain ⟨u', h_u'v, h_neg_u'⟩ := bx_backward_witness v _ h_P_v
  -- [GAP] — need w ≤ u' to apply h_guard at u'. This is the same
  -- linearity gap the task 90 recommendation claimed to avoid by
  -- "propagating forward". But BX4 propagates into P, not into the
  -- formula itself, so the forward push re-introduces a past witness
  -- without a link back to w.
  sorry
```

## Edge Cases

1. **ψ-witness at w itself**: excluded by `h_not_psi`. BX9 therefore
   forces `φ ∈ w` cleanly.
2. **Empty guard interval**: Lean's `¬bx_le v u` at `u = v` is false by
   reflexivity, so the `u = v` case never triggers the guard. Good.
3. **`u = w` with `¬bx_le v w`**: the guard demands `φ ∈ w`. Delivered by
   BX9 (independent of any trajectory reasoning). If `bx_le v w` holds,
   the guard implication is vacuous at `u = w`.
4. **Self-loop `w ≤ w`**: reflexivity is fine; the guard does not apply
   because `¬bx_le v w` would need to hold, which conflicts with `u = w`
   only when `bx_le v w` is false.
5. **Maximal/terminal trajectory**: BX10 still gives `F(ψ) ∈ w`, and
   `bx_forward_witness` still produces a `v₀` via Lindenbaum, regardless
   of whether `w` has "proper successors" in any visual sense — Lindenbaum
   always extends a consistent seed.
6. **Arbitrary u ∈ strict interval, u ≠ w**: **UNRESOLVED**. This is the
   open gap. No clean case analysis closes it without the missing
   Until-forward-persistence lemma.

## Evidence

### Proof state at `Frame.lean:653` (lean_goal)

```
w : BXPoint
φ ψ : Formula
h_until : φ.untl ψ ∈ w.formulas
h_not_psi : ψ ∉ w.formulas
⊢ ∃ v, bx_le w v ∧ ψ ∈ v.formulas ∧
    ∀ (u : BXPoint), bx_le w u → bx_le u v ∧ ¬bx_le v u → φ ∈ u.formulas
```

### Proof state at `Frame.lean:675` (lean_goal)

```
w : BXPoint
φ ψ : Formula
v : BXPoint
h_wv : bx_le w v
h_ψv : ψ ∈ v.formulas
h_guard : ∀ (u : BXPoint), bx_le w u →
           bx_le u v ∧ ¬bx_le v u → φ ∈ u.formulas
h_not_psi : ψ ∉ w.formulas
⊢ φ.untl ψ ∈ w.formulas
```

### Axiom signatures (verified via file reads on `Axioms.lean:140-264`)

- `connect_future φ : φ → G(P φ)` = `φ.imp (φ.some_past.all_future)` (`:146-147`)
- `connect_past φ : φ → H(F φ)` = `φ.imp (φ.some_future.all_past)` (`:151-152`)
- `self_accum_until φ ψ : (φ U ψ) → ((φ ∧ (φ U ψ)) U ψ)` (`:157-159`)
- `absorb_until φ ψ : (φ U (φ ∧ (φ U ψ))) → (φ U ψ)` (`:169-170`)
- `linear_until φ ψ χ θ : (φ U ψ) ∧ (χ U θ) → three-way Until disjunction` (`:180-186`)
- `until_elim φ ψ : (φ U ψ) → (φ ∨ ψ)` (`:214-215`)
- `until_F φ ψ : (φ U ψ) → F ψ` (`:226-227`)
- `F_until_equiv φ : F φ → (⊤ U φ)` (`:258-259`)

### No Until-forward-persistence lemma exists

`Grep` for `untl.*all_future|all_future.*untl|G.*untl` across
`Theories/Bimodal` returns only:
- BX2 `left_mono_until` (antecedent shape, not persistence)
- BX3 `right_mono_until` (antecedent shape, not persistence)
- substitution/soundness plumbing (irrelevant)

No theorem of the form `(φ U ψ) → G(φ U ψ)` or
`(φ U ψ) ∈ w → ∀ u ≥ w, (φ U ψ) ∈ u` exists. This is the load-bearing
missing infrastructure.

## Confidence Level

**Low to Medium** on the overall task 92 implementation plan as given by
task 90. **High** confidence that the task 90 sketch as literally written
does not close steps (U5) (forward guard at arbitrary intermediate `u`)
and (B-GAP) (backward linearity re-introduction via BX4 + P).

Specifically:
- **High confidence**: steps S1–S4 hold, axioms exist as task 90 claims.
- **High confidence**: BX4 is `φ → G(P φ)`, not a forward persistence for
  the formula itself. Task 90's phrasing is technically misleading.
- **Medium-low confidence**: the gap at (U5) is closeable without new
  axiom work. The task 90 recommendation may still be salvageable via a
  cleverer BX5/BX6/BX7 combination that I did not find in a single
  investigation pass.
- **Medium confidence**: escalation via `/spawn 92` for a dedicated
  "Until-forward-persistence or vacuous-witness" task may be needed.

## Open Questions (for the Critic teammate)

1. **Does a derived persistence lemma
   `(φ U ψ) ∈ w → G(φ U ψ ∨ ψ) ∈ w`** (or similar) follow from
   BX4 + BX5 + BX6 + BX10 via `generalized_temporal_k`? If so, it would
   close step (U5) because at every u ≥ w we'd have `(φ U ψ ∨ ψ) ∈ u`,
   and BX9 + case split would give `φ ∨ ψ ∨ ψ = φ ∨ ψ`, then
   `ψ ∈ u` would lead (how?) to `bx_le v u` contradicting `¬bx_le v u`
   — but this latter move still requires linking `ψ ∈ u` to
   `bx_le v u`, which is exactly the X-vs-G mismatch the module docstring
   at `Frame.lean:600-611` warns about.

2. **Can `v` be constructed as a Lindenbaum minimum on `g_content(w)`
   such that `bx_le v u` fails only when `u = v`?** Concretely, is there
   a seed augmentation (e.g., `g_content(w) ∪ {ψ} ∪ S`) for some auxiliary
   set `S` that forces v to be an immediate successor of w in the
   `g_content`-subset order?

3. **Does BX7 `linear_until` applied to `(φUψ) ∧ (⊤Uψ) ∈ w` with
   subsequent BX9/BX10 case analysis yield a syntactic proof of "earliest
   ψ-witness" at the metalevel?** The object-level BX7 conclusion is a
   three-way disjunction of compound Untils, not a metalevel minimum; the
   bridging would require re-application of BX10/`bx_forward_witness` to
   each disjunct, which may or may not terminate.

4. **For the backward direction**: is there a cleaner path via
   **BX4' `connect_past`** applied at v to `ψ`? We get
   `H(F(ψ)) ∈ v`. Pulled back through `bx_H_forward` to any `u ≤ v`,
   this gives `F(ψ) ∈ u`, which via bx_forward_witness gives a
   ψ-point reachable from u. Does this help link w and u via a
   shared ψ-witness? I did not fully explore this angle.

5. **Should the plan explicitly budget an escalation to `/spawn 92`?**
   The task 90 "do NOT escalate preemptively" guidance assumed the
   sketch was complete. Given the gap exposed here, the plan for
   `/plan 92` may need a contingent Phase 0: "Attempt the task 90 sketch
   literally; if step (U5) stalls within N hours, spawn task 94 for a
   derived Until-forward persistence lemma."

## File and Line References

All paths are absolute.

- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/Frame.lean`
  (lines 61, 140-157, 164-185, 192-205, 208-257, 266-328, 581-583, 600-704)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/ProofSystem/Axioms.lean`
  (lines 140-264)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/TemporalContent.lean`
  (lines 42-115)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/WitnessSeed.lean`
  (lines 511-560 — content duality lemmas)
- `/home/benjamin/Projects/ProofChecker/specs/090_research_bx_le_redefinition/reports/03_task92_recommendation.md`
  (the sketch whose step 4 is challenged in this report)
