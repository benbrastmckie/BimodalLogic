# Decision Record: Total-History Validity Refactor (Omega-Free Semantics Core)

**Status**: settled. Each decision below was made **once**, at plan time, and is recorded here so
that neither the total-history-validity refactor nor the four-axiom `TaskFrame` alignment task
re-litigates it. An implementer who disagrees should raise it with the user, not silently choose
differently.

**Origin**: `specs/414_refactor_semantics_to_total_history_validity/plans/03_omega-free-totality-refactor.md`,
section "Decisions made at plan time". Its authoritative research input is
`specs/414_refactor_semantics_to_total_history_validity/reports/03_total-history-validity-refactor.md`
(round 3, machine-verified against the live tree).

**Paper citations** in this record are by `\label` anchor against
`specs/paper-definitions-of-record.md` — never against the paper file directly, and never by line
number. That record is drift-linted by `scripts/check-paper-definitions.sh`.

---

## Decision A — `H_F` encoding (hybrid predicate/subtype)

**Decision.** Totality is encoded two ways, deliberately, with a sharp boundary between them:

- **Predicate-hypothesis form** — `(τ : WorldHistory F) (hτ : τ.IsTotal)` — in `TruthAt`, `valid`,
  `SemanticConsequence`, the satisfiable family, and the four variant validity predicates.
- **Subtype form** — `def TaskFrame.HF (F : TaskFrame D) : Type := {τ : WorldHistory F // τ.IsTotal}` —
  **only** where `H_F` appears as an object in its own right: `thm:extension`'s conclusion,
  `cor:occurrence`, and the optional frame-relative validity `⊨_F`.

**Anchor.** `def:world-history`:

> `A world history is \textit{total}--- equivalently, a \textit{possible world}--- just in case
> $X = D$. … The set of all total world histories over $\F$ is denoted $H_{\F}$.`

**Rationale.** The predicate form is exactly the charter's own "two moves" delta and keeps the
diff at its stated size; it also keeps `TruthAt` total on an arbitrary `WorldHistory F`, which the
recursion needs. The subtype form exists because the paper gives this set a *name* and quantifies
over it as an object; transcribing `∃ σ ∈ H_F` as a subtype existential is fidelity.

**Why this is not a §9 violation** (§9 forbids compatibility shims, aliases, and *parallel validity
notions*). There is exactly **one** validity predicate. `HF` is a bundled name for the same
`IsTotal` predicate, bridged only by `.val` / `.property`. No second `valid`, no alias of an
existing API surface, no alternate box clause.

**Standing constraint.** Totality is `IsTotal τ := ∀ t, τ.domain t` — never Mathlib's `IsMax`, and
never any order-theoretic maximality predicate. Maximality appears only as an *internal* step en
route to `thm:extension` (see Decision B's `exists_maximal_extension` note), never as the target
predicate of validity.

### Accepted fidelity gap — the atom clause's `∃ (ht : τ.domain t)`

`def:BL-semantics`'s atom clause is:

> `\item[($p_i$)] $\M,\tau,x \vDash p_i$ \textit{iff} $\tau(x) \in \vert p_i\vert$.`

The Lean clause is `∃ (ht : τ.domain t), M.valuation (τ.states t ht) p`. This is a **known,
reasoned deviation, accepted and not to be re-opened**:

- Under the **predicate** encoding, `TruthAt` must be defined for an arbitrary `WorldHistory F`,
  whose `states` is dependent on a domain proof. The `∃` is the only total way to write the clause.
- The deviation is **harmless exactly where it is consumed**: every consuming site supplies a total
  `τ`, for which `τ.domain t` is inhabited, so the `∃` is trivially satisfied and the clause is
  pointwise equivalent to the paper's.
- Under the **subtype** encoding the clause could be written literally, since `τ.property t`
  supplies the proof. That is not a reason to switch encodings — see Decision A's boundary above.

Recording it here is the mitigation; the alternative (silently carrying an unremarked divergence
from a quoted anchor) is what this record exists to prevent.

---

## Decision B — `PartialHistory` layering

**Decision.** `WorldHistory extends PartialHistory`, with `PartialHistory` carrying the
**unconditional** task-respect condition:

```lean
structure PartialHistory (F : TaskFrame D) where
  domain : D → Prop
  nonempty_domain : ∃ t, domain t
  states : (t : D) → domain t → F.WorldState
  respects_task : ∀ (s t : D) (hs : domain s) (ht : domain t),
    F.TaskRel (states s hs) (t - s) (states t ht)

structure WorldHistory (F : TaskFrame D) extends PartialHistory F where
  convex : ∀ s t u, domain s → domain u → s ≤ t → t ≤ u → domain t
```

**Anchor.** `def:world-history`:

> `A \textit{partial history} over a frame $\F = \tuple{W, \D, \Rightarrow}$ is a function
> $\tau : X \to W$ on a nonempty set $X \subseteq D$ where $\tau(x) \Rightarrow_{y-x} \tau(y)$ for
> all times $x, y \in X$. … A \textit{world history} is any partial history whose domain $X$ is
> \textit{convex} …`

Three sub-decisions, each with its reason:

1. **Nonemptiness is a field, not a side hypothesis.** `def:world-history` requires a nonempty
   domain for a *partial* history. Carrying it as data is what makes `thm:extension`'s hypothesis a
   faithful transcription rather than an empty-case argument the paper never makes.
2. **`respects_task` is stated unconditionally** — "for all times $x, y \in X$", no `s ≤ t` guard.
   This is the form `lem:fibers` and `lem:admissible` consume, both of which are stated with no
   sign proviso. The existing guarded form is *derived* as `respects_task_le`, and a smart
   constructor `PartialHistory.ofLe` lets an existing site keep its guarded proof, discharging the
   unconditional field via `TaskFrame.converse`. **`ofLe` is a proof-convenience constructor, not a
   compatibility shim**: it introduces no second history type, no second validity notion, and no
   alias of any API surface — it is one lemma-shaped constructor over the single structure.
3. **`extends`, not a standalone structure and not an `IsConvex` mixin.** Lean 4's flat field
   syntax means every existing `WorldHistory … where` block keeps its shape and gains exactly one
   line (`nonempty_domain := …`). The migration cost is bounded by the construction-site count,
   which is small (~11 sites, 10 of them `domain := fun _ => True`).

**Note on maximality.** `exists_maximal_extension` (Zorn over the extension order) is an
**internal lemma en route to `thm:extension`** — demoted from an earlier round's framing of it as
the target existence theorem. `isMax_of_total` is the load-bearing direction. Neither is the
validity predicate; see Decision A's standing constraint.

---

## Decision C — Omega: delete outright, in this task, without spawning

**Decision.** `Omega`, `ShiftClosed`, and every `τ ∈ Omega` hypothesis are removed from live code
(boneyards excluded), and the `regionFrame` deterministic re-host is done **inside this task**, not
spawned as a follow-up.

**Why the alternatives fail, in the order they fail:**

- **Retain-as-generalization is out.** It violates the charter's §9 "one uniform Omega-free API"
  directly, and it leaves live exactly the hedge the paper's own `cor:tm-completeness` footnote
  describes — which landing this refactor is supposed to make obsolete.
- **The split-scope option (land the Omega-free API now, spawn the `regionFrame` re-host as a
  follow-up) is not executable as framed.** Verified at plan time: `Bridge/DenseTruth.lean`,
  `Bridge/RegionLabel.lean`, `Bridge/IntTruth.lean`, `Bridge/TruthLemma.lean`, and
  `Bridge/Omega.lean` all call the **core** `TruthAt` with `regionOmega` as its `Omega` argument.
  Retargeting `TruthAt`'s box clause therefore breaks the decidability bridge *immediately* — and
  not merely syntactically: with `regionFrame`'s permissive
  `TaskRel = fun s d s' => d = 0 → s = s'`, `H_F` is the **full function space**, so
  `truthAt_box_iff_region`'s reduction becomes **false**. There is no green intermediate state in
  which the core API is Omega-free and `regionOmega` still functions; a follow-up split would leave
  the tree red *between two tasks*.
- **Doing the re-host here is templated, not novel.** The completeness side already made exactly
  this move: `multiFamTaskFrameGen` is deterministic-shift, so `multiFamGen_total_eq` holds and
  `multiFamOmegaGen` *is* `H_F`.

**Key distinction to keep in view.** Totality fixes the **empty-history** problem but **not** the
**junk-history** problem. `regionOmega ⊊ H_F` strictly, because a permissive `TaskRel` admits
arbitrary total junk histories. The decidability side needs a real carrier re-host, not a rewrite.

**Contingency, with precise ownership.** If the re-host proves materially larger than sized, spawn
**one** task owning **exactly**:
`FormalSystem/Metalogic/Decidability/Verified/Bridge/Omega.lean` (the `regionFrame` definition,
`regionHistory`, `regionOmega`, and their five declarations) plus consumer repairs in
`Bridge/Valuation.lean`, `Bridge/IntTruth.lean`, `Bridge/DenseTruth.lean`, `Bridge/TruthLemma.lean`,
`Bridge/RegionLabel.lean`, and whatever `Decidability/Verified/Decidable.lean` surfaces — **entirely
within the current Omega architecture**, delivering `regionOmega_eq_total` as its acceptance
criterion. That spawned task changes no API and is green standalone.

**The spawned task owns the *prerequisite*, never the follow-up.** The box-clause retarget blocks
on it. That ordering is what keeps the tree green and §9 intact. An implementer who invokes the
contingency must say so explicitly in the wrap-up rather than silently deferring the retarget.

---

## Decision D — the Omega collapse is ordered reverse-topologically, not atomically

**Decision.** Removing an `Omega` binder from a declaration breaks every declaration that mentions
it. The binder sweeps therefore proceed in **reverse dependency order**: a declaration may drop its
`Omega` binder only once every declaration that mentions it has already dropped its own.

Order: leaves first (`Tests/**`, `Examples/**`, `Automation/**`, `FrameConditions/**`), then
`Decidability/**`, then the canonical/algebraic completeness stack, and `Semantics/Truth.lean`'s own
parameter **absolutely last**.

**Rationale.** Each sweep owns a set closed under "callers of", so each sweep ends green. The
alternative — one tree-wide atomic edit — would exceed a single agent run and would leave no green
checkpoint to recover from. The **semantic retarget** (changing what the box clause *means*) is
kept strictly separate from the **mechanical binder churn** (removing the now-inert parameter);
conflating them is what makes a green intermediate impossible.

---

## The §7 acceptance criterion, and the invariant a future `TaskFrame`-axioms implementer MUST preserve

The charter's §7 requires that *Spherical*'s Lean statement be **literally the hypothesis
`lem:step`'s proof consumes** — not an inert structure field. That criterion is discharged in this
task, not deferred:

- *Spherical*, *Serial*, and *Interpolates* are introduced as `Prop`-valued predicates over a bare
  task relation.
- `lem:step` is proved **consuming `hSph : Spherical F.TaskRel` in its proof body**, at the sole
  application site the paper names. The acceptance check is performed, not asserted: **deleting
  `hSph` from `step`'s binder list must break the build.**

**Anchor.** `def:frame#Spherical`:

> `\item[\it Spherical:] $\bigcap \mathcal{S} \neq \emptyset$ for any directed family
> $\mathcal{S}$ of nonempty fibers and segments.`

and `lem:step`:

> `Every partial history $\tau : X \to W$ over a frame $\F = \tuple{W, \D, \Rightarrow}$ extends to
> a partial history on $X \cup \set{z}$ for any duration $z \in D$.`

### THE INVARIANT (binding on the four-axiom `TaskFrame` alignment work)

When the axiom fields are added to `TaskFrame`:

- `TaskFrame.spherical` must be **definitionally** `Spherical TaskRel`,
- `TaskFrame.serial` must be **definitionally** `Serial TaskRel`,
- the **interpolation half** of biconditional Compositionality must be **definitionally**
  `Interpolates TaskRel`,

all three as defined by the total-history-validity refactor. The axioms phase then discharges
`step`'s hypotheses by `F.spherical` / `F.serial` / `F.interpolates` — a mechanical substitution
with **zero restatement**.

**If a field lands whose statement differs, `step` stops typechecking.** That compilation failure
**is** the acceptance test. It is precisely why landing the hypothesis form first is safer than
waiting for the fields: it converts a silent cross-task divergence into a loud build break.

Two directed classes, kept separate: *Spherical* quantifies over directed families of **nonempty
fibers and segments** as **two separate classes**. The retired device by which one-sided fibers
counted among segments must not reappear. Directedness is its own definition (`def:directed`):

> `A nonempty family of sets $\mathcal{S}$ is \textit{directed} just in case
> $S \subseteq S_1 \cap S_2$ for some $S \in \mathcal{S}$ whenever $S_1, S_2 \in \mathcal{S}$.`

---

## Related records

- `specs/decisions/untl-snce-argument-order.md` — the open escalation on `untl`/`snce` argument
  order (paper footnote vs. Lean tree). **Not** decided here; the Lean convention is not changed.
- `specs/paper-definitions-of-record.md` — the pinned verbatim anchors every citation above
  resolves against.
