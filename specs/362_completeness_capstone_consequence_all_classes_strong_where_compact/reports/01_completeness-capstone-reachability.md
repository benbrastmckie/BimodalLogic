# Research: Completeness Capstone — What Is Reachable Today

**Task**: 362 — completeness capstone: consequence completeness for all classes, strong where compact
**Type**: lean4 · **Session**: sess_1787662855_e59fd5_362 · **Dispatch**: 2
**Date**: 2026-08-25
**File scope**: `FormalSystem/Metalogic/StrongCompleteness.lean`, `FormalSystem/Metalogic.lean`
(plus, for leg D, `latex/subfiles/04-Metalogic.tex`; plus, for the reachable slice of leg B,
`FormalSystem/Metalogic/SetConsequence.lean`)

---

## Headline: the delegation context's DEPENDENCY STATUS block is stale, and leg A is fully reachable today

The dispatch brief states that 169 (base weak), 170 (dense weak), 361 (architecture/verdict) and
424 (shift-set Representation Theorem) are "all NOT complete", and instructs that the research
must establish what is reachable given that. The answer, established by machine check rather than
by reading task metadata, is:

| Claimed status | Verified reality | Evidence |
|---|---|---|
| 169 base weak — not complete | **The mathematical content is landed.** `BXCanonical.completeness : valid φ → Derivable FrameClass.Base [] φ` kernel-verifies at exactly `[propext, Classical.choice, Quot.sound]` | `lean_verify` on `FormalSystem.Metalogic.BXCanonical.completeness` |
| 170 dense weak — not complete | **Landed.** `BXCanonical.completeness_dense` at exactly `[propext, Classical.choice, Quot.sound]` | `lean_verify` |
| 375 discrete weak — complete | Confirmed. `BXCanonical.completeness_discrete` at exactly `[propext, Classical.choice, Quot.sound]` | `lean_verify` |
| 361 — not complete | **Completed and archived**, at `specs/archive/361_strong_completeness_architecture_and_weak_terminus_gap_analysis/` | directory listing |
| 424 — not complete | **`[COMPLETED]` in `specs/TODO.md`**, and its **GATE VERDICT is PASSED** | `specs/424_.../summaries/01_shift-set-representation-theorem-summary.md` |

`specs/TODO.md:2240` is the source of the stale block; it is dated "re-verified 2026-08-18" and has
been overtaken by events (424's own entry at `specs/TODO.md:1987` reads `[COMPLETED]`, and
`specs/TODO.md:2021` already records 361 as archived — the same file contradicts itself).

**Consequence for scoping: leg A has zero remaining dependencies.** It does not need 169 or 170 to
land as *tasks*, because the only artifacts it consumes from them — the three single-formula
completeness engines — are already in the tree and already sorry-free.

---

## Leg A — finite-context consequence completeness for Base, Dense, Discrete

### Verdict: fully reachable today. Prototyped end to end, compiled clean on the first attempt, sorry-free.

I wrote the complete leg-A implementation to a scratch file, compiled it against the real build
(`lake env lean`, exit 0), and read the axioms off the resulting kernel environment. All twelve
declarations elaborate with **zero errors and zero `sorry`**, at exactly
`[propext, Classical.choice, Quot.sound]`:

```
'…consequence_completeness_base'     depends on axioms: [propext, Classical.choice, Quot.sound]
'…consequence_completeness_dense'    depends on axioms: [propext, Classical.choice, Quot.sound]
'…consequence_completeness_discrete' depends on axioms: [propext, Classical.choice, Quot.sound]
'…soundness_base_consequence'        depends on axioms: [propext, Classical.choice, Quot.sound]
'…soundness_dense_consequence'       depends on axioms: [propext, Classical.choice, Quot.sound]
'…soundness_discrete_consequence'    depends on axioms: [propext, Classical.choice, Quot.sound]
```

The scratch files were deleted after measurement; `git status` shows no residue under
`FormalSystem/`.

### Three findings that change the plan from the brief's assumption

**(1) Base needs no new consequence relation — `SemanticConsequence` already *is* it.**

The brief says "define `SemanticConsequenceX` … paralleling the `ValidX` binder list", and the
`SemanticConsequenceDedekindDense` docstring warns "Why not `SemanticConsequence`: the general
relation quantifies over *all* carriers, so it cannot express consequence restricted to the
Dedekind class". That warning is correct for Dedekind, Dense and Discrete — and **inapplicable to
Base**, because for Base "all carriers" *is* the class. Compare, verbatim:

- `valid` (`Semantics/Validity.lean:94`): `∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D] (F) (M) (τ) (_ : τ.IsTotal) (t : D), TruthAt M τ t φ`
- `SemanticConsequence` (`Semantics/Validity.lean:125`): the same binder list, with `(∀ ψ ∈ Γ, TruthAt M τ t ψ) →` inserted before the conclusion.

That is precisely the surgery the brief prescribes. `soundness` (`Metalogic/Soundness.lean:1080`)
binds the same list, so it discharges `SemanticConsequence` directly.

**Recommendation**: do *not* introduce a `SemanticConsequenceBase` synonym. Reuse
`SemanticConsequence`, and put the reason in the Base section header — a gratuitous defeq
duplicate of a definition that already carries the `Γ ⊨ φ` notation (`Validity.lean:135`) would be
a maintenance liability, and the existing `SetSemanticConsequenceBase` in `SetConsequence.lean` is
*not* a precedent for it (there is no set-level general relation for it to have reused).

The Base section then has **four** declarations, not the Dedekind section's six: the semantic
deduction lemma, the consequence terminus, the soundness guard, and the weak corollary. There is
no `_of_engine` layer for Base/Dense/Discrete, because unlike Dedekind at the time its section was
written, all three engines already exist — go straight to unconditional.

**(2) No import change is required.**

`StrongCompleteness.lean` already imports `BXCanonical.CompletenessDedekind`, whose line 7 is
`import FormalSystem.Metalogic.BXCanonical.Completeness`. I verified this by deleting the explicit
import from the prototype and recompiling: still exit 0. The plan must not add an import line.

**(3) The `completeness_dense` / `completeness_discrete` name collision is benign — measured, not assumed.**

Re-exposing the weak forms as `FormalSystem.Metalogic.completeness_dense` and
`…completeness_discrete` puts those short names in a namespace that also reaches
`FormalSystem.Metalogic.BXCanonical.completeness_dense` etc. (Dedekind sidestepped this by naming
its engine `completeness_dedekind_engine`.) I compiled a deliberate ambiguity probe — the new
declarations in `namespace FormalSystem.Metalogic` plus `open FormalSystem.Metalogic.BXCanonical`
plus a use site — and it **elaborates clean, exit 0**: the enclosing-namespace declaration wins
over the `open`. Furthermore, a repo-wide grep shows every reference to `completeness_dense` /
`completeness_discrete` outside `BXCanonical/Completeness.lean` is **docstring prose, not a call
site**, so nothing can be silently re-pointed. The two forms have identical types in any case, so
even a re-pointing would be semantically inert. Not a blocker; worth one sentence in the module
docstring.

### The landed shape (verified to compile; use verbatim)

For Base — note `SemanticConsequence`, not a new definition:

```lean
theorem semantic_deduction_base (Γ : Context) (φ : Formula) :
    SemanticConsequence Γ φ ↔ valid (Γ.foldr Formula.imp φ) := by
  constructor
  · intro h D _ _ _ _ F M τ hτ t
    exact (truthAt_foldr_imp M τ t Γ φ).mpr (h D F M τ hτ t)
  · intro h D _ _ _ _ F M τ hτ t
    exact (truthAt_foldr_imp M τ t Γ φ).mp (h D F M τ hτ t)

theorem consequence_completeness_base (Γ : Context) (φ : Formula)
    (h : SemanticConsequence Γ φ) : Derivable FrameClass.Base Γ φ :=
  (derivable_foldr_imp_iff Γ φ).mpr
    (BXCanonical.completeness _ ((semantic_deduction_base Γ φ).mp h))

theorem soundness_base_consequence (Γ : Context) (φ : Formula)
    (h : Derivable FrameClass.Base Γ φ) : SemanticConsequence Γ φ := by
  intro D _ _ _ _ F M τ hτ t h_ctx
  exact h.elim fun d => soundness Γ φ d D F M τ hτ t h_ctx

theorem completeness_base (φ : Formula) (h : valid φ) :
    Derivable FrameClass.Base [] φ :=
  consequence_completeness_base [] φ
    ((semantic_deduction_base [] φ).mpr (by simpa using h))
```

Dense and Discrete each need their own relation. The **only** thing that varies across the three
is the number of `_` placeholders in the `intro` — one per instance binder. Getting that count
wrong is the single likely failure mode, so it is tabulated:

| Class | Relation | `intro` placeholder count (after `D`) | Extra binders beyond Base's four |
|---|---|---|---|
| Base | `SemanticConsequence` (existing) | 4 | — |
| Dense | `SemanticConsequenceDense` (new) | 5 | `[DenselyOrdered D]` |
| Discrete | `SemanticConsequenceDiscrete` (new) | 8 | `[SuccOrder D] [PredOrder D] [IsSuccArchimedean D] [IsPredArchimedean D]` |

Each new relation is its `SetSemanticConsequence*` sibling in `SetConsequence.lean:70–105` with
`Γ : Set Formula` changed to `Γ : Context` and nothing else. Both new definitions and all
remaining eight theorems compiled clean; the full prototype text is reproducible from the table
above plus the Base block.

Note the `soundness_*_consequence` guards are not optional decoration: `soundness`,
`soundness_dense` and `soundness_discrete` (`Soundness.lean:1080, 1254, 1400`) all already have
exactly the required `(Γ) (φ) (d) (D) [binders] (F) (M) (τ) (h_mem) (t) (h_ctx)` shape, so each
guard is a two-line proof, and each is what stops a mis-stated consequence relation from making
the matching completeness terminus vacuous — the role `soundness_dedekind_consequence` already
plays for Dedekind.

### Insertion points (verified by symbol, current file)

| Content | Section header | Line |
|---|---|---|
| Base block | `/-! ## Consequence and strong completeness for FrameClass.Base` | 401 |
| Dense block | `/-! ## Consequence and strong completeness for FrameClass.Dense` | 413 |
| Discrete block | `/-! ## Consequence completeness for FrameClass.Discrete` | 419 |

Each header's "Reserved" prose must be replaced, not merely appended to — it currently asserts the
material is "intentionally absent", which becomes false the moment the block lands.

---

## Leg B — genuine strong completeness for Base and Dense

### Verdict: the *substantive* result is NOT reachable in this task. A well-defined cheap slice is.

**What 361 and 424 actually settled.** 361's design
(`specs/archive/361_.../design/02_compactness-route.md`) separates two questions and returns
**opposite** verdicts:

- **Q2 (architectural)** — does the existing BXCanonical chronicle machinery deliver model
  existence for arbitrary `SetConsistent` sets? **VERDICT: NO**, and structurally so. Every
  countermodel in the tree comes from `fully_restricted_parametric_completeness_from_neg_membership`,
  whose three coherence hypotheses are *root-relative* and quantify over `subformulaClosure` /
  `deferralClosure`, both of which return a **`Finset`**. An infinite `Γ` needs coherence over
  `⋃_{ψ ∈ Γ} subformulaClosure ψ`, which is not a `Finset`. This is not a missing lemma; it is why
  the recommended route abandons the chronicle rather than extending it.
- **Q1 (mathematical)** — is `⊨_Base` / `⊨_Dense` compact? **VERDICT: likely, not proved.**

The recommended route is instead a bespoke ultraproduct, decomposed into `S1`–`S5`. **`S1` is task
424, and it has PASSED**: both directions of the shift-set representation theorem
(`ShiftSet.forward_repr`, `ShiftSet.reverse_repr`) are landed sorry-free, and the one non-free
field (`sep`, the paper's *Limit* axiom) is first-order over the two-sorted signature and hence
ultraproduct-preserved, so the GATING RULE's cancel condition is **not** met.

**But `S2`–`S5` do not exist**, as tasks or as code — I grepped for `ultraproduct` / `Łoś` across
`specs/TODO.md` and found only the authorization prose. 361's GATING RULE is explicit that a
PASSED gate *authorizes* their creation and nothing more, and 424's own summary restates it: "a
PASSED verdict only unblocks authorization for them." Leg B's substance is:

- `S2` — the ultraproduct carrier over the index type `{L : List Formula // ∀ ψ ∈ L, ψ ∈ Γ}`
- `S3` — a Łoś lemma for `TruthAt` by induction on `Formula`, six cases, mechanical except `box`
- `S4` — `ModelExistenceBase`/`ModelExistenceDense`, hence `CompactBase`/`CompactDense`
- `S5` — strong completeness for Base and Dense

**Recommendation: do not attempt `S2`–`S5` inside task 362.** They are separate multi-phase tasks
by 361's own decomposition (`design/04_subtask-decomposition.md`), and attempting them here would
violate the phase-sizing discipline as well as the gating rule's spawn protocol. The plan should
instead record the authorization and recommend spawning them — that recommendation belongs in the
task's summary, not in a `sorry`.

### The reachable slice of leg B (prototyped, compiles, sorry-free)

`SetConsequence.lean` currently carries the Dense and Discrete set-layer vocabulary but the **Base
half is missing**: `SetSemanticConsequenceBase` exists (`:70`), but `CompactBase`,
`StrongCompletenessBase`, `SatisfiableBaseSet` and `ModelExistenceBase` do not. Correspondingly,
`strongCompletenessDense_of_compact` exists in `StrongCompleteness.lean:262` with no Base
counterpart. Adding the mirror is cheap, closes a visible asymmetry, and reduces leg B to exactly
one named obligation per class. I prototyped it — compiles clean, exit 0:

```lean
theorem strongCompletenessBase_of_compact (hc : CompactBase)
    (engine : ∀ ψ : Formula, valid ψ → Derivable FrameClass.Base [] ψ) :
    StrongCompletenessBase := by
  intro Γ φ h
  obtain ⟨L, hL, hvalid⟩ := hc Γ φ h
  exact ⟨L, hL, (derivable_foldr_imp_iff L φ).mpr (engine _ hvalid)⟩
```
→ `[propext, Classical.choice, Quot.sound]`.

The four Base definitions are their Dense siblings (`SetConsequence.lean:200–226`) with
`SetSemanticConsequenceBase`/`valid` in place of `SetSemanticConsequenceDense`/`ValidDense` and the
`[DenselyOrdered D]` binder dropped.

Keep the `engine` hypothesis live, exactly as the Dense version does and for the reason its
docstring gives: it isolates `CompactBase` as the whole of the remaining obligation. Note that
`engine` is now dischargeable at `BXCanonical.completeness` — worth saying in the docstring (as
the Dense one already says for `completeness_dense`), but do not discharge it.

**Note on file scope.** The brief's `file_scope` is `StrongCompleteness.lean` and `Metalogic.lean`.
This slice touches `SetConsequence.lean` as well. That is a genuine scope extension and should be
an explicit, user-visible decision in the plan rather than a silent one; if it is declined, leg B
reduces to documentation only and nothing else in the task is affected.

---

## Leg C — no strong form for Discrete or Dedekind

### Verdict: already landed. Leg C is documentation reconciliation, not proof work.

- **Discrete**: fully machine-checked in `FormalSystem/Metalogic/DiscreteNonCompactness.lean`.
  `archWitness`, `archWitness_finitely_satisfiable`, `archWitness_not_satisfiable`,
  `discrete_consequence_not_compact` (refuting `CompactDiscrete`) and
  `strongCompletenessDiscrete_refuted` (refuting `StrongCompletenessDiscrete`) all carry
  `#print axioms` audits at `:295–315`. Nothing to prove.
- **Dedekind**: the non-compactness claim rests on Reynolds 1992 Thm 7 being weak-only. It is
  **prose, not a theorem** — there is no `CompactDedekind` definition and no refutation. The
  `StrongCompleteness.lean` module docstring and the `consequence_completeness_dedekind_of_engine`
  docstring (fact 2) both state it flatly as settled.

  **This is the one place in the task where a claim outruns its evidence.** The docstring asserts
  "It is refuted, not merely unproved" for Dedekind, but no refutation exists in the tree, and the
  Discrete case shows what an actual refutation looks like. The honest options are (a) formalize a
  Dedekind witness — out of scope and not obviously cheap, since the Discrete witness leans on
  `IsSuccArchimedean` which Dedekind does not have — or (b) **soften the Dedekind prose to
  distinguish "unavailable on the primary source's own terms" from "machine-refuted"**, reserving
  the latter phrasing for Discrete. Recommend (b), as a one-paragraph edit, and flag the asymmetry
  explicitly rather than letting the two classes read as sharing a status. `SetConsequence.lean`
  already models exactly this discipline for Dense vs. Discrete ("The Dense and Discrete statements
  must not be read as sharing a status") — the same care is owed to Dedekind vs. Discrete.

---

## Leg D — LaTeX alignment (`latex/subfiles/04-Metalogic.tex`, 545 lines)

### Verdict: reachable, and larger than the brief anticipates — the file carries three false claims about the Lean tree.

**The "Note on Infinite Contexts" TODO the brief asks to resolve no longer exists.** I grepped the
whole `latex/` tree for "Infinite Context" — zero matches. The terminology work it was to gate is
also already done: `\subsubsection{Consequence Completeness}` (`:235`) and
`\subsubsection{Strong Completeness and Compactness}` (`:267`) already implement the settled
2026-07-27 discipline, and `:243` already states "The name *strong completeness* is reserved for
the infinite-premise statement". **Leg D as literally briefed is complete.**

What is *not* done is factual currency. `\subsubsection{Sorry Status}` (`:482`) is badly stale:

| Line | Claim | Status |
|---|---|---|
| 487 | "`completeness` (Base, line 196) carries exactly **one** live `sorryAx`, sourced from the deprecated `WeakCanonical.countermodel_discrete` fallback" | **FALSE.** Verified `[propext, Classical.choice, Quot.sound]`, no `sorryAx`. `FormalSystem/Metalogic.lean:48` already records the correction. |
| 489 | "An unconditional `completeness_dedekind` **does not exist**. Only `…_of_engine` … are landed" | **FALSE.** `completeness_dedekind` and `consequence_completeness_dedekind` are landed unconditionally at `StrongCompleteness.lean:398–399`, with `#print axioms` audits in the file. |
| 493 | "The one remaining sorry has a specific, named blocker…" whole paragraph | **Moot.** No such sorry. |
| 536–538 | "the Base-class instance additionally carries the single live sorry described above" | **FALSE**, same defect restated in the summary table footnote. |

Additional currency edits, all small:

- `:246–250` — the Consequence Completeness footnote points only at
  `consequence_completeness_dedekind_of_engine` and says the Base/Dense/Discrete instances "follow
  the same three-declaration shape". Once leg A lands, repoint it at the four unconditional
  theorems and correct "three-declaration" (Base is four declarations and reuses
  `SemanticConsequence`; the others are five).
- `:275–290` — the **Base and Dense: open** bullet should record 424's PASSED gate and the
  ultraproduct route, and should carry 361's Q2 finding (the chronicle machinery structurally
  cannot reach model existence), which is the more informative half and is currently absent.
- `:288–296` — the **Discrete: provably unavailable** bullet is still prose; cite
  `discrete_consequence_not_compact` and `strongCompletenessDiscrete_refuted` by name.
- `:296–302` — the **Dedekind** bullet: apply the leg-C softening above.

**Note on file scope**, again: `latex/` is outside the brief's declared `file_scope` even though
leg D is in the brief's SCOPE. Same treatment as leg B's — make it explicit in the plan.

---

## Also requires updating: `FormalSystem/Metalogic.lean`

In scope and unambiguous. The "Publication-Ready Results" list (`:44–75`) needs four new entries
for the leg-A termini with their axiom sets, and the entry at `:62` ("Consequence completeness
(Dedekind)") should be generalized to note that the finite-context form now exists for all four
classes. The `StrongCompleteness.lean` bullet in "Key Components" (`:101`) should mention the
per-class consequence layer.

---

## Tactic survey

No tactic search was needed. Every proof obligation in leg A and the reachable leg-B slice closes
by `exact` term application against existing lemmas (`truthAt_foldr_imp`, `derivable_foldr_imp_iff`,
`soundness*`, `BXCanonical.completeness*`), with `constructor`/`intro` for the biconditionals and a
single `simpa using h` to discharge the vacuous `∀ ψ ∈ [], _` binder in each weak corollary. All of
it compiled on the first attempt; nothing required `simp`/`omega`/`aesop`/`decide` and no premise
search was run.

The one measurement worth carrying forward is the `intro` placeholder-count table in leg A — that
is where an implementer will lose time, not in tactic selection.

---

## Recommended plan shape

| Phase | Content | Files | Risk |
|---|---|---|---|
| 1 | Base consequence block (4 decls, reusing `SemanticConsequence`) + section prose | `StrongCompleteness.lean` | low — prototyped |
| 2 | Dense consequence block (5 decls) | `StrongCompleteness.lean` | low — prototyped |
| 3 | Discrete consequence block (5 decls) + `#print axioms` audit for all three | `StrongCompleteness.lean` | low — prototyped |
| 4 | Base set-layer mirror + `strongCompletenessBase_of_compact`; leg-C Dedekind prose softening | `SetConsequence.lean`, `StrongCompleteness.lean` | low — prototyped; **scope extension** |
| 5 | Tracking-table update | `Metalogic.lean` | low |
| 6 | LaTeX currency + terminology finish | `latex/subfiles/04-Metalogic.tex` | low; **scope extension** |

Zero-debt outlook: **no phase requires a `sorry`, and none is permitted.** Every Lean obligation in
phases 1–5 has been compiled to completion against the real build. The parts of the brief that
*would* have needed a `sorry` — leg B's `S2`–`S5` — are correctly handled by not attempting them
and by recommending they be spawned as separate tasks under 361's now-satisfied gate.

## Verification commands

```
lake build FormalSystem.Metalogic.StrongCompleteness    # currently green, 2254 jobs
lake build                                              # full-tree acceptance
```
Plus `#print axioms` on each new terminus, expecting exactly
`[propext, Classical.choice, Quot.sound]`.
