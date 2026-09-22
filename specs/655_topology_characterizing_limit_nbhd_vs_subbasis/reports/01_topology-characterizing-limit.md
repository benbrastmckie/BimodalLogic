# Research Report: Task #655

**Task**: 655 - Topology characterizing Limit: cone-neighbourhood topology 𝒩_F vs subbasis topology 𝒯_F
**Started**: 2026-09-22T16:16:11Z
**Completed**: 2026-09-22T16:48:33Z
**Effort**: ~35 minutes wall clock (5 compiled probe files, 1225 lines, 0 sorries)
**Dependencies**: None
**Sources/Inputs**:
- Manuscript: `/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex` (labels `def:task-relation`, `def:frame`, `lem:nullity`, `def:task-topology`, `app:topology-t1`, `app:topology-r0`, `def:world-history`, `app:dense`, `app:drift`, `def:deterministic`; prose at the frame-constraints paragraph and its footnote, and the "canonical topology" sentence)
- Frame-correspondence research: `/home/benjamin/Philosophy/Papers/PossibleWorlds/specs/archive/136_rewrite_mf_paragraph_frame_correspondence/reports/03_worlds-topological-categorical-characterization.md` (sections 4.1, 4.2, 4.2.3, 4.3.2, 4.3.6, 4.4.1, 4.4.2)
- Lean tree: `FormalSystem/Semantics/TaskFrame.lean` (`cone`, `Fib`, `Serial`, `Compositional`, `Saturation`, `saturation_of_finite`, `nullity_of_serial_limit`, `limit_of_shift`, `exists_uniform_radius_of_finite`), `FormalSystem/Semantics/ShiftSet.lean` (`sep`, `rev_sep`)
- Mathlib (v4.33.0-rc1 pin): `TopologicalSpace.generateFrom`, `TopologicalSpace.mkOfNhds`, `T1Space`, `R0Space`, `T2Space`, `DiscreteTopology`, `OrderTopology`, `TopologicalSpace.coinduced`, `Filter.IsBasis`, `t1Space_antitone`, `Metric.isOpen_iff`
- lean-lsp MCP (`lean_local_search`, `lean_run_code`) for name verification; `lake env lean` for every probe
**Artifacts**:
- This report: `specs/655_topology_characterizing_limit_nbhd_vs_subbasis/reports/01_topology-characterizing-limit.md`
- Probes (all compile with `lake env lean`, zero `sorry`, zero axioms beyond Mathlib's):
  - `specs/655_topology_characterizing_limit_nbhd_vs_subbasis/probes/NbhdTopology.lean` — the general theory (Q1, Q2, Q4)
  - `specs/655_topology_characterizing_limit_nbhd_vs_subbasis/probes/FourState.lean` — the four-state funnel witness
  - `specs/655_topology_characterizing_limit_nbhd_vs_subbasis/probes/IntPartition.lean` — the ℤ collapse
  - `specs/655_topology_characterizing_limit_nbhd_vs_subbasis/probes/RealFrames.lean` — metric, translation (𝔉¹) and drift (𝔉°) frames over ℝ
  - `specs/655_topology_characterizing_limit_nbhd_vs_subbasis/probes/TwoOrigins.lean` — T1-but-not-Hausdorff on a frame satisfying Compositionality, Seriality and Limit
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **Verdict (Q1)**: `𝒩_F` characterizes Limit exactly. `Limit ⟺ 𝒩_F is T1` is proved over a bare relation with **no other hypothesis at all** for the ⊆ half of Limit (`t1Space_nbhdTopology_iff_limit`); the paper's equality form needs additionally `w ∈ (w)_x`, which `lem:nullity` supplies from Seriality plus the ⊆ half. Report 03's "given Seriality and Compositionality" is one hypothesis too many: Compositionality is not consumed.
- **Correction to report 03**: `𝒯_F` and `𝒩_F` are **not** incomparable. Given only `w ⇒_0 w`, every `𝒩_F`-open set is a union of cones, so `𝒯_F` is always finer (`coneTopology_le_nbhdTopology`), strictly in general. Consequently `app:topology-t1` is a two-line corollary of the biconditional (T1 is inherited by finer topologies) and its proof **does not need the reflection convention** (`t1Space_coneTopology_of_limit`).
- **Q2**: `𝒩_F` is `TopologicalSpace.mkOfNhds` of the cone filters — the finest topology in which every neighbourhood of `w` contains a cone at `w` (`nbhdTopology_le_of_coneFilter_le_nhds`); the cones at `w` form a filter base (`isBasis_cone`); its closed sets are exactly the sets closed under arbitrarily short tasks (`nbhdTopology_isClosed_iff`); every history is `𝒩_F`-continuous with no axiom consumed (`continuous_nbhdTopology_of_history`), so `𝒩_F` lies below the final topology (`finalTopology_le_nbhdTopology`), strictly in general (hedgehog frame, UNVERIFIED). Cones are `𝒩_F`-open under a triangle (mixed-sign composition) condition, over ℤ, and in every deterministic/metric frame; not in general (`not_isOpen_cone_R4`).
- **Q3**: Everything the manuscript states survives with `𝒩_F` in place of `𝒯_F`, with shorter proofs; `app:topology-r0` is unchanged. `𝒩_F` is R0 under Limit; without Limit it need not be (UNVERIFIED spoke example). `𝒩_F` is Hausdorff on every named example frame, and discrete over ℤ, but **T1-not-Hausdorff occurs inside the four-axiom class**: the half-line with two origins (`not_t2Space_nbhdTopology_RTO`; Saturation for it argued on paper). Report 03's `H_F` compactness and orbit-space results never touch either topology and are unaffected.
- **Q4**: The gap is exactly the one-way instantaneous pairs. Under reflection, composition and "no one-way pairs", `𝒯_F` T1 implies Limit (`limit_of_t1Space_coneTopology`); the funnel is a one-way pair (`not_noOneWay_R4`).
- **Q5 recommendation: option (a)** — replace `𝒯_F` by `𝒩_F` in `def:task-topology`, restate `app:topology-t1` as the biconditional under Seriality alone, keep `app:topology-r0` verbatim, add a one-line continuity lemma, and record the old subbasis topology in a footnote with the funnel. Draft statements are in section 5. The refactor should give the **general** frame a `TopologicalSpace F.WorldState := nbhdTopology F.TaskRel` instance and derive `T1Space`/`R0Space` instances from the regular class.
- **Q6**: "regular" is clean in the Lean tree; in the manuscript it occurs only inside the defined term "irregular worlds" (`:1431`, `:1434`). The nearer term-of-art risk is not Lemmon's regular logics but **topological regularity (T3)**, which this very appendix now sits beside; one disclaiming footnote handles both. Proposed identifiers: `FrameOver` (general, unchanged) + `class FrameOver.IsRegular : Prop`.

## Context & Scope

The manuscript defines `𝒯_F` by "Basic Opens: `B_F := {(w)_x : w ∈ W, x > 0}`; Topology: `𝒯_F := ⟨W, 𝒪_F⟩` where `𝒪_F` is the result of closing `B_F` under arbitrary union and finite intersection" (`def:task-topology`), proves "`𝒯_F` is T1 for every task frame" (`app:topology-t1`, whose proof moves via "`w ⇒_0 w` by `lem:nullity`" and "`u ⇒_{-y} w` by the reflection convention" to `w ∈ ⋂_{x>0} (u)_x = {u}`), and derives R0 (`app:topology-r0`). Report 03 §4.2.3 exhibited the four-state funnel on which `𝒯_F` is discrete while Limit fails, and proposed `𝒩_F`.

This report re-derives everything over bare relations `R : W → D → W → Prop` using the library's `TaskFrame.cone` and the library's literal Limit shape `∀ w u, (∀ x, 0 < x → ∃ y, |y| < x ∧ R w y u) → u = w` (the ⊆ half of the paper's equality), so every result applies verbatim to `F.TaskRel` after the refactor. Nothing under `FormalSystem/` or `Tests/` was touched. Every topological claim below carries either the name of a compiled, sorry-free declaration or the label **UNVERIFIED**.

**Conventions.** `D` is a nontrivial linearly ordered additive commutative group; `(w)_x := cone R w x = {u | ∃ y, |y| < x ∧ R w y u}`; "nullity" means `∀ w, R w 0 w`; "reflection" means `R w d u → R u (-d) w`; "composition" means the ← half of Compositionality. Mathlib orders topologies by `t₁ ≤ t₂ ↔` every `t₂`-open set is `t₁`-open, so "`𝒯_F` is finer than `𝒩_F`" is `coneTopology R ≤ nbhdTopology R`.

## Findings

### 1. Q1 — The characterization

**1.1 Definitions.** (`NbhdTopology.lean`)

- `coneTopology R := generateFrom {s | ∃ w x, 0 < x ∧ s = cone R w x}` — this is `𝒯_F` exactly as `def:task-topology` states it.
- `nbhdTopology R` — `𝒩_F`: `IsOpen O ↔ ∀ w ∈ O, ∃ x, 0 < x ∧ cone R w x ⊆ O` (`nbhdTopology_isOpen_iff`). The three topology axioms are discharged from `cone_mono` (nesting in the radius) and the existence of a positive duration (`exists_pos_duration`, which is where `[Nontrivial D]` is consumed — over a trivial `D` no set could be open).

**1.2 The theorem.** `t1Space_nbhdTopology_iff_limit (R) : @T1Space W (nbhdTopology R) ↔ Limit R`, where `Limit R` is the library's ⊆-shape. **No frame condition is consumed in either direction.** The proof is four lines each way: `{u}ᶜ` is `𝒩_F`-open iff every `w ≠ u` has a cone omitting `u`, which is the contrapositive of the ⊆ half of Limit.

The paper's equality `⋂_{x>0}(w)_x = {w}` is `Limit R ∧ ∀ w x, 0 < x → w ∈ (w)_x` (`limit_eq_iff`), and the second conjunct follows from nullity (`mem_cone_self`), which the library derives from Seriality plus the ⊆ half (`nullity_of_serial_limit`). Hence, **for any structure satisfying Seriality, the paper's Limit holds iff `𝒩_F` is T1.** Report 03's extra hypothesis (Compositionality, used there to manufacture `w ⇒_0 w` through reflection-at-zero) is not needed.

**1.3 `𝒯_F` is finer, not incomparable.** `coneTopology_le_nbhdTopology (R) (h0 : ∀ w, R w 0 w) : coneTopology R ≤ nbhdTopology R`. Proof: an `𝒩_F`-open `O` equals `⋃₀ {c | c is a cone ∧ c ⊆ O}`, because each `w ∈ O` lies in its own cone `(w)_x ⊆ O` by nullity. Report 03 §4.2.3's sentence "In general `𝒩_F` and `𝒯_F` are incomparable (cones need not be `𝒩_F`-open …)" is half right: cones need not be `𝒩_F`-open (1.5 below), which shows `𝒯_F ⊄ 𝒩_F`; but `𝒩_F ⊆ 𝒯_F` always. The two coincide exactly when every cone is `𝒩_F`-open (`coneTopology_eq_nbhdTopology_iff`).

**1.4 `app:topology-t1` and `app:topology-r0`, re-derived.** `t1Space_coneTopology_of_limit (R) (h0) (hlim) : @T1Space W (coneTopology R)` is `t1Space_antitone` applied to 1.3 and 1.2. Consumed: Limit (⊆) and nullity; **the reflection convention is not consumed**, unlike the paper's proof, which uses it to pass from `u ∈ (w)_x` to `w ∈ (u)_x`. `r0Space_nbhdTopology_of_limit` and `r0Space_coneTopology_of_limit` come from Mathlib's `T1Space → R0Space` instance; the paper's R0 proof is topology-agnostic and survives verbatim.

**1.5 The converse fails for `𝒯_F`: the four-state funnel** (`FourState.lean`, `W = Fin 4`, any `[DenselyOrdered D]`). `R4 w x u :⇔ (x = 0 ∧ w = u) ∨ (0 < x ∧ (w = u ∨ (w < 2 ∧ 2 ≤ u))) ∨ (x < 0 ∧ (w = u ∨ (u < 2 ∧ 2 ≤ w)))`.

| Claim | Declaration |
|---|---|
| Reflection law at every duration | `R4_reflection` |
| Seriality (`TaskFrame.Serial`) | `R4_serial` |
| Compositionality, both halves (`TaskFrame.Compositional`) | `R4_compositional` (`decide` on `Fin 4` after sign case-split) |
| Saturation (`TaskFrame.Saturation`) | `R4_saturation` (via library `saturation_of_finite`) |
| Cone membership `u ∈ (w)_x ↔ w = u ∨ (w low ∧ u high) ∨ (u low ∧ w high)` | `mem_cone_R4` (uses density: `exists_between`) |
| Limit fails: `2 ∈ (0)_x` for all `x > 0` | `R4_not_limit` |
| `{w} = ⋂_{v ∈ (w)_x} (v)_x` — every singleton is a finite intersection of cones | `singleton_eq_biInter_cone_R4` |
| `𝒯_F` is **discrete**, hence T1 | `discreteTopology_coneTopology_R4`, `t1Space_coneTopology_R4` |
| `𝒩_F` is **indiscrete** (`= ⊤`), hence not T1 | `nbhdTopology_R4_eq_top`, `not_t1Space_nbhdTopology_R4` |
| The cone `(0)_x` is not `𝒩_F`-open | `not_isOpen_cone_R4` |
| One-way instantaneous pair `0 → 2` | `not_noOneWay_R4` |

The mechanism is visible in `singleton_eq_biInter_cone_R4`: `0` is isolated by cones centred at `2` and `3`, which Limit — a condition on cones centred at `0` — cannot see. Over ℤ the same relation has `(w)_1 = {w}` and satisfies Limit; the funnel needs a dense `D` (section 3).

**1.6 `sep` does not imply Limit** (UNVERIFIED in Lean; re-derived). Histories over `R4` are constant, or constant in `{0,1}` up to a jump time `c` and constant in `{2,3}` after (`c` on either side). If `τ = y₁·σ = y₂·σ` with `y₁ ≠ y₂` then `τ = (y₂−y₁)·τ`, so the jump set of `τ` is translation-invariant, hence empty, so `τ` is constant and `σ = τ`. Hence `σ = y·τ` for arbitrarily small `|y|` forces `σ = τ`: `ShiftSet.sep` holds on `H_{R4}` while Limit fails, so `rev_sep` (`ShiftSet.lean:326`) is genuinely one-directional. No statement change to `ShiftSet.lean` is implied.

### 2. Q2 — What `𝒩_F` is

**2.1 Neighbourhood system, filter base.** The task's parenthetical asks whether `𝒩_F` is "the finest topology in which each `(w)_x` is a neighbourhood of `w`". That phrase picks out the discrete topology (in which every set containing `w` is a neighbourhood). The correct statement, verified:

- `coneFilter R w := ⨅ x > 0, 𝓟 (cone R w x)`; `mem_coneFilter : s ∈ coneFilter R w ↔ ∃ x > 0, cone R w x ⊆ s`; the cones at `w` are a filter base — nested, with nonempty index set (`isBasis_cone : Filter.IsBasis (0 < ·) (cone R w ·)`). So yes, they form a filter base; the nesting is `cone_mono`.
- `nbhdTopology_eq_mkOfNhds : nbhdTopology R = TopologicalSpace.mkOfNhds (coneFilter R)`.
- `coneFilter_le_nhds : coneFilter R w ≤ 𝓝[𝒩_F] w` — every `𝒩_F`-neighbourhood of `w` contains a cone at `w`; and `nbhdTopology_le_of_coneFilter_le_nhds : (∀ w, coneFilter R w ≤ 𝓝[t] w) → nbhdTopology R ≤ t` — **`𝒩_F` is the finest topology with that property.** The cones are not in general `𝒩_F`-neighbourhoods of their centres (1.5), so `𝓝[𝒩_F] w ≠ coneFilter R w` in general; equality holds exactly under Mathlib's `nhds_mkOfNhds` side condition, which is the cone-openness condition of 2.4.

**2.2 Closed sets** (`nbhdTopology_isClosed_iff`): `C` is `𝒩_F`-closed iff `∀ w, (∀ x > 0, (w)_x ∩ C ≠ ∅) → w ∈ C` — "closed under limits of arbitrarily short tasks", in the one-step sense that topological closedness always has for a neighbourhood-system topology (not an iterated or sequential closure).

**2.3 Histories are continuous; the final topology.** `IsHistory R τ := ∀ x y, R (τ x) (y - x) (τ y)` (`def:world-history` at `X = D`). `continuous_nbhdTopology_of_history [OrderTopology D] : IsHistory R τ → Continuous[order, 𝒩_F] τ` — with **no frame axiom consumed**: for `z ∈ τ⁻¹O` and `(τ z)_x ⊆ O`, the order-open interval `(z − x, z + x)` maps into `(τ z)_x`. Therefore the final topology of all histories, `⨆_τ coinduced τ`, is finer: `finalTopology_le_nbhdTopology`.

Whether `𝒩_F` *equals* the final topology: **no in general** (UNVERIFIED, paper argument). The *hedgehog* frame over `D = ℝ`: a centre `w`, spokes `p_n^{(t)}` (`n ≥ 1`, `0 < t ≤ 1/n`) with `w ⇒_x p_n^{(t)}` iff `t ≤ x` and drift `p_n^{(t)} ⇒_x p_n^{(t')}` iff `t ≤ t' ≤ t + x`, tips `p_n^{(1/n)}` looping, all states looping, negatives by reflection. It satisfies Compositionality, Seriality, Limit (same case analysis as `TwoOrigins.lean`, one spoke at a time), and Saturation by the shadow argument of 3.3. Let `O := W ∖ {tips}`. Every history through `w` leaves `w` along one spoke and reaches that spoke's tip, if at all, at a time bounded away from its departure (it must traverse length `1/n` at speed `≤ 1`), so every `τ⁻¹O` is an open ray or all of `ℝ`: `O` is final-open. But `(w)_x ∋ p_n^{(1/n)}` whenever `1/n < x`, so no cone at `w` lies in `O`: `O` is not `𝒩_F`-open. On the four-state funnel both topologies are indiscrete (a history `1` on `(−∞, c)`, `2` on `[c, ∞)` shows a set containing a low state but not a high one is never final-open); on the metric frame both are Euclidean (the straight-line history through `w` hits every nearby point). A frame condition equivalent to `𝒩_F = final` is **open**; the obstruction is that the Extension theorem gives one history per escape, never one history witnessing all escapes.

**2.4 When are cones `𝒩_F`-open?** Define `Triangle R := ∀ w u v y z, R w y u → R u z v → ∃ t, |t| ≤ |y| + |z| ∧ R w t v`. Same-sign composition supplies this with `t = y + z`; what `Triangle` adds is precisely the mixed-sign case that `def:frame` leaves "inexpressible at the primitive level". Then:

- `isOpen_cone_of_triangle : Triangle R → IsOpen[𝒩_F] (cone R w x)`;
- `coneTopology_eq_nbhdTopology_of_triangle : (∀ w, R w 0 w) → Triangle R → coneTopology R = nbhdTopology R`.

Instances: every deterministic frame in the group-action sense (`R w y u ↔ u = f_y w` with `f` a `D`-action; `t := y + z`, `|y+z| ≤ |y|+|z|`), the ℝ-metric frame, the translation frame `𝔉¹`, the drift frame `𝔉°` (section 3), and every frame over ℤ whose `⇒_0` is an equivalence relation (`IntPartition.lean`). Non-instances: the funnel (`not_isOpen_cone_R4`), and inside the four-axiom class the hedgehog of 2.3 (UNVERIFIED): `(p_n^{(t)})_{x}` contains `w` when `t < x`, but `w`'s cones spread into every spoke.

### 3. Q2/Q3 — The two topologies on the paper's named frames and frame classes

**3.1 Over ℤ** (`IntPartition.lean`, any `W`). `cone_int_one : (w)_1 = Fib(w, 0)`; `nbhdTopology_isOpen_iff_int : O is 𝒩_F-open ↔ O is closed under ⇒_0`; `coneTopology_eq_nbhdTopology_int : 𝒯_F = 𝒩_F` given `⇒_0` reflexive, symmetric, composing, and the reflection law; `limit_int_iff : Limit ↔ ⇒_0 ⊆ id`; `discreteTopology_nbhdTopology_int_iff : 𝒩_F discrete ↔ ⇒_0 ⊆ id`. So over ℤ both topologies are the partition topology of `⇒_0`, and Limit ⟺ discrete ⟺ T1 ⟺ Hausdorff. The two-state frame of `app:dense` ("`w ⇒_0 w'` iff `w = w'` and `w ⇒_d w'` for all `w, w'` and `d > 0`", over the non-dense `D` with least positive `ε`) is discrete for both — the paper's own verification "`(w)_ε = {w}`" is exactly `cone_int_one` at `ε`.

**3.2 Over ℝ, the named frames** (`RealFrames.lean`): for `metricRel r x s :⇔ |s − r| ≤ |x|`, `translationRel r x s :⇔ s = r + x` (the "translation frame `𝔉¹`" of `cor:no-characterization`, "`w ⇒¹_x u` just in case `u = w + x`"), and `driftRel` (the drift frame `𝔉°` of `app:drift`, "`x ≤ u − w ≤ 2x` for `x ≥ 0`, extended … by `def:task-relation`"): `cone_metricRel`, `cone_translationRel` (`= Metric.ball r x`), `cone_driftRel` (`= Metric.ball r (2x)`); hence `nbhdTopology_metric`/`_translation`/`_drift : 𝒩_F = the Euclidean topology` (`nbhdTopology_eq_real`) and `coneTopology_metric`/`_translation`/`_drift : 𝒯_F = 𝒩_F` (`coneTopology_eq_nbhdTopology_real`). Consequently both are T1, R0, **Hausdorff** (`t2Space_nbhd_metric`) and **not discrete** (`not_discrete_nbhd_metric`, `not_discreteTopology_real`). `driftRel_reflection` checks the reflection law for `𝔉°` at every duration.

**3.3 T1 but not Hausdorff inside the four-axiom class** (`TwoOrigins.lean`, `D = ℝ`). `W = {o true, o false} ∪ {p t : t > 0}`; origins loop at every duration; `o b ⇒_x p t` iff `t ≤ x`; `p t ⇒_x p s` iff `t ≤ s ≤ t + x` (`x ≥ 0`), reflected. Verified: `RTO_serial`, `RTO_compositional` (both halves), `RTO_limit`, `t1Space_nbhdTopology_RTO`, and `not_t2Space_nbhdTopology_RTO`: any open set around either origin contains `p t` for all small `t`. This is the half-line with two origins, the textbook T1-non-Hausdorff space, realized as a task frame. **Saturation (UNVERIFIED)**: map `W → [0, ∞)` by `o b ↦ 0`, `p t ↦ t`; every fibre and segment has closed shadow (`Fib(o b, x) ↦ [0, x]`, `Fib(p t, x) ↦ [t, t + x]`, backward fibres and segments are intersections of such), so a `⊇`-directed family of nonempty fibres/segments has a common shadow point `r` by compactness of `[0, 1]`-type intervals; if `r > 0` then `p r` is in every member; if `r = 0` every member contains an origin, and directedness forbids one member containing only `o true` and another only `o false` (their common sub-member would contain neither, contradicting `r = 0`), so one origin is in every member. The ℚ-indexed version fails Saturation (nested rational intervals with irrational limit), so this witness is genuinely over ℝ; a regular T1-non-Hausdorff frame over ℚ is **open**.

*What "T1 but not Hausdorff" means for the paper.* T1 = Limit = "distinct world states are instantaneously separated" (the manuscript's own gloss in the frame-constraints paragraph): no state lies in every short-task cone of another. Hausdorff would demand more: that two distinct states have short-task cones that are eventually *disjoint*. The two-origin frame has two states that no task of any duration connects, yet whose immediate futures coincide at every scale — they are distinguishable by what they *are* but not by what they can *do next*. Limit was never meant to exclude that; the paper's picture (task frames as dynamical systems) is one in which branching from indistinguishable starts is a feature. So `𝒩_F` being T1 and not Hausdorff is the right level of separation, and the paper should not claim more.

**3.4 R0 without Limit** (UNVERIFIED, paper argument). Under Limit both topologies are R0 (1.4). Without Limit, in the class satisfying Seriality and Compositionality, `𝒩_F` need not be R0: take the hedgehog of 2.3 with a second special state `u` and `u ⇒_x p_n^{(1/n)}` (tips) for all `x > 0`, i.e. tips-to-`u` by reflection; then every open set containing `w`… — more simply, with `w` reaching all spoke points near the centre and `u` reaching all tips instantaneously, `w ∈ cl{u}` (any open around `u` contains a tip, whose cones at every radius contain `w` via the tip's reflected instantaneous link) while `u ∉ cl{w}` (`{w} ∪` all spoke points is open and omits `u`). Over ℤ with symmetric `⇒_0` the partition topology is R0. So: R0 for `𝒩_F` is exactly as robust as T1 — a consequence of Limit, not of the other three axioms.

**3.5 Discreteness.** `𝒩_F` is discrete iff every state `w` has a *dwell time* `x_w > 0` with `(w)_{x_w} = {w}` (immediate from `nbhdTopology_isOpen_iff`, UNVERIFIED as a named lemma). Report 03 §4.3.6's rigidity theorem says a *uniform* dwell time over dense Archimedean `D` forces the static frame; the pointwise version does not (spokes of shrinking length). Over ℤ discreteness is Limit (3.1); on every named dense-time example frame it fails (3.2); the static frame is discrete over every `D`.

**3.6 Report 03's other results.** §4.3.2 (compactness dichotomy, pro-discrete structure of `H_F`), §4.3.3, §4.4.2 (orbit space) all give `W` the *discrete* topology and never mention `𝒯_F` or `𝒩_F`; they are unaffected by any change to `def:task-topology`. §4.4.1's closing remark — the shift action is a flow over ℝ "only after retopologizing `W` by `𝒩_F`, along which histories are continuous" — is confirmed by `continuous_nbhdTopology_of_history`. The dictionary rows of §4.2 are amended as follows: Limit row 1 (`𝒯_F` T1, ⟹ only) stands; Limit row 2 (`𝒩_F` T1, ⟺) stands with the weaker hypothesis "given Seriality" and with the parenthetical "incomparable" replaced by "`𝒯_F` is finer"; Limit row 3 (ℤ) stands and is now machine-checked. The entourages `U_x := {(w,u) : u ∈ (w)_x}` are symmetric under reflection and `⋂_x U_x = Δ` is Limit (⊆) plus nullity, but they are not a uniformity base (no square-root property — `Triangle` fails in general), so "separated pre-uniformity" is the accurate phrase.

### 4. Q4 — The funnel is the whole gap

`QuickFwd R w u :⇔ ∀ x > 0, ∃ y, 0 ≤ y < x ∧ R w y u`; `NoOneWay R :⇔ ∀ w u, QuickFwd R w u → QuickFwd R u w`.

**`limit_of_t1Space_coneTopology`**: under reflection, composition (← half only) and `NoOneWay`, `@T1Space W (coneTopology R) → Limit R`. Proof structure (all in Lean): (i) if `u` is in every cone of `w` then `QuickFwd w u ∨ QuickFwd u w` (a minimum-of-two-radii argument), hence both by `NoOneWay`; (ii) *every cone containing `w` contains `u`* — for `w ∈ (v)_x` via `v ⇒_y w`: if `y ≥ 0`, compose with `w ⇒_{y'} u` for `y' < x − y`; if `y < 0`, reflect to `w ⇒_{−y} v`, compose with `u ⇒_{y'} w` for `y' < x + y`, and reflect back; (iii) by induction on `TopologicalSpace.GenerateOpen`, every `𝒯_F`-open set containing `w` contains `u`; (iv) T1 makes `{u}ᶜ` open, contradiction unless `u = w`.

Contrapositively: **every structure on which `𝒯_F` is T1 and Limit fails contains a one-way instantaneous pair** — a `w`, `u` with `w ⇒_y u` for arbitrarily small `y ≥ 0` but not conversely. That is the funnel's signature (`not_noOneWay_R4`: `0 → 2` is one-way). So "T1 for `𝒯_F` plus no one-way pairs" recovers Limit, and the general shape of the gap between the two topologies is: `𝒯_F` can use cones centred at a *third* point `v` to separate `w` from `u`, which requires `w ∈ (v)_x ∌ u`; with two-sided instantaneity and composition, `u` would ride along into `(v)_x`. Only one-way instantaneity blocks the ride.

Note the theorem does not require the pair to be *between tiers* or to have *two* states on each side; the four-state minimality in report 03 ("no frame with at most three states … does this") is about constant positive-duration relations and finite `W`, and is not contradicted: with three states one cannot both have a one-way pair and isolate each point by cones centred elsewhere.

### 5. Q5 — Recommendation and drafts

**Verdict: (a).** Replace `𝒯_F` by `𝒩_F` in `def:task-topology`, state the biconditional, keep R0, add continuity, footnote the old topology. Reasons: (i) the biconditional is the theorem the surrounding prose already claims ("distinct world states are instantaneously separated"; "the task relation induces a canonical topology on world states"), and it holds under Seriality alone; (ii) the new definition is *shorter* than the old — one clause instead of a subbasis closure — and its proofs are shorter and consume less (no reflection); (iii) `𝒩_F` is the topology that makes possible worlds continuous paths, which is the dynamical reading the paper wants; (iv) `𝒯_F` retains no independent role: it is finer, T1 for the same reason, and its T1-ness is not a frame property. Option (b) would carry two topologies for one theorem; option (c) would leave a definition whose headline property does not characterize anything.

**Draft `def:task-topology`** (house style; replaces the Basic Opens and Topology clauses, keeps Closure, T1, R0 verbatim):

```latex
\begin{Ddef} \label{def:task-topology}
	Given a task frame $\F = \tuple{W, \D, \Rightarrow}$, define:
	\begin{enumerate}[wide=0pt, labelsep=.1in, itemsep=.075in]
		\item[\it Open Sets:] $\mathcal{O}_{\F} \coloneq \set{O \subseteq W : \text{for every } w \in O \text{ there is some } x > 0 \text{ where } (w)_x \subseteq O}$.
		\item[\it Topology:] $\mathcal{T}_{\F} \coloneq \tuple{W, \mathcal{O}_{\F}}$.
		\item[\it Closure:] $\overline{S} \coloneq \set{w \in W : O \cap S \neq \emptyset \text{ for every open } O \in \mathcal{O}_{\F} \text{ where } w \in O}$ for $S \subseteq W$.
		\item[\it T1:] A topology is \textit{T1} just in case $\overline{\set{w}} = \set{w}$ for all $w \in W$.
		\item[\it R0:] A topology is \textit{R0} just in case $w \in \overline{\set{u}}$ iff $u \in \overline{\set{w}}$ for all $w, u \in W$.
	\end{enumerate}
\end{Ddef}
```

with a one-sentence justification after the definition (or a footnote): "Since $(w)_x \subseteq (w)_y$ whenever $x \leq y$ and $\D$ has a positive duration, $\mathcal{O}_{\F}$ contains $\emptyset$ and $W$ and is closed under arbitrary union and finite intersection, so $\mathcal{T}_{\F}$ is a topology." (Verified: the three fields of `nbhdTopology`.) A footnote recording the old topology: "The topology generated by the cones as a subbasis is finer than $\mathcal{T}_{\F}$ and is likewise \textit{T1} in every task frame, but its being \textit{T1} does not characterize \textit{Limit}: on $W = \set{0,1,2,3}$ over a dense $\D$ with $w \Rightarrow_x u$ iff $w = u$ or $w \in \set{0,1}$ and $u \in \set{2,3}$ for $x > 0$, every singleton is a finite intersection of cones while $(0)_x = \set{0,2,3}$ for every $x > 0$." (Verified: `FourState.lean`.)

**Draft `app:topology-t1`** (now a biconditional; the class quantified over must drop Limit, so it is stated for structures satisfying Seriality — the only axiom consumed):

```latex
\begin{Tthm} \label{app:topology-t1}
	Let $\F = \tuple{W, \D, \Rightarrow}$ satisfy \textit{Seriality}. Then $\F$ satisfies \textit{Limit} iff $\mathcal{T}_{\F}$ is \textit{T1}. In particular, $\mathcal{T}_{\F}$ is \textit{T1} for every task frame.
\end{Tthm}

\begin{proof}
	($\Rightarrow$) Let $u \in W$. Since $u \in O \cap \set{u}$ for every open $O$ containing $u$, $\set{u} \subseteq \overline{\set{u}}$ by \textit{Closure}.
	For the converse inclusion, consider any $w \neq u$.
	Since $u \notin \set{w} = \bigcap_{x > 0} (w)_x$ by \textit{Limit}, there is some $x > 0$ where $u \notin (w)_x$, and so $(w)_x \subseteq W \setminus \set{u}$.
	Thus $W \setminus \set{u}$ is open by \textit{Open Sets}, and since it contains $w$ and misses $\set{u}$, $w \notin \overline{\set{u}}$ by \textit{Closure}.
	Hence $\overline{\set{u}} = \set{u}$, and so $\mathcal{T}_{\F}$ is \textit{T1}.

	($\Leftarrow$) Suppose $\mathcal{T}_{\F}$ is \textit{T1}, and consider any $w \in W$.
	If $u \in \bigcap_{x > 0} (w)_x$ and $u \neq w$, then $W \setminus \set{u} = W \setminus \overline{\set{u}}$ is open and contains $w$, so $(w)_x \subseteq W \setminus \set{u}$ for some $x > 0$, contradicting $u \in (w)_x$.
	Thus $\bigcap_{x > 0} (w)_x \subseteq \set{w}$.
	By \textit{Seriality} at $x = 0$ there is some $v$ where $w \Rightarrow_0 v$; since $\vert{0} < x$ for every $x > 0$, $v \in \bigcap_{x > 0} (w)_x \subseteq \set{w}$, so $w \Rightarrow_0 w$, whence $w \in (w)_x$ for every $x > 0$.
	Hence $\bigcap_{x > 0} (w)_x = \set{w}$, and so $\F$ satisfies \textit{Limit}.
\end{proof}
```

(Verified: `t1Space_nbhdTopology_iff_limit`, `limit_eq_iff`, `mem_cone_self`, library `nullity_of_serial_limit`. Note the (⇐) direction *re-proves* `lem:nullity` inline because `lem:nullity` is stated for task frames, which presuppose Limit; alternatively restate `lem:nullity` for structures satisfying Seriality and the ⊆ half of Limit, which is what the Lean `nullity_of_serial_limit` already does, and cite it.)

**`app:topology-r0`**: unchanged, verbatim — its proof uses only `app:topology-t1` and the definitions of Closure and R0. (Verified: `r0Space_nbhdTopology_of_limit`.)

**New lemma (recommended, optional)**:

```latex
\begin{Lthm} \label{app:topology-continuous}
	Every possible world $\tau \in H_{\F}$ is continuous from $\D$ with the order topology to $\mathcal{T}_{\F}$.
\end{Lthm}

\begin{proof}
	Let $O \in \mathcal{O}_{\F}$ and $z \in \tau^{-1}(O)$, so $(\tau(z))_x \subseteq O$ for some $x > 0$ by \textit{Open Sets}.
	For any $y$ with $z - x < y < z + x$, $\tau(z) \Rightarrow_{y - z} \tau(y)$ by \textbf{\ref{def:world-history}} with $\vert{y - z} < x$, so $\tau(y) \in (\tau(z))_x \subseteq O$.
	Thus $\tau^{-1}(O)$ contains the open interval $(z - x, z + x)$ around each of its points, and so is open in the order topology.
\end{proof}
```

(Verified: `continuous_nbhdTopology_of_history`; no frame axiom is used, so it holds for partial histories with `X = D` over any structure.)

**Cost in other sections** (every live citation of `def:task-topology`/`app:topology-t1`/`app:topology-r0`, by grep):

| Site | Current text | Change |
|---|---|---|
| Footnote at the frame-constraints paragraph (`:992`–`:995`): "The set of \textit{basic opens} $B_{\F} \coloneq \set{(w)_x : \ldots}$ generates a topology $\mathcal{T}_{\F}$ … closing $B_{\F}$ under arbitrary union and finite intersection. The \textit{Appendix} proves in app:topology-t1 that $\mathcal{T}_{\F}$ is \textit{T1}, and hence \textit{R0} …" | Replace the first sentence by "The cones induce a topology $\mathcal{T}_{\F}$ on $W$ in which a set is open just in case it contains some cone $(w)_x$ around each of its members $w$." and the second by "The \textit{Appendix} proves in app:topology-t1 that $\mathcal{T}_{\F}$ is \textit{T1} exactly when \textit{Limit} holds, and hence \textit{R0} as shown in app:topology-r0." | one footnote |
| "Given that the task relation induces a canonical topology on world states, app:topology-t1 establishes that this topology is \textit{T1} for every task frame, with \textit{R0} following as app:topology-r0." (`:1675`) | Optionally sharpen "for every task frame" to "for every task frame, and indeed exactly when \textit{Limit} holds"; the sentence is true as written. | zero or one clause |
| Comment "`(def:task-topology, app:topology-t1, app:topology-r0 RELOCATED to app:TaskSemantics)`" (`:3914`) | none | — |
| `lem:nullity` | none; optionally generalize its hypothesis as noted above | — |

No other section cites these labels. The `def:frame` gloss "distinct world states are instantaneously separated" (`:992`) becomes literally true of `𝒯_F` under the new definition.

**What the Lean refactor should build** (task 656 and its dependents):

1. A new module `FormalSystem/Semantics/StateTopology.lean` (keep `TaskFrame.lean` free of `Mathlib.Topology` imports; the topology file imports `TaskFrame` plus `Mathlib.Topology.Separation.Basic`, `Mathlib.Topology.Order`, `Mathlib.Topology.Order.Basic`). Contents, lifted from `NbhdTopology.lean` with the same names: `Limit` (named predicate — see 3 below), `coneTopology`, `nbhdTopology`, `nbhdTopology_isOpen_iff`, `nbhdTopology_isClosed_iff`, `t1Space_nbhdTopology_iff_limit`, `limit_eq_iff`, `coneTopology_le_nbhdTopology`, `t1Space_coneTopology_of_limit`, `r0Space_*`, `coneFilter`, `isBasis_cone`, `mem_coneFilter`, `nbhdTopology_eq_mkOfNhds`, `coneFilter_le_nhds`, `nbhdTopology_le_of_coneFilter_le_nhds`, `IsHistory`/`continuous_nbhdTopology_of_history`, `finalTopology_le_nbhdTopology`, `Triangle`, `isOpen_cone_of_triangle`, `coneTopology_eq_nbhdTopology_of_triangle`, `coneTopology_eq_nbhdTopology_iff`, `QuickFwd`, `NoOneWay`, `limit_of_t1Space_coneTopology`. All are library-grade as they stand (bare-relation statements, explicit hypotheses, no `sorry`, no `native_decide`, no `classical` beyond Mathlib's).
2. **Instances on the general frame**: `instance (F : FrameOver D) : TopologicalSpace F.WorldState := nbhdTopology F.TaskRel` — `𝒩_F` needs no axiom, so it belongs to the general structure; `𝒯_F` stays a `def` (`FrameOver.coneTopology`) with no instance, so there is exactly one `TopologicalSpace` on a state space. Then `theorem FrameOver.t1Space_iff_limit : T1Space F.WorldState ↔ Limit F.TaskRel`, and for the constrained class `instance [F.IsRegular] : T1Space F.WorldState`, `instance [F.IsRegular] : R0Space F.WorldState`. History continuity: `theorem WorldHistory.continuous_state (τ : WorldHistory F) [TopologicalSpace ↑D] [OrderTopology ↑D] : Continuous τ.state` — take the order topology on `D` as *binders*, as the probe does, rather than a global `Preorder.topology` instance on `TemporalOrder` carriers, to avoid instance diamonds at `intOrder`/ℚ/ℝ where Mathlib already has topologies.
3. **Name Limit.** `TaskFrame.lean` keeps Limit "deliberately unnamed and used in its literal transcribed shape". The topology results need it as a predicate on the right of an `↔`; define `TaskFrame.Limit R := ∀ w u, (∀ x, 0 < x → ∃ y, |y| < x ∧ R w y u) → u = w` (definitionally the literal shape, so `FrameOver.limit : Limit TaskRel` by citation, exactly like `serial`/`saturation`) and update the docstrings that record the deliberate non-naming.
4. **Counterexamples module** (`FormalSystem/Semantics/StateTopology/Counterexamples.lean` or under `Tests/BimodalTest/`): `R4` with its eleven verified facts; `RTO` (two origins) with Seriality, Compositionality, Limit, T1, not-T2 — and Saturation, which the refactor should prove (the shadow argument of 3.3; the general lemma "a `⊇`-directed family of nonempty sets whose images under a map into a compact Hausdorff space are closed and whose fibres over the accumulation point are controlled …" is the reusable content). Also `IntPartition.lean`'s four theorems, which make the ℤ layer's "Limit = injectivity at zero" (`eq_of_taskRel_zero`) a topological statement.
5. **Existing statements that change.** No theorem statement changes. Docstrings that must change: `TaskFrame.lean`'s module header ("the live tree has no `TopologicalSpace` instance" is implied by the R3 note) and `exists_uniform_radius_of_finite`'s "Status" paragraph ("This is the deliberate substitute for the paper's cone-topology T1 result … no topology exists anywhere in this library") — the substitute becomes a corollary; `ShiftSet.lean`'s `sep` docstring can cite 1.6 for the one-directionality of `rev_sep`. The named example frames in the tree (`staticFrame`, `trivialFrame`, `natFrame`, the translation frame) should each get a one-line topology fact (`staticFrame`: discrete; translation: order topology via `cone_translationRel`).
6. **What is not library-grade yet**: the hedgehog (2.3, 2.4, 3.4) and the two-origin frame's Saturation are paper arguments; the `𝒩_F = final topology` question is open; the ℚ analogue of 3.3 is open.

### 6. Q6 — Naming collision check for "regular"

- **Manuscript**: `grep -n -i regular possible_worlds.tex` returns exactly two hits, both the word *irregular* inside the defined term "\textit{irregular worlds}--- functions $\tau : X \to W$ where $X \subsetneq D$ is a \textit{coset domain}" (`:1431`) and "These considerations recommend possible over irregular worlds" (`:1434`). "regular" as a standalone word: zero occurrences. **Risk**: a reader who has just met "irregular worlds" may read "regular task frame" as a frame whose worlds are the non-irregular ones. The nouns differ (frame vs world) and the two terms are two thousand lines apart, so this is low; a one-clause footnote at the first use of "regular task frame" ("not to be confused with the irregular worlds of §…") closes it.
- **Lean tree**: `grep -rn -i regular FormalSystem Tests` returns one hit, a comment "Convert to regular equality using LawfulBEq" (`FormalSystem/Metalogic/Decidability/Closure.lean:377`) — not a technical term. Mathlib has `IsRegular` (cancellable monoid elements) and `RegularSpace` (T3); both are namespaced away from `FrameOver.IsRegular` and neither is imported by the semantics layer today.
- **Lemmon's regular logics** (recalled, not held: Lemmon 1957; Chellas 1980 ch. 8): a *regular* modal logic is closed under `(A → B) / (□A → □B)` and contains `□(A ∧ B) ↔ □A ∧ □B` but not necessarily `□⊤` — non-normal, with neighbourhood rather than relational semantics. One sentence: because regular logics have no relational frames at all, "regular task frame" cannot be mistaken for "frame for a regular logic" by anyone who knows the term, and the paper's operators are normal in any case, so the precedent creates no confusion in the paper's neighbourhood beyond what a footnote settles.
- **The nearer risk is topological regularity (T3).** This appendix now speaks of T1 and R0; "regular" is the standard name of the next separation axiom, and a reader will wonder whether "regular task frame" means "task frame whose state topology is regular". It does not (the two-origin frame is regular in the decided sense and its `𝒩_F` is not even Hausdorff). Mitigation: the paper never uses "regular" for a separation axiom (it currently does not), and the disclaiming footnote names both readings.
- **Proposed Lean identifier scheme**: the general structure keeps its bare name, `FrameOver D` (fields `WorldState`, `worldNonempty`, `PosRel`; `TaskRel` derived), and the constrained class is `class FrameOver.IsRegular (F : FrameOver D) : Prop` with fields `comp`, `serial`, `limit`, `saturation` (each by citation of the bare-relation predicates, `limit : Limit F.TaskRel` once Limit is named), plus `TaskFrame.IsRegular G := G.toFibre.IsRegular`. Reasons: (i) Mathlib's convention for a `Prop`-valued predicate on a *term* is `IsFoo` (`Ideal.IsPrime`, `IsUnit`), usable as an instance binder `[F.IsRegular]` so downstream theorems read `(F : FrameOver D) [F.IsRegular]` with the axioms available as `F.comp` etc. through the class; (ii) unbundled keeps `TaskFrame = Σ D, FrameOver D` and the ℤ layer's `FrameOver intOrder` untouched, and lets the correspondence theorems range over "all frames over `D`" and "all regular frames over `D`" as two quantifiers over one type; (iii) `Regular` alone reads as a type-level adjective (`T1Space`-style) and is wrong for a term; `RegularFrameOver D extends FrameOver D` (bundled, like `FiniteFrameOver`) is acceptable as a *secondary* alias for construction sites that want to discharge the four axioms in one `where` block, defined as the subtype or as a structure with a `toFrameOver` projection and an `instance : (R.toFrameOver).IsRegular`. Do not use `IsRegular` bare at top level (shadows Mathlib's).

### 7. Results table

Class: the four-axiom ("regular") class unless a cell says otherwise; "ℤ", "ℚ", "ℝ" are the temporal order. Evidence names are declarations in the probes; UNVERIFIED marks a paper argument in this report.

| Property | `𝒩_F` over ℤ | `𝒩_F` over ℚ / ℝ | `𝒯_F` over ℤ | `𝒯_F` over ℚ / ℝ |
|---|---|---|---|---|
| T1 | holds; ⟺ Limit ⟺ `⇒_0 = id` — `t1Space_nbhdTopology_iff_limit`, `limit_int_iff` | holds; ⟺ Limit, no other hypothesis — `t1Space_nbhdTopology_iff_limit` | holds — `coneTopology_eq_nbhdTopology_int` | holds (Limit + nullity) — `t1Space_coneTopology_of_limit` |
| R0 | holds — `r0Space_nbhdTopology_of_limit`; without Limit: holds (partition) — `nbhdTopology_isOpen_iff_int` | holds — `r0Space_nbhdTopology_of_limit`; without Limit: **fails** in general — UNVERIFIED (3.4) | holds — `r0Space_coneTopology_of_limit` | holds — `r0Space_coneTopology_of_limit` |
| Hausdorff | holds (discrete) — `discreteTopology_nbhdTopology_int_iff` | **fails** in general over ℝ — `not_t2Space_nbhdTopology_RTO` (Saturation UNVERIFIED); holds for metric/𝔉¹/𝔉° — `t2Space_nbhd_metric`; over ℚ: open | holds (discrete) | fails over ℝ on the two-origin frame since `𝒯_F = 𝒩_F` there — UNVERIFIED; holds for metric/𝔉¹/𝔉° — `coneTopology_metric` |
| Discrete | holds ⟺ Limit — `discreteTopology_nbhdTopology_int_iff` | fails on metric/𝔉¹/𝔉° — `not_discrete_nbhd_metric`; holds for static frames; ⟺ pointwise dwell time — UNVERIFIED (3.5) | holds ⟺ Limit — via `coneTopology_eq_nbhdTopology_int` | fails on metric/𝔉¹/𝔉° — `coneTopology_metric`, `not_discreteTopology_real` |
| History continuity (order topology on D) | holds, trivially (D discrete) — `continuous_nbhdTopology_of_history` | holds, no axiom used — `continuous_nbhdTopology_of_history` | holds (D discrete) | **fails** in general — UNVERIFIED (hedgehog: `{w}` is `𝒯_F`-open, the history "w until c, then out a spoke" has preimage `(−∞, c]`) |
| Final topology of all histories | `𝒩_F ⊆` final always — `finalTopology_le_nbhdTopology`; equal ⟺ Limit (final is discrete) | `𝒩_F ⊆` final — `finalTopology_le_nbhdTopology`; equality fails in general — UNVERIFIED (hedgehog); equal on metric frame — UNVERIFIED | incomparable in general: on ℤ without Limit final ⊋ `𝒯_F` — UNVERIFIED | incomparable in general: funnel has `𝒯_F` discrete, final indiscrete — UNVERIFIED |
| Cones open | holds (given `⇒_0` an equivalence) — `coneTopology_eq_nbhdTopology_int` | **fails** in general — `not_isOpen_cone_R4` (funnel), hedgehog inside the regular class UNVERIFIED; holds under `Triangle` — `isOpen_cone_of_triangle`; holds on metric/𝔉¹/𝔉° — `cone_*Rel` | holds by definition | holds by definition |
| Converse of T1 (T1 ⟹ Limit) | holds — `t1Space_nbhdTopology_iff_limit` | holds — `t1Space_nbhdTopology_iff_limit` | holds (`𝒯_F = 𝒩_F`) | **fails** — `discreteTopology_coneTopology_R4` + `R4_not_limit`; recovered under `NoOneWay` — `limit_of_t1Space_coneTopology` |
| `𝒯_F` vs `𝒩_F` | equal — `coneTopology_eq_nbhdTopology_int` | `𝒯_F` finer always — `coneTopology_le_nbhdTopology`; strictly on the funnel — `nbhdTopology_R4_eq_top` + `discreteTopology_coneTopology_R4`; equal ⟺ cones open — `coneTopology_eq_nbhdTopology_iff` | | |

## Decisions

- Stated every result over a bare relation with the library's `cone` and the library's literal Limit shape, so the refactor lifts them by substitution rather than restatement.
- Kept each probe standalone (the three small files restate `nbhdTopology'`/`coneTopology'` verbatim) because `specs/` is not a Lake module; the refactor should have one copy.
- Treated the paper's reflection convention as an explicit hypothesis where consumed (`R4_reflection`, `driftRel_reflection`, `hrefl` in `limit_of_t1Space_coneTopology`, `coneTopology_eq_nbhdTopology_int`), and recorded where it is *not* consumed (`app:topology-t1`).
- Did not attempt Saturation for the two-origin or hedgehog frames in Lean; the shadow argument is written out so the refactor can formalize it once, generally.
- Recommended (a) over (b): a second topology in the paper would exist only to have a theorem that a footnote can carry.

## Risks & Mitigations

- **The biconditional's class.** Stating `app:topology-t1` as "Limit iff T1" requires quantifying over structures that satisfy Seriality but not necessarily Limit, which the manuscript's "task frame" vocabulary does not name. Mitigation: the draft says "Let $\F$ satisfy \textit{Seriality}"; once the refactor's "general task frame / regular task frame" distinction lands in the paper, it becomes "Let $\F$ be a task frame satisfying \textit{Seriality}".
- **`lem:nullity` presupposes Limit.** The (⇐) draft re-proves it inline; alternatively generalize `lem:nullity` (the Lean `nullity_of_serial_limit` already has the general shape).
- **Instance diamonds** if the refactor puts a global order topology on `TemporalOrder` carriers. Mitigation: binders, as in the probe.
- **Saturation for the two-origin frame** is unverified; if it failed, the "T1-not-Hausdorff inside the regular class" claim would drop to "inside the Seriality+Compositionality+Limit class". The shadow argument is elementary and I see no gap, but the refactor should close it.
- **The `Fin 4` `decide` calls** in `FourState.lean` are cheap (16–64 cases) but would not scale to larger finite witnesses; that is fine for a counterexample module.

## Tactic Survey Results

| Goal | Tactic | Result | Premises/Config |
|---|---|---|---|
| `R4_compositional` residual `∀ w v : Fin 4, (…) ↔ ∃ u, (…) ∧ (…)` after sign case-split and `simp only [R4_pos …]` | `decide` | success | `Fintype.decidableExistsFintype`, `Fin` decidable eq |
| `singleton_eq_biInter_cone_R4` after `simp only [mem_iInter, mem_cone_R4 hx]` | `decide` | success | `revert u w` first |
| `nbhdTopology_R4_eq_top` chase from any point to all four | `decide +revert` on `Set` membership | fail (membership in an arbitrary `Set (Fin 4)` is not decidable) | replaced by explicit `step` lemma + `match u with` |
| Sign/abs arithmetic in `limit_of_t1Space_coneTopology` (general ordered group) | `linarith` | not applicable (no ordered field) | `lt_sub_iff_add_lt'`, `sub_lt_iff_lt_add`, `neg_lt_iff_pos_add`, `abs_of_nonneg/neg` |
| Same over ℝ (`RealFrames`, `TwoOrigins`) | `linarith` | success | after `abs_of_nonneg`/`abs_of_neg` rewrites and `show … from` to expose `RTO` matches |
| `IsOpen[generateFrom g] {u}ᶜ → …` structural | `induction` on `GenerateOpen` | success | four constructors `basic/univ/inter/sUnion` |
| `T1Space → R0Space`, `DiscreteTopology → T1Space` | `infer_instance` | success | Mathlib instances |
| `t1Space_coneTopology_of_limit` | `t1Space_antitone` | success | T1 is antitone in the topology |

## Context Extension Recommendations

- **Topic**: State-space topology for task frames.
- **Gap**: `.claude/context/project/lean4/` has no note on `TopologicalSpace`-valued definitions in this repository (instance placement on `F.WorldState`, `IsOpen[t]` notation, `letI` discipline, `TopologicalSpace.ext` + `funext` + `propext` for topology equality, `t1Space_antitone`, `mkOfNhds`).
- **Recommendation**: after the refactor lands, add `context/project/lean4/patterns/state-topology.md` distilled from `NbhdTopology.lean`'s header and the idioms above.

## Appendix

- Search queries: `lean_local_search` for `t1Space_antitone`, `R0Space`, `saturation_of_finite`; `lean_run_code` `#check` batches for the Mathlib names listed under Sources (all resolved on the pinned Mathlib; `abs_add` is now `abs_add_le`, `Real.ball_eq_Ioo` and `Fin.val_lt_two_iff` do not exist and were not needed; `Mathlib.Topology.Instances.Real.Defs` is not present in the pinned build, `Mathlib.Topology.MetricSpace.Basic` suffices for ℝ).
- Manuscript greps: `def:task-topology` (`:2881`), `app:topology-t1` (`:2896`), `app:topology-r0` (`:2914`), `def:world-history` (`:2926`), `app:dense` (`:3369`), `app:drift` (`:3720`), translation frame `𝔉¹` (`:3760`), `regular` (two hits, both "irregular worlds"), `clock` (no hits — the task's "clock frames" do not occur in the manuscript; the translation frame `𝔉¹` was taken as intended).
- Compile commands: `lake env lean specs/655_…/probes/<File>.lean` for each of the five files; all exit 0 with no errors; `grep -n sorry` over the probes matches only the word in a docstring.
- Tree state at start and end: `git status` showed only the pre-existing `specs/TODO.md`, `specs/events.jsonl`, `specs/state.json` modifications and the three untracked task directories (651, 653, 655); no foreign commits or builds observed.
