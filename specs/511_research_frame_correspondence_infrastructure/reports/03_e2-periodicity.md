# Research Report (Third Pass): E2 — does `FwdRec` force periodicity?

**Task**: 511 — Determine what frame-correspondence infrastructure this bimodal setting can
support, and specify it
**Task Type**: formal
**Domains**: logic (temporal correspondence), math (order theory, combinatorics of digraphs)
**Scope**: single question — report 02 §6's open item **E2**. Nothing else in reports 01 or 02 is
re-opened, amended, or restated.
**Lean evidence**: `specs/511_research_frame_correspondence_infrastructure/reports/03_probes.lean`
— 646 lines, compiles clean under `lake env lean` (exit 0, no errors, no `sorry`), every headline
result checked with `#print axioms` to depend only on `propext` / `Classical.choice` / `Quot.sound`.

---

## Executive Summary

**E2 is TRUE, and it is now proved. `FwdRec` is the exact correspondent for the full density
schema over `D = ℤ`.**

1. **The lead is wrong, and cheaply so.** The full 2-shift *is* a legal task frame — the
   permissive-class helpers `natFrame` uses are generic in the carrier, so `freeFrame Bool` is a
   `TaskFrame ℤ` with all four `def:frame` axioms discharged (**[Lean]**, `freeFrame`). So report
   02 §2's digraph reformulation is **faithful**, not lossy, and `limit` is not the hidden
   ingredient — over a `D` with a least positive element `limit` is discharged outright by
   `limit_of_succOrder` and carries no content at all. The lead's counterexample fails for a
   different reason: it exhibits *one* aperiodic forward-recurrent walk, whereas `FwdRec F`
   quantifies over **all** total histories, and the full 2-shift also admits `… a a a b a a a …`,
   in which `b` never recurs (**[Lean]**, `freeFrame_bool_not_fwdRec`). Neither of the brief's
   outcomes (1) or (2) is what happened. §1.

2. **E2, in report 02 §2's own digraph terms, is TRUE — proved.** If every bi-infinite walk in
   `(W, R)` is forward-recurrent at every position, then every bi-infinite walk is periodic
   (**[Lean]**, `Walk.periodic`). The proof runs through a sharper intermediate fact that is the
   real content: **`R` is deterministic** — no state has two distinct walk-successors
   (**[Lean]**, `Walk.succ_unique`). Determinism plus a single recurrence gives periodicity in
   two lines. §2.

3. **The determinism proof is a minimal-cycle argument, not a case analysis.** Report 02 tried
   candidate digraphs one at a time and kept finding a one-off visit; the general reason is:
   `AllRec` forces every closed walk at `x` to visit exactly the vertices of the *shortest* closed
   walk at `x`, and a second out-edge at `x` then splices a strictly shorter closed walk. §2.2.

4. **Full-schema exactness now holds over `ℤ`** (**[Lean]**, `Bridge.density_schema_iff_fwdRec`):

   > `F ⊨ GGφ → Gφ` for **every** formula `φ` ⟺ `FwdRec F`.

   The `⟸` half needed one lemma the tree did not have and one it already did. New:
   `truthAt_add_hist_period`, truth periodicity from a **per-history** period. Existing:
   `Truth.box_time_const` — a boxed formula's truth value is a constant of the model. That is what
   lets a period belonging to `τ` alone survive the `□` case. **Report 02 §9's Phase E1 is
   thereby unnecessary**: no `Formula.BoxFree` predicate is needed. §3.

5. **One caveat, and it is real: E2's *periodicity* conclusion is specific to `D ≅ ℤ`.** Over a
   general non-dense `D` — e.g. `D = ℤ ×ₗ ℤ` — there is a `FwdRec` frame with a total history
   having **no** period whatever (**[paper]**, §4). The density conclusion still appears to
   survive there, by an order-automorphism argument replacing the group-translation one, but that
   is **not** proved and is recorded as open. So the exactness claim is stated at `D = ℤ` and
   nowhere wider. §4, §5.

6. **Report 02's Risk-table entry "over-reading the atomic biconditional" is now discharged for
   `D = ℤ` and still stands for every other `D`.** The atomic biconditional
   `Corr.density_iff_fwdRec` is untouched and continues to hold over arbitrary `D`; what changed
   is that at `D = ℤ` the schema-level statement is now proved too. §5.

---

## 0. Method, and what is verified vs. argued

Everything labelled **[Lean]** is machine-checked in `reports/03_probes.lean` against the tree's
own `TruthAt`, `TaskFrame`, `WorldHistory`, `TaskModel`. Everything labelled **[paper]** is an
argument I did not formalise. One item is flagged **[open]**.

`Corr.Covers`, `Corr.FwdRec` and `Corr.density_iff_fwdRec` are **copied verbatim** from
`02_probes.lean` §Probe C into `03_probes.lean`, unchanged, because probe files are standalone and
not on the Lake module path so one cannot import the other. Nothing about them is modified; the
copy exists only so that the new biconditional is machine-checked end to end in one file.

---

## 1. The lead, tested and refuted — for a reason that matters

The brief's lead had two halves. Both are answered, and they point in opposite directions from the
one predicted.

### 1.1 The digraph reduction is faithful; `limit` is not the hidden ingredient — **[Lean]**

The suspicion was that `TaskRel ≡ True` on a carrier with `|W| > 1` violates `limit`, so that
report 02 §2's digraph picture silently admits illegal frames.

That suspicion conflates two relations. The full 2-shift's frame relation is **not** `≡ True`; it
is the *permissive* relation `R w d u ↔ (d ≠ 0 ∨ w = u)`, which at `d = 0` relates a state only to
itself. `≡ True` indeed fails `nullity_identity` (and hence `limit`); the permissive relation
fails neither. The probe builds

```lean
def freeFrame (W : Type) [Nonempty W] … : TaskFrame D
```

discharging every field with the tree's own Helper-B lemmas — `serial_of_permissive`,
`limit_of_permissive`, `spherical_of_permissive`, `interpolates_of_permissive` — **none of which
mentions `ℕ`**. `natFrame` is simply the `W = ℕ` instance of this. So `freeFrame Bool` is a legal
`TaskFrame ℤ`, and its one-step digraph `R w u := TaskRel w 1 u` is the complete digraph on
`Bool`: the full 2-shift, all four edges.

Sharper still: over any `D` with a least positive element `p`, the `limit` field is **vacuous**.
Its hypothesis supplies, for every `x > 0`, some `y` with `|y| < x`; instantiating at `x := p`
forces `y = 0`, and `nullity_identity` closes it. That is exactly what
`TaskFrame.limit_of_succOrder` is, and it is why `limit_of_permissive` delegates to it. **`limit`
cannot be the reason E2 is true, because on the non-dense `D` where E2 is even statable it has no
content.**

### 1.2 The proposed counterexample walk is not a counterexample to E2 — **[Lean]**

`FwdRec F` is a condition on `F`, quantified over **all** total histories:

```lean
def FwdRec (F : TaskFrame D) : Prop :=
  ∀ (τ : WorldHistory F) (hτ : τ.IsTotal) (t s : D), Covers t s → …
```

An aperiodic walk in which both letters recur is forward-recurrent *as a walk*. It does not make
its frame `FwdRec`, because the same frame admits other walks. The probe exhibits one:

```lean
theorem freeFrame_bool_not_fwdRec : ¬ Corr.FwdRec (freeFrame Bool (D := ℤ))
```

witnessed by `blipHist`, the history `… a a a b a a a …` with states `decide (t = 0)`. At the
covering pair `(-1) ⋖ 0` the set `A := (· = false)` holds throughout `(0, ∞)` and fails at `0`.

This is exactly report 02 §6's own phrasing — "*if **every** bi-infinite walk in `(W, R)` is
forward-recurrent at every position*" — so the digraph statement was never the false one. The lead
mislocated the quantifier.

**Consequence for the dispatch's decision tree**: outcome (1) is wrong (the reduction is not
lossy), outcome (2) is wrong (the counterexample does not survive as a legal frame *satisfying
FwdRec*), and outcome (3) does not apply. E2 is true, and true for a purely combinatorial reason.

---

## 2. E2 in digraph form: TRUE — **[Lean]**

Fix a relation `R` on a set `W`. Write

```lean
def IsWalk (R : W → W → Prop) (σ : ℤ → W) : Prop := ∀ n : ℤ, R (σ n) (σ (n + 1))

def AllRec (R : W → W → Prop) : Prop :=
  ∀ σ : ℤ → W, IsWalk R σ → ∀ n : ℤ, ∃ m : ℤ, n < m ∧ σ m = σ n
```

`AllRec` is the digraph transcription of `FwdRec` over `ℤ` (§3.1 below makes the bridge precise).

> **Theorem (`Walk.periodic`, proved).**
> `AllRec R → ∀ σ, IsWalk R σ → ∃ π : ℤ, 0 < π ∧ ∀ n, σ (n + π) = σ n`.

### 2.1 The real content is determinism

> **Theorem (`Walk.succ_unique`, proved).** Under `AllRec R`, any two walks agreeing at time `0`
> agree at time `1`.

Given determinism, periodicity is immediate: `AllRec` hands over `m > 0` with `σ m = σ 0`; the
shifted walk `σ(· + m)` agrees with `σ` at `0`, hence (by determinism, iterated —
`Walk.det`) at every later time; and `Walk.exists_nonneg_eq` pulls every negative index back to a
non-negative one, so the same period covers all of `ℤ`. This is `Walk.periodic`'s eight-line proof.

So report 02's empirical observation — "the frames that survive are precisely those whose `R` is a
permutation with all orbits finite" — was right, and the load-bearing half of it is the
*functionality*, not the finiteness.

### 2.2 Why determinism holds: the minimal-cycle argument

Report 02 attacked E2 by trying candidate digraphs (`{(a,a),(a,b),(b,a)}`; `{(a,b),(b,a),(a,c),(c,a)}`;
`ℕ` with resets) and finding a one-off visit each time. The uniform reason is three steps.

Let `x` lie on some walk. Grafting an arbitrary right-infinite walk from `x` onto that walk's past
is again a walk, so `AllRec` at position `0` gives:

- **(a) Every right-infinite walk from `x` returns to `x`.** In particular closed walks at `x`
  exist. Let `ℓ` be the **least** length of one, realised by `W₀` (packaged in Lean as the
  structure `Walk.MinCyc`, built by `Walk.exists_minCyc` via `Nat.find`, with `W₀` the periodic
  extension `Walk.per` of the witnessing closed walk).

- **(b) Containment (`Walk.minCyc_mem`).** *Every state occupied by any closed walk at `x` lies on
  `W₀`.* Graft the closed walk's periodic extension onto the **past** of `W₀`'s future. Each of
  its states then sits at a negative index; `AllRec`, iterated, pushes its recurrences arbitrarily
  far right (`Walk.exists_nonneg_eq`), so it must reappear at a non-negative index, i.e. on `W₀`.

- **(c) The splice.** Suppose `x` has two distinct walk-successors; let `w` be whichever differs
  from `W₀ 1`. By (a) there is a closed walk at `x` through `w`, so by (b) `w = W₀ j` with
  `0 ≤ j < ℓ`. `j = 1` is excluded by choice of `w`. `j = 0` forces a loop at `x`, hence `ℓ = 1`,
  hence `W₀ 1 = x = w` — excluded likewise. So `j ≥ 2`, and

  ```
  x → W₀ j → W₀ (j+1) → … → W₀ (ℓ-1) → x
  ```

  is a closed walk at `x` of length `ℓ - j + 1 < ℓ`, contradicting minimality. ∎

Every one of report 02's failed candidates is an instance: the golden-mean shift has `ℓ = 1`
(the loop at `a`) and a second out-edge `a → b`, so (c) fires immediately.

**Note on what is *not* needed.** No finiteness of `W`, no strong connectivity, no König-style
compactness, no choice beyond what Lean's `Classical` already supplies. `W` may be infinite; the
argument localises to the minimal cycle through the state under examination.

---

## 3. From periodicity to the full schema — **[Lean]**

### 3.1 The bridge: a task frame over `ℤ` *is* a serial digraph

Report 02 §2 asserted this; the probe proves it, in both directions.

- **Histories are walks** (`Bridge.hist_isWalk`): `respects_task n (n+1)` is literally
  `R (τ n) (τ (n+1))` for `R w u := F.TaskRel w 1 u`.
- **Walks are histories** (`Bridge.taskRel_nat`, `Bridge.taskRel_diff`, `Bridge.ofWalk`): induction
  on `k : ℕ` using `forward_comp` and `nullity` gives `F.TaskRel (σ s) k (σ (s+k))` (i.e. `Rₖ = R₁ᵏ`),
  and `converse` covers negative differences. So every bi-infinite `R₁`-walk is a **total**
  `WorldHistory`.
- **`FwdRec` is `AllRec`** (`Bridge.allRec_of_fwdRec`): in `ℤ` the covering pairs are exactly
  `(n-1) ⋖ n`, and instantiating `FwdRec`'s second-order `A` at
  `fun w => ∃ m, n < m ∧ σ m = w` reads off the recurrence.

Hence (`Bridge.hist_periodic`): **over `D = ℤ`, `FwdRec F` implies every total history of `F` is
periodic.** That is E2, answered.

`Bridge.hist_deterministic` records the sharper structural fact at frame level: under `FwdRec`,
two total histories agreeing at one time agree one step later.

### 3.2 The `□` case, and why report 02's E1 is not needed

Report 02 §9 scoped Phase **E1** as "generalise `truthAt_add_period` to a per-history period *for
`□`-free formulas*", requiring a new `Formula.BoxFree` predicate. That restriction turns out to be
unnecessary. `LoopingDuration.truthAt_add_period` needs a *frame-uniform* period precisely because
its `□` case reaches into other histories, which may have other periods. But the tree already
proves

```lean
theorem Truth.box_time_const (M : TaskModel F) (τ : WorldHistory F) (hτ : τ.IsTotal) (t s : D)
    (φ : Formula) : TruthAt M τ t φ.box ↔ TruthAt M τ s φ.box
```

(`Semantics/Truth.lean:757`) — a boxed formula's truth value is a constant of the model, by
time-homogeneity. So the `□` case of a per-history induction is discharged outright, with no
appeal to the other histories' periods at all. The probe's

```lean
theorem truthAt_add_hist_period (M : TaskModel F) (τ : WorldHistory F) (hτ : τ.IsTotal) {π : D}
    (hper : ∀ x, τ.states (x + π) _ = τ.states x _) :
    ∀ (φ : Formula) (t : D), TruthAt M τ t φ ↔ TruthAt M τ (t + π) φ
```

holds over an **arbitrary** `D` and for **every** formula. `density_of_hist_periodic` then gives
the full schema from per-history periods, again over arbitrary `D`, in eight lines.

**Replace Phase E1 in report 02 §9 with this.** It is shorter, it is not restricted to `□`-free
formulas, and it needs no new syntax predicate.

### 3.3 The result

```lean
theorem Bridge.density_schema_iff_fwdRec (F : TaskFrame ℤ) :
    (∀ (φ : Formula) (M : TaskModel F) (τ : WorldHistory F), τ.IsTotal → ∀ t : ℤ,
        TruthAt M τ t (φ.allFuture.allFuture.imp φ.allFuture)) ↔ Corr.FwdRec F
```

`⟹` is the atomic biconditional applied at `φ := atom p`. `⟸` is
`hist_periodic` → `density_of_hist_periodic`. Both directions machine-checked.

---

## 4. The caveat: periodicity is specific to `D ≅ ℤ` — **[paper]**

E2 was posed "over a non-dense `D`". The proof above is over `ℤ`, and the restriction is not
cosmetic: **the periodicity conclusion is false over a general non-dense `D`.**

Let `D = ℤ ×ₗ ℤ` (lexicographic, first coordinate dominant). `D` is a nontrivial totally ordered
abelian group with least positive element `p = (0,1)`; its covering pairs are exactly
`t ⋖ t + p`. Write `column(a) := {(a, n) : n ∈ ℤ}`.

Take report 02 §5.1's carrier `W := ⊔_{n ≥ 1} ℤ/nℤ`, and define

- `R_{(0,k)} :=` the `k`-fold cyclic successor within each component (a permutation of `W`);
- `R_{(a,b)} :=` the **full** relation `W × W`, for every `a > 0`;
- negative durations by `converse`; `R_0 = id`.

*Legality* — `nullity_identity` ✓; `comp` ✓ (composing a permutation with the full relation on
either side is the full relation, and the permutations compose exactly); `serial` ✓ (permutations
and the full relation are total and surjective); `limit` ✓ **vacuously**, by §1.1's least-positive
argument; `spherical` ✓ by the singleton/`univ` route, since every fibre is a singleton (durations
inside a column) or all of `W`.

*Histories* — task-respect constrains a history only **within** a column, where it is the orbit of
`R_p`; across columns the relation is full, so columns are independent. A history is therefore a
free choice, per column `a`, of a component `m_a ≥ 1` and a starting residue.

*`FwdRec` holds* — at `t = (a, n)` the state recurs at `t + m_a · p > t`, inside its own column.

*But some history has no period.* Choose `m_a := |a| + 1`, so distinct columns use **distinct
components**. Let `π > 0` be a candidate period, `π = (c, m)` with `c ≥ 0`.
 - `c = 0`: `σ(x + (0,m)) = σ(x)` for all `x` forces `m_a ∣ m` for every `a` — impossible, the
   `m_a` are unbounded.
 - `c > 0`: `σ((a,n) + π)` lies in component `m_{a+c}`, `σ((a,n))` in component `m_a`; these are
   different summands of `W`, so the values differ.

Hence no period exists, while `FwdRec` holds. **E2's literal statement is false over a general
non-dense `D`.**

### 4.1 Does density still hold on that frame? Probably — but this is **[open]**

Periodicity was a *means*; density is the end. On this frame, density still appears to hold, by
replacing the group translation with an **order automorphism of `(D, <)` that preserves the
history**. For the history above and any `s = (a, n)`, the map

> `T := ` (shift column `a` by `m_a`) ∪ (identity on every other column)

is an order automorphism of `D` — order between columns depends only on the column index, so
permuting within one column is order-preserving — and it preserves `τ` pointwise, because
`R_p^{m_a}` is the identity on column `a`'s component. `T` moves `s` strictly upward. Since `□`
formulas are time-constant (`Truth.box_time_const`) and every other clause is invariant under an
automorphism of `(D, <, τ)`, truth at `s` and at `T s > s` coincides, which is exactly what
density needs at the covering pair below `s`.

That is a sketch, not a proof, and it is a sketch about one frame rather than a general
correspondent. **Recorded as open**: *is `FwdRec F` still equivalent to full-schema density over
an arbitrary non-dense `D`, with "periodic" replaced by "shift-recurrent under an
order-automorphism of `(D,<)` preserving `τ`"?* Call this **E2′**.

---

## 5. What this changes, and what it does not

### 5.1 Amendments to report 02

| Report 02 location | Status | Amendment |
|---|---|---|
| §6 statement of **E2** | **CLOSED — affirmative, at `D = ℤ`** | `FwdRec F → every total history periodic` is proved (`Bridge.hist_periodic`). The digraph form is proved outright (`Walk.periodic`). Replace "I could not turn this into a proof" with the citation. |
| §6 "**If E2 is true**, `FwdRec` is the exact correspondent for the whole schema" | **Confirmed, at `D = ℤ`** | `Bridge.density_schema_iff_fwdRec`, proved. State it at `D = ℤ`, not at arbitrary non-dense `D`. |
| §6 "the frames that survive are precisely those whose `R` is a permutation with all orbits finite" | **Confirmed and sharpened** | The load-bearing half is *determinism* (`Walk.succ_unique`, `Bridge.hist_deterministic`); finiteness of orbits then follows from a single recurrence. |
| §9 Phase **E1** | **Superseded — delete** | `truthAt_add_hist_period` + `Truth.box_time_const` does the job for *all* formulas. No `Formula.BoxFree` predicate is needed; report 01 Phase 2's scoping of one is not required for this. |
| §9 Phase **E2** gate | **Discharged, with a narrower scope than written** | Do not remove the gate; re-aim it at **E2′** (§4.1), i.e. at general non-dense `D`. |
| §10 Risk "**E2 is false**" | **Retire for `D = ℤ`; keep for general `D`** | Over `D = ℤ` the risk is gone. Over general non-dense `D` the *periodicity* route is now known to fail (§4), so anything relying on it must be `ℤ`-scoped. |
| §10 Risk "**Over-reading the atomic biconditional**" | **Partially discharged** | At `D = ℤ` the schema-level claim is now proved and may be stated without the atomic qualifier. At every other `D` the qualifier stands, unchanged. |

**Explicitly unchanged**: the atomic biconditional `Corr.density_iff_fwdRec` over arbitrary `D`;
`fwdRec_of_denselyOrdered`; the frame-valued Tier-0 framing (§3); the differentiation verdict (§5);
the `natFrame` necessity engine (§1.1); the `Interpolates` finding (§2); §§7–8 and all of report 01
that report 02 left standing. Nothing here touches any of them.

### 5.2 Construction-specification delta for `FrameConditions/Correspondence/Density.lean`

Report 02 §9's Phases A–D are unaffected. The new material adds one phase and deletes one:

- **Phase B′ (replaces Phase B and Phase E1, ~90 lines, proof in hand)** —
  `truthAt_add_hist_period` and `density_of_hist_periodic`, lifted from `03_probes.lean` §Probe I.
  Stated over arbitrary `D`, for every formula. Strictly subsumes report 02's Phase B
  (`density_of_loopingDuration` is the special case where the per-history period is frame-uniform),
  so Phase B may be kept for its `clockFrame` corollary or dropped. Imports
  `Semantics/Truth.lean` only — **this removes report 02's flagged import-direction question**,
  since `Metalogic/Independence/LoopingDuration` is no longer needed.
- **Phase E2 (new, ~330 lines, proof in hand)** — the walk theory (`03_probes.lean` §Probe H:
  `IsWalk`, `AllRec`, `per`, `MinCyc`, `exists_minCyc`, `minCyc_mem`, `succ_unique`, `det`,
  `periodic`) plus the bridge (§Probe J: `step`, `taskRel_nat`, `taskRel_diff`, `ofWalk`,
  `hist_isWalk`, `allRec_of_fwdRec`, `hist_periodic`, `hist_deterministic`,
  `density_schema_iff_fwdRec`). *Risk: none — it compiles today.*
  The walk theory is carrier- and frame-agnostic and arguably belongs in its own file
  (`FrameConditions/WalkRecurrence.lean`), since nothing in it mentions `TaskFrame`.
- **Also worth lifting**: `freeFrame` (§Probe G). The tree currently has `natFrame` at `W = ℕ`
  only; `freeFrame` generalises it to any nonempty carrier at zero proof cost, and gives finite
  permissive frames (`freeFrame Bool`, `freeFrame (Fin n)`) that any future refutation over `ℤ`
  will want.

---

## 6. Risks

| Risk | Assessment |
|---|---|
| **Reading §3.3 as a claim about arbitrary non-dense `D`** | It is not. §4 gives an explicit `FwdRec` frame over `ℤ ×ₗ ℤ` with an aperiodic history. Any transcription must carry the `D = ℤ` binder. |
| **The `ℤ ×ₗ ℤ` counterexample is paper-only** | §4 is argued, not formalised (~150 lines to formalise: `Prod.Lex` instances plus the `⊔ℤ/nℤ` frame). Nothing in §§1–3 depends on it; it functions purely as a scope limit on §3.3, and the limit is the conservative direction. |
| **E2′ left open** | §4.1's automorphism argument is a sketch about one frame. Do not let a plan state a general-`D` full-schema correspondent. |
| **`Walk.*` naming** | Provisional, as `FwdRec` was. The walk theory is a general digraph result with no bimodal content; keep it out of both `Valid*` and `Corr*` namespaces. |
| **Copied definitions drifting** | `03_probes.lean` copies `Covers` / `FwdRec` / `density_iff_fwdRec` verbatim from `02_probes.lean`. On transcription into `FrameConditions/`, there must be exactly **one** copy; the probe duplication is an artefact of probe files not being Lake modules. |

---

## 7. Answer to the Dispatched Question, in One Line

**[E2] Over a non-dense `D`, does `FwdRec F` imply that every total history of `F` is periodic?**

> **At `D = ℤ`: YES — proved** (`Bridge.hist_periodic`), via the digraph theorem `Walk.periodic`,
> whose real content is that `AllRec` forces the one-step relation to be **deterministic**
> (`Walk.succ_unique`, by a minimal-closed-walk splicing argument). Consequently `FwdRec` is the
> **exact correspondent for the full density schema over `ℤ`**
> (`Bridge.density_schema_iff_fwdRec`, both directions machine-checked, all formulas). The lead's
> full-2-shift frame is legal (`freeFrame Bool`) — so the digraph reduction is faithful and `limit`
> is not the mechanism — but it fails `FwdRec` on the one-off walk `… a a a b a a a …`, so it was
> never a counterexample. **Over a general non-dense `D` the periodicity conclusion is FALSE**
> (`⊔ℤ/nℤ` over `ℤ ×ₗ ℤ`, §4, [paper]); whether full-schema exactness survives there with
> "periodic" weakened to "shift-recurrent under a history-preserving order automorphism" is
> recorded as the new open item **E2′**.
