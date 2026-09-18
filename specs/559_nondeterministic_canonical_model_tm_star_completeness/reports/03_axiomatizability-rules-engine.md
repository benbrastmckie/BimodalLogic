# Research Report: Task #559 (round 03: axiomatizability, LC schemata, rules, engine)

**Task**: 559 - nondeterministic_canonical_model_tm_star_completeness
**Started**: 2026-09-18T23:22:07Z
**Completed**: 2026-09-18T23:41:00Z
**Effort**: one research dispatch (orchestrated, seq 5, `--lit`)
**Dependencies**: reports 01 and 02 of this task and probes 01/02 (not redone); 535 (archived), 533, 536, 537 (landed baseline)
**Sources/Inputs**: - Codebase (`Semantics/TaskFrame.lean` for the literal `Saturation`/`Fib`/`Seg` definitions; the anchors already audited in reports 01/02), a compiled Mathlib-only probe (bare `lean`, pinned toolchain and Mathlib oleans, no `lake` process, no `FormalSystem` import), and the literature corpus: `reynolds_2003_priors-ockhamist-logic-historical-necessity` (all 29 chunks), `reynolds_2002_axioms_for_branching_time` (§6, §8, §9.1), `reynolds_2001` (§7: Definition 4, AA rule, Lemma 6). Not held and therefore not used as sources: Reynolds 2005, Zanardo 1991, Di Maio-Zanardo 1998, Gurevich-Shelah 1985, Kupferman-Pnueli-Vardi 2012, Rabin 1969.
**Artifacts**: - `specs/559_nondeterministic_canonical_model_tm_star_completeness/reports/03_axiomatizability-rules-engine.md` (this report); - `specs/559_nondeterministic_canonical_model_tm_star_completeness/probes/03_morphisms-clock-rule-lc-schema.lean` (814 lines, sorry-free, exit 0)
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **New tool, compiled: truth is invariant under surjective two-way bounded morphisms**
  (`tw_invariance`). A world state CAN be split without changing `⊡`, provided every copy keeps
  all of its predecessors and successors up to copy. The dispatch premise "splitting a world state
  changes `⟨τ⟩_t` and hence `⊡`" is true of past-unravelling and false of two-way unravelling.
  Everything below that is positive comes from this lemma.
- **Q3, overturned: all three of Reynolds' non-axiom ingredients are sound here.**
  - Gabbay's plain IRR rule `⊢ (q ∧ H¬q) → φ ⟹ ⊢ φ` is sound (`irr_sound`, compiled over ℤ).
  - A stronger *clock rule* is sound (`clock_irr_sound`, compiled over ℤ): `q` may be assumed to
    hold at exactly one time of every history, with that time `⊡`-rigid. A time cannot be named
    globally (`□` sees every shift, which is why 535's candidate is unsound), but it can be named
    **within every `⊡`-cluster**, which is what IRR does on a tree.
  - The semantic core of Reynolds 2001's Auxiliary Atoms rule transfers (`aa_expand`, compiled):
    the forward-cone unravelling is a two-way-morphic preimage whose forward cone is a tree.
  - The model transformation behind both naming rules is the *clock product* `F × D`, which exists
    at every class and preserves all four frame axioms (paper argument). No language extension is
    needed for naming.
- **Q1 at ZTime: Saturation is idle, and validity is decidable (paper argument, Medium-High).** The
  universal cover of a doubly serial digraph is a two-way-morphic preimage, and every oriented tree
  satisfies the literal `Saturation` (proof in Findings 1.2). So ZTime-validity is validity over
  all doubly serial digraphs, which is an MSO-definable property of countably branching trees.
  Decidability then rests on Rabin's theorem, which is recalled and not held. Base, Dense and
  RTime: r.e. status OPEN, with the obstruction located (Findings 1.4).
- **Q2: the right limit-closure principle is Reynolds 2003's infinite schema `LC_n`, transposed.**
  `LC_n := ⊡G≤ ⋀_{i<n}(⟐αᵢ → ⟐F⟐α_{i+1}) → ⟐G≤ ⋀_{i<n}(⟐αᵢ → F⟐α_{i+1})` (indices mod `n`) is
  valid on every all-walks ℤ-model for every `n ≥ 1` and arbitrary `αᵢ` (`lcN_valid_full`,
  compiled). It is valid at Base by Zorn plus `extension` (paper argument, same pattern as report
  02 §2, UNVERIFIED in Lean). The until-form of Reynolds 2001's LC is X-free in this language and
  its semantic core is an instance of the compiled `omega_chain`; but it is a ZTime-only principle:
  a Zeno pattern refutes it over dense time (paper sketch, UNVERIFIED).
- **Q4/Q5: ZTime first, by a Reynolds-2001-style engine.** At ZTime the candidate system is
  TM⁺ + `LC_n` + `LCU` + the clock rule + the transposed AA rule, every ingredient has a compiled
  soundness core, no frame axiom is at risk (Saturation is idle), and the blueprint is a held paper
  with a full proof. The located obstruction is Reynolds' one-sided automaton: it reads ω-words
  from a root, and here emergent histories are limits of splices in *both* directions.
  Completeness remains CONJECTURED at every class; nothing here licenses stating it.
- **560**: report 02's rescope stands (`plus_incomplete_base` with BLC). Nothing in this round
  changes it; two follow-on tasks are proposed (Recommendations).

## Context & Scope

The dispatch fixed the semantics (task frames with all four axioms, `H_F` = all total histories,
`□` over `H_F`, `⊡` over histories through the current state) and asked six questions about a sound
and complete system for it. Reports 01 and 02 established incompleteness of the current `PlusAxiom`
set at ZTime and Base; that was not re-investigated. Constraints carried over: research only, no
change under `FormalSystem/` or `Tests/`, no `lake build`, probes import Mathlib only, never a
sorried completeness theorem, every unchecked claim labelled, every literature claim tied to a held
source or labelled recalled.

**Status vocabulary used below.** *Compiled*: a theorem of probe 03, in the ℤ-specialised mirror of
`PlusTruthAt` whose faithfulness reports 01/02 audited (over ℤ, `H_F` is the set of bi-infinite
`⇒₁`-walks). *Paper*: an argument written out here and not machine-checked. *UNVERIFIED*: a sketch.
*Recalled*: a literature fact not backed by a held source.

## Findings

### Codebase Patterns

- `TaskFrame.Saturation` (`Semantics/TaskFrame.lean:540`) quantifies over `⊇`-directed families of
  nonempty members, each a fibre `Fib R w x` (any duration, negative ones run backwards) or a
  segment `Seg R w v x y = Fib R w x ∩ Fib R v (-y)` with `x, y ≥ 0`. Findings 1.2 is proved
  against exactly this shape.
- The repository has no notion of bounded morphism, frame product or unravelling (searched:
  `bounded morphism`, `pmorphism`, `p_morphism` under `FormalSystem/`). The landed discharge
  helpers `limit_of_shift`, `saturation_of_fib_finite` and
  `sInter_nonempty_of_directed_of_minimal` are the natural targets for Findings 3.2.
- `PlusDerivationTree` has no fresh-atom rule (report 01). A rule of IRR type is validity-preserving
  and not truth-preserving, so it must be restricted to the empty context, as the necessitation
  rules already are.

### External Resources

- **Reynolds 2003 (held; extended abstract; OCR formulas unreliable, so each item below is
  re-derived from the prose).**
  - The bundled system: MP, temporal and branching generalisation, a Gabbay-style IRR rule with a
    fresh atom `p` and antecedent `p ∧ H¬p`, the ANF rule `p → □p` for atoms, linear axioms L1-L4
    for F/P only (no until/since), S5 for `□`, HN `Pα → □P◇α`, MB `G⊥ → □G⊥`. "We do not use a
    substitution rule as it is not valid."
  - §5: the separating formula is `□G(p → ◇Fp) → ◇G(p → Fp)`, from the paper's [20]; limit
    closure is "in our case transfinite".
  - LC, reconstructed from the statement of Lemma 3 and its proof (the proof names
    `δ = □G≤ ⋀_{i<n}(◇αᵢ → ◇F◇α_{i+1})` and concludes
    `σ, t ⊨ G≤ ⋀_{i<n}(◇αᵢ → F◇α_{i+1})` for a history `σ ⊇ π`): "an infinite sequence of
    axioms: one for each `n > 0`", with `αₙ = α₀`. The soundness proof cycles through the indices
    by transfinite induction and extends the resulting linearly ordered set to a history; beyond
    that set no `◇αᵢ` holds, so the implication is vacuous there.
  - §6-7: completeness is a sketch. It needs finite labels (hues; a colour is the set of hues of
    a whole `≈`-class and corresponds to a state formula), the IRR rule "for two reasons: matching
    squares … and as part of the banning procedure", LC, and three kinds of ban on colours.
- **Reynolds 2002 (held).** §6: the branching-time logics discussed "are (almost) all decidable.
  This follows from the decidability of the full monadic second-order theory of the class of all
  trees" (the paper's [12], [13]: Gurevich-Shelah, not held). The proof "does not work for the
  Ockhamist logic without the no-trace-of-futurity assumption on valuations of atoms". §8: Kamp
  frames, with the shared-past condition "if `x ≈ y` and `u < x` then there is `v < y` such that
  `u ≈ v`". §9.1: the LC schema is proposed there first; the CTL* proof used "a deterministic
  linear automaton to record the state of construction (along each branch) and an elaborate
  banning mechanism".
- **Reynolds 2001 §7 (held).** Definition 4: `θ = b₀ ∧ AG ⋀((b ∧ aᵢ) → AX p(b,i)) ∧ AG ⋀¬(b ∧ b')`
  with the `aᵢ` pairwise inconsistent, jointly exhaustive state formulas of the old language and
  `p : Q × {1..n} → Q`. AA: from `⊢ θ → ψ` infer `⊢ ψ` when `ψ` uses no `Q`-atom. Lemma 6 proves
  soundness by "a simple recursion on the length of finite prefixes of branches starting at" the
  root. §1: the rule "is generally only useful when the Kripke (transition) frame is a tree".
- **Not used as sources.** Rabin's theorem (SωS), Shelah's undecidability of MSO over ℝ, Gabbay
  separation: recalled. Reynolds 2005, Zanardo 1991, Di Maio-Zanardo 1998, Kupferman-Pnueli-Vardi
  2012: not held; nothing below depends on their content.

### 1. Q1: axiomatizability in principle

#### 1.1 Invariance under two-way bounded morphisms (compiled)

`TwoWay R' R f` says `f` is a digraph homomorphism with *forth* (every out-edge of `f a` lifts to
an out-edge of `a`) and *back* (every in-edge of `f a` lifts to an in-edge of `a`).

- `lift_walk`: every walk through `f a` at `t` lifts to a walk through `a` at `t`, by dependent
  choice forwards and backwards.
- `tw_invariance`: for surjective `f` and every formula, walk `σ'` and time,
  `T (fullModel R' (V ∘ f)) σ' t φ ↔ T (fullModel R V) (f ∘ σ') t φ`. Surjectivity is used for
  `□` only.

What this does and does not allow. Splitting a state by its *past* (the tree unravelling of
Ockhamist semantics) is not a two-way morphism: the copy indexed by one past loses the other
in-edges, *back* fails, and `⟐Pq` changes value. Splitting that keeps branching in both directions
is harmless.

#### 1.2 Saturation is idle at ZTime (paper)

**Claim.** A formula is valid on all ZTime frames iff it is valid on all doubly serial digraphs
with the all-walks semantics, Saturation dropped.

*Proof.* One direction is inclusion. For the other, let `G` be a doubly serial digraph refuting
`φ`, and let `G̃` be the disjoint union of the universal covers of its components (as undirected
multigraphs, orientation kept). The covering map is a surjective two-way bounded morphism, with
unique lifts, so `G̃` refutes `φ` by 1.1. `G̃` is doubly serial, and it is an *oriented forest*: a
directed walk is a reduced path, so directed paths between two nodes are unique. It remains to
show that an oriented forest satisfies the literal `Saturation`.

1. Every segment is a subsingleton. For `x, y > 0`, a member of `Fib(w,x) ∩ Fib(v,-y)` lies on the
   unique directed path from `w` to `v`, at distance `x` from `w`. For `x = 0` or `y = 0` the
   segment is inside `{w}` or `{v}`.
2. If a directed family has a singleton member `{b}`, directedness puts `b` in every member. So
   assume every member has at least two elements; by step 1 all members are fibres of nonzero
   duration.
3. A forward fibre `Fib(a,n)` and a backward fibre `Fib(a',-m)` share at most one element, since
   two common elements would give two directed paths from `a` to `a'`. Directedness therefore
   forces all members to have the same sign; say forward.
4. Among all representations `Fib(a,n)` of members choose one, `F_m = Fib(a_m, r_m)`, with `r_m`
   least. Let `F_i` be any member and `F' = Fib(a',n') ⊆ F_m ∩ F_i` a member. For `x ∈ F'` the
   directed paths `a_m → x` and `a' → x` merge at a node that is the unique sink of the reduced
   path between `a_m` and `a'`, hence independent of `x`; call it `m`, at distance `k` from `a_m`.
   Then `F' = Fib(m, r_m - k)`, a representation of a member with duration `r_m - k`. Minimality
   gives `k = 0`, so `F' = F_m` and `F_m ⊆ F_i`.
5. Hence `F_m ⊆ ⋂ S`, which is nonempty. ∎

Consequences.

- Limit closure at ZTime needs no Saturation; the compiled proofs (`limit_walk`, `limit_walkB`,
  `lcN_valid_full`) indeed use dependent choice only. Report 02's mechanism statement "Saturation
  yields limit closure" is the right description at Base, Dense and RTime, not at ZTime.
- A ZTime engine has no Saturation obligation in principle. In Lean the practical route is a
  finitely branching construction (`saturation_of_fib_finite`) or a formalised step 1-5.

#### 1.3 Decidability at ZTime (paper, Medium-High; rests on a recalled theorem)

1. *Countable model property.* Close a countable set of walks under one chosen witness walk per
   (state, `⟐ψ` or `◇ψ` in the closure of `φ`). State-local truth is shift-invariant, so one
   witness per state suffices, and induction on `ψ` shows truth is preserved for walks of the
   sub-digraph (the `⊡` case uses the witness for `⟐¬ψ`).
2. By 1.2 pass to the cover: a countable oriented forest, doubly serial.
3. Root each tree anywhere. It becomes a countably branching rooted tree with one unary predicate
   for the orientation of the parent edge and one per atom.
4. A walk with a marked time is a pair `(P, x ∈ P)` with `P` a set of nodes that is connected and
   has exactly one in-neighbour and one out-neighbour in `P` at each node. Truth of a formula at
   `(P, x)` is MSO-definable by the usual translation of `U`/`S`; `⊡ψ` is `∀P' ∋ x`, and `□ψ` is
   `∀P' ∀x' ∈ P'` (shift-closure makes `□` the universal modality).
5. Satisfiability is therefore an MSO sentence over the full ω-branching tree, decidable by
   Rabin's theorem (recalled; the held Reynolds 2002 §6 describes the same method for the tree
   logics via Gurevich-Shelah).

So at ZTime the validities are decidable, hence recursively axiomatizable; the open question is
only a *natural* system. Report 01 §2.4 gives the lower bound (contains full CTL*). The finite
model property is NOT established: a regular tree does not obviously fold to a finite digraph whose
cover is that tree, because folding by subtree type forgets what lies above a node.

#### 1.4 Base, Dense, RTime: OPEN, with the obstruction located

- **What transfers from Gurevich-Shelah (via Reynolds 2002 §6).** The method needs atoms to carry
  no trace of futurity. Here atoms are state-valued, so the hypothesis holds.
- **What does not.** The method needs tree models. `lift_walk` is dependent choice over integer
  steps. For a general `D` a morphism needs forth and back at every duration, and lifting a total
  history needs Zorn plus an Extension Theorem *inside the preimage frame and inside the fibre over
  the given history*, that is, a relative form of Saturation. No tree-like preimage with that
  property is known. The clock product of Findings 3.2 has unique lifts and escapes the problem,
  but it does not make the frame tree-like.
- **RTime.** An MSO route is blocked independently (MSO over ℝ is undecidable: recalled).
- **Verdict.** Whether the Base, Dense or RTime validities are r.e. is open. A complete finitary
  system for them cannot be promised before this is settled.

### 2. Q2: the limit-closure schemata

#### 2.1 The general principle (compiled)

- `omega_limit`: walks `τ_k` with strictly increasing markers `c_k`, each agreeing with its
  predecessor up to `c_k`, have a limit walk agreeing with `τ_k` up to `c_k`.
- `omega_chain`: let `A i s v` be predicates of index, time and state, and `P i η s s'` a property
  of the segment of `η` on `(s, s']`. If every `A i`-point at `s ≥ t` on a walk through `w` at `t`
  can be continued by a splice to a later `A (i+1)`-point with the new segment satisfying `P i`,
  then one walk through `w` at `t` has markers `c_0 < c_1 < …` with `A k` at `c_k` and `P k` on
  each segment. `limit_walk` (probe 01) and `limit_walkB` (probe 02) are instances.

#### 2.2 `LC_n`: the schema for every class

`LC_n := ⊡G≤ ⋀_{i<n}(⟐αᵢ → ⟐F⟐α_{(i+1) mod n}) → ⟐G≤ ⋀_{i<n}(⟐αᵢ → F⟐α_{(i+1) mod n})`.

- **ZTime: compiled** (`lcN_valid_full`), for every `n ≥ 1` and *arbitrary* formulas `αᵢ`. No
  state-locality side condition is needed, because each parameter occurs under `⟐`. Proof: if no
  `⟐αᵢ`-point is reachable the current history witnesses the consequent vacuously; otherwise
  `omega_chain` with `A k := ⟐α_{(i₀+k) mod n}` gives a walk on which every index recurs beyond
  every time.
- **Base: paper, UNVERIFIED in Lean.** Let `Q(μ)` hold of a partial history whose domain is a
  down-set containing `t`, with `μ(t) = σ(t)`, and on which every `⟐αᵢ` is cofinal. `Q` is closed
  under unions of chains. If some `⟐αᵢ`-point is reachable, the ω-chain (dependent choice,
  `PlusPasting.paste`, the antecedent applied to each total stage) puts a member in `Q`. Take a
  `Q`-maximal `μ*` (Zorn) and a total extension `τ` (`extension`). At a point of `dom μ*` the
  consequent holds by cofinality. At a point `x` beyond `dom μ*` with `⟐αⱼ`, restarting the
  ω-chain from `(τ, x)` yields a member of `Q` strictly extending `μ*`; so no such `x` exists and
  the implication is vacuous there. State-locality of `⟐αᵢ` (`stab_state_only`) is what makes
  `Q` well defined on partial histories.
- **One schema, finitely many, or infinitely many?** `LC_n` is an instance of `LC_m` whenever
  `n ∣ m` (take periodic parameters), so the family is directed. Whether a finite subfamily
  suffices is OPEN; the held source states the family as infinite and proves nothing about
  independence. BLC of report 02 is, up to the extra conjunct `⟐Fp`, `LC_1` with `α₀ := p`.
- **`LC_1(p)` is already independent of the current axioms** (paper, one line): in report 02's
  bundle `evFalse` the antecedent holds everywhere, and at a `p`-point every member through the
  class has a last `p`-time, where `⟐p → F⟐p` fails.

#### 2.3 `LCU`: the until-form, ZTime only

Reynolds 2001's LC is `AG(Eα → EX(Eβ U Eα)) → (Eα → EG(Eβ U Eα))` with non-strict `U`. Over ℤ,
`X(b U≤ a)` is the strict `untl b a`, so the transposition is X-free:
`LCU := ⊡G≤(⟐α → ⟐(⟐β U ⟐α)) → (⟐α → ⟐G≤(⟐α ∨ (⟐β U ⟐α)))`.

- **ZTime.** The semantic core is `omega_chain` with `A k := ⟐α` and `P k η s s' :=` "`⟐β` on
  `(s, s')`": every time from `t` on is a marker or lies in a `β`-stretch ending at a marker.
  Compiled at that level; the formula-level statement is UNVERIFIED.
- **Dense, RTime, Base: invalid (paper sketch, UNVERIFIED).** Already the deterministic line shows
  the shape fails over dense time: `α` at `-1/k`, `β` between, neither from `0` on; the antecedent
  holds at `-1` and `⟐α ∨ (⟐β U ⟐α)` fails at `0`. This is the Zeno point named in the dispatch:
  an ω-sequence of splices converges to a time at which the limit state is unconstrained. `LC_n`
  survives because its consequent is an implication and is vacuous beyond the constructed part.
- **Located open question.** Over dense time, which until-form principle is valid and strong
  enough? A multi-index until-form fails even over ℤ (a non-marker `⟐αⱼ`-point inside a
  `β_k`-stretch has no witness). Whether `LC_n` alone suffices for a language with `U`/`S` at
  Dense/RTime is OPEN; Reynolds 2003's language has F/P only, so the held source is silent.

### 3. Q3: rules and language extensions

#### 3.1 The naming rules are sound (compiled over ℤ)

- `clockR` on `W × ℤ` advances an integer clock on every step; `clock_twoWay` shows the projection
  is a two-way bounded morphism; `clock_eq` shows the clock along any walk is time plus a constant.
- `clock_irr_sound`. Let `nm q := q ∧ H¬q ∧ G¬q`, `once q := nm q ∨ P(nm q) ∨ F(nm q)`,
  `rigid q := (Fq → ⊡Fq) ∧ (Pq → ⊡Pq)` and `clockAnte q := q ∧ □A(once q ∧ rigid q)`. If
  `clockAnte q → φ` is valid on all doubly serial all-walks models and `q` does not occur in `φ`,
  then `φ` is valid on all of them. Proof: go to the clock product, make `q` true exactly at clock
  value `0`, apply the premise, forget `q` (`T_fresh`), project (`tw_invariance`).
- `irr_sound`: the same for Gabbay's antecedent `q ∧ H¬q`, as a corollary.
- **Why this does not contradict established point (e).** 535's antecedent contained `□H¬q` and
  `□G¬q`, which shift-closure refutes. In the clock model `□` still sees histories on which `q`
  holds at other times; what is true is that every history has `q` exactly once and that histories
  sharing a state at a time agree on when. That is the content of `once` and `rigid`.
- The clock rule is also sound for paste- and shift-closed bundles (the clock product of a bundle
  is again one, and lifts are unique), so it does not derive any `LC_n`. Rules and LC are
  independent ingredients, as in Reynolds 2003.

#### 3.2 The clock product at every class (paper)

For a frame `F` over `D`, let `F × D` have states `(w, d)` and `(w,d) ⇒_x (v,e)` iff `w ⇒_x v`
and `e = d + x`.

- Compositionality and Seriality are inherited.
- Limit: if `(v,e)` lies in every cone of `(w,d)` then `v = w` by Limit in `F`, and
  `|e - d| < x` for every `x > 0` forces `e = d`.
- Saturation: two members of a directed family with different clock coordinates are disjoint, so
  all members share one; project to `F`.
- Total histories of `F × D` are pairs (history of `F`, clock offset), with unique lifts, so no
  Extension Theorem is needed for invariance, and no history revisits a state.

Hence both naming rules are sound at Base, Dense, ZTime and RTime. Cost for `PlusDerivationTree`:
one constructor with side conditions "`q` fresh" and "empty context"; one soundness arm, which
needs the clock product as a `FrameOver` construction plus `PlusTruthAt` invariance under the
projection (estimated 300-400 lines, no choice principles). Conservativity over TM: the forward
direction is soundness plus TM completeness, so it survives any sound extension; the backward
direction is untouched.

#### 3.3 The Auxiliary Atoms rule transfers at ZTime (semantic core compiled)

- `coneR` on `W ⊕ (W × List W)`: `inl` is a verbatim copy; `inr (v, h)` is a copy of `v` reached
  along the recorded path `h`. `inl u → inr (v, h)` whenever `u → v`, so every copy keeps all its
  predecessors; `inr (u,h) → inr (v,h')` iff `u → v` and `h' = u :: h`; nothing leaves `inr`.
- `cone_twoWay` (compiled, no axioms): the projection is a surjective two-way bounded morphism.
- `aa_expand` (compiled): for any machine `p : Q → I → Q`, start state `b₀` and index map
  `idx : W → I`, there are a lift `σ'` of the given walk and a labelling `st` with `st = b₀` now
  and, on every history through the current state, at every time from now on, every history
  through the state reached moving to `p (st ·) (idx ·)`. This is the semantic content of
  `θ⊡ := b₀ ∧ ⊡G≤ ⋀((b ∧ aᵢ) → ⊡X p(b,i))`; the exclusivity conjunct is immediate because `st` is
  a function.
- The formula-level rule (with the `aᵢ` state-local, pairwise inconsistent and exhaustive, and
  `idx` read off them via `tw_invariance`) is UNVERIFIED as a compiled statement. A mirror-image
  rule for the past holds by the symmetric construction. The construction is discrete-step and has
  no analogue at Dense or RTime.

#### 3.4 Language extensions and rule-free routes

- Naming does not force a language extension. The L⋆ registers, state nominals or a difference
  operator remain options for *expressing* colour-level bans as axioms, but none is needed for
  soundness of the rules above. They were not assessed further this round.
- Rule-free routes: the held sources say only that Zanardo's bundled axiomatization has "a
  complicated axiom … which provides an alternative to using the IRR rule" and proceeds "step by
  step" (Reynolds 2002 §8, 2003 §4). Di Maio-Zanardo is not held. No verdict.

### 4. Q4: the engine

| Candidate | Frame axioms at risk | Unintended histories | Reuse | Verdict |
|---|---|---|---|---|
| (i) Reynolds-2001 finite-closure construction, ZTime | none (1.2; or finite `W`) | emergent walks of the final digraph; excluded by AA-recorded automaton plus banning | nothing from the k-equivalence engine, which is linear-only; closure and MCS infrastructure only | **recommended first**; located obstruction below |
| (ii) Burgess-Xu chronicles building frame and histories together | Saturation for infinite `W` at Base/Dense; Limit over dense time | limits of splices; over dense time also histories switching at densely many times | chronicle machinery, the Base three-way split | only with `LC_n` + IRR in the style of Reynolds 2003, whose proof is a sketch |
| (iii) T×W / Kamp-frame style | same as (ii) | same | none landed | structurally closest, but the literature completeness results are for *bundled* validity, a different semantics |
| (iv) mosaics / quasimodels | none at ZTime | must encode limit closure in the quasimodel's run condition | none | a decision procedure rather than an axiomatic engine; pairs with 1.3 |

**Structural note for (iii).** The `(history, time)` pairs of a task frame, with `(τ,t) ≈ (ρ,t)` iff
`τ(t) = ρ(t)`, form a Kamp-frame-like grid *without* the shared-past condition (Reynolds 2002 §8,
condition 3), and with two-sided splice closure, shift closure and limit closure instead. No held
source treats that class.

**The located obstruction for (i).** Reynolds' automaton is deterministic, reads an ω-word from the
root, and AA records its state at tree nodes (2001 §7, Lemma 6; 2002 §9.1). Here:

1. there is no root, and formulas contain `S`, so a bad emergent history can be bad because of its
   past;
2. emergent histories arise as limits of splices forwards and backwards;
3. `aa_expand` gives a machine run from the *current point forwards*, and its mirror image one
   backwards; nothing gives a single run along a bi-infinite walk.

A proof would need a two-sided decomposition (separation of each closure formula into pure-past and
pure-future parts with `⊡`/`□` leaves, which holds over ℤ: recalled) and two automata anchored at a
named time, which is what the clock rule supplies. This is a research programme, not a transcription.

### 5. Q5: class order and transfer

1. **ZTime first.** Decidable (1.3), Saturation idle (1.2), all ingredients sound with compiled
   cores (§2, §3), and the only held blueprint with a full proof (Reynolds 2001).
2. **Base second.** `LC_n` and the naming rules are sound there; the blueprint is Reynolds 2003's
   sketch; the mixed-case elimination must be re-verified for `PlusFormula`. ZTime gives Base the
   finite-label and banning technique and nothing about Saturation.
3. **Dense and RTime last.** The until-form principle is unknown (2.3), AA has no analogue (3.3),
   and r.e.-ness is open (1.4).

### 6. Q6: baselines

| Baseline | `LC_n` | clock rule / IRR | AA⊡ (ZTime) |
|---|---|---|---|
| Soundness, one lemma per constructor | ZTime compiled in the mirror; Base paper (Zorn + `extension`) | ZTime compiled in the mirror; all classes paper (3.2) | semantic core compiled; formula level UNVERIFIED |
| Collapse under *Determined* | with `⊡ = id` the instance is `χ → χ` | admissible by the deterministic completeness of task 537 plus soundness on deterministic frames (the clock product of a deterministic frame is deterministic) | same |
| Conservativity over TM, forward | soundness + TM completeness | same | same |
| Conservativity over TM, backward | unaffected (axioms are only added) | unaffected | unaffected |
| Coarsened-model independence proofs (560) | `IsNaive := False`; refuted in `evFalse` (2.2) | sound on paste- and shift-closed bundles, so existing non-derivability proofs survive with one new arm | not examined |

### Per-class table

| Class | Candidate system | Soundness | Completeness | Engine |
|---|---|---|---|---|
| **ZTime** | TM⁺ + `LC_n` + `LCU` + clock rule + AA⊡ and its mirror image | semantic cores compiled in the mirror; against `PlusTruthAt` not yet | CONJECTURED; validities decidable (paper) | Reynolds-2001 style, new; obstruction: two-sided automaton |
| **Base** | TM⁺ + `LC_n` + clock rule | `LC_n` paper; clock rule paper | OPEN; r.e.-ness open | Reynolds-2003 style over chronicles; blueprint is a sketch |
| **Dense** | TM⁺ + `LC_n` + clock rule + an unknown until-form principle | as Base; `LCU` invalid (sketch) | OPEN | none |
| **RTime** | as Dense | as Dense | OPEN; MSO route blocked (recalled) | none; Doets route is linear-only |

### Recommendations

1. **Task 560: keep report 02's rescope**,
   `plus_incomplete_base : PlusValid blc ∧ ¬ PlusDerivable FrameClass.Base [] blc`, ZTime as a
   corollary. One refinement: state the validity half through a general lemma "a maximal
   non-erring partial history exists" so that it also yields `LC_n` at Base (2.2) at no extra cost.
2. **Follow-on task A (lean4, implementable now, sorry-free target):** frame morphisms and the
   clock product. Deliverables: `FrameOver` clock product with its four axioms; `PlusTruthAt`
   invariance under the projection; validity preservation of the clock rule at every class. No new
   constructor yet.
3. **Follow-on task B (research, this task's next round with `--research --lit`):** the ZTime
   engine. Read Reynolds 2001 §9-§15 in full against the obstruction of §4; write out the oriented
   forest Saturation proof and the MSO translation of 1.3 as probes; decide the finite model
   property. Acquire first: Reynolds 2005 (PCTL*, past operators), Zanardo 1991 (bundled S/U),
   Di Maio-Zanardo 1998.
4. Do not add any constructor to `PlusAxiom` or `PlusDerivationTree` before task B reports: the
   right ZTime rule set is not settled, and each constructor costs an arm in every soundness and
   independence recursion.

## Decisions

1. The dispatch premise that state splitting is unsound is refined: two-way splitting is sound
   (compiled), past-splitting is not.
2. Established point (e) stands for 535's exact candidate and is refined: `⊡`-local naming of a
   time is sound at every class.
3. `LC_n` (implication form, all `n`) is the limit-closure schema of record for every class; `LCU`
   is ZTime-only.
4. ZTime is the first class for any positive attempt. No completeness theorem is stated anywhere.
5. No language extension is recommended at this point.
6. No `user_decision` is raised: report 02's rescope of 560 was made with the user and is unchanged.

## Risks & Mitigations

- **Risk**: the mirror departs from `PlusTruthAt`. **Mitigation**: clauses are verbatim from
  probes 01/02, whose faithfulness report 02 audited; every implementation task re-proves against
  the repository semantics.
- **Risk**: the oriented-forest Saturation proof (1.2) has a gap. **Mitigation**: it is five short
  steps against the literal definition; task B compiles it. Nothing else in this report depends on
  it except 1.3 and the "no Saturation obligation" remark.
- **Risk**: decidability (1.3) leans on a recalled theorem. **Mitigation**: labelled; the held
  Reynolds 2002 §6 confirms the method for the neighbouring tree logics.
- **Risk**: the clock product's Saturation argument (3.2) misses a case for segments.
  **Mitigation**: segments are intersections of two fibres, so the same clock-coordinate argument
  applies; task A compiles it.
- **Risk**: the Zeno counter-pattern to `LCU` (2.3) is only checked on the deterministic line,
  where `⊡ = id`. **Mitigation**: that already refutes validity at Dense and RTime, since
  deterministic frames belong to those classes; a nondeterministic version is not needed for the
  verdict "invalid".

## Tactic Survey Results

| Goal | Tactic | Result | Premises/Config |
|------|--------|--------|-----------------|
| lift sequences by choice | `if h : ∃ … then h.choose else …` by structural recursion, then `dif_pos` | success | `open Classical in` on the `def` |
| casts `t + ↑(k+1) = t + ↑k + 1` | `push_cast; ring` | success | — |
| `Int.toNat` index arithmetic in `lift_walk`, `omega_limit` | `omega` | success | handles `toNat` directly |
| transporting `T … (f ∘ ρ') …` to `T … ρ …` | `funext hf ▸ h` | success | `rw` not needed |
| dependent chain of stages | `Nat.rec (motive := …)` over a `structure` with `Prop` fields, `Classical.choose` on a step lemma | success | — |
| residues: `(i₀ + k) % n = (j+1) % n` | explicit `k := j+1+m+N*n`, `ring`, `Nat.add_mul_mod_self_left` | success | `omega` cannot see `N*n` |
| `(a % n + 1) % n = (a+1) % n` | `Nat.mod_add_mod` | success | — |
| clock arithmetic | `clock_eq` + `omega` | success | — |
| case analysis on `Sum` relation | `rintro (u | x) (v | y) h`, `rcases hv : η' _ with v | y` | success | — |

## Context Extension Recommendations

- **Topic**: model transformations for the all-histories semantics. **Gap**: no context note or
  module says that two-way bounded morphisms preserve `PlusTruthAt`, that the clock product
  preserves the four frame axioms, or that Saturation is idle at ZTime. **Recommendation**: a
  section in the README of whatever module follow-on task A creates, and a cross-reference from
  `Metalogic/Independence/README.md` next to the notes proposed in reports 01 and 02.

## Appendix

- Probe 03 index (`probes/03_morphisms-clock-rule-lc-schema.lean`):
  - Clauses: `neg_iff`, `and_iff`, `or_iff`, `dstab_iff`, `someFuture_iff`, `somePast_iff`,
    `allFuture_iff`, `allPast_iff`, `gle_iff`, `always_iff`; `IsWalk`, `fullModel`, `DS`, `paste`,
    `paste_walk`
  - H: `TwoWay`, `fwdSeq`, `bwdSeq`, `fwdSeq_spec`, `bwdSeq_spec`, `liftFn`, `lift_walk`,
    `tw_invariance`
  - K: `Fm.fresh`, `T_fresh`, `clockR`, `clock_twoWay`, `clock_DS`, `clock_add`, `clock_eq`, `nm`,
    `once`, `rigid`, `clockAnte`, `clock_irr_sound`, `irr_sound`
  - J: `coneR`, `coneF`, `cone_twoWay`, `coneF_surjective`, `run`, `coneSt`, `aa_expand`
  - I: `c_mono`, `c_ge`, `agree_add`, `omega_limit`, `Stg`, `stg_step`, `omega_chain`, `bigAnd`,
    `bigAnd_iff`, `lcAnte`, `lcCons`, `lcN`, `lcN_valid_full`
- `#print axioms` (scratch copy): `tw_invariance`, `clock_irr_sound`, `omega_chain`,
  `lcN_valid_full`, `aa_expand`: `propext`, `Classical.choice`, `Quot.sound` only. `cone_twoWay`:
  no axioms.
- Compile command: bare `lean` from `~/.elan/toolchains/leanprover--lean4---v4.33.0-rc1`, with
  `LEAN_PATH` set to `.lake/packages/*/.lake/build/lib/lean`. Exit 0, no warnings, about 13 s.
- Not compiled anywhere: 1.2 (oriented forests), 1.3, the Base validity of `LC_n`, 3.2 at general
  `D`, the formula-level AA⊡ rule, the formula-level `LCU`, the dense refutation of `LCU`.
- Literature locators: Reynolds 2003 chunks 0006-0008 (system), 0011-0014 (LC and Lemma 3),
  0015-0024 (sketch); Reynolds 2002 §6, §8, §9.1; Reynolds 2001
  `sec03_*.md` lines 236-346.

## Literature Proof Structure

**Source**: Reynolds 2003, Lemma 3 (LC is sound), and Reynolds 2001 §7, Lemma 6 (AA is sound).
**Strategy**: transfinite (here: Zorn) construction of a linearly ordered set of points cycling
through the indices, extended to a history; and recursion from a root along branches.

### Step Map
1. Observation: from a `◇αᵢ`-point above `t` on some history, the antecedent gives a later
   `◇α_{i+1}`-point -- Reynolds 2003, proof of Lemma 3. Lean: hypothesis `H` of `omega_chain`.
2. Cycle through the indices, building an increasing sequence -- ibid. Lean: `stg_step`, `chain`.
3. At limit stages continue if some `◇αᵢ`-point lies above everything built, else stop -- ibid.
   Lean: over ℤ one ω-sequence suffices (`omega_limit`); at Base, Zorn over partial histories
   (paper, 2.2).
4. The set built is linearly ordered, so it extends to a history -- ibid. Lean: over ℤ the limit is
   already total; at Base this is `extension`, and it is the one place Saturation is used.
5. Beyond the set built no `◇αᵢ` holds, so the implication is vacuous there -- ibid. Lean: the
   maximality step of 2.2.
6. AA: define the `Q`-atoms by recursion on finite prefixes from the root -- Reynolds 2001 Lemma 6.
   Lean: `run` along the recorded path in `coneR`; `aa_expand`.

### Dependencies
- Step 3 depends on 1 and 2; step 5 depends on 3 and 4; step 6 is independent and depends on
  `cone_twoWay` + `tw_invariance` to keep the old language's truths.

### Potential Formalization Challenges
- Step 3 at Base: the `Q`-poset over the `PartialHistory` API and its chain closure.
- Step 4 on a tree is trivial (a linearly ordered set of tree points lies on a branch); on a task
  frame it is the Extension Theorem. This is where the transposition is not a transcription.
- Step 6 has a root in the source and none here; the cone construction supplies a local root at the
  evaluation point, forwards only.
