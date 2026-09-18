# Research Report: Task #559 (review of report 01)

**Task**: 559 - nondeterministic_canonical_model_tm_star_completeness
**Started**: 2026-09-18T21:30:00Z
**Completed**: 2026-09-18T22:59:43Z
**Effort**: one review session (interactive, not an orchestrated dispatch)
**Dependencies**: report 01 of this task and its probe file; 535 (archived), 533, 536, 537 as in report 01
**Sources/Inputs**:
- Report under review: `reports/01_nondeterministic-canonical-model.md`, `probes/01_limit-closure-probes.lean`
- Codebase, read against the report's setup claims: `Syntax/PlusLanguage/{Axioms,Formula}.lean`, `Semantics/PlusLanguage/{PlusTruth,PlusValidity}.lean`, `Semantics/{TaskFrame,PartialHistory}.lean`, `Semantics/Extension/{README.md,Extension.lean}`, `Metalogic/Independence/CoarsenedModels.lean`
- Paper text as pinned in `docs/reference/paper-definitions-of-record.md` (`def:world-history`, the `($\Box$)` clause, `def:frame`)
- A compiled Mathlib-only probe (bare `lean`, pinned toolchain and Mathlib oleans, no `lake` process, no `FormalSystem` import)
**Artifacts**:
- `specs/559_nondeterministic_canonical_model_tm_star_completeness/reports/02_review-base-incompleteness.md` (this report)
- `specs/559_nondeterministic_canonical_model_tm_star_completeness/probes/02_review-base-limit-closure.lean` (918 lines: the 01 probe verbatim plus Part G; sorry-free; exit 0)
**Standards**: report-format.md

## Executive Summary

- **Report 01's headline is confirmed.** TM⁺ is incomplete over the paper's all-histories semantics
  at ZTime, witnessed by `LC⁺`. The semantics mirror, the axiom mirror, the coarsened-model route and
  the countermodel all check out against the repository. The 01 probe recompiles sorry-free.
- **Report 01's Base verdict ("UNDETERMINED") is too weak.** The X-free formula
  `BLC := (⟐Fp ∧ ⊡G(p → ⟐Fp)) → ⟐(Fp ∧ G(p → Fp))` is valid at `.Base` (paper argument, via the
  Extension Theorem) and is refuted in a paste-closed coarsened model on a ℤ-frame (compiled). So the
  current TM⁺ is incomplete at `.Base` as well, and a second time at `.ZTime`.
- **The missed point is the role of Saturation.** Report 01 treats Saturation as a side condition on
  frame construction. But Saturation yields the Extension Theorem, and the Extension Theorem makes
  limit closure valid at every order type. Choosing the time order, the usual escape at Base, does
  not avoid it.
- **Status of the Base claim.** Two steps are on paper only: Base validity of BLC (Zorn plus
  `extension`) and Saturation of the new countermodel frame `eR`. Everything else is compiled.
- **Dense and RTime.** BLC is valid there too. Non-derivability needs a dense saturated countermodel,
  which is sketched here but UNVERIFIED. Incompleteness at those classes is likely, and open.
- **Recommendation.** Retarget task 560 at BLC, instead of or alongside LC⁺. One formula then settles
  Base and ZTime, and the `.Base` non-derivability needs less new machinery than report 01's target.

## Context & Scope

The user asked for a review of report 01 with attention to mistakes in the assumptions or setup, and
for what completeness of TM⁺ would require at Base and at the extension classes. The review read
every setup claim of report 01 against the source it cites, recompiled its probe, and then looked for
what report 01 left undetermined. Constraints carried over from report 01: no `lake build`, probes
import Mathlib only, never a sorried completeness theorem, every unchecked claim labelled.

**Which semantics the arguments use.**

- The validity claims (LC⁺ at ZTime, BLC at Base) are about the paper's total-histories semantics.
  `□` and `⊡` in `PlusTruthAt` quantify over `WorldHistory F`, which is
  `{τ : PartialHistory F // τ.IsTotal}`. The pinned `def:world-history` defines `H_F` as exactly
  this: a possible world is a history with domain `X = D`. Partial and convex histories never enter
  a truth clause.
- The non-derivability claims deliberately use a different semantics, the coarsened-state models of
  `CoarsenedModels.lean`. `□` still ranges over all total histories of a genuine task frame, and `⊡`
  is reinterpreted over `π`-classes. This is the standard method: soundness of TM⁺ in the
  non-standard class, one refuting model, hence non-derivability. A countermodel in the paper's own
  semantics is impossible, because the formulas are valid there.
- The compiled probes are not `PlusTruthAt`. They are a ℤ-specialised mirror in which `H_F` is the
  set of bi-infinite `⇒₁`-walks. The identification is exact over ℤ (see Findings 1). Validity
  against the real `PlusTruthAt` is still to be proved in both cases.
- One limit on this check: the paper's `($\Stability$)` clause is recorded in the repository only in
  paraphrase (`def:BLstar-semantics` is LIVE-UNPINNED). The `⊡` clause was checked against the
  repository's transcription and docstrings, not against the paper source. `($\Box$)` and
  `def:world-history` are pinned verbatim and match.

## Findings

### 1. Setup claims of report 01, checked

| Claim | Verdict | Evidence |
|---|---|---|
| The probe's `T` mirrors `PlusTruthAt` clause for clause | confirmed | `PlusTruth.lean:82-91`: `⊡` over total histories sharing the state at `t`; `untl ψ φ` strict with `φ` the eventuality; `next := untl ⊥` (`Formula.lean:174`) |
| Over ℤ, `H_F` is the set of bi-infinite `⇒₁`-walks | confirmed | `Compositional` is the biconditional (`TaskFrame.lean:595`), so `⇒ₙ = (⇒₁)ⁿ`; `WorldHistory.respects_task` covers all pairs, negative durations by the converse convention |
| `PF`/`PP` mirror `IsPureFuture`/`IsPurePast` | confirmed | `Formula.lean:299-313`; both allow `□ψ` and `⊡ψ` as leaves for arbitrary `ψ` |
| PS and US are as stated; US does not encode limit closure | confirmed | `Axioms.lean:300-305`; both are finite-splice principles |
| `CoarseModel`/`CTruthAt` are the right soundness vehicle | confirmed | `CoarsenedModels.lean:97-107`; atoms are `π`-invariant by `atom_inv`, which is what the probe's `V (π (σ t))` encodes |
| The soundness recursion covers every rule, including time reflection | confirmed | paste-closure is symmetric in its two arguments, so the reflected PS and the reflected US (SS) hold by the same splice with roles exchanged |
| `cR` satisfies Saturation | confirmed on paper | see below; report 01 also leaves this on paper |
| 535's naming rule is unsound | confirmed, one step implicit | the probe shows the antecedent unsatisfiable; deriving `⊥` also needs `q ∧ □G¬q → ⊥` derivable, which holds because it is TM-valid and TM is complete |
| ZTime frames are ℤ up to isomorphism | confirmed | `Axioms.lean` frame-class docstring (categoricity of `ZTime`); transport along the isomorphism is not written anywhere |

**Saturation of `cR`.** Every fibre of nonzero duration contains `none`, since `none → x` and
`x → none` for all `x`. Every segment with both offsets positive contains `none` for the same
reason. Fibres of duration zero and segments with a zero offset are subsingletons. A ⊇-directed
family of nonempty members therefore either contains a singleton `{w}`, in which case directedness
puts `w` in every member, or consists of members that all contain `none`.

**Overstatement in report 01.** Its summary says every step is "already in the repo or
machine-checked". Three are not: Saturation of `cR` (paper, correct), the `.ZTime` generalisation of
`cValid_of_tm` (not written), and the reflected PS/US arms (not compiled). All three are routine.

### 2. Base incompleteness: the formula BLC

`BLC := (⟐Fp ∧ ⊡G(p → ⟐Fp)) → ⟐(Fp ∧ G(p → Fp))`, with `p` an atom. It is the Burgess/Thomason
formula `□G(p → ◇Fp) → ◇G(p → Fp)`, which separates full from bundled Ockhamist validity, transposed
to `⊡`. It contains no `X`, so it is not confined to discrete time. Report 01's `LC⁺` is
Base-invalid (its own §2.5); BLC is the Base-valid replacement.

**Validity over every full ℤ-model: compiled.** `limit_walkB` and `blc_valid_full` (probe 02, lines
726 and 770). The stage invariant carries a marker time `c` that is a `p`-point, with every earlier
`p`-point after `t` followed by a `p`-point at or before `c`. Each step pastes a witness at `c`. The
markers grow by at least one per step, so the diagonal limit is total.

**Validity at `.Base`: paper argument, checked carefully, UNVERIFIED in Lean.** Fix a frame over any
temporal order, a model, and `(σ, t)` satisfying the antecedent.

1. Let `Q(μ)` hold of a partial history `μ` when: its domain is a down-set containing `t`;
   `μ(t) = σ(t)`; the domain contains a `p`-point after `t`; and every `p`-point `x > t` in the
   domain either has a later `p`-point in the domain or is the maximum of the domain.
2. `Q` is nonempty: `⟐Fp` gives `τ₀` through `σ(t)` with a `p`-point `s₀ > t`, and `τ₀` restricted to
   `(-∞, s₀]` satisfies `Q`.
3. `Q` is closed under unions of chains in the extension order. If `x` is the maximum of one member
   but not of the union, a larger member contains a point above `x`, and there `x` is not the
   maximum, so it has a later `p`-point.
4. Take a `Q`-maximal `μ*` (Zorn) and a total extension `τ` of it (`Extension.lean`, `extension`).
   Then `τ(t) = σ(t)` and `Fp` holds at `(τ, t)`.
5. Suppose `G(p → Fp)` fails at `(τ, t)`: some `p`-point `f > t` on `τ` has no later `p`-point on
   `τ`. Then `f` is the maximum of `dom μ*` or lies above all of it, since any other `p`-point of
   `μ*` has a later one inside the domain.
6. The antecedent's second conjunct applies to `τ` at `f` and gives `ρ` through `τ(f)` at `f` with a
   `p`-point `s' > f`. The splice of `τ` up to `f` with `ρ` after `f` is a world history
   (`PlusPasting.paste`, valid at `.Base`). Its restriction to `(-∞, s']` satisfies `Q` and strictly
   extends `μ*`. This contradicts maximality, so `τ` witnesses the consequent.

Steps 4 and 6 use only landed results. The Lean work is the `Q`-poset and its chain closure over the
`PartialHistory` API.

**Non-derivability: compiled countermodel, Saturation on paper.**

- Bundle `evFalse := {β : ℤ → Bool | ∃ m, ∀ k ≥ m, β k = false}`, with `p` read as `true`. It is
  paste-closed (`evFalse_pasteClosed`) and shift-closed. `blc_refuted`: the antecedent holds at every
  member and time, and the consequent would need infinitely many `p`-times after `t`.
- Frame `eR` on `Option (Bool × ℕ)`. `none` is a hub of class `b` with `none → x` for every `x`, and
  only `none → none` into it. `some (c, k)` has class `c` and a budget `k`;
  `some (_, k) → some (c', k')` iff `k' ≤ k` and (`c' = true → k' < k`). The budget bounds the number
  of future `p`-visits.
- `eR_image_eq`: the `eπ`-image of the walks of `eR` is exactly `evFalse`. `blc_refuted_coarse` is
  the end-to-end coarse refutation, through report 01's `ct_iff_image`.
- Saturation of `eR` (paper). `eR` is transitive and dense (`eR_trans`, `eR_dense`), so `⇒ₙ = eR` for
  `n ≥ 1`, and it is serial both ways (`eR_succ`, `eR_from_hub`). Forward fibres of non-hub states
  are finite. Every infinite fibre or segment (a forward fibre of the hub, a backward fibre of a
  non-hub state, a segment starting at the hub) contains `none`. A ⊇-directed family with a finite
  member has a minimum-cardinality member contained in every other member
  (`sInter_nonempty_of_directed_of_minimal` is the landed tool); a family of infinite members has
  `none` in its intersection. Limit is automatic over ℤ.
- The countermodel lives on a ℤ-frame. Since `.Base`-derivable implies `.ZTime`-derivable, it
  refutes derivability at both classes. **The `.Base` case needs only the landed `.Base` coarse
  soundness plus the PS/US arms.** The `.ZTime` case additionally needs the unwritten `.ZTime`
  generalisation of `cValid_of_tm`, exactly as in report 01.

### 3. Dense and RTime

- BLC is valid at both, because it is valid at `.Base`.
- The ℤ countermodel does not apply: the Dense and RTime axioms are not valid on ℤ-frames.
- Sketch of a dense countermodel (UNVERIFIED). Over dense time the Limit axiom forces clock-like
  states, so take states `position × Option (Bool × budget)` with `⇒_x` advancing the position by
  `x` (`limit_of_shift` is the landed discharge). Budgets must be ordinals, not naturals: splicing a
  past onto a future whose `p`-times accumulate downward needs a budget above infinitely many
  others, which ordinal left-addition supplies. Forward fibres are then infinite, so Saturation must
  be re-argued through nested ordinal intervals over a successor ordinal (sups exist).
- Verdict: incompleteness at Dense and RTime is likely, and open.

### 4. Revised per-class table

| Class | All-histories TM⁺ (current axioms) | Evidence |
|---|---|---|
| **Base** | **INCOMPLETE** (BLC) | validity: paper (Zorn + `extension`); non-derivability: compiled, Saturation of `eR` on paper |
| **ZTime** | **INCOMPLETE** (LC⁺, and BLC) | report 01 for LC⁺; `blc_valid_full` and `blc_refuted_coarse` compiled for BLC |
| **Dense** | BLC valid; non-derivability CONJECTURED | needs the dense saturated countermodel of Findings 3 |
| **RTime** | BLC valid; non-derivability CONJECTURED | as Dense |

### 5. What completeness would require

- **Keeping the paper's all-histories semantics.**
  - TM⁺ needs limit-closure schemata at every class, X-free at Base. BLC is the simplest instance; a
    complete system would need a schema family (the analogue of Reynolds' LC with state-local
    parameters), not one formula.
  - The completeness problem is then the analogue of full, non-bundled Ockhamist or CTL*
    completeness. Report 01's "at least as hard as full CTL*" stands at ZTime. At Base the closer
    analogue is Ockhamist validity over all trees, with general linear flows and no `X`.
  - For CTL*, Reynolds 2001 needed the AA rule on top of LC. 535's inventory lists Reynolds 2003 for
    the full-tree Ockhamist case. As recalled, and not checked here, that paper announces an
    axiomatization without a published full proof.
  - This is an open research problem. Report 01's decision not to attempt `plus_completeness_*` for
    the current axioms is endorsed, and now extends to `.Base`.
- **Switching to bundled semantics** (paste- and shift-closed bundles, equivalently coarsened models
  with paste-closed image). TM⁺ is sound there, and completeness is plausibly provable. It would be
  completeness for a different semantics from the paper's, and should be stated as such.

## Decisions

1. Report 01's ZTime verdict and its 560 design are confirmed as sound.
2. Report 01's Base row is superseded: INCOMPLETE, with the two paper steps named above.
3. Report 01's Dense and RTime rows move from UNDETERMINED to "BLC valid; non-derivability
   CONJECTURED".
4. The general TM⁺ completeness question is recorded as false for the current axioms at Base and
   ZTime, and open for any extension at every class.

## Recommendations

1. **Retarget task 560 at BLC**, instead of or alongside LC⁺. Proposed target:
   `plus_incomplete_base : PlusValid blc ∧ ¬ PlusDerivable FrameClass.Base [] blc`, with the ZTime
   statement as a corollary once the `.ZTime` coarse soundness lands. 560 is `not_started` and is
   currently scoped on report 01 alone; its description should be rescoped on this report.
2. Phase order for the BLC target: paste-closed coarse soundness at `.Base` (report 01's Phase 1
   without the class generalisation); the `eR` frame with Saturation and the refutation; Base
   validity by the Zorn argument of Findings 2; assembly and README rows.
3. Keep LC⁺ as an optional second witness at ZTime. It is the cleaner statement for the CTL*
   comparison, but it is not needed for the headline.
4. Treat the dense countermodel as a separate research question, not part of 560.

## Risks & Mitigations

- **Risk**: the Base validity argument has a gap that only formalisation exposes. **Mitigation**:
  the ℤ case is compiled with the same stage invariant; the general case replaces the ω-chain by
  Zorn and uses `extension` and `paste` as black boxes. The chain-closure step (Findings 2, step 3)
  is the one to write first.
- **Risk**: Saturation of `eR` is fiddlier in Lean than on paper. **Mitigation**: the ingredients are
  compiled, and `saturation_of_fib_finite` and `sInter_nonempty_of_directed_of_minimal` cover the
  finite-member case. Only the hub case is new, and it is a one-line membership.
- **Risk**: the mirror departs from `PlusTruthAt` or `CTruthAt`. **Mitigation**: as in report 01,
  the implementation re-proves everything against the repository semantics; the probes are evidence,
  not the result.

## Context Extension Recommendations

- **Topic**: Saturation and limit closure. **Gap**: nothing in the context or module docs says that
  the Extension Theorem makes limit-closure principles valid at every order type, which is why the
  all-histories logic of `⊡` outruns any finite-splice axiomatization even at `.Base`.
  **Recommendation**: a paragraph in `Metalogic/Independence/README.md` when 560 lands, beside
  report 01's proposed note on bundled against all-histories semantics.

## Appendix

- Probe 02 index (Part G only; everything before line 553 is probe 01 verbatim):
  `someFuture_iff`, `blc`, `evFalse`, `eModel`, `evFalse_pasteClosed`, `evFalse_shiftClosed`,
  `blc_refuted`, `GoodB`, `goodB_step`, `chainB`, `chainB_lt`, `chainB_agree1`, `chainB_mono`,
  `chainB_agree`, `limit_walkB`, `blc_valid_full`, `eR`, `eπ`, `eR_budget`, `eR_evFalse_aux`,
  `eR_image_mem`, `mem_eR_image`, `eR_image_eq`, `blc_refuted_coarse`, `eR_trans`, `eR_dense`,
  `eR_succ`, `eR_from_hub`.
- `#print axioms` for `blc_valid_full` and `blc_refuted_coarse`: `propext`, `Classical.choice`,
  `Quot.sound` only.
- Compile command: bare `lean` from `~/.elan/toolchains/leanprover--lean4---v4.33.0-rc1`, with
  `LEAN_PATH` set to `.lake/packages/*/.lake/build/lib/lean`. Exit 0, about 13 seconds.
- Not compiled anywhere: Base validity of BLC; Saturation of `cR` and of `eR`; the dense
  countermodel.
