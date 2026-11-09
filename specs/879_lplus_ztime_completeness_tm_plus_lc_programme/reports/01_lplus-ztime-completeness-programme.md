# Research Report: Task #879 — the L⁺ ZTime completeness programme: target, architecture, ingredients, verdict

**Task**: 879 - Own the L-plus ZTime completeness programme for TM-plus with the limit-closure schema
**Started**: 2026-11-09T09:05:46Z
**Completed**: 2026-11-09T09:31:49Z
**Effort**: one research dispatch (orchestrated, seq 21, `--lit`)
**Dependencies**: 870 (oriented-forest *Saturation*, `[COMPLETED]`), 871 (`LCU` record repair and backward `LC_n`, `[COMPLETED]`), 867 (Gabbay separation over ℤ, `[COMPLETED]` the morning of this dispatch)
**Sources/Inputs**:
- Prior records, read in full this session: `specs/archive/559_.../reports/03_axiomatizability-rules-engine.md` (with its four amendments), `specs/archive/865_.../reports/01_lc-axiomatization-automaton-obstruction.md`, `specs/archive/870_.../summaries/01_oriented-forest-saturation-summary.md`, `specs/archive/871_.../summaries/01_lcu-omega-chain-record-repair-summary.md`, `specs/867_.../summaries/04_separation-theorem-discharge-ztime-summary.md`, `specs/archive/878_.../reports/01_lplus-ztime-decidability-proof-repair.md` findings 7-10, `specs/archive/884_.../summaries/*.md`, `specs/archive/559_.../summaries/04_naming-rule-soundness-toolkit-summary.md`, `specs/ROADMAP.md`
- Codebase, read this session: `FormalSystem/PlusLanguage/{Axioms,Derivation,Formula,PlusLCSchema,PlusValidity,PlusTruth,PlusPasting,Substitution,PlusLimitClosure}.lean`, `FormalSystem/Metalogic/NamingRules.lean`, `FormalSystem/Metalogic/Independence/PlusIncompleteness.lean`, `FormalSystem/Metalogic/Conservativity/Plus/{PlusSoundness,Atomization}.lean`, `FormalSystem/Metalogic/Expressiveness/SeparationZ/{Discharge,Packaging}.lean`, `FormalSystem/Semantics/{HistoryMorphism,OrientedForest,TaskFrame,IntNormalForm,SlicedFrame}.lean`, `FormalSystem/Semantics/Frames/TranslationProduct.lean`, `specs/archive/559_.../probes/03_morphisms-clock-rule-lc-schema.lean` (the `coneR`/`aa_expand` section)
- Context: `.claude/context/project/logic/domain/ztime-no-finite-carrier-fmp.md`
- Literature (held, read this session): Reynolds 2001, *An Axiomatization of Full Computation Tree Logic*, §9-§15 (`reynolds_2001`, chunks sec04-sec09); Reynolds 2003 and 2002 only as summarised in report 03
- Mathlib lookup skipped: no Lean target (no `*.lean` path in `file_scope`, task_type not lean4-routed)
**Artifacts**:
- `specs/879_lplus_ztime_completeness_tm_plus_lc_programme/reports/01_lplus-ztime-completeness-programme.md` (this report)
- `specs/879_lplus_ztime_completeness_tm_plus_lc_programme/probes/01_target-statements.lean` (the target statements, elaborated this session under `import FormalSystem`, no `sorry`, no theorem)
- `specs/879_lplus_ztime_completeness_tm_plus_lc_programme/task-proposals.json` and `task-proposals-audit.ndjson` (the nine missing-ingredient proposals and their backlog-audit verdicts)
**Standards**: report-format.md, subagent-return.md
**Task Type**: formal
**Domains**: logic (primary: the proof system, the Reynolds engine, where separation is consumed), math (secondary: order and graph theory for the carrier and the cover; ω-automata for the ban mechanism)

## Status vocabulary

*Compiled* — a theorem of this repository's library, read this session. *Elaborated* — a statement that type-checked this session under `import FormalSystem` (no proof). *Probe* — compiled in `specs/`, not in the library. *Derived* — a paper derivation performed this session. *Paper* — a paper-level claim inherited from a prior record and not re-derived. *Held* — a literature fact read this session in a held source. No claim below is a completeness claim.

## Executive Summary

**Amended by** specs/902_reassess_lplus_ztime_nogo_cslib_omega_automata/reports/01_cslib-omega-automata-nogo-reassessment.md, 2026-11-09: the *ground* of the Lean NO-GO is replaced and the NO-GO itself is preserved — ω-automata are not absent from the reachable Lean ecosystem (CSLib upstream carries the ω-regular closure lattice with a proved complementation; the local CSLib fork carries McNaughton determinization to Muller, sorry-free, on this project's toolchain), so the obstruction relocates to the four components (O1)-(O4) named in that report rather than resting on Mathlib's inventory or on the MSO refusal. The ingredient table's row 8 (the full-product lemma at the cut) is unchanged, because it is this repository's own TaskFrame-semantics obligation about `WorldHistory` and free pasting that no version of CSLib contains or could contain.

- **Deliverable 1 is met and machine-checked as a statement.** The target is stated as three `Prop`s over one parametric proof system `ExtDerivation fc Ax R` (TM⁺ theoremhood, an axiom set, a rule set): **T1** `ExtComplete IsLCAxiom RuleSet.none` — the dispatch's literal question (TM⁺ + `LC_n` + backward `LC_n`, no rules); **T2** the same schemata with the clock rule and the forward and backward Auxiliary-Atoms rules; **T3** the Reynolds-2001 transposition, TM⁺ + the until-form `LCU` + its mirror + the three rules. All three elaborate (probe file above). Nothing is proved.
- **Deliverable 2: the architecture closes at paper level for T3, not for T1.** Reynolds 2001 §9-§15, read this session, consumes the **until-form** limit-closure axiom in exactly one place — the ban-preservation lemma (his Lemma 17: `Eα → EX((Eβ) U (Eα))` iterated to `Eα → EG((Eβ) U (Eα))`) — and the F-form `LC_n` does not discharge that step because its consequent constrains only the marker points, never the stretch between them. `LC_n` is Reynolds 2003's device for an F/P-only language; L⁺ has `untl`/`snce` primitive. So the schema of record for this language is `LCU` plus its mirror, and the dispatch's framing ("`LC_n` plus progress measures") is corrected to "`LCU` plus the automaton-and-ban machinery".
- **The exact point at which separation is consumed is located.** The two one-sided automata of report 865's doubled design are initialised at the clock cut by *state-level* data — the forward one by the set of past-types realised at the cut colour, the backward one by the set of future-types — and that initialisation is sound only because the stability cluster's `(past-type, future-type)` set is a **full product** (`paste` + `truth_congr_agreeUpTo/From`, compiled), which presupposes that every closure formula splits into independent past-determined and future-determined parts — `separationOver_ztime`, landed by 867. Without separation the hue at the cut is walk-dependent and no fresh atom (atoms are state-valued) can carry it; with it, a product automaton indexed by the cut colour's type set does. Derived, finding 2.4.
- **Two structural facts fix the shape of the final model.** The finite-carrier and finite-width fmp refutations (`ztime-no-finite-carrier-fmp.md`, probe-level, Probe706/Probe710) mean the canonical model must have infinitely many states at a single time; the Reynolds limit quotient `T/≡` is exactly such a time-sliced digraph with infinite fibres, and its *Saturation* is **not** discharged by any landed route. The countermodel of record is therefore its universal cover (an oriented forest, saturated by 870's `saturation_of_orientedForest`), which needs two unlanded, unowned pieces: the cover construction (ROADMAP (H5)'s second half, also owed to the decidability paper proof) and a truth-transfer theorem whose base frame needs no *Saturation*.
- **Deliverable 3: the ingredient table has 21 rows; 9 are missing and are filed as audited proposals.** Landed: `lcN`, backward `lcN`, `clock_irr_sound`/`irr_sound`, `separationOver_ztime`/`sepZ`, `saturation_of_orientedForest`, `plus_invariance_of_isZTime`, `paste`/`truth_congr_*`, `completeness_ztime`+`ofTMSubst`, `stab_state_only`/`box_global`, `atom_stab`, `plus_soundness_ztime`. Missing: `LCU` declared and valid; the cone carrier as a regular frame (inr-layer forest + two-layer *Saturation* split); the formula-level AA rules with soundness; the extended system module; the universal cover; invariance without base *Saturation*; the cut product lemma; the linear-validity bridge; and the two-sided paper proof itself.
- **Deliverable 4, the verdict: GO for T3 as a staged paper programme with cheap Lean ingredients landing now; NO-GO on T1 as stated; NO-GO on a Lean proof of any of T1-T3 today.** T1 is neither reached nor refuted: it reduces to two precise open questions (is `LCU` derivable from TM⁺ + `LC_n` at ZTime; are the three naming rules admissible). The Lean obstruction is specific: the engine needs a **deterministic** ω-automaton (Rabin/parity) for the violation language, Mathlib has no ω-automata and no determinization — but that obstruction is relocated rather than inherited from the MSO refusal: 902 Finding 3 re-measures it as (O1)-(O4), namely determinization to Rabin or parity `proof_wanted` even in the local CSLib fork, the indexed conjunctive product absent from both CSLib trees at ≈100-150 lines, the determinized automaton arriving existentially over `Type` rather than as nameable syntax, and nothing in CSLib touching the remaining ingredient rows. Soundness of the whole T3 system is formalizable now; completeness is not.

## Context & Scope

The dispatch asked four things: (1) the target theorem as a Lean proposition, stated not proved; (2) the proof architecture end to end — canonical-bundle closedness from limit closure, the doubled Auxiliary-Atoms rule over the layer-split carrier, and the exact point at which separation is consumed; (3) an ingredient table with each lemma landed, owned, or missing, missing ones filed through the backlog audit; (4) a go/no-go verdict, a precisely located obstruction counting as complete.

Constraints honoured: nothing under `FormalSystem/` or `Tests/` was touched; no `lake build`; the only Lean run was a `lean_run_code` elaboration of statements with no proofs; ZTime only; L^▷ not entered; no completeness or decidability claim is made. Every declaration name cited was re-verified against the tree by grep this session (finding 0), as the dispatch requires.

Not redone: report 865's five findings (doubled automaton sufficient in shape; AA carrier intrinsic; layer-split route; `LCU` misrecord; ZTime existence question) are taken as read and built on. Where this report corrects a prior record, it says so (findings 2.3, 2.4).

Standing ruling honoured: decidability before completeness. 878 made the ZTime decidability paper proof rigorous conditional on (H5); 870 landed (H5)'s *Saturation* half; the cover half is unlanded and, as of this session, unowned (no open task names it) — finding 3 files it, since the completeness programme needs it too.

## Domain Analysis

**Logic (primary).** The question is which axiom schema and which rules a Reynolds-style engine consumes, where the engine's three languages (object, linear, fresh-atom) are transposed to L⁺, and where a definability theorem (separation) enters. The decisive logical facts are the `⊡ = ▷◁` / pasting factorization and the until-form of limit closure.

**Math (secondary).** Three load-bearing items are not logical: the two-layer carrier's *Saturation* (order/graph theory, 865 finding 4, now with 870's lemma to hand); the universal cover and the time-sliced shape of the limit quotient (graph theory); and the deterministic ω-automaton for the violation language (automata theory — Safra/Piterman, held in the corpus as `piterman_2007`, `schewe_varghese_2014`, `loding_pirogov_2019`).

**No physics content.**

## Findings

### 0. Declaration inventory, re-verified against the tree this session

| Name | Where (grep this session) | Status |
|---|---|---|
| `plus_incomplete_base`, `not_plus_complete_base` | `Metalogic/Independence/PlusIncompleteness.lean:74,` ff. | compiled; `PlusValid (blc p) ∧ ¬ PlusDerivable .Base [] (blc p)` |
| `lcN`, `lcAnte`, `lcCons`, `lcN_plusValidZTime` | `PlusLanguage/PlusLCSchema.lean:189-308` | compiled, `n ≥ 1`, arbitrary `α` |
| `lcN_reflectTime_plusValidZTime` | `PlusLCSchema.lean:334` | compiled (871) |
| `omega_chain` with segment property `P`, `hP` | `PlusLanguage/PlusOmegaChain.lean:373` | compiled (871 restored `P`) |
| `clock_irr_sound`, `irr_sound`, `Fresh`, `clockAnte` | `Metalogic/NamingRules.lean:317,345` | compiled, arbitrary `FrameClass` |
| `separationOver_ztime : SeparationOver TaskFrame.IsZTime`, `sepZ`, `sepZ_sepClauses`, `plusTruthAt_sepZ_iff` | `Metalogic/Expressiveness/SeparationZ/Discharge.lean:93-150` | compiled (867) |
| `pureLit_cnf`, `usTruth_sepFormUS_package` | `SeparationZ/Packaging.lean:222,314` | compiled — the CNF literals are syntactically `IsUOnly ∨ IsSOnly` |
| `saturation_of_orientedForest`, `saturation_of_orientedForest'`, `IsOrientedForest` | `Semantics/OrientedForest.lean:134,837,880` | compiled (870) |
| `TwoWayBounded`, `exists_preimage_step_neg`, `plus_invariance_of_isZTime` | `Semantics/HistoryMorphism.lean:281,306,589` | compiled; both frames `[IsRegular]` |
| `prodRel_saturation`, `translationProduct` | `Semantics/Frames/TranslationProduct.lean:203` | compiled |
| `paste`, `paste_valid`, `paste_valid'` | `PlusLanguage/PlusPasting.lean:334,350` | compiled |
| `stab_iff_ofut_opast` | `OpenLanguage/OpenTruth.lean:339` | compiled |
| `stab_state_only`, `box_global` | `PlusLanguage/PlusTruth.lean:338,378` | compiled |
| `PlusDerivationTree`, `PlusDerivable`, `PlusAxiom` (incl. `atom_stab`, `paste`, `untl_paste`, `box_stab`, `stab_t`) | `PlusLanguage/{Derivation,Axioms}.lean` | compiled; no fresh-atom rule, theorems-only rules take `[]` |
| `PlusDerivationTree.ofTMSubst`, `PlusAxiom.ofTMSubst` | `PlusLanguage/Substitution.lean:155,199` | compiled |
| `completeness_ztime : WeakCompleteness FrameClass.ZTime` | `Metalogic/StrongCompleteness.lean:1119` | compiled, base `Formula` |
| `plus_soundness_ztime` | `Metalogic/Conservativity/Plus/PlusSoundness.lean:162` | compiled |
| `PlusFormula.StateLocal` | `PlusLanguage/PlusStateLocal.lean:149` | compiled |
| `coneR`, `cone_twoWay`, `aa_expand`, `coneSt` | `specs/archive/559_.../probes/03_...lean:524-575` | **probe only**, Mathlib-only mirror; not in the library |
| `LCU` | — | **undeclared** (871 confirmed; its docstring says so) |

### 1. Deliverable (1): the target theorem, stated and not proved

The dispatch's standing ruling forbids adding a constructor to `PlusFormula`, `PlusAxiom` or `PlusDerivationTree`. The target is therefore stated over a **new** Prop-valued theoremhood predicate whose base case is TM⁺ theoremhood and whose constructors add an axiom set and the three naming rules, gated by a rule set. The full text is `probes/01_target-statements.lean`; it **elaborated this session** under `import FormalSystem` with no errors (eight `#check` outputs; `T1 T2 T3 : Prop`). The load-bearing definitions:

```lean
/-- `LCU` (report 03 §2.3) in primitive syntax: `⊡G≤(⟐α → ⟐(⟐β U ⟐α)) → (⟐α → ⟐G≤(⟐α ∨ (⟐β U ⟐α)))`. -/
def lcU (α β : PlusFormula) : PlusFormula :=
  (stab (gle ((dstab α).imp (dstab (untl (dstab β) (dstab α)))))).imp
    ((dstab α).imp (dstab (gle ((dstab α).or (untl (dstab β) (dstab α))))))

def IsLCAxiom  (ψ) : Prop := ∃ n α, 0 < n ∧ (ψ = lcN n α ∨ ψ = (lcN n α).reflectTime)
def IsLCUAxiom (ψ) : Prop := ∃ α β,       ψ = lcU α β ∨ ψ = (lcU α β).reflectTime

structure RuleSet where (clock aaFwd aaBwd : Bool)

/-- `θ⊡`: `b₀ ∧ ⊡G≤ ⋀_{b∈Q,i<k}((b ∧ aᵢ) → ⊡X p(b,i)) ∧ ⊡G≤ ⋀_{b≠b'} ¬(b ∧ b')`, anchored at the evaluation point. -/
def aaAnte (b₀ : Atom) (Q : List Atom) (k : ℕ) (a : ℕ → PlusFormula) (p : Atom → ℕ → Atom) : PlusFormula

inductive ExtDerivation (fc : FrameClass) (Ax : PlusFormula → Prop) (R : RuleSet) : PlusFormula → Prop
  | tm   (d : PlusDerivable fc [] φ)                       -- every TM⁺ theorem
  | ax   (h : Ax φ)
  | mp | nec | tnec | refl                                   -- MP, □-, G-necessitation, time reflection
  | clock (hR : R.clock = true) (hq : Fresh q φ) (d : ExtDerivation fc Ax R ((clockAnte q).imp φ))
  | aaFwd (hR : R.aaFwd = true) … (hsl : ∀ i < k, StateLocal (a i)) (hfresh : Q fresh in φ and every aᵢ)
          (hexh : ⊢ ⋁ᵢ aᵢ) (hexcl : ∀ i ≠ j, ⊢ ¬(aᵢ ∧ aⱼ)) (d : ⊢ (aaAnte b₀ Q k a p).imp φ)
  | aaBwd … (d : ⊢ (aaAnte b₀ Q k a p).reflectTime.imp φ)

def ExtComplete (Ax) (R) : Prop := ∀ φ, PlusValidZTime φ → ExtDerivation FrameClass.ZTime Ax R φ
def ExtSound    (Ax) (R) : Prop := ∀ φ, ExtDerivation FrameClass.ZTime Ax R φ → PlusValidZTime φ

def T1 : Prop := ExtComplete IsLCAxiom  RuleSet.none   -- the dispatch's literal question
def T2 : Prop := ExtComplete IsLCAxiom  RuleSet.all
def T3 : Prop := ExtComplete IsLCUAxiom RuleSet.all    -- the Reynolds-2001 transposition
```

Design notes, each a decision recorded below:

- **Theorems only.** The naming rules are validity-preserving, not truth-preserving, so — like `necessitation` in `PlusDerivationTree` — they live at the empty context, and `ExtDerivation` has no context parameter at all. `PlusDerivable fc [] φ` as the base case captures every TM⁺ theorem; the closure is the same set a leaf-level axiom extension would give, because the four structural rules are the same on both sides.
- **The AA side conditions are Reynolds 2001 Definition 4's, transposed.** The `aᵢ` are *state* formulas there (`C_c`, conjunctions of `E`-formulas); here `PlusFormula.StateLocal (a i)`, which is the landed predicate whose semantic content is `stab_state_only`. Exhaustiveness and exclusivity are *derivability* side conditions inside the same system, as in the source. The anchoring at the evaluation point (not at a global floor) is forced by the semantics: `aa_expand` (probe) establishes the run only on the forward cone of the current point, and the verbatim layer of the carrier violates the step clause, so a `□A`-global `θ` would be unsound.
- **`ExtSound IsLCAxiom RuleSet.none` is provable today** from `plus_soundness_ztime`, `lcN_plusValidZTime`, `lcN_reflectTime_plusValidZTime`, `plusValidIn_reflectTime`, and the closure of `PlusValidZTime` under MP and the two necessitations (routine). `ExtSound _ RuleSet.all` additionally needs the formula-level AA soundness (finding 3, missing). `ExtSound IsLCUAxiom _` additionally needs `LCU`'s ZTime validity (missing; semantic core landed by 871).

### 2. Deliverable (2): the architecture end to end

The blueprint is Reynolds 2001 §9-§15 (held, read this session). What follows is its transposition to L⁺ over ℤ-time, stage by stage, with the three places where the transposition is not a transcription made explicit (2.2 the shape of the final model, 2.3 the schema, 2.4 the cut).

#### 2.1 The three languages and the objects

- **Object language**: L⁺ over the sentence letters of `φ`. Closure `cl(φ⁺)`: subformulas of `φ⁺`, closed under one negation and one `⟐`, **and** containing, for every member, the literals of its separated CNF `sepZ` (so that past-determined and future-determined components are closure members). Finite.
- **Hues and colours** (Reynolds §10.1): a *hue* is a maximal consistent subset of the hue-closure at a point `(σ, t)`; a *colour* is the set of hues of a state — well defined because hues of the same state agree on every `⟐`-formula and every atom (`stab_state_only`, `atom_stab`; Reynolds Lemma 11). The state formula of a colour `c` is `γ_c := ⋀_{a∈c} ⟐δ_a ∧ ⋀_{a∉c} ¬⟐δ_a`.
- **Linear language**: L's `untl`/`snce` fragment over the alphabet of **colours**, with the `⟐`-formulas and `□`-formulas of the closure as sentence letters. The "linear content" of a walk is its colour word indexed by ℤ.
- **Fresh-atom language**: L⁺ plus the clock atom `q` and the automaton atoms `Q_f ∪ Q_b`.

The bad-walk formula is `χ₀ := A ⋀_{γ ∈ cl} (γ̄ → ⟐γ)`, where `γ̄` is `γ` with every maximal `⟐`/`□`-subformula read as a sentence letter: a walk is *bad* iff at some position some closure formula is true along it while `⟐γ` is absent from the colour there. Universal non-badness is what makes the `⟐`-case (⇐) of the truth lemma go through for emergent walks (Reynolds Lemma 27).

#### 2.2 The step-by-step construction and the shape of the final model

Reynolds builds a floored Ockhamist frame `(T, <, ≡)` — a set of ω-lines (constructed histories) with `≡` identifying points at the same level across lines — and quotients by `≡` to a Kripke structure `S = T/≡` whose fullpaths include *emergent* ones. The transposition: constructed histories are ℤ-lines, all passing through the anchor (the `q`-point) at time 0; `≡` identifies same-time points; the quotient is a **time-sliced digraph** — states carry their time, edges run from slice `n` to `n + 1` — with every bi-infinite walk passing through the single anchor state exactly once. Defects are cured in both directions (a point with no successor; a point with no predecessor), alternating, with pioneers and lulls in both directions.

Two landed facts fix what this final model must look like, and both are consistent with the construction:

- **No finite carrier, no finite width.** `ztime-no-finite-carrier-fmp.md` records (probe-level, sorry-free, Probe706/Probe710) that `θ := □(p ∨ Fp ∨ Pp) ∧ □(p → ¬Pp)` has no model on any regular ℤ-frame with a finite carrier, and that `Φ := θ' ∧ □(⊡Fp → ¬⊡¬Xp)` has no model on any `ofSlicedStep` frame with finite per-time fibres. A completeness proof must therefore produce, for a consistent `¬θ`-like formula, an infinite carrier with **infinitely many states at a single time**. The Reynolds quotient has exactly that: siblings and towers are added at every stage, so every slice is countably infinite. The design rule of that note ("the root paths of a finite class graph") is the quotient's own shape.
- **The quotient is not known saturated.** `S = T/≡` has infinite fibres (a state acquires new successors at every later stage), so neither `saturation_of_finite` nor `saturation_of_fib_finite` applies; it is not an oriented forest (states have many predecessors and many successors by construction), so 870's lemma does not apply directly; and a general countable doubly serial digraph can fail *Saturation* (derived: nest fibres `Fib(a_k, k)` with disjoint depth-`k` paths to `{x_j : j ≥ k}`; the intersection is empty). So *Saturation* of the final frame is a **genuine obligation** here, unlike in Reynolds' Kripke setting. The route of record is report 03 §1.2's: replace `S` by its **universal cover** `S̃` (components as orientation-keeping undirected multigraphs), which is an oriented forest, hence saturated by `saturation_of_orientedForest` (compiled), doubly serial, and two-way-bounded over `S` — and transfer truth along the covering map. That transfer is the one place a landed theorem does not fit as stated: `plus_invariance_of_isZTime` takes `[F.IsRegular]` on the **base** `F = S`, which bundles *Saturation* (`TaskFrame.lean:1189` ff., read this session), and `S`'s *Saturation* is exactly what is unknown. `exists_preimage_step_neg`'s own proof uses only `reflection` (read this session, `HistoryMorphism.lean:306-310`); whether *Saturation* is consumed anywhere in the lifting chain (`bwdSeq_spec`, `chain_spec`, `chain_step`, `chain_rel`) is unverified and is filed (finding 3, P6). Both the cover and the weakened invariance are shared with 878's decidability proof (its step reorder and (H5)).

#### 2.3 Ban preservation consumes the until-form schema, not `LC_n` (correction of record)

Reynolds 2001's completeness engine uses its limit-closure axiom in **one** place: Lemma 17, the preservation of clause K5A ("choosing hue `h'` after banned list `B` does not force a contravention"). The proof derives `⊢ Eα → EX((Eβ) U (Eα))` for `α :=` "hue `h'` here, no bad path, no `B`-contravention" and `β :=` "no colour in `V_{p₁}, …, V_{p_m}, V_q`", generalises to `⊢ AG(Eα → EX((Eβ) U (Eα)))`, and applies LC to get `⊢ Eα → EG((Eβ) U (Eα))` — an infinite path that never visits the relevant `V`-colours and hits `U_q` infinitely often, i.e. a bad path, contradiction. The transposition is literal: `⟐α → ⟐(⟐β U ⟐α)` iterated by `LCU` to `⟐α → ⟐G≤(⟐α ∨ (⟐β U ⟐α))`, with `β` a Boolean combination of the state-level `Q`-atoms. The **segment guard** `⟐β` throughout is what makes the limit path bad; `LC_n`'s consequent `⟐G≤ ⋀ᵢ(⟐αᵢ → F⟐α_{i+1})` constrains marker points only and says nothing about the stretch between them, so no choice of the `αᵢ` recovers the guard (derived; the obvious attempts — `αᵢ := α ∨ β`, or `α ∧ ⟐((¬v) U α)` — fail because the between-points are unconstrained and because `⟐((¬v) U α)` at a marker speaks of *some* walk, not the one being built). 865 finding 2 already observed that an until-commitment's guard is not discharged by the F-form; this finding says the same for the ban mechanism, which is the engine's only consumer of limit closure.

Consequences: (i) the schema of record for L⁺ at ZTime is `LCU` and its mirror, both ZTime-valid at the semantic level (`omega_chain` with `P` — the hook 871 restored for exactly this consumer) and both **undeclared** — P1 in finding 3; (ii) `LC_n`'s role in a language with `untl`/`snce` is unclear: it is Reynolds 2003's device for an F/P-only language whose completeness is a sketch, and whether it is derivable from `LCU` plus the rules, or vice versa, is open and is recorded as a question in P9; (iii) the ROADMAP sentence "the cure of record is `LC_n` plus progress measures in the state" should read "`LCU` plus the automaton-and-ban machinery" — the "progress measure" is Reynolds' banned list with its lull discipline (§11, §13.1), not an independent device.

#### 2.4 The doubled automaton, and the exact point at which separation is consumed

865 finding 5 established that two one-sided, clock-anchored automata suffice in shape. This section fixes what each automaton reads, what initialises it, and why that initialisation is legitimate — which is where `separationOver_ztime` enters, and the only place.

**What is checked.** Universal non-badness: for every bi-infinite walk `b` and position `i`, and every `γ ∈ cl`, if `γ̄` holds at `(b, i)` then `⟐γ ∈ colour(b(i))`. Every walk passes through the anchor state `w₀` at its `q`-time (clock 0). Split the condition at the cut: positions `i ≥ 0` are the forward automaton's, positions `i < 0` the backward one's.

**What is read.** Both automata read the colour word (state-level by `stab_state_only`/`atom_stab`), as Reynolds' reads the `E`-label sets. For a position `i ≥ 0` the truth of `γ̄` at `i` depends on the whole bi-infinite word. By separation, `γ̄ ≡ ⋀ⱼ (αⱼ ∨ βⱼ)` with `αⱼ` past-determined and `βⱼ` future-determined, syntactically pure (`pureLit_cnf`, compiled). The `βⱼ` at `i ≥ 0` depend on the forward word from `i` and are handled by Rabin acceptance (guess and verify, then determinise). The `αⱼ` at `i ≥ 0` are determined by the **past-type at the cut** and the colour word on `[0, i]`, by the one-step unrolling of `snce` over all pure-past closure formulas simultaneously (`(ψ S φ)(i+1) ⇔ φ(i) ∨ (ψ(i) ∧ (ψ S φ)(i))`, for pure-past `ψ, φ` — derived). So the forward automaton, **given the past-type at the cut**, is a deterministic Rabin automaton over colour words recognising "some violation at a position `≥ 0`, or the forward word fails to realise its own commitments"; the backward one is the mirror, given the future-type at the cut.

**The problem.** The run must be recorded in fresh atoms (the AA rule), and atoms are **state-valued** (`PlusTruthAt`'s `.atom` clause, compiled). The past-type at the cut is a property of the *walk*, not of the state `w₀`: different walks through `w₀` have different pasts. No state-level initialisation can name "the" past-type.

**The resolution, and the consumption point.** Let `PT(w₀) := {pt(σ) : σ through w₀ at 0}` — a function of `colour(w₀)`, hence state-level, hence expressible as a state formula. Initialise the forward automaton with the **product** over `pt ∈ PT(w₀)` of the `pt`-indexed automata (its initial state is a function of `γ_{colour(w₀)}`, so `θ_f` can state it), and require universal non-acceptance in **every** component. That is sound — every real walk through `w₀` must be non-violating for every `pt ∈ PT(w₀)`, not only for its own — exactly when, for every `pt ∈ PT(w₀)` and every forward half realised at `w₀`, some real walk has that past-type and that forward half. That is the **full-product lemma** (865 finding 5(b), derived from compiled `paste`, `paste_agreeUpTo`, `paste_agreeFrom`): the cluster's `(pt, ft)` set is `PT(w₀) × FT(w₀)`. And the lemma is only meaningful because every closure formula's truth at the cut **is** a function of `(pt, ft)` — which is what `separationOver_ztime` supplies and what fails without it: for an unseparated hue (e.g. `(a U c) S b`), pasting the past of one walk onto the future of another produces a hue that is neither walk's, so "non-violating for every hue in the colour" is **not** justified by any real walk, and the state-level initialisation is unsound. **Separation is consumed exactly once: in the legitimacy of initialising the two product automata at the cut from the cut colour's type sets.** The mirror statement holds for the backward automaton and `FT(w₀)`.

Two further checks close the loop (derived): the automata also detect a violation **at the cut itself** (a pure-future `γ` true along `b` with `⟐γ ∉ colour(w₀)` is a position-0 violation independent of `pt`), so an emergent walk's own `pt(b)` and `ft(b)` lie in `PT(w₀)` and `FT(w₀)` and its own component is among those run; and the run encoding `θ_f ∧ θ_b` is anchored at the evaluation point with `⊡G≤` / its mirror `⊡H≤`, which is the shape `aa_expand` (probe) actually establishes — a `□A`-global `θ` would be refuted on the verbatim layer of the carrier, where `inl u → inr (v, h)` for every `h`.

#### 2.5 The engine, stage by stage, with the status of each step

| Stage | Reynolds 2001 | Transposition | Status |
|---|---|---|---|
| A. System and consistency of `φ⁺` | Lemma 7: `φ⁺ = θ_A ∧ φ ∧ ¬Eχ₁` consistent via PLTL completeness (Claim 1), `⊢ Eγ ← γ` (Claim 2), AA (Claim 3) | `φ⁺ := clockAnte q ∧ θ_f ∧ θ_b ∧ φ ∧ ⊡¬χ₁` at the anchor; Claim 1 is a linear ℤ-word validity, derived through `completeness_ztime` + `ofTMSubst`; Claim 2 uses `stab_t`'s contrapositive; Claim 3 applies `aaBwd`, `aaFwd`, `clock` in turn | paper; compiled core for Claims 1-2 (P8); rules landed except AA (P3) |
| B. Hues, colours, down-and-across | §10, Lemma 12 | identical, with `⊡` for `E`, `⊡`-S5 schemata (`stab_k/t/4/5`, `box_stab`) for C9-C14, two-sided (up-and-across for past defects) | paper, routine |
| C. Chronicle, banning, lulls | §11-§13 | two-sided banned lists (one per automaton), lulls in both directions, `e_H = 2^{|H|}` | paper, transposable |
| D. Ban preservation | Lemma 17 (LC) | `LCU` and mirror (2.3) | paper; **needs `LCU` declared** (P1) |
| E. Limit, universal non-acceptance | Lemmas 19-20 | along every bi-infinite walk, both halves from the cut | paper, combinatorial |
| F. Fair scheduling | Lemmas 21-22 (evaporating graphs) | identical | paper, combinatorial |
| G. Truth lemma | §15, Lemmas 24-27 | `untl` and `snce` cases by fair scheduling in each direction; `⊡` (⇐) by Lemmas 25-27 with the two automata (2.4) | paper |
| H. Final frame | `(S, R, g)` is a Kripke structure | `S` is a time-sliced digraph, doubly serial; regularity via the universal cover and invariance without base *Saturation* (2.2) | **two missing Lean pieces** (P5, P6) |
| I. Soundness of the system | PLTL + CTL* axioms + AA Lemma 6 | `ExtSound`: landed except AA soundness (P2-P3) and `LCU` validity (P1) | formalizable now |

### 3. Deliverable (3): the ingredient table

Status key: **landed** (compiled in the tree), **owned** (an open task names it), **missing** (filed as a proposal below, id in brackets), **paper** (a step of the proof, owned by P9).

| # | Ingredient | Status | Evidence / proposal |
|---|---|---|---|
| 1 | `LC_n` valid at ZTime, backward `LC_n` | landed | `lcN_plusValidZTime`, `lcN_reflectTime_plusValidZTime` |
| 2 | `LCU` and mirror, declared and ZTime-valid | **missing** | [P1 `lcu_until_form_schema_ztime_validity`]; semantic core `omega_chain` with `P` landed |
| 3 | Clock rule, plain IRR | landed | `clock_irr_sound`, `irr_sound` |
| 4 | Cone carrier as a regular ℤ-frame: inr-layer `IsOrientedForest`, two-layer *Saturation* split, `TwoWayBounded coneF` | **missing** | [P2 `cone_unravelling_frame_layer_split_saturation`]; 870 supplies `saturation_of_orientedForest'`; `coneR` is probe-only |
| 5 | AA⊡ rule, forward and mirror, formula level with ZTime soundness | **missing** | [P3 `auxiliary_atoms_rule_soundness_ztime`]; depends on 4 |
| 6 | The extended system `ExtDerivation`, `ExtSound` at ZTime, targets T1-T3 as `Prop`s | **missing** (statement elaborated here) | [P4 `lplus_extended_proof_system_and_target_statement`]; `probes/01_target-statements.lean` |
| 7 | Separation at ZTime, syntactic purity of the CNF | landed | `separationOver_ztime`, `sepZ`, `pureLit_cnf` |
| 8 | Full-product lemma at the cut | **missing** (derived) | [P7 `stability_cluster_type_product_lemma`]; from `paste`, `paste_agreeUpTo/From` |
| 9 | Linear ℤ-word validity ⇒ TM⁺ theorem under substitution | **missing** (two-line bridge) | [P8 `linear_ztime_validity_tm_plus_substitution_bridge`]; `completeness_ztime` + `ofTMSubst` |
| 10 | `⊡` state-locality, `□` globality, atom stability | landed | `stab_state_only`, `box_global`, `atom_stab` |
| 11 | Pasting axioms PS/US and the `⊡ = ▷◁` factorization | landed | `paste_valid`, `untl_paste`, `stab_iff_ofut_opast` |
| 12 | Two-way-bounded invariance over ℤ (both frames regular) | landed | `plus_invariance_of_isZTime` |
| 13 | Invariance with **no** *Saturation* on the base | **missing** | [P6 `plus_invariance_base_without_saturation`] |
| 14 | Oriented-forest *Saturation* | landed | `saturation_of_orientedForest` (870) |
| 15 | Universal cover: forest, doubly serial, surjective two-way bounded covering map | **missing, unowned** | [P5 `universal_cover_oriented_forest_two_way_bounded`]; (H5)'s second half |
| 16 | Deterministic Rabin automaton for the violation language | paper (held: Safra/Piterman in corpus) | ω-automata, the ω-regular closure lattice and Büchi complementation are landed in CSLib upstream; McNaughton determinization to Muller is landed, sorry-free, in the local CSLib fork, which is on this project's own Lean toolchain. Determinization to Rabin or parity is `proof_wanted` even in the fork, the indexed conjunctive product is absent from both trees (≈100-150 lines to add), and the determinized automaton arrives existentially over `Type`. Not a Mathlib-absence refusal; a located and costed gap. (902 Finding 3) |
| 17 | Consistency of `φ⁺` (Lemma 7 analogue) | paper | P9 |
| 18 | Ban preservation with `LCU` (Lemma 17 analogue) | paper | P9 |
| 19 | Universal non-acceptance, two-sided (Lemmas 19-20) | paper | P9 |
| 20 | Fair scheduling (Lemmas 21-22) | paper | P9 |
| 21 | Two-sided truth lemma (§15) | paper | P9 [`two_sided_reynolds_engine_paper_proof`] |

**Backlog audit.** The nine proposals were run through `scripts/audit-task-proposals.sh` (exit 0; `task-proposals-audit.ndjson`). Dispositions of every non-`scope-blind`, non-trivial verdict:

- `duplicate-of-open 430 semantic_lift_and_track_a_assembly_valid_iff_allclosed` on P6, P7, P8 — **dismissed**: 430 is the base-language tableau spine's semantic lift (`Decidability/Verified`, `Correctness.lean`), unrelated in content; token overlap on "lift"/"valid"/"assembly".
- `subset-of-open 869 open_modal_invariance_ray_agreement_lifting` on P6 — **overlap on `HistoryMorphism.lean` only**: 869 is the demoted L^▷ invariance task; P6 is the L⁺ base-hypothesis weakening. If both are ever dispatched, add a serializing edge with P6 first (869 is off the critical path by ruling).
- `covered-by-closed 864/871` on P1 — **not covered**: 864 landed `lcN`, 871 restored `omega_chain`'s `P` hook and explicitly left `LCU` undeclared ("by design and per this task's explicit Non-Goal").
- `covered-by-closed 856` on P4 — **not covered**: 856 is the L^▷ proof system; P4 is the L⁺ extension.
- All remaining `covered-by-closed` verdicts carry semantic scores at or below 0.62 against records (443, 706, 718, 468, …) that are reports or refactors, not the lemmas proposed; none names any of the nine ingredients. Every proposal is **genuinely new** on inspection.

**Creation.** The formal-research-agent contract has no task-creation surface; following 865's precedent, the audited proposals are left in `task-proposals.json` for `/task` or the orchestrator's intake. Suggested dependency edges: P3 ← P2; P4 ← P3 (soundness arm) or P4 lands first with the soundness arm parametric; P9 ← P1 (so the paper proof cites a declared schema); P5 and P6 independent and shared with the decidability front.

### 4. Deliverable (4): the verdict

**GO — T3 as a staged paper programme, with the compiled ingredients landing now.** Every step of the Reynolds engine has a transposition with no located refutation; the three non-transcription points (final-model shape, until-form schema, cut initialisation) are each resolved on paper above with named compiled cores. The order: P1, P7, P8, P2, P3, P4 (Lean, each small, all independent of the automaton), P5 and P6 (Lean, shared with 878), then P9 (the paper proof, research). Soundness of the whole T3 system becomes a theorem at the end of P1-P4.

**NO-GO on T1 as stated — not refuted, reduced.** No architecture on record reaches `ExtComplete IsLCAxiom RuleSet.none`. It is **not** refuted (T1 is implied by T3 together with two admissibility facts), and it reduces to two precise open questions, both recorded in P9: (Q1) is `lcU α β` derivable in TM⁺ + `LC_n` + mirror at ZTime, for state-local `β`? (Q2) are `clock`, `aaFwd`, `aaBwd` admissible over TM⁺ + the schemata? Reynolds 2002 §8 and 2003 §4 mention Zanardo's "complicated axiom … alternative to the IRR rule"; Di Maio–Zanardo 1998 is not held. Nothing in this tree bears on either question.

**NO-GO on a Lean proof of T1, T2 or T3 today — a located obstruction.** The engine needs a **deterministic** ω-automaton (Rabin or parity) for the violation language, because the AA rule records a run as a function of the path prefix (determinism is what `coneSt` and Reynolds' Lemma 13/26 use); the language is ω-regular but not a safety language (it contains liveness via `untl`), so determinization (Safra/Piterman, held) is unavoidable in this design; and Mathlib at this pin has no ω-automata and no determinization (866 finding 8, 878 finding 8, ROADMAP ruling). That Mathlib-absence does not make the automaton unformalizable, and the obstruction is not the MSO one — re-measured in 902 Finding 3, the Lean obstruction relocates to four named components: (O1) determinization to Rabin or parity is `proof_wanted` even in the local CSLib fork; (O2) the indexed conjunctive product with a nameable initial state is absent from both CSLib trees, costed at 100-150 lines; (O3) determinization arrives as an existential over `Type`, not as nameable syntax the AA rule can use; (O4) nothing in CSLib touches the remaining rows of the ingredient table. A replacement by an explicit progress-measure argument that avoids determinization is conceivable but is a research design, not an ingredient; it is named in P9 as the only route to a Lean proof.

**Relation to the decidability-first ruling.** 878's paper theorem makes `{φ | PlusValidZTime φ}` recursive conditional on (H5), so *existence* of a recursive axiomatization is settled on paper and the live question is the natural one — which is exactly T3 versus T1. (H5)'s cover half (P5) is now owed to both fronts and is the cheapest shared item.

### Cross-Domain Synthesis

The logical and the order-theoretic content meet at the cut and nowhere else. Free pasting at a state (order theory) is what makes `⊡` factor (`⊡ = ▷◁`, logic) and what makes the stability cluster's type set a full product; separation (logic) is what makes a hue a function of that product; and the product is what makes a *state-level* initialisation of the two automata sound, which is the only way a state-valued atom can carry a run. So the semantics' defining feature pays for itself exactly once, at the anchor.

The same feature is what the ban mechanism cannot see: Reynolds' banned list reads colours, and the segment guard that the until-form supplies is a statement about the stretch between colours — the one thing the F-form `LC_n` does not constrain. That is why the schema has to change when the language acquires `untl`.

And the two fmp refutations, both probe-level facts about ℤ-time, turn out to describe the Reynolds quotient exactly — infinite, time-sliced, infinitely wide — which is the reason its *Saturation* is a real obligation and the reason the cover and 870's lemma are on the completeness front's critical path as well as the decidability front's.

## Decisions

1. **The target is stated parametrically, as three `Prop`s over one system**, rather than as the single sentence the dispatch names, because the dispatch's literal system (T1) and the system the architecture reaches (T3) differ in both schema and rules, and stating only one would misreport the programme. All three elaborate; none is a theorem.
2. **`LCU`, not `LC_n`, is recorded as the schema of record for this language**, on the strength of Reynolds 2001 Lemma 17 read this session. The ROADMAP sentence is to be amended (Recommendations), not silently contradicted.
3. **Separation's consumption point is recorded as the initialisation of the product automata at the cut**, refining 865 finding 5(c)'s "a single shared initial state" to "an initial state that is a function of the cut colour's type sets". The refinement is derived, not compiled.
4. **The final frame is the universal cover of the quotient**, not the quotient, and the two missing Lean pieces this forces (P5, P6) are filed rather than assumed. Direct *Saturation* of the quotient is not claimed and not refuted.
5. **The Lean obstruction is named as determinization**, but the alignment with the standing refusal on the MSO route does **not** hold, per 902 Finding 3: the MSO refusal rests on the needed material being absent everywhere reachable, and that is false here — CSLib upstream carries the ω-regular closure lattice including a proved `IsRegular.compl`, and the local CSLib fork carries McNaughton determinization to Muller, proved in both directions and sorry-free, on this project's own toolchain. There is also no second ω-automata project to open by the back door, because the determinization already exists; the residual Lean gap is (O1)-(O4) of that report.
6. **Nine tasks are proposed and audited, none created here** — the agent contract has no creation surface; the 865 precedent is followed and the gap is recorded in `issues.jsonl`.
7. **No `user_decision` is raised.** The verdict's three parts follow from the artifacts and the held source; the only preference-shaped question (whether to pursue T1 at all) is answered by the ruling already on record (decidability before completeness; the natural system is the open question), and the alternatives are recorded in P9 rather than put to the user mid-loop.
8. **No library change and no completeness claim** lands from this task.

## Recommendations

1. **File P1-P4 as one serialized batch** (`lean4`): declare `LCU` and its ZTime validity; the cone carrier with the layer split; the AA rules with soundness; the extended system with `ExtSound` and T1-T3 as `Prop`s. End state: a sound, conjecturally complete system in the tree, with the targets stated beside `plus_incomplete_base`'s "open at every class" sentence.
2. **File P5 and P6 now, on both fronts' behalf** (`lean4`): the universal cover and the base-*Saturation*-free invariance. P6 may be a hypothesis audit rather than new mathematics; its report should say which.
3. **File P7 and P8** (`lean4`, small): the cut product lemma and the linear bridge; both are compiled-core lemmas the paper proof will cite by name.
4. **File P9** (`formal`, research): the two-sided paper proof at Reynolds-2001 rigour, owning Q1 and Q2 and the progress-measure question.
5. **Amend two records, cheaply**: `specs/ROADMAP.md`'s "cure of record is `LC_n` plus progress measures in the state" → "`LCU` and its mirror plus the automaton-and-ban machinery (Reynolds 2001 §11-§13); `LC_n`'s role in a language with `untl`/`snce` is open"; and `PlusLCSchema.lean`'s `LCU` docstring section may cite P1 once it lands. `docs/theorem-index.md`'s "completeness of any recursive extension of TM⁺ is open at every frame class" stands.
6. **Do not file** a Lean formalization of T3's completeness proof, until P9 reports whether a progress-measure replacement exists; and do not file a *determinization* project, which is largely done in the local CSLib fork — the live question is whether to depend on it, and 902 Finding 4 recommends not depending on it now.

## Risks & Mitigations

- **Risk**: the one-step unrolling argument of 2.4 is stated for syntactically pure-past formulas; `sepZ`'s literals are `IsUOnly ∨ IsSOnly` over `USForm` with `⊡`/`□`-leaves, and the transfer to `PlusFormula` goes through `toPlus_sepFormUS`. *Mitigation*: the automaton is paper-level in any case (item 16); P9 should pin the alphabet and the unrolling against `Packaging.lean`'s actual literal shape.
- **Risk**: the mixed-family case of the layer split (865 finding 4's residual risk) costs more than expected. *Mitigation*: P2 is scoped to exactly that lemma plus the inr-forest discharge; 870's `saturation_of_orientedForest'` takes the `hgen` form P2 needs.
- **Risk**: *Saturation* turns out to be essential somewhere in the lifting chain, so P6 fails and the cover route needs the quotient saturated after all. *Mitigation*: P6 is written to report the exact step in that case; the fallback is a direct *Saturation* argument for the sliced quotient, which this report neither claims nor refutes.
- **Risk**: T1 is read as refuted. It is not; it is unreached, with Q1/Q2 named. *Mitigation*: stated three times above.
- **Risk**: the determinization obstruction is read as blocking the paper programme. It blocks only the Lean proof; Safra/Piterman are held. *Mitigation*: finding 4's third paragraph.
- **Risk**: the proposals are created without the suggested edges and P3 lands before P2's carrier. *Mitigation*: the edges are listed in finding 3.

## Appendix

### Evidence tier by claim

| Claim | Tier |
|---|---|
| T1, T2, T3 and `ExtDerivation` are well-typed under `import FormalSystem` | elaborated (this session) |
| All names in finding 0 exist at the cited locations | compiled (grep this session) |
| Reynolds 2001 uses LC only in Lemma 17; LC there is the until-form; AA needs a deterministic automaton | held (read this session) |
| `LC_n` cannot discharge the segment guard | derived |
| Past-types at `i ≥ 0` are determined by the cut past-type and the colour word on `[0, i]` | derived |
| State-level initialisation at the cut is sound iff the cut hue splits into independent halves; separation is consumed there and only there | derived |
| The Reynolds quotient is time-sliced with infinite slices; a general countable digraph can fail *Saturation* | derived |
| Finite-carrier and finite-width fmp fail at ZTime | probe (Probe706, Probe710; cited via the context note, not re-run) |
| `plus_invariance_of_isZTime` demands `[F.IsRegular]` on the base; `exists_preimage_step_neg` uses only `reflection` | compiled / read |
| The universal cover is an oriented forest with a two-way bounded covering map | paper (report 03 §1.2, amended by 884) |
| Mathlib has no ω-automata or determinization | read — re-verified directly in 902 against `.lake/packages/mathlib` at `79d0395a` (tag `v4.33.0-rc1`): `Mathlib/Computability/` carries DFA, NFA, EpsilonNFA, RegularExpressions, MyhillNerode and Language and no ω-automaton file, and a case-insensitive grep over `Mathlib/` for the Büchi, Muller, Rabin and ω-regular name stems returns zero files; the `[CARRIED-UNVERIFIED]` tag is removed |

### Locators

- `specs/879_.../probes/01_target-statements.lean` — the statements, with the exact `lean_run_code` output recorded in its header
- `specs/879_.../task-proposals.json`, `task-proposals-audit.ndjson` — P1-P9 and verdicts
- Reynolds 2001: `/home/benjamin/Projects/Literature/sources/reynolds_2001/sec04_…` (§9 three languages, Lemma 7), `sec05_…` (§10 hues/colours, §11 banning), `sec06_…`/`sec07_…` (§11.1 lulls, §12 chronicles, §13 Lemma 17, §14 Lemmas 19-20), `sec08_…`/`sec09_…` (§14.3 Lemmas 21-22, §15 truth lemma, Lemmas 24-27)
- `FormalSystem/Metalogic/NamingRules.lean` module docstring, "The Auxiliary-Atoms expansion, and where it stops" — the blocker P2 discharges
- `.claude/context/project/logic/domain/ztime-no-finite-carrier-fmp.md` §§1-7 — the two fmp refutations and the sliced-graph diagnosis
