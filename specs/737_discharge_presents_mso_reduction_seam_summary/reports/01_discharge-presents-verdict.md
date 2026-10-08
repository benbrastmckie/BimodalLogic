# Research Report: Task #737

**Task**: 737 - Discharge the Presents hypothesis bundle: formalize the MSO-over-Z-less-than reduction behind the seam summary
**Started**: 2026-10-08T06:21:34Z
**Completed**: 2026-10-08T07:05:00Z
**Effort**: 1 research dispatch (lean4, standard mode); one 330-line research probe compiled during the dispatch
**Dependencies**: 711 (satisfied; substrate landed and re-verified this dispatch)
**Sources/Inputs**:
- Codebase, read in full this dispatch: `FormalSystem/Metalogic/Decidability/RaySummary/Seam.lean` (158 lines; `Presents` at lines 111-128), `FormalSystem/Metalogic/WeakCanonical/KTypeSummary/{Basic,Segment,Family,Saturation,Universal}.lean` and its README, `FormalSystem/PlusLanguage/PlusRayFibre.lean`, `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean`, `FormalSystem/Metalogic/Expressiveness/NormalForm.lean` (`doets_lemma_1_1`, `nf_exists_unique`), `FormalSystem/Metalogic/WeakCanonical/NEquivalence.lean` (`KType`, `kTypeOf`), `FormalSystem/Metalogic/Conservativity/Plus/Atomization.lean` (header, `plusTruthAt_iff_atomize`), `specs/evidence/seam-gluing-ray-product/{stab-depth-two-probe,ktype-summary-substrate-probe}.lean`, `scripts/check-evidence-probes.sh`
- Mathlib search tools: `lean_local_search` (index `warming` throughout — positive hits admissible, absences not; no absence claim in this report rests on it); no rate-limited search was needed, every candidate name was resolved by direct read and compilation
- lean-lsp MCP / toolchain: four `lake env lean` elaborations of the research probe through `lake-build-guard.sh`; `#print axioms` on the four headline theorems
- Literature: HWZ 2000 corpus chunk `chunk_0022.md` (Definition 12, Remark 13, Theorem 14) read directly this dispatch; Thomas 1997 p. 30 and GKWZ 2003 Thm 1.28 / Lemma 11.23 / Thm 13.6 carried from `specs/711_universal_summary_substrate_stab_fibre/reports/01_universal-summary-substrate.md` (the dispatch forbids re-running the shared-core check)
- Programme records: 711 report, plan v2 and summaries 01/02; 736 report; `specs/state.json` records for 711, 735, 737, 738; `specs/ROADMAP.md` Phase 1 lines 100-131
**Artifacts**:
- `specs/737_discharge_presents_mso_reduction_seam_summary/reports/01_discharge-presents-verdict.md` (this report)
- `specs/737_discharge_presents_mso_reduction_seam_summary/probes/presents-is-seam-decidedness.lean` (research probe, 330 lines, compiled; not yet in the evidence collection — landing and wiring it is a plan phase)
- `specs/737_discharge_presents_mso_reduction_seam_summary/probes/presents-is-seam-decidedness.compile.log` (the green compile record)
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **The principal field cannot be discharged on this route in its landed shape, and the obstruction is now machine-checked, not argued.** For every signature `sig`, every depth `k`, the single-family bundle `Presents M τ t φ sig k T S` is inhabited **iff** `φ` is `⊡`-decided at the seam — `⊡φ ∨ ⊡¬φ` at `(τ, t)`. Forward: `colours` + `determined` + `verdict` alone, through `family_saturation`, force every ray pair to agree on `φ` (`realized` is not even used). Backward: the constant target carrying the answer is a witness. So `colours` as landed is not the MSO reduction; it is a semantic condition on the seam that is false in general and whose truth makes the bridge `plusStab_iff_seamSummary` restate `⊡φ ↔ ⊡φ`. Compiled: `exists_presents_iff`, `[propext, Classical.choice, Quot.sound]`, no `sorryAx`.
- **The obstruction bites on a real seam.** On the E2 fixture (two states `a`, `b`; edges `a→a`, `a→b`, `b→b`; `p` at `b`), the seam `(stayA c t, t)` is undecided on `Fp`: `stayA` refutes it, `jumpB` satisfies it, both pass through `(c, a)`. Hence `¬ Presents Mg (stayA c t) t Fp sig k T S` for **every** `sig`, `k`, `T`, `S` (`no_presents_on_fixture`, compiled, standard axioms). This is acceptance outcome (b) for field (1): the obstruction is a theorem on a regular ℤ-frame, not prose.
- **The corrected shape discharges all four fields definitionally — and moves the whole cost to one named object.** With the two-letter trace encoding (`now` marker + `φ`'s truth along the history), the depth-1 target `∃x (now x ∧ φ x)`, and `Hit` := the set of family triples realized by some ray pair's trace, the `⊡` bridge is a **theorem with no hypothesis bundle**: `⊡φ ↔ ∀ tr ∈ Hit, ∀ c ∈ family tr, T c`, with `Hit` finite (`plusStab_iff_forall_hit`, `hit_finite`, compiled). A four-field `PresentsMulti` mirroring the landed bundle is inhabited outright (`presentsMulti_trace`, compiled). Field (3) `determined` is a 9-line corollary of `doets_lemma_1_1` for any depth-≤k sentence (`determinedByKType_eval`) — the quick win the dispatch predicted, and as it warned, no evidence for the rest.
- **Coverage answer, asked for early:** the landed `KTypeSummary/` cluster supplies Büchi's **complementation half** in full — finite-index congruence, bi-infinite Ramsey cover, saturation, finite union of families — and **nothing of the realizability half**: no characterization of which traces a model's path space realizes (`Hit`), no effective `k`-type composition, no computable `kTypeOf` (it is `Classical.dec` by design). 711's plan v2 built none of its v1 realizability deliverables D2-D4 (`FwdPresentation`/`Profile`/fulfilling-run theorem); summary 02 says so verbatim. The question is one of coverage, and the coverage is exactly one half.
- **Verdict (outcome (b), complete and valid):** the MSO-over-⟨ℤ,<⟩ reduction is NOT discharged by this route and cannot be discharged by any theorem over the landed cluster alone; its content is `Hit`, i.e. the quasimodel/realizability direction (HWZ Def 12 + Thm 14 with the one-sided-liveness repair, then a decision for quasimodel existence), which costs the B1-B4 components tabulated under Findings. Recommend: land the probe wired into the gate; land the corrected interface beside (not replacing) the landed bundle with the degeneracy pinned in its docstring and in the axiom test; re-point 735's dependency at `Hit`; no `user_decision`.
- **No complexity bound is claimed, upper or lower.** Everything stays under `[F.IsRegular]`, over the time axis, with a finite alphabet of per-time summaries.

## Context & Scope

The dispatch asks whether `Presents` (four fields, `Seam.lean:111-128`, re-verified by direct read this dispatch) can be discharged in whole or field by field, with each remaining field's obstruction stated as a theorem or a wired probe, and — before committing to phases — how much of Büchi's segment-congruence argument the landed `k`-type cluster already supplies. It forbids re-running the (c)/(d) shared-core check (settled by 711 at Medium-High: candidate (d) *is* Büchi's Ramsey proof of the complementation step inside route (c)), forbids porting from cslib, forbids sorry deferral, new axioms, finite-fibre or finite-width assumptions, and any complexity claim.

What this report does: states the bundle's inhabitation condition exactly and proves it both ways; exhibits a concrete seam with no inhabitant; builds the corrected interface and proves the bridge from it with no hypothesis; names the residue and costs it. What it does not do: it builds no decision procedure, decides nothing, and does not touch `FormalSystem/` (the probe lives in the task directory until a plan phase lands it in `specs/evidence/`).

Evidence tier announced per the readiness context: `lean_local_search` reported `index: warming` on every call, so it was used only to confirm presence (`Presents` resolved to `Seam.lean`); every other name in this report was resolved by reading its declaration and by compiling against it.

Territory: sibling 738 (markdown, no `file_scope`) was concurrently dispatched; `git status` showed only state-file modifications, no foreign commits, and no running build (the `lean --worker` processes are `lake serve`'s file workers). Nothing outside the task directory and the scratchpad was written.

## Findings

### Codebase Patterns

- **The bundle's parameters are inert for inhabitation.** `Presents` takes `sig`, `k`, `T`, `S` as parameters; `colours` quantifies over all ray pairs with `S` fixed first. Since `determined` makes `T` constant on `S`'s family (`family_saturation`, `Universal.lean:84`), `colours` reduces to "every ray pair's `φ`-value equals one fixed value", and `verdict` fixes that value to `S.holds`. The exact derivation is `seamDecided_of_presents` in the probe; it uses `plusStab_iff_seamSummary` for the `holds = true` branch and `family_saturation` for the other, and never touches `realized`.
- **The trivial witness.** When the seam is decided, `T := fun _ => ⊡φ-at-(τ,t)`, `S := ⟨τneg, τzero, τpos, decide (⊡φ)⟩` with the triple read off `family_cover` on the constant colouring, and `realized` witnessed by `τ`'s own pair `seamOmegaEquiv t (τ.state t) ⟨τ, rfl⟩`, inhabit the bundle for every `sig`, `k` (`exists_presents_of_seamDecided`). This is the "true-looking name over a proof that does not reach it" the dispatch warns about, now shown to be the *only* kind of inhabitant the landed shape admits.
- **The one-family limitation was recorded but its consequence was not.** `Seam.lean` point (c), the RaySummary README ("One family per summary") and 711 summary 02 all name the one-family shape as a limitation with a multi-family generalisation left to the consumer. None records that the one-family shape collapses to seam decidedness; the module docstring still calls `colours` "the unformalized MSO reduction" at Medium confidence. That sentence is wrong as stated and should be corrected in the same change that lands the probe (Recommendation 2).
- **The substrate is exactly the complementation half.** `KTypeSummary/README.md`'s six-step table marks steps 2, 3, 3′, 4, 5, 5′ landed and step 6 out of scope. Against Thomas 1997 p. 30 (carried from 711's report, Key Findings): finite-index congruence ⇒ `kType_finite`; `⋃ U_i · V_i^ω` cover ⇒ `family_cover` (bi-infinite); "the complement has again such a representation" ⇒ `family_saturation` + `target_eq_union_of_families`. The recognizability/emptiness side — which families a given structure realizes, and whether that set is computable — has no counterpart in the cluster. 711 summary 02 line 45: "nothing from v1's `FwdPresentation`/`Profile` design was built"; 711's `file_scope` still lists `RaySummary/{Profile,Forward,Backward,Periodic,Colour,Stab}.lean`, none of which exists on disk (only `Seam.lean` does).
- **`kTypeOf` is noncomputable by construction** (`NEquivalence.lean:72`, `Classical.dec`), and the substrate probe records that no claim rests on evaluating a `k`-type. Any "verdict" `Bool` built on the cluster is classical. That is not a defect of the cluster; it is a measurement of what a decision procedure would still have to add.
- **`determined` generalises cheaply.** `determinedByKType_nfEval` (`Universal.lean:70`) is the `nf`-coordinate of the `k`-type; `doets_lemma_1_1` (`NormalForm.lean:460`) lifts the same argument to any sentence of depth ≤ k. The probe's `determinedByKType_eval` is that lemma, 9 lines, and belongs in `Universal.lean` beside its special case.
- **The E2 fixture is the right undecided seam and is cheap to transcribe.** `FrameOver.ofSlicedStep` + `ofSlicedStep_isRegular` (`SlicedFrame.lean:283`) give a regular ℤ-frame from a two-state step relation; `stayA`/`jumpB` and their state lemmas transcribe in 50 lines (the collection's standing rule is transcribe, never import a probe).
- **Durable anchors re-verified by name this dispatch**: `infinite_ramsey_pairs` at `RamseyFactorization.lean:82` is a one-line alias of `Nat.exists_strictMono_const_pair_colour` at `InfiniteRamseyPairs.lean:134`; `not_finite_width_fmp` at `NoFiniteWidth.lean:1280`; `pastStab_iff_allBwdPathsMeet` at `backward-dual-asymmetric-fixture.lean:577`; the retired-as-vacuous section of `Correctness.lean` at line 192. The stale `:146` citation the dispatch warns about was not propagated.

### External Resources

- **HWZ 2000, Definition 12 / Remark 13 / Theorem 14** (`chunk_0022.md`, read directly): a quasimodel is a state function `f` with a set of runs `R` such that every constant's run is in `R` and every type in every quasistate is realized by some run; Theorem 14: a sentence is satisfiable on a flow iff satisfied in a quasimodel over it; the proof's `⇒` direction builds `f(w)` from the sets of subformulas true at each domain element. This is the realizability direction `Hit` needs: in our setting the "domain elements" are histories through the seam and the "types" are their traces. The one-sided-liveness repair 711's report derived from Lemma 17's splice hazard applies unchanged.
- **HWZ Thm 15, GKWZ Thm 1.28 / Lemma 11.23 / Thm 13.6, Thomas 1997 p. 30**: carried from 711's report lemma table [CARRIED-UNVERIFIED: `specs/711_universal_summary_substrate_stab_fibre/reports/01_universal-summary-substrate.md`, "Lemma-level mapping table" and "Key Findings"]. Their status there — `blocked (frame only)` under zero-debt — is unchanged by anything here.
- **cslib** (read-only reference per 736; not re-elaborated this dispatch): `IsRegular.compl` proved upstream through `buchiFamily_cover` + `buchiFamily_saturation`; zero MSO anywhere in `Cslib/`; `BuchiCompl.lean`'s correctness theorems are `proof_wanted` [CARRIED-UNVERIFIED: `specs/736_cslib_omega_automata_survey_and_e3_reopen_check/reports/01_cslib-omega-automata-survey.md`, A.3-A.4 and (D)]. Relevant here only as confirmation that the shape this cluster has — cover + saturation — is the complementation proof and nothing more; cslib's *emptiness* side lives in its automaton infrastructure, which is over states and is the axis the programme has refuted.
- **Mathlib at pin `v4.33.0-rc1`**: no infinite Ramsey for pairs, no ω-automata, no MSO [CARRIED-UNVERIFIED: 711 report "External Resources" grep sweep; 736 report (D) grep sweep]. Nothing in this report needs Mathlib beyond what the cluster already imports.

### The obstruction, stated (field 1, and what it drags with it)

Probe `presents-is-seam-decidedness.lean`, Part 1 (compiled; the exact statements are the plan's Challenge Statements):

```lean
def SeamDecided (M : TaskModel F.toTaskFrame) (τ : WorldHistory F.toTaskFrame) (t : ℤ)
    (φ : PlusFormula) : Prop :=
  PlusTruthAt M τ t (.stab φ) ∨ PlusTruthAt M τ t (.stab φ.neg)

theorem seamDecided_of_presents (h : Presents M τ t φ sig k T S) : SeamDecided M τ t φ

theorem exists_presents_of_seamDecided (hdec : SeamDecided M τ t φ)
    (sig : MonadicSignature) [Fintype sig.preds] [DecidableEq sig.preds] (k : ℕ) :
    ∃ (T : (sig.preds → ℤ → Prop) → Prop) (S : SeamSummary sig k), Presents M τ t φ sig k T S

theorem exists_presents_iff (sig : MonadicSignature) [Fintype sig.preds] [DecidableEq sig.preds]
    (k : ℕ) :
    (∃ (T : (sig.preds → ℤ → Prop) → Prop) (S : SeamSummary sig k),
      Presents M τ t φ sig k T S) ↔ SeamDecided M τ t φ
```

Part 2 (compiled): on the transcribed E2 fixture `Fg`/`Mg`, `seam_undecided (c t : ℤ) : ¬ SeamDecided Mg (stayA c t) t Fp` and

```lean
theorem no_presents_on_fixture (c t : ℤ) (sig : MonadicSignature) [Fintype sig.preds]
    [DecidableEq sig.preds] (k : ℕ) (T : (sig.preds → ℤ → Prop) → Prop) (S : SeamSummary sig k) :
    ¬ Presents Mg (stayA c t) t Fp sig k T S
```

Reading per field, as the dispatch asks:

| Field | Single-family shape (landed) | Corrected shape (probe Part 3) |
|---|---|---|
| (1) `colours` | **Not dischargeable** except on decided seams; obstruction `no_presents_on_fixture`. Not the MSO reduction. | Definitional: `c := trace`, triple from `family_cover` (Ramsey), value by `Tφ_trace`. |
| (2) `realized` | Vacuous once (1),(3),(4) hold (any ray pair works); never needed for the obstruction. | Definitional: `Hit` is the set of realized triples. |
| (3) `determined` | Trivial for the constant target. | `Tφ_determined` via `determinedByKType_eval` (Doets 1.1), any `k ≥ 1`. Real content, small. |
| (4) `verdict` | Does not follow from (1)-(3): `holds` is free. It is what pins the one value all pairs share. | A finite conjunction over `Hit`; the `Bool` is classical (`decide` under `open Classical`). |

### The corrected interface and the residue (probe Part 3)

```lean
abbrev sig2 : MonadicSignature := ⟨Bool⟩          -- true = `now`, false = φ
def trace (M) (φ) (t) (σ) : sig2.preds → ℤ → Prop := fun p z => bif p then z = t else PlusTruthAt M σ z φ
def nowPhi : MonadicFormula sig2 0 := .ex (.and (.atom true 0) (.atom false 0))   -- depth 1
def Tφ : (sig2.preds → ℤ → Prop) → Prop := fun c => eval (zFiber sig2 c) Fin.elim0 nowPhi
def Hit (M) (τ) (t) (φ) (k) : Set (KType sig2 k × KType sig2 k × KType sig2 k) :=
  {tr | ∃ bf : SeqPair F (τ.state t), InFamily sig2 k tr.1 tr.2.1 tr.2.2 (trace M φ t (world τ t bf))}

theorem hit_finite : (Hit M τ t φ k).Finite
theorem plusStab_iff_forall_hit (hk : 1 ≤ k) :
    PlusTruthAt M τ t (.stab φ) ↔ ∀ tr ∈ Hit M τ t φ k, ∀ c, InFamily sig2 k tr.1 tr.2.1 tr.2.2 c → Tφ c
structure PresentsMulti ... (hit : Set _) (holds : Bool) : Prop   -- same four fields, triple → set
theorem plusStab_iff_presentsMulti (h : PresentsMulti M τ t φ sig k T hit holds) : ⊡φ ↔ holds = true
theorem presentsMulti_trace (hk : 1 ≤ k) : PresentsMulti M τ t φ sig2 k Tφ (Hit M τ t φ k) (decide ⊡φ)
```

All four: `[propext, Classical.choice, Quot.sound]`, no `sorryAx` (`#print axioms` foot of the probe; compile log in `probes/`). The bridge is a theorem; the whole of what the dispatch calls "the MSO reduction" is now the single question **is `Hit` computable from a finite presentation of `M`?** — and for 735's validity target, **which `Hit`-sets are realizable by some model at all?** Neither is answered by anything landed.

### Coverage: what the cluster supplies and what remains (the early answer)

| Büchi's argument (Thomas 1997 §5.1, carried) | `k`-type idiom | In tree | Needed for the residue |
|---|---|---|---|
| finite-index congruence on segments | `KType`, `kType_finite` | yes | — |
| every ω-word in some `U·V^ω` class-family (Ramsey) | `family_cover`, bi-infinite | yes | used by `colours` |
| saturation: each family inside or outside `L` | `family_saturation` | yes | used by the bridge |
| complement is a finite union of families | `finite_family_triples`, `target_eq_union_of_families` | yes | used (finiteness of `Hit`) |
| each family `U·V^ω` is itself recognizable | membership in a family is `k'`-type-determined for some `k'` | **no** | not needed for the bridge; needed to make `Hit` a *definable* object |
| recognizability / emptiness of `L` | which family triples the model's path space realizes (`Hit`); effective `k`-type composition | **no** | **this is the residue** |

Residue components, costed (engineering effort only; no complexity claim):

| Component | What it is | Est. lines | Risk |
|---|---|---|---|
| B0 | Land the probe wired into the gate; land `determinedByKType_eval`; land the corrected interface (`SeamDecided`, `exists_presents_iff`, `PresentsMulti`, `Hit`, hypothesis-free bridge) with pins and docs | ~450 (330 compiled + glue, pins, docs) | none — compiled |
| B1 | Alphabet: subformula closure of the atomized `φ` as `sig.preds`; trace as the full labelling; local run conditions (HWZ Def 11 `U`/`S` clauses) on traces | 300-500 | low-medium |
| B2 | Realizability: a colouring is a trace of a history through the seam iff it satisfies local run conditions and per-time state realizability (quasistate), with one-sided live flags — HWZ Def 12 / Thm 14 for *this* semantics; this is 711's dropped D2-D5 in trace form | 1,500-2,500 [CARRIED-UNVERIFIED for the D2-D5 figures: 711 report "Estimated cost" table, 1,900-2,700 lines / 7-9 dispatches] | high — the Lemma 17 splice hazard and the backward half both live here |
| B3 | Effective composition: computable `kTypeOf` on finite segments and a `compose : KType → KType → KType → KType` with correctness against `kEquiv_orderedSum_of_kEquiv_colour`; without it no `Bool` is computable | 800-1,500 | high — `kTypeOf` is `Classical.dec` by design; the mixing lemma is an equivalence, not a computation |
| B4 | For validity: satisfiability ↔ existence of a (repaired) quasimodel ↔ a finite search over `Hit`-sets; the composition-method analogue of "MSO-definable ⟺ `k`-type-determined for some `k`" | unbounded here; this is HWZ Thm 15 / GKWZ 1.28's work and is `blocked` under zero-debt as a citation | — |

B0 is this task's honest deliverable. B1-B3 are a per-model device and belong to a successor record that 735 depends on; B4 is the validity quantification and is 735's own frame. The gap is larger than the cluster can close in this record, and saying so with B0 landed is the complete outcome the dispatch names.

### Recommendations

1. **Land the probe as outcome (b)**: `specs/evidence/seam-gluing-ray-product/presents-is-seam-decidedness.lean` from `probes/` verbatim (header rewritten to the collection's "What is established / What is NOT established / Axiom record / Compile line" form), appended to `WIRED` in `scripts/check-evidence-probes.sh` with its doc block; run the collection once. Zero research risk.
2. **Correct the record where it is wrong.** `Seam.lean` point (c) and the `Presents` docstring call `colours` "the unformalized MSO reduction" at Medium confidence; the RaySummary README repeats it. Replace with: the one-family bundle is inhabited iff the seam is decided (`exists_presents_iff`), the multi-family shape is the interface, and the reduction's content is `Hit`. Do not delete `Presents` or `plusStab_iff_seamSummary` (they are pinned, cited, and correct as theorems); add the degeneracy beside them.
3. **Land the corrected interface in the library**, as a new module `FormalSystem/Metalogic/Decidability/RaySummary/SeamMulti.lean` (or in `Seam.lean` if the planner prefers one file): `SeamDecided`, `seamDecided_of_presents`, `exists_presents_of_seamDecided`, `exists_presents_iff`, `PresentsMulti`, `plusStab_iff_presentsMulti`; and, generically over any `sig` with a marker predicate rather than the probe's `Bool`, `Hit`, `hit_finite`, the trace, and `plusStab_iff_forall_hit`. Put `determinedByKType_eval` in `KTypeSummary/Universal.lean` beside `determinedByKType_nfEval`. Pin `exists_presents_iff`, `plusStab_iff_forall_hit`, `plusStab_iff_presentsMulti` in `KTypeSummaryAxiomTest.lean` (same `#guard_msgs` pattern; expected profile pcq). Add one row to the Decidability section of `docs/theorem-index.md` for `plusStab_iff_forall_hit` (frame class ZTime under `[F.IsRegular]`, axioms `pcq`).
4. **Keep the fixture-level obstruction in the probe, not the library**: `no_presents_on_fixture` transcribes E2's frame and belongs in the evidence collection.
5. **Re-point 735.** Its input is no longer "discharge `Presents`" but "decide `Hit` (B1-B3) and quantify over models (B4)"; its description should name `plusStab_iff_forall_hit` as the bridge it consumes and `Hit` as the object it must compute. Spawning B1-B3 as a successor lean4 record between this one and 735 is the planner's call; this report recommends it so that 735 does not absorb the cost silently — the exact risk this task was filed to close.
6. **`file_scope` at plan time** (proposed in `.return-meta.json`): the probe, `scripts/check-evidence-probes.sh`, `RaySummary/{Seam,SeamMulti}.lean`, `RaySummary.lean`, `RaySummary/README.md`, `KTypeSummary/Universal.lean` and README, `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean`, `docs/theorem-index.md`, `specs/ROADMAP.md`. Contention with 733/734 on the gate script stands; dispatch singly.
7. **Carry both inherited limits unchanged.** The characterization is direction-symmetric (ray pairs carry the backward factor), but the exhibited undecided seam is forward (`Fp`); no backward Bool-fixture bridge is built here, and `pastStab_iff_allBwdPathsMeet` remains the only backward fixture result. E2's falsifier check remains a weak positive.

## Decisions

- **D-1 Outcome (b), not (a).** The dispatch names a recorded, machine-checked verdict as complete; field (1) in the landed shape is provably undischargeable except on decided seams, so (a) is not available and no partial discharge is presented as more than it is.
- **D-2 Do not re-run the shared-core check.** Thomas 1997 p. 30 is cited as carried from 711; HWZ chunk 0022 was read directly only because the cost table needed Definition 12 / Theorem 14's exact shape.
- **D-3 The probe stays in the task directory for now.** Writing into `specs/evidence/` and the gate script is implementation work with declared contention; research hands the compiled text to the plan.
- **D-4 Keep the landed bundle; add beside it.** `Presents` and `plusStab_iff_seamSummary` are correct theorems with pinned profiles and external citations; the fix is to record their degeneracy, not to delete them.
- **D-5 No `user_decision`.** Every open choice (one module or two, successor record or not, `Bool` vs. generic marker alphabet) is a routine engineering judgment the plan can make; the ROADMAP consequence — that 711 → 737 → 735 now has a named B1-B4 gap between 737 and 735 — is a finding to record, not a choice the user must make before planning.

## Risks & Mitigations

- **Risk: the plan lands `PresentsMulti` and 735 treats `presentsMulti_trace` as "Presents discharged".** The `Bool` there is `decide` under `open Classical`; it computes nothing. Mitigation: the docstring and the theorem-index row must say "hypothesis-free bridge over the realized set; `Hit` is not computed"; pin the statement so the wording cannot drift from the term.
- **Risk: generalising the probe's `Bool` alphabet to a marker-plus-closure signature introduces `Fintype`/`DecidableEq` plumbing for a subtype of `PlusFormula`.** Mitigation: state the library version over an arbitrary `sig` with a distinguished `now : sig.preds` and an arbitrary `φ`-predicate, exactly as the probe does with `true`/`false`; closure alphabets are B1's business.
- **Risk: `lake-build-guard.sh build` REPLAYs a stale result for `env lean <file>` after the file changes** (observed this dispatch, 56 s window; keyed on argv, not content). Mitigation: single-file recompiles pass `--no-share`; recorded in the issue log.
- **Risk: a reader takes the undecided-seam fixture as a claim about `⊡(Pp)`.** Mitigation: Recommendation 7 and the probe header carry the forward-only scope explicitly.
- **Risk: the stale `RamseyFactorization.lean:146` anchor resurfaces from ROADMAP/711 records.** Mitigation: this report cites by name with the line re-resolved (`:82` alias, `:134` canonical).

## Literature Proof Structure

**Source**: HWZ 2000 §3 (Defs 10-12, Thm 14; `chunk_0022.md` read directly) framing GKWZ 2003 Lemma 11.23 / Thm 1.28 / Thm 13.6 and Thomas 1997 §5.1 (carried from 711's report, which holds the full step map; not re-extracted here).
**Strategy**: satisfiable ⟺ quasimodel exists (Thm 14); quasimodel existence is an MSO sentence over the flow (Lemma 11.23); decide it on ⟨ℤ,<⟩ by Büchi (Thm 15 / Thm 1.28); Büchi's hard step, complementation, by Ramsey on segment classes (Thomas p. 30) — the landed cluster.

### Step Map (restricted to what bears on the four fields)

1. Trace of a history = the set of subformulas true at each time — HWZ Thm 14 proof, `t_a = {ψ : (M, w) ⊨_a ψ}` → probe `trace` (two letters; B1 widens to the closure).
2. Realized types per time, every type realized by a run — HWZ Def 12 (second clause) → `Hit` (realized family triples) and the corrected `realized` field.
3. Universal over histories ⟺ conjunction over realized types — Thm 14 `⇒` direction read at the seam → `plusStab_iff_forall_hit`.
4. Complementation / saturation making the conjunction finite — Thomas p. 30 → `family_saturation`, `finite_family_triples` (landed).
5. Deciding quasimodel existence — HWZ Thm 15 / GKWZ 1.28 → **blocked** under zero-debt; the `k`-type analogue is B3-B4.

### Dependencies

Step 3 depends on 1, 2, 4; step 5 depends on everything and is absent.

### Potential Formalization Challenges

- Step 2 for `⊡`: a quasistate must carry one-sided live flags (711's Lemma 17 finding); `Hit` as defined sidesteps this by being semantic, which is exactly why it is not computable as it stands.
- Step 5: the composition method needs effective `k`-type composition; the tree's mixing lemma is an equivalence proved classically.

## Tactic Survey Results

| Goal | Tactic / method | Result | Premises/Config |
|---|---|---|---|
| `Presents → SeamDecided` | `by_cases` on `S.holds`; `rw [plusStab_iff_omega, PlusTruth.neg_iff]`; `rcases family_saturation` | success, pcq | `plusStab_iff_seamSummary`, `h.colours`, `h.verdict`, `h.determined`, `family_saturation` |
| `SeamDecided → ∃ T S, Presents` | `classical`; `family_cover` on the constant colouring; constant target; `decide_eq_true_iff` | success, pcq | `family_cover`, `plusStab_iff_omega`, `PlusTruth.neg_iff`, `seamOmegaEquiv` |
| `¬ SeamDecided Mg (stayA c t) t Fp` | `rintro (h\|h)`; `PlusTruth.stab_iff` applied to `stayA` / `jumpB`; state lemmas by `rfl` + `ring` | success, pcq | transcribed E2 fixture, `PlusTruth.someFuture_iff` |
| `DeterminedByKType sig k (fun c => eval (zFiber sig c) _ ψ)` for depth ≤ k | `doets_lemma_1_1` after `unfold kTypeOf; congr_fun; simp only [decide_eq_decide]` | success, pcq | `doets_lemma_1_1`, `nf_exists_unique` (inside it) |
| `Tφ (trace …) ↔ PlusTruthAt M σ t φ` | `simp only [Tφ, nowPhi, eval, zFiber, trace, Fin.cons_zero, cond_true, cond_false]` then `constructor` | success | none beyond unfolding |
| `⊡φ ↔ ∀ tr ∈ Hit, ∀ c ∈ family, Tφ c` | `rw [plusStab_iff_omega]`; `family_saturation` one way, `family_cover` the other | success, pcq | `Tφ_determined`, `Tφ_trace` |
| `PresentsMulti … (decide ⊡φ)` | `where` fields; `open Classical in` so the `decide` instance and `rw [decide_eq_true_iff]` agree | success after one instance-synthesis failure (explicit `@decide _ (Classical.propDecidable _)` cannot be rewritten) and one parse error (`open … in` must precede the docstring) | `plusStab_iff_forall_hit` |
| `#print axioms` × 4 | guarded `lake env lean`, `--no-share` on recompiles | all `[propext, Classical.choice, Quot.sound]`; `grep -c sorry` = 0 over 330 lines | — |

No `simp`/`omega`/`aesop` was used to bypass a step the literature handles explicitly; the only automation is `ring`/`omega` on the fixture's integer arithmetic, as in E2.

## Context Extension Recommendations

- **Topic**: hypothesis bundles that collapse to a semantic condition. **Gap**: no context note warns that a universally-quantified "realization" hypothesis with a single fixed summary collapses to agreement of all witnesses; this is the second record (after `Correctness.lean`'s retired section) where a true-looking interface carried no reduction. **Recommendation**: add a short pattern note under `context/project/lean4/patterns/` ("inhabitation check before discharge": state `(∃ params, Bundle) ↔ ?` and prove it before building on the bundle), citing `exists_presents_iff` once landed.
- **Topic**: `lake-build-guard.sh` sharing semantics for `env lean`. **Gap**: `long-builds.md` does not say that result sharing keys on argv, so a changed file recompiled within the window is silently replayed. **Recommendation**: one sentence in `context/project/lean4/operations/long-builds.md` naming `--no-share` for single-file elaboration.
- **Topic**: decidability-side pointer to the coverage finding. **Gap**: `ztime-no-finite-carrier-fmp.md` §8 (per 711) still has no paragraph on what the `k`-type cluster covers and what `Hit` is. **Recommendation**: fold the coverage table above into that section when the corrected interface lands.

## Appendix

### Search queries used

- `lean_local_search`: `Presents` (hit: `FormalSystem.Metalogic.Decidability.RaySummary.Presents`, `Seam.lean`; `index: warming`).
- Repository greps: `infinite_ramsey_pairs|exists_strictMono_const_pair_colour`; `theorem not_finite_width_fmp`; `theorem pastStab_iff_allBwdPathsMeet`; `retired|vacuous` in `Correctness.lean`; `def StabFibre`; `neg` in `Formula.lean`; `doets_lemma_1_1`, `nf_exists_unique`, `nfToSentence` in `NormalForm.lean`; `def eval`, `quantifierDepth` in `MonadicFO.lean`; `def zFiber`; `class IsRegular`; `ofSlicedStep` in `SlicedFrame.lean`; `WIRED` in `check-evidence-probes.sh`; `737|Presents|colours` in `ROADMAP.md`; D2-D4/`Profile` in 711 summary 02 and plan 02; `jq` over `state.json` for 711/735/737/738.
- Literature: `~/Projects/Literature/sources/hodkinson_wolter_zakharyaschev_2000_decidable_fragments_fotl/chunk_0022.md` lines 1-60 (Def 12, Remark 13, Thm 14).
- Build: `lake-build-guard.sh build [--no-share] --timeout 900 -- env lean <probe>` × 4 (attempt 1: one instance error, parts 1-2 green; 2: REPLAY of 1; 3: parse error at `open … in`; 4: green, exit 0).

### References to documentation

- `FormalSystem/Metalogic/WeakCanonical/KTypeSummary/README.md` (six-step table, consumer relation, two carried limits).
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` ("One family per summary").
- `.claude/context/formats/report-format.md` (carried-figure discipline applied above).
- `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` (pin pattern to extend).
- Issue log this dispatch: two `win` entries (early finding; compiled probe), one `issue` (guard REPLAY on a changed file, minor).
