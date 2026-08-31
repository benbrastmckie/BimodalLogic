# Research Report: Definitional Review, app:dense Verdict, Galois Closures, Task Realignment

**Task**: 514 — align_definitions_with_source_paper (METATASK, metalogic systematicity front)
**Task Type**: formal
**Domains**: logic (temporal/modal correspondence, completeness), math (ordered abelian groups,
Galois connections, order theory)
**Source of truth**: `/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex`
(4893 lines, read at the anchors listed below on 2026-08-31)
**Started / Completed**: 2026-08-31

---

## Executive Summary

1. **Phase 1 (definitional review)**: complete map of the 28 named paper definitions to the Lean
   tree (§1). Confirmed finding (1) of the dispatch: `def:frame` makes the temporal order 𝔻 a
   **component** of the task frame, `def:frame-properties` predicates Discrete/Dense/Complete
   **of a frame**, `def:frame-validity` is per-frame — the tree's `TaskFrame (D : Type)`
   parameterization is the deviation, and `Complete` (not "Dedekind") is the paper's name. The
   four category-theoretic definitions (`def:interval-site`, `def:behavior-presheaf`,
   `def:path-category`, `def:conduche`) are **presentational** with respect to the metalogic
   front: no soundness/completeness result consumes them (§1.4). Verdict: no Lean counterpart
   required.

2. **The app:dense conflict is adjudicated: resolution (a), in a precise form** (§2). The
   theorem *statements* of `app:discrete`/`app:dense`/`app:complete` read as per-frame
   biconditionals, and their (⇒) directions in that reading are **false** — machine-refuted by
   `staticFrame` (511 probes). But the paper's own *proofs* prove, and their closing sentences
   *state*, a different and true theorem: each (⇒) direction constructs one counterexample frame
   F′ over the non-conforming 𝔻 and concludes verbatim "the axiom is not valid over **every task
   frame with temporal order 𝔻**". So the proven content is the **temporal-order-level**
   biconditional `(∀ F with order 𝔻, ⊨_F ax) ↔ 𝔻 is X` — exactly report 01's Tier-1
   duration-type correspondence. Candidates (b), (c), (d) are each eliminated with evidence
   (§2.2). The author has met the degenerate-frame phenomenon: the commented-out
   `cor:no-characterization`/`app:drift` use the same technique against Deterministic, and
   `app:deterministic` is carefully one-directional; the biconditional *phrasing* survives only
   at Discrete/Dense/Complete, where the D-level reading is what the proof delivers.

3. **Phase 2 (Galois closure): the dispatch's premise "Sat .Dense is NOT Galois-closed" is
   WRONG, and the correction is the central positive result** (§3). The closure of a class is
   computed against `Th(K)` — *all* sentences valid over the class — not against the single
   density axiom. `Th(Sat .Dense)` contains the **indicator axiom** NN = `¬U(⊥,⊤)` = ¬X⊤
   (the tree's `Axiom.dense_indicator`, already sound over Dense, machine-checked), and X⊤'s
   truth is **independent of the model, the history, and the valuation** — it says only "the
   evaluation time has an immediate successor in 𝔻". Hence `Mod{NN} = Sat .Dense` *exactly*, so

   > **Sat .Dense IS Galois-closed** (and dually, the paper's Discrete class is Galois-closed
   > via X⊤). `Mod{density-schema} = FwdRec` (511) characterizes the closure of the *single
   > axiom* DN, not the closure of the class.

   Full closure table for all five classes in §3.3, including the two genuine non-closures:
   ℤ-time (the tree's Discrete) and dense-and-complete (the tree's Dedekind), each with an
   explicit degenerate witness and a sandwich characterization, and an argument that no
   closed-form characterization is currently available for either (Reynolds' own
   "no temporal formula can" remark, already quoted in the tree's `sep` docstring, is the
   published form of this obstruction).

4. **Phase 3 (task realignment)**: verdict per task in §4 — 512 KEEP (now paper-mandated, not
   merely encoding-preference), 507 KEEP (amended direction confirmed; add the `.Dedekind →
   .Complete` rename and `Sat` spec), 508 KEEP, 509 KEEP, 510 KEEP with DELETE verdict
   pre-registered, 511 CLOSE as researched (its deliverables are absorbed), 513 **REVISE
   fundamentally** — the uniform-faithfulness question is answered *negative* by §3 and the task
   becomes the Galois-closure implementation task. Exact replacement description texts are given
   in §4.3 for the implement phase of this metatask to apply.

---

## 0. Method and evidence discipline

Everything below is labelled:
- **[paper]** — read directly from `possible_worlds.tex` at the cited anchor this session.
- **[Lean]** — already machine-checked in the tree or in
  `specs/511_research_frame_correspondence_infrastructure/reports/02_probes.lean` / `03_probes.lean`
  (sorry-free, axiom-profiled per those reports).
- **[argued]** — mathematical argument made in this report, not formalized; each is small and
  each is listed in §5 as a formalization obligation for the revised task 513.

Anchors were read at these source lines (current file state; `specs/paper-definitions-of-record.md`
is the drift-tracked mirror and should be extended with any anchor below it does not yet carry):
`def:temporal-order` :2779, `def:task-relation` :2783, `def:directed` :2811, `def:frame` :2841,
`def:deterministic` :2875, `def:task-topology` :2879, `def:world-history` :2963,
`def:constraints` :3036, `def:BL-semantics` :3603, `def:time-shift-histories` :3620,
`def:frame-properties` :3731, `def:frame-validity` :3744, `def:BLplus-language` :3755,
`def:BLplus-semantics` :3767, `def:BLplus-defined` :3782, `app:discrete` :3842, `app:dense`
:3923, `app:complete` :4003, `app:drift` (commented) :~4245, `cor:no-characterization`
(commented) :4282, `def:logical-consequence` :4351, `def:derivability` :4356, `def:soundness`
:4360, `def:S5` :4555, `def:BX` :4573, `def:TMplus-f` :4622, `def:TMplus-d` :4642,
`def:TMplus-c` :4659, `def:TMplus` :4682, `cor:tm-completeness` :4700ff, `def:order-automorphism`
:2568, `def:time-shifted` :2576, `def:abundant` :2611, `def:bisimulation` :2286,
`def:interval-site` :3245, `def:behavior-presheaf` :3270, `def:path-category` :3423,
`def:conduche` :3443, `app:auto_existence` :3630, `lem:deterministic-singleton` :4106,
`app:deterministic` :4139, `app:non-deterministic` :4158.

---

## 1. Phase 1 — Definitional review: paper → Lean map

### 1.1 The semantic core

| Paper anchor | Paper content (condensed; quotes verbatim where load-bearing) | Lean counterpart | Divergence |
|---|---|---|---|
| `def:temporal-order` | "A *temporal order* is a **nontrivial totally ordered abelian group** 𝔻 = ⟨D,+,0,≤⟩ with positive cone D⁺" **[paper]** | binder set `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]` | Aligned pointwise, but scattered as an *inlined binder list* at every site instead of one bundled notion — the root duplication (task 512). |
| `def:task-relation` | Parameterized relation on D⁺, extended to D by the **converse convention** `w ⇒₋ₓ u := u ⇒ₓ w`; defines Fiber, Cone, Segment **[paper]** | `TaskRel : WorldState → D → WorldState → Prop` total in D, with `converse` axiom field | Representational only; extensionally aligned (converse-field ↔ converse-convention). |
| `def:frame` | "A *task frame* is any 𝔽 = ⟨W, **𝔻**, ⇒⟩" — **𝔻 is a component of the tuple** — with axioms *Compositionality* (iff), *Seriality*, *Limit*, *Saturation* **[paper]** | `structure TaskFrame (D : Type*) [...]` (`Semantics/TaskFrame.lean:493`) with `comp`, `serial`, `limit`, `spherical`, plus derivable `nullity_identity` and `nonempty` | **THE deviation**: D is a parameter, not a field. Everything else inter-derivable (proved in the module's own docstring analysis). Fixed by task 512, which is hereby paper-mandated. |
| `def:directed` | Two senses (⊇-directed, ⊆-directed) of directedness for set families; the ⊇ sense feeds *Saturation* **[paper]** | folded into the `spherical` field's statement | Aligned. Not a frame condition on its own — relevant to §2.2(b). |
| `def:deterministic` | Frame-level: 𝔽 Deterministic iff `u = v` whenever `w ⇒ₓ u` and `w ⇒ₓ v` **[paper]** | **none** in `Semantics/` | Gap, but **not load-bearing for this front**: its consumers (`lem:deterministic-singleton`, `app:deterministic`, `app:non-deterministic`) concern the Stability operator, which is not in `Formula`. No task needed now. |
| `def:task-topology` | Basic opens = cones; T1/R0 notions **[paper]** | **none** | Presentational (feeds `app:topology-t1`/`-r0` remarks only). No counterpart needed. |
| `def:world-history` | Partial history (`τ(x) ⇒_{y−x} τ(y)`), *convex* domain, total = possible world, H_𝔽 **[paper]** | `PartialHistory` / `WorldHistory` (`respects_task`, convexity), `IsTotal`; H_𝔽 via extension theorem (`Semantics/Extension/`) | Aligned (verified previously; pinned in `paper-definitions-of-record.md`). |
| `def:constraints` | Constraints on z ∉ X: segments/fibers through τ **[paper]** | `Semantics/Extension/Constraint.lean` | Aligned. |
| `def:BL-semantics` | Model = frame + valuation `|pᵢ| ⊆ W` (**valuation on world states**); truth at (τ, x); `□` quantifies over all of H_𝔽 **[paper]** | `TaskModel.valuation : F.WorldState → Atom → Prop`; `TruthAt` (`Semantics/Truth.lean:163`) | Aligned (511 report 01 §2 verified clause-by-clause). |
| `def:time-shift-histories` + `app:auto_existence` + `lem:history-time-shift-preservation` | Translations `ā(z) = z + d`; **every task frame** admits a shift of any history to any time; truth preserved **[paper]** | at D = ℤ only (`IntNormalForm`/`IntTransfer`; probe `truthAt_add_hist_period`) | Partial gap at general D. Low priority: used by the paper for BL-side lemmas, not consumed by the front's soundness/completeness chain. Record; do not open a task. |
| `def:frame-properties` | "A **task frame** 𝔽 = ⟨W, 𝔻, ⇒⟩ is: **Discrete** [every x with a successor has a least one] / **Dense** / **Complete** [LUB property]" — properties **of a frame**, each a condition on its 𝔻-component; the third is named **Complete** **[paper]** | carrier-typeclass conditions on the *parameter* D; class name `Dedekind` in `FrameClass`, `ValidDedekind*` | Three divergences: (i) predicated of D-the-parameter, not of a frame (consequence of the 512 deviation); (ii) name `Dedekind` is non-conforming — paper says **Complete**; (iii) tree's Discrete adds `IsPredArchimedean` (ℤ-time), strictly narrower than the paper's Discrete — deliberate (TM⁺_f targets ℤ-time, §3.3) but must be named honestly, not called "the Discrete class". |
| `def:frame-validity` | "valid **over a task frame** 𝔽 … for every model M where 𝔽 = ⟨W,𝔻,⇒⟩, possible world τ ∈ H_𝔽, and time x ∈ D" + footnote: never vacuous since H_𝔽 ≠ ∅ **[paper]** | `TaskFrame.ValidOn` (`Semantics/Validity.lean:561`) — present and conforming — **plus 14 other validity predicates that quantify over D** | The paper has ONE validity notion, per-frame. The tree's `valid`/`ValidDense`/`ValidDiscrete`/`ValidDedekind`/`ValidDedekindDense`/`BLValid*`/`ValidInt`/`ValidOver*` are all duration-quantified images of it. Task 507's amended frame-level shape is the paper's shape. |
| `def:BLplus-language` / `-semantics` / `-defined` | BL⁺ with Since/Until primitive; Past/Future/f/p/△/▽/Next/Previous defined **[paper]** | `Formula` (untl/snce primitive); `allFuture`, `someFuture`, `kPlus`, `kMinus`, etc. | Aligned; the tree's primary language is BL⁺ as the paper's TODO at `def:BLplus-language` itself anticipates ("no reason not to start with this more expressive language"). |
| `def:logical-consequence` | ONE relation Γ ⊨ φ over **all** models; `cor:tm-completeness` then defines the **class-restricted** ⊨_C ("restricts def:logical-consequence to models over task frames in a class C") **[paper]** | 8 hand-copied `SetSemanticConsequence*` variants | The paper's ⊨_C **is** the FrameClass-indexed consequence relation task 507 builds. One definition, indexed — the paper already has the shape. |
| `def:derivability` | smallest relation closed under TM's axioms/rules **[paper]** | `DerivationTree (fc : FrameClass)` / `Derivable fc` | Aligned and already parameterized — the model for the semantic side. |
| `def:soundness` | Γ ⊨ φ whenever Γ ⊢ φ **[paper]** | ~23 instances of one schema | Task 508's target: one theorem `Derivable fc Γ φ → SetSemanticConsequence fc Γ φ`. |

### 1.2 The proof systems

| Paper anchor | Content | Lean counterpart | Divergence |
|---|---|---|---|
| `def:S5` | MK, MT, M5, MP, MN **[paper]** | Base-layer modal axioms in `Axiom` | Aligned. |
| `def:BX` | TN, TD, TB, TL, CN, TA, UE, UT, UI, UC, UF, UG, SU + uniformity NP, NF, NA, NB **[paper]** | Base-layer temporal constructors (45 total; incl. `serial_future`/`serial_past` = TB and its past form) | Aligned modulo naming; a constructor-by-constructor audit is routine and belongs to 507/508's plan, not new research. |
| `def:TMplus-f` | BX_f = BX + **UZ** (`fφ → ¬φUφ`) + **Z1**; sound/complete class is **exactly ℤ-time** (successor-Archimedean discrete, by Hölder); UZ/Z1 explicitly **not sound over non-Archimedean discrete orders** (ℤ×_lex ℤ comment) **[paper]** | `prior_UZ`, `prior_SZ`, `z1` at `.Discrete` (`Axioms.lean:342–368`) | Aligned, including the ℤ-time narrowing — the paper itself narrows. The *class name* is where care is needed (§3.3, Discrete row). |
| `def:TMplus-d` | BX_d = BX + **DN** (`FFφ → Fφ`) + **NN** (`¬X⊤`, "no immediate successor") **[paper]** | `density`, `dense_indicator` at `.Dense` (`Axioms.lean:370–392`) | Aligned. `dense_indicator` IS the paper's NN. Load-bearing for §3. |
| `def:TMplus-c` | BX_c = BX + Reynolds **Prior-U**, **Sep** (K⁺/K⁻ abbreviations); **CO is a derived theorem** of BX_c **[paper]** | `prior_U_gap`, `prior_S_gap`, `sep` at `.Dedekind`; `co_derived` in `Theorems/DedekindDerived` | Aligned in content (tree keeps Reynolds triple official, CO derived — matching the paper's "may be omitted"). Name `Dedekind` non-conforming. |
| `def:TMplus` | TM⁺ = S5 + BX + **MF** (`□φ → □Fφ`); TM⁺_f/d/c add the class axioms **[paper]** | `FrameClass` + `minFrameClass` (`Axioms.lean:531,601–608`) | Aligned; `FrameClass` order Base ≤ Dense ≤ Dedekind, Base ≤ Discrete matches which axioms each system may use. |
| `cor:tm-completeness` | ⊨_C defined; **TM⁺ strongly complete over all task frames; TM⁺_d strongly complete over dense; TM⁺_f weakly complete over ℤ-time; TM⁺_c weakly complete over the dense-and-complete class**; strong completeness provably fails for ℤ-time and ℝ **[paper]** | `StrongCompleteness.lean`, `DiscreteNonCompactness.lean`, per-class families | The completeness targets of record. Note: TM⁺_c's class is **dense-and-complete** (= ℝ up to iso), not bare Complete — the tree's `.Dedekind ↦ DenselyOrdered ∧ LUB` interpretation (507 report) has the **right semantics under the wrong name**. |

### 1.3 The two-dimensional layer (no counterpart needed)

`def:bisimulation` (:2286), `def:order-automorphism` (:2568), `def:time-shifted` (:2576),
`def:abundant` (:2611) all belong to the paper's **two-dimensional (Thomason-style) semantics**
critique in the run-up sections — models ⟨W, T, ≤, |·|⟩, not task frames. `def:abundant` in
particular is a condition on *two-dimensional models of BLK* **[paper]**; for task frames the
analogous fact is a *theorem* (`app:auto_existence`: every task frame admits every time-shift),
not a condition. **Verdict: presentational for this repository; no Lean counterpart; and — 
decisive for §2.2(d) — abundance cannot be an implicit hypothesis of the app:dense family,
because for task frames it holds always.**

### 1.4 The category-theoretic layer (determination requested by the dispatch)

`def:interval-site` (:3245), `def:behavior-presheaf` (:3270), `def:path-category` (:3423),
`def:conduche` (:3443) form a self-contained thread: Beh(𝔽) is a sheaf for the Johnstone
coverage on the interval site; Path(𝔽) is its associated category; the associated-presheaf /
discrete-Conduché-fibration equivalence (Johnstone Prop. 2.3, SSV Thm. A.2.1) identifies them;
`rmk:shift-finite-type` connects to shifts of finite type. **Consumers**: `app:presheaf-dictionary`,
`cor:path-fibration`, remarks, and Conclusion prose — all within the thread itself. **No
soundness, completeness, compactness, or characterization theorem cites any of the four**
**[paper]** (checked by following every `\ref` out of the thread). The one contact point with the
core is the *Saturation-backed directed gluing* footnote of `app:gluing`, which is stated and
proved frame-theoretically without categorical vocabulary.

**Verdict: load-bearing for the paper's structural narrative, presentational for the Lean
metalogic front.** No Lean counterpart exists and none is required by any task on this front. If
formalized ever, it is a separate, optional project (natural home: after 512, since Beh(𝔽) wants
a bundled frame). Do not open a task now.

---

## 2. Phase 2a — The app:dense conflict: adjudicated verdict

### 2.1 What the paper actually proves **[paper]**

All three characterization theorems have the same anatomy, read in full this session:

- **Statement** (e.g. `app:dense`): "𝔽 ⊨ FFφ → Fφ iff 𝔽 is a Dense task frame."
- **(⇐) proof**: "Suppose **𝔻** is Dense and let 𝔽 = ⟨W,𝔻,⇒⟩ be an **arbitrary** task frame…
  Since 𝔽, M, τ, x were arbitrary, [the axiom] is valid over **every task frame** 𝔽 = ⟨W,𝔻,⇒⟩."
  This is a genuine per-frame direction: *every* frame whose order is dense validates the axiom.
- **(⇒) proof**: "Suppose 𝔻 is not Dense. … Let W = {w₀, w₁} … let **𝔽′** = ⟨W,𝔻,⇒⟩ …" — a
  **freshly constructed** two-state frame (for `app:discrete`/`app:complete`: the translation
  frame W = D, `w ⇒_d u iff u = w + d`) — ending verbatim: "**and the axiom is not valid over
  every task frame with temporal order 𝔻**."

So the proofs establish, for each pair (ax, X) ∈ {(DF, Discrete), (DN, Dense), (CO, Complete)}:

> **(T1)**  (∀ 𝔽 with temporal order 𝔻: ⊨_𝔽 ax)  ⟺  𝔻 is X.

They do **not** establish the per-frame reading

> **(T0)**  ⊨_𝔽 ax ⟺ 𝔻_𝔽 is X,

whose (⇒) direction ("⊨_𝔽 ax implies 𝔻_𝔽 is X") is **refuted** — `staticFrame` over ℤ validates
the density schema for every formula while ℤ is not dense **[Lean]** (02_probes
`Static.staticFrame_validates_density`; and `staticFrame` discharges all four `def:frame` axioms
both in the probes and in the tree, `Semantics/TaskFrame.lean:1276ff`, Helper C).

### 2.2 Elimination of the other candidates

- **(b) def:frame stricter than the Lean encoding — NO.** `def:directed` is a definition about
  set families consumed inside *Saturation*, not an extra frame axiom; `def:task-topology`
  imposes no condition (it *defines* a topology and proves T1/R0 as theorems for every frame);
  no condition on H_𝔽 exists beyond `def:world-history` (and H_𝔽 ≠ ∅ is a *theorem*,
  `cor:occurrence`, satisfied by staticFrame's constant histories). Decisively, the paper's own
  counterexample frames in `app:dense` (two-state, permissive at every positive duration) and
  `app:non-deterministic` (identical construction) are frames of exactly staticFrame's degenerate
  character, verified against the four axioms in-text — the paper *relies on* such frames being
  legal. **[paper]**
- **(c) staticFrame unfaithful — NO.** Machine-checked discharge of all four axioms **[Lean]**
  (02_probes; tree Helper C), and the frame-class equivalence analysis in
  `TaskFrame.lean:520ff` shows the Lean frame class is extensionally the paper's.
- **(d) implicit relativization (abundance / constraints) — NO.** Abundance is a condition on
  *two-dimensional models* of the earlier semantics (§1.3); its task-frame analogue is
  `app:auto_existence`, a theorem holding for **every** task frame — so it cannot cut down the
  frame class. `def:constraints` is bookkeeping for the extension theorem, not a frame condition.
  **[paper]**

### 2.3 Prior art inside the paper — the author has met this phenomenon **[paper]**

The commented-out `app:drift` (:~4245) constructs a *non-deterministic* frame 𝔽° (drift at rate
∈ [1,2] on ℝ) over which `φ → ▽φ` (Determined) is valid for every store/recall-free sentence —
truth depends only on the world state of evaluation, the same collapse mechanism as staticFrame's
time-invariance. The commented `cor:no-characterization` (:4282) then compares 𝔽° with the
deterministic unit-drift frame 𝔽¹ and concludes **no store/recall-free sentence set characterizes
the Deterministic frames**. The live `app:deterministic` (:4139) is stated **one-directional**
("if 𝔽 is Deterministic") and `app:non-deterministic` (:4158) only claims *some* non-deterministic
frame refutes the schema. So for Deterministic the paper's phrasing is already honest per-frame.
For Discrete/Dense/Complete the biconditional *phrasing* was retained while the proof's
conclusion sentence carries the correct (T1) quantification — the technique was considered
(same author, same appendix, same degenerate-frame mechanism) but the three statements were not
re-worded to match.

### 2.4 Verdict (the front's definition of record)

> **Resolution (a), precisely bounded.** The per-frame reading (T0) of
> `app:discrete`/`app:dense`/`app:complete` is false in its (⇒) direction; the theorems as
> *proved and concluded* are the temporal-order-level biconditionals (T1), which are true and are
> what the Lean tree shall formalize. The (⇐) directions are genuinely per-frame and are the
> per-class soundness facts the tree already has. No non-degeneracy hypothesis is to be bolted
> onto (T0) — §3 shows the class-level exactness the front wants is recovered by a different and
> already-present mechanism (indicator axioms), and the per-axiom gap is characterized by
> closure, not patched.

This repository treats the paper as read-only input; whether the author re-words the three
statements (e.g. "valid over every task frame with temporal order 𝔻 iff 𝔻 is X") is out of
scope here, but the divergence is recorded and `specs/paper-definitions-of-record.md` should
carry the three `app:*` anchors with this reading note when next extended.

The counterexample frames used by (T1)'s (⇒) directions are, in tree terms: the **translation
frame** `w ⇒_d u ↔ u = w + d` over D (= report 01's `transFrame`, needed for `app:discrete`/
`app:complete`) and the **two-state permissive frame** (= `natFrame`'s relation class over a
two-point carrier, `app:dense`). Both are ~15-line constructions against existing helpers
(`TaskFrame.lean` Helpers B/C, `limit_of_shift`).

---

## 3. Phase 2b — The Galois closure, per frame class

### 3.1 Setup (the definitions the tree shall carry, post-512)

With bundled frames (task 512), `Fr := TaskFrame` is a type and classes are `Set TaskFrame`:

```
Th  : Set TaskFrame → Set Formula     Th K  := {φ | ∀ F ∈ K, F.ValidOn φ}
Mod : Set Formula  → Set TaskFrame    Mod S := {F | ∀ φ ∈ S, F.ValidOn φ}
```

Both antitone; `Mod ∘ Th` is a closure operator; `K` is **Galois-closed** iff `Mod (Th K) = K`.
Then, exactly as the dispatch says:
- correspondence for ax = computing `Mod {ax}` (ax as a schema: the set of its instances);
- soundness for fc = `Sat fc ⊆ Mod (Axioms fc)` where `Axioms fc := {ax | minFrameClass ax ≤ fc}`;
- minFrameClass **class-level** exactness = `Sat fc` Galois-closed with
  `Mod (Axioms fc) = Sat fc`.

Universe note for the implementer: `TaskFrame` bundles two `Type` fields, so `Set TaskFrame`
lives one universe up; `Th`/`Mod` are unproblematic, but keep both `Set`-valued (no `Type`-valued
class of frames is needed anywhere below).

### 3.2 The correction to the dispatch premise — the indicator mechanism

The dispatch inferred "`Sat .Dense` is NOT Galois-closed" from
`Mod{density-schema} = FwdRec ⊋ Sat .Dense`. That inference conflates `Th (Sat .Dense)` with the
single schema DN. It is refuted by one observation:

> **The truth value of X⊤ (`Formula.untl ⊥ ⊤`) at (M, τ, t) is
> `∃ s > t, (t, s) = ∅` — a property of 𝔻 and t alone.** It mentions no atom, so the valuation
> is irrelevant; the `untl` clause never consults τ. **[argued — 5-line unfold of `TruthAt`]**

Combined with homogeneity of ordered groups (t has an immediate successor iff 0 has a least
positive element iff *every* t does; and for a nontrivial totally ordered abelian group, "no
least positive element" ⟺ densely ordered) **[argued — standard, short]**, this gives:

> **(IND-D)** `F.ValidOn NN ⟺ DenselyOrdered F.Duration`, i.e. **`Mod {NN} = Sat .Dense`
> exactly**, per-frame, with no degenerate-frame gap. Dually
> **(IND-F)** `F.ValidOn X⊤ ⟺ F.Duration has a least positive element`, i.e.
> `Mod {X⊤} =` the paper's Discrete class.

(One hypothesis is consumed: `F.ValidOn` quantifies over τ ∈ H_F, so H_F ≠ ∅ is needed for the
⇒ readings — supplied by the tree's extension theorem, as `def:frame-validity`'s own footnote
anticipates.)

NN **is** an axiom of the Dense group — `Axiom.dense_indicator` (`Axioms.lean:381`), whose
docstring already records that the density schema alone cannot derive it (conservativity over ℤ).
X⊤ is **derivable** in the Discrete group: instantiate `prior_UZ` at ⊤ and discharge `f⊤` by
`serial_future` **[argued — 3 lines]**. Since `Axioms fc ⊆ Th (Sat fc)` (soundness, already
machine-checked per class in the tree), the closures follow.

**Consequence for 513's question**: no uniform `Faithful` predicate is *needed* for Dense or
Discrete — class-level exactness already holds — and none can *work* for Complete (§3.3), so the
uniform-faithfulness program has a complete negative answer. Design (A) of 513, upgraded with
indicators, is the answer of record.

### 3.3 The closure table (the Phase-2 deliverable)

Throughout, "Sat" is the post-512/507 frame-level interpretation; classes are duration-determined
(every `def:frame-properties` item is a condition on 𝔻).

| Class K | Definition of record | `Mod (Th K)` | Closed? | Evidence |
|---|---|---|---|---|
| **Base** = all task frames | `def:frame` | `Fr` itself | **YES** (trivially: `Mod S ⊆ Fr` for every S) | definitional |
| **Dense** = {F : 𝔻_F dense} | `def:frame-properties#Dense` | **= Sat .Dense** | **YES** | (IND-D) [argued]; NN ∈ Axioms(.Dense) [Lean, `dense_indicator` + `soundness_dense`]. Per-axiom sub-result: `Mod {DN-schema} = {F : FwdRec F}` at D = ℤ, atomic form at arbitrary D **[Lean, 511 probes]** — this is the closure of the *axiom*, strictly above the class. |
| **Discrete (paper)** = {F : 𝔻_F has least positive element} | `def:frame-properties#Discrete` | **= the class** | **YES** | (IND-F) [argued]. Note: X⊤ ∈ Th(paper-Discrete) even though UZ/Z1 are NOT (they fail over non-Archimedean discrete 𝔻 on rich frames — the paper's own ℤ×_lexℤ comment at `def:TMplus-f`); closure needs only the indicator. |
| **Discrete (tree)** ≈ ℤ-time = {F : 𝔻_F ≅ ℤ} | `def:TMplus-f` ("exactly ℤ-time", Hölder) | `Mod (TM⁺_f)` = {F : 𝔻_F discrete ∧ F ⊨ UZ ∧ SZ ∧ Z1} | **NO** | Witness: `staticFrame` over ℤ×_lexℤ validates every TM⁺_f theorem (time-invariant truth validates UZ, Z1, and all Base axioms; X⊤ holds since ℤ×_lexℤ is discrete) **[argued; Lean-checkable by generalizing 02_probes' time-invariance lemma to arbitrary D — 03's `density_of_hist_periodic` already runs at arbitrary D]**. Sandwich: **ℤ-time ⊊ Mod(TM⁺_f) ⊆ paper-Discrete**. Closed form beyond the sandwich: **open** — no variable-free sentence separates ℤ from ℤ×_lexℤ (all unbounded discrete orders agree on FO(<) sentences, and valuation-free BL⁺ sentences express no more) **[argued]**; and a structural FwdRec-analogue for `Mod {UZ}` is not currently computed. Recorded as open with witness, not guessed at. |
| **Complete (paper)** = {F : 𝔻_F conditionally complete} (≅ ℤ or ℝ by Hölder) | `def:frame-properties#Complete` | strictly larger | **NO** | `Th(K) = Th(ℤ-frames) ∩ Th(ℝ-frames)` contains neither X⊤ nor NN, so the closure contains `staticFrame` over **every** 𝔻 (static-frame validity depends only on the discrete/dense bit of 𝔻 **[argued]**). No temporal-formula characterization of completeness exists — Reynolds, quoted verbatim in the tree's own `sep` docstring (`Axioms.lean:~455`): the axioms "enforce only a *definably* Dedekind-complete model". |
| **Dense-and-Complete** (tree `.Dedekind`) = {F : 𝔻_F ≅ ℝ} | `cor:tm-completeness` item TM⁺_c | `Mod (TM⁺_c)` | **NO** | Witness: `staticFrame` over ℚ validates PU, SEP, DN, NN and all Base axioms (checked schema-by-schema under time-invariance in this session's analysis **[argued; Lean-checkable, same lemma]**), and ℚ is not complete. Sandwich: **ℝ-time ⊊ Mod(TM⁺_c) ⊆ Sat .Dense** (the upper bound via NN ∈ Axioms(.Dedekind), since `.Dense ≤ .Dedekind`). Closed form: **open**, and *expected to stay open* — `sep` has no duration-level correspondent at all (Reynolds' long-line remark; 511 report 01 §6.5), so a closed-form `Mod {sep}` is the same open problem in different clothes. |

### 3.4 What belongs in the Lean tree (specification, consumed by revised task 513)

All post-512 (bundled frames), post-507 (`Sat`, `ValidIn`):

1. **`Semantics/Correspondence/Galois.lean`** (new, small): `Th`, `Mod`, antitonicity both ways,
   `subset_modTh` (K ⊆ Mod(Th K)), `thModTh_eq_th` (closure idempotence facts), and
   `GaloisClosed : Set TaskFrame → Prop`. ~80 lines. *One* definition pair used many ways — no
   per-class copies of anything.
2. **Indicator exactness** (the two theorems that make Dense and paper-Discrete closed):
   `validOn_indicator_iff_denselyOrdered : F.ValidOn NN ↔ DenselyOrdered F.Duration` and its X⊤
   dual; corollaries `modTh_dense_eq : Mod (Th (Sat .Dense)) = Sat .Dense` and the
   paper-Discrete analogue. The X⊤-from-UZ derivation as a `Derivable` lemma.
3. **Per-axiom closure of DN**: port 511's `Corr.density_iff_fwdRec` (atomic, arbitrary D) and
   `Bridge.density_schema_iff_fwdRec` (schema, D = ℤ) out of probe files into the tree, restated
   over bundled frames, as `Mod {DN} = {F | FwdRec F}` at ℤ. (This was already 511's Tier-2
   recommendation; it now lands as a *closure* statement, which is its honest shape.)
4. **(T1) duration-level correspondence** for DF, DN, CO: the paper's three theorems in their
   proven form, using the translation frame and the two-state frame as the (⇒) witnesses.
5. **Non-closure witnesses**: generalize 02_probes' static-frame time-invariance lemma to
   arbitrary D (03's `density_of_hist_periodic` is the pattern) and derive
   (a) `staticFrame ℚ ∈ Mod (Axioms .Dedekind) \ Sat .Dedekind`,
   (b) `staticFrame (ℤ ×ₗ ℤ) ∈ Mod (Axioms .Discrete) \ ℤ-time` (Mathlib has the lex-group
   instances). Sandwich corollaries as stated in the table.
6. **NOT in the tree**: closed-form characterizations of `Mod (TM⁺_f)` and `Mod (TM⁺_c)` — open,
   with the evidence above; do not open tasks that promise them.

Item counts are deliberately small: 2 definitions (Th, Mod), ~8 theorems, 2 witness frames
already essentially present. Everything else in the table is a corollary by closure/order
reasoning — the stacking discipline the governing principle demands.

---

## 4. Phase 3 — Task realignment

### 4.1 Governing facts carried into every verdict

(i) the paper's shape is frame-first (`def:frame`, `def:frame-properties`, `def:frame-validity`,
⊨_C); (ii) the honest characterization layer is (T1) + closures (§2, §3); (iii) one notion per
paper notion, same name — `Complete`, not `Dedekind`; (iv) results must stack via the Galois
module, not by re-proof.

### 4.2 Verdict table

| Task | Verdict | Reason (one line) |
|---|---|---|
| 512 bundle_duration_into_taskframe | **KEEP, amend grounding** | No longer an encoding preference: `def:frame` literally lists 𝔻 as a component. First on the front. |
| 507 parameterize_validity_by_frameclass | **KEEP, amend** | Amended frame-level direction is exactly the paper's ⊨_F / ⊨_C; add the `.Dedekind → .Complete` rename and the `Sat` spec below. After 512. |
| 508 parameterize_soundness_over_indexed_validity | **KEEP, amend citation** | Targets `def:soundness` + ⊨_C; unchanged in substance. After 507. |
| 509 parameterize_compactness_and_strong_completeness_family | **KEEP, amend citation** | Targets `cor:tm-completeness`'s strong/weak completeness per class; unchanged in substance. After 507/508. |
| 510 resolve_orphaned_frameconditions_layer | **KEEP; verdict pre-registered: DELETE** | Under frame-level `Sat` the carrier-typeclass layer has no consumer and no paper counterpart; `AxiomCompatible` superseded by `minFrameClass` either way. After 507 lands its `Sat`. |
| 511 research_frame_correspondence_infrastructure | **CLOSE (researched, terminal)** | Its research deliverables (FwdRec, Tier-1, probes) are absorbed by §3.4 items 3–5; no implementation belongs under it. |
| 513 uniform_frame_faithfulness_predicate | **REVISE (replace description)** | The uniform-`Faithful` question is answered negative by §3.2/§3.3; the task becomes the Galois-closure implementation task (§3.4). Depends on 512 + 507. |

No other active task asserts a superseded shape: 492/493/494 (ultraproduct/compactness chain)
and 495 already speak in class terms and are consumers of 509's family, not of the old
carrier-quantified predicates; they need no text change now (509's implementation will migrate
their call sites mechanically).

### 4.3 Replacement/amendment texts (for the implement phase to apply verbatim)

**512 — append to description:**
> === PAPER GROUNDING (definitive) === def:frame reads verbatim: "A task frame is any F =
> <W, D, =>> where W is a nonempty set of world states, **D is a temporal order**, and => is a
> task relation…" — the duration is a COMPONENT of the frame. def:frame-properties predicates
> Discrete/Dense/Complete of the frame through its D-component; def:frame-validity is per-frame.
> This refactor is therefore conformance to the source of truth, not an encoding preference.
> Naming obligation carried by this task or 507 (whichever touches it first): the paper's third
> frame property is COMPLETE — the ValidDedekind*/FrameClass.Dedekind naming is non-conforming
> and is renamed under 507. See specs/514_align_definitions_with_source_paper/reports/01 §1.1.

**507 — append to description:**
> === PAPER GROUNDING AND NAMING === ValidIn fc is the paper's class-restricted consequence ⊨_C
> (cor:tm-completeness: "restricts def:logical-consequence to models over task frames in a class
> C"); TaskFrame.ValidOn is def:frame-validity and stays the single frame-level primitive.
> Sat interpretation of record: .Base ↦ True; .Dense ↦ DenselyOrdered F.Duration; .Discrete ↦
> ∃ least positive duration WITH the successor-Archimedean refinement kept as a SEPARATE
> named predicate (the paper's def:TMplus-f narrows TM+_f's target to Z-time via Hölder — do not
> silently conflate the Discrete property with the Z-time class); rename FrameClass.Dedekind →
> FrameClass.Complete with Sat .Complete ↦ DenselyOrdered ∧ conditionally-complete (the paper's
> TM+_c target is the DENSE-AND-COMPLETE class, cor:tm-completeness; the bare Complete property
> of def:frame-properties admits Z as well — record both, one predicate each, no bridged
> duplicates). The prior recommendation "rename ValidDedekind to ValidComplete" is superseded by
> this class-level rename. See specs/514_align_definitions_with_source_paper/reports/01 §1.1, §3.3.

**508, 509 — append to each description:**
> === PAPER GROUNDING === Targets def:soundness / def:logical-consequence / cor:tm-completeness's
> ⊨_C and per-class strong/weak completeness roster (TM+ strong over all task frames; TM+_d
> strong over dense; TM+_f weak over Z-time; TM+_c weak over dense-and-complete). Class naming
> follows 507's rename (.Complete, not .Dedekind). See
> specs/514_align_definitions_with_source_paper/reports/01 §1.2.

**510 — append to description:**
> === VERDICT PRE-REGISTERED BY TASK 514 RESEARCH === DELETE. Under the frame-level Sat of 507
> the carrier-typeclass layer has no role and no paper counterpart (the paper has no
> carrier-level validity notion at all — def:frame-validity is per-frame, ⊨_C is per-class).
> Execute as deletion + C6 manifest update; promotion is off the table unless 507's
> implementation discovers a concrete consumer, which its plan must record explicitly if so.

**511 — no text change; postflight note for the board:**
> Research complete and absorbed: FwdRec and the Tier-1/T1 statements land under revised task
> 513; probe files remain the evidence of record. Terminal at [RESEARCHED]; do not dispatch
> /plan 511.

**513 — replace description entirely:**
> GALOIS-CLOSURE IMPLEMENTATION for the frame-class layer, replacing the uniform-faithfulness
> question, which is ANSWERED and closed: no uniform Faithful predicate is needed for
> Dense/Discrete (class-level exactness already holds via indicator axioms) and none can exist
> for Complete (Reynolds: completeness is not characterizable by temporal formulas — the sep
> docstring in ProofSystem/Axioms.lean already quotes this; sep itself has no correspondent,
> 511 report 01 §6.5). Design (A)-with-indicators is the design of record.
>
> DELIVERABLES (all post-512, post-507; spec at
> specs/514_align_definitions_with_source_paper/reports/01 §3.3–3.4):
> (1) Semantics/Correspondence/Galois.lean: Th, Mod, antitonicity, closure operator,
> GaloisClosed — one definition pair, no per-class copies.
> (2) Indicator exactness: F.ValidOn ¬X⊤ ↔ DenselyOrdered F.Duration and the X⊤/discrete dual;
> corollaries Mod(Th(Sat .Dense)) = Sat .Dense and the paper-Discrete analogue; the
> Derivable-level X⊤-from-prior_UZ+serial_future lemma.
> (3) Per-axiom closure of the density schema: port 511's Corr.density_iff_fwdRec (atomic,
> arbitrary D) and Bridge.density_schema_iff_fwdRec (schema, D = Z) from the probe files into
> the tree over bundled frames, stated as Mod {density} = {F | FwdRec F} at Z.
> (4) Duration-level correspondence (T1) for DF/DN/CO in the paper's proven form —
> "(∀ F over D, F ⊨ ax) ↔ D is Discrete/Dense/Complete" — with the translation frame and the
> two-state permissive frame as (⇒) witnesses (app:discrete/app:dense/app:complete adjudication:
> report 01 §2.4).
> (5) Non-closure witnesses: generalize the static-frame time-invariance lemma to arbitrary D
> (03_probes density_of_hist_periodic is the pattern); derive staticFrame over Q ∈
> Mod(Axioms .Complete) \ Sat .Complete and staticFrame over Z ×ₗ Z ∈ Mod(Axioms .Discrete) \
> Z-time; sandwich corollaries Z-time ⊊ Mod(TM+_f) ⊆ paper-Discrete and R-time ⊊ Mod(TM+_c) ⊆
> Sat .Dense.
> (6) EXPLICIT NON-GOALS, recorded so the question is not reopened: closed-form
> characterizations of Mod(TM+_f) and Mod(TM+_c) are OPEN and not promised — evidence: no
> variable-free BL+ sentence separates Z from Z ×ₗ Z or Q from R, and sep has no correspondent.
>
> ACCEPTANCE: sorry-free, lake build green, every theorem above stated over bundled frames with
> Sat from 507, axiom profiles clean; the FwdRec port must not re-prove what the probes proved —
> transplant and restate. GROUNDING: possible_worlds.tex def:frame-properties, def:frame-validity,
> cor:tm-completeness, app:discrete/dense/complete;
> specs/514_align_definitions_with_source_paper/reports/01;
> specs/511_research_frame_correspondence_infrastructure/reports/01–03 + probes.

### 4.4 Build order of record

```
512 (bundle)  →  507 (Sat/ValidIn + Complete rename)  →  508 (soundness)  →  509 (compactness/SC family)
                     ↘ 510 (FrameConditions delete)         ↘ 513-revised (Galois closures)  [after 512+507; parallel to 508/509]
```

511 terminal at [RESEARCHED]. 513-revised is independent of 508/509 (it consumes `Sat` and
`ValidOn` only) and may run in parallel with them.

---

## 5. Formalization obligations opened by this report's [argued] items

All land inside revised 513 (they are its items 2, 4, 5): X⊤ truth-unfolding; ordered-group
homogeneity (successor ↔ least positive element ↔ ¬dense); X⊤ derivability from prior_UZ + TB;
static-frame time-invariance at arbitrary D; the two non-closure witnesses; the (T1) theorems.
None is research; each is a bounded lemma with a stated proof route.

## 6. Risks & Mitigations

- **Risk**: the indicator argument silently depends on H_F ≠ ∅. *Mitigation*: recorded in §3.2;
  the tree's extension theorem supplies it; the `def:frame-validity` footnote is the paper
  warrant.
- **Risk**: the ℚ/ℤ×ₗℤ static-frame witnesses are [argued], not yet [Lean]; if one failed, the
  non-closure rows would need a different witness (not a different verdict — Reynolds' remark
  independently blocks closure of Complete). *Mitigation*: they are items in 513's phase plan
  and were checked schema-by-schema here (PU, SEP, DN, NN, UZ, Z1 under time-invariant truth).
- **Risk**: paper drift — the anchors above are line-numbered against today's 4893-line file.
  *Mitigation*: `specs/paper-definitions-of-record.md` + `scripts/check-paper-definitions.sh`
  is the standing mechanism; the implement phase should add the `app:discrete/dense/complete`
  and `def:deterministic` anchors when it touches that file.
- **Risk**: 507's rename `.Dedekind → .Complete` collides with the *bare* Complete property
  (which admits ℤ). *Mitigation*: §4.3's 507 text mandates both predicates with distinct names
  and forbids conflation; the class constructor denotes the TM⁺_c target class
  (dense-and-complete), documented at the constructor.
