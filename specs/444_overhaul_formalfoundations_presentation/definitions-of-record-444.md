# Definitions of Record — FormalFoundations.typ Overhaul

Phase 1 output. Every restatement written into `typst/FormalFoundations.typ` during Phases 3–8
must be diffed against an anchor recorded here (Fidelity Bar V1). A restatement with no anchor
here is not written.

- **Paper**: `/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex`
- **Extraction date**: 2026-08-13
- **Repo commit at extraction**: `dfd00bb6c`

## Anchor line-number drift (recorded, not blocking)

The plan's Phase 1 task list cites line numbers taken from the research report. Every one of the
13 named anchors **still exists under its own `\label`**; only the line numbers have moved, by
roughly +27 lines. Since the anchors are located by label rather than by line, this is drift in
the citation, not a moved definition, and the Rollback/Contingency clause ("if the paper has
moved such that the recorded anchors no longer match, stop and mark `[BLOCKED]`") is **not**
triggered — the anchors match, and each is quoted verbatim below.

| Anchor | Plan/report line | Actual line |
|---|---|---|
| `def:temporal-order` | — | 2614 |
| `def:task-relation` | — | 2618 |
| `def:directed` | — | 2628 |
| `def:frame` | — | 2632 |
| `def:task-topology` | 2622–2632 | 2649 |
| `app:topology-t1` | 2653–2666 | 2680 |
| `app:topology-r0` | 2673–2680 | 2700 |
| `def:world-history` | 2707–2714 | 2734 |
| `def:BL-model` | 2876–2878 | 2903 |
| `def:BL-semantics` (atom `:2892`, Box `:2899`) | 2892 / 2899 | 2907 (atom 2919, Box 2925) |
| `def:frame-validity` | — | 3080 |
| `def:logical-consequence` | — | 3603 |
| `def:BLplus-language` | — | 3831 |
| `def:BLplus-semantics` | 3820–3823 | 3839 |
| `def:BX` | — | 3919 |

Supporting anchors also extracted: `lem:nullity` (2660), `lem:step` (2839),
`cor:spherical-finite` (2853), `thm:extension` (2866), `cor:occurrence` (2893),
`def:frame-properties` (3070), `def:BLplus-defined` (3855), `thm:BLplus-PastFuture` (3872),
`thm:BLplus-NextPrevious` (3888), `def:S5` (3900), `cor:tm-completeness` (4043),
`cor:tm-decidability` (4100).

---

## 1. `def:temporal-order` (`:2614`)

> A *temporal order* is a nontrivial totally ordered abelian group $\D = \tuple{D, +, 0, \leq}$
> with *positive cone* $D^+ \coloneq \set{x \in D : x \geq 0}$.

## 2. `def:task-relation` (`:2618`)

> A *task relation* on a nonempty set of *world states* $W$ over a temporal order $\D$ is any
> parameterized relation $w \Rightarrow_x u$ for $w,u \in W$ and $x \in D^+$, extended to
> negative durations by the *converse convention* $w \Rightarrow_{-x} u \coloneq u \Rightarrow_{x} w$
> for $x \geq 0$, determining the following for any world states $w, v \in W$ and durations
> $x, y \in D$:
>
> - *Fiber:* $\Fib(w, x) \coloneq \set{u \in W : w \Rightarrow_x u}$.
> - *Cone:* $(w)_x \coloneq \bigcup_{\vert{y} < x} \Fib(w, y)$ where $x > 0$.
> - *Segment:* $[w, v]_x^y \coloneq \Fib(w, x) \cap \Fib(v, -y)$ where $x, y \geq 0$.

**Note for Phase 3.** The paper attaches side conditions the current document drops: the cone is
defined only for $x > 0$, and the segment only for $x, y \geq 0$. The task relation is primitively
given only on $D^+$; negative durations are *defined* by the converse convention, not primitive.
$W$ is required nonempty here, at the task-relation level.

## 3. `def:directed` (`:2628`)

> A nonempty family of sets $\mathcal{S}$ is *directed* just in case $S \subseteq S_1 \cap S_2$
> for some $S \in \mathcal{S}$ whenever $S_1, S_2 \in \mathcal{S}$.

## 4. `def:frame` (`:2632`)

> A *frame* is any $\F = \tuple{W, \D, \Rightarrow}$ where $W$ is a nonempty set of world states,
> $\D$ is a temporal order, and $\Rightarrow$ is a task relation satisfying the following for
> $x, y \geq 0$:
>
> - *Compositionality:* $w \Rightarrow_{x + y} v$ if and only if $w \Rightarrow_x u$ and
>   $u \Rightarrow_y v$ for some $u \in W$.
> - *Seriality:* $w \Rightarrow_x u$ and $v \Rightarrow_x w$ for some $u, v \in W$.
> - *Limit:* $\bigcap_{x > 0} (w)_x = \set{w}$.
> - *Spherical:* $\bigcap \mathcal{S} \neq \emptyset$ for any directed family $\mathcal{S}$ of
>   nonempty fibers and segments.

**Note for Phase 3.** Compositionality is explicitly a biconditional. The four conditions are
constrained to $x, y \geq 0$. The document's current one-sentence rendering at `:127-128` is
faithful in content; it is the presentation (E1/E3), not the mathematics, that Phase 3 repairs.

## 5. `lem:nullity` (`:2660`)

> $w \Rightarrow_0 w$ for every world state $w \in W$ in every frame
> $\F = \tuple{W, \D, \Rightarrow}$.

Proof: *Seriality* at $x=0$ gives $w \Rightarrow_0 u$; $\vert 0 \vert < x$ for every $x>0$ puts
$u \in (w)_x$ for all $x>0$; *Limit* collapses the intersection to $\set{w}$, so $u = w$.
Choice-free.

## 6. `def:task-topology` (`:2649`)

> Given a frame $\F = \tuple{W, \D, \Rightarrow}$, define:
>
> - **Basic Opens:** $B_{\F} \coloneq \set{(w)_x : w \in W \text{ and } x \in D \text{ with } x > 0}$.
> - **Topology:** $\mathcal{T}_{\F} \coloneq \tuple{W, \mathcal{O}_{\F}}$ where $\mathcal{O}_{\F}$
>   is the result of closing $B_{\F}$ under arbitrary union and finite intersection.
> - **Discrete:** A topology is *discrete* just in case every subset of $W$ is open.
> - **Closure:** $\overline{S} \coloneq \set{w \in W : O \cap S \neq \emptyset \text{ for every
>   open } O \in \mathcal{T}_{\F} \text{ where } w \in O}$ for $S \subseteq W$.
> - **T1:** A topology is *T1* just in case $\overline{\set{w}} = \set{w}$ for all $w \in W$.
> - **R0:** A topology is *R0* just in case $w \in \overline{\set{u}}$ iff $u \in \overline{\set{w}}$
>   for all $w, u \in W$.

**Note.** The topology is on $W$ (world states), not on $H_{\F}$ or on $D$. The basic opens are
the cones. There is a further theorem `app:topology-nondiscrete` characterizing discreteness of
$\mathcal{T}_\F$, but it is **commented out** in the live source and must not be cited.

## 7. `app:topology-t1` (`:2680`)

> $\mathcal{T}_{\F}$ is T1 for every frame $\F$.

Proof, compressed: $\set{u} \subseteq \overline{\set{u}}$ is immediate from *Closure*. Conversely,
let $w \in \overline{\set{u}}$. By `lem:nullity`, $w \Rightarrow_0 w$, so every basic open $(w)_x$
with $x > 0$ contains $w$; hence $u \in (w)_x$ for every $x>0$. So for each $x > 0$ there is $y$
with $\vert y \vert < x$ and $w \Rightarrow_y u$, whence $u \Rightarrow_{-y} w$ by the converse
convention and $w \in (u)_x$. *Limit* then gives $w \in \bigcap_{x>0}(u)_x = \set{u}$, so $w = u$.

## 8. `app:topology-r0` (`:2700`)

> $\mathcal{T}_{\F}$ is *R0* for every frame $\F$.

Immediate corollary of T1.

## 9. `def:world-history` (`:2734`)

> A *partial history* over a frame $\F = \tuple{W, \D, \Rightarrow}$ is a function
> $\tau : X \to W$ on a nonempty set $X \subseteq D$ where $\tau(x) \Rightarrow_{y-x} \tau(y)$
> for all times $x, y \in X$.
> A *world history* is any partial history whose domain $X$ is *convex*, so that $y \in X$
> whenever $x, z \in X$ and $x < y < z$.
> A world history is *total*— equivalently, a *possible world*— just in case $X = D$.
> A partial history $\sigma$ *extends* $\tau$ just in case $\dom{\tau} \subseteq \dom{\sigma}$ and
> $\tau(x) = \sigma(x)$ for all $x \in \dom{\tau}$.
> The set of all total world histories over $\F$ is denoted $H_{\F}$.

**Note for Phase 3.** Five distinct clauses, one of which (the *extends* relation) the current
document omits entirely — it is needed to state `thm:extension`. The three-tier structure is
partial history → world history (convex domain) → total world history / possible world ($X = D$).

## 10. `lem:step` (`:2839`), `cor:spherical-finite` (`:2853`), `thm:extension` (`:2866`), `cor:occurrence` (`:2893`)

> **`cor:spherical-finite`.** Every frame $\F = \tuple{W, \D, \Rightarrow}$ with finite $W$
> satisfies *Spherical*, choice-free.

> **`thm:extension`.** Every partial history $\tau : X \to W$ over a frame
> $\F = \tuple{W, \D, \Rightarrow}$ is extended by some total world history $\sigma \in H_{\F}$.

> **`cor:occurrence`.** For any frame $\F = \tuple{W, \D, \Rightarrow}$, world state $w \in W$,
> and time $x \in D$, there is a total world history $\tau \in H_{\F}$ where $\tau(x) = w$, and so
> $H_{\F} \neq \emptyset$.

`thm:extension` proof shape: partial histories extending $\tau$ are ordered by extension; chains
are bounded by their unions; Zorn gives a maximal $\sigma : T \to W$; if $T \neq D$, `lem:step`
extends $\sigma$ to $T \cup \set{z}$, contradicting maximality. The `thm:extension` footnote
states the ZFC/choice-free contrast against `lem:nullity` and `cor:spherical-finite` explicitly.
`lem:step` is the sole *Spherical* application site, and its own proof notes that *Spherical* is
unnecessary when the directed family has a $\subseteq$-least member (`lem:nesting`).

## 11. `def:BL-model` (`:2903`) — **the anchor the current document contradicts**

> A *model* of $\BL$ is a structure $\M = \tuple{W, \D, \Rightarrow, \vert{\cdot}}$ where
> $\F = \tuple{W, \D, \Rightarrow}$ is a frame and $\vert{p_i} \subseteq W$ for every sentence
> letter $p_i \in \SL$.

**The error.** `typst/FormalFoundations.typ:136` asserts $\vert p \vert \subseteq H_{\F} \times D$.
The paper says $\vert p_i \vert \subseteq W$. Atoms are sets of **world states**, full stop.

## 12. `def:BL-semantics` (`:2907`)

> Truth in a model at a possible world $\tau \in H_{\F}$ and time is defined recursively:
>
> - ($p_i$) $\M,\tau,x \vDash p_i$ *iff* $\tau(x) \in |p_i|$.
> - ($\bot$) $\M,\tau,x \nvDash \bot$.
> - ($\shortrightarrow$) $\M,\tau,x \vDash \varphi \rightarrow \psi$ *iff*
>   $\M,\tau,x \nvDash \varphi$ or $\M,\tau,x \vDash \psi$.
> - ($\Box$) $\M,\tau,x \vDash \Box \varphi$ *iff* $\M,\sigma,x \vDash \varphi$ for all
>   $\sigma \in H_{\F}$.
> - ($\Past$) $\M,\tau,x \vDash \Past \varphi$ *iff* $\M,\tau,y \vDash \varphi$ for all $y\in D$
>   where $y < x$.
> - ($\Future$) $\M,\tau,x \vDash \Future \varphi$ *iff* $\M,\tau,y \vDash \varphi$ for all $y\in D$
>   where $x < y$.

**The corrected atom clause is $\tau(x) \in |p_i|$** — truth at a time is mediated entirely
through the world state the history occupies there. This is precisely the architecture Dana's
first question concerns.

**Box clause verdict**: the current document's rendering ("$\square$ quantifies over *all* total
world histories") matches verbatim. No repair needed.

## 13. `def:frame-properties` (`:3070`)

> A task frame $\F = \tuple{W, \D, \Rightarrow}$ is:
>
> - Discrete if for any $x \in D$, whenever there exists $y > x$, there is a least such $y' > x$
>   satisfying $z \geq y'$ for all $z > x$.
> - Dense if for any $x, y \in D$ where $x < y$, there exists $z \in D$ where $x < z < y$.
> - Complete if every nonempty $S \subseteq D$ bounded above has a least upper bound in $D$.
> - Deterministic if $u = v$ whenever $w \Rightarrow_x u$ and $w \Rightarrow_x v$ for
>   $w, u, v \in W$ and $x \in D$.

## 14. `def:frame-validity` (`:3080`)

> A well-formed sentence $\varphi$ of $\BL$ is *valid over a frame*
> $\F = \tuple{W, \D, \Rightarrow}$ which we may write $\vDash_{\F} \varphi$ if and only if
> $\M,\tau,x \vDash \varphi$ for every model $\M = \tuple{W, \D, \Rightarrow, \vert{\cdot}}$ where
> $\F = \tuple{W, \D, \Rightarrow}$, possible world $\tau \in H_{\F}$, and time $x \in D$.

Followed in the live source by: *"Since $H_{\F} \neq \emptyset$ for every frame by `cor:occurrence`,
frame validity is never vacuous."* And a footnote distinguishing the frame-fixed $H_\F$ from a
*general frame* in the Blackburn–de Rijke–Venema sense: a general frame restricts admissible
valuations to a Boolean subalgebra, whereas here **every** valuation $\vert p_i\vert \subseteq W$
is admissible; $H_\F$ constrains the points of evaluation, not the admissible propositions.

## 15. `def:logical-consequence` (`:3603`)

> A conclusion $\varphi$ is a *logical consequence* of a set of premises $\Gamma$— written
> $\Gamma \vDash \varphi$— just in case for all models $\M$, possible worlds $\tau \in H_{\F}$,
> and times $x \in D$, if $\M,\tau,x \vDash \gamma$ for all premises $\gamma \in \Gamma$, then
> $\M,\tau,x \vDash \varphi$.
> A sentence $\varphi$ is *valid* just in case $\vDash \varphi$.

## 16. `def:BLplus-language` (`:3831`)

> The language $\BL^+ \coloneq \tuple{\SL,\bot,\rightarrow,\Box,\since,\until}$ where
> $\SL \coloneq \set{p_i: i\in \N}$ is a countable set of sentence letters as before where the
> remaining symbols denote falsity, material implication, the metaphysical necessity operator,
> the since operator, and the until operator, respectively.
> Well-formed sentences of $\BL^+$ are defined by:
> $\varphi, \psi \Coloneq p_i \mid \bot \mid \varphi \rightarrow \psi \mid \Box\varphi \mid
> \varphi\since\psi \mid \varphi\until\psi$.

**Note.** The paper's Since/Until are written **infix**, not prefix. The current document's
$S(\varphi,\psi)$ / $U(\varphi,\psi)$ prefix rendering departs from the paper's notation.

## 17. `def:BLplus-semantics` (`:3839`)

> - ($\since$) $\M,\tau,x \vDash \varphi\since\psi$ *iff* $\M,\tau,z \vDash \psi$ for some time
>   $z < x$ where $\M,\tau,y \vDash \varphi$ for all $y \in D$ with $z < y < x$.
> - ($\until$) $\M,\tau,x \vDash \varphi\until\psi$ *iff* $\M,\tau,z \vDash \psi$ for some time
>   $z > x$ where $\M,\tau,y \vDash \varphi$ for all $y \in D$ with $x < y < z$.

## 18. `def:BLplus-defined` (`:3855`)

> Past: $\past\varphi \coloneq \top\since\varphi$. Future: $\future\varphi \coloneq \top\until\varphi$.
> Historical: $\Past\varphi \coloneq \neg\past\neg\varphi$. Henceforth: $\Future\varphi \coloneq \neg\future\neg\varphi$.
> Always: $\always\varphi \coloneq \Past\varphi \wedge \varphi \wedge \Future\varphi$.
> Sometimes: $\sometimes\varphi \coloneq \past\varphi \vee \varphi \vee \future\varphi$.
> **Next: $\Next\varphi \coloneq \bot\until\varphi$. Previous: $\Previous\varphi \coloneq \bot\since\varphi$.**

## 19. `def:BX` (`:3919`) — 17 named keys

> Letting $\varphi_{\tuple{\textsc{s}|\textsc{u}}}$ denote the result swapping occurrences of
> $\since$ and $\until$ in $\varphi$, **BX** is the *Base Burgess–Xu Tense Logic* axiomatized below
> **where the past/since direction of each axiom follows from the future/until direction**.

Rules: **TN** ($\vdash\varphi \Rightarrow \vdash\Future\varphi$), **TD** (the S/U-swap duality
rule). Seriality/linearity/connectedness: **TB** $\future\top$; **TL**; **CN**. Primary Since/Until:
**TA** $\varphi \rightarrow \Future\past\varphi$; **UE**; **UT**; **UI**; **UC**; **UF**; **UG**;
**SU**. Uniformity (vacuous unless discrete): **NP** $\Next\top\rightarrow\Previous\top$;
**NF** $\Next\top\rightarrow\Future\Next\top$; **NA** $\Next\top\rightarrow\Past\Next\top$;
**NB** $\Next\top\rightarrow\Box\Next\top$.

Total: 2 rules + 11 axioms + 4 uniformity = 17 keys.

---

# Gap Decisions

## G2 — Since/Until argument order: **CLOSED. The current document is backwards.**

Three independent sources, all read directly:

1. **The paper's own clause** (`def:BLplus-semantics`, above): in $\varphi \since \psi$ the
   witnessed **event is $\psi$** (the second argument), the **guard is $\varphi$** (the first).
   The paper is **guard-first**.
2. **The paper corroborates itself** at `def:BLplus-defined`: $\past\varphi \coloneq \top\since\varphi$
   — guard $\top$, event $\varphi$. And $\Next\varphi \coloneq \bot\until\varphi$ — guard $\bot$,
   event $\varphi$.
3. **The Lean source, read directly** (`FormalSystem/Semantics/Truth.lean:153-155`):
   `| Formula.snce φ ψ => ∃ s : D, s < t ∧ TruthAt M τ s φ ∧ ∀ r, s < r → r < t → TruthAt M τ r ψ`
   — here **`φ` is the event** (witnessed at `s`) and **`ψ` is the guard** (holding throughout).
   The Lean tree is **event-first**. Corroborated by `Formula.lean:141`
   `somePast φ := Formula.snce φ Formula.top` (event `φ`, guard `⊤`) and `Formula.lean:493`
   `next φ := Formula.untl φ Formula.bot`.

**Verdict.** `FormalFoundations.typ:117` says the paper's $S$/$U$ are "in the Burgess *event-first*
convention: $\varphi$ is the event, $\psi$ the guard." **This is exactly backwards for the paper's
own notation**, which is what the document purports to present. Event-first is the *Lean* tree's
convention.

The live paper footnote at `def:BLplus-semantics` states the mismatch correctly in the direction
that holds. Note that `specs/decisions/untl-snce-argument-order.md` quotes an **older, since-corrected**
version of that footnote (the "Pnueli convention" version) and is stale on that point; the live
paper text supersedes it. The Lean docstring at `Truth.lean:137-142` likewise calls the footnote
"backwards" — that docstring is stale in the same way, since the footnote has since been fixed.

**Decision, with reason.**
- Present the paper's own **infix, guard-first** notation: $\varphi \mathbin{S} \psi$ and
  $\varphi \mathbin{U} \psi$, with $\varphi$ the guard holding throughout the interval and $\psi$
  the event witnessed at the endpoint. Reason: the document restates the paper's language for a
  reader assumed unfamiliar with it; presenting the paper's own notation is the only choice that
  does not require the reader to translate.
- **Drop the Lean-convention footnote entirely.** Reason: it is a note about an internal
  constructor convention of a repository the reader is not reading, it is the direct cause of the
  error now in the file, and it fails E3 (a remark must state a mathematical fact, a dependency,
  or an open question).
- **Write the discreteness indicator as $\Next\top$, never as $U(\top,\bot)$.** Reason: the
  document currently writes `U(⊤,⊥)` at `:289`, which is the **Lean** argument order; the paper's
  order would make it $\bot \mathbin{U} \top$. Using the *defined* operator $\Next\top$ is correct
  under either convention and removes the hazard at the one site where it bites. Lean's
  `dense_indicator` axiom may still be cited by name.

## G1 — BX / paper-BX identification: **CLOSED. State the reconciliation; keep the hedge.**

**Measured.** The paper's `def:BX` has **17 named keys**: 2 rules (TN, TD) + 11 axioms
(TB, TL, CN, TA, UE, UT, UI, UC, UF, UG, SU) + 4 uniformity axioms (NP, NF, NA, NB).

`typst/SYNC-MAP.md:147` records Lean's **BX Temporal layer at 22 constructors**, and names them
in explicit primed/unprimed pairs: serial_future/past (BX1/BX1′), left_mono_until_G /
left_mono_since_H (BX2G/BX2H), right_mono_until/since (BX3/BX3′), connect_future/past (BX4/BX4′),
enrichment_until/since (BX13/BX13′), self_accum_until/since (BX5/BX5′), absorb_until/since
(BX6/BX6′), linear_until/since (BX7/BX7′), until_F / since_P (BX10/BX10′), temp_linearity(_past)
(BX11/BX11′), F_until_equiv / P_since_equiv (BX12/BX12′).

**That is exactly 11 pairs.** The paper's 11 primary axioms and Lean's 22 temporal constructors
stand in exact bijection, one paper axiom to one future/past pair.

**The explanation of the numeric gap.** The paper's `def:BX` says in its own preamble that "the
past/since direction of each axiom follows from the future/until direction", and discharges that
with the **TD duality rule** — so the paper states 11 axioms and derives their 11 mirrors. The
Lean tree has **no TD rule**; it states both directions as separate constructors. 11 + 11 = 22.
The gap is duality bookkeeping, not a difference in content.

The uniformity layer does **not** match as cleanly: the paper's 4 keys (NP, NF, NA, NB) face 5
Lean constructors (`discrete_symm_fwd`, `discrete_symm_bwd`, `discrete_propagate_fwd`,
`discrete_propagate_bwd`, `discrete_box_necessity`), NP evidently splitting into two directions.

**Decision, with reason.** State the reconciliation in one sentence — the numeric gap is
TD-duality bookkeeping, with an exact 11-to-11-pair correspondence on the primary layer — **and
retain the hedge** that no theorem in the tree establishes that the two axiomatizations prove the
same set of formulas. Reason: the reconciliation is a real, checkable fact that the reader is
entitled to, and withholding it while hedging would be uninformative; but the reconciliation is a
correspondence of *shape*, not a machine-checked deductive equivalence, and the uniformity layer
does not even match numerically. Asserting equivalence would be the one unverified claim in the
document.

**Consistency requirement (Phase 10 audits this).** Wherever the identification appears, the Lean
frame-class vocabulary (`FrameClass.Dense` / `Discrete` / `Base` / `Dedekind`) is used and is
never silently renamed to the paper's $\mathbf{TM}^+_\textsc{d}$ etc., and the hedge accompanies
it. An inconsistent posture is worse than either choice.

## G3 — Topology depth: **CLOSED. Definition plus theorem.**

**Decision.** Phase 3 writes a `#definition` for the task topology (basic opens = cones; the
closure operator; T1; R0) and a `#theorem` stating that $\mathcal{T}_\F$ is T1 for every frame,
with R0 as a `#corollary`, plus one bounded `#remark` posing the partial-history-as-restriction
question as a live definitional question rather than settling it silently.

**Reason.** This is the reader's own most-developed question (~40% of the email), and it is the
justification he himself offers for the identification he is asking about. A bare remark would
under-serve it. The cost is bounded: the T1 proof compresses to three lines (Nullity puts $w$ in
every basic open around $w$; the converse convention transposes; *Limit* collapses), and R0 is
immediate. A full proof-plus-discussion treatment would overrun the page budget without adding
anything the reader cannot reconstruct.

**Constraint.** `app:topology-nondiscrete` is commented out in the live paper source and must not
be cited.

## G4 — Out-of-scope acknowledgment

Executed in Phase 9: one line acknowledging that complexity (as distinct from decidability),
interpolation, and finite axiomatizability are known-open and out of scope.

---

# Re-stamped Status Counts

`scripts/typst-status-counts.sh --json`, re-run at commit `dfd00bb6c` (2026-08-13):

```json
{
  "axiom_count": 45, "rule_count": 7, "base_count": 37,
  "dense_only_count": 2, "discrete_only_count": 3, "dedekind_only_count": 3,
  "sorry_total": 5, "sorry_total_excl_boneyard": 1,
  "sorry_algebraic": 0, "sorry_bxcanonical": 0, "sorry_bundle": 0,
  "sorry_weakcanonical": 5, "sorry_weakcanonical_excl_boneyard": 1,
  "sorry_other": 0,
  "stamp_commit": "dfd00bb6c", "stamp_date": "2026-08-13"
}
```

**Diff against the plan's Scope Hypothesis** (`sorry_total=5`, `sorry_total_excl_boneyard=1`,
`sorry_algebraic=0`, `sorry_bxcanonical=0`, `sorry_bundle=0`): **all five identical**. The only
field that moved is `stamp_commit`, from the document's current `c2b8da5d6` to `dfd00bb6c`.
Phase 6 re-stamps the commit and re-derives nothing.

# FIX Disposition Table

`grep -c "FIX:" typst/FormalFoundations.typ` returns **11**, at lines **93, 113, 123, 126, 135,
174, 189, 208, 231, 285, 337** — **exactly** the plan's Scope Hypothesis. No amendment needed.

| Line | Verbatim subject | Owning phase | Resolution |
|---|---|---|---|
| 93 | "no indent here, and smaller font, creating an environment as appropriate" | 9 | Local `abstract-block` helper; abstract rewritten for the five-section document |
| 113 | "definitions and notation depart from possible_worlds.tex … focus on the extended language using the same symbol $\BL^+$ … leaving off mention of $\BL$ except perhaps for a footnote" | 3 | $\BL^+$ primary throughout; $\BL$ demoted to one footnote with the paper link |
| 123 | "the converse convention deserves its own definition, as do the other definitions used below" | 3 | Temporal Order, Task Relation (Fiber/Cone/Segment as labelled clauses), converse convention split into environments |
| 126 | "this definition also feels scrunched up and should be expanded into indented elements" | 3 | Frame's four axioms expanded via `template.typ`'s `items`/`item` |
| 135 | "$\vert p\vert \subseteq H_\F \times D$ is wrong … requiring careful analysis throughout" | 3 (write), 10 (audit) | $\vert p_i\vert \subseteq W$, atom clause $\tau(x) \in \vert p_i\vert$; document-wide faithfulness pass |
| 174 | "poorly stated and confusing … drill down to the Henkin constructions" | 4 (compress), 5–6 (constructions) | Correspondence claims kept, framing prose cut; the constructions get Phases 5–6 |
| 189 | "meta-commentary like '— Stated Exactly, Unsoftened' is empty noise … virtually no substance" | 4 (rewrite), 2 (headings), 9 (sweep) | Per-system completeness theorems; heading qualifiers deleted |
| 208 | "quality of this section is very poor … EVERY ISSUE should be introduced through a formal lens" | 7 | Irregular worlds as `#definition`; the price as `#proposition` |
| 231 | "this section can be dropped entirely … focusing all attention on TM$^+$" | 2 (fold), 5 (restate) | Section retired as a named pain point; (DD) restated for $\BL^+$ via $\Next\top$ inside the construction section |
| 285 | "presenting the Henkin construction in precise formal detail … citing relevant literature" | 5 and 6 | Definition-plus-theorem per branch, credits at the construction |
| 337 | "ALL that is needed are the precise formal mechanics briefly introduced" | 8 | Waypoint cut to one sentence; algebraic layer first; one closing question |

# Verbatim Quoted Passages (Phase 7 re-verifies these against the live paper)

## Q1 — Irregular worlds (`sub:Extension`, footnote at `:1279-1283`, **unlabelled**)

Verified verbatim 2026-08-13. The document's block quote at `:216-218` matches the live source
word for word across all four sentences. The trailing sentence

> "The broadened operator also satisfies factivity, normality, and necessitation relative to the
> broadened consequence relation, displacing $\Box$ from its standing as $\mathrm{Str}^{\OO}_{L}(\Box)$."

**remains commented out** in the live source and must not be cited as paper text. The document's
current discipline at `:221` — attributing point (iv) to the report's own analysis — is correct
and is preserved.

Dorr and Goodman are cited by the paper at **p. 656** for the contingency-of-temporal-structure
sympathy (the separate `rmk:dg-parity` cites p. 635 for Symmetry).

## Q2 — Stability (`sub:RestrictedModalities`, live footnote)

To be re-verified at Phase 7 authoring. The general lesson drawn from it is the report's own
analysis; the paper's own sentence stating it generally is commented out.

---

# Phase 10 Audit Verdicts

Adversarial read of the finished document against the paper and the Lean tree, conducted as a
read against sources before any repair. Two discrepancies were found and repaired; both are
recorded below.

## A1 — Declaration-existence sweep (V2)

Every backticked identifier-shaped span in the document was extracted (44 candidates) and
matched against the set of *actual declaration names* under `FormalSystem/` excluding
`Boneyard/`, parsed from `theorem`/`lemma`/`def`/`abbrev`/`structure`/`inductive`/`instance`/
`class` binders. This is strictly stronger than `scripts/typst-sync-check.sh`'s Check 1, which
greps for the string anywhere in a `.lean` file and therefore accepts a name that appears only
in a docstring — the exact failure mode that let the pre-rewrite document cite `limit_chronicle`,
which is not a declaration.

**Verdict: no unresolved declaration remains.** Every non-matching span is one of:
`.lean` filenames (`BooleanStructure.lean`, `FlowFrame.lean`, `InteriorOperators.lean`,
`UltrafilterMCS.lean`, `Shuffle.lean`, `ShuffleReal.lean`, `EpsilonDense.lean`,
`OrderIsoReal.lean`); Lean core axioms and keywords (`propext`, `Classical.choice`, `Quot.sound`,
`sorryAx`, `sorry`); or constructors of `inductive FrameClass` (`FrameClass.Base`, `Dense`,
`Discrete`, `Dedekind`), which the binder parser does not enumerate.

## A2 — Environment citation sweep (E4)

46 environments. Every one carries either a paper anchor footnote citing
`@brastmckie2026possibleworlds` or a `#leansrc` block, except `#definition("Shift set")`.

**Verdict: correct as it stands.** The shift-set definition is deliberately uncited: it names a
design target with no paper anchor and no Lean identifier, and the adjacent prose states exactly
that ("no such identifier exists anywhere in the tree, and the programme is not started"). The
status claim is traceable even though the definition is not; nothing is asserted as proved.

## A3 — Definition diffs against recorded anchors (V1)

| Document environment | Anchor | Verdict |
|---|---|---|
| Language | `def:BLplus-language` | PASS (infix, as the paper writes it) |
| Defined Operators | `def:BLplus-defined` | PASS (all four clauses, paper's order) |
| Temporal Order | `def:temporal-order` | PASS |
| Task Relation | `def:task-relation` | PASS (side conditions restored) |
| Directed Family | `def:directed` | PASS |
| Frame | `def:frame` | PASS (biconditional preserved) |
| Nullity | `lem:nullity` | PASS (proof matches) |
| History | `def:world-history` | PASS (all five clauses) |
| Extension / Occurrence | `thm:extension`, `cor:occurrence` | PASS |
| Task Topology | `def:task-topology` | PASS on the four clauses used; the Discrete clause is deliberately omitted (unused; `app:topology-nondiscrete` is commented out and uncitable) |
| Separation | `app:topology-t1`, `app:topology-r0` | PASS |
| Model | `def:BL-model` | PASS — **the corrected clause** |
| Truth | `def:BL-semantics`, `def:BLplus-semantics` | PASS — atom clause is `τ(x) ∈ |p_i|` |
| Frame Properties | `def:frame-properties` | PASS |
| Validity and Consequence | `def:frame-validity`, `def:logical-consequence` | PASS |
| S5 | `def:S5` | PASS |
| BX | `def:BX` | PASS (17 keys; TD-duality note correct) |
| Extensions table (DN, NN) | `def:TMplus-d` | PASS — re-verified at `:3989`: DN is `GGφ → Gφ`, NN is `¬Next⊤` |
| Irregular World | `sub:Extension` footnote | PASS (re-verified verbatim) |
| Strongest Objective Normal Modal Operator | `def:strongest` | PASS |
| Existence | `thm:exist` | PASS |
| Uniqueness and logic | `lem:uniq`, `thm:s4`, `thm:sym` | PASS |
| Orthogonality | live Stability footnote | PASS (re-verified verbatim) |

## A4 — Atom-interpretation propagation

Every occurrence of a valuation or model-structure paraphrase was re-read. `|p_i| ⊆ W` appears at
the Model definition and again in the general-frame remark; the atomic clause is `τ(x) ∈ |p_i|`;
no occurrence of `H_F × D` survives anywhere. The Correspondence proposition's Complete case
interprets an atom as the lower half of a Dedekind cut on the translation-flow frame, where
`W = D`, so that reading is consistent with the corrected definition and required no repair.
The Box clause, frame validity, and logical consequence all match their anchors verbatim.

**Verdict: propagation complete; no residual drift.**

## A5 — Status labels against tree state

Base-frame `completeness` carries `sorryAx` and is stated as outstanding, not upgraded. The three
sorry-free results are cited only with their measured axiom reports. `kampPriorExpressiveCompleteness`
is labelled open, matching its status. The Jónsson–Tarski material is labelled archived; the
subtree `Boneyard/UltrafilterFrame/` exists and contains `TenseS5Algebra.lean` and
`UltrafilterFrame.lean`. The shift-set programme is labelled not started; no `ShiftSet`/`shiftSet`
identifier exists anywhere. No archived content is described as live.

One stale *source* was found and routed around rather than repeated:
`FormalSystem/Metalogic/Algebraic/README.md` lists `AlgebraicCompleteness.lean` as live and
sorry-free, but that file is in `Boneyard/UltrafilterFrame/`. The document cites only the five
modules actually present in `Metalogic/Algebraic/`. Editing the README is a non-goal.

**Verdict: PASS.**

## A6 — G1 posture consistency: **DISCREPANCY FOUND AND REPAIRED**

The Phase 4 text stated the three machine-checked results as claims about the paper's systems
($\mathbf{TM}^+_\textsc{d}$, $\mathbf{TM}^+_\textsc{f}$, $\mathbf{TM}^+_\textsc{c}$) while citing
Lean declarations about `FrameClass.Dense`/`Discrete`/`Dedekind` — making exactly the
identification that the Phase 6 remark calls a conjecture and claims is "treated as one
throughout". Two sections, opposite postures.

**Repair**: the three theorems are restated in the development's own frame-class vocabulary, which
is what both the Lean statements and the paper's proof actually establish, with one sentence
recording that the paper attributes them to its systems and that the identification is a
conjecture, cross-referenced to the Phase 6 remark. The posture is now uniform.

## A7 — Since/Until argument order (G2)

Every occurrence of `◁`/`▷`, `Next`, and `Prev` was checked against the Phase 1 decision. All are
infix and guard-first, and all agree with the paper: `Pφ := ⊤ ◁ φ`, `Fφ := ⊤ ▷ φ`,
`Prev φ := ⊥ ◁ φ`, `Next φ := ⊥ ▷ φ`; the truth clauses witness the event at the second argument.
The discreteness indicator is written `Next⊤` everywhere and never as `U(⊤,⊥)`, which is the Lean
order. The case-split membership conditions were checked against `mcs_mixed_case_absurd`'s actual
hypotheses (`¬□(¬Next⊤) ∈ A` and `¬□Next⊤ ∈ A`) and match.

**Verdict: PASS, no residual.** One adjacent overstatement was found and repaired: the case-split
figure caption described the Dedekind branch as "the dense branch specialized to ℝ", which
conflates the case split with the construction — the Dedekind route uses a different construction
(shuffle plus order-isomorphism), and what is true is only that it needs no split.

## A8 — Quoted passages (V1)

Both re-verified against the live paper on 2026-08-13: the irregular-worlds footnote
(`:1279-1283`), whose displacement sentence remains commented out and is not cited as paper text;
and the Stability footnote (`:1079-1083`).

**Verdict: PASS.**

## Summary

Two discrepancies found, both repaired in place: the G1 posture inconsistency (A6) and the
case-split caption overstatement (A7). No discrepancy remains open, and nothing unresolved is
asserted in the document — the three genuinely open items are stated as open questions.
