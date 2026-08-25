# Research: machine-checking the Discrete non-compactness witness

**Task**: 425 — Convert the informal argument in `FormalSystem/Metalogic/StrongCompleteness.lean`
into a machine-checked theorem: the `FrameClass.Discrete` consequence relation is not compact.

**Session**: `sess_1787618565_717c84_425` · **dispatch_seq**: 4 · **type**: lean4

**Headline finding**: the whole proof was constructed and compiled sorry-free during this
research pass. All three acceptance theorems land, each at exactly
`[propext, Classical.choice, Quot.sound]`. This report carries the verified proof text; the
implementation phase is transcription plus placement, not discovery.

---

## 0. Baseline

| Probe | Result |
|---|---|
| `lake build` at `1f192f3f8` | `Build completed successfully (2462 jobs)`, exit 0 |
| `FormalSystem.Metalogic.StrongCompleteness` olean | present, loadable |
| Toolchain | Lean v4.33.0-rc1, Mathlib tag `v4.33.0-rc1` |

Verification method throughout: scratch files compiled with
`lake env lean <file>` against the built tree. Six probe rounds; the final probe
(`probe6.lean` / `probe7.lean`) contains the complete construction and compiles with **zero
errors, zero warnings, zero sorries**.

---

## 1. Source-fidelity corrections (read before planning)

Two citations in the task description and the governing design document are **stale**. Both are
corrected below; neither changes the mathematics.

### 1.1 `Formula.next` argument order was swapped

The task description and
`specs/archive/361_.../design/02_compactness-route.md` (§"The load-bearing ingredient, verified")
both quote:

```lean
def next (φ : Formula) : Formula := Formula.untl φ Formula.bot   -- STALE
```

The current tree has, at `FormalSystem/Syntax/Formula.lean:511` (**not** `:490`):

```lean
/-- Next-step operator: X(phi) = `untl bot phi`, rendered `U(phi, bot)` in the prefix notation
    (which is event-first, the reverse of the constructor's guard-first arguments). -/
def next (φ : Formula) : Formula := Formula.untl Formula.bot φ
```

The design document predates the uniform `untl`/`snce` argument swap recorded in
`specs/decisions/untl-snce-argument-order.md`. `untl` is now **guard-first, event-second**, so
`next φ = untl (guard := ⊥) (event := φ)`.

**The in-tree docstrings are already correct.** `StrongCompleteness.lean:60` and `:417` both
write `Formula.next φ = Formula.untl Formula.bot φ`. No docstring correction is owed by this
task; only the archived design document and the delegation prompt carry the stale form.

The semantics are unaffected, and the load-bearing reading survives verbatim. The `untl` clause
(`FormalSystem/Semantics/Truth.lean:165`) is

```lean
| Formula.untl ψ φ => ∃ s : D, t < s ∧ TruthAt M τ s φ ∧ ∀ r : D, t < r → r < s → TruthAt M τ r ψ
```

so `TruthAt t (next φ)` is `∃ s > t, φ(s) ∧ ∀ r ∈ (t,s), ⊥` — "`s` is the immediate successor
of `t`". Confirmed by machine-checked `truthAt_next_iff` below.

### 1.2 `StrongCompleteness.lean:56-62` is the correct anchor

Verified. The informal argument sits in the module docstring's per-class programme bullet for
`FrameClass.Discrete` (lines 56-62), and is restated in the reserved section comment at lines
411-421. Both survive as prose; this task adds the theorems the prose promises.

---

## 2. What is missing from the tree

`FormalSystem/Metalogic/SetConsequence.lean` supplies `SetSemanticConsequenceDiscrete`
(`:85`) but the satisfiability/compactness vocabulary exists **only for Dense**:
`SatisfiableDenseSet` (`:207`), `CompactDense` (`:199`), `ModelExistenceDense` (`:219`),
`StrongCompletenessDense` (`:192`). The Discrete analogues named in the acceptance criteria —
`SatisfiableDiscreteSet`, `CompactDiscrete` — do not exist and must be added.

Also absent tree-wide: any semantic characterisation of `Formula.next`. Grep for `next_iff`,
`untl_bot`, and a `TruthAt … (Order.succ t)` shape returns nothing under `FormalSystem/`. The
only `Formula.next` results are proof-theoretic (`FormalSystem/Theorems/DiscreteUnfolding.lean`).
So `truthAt_next_iff` is genuinely new.

---

## 3. Verified proof, layer by layer

Everything in this section compiled. Line-for-line reusable.

### Layer 0 — vocabulary (destined for `SetConsequence.lean`)

Mirrors `SatisfiableDenseSet` / `CompactDense` exactly, with `ValidDiscrete`'s binder list
(`FormalSystem/Semantics/Validity.lean:243`) in place of `ValidDense`'s.

```lean
def SatisfiableDiscreteSet (Γ : Set Formula) : Prop :=
  ∃ (D : Type) (_ : AddCommGroup D) (_ : LinearOrder D) (_ : IsOrderedAddMonoid D)
    (_ : SuccOrder D) (_ : PredOrder D) (_ : IsSuccArchimedean D) (_ : IsPredArchimedean D)
    (_ : Nontrivial D)
    (F : TaskFrame D) (M : TaskModel F)
    (τ : WorldHistory F) (_ : τ.IsTotal) (t : D),
    ∀ ψ ∈ Γ, TruthAt M τ t ψ

def CompactDiscrete : Prop :=
  ∀ (Γ : Set Formula) (φ : Formula), SetSemanticConsequenceDiscrete Γ φ →
    ∃ L : List Formula, (∀ ψ ∈ L, ψ ∈ Γ) ∧ ValidDiscrete (L.foldr Formula.imp φ)
```

**Verified risk, resolved**: the five extra class binders written as anonymous existential
binders (`(_ : SuccOrder D)` needs `Preorder D` from the earlier `(_ : LinearOrder D)`;
`IsSuccArchimedean D` needs both) elaborate without complaint, and — the non-obvious half —
**destructuring them with `rintro`/`obtain` using `_` names makes them available to instance
synthesis**. Both `archWitness_not_satisfiable` and `discrete_consequence_not_compact` depend on
this and compile.

**Anti-pattern found the hard way**: naming the destructured instances (`rintro ⟨D, i1, i2, …⟩`)
and then re-installing them with `haveI := i1` **breaks the build** — `haveI` drops the value, so
the re-synthesised instance is no longer defeq to the one baked into `F`/`M`'s types
("synthesized type class instance is not definitionally equal…"). Use bare `_` binders and let
synthesis find the originals. Do not "helpfully" add `haveI` lines.

### Layer 1 — the next-step truth lemmas

```lean
variable {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]

theorem truthAt_next_iff [SuccOrder D] [NoMaxOrder D]
    {F : TaskFrame D} (M : TaskModel F) (τ : WorldHistory F) (t : D) (φ : Formula) :
    TruthAt M τ t (Formula.next φ) ↔ TruthAt M τ (Order.succ t) φ := by
  constructor
  · rintro ⟨s, hts, hs, hgap⟩
    have h1 : Order.succ t ≤ s := Order.succ_le_of_lt hts
    rcases lt_or_eq_of_le h1 with h | h
    · exact absurd (hgap (Order.succ t) (Order.lt_succ t) h) not_false
    · exact h ▸ hs
  · intro h
    exact ⟨Order.succ t, Order.lt_succ t, h, fun r hr hrs =>
      absurd hr (not_lt.mpr (Order.le_of_lt_succ hrs))⟩

theorem truthAt_next_iterate [SuccOrder D] [NoMaxOrder D]
    {F : TaskFrame D} (M : TaskModel F) (τ : WorldHistory F) :
    ∀ (n : ℕ) (t : D) (φ : Formula),
      TruthAt M τ t (Formula.next^[n] φ) ↔ TruthAt M τ (Order.succ^[n] t) φ := by
  intro n
  induction n with
  | zero => intro t φ; simp
  | succ k ih =>
    intro t φ
    rw [Function.iterate_succ_apply, ih, Function.iterate_succ_apply']
    exact truthAt_next_iff M τ _ φ
```

Note the asymmetric rewrite in the inductive step: `iterate_succ_apply` on the **formula** side
(`next^[k+1] φ = next^[k] (next φ)`) and `iterate_succ_apply'` on the **time** side
(`succ^[k+1] t = succ (succ^[k] t)`). Using the same one on both sides does not close
(measured: type mismatch at the `exact`).

`NoMaxOrder D` is **inferrable** from the Discrete binder list — machine-checked:

```lean
example (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [SuccOrder D]
    [PredOrder D] [IsSuccArchimedean D] [IsPredArchimedean D] [Nontrivial D] :
    NoMaxOrder D := inferInstance   -- ✓
```

This matches the existing in-tree precedent at `FormalSystem/Metalogic/Soundness.lean:420`
(`have _h_nomax : NoMaxOrder T := inferInstance`) and `:433`.

### Layer 2 — the witness set and its index function

```lean
def archWitness (p : Atom) : Set Formula :=
  {(Formula.atom p).someFuture} ∪ {ψ | ∃ n : ℕ, ψ = (Formula.next^[n] (Formula.atom p)).neg}

def nextDepth : Formula → ℕ
  | Formula.untl Formula.bot φ => nextDepth φ + 1
  | _ => 0

def witIdx : Formula → ℕ
  | Formula.imp χ Formula.bot => nextDepth χ
  | _ => 0

theorem nextDepth_next_iterate (p : Atom) (n : ℕ) :
    nextDepth (Formula.next^[n] (Formula.atom p)) = n := by
  induction n with
  | zero => simp [nextDepth]
  | succ k ih => rw [Function.iterate_succ_apply']; simp [Formula.next, nextDepth, ih]

theorem witIdx_neg_next_iterate (p : Atom) (n : ℕ) :
    witIdx ((Formula.next^[n] (Formula.atom p)).neg) = n := by
  simp [Formula.neg, witIdx, nextDepth_next_iterate]
```

**Why an index function is needed at all.** `archWitness_finitely_satisfiable` receives an
arbitrary `L : List Formula` with `∀ ψ ∈ L, ψ ∈ archWitness p` and must produce a *single*
threshold `N` beyond which to place `p`. Membership only gives `∃ n, ψ = ¬Xⁿ p` per element;
`witIdx` turns that existential into a computable index so the threshold can be taken as a max
over `L`.

**Do not use `Formula.complexity`** (`FormalSystem/Syntax/Formula.lean:224`) as the size measure. It is
pattern-aware — it special-cases `always`, `sometimes`, `weakFuture`, `weakPast` expansions and
charges them overhead 1 — so it is not a monotone structural size and gives no usable bound.

**Bound extraction, verified**: use `(L.map witIdx).sum` as `N` and Mathlib's
`List.single_le_sum (fun _ _ => Nat.zero_le _)` for `witIdx ψ ≤ N`. Simpler than a `foldr max`
helper, and it needs no auxiliary lemma.

### Layer 3 — the ℤ model

`TaskFrame.natFrame` (`FormalSystem/Semantics/TaskFrame.lean:1288`) is the right frame off the
shelf: `WorldState := Nat`, permissive relation `TaskRel w d u := d ≠ 0 ∨ w = u`, all four
`def:frame` axioms discharged, binders `[SuccOrder D] [NoMaxOrder D]` supplied by `ℤ`. Because
the relation is permissive, an **arbitrary** state function respects it, which is exactly what a
non-constant history needs. (`WorldHistory.universalNatFrame` is constant-state and therefore
useless here; `staticFrame` is worse — its relation forces constant histories.)

```lean
def zHistory (N : ℤ) : WorldHistory (TaskFrame.natFrame (D := ℤ)) where
  domain := fun _ => True
  nonempty_domain := ⟨0, True.intro⟩
  convex := fun _ _ _ _ _ _ _ => True.intro
  states := fun t _ => (if N < t then 1 else 0 : Nat)
  respects_task := by
    intro s t _ _
    rcases eq_or_ne t s with rfl | hne
    · right; rfl
    · left; exact sub_ne_zero.mpr hne

def zModel : TaskModel (TaskFrame.natFrame (D := ℤ)) where
  valuation := fun (w : Nat) _ => w = 1

theorem zHistory_total (N : ℤ) : (zHistory N).IsTotal := fun _ => True.intro

theorem zTruth_atom (N : ℤ) (p : Atom) (t : ℤ) :
    TruthAt zModel (zHistory N) t (Formula.atom p) ↔ N < t := by
  constructor
  · rintro ⟨_, h⟩
    simp only [zModel, zHistory] at h
    by_contra hc
    simp [hc] at h
  · intro h
    exact ⟨True.intro, by simp only [zModel, zHistory]; simp [h]⟩

theorem succ_iterate_zero_int (n : ℕ) : Order.succ^[n] (0:ℤ) = (n : ℤ) := by
  induction n with
  | zero => simp
  | succ k ih => rw [Function.iterate_succ_apply', ih]; simp [Order.succ_eq_add_one]
```

**Elaboration trap, resolved.** `TaskFrame.natFrame.WorldState` does not reduce far enough for
numeral elaboration: writing `1` or `0` at that expected type fails with
`failed to synthesize OfNat TaskFrame.natFrame.WorldState 1`. Two fixes are needed and both are
in the text above:

- `states := fun t _ => (if N < t then 1 else 0 : Nat)` — ascribe the *body* to `Nat`.
- `valuation := fun (w : Nat) _ => w = 1` — annotate the **lambda binder**. Note that
  `fun w _ => (w : Nat) = 1` does **not** work (ascription on an existing fvar does not retarget
  numeral elaboration); the binder annotation does.

ℤ instances all present, machine-checked: `SuccOrder ℤ`, `PredOrder ℤ`, `IsSuccArchimedean ℤ`,
`IsPredArchimedean ℤ`, `IsOrderedAddMonoid ℤ`, `NoMaxOrder ℤ`, `Nontrivial ℤ`.

### Layer 4 — the three acceptance theorems

```lean
theorem archWitness_finitely_satisfiable (p : Atom) (L : List Formula)
    (hL : ∀ ψ ∈ L, ψ ∈ archWitness p) : SatisfiableDiscreteSet {ψ | ψ ∈ L} := by
  classical
  refine ⟨ℤ, inferInstance, inferInstance, inferInstance, inferInstance, inferInstance,
    inferInstance, inferInstance, inferInstance, TaskFrame.natFrame, zModel,
    zHistory ((L.map witIdx).sum : ℕ), zHistory_total _, 0, ?_⟩
  set N : ℕ := (L.map witIdx).sum with hNdef
  intro ψ hψ
  have hmem := hL ψ hψ
  simp only [archWitness, Set.mem_union, Set.mem_singleton_iff, Set.mem_setOf_eq] at hmem
  rcases hmem with rfl | ⟨n, rfl⟩
  · -- F p : place the witness at N + 1
    refine ⟨(N : ℤ) + 1, by positivity, ?_, fun r _ _ => id⟩
    exact (zTruth_atom _ p _).mpr (by omega)
  · -- ¬ Xⁿ p, with n ≤ N
    have hn_le : n ≤ N := by
      have : witIdx ((Formula.next^[n] (Formula.atom p)).neg) ∈ L.map witIdx :=
        List.mem_map_of_mem hψ
      have hle := List.single_le_sum (fun _ _ => Nat.zero_le _) _ this
      rwa [witIdx_neg_next_iterate] at hle
    intro hcon
    have := (truthAt_next_iterate zModel (zHistory (N:ℤ)) n 0 (Formula.atom p)).mp hcon
    rw [succ_iterate_zero_int] at this
    have := (zTruth_atom _ p _).mp this
    omega

theorem archWitness_not_satisfiable (p : Atom) : ¬ SatisfiableDiscreteSet (archWitness p) := by
  rintro ⟨D, _, _, _, _, _, _, _, _, F, M, τ, hτ, t, h⟩
  haveI : NoMaxOrder D := inferInstance
  have hF : TruthAt M τ t ((Formula.atom p).someFuture) := by
    apply h; simp [archWitness]
  obtain ⟨s, hts, hs, -⟩ := hF
  obtain ⟨n, hn⟩ := (Order.succ_le_of_lt hts).exists_succ_iterate
  have hs' : TruthAt M τ (Order.succ^[n + 1] t) (Formula.atom p) := by
    rw [Function.iterate_succ_apply, hn]; exact hs
  have hX : TruthAt M τ t (Formula.next^[n + 1] (Formula.atom p)) :=
    (truthAt_next_iterate M τ (n + 1) t _).mpr hs'
  have hneg : TruthAt M τ t ((Formula.next^[n+1] (Formula.atom p)).neg) := by
    apply h; right; exact ⟨n + 1, rfl⟩
  exact hneg hX

theorem discrete_consequence_not_compact : ¬ CompactDiscrete := by
  intro hc
  classical
  set p : Atom := ⟨"p", none⟩ with hp
  have hcons : SetSemanticConsequenceDiscrete (archWitness p) Formula.bot := by
    intro D _ _ _ _ _ _ _ _ F M τ hτ t hall
    exact absurd
      ⟨D, inferInstance, inferInstance, inferInstance, inferInstance, inferInstance,
        inferInstance, inferInstance, inferInstance, F, M, τ, hτ, t, hall⟩
      (archWitness_not_satisfiable p)
  obtain ⟨L, hL, hvalid⟩ := hc _ _ hcons
  obtain ⟨D, _, _, _, _, _, _, _, _, F, M, τ, hτ, t, hsat⟩ :=
    archWitness_finitely_satisfiable p L hL
  have hv := hvalid D F M τ hτ t
  exact (truthAt_foldr_imp M τ t L Formula.bot).mp hv (fun ψ hψ => hsat ψ hψ)
```

The reachability step is `(Order.succ_le_of_lt hts).exists_succ_iterate` — the same idiom the
tree already uses at `FormalSystem/Metalogic/SoundnessLemmas/FrameClassVariants.lean:748`,
`:767`, `:828`, `:865`, `:877`. This is where `IsSuccArchimedean` does its work.

`Atom` is a plain structure (`FormalSystem/Syntax/Atom.lean:75`, fields `base : String`,
`freshIndex : Option Nat`), so `⟨"p", none⟩` is a legitimate concrete atom; no `Nonempty Atom`
plumbing is needed.

### Axiom audit — measured

```
'archWitness_finitely_satisfiable' depends on axioms: [propext, Classical.choice, Quot.sound]
'archWitness_not_satisfiable'      depends on axioms: [propext, Classical.choice, Quot.sound]
'discrete_consequence_not_compact' depends on axioms: [propext, Classical.choice, Quot.sound]
'truthAt_next_iff'                 depends on axioms: [propext, Classical.choice, Quot.sound]
'truthAt_next_iterate'             depends on axioms: [propext, Classical.choice, Quot.sound]
```

Identical to the set carried by `completeness_dense` / `completeness_discrete` /
`consequence_completeness_dedekind`. Acceptance criterion "`#print axioms` clean on each" is met.

---

## 4. Placement

### 4.1 Layer 0 → `FormalSystem/Metalogic/SetConsequence.lean`

Add `SatisfiableDiscreteSet` and `CompactDiscrete` beside their Dense counterparts. The module
docstring's scope sentence ("the statements — not the proofs — of strong completeness,
compactness, satisfiability and model existence for `FrameClass.Dense`") must be widened to name
Discrete, **and** must record the asymmetry that matters: `CompactDense` names an open
obligation, whereas `CompactDiscrete` is *refuted* downstream. No import change is required —
`IsSuccArchimedean` is already in scope there via `SetSemanticConsequenceDiscrete`.

### 4.2 Layers 1-4 → a new module downstream of `StrongCompleteness.lean`

Recommended: `FormalSystem/Metalogic/DiscreteNonCompactness.lean`, with
`import FormalSystem.Metalogic.StrongCompleteness`, registered in `FormalSystem/Metalogic.lean`'s
re-export list (which currently imports `StrongCompleteness` at `:9`).

**Why downstream, not inside `StrongCompleteness.lean`.** The final theorem consumes
`truthAt_foldr_imp`, which lives in `StrongCompleteness.lean:148`. Placing the witness inside
`SetConsequence.lean` is therefore impossible without an import cycle — the same constraint that
already forced `strongCompletenessDense_of_compact` upward (recorded in `SetConsequence.lean`'s
"Downstream" section). Placing it inside `StrongCompleteness.lean` would work, but pulls a
concrete ℤ frame/model/history construction into the module that hosts the completeness
statements; a separate module keeps that boundary and keeps the rebuild blast radius to the new
file plus the aggregator.

**Where `truthAt_next_iff` / `truthAt_next_iterate` ideally belong.** They are pure semantics
with no completeness content, and `FormalSystem/Semantics/Truth.lean` already hosts the
`Truth` namespace of `@[simp]` characterisation theorems (`some_future_iff` `:250`,
`future_iff` `:286`, `past_iff` `:305`, …) — a `Truth.next_iff` would sit there naturally, and
the needed `SuccOrder`/`NoMaxOrder` are already in scope transitively via `TaskFrame.lean`'s
`import Mathlib.Order.SuccPred.Basic` (no new import). The cost is that `Truth.lean` is near the
root, so editing it triggers a full-tree rebuild. **Recommendation**: land them in the new
module for this task, with a docstring note that promotion to `Semantics/Truth.lean` is the
natural home once a second consumer appears. This is a judgement call the planner may reverse;
both placements compile.

Do **not** mark `truthAt_next_iff` `@[simp]` — it would rewrite `next` occurrences inside the
proof-theoretic `DiscreteUnfolding.lean` reasoning if the lemma ever moves upstream.

---

## 5. Optional fourth theorem (recommended, cheap)

The task sentence says "…hence strong completeness is refuted for that class", but the
acceptance list names only three theorems. The refutation itself is ~6 lines on top of what is
already proved, because `soundness_discrete` (`FormalSystem/Metalogic/Soundness.lean:1393`)
has precisely the binder list `SatisfiableDiscreteSet` unpacks to:

```lean
def StrongCompletenessDiscrete : Prop :=          -- new, beside StrongCompletenessDense
  ∀ (Γ : Set Formula) (φ : Formula),
    SetSemanticConsequenceDiscrete Γ φ → SetDerivable FrameClass.Discrete Γ φ

theorem strongCompletenessDiscrete_refuted : ¬ StrongCompletenessDiscrete
-- take Γ = archWitness p, φ = ⊥; the finitary derivation cites some L ⊆ Γ; feed
-- archWitness_finitely_satisfiable's model to soundness_discrete L ⊥ to derive TruthAt … ⊥.
```

Marked **optional**: it adds vocabulary surface (`StrongCompletenessDiscrete`) beyond the stated
acceptance set. It was not compiled in this pass — unlike everything in §3, it is a sketch. If
the planner includes it, budget one short phase and verify rather than assume.

---

## 6. Scope boundary honoured

No Dedekind non-compactness witness is proposed, researched, or sketched anywhere in this
report. The design document's "Not recommended here" directive and the task's explicit
out-of-scope clause both hold: that class's non-compactness is already established and the work
belongs to a separate in-flight task.

---

## 7. Suggested phase decomposition

| Phase | Content | Files | Verification |
|---|---|---|---|
| 1 | `SatisfiableDiscreteSet`, `CompactDiscrete` + docstring widening | `Metalogic/SetConsequence.lean` | `lake build` |
| 2 | New module skeleton + `truthAt_next_iff`, `truthAt_next_iterate` | `Metalogic/DiscreteNonCompactness.lean`, `Metalogic.lean` | `lake build`, `#print axioms` |
| 3 | `archWitness`, `nextDepth`, `witIdx` + their two index lemmas; ℤ model (`zHistory`, `zModel`, `zTruth_atom`, `succ_iterate_zero_int`) | same module | `lake build` |
| 4 | The three acceptance theorems + `#print axioms` block | same module | `lake build`, three axiom lines |
| 5 *(optional)* | `StrongCompletenessDiscrete` + `strongCompletenessDiscrete_refuted` | `SetConsequence.lean` + new module | `lake build`, `#print axioms` |

Each phase is well under one agent run. Phases 2-4 are transcription of verified text.

---

## 8. Zero-debt statement

No `sorry` is required at any point, no new axiom is required, and no approach in this report
defers any obligation. The complete proof exists and compiles. If an implementation run finds
otherwise, the discrepancy is a transcription error against §3, not a mathematical gap — the
scratch probe is reproducible with `lake env lean` against the built tree.

---

## Appendix: verification log

| Probe | What it settled | Outcome |
|---|---|---|
| 1 | `NoMaxOrder` inferrable at Discrete binders; ℤ instances; `SatisfiableDiscreteSet` shape elaborates; `nextDepth` equation compiler; `List.single_le_sum` | all pass |
| 2 | `truthAt_next_iff`, `truthAt_next_iterate` | pass (after fixing the asymmetric `iterate_succ_apply` / `iterate_succ_apply'` rewrite) |
| 3 | ℤ model | `OfNat … WorldState` failure found |
| 4 | ℤ model, corrected | pass |
| 5 | full assembly | `haveI`-defeq failure + `truthAt_foldr_imp` import gap found |
| 6 | full assembly, corrected (import `StrongCompleteness`, bare `_` instance binders) | **zero errors, zero warnings** |
| 7 | `#print axioms` on all five | `[propext, Classical.choice, Quot.sound]` throughout |
