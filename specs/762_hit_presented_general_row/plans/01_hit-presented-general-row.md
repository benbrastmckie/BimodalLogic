# Implementation Plan: Task #762

- **Task**: 762 - (C)'s general row: exists_hitPresented with sizeBound φ k a count, for every regular ℤ-model (run-layer phase 3)
- **Status**: [IMPLEMENTING]
- **Effort**: 25.5 hours
- **Dependencies**: 759 (logical edge, discharged: `Probe759.hitPresented_node` is a Hit-level POSITIVE, so the Stage 0 "statement is false" branch does not fire); no open dependency (the serialization-only edge on 761 was dropped at research time)
- **Research Inputs**: specs/762_hit_presented_general_row/reports/01_hit-presented-general-row.md
- **Artifacts**: plans/01_hit-presented-general-row.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Land the general row of requirement (C) as a sorry-free library theorem: for every regular
`ℤ`-model `M`, seam `(τ, t)`, formula `φ` and depth `1 ≤ k`, a finite labelled presentation with
`Fintype.card Q ≤ sizeBound φ k` satisfying `HitPresented M τ t φ lab step k`, with
`sizeBound φ k := Nat.card (KType (clSig φ) k) ^ 3 * (4 * Nat.card (Profile (clSig φ) k) ^ 2 + 1)`
EXHIBITED in the statement as a count of depth-`k` types and of profiles — never an `∃ L`, never
a running time. The route is the research report's Ramsey-over-profile argument, in four layers
over three sibling modules under `RaySummary/` (all three already in the task's `file_scope`):
`Profile.lean` (a finite σ-star profile of finite words that composes under concatenation, and
bounded representatives by profile pumping), `Periodic.lean` (one-sided periodic transport in
both orientations and the seam assembly `exists_periodic_subfamily`: every family triple of a
colouring with `now` exactly at `t` is realized by a bi-ultimately-periodic colouring whose own
family triples all belong to the original), and `HitComplete.lean` (a three-piece gadget whose
`hitOf` is exactly the family-triple set of its periodic trace, the disjoint union of one gadget
per realized triple, and the headline `exists_hitPresented`). Done means: the filed statement
compiles verbatim at `[propext, Classical.choice, Quot.sound]` with zero `sorry`, pinned at the
two C14 sites and in `docs/theorem-index.md`, with the RaySummary README's (C) row, obligation
(ii) item 2 and Evidence prose amended, and the full gate green.

### Research Integration

Report `01_hit-presented-general-row.md` is integrated in full:
- **T2 positive, no Stage 0 ruling** (Finding 1): the record proceeds as a positive theorem.
- **Reduction (★)** (Finding 2): `HitPresented` is satisfiable iff every triple of every seam
  trace is realized by a bi-ultimately-periodic colouring whose triples lie in the trace's. The
  plan's Layer 3 (`exists_periodic_subfamily`) IS (★); Layer 4 is the model-free gadget reading.
- **Cut-pair obstruction** (Finding 3): the fixtures' literal-segment lasso is NOT the route;
  no phase repeats one literal segment, and the transport `↔` of `Transport.lean` stays unused.
- **The argument** (Finding 4): σ-star profile `g_σ`, composition law, cut profile, Ramsey on
  `(profile, cutProfile)` of stretches, offset pigeonhole, block-by-block compositionality. The
  composition law — the one risky lemma, brute-force checked at depth 1 (1347 pairs, 0
  mismatches; CARRIED-UNVERIFIED from the report's scratchpad run) — is Phase 2 and gates the
  rest.
- **The bound** (Finding 5): profile pumping gives pieces of length `< P ^ 2`; the plan keeps
  the report's loose `4 * P ^ 2 + 1` per gadget and `N ^ 3` gadgets.
- **Ingredients by name** (Finding 6): `Nat.exists_strictMono_const_pair_colour`
  (`ForMathlib/Combinatorics/InfiniteRamseyPairs.lean`, `{C : Type} [Finite C]`),
  `kTypeOf_listSeg_append_congr`, `kTypeOf_segZ_eq_listSeg`, `listSeg`, `labels`
  (`Compose.lean`), `nonempty_iff_of_kTypeOf_eq`, `exists_interp_iff_of_kTypeOf_eq`,
  `mem_hitOf_iff`, `cutAt`/`exists_concat`/`isRun_concat`/`kTypeOf_segZ_concat` (`HitOf.lean`),
  `IsRun`/`runTrace`/`pathLabels` (`Present.lean`), `SegmentFactorization`/`InFamily`
  (`KTypeSummary/Family.lean`), `familyTriples`/`HitCl`/`hitCl_finite`/`hitCl_eq_iUnion`/
  `HitPresented` (`Trace.lean`), `clSig`/`clNow`/`clTrace` (`Closure.lean`) — all re-read at
  plan time at the signatures quoted in the phases below.
- **Recommendations 1-5**: four layers → fourteen phases; filed statement kept exactly with
  `1 ≤ k` free; sibling modules (no `proposed_file_scope` needed — `file_scope` already lists
  them); composition law first; README records the positive settlement and retires the
  "needs an infinite seam fibre" heuristic.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` was provided to this dispatch; ROADMAP.md was not consulted and is not
modified.

## Goals & Non-Goals

**Goals** (the identifier set equals the `## Lean Challenge Statements` block):
- `Profile` — `KType sig k × (KType sig k → KType sig k → KType sig k → Bool)`, the finite
  datum; its `Nat.card` is the `P` of the bound.
- `profile` — the profile of a finite word: its `k`-type and, for every `σ`, the σ-star relation
  `g_σ` as a Bool table.
- `cutProfile` — the set of `(profile prefix, profile suffix)` pairs over all cuts of a word.
- `profile_append_congr` — the composition congruence (the decisive lemma).
- `exists_rep_of_length_lt` — bounded representatives: same profile, cut profile shrunk, length
  `< Nat.card (Profile sig k) ^ 2`.
- `periodicColouring` — the bi-ultimately-periodic colouring `w^(ω*) · m · v^ω` with `m`
  starting at time `b`.
- `fwdPeriodic`, `bwdPeriodic` — the one-sided forms used by the transport theorems.
- `FwdTypes`, `BwdTypes` — the forward/backward tail type sets of a colouring read from `t`.
- `exists_periodic_fwd`, `exists_periodic_bwd` — one-sided periodic transport (★₊), (★₋), with
  the piece-length bounds.
- `exists_periodic_subfamily` — the seam assembly (★).
- `GadgetState`, `gadgetLab`, `gadgetStep` — the three-piece presentation of a periodic word.
- `hitOf_gadget_eq` — a gadget's `hitOf` is the family-triple set of its periodic trace.
- `hitOf_sigma_eq` — `hitOf` of a disjoint union of presentations is the union of their
  `hitOf`s.
- `sizeBound` — the exhibited count.
- `exists_hitPresented` — the headline, verbatim as filed.

**Non-Goals**:
- No `Decidable (PlusValidZTime φ)` in any form; nothing about the lift (that is the successor
  record); nothing about (W)'s soundness half; no edit to `RunLayer.lean`/`LadderModel.lean`.
- No complexity bound, upper or lower: `sizeBound` counts types and profiles, times nothing,
  bounds no procedure; the held 2EXPTIME ceiling rules proposals out only (guardrail (c)).
- No width, fibre or finiteness hypothesis on `M` beyond `[F.IsRegular]`, which enters only as
  `HitCl`'s own hypothesis (guardrail (b)); `Fintype` is on the PRESENTATION only.
- No automata library, no Mathlib `Language`/`DFA`/`NFA`, no Büchi/MSO theorem cited in place of
  a proof, no cslib (guardrail (d)); the ultimately-periodic-witness fact is re-proved by Ramsey
  over the profile for the finitely many conditions this record needs.
- No `kTypeOf` order-reversal lemma: the backward half duplicates the forward half, as
  `exists_zFactorization` applies Ramsey once per orientation (Decisions). The reversal lemma is
  the documented alternative, not a goal.
- No computable presentation: the gadget family is chosen classically per triple; the `∃`
  statement permits it (the fixtures' `def` presentations were needed only for `#guard`s).
- No edit to any wired probe under `specs/evidence/` (their headers are historical records);
  no edit to `Transport.lean`; the transport `↔` (threshold `3·(m₀+p)`) stays a non-goal.
- Nothing about `⊡(Pp)`: the combinatorics is direction-neutral, but no backward Bool-fixture
  bridge is built, and the README must say the landed form bears nothing on it (guardrail (e)).
- No task numbers or `specs/NNN_` citations in any file outside `specs/**`.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Composition law of `starProfile` has a gap in the straddling case (one empty half, `u·v = σ` vs `u = v = 1`) | H | L | Phase 2 lands it first, stated in congruence form with the explicit law as the internal statement; brute-force evidence at depth 1 (CARRIED-UNVERIFIED); fallback within zero debt is to STRENGTHEN the profile (carry the straddling halves' types explicitly), never to weaken the statement |
| Forward transport (Phase 6) does not close: the chosen cuts fail to factor `R` as `L_α L_σ^ω` | H | M | Only equality of `profile` and `cutProfile` block by block plus `profile_append_congr` is used — no idempotent; if the block-by-block comparison needs the offset-`o` cut's `(profile z, profile y)` pair in EVERY block (it does), Phase 5 must colour stretches by `cutProfile`, not only `profile`. If Phase 6 still fails, the honest outcome is `[BLOCKED]` with the goal state recorded in the summary — never `sorry`, axiom, or a smuggled hypothesis |
| Size: 2500-3500 lines by the fixture precedents (Probe745 1595, Probe759 1434 lines, re-measured at plan time by `wc -l`); more than one implementation dispatch | M | H | Fourteen phases of ≤ 2 h each with their own build check; Phases 1-3 land before any transport; the longFile linter (`weak.linter.style.longFile = 1500`, `lakefile.toml`) is respected by the three-module split, and a module that still crosses 1500 lines carries the sanctioned in-source `set_option linter.style.longFile N` baseline after its docstring |
| Backward duplication (Phase 7) doubles Layer 3 | M | H | Accepted, as `Family.lean` does; the implementer may instead prove a `kTypeOf` reversal transfer (`kTypeOf (listSeg l.reverse)` determined by `kTypeOf (listSeg l)`) and derive Phase 7 from Phase 6 — record the choice in the summary either way |
| `hitOf_gadget_eq` needs the gadget's anchored run to be UNIQUE (predecessor-deterministic before `t`, successor-deterministic after `t`) and `IsRun` forbids any other `now` | M | L | Phase 10 proves `isRun_gadget_iff` first; the `now`-placement hypothesis is the single clause `∀ z, periodicColouring w m v b now z ↔ z = t`, which forces `w`, `v` `now`-free and `m` to carry exactly one `now` |
| The bound's shape `P = N · 2^(N^3)` is enormous | L | H | It is a count; state it, quote the `AnchorLayer.lean` disclaimer, claim no minimality, make no complexity reading anywhere |
| README edits drift into record-versioning or task-number language | M | M | Phase 14 writes present-tense design statements with durable anchors (`exists_hitPresented`, `HitComplete.lean`); the C9 and task-reference gates run before the phase closes |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 4 | 1 |
| 3 | 3, 5, 8, 10 | 2, 4 |
| 4 | 6, 11, 12 | 3, 5, 10 |
| 5 | 7 | 6 |
| 6 | 9 | 6, 7, 8 |
| 7 | 13 | 9, 11, 12 |
| 8 | 14 | 13 |

Phases within the same wave can execute in parallel.

### Phase 1: `Profile.lean` — Star Languages, the σ-Star Profile, and Finiteness [COMPLETED]

**Goal**: Create `FormalSystem/Metalogic/Decidability/RaySummary/Profile.lean` (namespace
`FormalSystem.Metalogic.WeakCanonical`, beside `Compose.lean`/`HitOf.lean`/`Transport.lean`)
with the definitions of Layer 1, their finiteness, and the two membership read-outs; wire it into
the aggregator and the library root.

**Tasks**:
- [x] Module docstring: what a profile is, why FO `k`-types do not compose under star (the
      cut-pair obstruction, stated with no task number), and the count disclaimer in
      `AnchorLayer.lean`'s words with "profiles" for "cells".
- [x] `variable {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {k : ℕ}`;
      abbreviation `Letter sig := sig.preds → Bool` only if it shortens signatures (optional).
- [x] `def StarPlus (σ : KType sig k) (l : List (sig.preds → Bool)) : Prop` — `l` is a nonempty
      concatenation of nonempty pieces each of `k`-type `σ` (as `∃ ps, ps ≠ [] ∧ (∀ p ∈ ps, p ≠ []
      ∧ kTypeOf sig k (listSeg p) = σ) ∧ ps.flatten = l`); `def StarZero σ l` (pieces possibly
      none, `l = []` allowed); `def PrefixStar (α σ) l := ∃ p q, l = p ++ q ∧ kTypeOf sig k
      (listSeg p) = α ∧ StarZero σ q`.
- [x] `def starProfile (σ : KType sig k) (l) : KType sig k → KType sig k → Prop :=
      fun x y => ∃ p m q, l = p ++ m ++ q ∧ StarZero σ m ∧ kTypeOf sig k (listSeg p) = x ∧
      kTypeOf sig k (listSeg q) = y`.
- [x] `abbrev Profile (sig) (k) : Type := KType sig k × (KType sig k → KType sig k → KType sig k
      → Bool)`; `noncomputable def profile (l) : Profile sig k := (kTypeOf sig k (listSeg l),
      fun σ x y => decide (starProfile σ l x y))` under `open Classical`; `noncomputable def
      cutProfile (l) : Set (Profile sig k × Profile sig k) := {pr | ∃ z y, l = z ++ y ∧ pr =
      (profile z, profile y)}`.
- [x] `instance : Fintype (Profile sig k)` and `DecidableEq (Profile sig k)` (from
      `normalFormFintype` through `KType`'s `Fintype`/`DecidableEq`, via `inferInstanceAs` as
      `Closure.lean` does for `clSig`); `theorem card_profile : Nat.card (Profile sig k) =
      Nat.card (KType sig k) * 2 ^ (Nat.card (KType sig k) ^ 3)` (optional, documentary only). *(deviation: altered — instance search does not reach three nested function levels, so the two inner `Fintype`/`DecidableEq` instances are supplied by `haveI` before `inferInstanceAs`; `card_profile` landed over `[Finite sig.preds]`)*
- [x] `def typeNil : KType sig k := kTypeOf sig k (listSeg [])` with `theorem kTypeOf_listSeg_eq_typeNil_iff
      (hk : 1 ≤ k) : kTypeOf sig k (listSeg l) = typeNil ↔ l = []` from `nonempty_iff_of_kTypeOf_eq`.
- [x] Read-outs: `theorem starPlus_iff_profile (hk : 1 ≤ k) : StarPlus σ l ↔ l ≠ [] ∧
      (profile l).2 σ typeNil typeNil = true`; `theorem prefixStar_iff_profile : PrefixStar α σ l
      ↔ (profile l).2 σ α typeNil = true`; `theorem kTypeOf_eq_of_profile_eq : profile l = profile
      l' → kTypeOf sig k (listSeg l) = kTypeOf sig k (listSeg l')`.
- [x] Wiring: `import FormalSystem.Metalogic.Decidability.RaySummary.Profile` in
      `FormalSystem/Metalogic/Decidability/RaySummary.lean` (after the `Transport` import) and
      in `FormalSystem.lean` (alphabetical position among the `RaySummary.*` imports); one
      sentence in the aggregator docstring naming the profile.
- [x] Commit per green sub-step (`task 762 phase 1.N: …`).

**Timing**: 2 hours

**Depends on**: none

**Verification Tier**: interface

**Commit Mode**: per-substep

**Scope Hypothesis**: ~250-350 lines for this phase (definitions, instances, read-outs); whole
module 900-1200 lines after Phases 2-3. Confirm by `wc -l` at phase close; if the projection
exceeds 1500, decide at Phase 3 whether Layer 2 moves to `Periodic.lean`.

**Tier Justification**: `lake build FormalSystem.Metalogic.Decidability.RaySummary.Profile`
followed by `lake build FormalSystem.Metalogic.Decidability.RaySummary` covers the new module and
its one direct dependent, the aggregator; the `FormalSystem.lean` root import can only fail if
the module fails, which the first command already checks.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/Profile.lean` - new module: star languages, `starProfile`, `Profile`, `profile`, `cutProfile`, finiteness, read-outs
- `FormalSystem/Metalogic/Decidability/RaySummary.lean` - one import line and one docstring sentence
- `FormalSystem.lean` - one import line

**Verification**:
- `lake build FormalSystem.Metalogic.Decidability.RaySummary.Profile` exits 0 with no `sorry`
  warning; `lake build FormalSystem.Metalogic.Decidability.RaySummary` exits 0.
- `#print axioms` for `starPlus_iff_profile` and `prefixStar_iff_profile` read
  `[propext, Classical.choice, Quot.sound]` or a subset.
- `bash .claude/scripts/lean-sorry-census.sh` count 0 for the new file.

---

### Phase 2: The Composition Law `profile_append_congr` [COMPLETED]

**Goal**: Prove that the profile of `l₁ ++ l₂` is a function of `profile l₁` and `profile l₂`,
through the explicit law of the research report (Finding 4), and derive the congruence.

**Tasks**:
- [x] `theorem starProfile_append (hk : 1 ≤ k) (σ) (l₁ l₂) (x y) : starProfile σ (l₁ ++ l₂) x y
      ↔ (∃ y', starProfile σ l₁ x y' ∧ y = kTypeOf (listSeg (rep y' ++ l₂)))` — state instead
      WITHOUT representatives, as the four-case disjunction over where the middle `m` sits:
      (i) inside `l₁` (`y` is `y' · type l₂` by `kTypeOf_listSeg_append_congr`), (ii) inside
      `l₂`, (iii) straddling at a piece boundary (`u = v = typeNil`), (iv) straddling inside one
      piece `l = l' ++ l''` with `type l' · type l'' = σ`; the "type product" is expressed as
      `kTypeOf (listSeg (a ++ b))` for any representatives, well defined by
      `kTypeOf_listSeg_append_congr`.
- [x] The middle-split lemma: `StarZero σ m → m = m₁ ++ m₂ → ∃ cases` (the four-way split of a
      concatenation of pieces at a cut), and its converse assembling `StarZero` from the cases.
- [x] `theorem profile_append_congr (hk : 1 ≤ k) {l₁ l₁' l₂ l₂'} (h₁ : profile l₁ = profile l₁')
      (h₂ : profile l₂ = profile l₂') : profile (l₁ ++ l₂) = profile (l₁' ++ l₂')` by
      `Prod.ext` (first component: `kTypeOf_listSeg_append_congr`; second: `funext` and
      `starProfile_append` on both sides, with each case's data transported through `h₁`/`h₂`).
- [x] `theorem profile_flatten_congr`: the list-of-pieces form (pieces pairwise profile-equal
      ⇒ flattenings profile-equal), by induction from `profile_append_congr` — the shape Phase 6
      uses block by block.
- [x] If the four-case law does not close as stated: strengthen `starProfile` to carry the
      straddling halves' types (a fifth component), re-run Phase 1's read-outs, record the
      change in the summary; do NOT weaken any statement downstream. *(not needed: the four-case law closed as stated, with the type product on representatives `TypeMul`/`typeMul_iff`; landed over `[Finite sig.preds]`)*

**Timing**: 2 hours

**Depends on**: 1

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: ~300-450 lines (the four-case split is the bulk). The report's brute-force
check (1347 pairs at depth 1, 0 mismatches) is CARRIED-UNVERIFIED from its scratchpad; the
Lean proof is the confirmation.

**Tier Justification**: `lake build FormalSystem.Metalogic.Decidability.RaySummary.Profile` is
the complete covering check — this phase adds theorems to one module and changes no signature any
other module consumes yet.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/Profile.lean` - `starProfile_append`, `profile_append_congr`, `profile_flatten_congr`

**Verification**:
- `lake build FormalSystem.Metalogic.Decidability.RaySummary.Profile` exits 0; `#print axioms
  profile_append_congr` at `[propext, Classical.choice, Quot.sound]` or a subset; no `sorry`.

---

### Phase 3: Bounded Representatives `exists_rep_of_length_lt` [COMPLETED]

**Goal**: Every word has a representative of the same profile, no larger cut profile, and length
below `Nat.card (Profile sig k) ^ 2`, by pigeonhole on cut pairs and deletion.

**Tasks**:
- [x] `theorem cutProfile_delete`: for `l = a ++ b ++ c` with `profile a = profile (a ++ b)`
      (equivalently `(profile a, profile (b ++ c)) = (profile (a ++ b), profile c)` — the two
      cut pairs coincide), `profile (a ++ c) = profile l` (by `profile_append_congr`) and
      `cutProfile (a ++ c) ⊆ cutProfile l` (every cut of `a ++ c` is a cut of `l` with the same
      pair, using the congruence on whichever side the cut falls).
- [x] `theorem exists_eq_cutPair_of_length_ge`: a word of length `≥ Nat.card (Profile sig k) ^ 2`
      has cut positions `i < j` with equal `(profile (take i), profile (drop i))` pairs
      (`Fintype.exists_ne_map_eq_of_card_lt` on `Fin (l.length + 1) → Profile × Profile`, as
      `kTypeOf_listSeg_replicate_eventually_periodic_bounded` uses it).
- [x] `theorem exists_rep_of_length_lt (hk : 1 ≤ k) (l) : ∃ l', l'.length < Nat.card (Profile sig
      k) ^ 2 ∧ profile l' = profile l ∧ cutProfile l' ⊆ cutProfile l` by strong induction on
      `l.length`.
- [x] Corollary `exists_rep_of_length_lt'`: the same with `l' ≠ []` whenever `l ≠ []` (type
      nonemptiness is profile-visible at `k ≥ 1`). *(deviation: altered — named `exists_rep_of_length_lt_ne_nil`, no prime)*

**Timing**: 1.5 hours

**Depends on**: 2

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: ~150-250 lines. Confirm `wc -l` of `Profile.lean` after this phase is
below 1500; otherwise add the sanctioned longFile baseline or move this layer to
`Periodic.lean` (both files are in `file_scope`).

**Tier Justification**: `lake build FormalSystem.Metalogic.Decidability.RaySummary.Profile` is
the complete covering check; no other module consumes these names yet.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/Profile.lean` - `cutProfile_delete`, `exists_eq_cutPair_of_length_ge`, `exists_rep_of_length_lt`

**Verification**:
- `lake build FormalSystem.Metalogic.Decidability.RaySummary.Profile` exits 0; no `sorry`;
  `#print axioms exists_rep_of_length_lt` at the standard profile or a subset.

---

### Phase 4: `Periodic.lean` — Periodic Colourings and the Tail Type Sets [COMPLETED]

**Goal**: Create `FormalSystem/Metalogic/Decidability/RaySummary/Periodic.lean` (namespace
`FormalSystem.Metalogic.WeakCanonical`, importing `Profile`) with the bi-ultimately-periodic
colouring, its one-sided forms, the forward/backward tail type sets, and the lemmas that read
segment types of a periodic colouring off its piece words.

**Tasks**:
- [x] `def periodicColouring (w m v : List (sig.preds → Bool)) (b : ℤ) : sig.preds → ℤ → Prop`
      — position `z < b` reads `w.getD (((z - b) % w.length).toNat) default`, `b ≤ z < b +
      m.length` reads `m[z - b]`, `z ≥ b + m.length` reads `v.getD (((z - b - m.length) %
      v.length).toNat) default`; `instance : ∀ p, DecidablePred (periodicColouring w m v b p)`.
- [x] `abbrev fwdPeriodic (u v) (t : ℤ) := periodicColouring v u v (t + 1)` (reads `u` from
      `t + 1`, then `v^ω`; the part before `t + 1` is irrelevant to `FwdTypes`) and
      `abbrev bwdPeriodic (w u) (t : ℤ) := periodicColouring w u w (t - u.length)` (reads `u`
      ending at `t - 1`, `w^(ω*)` before it).
- [x] `def FwdTypes (c) (t : ℤ) : Set (KType sig k × KType sig k) := {x | ∃ W : ℕ → ℤ,
      StrictMono W ∧ t + 1 ≤ W 0 ∧ kTypeOf sig k (segZ sig c (t + 1) (W 0)) = x.1 ∧ ∀ i,
      kTypeOf sig k (segZ sig c (W i) (W (i + 1))) = x.2}`; `def BwdTypes (c) (t) := {x | ∃ W :
      ℕ → ℤ, StrictAnti W ∧ W 0 ≤ t ∧ kTypeOf sig k (segZ sig c (W 0) t) = x.2 ∧ ∀ i, kTypeOf
      sig k (segZ sig c (W (i + 1)) (W i)) = x.1}`.
- [x] Tail congruences: `fwdTypes_congr : (∀ p z, t < z → (c p z ↔ c' p z)) → FwdTypes c t =
      FwdTypes c' t`; `bwdTypes_congr` for `z < t`; `fwdTypes_shift`/`bwdTypes_shift` only if
      Phase 6 needs them.
- [x] Reading segments: `labels_periodicColouring_of_ge`: for `b + m.length ≤ a ≤ a'`, `labels
      (periodicColouring w m v b) a a'` is the corresponding slice of `v^ω` (stated via
      `List.take`/`List.drop` of `List.replicate n v |>.flatten`), and the `w` mirror;
      `labels_append_of_le : a ≤ c ≤ b → labels c a b = labels c a c ++ labels c c b`
      (check `Compose.lean` for an existing form first; add only if absent). *(deviation: altered — `labels_append` already exists in `Transport.lean` and is imported; the read-outs landed as `labels_periodicColouring_mid`/`_slice`/`_period`/`_replicate`/`_bwd`)*
- [x] `theorem kTypeOf_segZ_periodic_block`: a whole period `[b + m.length + i·|v|, b +
      m.length + (i+1)·|v|)` has `kTypeOf (listSeg v)`; `profile` of a stretch of `n` full
      periods equals `profile (flatten (replicate n v))` (by `profile_flatten_congr`). *(deviation: altered — landed as the label-list equality `labels_periodicColouring_replicate`, from which the profile equality is `rfl`; the shift lemmas were not needed)*
- [x] Wiring: aggregator and `FormalSystem.lean` imports as in Phase 1.

**Timing**: 2 hours

**Depends on**: 1

**Verification Tier**: interface

**Commit Mode**: per-substep

**Scope Hypothesis**: ~300-400 lines for this phase; whole module 1100-1400 lines after Phases
5-9 — confirm by `wc -l` at each phase close and apply the longFile baseline rule if crossed.

**Tier Justification**: `lake build FormalSystem.Metalogic.Decidability.RaySummary.Periodic`
then `lake build FormalSystem.Metalogic.Decidability.RaySummary` covers the new module and the
aggregator, its only direct dependent.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/Periodic.lean` - new module: `periodicColouring`, `fwdPeriodic`, `bwdPeriodic`, `FwdTypes`, `BwdTypes`, tail congruences, segment read-outs
- `FormalSystem/Metalogic/Decidability/RaySummary.lean` - one import line and one docstring sentence
- `FormalSystem.lean` - one import line

**Verification**:
- Both `lake build` commands exit 0; no `sorry`; `periodicColouring` is a plain `def` (its
  `DecidablePred` instance computes).

---

### Phase 5: Forward Ramsey Blocks [COMPLETED]

**Goal**: From `(α, σ) ∈ FwdTypes c t`, extract the prefix `u` and consecutive blocks
`B 0, B 1, …` of the forward tail, each a `StarPlus σ` word, all with the SAME `profile` and the
SAME `cutProfile`.

**Tasks**:
- [x] `theorem exists_blocks_fwd (hk : 1 ≤ k) (hx : (α, σ) ∈ FwdTypes c t) : ∃ (u : List _)
      (B : ℕ → List _) (E : Profile sig k) (CP : Set (Profile × Profile)), kTypeOf (listSeg u) =
      α ∧ (∀ a, StarPlus σ (B a)) ∧ (∀ a, profile (B a) = E) ∧ (∀ a, cutProfile (B a) = CP) ∧
      labels c (t + 1) (t + 1 + u.length) = u ∧ ∀ a, labels c (start a) (start (a + 1)) = B a`
      with `start a := t + 1 + u.length + (B 0 ++ … ++ B (a-1)).length` — or, equivalently and
      simpler to consume, `∀ n, labels c (t + 1) (start n) = u ++ (List.ofFn … ).flatten`.
- [x] Proof: with `W` from the membership, colour pairs `i < j` by `(profile, cutProfile)` of
      `labels c (W i) (W j)` — `cutProfile` is a `Set` over a finite type, so colour by its
      `Finset` twin or by `fun pr => decide (pr ∈ cutProfile …)` as a `Profile × Profile → Bool`
      (a `Type` with `[Finite]`, as `Nat.exists_strictMono_const_pair_colour` requires);
      obtain `g` strictly monotone with constant colour; blocks are `labels c (W (g a)) (W (g
      (a+1)))`, each a concatenation of `g (a+1) - g a` segments of type `σ` (so `StarPlus σ`,
      nonempty by `nonempty_iff_of_kTypeOf_eq` at `k ≥ 1`), with `u := labels c (t + 1) (W (g 0))`
      (prefix `[t+1, W 0)` of type `α` followed by `g 0` further `σ`-segments — so `PrefixStar α
      σ u`, which is what Phase 6's membership half uses; record `u`'s shape as a conjunct).
- [x] Carry `cutAt`-style position bookkeeping as a small helper (`blockStart`), with
      `blockStart_succ` and coverage, modelled on `HitOf.lean`'s `cutAt`/`cutAt_succ`. *(deviation: altered — the blocks are returned as a cut sequence `V` with `labels c (V a) (V (a + 1))` as the block, so no `blockStart` helper is needed; `starZero_labels` is the coverage lemma)*

**Timing**: 1.5 hours

**Depends on**: 2, 4

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: ~200-300 lines. Confirm the Ramsey colour type is a `Type` (universe 0)
with a `Finite` instance before writing the proof — `Nat.exists_strictMono_const_pair_colour`
is stated for `{C : Type} [Finite C]` (re-read at plan time at
`ForMathlib/Combinatorics/InfiniteRamseyPairs.lean`, `namespace Nat`).

**Tier Justification**: `lake build FormalSystem.Metalogic.Decidability.RaySummary.Periodic` is
the complete covering check; this phase adds theorems to one module and no signature consumed
elsewhere.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/Periodic.lean` - `blockStart`, `exists_blocks_fwd`

**Verification**:
- `lake build …Periodic` exits 0; no `sorry`; the `#print axioms` line for `exists_blocks_fwd`
  at the standard profile or a subset.

---

### Phase 6: Forward Transport `exists_periodic_fwd` [COMPLETED]

**Goal**: (★₊) — a bounded prefix `u'` and period `v'` with `(α, σ) ∈ FwdTypes (fwdPeriodic u' v'
t) t` and `FwdTypes (fwdPeriodic u' v' t) t ⊆ FwdTypes c t`.

**Tasks**:
- [x] Pick `u'`, `v'` by Phase 3 from `u` and `B 0` (`profile u' = profile u`, `cutProfile u' ⊆
      cutProfile u`, `profile v' = E`, `cutProfile v' ⊆ CP`, lengths `< P ^ 2`, `v' ≠ []`).
- [x] Membership: `PrefixStar α σ u'` (read off `profile u' = profile u`,
      `prefixStar_iff_profile`) and `StarPlus σ v'` (`starPlus_iff_profile`) give a `W` for
      `fwdPeriodic u' v' t` directly (cut at the end of `u'`'s `α`-prefix, then at each
      `σ`-piece boundary, then period by period).
- [x] Containment, the core: given `(α', σ') ∈ FwdTypes (fwdPeriodic u' v' t) t` with cuts `W'`,
      infinitely many cuts fall in the periodic part; by pigeonhole on `W' i mod v'.length`
      (`Finite.exists_infinite_fiber` or `Fintype.exists_ne_map_eq_of_card_lt` on a window of
      `v'.length + 1` cuts) two cuts share an offset `o`, in copies `a₀ < a₀ + s`.
- [x] With `z := v'.take o`, `y := v'.drop o`: `PrefixStar α' σ' (u' ++ flatten (replicate (a₀-1)
      v') ++ z)` and `StarPlus σ' (y ++ flatten (replicate (s-1) v') ++ z)` (each is a union of
      consecutive `σ'`-pieces of `W'`, read as `labels` of the periodic colouring by Phase 4).
- [x] Transport: `(profile z, profile y) ∈ cutProfile v' ⊆ CP = cutProfile (B a)` for every `a`,
      so choose in every block a cut `(z_a, y_a)` with `profile z_a = profile z`, `profile y_a =
      profile y`; by `profile_flatten_congr`, `profile (u ++ B 0 ++ … ++ B (a₀-2) ++ z_{a₀-1}) =
      profile (u' ++ flatten (replicate (a₀-1) v') ++ z)` and `profile (y_a ++ B (a+1) ++ … ++
      z_{a+s})` equals `profile (y ++ flatten (replicate (s-1) v') ++ z)`; read `PrefixStar α' σ'`
      and `StarPlus σ'` off the equal profiles.
- [x] Assemble `W''` for `c`: the chosen cut positions in blocks `a₀-1, a₀-1+s, a₀-1+2s, …`
      (strictly monotone, first `≥ t + 1`), whose successive stretches are the `StarPlus σ'`
      words above — hence a factorization `L_{α'} L_{σ'}^ω` of `c`'s tail, i.e. `(α', σ') ∈
      FwdTypes c t` (each `StarPlus` stretch refines to `σ'`-typed segments: re-cut at the piece
      boundaries inside it to produce `W''` with EVERY segment of type `σ'`). *(deviation: altered — the re-cutting is a generic lemma, `mem_fwdTypes_of_pieces`/`mem_fwdTypes_of_stretches` on `refineIdx`/`refineCut`, used by both the membership and the containment half)*
- [x] `theorem exists_periodic_fwd (hk : 1 ≤ k) (c) (t) {x} (hx : x ∈ FwdTypes c t) : ∃ u v, v ≠
      [] ∧ u.length < Nat.card (Profile sig k) ^ 2 ∧ v.length < Nat.card (Profile sig k) ^ 2 ∧ x
      ∈ FwdTypes (fwdPeriodic u v t) t ∧ FwdTypes (fwdPeriodic u v t) t ⊆ FwdTypes c t`.

**Timing**: 2 hours

**Depends on**: 3, 5

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: ~350-500 lines, the largest single proof of the record. If it exceeds one
dispatch, checkpoint with `bash .claude/scripts/git-snapshot.sh 762 --no-revert` per
`context/patterns/checkpoint-before-overflow.md` and resume from the recorded goal state; if the
containment half does not close, STOP and return `[BLOCKED]` with the goal state in the summary
(the record's contingency), leaving Phases 1-5 landed and no `sorry` anywhere.

**Tier Justification**: `lake build FormalSystem.Metalogic.Decidability.RaySummary.Periodic` is
the complete covering check; no other module consumes `exists_periodic_fwd` yet.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/Periodic.lean` - offset pigeonhole, cut transport, `exists_periodic_fwd`

**Verification**:
- `lake build …Periodic` exits 0; no `sorry`; `#print axioms exists_periodic_fwd` at the
  standard profile or a subset.

---

### Phase 7: Backward Mirror `exists_periodic_bwd` [COMPLETED]

**Goal**: (★₋) — the same statement for the backward tail: `w'` and `u'` bounded, `(σ, β) ∈
BwdTypes (bwdPeriodic w' u' t) t`, `BwdTypes (bwdPeriodic w' u' t) t ⊆ BwdTypes c t`.

**Tasks**:
- [x] Decide the route at phase start and record it in `progress-file.md`: (a) duplication —
      mirror Phases 5-6 with `StrictAnti W`, blocks read right-to-left, prefix at the END of the
      stretch (`StarZero σ q ++ β`-suffix form `SuffixStar`), the Ramsey colouring on `labels c
      (W j) (W i)` for `i < j`; or (b) a reversal transfer `kTypeOf (listSeg l.reverse)` as a
      function of `kTypeOf (listSeg l)` (through the order-dual of `OrderedMonadicStructure` and
      a formula transformation swapping the arguments of `lt`), from which (★₋) is (★₊) on the
      reversed colouring. (a) is the plan's default (precedent `exists_zFactorization`). *(decision: route (b) taken — the back-and-forth game `kEquiv_iff_backForth` is atom-symmetric under order reversal (`atoms_dual_iff`, `backForth_dual`, `kEquiv_dual`), giving `kTypeOf_listSeg_reverse_congr` in ~60 lines; recorded here since this agent keeps no progress-file)*
- [x] `exists_blocks_bwd`, the mirrored cut transport, and `theorem exists_periodic_bwd (hk : 1 ≤
      k) (c) (t) {x} (hx : x ∈ BwdTypes c t) : ∃ w u, w ≠ [] ∧ w.length < Nat.card (Profile sig k)
      ^ 2 ∧ u.length < Nat.card (Profile sig k) ^ 2 ∧ x ∈ BwdTypes (bwdPeriodic w u t) t ∧ BwdTypes
      (bwdPeriodic w u t) t ⊆ BwdTypes c t`. *(deviation: altered — under route (b) there is no `exists_blocks_bwd`; instead `reflect`, `revType`, `kTypeOf_segZ_reflect`, `revType_segZ`, `mem_bwdTypes_iff_reflect`, `reflect_bwdPeriodic`, and `exists_periodic_bwd` as `exists_periodic_fwd` on the reflection)*

**Timing**: 2 hours

**Depends on**: 6

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: ~450-650 lines under route (a) (Phases 5-6 re-measured and mirrored);
~250-400 under route (b) plus whatever the reversal lemma costs. Confirm by `wc -l` and apply
the longFile rule to `Periodic.lean` if it crosses 1500 lines.

**Tier Justification**: `lake build FormalSystem.Metalogic.Decidability.RaySummary.Periodic` is
the complete covering check; no other module consumes `exists_periodic_bwd` yet.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/Periodic.lean` - `exists_blocks_bwd`, `exists_periodic_bwd` (and the reversal transfer under route (b))

**Verification**:
- `lake build …Periodic` exits 0; no `sorry`; `#print axioms exists_periodic_bwd` at the
  standard profile or a subset.

---

### Phase 8: Family Triples Through the Seam [COMPLETED]

**Goal**: Decompose `familyTriples sig k c` at a colouring whose `now` letter holds exactly at
`t` into a backward tail pair, the letter at `t`, and a forward tail pair — both directions.

**Tasks**:
- [x] `theorem now_mem_middle (hk : 1 ≤ k) (F : SegmentFactorization sig k c) (hnow : ∀ z, c now
      z ↔ z = t) : F.W 0 ≤ t ∧ t < F.W 1` — if `t` sat in a positive segment, every positive
      segment (same type, `exists_interp_iff_of_kTypeOf_eq`) would contain a `now` position,
      contradicting uniqueness; mirror for negative segments.
- [x] `def letterAt (c) (t) : sig.preds → Bool := fun p => decide (c p t)` (classical).
- [x] `theorem mem_familyTriples_iff_tails (hk) (hnow) : x ∈ familyTriples sig k c ↔ ∃ β α,
      (x.1, β) ∈ BwdTypes c t ∧ (α, x.2.2) ∈ FwdTypes c t ∧ ∀ lβ lα, kTypeOf (listSeg lβ) = β →
      kTypeOf (listSeg lα) = α → x.2.1 = kTypeOf (listSeg (lβ ++ [letterAt c t] ++ lα))` —
      (→) from `F` via `now_mem_middle`, `kTypeOf_segZ_eq_listSeg`, the `labels` split at `t`
      and `t + 1`, and `kTypeOf_listSeg_append_congr`; (←) build the `SegmentFactorization`
      from the two cut sequences (`W 0 := Wb 0`, `W (i+1) := Wf i`, `W (-(i+1)) := Wb (i+1)`;
      `mono` and `cover` from `StrictMono`/`StrictAnti`), its middle type by the same lemmas.
- [x] Shape freedom: the implementer may replace the `∀ lβ lα` clause by any equivalent
      well-defined "middle type" formulation; only `exists_periodic_subfamily` (Phase 9) is in
      the Goals set. *(deviation: altered — the middle clause landed in the ∃-form `∃ lβ lα, type lβ = β ∧ type lα = α ∧ x.2.1 = type (lβ ++ letterAt c t :: lα)`, equivalent by the congruence and easier to consume in both directions; `segmentFactorization_lt` and `not_now_of_eq_segments` are the helpers)*

**Timing**: 2 hours

**Depends on**: 4

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: ~250-350 lines. Check `SegmentFactorization`'s full field list
(`Family.lean`, from line 70 at plan time: `W`, `mono`, `cover`, the three types and their
segment equations) before building the converse; the field names beyond `W`/`mono`/`cover` were
not re-read this session and must be confirmed in the file.

**Tier Justification**: `lake build FormalSystem.Metalogic.Decidability.RaySummary.Periodic` is
the complete covering check; this phase adds theorems to one module only.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/Periodic.lean` - `now_mem_middle`, `letterAt`, `mem_familyTriples_iff_tails`

**Verification**:
- `lake build …Periodic` exits 0; no `sorry`; standard axiom profile or a subset.

---

### Phase 9: The Seam Assembly `exists_periodic_subfamily` [COMPLETED]

**Goal**: (★) — every family triple of a colouring with `now` exactly at `t` is a triple of a
bounded bi-ultimately-periodic colouring, with `now` exactly at `t`, whose family triples all
belong to the original's.

**Tasks**:
- [x] From `hx` and Phase 8 obtain `β, α`; apply `exists_periodic_bwd` to `(x.1, β)` and
      `exists_periodic_fwd` to `(α, x.2.2)`, getting `w, u_b` and `u_f, v`.
- [x] Set `m := u_b ++ [letterAt c t] ++ u_f`, `b := t - u_b.length`; show `periodicColouring w
      m v b` agrees with `bwdPeriodic w u_b t` on `z < t`, with `fwdPeriodic u_f v t` on `z > t`,
      and reads `letterAt c t` at `t`; `now` holds exactly at `t` (the `w`/`v` letters are
      `now`-free because they occur at positions `≠ t` of `c`'s tails, through the tail
      agreements of Phase 4 and the equal-profile transport — state and prove
      `now_free_of_periodic` explicitly). *(deviation: altered — `now`-freeness is transferred along the shared tail type instead of letter by letter: `fwd_now_free_transfer`/`bwd_now_free_transfer` (type-visibility of `now` at `k ≥ 1`), with the glue agreements `periodicLetter_glue_lt`/`_gt`/`_t`)*
- [x] Membership: `x ∈ familyTriples (periodicColouring w m v b)` by Phase 8 (←) with the tail
      memberships and the middle clause.
- [x] Containment: for `x' ∈ familyTriples (periodicColouring …)`, Phase 8 (→) gives tails in
      `BwdTypes (bwdPeriodic …) ⊆ BwdTypes c t` and `FwdTypes (fwdPeriodic …) ⊆ FwdTypes c t`
      (via `bwdTypes_congr`/`fwdTypes_congr`), same letter at `t`, hence `x' ∈ familyTriples c`
      by Phase 8 (←).
- [x] `theorem exists_periodic_subfamily (hk : 1 ≤ k) (c) (now) (t) (hnow : ∀ z, c now z ↔ z =
      t) {x} (hx : x ∈ familyTriples sig k c) : ∃ w m v b, w ≠ [] ∧ v ≠ [] ∧ w.length < Nat.card
      (Profile sig k) ^ 2 ∧ m.length ≤ 2 * Nat.card (Profile sig k) ^ 2 ∧ v.length < Nat.card
      (Profile sig k) ^ 2 ∧ (∀ z, periodicColouring w m v b now z ↔ z = t) ∧ x ∈ familyTriples sig
      k (periodicColouring w m v b) ∧ familyTriples sig k (periodicColouring w m v b) ⊆
      familyTriples sig k c`.

**Timing**: 1.5 hours

**Depends on**: 6, 7, 8

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: ~150-250 lines; `m.length ≤ 2 P ^ 2` follows from `u_b.length + 1 +
u_f.length ≤ (P ^ 2 - 1) + 1 + (P ^ 2 - 1)`, needing `1 ≤ P` (`Nat.card_pos` on the nonempty
finite `Profile`).

**Tier Justification**: `lake build FormalSystem.Metalogic.Decidability.RaySummary.Periodic` is
the complete covering check; `exists_periodic_subfamily` is consumed only by `HitComplete.lean`,
which Phase 13 builds against it.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/Periodic.lean` - `now_free_of_periodic`, `exists_periodic_subfamily`

**Verification**:
- `lake build …Periodic` exits 0; no `sorry`; `#print axioms exists_periodic_subfamily` at
  `[propext, Classical.choice, Quot.sound]` or a subset; `wc -l` recorded in the summary.

---

### Phase 10: `HitComplete.lean` — The Gadget and Its Unique Anchored Run [COMPLETED]

**Goal**: Create `FormalSystem/Metalogic/Decidability/RaySummary/HitComplete.lean` (importing
`Periodic` and `HitOf`; gadget section in namespace `FormalSystem.Metalogic.WeakCanonical`,
headline section in `FormalSystem.Metalogic.Decidability.RaySummary`) with the three-piece
presentation of a periodic word and the characterization of its anchored runs.

**Tasks**:
- [x] `abbrev GadgetState {sig} (w m v : List (sig.preds → Bool)) : Type := Fin w.length ⊕ Fin
      m.length ⊕ Fin v.length` (so `Fintype`/`DecidableEq` are inferred); `def gadgetLab w m v :
      GadgetState w m v → sig.preds → Bool` reading the letter at the index; `def gadgetStep w m v
      : GadgetState w m v → GadgetState w m v → Bool` — `w`-cycle (`i → i+1`, last `w` → first
      `m`, or → first `v` if `m = []`), `m`-path, last `m` → first `v`, `v`-cycle; a `#guard` on
      a two-letter toy (`Fin 1 ⊕ Fin 1 ⊕ Fin 1`) documenting the step table.
- [x] `def gadgetRun w m v (b : ℤ) : ℤ → GadgetState w m v` — the canonical run reading
      `periodicColouring w m v b` (same three-case clock as Phase 4), with `isRun_gadgetRun`
      (anchored at `t` whenever `periodicColouring … now` holds exactly at `t`), and
      `runTrace_gadgetRun : runTrace (gadgetLab w m v) (gadgetRun w m v b) = periodicColouring w
      m v b` (as `Prop`-valued functions, by `funext` and the `Bool`/`Prop` bridge).
- [x] `theorem isRun_gadget_iff (hw : w ≠ []) (hv : v ≠ []) (hnow : ∀ z, periodicColouring w m v
      b now z ↔ z = t) (ρ) : IsRun (gadgetLab w m v) (gadgetStep w m v) now t ρ ↔ ρ = gadgetRun
      w m v b` — (←) above; (→): `ρ t` is the unique `now` state (the `m`-index carrying `now`),
      then successor-determinism after `t` (`m`-path then `v`-cycle are functional) and
      predecessor-determinism before `t` (the only predecessor of an `m` index `> 0` is its
      predecessor; of `m` index `0` is the last `w` index; of a `w` index is its predecessor in
      the cycle) by the two-sided induction `Probe745`'s gadget confinement uses
      (`inl_bwd_pre`-style `key` on `t - 1 - n`). *(deviation: altered — `gadgetRun` takes `hw : w ≠ []` and `hv : v ≠ []` (needed to form `Fin` indices); the two-sided induction is `gadgetStep_inr_unique` (successor-determinism on `inr` states) and `gadgetStep_pred_unique` (predecessor-determinism on non-`v` states), with `mid_of_now_unique` forcing `b ≤ t < b + |m|` from `hnow` alone)*
- [x] Wiring: aggregator and `FormalSystem.lean` imports (after `Periodic`).

**Timing**: 2 hours

**Depends on**: 4

**Verification Tier**: interface

**Commit Mode**: per-substep

**Scope Hypothesis**: ~350-450 lines (Probe745's one-gadget run characterization, lines
1092-1503 at plan time, is ~410 for two gadgets); whole module 700-1000 lines after Phases
11-13.

**Tier Justification**: `lake build FormalSystem.Metalogic.Decidability.RaySummary.HitComplete`
then `lake build FormalSystem.Metalogic.Decidability.RaySummary` covers the new module and the
aggregator, its only direct dependent.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/HitComplete.lean` - new module: `GadgetState`, `gadgetLab`, `gadgetStep`, `gadgetRun`, `isRun_gadget_iff`, `runTrace_gadgetRun`
- `FormalSystem/Metalogic/Decidability/RaySummary.lean` - one import line and one docstring sentence
- `FormalSystem.lean` - one import line

**Verification**:
- Both `lake build` commands exit 0; no `sorry`; `gadgetLab`/`gadgetStep` are plain `def`s and
  the toy `#guard` passes.

---

### Phase 11: `hitOf_gadget_eq` [COMPLETED]

**Goal**: A gadget's computable realized-triple set is exactly the family-triple set of its
periodic trace.

**Tasks**:
- [x] `theorem hitOf_gadget_eq (hk : 1 ≤ k) (hw : w ≠ []) (hv : v ≠ []) (hnow : ∀ z,
      periodicColouring w m v b now z ↔ z = t) : (↑(hitOf (gadgetLab w m v) (gadgetStep w m v)
      now k) : Set _) = familyTriples sig k (periodicColouring w m v b)` — by `Set.ext`,
      `mem_hitOf_iff t hk`, `isRun_gadget_iff`, `runTrace_gadgetRun`, `mem_familyTriples`.

**Timing**: 1 hour

**Depends on**: 10

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: ~40-80 lines; the whole weight is in Phase 10's characterization. Confirm
`mem_hitOf_iff`'s argument order `(t : ℤ) (hk : 1 ≤ k) (x)` against `HitOf.lean` (re-read at
plan time at its line 795) when applying it.

**Tier Justification**: `lake build FormalSystem.Metalogic.Decidability.RaySummary.HitComplete`
is the complete covering check; no other module consumes this theorem.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/HitComplete.lean` - `hitOf_gadget_eq`

**Verification**:
- `lake build …HitComplete` exits 0; no `sorry`; standard axiom profile or a subset.

---

### Phase 12: Disjoint Unions of Presentations `hitOf_sigma_eq` [COMPLETED]

**Goal**: `hitOf` of the disjoint union of a finite family of presentations (no cross edges) is
the union of their `hitOf`s, with the cardinality of the union's state type as a sum.

**Tasks**:
- [x] `def sigmaLab {ι} (Q : ι → Type) (lab : ∀ i, Q i → sig.preds → Bool) : (Σ i, Q i) →
      sig.preds → Bool`; `def sigmaStep (step : ∀ i, Q i → Q i → Bool) : (Σ i, Q i) → (Σ i, Q i)
      → Bool := fun ⟨i, q⟩ ⟨j, q'⟩ => if h : i = j then step j (h ▸ q) q' else false` (with
      `[DecidableEq ι]`).
- [x] `theorem isRun_sigma_iff`: a run of the union stays in one summand (`step` across
      summands is `false`), i.e. `IsRun (sigmaLab …) (sigmaStep …) now t ρ ↔ ∃ i ρ', IsRun (lab i)
      (step i) now t ρ' ∧ ρ = fun z => ⟨i, ρ' z⟩`, and `runTrace_sigma`.
- [x] `theorem hitOf_sigma_eq (hk : 1 ≤ k) [Fintype ι] [DecidableEq ι] [∀ i, Fintype (Q i)] [∀
      i, DecidableEq (Q i)] : hitOf (sigmaLab Q lab) (sigmaStep Q step) now k = Finset.univ.biUnion
      (fun i => hitOf (lab i) (step i) now k)` via `mem_hitOf_iff` and `isRun_sigma_iff`.
- [x] `Fintype.card_sigma` is Mathlib's; note the bound form `Fintype.card (Σ i, Q i) ≤
      Fintype.card ι * B` when every `Fintype.card (Q i) ≤ B` (`Finset.sum_le_card_nsmul`). *(deviation: altered — landed as `card_sigma_le` via `Fintype.card_sigma`, `Finset.sum_le_sum` and `Finset.sum_const`)*

**Timing**: 1.5 hours

**Depends on**: 10

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: ~150-250 lines; `Fintype.card_sigma`'s exact name and the `Finset.sum_le_card_nsmul`
shape are to be confirmed with `lean_local_search`/`lean_loogle` at implementation time (not
re-derived at plan time).

**Tier Justification**: `lake build FormalSystem.Metalogic.Decidability.RaySummary.HitComplete`
is the complete covering check; this phase adds generic lemmas to one module only.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/HitComplete.lean` - `sigmaLab`, `sigmaStep`, `isRun_sigma_iff`, `hitOf_sigma_eq`

**Verification**:
- `lake build …HitComplete` exits 0; no `sorry`; standard axiom profile or a subset.

---

### Phase 13: `sizeBound` and the Headline `exists_hitPresented` [COMPLETED]

**Goal**: Assemble the filed statement verbatim, with the count exhibited, and write the module's
"what it does NOT say" docstring.

**Tasks**:
- [x] Section `namespace FormalSystem.Metalogic.Decidability.RaySummary`, `variable {F : FrameOver
      intOrder}`, opens as `Trace.lean` (line 74-75 at plan time).
- [x] `noncomputable def sizeBound (φ : PlusFormula) (k : ℕ) : ℕ := Nat.card (KType (clSig φ) k)
      ^ 3 * (4 * Nat.card (Profile (clSig φ) k) ^ 2 + 1)` with the disclaimer docstring
      (`AnchorLayer.lean`'s words, "types and profiles" for "cells").
- [x] `theorem exists_hitPresented (M : TaskModel F.toTaskFrame) [F.IsRegular] (τ : WorldHistory
      F.toTaskFrame) (t : ℤ) (φ : PlusFormula) (k : ℕ) (hk : 1 ≤ k) : ∃ (Q : Type) (_ : Fintype
      Q) (_ : DecidableEq Q) (lab : Q → (clSig φ).preds → Bool) (step : Q → Q → Bool),
      Fintype.card Q ≤ sizeBound φ k ∧ HitPresented M τ t φ lab step k`:
      - `classical`; `haveI := (hitCl_finite M τ t φ k).fintype`; for each `x : ↥(HitCl M τ t φ
        k)` obtain `bf` from `hitCl_eq_iUnion` (membership in the `⋃`), then `w m v b` from
        `exists_periodic_subfamily` applied to `c := clTrace M φ t (spliced τ t bf)` with `now :=
        clNow φ` and `hnow` from `Trace.lean`'s anchoring of `clTrace` at `t` (the `clNow` clause
        of `clTrace_anchored` — confirm its exact name/shape in `Trace.lean` `## Soundness`);
      - `Q := Σ x : ↥(HitCl …), GadgetState (w x) (m x) (v x)`, `lab := sigmaLab`, `step :=
        sigmaStep`;
      - `HitPresented` unfolds to `HitCl = ↑(hitOf …)`: by `hitOf_sigma_eq`, `hitOf_gadget_eq`,
        `Finset.coe_biUnion`; `⊆` from each `familyTriples (periodic x) ⊆ familyTriples (c x) ⊆
        HitCl` (`hitCl_eq_iUnion` again); `⊇` from `x ∈ familyTriples (periodic x)`; *(deviation: altered — rewriting with `hitOf_sigma_eq` timed out in `isDefEq` (the union's `hitOf` instance paths), so the set equality is proved pointwise through `mem_hitOf_iff` on the union, `isRun_sigma_iff` and `hitOf_gadget_eq`; `hitOf_sigma_eq` itself is landed and pinned)*
      - the count: `Fintype.card Q = ∑ x, (w x).length + (m x).length + (v x).length ≤ card
        ↥HitCl * (4 P ^ 2 + 1) ≤ N ^ 3 * (4 P ^ 2 + 1)` with `card ↥HitCl ≤ Fintype.card (KType ×
        KType × KType) = N ^ 3` (`Fintype.card_subtype_le`, `Fintype.card_prod`, `Nat.card_eq_fintype_card`).
- [x] Module docstring (`HitComplete.lean`): the headline, the route in four sentences, and the
      section "What `exists_hitPresented` does NOT say": no complexity bound; `sizeBound` counts
      types and profiles; no `Decidable (PlusValidZTime φ)`; one seam; `[F.IsRegular]` is the
      only hypothesis and `Fintype` is on the presentation; the presentation is noncomputable
      (classical choice per triple); nothing about `⊡(Pp)` (direction-neutral combinatorics, no
      backward Bool-fixture bridge); `Presented` stays refuted as a completeness carrier
      (`Probe735.not_presented`, cited by name not path). No task number anywhere.
- [x] `#print axioms` lines for `exists_hitPresented`, `exists_periodic_subfamily`,
      `profile_append_congr` observed and recorded in `progress-file.md`.

**Timing**: 1.5 hours

**Depends on**: 9, 11, 12

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: ~150-250 lines. The statement is the filed one character for character
(re-read against the dispatch Description at plan time); any binder-shape change (e.g. `{F}`
implicit vs explicit, instance order) must preserve the user-visible shape `exists_hitPresented
(M) [F.IsRegular] (τ) (t) (φ) (k) (hk : 1 ≤ k) : ∃ Q …` and be recorded in the summary.

**Tier Justification**: `lake build FormalSystem.Metalogic.Decidability.RaySummary.HitComplete`
is the complete covering check for the Lean; the pins, index rows and README that consume the
new names are Phase 14's `full` sweep.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/HitComplete.lean` - `sizeBound`, `exists_hitPresented`, module docstring

**Verification**:
- `lake build …HitComplete` exits 0; `#print axioms
  FormalSystem.Metalogic.Decidability.RaySummary.exists_hitPresented` reads `[propext,
  Classical.choice, Quot.sound]`; no `sorry`, no `axiom`, no vacuous definition (`grep -c
  "sorry\|^axiom\|:= True\|:= trivial"` of the three new modules is 0 outside docstrings).

---

### Phase 14: Records, C14 Pins at the Two Synchronized Sites, Theorem Index, README, status.typ, Full Gate [COMPLETED]

**Goal**: Pin the three headline declarations, record the settlement in every in-tree surface
the task's `file_scope` names, and run the complete repository gate set.

**Tasks**:
- [x] `scripts/check-module-invariants.sh`: in the C14 block, add three matched pairs — a
      baseline line `'FormalSystem.Metalogic.Decidability.RaySummary.exists_hitPresented' depends
      on axioms: [propext, Classical.choice, Quot.sound]` and the corresponding `#print axioms`
      line, likewise for `FormalSystem.Metalogic.WeakCanonical.exists_periodic_subfamily` and
      `FormalSystem.Metalogic.WeakCanonical.profile_append_congr`, placed directly after the
      `hitCl_modelOf_eq_hitOf` pair in BOTH heredocs (same relative position in each); extend
      the block comment with one paragraph: (C)'s general row, the Ramsey-over-profile route,
      the count disclaimer, "pins a profile and is not a decision procedure", `Presented` still
      refuted. Durable anchors only.
- [x] `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean`: three rows in the "What is
      pinned" table (chain step "seam interface"/"(C)") and three `#guard_msgs` + `#print axioms`
      pairs in the trailing section, in the same shape as the `hitPresented_of_presented` pair
      (lines 420-424 at plan time); one paragraph of prose beside the `HitPresented` paragraph
      stating the general row is landed and what it does not say.
- [x] `docs/theorem-index.md`: three rows directly after the `hitCl_modelOf_eq_hitOf` row —
      `exists_hitPresented` (`HitComplete.lean`, ZTime, `pcq pinned:C14`; statement: requirement
      (C)'s general row, the count `sizeBound φ k` exhibited, no complexity bound, no
      `PlusValidZTime`, one seam, nothing about `⊡(Pp)`), `exists_periodic_subfamily`
      (`Periodic.lean`, `—`), `profile_append_congr` (`Profile.lean`, `—`). Fully qualified Lean
      names; no line numbers; no task number.
- [x] `FormalSystem/Metalogic/Decidability/RaySummary/README.md`:
      - "What it holds": rows for `Profile.lean` and `Periodic.lean` directly after the
        `Transport.lean` row and for `HitComplete.lean` directly after the `Realize.lean` row,
        with `wc -l` line counts measured at phase time;
      - "The verdict", (C) row: the verdict cell states the row is SETTLED in general —
        `exists_hitPresented` (`HitComplete.lean`) for every regular `ℤ`-model, seam, `φ` and
        `k ≥ 1`, count `sizeBound φ k = N^3·(4P^2+1)` exhibited (`N` types, `P` profiles), the
        Ramsey-over-profile route, the two fixtures kept as evidence, `Presented` still refuted,
        the disclaimer; the closing sentence "Without (C), …" is rewritten to say what (C) now
        delivers and what it does not (one seam; the lift is (W));
      - (W) row and "(W): what landed and what did not" obligation (ii) item 2: "completeness:
        (C)'s general row" is marked landed with the theorem named; (W) stays BLOCKED on its
        soundness half only; the "Successor" paragraph's "(C)'s general row" clause is adjusted;
      - "The bound: exhibited on the fixture, as a count": add one paragraph "The bound in
        general" naming `sizeBound`, `Profile`, the disclaimer, and that the transport `↔` of
        `Transport.lean` remains a non-goal;
      - `## Evidence`, the eleventh-probe paragraph: replace the sentence "— a Hit-level
        falsifier for (C) needs a seam with infinitely many histories through it" by a
        present-tense statement that no Hit-level falsifier exists because the general row is a
        theorem (`exists_hitPresented`), and that the probes stay as the two fixture
        exhibitions; add no new probe paragraph (the library theorem is not a probe);
      - `*Last verified:*` date.
      Present-tense design statements only; no "no longer"/"previously"; no task number.
- [x] `FormalSystem/Metalogic/Decidability/RaySummary.lean` docstring: the sentence(s) added in
      Phases 1, 4, 10 re-read as one coherent paragraph naming (C)'s settlement. *(the three module bullets of Phases 1, 4 and 13 are the paragraph)*
- [x] `bash scripts/typst-status-counts.sh` to regenerate `typst/generated/status.typ`; commit
      the regenerated file.
- [x] Run the complete gate set (below), each detached where the pattern requires, every exit
      status recorded; commit; write the implementation summary per `summary-format.md`
      including the `wc -l` of the three modules, the route chosen in Phase 7, and the three
      `#print axioms` lines.

**Timing**: 2 hours

**Depends on**: 13

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: Three C14 pairs at each of two sites (six insertions), three theorem-index
rows, three README table rows plus five prose amendments. At plan time the C14 baseline heredoc
and its `#print axioms` list each carry one `hitCl_modelOf_eq_hitOf` line (script lines 2331 and
2562) — confirm by `grep -n hitCl_modelOf_eq_hitOf scripts/check-module-invariants.sh` returning
exactly one line in each heredoc before inserting, and re-count (+3 each) after; the test file's
pin section ends at the `hitCl_modelOf_eq_hitOf` pair — confirm by reading the file's tail.

**Files to modify**:
- `scripts/check-module-invariants.sh` - three C14 baseline/`#print axioms` pairs and one comment paragraph
- `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` - three table rows, one prose paragraph, three pin pairs
- `docs/theorem-index.md` - three rows after the `hitCl_modelOf_eq_hitOf` row
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` - three table rows, (C) row, (W) row, obligation (ii) item 2, "The bound in general" paragraph, Evidence sentence, `Last verified`
- `FormalSystem/Metalogic/Decidability/RaySummary.lean` - docstring paragraph
- `typst/generated/status.typ` - regenerated by `scripts/typst-status-counts.sh`

**Verification** (the complete gate set — every command's exit status is checked, never only
its output):
- Full `lake build` via `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build`,
  detached (`Bash(run_in_background: true)`) with a bounded waiter per
  `context/patterns/bounded-build-waiter.md`, exits 0.
- `lake build BimodalTest.Metalogic.KTypeSummaryAxiomTest` exits 0 (the six new `#guard_msgs`
  pass).
- `bash scripts/check-module-invariants.sh` exits 0 (C14 with the three new pairs; C9 zero
  task-number or `specs/NNN_` citations under `FormalSystem/`, `scripts/`, `docs/`), detached
  with a bounded waiter.
- `bash .claude/scripts/check-task-references.sh --quiet` exits 0 on the files this task
  touched (if it exits non-zero repo-wide on pre-existing occurrences, as the sibling record's
  summary reports, run it on the touched paths and record the repo-wide figure as pre-existing).
- `bash scripts/readme-lint.sh FormalSystem/Metalogic/Decidability/RaySummary` exits 0.
- `bash .claude/scripts/lean-sorry-census.sh` count 0 over the three new modules; `grep -rn
  "^axiom " FormalSystem/` count unchanged from baseline; vacuous-definition grep count 0.
- `bash scripts/typst-status-counts.sh` exits 0 and `git diff --stat typst/generated/status.typ`
  shows only stamp and count changes.
- `bash .claude/scripts/verify-deploy.sh` exits 0.
- `git status --short` shows no modified file outside the task's `file_scope` (ten entries). *(deviation: altered — the INV check required regenerating the inventory blocks of `README.md`, `FormalSystem/README.md`, `FormalSystem/Metalogic/README.md`, all in `file_scope`; C15 required `Paper:` lines on two docstrings and C16 the removal of two unused `[Finite sig.preds]` binders, so `Profile.lean`/`Periodic.lean` are in this phase's commit too)*

## Lean Challenge Statements

The definitional bodies of `Profile` and `sizeBound` are part of the contract (guardrail (c):
the count is exhibited, never `∃ L`) and are therefore written out, as are the one-line
abbreviations `fwdPeriodic`/`bwdPeriodic`/`GadgetState`; every other body is `sorry`. Implicit
`sig`/`k` binders are made explicit here so the block type-checks standalone.

```lean
import FormalSystem

open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.PlusLanguage
open FormalSystem.Metalogic.WeakCanonical FormalSystem.Metalogic.Expressiveness
open FormalSystem.Metalogic.Decidability.RaySummary

namespace FormalSystem.Metalogic.WeakCanonical

variable (sig : MonadicSignature) [Fintype sig.preds] [DecidableEq sig.preds] (k : ℕ)

abbrev Profile : Type := KType sig k × (KType sig k → KType sig k → KType sig k → Bool)

noncomputable def profile (l : List (sig.preds → Bool)) : Profile sig k := sorry

noncomputable def cutProfile (l : List (sig.preds → Bool)) :
    Set (Profile sig k × Profile sig k) := sorry

theorem profile_append_congr (hk : 1 ≤ k) {l₁ l₁' l₂ l₂' : List (sig.preds → Bool)}
    (h₁ : profile sig k l₁ = profile sig k l₁') (h₂ : profile sig k l₂ = profile sig k l₂') :
    profile sig k (l₁ ++ l₂) = profile sig k (l₁' ++ l₂') := sorry

theorem exists_rep_of_length_lt (hk : 1 ≤ k) (l : List (sig.preds → Bool)) :
    ∃ l' : List (sig.preds → Bool), l'.length < Nat.card (Profile sig k) ^ 2 ∧
      profile sig k l' = profile sig k l ∧ cutProfile sig k l' ⊆ cutProfile sig k l := sorry

def periodicColouring (w m v : List (sig.preds → Bool)) (b : ℤ) : sig.preds → ℤ → Prop := sorry

abbrev fwdPeriodic (u v : List (sig.preds → Bool)) (t : ℤ) : sig.preds → ℤ → Prop :=
  periodicColouring sig v u v (t + 1)

abbrev bwdPeriodic (w u : List (sig.preds → Bool)) (t : ℤ) : sig.preds → ℤ → Prop :=
  periodicColouring sig w u w (t - u.length)

def FwdTypes (c : sig.preds → ℤ → Prop) (t : ℤ) : Set (KType sig k × KType sig k) := sorry

def BwdTypes (c : sig.preds → ℤ → Prop) (t : ℤ) : Set (KType sig k × KType sig k) := sorry

theorem exists_periodic_fwd (hk : 1 ≤ k) (c : sig.preds → ℤ → Prop) (t : ℤ)
    {x : KType sig k × KType sig k} (hx : x ∈ FwdTypes sig k c t) :
    ∃ u v : List (sig.preds → Bool), v ≠ [] ∧
      u.length < Nat.card (Profile sig k) ^ 2 ∧ v.length < Nat.card (Profile sig k) ^ 2 ∧
      x ∈ FwdTypes sig k (fwdPeriodic sig u v t) t ∧
      FwdTypes sig k (fwdPeriodic sig u v t) t ⊆ FwdTypes sig k c t := sorry

theorem exists_periodic_bwd (hk : 1 ≤ k) (c : sig.preds → ℤ → Prop) (t : ℤ)
    {x : KType sig k × KType sig k} (hx : x ∈ BwdTypes sig k c t) :
    ∃ w u : List (sig.preds → Bool), w ≠ [] ∧
      w.length < Nat.card (Profile sig k) ^ 2 ∧ u.length < Nat.card (Profile sig k) ^ 2 ∧
      x ∈ BwdTypes sig k (bwdPeriodic sig w u t) t ∧
      BwdTypes sig k (bwdPeriodic sig w u t) t ⊆ BwdTypes sig k c t := sorry

theorem exists_periodic_subfamily (hk : 1 ≤ k) (c : sig.preds → ℤ → Prop) (now : sig.preds)
    (t : ℤ) (hnow : ∀ z, c now z ↔ z = t)
    {x : KType sig k × KType sig k × KType sig k} (hx : x ∈ familyTriples sig k c) :
    ∃ (w m v : List (sig.preds → Bool)) (b : ℤ), w ≠ [] ∧ v ≠ [] ∧
      w.length < Nat.card (Profile sig k) ^ 2 ∧ m.length ≤ 2 * Nat.card (Profile sig k) ^ 2 ∧
      v.length < Nat.card (Profile sig k) ^ 2 ∧
      (∀ z, periodicColouring sig w m v b now z ↔ z = t) ∧
      x ∈ familyTriples sig k (periodicColouring sig w m v b) ∧
      familyTriples sig k (periodicColouring sig w m v b) ⊆ familyTriples sig k c := sorry

abbrev GadgetState (w m v : List (sig.preds → Bool)) : Type :=
  Fin w.length ⊕ Fin m.length ⊕ Fin v.length

def gadgetLab (w m v : List (sig.preds → Bool)) : GadgetState sig w m v → sig.preds → Bool := sorry

def gadgetStep (w m v : List (sig.preds → Bool)) :
    GadgetState sig w m v → GadgetState sig w m v → Bool := sorry

theorem hitOf_gadget_eq (hk : 1 ≤ k) (now : sig.preds) (w m v : List (sig.preds → Bool))
    (b t : ℤ) (hw : w ≠ []) (hv : v ≠ [])
    (hnow : ∀ z, periodicColouring sig w m v b now z ↔ z = t) :
    (↑(hitOf (gadgetLab sig w m v) (gadgetStep sig w m v) now k) :
        Set (KType sig k × KType sig k × KType sig k)) =
      familyTriples sig k (periodicColouring sig w m v b) := sorry

theorem hitOf_sigma_eq (hk : 1 ≤ k) (now : sig.preds) {ι : Type} [Fintype ι] [DecidableEq ι]
    (Q : ι → Type) [∀ i, Fintype (Q i)] [∀ i, DecidableEq (Q i)]
    (lab : ∀ i, Q i → sig.preds → Bool) (step : ∀ i, Q i → Q i → Bool) :
    hitOf (fun (x : Σ i, Q i) => lab x.1 x.2)
        (fun (x y : Σ i, Q i) => if h : x.1 = y.1 then step y.1 (h ▸ x.2) y.2 else false) now k =
      Finset.univ.biUnion (fun i => hitOf (lab i) (step i) now k) := sorry

end FormalSystem.Metalogic.WeakCanonical

namespace FormalSystem.Metalogic.Decidability.RaySummary

variable {F : FrameOver intOrder}

noncomputable def sizeBound (φ : PlusFormula) (k : ℕ) : ℕ :=
  Nat.card (KType (clSig φ) k) ^ 3 * (4 * Nat.card (Profile (clSig φ) k) ^ 2 + 1)

theorem exists_hitPresented (M : TaskModel F.toTaskFrame) [F.IsRegular]
    (τ : WorldHistory F.toTaskFrame) (t : ℤ) (φ : PlusFormula) (k : ℕ) (hk : 1 ≤ k) :
    ∃ (Q : Type) (_ : Fintype Q) (_ : DecidableEq Q)
      (lab : Q → (clSig φ).preds → Bool) (step : Q → Q → Bool),
      Fintype.card Q ≤ sizeBound φ k ∧ HitPresented M τ t φ lab step k := sorry

end FormalSystem.Metalogic.Decidability.RaySummary
```

## Testing & Validation

- [x] Every new module builds under `lake build <module>` with 0 errors and 0 `sorry` warnings;
      the full guarded `lake build` exits 0.
- [x] `#print axioms` for `exists_hitPresented`, `exists_periodic_subfamily` and
      `profile_append_congr` read `[propext, Classical.choice, Quot.sound]`; no `sorryAx`.
- [x] No `sorry`, `axiom`, or vacuous-definition pattern in the three modules (grep count 0
      outside docstrings); `lean-sorry-census.sh` count 0.
- [x] The twenty Goals identifiers match the Lean Challenge Statements block exactly
      (`lean-challenge-snapshot.sh --check 762 .` advisory; a manifest-absent exit is recorded,
      not treated as failure). *(checked by grep: all twenty identifiers declared; the snapshot check was not run — no manifest exists)*
- [x] The headline statement matches the dispatch's filed statement character for character in
      its user-visible shape (`exists_hitPresented (M) [F.IsRegular] (τ) (t) (φ) (k) (hk : 1 ≤ k)
      : ∃ (Q : Type) (_ : Fintype Q) (_ : DecidableEq Q) (lab) (step), Fintype.card Q ≤ sizeBound
      φ k ∧ HitPresented M τ t φ lab step k`).
- [x] `lake build BimodalTest.Metalogic.KTypeSummaryAxiomTest` exits 0 with the three new pin
      pairs; `check-module-invariants.sh` C14 passes with the three new pairs.
- [x] `check-task-references.sh`, `readme-lint.sh`, `verify-deploy.sh`, `typst-status-counts.sh`
      all exit 0; `git status --short` clean outside `file_scope`.
- [x] README read-through: (C) row, (W) row, obligation (ii) item 2, "The bound in general",
      Evidence sentence, "What it holds" rows, `Last verified` — present tense, durable anchors,
      no task numbers, no record-versioning language.

## Artifacts & Outputs

- `FormalSystem/Metalogic/Decidability/RaySummary/Profile.lean` (new)
- `FormalSystem/Metalogic/Decidability/RaySummary/Periodic.lean` (new)
- `FormalSystem/Metalogic/Decidability/RaySummary/HitComplete.lean` (new)
- `FormalSystem/Metalogic/Decidability/RaySummary.lean`, `FormalSystem.lean` (imports, docstring)
- `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean`, `scripts/check-module-invariants.sh`
  (C14 pins), `docs/theorem-index.md` (three rows),
  `FormalSystem/Metalogic/Decidability/RaySummary/README.md` (amendments),
  `typst/generated/status.typ` (regenerated)
- `specs/762_hit_presented_general_row/summaries/01_hit-presented-general-row-summary.md`

## Rollback/Contingency

- **Phase 2 fails as stated**: strengthen the profile (carry the straddling halves' types), not
  the statement; if it still fails, return `[BLOCKED]` with the goal state — the record's own
  contingency — leaving Phase 1 landed (definitions and read-outs compile and are harmless).
- **Phase 6 or 7 fails**: `[BLOCKED]` with the obstruction recorded in the summary and the
  README untouched beyond the "What it holds" rows for the landed modules; never a `sorry`,
  axiom, vacuous definition, external decidability theorem, or a finite-width/finite-fibre
  hypothesis on `M`.
- **Context overflow mid-phase**: `bash .claude/scripts/git-snapshot.sh 762 --no-revert` (the
  durable, non-reverting checkpoint), progress recorded in `progress-file.md`, resume from the
  last green sub-step commit.
- **A genuine revert of uncommitted work** (only if a landed module must be discarded): the
  snapshot-then-rollback recipe at `context/contracts/recovery.md`'s rollback rung, with its
  out-of-scope override only for the deliberate whole-tree case — never a bare precautionary
  `git-snapshot.sh 762`.
- Committed green sub-steps are never reverted; a later phase that cannot close is reported
  `[PARTIAL]`/`[BLOCKED]` on its own heading with the earlier phases' `[COMPLETED]` markers kept.
