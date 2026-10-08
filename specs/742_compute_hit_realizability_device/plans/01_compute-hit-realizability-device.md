# Implementation Plan: Task #742

- **Task**: 742 - Compute Hit: the per-model realizability device (B1-B3) between the seam bridge and the decidable stab check
- **Status**: [IMPLEMENTING]
- **Effort**: 19 hours (10 phases; lean4 `--hard`, one agent run per phase)
- **Dependencies**: 737 (complete; `SeamMulti.lean` is the bridge this plan feeds), 711 (complete; the `KTypeSummary/` substrate)
- **Research Inputs**: specs/742_compute_hit_realizability_device/reports/01_compute-hit-realizability-device.md
- **Artifacts**: plans/01_compute-hit-realizability-device.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md, reference-grounding.md (lean4 override, Tier 1), anti-analysis.md (lean4 override), wrap-up.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

The landed bridge `plusStab_iff_forall_hit` reduces `⊡φ` at a seam of a regular `ℤ`-frame to a
finite conjunction over the realized family triples `Hit M τ t φ k`, and `Hit` is computed
nowhere. This plan lands the four components the research report found tractable — B1 (closure
alphabet and local run conditions), B2a (the trace of a history is the unique anchored local run,
so `Hit` is the image of the seam's ray pairs under a trace map), B3a (a computable `kTypeOfFin`
equal to the classical `kTypeOf`, de-risked by a compiled research probe), and B3b (effective
composition on representatives and a computable `hitOf` on a finite labelled presentation with a
proved membership characterization) — and closes them with the per-model bridge
`hit_eq_hitOf_of_presented`: under an EXPLICIT realization hypothesis `Presented` (the seam's
trace set equals the presentation's run set), `HitCl M τ t φ k` equals the computable
`hitOf`. The one component that is not built, B2b (constructing a regular model realizing a
given presentation — HWZ 2000 Thm 14 ⇐ for the `⊡` fibre, which needs an infinite committed-state
slice and a new regular-frame constructor), gets a MACHINE-CHECKED verdict instead: a wired
evidence probe showing that per-time quasistates in HWZ's verbatim shape (bare sets of types with
the consecutive-type relation) do not determine `Hit`, plus a costed successor-record description.
Everything stays under `[F.IsRegular]`, over the time axis with a finite alphabet of per-time
summaries; the only `[Finite W]` anywhere is in the counterexample fixture; no complexity bound is
claimed; no `require` edge and no copied declaration from cslib.

Definition of done: Phases 1-9 compile sorry-free on the standard axiom profile with every
headline pinned in `KTypeSummaryAxiomTest.lean`; the `#eval` computability witnesses run; the
probe is wired and green under `scripts/check-evidence-probes.sh`; the theorem index, both READMEs
and the ROADMAP residue bullet say exactly what landed and what did not; the summary carries the
B2b successor-record description verbatim. "`Hit` computed" is NEVER written as the headline — the
honest headline is: `hitOf` is computable on finite presentations, `Hit M` is the image of the
ray pairs under a computable trace map, and per-presentation realization (B2b) is the successor's.

### Research Integration

From `reports/01_compute-hit-realizability-device.md` (all re-verified by name this planning
pass, every line number treated as advisory):

- **B3a is LOW, not HIGH**: `Probe742.decNfEvalNf`, `kTypeOfFin`, `kTypeOfFin_eq`, `segZFinDec`,
  `kTypeOfFin_segZ` compiled (`probes/b3a-compile-5.log`: `GUARD_EXIT=0`, axioms `[propext,
  Classical.choice, Quot.sound]`, `#eval` outputs `1`, `true`, `false`). Phase 1 transcribes the
  probe into the library with explicit instance binders instead of the probe's `FinDec` class
  (so the Challenge statements below carry no class declaration).
- **The `ℤ`-instance hazard** (research Recommendation 4, issue log `iss_1791449923336_j0t4L5`):
  `inferInstanceAs` on `ℤ`-subtype order/equality resolves through
  `Int.instConditionallyCompleteLinearOrder` (noncomputable). Every decidability instance for
  `segZ` is an explicit term (`Int.decEq`, `Int.decLt` via `decidable_of_iff` — target proposition
  FIRST in the `@` form — and `Fintype.subtype` on `Finset.Ico` with explicit `Int.instLinearOrder`
  / `Int.instLocallyFiniteOrder`). Phase 4's `listSeg` sidesteps the hazard entirely by using a
  `Fin n` carrier, whose instances are computable by construction.
- **The closure alphabet** `⟨{ψ // ψ ∈ (PlusFormula.subformulas φ).toFinset} ⊕ Unit⟩` has
  `Fintype`/`DecidableEq` by `inferInstanceAs` (`lean_run_code`, `Fintype.card = 4` for `p U q`);
  `PlusFormula.subformulas` must be namespaced.
- **Local run conditions are `PlusTruthAt`'s `untl`/`snce` clauses verbatim** (strict `t < s`,
  guard on the open interval — HWZ Def 11), so soundness of the trace is `Iff.rfl` per clause;
  `box` is a per-time datum and `stab` a per-state datum, carried by `Anchored`, never by a run
  condition.
- **The fibre is a product** (`seamOmegaEquiv : StabFibre F.toTaskFrame t s ≃ SeqPair F s`,
  landed): the Lemma 17 splice is a closure property of the fibre, and a per-state summary must be
  a product of ray summaries. That is why B2b needs an infinite committed-state slice and a
  `Saturation` constructor the tree lacks (`ofSlicedStep_saturation` is `[Finite W]`-only), and
  why it is the successor's record, not a phase here.
- **Composition on representatives, never on bare `KType`** (Finding 4): `KType sig k` is
  `NormalForm sig k 0 → Bool`, and most of its inhabitants are the type of nothing, so a
  `compose : KType → KType → KType` has no correctness statement off realizable values. Phase 4
  states correctness as a congruence on label-list representatives
  (`kTypeOf_listSeg_append_congr`), proved from `kEquiv_orderedSum_of_kEquiv_colour` at a two-point
  index order, and Phases 6-7 compute path types by a representative-carrying closure that
  terminates by cardinality (`KType sig k` is a `Fintype` with `DecidableEq`).
- **Three readings of "compute `Hit`"** (Finding 2): this plan lands (R1) `Hit` as an image, (R2)
  the computable `hitOf`, and the (R3 ⇒) half as the conditional `hit_eq_hitOf_of_presented`;
  (R3 ⇐) — `Presented (modelOf P) … P` for a constructed model — is B2b.

### Prior Plan Reference

No prior plan for this task. Calibration is borrowed from the batch that produced 737/738: README
line anchors drifted mid-batch (RaySummary 35→41, KTypeSummary 96→101), so every anchor in this
plan is a declaration name, never a line number.

### Roadmap Alignment

`specs/ROADMAP.md`, Phase 1 "Decidability front", the bullet beginning "Compute `Hit` — the
residue between the discharge record and the assembly, in three parts" (`(Task 742)`), and the
critical-path note "742 → 735". This plan advances that bullet's B1, B3 and the B2a half of B2;
Phase 10 rewrites the bullet to say so and names the B2b successor beside it. The adjacent bullet
"Assemble the decidable stab check … (Task 735)" is the consumer; nothing here attempts it.

## Goals & Non-Goals

- **Goals**: `kTypeOfFin_eq`, `kTypeOf_listSeg_append_congr`, `plusStab_iff_forall_hitSig`,
  `clTrace_localRun`, `clTrace_anchored`, `eq_clTrace_of_localRun_anchored`, `mem_hitOf_iff`,
  `hit_eq_hitOf_of_presented`
- Goals, stated in prose (not Challenge-pinned): a wired evidence probe
  (quasistate-does-not-determine-hit) holding B2b's verdict in place; `#eval` computability
  witnesses for the computable `k`-type and for `hitOf` on a two-state presentation; axiom pins
  for every headline; theorem-index rows; README and ROADMAP updates; the B2b successor-record
  description written out in the summary for filing.
- **Non-Goals**:
  - B2b itself: `modelOf P`, the infinite committed-state slice, a `Saturation` constructor for
    sliced frames with finitely many fibre shapes per time, `hit_modelOf`. Successor record.
  - B4 / task 735: `Decidable (PlusValidZTime φ)`, any quantification over models, any search
    over presentations, any per-seam `Bool` verdict. Not attempted; the one-line corollary
    `plusStab_iff_forall_hitOf_of_presented` restates the bridge over `hitOf` and decides nothing.
  - Rebuilding or retiring `exists_presents_iff`, `plusStab_iff_forall_hit`, `PresentsMulti`,
    `presentsMulti_seamTrace`, `determinedByKType_eval` — all cited, none re-proved.
  - A backward Bool-fixture bridge: `pastStab_iff_allBwdPathsMeet` remains the only backward
    fixture result; the probe is forward-only (`¬Fp`); every module header says so.
  - Any complexity bound, upper or lower; any `[Finite W]` outside the counterexample fixture;
    any cslib `require` or copied declaration (`~/Projects/cslib/` is consulted for strategy only).
  - A context-pattern note on `ℤ`-subtype decidability (research Context Extension Recommendation)
    — it belongs to the agent-system source store, not this repository; recorded in the summary
    as a recommendation only.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `eq_clTrace_of_localRun_anchored`'s `untl`/`snce` cases need a well-founded argument the plan has not spelled out (an anchored run could satisfy the `untl` clause "too early" or "too late") | H | M | The induction is on `ψ ∈ cl` (structural on `PlusFormula`), with the IH giving `c ⟨ψ⟩ = PlusTruthAt` pointwise for both parts of `ψ U χ`; the `untl` clause of `LocalRun` is then literally the `untl` clause of `PlusTruthAt` after rewriting by the IH, so no well-founded argument is needed. If a case resists, land the `atom`/`bot`/`imp`/`box`/`stab` cases green first (H2's 30% bar), then the temporal cases |
| The Finding 3 (e) fixture's per-time quasistates are hand-enumerated (research confidence Medium): A and B might not have equal quasistate sets or pair relations over `cl = {p, Fp}` | M | M | Phase 8 is a decision gate: the probe proves quasistate equality and pair-relation equality IN LEAN before the `Hit_A ≠ Hit_B` theorem; if either equality fails, repair the fixture (add a fourth state) within the phase and record the change in the probe header; the `Hit` inequality itself is derived through `plusStab_iff_forall_hit` and never evaluates a `k`-type |
| `hitOf`'s closure is defined by bounded iteration, and the completeness direction of `mem_hitOf_iff` (every realized triple is found) needs the two-point mixing instance plus an order-isomorphism between a trace segment and `listSeg` | H | M | Phase 4 lands `kTypeOf_segZ_eq_listSeg` (via `k_equiv_of_iso`, `IntegerModel/GoodStructures.lean`) and the congruence before Phases 6-7 touch the closure; the closure's fixpoint is a `Nat`-bounded iterate (`Fintype.card (Q × Q × KType sig k)` rounds), so no `WellFounded` recursion on `Finset` |
| `decide` on `KType` equality and the `#eval` witnesses are exponential in `|NormalForm sig k 0|`; a witness at depth 2 may not finish | M | H | Witnesses run at depth 1 only, on two-state presentations and 3-5 point segments, exactly as the research probe did; no complexity claim is made anywhere |
| Shared-file contention with 733/734/739 on `scripts/check-evidence-probes.sh` and the evidence collection, and with 740 on `RaySummary/` and `KTypeSummary/` | M | M | ROADMAP already batches 742 with 735 and 740 with 709; Phase 8 is the only phase touching the gate script; if a batch admission collision is reported, dispatch Phase 8 singly |
| A same-named weaker statement sits under a true-looking name (the defect 737 was filed to find) | H | L | `## Lean Challenge Statements` pins every Goal's signature; `hit_eq_hitOf_of_presented` carries `Presented` as an explicit hypothesis in its name and its statement; module headers state B2b's absence in the first paragraph |
| `Fintype`/`DecidableEq` plumbing for `(clSig φ).preds` fails under `variable`-level instances where the research's `lean_run_code` succeeded at top level | L | L | State the instances as named `instance`s immediately after `clSig`, with `inferInstanceAs` on the `Subtype`/`Sum` form the research compiled |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2, 8 | -- |
| 2 | 3, 4 | 2 (for 3); 1 (for 4) |
| 3 | 5, 6 | 3 (for 5); 4 (for 6) |
| 4 | 7 | 6 |
| 5 | 9 | 5, 7 |
| 6 | 10 | 8, 9 |

Phases within the same wave can execute in parallel. Territory within a wave is disjoint by
construction: Wave 1 owns `KTypeSummary/KTypeFin.lean` + `KTypeSummary.lean` (Phase 1),
`RaySummary/Closure.lean` + `RaySummary.lean` (Phase 2), the probe + gate script (Phase 8); Wave 2
owns `Trace.lean` + `RaySummary.lean` (Phase 3) and `Compose.lean` only (Phase 4); Wave 3 owns
`Trace.lean` (Phase 5) and `Compose.lean` + `RaySummary.lean` (Phase 6). Every build is the guarded,
detached form `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build <Module>`;
every phase ends with the scoped build green, `#print axioms` on each new theorem showing exactly
`[propext, Classical.choice, Quot.sound]`, and `grep -c sorry` = 0 on the touched module.

---

### Phase 1: B3a — the computable `k`-type of a finite decidable structure [COMPLETED]

**Goal**: Land the research probe as a library module: `NfEvalNf` is decidable on a finite
decidable structure by induction on depth, the resulting `kTypeOfFin` equals the classical
`kTypeOf` pointwise, and `segZ` segments of decidable colourings carry computable instances.

**Tasks**:
- [x] Create `FormalSystem/Metalogic/WeakCanonical/KTypeSummary/KTypeFin.lean` (namespace
      `FormalSystem.Metalogic.WeakCanonical`, importing `KTypeSummary.Segment`), header stating:
      what is computed, that nothing is decided about `⊡` or `Hit`, that no complexity bound is
      claimed, and the `ℤ`-instance hazard verbatim from the research (explicit terms, `Int.decEq`,
      `Int.decLt`, `decidable_of_iff` target-first).
- [x] Transcribe `decAtomEval` and `decNfEvalNf` from `probes/b3a-computable-ktype.lean` with the
      probe's `FinDec` class replaced by four explicit instance binders `[Fintype M.carrier]
      [DecidableEq M.carrier] [DecidableRel (α := M.carrier) (· < ·)] [∀ p, DecidablePred (M.interp p)]`
      (the `LinearOrder M.carrier` instance is registered in `Expressiveness/MonadicFO.lean`;
      `atomKindFintype`, `normalFormFintype`, `Fintype.decidableForallFintype`,
      `Fintype.decidableExistsFintype`, `instDecidableIff`, `instDecidableAnd` as in the probe).
- [x] `kTypeOfFin` and `kTypeOfFin_eq` (proof `funext nf; unfold kTypeOfFin kTypeOf; exact
      decide_eq_decide.mpr Iff.rfl`), then `decEval` — `Decidable (eval M env α)` for every
      `MonadicFormula sig n` on the same binders, by structural induction (needed by Phase 9's
      `stabTargetSig` witness; the `.lt` constructor uses the `DecidableRel` binder).
- [x] The four `segZ` instances as explicit terms (`segZFintype`, `segZDecidableEq`,
      `segZDecidableLT`, `segZDecidablePred` for `[∀ p, DecidablePred (c p)]`), and
      `kTypeOfFin_segZ`.
- [x] Add `import FormalSystem.Metalogic.WeakCanonical.KTypeSummary.KTypeFin` to
      `FormalSystem/Metalogic/WeakCanonical/KTypeSummary.lean`; scoped build; `#print axioms
      kTypeOfFin_eq` = standard profile; `grep -c sorry` = 0.

**Timing**: 2 hours

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: ~150-200 lines (the probe is 119 lines with `#eval`s; the explicit-binder
restatement and `decEval` add 40-80). Confirm by `wc -l` at phase end; a module over 300 lines
means the binders are being repeated where a `variable` block would do.

**Files to modify**:
- `FormalSystem/Metalogic/WeakCanonical/KTypeSummary/KTypeFin.lean` - new module (B3a)
- `FormalSystem/Metalogic/WeakCanonical/KTypeSummary.lean` - add the `KTypeFin` import

**Verification**:
- `lake-build-guard.sh build … -- build FormalSystem.Metalogic.WeakCanonical.KTypeSummary.KTypeFin` green.
- `#print axioms` for `kTypeOfFin_eq` and `kTypeOfFin_segZ`: exactly `[propext, Classical.choice, Quot.sound]`.
- `kTypeOfFin` and `decEval` are `def`, not `noncomputable def`; `#eval decide (kTypeOfFin (segZ twoLetter c2 0 3) 1 = kTypeOfFin (segZ twoLetter c2 0 5) 1)` (the probe's `c2`) prints `true` in a scratch `lean_run_code` — the permanent witness is Phase 9's test module.

---

### Phase 2: B1 — the closure alphabet, local run conditions, anchors, and the signature-generic bridge [COMPLETED]

**Goal**: Widen the two-letter trace alphabet to the subformula closure of `φ` plus a `now`
marker, state HWZ Def 11's run conditions on colourings over that alphabet, state the anchors
(atoms at states, `box`-letters per time, `stab`-letters per state, `now` exactly at `t`), and
restate the hypothesis-free bridge over an arbitrary signature with distinguished `now`/`phi`
letters so that `plusStab_iff_forall_hit` becomes its two-letter instance.

**Tasks**:
- [x] Create `FormalSystem/Metalogic/Decidability/RaySummary/Closure.lean` (namespace
      `FormalSystem.Metalogic.Decidability.RaySummary`, importing `RaySummary.SeamMulti` and
      `PlusLanguage.Subformulas`), header: alphabet = HWZ 2000 Def 6 `sub_x φ` plus marker;
      run conditions = Def 11; what is NOT here (no realizability, no B2b, no `Bool`, forward-only
      fixture limit carried).
- [x] `clSig φ : MonadicSignature := ⟨{ψ : PlusFormula // ψ ∈ (PlusFormula.subformulas φ).toFinset} ⊕ Unit⟩`
      with named `instance`s `Fintype (clSig φ).preds`, `DecidableEq (clSig φ).preds` by
      `inferInstanceAs`; `clNow φ := Sum.inr ()`; `clPhi φ := Sum.inl ⟨φ, self-membership⟩`;
      `clLetter` for a subformula with its membership proof.
- [x] `LocalRun φ (c : (clSig φ).preds → ℤ → Prop) : Prop` — for every `ψ` in the closure: the
      `bot` clause (`¬ c ⟨.bot⟩ z`), the `imp` clause (`c ⟨ψ₁.imp ψ₂⟩ z ↔ (c ⟨ψ₁⟩ z → c ⟨ψ₂⟩ z)`),
      the `untl` clause (`c ⟨.untl ψ χ⟩ z ↔ ∃ s, z < s ∧ c ⟨χ⟩ s ∧ ∀ r, z < r → r < s → c ⟨ψ⟩ r`)
      and the `snce` dual with `s < z`, each quantified over the membership proofs of the parts
      (via the `plusClosure_*` projections of `Subformulas.lean`); `atom`, `box`, `stab` impose
      no run condition.
- [x] `Anchored M φ t c σ : Prop` — `c (clNow φ) z ↔ z = t`; for every closure atom `.atom p`:
      `c ⟨.atom p⟩ z ↔ M.valuation (σ.state z) p`; for every closure `.box ψ`:
      `c ⟨.box ψ⟩ z ↔ ∀ σ', PlusTruthAt M σ' z ψ` (per-time datum); for every closure `.stab ψ`:
      `c ⟨.stab ψ⟩ z ↔ ∀ σ', σ.state z = σ'.state z → PlusTruthAt M σ' z ψ` (per-state datum).
      Docstring: these are the atomization licence of `Seam.lean` point (e) and
      `plusTruthAt_iff_atomize`, stated as anchors rather than run conditions.
- [x] `clTrace M φ t σ : (clSig φ).preds → ℤ → Prop := fun p z => match p with | .inl ψ =>
      PlusTruthAt M σ z ψ.1 | .inr () => z = t`, and `clTrace_proj : seamTrace M φ t σ = fun b z =>
      bif b then clTrace M φ t σ (clNow φ) z else clTrace M φ t σ (clPhi φ) z` (definitional).
- [x] The generic bridge: `HitSig sig M τ t tr k : Set (KType sig k × KType sig k × KType sig k)`
      := `{x | ∃ bf : SeqPair F (τ.state t), InFamily sig k x.1 x.2.1 x.2.2 (tr (spliced τ t bf))}`,
      `nowPhiSig sig now phi : MonadicFormula sig 0 := .ex (.and (.atom now 0) (.atom phi 0))`,
      `stabTargetSig sig now phi c := eval (zFiber sig c) Fin.elim0 (nowPhiSig sig now phi)`,
      `stabTargetSig_determined` (from `determinedByKType_eval`, depth 1 ≤ k),
      `stabTargetSig_of_trace` (the analogue of `stabTarget_seamTrace` under the two anchor
      hypotheses), `hitSig_finite` (from `finite_family_triples`), and
      `plusStab_iff_forall_hitSig` — the SAME proof as `plusStab_iff_forall_hit` (forward:
      `plusStab_iff_omega` + saturation via `family_saturation`; backward: `family_cover`), with
      the two-letter theorem's statement recoverable as the instance `sig := twoLetter`,
      `now := true`, `phi := false`, `tr := seamTrace M φ t` (record this as
      `hitSig_twoLetter : HitSig twoLetter M τ t (seamTrace M φ t) k = Hit M τ t φ k`, `rfl`). *(deviation at Phase 10: altered — `HitSig` no longer takes `M`, which its body never read (the env linter's `unusedArguments`); `HitSig twoLetter τ t (seamTrace M φ t) k = Hit M τ t φ k` is still `rfl`. A strict generalization of the Challenge signature, not a weakening.)*
- [x] Add `import FormalSystem.Metalogic.Decidability.RaySummary.Closure` to
      `FormalSystem/Metalogic/Decidability/RaySummary.lean`; scoped build; axioms; zero sorries.

**Timing**: 2 hours

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: 300-500 lines (CARRIED from the research report's Finding 5 row for B1,
itself carried from 737; confirm by `wc -l`). The generic bridge is a restatement with the same
proof, so if it exceeds the two-letter proof's length by more than ~40 lines the generalisation
has gone wrong somewhere (most likely in the `now` anchor's direction).

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/Closure.lean` - new module (B1)
- `FormalSystem/Metalogic/Decidability/RaySummary.lean` - add the `Closure` import

**Verification**:
- Scoped build of `FormalSystem.Metalogic.Decidability.RaySummary.Closure` green.
- `#print axioms plusStab_iff_forall_hitSig` = standard profile; `hitSig_twoLetter` by `rfl`.
- `Fintype.card (clSig (.untl (.atom p) (.atom q))).preds` evaluates to `4` in `lean_run_code`.

---

### Phase 3: B2a (i) — the trace is an anchored local run [COMPLETED]

**Goal**: Soundness of the closure trace: `clTrace M φ t σ` satisfies every run condition and
every anchor — HWZ 2000 Thm 14 ⇒, the direction that reads types off a model.

**Tasks**:
- [x] Create `FormalSystem/Metalogic/Decidability/RaySummary/Trace.lean` (imports `Closure`),
      header: Thm 14 ⇒ here, Thm 14's uniqueness in Phase 5, Thm 14 ⇐ is B2b and absent; the
      product structure of the fibre (`seamOmegaEquiv`) is why a per-state summary must be a
      product and why B2b is a separate record — fold research Finding 3 (a)-(b) into this header
      and into the RaySummary README's point (d) in Phase 10.
- [x] `clTrace_localRun M φ t σ : LocalRun φ (clTrace M φ t σ)` — each clause is `PlusTruthAt`'s
      clause by `Iff.rfl` after unfolding `clTrace` (the `untl`/`snce` clauses are strict with the
      guard on the open interval, exactly as `PlusTruth.lean` states them).
- [x] `clTrace_anchored M φ t σ : Anchored M φ t (clTrace M φ t σ) σ` — the `now` anchor is
      `Iff.rfl`; `atom`, `box`, `stab` anchors are the corresponding `PlusTruthAt` clauses.
- [x] `HitCl M τ t φ k := HitSig (clSig φ) M τ t (clTrace M φ t) k`,
      `hitCl_finite`, and `plusStab_iff_forall_hitCl` (instance of Phase 2's generic bridge with
      the two anchors discharged by `clTrace_anchored`).
- [x] `hitCl_eq_image : HitCl M τ t φ k = (fun bf => familyTriples (clTrace M φ t (spliced τ t bf))) '' Set.univ`
      stated with `familyTriples c := {x | InFamily (clSig φ) k x.1 x.2.1 x.2.2 c}` as a `Set`-valued
      image (`⋃ bf, familyTriples …`) — reading (R1) of the research, a theorem and explicitly NOT
      a computation (docstring says so: `SeqPair` is not finite). *(deviation: altered — landed as `hitCl_eq_iUnion` in the `⋃ bf, familyTriples …` form the item itself parenthesises; the literal `'' Set.univ` image is a set of sets and does not typecheck against `Set (triple)`; generic form `hitSig_eq_iUnion` also landed)*
- [x] Add `import FormalSystem.Metalogic.Decidability.RaySummary.Trace` to `RaySummary.lean`;
      scoped build; axioms; zero sorries.

**Timing**: 2 hours

**Depends on**: 2

**Verification Tier**: local

**Scope Hypothesis**: 200-300 lines (the research's B2a figure 400-600 is split across Phases 3
and 5). Confirm by `wc -l`.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/Trace.lean` - new module (B2a, soundness half)
- `FormalSystem/Metalogic/Decidability/RaySummary.lean` - add the `Trace` import

**Verification**:
- Scoped build green; `#print axioms clTrace_localRun`, `clTrace_anchored`,
  `plusStab_iff_forall_hitCl` = standard profile.

---

### Phase 4: B3b (i) — label-list segments and composition on representatives [COMPLETED]

**Goal**: A computable finite segment built from a list of letters, its computable `k`-type, the
order-isomorphism identifying a trace segment `segZ` with the segment of its label list, and the
composition congruence: the `k`-type of a concatenation depends only on the `k`-types of the
parts (the two-point instance of `kEquiv_orderedSum_of_kEquiv_colour`).

**Tasks**:
- [x] Create `FormalSystem/Metalogic/Decidability/RaySummary/Compose.lean` (imports
      `KTypeSummary.KTypeFin`, `WeakCanonical.MixedSum`, `RaySummary.SeamMulti`), header: what
      "effective composition" means here (representatives, research Finding 4 and Decision D-3)
      and why no `compose : KType → KType → KType` on bare values is defined; no complexity claim.
- [x] `listSeg (l : List (sig.preds → Bool)) : OrderedMonadicStructure sig` with carrier
      `Fin l.length`, `interp p i := l.get i p = true`, `carrierOrder := inferInstance` (on
      `Fin`, computable); the four decidability instances on `(listSeg l).carrier` (all
      `inferInstance` on `Fin` — verify each is computable with a `#eval` in `lean_run_code`
      before committing); `kTypeOfFin_listSeg : kTypeOfFin (listSeg l) k = kTypeOf sig k (listSeg l)`.
- [x] `labels (c : sig.preds → ℤ → Prop) [∀ p, DecidablePred (c p)] (a b : ℤ) : List (sig.preds → Bool)`
      (the letters of `c` on `[a, b)`, via `List.range` / `Int.toNat (b - a)`), and
      `kTypeOf_segZ_eq_listSeg : kTypeOf sig k (segZ sig c a b) = kTypeOf sig k (listSeg (labels c a b))`
      by `k_equiv_of_iso` (`IntegerModel/GoodStructures.lean`) with the order isomorphism
      `{t // a ≤ t ∧ t < b} ≃o Fin (b - a).toNat`.
- [x] `listSeg_append_kEquiv : KEquiv sig k (listSeg (l₁ ++ l₂)) (orderedSum sig Bool (fun b => bif b then listSeg l₂ else listSeg l₁))`
      by `k_equiv_of_iso` (the concatenation IS the two-point ordered sum, up to the evident
      order isomorphism `Fin (n₁ + n₂) ≃o Σ-lex`), then
      `kTypeOf_listSeg_append_congr` from `kEquiv_orderedSum_of_kEquiv_colour` with `I = J = Bool`
      — the colouring hypothesis `KEquiv (colourSig (KType sig k)) k (kTypeColouring …) (kTypeColouring …)`
      is discharged by `rfl`-level equality of the two coloured orders once `h₁`, `h₂` are rewritten
      in (they are literally the same `kTypeColouring` after rewriting). *(deviation at Phase 10: altered — the `[DecidableEq sig.preds]` binder, used by neither the statement nor the proof (the env linter's `unusedArguments`), was dropped; `[Fintype sig.preds]` stays. A strict generalization of the Challenge signature, not a weakening.)*
- [x] Scoped build (`Compose` is not yet imported by the aggregator — build the module by name);
      axioms; zero sorries. Do NOT touch `RaySummary.lean` in this phase (Phase 3 owns it in this wave).
      *(deviation: altered — the two order isomorphisms are built as `StrictMono.orderIsoOfSurjective`
      of explicit maps `segZToListSeg` / `appendPt`, the idiom of `kEquiv_zFiber_segSum`, rather than
      by `Equiv.toOrderIso` on a hand-built `Fin (n₁ + n₂) ≃ Σ-lex`; same statements, same
      `k_equiv_of_iso` route. `kTypeOf_segZ_eq_listSeg` and `listSeg_append_kEquiv` carry
      `[Finite sig.preds]` (what `k_equiv_of_iso` needs) rather than the section's
      `[Fintype] [DecidableEq]`, which the unused-instance linters reject; the Challenge-pinned
      `kTypeOf_listSeg_append_congr` keeps its recorded `[Fintype sig.preds] [DecidableEq sig.preds]`
      binders verbatim under a declaration-scoped linter opt-out, as `exists_matching_factorization`
      does. `wc -l` = 297, inside the 250-400 hypothesis.)*

**Timing**: 2 hours

**Depends on**: 1

**Verification Tier**: local

**Scope Hypothesis**: 250-400 lines; the two order-isomorphism constructions are the bulk.
Confirm by `wc -l`; if `kEquiv_orderedSum_of_kEquiv_colour`'s `LinearOrder Bool` instance path
turns out noncomputable it does not matter — this phase's theorems are `Prop`, and only `listSeg`
and `kTypeOfFin_listSeg` must stay computable.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/Compose.lean` - new module (B3b, composition half)

**Verification**:
- `lake-build-guard.sh … -- build FormalSystem.Metalogic.Decidability.RaySummary.Compose` green.
- `#print axioms kTypeOf_listSeg_append_congr`, `kTypeOf_segZ_eq_listSeg` = standard profile.
- `#eval decide (kTypeOfFin (listSeg [f, g, f]) 1 = kTypeOfFin (listSeg [f, g, f, g, f]) 1)` runs
  (depth 1, two letters) in `lean_run_code`.

---

### Phase 5: B2a (ii) — an anchored local run is the trace [COMPLETED]

**Goal**: Uniqueness, the half of HWZ Thm 14 ⇒ the per-model device needs: a colouring over the
closure alphabet that satisfies the run conditions and the anchors for `σ` IS `clTrace M φ t σ`.

**Tasks**:
- [x] In `Trace.lean`: `eq_clTrace_of_localRun_anchored M φ t σ {c} (hr : LocalRun φ c)
      (ha : Anchored M φ t c σ) : c = clTrace M φ t σ` — `funext p z`; case `.inr ()` from the
      `now` anchor; case `.inl ⟨ψ, hψ⟩` by structural induction on `ψ` generalising the
      membership proof: `atom`/`box`/`stab` from the anchors; `bot` from the `bot` run clause;
      `imp` from the `imp` clause and the two IHs (parts are in the closure by
      `plusClosure_imp_left`/`_right`); `untl ψ χ`: rewrite the `untl` run clause by the IHs for
      `ψ` and `χ` at every time — the right-hand side is then `PlusTruthAt M σ z (.untl ψ χ)`
      verbatim; `snce` dually. State the lemma `clTrace_unique` as the `∃!` packaging. *(deviation: altered — the induction is factored into the named core `letter_iff_of_localRun_anchored` (all seven constructor cases, membership proof generalised), and `eq_clTrace_of_localRun_anchored` is its `funext`/`propext` packaging; the `box`/`stab` cases read the anchor directly and discard their IHs)*
- [x] Record in the docstring the one subtlety: `box`'s anchor is independent of `σ`, so the
      induction threads it as a per-time datum, never through a run condition (research
      "Potential Formalization Challenges", step 4).
- [x] Scoped build; `#print axioms eq_clTrace_of_localRun_anchored` = standard profile; zero
      sorries. Do NOT touch `RaySummary.lean` (Phase 6 owns it in this wave). *(verified: `probes/trace-build-p5-1.log` GUARD_EXIT=0, 1926 jobs, 0 errors, 0 warnings; `probes/trace-axioms-p5.log` all three new theorems `[propext, Classical.choice, Quot.sound]`; `grep -c sorry Trace.lean` = 0; `RaySummary.lean` untouched)*

**Timing**: 2 hours

**Depends on**: 3

**Verification Tier**: local

**Scope Hypothesis**: 150-250 lines added to `Trace.lean` (total module ≤ 550). Confirm by
`wc -l`. *(measured: 84 lines added, module 165 → 249 — under the hypothesis because every temporal case is a two-line `rw`/`simp only` rewrite exactly as the Risks table predicted; nothing was omitted)* H2 bar: the `atom`/`bot`/`imp` cases are the first sorry-free leaf — land them green
before the temporal cases.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/Trace.lean` - add the characterization

**Verification**:
- Scoped build green; axioms standard; `grep -c sorry Trace.lean` = 0.

---

### Phase 6: B3b (ii) — finite labelled presentations and the path-type closure [COMPLETED]

**Goal**: The finite datum `hitOf` computes over — a finite labelled step graph over the alphabet
(unbundled: `Q` with `[Fintype Q] [DecidableEq Q]`, `lab : Q → sig.preds → Bool`,
`step : Q → Q → Bool`, a distinguished `now : sig.preds`) — its bi-infinite runs, and a
computable, representative-carrying closure `pathTypes` giving the `k`-types of finite
`now`-free paths between two states, with a proved membership specification.

**Tasks**:
- [x] In `Compose.lean`, section `Presentation`: `IsRun step lab now t ρ : Prop :=
      (∀ z, step (ρ z) (ρ (z + 1)) = true) ∧ ∀ z, (lab (ρ z) now = true ↔ z = t)`;
      `runTrace lab ρ : sig.preds → ℤ → Prop := fun p z => lab (ρ z) p = true` with its
      `DecidablePred` instances (explicit); `pathLabels` of a finite state path. Docstring: this
      is the shape HWZ Def 10's state function takes once the per-time alphabet is a finite set of
      letters; the product/liveness structure a REALIZABLE presentation needs (research Finding 3)
      is B2b's and is not imposed here — `Presented` (Phase 9) is what connects runs to histories.
      *(deviation: altered — landed in the new module `RaySummary/Present.lean` (imports
      `Compose`), per this phase's own split rule: the merged module measured 932 lines, past the
      ~900 trigger; `Compose.lean` is unchanged but for a one-line pointer. Argument order is
      `lab step now` throughout. The finite paths are the inductive `StepPath step q q' p`
      (single state / snoc a `step`-successor) with `stepPath_iff` giving the
      `head?`/`getLast?`/`List.IsChain` reading.)*
- [x] `pathTypes Q lab step now k (q q' : Q) : Finset (KType sig k)` — the `k`-types of nonempty
      `now`-free `step`-paths from `q` to `q'`, computed as the fixpoint of the DP
      `T ← T ∪ {kTypeOfFin (listSeg (rep ++ [lab q''])) …}` over a `Finset (Q × Q × KType sig k × List (sig.preds → Bool))`
      of representatives, iterated `Fintype.card (Q × Q × KType sig k)` times (bounded `Nat.iterate`,
      so no well-founded recursion on `Finset`); `pathTypesNow` for paths with exactly one `now`
      letter (the middle-segment variant). *(deviation: altered — one closure serves both
      read-outs: entries are a `structure PathEntry` (`src`, `dst`, `hasNow : Bool`, `ty`, `rep`)
      and the `now` budget is the flag, so `pathTypes`/`pathTypesNow` filter the same
      `pathClosure` on `hasNow`. The computable iterate `closureIter` stops at the first
      stationary round (proved equal to the `Nat.iterate`, `closureIter_eq_iterate`), and the
      round bound `closureBound` is computed arithmetically from
      `Fintype.card (NormalForm sig k 0)` (`closureBound_eq`) — enumerating `KType sig k` for
      `Fintype.card` would never return at depth 1 (`2^256` elements), and without the early stop
      the `#eval` witness could not run.)*
- [x] `mem_pathTypes_iff : τ ∈ pathTypes … q q' ↔ ∃ p : List Q, p ≠ [] ∧ p.head? = some q ∧ … ∧ (∀ x ∈ p, lab x now = false) ∧ kTypeOf sig k (listSeg (pathLabels lab p)) = τ`
      — soundness by induction on the iterate; completeness by induction on the path length using
      `kTypeOf_listSeg_append_congr` (the DP keeps one representative per `(q, q', τ)` and the
      congruence says any other path of the same type composes to the same type) and the
      cardinality bound (a new `(q, q', τ)` key appears at each non-stationary round, so the
      fixpoint is reached within `card` rounds). The same for `mem_pathTypesNow_iff`.
      *(deviation: altered — completeness is by induction on `StepPath` rather than on the path
      length (`exists_mem_iterate_of_stepPath`, the congruence applied exactly as planned); the
      cardinality bound is the generic `iterate_stabilizes` (a bounded, strictly growing measure
      forces a fixpoint within the bound), instantiated with the key-image cardinality
      (`closureStep_pathClosure`). Both membership theorems are stated in the planned list shape
      via `stepPath_iff`, with `mem_pathTypes_iff_stepPath`/`mem_pathTypesNow_iff_stepPath` as the
      inductive forms.)*
- [x] `fwdLive step τ q : Bool` — `q` starts an infinite forward chain `q = q₁ → q₂ → …` in the
      graph `G_τ := {(q, q') | τ ∈ pathTypes … q q'}` — decided as "some state reachable from `q`
      in `G_τ` lies on a `G_τ`-cycle" (finite reachability, `decide` over `Fintype Q`), with
      `fwdLive_iff : fwdLive … = true ↔ ∃ f : ℕ → Q, f 0 = q ∧ ∀ n, τ ∈ pathTypes … (f n) (f (n+1))`
      (⇐ by pigeonhole on `Fintype Q`; ⇒ by unrolling the cycle); `bwdLive` dually.
      *(deviation: altered — `fwdLive_iff`/`bwdLive_iff` are stated verbatim, but the decision is
      the greatest fixpoint of a pruning step (`liveSet := pruneStep^[card Q] univ`, generic
      `live_iff` on a Boolean graph) rather than reachability-plus-cycle: ⇒ chooses successors
      inside the fixpoint (`hasChain_of_mem_fixed`), ⇐ shows a chain survives every round
      (`hasChain_mem_iterate`); stationarity is again `iterate_stabilizes`. This needs neither the
      pigeonhole nor a cycle-unrolling index arithmetic and reuses the one stabilization lemma;
      the planned criterion would itself have needed a stabilization argument for reachability.)*
- [x] Add `import FormalSystem.Metalogic.Decidability.RaySummary.Compose` to `RaySummary.lean`;
      scoped build; axioms; zero sorries. *(altered — both `Compose` and the new `Present` are
      imported and listed in the aggregator's module list, alongside the previously unlisted
      `Closure` and `Trace`.)*

**Timing**: 2 hours

**Depends on**: 4

**Verification Tier**: local

**Scope Hypothesis**: 300-500 lines added to `Compose.lean`. The research's B3b figure is 600-1,000
for "closure + family read-out"; this plan drops the research's `dischargeSet` key because
`LocalRun` is a CONSEQUENCE of `Presented` (traces of histories satisfy it by `clTrace_localRun`),
not a run condition of the presentation — record this as a Decision in the module header. Confirm
by `wc -l`; if the module passes ~900 lines, split the `Presentation` section into its own file
`Present.lean` and add it to `file_scope` via the plan's Files to modify.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/Compose.lean` - presentations, `pathTypes`, liveness
  *(as landed: one-line pointer only; the content went to the split module below)*
- `FormalSystem/Metalogic/Decidability/RaySummary/Present.lean` - NEW (added to file scope per the
  Scope Hypothesis split rule): presentations, `pathTypes`, `pathTypesNow`, liveness
- `FormalSystem/Metalogic/Decidability/RaySummary.lean` - add the `Compose` and `Present` imports

**Verification**:
- Scoped build green; `#print axioms mem_pathTypes_iff`, `fwdLive_iff` = standard profile.
- `pathTypes`, `fwdLive` are `def`, not `noncomputable`; a two-state `#eval` of
  `(pathTypes …).card` at depth 1 runs in `lean_run_code`.

---

### Phase 7: B3b (iii) — `hitOf` and its membership characterization [COMPLETED]

**Goal**: The computable realized-triple set of a finite presentation and the theorem that it is
exactly the set of family triples of the presentation's runs — 711's dropped D3 read-out, on
`k`-type-keyed path types, with the splice construction on abstract runs (legitimate here because
it splices runs of the presentation, not histories of a model — research Finding 4).

**Tasks**:
- [x] `hitOf Q lab step now k : Finset (KType sig k × KType sig k × KType sig k)` :=
      the triples `(τneg, τzero, τpos)` such that `∃ q₀ q₁ : Q, τzero ∈ pathTypesNow … q₀ q₁ ∧
      bwdLive step τneg q₀ = true ∧ fwdLive step τpos q₁ = true` (a `Finset.filter` over
      `Finset.univ` of the product type, decidable by `Fintype Q` and `DecidableEq (KType sig k)`
      via `Fintype.decidablePiFintype`). It does not depend on `t`: runs are translation-invariant.
      *(deviation: altered — landed in the new module `RaySummary/HitOf.lean` (imports `Present`;
      `Present.lean` was at 684 lines and this phase adds ~800, past the ~900 split trigger), with
      `Q` implicit and the `lab step now k` argument order of `Present.lean`. TWO SUBSTANTIVE
      CHANGES, both forced: (1) the liveness conjuncts are `bwdLiveSep`/`fwdLiveSep`, liveness in
      the graph of DISJOINT segments joined by one `step` (`fwdSepGraph x y := ∃ x', step x x' ∧
      τ ∈ pathTypes x' y`, mirror for `bwd`), not Phase 6's `fwdLive`/`bwdLive`, whose graph
      `G_τ := {(x, y) | τ ∈ pathTypes x y}` chains paths that SHARE an endpoint — a
      `SegmentFactorization`'s segments are disjoint, and the type of a path minus its last state
      is not the path's type, so with the planned graph `mem_hitOf_iff` is FALSE (counterexample,
      `#eval`-witnessed in `probes/hitof-axioms-p7.lean`: two states, `step x y := x ≠ y`, state
      `false` reading one letter and state `true` none; at the depth-1 type of `[false]`,
      `fwdLive … false = true` via the one-state self-loop, yet every run alternates and no
      factorization into disjoint segments of that type exists; `fwdLiveSep … false = false`).
      `fwdLive`/`bwdLive` are untouched and unused here. (2) `hitOf` is an image over
      `Finset.univ : Finset (Q × Q)` of products of `pathTypesNow` with `allPathTypes` filtered by
      liveness, not a `Finset.filter` over `Finset.univ` of the triple product of `KType sig k` —
      that `univ` has `2 ^ (3 · |NormalForm sig k 0|)` elements and would never enumerate (Phase
      6's `closureBound` decision); `mem_hitOf_iff_live` recovers the planned filter shape.)*
- [x] `mem_hitOf_iff … (hk : 1 ≤ k) : x ∈ hitOf Q lab step now k ↔ ∃ ρ : ℤ → Q, IsRun step lab now t ρ ∧ InFamily sig k x.1 x.2.1 x.2.2 (runTrace lab ρ)`.
      ⇒ (realization): splice — the `pathTypesNow` representative for the middle segment placed on
      `[t - i, t - i + n)` so that `now` lands at `t`, the forward chain's representatives
      concatenated rightward and the backward chain's leftward; define `ρ`, prove `IsRun`, build
      the `SegmentFactorization` with cuts at the representative boundaries (`mono`, `cover`,
      `strict_pos`, `strict_neg` from nonemptiness of representatives) and the three type
      equations via `kTypeOf_segZ_eq_listSeg`. ⇐ (completeness): from a `SegmentFactorization` of
      `runTrace lab ρ`, read the states at the cuts; the positive cut states form a `G_τpos`
      forward chain (each segment is a `now`-free path by uniqueness of `now` — this is where
      `hk` enters: `now` is `k`-type-visible via `∃x now x` at depth 1, so a positive segment
      containing `now` would force every positive segment to, contradicting `IsRun`), hence
      `fwdLive`; dually `bwdLive`; the middle segment contains `t`, hence `pathTypesNow`.
      *(deviation: altered — proved as planned in both directions (`exists_run_of_live` for ⇒,
      `live_of_run` for ⇐, `mem_hitOf_iff` assembling them), against the `Sep` liveness. The
      splice is a generic `ℤ`-indexed concatenation of nonempty lists (`cutAt`, `exists_concat`,
      `isRun_concat`, `kTypeOf_segZ_concat`) applied to the family "backward paths below, the
      `pathTypesNow` path at `0`, forward paths above", with the anchor placed by choosing the
      base cut `t - i₀` for the unique `now` index `i₀` of the middle path (`countP_eq_one_iff`).
      The ⇐ direction reads the segments as `runSeg` paths; `hk` enters exactly twice, through
      `doets_lemma_1_1` (`eval_iff_of_kTypeOf_eq`): nonemptiness of every positive/negative
      segment (`∃x ¬(x < x)`, `nonempty_iff_of_kTypeOf_eq`) and the `now` state's segment being
      the middle one (`∃x now x`, `exists_interp_iff_of_kTypeOf_eq`) — the plan's argument, with
      the extra nonemptiness use it did not name.)*
- [ ] `hitOf_eq_of_translate` (optional, if cheap): `hitOf` is the same for every `t` — already
      implied by the statement's `t`-independence; otherwise skip. *(deviation: skipped — `hitOf`
      takes no `t`, and `mem_hitOf_iff` is stated for every `t`; the plan's own "otherwise skip".)*
- [x] Scoped build; `#print axioms mem_hitOf_iff` = standard profile; zero sorries.
      *(altered — `RaySummary.lean` and `FormalSystem.lean` import `HitOf`;
      `typst/generated/status.typ` regenerated.)*

**Timing**: 2 hours

**Depends on**: 6

**Verification Tier**: local

**Scope Hypothesis**: 300-500 lines added to `Compose.lean` (or `Present.lean` if Phase 6 split).
The splice (⇒) is the long direction. Confirm by `wc -l`.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/Compose.lean` - `hitOf` and `mem_hitOf_iff`
  *(as landed: untouched; the content went to the new module below)*
- `FormalSystem/Metalogic/Decidability/RaySummary/HitOf.lean` - NEW (added to file scope per the
  Phase 6 split rule): `hitOf`, `mem_hitOf_iff`, the `Sep` liveness, the concatenation
- `FormalSystem/Metalogic/Decidability/RaySummary.lean`, `FormalSystem.lean` - import `HitOf`

**Verification**:
- Scoped build green; axioms standard; `hitOf` is a `def`; a two-state `#eval (hitOf …).card` at
  depth 1 runs.

---

### Phase 8: B2b verdict — the HWZ-verbatim quasistate shape does not determine `Hit` [COMPLETED]

**Goal**: The machine-checked obstruction for the one component this record does not build: two
regular `ℤ`-frame models with equal per-time quasistates (as bare sets of closure types) and equal
consecutive-type relations over `cl = {p, Fp}` whose realized sets `Hit` differ — so any B2b that
transcribes HWZ Defs 10-12 without the product repair is refuted before it is attempted.

**Tasks**:
- [x] Create `specs/evidence/seam-gluing-ray-product/quasistate-does-not-determine-hit.lean`
      (`import FormalSystem`, namespace `Probe742`), header in the collection's house style
      (what is established / what is NOT / axiom record / compile line): three states `a`, `b`,
      `d` on `Fin 3`, `p` at `b` only; model A steps `a→a, a→b, b→b, d→d, d→b`; model B steps
      `a→a, b→b, d→d, d→b` (no `a→b`); both bi-serial, built by `FrameOver.ofSlicedStep` with
      `ofSlicedStep_isRegular`, `Fp := someFuture (.atom pa)` transcribed from
      `presents-is-seam-decidedness.lean`, never imported from it. `[Finite W]` is the
      counterexample's licence, stated as such in the header.
- [x] `quasiState M z : Set (Set PlusFormula)` := `{S | ∃ σ, S = {ψ ∈ cl | PlusTruthAt M σ z ψ}}`
      with `cl := {.atom pa, Fp}`; `pairRel M z` := the set of consecutive pairs
      `(type_z σ, type_{z+1} σ)`; theorems `quasiState_A_eq_B : ∀ z, quasiState MA z = quasiState MB z`
      and `pairRel_A_eq_B` — each by exhibiting, per type, the realizing history (`stayA`,
      `jumpB`-at-`z`, `stayD`, `dToB`-at-`z`, `stayB`) and ruling out the fourth type `{p}` (p
      forces `Fp`'s… no: `{p}` without `Fp` is realized at `b` only if no future `p`, impossible
      since `b→b`; prove it). This is the DECISION GATE: if either equality fails in Lean, repair
      the fixture inside this phase and record the repair in the header; do not weaken the
      theorem statement.
- [x] `stab_notFp_A : ¬ PlusTruthAt MA (stayA t) t (.stab Fp.neg)` (the jump `a→b` refutes
      `¬Fp` through the seam state `a`) and `stab_notFp_B : PlusTruthAt MB (stayA t) t (.stab Fp.neg)`
      (every history through `a` in B stays at `a`: prove `∀ σ, σ.state t = a → ∀ z ≥ t, σ.state z = a`
      by induction on `z - t` through `ofSlicedStep_step`, then no `p` ever). *(deviation:
      altered — `stayA` is the parameter-free constant history `z ↦ (z, a)` (`stayA_A`/`stayA_B`
      per model), the seam being `(stayA, t)` for the theorem's own `t`; the plan's `stayA t`
      argument carried no content. Statements are otherwise as planned, for every `t`.)*
- [x] `hit_ne : Hit MA (stayA t) t Fp.neg 1 ≠ Hit MB (stayA t) t Fp.neg 1` — from
      `plusStab_iff_forall_hit` at both seams (same `stabTarget`, same `k = 1`, `hk` trivial):
      equal `Hit` would give equal `⊡¬Fp` values, contradicting the two theorems above. No
      `k`-type is evaluated. Then the headline
      `quasistate_does_not_determine_hit : (∀ z, quasiState MA z = quasiState MB z) ∧ (∀ z, pairRel MA z = pairRel MB z) ∧ Hit MA … ≠ Hit MB …`.
- [x] `#print axioms` foot on every theorem; wire `"seam-gluing-ray-product/quasistate-does-not-determine-hit"`
      into the `WIRED` array of `scripts/check-evidence-probes.sh` with its header-comment row in
      the probe table (house style: `probe | the decision it holds in place`, wrapped at the
      existing column); run `bash scripts/check-evidence-probes.sh` green.

**Timing**: 2 hours

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: 400-500 lines (research Finding 5 row "B2-verdict probe", calibrated on the
E2 probe's transcription pattern). Confirm by `wc -l`.

**Files to modify**:
- `specs/evidence/seam-gluing-ray-product/quasistate-does-not-determine-hit.lean` - new wired probe
- `scripts/check-evidence-probes.sh` - add the `WIRED` entry and its header row

**Verification**:
- `bash scripts/check-evidence-probes.sh` exits 0 with the new probe listed.
- `#print axioms quasistate_does_not_determine_hit` = `[propext, Classical.choice, Quot.sound]`
  (`Classical.choice` enters through `worldHistoryOfStepPath`, as in every probe of the
  collection); `grep -c sorry` = 0.

---

### Phase 9: The per-model bridge under an explicit realization hypothesis, and the computability witnesses [COMPLETED]

**Goal**: Connect B2a to B3b: when a presentation's run set IS the seam's trace set, `HitCl`
equals the computable `hitOf`; restate the `⊡` bridge over `hitOf` under that hypothesis; land the
permanent `#eval` witnesses that the device is computable.

**Tasks**:
- [x] In `Trace.lean` (importing `Compose`): `Presented M τ t φ lab step : Prop :=
      ∀ c, (∃ bf : SeqPair F (τ.state t), c = clTrace M φ t (spliced τ t bf)) ↔ (∃ ρ, IsRun step lab (clNow φ) t ρ ∧ c = runTrace lab ρ)`.
      Docstring, first sentence: this hypothesis is NOT discharged in this tree for any
      non-trivial model; discharging it for a model CONSTRUCTED from a presentation is B2b, the
      successor record; `presented_localRun : Presented … → ∀ ρ, IsRun … ρ → LocalRun φ (runTrace lab ρ)`
      (from `clTrace_localRun`) shows the run conditions are inherited, which is why
      `pathTypes` needs no discharge bookkeeping. *(deviation: altered — `Trace.lean` imports
      `HitOf` (where `hitOf` landed in Phase 7), not `Compose`; the run predicate's argument order
      is the library's `IsRun lab step (clNow φ) t ρ`)*
- [x] `hit_eq_hitOf_of_presented … (hk : 1 ≤ k) (hP : Presented M τ t φ lab step) : HitCl M τ t φ k = ↑(hitOf Q lab step (clNow φ) k)`
      — `Set.ext`; both sides are "∃ a run/ray pair whose trace realizes the triple"; `mem_hitOf_iff`
      on the right, `hP` to move between runs and traces.
- [x] `plusStab_iff_forall_hitOf_of_presented` — the one-line corollary of
      `plusStab_iff_forall_hitCl` and the equality; docstring says it decides nothing (the
      per-triple condition `∀ c, InFamily … → stabTargetSig …` is 735's to make effective, via
      `kTypeOf_zFiber_eq_of_inFamily` and a middle-segment representative) and names task 735's
      frame without doing its work.
- [x] Create `Tests/BimodalTest/Metalogic/KTypeFinEvalTest.lean` (imported from
      `Tests/BimodalTest/Metalogic.lean` or the aggregator that lists `KTypeSummaryAxiomTest`):
      `#guard`/`#eval` witnesses at depth 1 — the probe's three checks on `segZ twoLetter c2`,
      `kTypeOfFin (listSeg …)` equality of `[f,g,f]` and `[f,g,f,g,f]`, and `(hitOf …).card` on
      the two-state presentation `Q = Bool`, `lab a = {}`, `lab b = {p}`, `step a a, a b, b b`,
      `now` on a third letter placed by a one-`now` variant — pick the smallest presentation whose
      `hitOf` is nonempty and record the expected cardinality as a `#guard`, with a comment that
      the number is a witness of computability and nothing else. *(deviation: altered — no
      `Tests/BimodalTest/Metalogic.lean` exists; the import went into `Tests/BimodalTest.lean`,
      the aggregator listing `KTypeSummaryAxiomTest`. The nonempty-`hitOf` presentation is Phase
      7's two-state `labW`/`stepW` fixture over `twoLetter` (`now := true`; `#guard` card `2`,
      `allPathTypes` card `1`), already the smallest nonempty one, so no third letter was
      introduced; the alternating `labAlt`/`stepAlt` discriminator (`fwdLive`/`bwdLive` true,
      `fwdLiveSep`/`bwdLiveSep` false, `hitOf` card `0`) is pinned beside it. `listSeg` checks
      use `f` = `φ`-only, `g` = letterless: `[f,g,f] ≡₁ [f,g,f,g,f]`, `[f,g,f] ≢₁ [f]`)*
- [x] Scoped builds of `Trace` and the test module; axioms; zero sorries.

**Timing**: 1.5 hours

**Depends on**: 5, 7

**Verification Tier**: interface

**Scope Hypothesis**: 150-250 lines across `Trace.lean` and the new test module. Confirm by `wc -l`.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/Trace.lean` - `Presented`, `hit_eq_hitOf_of_presented`, corollary
- `Tests/BimodalTest/Metalogic/KTypeFinEvalTest.lean` - new computability-witness module
- `Tests/BimodalTest/Metalogic.lean` - import the new test module (or whichever aggregator lists `KTypeSummaryAxiomTest`)

**Verification**:
- Builds of `FormalSystem.Metalogic.Decidability.RaySummary.Trace` and `BimodalTest.Metalogic.KTypeFinEvalTest` green (the latter runs the `#guard`s).
- `#print axioms hit_eq_hitOf_of_presented` = standard profile.

---

### Phase 10: Pins, theorem index, READMEs, ROADMAP, and the successor-record description [COMPLETED]

**Goal**: Make the tree say exactly what landed: axiom pins for every headline, theorem-index rows
with their C14 baseline, both READMEs rewritten so "`Hit` is not computed" becomes "`hitOf` is
computable on finite presentations and `Hit` is its image under `Presented`; realization (B2b)
is the successor's", the ROADMAP residue bullet updated, and the B2b successor record described
verbatim in the implementation summary for filing.

**Tasks**:
- [x] `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean`: add `#guard_msgs` + `#print axioms`
      rows (fully qualified names) for `kTypeOfFin_eq`, `kTypeOf_listSeg_append_congr`,
      `plusStab_iff_forall_hitSig`, `clTrace_localRun`, `eq_clTrace_of_localRun_anchored`,
      `mem_hitOf_iff`, `hit_eq_hitOf_of_presented`; extend the "What is pinned" table; rewrite the
      "What this does not pin, and why" paragraph (replace "the realized set `Hit` is not computed
      anywhere" with the honest state: computable `hitOf`, image theorem, `Presented` undischarged
      for constructed models, B2b successor). *(deviation: altered — ten rows, not seven: the
      Phase 9 handoff's `Presented`, `presented_localRun` and
      `plusStab_iff_forall_hitOf_of_presented` are pinned beside the seven; expected blocks
      measured by `lake env lean` (`probes/p10-axioms.log`), never typed.)*
- [x] `docs/theorem-index.md`: rows for `hit_eq_hitOf_of_presented`, `mem_hitOf_iff`,
      `plusStab_iff_forall_hitSig` (`Paper: —`, frame class `ZTime`, axioms `pcq pinned:C14`);
      update the `plusStab_iff_forall_hit` row's statement text ("`Hit` is not computed" →
      "`Hit` is computed on presentations by `hitOf`; see `hit_eq_hitOf_of_presented`"); run
      `bash scripts/check-module-invariants.sh` and update the C14 baseline it maintains in the
      same commit, per the test file's "When one of these guards fires" rule. *(deviation:
      altered — `mem_hitOf_iff`'s frame-class cell is `—` (class-generic: the statement mentions
      no frame), not `ZTime`; the corrected row text keeps every qualifier ("only on a finite
      presentation and only under `Presented`, never for a model outright"); C15 requires a
      `Paper: — (reason)` line in each indexed declaration's docstring, so `mem_hitOf_iff`
      (`HitOf.lean`) and `hit_eq_hitOf_of_presented` (`Trace.lean`) gained one —
      `plusStab_iff_forall_hitSig` already carried it.)*
- [x] `FormalSystem/Metalogic/Decidability/RaySummary/README.md`: module table rows for
      `Closure.lean`, `Trace.lean`, `Compose.lean` with measured line counts; rewrite "What it
      does not do" (B2b and B4 remain not done; the product-fibre consequence from research
      Finding 3 (a)-(b) folded into the realizability paragraph); evidence section gains the new
      probe; "Two carried limits" unchanged in substance (forward-only, no backward Bool-fixture
      bridge). `FormalSystem/Metalogic/WeakCanonical/KTypeSummary/README.md`: `KTypeFin.lean` row
      (step 1′: the congruence is computable), six-step table's step 6 stays "out of scope"; the
      consumer-relation paragraph updated to name `hitOf`. *(deviation: altered — five module
      rows (`Present.lean` and `HitOf.lean` beside the three planned, since Phases 6-7 split them
      out), counts re-measured by `wc -l`; the evidence section also names the witness module
      `KTypeFinEvalTest.lean`; `FormalSystem/Metalogic/Decidability/README.md`'s `RaySummary/` row
      (file count 2 → 7, the stale "`Hit` is not computed") corrected in the same pass.)*
- [x] `FormalSystem/Metalogic/Decidability/RaySummary.lean` and `KTypeSummary.lean` module
      docstrings: list the new modules (imports were added in Phases 1, 2, 3, 6). *(deviation:
      altered — `KTypeSummary.lean` already listed `KTypeFin` since Phase 1 and is unchanged;
      `RaySummary.lean`'s overview paragraph ("in two modules", "`Hit` named as not computed")
      and its `Trace`/`HitOf` bullets rewritten; the parent aggregator
      `FormalSystem/Metalogic/Decidability.lean`'s `RaySummary` bullet carried the same stale
      claim and was corrected too.)*
- [x] `specs/ROADMAP.md`: rewrite the "Compute `Hit`" bullet to record B1, B2a, B3a, B3b landed
      with their declaration names, B2b verdict + probe name, and add the successor bullet
      "Realize a seam presentation — HWZ 2000 Thm 14 ⇐ for the `⊡` fibre: product summaries,
      an infinite committed-state slice, a `Saturation` constructor for sliced frames with
      finitely many fibre shapes per time (`ofSlicedStep_saturation` is `[Finite W]`-only), and
      `hit_modelOf`; 735's soundness depends on it (research Finding 2)"; keep the 742 → 735
      critical-path note and add "→ successor" on 735's dependency line.
- [x] Write the successor-record description into the implementation summary's "Follow-up
      records" section verbatim (title, WHY, the three sub-obstructions of research Finding 3
      (c)-(d), cost 1,200-2,000 + 300-500 lines carried from the research as CARRIED, the
      constraints that transfer, acceptance in the same either/or form as this task's), and set
      the return's `next_steps` to: file it with `/task`, add it to 735's `dependencies`, then
      `/orchestrate 735 --hard --lit`. Filing is a `/task` invocation outside this dispatch.
- [x] Full gate: `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build` (whole
      project), `bash scripts/check-module-invariants.sh`, `bash scripts/check-evidence-probes.sh`,
      `bash .claude/scripts/verify-deploy.sh` — all green; `#print axioms` on every new headline
      via `lean_verify`; `grep -rc sorry` over the four new modules = 0. *(deviation: altered —
      the invariants gate's first run failed on four items inherited from Phases 2-9 (C16 ×7
      env-linter findings, C29 reasonless `set_option`, C33 hand-edited root, INV stale inventory
      blocks); repaired in-phase: `PathEntry` field docstrings, `HitSig` without its unread `M`
      and `kTypeOf_listSeg_append_congr` without its unused `[DecidableEq]` (strict
      generalizations, after C26 refused in-source suppressions), `lake exe mk_all`,
      `--emit-inventory`; final full run green on every build-dependent check and `--no-build`
      pass exit 0. `#print axioms` by one `lake env lean` pass rather than `lean_verify`;
      `typst-sync-check.sh` Check 1 carries one pre-existing violation outside this task's
      files.)*

**Timing**: 1.5 hours

**Depends on**: 8, 9

**Verification Tier**: full

**Scope Hypothesis**: 7 new pin rows, 3 new index rows, 2 README tables, 1 ROADMAP bullet + 1 new
bullet. Confirm each count against the diff; a README line-count column is re-measured by
`wc -l` at this phase, never carried.

**Files to modify**:
- `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` - seven new pin rows and the prose update
- `docs/theorem-index.md` - three new rows, one row's statement text corrected
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` - module table, "What it does not do", evidence
- `FormalSystem/Metalogic/WeakCanonical/KTypeSummary/README.md` - `KTypeFin.lean` row, consumer relation
- `FormalSystem/Metalogic/Decidability/RaySummary.lean` - module docstring lists the new modules
- `FormalSystem/Metalogic/WeakCanonical/KTypeSummary.lean` - module docstring lists `KTypeFin`
- `specs/ROADMAP.md` - residue bullet rewritten, successor bullet added

**Verification**:
- `bash .claude/scripts/verify-deploy.sh` green (the complete gate set — this is the `full` tier's requirement).
- `bash scripts/check-module-invariants.sh` green, including C14 with the updated baseline and C9 (no task numbers under `FormalSystem/`, `docs/`, the test file — task numbers only in `specs/**`).
- No prose anywhere under `FormalSystem/`, `docs/` or `Tests/` reads "`Hit` computed" without the `Presented` qualifier.

## Literature Proof Structure

**Source** (H3 Tier 1, read directly by the research dispatch; chunk ids under
`~/Projects/Literature/sources/hodkinson_wolter_zakharyaschev_2000_decidable_fragments_fotl/`):
HWZ 2000 §3 Defs 6-12, Remark 13, Thm 14, Lemma 17 (`chunk_0020.md`-`chunk_0023.md`,
`chunk_0027.md`); §4 Thm 15 (`chunk_0024.md`) for the boundary with B4 only. Second source for the
composition step: Doets 1987 3.1.8 as landed (`kEquiv_orderedSum_of_kEquiv_colour`,
`MixedSum.lean`); Thomas 1997 composition principle (`thomas_1997/chunk_0004.md`, UNVERIFIED
summary — corroboration only, never a source). Doets 1989 Lemma 1.1 as landed
(`determinedByKType_eval`).

**Transcription discipline**: the source wins where it applies. One documented divergence, from
the research's Finding 3: HWZ's domain elements are persistent runs `⟨r, ξ⟩`, this semantics'
are histories = step paths through a product fibre (`seamOmegaEquiv`); so Thm 14 ⇐ cannot be
transcribed as written, and this plan lands Thm 14 ⇒ (both halves) plus the machine-checked
refutation of the verbatim ⇐ shape, and defers the re-engineered ⇐ to the successor. No
`simp`/`omega`/`aesop` is used to bypass a step the paper handles explicitly: the `untl`/`snce`
clauses are transcribed verbatim and proved by `Iff.rfl`/rewriting.

### Lemma-level mapping table

| Source | Prop/Location | Lean Identifier | Type Signature | Status |
|---|---|---|---|---|
| HWZ 2000 | Def 6 (state candidate), p. 10, `chunk_0020.md` | `clSig` (Phase 2) | `PlusFormula → MonadicSignature` | pending |
| HWZ 2000 | Def 10 (state function), p. 11, `chunk_0021.md` | unbundled presentation `(Q, lab, step, now)` + `IsRun` (Phase 6) | `IsRun : (Q → Q → Bool) → (Q → sig.preds → Bool) → sig.preds → ℤ → (ℤ → Q) → Prop` | pending (finite-letter shape only; the product/liveness structure is B2b's) |
| HWZ 2000 | Def 11 (run), p. 11, `chunk_0021.md`-`chunk_0022.md` | `LocalRun` (Phase 2) | `(φ : PlusFormula) → ((clSig φ).preds → ℤ → Prop) → Prop` | pending |
| HWZ 2000 | Def 12 (quasimodel), second clause, p. 11, `chunk_0022.md` | — | — | blocked (B2b, successor record; verdict probe Phase 8) |
| HWZ 2000 | Thm 14 ⇒ (trace `t_a`), p. 11, `chunk_0022.md` | `clTrace`, `clTrace_localRun`, `clTrace_anchored` (Phases 2-3) | see Challenge block | pending |
| HWZ 2000 | Thm 14 ⇒, uniqueness of `r(w) = t_{I(w)}(a)` | `eq_clTrace_of_localRun_anchored` (Phase 5) | `LocalRun φ c → Anchored M φ t c σ → c = clTrace M φ t σ` | pending |
| HWZ 2000 | Thm 14 ⇐ (model from quasimodel), pp. 11-12, `chunk_0023.md` | — (`Presented` is the hypothesis it would discharge; `hit_eq_hitOf_of_presented` is conditional on it) | `Presented M τ t φ lab step → HitCl M τ t φ k = ↑(hitOf …)` | pending (conditional form only); ⇐ itself blocked (B2b) |
| HWZ 2000 | Lemma 17 (splice), pp. 14-15, `chunk_0027.md` | `seamOmegaEquiv` (landed) — the splice is a closure property of the fibre | `StabFibre F.toTaskFrame t s ≃ SeqPair F s` | transcribed (landed) |
| HWZ 2000 | Thm 15, p. 13, `chunk_0024.md` | — (B4, task 735) | — | blocked (zero-debt citation; not this task) |
| Doets 1987 / Thomas 1997 | 3.1.8 / composition principle | `kTypeOf_listSeg_append_congr` (Phase 4) from landed `kEquiv_orderedSum_of_kEquiv_colour` | see Challenge block | pending (landed classical lemma, two-point instance) |
| Doets 1989 | Lemma 1.1 | `determinedByKType_eval` (landed), used by `stabTargetSig_determined` | `ψ.quantifierDepth ≤ k → DeterminedByKType sig k (fun c => eval (zFiber sig c) Fin.elim0 ψ)` | transcribed (landed) |
| — (this formalization) | research probe `b3a-computable-ktype.lean` | `kTypeOfFin`, `kTypeOfFin_eq` (Phase 1) | `kTypeOfFin M k = kTypeOf sig k M` | pending (compiled as a probe; transcription into the library is Phase 1) |
| — (this formalization) | 711's D3 read-out, restated on `k`-type-keyed path types | `hitOf`, `mem_hitOf_iff` (Phases 6-7) | see Challenge block | pending |

## Lean Challenge Statements

```lean
import FormalSystem.Metalogic.Decidability.RaySummary.SeamMulti
import FormalSystem.Metalogic.WeakCanonical.MixedSum
import FormalSystem.PlusLanguage.Subformulas

open FormalSystem.PlusLanguage FormalSystem.Metalogic.WeakCanonical
open FormalSystem.Metalogic.Expressiveness FormalSystem.Semantics

namespace FormalSystem.Metalogic.WeakCanonical

variable {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]

/-- B3a: the computable `k`-type of a finite decidable structure. -/
def kTypeOfFin (M : OrderedMonadicStructure sig) [Fintype M.carrier] [DecidableEq M.carrier]
    [DecidableRel (α := M.carrier) (· < ·)] [∀ p, DecidablePred (M.interp p)] (k : ℕ) :
    KType sig k := sorry

/-- B3a: it is the library's classical `k`-type. -/
theorem kTypeOfFin_eq (M : OrderedMonadicStructure sig) [Fintype M.carrier]
    [DecidableEq M.carrier] [DecidableRel (α := M.carrier) (· < ·)]
    [∀ p, DecidablePred (M.interp p)] (k : ℕ) :
    kTypeOfFin M k = kTypeOf sig k M := sorry

/-- B3b: the finite segment of a list of letters, carrier `Fin l.length`. -/
def listSeg (l : List (sig.preds → Bool)) : OrderedMonadicStructure sig := sorry

/-- B3b: composition on representatives — the `k`-type of a concatenation depends only on the
`k`-types of the parts (two-point instance of `kEquiv_orderedSum_of_kEquiv_colour`). -/
theorem kTypeOf_listSeg_append_congr (k : ℕ) {l₁ l₁' l₂ l₂' : List (sig.preds → Bool)}
    (h₁ : kTypeOf sig k (listSeg l₁) = kTypeOf sig k (listSeg l₁'))
    (h₂ : kTypeOf sig k (listSeg l₂) = kTypeOf sig k (listSeg l₂')) :
    kTypeOf sig k (listSeg (l₁ ++ l₂)) = kTypeOf sig k (listSeg (l₁' ++ l₂')) := sorry

end FormalSystem.Metalogic.WeakCanonical

namespace FormalSystem.Metalogic.Decidability.RaySummary

variable {F : FrameOver intOrder} [F.IsRegular]

/-- B1: the closure alphabet — the subformulas of `φ` plus the marker `now`. -/
def clSig (φ : PlusFormula) : MonadicSignature :=
  ⟨{ψ : PlusFormula // ψ ∈ (PlusFormula.subformulas φ).toFinset} ⊕ Unit⟩

instance (φ : PlusFormula) : Fintype (clSig φ).preds := sorry
instance (φ : PlusFormula) : DecidableEq (clSig φ).preds := sorry

/-- B1: the marker letter. -/
def clNow (φ : PlusFormula) : (clSig φ).preds := Sum.inr ()

/-- B1: the letter of `φ` itself. -/
def clPhi (φ : PlusFormula) : (clSig φ).preds := sorry

/-- B1: HWZ 2000 Def 11's run conditions on a colouring over the closure alphabet. -/
def LocalRun (φ : PlusFormula) (c : (clSig φ).preds → ℤ → Prop) : Prop := sorry

/-- B1: the anchors of a colouring to a history — atoms at states, `box`-letters per time,
`stab`-letters per state, `now` exactly at `t`. -/
def Anchored (M : TaskModel F.toTaskFrame) (φ : PlusFormula) (t : ℤ)
    (c : (clSig φ).preds → ℤ → Prop) (σ : WorldHistory F.toTaskFrame) : Prop := sorry

/-- B1: the trace of a history over the closure alphabet (HWZ 2000 Thm 14's `t_a`). -/
def clTrace (M : TaskModel F.toTaskFrame) (φ : PlusFormula) (t : ℤ)
    (σ : WorldHistory F.toTaskFrame) : (clSig φ).preds → ℤ → Prop := sorry

/-- B1: the realized family triples of an arbitrary trace over an arbitrary signature. -/
def HitSig (sig : MonadicSignature) [Fintype sig.preds] [DecidableEq sig.preds]
    (M : TaskModel F.toTaskFrame) (τ : WorldHistory F.toTaskFrame) (t : ℤ)
    (tr : WorldHistory F.toTaskFrame → sig.preds → ℤ → Prop) (k : ℕ) :
    Set (KType sig k × KType sig k × KType sig k) := sorry

/-- B1: the depth-1 target `∃x (now x ∧ phi x)` over an arbitrary signature. -/
def stabTargetSig (sig : MonadicSignature) (now phi : sig.preds) :
    (sig.preds → ℤ → Prop) → Prop := sorry

/-- B1: the hypothesis-free `⊡` bridge over an arbitrary signature with distinguished `now` and
`phi` letters; `plusStab_iff_forall_hit` is its two-letter instance. -/
theorem plusStab_iff_forall_hitSig (sig : MonadicSignature) [Fintype sig.preds]
    [DecidableEq sig.preds] (now phi : sig.preds) (M : TaskModel F.toTaskFrame)
    (τ : WorldHistory F.toTaskFrame) (t : ℤ) (φ : PlusFormula)
    (tr : WorldHistory F.toTaskFrame → sig.preds → ℤ → Prop)
    (hnow : ∀ σ z, tr σ now z ↔ z = t)
    (hphi : ∀ σ z, tr σ phi z ↔ PlusTruthAt M σ z φ) (k : ℕ) (hk : 1 ≤ k) :
    PlusTruthAt M τ t (.stab φ) ↔
      ∀ x ∈ HitSig sig M τ t tr k,
        ∀ c, InFamily sig k x.1 x.2.1 x.2.2 c → stabTargetSig sig now phi c := sorry

/-- B2a: the trace satisfies the run conditions (HWZ 2000 Thm 14 ⇒). -/
theorem clTrace_localRun (M : TaskModel F.toTaskFrame) (φ : PlusFormula) (t : ℤ)
    (σ : WorldHistory F.toTaskFrame) : LocalRun φ (clTrace M φ t σ) := sorry

/-- B2a: the trace is anchored to its history. -/
theorem clTrace_anchored (M : TaskModel F.toTaskFrame) (φ : PlusFormula) (t : ℤ)
    (σ : WorldHistory F.toTaskFrame) : Anchored M φ t (clTrace M φ t σ) σ := sorry

/-- B2a: an anchored local run is the trace (the uniqueness half of Thm 14 ⇒). -/
theorem eq_clTrace_of_localRun_anchored (M : TaskModel F.toTaskFrame) (φ : PlusFormula)
    (t : ℤ) (σ : WorldHistory F.toTaskFrame) {c : (clSig φ).preds → ℤ → Prop}
    (hr : LocalRun φ c) (ha : Anchored M φ t c σ) : c = clTrace M φ t σ := sorry

/-- B2a: the realized family triples of the closure trace. -/
def HitCl (M : TaskModel F.toTaskFrame) (τ : WorldHistory F.toTaskFrame) (t : ℤ)
    (φ : PlusFormula) (k : ℕ) :
    Set (KType (clSig φ) k × KType (clSig φ) k × KType (clSig φ) k) :=
  HitSig (clSig φ) M τ t (clTrace M φ t) k

section Presentation

variable {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]

/-- B3b: a bi-infinite run of a finite labelled presentation, with `now` exactly at `t`. -/
def IsRun {Q : Type} (step : Q → Q → Bool) (lab : Q → sig.preds → Bool) (now : sig.preds)
    (t : ℤ) (ρ : ℤ → Q) : Prop :=
  (∀ z, step (ρ z) (ρ (z + 1)) = true) ∧ ∀ z, (lab (ρ z) now = true ↔ z = t)

/-- B3b: the colouring a run writes on the time axis. -/
def runTrace {Q : Type} (lab : Q → sig.preds → Bool) (ρ : ℤ → Q) : sig.preds → ℤ → Prop :=
  fun p z => lab (ρ z) p = true

/-- B3b: the computable realized-triple set of a finite labelled presentation. -/
def hitOf (Q : Type) [Fintype Q] [DecidableEq Q] (lab : Q → sig.preds → Bool)
    (step : Q → Q → Bool) (now : sig.preds) (k : ℕ) :
    Finset (KType sig k × KType sig k × KType sig k) := sorry

/-- B3b: `hitOf` is exactly the set of family triples of the presentation's runs. -/
theorem mem_hitOf_iff (Q : Type) [Fintype Q] [DecidableEq Q] (lab : Q → sig.preds → Bool)
    (step : Q → Q → Bool) (now : sig.preds) (t : ℤ) (k : ℕ) (hk : 1 ≤ k)
    (x : KType sig k × KType sig k × KType sig k) :
    x ∈ hitOf Q lab step now k ↔
      ∃ ρ : ℤ → Q, IsRun step lab now t ρ ∧
        InFamily sig k x.1 x.2.1 x.2.2 (runTrace lab ρ) := sorry

end Presentation

/-- The realization hypothesis: the seam's trace set is the presentation's run set. NOT
discharged in this tree for any constructed model — that is B2b, the successor record. -/
def Presented (M : TaskModel F.toTaskFrame) (τ : WorldHistory F.toTaskFrame) (t : ℤ)
    (φ : PlusFormula) {Q : Type} (lab : Q → (clSig φ).preds → Bool) (step : Q → Q → Bool) :
    Prop :=
  ∀ c : (clSig φ).preds → ℤ → Prop,
    (∃ bf : SeqPair F (τ.state t), c = clTrace M φ t (spliced τ t bf)) ↔
      (∃ ρ : ℤ → Q, IsRun step lab (clNow φ) t ρ ∧ c = runTrace lab ρ)

/-- The per-model bridge: under `Presented`, the realized set is the computable `hitOf`. -/
theorem hit_eq_hitOf_of_presented (M : TaskModel F.toTaskFrame) (τ : WorldHistory F.toTaskFrame)
    (t : ℤ) (φ : PlusFormula) (k : ℕ) (hk : 1 ≤ k) {Q : Type} [Fintype Q] [DecidableEq Q]
    (lab : Q → (clSig φ).preds → Bool) (step : Q → Q → Bool)
    (hP : Presented M τ t φ lab step) :
    HitCl M τ t φ k = ↑(hitOf Q lab step (clNow φ) k) := sorry

end FormalSystem.Metalogic.Decidability.RaySummary
```

## Testing & Validation

- [ ] Every new module builds under the guarded, detached, scoped invocation; the full project
      builds at Phase 10.
- [ ] `#print axioms` (via `lean_verify`, fully qualified) on each Goal identifier reports exactly
      `[propext, Classical.choice, Quot.sound]`; `grep -c sorry` = 0 on every touched module; no
      `def X := True`-shaped vacuous placeholder anywhere.
- [ ] `kTypeOfFin`, `decEval`, `listSeg`, `pathTypes`, `fwdLive`, `bwdLive`, `hitOf` are
      `def`, never `noncomputable def`; `Tests/BimodalTest/Metalogic/KTypeFinEvalTest.lean`'s
      `#guard`s pass at depth 1.
- [ ] `bash scripts/check-evidence-probes.sh` exits 0 with
      `quasistate-does-not-determine-hit` wired; its headline theorem states quasistate equality,
      pair-relation equality AND `Hit` inequality in one conjunction.
- [ ] `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` carries the seven new pins and
      builds; `bash scripts/check-module-invariants.sh` green with the C14 baseline updated in the
      same commit as the index rows; `bash .claude/scripts/verify-deploy.sh` green.
- [ ] Prose audit: no file under `FormalSystem/`, `docs/`, `Tests/` says "`Hit` computed" without
      the `Presented` qualifier; every new module header names B2b as absent and the backward
      Bool-fixture limit as carried; no task numbers outside `specs/**` (C9).

## Artifacts & Outputs

- `FormalSystem/Metalogic/WeakCanonical/KTypeSummary/KTypeFin.lean` (B3a)
- `FormalSystem/Metalogic/Decidability/RaySummary/Closure.lean` (B1)
- `FormalSystem/Metalogic/Decidability/RaySummary/Trace.lean` (B2a + `Presented` bridge)
- `FormalSystem/Metalogic/Decidability/RaySummary/Compose.lean` (B3b)
- `specs/evidence/seam-gluing-ray-product/quasistate-does-not-determine-hit.lean` (B2b verdict, wired)
- `Tests/BimodalTest/Metalogic/KTypeFinEvalTest.lean` (computability witnesses)
- Updated: both aggregators, both READMEs, `KTypeSummaryAxiomTest.lean`, `docs/theorem-index.md`
  (+ C14 baseline), `scripts/check-evidence-probes.sh`, `specs/ROADMAP.md`
- `specs/742_compute_hit_realizability_device/summaries/01_compute-hit-realizability-device-summary.md`
  with a "Follow-up records" section carrying the B2b successor description verbatim and the
  context-pattern recommendation (`ℤ`-subtype decidability, `decidable_of_iff` argument order)
  for the agent-system source store.
- `.orchestrator-handoff.json` per dispatch; `sorry_inventory` empty at every green close.

## Rollback/Contingency

- Rung (a), fix forward, is the default for any RED state (`context/contracts/recovery.md`).
- Rung (b), `--hard` only: if `eq_clTrace_of_localRun_anchored`'s temporal cases or
  `mem_hitOf_iff`'s splice direction genuinely resist within a dispatch, land the remaining cases
  green and the resisting one as a documented strategic sorry meeting all five conditions of
  `anti-analysis.md`'s test, tracked in `sorry_inventory` with `strategic: true` and a follow-up
  owner, and report `implemented` with `skeleton: true` — never `def X := True`, never a weakened
  same-named statement.
- Rung (c), only if a genuine rollback is unavoidable: `bash .claude/scripts/git-snapshot.sh 742`
  in its default reverting mode (with `--allow-out-of-scope` only if a path outside `file_scope`
  must be included), then the smallest-scope rollback. An ordinary defensive checkpoint before
  the splice construction uses `--no-revert` instead.
- Phase 8 is a decision gate on the fixture, not on the plan: a failed quasistate equality is
  repaired inside the phase (fixture change recorded in the probe header); it never downgrades
  the theorem to a weaker statement, and it never bypasses Phases 1-7, 9, 10, which do not depend
  on it.
- If Phase 7's completeness direction cannot be closed because a realized triple's side segments
  can contain `now` at some `k` the plan did not anticipate, the honest fallback is to strengthen
  `hk` (state the bound actually needed) in `mem_hitOf_iff` and `hit_eq_hitOf_of_presented`,
  record it in the Challenge drift note of the summary, and mark the phase `[BLOCKED]` for user
  review per `plan-compliance.md` — not to silently widen `hitOf`.
