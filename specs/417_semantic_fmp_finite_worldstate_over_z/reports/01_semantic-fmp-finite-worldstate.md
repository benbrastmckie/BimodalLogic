# Research Report: Semantic FMP with Finite WorldState over ℤ

- **Task**: 417 `semantic_fmp_finite_worldstate_over_z`
- **Date**: 2026-07-28
- **Session**: sess_1785280411_23b0e6_417
- **Agent**: lean-research-hard-agent (hard mode: H2, H3 Tier 1, H4)
- **Reference tier**: Tier 1 (literature-backed — paper `cor:tm-decidability` + Comments/fix.md C6)
- **Dependency**: 414 (Ω-free maximal-history semantics; status `researching` — NOT yet landed;
  current repo semantics still carries the `Omega`/`ShiftClosed` parameters)

## Executive Summary

1. **Premise CONFIRMED** (highest-priority question): the entire
   `FormalSystem/Metalogic/Decidability/FMP/` directory contains **zero occurrences of
   `TruthAt`** (verified by grep over all five files). Its "FMP" theorems are statements about
   MCS *membership* (`phi ∉ S.carrier`), not semantic satisfaction. Separately,
   `validity_decidable` (`Metalogic/Decidability/Correctness.lean:78`) is literally
   `Classical.em (⊨ φ)`. Both fix.md C6 claims about the repo are accurate.
2. The **statement** of the semantic FMP is straightforward to write against both the current
   and the post-refactor semantics (concrete signatures below); the finiteness constraint sits
   on `F.WorldState` (`Finite F.WorldState` or the existing `FiniteTaskFrame ℤ` bundle), never
   on `D = ℤ`.
3. The **proof** is genuinely hard. Neither existing construction delivers it directly:
   the FMP tree has finite worlds but no truth lemma; the sorry-free
   `BXCanonical.completeness_discrete` countermodel has a `ℤ` carrier but **infinite**
   `WorldState := FamIdx × ℤ`; the tableau bridge (`Verified/Bridge/`) has a real
   TruthAt-connected truth lemma over ℤ carriers but `WorldState := WorldIndex × (Set ι × Set ι)`
   with `WorldIndex = Nat` — also infinite as a type. A finite-W collapse is new mathematics
   (quasimodel/selective-filtration territory, as fix.md C6 itself notes by citing mosaics).
4. **Mathlib has no modal-logic filtration** (verified negative: `lean_leansearch` returns only
   measure-theoretic and filtered-algebra `Filtration`s). All filtration machinery is
   hand-built in-repo and much of it is reusable.
5. **Decidable model checking** for finite-W-over-ℤ decomposes into a tractable path-local part
   (temporal operators via ultimately-periodic histories — the repo's
   `Verified/Bridge/TemporalGate.lean` guarded-witness machinery is a hand-rolled version of
   exactly this) and a hard box part (`∀` over ALL maximal histories of the frame, an
   uncountable set even for finite W). The box case is the most-likely-underestimated
   sub-problem and needs an explicit finite-presentation reduction; concrete options below.
6. The Decidability tree is currently **sorry-free** (grep for real `sorry` tokens: none; the
   hits are all doc-comments).

---

## Findings

### H3 Tier 1 lemma-level mapping table

| Paper claim (location) | Informal statement | Target Lean name | Lean signature | Status |
|---|---|---|---|---|
| `cor:tm-decidability` (JPL/possible_worlds.tex:3296-3299) | TM, TM_f, TM_d, TM_c, TM_dc decidable | (out of scope for this task; tableau programme owns it) | — | to-prove (elsewhere) |
| Proof text step 1 (tex:3301-3302) "Completeness + recursive axiomatization ⇒ theorems r.e." | `ValidDiscrete φ → Derivable .Discrete [] φ` | `FormalSystem.Metalogic.BXCanonical.completeness_discrete` | `(φ : Formula) : ValidDiscrete φ → Derivable FrameClass.Discrete [] φ` | **exists, sorry-free** (axioms: propext, Classical.choice, Quot.sound; verified via `lean_verify`) — but stated against the *current* Ω-semantics; rebases under 415 |
| Proof text step 2 (tex:3302-3303) "FMP ⇒ non-theorems r.e." — the semantic FMP this proof cites | Satisfiable over Discrete class ⇒ satisfiable with finite W over ℤ | `semantic_fmp_int` (NEW — this task's core deliverable) | see §Target Statement | **to-prove** (does not exist in any form connected to `TruthAt`) |
| Proof text step 2 (tex:3303) "finite models may be effectively enumerated and checked" | Decidable model checking on the finite-W-over-ℤ presentation | `FinitePresentation.checkSat` + correctness (NEW) | see §Decidable Model Checking | **to-prove**; paper-side restatement as "finite W over ℤ" is a mandatory fix.md C6 edit regardless |
| Proof text step 3 (tex:3304) "theorems and non-theorems both r.e. ⇒ decidable" | Post's theorem-style glue | (paper-level; would need a computability framing in Lean) | — | to-prove (elsewhere; not this task per fix.md — tableau route supplies the verified procedure) |
| fix.md C6 claim: "Lean FMP theorems … never connected to TruthAt" | `FMP/FMP.lean` theorems are syntactic | (verification, not a target) | see §Premise Check | **CONFIRMED** |
| fix.md C6 claim: "`validity_decidable` is literally `Classical.em`" | vacuous classical disjunction | (verification) | `Decidability/Correctness.lean:78-81` quoted below | **CONFIRMED** |

### Premise Check (Research Question 1) — CONFIRMED

`grep -rn "TruthAt" FormalSystem/Metalogic/Decidability/FMP/` → **zero hits** across all five
files (`ClosureMCS.lean`, `Filtration.lean`, `FiniteModel.lean`, `TruthPreservation.lean`,
`FMP.lean`; 1,463 lines total). The flagship theorems, verbatim
(`FormalSystem/Metalogic/Decidability/FMP/FMP.lean:204-222`):

```lean
theorem mcs_finite_model_property (phi : Formula)
    (h_not_provable : ¬Derivable FrameClass.Base [] phi) :
    ∃ (S : ClosureMCSBundle phi), phi ∉ S.carrier ∧
    Finite (FilteredWorld phi)

theorem fmp_contrapositive (phi : Formula)
    (h_all_mcs : ∀ (S : ClosureMCSBundle phi), phi ∈ S.carrier) :
    Derivable FrameClass.Base [] phi
```

"Truth" here is `phi ∈ S.carrier` — set membership in a closure MCS. No `TaskModel`, no
`WorldHistory`, no `TruthAt`. Moreover two of the five advertised results are vacuous:
`fmp_size_bound` (FMP.lean:237-242) concludes `bound = 2 ^ card ∧ True`, and
`filtered_world_bound` (FMP.lean:183-189) concludes `∀ _S, True`. Also confirmed
(`Decidability/Correctness.lean:78-81`):

```lean
theorem validity_decidable (φ : Formula) :
    (⊨ φ) ∨ ¬(⊨ φ) := by
  exact Classical.em (⊨ φ)
```

The task description's premise is accurate in full. `TruthPreservation.lean`, despite its name,
also never mentions `TruthAt` (it preserves *membership* across the filtration quotient).

### Target Statement (Research Question 2)

Current semantics (`Semantics/Truth.lean:128-137`): `TruthAt (M : TaskModel F)
(Omega : Set (WorldHistory F)) (τ : WorldHistory F) (t : D) : Formula → Prop`, box case
`∀ σ ∈ Omega, TruthAt M Omega σ t φ`. Post-414 target (per 414's task description): Omega and
`ShiftClosed` removed; box quantifies over **maximal** histories; validity/satisfiability
binders lose `Omega`/`ShiftClosed`. No maximality predicate exists in-repo yet
(`lean_local_search "Maximal"`: only Mathlib's generic `Maximal` from `Order/Minimal.lean` and
the unrelated `Metalogic.Core.MaximalConsistent`); 414 will likely define the extension order
and use Mathlib's `Maximal` or a bespoke `WorldHistory.IsMaximal`. The statement below is
written to be robust to that choice — the only 414-sensitive tokens are the `TruthAt` arity and
the maximality predicate name, both isolated in `SatisfiableDiscrete` and the conclusion binder.

```lean
/-- Satisfiability over the Discrete frame class (post-414 form; binders match `ValidDiscrete`,
Semantics/Validity.lean:187-193, minus Omega/ShiftClosed, plus maximality). -/
def SatisfiableDiscrete (φ : Formula) : Prop :=
  ∃ (D : Type) (_ : AddCommGroup D) (_ : LinearOrder D) (_ : IsOrderedAddMonoid D)
    (_ : SuccOrder D) (_ : PredOrder D) (_ : IsSuccArchimedean D) (_ : IsPredArchimedean D)
    (_ : Nontrivial D)
    (F : TaskFrame D) (M : TaskModel F) (τ : WorldHistory F) (_ : τ.IsMaximal) (t : D),
    TruthAt M τ t φ

/-- **Semantic FMP over ℤ** (the theorem cor:tm-decidability's proof text cites). -/
theorem semantic_fmp_int (φ : Formula) (h : SatisfiableDiscrete φ) :
    ∃ (F : TaskFrame ℤ) (_ : Finite F.WorldState) (M : TaskModel F)
      (τ : WorldHistory F) (_ : τ.IsMaximal) (t : ℤ),
      TruthAt M τ t φ

/-- Contrapositive form the enumeration argument consumes (¬`ValidDiscrete` ⇒ finite-W-over-ℤ
countermodel). `φ.neg = φ.imp .bot`, so `TruthAt … φ.neg` is definitionally `¬TruthAt … φ`. -/
theorem exists_finite_int_countermodel (φ : Formula) (h : ¬ValidDiscrete φ) :
    ∃ (F : TaskFrame ℤ) (_ : Finite F.WorldState) (M : TaskModel F)
      (τ : WorldHistory F) (_ : τ.IsMaximal) (t : ℤ),
      TruthAt M τ t φ.neg
```

Optional strengthening (paper's bound): `Nat.card F.WorldState ≤ 2 ^ (subformulaClosure φ).card`
(`FormalSystem.Syntax.subformulaClosure` exists — `Syntax/SubformulaClosure/Closure.lean` — with
`Fintype` instance `FMP.subformulaClosureFintype`, FiniteModel.lean:121).

Two packaging notes:
- `Semantics.FiniteTaskFrame ℤ` already exists (`Semantics/TaskFrame.lean:293-296`, field
  `finite_world : Finite WorldState`) and is the natural bundle for the conclusion; the unbundled
  `(F, Finite F.WorldState)` form above is friendlier to the eventual model-checking consumer.
  Either is fine; pick one and stay with it.
- If 414 lands `satisfiable` Omega-free, `SatisfiableDiscrete` should be derived from it rather
  than duplicated. Current `satisfiable` (Validity.lean:129-133) has no discrete variant — a
  Discrete-class satisfiability predicate must be **added** in either case.

### Finiteness Placement (Research Question 3) — on `WorldState`, as `Finite`

`TaskFrame.WorldState : Type` (`Semantics/TaskFrame.lean:99-101`). The repo convention is the
`Finite` typeclass (not `Fintype`): `FiniteTaskFrame` stores `finite_world : Finite WorldState`,
and `FilteredWorld.finite` (FiniteModel.lean:137) is a `Finite` instance. `Finite` is
proof-irrelevant and right for the FMP statement; the model-checking side needs computation and
should carry `Fintype` + `DecidableEq` in its own `FinitePresentation` structure (transport via
`Fintype.ofFinite` — verified working, see instance check below). D-side instances for ℤ, all
**verified present in the pinned Mathlib** via `lean_run_code` (imports
`Mathlib.Data.Int.Interval`, `Mathlib.Data.Int.SuccPred`, `Mathlib.Order.SuccPred.Archimedean`):
`LocallyFiniteOrder ℤ`, `SuccOrder ℤ`, `PredOrder ℤ`, `IsSuccArchimedean ℤ`,
`IsPredArchimedean ℤ`, `Nontrivial ℤ`, `Finset.Icc`-bounded `Decidable` quantifiers,
`Fintype.decidableForallFintype`. Note `SuccOrder ℤ` needs `Mathlib.Data.Int.SuccPred` — it is
NOT reachable from the imports `Validity.lean` currently has, so instantiating
`SatisfiableDiscrete` at ℤ will need that import.

### Filtration (Research Question 4)

**Mathlib: none.** `lean_leansearch "filtration finite model property modal logic Kripke frame"`
returns only `MeasureTheory.Filtration` and `RingTheory.FilteredAlgebra.IsFiltration` — no modal
logic, no Kripke semantics, no FMP infrastructure exists in Mathlib. Any filtration is
hand-built.

**In-repo, reusable toward a semantic filtration** (all in `Metalogic/Decidability/FMP/` unless
noted):
- `subformulaClosure` + `Fintype` instance (Syntax + FiniteModel.lean:121) — the closure index.
- `FilteredWorld phi := Quotient (ClosureMCSSetoid phi)` (Filtration.lean:158) with
  `Finite (FilteredWorld phi)` (FiniteModel.lean:137) and injective
  `filteredCharacteristicSet` (FiniteModel.lean:88-96) — a finite world type keyed to φ.
- `RefinedFilteredTaskFrame phi : TaskFrame D` (Filtration.lean:197), polymorphic in D, packaged
  as `FiniteFilteredTaskFrame D phi : FiniteTaskFrame D` (FiniteModel.lean:159) — a genuine
  `TaskFrame` (nullity/comp/converse discharged) with finite worlds, instantiable at ℤ.
- `filteredWorldMem` (Filtration.lean:300) — well-defined closure-membership on the quotient,
  the natural valuation seed (`M.valuation ⟦S⟧ p := filteredWorldMem phi (.atom p) … ⟦S⟧`).

**What is missing is precisely the truth lemma**: `TruthAt M τ t ψ ↔ ψ ∈ (representative at
(τ,t))` for ψ in the closure — and for THIS logic that lemma is hard: (i) `untl`/`snce` are not
preserved by naive filtration (the classical problem; until needs interval witnesses), and
(ii) box quantifies over all maximal histories of the *quotient* frame, which has more (or
different) histories than the original — collapsing W changes the history space, and nothing
short of a bisimulation-style argument restores box truth. fix.md C6 itself flags the field
standard for logics of infinite frames: **mosaics/quasimodels** (Burgess 1984 §3;
Caleiro–Viganò–Volpe 2013, EXPSPACE for a tense+S5 bimodal logic). Expect the proof to be a
quasimodel argument (finite set of "moment types" + coherence + a realization lemma producing an
ultimately-periodic model over ℤ), not a textbook filtration.

**Proof-route comparison** (all three candidate feedstocks verified):

| Route | Feedstock | Carrier | WorldState | TruthAt-connected? | Gap to finite-W-over-ℤ FMP |
|---|---|---|---|---|---|
| A. Semantic filtration of an arbitrary satisfying model | the given model | arbitrary D → must move to ℤ too | quotient of arbitrary W (finite ✓) | must prove truth lemma | truth lemma for untl/snce/box + D-change to ℤ; hardest as stated |
| B. Completeness countermodel | `BXCanonical.completeness_discrete` (sorry-free) via `Chronicle/` | ℤ ✓ (`multiFamTaskFrame FamIdx : TaskFrame ℤ`, ChronicleMonadicBridge.lean:80-81,141) | `FamIdx × ℤ` — **infinite** | ✓ (it witnesses ¬ValidDiscrete) | collapse `FamIdx × ℤ` to finitely many states preserving truth — a state-collapse/periodicity lemma; also rebases under 415 |
| C. Tableau branch model | `Verified/Bridge/` truth lemma (`BranchTruthAt`, IntTruth.lean) | ℤ ✓ | `WorldIndex × (Set ι × Set ι)`, `WorldIndex = Nat` — infinite type, but `normWorld` collapses valuation to finitely many known worlds (IntTruth.lean "Correction 10") | ✓ (signed truth lemma against real `TruthAt`) | quotient by `normWorld`-equivalence + finitely many region codes → genuinely finite W; needs open-branch existence for satisfiable φ (tableau completeness, i.e. the 410-412 programme) |

**Recommendation**: Route C is mathematically closest — the branch model is already
"finite-W-in-disguise" (finitely many known worlds × finitely many region codes, with all other
worlds reading as copies via `normWorld`) and its truth lemma is done for atom/bot/imp/box with
untl/snce in progress under the task-165 phase-7 work. But it depends on tableau completeness
(an open branch must exist for every satisfiable formula), which is the 410-412 programme's
still-open half. Route B is self-contained today (completeness_discrete is sorry-free) but its
collapse lemma (`FamIdx × ℤ` → finite) is new mathematics of quasimodel difficulty, and 415 will
rebuild the feedstock anyway. The plan should sequence: (1) land statements + the
finite-presentation layer (independent of 414's exact predicate names), (2) build the
collapse/realization lemma against whichever of B/C is sorry-free **after 414/415 land**,
deciding then. Do not start the truth-lemma work before 414 lands — every case of it touches
`TruthAt`'s signature.

### Decidable Model Checking (Research Question 5) — the underestimated half

The paper-side argument needs: finite presentations enumerable + `sat-in-P` decidable per
presentation. Proposed presentation layer (new, small, independent of 414):

```lean
/-- A finitely presented discrete task frame: worlds `Fin (n+1)`, a decidable one-step
relation, a decidable valuation. `toFrame` interprets duration `d : ℤ` as signed `step`-path
reachability (d ≥ 0: d-fold composition; d < 0 via converse), which discharges
`nullity_identity`, `forward_comp`, `converse` by construction. -/
structure FinitePresentation where
  n : ℕ
  step : Fin (n + 1) → Fin (n + 1) → Bool
  val : Fin (n + 1) → Atom → Bool

def FinitePresentation.toFrame (P : FinitePresentation) : TaskFrame ℤ
def FinitePresentation.toModel (P : FinitePresentation) : TaskModel P.toFrame
def FinitePresentation.checkSat (P : FinitePresentation) (φ : Formula) : Bool
theorem FinitePresentation.checkSat_correct (P : FinitePresentation) (φ : Formula) :
    P.checkSat φ = true ↔
      ∃ (τ : WorldHistory P.toFrame) (_ : τ.IsMaximal) (t : ℤ), TruthAt P.toModel τ t φ
```

**Do not aim at `Decidable (TruthAt M τ t φ)` directly** — it is false as an instance target:
`τ` is an arbitrary function out of ℤ (infinite data), and the box case quantifies over ALL
maximal histories, an uncountable set even for finite W (with a total `step`, every function
`ℤ → W` along edges is a history). Decidability is recovered only at the level of the finite
presentation, through two reductions, and these are the real content:

1. **Temporal quantifiers (untl/snce)**: over a finite-W frame, restrict attention to
   ultimately periodic histories (period ≤ lcm of cycle lengths reachable in the `step` graph;
   crude bound `(n+1)!` or per-lasso `≤ n+1`). Truth of any fixed subformula along an ultimately
   periodic history is itself eventually periodic in `t`, so `∃ s > t` / `∀ r ∈ (t,s)` reduce to
   `Finset.Icc` searches over one window + one period (bounded-quantifier decidability over
   `Finset.Icc (a b : ℤ)` verified available). The repo has a hand-rolled analogue:
   `temporalWitnessCheck` (`Verified/Bridge/TemporalGate.lean:264-268`, ten guarded-witness/ray
   conditions with consumption lemmas) and the untl/snce halves of `BranchTruthAt`
   (IntTruth.lean, "positive until/since halves, sorry-free" per recent commits) — reusable
   patterns, though branch-indexed rather than presentation-indexed.
2. **Box**: `∀ τ' maximal at time t` must be reduced to a finite check. The honest statement of
   the needed lemma (this is a small quasimodel/pumping theorem, not an instance derivation):
   *every maximal history through a finite-W frame is subformula-equivalent at every time to an
   ultimately periodic one with period and offset bounded in `n` and `|subformulaClosure φ|`* —
   so box reduces to the finitely many lasso-shaped histories below the bound. This lemma is
   ALSO the realization half of the FMP proof itself (routes B/C both need it), which is the
   deep reason fix.md pairs the two deliverables: **the FMP and decidable model checking share
   one core lemma** (bounded-periodic realization). Plan them as one artifact, not two.

If the plan needs a de-risked fallback: `checkSat` restricted to the box-free (purely temporal)
fragment is provable with machinery-level effort; the box case is the research-grade part and
should be its own phase with an explicit [BLOCKED]-escape documented.

### Preserved Assets vs Superseded (Research Question 6)

**Preserved (reused by this task)**: `subformulaClosure` + card/Fintype
(`Syntax/SubformulaClosure/Closure.lean`); all of `FMP/ClosureMCS.lean` (restricted Lindenbaum:
`closure_mcs_exists_containing`, bounds); `FMP/Filtration.lean` (`ClosureMCSBundle`,
`FilteredWorld`, `RefinedFilteredTaskFrame`, `filteredWorldMem`); `FMP/FiniteModel.lean`
(finiteness instances, `FiniteFilteredTaskFrame`); `Semantics.FiniteTaskFrame`
(TaskFrame.lean:293); the `Verified/Bridge/` truth-lemma corpus (region/gap machinery,
`temporalWitnessCheck`, `BranchTruthAt` cases) as pattern and possibly as feedstock (route C);
`BXCanonical.completeness_discrete` (route B feedstock, pending 415 rebase).

**Superseded / demoted by this task**: `FMP/FMP.lean`'s five theorems stop being "the FMP" —
they remain valid completeness-side lemmas but the paper citation moves to `semantic_fmp_int`;
`fmp_size_bound` and `filtered_world_bound` (vacuous `True` conclusions) should be deleted or
restated with content; `validity_decidable` and `validity_has_decision_procedure`
(Correctness.lean:78-92, both classically vacuous) should be deleted or renamed to stop
advertising decidability. `FMP/TruthPreservation.lean` is membership-preservation and keeps its
role in the syntactic tree only.

**Rebased under 414/415 (not this task's to fix, but this task must wait for)**: `TruthAt`,
`valid`, `ValidDiscrete`, `satisfiable` signatures; `soundness_discrete`;
`completeness_discrete`; the whole `Verified/Bridge` Omega plumbing (`regionOmega` becomes a
maximal-history fact).

### Sorry Inventory — Decidability tree (Research Question 7)

**Zero `sorry` tokens** in `FormalSystem/Metalogic/Decidability/` (strict grep excluding
comments/docstrings; the only matches are prose mentions in doc-comments at
`Verified/Termination/TimeTypeBound.lean:1964`, `Propositional/Decidable.lean:27`,
`Verified/Bridge/IntTruth.lean:527,847,860` — all describing sorry-FREE status). Elsewhere in
`Metalogic/` (context, not this tree): `BXCanonical/Completeness.lean` doc-comments reference a
historical "terminal sorry" but `completeness_discrete` verifies clean
(propext/Classical.choice/Quot.sound only); `WeakCanonical/` prose references Boneyard'd
sorry-tainted material that lives under `Boneyard/`.

## Literature Proof Structure (Tier 1)

Source: `cor:tm-decidability` proof, `/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex:3300-3305`; corrections mandated by `/home/benjamin/Philosophy/Papers/PossibleWorlds/Comments/fix.md` §C6 (lines 177-195).

| Step | Paper text | Lean translation consideration |
|---|---|---|
| 1 | Completeness + recursive axiomatization ⇒ theorems r.e. | `completeness_discrete` (exists, rebased by 415); "r.e." framing stays paper-level |
| 2a | FMP: every non-theorem fails in some finite model | `exists_finite_int_countermodel` — THE deliverable; "finite model" must read "finite W over ℤ" (fix.md C6 mandatory edit: literal reading false since every model has infinite D) |
| 2b | finite models effectively enumerated and checked | `FinitePresentation` enumeration + `checkSat_correct`; box case is the hard core (shared realization lemma) |
| 3 | Both r.e. ⇒ decidable | paper-level glue; verified decision procedure is the tableau programme's deliverable (165/410-412), not this task's |

## Adversarial Self-Verification

| Claim | Source/Counterexample | Verification Method | Confidence |
|---|---|---|---|
| FMP tree never mentions `TruthAt` | grep over all 5 files, 0 hits | direct file scan (Read + grep) | High |
| `validity_decidable` = `Classical.em` | Correctness.lean:78-81 quoted verbatim | Read | High |
| `completeness_discrete` sorry-free | axioms = propext, Classical.choice, Quot.sound | `lean_verify` on fully qualified name | High |
| Mathlib has no modal filtration | only MeasureTheory/RingTheory Filtrations returned | `lean_leansearch` (named, rate-limited tool) | High (negative result; also checked `lean_loogle`) |
| ℤ instances (`SuccOrder`, `LocallyFiniteOrder`, Archimedean, bounded-∀ decidability, `Fintype.ofFinite`) all available; `SuccOrder ℤ` needs `Mathlib.Data.Int.SuccPred` import | compiling snippet | `lean_run_code` (first attempt failed on wrong module path AND missing Int.SuccPred import — both corrected and re-verified green) | High |
| BXCanonical countermodel has infinite `WorldState = FamIdx × ℤ` | ChronicleMonadicBridge.lean:80-81,141 | grep + Read | High |
| Bridge model `WorldState = W × (Set ι × Set ι)`, `W = WorldIndex = Nat` (infinite type, finite-in-disguise via `normWorld`) | Omega.lean:136-137, IntTruth.lean Correction 10 | Read | High |
| Box-case decidability requires a bounded-periodic realization lemma shared with the FMP proof | argument from finite-W path structure; uncountable maximal-history set (total `step` ⇒ all edge-respecting `ℤ → W` functions are histories) | reasoned analysis, NOT machine-checked | Medium — the *difficulty* claim is solid; the exact bound shape (period ≤ f(n, closure)) is a plan-time design decision |
| Route C branch model collapses to genuinely finite W | `normWorld` normalisation exists, but the quotient construction is proposed, not present | Read (IntTruth.lean header) | Medium — collapse is plausible, unproven |

**Adversarial challenges applied**:
1. *Is the premise really right — could `TruthPreservation.lean` be the hidden TruthAt link?*
   No: grep is decisive; the file preserves MCS-membership across the quotient, never semantic
   truth. Premise stands.
2. *Is the description's "replace reliance on FMP.lean" fair, given `completeness_discrete` is
   sorry-free?* Yes — completeness is a different theorem; the FMP tree's own results genuinely
   never reach `TruthAt`, and the paper's proof text cites an FMP the repo lacks.
3. *Modified after verification*: an early draft recommended targeting
   `Decidable (TruthAt …)` instances directly; killed after working through the box case
   (uncountable maximal-history space) — replaced with the `FinitePresentation.checkSat`
   formulation and the shared realization lemma. Also: first instance-check snippet failed on a
   stale module path (`Mathlib.Order.Interval.Finset.Int` does not exist in the pinned Mathlib;
   correct module is `Mathlib.Data.Int.Interval`) — recorded so the planner does not repeat it.

## Recommendations for Planning

1. **Hard gate on 414**: no phase that states or proves against `TruthAt` should be dispatched
   before 414 lands; the statements above isolate the 414-sensitive tokens.
2. Phase the work: (i) `SatisfiableDiscrete` + `semantic_fmp_int`/`exists_finite_int_countermodel`
   statements + `FinitePresentation`/`toFrame`/`toModel` (buildable immediately after 414);
   (ii) box-free `checkSat` with correctness (periodicity machinery, reuse TemporalGate
   patterns); (iii) the bounded-periodic realization lemma (shared core); (iv) FMP proof via
   route B or C decided by what is sorry-free post-415; (v) box-case `checkSat` completion;
   (vi) demote/delete the vacuous `FMP.lean`/`Correctness.lean` theorems and update the FMP
   README. Phases (iii)-(v) are research-grade; size them as single-lemma dispatches.
3. Keep the paper-side mandatory edit (restate enumeration as finite W over ℤ) out of this
   repo's scope — it is a PossibleWorlds-repo edit per fix.md C6.

## References

- `/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex:3296-3305` (cor:tm-decidability)
- `/home/benjamin/Philosophy/Papers/PossibleWorlds/Comments/fix.md:177-195` (§C6, decision text)
- Burgess 1984 §3 (FMP-vs-Rabin dichotomy); Caleiro–Viganò–Volpe 2013 (mosaic decidability,
  EXPSPACE, tense+S5) — both as cited by fix.md C6 option 2
- Repo files as cited inline (all paths relative to `/home/benjamin/Projects/BimodalLogic/`)
