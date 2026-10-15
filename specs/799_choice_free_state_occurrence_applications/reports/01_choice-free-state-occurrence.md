# Research Report: Task #799

**Task**: 799 - Choice-free `StateOccurs` for the state-set applications
**Started**: 2026-10-15T00:00:00Z
**Completed**: 2026-10-15T00:00:00Z
**Effort**: medium
**Dependencies**: the state-set pin task (landed: `StateOccurs.of_isRegular` and the three `_of_isRegular` corollaries are present in the tree)
**Sources/Inputs**:
- Codebase: `FormalSystem/Metalogic/Independence/{StateSetTruth,OrderTransfer,DeterminismUndefinable,DriftHistories,RealTranslationFrame,ArchimedeanSharpness}.lean`, `FormalSystem/Semantics/{TaskFrame,ShiftSet}.lean`, `FormalSystem/Semantics/Frames/Standard.lean`, `FormalSystem/Semantics/Correspondence/DurationFrames.lean`, `FormalSystem/MainResults.lean`, `scripts/check-module-invariants.sh`
- lean-lsp MCP: `lean_run_code` compiled probes (the strongest evidence tier available; no claim below rests on an LSP index lookup)
- Literature: `/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/appendix_cut_material.tex` (header "Footnote on the appeals to choice in lem:state-set"), `/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex` (`def:state-set`, `def:flow`, `lem:state-set`, `app:drift`, `cor:no-characterization`, `rmk:choice`, `lem:canonical-frames`)
**Artifacts**:
- `specs/799_choice_free_state_occurrence_applications/reports/01_choice-free-state-occurrence.md`
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **The paper's footnote is already discharged for the two applications it names.** "The applications below" in the cut footnote are `app:drift` and `cor:no-characterization`, i.e. `F°` and `F¹`. Both already discharge (H2) by explicit witness (`fzero_stateOccurs`, `f1_stateOccurs`) and neither routes through `cor:occurrence`, `thm:extension` or Zorn. **The audit of `DeterminismUndefinable.lean` finds nothing to move**: all four consumers already take the choice-free route, and their residual `Classical.choice` is carrier-borne (ℝ), exactly as that module's existing pin asserts.
- **Deliverable (2) as literally written is unachievable at `translationFrame`.** Measured: `translationFrame` itself reports `[propext, Classical.choice, Quot.sound]`. Since `#print axioms` traverses a declaration's *type* as well as its value, no theorem whose statement mentions `translationFrame D` can ever pin choice-free, however the witness is built. The sole choice source inside it is `TaskFrame.limit_of_shift`, whose own choice arrives through Mathlib's `exists_ne` and `abs_eq_zero`.
- **An absolute choice-free pin is nevertheless reachable, and was built and verified.** Routing the same deterministic translation flow through `ShiftSet` instead of `FrameOver.ofReflectiveRegular` — a generic `selfShift D : ShiftSet D` (`D` acting on itself), whose `sep` field carries *Limit* directly — yields frame, reference histories, (H1), (H2), the bridge, *Determined* and the validity corollary all at `[propext, Quot.sound]`, with **no `Classical.choice`**, over an arbitrary duration group. Every proof in this report compiled.
- **That route is not a detour: `(selfShift realTemporalOrder).frame = F1` by `rfl`** (verified). So the generic layer is literally the frame `cor:no-characterization` instantiates, and `f1_orderFlow`/`f1_stateOccurs` are its ℝ instances.
- **Recommended approach**: a new leaf module carrying (a) the generic choice-free `selfShift` layer with absolute `#print axioms` pins, and (b) the `translationFrame D` instances the `*Sharpness` consumers use, pinned *relatively* (profile equal to `translationFrame`'s own; the witness step adds nothing). Both halves verified to compile. A third, measured option — making `translationFrame` itself choice-free by one 10-line proof rewrite — is documented below with its real cost and is left as a user decision, not taken.

## Context & Scope

Researched: how to realise the paper's cut footnote to `lem:state-set` ("the appeals to `cor:occurrence`, and hence to Zorn's lemma, are inessential to the applications below, where a possible world through any given world state at any given time is exhibited explicitly as a translation") as Lean declarations whose `#print axioms` output is free of `Classical.choice`, for the frames the applications instantiate at.

Constraints honoured throughout: `OrderFlow` is not weakened; the two-hypothesis originals in `StateSetTruth.lean` are untouched; no attempt is made at a choice-free `occurrence` in general. All findings are measurements, not estimates: each axiom profile quoted below was produced by a compiled `#print axioms` run against the built library.

Out of scope by territory: `typst/generated/status.typ`, `typst/FormalFoundations.typ`, `docs/reference/API_REFERENCE.md`, `scripts/lean-citation-manifest.json` and the other files a concurrently dispatched sibling task declares. None of the recommendations below touch them.

## Literature Proof Structure

**Source**: `appendix_cut_material.tex`, "Footnote on the appeals to choice in lem:state-set" (originally a footnote following `lem:state-set`); context from `possible_worlds.tex` `def:flow`, `lem:state-set`, `app:drift`, `cor:no-characterization`, `rmk:choice`, `lem:canonical-frames`.
**Strategy**: not a proof but a *provenance claim* — an assertion that one step of a proved lemma can be replaced, at the frames where the lemma is applied, by an explicit construction.

### Step Map

1. `lem:state-set` is proved over a `def:flow` frame. Two steps of its proof appeal to `cor:occurrence`: the `□` case ("every world state occurs at every time, so `{ρ(x) | ρ ∈ H_F} = W`") and the (⇐) half of the validity clause ("each `w ∈ W` is `τ(x)` for some `τ ∈ H_F`") — `possible_worlds.tex`, proof of `lem:state-set`.
2. `cor:occurrence` is proved by extending a one-point partial history through `thm:extension`, which appeals to Zorn's lemma — `rmk:choice`.
3. The footnote's claim: at the frames where `lem:state-set` is *applied*, step 1's appeal is replaceable, because a world through a given state at a given time "is exhibited explicitly as a translation".
4. The applications are `app:drift` (`F°`, the drift band on ℝ, which satisfies `def:flow` because its worlds are strictly increasing 2-Lipschitz order-automorphisms of ℝ) and `cor:no-characterization` (`F¹ = F^tr_ℝ`, the translation frame over ℝ, whose worlds are exactly `τ(t) = t + c` by `lem:canonical-frames`).
5. `rmk:choice` is the paper's own inventory: `cor:occurrence`, the (⇐) half of `lem:deterministic-singleton`, `lem:nomic-occurrence` and `lem:nomic-recovery` are ZFC; `lem:nullity`, `cor:saturation-finite`, `app:gluing` and the (⇒) half of `lem:deterministic-singleton` are choice-free.

### Dependencies

- Step 3 depends on step 4: the claim is indexed to *which* frames are applied at, and is false for a general `def:flow` frame.
- Step 1 is the only place `lem:state-set` consumes choice; steps 2 and 5 only locate the cost.

### Potential Formalization Challenges

- **Step 3/4 are already discharged in the tree**, which is the single most consequential finding of this research: `f1_stateOccurs` builds the witness as `oneShift.hist (w - x)` and `fzero_stateOccurs` by an explicit affine map, and the two-hypothesis corollaries in `StateSetTruth.lean` are what `DeterminismUndefinable.lean` consumes. The paper's footnote therefore describes work the tree already does. What is *not* in the tree is the same fact at the translation frame over an **arbitrary** duration group, which is where the new content lies.
- **Step 4's `F^tr` is a frame constant with two avatars in Lean**, and the choice-freeness claim distinguishes them sharply: `translationFrame D` (`Semantics/Frames/Standard.lean`, built through `FrameOver.ofReflectiveRegular`) is choice-borne; the `ShiftSet` avatar is not. The paper has no counterpart to this distinction, so a reader of the formalisation needs it recorded explicitly — which is deliverable (4)'s job.
- **"Exhibited explicitly as a translation"** maps onto `translationSigma D c` (`def:canonical-frames`' `σ_c`) on the `translationFrame` route, and onto `ShiftSet.hist` on the `ShiftSet` route. Both were built and verified; neither needs `PartialHistory.extension`.

## Findings

### Codebase Patterns

**What the pin task left.** `StateSetTruth.lean` carries `satSet`, `plusTruthAt_iff_mem_satSet`, `plusValidOn_iff_satSet_univ`, `determined_of_orderFlow` under `(h1 : OrderFlow F) (h2 : StateOccurs F)`, plus a `Regular` section with the three `_of_isRegular` forms routed through `StateOccurs.of_isRegular` (`OrderTransfer.lean:…`, `fun w x => PartialHistory.occurrence F w x`). The `_of_isRegular` forms have **no consumer anywhere in the tree** (verified by grep over `FormalSystem/` and `Tests/`); they exist to state `lem:state-set` at `def:flow`'s hypotheses.

**Measured axiom profiles (all by compiled `#print axioms`).**

| Declaration | Profile | Reading |
|---|---|---|
| `plusTruthAt_iff_mem_satSet` | `[propext]` | generic bridge: choice-free |
| `determined_of_orderFlow` | `[propext, Quot.sound]` | generic: choice-free |
| `FrameOver.ofReflectiveRegular` | `[propext]` | the constructor is clean |
| `TaskFrame.comp_of`, `TaskFrame.saturation_of_fib_subsingleton`, `translationRel_fib_subsingleton` | `[propext]` | clean |
| `FrameOver.instIsRegularOfReflective` | `[propext, Quot.sound]` | clean |
| **`TaskFrame.limit_of_shift`** | **`[propext, Classical.choice, Quot.sound]`** | **the one choice source** |
| `translationFrame`, `translationFrame_isRegular`, `translationHist`, `translationSigma`, `translationSigma_states`, `translationStates_eq` | `[propext, Classical.choice, Quot.sound]` | all inherited from the row above |
| `f1_orderFlow`, `f1_stateOccurs`, `fzero_orderFlow`, `fzero_stateOccurs`, `fzero_determined`, `fzero_plusValidOn_iff_f1`, `deterministic_not_plusDefinable` | `[propext, Classical.choice, Quot.sound]` | carrier-borne (ℝ), as `DeterminismUndefinable.lean`'s pin states |

**Where `limit_of_shift`'s choice comes from.** Two Mathlib lemmas, isolated by probe: `exists_ne` (`[propext, Classical.choice, Quot.sound]`) used to extract a positive duration from `[Nontrivial D]`, and `abs_eq_zero` (same) used to turn `|y₀| = 0` into `y₀ = 0`. A third, subtler source lives in the same neighbourhood and is worth recording because it will bite any future choice-free work over a `TemporalOrder`: **`AddRightStrictMono ↑D` is choice-borne while `AddLeftStrictMono ↑D` is not.** Measured at the `TemporalOrder` bundle:

- `add_lt_add_right h c : c + a < c + b` → `[propext]`
- `add_lt_add_left h c : a + c < b + c` → `[propext, Classical.choice, Quot.sound]`
- `sub_pos.mpr : a < b → 0 < b - a` → `[propext, Classical.choice, Quot.sound]` (it needs the right-mono instance)

So choice-free ordered-group arithmetic over a `TemporalOrder` is available, but only through the *left*-mono lemmas and with `sub_pos` replaced by adding `-a` on the left. All proofs recommended below respect that discipline.

**The reducibility barrier, and why it decides the route.** `RealTranslationFrame.lean`'s module docstring records that `translationFrame` is a plain `def`, so `(translationFrame D).toTaskFrame.WorldState` does not reduce to `↑D` at the transparency instance synthesis uses; the house workaround is the view definition `translationStates`. `ShiftSet.fibre` and `ShiftSet.frame` are both `@[reducible]`, so `S.frame.WorldState` *is* `S.Carrier` for instance search. Consequence, verified both ways: on the `ShiftSet` route the `[LinearOrder F.WorldState]` instance `OrderFlow` requires synthesizes with no help, and `τ.state r = τ.state 0 + r` elaborates directly; on the `translationFrame` route both need manual help (an `inferInstanceAs` instance for the `LinearOrder`, and an identity view `WorldState → ↑D` so that a state can appear as a `+`/`-` operand).

**No mechanical pin would break under a shrinking axiom set, except the big one.** `scripts/typst-status-counts.sh`'s `AXIOM_DECLS` covers five `BXCanonical` declarations only. But `scripts/check-module-invariants.sh` pins **202** declarations' axiom sets by exact string equality (C2's 50 + C14's rest), C21 asserts every name on `FormalSystem/MainResults.lean` is in that pinned set, and C2's own failure message reads "axiom sets diverged from baseline -- this is a HARD STOP, not a new baseline". `MainResults.lean`'s "axiom contract" additionally asserts in prose that every declaration on the page reports `[propext, Classical.choice, Quot.sound]` with exactly one recorded exception. Several pinned `*Sharpness` results are proved over `translationFrame D`.

### External Resources

- **`ShiftSet` (`FormalSystem/Semantics/ShiftSet.lean`)** is the choice-free frame constructor. Its four axiom fields are `carrier_nonempty`, `sh_zero`, `sh_add`, `sep`; `fibre_isRegular` discharges *Compositionality*, *Seriality* and *Saturation* from functionality plus the action laws, and takes *Limit* **directly from `sep`** — never through `TaskFrame.limit_of_shift`. That is precisely why this route escapes the choice source. `ShiftSet.ofIntAction` is the existing house precedent for a packaged shift-set constructor living in this module.
- **`oneShift` (`RealTranslationFrame.lean`)** is the ℝ instance of the construction recommended below, with the `sep` proof this report's generic `sep` proof generalises almost verbatim (instantiate the hypothesis at `|u - w|`, derive `|u - w| < |u - w|`).
- **Mathlib**, this toolchain (`Lean v4.33.0-rc1`, Mathlib tag `v4.33.0-rc1`): `abs_pos` `[propext]`, `sub_pos` `[propext]`, `exists_pair_ne` axiom-free, `lt_trichotomy` axiom-free, `add_right_injective` axiom-free, `not_lt` axiom-free, `instDistribLatticeOfLinearOrder` `[propext]`. `exists_ne` and `abs_eq_zero` are the two to avoid.

### Recommendations

A sorry-free path exists for every deliverable; all Lean below compiled under `lean_run_code` against the built library, and the axiom profile quoted after each block is the measured one.

**Recommendation 1 — new leaf module.** Put the new material in one new module, e.g. `FormalSystem/Metalogic/Independence/TranslationStateSet.lean`, importing `FormalSystem.Metalogic.Independence.StateSetTruth`, `FormalSystem.Semantics.ShiftSet` and `FormalSystem.Semantics.Correspondence.DurationFrames`; register it in `FormalSystem/Metalogic/Independence.lean`'s import list and module census, and add a row to `FormalSystem/Metalogic/Independence/README.md`'s table. Rationale: `StateSetTruth.lean`'s import closure (via `PlusValidity`) contains neither `ShiftSet` nor `DurationFrames`, and widening it would drag both into every consumer of the bridge. `ZTimeSharpness.lean` importing `Semantics.Correspondence.DurationFrames` is the precedent for an `Independence/` module reaching that far. All four proposed name prefixes (`selfShift`, `translationFlow`, `translationFrame_orderFlow`, `translationFrame_stateOccurs`) are unused in the tree.

**Recommendation 2 — the generic, absolutely choice-free layer (the headline).** Define `D` acting on itself as a shift set and read the state-set results off it. Verified profiles: `selfShift` and the frame `[propext]`; every theorem `[propext, Quot.sound]`; **no `Classical.choice` anywhere**.

```lean
@[reducible] def selfShift (D : TemporalOrder) : ShiftSet D where
  Carrier := ↑D
  carrier_nonempty := ⟨0⟩
  sh := fun w d => w + d
  sh_zero := by intro w; exact add_zero w
  sh_add := by intro w a b; exact add_assoc w a b
  sep := by
    intro w u h
    by_contra hne
    have hpos : (0 : ↑D) < |u - w| := abs_pos.mpr (sub_ne_zero.mpr hne)
    obtain ⟨y, hy, hu⟩ := h (|u - w|) hpos
    have hy' : y = u - w := by rw [hu]; abel
    rw [hy'] at hy
    exact lt_irrefl _ hy
  A := fun _ _ => False

@[reducible] def translationFlow (D : TemporalOrder) : TaskFrame := (selfShift D).frame

theorem translationFlow_taskRel (D : TemporalOrder) (w x u : ↑D) :
    (translationFlow D).TaskRel w x u ↔ u = w + x := (selfShift D).fibre_taskRel w x u

theorem translationFlow_states_eq (D : TemporalOrder)
    (τ : WorldHistory (translationFlow D)) (r : ↑D) : τ.state r = τ.state 0 + r := by
  have h := (translationFlow_taskRel D _ _ _).mp (τ.respects_task 0 r)
  rw [sub_zero] at h
  exact h

theorem translationFlow_orderFlow (D : TemporalOrder) : OrderFlow (translationFlow D) where
  strictMono := by
    intro τ s t hst
    rw [translationFlow_states_eq D τ s, translationFlow_states_eq D τ t]
    exact add_lt_add_right hst _
  hits_future := by
    intro τ x v hv
    refine ⟨-(τ.state 0) + v, ?_, ?_⟩
    · rw [translationFlow_states_eq D τ x] at hv
      have h2 := add_lt_add_right hv (-(τ.state 0))
      rw [show -(τ.state 0) + (τ.state 0 + x) = x by abel] at h2
      exact h2
    · rw [translationFlow_states_eq D τ (-(τ.state 0) + v)]; abel
  hits_past := by
    intro τ x v hv
    refine ⟨-(τ.state 0) + v, ?_, ?_⟩
    · rw [translationFlow_states_eq D τ x] at hv
      have h2 := add_lt_add_right hv (-(τ.state 0))
      rw [show -(τ.state 0) + (τ.state 0 + x) = x by abel] at h2
      exact h2
    · rw [translationFlow_states_eq D τ (-(τ.state 0) + v)]; abel

theorem translationFlow_stateOccurs (D : TemporalOrder) : StateOccurs (translationFlow D) := by
  intro w x
  refine ⟨(selfShift D).hist (-x + w), ?_⟩
  change -x + w + x = w
  abel
```

and then the three corollaries, each a one-liner over the pair above:

```lean
theorem translationFlow_plusTruthAt_iff_mem_satSet (D : TemporalOrder)
    (M : TaskModel (translationFlow D)) (φ : PlusFormula) :
    ∀ (τ : WorldHistory (translationFlow D)) (t : ↑D),
      PlusTruthAt M τ t φ ↔ τ.state t ∈ satSet M.valuation φ :=
  plusTruthAt_iff_mem_satSet (translationFlow_orderFlow D) (translationFlow_stateOccurs D) M φ

theorem translationFlow_determined (D : TemporalOrder) (φ : PlusFormula) :
    (translationFlow D).PlusValidOn (.imp φ (.stab φ)) :=
  determined_of_orderFlow (translationFlow_orderFlow D) (translationFlow_stateOccurs D) φ

theorem translationFlow_plusValidOn_iff_satSet_univ (D : TemporalOrder) (φ : PlusFormula) :
    (translationFlow D).PlusValidOn φ ↔ ∀ V : ↑D → Atom → Prop, satSet V φ = Set.univ :=
  plusValidOn_iff_satSet_univ (translationFlow_orderFlow D) (translationFlow_stateOccurs D) φ
```

Two further facts, both verified, make this layer the right place for the result rather than a sidecar:

- `(selfShift realTemporalOrder).frame = F1` holds **by `rfl`**, and `(selfShift realTemporalOrder).Carrier = ℝ` likewise. So `f1_orderFlow` and `f1_stateOccurs` can be restated as `translationFlow_orderFlow realTemporalOrder` and `translationFlow_stateOccurs realTemporalOrder` — the ℝ instances of the generic lemmas (both verified to typecheck at `OrderFlow F1` / `StateOccurs F1`). This is a genuine consolidation, not a rename: the hand-written `f1_*` proofs in `DeterminismUndefinable.lean` become instances. Whether to take it is a judgement call for the plan — the existing proofs are short and their docstrings carry explanatory weight; a middle course is to keep them and add a one-line remark pointing at the generic forms.
- `(translationFlow D).Deterministic` is immediate from `translationFlow_taskRel` via `TaskFrame.fib_subsingleton_of_functional` (verified, `[propext, Quot.sound]`), which generalises `f1_deterministic` off ℝ at no cost and is worth including since it makes the frame's `def:deterministic` status part of the same choice-free record.

**Recommendation 3 — the `translationFrame D` instances, with a relative pin.** The `*Sharpness` modules build their countermodels on `translationFrame D`, not on the `ShiftSet` avatar, so the state-set results must also be available there. The witness is the paper's own `σ_c`. Verified to compile; profile `[propext, Classical.choice, Quot.sound]`, with the choice **entirely frame-constant-borne**:

```lean
/-- Identity view: a translation-frame world state, retyped at the duration carrier. -/
def translationState {D : TemporalOrder}
    (w : (translationFrame D).toTaskFrame.WorldState) : ↑D := w

instance translationFrame_worldLinearOrder (D : TemporalOrder) :
    LinearOrder ((translationFrame D).toTaskFrame.WorldState) := inferInstanceAs (LinearOrder ↑D)

theorem translationFrame_orderFlow (D : TemporalOrder) :
    OrderFlow (translationFrame D).toTaskFrame where
  strictMono := by
    intro τ s t hst
    show (τ.state s : ↑D) < (τ.state t : ↑D)
    rw [show (τ.state s : ↑D) = translationStates τ 0 + s from translationStates_eq τ s,
        show (τ.state t : ↑D) = translationStates τ 0 + t from translationStates_eq τ t]
    exact add_lt_add_right hst _
  hits_future := by
    intro τ x v hv
    refine ⟨-(translationStates τ 0) + translationState v, ?_, ?_⟩
    · have h : translationStates τ 0 + x < translationState v := by
        rw [← translationStates_eq τ x]; exact hv
      have h2 := add_lt_add_right h (-(translationStates τ 0))
      rw [show -(translationStates τ 0) + (translationStates τ 0 + x) = x by abel] at h2
      exact h2
    · change translationStates τ (-(translationStates τ 0) + translationState v)
        = translationState v
      rw [translationStates_eq τ (-(translationStates τ 0) + translationState v)]
      abel
  hits_past := by
    intro τ x v hv
    refine ⟨-(translationStates τ 0) + translationState v, ?_, ?_⟩
    · have h : translationState v < translationStates τ 0 + x := by
        rw [← translationStates_eq τ x]; exact hv
      have h2 := add_lt_add_right h (-(translationStates τ 0))
      rw [show -(translationStates τ 0) + (translationStates τ 0 + x) = x by abel] at h2
      exact h2
    · change translationStates τ (-(translationStates τ 0) + translationState v)
        = translationState v
      rw [translationStates_eq τ (-(translationStates τ 0) + translationState v)]
      abel

theorem translationFrame_stateOccurs (D : TemporalOrder) :
    StateOccurs (translationFrame D).toTaskFrame := by
  intro w x
  refine ⟨translationSigma D (-x + translationState w), ?_⟩
  change translationStates (translationSigma D (-x + translationState w)) x = translationState w
  rw [translationSigma_states]
  abel
```

The pin recorded for these must be *relative*, and must say so in the words the measurement supports: the three corollaries at `translationFrame D` report exactly what `translationFrame D` itself reports, so the (H2) discharge contributes nothing — no `cor:occurrence`, no `thm:extension`, no Zorn — while the frame constant's own `Classical.choice`, arriving through `TaskFrame.limit_of_shift`, remains. This is the same carrier-borne-not-argument-borne distinction `DeterminismUndefinable.lean`'s pin already draws, applied to a frame constant instead of to ℝ.

**Recommendation 4 — the `StateSetTruth.lean` docstring (deliverable 4).** Add a section to the module docstring recording three routes and which consumers take which, so a reader can tell at a glance whether a given result is choice-dependent:

| Route | Hypotheses | Discharge of (H2) | Choice | Consumers |
|---|---|---|---|---|
| two-hypothesis originals | `OrderFlow F`, `StateOccurs F` | assumed | none (`[propext]` / `[propext, Quot.sound]`) | `DeterminismUndefinable.lean` at `F°` and `F¹`, each by explicit witness |
| `_of_isRegular` | `[F.IsRegular]`, `OrderFlow F` | `StateOccurs.of_isRegular` → `cor:occurrence` → `thm:extension` → Zorn | `Classical.choice`, argument-borne | none yet; states `lem:state-set` at `def:flow`'s hypotheses |
| `translationFlow` / `translationFrame` instances | none beyond the frame | explicit translation `σ_c` | none at `translationFlow`; frame-constant-borne at `translationFrame` | the `*Sharpness` countermodels (`translationFrame`), `F¹` (`translationFlow`, by `rfl`) |

Record alongside it that `plusTruthAt_iff_mem_satSet` reports `[propext]` alone and `determined_of_orderFlow` `[propext, Quot.sound]`, so the generic argument is choice-free and only instantiation can add choice — and that `ArchimedeanSharpness.lean`'s "## Choice dependence" section remains accurate for `translationFrame` under Recommendations 2 and 3 (it would need amending only under Recommendation 5).

**Recommendation 5 — measured, offered, not taken: make `translationFrame` itself choice-free.** `TaskFrame.limit_of_shift` admits a choice-free proof, verified at `[propext]`, with no signature change and therefore no effect on its three other call sites (`Semantics/Frames/Standard.lean`, `Metalogic/Decidability/Verified/Bridge/RegionFrame.lean`, `Metalogic/Algebraic/FlowFrame.lean`). The two substitutions are: extract the positive duration from `exists_pair_ne` + `lt_trichotomy` + a left-added `-a` instead of from `exists_ne` + `sub_pos`; and close with `abs_pos.mpr` under `by_contra` instead of `abs_eq_zero`. With that one change in place, a full copy of `translationFrame`'s body measured `[propext]`, and the whole downstream chain built on it — reference history, `σ_c`, state view, (H1), (H2), *Determined*, the validity corollary — measured `[propext, Quot.sound]`.

This is not recommended as part of this task, for a cost the measurement also exposes: `scripts/check-module-invariants.sh` pins 202 axiom sets by exact string equality, C2's failure text calls divergence "a HARD STOP, not a new baseline", several pinned `*Sharpness` declarations are proved over `translationFrame D`, and `MainResults.lean`'s prose asserts a uniform `[propext, Classical.choice, Quot.sound]` profile with exactly one recorded exception. A shrinking axiom set is a *good* change that nonetheless trips a deliberately unforgiving tripwire, and absorbing it means re-pinning however many of those 202 rows moved and amending the page's axiom contract. That is a decision about a repository-wide invariant, not a detail of this task, so it is surfaced rather than taken.

## Decisions

- **Deliverable (2) is met at the `ShiftSet` avatar of the translation flow, not at `translationFrame`.** Reason: measured impossibility at `translationFrame` without an upstream change (its own profile carries `Classical.choice`, and `#print axioms` traverses types). The spec's phrase "the translation frame first, by exhibiting the witnessing history explicitly through `translationHist`" is honoured in substance — an explicit translation, never `PartialHistory.extension` — and in addition at `translationFrame` itself via `translationSigma` (Recommendation 3), where only a relative pin is available.
- **Deliverable (3)'s audit is reported as a no-op finding, not as work.** All four consumers in `DeterminismUndefinable.lean` (`fzero_determined`, `determined_valid_on_non_deterministic`, `fzero_plusValidOn_iff_f1`, `deterministic_not_plusDefinable`) already consume the two-hypothesis route with explicit witnesses; there is no consumer of any `_of_isRegular` form anywhere in `FormalSystem/` or `Tests/`. Nothing can be moved to a choice-free route because nothing is on the Zorn route.
- **`OrderFlow` is not weakened and the two-hypothesis originals are not touched**, per the scope discipline. The new material is additive: one new leaf module plus one docstring section.
- **No choice-free `occurrence` in general is attempted**, per the scope discipline and `rmk:choice`.
- **`selfShift` is proposed for the new `Independence/` module rather than for `Semantics/ShiftSet.lean`**, to keep the blast radius at one new leaf; `ShiftSet.ofIntAction` is the precedent for the alternative placement if a later consumer outside `Independence/` wants it.

## Risks & Mitigations

- **Risk**: the global `instance translationFrame_worldLinearOrder` could interfere with instance search elsewhere. **Mitigation**: it is keyed on `(translationFrame D).toTaskFrame.WorldState`, a head symbol no existing instance mentions, and is definitionally the carrier's own `LinearOrder`, so no diamond arises. If the implementation prefers caution, make it `scoped`/`local` and pass it explicitly — the `OrderFlow` statements accept an explicit instance argument.
- **Risk**: a reader takes the relative pin at `translationFrame` for an absolute one. **Mitigation**: deliverable (4)'s table states the three routes and their profiles side by side, and the `translationFrame` rows name `TaskFrame.limit_of_shift` as the residual source explicitly.
- **Risk**: restating `f1_orderFlow`/`f1_stateOccurs` as instances of the generic lemmas edits `DeterminismUndefinable.lean`, which carries the axiom pin the task constraints require to keep passing. **Mitigation**: the pin's three cross-checks concern `plusTruthAt_iff_mem_satSet`, `determined_of_orderFlow`, `fzero_not_deterministic` and the *existence* of explicit witnesses for `fzero_stateOccurs`/`f1_stateOccurs` — all preserved under the restatement, since the generic witness is still an explicit translation. Measured: the restated forms report the same `[propext, Classical.choice, Quot.sound]`. Safest sequencing is to land the new module first, verify the pin, and treat the consolidation as a separate, optional step.
- **Risk**: `lake build` cost. **Mitigation**: the new module is a leaf; only the `Independence` aggregator and `MainResults.lean` (if new pins are added there) sit above it. Build via `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Independence.TranslationStateSet` detached, then the full project once.
- **Risk (concurrency)**: sibling tasks are dispatched on this same working tree, one of them declaring `typst/generated/status.typ`, `typst/FormalFoundations.typ`, `docs/reference/API_REFERENCE.md` and `scripts/lean-citation-manifest.json`. **Mitigation**: none of the recommendations touch those files; stage only this task's own files by explicit path.
- **Risk**: the `% PORT:` comment at `lem:state-set` in `possible_worlds.tex` still reads "no corollary discharging StateOccurs by PartialHistory.occurrence so that the statement matches def:flow", which the landed pin task falsified. **Mitigation**: flagged here only — the citation manifest and paper-facing records are a sibling task's declared territory, so this task must not edit them.

## Tactic Survey Results

Candidates were tested by compiling the real goals, not by `lean_multi_attempt` against a scratch position — the goals live inside structure-instance fields over frames that only exist once the surrounding definitions do, so a positional attempt would have had nothing to attach to. Every row below is a compiled result.

| Goal | Tactic | Result | Premises/Config |
|---|---|---|---|
| `selfShift`'s `sep` field | `by_contra` + `abs_pos.mpr` + `abel` | success | `abs_pos`, `sub_ne_zero`, `lt_irrefl`; `abel` for `y = u - w` |
| `translationFlow_states_eq` | `rw [sub_zero]` over `respects_task 0 r` | success | `fibre_taskRel` |
| `OrderFlow.strictMono` at the flow | `rw` the two state equations, then `add_lt_add_right` | success | **left**-mono form only; `add_lt_add_left` compiles but imports `Classical.choice` |
| `OrderFlow.hits_future` / `hits_past` | `refine ⟨-(τ.state 0) + v, _, _⟩`, `add_lt_add_right … (-(τ.state 0))`, `abel` | success | witness written additively; `sub_pos` deliberately avoided (choice-borne here) |
| `StateOccurs` at the flow | `refine ⟨(selfShift D).hist (-x + w), _⟩`, `change`, `abel` | success | `ShiftSet.hist`'s state function is `t ↦ sh w t` definitionally |
| `StateOccurs` at `translationFrame` | `refine ⟨translationSigma D (-x + translationState w), _⟩`, `change`, `rw [translationSigma_states]`, `abel` | success | needs the identity view `translationState`; `translationSigma_states` is `rfl` |
| `τ.state c = v` at `translationFrame`, stated through an ascription | `show (τ.state _ : ↑D) = …` then `rw` | **fail** | the `rw` does not fire; `change` to a `translationStates` application first, then `rw`, then `abel` |
| `0 < b - a` from `a < b` over a `TemporalOrder` | `sub_pos.mpr` | success but **choice-borne** | replace with `add_lt_add_right h (-a)` + `neg_add_cancel` |
| `|y| = 0 → y = 0` | `abs_eq_zero.mp` | success but **choice-borne** | replace with `by_contra` + `abs_pos.mpr` |
| `∃ x : D, 0 < x` from `[Nontrivial D]` | `exists_ne` + `lt_or_gt_of_ne` + `sub_pos` | success but **choice-borne** | replace with `exists_pair_ne` + `lt_trichotomy` + left-added `-a` |
| `(selfShift realTemporalOrder).frame = F1` | `rfl` | success | both sides `@[reducible]` |
| whole-chain axiom audit | `#print axioms` on 20+ declarations | success | the evidence of record for every profile quoted in this report |

`lean_hammer_premise` was not consulted: no goal in this task was an unknown-premise search problem — every step was either frame-arithmetic over a known bundle or a direct application of an existing bridge lemma, and the binding constraint was *which* of two equally-provable lemmas carries `Classical.choice`, which a premise recommender does not report.

## Context Extension Recommendations

- **Topic**: left-mono vs. right-mono asymmetry in choice-dependence over the `TemporalOrder` bundle.
  **Gap**: nothing in `context/project/lean4/` records that `add_lt_add_right` is choice-free at a `TemporalOrder` while `add_lt_add_left` and `sub_pos` are not. Any future choice-hygiene work in this tree will rediscover it the slow way, as this task did.
  **Recommendation**: add a short section to `context/project/lean4/patterns/dependency-tracing.md` (which already owns "mechanically tracing declaration dependencies; why `#print axioms` cannot answer it") recording the three measured rows, the substitution recipes, and the method — bisect a choice profile by re-proving the suspect step with left-mono lemmas and comparing `#print axioms`.
- **Topic**: `#print axioms` traverses a declaration's type as well as its value.
  **Gap**: the consequence — that a choice-borne *frame constant* makes every theorem *about* it choice-borne, irrespective of the proof — is the single fact that reshaped this task, and no context file states it.
  **Recommendation**: one paragraph in the same file, cross-referenced from `context/project/lean4/tools/comparator-guide.md`'s trust-model discussion.
- **Topic**: the C2/C14 exact-string axiom baseline as a constraint on *improvements*.
  **Gap**: `context/project/lean4/` has no note that shrinking an axiom set trips a HARD STOP check, so an agent making a legitimate hygiene improvement will read the failure as its own regression.
  **Recommendation**: a note in `context/project/lean4/operations/` (or wherever the invariant-check guidance lives) stating that `check-module-invariants.sh` C2/C14 pin by exact equality, that a *smaller* set is still a divergence, and that re-baselining is an explicit user decision.

## Appendix

### Search queries and probes used

No rate-limited search tool was needed: every question was local, and `lean_run_code` answered each by compiling against the built library. `lean_leansearch`, `lean_loogle`, `lean_leanfinder`, `lean_state_search` and `lean_hammer_premise` were not called, so no rate limit was approached and no fallback was exercised. `lean_diagnostic_messages` and `lean_file_outline` were not called (blocked). Grep/read sweeps over `FormalSystem/`, `Tests/`, `docs/`, `typst/` and `scripts/` supplied the consumer census and the pin inventory.

Probe sequence, in order, each a compiled `lean_run_code` snippet:

1. `#print axioms` on `translationFrame`, `translationHist`, `translationSigma`, `translationSigma_states`, `translationStates_eq`, `translationFrame_isRegular` — established that the frame constant is choice-borne.
2. `#print axioms` on `FrameOver.ofReflectiveRegular`, `FrameOver.instIsRegularOfReflective`, `TaskFrame.limit_of_shift`, `TaskFrame.saturation_of_fib_subsingleton`, `TaskFrame.comp_of`, `translationRel_fib_subsingleton` — isolated `limit_of_shift` as the sole source.
3. Per-lemma profiles of `limit_of_shift`'s steps (`exists_ne`, `lt_or_gt_of_ne`, `abs_eq_zero`, `abs_nonneg`, `le_antisymm`, `add_right_injective`, `not_lt`, `lt_irrefl`) and of the instance chain (`instDistribLatticeOfLinearOrder`, `instIsRightCancelAddOfAddRightReflectLE`, `contravariant_lt_of_covariant_le`, `covariant_swap_add_of_covariant_add`, `IsRightCancelAdd.addRightStrictMono_of_addRightMono`, `IsOrderedAddMonoid.toAddLeftMono`).
4. The left/right asymmetry, by the minimal pair `add_lt_add_right` (`[propext]`) vs `add_lt_add_left` (`[propext, Classical.choice, Quot.sound]`) at a `TemporalOrder`.
5. A choice-free `limit_of_shift` (`[propext]`), then a full copy of `translationFrame`'s body over it (`[propext]`), then that copy's reference history, `σ_c`, state view, (H1), (H2), *Determined* and validity corollary (all `[propext, Quot.sound]`).
6. (H1), (H2) and the three corollaries at the *real* `translationFrame D`, with the `inferInstanceAs` `LinearOrder` instance and the `translationState` view — all compiled, all `[propext, Classical.choice, Quot.sound]`.
7. `selfShift`, `translationFlow` and the full chain, plus `(translationFlow D).Deterministic` — all `[propext]` / `[propext, Quot.sound]`.
8. `(selfShift realTemporalOrder).frame = F1 := rfl` and `(selfShift realTemporalOrder).Carrier = ℝ := rfl`; then `OrderFlow F1` and `StateOccurs F1` derived from the generic lemmas.
9. `#print axioms` on `f1_orderFlow`, `f1_stateOccurs`, `fzero_orderFlow`, `fzero_stateOccurs`, `fzero_determined`, `fzero_plusValidOn_iff_f1`, `deterministic_not_plusDefinable` — confirmed the existing carrier-borne reading.

### References

- `FormalSystem/Metalogic/Independence/StateSetTruth.lean` — `satSet`, the bridge, the validity corollary, *Determined*, and the `Regular` section
- `FormalSystem/Metalogic/Independence/OrderTransfer.lean` — `OrderFlow`, `StateOccurs`, `StateOccurs.of_isRegular`
- `FormalSystem/Metalogic/Independence/DeterminismUndefinable.lean` — the four consumers and the existing axiom pin
- `FormalSystem/Metalogic/Independence/DriftHistories.lean` — `fzero_orderFlow`, `fzero_stateOccurs`
- `FormalSystem/Metalogic/Independence/RealTranslationFrame.lean` — `oneShift`, `F1`, and the reducibility-barrier docstring
- `FormalSystem/Metalogic/Independence/ArchimedeanSharpness.lean` — the "## Choice dependence" section
- `FormalSystem/Semantics/ShiftSet.lean` — `ShiftSet`, `fibre`, `fibre_isRegular`, `hist`, `ofIntAction`
- `FormalSystem/Semantics/TaskFrame.lean` — `TaskFrame.limit_of_shift`
- `FormalSystem/Semantics/Frames/Standard.lean` — `translationFrame`, `translationFrame_isRegular`
- `FormalSystem/Semantics/Correspondence/DurationFrames.lean` — `translationHist`, `translationStates`, `translationSigma`, `translationStates_eq`
- `FormalSystem/MainResults.lean`, `scripts/check-module-invariants.sh` — the axiom contract and the 202-row baseline
- `possible_worlds.tex`: `def:state-set`, `def:flow`, `lem:state-set`, `app:drift`, `cor:no-characterization`, `rmk:choice`, `lem:canonical-frames`; `appendix_cut_material.tex`: "Footnote on the appeals to choice in lem:state-set"
