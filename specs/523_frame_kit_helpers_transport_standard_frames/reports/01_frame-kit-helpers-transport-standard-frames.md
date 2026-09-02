# Research Report: Frame Kit Helpers, Truth Transport, Standard Frames

- **Task**: 523 — WAVE 2 (core utilities)
- **Type**: lean4
- **Date**: 2026-09-02
- **Baseline**: `lake build` green at HEAD (`fea304614`, 2517 jobs, exit 0)
- **Review source**: `specs/reviews/2026-09-01-lean-engineering/{C-frames,A-soundness}.md`

## Executive summary

Every one of the task's nine work items is grounded in a real, verified duplication. The
mathematics is sound and the helpers are constructible — two of them (Helper D and the Helper B
completion) were **written and compiled against the live tree during this research**, with clean
axiom profiles (see §3.1 and §3.2 for the verbatim, elaborating text).

But a substantial fraction of the measured-state paragraph has drifted, and three of its claims
are now wrong in ways that change the plan:

1. **`Spherical` no longer exists.** Task 517's rename landed; `grep -rn Spherical FormalSystem`
   returns **zero** hits. Every finding, helper name and acceptance phrase in the task
   description that says "Spherical" must be read as **`Saturation`**. The proposed helper is
   `saturation_of_fib_subsingleton`, not `spherical_of_fib_subsingleton`.
2. **C-05 has already landed** (task 521, phase 6). The four atom-truth lemmas are `@[simp]` and
   the eight-site `rw [show τ.val = … from rfl]` idiom is gone from `DurationFrames.lean`. Item
   C-05 should be struck from this task's scope.
3. **The acceptance criterion "exactly one `induction φ` truth-transport proof in `Semantics/` +
   `Independence/`" is not achievable**, for a mathematical reason, not an effort reason. See
   §4.3. Recommend restating it as **"at most two"**.

Two hard constraints that no plan may violate are recorded in §7.

---

## 1. Stale-figure ledger

Every figure in the measured-state paragraph, checked. **Bold** rows are materially wrong, not
merely drifted.

| Claim | Measured state (task) | Verified current state |
|---|---|---|
| Axiom name | "Spherical" | **`Saturation` / `Saturated`** — zero `Spherical` occurrences tree-wide |
| Generic helper A | `TaskFrame.lean:977` | `:982` `sInter_nonempty_of_directed_of_univ_or_singleton` (`:977` is inside its docstring) |
| Generic helper B | `Algebraic/FlowFrame.lean:116` | `:116-127` `Algebraic.sInter_nonempty_of_directed_subsingleton` — exact |
| Helper B block | `TaskFrame.lean:1129-1235` | `:1134-1241` |
| Helper C block | `:1237-1295` | `:1242-1299` |
| `natFrame` | `:1449` | `:1454` |
| Site: ClockFrame | `:156` | `:156-165` `clockRel_saturation` — exact |
| Site: DurationFrames | `:163` | **`:155-165`** (`:163` is a branch inside the block) |
| Site: RegionFrame | `:208`, `:295` | `:208-222`, `:295-307` — exact |
| Site: ReynoldsBridge | `:464`, `:522`, `:784` | **`:465-474`, `:523-529`, `:785-794`** (+1) |
| Site: ShiftSet | `:186` | `:186-202` — exact |
| Saturation-site census | "seven sites" | **Seven duplicated bodies confirmed, but ten saturation declarations exist**; `ClockFrame:209` and `ReynoldsBridge:835` are already one-line citations |
| `time_shift_preserves_truth` | `Truth.lean:450`, 236 lines | **`:655-887`, 233 lines** (task 521 inserted ~205 lines above it) |
| `truthAt_map` | `IntTransfer.lean:292` | `:292-363`, 72 lines — exact |
| `truthAt_add_hist_period` | `FwdRecPeriodicity.lean:356` | `:356-420`, 65 lines — exact |
| `truthAt_add_period` | `LoopingDuration.lean:98` | `:98-165`, 68 lines — exact |
| `truthAt_mirror` | `CoNotPriorU.lean:416` | **`:406-485`**, 80 lines |
| Transport total | "~370 lines" | **~518 lines** (233+72+65+68+80). The review's "`time_shift_preserves_truth` (~90 lines of proof)" is the stale figure; the task's 236 was close |
| Z dictionary | `FwdRecBridge.lean:61-115` vs `IntNormalForm.lean:177-345` | Confirmed, both ranges accurate |
| Total-history boilerplate | "six copies" | **Six in `Semantics/` confirmed** (`WorldHistory.lean:152,172,193,215`; `ShiftSet.lean:214`; `IntNormalForm.lean:310`) — **plus ~12 more outside `Semantics/`** |
| "Least positive ⟹ successor" ×4 | four copies | **Real, but two distinct directions**: 2 sites of the converse (not covered by U7) + 3 sites of the forward direction (covered). See §4.6 |
| `WorldHistory.lean` dead lemmas | `:382-444`, four | Confirmed: `neg_lt_neg_iff` `:399`, `neg_le_neg_iff` `:416`, `neg_neg_eq` `:430`, `neg_injective` `:436` — **all four have exactly 1 repo occurrence (their own declaration)** |
| A-06 pairs | `:400/440`, `:479/541`, ~90 lines | **`:780/821` (`prior_UZ_valid`/`prior_SZ_valid`) and `:861/924` (`z1_valid`/`z1_past_valid`), 184 lines** |
| A-06 names | "prior_SZ_is_valid", "z1_past_is_valid" | **`prior_SZ_valid`, `z1_past_valid`** (no `_is_`) |
| Separability D-op recipe | `:270/324` | **`sep_order` `:261-…`, `sep_order_mirror` `:…-354`** |
| Frame constants | "fourteen in nine files" | **22 frame-valued `def`s across 15 files** (full table in §5) |
| `Semantics.lean` gaps | "fixed by an already-landed task" | **NOT fixed.** `LexCarrier`, `BLSchemaValidity` and **`Extension/PeriodicExtension`** are still un-imported |
| `Semantics/README.md` | omits TemporalOrder/FrameProperty/FrameClassValidity | Confirmed **for the README only** — `Semantics.lean` itself imports all three |
| `Independence.lean` "one result" | `:17-19` above a six-module list | Confirmed, docstring `:14-42` |
| TaskFrame regression sections | five overlapping | Confirmed: `:1778-1793`, `:1804-1825`, `:1834-1852`, `:1866-1890`, `:1899-1924` (108 example lines) |
| C-05 (atom-truth `@[simp]`) | in scope | **Already landed by task 521** — all four lemmas are `@[simp]`; zero `rw [show … from rfl]` in `DurationFrames.lean` |
| `SoundnessLemmas/DiscreteOrder.lean` | to be created | Confirmed absent; the directory holds only `CoValidity` (113), `FrameClassVariants` (975), `Separability` (354) |

**Sequencing claim verified**: both prerequisites landed. Task 517 (Saturation rename) and task
521 (truth simp-normal form) are committed; task 522's changes (`FrameClass.Sat` reducible,
`IsDense` abbrev, 47→21 adapters, `sat_intro`, `ValidDedekind` renames) are present at HEAD.

---

## 2. Territory map (current, verified)

| File | Lines | Role in this task |
|---|---|---|
| `FormalSystem/Semantics/TaskFrame.lean` | 1926 | Helpers A/B/C/D; frame constants; 5 regression sections |
| `FormalSystem/Semantics/Truth.lean` | 1062 | `time_shift_preserves_truth`, `truth_double_shift_cancel`; home of `TruthIso` |
| `FormalSystem/Semantics/WorldHistory.lean` | 545 | `ofTotal`; 8 dead lemmas; `time_shift_*` rename |
| `FormalSystem/Semantics/IntNormalForm.lean` | 537 | Upstream Z step-path dictionary |
| `FormalSystem/Semantics/Correspondence/DurationFrames.lean` | 526 | `translationFrame`, `permissiveFrame`, one saturation site |
| `FormalSystem/Semantics/ShiftSet.lean` | 521 | Bespoke saturation site (needs rewrite, not re-point) |
| `FormalSystem/Semantics/Correspondence/FwdRecPeriodicity.lean` | 445 | `per_period`; `Walk`/`MinCyc`; one transport |
| `FormalSystem/Semantics/IntTransfer.lean` | 414 | `truthAt_map` + `Aligned` |
| `FormalSystem/Semantics/DurationClassification.lean` | 330 | Home for U7 |
| `FormalSystem/Semantics/Correspondence/FwdRecBridge.lean` | 186 | Duplicate dictionary |
| `FormalSystem/Semantics/LexCarrier.lean` | 153 | Generalise to `α ×ₗ ℤ` |
| `FormalSystem/Semantics.lean` | 207 | Aggregator (3 gaps) |
| `FormalSystem/Metalogic/WeakCanonical/IntegerModel/ReynoldsBridge.lean` | 1350 | 3 saturation sites |
| `FormalSystem/Metalogic/SoundnessLemmas/FrameClassVariants.lean` | 975 | A-06 hand-mirrored pairs |
| `FormalSystem/Metalogic/Algebraic/FlowFrame.lean` | 818 | Duplicate helper to delete |
| `FormalSystem/Metalogic/Decidability/Verified/Bridge/RegionFrame.lean` | 586 | 2 saturation sites |
| `FormalSystem/Metalogic/Independence/CoNotPriorU.lean` | 574 | `truthAt_mirror` (anti-iso) |
| `FormalSystem/Examples/TemporalStructures.lean` | 550 | `genericNatFrame`/`genericTimeFrame` |
| `FormalSystem/Metalogic/SoundnessLemmas/Separability.lean` | 354 | D-op recipe to imitate |
| `FormalSystem/Metalogic/Independence/LoopingDuration.lean` | 273 | `truthAt_add_period` |
| `FormalSystem/Metalogic/Independence/LexIntWitness.lean` | 258 | ~70 lines to delete |
| `FormalSystem/Metalogic/Independence/ClockFrame.lean` | 245 | 1 saturation site |
| `FormalSystem/Metalogic/Independence.lean` | 57 | "one result" docstring fix |

---

## 3. Verified-compiling helper text

Both blocks below were elaborated against the live tree with `lake env lean` on a scratch file
importing `FormalSystem.Semantics.TaskFrame`. **They compile with no errors and no `sorryAx`.**
The implementer should paste them, not re-derive them.

### 3.1 Helper D — the deterministic class (work item 1)

Home: `TaskFrame.lean`, immediately after Helper C (i.e. after current line 1299), inside
`namespace TaskFrame`, under the section header
`/-! ### Helper D — the deterministic class: every fibre is a subsingleton -/`.

```lean
omit [IsOrderedAddMonoid D] in
theorem sInter_nonempty_of_directed_subsingleton {W : Type} {S : Set (Set W)}
    (hdir : DirectedFamily S) (hne : ∀ s ∈ S, s.Nonempty)
    (hsub : ∀ s ∈ S, s.Subsingleton) : (⋂₀ S).Nonempty := by
  obtain ⟨⟨s₀, hs₀⟩, hdir₂⟩ := hdir
  obtain ⟨a, ha⟩ := hne s₀ hs₀
  refine ⟨a, Set.mem_sInter.mpr fun s₁ hs₁ => ?_⟩
  obtain ⟨s', hs', hsub'⟩ := hdir₂ s₀ hs₀ s₁ hs₁
  obtain ⟨b, hb⟩ := hne s' hs'
  have hb₀ : b ∈ s₀ ∩ s₁ := hsub' hb
  have hba : b = a := hsub s₀ hs₀ hb₀.1 ha
  exact hba ▸ hb₀.2

omit [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] in
theorem fib_subsingleton_of_functional {W : Type} {f : W → D → W} {R : W → D → W → Prop}
    (hR : ∀ w x u, R w x u ↔ u = f w x) : ∀ w x, (Fib R w x).Subsingleton := by
  intro w x u hu u' hu'
  exact ((hR w x u).mp hu).trans ((hR w x u').mp hu').symm

omit [IsOrderedAddMonoid D] in
theorem saturation_of_fib_subsingleton {W : Type} {R : W → D → W → Prop}
    (h : ∀ w x, (Fib R w x).Subsingleton) : Saturation R := by
  intro S hdir hmem
  refine sInter_nonempty_of_directed_subsingleton hdir (fun s hs => (hmem s hs).2)
    (fun s hs => ?_)
  rcases (hmem s hs).1 with ⟨w, x, rfl⟩ | ⟨w, v, x, y, _, _, rfl⟩
  · exact h w x
  · exact (h w x).anti Set.inter_subset_left
```

Measured axiom profiles (`#print axioms`, this toolchain):

- `sInter_nonempty_of_directed_subsingleton` — **does not depend on any axioms**
- `fib_subsingleton_of_functional` — **does not depend on any axioms**
- `saturation_of_fib_subsingleton` — **`[propext]`** only

That is strictly better than routing through the existing
`sInter_nonempty_of_directed_of_univ_or_singleton`, whose `classical`/`by_cases` opening makes it
`Classical.choice`-dependent. **Do not** implement Helper D by converting subsingletons to literal
singletons and calling the `univ_or_singleton` helper: the direct proof (which is FlowFrame's,
moved) is shorter *and* axiom-free. `Seg R w v x y = Fib R w x ∩ Fib R v (-y)` is a subset of a
fibre, so `Set.Subsingleton.anti` covers the segment class with no extra hypothesis — which is why
the helper needs only the fibre hypothesis.

**Recommendation**: add a `#guard_msgs`-gated `#print axioms` block for all three in
`Tests/BimodalTest/Semantics/SaturationFiniteAxiomTest.lean`, beside the existing four. The
axiom-free core is exactly the kind of fact that file exists to protect.

### 3.2 Helper B completion (work item 2)

Home: `TaskFrame.lean`, inside the Helper B block (`:1134-1241`), after
`interpolates_of_permissive`. Compiles; `#print axioms` reports `[propext]` for all four.

```lean
omit [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D] in
theorem nullity_identity_of_permissive {W : Type} {R : W → D → W → Prop}
    (hR : ∀ w d u, R w d u ↔ (d ≠ 0 ∨ w = u)) : ∀ w u, R w 0 u ↔ w = u := by
  intro w u
  rw [hR]
  simp

omit [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D] in
theorem converse_of_permissive {W : Type} {R : W → D → W → Prop}
    (hR : ∀ w d u, R w d u ↔ (d ≠ 0 ∨ w = u)) : ∀ w d u, R w d u ↔ R u (-d) w := by
  intro w d u
  rw [hR, hR]
  simp only [ne_eq, neg_eq_zero]
  exact ⟨fun h => h.imp id Eq.symm, fun h => h.imp id Eq.symm⟩

omit [Nontrivial D] in
theorem forward_comp_of_permissive {W : Type} {R : W → D → W → Prop}
    (hR : ∀ w d u, R w d u ↔ (d ≠ 0 ∨ w = u)) :
    ∀ w u v x y, 0 ≤ x → 0 ≤ y → R w x u → R u y v → R w (x + y) v := by
  intro w u v x y hx hy h1 h2
  rw [hR] at h1 h2 ⊢
  rcases h1 with hxne | hwu
  · refine Or.inl fun heq => hxne (le_antisymm ?_ hx)
    have hy_eq : y = -x := (neg_eq_of_add_eq_zero_right heq).symm
    exact neg_nonneg.mp (hy_eq ▸ hy)
  · rcases h2 with hyne | huv
    · refine Or.inl fun heq => hyne (le_antisymm ?_ hy)
      have hx_eq : x = -y := (neg_eq_of_add_eq_zero_left heq).symm
      exact neg_nonneg.mp (hx_eq ▸ hx)
    · exact Or.inr (hwu.trans huv)

theorem comp_of_permissive {W : Type} {R : W → D → W → Prop}
    (hR : ∀ w d u, R w d u ↔ (d ≠ 0 ∨ w = u)) : Compositional R :=
  comp_of (interpolates_of_permissive hR) (forward_comp_of_permissive hR)
```

Two gotchas measured, not guessed:

- **`linarith` is not available** in `TaskFrame.lean`'s import closure. The sign argument must be
  written with `neg_nonneg`/`le_antisymm` as above; a `linarith` version fails to elaborate.
- **`comp_of_permissive` needs `[Nontrivial D]`** in scope (inherited via
  `interpolates_of_permissive`); the other three must `omit` it.

---

## 4. Per-work-item findings

### 4.1 Work item 1 — collapse the seven Saturation sites

The seven duplicated bodies total **93 lines** and split into three families:

| Family | Sites | Current helper | Collapse |
|---|---|---|---|
| Subsingleton→singleton conversion | `ClockFrame:156-165` (10), `DurationFrames:155-165` (11), `RegionFrame:208-222` (15), `RegionFrame:295-307` (13) | `TaskFrame.sInter_..._univ_or_singleton` | re-point to Helper D; the `Set.univ` disjunct is **dead weight at all four** |
| Direct `Subsingleton` | `ReynoldsBridge:465-474` (10), `:523-529` (7), `:785-794` (10) | `Algebraic.sInter_..._subsingleton` | re-point to Helper D (same shape) |
| Bespoke | `ShiftSet:186-202` (17) | **neither** | **rewrite**, not re-point — it never constructs a `Set.Subsingleton` value at all, proving raw pairwise equality and threading the directed-family witness by hand |

Two further observations the review does not record:

- `ReynoldsBridge` proves **the same proposition twice**: the `saturation` field of
  `zTaskFrameV2` (`:465`) and the top-level `zTaskFrameV2_saturation` (`:523`) are two
  independent proofs of `TaskFrame.Saturation zTaskFrameV2.TaskRel`. Same for `RegionFrame:208`
  vs `:295`. The fix in both files is to declare the `*_fib_subsingleton` lemma **before** the
  frame, discharge the field with Helper D, and make the top-level theorem a one-line citation of
  the field. The file already demonstrates the target shape at `ReynoldsBridge:835-837`.
- `Algebraic.multiFamTaskFrameGen_saturation` (FlowFrame) is **consumed** by
  `ReynoldsBridge:835`. Deleting `Algebraic.sInter_nonempty_of_directed_subsingleton` must
  retarget that theorem's proof at `TaskFrame.saturation_of_fib_subsingleton`, not delete it.

**Expected**: 93 → ~10 lines at the sites; +26 lines of Helper D; delete FlowFrame's 12-line
helper. Net **≈ −70**.

### 4.2 Work item 2 — Helper B completion and the `TemporalOrder` migration

The Helper-B half is clean (§3.2). The **migration half carries a documented counter-argument**
that the plan must answer.

`TemporalOrder.of`'s own docstring (`TemporalOrder.lean:98-113`) says, verbatim:

> **Kept permanently, on evidence.** … wherever a frame's duration carrier is pinned to a bare
> `Type` by a neighbouring abstraction — `BFMCS` in the bundle layer, `FrameConditionFor`,
> `TemporalCarrier` and the frame-condition family `C : (D : Type) → … → Prop` in the
> decidability bridge — the frame is a value of `FrameOver (TemporalOrder.of D)`. Promoting only
> the frame's binder to `(D : TemporalOrder)` at those sites would leave every caller naming
> `(D := …)` explicitly, because unification cannot invert `TemporalOrder.carrier ?D =?= Rat`.

Current shapes (verified):

- **Already `(D : TemporalOrder)`**: `genericTimeFrame` (`TemporalStructures:331`),
  `genericNatFrame` (`:382`), `translationFrame` (`DurationFrames:122`), `permissiveFrame`
  (`DurationFrames:212`).
- **Bare-`Type`**: `trivialFrame` (`TaskFrame:1321`), `staticFrame` (`:1384`), `natFrame`
  (`:1454`), `regionFrame`, `clockFrame`.

So the migration is smaller than it sounds — three definitions — but they have **57 / 61 / 50**
references respectively, essentially all of the form `(D := ℤ)`. The migration is mechanical
(`(D := ℤ)` → `intOrder`) but touches every one of those sites.

**Recommendation**: do the Helper B completion and the `genericNatFrame`/`genericTimeFrame`
merge, and make the `TemporalOrder` migration its **own phase with an explicit go/no-go**,
grounded in a count of how many call sites would need a new explicit `(D := …)`. If the count is
non-trivial, the honest outcome is to leave the three constants at `TemporalOrder.of D` and
record why in the docstring — the review's C-03 offers exactly this fallback ("or keep them as
`abbrev`s pointing at the `TaskFrame.lean` constants").

**Note**: `permissiveFrame` is **not** `natFrame` — its carrier is `Bool`, `natFrame`'s is `Nat`,
and it takes `SuccOrder`/`NoMaxOrder` as *explicit* arguments rather than instances. It cannot be
merged away; it is a third client of Helper B.

### 4.3 Work item 4 — `TruthIso` (the highest-value and highest-risk item)

**The five transports are not five instances of one lemma. They are four plus one.**

| # | Declaration | Lines | `dur` map | Box case discharged by | Derivable from a uniform `TruthIso`? |
|---|---|---|---|---|---|
| 1 | `Truth.time_shift_preserves_truth` `:655-887` | 233 | `(· + (y−x))`, order-preserving | history generalisation + `truth_double_shift_cancel` | **yes** |
| 2 | `IntTransfer.truthAt_map` `:292-363` | 72 | `e : ↑D ≃+o ↑E` (**additive** order iso) | `WorldHistory.map`/`comap` + `Aligned` | **yes**, but needs the `Aligned` shape recast as an `F.HF ≃ F'.HF` |
| 3 | `FwdRecPeriodicity.truthAt_add_hist_period` `:356-420` | 65 | `(· + π)` | **`Truth.box_time_const` — the IH is never used** | **NO** — see below |
| 4 | `LoopingDuration.truthAt_add_period` `:98-165` | 68 | `(· + π)`, frame-uniform | history generalisation | **yes** |
| 5 | `CoNotPriorU.truthAt_mirror` `:406-485` | 80 | `(−·)`, **order-reversing**; concludes `φ.swapTemporal` | constructs the reflected history | **yes, via the anti-iso twin** |

**Why #3 cannot be an instance.** Its hypothesis `hper : ∀ x, τ.states (x+π) _ = τ.states x _` is
about **one history `τ`**. A `TruthIso`'s `atom` field is necessarily quantified over *all*
histories, because the `box` clause of `TruthAt` ranges over all total histories and the
induction hypothesis must be available at each of them. That is precisely the distinction
`FwdRecPeriodicity.lean:349-352` documents in prose: `LoopingDuration.truthAt_add_period` needs a
**frame-uniform** period because its `□` case reaches into other histories, while this one gets by
with a **per-history** period only because its `□` case is discharged by model-constancy instead.
Feeding #3 a uniform hypothesis would strictly weaken the theorem and break its consumer.

**Consequence for acceptance.** "Exactly one `induction φ` truth-transport proof in `Semantics/`
+ `Independence/`" is unreachable. Recommend restating as: **"at most two — the generic
`truthAt_of_truthIso`, plus `truthAt_add_hist_period`, which keeps its own induction and gains a
docstring cross-reference explaining why it is not an instance."**

**A bonus the review misses.** `Truth.truth_double_shift_cancel` (`:584-633`, 50 lines) is a
**sixth** live six-case induction, existing only to serve `time_shift_preserves_truth`'s box case.
If `TruthIso.hist` is an honest `F.HF ≃ F'.HF` (for the shift case: `timeShift · Δ` with inverse
`timeShift · (−Δ)`), the box case gets its round-trip from `Equiv.symm_apply_apply` and this
helper becomes **deletable**. Fold it into the estimate.

**Structure sketch** (types confirmed against the tree — `TaskModel` has the single field
`valuation : F.WorldState → Atom → Prop`; `TaskFrame.HF F := {τ : WorldHistory F // τ.IsTotal}`;
`states : (t : F.Duration) → domain t → F.WorldState`):

```lean
structure TruthIso {F F' : TaskFrame} (M : TaskModel F) (M' : TaskModel F') where
  dur  : F.Duration ≃o F'.Duration
  hist : F.HF ≃ F'.HF
  atom : ∀ (τ : F.HF) (t : F.Duration) (p : Atom),
           M.valuation (τ.val.states t (τ.property t)) p ↔
           M'.valuation ((hist τ).val.states (dur t) ((hist τ).property (dur t))) p
```

`Formula` has exactly six constructors (`atom`/`bot`/`imp`/`box`/`untl`/`snce`), and
`Formula.swapTemporal` (`Syntax/Formula.lean:668-674`) fixes `atom`/`bot`, distributes through
`imp`/`box`, and exchanges `untl` ↔ `snce` — exactly the shape the anti-iso twin's `untl`/`snce`
cases need. `swap_temporal_involution` (`:682-690`) is available.

**Toolkit that landed after the review was written.** Task 521 added the `truth_norm` and
`swap_norm` simp attribute sets plus the `truth_simp` macro (`Automation/TruthNormAttr.lean`),
and eleven `@[simp, truth_norm]` characterisation lemmas (`and_iff`, `untl_iff`, `snce_iff`,
`always_iff`, `kPlus_iff`, …). `swap_norm` collects all eleven `Formula.swap_temporal_*`
distribution lemmas. The generic induction should be written against these, not against
`simp only [TruthAt]` — that is what makes a ~90-line body plausible where the current
`time_shift_preserves_truth` needs 233.

**Sequencing** (revised from the review's, given #3's exclusion): land #1 and #4 first (they
share `dur := (· + Δ)` exactly and are the two largest wins), then #5 via the anti-iso twin, then
#2's `≃+o`/`Aligned` recast last.

**Expected**: 233+72+68+80 = 453 → ~90 (generic) + ~50 (anti-iso twin) + 4×~12 = ~188, plus 50
deleted from `truth_double_shift_cancel`. Net **≈ −315**.

### 4.4 Work item 3 — `ofTotal`

Six `Semantics/` sites confirmed (`WorldHistory.lean:152` `universal`, `:172` `trivial`, `:193`
`universalTrivialFrame`, `:215` `universalNatFrame`; `ShiftSet.lean:214` `hist`;
`IntNormalForm.lean:310` `HFofStepPath`). All six write the identical four-field skeleton
`domain := fun _ => True`, `nonempty_domain := ⟨0, trivial⟩`, `convex := … trivial`, differing
only in `states` and `respects_task`.

**Leverage beyond the six**: the same idiom recurs at `CoNotPriorU:388`,
`DiscreteNonCompactness:150`, `ClockFrame:228`, `ReynoldsBridge:533,843`, `RegionFrame:333`,
`FlowFrame:194`, `DurationFrames:178,264`, `FwdRecBridge:97`, `TemporalStructures:313,477` — a
further **twelve** sites that `ofTotal` would also serve. The plan should migrate at least the
`Semantics/` six and note the rest as follow-on.

The `@[simp] ofTotal_states` lemma is the load-bearing half: with `domain := fun _ => True` the
domain proof is `trivial`, so `(ofTotal f h).val.states t trivial = f t` is `rfl` and `simp` will
close the bridge that call sites currently open by hand.

### 4.5 Work item 5 — the Z dictionary

Confirmed and cleanly actionable. `FwdRecBridge.lean:60-112` re-derives, under `Bridge.*` names,
what `IntNormalForm.lean` already proves:

| `FwdRecBridge` | `IntNormalForm` | Relationship |
|---|---|---|
| `Bridge.step` `:61-62` | `FrameOver.step` `:176-178` | **byte-identical body**, same identifier, different namespace |
| `Bridge.taskRel_diff` `:82-92` | `respects_of_isStepPath` `:294-303` | **same statement**, different proof route |
| `Bridge.ofWalk` + `ofWalk_isTotal` `:94-104` | `HFofStepPath` `:305-316` | same construction; IntNormalForm's is pre-bundled as `HF` |
| `Bridge.hist_isWalk` `:106-112` | `TaskFrame.HF.isStepPath` `:322-327` | **same statement**, same one-line proof |
| (the three jointly) | `mem_HF_iff_adjacent` `:329-341` | IntNormalForm states the round trip as one `Iff` |

`Bridge.taskRel_nat` `:64-78` is the one genuinely different lemma (a `ℕ`-indexed iteration);
IntNormalForm's `taskRel_natCast_iff_iter` `:182-200` + `iter_of_isStepPath` `:284-292` cover the
same ground more generally.

**`isWalk_iff_isStepPath` is `Iff.rfl`.** `Walk.IsWalk R σ := ∀ n : ℤ, R (σ n) (σ (n+1))`
(`FwdRecPeriodicity:69`) and `IsStepPath F f := ∀ n : ℤ, F.step (f n) (f (n+1))`
(`IntNormalForm:265-266`) both unfold to `∀ n : ℤ, F.TaskRel (σ n) 1 (σ (n+1))` once `step` is
substituted — they are **definitionally equal**, not merely equivalent.

**No import cycle.** `IntNormalForm`'s full `FormalSystem.*` transitive closure is
`{PartialHistory, TaskFrame, TemporalOrder, WorldHistory}` — nothing in `Correspondence/`.
`FwdRecBridge` is imported by exactly one module, `Semantics.lean:37`. Adding
`import FormalSystem.Semantics.IntNormalForm` to `FwdRecBridge.lean` is safe.

**Expected**: ~52 lines out, ~8 in. Net **≈ −45**.

### 4.6 Work items 6 — `isLeast_succ` and `LexInt`

**C-15 splits into two directions, and U7 covers only one.**

*Direction B (covered by U7)* — least-positive witness ⟹ successor structure. Three sites:

- `DurationFrames.lean:90-101` `succOrder_of_isLeast_pos` (12 lines)
- `LexIntWitness.lean:97-104` `lexInt_isLeast_succ` (8 lines)
- `LexIntWitness.lean:107-115` `lexInt_isGreatest_pred` (9 lines)

All three use only `sub_pos`, `le_sub_iff_add_le`, `add_comm`. The right hypotheses for the shared
lemma are **`[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]` and nothing more** — no
`Nontrivial`, no `Archimedean`, no `SuccOrder`:

```lean
theorem isLeast_succ_of_isLeast_pos {p : D} (hp : IsLeast {y : D | 0 < y} p) (x : D) :
    IsLeast {z : D | x < z} (x + p)
theorem isGreatest_pred_of_isLeast_pos {p : D} (hp : IsLeast {y : D | 0 < y} p) (x : D) :
    IsGreatest {z : D | z < x} (x - p)
```

*Direction A (NOT covered)* — successor structure ⟹ least-positive fact. Two sites:
`DurationClassification.lean:194-196` `isLeast_pos_succ_zero` and `BLSchemaValidity.lean:136-139`
`isGreatest_neg_pred_zero`. These are 3–4 lines each and the second's docstring **explicitly
records the duplication as deliberate** (a territory split from an earlier task). Leave them, or
merge them only with an explicit note superseding that docstring.

**C-16 / LexCarrier generalisation.** `LexCarrier.lean` (153 lines) uses **nothing about `ℚ`** —
its `lexSucc_le_iff`/`le_lexPred_iff` proofs go through `Prod.Lex.le_iff'`/`lt_iff'` and
`Int.lt_iff_add_one_le`; only the *second* factor must be `ℤ`. Generalising to `α ×ₗ ℤ` is sound.
Three concrete points the plan must handle:

- **`LexCarrier` has no `IsLeast {x | 0 < x} p` theorem at all.** It builds `SuccOrder`/`PredOrder`
  directly from hand-written `succ`/`pred` functions. `LexInt.isLeast_pos` is *new content*, not a
  move.
- **`LexCarrier`'s non-Archimedean facts are `example`s, not named theorems**
  (`:112-130` `¬IsSuccArchimedean`, `:133-151` `¬IsPredArchimedean`). They must be **promoted to
  named theorems** before `LexIntWitness` can cite them.
- **`LexIntWitness.lean:123-141` `lexInt_not_archimedean` states `¬ Archimedean`**, a *different*
  proposition from `¬IsSuccArchimedean`. Both belong in the `LexInt` namespace.
- Both files open with the **same four-`example` instance-pinning ritual**
  (`LexCarrier:60-66`, `LexIntWitness:72-78`); one copy survives.
- Blast radius is small: `LexCarrier` is imported only by `Metalogic/Z1Countermodel.lean:10`;
  `LexIntWitness` only by `Metalogic/Independence.lean:12`.

**Expected**: `LexIntWitness:72-141` (~70 lines) mostly deleted; ~30 added to `LexCarrier`. Net
**≈ −60** including the U7 collapse.

### 4.7 Work item 7 — the A-06 order-dual cores

The four proofs are at `FrameClassVariants.lean:780-817` (`prior_UZ_valid`, 38),
`:821-857` (`prior_SZ_valid`, 37), `:861-920` (`z1_valid`, 60), `:924-972` (`z1_past_valid`, 49)
— **184 lines, not ~90**.

The `Separability.lean` precedent is real and directly applicable: `sep_order` is stated as a
**pure order/`Set` lemma over an abstract `P : Set D`** with all `Formula`/`TruthAt` unfolding
left to its caller, and `sep_order_mirror` is obtained by instantiating it at `Dᵒᵈ` rather than
hand-dualising a ~130-line body. Mathlib supplies the dualisation instances this needs
(`SuccOrder α → PredOrder αᵒᵈ` at `Mathlib/Order/SuccPred/Basic.lean:73`; the
`IsSuccArchimedean`/`IsPredArchimedean` duals at `Mathlib/Order/SuccPred/Archimedean.lean:46,50`).

**The obstruction is structural, not mathematical**: unlike `sep_order`, the four
`FrameClassVariants` proofs **interleave** the order reasoning (`Nat.find`, `Order.succ^[·]`,
`Monotone`/`Antitone` strong induction) with `Formula`/`TruthAt` unfolding inside one monolithic
body. So the work is *two* steps, and the plan must sequence them:

1. Extract `exists_nearest_succ` / `forall_gt_of_succ_step` over an abstract `P : D → Prop` with
   `[SuccOrder D] [IsSuccArchimedean D]` into the new `SoundnessLemmas/DiscreteOrder.lean`.
2. Obtain the past-side cores at `Dᵒᵈ`, then re-instantiate `P := fun x => TruthAt M τ x φ` at
   each of the four sites.

**Do not attempt a `Formula`-level dualisation.** `LexIntWitness.lean:52-54` records that a
single-frame `F.ValidOn φ → F.ValidOn φ.swapTemporal` closure lemma "does not exist and is false
in general". The dualisation here is of the **carrier** `D`, not of the formula — exactly what
`sep_order_mirror` does.

**Expected**: 184 → ~110 at the sites, +~45 in `DiscreteOrder.lean`. Net **≈ −30**. This is the
lowest-yield item; size the phase accordingly.

### 4.8 Work item 8 — dead lemmas and `Function.Periodic`

`WorldHistory.lean:382-444` — confirmed. Four theorems, **each with exactly one repo occurrence
(its own declaration line)**: `neg_lt_neg_iff` `:399-411`, `neg_le_neg_iff` `:416-425`,
`neg_neg_eq` `:430-431`, `neg_injective` `:436-443`. They shadow Mathlib's
`neg_le_neg_iff : -a ≤ -b ↔ b ≤ a` and `neg_lt_neg_iff : -a < -b ↔ b < a`
(`Mathlib/Algebra/Order/Group/Unbundled/Basic.lean:227-256`, both `@[simp]`) with the
biconditional's sides **swapped**, and Mathlib's carry `@[simp]` while these do not. Namespaced
under `WorldHistory`, so no elaborator clash — the harm is a reader trap. Delete all four.

**Additional dead code found (not in the review).** Four more `WorldHistory.lean` lemmas have
zero external references: `time_shift_domain_iff` `:295`, `time_shift_inverse_domain` `:302`,
`time_shift_time_shift_states` `:335`, `time_shift_zero_domain_iff` `:355`. Delete them rather
than renaming them in work item 9. That leaves only three `time_shift_*` lemmas to rename
(`time_shift_congr`, 12 refs — 9 of them inside `time_shift_preserves_truth`, so they vanish with
the `TruthIso` refactor; `time_shift_time_shift_neg_domain_iff` and
`time_shift_time_shift_neg_states`, 3 refs each, both consumed only by
`truth_double_shift_cancel`, which §4.3 also deletes).

**`per_period` → `Function.Periodic`.** `per_period σ m : ∀ n, per σ m (n + m) = per σ m n`
(`FwdRecPeriodicity:106-108`) **is** `Function.Periodic (per σ m) m` — Mathlib's definition is
`Periodic [Add α] (f : α → β) (c : α) : Prop := ∀ x, f (x + c) = f x`, at
`Mathlib/Algebra/Ring/Periodic.lean:43-46` in this pin (**not** `Mathlib/Algebra/Periodic.lean`
or `Mathlib/Algebra/Order/Periodic.lean`, neither of which exists here). Two further members of
the same family are also `Function.Periodic` in disguise: `MinCyc.perd` (`:121`) is
`Function.Periodic M.walk M.len`, and `Walk.periodic`'s conclusion (`:327-342`) is
`∃ π, 0 < π ∧ Function.Periodic σ π`.

**Do not touch `Walk`/`MinCyc`.** C-14 records the Mathlib survey as negative
(`SimpleGraph.Walk`, `Quiver.Path`, `Relation.ReflTransGen`, `Function.minimalPeriod`,
`IsPeriodicPt` all rejected). Record that negative result in `FwdRecPeriodicity.lean`'s module
docstring so it is not re-run.

### 4.9 Work item 9 — `Frames/Standard.lean` and the doc fixes

**`FormalSystem/Semantics/Frames/` does not exist.** Placement matters, and the obvious placement
is wrong:

- `translationFrame` and `permissiveFrame` currently live in
  `Correspondence/DurationFrames.lean`, which imports `Correspondence/Indicator` and
  `DurationClassification`. A `Frames/Standard.lean` that *imports* `DurationFrames` to
  re-export them would sit **downstream of `Correspondence/`** — an index below the modules it
  indexes.
- Neither frame needs anything from `Indicator` or `DurationClassification`
  (`translationFrame` is `W = D`, `w ⇒_x u ↔ u = w + x`; `permissiveFrame` is `W = Bool`).
  **Move both definitions up into `Frames/Standard.lean`** (importing only `TaskFrame`) and have
  `DurationFrames.lean` import it. That keeps `Frames/` upstream and makes the index real.

**Frame-constant census: 22, not 14, across 15 files, not 9.** Full list:

| Name | File | Line | Type |
|---|---|---|---|
| `trivialFrame` | `Semantics/TaskFrame.lean` | 1321 | `FrameOver (TemporalOrder.of D)` |
| `staticFrame` | `Semantics/TaskFrame.lean` | 1384 | `FrameOver (TemporalOrder.of D)` |
| `natFrame` | `Semantics/TaskFrame.lean` | 1454 | `FrameOver (TemporalOrder.of D)` |
| `ofStep` | `Semantics/IntNormalForm.lean` | 445 | `FrameOver intOrder` |
| `flipFrame` | `Semantics/IntNormalForm.lean` | 518 | `FrameOver intOrder` |
| `translationFrame` | `Semantics/Correspondence/DurationFrames.lean` | 122 | `FrameOver D` |
| `permissiveFrame` | `Semantics/Correspondence/DurationFrames.lean` | 212 | `FrameOver D` |
| `intTimeFrame` | `Examples/TemporalStructures.lean` | 78 | `FrameOver intOrder` |
| `intNatFrame` | `Examples/TemporalStructures.lean` | 123 | `FrameOver intOrder` |
| `intBoolFrame` | `Examples/TemporalStructures.lean` | 225 | `FrameOver intOrder` |
| `genericTimeFrame` | `Examples/TemporalStructures.lean` | 331 | `FrameOver D` |
| `genericNatFrame` | `Examples/TemporalStructures.lean` | 382 | `FrameOver D` |
| `clockFrame` | `Metalogic/Independence/ClockFrame.lean` | 178 | `FrameOver (TemporalOrder.of ℚ)` |
| `lexIntStaticFrame` | `Metalogic/Independence/LexIntWitness.lean` | 149 | `TaskFrame` |
| `ratStaticFrame` | `Metalogic/Independence/RationalWitness.lean` | 105 | `TaskFrame` |
| `toFibre` | `Metalogic/Decidability/IntPresentation.lean` | 134 | `FrameOver intOrder` |
| `toFiniteFibre` | `Metalogic/Decidability/IntPresentation.lean` | 159 | `FiniteFrameOver intOrder` |
| `RefinedFilteredTaskFrame` | `Metalogic/Decidability/FMP/Filtration.lean` | 299 | `FrameOver D` |
| `FiniteFilteredTaskFrame` | `Metalogic/Decidability/FMP/FiniteModel.lean` | 173 | `FiniteFrameOver D` |
| `regionFrame` | `Metalogic/Decidability/Verified/Bridge/RegionFrame.lean` | 181 | `FrameOver (TemporalOrder.of D)` |
| `multiFamTaskFrameGen` | `Metalogic/Algebraic/FlowFrame.lean` | 153 | `FrameOver D` |
| `zTaskFrameV2` | `Metalogic/WeakCanonical/IntegerModel/ReynoldsBridge.lean` | 454 | `FrameOver intOrder` |
| `multiFamTaskFrame` | `Metalogic/WeakCanonical/IntegerModel/ReynoldsBridge.lean` | 768 | `FrameOver intOrder` |

`Standard.lean` should index the four the task names and **link** (not re-export) the rest.

**`Semantics.lean` gaps (C-19) — the task's "already fixed" claim is wrong.** `Semantics.lean`
imports 30 of the 33 `Semantics/**.lean` modules. Still missing: **`LexCarrier`**,
**`BLSchemaValidity`**, and **`Extension/PeriodicExtension`** (the third is not in the review
either).

**`Semantics/README.md` (C-20)** — confirmed: its Contents table omits `TemporalOrder.lean`,
`FrameProperty.lean`, `FrameClassValidity.lean`, and lists `LexCarrier.lean` despite
`Semantics.lean` not importing it. `Semantics.lean` itself imports all three of the omitted
modules, so the defect is README-only.

**`Independence.lean` (C-21)** — confirmed. Its docstring `:14-42` opens "The one result carried
here is that the paper's `CO` principle does not derive Reynolds' `Axiom.prior_U_gap`…" directly
above a `## Contents` list of **six** modules.

**`TaskFrame.lean` regression sections (C-22)** — five confirmed, 108 example lines in
`:1778-1924`:

| Section | Lines | Content |
|---|---|---|
| `BridgeChecks` | 1778-1793 | `TaskFrame ↔ FrameOver` round trip, `Duration` algebra |
| `TotalSpaceIdentity` | 1804-1825 | **the same round trip again**, plus flat accessors |
| `BundledDefinitionalContent` | 1834-1852 | four axioms + limit, at bundled `TaskFrame` |
| `DefinitionalContent` | 1866-1890 | **the same four axioms**, at `FrameOver E` |
| `FibreDefinitionalContent` | 1899-1924 | **the same four axioms again**, at `FrameOver D` |

The natural merge is 5 → 2: one round-trip/identity section and one definitional-content section
covering all three ambient shapes.

**`time_shift_*` rename (C-23)** — see §4.8. After deleting the four dead ones and the two
consumed only by `truth_double_shift_cancel`, the rename reduces to `time_shift_congr` and
`Truth.time_shift_preserves_truth`.

---

## 5. Line-budget estimate

| Item | Removed | Added | Net |
|---|---|---|---|
| 1. Saturation sites + Helper D + FlowFrame delete | ~105 | ~30 | **−75** |
| 2. Helper B completion + generic merge | ~140 | ~60 | **−80** |
| 3. `ofTotal` (Semantics/ six) | ~55 | ~30 | **−25** |
| 4. `TruthIso` (four transports + `truth_double_shift_cancel`) | ~503 | ~190 | **−313** |
| 5. Z dictionary | ~52 | ~8 | **−44** |
| 6. U7 + `LexInt` | ~95 | ~35 | **−60** |
| 7. `DiscreteOrder.lean` D-op cores | ~75 | ~45 | **−30** |
| 8. Dead lemmas (8 in `WorldHistory.lean`) + `Function.Periodic` | ~95 | ~5 | **−90** |
| 9. `Frames/Standard.lean`, regression-section merge, doc fixes | ~80 | ~60 | **−20** |
| **Total** | **~1200** | **~463** | **≈ −737** |

Consistent with the task's "~700–800 removed net of ~250 added" target, though the *added* figure
is closer to ~460 than ~250 once the `TruthIso` structure, its anti-iso twin, `Standard.lean` and
`DiscreteOrder.lean` are counted honestly.

---

## 6. Recommended phase decomposition

Ordered by independence and risk. Items 1–3 and 5–6 are mutually independent and could run in
parallel with disjoint file territories; item 4 is the long pole.

| Phase | Work | Territory | Risk |
|---|---|---|---|
| 1 | Helper D + collapse 7 sites + delete FlowFrame helper + retarget `multiFamTaskFrameGen_saturation` | `TaskFrame.lean`, `FlowFrame.lean`, `ClockFrame.lean`, `DurationFrames.lean`, `RegionFrame.lean`, `ReynoldsBridge.lean`, `ShiftSet.lean` | Low — text in §3.1 already compiles |
| 2 | Helper B completion; permissive frames to 7 one-liners | `TaskFrame.lean`, `TemporalStructures.lean`, `DurationFrames.lean` | Low — text in §3.2 already compiles |
| 3 | `TemporalOrder` migration go/no-go + `genericNatFrame`/`genericTimeFrame` → `abbrev` | `TaskFrame.lean`, `TemporalStructures.lean` + ~160 call sites | **Medium-high** — see §4.2; gate on a call-site count |
| 4 | `ofTotal` + `@[simp] ofTotal_states`; collapse the `Semantics/` six | `WorldHistory.lean`, `ShiftSet.lean`, `IntNormalForm.lean` | Low |
| 5 | Delete 8 dead `WorldHistory.lean` lemmas; `per_period` → `Function.Periodic`; record the negative Walk/MinCyc survey | `WorldHistory.lean`, `FwdRecPeriodicity.lean` | Low |
| 6 | Import `IntNormalForm` from `FwdRecBridge`; delete the duplicate dictionary; add `isWalk_iff_isStepPath` (`Iff.rfl`) | `FwdRecBridge.lean` | Low |
| 7 | U7 pair in `DurationClassification.lean`; retarget the 3 Direction-B sites | `DurationClassification.lean`, `DurationFrames.lean`, `LexIntWitness.lean` | Low |
| 8 | Generalise `LexCarrier` to `α ×ₗ ℤ`; promote its `example`s to theorems; make `LexIntWitness` an instance | `LexCarrier.lean`, `LexIntWitness.lean` | Medium |
| 9a | `TruthIso` structure + `truthAt_of_truthIso`; derive `time_shift_preserves_truth` and `truthAt_add_period`; delete `truth_double_shift_cancel` | `Truth.lean`, `LoopingDuration.lean` | **High** |
| 9b | Anti-iso twin; derive `truthAt_mirror` | `Truth.lean`, `CoNotPriorU.lean` | **High** |
| 9c | Recast `Aligned` as an `HF` equivalence; derive `truthAt_map` | `IntTransfer.lean` | **High** |
| 10 | `DiscreteOrder.lean` cores; re-obtain the two past-side proofs at `Dᵒᵈ` | `SoundnessLemmas/` | Medium |
| 11 | `Frames/Standard.lean` (**moving** `translationFrame`/`permissiveFrame` upstream); `Semantics.lean` 3 missing imports; `Semantics/README.md`; `Independence.lean` docstring; merge 5 regression sections → 2; `timeShift_*` rename | index + docs | Low |

Phase 9a must land green before 9b or 9c is attempted; if 9a stalls, the remaining phases are all
independently valuable and the task should still be judged a success on them.

---

## 7. Hard constraints (violate these and the build breaks)

1. **`Tests/BimodalTest/Semantics/SaturationFiniteAxiomTest.lean` contains four build-breaking
   `#guard_msgs`-gated `#print axioms` blocks.** They pin
   `sInter_nonempty_of_directed_of_minimal` (*no axioms*), `saturation_of_finite`
   (`[propext, Classical.choice, Quot.sound]`), `saturation_of_subsingleton` (**`[propext]`**),
   and `wlem_of_saturation` (`[propext, Quot.sound]`). The file's own prose names the exact
   temptation to avoid: *"'simplify by routing the subsingleton case through the general lemma' —
   a tempting and entirely wrong consolidation."* **Helper A (`saturation_of_subsingleton`) must
   not be re-derived from Helper D**, nor from `saturation_of_finite`. Helper D is *additive*.
   `TaskFrame.saturation_of_finite`'s docstring (`TaskFrame.lean:1061`) carries the same
   prohibition in prose.
2. **The C2 baseline is `#print axioms` on four flagship theorems**
   (`BXCanonical.completeness`, `.completeness_dense`, `.completeness_discrete`,
   `.Chronicle.countermodel_dense`), checked by `scripts/check-module-invariants.sh` check C2.
   All four already carry `[propext, Classical.choice, Quot.sound]`, so nothing in this task can
   move them — but re-run the check before claiming acceptance.
3. **Every `lake build` must be detached and guarded**:
   `Bash(run_in_background: true)` on `./.claude/scripts/lake-build-guard.sh build --timeout 600
   -- build`. A foreground call will be killed at the tool cap and bank no progress. Verified
   working this session (2517 jobs, exit 0).
4. **Zero-debt**: no `sorry`, no new axioms, no Option-B deferral. Every phase above is
   completable without one; the only phase with genuine uncertainty is 9c, and its fallback is to
   leave `truthAt_map` in place rather than to leave a `sorry`.

## 8. Open questions for the planner

1. **Phase 3 go/no-go**: does the `TemporalOrder` migration of `trivialFrame`/`staticFrame`/
   `natFrame` create more explicit `(D := …)` annotations than it removes? The `TemporalOrder.of`
   docstring predicts it does at bare-`Type`-pinned sites. Count before committing.
2. **Acceptance restatement**: "exactly one `induction φ`" → **"at most two"** (§4.3). Needs the
   task owner's assent, or the criterion will read as failed on a correct implementation.
3. **C-05 removal**: strike it from scope; task 521 landed it.
4. **`Standard.lean` direction**: move `translationFrame`/`permissiveFrame` upstream (recommended)
   or accept an index that sits below `Correspondence/`?
