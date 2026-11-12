# Research Report: Task #901 — the two-sided Reynolds engine for L⁺ at ZTime, written out at Reynolds-2001 §9-§15 rigour

**Task**: 901 - Paper proof of the two-sided Reynolds engine for L-plus at ZTime: ban preservation, fair scheduling, universal non-acceptance, truth lemma
**Started**: 2026-11-09T19:00:00Z
**Completed**: 2026-11-09T19:27:20Z
**Effort**: one research dispatch (orchestrated, seq 4); paper only, no Lean work, no library change
**Dependencies**: None blocking. Prior art inherited as read: the L⁺ ZTime completeness programme report, the CSLib ω-automata NO-GO re-assessment, the Muller-sufficiency split verdict.
**Sources/Inputs**:
- Literature (held, read in full this session): Reynolds 2001, *An Axiomatization of Full Computation Tree Logic*, `/home/benjamin/Projects/Literature/sources/reynolds_2001/` — `sec02_a.md` (PLTL axioms C0-C8, §2.1 automata, Theorem 2), `sec03_…md` (C9-C15, §6 LC with its soundness proof, §7 Definition 4 and the AA rule with Lemma 6), `sec04_…md` (§9: the three languages, `ecl`, `χ₀`, the automaton, `θ_A`, `χ₁`, `φ⁺`, Lemma 7 with Claims 1-3), `sec05_…md` (§10.1 hues/colours, Lemmas 8-12, §11 the idea of banning, `ζ_L`), `sec06_…md` (§11.1 lulls and `e_H`, §12 chronicles K0-K5D, Lemma 13, §12.1 pioneers P1-P4, §12.2 Lemma 14, §13 Lemma 15 and Definition 6, Lemma 16, §13.1 the banning procedure), `sec07_…md` (§13.2 Lemma 17 — the LC consumer — Lemma 18, §14 the limit, §14.1 the Kripke structure, §14.2 Lemmas 19-20), `sec08_…md` (§14.3 evaporating graphs, Lemmas 21-22), `sec09_…md` (§15 the truth lemma and Lemmas 24-27)
- Prior records, read in full this session: `specs/879_lplus_ztime_completeness_tm_plus_lc_programme/reports/01_lplus-ztime-completeness-programme.md` (all four deliverables, the 21-row ingredient table, both amendment notes), `specs/902_reassess_lplus_ztime_nogo_cslib_omega_automata/reports/01_cslib-omega-automata-nogo-reassessment.md` ((O1)-(O4) as quoted in its Finding 3), `specs/903_muller_sufficiency_for_auxiliary_atoms_rule_ztime/reports/01_muller-sufficiency-aa-rule-ban-lull.md` (read in full; its split verdict is inherited here as a settled premise, not re-derived)
- `specs/879_…/probes/01_target-statements.lean` — read verbatim this session: `lcU`, `IsLCAxiom`, `IsLCUAxiom`, `RuleSet`, `aaStep`, `aaExcl`, `aaAnte`, `ExtDerivation` with all eleven constructors, `ExtSound`/`ExtComplete`, `T1`/`T2`/`T3`
- This repository, read this session: `FormalSystem/PlusLanguage/Formula.lean` (the seven constructors, every derived operator, `reflectTime`, `IsPureFuture`/`IsPurePast`), `PlusLanguage/PlusTruth.lean:84-93` (the seven truth clauses), `PlusLanguage/Axioms.lean:110-313` (the full TM⁺ schema list incl. `stab_k/t/4/5`, `box_stab`, `atom_stab`, `paste`, `untl_paste`, and `minFrameClass`), `PlusLanguage/PlusLCSchema.lean` (module docstring, `gle`, `gle_iff`, `bigAnd`, `bigAnd_iff`, `lcAnte`, `lcCons`, `lcN`, `lcU`, and the five validity theorems), `PlusLanguage/PlusStateLocal.lean:149-186` (`StateLocal` and its arms), `PlusLanguage/PlusPasting.lean:250-362` (`agreeFrom`/`agreeUpTo`, `paste_agreeFrom`, `paste_agreeUpTo`, `truth_congr_agreeFrom`, `truth_congr_agreeUpTo`, `paste_valid`, `paste_valid'`), `PlusLanguage/Substitution.lean:155-198` (`PlusAxiom.ofTMSubst`, `minFrameClass_ofTMSubst`, `PlusDerivationTree.ofTMSubst`), `Metalogic/NamingRules.lean:115-192,317-360` (`Fresh`, `once`, `rigid`, `clockAnte`, `clock_irr_sound`, `irr_sound`), `Metalogic/Expressiveness/SeparationZ/Discharge.lean:86-152` (`sepZ`, `sepZ_sepClauses`, `plusTruthAt_sepZ_iff`, `separationOver_ztime`), `Metalogic/SetConsequence.lean:226` (`WeakCompleteness`), `Metalogic/StrongCompleteness.lean:1119` (`completeness_ztime`), `Semantics/TaskFrame.lean` (module docstring §§ on the four regularity constraints and the `saturation_of_*` family), `OpenLanguage/OpenTruth.lean:339` (`stab_iff_ofut_opast`)
- Mathlib lookup skipped: no Lean target (`file_scope` for this task is `[]`, `task_type` is `formal`, not lean4-routed) — gate resolved by `context/patterns/mathlib-lookup-gate.md` condition (a), which is false, so condition (b) was not checked
**Artifacts**:
- `specs/901_two_sided_reynolds_engine_paper_proof/reports/01_two-sided-reynolds-engine-paper-proof.md` (this report)
**Standards**: report-format.md, subagent-return.md
**Task Type**: formal
**Domains**: logic (primary: the proof system, the three languages, the chronicle, ban preservation, the truth lemma), math (secondary: ω-automata acceptance shape, the evaporating-graph combinatorics, the order/graph theory of the sliced quotient and its universal cover)

## Status vocabulary

*Compiled* — a declaration of this repository's library, read at its cited line this session. *Held* — a literature fact read this session in a held source, with its chunk cited. *Derived* — a paper derivation performed this session, stated with its argument. *Carried* — inherited from a prior record and not re-derived, flagged at each use. *Open* — named and not answered.

No claim below is a completeness claim. Nothing under `FormalSystem/`, `Tests/`, `lakefile.toml` or `lake-manifest.json` was touched; no `require` was added; no Lean process was started and no `lake` invocation was made. The write-up below is a **paper proof**: it has the status of Reynolds' own §9-§15 text, not of a machine-checked theorem.

## Executive Summary

- **The transposition closes, and it closes in a shape the prior architecture did not predict.** The two-sided engine is **not** one interleaved chronicle with a joint ban-preservation lemma; it is **two one-sided engines hinged at the clock cut**, each verbatim Reynolds (one of them under `reflectTime`), whose only interaction is at the anchor ≡-class. Finding 11 states the obstruction that rules out the interleaved form — Reynolds' Lemma 16 non-emptiness argument needs a *joint* K5A clause, and Lemma 17's prefix-transfer step `⊢ ⟐X((⟐β) U ⟐χ₁⁺) → ⟐χ₁⁺` has **no backward counterpart across a forward segment**, because backward badness is a tail-of-the-past property and a forward β-segment does not carry it down — and Finding 11.3 resolves it by the **level split**: the forward banned list lives at levels ≥ 0 and is computed upward from the anchor, the backward list at levels ≤ 0 and downward, the two frontiers are the top and the bottom and never meet. Derived.
- **Separation is consumed twice, not once, and the two uses are different.** 879 located one consumption point (the legitimacy of the cut initialisation). This write-up splits it. (i) **Separation** makes the cut index a *finite, state-level* datum: by `sepZ` every closure formula is a conjunction of (pure-past ∨ pure-future) clauses whose literals are themselves closure members, so the truth of any closure formula at any position factors through a past-type and a future-type at the cut, each a subset of a fixed finite literal set (Findings 1, 4). (ii) **PS/US pasting** (`paste`, `untl_paste`, compiled) is what makes the *conditional* badness tautology `⊢ χ̄₀[⟐]` derivable, which is Reynolds' Claim 2 and the place 879 put the full-product lemma (Finding 7.3). Neither substitutes for the other: separation gives the finite index, pasting gives the theorem about it. Derived.
- **The cut indexing needs no colour-dependent initial state, and this simplifies the Auxiliary-Atoms interface.** 879 recorded the forward automaton's initial state as "a function of `γ_{colour(w₀)}`". That is avoidable: fold the indexing into the automaton's **first transition**. The AA rule's `θ⊡` already has the shape `b₀ ∧ ⊡G≤((b ∧ aᵢ) → ⊡X p(b,i))`, so the state at position 1 is `ρ(b₀, c₀)` — a function of the cut letter. Defining `ρ⁺(s₀⁺, c) :=` the initial state of the union-automaton for `{pt : ⟐δ_pt ∈ c}` makes the single fixed atom `b₀⁺` sufficient and leaves `aaAnte` (read, the probe) unchanged. Derived; Finding 5.4.
- **The alphabet must be enlarged beyond Reynolds', and the full-product lemma pays for most of the enlargement back.** Reynolds' alphabet is `𝒫(ecl φ)` with `ecl φ = {Eψ, E¬ψ : ψ ≤ φ}`: single realizabilities. The cut needs *realized combinations* of pure literals, which single realizabilities do not determine, so `ecl(φ)` must additionally contain the `⟐`-images of the characteristic conjunctions of the pure literals. Naively that is `⟐δ_{(pt,ft)}` for every pair; the full-product lemma (`{(a∩PastLits, a∩FutLits) : a ∈ c} = PT(c) × FT(c)`, derived from compiled `paste_agreeUpTo`/`paste_agreeFrom`/`truth_congr_*`) collapses it to the separate families `⟐δ_pt` and `⟐δ_ft`. Findings 1.3, 4.2, 4.4.
- **The circularity in the ⊡-case of the truth lemma is closed by clause (b) plus chronicle clause K1, not by cross-certification.** The forward automaton's guarantee is conditional on the cut letter certifying the walk's past-type; the walk's past-type is a function of its *backward* half. The circularity closes on the bar-translation's purity: a certified-but-possibly-wrong hypothetical type is already a usable ticket into clause (b), because the fact clause (b) extracts at position 0 is pure in the automaton's own reading direction and so does not depend on the ticket being right; chronicle clause K1 alone seeds the one further fact clause (b) cannot itself supply. Each automaton's clause (b) already contains the position-0 instance it needs — no cross-certifying clause (a) is required — and `φ⁺` still gains no conjunct. Finding 14.4; derived.
- **Ban preservation consumes `LCU` and its mirror exactly once each, and both are now declared and ZTime-valid in the library.** Finding 10 writes out Lemma 17⁺ line by line in L⁺ syntax: the `⟐α → ⟐X((⟐β) U ⟐α)` step by C9-C13's counterparts (`stab_k/t/4/5`, `box_stab`), the generalisation by `⊡G≤`, then `lcU` to reach `⟐α → ⟐G≤(⟐α ∨ (⟐β U ⟐α))`, then a two-sided-PLTL step to `⟐χ₁⁺`. **Inventory correction to the record**: 879's ingredient row 2 ("`LCU` and mirror, declared and ZTime-valid — missing") is stale. `lcU`, `lcU_plusValidInt`, `lcU_plusValidZTime` and `lcU_reflectTime_plusValidZTime` are all compiled (`PlusLanguage/PlusLCSchema.lean:248,409,464,486`, read this session), so the lemma cites a declared schema by name.
- **Universal non-acceptance, fair scheduling and the truth lemma transpose with no new mathematics, once the level split is in place.** Lemmas 19-22 are combinatorial facts about banned lists and evaporating graphs over a one-sided index and apply verbatim in each half (Findings 12, 13). The truth lemma's `untl` case at a point *below* the anchor is discharged using the **forward** machinery only, because every upward ray from such a point enters the level ≥ 0 region where forward pioneers and forward lulls exist; `snce` below is the mirror (Finding 14.2). The `⊡` (⇐) case for emergent walks is Finding 14.3-14.4.
- **The two located questions are recorded with their settling conditions, and one of them cannot be settled the obvious way.** (Q1) "is `lcU` derivable from TM⁺ + `LC_n` + mirror at ZTime" **cannot be refuted by a ZTime countermodel**, because `lcN` and `lcU` are *both* ZTime-valid (`lcN_plusValidZTime`, `lcU_plusValidZTime`, compiled); a refutation needs a non-ZTime (general-frame or algebraic) model of TM⁺ + `LC_n` in which `LCU` fails. (Q2) "are `clock`, `aaFwd`, `aaBwd` admissible over TM⁺ + the schemata" is open; what is landed is *soundness*, not admissibility (`clock_irr_sound`, `irr_sound`, compiled), and the two are not the same property. T3 together with (Q1) and (Q2) yields T1. Finding 16.
- **The Lean position is unchanged and no Lean work is filed.** (O1) `Muller.toRabin_exists` is the single determinization gap; (O3) determinization arrives existentially over `Type`, not as nameable syntax the AA rule can use; (O4) nothing in either CSLib tree touches the remaining rows; (O2) is discharged under the union-first composition order. Carried from the NO-GO re-assessment as amended. Nothing in this write-up moves any of them: the alphabet enlargement changes only finite cardinalities, which is not what (O1)/(O3) are about. Finding 17.

## Context & Scope

The dispatch asks for one thing: write out, at the level of rigour of Reynolds 2001 §9-§15, the two-sided transposition of the CTL\* completeness engine to L⁺ over ℤ-time for the system TM⁺ + `LCU` + mirror `LCU` + clock rule + forward and backward Auxiliary-Atoms rules. It enumerates nine required components (closure sets with the separated CNF; hues, colours and the state formula of a colour; the two deterministic Rabin automata with the violation language defined through the separated CNF; the consistency lemma via the linear bridge and the three rules; the two-sided chronicle with alternating curing, pioneers and lulls in both directions; ban preservation consuming `LCU` and its mirror; universal non-acceptance along every bi-infinite walk; the truth lemma including the stab case for emergent walks; the final-frame step through the universal cover), two located questions to record, one settled premise to inherit, and one standing prohibition.

**Inherited as settled, not re-derived.** The split verdict on acceptance conditions: a deterministic Muller automaton suffices for the Auxiliary-Atoms rule — the rule's antecedent carries no acceptance condition at all, so determinism is the whole demand — and does **not** suffice for the ban/lull mechanism, whose chronicle indexes `bl` by the number of accepting pairs; the two-state family `Q = {a,b}`, `𝓕 = {{a,b}}` shows pair-enumeration over a Muller family is unsound rather than merely incomplete. Consequently the write-up below names **deterministic Rabin** automata throughout and does not hedge the acceptance type anywhere.

**Scope honoured.** Paper only. No Lean source was written or run; no `lake` invocation; nothing under `FormalSystem/` or `Tests/` touched; no `require`; no completeness or decidability claim; ZTime only; L^▷ not entered. A Lean formalization is **not** filed, per the dispatch and per the standing recommendation, because the located obstruction (O1)/(O3)/(O4) is unresolved.

**Not redone.** The target statements T1/T2/T3 and `ExtDerivation`'s eleven constructors (elaborated in a prior dispatch's probe; read verbatim here, not re-elaborated). The architecture's four deliverables and the 21-row ingredient table. The CSLib inventory and axiom profiles. The two finite-model-property refutations at ZTime (probe-level, cited through the context note, not re-run).

**Deploy-freshness note.** The dispatch records this repository's deployed `.claude/` tree as stale for six extensions (`core formal lean literature memory typst`). No deployed command or instruction was relied on beyond the Mathlib-lookup gate's resolution table, whose outcome here is forced by `file_scope = []` under any version of that table. No redeploy was run; none is needed for a paper-only dispatch. Recorded in `issues.jsonl`.

## Domain Analysis

**Logic (primary).** Almost everything below is logic: which schemata the engine consumes and where; how Reynolds' three languages (object CTL\*, PLTL, fresh-atom CTL\*) become three L⁺-side languages (object L⁺, two-sided PLTL over ℤ, L⁺-plus-fresh-atoms); how `E`/`A` become `⟐`/`⊡`; how a floored Ockhamist frame becomes a ℤ-levelled one with a clock anchor; and what the separated CNF buys. The decisive logical facts are the S5 cluster for `⊡` with `box_stab` and `atom_stab`, the pasting axioms PS/US, the `⊡ = ▷◁` factorization, and `LCU`'s segment guard.

**Math (secondary).** Three genuinely non-logical items. The acceptance-condition shape (inherited settled). The evaporating-graph combinatorics of Lemmas 21-22, which is pure finite graph theory and direction-blind. And the order/graph theory of the final frame: the quotient is a time-sliced digraph with countably infinite slices, its *Saturation* is a real obligation here (unlike in Reynolds' Kripke setting, which has no such axiom), and the route of record is its universal cover.

**No physics content.**

## Findings

### 0. The system, the semantics, and what is landed — re-verified this session

#### 0.1 The language and its truth clauses

L⁺ (`PlusLanguage/Formula.lean`, compiled) is the seven-constructor inductive `atom | bot | imp | box | untl | snce | stab`. Truth is at a pointed history (`PlusTruth.lean:84-93`, compiled, quoted exactly):

```
(.atom p)   M.valuation (τ.state t) p
(.bot)      False
(.imp φ ψ)  … → …
(.box φ)    ∀ σ : WorldHistory F, PlusTruthAt M σ t φ
(.untl ψ φ) ∃ s, t < s ∧ φ at s ∧ ∀ r, t < r → r < s → ψ at r
(.snce ψ φ) ∃ s, s < t ∧ φ at s ∧ ∀ r, s < r → r < t → ψ at r
(.stab φ)   ∀ σ, τ.state t = σ.state t → PlusTruthAt M σ t φ
```

So `⊡` is the *same-state-same-time* history quantifier and `□` the *unrestricted* one, `⟐φ := ¬⊡¬φ` (`dstab`, compiled). `untl`/`snce` are strict. At `FrameClass.ZTime` the duration order is `ℤ` and the frame is regular, i.e. satisfies *Compositionality*, *Seriality*, *Limit* and *Saturation* (`Semantics/TaskFrame.lean` docstring, read).

**The dictionary against Reynolds.** `E ↦ ⟐`, `A ↦ ⊡`, `X ↦ next`, `U ↦ untl`, `G ↦ allFuture`, `AG ↦ ⊡G≤` (`gle φ := φ ∧ Gφ`, compiled, `gle_iff` read). Four asymmetries, each load-bearing below:

| Reynolds | L⁺ at ZTime | Consequence |
|---|---|---|
| ω-tree, floored, past linear and finite | ℤ-levelled, no floor, past infinite and branching | the construction grows at two frontiers; `snce`-commitments exist |
| no counterpart to `□` | `□` global, `box_stab : □φ → ⊡φ` | `□`-formulas are state-level a fortiori; a `□A`-global `θ` would be unsound on the carrier |
| C15 `AXa → XAa` | PS/US pasting (`paste`, `untl_paste`) | pasting is *stronger*: it gives down-and-across **and** up-and-across **and** the full product |
| every formula future-directed | `snce` primitive; separation available | the cut split needs `sepZ`; Reynolds needs no separation |

#### 0.2 The schemata of TM⁺ that the engine uses, by name

Read at `PlusLanguage/Axioms.lean`: `stab_k` (`:285`, K for `⊡`), `stab_t` (`:288`, `⊡φ → φ`), `stab_4` (`:293`), `stab_5` (`:297`), `box_stab` (`:300`), `atom_stab` (`:304`, `p → ⊡p`), `paste` (`:308`, PS: `⟐φ⁺ → ⟐ψ⁻ → ⟐(φ⁺ ∧ ψ⁻)` for pure-future `φ⁺`, pure-past `ψ⁻`), `untl_paste` (`:312`, US: `(α⁻ U ⟐φ⁺) → ⟐(α⁻ U φ⁺)`), plus the full PLTL-shaped block (`left_mono_until_G`, `right_mono_until`, `connect_future`, `enrichment_until`, `self_accum_until`, `absorb_until`, `linear_until`, `until_F`, `temp_linearity`, `F_until_equiv` and their `snce`/past mirrors) and the ZTime arms `prior_UZ`, `prior_SZ`, `z1` (`minFrameClass` routes exactly these three to `.ZTime`, read at `:323-325`).

**Reynolds' C9-C15, matched.** C9 = `stab_k`; C10 = `stab_4`; C11 = `stab_t`; C12 (`a → AEa`) is the S5 B-axiom, a theorem of `stab_k/t/4/5`; C13 is the definition of `dstab`; C14 = `atom_stab`, extended to all `□`- and `⊡`-formulas by `box_stab` and `stab_4`; **C15 has no direct counterpart and is not needed** — its two uses in Reynolds (the contrapositive in Lemma 12 down-and-across, and the `XEζ → EXζ` step in Lemma 17's final claim) are both discharged here by PS/US pasting, which is strictly stronger. Derived; Finding 2.4 and Finding 10.5.

#### 0.3 The schema and rules of record, and their status

| Item | Status | Evidence |
|---|---|---|
| `lcU α β = ⊡G≤(⟐α → ⟐(⟐β U ⟐α)) → (⟐α → ⟐G≤(⟐α ∨ (⟐β U ⟐α)))` | **compiled** | `PlusLCSchema.lean:248` |
| `lcU_plusValidInt`, `lcU_plusValidZTime`, `lcU_reflectTime_plusValidZTime` | **compiled** | `PlusLCSchema.lean:409,464,486` |
| `lcN`, `lcN_plusValidZTime`, `lcN_reflectTime_plusValidZTime` | compiled | `PlusLCSchema.lean:226`, and the validity theorems |
| `clockAnte q`, `clock_irr_sound`, `irr_sound`, `Fresh` | compiled | `NamingRules.lean:190,317,345,115` |
| `aaAnte`, `aaStep`, `aaExcl`, `ExtDerivation`, `T1/T2/T3` | **probe only** (elaborated, not in the library) | `specs/879_…/probes/01_target-statements.lean:40-55,58-85,99-116` |
| `separationOver_ztime`, `sepZ`, `sepZ_sepClauses`, `plusTruthAt_sepZ_iff` | compiled | `SeparationZ/Discharge.lean:93,122,128,151` |
| `paste_valid`, `paste_valid'`, `truth_congr_agreeFrom`, `truth_congr_agreeUpTo`, `paste_agreeFrom`, `paste_agreeUpTo` | compiled | `PlusPasting.lean:334,350,281,306,259,271` |
| `completeness_ztime : WeakCompleteness FrameClass.ZTime`, `WeakCompleteness` | compiled | `StrongCompleteness.lean:1119`, `SetConsequence.lean:226` |
| `PlusAxiom.ofTMSubst`, `minFrameClass_ofTMSubst`, `PlusDerivationTree.ofTMSubst` | compiled | `Substitution.lean:155,184,199` |
| `StateLocal` with `stateLocal_stab`, `stateLocal_box`, `stateLocal_atom`, `not_stateLocal_untl` | compiled | `PlusStateLocal.lean:149,183,170,160,174` |
| `saturation_of_orientedForest`, `plus_invariance_of_isZTime` | compiled | `OrientedForest.lean:134`, `HistoryMorphism.lean:589` |
| universal cover; invariance with no *Saturation* on the base | **missing** | the two Lean pieces the final-frame step needs |

**Inventory correction.** The ingredient table of the programme report lists row 2 (`LCU` declared and ZTime-valid) as **missing**. It is landed, as the first two rows above show (grep + direct read this session). The ban-preservation lemma below therefore cites a compiled schema, not a proposal.

Throughout, `⊢` abbreviates `ExtDerivation FrameClass.ZTime IsLCUAxiom RuleSet.all`, and *consistent* means `⊬ ⋀Γ → ⊥` for every finite `Γ ⊆ ·`. For `LCU` and its mirror the two axiom instances are exactly `IsLCUAxiom`'s disjuncts (`ψ = lcU α β ∨ ψ = (lcU α β).reflectTime`, read).

### 1. The closure sets, with the separated CNF of every closure formula

Fix an L⁺ formula `φ` with `⊬ ¬φ`; let `L` be its atom set. Write `Sub(ψ)` for the subformula set.

#### 1.1 The pure-literal sets

`sepZ` (compiled, `Discharge.lean:122`) returns, for each `ψ`, a finite list of pairs; `sepZ_sepClauses` (compiled) certifies that each pair's first component is pure-past and second pure-future, and `plusTruthAt_sepZ_iff` (compiled) that `ψ ↔ ⋀_{c ∈ sepZ ψ}(c.1 ∨ c.2)` pointwise on every regular ZTime frame. Define

```
Lits(ψ)         := {c.1, c.2 : c ∈ sepZ ψ}
PastLits₀(X)    := ⋃_{ψ ∈ X} {c.1 : c ∈ sepZ ψ}      FutLits₀(X) := ⋃_{ψ ∈ X} {c.2 : c ∈ sepZ ψ}
PastLits(X)     := the closure of PastLits₀(X) under pure-past subformulas of its members
FutLits(X)      := the closure of FutLits₀(X) under pure-future subformulas of its members
```

both finite: `sepZ` returns a list and `X` below is finite, so `PastLits₀(X)`/`FutLits₀(X)` are
finite, and a finite set's subformula closure is finite, so the closure step preserves
finiteness and the alphabet stays finite.

**Why the closure is needed.** `pt ⊆ PastLits` records only which *top-level* `ᾱ` hold at the
cut, whereas Lemma 5.1 below works with `Λ⁻`, the set of pure-past linear subformulas of those
`ᾱ`, explicitly closed under subformulas. `sepZ`'s past components are S-only abstract formulas
with L⁺ leaves resubstituted (compiled, `Discharge.lean:93-117`), and their own pure-past
subformulas need not themselves be clause components of anything in `PastLits₀(X)`, so without
this closure step `pt` alone would not determine which members of `Λ⁻` hold at the cut. Taking
`PastLits(X)`/`FutLits(X)` to be the subformula closure, rather than the top-level set alone,
closes that gap at no cost beyond the (still finite) enlargement recorded above.

#### 1.2 One separation round suffices

**Lemma 1.1 (derived).** Let `α` be pure-past (`IsPurePast`, compiled at `Formula.lean:318`). Then the truth of `α` at `(τ,t)` depends only on `τ`'s restriction to times `≤ t`; dually for pure-future and `≥ t`.

*Proof.* This is `truth_congr_agreeUpTo` and `truth_congr_agreeFrom` (compiled, `PlusPasting.lean:306,281`), whose inductive arms admit `box` and `stab` as leaves precisely because the `box`/`stab` clauses do not mention the history at any other time. ∎

Consequently a literal of a separated clause needs no further separation for the purposes below: its truth at any time already factors through one side of that time. So the closure is built with **one** `sepZ` round, and no fixpoint iteration is required — a point worth stating because `sepZ` is an *algorithm* (a `def`, deliberately computable, read at `Discharge.lean:122`) and applying it to an already-separated formula returns clauses with a trivial component rather than a smaller formula.

#### 1.3 The three closure sets

```
cl₀(φ)  := Sub(φ) ∪ {¬ψ : ψ ∈ Sub(φ)} ∪ ⋃_{ψ ∈ Sub(φ)} Lits(ψ)                (finite)
PastLits := PastLits(cl₀(φ)),  FutLits := FutLits(cl₀(φ))                      (finite)
δ_a     := ⋀_{δ ∈ a} δ ∧ ⋀_{δ ∈ S \ a} ¬δ      for a ⊆ S, S finite            (fixed order)
cl(φ)   := cl₀(φ) ∪ {δ_pt : pt ⊆ PastLits} ∪ {δ_ft : ft ⊆ FutLits}
           closed under one negation                                            (finite)
ecl(φ)  := {⟐δ, ⟐¬δ : δ ∈ cl(φ)}                                               (finite)
```

Three comments, each a decision recorded in `## Decisions`.

- **Why the `δ_pt`, `δ_ft` are in the closure.** Reynolds' `ecl φ = {Eψ, E¬ψ : ψ ≤ φ}` records only *single* realizabilities. The cut needs *realized combinations* of the pure literals (Finding 4), and single realizabilities do not determine them: `⟐α₁ ∧ ⟐α₂` does not give `⟐(α₁ ∧ α₂)` for two pure-past literals (PS pastes a past against a *future*, not a past against a past). So the characteristic conjunctions must be closure members in their own right. Derived.
- **Why pairs `δ_{(pt,ft)}` are not needed.** The full-product lemma (Finding 4.2) says the realized `(pt, ft)` pairs at a colour form a product, so `PT` and `FT` separately determine the pairs. This collapses `2^{|PastLits|+|FutLits|}` extra closure members to `2^{|PastLits|} + 2^{|FutLits|}`. Derived.
- **`cl(φ)` is about `φ`, not `φ⁺`.** The automata and the Auxiliary-Atoms rule's state formulas must use atoms from `L` only — the rule's `hfresh` side condition (read: `∀ b ∈ Q, Fresh b φ ∧ ∀ i < k, Fresh b (a i)`) demands it. This is Reynolds' own division: his automaton reads subsets of `ecl φ` while his hues are over `fcl φ⁺`. The hue closure below is the only object built over `φ⁺`.

### 2. Hues, colours, and the state formula of a colour

#### 2.1 The hue closure

With `φ⁺` as in Finding 6 (its definition does not depend on this subsection),

```
fcl(φ⁺) := {ψ, ¬ψ, ⟐ψ, ¬⟐ψ, ⟐¬ψ, ¬⟐¬ψ : ψ ∈ Sub(φ⁺)}                 (finite)
C       := 𝒫(𝒫(fcl φ⁺))            — the set of φ⁺-colours
γ_c     := ⋀_{a ∈ c} ⟐δ_a ∧ ⋀_{a ∉ c} ¬⟐δ_a        for c ∈ C
h(a,c)  := {δ : δ ∈ a} ∪ {¬δ : δ ∈ fcl(φ⁺) \ a} ∪ {⟐δ_b : b ∈ c} ∪ {¬⟐δ_b : b ∉ c}   for a ∈ c
hcl(φ⁺) := {δ, ¬δ : δ ∈ fcl φ⁺} ∪ {⟐δ_a, ¬⟐δ_a : a ⊆ fcl φ⁺}
H(φ⁺)   := {h(a,c) : a ∈ c ∈ C}
```

A *hue* is a member of `H(φ⁺)`; it is *consistent* iff consistent as a formula set. A *colour* `c` is consistent iff `γ_c` is.

#### 2.2 The four hue lemmas, transposed

**Lemma 2.1 (= Reynolds Lemma 8; derived).** Each hue is a hue of exactly one colour, and `h* = {b ⊆ 𝒫(fcl φ⁺) : ⟐δ_b ∈ h}`.

*Proof.* Reynolds' length argument transposes verbatim (held, `sec05:67-85`). With `|φ⁺| = n`, every member of `fcl(φ⁺)` has length at most `n + 4` (one negation plus one `⟐`, which is `¬⊡¬`), while `φ⁺, ¬φ⁺, ⟐φ⁺, ¬⟐φ⁺, ⟐¬φ⁺, ¬⟐¬φ⁺` are six distinct members of `fcl(φ⁺)` each contributing itself or its negation as a separate conjunct of `δ_a`, so `|⟐δ_a| ≥ 6n + c` for a fixed small `c` — hence `⟐δ_a ∉ fcl(φ⁺)` and the ambiguity Reynolds eliminates cannot arise. ∎

**Lemma 2.2 (= Reynolds Lemma 11(1); derived).** Consistent hues of the same colour agree on atoms, on `⟐`-formulas and on `□`-formulas.

*Proof.* Atoms: `atom_stab` (`p → ⊡p`) and `stab_t` give `⊢ p ↔ ⊡p`, and `⊡p` is decided by the colour's `⟐δ_b` conjuncts. `⟐`-formulas: `stab_4`/`stab_5` give `⊢ ⟐ψ → ⊡⟐ψ`, so `⟐ψ` is `⊡`-stable and again colour-decided. `□`-formulas: `box_stab` plus `stab_4` give `⊢ □ψ → ⊡□ψ`. ∎

**Lemma 2.3 (= Reynolds Lemma 11(2); derived).** If `h` is a consistent hue then `h*` is consistent and every hue of `h*` is consistent. (Reynolds' proof: extend to an MCS, use C9-C14; here the S5 cluster plus Lemma 2.2.)

**Lemma 2.4 (= Reynolds Lemma 10; derived).** A consistent hue is maximally consistent in `hcl(φ⁺)`.

#### 2.3 `γ_c` is a state formula, and the alphabet's two tautologies

**Lemma 2.5 (derived + compiled).** `γ_c` is `StateLocal`. Hence `⊢ γ_c ↔ ⊡γ_c`.

*Proof.* `γ_c` is a Boolean combination of `⟐δ_a = ¬⊡¬δ_a`. `StateLocal` (compiled, `PlusStateLocal.lean:149`) admits `atom`, `bot`, `imp` componentwise, and `box`/`stab` with an **arbitrary** argument (`stateLocal_box` `:170`, `stateLocal_stab` `:183`); only `untl`/`snce` are excluded (`not_stateLocal_untl` `:174`). Every leaf of `γ_c` is a `stab`. ∎

**Lemma 2.6 (derived).** Let `Ĉ := {ĉ : ĉ ⊆ ecl(φ)}` be the automaton alphabet and `γ̂_ĉ := ⋀_{e ∈ ĉ} e ∧ ⋀_{e ∈ ecl(φ) \ ĉ} ¬e`. Then

1. `⊢ ⋁_{ĉ ∈ Ĉ} γ̂_ĉ`  (exhaustiveness), and
2. `⊢ ¬(γ̂_ĉ ∧ γ̂_{ĉ'})` for `ĉ ≠ ĉ'`  (exclusivity),

each a substitution instance of a classical tautology in the `|ecl(φ)|` letters; and each `γ̂_ĉ` is `StateLocal` by Lemma 2.5's argument, and uses atoms from `L` only.

These are exactly the `hexh`, `hexcl` and `hsl` side conditions of `aaFwd`/`aaBwd` (read verbatim in the probe: `hexh : ExtDerivation … (bigOr k a)`, `hexcl : ∀ i < k, ∀ j < k, i ≠ j → ExtDerivation … ((a i).and (a j)).neg`, `hsl : ∀ i < k, PlusFormula.StateLocal (a i)`). The alphabet of the automata is `Ĉ`; the *letter of a colour* `c ∈ C` is `ĉ(c) := {e ∈ ecl(φ) : ⊢ γ_c → e}`, equivalently `{⟐δ : δ ∈ cl(φ), ⟐δ ∈ h for some/every hue h of c}` by Lemma 2.2.

### 3. The linear language, the bar-translation, and the bad-word formula

#### 3.1 Two-sided PLTL over ℤ

The *linear language* is the `untl`/`snce` fragment of L (i.e. L⁺ with no `box`, no `stab` other than as a sentence letter), over the sentence-letter set `ecl(φ)`. Its models are ℤ-indexed words over `𝒫(ecl φ)`, i.e. elements of `Ĉ^ℤ`. Writing `X`, `Y`, `F`, `P`, `G`, `H` for the derived operators and `△ψ := Hψ ∧ ψ ∧ Gψ`, the fragment is exactly the language in which `completeness_ztime` is complete (compiled, for the base `Formula` type).

#### 3.2 The bar-translation

For `δ ∈ cl(φ)` define `δ̄` by recursion, taking the maximal `⟐`- and `□`-subformulas as letters:

```
p̄ := ⟐p  (p ∈ L)     ⊥̄ := ⊥     (ψ → χ)‾ := ψ̄ → χ̄
(ψ U χ)‾ := ψ̄ U χ̄    (ψ S χ)‾ := ψ̄ S χ̄     (⟐ψ)‾ := the letter ⟐ψ     (□ψ)‾ := the letter ⟐□ψ
```

(`□ψ` is folded to the letter `⟐□ψ`, which is interchangeable with `□ψ` by `box_stab` and `stab_t`.)

**Lemma 3.1 (derived).** `(·)‾` maps `IsPurePast` closure formulas to pure-past linear formulas (no `U` outside a letter) and `IsPureFuture` ones to pure-future linear formulas.

*Proof.* `IsPurePast` (compiled, `Formula.lean:318`) has arms `atom`, `bot`, `imp`, `box` (leaf, arbitrary argument), `stab` (leaf), `snce`; the translation sends the first three componentwise, the two leaf arms to letters, and `snce` to `S`. Dually. ∎

**Lemma 3.2 (derived).** For every `δ ∈ cl(φ)`, `⊢ δ̄[⟐·] ↔ δ`, where `[⟐·]` substitutes each letter by the L⁺ formula it names.

*Proof.* Induction on `δ`. Atoms: `⊢ p ↔ ⟐p` by `atom_stab` and `stab_t`. Leaves: identity. Booleans: propositional. `untl`/`snce`: congruence under provable equivalence, available from `left_mono_until_G`, `right_mono_until` and their past mirrors together with G- and H-necessitation (`tnec` and `refl ∘ tnec` in `ExtDerivation`, read). ∎

#### 3.3 The bad-word formula

```
χ̄₀ := ⋀_{γ ∈ cl(φ)} △(γ̄ → ⟐γ)
```

a formula of the linear language (`⟐γ` is a letter, since `γ ∈ cl(φ)` gives `⟐γ ∈ ecl(φ)`). A word `w ∈ Ĉ^ℤ` is **bad** iff `w ⊭ χ̄₀` at 0, i.e. iff at some `i ∈ ℤ` some `γ ∈ cl(φ)` has `γ̄` true at `i` while `⟐γ ∉ w(i)`.

This is Reynolds' `χ₀ = AG ⋀_{γ ∈ cl φ}(γ̄ → Eγ)` (held, `sec04:82-85`) with two changes: `△` for `G` (the quantification is over all of `ℤ`, not just the future, because walks are bi-infinite), and `cl(φ)` enlarged per Finding 1.3. Badness is the exact obstacle to the `⟐` (⇐) case of the truth lemma, as Finding 14.3 shows.

**Note on `△` versus the one-sided split.** `χ̄₀` is a bi-infinite-word condition and ω-automata read one-sided words. Finding 5 splits it at the cut; the splitting device is the separated CNF, and it is the only reason separation appears in this engine at all.

### 4. The cut: types, the full-product lemma, and what the letter must record

Fix the anchor. By `clockAnte q` (compiled, `NamingRules.lean:190`) the fresh atom `q` names exactly one time on every history through the current state, `⊡`-rigidly (`once q` and `rigid q`, read); normalise it to `0`. Write `w₀` for the anchor state and `c₀` for the anchor colour.

#### 4.1 Past-types and future-types

For a history `τ` through `w₀` at `0`,

```
pt(τ) := {α ∈ PastLits : α true at (τ, 0)}      ft(τ) := {β ∈ FutLits : β true at (τ, 0)}
PT(c₀) := {pt(τ) : τ through w₀ at 0}           FT(c₀) := {ft(τ) : τ through w₀ at 0}
```

By Lemma 1.1, `pt(τ)` depends only on `τ↾(−∞,0]` and `ft(τ)` only on `τ↾[0,∞)`.

**Lemma 4.1 (derived).** `PT(c₀) = {a ∩ PastLits : a ∈ c₀}` and `FT(c₀) = {a ∩ FutLits : a ∈ c₀}`; both are determined by `c₀`, hence by the state `w₀`, hence expressible by the state formula `γ_{c₀}`.

*Proof.* A hue of `c₀` is exactly the fcl-type of some history through `w₀` at `0` (K3A/K3B below, and Lemma 2.4 for maximality); restrict to `PastLits ⊆ cl₀(φ) ⊆ fcl(φ⁺)`. ∎

#### 4.2 The full-product lemma

**Lemma 4.2 (the full-product lemma; derived from compiled cores).** `{(a ∩ PastLits, a ∩ FutLits) : a ∈ c₀} = PT(c₀) × FT(c₀)`.

*Proof.* `⊆` is Lemma 4.1. For `⊇`, let `pt = pt(ρ)` and `ft = ft(σ)` with `ρ, σ` both through `w₀` at `0`. Then `ρ.state 0 = σ.state 0`, so `paste ρ σ 0` is defined (compiled, `PlusPasting.lean:136`) and `paste_agreeUpTo`/`paste_agreeFrom` (compiled, `:271,259`) give agreement with `ρ` up to and including `0` and with `σ` from `0` on. By `truth_congr_agreeUpTo` every `α ∈ PastLits` has the same truth value at `(paste ρ σ 0, 0)` as at `(ρ, 0)`, and by `truth_congr_agreeFrom` every `β ∈ FutLits` the same as at `(σ, 0)`. So the pasted history realizes `(pt, ft)`, and it passes through `w₀` at `0`, so its fcl-type is a hue of `c₀`. ∎

**Lemma 4.3 (the hue is a function of its type pair; derived).** For `a, a' ∈ c₀`, if `a ∩ PastLits = a' ∩ PastLits` and `a ∩ FutLits = a' ∩ FutLits` then `a = a'`.

*Proof.* Let `δ ∈ fcl(φ⁺)`. If `δ` is a `⟐`- or `□`-formula it is colour-decided (Lemma 2.2) and both hues agree. Otherwise `δ`'s truth at `0` is, by `plusTruthAt_sepZ_iff` (compiled), equivalent to `⋀_{c ∈ sepZ δ}(c.1 ∨ c.2)`; by the closure's construction (Finding 1.3) every `c.1 ∈ PastLits` and `c.2 ∈ FutLits`; by Lemma 1.1 their truth values at `0` are exactly the two restrictions, which agree. ∎

Lemmas 4.2 and 4.3 together say: **the hue set of a colour is the product `PT × FT`, with the hue recoverable from the pair.** This is the refinement 879 located as "the cluster's `(pt, ft)` set is a full product", stated here with the use it is put to.

#### 4.3 Where separation is consumed, precisely

Two distinct consumptions, named once each:

- **(S1) Finiteness and state-locality of the cut index.** Without separation, the truth of a closure formula at a position `i ≥ 0` is a function of the whole bi-infinite word and does not factor; the "past at the cut" relevant to it is then not a finite datum and no state formula names it. With separation it factors through `pt ⊆ PastLits`, a subset of a fixed finite set, and by Lemma 4.1 the *realized set* of such subsets is a function of the state. This is what makes the forward automaton a finite object and the index nameable. Consumes `separationOver_ztime` / `sepZ_sepClauses` / `plusTruthAt_sepZ_iff` (compiled).
- **(S2) Derivability of conditional badness.** Finding 7.3's `⊢ χ̄₀[⟐·]` is the theorem that licences running the forward automaton on *every* certified `pt`, not only on the walk's own. Its proof is PS/US pasting, not separation — but its *statement* is only formulable because (S1) makes `pt` a finite index. So separation is a precondition of (S2) and pasting is its content.

Without (S1) the architecture has no finite automaton; without (S2) it has one whose non-acceptance demand is not provably consistent. 879's single consumption point is the conjunction of the two.

#### 4.4 What the cut letter must record

By Lemmas 4.1-4.3, the cut letter `ĉ(c₀)` must determine `PT(c₀)` and `FT(c₀)`, which by Finding 1.3's closure enlargement it does:

```
PT(c₀) = {pt ⊆ PastLits : ⟐δ_pt ∈ ĉ(c₀)}        FT(c₀) = {ft ⊆ FutLits : ⟐δ_ft ∈ ĉ(c₀)}
```

because `δ_pt, δ_ft ∈ cl(φ)` and hence `⟐δ_pt, ⟐δ_ft ∈ ecl(φ)`. No further enlargement is needed, and by Lemma 4.2 no pair-indexed letters are needed.

### 5. The two deterministic Rabin automata over colour words

#### 5.1 The forward violation language

For `pt ⊆ PastLits` and a one-sided word `v = (v_0, v_1, …) ∈ Ĉ^ω`, say `v` has a **forward violation at `i ≥ 0` under `pt`** iff for some `γ ∈ cl(φ)`: `γ̄` is true at position `i` of the bi-infinite word whose forward half is `v` and whose cut past-type is `pt`, while `⟐γ ∉ v_i`.

That this is well defined — that `pt` plus `v` suffices — is the content of:

**Lemma 5.1 (the one-step unrolling; derived).** Let `Λ⁻` be the (finite) set of pure-past linear subformulas of the `ᾱ` for `α ∈ PastLits`, closed under subformulas. Define the *running past-type* `Π_i ⊆ Λ⁻` as the set of members true at position `i`. Then, because `PastLits` is itself the closure of its top-level members under pure-past subformulas (Finding 1.1), `Π_0` is determined by `pt` and `v_0`, and for `i ≥ 0`

```
(ψ S χ) ∈ Π_{i+1}  ⟺  χ ∈ Π_i  or  (ψ ∈ Π_i  and  (ψ S χ) ∈ Π_i)
(Y χ)   ∈ Π_{i+1}  ⟺  χ ∈ Π_i
e       ∈ Π_{i+1}  ⟺  e ∈ v_{i+1}                      (e a letter)
```

and the Boolean cases componentwise. Hence `Π_{i+1}` is a function of `Π_i` and `v_i, v_{i+1}` alone: the running past-type is computed by a **deterministic finite transducer** initialised from `pt`.

*Proof.* The `S` clause: `(ψ S χ)` at `i+1` iff `∃ s < i+1` with `χ` at `s` and `ψ` on `(s, i+1)`. Either `s = i`, giving `χ ∈ Π_i` with an empty interval; or `s < i`, which needs `ψ` at `i` and `ψ` on `(s,i)`, i.e. `ψ ∈ Π_i` and `(ψ S χ) ∈ Π_i`. The step to `i+1` from `i` exists because the duration order is `ℤ`, i.e. discrete — the frame-class fact that `prior_UZ`, `prior_SZ`, `z1` axiomatise (read, `Axioms.lean:252-261`). ∎

**Formulation guard.** This determinacy claim must not be read as making the forward-violation condition consult `Π_0` (or any running past-type) for a `γ̄` that is pure in the automaton's own forward-reading direction: such a `γ̄`'s truth at position `0` is, by Lemma 3.1, independent of `Π_0` and of any cut past-type altogether, depending only on `v`. This blindness — a pure-future translation's truth at `0` does not depend on which past-type is hypothesized at the cut — is exactly what later licenses treating a certified-but-possibly-wrong past-type as already sufficient to extract that fact at position `0`.

**Lemma 5.2 (ω-regularity; derived + held).** For each `pt`, the set `Viol⁺_pt := {v ∈ Ĉ^ω : v has a forward violation at some i ≥ 0 under pt}` is ω-regular.

*Proof.* `γ̄` at position `i` is, by `plusTruthAt_sepZ_iff` and Lemma 3.1, a Boolean combination of pure-past literal translations `ᾱ` (whose truth at `i` is `α ∈ Π_i`, computed deterministically by Lemma 5.1) and pure-future literal translations `β̄` (whose truth at `i` depends only on `v↾[i,∞)`, and is an LTL condition over the letters). So "violation at `i`" is a Boolean combination of a deterministic-transducer state and a finite set of future LTL obligations; "violation at some `i ≥ 0`" is their union over `i`. Each future obligation is LTL, hence ω-regular; the finite Boolean combination and the `∃i` are ω-regular closures. ∎

#### 5.2 The forward automaton

```
Viol⁺ := {v ∈ Ĉ^ω :  ∃ pt with ⟐δ_pt ∈ v_0 and v ∈ Viol⁺_pt }
```

where `ft_lin(v) := {β ∈ FutLits : β̄ true at position 0 of v}` (well defined: `β̄` is pure-future by Lemma 3.1, so its truth at `0` depends only on `v`).

`Viol⁺` is the forward half of badness, with the index taken over exactly the certified past-types; it is ω-regular by Lemma 5.2 alone.

**Theorem 1 (the elimination; derived).** For `v ∈ Ĉ^ω` whose first letter certifies at least one past-type (`∃ pt ⊆ PastLits` with `⟐δ_pt ∈ v_0`), the condition `⟐δ_{ft_lin(v)} ∉ v_0` already implies `v ∈ Viol⁺_pt`, i.e. membership in the clause-(b)-only `Viol⁺` above. Dually for the backward direction.

*Proof.* Set `γ := δ_{ft_lin(v)}`. Then `γ ∈ cl(φ)` (Finding 1.3), and `γ` is pure-future: it is a conjunction of `FutLits`-members and their negations, each a future component of a `sepZ` clause and so `IsPureFuture`, and `IsPureFuture` is closed under `imp` and has `bot` (compiled, `Formula.lean:309-316`), hence closed under negation and conjunction. By Lemma 3.1 the bar-translation sends this closure to pure-future *linear* formulas, so `γ̄`'s truth at position `0` is a condition on `v` alone — it consults no pure-past subformula value, in particular not the hypothetical cut past-type `pt` that clause (b) ranges over (that hypothetical value is all `Π_0` controls, Lemma 5.1). And `γ̄` is true at `0` of `v` by construction: `γ̄ = ⋀_{β ∈ ft_lin(v)} β̄ ∧ ⋀_{β ∈ FutLits \ ft_lin(v)} ¬β̄`, and `ft_lin(v)` is exactly the set of `β` with `β̄` true at `0`. So, for the certified `pt`, `γ̄` is true at `i = 0` of the bi-infinite word with forward half `v` and cut past-type `pt`, while `⟐γ ∉ v_0` by hypothesis — a forward violation at `i = 0` under `pt`. Hence `v ∈ Viol⁺_pt`. ∎ The mirror is the `reflectTime` image, using `IsPurePast`'s closure under `imp`/`bot` (compiled, `Formula.lean:318-325`) in place of `IsPureFuture`'s.

A certified-but-possibly-wrong past-type is therefore already a usable ticket into clause (b) for a `γ` pure in the automaton's own reading direction: clause (b)'s evaluation of such a `γ̄` is blind to which `pt` is hypothesized, so the dropped clause's instance is subsumed rather than lost — this is why the clause-(b)-only definition above loses nothing that the hypothesis covers.

**Strictness.** The inclusion needs the first-letter certification hypothesis: on a word whose first letter certifies no past-type at all, the clause-(b)-only `Viol⁺` is empty while the superseded two-clause form could still fire on its dropped clause, so the recognized language strictly shrinks; this is recorded honestly rather than claimed as a lossless rewrite.

By Theorem 2 (held, `sec02:…`, citing McNaughton and Safra) and the inherited settled verdict that **Rabin, not Muller, is the acceptance type the ban mechanism consumes**, fix a deterministic Rabin automaton

```
A⁺ = (Q⁺, s₀⁺, ρ⁺, {(U⁺_1, V⁺_1), …, (U⁺_{K⁺}, V⁺_{K⁺})})
```

over the alphabet `Ĉ`, accepting exactly `Viol⁺`, with `Q⁺ ∩ (L ∪ ecl(φ)) = ∅` and each `U⁺_i ∩ V⁺_i = ∅` (the normalisation is free: replace `U` by `U \ V`, held, `sec02`).

#### 5.3 The backward automaton

Mirror everything under `reflectTime` (compiled involution, `Formula.lean:reflect_time_involution`): `Viol⁻` reads the backward half `(v_0, v_{-1}, v_{-2}, …)` and is stated in the same clause-(b)-only form, with its violations over positions `i ≤ 0` and its index ranging over certified future-types. Theorem 1's mirror licenses the same elimination here: for a `γ̄` pure-past — pure in the backward automaton's own reading direction — truth at position `0` of the backward word is a condition on `(v_0, v_{-1}, …)` alone, blind to which future-type `ft` is hypothesized at the cut, so the instance `γ := δ_{pt_lin(v)}` (`⟐δ_{pt_lin(v)} ∉ v_0`) is subsumed by clause (b) exactly as above, under the dual first-letter certification hypothesis and with the dual strictness caveat. Fix a deterministic Rabin `A⁻ = (Q⁻, s₀⁻, ρ⁻, {(U⁻_i, V⁻_i)}_{i ≤ K⁻})`, `Q⁻` disjoint from everything else.

#### 5.4 The cut indexing is folded into the first transition

Define `ρ⁺(s₀⁺, ĉ)` to be the initial state of the sub-automaton of `A⁺` that has already resolved `{pt : ⟐δ_pt ∈ ĉ}`. This is legitimate because the index set is a function of the letter (Finding 4.4) and the automaton is deterministic.

**Consequence.** The Auxiliary-Atoms rule needs only a *single fixed* initial-state atom `b₀⁺ := s₀⁺`, and `aaAnte b₀ Q k a p` (read verbatim in the probe) is used **unchanged**. This replaces the architecture's earlier reading, on which the initial state had to be "a function of `γ_{colour(w₀)}`" and `θ_f` had to state it. Derived; recorded as a decision.

#### 5.5 The acceptance formulas

With `u⁺_i := ⋁_{s ∈ U⁺_i} s` and `v⁺_i := ⋁_{s ∈ V⁺_i} s` (`Q⁺`-atoms, hence state-local by `atom_stab`),

```
χ₁⁺ := ⋁_{i=1}^{K⁺} (G F ¬… )   — precisely:  ⋁_{i=1}^{K⁺} ( FG ¬v⁺_i  ∧  GF u⁺_i )
χ₁⁻ := the reflectTime mirror:    ⋁_{i=1}^{K⁻} ( HP ¬v⁻_i  ∧  PH u⁻_i )  — i.e. (χ₁⁻-shape)ʳ
```

where `FG ψ := F(Gψ)`, `GF ψ := G(Fψ)` are the L⁺ derived operators along the evaluation history and `HP`, `PH` their past mirrors. `χ₁⁺` says "the forward automaton accepts the forward half of the evaluation history"; `χ₁⁻` the mirror. Each lies in the `{GF, FG}` Boolean fragment, which is the fragment the acceptance-condition question was settled in (inherited).

### 6. The fresh-atom language, `θ_f`, `θ_b`, and `φ⁺`

The third language is L⁺ over `L ∪ Q⁺ ∪ Q⁻ ∪ {q}`. Enumerate `Ĉ = {ĉ_1, …, ĉ_k}` and put `a_i := γ̂_{ĉ_i}` (Lemma 2.6). With `p⁺(s, i) := ρ⁺(s, ĉ_i)` and `p⁻(s,i) := ρ⁻(s, ĉ_i)`:

```
θ_f := aaAnte s₀⁺ Q⁺ k a p⁺
     = s₀⁺ ∧ ⊡G≤ ⋀_{b ∈ Q⁺, i < k}((b ∧ a_i) → ⊡X p⁺(b,i)) ∧ ⊡G≤ ⋀_{b ≠ b'}¬(b ∧ b')
θ_b := (aaAnte s₀⁻ Q⁻ k a p⁻).reflectTime
φ⁺  := clockAnte q ∧ θ_f ∧ θ_b ∧ φ ∧ ⊡¬χ₁⁺ ∧ ⊡¬χ₁⁻
```

Five points.

- **Anchoring, not globalising.** `θ_f` is anchored at the evaluation point with `⊡G≤`, not with a `□`-global prefix. This is forced: on the two-layer carrier the verbatim layer has `inl u → inr (v,h)` for every `h`, so a `□A`-global `θ` is refuted there (carried from the architecture's Finding 2.4; the probe-level `aa_expand` establishes the run on the forward cone only). The `reflectTime` of `⊡G≤` is `⊡H≤`, which anchors `θ_b` on the backward cone.
- **`θ_f` is `⊡`-stable.** `⊢ θ_f → ⊡θ_f`, by `atom_stab` on the conjunct `s₀⁺` and `stab_4` on the two `⊡`-conjuncts. Used in Finding 7.4.
- **Both halves of non-acceptance are explicit.** `⊡¬χ₁⁺ ∧ ⊡¬χ₁⁻` rather than a single `⊡¬χ₁`. Each is required *at the anchor only*: every bi-infinite walk passes through `w₀` at time `0` exactly once (by `clockAnte`), so `⊡¬χ₁⁺` at the anchor says precisely "no walk's forward half is accepted", and dually. Finding 11.2 shows why demanding either at any other point would be both unnecessary and unobtainable.
- **Freshness.** `q`, `Q⁺`, `Q⁻` are pairwise disjoint and fresh in `φ` and in every `a_i` (the `a_i` use atoms from `L` only, Lemma 2.6), discharging `hfresh` and the `clock` rule's `hq`.
- **The two-sided hinge is forced by the rule inventory, not chosen.** `aaAnte` names a run in **one direction**: an initial-state atom at the evaluation point propagated along `⊡G≤`. `ExtDerivation`'s rule set offers exactly this and its `reflectTime` mirror `⊡H≤`, and nothing else; no constructor names a bi-infinite run as a single family of fresh atoms. A bi-infinite automaton therefore could not be put inside L⁺ by the Auxiliary-Atoms rule regardless of what ω-automata theory supplies — the two-sided pair `θ_f`/`θ_b` above, hinged at the cut `clockAnte q` supplies, is the general reason the engine is two-sided rather than bi-infinite, not a workaround (`specs/905_eliminate_cross_certification_two_sided_reynolds_automata/reports/01_eliminate-cross-certification-clauses.md`, Finding 4(i); derived there from this repository's rule inventory, Finding 16.3).

### 7. Lemma 7⁺: consistency of `φ⁺`, via the linear bridge and the three rules

**Lemma 7⁺ (derived).** If `φ` is consistent then so is `φ⁺`.

The proof is Reynolds' three claims, doubled, with one new ingredient (the linear bridge) stated separately because it is used twice.

#### 7.1 The linear bridge

**Lemma 7.1 (the linear bridge; derived from compiled cores).** Let `ψ` be a formula of the linear language (Finding 3.1) that is valid on every history of every regular ZTime frame when its letters are read as atoms. Then `⊢ ψ[σ]` for every substitution `σ` of L⁺ formulas for the letters.

*Proof.* `ψ` is a `Formula` (base language: no `box`, no `stab` — the letters are atoms). Its validity hypothesis is `ValidIn FrameClass.ZTime ψ`, so `completeness_ztime : WeakCompleteness FrameClass.ZTime` (compiled, `StrongCompleteness.lean:1119`, unfolding to `∀ ψ, ValidIn fc ψ → Derivable fc [] ψ` at `SetConsequence.lean:226`) gives `Derivable FrameClass.ZTime [] ψ`. Then `PlusDerivationTree.ofTMSubst` (compiled, `Substitution.lean:199`) transports to `PlusDerivable FrameClass.ZTime [] (substPlus σ ψ)`, at the *same* frame class by `minFrameClass_ofTMSubst` (compiled, `:184`). Finally `ExtDerivation.tm` (read, the probe) injects every TM⁺ theorem. ∎

This is the two-line bridge the architecture filed as an ingredient; it is stated here because it carries **two** loads: Claim 1⁺ below, and the derivability of the separated CNF (Lemma 7.2).

**Lemma 7.2 (derivable separation; derived).** For every `δ ∈ cl(φ)`, `⊢ δ ↔ ⋀_{c ∈ sepZ δ}(c.1 ∨ c.2)`.

*Proof.* `sepZ` is computed by leaf-abstraction, separation of the abstracted `U`/`S` formula, packaging, and resubstitution (read, `Discharge.lean:122`). The abstracted equivalence is a validity of the *base* language over `ℤ` (its leaves are abstract letters), namely the one `usTruth_sep_iff` and `usTruth_sepFormUS_package` certify (read, `Discharge.lean:137-143`); by Lemma 7.1 it is derivable under the substitution that returns the actual `⊡`/`□`-leaves. ∎

**Why this matters.** `plusTruthAt_sepZ_iff` is a *semantic* theorem about ZTime frames; the completeness proof cannot help itself to the semantic separation of L⁺ formulas without circularity (that would presuppose the L⁺ ZTime completeness being proved). Lemma 7.2 is the non-circular form: the separation is an L-validity *about the leaf abstraction*, and the bridge lifts it. Derived; recorded as a decision.

#### 7.2 Claim 1⁺: the linear claim

**Claim 1⁺ (derived).** In the linear language,

```
⊨_ℤ  ( χ̄₁⁺  ∧  s₀⁺  ∧  G≤ ⋀_{b ∈ Q⁺, i<k}((b ∧ a_i) → X p⁺(b,i))  ∧  G≤ ⋀_{b≠b'} ¬(b ∧ b') )
      →  ¬⋀_{pt ⊆ PastLits}(⟐δ_pt → ⋀_{γ ∈ cl(φ)} G≤(γ̄^{pt} → ⟐γ))
```

read at `0`, where `χ̄₁⁺` is `χ₁⁺` read linearly. The consequent is the **conditional** bad-word
conjunction over every certified past-type `pt ⊆ PastLits` (`γ̄^{pt}` as in Finding 7.3: `γ̄` with
its pure-past literals' values at the cut fixed to `pt`), not the real-word form `¬χ̄₀⁺` (with
`χ̄₀⁺ := ⋀_{γ ∈ cl(φ)} G≤(γ̄ → ⟐γ)`) a superseded statement of this claim used in its place — the
clause-(b)-only `Viol⁺` the proof below consumes certifies a hypothetical `pt`, not necessarily
the word's own, so only the conditional form follows.

*Proof.* Reynolds' Claim 1 (held, `sec04:153-200`), with the induction anchored at `0` rather than at a floor. Let `w` be a ℤ-word satisfying the antecedent at `0`, and let `(s_0, s_1, …)` be the run of `A⁺` on `(w_0, w_1, …)`, i.e. `s_0 = s₀⁺` and `s_{i+1} = ρ⁺(s_i, w_i)`. Show by induction on `i ≥ 0` that `s ∈ w_i ⟺ s = s_i` for `s ∈ Q⁺`. The `⟸` direction at `i = 0` is the conjunct `s₀⁺`; at `i+1`, the step clause applies with the unique `i`-th letter `a_{j}` such that `w_i ⊨ a_j` (unique by exclusivity, existent by exhaustiveness, Lemma 2.6), giving `p⁺(s_i, j) = ρ⁺(s_i, ĉ_j) = s_{i+1} ∈ w_{i+1}`; the `⟹` direction then follows from the mutual-exclusivity conjunct. Since `w ⊨ χ̄₁⁺` there is `i ≤ K⁺` with no `V⁺_i`-atom infinitely often and some `U⁺_i`-atom infinitely often in `(w_j)_{j ≥ 0}`, hence the same of the run, hence `A⁺` accepts `(w_0, w_1, …)`, hence that word lies in `Viol⁺`. By `Viol⁺`'s clause-(b)-only definition (Finding 5.2) there is `pt ⊆ PastLits` with `⟐δ_pt ∈ w_0` and `(w_0, w_1, …) ∈ Viol⁺_pt`, i.e. some `γ ∈ cl(φ)` has `γ̄^{pt}` true at some `i ≥ 0` with `⟐γ ∉ w_i`. This falsifies the `pt`-th conjunct of `⋀_{pt ⊆ PastLits}(⟐δ_pt → ⋀_{γ ∈ cl(φ)} G≤(γ̄^{pt} → ⟐γ))` at `0` (its antecedent `⟐δ_pt` holds at `w_0`, and its consequent fails at `i`), i.e. `w ⊨ ¬⋀_{pt ⊆ PastLits}(⟐δ_pt → ⋀_{γ ∈ cl(φ)} G≤(γ̄^{pt} → ⟐γ))`. ∎

The mirror, **Claim 1⁻**, is the `reflectTime` image: same statement with `H≤`, `Y`, `A⁻`, `χ̄₁⁻`, induction over `i ≤ 0`, and consequent the negation of `⋀_{ft ⊆ FutLits}(⟐δ_ft → ⋀_{γ ∈ cl(φ)} H≤(γ̄^{ft} → ⟐γ))` read at `0`, indexed over certified future-types rather than certified past-types (the backward automaton's clause (b), Finding 5.3).

**Why this repair was always needed.** The mismatch between Claim 1⁺'s consequent and what its proof can establish pre-dates this task's elimination of `Viol⁺`'s first, now-dropped disjunct: that disjunct's branch (`γ := δ_{ft_lin(w)}` at `i = 0`) was the *one* branch of the superseded two-disjunct `Viol⁺` that produced a real-word violation, so as long as that branch was present it masked the mismatch on every run that took it. Dropping the disjunct does not create the defect; it removes the one branch that was hiding it, which is why the repair above is required independently of the elimination and not a cost the elimination itself incurs.

#### 7.3 `⊢ χ̄₀[⟐·]`: conditional badness is a theorem, by pasting

**Lemma 7.3 (derived).** `⊢ ⋀_{γ ∈ cl(φ)} ⊡G≤(γ̄[⟐·] → ⟐γ)` and its past mirror; hence `⊢ χ̄₀[⟐·]` read at the anchor.

*Proof.* Fix `γ ∈ cl(φ)`. By Lemma 3.2, `⊢ γ̄[⟐·] ↔ γ`. By `stab_t`'s contrapositive, `⊢ γ → ⟐γ`. So `⊢ γ̄[⟐·] → ⟐γ`, and the `⊡G≤`-prefix follows by G-necessitation (`tnec`) and `⊡`-necessitation (`nec` plus `box_stab`); the `⊡H≤` mirror by `refl`.

This is the *unconditional* form. The **conditional** form — the one the automaton's clause (b) needs, where `γ̄` is computed from a *certified* `pt` rather than from the evaluation history's own past — is where pasting enters. Write `γ̄^{pt}` for `γ̄` with its pure-past literals' values at the cut fixed to `pt`. Then

```
⊢ ⟐δ_pt  →  ⊡G≤( γ̄^{pt}[⟐·]  →  ⟐γ )
```

*Proof of the conditional form.* Assume `⟐δ_pt` at the anchor: some history `ρ` through `w₀` at `0` has `pt(ρ) = pt`. Let `τ` be any history through the current state at a time `t ≥ 0` with `γ̄^{pt}` true at `(τ,t)`. `δ_pt` is pure-past and `γ`'s future-determined part along `τ` is pure-future, so PS (`paste`, compiled axiom at `Axioms.lean:308`; semantic witness `paste_valid` at `PlusPasting.lean:334`) yields a history `π` agreeing with `ρ` up to `0` and with `τ` from `0` on. By `truth_congr_agreeUpTo`/`truth_congr_agreeFrom` (compiled) the pure-past literals of `γ`'s separated clauses have, at `0`, their `ρ`-values — i.e. exactly `pt` — and the pure-future ones at `t` their `τ`-values. By Lemma 7.2 and Lemma 5.1's unrolling, `γ` is therefore true at `(π, t)`. Since `π` passes through `τ`'s state at `t`, `⟐γ` holds at `(τ, t)`. The until-form instances (where the pasting must happen *under* a `U`) are the US axiom `untl_paste` (compiled, `Axioms.lean:312`). ∎

**This is consumption point (S2).** It is the exact place at which the engine's demand "no violation for *any* certified `pt`" is shown to be a demand about real walks rather than about spurious ones, and it is discharged by the pasting axioms, which are the syntactic shadow of free pasting at a state.

#### 7.4 Claim 2⁺: `⊢ θ_f → ⊡¬χ₁⁺`

**Claim 2⁺ (derived).** `⊢ θ_f → ⊡¬χ₁⁺`, and the mirror `⊢ θ_b → ⊡¬χ₁⁻`.

*Proof.* By Lemma 7.1 applied to Claim 1⁺ under the substitution sending each letter `⟐δ` to the L⁺ formula `⟐δ` and each `Q⁺`-atom to itself,

```
⊢ ( χ₁⁺ ∧ s₀⁺ ∧ G≤ ⋀((b ∧ a_i) → X p⁺(b,i)) ∧ G≤ ⋀ ¬(b ∧ b') )
      →  ¬⋀_{pt ⊆ PastLits}(⟐δ_pt → ⋀_{γ ∈ cl(φ)} G≤(γ̄^{pt}[⟐·] → ⟐γ)).
```

The three non-`χ₁⁺` conjuncts follow from `θ_f` by `stab_t` (which strips each `⊡`), and the
consequent's `pt`-th conjunct, `⟐δ_pt → ⋀_{γ ∈ cl(φ)} G≤(γ̄^{pt}[⟐·] → ⟐γ)`, follows for every
`pt ⊆ PastLits` from the matching instance of Lemma 7.3's **conditional** form — consumption
point (S2), `⊢ ⟐δ_pt → ⊡G≤(γ̄^{pt}[⟐·] → ⟐γ)` for every `γ ∈ cl(φ)` — by stripping its `⊡`; `cl(φ)`
is finite so the conjunction over `γ` is a theorem, and `PastLits` is finite so the further
conjunction over `pt` is too. This is the re-pointing the (D2) repair requires: Claim 2⁺ now
consumes Lemma 7.3's conditional form, matching Claim 1⁺'s restated consequent exactly, rather
than Lemma 7.3's unconditional form (`⊢ χ̄₀⁺[⟐·]`), which does not match it. Hence `⊢ θ_f → ¬χ₁⁺`.
Since `⊢ θ_f → ⊡θ_f` (Finding 6) and `stab_k` distributes, `⊢ θ_f → ⊡¬χ₁⁺`. ∎

**Note on Reynolds' C15.** Reynolds' Claim 2 (held, `sec04:201-237`) uses C9, C11, C14 to pull `Eχ₁` inside and reach `E(χ₁ ∧ s₀ ∧ …)`. Here the corresponding step is the `⊡`-stability of `θ_f`, which is available from `atom_stab` + `stab_4` directly, so C15 is not needed.

**Confirmation: Lemma 7⁺ is unaffected.** The (D2) repair changes only the derivation of
`⊢ θ_f → ¬χ₁⁺` just above; it leaves the proof's two closing steps — `⊢ θ_f → ⊡θ_f` (Finding 6)
then `stab_k`-distribution to `⊢ θ_f → ⊡¬χ₁⁺` — untouched, so Claim 2⁺'s conclusion is exactly the
same formula as before the repair. The proof of Lemma 7⁺ at the end of section 7.5 consumes only
that conclusion (the two conjuncts `⊡¬χ₁⁺`, `⊡¬χ₁⁻`) and nothing else from this section; reading
it confirms it is unaffected by the repair, rather than merely asserting that it must be.

#### 7.5 Claim 3⁺ and the lemma

**Claim 3⁺ (derived).** If `⊢ clockAnte q ∧ θ_f ∧ θ_b → ¬φ` then `⊢ ¬φ`.

*Proof.* Three rule applications, in this order (`ExtDerivation`'s constructors, read verbatim):

1. `aaBwd` with `(s₀⁻, Q⁻, k, a, p⁻)`, discharging `θ_b`. Side conditions: `hb : s₀⁻ ∈ Q⁻` ✓; `hp : ∀ b ∈ Q⁻, ∀ i < k, p⁻ b i ∈ Q⁻` ✓ (`ρ⁻` maps into `Q⁻`); `hsl` ✓ (Lemma 2.6); `hfresh` ✓ (Finding 6); `hexh`, `hexcl` ✓ (Lemma 2.6).
2. `aaFwd` with `(s₀⁺, Q⁺, k, a, p⁺)`, discharging `θ_f`; same checks.
3. `clock` with `q`, discharging `clockAnte q`. Side condition `hq : Fresh q (¬φ)` ✓.

Each rule is at the empty context (the naming rules are validity-preserving, not truth-preserving; `ExtDerivation` has no context parameter at all — read). ∎

*Proof of Lemma 7⁺.* Suppose `φ⁺` inconsistent, i.e. `⊢ ¬φ⁺`. By Claim 2⁺ the two conjuncts `⊡¬χ₁⁺`, `⊡¬χ₁⁻` are consequences of `θ_f ∧ θ_b`, so `⊢ clockAnte q ∧ θ_f ∧ θ_b → ¬φ`. By Claim 3⁺, `⊢ ¬φ`, contradicting the consistency of `φ`. ∎

### 8. The two-sided chronicle

#### 8.1 ℤ-levelled Ockhamist frames

A **ℤ-levelled Ockhamist frame** is `(T, <, ≡, lvl)` with `lvl : T → ℤ`, such that: `x ≡ y ⟹ lvl x = lvl y`; `≡` is an equivalence; `<` is a strict partial order with `x < y ⟹ lvl x < lvl y`; every `x` has at most one immediate `<`-successor `x⁺` and at most one immediate `<`-predecessor `x⁻`, and `lvl x⁺ = lvl x + 1`, `lvl x⁻ = lvl x - 1`; and the `<`-maximal chains ("lines") are intervals of `ℤ` under `lvl`. A *stage* frame is one with `T` finite and every line a finite interval.

The differences from Reynolds' floored Ockhamist frame (held, `sec05:11-30`) are exactly: `lvl` into `ℤ` rather than a floor at level `0`, and the existence of `x⁻` as a separate defect kind.

#### 8.2 The chronicle

A **two-sided chronicle** is `(T, <, ≡, lvl, λ, bl⁺, bl⁻, x₀)` with `(T,<,≡,lvl)` a ℤ-levelled Ockhamist frame, `λ : T → H(φ⁺)`, `x₀ ∈ T` with `lvl x₀ = 0`, and

```
bl⁺ : {x ∈ T : lvl x ≥ 0} → (C × {1,…,K⁺})*
bl⁻ : {x ∈ T : lvl x ≤ 0} → (C × {1,…,K⁻})*
```

subject to the clauses below, in which `γ_{λ*(x)}` is the state formula of `x`'s colour and `ζ⁺_B`, `ζ⁻_B` are the look-ahead formulas of Finding 8.3.

| Clause | Statement |
|---|---|
| K0 | `lvl x₀ = 0` and `φ⁺ ∈ λ(x₀)`; `bl⁺(y) = bl⁻(y) = []` for every `y ≡ x₀` |
| K1 | `λ(x)` is consistent |
| K2F | if `x⁺` exists then `λ(x) R_X λ(x⁺)` |
| K2P | if `x⁻` exists then `λ(x⁻) R_X λ(x)` |
| K3A | `x ≡ y ⟹ λ(x), λ(y)` are hues of the same colour |
| K3B | every hue of `λ*(x)` is `λ(y)` for some `y ≡ x` |
| K4A⁺ | if `(c,p) ∈ bl⁺(x)` then (1) `c` has appeared at or below `x` and (2) there is a lull in forward unbanning reaching its `e_H`-th step below `x` with no colour in `V⁺_p` appearing between the lull's start and `x` |
| K4A⁻ | the `reflectTime` mirror: *above* `x`, with `V⁻_p` |
| K4B⁺ | if `(d,q)` precedes `(c,p)` in `bl⁺(x)` then the most recent appearance of `V⁺_q` below `x` is at or below that of `V⁺_p`, and if `V⁺_p` has never appeared below `x` then neither has `V⁺_q` |
| K4B⁻ | the mirror |
| K4C | `x ≡ y ⟹ bl⁺(x) = bl⁺(y)` and `bl⁻(x) = bl⁻(y)` (where defined) |
| K5A⁺ | `⊬ γ_{λ*(x)} → ⟐ζ⁺_{bl⁺(x)}`, for `lvl x ≥ 0` |
| K5A⁻ | `⊬ γ_{λ*(x)} → ⟐ζ⁻_{bl⁻(x)}`, for `lvl x ≤ 0` |
| K5B⁺ | if `x⁺` exists, `lvl x ≥ 0`, and `(c,p) ∈ bl⁺(x)` then `λ*(x⁺) ≠ c` |
| K5B⁻ | if `x⁻` exists, `lvl x ≤ 0`, and `(c,p) ∈ bl⁻(x)` then `λ*(x⁻) ≠ c` |
| K5C | no pair occurs twice in `bl⁺(x)` or in `bl⁻(x)` |
| K5D⁺ | if `x⁺` exists and `(c,p)` is newly banned at `x⁺` then `λ*(x⁺) = c` |
| K5D⁻ | the mirror at `x⁻` |

**The level restrictions in K5A/K5B are the heart of the transposition**, and Finding 11 is devoted to them: `bl⁺` is defined and constrained only at levels `≥ 0`, `bl⁻` only at levels `≤ 0`.

#### 8.3 The look-ahead formulas

For `B⁺ = [(c_1,p_1), …, (c_m,p_m)] ∈ (C × {1,…,K⁺})*`, with `v⁺_i := ⋁_{s ∈ V⁺_i} s`:

```
ζ⁺_{B⁺} := χ₁⁺ ∨ X((¬v⁺_{p_1}) U γ_{c_1}) ∨ X((¬v⁺_{p_1} ∧ ¬v⁺_{p_2}) U γ_{c_2}) ∨ …
                ∨ X((¬v⁺_{p_1} ∧ … ∧ ¬v⁺_{p_m}) U γ_{c_m})
ζ⁺_[]   := χ₁⁺
```

and `ζ⁻_{B⁻}` the `reflectTime` mirror (`Y`, `S`, `χ₁⁻`, `v⁻`). This is Reynolds' `ζ_L` (held, `sec05:239-248`) with `γ_c` for `γ_c` and `X`/`U` as in L⁺. Its reading is unchanged: the first disjunct says a forward-bad walk starts here; the `j`-th later disjunct says a walk proceeds to a `c_j`-coloured point without any colour in `V⁺_{p_1}, …, V⁺_{p_j}` showing up, which contravenes the ban that would still be in force.

#### 8.4 Lemma 13⁺: the fresh atoms track the run

**Lemma 8.1 (= Reynolds Lemma 13; derived).** For every `x` in a two-sided chronicle with `lvl x ≥ 0`:

a) `⊡G≤ ⋀_{b ∈ Q⁺, i<k}((b ∧ a_i) → ⊡X p⁺(b,i)) ∈ λ(x)`, and for every `b ∈ Q⁺` and `i < k`, if every conjunct of `a_i` is in `λ(x)`, `b ∈ λ(x)` and `x⁺` exists, then `p⁺(b,i) ∈ λ(x⁺)`;

b) `⊡G≤ ⋀_{b ≠ b'} ¬(b ∧ b') ∈ λ(x)` and exactly one `Q⁺`-atom is in `λ(x)`.

*Proof.* Induction along `<` from the anchor class upward, using K0 (`φ⁺ ∈ λ(x₀)`, hence `θ_f ∈ λ(x₀)`), K1, K2F, K3A and Lemma 2.2; the `⊡G≤` conjuncts propagate by `stab_4` and `gle`'s own unfolding `⊢ G≤ψ → XG≤ψ`. ∎

The mirror holds for `Q⁻` at levels `≤ 0`, downward. **This is the lemma that makes the run readable off the labels, and hence the lemma that the ban mechanism and Lemma 14.5 consume.** Note what it does *not* need: no acceptance condition appears in it, which is the inherited reason a merely deterministic automaton would suffice *here* while the ban mechanism still needs the pair shape.

**Lemma 8.2 (the chronicle seed; derived).** For every `x` in a two-sided chronicle, put `h := λ(x)`, `pt_h := {α ∈ PastLits : α ∈ h}` and `ft_h := {β ∈ FutLits : β ∈ h}`. Then both `⟐δ_{pt_h} ∈ h` and `⟐δ_{ft_h} ∈ h`, hence both lie in the letter `ĉ(λ*(x))`.

*Proof.* Four links, given for `ft_h`; the `pt_h` case is the `reflectTime` mirror.

1. `FutLits ⊆ fcl(φ⁺)`. `FutLits ⊆ cl₀(φ)` by the closure construction (Finding 1.1), the same inclusion Lemma 4.1's proof already uses for `PastLits`. `cl₀(φ) ⊆ Sub(φ⁺)`: every member of `cl₀(φ)` is, by construction, a component of some `δ_ft ∈ cl(φ)` for `ft ⊆ FutLits` (Finding 1.3), hence of `⟐δ_ft ∈ ecl(φ)`, hence of the corresponding `a_i := γ̂_{ĉ_i}` (Finding 6) — `γ̂_ĉ` is a conjunction over all of `ecl(φ)`, Finding 2.3 — and `a_i` occurs, as written, inside `θ_f`'s own display (Finding 6), itself a conjunct of `φ⁺` (Finding 6). `Sub(φ⁺) ⊆ fcl(φ⁺)` by `fcl`'s plain-`ψ` alternative (Finding 2.1). This spells out, link by link, the inclusion `cl₀(φ) ⊆ fcl(φ⁺)` that Lemma 4.1's proof already invokes without naming the `a_i`/`θ_f` route.
2. `h = h(a,c)` decides every member of `fcl(φ⁺)` — `h(a,c)`'s own definition (Finding 2.1) puts `δ ∈ h` for `δ ∈ a` and `¬δ ∈ h` for `δ ∈ fcl(φ⁺) \ a` — hence, by link 1, decides every member of `FutLits`. So `⊢ ⋀h → δ_{ft_h}`: every `β ∈ ft_h` is a conjunct of `⋀h`, and every `β ∈ FutLits \ ft_h` contributes `¬β` as a conjunct of `⋀h`, which is exactly `δ_{ft_h}`'s own two conjunct-blocks (Finding 1.3's `δ_a` notation).
3. `⊢ δ_{ft_h} → ⟐δ_{ft_h}` is the contrapositive of `stab_t` (`⊢ ⊡φ → φ`; compiled, `Axioms.lean:288`) instantiated at `¬δ_{ft_h}`, since `⟐ψ := ¬⊡¬ψ`.
4. Chaining links 2 and 3, `⊢ ⋀h → ⟐δ_{ft_h}`. By K1, `λ(x)` is consistent, hence so is `h`; by Lemma 2.4, a consistent hue is maximally consistent in `hcl(φ⁺)`, which decides `⟐δ_{ft_h}` (`ecl(φ) ⊆ hcl(φ⁺)`). `¬⟐δ_{ft_h} ∈ h` together with `⊢ ⋀h → ⟐δ_{ft_h}` would make `h` inconsistent, contradicting K1; so `⟐δ_{ft_h} ∈ h`.

Lemma 2.2 closes it: consistent hues of the same colour agree on `⟐`-formulas, so `⟐δ_{ft_h}` is colour-decided, i.e. `⊢ γ_{λ*(x)} → ⟐δ_{ft_h}`, i.e. `⟐δ_{ft_h} ∈ ĉ(λ*(x))` by the letter's own definition (Finding 2.3). ∎

**What the lemma does and does not use.** Only K1 from the chronicle clause list — no K2–K5, no fairness, no pioneer — so it is a fact about every node's own label, settled before any walk is in view. In particular it is not a consequence of the truth lemma (Finding 14), so it is available inside the truth lemma's own induction with no circularity. And it does **not** claim `ft_h` is the walk's future-type `ft_lin`: `h` is one representative node's label, while `ft_lin` (Finding 5.2) is read off the limit word an *emergent* walk determines, and for such a walk the two generally differ.

#### 8.5 Pioneers, in both directions

```
P1  every x ∈ T is below-or-equal a forward pioneer or a sibling of one, and
    above-or-equal a backward pioneer or a sibling of one
P2F if x is a forward pioneer or a sibling of one and x⁺ exists then x⁺ is a forward pioneer
P2P the mirror with x⁻ and backward pioneers
P3F if x is a forward pioneer and x⁺ exists then  ⊬ (⋀λ(x) ∧ X⋀λ(x⁺)) → ⟐ζ⁺_{bl⁺(x)}
P3P the mirror:                                   ⊬ (⋀λ(x) ∧ Y⋀λ(x⁻)) → ⟐ζ⁻_{bl⁻(x)}
P4F if x is a forward pioneer and x⁺ exists then λ(x⁺) is a fair choice among the hues
    satisfying P3F: no other such hue has come up less recently as λ(y) for y < x
P4P the mirror, over {y : y > x}
```

The two pioneer families are disjoint in practice: forward pioneers are created at the top frontier (levels `≥ 0`) and backward ones at the bottom frontier (levels `≤ 0`). Each family's fairness discipline governs one direction's eventualities.

### 9. Curing defects in both directions; admissible hues; the start

#### 9.1 Admissible successor and predecessor hues

For `h ∈ H(φ⁺)` and `B ∈ (C × {1,…,K⁺})*`, following Reynolds' Definition 6 (held, `sec06:183-187`):

```
Pn⁺(h, B) := { h' ∈ H(φ⁺) :  ⊬ (⋀h ∧ X⋀h') → ⟐ζ⁺_B }
Pn⁻(h, B) := { h' ∈ H(φ⁺) :  ⊬ (⋀h ∧ Y⋀h') → ⟐ζ⁻_B }
```

**Lemma 9.1 (= Reynolds Lemma 16; derived).** If `h, B` satisfy K5A⁺, i.e. `⊬ γ_{h*} → ⟐ζ⁺_B`, then (1) `Pn⁺(h,B) ≠ ∅`; (2) every `h' ∈ Pn⁺(h,B)` is consistent; (3) `h' ∈ Pn⁺(h,B) ⟹ h R_X h'`.

*Proof.* (1) Suppose empty: then `⊢ (⋀h ∧ X⋀h') → ⟐ζ⁺_B` for every `h' ∈ H(φ⁺)`. Since `⊢ ⋁_{h' ∈ H(φ⁺)} ⋀h'` (a substitution instance of a propositional tautology, `H(φ⁺)` being the full hue set) and `X` distributes over the finite disjunction (`right_mono_until` with `next`'s `⊥`-guard, plus `serial_future`), we get `⊢ ⋀h → ⟐ζ⁺_B`. Writing `h = h(a,c)`, `γ_c` has `⟐δ_a` as a conjunct and `⊢ γ_c → ⟐(δ_a ∧ γ_c)` by the S5 cluster, while `⊢ (δ_a ∧ γ_c) → ⋀h`; so `⊢ γ_{h*} → ⟐ζ⁺_B`, contradicting K5A⁺.
(2) Immediate: a derivable `(⋀h ∧ X⋀h') → ⟐ζ⁺_B` would follow from inconsistency of `⋀h'`.
(3) `⋀h ∧ X⋀h'` is consistent; extend to an MCS `Γ`, put `Δ := {ψ : Xψ ∈ Γ}`, which is an MCS by the PLTL-shaped axioms, and `h' ⊆ Δ` with `Γ R_X Δ`. ∎

The mirror, with `Pn⁻`, K5A⁻ and `Y`, is Lemma 9.1 under `reflectTime`.

#### 9.2 Lemma 15⁺: curing a future defect

**Lemma 9.2 (= Reynolds Lemma 15; derived).** Let `(T,<,≡,lvl,λ,bl⁺,bl⁻,x₀)` be a finite two-sided chronicle satisfying P1-P4, and let `x ∈ T` have `lvl x ≥ 0` and no `<`-successor. Then it extends to a finite two-sided chronicle with `x⁺` present, still satisfying P1-P4.

*Proof.* Verbatim Reynolds §13 (held, `sec06:161-...`, `sec07:1-9`), with the hue choice `h⁺ ∈ Pn⁺(λ(x), bl⁺(x))` least-recently-used (P4F), the `n-1` sibling towers `z_1, …, z_{n-1}` with their grids `z_{ij}` filled top-down by the down-and-across lemma, `λ'(z_i) := h⁺_i` (the hues of `h⁺*`), and the banning procedure of §13.1 computing `bl'⁺(x⁺)` from `bl⁺(x)` and `λ'*(x⁺)`. Two deviations, each stated:

- **The down-and-across lemma is replaced by pasting.** Reynolds' Lemma 12 (held, `sec05:135-169`) uses the contrapositive of C15 to produce a predecessor hue `h_{12}` of `h_{11}` with `h_{12} R_X h_{22}`. Here that is not needed in the same form: by Lemma 4.2 (full product) the hue set of a colour is `PT × FT`, so the required grid labels exist by construction — a point `z_{ij}` at level `lvl x_j` in the sibling tower is labelled by the hue of `λ*(x_j)` whose future-type is the one forced by `h⁺_i`'s tower and whose past-type is `x_j`'s own. Existence is exactly the product. Derived; this is the one place where the task-frame semantics *simplifies* Reynolds rather than complicating him.
- **`bl⁻` is not touched.** `bl⁻(x⁺)` is **undefined** if `lvl x⁺ > 0` and is `[]` if `lvl x⁺ = 0` (which happens only inside the anchor class, where K0 fixes it). `bl⁻` at existing points is unchanged. So no backward clause is at risk; see Finding 11. ∎

**Lemma 9.3 (= the mirror).** The `reflectTime` image: a point `x` with `lvl x ≤ 0` and no `<`-predecessor acquires `x⁻`, with `Pn⁻`, `bl'⁻`, P4P, and `bl⁺` untouched.

#### 9.3 Lemma 14⁺: the start

**Lemma 9.4 (= Reynolds Lemma 14; derived).** There is a finite two-sided chronicle satisfying P1-P4.

*Proof.* By Lemma 7⁺, `φ⁺` is consistent; by Lindenbaum (the analogue of Reynolds' Lemma 9, standard) extend to an MCS `Γ₀` and put `h := Γ₀ ∩ hcl(φ⁺)`, a consistent hue. Say `h*` has hues `h_0 = h, …, h_{n-1}` (all consistent, Lemma 2.3). Take `T_0 := {X_0, …, X_{n-1}}`, `<_0 := ∅`, `≡_0 := T_0 × T_0`, `lvl ≡ 0`, `λ_0(X_i) := h_i`, `bl⁺_0 ≡ bl⁻_0 ≡ []`, `x₀ := X_0`. K0-K3B are immediate; K4A-K5D are vacuous for empty lists. K5A⁺ holds because `⊡¬χ₁⁺` is a conjunct of `φ⁺` and so `¬⟐χ₁⁺ ∈ h` — hence `¬⟐χ₁⁺ ∈ h_i` for every `i` by Lemma 2.2 — hence `γ_{h*} ∧ ¬⟐ζ⁺_[]` is consistent. K5A⁻ dually, from `⊡¬χ₁⁻`. Declare `X_0` the pioneer (both forward and backward) of the class and the others its siblings. ∎

Note that `n = |PT(c₀)| · |FT(c₀)|` by Lemma 4.2: the anchor class is exactly the product, and that is what lets the forward construction above it and the backward construction below it share a floor without constraining one another.

#### 9.4 Alternating curing

Enumerate the defects (points without a successor at level `≥ 0`; points without a predecessor at level `≤ 0`) fairly, and cure them in turn, alternating between the two frontiers. By Lemmas 9.2 and 9.3 every stage is a finite two-sided chronicle satisfying P1-P4; by fairness, in the limit

```
L1  every point has an immediate successor and an immediate predecessor
L2  every point has a forward pioneer above it and a backward pioneer below it
```

and `lvl` is onto `ℤ` on every line.

### 10. Ban preservation: Lemma 17⁺ and Lemma 17⁻, consuming `LCU` and its mirror

This is the engine's only consumer of limit closure, and the reason the schema of record is the until-form.

**Lemma 10.1 (= Reynolds Lemma 17; derived).** Let `h, h' ∈ H(φ⁺)` with `h' ∈ Pn⁺(h, B)`, where `B = [(c_1,p_1), …, (c_n,p_n)]`, `m ≤ n`, and

```
B' = [(c_1,p_1), …, (c_m,p_m), (h'*, q_1), …, (h'*, q_l)]
```

with `h'*` not in `V⁺_{p_i}` for `i ≤ m` and `h'*` in `U⁺_{q_j}` for `j ≤ l`. Then `⊬ γ_{h'*} → ⟐ζ⁺_{B'}`.

*Proof.* Suppose for contradiction `⊢ γ_{h'*} → ⟐ζ⁺_{B'}`.

**10.1 Reduce to `l = 1`.** For each `j`, `⊢ X((⋀_{i≤m} ¬v⁺_{p_i} ∧ ¬v⁺_{q_j}) U γ_{h'*}) → X((⋀_{i≤m} ¬v⁺_{p_i} ∧ ¬v⁺_{q_1}) U γ_{h'*})` fails in general, but the implication Reynolds needs runs the other way and is available: `⊢ ζ⁺_{B'_j} → ζ⁺_{B'_1}` where `B'_j` keeps only the `j`-th new pair, by `left_mono_until_G` (weakening the guard conjunction). So it suffices to refute the `l = 1` case. (Held, `sec07:32-44`.) The case `l = 0` is the degenerate one treated at the end.

**10.2 Set up `α` and `β`.** Put `θ := ⋁_{j ≤ m} X((⋀_{i ≤ j} ¬v⁺_{p_i}) U γ_{c_j})` (`θ := ⊥` if `m = 0`), `θ' := X((⋀_{i ≤ m} ¬v⁺_{p_i} ∧ ¬v⁺_{q_1}) U γ_{h'*})`, so `ζ⁺_{B'} = χ₁⁺ ∨ θ ∨ θ'`, and

```
α := γ_{h'*} ∧ ¬⟐χ₁⁺ ∧ ¬⟐θ          β := ⋀_{i ≤ m} ¬v⁺_{p_i} ∧ ¬v⁺_{q_1}
```

From the assumption, the S5 cluster (`stab_k`, `stab_t`, `stab_4`, `stab_5`) gives `⊢ α → ⟐θ'`, hence `⊢ ⟐α → ⟐θ'` by `stab_4`/`stab_5`, i.e.

```
⊢ ⟐α → ⟐X((⟐β) U γ_{h'*})
```

using `⊢ β → ⟐β` (`stab_t` contrapositive) under the `U`-guard, which is `right_mono_until` plus G-necessitation.

**10.3 Upgrade the endpoint from `γ_{h'*}` to `α`.** From `⊢ ⟐α → ⟐X((⟐β) U γ_{h'*})`, split the endpoint on `⟐χ₁⁺ ∨ ¬⟐χ₁⁺` and then on `⟐θ ∨ ¬⟐θ`, distributing over the disjunctions by `right_mono_until`:

```
⊢ ⟐α → ( ⟐X((⟐β) U (γ_{h'*} ∧ ¬⟐χ₁⁺ ∧ ¬⟐θ)) ∨ ⟐X((⟐β) U (γ_{h'*} ∧ ⟐χ₁⁺))
                                              ∨ ⟐X((⟐β) U (γ_{h'*} ∧ ⟐θ)) )
```

The second disjunct implies `⟐χ₁⁺` at the start: `χ₁⁺` is a `{GF, FG}` Boolean combination and therefore **invariant under finite prefixes**, so prefixing the `(⟐β)`-segment to the bad walk gives a bad walk from the start, and derivably `⊢ ⟐X((⟐β) U ⟐χ₁⁺) → ⟐χ₁⁺` by `untl_paste` (US: the guard `⟐β` is state-local, hence pure-past-admissible as a `stab`-leaf, and the event `χ₁⁺` is pure-future) together with the `F_until_equiv`/`absorb_until` shuffles. Since `α` contains `¬⟐χ₁⁺`, that disjunct is excluded. The third implies `⟐θ` at the start, because `β` **subsumes every guard of `θ`** (`β` conjoins `¬v⁺_{p_i}` for all `i ≤ m`, and `θ`'s `j`-th guard is `⋀_{i ≤ j} ¬v⁺_{p_i}` with `j ≤ m`), so prefixing the segment to a `θ`-witness gives a `θ`-witness from the start; derivably by `self_accum_until` and `left_mono_until_G`. Since `α` contains `¬⟐θ`, that disjunct is excluded too. Hence

```
⊢ ⟐α → ⟐X((⟐β) U (⟐α))
```

(the last step replacing the endpoint conjunction by `⟐α` via `stab_t`'s contrapositive).

**10.4 Apply `LCU`.** By G- and `⊡`-generalisation (`tnec`, `nec`, `box_stab`),

```
⊢ ⊡G≤(⟐α → ⟐(⟐β U ⟐α))
```

— the antecedent of `lcU α β` **exactly as declared** (`PlusLCSchema.lean:248`, read: `(stab ((dstab α).imp (dstab (untl (dstab β) (dstab α)))).gle).imp ((dstab α).imp (dstab ((dstab α).or (untl (dstab β) (dstab α))).gle))`). Modus ponens on the `LCU` instance `ExtDerivation.ax` with `IsLCUAxiom`'s first disjunct gives

```
⊢ ⟐α → ⟐G≤(⟐α ∨ (⟐β U ⟐α)).
```

**This is the one and only consumption of limit closure in the engine**, and the `F`-form `lcN` does not discharge it: `lcN`'s consequent `⟐G≤ ⋀_i(⟐α_i → F⟐α_{i+1})` constrains only the marker points and says nothing about the stretch between them, while the whole content needed here is that `⟐β` holds *throughout* each stretch. (Carried from the architecture's Finding 2.3, where the two obvious repairs — `α_i := α ∨ β`, and `α ∧ ⟐((¬v) U α)` — are refuted.)

**10.5 The limit walk is forward-bad.** `⊢ G≤(⟐α ∨ (⟐β U ⟐α)) → χ₁⁺`: along such a walk, `γ_{h'*}` recurs (at every `⟐α`-point, cofinally by the `U`-commitments), so by Lemma 8.1 a `U⁺_{q_1}`-state recurs, while no colour in `V⁺_{q_1}` ever appears (every point is either an `⟐α`-point, where `h'* ∉ V⁺_{q_1}` because `U⁺_{q_1} ∩ V⁺_{q_1} = ∅`, or inside a `⟐β`-stretch, where `¬v⁺_{q_1}` holds). So `FG ¬v⁺_{q_1} ∧ GF u⁺_{q_1}`, a disjunct of `χ₁⁺`. This is a two-sided-PLTL validity in the `Q⁺`-atoms, hence derivable by Lemma 7.1. Combining,

```
⊢ ⟐α → ⟐χ₁⁺,   i.e.   ⊢ (γ_{h'*} ∧ ¬⟐χ₁⁺ ∧ ¬⟐θ) → ⟐χ₁⁺,   i.e.   ⊢ γ_{h'*} → (⟐χ₁⁺ ∨ ⟐θ).
```

**10.6 The contradiction with `h' ∈ Pn⁺(h,B)`.** From 10.5, `⊢ ⋀h' → ⟐(χ₁⁺ ∨ θ)`. Since `h'*` is in no `V⁺_{p_i}` (`i ≤ m`), `⊢ ⋀h' → ⋀_{i ≤ m} ¬v⁺_{p_i}`, so prefixing one step: `⊢ X⋀h' → ⟐(Xχ₁⁺ ∨ ⋁_{j ≤ m} X((⋀_{i ≤ j}¬v⁺_{p_i}) U γ_{c_j}))`, using `untl_paste` for the `X`/`⟐` interchange in place of Reynolds' C14/C15 step (held, `sec07:119-136`). With `⊢ Xχ₁⁺ → χ₁⁺` (prefix invariance again) this yields `⊢ (⋀h ∧ X⋀h') → ⟐ζ⁺_B`, i.e. `h' ∉ Pn⁺(h,B)`. Contradiction.

**10.7 The case `l = 0`.** Then `ζ⁺_{B'} = χ₁⁺ ∨ θ` with `θ` a prefix of `B`'s disjuncts, and the assumption `⊢ γ_{h'*} → ⟐(χ₁⁺ ∨ θ)` already gives 10.6 directly, with no use of `LCU`. ∎

**Lemma 10.2 (= the mirror).** The `reflectTime` image of Lemma 10.1, with `Pn⁻`, `ζ⁻`, `χ₁⁻`, `Y`, `S`, the past pasting axioms (`paste_valid'`, `untl_paste` reflected), and the **backward** `LCU` instance `(lcU α β).reflectTime` — `IsLCUAxiom`'s second disjunct, whose ZTime validity is `lcU_reflectTime_plusValidZTime` (compiled, `PlusLCSchema.lean:486`).

**Lemma 10.3 (= Reynolds Lemma 18; derived).** If `(c,p) ∈ bl⁺(x)` then `λ'*(x⁺) ≠ c`; hence K5B⁺ and K5C are preserved.

*Proof.* Reynolds' argument transposes with no change (held, `sec07:148-182`): if `λ'*(x⁺) = c_j`, then since `λ'(x⁺) ∈ Pn⁺(λ(x), bl⁺(x))` we cannot have all of `¬v⁺_{p_1}, …, ¬v⁺_{p_j}` in `λ(x)`; so `λ*(x)` is in some `V⁺_{p_i}` with `i < j`, so `(c_i,p_i)` would have been unbanned at `x`; the only way it is in `bl⁺(x)` is by being newly banned at `x`, which by K5D⁺ forces `c_i = λ*(x)` with `c_i ∈ U⁺_{p_i}` — contradicting `U⁺_{p_i} ∩ V⁺_{p_i} = ∅` via Lemma 8.1. ∎

### 11. The located obstruction: why the naive interleaved chronicle fails, and the level split that repairs it

This finding is the one place where the transposition is not a transcription and where the prior record did not anticipate the difficulty. It is stated in full because a future reader will otherwise re-derive it.

#### 11.1 The naive design, and its two incompatible demands

The obvious two-sided chronicle keeps both banned lists total on `T` and imposes K5A as a conjunction, `⊬ γ_{λ*(x)} → ⟐ζ⁺_{bl⁺(x)}` **and** `⊬ γ_{λ*(x)} → ⟐ζ⁻_{bl⁻(x)}`, with the admissible set `Pn⁺(h, B⁺) ∩ Pn⁻(h, B⁻)`.

**This is inconsistent as a design, for a sharp reason.**

- **Non-emptiness forces the *joint* clause.** Repeat Lemma 9.1(1) for the intersection: if the intersection is empty then for every `h'` at least one of the two conditions fails, so `⊢ (⋀h ∧ X⋀h') → (⟐ζ⁺_{B⁺} ∨ ⟐ζ⁻_{B⁻})` for every `h'`, and summing over the tautologous disjunction gives `⊢ γ_{h*} → (⟐ζ⁺_{B⁺} ∨ ⟐ζ⁻_{B⁻})`. That contradicts nothing: the two separate non-derivabilities `⊬ γ → ⟐ζ⁺` and `⊬ γ → ⟐ζ⁻` are compatible with the derivability of their disjunction. So the clause that must be maintained is the **joint** one, `⊬ γ_{λ*(x)} → (⟐ζ⁺_{bl⁺(x)} ∨ ⟐ζ⁻_{bl⁻(x)})`. Derived.
- **Preservation of the joint clause forces a backward prefix-transfer that does not hold.** Run Lemma 10.1 with the joint conclusion: put `α := γ_{h'*} ∧ ¬⟐χ₁⁺ ∧ ¬⟐θ ∧ ¬⟐ζ⁻_{B⁻}`. Step 10.3 must then exclude a *fourth* endpoint disjunct, `⟐X((⟐β) U (γ_{h'*} ∧ ⟐ζ⁻_{B⁻}))`, which requires

  ```
  ⊢ ⟐X((⟐β) U ⟐ζ⁻_{B⁻}) → ⟐ζ⁻_{B⁻}          (*)
  ```

  i.e. that a backward-looking witness available at the far end of a forward `β`-segment is already available at the near end. **(*) is false, semantically.** Its two disjunct kinds fail for different reasons. For `χ₁⁻`: a history `σ` through the far endpoint's state at time `t'` that is backward-bad has `σ(t)` at the near time `t` equal to *some* state, not the near endpoint's state, and `⟐` demands agreement at the evaluation time, so nothing transfers; pasting cannot help, because pasting requires the two histories to share a state at the pasting time, which is exactly what is missing. For the `Y((…) S γ_{d_j})` disjuncts: a backward witness from `t'` whose `γ_{d_j}`-point lies in the open segment `(t, t')` gives no witness from `t` at all. Derived.

  The asymmetry is not accidental. Reynolds' step 10.3 works because `χ₁⁺` is a tail-of-the-*future* property and the segment is prefixed to it, and because `β` subsumes `θ`'s guards. In the backward direction the segment is a *suffix* of the past, and a tail-of-the-past property is invariant under changing a finite suffix of the past only if the evaluation point is held fixed — which a forward step does not do.

#### 11.2 What the engine actually needs, and where

Reread the requirement. The forward non-acceptance obligation is `⊡¬χ₁⁺` **at the anchor**, because every bi-infinite walk passes through `w₀` at time `0` exactly once and `χ₁⁺` at the anchor along that walk *is* "the walk's forward half is accepted". Likewise `⊡¬χ₁⁻` at the anchor. Neither is required anywhere else, and neither propagates: semantically, `⊡¬χ₁⁻` at `x` does not imply `⊡¬χ₁⁻` at `x⁺`, because a history through `x⁺`'s state need not pass through `x`'s state one step earlier.

So the forward machinery exists to maintain one clause at one place while the structure grows *upward*, and the backward machinery to maintain another clause at the same place while it grows *downward*. Nothing requires them to be maintained at the same points.

#### 11.3 The resolution: the level split

Declare, as in Finding 8.2:

- `bl⁺` is defined on `{lvl ≥ 0}`, computed **upward** from the anchor class (where it is `[]` by K0), by the forward banning procedure at each forward step. A point's forward list is fixed once the point exists, because a point's past is fixed once it exists: the construction only adds points above the top and below the bottom, never in the middle of a line.
- `bl⁻` is defined on `{lvl ≤ 0}`, computed **downward** from the anchor class, dually.
- K5A⁺ and K5B⁺ are required only at levels `≥ 0`; K5A⁻ and K5B⁻ only at levels `≤ 0`.

Three consequences, which together discharge 11.1:

1. **Forward defects occur only at levels `≥ 0` and past defects only at levels `≤ 0`.** A point below the anchor already has a successor (toward the anchor); a point above it already has a predecessor. So the two frontiers are the top and the bottom and they never meet, and a forward step never has a backward clause to preserve (`bl⁻(x⁺)` is simply undefined for `lvl x⁺ > 0`). The joint K5A is never needed; Lemma 9.1 is used in its one-sided form, exactly as Reynolds states it; Lemma 10.1 is used with `α` as Reynolds writes it, so (*) never arises.
2. **Each half is verbatim Reynolds, one of them under `reflectTime`.** The structure at levels `≥ 0` is a floored Ockhamist frame with floor the anchor class, and the forward engine on it is the source's engine with no deviation beyond the alphabet, the automaton, and the pasting-for-C15 substitution. Symmetrically below.
3. **The only interaction is at the anchor class, and the full-product lemma is the whole of it.** The anchor class's hue set is `PT(c₀) × FT(c₀)` (Lemma 4.2) with the hue recoverable from the pair (Lemma 4.3). The forward engine's floor labelling depends only on the future-type coordinate, the backward engine's ceiling labelling only on the past-type coordinate, and the product says every combination is present — so the two labellings are simultaneously realisable and neither constrains the other.

**This is the finding the dispatch's phrase "alternating future and past defect curing, pioneers and lulls in both directions" names, with its reason supplied**: the alternation is between two frontiers that cannot interfere, and the reason they cannot is the product at the hinge.

#### 11.4 The one place the split costs something

With K5A⁺ absent below the anchor, the truth lemma's `untl` case at a point `t` with `lvl t < 0` cannot use a forward banned list at `t`. It does not need to: Finding 14.2 discharges it using the forward machinery **above** the anchor only.

### 12. Lulls, evaporating graphs, and hue scheduling in both directions

#### 12.1 Lulls

Fix `e_H := 2^{|H(φ⁺)|}`, the same constant in both directions (the hue set is the same). *Forward unbanning* at `x⁺` means `bl⁺(x)` is not a prefix of `bl⁺(x⁺)`; the *unbanned* and *newly banned* pairs are read off the longest common prefix exactly as in the source (held, `sec06:29-42`). A **forward lull** between `x_n < x_{n+1} < … < x_{n+e_H}` (consecutive successors, all at levels `≥ 0`) is a stretch with no forward unbanning at any `x_i`, `n < i ≤ n + e_H`. *Backward lull* is the mirror.

#### 12.2 Evaporating graphs

**Lemma 12.1 (= Reynolds Lemma 21; held, direction-blind).** Let `H` be finite and `E = (E_0, E_1, …)` with `E_{i+1}(h) ⊆ E_i(h)` for all `i, h` (an *evaporating graph*). Let `π = (x_0, x_1, …)` be a *fair path*: each `x_{i+1} ∈ E_i(x_i)` and each `x_{i+1}` is either new or the least-recently-appeared member of `E_i(x_i)`. Then `x_{2^{|H|}}` already occurs among `x_0, …, x_{min(2^{|H|}, |π|)-1}`, and `ran(π) ⊆ {x_i : i < min(2^{|H|}, |π|)}`.

This is a statement about a finite set and a decreasing family of relations. It contains no temporal direction, so it is reused unchanged in both halves.

**Lemma 12.2 (= Reynolds Lemma 22; derived).** Let `(h_0, h_1, …)` be hues and `(L_0, L_1, …)` forward lists with (1) `h_{i+1} ∈ Pn⁺(h_i, L_i)`, (2) `L_i` a prefix of `L_{i+1}`, (3) each `h_{i+1}` new or the least-recently-appeared member of `Pn⁺(h_i, L_i)`. Then `{h_i : i < |σ|} ⊆ {h_i : i ≤ e_H}`.

*Proof.* Put `E_i(h) := Pn⁺(h, L_i)`. Prefix growth makes `⊢ ζ⁺_{L_i} → ζ⁺_{L_{i+1}}` (the later list has all the earlier disjuncts), so `E_{i+1}(h) ⊆ E_i(h)`: `(H(φ⁺), E)` evaporates. The sequence is a fair path, and Lemma 12.1 applies. ∎

The mirror holds with `Pn⁻` and backward lists.

**Lemma 12.3 (= Reynolds Lemma 19; derived).** Along any fullpath `(s_0, s_1, …)` of the quotient at levels `≥ 0` there are infinitely many forward lulls.

*Proof.* Reynolds' argument (held, `sec07:234-275`) is combinatorial in the banned lists and the appearance order of the `V⁺_p`, and uses only K4A⁺, K4B⁺, K5D⁺. It transposes with the index set `{1,…,K⁺}` and no change. The mirror holds backward. ∎

### 13. The limit, the quotient, and universal non-acceptance

#### 13.1 The quotient

Let `S := T/≡`, `R := {([x],[y]) : ∃ x' ≡ x with (x')⁺ ≡ y}`, `g([x]) := {p ∈ L ∪ Q⁺ ∪ Q⁻ ∪ {q} : p ∈ λ(x') for some x' ≡ x}` (well defined by Lemma 2.2), and `lvl([x]) := lvl(x)` (well defined). By L1, `R` is **doubly** serial: every state has an `R`-successor and an `R`-predecessor. By K3A/K4C, `λ*([x])`, `bl⁺([x])`, `bl⁻([x])` are well defined.

A **walk** is a bi-infinite `b : ℤ → S` with `(b_i, b_{i+1}) ∈ R` for all `i`. Each `t ∈ T` determines the walk `line(t)` through `[t]` given by its own line (L1 makes it total). Walks not of this form are **emergent**; there are in general uncountably many. Every walk has `lvl(b_i) = lvl(b_0) + i`, and by `clockAnte` every walk meets level `0` exactly once; normalise `b_0` to be that point, so `b_0` is in the anchor class.

The quotient is a **time-sliced digraph**: states carry their level, edges go from slice `n` to slice `n+1`, every slice is countably infinite (siblings and towers are added at every stage). This is exactly the shape the two finite-model-property refutations at ZTime require of any canonical model — no finite carrier, no finite per-time fibre (carried, probe-level, `ztime-no-finite-carrier-fmp.md`).

#### 13.2 Universal non-acceptance

**Lemma 13.1 (= Reynolds Lemma 20, forward; derived).** Along any walk `b` there is no `i ≤ K⁺` such that infinitely many `j ≥ 0` have `λ*(b_j) ∈ U⁺_i` while only finitely many have `λ*(b_j) ∈ V⁺_i`.

*Proof.* Reynolds' proof (held, `sec07:281-318`) verbatim, restricted to the one-sided index `j ≥ 0` where `bl⁺` is defined. Suppose such an `i = p` and such a `c ∈ U⁺_p` recurring. Let `G` be the non-empty set of pairs `(c',p')` with `c' ∈ U⁺_{p'}` recurring and all colours in `V⁺_{p'}` occurring only finitely often; pick `(c',p')` whose last `V⁺_{p'}`-appearance is earliest. Find an index past (i) the last appearance of every colour not in `inf(b)`, (ii) a subsequent appearance of every colour in `inf(b)`, and (iii) the end of a forward lull (available by Lemma 12.3). At the next appearance of `c'`, the pair `(c',p')` is newly banned (K4A⁺'s two conditions hold, K5D⁺ permits it). It is never subsequently unbanned: an unbanning needs a pair `(d,q)` at or before it in the list, either directly unbanned by a `V⁺_q`-appearance — impossible, since K4B⁺ puts `V⁺_q`'s last appearance at or before `V⁺_{p'}`'s, which was long enough ago that every colour in `inf(b)` has since appeared while no `V⁺_q`-colour has — or usurped by an older pair `(e,r)`, which would put `(e,r) ∈ G` with an earlier last `V⁺_r`-appearance, contradicting the choice of `(c',p')`. So `(c',p')` stays banned and K5B⁺ forbids `c'` from recurring: contradiction. ∎

**Lemma 13.2 (= the mirror).** No `i ≤ K⁻` has infinitely many `j ≤ 0` with `λ*(b_j) ∈ U⁻_i` and only finitely many with `λ*(b_j) ∈ V⁻_i`.

**Corollary 13.3 (derived).** For every walk `b`, `A⁺` does not accept `(ĉ(λ*(b_0)), ĉ(λ*(b_1)), …)` and `A⁻` does not accept `(ĉ(λ*(b_0)), ĉ(λ*(b_{-1})), …)`.

*Proof.* By Lemma 8.1 and Lemma 2.2 the `Q⁺`-atoms in the labels along `b` at levels `≥ 0` are exactly the run states of `A⁺` on that word (this is Reynolds' Lemma 26, Finding 14.5 below); Rabin acceptance would then give the configuration Lemma 13.1 excludes. Mirror for `A⁻`. ∎

### 14. The truth lemma, including the `⊡` case for emergent walks

**Theorem 14.1 (the truth lemma; derived).** For every `δ ∈ cl(φ⁺)` and every `t ∈ T`,

```
δ ∈ λ(t)   ⟺   (S, R, g), line(t), lvl(t) ⊨ δ.
```

With K0 this gives `(S,R,g), line(x₀), 0 ⊨ φ`, which with the final-frame step of Finding 15 is the completeness theorem for T3.

*Proof.* Induction on `δ`. The cases `atom`, `bot`, `imp` are Lemma 2.4 (maximal consistency in `hcl φ⁺`) plus the IH, with the atom case using Lemma 2.2 for well-definedness of `g`. `box` reduces to `⊡` plus globality (`box_global`, compiled). The four substantive cases follow.

#### 14.1 `untl` (⟹), at a point at level ≥ 0

Verbatim Reynolds (held, `sec09:24-123`). Suppose `α U β ∈ λ(t)` and, for contradiction, that `α`, `α U β`, `¬β` are in `λ(t_i)` for every `i ≥ 0` along `line(t)` (the alternative, that `β` arrives, is the conclusion). By L2/P2F, `line(t)` has a forward pioneering region; by Lemma 12.3 choose a forward lull `t_n < … < t_{n+e_H}` inside it, and let `B := bl⁺(t_{n+e_H})`. By K4A⁺(2), no hue appearing in the lull is in any `V⁺_p` for `p` mentioned in `B`.

Run the hypothetical continuation: recursively pick `h_{i+1} ∈ Pn⁺(h_i, B)` fairly, starting from `h_{n+e_H} := λ(t_{n+e_H})`. Lemma 9.1(1) keeps the set non-empty; Lemma 10.1 keeps `⊬ γ_{h_i*} → ⟐ζ⁺_B` true at each step (so the recursion does not stall); Lemma 12.2 says every hue ever reached already appeared during the lull. Put `I := {h : h = h_i$ for infinitely many i}` and `Θ := ⋁_{h ∈ I} ⋀h`. Then

```
V1  every h ∈ I contains α, α U β and ¬β
V2  no h ∈ I is in any V⁺_p for p mentioned in B
V3  ⊬ ⋀h → ⟐ζ⁺_B  for every h ∈ I
```

**Lemma 14.2 (= Reynolds Lemma 23; derived).** `⊢ Θ → (XΘ ∨ ⟐ζ⁺_B)`.

*Proof.* Otherwise there is an MCS `Γ ⊇ {Θ, ¬⟐ζ⁺_B, ¬XΘ}`; let `Δ := {ψ : Xψ ∈ Γ}`, `h_1 := Γ ∩ hcl(φ⁺)`, `h_2 := Δ ∩ hcl(φ⁺)`. Then `h_1 ∈ I` and `h_2 ∉ I`; but `⊬ (⋀h_1 ∧ X⋀h_2) → ⟐ζ⁺_B` (else `Γ` is inconsistent), so `h_2 ∈ Pn⁺(h_1, B)`, and fairness forces `h_2 ∈ I`. ∎

By V2, `⊢ Θ → ⋀_{p ∈ B} ¬v⁺_p`, so the S5 cluster gives `⊢ (Θ ∧ X⟐ζ⁺_B) → ⟐ζ⁺_B`; with Lemma 14.2, `⊢ (Θ ∧ ¬⟐ζ⁺_B) → X(Θ ∧ ¬⟐ζ⁺_B)`; by G-generalisation and `connect_future`, `⊢ (Θ ∧ ¬⟐ζ⁺_B) → G≤Θ`. By V1, `⊢ Θ → (α ∧ (α U β) ∧ ¬β)`, so `⊢ (Θ ∧ ¬⟐ζ⁺_B) → ((α U β) ∧ G≤¬β)`, which `until_F` refutes. Hence `⊢ Θ → ⟐ζ⁺_B`, and picking any `h ∈ I` gives `⊢ ⋀h → ⟐ζ⁺_B`, contradicting V3. ∎

#### 14.2 `untl` (⟹) at a point at level < 0, and `snce` (⟹) above the anchor

The level split (Finding 11.3) leaves `bl⁺` undefined below the anchor, so the argument of 14.1 cannot be run at `t` with `lvl t < 0`. It need not be.

**Lemma 14.3 (derived).** Theorem 14.1's `untl` (⟹) case holds at every `t ∈ T`, including `lvl t < 0`.

*Proof.* Suppose `α U β ∈ λ(t)` with `lvl t < 0` and, for contradiction, `α`, `α U β`, `¬β` in `λ(t_i)` for all `i ≥ 0`. The hue persistence is established exactly as in 14.1, by K2F, `self_accum_until` (the `C7` analogue: `⊢ (α U β) → (β ∨ (α ∧ X(α U β)))`) and the IH — none of which mentions a banned list or a level. Since `lvl t_i = lvl t + i`, the ray `(t_i)_{i ≥ 0}` enters `{lvl ≥ 0}` after finitely many steps, and by L2/P2F its forward pioneering region lies there. Apply 14.1's argument from that point on: the lull, `B`, `I`, `Θ`, Lemma 14.2 and the contradiction all live at levels `≥ 0`, where `bl⁺` is defined. The three hue facts V1 transfer because the persistence holds along the whole ray. ∎

The `snce` (⟹) case is the `reflectTime` mirror, with `bl⁻` and backward pioneers, and holds at every `t` including `lvl t > 0` by the same argument downward. The (⟸) directions of both are the easy ones (Reynolds, held, `sec09:124-136`): propositional, from `self_accum_until` and the IH.

#### 14.3 `⊡`/`⟐` (⟹)

`⟐δ ∈ λ(t)`: by Lemma 14.4 below, `λ*(t)` has a hue `h'` with `δ ∈ h'`; by K3B some `t' ≡ t` has `λ(t') = h'`; by the IH `line(t'), lvl t ⊨ δ`; and `line(t')` passes through `[t'] = [t]` at `lvl t`, so `⟐δ` holds along `line(t)` at `lvl t`.

**Lemma 14.4 (= Reynolds Lemma 24; derived).** If `⟐δ ∈ cl(φ⁺)`, `⟐δ ∈ h ∈ H(φ⁺)` and `h` consistent, then `h*` has a hue `h'` with `δ ∈ h'`.

*Proof.* Extend `h` to an MCS `Γ`; the set `{δ} ∪ {ψ : ⊡ψ ∈ Γ}` is consistent by the S5 cluster; extend to an MCS `Δ` and put `h' := Δ ∩ hcl(φ⁺)`. For `h'* = h*`, note every `⟐δ_b ∈ Γ` is in `Δ` by `stab_4`. ∎

#### 14.4 `⊡`/`⟐` (⟸): the emergent-walk case

This is the hard case and the reason for the automata.

Suppose `(S,R,g), line(t), lvl t ⊨ ⟐δ`: there is a walk `b` with `b_{lvl t} = [t]` and `b, lvl t ⊨ δ`. `b` may be emergent. Define the ℤ-word `w(b) := (ĉ(λ*(b_i)))_{i ∈ ℤ}` over `Ĉ` (well defined by Lemma 2.2 and K3A). Three steps.

**Step 1 (= Reynolds Lemma 25; derived).** For every linear temporal combination `ψ` of members of `cl(φ⁺)` and every `i`, `w(b), i ⊨ ψ̄` iff `(S,R,g), b, i ⊨ ψ`.

*Proof.* Induction on `ψ`, the only non-immediate case being a letter `⟐ρ`: if `w(b), i ⊨ ⟐ρ` then `⟐ρ ∈ λ(t')` for some `t' ∈ b_i`, and the **outer** IH of Theorem 14.1 at `⟐ρ` gives `line(t'), i ⊨ ⟐ρ`, hence `b, i ⊨ ⟐ρ` (both walks pass through `b_i` at `i`). Conversely `b, i ⊨ ⟐ρ` gives `line(t'), i ⊨ ⟐ρ` for any `t' ∈ b_i`, and the outer IH gives `⟐ρ ∈ λ(t')`, i.e. the letter is in `w(b)_i`. ∎

**Step 2 (= Reynolds Lemma 26; derived).** For every `i ≥ 0` and `s ∈ Q⁺`, `s ∈ g(b_i)` iff `s = q_i`, where `(q_0, q_1, …)` is the run of `A⁺` on `(w(b)_0, w(b)_1, …)`. Mirror for `Q⁻` and `i ≤ 0`.

*Proof.* Induction on `i`. At `i = 0`, K0 gives `s₀⁺ ∈ λ(x₀)` for the anchor class. At `i+1`: pick `t_i ∈ b_i` with `t_i^+ ∈ b_{i+1}`; by the IH and Lemma 2.2, `q_i ∈ λ(t_i)`; every conjunct of `γ̂_{w(b)_i}` is in `λ(t_i)` (for `e ∈ w(b)_i`, by Lemma 2.2; for `e ∉ w(b)_i`, because no `t' ∈ b_i` has `e ∈ λ(t')` and `λ(t_i)` is maximal in `hcl(φ⁺) ⊇ ecl(φ)`); so Lemma 8.1(a) gives `ρ⁺(q_i, w(b)_i) = q_{i+1} ∈ λ(t_i^+)`, i.e. `q_{i+1} ∈ g(b_{i+1})`. The converse direction follows from Lemma 8.1(b). ∎

**Step 3' (derived). `w(b)` is not bad, so `⟐δ ∈ λ(t)`.**

*Proof.* (1) By Corollary 13.3 and Step 2, neither `A⁺` nor `A⁻` accepts its half of `w(b)`, unchanged from Step 3.

(2) By Lemma 8.2 applied to any representative `x₀` of the class `b_0`, there is a certified `ft_0 := {β ∈ FutLits : β ∈ λ(x₀)}` with `⟐δ_{ft_0} ∈ w(b)_0` (`λ*(x₀) = λ*(b_0)` by K3A, and `w(b)_0 = ĉ(λ*(b_0))` by definition of `w(b)`). `ft_0` is certified but not yet known to be `w(b)`'s real future-type `ft_lin(w(b)) := {β ∈ FutLits : w(b), 0 ⊨ β̄}`.

(3) Non-acceptance by `A⁻` gives, for this certified `ft_0`, no backward violation at `i = 0` under `ft_0`. Instantiate at `γ := δ_{pt_lin(w(b))}`, with `pt_lin(w(b)) := {α ∈ PastLits : w(b), 0 ⊨ ᾱ}`: this `γ` is pure-past (Finding 5.3's mirror of Finding 5.2), so by Lemma 3.1 its translation's truth at `0` is a condition on `w(b)` alone — it does not consult `ft_0` — and it is true at `0` of `w(b)` by construction, exactly as `pt_lin` is defined. So `⟐δ_{pt_lin(w(b))} ∈ w(b)_0`: the real past-type is now certified, for real, not merely hypothesized.

(4) Non-acceptance by `A⁺` then gives, for this now-really-certified `pt_lin(w(b))`, forward badness-freedom for every `i ≥ 0`: for every `γ ∈ cl(φ)` and `i ≥ 0`, if `w(b), i ⊨ γ̄` then `⟐γ ∈ w(b)_i`. Instantiate at `i = 0`, `γ := δ_{ft_lin(w(b))}` (true at `0` by construction, dually to (3)): `⟐δ_{ft_lin(w(b))} ∈ w(b)_0`. The real future-type is now certified, for real.

(5) Non-acceptance by `A⁻` again, now for this really-certified `ft_lin(w(b))`, gives backward badness-freedom for every `i ≤ 0`: for every `γ ∈ cl(φ)` and `i ≤ 0`, if `w(b), i ⊨ γ̄` then `⟐γ ∈ w(b)_i`.

(6) (4) and (5) together say exactly `w(b) ⊨ χ̄₀`, as before.

Apply this at `i := lvl t` and `γ := δ`. By Step 1, `w(b), lvl t ⊨ δ̄`; hence `⟐δ ∈ w(b)_{lvl t}`, i.e. `⟐δ ∈ λ(t')` for some `t' ≡ t`, i.e. `⟐δ ∈ λ(t)` by Lemma 2.2. ∎

**Why this breaks the circularity.** Not by cross-certification between the two automata: a certified-but-possibly-wrong hypothetical type — `ft_0` at step (2) — is already a usable ticket into clause (b), because the fact step (3) extracts at position `0` is pure-past, hence does not depend on the ticket being right. Step (3)'s output is then a real certification, which licenses the unconditional guarantees of steps (4)-(5) with no further hypothesis.

**Structural comparison.** The bookkeeping is one link longer than the two-clause original — four non-acceptance applications instead of two, since the hypothesis is upgraded from merely-certified to really-certified twice before both real types are in hand — while each automaton is one disjunct smaller (the omega-regularity-only clause of Finding 5, now dropped from both). The chain order matters: the seed at step (2) must be of the opposite polarity to the fact first extracted at step (3) (seeding a future-type to certify the past-type, not the reverse), and the whole chain is symmetric under `reflectTime`, which exchanges `A⁺ ↔ A⁻`, `pt ↔ ft`, and steps (2)-(3) with (4)-(5).

*(Remark: `δ ∈ cl(φ⁺)` while the automata range over `cl(φ)`. For `δ ∈ cl(φ)` the above is immediate. For `δ ∈ cl(φ⁺) \ cl(φ)` — the formulas mentioning `q`, `Q⁺`, `Q⁻` — the `⟐`-case is settled without the automata: those atoms are state-local by `atom_stab`, so `⟐` of a Boolean combination of them is colour-decided by Lemma 2.2, and the only temporal combinations of them occurring in `cl(φ⁺)` are inside `θ_f`, `θ_b`, `χ₁⁺`, `χ₁⁻`, each of which is settled by Lemma 8.1 and Corollary 13.3 directly. Derived; this is the one bookkeeping point Reynolds does not have to make, because his `φ⁺` has no backward half.)*

#### 14.5 What Step 2 does and does not need

Step 2 reads the automaton's run off the labels and consumes **no acceptance condition**. That is the structural fact behind the inherited split verdict: at this interface a merely deterministic automaton would do, and determinism is what `p⁺ : Q⁺ × {1,…,k} → Q⁺` being a *function* delivers. The acceptance condition is consumed instead in Finding 8.3 (`ζ⁺` is indexed by pairs), Finding 10.5 (`U⁺_q ∩ V⁺_q = ∅`), Lemma 10.3 and Lemma 13.1 — all of which read a single pair per index. Hence the write-up names Rabin automata throughout and the Muller alternative is not available for the ban mechanism.

### 15. The final frame: the universal cover

`(S, R, g)` is not yet a model of L⁺: the semantics needs a **regular ℤ-time task frame**, i.e. *Compositionality*, *Seriality*, *Limit* and *Saturation* (read, `TaskFrame.lean` docstring), and `R` is only a one-step relation.

#### 15.1 From a step relation to a task frame

The one-step relation `R` on `S` generates a ℤ-time task frame by iteration (`IntNormalForm.lean`'s `ofStepRel`/`iter` route, carried): *Compositionality* holds by construction of the iterate, *Seriality* because `R` is doubly serial (Finding 13.1), and *Limit* by the standard discharge for shift-like relations (`limit_of_shift`/`limit_of_succOrder`, read in the `TaskFrame.lean` docstring).

#### 15.2 *Saturation* is a genuine obligation here, unlike in Reynolds' setting

Reynolds stops at "(S,R,g) is a Kripke structure" (held, `sec07:194-201`): a Kripke frame is a set with a total relation and nothing more. Task frames carry *Saturation*, and the quotient does not obviously have it: every slice is countably infinite, so neither `saturation_of_finite` nor `saturation_of_fib_finite` applies, and the quotient is not an oriented forest (states have many predecessors and many successors by construction), so `saturation_of_orientedForest` does not apply directly. A general countable doubly serial digraph can fail *Saturation* (carried, derived in the architecture report by nesting fibres with disjoint depth-`k` paths).

#### 15.3 The route of record: the universal cover

Replace `S` by its **universal cover** `S̃` — components of the orientation-keeping undirected multigraph of `R`, unrolled — which is an oriented forest, hence saturated by `saturation_of_orientedForest` (compiled, `OrientedForest.lean:134`), doubly serial, and carries a surjective two-way-bounded covering map `π : S̃ → S`. Transfer truth along `π`.

**The two missing pieces, named.** (i) The cover construction itself, with its forest, double-seriality and two-way-boundedness properties: **missing**, and shared with the ZTime decidability paper proof. (ii) Invariance along a two-way-bounded surjection whose **base** is not assumed saturated: `plus_invariance_of_isZTime` (compiled, `HistoryMorphism.lean:589`) demands `[F.IsRegular]` on the base, which bundles *Saturation*, and the base here is `S`, whose *Saturation* is exactly what is unknown. `exists_preimage_step_neg`'s own proof uses only `reflection` (read), so the hypothesis may well be removable by audit rather than by new mathematics; whether *Saturation* is consumed anywhere in the lifting chain is **unverified**. Carried from the architecture report, which files both.

#### 15.4 The shape is right

The two ZTime finite-model-property refutations say a canonical model must have an infinite carrier with infinitely many states at a single time; the quotient has exactly that, and so does its cover. So the cover route is not a workaround imposed by a defect of the construction — it is the shape the frame class forces.

### 16. The two located questions

#### 16.1 (Q1) Is `lcU α β` derivable in TM⁺ + `LC_n` + mirror at ZTime, for state-local `β`?

**Open.** What is established:

- The `F`-form does not discharge the segment guard: `lcN`'s consequent constrains only the marker points, and the obvious repairs fail (carried, derived in the architecture report's Finding 2.3). This refutes the *obvious* derivation, not derivability.
- **A ZTime countermodel cannot settle it.** Both schemata are ZTime-valid: `lcN_plusValidZTime` and `lcU_plusValidZTime` are compiled (`PlusLCSchema.lean`, read). So TM⁺ + `LC_n` and TM⁺ + `LCU` have *the same* ZTime models, and no ZTime frame separates them. Derived; this is the sharpening this report adds to the question.
- Consequently (Q1) is settleable only by (i) an actual derivation, or (ii) a non-ZTime separating model — a general frame, an algebra, or a frame class at which `lcN` is valid and `LCU` is not. `.Base` validity of both is open and unclaimed (read, the `PlusLCSchema.lean` docstring: "`.Base` validity of `LCU` is **open and unclaimed**, for the same cofinality reason `lcN`'s is"), which is where such a separation would be looked for first.
- Reynolds 2003's `LC_n` is the device for an `F`/`P`-only language; L⁺ has `untl`/`snce` primitive. So the question is not whether Reynolds was wrong but whether the richer language makes the weaker schema suffice.

#### 16.2 (Q2) Are the three naming rules admissible in the rule-free system?

**Open.** What is established:

- **Soundness is landed; admissibility is a different property.** `clock_irr_sound` and `irr_sound` (compiled, `NamingRules.lean:317,345`) say the clock and IRR rules preserve *validity* at an arbitrary frame class. Admissibility over TM⁺ + the schemata would say they preserve *derivability* — that whenever the premise is derivable so is the conclusion — which does not follow from soundness unless the system is already complete. No analogue is landed for the AA rules at all (their formula-level soundness is itself a missing ingredient).
- **The reduction is exact.** T3 (`ExtComplete IsLCUAxiom RuleSet.all`) together with (Q1) and (Q2) yields T1 (`ExtComplete IsLCAxiom RuleSet.none`): (Q1) replaces the `LCU` axiom instances by `LC_n` derivations, (Q2) eliminates the three rule applications. T1 is therefore **unreached, not refuted**.
- Reynolds raises the same question for his own rule ("One important question is whether the AA rule is really needed", held, `sec01:210`) and points at Zanardo's "complicated axiom … alternative to the IRR rule" via Reynolds 2002 §8 and 2003 §4; Di Maio–Zanardo 1998 is not held in the corpus.

#### 16.3 One further question this write-up raises

**(Q3) Is the cross-certification of Finding 14.4 eliminable? Answered in the affirmative.** The two clause-(a)s are redundant: each is already an instance of the same automaton's clause (b), evaluated at position 0 under a hypothetical cut type the bar-translation's purity makes irrelevant (Theorem 1); the one fact clause (b) cannot supply on its own — that the chronicle's own letter already certifies a type of each polarity — is seeded from chronicle clause K1 alone, with no circularity (the section-8 seed lemma); and Step 3 of this section's emergent-walk case is replaced by the four-link bootstrap Step 3′ above. The argument is carried in full in `specs/905_eliminate_cross_certification_two_sided_reynolds_automata/reports/01_eliminate-cross-certification-clauses.md`, which is the record of this answer.

Two qualifications. First, the certification is automatic from the chronicle clauses **plus clause (b)**, not from the chronicle clauses alone: it is clause (b)'s own position-0 instance, seeded by K1, that does the work. Second, the *clauses* are eliminable while the *fact* they encoded — that each half's cut type is certified — remains load-bearing at the cut; eliminating the clauses removes a redundant device, not the fact.

The third admissible answer, a bi-infinite-automaton alternative, is closed rather than left open. The Auxiliary-Atoms rule's antecedent `aaAnte` names a run in one direction only, and `ExtDerivation`'s rule set offers exactly it and its `reflectTime` mirror and nothing else, so no automaton over a bi-infinite word could be named inside L⁺ regardless of what ω-automata theory supplies (Finding 4(i) of the record above, derived from this repository's rule inventory). The supporting claim that the standard reduction for bi-infinite recognizability is itself a forward/backward cut-and-split is marked **recalled**: the Literature corpus was swept and holds no substantive source. Derived.

### 17. The Lean position: inherited, with one inventory correction

Carried verbatim from the NO-GO re-assessment as amended, and **not** re-measured here:

- **(O1)** Determinization to a deterministic Rabin automaton is unproved everywhere. `Muller.toRabin_exists` (local CSLib fork, `DA/Conversions.lean:112`) is a `proof_wanted` and is the single remaining determinization gap; `Rabin.toParity_exists` is off the critical path because `Parity.toRabin_language_eq` is proved and the ban mechanism consumes Rabin rather than parity. The named consumer is the ban/lull mechanism, per the inherited split verdict.
- **(O2)** Discharged, not deprioritized: the cut product is a finite indexed **union**, and taking it on the Muller side then determinizing once puts it inside the already-proved `Muller.exists_iSup`. None of the Rabin-side product or closure code it was costed at is needed.
- **(O3)** Every determinization result arrives as an existential over `Type`, not as the syntax the Auxiliary-Atoms rule needs to name the automaton in fresh state-valued atoms.
- **(O4)** The rest of the paper proof — consistency of `φ⁺`, ban preservation, universal non-acceptance, fair scheduling, the two-sided truth lemma — is untouched by any of this.

**Nothing in this write-up moves any of them.** The alphabet enlargement (Finding 1.3), the cross-certification clauses (Finding 5.2) and the first-transition indexing (Finding 5.4) change finite cardinalities and a transition table's first row; (O1) is about an unproved theorem and (O3) about the *form* in which it would arrive, neither of which is a cardinality question. **A Lean formalization is therefore not filed**, per the dispatch and the standing recommendation.

**The one correction.** The architecture's ingredient row 2 — `LCU` and its mirror, declared and ZTime-valid — is recorded as missing and is **landed**: `lcU` (`PlusLCSchema.lean:248`), `lcU_plusValidInt` (`:409`), `lcU_plusValidZTime` (`:464`), `lcU_reflectTime_plusValidZTime` (`:486`), all read this session. Recorded in `issues.jsonl` as a win.

**What this write-up adds to the Lean-side inventory, as paper-level statements only** (not filed, per the prohibition): the full-product lemma now has two consumers rather than one (the cut soundness and the alphabet collapse, Findings 4.2-4.4); the linear bridge has two consumers rather than one (Claim 1⁺ and derivable separation, Lemmas 7.1-7.2); and the level split (Finding 11.3) is a statement about the *chronicle definition*, so it changes what any future formalization of stages C-F would have to state, not how much of it there is.

### Cross-Domain Synthesis

The logical and the order-theoretic content meet at the cut and at the cover, and nowhere else.

**At the cut**, the semantics' defining feature — free pasting at a state — pays for itself three times over, in three different registers. Order-theoretically it makes the stability cluster's type set a *product* (Lemma 4.2, from `paste_agreeUpTo`/`paste_agreeFrom`). Logically, in its axiomatic shadow PS/US, it makes conditional badness a *theorem* (Lemma 7.3), which is what licences the automaton's union over certified types. And combinatorially it makes the down-and-across construction *free* (Lemma 9.2's first deviation), replacing Reynolds' C15 argument with an existence statement about the product. Separation is the other half of the same seam: it is what makes the cut index finite and state-level in the first place, so that there is a product to speak of. Neither feature alone suffices, and the architecture's single "consumption point" is their conjunction.

**At the cover**, the fact that drives everything is a frame-class fact and not a logical one: task frames carry *Saturation* and Kripke frames do not. That single difference is the reason Reynolds' proof ends at `S = T/≡` and this one does not — and the reason the two finite-model-property refutations at ZTime, which are statements about carriers and fibres, turn out to describe the quotient exactly. The engine produces the shape the frame class demands; what it does not produce is the axiom, and the cover supplies it.

**Between the two**, the direction of time is the organising asymmetry, and the one place the transposition is genuinely new mathematics is where that asymmetry bites: Finding 11's observation that forward badness is prefix-invariant and backward badness is not, in the sense that a forward segment carries a bad future down to its start but does not carry a bad past up to its end. The resolution is not a cleverer formula but a *structural* decision — split the two mechanisms by level — and that decision is only available because the clock rule gives a canonical cut. So the three naming rules are not three conveniences: the clock rule is what makes the two-sidedness tractable at all, and the two Auxiliary-Atoms rules are what put the two automata inside the language.

## Decisions

1. **The two-sided engine is two one-sided engines hinged at the cut, not one interleaved chronicle.** The interleaved design is reported as *failing*, with the exact step that fails named (Finding 11.1's (\*)), rather than omitted. The level split (Finding 11.3) is adopted as the design of record, and the chronicle definition of Finding 8.2 carries the level restrictions in its K5A/K5B clauses accordingly.
2. **Separation's consumption point is split into (S1) and (S2).** The architecture located one point; this write-up records two, because they consume different landed results (`separationOver_ztime` versus `paste`/`untl_paste`) and either alone leaves the engine broken in a different way (Finding 4.3).
3. **The cut index is folded into the automaton's first transition**, so the Auxiliary-Atoms rule's single fixed initial-state atom suffices and `aaAnte` is used unchanged. This supersedes the reading on which the initial state was a function of the cut colour and `θ_f` had to state it (Finding 5.4).
4. **The automaton alphabet is enlarged beyond Reynolds', and the enlargement is minimised by the full-product lemma.** The characteristic conjunctions of the pure literals are closure members; the pair-indexed conjunctions are not needed (Findings 1.3, 4.4). The enlargement is reported as *forced* by the two-sidedness, not as a presentational choice.
5. **The circularity in the `⊡` (⇐) case is closed by cross-certification rather than by a bi-infinite automaton.** Each automaton certifies the type the other consumes; the matching derivable obligations are instances of `χ̄₀` at position 0, so `φ⁺` gains no conjunct (Finding 14.4). The alternative (a single automaton over bi-infinite words) is recorded as (Q3) rather than attempted.
6. **Derivable separation is routed through the leaf abstraction and the linear bridge, not through `plusTruthAt_sepZ_iff`.** Using the semantic separation of L⁺ formulas inside a completeness proof for L⁺ would be circular; the abstraction's separation is an L-validity and the bridge lifts it (Lemma 7.2). Recorded because the circularity is easy to miss.
7. **Reynolds' C15 is not transposed.** Both of its uses are discharged by PS/US pasting, which is strictly stronger on task frames. Recorded so that a future reader does not look for a `⊡X → X⊡` schema in TM⁺ and conclude an ingredient is missing (Findings 0.2, 9.2, 10.6).
8. **The acceptance type is named without hedging.** Deterministic Rabin throughout, on the inherited settled premise. Finding 14.5 records *where* the pair shape is consumed and where it is not, so the premise is visible at its point of use rather than only in the preamble.
9. **(Q1) is reported with its settling condition, which is not the obvious one.** That both schemata are ZTime-valid, hence that no ZTime countermodel can separate them, is stated as a finding; it changes what a future attempt on (Q1) should look for.
10. **No `user_decision` is raised.** The dispatch names a write-up and two questions to record; the write-up is delivered, the questions are recorded with their settling conditions, and the one preference-shaped item downstream (whether to invest in `Muller.toRabin_exists`) is owned by the NO-GO re-assessment's recommendations and is not re-opened.
11. **No library change, no `require`, no Lean execution, no task creation, and no completeness claim** lands from this dispatch. The formal-research-agent contract has no task-creation surface; the recommendations below are left for intake.

## Recommendations

1. **Amend the architecture report's ingredient table row 2 to "landed"**, citing `lcU` (`PlusLCSchema.lean:248`) and the three validity theorems (`:409,464,486`). Its stage-D row ("Ban preservation — needs `LCU` declared") should drop the parenthetical; the stage is `paper` with its schema in hand.
2. **Amend the architecture report's Finding 2.4** to record the split consumption point (S1)/(S2) of Finding 4.3 and the first-transition indexing of Finding 5.4. The current text's "its initial state is a function of `γ_{colour(w₀)}`, so `θ_f` can state it" is correct but avoidable, and the avoidable version is the one a formalization should state.
3. **File the full-product lemma and the linear bridge with their second consumers named.** Both are already filed as small Lean ingredients; their statements should record that the full-product lemma is consumed by the alphabet collapse as well as by the cut soundness, and the bridge by derivable separation as well as by Claim 1⁺. The statements themselves do not change; only what cites them does.
4. **Do not file the level split as a Lean item.** It is a change to the *definition* of a chronicle, and chronicles are stages C-F of the ingredient table, all `paper`, all behind (O1)/(O3). Filing it would create a Lean task with no reachable target.
5. **Attempt (Q3) before any formalization of the automata.** Eliminating the cross-certification clauses would remove one ω-regularity argument from each automaton and shrink the alphabet's enlargement; it is a paper question answerable against the chronicle clauses alone, and it is strictly cheaper than anything in Finding 17.
6. **Pursue (Q1) through a non-ZTime separating model, not through a ZTime countermodel.** Finding 16.1 shows the latter cannot work. The natural first target is `.Base`, where both schemata's validity is open and unclaimed.
7. **Keep (Q2) framed as admissibility, not soundness.** The landed `clock_irr_sound`/`irr_sound` do not bear on it, and recording them as partial progress on (Q2) would overstate the position.
8. **Do not file a Lean formalization of any part of §§7-15 above**, and do not re-open the CSLib `require` question. Both conclusions are inherited and this write-up strengthens neither direction.

## Risks & Mitigations

- **Risk: the level split (Finding 11.3) is a design decision whose adequacy rests on Finding 11.2's claim that `⊡¬χ₁⁺` and `⊡¬χ₁⁻` are required at the anchor only.** That claim rests in turn on every bi-infinite walk meeting level 0 exactly once, which is `clockAnte`'s content. *Mitigation*: the claim is stated at its point of use with its ground (`clockAnte q`, compiled, whose `once`/`rigid` conjuncts are read verbatim), and the converse — that the clauses do not propagate — is given a semantic reason, not asserted. If the clock rule were weakened the split would have to be re-examined.
- **Risk: the failure of (\*) in Finding 11.1 is argued semantically, and a derivable form might still exist by some route not tried.** *Mitigation*: the argument is given for both disjunct kinds separately and identifies the structural reason (a forward segment is a suffix of the past, and `⟐` demands same-state-same-time agreement that pasting cannot supply). It is a refutation of the transposition of Reynolds' step, not a proof that no derivation of (\*) exists; the level split makes the question moot rather than answering it, and that is stated.
- **Risk: Lemma 5.2's ω-regularity argument is a sketch at the level of "LTL conditions are ω-regular", not a construction.** *Mitigation*: this matches the source's own level (Reynolds invokes Theorem 2 and does not construct the automaton), and the construction is in any case behind (O1). The one part that is *not* standard — the deterministic transducer for the running past-type — is given explicitly with its recursion (Lemma 5.1), because that is the part separation is responsible for.
- **Risk: the `⊡` (⇐) case's bookkeeping remark (Finding 14.4's parenthesis) covers the `cl(φ⁺) \ cl(φ)` formulas by inspection of `φ⁺`'s shape rather than by a uniform argument.** *Mitigation*: the remark names the three formulas involved and the landed facts that settle each. A uniform argument would require the automata to range over `cl(φ⁺)`, which the Auxiliary-Atoms rule's freshness side condition forbids — so the case split is forced, not chosen.
- **Risk: the alphabet is enormous (`|Ĉ| = 2^{|ecl φ|}` with `ecl φ` already exponential in `|cl φ|`).** *Mitigation*: only finiteness is load-bearing for a `Prop`-valued completeness statement, and the automaton is non-computable under (O3) regardless. Nothing in the proof is sensitive to the size; this is noted rather than optimised.
- **Risk: Lemma 9.2's first deviation (pasting in place of the down-and-across lemma) is asserted for the sibling grid without writing out the labelling.** *Mitigation*: the existence statement it needs is exactly Lemma 4.2 plus Lemma 4.3, both proved above from compiled cores; what is not written out is the index bookkeeping of the grid, which is Reynolds' Figure 5 and carries no new content.
- **Risk: the final-frame step is the weakest link and is inherited rather than advanced.** The cover construction and the base-*Saturation*-free invariance are both missing, and whether *Saturation* is consumed in the lifting chain is unverified. *Mitigation*: stated as such in Finding 15.3, with the one piece of positive evidence (`exists_preimage_step_neg` uses only `reflection`) and the one piece of negative evidence (`plus_invariance_of_isZTime` demands `[F.IsRegular]` on the base) both named. This write-up does not claim the final-frame step; it claims the engine up to it.
- **Risk: this report is read as a completeness proof of T3.** It is a paper proof at the source's level of rigour, with one step (the final frame) resting on two unlanded pieces and the whole resting on no machine checking. *Mitigation*: stated in the status vocabulary, in Finding 15.3, and here.
- **Risk: it is read as lifting the Lean NO-GO or as licensing a formalization.** It does neither. *Mitigation*: Finding 17 and recommendations 4 and 8.

## Tactic Survey Results

Not applicable: no proof goal was opened and no Lean process was started. This dispatch is a paper write-up by its own terms ("RESEARCH TASK, report only"), carried out by reading a held source, nineteen library files, and three prior records, and by deriving the transposition above. Recording a tactic survey here would be fabrication.

## Appendix

### Evidence tier by claim

| Claim | Tier |
|---|---|
| The seven L⁺ truth clauses; `⊡` is same-state-same-time, `□` unrestricted | compiled (`PlusTruth.lean:84-93`) |
| `lcU` declared with the four validity theorems; `lcN` likewise | compiled (`PlusLCSchema.lean:226,248,409,464,486`) |
| `paste`, `untl_paste`, `atom_stab`, `box_stab`, `stab_k/t/4/5` are TM⁺ schemata | compiled (`Axioms.lean:285-313`) |
| `paste_valid`, `truth_congr_agreeUpTo`, `truth_congr_agreeFrom`, `paste_agreeUpTo`, `paste_agreeFrom` | compiled (`PlusPasting.lean:259-362`) |
| `sepZ` computes a separated CNF; its clauses are (pure-past, pure-future); it is equivalent on regular ZTime frames | compiled (`Discharge.lean:122,128,151`) |
| `completeness_ztime` is weak completeness at ZTime for the base language; `ofTMSubst` transports at the same frame class | compiled (`StrongCompleteness.lean:1119`, `SetConsequence.lean:226`, `Substitution.lean:199,184`) |
| `StateLocal` admits `box`/`stab` with arbitrary argument and excludes `untl`/`snce` | compiled (`PlusStateLocal.lean:149,170,183,174`) |
| `clockAnte`, `once`, `rigid`, `Fresh`, `clock_irr_sound`, `irr_sound` | compiled (`NamingRules.lean:115,180,184,190,317,345`) |
| `aaAnte`/`aaStep`/`aaExcl`/`ExtDerivation`/`T1`-`T3` as stated, with the `aaFwd`/`aaBwd` side conditions | probe only (`specs/879_…/probes/01_target-statements.lean`, read verbatim) |
| Reynolds' `θ_A`, `χ₀`, `χ₁`, `φ⁺`, `ζ_L`, K0-K5D, P1-P4, `e_H = 2^{|H|}`, Lemmas 7-27, C0-C15, LC, Definition 4, Theorem 2 | held (read this session, chunks `sec02`-`sec09`) |
| One separation round suffices; the bar-translation preserves purity; `⊢ γ̄[⟐·] ↔ γ` | derived |
| `PT(c₀) = {a ∩ PastLits : a ∈ c₀}`; the full product; the hue is a function of its type pair | derived (from the compiled pasting cores) |
| The one-step unrolling makes the running past-type a deterministic transducer | derived |
| The cut index folds into the automaton's first transition; the single initial-state atom suffices | derived |
| The alphabet must carry the characteristic conjunctions of the pure literals; pairs are unnecessary | derived |
| Claims 1⁺/2⁺/3⁺ and Lemma 7⁺; the linear bridge; derivable separation; `⊢ χ̄₀[⟐·]` conditional form | derived |
| Lemma 17⁺ line by line, with `LCU` at step 10.4 and the mirror at Lemma 10.2 | derived |
| The interleaved chronicle fails; (\*) is false for both disjunct kinds; the level split repairs it | derived |
| Lemmas 19-22, 23-27 transpose; `untl` (⟹) below the anchor via the forward machinery above it | derived |
| Cross-certification closes the `⊡` (⇐) circularity at no syntactic cost | derived |
| `C15` is not needed; both its uses are pasting | derived |
| (Q1) is not settleable by a ZTime countermodel | derived (from the two compiled validity theorems) |
| The quotient is time-sliced with countably infinite slices; a general countable doubly serial digraph can fail *Saturation* | carried (the architecture report's Finding 2.2) |
| Finite-carrier and finite-width fmp fail at ZTime | carried (probe-level, via the context note; not re-run) |
| The universal cover is an oriented forest with a two-way-bounded covering map | carried (paper, the architecture report's Finding 2.2) |
| `saturation_of_orientedForest`; `plus_invariance_of_isZTime` demands `[F.IsRegular]` on the base | compiled (`OrientedForest.lean:134`, `HistoryMorphism.lean:589`) |
| The split acceptance-condition verdict: Muller suffices for AA, not for ban/lull; the two-state counterexample | carried as a settled premise (the Muller-sufficiency report, read in full) |
| (O1), (O3), (O4) live; (O2) discharged | carried (the NO-GO re-assessment as amended) |

### Locators

**Reynolds 2001**, `/home/benjamin/Projects/Literature/sources/reynolds_2001/`:
`sec02_a.md` — C0-C8 and the PLTL rules; §2.1 the Rabin automaton and the `U ∩ V = ∅` normalisation; Theorem 2 (McNaughton, Safra).
`sec03_47-equivalence-results-…md:152-168` — C9-C15; `:192-237` — §6 LC with Lemma 5's soundness proof; `:280-331` — Definition 4 and the AA rule; `:329` — Lemma 6.
`sec04_sec-9-…md:26-60` — `cl φ` and the emergent-branch problem; `:61-85` — `ecl φ`, the bar-translation, `χ₀`; `:94-105` — "The simple form of the Rabin acceptance criteria is the key to guiding our construction", and the automaton; `:123-141` — `θ_A`, `v_i`, `u_i`, `χ₁`; `:142-150` — `φ⁺` and Lemma 7; `:151-260` — Claims 1-3.
`sec05_sec-10-…md:33-66` — `fcl φ⁺`, `δ_a`, `C`, `γ_c`, `h(a,c)`, `H(φ⁺)`; `:67-89` — Lemma 8; `:107-122` — `hcl φ⁺`, Lemmas 9-10, `R_X`/`R_A`, "a hue is in `V_i`/`U_i`"; `:124-169` — Lemmas 11-12; `:171-232` — §11 the idea of banning, with the bifurcation and conditionality discussion; `:236-262` — `ζ_L` and its reading.
`sec06_111-lulls-…md:1-48` — §11.1 lulls, `e_H = 2^{|H(φ⁺)|}`, unbanning; `:50-98` — §12 the chronicle and K0-K5D; `:106-117` — Lemma 13; `:118-135` — §12.1 pioneers P1-P4; `:136-158` — §12.2 Lemma 14; `:161-229` — §13 Lemma 15, Definition 6, Lemma 16; `:230-321` — the sibling grid and Figure 5; `:322-375` — §13.1 the banning procedure with usurping.
`sec07_132-a-new-chronicle-…md:1-14` — §13.2's checklist; `:16-143` — Lemma 17, the LC consumer, with its final claim; `:145-182` — Lemma 18 and K5B/K5C; `:184-191` — §14 the limit, L1-L2; `:194-217` — §14.1 the Kripke structure; `:219-318` — §14.2 Lemmas 19-20.
`sec08_143-hue-scheduling-…md:1-54` — §14.3 evaporating graphs, Definition 7, Lemma 21; `:56-86` — Lemma 22.
`sec09_sec-15-truth-lemma-…md:1-23` — the statement and the easy cases; `:24-123` — `α U β` (⟹) with Lemma 23; `:124-136` — `α U β` (⟸); `:137-155` — `Ea` (⟹) and Lemma 24; `:156-253` — `Ea` (⟸) with Lemmas 25-27.

**This repository** (every line cited was read this session):
`FormalSystem/PlusLanguage/Formula.lean:95-112` (the seven constructors), `:130-215` (the derived operators, `dstab`, `Will`/`will`/`Could`/`could`), `:218-230` (`reflectTime`, `reflect_time_involution`), `:309-325` (`IsPureFuture`, `IsPurePast`).
`PlusLanguage/PlusTruth.lean:84-93` (the truth clauses), `:338,378` (`stab_state_only`, `box_global`).
`PlusLanguage/Axioms.lean:110-313` (the schema list), `:316-329` (`minFrameClass`).
`PlusLanguage/PlusLCSchema.lean:51-66` (`LCU` vs `lcN 1` side by side), `:73-85` (what is and is not claimed for `lcU`), `:146` (`gle`), `:155` (`gle_iff`), `:177` (`bigAnd`), `:185` (`bigAnd_iff`), `:205,211,226` (`lcAnte`, `lcCons`, `lcN`), `:248` (`lcU`), `:409,464,486` (the three `lcU` validity theorems).
`PlusLanguage/PlusStateLocal.lean:149-186` (`StateLocal` and its arms).
`PlusLanguage/PlusPasting.lean:97,136` (`pasteFun`, `paste`), `:250-277` (`agreeFrom_mono`, `agreeUpTo_mono`, `paste_agreeFrom`, `paste_agreeUpTo`), `:281-330` (`truth_congr_agreeFrom`, `truth_congr_agreeUpTo`), `:334-362` (`paste_valid`, `paste_valid'`, `future_dstab_valid`).
`PlusLanguage/Substitution.lean:155,184,199` (`PlusAxiom.ofTMSubst`, `minFrameClass_ofTMSubst`, `PlusDerivationTree.ofTMSubst`).
`Metalogic/NamingRules.lean:115-123` (`Fresh`), `:180-191` (`once`, `rigid`, `clockAnte`), `:317-343` (`clock_irr_sound`), `:345-360` (`irr_sound`).
`Metalogic/Expressiveness/SeparationZ/Discharge.lean:86-104` (`sepZ`), `:122-128` (`sepZ_sepClauses`), `:131-151` (`plusTruthAt_sepZ_iff`), `:152-158` (`separationOver_ztime`).
`Metalogic/SetConsequence.lean:226` (`WeakCompleteness`), `Metalogic/StrongCompleteness.lean:1119` (`completeness_ztime`).
`Semantics/TaskFrame.lean:74-120` (the four regularity constraints, *Saturation* verbatim, nullity), `:179-242` (the constraint predicates and the `saturation_of_*` family).
`Semantics/OrientedForest.lean:134` (`saturation_of_orientedForest`), `Semantics/HistoryMorphism.lean:306,589` (`exists_preimage_step_neg`, `plus_invariance_of_isZTime`).
`OpenLanguage/OpenTruth.lean:339` (`stab_iff_ofut_opast`).

**Prior records**:
`specs/879_lplus_ztime_completeness_tm_plus_lc_programme/reports/01_lplus-ztime-completeness-programme.md` — Findings 0 (the declaration inventory), 1 (T1-T3), 2.1-2.5 (the architecture and the stage table), 3 (the 21-row ingredient table), 4 (the verdict), and both amendment notes.
`specs/879_…/probes/01_target-statements.lean` — the target statements, read verbatim.
`specs/902_reassess_lplus_ztime_nogo_cslib_omega_automata/reports/01_cslib-omega-automata-nogo-reassessment.md` — Finding 3's (O1)-(O4) and its amendment note.
`specs/903_muller_sufficiency_for_auxiliary_atoms_rule_ztime/reports/01_muller-sufficiency-aa-rule-ban-lull.md` — the split verdict, inherited here as a settled premise.
`.claude/context/project/logic/domain/ztime-no-finite-carrier-fmp.md` — the two finite-model-property refutations (cited through the architecture report, not re-run).
`specs/901_two_sided_reynolds_engine_paper_proof/issues.jsonl` — the two entries recorded this dispatch (the `lcU` inventory win; the deploy-staleness note).
