# State-Topology Appendix Support Table

[Back to Reference Documentation](README.md)

**What this is.** A mapping from each element the manuscript's task-semantics appendix contains —
or will contain, once its topology material is rewritten — to the exact Lean declaration that
certifies it, with that declaration's axiom profile. It also names, explicitly, every statement
the appendix would assert that this library does **not** certify.

**Audience**: whoever is writing or reviewing the topology material of the paper's task-semantics
appendix, and wants to know what may be asserted as proved.

**How rows are keyed.** By paper label (`def:task-topology`, `app:topology-t1`,
`app:topology-r0`) or by a quotable phrase — **never by line number**. The appendix is rewritten
independently of this repository, and a line-keyed table would be stale the moment it was. The
three labels above are recorded `LIVE-UNPINNED` in
[`paper-definitions-of-record.md`](paper-definitions-of-record.md) and resolve under check C15.

**Relation to the ledger.** [`../theorem-index.md`](../theorem-index.md) is the single
per-theorem ledger and remains the authority on any individual declaration's statement, file and
axioms. This page is the *manuscript-facing view* of the same declarations: it is organised by
what the appendix says, not by what the library proves.

## The decision this table serves

The topology material is being rewritten under **option (a)**: the appendix defines the topology
as the cone-**neighbourhood** topology, states T1 as a **biconditional**, keeps the R0 corollary,
adds a history-continuity lemma, and records the old subbasis topology in a footnote. The symbol
`𝒯_F` is reassigned to the neighbourhood topology; the superseded subbasis topology keeps no
symbol of its own in the manuscript.

Because the symbol moved and the Lean names did not, read every row below against this
correspondence, which is also the module header of
[`../../FormalSystem/Semantics/StateTopology.lean`](../../FormalSystem/Semantics/StateTopology.lean):

| Manuscript | Relation level | Frame level |
|---|---|---|
| `𝒯_F` of the revised `def:task-topology` | `TaskFrame.nbhdTopology` | `FrameOver.stateTopology` |
| the footnote's superseded subbasis topology | `TaskFrame.coneTopology` | `FrameOver.coneTop` |

Lean docstrings keep the **pre-revision** reading throughout — `𝒩_F` for the neighbourhood
topology, `𝒯_F` for the subbasis topology — so that the two are never ambiguous inside the
development. This table writes out which topology is meant in every row rather than leaning on
either convention.

## Status vocabulary

| Status | Meaning |
|---|---|
| `certified` | A named declaration exists in the tree today and is sorry-free with standard axioms |
| `pending-sibling` | Blocked on the sibling open-questions work (*Saturation* for the two real witnesses; R0 without *Limit*). **Not** attempted here, by design |
| `not-certified` | No declaration certifies the statement as the appendix would phrase it. Some of these are over-claims the library actively refutes; see "Statements the library does not certify" |

`pcq` abbreviates exactly `[propext, Classical.choice, Quot.sound]`, the profile of every
declaration in this table. Every value below was read off `#print axioms` against the built
modules, not assumed.

## 1. The replacement `def:task-topology`

| Manuscript element | Statement | Certifying declaration | Axiom profile | Status |
|---|---|---|---|---|
| `def:task-topology`, Open Sets clause | `O` is open exactly when every `w ∈ O` has a positive cone `(w)_x ⊆ O` | `FormalSystem.Semantics.TaskFrame.nbhdTopology_isOpen_iff` | `pcq` | `certified` |
| `def:task-topology`, Open Sets clause, at a frame | the same criterion, stated so no consumer unfolds the instance | `FormalSystem.Semantics.FrameOver.isOpen_iff` | `pcq` | `certified` |
| `def:task-topology`, "this is a topology" | the three topology axioms hold with **no** frame constraint assumed — only that a positive radius exists | the three fields of `FormalSystem.Semantics.TaskFrame.nbhdTopology` (`isOpen_univ`, `isOpen_inter`, `isOpen_sUnion`) | `pcq` | `certified` |
| `def:task-topology`, *Closure* clause | the paper's `cl{w} = {w}` reading of *T1* is Mathlib's `T1Space` | `FormalSystem.Semantics.TaskFrame.t1Space_iff_closure_singleton` | `pcq` | `certified` |
| "the cones at a state are a neighbourhood base" | the cones at `w` are a filter base, and `𝒩_F` is the topology they generate as a neighbourhood system | `FormalSystem.Semantics.TaskFrame.isBasis_cone`, `FormalSystem.Semantics.TaskFrame.nbhdTopology_eq_mkOfNhds` | `pcq` | `certified` |
| "it is the canonical such topology" | `𝒩_F` is the **finest** topology in which every neighbourhood of `w` contains a cone at `w` | `FormalSystem.Semantics.TaskFrame.nbhdTopology_le_of_coneFilter_le_nhds` | `pcq` | `certified` |

## 2. `app:topology-t1` as a biconditional

| Manuscript element | Statement | Certifying declaration | Axiom profile | Status |
|---|---|---|---|---|
| `app:topology-t1`, as the appendix drafts it | `⋂_{x>0} (w)_x = {w}` for every `w` **iff** the topology is T1, under *Seriality* alone | `FormalSystem.Semantics.TaskFrame.t1Space_nbhdTopology_iff_iInter_cone_of_serial` | `pcq` | `certified` |
| `app:topology-t1`, the sharper form the library proves | T1 **iff** *Limit* (the `⊆` half), with **no** frame constraint consumed in either direction — not even *Seriality* | `FormalSystem.Semantics.TaskFrame.t1Space_nbhdTopology_iff_limit` | `pcq` | `certified` |
| `app:topology-t1`, at a frame | the same biconditional in the frame register | `FormalSystem.Semantics.FrameOver.t1Space_iff_limit` | `pcq` | `certified` |
| "a regular frame's state space is T1" | the four-constraint class gets T1 as an instance | `FormalSystem.Semantics.FrameOver.instT1SpaceOfRegular` | `pcq` | `certified` |
| the equality form of *Limit* | `⋂_{x>0} (w)_x = {w}` is T1 plus `w ∈ (w)_x`, which is why the Lean `Limit` transcribes only `⊆` | `FormalSystem.Semantics.TaskFrame.limit_eq_iff`, `FormalSystem.Semantics.TaskFrame.mem_cone_self` | `pcq` / `[propext]` | `certified` |
| the equality form at a regular frame | `⋂_{x>0} (w)_x = {w}` outright | `FormalSystem.Semantics.FrameOver.iInter_cone_eq_singleton` | `pcq` | `certified` |

## 3. `app:topology-r0`

| Manuscript element | Statement | Certifying declaration | Axiom profile | Status |
|---|---|---|---|---|
| `app:topology-r0`, for the revised topology | the state topology is R0 under *Limit* | `FormalSystem.Semantics.TaskFrame.r0Space_nbhdTopology_of_limit` | `pcq` | `certified` |
| `app:topology-r0`, at a regular frame | the same, named in the frame register | `FormalSystem.Semantics.FrameOver.r0Space_stateTopology` | `pcq` | `certified` |
| `app:topology-r0`, the paper's closure phrasing | `w ∈ cl{u}` exactly when `u ∈ cl{w}` **is** Mathlib's `R0Space`, via `specializes_iff_mem_closure` | `FormalSystem.Semantics.TaskFrame.r0Space_iff_mem_closure_comm` | `pcq` | `certified` |
| `app:topology-r0`, for the superseded topology | the footnote's topology is R0 too, under *Limit* and nullity | `FormalSystem.Semantics.TaskFrame.r0Space_coneTopology_of_limit`, `FormalSystem.Semantics.FrameOver.r0Space_coneTop` | `pcq` | `certified` |
| "R0 can fail without *Limit*" | a *Seriality* + *Compositionality* structure whose topology is not R0 | — | — | **`pending-sibling`** |

## 4. The new history-continuity lemma

| Manuscript element | Statement | Certifying declaration | Axiom profile | Status |
|---|---|---|---|---|
| "every possible world is a continuous path" | every history is continuous from the order topology on the duration carrier into the state topology, with **no** frame constraint consumed | `FormalSystem.Semantics.TaskFrame.continuous_nbhdTopology_of_history` | `pcq` | `certified` |
| the same at a frame | the order topology on the carrier is an explicit binder, never a global instance | `FormalSystem.Semantics.FrameOver.continuous_of_history` | `pcq` | `certified` |
| "the topology is below the final topology of all histories" | `𝒩_F ≥` the final topology in Mathlib's order — i.e. coarser | `FormalSystem.Semantics.TaskFrame.finalTopology_le_nbhdTopology` | `pcq` | `certified` |
| "**the** topology that makes worlds continuous paths" | — | — | — | **`not-certified`, and refuted as a characterization** — see flag 1 |

## 5. The footnote: the superseded subbasis topology and the four-state funnel

| Manuscript element | Statement | Certifying declaration | Axiom profile | Status |
|---|---|---|---|---|
| "the old topology was generated by the cones as a subbasis" | the definition itself | `FormalSystem.Semantics.TaskFrame.coneTopology`, `FormalSystem.Semantics.FrameOver.coneTop` | `pcq` | `certified` |
| "the old topology is finer" | `coneTopology R ≤ nbhdTopology R` given `w ⇒₀ w`; in Mathlib's order `≤` **is** finer | `FormalSystem.Semantics.TaskFrame.coneTopology_le_nbhdTopology`, `FormalSystem.Semantics.FrameOver.coneTop_le_stateTopology` | `pcq` | `certified` |
| "the old topology is T1 under *Limit* too" | the instance holds | `FormalSystem.Semantics.TaskFrame.t1Space_coneTopology_of_limit`, `FormalSystem.Semantics.FrameOver.t1Space_coneTop` | `pcq` | `certified` |
| "...because T1 is inherited by finer topologies" (the *reason*) | — | no such general lemma is stated in this library; the instance is proved directly from *Limit* and nullity | — | **`not-certified` as stated** — see flag 2 |
| "the old topology's T1 does **not** characterize *Limit*" | on the four-state funnel the subbasis topology is T1 (indeed discrete) **while *Limit* fails** | `FormalSystem.Semantics.StateTopology.funnel_t1Space_coneTopology` with `FormalSystem.Semantics.StateTopology.funnel_not_limit` | `pcq` | `certified` |
| "the funnel is a genuine frame, not a degenerate one" | it satisfies *Seriality*, *Compositionality* and *Saturation* | `FormalSystem.Semantics.StateTopology.funnel_serial`, `...funnel_compositional`, `...funnel_saturation` | `pcq` | `certified` |
| the funnel's cone computation | `(w)_x` is the symmetric funnel relation at every positive `x`; each singleton is a finite intersection of cones | `FormalSystem.Semantics.StateTopology.mem_cone_funnelRel`, `...funnelRel_singleton_eq_biInter_cone` | `pcq` | `certified` |
| "on the funnel the new topology is indiscrete" | the neighbourhood topology is `⊤`, so it is not even T0 there | `FormalSystem.Semantics.StateTopology.funnelRel_nbhdTopology_eq_top`, `...funnel_not_t1Space` | `pcq` | `certified` |
| "the gap is exactly the one-way instantaneous pairs" | subbasis-T1 implies *Limit* under reflection, composition and *NoOneWay*; the funnel carries the one-way pair that shows *NoOneWay* is not free | `FormalSystem.Semantics.TaskFrame.limit_of_t1Space_coneTopology`, `FormalSystem.Semantics.StateTopology.funnel_one_way_pair` | `pcq` | `certified` |

## 6. Further results the collection now makes worth stating

These are certified today and have no manuscript element yet. They are listed because each is the
sharpest available form of a claim the appendix is likely to want.

| Candidate manuscript element | Statement | Certifying declaration | Axiom profile | Status |
|---|---|---|---|---|
| "T1 does not give Hausdorff" | the half-line with two origins is T1 and **not** Hausdorff | `FormalSystem.Semantics.StateTopology.TwoOrigins.frame_t1Space` with `...TwoOrigins.frame_not_t2Space` | `pcq` | `certified` (but see flag 3 for "task frame") |
| "and that is a property of the frame, not of the choice of topology" | on that frame the two topologies **coincide**, and neither is Hausdorff | `FormalSystem.Semantics.StateTopology.TwoOrigins.frame_coneTop_eq_stateTopology`, `...TwoOrigins.frame_not_t2Space_coneTop` | `pcq` | `certified` (see flag 3) |
| "the shortcut condition is sufficient but not necessary" | *Triangle* implies the two topologies agree, yet they agree on the two-origin frame where *Triangle* **fails** | `FormalSystem.Semantics.TaskFrame.coneTopology_eq_nbhdTopology_of_triangle`, `FormalSystem.Semantics.StateTopology.TwoOrigins.not_triangle`, `...TwoOrigins.coneTopology_eq_nbhdTopology` | `pcq` | `certified` |
| "cone-openness is the exact criterion" | the two topologies agree **iff** every cone is open in the neighbourhood topology | `FormalSystem.Semantics.TaskFrame.coneTopology_eq_nbhdTopology_iff` | `pcq` | `certified` |
| "the two topologies really can differ" | on the hedgehog they differ, and the subbasis topology is **strictly** finer | `FormalSystem.Semantics.StateTopology.Hedgehog.coneTopology_ne_nbhdTopology`, `...Hedgehog.coneTopology_lt_nbhdTopology` | `pcq` | `certified` (see flag 3) |
| "the state topology is strictly below the final topology" | the hedgehog separates them | `FormalSystem.Semantics.StateTopology.Hedgehog.finalTopology_ne_nbhdTopology` | `pcq` | `certified` (see flag 3) |
| "over a discrete duration group everything collapses" | over `ℤ` both topologies are the partition topology of `⇒₀`, and *Limit* ⟺ discrete ⟺ T1 | `FormalSystem.Semantics.TaskFrame.cone_int_one`, `...nbhdTopology_isOpen_iff_int`, `...limit_int_iff`, `...discreteTopology_nbhdTopology_int_iff` | `pcq` | `certified` |
| "on the named real frames the topology is the Euclidean one" | when the cones are Euclidean balls, the neighbourhood topology **is** the usual topology on `ℝ`, and the two topologies coincide | `FormalSystem.Semantics.TaskFrame.nbhdTopology_eq_real`, `...coneTopology_eq_nbhdTopology_real` | `pcq` | `certified` |
| "the topology is discrete exactly under a pointwise dwell time" | discreteness is equivalent to every state having a radius that isolates it | `FormalSystem.Semantics.TaskFrame.discreteTopology_nbhdTopology_iff` | `pcq` | `certified` |
| "closed sets are those closed under arbitrarily short tasks" | the closed-set criterion, dual to the open one | `FormalSystem.Semantics.TaskFrame.nbhdTopology_isClosed_iff` | `pcq` | `certified` |

## Statements the library does not certify

This is the section to read before asserting anything as proved.

**1. "`𝒩_F` is *the* topology that makes possible worlds continuous paths" — over-claimed, and the
library refutes the definite article.** What is certified is that every history is continuous
(`continuous_nbhdTopology_of_history`) and that the state topology is *coarser* than the final
topology of all histories (`finalTopology_le_nbhdTopology`). `Hedgehog.finalTopology_ne_nbhdTopology`
shows that containment is **strict** on a structure satisfying *Seriality*, *Compositionality* and
*Limit*, so the state topology is **not** the finest topology making worlds continuous, and no
characterization of it in those terms is available. Safe wordings: "a topology in which every
possible world is a continuous path", or the sharp form that *is* certified — it is the finest
topology in which every neighbourhood of `w` contains a cone at `w`
(`nbhdTopology_le_of_coneFilter_le_nhds`).

**2. "The old topology is T1 for the same reason — T1 is inherited by finer topologies."** The
*instance* is certified (`t1Space_coneTopology_of_limit`), but it is proved directly from *Limit*
and nullity; no "T1 passes to finer topologies" lemma is stated in this library. Either cite the
instance and drop the reason, or state the general lemma first. If the reason is given, it must
use the fineness direction the library proves: `coneTopology ≤ nbhdTopology` in Mathlib's order
**means the subbasis topology is finer**.

**3. Every claim that the two-origin or the hedgehog witness is a *task frame*.**
`pending-sibling`. Neither claims *Saturation* and neither is an `IsRegular` instance — both
docstrings say so deliberately. As the library stands, "there is a **task frame** that is T1 and
not Hausdorff" is **not certified**; what is certified is "there is a structure satisfying
*Seriality*, *Compositionality* and *Limit* that is T1 and not Hausdorff". The same qualification
attaches to every hedgehog row. Closing this is the sibling open-questions task, not this one.

**4. "Without *Limit*, the topology need not be R0."** `pending-sibling`. The witness — the
hedgehog plus a further state related to every tip at every positive duration — was never built
in Lean and was an explicit non-goal of the prior round. The contrasting positive fact (over `ℤ`,
with symmetric `⇒₀`, the partition topology is R0) **is** certified, by the four `*_int*` results.

**5. The paper-versus-Mathlib formulation gap for *R0* and *T1*.** **Closed.** The paper states
both with closures and this development states both with Mathlib's separation classes;
`r0Space_iff_mem_closure_comm` and `t1Space_iff_closure_singleton` make the identification a
checked fact rather than a reader's assumption.

### Two notes that are not defects

- **The drafted `app:topology-t1` is weaker than what Lean proves.** The draft consumes
  *Seriality*; `t1Space_nbhdTopology_iff_limit` consumes nothing at all. *Seriality* is needed
  only to upgrade the `⊆` half of *Limit* to the paper's equality form, by way of `lem:nullity`.
  Stating the weaker form is a presentational choice, not an error — and
  `t1Space_nbhdTopology_iff_iInter_cone_of_serial` certifies the weaker form directly, so the
  appendix need not do the upgrade in prose.
- **"The `def:frame` gloss 'distinct world states are instantaneously separated' becomes literally
  true."** Interpretive rather than mathematical. The nearest certified content is
  `t1Space_nbhdTopology_iff_limit` together with `discreteTopology_nbhdTopology_iff`. No action
  needed beyond not presenting it as a theorem.

## Verifying this page

Every Lean name above resolves in the tree, and every axiom profile is machine-checked:

```bash
bash scripts/check-module-invariants.sh    # C14 axiom pins, C15 the ledger round trip
lake build --wfail                          # the whole library, zero warnings
```

## Related Documentation

- [`../theorem-index.md`](../theorem-index.md) — the single per-theorem ledger
- [`paper-definitions-of-record.md`](paper-definitions-of-record.md) — the pinned paper-anchor manifest
- [`../../FormalSystem/Semantics/StateTopology.lean`](../../FormalSystem/Semantics/StateTopology.lean) — the general-relation and frame-level layers
- [`../../FormalSystem/Semantics/StateTopology/Counterexamples.lean`](../../FormalSystem/Semantics/StateTopology/Counterexamples.lean) — the four witnesses
- [`../../FormalSystem/Semantics/README.md`](../../FormalSystem/Semantics/README.md) — the module tables

## Tags

`topology` · `state-topology` · `def:task-topology` · `app:topology-t1` · `app:topology-r0` · `manuscript-support`
