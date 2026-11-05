# Research Report: Task #878 — a rigorous paper proof that L⁺ validity at ZTime is decidable

- **Task**: 878 - make the paper proof of L⁺ ZTime decidability rigorous
- **Started**: 2026-11-05T06:42:00Z
- **Completed**: 2026-11-05T07:35:00Z
- **Effort**: one research dispatch (orchestrated, seq 1, `--lit`)
- **Dependencies**: report 03 of task 559 §§1.1-1.4 (the argument being repaired); report 01 of
  task 866 (which located gaps G1 and G2); task 870 (oriented-forest Saturation, `[NOT STARTED]`,
  cited and not reproved)
- **Sources/Inputs**:
  - `specs/559_nondeterministic_canonical_model_tm_star_completeness/reports/03_axiomatizability-rules-engine.md`
    §§1.1-1.4 and both dated amendments (read in full this session)
  - `specs/866_mso_route_open_modals_ztime_decidability/reports/01_mso-route-open-modals.md`
    (read in full this session)
  - `FormalSystem/PlusLanguage/PlusTruth.lean` (the truth recursion and the four shift/locality
    theorems), `FormalSystem/PlusLanguage/PlusValidity.lean`,
    `FormalSystem/PlusLanguage/PlusIntTransfer.lean`, `FormalSystem/Semantics/TaskFrame.lean`
    (the four axiom predicates and `FrameOver.IsRegular`),
    `FormalSystem/Semantics/IntNormalForm.lean` (`step`, `taskRel_eq_iter`),
    `FormalSystem/Semantics/HistoryMorphism.lean` (`TwoWayBounded`,
    `plus_invariance_of_isZTime`), `FormalSystem/Semantics/FrameProperty.lean`
    (`TaskFrame.IsZTime`), `FormalSystem/Semantics/FrameClassValidity.lean` (`Sat .ZTime`)
  - Literature corpus, held and read this session: Thomas 1997, *Languages, Automata, and Logic*
    (§3 pp. 450-462 on the non-elementary conversion bound; §6.3 pp. 2440-2520 of the markdown,
    Theorems 6.18, 6.19, 6.20 and the countable-branching embedding); Chagrov &
    Zakharyaschev 1997, *Modal Logic*, ch. 16 p. 496 (Theorem 16.10, Craig's theorem)
  - Not consulted and not relied on: Rabin 1969 itself, Gurevich-Shelah, Shelah on MSO over ℝ,
    Muchnik/Walukiewicz 1996, Stupp 1975
- **Artifacts**: `specs/878_lplus_ztime_decidability_paper_proof_repair/reports/01_lplus-ztime-decidability-proof-repair.md`
- **Standards**: report-format.md, subagent-return.md
- **Task Type**: formal
- **Domains**: logic (primary: modal/temporal definability, MSO translation, recursive
  axiomatizability), math (secondary: order and reachability structure of oriented forests,
  covering spaces of multigraphs, cardinality of closure operators)

## Executive Summary

- **G1 is repaired, and the repair is small.** Report 03 §1.3 step 1 justified its per-state
  witness economy by "state-local truth is shift-invariant", which is a non-sequitur; report 866
  finding 5 noticed that and concluded the justification was never available. The correct
  justification is a different fact, and it is **already compiled in this repository**:
  `PlusTruth.stab_state_only` (`FormalSystem/PlusLanguage/PlusTruth.lean:332`) says `⊡φ`'s truth
  value depends on the world state *alone*, and `PlusTruth.box_global` (`:372`) says `□φ`'s truth
  value is one bit per model. Because the two universal modals of L⁺ are the only ones whose
  quantifier leaves the current walk, and because each one's quantifier range is determined by a
  *state* (for `⊡`) or by *nothing at all* (for `□`), the witness closure can be indexed by
  states, not by walks. A closure operator on states is countable-to-countable; the fixpoint G1
  named simply does not arise. Full proof in finding 2.
- **A by-product of the repair: at most `1 + |{□χ ∈ cl φ}|` components are needed.** All `⊡`
  witnesses lie in the component of their anchoring state, and the `□` witnesses are finitely
  many and chosen once. So the countable model has **finitely many** connected components, which
  makes G2's repair comfortable rather than merely possible (finding 3).
- **G2 is repaired explicitly, and step 4's encoding survives it — but only with one stated
  guard.** The new super-root `r` adds no digraph edges, so `Walk`, directed reachability `⊑`,
  and the `U`/`S` clauses are untouched *inside* a component. The one real hazard is that the
  rooted-tree meet of two nodes in different components is now `r`, and report 866 finding 3's
  first-order definition of `⊑` would then return spurious cross-component reachability unless
  the definition carries the conjunct `¬Rt(meet(y,x))`. That conjunct is load-bearing and is
  stated (finding 4).
- **The argument has to be reordered, and the reason is a Lean hypothesis bundle.**
  `FrameOver.IsRegular` carries `saturation` as a fourth field, so the compiled invariance
  theorem `plus_invariance_of_isZTime` demands Saturation of *both* frames. Taking the cover
  first and running the countable-model step inside the oriented forest fixes this, because an
  induced sub-digraph of an oriented forest is an oriented forest and so satisfies Saturation
  again by the same cited lemma. Report 03's order (countable model, then cover) cannot be run
  against the repository's own compiled invariance theorem (finding 1).
- **Every recalled citation in the chain is now held.** Rabin's theorem is **Thomas 1997
  Theorem 6.20** (`S2S` is decidable, attributed to Rabin 1969), with Theorem 6.19 supplying the
  effective MSO-to-automaton direction, Theorem 6.18 (Rabin Basis Theorem) supplying a regular
  satisfying tree, and §6.3's explicit `1^{i₁}0 ⋯ 1^{i_k}0` coding supplying the
  countable-branching-into-binary-tree embedding — so **`S2S` alone suffices and `SωS`,
  Gurevich-Shelah and the Muchnik/Walukiewicz transfer theorem are not needed**. Craig's
  observation is **Chagrov & Zakharyaschev 1997 Theorem 16.10** (finding 6).
- **The theorem, stated: `{φ | PlusValidZTime φ}` is decidable**, on the explicit hypothesis list
  of finding 7, of which exactly one item is not either compiled here or held in the corpus — the
  oriented-forest Saturation lemma and the universal-cover construction of report 03 §1.2, owned
  by task 870 and cited per the dispatch. **Not** given: no constructive decision procedure, no
  Lean `Decidable` instance, no elementary complexity bound, no finite model property (though a
  *regular*-model property does follow, finding 8), and nothing at Base, Dense or RTime.
- **Craig: the existence question is closed, and did not need Craig.** Decidability makes the
  validity set recursive, so it is its own recursive axiom set; Craig's theorem is the tool for
  the weaker r.e.-only case. Report 03's amendment of 2026-11-05 can be lifted at the level of
  existence. What stays open is a *finitely schematic* system (finding 9).
- **The open-modal reading does NOT survive the repair, and report 866's countability claim for
  it is itself an instance of G1.** One paragraph, finding 10, as the dispatch directs.

## Context & Scope

The dispatch asked for a self-contained written argument, each step proved or cited to a held
source, repairing two located gaps in the only existing argument that L⁺ ZTime validity is
decidable.

Constraints honoured:

- **Report only.** Nothing under `FormalSystem/` or `Tests/` is changed, and no Lean
  formalization of this route is proposed; that is refused by standing ruling (Mathlib has no MSO
  syntax, no ω-automata and no Rabin tree theorem — report 866 finding 8, held).
- **Status vocabulary.** *Compiled*: a theorem of this repository's live tree, cited by file and
  line, read this session. *Held*: a claim backed by a source document read this session.
  *Cited*: a claim this report consumes without reproving, per the dispatch's instruction
  (report 03 §1.2 and task 870). *Derived*: a paper derivation performed in this session.
  *Paper*: an argument written out here, not machine-checked. *Recalled*: no source in hand —
  **this report contains no load-bearing recalled claim**, which was dispatch item (3).
- **Scope is ZTime.** Nothing here touches Base, Dense or RTime; report 03 §1.4 locates those
  obstructions and this report does not revisit them.
- **No finite model property is claimed.** Finding 8 states what *is* obtained instead and why
  the generic finite-model remark in Thomas 1997 §6.3 does not transfer to this setting.
- **The landed `decidableValidZTime` / `decidableDerivableZTime` are a different result**, at
  base `Formula` whose constructors are `atom | bot | imp | box | untl | snce` with no `stab`.
  Nothing below leans on them and nothing below extends them.

## Domain Analysis

Primary domain **logic**. The deliverable is a decidability proof for a modal-temporal logic by
interpretation into monadic second-order logic, with the two hard steps being a countable-model
argument (a model-theoretic closure argument) and a definability argument (the MSO translation).

Secondary domain **math**. Three pieces of non-logical content are load-bearing: the order and
reachability structure of oriented forests (unique directed paths; directed reachability as a
first-order condition on the rooted-tree order plus an orientation predicate); the covering
theory of multigraphs (the universal cover is a simple tree, so parallel edges and loops in the
base do not produce directed 2-cycles upstairs); and a cardinality argument about closure
operators (an ω-iterated countable-to-countable closure on a set of *states* is countable,
whereas the same closure on a set of *walks* is not — this is exactly the difference between G1
and its repair).

No physics content.

## Findings

### 0. The semantics, pinned (compiled)

Everything below is stated against the repository's own definitions, read this session.

- `PlusTruthAt` (`FormalSystem/PlusLanguage/PlusTruth.lean:84`) has seven clauses. The two that
  leave the current history are

  ```
  | .box  φ => ∀ σ : WorldHistory F, PlusTruthAt M σ t φ
  | .stab φ => ∀ σ : WorldHistory F, τ.state t = σ.state t → PlusTruthAt M σ t φ
  ```

  Note that both quantify at the **same** time `t`, and that `stab`'s restriction is literally an
  equation between two world states.
- `PlusValidZTime φ := PlusValidIn ProofSystem.FrameClass.ZTime φ`
  (`PlusValidity.lean:117`), and `FrameClass.Sat .ZTime F = F.IsRegular ∧ F.IsZTime`
  (`FrameClassValidity.lean:156`). `TaskFrame.IsZTime` (`FrameProperty.lean:192`) asks for
  `SuccOrder`, `PredOrder`, `IsSuccArchimedean`, `IsPredArchimedean` on the duration carrier.
- `FrameOver.IsRegular` (`TaskFrame.lean:1185`) has **four** fields: `comp`
  (`TaskFrame.Compositional`), `serial` (`TaskFrame.Serial`), `limit` (`TaskFrame.Limit`) and
  `saturation` (`TaskFrame.Saturation`). The four bare predicates are at `TaskFrame.lean`:
  `Saturation` (directed families of nonempty fibres and segments have nonempty intersection),
  `Serial` (`∀ w x, 0 ≤ x → (∃ u, R w x u) ∧ (∃ v, R v x w)`), `Compositional`, `Limit`.
- **Carrier normalization is compiled.** `plusValidZTime_iff_plusValidInt`
  (`PlusIntTransfer.lean:188`): `PlusValidZTime φ ↔ PlusValidInt φ`, where
  `PlusValidInt φ := ∀ (F : FrameOver intOrder) [F.IsRegular] (M) (τ) (t : ℤ), PlusTruthAt M τ t φ`
  (`:167`). So the duration carrier may be taken to be literally `ℤ` with no loss, as a theorem
  and not as an informal appeal to categoricity.
- **Over `ℤ` a frame is a digraph.** `FrameOver.step F w u := F.TaskRel w 1 u`
  (`IntNormalForm.lean:182`) and `taskRel_eq_iter` (`:224`) decompose `TaskRel` at every `d : ℤ`
  into `|d|`-fold iteration of `step`. Consequently, over `ℤ`: `Compositional` + `Limit` say
  exactly that `TaskRel` is the signed iteration of the one-step relation, `Serial` at `x = 1`
  says the digraph is **doubly serial** (every node has a `step`-successor and a
  `step`-predecessor) and `Serial` at every other `x ≥ 0` follows by composition, and
  `WorldHistory F` is the set of bi-infinite `step`-walks `σ : ℤ → W`. So, over `ℤ`:

  > **a ZTime frame is precisely a doubly serial digraph satisfying `Saturation`, with
  > `H_F` = all bi-infinite walks and the atoms valued on states.**

  This is the normal form every step below works in. (Derived, from compiled components.)
- **Four compiled facts about the two modals**, all in `PlusTruth.lean`:
  - `plusTruthAt_timeShift` (`:264`): `PlusTruthAt M (σ.timeShift Δ) t φ ↔ PlusTruthAt M σ (t+Δ) φ`
    — truth commutes with time shift, for every `PlusFormula`.
  - `truth_congr_ext` (`:239`): histories with the same state at every time satisfy the same
    formulas.
  - **`stab_state_only` (`:332`)**: `τ.state t = σ.state s → (PlusTruthAt M τ t (.stab φ) ↔
    PlusTruthAt M σ s (.stab φ))`. `⊡φ` is **one bit per world state**.
  - **`box_global` (`:372`)**: `PlusTruthAt M τ t (.box ψ) ↔ PlusTruthAt M σ s (.box ψ)` for any
    two histories and any two times. `□ψ` is **one bit per model**.

  The last two are the whole of the G1 repair. They were available when report 03 §1.3 was
  written and were not cited there.

### 1. The order of the argument has to change, and why

Report 03 §1.3 runs: (1) countable model, (2) pass to the cover, (3) root, (4) translate,
(5) Rabin. That order cannot be run against this repository's compiled invariance theorem.

`TwoWayBounded.plus_invariance_of_isZTime` (`HistoryMorphism.lean:589`) reads

```lean
theorem plus_invariance_of_isZTime {D : TemporalOrder} {F' F : FrameOver D}
    [F'.IsRegular] [F.IsRegular] [SuccOrder ↑D] [IsSuccArchimedean ↑D]
    {f : F'.WorldState → F.WorldState} (h : TwoWayBounded f)
    (hs : Function.Surjective f) (M : TaskModel F.toTaskFrame) :
    ∃ g : HistMorphism F' F, g.toFun = f ∧
      ∀ (φ : PlusFormula) (τ' : WorldHistory F'.toTaskFrame) (t : ↑D),
        PlusTruthAt (g.pullM M) τ' t φ ↔ PlusTruthAt M (g.mapH τ') t φ
```

and `IsRegular` bundles `saturation`. So the theorem demands Saturation of the *base* frame as
well as the cover. In report 03's order, the base frame at the cover step is the countable
sub-digraph produced by step 1, whose Saturation is exactly what is not established.

**The fix is to take the cover first.** Then:

- **Step A (the cover).** Given a ZTime refutation, normalize the carrier to `ℤ`
  (`plusValidZTime_iff_plusValidInt`, compiled) and let `F` be the resulting doubly serial
  digraph with `Saturation`. Let `F̃` be the disjoint union of the universal covers of `F`'s
  connected components, taken as **undirected multigraphs with orientation kept**. The covering
  map `f : F̃ → F` is a surjective two-way bounded morphism with unique lifts, `F̃` is doubly
  serial, and `F̃` is an **oriented forest** — directed walks are reduced paths, so directed
  paths between two nodes are unique. *(Cited: report 03 §1.2; the dispatch directs that the
  cover step and its Saturation consequence be cited, not reproved.)* `F̃` therefore satisfies
  `Saturation` by the oriented-forest lemma task 870 owns, and so `F̃.IsRegular` holds; with `F`
  regular by hypothesis, `plus_invariance_of_isZTime` applies and `F̃` refutes `φ`.
- **Step B (countable model), finding 2.** Applied **inside** `F̃`, producing an induced
  sub-digraph `G`.
- Crucially, **an induced sub-digraph of an oriented forest is an oriented forest** (the
  underlying undirected graph of an induced subgraph of a forest is a forest, and any directed
  path in the subgraph is one in the whole, so uniqueness is inherited), and step B makes `G`
  doubly serial by construction. So `G` satisfies `Saturation` by the *same* cited lemma, `G`
  is again a ZTime frame, and **no second cover and no second invariance appeal is needed**.

Two precision notes on the cited material, recorded for task 870's benefit:

- **The multigraph convention is load-bearing.** Taking the components as *multigraphs* means a
  base pair of opposite edges `u → v`, `v → u` lifts to **two distinct** cover edges to two
  distinct nodes, and a base loop `u → u` lifts to a ray. Hence the cover is a **simple** tree:
  no parallel edges, no loops, and therefore **no directed 2-cycles**. Finding 4's `Walk`
  predicate depends on exactly that.
- **Task 870's stated hypothesis may be too weak.** The task text asks for "a frame in which
  directed paths between any two nodes are unique". Report 03 §1.2's step 4 uses the *undirected*
  tree path between `a_m` and `a'` and its unique sink; that needs the underlying undirected
  graph to be a forest, which is strictly more than directed-path uniqueness. The hypothesis
  that should be stated is the oriented-forest one. (Flagged, not resolved here; recorded in this
  task's issue log.)

### 2. Step B: the repaired countable-model step (the G1 repair) — paper, with compiled core

Let `cl φ` be the finite set of subformulas of `φ`.

> **Lemma B (countable model).** Let `F̃` be a doubly serial digraph over `ℤ`, `M` a model on it
> whose valuation reads only atoms of `φ`, `σ₀ ∈ H_{F̃}` and `t₀ ∈ ℤ` with
> `¬PlusTruthAt M σ₀ t₀ φ`. Then there is a **countable** set `U ⊆ W_{F̃}` such that, writing
> `G` for the induced sub-digraph on `U` and `M|_U` for the restricted model:
> `G` is doubly serial, `σ₀ ∈ H_G`, and for **every** `σ ∈ H_G`, every `t ∈ ℤ` and every
> `ψ ∈ cl φ`: `PlusTruthAt (M|_U) σ t ψ ↔ PlusTruthAt M σ t ψ`. In particular `G` refutes `φ`.

*Proof.* Choose witnesses as follows (AC).

- **The `□` witnesses, chosen once.** For each `□χ ∈ cl φ`: if there is any `ρ ∈ H_{F̃}` with
  `¬PlusTruthAt M ρ 0 χ`, fix one and call it `w(□χ)`. By `box_global` (compiled) the truth value
  of `□χ` is independent of both the history and the time, so this finite family is *all* the
  `□`-data there is.
- **The `⊡` witnesses, indexed by a state.** For each state `u ∈ W_{F̃}` and each `⊡χ ∈ cl φ`: if
  there is `ρ ∈ H_{F̃}` with `ρ(0) = u` and `¬PlusTruthAt M ρ 0 χ`, fix one and call it
  `w(u, ⊡χ)`. The normalization of the time to `0` is legitimate by `plusTruthAt_timeShift`
  (compiled): if `ρ(t) = u` and `¬PlusTruthAt M ρ t χ`, then `ρ.timeShift t` has value `u` at `0`
  and falsifies `χ` there.

Now set `U₀ := σ₀(ℤ) ∪ ⋃{ w(□χ)(ℤ) : □χ ∈ cl φ }`, and
`U_{n+1} := U_n ∪ ⋃{ w(u, ⊡χ)(ℤ) : u ∈ U_n, ⊡χ ∈ cl φ }`, and `U := ⋃_n U_n`.

- **`U` is countable.** Each `U_n` is countable: `U₀` is a finite union of countable walk images,
  and `U_{n+1}` adds at most `|U_n| × |cl φ|` countable walk images. A countable union of
  countable sets is countable, and `U` is a countable union of the `U_n`. **This is the whole
  repair**: the closure operator runs over *states*, and `W_{F̃}` is being cut down to a countable
  set of states, so each stage is a countable-to-countable step. Report 866's G1 is the
  observation that a closure over *walks* is not, and it is not — see finding 10.
- **`G` is doubly serial.** Every `u ∈ U` lies on a walk whose entire image is in `U` (namely
  `σ₀`, some `w(□χ)`, or the `w(v, ⊡χ)` that introduced it), so `u` has a `step`-successor and a
  `step`-predecessor inside `U`.
- **`H_G ⊆ H_{F̃}`**, since `G` is an induced sub-digraph: every bi-infinite `G`-walk is a
  bi-infinite `F̃`-walk. `σ₀ ∈ H_G` because `σ₀(ℤ) ⊆ U₀`.
- **`H_G` is shift-closed**, so `plusTruthAt_timeShift` is available in `G` as well as in `F̃`.

**The induction.** By induction on `ψ ∈ cl φ`, with the statement quantified over **all**
`σ ∈ H_G` and all `t ∈ ℤ`. This scope is the point: the induction hypothesis is available at every
walk of `G`, including the "crossing" walks report 866's G1 names.

- `.atom p`: the valuation is the restriction, and `σ(t) ∈ U`. Both sides are
  `M.valuation (σ.state t) p`.
- `.bot`, `.imp`: immediate from the IH.
- `.untl ψ χ`, `.snce ψ χ`: both clauses quantify over times along `σ` only, and `σ` is the same
  function on both sides. The IH at `(σ, s)` and `(σ, r)` for the relevant `s, r` closes them.
- `.stab χ` (that is, `⊡χ`). Write `u := σ(t) ∈ U`.
  - (⟹) Suppose `PlusTruthAt M σ t (⊡χ)`. Let `ρ ∈ H_G` with `ρ(t) = u`. Then `ρ ∈ H_{F̃}`, so
    `PlusTruthAt M ρ t χ`; the IH at `ρ` (a `G`-walk) gives `PlusTruthAt (M|_U) ρ t χ`. Hence
    `PlusTruthAt (M|_U) σ t (⊡χ)`. *No witness is consumed in this direction* — the sub-digraph's
    quantifier range is a subset of the ambient one.
  - (⟸) Suppose `PlusTruthAt (M|_U) σ t (⊡χ)` and, for contradiction, that `⊡χ` fails at `(σ, t)`
    in `F̃`: some `ρ ∈ H_{F̃}` has `ρ(t) = u` and `¬PlusTruthAt M ρ t χ`. Then `w(u, ⊡χ)` exists
    (the choice above was made for the pair `(u, ⊡χ)`, and `u ∈ U_n` for some `n`), its image lies
    in `U_{n+1} ⊆ U`, so `w := w(u, ⊡χ) ∈ H_G`, and `¬PlusTruthAt M w 0 χ`. The IH at `w` gives
    `¬PlusTruthAt (M|_U) w 0 χ`. Put `ρ' := w.timeShift (-t)`, a `G`-walk with `ρ'(t) = w(0) = u`;
    `plusTruthAt_timeShift` in `G` gives `¬PlusTruthAt (M|_U) ρ' t χ`, contradicting
    `PlusTruthAt (M|_U) σ t (⊡χ)`. ∎(case)
- `.box χ`. Identical, with `w(□χ)` in place of `w(u, ⊡χ)` and with the restriction `ρ(t) = u`
  dropped. The (⟹) direction is again free; the (⟸) direction uses the single global witness,
  shifted to time `t`.

Taking `ψ := φ`, `σ := σ₀`, `t := t₀` gives `¬PlusTruthAt (M|_U) σ₀ t₀ φ`. ∎

**Where G1 actually was.** Report 03 §1.3 step 1 wrote: "State-local truth is shift-invariant, so
one witness per state suffices". That sentence is a non-sequitur, and report 866 finding 5 was
right to refuse it. But the conclusion it was reaching for is true for a different reason, which
is `stab_state_only`: the `⊡` quantifier's *restriction* is an equation between world states, so
the class of histories it ranges over at `(σ, t)` is determined by the single state `σ(t)` —
independently of any claim about shift-invariance of state-local truth. Shift-invariance is still
used, but only to normalize the *time* at which a witness is recorded, which is a convenience and
not the load-bearing step. **G1 was a defect in the justification, not in the construction**, and
the two theorems that justify it are compiled in the repository.

### 3. By-product: finitely many components suffice (derived)

In Lemma B's construction, `w(u, ⊡χ)(0) = u`, so every `⊡` witness lies in the connected
component of its own anchoring state; the `⊡` closure therefore never leaves a component. The only
cross-component additions are the `□` witnesses, of which there are at most `|{□χ ∈ cl φ}|`, all
chosen at stage `0`. Hence

> `U` meets at most `1 + |{□χ ∈ cl φ}|` connected components of `F̃`, so **`G` has finitely many
> components**, and the universal cover of each is one tree, so the forest of finding 4 has
> **finitely many** trees.

This does not weaken the need for G2's repair — restricting to one component is still unsound,
because `□`'s witnesses genuinely live in the other components — but it makes the new super-root
finitely branching, which removes any residual worry about the branching degree of the coded tree.

### 4. Step C: rooting, the new-root coding (the G2 repair), and whether step 4's encoding survives

`G` is now a countable, countably-branching, doubly serial oriented forest with finitely many
components, refuting `φ`. Root each component tree at an arbitrary node, giving roots
`r₁, …, r_k`. Adjoin a fresh node `r` and tree edges `{r, r_i}`. Call the result `T*` — a single
rooted, countably branching tree.

**The vocabulary.** `T*` is presented as a structure with the child relation `Ch(u, v)` ("`v` is a
child of `u`"), the induced ancestor order `⪯`, and these unary predicates:

- `Rt := {r}`;
- `Up ⊆ T* \ {r}`: `Up(v)` holds iff the digraph edge on the tree edge `{parent(v), v}` runs
  `v → parent(v)` (child-to-parent); `¬Up(v)` means it runs `parent(v) → v`. Every tree edge of
  `G` carries exactly one orientation, because the cover is a *simple* tree (finding 1's
  multigraph note). **Convention**: `Up(r_i) := false` for each component root, whose value is
  immaterial under the robust definition of `⊑` below;
- `A_p` for each atom `p` occurring in `φ` (finitely many), with `A_p ∩ {r} = ∅`.

**The digraph, recovered.**

```
E(u, v)  :⟺  ¬Rt(u) ∧ ¬Rt(v) ∧ [ (Ch(u, v) ∧ ¬Up(v)) ∨ (Ch(v, u) ∧ Up(u)) ]
```

This is first-order over `(Ch, Up, Rt)`. The two `¬Rt` conjuncts delete exactly the `k` tree edges
incident to `r`, and `r`'s edges are the only ones `T*` added, so `E` is literally `G`'s edge
relation and `(T* \ {r}, E)` is literally `G`. **G2 is thereby repaired**: `□`'s forest-wide range
has become a quantifier over the subsets of a single tree.

**Does step 4's encoding survive? Four checks, three free and one not.**

1. **`Walk` survives, and `r` needs no separate exclusion.** The step-4 predicate is

   ```
   Walk(P) :⟺ P ≠ ∅ ∧ (∀u ∈ P)(∃!v ∈ P. E(u, v)) ∧ (∀u ∈ P)(∃!v ∈ P. E(v, u))
                   ∧ P is connected in E restricted to P
   ```

   Since `E` has no edge at `r`, a `P` containing `r` fails the in-degree clause outright; the
   exclusion is automatic. Correctness of `Walk` is unchanged by the new root and holds because
   `G` is an oriented forest: the degree clauses make `E|_P` a disjoint union of bi-infinite
   directed paths and directed cycles; `G` has no directed cycle (a directed cycle is a cycle of
   the underlying graph, and a directed 2-cycle would need parallel edges — excluded by finding
   1's multigraph note); connectedness leaves one bi-infinite directed path. Conversely the image
   of any bi-infinite walk satisfies the three clauses, and such a walk is injective because a
   repeat would give a directed cycle.
2. **`U`/`S` survive.** Writing `⊑` for directed `E`-reachability, report 866 finding 3
   establishes (derived there, rechecked here) that for `P, P'` encoding walks through `x`,
   `{y ∈ P : y ⊑ x}` is exactly `P`'s backward ray from `x`, and set equality of backward rays is
   time-wise agreement. So the walk's own time order is recovered from `⊑` restricted to `P`, and

   ```
   ⟦untl ψ χ⟧(P, x) := ∃y [ y ∈ P ∧ x ⊑ y ∧ y ≠ x ∧ ⟦χ⟧(P, y)
                              ∧ ∀z (z ∈ P ∧ x ⊑ z ∧ z ⊑ y ∧ z ≠ x ∧ z ≠ y → ⟦ψ⟧(P, z)) ]
   ```

   with `⟦snce⟧` the mirror (`y ⊑ x`, `z` between). None of this mentions `r`.
3. **`⊡` and `□` survive, and the forgotten time index is the reason the encoding is sound at
   all.** A pair `(P, x)` records no absolute time. That is harmless, and it is `plusTruthAt_timeShift`
   that makes it harmless: if `(σ, t)` and `(σ', t')` have the same image pair, then `σ'` is a
   shift of `σ` and the truth values agree. So truth is a well-defined function of `(P, x)`, and

   ```
   ⟦stab χ⟧(P, x) := ∀P' [ Walk(P') ∧ x ∈ P' → ⟦χ⟧(P', x) ]
   ⟦box  χ⟧(P, x) := ∀P' ∀x' [ Walk(P') ∧ x' ∈ P' → ⟦χ⟧(P', x') ]
   ```

   are correct. The second is the universal modality, which is what `box_global` (compiled) says
   `□` is; report 03 step 4's rendering of `□` as `∀P' ∀x' ∈ P'` is exactly right and now has a
   compiled warrant.
4. **`⊑` does NOT survive unguarded. This is the one real hazard of the new root.** Report 866
   finding 3 defines `⊑` first-order from the rooted-tree order and `Up`: with `m` the meet of `y`
   and `x`, `y ⊑ x` iff every node on `(m, y]` is `Up` and every node on `(m, x]` is `¬Up`. In
   `T*`, the meet of two nodes in **different** components is `r`, and that definition would then
   be satisfiable across components: if `Up` happened to hold all the way up from `y` to its
   component root and fail all the way down from `x`'s component root to `x`, the definition would
   return a directed path that does not exist. The definition must therefore carry the component
   guard explicitly:

   ```
   y ⊑ x  :⟺  ∃m [ m = meet(y, x) ∧ ¬Rt(m)
                     ∧ ∀z (m ≺ z ⪯ y → Up(z)) ∧ ∀z (m ≺ z ⪯ x → ¬Up(z)) ]
   ```

   With `¬Rt(m)` present, `⊑` is correct and never crosses components; the `Up(r_i) := false`
   convention above makes the unguarded form correct too, but relying on a convention where a
   conjunct will do is the wrong trade. `meet(y, x)` is the `⪯`-greatest common ancestor, which is
   first-order definable and always exists. Report 866's observation that `⊑` is **first-order**,
   with no transitive-closure quantifier, is unaffected: the guard is one more first-order
   conjunct, so the two open modals' clauses and the `U`/`S` clauses still add **no quantifier
   alternation** over what `⊡` already pays.

**Verdict on dispatch item (2).** The forest gap is repaired by the explicit coding above, and
step 4's encoding survives it, subject to the stated `¬Rt(meet(y, x))` guard on `⊑`, which is the
only place the new root can do damage.

### 5. Step D: the MSO sentence, and Step E: Rabin

**The coding predicate.** For the final sentence we quantify over the model as well as over the
walk. Thomas 1997 §6.3 (held) embeds a countably branching tree into the full binary tree
`T = ⟨{0,1}*, S₀, S₁⟩` by coding the node reached from the root by the `i₁`-th, then `i₂`-th, …,
then `i_l`-th successor as the word `1^{i₁}0 1^{i₂}0 ⋯ 1^{i_l}0`; the embedding preserves the
prefix relation, and "such an embedding is described by its range, a set `P₀ ⊆ {0,1}*`". Write
`≺` for the prefix order, which is MSO-definable from `S₀, S₁`. Then put

```
Coding(P₀, Rt, Up, (A_p)) :⟺  P₀ ≠ ∅
  ∧ P₀ has a ≺-least element r, and Rt = {r}
  ∧ every u ∈ P₀ \ {r} has a ≺-greatest P₀-element strictly below it  (its parent)
  ∧ Up ⊆ P₀ \ {r},  each A_p ⊆ P₀ \ {r}
  ∧ the derived E (finding 4) is doubly serial on P₀ \ {r}
```

all first-order over `(≺, P₀, Rt, Up, (A_p))`, with quantifiers relativized to `P₀`. Two remarks:

- **No "finitely many ancestors" clause is needed.** Every node of the binary tree is a *finite*
  word, so its set of prefixes is finite; hence every `u ∈ P₀` automatically has finitely many
  `P₀`-ancestors and sits at finite child-distance from `r`. This is why the embedding into the
  binary tree, rather than an abstract appeal to `SωS`, is the convenient carrier.
- **`Coding` does not try to say "this forest is a universal cover".** It does not need to.
  Soundness of the reduction needs only that every structure satisfying `Coding` is a legitimate
  ZTime frame: `(P₀ \ {r}, E)` is a doubly serial oriented forest (its underlying undirected graph
  is `T*` minus `r`, a forest), hence satisfies `Saturation` by the cited oriented-forest lemma,
  hence with `comp`/`serial`/`limit` automatic over `ℤ` it is a ZTime frame. Completeness of the
  reduction is Steps A-C.

**The sentence.** With `⟦·⟧` the translation of finding 4 and `Walk` its walk predicate,

```
Θ_φ  :=  ∃P₀ ∃Rt ∃Up ∃(A_p)_{p ∈ At(φ)} ∃P ∃x
            [ Coding(P₀, Rt, Up, (A_p)) ∧ Walk(P) ∧ x ∈ P ∧ ¬⟦φ⟧(P, x) ]
```

a sentence of monadic second-order logic over `T` (the first-order `∃x` is simulated by a
second-order quantifier over singletons, as Thomas 1997 §6.3's `MSO₀` does). By Steps A-C and the
soundness remark above,

> **`¬PlusValidZTime φ` iff `T ⊨ Θ_φ`.**

**Step E.** `Θ_φ` is a sentence of `S2S`, and `S2S` is decidable:

> **Theorem 6.20 (Rabin Tree Theorem [Rab69])** — *The theory `S2S` is decidable.*
> — Thomas 1997, §6.3 (held, read this session)

and effectively so: Theorem 6.19 constructs from any MSO formula over `(S₀, S₁)` an equivalent
Muller tree automaton, and Theorem 6.18 (Rabin Basis Theorem, cf. Rab72) decides emptiness. Since
`Θ_φ` is computed from `φ` by a primitive recursion over the subformula structure, `φ ↦ Θ_φ` is
computable, and

> **`{φ : PlusFormula | PlusValidZTime φ}` is decidable.**

### 6. Dispatch item (3): every recalled citation replaced, and the exact form of Rabin's theorem

| Claim in report 03 §1.3 | Status there | Status here |
|---|---|---|
| Rabin's theorem (decidability of MSO over the tree) | recalled | **held**: Thomas 1997 Thm 6.20, `S2S` decidable, attributed to Rabin 1969 |
| MSO → tree automaton, effectively | not stated | **held**: Thomas 1997 Thm 6.19 (Muller tree automaton) |
| Emptiness decidable; regular witness | not stated | **held**: Thomas 1997 Thm 6.18 (Rabin Basis Theorem, cf. Rab72) |
| "countably branching trees are fine" | asserted | **held**: Thomas 1997 §6.3, explicit `1^{i₁}0⋯1^{i_l}0` embedding, "the decidability of `S2S` extends to tree models with arbitrary finite and even countable branching" |
| Gurevich-Shelah (MSO of all trees), via Reynolds 2002 §6 | recalled | **not needed** and not used |
| `SωS` | implicit in "ω-branching tree" | **not needed**: the embedding discharges countable branching inside `S2S` |
| Muchnik/Walukiewicz unravelling transfer (Thomas Thm 6.21) | not stated | **not needed** and not used |
| MSO over ℝ undecidable (Shelah) | recalled | **out of scope**: used only by report 03 §1.4 for RTime |
| Craig's observation | recalled | **held**: Chagrov & Zakharyaschev 1997 Thm 16.10, p. 496 |
| Oriented-forest `Saturation`; the universal cover is a two-way morphism onto its base | paper (§1.2) | **cited per dispatch**, owned by task 870 |
| `⊡` is state-determined; `□` is model-determined; truth commutes with shift; carrier is `ℤ` | not cited | **compiled**: `stab_state_only`, `box_global`, `plusTruthAt_timeShift`, `plusValidZTime_iff_plusValidInt` |

**The exact form of Rabin's theorem that is used.** Only this:

> Let `T = ⟨{0,1}*, S₀, S₁⟩` be the full binary tree. The set of monadic second-order sentences
> true in `T` is decidable, and the decision is effective in the sentence.

Nothing stronger. In particular the argument does **not** use decidability of MSO over the
ω-branching tree as a primitive, does **not** use the monadic theory of the class of all trees,
and does **not** use any transfer theorem for unravellings. Countable branching enters only
through the explicit prefix-preserving embedding, whose range is existentially quantified as `P₀`.

### 7. Dispatch item (4a): the theorem, with its hypotheses

> **Theorem (L⁺ validity at ZTime is decidable).** The set `{φ : PlusFormula | PlusValidZTime φ}`
> is decidable.
>
> **Hypotheses.**
> - **(H0)** Classical set theory with choice. AC is used once, for the simultaneous witness
>   choice in Lemma B; the construction is an ω-iteration of such choices.
> - **(H1)** *Compiled*: `plusValidZTime_iff_plusValidInt` — the duration carrier may be taken to
>   be `ℤ`.
> - **(H2)** *Compiled*: `taskRel_eq_iter` and the `IntNormalForm` layer — over `ℤ` a frame is
>   the signed iteration of its one-step relation, and `H_F` is the set of bi-infinite walks.
> - **(H3)** *Compiled*: `PlusTruth.stab_state_only`, `PlusTruth.box_global`,
>   `PlusTruth.plusTruthAt_timeShift`, `PlusTruth.truth_congr_ext`.
> - **(H4)** *Compiled*: `TwoWayBounded.plus_invariance_of_isZTime`.
> - **(H5)** *Cited, owned by task 870, currently `[NOT STARTED]`*: every doubly serial oriented
>   forest over `ℤ` satisfies `TaskFrame.Saturation`; and the universal cover of a doubly serial
>   digraph (components as orientation-keeping undirected multigraphs) is a doubly serial oriented
>   forest whose covering map is a surjective two-way bounded morphism. Report 03 §1.2 gives both
>   with a written proof.
> - **(H6)** *Held*: Thomas 1997 Theorems 6.18, 6.19, 6.20 and the countable-branching embedding
>   of §6.3.
>
> **Proof.** Steps A (finding 1), B (finding 2), C (finding 4), D and E (finding 5). ∎

**Confidence.** The chain is complete and every link is either compiled, held, or the single
cited item (H5). Relative to report 03 §1.3's self-label ("paper, Medium-High; rests on a recalled
theorem"), what has changed is that the recalled theorem is held, G1 and G2 are closed, and the
only unverified mathematical content left in the chain is (H5), which is a self-contained lemma
with a written proof and an owning task. This report labels the result **paper, High, conditional
on (H5)**. It is not machine-checked and this report does not make it so.

### 8. Dispatch item (4b): what the theorem does NOT give

- **No constructive decision procedure.** The decision procedure is effective in the classical
  sense (H6 is effective, and `φ ↦ Θ_φ` is computable), but the *proof* that it is correct is not
  constructive: Lemma B uses AC, and the completeness direction of the reduction
  (`¬PlusValidZTime φ ⟹ T ⊨ Θ_φ`) runs through three non-effective constructions — a universal
  cover of an arbitrary digraph, an ω-iterated choice closure, and an arbitrary rooting.
- **No Lean `Decidable (PlusValidZTime φ)`.** Nothing here contributes to the ladder engine's
  constructive target, and formalizing this route is refused by standing ruling (report 866
  finding 8, held: Mathlib has DFA/NFA/regular expressions and no MSO syntax, no ω-automaton, no
  determinization of ω-automata, no Rabin tree theorem). The two results are disjoint: a verdict
  here neither unblocks nor obstructs that front.
- **No complexity bound of any practical kind.** `Θ_φ`'s quantifier-alternation depth grows with
  the nesting depth of `□`/`⊡` in `φ`, each alternation is discharged by a complementation step,
  and Thomas 1997 §3 records (held, from Meyer and Stockmeyer via [AHU74]) that the time
  complexity of converting MSO formulas to equivalent automata "cannot be bounded by an
  elementary function" already over words. So **no elementary upper bound** follows from this
  construction. This is a statement about the method, not a lower bound on L⁺ ZTime validity;
  this report asserts no lower bound. (Report 01 of task 559 §2.4's observation that the logic
  contains full CTL* is the separate source for a lower bound and is not re-derived here.)
- **No finite model property.** Rabin's Basis Theorem *does* give a satisfying **regular** tree,
  hence (finding 9's by-product) a finitely presented refuting frame, but not a finite one. The
  generic finite-model remark in Thomas 1997 §6.3 — "if a formula of such a logic is satisfiable
  … also a regular tree model can be guaranteed. Such regular models originate from finite graphs
  … So the respective modal logic `L` has the so-called finite model property" — **does not
  transfer here**, and the reason is precisely report 03 §1.1's warning. Folding a regular tree by
  subtree type gives a finite graph, but the fold map is *not* a two-way bounded morphism: *forth*
  holds, and *back* fails, because a tree node has exactly one parent and so cannot witness every
  in-edge of its subtree type. `plus_invariance_of_isZTime` demands `TwoWayBounded`, so L⁺ truth
  need not transfer along the fold, and report 03's "folding by subtree type forgets what lies
  above a node" is exactly this failure. Thomas's remark is sound for bisimulation-invariant
  logics whose models are read forward from a root; L⁺'s `⊡` reads both directions.
- **Nothing at Base, Dense or RTime.** Report 03 §1.4 locates those obstructions (tree-like
  preimages at a general duration would need a relative form of Saturation that no known
  construction has; over ℝ the MSO route is independently blocked). This report reaches **ZTime
  only** and claims nothing about r.e.-ness, axiomatizability or decidability at the other three
  classes.
- **No completeness result.** Decidability of the validity set is not completeness of any
  particular proof system, and nothing here licenses stating completeness of TM⁺ or of any
  extension at any class.

### 9. Dispatch item (5): Craig's observation and recursive axiomatizability

> **Theorem 16.10 (Craig's theorem).** For every logic `L` the following are equivalent:
> (i) `L` has a recursively enumerable set of axioms; (ii) `L` has a recursive set of axioms;
> (iii) `L` is recursively enumerable. *Remark*: it remains true for axiom **schemes**, and for
> axiomatizations over a fixed r.e. base logic `L₀ ⊆ L`.
> — Chagrov & Zakharyaschev 1997, *Modal Logic*, ch. 16 p. 496 (held, read this session)

Their proof of (iii) ⟹ (ii) replaces the `n`-th enumerated theorem `φ_n` by the `n`-fold
conjunction `φ_n ∧ ⋯ ∧ φ_n`, which is recognizable in polynomial time; it uses only the admissible
rules `p / p ∧ p` and `p ∧ p / p`, so it does **not** depend on a substitution rule. That matters
here, because uniform substitution is unsound in this semantics (atoms are state-valued and an
arbitrary L⁺ formula is not state-local), which is also why Reynolds 2003 writes "we do not use a
substitution rule as it is not valid" (held, via report 03's reading of that source).

**Verdict.** Report 03's amendment of 2026-11-05 records the existence question as open. On the
theorem of finding 7 it is **closed, affirmatively, and did not need Craig**:

- Decidability makes `V := {φ | PlusValidZTime φ}` a **recursive** set. Then `V` is literally its
  own recursive axiom set: take axioms `V`, rules none (or MP alone, which `V` is closed under).
  This is Craig's (ii) directly, with no trick required.
- Craig's theorem is the instrument needed in the weaker situation where only (iii) is available —
  that is, if one had r.e.-ness of `V` without decidability. That situation does not arise at
  ZTime under finding 7, and it is exactly the situation at Base, Dense and RTime, where
  r.e.-ness is itself open (report 03 §1.4).

**What remains open, and should not be conflated with the above.** A recursive axiom set is not a
*natural* system. The open questions report 03 §2 locates are untouched: whether a finite set of
schemata (`LC_n` for all `n`, or a finite subfamily of it, over TM⁺ plus the clock and
transposed-AA rules) axiomatizes the ZTime validities, and whether the `LC_n` family is
independent. Finding 7 answers "is there a recursive axiomatization?" and says nothing about "is
there a finitely schematic one?".

**A by-product worth recording.** Theorem 6.18 (Rabin Basis Theorem) applied to `Θ_φ` yields more
than decidability: whenever `φ` is refutable at ZTime, the satisfying expanded binary tree may be
taken **regular**, with its generating word automaton obtained effectively. Decoding through
`P₀`, this is a **regular-model property**: every ZTime-refutable L⁺ formula is refuted on a
finitely presented (automaton-generated) doubly serial oriented forest. Finitely presented, not
finite — see finding 8 on why the fold to a finite digraph is unsound.

### 10. Dispatch item on the open modals: one paragraph, and a correction

**The repaired step 1 does not admit the open-modal amendment, and report 866 finding 5's
countability claim for it is itself an instance of G1.** The repair in finding 2 works because the
object that determines a modal's quantifier class ranges over a set that is *being made
countable*: for `⊡` that object is a world state (`stab_state_only`, compiled) and the closure runs
over states; for `□` it is nothing at all (`box_global`, compiled) and finitely many global
witnesses suffice. For `▷` the determining object is an entire backward ray — `AgreeUpTo τ σ t`
is agreement at every time `≤ t` — and the set of backward rays of a countable oriented forest is
in general of size continuum, so indexing witnesses by it does not give a countable closure.
Report 866 finding 5 proposed indexing by "(walk already in the set, time in ℤ, diamond
subformula)" and concluded "an ω-iteration of a countable-to-countable closure is countable"; that
is precisely the move G1 forbids, because the induction in Lemma B must hold at **every** walk of
the sub-digraph, not only at the designated ones, and the sub-digraph has uncountably many walks.
Report 866's own finding 6 states the obstruction and its finding 5 then walks into it. So: `▷`
and `◁` still ride step 4's encoding (finding 4's `⊑` clauses, confirmed here, now with the
`¬Rt(meet)` guard) and still ride the cover step, but they have **no countable-model step**, and
L^▷ decidability at ZTime is therefore *not* obtained here. A repair would need a countable-model
argument of a different kind — an elementary-submodel or Hintikka-type/mosaic argument in which
the ray is replaced by a finite type — and that is a research project, not an amendment. Per the
dispatch, this stops here.

### Cross-Domain Synthesis

The logical content (two universal modals, one restricted by a state equation and one
unrestricted) and the mathematical content (a closure operator's cardinality) meet at exactly one
point, and the meeting is the whole repair. A witness closure is countable iff it is indexed by
something countable. The repository's compiled `stab_state_only` and `box_global` say that L⁺'s two
non-local modals are indexed by a *world state* and by *nothing*; the carrier of world states is
precisely what the countable-model step is cutting down; so the closure is countable. Report 03
reached the right index set by the wrong route and report 866 correctly rejected the route, but the
index set was right.

The second meeting point is in the other direction: the oriented forest's order-theoretic gift
(unique directed paths) is what lets an *unindexed node set* `P` stand in for a *time-indexed
walk*, and therefore what makes the whole MSO encoding possible — including, as finding 4 shows,
what makes the new super-root harmless everywhere except in the one place where the tree order and
the digraph order disagree about what a meet is.

## Decisions

1. **The argument is reordered: cover first, countable model second.** Forced by
   `FrameOver.IsRegular` bundling `saturation`, which makes the compiled invariance theorem
   demand Saturation of the base frame. Decided to reorder rather than to propose a Saturation-free
   regularity hypothesis in Lean, since reordering costs nothing (induced sub-digraphs of oriented
   forests are oriented forests) and proposing Lean changes is outside this task's scope.
2. **G1 is repaired by re-justification, not by reconstruction.** Decided to keep report 03's
   construction verbatim and replace its justification with `stab_state_only` / `box_global`,
   rather than to invent a new countable-model argument. This is the minimal repair and it makes
   the step's load-bearing content compiled rather than paper.
3. **`⊑` is given with the `¬Rt(meet(y, x))` conjunct rather than relying on the
   `Up(r_i) := false` convention.** Both are sound; the conjunct is local to the definition and
   does not depend on how the component roots are labelled.
4. **Rabin is cited at `S2S`, not at `SωS`.** Decided to carry the countable-branching embedding
   explicitly (Thomas 1997 §6.3) so that the single held statement of Theorem 6.20 discharges the
   step, rather than citing a broader theorem whose exact form is not in hand.
5. **Craig is recorded as *not needed*, with the held citation kept anyway.** The dispatch asked
   whether Craig's observation yields recursive axiomatizability; the honest answer is that
   decidability yields it directly and Craig is the tool for the weaker hypothesis. Decided to
   record both, and to keep the held citation because it is the instrument the Base/Dense/RTime
   questions will need if r.e.-ness is ever established there without decidability.
6. **The open-modal paragraph is a correction of report 866, stated as such.** Decided to say
   plainly that finding 5 of that report walks into the gap its own finding 6 names, rather than
   to leave a softer "the economy is lost but countability survives" reading standing.
7. **(H5) is cited and not reproved**, per the dispatch. Decided additionally to flag that task
   870's stated hypothesis (directed-path uniqueness) looks weaker than what report 03 §1.2's
   step 4 consumes (an underlying forest), so that the Lean lemma is stated at the strength the
   argument needs.

## Recommendations

- **R1 (file it; small).** `/revise` task 870 to restate its hypothesis at **oriented-forest**
  strength (the underlying undirected graph is a forest), not merely directed-path uniqueness.
  Report 03 §1.2's own step 4 needs the stronger hypothesis (finding 1; decision 7); a Lean lemma
  stated at the weaker hypothesis will not discharge (H5). This report propagates the flag (report
  03 §1.2's new note, this report's decision 7, and `specs/ROADMAP.md`'s `870` run-order
  annotations) but does not itself mutate task 870's record — that is a `/revise` operation for
  870's owner or the user.
- **R2 (optional, not filed).** A separate task to write the theorem of finding 7 into
  `typst/chapters/p3-decidability-frontier.typ` as a citable chapter-level result, subject to its
  own chapter-quality gate (source grounding, anti-fluff density, presentation clarity,
  open-question honesty). The dispatch that produced this report asked for a report only; this
  recommendation is left for the user to file if wanted beyond the report.

## Risks & Mitigations

- **Risk: the theorem is read as machine-checked.** It is not; it is a paper theorem, conditional
  on (H5). *Mitigation*: finding 7's hypothesis list labels every item by tier, and the Context &
  Scope vocabulary is explicit.
- **Risk: (H5) turns out to need more than an oriented forest, or task 870's lemma lands at the
  weaker directed-path-uniqueness hypothesis and does not discharge (H5).** *Mitigation*: finding
  1 flags the discrepancy and this task's issue log records it; task 870's plan should state the
  oriented-forest hypothesis. If (H5) fails, the whole chain fails at Step A and the conclusion
  reverts to report 03's status.
- **Risk: Lemma B is read as establishing a countable model for L^▷ too.** It does not; finding 10
  is explicit, and the mechanism (state-indexed closure) is stated in a form that makes the
  failure for `▷` immediate.
- **Risk: the regular-model by-product (finding 9) is read as a finite model property.** It is
  not. *Mitigation*: finding 8 states the fold map's failure of *back* and why Thomas's generic
  remark does not transfer.
- **Risk: the `Walk` predicate's correctness is read as holding in an arbitrary digraph.** It
  does not; it needs the absence of directed cycles, which needs the cover to be a simple tree,
  which needs the multigraph convention of finding 1. *Mitigation*: stated at both points.
- **Risk: this report is read as proposing a Lean formalization of the MSO route.** It is not;
  the standing refusal is restated in Context & Scope and finding 8.
- **Risk: `Θ_φ`'s `Coding` predicate is thought to need a finiteness or well-foundedness clause
  that MSO cannot express.** It does not, because binary-tree nodes are finite words.
  *Mitigation*: stated as the first remark of finding 5.

## Appendix

### Evidence tier by claim

| Claim | Tier |
|---|---|
| `PlusTruthAt`'s `box` and `stab` clauses; both quantify at the same time | compiled (`PlusTruth.lean:84`) |
| `⊡φ` is one bit per world state | compiled (`stab_state_only`, `:332`) |
| `□φ` is one bit per model | compiled (`box_global`, `:372`) |
| L⁺ truth commutes with time shift | compiled (`plusTruthAt_timeShift`, `:264`) |
| Duration carrier normalizes to `ℤ` | compiled (`plusValidZTime_iff_plusValidInt`, `PlusIntTransfer.lean:188`) |
| Over `ℤ` a frame is its one-step relation; `H_F` = bi-infinite walks | compiled components (`taskRel_eq_iter`, `IntNormalForm.lean:224`), assembled here (derived) |
| `IsRegular` bundles `saturation`, so invariance needs it of both frames | compiled (`TaskFrame.lean:1185`, `HistoryMorphism.lean:589`) |
| L⁺ truth invariance along a surjective two-way bounded morphism over discrete time | compiled (`plus_invariance_of_isZTime`) |
| Oriented forests satisfy `Saturation`; the universal cover is a two-way morphism onto its base | cited (report 03 §1.2; task 870) |
| Induced sub-digraph of an oriented forest is an oriented forest | derived (finding 1) |
| The universal cover of a multigraph is a *simple* tree, so no directed 2-cycles | derived (finding 1) |
| Lemma B (countable model), the G1 repair | paper, this session (finding 2); its two load-bearing lemmas compiled |
| At most `1 + |{□χ ∈ cl φ}|` components are needed | derived (finding 3) |
| New-root coding; `E` first-order; `Walk` needs no `r`-exclusion | derived (finding 4) |
| `⊑` needs the `¬Rt(meet(y,x))` guard in `T*` | derived (finding 4) |
| `(P, x)` determines truth (the forgotten time index is harmless) | derived from compiled `plusTruthAt_timeShift` (finding 4) |
| `⊑` is first-order over the tree order plus `Up`; `U`/`S` and `▷`/`◁` clauses | report 866 finding 3 (derived there), rechecked here |
| `Coding` needs no finiteness clause | derived (finding 5) |
| `S2S` is decidable (Rabin Tree Theorem) | **held** (Thomas 1997 Thm 6.20) |
| MSO → Muller tree automaton, effectively | **held** (Thomas 1997 Thm 6.19) |
| Emptiness decidable; regular witness obtainable | **held** (Thomas 1997 Thm 6.18) |
| Countable branching embeds in the binary tree, with the explicit coding | **held** (Thomas 1997 §6.3) |
| MSO→automaton conversion is non-elementary already over words | **held** (Thomas 1997 §3, from Meyer-Stockmeyer via [AHU74]) |
| Craig's theorem, (i) ⟺ (ii) ⟺ (iii), also for schemes | **held** (Chagrov & Zakharyaschev 1997 Thm 16.10) |
| Thomas's generic finite-model remark does not transfer (fold map fails *back*) | derived (finding 8), against report 03 §1.1's compiled warning |
| Mathlib has no MSO / ω-automata / Rabin | held (report 866 finding 8, two leansearch queries there) |
| Open modals have no countable-model step; report 866 finding 5 is an instance of G1 | derived (finding 10) |
| Base, Dense, RTime obstructions | report 03 §1.4, not revisited |

### References

- `specs/559_nondeterministic_canonical_model_tm_star_completeness/reports/03_axiomatizability-rules-engine.md`
  §1.1 (two-way invariance), §1.2 (the cover and oriented-forest Saturation), §1.3 steps 1-5 (the
  argument repaired here), §1.4 (the other three classes), §2 (the `LC_n` schemata and the
  natural-system question left open)
- `specs/866_mso_route_open_modals_ztime_decidability/reports/01_mso-route-open-modals.md`
  findings 3 (the `⊑` clauses), 4 (the cover carries `▷`/`◁`), 5 (corrected in finding 10 here),
  6 (G1 and G2), 8 (Mathlib verdict)
- `FormalSystem/PlusLanguage/PlusTruth.lean:84` (`PlusTruthAt`), `:221` (`stab_congr_state`),
  `:239` (`truth_congr_ext`), `:264` (`plusTruthAt_timeShift`), `:332` (`stab_state_only`),
  `:349` (`box_time_invariant`), `:372` (`box_global`)
- `FormalSystem/PlusLanguage/PlusValidity.lean:117` (`PlusValidZTime`),
  `FormalSystem/PlusLanguage/PlusIntTransfer.lean:167` (`PlusValidInt`), `:188`
  (`plusValidZTime_iff_plusValidInt`)
- `FormalSystem/Semantics/TaskFrame.lean` (`Saturation`, `Serial`, `Compositional`, `Limit`,
  `FrameOver.IsRegular` at `:1185`), `FormalSystem/Semantics/IntNormalForm.lean:182` (`step`),
  `:224` (`taskRel_eq_iter`), `FormalSystem/Semantics/HistoryMorphism.lean:281`
  (`TwoWayBounded`), `:589` (`plus_invariance_of_isZTime`),
  `FormalSystem/Semantics/FrameProperty.lean:192` (`TaskFrame.IsZTime`),
  `FormalSystem/Semantics/FrameClassValidity.lean:156` (`Sat .ZTime`)
- W. Thomas, *Languages, Automata, and Logic* (1997), §3 (the non-elementary conversion bound),
  §6.2 (determinacy and complementation of Rabin chain tree automata), §6.3 (Theorems 6.18, 6.19,
  6.20; the countable-branching embedding; the Kripke-structure coding; the generic finite-model
  remark). `/home/benjamin/Projects/Literature/sources/thomas_1997_languages/`
- A. Chagrov and M. Zakharyaschev, *Modal Logic* (Oxford Logic Guides 35, 1997), ch. 16
  ("The decidability of logics"), p. 496: Lemmas 16.8-16.9, Theorem 16.10 (Craig's theorem) and
  its Remark, Theorem 16.11.
  `/home/benjamin/Projects/Literature/sources/chagrovzakharyaschev_1997_modallogic/chunk_0821.md`
  (chunk id `5b8f6ce7f913a74f`; `provenance_fidelity: verified_conversion`). OCR hazard on these
  DJVU-derived pages: the conjunction `φ_n ∧ ⋯ ∧ φ_n` reads as `= (fn A ... A (pn`, and `ψ_n`
  as `xpn` / `x/j`; the prose is legible and the formula shapes were reconstructed from it.
