# Implementation Summary: Re-base Rabinovich Section 5 onto the faithful Dedekind carrier

- **Task**: 378
- **Plan**: `specs/378_rebase_section5_onto_faithful_dedekind_carrier/plans/01_faithful-dedekind-section5-rebase.md`
- **Status**: COMPLETED — 9 of 9 phases, each closed in one agent run, no phase re-split, no phase blocked
- **Session**: `sess_1785164194_b6cbfb`
- **Date**: 2026-07-27

## What the task was

Rabinovich's Section 5 (2014, *A Proof of Kamp's Theorem*, PDF pp.7-11) was already transcribed in
this tree under `EANegationFix/`, but at the **strictly-too-strong** `HasAttainedINF` /
`HasAttainedSUP` carrier. That carrier provably deletes the paper's printed disjunct (2)
`K⁺(P₁)(z₀) ∧ Oₙ(P₂,…,Pₙ,z₀,z₁)` (PDF p.8) — machine-refuted by `hasDefinableINF_excludes_kplus`
(`Lemma53.lean:290`), which shows even the *weaker* `HasDefinableINF` is already too strong.

Rabinovich states Proposition 4.2 **over Dedekind complete chains** (PDF p.6, in the statement
itself). This task re-based the chain onto the faithful `HasDedekindINF` carrier
(`DedekindINF.lean:136`) so that the transcription assumes what the paper assumes.

## What landed

**9 new live modules, 133 declarations, 3,608 lines, 0 sorries, all axiom-clean.** Nothing was
deleted; the attained stack in `EANegationFix/` is untouched, still live, and still consumed.

| Phase | Module | Decls | Rabinovich (PDF page) |
|---|---|---|---|
| 1 | `Kamp/Lemma53Faithful.lean` | 13 | Lemma 5.3, printed **three**-disjunct `Oₙ₊₁`, disjunct (2) restored (p.8) |
| 2 | `Kamp/Lemma53FaithfulPast.lean` | 11 | Lemma 5.3 `HasDedekindSUP` / Since mirror, `K⁻` primitives (p.8) |
| 3 | `Kamp/VecEACombinators.lean` | 8 | Lemma 3.4 / Cor 5.4 plumbing: `conjEverywhere`, `concatPin` (pp.6, 9) |
| 4 | `EANegationFixFaithful/BoundedFixFaithful.lean` | 14 | Cor 5.4(1)/(2) — **the migration canary** (p.9) |
| 5 | `EANegationFixFaithful/BoundedFixAnchoredFaithful.lean` | 10 | Cor 5.4 anchored bounded-fix mirrors (pp.9-10) |
| 6 | `EANegationFixFaithful/NegFixOneFaithful.lean` | 39 | Lemma 5.1 base case at `n = 1` (pp.9-10) |
| 7 | `EANegationFixFaithful/NegFixListFaithful.lean` | 19 | Lemma 5.1 `Aᵢ`/`Bᵢ` split + closing induction (pp.10-11) |
| 8 | `EANegationFixFaithful/VecEANegFixFaithful.lean` | 11 | Prop 4.2 / 4.3 De Morgan lift chain (p.6) |
| 9 | `Kamp/Prop42Faithful.lean` | 8 | **Prop 4.2 itself, at the faithful carrier** (p.6) |

Plus, per phase, one import edge and NOTE in `Kamp/NfMultiAnchorBridge.lean` (liveness), and in
Phase 9 the correspondence-table extension in `Kamp/Section5Correspondence.lean`.

### The headline result

```lean
theorem prop42_contentful_of_dedekind
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_INF : HasDedekindINF M atomMap) (v : VVecEA2) :
    Prop42Contentful M atomMap v
```

This discharges the **same** `Prop42Contentful` target (`Prop42Contentful.lean:151`) that
`prop42_contentful_of_attained` (`Section5Correspondence.lean:128`) discharges, but from
`HasDedekindINF` **alone** where that one needs `HasAttainedINF` **and** `HasAttainedSUP`.

## Measured final gates

| Gate | Baseline (pre-Phase 1) | Final (post-Phase 9) |
|---|---|---|
| `lake build` exit | 0 | **0** |
| Jobs | 1883 | **1892** (+9, exactly +1 per phase) |
| Live modules from `FormalSystem.lean` | 269 | **278** (+9) |
| Tactic-position sorries in `Kamp/` | 4 dead / 0 live | **4 dead / 0 live** (unchanged) |
| Tactic-position sorries in the 9 new modules | — | **0** |
| Real `axiom` declarations in `FormalSystem/` | 0 | **0** |
| `AggregateOffDiagK1` explicit build | 1098 jobs, EXIT 0 | **1098 jobs, EXIT 0** |
| `EANegationFix/` (attained stack) | live | **untouched, still live** |

Sorry census is tactic-position via `.claude/scripts/lean-sorry-census.sh`, never `grep -c`. The 4
dead sorries are all under `Kamp/Boneyard/` and were pre-existing:
`EndpointNegation.lean:164`, `FOToVEA.lean:122`, `EANegationVBracketBackward.lean:452`, `:611`.
Liveness is by transitive `import` walk from `FormalSystem.lean` (no `Boneyard` module is live);
`lake build BoneyardArchive` was never run or cited, since it passes vacuously.

**Axiom-count caveat, recurring every phase.** A bare `grep -c '^axiom ' FormalSystem/` returns
**2**. Both are prose continuation lines inside `Boneyard/` comments
(`Boneyard/DiscreteXY/Discreteness.lean:40`; `Boneyard/StrictSemanticsLegacy/Bundle/SuccChainFMCS.lean:1233`).
Neither is a declaration. **Real axiom count: 0.** All 133 new declarations verify as subsets of
`[propext, Classical.choice, Quot.sound]`; `prop42_faithful_unobservable_on_prior` needs only
`[propext]`.

**Jobs/modules discrepancy, recorded rather than silently matched.** The plan projected **1891
jobs / 277 live modules** as the terminal figure. That projection was one low — it counted 8 new
modules while its own Artifacts section listed 9 paths, and it predated Phase 5's anchored mirrors
being counted as their own module. The measured terminus is **1892 / 278**.

## Non-vacuity: what this EXCLUDES, machine-checked

An over-strong hypothesis, a vacuous conclusion, and a `⊤`-collapsed or dropped witness all pass
sorry-free, axiom-clean and EXIT 0 exactly as a contentful theorem does. This failure mode had
already recurred three times in this development undetected, so every phase carried an exclusion
artifact. The final ones:

1. **Wrong quantifier order** — `prop42Faithful_perPoint_is_VACUOUS` proves the per-point `∃ v'`
   ordering from **no carrier hypothesis at all**. Negative control recorded verbatim:
   `prop42Faithful_perPoint_is_VACUOUS M atomMap v` does **not** typecheck against
   `Prop42Contentful M atomMap v` — a hard type mismatch. The compiler certifies that hoisting
   `∃ v'` outside `∀ z₀ z₁` is the actual content.
2. **`⊤`-collapsed witness** — `⟨topVVec, fun _ _ _ => Iff.rfl⟩` does **not** typecheck against
   `Prop42Contentful`; upstream, `topVVec_contentful_forces_unsat` (`Prop42Contentful.lean:229`)
   shows offering the all-`⊤` formula commits the offerer to `v` being unsatisfiable everywhere.
3. **Hollow witness (the failure specific to the final phase)** — `Prop42Contentful` existentially
   quantifies the witness, so a construction that had silently dropped the paper's Case 1 gate
   would prove the headline theorem *verbatim*. Closed by
   `prop42_witness_exposes_negFixFaithful` (names the witness as `v.negFixFaithful`) and
   `prop42_witness_carries_limit_gate` (proves the `K⁺(¬β₁)(z₀)` gate, PDF p.9, still fires in it).

Earlier phases contributed the same discipline: `lemma53Faithful_perPoint_is_VACUOUS`
(`Lemma53Faithful.lean:354`), `VecEA2.mem_negFixFaithful_disjuncts` (verbatim disjunct survival — a
lemma the attained lift *cannot state*), `VecEA2.negFixFaithful_carries_limit_gate`, and
`negFixListFaithful_case1_is_indispensable`.

## The `HasDedekindSUP` non-consumption verdict (Phases 4-9)

`HasDedekindSUP` was **dropped in six consecutive phases** — 4, 5, 6, 7, 8 and 9. Every faithful
`_iff` in the chain assumes `HasDedekindINF` and nothing else: the fold, the recursion, the
anchored mirrors and the bounded fixes touch no supremum, no `K⁻`, and no last-occurrence point.
`orderedPointsExist_combine_kminus` and `HasDedekindSUP.last_occ_tp` remain unconsumed.

This was reported at every phase boundary and **no use was contrived** for symmetry — adding
`HasDedekindSUP` to any of these statements would have been an unused hypothesis and a
strengthening that buys nothing. Phase 2 retains independent value: `Lemma53FaithfulPast.lean` *is*
consumed in Phase 9, but for its `K⁻` **exclusion** theorem
(`prior_makes_kminus_disjunct_unreachable`), which is a genuine use.

The payoff is recorded concretely by `prop42_contentful_of_attained_inf_only`: the previously
landed `prop42_contentful_of_attained` is now a corollary whose `HasAttainedSUP` argument is
**unused**.

## Plan Deviations

- **Phase 4 (altered)** — the faithful bounded fix returns `VVecEA2`, not `VBracketFormula`: the
  paper's point condition could not be written in the landed type and was re-encoded. This was the
  migration canary firing as designed.
- **Phase 8 (altered)** — the bracket leg is spliced **verbatim**, with no `List.map` under `⊤`
  endpoints. The attained `VecEA2.negFix`'s map exists only because a `VBracketFormula` disjunct
  has no endpoint slots; reproducing it would have `⊤`-erased `kplusLeftBlock`'s left-endpoint
  condition — i.e. deleted the limit gate at the lift.
- **Phase 9 (altered)** — `Prop42Faithful.lean` additionally imports `Kamp.Lemma53FaithfulPast`,
  required to execute Phase 9's own Verification bullet demanding the cumulative statement cover
  "disjunct (2) **and its dual**". Cycle-free.
- **Phase 9 (altered)** — `Section5Correspondence.lean` edits went beyond appending rows: two
  statements in its existing "What the carrier EXCLUDES" section went stale the moment this phase
  landed (the strengthening-chain diagram marked only `HasAttainedINF` as landed; one sentence
  still read "Building the faithful carrier is separately owned"). Both corrected in place. **No
  existing row deleted or renumbered.**
- **Phase 9 (altered)** — stale citation `DedekindINF.lean:167` → `:172` (true line of
  `HasAttainedINF.toHasDedekindINF`) corrected in three files; comment-only, no declaration
  touched. The stale number originated in the plan and had propagated into Phases 7-8.
- **Cross-phase (recorded, not corrected in place)** — line-number and path discipline caught drift
  three times: a wrong *path* in Phase 8 (the attained lift is `EANegationFix/VecEANegFix.lean`,
  not `Kamp/VecEANegFix.lean`) and line drift in Phases 7 and 9. Re-confirming by `grep -n` before
  each edit stayed cheap and is worth keeping.

No plan step was skipped, deferred, or substituted. No phase was blocked. No strategic `sorry` was
landed; the sorry gate admitted zero.

## What this EXCLUDES / what remains

**This is not Rabinovich's Proposition 4.2 simpliciter, and must not be cited as such.** The
strengthening chain, weakest to strongest:

```
Rabinovich's Dedekind completeness  <  HasDedekindINF  <  HasDefinableINF  <  HasAttainedINF
                                            ^ NOW LANDED              previously landed terminus ^
```

Two of the three steps were closed by this task. **One remains open**: `HasDedekindINF` is still a
hypothesis *about the structure*, not a derivation from Dedekind completeness of the order.
Deriving it from order completeness alone is not attempted anywhere in this tree.

**The gain is real but not yet observable.** `prop42_faithful_unobservable_on_prior`
(`Prop42Faithful.lean`) proves that on every structure which is a Prior structure in both
directions, the restored disjunct (2) `K⁺(P)(z₀)` **and** its Since dual `K⁻(P)(z₁)` are **both
provably dead**. Every live consumer in this tree is such a structure. So:

- the faithful carrier is strictly weaker, and that is machine-checked;
- no current consumer can observe the difference, and that is *also* machine-checked;
- observability arrives only with a genuinely non-attained Dedekind-complete frame class.

**This development does not build such a frame class.** The paper's own witness is `ℝ` with `P₁`
interpreted as `{x | x > 0}` and `z₀ = 0`: `inf{z ∈ (0,1) | P₁(z)} = 0 = z₀`, so no `r₀ > z₀` has
`¬P₁` below it, while `ℝ` *is* Dedekind complete and the paper covers it via disjunct (2).
Constructing that as a frame class is the next fidelity milestone and is owned by no module here.

**Also out of scope, and deliberately untouched.** The model-independent Proposition 4.2 backward
direction at the `BracketFormula` level remains ruled **unfixable** (three-strikes prohibition;
`Boneyard/NegationIndep.lean:346-364` and a concurring independent analysis). No attempt was made
in any phase — `EANegation.lean` and `Boneyard/EANegationVBracketBackward.lean` were not read,
referenced, or edited. The faithful chain confirms rather than refutes that ruling: the INF anchors
are precisely what make the direction go through.

## Source-citation discipline

Rabinovich is cited **by PDF page only**, from
`~/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.pdf`. The
companion `.md` conversion is **corrupt** — it drops displayed equations and inverts `k ≠ m` to
`k = m` — and was never used as ground truth. Every new declaration carries a PDF-page source
correspondence in its docstring.
