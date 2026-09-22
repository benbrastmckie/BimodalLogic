# Implementation Plan: Task #651

- **Task**: 651 - chain_complete_dense_tm_minus
- **Status**: [NOT STARTED]
- **Effort**: 13.5 hours
- **Dependencies**: 534 (landed; the Conservativity layer this plan builds on is in-tree)
- **Research Inputs**: specs/651_chain_complete_dense_tm_minus/reports/01_chain-complete-dense-route.md
- **Artifacts**: plans/01_chain-complete-dense.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Prove `ChainComplete FrameClass.Dense ∅` — TM⁻_d alone is complete for L⁻ over ℚ-chain
bundles — as a real theorem, turning the `.Dense` row of `FragmentAxiomatization.lean`'s verdict
table from literature-backed into machine-checked. The route is the classical one (Burgess 1984
§2.5, the tense logic of ℚ): an L⁻-typed maximal-consistent-set layer, the canonical `G`- and
`□`-relations on those sets, a Burgess-style ω-stage construction of a single ℚ-indexed chronicle
from any seed MCS, a bundle indexed by one `□`-class of chronicles, and a truth lemma for
`chainSat`. Five new modules land under `FormalSystem/Metalogic/Conservativity/`; nothing is
imported from the `Formula`-typed canonical models (that route is circular, as
`TMCompletenessReduction.lean` records). Done means: `chainComplete_dense` and
`minusExt_iff_tmFrag_dense` sorry-free with standard axioms only, the three two-line corollaries
(`minusValidIn_chainValidIn`, `tmMinusComplete_dense`, `forward_dense`) landed, every docstring
and ledger row that currently says "never asserted / open at `.Dense`" revised, and all gates
green (`lake build --wfail`, `check-module-invariants.sh`, `mk_all --check`,
`check-metalogic-cycles.sh`).

### Research Integration

The plan follows the research report's route lemma-for-lemma (report §Findings 3) and its
six-phase decomposition (report §Recommendations), with the risk phase (the ℚ-chronicle
construction) split into two phases as the report itself recommends. Key findings carried in:

- **Class choice: `.Dense`, `Ax = ∅`, no switch.** It is the only row whose classical proof is a
  single uniform step-by-step construction — no dense/discrete split (`.Base`), no discrete engine
  with a Z1 limit-closure argument and no compactness (`.ZTime`). All four TM⁻_d-specific
  ingredients (DN dual, TL, TS, TC) are axioms or two-line derivations already. Nothing existing
  makes another class cheaper.
- **Nothing in the tree's canonical models is reusable by import**; every MCS/Lindenbaum/truth
  lemma declaration is over `Formula`. The L⁻ side gets its own MCS layer, a near-verbatim mirror
  of `Metalogic/Core/MaximalConsistent.lean` (the probe already compiles the four Lindenbaum
  declarations in ~70 lines, sorry-free).
- **The countable ℚ construction is structural, not optional.** `ChainValidIn` quantifies over
  bundles of copies of *one* ordered group `D`; the full canonical model's `R`-components may be
  uncountable and non-isomorphic, so canonical-model-plus-bulldozing does not land in the
  quantifier. Build the chain directly on ℚ.
- **Bundle index = one `canBox`-class of chronicles.** The `chainSat` box clause quantifies over
  all of `FamIdx × ℚ`, which is exactly what the `◇`-witness case of the truth lemma needs.
- **The assembly contract is the probe's `chainComplete_dense_of_engine` shape**: the engine
  (`¬ ⊢⁻[.Dense] φ → ∃ FamIdx v q, ¬ chainSat v q φ` at `TemporalOrder.of ℚ`) is the interface
  between the chronicle/truth-lemma phases and the final theorem.
- **Downstream prose consequences are mandatory**: `chainComplete_dense` makes several docstrings
  false (enumerated in Phase 7). The corollaries `tmMinusComplete_dense`/`forward_dense` are what
  make those edits honest rather than merely narrower.
- Mathlib names confirmed at the pinned version by the compiled probe: `zorn_subset_nonempty`,
  `exists_surjective_nat`, `Nat.unpair`/`Nat.pair`/`Nat.unpair_pair`/`Nat.right_le_pair`,
  `exists_between`, `Finset.max'`/`min'`, `NoMaxOrder ℚ`/`NoMinOrder ℚ`/`DenselyOrdered ℚ`.
  `Set.Finite.exists_between` does **not** exist.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` was provided in the dispatch context; ROADMAP.md was not consulted.

## Goals & Non-Goals

**Goals**:
- `chainComplete_dense`
- `minusExt_iff_tmFrag_dense`
- `minusValidIn_chainValidIn`
- `tmMinusComplete_dense`
- `forward_dense`

**Non-Goals**:
- `ChainComplete` at `.Base`, `.ZTime`, or `.RTime` — these stay explicit, undischarged
  hypotheses (hard constraint, inherited).
- Any "for all `fc`" chronicle-existence theorem — false at `.Base`/`.ZTime` (no interpolation
  lemma there); `exists_chronicle_through` is stated at `.Dense` only.
- Reusing or refactoring `Metalogic/Core/`, `Metalogic/BXCanonical/`, or the Chronicle engine;
  they remain untouched copy sources.
- Bulldozing, cluster quotienting, Cantor's theorem, or a Löwenheim–Skolem detour.
- Un-commenting or editing the paper's footnote (the `Paper note` in
  `FragmentAxiomatization.lean` stays as a record; the module docstring is edited only where the
  proof makes it false).
- A pattern note under `context/project/lean4/patterns/` (report §Context Extension
  Recommendations) — a follow-up, not this task.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Phase 4/5 (ℚ-chronicle) overruns: four-way `Finset`-extrema case analysis in `insert_future` | H | M | Already split into two phases; state `insert_future` with the disjunctive conclusion of report §3.4 so the "already present" case never places a duplicate irreflexive point; keep `Stage` as `ℚ → Option MPoint` with a `Finset` support so `max'`/`min'` apply directly |
| `canR_weakLinear` proof gets long (three provably-inconsistent TL disjuncts, each a derivation) | M | M | Prove one helper `notF_of_inconsistent : ⊢ ¬χ → ⊢ ¬Fχ` (via `fMono` + `notFBot`) and reuse it three times; use `mem_or_neg_mem` to get the extensionality-or-witness split |
| L⁻ derivations are explicit `DerivationTree` terms and get verbose | M | H | Derive everything through `minusDeductionTheorem` in a context, as `MinusDeduction.lean` does; reuse `minusImpTrans`/`minusContrapos`/`minusFlip`; obtain every past-side lemma by `time_reflection` at `χ.reflectTime` transported along `reflectTime_involution`, never by hand |
| DN gate: `Axiom.dn` requires `FrameClass.Dense ≤ fc` | L | L | Only `fF_of_f` (Phase 2) and `exists_canR_between` (Phase 3) are stated at `.Dense`; discharge with `le_refl`. Everything else stays at variable `fc` |
| Universe of `FamIdx`: `ChainValidIn` fixes `FamIdx : Type` | L | L | `{c : Chronicle // …}` over `ℚ → Set MinusFormula` lives in `Type` (the probe compiles the structure) |
| Docstring drift: several docstrings and ledgers assert "never asserted / open at `.Dense`" | H (prose correctness) | H | Phase 7 carries an explicit checklist; grep `ChainComplete`, `TMMinusComplete`, `never asserted`, `open` across `FormalSystem/Metalogic/Conservativity/`, `FormalSystem/Metalogic.lean`, `docs/theorem-index.md` before closing |
| C14 pin mechanics: the theorem-index `pinned:C14` row is honest only if the `C14LEAN`/`C14BASE` heredoc pair gains matching lines (compared by exact string) | M | M | Run `#print axioms` first, paste the exact output line into `C14BASE` and the matching `#print axioms` line into `C14LEAN`, then run the full script |
| Header linter under `--wfail` rejects a new module (docstring placement, broad imports) | M | L | Copyright header, imports, then module docstring, exactly as sibling modules; import Mathlib modules individually (`Mathlib.Order.Zorn`, `Mathlib.Data.Countable.Defs`, `Mathlib.Data.Nat.Pairing`, `Mathlib.Data.Finset.Max`) — the probe's import list is the starting set |
| Concurrent siblings (653, 655) on the same tree | L | M | Their declared scopes are under `specs/653_*/`, `specs/655_*/` only; re-read before editing, stage only this task's files by explicit list, never a directory add, never `git-snapshot.sh` in default mode |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3 | 1, 2 |
| 3 | 4 | 3 |
| 4 | 5 | 4 |
| 5 | 6 | 5 |
| 6 | 7 | 6 |

Phases within the same wave can execute in parallel.

Throughout: `fc := FrameClass.Dense` where a lemma needs DN; everything else at a variable
`fc`. Write `MPoint fc := {S : Set MinusFormula // MinusSetMaximalConsistent fc S}`. Every build
is detached through `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build
--wfail <Module>` per `rules/lean4.md`. Commit every green sub-step with an explicit file list.
Docstrings cite Burgess 1984 §2.5 by section, `def:BL-semantics` by label; no line numbers, no
task numbers (the write-time gate blocks them outside `specs/`).

### Phase 1: MinusMCS.lean — the L⁻ maximal-consistent-set layer [NOT STARTED]

**Goal**: A `MinusFormula`-typed mirror of `Metalogic/Core/MaximalConsistent.lean` and the
closure properties of `Core/MCSProperties.lean`, sufficient for every MCS argument in Phases 3–6.

**Tasks**:
- [ ] Create `FormalSystem/Metalogic/Conservativity/MinusMCS.lean` with copyright header, imports
  (`FormalSystem.Metalogic.Conservativity.MinusDeduction`, `Mathlib.Order.Zorn`), then module
  docstring naming `Core/MaximalConsistent.lean` and `Core/MCSProperties.lean` as copy sources
- [ ] Transcribe the probe's §1 verbatim: `MinusConsistent`, `MinusSetConsistent`,
  `MinusSetMaximalConsistent`, polymorphic `exists_maximal_of_chainClosed`,
  `finite_list_in_chain_member`, `minus_consistent_chain_union`, `minus_set_lindenbaum`,
  `neg_consistent_of_not_minus_derivable`
- [ ] Add `MPoint fc` (the subtype) and `MinusSetMaximalConsistent.finite_subset_consistent`
- [ ] Closure properties, each mirroring its `Core` namesake on top of `minusDeductionTheorem`:
  `closed_under_derivation` (finite `L ⊆ S`, `L ⊢⁻ φ` ⟹ `φ ∈ S`), `theorem_in_mcs`,
  `mp_of_theorem`, `implication_property`, `negation_complete` (`mem_or_neg_mem`),
  `neg_excludes`, `bot_not_mem`, `not_mem_iff_neg_mem`, `imp_mem_iff : (φ.imp ψ) ∈ S ↔ (φ ∈ S →
  ψ ∈ S)`, `and_mem_iff`, `neg_neg_mem_iff`
- [ ] Duality inside an MCS: `someFuture_mem_iff : ψ.someFuture ∈ S ↔ ψ.neg.allFuture ∉ S`,
  `somePast_mem_iff`, `diamond_mem_iff` (each is `not_mem_iff_neg_mem` unfolded)
- [ ] `lean_verify` a sample (`minus_set_lindenbaum`, `imp_mem_iff`): standard axioms only

**Timing**: 2 hours

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: ~450 lines (report §Recommendations 1). Confirm by `wc -l` at phase close;
an overrun past ~600 means a closure lemma was proved from scratch instead of via the deduction
theorem — re-check against `Core/MCSProperties.lean` before continuing.

**Files to modify**:
- `FormalSystem/Metalogic/Conservativity/MinusMCS.lean` - new module

**Verification**:
- Scoped guarded build of `FormalSystem.Metalogic.Conservativity.MinusMCS` with `--wfail` green
- `grep -c sorry` on the file returns 0
- Every name listed above is declared; `lean_verify` on the sampled names returns
  `[propext, Classical.choice, Quot.sound]` or a subset

---

### Phase 2: MinusTemporalDerived.lean — derived TM⁻ theorems and TR mirrors [NOT STARTED]

**Goal**: Every derivation-level lemma the canonical relations and chronicle need, future-side
proved once, past-side obtained by time reflection.

**Tasks**:
- [ ] Create `FormalSystem/Metalogic/Conservativity/MinusTemporalDerived.lean` (imports
  `MinusDeduction`; module docstring names `Theorems/GeneralizedNecessitation.lean` as the copy
  source for the generalized K rule)
- [ ] `minusGeneralizedTemporalK : Γ ⊢⁻[fc] φ → Context.map allFuture Γ ⊢⁻[fc] φ.allFuture`
  (induction on `Γ` through `minusDeductionTheorem`, `temporal_necessitation`, `temp_k` — the
  L⁻ transposition of `generalizedTemporalK`)
- [ ] `minusGeneralizedModalK : Γ ⊢⁻[fc] φ → Context.map box Γ ⊢⁻[fc] φ.box` (same induction
  with `necessitation`, `modal_k`)
- [ ] Future-side theorems, each `⊢⁻[fc]`: `gAnd : (Gφ ∧ Gψ) → G(φ ∧ ψ)`; `fMono : ⊢ φ → ψ ⟹
  ⊢ Fφ → Fψ`; `gAndF : (Gχ ∧ Fψ) → F(χ ∧ ψ)`; `notFBot : ⊢ (F⊥).neg`; `notF_of_not : ⊢ χ.neg
  ⟹ ⊢ (Fχ).neg`; `g4` (= `temp_4`), `tcFuture` (= `temp_connect`), `serialF` (= `temp_serial`)
  as named wrappers
- [ ] The one DN use: `fF_of_f : ⊢⁻[.Dense] Fψ → FFψ` (contrapose `Axiom.dn`, gate by `le_refl`)
- [ ] Modal: `boxImpBoxG` (= `modal_future` wrapper); `boxImpBoxH : ⊢⁻[fc] □φ → □Hφ` by
  `time_reflection` of `modal_future` at `φ.reflectTime`, transported by
  `reflectTime_involution` (the `boxGlobalPast` idiom)
- [ ] Past mirrors by TR, never by hand: `hAnd`, `minusGeneralizedPastK`, `pMono`, `hAndP`,
  `notPBot`, `notP_of_not`, `h4`, `tcPast : ⊢ φ → HFφ`, `serialP : ⊢ P⊤`, `tlPast` (the
  reflection of `temp_linearity`); prove any needed `@[simp] reflectTime_*` helper missing from
  `MinusLanguage/Formula.lean` locally rather than editing that module
- [ ] `lean_verify` on `fF_of_f`, `tlPast`, `minusGeneralizedTemporalK`

**Timing**: 2 hours

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: ~500 lines (report §Recommendations 2). Confirm at phase close; if the
past-side block is not roughly one-third the size of the future-side block, a mirror was
re-derived by hand — replace it with the TR idiom.

**Files to modify**:
- `FormalSystem/Metalogic/Conservativity/MinusTemporalDerived.lean` - new module

**Verification**:
- Scoped guarded build with `--wfail` green; `grep -c sorry` returns 0
- Every past lemma's proof term contains `time_reflection` (grep), none re-derives a future proof
- `lean_verify` on the sampled names: standard axioms only (`[propext]` or fewer is expected for
  pure derivations, as `boxGlobalFuture`'s ledger row shows)

---

### Phase 3: MinusCanonicalFrame.lean — canonical relations, existence, density, linearity [NOT STARTED]

**Goal**: `canR`/`canBox` on `MPoint`s with every relational lemma the chronicle construction and
truth lemma consume; density stated at `.Dense`, everything else at variable `fc`.

**Tasks**:
- [ ] Create `FormalSystem/Metalogic/Conservativity/MinusCanonicalFrame.lean` (imports `MinusMCS`,
  `MinusTemporalDerived`; docstring names `BXCanonical/Frame.lean` and `TruthLemma.lean` as copy
  sources: `BxLe`↔`canR`, `BxModalEquiv`↔`canBox`, `g_content_set_consistent`,
  `bx_forward_witness`, `bx_modal_witness`, `F_from_witness`)
- [ ] `canR`, `canBox` as in the probe (on `Set MinusFormula`, used at `MPoint` carriers);
  `GContent Γ := {χ | Gχ ∈ Γ}`, `HContent`, `BoxContent`
- [ ] `canR_trans` (T4); `canR_iff_past : canR Γ Δ ↔ ∀ χ, Hχ ∈ Δ → χ ∈ Γ` (⇒ by TC through
  `neg_excludes`; ⇐ by `tcPast`); `F_of_canR : canR Γ Δ → ψ ∈ Δ → Fψ ∈ Γ` and `P_of_canR`
- [ ] Existence: `gContent_insert_consistent` (Lindenbaum seed consistency via
  `minusGeneralizedTemporalK` + `gAnd`), `exists_canR_of_F : Fψ ∈ Γ → ∃ Δ : MPoint, canR Γ Δ ∧
  ψ ∈ Δ`; past mirror `exists_canR_of_P` via `canR_iff_past`; `exists_canR_serial` (TS),
  `exists_canR_serial_past` (`serialP`)
- [ ] **Density** (`.Dense` only): `exists_canR_between : canR Γ Δ → ∃ Θ, canR Γ Θ ∧ canR Θ Δ`
  — Lindenbaum on `GContent Γ ∪ HContent Δ`; consistency by the report §3.3 derivation chain
  (`gAnd`, `hAnd`, `F_of_canR`, `fF_of_f`, `gAndF` twice, `notF_of_not`, `notFBot`); `canR Θ Δ`
  from `canR_iff_past`
- [ ] **Weak linearity**, both sides: `canR_weakLinear_right : canR Γ Δ₁ → canR Γ Δ₂ → Δ₁ = Δ₂ ∨
  canR Δ₁ Δ₂ ∨ canR Δ₂ Δ₁` (TL; each disjunct refuted via `notF_of_not`; the `Δ₁ = Δ₂` branch by
  `Subtype.ext` + `mem_or_neg_mem`), and `canR_weakLinear_left` (mirror via `tlPast` and
  `canR_iff_past`)
- [ ] Box: `canBox_refl` (T), `canBox_trans` (4 via `boxImpBoxBox`), `canBox_symm` (B via
  `minusModalB`), `exists_canBox_of_dia : ◇ψ ∈ Γ → ∃ Δ, canBox Γ Δ ∧ ψ ∈ Δ`
  (`minusGeneralizedModalK`), `canBox_of_canR : canBox Γ Δ → canR Δ Δ' → canBox Γ Δ'` (MF) and
  `canBox_of_canR_rev` (`boxImpBoxH`)
- [ ] `lean_verify` on `exists_canR_between`, `canR_weakLinear_right`, `exists_canBox_of_dia`

**Timing**: 2 hours

**Depends on**: 1, 2

**Verification Tier**: local

**Scope Hypothesis**: ~600 lines (report §Recommendations 3). Confirm at phase close. Confirm
also that `grep -n "FrameClass.Dense" MinusCanonicalFrame.lean` hits only `exists_canR_between`
(and its helper) — any other hit means a generic lemma was over-specialised.

**Files to modify**:
- `FormalSystem/Metalogic/Conservativity/MinusCanonicalFrame.lean` - new module

**Verification**:
- Scoped guarded build with `--wfail` green; `grep -c sorry` returns 0
- `exists_canR_between` is stated at `FrameClass.Dense`; every other declaration is at a variable
  `fc`
- `lean_verify` on the sampled names: standard axioms only

---

### Phase 4: MinusChronicle.lean part A — stages, placement, interpolation [NOT STARTED]

**Goal**: The finite-stage representation and the three single-stage lemmas (`insert_future`,
`insert_past`, `fill`) that the ω-construction iterates; all at `.Dense`.

**Tasks**:
- [ ] Create `FormalSystem/Metalogic/Conservativity/MinusChronicle.lean` (imports
  `MinusCanonicalFrame`, `Mathlib.Data.Finset.Max`, `Mathlib.Data.Countable.Defs`,
  `Mathlib.Data.Nat.Pairing`; docstring: Burgess 1984 §2.5 step-by-step construction; state
  explicitly that nothing here generalises beyond `.Dense`)
- [ ] `structure Chronicle` exactly as the probe §2 (`c : ℚ → Set MinusFormula`, `mcs`, `coh`,
  `witF`, `witP`) at `fc := .Dense`; **no** injectivity field (reflexive MCSs may label many
  rationals)
- [ ] `coherent (s : ℚ → Option (MPoint .Dense)) : Prop := ∀ q q' Γ Δ, q < q' → s q = some Γ →
  s q' = some Δ → canR Γ Δ`; `structure Stage` with `s`, `supp : Finset ℚ`, `supp_spec : ∀ q,
  q ∈ supp ↔ (s q).isSome`, `coh : coherent s`; extension order `Stage.le s s' := ∀ q Γ, s.s q =
  some Γ → s'.s q = some Γ` with `le_refl`, `le_trans`
- [ ] `Stage.update (s) (r) (Δ)` (the `s[r ↦ Δ]` writer) with `supp` = `insert r s.supp`, and
  its `le` lemma
- [ ] `insert_future : s.s q = some Γ → canR Γ Δ → (∃ q' > q, s.s q' = some Δ) ∨ (∃ r > q,
  s.s r = none ∧ coherent (s.update r Δ).s)` — proof per report §3.4: `U := s.supp.filter (fun q'
  => q < q' ∧ ¬ canR (s q') Δ)`; `U = ∅` ⟹ `r > s.supp.max'` by `NoMaxOrder`; `U ≠ ∅` ⟹ `q₁ :=
  U.min'`, `canR_weakLinear_right` at `Γ`, then `Δ = s q₁` (first disjunct) or `canR Δ (s q₁)`
  and `r` by `exists_between` strictly between `(s.supp.filter (· < q₁)).max'` and `q₁`
- [ ] `insert_past` — the mirror (`canR_weakLinear_left`, `canR_iff_past`, `NoMinOrder`,
  `Finset.min'`)
- [ ] `fill : r ∉ s.supp → s.supp.Nonempty → ∃ Θ, coherent (s.update r Θ).s` by cases on
  `(s.supp.filter (· < r)).Nonempty` × `(s.supp.filter (r < ·)).Nonempty`: both →
  `exists_canR_between`; below only → `exists_canR_serial`; above only →
  `exists_canR_serial_past`; neither is excluded by `s.supp.Nonempty`

**Timing**: 2 hours

**Depends on**: 3

**Verification Tier**: local

**Scope Hypothesis**: ~450 lines for part A (half of report §Recommendations 4's ~900). Confirm at
phase close; if `insert_future` alone exceeds ~150 lines, factor the `U = ∅` and `U ≠ ∅` branches
into named helper lemmas before continuing to part B.

**Files to modify**:
- `FormalSystem/Metalogic/Conservativity/MinusChronicle.lean` - new module (first half)

**Verification**:
- Scoped guarded build with `--wfail` green; `grep -c sorry` returns 0
- `insert_future`, `insert_past`, `fill` are declared with the disjunctive/existential shapes
  above (statement fidelity — see the challenge note under Testing & Validation)

---

### Phase 5: MinusChronicle.lean part B — enumeration, iteration, limit, box-class closure [NOT STARTED]

**Goal**: `exists_chronicle_through : ∀ Γ : MPoint .Dense, ∃ c : Chronicle, c.c 0 = Γ`, plus
the `canBox`-closure of a chronicle.

**Tasks**:
- [ ] `Req := ℚ ⊕ (ℚ × MinusFormula × Bool)`; instances `Countable Req`, `Nonempty Req`;
  transcribe the probe's `exists_enum_infinitely_often` and fix an enumeration `e : ℕ → Req`
- [ ] `step : Stage → Req → Stage`, dispatching: `.inl r` → if `r ∉ supp` apply `fill` (choice),
  else no-op; `.inr (q, ψ, true)` → if `s q = some Γ` and `ψ.someFuture ∈ Γ`, take
  `exists_canR_of_F` then `insert_future` (no-op on its first disjunct, `update` on its second);
  `.inr (q, ψ, false)` → the `P` mirror; each branch returns a `Stage` with `s ≤ step s r`
- [ ] `stages : ℕ → Stage` by iteration from the seed stage `{0 ↦ Γ}` (`supp = {0}`,
  `coherent` vacuously); `stages_mono : m ≤ n → stages m ≤ stages n`
- [ ] Every rational is eventually labelled: `exists_stage_labelled : ∀ q, ∃ n Γ, (stages n).s q
  = some Γ` (the `.inl q` requirement recurs; `fill` fires the first time it is unlabelled)
- [ ] The limit `limitChain : ℚ → Set MinusFormula` via `Classical.choose` on
  `exists_stage_labelled`, with `limit_eq_of_labelled : (stages n).s q = some Γ → limitChain q =
  Γ` (monotonicity)
- [ ] `limit_mcs`, `limit_coh` (evaluate both points at `max n n'`), `limit_witF` (`Fψ ∈
  limitChain q` ⟹ labelled at some `n₀` ⟹ requirement `(q, ψ, true)` recurs at `n ≥ n₀` ⟹ the
  step's witness is at `q' > q` in `stages (n+1)` ⟹ `ψ ∈ limitChain q'`), `limit_witP`
- [ ] Assemble `exists_chronicle_through`
- [ ] `chronicle_canBox_closed : canBox Γ (c.c q₀) → ∀ q, canBox Γ (c.c q)` (by `canBox_of_canR`
  for `q₀ < q`, `canBox_of_canR_rev` for `q < q₀`, via `c.coh`)
- [ ] `lean_verify` on `exists_chronicle_through`

**Timing**: 2 hours

**Depends on**: 4

**Verification Tier**: local

**Scope Hypothesis**: ~450 lines for part B, ~900 for the whole module. Confirm at phase close;
the module must stay under the 1500-line `longFile` limit — if it approaches it, move part A's
stage algebra to its own module rather than adding a `set_option` baseline.

**Files to modify**:
- `FormalSystem/Metalogic/Conservativity/MinusChronicle.lean` - second half

**Verification**:
- Scoped guarded build with `--wfail` green; `grep -c sorry` returns 0
- `exists_chronicle_through` is stated at `FrameClass.Dense` and only there
- `lean_verify exists_chronicle_through`: standard axioms only

---

### Phase 6: MinusChainCompleteness.lean — bundle, truth lemma, the theorem and corollaries [NOT STARTED]

**Goal**: The five Goal theorems, sorry-free, with the exact signatures pinned under `## Lean
Challenge Statements`.

**Tasks**:
- [ ] Create `FormalSystem/Metalogic/Conservativity/MinusChainCompleteness.lean` (imports
  `MinusChronicle`, `FragmentAxiomatization`, `TMCompletenessReduction`; neither of those two may
  import the new modules — no cycle)
- [ ] Fix `Γ₀ : MPoint .Dense`; `FamIdx Γ₀ := {c : Chronicle // ∀ q, canBox Γ₀ (c.c q)}`;
  `instance : Nonempty (FamIdx Γ₀)` from `exists_chronicle_through Γ₀` + `canBox_refl` +
  `chronicle_canBox_closed`; valuation `val Γ₀ : FamIdx Γ₀ × ↑(TemporalOrder.of ℚ) → Atom →
  Prop := fun p a => MinusFormula.atom a ∈ p.1.1.c p.2`
- [ ] `truth_lemma : ∀ ψ (c : FamIdx Γ₀) (q : ℚ), chainSat (val Γ₀) (c, q) ψ ↔ ψ ∈ c.1.c q` by
  induction on `ψ` generalising `c q`: `atom` (rfl), `bot` (`bot_not_mem`), `imp` (`imp_mem_iff`),
  `allFuture` (⇒ `coh`; ⇐ `someFuture_mem_iff` + `witF`), `allPast` (⇒ `coh` + `canR_iff_past`;
  ⇐ `witP`), `box` (⇒ `canBox_symm`/`canBox_trans` through `Γ₀`; ⇐ `diamond_mem_iff`,
  `exists_canBox_of_dia`, `exists_chronicle_through Δ`, membership in `FamIdx Γ₀` by
  `canBox_trans` + `chronicle_canBox_closed`, IH at `(c', 0)`)
- [ ] `refutation_engine : ¬ Derivable .Dense [] φ → ∃ (FamIdx : Type) (_ : Nonempty FamIdx) v q,
  ¬ chainSat v q φ` (`neg_consistent_of_not_minus_derivable`, `minus_set_lindenbaum`, the
  truth lemma at `(c₀, 0)` with `neg_excludes`)
- [ ] `chainComplete_dense` by transcribing the probe's `chainComplete_dense_of_engine` and
  `not_chainValidIn_dense_of_rat_refutation` (the `.Dense` side condition is `inferInstance`)
- [ ] `minusExt_iff_tmFrag_dense := minusExt_empty_iff_tmFrag_dense_of_chainComplete
  chainComplete_dense`
- [ ] `minusValidIn_chainValidIn` (contrapositive of `not_minusValidIn_of_not_chainSat`);
  `tmMinusComplete_dense` (`minusExt_empty_iff.mp ∘ chainComplete_dense φ ∘
  minusValidIn_chainValidIn`); `forward_dense := tmMinusCompleteDense_iff_forwardDense.mp
  tmMinusComplete_dense`
- [ ] `lean_verify` on all five Goal names: standard axioms only, no `sorryAx`

**Timing**: 2 hours

**Depends on**: 5

**Verification Tier**: local

**Scope Hypothesis**: ~300 lines (report §Recommendations 5). Confirm at phase close.

**Files to modify**:
- `FormalSystem/Metalogic/Conservativity/MinusChainCompleteness.lean` - new module

**Verification**:
- Scoped guarded build with `--wfail` green; `grep -c sorry` returns 0
- `lean_verify` on `FormalSystem.Metalogic.Conservativity.chainComplete_dense`,
  `.minusExt_iff_tmFrag_dense`, `.minusValidIn_chainValidIn`, `.tmMinusComplete_dense`,
  `.forward_dense`: each `[propext, Classical.choice, Quot.sound]` or a subset
- The five signatures match `## Lean Challenge Statements` verbatim

---

### Phase 7: Wiring, ledgers, status prose, and gates [NOT STARTED]

**Goal**: The library knows about the new modules, every ledger and docstring tells the truth
about `.Dense`, and all repository gates are green.

**Tasks**:
- [ ] Add the five new modules to `FormalSystem/Metalogic/Conservativity.lean`'s import block, and
  a bullet for each in its module docstring's module list (with the `.Dense` row now described as
  machine-checked and the `.RTime` obstruction paragraph left untouched)
- [ ] Regenerate the root: `lake exe mk_all --lib FormalSystem`; never hand-edit
  `FormalSystem.lean`
- [ ] `bash scripts/check-module-invariants.sh --emit-inventory` to refresh
  `FormalSystem/Metalogic/Conservativity/README.md`'s generated block; then hand-fill the five new
  rows' descriptions, revise the README's forward-row status line ("**open** at `.Dense` and
  `.RTime`" → machine-checked at `.Dense`, open at `.RTime`), the `FragmentAxiomatization.lean`
  row description, and the `ChainComplete` bullet
- [ ] `FragmentAxiomatization.lean` docstrings: module docstring ("nothing here concludes
  `ChainComplete fc Ax`" → concluded at `.Dense` by `chainComplete_dense` in
  `MinusChainCompleteness.lean`, hypothesis at the other three), the `.Dense` verdict bullet
  (completeness: **machine-checked**), the `ChainComplete` docstring ("No declaration in this
  tree concludes it" → exactly one does, at `.Dense`), and
  `minusExt_empty_iff_tmFrag_dense_of_chainComplete`'s docstring (both propositions now asserted,
  pointing at the unconditional `minusExt_iff_tmFrag_dense`)
- [ ] `TMCompletenessReduction.lean`: the `.Dense` row of the four-row status table (**closed**,
  `tmMinusComplete_dense`/`forward_dense`), retitle and rewrite the "`.Dense` — expected complete,
  unproved" subsection to record the landed route and drop the four-item "What a positive answer
  still needs" list (keep the circularity paragraph about `BXCanonical/Chronicle/`), and the
  "Two rows are closed, two are not" sentence; the `.RTime` subsection stays as is
- [ ] `ChainBundleTruth.lean` module docstring: "It is **not** a completeness proof … the converse
  is not proved" → the converse is now proved at `.Dense` (`minusValidIn_chainValidIn` +
  `chainComplete_dense`), still open at `.RTime`; `not_minusValidIn_of_not_chainSat`'s docstring
  likewise
- [ ] `Conservativity.lean` module docstring (`ChainComplete … which no declaration concludes`,
  the "hypothesis `ChainComplete`, never asserted" bullet), `MinusExt.lean`'s and
  `Fragment.lean`'s "never asserted" phrases, and `FormalSystem/Metalogic.lean`'s "explicit,
  never-asserted hypothesis `ChainComplete`" sentence — each revised to "asserted at `.Dense`
  only"
- [ ] `docs/theorem-index.md`: in the Conservativity section add rows for the five Goal theorems
  (`pcq pinned:C14`, class `Dense`; `minusValidIn_chainValidIn` class `—`); revise the existing
  `minusExt_iff_tmFrag_of_chainComplete` row's "(hypothesis never discharged)" to "(discharged at
  `.Dense` by `chainComplete_dense`)"; revise the "Forward proof-theoretic conservativity … open
  at `Dense` and `RTime`" bullet in the refutations-not-gaps section
- [ ] `scripts/check-module-invariants.sh`: run `#print axioms` on each of the five names, paste
  the exact output lines into the `C14BASE` heredoc and the matching `#print axioms` lines into
  `C14LEAN`, in the same relative position as the existing
  `minusExt_iff_tmFrag_of_chainComplete` entries
- [ ] Full guarded `lake build --wfail`; `bash scripts/check-module-invariants.sh` (all checks,
  including C14 and the inventory `--check`); `lake exe mk_all --lib FormalSystem --check`;
  `bash scripts/check-metalogic-cycles.sh`
- [ ] Final grep sweep across `FormalSystem/Metalogic/Conservativity/`,
  `FormalSystem/Metalogic.lean`, `docs/theorem-index.md` for `never asserted`, `not
  machine-checked`, `open at`, `ChainComplete`, `TMMinusComplete` — every remaining hit must be
  about `.Base`/`.ZTime`/`.RTime` or the general conditional theorem, not `.Dense`

**Timing**: 1.5 hours

**Depends on**: 6

**Verification Tier**: full

**Scope Hypothesis**: the docstring/ledger edit sites enumerated above are the ones the research
report §5 and a `grep -rn ChainComplete` of the tree surfaced (eight files). Confirm by the final
grep sweep; any additional hit found at implementation time is edited in this phase, not
deferred.

**Files to modify**:
- `FormalSystem/Metalogic/Conservativity.lean` - aggregator imports + docstring
- `FormalSystem.lean` - regenerated by `mk_all` only
- `FormalSystem/Metalogic/Conservativity/README.md` - inventory block + status prose
- `FormalSystem/Metalogic/Conservativity/FragmentAxiomatization.lean` - docstrings only
- `FormalSystem/Metalogic/Conservativity/TMCompletenessReduction.lean` - docstrings only
- `FormalSystem/Metalogic/Conservativity/ChainBundleTruth.lean` - docstrings only
- `FormalSystem/Metalogic/Conservativity/MinusExt.lean` - one docstring phrase
- `FormalSystem/Metalogic/Conservativity/Fragment.lean` - one docstring phrase
- `FormalSystem/Metalogic.lean` - one docstring sentence
- `docs/theorem-index.md` - five new rows, two revised passages
- `scripts/check-module-invariants.sh` - C14 heredoc pair, five lines each

**Verification**:
- `lake build --wfail` (full, guarded) green
- `bash scripts/check-module-invariants.sh` exits 0 with C14 passing on the new baseline
- `lake exe mk_all --lib FormalSystem --check` exits 0; `bash scripts/check-metalogic-cycles.sh`
  exits 0
- `lean_verify` on `chainComplete_dense` and `minusExt_iff_tmFrag_dense` returns standard axioms
  only, no `sorryAx` (the task's acceptance criterion, re-run after wiring)
- The final grep sweep reports no `.Dense`-scoped "never asserted"/"open" claim

## Lean Challenge Statements

The identifier set below equals the `**Goals**:` list. These five signatures were type-checked
standalone against the prebuilt oleans at planning time (exit 0, `sorry` warnings only).

```lean
import FormalSystem.Metalogic.Conservativity.FragmentAxiomatization
import FormalSystem.Metalogic.Conservativity.TMCompletenessReduction

namespace FormalSystem.Metalogic.Conservativity

open FormalSystem.ProofSystem
open FormalSystem.MinusLanguage

theorem chainComplete_dense : ChainComplete FrameClass.Dense ∅ := sorry

theorem minusExt_iff_tmFrag_dense (φ : MinusFormula) :
    MinusExt FrameClass.Dense ∅ φ ↔ TMFrag FrameClass.Dense φ := sorry

theorem minusValidIn_chainValidIn {fc : FrameClass} {φ : MinusFormula}
    (h : MinusValidIn fc φ) : ChainValidIn fc φ := sorry

theorem tmMinusComplete_dense : TMMinusComplete FrameClass.Dense := sorry

theorem forward_dense : Forward FrameClass.Dense := sorry

end FormalSystem.Metalogic.Conservativity
```

## Testing & Validation

- [ ] Each new module builds scoped with `--wfail` at its phase close (Phases 1–6), with
  `grep -c sorry` = 0 and no vacuous placeholders (`rules/lean4.md`)
- [ ] `lean_verify` on the five Goal names: `[propext, Classical.choice, Quot.sound]` or a subset,
  never `sorryAx`
- [ ] `exists_canR_between`, `fF_of_f`, `Chronicle`, `exists_chronicle_through`, and everything in
  `MinusChainCompleteness.lean` are at `FrameClass.Dense`; nothing concludes `ChainComplete` at
  any other class (`grep -n "ChainComplete FrameClass\.\(Base\|ZTime\|RTime\)"` finds only the
  pre-existing conditional corollaries)
- [ ] Full guarded `lake build --wfail` green; `check-module-invariants.sh` all pass;
  `mk_all --check` 0; `check-metalogic-cycles.sh` 0
- [ ] Statement fidelity: the implemented signatures of the five Goal theorems match the challenge
  block verbatim (`lean-challenge-snapshot.sh --check 651 .` is advisory; a drift finding is
  investigated under `rules/plan-compliance.md`, never silently reconciled)
- [ ] No task-number references in any file outside `specs/` (the write-time gate blocks them)
- [ ] Concurrency discipline: every commit stages an explicit file list; `git log` checked before
  reporting any foreign modification

## Artifacts & Outputs

- `FormalSystem/Metalogic/Conservativity/MinusMCS.lean`
- `FormalSystem/Metalogic/Conservativity/MinusTemporalDerived.lean`
- `FormalSystem/Metalogic/Conservativity/MinusCanonicalFrame.lean`
- `FormalSystem/Metalogic/Conservativity/MinusChronicle.lean`
- `FormalSystem/Metalogic/Conservativity/MinusChainCompleteness.lean`
- Edited: `Conservativity.lean`, `FormalSystem.lean` (generated), `Conservativity/README.md`,
  `FragmentAxiomatization.lean`, `TMCompletenessReduction.lean`, `ChainBundleTruth.lean`,
  `MinusExt.lean`, `Fragment.lean`, `FormalSystem/Metalogic.lean`, `docs/theorem-index.md`,
  `scripts/check-module-invariants.sh`
- `specs/651_chain_complete_dense_tm_minus/summaries/01_chain-complete-dense-summary.md`

## Rollback/Contingency

- Each phase is a separate green commit; a failed phase is abandoned by reverting only its own
  uncommitted hunks, never the tree. The five new modules are additive until Phase 7 — reverting
  them removes nothing existing.
- If Phase 4 or 5 hits a genuine obstruction (a lemma whose paper argument does not go through —
  which axiom, what the canonical order fails to satisfy), the task's own acceptance criteria
  admit "a precisely located obstruction reported with a compiled probe" as a complete outcome:
  mark the phase `[BLOCKED]`, write the probe under `specs/651_*/probes/`, and do **not** state
  `chainComplete_dense` with `sorry`. Phases 1–3 remain landed as reusable infrastructure.
- If a whole-tree rollback is ever genuinely required, follow `context/contracts/recovery.md`'s
  rollback rung (`git-snapshot.sh 651`, with `--allow-out-of-scope` only for the deliberate
  whole-tree case); never as a routine checkpoint — a defensive checkpoint before Phase 7's
  multi-file edits uses `--no-revert`.
