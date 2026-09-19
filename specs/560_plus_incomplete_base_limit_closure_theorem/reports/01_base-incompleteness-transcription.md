# Research Report: Task #560

**Task**: 560 - plus_incomplete_base_limit_closure_theorem
**Started**: 2026-09-19T00:58:49Z
**Completed**: 2026-09-19T01:11:14Z
**Effort**: one research dispatch; implementation estimate 4 short phases (about 900-1,100 lines of Lean, most of it already compiled in this round's probes)
**Dependencies**: None (inputs are the task-559 reports 02/03/04 and probes 01/02, all present)
**Sources/Inputs**: - Codebase (`Metalogic/Independence/CoarsenedModels.lean`, `NaiveSystem.lean`, `ForwardDeterministicFrame.lean`, `Semantics/PlusLanguage/{PlusTruth,PlusValidity,PlusPasting}.lean`, `Semantics/{TaskFrame,PartialHistory,PartialHistoryOrder}.lean`, `Semantics/Extension/Extension.lean`, `Metalogic/Conservativity/Plus/{AxiomValidity,PlusSoundness}.lean`, `Conservativity/Star/Forward.lean`, the two READMEs); task-559 reports 02 section 2, 03 section 2.2, 04 section 4.1 and probes 01/02; two new probes compiled with bare `lean` against the repository's own oleans (no `lake` process)
**Artifacts**: - `specs/560_plus_incomplete_base_limit_closure_theorem/reports/01_base-incompleteness-transcription.md` (this report)
  - `specs/560_plus_incomplete_base_limit_closure_theorem/probes/01_blc-base-validity.lean` (169 lines, sorry-free, exit 0)
  - `specs/560_plus_incomplete_base_limit_closure_theorem/probes/02_blc-base-nonderivability.lean` (595 lines, sorry-free, exit 0)
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **Both halves of `plus_incomplete_base` now compile against the LIVE definitions**, sorry-free,
  with axioms `propext`, `Classical.choice`, `Quot.sound` only. Probe 01 proves
  `blc_plusValid : PlusValid (blc p)`; probe 02 proves
  `blc_not_plusDerivable_base : ¬ PlusDerivable FrameClass.Base [] (blc p)`. These are stated
  against `PlusTruthAt`, `WorldHistory`, `CoarseModel`, `CTruthAt`, `PlusDerivationTree`, not
  against the ℤ-mirror of the task-559 probes.
- **The two steps that were "on paper only" are closed.** (i) Base validity of `blc` by Zorn plus
  `PartialHistory.extension` went through on the first compile, via the general lemma report 03
  asked for. (ii) *Saturation* of `eR` went through with one new 12-line helper (a directed
  family with one finite member) plus a "contains the hub or is finite" case split.
- **Report 02's paper argument is correct as written**; no gap appeared. One simplification was
  found: `LCProp` (report 02's `Q`) needs no separate "domain contains `t`" clause beyond the
  anchor, and step 5's dichotomy is a three-line consequence of the down-set clause.
- **A sorry-free path exists for every mandatory phase (1-4).** Implementation is a transcription
  of the probes into four modules plus README edits. No new axiom, no change to `PlusAxiom` or
  `PlusDerivationTree`, no completeness statement.
- **Phase 5 (ZTime) remains optional and unprobed.** It needs a class-indexed variant of
  `cValid_of_tm`/`naiveAxiom_cValid` plus `FrameClass.ZTime.Sat EF`; recommend deferring it.

## Context & Scope

The dispatch asks for research supporting a five-phase implementation of
`plus_incomplete_base : PlusValid blc ∧ ¬ PlusDerivable FrameClass.Base [] blc`. The inputs were
ℤ-specialised mirror probes; the named risk was the transcription against the live semantics, and
the two steps never compiled anywhere. This round therefore did the transcription as probes rather
than describing it. Constraints honoured: no `lake build` was run (another session held builds);
probes import only already-built `FormalSystem` modules and live under `specs/`; nothing under
`FormalSystem/` was edited.

## Findings

### Codebase Patterns

1. **Coarse soundness is reusable unchanged.** `naiveAxiom_cValid` and
   `naiveAxiom_cValid_reflect_time` (`CoarsenedModels.lean:470,567`) cover every naive arm at
   `.Base`. `PlusAxiom.IsNaive` is `False` exactly on `paste` and `untl_paste`. So the paste-closed
   dispatch is `by_cases hn : IsNaive ax`; the naive branch cites the landed lemmas, the other
   branch is a two-arm `cases`. The derivation recursion is `naive_cValid_and_reflect_time`
   (`:691`) with the `NaiveOnly` argument deleted and a `PasteClosed` hypothesis threaded; the
   `termination_by`/`decreasing_by` block copies verbatim.
2. **The right `PasteClosed` is image-level**, as the dispatch says:
   `∀ ρ σ t, SameUnder K ρ σ t → ∃ η, (∀ s ≤ t, π(η s) = π(ρ s)) ∧ (∀ s ≥ t, π(η s) = π(σ s))`.
   Both clauses include `t`; that is consistent because of the `SameUnder` hypothesis and it
   removes a case split from every consumer.
3. **Purity congruences for `CTruthAt` hold at the `π`-image level**, not just at state equality:
   the atom case is `K.atom_inv_iff`, `box` is `Iff.rfl`, `stab` rewrites the `π`-equation at `t`.
   These are `truth_congr_agreeFrom`/`agreeUpTo` (`PlusPasting.lean:152,177`) with
   `τ.state s = σ.state s` replaced by `K.π (τ.state s) = K.π (σ.state s)`.
4. **Reflected arms**: `AxiomValidity.lean:292-297` shows the normal form:
   `simp only [PlusFormula.reflectTime, reflect_time_dstab, reflect_time_and]` then the primed
   lemma at `h0.reflectTime h1.reflectTime`. The same two lines work in the coarse dispatch.
5. **ℤ-frame construction pattern**: `ForwardDeterministicFrame.lean:102-227` (`fnRel`,
   `fnFrameOver`, `FN`, `fn_taskRel_iff`). A two-sided relation with a reflection law, the four
   bare-relation axioms, then a literal `@[reducible] FrameOver (TemporalOrder.of ℤ)` whose fields
   cite `TaskFrame.*_reflect_of_reflective`. `@[reducible]` is required or `WorldState` does not
   reduce to the carrier. *Limit* is `TaskFrame.limit_of_succOrder (D := ℤ)`.
6. **Zorn infrastructure is complete**: `PartialHistory` is a `Preorder`; `chainSup`,
   `le_chainSup`, `chain_states_agree`, `extension` are landed. `zorn_le_nonempty₀` has the shape
   needed (`Maximal (· ∈ s) m` on a preorder gives `∀ ν ∈ s, m ≤ ν → ν ≤ m`).
7. **No restriction API exists** for `WorldHistory` to a down-set; a 5-line `restrictIic` is new.
8. **Order-coercion friction (the only recurring compile issue).** On `EF`, times bound by a
   definition have type `EF.Duration.carrier`; `omega` does not see through it. Fixes that
   worked: state helper lemmas with `(t : ℤ)` binders and apply them; `sub_pos.mpr h` /
   `sub_neg.mpr h` instead of `by omega`; `show (t : ℤ) < t + 1 by omega`; `Int.lt_succ s`.

### External Resources

- Mathlib: `zorn_le_nonempty₀`, `IsChain.total`, `Set.eq_of_subset_of_ncard_le`, `Nat.find`,
  `Set.Finite.subset`, `Finset.finite_toSet`, `Finset.Ioo`/`filter`/`card_lt_card` (all verified
  by compilation at the pinned Mathlib).
- Literature: Burgess / Thomason (1984, "Combinations of Tense and Modality") for the formula
  `□G(p → ◇Fp) → ◇G(p → Fp)` separating full from bundled Ockhamist validity. Used only for
  attribution in the module docstring; the proof followed is report 02's six-step argument.

### Recommendations

**Module layout (4 new files, 2 aggregator lines, 3 READMEs).**

| Phase | File | Content (names as compiled in the probes) |
|---|---|---|
| 1 | `Metalogic/Independence/PastedCoarseModels.lean` | `CoarseModel.PasteClosed`, `c_truth_congr_from`, `c_truth_congr_upTo`, `c_paste`, `c_paste'`, `c_untl_paste`, `c_snce_paste`, `PCValid`, `plusAxiom_pcValid`, `plus_pcValid_and_reflect_time`, `not_plusDerivable_of_pcRefuted` |
| 2 | `Metalogic/Independence/LimitClosureCountermodel.lean` | `eR`, `eπ`, `eR_trans/dense/succ`, `eRel` + `eRel_zero/pos/neg/reflection/serial/comp/limit`, `sInter_nonempty_of_directed_of_finite_mem`, `eR_fwd_finite`, `eRel_fib_hub_or_finite`, `eRel_seg_hub_or_finite`, `eRel_saturation`, `eFrameOver`, `EF`, `ef_taskRel_iff`, `IsWalk`, `isWalk_state`, `walk_lt`, `histOfWalk`, `evFalse`, `eR_budget`, `eR_evFalse_aux`, `eR_image_mem`, `mem_eR_image`, `eK`, `eK_pasteClosed`, `blc_cRefuted` |
| 3 | `Semantics/PlusLanguage/PlusLimitClosure.lean` | `exists_maximal_of_chainClosed` (the general lemma), `restrictIic`, `LCProp`, `lcProp_restrictIic`, `lcProp_chainSup`, `limit_history`, `blc`, `blc_plusValid` |
| 4 | `Metalogic/Independence/PlusIncompleteness.lean` | `plus_incomplete_base`, corollary `not_plus_complete_base : ¬ ∀ ψ, PlusValidIn .Base ψ → PlusDerivable .Base [] ψ` (the exact hypothesis of `starConservative_of_plusComplete`), axiom pin, README edits |

Placement notes for the planner:
- `blc` must be defined in the Phase-3 file (Semantics layer), since Phase 2's refutation and
  Phase 4 both import it. Phase 2 therefore imports `PlusLimitClosure`; if the planner keeps the
  dispatch's phase order (1, 2, 3), define `blc` in a tiny leaf or move Phase 3 before Phase 2.
  **Recommended order: 1, 3, 2, 4.** Phases 1 and 3 are independent of each other.
- `sInter_nonempty_of_directed_of_finite_mem` is frame-agnostic and belongs beside
  `saturation_of_fib_finite` in `Semantics/TaskFrame.lean`; keeping it local to the Phase-2 file
  is acceptable if touching `TaskFrame.lean` (2,358 lines, heavy rebuild fan-out) is unwanted.
  Recommend local first.
- The general lemma and `restrictIic` are language-independent; `Semantics/Extension/` would be
  the natural home. The dispatch names `Semantics/PlusLanguage/`; keep them there unless the
  planner wants the cleaner split. Either compiles (imports are `Extension.Extension` +
  `PlusPasting`).
- Register new modules in `Metalogic/Independence.lean` and `Semantics/PlusLanguage.lean`
  (C24: both already reach `FormalSystem.Init` transitively through their imports).
- Replace `| _ => exact absurd trivial hn` in `plusAxiom_pcValid` if the no-wildcard dispatch
  convention is enforced; it is safe here because a future naive constructor lands in the first
  `by_cases` branch and a future non-naive one fails the `absurd`.
- LC_n at Base: `exists_maximal_of_chainClosed` is stated for an arbitrary chain-closed `Q`, so it
  supports that instance, but the LC_n proof also needs an ω-chain seed. It does not fall out for
  free; per the dispatch, do not state it.

**README rows (Phase 4).** `Metalogic/Conservativity/Plus/README.md:15,64` and
`Metalogic/README.md:276,302`: completeness of the current TM⁺ axioms is FALSE at Base;
completeness of any extension is OPEN at every class; the conditional TM⋆-over-TM⁺ row's
hypothesis is refuted at Base. One-line reading from report 04 section 4.1: the coarsened
countermodel is a dense, non-closed bundle; PS and US say paste-closed, MF says
translation-closed, nothing says closed. Add `Independence/README.md` file-table rows.

**Consistency check for the module docstring.** Under `⊡ = id`, `blc` reduces to
`(Fp ∧ G(p → Fp)) → (Fp ∧ G(p → Fp))`, a TM⁺ + *Determined* theorem; and `EF` is necessarily
nondeterministic (`none → x` for every `x`).

**Phase 5 (optional).** Not probed. Requires (a) `CValidIn fc` / a `fc.Sat F` hypothesis threaded
through `cValid_of_tm`, both dispatch lemmas and the recursion, with the three ZTime arms
(`prior_UZ`, `prior_SZ`, `z1`) via `axiom_validIn` at `.ZTime`; (b) `FrameClass.ZTime.Sat EF`
(`TaskFrame.IsZTime`, a four-component discreteness bundle on `ℤ`). Recommend a separate task.

## Decisions

- Probes were compiled against live oleans with bare `lean`, not `lake`, because another session
  was building; no build guard was needed and no olean was written.
- `PasteClosed` is a `def` on `CoarseModel`, not a structure field, so `CoarseModel` and every
  landed consumer stay untouched.
- The valuation of `eK` reads every atom on the `true` class, as in the mirror; `atom_inv` is then
  a rewrite.
- No `user_decision` is raised: nothing here needs the user's judgment.

## Risks & Mitigations

- **Risk**: probe code drifts from what lands. **Mitigation**: the probes are in the task
  directory and compile today; the plan should copy declarations, then restyle.
- **Risk**: linter / docstring requirements (`docBlame`, 100-column, no task numbers under
  `FormalSystem/`). **Mitigation**: probe headers deliberately avoid being copy-ready; every
  landed declaration needs a docstring and the `Probe560` namespace must go.
- **Risk**: C2/C14 axiom baselines. **Mitigation**: pin `plus_incomplete_base` with the measured
  profile `[propext, Classical.choice, Quot.sound]`.
- **Risk**: concurrent sessions are modifying `FormalSystem/Metalogic/README.md` right now
  (uncommitted, not from this task). **Mitigation**: Phase 4 must re-read before editing and stage
  only its own files by explicit path.
- **Process note**: during this dispatch an unquoted shell heredoc caused bash to evaluate
  backticked identifiers in a Python string. Every resulting command was `command not found`, a
  directory, or a bare `lean`/`paste` (usage text; one stdin hang, which was this agent's own
  child and was killed). No file was written and no build ran. The save was redone with a quoted
  heredoc.

## Literature Proof Structure

**Source**: task-559 report 02, section 2 (validity argument), after Burgess / Thomason 1984.
**Strategy**: Zorn over a chain-closed property of partial histories, then the Extension Theorem,
then a maximality contradiction by one paste.

### Step Map
1. Define `Q` (`LCProp`): down-set domain; anchored at `(t, σ t)`; has a `p`-point after `t`;
   every `p`-point after `t` has a later one in the domain or is the domain's maximum.
2. `Q` is nonempty: restrict the `⟐Fp` witness to `(-∞, s₀]` (`lcProp_restrictIic`).
3. `Q` is closed under chain unions (`lcProp_chainSup`).
4. Zorn + `extension` (`exists_maximal_of_chainClosed`): a `Q`-maximal `μ*` and a total `τ ⊇ μ*`.
5. If `G(p → Fp)` fails at `f` on `τ`, then `dom μ* ⊆ (-∞, f]`.
6. The antecedent at `(τ, f)` gives `η`, `s' > f`; `paste τ η f` restricted to `(-∞, s']` is in
   `Q` and strictly extends `μ*`. Contradiction.

### Dependencies
- 4 depends on 2, 3. 5 depends on 1 (down-set, recur). 6 depends on 4, 5 and `PlusPasting.paste`
  at its current total-history signature.

### Potential Formalization Challenges
- None remaining: all six steps are compiled in probe 01. Dependent `states x hx` arguments were
  handled by stating `p`-points as `∃ hx : μ.domain x, P (μ.states x hx)` and rewriting along
  `Extends.agree`.

## Tactic Survey Results

| Goal | Tactic | Result | Premises/Config |
|------|--------|--------|-----------------|
| `eRel_zero/pos/neg/reflection` sign cases | `omega` | success | after `unfold eRel; rintro` |
| `0 < t - s` from `s < t` on `EF.Duration` | `omega` | fail | carrier not unfolded; use `sub_pos.mpr h` |
| `t < t + 1` on `EF.Duration` | `omega` | fail bare, success under `show (t : ℤ) < t + 1` | `Int.lt_succ` also works |
| chain-closure "not max" case | `push Not` | success | `push_neg` is deprecated at this pin |
| `evFalse` membership of indicator sequences | `simp` | success | `[h1, h2]` disequalities from `omega` |
| finite forward fibre | `simp only` | success | `Finset.coe_image, Set.mem_image, Finset.mem_product, Finset.mem_range` |

## Context Extension Recommendations

- **Topic**: `omega` against `TemporalOrder.of ℤ` carriers.
- **Gap**: no context file records that `omega` cannot see through `F.Duration.carrier` on a
  concrete ℤ-frame, nor the four workarounds in Codebase Patterns item 8.
- **Recommendation**: a short entry in the lean4 extension's patterns directory (source store:
  `agent-system/extensions/lean/`), not under `.claude/`.

## Appendix

- Compile recipe: `LEAN_PATH=.lake/build/lib/lean:<each .lake/packages/*/.lake/build/lib/lean>`
  with `~/.elan/toolchains/leanprover--lean4---v4.33.0-rc1/bin/lean <file>`; each probe compiles in
  a few seconds; exit 0.
- `#print axioms`: `blc_plusValid`, `blc_not_plusDerivable_base`, `EF`, `histOfWalk`,
  `not_plusDerivable_of_pcRefuted`: `[propext, Classical.choice, Quot.sound]`.
- Searches: codebase grep only; no rate-limited Mathlib search was needed (every Mathlib name was
  verified by compilation).
- Not verified this round: Phase 5; a full `lake build FormalSystem`; module-invariant script.
