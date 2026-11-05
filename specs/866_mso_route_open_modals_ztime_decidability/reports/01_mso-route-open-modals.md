# Research Report: Task #866 — the MSO route and the open modals at ZTime

- **Task**: 866 - MSO route: do the open modals ride the encoding that decides L⁺ validity at ZTime?
- **Started**: 2026-11-05T05:43:00Z
- **Completed**: 2026-11-05T05:55:00Z
- **Effort**: ~15 minutes (cheap by design)
- **Dependencies**: None (independent of the ladder/RaySummary front and of Gabbay separation)
- **Sources/Inputs**:
  - `specs/559_nondeterministic_canonical_model_tm_star_completeness/reports/03_axiomatizability-rules-engine.md` sections 1.1, 1.2, 1.3, 1.4 (read in full this session)
  - `FormalSystem/OpenLanguage/OpenClasses.lean`, `OpenTruth.lean`, `FormalSystem/OpenLanguage.lean` (the `▷`/`◁` semantics)
  - `FormalSystem/PlusLanguage/PlusPasting.lean` lines 243-249 (`AgreeFrom`, `AgreeUpTo`)
  - `FormalSystem/Semantics/HistoryMorphism.lean` (`HistMap`, `HistMorphism`, `plus_invariance`, `TwoWayBounded`, `plus_invariance_of_isZTime`)
  - `FormalSystem/Metalogic/Decidability/WitnessFamily/Compression/Assembly.lean`, `FormalSystem/Metalogic/ZTimeProvability.lean` (scope of the landed decidability)
  - `FormalSystem/Metalogic/Expressiveness/OpenFutureElimination.lean` (the competing Gabbay-conditional route)
  - `FormalSystem/Syntax/Formula.lean` (base-language constructor list)
  - Mathlib lookup MCP (`lean_leansearch`, 2 queries) for ω-automata / MSO infrastructure
- **Artifacts**: `specs/866_mso_route_open_modals_ztime_decidability/reports/01_mso-route-open-modals.md`
- **Standards**: report-format.md, subagent-return.md
- **Task Type**: formal
- **Domains**: logic (primary: modal/temporal definability, MSO translation), math (secondary: order and reachability structure of oriented forests)

## Executive Summary

- **Verdict: YES.** The open-future modal `▷` and the open-past modal `◁` are MSO-definable in
  report 03's step-4 encoding, with no new machinery. In the `(P, x)` encoding the restriction is
  `∀y (y ⊑ x → (y ∈ P ↔ y ∈ P'))`, where `⊑` is directed reachability in the oriented forest —
  one extra first-order conjunct inside a quantifier `∀P'` that `⊡` already pays for. `◁` is the
  mirror with `x ⊑ y`. Derived this session, not recalled.
- **The invariance step also survives.** `▷`/`◁` truth is preserved along the cover map of report
  03 section 1.2, because the lifted witness reuses the given history's past verbatim and only
  needs forward lifting from the basepoint at `x` (backward, for `◁`). This is *weaker* than what
  the compiled `HistMorphism.plus_invariance` already uses for `⊡`, which needs two-sided lifting
  through one pinned state.
- **One step needs amendment, and it is step 1, not step 4.** The countable-model step's economy
  "one witness per (state, diamond subformula)" relies on state-locality and is unavailable for
  `▷`/`◁`, whose witnesses depend on a whole past. Countability survives (one witness per
  (walk, time, subformula) is still countable); what does not survive is the economy.
- **Two pre-existing gaps in report 03 section 1.3 found while checking it.** Step 1's induction
  needs witnesses at every walk of the sub-digraph, not only at the designated countable set;
  and step 3 yields a *forest* of countably many trees while step 5 applies Rabin to one tree.
  Both are present already for `⊡` and neither is introduced by the open modals. The forest gap
  is repairable by a standard new-root coding; the step-1 gap is the weakest link in the whole
  argument and is where any attempt to make this rigorous should start.
- **Recommendation: file ONE small Lean task, not the decidability result.** The `▷`/`◁`
  invariance lemma is cheap and independently useful (est. 150-350 lines). The MSO route's
  conclusion is not formalizable at acceptable cost: Mathlib has DFA/NFA/regular expressions and
  **no** ω-automata, MSO, or Rabin tree theorem. Keep the decidability claim as a paper result.

## Context & Scope

Evaluated: whether report 03 section 1.3's five-step paper argument for decidability of L⁺
validity at ZTime extends to L^▷ — L⁺ plus `▷` and `◁` — and at what cost.

Constraints honoured, as the dispatch requires:

- **Nothing here is verified in Lean.** Report 03 section 1.3 is a paper argument and this report
  does not change that. Every claim below carries one of: *compiled* (machine-checked in this
  repository), *derived* (a paper derivation performed in this session), *paper* (report 03's own
  paper-level claim, inherited), *held* (source document consulted), *recalled* (from memory, no
  source in hand).
- **No finite model property is claimed.** Report 03 states the FMP is not established, because
  folding a regular tree by subtree type forgets what lies above a node. That stands, and the
  open modals make it strictly worse rather than better: `▷` reads the entire past of the point
  of evaluation, which is exactly the information subtree-type folding discards.
- **The landed ZTime decidability is a different result.** `Compression.decidableValidZTime` and
  `ZTimeProvability.decidableDerivableZTime` both take `Formula`, whose constructors are
  `atom | bot | imp | box | untl | snce` (`FormalSystem/Syntax/Formula.lean:76-88`, read this
  session) — the base language, with no stability modal. Neither extends to `⊡`, and a fortiori
  neither extends to `▷`/`◁`. Nothing below leans on them.
- **Base, Dense and RTime remain open.** Report 03 section 1.4 locates the obstruction (the
  method needs tree models; lifting a total history over a general duration needs a relative
  form of Saturation that no known tree-like preimage has; and over ℝ the MSO route is blocked
  independently, MSO over ℝ being undecidable — *recalled*). Nothing in this report touches
  those classes. The MSO route reaches **ZTime only**.

## Domain Analysis

Primary domain **logic**: the question is a definability question about two modal operators
inside an MSO translation, and its resolution is a translation argument plus a bounded-morphism
invariance argument.

Secondary domain **math** (order/reachability): the load-bearing structural facts are properties
of the oriented forest produced by report 03 section 1.2 — unique directed paths, absence of
directed cycles, and the first-order definability of directed reachability from the rooted-tree
order together with the parent-edge orientation predicate. These are order-theoretic, not
logical, and they are what make the new restriction cheap rather than expensive.

No physics content.

## Findings

### 1. The honesty check: report 03 never mentions the open modals (verified)

`grep -ni "open"` over
`specs/559_nondeterministic_canonical_model_tm_star_completeness/reports/03_axiomatizability-rules-engine.md`
returns 11 lines (run this session). Every one is either the status word `OPEN`/`open` applied to
Base/Dense/RTime r.e.-ness or to a located open question, or the phrase "open question". There is
no occurrence of `▷`, `◁`, "open future", "open past", or "restricted modal". The contribution
recorded below is therefore new relative to that report, as the dispatch asked be confirmed
before starting.

### 2. The semantics being encoded (compiled)

From `FormalSystem/OpenLanguage/OpenTruth.lean:92-93`, the two clauses are literally

- `.ofut φ => ∀ σ, AgreeUpTo τ σ t → OpenTruthAt M σ t φ`
- `.opast φ => ∀ σ, AgreeFrom τ σ t → OpenTruthAt M σ t φ`

and from `FormalSystem/PlusLanguage/PlusPasting.lean:243-249`,
`AgreeUpTo τ σ t := ∀ s, s ≤ t → τ.state s = σ.state s` and
`AgreeFrom τ σ t := ∀ s, t ≤ s → τ.state s = σ.state s`.

So both modals are universal quantifiers over histories, restricted by *state-wise agreement on
a closed ray* — closed downward at `t` for `▷`, upward at `t` for `◁`. `⊡` is the same shape with
the degenerate ray `{t}` (`stabClass τ x = {σ | τ.state x = σ.state x}`,
`OpenClasses.lean:76-78`). The inclusions `openFutureClass_subset_stabClass` and
`openPastClass_subset_stabClass` are compiled; so is the time-reflection symmetry
(`openTruthAt_rev`, `openValid_reflectTime`), which is why the `◁` half below needs no separate
argument beyond naming the mirror.

### 3. Step 4 accommodates `▷` and `◁` directly (derived)

Report 03 step 4 encodes a walk with a marked time as a pair `(P, x ∈ P)`, where `P` is a set of
nodes that is connected and has exactly one in-neighbour and one out-neighbour in `P` at each
node. Write `⊑` for directed reachability in the forest. Then:

**Claim.** For `P, P'` both encoding walks and both containing `x`:
`P` and `P'` agree at every time `≤ x` **iff** `∀y (y ⊑ x → (y ∈ P ↔ y ∈ P'))`.

*Derivation.* In the cover, world states *are* nodes, so agreement at a time is equality of the
node occupied at that time.

1. `P` is a bi-infinite directed path. Each node of `P` has exactly one `P`-in-neighbour and one
   `P`-out-neighbour, so `P` is a disjoint union of bi-infinite directed paths and directed
   cycles; an oriented forest has no directed cycle (two nodes on one would be joined by two
   distinct directed paths, contradicting section 1.2's uniqueness); connectedness leaves one
   component. The marked `x` then fixes the time indexing: the node at time `x - k` is the unique
   node of `P` at directed distance `k` to `x`.
2. **`{y : y ∈ P ∧ y ⊑ x}` is exactly `P`'s backward ray from `x`.** If `y ∈ P` and `y ⊑ x` but
   `y` sat at a `P`-time `> x`, then `P`'s own segment gives a directed path `x → y` and `y ⊑ x`
   gives one `y → x`, composing to a directed cycle — impossible. Conversely a node of `P` at
   time `≤ x` reaches `x` along `P`.
3. By uniqueness of directed paths, two backward rays ending at `x` that are **equal as sets**
   are equal as time-indexed sequences. So set equality of the two backward rays is exactly
   time-wise agreement at every `t ≤ x`. Combined with step 2, the displayed first-order
   condition says precisely that. ∎

Hence the translation clause is

```
⟦▷ψ⟧(P, x)  :=  ∀P'. [ Walk(P') ∧ x ∈ P' ∧ ∀y (y ⊑ x → (y ∈ P ↔ y ∈ P')) ] → ⟦ψ⟧(P', x)
⟦◁ψ⟧(P, x)  :=  ∀P'. [ Walk(P') ∧ x ∈ P' ∧ ∀y (x ⊑ y → (y ∈ P ↔ y ∈ P')) ] → ⟦ψ⟧(P', x)
```

against report 03's `⟦⊡ψ⟧(P, x) := ∀P'. [Walk(P') ∧ x ∈ P'] → ⟦ψ⟧(P', x)`. The dispatch's
hypothesis — "the same shape as box-dot's `for all P' containing x`, with a restriction that is
itself MSO-expressible" — is confirmed exactly.

**The restriction costs less than MSO.** `⊑` is *first-order* over the rooted tree's order
relation plus the parent-edge orientation predicate that step 3 already supplies, with no
transitive-closure quantifier: letting `m` be the meet of `y` and `x` in the tree order,
`y ⊑ x` holds iff every node on `(m, y]` has its parent edge oriented child-to-parent and every
node on `(m, x]` has its parent edge oriented parent-to-child. (The undirected tree path is
unique; by section 1.2 a directed walk in an oriented forest is a reduced path, so a directed
path from `y` to `x`, if any, is that tree path, monotonically oriented.) So the two new clauses
add **no quantifier alternation** over what `⊡` already pays, and in particular do not change the
shape of the final sentence that step 5 feeds to Rabin's theorem.

**`▷` and `◁` are also strictly better behaved than `□` here**: their quantifiers are
component-local (a walk agreeing with `P` on a ray shares nodes with `P`, hence lies in `P`'s
tree), whereas `□` ranges over the whole forest. This matters for finding 6 below.

### 4. The cover step (1.2) also carries `▷` and `◁` (derived)

Report 03 section 1.1 warns that the Ockhamist past-splitting unravelling is **not** a two-way
bounded morphism — *back* fails and `⟐Pq` changes value. That warning does not apply to the
cover map of section 1.2, which is a covering map with unique lifts, but the `▷` clause still
needs its own argument, because agreement in the cover is agreement of *nodes* while agreement
downstairs is agreement of *images*, and distinct cover nodes can share an image.

**Claim.** Let `f : G̃ → G` be a two-way bounded morphism (in this repository's terms,
`TwoWayBounded f`: `forth` plus `step`, `HistoryMorphism.lean:281-286`), over integer time. Then
for every `G̃`-walk `σ̃` and time `x`,
`G̃ ⊨ ▷ψ at (σ̃, x)` iff `G ⊨ ▷ψ at (f∘σ̃, x)`, assuming the induction hypothesis for `ψ`.

*Derivation.*

- (⇐) Given `σ̃'` agreeing with `σ̃` up to `x`, `f∘σ̃'` agrees with `f∘σ̃` up to `x`, so the
  right-hand side gives `ψ` at `f∘σ̃'`, and the IH transfers it to `σ̃'`.
- (⇒) Given a `G`-walk `σ` agreeing with `f∘σ̃` up to `x`, define `σ̃'` to be `σ̃` itself for
  `t ≤ x` and to follow `σ` forward from the basepoint `σ̃(x)` for `t > x`, using `step` at each
  successor (dependent choice over integer steps — the same mechanism `fwdSeq` already
  implements). Then `f(σ̃'(t)) = f(σ̃(t)) = σ(t)` for `t ≤ x` by the agreement hypothesis, and
  `f∘σ̃' = σ` above `x` by construction, so `f∘σ̃' = σ`; and `σ̃'` agrees with `σ̃` up to `x` by
  construction. The left-hand side gives `ψ` at `σ̃'`, and the IH transfers it to `f∘σ̃' = σ`. ∎

The apparent image-collapse problem dissolves because the lifted witness **reuses `σ̃`'s own past
verbatim** instead of re-lifting it. Two consequences worth recording:

- The `▷` case needs *forward* lifting only, and the `◁` case *backward* lifting only. The
  compiled `⊡` case of `HistMorphism.plus_invariance` (`HistoryMorphism.lean:210-219`) uses
  `HistMap.lift`, which produces a whole history through one pinned state — i.e. both directions
  at once. So each open-modal case is a *weaker* obligation than the `⊡` case already discharged.
- What is missing in the Lean API is only the *statement* of a ray-agreement lifting field.
  `HistMap.lift` pins `τ'.state t = a` at a single time; `▷` needs "pins `ρ'` to `τ'` on all of
  `(-∞, x]`". That is the one new piece, and over ℤ it is constructible from `TwoWayBounded.step`
  by the existing forward-sequence machinery. See recommendation R1.

### 5. Step 1 needs amendment: the per-state witness economy is lost (derived)

Report 03 step 1 closes a countable set of walks "under one chosen witness walk per
(state, `⟐ψ` or `◇ψ` in the closure of `φ`)", justified by: "State-local truth is shift-invariant,
so one witness per state suffices."

That justification fails for `▷` and `◁`. A falsifying witness for `▷ψ` at `(τ, x)` must agree
with `τ` at *every* time `≤ x`; it is a function of the whole past of `τ` below `x`, not of the
state `τ(x)`, and `▷` is not shift-invariant in the required sense because the ray is anchored at
the time of evaluation. So "one witness per state" is unsound here.

**Countability survives the loss.** Indexing witnesses by (walk already in the set, time in ℤ,
diamond subformula) gives countably-many-times-countably-many-times-finitely-many per stage, and
an ω-iteration of a countable-to-countable closure is countable. What is lost is only the
economy, which the argument does not actually need: step 1's conclusion is a countable model, and
the amended closure still delivers one.

**Which direction of the induction consumes witnesses.** For any universal modal `M` whose
quantifier range in a sub-digraph `G'` is a subset of its range in `G` (true of `□`, `⊡`, `▷`,
`◁`, since every walk of an induced sub-digraph is a walk of the whole): truth of `Mψ` in `G`
transfers to `G'` for free, and only *falsity* needs a witness that survives into `G'`. Adding
the witness walk's states to `G'` is exactly what makes it survive, and for `▷` the witness's
states below `x` are already present, since it shares `τ`'s past. So the open modals need nothing
structurally new at step 1 — just more witnesses.

### 6. Two pre-existing gaps in section 1.3, neither open-modal-specific (derived)

Found while checking the argument; recorded rather than repaired, since the dispatch's deliverable
is a verdict and this task does not re-verify report 03.

- **(G1) Step 1's induction scope.** The equivalence `T_G(σ, t, ψ) ↔ T_{G'}(σ, t, ψ)` has to hold
  at *every* walk `σ` of the induced sub-digraph `G'`, because the box clauses in `G'` quantify
  over all of them — including walks that arise from crossing between designated walks and were
  never in the closed countable set `W`. But the witnesses were chosen only for walks in `W`. The
  fixpoint is therefore not obviously reached: `G'` depends on `W`, and the witnesses `W` needs
  depend on the walks of `G'`. This is the weakest link in section 1.3 and it is present already
  for `⊡`, with or without the open modals. It is consistent with report 03's own confidence
  label on 1.3 ("paper, Medium-High; rests on a recalled theorem").
- **(G2) Forest versus tree.** Section 1.2 produces "the disjoint union of the universal covers
  of its components" — countably many trees. Step 3 says "root each tree anywhere", but step 5
  reads satisfiability as "an MSO sentence over the full ω-branching tree", singular. Restricting
  to one component is not sound for `□`, whose range would shrink and whose truth could therefore
  change. The standard repair is to adjoin a new root whose children are the component roots and
  to carry a predicate excluding the new root's edges from the digraph edge relation; the coding
  is MSO-definable and does not disturb anything above. As noted in finding 3, `▷` and `◁` are
  component-local and so are **indifferent** to this gap — it is a `□` problem only.

### 7. Relation to the two routes this one bypasses (compiled, for the Lean facts)

- **Independent of Gabbay separation.** `OpenFutureElimination.openValidIn_ztime_iff_tr` reduces
  L^▷ validity at ZTime to L⁺ validity of a translation `tr`, but only under the hypothesis
  `SeparationOver TaskFrame.IsZTime` — Gabbay's Separation Theorem over the integer flow, not
  formalized (`OpenFutureElimination.lean:366-375`, the file's own header says so). The MSO route
  needs none of it: it attacks L^▷ validity directly, so it makes that hypothesis unnecessary
  **for the decidability question** (the translation remains independently valuable as an
  expressiveness result, and `Independence/OpenFutureUndefinable.lean`'s non-definability verdict
  at Base/Dense is the other side of that coin).
- **Independent of the ladder/RaySummary front.** The MSO argument uses the cover, the countable
  closure, and Rabin's theorem. It touches neither `tpOf`
  (`Decidability/RaySummary/AnchorLayer.lean:104`) nor the realization theorem nor any lift to
  `Decidable PlusValidZTime`. Confirmed by reading what the argument consumes, not by a
  dependency trace.
- **Disjoint from the landed decidability.** See the Context & Scope guardrail: the two landed
  `def`s are at base `Formula`.

### 8. Mathlib has nothing to build the MSO step on (held: MCP results this session)

`lean_leansearch` on "monadic second-order logic decidability tree automaton" and on "Buchi
automaton omega word acceptance infinite" returns, between them, only
`Mathlib.Computability.DFA`, `Mathlib.Computability.NFA`, `Mathlib.Computability.RegularExpressions`
and `Mathlib.Data.Tree.Basic` — finite-word automata and a finite binary tree type. No MSO
syntax, no ω-automaton, no determinization of ω-automata, no Rabin tree theorem, no Gurevich-Shelah.
(`lean_local_search` for "MSO second order" returned empty with `index: warming`, which per the
dispatch's interpretation rule is **not** proof of absence; the Mathlib verdict rests on the two
leansearch queries, which are the relevant evidence since the question is about Mathlib, not about
this repository.)

Formalizing step 5 therefore means formalizing Rabin's tree theorem from scratch — the
determinization of parity/Rabin automata over infinite trees. That is a multi-year project of a
different kind from anything in this repository, and nothing short of it would discharge the step.

### Cross-Domain Synthesis

The logic content (two modal clauses) and the order content (reachability in an oriented forest)
meet at one point, and the meeting is what makes the answer cheap. `▷`'s semantic restriction is
"agreement on a downward-closed ray of time". The forest's structural gift from section 1.2 is
"directed paths are unique". Together they turn a condition about *time-indexed sequences of
states* — which the `(P, x)` encoding deliberately forgets, keeping only an unindexed node set —
back into a condition about *sets*, recoverable without the index. Had section 1.2 produced
anything less than an oriented forest, the time index would have had to be reconstructed inside
the translation, and the restriction would have cost a transitive closure or worse.

The same structural gift is what bounds the amendment in finding 5 to a loss of economy rather
than a loss of countability: the witness for `▷` shares the evaluation point's past, so it adds
no nodes below `x` and the closure does not grow downward.

## Decisions

1. **Verdict recorded as YES at step 4, with an amendment at step 1.** The dispatch asked for a
   verdict on whether the open modals ride the MSO encoding. They do, at step 4 — the step the
   dispatch flagged — and the invariance step 2 carries them too. The cost is a loss of step 1's
   witness economy, which countability survives. Decided to state the verdict as positive while
   naming step 1 as the step that changes, rather than hedging the whole verdict on step 1's
   pre-existing weakness.
2. **Gaps G1 and G2 recorded, not repaired.** Both belong to report 03's own argument and affect
   `⊡` with or without the open modals. Repairing G1 is a research project in its own right.
   Decided to locate them precisely here so that any future attempt starts at G1, and to state
   explicitly that neither is caused by the open modals.
3. **Do not propose formalizing the decidability result.** Finding 8 settles the cost. Decided to
   recommend keeping the ZTime decidability of L^▷ as a paper result, and to carve out the one
   genuinely cheap, independently useful Lean item (R1) instead of filing the whole route.
4. **`◁` handled by mirror throughout.** The compiled time-reflection transport
   (`openTruthAt_rev`, `openValidOn_rev_iff`, `openValid_reflectTime` in
   `OpenLanguage/OpenReversal.lean`) already carries L^▷ validity across time reversal, and
   `reflectTime` exchanges `▷` and `◁`. Decided not to duplicate every derivation for `◁`.

## Recommendations

Prioritized.

- **R1 (file it; small).** A Lean task: `▷`/`◁` truth invariance along a history-lifting morphism
  with ray-agreement lifting, plus the ZTime construction of such lifting from `TwoWayBounded`.
  - Shape: one new field or standalone hypothesis beside `HistMap.lift` ("a history of the image
    frame agreeing with the image of `τ'` up to `x` lifts to a history of the source agreeing
    with `τ'` up to `x`"), its mirror for `◁`, their derivation over ℤ from `TwoWayBounded.step`
    / `forth` via the existing forward/backward sequence machinery, and an `open_invariance`
    theorem over `OpenFormula` reusing `plus_invariance`'s seven cases verbatim.
  - Cost estimate: **150-350 lines**, one implementation phase. The two new induction cases are
    each shorter than the compiled `stab` case (finding 4); the real work is the two lifting
    lemmas, and `exists_histMorphism_of_isZTime` is the template.
  - Value independent of the MSO route: it is the L^▷ analogue of a result this repository
    already has at L⁺, it is the invariance fact any future bounded-morphism argument about the
    open modals will need, and it does not depend on G1, G2, Rabin, Gabbay separation, or the
    ladder.
- **R2 (do not file).** The MSO decidability proof for L^▷ at ZTime. Blocked by finding 8 at a
  cost no plausible budget reaches. Record the result as a paper theorem in the manuscript's own
  terms if it is wanted; do not open a formalization task.
- **R3 (optional, cheap).** A short amendment note appended to report 03 section 1.3, or a
  pointer from it to this report, recording (a) that the open modals are accommodated, (b) that
  step 1's per-state economy is unsound for any modal whose witness is not state-local, and
  (c) gaps G1 and G2. Prevents the per-state economy from being relied on again.
- **R4 (research, expensive, not now).** Repair G1. Until the fixpoint in step 1 is closed, the
  whole of section 1.3 — base language with `⊡`, and the open extension alike — is a sketch. Any
  serious pursuit of the MSO route begins here, not at step 4.

## Risks & Mitigations

- **Risk: the verdict is read as "decidability of L^▷ at ZTime is established".** It is not.
  Section 1.3 is unverified, and G1 is a live gap in it. *Mitigation*: the Context & Scope
  guardrails and finding 6 state this; R3 would propagate it to report 03.
- **Risk: the verdict is read as covering Base, Dense or RTime.** It does not. *Mitigation*:
  stated in Context & Scope with the obstruction's location (report 03 section 1.4).
- **Risk: confusion with the landed base-language decidability.** `decidableValidZTime` /
  `decidableDerivableZTime` are at `Formula`, which has no `⊡` and no `▷`/`◁`. *Mitigation*:
  constructor list cited in Context & Scope.
- **Risk: the finite model property is inferred from "regular tree".** Report 03 denies it, and
  finding 3's reliance on the full backward ray is direct evidence that `▷` reads exactly what
  subtree-type folding discards. *Mitigation*: stated in Context & Scope.
- **Risk: R1's lifting field turns out to need Saturation or a relative Extension Theorem.** Over
  ℤ it should not — forward lifting from a basepoint is successor-step dependent choice, the same
  mechanism `fwdSeq` already uses — but this is a derived expectation, not a compiled one. If it
  does, R1's phase marks `[BLOCKED]` with the goal state, and the loss is a few hundred lines,
  not a research programme. Note that over a general duration this is exactly the obstruction
  report 03 section 1.4 names, which is one more reason R1 is scoped to ZTime.

## Appendix

### Evidence tier by claim

| Claim | Tier |
|---|---|
| Report 03 never mentions the open modals | verified this session (grep) |
| `▷`/`◁` truth clauses and `AgreeUpTo`/`AgreeFrom` definitions | compiled |
| `plus_invariance` exists at `PlusFormula` with a `stab` case using `HistMap.lift` | compiled |
| `TwoWayBounded` has `forth` + `step`; `plus_invariance_of_isZTime` needs surjectivity | compiled |
| Landed decidability is at base `Formula` (no `⊡`) | compiled |
| `openValidIn_ztime_iff_tr` is conditional on `SeparationOver TaskFrame.IsZTime` | compiled |
| Step 4 accommodates `▷`/`◁`; `⊑` is FO-definable | derived (finding 3) |
| Cover step carries `▷`/`◁` | derived (finding 4) |
| Step 1's per-state economy is unsound for `▷`/`◁`; countability survives | derived (finding 5) |
| Gaps G1, G2 | derived (finding 6) |
| Mathlib has no MSO / ω-automata / Rabin | held (two leansearch queries this session) |
| Rabin's theorem itself; undecidability of MSO over ℝ | recalled (inherited from report 03) |
| Section 1.2's oriented-forest construction and unique directed paths | paper (report 03) |
| Section 1.3 steps 1-5 as a whole | paper (report 03), unverified |

### References

- `specs/559_nondeterministic_canonical_model_tm_star_completeness/reports/03_axiomatizability-rules-engine.md`
  sections 1.1 (invariance), 1.2 (the cover), 1.3 (the five steps), 1.4 (Base/Dense/RTime)
- `FormalSystem/OpenLanguage/README.md` — paper-label correspondence for `▷`, `◁`,
  `⟨τ⟩_x`, `|τ⟩_x`, `⟨τ|_x`
- `FormalSystem/Semantics/HistoryMorphism.lean:100-230` (`HistMap`, `HistMorphism`,
  `plus_invariance`), `:281-286` (`TwoWayBounded`), `:589-597` (`plus_invariance_of_isZTime`)
- `FormalSystem/Metalogic/Expressiveness/OpenFutureElimination.lean:300-375` (`SeparationOver`,
  `tr`, `openValidIn_ztime_iff_tr`)
