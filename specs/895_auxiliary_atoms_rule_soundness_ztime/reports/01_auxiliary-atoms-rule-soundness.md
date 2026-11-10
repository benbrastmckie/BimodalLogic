# Research Report: Task #895

**Task**: 895 - The Auxiliary-Atoms rule for L⁺ at ZTime, forward and mirror, formula level with soundness
**Started**: 2026-11-10T21:55:00Z
**Completed**: 2026-11-10T22:35:00Z
**Effort**: medium (one new module, ~600-750 lines, five phases; no blocker found)
**Dependencies**: Task 894 [COMPLETED], Task 915 [COMPLETED] — both landed, both load-bearing here
**Sources/Inputs**: - Codebase (`FormalSystem/Metalogic/NamingRules.lean`, `FormalSystem/Semantics/{ConeUnravelling,HistoryMorphism,IntNormalForm,TaskFrame}.lean`, `FormalSystem/PlusLanguage/{Formula,PlusTruth,PlusValidity,PlusStateLocal,PlusLCSchema,PlusIntTransfer,PlusReversal}.lean`), lean-lsp MCP (`lean_run_code`, `lean_local_search`), `lake env lean`, literature (`reynolds_2001` §7 Definition 4 / Lemma 6, §4.7 Lemma 3 — `verified_conversion`), archived probe `specs/evidence/limit-closure-schema/lc-schema-omega-chain.lean` Part J
**Artifacts**: - specs/895_auxiliary_atoms_rule_soundness_ztime/reports/01_auxiliary-atoms-rule-soundness.md
  - specs/evidence/auxiliary-atoms-rule-soundness/aa-core-probe.lean (new, compiled, sorry-free)
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **No obstruction. The whole route is compiled, not argued.** Seven ingredients — every step of
  the proof that was not already a landed library theorem — were written and checked against the
  real library in `specs/evidence/auxiliary-atoms-rule-soundness/aa-core-probe.lean`:
  `lake env lean` exits 0 with zero diagnostics and zero `sorry`. The remaining work is assembly,
  not discovery.
- **State the rule at `PlusValidInt`, not at `PlusValidZTime`.** `coneFrame F` requires
  `F : FrameOver intOrder` with `[F.IsRegular]` — which is *exactly* `PlusValidInt`'s binder
  bundle — so the premise instantiates at the cone with no plumbing (checked). `PlusValidZTime`
  then follows by `plusValidZTime_iff_plusValidInt`, and the **mirror rule is a two-line
  corollary** of `plusValidIn_reflectTime_iff`. This is the landed `lcN_plusValidInt` →
  `lcN_plusValidZTime` → `lcN_reflectTime_plusValidZTime` pattern, reused verbatim. No mirrored
  cone is needed, and the mirror must *not* be expanded in syntax (precedent and reasons below).
- **`exists_coneUnravelling` is the wrong entry point and must not be used here.** It hides the
  carrier behind an existential, so no valuation can be defined on it. Use the concrete
  ingredients the same module exports — `coneFrame F`, `coneF`, `coneF_twoWayBounded`,
  `coneF_surjective`, `coneFrame_isRegular` — and call
  `TwoWayBounded.plus_invariance_of_isZTime` directly, as the headline itself does.
- **The one conceptual gap, and its one-line closure.** The machine's input function must be
  `idx : F.WorldState → ℕ` — a function of the *state alone* — while `PlusFormula.StateLocal`'s
  semantic content (`IsPlusStateLocal`) is a **same-time** property and does not by itself give
  time-independence. The gap closes by composing `plusStateLocal_stab_iff` with
  `stab_state_only`, which *is* the different-times statement. Compiled as probe (A).
- **Three small library gaps, each with a sibling-language precedent**: L⁺ has no `next_iff_succ`
  (L and L^N both do), no family form of `plusTruthAt_congr_of_fresh` (the landed one forgets one
  atom; the rule discharges a finite set), and no different-times corollary of state-locality.
  All three are probe-checked.
- **Zero-debt: no sorry is needed anywhere, and none is proposed.** Freshness, exclusivity and
  the machine run are all *verified* at the constructed model rather than assumed; only the
  `aᵢ`-partition conditions are hypotheses, which is faithful to Reynolds (where they are
  classical-tautology side conditions).

## Context & Scope

What was researched: whether the transposed Reynolds-2001 Auxiliary-Atoms rule can be stated at
the L⁺ formula level and proved validity-preserving at `FrameClass.ZTime` with the library as it
now stands; which declarations the proof consumes; what is missing; where the module belongs; and
what the repository gate set demands of a new `Metalogic/` module.

Constraints honoured: the task's own prescription of the antecedent shape and the proof route
(cone unravelling + machine-run valuation + freshness + projection); the zero-debt policy (no
sorry deferral, no new axiom); literature fidelity to `reynolds_2001` §7, which the task names
explicitly and which task 915 made citable; and the territory contract (nothing read or written
overlaps task 909's `file_scope`).

Out of scope, as the task states: any completeness claim, and any derivability (proof-system)
form of the rule. This is a soundness fact about one rule.

## Literature Proof Structure

**Source**: Reynolds, *An Axiomatization of Full Computation Tree Logic* (2001), §7 "The
auxiliary atoms rule" — Definition 4 and Lemma 6; §4.7 Lemma 3. Chunk
`b8612210b46df4dc`, `provenance_fidelity: verified_conversion` (not an unverified summary).
**Strategy**: contraposition — satisfiability-preservation of the antecedent, discharged by
unravelling the model into an ω-tree and defining the fresh atoms by recursion on branch
prefixes.

### Definition 4, as the source states it

`{a₁, …, aₙ}` uses atoms from `L` only, with: each `aᵢ` a **state formula** (a boolean
combination of atoms and formulas of the form `E…`); `(aᵢ ∧ aⱼ) → false` a substitution instance
of a classical tautology for `i ≠ j`; and `⋁ᵢ aᵢ` a substitution instance of a classical
tautology. `Q` finite and enumerated, `b₀ ∈ Q`, `p : Q × {1,…,n} → Q`, and

```
θ  :=  b₀  ∧  ⋀_{b∈Q} ⋀_{i=1..n} A G ((b ∧ aᵢ) → A X p(b,i))  ∧  ⋀_{b≠b'∈Q} A G ¬(b ∧ b')
```

**AA**: infer `⊢ ψ` from `⊢ (θ → ψ)` provided `L` and `Q` are disjoint, `ψ` uses atoms from `L`
only, and `θ` is functionally `L + Q`-expandable.

### Step map, and the transposition into this tree

| # | Source step | TM/L⁺ counterpart | Status |
|---|---|---|---|
| 1 | `A` (universal path quantifier) | `⊡` (`PlusFormula.stab`) | landed |
| 2 | `G` (reflexive future) | `G≤` (`PlusFormula.gle`, `gle_iff`) | landed, `PlusLCSchema.lean` |
| 3 | `X` | `PlusFormula.next` | landed; **its truth clause is not** (gap 1) |
| 4 | finite conjunction over `Q`, over `i` | `bigAnd` + `bigAnd_iff` | landed, `PlusLCSchema.lean` |
| 5 | "`aᵢ` is a state formula" | `PlusFormula.StateLocal` | landed; needs a different-times corollary (gap 2) |
| 6 | `aᵢ` pairwise inconsistent / jointly exhaustive, by classical tautology | validity hypotheses on the rule | weaker than the source, hence a *more general* rule |
| 7 | "ω-tree model" (Lemma 3 (a)⇔(d), "a tree can be produced by unraveling the fullpaths") | `coneFrame F` + `coneF_twoWayBounded` + `plus_invariance_of_isZTime` | **landed by task 894** |
| 8 | "a simple recursion on the length of finite prefixes of branches" defines the `Q` valuation | `aaRun`/`aaState` over the recorded list, i.e. the archived `coneSt` | probe (F)/(G) |
| 9 | `ψ` uses atoms from `L` only | `∀ j < m, Fresh (qa j) φ` + a family congruence | landed for one atom; family form is gap 3 |
| 10 | "via lemma 3, have our result" | projection along `g.mapH`, with `g.lift` anchoring | landed |

The task description's `aaAnte` matches Definition 4's `θ` **clause for clause** under rows 1-4,
including the exclusivity conjunct sitting under `⊡G≤` and the `⊡X` (not bare `X`) in the step
clause. That fidelity is confirmed against the source text, not assumed.

### Dependencies

Step 8 depends on 7 (the carrier must exist before a labelling of it can be defined). Step 10
depends on 7 and 9. Step 6 is consumed only inside step 8's `idx`, and consumes step 5.

### Potential formalization challenges

- **Step 5 is the only one with real content beyond transcription.** "State formula" in a CTL*
  setting means truth depends on the *state*, full stop. `IsPlusStateLocal` fixes the time on
  both sides, so it is weaker as written. See Finding 2.
- **Step 3**: `next = untl ⊥ ·` needs a successor-collapse lemma that L⁺ lacks.
- **Step 6**: the source's "substitution instance of a classical tautology" is strictly stronger
  than semantic validity. Taking validity as the hypothesis is a *generalization*, recorded as a
  deliberate deviation rather than a silent one.

## Findings

### Codebase Patterns

**1. The cone-unravelling API, and which half of it to use.**
`FormalSystem/Semantics/ConeUnravelling.lean` (1060 lines, 41 declarations, task 894) exports
both a concrete layer and an existential headline:

- Concrete: `coneR`, `coneF`, `coneFrame F : FrameOver intOrder`, `coneFrame_taskRel`,
  `coneFrame_isRegular` (an `instance`, deliberately), `coneF_twoWayBounded F`,
  `coneF_surjective (E := F.step)`.
- Existential: `exists_coneUnravelling F M : ∃ (F' : FrameOver intOrder) (_ : F'.IsRegular) (f : …), TwoWayBounded f ∧ Function.Surjective f ∧ ∃ g : HistMorphism F' F, g.toFun = f ∧ ∀ φ τ' t, …`

**The existential cannot be used by this task.** It quantifies the carrier away, and the AA
proof must define a valuation *on that carrier* (the `Q`-atoms read the machine state of a
cone node). Use the concrete layer and call
`TwoWayBounded.plus_invariance_of_isZTime (h := coneF_twoWayBounded F) (hs := coneF_surjective (E := F.step)) M`
directly — which is what `exists_coneUnravelling`'s own body does. This is a finding about the
*shape* of the dependency, not a defect in task 894's deliverable: nothing in the headline is
wrong, it is simply packaged for a different consumer.

**2. `HistMap.lift` is the anchoring device, and it is already a field.**
`HistMorphism` extends `HistMap`, whose `lift` field is exactly the pointed lifting the proof
needs: `∀ τ a t, toFun a = τ.state t → ∃ τ', τ'.state t = a ∧ ∀ s, toFun (τ'.state s) = τ.state s`.
Instantiated at `a := .inr (τ.state x, [])` — where `coneF (.inr (w, [])) = w` holds by
`rfl` — it yields a cone history anchored at the empty-record node *and* projecting onto the given
base history (`WorldHistory.ext_state` turns the pointwise equation into `g.mapH τ' = τ`). No
history-construction work is needed, and no `onto`/surjectivity-on-histories argument either.
This is the structural analogue of `clock_irr_sound`'s use of `projH_liftH`.

**3. `PlusValidInt` is the correct statement level, and it is free.** Verified by compiled
example: `(h : PlusValidInt φ) (M) (τ) (t : ℤ) : PlusTruthAt M τ t φ := h (coneFrame F) M τ t`
elaborates with the `[(coneFrame F).IsRegular]` binder discharged by `coneFrame_isRegular`'s
instance status. The three-step ladder
`aa_sound_int` (at `PlusValidInt`) → `aa_sound_ztime` (by `plusValidZTime_iff_plusValidInt`) →
mirror (by `plusValidIn_reflectTime_iff`) mirrors `lcN_plusValidInt` /
`lcN_plusValidZTime` / `lcN_reflectTime_plusValidZTime` exactly.

**4. The antecedent's syntax is already expressible.** `PlusFormula.gle` + `gle_iff` and
`bigAnd` + `bigAnd_iff` live in `PlusLanguage/PlusLCSchema.lean` and are `ℕ`-indexed over
`ℕ → PlusFormula`. Matching that indexing — `qa : ℕ → Atom` with bound `m`, `a : ℕ → PlusFormula`
with bound `k`, `p : ℕ → ℕ → ℕ` with `∀ j < m, ∀ i < k, p j i < m` — makes `bigAnd_iff` directly
reusable and avoids all `Fin`/`Finset` plumbing. `lcAnte`/`lcN` are the style precedent.

**5. `clock_irr_sound` is the template for the rule's shape**, with one difference. It is stated
at an arbitrary `FrameClass` because the translation product stays in any class. The AA rule
cannot be: `coneFrame` exists only over `intOrder`, so the class is fixed at `.ZTime` (via
`PlusValidInt`). Its `Fresh` predicate, its `plusTruthAt_congr_of_fresh`, and its
"build a model → discharge the antecedent → forget the atom → project" skeleton all transfer.

### External Resources

- `reynolds_2001` §7 (Definition 4, Lemma 6) — the primary statement, read and mapped above.
  OCR is degraded in the formula display (`⋀` renders as `A`, `θ` as `0`, `ψ` as `V`/`T`); the
  structure is nonetheless unambiguous and agrees with the task description. Cite §7 by section,
  and quote no OCR'd formula verbatim into Lean doc comments.
- `reynolds_2001` §4.7 Lemma 3 — Kripke validity ⇔ complete ω-tree validity, with the explicit
  remark that "a tree can be produced by unraveling the fullpaths on a given Kripke frame". This
  is the source-side counterpart of `exists_coneUnravelling`, and the right `Paper:`-line anchor
  for the new module's docstring narrative.
- Archived probe `specs/evidence/limit-closure-schema/lc-schema-omega-chain.lean` Part J
  (lines 515-600): `coneR`, `coneF`, `cone_twoWay`, `run`, `coneSt`, `aa_expand`. Mathlib-only
  mirror over `IsWalk`, not over `WorldHistory`. `aa_expand`'s proof shape (the `hin`
  induction, then the single step at `s = t + k`) transfers intact; its `omega` steps do not
  (see Risks).

### Recommendations

**Home: a new sibling, `FormalSystem/Metalogic/AuxiliaryAtoms.lean`.** Not `NamingRules.lean`.
That module would have to gain four imports (`Semantics/ConeUnravelling`,
`PlusLanguage/PlusLCSchema`, `PlusLanguage/PlusIntTransfer`, `PlusLanguage/PlusStateLocal`) for
declarations none of its current clients consume, and its docstring already defers the AA
expansion to elsewhere ("That transfer is **not** formalized here"). A sibling keeps the blast
radius at one new file plus registration. `NamingRules.lean` needs **prose only**: retire the
"and where it stops" framing now that the rule exists, and add the cross-reference. No import,
so no new edge.

**Layer/gate check, done:** `Metalogic/` → `Semantics/` is a *downward* edge, so
`check-metalogic-cycles.sh`'s assertion B (the upward allowlist, which fails on surplus *and*
shortfall) is untouched; the layer table covers `Metalogic/` by directory, so no
`LANGUAGE_FILE_LAYERS` row is needed (only new files in the *language* directories need one).
What the new module does owe: a line in `FormalSystem/Metalogic.lean` (C8, aggregator
convention), regeneration of `FormalSystem.lean` via `lake exe mk_all --lib FormalSystem` (C33,
byte-currency), a transitive `FormalSystem.Init` import (C24), camelCase `def`s (C26 forbids
snake_case `def`/`abbrev`; theorem names stay snake_case), `Paper:` lines on the public
declarations (C15/`check-paper-definitions.sh`), and `docs/theorem-index.md` rows. An
axiom-profile evidence module under `Tests/BimodalTest/Metalogic/` with `#guard_msgs`-gated
`#print axioms` blocks is the task-894 precedent and should be matched (expected ceiling
`[propext, Classical.choice, Quot.sound]` — `Classical.choice` is genuinely consumed, by `idx`).

**The three library gaps to land first** (each probe-checked, each with a precedent):

1. `plusTruthAt_next_iff_succ` over `[SuccOrder F.Duration] [NoMaxOrder F.Duration]`, plus the
   `intOrder` corollary via `Order.succ_eq_add_one`. Twin of
   `SourceLanguage/SentenceTruth.lean`'s `next_iff_succ` and `NomicLanguage/NomicTruth.lean`'s
   `next_iff_succ`/`next_iff_add_one`. ~12 lines. **Candidate for promotion to
   `PlusLanguage/PlusTruth.lean`** — it is general and belongs beside the other `_iff` clause
   lemmas; keeping it local first and recording the promotion rationale at the declaration is the
   `base_taskRel_eq_ofStepRel` precedent.
2. `plusTruthAt_stateLocal_state_only` — the different-times form of state-locality, a one-line
   composition of `plusStateLocal_stab_iff` and `stab_state_only`. **Promotion candidate for
   `PlusLanguage/PlusStateLocal.lean`**, where the module docstring already discusses precisely
   the same-time/different-times asymmetry and says the different-times shape "does **not**
   generalize to this fragment" — true of `box φ`, but the *composition* above does hold for a
   `StateLocal φ`, and that is worth recording there rather than only here.
3. `plusTruthAt_congr_of_fresh_family` — the finite-family form of
   `NamingRules.plusTruthAt_congr_of_fresh`. The induction is the same seven cases with
   `hV`'s side condition read as `∀ j < m, r ≠ qa j`. **Reuse `NamingRules.Fresh` itself** — do
   not define a second freshness predicate — so the tree keeps one notion and only the congruence
   theorem is generalized; cross-reference the single-atom case at the new declaration.

**Proof skeleton of the headline** (every numbered step corresponds to a compiled probe or a
landed theorem):

```
aa_sound_int:  intro F ⟨F.IsRegular⟩ M τ x
  0.  obtain ⟨g, hgf, htruth⟩ := TwoWayBounded.plus_invariance_of_isZTime
         (coneF_twoWayBounded F) (coneF_surjective (E := F.step)) M
  1.  idx := aaIdx a k M            -- noncomputable dite; well-defined by probe (A) + exhaustiveness
  2.  Mc := aaModel F M qa m (aaState p b₀ idx)                              -- probe (F)
  3.  obtain ⟨τ', hanchor, hproj⟩ := g.lift τ (.inr (τ.state x, [])) x (by rw [hgf])
  4.  antecedent at (Mc, τ', x):
        b₀         -- aaModel_atom_q, aaRun [] = b₀
        ⊡G≤ step   -- stab_iff ▸ gle_iff ▸ bigAnd_iff ▸ next_iff_add_one ▸ aaState_step  (probe G)
        ⊡G≤ excl   -- stab_iff ▸ gle_iff ▸ bigAnd_iff ▸ aaModel_atom_q (two states, one node)
  5.  φ at (Mc, τ', x)                            -- the premise, at `coneFrame F` (Finding 3)
  6.  φ at (g.pullM M, τ', x)                     -- congr_of_fresh_family, via aaModel_valuation_off
  7.  φ at (M, g.mapH τ', x)                      -- htruth
  8.  g.mapH τ' = τ                               -- WorldHistory.ext_state hproj
```

Step 4's step-clause branch is the only one with work in it, and it is exactly probe (G) plus
the index-matching argument: when `aᵢ` is true at a cone node, transfer it to the base by steps
6-7 and apply **exclusivity** to force `i = idx (coneF z)`, which is the index `aaState` actually
stepped on. Exhaustiveness is what makes `aaIdx`'s `dite` take its real branch at every
*occurring* state — and only occurring states are ever asked about, so **no global
"history through a state" existence lemma is needed** (the tree has none).

**Suggested phase decomposition** (five phases, each independently green):

1. The three infrastructure lemmas above (gaps 1-3). ~90 lines.
2. Cone-history lemmas + `aaRun`/`aaState` + `aaState_step`. ~120 lines — all of it already
   compiled in the probe, transcription plus doc comments.
3. The antecedent syntax: `aaStep`, `aaExcl`, `aaAnte` as `def`s, with their three
   truth-characterization lemmas.
4. `aaModel`, `aaIdx`, and `plusTruthAt_aaAnte` (step 4 above).
5. The three headline theorems, the evidence module, `theorem-index.md` rows,
   `NamingRules.lean`'s prose, aggregator/README/`FormalSystem.lean` registration, gate set.

**Mirror rule: state it, do not expand it.** `plusValidIn_reflectTime_iff` makes the mirror a
two-line corollary (`PlusValidZTime ((aaAnte …).imp φ).reflectTime` → unreflect → forward rule →
reflect), with the freshness and partition hypotheses stated on the *unreflected* data so that no
`Fresh`-vs-`reflectTime` commutation lemma is needed. Expanding the mirror in syntax would
require an `H≤` definition (neither `Formula` nor `PlusFormula` carries a reflexive *past*
closure), a `reflect_time_gle` push-through, and a `reflect_time_bigAnd` — the three declarations
`lcN_reflectTime_plusValidZTime`'s doc comment names and declines, for the same reason. Follow
that precedent and record it. A mirrored cone is likewise unnecessary and should not be built.

## Decisions

- **Statement level `PlusValidInt`, not `PlusValidIn fc` generic.** Forced: the construction
  exists only over `intOrder`. Recorded so a reader does not read the narrowing (against
  `clock_irr_sound`'s class-generic signature) as sloppiness.
- **Concrete cone API, not `exists_coneUnravelling`.** Forced by the need to define a valuation
  on the carrier.
- **`ℕ`-indexed bounded families for `Q`, the `aᵢ` and the machine**, not `Fin`/`Finset`. Chosen
  to match `bigAnd`'s indexing and `lcN`'s style; the alternative buys nothing and costs
  conversion lemmas at every `bigAnd_iff` site.
- **The `aᵢ` partition conditions enter as semantic validity hypotheses**, which is weaker than
  Reynolds' "substitution instance of a classical tautology" and therefore yields a more general
  rule. Deliberate; to be stated at the declaration.
- **`NamingRules.Fresh` is reused, not re-defined.** Only the congruence theorem is generalized.
- **One new module, prose-only change to `NamingRules.lean`.**
- **Evidence probe lives at `specs/evidence/auxiliary-atoms-rule-soundness/aa-core-probe.lean`**,
  not under the task directory — `check-evidence-probes.sh`'s header states the reason (task
  directories are archived into a gitignored path). Whether to add a `WIRED` entry for it is a
  plan decision; task 894 declined for its own probe, and an unlisted file there is simply
  unguarded rather than a gate failure.

## Risks & Mitigations

| # | Risk | Severity | Mitigation (all verified) |
|---|---|---|---|
| 1 | `omega` cannot see arithmetic over `↑intOrder` ("no usable constraints"), so the archived probe's `⟨(s-t).toNat, by omega⟩` offset extraction does not transfer | would block probe (G) | Replaced by `Int.toNat_of_nonneg` + `sub_nonneg` + `abel`. Compiled. Same obstruction task 894 recorded for `x.natAbs = n + 1` |
| 2 | `coneFrame_taskRel` does not rewrite a goal phrased with `(coneFrame F).toTaskFrame.TaskRel` (as `WorldHistory.respects_task` gives it) | small, easy to misread as a missing lemma | State an intermediate `have` at `FrameOver.TaskRel` first; `toTaskFrame` is `@[reducible]`, so it typechecks. Compiled in probe (C) |
| 3 | `IsPlusStateLocal` is same-time only, so `idx` looks ill-defined | would be a design-level gap | Closed by probe (A). This is the finding most likely to be missed by an implementer reading `StateLocal` alone |
| 4 | `#print axioms` ceiling rises (`Classical.choice` from `aaIdx`'s `dite`) | cosmetic but gate-visible | `Classical.choice` is already in the cone modules' measured ceiling `[propext, Classical.choice, Quot.sound]`; measure and pin in a new evidence module rather than asserting |
| 5 | Style/linter gates on new code: `show` that changes the goal (`linter.style.show`), unused `simp` arguments | minor, C16/C28/C30 | Both were hit and fixed inside the probe (`change` instead of `show`); the probe now compiles with **zero** diagnostics, so the transcribed code starts clean |
| 6 | Sibling task 909 is implementing concurrently on this tree | low | No file this task touches is in 909's declared `file_scope`; `FormalSystem/Metalogic/README.md` and `README.md` *are* in it, so the inventory regeneration in phase 5 must re-read those files immediately before editing and stage only its own hunks |
| 7 | The deployed `.claude/` tree is stale for five extensions | none for this task | No `.claude/**` file is written; the gates cited above were read from `scripts/` (the repository's own, not a deployed copy) |

## Tactic Survey Results

Investigated with `lean_run_code` against the real library (not `lean_multi_attempt`, since each
candidate needed a full standalone statement rather than a tactic at an existing goal). All seven
were subsequently consolidated and re-checked with `lake env lean`: exit 0, zero diagnostics.

| Goal | Tactic | Result | Premises/Config |
|------|--------|--------|-----------------|
| state-local truth is state-only (A) | term-mode `Iff.trans` chain | success | `plusStateLocal_stab_iff`, `stab_state_only` — no tactic needed |
| `next` collapses to `succ` (B) | `rw` + `rcases lt_or_eq_of_le` | success | `PlusTruth.untl_iff`, `Order.succ_le_of_lt`, `Order.lt_succ`, `PlusTruth.bot_false` |
| `next` at `+1` over `intOrder` (B') | `rw` | success | `Order.succ_eq_add_one` (synthesizes over `↑intOrder`) |
| cone history one-step edge (C) | `have`/`rwa` + `simp only` + `norm_num` | success | `coneFrame_taskRel`, `ofStepRel`, `iter_zero`; `abel` for `s + 1 - s = 1` |
| cone history one-step edge (C) | `omega` for the duration arithmetic | **fail** | "no usable constraints" on `↑intOrder`; `abel`/`push_cast` used instead |
| `inr`-anchoring induction (D) | `induction` + `rcases hv :` + `simpa` | success | probe (C), `push_cast`, `abel` |
| family freshness congruence (E) | `induction` + congruence combinators | success | `imp_congr`, `forall_congr'`, `exists_congr`, `and_congr_right`, `imp_congr_right` |
| `aaModel` reading lemmas (F) | `rintro`/`exact` | success | injectivity-below-`m` hypothesis is load-bearing in `aaModel_atom_q` |
| the step identity (G) | `obtain`/`rcases hv :`/`change`/`rw` | success | probes (C), (D); `Int.toNat_of_nonneg`, `sub_nonneg`, `abel` |
| the step identity (G) | `show` to restate the `aaRun` goal | **fail (lint)** | `linter.style.show` rejects a goal-changing `show`; `change` accepted |
| premise instantiation at the cone | `exact h (coneFrame F) M τ t` | success | `PlusValidInt`'s binders discharged by `coneFrame_isRegular` |

`aesop`, `decide`, `ring`, `linarith`, `positivity` and `lean_hammer_premise` were not reached:
every goal above closed on the first or second structured attempt, and the task's literature
source prescribes the proof steps, so tactic search would have been a fidelity violation rather
than an economy (`lean4.md`, Literature Fidelity).

## Context Extension Recommendations

- **Topic**: duration-type arithmetic over `↑intOrder`.
  **Gap**: `omega` fails on `↑intOrder` with "no usable constraints" even though the type is
  reducibly `ℤ`. Two tasks have now independently rediscovered this (894, for
  `x.natAbs = n + 1`; this one, for `∃ n : ℕ, s = t + n`) and each paid to find its own
  workaround. `context/project/lean4/patterns/` has no entry for it.
  **Recommendation**: a short pattern file recording the symptom, the two concrete replacement
  idioms (`Nat.exists_eq_succ_of_ne_zero ∘ Int.natAbs_ne_zero` for the first;
  `Int.toNat_of_nonneg` + `sub_nonneg` + `abel` for the second), and the `@[reducible]`
  `toTaskFrame` corollary that `FrameOver.TaskRel`-stated rewrites miss goals phrased through
  `.toTaskFrame.TaskRel`. One file, two idioms, both already compiled here.

## Appendix

**Searches and probes run.** `lean_local_search` (`coneFrame`; index reported `warming`, so its
results are corroborating rather than proof of absence — every name below was additionally
confirmed by grep against the source and by compiled use). `lean_run_code` ×4 (probe batches
A-D, E-F, G, H-I). `lake env lean` ×1 on the consolidated probe: exit 0, zero diagnostics, zero
`sorry`. No rate-limited search tool was needed: nothing here is a Mathlib-lemma hunt, and
`lean_leansearch`/`lean_loogle`/`lean_leanfinder` were therefore not called. No MCP call failed
and no fallback was exercised. **Blocked tools `lean_diagnostic_messages` and
`lean_file_outline` were not called.**

**Literature queries.** `literature-search.sh "auxiliary atoms rule"` → `reynolds_2001` §7
(`b8612210b46df4dc`, rank -20.5, top hit); `--read` on that chunk; grep for `Lemma 3` across
`~/Projects/Literature/sources/reynolds_2001/*.md` → §4.7.

**Declarations confirmed to exist, with signatures read this session.**
`FormalSystem.Semantics`: `coneR`, `coneF`, `coneFrame`, `coneFrame_taskRel`,
`coneFrame_isRegular`, `coneF_twoWayBounded`, `coneF_surjective`, `base_taskRel_eq_ofStepRel`,
`exists_coneUnravelling`, `ofStepRel`, `ofStepRel_of_nonneg`, `iter`, `iter_zero`,
`FrameOver.taskRel_eq_iter`, `FrameOver.toTaskFrame`, `worldHistoryOfStepPath`,
`HistMap.{toFun,forth,lift,mapH,pullM}`, `HistMorphism.{onto,plus_invariance,plusValidOn}`,
`TwoWayBounded.{exists_histMorphism_of_isZTime,plus_invariance_of_isZTime}`.
`FormalSystem.PlusLanguage`: `PlusFormula.{atom,bot,imp,box,untl,snce,stab,and,or,neg,iff,top,next,always,allFuture,allPast,someFuture,somePast,dstab,gle,reflectTime,StateLocal}`,
`PlusTruth.{box_iff,stab_iff,untl_iff,snce_iff,dstab_iff,and_iff,bot_false,top_true}`,
`stab_state_only`, `plusStateLocal_stab_iff`, `isPlusStateLocal_of_stateLocal`, `gle_iff`,
`bigAnd`, `bigAnd_iff`, `lcAnte`, `lcN`, `lcN_plusValidInt`, `lcN_plusValidZTime`,
`lcN_reflectTime_plusValidZTime`, `PlusValidIn`, `PlusValid{,Dense,ZTime,Int}`,
`plusValidZTime_iff_plusValidInt`, `plusValidIn_reflectTime`, `plusValidIn_reflectTime_iff`.
`FormalSystem.Metalogic.NamingRules`: `Fresh`, `plusTruthAt_congr_of_fresh`, `clockAnte`,
`plusTruthAt_clockAnte`, `clock_irr_sound`, `irr_sound`.
Confirmed **absent**: any `bigOr`, any `H≤`/reflexive-past closure, any `next_iff` at
`PlusTruthAt`, any family/set form of the freshness congruence, any different-times corollary of
`StateLocal`, any "history through a state" existence lemma, and any existing `aa`/
`AuxiliaryAtoms` declaration or module.

**Gate scripts read.** `scripts/check-metalogic-cycles.sh` (assertions A/B/C and the layer-table
contract), `scripts/check-module-invariants.sh` (C6/C8/C24/C26/C33 and the enforcement flags),
`scripts/module-invariants-manifest.txt`, `scripts/check-evidence-probes.sh`,
`scripts/check-copyright-headers.sh`.
