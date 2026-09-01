# Research: Assemble Compactness and Collect Strong Completeness for Base and Dense

**Task type**: lean4
**Scope**: Steps S4 (model existence -> compactness) and S5 (strong completeness) of the
authorized route.

## Headline finding

**The entire mathematical content of this task is already verified.** A 45-line probe
compiled against the built library with `lake env lean`, exit 0, and reports for all six
target declarations:

```
'FormalSystem.Metalogic.modelExistenceBase' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.modelExistenceDense' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.compactBase' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.compactDense' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.strongCompletenessBase' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.strongCompletenessDense' depends on axioms: [propext, Classical.choice, Quot.sound]
```

`sorryAx` absent from all six. This is the task's stated acceptance criterion, met at research
time. The remaining work is **placement, prose correction across ~35 now-false status claims,
and gate wiring** — not proof search.

The verified probe source is reproduced verbatim in the appendix. It was compiled as a single
file importing `FormalSystem.Metalogic.StrongCompleteness` plus the two ultraproduct modules.

---

## 1. What the ultraproduct layer actually delivers

Task 492 landed four modules under `FormalSystem/Semantics/Ultraproduct/`, all sorry-free.
The four declarations this task consumes:

| Declaration | Location | Type |
|---|---|---|
| `Idx (Γ : Set α)` | `IndexFilter.lean:54` | `{L : List α // ∀ ψ ∈ L, ψ ∈ Γ}` — abbrev, so `Idx Γ : Type` for `Γ : Set Formula` |
| `idxUF (Γ : Set α)` | `IndexFilter.lean:85` | `Ultrafilter (Idx Γ)` |
| `eventually_mem` | `IndexFilter.lean:89` | `ψ ∈ Γ → ∀ᶠ L in (idxUF Γ : Filter _), ψ ∈ L.val` |
| `uShiftSet φ S` | `ShiftSetProduct.lean:123` | `(∀ i, ShiftSet (T i)) → ShiftSet (UT φ T)`, **no hypotheses** |
| `los_truthAt` | `Los.lean:154` | `TruthAt (uShiftSet φ S).model ((uShiftSet φ S).hist (omk f)) (mk x) χ ↔ ∀ᶠ i in φ, TruthAt (S i).model ((S i).hist (f i)) (x i) χ` |

Two supporting facts from `FormalSystem/Semantics/ShiftSet.lean` complete the circuit, and are
the reason no new semantic work is needed:

- `ShiftSet.ofModel (F) (M) : ShiftSet F.Duration` (`:360`) — every task model induces a shift
  set, carrier `F.HF` (total histories), valuation read at time `0`.
- `ShiftSet.reverse_repr` (`:377`) — `ShiftTruth (ofModel F M) τ t φ ↔ TruthAt M τ.val t φ`.
- `ShiftSet.forward_repr` (`:278`) — `TruthAt S.model (S.hist w) t φ ↔ ShiftTruth S w t φ`.

Composing `forward_repr` with `reverse_repr` transports per-index truth in an *arbitrary*
`(F i, M i, τ i, t i)` witness into the orbit-history form `los_truthAt` speaks about. That
composition is the only non-obvious step, and it needs no new lemma.

### Type-level facts that make the assembly go through

Each was checked, not assumed:

- `TemporalOrder.carrier : Type` (`TemporalOrder.lean:78`) and `Idx Γ : Type`, so the
  `variable {I : Type}` binders in `Carrier.lean` accept the index type without universe
  surgery. `TaskFrame` is `Type 1`; the existentials in `SatisfiableBaseSet` range over it,
  which `Exists` handles.
- `(FrameOver.toTaskFrame F).Duration = D` by `rfl` (`TaskFrame.lean:1803`), and
  `ShiftSet.frame` is `@[reducible]`, so `(uShiftSet φ S).frame.Duration` **is** `UT φ T` and
  `mk x : ↑(UT φ T)` type-checks directly as the required `t : F.Duration`.
- `UT` is `@[reducible]` (`ShiftSetProduct.lean:79`), so `↑(UT φ T)` reduces to
  `UD φ (fun i => ↑(T i))` at instance-synthesis transparency. This is what lets the Dense
  branch find `Carrier.lean:182`'s `instance [∀ i, DenselyOrdered (D i)] : DenselyOrdered (UD φ D)`.
- `ShiftSet.ofModel` is a plain `def`, but `(S i).Carrier` reduces to `(F i).HF` at default
  transparency, so `(⟨τ i, hτ i⟩ : (F i).HF)` is accepted where a carrier element is wanted.
  The probe writes the ascription explicitly; that ascription is load-bearing for elaboration
  order and should be kept.

---

## 2. The two proofs (verified)

### `modelExistenceBase`

Shape: `choose` per-index witnesses out of the finite-satisfiability hypothesis at index type
`Idx Γ`; form the pointwise shift set; take the ultraproduct at `idxUF Γ`; read off truth via
`los_truthAt` and `eventually_mem`.

```lean
theorem modelExistenceBase : ModelExistenceBase := by
  classical
  intro Γ hfin
  choose F M τ hτ t ht using fun (i : Idx Γ) => hfin i.val i.property
  refine ⟨(uShiftSet (idxUF Γ) (fun i => ShiftSet.ofModel (F i) (M i))).frame,
    (uShiftSet (idxUF Γ) (fun i => ShiftSet.ofModel (F i) (M i))).model,
    (uShiftSet (idxUF Γ) (fun i => ShiftSet.ofModel (F i) (M i))).hist
      (omk (fun i => (⟨τ i, hτ i⟩ : (F i).HF))),
    ShiftSet.hist_isTotal _ _, Ultraproduct.mk (fun i => t i), ?_⟩
  intro ψ hψ
  refine (los_truthAt (fun i => ShiftSet.ofModel (F i) (M i)) _ _ ψ).mpr ?_
  refine (eventually_mem Γ hψ).mono ?_
  intro i hi
  exact (ShiftSet.forward_repr _ _ _ ψ).mpr
    ((ShiftSet.reverse_repr (F i) (M i) ⟨τ i, hτ i⟩ (t i) ψ).mpr (ht i ψ hi))
```

Notes:
- `Ultraproduct.mk` must be qualified — bare `mk` is ambiguous under the open namespaces.
- The ultrafilter argument of `los_truthAt` is implicit and is fixed by unification against the
  goal, so `(idxUF Γ)` need not be named at the `los_truthAt` call site.
- `ht i ψ hi` type-checks because membership in `{ψ | ψ ∈ i.val}` is definitionally
  `ψ ∈ i.val`.

### `modelExistenceDense`

Identical modulo two lines. `SatisfiableDenseSet` (`SetConsequence.lean:270`) carries an extra
anonymous binder `(_ : DenselyOrdered F.Duration)`, so `choose` takes one more name and the
ultraproduct's density instance is supplied by `inferInstance` under a `haveI`:

```lean
  choose F hd M τ hτ t ht using fun (i : Idx Γ) => hfin i.val i.property
  haveI : ∀ i, DenselyOrdered ((F i).Duration : Type) := hd
  refine ⟨…frame, inferInstance, …model, …hist …, ShiftSet.hist_isTotal _ _, Ultraproduct.mk …, ?_⟩
```

The `haveI` here is **safe**, unlike the pattern `SetConsequence.lean:311`'s docstring warns
against for the Discrete binders: it installs a *new* family of instances on the per-index
durations for synthesis at the ultraproduct, and does not attempt to re-install an instance
already baked into a frame's type. Verified by compilation.

### The capstone (verified)

```lean
theorem compactBase : CompactBase := compactBase_of_modelExistence modelExistenceBase
theorem compactDense : CompactDense := compactDense_of_modelExistenceDense modelExistenceDense

theorem strongCompletenessBase : StrongCompletenessBase :=
  strongCompletenessBase_of_compact compactBase completeness_base

theorem strongCompletenessDense : StrongCompletenessDense :=
  strongCompletenessDense_of_compact compactDense completeness_dense
```

**Engine discharge, corrected against the task description.** The task names
`BXCanonical.completeness` (`BXCanonical/Completeness.lean:196`) and
`BXCanonical.completeness_dense` (`:256`). Those work, but the *in-module* names
`completeness_base` (`StrongCompleteness.lean:677`) and `completeness_dense` (`:783`) have
exactly the same types, are defined in the same namespace as the reductions, and are what the
probe used. Either is correct; the in-module names avoid a namespace reach and were the ones
measured.

Note also that the line numbers in the task description have drifted by ~7: the reductions are
at `StrongCompleteness.lean:312` and `:338`, not `:305`/`:331`.

**"Discharge their engine hypotheses" means supply arguments, not delete parameters.** The two
`*_of_compact` reductions must keep their `engine` parameters. Task 509 (`Parameterize
compactness and strong completeness family`) is sequenced immediately behind this task and
plans to collapse both reductions into one `FrameClass`-indexed
`strongCompleteness_of_compact (fc)`; removing the parameter now would break that plan and
would lose the reduction's own statement, which is independently worth having.

---

## 3. Recommended placement

### Primary recommendation: one new module

Create **`FormalSystem/Metalogic/Compactness.lean`**, holding all six theorems, with imports:

```lean
import FormalSystem.Metalogic.StrongCompleteness
import FormalSystem.Semantics.Ultraproduct.Los
import FormalSystem.Semantics.Ultraproduct.IndexFilter
```

and add `import FormalSystem.Metalogic.Compactness` to `FormalSystem/Metalogic.lean` (after
line 10, alongside `DiscreteNonCompactness`).

Why this shape:

1. **It is the literally verified artifact.** The probe is this module, minus a copyright
   header and module docstring. Nothing about the ordering, imports, or elaboration is
   speculative.
2. **`Los.lean` does not transitively import `IndexFilter.lean`** — Task 492's summary records
   this deviation explicitly. Both imports are required.
3. **No import cycle.** `Ultraproduct/{Carrier,IndexFilter,ShiftSetProduct,Los}.lean` import
   only `Mathlib` and `FormalSystem.Semantics.{TemporalOrder,ShiftSet}`; nothing under
   `FormalSystem/Metalogic/` is reachable from them. Checked by reading every import line in
   the chain.
4. **It keeps the ultraproduct dependency out of `StrongCompleteness.lean`**, a 924-line module
   that task 509 will restate wholesale.
5. **`scripts/module-invariants-manifest.txt` needs no entry.** That file lists modules
   *unreachable* from the aggregator (C6 rot guard); a module imported by `Metalogic.lean` is
   reachable and must not be listed.
6. **C8 (aggregator convention) is satisfied**: a bare `Compactness.lean` with no sibling
   `Compactness/` directory is exactly the shape `SetConsequence.lean` and
   `DiscreteNonCompactness.lean` already have.

### Alternative: split model existence from the capstone

`FormalSystem/Metalogic/ModelExistence.lean` (the two model-existence theorems) plus the four
capstone theorems appended to the **end** of `StrongCompleteness.lean`, with
`import FormalSystem.Metalogic.ModelExistence` added there.

This co-locates `strongCompletenessBase` with `strongCompletenessBase_of_compact`, which task
509 may find convenient. Declaration order forces the capstone to sit after `completeness_base`
(`:677`) and `completeness_dense` (`:783`) — i.e. at the very end of the file, before
`end FormalSystem.Metalogic`. This variant was **not** compiled; only the single-module form
was. Nothing about it is mathematically different, but it is one more moving part.

Either way, `StrongCompleteness.lean` is edited for prose (Section 4), so "does not touch
`StrongCompleteness.lean`" is not a real advantage of the primary recommendation.

---

## 4. The status-claim surface: ~35 now-false prose sites

This is the bulk of the actual work. The tree asserts, in many places and in strong terms,
that `CompactBase` / `CompactDense` / `ModelExistenceBase` / `ModelExistenceDense` /
`StrongCompletenessBase` / `StrongCompletenessDense` are **open obligations, neither proved
nor refuted**. Every one of those statements becomes false. Several are load-bearing for other
documents' three-way status taxonomy (Discrete refuted / Base+Dense open / Dedekind
unavailable), which collapses to a two-way one.

### In-tree Lean docstrings (must change — these are what future readers trust)

| File | Lines |
|---|---|
| `FormalSystem/Metalogic/SetConsequence.lean` | `:191`, `:200`, `:215`, `:237`, `:246`, `:281`, `:290`, plus the section header block at `:180`-`:205` |
| `FormalSystem/Metalogic/StrongCompleteness.lean` | `:84`, `:135`, `:294` (the long "Status of `CompactBase`" block at `:294`-`:308`), `:335`, `:370`, `:418`, `:645`, `:689`, `:691`, `:746`-`:747`, `:805`, `:904`, `:909` |
| `FormalSystem/Metalogic.lean` | `:106` (the three-status bullet list), `:156`, `:159`, `:164`-`:165` |

Two of these deserve care rather than a find-and-replace:

- **`StrongCompleteness.lean:294`-`:308`** contains a substantive and still-correct argument
  about *why* the `BXCanonical` chronicle machinery structurally cannot reach `CompactBase`
  (the `deferralClosure`/`subformulaClosure` `Finset` obstruction). That reasoning explains why
  the ultraproduct route exists and should be **kept**, reframed from "why this is still open"
  to "why the route is what it is". Do not delete it.
- **`Metalogic.lean:106`** and **`StrongCompleteness.lean:84`** state a three-way status
  taxonomy that other files cross-reference verbatim. After this task it is two-way: Discrete
  **refuted**, Base and Dense **proved**, Dedekind **unavailable on its primary source's own
  terms**. Update all mirrors together or the tree becomes internally inconsistent.

### Documentation (must change)

| File | Lines | What it says |
|---|---|---|
| `README.md` | `:165` | "**Base** and **Dense** — **open**. Neither proved nor refuted" |
| `docs/project-info/known-limitations.md` | `:37`, `:78` | table row listing Base/Dense as **Open**; prose naming `CompactBase`/`CompactDense` as remaining work |
| `docs/project-info/implementation-status.md` | `:68` | "`CompactBase`/`CompactDense` named as open obligations" |
| `docs/user-guide/architecture.md` | `:824`-`:827`, `:1090` | declaration table marking both as "an **open obligation**"; module tree comment |
| `docs/reference/API_REFERENCE.md` | `:704`-`:707` | same table, "(**open**)" |
| `docs/development/MODULE_ORGANIZATION.md` | `:297` | "name the two open obligations" |
| `FormalSystem/Metalogic/README.md` | `:142`-`:144` | module table; needs a `Compactness.lean` row and a corrected `StrongCompleteness.lean` line count |
| `FormalSystem/Semantics/README.md` | — | already has the `Ultraproduct/` row from task 492; no change needed |

Note the declaration-table line numbers in `architecture.md:824`-`827` and
`API_REFERENCE.md:704`-`707` cite `SetConsequence.lean:211/219/256/263`; the current values are
`:209/:217/:255/:262`. Those citations are already stale by 1-2 lines and should be re-derived
rather than copied.

### Paper-side (this is the task's stated external payoff)

- **`specs/paper-definitions-of-record.md:110`** — the `cor:tm-completeness` row records the
  mismatch as **"Yes, twice"**, item (ii) being that the paper attributes strong completeness
  for TM⁺ / TM⁺_d to this repository "where both are **conditional** on the unproved
  `CompactBase` / `CompactDense`". After this task, item (ii) is resolved and only item (i)
  (the TM⁺_c / `FrameClass.Dedekind` mismatch) remains live. Edit the row, do not delete it.
- **The author memo** is
  `specs/archive/488_align_lean_code_and_docs_with_possible_worlds_paper/reports/02_author-memo.md`.
  The items to retire are **D1** (`:29`, "TM⁺ strong completeness is attributed to a Lean
  result that is conditional") and **D2** (`:75`, "TM⁺_d strong completeness — same defect").
  The memo's verification table at `:434`-`:435` records `Metalogic.CompactBase` and
  `Metalogic.CompactDense` as "`Prop` def, undischarged", and `:450` records "**Confirmed
  absent**: any declaration inhabiting `CompactBase` or `CompactDense`". Both become false.

  **Recommendation on how to retire**: the memo is an archived, dated deliverable of a completed
  task. Do not rewrite its body as though the defect never existed. Add a dated retirement note
  at the top of D1 and D2 (and a one-line correction under the `:434`/`:450` rows) naming the
  discharging declarations, and make the *live* record — `specs/paper-definitions-of-record.md`
  — carry the current truth. This preserves provenance, which is what that file is for.
- **`typst/FormalFoundations.typ:1454`** — the Representation-theorem proof sketch says the
  model-existence step is "each instance of `StrongCompletenessBase`, `CompactBase`, and
  `ModelExistenceBase`", with `#leansrc` pointers at `:1484`-`:1486` to `Metalogic.SetConsequence`.
  Those three declarations are still *defined* there, so the `#leansrc` anchors remain valid, but
  the prose's implicit "these are statements we would need" reading is now understated — they are
  theorems. Worth a sentence; `scripts/typst-sync-check.sh` and `typst-status-counts.sh` should be
  re-run.

### Explicitly out of scope

`specs/reviews/review-2026-08-25.md`, `review-2026-08-25-programme-status.md`, and
`review-2026-08-31-metalogic-systematicity.md` are **dated snapshots**. They correctly describe
the tree as of their dates and must not be retro-edited. Same for
`specs/492_*/reports/` and `plans/`.

`specs/TODO.md` and `specs/CHANGE_LOG.md` are handled by the normal task lifecycle.

---

## 5. Gate and script wiring

| Gate | Status | Action |
|---|---|---|
| C1 `lake build` | must stay green | run `lake-build-guard.sh` (detached) at the end |
| C2 four-flagship axiom baseline | **unaffected** — names only `BXCanonical.completeness{,_dense,_discrete}` and `Chronicle.countermodel_dense` | none |
| C3 zero structural `sorry` | **unaffected** — nothing added carries a sorry | none |
| C4/C5/C12/C13 path resolution | new module path must resolve in any doc that names it | ensure `FormalSystem/Metalogic/Compactness.lean` is spelled exactly |
| C6 rot guard / `module-invariants-manifest.txt` | new module is reachable via `Metalogic.lean` | **do not add an entry** |
| C8 aggregator convention | satisfied by a bare `Compactness.lean` | none |
| C9 no task-number citations under `FormalSystem/` | applies to the new module's docstring | write no task numbers in the Lean file |
| C14 (i) stale-count scan | scans for `(14\|21\|42\|44) axiom/constructor` and non-zero sorry table rows | none triggered |
| C14 (ii) headline axiom baseline | names `Decidability.sound_of_isValid` and `completeness_dedekind` | **recommend adding** `strongCompletenessBase` and `strongCompletenessDense` to `C14_BASELINE` (and to the scratch file at `scripts/check-module-invariants.sh:775`), which is how "axiom-audited" in the acceptance criterion becomes a standing gate rather than a one-off observation |
| C15 paper-anchor resolution | only if new docstrings cite paper anchors | `cor:tm-completeness` is already a manifest row, so citing it is safe |
| `readme-lint.sh` check 2 | reported, not gated | add the `Compactness.lean` row to `FormalSystem/Metalogic/README.md` anyway |
| `check-evidence-probes.sh` | unrelated (bi-lasso probes only) | none |

---

## 6. Risks, and why each is small

| Risk | Assessment |
|---|---|
| Proof does not compile in its final location | **Very low.** Compiled verbatim against the built library. The only difference in the final form is a header and a docstring. |
| Import cycle | **None.** Every import in the `Ultraproduct` chain was read; nothing reaches `FormalSystem/Metalogic/`. |
| Elaboration slowness | Not measured under a full `lake build`. The probe elaborated in the same wall-clock envelope as a small file; the six theorems are short and the heavy lifting (`los`, `uSep`) is already in built oleans. |
| Universe mismatch on `Idx Γ` | **Resolved.** `Formula : Type`, `Idx Γ : Type`, and `Carrier.lean` binds `{I : Type}`. Compiles. |
| Dense instance synthesis fails | **Resolved.** `haveI` + `inferInstance` verified. |
| Missed status-claim site | **This is the real risk.** The inventory above was built by grepping the six declaration names plus the phrases `open obligation`, `neither proved nor refuted`, `remaining obligation`, `**open**`, `undischarged`. A phrasing outside that set could survive. Re-grep after editing. |
| Task 509 conflict | Mitigated by 509's declared serialization edge; this task lands first by design. Keep the `*_of_compact` reductions parameterized. |

---

## 7. Suggested phase decomposition

1. **Phase 1** — Create `FormalSystem/Metalogic/Compactness.lean` with the six theorems and a
   module docstring; wire into `FormalSystem/Metalogic.lean`. Build green, `#print axioms`
   captured for all six.
2. **Phase 2** — In-tree docstring corrections: `SetConsequence.lean`,
   `StrongCompleteness.lean`, `Metalogic.lean` (the ~23 sites in the table above), preserving
   the `:294` chronicle-obstruction argument. Build green.
3. **Phase 3** — Documentation: `README.md`, `docs/project-info/{known-limitations,
   implementation-status}.md`, `docs/user-guide/architecture.md`,
   `docs/reference/API_REFERENCE.md`, `docs/development/MODULE_ORGANIZATION.md`,
   `FormalSystem/Metalogic/README.md`. Re-derive the stale `SetConsequence.lean` line numbers.
4. **Phase 4** — Paper-side: `specs/paper-definitions-of-record.md:110`, the author-memo D1/D2
   retirement notes, `typst/FormalFoundations.typ:1454`.
5. **Phase 5** — Gate wiring and acceptance: add the two theorems to C14's axiom baseline; run
   `check-module-invariants.sh`, `readme-lint.sh`, `typst-sync-check.sh`; capture the literal
   `lake build` and `#print axioms` output as acceptance evidence.

Phases 2-4 touch disjoint file sets from each other and can be parallelized under territory
contracts if the plan wants that; Phase 1 must precede all of them and Phase 5 must follow.

---

## Appendix: the verified probe, verbatim

Compiled with `lake env lean <path>`, exit 0, no warnings.

```lean
import FormalSystem.Semantics.Ultraproduct.Los
import FormalSystem.Semantics.Ultraproduct.IndexFilter
import FormalSystem.Metalogic.StrongCompleteness

open Filter FormalSystem.Syntax FormalSystem.Semantics
open FormalSystem.Semantics.Ultraproduct

namespace FormalSystem.Metalogic

theorem modelExistenceBase : ModelExistenceBase := by
  classical
  intro Γ hfin
  choose F M τ hτ t ht using fun (i : Idx Γ) => hfin i.val i.property
  refine ⟨(uShiftSet (idxUF Γ) (fun i => ShiftSet.ofModel (F i) (M i))).frame,
    (uShiftSet (idxUF Γ) (fun i => ShiftSet.ofModel (F i) (M i))).model,
    (uShiftSet (idxUF Γ) (fun i => ShiftSet.ofModel (F i) (M i))).hist
      (omk (fun i => (⟨τ i, hτ i⟩ : (F i).HF))),
    ShiftSet.hist_isTotal _ _, Ultraproduct.mk (fun i => t i), ?_⟩
  intro ψ hψ
  refine (los_truthAt (fun i => ShiftSet.ofModel (F i) (M i)) _ _ ψ).mpr ?_
  refine (eventually_mem Γ hψ).mono ?_
  intro i hi
  exact (ShiftSet.forward_repr _ _ _ ψ).mpr
    ((ShiftSet.reverse_repr (F i) (M i) ⟨τ i, hτ i⟩ (t i) ψ).mpr (ht i ψ hi))

theorem modelExistenceDense : ModelExistenceDense := by
  classical
  intro Γ hfin
  choose F hd M τ hτ t ht using fun (i : Idx Γ) => hfin i.val i.property
  haveI : ∀ i, DenselyOrdered ((F i).Duration : Type) := hd
  refine ⟨(uShiftSet (idxUF Γ) (fun i => ShiftSet.ofModel (F i) (M i))).frame,
    inferInstance,
    (uShiftSet (idxUF Γ) (fun i => ShiftSet.ofModel (F i) (M i))).model,
    (uShiftSet (idxUF Γ) (fun i => ShiftSet.ofModel (F i) (M i))).hist
      (omk (fun i => (⟨τ i, hτ i⟩ : (F i).HF))),
    ShiftSet.hist_isTotal _ _, Ultraproduct.mk (fun i => t i), ?_⟩
  intro ψ hψ
  refine (los_truthAt (fun i => ShiftSet.ofModel (F i) (M i)) _ _ ψ).mpr ?_
  refine (eventually_mem Γ hψ).mono ?_
  intro i hi
  exact (ShiftSet.forward_repr _ _ _ ψ).mpr
    ((ShiftSet.reverse_repr (F i) (M i) ⟨τ i, hτ i⟩ (t i) ψ).mpr (ht i ψ hi))

theorem compactBase : CompactBase := compactBase_of_modelExistence modelExistenceBase

theorem compactDense : CompactDense := compactDense_of_modelExistenceDense modelExistenceDense

theorem strongCompletenessBase : StrongCompletenessBase :=
  strongCompletenessBase_of_compact compactBase completeness_base

theorem strongCompletenessDense : StrongCompletenessDense :=
  strongCompletenessDense_of_compact compactDense completeness_dense

end FormalSystem.Metalogic
```
