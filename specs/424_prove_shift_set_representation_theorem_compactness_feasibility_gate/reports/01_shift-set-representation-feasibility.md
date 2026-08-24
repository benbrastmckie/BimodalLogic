# Shift-Set Representation Theorem — Research Report

**Scope**: `FormalSystem/Semantics/ShiftSet.lean` (does not exist yet).
**Governing design**: `specs/archive/361_strong_completeness_architecture_and_weak_terminus_gap_analysis/design/02_compactness-route.md`.
**Verification basis**: a complete 225-line prototype, compiled with `lake env lean` against the
live tree (Lean v4.33.0-rc1, Mathlib `79d0395a`), preserved at
`specs/424_prove_shift_set_representation_theorem_compactness_feasibility_gate/prototype/ShiftSet-prototype.lean`.

---

## Headline

**The gate is feasible and, in prototype form, already PASSES.** Both directions of the
representation theorem — including the truth-correspondence content, not merely the two
constructions — compile sorry-free. `#print axioms` on each reports:

```
'ShiftSet.forward_repr'    depends on axioms: [propext, Quot.sound]
'ShiftSet.reverse_repr'    depends on axioms: [propext, Classical.choice, Quot.sound]
'ShiftSet.total_eq_orbit'  depends on axioms: [propext, Quot.sound]
```

No `sorryAx` on either direction. `Classical.choice` on the reverse direction comes only from
`PartialHistory.hF_nonempty` (`Semantics/Extension/Extension.lean:266`), which is Zorn-based;
the gate's evidence standard forbids `sorryAx`, not choice.

**The cancel condition is NOT triggered.** One additional hypothesis on shift sets is required
(see §2), but it is first-order expressible over the two-sorted signature
`⟨Ω, D; <, +, 0, sh, (A_p)⟩` and hence preserved by ultraproducts (Łoś). Route B stands.

---

## 1. What the design document got wrong (and it matters)

The design doc's forward direction claims that `nullity_identity`, `forward_comp`, `converse`,
`convex`, and `respects_task` "hold BY CONSTRUCTION". That list was written against a
`TaskFrame` with **five** fields. The live `TaskFrame` (`Semantics/TaskFrame.lean:474-577`) now
carries **seven**:

| Field | Line | Status under `TaskRel w d u := (u = sh w d)` |
|---|---|---|
| `nonempty` | :492 | free — from `Ω` nonempty |
| `nullity_identity` | :511 | free — from `sh w 0 = w` |
| `comp` (**biconditional**) | :533 | free — **both** halves; interpolation is witnessed by `sh w x`, uniquely |
| `converse` | :549 | free — from the two action laws |
| `serial` | :556 | free — witnesses `sh w x` and `sh w (-x)` |
| `limit` | :566 | **FAILS** for an arbitrary `D`-action — see §2 |
| `spherical` | :577 | free — see §3 |

So the forward direction carries **four obligations the design doc never mentioned**
(`serial`, `limit`, `spherical`, and the interpolation half of `comp`), not the "one small new
obligation" the task re-issue anticipated. Three of the four are free. The fourth is not.

The re-issue's *own* named new obligation — "the constructed frame's total-history set equals the
shift-orbit range" — is genuine, is proved (`total_eq_orbit` in the prototype), and is indeed
easy: `σ.respects_task 0 t` gives `σ.states t = sh (σ.states 0) t` directly, after `sub_zero`.

## 2. The one real gap: *Limit* is not free, and the `ShiftSet` structure must carry it

`TaskFrame.limit` reads

```lean
limit : ∀ w u, (∀ x, 0 < x → ∃ y, |y| < x ∧ TaskRel w y u) → u = w
```

Under `TaskRel w d u := (u = sh w d)` this is a **substantive** condition on the action, and it
is **false** for `D`-actions in general.

**Counterexample** (not machine-checked; see §7 for why, and for the cheapest route to
machine-checking it): take `D := ℝ` and `Ω := ℝ ⧸ ℚ` with `sh [a] d := [a + d]`. Both action
laws hold. Take `w := [0]` and `u := [α]` for any irrational `α`. For every `x > 0`, rational
density supplies `q ∈ ℚ` with `|α − q| < x`; set `y := α − q`, so `|y| < x` and
`[y] = [α] = u`. Yet `u ≠ w` because `α ∉ ℚ`. *Limit* fails.

Structurally: *Limit* fails for exactly the actions in which some stabiliser subgroup
`Stab(w) ≤ D` has a coset accumulating at `0` — i.e. a **dense proper** stabiliser. Nothing in
`sh_zero`/`sh_add` rules that out.

**Therefore `ShiftSet` must carry a separation field**, which is the literal transcription of
*Limit* over the action:

```lean
  /-- The paper's *Limit* axiom, transcribed over the shift action. -/
  limit : ∀ w u, (∀ x : D, 0 < x → ∃ y : D, |y| < x ∧ u = sh w y) → u = w
```

Two facts make this the right field and not a fudge:

1. **It is elementary.** Written out it is
   `∀ w u : Ω. (∀ x : D. 0 < x → ∃ y : D. −x < y ∧ y < x ∧ u = sh(w, y)) → u = w` — a
   first-order sentence over `⟨Ω, D; <, +, 0, sh, (A_p)⟩`, hence preserved by ultraproducts.
   The design doc's cancel condition names "an additional **non-elementary** hypothesis"; this
   is not one, so **the branch is not cancelled**.
2. **The reverse direction discharges it.** `rev_sep` in the prototype proves it for
   `Ω := F.HF`, `sh := HF.timeShift`, straight out of `F.limit`: if `τ = σ.timeShift y` with
   `|y| < x` for every `x > 0`, then at each time `t`, `σ.respects_task t (t+y)` gives
   `F.TaskRel (σ.states t) y (τ.states t)`, and `F.limit` collapses the two states. No new
   frame hypothesis is needed.

**Rejected alternative — freeness.** The obvious stronger axiom `∀ w d, sh w d = w → d = 0`
(free action) *does* imply the separation field, and is simpler. **It must not be used**: the
reverse direction cannot discharge it. A constant total history (`WorldHistory.universal`, e.g.
over a reflexive frame) satisfies `σ.timeShift d = σ` for **every** `d`, so its stabiliser is all
of `D`. Separation is exactly the right strength; freeness is strictly too strong and would
refute the reverse direction. This is worth a docstring in the landed file.

## 3. *Spherical* is free — and the reason is worth recording

Under a functional task relation, `Fib R w x = {sh w x}` is a **singleton** and
`Seg R w v x y = {sh w x} ∩ {sh v (−y)}` is a singleton or empty. `DirectedFamily`
(`TaskFrame.lean:276`) requires `∃ S' ∈ S, S' ⊆ S₁ ∩ S₂`; on singletons this forces every member
of the family to be the *same* singleton, so `⋂₀ S` is that singleton and is nonempty. Proved in
the prototype (`frame.spherical`, ~14 lines) — no frame-theoretic machinery, no Zorn.

Consequence worth stating plainly: **the shift-set axiomatisation is four items
(`carrier_nonempty`, `sh_zero`, `sh_add`, `limit`) where the frame needs seven.** Three frame
axioms are pure consequences of functionality plus the group action. That is the substance of
"the task-model class is representable by shift sets."

## 4. R3 (`Type` vs `Type*`) — asserted early, as the design doc demands

`TaskFrame.WorldState : Type` (`TaskFrame.lean:477`), and `valid` binds `D : Type`
(`Validity.lean:95`, with the note at :92). So:

- `ShiftSet` must be declared with `(D : Type)`, **not** `Type*`, and `Carrier : Type`.
- With `D : Type`, `WorldHistory F : Type` and therefore `F.HF : Type`, so the reverse
  direction's carrier lands where the forward direction needs it.

The prototype fixes `D : Type` in the `ShiftSet` binder and typechecks `ofModel` — R3 is
discharged at the structure declaration, not at assembly time. **Do not** relax to `Type*`.

## 5. Two dependencies the file cannot avoid

### 5a. History extensionality is not available in `Semantics/`

`sh_zero`, `sh_add`, `total_eq_orbit` and `rev_sep` all need "two histories with equal domain and
equal states are equal". `WorldHistory`/`PartialHistory` have **no** `@[ext]` lemma. The only
copy in the tree is `worldHistory_ext` at
`FormalSystem/Metalogic/Decidability/Verified/Bridge/RegionFrame.lean:132` — importing that from
`Semantics/` would invert the layering.

Options: (a) a local copy inside `ShiftSet.lean`, docstring'd as a local copy with an explicit
cross-reference to `RegionFrame.lean:132`; (b) extend `file_scope` and hoist a
`WorldHistory.ext` into `Semantics/WorldHistory.lean`, retargeting `RegionFrame.lean`.
**Recommend (a)** — it keeps `file_scope` honest, the lemma is 10 lines, and the consolidation is
a clean separate follow-up. The prototype uses (a) (`ShiftSet.wh_ext`).

### 5b. Carrier-nonemptiness pulls in the Extension Theorem

`ofModel`'s `carrier_nonempty` needs `Nonempty F.HF`, supplied by
`PartialHistory.hF_nonempty F F.nonempty.some` (`Semantics/Extension/Extension.lean:266`). So
`ShiftSet.lean` must `import FormalSystem.Semantics.Extension.Extension`, and the reverse
direction inherits `Classical.choice`. Both are fine; both should be stated in the module
docstring so nobody later mistakes the choice dependency for a defect.

### 5c. `lake build` will not see the file unless it is registered

`lakefile.lean` sets `roots := #[FormalSystem]`, and the semantics aggregator is
`FormalSystem/Semantics.lean` (imports at :7-20). A new `ShiftSet.lean` that nothing imports is
**not built** by `lake build`, which would make the "lake build green" acceptance criterion
vacuous. **`file_scope` must be extended to include `FormalSystem/Semantics.lean`** (a one-line
`import FormalSystem.Semantics.ShiftSet` addition). This is the one scope change that is not
optional.

## 6. Verified anchors (all re-read against the live tree this session)

| Symbol | Location | Note |
|---|---|---|
| `TruthAt` | `Semantics/Truth.lean:159-167` | 6 clauses; box is `∀ σ, σ.IsTotal → …`; no `Omega` |
| `TaskFrame` | `Semantics/TaskFrame.lean:474-577` | 7 fields |
| `TaskFrame.Spherical` / `DirectedFamily` / `IsFiber` / `IsSegment` | `TaskFrame.lean:343` / `:276` / `:284` / `:294` | |
| `WorldHistory.timeShift` | `Semantics/WorldHistory.lean:262` | `domain z := σ.domain (z + Δ)` |
| `WorldHistory.isTotal_timeShift` | `Semantics/WorldHistory.lean:486` | unconditional |
| `TaskFrame.HF`, `HF.timeShift`, `HF.timeShift_val` | `WorldHistory.lean:512`, `:521`, `:525` | already exactly the reverse direction's `Ω`/`sh` |
| `TimeShift.time_shift_preserves_truth` | `Semantics/Truth.lean:457` | `(M) (σ) (x y : D) (φ)`, unconditional |
| `PartialHistory.occurrence` / `hF_nonempty` | `Semantics/Extension/Extension.lean:250` / `:266` | |
| `valid` | `Semantics/Validity.lean:94-98` | `D : Type` |
| `worldHistory_ext` | `Metalogic/Decidability/Verified/Bridge/RegionFrame.lean:132` | wrong layer to import |
| `ShiftClosed` | — | confirmed absent tree-wide; retired, as the re-issue states |
| sorries in `FormalSystem/Semantics/**` | — | zero |

## 7. What is *not* machine-checked

The §2 counterexample. Machine-checking it needs `Mathlib.Data.Real.Irrational`, which is **not
in this repo's Mathlib build** (1840 of ~7000 oleans are built), so it would add substantial
build time. The cheapest self-contained alternative avoids the reals entirely: `D := ℚ`,
`Ω := ℚ ⧸ H` with `H := {q : ℚ | ∃ (a : ℤ) (n : ℕ), q = a / 2^n}` (the dyadics — a dense proper
subgroup of `ℚ`); `1/3 ∉ H` because `2^n = 3a` would force `3 ∣ 2^n`. Estimated 40-60 lines.

**This is optional and not gate-blocking.** It is worth doing because it converts "the `limit`
field is an unjustified strengthening of the shift-set notion" from an open reviewer objection
into a theorem. Recommend it as a final, explicitly-optional phase.

---

## 8. Recommended shape of `FormalSystem/Semantics/ShiftSet.lean`

Phase-sized, each phase one agent run. Total ~250-300 lines including docstrings.

| Phase | Content | Prototype evidence |
|---|---|---|
| 1 | Module header; `structure ShiftSet (D : Type) … [4 fields + `A`]`; `sh_neg`, `sh_neg'`; local `wh_ext`. R3 asserted here. | compiles |
| 2 | `ShiftSet.frame` — all seven `TaskFrame` fields. `limit := S.limit`; `spherical` proved from singleton fibers/segments. | compiles |
| 3 | `ShiftSet.hist`, `hist_isTotal`, `ShiftSet.model`, `total_eq_orbit`. | compiles |
| 4 | `ShiftTruth` (6 clauses, box over the whole carrier); `forward_repr` by induction. | compiles |
| 5 | `ts_zero`, `ts_add`, `rev_sep`; `ofModel`; `reverse_repr` by induction. | compiles |
| 6 | Register in `FormalSystem/Semantics.lean`; `#print axioms` on both directions; `lake build`. | — |
| 7 | *(optional)* dyadic counterexample witnessing that the `limit` field is not derivable. | not attempted |

Gate verdict recorded in the task summary should be **PASSED**, conditional on phase 6 reproducing
the two clean `#print axioms` lines inside the real build.

### Statement shapes that must land verbatim

```lean
theorem ShiftSet.forward_repr (S : ShiftSet D) (w : S.Carrier) (t : D) (φ : Formula) :
    TruthAt S.model (S.hist w) t φ ↔ ShiftTruth S w t φ

theorem ShiftSet.reverse_repr (F : TaskFrame D) (M : TaskModel F) (τ : F.HF) (t : D)
    (φ : Formula) :
    ShiftTruth (ShiftSet.ofModel F M) τ t φ ↔ TruthAt M τ.val t φ
```

A pair of bare *constructions* (`frame`, `ofModel`) with no truth-correspondence would type-check
and be **vacuous as a gate** — the whole point is that `TruthAt` transfers, since that is what
the Łoś lemma of step `S3` will be stated against. Both statements above must be present.

## 9. Zero-debt note

No phase above requires `sorry`, and no new axiom is introduced. Every proof obligation named in
this report has been discharged in the prototype except the optional §7 counterexample, which is
a fresh construction rather than a gap in the gate.
