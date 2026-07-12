# Research Report: Task #352 — Build depth-k navigated exterior negation clause layer via ExistProviders

- **Task**: 352 - Build depth-k navigated exterior negation clause layer via ExistProviders
- **Started**: 2026-07-12
- **Completed**: 2026-07-12T19:32:00Z
- **Effort**: Team research (4 teammates, hard-mode lean4)
- **Dependencies**: task 349 (blocked on this task, Phase 2 re-dispatch); task 309 (downstream consumer of 349)
- **Sources/Inputs**: teammate findings A-D (below); `specs/349_.../reports/11_spawn-analysis.md`;
  `specs/349_.../handoffs/v7-phase2-blocked-1783882788.json`; `specs/349_.../plans/07_enriched-bracket-carrier.md`
  Phase 2 BLOCKER block (cited by teammates, not re-read directly by synthesis); direct Lean reads
  performed by teammates: `PriorInterface.lean`, `ExteriorBracketK.lean`, `ExteriorNegation.lean`,
  `ExteriorNegationPast.lean`, `NfEFold.lean`, `RefutationF2.lean`, `KampPrior.lean`, `OuterGate.lean`,
  `ExteriorBracket.lean`, `NfZoneDepthK.lean`.
- **Artifacts**: this file; source teammate findings `01_teammate-{a,b,c,d}-findings.md`
- **Standards**: report-format.md, artifact-formats.md

## Executive Summary

- Task 352's premise is **sound**: the `ExistProviders` dependency-inversion interface (`PriorInterface.lean:38-46`)
  is the correct, already-load-bearing channel, threading cleanly at the right depth (`k`) and scope
  (standalone leaf module, no mutual recursion with `endInterval`). Teammates A, C, D converge on this.
- The single point of genuine risk — and the crux the whole task turns on — is a **discipline failure**,
  not a wall: the landed depth-k determinacy core (`kvE_subBit`, `kvE_futAnyBit`, `kvE_projFreshD`) is
  **marginal navigation/enumeration scaffolding**, not a content channel. If the clause's exclusion
  predicate is built from these marginal bits (keyed on a projected `χ : NormalForm sig k 1`), the F2
  counterexample reproduces one rung up and 352 re-blocks exactly as 349 Phase 2 did. The clause's
  truth-bearing content must instead come from `P.existF` applied directly to each **full fiber
  element** `s : NormalForm sig k 5` with `σ.2 s = true` — a finite (Fintype-backed) disjunction over
  the whole fiber, never a disjunction indexed by collapsed marginal profiles.
- Line-count estimate: **~1800-2600 lines** (not a flat ~2000). The swing factor is whether the
  P-stratum can reuse `nf_succ_char_formula`'s existing arity-2-converter shape as-is, or needs a new
  "existF-fold over a Fintype fiber" combinator (the corrected discipline above implies the latter,
  adding scope B did not budget).
- A **pre-build verification gate is warranted and should run before Phase 2/3** of the 5-phase build:
  a small, targeted Lean probe (re-run the F2 counterexample pair against the *corrected* full-fiber
  `existF`-disjunction construction and confirm it now distinguishes them) plus one dedicated
  adversarial re-read of Rabinovich Lemma 7.8's proof to confirm it consumes only rung-k formulas
  (not rung-k brackets). This is cheap (~150-300 lines / one reading pass) insurance against discovering
  the same wall after a 2000+ line commitment.
- Recommend a new guard **G6**: "no clause-content position may render a formula from a projected/marginal
  profile (`kvE_subBit`, `kvE_futAnyBit`, `kvE_projFreshD` outputs); every content-bearing disjunct
  must apply `P.existF` to a full fiber element directly. Marginal reads are permitted only for zone
  classification, admissibility bucketing, and chain-assembly order."

## Context & Scope

Task 352 builds the depth-k generalization of the frozen k=2 exterior negation clause layer
(`ExteriorNegation.lean` / `ExteriorNegationPast.lean`, 2844 lines combined), parameterized by
`P : ExistProviders sig atomMap k`, to unblock task 349 Phase 2's four bracket lemmas
(`kvE_extBracketPast/Fut_sound/complete`). Four teammates investigated: A (ExistProviders channel
adequacy), B (frozen-layer generalization template + candidate architectures), C (adversarial critic
of the whole premise, including the F2 obstruction), D (module architecture, decomposition, roadmap fit).
All four are read-only Lean research; no code was written or built by this synthesis or by the teammates.

## Key Findings

### Teammate A — Primary: the ExistProviders channel (confidence: HIGH)

- `ExistProviders` (`PriorInterface.lean:38-45`) is a two-field bundle: `existF (n) : NormalForm sig k (n+1) → Formula`
  (an all-arity, depth-k, lossless single-anchor existential converter) + `correct` (the exact
  truth-semantics biconditional against `nf_eval_nf`).
- `P.existF 0 : NormalForm sig k 1 → Formula` is the depth-k generalization of `nf_depth0_char_formula`
  (KampPrior.lean:936-960; already used this way by the interior gate, `OuterGate.lean:79`).
- The two depth-0 hardwirings in the frozen clause layer (formula source via `nf_depth0_char_formula`,
  and profile-list reads via `nf0_assemble`'s depth-0-only-lossless coordinatization) are individually
  replaceable: formula source → `P.existF 0`; profile-list reads → `kvE_subBit`/`kvE_projFreshD`
  (full-arity fiber-existential, already landed and green in `ExteriorBracketK.lean`).
- `P` is in scope at the recursion site (`kampPrior_existProviders_of_ih`, KampPrior.lean:895-907; the
  `∀k` fixpoint lives in KampPrior's `Nat.rec`, structurally available for `j ≤ k` at the `|k+1=>` arm).
- Interface (KF3) proposes concrete signatures for `kvE_futPos`, `kvE_extNegFut`, `_sound`, `_complete`
  parameterized by `P`, mirroring `ExteriorBracket.lean:432-615`'s consumption pattern.
- A's own confidence caveat: "the residual is construction... not a semantic obstruction" — confidence
  is on channel adequacy and interface shape, explicitly **not** on the line-count estimate. A also
  flags (open question 3, to the "faithfulness teammate") the exact question C independently pursued:
  whether `existF 0` as a black box under-specifies the paper's device.

### Teammate B — Frozen k=2 template + prior art + architectures (confidence: HIGH on strata/verdicts, MEDIUM on line-count/arity)

- Three-stratum decomposition of the frozen layer: **V** (profile-agnostic combinators — zone/order
  classification, chain build/destruct, min-pick — generalize verbatim, roughly half the volume), **L**
  (mechanical substitution via already-landed depth-k core: `kvE_subBit` for `σ.2 (nf0_assemble …)` reads,
  `kvE_futAnyBit`/`kvE_projFreshD` for the zone-fact pins), **P** (genuine new construction: the
  TL-formula-building layer, needs `nf_succ_char_formula` (KampPrior.lean:67) + `ExistProviders`).
- Per-step V/L/P table (file:line-cited) is the most granular artifact any teammate produced and is
  reused directly in this synthesis's decomposition below.
- A3 ("thin adapter over the frozen layer via `nfk_truncD` shadows") is **provably dead** — confirmed
  independently by C and by the original blocker record (plan-07 BLOCKER (ii)).
- B's own open questions (esp. #2: "at which `existF` arity does the clause layer consume the provider?
  Confirm `existF 1` supplies exactly the arity-2 shape `nf_succ_char_formula` wants") are the exact
  point Conflict 1 below overturns: B assumed the P-rows render `existF` of a **marginal** profile
  `χ : NormalForm sig k 1`, which is the discipline C shows is insufficient.

### Teammate C — Critic (confidence: HIGH on the diagnosis, MEDIUM-HIGH on the existF-sufficiency claim)

- Reproduced the F2 obstruction directly against the real definitions (not the handoff's summary):
  `f2_sub_proj_eq` (RefutationF2.lean:471) shows two distinct depth-1 arity-4 subs sharing every
  marginal read channel (atom layer + fresh projection) but differing in deeper joint content;
  `f2_carrier_eq` (:582) machine-proves the frozen carrier assigns them the same value while only one
  is realized — a genuine soundness-direction failure, not a heuristic worry.
- Central finding: resolution (a) escapes F2 **only if** the clause pins each exterior sub's full joint
  quant-layer content via `existF`-folds over the sub's **own fiber** — not via the landed core's
  marginal bits (`kvE_futAnyBit`/`kvE_subBit`, both keyed on `χ : NormalForm sig k 1`, both routing
  through the G1-forbidden-in-content-position `nfk_projFresh`). Wiring the bracket to the marginal
  bits reproduces the identical F2 pattern one rung up.
- Verdict on existF-sufficiency (refutation attempt 2, the (a)-is-secretly-(b) risk): **converters
  suffice** — Rabinovich Def 7.5/7.6/7.8/7.10's recursion threads rung-k **formulas**, not rung-k
  brackets, and `NormalForm sig k n`'s `Fintype` instance supports a finite Boolean/existF closure.
  Confidence Medium-High, explicitly flagged as the single claim most worth an independent second read.
- Line-count: frozen layer measured at 2844 lines (`ExteriorNegation.lean` 1735 + `ExteriorNegationPast.lean`
  1109); ~2000+ judged conservative given added UZ/SZ relativization, inductive scaffolding, and k=0
  recovery lemmas.
- Disputes the "byte-identical statement shape" framing in report 11: the bracket *lemma statements*
  must change (gain `P`, replace marginal `hbelow`); only the 7 frozen **provider files** +
  `KampPrior.lean` + `Lemma32Reduction.lean` must stay byte-identical.
- Proposes new guard **G6** ("no marginal bit in any clause-content position") and flags Q1
  (existF-sufficiency) as needing one dedicated adversarial re-read of Lemma 7.8's proof before the
  big build.

### Teammate D — Architecture, decomposition, roadmap (confidence: HIGH on structuring, MEDIUM-HIGH on line estimates)

- Standalone module, parameterized by `P : ExistProviders sig atomMap k`, is correct and decisive —
  not mutual with `endIntervalStep`. The apparent mutual-recursion tension is resolved by dependency
  inversion: the `∀k` fixpoint lives in KampPrior's `Nat.rec` (`PriorInterface.lean:25` states this
  verbatim), and both 352's clause layer and 349's carrier sit below it as provider-parametric leaves.
- Import DAG admits a new `ExteriorNegationK.lean` cleanly (no cycle): frozen clause layer is low in the
  DAG (0 `ExistProviders` references), `PriorInterface`/`ExteriorBracketK` sit strictly below a new leaf
  module.
- Plan v7 already anticipated this: Phase 3's `endIntervalStep` signature already carries `P`
  (plan v7:515-518); Phase 5 is already "provider-family parametric" (v7:603-612). Only Phase 2's
  *statement* needs the `P` parameter added — no deep plan-v7 restructure.
- Proposed 5-phase / diamond decomposition (Phase 1 skeleton → Phase 2/3 parallel Future/Past →
  Phase 4 interface exposition → Phase 5 audit), **~1500-2250 lines**, with the Future/Past split
  parallelizable under an H7 territory contract.
- 352 sits on the critical path: `352 → 349 Phase 2 re-dispatch → 349 Phases 3-6 → 309 Phase 14/19 →
  KampPrior:353/:354 n≥2 arm → completeness_discrete`. Flags a naming-drift risk (349's description
  promises `endChar_correct`; plan v7 renamed to `endInterval_correct`) as a coordination item for 309,
  not 352's deliverable but on 352's path to surface.
- Flags the `ExistProviders`-shape contract with task 309 as the single most important cross-task
  constraint: 352 must consume the canonical `ExistProviders` record verbatim, not a bespoke one, or
  309's `Nat.rec`-supplied instance won't fit.

## Synthesis / Conflicts Resolved

### Conflict 1 — Reuse optimism (A) vs. F2 re-block risk (C): RULING — C's discipline is correct; A's channel-adequacy claim survives once corrected

**A's claim**: the landed determinacy core (`kvE_subBit`/`kvE_projFreshD`, full-arity fiber-existential)
"replaces the depth-0 reads" and the residual is "engineering-bounded."

**C's claim**: those same bits are keyed on `χ : NormalForm sig k 1` (an arity-1 **marginal**
projection), route through `nfk_projFresh` (the exact G1-forbidden F2 discriminator), and are honest
only *as marginals* — using them as clause content reproduces the identical F2 counterexample
(`f2_sub_proj_eq`, RefutationF2.lean:471) one rung up.

**Evidence check**: `kvE_subBit_iff` (ExteriorBracketK.lean:314-369) is a biconditional of the form
"∃ a sub `s` in σ's fiber with zone `zs` and fresh-profile `χ` ↔ `kvE_subBit σ zs χ = true`." This is
correct as a statement about σ, but it is an **existential over the marginal profile `χ`**: if two
subs `s₁ ≠ s₂` share `(zs, χ)` but differ in deeper joint coordinates (F2's exact construction), the
bit cannot distinguish them. B's own per-step table independently confirms the mechanism: B labels
the profile-list rows (`kvE2_futGapList`/`RayList`) as **L** — "universe `NF 0 1 → NF k 1`" — i.e. B's
own generalization iterates over the same marginal `χ : NormalForm sig k 1` type C flags as
insufficient for *content*. B is correct that this substitution is honest for **navigation/enumeration**
(deciding which profiles exist, matching the frozen layer's list-filter shape) but B did not separately
flag that the same collapsed type cannot also carry the clause's *separating power* — that is exactly
C's Key Finding 2/3 and refutation attempt 1.

**Ruling**: A's KF1/KF2/KF4 (channel exists, is in scope, threads correctly) stand. A's optimism about
"engineering-bounded residual" is correct *only* under the discipline C names: **`kvE_subBit`,
`kvE_futAnyBit`, `kvE_projFreshD` are zone-navigation/enumeration scaffolding — legitimate for deciding
which zone a sub falls in, which subs to visit, and chain-assembly order — but the clause's
truth-bearing content must be built as a finite disjunction of `P.existF` applied directly to each
**full fiber element** `s : NormalForm sig k 5` with `σ.2 s = true` (the actual positive-sub set,
a `Fintype`-backed finite list), never as a Boolean combination indexed by the collapsed marginal
profile `χ`.** Concretely: where the frozen layer's `nf0_assemble`-based bit read is depth-0-lossless
(marginal = joint at depth 0, per `NfEFold.lean:549-561` and C's independent confirmation), at depth
k the analogous *content* position must skip the marginal-profile indirection entirely and render
`P.existF` at the arity matching the full sub type. This is C's refutation-attempt-2 conclusion
("the escape requires... existF-converters folded over the sub's own fiber, NOT the landed marginal
bits") stated as a constructive rule rather than a negative result.

**Practical consequence for the plan**: B's Phase P-rows (`kvE2_futGapD`/`RayForm`/`futPos`,
ExteriorNegation.lean:1072-1132) should NOT be built as `nf_succ_char_formula … (P.existF 1) χ` for
`χ : NormalForm sig k 1` (B's proposed substitution, and A's open-question-2 framing). They should be
built as a disjunction/conjunction of `P.existF` over the elements of `{s : NormalForm sig k 5 |
σ.2 s = true}` directly, with the marginal `kvE_subBit`/zone machinery used only to partition/order
that fiber for the `D`-guarded Until-chain assembly (the V-stratum combinators, which are agnostic to
how their formula inputs were produced, remain reusable verbatim — B's V-row verdict is unaffected).

### Conflict 2 — Line-count: B's over-count claim vs. C's ~2000-conservative claim: RULING — 1800-2600 lines, swing factor = P-stratum combinator novelty

B argues ~2000 is an over-count because three of four "unbuilt" dependencies (fold bridge, determinacy
core, char-formula channel) are already landed/frozen-consumable, leaving only V-stratum retyping +
P-stratum threading. C argues ~2000 is conservative because the frozen file is 2844 lines and the
depth-k version adds inductive scaffolding, UZ/SZ relativization, and k=0 recovery lemmas on top.

**Ruling**: both are partially right, but the Conflict-1 resolution shifts the balance toward C's side.
B's estimate assumed the P-stratum could reuse `nf_succ_char_formula` (KampPrior.lean:67) as a
verbatim, or near-verbatim, parameter substitution — i.e., "just thread `P.existF 1` through the
existing combinator." Under the corrected discipline (content channel = existF-fold over the *full
fiber*, not a marginal-profile-indexed converter), `nf_succ_char_formula`'s existing shape (an
arity-2-existential-to-arity-1-NF converter) is not quite the right shape for "render a finite
disjunction over a Fintype fiber of arity-5 subs" — a new combinator is very likely needed for that
fold, which B's estimate did not budget. This adds scope beyond B's "parameterized reuse" framing, but
not to the degree of a full from-scratch rebuild, since the V-stratum (order/zone/chain-building,
genuinely reusable per both B and D) still accounts for roughly half the frozen volume.

**Range**: **1800-2600 lines**, centered near D's decomposition estimate (1500-2250) but shifted upward
by 200-400 lines to account for the full-fiber disjunction combinator the Conflict-1 ruling requires.
The swing factor is exactly this: if the full-fiber fold can be built as a thin wrapper reusing
`nf_succ_char_formula`'s correctness machinery (optimistic, B's assumption), the estimate sits near
1800-2100; if it needs a materially new combinator with its own soundness/completeness proof obligations
(the more likely reading of C's refutation), budget 2200-2600.

### Conflict 3 — existF-sufficiency ((a)-is-secretly-(b) risk): RULING — pre-build verification gate is warranted

C flags an explicitly unverified, load-bearing assumption: does Rabinovich's Def 7.5 rung-(k+1) bracket,
once negated (Lemma 7.8) and closed (Lemma 7.10), consume *only* canonical-expansion predicates
(⇒ `P.existF` suffices, resolution (a)), or does any step consume the rung-k bracket's own
`_sound`/`_complete` (⇒ `ExistProviders` is insufficient and 352 needs a richer bundle carrying
recursive bracket correctness, i.e. secretly resolution (b))? C's own confidence on this specific claim
is Medium-High — the weakest link in an otherwise High-confidence adversarial pass, and C explicitly
recommends a dedicated re-read before committing to the full build.

**Ruling**: yes, gate the build. The asymmetry is stark: the probe costs an estimated 150-300 lines of
targeted Lean + one focused re-read of a already-identified proof passage; being wrong costs an entire
~2000+ line committed rebuild that re-blocks at the exact same wall one abstraction higher, discovered
only after Phase 2/3 are substantially built. Given that 352 sits on the sole remaining path to
`completeness_discrete` (per D's roadmap finding) and that this exact wall has already blocked task 349
once, the cost asymmetry alone justifies gating.

**What the probe must establish** (two parts, both required before Phase 2/3 dispatch):

1. **Lean side (constructive check, ~150-300 lines)**: instantiate the corrected full-fiber
   `existF`-disjunction construction (Conflict 1's ruling) against the *existing* F2 counterexample
   pair (`f2qnf`/`f2qnf'`, RefutationF2.lean, already built and sorry-free) at the smallest live rung
   (k=1, i.e., building the depth-1 clause layer that 349 Phase 2 actually needs first). Prove that the
   corrected construction assigns `f2qnf` and `f2qnf'` **different** bracket truth values (the property
   the frozen/marginal construction was shown to lack). This is a small, targeted reuse of already-landed
   machinery — not a preview build of the full clause layer — and directly falsifies or confirms the
   Conflict-1 ruling before it is load-bearing across 2000+ lines.
2. **Literature side (proof-structure check, no Lean)**: one dedicated adversarial re-read of
   Rabinovich Lemma 7.8's proof (the negation-closure step) confirming every case of its induction
   (Case 1-3 + the structural-induction step, per C's citation of the Case 1-3 discussion) consumes
   rung-k **formulas** at each recursive appeal, never a rung-k bracket's `_sound`/`_complete` as a
   hypothesis. If any case is found to require the latter, resolution (a) is insufficient and the task
   must be re-scoped toward resolution (b) or (c) before any further Lean work.

If both checks pass: proceed to the 5-phase build as scoped below. If either fails: stop and re-dispatch
`/spawn 352` (or revise the parent 349 plan) before committing further lines — the corrected discipline
from Conflict 1 does not, by itself, guarantee existF-sufficiency; it only removes the specific
marginal-bit failure mode C identified.

## Recommended Construction Path

- **Module layout** (per D, uncontested by A/B/C): standalone leaf modules `ExteriorNegationK.lean`
  + `ExteriorNegationPastK.lean`, importing `PriorInterface` (for `ExistProviders`), the frozen clause
  layer read-only as a byte-identical template, and `ExteriorBracketK` (determinacy core, consumed
  verbatim for navigation only — see below). No `mutual` block; no changes to `endIntervalStep`'s
  existing value-level `Nat.rec`.
- **The F2-safe content channel** (per Conflict 1 ruling): the clause's exclusion/inclusion predicate
  is a finite disjunction of `P.existF` applied directly to each full fiber element
  `s : NormalForm sig k 5` with `σ.2 s = true` (the actual positive-sub set of `σ : NormalForm sig
  (k+1) 4`, `Fintype`-backed). `kvE_subBit`/`kvE_futAnyBit`/`kvE_projFreshD` are consumed **only** for
  zone classification, admissibility bucketing, and Until-chain assembly order — never as the source
  of a clause-content Boolean.
- **Interface signatures 349 Phase 2 consumes** (per A's KF3, adjusted for the corrected content
  channel — arity/shape of the formula-building step changes, the surrounding `_sound`/`_complete`
  signature shape does not):
  ```lean
  noncomputable def kvE_futPos {sig} {k}
      (atomMap : Formula → sig.preds) (h_surj : ∀ p, ∃ a : Atom, atomMap (.atom a) = p)
      (P : ExistProviders sig atomMap k) (σ : NormalForm sig (k+1) 4) : Formula
  noncomputable def kvE_extNegFut {sig} {k} (atomMap) (h_surj) (P) (σ) : Formula :=
      (kvE_futPos atomMap h_surj P σ).neg
  theorem kvE_extNegFut_sound {sig} {k} (M) (atomMap) (h_surj) (P) (h_UZ) (h_SZ)
      (σ) (w x t : M.carrier) (hxw hwt) (hcl) : ∀ x1, t < x1 → ¬ nf_eval_nf M (k+1) 4 … σ
  theorem kvE_extNegFut_complete {sig} {k} (M) (atomMap) (h_surj) (P) (h_UZ) (h_SZ)
      (qnf) (σ) (w x t) (hxw hwt) (henv) (hbelow : … full-fiber pin, NOT kvE_futAnyBit alone …)
      (hbase) (hb) (hno) : temporal_truth M atomMap t (kvE_futPos atomMap h_surj P σ)
  ```
  `hbelow`'s shape is the one place A's proposed signature (KF3, literal reuse of `kvE_futAnyBit_correct`
  as the pin) must be revised per the Conflict-1 ruling: the pin supplied to `_complete` must certify
  full-fiber content, not just the marginal `(zone, nfk_projFresh)` fact — `kvE_futAnyBit_correct` alone
  is necessary-but-not-sufficient scaffolding for this hypothesis, not the hypothesis itself.
- **Proposed guard G6** (verbatim per C, endorsed): *"No clause-content position may render a formula
  from a projected/marginal profile (any `kvE_subBit`/`kvE_futAnyBit`/`kvE_projFreshD` output used as a
  Boolean truth-value standing in for a sub's semantic realization). Every content-bearing disjunct
  must apply `P.existF` directly to a full fiber element. Marginal reads are permitted only for zone
  classification, admissibility bucketing, and chain-assembly order."* Add this to the plan's guard
  list (alongside G1-G5) before Phase 1 dispatch.

## Pre-build Verification Gate

See Conflict 3 ruling above for the full specification. Summary: **required, run as Phase 0 (or 1a)
before Phase 2/3**. Two parts: (1) a ~150-300 line Lean probe re-running the existing F2 counterexample
pair against the corrected full-fiber `existF`-disjunction construction, confirming it now distinguishes
`f2qnf`/`f2qnf'`; (2) one dedicated adversarial re-read of Rabinovich Lemma 7.8's proof confirming its
induction consumes only rung-k formulas, never a rung-k bracket's own soundness/completeness. Go/no-go:
proceed to the 5-phase build only if both pass; otherwise stop and re-scope via `/spawn` or plan revision.

## Risk Table

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| Clause content built over marginal `kvE_subBit`/`kvE_futAnyBit` bits (the naive, tempting reading — the bits are green and landed) | Medium-High (explicitly flagged by C as "the natural, tempting move") | Critical — re-blocks with F2 one rung up, discovered only after most of the build | Guard G6; pre-build probe (Conflict 3) validates the corrected construction before full build |
| `existF`-converters insufficient for Lemma 7.8 negation closure (secretly needs resolution (b), recursive bracket) | Low-Medium (C's confidence Medium-High that converters suffice) | Critical — entire task re-scopes to resolution (b), which entangles 352 with 349 Phase 3 | Pre-build literature re-read (Conflict 3, part 2) before Phase 2/3 dispatch |
| Line-count overrun beyond 2600 if full-fiber fold needs a materially new combinator | Medium | Medium — schedule/dispatch-count impact, not correctness impact | Pre-declare Phase 2/3 as splitting by proof direction (H8); treat overrun as planned, not churn |
| `ExistProviders` bespoke-vs-canonical shape mismatch with task 309's `Nat.rec`-supplied instance | Low (D notes 352 must consume the canonical record, not invent one) | High — breaks the 309 consumption chain if violated | Explicit interface review against `PriorInterface.lean:38-46` at Phase 4 (interface exposition) |
| `h_UZ`/`h_SZ` (Prior UZ/SZ conditionality) fails to propagate to every char-correctness site, forcing new hypotheses into `_sound`/`_complete` | Low-Medium (B's open question 3; unresolved) | Medium — changes the bracket's consumer-facing signature shape beyond the `P` parameter | Verify during Phase 2 construction; confirm against `nf_succ_char_formula_correct`'s hypothesis shape |
| `nf0_zoneSpec` atom-layer read is used somewhere on the quant layer rather than strictly the atom layer (B's open question 4) | Low | Medium — would reintroduce a depth-0 hardwiring | Explicit check during Phase 1 skeleton construction, mirroring the D7 discipline already followed by `ExteriorBracketK` |
| Naming drift: 349's description promises `endChar_correct`, plan v7 uses `endInterval_correct` (D's finding) | Low | Low — coordination friction with task 309, not a 352 correctness risk | Surface to 309's plan/description at Phase 4 handoff; not 352's deliverable to fix |

## Proposed Decomposition for /plan

Adopting D's diamond decomposition with the Conflict-1/3 corrections folded in (Phase 0 gate added;
Phase 1/2/3 line estimates widened per Conflict 2's ruling):

| Phase | Deliverable | Est. lines | Depends on | Territory |
|---|---|---|---|---|
| **0. Pre-build verification gate** | F2-pair re-test against the full-fiber `existF`-disjunction construction (Conflict 3, part 1) + Lemma 7.8 adversarial re-read (part 2). Go/no-go before further dispatch. | ~150-300 | — | Single agent; reads `RefutationF2.lean` + Rabinovich §7 |
| **1. Shared depth-k clause skeleton + P plumbing** | Full-fiber coordinatization (replaces `nf0_assemble`'s role) built directly on `P.existF`, made lossless at depth k by construction (not by marginal substitution). Establishes the clause-fact interface both sides consume. Consumes `ExteriorBracketK` core (`nfk_truncD`, `kvE_subBit_iff`, `kvE_futAnyBit`) **only for navigation**, per G6. | ~350-550 | 0 | Single agent |
| **2. Future side clause layer** (`ExteriorNegationK.lean`) | `kvE_futPos_k`/`kvE_extNegFut_k` + `_sound` + `_complete` over `P`, built on Phase 1's full-fiber channel. Likely splits 2a (`_sound`) / 2b (`_complete`). | ~550-800 | 1 | Disjoint file: `ExteriorNegationK.lean` |
| **3. Past side clause layer** (`ExteriorNegationPastK.lean`) | Structural Past mirror of Phase 2. Parallelizable with Phase 2 under H7 (disjoint files). Likely splits 3a/3b. | ~550-800 | 1 | Disjoint file: `ExteriorNegationPastK.lean` |
| **4. Interface exposition** | Package per-side clause facts into the exact shape 349 Phase 2 consumes (`habove`/`hbelow` at the corrected full-fiber pin shape, not the marginal `kvE_futAnyBit` shape alone). Cross-check against `ExistProviders`' canonical shape for the 309 consumption chain. | ~200-350 | 2, 3 | Single agent |
| **5. Axiom audit + whole-tree build** | `lean_verify` axiom-clean (`[propext, Classical.choice, Quot.sound]`) on every headline decl; frozen-file diffs EMPTY; G1-G6 grep-clean; k=0 recovery/agreement lemmas against the frozen k=2 originals; confirm citability by 349 Phase 2. | ~50-100 | 4 | Single agent |

**Total: ~1850-2900 lines** (Phase 0 + widened Phase 1-3 estimates; center-of-mass ~2200-2400, consistent
with the Conflict-2 ruling). Dispatch count: ~9-11 agent runs (Phase 0 alone, Phase 1 alone, Phases
2a/2b + 3a/3b in parallel wave, Phase 4, Phase 5).

```
Wave 0:  Phase 0  (pre-build verification gate — GO/NO-GO)
             │
Wave 1:  Phase 1  (skeleton + full-fiber P plumbing)
             │
        ┌────┴────┐
Wave 2: Phase 2   Phase 3      ← PARALLEL (H7 territory: disjoint side-modules)
        (Future)  (Past)
        └────┬────┘
Wave 3:  Phase 4  (interface exposition)
             │
Wave 4:  Phase 5  (audit)
```

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|:----------:|
| A | Primary — ExistProviders channel adequacy and interface shape | completed | High (channel/interface); explicitly not on line-count |
| B | Alternatives — frozen-layer generalization template, per-step V/L/P table, candidate architectures | completed | High (strata/verdicts); Medium (line-count, existF arity — the point Conflict 1 revises) |
| C | Critic — F2 obstruction reproduction, marginal-vs-joint discipline, existF-sufficiency adversarial check | completed | High (F2 diagnosis, marginal-bits risk); Medium-High (existF-sufficiency, the Conflict-3 gate) |
| D | Horizons — module architecture, decomposition, roadmap alignment | completed | High (standalone/DAG/plan-v7 impact); Medium-High (line estimates, pre-Conflict-1-correction) |
| E | Literature faithfulness (Rabinovich 2014, fable) — Def 7.5/7.7, Cor 5.4, Lemma 7.8 negation-closure adjudication | completed | High (Lemma 7.8 verdict from PDF proofs + paper resource inventory) |

## Addendum — Teammate E (Rabinovich literature, fable): Lemma 7.8 resolved, Conflict-3 gate downgraded

Teammate E was dispatched after the initial a–d synthesis, specifically to close the
Conflict-3 / pre-build-gate uncertainty by reading the paper's proofs directly. Findings file:
`reports/01_teammate-e-findings.md`. Net effect on this report: **the largest pre-build unknown
is now resolved in favor of proceeding.**

- **Lemma 7.8 verdict — resolution (a) holds; it does NOT collapse into (b).** Reading the actual
  proofs (PDF pp. 8–11, including display equations dropped in the markdown conversion), negation
  closure consumes across the rung boundary only previous-round **TL formulas** — the Cor 5.4
  Until-folds `F_n := α_n`, `F_{i−1} := α_{i−1} ∧ (β_i Until F_i)` (the literal `existF` shape)
  plus `K⁺` atoms of the Def 7.7 canonical expansion — and **never invokes the rung-(k+1) bracket
  recursively on the depth axis.** The paper's own resource inventory confirms it ("Cor 5.4(1)
  used Lemma 5.3 and Until modality … Lemma 5.1 uses standard equivalences and Cor 5.4(2)"). This
  means the standalone `P : ExistProviders`-parameterized module (Teammate D / Conflict-1 ruling)
  is faithful to the paper, not a shortcut.
- **Sharpening C missed:** Lemma 5.1 Case 3 *does* contain a genuine internal recursion — an
  induction on bracket **length** via the `A_i`/`B_i` prefix/suffix brackets — but it is
  **intra-rung**, and its Lean analog is the already-landed list recursion
  (`kvE2_futChain`/`kvE2_futMinPick`), not a mutual depth recursion. So no new depth recursion is
  opened, consistent with the acyclic-DAG finding.
- **G6 is paper-justified:** the paper pins clause content with full entry tuples and uses
  marginal-looking devices (`INF`, `K⁺`, `r_0`) strictly for navigation — exactly C's
  marginal-vs-content distinction. The k=2 layer's `Formula.neg` shortcut is faithful-in-effect:
  the paper needs positive-form reconstruction only because of ∨∃∀-FOMLO's negation-hostility,
  which TL formulas do not share (Def 7.7 idempotence).
- **Revised Conflict-3 / gate posture:** the gate's *adversarial Lemma-7.8 re-read is now DONE*
  (this addendum). The remaining Phase-0 item is only the small Lean F2-probe — re-test the
  existing F2 pair against the corrected full-fiber (`P.existF`-over-fiber) construction to confirm
  it separates where the marginal construction did not. E's 10-row paper→Lean construct map in
  `01_teammate-e-findings.md` is the faithful transcription reference for the Phase-1/2 build.

## Open Questions / References

- **Q1 (from C, unresolved by this synthesis — this is exactly what the pre-build gate answers)**: does
  Rabinovich Lemma 7.8's proof consume only rung-k formulas at every step, or does any case implicitly
  need the rung-k bracket's own soundness/completeness? Gate this before Phase 2/3 (Conflict 3).
- **Q2 (from B, resolved by this synthesis)**: at which `existF` arity does the clause layer consume the
  provider? **Resolved**: not a fixed small arity applied to a marginal profile — the full fiber-element
  arity (`NormalForm sig k 5`), per the Conflict-1 ruling.
- **Q3 (from B, unresolved)**: do `h_UZ`/`h_SZ` propagate to every char-correctness site, or only the
  top? Affects whether the rebuilt lemmas gain `semantic_prior_UZ/SZ` hypotheses vs. stay model-generic
  like the frozen k=2 originals. Verify during Phase 2 construction.
- **Q4 (from B, likely resolved but not step-verified)**: is `nf0_zoneSpec σ.1`'s atom-layer read truly
  confined to the atom layer at every clause-layer step, never the quant layer? Check during Phase 1.
- **Q5 (from D, coordination item, not a 352 blocker)**: naming drift between 349's promised
  `endChar_correct` and plan v7's `endInterval_correct` — surface to task 309 at Phase 4 handoff.
- **Q6 (from C's Q6)**: 352 must also show the depth-k bracket FORMULA (not just individual bits)
  degrades to the frozen `kvE2_extBracketFut` shape at k=0, or the k=2 consumer in 349 won't accept it.
  Fold into Phase 5's k=0 recovery obligation.
- **References**: `PriorInterface.lean:38-46` (`ExistProviders`); `ExteriorBracketK.lean` (determinacy
  core, task 349 Phase 1); `NfEFold.lean:549-561,627` (depth-0-only losslessness; Phase-1 fold bridge);
  `RefutationF2.lean` (F2 counterexample, whole file per C); `KampPrior.lean:67,81,895-960`
  (`nf_succ_char_formula`, shim instantiation); `OuterGate.lean:70-146` (interior gate's existing
  `P.existF 0` usage); `ExteriorBracket.lean:432-684` (k=2 bracket assembly pattern); `ExteriorNegation.lean`
  / `ExteriorNegationPast.lean` (frozen clause layer, 2844 lines combined); `specs/349_.../reports/
  11_spawn-analysis.md`; `specs/349_.../handoffs/v7-phase2-blocked-1783882788.json`.
