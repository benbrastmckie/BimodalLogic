# Diagnostic Report: bx_le_linear Probe

- **Task**: 90 — bx_le redefinition decision
- **Phase**: 1 (diagnostic) → 2 (report)
- **Date**: 2026-04-10
- **Method**: Read-only `lean-lsp` MCP probes. No source files edited.
- **Related**: [01_team-research.md](01_team-research.md), [01_bx_le_decision-plan.md](../plans/01_bx_le_decision-plan.md)

## 1. Context

The Phase 1 team research ([01_team-research.md](01_team-research.md)) recommended
rejecting Option A (redefine `bx_le` via Until-witnesses), adopting Option B
(reframed as Burgess-Xu Until-induction on the existing
`bx_le := g_content ⊆` ordering at `Frame.lean:61`), and gating task 92 on a
cheap diagnostic: is the canonical linearity lemma
`bx_le_linear : ∀ w v : BXPoint, bx_le w v ∨ bx_le v w`
(or its weaker interval variant) directly derivable from BX7 + BX11 + BX12
given the current axiom inventory? This report answers that question via
read-only `lean-lsp` probes at the sorry site `Frame.lean:653`.

## 2. Axiom Inventory Snapshot

All three candidate axioms are confirmed present in
`Theories/Bimodal/ProofSystem/Axioms.lean`:

- **BX7 `linear_until`** (line 180):
  `(φ U ψ) ∧ (χ U θ) → ((φ∧χ) U (ψ∧θ)) ∨ ((φ∧χ) U (ψ∧χ)) ∨ ((φ∧χ) U (φ∧θ))`
  Linearly orders *Until-witnesses* inside a single MCS.

- **BX11 `temp_linearity`** (lines 240-244):
  `F(φ) ∧ F(ψ) → F(φ∧ψ) ∨ F(φ ∧ F(ψ)) ∨ F(F(φ) ∧ ψ)`
  Linearly orders *F-witnesses* inside a single MCS. Stated internally as a
  formula schema; does NOT relate two arbitrary BXPoints in the metalogic.

- **BX12 `F_until_equiv`** (lines 258-263):
  `F(φ) → (⊤ U φ)` — bridges F-eventualities to Until-form with vacuous guard.

All three live *inside* a single MCS's formula set; none provides a
metalogic relation between two arbitrary `BXPoint` values.

## 3. Probe Log

Working position: `Frame.lean:653` (the `sorry` of
`bx_until_eventuality_resolution`), where the context holds
`w : BXPoint`, `φ ψ : Formula`, `h_until : φ.untl ψ ∈ w.formulas`,
`h_not_psi : ψ ∉ w.formulas`.

### Probe 1 — Direct global bx_le_linear

**Snippet**:
```lean
have h_lin : ∀ a b : BXPoint, bx_le a b ∨ bx_le b a := by
  intro a b; sorry
```

**Goal after `intro a b`**:
```
w : BXPoint
φ ψ : Formula
h_until : φ.untl ψ ∈ w.formulas
h_not_psi : ψ ∉ w.formulas
a b : BXPoint
⊢ bx_le a b ∨ bx_le b a
```

**Result**: Goal is unchanged and bare. No axiom of BX directly closes
`bx_le a b ∨ bx_le b a` for *arbitrary* MCSes `a`, `b`. There is no accessible
formula common to `a.formulas` and `b.formulas` that could invoke BX11.

### Probe 2 — Case split on bx_le a b

**Snippet**:
```lean
have h_lin : ∀ a b : BXPoint, bx_le a b ∨ bx_le b a := by
  intro a b
  by_cases h : bx_le a b
  · exact Or.inl h
  · right; sorry
```

**Goal after `right`**:
```
case neg
...
a b : BXPoint
h : ¬bx_le a b
⊢ bx_le b a
```
Unfolding gives `⊢ g_content b.formulas ⊆ a.formulas`, i.e.
`∀ φ, G(φ) ∈ b → φ ∈ a`.

**Result**: Identical obstruction. From `¬bx_le a b`
(i.e. `∃ φ, G(φ) ∈ a ∧ φ ∉ b`) there is no route to `bx_le b a` — these are
two independent universal statements over the infinite formula language. No
characteristic formula for an MCS exists in finitary bimodal syntax.

### Probe 3 — Interval linearity variant

**Snippet**:
```lean
have h_interval :
    ∀ u : BXPoint, bx_le w u → ∀ v : BXPoint, bx_le w v →
      bx_le u v ∨ bx_le v u := by
  intro u h_wu v h_wv; sorry
```

**Goal after intro**:
```
w : BXPoint
...
u : BXPoint; h_wu : bx_le w u
v : BXPoint; h_wv : bx_le w v
⊢ bx_le u v ∨ bx_le v u
```

**Result**: Even with both `u` and `v` in the future cone of `w`, there is no
direct BX11 application. BX11 would linearly order two F-witnesses *inside*
`w.formulas`, but we do not have a common formula `χ` such that
`F(χ) ∈ w` pins down both `u` and `v`. The `g_content ⊆` ordering is
metalogic; BX11 is object-logic. The semantic bridge is missing.

### Probe 4 — BX7 instantiation probe

**Snippet**:
```lean
have h_bx7 := Axiom.linear_until φ ψ φ ψ
```

**Goal after**:
```
...
h_bx7 :
  Axiom
    (((φ.untl ψ).and (φ.untl ψ)).imp
      ((((φ.and φ).untl (ψ.and ψ)).or ((φ.and φ).untl (ψ.and φ))).or
       ((φ.and φ).untl (φ.and ψ))))
⊢ ∃ v, bx_le w v ∧ ψ ∈ v.formulas ∧ …
```

**Result**: BX7 produces a new Until-form *internal to `w.formulas`*, not a
linearity statement on BXPoints. It is useful as an inductive step (Burgess-Xu
self-accumulation) but does not close any `bx_le … ∨ bx_le …` goal directly.

## 4. Outcome Classification

**Verdict: (b) PARTIAL — stuck on an identified structural blocker.**

Global `bx_le_linear` is not derivable from BX7 + BX11 + BX12 because:
- BX11 lives inside a single MCS's formula set (object-level F-linearity),
  whereas `bx_le` is a metalogic relation between MCSes.
- Bridging the two requires a *common ancestor* MCS that "sees" both target
  MCSes through concrete F-formulas, which does not exist for arbitrary
  BXPoint pairs in the canonical model.
- No characteristic formula exists for an MCS in finitary bimodal syntax, so
  `¬bx_le a b` (an existential over `Formula`) cannot be converted into a
  positive witness that would feed BX11.

Interval linearity (Probe 3) inherits the same obstruction: having `w ≤ u`
and `w ≤ v` does not exhibit a shared F-formula in `w.formulas` that BX11 can
decompose into `u`- and `v`-witnessing disjuncts.

## 5. Identified Obstruction

The stuck sub-lemma is **not** "derive linearity of `bx_le`". The stuck point
is the *semantic bridge* from metalogic `bx_le` to object-logic F/Until
formulas. Any proof of linearity must manufacture the bridge, and the only
available manufacturer is the Burgess-Xu Until-induction technique itself,
which builds the trajectory *without* needing a separate linearity lemma.

Concretely, for the sorry at `Frame.lean:674` (`bx_until_backward`), the
existing comment says:

> From P(¬(φ U ψ)) ∈ v: ∃ u ≤ v with ¬(φ U ψ) ∈ u.
> Gap: need w ≤ u to use the guard. Requires linearity of bx_le between
> w and u.

The diagnostic shows this formulation of the gap is **misleading**: the fix
is not to prove `w ≤ u ∨ u ≤ w`. The fix is to construct `u` directly inside
the `w`-trajectory via Until-induction on `(φ ∧ (φ U ψ)) U ψ` (BX5
self-accumulation), so that `w ≤ u` holds by construction, not by
post-hoc linearization.

## 6. Implications for Task 92

- **Branch A (success)** is *eliminated*. Neither global nor interval
  linearity is directly derivable.
- **Branch B (partial with identified blocker)** is *active*. The blocker is
  the semantic bridge, and the unblocker is Burgess-Xu Until-induction
  (BX5 self-accumulation + BX6 absorption + BX10 + BX12), applied along the
  trajectory from `w` rather than post-hoc.
- **Branch C (formal countermodel)** is *inactive*. No countermodel surfaced;
  the obstruction is structural (missing bridge), not semantic.
- **Branch D (inconclusive)** is *inactive*. The probes were decisive within
  the time budget.

Task 92 should therefore commit to Burgess-Xu Until-induction as a *direct
construction*, and should NOT include a preliminary "prove `bx_le_linear`"
step. The `Frame.lean:674` comment should be updated during task 92 to
reflect this. The canonical name for the technique in all task 92 artifacts
is **Burgess-Xu Until-induction** (not "Henkin closure").
