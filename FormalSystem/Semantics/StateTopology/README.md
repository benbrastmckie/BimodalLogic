# Semantics/StateTopology

Frame witnesses for the state-topology development: concrete `FrameOver` values built to show
that something holds, or that something does *not* follow.

Every module here is a **leaf**. Nothing under `FormalSystem/` imports them; the generated
library root reaches them directly. That is deliberate and is recorded in
[`../../../docs/ARCHITECTURE.md`](../../../docs/ARCHITECTURE.md)'s "The state topology is a leaf,
on purpose": `Mathlib.Topology.*` brings order and completeness instances with it, and routing
them through `Semantics.lean` put a `Preorder ℤ` instance diamond into scope for every downstream
module — twice.

## Modules

<!-- BEGIN GENERATED: inventory dir=FormalSystem/Semantics/StateTopology -->
| File | Lines | Description |
|------|------:|-------------|
| `ConstraintWitnesses.lean` | 1,372 | Witnesses whose content is a `def:frame` constraint or a separation property **failing**: the ghost ray (*Serial*, *Compositional*, no *Limit*, `𝒩_F` not R0 — `GhostRay.frame_not_r0Space`) the ℚ-carrier two-origin frame (first three constraints, ***Saturation* fails* — `RationalTwoOrigins.not_rel_saturation`, and *Completion* fails too — `RationalTwoOrigins.not_rel_completion`), and the separating frame (*Serial*, *Compositional*, *Limit* and ***Completion***, ***Saturation* fails* — `SeparatingFrame.srel_completion`, `SeparatingFrame.not_srel_saturation`). |
| `Counterexamples.lean` | 2,056 | Frames satisfying some `def:frame` constraints and not others: the four-state funnel (no *Limit*, `𝒯_F` T1 anyway), and the two **regular task frames** the appendix cites — the two-origin half-line (T1, not Hausdorff) and the hedgehog (`𝒩_F` strictly below the final topology of all histories), both with *Saturation* proved by the shadow argument. |
| `MetricFrame.lean` | 290 | The metric frame (a task of duration `y` moves distance at most `c` times the size of `y` on the carrier `ℝ`), previously only prose: regular at every positive speed, and the frame on which `𝒩_F` **is** the final topology of all histories (`MetricFrame.finalTopology_eq_nbhdTopology`). |
<!-- END GENERATED -->

## What each witness settles

**`Counterexamples.lean`** — frames satisfying some `def:frame` constraints and not others.

- `funnelFrame` — *Serial*, *Compositional*, *Saturated*; **fails *Limit***. `𝒯_F` is T1 on it
  nonetheless, so the converse of `app:topology-t1` is false. Deliberately **not** an
  `FrameOver.IsRegular` instance, and must never be given one.
- `TwoOrigins.frame` — the half-line with two origins. A **regular task frame**: all four
  constraints, *Saturation* included (`TwoOrigins.frame_saturation`). Its state space is T1 and
  **not Hausdorff** (`TwoOrigins.taskFrame_t1_not_t2`), and the two topologies coincide on it
  (`TwoOrigins.frame_coneTop_eq_stateTopology`) although *Triangle* fails
  (`TwoOrigins.not_triangle`).
- `Hedgehog.frame` — a centre with countably many rays. Also a **regular task frame**
  (`Hedgehog.frame_saturation`). It puts `𝒩_F` strictly below the final topology of all histories
  (`Hedgehog.finalTopology_ne_nbhdTopology`) and is where `𝒯_F ≠ 𝒩_F` is named
  (`Hedgehog.coneTopology_lt_nbhdTopology`).

**`ConstraintWitnesses.lean`** — a constraint or a separation property *failing*.

- `GhostRay` — *Serial* and *Compositional*, **fails *Limit***, and its `𝒩_F` is **not R0**
  (`GhostRay.frame_not_r0Space`). So R0 is exactly as fragile as T1, and `app:topology-r0`'s
  derivation from `app:topology-t1` needs no separate frame-level argument.
- `RationalTwoOrigins` — the two-origin relation verbatim over `ℚ`. *Seriality*,
  *Compositionality* and *Limit* survive the move; ***Saturation* does not**
  (`RationalTwoOrigins.not_rel_saturation`). The witness is the family of rational intervals
  straddling the cut `{q : q² < 2} | {q : 2 < q²}`. This is why the real-carrier witness is over
  `ℝ`. It **also** fails *Completion* (`RationalTwoOrigins.not_rel_completion`), so it is not a
  separator for the two conditions — and the pinching argument in its docstring shows no
  dense-time drift frame can be.
- `SeparatingFrame` — unit-speed drift on `ℚ` over `ℤ`-time, `w ⇒ₓ v` iff `|v - w| ≤ |x|`. It
  satisfies *Seriality*, *Compositionality*, *Limit* **and** *Completion*
  (`SeparatingFrame.srel_completion`) while **failing *Saturation***
  (`SeparatingFrame.not_srel_saturation`). So `Completion → Saturation` is **false** and
  *Completion* is a **strict** weakening of *Saturation*. `not_srel_totalComp` is the
  consistency check: the converse does hold under mixed-sign composition plus *Limit*, so a
  separating frame has to refute it.

**`MetricFrame.lean`** — the metric frame, named at last.

- `MetricFrame.rel c r y u ↔ |u - r| ≤ c·|y|` had existed only as prose; the library carried the
  real-carrier *bridges* (`TaskFrame.nbhdTopology_eq_real`), which take the ball shape of the
  cones as a hypothesis rather than as a frame.
- Regular at every positive speed (`MetricFrame.isRegular`), and on it `𝒩_F` **is** the final
  topology of all histories (`MetricFrame.finalTopology_eq_nbhdTopology`). The hedgehog's
  separation of the two is therefore a feature of branching, not of the cone construction.

## Related Documentation

- [Semantics README](../README.md)
- [`../StateTopology.lean`](../StateTopology.lean) — `coneTopology`, `nbhdTopology`,
  `FrameOver.t1Space_iff_limit`, `TaskFrame.finalTopology_eq_of_surjective_open_history`
- [`../TaskFrame.lean`](../TaskFrame.lean) — the four `def:frame` constraints as bare-relation
  predicates, and `TaskFrame.exists_mem_image_of_directedFamily` (the shadow lemma both
  *Saturation* proofs consume)
- [`../../../docs/reference/state-topology-appendix-support.md`](../../../docs/reference/state-topology-appendix-support.md)
  — which appendix claim each witness supports

---

*Last verified: 2026-09-23*
