# Research Report: Task #559

**Task**: 559 - nondeterministic_canonical_model_tm_star_completeness
**Started**: 2026-09-18T19:19:00Z
**Completed**: 2026-09-18T19:45:00Z
**Effort**: one research dispatch (orchestrated, seq 4)
**Dependencies**: 535 (archived report and probes), 533, 536, 537 (landed baseline)
**Sources/Inputs**: - Codebase (`Syntax/PlusLanguage/Axioms.lean`, `Semantics/PlusLanguage/{PlusTruth,PlusPasting,PlusValidity}.lean`, `Semantics/TaskFrame.lean`, `Semantics/PartialHistory.lean`, `Metalogic/Independence/{NaiveSystem,CoarsenedModels,PastingIndependence,StateSetTruth,DeterminismUndefinable}.lean`, `Metalogic/Conservativity/Plus/{README.md,Forward.lean}`, `Metalogic/BXCanonical/Completeness.lean`, `Metalogic/WeakCanonical/IntegerModel/ReynoldsBridge.lean`), the archived 535 report, the literature corpus (`~/Projects/Literature/sources/reynolds_2001/` §1, §5-§8), and a compiled Mathlib-only probe file. No `lake build`, no `lean_build`, no `FormalSystem` import (build embargo from the user).
**Artifacts**: - `specs/559_nondeterministic_canonical_model_tm_star_completeness/reports/01_nondeterministic-canonical-model.md` (this report); - `specs/559_nondeterministic_canonical_model_tm_star_completeness/probes/01_limit-closure-probes.lean` (550 lines, sorry-free)
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **Headline verdict: the current TM⁺ axiom set is incomplete over the paper's all-histories
  semantics at ZTime.** The witness is `LC⁺ := (⟐Xp ∧ ⊡G(p → ⟐Xp)) → ⟐Gp`, a direct transposition
  of the limit-closure (LC) axiom that Reynolds (2001) added to get full CTL*. LC⁺ holds on every
  ℤ-time task frame. It fails in a paste-closed coarsened-state model on a genuine infinite ℤ-time
  task frame. By the repo's own coarsened-model soundness pattern, extended with two arms for PS/US,
  it is therefore not derivable in TM⁺ at `.ZTime`. Every mathematical step is either already in
  the repo or machine-checked in the probe file. Only the final assembly inside `FormalSystem` is
  left to task 560, and that step is transcription.
- **The obstruction is limit closure, not a mixed-formula demand.** Lifting fails first at a
  pure-future eventuality forced under `⊡`. With `⊡F¬p ∈ Λ(t)`, a `⇒`-respecting class walk can stay
  in `p`-classes forever, and then no chronicle labels it. PS and US only cover finite splices, and
  this demand is an ω-limit of splices. The TaskFrame axioms are not the problem over ℤ: on a
  finite type digraph all six hold for free (see §1).
- **Route (c), L⁺-indistinguishability of a bundled model and its completion, is closed.** A
  bundle and its completion disagree on LC⁺ (probe `lcPlus_refuted` against
  `completion_validates`). The `StateSetTruth` technique only works when every history through a
  state has the same L⁺-theory, and that is exactly what fails in any model that refutes
  *Determined*.
- **Naming rule: 535's candidate is unsound.** The rule reads: from `⊢ (q ∧ ⊡q ∧ □H¬q ∧ □G¬q) → φ`
  infer `⊢ φ`. Its antecedent can never be satisfied, because `H_F` is closed under time shift
  (probe `naming_antecedent_unsat`), so the rule derives `⊥`. Rules that name times (IRR style)
  conflict with shift-invariance. Reynolds' AA rule is sound for trees because it can split nodes
  by path. Here atoms and `⊡` are state-valued and states cannot be split, so AA does not transfer
  as stated (UNVERIFIED). The ANF phenomenon does not force a rule: TM⁺ has no substitution rule,
  and AS is an atom-restricted schema.
- **The positive problem is at least as hard as full CTL*, and it is not implementable now.** The
  pure-future fragment of TM⁺ over ℤ-time frames is full CTL* over serial Kripke structures, with
  `⟐` read as `E` (paper reduction, §2.4). Reynolds needed LC plus the AA rule and a roughly 40-page
  automaton-and-banning construction for that fragment alone. TM⁺ adds branching past, S, and `□`.
  The recommended candidate system is TM⁺ + an LC schema family at `.ZTime`, and its completeness is
  labelled CONJECTURED.
- **Bundled fallback: soundness yes, "modest" completeness no.** TM⁺ is sound over paste-closed
  bundles; this is the same fact that powers the countermodel. Completeness over bundles is not
  reachable from the existing engines with modest changes. At ZTime, canonical ℤ-chronicles do not
  exist through arbitrary MCSs because the logic is not compact. At Dense, U/S separation fails over
  ℚ, which puts mixed single-splice lifting at risk.
- **Recommendation for task 560 (rescoped on this report):** implement the definite theorem
  `plus_incomplete_ztime : PlusValidZTime lcPlus ∧ ¬ PlusDerivable .ZTime [] lcPlus` in four
  one-run phases (§5). Record general completeness as open, sharpened from "open" to "false for the
  current axioms at ZTime; open for any extension". Do not attempt `plus_completeness_ztime`.

## Context & Scope

The question was whether the chronicle-based completeness engines can be adapted so that the
canonical frame is nondeterministic, which would give a complete axiomatization of TM⁺ (L plus the
stability modal `⊡`) over the paper's all-histories semantics. The dispatch asked for ZTime first.
Constraints: research only, output limited to the report and probes, never a sorried completeness
theorem, and every proposed axiom either probed sorry-free or labelled UNVERIFIED. The user also
imposed a hard constraint: no `lake build`. The probes therefore import Mathlib only. They mirror
`PlusTruthAt` specialised to ℤ-time and were compiled with the pinned toolchain's bare `lean`
against the pinned Mathlib oleans, with `LEAN_PATH` set by hand and no `lake` process. The first
two parts were also run through `lean_run_code`.

**Faithfulness of the mirror.** Take a frame over ℤ and let `R := ⇒₁`. Compositionality gives
`⇒ₙ = Rⁿ` for `n ≥ 1`, and nullity gives `⇒₀ = id`. `WorldHistory F` (`PartialHistory.lean:405`)
is the type of total histories, whose obligation `respects_task s t` then says exactly that
consecutive states are `R`-related. So `H_F` is the set of bi-infinite `R`-walks. The probe type
`BModel` carries the bundle `B` explicitly, and `fullModel R V` is the case "B = all walks". The
`T` recursion is `PlusTruthAt` clause for clause (`PlusTruth.lean:81-90`), with `□`/`⊡` ranging
over `B`.

## Findings

### Codebase Patterns

- `PlusAxiom` (`Syntax/PlusLanguage/Axioms.lean`) is closed, with the TM schemata over
  `PlusFormula` plus SK, ST, S4, S5, MS, AS, PS (`paste`) and US (`untl_paste`), all at `.Base`.
  `PlusDerivationTree` has no substitution rule.
- `Independence/CoarsenedModels.lean` already contains the whole soundness machinery the
  incompleteness proof needs. `CoarseModel` interprets `⊡` by a coarsening `π`, and
  `cTruthAt_iff_atomize` carries every TM schema over by atomization. `naiveAxiom_cValid` has one
  arm per constructor and no wildcard, with PS/US excluded. `naive_cValid_and_reflect_time` is the
  companion recursion, and `not_naiveDerivable_of_cRefuted` is the shape a refutation consumes.
  **The only missing pieces are a `PasteClosed` predicate and two arms (PS, US).** Probe Part F
  (`ct_iff_image`) shows that coarse truth equals bundled truth on the `π`-image. Part B
  (`ps_valid`, `us_valid`) proves both arms for every paste-closed bundle.
- All four engines build deterministic countermodels (535 §4.1, re-confirmed:
  `zTaskFrameV2`, `ReynoldsBridge.lean:463`, `u = w + d`). The ZTime engine
  (`countermodel_discrete_reynolds_v2`, `ReynoldsBridge.lean:873`) handles `□ψ` as a monadic
  predicate that is constant along each family. It is a Reynolds/Doets k-equivalence transfer on
  linear orders, and it has no branching analogue.
- The `StateSetTruth`/`OrderTransfer` technique (`plusTruthAt_iff_mem_satSet`) needs (H1)+(H2):
  truth depends on the state alone. This makes *Determined* valid (`determined_of_orderFlow`), so
  the technique cannot apply to any model that refutes *Determined*.

### External Resources

- Reynolds 2001, *An axiomatization of full computation tree logic* (JSL), read on disk:
  - §1 frames the gap: bundled (Stirling's VLTFC, fusion- and suffix-closed paths) against
    limit-closed.
  - §6 gives the LC axiom `AG(Eα → EX((Eβ) U (Eα))) → (Eα → EG((Eβ) U (Eα)))` with the soundness
    proof (Lemma 5), a dependent-choice path construction that the probe's `limit_walk` transposes.
  - §7 gives the Auxiliary Atoms rule. It is IRR-like, with fresh atoms, and it is sound because
    atoms can be assigned by recursion from the root along the branches of a tree (Lemma 6).
  - §8, Theorem 3: bundled axioms + LC + AA is weakly complete. The proof is a filtration with a
    deterministic Rabin automaton and a banning mechanism.
- 535's literature inventory (Thomason 1984 §4, Reynolds 2003, Zanardo 1985/1991 second-hand,
  von Kutschera 1997, Di Maio-Zanardo 1996) is unchanged; it was not re-read.
- Gabbay's separation theorem for U/S holds over Dedekind-complete orders (ℤ, ℝ) and fails over ℚ
  (Stavi connectives needed). Cited from memory as standard background, not re-read here.

### 1. Frame design (question 1)

**Over ℤ, a task frame is a digraph that is serial in both directions, plus Saturation.**

| Axiom | Status over ℤ | Reason |
|---|---|---|
| `nullity_identity` | automatic | `⇒₀ := id`; `FrameOver.nullity_identity` derives it from Limit |
| `comp` (both directions) | automatic | `⇒ₙ := Rⁿ`, so composition and interpolation are associativity of relational powers |
| converse | automatic | `ofReflective` / `reflect` convention |
| `serial` | the digraph condition | every node needs an in-edge and an out-edge |
| `limit` | automatic | `TaskFrame.limit_of_succOrder` |
| `saturation` | automatic for finite `W` (`saturation_of_finite`); **a genuine condition for infinite `W`** | a directed chain `Fib(a_k,1) = {b_j : j ≥ k}` can have empty intersection. For an MCS-based `W` whose relation is closed in the Stone topology, fibres and segments are closed in a compact space, so compactness gives it (paper argument) |

**Recommendation:** the frame for any future completeness attempt should be Reynolds-style, with
states = `⊡`-classes of sets that are maximal consistent *relative to a finite closure*. Then `W`
is finite and all six axioms hold for free. The literal infinite class frame `MCS/≈` is strictly
worse: Saturation needs compactness, and 535 §4.3 already showed that the composition direction
fails. **The whole difficulty lies in the truth lemma on the walks the finite digraph admits**,
exactly as in full CTL*. The same fact shows why a countermodel to limit closure *must* be
infinite. On a finite frame the walk space is compact, so every continuous `π`-image is
limit-closed and LC⁺ holds. The probe frame `cR` below therefore has `W = Option ℕ`.

### 2. Lifting over ℤ (question 2): it fails, and the named failure is limit closure

#### 2.1 The validity (probe Part A, compiled)

- `limit_walk` handles any digraph `R` and state `w`. Suppose there is a walk through `w` at `t`
  with `p` at `t+1`, and every `p`-point on a walk through `w` at `t` can be continued one more
  `p`-step. Then **one** walk through `w` at `t` has `p` at every `s > t`.
- The proof is dependent choice. `chain` builds stage `k+1` by pasting (`paste_walk`) a
  continuation onto stage `k`. `chain_agree` shows the stages agree on growing initial segments,
  and the limit is read off diagonally.
- `lcPlus_valid_full` concludes `T (fullModel R V) σ t (lcPlus p)` for every digraph, valuation,
  sequence and time. This is LC⁺ validity over every ℤ-time task frame under the all-histories
  semantics.

#### 2.2 The countermodel (probe Parts B-D, F, compiled)

- `cModel`: two classes (`true` = the `p`-class `a`, `false` = `b`), with bundle
  `finRuns := {β | ∀ n, ∃ m ≥ n, β m = false}` (no infinite forward `a`-run).
  `finRuns_pasteClosed` and `finRuns_shiftClosed` hold. `lcPlus_refuted` shows LC⁺ fails at every
  member and every time.
- `cR` on `Option ℕ`: `none = b`, `some j = a_j`, with edges `b → x`, `a_j → b`, and `a_j → a_m`
  for `m < j`.
  - `image_walk_mem` (counters strictly decrease) and `mem_image_walk` (the counter is the distance
    to the next `b`, via `Nat.find`) combine into `cR_image_eq`: the `isSome`-image of the walks is
    exactly `finRuns`.
  - `cR_to_none`, `cR_from_none` and `cR_two_universal` give two-way seriality and `R∘R`
    universal. So every nonzero-duration fibre and segment contains `none`, and the zero-duration
    ones are singletons, which means **Saturation holds**. The directed-family argument is on paper
    here; the repo's `sInter_nonempty_of_directed_of_*` helpers are the transcription targets.
- `ct_iff_image` shows that coarsened truth (the mirror of `CTruthAt`) on `cR` with `π := isSome`
  equals bundled truth on the image. `lcPlus_refuted_coarse` gives the end-to-end refutation.

#### 2.3 Non-derivability, assembled

1. Consider coarsened-state models that are paste-closed on their `π`-image. TM schemata are valid
   on them at `.ZTime` frames: `cTruthAt_iff_atomize` and `axiom_validIn` at `fc := .ZTime`, the
   same proof as `cValid_of_tm` with the class generalised.
2. SK, ST, S4, S5, MS and AS hold by the landed `cValid_stab_*` arms.
3. PS and US hold by `ps_valid` / `us_valid`. Their time-reflected forms hold by the same pasting
   with the roles swapped.
4. The rules are sound by the landed companion recursion.
5. `cR` is a ZTime frame, and it refutes LC⁺.

Hence `¬ PlusDerivable .ZTime [] lcPlus`, and with 2.1, **TM⁺ is incomplete at ZTime.**
Consistency check against 537: under `⊡ = id`, LC⁺ is the induction principle
`(Xp ∧ G(p → Xp)) → Gp`, which is TM-derivable at ZTime (Z1). So LC⁺ is derivable in TM⁺ +
*Determined*, which agrees with 537's deterministic completeness. The countermodel is
nondeterministic, as it must be.

**The first failing lifting demand.** Take `Γ ⊇ {⟐Xp, ⊡G(p → ⟐Xp), ⊡F¬p}`, which is consistent
by 2.3. The class walk that stays in `p`-classes after `t` respects `⇒`. A labelling would need
`F¬p ∈ Λ(t)`, because `⊡F¬p` is class-determined. It would also need `p ∈ Λ(s)` for every `s > t`,
because atoms are class-determined by AS. Those two requirements contradict each other. The demand
is a **pure-future eventuality under `⊡`**; the general case is `⊡(χ₁ U χ₂)`. It is not a mixed
demand.

#### 2.4 Hardness of the positive problem (paper argument, Medium-High)

- The translation: a CTL* state formula `Eψ` maps to `⟐ψᵗʳ`, and path formulas map to pure-future
  formulas (X ↦ `untl ⊥`, U ↦ strict U with the present conjunct).
- Pure-future truth at `(σ,t)` depends only on `σ|[t,∞)` (repo `truth_congr_agreeFrom`).
  Forward walks from `w` extend backwards by seriality. So `⟐` over walks through `w` is `E` over
  paths from `w`.
- A finite serial Kripke structure becomes a ℤ-task frame by adding a fresh self-looping source
  node before every node that lacks a predecessor. This leaves all future paths unchanged.
  Finiteness gives Saturation, and CTL* has the finite model property.
- Hence the ZTime all-histories logic of TM⁺ conservatively contains full CTL*.
- Any complete axiomatization must therefore do at least Reynolds 2001's work, extended with
  branching past and S/U.

#### 2.5 (a) Candidate additions

| Schema | Status |
|---|---|
| `LC⁺` = `(⟐Xp ∧ ⊡G(p → ⟐Xp)) → ⟐Gp` | valid at ZTime: **compiled** (`lcPlus_valid_full`); not TM⁺-derivable: **compiled countermodel** plus the transcription in §2.3 |
| LC schema family `⊡G(a → ⟐X(b U a)) → (a → ⟐G(b U a))`, with `a`, `b` state-local (`PlusFormula.StateLocal`) | valid at ZTime on paper (Reynolds Lemma 5, transposed; needs `stab_state_only`). **UNVERIFIED** as a compiled statement |
| past mirror of the family | follows by time reflection (TR); **UNVERIFIED** |
| LC⁺ at `.Base` / `.Dense` | at Dense, `X` is degenerate (`¬X⊤`) and LC⁺ is trivially derivable. At Base it is *invalid* on paper: ℤ ×ₗ ℤ time with `R` = `a₀ → a₁ → …`, `aₙ → b`, `b → b`, `b → a₀`, and cross-block durations universal. A forward `a`-run exists within a block, but there is no bi-infinite `a`-walk for the later blocks. **UNVERIFIED** by probe |
| mixed pasting schemata (for example `⟐F⟐Pq → ⟐FPq`) | invalid in general (535 D3 pattern); not needed for the LC failure |

#### 2.6 (b) Naming rules

- 535's candidate is unsound (compiled: `naming_antecedent_unsat`, for every shift-closed bundle,
  hence every full model).
- An IRR-style rule names a time, which is impossible when `H_F` is shift-closed and atoms live on
  states.
- A Reynolds-AA-style rule needs path-dependent fresh atoms. That requires splitting states, which
  changes `⟨τ⟩_t` and so changes the value of `⊡`. Its soundness is therefore doubtful and
  **UNVERIFIED**.
- ANF does not force a rule, because AS is an atom-restricted axiom and TM⁺ has no substitution
  rule (`PlusDerivationTree` constructors: axiom, assumption, MP, necessitation, temporal
  necessitation, time reflection, weakening).
- Whether any complete ZTime system can avoid a rule is **open**. Even for CTL*, Reynolds used AA.

#### 2.7 (c) Indistinguishability route

Closed. `completion_validates` and `lcPlus_refuted` put the same two classes, once with a
paste-closed bundle and once with all walks, on opposite sides of LC⁺. No generalisation of
`fzero_plusValidOn_iff_f1` can identify a bundled canonical model with its completion.

### 3. Bundled fallback (question 3)

- **Semantics.** A bundled model is `(F, B, V)` with `B ⊆ H_F` closed under time shift and splice
  at a shared state, and `□`/`⊡` range over `B`. Equivalently, it is a coarsened-state model whose
  `π`-image is paste-closed (Part F).
- **Soundness of the current `PlusAxiom` set: yes at every class** (§2.3's argument is
  class-uniform; shift-closure gives MF). This is the result 560 Phase 1 lands, as part of the
  incompleteness proof.
- **Completeness: not reachable with modest changes.**
  - *Single-splice lifting.* In a canonical setting where every formula is provably a Boolean
    combination of pure-past and pure-future formulas, PS alone lifts one splice. One takes
    `Θ ⊇ Past(Λ₁(t₀)) ∪ Fut(Λ₂(t₀)) ∪ ⊡-content`, and the splice line's theory is then determined
    at every time. That separation property is derivable at ZTime and RTime (Gabbay separation +
    TM completeness + atomization + substitution back; paper argument, Medium).
  - *ZTime* is not compact. Canonical ℤ-chronicles do not exist through arbitrary MCSs, which is
    why the landed ZTime engine uses finite-depth k-equivalence. A bundled ZTime proof would need a
    Stirling-style finite-closure construction rather than an adaptation of the engine.
  - *Dense (ℚ)*: separation fails, so mixed single splices are not covered by PS/US.
  - Verdict: **CONJECTURED provable at ZTime/RTime, open at Dense/Base; a multi-task research
    project**, not 560.
- **Side observation (Medium, UNVERIFIED, not load-bearing).** Every naive-consistent formula has
  a *non-pasted* coarsened model at each class with a TM engine. The construction atomizes, adds
  the finitely many background instances `□always(T ∧ ¬q_χ → ◇(T ∧ ¬χ))` (which are
  naive-derivable), uses TM completeness, and sets `π := type`. This would make the naive system
  complete for coarsened models.

### 4. Per-class verdict table (question 4)

| Class | All-histories TM⁺ (current axioms) | With additions | Engine to fork / territory | What it gives the next class |
|---|---|---|---|---|
| **ZTime** | **INCOMPLETE**: LC⁺ valid and not derivable (§2) | TM⁺ + LC family (+ possibly an AA-type rule): completeness CONJECTURED, ≥ full-CTL* hardness; no engine to fork (the k-equivalence engine is linear-only); would need a new finite-closure digraph construction | incompleteness: `Metalogic/Independence/` (new `LimitClosure*.lean`), reusing `CoarsenedModels.lean` | the paste-closed coarsened soundness is class-uniform, and so is the countermodel technique |
| **Dense** | UNDETERMINED. LC⁺ is trivial here; a dense limit principle must pass through Extension/Saturation, and separation fails over ℚ | unknown | none | — |
| **Base** | UNDETERMINED. LC⁺ is Base-invalid (paper, §2.5); Base contains both the dense and discrete difficulties plus the three-way split of `completeness` | unknown | none | — |
| **Dedekind (RTime)** | UNDETERMINED; separation holds, but the Doets route is linear-only (535) | unknown | none | — |

Bundled row: sound at all four classes (560 Phase 1). Completeness is CONJECTURED at ZTime/RTime
and open at Dense/Base (§3). Not scheduled.

### 5. Implementation design for task 560 (question 5)

Target theorem: `plus_incomplete_ztime : PlusValidZTime lcPlus ∧ ¬ PlusDerivable FrameClass.ZTime [] lcPlus`,
with `lcPlus := ((dstab (next p)).and (stab (allFuture ((atom p).imp (dstab (next p)))))).imp (dstab (allFuture p))`.
Nothing is added to `PlusAxiom`, so `plus_soundness_validIn`, `forward_plus` and
`plusDerivable_ofFormula_iff` are untouched by construction.

- **Phase 1: paste-closed coarsened soundness** (`Metalogic/Independence/PastedCoarseModels.lean`,
  about 250 lines).
  - Define `CoarseModel.PasteClosed` on `π`-images. This needs a `WorldHistory` splice at equal
    `π`-class, which is image-level and does not reuse `PlusPasting.paste`, since that one needs
    state equality.
  - Port the purity congruences to `CTruthAt` (probe `pf_congr`/`pp_congr` against the repo's
    `truth_congr_agreeFrom`).
  - Add the PS/US arms and their reflected forms.
  - Add a `cValid`-at-class generalisation of `cValid_of_tm` (`axiom_validIn` with a general `fc`
    and frame hypothesis).
  - Soundness recursion: `plusDerivable_pcValid : PlusDerivable .ZTime [] φ → PCValidZTime φ`,
    mirroring `naive_cValid_and_reflect_time`.
- **Phase 2: the frame and the refutation** (`LimitClosureCountermodel.lean`, about 250 lines).
  - Build `cR` as `FrameOver intOrder` via `ofReflective` over `Option ℕ`. Comp, serial and limit
    come from the relational-power presentation and `limit_of_succOrder`. Saturation comes from
    "every nonzero fibre/segment contains `none`" plus singleton zero fibres.
  - Construct the `CoarseModel` with `π := Option.isSome`, show it is `PasteClosed`, and prove
    `¬ CTruthAt … lcPlus` (transcribe probe Parts C, D, F).
- **Phase 3: validity** (`Semantics/PlusLanguage/PlusLimitClosure.lean`, about 250 lines).
  - Prove `lcPlus_plusValidZTime` over any `IsZTime` frame: the probe's `chain`/`limit_walk`
    carried over `WorldHistory` with `PlusPasting.paste`.
  - The limit history is `ofTotal` of the diagonal state function. Its `respects_task` at `(s, s')`
    comes from a single stage that contains both times, via succ-Archimedean induction to reach any
    `s > t` in finitely many steps.
  - `X` semantics: port `next_iff` using `SuccOrder`.
- **Phase 4: assembly and documentation.**
  - Assemble `plus_incomplete_ztime`.
  - Update the metatheory rows in `Metalogic/Conservativity/Plus/README.md` and
    `Metalogic/README.md`: "general TM⁺ completeness: FALSE at ZTime for the current axioms
    (`plus_incomplete_ztime`); completeness of any extension OPEN (≥ full CTL*)". Update the
    dependent TM⋆ row: the "conditional on general TM⁺ completeness" hypothesis is refuted at ZTime.
  - Add an axiom pin (`propext`, `Classical.choice`, `Quot.sound`).
  - No task numbers under `FormalSystem/`.

Soundness obligations for any new constructor: none in 560, because none is added. If a later task
adds `lc` to `PlusAxiom`, the obligations are:

- `minFrameClass := .ZTime`
- a validity arm (Phase 3's lemma) and a reflect-time arm (the past LC)
- `IsNaive := False` for it (it is not coarse-valid: Phase 2 refutes it)
- a re-check that `naiveAxiom_cValid` still pattern-matches exhaustively
- conservativity over TM is preserved, because forward conservativity only uses TM⁺ soundness

## Decisions

1. Settled at ZTime: the current TM⁺ is incomplete over all-histories semantics. This is a result,
   not a blocker.
2. `plus_completeness_ztime` is **not** a 560 target. Completeness of any extension is recorded as
   open, and at least as hard as full CTL*.
3. 560 is rescoped to the incompleteness theorem, with no change to `PlusAxiom`.
4. 535's naming-rule candidate is withdrawn as unsound.
5. The bundled semantics is recorded as sound. Its completeness is not scheduled.

## Risks & Mitigations

- **Risk**: the Saturation proof for the infinite frame `cR` is fiddlier than expected.
  **Mitigation**: the only facts it needs (two-way seriality, `R∘R` universal) are compiled.
  Fallback: a sibling frame with a larger hub set.
- **Risk**: an image-level splice of `WorldHistory` at equal `π`-class needs a history *through a
  chosen state* at the splice time. **Mitigation**: `mem_image_walk` constructs it concretely for
  `cR`. The general `PasteClosed` predicate should be stated at image level, as in the probe.
- **Risk**: the mirror departs from `PlusTruthAt`. **Mitigation**: the clauses are verbatim, and the
  only specialisation is "histories = walks", which is justified above. Phases 2 and 3 re-prove
  everything against the repo semantics.
- **Risk**: LC⁺ turns out derivable through an overlooked rule. **Mitigation**: the soundness
  recursion covers every `PlusDerivationTree` constructor, and every schema is handled by
  atomization (TM) or explicitly (⊡ arms).

## Tactic Survey Results

| Goal | Tactic | Result | Premises/Config |
|---|---|---|---|
| clause lemmas (`and_iff`, `dstab_iff`, `allFuture_iff`) | `simp only [Fm.*, T]` + `tauto` / `by_contra` | success | classical |
| `next_iff` (the witness is the successor) | `obtain rfl : s = t+1 := by by_contra …; omega` | success | omega |
| splice is a walk | `by_cases` on `n+1 ≤ s`, `n ≤ s`, `if_pos`/`if_neg` | success | omega |
| dependent-choice chain | structural `def` returning a subtype, via `Classical.choose` | success | — |
| diagonal limit | `Int.toNat` stage index + `Nat.exists_eq_add_of_le` agreement | success | omega |
| rewriting a bundle inside `T` | `rw` fails (motive: `σ : ℤ → M.C`) | fail | fixed by generalising the set and using `subst` |
| `mem_image_walk` counter arithmetic | `Nat.find_spec` / `Nat.find_min'` | success | omega |

## Context Extension Recommendations

- **Topic**: bundled against all-histories semantics for `⊡`. **Gap**: there is no context note
  saying that limit closure (Reynolds LC) is the separating principle, or that the coarsened-model
  machinery is the tool. **Recommendation**: add a paragraph to
  `Metalogic/Independence/README.md` when 560 lands.

## Appendix

- Probe index (`probes/01_limit-closure-probes.lean`):
  - Clauses: `and_iff`, `dstab_iff`, `allFuture_iff`, `allPast_iff`, `next_iff`
  - A: `IsWalk`, `fullModel`, `paste`, `paste_walk`, `Good`, `good_step`, `chain`, `chain_agree`,
    `limit_walk`, `lcPlus`, `lcPlus_valid_full`
  - B: `PF`, `PP`, `pf_congr`, `pp_congr`, `PasteClosed`, `ps_valid`, `us_valid`
  - C: `finRuns`, `cModel`, `finRuns_pasteClosed`, `finRuns_shiftClosed`, `lcPlus_refuted`,
    `completion_validates`
  - D: `cR`, `cR_to_none`, `cR_from_none`, `cR_two_universal`, `image_walk_mem`, `mem_image_walk`
  - E: `naming_antecedent_unsat`
  - F: `CT`, `imageModel`, `ct_iff_image`, `cR_image_eq`, `lcPlus_refuted_coarse`
  - `#print axioms` (checked in a scratch copy): `propext`, `Classical.choice`, `Quot.sound` only.
    `mem_image_walk` uses `propext`, `Quot.sound`.
- Compile command: bare `lean` from `~/.elan/toolchains/leanprover--lean4---v4.33.0-rc1`, with
  `LEAN_PATH` set to `.lake/packages/*/.lake/build/lib/lean`. Exit 0, warnings only
  (unused variables).
- Literature: `reynolds_2001/sec01_*.md` (lines 60-160), `sec03_*.md` (lines 185-360).

## Literature Proof Structure

**Source**: Reynolds 2001, §6 Lemma 5 (LC soundness) and §8 Theorem 3.
**Strategy**: an inductive path construction (dependent choice) for soundness. Completeness uses a
filtration with automaton-labelled fresh atoms (AA) and banning.

### Step Map
1. Assume `AG(Eα → EX((Eβ) U (Eα)))` and `Eα` at `t₀` (Lemma 5). Lean: the hypotheses of
   `limit_walk`.
2. Inductively choose `t_{k+1} > t_k` along some branch with `Eα` at `t_{k+1}` and `Eβ` between.
   Lean: `good_step` (a single step, because `X`).
3. The branch through all `t_k` is a path of the complete tree. Lean: the diagonal `lim` in
   `limit_walk`, where branches become walks and pasting stands in for tree extension.
4. Completeness (Theorem 3) needs LC plus the AA rule. There is no Lean counterpart; see §2.4 and
   §2.6.

### Dependencies
- Step 3 depends on 2. Our transposition also needs `paste_walk`, the ℤ analogue of tree fusion.

### Potential Formalization Challenges
- Step 3 over a general `IsZTime` frame: building the limit `WorldHistory` needs succ-Archimedean
  induction (Phase 3).
- Step 4: AA's soundness relies on tree-shaped frames, and task frames are not trees.
