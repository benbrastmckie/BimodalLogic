# Research Report: Ranked Route Analysis for Decidability of Full L⁺

- **Task**: 718 - Omega sequence decidability full lplus
- **Started**: 2026-10-02T23:11:00Z
- **Completed**: 2026-10-02T23:59:00Z
- **Effort**: ~1 research round (one dispatch), including one compiled probe
- **Dependencies**: Consumes the sliced-class incompleteness record, the L⁺ finite-model-property
  record, and `reports/01_gluing-route-seed.md` (the author-written seed, treated as checked premises)
- **Sources/Inputs**:
  - Landed tree: `FormalSystem/Semantics/{PartialHistory,TaskFrame,IntNormalForm,SlicedFrame,Extension}.lean`,
    `FormalSystem/PlusLanguage/{PlusPasting,PlusTruth,PlusValidity}.lean`,
    `FormalSystem/Metalogic/Decidability/{README.md,FMP/README.md,BiLasso/}`
  - Landed probes: `specs/706_.../probes/NoFiniteCarrierModel.lean`, `specs/710_.../probes/NoFiniteWidthModel.lean`
  - New probe (this round): `specs/718_.../probes/SeamFibreProduct.lean`
  - Paper (clean working tree): `~/Philosophy/Papers/PossibleWorlds/JPL/{possible_worlds,metalogic}.tex`
  - Literature corpus `~/Projects/Literature/`: Piterman 2007, Löding–Pirogov 2019, Reynolds 2001,
    Hodkinson–Reynolds 2006 (Handbook ch. 11), Hodkinson–Wolter–Zakharyaschev 2000, GKWZ 2003 ch. 11,
    Rabinovich 2014, Doets 1987/1989, `SOURCES.md` D8/D9
- **Artifacts**:
  - `specs/718_omega_sequence_decidability_full_lplus/reports/02_ranked-route-analysis.md`
  - `specs/718_omega_sequence_decidability_full_lplus/probes/SeamFibreProduct.lean`
- **Standards**: report-format.md, status-markers.md, artifact-management.md, subagent-return.md
- **Task Type**: formal:logic

## Executive Summary

- **The keystone is PROVED, not refuted.** The `⊡` quantification domain is exactly the fibre
  product of the past-ray and future-ray spaces over the seam state. Machine-checked this round at
  a **general task frame, any duration** (`Probe718.seamFibreEquiv`), and in **ω-sequence form over
  ℤ** (`Probe718.seamOmegaEquiv`), with the two `⊡`-clause restatements
  (`plusStab_iff_rays`, `plusStab_iff_omega`). Sorry-free; axioms `[propext, Classical.choice,
  Quot.sound]`. Every downstream route in this round may now assume it.
- **The ray layer's definitional question is settled, and the Saturation trap is avoidable.** Rays
  are definable directly (a `PartialHistory`-shaped half-line domain), and gluing two of them is
  `app:gluing`'s **binary** case with overlap `{t}` — *Compositionality* plus the reflection
  convention and nothing else. The directed-colimit presentation (hence Saturation, hence the
  paper's `D = ℚ` counterexample) is an artefact of building rays out of bounded sections and is
  **not forced**. The warning in the task description was correct as a warning and is now discharged.
- **Much of this is already landed and was not credited.** `FormalSystem/PlusLanguage/PlusPasting.lean`
  already implements the paper's `⌢_z` as `paste`, at the general frame, choice-free, and its own
  header already asserts the product claim in prose — what it proves is *closure*, not the
  bijection. This round supplies the bijection the prose asserted.
- **Verdict on the primary direction: the ω move is a DECOMPOSITION, not a re-basing — and that is
  the good news.** Re-basing validity on forward-only ω-histories changes the logic (an initial
  time makes `¬P⊤` satisfiable, which is ℤ-unsatisfiable), so it cannot be a conservative transfer
  and there is no ω-analogue of `plusValidZTime_iff_plusValidInt` to be had on those terms. What
  survives, and is what the author actually wants, is ℤ-histories *presented* as pairs of
  ω-sequences through a seam. The backward factor is retained, not deleted; the two-sidedness of
  the landed refutations is thereby **located** (it lives in the backward factor) rather than removed.
- **Ranked routes.** R1 **seam-gluing + ω-automata determinization over the ray product** (one
  route, as predicted) — the only route that evades `not_finite_width_fmp` by its only open move,
  conceding infinite fibres and seeking a finite presentation; external precedent exists
  (monodic-FOTL quasimodels, whose "runs" are exactly infinite fibres over finitely many types).
  R2 **mosaics / quasimodels** — gluing-native, same precedent, cheaper substrate, weaker reach.
  R3 **periodicity/Ramsey (F4)** — demoted to a *component* of R1, not a route. R4
  **task-coherence-preserving filtration** (the paper's own open problem) — **CLOSED for ℤ-time**:
  finite carrier ⟹ finite width, and `Probe706.no_finite_carrier_sat` already refutes it as a
  theorem, on the `⊡`-free fragment. R5 **translation to a decidable first-order fragment** —
  assessed and rated low.
- **Two paper-drift findings.** (i) The paper's `metalogic.tex` FMP subsection records FMP for
  **TM** as fully open and names filtration as the technique; this repository holds a machine-checked
  refutation for the ℤ-time case, on a `⊡`-free witness. (ii) The paper's claim about this
  repository ("implements a decision procedure for TM whose soundness is verified, though no
  decidability theorem for TM is machine-checked at present") is **accurate as of this reading**.
  The `SU` → `US` rename is real; the Lean library already spells it `US`, and only
  `docs/reference/paper-definitions-of-record.md` is behind.

## Context & Scope

Route-selection round for decidability of **full** L⁺ (`⊡` in the language), over **full possible
worlds** — not a fragment, not a restricted frame class, not the stab-free flagship. The round
selects and falsifies routes and lands probes; it implements no decision procedure. Five closed
results ((a)–(e) of the task description) are taken as given and are not re-certified; each
surviving route below states the mechanism by which it evades those that bear on it.

Scope boundaries respected: the F4 periodicity proof work is consumed, not duplicated; the
settled sliced-class incompleteness question is not reopened; soundness
(`plusTruth_iff_mem`, `plusRefutes_of_certifies`) is untouched; no width, tail-period or complexity
bound is committed; the presheaf-front tasks' territory (563–567, 616–618) is consumed, not re-filed.
No file under `~/Philosophy/Papers/PossibleWorlds/` was written, and no task was created there.

## Findings

### F1. The keystone: the `⊡` fibre is the fibre product [PROVED]

`specs/718_omega_sequence_decidability_full_lplus/probes/SeamFibreProduct.lean`, compiled clean
(no errors, no warnings, no `sorry`), axioms `[propext, Classical.choice, Quot.sound]` on all four
headline declarations.

- `Probe718.PastRay F t` / `FutRay F t` — convex histories on `(-∞, t]` and `[t, ∞)`, as dependent
  functions on the time subtypes (so ray equality is funext).
- `Probe718.glue` — the seam gluing; total by construction.
- `Probe718.seamFibreEquiv : StabFibre F t s ≃ RayPair F t s` — **at a general task frame, any
  duration**: the set of possible worlds in state `s` at time `t` (verbatim `PlusTruth.stab_iff`'s
  quantification domain) is equivalent to `{(b, f) // b.seam = s ∧ f.seam = s}`, the fibre product
  over the seam.
- `Probe718.plusStab_iff_rays` — `⊡φ` at `(τ, t)` iff `φ` holds at every seam gluing through
  `τ.state t`.
- `Probe718.seamOmegaEquiv : StabFibre F.toTaskFrame t s ≃ SeqPair F s` — over a regular ℤ-frame,
  the same fibre is equivalent to pairs of **ω-indexed step sequences** out of `s` (one backward,
  one forward), via `pathFibreEquiv` (through the landed `FrameOver.mem_HF_iff_adjacent` /
  `worldHistoryOfStepPath`) composed with `omegaSplitEquiv`.
- `Probe718.plusStab_iff_omega` — `⊡` as a quantifier over pairs of ω-sequences.

What the proof uses: the ray task-constraints, `TaskFrame.comp` (*Compositionality*),
`FrameOver.reflection`, `WorldHistory.ofTotal`, `WorldHistory.ext_state`. It cites **no** Zorn, no
Extension Theorem, no *Saturation*, no frame-class hypothesis. The `Classical.choice` in the axiom
triple is the repository's standard baseline (it enters via ambient decidability of `≤` in the case
split and via Mathlib infrastructure), not via a choice-dependent construction step; this is a
by-inspection claim about the proof term, not a mechanically separated dependency.

**What F1 does not do.** It bounds nothing and evades nothing. It is the *mechanism* behind
`not_finite_width_fmp`: a fibre that is a product of two path spaces cannot be finite unless both
factors are, so finite per-time fibres were never going to be complete. F1 explains the refutation;
it does not escape it. The task description's caution is upheld verbatim — "all ways" is the
largest choice, and this route concedes infinite fibres.

### F2. The ray layer: definable directly; the binary/directed split resolved [SETTLED]

The task description called this "the single most important unanswered definitional question".
Answer, with evidence:

- `PartialHistory.domain` is an arbitrary predicate on `F.Duration`
  (`FormalSystem/Semantics/PartialHistory.lean:136-138`), so a ray domain needs no new type. The
  probe's subtype-indexed presentation is the same content with funext-friendly equality; either is
  acceptable, and **no new primitive is warranted**.
- Gluing a past ray to a future ray is `app:gluing` with `X₁ = (-∞, t]`, `X₂ = [t, ∞)`,
  `X₁ ∩ X₂ = {t}` — the **binary** case. The paper's own proof of `app:gluing`
  (`JPL/possible_worlds.tex`, label `app:gluing`, LIVE) uses only convexity and *Compositionality*;
  its footnote's *Saturation* dependency and its `D = ℚ`, `W = {q ∈ ℚ : q > 0}` counterexample
  attach to the **upward directed** case, routed through `thm:extension`.
- Therefore: the directed/`Saturation` hazard is real but **avoidable**, and is incurred only by
  presenting the ray as a colimit of bounded sections `Beh F l`. Totality of the glued object comes
  from the seam construction, not from `thm:extension`.
- Corollary for the effective-extension question (task 719's Deliverable 4): the binary seam gluing
  **does** supply a choice-free construction of a total history from one-sided data, where
  `FormalSystem/Semantics/Extension.lean` uses Zorn plus `Classical.choice`, and where
  `BiLasso/Orbit.lean` had to build a bi-lasso-only "Tier A" effective version. The generalisation
  is reachable along exactly this path. Note the limit of the claim: it produces a total history
  from a *pair of rays*, not from an *arbitrary partial history*, so it generalises Tier A's role
  without subsuming `thm:extension` itself.

### F3. The seam gluing is already landed, and the product claim was already asserted in prose

`FormalSystem/PlusLanguage/PlusPasting.lean` — read in full:

- `pasteFun`, `paste_rel_le_lt`, `paste_rel`, `paste` implement the paper's `⌢_z` **at the general
  task frame**, with the module header stating: "using only *Compositionality* (`TaskFrame.comp`)
  across `t` and the converse convention (`TaskFrame.reflection`) for the reverse orientation — no
  *Saturation*, no extension theorem, no frame-class assumption."
- The same header already asserts the keystone in prose: "the total histories through a world state
  are the **product of its possible pasts and its possible futures**". What the file *proves* is
  closure (`paste` is a world history) plus the two agreement lemmas — not the bijection. F1 is the
  upgrade from the prose assertion to an `Equiv`.
- `paste_valid` / `untl_dstab_valid` are the Lean counterparts of the paper's own (commented-out)
  soundness arguments for **PS** and **US**, which the paper derives *by* `⌢_z`.

Consequence for the paper's formalization claim: the paper says `app:gluing` "is not yet among"
the formalized results — correct for `app:gluing` in its general convex-domain form. But the seam
corollary the paper actually uses (the commented-out pasting-principles passage) **is** formalized,
and choice-free. That is worth knowing before task 564 or 719 is budgeted.

### F4. The ω-sequence move: what it is, and what it is not [VERDICT]

- **As a re-basing of validity, it fails, and the failure is cheap to see.** With forward-only
  ω-histories there is an initial time; `snce` at time 0 is vacuous, so `¬P⊤` (equivalently `H⊥`) is
  satisfiable at `(σ, 0)` while being unsatisfiable over ℤ-time at every point. ω-validity and
  ℤ-validity therefore differ, and there is no ω-analogue of
  `FormalSystem.PlusLanguage.plusValidZTime_iff_plusValidInt` of the shape "same validities". A
  faithful ω-time transfer would have to quantify away the origin (evaluate only at points with
  unbounded past), which re-introduces the backward factor — i.e. returns to F1.
  Status: **[DERIVED, argued, not machine-checked]** — formalizing it needs an ω-time semantics the
  tree does not have, which is a disproportionate cost for a result whose content is this clear.
  Recorded here as the reason **not** to build that semantics.
- **As a decomposition, it is exactly right, and is now a theorem** (`seamOmegaEquiv`): a ℤ-history
  through a seam *is* a pair of ω-sequences. This is the classical bi-infinite-word ↔ pair-of-ω-words
  move, and it is what makes a deterministic automaton per factor available.
- **On two-sidedness of the landed refutations**: the obstruction is *located*, not removed. Reading
  `specs/710_.../probes/NoFiniteWidthModel.lean`'s negative half, the contradiction needs `p`-states
  at **unboundedly early** times (ancestors of a `p`-state are all *pre*, each *pre* state has a
  `p`-successor), then pigeonholes backward *post*-chains of every length into a single finite
  time-slice. With a least time that chain-length argument has a trivial bound and does not run.
  So the finite-width obstruction as *stated* is genuinely two-sided. This does **not** rescue
  finite width for the real target: the real target is ℤ-time validity, where the refutation
  stands, and the forward-only setting where it fails is the setting whose validities are the wrong
  ones (previous bullet). This is the negative result the task asked to be recorded, and it is
  recorded as an argued finding about an existing machine-checked proof rather than as a new
  theorem, because the theorem it would be stated against (ω-time validity) is one this round
  recommends not introducing.

### F5. Filtration (the paper's own open problem) is CLOSED for ℤ-time [REFUTED, theorem in hand]

- The paper (`JPL/metalogic.tex`, "Finite Model Property") records FMP for **TM** as "an important
  open question", notes FMP would give decidability by exhaustive search over finite models, names
  **filtration** as the standard technique, and names the obstacle: the quotient must preserve
  task-coherence (*Nullity*, *Compositionality*).
- `specs/706_.../probes/NoFiniteCarrierModel.lean` proves `no_finite_carrier_sat`: **no** regular
  ℤ-frame with `Finite WorldState` carrier satisfies `θ := □(p ∨ Fp ∨ Pp) ∧ □(p → ¬Pp)` at any
  history and time, while `not_plusValidZTime_neg_θ` shows `θ` is ℤ-satisfiable. And
  `θ_eq_ofFormula` shows `θ` is **`⊡`-free** — it is the embedding of an L (TM-language) formula.
  Hence TM itself lacks the finite model property over the ℤ-time frame class, machine-checked.
- Independently, `FormalSystem/Metalogic/Decidability/FMP/README.md` states that the existing
  `FMP/` directory is **not** a semantic FMP: its relation is the *permissive* one
  (`fun w d u => if d = 0 then w = u else True`), it contains zero occurrences of `TruthAt`, and a
  truth lemma on that frame is *false*; what remains open there is precisely "build a genuine
  filtered task relation and re-discharge the four axioms". F5 says that open item is
  **unachievable over ℤ with a finite carrier** — a finite carrier gives finite per-time fibres, so
  finite carrier is a special case of the already-refuted finite width.
- Precise limits of the refutation, stated so the report cannot be over-read: it is over **ℤ**
  (discrete) frames. `PlusValid` (all frames) is stronger than `PlusValidZTime`, and whether `θ`
  has a finite-carrier model over a *dense* duration is untouched by the probe — the pumping
  argument needs discreteness. So the paper's question, read over its full frame class, is narrowed
  rather than fully answered; read over discrete time — the programme's actual target, and the
  setting of every decidability asset in the tree — it is answered **negatively**.
- **Obstruction recorded as a theorem**: `Probe706.no_finite_carrier_sat` /
  `not_finite_carrier_fmp`, plus `Probe710.not_finite_width_fmp` for the stronger statement. No new
  theorem is needed for this route and none should be written; what *is* warranted is promoting
  these two probes into the library, which no task currently owns (see Recommendations).

### F6. The ranked routes

Each route states: class/basis · what it must prove · which closed result bears on it and the
evasion mechanism · leverage · obstruction and severity · probe-first falsification plan.

#### R1 — Seam-gluing ray product + ω-automata determinization [RANK 1; the only live route]

- **Basis**: the fibre product of F1, with each factor presented as the root-path space of a finite
  class graph. The class presents (i) a finite graph of state-classes, (ii) per class a finite
  automaton summary for each `⊡`/temporal subformula, read along backward and forward runs. `⊡`'s
  check is `plusStab_iff_omega`'s quantifier, summarised by the two automata.
- **Must prove**: completeness of the class for ℤ-time non-validity of L⁺, and decidability of the
  check. Equivalently: that the pair-of-runs quantification has a finite deterministic summary
  sound and complete for each `⊡`-subformula.
- **Closed results that bear, and the evasion**: (a) and (b) presented single lassos / finite
  graphs and are evaded by presenting *path sets* rather than paths; (c) and (d) are evaded only by
  **conceding infinite fibres** — the class's per-time fibre is a full product of two path spaces,
  so the finite-fibre hypothesis of `not_finite_width_fmp` is simply not met. (e) is not restated
  in any form: no tail-stable re-presentation is claimed anywhere in this route.
- **Leverage**: F1 and F2 give the semantic side for free and choice-free. `mem_HF_iff_adjacent`
  gives the ℤ path identification. Task 618's identification of `Path(F)` as the free category on
  `(W, ⇒₁)` over ℤ is literally the "root paths of a finite class graph" presentation. Determinized
  automata are the only known mechanism for summarising "all runs" finitely, and the literature is
  in hand (Piterman 2007 LMCS; Löding–Pirogov 2019; Reynolds 2001 for the CTL\* route this mirrors).
- **External precedent — and a correction to the record**: the refutation record said a
  successor class with infinite fibres has "no checker precedent". That is right *within this
  programme*, but **not** in the literature: the monodic-FOTL decision procedures decide
  satisfiability via **quasimodels** whose elements are *runs* — ω-sequences of types — i.e. a class
  with infinite fibres finitely presented by finitely many types (GKWZ 2003 ch. 11, in corpus;
  Hodkinson–Wolter–Zakharyaschev 2000, in corpus). This materially lowers R1's novelty risk.
- **Obstruction and severity**: **HIGH, and concentrated in one place** — nested `⊡`. The alphabet
  the automaton reads must carry the truth values of `⊡`-subformulas, which are themselves defined
  by a quantification over the fibre. Outer-to-inner stratification by `⊡`-depth is the obvious
  fix and should be the first thing probed, since `⊡φ` depends on the present state alone
  (`PlusTruth.stab_state_only`, landed) — which is exactly what makes stratification plausible.
  Secondary: formalization cost. Per `~/Projects/Literature/SOURCES.md` D8, **no formalization of
  Safra or Piterman determinization exists in any proof assistant**, so task 711's substrate is a
  from-scratch mechanization with no prior art.
- **Complexity sanity check**: the CTL\* 2EXPTIME-hardness reduction (filed, argued in both
  directions) is the lower bound; determinization-based upper bounds are doubly exponential, which
  is consistent. Any proposal cheaper than 2EXPTIME is prima facie wrong. **No bound committed.**
- **Probe-first falsification plan** (in dependency order, each cheap relative to the route):
  1. **Stratification probe.** For `⊡`-depth-1 formulas, show the fibre quantification depends only
     on the seam state and the two run-sets, and that `stab_state_only` lifts to a per-class summary.
     Falsifier: a depth-2 formula whose `⊡`-value at a class is not a function of the class's
     automaton state.
  2. **Finite-summary probe.** On a finite step-graph, decide `⊡φ` for `φ` a single temporal
     operator over state formulas, by reachability only (no determinization). If this already fails,
     R1 is dead and the obstruction is not determinization but the quantifier shape.
  3. **Determinization-necessity probe.** Exhibit a `φ` for which nondeterministic Büchi summaries
     give the wrong answer under complementation — i.e. show determinization is genuinely required
     before paying for it (this is what would revive task 711 on evidence rather than on expectation).

#### R2 — Mosaics / quasimodels [RANK 2; cheaper, weaker reach]

- **Basis**: finitely many finite "mosaics" (labelled interval pieces) plus an amalgamation
  condition; satisfiability iff a saturated mosaic set exists. The sheaf formulation is the natural
  home: `app:gluing`'s unique gluing at a shared endpoint **is** the amalgamation condition, so a
  mosaic method over this semantics is gluing-native rather than bolted on.
- **Must prove**: a mosaic-existence theorem for L⁺ with `⊡`, and decidability of saturation.
- **Evasion**: same as R1 — the represented model is infinite and the fibres are infinite; only the
  mosaic *set* is finite. `not_finite_width_fmp` does not apply to a presentation that never claims
  finite fibres.
- **Leverage**: no determinization substrate needed (the main cost of R1); same quasimodel
  precedent; and it reuses F1/F2 directly, since a mosaic for this semantics is a bounded convex
  history and gluing is already landed.
- **Obstruction and severity**: **MEDIUM-HIGH** — mosaic methods classically handle *linear-time*
  and first-order temporal logics; `⊡`'s branching quantification over the seam fibre is the part
  with no off-the-shelf mosaic treatment. Also an evidence gap: the acquired
  Hodkinson–Reynolds 2006 Handbook chapter has §5.10 Mosaics / §5.11 Monodic fragments **in its
  table of contents only** — the section bodies (pp. 708–712) are absent from the converted
  markdown. Ranking R2 above structural grounds requires that text.
- **Probe-first plan**: define a mosaic as a `Beh F l` section plus a Hintikka labelling; probe
  whether two mosaics agreeing at a germ always amalgamate (this is F1/`app:gluing` and should
  succeed), then probe whether `⊡`-saturation of a finite mosaic set is decidable. The second is
  where it will break if it breaks.

#### R3 — Periodicity / Ramsey (the re-scoped F4 statement) [RANK 3; a COMPONENT, not a route]

- **Verdict**: do not invest in F4 as a route. Invest in it, if at all, as R1's summary step.
- **Reasoning**: F4's premise is *finite width*, which `not_finite_width_fmp` has refuted for any
  complete class. A "finite width ⟹ eventually periodic" theorem is therefore a statement about a
  class that cannot be complete; it buys a bound inside a presentation, not a decision procedure.
- **What F1 contributes to it, positively**: F4's two stab-forced repairs to HWZ — that the
  quasistate must record the **one-sided** live sets, and that fulfilment must be secured for every
  live position at once by an idempotent Ramsey colour — are **explained** by the fibre product.
  One-sidedness is not a patch: the fibre *is* a product of two one-sided objects, so one-sided live
  sets are the only kind there are in the right presentation. If R1 goes the determinization way,
  the Ramsey colour is replaced by the automaton's acceptance condition and the repair becomes
  unnecessary; if R1 goes the Ramsey way, the repair is exactly right. Either way the F4 work is
  consumed by R1 and should be sequenced under it.

#### R4 — Task-coherence-preserving filtration [RANK 4; CLOSED for ℤ-time — see F5]

- Not a candidate for ℤ-time. Obstruction already a theorem (`Probe706.no_finite_carrier_sat`,
  `Probe710.not_finite_width_fmp`). The only live residue is the non-discrete frame classes, which
  are not the programme's target, and the paper-side correction in F5.

#### R5 — Translation into a decidable first-order fragment [RANK 5; assessed, low]

- The paper names this as the alternative if FMP fails. Assessment: the obvious translations put
  history quantification into the object language, and that is the undecidable direction — the paper
  itself cites Finkbeiner–Hahn for HyperLTL satisfiability undecidability, and `□`/`⊡` are
  *position-local* path quantifiers whose standard decidable treatment is automata-theoretic
  (Vardi–Wolper 1986, in corpus), not first-order. The monodic fragment (HWZ 2000, in corpus) is
  decidable but its decidability proof *is* the quasimodel/run method, i.e. it routes back into
  R1/R2 rather than offering an independent route. Keep as a write-up citation; do not fund.

### F7. Paper cross-checks (bidirectional) [VERIFIED against a clean working tree]

- `app:gluing` — **LIVE**, binary overlap, proof by convexity + *Compositionality*; footnote carries
  the directed/*Saturation* dependency and the `D = ℚ` counterexample. Bears on decidability:
  **yes**, it is R1's and R2's foundation.
- `thm:extension` — **LIVE**; footnote confirms Zorn, and itemises what is choice-free
  (`lem:nullity`'s zero loops, `cor:saturation-finite`). Bears: **indirectly** — it is what F2 shows
  the ray construction does *not* need.
- The **main-body** paragraph asserting the categorical repackaging (interval site, Johnstone
  coverage, twisted-arrow site, discrete Conduché fibrations, path category; citing Schultz–Spivak–
  Vasilakopoulou and Johnstone) is **LIVE, uncommented** — including the sentence "The upward
  directed form of gluing in the lemma's own footnote rests on *Saturation* by way of
  `thm:extension`". So the paper's standing prose commitment to the sheaf route survives the cut of
  `app:Structure` / `app:presheaf-dictionary`, exactly as the task description's own correction
  states. Cut status is deliberate author scoping and is **not** reported as a defect.
- The pasting-principles passage (`⌢_z`) — **COMMENTED OUT**; its restoration is an author decision
  and is not this round's to make. It is consumed here regardless (F3), and its hypothesis
  `ρ(z) = σ(z)` matches `StabClause.stab_clause`'s `τ.state t = σ.state t` on the nose.
- `app:deterministic` / `app:deterministic-future` — bear **negatively** on decidability with `⊡`:
  determinism collapses the fibre (`PlusDeterminism` already lands `⊡φ ↔ φ` on deterministic
  frames), so they characterise the degenerate case rather than help the general one. Useful as
  sanity fixtures for any new procedure, not as route material.
- `app:discrete` / `app:dense` / `app:complete` — frame-class correspondences; bear on which frame
  class a decidability claim is *about* (and hence on F5's limits), not on any route's mechanism.
  Their own footnote's *static* task frame is a cheap degenerate fixture worth reusing.
- `app:drift`, `app:abundant`, `app:unbounded`, `app:frame-impossible`, `app:expressive`,
  `app:TaskSemantics` — surveyed; **no bearing** on decidability with `⊡` found. Negative verdicts
  recorded as results.
- `metalogic.tex` canonical-model chain (`lem:lindenbaum` … `thm:TMd-completeness`) — bears on
  **completeness**, not decidability; the canonical model is infinite and uncountable, and the
  chain's `thm:canonical-nullity` / `thm:canonical-compositionality` are exactly the task-coherence
  conditions F5 shows a finite quotient cannot have over ℤ. Negative for routes, positive as the
  explanation of *why* R4 is closed.
- The paper's claim about this repository — **ACCURATE**. `FormalSystem/Metalogic/Decidability/README.md`
  confirms the sound direction is landed (`sound_of_isValid`, `isValid_sound`, `decide_sound`) and
  that the biconditional plus `Decidable (⊨ φ)` instances are not established
  ("`validity_decidable` … Retired as vacuous"). No drift to report in that direction.
- `SU` → `US` — confirmed: the paper now spells `US` in the `def:BX` schema list and the Burgess A3a
  footnote; `FormalSystem/PlusLanguage/PlusPasting.lean` already uses `US`;
  `docs/reference/paper-definitions-of-record.md` still says `SU` and is the only thing behind.
  Every axiom named in this report uses the paper's current spelling.

### F8. Reusable substrate and one flagged dependency

- Reusable as-is: `PlusPasting.{paste, AgreeFrom, AgreeUpTo, truth_congr_agreeFrom,
  truth_congr_agreeUpTo}`; `IntNormalForm.{step, iter, taskRel_eq_iter, mem_HF_iff_adjacent,
  worldHistoryOfStepPath}`; `Semantics/Periodicity.lean`; `BiLasso/`'s `back`/`mid`/`fwd` finite
  presentation as the single-path special case of R1's path-set presentation; `SlicedFrame.lean` for
  the finite-fibre frame synthesis (now known to be an incomplete *class*, still a valid *frame*
  construction).
- **Flagged dependency**: the `liveAt`/`liveT` non-termination defect on total-edge sliced
  certificates (filed as its own task; reproducer at
  `specs/704_.../probes/03_tier2_sliced_certificates.lean`) is a defect in **shipped, gated** code.
  Any route that reuses the sliced liveness fixpoint inherits it. R1 as specified does **not**
  reuse that fixpoint — it computes automaton summaries over run spaces, not a liveness fixpoint
  over a finite-fibre slice — so the defect is not on R1's critical path. If a later design does
  reuse it, this flag becomes a blocker.

## Decisions

1. **Keystone affirmed, not refuted.** The fibre-product characterisation is a theorem. Downstream
   routes may assume it. Recorded in two forms (general duration; ω over ℤ).
2. **Ray layer = direct definition, not a colimit.** No new primitive; binary seam gluing only;
   *Saturation* not incurred. The directed case stays with task 565 where it belongs.
3. **The ω move is adopted as a decomposition and rejected as a re-basing.** Do **not** build an
   ω-time semantics or chase an ω-analogue of `plusValidZTime_iff_plusValidInt` as a validity
   transfer; it cannot exist on those terms (F4), and the decomposition gives everything the route
   needed anyway.
4. **R1 and the infinite-fibre class are ranked as ONE route**, as the task description predicted.
5. **F4/periodicity is demoted from route to component** and sequenced under R1.
6. **Filtration is closed for ℤ-time**; its obstruction is an existing theorem and no new probe is
   written for it.
7. **Task 711 (ω-automata determinization substrate) should be revived as a real dependency of R1,
   but only after R1's probe 2 and probe 3 land** — determinization is the single most expensive
   item in the programme (no prior art in any proof assistant), and probe 3 is designed precisely to
   decide whether it is *necessary* before it is funded. This is a programme-level call and is
   surfaced as a user decision, not taken here.
8. **No tasks were created and `specs/state.json` was not written.** A sibling task is dispatching
   on this same working tree this cycle, and `state.json`/`TODO.md` are shared mutable files;
   creating tasks from inside this dispatch risks clobbering a concurrent writer. Recommendations
   below are to be actioned by the orchestrator or the user.

## Recommendations

Priority order.

1. **Revise task 719's scope to consume this round's results rather than re-derive them** (via
   `/revise 719`, not silently). Specifically: its Deliverable 1 (ray layer) is **answered** by F2 —
   land the direct definition, drop the colimit investigation; its Deliverable 3 (stab fibre) is
   **proved** by F1 — the task's job becomes *promoting* `Probe718.seamFibreEquiv` and
   `seamOmegaEquiv` into `FormalSystem/`, not re-establishing them; its Deliverable 2 should note
   that `PlusPasting.paste` already is `⌢_z` at the general frame and that the remaining content is
   the *ray-layer* operator plus uniqueness; its Deliverable 4 is **reachable** per F2's corollary.
   Deliverable 5 is where the real open work now sits and should be re-pointed at R1's three probes.
2. **New task: promote the two FMP/width refutations into the library.** `Probe706.no_finite_carrier_sat`
   / `not_finite_carrier_fmp` and `Probe710.not_finite_width_fmp` are programme-defining negative
   results living only in `specs/**/probes/`. They are what closes R4 and what constrains every
   future class, and the hard constraint of this programme is that obstructions live as theorems.
   Owner: nobody currently. Also update `FormalSystem/Metalogic/Decidability/FMP/README.md`'s open
   item to record that its "build a genuine filtered task relation + truth lemma" goal is
   **unachievable at a finite carrier over ℤ**.
3. **Author-facing (not this round's to decide)**: the paper's `metalogic.tex` FMP subsection and
   the `app:gluing` formalization sentence both have cheap, accurate updates available (F5, F3).
   The `SU` → `US` pin in `docs/reference/paper-definitions-of-record.md` should be refreshed; CI
   cannot see this drift because the paper is out of tree.
4. **Sequence R1's falsification probes 1–3 before any implementation plan commits to
   determinization.** Each is small; probe 2 can kill the route outright for a fraction of the cost
   of the substrate.
5. **Acquire Hodkinson–Reynolds 2006 §§5.10–5.11 bodies (pp. 708–712)** before ranking R2 on
   anything but structural grounds. Everything else in the expected-source list is in the corpus.
6. **Do not fund R5**, and do not fund F4 as a standalone route (R3).

## Risks & Mitigations

- **Nested `⊡` defeats stratification** (R1's real risk, HIGH). Mitigation: probe 1 first; it is the
  cheapest possible test and `PlusTruth.stab_state_only` is the landed fact it leans on.
- **Determinization mechanization cost** (HIGH, and now quantified: no prior art in any proof
  assistant). Mitigation: probe 3 exists to make the *necessity* question empirical before the cost
  is paid; R2 is the fallback that avoids the substrate entirely.
- **F1 could be mistaken for progress on decidability** (reporting risk). Mitigation: stated three
  times in the probe header and here — F1 is the mechanism behind the refutation, not an escape
  from it. The fibre is conceded infinite.
- **"All ways" is a substantive commitment** (unchanged from the task description, and not dropped).
  The full product is the largest bundle; a restricted bundle changes which `⊡` formulas are valid.
  F1 proves the *full* product is what `stab_clause` means, which settles that the full bundle is
  the semantics' own choice and not an assumption this route imports — but it does so descriptively,
  and the ockhamist-grounding argument for *wanting* it is unaffected and still lives where it lived.
- **F5's frame-class limit could be over-read** as "TM lacks FMP, full stop". It is ℤ-time. Stated
  in F5 and repeated here.
- **Concurrent-writer risk on shared task state** — mitigated by writing no task state this round
  (Decision 8).

## Appendix

### Probe compile record

```
lake env lean specs/718_omega_sequence_decidability_full_lplus/probes/SeamFibreProduct.lean
  → clean (no errors, no warnings, no sorry)
'Probe718.seamFibreEquiv'    depends on axioms: [propext, Classical.choice, Quot.sound]
'Probe718.plusStab_iff_rays' depends on axioms: [propext, Classical.choice, Quot.sound]
'Probe718.seamOmegaEquiv'    depends on axioms: [propext, Classical.choice, Quot.sound]
'Probe718.plusStab_iff_omega' depends on axioms: [propext, Classical.choice, Quot.sound]
```

### Paper labels consulted (by label, as required — line numbers deliberately omitted)

`app:gluing`, `thm:extension`, `app:TaskSemantics`, `app:deterministic`,
`app:deterministic-future`, `app:discrete`, `app:dense`, `app:complete`, `app:drift`,
`app:abundant`, `app:unbounded`, `app:frame-impossible`, `app:expressive`, `def:BX` (for the
`US` spelling), `app:Structure` and `app:presheaf-dictionary` (both commented out), the
pasting-principles passage (commented out), `metalogic.tex`'s Finite Model Property subsection and
canonical-model chain.

### Literature status

In corpus and used: Piterman 2007 (LMCS, determinization), Löding–Pirogov 2019 (Safra unified),
Reynolds 2001 (full CTL\* axiomatization), Hodkinson–Reynolds 2006 (Handbook ch. 11 — TOC only for
§§5.10–5.11), Hodkinson–Wolter–Zakharyaschev 2000, GKWZ 2003 ch. 11 (quasimodels/runs),
Vardi–Wolper 1986, Rabinovich 2014 (Kamp), Doets 1987/1989.
Not acquired, and not needed for this round's verdicts: Safra 1988 itself (paywalled; superseded
for the mathematics by the two free sources above), Emerson–Jutla 1988, Zanardo 1985/1991 and
Reynolds 2007 (both paywalled, recorded as the highest-priority pair in
`~/Projects/Literature/SOURCES.md`), Schewe 2009 and Colcombet–Zdanowski 2009 (tight bounds; needed
only if R1 is funded).

### Key landed declarations cited

`StabClause.stab_clause`, `PlusTruth.{stab_iff, dstab_iff, box_iff, stab_state_only}`,
`PlusLanguage.{paste, paste_valid, untl_dstab_valid}`,
`PlusLanguage.plusValidZTime_iff_plusValidInt`,
`FrameOver.{step, mem_HF_iff_adjacent, worldHistoryOfStepPath, taskRel_eq_iter, ofSlicedStep}`,
`PartialHistory.{domain, IsTotal, IsConvex, restrict}`, `WorldHistory.{ofTotal, ext_state, state_congr}`,
`Semantics.Extension`'s Extension Theorem, `BiLasso/Orbit.lean`'s Tier A,
`Probe706.{no_finite_carrier_sat, not_finite_carrier_fmp, θ_eq_ofFormula}`,
`Probe710.{no_finite_width_sat, not_finite_width_fmp, not_sliced_complete}`,
`FixtureStable.lean`'s refutation of `exists_tailStable_repr`.
