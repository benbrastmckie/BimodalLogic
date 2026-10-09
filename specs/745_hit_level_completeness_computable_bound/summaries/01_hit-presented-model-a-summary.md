# Implementation Summary: Task #745

- **Task**: 745 - Requirement (C) of the ray-product verdict: Hit-level completeness with a computable bound -- settle HitPresented first
- **Status**: [IN PROGRESS]
- **Started**: 2026-10-08T23:51:39Z
- **Completed**: 2026-10-09T02:20:00Z
- **Effort**: ~1.95 hours (phase 1 ~0.2, phase 2 ~0.25, phase 3 ~0.3, phase 4 ~0.25, phase 5 ~0.3,
  phase 6 ~0.4, phase 7 ~0.25)
- **Dependencies**: None ((S) is an independent sibling record; (W) is downstream of both)
- **Artifacts**: plans/01_hit-presented-model-a.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Six single-phase dispatches of the eight-phase plan, each confined to one phase per its
dispatch's phase mission. **Phase 1** (dispatch 5) states the Hit-level hypothesis `HitPresented` in the
library beside `Presented` and records that it is strictly weaker, via
`hitPresented_of_presented`; both land sorry-free in
`FormalSystem/Metalogic/Decidability/RaySummary/Trace.lean` with the plan's required axiom foot.
**Phase 2** (dispatch 6) creates the evidence probe
`specs/evidence/seam-gluing-ray-product/hit-presented-model-a.lean` with its full header, the
model-A fixture transcription, and the step-path classification `path_classify`. **Phase 3**
(dispatch 7) turns that classification into a statement about the seam's SPLICES
(`splice_classify`) and lands the explicit `clTrace` read-out over the five-letter closure alphabet
of `Fp` on both splice families, culminating in the two function-level forms `clTrace_stayA_eq` and
`clTrace_jump_eq` that make trace equality a rewrite. **Phase 4** (dispatch 8) lands the
truncation bound `hitCl_eq_truncated`: `HitCl` at the seam is exactly the family triples of
`stayA`'s closure trace together with those of the finitely many `jump w` for `t ≤ w ≤ t + L`,
for an `L` that is never exhibited. **Phase 5** (dispatch 9) lands the presentation data
itself — the `L + 6`-state type `QA L`, the two-gadget step relation `stepOf` with its
no-cross-step lemma, the explicit flag table `labOf`, and the labelling bridge that ties
`labOf`'s flags to Phase 3's `clTrace` read-out at three levels, the outermost of which turns
Phase 6's run-trace comparison into a rewrite. Phases 6-8 — the run characterization, the
assembly, and the wiring/pins/docs/bound-verdict — are NOT attempted and remain
`[NOT STARTED]`.

Nothing is claimed about requirement (C) itself by any of the four phases. `HitPresented` is a
*declaration*, not yet a *discharged* hypothesis: no model satisfies it in the tree, and the
fixture-level discharge is phases 3-7's work. Phase 2 lands no statement mentioning `HitCl`,
`hitOf` or `HitPresented` at all — what it lands is the rigidity fact the discharge will rest on,
and phase 3 lands none either: `clTrace` is the closure-alphabet trace of a history, not `HitCl`.
Phase 4 is the first to mention `HitCl`, and what it lands is still not (C): `hitCl_eq_truncated`
re-indexes `HitCl` finitely, saying nothing about any presentation and nothing about `hitOf`.
Phase 5 is the first to land a PRESENTATION, and it too is not (C): `labOf` and `stepOf` are
data, `stepOf_no_cross` and the bridge lemmas are facts ABOUT that data, and not one of the
twenty-three declarations mentions `hitOf`, `IsRun`, `HitCl` or `HitPresented`. The connection
between the presentation's runs and the truncated trace set is Phase 6's, and the assembly into
`HitPresented` is Phase 7's.

**Phase 6** (dispatch 10) lands the run characterization — the step the research left uncompiled
and the one the whole result turns on. The presentation's anchored runs trace EXACTLY the
truncated family: `runTrace_mem_of_isRun` (`⊆`) and `exists_isRun_runTrace` (`⊇`), both at their
pinned signatures, plus the three excluded run shapes as named theorems and the `L + 1` branching
figure counted rather than asserted. 413 added lines, zero deletions, zero sorries.

**Phase 7** (dispatch 11) lands the headline. `hitPresented_modelA` composes Phase 4's truncation
bound with Phase 6's run characterization through the library's `mem_hitOf_iff`, at the pinned
signature verbatim, in `+69 / -0` lines and on the first compile round with no tactic iteration.
Observed axiom profile `[propext, Classical.choice, Quot.sound]`, exactly as the Scope Hypothesis
predicted and read off the `#print axioms` output rather than from the prediction. So the
satisfiability half of requirement (C) is now machine-checked: the Hit-level hypothesis
`HitPresented` is SATISFIABLE on fixture model A at every depth `k ≥ 1`, so the obstruction that
killed `Presented` (`Probe735.not_presented`) does NOT reach the Hit level, and the route through
(C) is not closed by task 735's verdict. The bound half is not touched and is not implied: the
`L` is `hitCl_eq_truncated`'s unexhibited `Set.Finite.bddAbove` witness, so
`Fintype.card (QA L) = L + 6` is a function of a number nothing produces. A five-bullet
"What `hitPresented_modelA` does NOT say" section at the headline itself records that, the
deliberate non-`Presented`-ness, the forward-only restriction, the absence of any decidability
claim, and the one-fixture scope. A second sub-step corrected the probe header's opening
paragraph and axiom record, which this phase's own edit had falsified.

## What Changed

- `FormalSystem/Metalogic/Decidability/RaySummary/Trace.lean` — +44 lines inside
  `section Presented`, after `hit_eq_hitOf_of_presented`:
  - `HitPresented` — a `def … : Prop`, body `HitCl M τ t φ k = ↑(hitOf lab step (clNow φ) k)`:
    (C) at the HIT level, an equality of family-triple sets rather than of trace sets.
  - `hitPresented_of_presented` — `Presented → HitPresented` at every depth `k ≥ 1`, as the term
    `hit_eq_hitOf_of_presented M τ t φ lab step k hk hP`.
- `typst/generated/status.typ` — regenerated line count (347508 → 347552, exactly the +44 above)
  and commit/date stamp. Not a plan-declared file; staged because the blocking pre-commit gate's
  own remedy requires it (see Plan Deviations).
- `specs/evidence/seam-gluing-ray-product/hit-presented-model-a.lean` — new, 276 lines (phase 2):
  - a 65-line header carrying every disclaimer the phase's task list mandates — what is
    established, the fixture, the argument in two sentences, the no-bound / forward-only /
    no-decidability / nothing-about-general-regular-ℤ-models limits, the non-generality of the
    fixture (model A's splices are eventually constant in both directions), the explicit statement
    that `Probe735.not_presented` is neither weakened nor retired, the decision held in place, the
    axiom record, and the compile line;
  - the fixture transcribed from `presented-not-complete.lean` (transcribed, never imported):
    `St`, `a`, `b`, `pa`, `Fp`, `RA`, `RA_fwd`, `RA_bwd`, `RA_aa`, `RA_ab`, `RA_bb`, `FA`,
    `instFARegular`, `ab_ne`, `MA`, `stayA`, `stayA_state`, `jump`, `jump_state`, `p_iff`,
    `Fp_iff`, `jump_p_iff`, `jump_Fp`;
  - the step-path classification: `stepA`, `time_eq` (the time component advances by one, so it is
    pinned by its value at `t`), `bwd_a` (`a` is reachable only from `a`, so the slice is pinned at
    `a` at and before the seam), `fwd_dichotomy`, `fwd_absorb` (`b` absorbs), and `path_classify`
    — every step path through `(t, a)` is the constant `a`-path or an `a`-then-`b` jump path with
    jump time `w ≥ t`;
  - a `#print axioms` foot over `path_classify`, `stayA` and `jump`.
- `specs/evidence/seam-gluing-ray-product/hit-presented-model-a.lean` — +205/−9 lines (phase 3),
  272 → 472 lines. The 9 deletions are header-paragraph rewrites, not removed proof: the opening
  paragraph now says "parts 1-2" and names the splice identification and the read-out; the
  argument paragraph gains the transport sentence and the closure-size figure; the axiom-record
  paragraph names the three new pins. Added:
  - `splice_classify` at its pinned signature — every ray pair through the seam `(t, a)` of
    `stayA` splices to `stayA` itself or to `jump w` for some `w ≥ t`;
  - the alphabet, enumerated: `cl_Fp`, `cl_p`, `cl_top`, `cl_bot` (membership in
    `plusSubformulaClosure Fp`) and `letter_cases`, the five-letter exhaustion that makes the
    read-out's case analysis demonstrably complete;
  - ten pairwise-distinctness lemmas `now_ne_{Fp,p,top,bot}`, `Fp_ne_{p,top,bot}`,
    `p_ne_{top,bot}`, `top_ne_bot` — UNUSED in this phase, landed for phases 5-6;
  - two supporting falsity lemmas `stayA_p_false`, `stayA_Fp_false`;
  - the ten per-letter read-outs `clTrace_stayA_{now,Fp,p,top,bot}` and
    `clTrace_jump_{now,Fp,p,top,bot}`;
  - the two assembled `↔` forms `clTrace_stayA_apply`, `clTrace_jump_apply` and the two
    function-level forms `clTrace_stayA_eq`, `clTrace_jump_eq`;
  - a live `#eval (plusSubformulaClosure Fp).card` at the foot of the alphabet section, and three
    new `#print axioms` pins (`splice_classify`, `clTrace_stayA_eq`, `clTrace_jump_eq`).

- `specs/evidence/seam-gluing-ray-product/hit-presented-model-a.lean` — +98 lines (phase 4,
  dispatch 8; zero deletions), file now 563 lines. A new `## The truncation bound` section:
  - `jump_seam {w t : ℤ} (hw : t ≤ w) : (jump w).state t = stayA.state t` — every `jump w` with
    `w ≥ t` passes through the seam `(t, a)`, since at `t` itself the jump has not happened.
  - `exists_splice_eq (t) (σ) (h : σ.state t = stayA.state t) : ∃ bf : SeqPair FA (stayA.state t),
    spliced stayA t bf = σ` — the converse of `splice_classify`: every seam-passing history IS a
    splice. `seamOmegaEquiv`'s `symm_apply_apply` and nothing more.
  - `hitCl_covered (t) (k) : ∀ x ∈ HitCl MA stayA t Fp k, ∃ n : ℕ,
    x ∈ familyTriples … stayA ∨ x ∈ familyTriples … (jump (t + n))` — `hitCl_eq_iUnion` followed
    by `splice_classify`, with the jump time re-expressed as a natural offset from `t`.
  - `hitCl_eq_truncated (t) (k) (hk : 1 ≤ k)` — the phase headline, at the pinned signature:
    `∃ L : ℕ, HitCl MA stayA t Fp k = familyTriples … stayA ∪ ⋃ w ∈ Set.Icc t (t + L),
    familyTriples … (jump w)`. Added to the probe's `#print axioms` foot, reporting exactly
    `[propext, Classical.choice, Quot.sound]`.

- `specs/evidence/seam-gluing-ray-product/hit-presented-model-a.lean` — +237 lines (phase 5,
  dispatch 9; zero deletions), file now 807 lines. A new `## The presentation data` section with
  twenty-three declarations and two compile-checked witnesses:
  - `#guard (plusSubformulaClosure Fp).card = 4` — the closure-size figure the flag table's
    branch count rests on, re-derived live before the table was written and now re-checked on
    every compile (a failing `#guard` is a compile error, unlike the bare `#eval` left at the
    foot).
  - `QA (L : ℕ) := Fin 3 ⊕ Fin (L + 3)` at the pinned signature, an `abbrev` so `Fintype` and
    `DecidableEq` resolve through the `Sum`/`Fin` instances with nothing hand-rolled.
  - `card_QA (L) : Fintype.card (QA L) = L + 6`, plus `#guard Fintype.card (QA 2) = 8`.
  - `stepOf (L) : QA L → QA L → Bool` at the pinned signature, a plain `def` with `decide (…)`
    bodies over `Fin` index values. Gadget 1 (`Fin 3`): `0→0, 0→1, 1→2, 2→2`. Gadget 2
    (`Fin (L + 3)`): `0→0`, `0→1`, `i→i+1` and `i→L+2` for `1 ≤ i ≤ L+1`, `L+2→L+2`.
  - `stepOf_inl_inr`, `stepOf_inr_inl` — the two crossing edges are `false` by `rfl`, both
    `@[simp]`.
  - `stepOf_no_cross (L) (q r) (h : stepOf L q r = true)` — every edge has both endpoints in one
    summand. The named declaration Phase 6's cross-gadget exclusion cites.
  - `stepOf_inl_inl_iff`, `stepOf_inr_inr_iff` — the two index-level step tables, as `↔`s Phase 6
    reads the edges off without unfolding `stepOf`.
  - `isNowState`, `isJumpState`, `isPostState` — the three state-side flags, factored out of
    `labOf` as named `def`s.
  - `labOf (L) : QA L → (clSig Fp).preds → Bool` at the pinned signature, a plain `def`: an
    explicit five-branch `if`-chain over the letters, NOT `decide` of `clTrace`.
  - `top_ne_now`, `Fp_ne_now`, `p_ne_now`, `bot_ne_now`, `top_ne_Fp`, `p_ne_Fp`, `bot_ne_Fp`,
    `bot_ne_top`, `bot_ne_p` — the nine symmetric forms of Phase 3's letter disequalities, in the
    direction `labOf`'s `if`-chain resolves them. Each is a one-line `.symm`.
  - `labOf_now`, `labOf_top`, `labOf_Fp`, `labOf_p`, `labOf_bot` — the five letter-branch
    evaluation lemmas, all `@[simp]`, each with a state-side right-hand side.
  - `labOf_inl (L) (i : Fin 3) (ℓ)` and `labOf_inr (L) (i : Fin (L + 3)) (ℓ)` — the per-gadget
    assembled flag lemmas, as four-case splits over `letter_cases`. Set beside
    `clTrace_stayA_apply` and `clTrace_jump_apply` they match disjunct for disjunct, with `z = t`
    replaced by `i.val = 1` and `w < z` by `i.val = L + 2`.
  - `labOf_inl_iff_clTrace_stayA (L) (t z) (i) (hnow : i.val = 1 ↔ z = t) (ℓ)` and
    `labOf_inr_iff_clTrace_jump (L) (t w z) (i) (hnow) (hp : i.val = L + 2 ↔ w < z) (ℓ)` — the
    position-indexed bridges: letterwise agreement with `clTrace`, given only the two
    correspondences the gadget has.
  - `runTrace_inl_eq`, `runTrace_inr_eq` — the `funext`-ed function-level forms, which are what
    actually make Phase 6's trace equality a rewrite.
  - Four new `#print axioms` foot lines (`labOf`, `stepOf`, and the two position-indexed
    bridges), matching the foot convention the file already carried.

- `specs/evidence/seam-gluing-ray-product/hit-presented-model-a.lean` (phase 6, +413 / -0, now
  1220 lines) — the run characterization. Eighteen new sorry-free declarations:
  - `no_run_const_pre (L) (t) (ρ) (hρ) (q) (hq : isNowState L q = false) (hconst : ∀ z, ρ z = q)`
    — counterexample 1: no run is constant at a non-`now` state, in either gadget. `IsRun`'s
    second clause at `z = t` and nothing else.
  - `isLeft_const_of_isRun (L) (hstep) (t) : ∀ z, (ρ z).isLeft = (ρ t).isLeft` — counterexample 2:
    `Sum.isLeft ∘ ρ` is constant along a `step`-chain, by Phase 5's `stepOf_no_cross` and nothing
    else, with the two-sided reach by `Int.induction_on`.
  - `inr_no_back_edge (L) (i j) (h) (hi : 1 ≤ i.val) : i.val < j.val ∨ (i.val = L+2 ∧ j.val = L+2)`
    — counterexample 3: no mid-chain loop; the index strictly increases and `j_post` is the only
    reachable self-loop.
  - `exists_left_index`, `exists_right_index` — a run confined to one gadget is the `Sum.inl` /
    `Sum.inr` of an index function `ℤ → Fin 3` / `ℤ → Fin (L + 3)`, built choice-free with
    `Sum.elim`.
  - `inl_bwd_pre`, `inl_fwd_post`, `inl_run_pinned` — gadget 1's rigidity: `s_pre` strictly before
    the seam, `s_now` at it, `s_post` strictly after, so gadget 1 carries exactly one anchored run.
  - `inr_bwd_pre` — gadget 2 is constant at `j_pre` strictly before the seam. This is what keeps
    `j_post` out of `(-∞, t]`, and it IS consumed, by `inr_post_threshold`.
  - `inr_fwd_index (L) (hstep) (ht) : ∀ n, (σ (t + n)).val = L + 2 ∨ (σ (t + n)).val = 1 + n` —
    gadget 2's forward branching. At `n = L + 1` the mid-chain alternative IS `j_post`
    (`1 + (L + 1) = L + 2`), so every gadget-2 run reaches `j_post` within `L + 1` steps.
  - `inr_absorb`, `inr_absorb_add` — `j_post`'s only successor is itself, for one step and for any
    number of steps.
  - `inr_post_threshold (L) (hstep) (hnow) : ∃ w, t ≤ w ∧ w ≤ t + L ∧ ∀ z, ((σ z).val = L+2 ↔ w < z)`
    — the threshold, from `Nat.find` of the first forward index at `j_post`.
  - `runTrace_mem_of_isRun` at the pinned signature — the `⊆` direction.
  - `stayRun` + `stayRun_val` / `stayRun_now` / `stayRun_isRun` — the gadget-1 witnessing run.
  - `jumpRun` + `jumpRun_val` / `jumpRun_now` / `jumpRun_post` / `jumpRun_isRun` — the gadget-2
    witnessing run with threshold `w`; the index is `min … (L + 2)` so the `Fin (L + 3)`
    membership needs no side condition, and `jumpRun_val` proves the `min` is the identity on the
    intended range.
  - `exists_isRun_runTrace` at the pinned signature — the `⊇` direction.
  - `jump_window_card (t) (L) : (Finset.Icc t (t + L)).card = L + 1` — the branching figure
    counted as a theorem, plus a computable `#guard` at `L = 2` over `stepOf`'s own edges into
    `j_post` (`Finset.Icc` on `ℤ` is not compilable, so the window itself is witnessed by the
    theorem, not by a `#guard`).
  - Two new `#print axioms` foot lines (`runTrace_mem_of_isRun`, `exists_isRun_runTrace`).

- `specs/evidence/seam-gluing-ray-product/hit-presented-model-a.lean` — phase 7, `+101 / -17`
  across two sub-step commits, now 1304 lines:
  - `hitPresented_modelA` — **the headline**, at the pinned signature verbatim:
    `(t : ℤ) (k : ℕ) (hk : 1 ≤ k) : ∃ L : ℕ, HitPresented MA stayA t Fp (labOf L) (stepOf L) k`.
    One composition and no new mathematical content: `hitCl_eq_truncated t k hk` supplies `L` and
    rewrites the seam side; `mem_hitOf_iff (labOf L) (stepOf L) (clNow Fp) k t hk x` rewrites the
    presentation side into run-existence (the ONLY place `1 ≤ k` is consumed); then
    `exists_isRun_runTrace` closes `⊆` on both union branches and `runTrace_mem_of_isRun` closes
    `⊇` on both run shapes. The two sides meet at `InFamily` with the trace as the sole differing
    argument — which is why nothing here compares trace sets, and hence why the Hit level
    survives.
  - `/-! ### What `hitPresented_modelA` does NOT say -/` — five bullets: no `L` exhibited so no
    bound delivered (naming both choice sites, and naming `card_QA`'s `L + 6` and
    `jump_window_card`'s `L + 1` as functions of an unexhibited `L`, not bounds); the
    presentation is deliberately NOT `Presented` and task 735's verdict stands unchanged;
    forward-only, nothing about `⊡(P p)`, no symmetry implied; `Decidable (PlusValidZTime φ)` not
    stated in any form and no claim that L⁺ is decidable, qualified or not; one fixture, one
    seam, one `φ`.
  - `#print axioms hitPresented_modelA` added to the foot (fourteen pinned lines now).
  - Header rewritten in three places that this phase's own edit falsified: the opening paragraph
    (it claimed "parts 1-2 of the record … Nothing in this file yet mentions `HitCl`, `hitOf` or
    `HitPresented`") now states the full contents plus a `**The headline.**` paragraph; the
    "What is NOT established" paragraph's "the later phases' headline" is now "the headline"; and
    the `**Axiom record.**` paragraph now reports the fourteen OBSERVED profiles, including the
    one exception (`stepOf` is `[propext]` alone, being a decidable `Bool`-valued table) and the
    four `Classical.choice` entry points.

## Decisions

- `HitPresented` is a `def … : Prop` whose body IS its pinned statement, so
  `hitPresented_of_presented` closes by definitional unfolding to `hit_eq_hitOf_of_presented`'s
  conclusion — a bare term application, no tactic block and no `unfold`/`show` step.
- Both docstrings carry the plan's three disclaimers explicitly: fixture-only, forward-only, and
  non-constructive (`∃ L` out of `Set.Finite.bddAbove`, so no bound). Neither mentions
  decidability, a decision procedure, or `PlusValidZTime` in any form — audited mechanically over
  the new block, whose only `Decidab`-shaped hits are the `[DecidableEq Q]` instance binders the
  pinned signature requires.
- Both docstrings state that `Probe735.not_presented` is NOT weakened or retired: that probe
  refutes a TRACE-set equality, `HitPresented` is a FAMILY-TRIPLE-set equality, the pumped trace's
  forward type is what the refutation turns on, and a type-level demand gives that argument
  nothing to bite on — so both hold of the same fixture at once.
- Phase 2 is a transcription, not a re-derivation. The research dispatch's compiled scratch file
  `rigid745.lean` was still present in the session scratchpad, so every tactic choice the report
  recorded as load-bearing transcribed verbatim and compiled green on the first attempt:
  `Int.induction_on` with case names `zero`/`succ`/`pred`; `push_cast at h ih ⊢` BEFORE the
  `show … by ring` rewrite in `bwd_a`; `simp only [not_exists]` in place of deprecated `push_neg`;
  an explicit `IsStepPath` hypothesis per theorem (this toolchain does not auto-include a
  propositional `variable`). No proof search was run and no alternative route was considered.
- Phase 2's `#print axioms` foot was added now rather than deferred to phase 7's assembly, because
  phase 2's own task list requires the header to carry "the axiom record" and an unverified record
  would have been prose. Phase 7 extends the foot to the headline.
- Phase 3's `splice_classify` needed no transport lemma. `WorldHistory.path` is
  `WorldHistory.state` by definition and `seamOmegaEquiv`'s `.symm` carries the seam condition
  `σ.state t = stayA.state t` as its `.2` field, so `path_classify` applies to
  `(spliced stayA t bf).path` directly and `WorldHistory.ext_state` lifts the pointwise result to a
  history equality. The plan's route was followed; no explicit `pathFibreEquiv` rewrite appears
  because the equivalence's definitional transparency made one unnecessary.
- The read-out's assembled forms deliberately avoid the distinctness lemmas: `clTrace_stayA_apply`
  and `clTrace_jump_apply` case on `letter_cases` in the forward direction and substitute via
  `rintro ... rfl` in the backward direction, so neither needs pairwise distinctness. The ten
  distinctness lemmas are landed anyway for phases 5-6's `labOf` flag-table case split and are
  recorded above as unused in this phase rather than left to look live.
- The read-out is stated at three strengths deliberately: per-letter (`clTrace_jump_p` and the
  nine siblings), assembled pointwise (`clTrace_jump_apply`), and function-level
  (`clTrace_jump_eq`). Phase 6's `runTrace (labOf L) ρ = clTrace MA Fp t …` obligations should
  discharge against the function-level forms, which is what makes "trace equality is a rewrite"
  literal rather than aspirational.
- The only `w`-dependence in a jump trace is the `p` letter's threshold: `now` at `t`, `⊤`
  everywhere, `Fp` everywhere (`b` absorbs, so a later `b` always exists), `⊥` nowhere, `p` exactly
  after `w`. That single threshold is what phase 5's presentation must reproduce and why distinct
  `w` give distinct traces.
- Nothing in phase 3 evaluates a `kTypeOf` or runs `decide` over `KType`, per the plan's Research
  Integration note (report D-2/D-3): the read-outs go through `clTrace_letter`/`clTrace_now` and
  `PlusTruthAt` only. The file's one `KType` occurrence is a docstring sentence saying so.

- **Phase 4: two choice sites named, not one.** The plan's task item asks for a comment naming
  where the non-constructivity enters (`Set.Finite.bddAbove`). The landed proof has TWO such
  sites and the section header names both: `choose!` picks a witnessing ray pair — hence, through
  `splice_classify`, a jump time — for each member of `HitCl`, and `Set.Finite.bddAbove` then
  asserts only that SOME upper bound of those offsets exists. Neither exhibits anything, which is
  why the `∃ L` shape is the recorded result rather than a presentational choice.
- **Phase 4: `Set.Finite.image` + `BddAbove`'s own `upperBounds` witness in place of
  `toFinset`/`Finset.sup`.** `((hitCl_finite …).image off).bddAbove` yields
  `⟨L, hL : L ∈ upperBounds (off '' HitCl)⟩` directly, so the `Set.Finite.toFinset` / `Finset.sup`
  bookkeeping the plan's Scope Hypothesis predicted as the dominant cost never arose. Both names
  were still re-resolved by name as the task item requires. This is not a route substitution: the
  plan's stated route is "`Set.Finite.bddAbove` on the image of the offsets to get `L`", which is
  exactly what was done.
- **Phase 4: one declaration-scoped linter suppression, documented in the docstring.** The pinned
  signature binds `(hk : 1 ≤ k)` and the truncation argument genuinely does not use it (`HitCl` is
  defined at every depth), so `unusedVariables` warned — colliding with the phase's zero-warnings
  bar. Renaming the binder to `_hk` would have altered the signature the phase's own verification
  requires verbatim, so the resolution is `set_option linter.unusedVariables false in` on that one
  declaration plus a docstring paragraph stating why `hk` is carried.
- **Phase 4: `exists_splice_eq` had to be a term proof, not `show`-then-`rw`.** Writing the
  `symm_apply_apply` goal out with `show` forced elaboration at `implicit` transparency and
  produced an application type mismatch between `{σ // σ.state t = stayA.state t}` and
  `Presheaf.StabFibre FA.toTaskFrame.toFibre.toTaskFrame t (stayA.state t)`, after which the `rw`
  found no pattern. `congrArg Subtype.val ((seamOmegaEquiv t (stayA.state t)).symm_apply_apply
  ⟨σ, h⟩)` compiles. Worth carrying into phase 6, which touches `IsRun` and may meet the same
  `toFibre.toTaskFrame` coercion wall.

- **Phase 5: `labOf` as an `if`-chain over the letters, not a `match` on `PlusFormula` shape.**
  A `match` on the letter's underlying formula (`.untl _ _`, `.impl .bot .bot` for `⊤`, `.atom _`)
  would have bound the flag table to `PlusFormula.top`'s current definitional unfolding — exactly
  the kind of anchor the task's anchor warning cautions against. The `if ℓ = clNow Fp / ℓ =
  clLetter Fp cl_top / …` chain depends only on `clNow`, `clLetter` and the four closure-membership
  proofs Phase 3 landed, so a change to how `⊤` is spelled cannot silently reshuffle the table.
- **Phase 5: the three state-side flags are their own `def`s.** `isNowState`, `isJumpState` and
  `isPostState` exist so that the five letter-branch lemmas can be `@[simp]` with a state-side
  right-hand side. Without them each lemma's RHS would be an inline `match`, which `simp` cannot
  usefully rewrite with, and Phase 6 would have to unfold `labOf` itself at every use.
- **Phase 5: nine symmetric disequality aliases, and why they are not redundant.** `simp` given
  `h : a ≠ b` rewrites `a = b` to `False`, but NOT `b = a`. Phase 3 proved the ten distinctness
  facts in the `clNow Fp ≠ clLetter …` / `clLetter Fp cl_Fp ≠ clLetter Fp cl_p` direction, while
  `labOf`'s `if`-chain presents every condition the other way round (`clLetter Fp cl_top =
  clNow Fp`, etc.). Nine one-line `.symm` aliases were cheaper and more legible than rewriting
  each proof to discharge the orientation inline — and they put Phase 3's ten previously-unused
  distinctness lemmas to work, closing a follow-up this summary had opened against them.
- **Phase 5: `stepOf` edges stated on `.val`, not on `Fin` literals.** `(1 : Fin (L + 3))`
  carries a `1 % (L + 3)` reduction obligation that varies with `L`; the mid-chain conditions
  (`1 ≤ i.val`, `i.val ≤ L + 1`, `j.val = i.val + 1`) are plain `ℕ` arithmetic that `decide` and
  `omega` handle directly. The `decide (…)` bodies keep both `stepOf` and `labOf` computable
  `def`s, never `noncomputable def` — required, since `HitPresented` is a proposition about
  `hitOf lab step` and `hitOf` is a `Finset`.
- **Phase 5: the ONE mid-chain covers all `L + 1` thresholds.** Gadget 2 has `L` mid states, not
  `L + 1` gadgets. A run reaching `j_post` at `t + d` dwells `d` steps on the mid chain
  (`0 ≤ d ≤ L`), so the single gadget realizes every `jump w` with `t ≤ w ≤ t + L`. This is why
  `Fintype.card (QA L)` is `L + 6` rather than quadratic in `L`.
- **Phase 5: the bridge landed at three levels, not one.** The plan's item asks for "a four-case
  lemma"; the phase's stated GOAL asks that Phase 6's run-trace comparison be "a rewrite rather
  than a re-derivation". Only the function-level forms (`runTrace_inl_eq`/`runTrace_inr_eq`)
  deliver the goal, and they need the position-indexed bridges, which need the assembled flag
  lemmas. Stopping at the four-case lemma would have satisfied the item's letter and missed the
  phase's goal.

- **Phase 6: gadget 1's trace equality consumes only `IsRun`'s own `↔`, and the probe says so.**
  Phase 5 built `labOf` so that a gadget-1 state reads nothing but `isNowState`, so the seam
  correspondence `i.val = 1 ↔ z = t` — which IS `IsRun`'s second clause, free — is the whole
  premise of `runTrace_inl_eq`. The plan's route describes the backward/forward pinning as the
  path to the `⊆` direction, and the pinning IS landed (`inl_bwd_pre`, `inl_fwd_post`,
  `inl_run_pinned`), but as the plan's named route and as the record that no unclassified
  gadget-1 run exists, not as a premise of the trace comparison. Stated in the probe's own section
  header rather than left for a reader to discover. `inr_bwd_pre` is consumed, by
  `inr_post_threshold`'s `z ≤ t` case.
- **Phase 6: the threshold comes from `Nat.find`, which produces no bound and implies none.**
  `inr_post_threshold` takes the least `n` with index `L + 2` at `t + n` and `inr_fwd_index`
  caps it at `L + 1`. `jump_window_card`'s docstring says explicitly that `L + 1` is not a bound
  on anything: `L` remains the unexhibited `Set.Finite.bddAbove` witness of `hitCl_eq_truncated`.
- **Phase 6: the witnessing runs are named `def`s, not inline terms.** `stayRun` and `jumpRun`
  each carry their own `val` lemma plus the two position correspondences, so the `IsRun` clauses
  and the trace equalities are separately checkable and the `min` bookkeeping in `jumpRun` is
  isolated in one lemma rather than spread through four proofs.
- **Phase 6: `omega` does not discharge an `Iff` goal in this toolchain.** Every
  `split_ifs <;> omega` over a goal of the form `<index> = c ↔ <time condition>` failed, reporting
  a counterexample region equal to the hypothesis set — i.e. omega learned nothing from the goal.
  Five sites, two compile rounds. The fix is to decompose the `Iff` first:
  `constructor <;> intro h <;> omega`, or `iff_of_false`/`iff_of_true` with a per-side `by omega`.
  A paired trap: `split_ifs` reduces a closed-literal branch such as `0 = L + 2` to `False`, so
  that branch wants `not_false` rather than `by omega`, and omega also ignores an atom-free
  hypothesis such as `h : 0 = 1`. Diagnosed by reading the goal with `lean_goal` rather than by
  guessing.
- **Phase 6: six inductions, each needing one explicit cast-reshaping line.** Every
  `ℕ`-indexed walk off the seam (`inl_bwd_pre`, `inl_fwd_post`, `inr_bwd_pre`, `inr_fwd_index`,
  `inr_absorb_add`) and the two-sided `Int.induction_on` in `isLeft_const_of_isRun` needs a
  `rw [show t ± ((m + 1 : ℕ) : ℤ) = … by push_cast; ring]` to line the successor index up with the
  step hypothesis. This is the single largest contributor to the phase's line count after the
  decomposition itself.

- **Phase 7: the assembly carries no mathematical content, and that is the point.**
  `hitPresented_modelA`'s proof is nineteen lines with no induction, no case analysis beyond the
  union's two branches, and no new lemma. Every obligation was discharged by a declaration a
  prior phase had already pinned. That is the evidence that the decomposition the plan chose was
  the right one: if the assembly had needed new mathematics, some earlier phase's pinned
  statement would have been the wrong statement.
- **Phase 7: the bridge is `InFamily`, not a trace-set equality — and this is why the Hit level
  survives.** `mem_hitOf_iff` is stated membership-wise with
  `InFamily sig k x.1 x.2.1 x.2.2 (runTrace lab ρ)`, and `familyTriples sig k c` is
  `{x | InFamily sig k x.1 x.2.1 x.2.2 c}`, so the two sides of `HitPresented` meet at `InFamily`
  with the TRACE as the sole differing argument. Phase 6's two directions supply exactly that
  identification. Nothing in the proof compares trace SETS, which is the equality
  `Probe735.not_presented` refutes — so the refutation has nothing to bite on here, exactly as
  task 735's verdict predicted it would not.
- **Phase 7: the header's stale claims were corrected, not left standing.** The probe's opening
  paragraph said "parts 1-2 of the record … Nothing in this file yet mentions `HitCl`, `hitOf` or
  `HitPresented`" — false from the moment Phase 4 landed and flatly false once the headline
  landed. Rather than leave a probe whose own header misdescribes it, the paragraph was rewritten
  to state the full contents and the headline, the "later phases' headline" clause was fixed, and
  the axiom record was replaced by the fourteen OBSERVED profiles. Recorded as a deviation
  annotation on the plan's second phase-7 item, since the plan asked only for the axiom record.

## Plan Deviations

- **Task 1.3** (the `HitPresented` docstring) altered: the plan directs the docstring to say the
  hypothesis "is discharged in this tree … by the wired probe
  `specs/evidence/seam-gluing-ray-product/hit-presented-model-a.lean`". That file does not exist
  at phase 1 — the plan's own phase 2 creates it and phase 8 wires it — so the reference is
  written as a forward reference ("landed by this record's later phases"). Every other element of
  the item (Hit-vs-trace weakening, `presented_localRun` unavailable, finiteness by
  `kType_finite`, fixture-only, non-constructive, no bound, `Paper: —` anchor) is verbatim.
  Annotated inline on the plan's checklist item.
- **Phase 1 Scope Hypothesis** overrun, not a step deviation: predicted ~15-25 added lines,
  actual 44. The two declarations plus bodies are 12 lines; the remaining 32 are docstring prose
  the phase's own task list mandates in detail. Recorded in `issues.jsonl`.
- **Out-of-scope staged path**: `typst/generated/status.typ`. The pre-commit
  `typst-sync-check.sh` Check 2 gate BLOCKED the phase commit because the committed
  `formalsystem-line-count` lagged live by exactly the 44 lines this phase added. The gate's
  `--no-verify` bypass is explicitly reserved for drift caused by *another* writer, so it did not
  apply; the documented remedy (full `lake build`, then `typst-sync-check.sh --fix`, then stage
  the file) was run instead. Every later phase of this record that adds Lean lines will hit the
  same gate, and this path is not in the plan's `file_scope` — recorded in `issues.jsonl` so
  phases 2-8 expect it.
- **Phase 2 fixture transcription** altered: the plan's transcription list names 19 identifiers;
  `RA_aa`, `RA_ab`, `RA_bb` and `ab_ne` were transcribed as well, because `stayA`, `jump` and
  `bwd_a` do not elaborate without them. Also `a`, `b` and `pa` are landed as `def`, as in
  `presented-not-complete.lean` which the item names as the transcription source, rather than as
  the `abbrev` the plan's `## Lean Challenge Statements` block shows — that block states in its own
  preamble that the `abbrev` form was a plan-time device to make the declared identifier set equal
  the `**Goals**:` set, and none of `St`/`a`/`b`/`pa`/`Fp` is a pinned goal. Every identifier that
  IS pinned landed at its pinned signature with a real body. Annotated inline on the checklist.
- **Phase 2 Scope Hypothesis** overshoot, not a step deviation: predicted ~200-230 lines (header
  ~60, fixture ~50, classification ~110); actual 276 (header 65, fixture ~100, classification
  ~96). Header and classification estimates were accurate; the fixture estimate was low by ~50,
  because `jump`'s well-definedness proof plus the three `RA` step facts it and `stayA` consume do
  not fit in 50 lines. No scope beyond the plan's enumerated items was added. Recorded in
  `issues.jsonl`.
- **The pre-commit gate did NOT fire for phase 2**, refining phase 1's expectation: the
  `typst-sync-check.sh` Check 2 gate tracks `formalsystem-line-count`, and the probe lives under
  `specs/`, outside `FormalSystem/`. Phases 3-7 touch only that probe, so they will not hit the
  gate either; phase 8's `Tests/` edit may.
- **Phase 3: no step deviation.** All four checklist items were executed as written, in order,
  through the plan's named helpers (`clTrace_letter`, `clTrace_now`, `p_iff`, `Fp_iff`,
  `jump_p_iff`, `jump_Fp`), with the `#eval` re-derivation run before the case split as the item
  requires. No step was skipped, altered, deferred, inlined, or routed through a different lemma.
- **Phase 3 Scope Hypothesis** REFUTED-WITH-OVERSHOOT, not a step deviation: predicted 80-120
  added lines, actual 205 insertions / 9 deletions (net +196). The hypothesis named the wrong
  driver — it suspected the splice-to-step-path transport, which came in at 29 lines and compiled
  on the first attempt. The driver is the read-out item itself: "for each member of
  `plusSubformulaClosure Fp` plus `clNow`, give `clTrace` on `stayA` and on `jump w` explicitly" is
  10 per-letter lemmas, and with 4 membership facts, `letter_cases`, 2 falsity lemmas, 2 assembled
  forms and 2 function-level forms that is 21 mandated declarations before any supporting material;
  the forward-looking distinctness lemmas add ~22 lines more. Recorded in `issues.jsonl` as
  `class: scope-estimate`, `severity: minor`, per the item's own instruction.
- **Phase 3 process deviation**: the phase heading was not marked `[IN PROGRESS]` before the proof
  work began — it went from `[NOT STARTED]` straight to `[COMPLETED]` in a single plan-file write
  at phase end. The marker exists for crash recovery, so writing it retroactively after the phase
  was already green would have been false rather than useful. Recorded in `issues.jsonl`; no other
  step of the phase-checkpoint protocol was omitted.
- **Phase 3 added declarations beyond the item's literal enumeration**: `letter_cases`, the four
  membership facts, the ten distinctness lemmas, the two `stayA` falsity lemmas, and the two
  function-level `_eq` forms are not named individually in the checklist item. They are supporting
  lemmas the enumerated read-out requires (or, for the distinctness lemmas, that phases 5-6 will),
  not substitutes for any plan step — the plan's own `Goals, stated in prose` entry covers "the
  four-case closure-letter read-out lemma for the closure alphabet of the fixture formula". Flagged
  here rather than left implicit.

- **Phase 4: no step deviation.** All six checklist items were executed as written, in order, and
  the phase heading was marked `[IN PROGRESS]` before the first file write (correcting phase 3's
  process slip). Three named declarations beyond the item's literal enumeration were added
  (`jump_seam`, `exists_splice_eq`, `hitCl_covered`) — a decomposition REFINEMENT in the
  plan-compliance-safe direction (more named lemmas, never an inlining); no plan-named declaration
  was skipped, altered or re-routed, and `hitCl_eq_truncated` matches its pin verbatim.
- **Phase 4 Scope Hypothesis** CONFIRMED — the first confirmed one in this task: predicted 60-100
  added lines, actual 98 insertions by `git diff --stat`. The predicted DRIVER was wrong, as in
  phase 3: no `Finset.sup` bookkeeping arose at all. The cost was the three extra helper
  declarations and the section's prose header instead.

- **Phase 5: no step skipped, deferred or re-routed; four items altered additively.** All seven
  checklist items were executed as written, in order, and the phase heading was marked
  `[IN PROGRESS]` before the first file write. Four items carry inline `*(deviation: altered …)*`
  annotations, each recording an ADDITIVE decomposition refinement — more named declarations than
  the item enumerates, never an inlining and never a substitution. Specifically: `card_QA` plus a
  `#guard` where the item left the card claim parenthetical; two `@[simp]` crossing-edge lemmas
  and two index-level step tables alongside the asked-for `stepOf_no_cross`; three state-side
  flag `def`s plus five `@[simp]` letter-branch lemmas behind `labOf`; and six bridge
  declarations where the item names one four-case lemma. No pinned signature was touched:
  `QA`, `labOf` and `stepOf` match the plan's `## Lean Challenge Statements` block verbatim under
  mechanical whitespace-normalized comparison.
- **Phase 5: the probe's `#print axioms` foot was extended beyond the item's wording** with
  `labOf`, `stepOf`, `labOf_inl_iff_clTrace_stayA` and `labOf_inr_iff_clTrace_jump`. The plan
  assigns the foot to Phase 7, for `hitPresented_modelA`; extending it here follows the
  convention the file already carried for phases 2-4 and produced the observed (not predicted)
  profiles recorded below. Flagged rather than left implicit.
- **Phase 5 Scope Hypothesis MISSED**: predicted 100-150 added lines, actual 237 insertions by
  `git diff --stat` (zero deletions). Three drivers, all inside the phase's own task list rather
  than scope creep — a 32-line section docstring documenting the two-gadget design and the
  mid-chain-covers-all-thresholds argument; the nine `simp`-orientation aliases; and the bridge
  item landing as six declarations. The secondary claim of the hypothesis,
  `Fintype.card (QA L) = L + 6`, was CONFIRMED and is now a named theorem plus a `#guard`. Phase
  4 had been the first confirmed hypothesis in this task; this returns to the overshoot pattern
  of phases 1-3.

- **Phase 6: no step skipped, deferred or re-routed; three items altered additively, one not
  triggered.** The `⊆` item, the `⊇` item and the three-counterexample item each carry an
  additive-decomposition annotation naming the declarations they landed as. The conditional
  escalation item ("if the `IsRun` pinning genuinely cannot be carried out") is left unchecked
  with an annotation recording that its condition never arose: the pinning was carried out as
  written, the explicitly rejected `mem_hitOf_iff_live` / `pathTypesNow` / `fwdLiveSep` route was
  not used, neither pinned statement was weakened, and no placeholder was landed.
- **Phase 6 Scope Hypothesis MISSED**: predicted 100-150 added lines, actual 413 insertions by
  `git diff --stat`, zero deletions. Three drivers, recorded in the issue log: the plan's
  prose route became 16 named declarations plus 2 `def`s rather than 2 theorems; the Int/Nat cast
  reshaping cost one explicit line per induction step across six inductions; and the witnessing
  runs landed as named `def`s with four evaluation lemmas each. Same direction and roughly the
  same factor as Phase 5's miss (100-150 predicted, 237 actual), so this plan's remaining
  per-phase line estimates should be read as low by 2-3x. The phase's second scope claim — that
  gadget 2's forward branching is exactly `L + 1` — is CONFIRMED and machine-checked, by
  `inr_fwd_index` (every run reaches `j_post` within `L + 1` steps), `inr_post_threshold` (the
  threshold lands in `[t, t + L]`), `exists_isRun_runTrace` (every member of that interval is
  realized) and `jump_window_card` (the interval has `L + 1` members).

- **Phase 7, item 1** *(altered)*: landed in the binder form `(t : ℤ) (k : ℕ) (hk : 1 ≤ k)`
  that the plan's `## Lean Challenge Statements` block pins, which is that block's rendering of
  the item's `∀ (t : ℤ) (k : ℕ), 1 ≤ k → …` prose. The Challenge block is the signature contract
  under `plan-compliance.md`'s Statement Fidelity section, so it wins over the item's prose
  paraphrase; verbatim MATCH confirmed mechanically.
- **Phase 7, item 2** *(altered)*: the header update went beyond the axiom record, correcting two
  further statements that this phase's own edit falsified (the opening paragraph's "parts 1-2 of
  the record … Nothing in this file yet mentions `HitCl`, `hitOf` or `HitPresented`", and the
  "What is NOT established" paragraph's "the later phases' headline"). Purely corrective and
  additive; no claim weakened, no qualifier dropped, no new claim introduced.
- **Phase 7, item 3** *(altered)*: the "short note" landed as a five-bullet
  `### What `hitPresented_modelA` does NOT say` section. It carries all three items the plan
  names, plus two the dispatch's standing constraints require of any statement of this result:
  FORWARD-ONLY (nothing about `⊡(P p)`, no symmetry implied) and the one-fixture/one-seam/one-`φ`
  qualifier. An expansion, never a substitution.
- **Phase 7 Scope Hypothesis CONFIRMED on both counts** — the first phase of this record whose
  line estimate held. Predicted 40-70 added lines; the headline sub-step is `+69 / -0` by
  `git diff --stat`, with the header-correction sub-step adding a further `+32 / -17` for
  `+101 / -17` across the phase. Predicted axiom profile
  `[propext, Classical.choice, Quot.sound]` and nothing more: CONFIRMED from the `#print axioms`
  output itself, no fourth axiom, no pin edited to match a prediction.

## Verification

- Build: Success. Scoped `FormalSystem.Metalogic.Decidability.RaySummary.Trace` (guard exit 0,
  1929 jobs); the two plan-enumerated direct dependents
  `FormalSystem.Metalogic.Decidability.RaySummary` (guard exit 0, 1931 jobs) and
  `BimodalTest.Metalogic.KTypeSummaryAxiomTest` (guard exit 0, 2178 jobs); and the full project
  (guard exit 0, 2836 jobs, `Build completed successfully`). Zero `error:` lines across every
  captured stream. `Trace.olean` is newer than `Trace.lean`.
- Sorry count: 0, repo-wide, via `lean-sorry-census.sh --cross-check` over all eight resolved
  source roots — `stripper_sorry_count: 0`, `compiler_sorry_count: 0`, `cross_check: MATCH`.
- Sorry inventory: empty. None introduced, none inherited.
- Vacuous count: 1, unchanged from `HEAD~1` and pre-existing —
  `FormalSystem/Examples/TemporalStructures.lean`'s `int_domain_universal`, where
  `intTimeHistory.domain t` genuinely reduces to `True`, so `trivial` is the honest proof. Zero
  introduced by this phase; the baseline is reported rather than rounded to 0.
- Axiom count: 14, unchanged from `HEAD~1` (verified by `git grep` at both revisions). No `axiom`
  added.
- Axiom foot: `#print axioms …hitPresented_of_presented` reports exactly
  `[propext, Classical.choice, Quot.sound]` — the list the plan's Phase 1 verification requires.
- Statement fidelity: both signatures confirmed against the plan's
  `## Lean Challenge Statements` entries by `#check @…` against the live build — same binders,
  same instance binders, same order, same conclusion.
- Comparator gate: not run. `compare_flag` is absent from the delegation context, so the gate's
  precondition is unmet and no `comparator` block is recorded.

### Phase 2 verification (dispatch 6)

- Probe compile: `lake env lean specs/evidence/seam-gluing-ray-product/hit-presented-model-a.lean`
  through `lake-build-guard.sh`, detached, guard exit 0. Captured output is exactly the three
  `#print axioms` info lines — zero errors, zero warnings.
- Full project build re-run after the phase: guard exit 0, `Build completed successfully
  (2836 jobs)`, zero `error:` lines over both captured streams, `Trace.olean` newer than
  `Trace.lean`. Phase 2 touched no file in the Lake build graph (the probe is under `specs/`,
  which no Lake target root reaches), so this re-run confirms no regression rather than new
  coverage.
- Sorry count: 0, repo-wide, re-run via `lean-sorry-census.sh --cross-check` over all eight
  resolved source roots — `stripper_sorry_count: 0`, `compiler_sorry_count: 0`,
  `cross_check: MATCH`. `grep -c sorry` on the probe is 0.
- Vacuous count: 1 — unchanged, still the same pre-existing `int_domain_universal`. Zero in the
  probe.
- Axiom count: 14 — unchanged. No `axiom` added.
- Axiom foot, observed not predicted: `Probe745.path_classify`, `Probe745.stayA` and
  `Probe745.jump` each report exactly `[propext, Classical.choice, Quot.sound]`.
- Statement fidelity: `path_classify`'s landed signature was extracted from the probe and from the
  plan's `## Lean Challenge Statements` block and diffed mechanically — byte-identical, no added
  hypothesis, no specialized quantifier, no weakened conclusion.
- `lean-challenge-snapshot.sh --check`: UNAVAILABLE, not green. No snapshot manifest exists at
  `specs/745_hit_level_completeness_computable_bound/challenge/manifest.json` (none was taken at
  plan time), so the script refuses. The plan lists this check as ADVISORY; the mechanical diff
  above stands in its place for the one signature this phase lands.
- `Probe735.not_presented` untouched: `presented-not-complete.lean`'s last commit is still task
  735's own wiring commit, and nothing in the new probe imports, weakens or contradicts it.

### Phase 3 verification (dispatch 7)

- Probe compile: `lake env lean specs/evidence/seam-gluing-ray-product/hit-presented-model-a.lean`
  exit 0. Captured output is exactly the `#eval` line (`4`) and the six `#print axioms` info lines
  — zero lines matching `error` or `warning`.
- Full project build re-run after the phase, detached through `lake-build-guard.sh`: guard exit 0,
  `Build completed successfully (2836 jobs)`, zero `error:` lines over the captured stream,
  `Trace.olean` (mtime 1791503825) newer than `Trace.lean` (1791503801). Phase 3 touched no file in
  the Lake build graph — the probe is under `specs/`, which no Lake target root reaches — so this
  re-run confirms non-regression rather than new coverage.
- Sorry count: 0, repo-wide, via `lean-sorry-census.sh --cross-check` over all eight resolved
  source roots — `stripper_sorry_count: 0`, `compiler_sorry_count: 0`, `cross_check: MATCH`.
  `grep -c sorry` on the probe is 0.
- Vacuous count: 1 — unchanged, still the same pre-existing `int_domain_universal`. Zero in the
  probe.
- Axiom count: 14 — unchanged. No `axiom` added.
- Axiom foot, observed not predicted: `Probe745.splice_classify`, `Probe745.clTrace_stayA_eq` and
  `Probe745.clTrace_jump_eq` each report exactly `[propext, Classical.choice, Quot.sound]`, as do
  the three phase-2 pins re-run in the same compile.
- Statement fidelity: `splice_classify`'s landed signature was extracted from the probe and from
  the plan's `## Lean Challenge Statements` block and compared by whitespace-normalized mechanical
  diff — identical, no added hypothesis, no specialized quantifier, no weakened conclusion.
- Closure-size figure: the plan's CARRIED-UNVERIFIED entry is now RE-DERIVED.
  `#eval (plusSubformulaClosure Fp).card` = 4, and `PlusFormula.subformulas Fp` printed as
  `[Fp, atom p, ⊤, ⊥, ⊥]`, so the four closure members are exactly those the plan names. The
  `#eval` is left live in the probe beside the case split, as the phase's verification requires.
- No `kTypeOf` evaluation and no `decide` over `KType` anywhere in the added proof: the file's only
  `KType` occurrence is a docstring sentence stating that fact.
- `lean-challenge-snapshot.sh --check`: UNAVAILABLE, not green — still no manifest at
  `specs/745_hit_level_completeness_computable_bound/challenge/manifest.json`. The mechanical diff
  above stands in its place for the one signature this phase lands.
- Comparator gate: not run. `compare_flag` is absent from the delegation context, so the gate's
  precondition is unmet and no `comparator` block is recorded.

### Phase 4 verification (dispatch 8)

- Probe compile: `lake env lean specs/evidence/seam-gluing-ray-product/hit-presented-model-a.lean`
  exit 0. Captured output is exactly the `#eval` line (`4`) and the seven `#print axioms` info
  lines — zero lines matching `error` or `warning`.
- Full project build re-run after the phase, detached through `lake-build-guard.sh`: guard exit 0
  (Tier 1), `Build completed successfully (2836 jobs)` with zero `error:` lines over the captured
  stream (Tier 2), `Trace.olean` newer than `Trace.lean` (Tier 3). Phase 4 touched no file in the
  Lake build graph — the probe is under `specs/`, which no Lake target root reaches — so this
  re-run confirms non-regression rather than new coverage.
- Sorry count: 0, repo-wide, via `lean-sorry-census.sh --cross-check` over all eight resolved
  source roots — `stripper_sorry_count: 0`, `compiler_sorry_count: 0`, `cross_check: MATCH`. The
  probe's two `grep -n sorr` hits are both prose (the header's "zero sorries" and the new
  section's "cited or `sorry`-ed here").
- Vacuous count: 1 — unchanged, still the same pre-existing `int_domain_universal`. Zero in the
  probe.
- Axiom count: 14 — unchanged. No `axiom` added.
- Axiom foot, observed not predicted: `Probe745.hitCl_eq_truncated` reports exactly
  `[propext, Classical.choice, Quot.sound]`, as do the six earlier pins re-run in the same compile.
- Statement fidelity: `hitCl_eq_truncated`'s landed signature was extracted from the probe and from
  the plan's `## Lean Challenge Statements` block and compared by whitespace-normalized mechanical
  string comparison — identical, including the `∃ L : ℕ` prefix and the `hk` binder name. No
  supplied or computed `L`, no added hypothesis, no weakened conclusion.
- No `kTypeOf` evaluation and no `decide` over `KType` anywhere in the added region: grep over
  lines 462+ returns only the two prose occurrences, which name them as what is NOT done.
- `lean-challenge-snapshot.sh --check`: UNAVAILABLE, not green — still no manifest at
  `specs/745_hit_level_completeness_computable_bound/challenge/manifest.json`. The mechanical
  comparison above stands in its place for the one signature this phase lands.
- Comparator gate: not run. `compare_flag` is absent from the delegation context, so the gate's
  precondition is unmet and no `comparator` block is recorded.

### Phase 5 verification (dispatch 9)

- Probe compile: `lake env lean specs/evidence/seam-gluing-ray-product/hit-presented-model-a.lean`
  through `lake-build-guard.sh`, un-piped, guard's own exit 0. Captured output is exactly the
  `#eval` line (`4`) and the eleven `#print axioms` info lines — zero lines matching `error`,
  `warning` or `sorry`. Both `#guard`s pass: a failing `#guard` is a compile error, so
  `(plusSubformulaClosure Fp).card = 4` and `Fintype.card (QA 2) = 8` are checked, not asserted.
- Ordered prerequisite honoured: `(plusSubformulaClosure Fp).card` was re-derived live as `4` via
  `lean_run_code` against the built `.olean`s BEFORE the flag table was written, which is the
  order the plan's item specifies. The same snippet confirmed `Fintype.card (Fin 3 ⊕ Fin (2+3))`
  is `8` by `#eval` and by `decide`. Table completeness does not in fact rest on that figure:
  `letter_cases` is the machine-checked five-case exhaustion of `(clSig Fp).preds` and the table
  carries one branch per case.
- Full project build re-run after the phase, detached through `lake-build-guard.sh`: guard exit 0
  (Tier 1), `Build completed successfully (2836 jobs)` with zero `error:` AND zero `warning:`
  lines over the captured stream (Tier 2). Phase 5 touched no file in the Lake build graph — the
  probe is under `specs/`, which no Lake target root reaches — so this is non-regression evidence,
  not new coverage.
- Sorry count: 0, repo-wide, via `lean-sorry-census.sh --cross-check` over all eight resolved
  source roots — `stripper_sorry_count: 0`, `compiler_sorry_count: 0`, `cross_check: MATCH`. The
  probe's single `grep -n sorry` hit is prose (the header's "cited or `sorry`-ed here").
- Vacuous count: 1 — unchanged, still the same pre-existing `int_domain_universal`. Zero in the
  probe.
- Axiom count: 14 — unchanged. No `axiom` added.
- `labOf` and `stepOf` are plain `def`: a regex sweep for `noncomputable\s+def\s+(labOf|stepOf)`
  over the probe returns nothing.
- Axiom foot, observed not predicted: `Probe745.stepOf` reports `[propext]` — choice-free, as the
  step relation is pure `Fin`/`ℕ` combinatorics touching no semantics. `Probe745.labOf`,
  `Probe745.labOf_inl_iff_clTrace_stayA` and `Probe745.labOf_inr_iff_clTrace_jump` each report
  `[propext, Classical.choice, Quot.sound]`, as do the seven earlier pins re-run in the same
  compile.
- Statement fidelity: the pinned `QA`, `labOf` and `stepOf` signatures were extracted from the
  plan's `## Lean Challenge Statements` block and from the probe, whitespace-normalized, and
  compared mechanically in python — all three present and identical. No added hypothesis, no
  specialized quantifier, no weakened conclusion.
- Plan-compliance spot-check: all twenty-three declarations the phase's checklist and annotations
  name are present in the probe as named declarations, confirmed by regex sweep.
- Prose audit of the added region: the only `decidab*` match across the diff's added lines is the
  type-class name `DecidableEq`; zero matches for `decision procedure` or `PlusValidZTime`. No
  decidability claim was introduced.
- `lean-challenge-snapshot.sh --check 745 <root>`: UNAVAILABLE, not green — exit 71, `no manifest
  found at specs/745_hit_level_completeness_computable_bound/challenge/manifest.json`. The
  mechanical comparison above stands in its place, and the gap is recorded in the issue log.
- Comparator gate: not run. `compare_flag` is absent from the delegation context, so the gate's
  precondition is unmet and no `comparator` block is recorded. Were it ever set for this task, the
  missing manifest would make it return the preflight verdict `challenge_missing`.

### Phase 6 verification (dispatch 10)

- Probe compile: `lake env lean specs/evidence/seam-gluing-ray-product/hit-presented-model-a.lean`
  through `lake-build-guard.sh`, un-piped, guard's own exit 0. Captured output is exactly the
  `#eval` line (`4`) and the thirteen `#print axioms` info lines — zero lines matching `error` or
  `warning`. Both `#guard`s pass (a failing `#guard` is a compile error), so
  `(plusSubformulaClosure Fp).card = 4` and the `L = 2` branching count `3` are checked, not
  asserted.
- Statement fidelity: the pinned `runTrace_mem_of_isRun` and `exists_isRun_runTrace` signatures
  were extracted from the plan's `## Lean Challenge Statements` block and from the probe,
  whitespace-normalized, and compared mechanically in python — both MATCH, character for
  character after whitespace normalization. Neither has gained a hypothesis nor specialized a
  quantifier relative to the pin.
- `lean-challenge-snapshot.sh --check 745 <root>`: UNAVAILABLE, not green — exit 71, `no manifest
  found at specs/745_hit_level_completeness_computable_bound/challenge/manifest.json`, unchanged
  from phase 5. The mechanical comparison above stands in its place.
- Axiom foot, observed not predicted: `Probe745.runTrace_mem_of_isRun` and
  `Probe745.exists_isRun_runTrace` each report `[propext, Classical.choice, Quot.sound]` — no
  `sorryAx`. `Classical.choice` enters through `inr_post_threshold`'s `Nat.find` bookkeeping and
  through the inherited `clTrace`/`jump` terms, as in every earlier phase of this probe. The
  eleven earlier pins re-run in the same compile are unchanged.
- Full project build re-run after the phase, detached through `lake-build-guard.sh`: guard exit 0
  (Tier 1), `Build completed successfully (2836 jobs)` with zero `error:` AND zero `warning:`
  lines over the captured stream (Tier 2). Tier 3 has no module to check for this phase: the only
  file modified is under `specs/`, which no Lake target root reaches, so this is non-regression
  evidence rather than new coverage — stated rather than implied.
- Sorry count: 0, repo-wide, via `lean-sorry-census.sh --cross-check` over all eight resolved
  source roots — `stripper_sorry_count: 0`, `compiler_sorry_count: 0`, `cross_check: MATCH`. The
  probe's single `grep -n sorry` hit is still the Phase-4 prose at line 483.
- Vacuous count: 1 — unchanged, still the same pre-existing `int_domain_universal`. Zero in the
  probe.
- Axiom count: 14 — unchanged. No `axiom` added.
- Plan-compliance spot-check: both pinned names present as named `theorem` declarations in the
  probe, and all eighteen declarations the phase's checklist and annotations name are present,
  confirmed by regex sweep.
- Prose audit of the added region: zero matches across the 413 added lines for `decidab`,
  `PlusValid`, `complexity`, `EXPTIME`, `2EXP`, `Buchi`/`Büchi`, `MSO`, `finite width`,
  `finite fibre` or `decision procedure`. No decidability claim, no complexity bound, no external
  automata-theoretic citation standing in for a proof.
- Comparator gate: not run. `compare_flag` is absent from the delegation context, so the gate's
  precondition is unmet and no `comparator` block is recorded.
- Territory: working tree clean of foreign modifications at dispatch start and at commit time
  apart from `specs/events.jsonl`, which is the orchestrator's own writer and was deliberately
  left unstaged. No foreign commit and no foreign build was observed.

### Phase 7 verification (dispatch 11)

- **Probe compile**: `lake env lean specs/evidence/seam-gluing-ray-product/hit-presented-model-a.lean`
  through `lake-build-guard.sh`, un-piped, detached. Guard exit 0 on both rounds (headline, then
  header edits). Captured output is exactly the `#eval` line (`4`) and fourteen `#print axioms`
  info lines; zero `error:`, zero `warning:`, no `sorryAx`; both `#guard`s pass. **Green on the
  first round, with no tactic iteration.**
- **Pinned signature**: MATCH, by whitespace-normalized python string comparison of the landed
  `hitPresented_modelA` declaration against the plan's `## Lean Challenge Statements` block —
  including the `∃ L : ℕ` prefix and the `hk` binder name. The advisory
  `lean-challenge-snapshot.sh --check 745 <root>` gate remains UNAVAILABLE for this task
  (exit 71: no manifest at `specs/745_…/challenge/manifest.json`; the snapshot was never taken
  at plan time), so the string comparison is its substitute, as in every earlier phase.
- **Axiom profile, OBSERVED not predicted**: `hitPresented_modelA` reports exactly
  `[propext, Classical.choice, Quot.sound]`. No fourth axiom appeared, so no pin was edited to
  match a prediction. Incidental finding recorded rather than smoothed over: `stepOf` reports
  `[propext]` ALONE; the header's axiom record now states that exception instead of claiming a
  uniform profile across all fourteen pins.
- **Full project build**: `lake-build-guard.sh build --timeout 1800 -- build`, un-piped,
  detached. Guard exit 0; `Build completed successfully (2836 jobs).`; zero `error:` and zero
  `warning:` over the captured stream. **Non-regression only** — phase 7 touched no file in the
  Lake build graph (the probe lives under `specs/`, which no Lake target root reaches), so Tier 3
  has no module of this phase's to check.
- **Repo-wide censuses** over the eight roots `lean-src-roots.sh` resolves: `sorry_count` 0 with
  `cross_check: MATCH` (compiler 0, stripper 0); `vacuous_count` 1 (the pre-existing
  `int_domain_universal`, unchanged by this phase; zero in the probe); `axiom_count` 14,
  unchanged from baseline — no axiom added.
- **Plan compliance**: `hitPresented_modelA` present as a named `theorem` at the verbatim pinned
  signature. All five phase-7 checklist items checked; three carry deviation annotations (binder
  form of the `∀` prose, the header's additive stale-statement correction, and the "short note"
  landing as a five-bullet section). No step skipped, deferred or re-routed. `git diff --stat`
  over the phase's two commits touches exactly one file — the one the plan's "Files to modify"
  names — and no file under any resolved source root.
- **Prose audit** of the 101 added lines: zero matches for `complexity`, `EXPTIME`, `2EXP`,
  `Buchi`/`Büchi`, `MSO`, `finite width`, `finite fibre`, `decision procedure`. Four matches for
  `decidab`/`PlusValid`, each inspected: one describes `stepOf` as a decidable `Bool`-valued
  table (not a decidability claim about L⁺), and three are explicit DISCLAIMERS in the pinned
  docstring and the "does NOT say" section.

## Impacts

- `path_classify` is the rigidity fact the whole positive construction rests on: it says the
  seam's step paths form a one-parameter family indexed by `w ≥ t` plus the constant path, and
  nothing else. Phase 3 has now turned it into a statement about the seam's SPLICES
  (`splice_classify`) through `seamOmegaEquiv` and `WorldHistory.ext_state`.
- `splice_classify` is what gives phase 4's classically-chosen per-member witnesses their natural
  offsets (`0` for `stayA`, `w - t` otherwise), which is the input `Set.Finite.bddAbove` is applied
  to in order to extract `L`. Without it the truncation argument has no index to bound.
- `clTrace_stayA_eq` and `clTrace_jump_eq` give both splice families' closure traces as explicit
  lambdas, so phase 6's `runTrace (labOf L) ρ = clTrace MA Fp t …` obligations are rewrites against
  a closed form rather than semantic arguments. `clTrace_jump_apply` additionally isolates the only
  `w`-dependence in a jump trace — the `p` letter's threshold — which is the single feature phase
  5's presentation has to reproduce.
- `hitCl_eq_truncated` is what phases 5-7 consume: it fixes the FINITE index (`stayA` plus
  `jump w` for `t ≤ w ≤ t + L`) that phase 5's `L + 6`-state presentation is built to realize and
  that phase 6's run characterization must match exactly. It also fixes, once and for all, the
  shape of this record's headline: because `L` arrives unexhibited, `hitPresented_modelA` can only
  ever be an `∃ L` statement, and any later phase that appeared to supply an `L` would be proving
  a different, stronger theorem than this plan authorizes.
- The bound verdict is now machine-visible rather than argued, in the only sense available: the
  landed theorem's `∃ L` prefix states the non-exhibition in the statement, and its axiom foot
  carries `Classical.choice`. Non-existence of a computable bound remains not a Lean-statable
  property, so this is the substitute the user approved in cycle 1, not a discharge of acceptance
  branch 3's literal wording.
- The probe is NOT yet in any gate: it lives under `specs/`, which no Lake target root reaches, so
  `lake build` never compiles it and it can rot silently until phase 8 wires it into
  `scripts/check-evidence-probes.sh`. Until then its only check is the explicit `lake env lean`
  compile line in its own header.
- `HitPresented` is now a declaration in `FormalSystem.Metalogic.Decidability.RaySummary`, so
  phases 2-7's probe can discharge a library name rather than a local one, and the ray-product
  verdict's requirement (C) has a formal statement to be measured against.
- `hitPresented_of_presented` fixes the hypothesis ordering formally: anything proved under
  `Presented` transfers to `HitPresented` at `k ≥ 1` for free, so the two hypotheses need not be
  carried separately downstream.
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` now contains a FALSE claim in three
  places — the `(C)` requirements-table row and two prose occurrences say `HitPresented` "is not
  a declaration in this tree". Phase 8 owns that README update; flagged in the phase handoff.

- Phase 6 closes the one link the research left uncompiled. With `runTrace_mem_of_isRun` and
  `exists_isRun_runTrace` in hand, the presentation's anchored run traces are pinned to exactly
  the family `hitCl_eq_truncated` describes, so Phase 7's `hitPresented_modelA` is a composition
  through `mem_hitOf_iff` with no remaining mathematical gap — the open question that remains is
  the bound, which this phase neither addresses nor weakens.
- `inr_fwd_index`'s shape (a mid chain whose index strictly increases until an absorbing state,
  so the walk is capped by the chain's length) is the reusable part of this phase for any later
  presentation-side argument on this fixture family; it is a fact about `stepOf`'s gadget 2 and
  nothing in it survives replacement of the step table.

## Follow-ups

- Phases 6-8 of `plans/01_hit-presented-model-a.md`, all `[NOT STARTED]`. Phase 6 (the run
  characterization) is next and touches only the probe file. Its `⊆` route is now fully stocked:
  `labOf_now` turns `IsRun`'s marker condition into "the state index is `1` exactly at `z = t`";
  `stepOf_no_cross` at any one `z` fixes the gadget for all of `ℤ`; `stepOf_inl_inl_iff` /
  `stepOf_inr_inr_iff` give the index-level edges, and the gadget-2 chain forces `j_post` to be
  reached at some `t + d` with `0 ≤ d ≤ L` (that `d` is the conclusion's `w`); then
  `runTrace_inl_eq` / `runTrace_inr_eq` discharge the trace equality as a rewrite.
- Two orientation traps for phase 6, both met in phase 5: `simp` will not use a `Ne` simp lemma
  in the reverse direction, so any new `labOf` branch needs its reverse-direction disequality
  supplied explicitly; and `letter_cases`'s disjunct order is `now, Fp, p, top, bot`, which is
  NOT `labOf`'s source order (`now, top, Fp, p, bot`), so an `rcases letter_cases` does not line
  up branch-for-branch with the table.
- The `∃ L` shape is now load-bearing for phase 7: `hitPresented_modelA` must keep its own `∃ L`
  prefix, because `hitCl_eq_truncated` supplies no `L` to pass down. A phase 7 that appeared to
  exhibit an `L` would be landing a theorem this plan does not authorize.
- Phase 6's run characterization remains the plan's single Medium-confidence, uncompiled link. If
  it cannot be carried out as written, the plan requires marking it `[BLOCKED]` rather than
  substituting the rejected `mem_hitOf_iff_live` route or weakening the pinned statement.
- Phase 8 owes: the README verdict update, `docs/theorem-index.md` rows for both new
  declarations, axiom pins in `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` in the
  same commit as the index rows, and the recorded bound verdict. Both docstrings already end with
  a `Paper: —` anchor line so the index rows are admissible when they land.
- `stepOf_no_cross` is the single fact that makes Phase 6's run characterization tractable: it
  lets one observation of a run's gadget at ONE time fix its gadget at EVERY time, so the two
  branches of the conclusion (`stayA`'s trace, or one `jump w`) are genuinely exclusive rather
  than requiring a global argument.
- `runTrace_inl_eq` and `runTrace_inr_eq` are stated with the position correspondences as
  hypotheses rather than against a concrete run, so Phase 6 can supply whichever run function it
  constructs without the bridge having to anticipate its shape.
- `card_QA` makes the state count a NAMED, machine-checked function of `L`. That is deliberately
  not a bound and must not be read as one: `L` is `hitCl_eq_truncated`'s unexhibited witness, so
  `L + 6` is a function of something no proof in this tree produces. Phase 7's docstring and
  Phase 8's index row both owe that qualifier.
- The `typst-sync-check.sh` Check 2 gate blocks a commit only when `FormalSystem/` line counts
  drift; phases 2 and 3 both confirmed it does not fire for the `specs/`-resident probe, so phases
  4-7 need not budget for it. Phase 8's `Tests/` axiom-pin edit may still trip it.
- RESOLVED: the ten distinctness lemmas phase 3 landed (`now_ne_*`, `Fp_ne_*`, `p_ne_*`,
  `top_ne_bot`) are no longer dead. Phase 5 uses all ten — four directly in `labOf_inl`/
  `labOf_inr`'s `simp` sets, and all ten as the sources of the nine `.symm` aliases the flag
  table's `if`-chain orientation requires. The removal this follow-up contemplated must NOT
  happen.
- No Challenge snapshot manifest exists for this record, so the advisory
  `lean-challenge-snapshot.sh --check` drift gate is unavailable for all 17 pinned identifiers.
  Each phase has been diffing its own landed signature against the plan's pin by hand instead.

## References

- `specs/745_hit_level_completeness_computable_bound/plans/01_hit-presented-model-a.md` — the plan,
  Phase 1 and the `## Lean Challenge Statements` pins.
- `specs/745_hit_level_completeness_computable_bound/reports/01_hit-level-completeness-probe.md` —
  the research the plan executes.
- `specs/745_hit_level_completeness_computable_bound/handoffs/phase-1-handoff-20261008T235902Z.md`,
  `handoffs/phase-2-handoff-20261009T001229Z.md`,
  `handoffs/phase-3-handoff-20261009T003531Z.md` and
  `handoffs/phase-4-handoff-20261009T005104Z.md` — the four phase-end handoffs, each with its next
  action and carried constraints.
- `specs/745_hit_level_completeness_computable_bound/issues.jsonl` — the three scope-hypothesis
  overruns, the pre-commit gate collision, phase 3's first-try-compile win, and phase 3's
  `[IN PROGRESS]`-marker process deviation.
- `FormalSystem/Metalogic/Decidability/RaySummary/Trace.lean` — the two new declarations.
- `specs/evidence/seam-gluing-ray-product/hit-presented-model-a.lean` — the probe: header,
  fixture, `path_classify`, `splice_classify`, and the closure-letter read-out.
- `specs/evidence/seam-gluing-ray-product/presented-not-complete.lean` — `Probe735.not_presented`,
  the trace-level refutation these docstrings and the new probe's header are careful not to
  weaken, and the transcription source for the fixture.
