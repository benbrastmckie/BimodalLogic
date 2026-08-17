# Research Report: Effective Periodic Extension over Finite ℤ-Frames

- **Task**: 441 — `effective_periodic_extension_over_finite_frames`
- **Type**: lean4
- **Session**: `sess_1787007762_7d00d6_441`
- **Date**: 2026-08-17
- **Status**: researched

---

## Executive Summary

1. **Deliverable 2 is mostly already built.** `FormalSystem/Metalogic/Decidability/BiLasso/Basic.lean`
   (landed by a concurrent task this run) is exactly the prefix-plus-cycle-in-each-direction
   datatype, with `unrollOf`, both periodicity lemmas, `unroll_isStepPath`, and `toHF`. It should be
   reused, not duplicated. It needs **one additive extension**: an origin offset, because `BiLasso`
   pins `mid` to the time window `[0, |mid|)` and a model checker's window generally sits elsewhere
   on ℤ. Shift-invariance is free — `isStepPath_shift` compiles in 4 lines and is choice-free
   (spike verified).
2. **Deliverable 1 has a level mismatch that the plan must resolve up front.** The task states
   `extend_periodic` over `FiniteTaskFrame Int`; `BiLasso` lives over `IntPresentation`. The two are
   not interchangeable: `Finite` is non-constructive, `IntPresentation` is data. Recommendation is a
   two-tier statement (see §4), with the `IntPresentation` tier carrying the effective content and
   the `FiniteTaskFrame` tier carrying the literal existential the task's wording asks for.
3. **ON CHOICE, answered empirically, and the answer is nuanced.** `Classical.choice` is
   **unavoidable in practice** for `extend_periodic`, but — unlike task 440's `spherical_of_finite`
   — the obstruction is **not a logical one**. Two independent sources were measured
   (§6): (a) every Mathlib finiteness/counting lemma, including every pigeonhole variant and
   `Finset.card_le_card` itself, depends on `Classical.choice`; (b) `BiLasso.unroll_isStepPath` and
   the `unroll_*` periodicity lemmas already depend on it. Neither is a WLEM-style obstruction. The
   docstring must say precisely this and must **not** claim constructivity.
4. **The successor selection itself is choice-free and computable** — the one part of the task's
   ON CHOICE hope that does cash out. A deterministic `succOf` via `List.find?` over
   `List.finRange P.card` compiles at `[propext, Quot.sound]` and is `#eval`-able (spike verified).
   This is worth landing and worth saying in the docstring, because it is the honest residue of
   "visibly cheaper than the general one".
5. **The literature source exists and is verbatim-quotable, but is unanchored.** The paper's
   effective-extension remark is a `\footnote` at `possible_worlds.tex:1648` with **no `\label`**,
   so it cannot be cited by anchor under this repo's citation-of-record discipline. It also says
   *bounded world history* (convex), not *finite-domain partial history* — a scope difference the
   plan must decide on deliberately (§3).
6. **Deliverable 3's limits are already machine-witnessed**, from two directions: `TruthAt.box_const`
   / `TruthAt.box_time_const` (box truth is a constant of the model, so window agreement is simply
   the wrong instrument for it), and task 417's `no_formula_independent_scan_bound` (no bound on
   temporal witnesses is computable from the lasso alone). Both should be cited by name in the
   docstring rather than asserted in prose.

---

## Literature Proof Structure

**Source**: `/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex`, line 1648,
unlabeled footnote to the shift-of-finite-type paragraph in the discussion section. Verified
verbatim 2026-08-17.

> In this case the conclusion of **\ref{thm:extension}** becomes effective without appeal to Zorn's
> lemma: since $W$ is finite, the forward and backward orbits extending a bounded world history must
> each revisit a world state, so every bounded world history extends to a possible world that is
> eventually periodic in both directions— a finite prefix plus a finite cycle each way— and is
> therefore finitely representable, licensing a finite certificate that a given bounded history is a
> fragment of a possible world.

**Framing paragraph** (same site, load-bearing for the datatype choice):

> When $W$ is finite and $D = \Z$, the set of possible worlds $H_{\F}$ is a shift of finite type
> where world states correspond to alphabet symbols, the unit-step task relation corresponds to the
> edges of a labeled graph, and possible worlds correspond exactly to the bi-infinite paths through
> that graph. […] See Lind and Marcus~\cite{Lind2021}.

**Strategy**: direct construction (not indirect, not induction on a well-order). Forward orbit +
backward orbit + pigeonhole.

### Step Map

| # | Step | Source | Lean status |
|---|------|--------|-------------|
| 1 | `H_F` over ℤ = bi-infinite step paths | framing paragraph (SFT); `Lind2021` | **done** — `TaskFrame.mem_HF_iff_adjacent` |
| 2 | Every state has a unit-step successor and predecessor | *Seriality* at $x = 1$ | **done** — `TaskFrame.Serial` at `x = 1`; see §2 note |
| 3 | Extend the bounded window forward by iterating a successor choice | remark, clause 1 | **new** — `succOf` (spike compiles, choice-free) |
| 4 | Extend backward by iterating a predecessor choice | remark, clause 1 | **new** — `predOf`, mirror of step 3 |
| 5 | Finiteness forces each orbit to revisit a state | remark, clause 2 | **new** — `orbit_repeat` (spike compiles; costs choice, §6) |
| 6 | The result is eventually periodic in both directions | remark, clause 2 | **done as a datatype** — `BiLasso.unroll_sub_back_length` / `unroll_add_fwd_length` |
| 7 | Hence finitely representable: finite prefix + finite cycle each way | remark, clause 3 | **done as a datatype** — `BiLasso` fields `back`/`mid`/`fwd` |
| 8 | Hence a finite certificate that a bounded history is a fragment of a possible world | remark, clause 4 | **new** — the agreement lemma, Deliverable 3 |

### Dependencies

- Step 5 depends on steps 3–4 (the orbit must exist before it can repeat).
- Steps 6–7 are properties of the already-landed `BiLasso`; steps 3–5 are what *produce* one.
- Step 8 depends on 7 plus the window-fidelity argument, and is independent of 5–6.

### Potential Formalization Challenges

- **Step 3/4, gap filling**: the source says *bounded world history* — convex, hence gap-free. The
  task says *partial history on a finite domain*, which permits gaps. See §3.
- **Step 5, choice**: see §6. The paper's "without appeal to Zorn's lemma" is a true and preserved
  claim; "choice-free" in Lean's `#print axioms` sense is not, and the two must not be conflated in
  the docstring. Task 440 already established the same distinction for `spherical_of_finite`, and
  the docstring should point at that precedent rather than re-argue it.
- **Step 7, placement**: `BiLasso` pins `mid` to `[0, |mid|)`. See §5.

### Citation-of-record gap (action required)

`specs/paper-definitions-of-record.md` tracks 47 anchors including `thm:extension` and
`cor:spherical-finite`, but **not** this footnote — it has no `\label`, so there is nothing to
track it by. Two options for the plan:

- **(preferred)** Add a tracked quotation to `paper-definitions-of-record.md` under a synthetic key
  (the file already documents how anchors are added and hashed), then cite that key from the
  docstring, matching the discipline every other `Semantics/` docstring follows.
- **(fallback)** Quote the footnote verbatim in the docstring and label it explicitly as an
  *unanchored* footnote at `possible_worlds.tex` §discussion, so a future drift check does not
  mistake it for a dangling anchor reference.

Do not silently cite it as if it were an anchor.

---

## Verified Codebase Facts

Every claim in this section was checked against HEAD during this research pass.

### Already exists — reuse, do not rebuild

| Declaration | File | What it gives Deliverable |
|---|---|---|
| `BiLasso` (structure: `back`/`mid`/`fwd`/`back_ne`/`fwd_ne`/`coherent`) | `Metalogic/Decidability/BiLasso/Basic.lean:145` | **D2** — the serializable presentation, plain `List (Fin card)` + decidable `coherent` |
| `BiLasso.unrollOf`, `BiLasso.unroll` | same, `:127`, `:168` | **D2** — the decoding function |
| `BiLasso.unroll_sub_back_length` / `unroll_add_fwd_length` | same, `:185`, `:194` | **D1** — the two periodicity conclusions, already proved |
| `BiLasso.unroll_isStepPath`, `BiLasso.toHF` | same, `:224`, `:272` | **D1** — decoding lands in `H_F` |
| `flipBiLasso` | same, `:292` | proof that `coherent` is `decide`-able against a real adjacency matrix |
| `IntPresentation` (`card`/`card_pos`/`step`/`val`/`fwd`/`bwd`) | `Metalogic/Decidability/IntPresentation.lean:66` | the constructive carrier; `fwd`/`bwd` are exactly steps 3–4's licences |
| `TaskFrame.mem_HF_iff_adjacent` | `Semantics/IntNormalForm.lean:306` | step 1 |
| `TaskFrame.HFofStepPath` | `Semantics/IntNormalForm.lean:281` | path → `F.HF`, all fields discharged from adjacency |
| `exists_repeat_of_card_lt`, `exists_repeat_of_isStepPath` | `Metalogic/Decidability/FMP/Periodicity.lean:104`, `:122` | step 5, for *arbitrary* paths |
| `exists_path_of_iter` | same, `:62` | gap filling (§3) — turns `iter step n w u` into an explicit filler path |
| `exists_iter_fwd` / `exists_iter_bwd` | `Semantics/IntNormalForm.lean` | orbit existence; **`exists_iter_fwd` depends on no axioms at all** |
| `TruthAt.box_const`, `TruthAt.box_time_const` | `Semantics/Truth.lean:740`, `:753` | **D3** — box truth is a constant of the model |
| `PartialHistory.extension`, `PartialHistory.Extends` | `Semantics/Extension/Extension.lean:203`, `PartialHistory.lean:185` | the general theorem this strengthens; the agreement relation to state D3 against |

### Does not exist anywhere in the tree

`extend_periodic` / `extendPeriodic` — grep across the whole repo returns nothing. No
`EventuallyPeriodic`, no origin-offset `BiLasso` variant, no window-agreement truth-transfer lemma
(`TimeShift.truth_history_eq` is only the trivial "equal histories have equal truth").

### A hypothesis the task states that is already discharged

The task says "Given a `FiniteTaskFrame Int` **with a serial relation**". `Serial` is not an extra
hypothesis — it is a `TaskFrame` *field*:

```
TaskFrame.Serial R := ∀ (w : W) (x : D), 0 ≤ x → (∃ u, R w x u) ∧ (∃ v, R v x w)
```
(`Semantics/TaskFrame.lean:358`), and `TaskFrame.serial` is a structure field (`:556`). Instantiating
at `x = 1` gives forward *and* backward one-step seriality directly. **`extend_periodic` should take
no seriality hypothesis**; taking one would duplicate a field and diverge from the frame-intrinsic
discipline `Extension.lean`'s docstring is explicit about (`cor:occurrence` was deliberately
converted to frame-intrinsic form for exactly this reason). Say so in the docstring so a reader does
not read the absence as an omission.

---

## §3 — The gap-filling scope decision (must be made in the plan, not mid-implementation)

The paper's remark is about a **bounded world history**: `WorldHistory` carries a `convex` field, so
its domain has no holes. The task description instead says "a partial history `t` on a FINITE
domain". `PartialHistory.domain : D → Prop` is arbitrary, so `{0, 5}` is a legal finite domain with a
four-time hole.

The hole is fillable and the tree already has the tool: `respects_task 0 5` gives
`F.TaskRel (τ 0) 5 (τ 5)`, `taskRel_eq_iter` turns that into `iter F.step 5 (τ 0) (τ 5)`, and
`exists_path_of_iter` produces an explicit filler `p : ℕ → W` with adjacency at every index. So the
gapped case costs one extra lemma, not a redesign.

**Recommendation**: implement in two steps, contiguous first.

1. **Interval window** (matches the literature verbatim, and matches what a model checker actually
   emits — a contiguous time window). Hypothesis: the domain is `Set.Icc a b`, or the window is
   handed over as a `List (Fin P.card)` with pairwise adjacency. This is the phase that should carry
   the literature citation.
2. **Gapped finite domain** (matches the task's literal wording). Derived from step 1 by filling each
   consecutive-pair gap with `exists_path_of_iter`.

Doing step 2 first is the trap: the gap-filling bookkeeping (ordering the finite domain, iterating
over consecutive pairs, concatenating fillers) is most of the work and none of the insight, and it
would bury the lasso construction the task is actually about.

---

## §4 — The `FiniteTaskFrame` / `IntPresentation` level mismatch

These are genuinely different objects, and `IntPresentation.lean`'s own docstring says why:

> A `FiniteTaskFrame`'s `finite_world` field is `Finite`, which is a *non-constructive* statement: it
> asserts a bijection with some `Fin n` exists without producing one, so it yields no enumeration and
> cannot drive `decide`.

Consequences:

- A `BiLasso` cannot be built over a bare `FiniteTaskFrame ℤ` — `coherent` is `P.step … = true`,
  Bool-valued, and there is no Bool-valued step relation on a general finite frame.
- Going `FiniteTaskFrame ℤ → IntPresentation` requires extracting an equivalence to `Fin n` from a
  `Prop`-level `∃`, plus decidability of a `Prop`-valued relation. That is `Classical.choice` in its
  most literal role and produces a non-computable presentation — i.e. it destroys exactly the
  property the task is after.

**Recommended two-tier statement**:

- **Tier A (effective, the payload)** — over `P : IntPresentation`. Produces a `BiLasso P` plus an
  origin, with `coherent` decidable and the whole object serializable as three `List ℕ`s and one
  `ℤ`. This is what ModelChecker 154 Deliverable 1 consumes; that task's description names it
  explicitly as "the finite lasso witness of BimodalLogic 441 (prefix plus cycle, forward and
  backward)".
- **Tier B (literal, the task's wording)** — over `F : FiniteTaskFrame ℤ`, or more precisely
  `F : TaskFrame ℤ` with `[Finite F.WorldState]`. States exactly what the task asks:

  ```
  ∃ σ : F.HF, Extends σ.val.toPartialHistory τ ∧
    ∃ n₀ p₀ n₁ p₁ : ℤ, 0 < p₀ ∧ 0 < p₁ ∧
      p₀ ≤ Nat.card F.WorldState ∧ p₁ ≤ Nat.card F.WorldState ∧
      (∀ x, n₁ ≤ x → σ.path (x + p₁) = σ.path x) ∧
      (∀ x, x ≤ n₀ → σ.path (x - p₀) = σ.path x)
  ```

  Provable directly from `exists_repeat_of_card_lt` + `exists_iter_fwd`/`exists_iter_bwd` +
  `HFofStepPath`, without any presentation. Note `[Finite F.WorldState]` as an instance is
  preferable to `FiniteTaskFrame`'s `finite_world` *field*, which `TaskFrame.lean`'s own
  definitional-content check flags as needing a `haveI` at every use site.

Tier B is the honest reading of "strengthen `thm:extension` for the finite discrete case"; Tier A is
the honest reading of "so a model checker can ship a checkable certificate". The task wants both and
they are different theorems. Prove Tier A and derive Tier B for presented frames as a corollary; prove
Tier B directly for the general finite frame.

---

## §5 — The origin-offset gap in `BiLasso` (spike-verified)

`BiLasso.unrollOf` is:

```lean
def unrollOf (back mid fwd : List (Fin P.card)) (t : ℤ) : Fin P.card :=
  if t < 0 then cyc P back t
  else if t < (mid.length : ℤ) then mid.getD t.toNat default
  else cyc P fwd (t - (mid.length : ℤ))
```

`mid` occupies `[0, |mid|)`, hard-coded. A window at times `[-7, -3]` therefore **cannot** be
represented: the negatives are covered by `back`, which is periodic, and a general window is not.

**Recommended fix — additive, no edit to the concurrent task's file.** A new module
`Metalogic/Decidability/BiLasso/Extend.lean` carrying either a `PlacedBiLasso` structure
(`{ lasso : BiLasso P, origin : ℤ }`) or a bare `placedUnroll L origin := L.unroll (t - origin)`.
Shift-invariance is trivial and choice-free; this compiled during research:

```lean
theorem isStepPath_shift {F : TaskFrame ℤ} {f : ℤ → F.WorldState} (h : IsStepPath F f) (k : ℤ) :
    IsStepPath F (fun t => f (t - k)) := by
  intro n
  have := h (n - k)
  simpa [show n + 1 - k = (n - k) + 1 by omega] using this
```

`#print axioms isStepPath_shift` → `[propext, Quot.sound]`.

The alternative — rotating `back`/`mid`/`fwd` to re-normalize the origin to 0 — is a seam-and-wraparound
exercise with no compensating benefit, and it would make the serialized certificate harder for
ModelChecker to produce (it emits a window at whatever absolute times its search used). Prefer the
offset field.

---

## §6 — ON CHOICE: the measured answer

The task requires reporting the actual `#print axioms` result and naming the obstruction outright.
All figures below were measured against HEAD during this pass.

### Baseline measurements

| Declaration | `#print axioms` |
|---|---|
| `PartialHistory.extension` (the general Zorn theorem) | `[propext, Classical.choice, Quot.sound]` |
| `PartialHistory.occurrence` | `[propext, Classical.choice, Quot.sound]` |
| `TaskFrame.spherical_of_finite` | `[propext, Classical.choice, Quot.sound]` |
| `TaskFrame.ofStep` | `[propext, Classical.choice, Quot.sound]` |
| `BiLasso.unroll_isStepPath` | `[propext, Classical.choice, Quot.sound]` |
| `BiLasso.unroll_sub_back_length` | `[propext, Classical.choice, Quot.sound]` |
| `BiLasso.toHF` | `[propext, Classical.choice, Quot.sound]` |
| `BiLasso.cyc` | `[propext]` |
| `flipBiLasso` (a `BiLasso` *value*) | `[propext, Quot.sound]` |
| `exists_iter_fwd` | *no axioms* |

### What is choice-free, measured

Plain ℤ arithmetic is **not** the problem — this was the first hypothesis tested and it was refuted:

| Probe | Result |
|---|---|
| `(x : ℤ) + 0 = x` by `omega` | `[propext, Quot.sound]` |
| `Int.emod_nonneg` use | `[propext, Quot.sound]` |
| `(x + k*n) % n = x % n` via `Int.add_mul_emod_self_right` | `[propext]` |
| `Nat.lt_succ_iff_lt_or_eq` | *no axioms* |
| `List.eq_nil_of_length_eq_zero` | *no axioms* |
| **`succOf` (deterministic successor, `List.find?` over `List.finRange`)** | **`[propext, Quot.sound]`** |
| **`succOf_step` (its correctness)** | **`[propext, Quot.sound]`** |
| **`isStepPath_shift`** | **`[propext, Quot.sound]`** |

`succOf` is also genuinely *computable* — no `Classical.dec`, no `Finset.min'`:

```lean
def succOf (P : IntPresentation) (w : Fin P.card) : Fin P.card :=
  match h : (List.finRange P.card).find? (fun u => P.step w u) with
  | some u => u
  | none => absurd (P.fwd w) (by
      intro hex; obtain ⟨u, hu⟩ := hex
      have := List.find?_eq_none.mp h u (List.mem_finRange u); simp [hu] at this)
```

This is the concrete cash-out of the task's "successor selection … should be made with decidability
… rather than `Classical.choice`". It works, and it should be landed.

### Where choice enters, and why it cannot be avoided in practice

**Source 1 — pigeonhole.** Every Mathlib route to "a repeat exists" costs choice, measured:

| Lemma | `#print axioms` |
|---|---|
| `Fintype.exists_ne_map_eq_of_card_lt` | `[propext, Classical.choice, Quot.sound]` |
| `Finset.exists_ne_map_eq_of_card_lt_of_maps_to` | `[propext, Classical.choice, Quot.sound]` |
| `Fintype.card_le_of_injective` | `[propext, Classical.choice, Quot.sound]` |
| `Finset.card_le_card` | `[propext, Classical.choice, Quot.sound]` |
| `List.Nodup.length_le_card` | `[propext, Classical.choice, Quot.sound]` |

`Finset.card_le_card` — the most primitive counting statement in the library — already carries it, so
every derived counting lemma does too. Consequently `orbit_repeat` (spike, compiles) measures
`[propext, Classical.choice, Quot.sound]`, and so will `exists_repeat_of_card_lt`, which the tree
already uses.

**Source 2 — the existing `BiLasso` lemmas.** `unroll_isStepPath` and both `unroll_*` periodicity
lemmas already depend on choice, so any Deliverable-1 statement routed through them inherits it
regardless of how the lists are produced. (Traced during this pass: it enters through
`BiLasso.length_pos_int`'s `exact_mod_cast`/`Nat.pos_of_ne_zero` step, not through anything about ℤ
or about the frame. It is incidental, and could in principle be scrubbed, but that is another task's
file.)

### The obstruction, named — and how it differs from task 440's

**`Classical.choice` is unavoidable for `extend_periodic` as it will actually be written, and the
obstruction is Mathlib's finiteness API, not logic.**

This must be stated with the distinction from task 440 made explicit, because the two look alike and
are not:

- **440's `spherical_of_finite`**: the obstruction is **logical and proved**. Weak excluded middle is
  derivable from *Spherical* at the finite carrier `Bool` over `D = Int` from `[propext, Quot.sound]`
  alone (`Tests/BimodalTest/Semantics/SphericalFiniteAxiomTest.lean`, `wlem_of_spherical`). A
  choice-free proof would prove WLEM in Lean's intuitionistic core. It cannot be fixed.
- **441's `extend_periodic`**: the obstruction is **an API fact, not a theorem**. Pigeonhole over a
  carrier with decidable equality is constructively valid; Mathlib simply does not provide a
  choice-free route to it, because `Finset.card` is built on `Multiset`/`Quot` machinery that pulls
  `Classical.choice` in at the base. A hand-rolled constructive pigeonhole on `Fin N` would remove
  this source. It is *not* known to be impossible — and the docstring must not say it is.

The docstring should therefore say, in substance: *the `#print axioms` result is
`[propext, Classical.choice, Quot.sound]`; the `Classical.choice` dependency comes from Mathlib's
finiteness API (pigeonhole) and from the reused `BiLasso` lemmas, not from the successor selection,
which is choice-free and computable (`succOf`); unlike `spherical_of_finite`, no logical obstruction
to a choice-free proof is known, and none is claimed either way.* And it should record what **is**
preserved from the paper's claim — the same thing `spherical_of_finite`'s docstring preserves: **no
Zorn.** `extend_periodic` does not route through `PartialHistory.exists_maximal_extension`, and that
is a real, checkable, non-vacuous difference from `thm:extension`.

**Optional stretch phase** (recommended as *optional*, not required): a hand-rolled choice-free
pigeonhole on `Fin N` (~40 lines, induction on the bound using `DecidableEq (Fin N)`), which combined
with `succOf` and a de-`exact_mod_cast`'d `length_pos_int` could plausibly bring the Tier-A path
statements to `[propext, Quot.sound]`. Estimated at one phase of real work with a real chance of
failure; it must not gate the deliverables. If attempted and it fails, that is a finding to record,
not a blocker.

---

## §7 — Deliverable 3: the agreement lemma and its limits

### The lemma

State agreement at the level of **states**, against the existing `Extends` relation, so it composes
with `thm:extension`'s own vocabulary:

```
Extends (placedToHF L origin).val.toPartialHistory τ
```

i.e. `dom τ ⊆ ℤ` (free, the constructed history is total) plus `∀ t ∈ dom τ, decoded t = τ t`. On a
presentation this is `decide`-able pointwise over the finite window, which is what makes it a
*certificate* rather than an assurance.

### The limits — three of them, all citable rather than merely assertable

The task names two; research found a third that is at least as important, because it is the one a
downstream reader is most likely to trip over.

1. **`box φ` does not transfer.** `TruthAt`'s box clause is
   `∀ (σ : WorldHistory F), σ.IsTotal → TruthAt M σ t φ` (`Semantics/Truth.lean:164`) — it quantifies
   over *all* of `H_F`, not over the constructed `σ`. Sharper, and worth stating because it forecloses
   a whole family of misuse: **`TruthAt.box_const` proves a boxed formula's truth value is independent
   of the history entirely**, and `TruthAt.box_time_const` that it is independent of the time. So
   agreement on a window is not merely insufficient for box — it is the wrong instrument. Box facts
   are a property of the model, computed once, and no window certificate bears on them.
2. **`Past φ` / `Future φ` do not transfer.** `untl`/`snce` quantify over all `s : D`
   (`Truth.lean:165–167`), not over the window. Agreement on `dom τ` says nothing about times outside
   it.
3. **No bound on the temporal witness is computable from the lasso.** Task 417 proved this,
   sorry-free, at `specs/417_semantic_fmp_finite_worldstate_over_z/evidence/phase3-scan-bound-is-false.lean`:
   `no_formula_independent_scan_bound` exhibits, for **every** integer `N`, a formula whose earliest
   witness after `t = -1` exceeds `N`, on **one fixed** bi-lasso with `|back| = 1`, `|mid| = 0`,
   `|fwd| = 1`. The witness family is `prevⁿ p`, whose truth set along that path is exactly `[n, ∞)`.
   Since `N` ranges over every quantity computable from the segment lengths and the time, no scan
   bound that is a function of the lasso alone can be correct. **Corollary that must be in the
   docstring**: the periodicity of the *path* does not induce periodicity of *formula truth* along
   it, so nobody may read "the history is eventually periodic with period `p₁`" as licensing
   "truth of `φ` is eventually periodic with period `p₁`". It is not.

### The misuse to foreclose explicitly

ModelChecker 154's own description states the failure mode in the consuming repo's words:

> Any design that drops abundance wholesale and cites `thm:extension` as cover is wrong.

The docstring should name this: the agreement lemma licenses *existential* claims about the found
window (this bounded history really is a fragment of a possible world), and licenses **nothing**
about universal obligations (`box`, and the tense operators over all of `D`). Put it in the module
docstring's opening, not in a trailing note — the task explicitly asks for "PROMINENTLY … and not
merely in passing", and a reader skimming for the theorem statement must hit the limits before they
hit the theorem.

---

## Tactic Survey Results

Conducted against the spike file, not against a final proof state, so these are indicative.

| Goal | Tactic | Result | Notes |
|---|---|---|---|
| ℤ index arithmetic (window/offset reduction) | `omega` | success | pervasive and reliable throughout `BiLasso/Basic.lean`; choice-free |
| `coherent` on a concrete presentation | `decide` | success | `flipBiLasso.coherent := by decide`; confirms the field is decidable and non-vacuous |
| `succOf` totality from `P.fwd` | `simp [hu] at this` after `List.find?_eq_none.mp` | success | choice-free |
| `isStepPath_shift` | `simpa [show … by omega] using` | success | 4 lines |
| pigeonhole on the orbit | `by_contra` + `Fintype.card_le_of_injective` + `simp` | success | costs choice (§6) |
| eliminating `exact_mod_cast` from `length_pos_int` | not attempted | — | flagged as the choice entry point; scoped to the optional stretch phase |

`lean_multi_attempt` was not used; the spikes were run as whole files under `lake env lean`, which
gave stronger evidence (full elaboration plus `#print axioms`) at comparable cost.

---

## Risks and Recommendations for Planning

| # | Risk | Mitigation |
|---|---|---|
| 1 | Duplicating `BiLasso` because it landed concurrently and is easy to miss | Phase 1 must open by reading `BiLasso/Basic.lean`; the plan should name `BiLasso` as the D2 datatype outright |
| 2 | Discovering the origin-offset gap mid-proof and redesigning | Resolve in the plan: additive `BiLasso/Extend.lean` with an origin, per §5 |
| 3 | Attempting the gapped-domain case first and drowning in bookkeeping | Sequence interval-window first, gapped second, per §3 |
| 4 | Over-claiming constructivity in the docstring | §6 gives the exact wording constraints; `#print axioms` must be run and its literal output pasted |
| 5 | Understating the limits in D3, or burying them | §7; put them before the theorem, cite `box_const` and 417's refutation by path |
| 6 | Treating the optional choice-free pigeonhole as required | Mark it explicitly optional in the plan; it must not gate D1–D3 |
| 7 | Adding a seriality hypothesis that duplicates a frame field | `TaskFrame.serial` at `x = 1`; take no hypothesis (§2 note) |

### Suggested phase decomposition

1. `BiLasso/Extend.lean` scaffold: origin offset, `placedUnroll`, `placedUnroll_isStepPath`,
   `placedToHF`. Small, all pieces spike-verified.
2. `succOf` / `predOf` and their specs. Choice-free, computable, spike-verified.
3. Orbit rho decomposition: forward tail + cycle as `List (Fin P.card)`, backward mirror,
   `orbit_repeat`. This is the substantive phase.
4. Tier A `extend_periodic` for a contiguous window; `coherent` discharged; `#print axioms` recorded.
5. Deliverable 3: agreement lemma, plus the module docstring carrying the three limits and the
   literature quotation.
6. Tier B: the `FiniteTaskFrame ℤ` / `[Finite F.WorldState]` existential statement (§4), derived and
   also proved directly.
7. Gapped finite domain via `exists_path_of_iter` (§3).
8. *(Optional)* choice-free pigeonhole attempt (§6).
9. Record-file update for the unanchored footnote (§2, citation-of-record gap).

### Build baseline

`lake build BimodalTest` is red at `BoxSpreadProbe`, `RegionGateProbe`, and `TableauConformance`
(`#guard_msgs` mismatches, failing identically against HEAD). These are pre-existing and out of
scope; do not re-baseline them. Scope phase-end verification to
`lake build FormalSystem.Metalogic.Decidability.BiLasso.Extend` and siblings.

---

## Zero-Debt Note

No `sorry`, no new axiom, and no Option-B deferral is recommended anywhere in this plan. Every phase
above is believed completable. The one item with a real chance of failure — the optional choice-free
pigeonhole, §6 — is scoped as optional precisely so that its failure produces a recorded finding
rather than technical debt. If any phase does prove uncompletable, the correct response is
`[BLOCKED]` with the goal state recorded, not a placeholder.

---

## Artifacts Consulted

- `FormalSystem/Metalogic/Decidability/BiLasso/Basic.lean`
- `FormalSystem/Metalogic/Decidability/IntPresentation.lean`
- `FormalSystem/Metalogic/Decidability/FMP/Periodicity.lean`
- `FormalSystem/Semantics/IntNormalForm.lean`
- `FormalSystem/Semantics/Extension/Extension.lean`
- `FormalSystem/Semantics/PartialHistory.lean`
- `FormalSystem/Semantics/TaskFrame.lean`
- `FormalSystem/Semantics/Truth.lean`
- `specs/417_semantic_fmp_finite_worldstate_over_z/evidence/phase3-scan-bound-is-false.lean`
- `specs/paper-definitions-of-record.md`
- `/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex` (lines 1648, 2905–2925)
- ModelChecker task 154 description (downstream consumer contract)
- PossibleWorlds task 79 description, Deliverable 2 (the transcribed remark)
