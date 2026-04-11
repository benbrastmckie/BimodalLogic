# Implementation Summary: BXPoint-backed HintikkaStepOracle

- **Task**: 99 - bxpoint_backed_hintikka_oracle
- **Status**: [COMPLETED]
- **Plan**: specs/099_bxpoint_backed_hintikka_oracle/plans/01_bxpoint-backed-oracle.md
- **Session**: sess_impl_99
- **Build**: clean (`lake build` -> 950 jobs, 0 errors, no new warnings)
- **Sorries introduced**: 0
- **Axioms introduced**: 0

## What Was Changed

Single file modified: `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/Construction.lean`.

Four additions:

1. `WitnessedHintikka` structure (new) bundling a `HintikkaPoint` with a
   concrete `BXPoint` witness and the subset property
   `point.formulas ⊆ witness.formulas`.
2. `HintikkaStepOracle` (signature strengthened) now returns a
   `WitnessedHintikka Sigma` rather than a bare `HintikkaPoint Sigma`.
3. `ChainWitnessed` predicate (new) on `HintikkaRawChain`: every point
   in the chain is backed by a `BXPoint`.
4. `hintikka_chain_exists` (signature strengthened) now takes a backing
   witness `w0` for `h0` and returns a raw chain together with
   `ChainWitnessed c`.
5. `chain_step_seed_consistent` (new theorem) — the task-99 payload.

A TODO comment was also added next to `HintikkaStepOracleSince` noting
the same witness-strengthening should be ported to the Since dual as a
follow-up.

No other files were touched. Phase 4's downstream-caller repair buffer
was not needed: `grep -r "HintikkaStepOracle\|hintikka_chain_exists"
Theories/` shows the declarations are only referenced inside
`Construction.lean` itself.

## Final Type Signature

```lean
structure WitnessedHintikka (Sigma : Finset Formula) where
  point : HintikkaPoint Sigma
  witness : BXPoint
  point_subset_witness : ∀ f ∈ point.formulas, f ∈ witness.formulas

def HintikkaStepOracle {Sigma : Finset Formula} (φ ψ : Formula) : Prop :=
  ∀ h : HintikkaPoint Sigma,
    Formula.untl φ ψ ∈ h.formulas → ψ ∉ h.formulas →
    ∃ wh' : WitnessedHintikka Sigma, hintikka_step h wh'.point ∧
      (ψ ∈ wh'.point.formulas ∨
        (Formula.untl φ ψ ∈ wh'.point.formulas ∧
          defect_count wh'.point < defect_count h))

def ChainWitnessed {Sigma : Finset Formula}
    (c : HintikkaRawChain Sigma) : Prop :=
  ∀ h ∈ c.points, ∃ w : BXPoint, ∀ f ∈ h.formulas, f ∈ w.formulas

theorem hintikka_chain_exists
    {Sigma : Finset Formula} {φ ψ : Formula}
    (oracle : HintikkaStepOracle (Sigma := Sigma) φ ψ)
    (h0 : HintikkaPoint Sigma) (w0 : BXPoint)
    (h0_sub : ∀ f ∈ h0.formulas, f ∈ w0.formulas)
    (h_target : Formula.untl φ ψ ∈ h0.formulas) :
    ∃ c : HintikkaRawChain Sigma,
      c.head = h0 ∧ ψ ∈ c.last.formulas ∧ ChainWitnessed c
```

## Proof Strategy for `chain_step_seed_consistent`

Exactly the one-line MCS-subset route prescribed in the plan (mirroring
the `h_neg_in = false` branch of `enriched_seed_consistent_until` in
`Realization.lean:271-276`):

```lean
theorem chain_step_seed_consistent
    {Sigma : Finset Formula}
    {c : HintikkaRawChain Sigma} (h_wit : ChainWitnessed c)
    {h : HintikkaPoint Sigma} (h_mem : h ∈ c.points)
    (S : Set Formula) (h_sub : S ⊆ (h.formulas : Set Formula)) :
    SetConsistent S := by
  obtain ⟨w, hw⟩ := h_wit h h_mem
  intro L hL ⟨d⟩
  have h_L_in_w : ∀ α ∈ L, α ∈ w.formulas := fun α hα => hw α (h_sub (hL α hα))
  exact w.is_mcs.1 L h_L_in_w ⟨d⟩
```

The proof needs exactly the MCS consistency `w.is_mcs.1` of the backing
BXPoint, the two chained subset inclusions
`L ⊆ S ⊆ h.formulas ⊆ w.formulas`, and the refutation `d : L ⊢ ⊥`
destructured from `Consistent L`.

## Verification Results

Ran at the end of Phase 5:

| Check | Result |
|-------|--------|
| `lake build` (full project) | Success, 950 jobs, 0 errors |
| Sorries in Construction.lean | 1 (a pre-existing comment on line 105, same as baseline) |
| Axioms (declaration) in Theories/ | 0 new (4 pre-existing matches are all inside comments/docstrings) |
| `lean_verify chain_step_seed_consistent` | axioms = `[propext, Quot.sound]` |
| `lean_verify hintikka_chain_exists` | axioms = `[propext, Classical.choice, Quot.sound]` |

Both theorems depend only on the standard Lean/Mathlib axiom set already
accepted by the project. No new axioms introduced.

## Downstream Caller Repairs

None required. `HintikkaStepOracle` and `hintikka_chain_exists` have no
callers outside `Construction.lean` at this time (parent task 98 Phase 4
is the intended first caller and will consume the new signatures when
its own plan advances). The `enriched_g_neg_bigconj_mem` scope-fix
buffer was also not needed.

## Relation to Parent Task 98

This task unblocks task 98 Phase 4. The parent plan can now:

1. Use `hintikka_chain_exists` with an initial `BXPoint` witness for
   the head (available from the Phase 4 context — the MCS-level starting
   point naturally provides one).
2. Destructure the resulting `ChainWitnessed` witness and feed each
   chain point's subset obligation through `chain_step_seed_consistent`,
   which closes the `SetConsistent` obligation Teammate A's §3.3
   reduction requires.

The Since dual (`HintikkaStepOracleSince`) is untouched; the inline TODO
points future work back to this task's pattern.
