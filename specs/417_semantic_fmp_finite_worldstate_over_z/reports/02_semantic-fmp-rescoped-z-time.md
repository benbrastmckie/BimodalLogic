# Research Report: Semantic FMP over a Fixed Carrier (finite WorldState over D = ℤ)

- **Task**: 417 - `semantic_fmp_finite_worldstate_over_z`
- **Started**: 2026-08-12T00:00:00Z
- **Completed**: 2026-08-12T00:00:00Z
- **Effort**: high (multi-phase; two sub-results already de-risked to machine-checked proofs)
- **Dependencies**: 414 (totality semantics — landed), 420 (four-axiom `TaskFrame` — landed), 438 (paper reconciliation — landed)
- **Sources/Inputs**:
  - `scripts/check-paper-definitions.sh` (exit 0, case (a) silent pass) and `specs/paper-definitions-of-record.md`
  - Paper anchors (read-only ground truth): `def:frame`, `def:frame#Seriality`, `def:frame#Limit`, `def:frame#Spherical`, `def:directed`, `def:task-relation`, `def:world-history`, `def:frame-properties`, `def:constraints`, `lem:constraint`, `lem:nesting`, `lem:nonempty`, `lem:step`, `thm:extension`, `cor:occurrence`, `cor:spherical-finite`, `cor:tm-completeness`, `cor:tm-decidability`, `def:TMplus-f`, `CO`, `DF`
  - Lean tree: `FormalSystem/Semantics/**`, `FormalSystem/Metalogic/Decidability/**`
  - Superseded round-1 report: `specs/417_semantic_fmp_finite_worldstate_over_z/reports/01_semantic-fmp-finite-worldstate.md`
- **Artifacts**: this report
- **Standards**: status-markers.md, artifact-management.md, tasks.md, report-format.md

## Executive Summary

- **The task's stated FMP target is refuted by the paper itself, and the paper names the repair.**
  "Satisfiable over the Discrete class ⇒ satisfiable with finite `W` over `D = ℤ`" is **false**:
  `cor:tm-decidability`'s current proof gives the counterexample (`CO` is refutable on the
  discrete order `ℤ ×_lex ℤ` yet valid in every model over `D = ℤ`). The repaired, paper-stated
  target is **ℤ-time**, not the full Discrete class. Lean is unaffected: `ValidDiscrete`
  (`Validity.lean:222`) already carries `[SuccOrder] [PredOrder] [IsSuccArchimedean]
  [IsPredArchimedean] [Nontrivial]`, which is ℤ-time by Hölder — only the task description's
  paper-side wording is wrong.
- **`cor:spherical-finite` is now a standalone paper corollary, and its Lean transcription is
  machine-checked in this pass** (12 lines, choice-free, `Set.Finite.exists_minimal` +
  directedness). The task description's verbatim Spherical quote is an `%% OLD:` line in the
  live paper; the argument survives unchanged, relocated.
- **The open Seriality question is answered NEGATIVE and machine-checked.** Seriality is
  independent of `nullity_identity` + `Compositional` + `converse` + `Limit` + `Spherical` over
  `D = ℤ`, even at `W = Unit`. It is a genuine obligation for any frame this task builds; over ℤ
  it amounts to the one-step relation being serial in both directions.
- **The task's "rebase surface" CAUTION is a negative finding.** No two-state universal-relation
  frame exists in the Lean tree. All three universal-relation frames are `Unit`-carriered and
  discharge *Limit* by `limit_of_subsingleton`. Conversely, the paper's *replacement*
  off-zero-universal witness frame already exists in Lean as `customFrame : TaskFrame Int` with
  `WorldState := Bool` — in `Tests/`, and worth promoting.
- **The finite-`W`-over-ℤ frame already exists; the truth lemma is the whole remaining job.**
  `FiniteFilteredTaskFrame ℤ φ` (`FMP/FiniteModel.lean:159`) is a genuine `FiniteTaskFrame ℤ`.
  Nothing in `FMP/` mentions `TruthAt` — round 1's premise check still holds.
- **Decidable model checking needs a new computational presentation.** `FiniteTaskFrame` carries
  `Finite WorldState`, not `Fintype`, so it cannot drive `decide`; `Semantics/` contains zero
  `Decidable` instances; and `validity_decidable` has since been **deleted** as vacuous
  (`Correctness.lean:74-104`), superseding round 1's finding that it exists.
- A **ℤ-frame normal form** (`TaskFrame ℤ` ≅ a bi-serially-closed one-step relation) makes both
  halves tractable and is the recommended spine of the plan; its key arithmetic lemma is
  machine-checked below.

## Context & Scope

Two deliverables: (1) a `TruthAt`-connected finite model property over a fixed carrier, replacing
the syntactic closure-MCS FMP theorems in `FormalSystem/Metalogic/Decidability/FMP/`; (2) decidable
model checking for the finite-`W`-over-ℤ presentation. Both are stated against the totality-based,
Ω-free semantics that task 414 landed and the four-axiom `TaskFrame` that task 420 landed. No edits
under `/home/benjamin/Philosophy/Papers/`.

**Paper-definitions lint**: `bash scripts/check-paper-definitions.sh` exits 0 with no output —
case (a), silent pass. All 26 tracked anchors are current. Proceeding was authorized.

## Findings

### 1. The stated target is refuted; the paper names the repaired target — REFUTATION

The task description's target predicate is "any formula satisfiable over the **Discrete** class is
satisfiable in a model with finite WorldState over `D = ℤ`". The paper's own `cor:tm-decidability`
proof now refutes exactly this, having deleted its former blanket premise as false. Verbatim, the
deleted line is retained in the paper as an `%% OLD:` comment:

> `%% OLD:   The finite model property makes the non-theorems recursively enumerable as well: every non-theorem fails in some model with finite $W$ over $D = \Z$, and such models may be effectively enumerated and model-checked.`

and the live replacement text reads, verbatim:

> "No finite model property over $D = \Z$ can hold uniformly across all five systems, and indeed
> never could have, since $\Z$ is a discrete carrier bearing no relation to the dense or complete
> frame classes of \textbf{TM}$_\textsc{d}$, \textbf{TM}$_\textsc{c}$, and \textbf{TM}$_\textsc{dc}$.
> Even restricted to the discrete systems, the premise fails: \textbf{\aref{DF}} is a non-theorem
> of \textbf{TM}, \textbf{TM}$_\textsc{d}$, \textbf{TM}$_\textsc{c}$, and \textbf{TM}$_\textsc{dc}$
> (each is sound over a class containing a dense or $\R$ member on which \textbf{\aref{DF}} fails)
> yet is valid in every model over $D = \Z$, and \textbf{\aref{CO}} is a non-theorem of
> \textbf{TM}$_\textsc{f}$ (witnessed by the non-Archimedean discrete order
> $\Z \times_{\mathrm{lex}} \Z$, \textbf{\ref{def:TMplus-f}}) yet is likewise valid in every model
> over $D = \Z$."

The `CO` clause is the one that bites this task specifically. `CO` (`\aitem{CO}`, verbatim:
`$\always(\Past\varphi \rightarrow \future\Past\varphi) \rightarrow (\Past\varphi \rightarrow \Future\varphi)$`)
is refutable on `ℤ ×_lex ℤ`, which **is** a Discrete frame under `def:frame-properties`, verbatim:

> "\item[\sc Discrete] if for any $x \in D$, whenever there exists $y > x$, there is a least such
> $y' > x$ satisfying $z \geq y'$ for all $z > x$."

So `¬CO` is satisfiable over the Discrete class and unsatisfiable over `D = ℤ` — with or without
finite `W`. The implication the task asks to prove has a counterexample.

The paper's repaired scoping, verbatim, is the target this task should adopt:

> "A repaired finite model property would need to be class-specific --- finite $W$ over $\Z$-time
> for the discrete systems, and analogous constructions for the dense and complete classes,
> ranging over effective non-Archimedean carriers such as $\Z \times_{\mathrm{lex}} \Z$ rather
> than $\Z$ alone --- none of which is currently established."

and, naming this task in the paper's own prose:

> "A verified \textit{sound} tableau procedure exists in the Lean 4 repository, and the semantic,
> truth-connected finite model property for the $\Z$-time discrete case is the target of dedicated
> ongoing formalization; no decidability theorem is machine-checked at present."

`def:TMplus-f` supplies the Hölder step that makes "ℤ-time" precise, verbatim:

> "By H\"{o}lder's theorem, a nontrivial \textit{discrete} Archimedean totally ordered abelian
> group is isomorphic to $\Z$, so the successor-Archimedean discrete class to which
> \textbf{BX}$_f$ and \textbf{TM}$^+_\textsc{f}$ are sound and complete is exactly $\Z$-time."

**Lean is unaffected.** `ValidDiscrete` (`FormalSystem/Semantics/Validity.lean:222`) quantifies over
`[SuccOrder D] [PredOrder D] [IsSuccArchimedean D] [IsPredArchimedean D] [Nontrivial D]` — the
successor-Archimedean class, i.e. ℤ-time, **not** the paper's broader `def:frame-properties`
Discrete. The repo has, by accident of its own binder choice, always been on the repaired side of
this distinction. Only the task description's paper-side framing needs correcting.

**Consequential**: `cor:tm-decidability` no longer asserts decidability at all. Its live statement
is "Whether \textbf{TM}, \textbf{TM}$_\textsc{f}$, \textbf{TM}$_\textsc{d}$, \textbf{TM}$_\textsc{c}$,
and \textbf{TM}$_\textsc{dc}$ are decidable is open." The task description's motivating premise
("the paper's decidability corollary proof text cites [the semantic FMP]", "to back the paper's
enumeration argument") describes text the paper has since deleted. The task's *deliverable* is
still wanted — the paper explicitly names it as ongoing work — but it no longer backs a claimed
decidability theorem; it is a step toward an open one.

### 2. `cor:spherical-finite` — new standalone corollary, transcription machine-checked

The finite-`W` Spherical argument the task description quotes has been promoted out of the two
appendix proof sites into its own corollary. The task description's verbatim quote is now an
`%% OLD:` line at both sites; the live text at each is "\textit{Spherical} holds by
\textbf{\ref{cor:spherical-finite}} since $W$ is finite." The mathematics is unchanged; the
transcription target moved.

`cor:spherical-finite`, verbatim:

```latex
\begin{Cthm} \label{cor:spherical-finite}
	Every frame $\F = \tuple{W, \D, \Rightarrow}$ with finite $W$ satisfies \textit{Spherical}, choice-free.
\end{Cthm}
```

Its proof, verbatim (this is what gets transcribed):

> "Let $\mathcal{S}$ be a directed family of nonempty fibers and segments, as in
> \textbf{\ref{def:directed}}. Since $W$ is finite, every member of $\mathcal{S}$ is a subset of
> $W$, so $\mathcal{S}$ has finitely many distinct members. Directedness gives, for any two members
> of $\mathcal{S}$, some member of $\mathcal{S}$ contained in their intersection, and iterating this
> over the finitely many members yields a $\subseteq$-least member $S^* \in \mathcal{S}$ with
> $S^* \subseteq S$ for every $S \in \mathcal{S}$. Since $S^*$ is itself a member of $\mathcal{S}$,
> it is nonempty, and $S^* \subseteq \bigcap \mathcal{S} \subseteq S^*$, so
> $\bigcap \mathcal{S} = S^* \neq \emptyset$."

**Machine-checked transcription** (verified green this pass via `lean_run_code` against the live
tree; zero diagnostics). Note it consumes only finiteness, directedness and member-nonemptiness —
the `IsFiber ∨ IsSegment` disjunct is never used, exactly as the paper's own `%% CHANGE (sigma-elim)`
comment records ("the finite-$W$ argument is indifferent to the kind of member"):

```lean
theorem spherical_of_finite {W : Type} [Finite W] (R : W → D → W → Prop) :
    TaskFrame.Spherical R := by
  intro S hdir hmem
  obtain ⟨hne, hd⟩ := hdir
  obtain ⟨Sstar, hStar⟩ := (Set.toFinite S).exists_minimal hne
  obtain ⟨hStarMem, hStarMin⟩ := hStar
  have hsub : ∀ T ∈ S, Sstar ⊆ T := by
    intro T hT
    obtain ⟨S', hS'mem, hS'sub⟩ := hd Sstar hStarMem T hT
    have h1 : S' ⊆ Sstar := fun x hx => (hS'sub hx).1
    have h2 : Sstar ⊆ S' := hStarMin hS'mem h1
    exact fun x hx => (hS'sub (h2 hx)).2
  obtain ⟨x, hx⟩ := (hmem Sstar hStarMem).2
  exact ⟨x, fun T hT => hsub T hT hx⟩
```

This belongs in `FormalSystem/Semantics/TaskFrame.lean` beside the existing family
`spherical_of_subsingleton` (:890), `spherical_of_permissive` (:1003), `spherical_of_eq` (:1052).
It **subsumes** `spherical_of_subsingleton` and, for finite carriers, `spherical_of_eq` — and it is
reusable by every sibling task that must discharge Spherical for a finite-carrier frame (415, 421,
427 per their descriptions). Its value exceeds this task's own scope; it should land early.

### 3. Seriality over ℤ — OPEN QUESTION ANSWERED NEGATIVE, machine-checked

The task description flags as open: "Whether SERIALITY is also automatic over `D = ℤ` … has not
been checked." It is **not** automatic, and finiteness does not rescue it. Counterexample: `W = Unit`
over `D = ℤ` with `R w d u := (d = 0)`. Machine-checked this pass (`lean_run_code`, zero diagnostics):

```lean
example : ∃ (R : Unit → ℤ → Unit → Prop),
    (∀ w u, R w 0 u ↔ w = u) ∧
    TaskFrame.Compositional R ∧
    (∀ w d u, R w d u ↔ R u (-d) w) ∧
    (∀ w u, (∀ x : ℤ, 0 < x → ∃ y, |y| < x ∧ R w y u) → u = w) ∧
    TaskFrame.Spherical R ∧
    ¬ TaskFrame.Serial R
```

All five non-Seriality conditions hold; `Serial` fails at `x = 1`. So Seriality is independent of
the rest of the `TaskFrame` field set over ℤ, at a one-element carrier. Consistent with
`cor:occurrence` (this frame's `H_F` is empty) and with `cor:tm-completeness`'s transfer footnote,
verbatim: "Since \textit{Occurrence} implies \textit{Seriality}, the \textit{Seriality} check comes
free wherever \textit{Occurrence} is already verified, and \textit{Spherical} holds automatically
whenever the frame in question has finite $W$ by \textbf{\ref{cor:spherical-finite}}; an infinite-$W$
frame would raise a genuine further obligation." Seriality is free *from Occurrence*, never *from ℤ*.

**Practical consequence**: in the ℤ normal form of Finding 5, Seriality is exactly "the one-step
relation `R₁` is serial in both directions" (`∀ w, ∃ u, R₁ w u` and `∀ w, ∃ v, R₁ v w`) — a
two-line obligation on any construction, and the *only* one of the four axioms that is not free.

### 4. Axiom-discharge status for a finite-`W`-over-ℤ frame

| `TaskFrame` field | Over `D = ℤ`, finite `W` | Discharge |
|---|---|---|
| `nonempty : Nonempty WorldState` | obligation | trivial for any concrete carrier |
| `nullity_identity : ∀ w u, TaskRel w 0 u ↔ w = u` | obligation | free in the normal form (`R₁⁰ = Eq`) |
| `comp : Compositional TaskRel` | obligation | free in the normal form (`iter_add`, below) |
| `converse : ∀ w d u, TaskRel w d u ↔ TaskRel u (-d) w` | obligation | free by construction |
| `serial : Serial TaskRel` | **genuine obligation** (Finding 3) | `R₁` bi-serial |
| `limit` | **free** | `TaskFrame.limit_of_succOrder` — one line |
| `spherical` | **free** | `spherical_of_finite` (Finding 2) — one line |

**Stale name in the task description**: `TaskFrame.limit_nullity_of_succOrder` does not exist.
`grep -rn "limit_nullity" --include=*.lean` returns zero hits. The live declarations are
`TaskFrame.limit_of_succOrder` (`TaskFrame.lean:673`) and `TaskFrame.limit_of_shift` (`:701`).
`TaskFrame.exists_uniform_radius_of_finite` (`:752`) keeps its name. The task description's
substantive claim — that the helper is stated against a bare relation and discharges the field in
one line — is confirmed:

```lean
theorem limit_of_succOrder [SuccOrder D] [NoMaxOrder D]
    {W : Type} {R : W → D → W → Prop} (hnull : ∀ w u, R w 0 u ↔ w = u) :
    ∀ w u, (∀ x, 0 < x → ∃ y, |y| < x ∧ R w y u) → u = w
```

**Why the move to ℤ is forced, not chosen** — `TaskFrame.lean:735-743`, on
`exists_uniform_radius_of_finite`, records it verbatim: "over a dense duration domain histories are
locally constant. That is the correct content of the axiom, not a defect — but it means the
filtration and FMP frames cannot remain dense-polymorphic once *Limit* is carried as a frame axiom.
The move of FMP to `ℤ` is therefore forced by the axiom rather than being a convenience."

### 5. Recommended spine: the ℤ-frame normal form

Over `D = ℤ` the whole frame collapses to a single finite relation. Derivation:

- **`⇒₀` is the identity.** Carried directly as the `nullity_identity` field. (In the paper this is
  the ℤ-instance of *Limit*: `(w)_1 = ⋃_{|y| < 1} Fib(w, y) = Fib(w, 0)` since `|y| < 1` forces
  `y = 0`, and the cone family is increasing in `x`, so `⋂_{x>0} (w)_x = Fib(w, 0)`; *Limit* then
  says `Fib(w,0) = {w}`. Lean carries the same content as a field plus `limit_of_succOrder`.)
- **`⇒ₙ = R₁ⁿ` for `n ≥ 0`**, by induction from `Compositional` at `x = n`, `y = 1`.
- **Negative durations** are the `converse` field.
- **`H_F` = bi-infinite `R₁`-paths**: `τ : ℤ → W` with `R₁ (τ n) (τ (n+1))` for all `n`; the
  all-pairs `respects_task` condition follows by composition.

Conversely, any `R₁ : W → W → Prop` that is serial in both directions yields a `TaskFrame ℤ`.
The arithmetic core is machine-checked this pass (`lean_run_code`, zero diagnostics):

```lean
def iter {W : Type} (R : W → W → Prop) : ℕ → W → W → Prop
  | 0 => Eq
  | n+1 => fun w u => ∃ v, iter R n w v ∧ R v u

theorem iter_add {W : Type} (R : W → W → Prop) (m n : ℕ) (w u : W) :
    iter R (m + n) w u ↔ ∃ v, iter R m w v ∧ iter R n v u
```

Three payoffs:

1. **Frame construction becomes cheap.** Building a finite-`W`-over-ℤ frame reduces to exhibiting a
   bi-serial relation on a `Fintype`; six of seven fields are then boilerplate.
2. **`□` is a model constant.** `TaskRel` is time-homogeneous, so `H_F` is closed under time shift
   (`WorldHistory.isTotal_timeShift`, `WorldHistory.lean:486`). Hence `TruthAt M τ t (φ.box)` is
   independent of both `τ` and `t`. This removes the hardest-looking clause from the truth-lemma
   induction: the box facts of a model form a single finite set, computed once.
3. **Model checking becomes ω-automata-shaped.** Truth along a bi-infinite path in a finite graph,
   with a globally-constant `□`. Eventualities (`untl`/`snce`) are handled by pigeonhole on `ℤ`.

Round 1's worry that the box clause is "an uncountable set even for finite `W`" is dissolved by
payoff 2 — the set is uncountable, but the predicate is constant on it.

### 6. What exists in the Lean tree, and what the gap actually is

**Premise re-confirmed.** `FormalSystem/Metalogic/Decidability/FMP/` still contains zero occurrences
of `TruthAt` across all five files. Its theorems are about MCS membership (`φ ∈ S.carrier`).

**The finite frame over ℤ already exists.** `FMP/FiniteModel.lean:159`:

```lean
noncomputable def FiniteFilteredTaskFrame [SuccOrder D] [NoMaxOrder D] (phi : Formula) :
    FiniteTaskFrame D where
  toTaskFrame := RefinedFilteredTaskFrame D phi
  finite_world := FilteredWorld.finite phi
```

with `FilteredWorld phi := Quotient (ClosureMCSSetoid phi)` (`Filtration.lean:159`). It is the only
live `FiniteTaskFrame` construction in the library (the file says so at `:177`). So the object this
task needs is already built and already carries all four axioms; **the entire remaining gap is the
truth lemma** relating `TruthAt` on it to closure-MCS membership.

**The extension chain is landed**, which supplies the truth lemma's box-clause prerequisite:
`PartialHistory.occurrence F w x` (`Semantics/Extension/Extension.lean:231`) is `cor:occurrence` in
frame-intrinsic form — for any world state `w` and time `x` there is a total history through `w` at
`x`. Also present: `step` (`Extension/Step.lean:119`, the sole *Spherical* application site),
`extension` (`Extension.lean:184`), `hF_nonempty` (`:244`).

**Other ℤ assets, and why they do not substitute.** `Verified/Bridge/IntTruth.lean:889` has a real
`TruthAt`-connected truth lemma over ℤ (`branchTruthAt`), but its carrier is
`regionFrame WorldIndex (BranchTime b) ℤ`, i.e. `WorldState = ℕ × ℤ` — infinite. Worse for reuse,
`RegionFrame.lean:537` machine-checks `not_regionConstant_regionHistory`: because that carrier
embeds the time in the state, no history on it can ever repeat a state, which forecloses any
lasso/periodicity argument **on that carrier specifically**. A genuinely finite `W` has no such
obstruction — this is an argument for building fresh on the normal form rather than adapting
`regionFrame`.

**Sorry inventory**: exactly one live `sorry` in `FormalSystem/` outside `Boneyard/` —
`Metalogic/WeakCanonical/Transfer.lean:1084`, the repo's declared invariant C3.
`Metalogic/Decidability/` and `Semantics/` are sorry-free. Any work here must keep it that way.

**Boneyard warning, load-bearing for planning.** Previous attempts at precisely the
eventuality-fulfilment machinery this truth lemma needs are archived with sorries:
`Boneyard/ScheduleBasedBFMCS/RootScopedChain.lean` (3), `Boneyard/QuasimodelOracle/RoundRobinChain.lean`
(3), `Boneyard/QuasimodelOracle/OracleStep.lean` (7), `Boneyard/QuasimodelOracle/OracleCoherence.lean`
(6), `Boneyard/SorriedDeclExcisions/BundleUntilSinceStep.lean` (7),
`Boneyard/SorriedDeclExcisions/WeakTruthLemmaCluster.lean` (6). This is the single largest risk in
the task and the reason the plan must isolate it in its own phase with an explicit escalation route.

### 7. The rebase CAUTION is a negative finding; the paper's replacement frame is already in Lean

The task description warns that a former two-state universal-relation witness frame violating
*Limit* may have been transcribed into the Lean tree. **It was not.** All three universal-relation
frames (`TaskRel := fun _ _ _ => True`) are `Unit`-carriered — `trivialFrame`
(`TaskFrame.lean:1074`), `intTimeFrame` and `genericTimeFrame` (`Examples/TemporalStructures.lean:78,
226`) — and each discharges `limit` by `limit_of_subsingleton` (`TaskFrame.lean:879`), i.e. *Limit*
is free because the carrier is a subsingleton, not because the relation is well-behaved. There is no
`Fin 2` frame anywhere, and a two-state universal frame would fail `nullity_identity` before
reaching *Limit*. **No rebase surface.**

The paper's *replacement* off-zero-universal witness frame, on the other hand, already exists in
Lean — in the test suite. `Tests/BimodalTest/Semantics/TaskFrameTest.lean:61`:

```lean
def customFrame : TaskFrame Int where
  WorldState := Bool
  TaskRel := fun w d u => d ≠ 0 ∨ w = u
```

This is exactly the paper's construction, verbatim from the `app:dense` proof: "Let $W = \set{w_0,
w_1}$ where $w \Rightarrow_0 w'$ \textit{iff} $w = w'$ and $w \Rightarrow_d w'$ for all $w, w' \in W$
and $d > 0$". Its *Limit* discharge (`TaskFrameTest.lean:128`) runs through
`TaskFrame.limit_of_permissive` → `limit_of_succOrder`, which is why it works over `Int` and would
not over a dense `D` — matching the paper's own reason for restricting the witness to a discrete
order. It is a ready-made, already-green, two-state finite-`W`-over-ℤ frame sitting in `Tests/`.

### 8. Decidable model checking — what is missing

- **`Semantics/` has no `Decidable` instances at all.** Exhaustive grep for
  `Decidable|decide|DecidablePred` over `FormalSystem/Semantics/` returns two hits, both prose in
  doc comments. `TruthAt` is `Prop`-valued; `WorldHistory.domain : D → Prop`.
- **`FiniteTaskFrame.finite_world : Finite WorldState` is the wrong finiteness notion for
  computation.** `Finite` is non-constructive and yields no enumeration, so it cannot drive `decide`.
  A `Fintype`/`DecidableEq` presentation is required.
- **`validity_decidable` has been deleted** — superseding round 1, which reported it as live at
  `Correctness.lean:78`. `Correctness.lean:74-104` is now a retirement note headed
  "`validity_decidable` / `validity_has_decision_procedure` — Retired as vacuous", stating verbatim
  that the former "was proved by `exact Classical.em (⊨ φ)`" and "is in no sense a decidability
  statement: it produces no procedure and no `Decidable` instance". The note also names what is
  still owed: "`isValid φ fc = true ↔ ⊨ φ`, and the `Decidable (⊨ φ)` instances for the four frame
  classes … That obligation is open."
- **`isValid` is a `Bool` with no correctness theorem.** `DecisionProcedure.lean:317`; the
  `= true ↔ ⊨ φ` bridge is the open obligation above.
- **No periodicity machinery exists.** No `UltimatelyPeriodic`/`EventuallyPeriodic`/lasso detection
  anywhere in the tree. This is new construction.

Recommended shape, enabled by the normal form (Finding 5):

```lean
structure IntPresentation where
  card  : ℕ
  step  : Fin card → Fin card → Bool
  val   : Atom → Fin card → Bool
  fwd   : ∀ w, ∃ u, step w u = true
  bwd   : ∀ w, ∃ v, step v w = true

def IntPresentation.toFiniteFrame (P : IntPresentation) : FiniteTaskFrame ℤ
def IntPresentation.check (P : IntPresentation) (w : Fin P.card) (φ : Formula) : Bool
theorem IntPresentation.check_correct (P : IntPresentation) … :
    P.check w φ = true ↔ ∃ τ, τ.IsTotal ∧ τ.states 0 _ = … ∧ TruthAt (P.toModel) τ 0 φ
```

`□` is decided once per model (Finding 5, payoff 2); `untl`/`snce` are decided by bounded search
over the finite graph with a pigeonhole bound on witness distance.

## Decisions

1. **Adopt the ℤ-time target, not the Discrete-class target.** The task's literal statement is
   refuted (Finding 1). Target: `satisfiable ℤ Γ → ∃ finite-`W` model over ℤ`. Lean's
   `ValidDiscrete`/`satisfiable ℤ` vocabulary already expresses it correctly.
2. **Transcribe `cor:spherical-finite` as a general library lemma, not a task-local one.** It is
   12 lines, choice-free, machine-checked, and subsumes two existing helpers.
3. **Treat Seriality as a genuine per-construction obligation.** Machine-checked negative (Finding 3).
4. **Build on the ℤ normal form** rather than adapting `regionFrame` (Finding 6).
5. **Do not re-derive the paper's finite-`W` argument** — transcribe `cor:spherical-finite`'s proof
   text, per the task's explicit instruction, now sourced from the standalone corollary.
6. **Zero-debt**: no phase may close with a `sorry`. Where the eventuality-fulfilment sub-lemma
   resists, escalate to `[BLOCKED]` for user review rather than deferring a placeholder.

## Recommendations

Prioritized; each sized to one agent run.

1. **Extend `specs/paper-definitions-of-record.md` to track `cor:spherical-finite`, `lem:nesting`,
   `lem:nonempty`.** This task quotes `cor:spherical-finite` verbatim as its transcription source,
   and it is currently **untracked** — the record's own "Known residual gap" section names this,
   and additionally notes that tracked `thm:extension` now cross-references untracked
   `cor:spherical-finite`. Follow the record's own four-step extension protocol. Do this first or
   this task's central citation is unprotected by the lint. *(Owner: this task's plan, phase 1.)*
2. **Land `TaskFrame.spherical_of_finite` in `FormalSystem/Semantics/TaskFrame.lean`.** Proof
   already machine-checked (Finding 2). Retire or re-derive `spherical_of_subsingleton` through it.
   Independently valuable to tasks 415, 421, 427.
3. **Land the ℤ normal form**: `iter`/`iter_add` (machine-checked), `TaskFrame.ofStep` building a
   `TaskFrame ℤ` from a bi-serial relation, `taskRel_eq_iter` for the converse direction, and
   `mem_HF_iff_adjacent` characterizing `H_F` as bi-infinite paths.
4. **Land `box_const`**: `TruthAt M τ t φ.box ↔ TruthAt M σ s φ.box` for total `τ, σ` and any `t, s`,
   from time-homogeneity plus `isTotal_timeShift`. This is the enabling lemma for both deliverables.
5. **Promote `customFrame` out of `Tests/`** into the library as the paper's canonical
   off-zero-universal two-state ℤ witness, with its four axiom discharges cited to the paper's
   `app:dense`/`app:deterministic` proof text. Cheap, and gives every downstream task a concrete
   finite-`W`-over-ℤ frame to test against.
6. **The truth lemma, decomposed into its own phases**: atoms/`⊥`/`→` (routine), `□` (via
   recommendation 4 plus `PartialHistory.occurrence`), then `untl`/`snce` **as a single isolated
   phase with its own risk budget**. The eventuality-fulfilment argument is where six previous
   attempts landed in `Boneyard` with sorries (Finding 6). Give it a dedicated phase, a pigeonhole
   /lasso strategy stated up front, and an explicit `[BLOCKED]` escalation if it resists.
7. **`IntPresentation` and `check`** (Finding 8), with `Fintype`/`DecidableEq` carriers, only after
   recommendation 3 lands.
8. **Correct the task description** on the six stale points inventoried in the Appendix before
   planning, so the plan does not re-inherit them.

## Risks & Mitigations

| Risk | Severity | Mitigation |
|---|---|---|
| `untl`/`snce` eventuality fulfilment resists (six Boneyard precedents) | **High** | Isolate in its own phase; state the pigeonhole/lasso strategy before starting; `[BLOCKED]` escalation, never a `sorry` |
| Task description's refuted target propagates into the plan | High | Recommendation 8; plan must restate the target as ℤ-time |
| `cor:spherical-finite` is untracked and could drift | Medium | Recommendation 1 (extend the record) |
| Transfer from abstract succ-Archimedean `D` to concrete `ℤ` not in tree | Medium | Mathlib supplies it: `LinearOrderedAddCommGroup.int_orderAddMonoidIso_of_isLeast_pos` (`Mathlib.GroupTheory.ArchimedeanDensely`) and `orderIsoIntOfLinearSuccPredArch`. Verify binder fit early |
| `Finite` vs `Fintype` mismatch blocks the checker late | Medium | Recommendation 7 sequenced after 3; `IntPresentation` carries `Fin card` by construction |
| Live `sorry` count regresses from 1 | Medium | Verify with the repo's own regex (`scripts/check-module-invariants.sh:165`), not naive grep, which over-counts doc-comment prose |
| Paper drifts again mid-task | Medium | Re-run `scripts/check-paper-definitions.sh` at every phase boundary; this neighborhood moved three times in four days |

## Appendix

### A. Stale claims in the task description (inventory for recommendation 8)

| Claim | Status | Correction |
|---|---|---|
| Target = "satisfiable over the **Discrete** class ⇒ finite `W` over ℤ" | **Refuted** | ℤ-time, not Discrete (Finding 1) |
| "the paper's decidability corollary proof text cites [the FMP]" | **Stale** | That text is now an `%% OLD:` line; `cor:tm-decidability` states decidability is *open* |
| "restated paper-side as finite `W` over ℤ … is a mandatory edit" | **Done, and superseded** | Paper made the restatement, then withdrew the decidability claim entirely |
| `TaskFrame.limit_nullity_of_succOrder` | **Renamed** | `TaskFrame.limit_of_succOrder` (`TaskFrame.lean:673`); zero hits for `limit_nullity` |
| Verbatim Spherical quote ("*Spherical* holds because `W` is finite, so …") | **Stale text, live math** | Now `%% OLD:` at both appendix sites; live source is `cor:spherical-finite` |
| CAUTION: old two-state universal witness may be transcribed in Lean | **Negative** | No such frame exists; all universal frames are `Unit`-carriered (Finding 7) |
| "Whether Seriality is automatic over ℤ is an OPEN question" | **Answered NO** | Machine-checked counterexample (Finding 3) |

### B. Superseded round-1 findings

Round 1 (`reports/01_semantic-fmp-finite-worldstate.md`) is retained as history. Beyond its already
recorded maximal-vs-total supersession, two of its specific findings are now stale:

- Its item 6 / H3 table row on `validity_decidable` being live at `Correctness.lean:78` — that
  declaration has since been **deleted** with a retirement note (Finding 8).
- Its item 5's assessment that the box case is "the most-likely-underestimated sub-problem …
  uncountable even for finite `W`" — dissolved by `box_const` (Finding 5, payoff 2). The
  underestimated sub-problem is instead `untl`/`snce` eventuality fulfilment (Finding 6).

Its premise check (`FMP/` contains zero `TruthAt`), its Mathlib-has-no-filtration negative, and its
inventory of the three candidate constructions remain accurate.

### C. Tactic and search survey

| Goal | Method | Result |
|---|---|---|
| `spherical_of_finite` | `Set.Finite.exists_minimal` + directedness, manual term/tactic mix | **success**, zero diagnostics, first attempt |
| `iter_add` | induction + `simpa [Nat.add_succ]` | **success**, zero diagnostics |
| Seriality-independence counterexample | `refine` + `omega` + `spherical_of_subsingleton` | **success**, zero diagnostics |
| finite directed family → least member | `lean_leansearch` | `Set.Finite.exists_minimal`, `DirectedOn.is_bot_of_is_min` (`Mathlib.Order.Preorder.Finite`, `Mathlib.Order.Directed`) |
| succ-Archimedean group ≅ ℤ | `lean_leansearch` | `LinearOrderedAddCommGroup.int_orderAddMonoidIso_of_isLeast_pos`, `orderIsoIntOfLinearSuccPredArch`, `LinearOrderedAddCommGroup.isAddCyclic_iff_nonempty_equiv_int` |

`lean_local_search` for `limit_nullity_of_succOrder` returned empty — the finding that led to the
rename discovery (Finding 4). No blocked tools were called; no MCP failures or rate limits occurred.

### D. Key Lean anchors

| Declaration | Location |
|---|---|
| `structure TaskFrame` (9 fields, `[Nontrivial D]` binder) | `FormalSystem/Semantics/TaskFrame.lean:472` |
| `TaskFrame.Spherical` / `Serial` / `Interpolates` / `Compositional` | `TaskFrame.lean:341,356,374,398` |
| `DirectedFamily` / `Fib` / `cone` / `Seg` / `IsFiber` / `IsSegment` | `TaskFrame.lean:274,208,229,255,282,292` |
| `TaskFrame.limit_of_succOrder` / `limit_of_shift` / `exists_uniform_radius_of_finite` | `TaskFrame.lean:673,701,752` |
| `spherical_of_subsingleton` / `_permissive` / `_eq` | `TaskFrame.lean:890,1003,1052` |
| `structure FiniteTaskFrame` (`finite_world : Finite WorldState`) | `TaskFrame.lean:1329` |
| `structure PartialHistory` / `IsTotal` / `Extends` | `Semantics/PartialHistory.lean:91,176,185` |
| `structure WorldHistory` / `IsTotal` / `TaskFrame.HF` / `isTotal_timeShift` | `Semantics/WorldHistory.lean:100,470,512,486` |
| `TruthAt` (Ω-free; box over `σ.IsTotal`) | `Semantics/Truth.lean:145` |
| `valid` / `satisfiable` / `FormulaSatisfiable` / `ValidDiscrete` | `Semantics/Validity.lean:94,157,190,222` |
| `PartialHistory.Constraints` (`def:constraints`) | `Semantics/FrameAxioms.lean:204` |
| `step` (`lem:step`) / `extension` / `occurrence` / `hF_nonempty` | `Semantics/Extension/Step.lean:119`, `Extension/Extension.lean:184,231,244` |
| `FiniteFilteredTaskFrame` (only live `FiniteTaskFrame`) | `Metalogic/Decidability/FMP/FiniteModel.lean:159` |
| `FilteredWorld` / `FilteredWorld.finite` | `FMP/Filtration.lean:159`, `FMP/FiniteModel.lean:137` |
| `validity_decidable` retirement note | `Metalogic/Decidability/Correctness.lean:74-104` |
| `branchTruthAt` (ℤ truth lemma, infinite carrier) | `Decidability/Verified/Bridge/IntTruth.lean:889` |
| `not_regionConstant_regionHistory` (forecloses lasso on `regionFrame`) | `Verified/Bridge/RegionFrame.lean:537` |
| `customFrame` (paper's off-zero-universal witness, `Bool` over `Int`) | `Tests/BimodalTest/Semantics/TaskFrameTest.lean:61` |
| sole live `sorry` | `Metalogic/WeakCanonical/Transfer.lean:1084` |
