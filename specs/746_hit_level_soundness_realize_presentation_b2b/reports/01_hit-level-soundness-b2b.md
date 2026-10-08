# Research Report: Requirement (S) — Hit-level soundness, realize a presentation by a constructed regular ℤ-model (B2b)

**Task**: 746 - Requirement (S) of the ray-product verdict: Hit-level soundness — realize a presentation by a constructed regular ℤ-model (B2b)
**Started**: 2026-10-08T16:09:00Z
**Completed**: 2026-10-08T16:35:00Z
**Effort**: MEDIUM (revised down from the carried HIGH — see Decisions)
**Dependencies**: None. (C) is independent and is not a dependency; (W) depends on this and on (C).
**Sources/Inputs**:
- Codebase: `FormalSystem/Metalogic/Decidability/RaySummary/{README.md,Closure.lean,Trace.lean,Present.lean,HitOf.lean}`, `FormalSystem/Semantics/{SlicedFrame.lean,TaskFrame.lean}`, `FormalSystem/PlusLanguage/{PlusTruth.lean,PlusRayFibre.lean,PlusStateLocal.lean,Subformulas.lean}`, `specs/evidence/seam-gluing-ray-product/presented-not-complete.lean`
- Three compiled probes written during this dispatch (below), each zero-sorry, axiom profile `[propext, Classical.choice, Quot.sound]`
- `lean env lean` direct compilation (lean-lsp MCP index not consulted; evidence tier is **compiled probe**, which is strictly stronger than an LSP index hit)
- Literature: HWZ 2000 Theorem 14 / Defs 10-12 via `hodkinson_wolter_zakharyaschev_2000_decidable_fragments_fotl` — corpus entry is **UNVERIFIED-summary provenance**, cited as orientation only and as the source of **no** claim below
**Artifacts**:
- `specs/746_hit_level_soundness_realize_presentation_b2b/reports/01_hit-level-soundness-b2b.md` (this report)
- `specs/746_hit_level_soundness_realize_presentation_b2b/evidence/01_fib-finite-generalization.lean` (compiled, 173 lines)
- `specs/746_hit_level_soundness_realize_presentation_b2b/evidence/02_cons-untl-core.lean` (compiled, 150 lines)
- `specs/746_hit_level_soundness_realize_presentation_b2b/evidence/03_cons-non-vacuity.lean` (compiled, all `#guard`s pass)
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **The named prerequisite is not on the critical path, and that is the dispatch's own question answered.** The crux the dispatch asked to test first was tested and it **fails as feared** — but the failure is irrelevant to (S), because (S) does not need an infinite slice. Liveness is a *hypothesis* (`Cons P`) for a **soundness** statement, not something the construction must engineer; the existing `FrameOver.ofSlicedStep` on the presentation's own finite `Q` suffices. The 300-500 line prerequisite is reclassified from blocking to **optional and independently valuable**.
- **The crux itself, machine-checked, both ways.** `ofSlicedStep_fib_finite`'s `[Finite W]` *does* generalize to two-sided finite branching on `R`, carrier-agnostically, in ~45 lines (`fib_finite_of_finBranch`, `saturation_of_finBranch`, probe 01) — the dispatch's reading of `saturation_of_fib_finite` is correct. And the dispatch's named hazard is real: a discharge transition resetting the counter to `0` from any level gives the `d = -1` fibre over the reset state an **infinite** preimage (`Rbad_fib_infinite`). **New finding the dispatch did not anticipate**: moving the reset to fire only *from* level `0` does not repair it, it only swaps the failing side (`Rok_fwd_infinite`). An unbounded nondeterministic deadline choice is infinite-branching on whichever side it fires. A two-sided finite-branching infinite slice is possible (`shift_saturation` on slice `ℤ`), but a deadline-countdown encoding is not one.
- **`Cons P` is derived from `Probe735`'s pumping proof, not invented, and its hard half is already proved.** Probe 02 proves `untl_iff_of_UCoh_ULive`: per-edge unfolding coherence (`UCoh`) plus acyclicity of the deferral graph (`ULive`, decided by `Present.lean`'s existing `live`) forces the `untl` clause of `LocalRun` on **every** run of the presentation — exactly the condition `Probe735.pump_isRun` violates. This is the single hardest new obligation (S) carries and it is now compiled, generically over `sig` and `Q`, with no model and no `[Finite W]`.
- **`Cons P` is non-vacuous, machine-checked.** Probe 03 exhibits a three-state presentation satisfying `UCoh`, `ULive`, bi-seriality in both senses, and the once-only `now` structure, all by `#guard`; and the same graph with one label changed **fails** `ULive`, so the condition is a real constraint rather than an empty one.
- **The structural induction (S) needs already exists in the usable direction.** `eq_clTrace_of_localRun_anchored` (`Trace.lean`) concludes `c = clTrace M φ t σ` from `LocalRun φ c` + `Anchored M φ t c σ`. **Both** directions of `Presented (modelOf P) τ t φ lab step` reduce to it, so (S) needs no new formula induction — provided `φ` is `box`-free and `stab`-free.
- **A scope limitation not in the carried description.** Under the `Cons` untl/snce conditions, truth of every closure subformula in `modelOf P` is state-determined, so the constructed model satisfies `⊡ψ ↔ ψ` for every `stab ψ` in the closure (the mechanism is `plusStateLocal_stab_iff`'s semantic half). Nested `stab` is realized only trivially. The honest (S) scope is `box`/`stab`-free `φ` — which is where the verdict's own table already puts the `box` and `stab` anchors: requirement **(W)**.
- **Revised cost: 600-900 lines, MEDIUM**, against the carried 1,200-2,000 HIGH + 300-500 prerequisite. The construction lands; a cited verdict is not needed.

## Context & Scope

Researched: what `Cons P` must say, what `modelOf P` must be, whether the carried frame-constructor prerequisite is needed, and what the whole thing costs. Constraints carried unchanged and honoured throughout: zero debt (no external Büchi/MSO/HWZ lemma stands in for a proof; the three probes prove what they claim); time axis never states; no statement anywhere of `Decidable (PlusValidZTime φ)` in any form; no complexity bound; cslib read-only and not consulted; forward-only (no backward Bool-fixture bridge exists, and probe 02's `snce` mirror is stated as owed work, not as a symmetry claim).

Every declaration below was re-resolved **by name** (the dispatch's anchor warning); no line number from the task description was trusted.

## Findings

### Reference grounding — Tier 1 lemma-level mapping

Tier 1 applies (HWZ 2000 Theorem 14 is named in the task). The source entry is UNVERIFIED-summary provenance, so the **Source** column records what the formalization's own README attributes to HWZ, and no row draws a claim from the corpus text.

| Source (HWZ 2000, as attributed in `RaySummary/README.md`) | Prop/Location | Lean Identifier | Type Signature (as resolved by name, abridged) | Status |
|---|---|---|---|---|
| Def 6, `sub_x φ` — the closure alphabet | `Closure.lean` | `clSig`, `clNow`, `clLetter`, `clPhi` | `clSig (φ : PlusFormula) : MonadicSignature := ⟨{ψ // ψ ∈ (PlusFormula.subformulas φ).toFinset} ⊕ Unit⟩` | LANDED, reuse verbatim |
| Def 11 — local run conditions on a colouring of `ℤ` | `Closure.lean` | `LocalRun` | `structure LocalRun (φ) (c : (clSig φ).preds → ℤ → Prop)` with fields `bot`, `imp`, `untl`, `snce` | LANDED; the `untl` field is what probe 02 discharges from `UCoh`+`ULive` |
| — (formalization's own; HWZ has no per-model anchor layer) | `Closure.lean` | `Anchored` | fields `now`, `atom`, `box`, `stab`; `box` quantifies `∀ σ', PlusTruthAt M σ' z ψ`, `stab` over `σ'` sharing `σ.state z` | LANDED; `box`/`stab` fields **vacuous** for `box`/`stab`-free `φ` — this is the (S)/(W) scope line |
| Thm 14, `t_a` (the trace of a history) | `Closure.lean` | `clTrace` | `clTrace (M) (φ) (t) (σ) : (clSig φ).preds → ℤ → Prop` | LANDED |
| Thm 14 (⇒), reading types off a model | `Trace.lean` | `clTrace_localRun`, `clTrace_anchored` | `LocalRun φ (clTrace M φ t σ)`; `Anchored M φ t (clTrace M φ t σ) σ` (every field `Iff.rfl`) | LANDED |
| Thm 14 uniqueness (the induction (S) reuses) | `Trace.lean` | `eq_clTrace_of_localRun_anchored` | `(hr : LocalRun φ c) → (ha : Anchored M φ t c σ) → c = clTrace M φ t σ` | **LANDED — this is why (S) needs no new formula induction** |
| Def 12 / Thm 14 (⇐), the realization hypothesis | `Trace.lean` | `Presented` | `∀ c, (∃ bf : SeqPair F (τ.state t), c = clTrace M φ t (spliced τ t bf)) ↔ (∃ ρ, IsRun lab step (clNow φ) t ρ ∧ c = runTrace lab ρ)` | **TO BUILD — this task's target** |
| Thm 14 (⇐) at `hitOf` level | `Trace.lean` | `hit_eq_hitOf_of_presented` | `… (hk : 1 ≤ k) → Presented M τ t φ lab step → HitCl M τ t φ k = ↑(hitOf lab step (clNow φ) k)` | LANDED; (S)'s Hit-level statement is a **one-line corollary** once `Presented` is discharged |
| Def 11 run / Def 12 quasimodel runs | `Present.lean` | `IsRun`, `runTrace` | `IsRun (t) (ρ) : Prop := (∀ z, step (ρ z) (ρ (z+1)) = true) ∧ ∀ z, (lab (ρ z) now = true ↔ z = t)` | LANDED |
| Def 11 persistence (HWZ's run liveness) | `Present.lean` | `live`, `live_iff`, `HasChain` | `live_iff (G) (q) : live G q = true ↔ HasChain G q` | LANDED; **the decidable primitive `ULive` is built on** |
| Lemma 17 splice / pumping | `presented-not-complete.lean` | `Probe735.pump_isRun`, `Probe735.not_presented` | `IsRun lab step now t ρ → ρ i = ρ j → IsRun lab step now t (pump ρ i j)` | LANDED; the **source** of `Cons P`, not a refutation of this task |
| — (formalization's own frame synthesis) | `SlicedFrame.lean` | `ofSlicedStep`, `ofSlicedStep_isRegular`, `ofSlicedStep_step`, `ofSlicedStep_mem_HF_iff` | `ofSlicedStep {W} [Finite W] [Nonempty W] (R : ℤ → W → W → Prop) (fwd) (bwd) : FrameOver intOrder` | LANDED; **usable as-is for (S)** with `W := Q` |
| — | `TaskFrame.lean` | `Saturation`, `saturation_of_fib_finite`, `Fib`, `IsRegular`, `ofReflectiveRegular` | `saturation_of_fib_finite {W} {R} (h : ∀ w x, (Fib R w x).Finite) : Saturation R` — **no carrier hypothesis** | LANDED; the dispatch's reading confirmed by name |
| — | `PlusRayFibre.lean` | `SeqPair`, `seamOmegaEquiv`, `ZPathFibre`, `FrameOver.worldHistoryOfStepPath` | `SeqPair F s := {bf : BwdSeq F × FwdSeq F // bf.1.1 0 = s ∧ bf.2.1 0 = s}`; `seamOmegaEquiv (t) (s) : StabFibre F.toTaskFrame t s ≃ SeqPair F s` | LANDED; the `Presented`-splice plumbing is **copyable verbatim** from `Probe735.not_presented`'s `hsp` block |
| — | `PlusStateLocal.lean` | `plusStateLocal_stab_iff`, `IsPlusStateLocal` | `(hφ : φ.StateLocal) → (PlusTruthAt M τ t φ ↔ PlusTruthAt M τ t (.stab φ))` | LANDED; the **mechanism** of the stab-collapse limitation (a semantic-hypothesis restatement is a ~5-line variant) |

### The crux, tested first and cheaply, as the dispatch directed

Probe `01_fib-finite-generalization.lean`, compiled, zero sorries:

| Claim | Declaration | Verdict |
|---|---|---|
| The `[Finite W]` on `ofSlicedStep_fib_finite` is replaceable by two-sided finite branching on `R`, with no carrier hypothesis | `fib_finite_of_finBranch (R) (hf : FwdFinBranch R) (hb : BwdFinBranch R) : ∀ p d, (TaskFrame.Fib (ofSlicedStepRel R) p d).Finite` | **CONFIRMED** |
| ... and that yields `Saturation` directly | `saturation_of_finBranch : TaskFrame.Saturation (ofSlicedStepRel R)` | **CONFIRMED** |
| `Fib` at negative durations is the **preimage**, and finiteness is not converse-stable, so finite branching is needed in both senses | the `d < 0` branch routes through `iterS_bwd_finite` (an `n`-step preimage), the `d ≥ 0` branch through `iterS_fwd_finite` | **CONFIRMED** — the dispatch's reflection-convention reading is exactly right |
| A discharge transition resetting the counter to `0` from any level breaks the bound outright | `Rbad_fwd : FwdFinBranch Rbad`; `Rbad_bwd_infinite`; `Rbad_fib_infinite : ¬ (Fib (ofSlicedStepRel Rbad) ((0:ℤ),(0:ℕ)) (-1)).Finite` | **CONFIRMED — the hazard is real** |
| Moving the reset to fire only from level `0` repairs it | `Rok_bwd : BwdFinBranch Rok`; **`Rok_fwd_infinite : ¬ {m | Rok t 0 m}.Finite`** | **REFUTED — new finding.** The failing side merely swaps. An unbounded nondeterministic deadline choice is infinite-branching wherever it fires; no reset placement avoids it. |
| The generalization is non-vacuous on a genuinely infinite slice | `shift_saturation : TaskFrame.Saturation (ofSlicedStepRel Rshift)` on slice `ℤ`, with `shift_slice_infinite : ¬ Finite ℤ` | **CONFIRMED** — a *deterministic* unbounded component is fine; a *nondeterministic* deadline is not |

**Consequence for the estimate.** The dispatch's structural reading of the prerequisite is vindicated: four of five field discharges are already carrier-agnostic (verified by signature: `ofSlicedStepRel_reflect`, `ofSlicedStep_compositional`, `ofSlicedStep_serial`, `ofSlicedStep_limit` carry no `[Finite W]`), and the whole requirement funnels through `ofSlicedStep_fib_finite`, whose crude `{p.1+d} ×ˢ univ` bound never touches the step relation. Replacing it costs ~45 lines of real proof. But **`[Finite W]` occurs 11 times in `SlicedFrame.lean` across 9 declarations**, and `ofSlicedStep` is referenced in **17 files** (4 `PlusSlicedCertificate` modules, 8 evidence probes, and the aggregators). An in-place generalization would churn all of them, including the two probes this task is forbidden to retire. The surviving cost is therefore mechanical surface area, ~120-160 lines, and it should land as a **parallel constructor beside `ofSlicedStep`**, never as an in-place edit.

### Why (S) does not need that prerequisite at all

The carried reasoning is: *liveness cannot be enforced by a step graph on a finite slice, because deferral paths are themselves histories, so the constructed model needs an infinite slice with committed states.* That reasoning is sound **for completeness** — requirement (C), where a presentation must be *manufactured* from a formula and liveness must be engineered. It does not apply to **soundness**. In (S) the presentation is *given*, and `Cons P` is a *hypothesis*: the burden of excluding deferral paths sits in the hypothesis, where the dispatch itself puts it ("`Cons P` MUST EXCLUDE PUMPABLE EVENTUALITY-DEFERRING RUN SETS"). A presentation whose step graph admits a deferral path simply is not `Cons`, and the construction never sees one.

So `modelOf P` can be `FrameOver.ofSlicedStep (fun _ q q' => step q q' = true) fwd bwd` with `W := Q` — `[Finite Q]` from the presentation's own `[Fintype Q]`, `[Nonempty Q]` from a `Cons` clause. The carrier `ℤ × Q` is infinite (`ofSlicedStep_not_finite_worldState`), regularity is free (`ofSlicedStep_isRegular`), and no finite-fibre or finite-width assumption is introduced anywhere — the refuted shape is not reproduced.

### `Cons P`, derived from `Probe735.not_presented`'s own proof

`Probe735`'s contradiction is precise: the pumped run claims the `untl` letter at `t` while visiting, from `t` on, only states on which the event letter is `false`. Generalized, the forbidden object is **a `step`-cycle every state of which claims the eventuality and lacks the event**. Probe `02_cons-untl-core.lean` turns that into two decidable conditions and proves they suffice:

```
UCoh lab step u g e : Prop :=
  ∀ q q', step q q' = true →
    (lab q u = true ↔ (lab q' e = true ∨ (lab q' g = true ∧ lab q' u = true)))

deferGraph lab step u e (x y : Q) : Bool := lab x u && !(lab x e) && step x y

ULive lab step u e : Prop := ∀ q, live (deferGraph lab step u e) q = false
```

- `UCoh` is `PlusTruthAt`'s `untl` clause unfolded across one step — decidable per edge, `Fintype Q` many checks.
- `ULive` is decided by `Present.lean`'s **existing** `live`, whose characterization `live_iff : live G q = true ↔ HasChain G q` is the bridge the liveness argument consumes. Nothing new is needed on the graph side.

Proved in probe 02, generically over `sig` and `Q`, with no model and no `[Finite W]`:

| Declaration | Statement | Role |
|---|---|---|
| `persist` | under `UCoh`, an undischarged claim at `z` forces `u`, `g` and `¬e` at every `z+1+m`, `m ≤ n` | the inductive core |
| `disch_of_UCoh_ULive` | `UCoh` + `ULive` + a step path + `lab (ρ z) u = true` → `Disch lab g e ρ z` | **the hard (⇒) direction of `LocalRun.untl`** |
| `u_of_disch` | `UCoh` + a step path + a discharge witness → `lab (ρ z) u = true` | the (⇐) direction, by walking coherence back from the witness |
| `untl_iff_of_UCoh_ULive` | the two combined: `lab (ρ z) u = true ↔ Disch lab g e ρ z` | **the `untl` field of `LocalRun`, discharged** |

The `snce` mirror is **owed work, not a symmetry claim**: it needs the backward deferral graph and the backward walk, and the forward-only constraint this task carries means nothing here transfers to it for free.

**Non-vacuity, machine-checked** (probe `03_cons-non-vacuity.lean`, every `#guard` passes): a three-state presentation (`0→0`, `0→1`, `1→2`, `2→2`; the event at `0` and `2`, absent at the `now`-state `1`) satisfies `UCoh`, `ULive`, bi-seriality in both senses, and the once-only `now` condition (no `step`-path of positive length returns to `1`, checked to the carrier's full depth). Changing one label so state `0`'s self-loop becomes event-free makes `live deferBad 0 = true`, so `ULive` fails — the `Probe735` shape, reproduced as the negative control. The conditions are a real constraint, satisfied.

### `Cons P`, assembled — the full clause list

1. **`[Nonempty Q]`** and **bi-seriality**: `∀ q, ∃ q', step q q' = true` and `∀ q, ∃ q', step q' q = true`. Feeds `ofSlicedStep`'s `fwd`/`bwd` (time-constant `R`, so the `t-1` index is immaterial).
2. **Propositional coherence, per state**: `lab q (clLetter φ h_bot) = false`; `lab q (imp ψ χ) = (!lab q ψ || lab q χ)`. These give `LocalRun`'s `bot` and `imp` fields directly.
3. **`UCoh` + `ULive`, one instance per `untl ψ χ` in `plusSubformulaClosure φ`** → `LocalRun.untl` by probe 02.
4. **The backward mirror, one instance per `snce ψ χ`** → `LocalRun.snce`. Owed.
5. **Once-only `now`**: no `step`-path of positive length from a `now`-labelled state returns to one. Gives `IsRun`'s second conjunct for every history through the seam.
6. **`box`/`stab`-freeness of `φ`** (or, in the general variant, clauses pinning `lab q (box ψ) = decide (∀ q', lab q' ψ)` and `lab q (stab ψ) = lab q ψ`). See the limitation below.

### The scope limitation, and why it is (W)'s remit rather than a defect

Clauses 2-4 force truth of every closure subformula in `modelOf P` to be a function of the state alone: two histories agreeing on `σ.state z` agree on every closure letter at `z`. By `plusStateLocal_stab_iff`'s semantic half that forces `⊡ψ ↔ ψ` in `modelOf P` for every `stab ψ` in the closure — nested `stab` is realized, but only trivially. Likewise, every world state `(z, q)` of `ofSlicedStep` exists at every time, so the `box` anchor's `∀ σ'` is time-invariant and `box ψ` gets a single global truth value.

Both facts land exactly where the verdict already assigns them: (W) is defined as "a finite object carrying, for every time, the `box` anchor across the whole slice and, for every state, the `stab` anchor, nested under `untl`/`snce`". So (S) over `box`/`stab`-free `φ` is the honest decomposition, not a narrowing. For `box`/`stab`-free `φ` the `Anchored.box` and `Anchored.stab` fields are vacuous (their hypothesis `box ψ ∈ plusSubformulaClosure φ` is uninhabited, since `plusSubformulaClosure φ = (PlusFormula.subformulas φ).toFinset` adds nothing), so `Anchored` reduces to `now` + `atom`, both immediate from the construction.

### Recommendations — a sorry-free path exists, and these are the Lean-ready targets

A sorry-free path to the full acceptance criterion (construction lands, not a cited verdict) is identified. No `sorry`, no new axiom, and no vacuous definition is needed or recommended anywhere.

**New module, beside `RaySummary/`** — suggested `FormalSystem/Metalogic/Decidability/RaySummary/Realize.lean` (one module; `file_scope` is the plan's to set). Targets, in dependency order:

```lean
-- Phase 1  (lift probe 02 + the snce mirror; ~200-280 lines)
def UCoh    (lab : Q → sig.preds → Bool) (step : Q → Q → Bool) (u g e : sig.preds) : Prop
def deferGraph (lab) (step) (u e) (x y : Q) : Bool
def ULive   (lab) (step) (u e) : Prop
theorem untl_iff_of_UCoh_ULive … : lab (ρ z) u = true ↔ Disch lab g e ρ z   -- COMPILED, probe 02
def SCoh / bwdDeferGraph / SLive  and  theorem snce_iff_of_SCoh_SLive …     -- OWED, the mirror

-- Phase 2  (the hypothesis bundle; ~120-180 lines)
structure Cons (φ : PlusFormula) (lab : Q → (clSig φ).preds → Bool) (step : Q → Q → Bool) : Prop
theorem cons_localRun (hC : Cons φ lab step) (ρ : ℤ → Q)
    (hstep : ∀ z, step (ρ z) (ρ (z + 1)) = true) : LocalRun φ (runTrace lab ρ)
-- plus the #guard non-vacuity inhabitant lifted from probe 03

-- Phase 3  (the model; ~80-120 lines, mostly citation)
def frameOf (step) (hC) : FrameOver intOrder := FrameOver.ofSlicedStep (fun _ q q' => step q q' = true) …
def modelOf (φ) (lab) (step) (hC) : TaskModel (frameOf step hC).toTaskFrame
instance : (frameOf step hC).IsRegular                       -- ofSlicedStep_isRegular
theorem modelOf_valuation … : (modelOf …).valuation (z, q) p = … lab q …

-- Phase 4  (the realization; ~180-260 lines)
theorem presented_modelOf (hbs : φ.BoxStabFree) (hC : Cons φ lab step) (q₀ : Q) (hq₀ : lab q₀ (clNow φ) = true)
    (τ : WorldHistory …) (hτ : τ.state t = (t, q₀)) :
    Presented (modelOf φ lab step hC) τ t φ lab (fun q q' => step q q' = true)

-- Phase 5  (the acceptance statement; ~30-60 lines incl. the theorem-index row)
theorem hitCl_modelOf_eq_hitOf (hk : 1 ≤ k) … :
    HitCl (modelOf φ lab step hC) τ t φ k = ↑(hitOf lab (fun q q' => step q q' = true) (clNow φ) k)
  := hit_eq_hitOf_of_presented … (presented_modelOf …)
```

**Phase 4's proof is the one worth stating in advance, because it is shorter than it looks.** Both directions go through `eq_clTrace_of_localRun_anchored`:
- (⇐) *run trace is a seam trace*: given `ρ` with `IsRun`, build `σ` from the step path `z ↦ (z, ρ z)` (via `FrameOver.worldHistoryOfStepPath`, or `ofSlicedStep_mem_HF_iff`'s `←` direction at offset `0`); show `LocalRun φ (runTrace lab ρ)` by `cons_localRun` and `Anchored (modelOf …) φ t (runTrace lab ρ) σ` by `now`+`atom` only; conclude `runTrace lab ρ = clTrace … σ`; then exhibit `σ` as a splice by copying the `hsp` block of `Probe735.not_presented` verbatim (`seamOmegaEquiv` + `Equiv.symm_apply_apply`).
- (⇒) *seam trace is a run trace*: given a splice `σ`, set `ρ z := (σ.path z).2`; `IsRun` follows from `ofSlicedStep_step` plus `Cons` clause 5; then the *same* two obligations and the *same* lemma give `runTrace lab ρ = clTrace … σ`.

Two new auxiliary items are needed and are cheap: `PlusFormula.BoxStabFree` with a subformula-inheritance lemma (~35 lines, mirroring `isBoxFree` in `Metalogic/Expressiveness/Separation/SemanticBridge.lean`, which is for `Formula` not `PlusFormula` and cannot be reused directly), and a semantic-hypothesis variant of `plusStateLocal_stab_iff` if the stab-collapse limitation is to be stated as a theorem (~5 lines).

**Optional, separable, and recommended as its own record or trailing phase** — the generalized constructor. Land `fib_finite_of_finBranch` / `saturation_of_finBranch` from probe 01 plus a **parallel** `ofSlicedStepBranch` constructor and its 7 companion restatements, in `SlicedFrame.lean`, **without touching `ofSlicedStep`** (17 referencing files, two of them probes this task may not retire). ~120-160 lines. It is not a dependency of anything above; its value is that (C) and (W) will want it, and probe 01 has already paid for its hard part.

## Decisions

1. **Tier 1 reference grounding applied**, with the HWZ corpus entry treated as orientation only. No claim in this report rests on it; every row of the mapping table is grounded in a declaration resolved by name in this tree or in a probe compiled during this dispatch.
2. **The carried frame-constructor prerequisite is reclassified from blocking to optional.** Recorded as an `estimate` issue in the task's issue log. Reason: (S) is a soundness statement, so liveness lives in `Cons P`, and `ofSlicedStep` on the presentation's own finite `Q` suffices.
3. **`Cons P` is derived from `Probe735.not_presented`'s proof**, as the dispatch directed, and not invented: `UCoh` is the unfolded truth clause and `ULive` is the negation of exactly the object `pump_isRun` manufactures.
4. **The HWZ-verbatim shape is not transcribed.** No bare type set appears anywhere; `Cons` is stated over the two atom-sequence ray languages' letters with types derived by the trace map, i.e. through `Anchored` and `runTrace`, as the dispatch required. The favourable consequence named in the dispatch is exploited rather than defended against: the product alphabet absorbs the Lemma 17 created-type hazard, so `Cons` needs **no** clause about created types, and none is proposed.
5. **Scope restricted to `box`/`stab`-free `φ`** for the landing statement, with the general variant noted. This is the (S)/(W) line the verdict already drew, and the stab-collapse finding is reported rather than hidden.
6. **Cost revised to 600-900 lines, MEDIUM.** Splitting is not expected to be necessary: the prerequisite is off the critical path and the largest single phase (Phase 4) is bounded at ~180-260 lines.
7. **No statement of `Decidable (PlusValidZTime φ)` in any form**, and no complexity bound, appears in this report or in any proposed target. (S) alone does not deliver validity; the lift is (W).
8. **Probes saved under the task directory, not under `specs/evidence/`.** Wiring them (and deciding which become permanent evidence) is the plan's call; nothing in `specs/evidence/` or `FormalSystem/` was modified by this dispatch.

## Adversarial Self-Verification

Every load-bearing claim was re-challenged. Three were revised; one is recorded as an UNRESOLVED open question rather than asserted.

| Claim | Source / Counterexample | Verification Method | Confidence |
|---|---|---|---|
| `ofSlicedStep_fib_finite`'s `[Finite W]` is replaceable by two-sided finite branching | `Probe746.fib_finite_of_finBranch` | compiled probe, zero sorries, `#print axioms` = `[propext, Classical.choice, Quot.sound]` | High |
| `saturation_of_fib_finite` requires fibre-wise finiteness with no carrier hypothesis | `TaskFrame.saturation_of_fib_finite {W} {R} (h : ∀ w x, (Fib R w x).Finite) : Saturation R` | signature read by name in `TaskFrame.lean`; docstring names a consumer with carrier `ℕ` | High |
| Four of five `ofReflectiveRegular` field discharges are already carrier-agnostic | `ofSlicedStepRel_reflect`, `ofSlicedStep_compositional`, `ofSlicedStep_serial`, `ofSlicedStep_limit` | all four signatures read by name; none carries `[Finite W]` | High |
| Reset-to-`0`-from-any-level gives an infinite negative-duration fibre | `Probe746.Rbad_fib_infinite` | compiled probe | High |
| Moving the reset to fire only from `0` does **not** repair it | `Probe746.Rok_fwd_infinite` | compiled probe | High |
| `UCoh` + `ULive` force `LocalRun`'s `untl` field on every run | `Probe746B.untl_iff_of_UCoh_ULive` | compiled probe, zero sorries, axioms pinned | High |
| `Cons`'s untl conditions are non-vacuous, with a negative control | `Probe746C`, all `#guard`s pass; `live deferBad 0 = true` is the `Probe735` shape | compiled `#guard` evaluation | High |
| `eq_clTrace_of_localRun_anchored` suffices for **both** directions of `Presented`, so no new formula induction is needed | statement `(hr : LocalRun φ c) → (ha : Anchored M φ t c σ) → c = clTrace M φ t σ` | signature read by name; the two reductions are written out in Recommendations but **not compiled** | Medium — the reductions are argued from signatures, not machine-checked; Phase 4 is where they are paid for |
| `Anchored.box`/`Anchored.stab` are vacuous for `box`/`stab`-free `φ` | fields quantify over `h : box ψ ∈ plusSubformulaClosure φ`; `plusSubformulaClosure φ = (PlusFormula.subformulas φ).toFinset` | both read by name; the refuting lemma (`BoxStabFree` inheritance) **does not yet exist** and is listed as owed | Medium |
| The `Cons` untl/snce clauses force state-determined truth, hence `⊡ψ ↔ ψ` in `modelOf P` | mechanism is `plusStateLocal_stab_iff`'s semantic half (`isPlusStateLocal_of_stateLocal`) | the existing lemma is for the **syntactic** fragment `PlusFormula.StateLocal`; the semantic-hypothesis variant is a ~5-line restatement that was **not** written | Medium |
| `ofSlicedStep`'s `box` anchor is time-invariant because every world state lies on a history | argued from bi-seriality (`exists_iterS_fwd`/`exists_iterS_bwd` give finite segments) plus `ofSlicedStep_mem_HF_iff` | **no such lemma found in the tree**; a bi-infinite path through an arbitrary state needs a choice/limit construction not located | **Low — flagged, and deliberately not relied on.** `box`-free `φ` sidesteps it entirely, which is why the recommendation restricts scope rather than proving this |
| `Probe735.not_presented` does not refute this task | the probe refutes `Presented` on fixture model A (`a→a, a→b, b→b`), whose `a` self-loop is precisely a deferral cycle, so model A's step graph is **not** a `Cons` presentation; (S) quantifies the other way | read `not_presented`'s full proof; the mechanism is `key`'s pumped `untl` violation, which `ULive` forbids by construction | High |
| 17 files reference `ofSlicedStep`; in-place generalization would churn them | `grep -rl` across `FormalSystem/`, `Tests/`, `specs/evidence/` | file listing | High |

**Contradiction log.** One contradiction with the dispatch's own framing was found and resolved.

- *Dispatch*: "A regular-frame constructor for 'finitely many fibre shapes per time' is therefore a prerequisite, estimated 300-500 lines CARRIED from 742's research." *Research*: the constructor is not a prerequisite for (S) at all. **Resolved in favour of research**, on precedence: the dispatch itself states that `Cons P` must exclude pumpable deferring run sets, and the dispatch's own reason for the infinite slice ("liveness cannot be enforced by a step graph on a finite slice") is a statement about *enforcing* liveness — a completeness burden. For soundness, `Cons P` carries it. The dispatch also explicitly invited this: "RE-VERIFY THAT ESTIMATE — an inspection on 2026-10-08 found it may be pessimistic." The verdict is that it is pessimistic for a *different and larger* reason than the inspection found.
- *Dispatch, on the crux*: "the likely shape is: replace that one crude bound with a reachability bound under a finite-branching hypothesis." *Research*: a reachability bound is not what is needed; plain two-sided finite branching is, and it is enough. **Resolved in favour of research, machine-checked** (`fib_finite_of_finBranch`). This is a strengthening of the dispatch's guess, not a correction of its direction.

**UNRESOLVED**, stated rather than papered over: whether `box`/`stab`-bearing `φ` can be handled at all through this construction, or only with the `box`-global / `stab`-collapsed degeneracy. The resolving check not yet performed is whether every world state of `ofSlicedStep` lies on a history (the Low-confidence row above). This does not block (S) on `box`/`stab`-free `φ`, and the downstream risk is confined to how much of (W) this construction can be reused for.

**Recommendations modified after verification.** Three. (i) The prerequisite was moved out of the critical path and recast as a parallel constructor rather than an in-place generalization, after the 17-file reference count surfaced. (ii) The scope was restricted to `box`/`stab`-free `φ` after the stab-collapse mechanism was traced, rather than claiming full-closure `φ`. (iii) The `snce` mirror was separated out and explicitly labelled owed work, instead of being folded into Phase 1 as a symmetry of the compiled `untl` result — the forward-only constraint forbids that claim.

## Literature Proof Structure

**Source**: HWZ 2000, *Decidable fragments of first-order temporal logics*, Theorem 14 (⇐ direction) and Definitions 10-12, as attributed in `RaySummary/README.md`. **Provenance: UNVERIFIED summary.** Treated as orientation; no step below is cited as authority for a Lean claim, and the formalization's own declarations are the ground truth throughout.

**Strategy** (as the formalization reconstructs it, with the product repair this semantics forces): realize a quasimodel by *persistent runs* satisfying the run conditions. The quasimodel is the finite labelled presentation `(Q, lab, step, now)`; its runs are `IsRun`; persistence is the liveness the run conditions demand.

**Step map, with the Lean translation consideration for each**:

1. *HWZ Def 10-11 — state candidates and run conditions.* **Translation**: `lab` + `LocalRun`. The verbatim Def 10 bare type set is **refuted for this semantics** (`quasistate_does_not_determine_hit`) and is not transcribed; the alphabet is `clSig φ` and types are derived by the trace map, which `Anchored` implements.
2. *HWZ Def 11 — persistent runs.* **Translation**: the decidable pair `UCoh` + `ULive`, with `ULive` built on `Present.lean`'s `live`/`live_iff`. **Compiled** (probe 02). HWZ's persistence is a condition on runs; the repair here is that it is replaced by a condition on the *graph*, which is decidable and which the pumping argument shows is necessary.
3. *HWZ Def 12 — the quasimodel as a structure.* **Translation**: `Cons P`, the hypothesis bundle. The clause the paper does not have is clause 5 (once-only `now`), which this formalization needs because `IsRun` anchors the marker at one time.
4. *HWZ Thm 14 (⇐) — build a model from the quasimodel.* **Translation**: `modelOf P := ofSlicedStep` on `W := Q`. Regularity is free. The paper's construction over `⟨ℤ,<⟩` and this one agree on the shape; the formalization's frame constraints (`Compositional`, `Serial`, `Limit`, `Saturation`) have no paper counterpart and are discharged by the existing constructor.
5. *HWZ Thm 14 (⇐) — the truth lemma.* **Translation**: `eq_clTrace_of_localRun_anchored`, already in the tree. This is the step where the formalization is **shorter** than the paper, because the induction is landed.
6. *HWZ Lemma 17 — the splice / created-type hazard.* **Translation**: absorbed by the product alphabet, as the dispatch directed. `Cons` carries no created-type clause. On the other side, the *pumping* half of the same lemma is what `Cons` clause 3/4 excludes.

**Dependencies**: steps 1-3 are independent of 4; step 5 depends on 1-4; step 6 is a non-obligation discharged by the semantics rather than by a proof.

**Potential formalization challenges**, in order of expected difficulty: the `snce` mirror of step 2 (no symmetry is available — forward-only); the splice plumbing of step 5's (⇐) half (mitigated: copyable from `Probe735`'s `hsp` block); `Anchored`'s `box`/`stab` vacuity lemma (needs the new `BoxStabFree` inheritance result); and the `IsRun` `now`-structure bookkeeping in both directions of step 5.

**Divergence from the source, flagged**: `Presented` is trace-set *equality*, which is this formalization's own strengthening of HWZ (the README records this, and `Probe735.not_presented` shows the strengthening is exactly what fails as a completeness carrier). (S) discharges the strengthened form, which is legitimate because it is strictly stronger than what Theorem 14 (⇐) claims — and the Hit-level statement the acceptance criterion names is the weaker consequence, obtained from it by `hit_eq_hitOf_of_presented`.

## Tactic Survey Results

Tactics were exercised inside the three compiled probes rather than through `lean_multi_attempt`, since the probes needed to compile anyway and a compiled proof is stronger evidence than a tactic trial.

| Goal | Tactic / lemma used | Result | Notes |
|---|---|---|---|
| `{u | iterS R (n+1) t w u}` finite from the `n`-step case | `Set.Finite.biUnion` after an `ext`/`simp [iterS]` rewrite | works | the `n`-step image factors as a bi-union over the previous level |
| `{w | iterS R (n+1) t w u}` finite (the **preimage** side) | same, but the bi-union indexes over `{v | R (t+n) v u}` | works after an explicit `⟨fun ⟨v,h1,h2⟩ => ⟨v,h2,h1⟩, …⟩` swap | `simp [iterS]` normalizes the two existentials in opposite conjunct orders; `exact` with the swap is cheaper than `tauto` |
| `rcases le_or_lt 0 d` | **fails**: `le_or_lt` is not an identifier at this Mathlib pin | use `le_or_gt` | pin is Mathlib `v4.33.0-rc1` (`79d0395a`) |
| `Set.finite_insert 0 h` | **fails**: it is an `Iff` at this pin, not a function | use `Set.Finite.insert 0 h` | same pin note |
| `Bool.eq_false_or_eq_true b` | gives `b = true ∨ b = false` (that order) | — | branch order matters; got it backwards once |
| chain membership goal after `refine ⟨fun n => ρ (z+1+(n:ℤ)), …⟩` | `rw [hcast]` **fails** on an unreduced beta-redex | insert an explicit `show` to beta-reduce first, then `rw` | recurs whenever a `HasChain` witness is given as a lambda |
| `ℤ`/`ℕ` cast juggling in the persistence induction | `push_cast; omega`, and `omega` directly for `(r - z - 1).toNat` bounds | works throughout | no `Int.toNat` lemma needed by name |
| `#guard` on `live` over `Fin 3` | evaluates | works | `live`'s `Finset.univ` iterate is computable at this size; confirms the decidability claim for `ULive` operationally |
| doc comment `/-- … -/` immediately before `#guard` | **fails**: `unexpected token '#guard'; expected 'lemma'` | use `/-! … -/` | worth knowing before writing the permanent `#guard` block |

## Context Extension Recommendations

- **Topic**: Mathlib-pin-specific naming drift for `Set.Finite` and order lemmas at `v4.33.0-rc1`.
  **Gap**: `le_or_lt` is absent (use `le_or_gt`) and `Set.finite_insert` is an `Iff` rather than a function (use `Set.Finite.insert`). Both cost a compile round during this dispatch and neither is recorded anywhere in `context/project/lean4/`.
  **Recommendation**: add these two rows to a new or existing pin-drift table under `context/project/lean4/patterns/`.
- **Topic**: `#guard` and doc comments.
  **Gap**: `/-- … -/` before `#guard` is a parse error; the repo's `#guard`-heavy test files all use `/-! … -/` but nothing says why.
  **Recommendation**: one line in the lean4 rules or the `#guard` conventions note.
- **Topic**: the soundness/completeness asymmetry in where liveness lives.
  **Gap**: this dispatch's central finding — that an infinite-slice frame constructor is a *completeness* burden and not a *soundness* one — is the kind of reasoning that was carried forward unexamined across two records.
  **Recommendation**: a short pattern note under `context/project/lean4/patterns/`, to the effect that a carried prerequisite should be re-checked against the direction of the quantifier in the statement that needs it.

## Appendix

### Search queries and lookups used

- `grep` by declaration name across `FormalSystem/` for every substrate item the dispatch named, re-resolved by name per the anchor warning: `Presented`, `presented_localRun`, `hit_eq_hitOf_of_presented`, `hitOf`, `mem_hitOf_iff`, `IsRun`, `runTrace`, `pathTypes`, `live_iff`, `ofSlicedStep`, `ofSlicedStep_isRegular`, `ofSlicedStep_fib_finite`, `ofSlicedStep_saturation`, `Saturation`, `saturation_of_fib_finite`, `IsRegular`, `ofReflectiveRegular`, `seamOmegaEquiv`, `SeqPair`.
- Additional lookups: `LocalRun`, `Anchored`, `clTrace`, `clSig`, `eq_clTrace_of_localRun_anchored`, `plusSubformulaClosure`, `PlusTruthAt`, `plusStateLocal_stab_iff`, `IsPlusStateLocal`, `isBoxFree`, `ZPathFibre`, `worldHistoryOfStepPath`, `pump_isRun`, `not_presented`.
- Reference counts: `grep -rl ofSlicedStep` over `FormalSystem/`, `Tests/`, `specs/evidence/` → 17 files; `grep -c '\[Finite W\]' FormalSystem/Semantics/SlicedFrame.lean` → 11.
- Build/verification: `lake env lean <probe>` for each of the three probes, plus `#print axioms` on nine headline declarations. No `lake build` was run (nothing under `FormalSystem/` was modified). The lean-lsp MCP index was not consulted; the evidence tier of record for every positive claim is **compiled probe**, and the two Medium/Low-confidence rows in the verification table are explicitly marked as *not* compiled.

### Documentation references

- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` — "The verdict", including the (C)/(S)/(W) table that fixes this record's scope and the (S)/(W) line the `box`/`stab` restriction follows.
- `docs/theorem-index.md` rows 194-200 — the existing `hitOf`/`Presented` rows, including the four **Conditional** rows whose hypothesis this task would discharge for constructed models. A new row for the Phase 5 statement belongs beside them.
- `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` — where the acceptance criterion's axiom pins go.
- `Tests/BimodalTest/Metalogic/KTypeFinEvalTest.lean` — where the probe-03 `#guard` inhabitant belongs if it becomes a permanent computability witness.
