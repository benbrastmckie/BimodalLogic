# Research Report: Total-History Validity Refactor (round 3)

- **Task**: 414 `refactor_semantics_to_total_history_validity`
- **Started**: TBD
- **Completed**: TBD
- **Effort**: TBD
- **Dependencies**: TBD
- **Sources/Inputs**: TBD
- **Artifacts**: TBD
- **Standards**: TBD
- **Session**: sess_1786421639_4348c4
- **Date**: 2026-08-10
- **Agent**: lean-research-agent
- **Charter**: `specs/state.json` → `active_projects[project_number == 414].description`, re-issued
  2026-08-10 (10 numbered sections), superseding the prior maximal-history charter in full.
- **Definitions of record**: `specs/paper-definitions-of-record.md` (23 recorded anchors).
- **Supersedes**: `reports/01_maximal-history-validity-refactor.md` (round 1, `IsMax` target) and
  `reports/02_group-c-reconciliation.md` (round 2, Group C bucketing) on every point the charter's
  §5 lists as superseded. This report carries forward what §5 lists as surviving, and corrects two
  survivals that turn out not to hold against the live tree (§5.1 below).

---

## 0. Mandated first step — paper-definitions lint

```
$ bash scripts/check-paper-definitions.sh
[paper-definitions] notice: possible_worlds.tex changed (source: live working tree,
new checksum f07441ebb9751d1e955d5af135bebc107ef7163dea49ccfb29b763aae67d1b27,
last-touching commit 7137d52d1941d1d385fcf5503be816adfbcf1c3a) but all 23 recorded
definitions are unchanged -- pass.
EXIT=0
```

**Outcome (b): notice, no recorded definition drifted → proceed.** No spec re-issue is required.
All anchors cited below are quoted verbatim from `specs/paper-definitions-of-record.md`, never
from the paper directly, and never by a bare `possible_worlds.tex:NNNN` locator.

---

## 1. Dependency state: which `def:frame` axioms are fields today

**Question 1 asked in the dispatch: exactly which of the four axioms are fields.**

`FormalSystem/Semantics/TaskFrame.lean:177-230` — the `TaskFrame` structure has exactly five
fields:

| Field | Line | Relation to `def:frame` |
|---|---|---|
| `WorldState : Type` | 179 | carrier; **no `Nonempty` field** (`def:task-relation` requires `W` nonempty) |
| `TaskRel : WorldState → D → WorldState → Prop` | 181 | the extended (two-sided) task relation |
| `nullity_identity : ∀ w u, TaskRel w 0 u ↔ w = u` | 198 | **not a paper axiom** — strictly stronger than `lem:nullity`; the structure's own docstring flags this as an OPEN DESIGN QUESTION |
| `forward_comp : ∀ w u v x y, 0 ≤ x → 0 ≤ y → TaskRel w x u → TaskRel u y v → TaskRel w (x+y) v` | 214 | the `←` (composition) HALF of the biconditional *Compositionality* only |
| `converse : ∀ w d u, TaskRel w d u ↔ TaskRel u (-d) w` | 230 | `def:task-relation`'s converse convention, not an axiom |

Verdict, per axiom of `def:frame` (record entry, sha256
`944879579f6b176390b9622db9c9cdfa52f07bc3f8244bd3f01dac1f77ca6926`):

| `def:frame` axiom | Verbatim (record) | Field? |
|---|---|---|
| *Compositionality* (`def:frame#Compositionality`) | `$w \Rightarrow_{x + y} v$ if and only if $w \Rightarrow_x u$ and $u \Rightarrow_y v$ for some $u \in W$.` | **HALF** — only `←`; the `→` (interpolation) direction is absent |
| *Seriality* (`def:frame#Seriality`) | `$w \Rightarrow_x u$ and $v \Rightarrow_x w$ for some $u, v \in W$.` | **ABSENT** |
| *Limit* (`def:frame#Limit`) | `$\bigcap\limits_{x > 0} (w)_x = \set{w}$.` | **ABSENT** (only discharge helpers `limit_of_succOrder` :302, `limit_of_shift` :330) |
| *Spherical* (`def:frame#Spherical`) | `$\bigcap \mathcal{S} \neq \emptyset$ for any directed family $\mathcal{S}$ of nonempty fibers and segments.` | **ABSENT** (only the apparatus `Fib` :445, `cone` :466, `Seg` :492, `DirectedFamily` :511, `IsFiber` :519, `IsSegment` :529) |

The dispatch brief's reading of the module header is **confirmed verbatim** against the live file.

### Task 420's actual state

`specs/420_align_task_frame_with_positive_cone_axioms/plans/02_four-axiom-frame-alignment.md`:

- Phases **1-9 `[COMPLETED]`** (line markers verified).
- Phase **10 `[BLOCKED]`** (`:698`) — "Add the four axiom fields and discharge all 16 live sites".

So the four axiom fields are gated behind 420 Phase 10, which is itself blocked (per
`state.json` blockers for 420) on a phase-level wait for task 415's `bundleFlowFrame` plus a
re-scope. `state.json` records 420 as `partial`; 438 and 439 are `completed`. (Note: 414's
`dependencies` array is `[420, 438, 439]` — the charter §9 names only 420 and 438; 439 is an
additional recorded edge and is satisfied.)

---

## 2. Question 2 — is `lem:step` blocked? **Statable now; not frame-intrinsic until 420 P10.**

This is the load-bearing scoping answer, and it is **not** a plain yes/no.

**`lem:step` cannot be proved as a property of the current `TaskFrame`**, because its proof
consumes *Spherical* (its sole application site) and *Seriality*, neither of which is structure
data. There is no way to obtain them from the five fields above.

**But `lem:step` — and the whole chain through `cor:occurrence` — IS statable and landable
now, in hypothesis form**, using the apparatus 420's Phase 7 already landed. I verified this by
compiling the following against the live tree (`lean_run_code`, success, only the three
deliberate `sorry`s for proof bodies, zero errors):

```lean
/-- `def:frame#Spherical` in hypothesis form, using the landed apparatus. -/
def Spherical {W : Type} (R : W → D → W → Prop) : Prop :=
  ∀ S : Set (Set W), DirectedFamily S →
    (∀ s ∈ S, (IsFiber R s ∨ IsSegment R s) ∧ s.Nonempty) →
    (⋂₀ S).Nonempty

/-- `def:frame#Seriality` in hypothesis form. -/
def Serial {W : Type} (R : W → D → W → Prop) : Prop :=
  ∀ (w : W) (x : D), 0 ≤ x → (∃ u, R w x u) ∧ (∃ v, R v x w)

/-- `def:frame#Compositionality`'s interpolation half (the `←` half is `forward_comp`). -/
def Interpolates {W : Type} (R : W → D → W → Prop) : Prop :=
  ∀ w v x y, 0 ≤ x → 0 ≤ y → R w (x + y) v → ∃ u, R w x u ∧ R u y v

theorem step (F : TaskFrame D)
    (hSph : Spherical F.TaskRel) (hSer : Serial F.TaskRel) (hInt : Interpolates F.TaskRel)
    (tau : PartialHistory F) (z : D) :
    ∃ sigma : PartialHistory F, Extends sigma tau ∧ sigma.domain z := ...
```

This is exactly the "standalone style" 420's Phases 3 and 7 already established for the Limit
discharge helpers and the fiber/segment apparatus: state against a bare relation or as an
explicit hypothesis now, so that Phase 10 turning the hypothesis into a field is a **mechanical
substitution with zero restatement**.

### Consequence for the §7 cross-task acceptance criterion

The charter §7 criterion — "*Spherical*'s Lean statement must be literally the hypothesis that
`lem:step`'s proof consumes" — is **satisfiable by this task without waiting for 420**, and in
fact this ordering is *safer* than waiting:

- If this task lands `Spherical` as an explicit hypothesis that `step`'s proof genuinely
  consumes, then 420 Phase 10 cannot land it as an inert field — Phase 10's field must have
  exactly this statement or `step` fails to typecheck at the substitution site.
- If instead this task waits, 420 Phase 10 lands a field with no consumer, and the joint failure
  mode the charter warns about becomes live.

**Recommendation (planning decision, surfaced not decided): land the `Spherical`/`Serial`/
`Interpolates` hypothesis-form Props and the `step`→`extension`→`occurrence` chain in THIS task,
and record in 420's Phase 10 that its field statements must be definitionally these Props.**

### What is genuinely blocked

Only one thing: **`H_F`'s nonemptiness as a frame-intrinsic theorem**. `cor:occurrence`
(record: `For any frame $\F = \tuple{W, \D, \Rightarrow}$, world state $w \in W$, and time
$x \in D$, there is a total world history $\tau \in H_{\F}$ where $\tau(x) = w$, and so
$H_{\F} \neq \emptyset$.`) needs Spherical/Seriality as frame data plus a `Nonempty WorldState`
field to produce the seed `w`. Until 420 Phase 10, every consumer must carry the hypotheses
explicitly. **This does not block anything else in this task** — see §3.

---

## 3. What IS independently landable now (verified)

| Charter item | Landable now? | Evidence |
|---|---|---|
| §2 binder delta on `TruthAt`/`valid`/`SemanticConsequence`/satisfiable family | **YES** | Verified prototype, §4 below — compiles sorry-free except two mechanical cases |
| §2 `ShiftClosed` elimination from the statement | **YES** | Verified: box case of shift-preservation needs no `ShiftClosed` (§4.2) |
| §3 `PartialHistory` layering + `Extends` + `IsTotal` | **YES** | Typechecks against live tree (§2 snippet) |
| §4 `Spherical`/`Serial`/`Interpolates` hypothesis-form Props | **YES** | Typecheck using landed 420 Phase 7 apparatus |
| §4 `lem:step` / `thm:extension` / `cor:occurrence` **statements** | **YES** (hypothesis-parameterized) | Typecheck (§2 snippet) |
| §4 same, as **frame-intrinsic** theorems | **NO — blocked on 420 Phase 10** | Spherical/Seriality/`Nonempty WorldState` are not structure data |
| §8 frame-relative validity `⊨_F` | OPTIONAL, and landable | `def:frame-validity` needs only `H_F`, not the axioms |

---

## 4. The concrete Lean signature changes (verified by compilation)

### 4.1 Verified line references (dispatch question 4)

The charter §2's line references are **correct against the live tree**:

- `FormalSystem/Semantics/Validity.lean:79-84` — `def valid`, binder line at **:80**, and it
  **already carries `[Nontrivial D]`**. Confirmed.
- `FormalSystem/Semantics/Validity.lean:103-109` — `def SemanticConsequence`, binder line at
  **:104**, and it **already carries `[Nontrivial D]`**. Confirmed.

The `[Nontrivial D]` claim in §2 is therefore **verified**. The genuine binder gap is only at the
structure level: `structure TaskFrame (D : Type*) [AddCommGroup D] [LinearOrder D]
[IsOrderedAddMonoid D]` (`:177`) has **no `[Nontrivial D]`** and **no `Nonempty WorldState`
field**. Also confirmed: `satisfiable` (`:129`), `SatisfiableAbs` (`:138`), and
`FormulaSatisfiable` (`:154`) do **not** carry `[Nontrivial D]` — they are the members of the
satisfiable family that need the binder *added*, unlike `valid`/`SemanticConsequence`.

`ValidDense` (`:169`), `ValidDiscrete` (`:187`), `ValidDedekind` (`:241`), and
`ValidDedekindDense` (`:276`) all already carry `[Nontrivial D]` and all carry the
`Omega`/`ShiftClosed` pair — they take the same two-move delta as `valid`.

### 4.2 Target signatures

The totality predicate, per `def:world-history` (record, sha256
`4aaa6ec0db38ccbba25ce6dc61d81b8a28f82913ba6b2b1defabaa42f9caf205`), verbatim: `A world history
is \textit{total}--- equivalently, a \textit{possible world}--- just in case $X = D$.`

```lean
def WorldHistory.IsTotal (τ : WorldHistory F) : Prop := ∀ t : D, τ.domain t
```

**`TruthAt`** (`Truth.lean:128-137`) — `Omega` parameter dropped, box clause retargeted:

```lean
def TruthAt (M : TaskModel F) (τ : WorldHistory F) (t : D) : Formula → Prop
  | Formula.atom p  => ∃ (ht : τ.domain t), M.valuation (τ.states t ht) p
  | Formula.bot     => False
  | Formula.imp φ ψ => TruthAt M τ t φ → TruthAt M τ t ψ
  | Formula.box φ   => ∀ (σ : WorldHistory F), σ.IsTotal → TruthAt M σ t φ
  | Formula.untl φ ψ => ∃ s : D, t < s ∧ TruthAt M τ s φ ∧
      ∀ r : D, t < r → r < s → TruthAt M τ r ψ
  | Formula.snce φ ψ => ∃ s : D, s < t ∧ TruthAt M τ s φ ∧
      ∀ r : D, s < r → r < t → TruthAt M τ r ψ
```

`def:BL-semantics`'s box clause, verbatim from the record:
`\item[($\Box$)] $\M,\tau,x \vDash \Box \varphi$ \textit{iff} $\M,\sigma,x \vDash \varphi$ for all $\sigma \in H_{\F}$.`

The `untl`/`snce` clauses are **τ-local and unchanged in shape** — they lose only the `Omega`
argument, exactly as the charter §2 states. (But see §6: their *argument order* raises a separate,
newly-surfaced discrepancy.)

**Note on the atom clause.** `def:BL-semantics`'s atom clause is now
`$\M,\tau,x \vDash p_i$ \textit{iff} $\tau(x) \in |p_i|$` — **no domain conjunct**. Lean's
`∃ (ht : τ.domain t), …` retains one. This is harmless *for total τ* (the `∃` is trivially
inhabited), and `TruthAt` must stay total on arbitrary `WorldHistory F` if the box clause takes
`σ.IsTotal` as a hypothesis rather than a subtype. It becomes a literal match only under the
subtype encoding — see §5.

**`valid`**:

```lean
def valid (φ : Formula) : Prop :=
  ∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]
    (F : TaskFrame D) (M : TaskModel F)
    (τ : WorldHistory F) (_ : τ.IsTotal) (t : D),
    TruthAt M τ t φ
```

**`SemanticConsequence`** (`def:logical-consequence`, verbatim: `for all models $\M$, possible
worlds $\tau \in H_{\F}$, and times $x \in D$, if $\M,\tau,x \vDash \gamma$ for all premises
$\gamma \in \Gamma$, then $\M,\tau,x \vDash \varphi$`):

```lean
def SemanticConsequence (Γ : Context) (φ : Formula) : Prop :=
  ∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]
    (F : TaskFrame D) (M : TaskModel F)
    (τ : WorldHistory F) (_ : τ.IsTotal) (t : D),
    (∀ ψ ∈ Γ, TruthAt M τ t ψ) → TruthAt M τ t φ
```

**Satisfiable family** — `satisfiable`, `SatisfiableAbs`, `FormulaSatisfiable`: drop
`(Omega : Set (WorldHistory F))` and `(_ : τ ∈ Omega)`, add `(_ : τ.IsTotal)`. The charter §5
records that satisfiability has **no paper anchor**; this is a design decision inherited from
`valid`, not a reconciliation finding. `satisfiable`/`SatisfiableAbs`/`FormulaSatisfiable`
additionally need `[Nontrivial D]` added if they are to be sound companions of `valid` (see
`unsatisfiable_implies_all` at `:372`, whose statement quantifies without `Nontrivial`).

**Variant validity predicates** — `ValidDense`, `ValidDiscrete`, `ValidDedekind`,
`ValidDedekindDense`: identical two-move delta.

### 4.3 VERIFIED: `ShiftClosed` is genuinely unnecessary, and shift-preservation is strictly easier

Charter §2 asserts "`ShiftClosed` becomes unnecessary in the STATEMENT of validity/consequence
because totality is trivially preserved by `timeShift`", and §5 asserts a totality-based
`time_shift_preserves_truth` is "strictly EASIER" than the verified maximality-based one. Both
are now **machine-verified**, not merely argued. I compiled the following against the live tree
(`lean_run_code`): every declaration is sorry-free except `time_shift_preserves_truth'`, whose
two remaining cases (`untl`, `snce`) I left as `sorry` because they are byte-for-byte the
existing proof's cases with the `Omega` argument deleted.

```lean
theorem isTotal_timeShift {σ : WorldHistory F} (h : IsTotal σ) (Δ : D) :
    IsTotal (WorldHistory.timeShift σ Δ) :=
  fun t => h (t + Δ)                       -- one line, no hypothesis
```

The box case of shift-preservation, **with no `ShiftClosed` hypothesis anywhere in the
statement**:

```lean
theorem time_shift_preserves_truth' (M : TaskModel F) (σ : WorldHistory F) (x y : D) (φ : Formula) :
    TruthAt' M (WorldHistory.timeShift σ (y - x)) x φ ↔ TruthAt' M σ y φ := by
  ...
  | box ψ ih =>
    simp only [TruthAt']
    constructor
    · intro hbx ρ hρ
      exact (ih ρ x y).mp (hbx (WorldHistory.timeShift ρ (y - x)) (isTotal_timeShift hρ _))
    · intro hby ρ hρ
      have h1 := hby (WorldHistory.timeShift ρ (x - y)) (isTotal_timeShift hρ _)
      ...
```

Compare `Truth.lean:481-511`, where the current proof must thread `h_sc ρ h_rho_mem (y - x)`
through both directions. The delta is: **`h_sc` is replaced by a term that is definitionally
`fun t => hρ (t + Δ)`**. Confirmed strictly easier.

`truth'_double_shift_cancel` (the transport lemma the box case depends on) also compiled
sorry-free; its box case becomes `simp only [TruthAt']` with **no residual goal at all**,
because both sides now quantify over the same `IsTotal`-predicate rather than the same `Omega`.

**Downstream impact of dropping `h_sc`**: `TimeShift.time_shift_preserves_truth` currently has 8
live call sites that pass `h_sc` (Soundness.lean:265, DenseValidity.lean:206/:858,
Decidability/Verified/Decidable.lean:655/:666/:1509, plus doc references). Each loses one
argument — mechanical.

---

## 5. The `H_F` encoding decision (§3, shared with 420) — surfaced, not decided

Charter §3 leaves open whether `H_F` is a subtype `{τ : WorldHistory F // τ.IsTotal}` or a
witness pair. Both encodings typecheck; the trade-off, stated so the planner can choose once:

| | Subtype `H_F := {τ // τ.IsTotal}` | Predicate hypothesis `(τ : WorldHistory F) (h : τ.IsTotal)` |
|---|---|---|
| Fidelity to `def:BL-semantics` atom clause | **literal** — `M.valuation (τ.val.states t (τ.property t)) p`, no domain conjunct, matching `$\tau(x) \in \vert p_i\vert$` exactly | approximate — retains `∃ (ht : τ.domain t)`, harmless but not literal |
| Fidelity to box clause `for all $\sigma \in H_{\F}$` | **literal** — `∀ σ : H_F, …` | `∀ σ, σ.IsTotal → …`, extensionally identical |
| Size of the diff from the current tree | large — every `WorldHistory F`-typed argument in the truth/validity layer changes type | **minimal** — exactly the charter §2 "two moves"; `Omega`+`h_mem` → `h_total` |
| Interaction with `timeShift` | needs a lifted `H_F.timeShift` (easy, `isTotal_timeShift` is the field) | none — `timeShift` already applies |
| Interaction with `thm:extension` | natural: `extension` returns an `H_F` element | needs `∃ σ, Extends σ τ ∧ σ.IsTotal` |
| Consistency with 420's `PartialHistory` layering | either | either |

**Recommendation (surfaced, not decided): predicate hypothesis for `TruthAt`/`valid`/
`SemanticConsequence`/satisfiable (the charter's own "two moves" framing), with the subtype used
only where `H_F` appears as an object in its own right (`thm:extension`'s conclusion,
`cor:occurrence`, and the optional `⊨_F`).** This keeps the diff at the charter's stated size
while giving `H_F` a name where the paper uses one. The planner must record this as a single
joint decision with 420 so it is not made twice (charter §3).

### The `PartialHistory` fidelity nuance

`def:world-history` states the task-respect condition **unconditionally**:
`$\tau(x) \Rightarrow_{y-x} \tau(y)$ for all times $x, y \in X$` — with the block's own comment
recording that the `y < x` instances "are covered by the converse convention". Lean's
`WorldHistory.respects_task` (`WorldHistory.lean:123-124`) carries an `s ≤ t →` guard. The
unconditional form is the more faithful transcription and is **inter-derivable** with the guarded
form given `TaskFrame.converse`. The planner should pick the unconditional form for the new
`PartialHistory` (it is what `lem:fibers`/`lem:admissible` consume, both of which are stated
"for every $t \in X$" with no sign proviso) and derive the guarded form for compatibility.

---

## 6. NEW FINDING (not anticipated by the charter): the `untl`/`snce` argument-order contradiction

Charter §2 says the `untl`/`snce` clauses are "τ-local and unchanged in shape", mirroring
`def:BLplus-semantics`. Investigating that anchor surfaced two problems.

### 6.1 `def:BLplus-semantics` is NOT in the definitions of record

`specs/paper-definitions-of-record.md` tracks 17 named entries (`def:temporal-order`,
`def:task-relation`, `def:directed`, `def:frame` + 4 sub-anchors, `lem:nullity`,
`def:world-history`, `thm:extension`, `cor:occurrence`, `def:constraints`, `lem:constraint`,
`lem:fibers`, `lem:admissible`, `lem:step`, `def:BL-model`, `def:BL-semantics`,
`def:frame-validity`, `def:logical-consequence`, `CO`/`TMP-CO`). `grep -c BLplus` on the record
returns **0**.

The anchor **does exist in the live paper**. Per the charter §10's own rule — "That file — NOT
the paper — is what specs in this repository cite" — **any spec citing `def:BLplus-semantics`
today is ungrounded**, and the drift lint would never catch a change to it.

**Recommendation**: extend the record with `def:BLplus-semantics` (and plausibly
`def:BLplus-language` / `def:BLplus-defined`) following the record's own documented extension
protocol — the same protocol used for the 2026-08-11 extension-machinery addition. This should be
a plan prerequisite, since this task's `untl`/`snce` rewrite is meant to mirror that anchor.

### 6.2 The paper's footnote describes the repo's convention **backwards**

Quoting the live `def:BLplus-semantics` block verbatim (flagged **UNVERIFIED-BY-RECORD**: this
text is quoted from the paper, not from the definitions of record, because the record does not
track it):

> Although the axioms of \textbf{TM}$^+$ are drawn from the Burgess-Xu (BX) system, the
> repository's \texttt{snce}/\texttt{untl} constructors follow the Pnueli convention with the
> guard as the first argument and the event as the second: $\varphi\since\psi$ means $\psi$ held
> at some past time with $\varphi$ holding throughout the interval since, and
> $\varphi\until\psi$ means $\psi$ will hold at some future time with $\varphi$ holding
> throughout the interval until $\psi$ holds.

> \item[($\until$)] $\M,\tau,x \vDash \varphi\until\psi$ \textit{iff} $\M,\tau,z \vDash \psi$ for
> some time $z > x$ where $\M,\tau,y \vDash \varphi$ for all $y \in D$ with $x < y < z$.

**The Lean tree is the opposite: event first, guard second.**

- `FormalSystem/Syntax/Formula.lean:85-90` docstring: "Burgess convention: φ = event (eventually
  true), ψ = guard (holds in between)."
- `FormalSystem/Semantics/Truth.lean:134-135`:
  `| Formula.untl φ ψ => ∃ s : D, t < s ∧ TruthAt M Omega τ s φ ∧ ∀ r, t < r → r < s → TruthAt M Omega τ r ψ`
  — the **first** argument is what holds at the witness `s`.
- `Formula.lean:131`: `def someFuture (φ : Formula) : Formula := Formula.untl φ Formula.top` —
  event first. The paper's `def:BLplus-defined` has `$\Past\varphi \coloneq \neg(\top\since\neg\varphi)$`
  — guard `⊤` first.

**The Lean tree is internally consistent and load-bearing on its own convention**, so this is not
a Lean bug to fix silently:

- `Axiom.dense_indicator = ¬U(⊤,⊥)`: under event-first this is `∃ s > t` with no `r` strictly
  between — i.e. an immediate successor, true on `ℤ`. `Validity.lean:229-231` depends on exactly
  this reading ("`U(⊤,⊥)` is true on `ℤ` because every point has an immediate successor").
- `K⁺A = ¬U(⊤,¬A)` (`Formula.lean:164-166`): under event-first this is "A holds arbitrarily
  soon", which is Reynolds' `K⁺`. Under guard-first it is not.

**Verdict**: it is the paper's footnote that misdescribes the repository, not the repository that
diverges from a convention it needs to adopt. **Do NOT flip the Lean convention** — doing so
would silently invert `dense_indicator`, `K⁺`, and every `FrameClass` axiom that mentions
`untl`/`snce`. Editing the paper is a NON-GOAL (charter §9). **This must therefore be escalated
to the user as a paper-side correction, and recorded as an explicit known divergence in the
`untl`/`snce` docstrings during this task's binder rewrite.** It is out of scope to resolve here.

---

## 7. The Omega-elimination survey (dispatch obligation)

### 7.1 The `ShiftClosed` definition and its only structural role

`FormalSystem/Semantics/Truth.lean:333-334`:

```lean
def ShiftClosed (Omega : Set (WorldHistory F)) : Prop :=
  ∀ σ ∈ Omega, ∀ (Δ : D), WorldHistory.timeShift σ Δ ∈ Omega
```

Its **only** structural role is the box case of `time_shift_preserves_truth` (`Truth.lean:481-511`),
which §4.3 shows evaporates under totality. `Set.univ_shift_closed` (`:339`) is its trivial
witness.

### 7.2 DECISIVE FINDING — the live completeness-side Omega is *provably* `H_F`

Task 415 has already re-hosted the dense/Dedekind countermodels onto the bundle flow frame, and
in doing so made the Omega-elimination on the completeness side a **rewrite along a provable set
equation rather than a re-proof**. I verified this fresh, sorry-free, zero errors, against the
live tree:

```lean
theorem multiFamOmegaGen_eq_total (D : Type) [AddCommGroup D] [LinearOrder D]
    [IsOrderedAddMonoid D] (FamIdx : Type) :
    multiFamOmegaGen D FamIdx
      = {σ : WorldHistory (multiFamTaskFrameGen D FamIdx) | ∀ t, σ.domain t} := by
  ext σ
  constructor
  · rintro ⟨⟨f, w₀⟩, rfl⟩; intro _; trivial
  · intro htot
    obtain ⟨f, w₀, rfl⟩ := multiFamGen_total_eq σ htot
    exact multiFamHistoryGen_mem_omega f w₀
```

Both halves come from already-landed 415 material:

- `⊆`: `multiFamHistoryGen` has `domain := fun _ => True` (`FlowFrame.lean:151`) — definitionally
  total.
- `⊇`: `multiFamGen_total_eq` (`FlowFrame.lean:302-326`) — "Every total history of the generic
  flow frame is a flow line". Its own docstring cites `def:world-history` for totality.

`bundleFlowOmega` is `multiFamOmegaGen` at the bundle index (`FlowFrame.lean:432-433`), and
`countermodel_dense_enriched` (`BXCanonical/Completeness.lean:134`) — the live witness for both
`completeness` and `completeness_dense` — is stated over exactly that Omega. Its docstring
already anticipates this task: "its admissible-history set is extensionally the frame's
total-history set H_F (`def:world-history`), so the box clause is the paper's
(`def:BL-semantics`) realized under the current Omega signature."

**Planning consequence**: the Omega-elimination does not need a new countermodel. It needs
`multiFamOmegaGen_eq_total` landed (it is 8 lines and already verified) plus a mechanical
signature rewrite at the countermodel's `∃ Omega, ShiftClosed ∧ τ ∈ Omega` existential.

### 7.3 COUNTERVAILING FINDING — the decidability bridge's Omega is **NOT** `H_F`

§7.2 must not be over-generalized. There are **five** Omega-valued definitions in the live tree,
not one, and the second-largest consumer group behaves oppositely.

`regionOmega` (`Metalogic/Decidability/Verified/Bridge/Omega.lean:215`) is
`Set.range fun p : W × D => regionHistory f p.1 p.2`. Every `regionHistory` is total
(`domain := fun _ => True`, `:182`). But the containment is **strict**, because `regionFrame`'s
task relation is maximally permissive above zero:

```lean
-- Bridge/Omega.lean:138
TaskRel := fun s d s' => d = 0 → s = s'
```

I verified sorry-free against the live tree that **any** assignment of states to all of `D` is a
legal total history of `regionFrame`:

```lean
def arbitraryTotal (g : D → W × (Set ι × Set ι)) : WorldHistory (regionFrame W ι D) where
  domain := fun _ => True
  convex := by intro _ _ _ _ _ _ _; trivial
  states := fun r _ => g r
  respects_task := by
    intro s t _ _ _ hd
    have h : t = s := sub_eq_zero.mp hd
    subst h
    rfl
```

So `regionFrame`'s `H_F` is the **full function space** `D → W × (Set ι × Set ι)`, whereas
`regionOmega` is the range of a two-parameter `W × D` family. `regionOmega ⊊ H_F` strictly, for
any nondegenerate `W`, `ι`, `D`.

This is not incidental — the module docstring (`Bridge/Omega.lean:20-32`) explains that a too-big
Omega is exactly what breaks the construction: `Set.univ` is rejected because it "contains the
empty history … at which every atom is false", so "a single such history falsifies `□p` outright
and no branch carrying `T(□p)` could ever be satisfied". **Totality fixes the empty history but
does not fix the junk-history problem**: an `arbitraryTotal g` with adversarial `g` falsifies
`□p` just as effectively as the empty history does.

**Therefore, under an Omega-free API, `regionFrame` must be REPLACED by a carrier whose total
histories are exactly the intended family** — precisely the move task 415 already made on the
completeness side, where `multiFamTaskFrameGen` is deterministic-shift and so
`multiFamGen_total_eq` holds. This is real, sized work, not a rewrite.

Blast radius of that re-host, from the signature inventory in §7.4: `Bridge/Omega.lean` (5
declarations, all deleted or re-hosted), plus consumers `Valuation.lean` (19 code refs),
`IntTruth.lean` (12), `DenseTruth.lean` (5), `TruthLemma.lean` (3), `RegionLabel.lean` (2), and
the 42 declarations of `Decidability/Verified/Decidable.lean` that sit above them. `ZOmegaV2` and
`multiFamOmega` (`ReynoldsBridge.lean:468`, `:694`) were **not** checked and may fall either way.

### 7.4 Signature-level inventory of the Omega/ShiftClosed blast radius

Derived by a paren-depth-aware declaration parser over `FormalSystem/**` and `Tests/**`,
excluding both boneyards (`FormalSystem/Boneyard/` and
`FormalSystem/Metalogic/WeakCanonical/Kamp/Boneyard/`). Match criteria: a
`Set (WorldHistory …)` parameter, a `ShiftClosed` hypothesis, the `⊨` notation, or a reference to
`valid`/`SemanticConsequence`/the satisfiable family/the four variant validity predicates.

**Total: 221 declarations** (209 signature-level + 12 body-level definitional anchors).

| Group | Count | Concentration |
|---|---|---|
| (A) `FormalSystem/Semantics/**` | 41 | `Truth.lean` 18, `Validity.lean` 14 sig + 9 anchors |
| (B) `FormalSystem/Metalogic/**` | 159 | `Soundness.lean` **70**, `Decidability/Verified/Decidable.lean` **42**, then a long tail |
| (C) everything else live | 21 | `FrameConditions/Validity.lean` 9, `FrameConditions/Soundness.lean` 5, `Automation/PrefilterSoundness.lean` 4, `Tests/BimodalTest/Integration/Helpers.lean` 2, `Automation/DatasetGenerator.lean` 1 |

Declarations actually requiring an edit under the `Omega + ShiftClosed Omega + τ ∈ Omega` →
`τ.IsTotal` collapse, stratified (disjoint strata):

| Stratum | Count | Meaning |
|---|---|---|
| S1 — signature binds the full triple | 22 | direct 3-binders-to-1 rewrite |
| S2 — Omega param + `ShiftClosed`, no `∈ Omega` | 6 | |
| S3 — Omega param only | 66 | Omega binder disappears |
| S4 — `ShiftClosed` only (Omega from a section `variable`) | 7 | |
| **signature subtotal** | **101** | |
| S5/S6 — definitional anchors binding the triple in the *body* | 11 | `valid`, `SemanticConsequence`, `ValidDense`, `ValidDiscrete`, `ValidDedekind`, `ValidDedekindDense`, `satisfiable`, `FormulaSatisfiable`, `ValidOver`, `IsValid`, `SemanticConsequenceDedekindDense` |
| **total requiring an edit** | **112** | |

Refinement: of the 101, twelve are **deletions rather than edits** — the 5 Omega-valued
definitions (`regionOmega`, `ZOmegaV2`, `multiFamOmega`, `multiFamOmegaGen`, `bundleFlowOmega`)
and the 7 `ShiftClosed`-proofs about them. Net: **≈89 signature rewrites + 12 deletions + 11
definition-body rewrites**.

**Approximate, flagged**: `Bridge/TruthLemma.lean:79` and `Bridge/Interpolate.lean:459` take
their Omega from a section `variable`, so every declaration in those sections is affected even
where the parser sees only 3 and 1 hits respectively. This part of the count **undercounts**.

The five Omega-valued definitions and the files that pass them (i.e. the non-`Set.univ` sites)
are: `FlowFrame.lean` (`multiFamOmegaGen` :161, `bundleFlowOmega` :432) consumed by
`CompletenessDedekind.lean`, `ChronicleMonadicBridge.lean`, `ChronicleToCountermodelBasic.lean`,
`Completeness.lean`, `Bundle/LimitMCS.lean`; `Bridge/Omega.lean` (`regionOmega` :215) consumed by
`Valuation.lean`, `IntTruth.lean`, `DenseTruth.lean`, `TruthLemma.lean`, `RegionLabel.lean`;
`ReynoldsBridge.lean` (`ZOmegaV2` :468, `multiFamOmega` :694). Only three live Metalogic files
pass `Set.univ` in a semantics position (`Chronicle/RRelation.lean`,
`Decidability/Propositional/Decidable.lean`, `Soundness.lean`).

### 7.5 The delete-vs-generalize trade-off (415-coupled — surfaced, NOT decided)

Charter §2 explicitly leaves this open. Revised in light of §7.3:

| | **Delete Omega outright** | **Retain Omega as a generalization `valid` specializes** |
|---|---|---|
| API uniformity | satisfies charter §9's "one uniform Omega-free API" literally | violates §9 unless the generalized form is strictly internal |
| Cost on the **completeness** side | low — one rewrite along `multiFamOmegaGen_eq_total`, already verified (§7.2) | zero |
| Cost on the **decidability** side | **high — requires re-hosting `regionFrame` onto a deterministic carrier** (§7.3), ~70+ declarations downstream | zero |
| Risk | the decidability re-host is a genuine sub-project and could stall this task | the hedge the paper's own `cor:tm-completeness` footnote describes stays live, which landing this task is supposed to make obsolete (charter §2) |

**I am not making this decision** (it is 415-coupled per the charter). But the shape has changed
materially from what §7.2 alone suggests: **the completeness side is ready; the decidability side
is not.** A third option the planner should weigh, which the charter does not name:

> **Split the scope.** Land the Omega-free `valid`/`SemanticConsequence`/`TruthAt` API and the
> completeness-side rewrite in this task, and spawn the `regionFrame` deterministic re-host as a
> separate task (the exact analogue of what 415 did for the flow frame). This keeps charter §9's
> "one uniform Omega-free API" intact while sizing the decidability work honestly rather than
> discovering it mid-implementation.

This is the single highest-value item for the planner to resolve before phase sequencing.

---

## 8. §5 SURVIVES list — carried forward, with two corrections

### 8.1 CORRECTION: the "surviving" order machinery is **not in the tree**

Charter §5 lists as SURVIVES: "The extension `Preorder` on histories …, `timeShift_mono`, the
shift/unshift lemma pair, and `chainSup`", plus `exists_maximal_extension` and `isMax_of_total`.

**These do not exist anywhere in the repository.** Verified:

```
$ grep -rn "exists_maximal_extension\|isMax_of_total\|chainSup\|timeShift_mono" --include=*.lean .
(no output — 0 matches, including under FormalSystem/Boneyard/)
```

They exist only as a `lean_run_code`-verified **prototype inside report 01** (§ "Finding 3 —
Verified Prototype", ~85 lines). Round 1 verified them; nothing landed them. The charter's
"SURVIVES" wording could be read as "already in the tree" — it is not. **The plan must schedule
landing this material, not assume it.** The material itself is still sound (predicate-agnostic
order machinery), so this is a scheduling correction, not a mathematical one.

Note further that under a totality target, `exists_maximal_extension` (Zorn to a `IsMax` history)
is the *engine* for `thm:extension`, but the charter §6 is right that the Zorn engine "retargets
to `PartialHistory`" — so the prototype needs porting from `WorldHistory` to `PartialHistory`,
not merely copying. `isMax_of_total` becomes the load-bearing direction, as §5 says.

### 8.2 CORRECTION: the Group C counts have measurably drifted — do NOT carry them as-is

Charter §5 says the 88/16/8 bucketing survives but the counts were never re-derived and predate
415's landing. A full kernel-reachability re-derivation is expensive and I did not run one
(see §9). But I ran a **cheap structural check that is sufficient to show the counts are stale**:

| Report 02's claim | Live-tree status (freshly derived) |
|---|---|
| "all four `ParametricCompleteness.lean` theorems" (in the ~88 DEAD bucket) | `FormalSystem/Metalogic/ParametricCompleteness.lean` — **FILE DELETED** |
| "the dense parametric-canonical device (`ParametricHistory` Omega unit + two `fully_restricted_*` truth lemmas + `countermodel_dense_enriched`)" = the 8 LIVE-AND-UNPORTABLE bucket, "the actual excision/re-host list" | `FormalSystem/Metalogic/Algebraic/ParametricCanonical.lean` — **FILE DELETED**; `ParametricHistory` survives only under `FormalSystem/Boneyard/**`; `fully_restricted_*` survives only as a prose reference at `FlowFrame.lean:690`; `countermodel_dense_enriched` is **LIVE but RE-HOSTED** onto `bundleFlowFrame` (`Completeness.lean:134-148`) |

**So the single most consequential Group C finding — the 8-declaration live-and-unportable
excision list — has already been discharged by task 415's phases 3-4** ("dense truth lemma
rehosted onto the bundle flow model", "delete superseded canonical model stack", per
`git log`). The re-host landed on a carrier whose Omega is provably `H_F` (§7.2).

**Status labels, as the dispatch requires:**

- The **bucketing concept** (dead / live-portable / live-unportable) — **carried forward,
  survives**, unchanged.
- The numbers **88 / 16 / 8** — **CARRIED FORWARD UNVERIFIED, and now known to be stale.** Not
  freshly derived. Do not quote them as current.
- The claim "the 8 live-unportable declarations are the excision list" — **freshly derived as
  SUPERSEDED**: that device is deleted and re-hosted.
- Any re-derivation the plan needs must re-run the report-02 reachability method (root set at
  report 02 Finding 1) against the post-415 tree.

### 8.3 What in §5 I confirmed still holds

- **Soundness-survival**: confirmed and strengthened. Soundness consumes shift-preservation
  (`Soundness.lean:265`), not Zorn. §4.3 machine-verifies that the totality-based
  shift-preservation is strictly easier.
- **`isMax_of_total` becomes load-bearing**: consistent with §7.2's `multiFamGen_total_eq`, which
  is the same "total ⇒ pinned down" move already landed for the flow frame.
- **Satisfiability has no paper anchor**: confirmed — no `satisfiab*` entry in the record.

---

## 9. Limitations and UNVERIFIED items

Flagged rather than asserted, per the dispatch:

1. **Group C counts NOT re-derived.** A full kernel used-constants reachability closure (report
   02's method) was out of budget for this pass. §8.2's staleness proof is structural
   (file/declaration existence), not a recount. Any number in the 88/16/8 family is
   **UNVERIFIED**.
2. **`def:BLplus-semantics` text is quoted from the live paper, not the record** (§6.2), because
   the record does not track it. It is therefore **UNVERIFIED-BY-RECORD** and unprotected by the
   drift lint.
3. **Two of the five Omega-valued definitions were not checked**: `ZOmegaV2`
   (`ReynoldsBridge.lean:468`) and `multiFamOmega` (`:694`). `multiFamOmegaGen`/`bundleFlowOmega`
   are proved equal to `H_F` (§7.2); `regionOmega` is proved strictly smaller than `H_F` (§7.3).
   The remaining two are **UNVERIFIED** and could fall either way; `multiFamOmega` is likely to
   behave like `multiFamOmegaGen` (it is the `ℤ` specialization, per
   `ChronicleMonadicBridge.lean:154`), but I did not confirm it.
4. **`time_shift_preserves_truth'`'s `untl`/`snce` cases were left as `sorry` in the probe**
   (§4.3). They are mechanically the existing proof minus the `Omega` argument, but that is an
   argument, not a compile. The atom/bot/imp/**box** cases and all of
   `truth'_double_shift_cancel` and `isTotal_timeShift` **did** compile sorry-free.
5. **The `step`/`extension`/`occurrence` bodies are `sorry` in the probe** (§2). Only their
   *statements* are verified to typecheck. Charter §6 says the transcription is cheaper than
   round 1 estimated because the paper supplies the decomposition; I did not attempt the proofs.
6. **`nullity_identity`'s open design question** (`TaskFrame.lean:188-197`) — whether to demote it
   to a derived `lem:nullity`, keep the iff, or drop injectivity-at-zero — is explicitly flagged
   in the tree as joint with this task. `lem:admissible` consumes only the *reflexivity* half
   (via `lem:fibers`), so the choice does not obstruct this task; but it must be made jointly.

---

## 10. Recommendations to the planner

1. **Prerequisite**: extend `specs/paper-definitions-of-record.md` with `def:BLplus-semantics`
   before any phase cites it (§6.1).
2. **Escalate §6.2 to the user** as a paper-side footnote correction. Do not flip the Lean
   `untl`/`snce` argument order. Record the divergence in the docstrings during the rewrite.
3. **Phase order**: (a) land `PartialHistory`/`Extends`/`IsTotal` + the §3 layering decision;
   (b) land the hypothesis-form `Spherical`/`Serial`/`Interpolates` and the
   `step`→`extension`→`occurrence` chain consuming them — this *is* the §7 acceptance criterion
   and satisfying it here forecloses 420's inert-field failure mode; (c) port the report-01 Zorn
   prototype from `WorldHistory` to `PartialHistory`; (d) the §2 binder delta on
   `TruthAt`/`valid`/`SemanticConsequence`/satisfiable/variants; (e) land
   `multiFamOmegaGen_eq_total` and rewrite the countermodel existentials.
4. **Make the §3 `H_F` encoding decision once**, jointly with 420, and record it in both plans
   (§5 gives the trade-off table).
5. **Highest-value open decision: delete-vs-generalize for Omega, now three-way** (§7.5). The
   completeness side is ready (§7.2, verified); the decidability side is **not** — `regionOmega`
   is provably a strict subset of its frame's `H_F` (§7.3), so `regionFrame` needs a
   deterministic re-host before the Omega-free API can reach it. Weigh the split-scope option.
   Confirm with 415 before committing. Also size the blast radius from §7.4: ~89 signature
   rewrites + 12 deletions + 11 definition-body rewrites, concentrated in `Soundness.lean` (70)
   and `Decidability/Verified/Decidable.lean` (42).
6. **Do not schedule frame-intrinsic `cor:occurrence`** — it is genuinely blocked on 420 Phase 10
   (`Nonempty WorldState` + Seriality/Spherical as fields). Everything else in the charter is
   independently landable (§3).
7. **`[Nontrivial D]` work is smaller than round 1 said** but not zero: `valid`,
   `SemanticConsequence`, and all four variants already have it; `satisfiable`,
   `SatisfiableAbs`, `FormulaSatisfiable`, and the `TaskFrame` structure do not.

---

## Appendix A — anchors cited, with verbatim text

All quoted from `specs/paper-definitions-of-record.md` unless marked otherwise.

| Anchor | Verbatim excerpt (abridged where noted) |
|---|---|
| `def:world-history` | `A \textit{partial history} over a frame $\F = \tuple{W, \D, \Rightarrow}$ is a function $\tau : X \to W$ on a nonempty set $X \subseteq D$ where $\tau(x) \Rightarrow_{y-x} \tau(y)$ for all times $x, y \in X$. … A \textit{world history} is any partial history whose domain $X$ is \textit{convex} … A world history is \textit{total}--- equivalently, a \textit{possible world}--- just in case $X = D$. … The set of all total world histories over $\F$ is denoted $H_{\F}$.` |
| `def:BL-semantics` (box) | `\item[($\Box$)] $\M,\tau,x \vDash \Box \varphi$ \textit{iff} $\M,\sigma,x \vDash \varphi$ for all $\sigma \in H_{\F}$.` |
| `def:BL-semantics` (atom) | `\item[($p_i$)] $\M,\tau,x \vDash p_i$ \textit{iff} $\tau(x) \in \vert p_i\vert$.` |
| `def:logical-consequence` | `A conclusion $\varphi$ is a \textit{logical consequence} of a set of premises $\Gamma$--- written $\Gamma \vDash \varphi$--- just in case for all models $\M$, possible worlds $\tau \in H_{\F}$, and times $x \in D$, … A sentence $\varphi$ is \textit{valid} just in case $\vDash \varphi$.` |
| `def:frame#Compositionality` | `\item[\it Compositionality:] $w \Rightarrow_{x + y} v$ if and only if $w \Rightarrow_x u$ and $u \Rightarrow_y v$ for some $u \in W$.` |
| `def:frame#Seriality` | `\item[\it Seriality:] $w \Rightarrow_x u$ and $v \Rightarrow_x w$ for some $u, v \in W$.` |
| `def:frame#Limit` | `\item[\it Limit:] $\bigcap\limits_{x > 0} (w)_x = \set{w}$.` |
| `def:frame#Spherical` | `\item[\it Spherical:] $\bigcap \mathcal{S} \neq \emptyset$ for any directed family $\mathcal{S}$ of nonempty fibers and segments.` |
| `def:directed` | `A nonempty family of sets $\mathcal{S}$ is \textit{directed} just in case $S \subseteq S_1 \cap S_2$ for some $S \in \mathcal{S}$ whenever $S_1, S_2 \in \mathcal{S}$.` |
| `def:task-relation` (Segment) | `\item[\it Segment:] $[w, v]_x^y \coloneq \Fib(w, x) \cap \Fib(v, -y)$ where $x, y \geq 0$.` |
| `lem:step` | `Every partial history $\tau : X \to W$ over a frame $\F = \tuple{W, \D, \Rightarrow}$ extends to a partial history on $X \cup \set{z}$ for any duration $z \in D$.` |
| `thm:extension` | `Every partial history $\tau : X \to W$ over a frame $\F = \tuple{W, \D, \Rightarrow}$ is extended by some total world history $\sigma \in H_{\F}$.` |
| `cor:occurrence` | `For any frame $\F = \tuple{W, \D, \Rightarrow}$, world state $w \in W$, and time $x \in D$, there is a total world history $\tau \in H_{\F}$ where $\tau(x) = w$, and so $H_{\F} \neq \emptyset$.` |
| `lem:constraint` | `… the constraints imposed on $z$ form a directed family of nonempty sets.` |
| `lem:fibers` | `… a world state $u \in W$ belongs to every member of the constraints imposed on $z$ just in case $\tau(t) \Rightarrow_{z-t} u$ for every $t \in X$.` |
| `lem:admissible` | `… the function $\tau \cup \set{\tuple{z, u}}$ is a partial history on $X \cup \set{z}$ just in case $u$ belongs to every member of the constraints imposed on $z$.` |
| `lem:nullity` | `$w \Rightarrow_0 w$ for every world state $w \in W$ in every frame $\F = \tuple{W, \D, \Rightarrow}$.` |
| `def:frame-validity` | `A well-formed sentence $\varphi$ of $\BL$ is \emph{valid over a frame} $\F$ … if and only if $\M,\tau,x \vDash \varphi$ for every model $\M$ …, possible world $\tau \in H_{\F}$, and time $x \in D$.` |
| `def:BLplus-semantics` | **NOT IN RECORD** — see §6.1. Text quoted in §6.2 is from the live paper and is UNVERIFIED-BY-RECORD. |
