> **SUPERSEDED** (2026-08-10): written against the superseded THREE-axiom frame (iff-Nullity as a primitive axiom, LAX positive-cone Compositionality with interpolation "NOT adopted", "Limit Nullity"), superseded by the paper's four-axiom `\label{def:frame}`: biconditional Compositionality, Seriality, Limit, Spherical, with Nullity demoted to derived `\label{lem:nullity}`. The three bare-relation helper theorems survive verbatim. See specs/438_reconcile_semantic_definitions_with_jpl_paper/reports/01_team-research.md (Deliverable 4) for what survives, and specs/438_reconcile_semantic_definitions_with_jpl_paper/reports/02_logical-consequence-discrepancy-audit.md (Findings 1b/4) for what report 01 itself got superseded on.

# Research Report: Aligning `TaskFrame` with the Refactored Paper `def:frame`

**Task**: 420 — align_task_frame_with_positive_cone_limit_nullity
**Type**: lean4
**Session**: sess_1785332177_7809d8
**Date**: 2026-07-29

---

## 1. Executive Summary

Six findings, all Lean-checked unless explicitly marked otherwise.

1. **The presentation already agrees with the paper.** `nullity_identity`, `forward_comp`
   (with `0 ≤ x`, `0 ≤ y`), and `converse` are exactly the paper's iff-Nullity, positive-cone
   lax Compositionality, and definitional converse convention. The `Axiomatization Notes` block
   claiming a divergence is now factually inverted and must be rewritten as agreement.
2. **`limit_nullity` transcribes cleanly** and the two-sided form compiles as a structure field
   (verified, §5).
3. **The discrete discharge helper needs `[SuccOrder D] [NoMaxOrder D]`, NOT
   `IsSuccArchimedean`.** The task description over-specifies. `IsSuccArchimedean` is never used
   in the one-line proof; `NoMaxOrder` is what makes `0 < Order.succ 0` available, and it is
   already an *instance consequence* of `[Nontrivial D]` on the repo's standard duration binders
   (verified, §6). The repo's existing discrete binder bundle therefore subsumes it for free.
4. **A previously-unflagged obligation: `identityFrame` needs `[Nontrivial D]`.** Limit Nullity
   is vacuous when no positive duration exists, so over a trivial duration group it forces the
   world-state set to be a singleton. The paper independently requires "a **nontrivial** totally
   ordered abelian group", so this is paper-mandated, not an artifact (§7).
5. **The real blocker is not `natFrame` — it is `ParametricCanonicalTaskFrame` at dense `D`.**
   Its task relation is *duration-blind above zero* (`if d > 0 then ExistsTask M N`), which is
   literally the paper's own `app:topology-r0` countermodel. It genuinely violates Limit Nullity
   over `ℚ`/`ℝ`, and it is the witness of the **live** theorem `countermodel_dense_enriched`
   (`Completeness.lean:143`). Restricting it to discrete `D` breaks the build; the sorry-free
   repair is a product carrier, which is exactly the direction task 415 already plans (§8).
6. **New derived result (Lean-verified):** Limit Nullity + finitely many world states forces a
   *uniform* positive radius per state. This mathematically explains why the filtration/FMP
   frames cannot stay dense-polymorphic, and independently corroborates task 417's move to `ℤ`
   (§9).

**Recommendation**: implement in the order of §14. Phase boundaries are drawn so that every
phase ends on a green `lake build`, and the one genuinely hard obligation
(`ParametricCanonicalTaskFrame`) is isolated with an explicit decision gate rather than being
smeared across the task. **No phase requires `sorry`**; a sorry-free path exists for every
obligation, though one of them (§8) is large enough that deferring it to task 415 is the
better-scoped option and is called out as such.

---

## 2. Literature Proof Structure

**Source**: `/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex`
(PossibleWorlds task 51, commits `754d069..e566885`). **Not** in this repo.

**Correct anchors** (all "line 1835" citations in the tree are stale):

| Content | Location |
|---|---|
| Formal `def:frame` | `possible_worlds.tex:2423–2451` (in `\label{app:TaskSemantics}`, line 2415) |
| Body statement of the frame | `possible_worlds.tex:908–926`, gloss at 932 |
| Derived-status remarks (Reflection, backward composition, mixed-sign) | `possible_worlds.tex:954–959` |
| Lax-law footnote (`R_{s+t} ⊇ R_s ∘ R_t`) | `possible_worlds.tex:964` |
| `app:topology-r0` (T1 ⇒ R0) | `possible_worlds.tex:3098–3129`; countermodel at 3108–3111; proof at 3125–3129 |

The file uses an inline revision convention (`%% CHANGE (...)`, `%% OLD: ...`); only
non-commented lines are live. Everything quoted below is live text.

### 2.1 Verbatim `def:frame` (lines 2423–2451, live lines only)

```latex
\begin{Ddef} \label{def:frame}
	A \textit{frame} is a structure $\F = \tuple{W, \D, \Rightarrow}$ where:
	\begin{enumerate}
		\item[\bf World States:] A nonempty set of \textit{world states} $W$.
		\item[\bf Temporal Order:] A nontrivial totally ordered abelian group
		      $\D = \tuple{D, +, 0, \leq}$.
		\item[\bf Task Relation:] A parameterized task relation
		      $\Rightarrow \subseteq W \times D^+ \times W$ on the \textit{positive cone}
		      $D^+ \coloneq \set{x \in D : x \geq 0}$, extended to negative durations by the
		      \textit{converse convention} $w \Rightarrow_x u \coloneq u \Rightarrow_{-x} w$
		      for any $x < 0$, and determining for each $w \in W$ and $x > 0$ the
		      \textit{cone} $(w)_x \coloneq \set{u \in W : w \Rightarrow_y u
		      \text{ where } \lvert y \rvert < x}$, satisfying:
		      \begin{itemize}
			      \item[\it Nullity:] $w \Rightarrow_0 u$ if and only if $w = u$.
			      \item[\it Compositionality:] If $w \Rightarrow_x u$ and
			            $u \Rightarrow_y v$, then $w \Rightarrow_{x + y} v$.
			      \item[\it Limit Nullity:] $\bigcap_{x > 0} (w)_x = \set{w}$.
		      \end{itemize}
	\end{enumerate}
\end{Ddef}
```

**No Reflection axiom** (deleted at 2438–2439). This confirms the task premise that this
supersedes `fix.md` A1.

### 2.2 Step map (paper → Lean)

| # | Paper clause | Lean counterpart | Status |
|---|---|---|---|
| 1 | Nonempty `W` | `WorldState : Type` | Not enforced (no `Nonempty` field). Pre-existing gap, out of scope. |
| 2 | **Nontrivial** totally ordered abelian group `D` | `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]` | **`Nontrivial` NOT enforced** — see §7. |
| 3 | Primitive relation on `D^+`, extended by converse convention | two-sided `TaskRel` + `converse` field | **Agrees.** The `converse` field *is* the definitional convention packaged as structure data. |
| 4 | Cone `(w)_x = {u : w ⇒_y u, |y| < x}` | (no Lean counterpart) | To be introduced inside `limit_nullity`, or as a `def`. |
| 5 | Nullity (iff) | `nullity_identity` | **Exact match.** |
| 6 | Compositionality (lax, on `D^+`) | `forward_comp` with `0 ≤ x`, `0 ≤ y` | **Exact match.** Paper states it proviso-free *on the primitive relation*, which lives on `D^+`; the Lean hypotheses are how that domain restriction is expressed against a two-sided relation. |
| 7 | **Limit Nullity** | *absent* | **The mathematical delta.** |
| 8 | Reflection (derived) | `nullity` + `converse` | Derived, matches. |
| 9 | Backward composition (derived) | `backward_comp` | Derived, matches. |
| 10 | Mixed-sign composition inexpressible | (not stated) | Should be recorded in the docstring. |

### 2.3 Paper text that directly refutes the current `Axiomatization Notes`

`possible_worlds.tex:957–959`:

> Composition of consecutive tasks over negative durations is likewise derived by taking
> converses, composing on the positive cone, and taking the converse of the result.
> By contrast, mixed-sign composition is not so much prohibited as **inexpressible at the
> primitive level**, since primitive durations are nonnegative.
> This is just as well: were composition extended across mixed-sign durations, *Nullity* would
> collapse nondeterminism, since $w \Rightarrow_x u$ and $w \Rightarrow_x u'$ give
> $u \Rightarrow_{-x} w$ by the converse convention, whence $u \Rightarrow_0 u'$ and so $u = u'$.

`possible_worlds.tex:964` calls the positive-cone presentation "not merely equivalent to the
definition above but **its official form**", and states the lax law
`$R_{s + t} \supseteq R_s \circ R_t$` — "the inclusion replaces the usual equality, which would
additionally assert interpolation".

The current Lean docstring (TaskFrame.lean:93–97) says the restricted form is a workaround for
something "algebraically impossible". The paper now makes the *same* argument and **adopts** the
same presentation. The block must be rewritten from "we diverge, here's why it's harmless" to
"we agree; the paper's official form is this, and here is the collapse argument it shares".

---

## 3. Current Lean State — Verified Alignment

`FormalSystem/Semantics/TaskFrame.lean` (311 lines). Structure at line 99, fields:
`WorldState`, `TaskRel`, `nullity_identity` (110), `forward_comp` (120), `converse` (128).
Derived: `nullity` (139), `backward_comp` (149). Examples: `trivialFrame` (173),
`identityFrame` (187), `natFrame` (219). `FiniteTaskFrame` extends at 293.

No `TaskFrame.mk` occurs anywhere in the repo — all constructions use anonymous-constructor or
`where` syntax, so adding a field produces clean "missing field" errors rather than silent
arity breakage. This is good for the implementation: the compiler will enumerate every site.

---

## 4. Stale-Anchor Worklist (`def:frame, line 1835`)

Correct anchor is `possible_worlds.tex:2423` (formal) / `908–926` (body).

| File | Lines |
|---|---|
| `FormalSystem/Semantics/TaskFrame.lean` | 17, 68, 90 |
| `FormalSystem/Examples/TemporalStructures.lean` | 20, 57 |
| `docs/user-guide/architecture.md` | 454 |
| `docs/reference/API_REFERENCE.md` | 147 |

Two adjacent stale artifacts, flagged but **outside this task's stated scope**:
- `typst/chapters/02-semantics.typ:37` carries the same one-way Nullity / unrestricted
  Compositionality as the LaTeX subfile.
- `typst/SYNC-MAP.md:230` records the row as `stale` and cites the pre-refactor paper range
  `possible_worlds.tex:902-907`, which no longer holds.

---

## 5. The `limit_nullity` Field — Recommended Statement (VERIFIED)

Recommend the **two-sided form**, matching the paper's official statement and its cone
definition (which is explicitly over the *extended* relation, `possible_worlds.tex:910`:
"$u \in (w)_x$ just in case $w \Rightarrow_y u$ or $u \Rightarrow_y w$ for some $0 \leq y < x$").

```lean
  /--
  Limit Nullity: nothing distinct from `w` is reachable in arbitrarily small durations.

  Direct transcription of the paper's `⋂_{x > 0} (w)_x = {w}`, where the two-sided cone is
  `(w)_x = {u : ∃ y, |y| < x ∧ TaskRel w y u}` over the extended relation. The `⊇` inclusion
  is `nullity`, so only `⊆` needs stating.
  -/
  limit_nullity : ∀ w u, (∀ x, 0 < x → ∃ y, |y| < x ∧ TaskRel w y u) → u = w
```

**Verified**: this compiles as a structure field alongside the existing four, and all three
library example frames were reconstructed against it (see §7).

Notes on the encoding:
- Conclusion orientation `u = w` (not `w = u`) matches the paper's `⋂ = {w}` reading and is
  what the discrete helper produces most directly. Either works; be consistent.
- The `⊇` direction of the paper's equality is `nullity` + cone monotonicity and needs no field.
- Using `|y| < x` (strict) matches the paper exactly.

**Do not** use the forward-only form (`0 ≤ y < x`) even though PossibleWorlds task-51 research
S2 proved them equivalent when imposed at all states. The two-sided form is the paper's official
statement; the equivalence proof is an extra dependency on an argument that lives outside this
repo, and the two-sided form is what the `app:topology-r0` proof consumes.

---

## 6. Discrete Discharge Helper (VERIFIED — with a correction)

**Correction to the task description**: `IsSuccArchimedean` is *not* needed. The one-line proof
uses only `SuccOrder D` (for `Order.succ`) and `NoMaxOrder D` (to get `0 < Order.succ 0` via
`Order.lt_succ`). Verified working form:

```lean
theorem limit_nullity_of_succOrder [SuccOrder D] [NoMaxOrder D]
    {W : Type} {R : W → D → W → Prop} (hnull : ∀ w u, R w 0 u ↔ w = u) :
    ∀ w u, (∀ x, 0 < x → ∃ y, |y| < x ∧ R w y u) → u = w := by
  intro w u h
  obtain ⟨y, hy, hR⟩ := h (Order.succ 0) (Order.lt_succ 0)
  have h1 : |y| ≤ 0 := Order.lt_succ_iff.mp hy
  have h2 : y = 0 := abs_eq_zero.mp (le_antisymm h1 (abs_nonneg y))
  subst h2
  exact ((hnull w u).mp hR).symm
```

Also verified:
- `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D] ⊢ NoMaxOrder D`
  is discharged by `infer_instance`.
- `Int` has `SuccOrder`, `NoMaxOrder`, and `IsSuccArchimedean` instances.

**Consequence for the repo**: the existing discrete binder bundle used throughout
`SoundnessLemmas/FrameClassVariants.lean` (lines 725, 765, 804, 866, 917, 946, 968, 1008) is
`[SuccOrder D] [PredOrder D] [IsSuccArchimedean D] [IsPredArchimedean D] [Nontrivial D]`. That
bundle **already implies** everything the helper needs (`NoMaxOrder` from `Nontrivial`). So any
frame carrying the project's standard discrete binders discharges Limit Nullity with no new
hypotheses at all. Prefer stating the helper with `[SuccOrder D] [NoMaxOrder D]` (minimal) and
let the richer bundles apply it.

Recommended naming, per the task's notation decision (prefer `inv`/`⁻¹` vocabulary, never
breve/smile): the helper is about succ-orders, not converses, so no naming constraint bites
here. Suggested name: `TaskFrame.limit_nullity_of_succOrder` (the task description's
`limit_nullity_of_discrete` is also fine, but "discrete" is not a Mathlib class in this repo and
`succOrder` names the actual hypothesis).

---

## 7. Complete Instantiation Inventory and Per-Site Verdict

18 construction sites total (16 live, 2 dead in `Boneyard/`). No `TaskFrame.mk` anywhere.

### Class A — holds unconditionally, no new hypotheses

| Site | Carrier | Relation | Why it holds |
|---|---|---|---|
| `Semantics/TaskFrame.lean:173` `trivialFrame` | any `D` | `fun _ _ _ => True` | `Unit` subsingleton; `Subsingleton.elim` |
| `Examples/TemporalStructures.lean:72` `intTimeFrame` | `Int` | `True` | same |
| `Examples/TemporalStructures.lean:151` `genericTimeFrame` | any `D` | `True` | same |
| `WeakCanonical/Transfer.lean:568` `zIntervalTaskFrame` | `ℤ` | `True` (`WorldState := Unit`) | same. **Task 415 reports this as dead/deletable** (`Transfer.lean:568-687`); coordinate. |
| `ReynoldsBridge.lean:453` `zTaskFrameV2` | `ℤ` | `u = w + d` | deterministic shift, see below |
| `ReynoldsBridge.lean:671` `multiFamTaskFrame` | `ℤ` | `p.1 = q.1 ∧ q.2 = p.2 + d` | deterministic shift |
| `ChronicleMonadicBridge.lean:139` `multiFamTaskFrameGen` | any `D` | `p.1 = q.1 ∧ q.2 = p.2 + d` | deterministic shift |

**Deterministic-shift frames satisfy Limit Nullity for *any* `D`, dense included.** The
duration is recoverable from the endpoints (`y = q.2 - p.2`), so the hypothesis gives
`|q.2 - p.2| < x` for every `x > 0`, forcing `q.2 = p.2` and then `q = p`. Worth extracting as a
second reusable helper alongside the succ-order one — it covers three sites and is the shape any
future flow-frame will have (see §8).

### Class B — needs `[Nontrivial D]`

| Site | Carrier | Relation |
|---|---|---|
| `Semantics/TaskFrame.lean:187` `identityFrame` | any `D` | `w = u ∧ x = 0` |

**Why**: the antecedent `∀ x, 0 < x → …` is *vacuous* when `D` has no positive element, so
nothing can be concluded. Over a trivial duration group Limit Nullity would force `W` to be a
singleton — which is correct behaviour, and exactly why the paper's `def:frame` demands "a
**nontrivial** totally ordered abelian group". Verified: with `[Nontrivial D]` the field
discharges via `exists_ne (0 : D)` + case split on sign.

**Design decision for the plan**: either (i) add `[Nontrivial D]` to the four affected example
frames locally, or (ii) add `[Nontrivial D]` to the `TaskFrame` structure binders to match the
paper exactly. Option (ii) is more faithful and would remove the ad-hoc `[Nontrivial D]` binders
already scattered through `Metalogic/` (Soundness.lean:1066, StrongCompleteness.lean:130,
Separability.lean:97/143, FrameClassVariants.lean ×8, MCSMixedCase.lean:74,
ChronicleToCountermodelBasic.lean:834), but it is a structure-signature change touching every
`(F : TaskFrame D)` binder in the tree. **Recommend (i) for this task**, with (ii) recorded as a
follow-up — this keeps the blast radius proportionate to the task's stated scope.

### Class C — VIOLATES Limit Nullity over dense `D` (the actual work)

All of these are *duration-blind above zero*: the relation at `d > 0` does not depend on `d`.
Over a densely ordered `D` this is precisely the paper's `app:topology-r0` countermodel shape
(`w ⇒_ε u` for every `ε > 0`), so they fail the axiom whenever two distinct world states are
related.

| Site | Carrier | Relation | Dense instantiation in the live tree? |
|---|---|---|---|
| `Semantics/TaskFrame.lean:219` `natFrame` | any `D` | `d ≠ 0 ∨ w = u` | only `D := Int` (Generators.lean:150/167, TaskFrameTest, SemanticPropertyTest) |
| `Examples/TemporalStructures.lean:163` `genericNatFrame` | any `D` | same body | no |
| `Examples/TemporalStructures.lean:85` `intNatFrame` | `Int` | same body | n/a — `Int` is discrete, **holds** |
| `Tests/…/TaskFrameTest.lean:56` `customFrame` | `Int` | same body, `WorldState := Bool` | n/a — **holds** |
| `FMP/Filtration.lean:197` `RefinedFilteredTaskFrame` | any `D` | `if d = 0 then w = u else True` | via `filteredFiniteFrame` (FMP.lean:175), polymorphic |
| `FMP/FiniteModel.lean:159` `FiniteFilteredTaskFrame` | any `D` | inherits the above | polymorphic |
| `Verified/Bridge/Omega.lean:136` `regionFrame` | any `D` | `d = 0 → s = s'` | **YES** — `Omega.lean:387-388` probe it at `ℚ` and `ℝ` |
| `Algebraic/ParametricCanonical.lean:207` `ParametricCanonicalTaskFrame` | any `D` | `if d>0 then ExistsTask M N else if d<0 then ExistsTask N M else M = N` | **YES** — `Rat` at `Completeness.lean:143` and `ChronicleToCountermodelBasic.lean:839`; `ℝ` probe at `CompletenessDedekind.lean:71` |

**Verified counterexample** (the `natFrame` relation over `ℚ`), machine-checked:

```lean
example : ¬ (∀ w u : Nat, (∀ x : ℚ, 0 < x → ∃ y : ℚ, |y| < x ∧ (y ≠ 0 ∨ w = u)) → u = w) := by
  intro h
  have hcon : (1 : Nat) = 0 := by
    refine h 0 1 (fun x hx => ⟨x/2, ?_, Or.inl ?_⟩)
    · rw [abs_of_pos (by linarith)]; linarith
    · exact ne_of_gt (by linarith)
  exact absurd hcon (by decide)
```

Take `w = 0`, `u = 1`, and witness `y = x/2` for each `x > 0`. The identical argument applies
verbatim to `RefinedFilteredTaskFrame`, `regionFrame`, and `ParametricCanonicalTaskFrame`.

**Note on `regionFrame`'s dense probes**: `Omega.lean:387-388` instantiate
`regionFrame Unit (Fin 1) ℚ` and `… ℝ`. Its `WorldState := W × (Set ι × Set ι)`, so at
`W = Unit, ι = Fin 1` the carrier has 4 elements — **not** a subsingleton. Those two `example`
lines will genuinely fail once `limit_nullity` is a field. They are elaboration probes, so
deleting or re-carrier-ing them is cheap, but they must not be overlooked.

### Class D — dead, ignore

`Boneyard/ChainCompleteness/Bundle/SuccChainTaskFrame.lean:95` and
`Boneyard/StrictSemanticsLegacy/Bundle/CanonicalConstruction.lean:267`. Both use the obsolete
field name `task_rel` and would not elaborate today. Nothing outside `Boneyard/` imports
`FormalSystem.Boneyard.*`, and `lakefile.lean`'s default target roots only `FormalSystem`.

`Tests/BimodalTest/Semantics/SemanticBenchmark.lean:50` (`benchFrame`) references the
nonexistent `TaskFrame.trivial_frame` and is explicitly excluded at `Tests/BimodalTest.lean:75`
("do not compile at all"). Treat as dead despite not being under `Boneyard/`.

### Duplication worth collapsing (optional)

`Examples.intTimeFrame` / `Examples.genericTimeFrame` / `Transfer.zIntervalTaskFrame` are
byte-identical to `Semantics.TaskFrame.trivialFrame`; `Examples.intNatFrame` /
`Examples.genericNatFrame` / `TaskFrameTest.customFrame` copy `natFrame`'s proof body verbatim
(including the full `forward_comp`/`converse` tactic blocks). Adding a fifth field means writing
the same `limit_nullity` proof six times unless these are re-expressed as thin wrappers. The
plan should decide; re-expressing as wrappers is the lower-total-effort path and reduces future
drift, but it touches `Examples/` which has a pedagogical mandate to be self-contained.

---

## 8. The Critical Obstruction: `ParametricCanonicalTaskFrame` at Dense `D`

This is the one obligation that cannot be discharged mechanically.

### 8.1 Why it fails

`ParametricCanonical.lean:92-96`:

```lean
def ParametricCanonicalTaskRel (M : ParametricCanonicalWorldState fc) (d : D)
    (N : ParametricCanonicalWorldState fc) : Prop :=
  if d > 0 then ExistsTask M.val N.val
  else if d < 0 then ExistsTask N.val M.val
  else M = N
```

For any `d > 0` this is `ExistsTask M.val N.val` — no dependence on `d`. So for any distinct
MCSs `M ≠ N` with `ExistsTask M N`, and any `x > 0`, pick `y = x/2`: `|y| < x` and
`TaskRel M y N`. Limit Nullity is refuted. This is *exactly* the paper's own countermodel at
`possible_worlds.tex:3109`:

> taking $\D$ to be the reals and $W = \set{v, w, u}$ where $w \Rightarrow_\varepsilon u$ for
> every $\varepsilon > 0$ … the resulting structure satisfies *Nullity* and
> *Compositionality* under the converse convention … and yet
> $\bigcap_{x > 0} (w)_x \supseteq \set{w, u}$ violates *Limit Nullity*.

Over `ℤ` it is fine (take `x = 1`; `|y| < 1` forces `y = 0`, then `nullity_identity`).

### 8.2 Why "just add discrete binders" is not available

`ParametricCanonicalTaskFrame Rat` is the witness of the **live** theorem
`countermodel_dense_enriched` (`BXCanonical/Completeness.lean:133-160`), whose statement is
`∃ (F : TaskFrame Rat) …`, feeding both `completeness` and `completeness_dense`. It is also the
witness at `ChronicleToCountermodelBasic.lean:839` and is elaboration-probed at `ℝ`
(`CompletenessDedekind.lean:71`). Adding `[SuccOrder D] [NoMaxOrder D]` to the frame breaks all
of these — `ℚ` and `ℝ` have no `SuccOrder`. That is a build break, not an option.

### 8.3 The sorry-free repair (and why it belongs with task 415)

Change the carrier from `MCS` to `MCS × D` and make the relation a deterministic shift with an
`ExistsTask` side condition:

```lean
TaskRel := fun p d q =>
  q.2 = p.2 + d ∧
  (0 < d → ExistsTask p.1.val q.1.val) ∧
  (d < 0 → ExistsTask q.1.val p.1.val) ∧
  (d = 0 → p.1 = q.1)
```

- `nullity_identity`: `d = 0` gives `q.2 = p.2` and `p.1 = q.1`, hence `p = q`. ✓
- `forward_comp`: the shift component is additive; the `ExistsTask` component needs transitivity
  of `ExistsTask`, which `parametric_task_rel_forward_comp` already establishes. ✓
- `converse`: symmetric by construction. ✓
- `limit_nullity`: **free** — this is a Class-A deterministic-shift frame, so the argument in §7
  applies unconditionally, dense `D` included. ✓

**This is the same construction task 415 already proposes.** Its report
(`specs/415_.../reports/01_completeness-maximal-history-rebase.md:209-216`) specifies:

```lean
def bundleFlowFrame (B : BFMCS (fc := fc) D) : TaskFrame D where
  -- nullity_identity / forward_comp / converse: same one-line algebra as multiFamTaskFrame
```

with `WorldState := FamIdx × D` — i.e. a deterministic-shift carrier. **Task 415's planned
refactor resolves this task's hardest Limit Nullity obligation as a side effect.** That report
also independently flags that the parametric canonical frame "cannot survive Omega removal"
(§4 of that report, line 186) and that it has junk maximal histories — so it is already slated
for replacement on other grounds.

### 8.4 Recommendation

**Do not do the carrier change inside this task.** Ripple: 14 references to
`ParametricCanonicalWorldState` across `ParametricCanonical.lean` and `ParametricHistory.lean`,
plus `ParametricTruthLemma.lean:109`, plus the three witness sites. Doing it here duplicates
415's work and risks two divergent refactors of the same definitions.

Instead the plan should pick one of:

- **(A) Sequence after 415** — declare a dependency, land `limit_nullity` for Classes A/B and
  the tractable Class-C sites now, and leave `ParametricCanonicalTaskFrame` as the single
  remaining hole, marking this task `[BLOCKED]` on 415 at that phase boundary. Honest, but
  leaves the tree non-compiling in between, which is unacceptable — so this only works if the
  field addition itself is also deferred.
- **(B) Land the field last** — do all docstring/LaTeX/anchor work and the helper lemmas first
  (they are independently valuable and non-breaking), then add the `limit_nullity` field only
  once 415 has replaced the parametric canonical frame. **Recommended.**
- **(C) Do the carrier change here** — largest scope, highest collision risk with 415, but
  self-contained. Choose only if the orchestrator judges 415 to be far off.

Option (B) is recommended because it keeps every phase green and puts the field addition on the
far side of the one dependency that makes it hard. **A decision gate belongs in the plan**, not
a silent choice.

---

## 9. New Derived Result: Limit Nullity on Finite Frames (VERIFIED)

Machine-checked (only a `push_neg` deprecation warning):

```lean
theorem finite_uniform_radius [Nontrivial D] {W : Type} [Fintype W]
    (R : W → D → W → Prop)
    (hlim : ∀ w u, (∀ x, 0 < x → ∃ y, |y| < x ∧ R w y u) → u = w)
    (w : W) : ∃ x : D, 0 < x ∧ ∀ u y, |y| < x → R w y u → u = w
```

**Reading**: on a frame with finitely many world states, Limit Nullity upgrades from a
pointwise limit statement to a *uniform* positive radius `x` around each `w` inside which
nothing but `w` is reachable. Proof: for each `u ≠ w` the axiom's contrapositive supplies a
radius `x_u`; take the `Finset.inf'` over the finite carrier.

**Consequences the plan should use**:

1. **Any finite frame satisfying Limit Nullity over a dense `D` is temporally rigid.** A
   `WorldHistory` through `w` at time `t` is constant on `(t - x_w, t + x_w)`, so over a
   densely ordered domain histories are locally constant. This is not a bug — it is the correct
   content of the axiom — but it means the filtration/FMP frames (`RefinedFilteredTaskFrame`,
   `FiniteFilteredTaskFrame`, `regionFrame`) **cannot** meaningfully be dense-polymorphic once
   the axiom lands.
2. This independently corroborates **task 417** ("semantic FMP finite worldstate over `ℤ`"):
   restricting FMP to `ℤ` is not a convenience, it is forced by Limit Nullity + finiteness.
   Cross-reference in the plan.
3. It also justifies deleting the `regionFrame` dense probes (`Omega.lean:387-388`) rather than
   trying to repair them.

This lemma is a worthwhile deliverable in its own right and is cheap (proof above is complete).
Suggested home: `FormalSystem/Semantics/TaskFrame.lean`, as
`TaskFrame.exists_uniform_radius_of_finite`.

---

## 10. `latex/subfiles/02-Semantics.tex` Restatement Spec

**Current state** (lines 25–31, the whole definition):

```latex
\begin{definition}[Task Frame]
A \textbf{task frame} over temporal type $D$ is a triple
$\taskframe = (\worldstate, D, {\taskto{}})$ satisfying:
\begin{enumerate}
  \item \textbf{Nullity}: For all $w : \worldstate$, we have $w \taskto{0} w$.
  \item \textbf{Compositionality}: For all $w, u, v : \worldstate$ and $x, y : D$,
        if $w \taskto{x} u$ and $u \taskto{y} v$, then $w \taskto{x+y} v$.
\end{enumerate}
\end{definition}
```

Three divergences from *both* the paper and the live tree: (a) one-way Nullity instead of the
iff; (b) unrestricted mixed-sign Compositionality — the very axiomatization TaskFrame.lean's own
notes call impossible for nondeterministic relations; (c) no Limit Nullity, no converse
convention, no cone notation.

**Structural facts for the implementer**:
- Subsection spans lines 6–35; primitives table at 13–23; gloss at 33–35. File is 137 lines.
- Header: `\documentclass[../BimodalReference.tex]{subfiles}` (line 1), `\begin{document}`
  (line 2). **No local `\usepackage`** — everything inherits from the master preamble.
- `definition` env declared at `latex/BimodalReference.tex:49` as
  `\newtheorem{definition}{Definition}[section]`.
- The definition carries **no `\label{}`**; grep confirms the entire file has zero `\label`
  commands, so nothing cross-references it. Adding `\label{def:frame}` is safe and advisable.
- Available macros (`latex/assets/bimodal-notation.sty`): `\taskframe` → `\mathcal{F}` (51),
  `\worldstate` → `W` (53), `\taskto[1]` → `\Rightarrow_{#1}` (56).
- **Missing macros** that the restatement needs: positive cone `D^+`, the cone `(w)_x`, and (if
  a symbol is wanted) the converse. Either add to `bimodal-notation.sty` or write inline.
- Build: master uses XeLaTeX via `latexmkrc` (`$pdf_mode = 5`, `$out_dir = 'build'`) with
  `ensure_path('TEXINPUTS', "$source_dir/assets//")`. Standalone compile from `latex/subfiles/`
  therefore needs `TEXINPUTS=../assets:` as the task states.

**Required content** — restate as: nonempty `\worldstate`; nontrivial totally ordered abelian
group `D`; primitive relation on the positive cone `D^+ = \{x \in D : x \geq 0\}`; the converse
convention; the cone `(w)_x`; then iff-Nullity, positive-cone Compositionality, Limit Nullity;
then a remark that Reflection and backward composition are derived and mixed-sign composition is
inexpressible. The primitives table at 13–23 also needs a `D^+` row and a corrected type for the
task relation.

**Notation constraint (user decision, 2026-07-28)**: any explicit converse operation is written
`$\Rightarrow^{-1}$` (and `$R^{-1}$` for abstract relations) — **never** `$\breve{R}$` or
`$R^{\smallsmile}$`. Note the paper itself currently states the converse convention with
subscript negation only and introduces no operator symbol, so the safest restatement introduces
none either; the constraint binds only if a symbol is added.

---

## 11. Lean Notation / Naming Constraints

Per the same user decision: prefer `inv`/`⁻¹` vocabulary in Lean (e.g. `TaskRel.inv`,
consistent with Mathlib's `Inv`), never breve/smile. **Applicability check**: the current tree
introduces no converse *operation* — `converse` is a field asserting an iff, not a defined
operator. So no rename is forced by this task. If the implementation introduces a cone
abbreviation or a converse operator, the constraint binds then. Recommend leaving the field name
`converse` (it names the paper's "converse convention" verbatim) and recasting only its
docstring.

---

## 12. Optional Stretch Goal: the T1 Theorem

**Assessment: defer.** Grep confirms there is **no topology anywhere** in
`FormalSystem/` — no `TopologicalSpace` instance, no cone construction, no closure operator.
Formalizing `app:topology-r0` requires first building the cone topology (`(w)_x` as a basis,
proving it *is* a basis, instantiating `TopologicalSpace`), which is a self-contained
development of its own. The paper's proof is one line *given* that infrastructure
(`possible_worlds.tex:3125-3129`), but the infrastructure is the work.

The `finite_uniform_radius` lemma in §9 is a strictly better sanity check for the same cost
bracket: it is already proved, it is topology-free, and it has direct consequences for tasks 415
and 417. Recommend substituting it for the stretch goal.

---

## 13. Risks and Open Questions

| # | Risk | Severity | Mitigation |
|---|---|---|---|
| 1 | `ParametricCanonicalTaskFrame` at `Rat`/`ℝ` cannot satisfy Limit Nullity without a carrier change (§8) | **High** | Explicit decision gate in the plan; recommended option (B) — land the field only after 415 |
| 2 | `regionFrame` dense probes at `Omega.lean:387-388` will fail (carrier has 4 elements, not a subsingleton) | Medium | Delete the two probes or re-carrier them; cheap either way |
| 3 | FMP filtration frames must lose dense polymorphism (§9) | Medium | Coordinate with task 417, which is already moving FMP to `ℤ` |
| 4 | `natFrame` is the `SampleableExt` generator at `Generators.lean:150/167` | Low | Uses `D := Int` throughout; discrete restriction is transparent to the tests. Verified |
| 5 | Six duplicated frame bodies each need their own `limit_nullity` proof | Low | Re-express `Examples/` and `customFrame` as wrappers, or accept the duplication |
| 6 | `[Nontrivial D]` on the structure vs. on the examples (§7 Class B) | Low | Recommend per-example binders now; structure-level change as a follow-up |
| 7 | Paper's "nonempty `W`" is still unenforced in Lean | Low | Pre-existing, out of scope; record in the docstring rather than fixing silently |

**Open question for the user / orchestrator**: is task 415 close enough that option (B) in §8.4
is viable, or should this task absorb the carrier change (option C)? This determines whether the
`limit_nullity` field lands in this task at all. It should not be resolved by an implementation
agent mid-phase.

---

## 14. Recommended Phase Decomposition

Sized so each phase ends on a green `lake build` and produces file writes, not analysis.

| Phase | Content | Breaking? |
|---|---|---|
| 1 | Re-anchor all stale `def:frame, line 1835` citations (§4: TaskFrame.lean 17/68/90, TemporalStructures.lean 20/57, architecture.md 454, API_REFERENCE.md 147) to `possible_worlds.tex:2423`. | No |
| 2 | Recast `TaskFrame.lean` docstrings: `converse` as the definitional converse convention (not a temporal-symmetry axiom); invert the `Axiomatization Notes` block from divergence to agreement, citing the lax law (`:964`) and the nondeterminism-collapse argument (`:957-959`); note that Reflection and backward composition are derived and mixed-sign composition inexpressible. | No |
| 3 | Add the two reusable helpers as standalone theorems (not yet fields): `limit_nullity_of_succOrder` (§6) and the deterministic-shift version (§7 Class A). Both proofs are given verbatim above and are verified. | No |
| 4 | Add `TaskFrame.exists_uniform_radius_of_finite` (§9, proof verified). Substitutes for the T1 stretch goal. | No |
| 5 | Rewrite `latex/subfiles/02-Semantics.tex` lines 6–35 per §10; add `\label{def:frame}`; add any needed notation macros; verify standalone compile with `TEXINPUTS=../assets: pdflatex` from `latex/subfiles/`. | No |
| **Gate** | **Decide §8.4 option (A)/(B)/(C).** Requires orchestrator or user judgment on task 415's timing. | — |
| 6 | Add the `limit_nullity` field (§5) and discharge Classes A and B (§7): 7 Class-A sites, `identityFrame` with `[Nontrivial D]`. | Yes |
| 7 | Discharge tractable Class C: restrict `natFrame`/`genericNatFrame` to `[SuccOrder D] [NoMaxOrder D]`; `intNatFrame`/`customFrame` at `Int` need no restriction; delete or re-carrier the `regionFrame` dense probes; restrict the filtration frames in coordination with task 417. | Yes |
| 8 | `ParametricCanonicalTaskFrame` per the gate decision. | Yes |

Phases 1–5 are entirely non-breaking and independently valuable; they can land regardless of how
the gate resolves.

---

## 15. Zero-Debt Statement

Every obligation identified has a sorry-free discharge path, and all the non-trivial ones are
machine-verified above. The single hard obligation (§8) has a known sorry-free repair which
another in-flight task already plans; the recommendation is to **sequence around it**, not to
defer it with a placeholder. No `sorry`, no new axiom, and no vacuous definition is required or
recommended anywhere in this plan. If the gate in §14 resolves such that phase 8 cannot proceed,
the correct outcome is `[BLOCKED]` on task 415 — not a placeholder.
