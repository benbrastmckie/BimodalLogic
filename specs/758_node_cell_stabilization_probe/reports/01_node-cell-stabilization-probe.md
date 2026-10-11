# Research Report: Task #758

**Task**: 758 - Node fixture probe: cell stabilization in the deadline index (preCell_stable, preCell_zero_ne, postCell_stable)
**Started**: 2026-10-11T00:30:30Z
**Completed**: 2026-10-11T00:47:08Z
**Effort**: ~1.5 hours (one research dispatch, including a compiled prototype)
**Dependencies**: None
**Sources/Inputs**: - Codebase: `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Limits/NoFiniteWidth.lean` (fixture), `FormalSystem/Metalogic/Decidability/RaySummary/AnchorLayer.lean` (`cellAt`, `tpOf`), `FormalSystem/PlusLanguage/PlusTruth.lean` (`box_global`, `stab_iff`), `FormalSystem/PlusLanguage/Subformulas.lean` (`plusSubformulaClosure`), `FormalSystem/Metalogic/Decidability/RaySummary/README.md`, `scripts/check-evidence-probes.sh`, `specs/evidence/seam-gluing-ray-product/deadline-ladder-branching.lean` and `backward-dual-asymmetric-fixture.lean` (basis probes)
- Design of record: `specs/757_lplus_decidability_successor_task_set/followup-scope-spec.md` Section A and H1
- lean-lsp MCP: `lean_run_code` (prototype compilation, closure enumeration); `lake env lean` on the saved prototype
- No literature source is referenced by the task; the Literature Extraction Protocol does not apply
**Artifacts**: - `specs/758_node_cell_stabilization_probe/reports/01_node-cell-stabilization-probe.md` (this report)
- `specs/758_node_cell_stabilization_probe/prototype/node-cell-stabilization-proto.lean` (compiled research prototype of all three statements; not the probe)
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **Verdict: stabilization at bound 1 holds on `Node` for the fixture's own witness `Φ`.** All three dispatch statements — `preCell_stable`, `preCell_zero_ne`, `postCell_stable` — are proved in a research prototype that compiles under `lake env lean` (the probe gate's own command) in 2.7 s with axioms `[propext, Classical.choice, Quot.sound]` and no `sorryAx`. The chosen formula is `Φ` itself; the fallback `D` was not needed.
- **The mechanism is exactly what the dispatch predicted (branch-time saturation), and it is sharper than the README's phrasing.** Every one of the 28 members of `cl Φ` has, on a canonical history `histOf k t` at time `s`, a truth value that is a Boolean combination of four relations between `s` and `t` (`s<t`, `s=t`, `t<s`, `s+1=t`) — and never of the thread index `k`. So a closure type is determined by the relative position `t - s`, and the four position classes `{<0}`, `{0}`, `{1}`, `{≥2}` give exactly four types. Cells: `pre 0 ↦ {tp 1}`, `pre (≥1) ↦ {tp 1, tp ≥2}`, `x ↦ {tp 0}`, `post ↦ {tp <0}`.
- **What separates `pre 0` from `pre 1` is the non-`⊡` letter `Xp`, not a `⊡`-letter.** `⊡Xp` is NOT in `cl Φ`; the closure's `⊡`-letter `⊡¬Xp` is FALSE at every pre state (`truth_stabNegXp`: the direct-to-`x` history shares the state), so all four `⊡`-letters of `cl Φ` take identical values at `pre 0` and `pre 1`. The cells differ as SETS because `pre 1` additionally realizes the type with `Xp ∉ T` (the history through `pre 1` that detours via `pre 0`). The probe header should state this precisely; the README's "`pre 0` reads `⊡Xp` where `pre (k+1)` reads `¬⊡Xp`" is true of a formula outside the closure and is not the cell-separating mechanism for `Φ`.
- **The thread index is invisible to cells at every `post k j`, including `j = 0`**: `postCell_subset` needs neither `1 ≤ j` nor `1 ≤ j'`. The dispatch's hypotheses are kept verbatim in `postCell_stable` (statement fidelity) and are vacuous on `Node`; the header should say so. The `x k` cells are likewise `k`-invariant (`xCell_stable`, a free bonus).
- **Cost figure**: the prototype is 284 lines (`wc -l`); the probe = prototype + a ~70-90 line header, so ~360-380 lines, inside the dispatch's 400-800 estimate and ONE implement dispatch. The implementer ports proofs, not discovers them.
- **Recommended approach**: a single-phase plan (plus the two one-line wiring edits) porting the prototype into `specs/evidence/seam-gluing-ray-product/node-cell-stabilization.lean`, with the header the dispatch mandates (witness `Φ`, fallback `D` not used, forward-only, no bound, no finiteness).

## Context & Scope

- Researched: whether `cellAt NoFiniteWidth.M NoFiniteWidth.Φ` on the library fixture `Node` stabilizes in the pre-index past 1 and is independent of the post thread/age indices — the one-region special case of the run layer's phase-2 first statement (RaySummary README, "(W): what landed and what did not", obligation (ii) item 1).
- Constraints honoured: the probe imports the library model and re-proves nothing (`F`, `M`, `histOf`, `hist_canon`, `canon_*`, `truth_p/Fp/Pp/Xp`, `Φ_true`, `box_global`, `cellAt`, `mem_tpOf_iff` are all cited, none re-proved); no sorry/axiom/vacuous definition; no finiteness added; no bound claimed; forward-only witness.
- Out of scope: the general ladder lemma (H3), any `Adm`, anything about `⊡(Pp)`, any claim that `⊡`-letters discriminate between devices.

## Findings

### Codebase Patterns

- **The fixture already carries the whole canonical-history toolkit.** `hist_canon : ∀ σ, ∃ k t, ∀ s, σ.state s = canon k t s` (every history is `histOf k t` up to `WorldHistory.ext_state`), `histOf_state`, `canon_of_lt/self/gt`, `canon_eq_x_iff`, the three transfer lemmas `lt_of_canon_eq_of_lt`, `gt_of_canon_eq_of_gt`, `eq_of_canon_eq_of_eq` (two canonical histories sharing a state at `s` are in the same position class at `s`), and the truth lemmas `truth_p/Fp/Pp/Xp` parametrised by `hσ : ∀ s, σ.state s = canon k t s`. The probe's `⊡` lemmas are ~12 lines each on top of these.
- **`cellAt M φ w z = {T | ∃ σ, σ.state z = w ∧ tpOf M φ σ z = T}`** (`AnchorLayer.lean` line 132), `mem_cellAt_iff` is `Iff.rfl`, `mem_tpOf_iff : ψ ∈ tpOf M φ σ z ↔ ψ ∈ plusSubformulaClosure φ ∧ PlusTruthAt M σ z ψ`. Equality of cells reduces to: for each history through the one state, a history through the other with the SAME `tpOf`; and `tpOf` equality reduces to truth transfer over `cl Φ`.
- **`cl Φ` is computable and enumerable**: `plusSubformulaClosure Φ = (PlusFormula.subformulas Φ).toFinset` with `card = 28` (raw list length 57 before dedup; `cl D` has 11). `Xp ∈ plusSubformulaClosure Φ` closes by `decide`. The membership `∀ ψ ∈ cl Φ, P ψ` decomposes under one `simp only` with `plusSubformulaClosure, List.mem_toFinset, PlusFormula.subformulas, List.mem_cons, List.mem_append, List.not_mem_nil, or_false, or_imp, forall_and, forall_eq` after unfolding `Φ, A', C', D, Fp, Pp, Xp, p, PlusFormula.and/or/neg/top` — no hand-written 28-way `rcases`.
- **Box letters are global**: `box_global M τ σ t s ψ : PlusTruthAt M τ t ψ.box ↔ PlusTruthAt M σ s ψ.box` (`FormalSystem.PlusLanguage.box_global`, NOT under `PlusTruth.`). From `Φ_true` this gives `A'`, `C'`, `D` at every point of `M`, so the six closure members built from them (`Φ`, `A'∧C'`, `A' → ¬C'`, `¬C'`, `¬D`, …) are constant.
- **`histOf k (t - Δ) = (histOf k t).timeShift Δ`** (`histOf_timeShift` in the prototype, by `WorldHistory.ext_state` + `split_ifs` + `omega`) — proved and available but NOT needed for the three statements, since `tpOf_eq_of` handles shift and thread change at once. Keep it out of the probe unless the planner wants it.
- **Precedent for imports**: `deadline-ladder-branching.lean` imports `RaySummary.RunLayer`; `w-soundness-shape-refuted.lean` imports `Limits.NoFiniteWidth` plus two RaySummary modules. A probe importing `Limits.NoFiniteWidth` and `RaySummary.AnchorLayer` is in-pattern; no probe imports another probe.
- **A `rw` hazard, confirmed and worked around** (also recorded in the issue log): the statements mention `cellAt M Φ (.pre k) z` where `Node.pre k` is elaborated at type `F.WorldState`, defeq to `Node` only at default transparency. `rw [mem_cellAt_iff]` and `rw [canon_eq_x_iff]` on such goals fail with "target expression is not type-correct under the implicit transparency level". Term-mode `(mem_cellAt_iff M Φ _ z T).mp hT` / `.mpr ⟨…⟩`, `canon_eq_x_iff.mp h'` after `have h' : canon k₀ t z = Node.x m := …`, and `(Set.ext_iff.mp h _).mpr` all work. Rewriting INSIDE a state equation (`rw [hσ s, histOf_state, canon_of_lt …]`) is fine, as the fixture itself does.
- **Mathlib pin quirk**: `push_neg` is deprecated at this pin — use `push Not`.

### External Resources

- No Mathlib search beyond the project tree was needed: every lemma used is in `FormalSystem` or core (`Set.Subset.antisymm`, `Set.ext_iff`, `Finset.ext`, `List.mem_*`, `forall_eq`, `or_imp`, `forall_and`, `omega`, `decide`). The rate-limited search tools were not called.
- Axiom record of the prototype: every headline theorem is `[propext, Classical.choice, Quot.sound]` — the same foot as `deadline-ladder-branching.lean`; `Classical.choice` enters through `hist_canon` → `FrameOver.mem_HF_iff_adjacent` → `worldHistoryOfStepPath`, as the eighth and ninth probes already note for the fixture.

### Truth table of `cl Φ` on a canonical history (the content of the verdict)

Writing `d := t - s` for the point `(histOf k t, s)` (so `d > 0` is a pre state, `d = 0` is `x k`, `d < 0` is `post k (−d−1)`):

| Closure letter | True iff | Lemma |
|---|---|---|
| `p` | `d = 0` | `truth_p` (library) |
| `Fp`, `⊡Fp` | `d > 0` | `truth_Fp` (library), `truth_stabFp` |
| `Pp`, `⊡Pp` | `d < 0` | `truth_Pp` (library), `truth_stabPp` |
| `⊡¬Pp` | `d ≥ 0` | `truth_stabNegPp` |
| `Xp` | `d = 1` | `truth_Xp` (library) |
| `⊡¬Xp` | `d ≤ 0` | `truth_stabNegXp` |
| `A'`, `C'`, `D` (and hence `Φ`, `A'∧C'`) | always | `truth_A'/C'/D` via `box_global` + `Φ_true` |
| `⊥` | never; `⊤` always | `PlusTruth.bot_false` |
| the remaining 13 implications | Boolean combinations of the above | `PlusTruth.imp_iff` |

Consequences: `tpOf M Φ (histOf k t) s` depends on `d` only, and only through the class of `d` in `{<0, 0, 1, ≥2}`. `SameClass s t s' t' := d = d' ∨ (2 ≤ d ∧ 2 ≤ d') ∨ (d < 0 ∧ d' < 0)` is the hypothesis of `tpOf_eq_of`; `k` does not appear. Histories through `pre m` at `z` are `histOf k₀ t` with `z < t` and `k₀ + (t−1−z).toNat = m` (`through_pre`), i.e. `d ∈ {1, …, m+1}`; through `post m j` exactly `histOf m (z−j−1)` (`through_post`, `d = −j−1`); through `x m` exactly `histOf m z` (`through_x`).

### Why bound 1 is `Φ`-specific (an observation, not a claim about the general lemma)

If a `⊡`-letter were nested under a temporal operator — e.g. `F(⊡Xp)` — its truth at `(histOf k t, s)` for `s < t−1` would be `k = 0` (only thread 0 passes through `pre 0`), so types WOULD depend on `k` and `pre m`'s cell would gain a third type at `m ≥ 2`; stabilization would still hold but at bound 2. This is consistent with the design of record's intention to state the general lemma (H3) with a bound syntactic in `φ`; the probe should not claim anything about that bound.

### Recommendations

1. **Formula**: `Φ`, recorded in the header as "witness `Φ`; fallback `D` not needed". `D` alone would also work (its closure is the 11-member subset) but gives a weaker record for no saving.
2. **Probe skeleton** (port from the prototype, in this order): `truth_A'/C'/D` → `truth_stabFp/Pp/NegPp/NegXp` (section with `hσ`) → `SameClass`, `truth_transfer`, `tpOf_eq_of` → `through_pre/post/x` → `preCell_subset`, `preCell_stable`, `preCell_zero_ne`, `postCell_subset`, `postCell_stable`, `xCell_stable` → `#print axioms` for the three dispatch theorems (and `xCell_stable` if kept). Statement text of the three dispatch theorems verbatim, including `(hj : 1 ≤ j) (hj' : 1 ≤ j')` on `postCell_stable` with `set_option linter.unusedVariables false in` and a docstring saying the hypotheses are vacuous on `Node`.
3. **Header must say** (guardrail (e) and the sharpening above): forward-only; nothing about `⊡(Pp)`; no claim that `⊡`-letters discriminate between devices — on this fixture they do not even discriminate `pre 0` from `pre 1`, the non-`⊡` letter `Xp` does, through set membership of a second type; cells are closure-indexed SETS over the time axis (28-member closure, four realized types), never one bit per depth; `Node` is infinite-width and the probe adds no finiteness; no bound of any kind is claimed — the probe exhibits cells; zero debt, no external lemma. Also record the `k`-invisibility at `post k 0`.
4. **Wiring**: one `WIRED` entry `"seam-gluing-ray-product/node-cell-stabilization"` appended after `deadline-ladder-branching` in `scripts/check-evidence-probes.sh` with a table row headed `POSITIVE VERDICT (requirement (W)'s run layer, phase 2, first statement, on the one-region fixture)`; one sentence in the README's Evidence section ("A tenth wired probe, …") placed after the ninth-probe paragraph, citing `NoFiniteWidth.M`, `cellAt`, the three theorem names and the `[propext, Classical.choice, Quot.sound]` foot, with durable anchors only. Optionally one clause in "(W): what landed and what did not", obligation (ii) item 1, pointing to the probe as the fixture-level confirmation — the planner may keep this to the one mandated sentence.
5. **Optional, not in the dispatch's STATEMENT**: distinctness lemmas `xCell_ne_preCell`, `postCell_ne_xCell`, etc., which would make "exactly four cells" a theorem (~60 lines with the same machinery: `p ∈ T` iff `x`-type, `Pp ∈ T` iff post-type). Recommend leaving out unless the planner wants the count made explicit; guardrail (c) permits counting cells but the three statements already carry the verdict.
6. **A sorry-free path exists and is exhibited**; no `[BLOCKED]` outcome is in play. The `.return-meta.json` `user_decision` field is not set: nothing here needs the user's judgment.

## Decisions

- D1: Chosen formula is `Φ` (not the fallback `D`). Basis: the full closure proved tractable (one `simp only`), and `Φ` is the witness the record names.
- D2: The closure is handled by mechanical enumeration (`simp only` over `PlusFormula.subformulas`), not by a formula-general induction — the latter is FALSE for arbitrary `ψ` (see the `F(⊡Xp)` observation), so enumeration is the honest route.
- D3: The research prototype is saved under the task directory (`prototype/`) as a port source for the implementer; it is NOT the probe and carries no evidence-header prose. The probe file is created in the implement phase at the dispatch's path.
- D4: `postCell_stable` keeps the dispatch's `1 ≤ j`, `1 ≤ j'` hypotheses verbatim (statement fidelity, `plan-compliance.md`), with the hypothesis-free `postCell_subset` beneath it making the vacuity visible.
- D5: No lemma is added to the library; everything lives in the probe, as the dispatch requires ("re-proves nothing" and adds nothing to `FormalSystem/`).

## Risks & Mitigations

- **Risk**: `rw` failures on `cellAt … (.pre k) …` goals (transparency hazard above) could cost an implementer an hour. **Mitigation**: the prototype uses term-mode `.mp/.mpr` throughout; the plan should name the hazard.
- **Risk**: the big `simp only` in `truth_transfer` is sensitive to the simp-set (needs `forall_eq`; `forall_eq_or_imp` is NOT what fires; unfold the truth lemmas' `p/Fp/Pp/Xp/top/neg` first so their LHS matches the raw closure members). **Mitigation**: port the call verbatim; the `lake env lean` run emits 2 "unused simp argument" linter warning lines and 0 errors (measured); harmless, trimmable.
- **Risk**: over-reading the verdict as evidence for the general ladder lemma's bound. **Mitigation**: header language per Recommendation 3; the report's `F(⊡Xp)` observation shows the bound is formula-dependent.
- **Risk**: cross-set collisions on `scripts/check-evidence-probes.sh` (task 734, `[PARTIAL]`) and the README (task 744, not started). **Mitigation**: both edits here are single appended lines/paragraphs at the end of the respective lists; the admission gate handles ordering; `mosaic-stab-saturated` is already in `WIRED`, so 734's script edit appears to have landed.

## Tactic Survey Results

| Goal | Tactic | Result | Premises/Config |
|------|--------|--------|-----------------|
| `Xp ∈ plusSubformulaClosure Φ` | decide | success | `decidableMemPlusSubformulaClosure` |
| `∀ ψ ∈ cl Φ, truth σ s ψ ↔ truth σ' s' ψ` (28 members) | simp only | success | unfolds + `List.mem_cons/append`, `or_imp`, `forall_and`, `forall_eq`, `PlusTruth.imp_iff/bot_false`, the 11 truth lemmas, 6 position iffs |
| same goal, simp set without `forall_eq` | simp only | fail (28 `∀ x, x = f → …` residues) | N/A |
| `k' + (z+1-1-z).toNat = k'` and similar `toNat` arithmetic | omega | success | after `congr 1` |
| `s < t ↔ s' < t'` from `SameClass` | constructor <;> intro <;> omega | success | disjunctive hypothesis case-split by omega |
| `(histOf k t).timeShift Δ = histOf k (t-Δ)` | ext_state; split_ifs <;> first \| rfl \| omega \| (congr 1; omega) | success | `WorldHistory.timeShift_state`, `histOf_state` |
| `¬ (t ≤ s)` → `s < t` | push_neg | deprecated warning | use `push Not` |
| `T ∈ cellAt M Φ (.pre k) z` rewriting | rw [mem_cellAt_iff] | fail (transparency) | use `(mem_cellAt_iff M Φ _ z T).mp` |

## Context Extension Recommendations

- **Topic**: `rw` on goals mentioning a `FrameOver.ofReflectiveRegular`-built frame's `WorldState` with a concrete carrier literal.
- **Gap**: no Lean4 context note records that `F.WorldState` vs the carrier type (`Node`) is defeq only at default transparency, so `rw` with iff-lemmas whose pattern fixes the `Eq`/membership type fails while term-mode application succeeds.
- **Recommendation**: add a short pattern note under `context/project/lean4/patterns/` (e.g. "frame-carrier transparency: prefer term-mode `.mp/.mpr` over `rw` for `cellAt`/`canon_eq_x_iff`-shaped lemmas on concrete fixtures").

## Appendix

- Search queries used: none against Mathlib (no rate-limited tool invoked); project-tree greps for `plusSubformulaClosure`, `box_global`, `stab_state_only`, `WorldHistory.ext_state`, `timeShift_state`, `mem_cellAt_iff`, probe import precedent.
- `lean_run_code` rounds: 6 (closure card/listing; two prototype iterations for the `⊡` lemmas; three for the transfer lemma and cell theorems). Final verification by `lake env lean` on the saved prototype: exit 0, 0 errors, 2.7 s.
- References: `RaySummary/README.md` "(W): what landed and what did not" (obligation (ii) item 1) and "Evidence" (ninth-probe paragraph); `followup-scope-spec.md` Section A (fixture probe rationale, guardrails (a)-(e)) and H1 (file scope, cost basis); `check-evidence-probes.sh` header (WIRED entry form, tracked-not-present rule).
