# Research: carrier normalization — the successor-Archimedean transfer

**Task type**: lean4
**Session**: sess_1787618565_717c84_475
**Scope**: `FormalSystem/Semantics/DurationClassification.lean` (extend),
one new `FormalSystem/Semantics/` module, three stale docstrings, one aggregator line.

---

## 0. Executive summary — the whole task is machine-verified, end to end

This is not a feasibility assessment. A complete, `sorry`-free, axiom-clean prototype of
**both** steps was written and compiled against the repository's own pinned Mathlib during
this research pass. It is saved at

`/home/benjamin/Projects/BimodalLogic/specs/475_carrier_normalization_successor_archimedean_transfer/prototype/verified-prototype.lean`

and it ends with

```
'Probe.validDiscrete_iff_validInt' depends on axioms: [propext, Classical.choice, Quot.sound]
```

i.e. the task's headline acceptance criterion — `ValidDiscrete φ ↔ φ holds in every model over a
ℤ-frame` — is **already proved**, with no `sorryAx` and no new `axiom`. Re-check it any time with

```
lake env lean specs/475_carrier_normalization_successor_archimedean_transfer/prototype/verified-prototype.lean
```

The prototype is 294 lines including imports and blank lines; the load-bearing body is ~230.
Implementation is therefore **transcription plus placement plus docstring repair**, not
discovery. The task's own estimate ("days to two weeks") is measuring a harder job than the
one that remains.

Two findings materially change the shape of the work versus the task description:

1. **`Spherical` is cheap, not the hard field.** The worry that transporting `TaskFrame`'s
   spherical axiom would be expensive is wrong: under an ordered-group iso the *sets* of fibers
   and of segments are literally the same sets, so `spherical` transports by handing `F.spherical`
   the identical directed family. It is 11 lines. See §3.2.
2. **The genuinely fiddly point is elsewhere, and it has a clean answer.** It is the `box` clause
   of `TruthAt`, which quantifies over *all* total histories of the frame — so the transport needs
   a two-way correspondence on histories. The obvious route (prove `WorldHistory F ≃ WorldHistory
   (F.map e)` and round-trip it) forces a dependent structure equality on the `states` field and is
   avoidable. Use a **`Prop`-valued alignment relation** instead of an `Equiv`. See §4.1 — this is
   the single design decision the implementer must not get wrong.

A third, smaller finding: the successor lemma needs **less** than the task predicted. See §2.3.

---

## 1. Zero-debt posture

Nothing in this report recommends a `sorry`, an `axiom`, a deferral, or an "Option B". None is
needed: the whole thing compiles. Every construction below was elaborated, not sketched.

---

## 2. Step 1 — the successor-based analogue of `archimedean_of_lub`

### 2.1 The four declarations, verbatim and verified

```lean
variable {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    [SuccOrder D] [Nontrivial D]

/-- The successor of `0` is the least strictly positive element. -/
theorem isLeast_pos_succ_zero :
    IsLeast {y : D | 0 < y} (Order.succ (0 : D)) :=
  ⟨Order.lt_succ (0 : D), fun _ hy => Order.succ_le_of_lt hy⟩

/-- In an ordered group with a successor structure, `succ` is translation by `succ 0`. -/
theorem succ_eq_add_succ_zero (z : D) : Order.succ z = z + Order.succ (0 : D) := by
  have hu : (0 : D) < Order.succ (0 : D) := Order.lt_succ (0 : D)
  refine le_antisymm ?_ ?_
  · exact Order.succ_le_of_lt (lt_add_of_pos_right z hu)
  · have h1 : (0 : D) < Order.succ z - z := sub_pos.mpr (Order.lt_succ z)
    have h2 : Order.succ (0 : D) ≤ Order.succ z - z :=
      (isLeast_pos_succ_zero (D := D)).2 h1
    rw [le_sub_iff_add_le, add_comm] at h2
    exact h2

theorem succ_iterate_zero (n : ℕ) :
    (Order.succ)^[n] (0 : D) = n • Order.succ (0 : D) := by
  induction n with
  | zero => simp
  | succ n ih =>
    rw [Function.iterate_succ_apply', ih, succ_eq_add_succ_zero, succ_nsmul]

/-- **Successor-Archimedean forces additively Archimedean.** -/
theorem archimedean_of_succ [IsSuccArchimedean D] : Archimedean D := by
  refine ⟨fun x y hy => ?_⟩
  rcases le_or_gt x 0 with hx | hx
  · exact ⟨0, by simpa using hx⟩
  · obtain ⟨n, hn⟩ := exists_succ_iterate_of_le (le_of_lt hx)
    refine ⟨n, ?_⟩
    rw [← hn, succ_iterate_zero]
    exact nsmul_le_nsmul_right ((isLeast_pos_succ_zero (D := D)).2 hy) n

/-- The full transfer. -/
noncomputable def intIso [IsSuccArchimedean D] : D ≃+o ℤ :=
  letI : Archimedean D := archimedean_of_succ
  LinearOrderedAddCommGroup.int_orderAddMonoidIso_of_isLeast_pos
    (isLeast_pos_succ_zero (D := D))
```

`#print axioms` on `archimedean_of_succ` and on `intIso`:
`[propext, Classical.choice, Quot.sound]` for both.

### 2.2 The mathematics in one paragraph

`Nontrivial` plus the ordered-group binders give `NoMaxOrder D` and `NoMinOrder D` by instance
search (machine-checked, §2.4), so `Order.lt_succ` applies and `u := succ 0` is strictly positive.
`Order.succ_le_of_lt` — a **field** of `SuccOrder`, so available with no side conditions — makes
`u` the least positive element. Squeezing `succ z` between `z` and `z + u` from both sides gives
`succ z = z + u`: translation. Hence `succ^[n] 0 = n • u`, and `IsSuccArchimedean`'s
`exists_succ_iterate_of_le` turns every `x ≥ 0` into some `n • u`; since `u ≤ y` for any `y > 0`,
`x ≤ n • y`. Negative `x` is `n = 0`. That is `Archimedean D`.

### 2.3 Finding: the lemma needs strictly fewer binders than the task assumed

The task description carries the `ValidDiscrete` bundle into Step 1. It is not needed.
`intIso` was re-elaborated with the predecessor binders **deleted** and still compiles:

| Binder | Needed by `intIso`? |
|---|---|
| `AddCommGroup D`, `LinearOrder D`, `IsOrderedAddMonoid D` | yes |
| `SuccOrder D` | yes |
| `Nontrivial D` | yes (it is what yields `NoMaxOrder`) |
| `IsSuccArchimedean D` | yes |
| **`PredOrder D`** | **no** |
| **`IsPredArchimedean D`** | **no** |

State the lemma at the smaller bundle. `ValidDiscrete`'s two extra instances then simply go
unused at the application site, which is correct and costs nothing.

### 2.4 Binder-fit re-verification (machine-checked this session)

Against the pinned Mathlib, under the full `ValidDiscrete` bundle:

| Probe | Result |
|---|---|
| `example : NoMaxOrder D := inferInstance` | synthesizes |
| `example : NoMinOrder D := inferInstance` | synthesizes |
| `example : Nonempty D := inferInstance` | synthesizes |
| `LinearOrderedAddCommGroup.int_orderAddMonoidIso_of_isLeast_pos` signature | `[AddCommGroup G] [LinearOrder G] [IsOrderedAddMonoid G] [Archimedean G] {x : G} → IsLeast {y \| 0 < y} x → G ≃+o ℤ` — exactly as the tree's docstrings record |
| `Order.succ_le_of_lt` | `[Preorder α] [SuccOrder α] {a b} : a < b → succ a ≤ b` — no `NoMaxOrder`, no linearity |
| `Order.lt_succ` | `[Preorder α] [SuccOrder α] [NoMaxOrder α] (a) : a < succ a` |
| `exists_succ_iterate_of_le` | exported from `IsSuccArchimedean` (`Mathlib/Order/SuccPred/Archimedean.lean:38`) |

So the tree's recorded finding — that `Archimedean D` does not synthesize from
`[IsSuccArchimedean D] [IsPredArchimedean D]`, and that an `IsLeast` witness is separately
required — is confirmed, and both gaps are closed by the four declarations above. **The recorded
wrong turn stays recorded**: `orderIsoIntOfLinearSuccPredArch` is never used anywhere in this
plan; nothing below consumes an order-only isomorphism.

### 2.5 Placement

`FormalSystem/Semantics/DurationClassification.lean`. It already imports
`Mathlib.GroupTheory.ArchimedeanDensely` (which is where the consumer lives) and
`FormalSystem.Semantics.TaskFrame`. **Add one import**:
`Mathlib.Order.SuccPred.Archimedean`. That file is already in the closure via
`Semantics/Validity.lean`, so it costs no build time.

Putting these next to `archimedean_of_lub` is the point: the file's own docstring frames the two
as a Dedekind branch and a discrete branch, and after this task both branches are present.

---

## 3. Step 2a — transporting `TaskFrame` along `D ≃+o E`

### 3.1 The construction (verified, ~50 lines)

State it **generically in both duration types**, not at `ℤ`. It costs nothing extra and the
ℤ case is then an instantiation.

```lean
def TaskFrame.map (F : TaskFrame D) (e : D ≃+o E) : TaskFrame E where
  WorldState := F.WorldState
  nonempty := F.nonempty
  TaskRel := fun w d u => F.TaskRel w (e.symm d) u
  …
```

The seven fields, with the verified proof shape for each:

| Field | Why it transports | Size |
|---|---|---|
| `WorldState`, `nonempty` | unchanged — same type | 2 lines |
| `nullity_identity` | `e.symm 0 = 0`; `simpa using F.nullity_identity w u` | 2 |
| `comp` | `e.symm` is additive, and `0 ≤ x ↔ 0 ≤ e.symm x` by `map_le_map_iff` | 8 |
| `converse` | `e.symm (-d) = -(e.symm d)` via `map_neg` | 2 |
| `serial` | nonnegativity transfer only | 4 |
| `limit` | needs `\|e.symm n\| = e.symm \|n\|` — **`map_abs` exists in Mathlib** for `≃+o` | 9 |
| `spherical` | see §3.2 | 11 |

`map_abs` was located by `exact?` and applies directly to `≃+o`; no hand-rolled absolute-value
lemma is needed. That was the one plausible sticking point in `limit` and it is not one.

### 3.2 Finding: `spherical` is the *cheapest* interesting field, not the most expensive

`Spherical R` quantifies over families of sets that are fibers or segments of `R`. Under the
transport:

- `Fib (F.map e).TaskRel w n = Fib F.TaskRel w (e.symm n)`, and `e.symm` is **surjective**, so
  `IsFiber (F.map e).TaskRel s ↔ IsFiber F.TaskRel s` — the two predicates pick out the *same*
  subsets of `WorldState`.
- likewise `Seg (F.map e).TaskRel w v x y = Seg F.TaskRel w v (e.symm x) (e.symm y)`, with
  `0 ≤ x ↔ 0 ≤ e.symm x`, so `IsSegment` also matches.

Therefore `spherical` is discharged by passing `F.spherical` the *identical* directed family `S`
and rewriting the membership hypothesis. No directedness argument is reconstructed, no
intersection is recomputed. Verified body:

```lean
  spherical := by
    intro S hS hmem
    refine F.spherical S hS ?_
    intro s hs
    obtain ⟨hfs, hne⟩ := hmem s hs
    refine ⟨?_, hne⟩
    rcases hfs with ⟨w, x, rfl⟩ | ⟨w, v, x, y, hx, hy, rfl⟩
    · exact Or.inl ⟨w, e.symm x, rfl⟩
    · refine Or.inr ⟨w, v, e.symm x, e.symm y, ?_, ?_, ?_⟩
      · simpa using (map_le_map_iff e.symm (a := 0) (b := x)).mpr hx
      · simpa using (map_le_map_iff e.symm (a := 0) (b := y)).mpr hy
      · simp [TaskFrame.Seg, TaskFrame.Fib, map_neg]
```

The whole of `TaskFrame.map` compiled on the first elaboration attempt.

---

## 4. Step 2b — transporting `TaskModel`, `WorldHistory`, and `TruthAt`

`TaskModel.map` is trivial (`WorldState` is unchanged, so the valuation is reused verbatim).
`WorldHistory.map` and `WorldHistory.comap` are each ~15 lines of the same order/additivity
rewrites.

### 4.1 THE design decision: alignment relation, not `Equiv`

`TruthAt`'s `box` clause is

```lean
  | Formula.box φ => ∀ (σ : WorldHistory F), σ.IsTotal → TruthAt M σ t φ
```

— a quantifier over *every* total history of the frame. So the truth transfer needs to move
histories in both directions. The tempting route is `WorldHistory F ≃ WorldHistory (F.map e)`,
proved by round-tripping `map` and `comap`. **Do not take it.** Round-tripping forces the
structure equality `map e (comap e σ') = σ'`, whose `states` field is dependent on `domain`; the
`e (e.symm n) = n` rewrite under it is a dependent transport, and the proof degenerates into
`HEq` wrangling.

The route that works — verified — replaces the `Equiv` with a `Prop`-valued relation:

```lean
structure Aligned {F : TaskFrame D} (e : D ≃+o E)
    (σ : WorldHistory F) (σ' : WorldHistory (TaskFrame.map F e)) : Prop where
  dom : ∀ n, σ'.domain n ↔ σ.domain (e.symm n)
  st  : ∀ (n : E) (h' : σ'.domain n) (h : σ.domain (e.symm n)),
          σ'.states n h' = σ.states (e.symm n) h
```

`σ'.states … = σ.states …` is a *non-dependent* equation between two `F.WorldState` terms —
`(F.map e).WorldState` is definitionally `F.WorldState` — so no `HEq` appears anywhere. Then:

- `aligned_map e τ : Aligned e τ (τ.map e)` is `⟨fun _ => Iff.rfl, fun _ _ _ => rfl⟩`.
- `aligned_comap e σ' : Aligned e (comap e σ') σ'` needs exactly one transport, discharged by
  the tree's **existing** `WorldHistory.states_eq_of_time_eq`
  (`FormalSystem/Semantics/WorldHistory.lean:323`) at `n = e (e.symm n)`. Three lines.

### 4.2 The truth-transfer theorem

```lean
theorem truthAt_map {F : TaskFrame D} (e : D ≃+o E) (M : TaskModel F) (φ : Formula) :
    ∀ (σ : WorldHistory F) (σ' : WorldHistory (TaskFrame.map F e)), Aligned e σ σ' →
      ∀ t : D, (TruthAt M σ t φ ↔ TruthAt (TaskModel.map M e) σ' (e t) φ)
```

Induction on `φ`, generalizing over **both** histories and the time — that generalization is what
makes `box` (which swaps the history) and `untl`/`snce` (which move the time) both go through.
Case sizes as verified: `atom` 22 lines, `bot` 1, `imp` 3, `box` 8, `untl` 17, `snce` 17.

`box` is the only case that uses `comap`: forward, an arbitrary `ρ'` over the transported frame is
answered by `comap e ρ'` back over `F`; backward, an arbitrary `ρ` over `F` is answered by
`ρ.map e`. Totality moves across an `Aligned` by one line (`isTotal_map`).

`untl`/`snce` are pure order transfer: the witness `s : D` maps to `e s`, `map_lt_map_iff` in both
directions, and the inner `∀ r` uses `e.symm r`.

### 4.3 The headline theorem

```lean
def ValidInt (φ : Formula) : Prop :=
  ∀ (F : TaskFrame ℤ) (M : TaskModel F) (τ : WorldHistory F) (_ : τ.IsTotal) (t : ℤ),
    TruthAt M τ t φ

theorem validDiscrete_iff_validInt (φ : Formula) : ValidDiscrete φ ↔ ValidInt φ := by
  constructor
  · intro h F M τ hτ t
    exact h ℤ F M τ hτ t
  · intro h D _ _ _ _ _ _ _ _ F M τ hτ t
    let e : D ≃+o ℤ := intIso
    refine (truthAt_map e M φ τ (WorldHistory.map τ e) (aligned_map e τ) t).mpr ?_
    exact h (TaskFrame.map F e) (TaskModel.map M e) (WorldHistory.map τ e)
      (isTotal_map e (aligned_map e τ) hτ) (e t)
```

Both directions verified. The forward direction is the task's "already compiled, 5 lines"
soundness direction and it is here reduced to a single instantiation at `ℤ` — confirming the
task's claim that ℤ discharges the whole binder bundle with zero instance work.

---

## 5. Placement, wiring, and the docstrings that go stale

### 5.1 Module layout

| Content | Module |
|---|---|
| §2 declarations | **extend** `FormalSystem/Semantics/DurationClassification.lean` |
| §3–§4 declarations | **new** `FormalSystem/Semantics/IntTransfer.lean` |

The new module imports `FormalSystem.Semantics.Validity` (for `ValidDiscrete` and, transitively,
`TruthAt`), `FormalSystem.Semantics.DurationClassification` (for `intIso`),
`Mathlib.Algebra.Order.Hom.Monoid` (for `≃+o` and `map_le_map_iff`/`map_lt_map_iff`/`map_abs`),
`Mathlib.Algebra.Order.Group.Int` and `Mathlib.Data.Int.SuccPred` (ℤ's instances). Verified as
sufficient — the prototype uses exactly this set.

`ValidInt` may reasonably live beside the other `Valid*` predicates in `Validity.lean` instead;
`Validity.lean` already imports `Mathlib.Order.SuccPred.Archimedean`, so only the two ℤ instance
imports would move with it. Either placement compiles; put it wherever the plan prefers, but pick
one — do not define it twice.

### 5.2 Aggregator (invariant C8/C6)

`FormalSystem/Semantics.lean` must gain `import FormalSystem.Semantics.IntTransfer` **and** a
matching bullet in its `## Submodules` list. Without both, `check-module-invariants.sh` will
flag the module as unreachable-and-unmanifested. This is the exact wiring step that
`DiscreteCarrierProbe.lean` went through recently, so the pattern is established.

### 5.3 Three docstrings assert this lemma is absent. All three become false.

This is not cosmetic — each is a recorded *finding* that a future reader would act on.

| File:line | Current claim | Required repair |
|---|---|---|
| `Semantics/Validity.lean:241` | "The successor-based analogue of `DurationClassification.lean`'s `archimedean_of_lub` — the missing input to that route — is not in this tree." | now present; point at `archimedean_of_succ` / `intIso` and at the new `validDiscrete_iff_validInt` |
| `Semantics/DurationClassification.lean:85` | whole section "This is the Dedekind branch only; the discrete branch has no analogue in this tree" — plus the "is **absent**" sentence and the `## Main results` list | rewrite as *both branches present*; add the three new names to `## Main results` |
| `Semantics/IntNormalForm.lean:76` | "the discrete branch needs the successor-based analogue, which is not in the tree" | rewrite; keep the recorded wrong turn about `orderIsoIntOfLinearSuccPredArch`, which remains correct and remains worth recording |

Keep the wrong-turn record in all three places. It is still true and is the reason the route is
what it is; only the "absent" claims change.

Verification greps for the plan's gate: `is not in this tree` → 0 hits in `Semantics/Validity.lean`;
`has no analogue in this tree` → 0 hits repo-wide; `which is not in the tree` → 0 hits in
`Semantics/IntNormalForm.lean`.

### 5.4 What does *not* need to change

No existing proof consumes `ValidDiscrete` in a way this touches; `TaskFrame`, `TaskModel`,
`WorldHistory`, `PartialHistory`, and `Truth` are all **read-only** here. `TaskFrame.map` is a new
definition, not a modification of the structure, so no existing frame construction
(`ofStep`, `toTaskFrame`, `zTaskFrameV2`, `trivialFrame`, …) is affected.

---

## 6. Suggested phase decomposition

Each phase is one agent run and ends green.

| Phase | Content | Est. lines | Gate |
|---|---|---|---|
| 1 | §2 into `DurationClassification.lean` + one import | ~45 | `lake build FormalSystem.Semantics.DurationClassification`; `#print axioms archimedean_of_succ` |
| 2 | New `IntTransfer.lean` with `TaskFrame.map` only | ~55 | module builds |
| 3 | `TaskModel.map`, `WorldHistory.map`, `comap`, `Aligned`, `aligned_map`, `aligned_comap`, `isTotal_map` | ~75 | module builds |
| 4 | `truthAt_map` | ~80 | module builds |
| 5 | `ValidInt` + `validDiscrete_iff_validInt`; aggregator import + Submodules bullet | ~20 | full `lake build`; `#print axioms` shows no `sorryAx` |
| 6 | The three docstring repairs (§5.3) | doc only | greps in §5.3; `bash scripts/check-module-invariants.sh` |

Phases 2–5 are transcription from the verified prototype. Phase 6 is the phase most likely to be
skipped and least likely to be caught by a build; make it a separate gated phase for that reason.

---

## 7. Tactic survey results

`lean_multi_attempt`-style probing was unnecessary — every goal was closed by an explicit term or
a named rewrite, which is the preferred shape for a tree of this style. Recorded anyway, since
two automation choices are load-bearing:

| Goal | Tactic tried | Result | Note |
|---|---|---|---|
| `z + succ 0 ≤ succ z` in an ordered group | `linarith` | **fail** | `linarith` does not fire on a bare `AddCommGroup` + `LinearOrder`; there is no ring structure. Use `le_sub_iff_add_le` + `add_comm`. This is the one place a naive attempt loses a dispatch. |
| `e \|a\| = \|e a\|` | `exact?` | success | found `map_abs e a` |
| `Seg`/`Fib` equality under transport | `simp [TaskFrame.Seg, TaskFrame.Fib, map_neg]` | success | |
| `(comap e ρ').domain s` from `ρ'.domain (e s)` | `simpa` | **fail** | it is *definitional*; `simp` normalizes past it. Use the bare term `fun s => hρ' (e s)`. Second place a naive attempt loses a dispatch. |
| ℤ instance bundle for `ValidDiscrete` | `exact h ℤ F M τ hτ t` | success | confirms zero instance work at ℤ |

---

## 8. Acceptance criteria, against the verified prototype

| Criterion | Status |
|---|---|
| `lake build` green; no new `sorry`; no new `axiom` | prototype is `sorry`-free and axiom-clean; full-tree build is Phase 5's gate |
| successor-based lemma stated and proved | `archimedean_of_succ` — §2.1 |
| `int_orderAddMonoidIso_of_isLeast_pos` applies to it | `intIso` — §2.1, elaborates |
| `ValidDiscrete φ ↔ φ in every ℤ-frame model`, as a landed theorem | `validDiscrete_iff_validInt` — §4.3, `[propext, Classical.choice, Quot.sound]` |

One criterion the task does not list but that the tree's own conventions require: the three
"this lemma is absent" docstrings (§5.3). Treat their repair as an acceptance criterion.

---

## 9. Artifacts

- `specs/475_carrier_normalization_successor_archimedean_transfer/prototype/verified-prototype.lean`
  — the complete compiled prototype, 294 lines, re-checkable with
  `lake env lean` on that path. Everything quoted in this report is copied from it.
