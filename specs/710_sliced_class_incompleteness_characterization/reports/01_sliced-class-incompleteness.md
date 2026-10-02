# Research Report: Task #710

**Task**: 710 - sliced_class_incompleteness_characterization
**Started**: 2026-10-02T13:47:44Z
**Completed**: 2026-10-02T14:32:00Z
**Effort**: ~3 hours (research round; one Lean probe written and compiled, 1176 lines, five headline declarations, sorry-free)
**Dependencies**: 703 (landed: `PlusSlicedCertificate`, `Sound.lean`, `Complete.lean`, `EmbedComplete.lean`). Reports 706 round 1 and 703 rounds 1, 2 and 6 read as inputs
**Sources/Inputs**:
- Codebase: `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/{Basic,Frame,Check,Sound,Complete,EmbedComplete}.lean`, `FormalSystem/Semantics/{SlicedFrame,IntNormalForm,TaskFrame,FrameProperty,PartialHistory}.lean`, `FormalSystem/PlusLanguage/{Formula,PlusTruth,PlusValidity}.lean`, `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/{Agreement,Closure}.lean`
- Prior artifacts: `specs/706_lplus_finite_model_property_and_completeness/reports/01_lplus-finite-model-property-research.md` and its probe `probes/NoFiniteCarrierModel.lean` (template for this probe); `specs/703_lplus_compression_and_completeness/plans/06_lplus-sliced-certificate-and-completeness.md` ("Open questions recorded, not planned")
- Literature corpus: `hodkinson_wolter_zakharyaschev_2000_decidable_fragments_fotl` chunks 0021, 0022, 0027, 0028, 0030 (Defs 10-12, Lemma 17, Defs 18-20, Lemma 21), read in full
- Mathlib: `Mathlib.Order.KonigLemma` located via `lean_leansearch` (not used: the finite-carrier König step is proved directly in the probe); `Set.finite_range`, `Set.Finite.bddAbove`, `Set.Finite.biUnion`, `List.finite_toSet`
- One new probe compiled with `lake env lean` against the built tree (about 3 s)
**Artifacts**:
- `specs/710_sliced_class_incompleteness_characterization/reports/01_sliced-class-incompleteness.md` (this report)
- `specs/710_sliced_class_incompleteness_characterization/probes/NoFiniteWidthModel.lean` (compiled, sorry-free; axioms `[propext, Classical.choice, Quot.sound]` on all five headline declarations)
**Standards**: report-format.md, subagent-return.md
**Task Type**: formal:logic

## Executive Summary

- **The refutation was found, and it is machine-checked: the time-sliced certificate class is
  incomplete for full L⁺ over ℤ-time, and already for the CTL-like fragment.** The witness is
  `Φ := θ' ∧ □(⊡Fp → ¬⊡¬Xp)` with `θ'` task 706's "every history meets `p` exactly once" (in its
  `⊡`-form) and `Xp := ⊥ U p`. `probes/NoFiniteWidthModel.lean` proves `not_sliced_complete`:
  `Φ.neg` is a ℤ-time non-validity (`not_plusValidZTime_neg_Φ`, on a countable, finitely
  branching regular ℤ-frame built by *Saturation*-from-finite-fibres) that **no**
  `PlusSlicedCertificate [] [Φ.neg]` certifies (`not_certifies`, through the landed `Certifies`
  checker and `Sound.lean`'s own route). Every `⊡` and `□` in `Φ` governs a state formula or a
  single temporal operator (`AF p`, `AH ¬p`, `EX p`), so it lies in the fragment task 709 targets.
- **The gap is characterised, and it is exactly finite width.** A model satisfying `Φ` must have
  `p` states at every time `t ≤ a`, every state after a `p` state is a *post* state, a post state
  can have no infinite backward chain of post states (that chain, pasted with any forward path, is
  a history with no `p`), so with finitely many predecessors per state the backward post-chains
  into any one state have bounded length (König), while the forward chains from the `p` states at
  times `a - n - 1` arrive at time `a` as backward post-chains of every length `n`: pigeonhole on
  the finitely many states at time `a`. This is `no_finite_width_sat`, stated for
  `FrameOver.ofSlicedStep R fwd bwd` with `[Finite W]` — the frame every certificate presents —
  and `not_finite_width_fmp` restates it as: **no certificate class presenting a frame with finite
  per-time fibres is complete**, whatever its clauses. The hierarchy is now strict:
  finite carrier (refuted by `θ`, task 706) ⊊ finite width (refuted by `Φ`, this task) ⊊ needed.
- **Where HWZ's technique breaks, localised.** Their Theorem 14 (model → quasimodel) collapses the
  domain at each time to its set of realised types; that collapse is sound because monodic FOTL
  has no quantifier over runs, and Lemma 17 (splice) routes runs through equal quasistates for the
  same reason — every run condition is existential (Def 12, Remark 13). L⁺'s `⊡` is a universal
  quantifier over runs, and any collapse to finitely many states per time adds *limit* runs
  (report 706's Route B failure, now with a formula that forbids every finite-width collapse at
  once). The periodicity half of their argument (Lemma 21) does transfer to fixed finite width,
  by a Ramsey-type strengthening of the splice (Finding F4, argued, not machine-checked), which is
  why the obstruction is width and nothing else.
- **Consequences for the programme.** Task 709's headline — the finite model property for the
  CTL-like fragment against the sliced class — is **false as stated**, since `Φ` is in the
  fragment; the ⊡-free flagship (`EmbedComplete.lean`) is unaffected; the model-checker relay
  (task 708) must carry "incomplete for L⁺, complete on the `⊡`-free fragment, never-report-validity
  stands" rather than an open completeness question. The only model class in sight that contains
  every countermodel of `Φ.neg` is the regular two-way tree class (a finite class graph with
  forward and backward child labels; `Φ`'s countermodel is one with three classes), which is the
  class Rabin-style regularity would produce — and whose checker would have to evaluate `⊡` over
  unboundedly ascending paths, a pushdown-like structure with no formalised precedent.
- **Recommendation.** Land the probe's five theorems beside `PlusWitnessFamily/Limits/` (a new
  `PlusSlicedCertificate/Limits/NoFiniteWidth.lean`), restate the sliced class's completeness as
  "complete exactly on targets with a finite-width countermodel", re-scope task 709 to the
  `⊡`-free-plus-bounded-delay fragment or abandon it, and record in task 708's relay that the
  certificate class is semantically incomplete. Raised as a non-blocking user decision.

## Context & Scope

Risk R3 of report 706 asked whether the sliced class — bi-serial, eventually periodic, tail-stable
sequences of finite slices on `ℤ × Fin n`, with liveness computed on all paths — is complete for
full L⁺. The dispatch asked for the refutation to be attempted first, by probe, on the pattern of
`NoFiniteCarrierModel.lean` (task 706) and `NoFiniteCertificate.lean` (task 703 round 2), and
for HWZ's quasimodel technique to be tested for transfer before any cold search.

Scope boundaries honoured:

- Research only. No file under `FormalSystem/` was edited; no plan was revised; no sibling's
  `file_scope` (`scripts/check-module-invariants.sh` for 704,
  `PlusWitnessFamily/Incompleteness.lean` for 705) was touched. No foreign uncommitted
  modification or running build was observed (`git status` shows only the orchestrator's own
  `specs/` changes).
- The probe is under `specs/710_.../probes/`, imports only `FormalSystem`, and is compiled with
  `lake env lean` from the repository root.
- Question Q6 of report 706 (which fragment the retired `PlusSharingWitnessFamily` class covers)
  is **closed by supersession**, per the dispatch: the only fact known is the necessary condition
  recorded in 703 round 2 §2.5 and 706 §Q6, and no characterisation is attempted here.

### Verification labels

| Label | Meaning |
|---|---|
| **[checked]** | Proved in `probes/NoFiniteWidthModel.lean`, sorry-free, axioms listed |
| **[landed]** | A declaration already in the tree, cited by name |
| **[argued]** | A paper argument in this report, not machine-checked |
| **[literature]** | Read from the literature corpus, cited by the paper's own labels |

## Findings

### F1 — The separating formula and its model **[checked]**

`Φ := (A' ∧ C') ∧ D` with, in the probe's primitive syntax,

```
p   := atom "p"        Fp := ⊤ U p        Pp := ⊤ S p        Xp := ⊥ U p
A'  := □(p ∨ ⊡Fp ∨ ⊡Pp)                   C' := □(p → ⊡¬Pp)        (task 706's θ')
D   := □(⊡Fp → ¬⊡¬Xp)
```

`θ' = A' ∧ C'` says every history meets `p` exactly once (every history has `p`, and a `p`-time
has no earlier `p`-time). Under it every state is one of: a **`p` state**; a **pre** state (every
history through it has `p` strictly ahead — `⊡Fp`); a **post** state (strictly behind). `D` says
every pre state has a `p`-successor on some history.

The model (`Probe710.F`, `Probe710.M`): carrier `Node = {pre k} ∪ {x k} ∪ {post k j}` (`k j : ℕ`),
steps `pre (k+1) → pre k`, `pre k → x k`, `x k → post k 0`, `post k j → post k (j+1)`, `p` at the
`x` states. Every state has one or two successors and exactly one predecessor, so the fibres of the
generated two-sided relation are finite (`fib_finite`, by `iterS`-free induction on `iter`) and
*Saturation* is `TaskFrame.saturation_of_fib_finite` **[landed]**; *Limit* is
`limit_of_succOrder`; the frame is `FrameOver.ofReflectiveRegular`'s instance, regular and ℤ-time.
Every bi-infinite step path is `… pre (k+2), pre (k+1), pre k, x k, post k 0, post k 1, …` for
one `k` and one position of `x k` (`path_eq_canon`), so truth is a case split on the position of
time `0` relative to that `x`: `Φ_true` at `(histOf 0 0, 0)`, hence `not_plusValidZTime_neg_Φ`.

Two facts about this model are the whole point. **It is finitely branching** — König's lemma
is not what separates it from the sliced class. **Its width is infinite**: at any time, the post
states present have unbounded "age" (distance back to their `x`), and the pre states unbounded
"distance to go"; no two of them are two-way bisimilar. A time-homogeneous presentation with this
property is exactly what the sliced class cannot present.

### F2 — No finite-width sliced frame satisfies `Φ` **[checked]**

`no_finite_width_sat` : for every `W` with `[Finite W] [Nonempty W]`, every bi-serial
`R : ℤ → W → W → Prop`, every model `M` on `FrameOver.ofSlicedStep R fwd bwd`, every history `τ`
and time `t`, `¬ PlusTruthAt M τ t Φ`. The proof is in two layers.

*Semantic layer* (`someP_of_A'`, `onceP_of_C'`, `succP_of_D`). Histories of the sliced frame are
offset step paths (`ofSlicedStep_mem_HF_iff` **[landed]**); `box_transfer` moves any `□`-fact to
every offset-`0` path at every time by `plusTruthAt_timeShift` **[landed]**; a history sharing a
state `(s, w)` with an offset-`0` path at time `s` is itself offset `0` (`hist_offset_zero`). The
three facts extracted, for `val x := M.valuation x pa` and offset-`0` paths `g`:

- `someP`: every path has a `p` time;
- `onceP`: at most one;
- `succP`: if every path through `(s, g s)` has `p` strictly after `s`, then some `u` with
  `R s (g s) u` has `val (s + 1, u)`.

*Combinatorial layer* (`core_false`): `someP`, `onceP`, `succP` are jointly unsatisfiable on a
finite `W`. With `PreN`/`PostN` as above (quantifying over offset-`0` paths), using only path
existence through every state (`exists_path_through`, by iterated choice) and gluing at a time
(`glue_isPath`):

1. a non-`p` state is pre or post (`preN_or_postN`);
2. the successor of a `p` or post state is post; the predecessor of a `p` or pre state is pre
   (`postN_of_exists`, `preN_of_exists` and their four corollaries);
3. behind any `p` state at time `a` there is a pre state at every earlier time (`preN_chain`),
   hence by `succP` a `p` state at every time `a - k` (`val_chain`);
4. the forward sequence from the `p` state at time `a - n - 1` reaches time `a` as a backward
   chain of `n` post states (`exists_backChain`); by pigeonhole on `W` some state `z` at time `a`
   ends backward post-chains of every length (`exists_long`, via `Set.finite_range` and
   `bddAbove`);
5. **König's step** (`long_step`): such a state has a predecessor with the same property, again by
   finiteness of `W`; iterating (`longSeq`) gives an infinite backward chain of post states;
6. gluing it with a forward path from `z` gives a path `g` with `g a = z`; `someP g` yields a `p`
   time `b`; if `b ≤ a` the state there is post, contradicting `not_val_of_postN`; if `b > a`,
   `PostN a z` gives a second `p` time `b' < a`, contradicting `onceP`.

Nothing about tail-stability, periodicity, the window, labels or liveness enters: the refutation is
of the **frame class**, as the dispatch's scope discipline asked (semantic, about the class of
structures a certificate presents, not about its encoding).

### F3 — The certificate corollaries **[checked]**

- `not_certifies (G : PlusSlicedCertificate [] [Φ.neg]) : ¬ G.Certifies`. From `G.Certifies`,
  `Sound.lean`'s route (`biSerial_of_certifies`, `exists_fulfilling_run_at_targetTime`,
  `lab_eq_canLab`, `mem_canLab_iff_plusTruthAt` **[landed]**) puts `Φ` true at the target
  position of `G.model h` on `G.frame h = FrameOver.ofSlicedStep G.stepRel …` with `W = Fin G.n`;
  F2 refutes it. The frame is kept rather than exported through `PlusRefutes`, which forgets it.
- `not_sliced_complete : ¬ ∀ ψ, ¬ PlusValidZTime ψ → ∃ G : PlusSlicedCertificate [] [ψ], G.Certifies`.
- `not_finite_width_fmp`: no ℤ-time non-validity-to-finite-width-countermodel property, stated
  over every `W`, `R`, `fwd`, `bwd`, `M`, `τ`, `t`. This is the statement that survives any
  change to the checker's clauses, the tail-stability mechanism, or the wire format.

### F4 — What the sliced class *is* complete for, and why width is the only obstruction **[argued]**

The class is complete exactly for targets with a **finite-width** countermodel. Necessity of
finite width is F2's shape (the certificate presents `ℤ × Fin n`). Sufficiency — every
finite-width model has an eventually periodic, hence tail-stable-presentable, finite-width model
of the same width — is the periodicity half of HWZ's argument, and it transfers, but not by their
splice lemma as stated. Sketch, for a bi-serial width-`n` sliced structure `S` satisfying `ψ`:

- Per node `(t, w)` let `fwdLive(t, w)`, `bwdLive(t, w) ⊆ H` be the Hintikka types starting a
  forward-, resp. backward-, fulfilling coherent type path (the landed `Live.lean` notions); the
  realised types are `live = fwdLive ∩ bwdLive` (pasting, 703's S5), and every `⊡`/`□` label is a
  universal statement over `live`. `fwdLive(t, ·)` is determined by `E_t` and `fwdLive(t+1, ·)`
  (prepending a coherent step to a fulfilling path keeps it fulfilling), and mirror for `bwdLive`.
- For `s < t` colour the pair by the strong slice states `(E, lab, fwdLive, bwdLive)` at `s` and
  `t` together with the relation `R_{s,t} ⊆ (Fin n × H)² × 2^{Ev}` of "type-path from `(s, w, h)`
  to `(t, u, h')` witnessing the eventualities `F`". Colours compose (`R_{s,u} = R_{s,t} ; R_{t,u}`)
  and are finitely many; infinite Ramsey for pairs gives `s₁ < s₂ < …` all of one colour `c`.
- Replace the forward tail by `[s₁, s₂)` repeated. `fwdLive` is preserved at `s₁`: ⊇ because a
  fulfilling path in `S` visits some `(w*, h*)` at infinitely many `sᵢ`, and the segments
  `(s₁, s_{i₁})` and `(s_{i₁}, s_{i_k})` — chosen so that every pending eventuality of `h*` is
  witnessed — have colour `c`, hence are realised inside one period; iterating the loop is
  fulfilling. ⊆ because each period of a fulfilling path in the periodic structure is a triple in
  `c = R_{sⱼ, sⱼ₊₁}`, realised in `S` between consecutive Ramsey times, and the witnessed sets
  compose. Within the first period both live sets are then forced by the one-step equations;
  `bwdLive` propagates forward unchanged. `□`-witnesses and the target sit in a window chosen
  below `s₁`. Mirror for the backward tail.
- Hence every label is unchanged, the structure is eventually periodic of the same width, and
  the landed re-presentation argument (706 §Q1.4 item 4; `Fixpoint.lean`) makes it tail-stable.

This is the HWZ Lemma 17/Lemma 21 argument with two repairs forced by `⊡`: the quasistate must
record the **one-sided** live sets (their `f(n) = f(m)`, equality of realised types, does not
determine `fwdLive(m, ·)`, so splicing can create a new realised type and falsify a `⊡`-label),
and fulfilment within a period must be secured for **every** live position at once, which the
idempotent Ramsey colour supplies and successive splicing (their Lemma 21) does not. None of this
is needed for the refutation; it is recorded because it shows the obstruction is width alone, so
no change to tails, windows or stability can rescue the class.

### F5 — HWZ transfer, localised **[literature]** **[argued]**

Read against chunks 0021-0030 of `hodkinson_wolter_zakharyaschev_2000_decidable_fragments_fotl`:

| HWZ | Sliced class | Transfers? |
|---|---|---|
| Def 10 state function `f(w) = ⟨T_w, T_w^con⟩`: the set of realised types at `w` | per-slice labelling plus live sets | as data, yes |
| Def 11 run: a coherent, U/S-fulfilling type sequence | fulfilling type path (`Live.lean`) | yes |
| Def 12 quasimodel: every type at every `w` lies on **some** run; Remark 13: take **all** runs `Ω_f` | every live position lies on a fulfilling path; `⊡` demands **all** paths through a state satisfy the label | the existential half transfers; the universal half has no HWZ counterpart |
| Thm 14 model → quasimodel: collapse the domain at each `w` to its realised types | collapse a model to finitely many states per time | **breaks**: F2. For L⁺ the collapse adds limit paths (706 Route B); `Φ` forbids every finite-width collapse |
| Lemma 17 splice at `f(n) = f(m)` | splice at equal strong slice states | breaks as stated (one-sided live sets); repaired in F4 |
| Lemma 21 bounded-period realisation by successive splicing | eventually periodic tails | transfers with the Ramsey repair (F4); no period bound claimed |
| MSO route (§4): "a quasimodel exists" as an MSO sentence over the flow | for fixed `n`, "a width-`n` model exists" is MSO over `⟨ℤ,<⟩` with alphabet the slice graphs (paths are `n`-tuples of unary predicates, `⊡` a second-order quantifier) | yes for fixed width; useless without a width bound, and F2 shows none exists |

So the question "does every satisfiable L⁺ formula have an eventually periodic quasimodel with
bounded period" splits: *periodic* yes (F4, for whatever width it has); *quasimodel with a
state candidate per time* — i.e. finite width — **no** (F2). The failure is in the first step of
HWZ's method, not in the periodicity machinery the sliced certificate was built to supply.

### F6 — The limit-closure test, and the bundled-trees precedent, re-read **[argued]**

The dispatch asked whether the sliced class contains the limits of its own ascending chains. It
does, trivially: every bi-infinite step path of a presented frame is a history (`mem_HF_iff_slicedPath`
**[landed]**). The separating formula came from the *dual* observation: limit closure together
with finite per-time fibres is König's lemma, so the class cannot contain a model in which a
universal eventuality (`⊡Fp` at the pre states, with the once-only clock) has unbounded delay at
a single time. Bundled trees omit limit paths and are refuted by a formula that forces one;
finite-width structures *add* limit paths and are refuted by a formula whose every model needs a
limit path to be absent. The precedent transfers as a method (force a limit object the class gets
wrong), not as a formula. Zanardo 1985 and Reynolds 2007 remain unacquired and were not needed.

### F7 — What is now open, and what is not

- **Closed**: completeness of the sliced class for full L⁺ (false); for the CTL-like fragment
  (false, same witness); for any finite-width certificate class (false). Q6 of report 706
  (closed by supersession).
- **Unchanged**: the `⊡`-free flagship `exists_plusSlicedCertificate_of_not_plusValidZTime_ofFormula`
  **[landed]**; soundness; the two prior refutations.
- **Open, sharpened**: decidability of L⁺ ℤ-time validity now has no certificate-class route at
  all; what is left is the automata route (706 Route A) or a **regular two-way tree** class — a
  finite graph with forward- and backward-child labels whose carrier is the set of root paths and
  whose step relation descends a forward edge or ascends a backward one. `Φ`'s model is one with
  three classes (`X: f→Post, b→Pre; Pre: f→X, b→Pre; Post: f→Post, b→X`). Whether every
  satisfiable L⁺ formula has such a model is the two-way analogue of Rabin's regularity theorem
  (plausible via 706's two-way-tree unravelling and MSO; not formalisable soon), and a checker for
  it would have to decide `⊡` over paths that ascend unboundedly through the root path — a
  pushdown-like liveness with no precedent in the tree or in Mathlib.
- **Not claimed**: any width bound for targets that *do* have finite-width countermodels; any
  period bound; that the regular two-way tree class is complete.

### Codebase Patterns

- `FrameOver.ofStep`'s field discharges (`IntNormalForm.lean`) are generic in `W` except
  *Saturation*; swapping `saturation_of_finite` for `saturation_of_fib_finite` with
  `Fib (ofStepRel R₁) w d ⊆ {u | iter R₁ |d| w u}` finite by induction gives a regular frame on any
  finitely branching bi-serial step relation (`Probe710.F`). The same generalisation of
  `FrameOver.ofSlicedStep` (replace `[Finite W]` by finite forward and backward fibres of `R t`)
  would be the reusable form; it was not needed here.
- `plusTruthAt_timeShift` plus `worldHistoryOfStepPath` turns a `□`-fact at one time into a fact
  along every offset-`0` path at every time (`box_transfer`), a cleaner idiom than the shifted
  path `mk g hg` of `NoFiniteCarrierModel.lean`.
- `ofSlicedStep_mem_HF_iff` is the only history-space fact used; pasting is literal gluing of two
  offset-`0` paths at a time (`glue_isPath`), with no appeal to `paste`.
- König for a finite type is forty lines with `Set.finite_range`/`bddAbove` and `Classical.choose`
  iterated by a `Nat`-recursive subtype sequence (`longSeq`); `Mathlib.Order.KonigLemma`'s
  `exists_seq_forall_proj_of_forall_finite` would also do but needs a projective system.

### Mathlib Theorems

- `Set.Finite.biUnion`, `List.finite_toSet` (finite fibres of iterates);
  `Set.finite_range`, `Set.Finite.bddAbove` (pigeonhole and König over `W`);
  `Finite.exists_ne_map_eq_of_infinite` not needed this time.
- `Mathlib.Order.KonigLemma`: `exists_seq_covby_of_forall_covby_finite`,
  `exists_seq_forall_proj_of_forall_finite` (located, not used).

### Context File Review

- `context/project/logic/README.md` loaded first; no domain file covers ℤ-time certificate
  classes (task 707 is writing the finite-carrier note). This report's F2 argument is the natural
  second section of that note.

### External Resources

- Hodkinson, Wolter, Zakharyaschev 2000, APAL 106, §§3-5 (quasimodels, Lemma 17, Lemma 21), as
  cited in F5. Their decidability proofs never need a universal quantifier over runs; that is the
  single point of divergence.
- Emerson and Halpern 1986 (R-generability, limit closure) and Reynolds 2001 §1 (banning), as
  report 706 already cites them; nothing new was extracted.
- Zanardo 1985, Reynolds 2007 (bundled trees): unacquired, unneeded (F6).

### Recommendations

1. **Land the probe as library theorems** in a new
   `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Limits/NoFiniteWidth.lean` (or
   beside `PlusWitnessFamily/Limits/`): `not_plusValidZTime_neg_Φ`, `no_finite_width_sat`,
   `not_certifies`, `not_sliced_complete`, `not_finite_width_fmp`; pin them in
   `docs/theorem-index.md` and `scripts/check-module-invariants.sh` per the C2/C15 invariants
   (task 704 owns that script this cycle — coordinate, do not edit concurrently). Add the probe
   to `scripts/check-evidence-probes.sh` until then. Estimated 6-10 h including a generic
   `FrameOver.ofStepFib` constructor.
2. **Restate the class's completeness** in `PlusSlicedCertificate.lean`'s header and
   `EmbedComplete.lean`'s "What the flagship does and does not buy": complete on the `⊡`-free
   fragment; incomplete for L⁺ and for the CTL-like fragment, with `Φ` named; the precise
   semantic characterisation (F4) recorded as argued.
3. **Re-scope or abandon task 709**: its headline is refuted. A surviving fragment would have to
   exclude `AF`-style universal eventualities with unbounded delay — e.g. restrict `⊡` to safety
   and bounded-step operators (`⊡G`, `⊡X^k`), whose countermodels are finite-width by a direct
   König-free argument; or restate 709 as the F4 periodicity theorem (finite width ⟹ eventually
   periodic), which is a real theorem the sliced class needs and is formalisable (Ramsey for pairs
   plus the landed liveness machinery; 40-80 h).
4. **Relay to task 708**: the sliced wire format is sound and is a strict extension of the lasso
   family, but it is semantically incomplete for L⁺; the never-report-validity discipline is
   permanent for targets with `⊡`, not pending a proof. The relay should cite `Φ`, not an open
   question.
5. **Do not pursue a fourth certificate class without the regular-two-way-tree analysis first.**
   Any class presenting a frame with finite per-time fibres is refuted by `not_finite_width_fmp`;
   the next candidate must present infinite fibres (root paths of a finite class graph), and its
   checker's `⊡` clause is the open problem. File that as a research-first task only if
   decidability of full L⁺ remains a programme goal.
6. **Fold F2 and F6 into task 707's context note** as a second section ("finite width fails
   too"), so the fact is read where certificate classes are designed.

## Decisions

- **D1. The refutation was attempted first and succeeded**; no cold search was needed. The
  formula was derived from the HWZ transfer analysis (F5): once the universal `⊡` was seen to
  need one-sided live sets, the question became whether finite width could be forced to fail, and
  König's lemma on finite fibres pointed at unbounded post-ages.
- **D2. The probe refutes the frame class, not the checker**: `no_finite_width_sat` is stated for
  every model on every finite-`W` `ofSlicedStep` frame, and `not_certifies` is derived from it
  through the landed soundness route. A refutation of `Certifies` alone would not survive a
  checker change; this one does.
- **D3. The model is time-homogeneous and finitely branching, by design**, so that the
  separation is attributed to width alone and not to infinite branching or to time-stamping.
- **D4. F4 (finite width ⟹ eventually periodic) is argued, not formalised.** It is not needed for
  the refutation; it is recorded because it pins the obstruction to width and because it is the
  theorem a re-scoped 709 could prove.
- **D5. Q6 of report 706 is closed by supersession**, as the dispatch directed.
- **D6. A non-blocking user decision is raised**: re-scoping task 709 and the wording of the 708
  relay are programme-level choices; nothing is lost by proceeding on the recommendation.
- **D7. No `.orchestrator-handoff.json` is written.** Outcome returned through `.return-meta.json`.

## Risks & Mitigations

| # | Risk | Severity | Mitigation |
|---|---|---|---|
| R1 | The probe's `Φ` is misread as outside the CTL-like fragment because `⊡¬Xp` and `⊡¬Pp` are stated with negation under `⊡` rather than as `⊡(S U S)`/`⊡(S S S)` literally | Low | Over ℤ-time `¬Xp ≡ ⊥ U ¬p` and task 706's own `θ'` already uses `⊡¬Pp` inside the fragment; the fragment grammar of 706 §Q3 lists `G` and its mirrors as instances. If a stricter grammar is adopted, the equivalent rewrite is one `decide`-free lemma |
| R2 | The probe drifts as the tree evolves | Low | Imports `FormalSystem` only; add to `scripts/check-evidence-probes.sh` or land per recommendation 1 |
| R3 | F4's Ramsey argument has a gap in the ⊆ direction (period segments realised in `S` between *consecutive* Ramsey times must compose into a fulfilling `S`-path) | Medium | The composition is by witnessed-set union and coherence-persistence of pending eventualities; stated in F4 with the sub-case (witness before the pending position) handled. It affects only the characterisation's sufficiency half, not the refutation |
| R4 | Task 709 is dispatched against its current description before this report is read | High | This report is filed in the same cycle; recommendation 3 names the re-scope. 709 is `[NOT STARTED]` with 703 as its only dependency |
| R5 | The paired model checker reads the sliced contract as pending-complete | Medium | Recommendation 4 |

## Appendix

### Probe

`specs/710_sliced_class_incompleteness_characterization/probes/NoFiniteWidthModel.lean`, 1176
lines, compiled from the repository root with
`lake env lean specs/710_sliced_class_incompleteness_characterization/probes/NoFiniteWidthModel.lean`
(about 3 s; no `sorry`; the only warnings silenced are the unused-section-variable notices in the
`Core` section). `#print axioms` reports `[propext, Classical.choice, Quot.sound]` for
`not_plusValidZTime_neg_Φ`, `no_finite_width_sat`, `not_certifies`, `not_sliced_complete`,
`not_finite_width_fmp`.

| Declaration | Statement |
|---|---|
| `Probe710.Φ` | the witness, in primitive syntax (F1) |
| `Probe710.F`, `Probe710.M` | the countable finitely branching regular ℤ-frame and model |
| `Probe710.path_eq_canon` | every step path of `F` is `canon k t` for some `k`, `t` |
| `Probe710.Φ_true` | `PlusTruthAt M (histOf 0 0) 0 Φ` |
| `Probe710.not_plusValidZTime_neg_Φ` | `¬ PlusValidZTime Φ.neg` |
| `Probe710.core_false` | `someP`, `onceP`, `succP` are inconsistent on a finite `W` (F2 step 1-6) |
| `Probe710.no_finite_width_sat` | no model on `FrameOver.ofSlicedStep R fwd bwd`, `[Finite W]`, satisfies `Φ` anywhere |
| `Probe710.not_certifies` | `∀ G : PlusSlicedCertificate [] [Φ.neg], ¬ G.Certifies` |
| `Probe710.not_sliced_complete` | the class is not complete for ℤ-time non-validity |
| `Probe710.not_finite_width_fmp` | no finite-width countermodel property |

### The witness, in primitive syntax

```
top := ⊥ → ⊥      Fp := untl top p      Pp := snce top p      Xp := untl ⊥ p
A'  := □(¬p → (¬⊡Fp → ⊡Pp))            C' := □(p → ⊡(Pp → ⊥))
D   := □(⊡Fp → (⊡(Xp → ⊥) → ⊥))
Φ   := ¬((A' ∧ C') → ¬D)      with  a ∧ b := ¬(a → ¬b)
```

### The three-class regular two-way tree (F7), for the record

Classes `X` (`p`), `Pre`, `Post`; forward child: `X ↦ Post`, `Pre ↦ X`, `Post ↦ Post`; backward
child: `X ↦ Pre`, `Pre ↦ Pre`, `Post ↦ X`. Carrier: words over `{f, b}` from a root of class `X`;
step: `w → w·f`, and `w·b → w`. Every history is `… Pre Pre X Post Post …`, every `Pre` node has
the forward child `X` as a `p`-successor, so `Φ` holds; the finite quotient (three states,
`Pre → Pre`, `Pre → X`, `X → Post`, `Post → Post`) is not a model (the `Pre` loop is a `p`-free
history), which is the finite-carrier failure of task 706 seen from the tree side. Not formalised;
`Probe710.F` is the simpler witness.

### Searches

- Repository: `ofSlicedStep`, `saturation_of_fib_finite`, `ofReflectiveRegular`,
  `mem_HF_iff_adjacent`, `plusTruthAt_timeShift`, `Certifies`, `plusRefutes_of_certifies`,
  `exists_fulfilling_run_at_targetTime`, `mem_canLab_iff_plusTruthAt`, `IsPath|glue` (no
  clashes), `open question|left open` in 703 plan v6.
- Literature corpus: `splic`, `Lemma 17`, `Definition 12`, `Definition 20`, `bounded period`
  in the HWZ source directory (the FTS index returned no results for the same queries; the chunk
  files were grepped directly).
- Mathlib: `lean_leansearch` "König's lemma: finitely branching infinite tree has an infinite
  path" (one query; `lean_local_search` reported its index unavailable).
