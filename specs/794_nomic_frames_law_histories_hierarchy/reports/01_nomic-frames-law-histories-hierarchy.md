# Research Report: Task #794

**Task**: 794 - Formalize the paper's nomic frames, law-histories, and the nomic hierarchy
**Started**: 2026-10-14T21:30:00Z
**Completed**: 2026-10-14T22:20:00Z
**Effort**: Implementation estimated 5-6 phases; every structural risk machine-checked during research
**Dependencies**: None (task 795, the nomic operator and its logic, depends on this one)
**Sources/Inputs**:
- `/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex` (`def:nomic-frame`,
  `def:nomic-properties`, `def:nomic-witnesses`, `prop:nomic-hierarchy`, `lem:nomic-occurrence`,
  `lem:nomic-recovery`, plus `def:frame`, `def:task-relation`, `def:world-history`, `lem:nullity`,
  `cor:saturation-finite`, `thm:extension`, `cor:occurrence`, `rmk:choice`)
- `/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/appendix_cut_material.tex` (`thm:nomic-primitive`)
- Codebase: `FormalSystem/Semantics/TaskFrame.lean`, `PartialHistory.lean`,
  `Extension/Extension.lean`, `IntNormalForm.lean`, `DeterministicBridge.lean`,
  `FrameConstraintIndependence.lean`, `OpenLanguage/OpenOckhamist.lean`,
  `scripts/check-module-invariants.sh`, `scripts/check-paper-definitions.sh`,
  `scripts/readme-lint.sh`, `docs/reference/paper-definitions-of-record.md`
- lean-lsp MCP (`lean_run_code` compiled probes against the built project; `lean_local_search`
  index reported `warming`, so absence findings below rest on grep sweeps, not on an empty LSP
  result)
**Artifacts**:
- `specs/794_nomic_frames_law_histories_hierarchy/reports/01_nomic-frames-law-histories-hierarchy.md`
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **The whole design is machine-checked, not proposed.** A single `lean_run_code` probe compiled,
  sorry-free and error-free, the `NomicFrame` structure (one carrier plus a derived family
  `NomicFrame.at`), its `IsRegular` class and the instance that feeds `FrameOver.IsRegular` back
  to synthesis, `lawHist`/`HF`, the `WorldHistory` bridge, the three properties of
  `def:nomic-properties` with `Uniform → Static` and `Uniform → Lawful`, `lem:nomic-occurrence`,
  **the full `lem:nomic-recovery` biconditional** (all three duration cases, through a general
  two-point-history lemma), the ℤ-time presentation `ofStepFamily` of `def:nomic-witnesses` with
  its `rfl` bridge to `FrameOver.ofStep` and automatic regularity, the adjacency characterisation
  of `lawHist` over ℤ, a `stepPath_invariant` helper, and **witness 1 of `prop:nomic-hierarchy`
  complete** (static, not lawful). Verified proof text for all of it is reproduced below.
- **The carrier problem has one good answer.** `at : W → FrameOver D` cannot be a field, because
  each `(F.at w).WorldState` must be the *index* type. Declare the carrier once as a field
  `World`, the relativised primitive relation as `PosRel : World → World → D.PositiveCone →
  World → Prop`, and derive `F.at w := ⟨F.World, F.PosRel w⟩`. Regularity is a class
  `NomicFrame.IsRegular` with field `∀ w, (F.at w).IsRegular` — exactly the general/regular split
  `FrameOver`/`FrameOver.IsRegular` already established, and the reason "a frame satisfying only
  some constraints" stays expressible.
- **`at` is a reserved token.** `def at (F : NomicFrame D) …` inside `namespace NomicFrame` fails
  to parse (`unexpected token 'at'; expected identifier`). The dotted form `def NomicFrame.at …`
  declared *outside* the namespace parses, and `F.at w` works everywhere in terms. Verified both
  ways.
- **`lawHist` must be a set of bare functions, not of `WorldHistory`s.** `WorldHistory (F.at w)`
  is a different type for each `w`, so the union `H_F` would not typecheck. `lawHist F w : Set (↑D
  → F.World) := {τ | ∀ x y, F.TaskRel w (τ x) (y - x) (τ y)}` is the reindexing the dispatch asks
  for; `mem_lawHist_iff` is the two-line bridge to `WorldHistory`, and over ℤ the definition is
  *literally* `FrameOver.isTotal_respects_iff_adjacent`'s left-hand side, which makes
  `mem_lawHist_iff_isStepPath` a one-term proof.
- **Siting: recommend `FormalSystem/Semantics/Nomic/`** (frames are frame theory, and
  `OpenLanguage/` imports `Semantics/`, never the reverse). Three gates attach to the new
  directory: a sibling aggregator `Semantics/Nomic.lean` (C8), a `Semantics/Nomic/README.md`
  (`readme-lint.sh` check 1, gated), and a regenerated root (`lake exe mk_all --lib FormalSystem`,
  C33).
- **Two files this task must touch sit in concurrent task 756's declared `file_scope`**:
  `docs/reference/paper-definitions-of-record.md` (six new anchor rows, required by gate C15) and
  `FormalSystem/Semantics.lean` (one import line). Both are single-hunk append-style edits; the
  six anchor `sha256` values are resolved in this report so the row text can be written without
  re-running the resolver.
- `scripts/check-paper-definitions.sh` is **already red** with 26 drifted anchors, pre-existing and
  unrelated. Do not treat it as a regression of this task and do not absorb the wave.

## Context & Scope

### What the paper asks for

`def:nomic-frame` replaces a task frame's single task relation by a family `⇒^w`, one per world
state `w ∈ W`, each satisfying `def:frame`, so that `F^w = ⟨W, D, ⇒^w⟩` is itself a task frame. It
then defines the law-histories

> `H_F^w := {τ : D → W | τ(x) ⇒_{y-x}^w τ(y) for all x, y ∈ D}` for each `w ∈ W`, with
> `H_F := ⋃_{w ∈ W} H_F^w`

and the `◈`-clause (the operator itself is task 795 and out of scope here).
`def:nomic-properties` gives three conditions: *Lawful* (`τ ∈ H_F^{τ(x)}` for all `τ ∈ H_F`,
`x ∈ D`), *Static* (`H_F^{τ(x)} = H_F^{τ(y)}` for all `τ ∈ H_F`, `x, y ∈ D`), *Uniform*
(`H_F^w = H_F` for all `w ∈ W`). `def:nomic-witnesses` fixes the ℤ-time presentation: `R_w :=
⇒_1^w`, `⇒_n^w := (R_w)^n` for `n ≥ 0`, reflection convention for `n < 0`. `lem:nomic-occurrence`,
`lem:nomic-recovery` and `prop:nomic-hierarchy`'s three witnesses are the results to port.
`rmk:choice` records that both nomic lemmas go through Zorn via `thm:extension`.

### What exists in the tree

Nothing nomic. `grep -rin nomic --include=*.lean` over `FormalSystem/` and `Tests/` returns one
real hit: `FormalSystem/OpenLanguage.lean:88`, which lists "**The nomic operator**, over a
four-place task relation `⇒ʷ` indexed by world states" under the manuscript operators without a
formalization. `docs/reference/paper-definitions-of-record.md` mentions the nomic operator once,
in the `sub:RestrictedModalities` KNOWN-ANCHORS note, as *not* formalized. No `nomic-*` anchor row
exists in either the MANIFEST or the KNOWN-ANCHORS block.

What *does* exist is the entire substrate the port needs, and it fits without adaptation.

## Findings

### Codebase Patterns

**The fibre/total-space split is what makes `def:nomic-frame` cheap.**
`FormalSystem/Semantics/TaskFrame.lean:1055` declares `FrameOver (D : TemporalOrder)` with exactly
two data fields — `WorldState : Type`, an instance-implicit `[worldNonempty]`, and `PosRel :
WorldState → D.PositiveCone → WorldState → Prop` — and `TaskFrame` (`:2571`) is
`Σ (D : TemporalOrder), FrameOver D`. The four `def:frame` constraints are **not** fields: they
live in `class FrameOver.IsRegular` (`:1172`), re-exported as `F.comp`, `F.serial`, `F.limit`,
`F.saturation`. A nomic frame is therefore one carrier plus a `w`-indexed `PosRel`, and `F^w` is a
two-field record built from them.

**The derived relation and its reflection convention are already named.**
`FrameOver.TaskRel := TaskFrame.reflect PosRel` (`:1115`), with `taskRel_of_nonneg`,
`taskRel_of_neg`, the derived reflection law `FrameOver.reflection` (`:1404`), and
`FrameOver.nullity_identity` (`:1324`, `lem:nullity`: `TaskRel w 0 u ↔ w = u`). `lem:nullity` is
therefore *not* transcribed again — it is a theorem available on every regular frame, the same
economy `DeterministicBridge.lean`'s docstring records for the paper's Step 1.

**`thm:extension` and `cor:occurrence` are frame-intrinsic and ready.**
`PartialHistory.extension (F : TaskFrame) [F.IsRegular] (τ : PartialHistory F) : ∃ σ :
WorldHistory F, Extends σ.val τ` (`Extension/Extension.lean:240`) and
`PartialHistory.occurrence (F) [F.IsRegular] (w) (x) : ∃ τ : WorldHistory F, τ.state x = w`
(`:341`). `lem:nomic-occurrence` is a one-line wrapper on the latter at `F.at w`, exactly as the
dispatch states; the paper's own proof is the same one-liner.

**The two-point partial history already has a worked precedent.**
`Semantics/DeterministicBridge.lean:146-165` builds `{⟨0,w⟩, ⟨x,z⟩}` with `domain := fun t => t =
0 ∨ t = x`, `states := fun t _ => if t = x then z else w`, discharging the four `respects_task`
branches by `nullity_identity`, the hypothesis, `F.reflection` and `nullity_identity` again — the
paper's `lem:nomic-recovery` wording ("the pair `⟨d,0⟩` is the same fact under the reflection
convention") verbatim. Decidability is free: `F.Duration` is a `LinearOrder`, so the `if` needs no
`Classical`. That block is inline in a proof; this task needs it as a **named lemma** (see
Recommendations).

**`FrameOver.ofStep` *is* `def:nomic-witnesses`, per-world.**
`Semantics/IntNormalForm.lean:456`: `ofStep {W} [Finite W] [Nonempty W] (R₁ : W → W → Prop) (fwd)
(bwd) : FrameOver intOrder`, whose relation is `ofStepRel R₁ w d u := (0 ≤ d → iter R₁ d.natAbs w
u) ∧ (d ≤ 0 → iter R₁ d.natAbs u w)` — literally `⇒_n^w = (R_w)^n` with the reflection convention
for `n < 0`. Its constraint discharges are the paper's own: *Compositionality* from `iter_add`,
*Limit* from `limit_of_succOrder` (ℤ is a `SuccOrder`), **`Saturation` from
`TaskFrame.saturation_of_finite`** (the route the dispatch names, and `ofStep` already takes it),
and *Seriality* as the only genuine hypothesis — which is exactly the paper's "each `R_w` below is
total and surjective". `ofStep_step` recovers `R₁`, and the auto-instance `ofStep_isRegular` makes
regularity free.

**History membership over ℤ.** `FrameOver.mem_HF_iff_adjacent (F) [F.IsRegular] (f : ℤ →
F.WorldState) : (∃ τ : WorldHistory F, τ.path = f) ↔ IsStepPath F f` (`IntNormalForm.lean:348`)
and its sibling `isTotal_respects_iff_adjacent (F) (f) : (∀ s t : ℤ, F.TaskRel (f s) (t - s) (f
t)) ↔ IsStepPath F f` (`:362`). **The sibling is the better fit** and is a refinement on the
dispatch's naming: `lawHist` is defined as the all-pairs predicate on a bare function, which is
`isTotal_respects_iff_adjacent`'s left-hand side on the nose, so the bridge is a single term with
no `WorldHistory` detour. `mem_HF_iff_adjacent` remains reachable through `mem_lawHist_iff`, and
both are in the same module, so neither is an extra import.

**A worked small-finite-ℤ witness exists to copy.** `OpenLanguage/OpenOckhamist.lean:130-145`:
`inductive SinkState | a | b | c deriving DecidableEq`, a hand-written `Fintype` instance
(`elems := {a,b,c}`, `complete := by intro x; cases x <;> simp`), a `Nonempty` instance, and
`abbrev sinkFrame := FrameOver.ofStep …`. `deriving Fintype` is used nowhere in the tree; the
hand-written instance is the house pattern. (A nomic witness needs no `abbrev` trick: its carrier
is a *field*, so `F.World` is the inductive by definition.)

**Independence-theorem style.** `Semantics/FrameConstraintIndependence.lean` states per-witness
named theorems (`emptyRel_not_serial`, `totalRel_not_limit`, `rayRel_not_saturation`), not bundled
existentials. `prop:nomic-hierarchy` should follow: two general implications plus three
`{witness}_static` / `{witness}_not_lawful` pairs, with an optional bundled existential on top.

### External Resources

No external search was needed: every lemma the paper's proofs invoke already has a name in this
tree. `lean_leansearch`/`loogle`/`leanfinder` were not called — all substrate was located by
`grep` and `Read`, then confirmed by compilation. Mathlib supplied only `Int.induction_on` (whose
case names in this pin are `zero`/`succ`/`pred`, **not** `hz`/`hp`/`hn`; the deprecated-alias
note at `BiLasso/Unfold.lean:178` records the same migration) and `Int.le_induction`.

### Recommendations

Every block below compiled under `lean_run_code` against the built project, with no `sorry`, no
error, and only two cosmetic lint warnings (noted inline). Line-length (100) and the `_`-prefix
convention for unused binders are the two adjustments needed on transcription.

#### R1. The structure, the derived family, and regularity

```lean
structure NomicFrame (D : TemporalOrder) where
  World : Type
  [worldNonempty : Nonempty World]
  PosRel : World → World → D.PositiveCone → World → Prop

attribute [instance] NomicFrame.worldNonempty

variable {D : TemporalOrder}

-- Declared with its dotted name OUTSIDE `namespace NomicFrame`: `at` is a reserved token.
def NomicFrame.at (F : NomicFrame D) (w : F.World) : FrameOver D where
  WorldState := F.World
  PosRel := F.PosRel w

namespace NomicFrame

class IsRegular (F : NomicFrame D) : Prop where
  regular : ∀ w : F.World, (F.at w).IsRegular

instance instAtIsRegular (F : NomicFrame D) [h : F.IsRegular] (w : F.World) :
    (F.at w).IsRegular := h.regular w

def TaskRel (F : NomicFrame D) (w : F.World) : F.World → ↑D → F.World → Prop :=
  (F.at w).TaskRel

theorem taskRel_eq (F : NomicFrame D) (w : F.World) : F.TaskRel w = (F.at w).TaskRel := rfl
```

`instAtIsRegular` is the load-bearing line: it is what lets every `FrameOver`-level theorem
(`nullity_identity`, `reflection`, `extension`, `occurrence`) fire at `F.at w` with no argument
passed. Keep `NomicFrame.at` a plain `def`, **not** `@[reducible]`: synthesis keys
`instAtIsRegular` on `FrameOver.IsRegular (F.at w)`, and the `ofReflectiveRegular` docstring
(`TaskFrame.lean:1481`) records what reducibility does to such a key.

#### R2. Law-histories, `H_F`, and the `WorldHistory` bridge

```lean
def lawHist (F : NomicFrame D) (w : F.World) : Set (↑D → F.World) :=
  {τ | ∀ x y, F.TaskRel w (τ x) (y - x) (τ y)}

def HF (F : NomicFrame D) : Set (↑D → F.World) := ⋃ w, F.lawHist w

theorem mem_lawHist_iff (F : NomicFrame D) (w : F.World) (τ : ↑D → F.World) :
    τ ∈ F.lawHist w ↔ ∃ σ : WorldHistory (F.at w).toTaskFrame, σ.state = τ := by
  constructor
  · intro h
    exact ⟨WorldHistory.ofTotal _ τ (fun s t => h s t), rfl⟩
  · rintro ⟨σ, rfl⟩
    intro x y
    exact σ.respects_task x y
```

`WorldHistory.ofTotal` + `WorldHistory.respects_task` are both already in
`PartialHistory.lean`; the bridge needs nothing new. `HF` membership is opened and closed with
`Set.mem_iUnion`.

#### R3. The three properties and the two trivial implications

```lean
def Lawful  (F : NomicFrame D) : Prop := ∀ τ ∈ F.HF, ∀ x, τ ∈ F.lawHist (τ x)
def Static  (F : NomicFrame D) : Prop := ∀ τ ∈ F.HF, ∀ x y, F.lawHist (τ x) = F.lawHist (τ y)
def Uniform (F : NomicFrame D) : Prop := ∀ w, F.lawHist w = F.HF

theorem static_of_uniform {F : NomicFrame D} (h : F.Uniform) : F.Static := by
  intro τ _ x y; rw [h, h]

theorem lawful_of_uniform {F : NomicFrame D} (h : F.Uniform) : F.Lawful := by
  intro τ hτ x; rw [h]; exact hτ
```

These are `prop:nomic-hierarchy`'s first sentence, and they are two tactics each.

#### R4. `lem:nomic-occurrence`

```lean
theorem occurrence (F : NomicFrame D) [F.IsRegular] (w u : F.World) (x : ↑D) :
    ∃ τ ∈ F.lawHist w, τ x = u := by
  obtain ⟨σ, hσ⟩ := PartialHistory.occurrence (F.at w).toTaskFrame u x
  exact ⟨σ.state, (F.mem_lawHist_iff w σ.state).mpr ⟨σ, rfl⟩, hσ⟩
```

Exactly the paper's proof: `F^w` is a task frame, so `cor:occurrence` applies at it. Choice-bearing
through `thm:extension`, per `rmk:choice`; the docstring must say so and must not advertise it as
choice-free.

#### R5. The two-point history, as a named general lemma over `TaskFrame`

```lean
theorem exists_worldHistory_two_point (F : TaskFrame) [F.IsRegular]
    (p q : F.WorldState) {d : F.Duration} (hd : (0 : F.Duration) ≠ d)
    (hpq : F.TaskRel p d q) :
    ∃ σ : WorldHistory F, σ.state 0 = p ∧ σ.state d = q := by
  have h0d : (if (0 : F.Duration) = d then q else p) = p := if_neg hd
  have hdd : (if d = d then q else p) = q := if_pos rfl
  have hresp : ∀ (s t : F.Duration), (s = 0 ∨ s = d) → (t = 0 ∨ t = d) →
      F.TaskRel (if s = d then q else p) (t - s) (if t = d then q else p) := by
    intro s t hs ht
    rcases hs with hs | hs <;> rcases ht with ht | ht <;> rw [hs, ht]
    · rw [h0d, sub_zero]; exact (F.nullity_identity p p).mpr rfl
    · rw [h0d, hdd, sub_zero]; exact hpq
    · rw [h0d, hdd, zero_sub]; exact (F.reflection p d q).mp hpq
    · rw [hdd, sub_self]; exact (F.nullity_identity q q).mpr rfl
  obtain ⟨σ, hext⟩ := PartialHistory.extension F
    { domain := fun t => t = 0 ∨ t = d
      nonempty_domain := ⟨0, Or.inl rfl⟩
      states := fun t _ => if t = d then q else p
      respects_task := fun s t hs ht => hresp s t hs ht }
  exact ⟨σ, (hext.agree 0 (Or.inl rfl)).trans h0d, (hext.agree d (Or.inr rfl)).trans hdd⟩
```

**Why a general lemma rather than an inline block.** Stating it with `p q : F.WorldState` is what
avoids a type mismatch that is otherwise unavoidable: an inline construction at `F.at w` elaborates
the `if`-terms at `(F.at w).WorldState` while the surrounding `have`s state them at `F.World`, and
`rw` then fails with `Application type mismatch … expected (F.at w).WorldState` on all four
branches. That failure was observed, then removed by this factoring. **Site**: put it in the new
nomic cluster with a docstring noting it belongs beside `PartialHistory.point` / `occurrence` in
`Extension/Extension.lean` and can be promoted there once that file is free (it is in task 756's
`file_scope` now), at which point `DeterministicBridge.lean:146-165`'s inline `key` block becomes a
one-line call. Do not refactor `DeterministicBridge.lean` in this task.

#### R6. `lem:nomic-recovery`, in full

```lean
theorem taskRel_imp_of_lawHist_eq (F : NomicFrame D) [F.IsRegular] {w u : F.World}
    (h : F.lawHist w = F.lawHist u) {p q : F.World} {d : ↑D}
    (hpq : F.TaskRel w p d q) : F.TaskRel u p d q := by
  have pos : ∀ (p q : F.World) (d : ↑D), 0 < d → F.TaskRel w p d q → F.TaskRel u p d q := by
    intro p q d hd hpq
    obtain ⟨σ, h0, hdq⟩ :=
      exists_worldHistory_two_point (F.at w).toTaskFrame p q (ne_of_lt hd) hpq
    have hmem : σ.state ∈ F.lawHist u := h ▸ (F.mem_lawHist_iff w σ.state).mpr ⟨σ, rfl⟩
    have hres := hmem 0 d
    rwa [h0, hdq, sub_zero] at hres
  rcases lt_trichotomy d 0 with hlt | heq | hgt
  · have hrefl : F.TaskRel w q (-d) p := ((F.at w).reflection p d q).mp hpq
    have hpos := pos q p (-d) (by simpa using hlt) hrefl
    exact ((F.at u).reflection p d q).mpr hpos
  · subst heq
    have hpq' : p = q := ((F.at w).nullity_identity p q).mp hpq
    exact ((F.at u).nullity_identity p q).mpr hpq'
  · exact pos p q d hgt hpq

theorem lawHist_eq_iff_taskRel_eq (F : NomicFrame D) [F.IsRegular] (w u : F.World) :
    F.lawHist w = F.lawHist u ↔ F.TaskRel w = F.TaskRel u := by
  constructor
  · intro h
    funext p d q
    exact propext ⟨fun hpq => F.taskRel_imp_of_lawHist_eq h hpq,
      fun hpq => F.taskRel_imp_of_lawHist_eq h.symm hpq⟩
  · intro h
    simp only [lawHist, h]
```

The case split is the paper's, in the paper's order of content: `d = 0` by `nullity_identity` at
`F^w` and at `F^u`; `d > 0` through the two-point history and `thm:extension` at `F^w`; `d < 0` by
the reflection convention reducing to the positive case. The `⇐` direction is `simp only [lawHist,
h]` — "immediate from `def:nomic-frame`, since `H_F^w` is defined purely in terms of `⇒^w`" is
literally true of the Lean definition. The symmetric inclusion the paper gets "by symmetry" is
`h.symm` into the same helper, which is why the helper is a separate named theorem.

#### R7. `def:nomic-witnesses`: the ℤ-time presentation

```lean
def ofStepFamily {W : Type} [Finite W] [Nonempty W] (R : W → W → W → Prop)
    (_fwd : ∀ w p, ∃ q, R w p q) (_bwd : ∀ w q, ∃ p, R w p q) : NomicFrame intOrder where
  World := W
  PosRel := fun w p x q => ofStepRel (R w) p (x : ℤ) q

theorem ofStepFamily_at {W : Type} [Finite W] [Nonempty W] {R : W → W → W → Prop}
    {fwd : ∀ w p, ∃ q, R w p q} {bwd : ∀ w q, ∃ p, R w p q} (w : W) :
    (ofStepFamily R fwd bwd).at w = FrameOver.ofStep (R w) (fwd w) (bwd w) := rfl

instance ofStepFamily_isRegular {W : Type} [Finite W] [Nonempty W] (R : W → W → W → Prop)
    (fwd : ∀ w p, ∃ q, R w p q) (bwd : ∀ w q, ∃ p, R w p q) :
    (ofStepFamily R fwd bwd).IsRegular where
  regular w := FrameOver.ofStep_isRegular (R w) (fwd w) (bwd w)

theorem mem_lawHist_iff_isStepPath (F : NomicFrame intOrder) [F.IsRegular] (w : F.World)
    (τ : ℤ → F.World) : τ ∈ F.lawHist w ↔ IsStepPath (F.at w) τ :=
  FrameOver.isTotal_respects_iff_adjacent (F.at w) τ

theorem mem_lawHist_ofStepFamily_iff {W : Type} [Finite W] [Nonempty W] {R : W → W → W → Prop}
    {fwd : ∀ w p, ∃ q, R w p q} {bwd : ∀ w q, ∃ p, R w p q} (w : W) (τ : ℤ → W) :
    τ ∈ (ofStepFamily R fwd bwd).lawHist w ↔ ∀ n : ℤ, R w (τ n) (τ (n + 1)) := by
  refine Iff.trans (mem_lawHist_iff_isStepPath (ofStepFamily R fwd bwd) w τ) ?_
  exact forall_congr' fun n => FrameOver.ofStep_step (R w) (fwd w) (bwd w) (τ n) (τ (n + 1))
```

Three points carried by the probe. `ofStepFamily_at` holds **by `rfl`** — the family's `w`-th
member is `ofStep (R w)` on the nose, which is what makes every ℤ-normal-form lemma apply
unchanged. `regular w := FrameOver.ofStep_isRegular …` typechecks as a bare term (an earlier
`rw [ofStepFamily_at w]` attempt failed on `Finite (ofStepFamily R fwd bwd).World` synthesis —
use the term, not the rewrite). And `mem_lawHist_ofStepFamily_iff` must go through
`refine Iff.trans … ?_` rather than `rw`: the membership's type is `↑intOrder → (ofStepFamily
…).World`, which `rw` will not match against a `ℤ → W` binder, while `refine`/`exact` close it up
to defeq (the `SlicedFrame.lean:360` pattern). The `_fwd`/`_bwd` underscores follow
`ofReflectiveRegular`'s `_hcomp` convention — the arguments are needed in the signature, consumed
only by the lemmas above.

#### R8. The ℤ step-path invariant helpers

```lean
theorem stepPath_invariant {W : Type} {R : W → W → Prop} {τ : ℤ → W}
    (h : ∀ n : ℤ, R (τ n) (τ (n + 1))) {P : W → Prop}
    (hstep : ∀ p q, R p q → (P p ↔ P q)) (n₀ : ℤ) (h₀ : P (τ n₀)) (n : ℤ) : P (τ n) := by
  have key : ∀ k : ℤ, P (τ (n₀ + k)) := by
    intro k
    induction k using Int.induction_on with
    | zero => simpa using h₀
    | succ i ih =>
      have hi := hstep _ _ (h (n₀ + i))
      rw [show n₀ + ((i : ℤ) + 1) = n₀ + (i : ℤ) + 1 from by omega]
      exact hi.mp ih
    | pred i ih =>
      have hi := hstep _ _ (h (n₀ + (-(i : ℤ) - 1)))
      rw [show n₀ + (-(i : ℤ) - 1) + 1 = n₀ + -(i : ℤ) from by omega] at hi
      exact hi.mpr ih
  have hk := key (n - n₀)
  rwa [show n₀ + (n - n₀) = n from by omega] at hk
```

`omega`, not `ring`, for the three index identities (`ring` failed on
`n₀ + (↑i + 1) = n₀ + ↑i + 1` in the probe). This single helper carries witnesses 1 and 3 and half
of witness 2. **Witness 2 additionally needs a forward-only companion**, since its separating
argument ("once at `a`, always at `a` forward") is not a two-sided invariant:

```lean
theorem stepPath_forward_invariant {W : Type} {R : W → W → Prop} {τ : ℤ → W}
    (h : ∀ n : ℤ, R (τ n) (τ (n + 1))) {P : W → Prop}
    (hstep : ∀ p q, R p q → P p → P q) {n₀ : ℤ} (h₀ : P (τ n₀)) :
    ∀ n, n₀ ≤ n → P (τ n)
```
by `Int.le_induction`. **Not probed** — it is the one declaration in the plan whose proof was not
compiled during research, and it is a three-line `Int.le_induction` mirror of the `succ` branch
above.

#### R9. `prop:nomic-hierarchy`: witness 1, complete and verified

```lean
inductive W3 | a | b | c
  deriving DecidableEq

instance : Nonempty W3 := ⟨W3.a⟩

instance : Fintype W3 where
  elems := {W3.a, W3.b, W3.c}
  complete := by intro x; cases x <;> simp

/-- `R_a = R_b` is the identity; `R_c` swaps `a` and `b` and fixes `c`. -/
def R1 (w : W3) : W3 → W3 → Prop :=
  match w with
  | .c => fun p q => (p = .a ∧ q = .b) ∨ (p = .b ∧ q = .a) ∨ (p = .c ∧ q = .c)
  | _ => Eq

theorem R1_fwd : ∀ w p, ∃ q, R1 w p q := by
  intro w p
  cases w with
  | a => exact ⟨p, rfl⟩
  | b => exact ⟨p, rfl⟩
  | c => cases p with
    | a => exact ⟨.b, Or.inl ⟨rfl, rfl⟩⟩
    | b => exact ⟨.a, Or.inr (Or.inl ⟨rfl, rfl⟩)⟩
    | c => exact ⟨.c, Or.inr (Or.inr ⟨rfl, rfl⟩)⟩

theorem R1_bwd : ∀ w q, ∃ p, R1 w p q := by
  intro w q
  cases w with
  | a => exact ⟨q, rfl⟩
  | b => exact ⟨q, rfl⟩
  | c => cases q with
    | a => exact ⟨.b, Or.inr (Or.inl ⟨rfl, rfl⟩)⟩
    | b => exact ⟨.a, Or.inl ⟨rfl, rfl⟩⟩
    | c => exact ⟨.c, Or.inr (Or.inr ⟨rfl, rfl⟩)⟩

def F1 : NomicFrame intOrder := NomicFrame.ofStepFamily R1 R1_fwd R1_bwd

theorem F1_lawHist_a_eq_b : F1.lawHist W3.a = F1.lawHist W3.b := rfl

theorem F1_const_of_mem_a {τ : ℤ → W3} (h : τ ∈ F1.lawHist W3.a) (n : ℤ) : τ n = τ 0 := by
  have hstep := (NomicFrame.mem_lawHist_ofStepFamily_iff W3.a τ).mp h
  exact NomicFrame.stepPath_invariant hstep
    (P := fun u => u = τ 0) (fun p q hpq => by subst hpq; exact Iff.rfl) 0 rfl n

theorem F1_c_invariant {τ : ℤ → W3} (h : τ ∈ F1.lawHist W3.c) (n : ℤ) :
    (τ n = W3.c ↔ τ 0 = W3.c) := by
  have hstep := (NomicFrame.mem_lawHist_ofStepFamily_iff W3.c τ).mp h
  refine NomicFrame.stepPath_invariant hstep
    (P := fun u => (u = W3.c ↔ τ 0 = W3.c)) ?_ 0 Iff.rfl n
  intro p q hpq
  rcases hpq with ⟨hp, hq⟩ | ⟨hp, hq⟩ | ⟨hp, hq⟩ <;> subst hp <;> subst hq <;> simp

theorem F1_static : F1.Static := by
  intro τ hτ x y
  obtain ⟨w, hw⟩ := Set.mem_iUnion.mp hτ
  cases w with
  | a => rw [F1_const_of_mem_a hw x, F1_const_of_mem_a hw y]
  | b =>
    have hw' : τ ∈ F1.lawHist W3.a := F1_lawHist_a_eq_b ▸ hw
    rw [F1_const_of_mem_a hw' x, F1_const_of_mem_a hw' y]
  | c =>
    by_cases h0 : τ 0 = W3.c
    · rw [(F1_c_invariant hw x).mpr h0, (F1_c_invariant hw y).mpr h0]
    · have hx : τ x ≠ W3.c := fun hc => h0 ((F1_c_invariant hw x).mp hc)
      have hy : τ y ≠ W3.c := fun hc => h0 ((F1_c_invariant hw y).mp hc)
      cases hxv : τ x <;> cases hyv : τ y <;>
        first
          | rfl
          | exact F1_lawHist_a_eq_b
          | exact F1_lawHist_a_eq_b.symm
          | exact absurd hxv hx
          | exact absurd hyv hy

/-- The alternating path: `a` at even times, `b` at odd times. -/
def alt : ℤ → W3 := fun n => if n % 2 = 0 then W3.a else W3.b

theorem alt_mem_c : alt ∈ F1.lawHist W3.c := by
  refine (NomicFrame.mem_lawHist_ofStepFamily_iff W3.c alt).mpr ?_
  intro n
  by_cases h : n % 2 = 0
  · have h1 : (n + 1) % 2 ≠ 0 := by omega
    exact Or.inl ⟨by simp [alt, h], by simp [alt, h1]⟩
  · have h1 : (n + 1) % 2 = 0 := by omega
    exact Or.inr (Or.inl ⟨by simp [alt, h], by simp [alt, h1]⟩)

theorem F1_not_lawful : ¬ F1.Lawful := by
  intro h
  have hmem : alt ∈ F1.HF := Set.mem_iUnion.mpr ⟨W3.c, alt_mem_c⟩
  have h0 : alt 0 = W3.a := by simp [alt]
  have hla : alt ∈ F1.lawHist W3.a := by
    have := h alt hmem 0
    rwa [h0] at this
  have h1 := F1_const_of_mem_a hla 1
  rw [h0] at h1
  simp [alt] at h1
```

`F1_lawHist_a_eq_b` holding **by `rfl`** is the pleasant consequence of writing `R1` as a `match`
with `| _ => Eq`: `R1 .a` and `R1 .b` reduce to the same term, so `F1.at .a` and `F1.at .b` are
the same record and the two law-history sets are definitionally equal. The paper's "`H_F^a =
H_F^b`" is therefore free, not proved. Keep this shape for witness 3's `R_b = R_c` as well.
(The probe emitted two long-line lint warnings on the `refine … (P := …) ?_ 0 Iff.rfl n` lines;
reflow on transcription.)

#### R10. Witnesses 2 and 3: proof plans, not yet compiled

Both relations are transcribed directly from `prop:nomic-hierarchy` and both are bi-serial, so
`ofStepFamily` applies verbatim. The paths each proof must follow were worked out and checked by
hand against the paper; neither was compiled.

**Witness 2 — lawful but not static**, on `W = {a, b, e}` with `R_a = {(a,a),(b,b),(e,a),(e,e)}`,
`R_b = {(a,a),(b,b),(e,b),(e,e)}`, `R_e = R_a ∪ R_b`. This is the heaviest proof in the task.
*Lawful* needs, for `τ ∈ lawHist v` and each `x`, that `τ ∈ lawHist (τ x)`:
- `τ ∈ lawHist a`: `P u := (u = b)` *is* a two-sided `R_a`-invariant, so `τ x = b` forces `τ`
  constantly `b`, hence `τ ∈ lawHist b` by reflexivity of `R_b` at `b`. Otherwise `τ x ∈ {a, e}`,
  and `lawHist a ⊆ lawHist e` because `R_a ⊆ R_e` (a one-line monotonicity lemma worth naming:
  `lawHist_mono_of_le`, from `mem_lawHist_ofStepFamily_iff`). Mirror for `τ ∈ lawHist b`.
- `τ ∈ lawHist e`: the separating fact is that no `R_e`-path visits both `a` and `b` — forward
  from `a` only `a` is reachable, forward from `b` only `b` — which is `stepPath_forward_invariant`
  (R8) at `P u := (u = a)` and at `P u := (u = b)`. With `b` excluded, every step of `τ` lies in
  `R_a` (the `R_e`-pairs not mentioning `b` are exactly `(a,a),(e,a),(e,e) ⊆ R_a`), so
  `τ ∈ lawHist a`; symmetrically for `a` excluded.
*Not static*: `σ₀ᵃ := fun n => if n ≤ 0 then e else a` lies in `lawHist a ⊆ HF` with `σ₀ᵃ 0 = e`
and `σ₀ᵃ 1 = a`, while `σ₀ᵇ := fun n => if n ≤ 0 then e else b` lies in `lawHist e` and not in
`lawHist a` (its step at `n = 0` is `R_a e b`, which is false). So `Static` would equate
`lawHist e` with `lawHist a`.

**Witness 3 — static and lawful but not uniform**, on `W = {a, b, c}` with `R_a = Eq` and
`R_b = R_c = {(a,a)} ∪ ({b,c} × {b,c})`. Easier than witness 2 and structurally the mirror of
witness 1: `R_b ≡ R_c` by `rfl` (same `match` body), `P u := (u = a)` is a two-sided
`R_b`-invariant, so every `τ ∈ lawHist b` is either constantly `a` or never `a`. *Static* and
*Lawful* then split on exactly that, with `lawHist a` the constants (by `stepPath_invariant` at
`R_a = Eq`, as in `F1_const_of_mem_a`) and constants lying in every `lawHist w` by reflexivity of
each `R_w`. *Not uniform*: the alternating `b`/`c` path (an `alt`-shaped definition) lies in
`HF` via `lawHist b` but not in `lawHist a`, which would force `τ 0 = τ 1`.

**Statement style** (per `FrameConstraintIndependence.lean`): per-witness named theorems
`F1_static` / `F1_not_lawful`, `F2_lawful` / `F2_not_static`, `F3_static` / `F3_lawful` /
`F3_not_uniform`, then the two general implications of R3, then — if a single citable name for the
anchor is wanted — one bundled `nomic_hierarchy` conjunction of three existentials, each bundling
its witness's `IsRegular` instance as `∃ _ : F.IsRegular, …`.

#### R11. `thm:nomic-primitive` (OPTIONAL — take clause (1) only, if at all)

The cut material (`appendix_cut_material.tex:554-612`, header
"Primitive-level characterization of the nomic frames") has four clauses. Their costs are very
different and the cut note itself records that clauses (3) and (4) "had no consumer".
- **(1) Static** — `F.Static ↔ ∀ v w u d, F.TaskRel v w d u → F.TaskRel w = F.TaskRel u`. Cheap
  **once R5 and R6 are in**: `⇒` is the two-point history plus `lawHist_eq_iff_taskRel_eq`; `⇐` is
  the definition of `lawHist` plus the same biconditional. Recommend taking this one.
- **(2) Lawful** — a three-point condition. Needs a **three-point** partial history
  (`{⟨0,w⟩,⟨e,p⟩,⟨e+d,q⟩}`) whose well-definedness argument is genuinely new: coinciding times must
  be shown to force coinciding states via `lem:nullity`, and the nested-`if` state function has to
  be proved to agree on every coincidence. Recommend attempting only if phases 1-5 close early;
  this is not "cheap once (4) is in".
- **(3), (4)** — out of scope. Consumerless in the paper, and (4) adds a finite-ℤ-path
  reformulation that duplicates R7's adjacency bridge.

## Decisions

1. **Carrier as a field, family as a derived definition.** `at : W → FrameOver D` cannot be a
   structure field (each member's `WorldState` must be the index type); the alternative — a field
   `at` plus a transport hypothesis `∀ w, (at w).WorldState = World` — was rejected as it makes
   every consumer transport along an equality of types. Verified by compilation.
2. **Regularity as a class, not fields.** Mirrors `FrameOver`/`FrameOver.IsRegular` and keeps a
   partially-constrained nomic frame expressible, which `TaskFrame.lean:1172`'s docstring records as
   the reason that split exists.
3. **`lawHist` over bare functions `↑D → F.World`**, with `mem_lawHist_iff` as the only bridge to
   `WorldHistory`. The alternative (`Set (WorldHistory (F.at w))`) cannot be unioned over `w`.
4. **`isTotal_respects_iff_adjacent`, not `mem_HF_iff_adjacent`, is the primary ℤ bridge** — a
   refinement on the dispatch's naming, because `lawHist` is already the all-pairs predicate the
   former is stated about. `mem_HF_iff_adjacent` stays reachable through `mem_lawHist_iff`.
5. **The two-point history becomes a named general lemma over `TaskFrame`**, sited in the new
   cluster, because stating it at `F.World` rather than at `(F.at w).WorldState` is what makes the
   recovery proof go through at all.
6. **`NomicFrame.at` is declared with its dotted name outside `namespace NomicFrame`**, because
   `at` is a reserved token. The alternative name `frameAt` also compiles cleanly (it was the first
   probe's spelling) and remains the fallback if the dotted declaration is judged too awkward.
7. **Paper-side `% PORT:` / `\leanproof{}` edits are out of scope.** `possible_worlds.tex` is
   read-only input from another repository — the record file's own charter, and the ruling task 792
   already took for the same marker class. Name the new declarations so a later
   `\leanproof{\texttt{NomicFrame.…}}` needs no rename.

## Risks & Mitigations

| Risk | Mitigation |
|---|---|
| Gate C15 rejects docstring citations of the six new anchors | Add rows to `docs/reference/paper-definitions-of-record.md` before the gate run. The six `sha256` values are resolved below, so MANIFEST rows (`anchor\|env\|-\|-\|sha`) can be written directly; a KNOWN-ANCHORS `LIVE-UNPINNED` row also satisfies C15 if no docstring quotes the text verbatim. |
| That record file is in concurrent task 756's `file_scope` | Re-read immediately before editing; stage only this task's own hunk (`git add -- <file>` with the explicit path, never a directory or glob). Same for the one import line in `FormalSystem/Semantics.lean`. |
| `check-paper-definitions.sh` is already red (26 drifted anchors) | Pre-existing and unrelated. Do not absorb the wave. New rows carry current shas and land green on their own rows; the whole-file checksum sentinels must **not** be re-pinned (the record's own dirty-pin convention: re-pin only when absorbing a drift *correction*). |
| C8 (sibling aggregator), `readme-lint.sh` check 1 (README per directory), C33 (byte-current root) | Create `FormalSystem/Semantics/Nomic.lean` and `FormalSystem/Semantics/Nomic/README.md` in the same phase as the first module; run `lake exe mk_all --lib FormalSystem` and commit the regenerated root. |
| C34a/C34b (`Constraints consumed:` markers) | Every new theorem carrying `[F.IsRegular]` or `[NomicFrame.IsRegular]` and reading as a constraint claim needs a `Constraints consumed:` line. `occurrence` and the recovery lemmas consume all four (through `thm:extension`); `static_of_uniform` / `lawful_of_uniform` consume none and take no instance binder. |
| C14 (axiom-set baselines) and `rmk:choice` honesty | `occurrence`, `taskRel_imp_of_lawHist_eq` and `lawHist_eq_iff_taskRel_eq` are theorems of **ZFC** via `thm:extension`'s Zorn appeal; the witnesses' `Saturation` also goes through `saturation_of_finite`, which is choice-dependent. Say so in the docstrings and never advertise them as choice-free — `DeterministicBridge.lean`'s "Choice dependence, recorded honestly" section is the model. Check whether any new declaration needs a C14 baseline row before the final gate run. |
| Witness 2's lawfulness is the one genuinely hard proof | It is isolated in its own phase, and its two helper lemmas (`stepPath_forward_invariant`, `lawHist_mono_of_le`) are small and independently statable. If it stalls, witnesses 1 and 3 plus the two general implications already discharge `prop:nomic-hierarchy`'s first sentence and the uniformity gap; only the staticity/lawfulness *independence* half would be outstanding, and that is a `[BLOCKED]` phase to raise, never a `sorry`. |
| `lean_local_search` index was `warming` throughout | Absence findings in this report rest on repository-wide `grep` sweeps, not on empty LSP results. Announced rather than treated as a negative finding. |
| Module length (1500-line linter) | Split as `Nomic/Frame.lean` (R1-R4), `Nomic/Recovery.lean` (R5-R6), `Nomic/Witnesses.lean` (R7-R10), with the aggregator importing all three. |

## Siting: the trade-off the dispatch asks to record

**Recommended: `FormalSystem/Semantics/Nomic/`.** A nomic frame is frame theory — it mentions no
object language, no formula and no model — and every tool it consumes (`FrameOver`,
`PartialHistory`, `Extension`, `IntNormalForm`) lives in `Semantics/`. `OpenLanguage/` imports
`Semantics/`, never the reverse, so task 795's `◈` operator and its truth clause can sit in
`OpenLanguage/` and import the frames; siting the frames under `OpenLanguage/` instead would make a
purely frame-theoretic notion a dependent of the open-language cluster and would put
`def:nomic-frame` in a directory whose other modules are all about formulas.

**The cost of that choice**, stated honestly: the operator of task 795 will then live in a
different directory from its frames, so task 795 carries one extra import and the two halves of the
nomic appendix are not co-located. The alternative — one `OpenLanguage/Nomic/` cluster holding both
— buys that co-location at the price of the dependency inversion above and of making the frames
unavailable to any future purely-semantic consumer that does not want `OpenLanguage`'s imports. The
import direction is the deciding argument.

## Paper anchors: resolved rows for the record file

Resolved against the live paper with `bash scripts/check-paper-definitions.sh --resolve
'<anchor>|env|-|-'` during this research. All six are `env` anchors with no enclosing environment
and no locator, so each MANIFEST row reads `<anchor>|env|-|-|<sha256>`:

| anchor | sha256 |
|---|---|
| `def:nomic-frame` | `60fdc0699603f6fd5f2a10f4e6ee8e17e96d569657e24e8b888849f6d914f60f` |
| `def:nomic-properties` | `10c70b4fbcb954f2771ed6afe41dfdfeb86a69b87ea05cc03a2044f49e0b1b8d` |
| `def:nomic-witnesses` | `3f2b3ad26238cc701fcce96aa3054c5d7172446bcb29b0a2fe0425eac9db4ae2` |
| `prop:nomic-hierarchy` | `7eb2c665feef36bfc6e16b4676292cc2442a85e714d3321fe1bef87737f7779a` |
| `lem:nomic-occurrence` | `be1804f3a08925d84878066a16f635555e0edc1d42f39b8ab3b28b7ba35efaad` |
| `lem:nomic-recovery` | `3f7df2521f4b222f19cd055cde9767ac441c8b199fad3b67a1819a0199b768e5` |

`thm:nomic-primitive` lives in `appendix_cut_material.tex`, which the record does not track; if
clause (1) is taken, cite it as cut material by file and header, not as a paper anchor, so C15 is
not asked to resolve it.

## Literature Proof Structure

**Source**: `~/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex`, the nomic appendix
(`def:nomic-frame` through `lem:nomic-recovery`), with `thm:nomic-primitive` from
`appendix_cut_material.tex`.
**Strategy**: definitional transcription, then two lemmas proved by constructing a partial history
and extending it (`thm:extension`), then three explicit finite ℤ-time countermodels.

### Step Map

1. Relativise the task relation: one `⇒^w` per world state, each a task frame — `def:nomic-frame`.
2. Define `H_F^w` as the total functions respecting `⇒^w` at all pairs, and `H_F` as their union —
   `def:nomic-frame`, Law-Histories item.
3. Define Lawful / Static / Uniform — `def:nomic-properties`.
4. Uniform ⟹ Static and Uniform ⟹ Lawful, by substituting `H_F` for each `H_F^w` —
   `prop:nomic-hierarchy`, first paragraph.
5. Every state occurs at every time along some law-history: `cor:occurrence` at `F^w` —
   `lem:nomic-occurrence`.
6. Equal law-history sets iff equal relativised relations — `lem:nomic-recovery`. Three cases:
   `d = 0` by `lem:nullity`; `d > 0` by the two-point partial history `{⟨0,p⟩,⟨d,q⟩}` over `F^w`
   extended by `thm:extension`; `d < 0` by the reflection convention of `def:task-relation`.
7. Fix the ℤ-time presentation `⇒_n^w = (R_w)^n` — `def:nomic-witnesses`.
8. Three witnesses, each on a three-element carrier, each `R_w` total and surjective so that
   *Seriality* holds, *Compositionality* automatic for iterates, *Limit* from `(w)_1 = {w}`,
   *Saturation* free on a finite `W` by `cor:saturation-finite` — `prop:nomic-hierarchy`.
9. *(cut)* Primitive-level forms of Static (two-point equation) and Lawful (three-point condition)
   — `thm:nomic-primitive` (1), (2).

### Dependencies

- Step 5 depends on Step 2 and on `cor:occurrence`/`thm:extension`.
- Step 6 depends on Steps 1-2, `lem:nullity`, `thm:extension`, and the reflection convention.
- Step 8 depends on Steps 2-3 and 7, and on `cor:saturation-finite`.
- Step 9 depends on Step 6 (both clauses route through `lem:nomic-recovery`).
- `rmk:choice` applies to Steps 5, 6 and 9: ZFC, not ZF.

### Potential Formalization Challenges, and how each is answered

- *Step 1 (the relativised family)*: the index type and each member's carrier must coincide.
  Answered by R1 (carrier as a field) — compiled.
- *Step 2 (one history type over `W`)*: answered by R2 (`Set (↑D → F.World)` + `mem_lawHist_iff`)
  — compiled.
- *Step 6, `d > 0` (the two-point domain `{0,d}` is not convex)*: the construction must run at the
  `PartialHistory` layer, with `thm:extension` and not `cor:occurrence` as the tool — the ruling
  `DeterministicBridge.lean` already recorded for the identical shape. Answered by R5 — compiled.
- *Step 8 (bi-infinite path reasoning on a finite carrier)*: answered by R7's adjacency bridge plus
  R8's invariant helpers; the paper's informal "every possible world stays within `{a,b}` or is
  constant at `c`" becomes a two-sided step-path invariant. Witness 1 compiled; witness 2's
  "once at `a`, always at `a`" additionally needs the forward-only companion.
- *Step 9 clause (2)*: the three-point history's well-definedness under coinciding times is the one
  step with no existing precedent in the tree. Deferred (R11).

## Tactic Survey Results

Candidates were tested by compiling whole declarations with `lean_run_code` rather than by
`lean_multi_attempt` at a position, since no target file exists yet; the results below are the ones
that affect the plan.

| Goal | Tactic | Result | Premises/Config |
|---|---|---|---|
| `Uniform → Static` | `intro τ _ x y; rw [h, h]` | success | `Uniform` as a rewrite |
| `Uniform → Lawful` | `intro τ hτ x; rw [h]; exact hτ` | success | — |
| `mem_lawHist_iff` (→) | `exact ⟨WorldHistory.ofTotal _ τ (fun s t => h s t), rfl⟩` | success | `WorldHistory.ofTotal` |
| `lem:nomic-recovery` (⇐) | `simp only [lawHist, h]` | success | the relation equation |
| `lawHist` ↔ `IsStepPath` | `exact FrameOver.isTotal_respects_iff_adjacent (F.at w) τ` | success | one term, no tactic |
| same, via `rw [mem_lawHist_iff_isStepPath]` | `rw` | **fail** | membership type is `↑intOrder → (…).World`; use `refine Iff.trans … ?_` |
| `ofStepFamily` regularity | `regular w := FrameOver.ofStep_isRegular …` (term) | success | — |
| same, via `rw [ofStepFamily_at w]; exact …` | `rw` + `exact` | **fail** | `Finite (ofStepFamily R fwd bwd).World` not synthesized |
| index identities in `stepPath_invariant` | `omega` | success | — |
| same | `ring` | **fail** | `n₀ + (↑i + 1) = n₀ + ↑i + 1` not closed |
| `Int.induction_on` case names | `zero` / `succ` / `pred` | success | `hz`/`hp`/`hn` are **rejected** on this pin |
| `(n + 1) % 2 ≠ 0` from `n % 2 = 0` | `omega` | success | — |
| `alt n` evaluation | `simp [alt, h]` | success | `h : n % 2 = 0` or its negation |
| `Fintype W3` completeness | `intro x; cases x <;> simp` | success | `OpenOckhamist.lean` pattern |
| witness-1 four-way case split | `cases … <;> cases … <;> first \| rfl \| exact … \| exact absurd …` | success | `F1_lawHist_a_eq_b` |
| two-point `respects_task`, stated at `F.World` | `rw [h0d, …]` | **fail** | type mismatch vs `(F.at w).WorldState`; fixed by R5's factoring |
| `def at` inside `namespace NomicFrame` | — | **fail (parse)** | `at` is a reserved token; use `def NomicFrame.at` outside the namespace |

## Context Extension Recommendations

- **Topic**: reserved-token identifiers in Lean 4 declaration names.
  **Gap**: nothing in `context/project/lean4/` records that `at` (and the other tactic-syntax
  tokens) cannot head a `def` inside a namespace while the dotted form outside it parses.
  **Recommendation**: one row in `context/project/lean4/patterns/` noting the failure mode and both
  workarounds (dotted top-level declaration, or rename), with this task's probe as the evidence.
- **Topic**: `rw` versus `refine`/`exact` across a structure-field carrier.
  **Gap**: two of the three probe failures in this task were the same mistake — using `rw` where
  the two sides are defeq but not syntactically equal because one mentions `(F.at w).WorldState`
  and the other `F.World`.
  **Recommendation**: add the rule of thumb ("across a derived frame's carrier, `refine
  Iff.trans … ?_` / `exact`, never `rw`") to the Lean tactic guidance, citing
  `SlicedFrame.lean:360` as the in-tree precedent.

## Appendix

### Probes run (all against the built project, via `lean_run_code`)

1. R1-R4 (structure, `frameAt`, `IsRegular`, `TaskRel`, `lawHist`, `HF`, `mem_lawHist_iff`, three
   properties, two implications, `occurrence`) — **clean on the first attempt**, no diagnostics.
2. `def at` inside the namespace — parse error; `S.at` dotted form in a minimal snippet — clean.
3. R6 with an inline two-point history at `F.at w` — four `rw` type mismatches.
4. R5 as a standalone general lemma over `TaskFrame` — clean.
5. R6 rebuilt on R5 — clean, both directions of `lem:nomic-recovery`.
6. R7 + R8 — `ofStepFamily`, `ofStepFamily_at` (`rfl`), the regularity instance,
   `mem_lawHist_iff_isStepPath`, `mem_lawHist_ofStepFamily_iff` clean; `stepPath_invariant` failed
   on `ring`/`hz`-names, then clean under `omega` + `zero`/`succ`/`pred`.
7. R9 (witness 1, complete: carrier, `R1`, bi-seriality, `F1`, `F1_lawHist_a_eq_b` by `rfl`,
   `F1_const_of_mem_a`, `F1_c_invariant`, `F1_static`, `alt`, `alt_mem_c`, `F1_not_lawful`) —
   clean, two long-line lint warnings only.

### Gate and tooling commands the implementation will need

```bash
# scoped build, detached and guarded
bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Semantics.Nomic
# regenerate the library root after adding modules (gate C33)
lake exe mk_all --lib FormalSystem
# README presence per directory (gated check 1)
bash scripts/readme-lint.sh FormalSystem
# anchor resolution for the record rows
bash scripts/check-paper-definitions.sh --resolve 'def:nomic-frame|env|-|-'
# the invariant harness (C3 sorry-freedom, C8, C15, C33, C34)
bash scripts/check-module-invariants.sh
```

### Searches and greps used

- `grep -rin nomic --include=*.lean FormalSystem/ Tests/`; `grep -rln nomic docs/ .claude/context`
- `grep -n 'label{def:frame}|label{def:task-relation}|label{cor:occurrence}|label{thm:extension}|label{lem:nullity}|label{cor:saturation-finite}|label{def:world-history}' possible_worlds.tex`
- `grep -rn 'IsStepPath|mem_HF_iff_adjacent|two-point|ofLe |Int.induction_on|deriving.*Fintype'`
  over `FormalSystem/`
- `mcp__lean-lsp__lean_local_search "NomicFrame"` — `{"items":[],"index":"warming"}`; not treated
  as proof of absence (the grep sweeps above are the evidence of record)

### Paper line references

`possible_worlds.tex`: `:2683` `def:task-relation`, `:2695` `def:frame`, `:2712` `lem:nullity`,
`:2726` `cor:saturation-finite`, `:2789` `def:world-history`, `:2905` `thm:extension`, `:2919`
`cor:occurrence`, `:2933` `rmk:choice`, `:3561` `def:nomic-frame`, `:3573`
`def:nomic-properties`, `:3585` `def:nomic-witnesses`, `:3593` `prop:nomic-hierarchy` (proof
`:3597`-`:3622`, with the three witnesses at `:3605`, `:3609`, `:3620`), `:3624`
`lem:nomic-occurrence` (`% PORT:` at `:3629`), `:3638` `lem:nomic-recovery` (`% PORT:` at
`:3642`). `appendix_cut_material.tex:554-612`: `thm:nomic-primitive` under the header
"Primitive-level characterization of the nomic frames".
