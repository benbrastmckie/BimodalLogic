# Research Report: Task #735

**Task**: 735 - Assemble the decidable stab check on the ray-product presentation: Decidable (PlusValidZTime phi)
**Started**: 2026-10-08T13:50:00Z
**Completed**: 2026-10-08T14:35:00Z
**Effort**: ~45 minutes (one research dispatch, `--hard --lit`)
**Dependencies**: 711 (complete), 737 (complete), 742 (complete)
**Sources/Inputs**: Codebase (`FormalSystem/Metalogic/Decidability/RaySummary/`, `KTypeSummary/`, `PlusLanguage/`), task 742 summary and research report, task 737 summary, the wired probe `quasistate-does-not-determine-hit.lean`, lean-lsp MCP (`lean_local_search`, `lean_loogle`), two compiled research probes (`lake env lean`), literature briefing (HWZ 2000 entry is UNVERIFIED-summary provenance)
**Artifacts**: this report; `specs/735_decidable_stab_check_ray_product_assembly/probes/presented-not-complete.lean` (compiled, 0 sorries, axioms `[propext, Classical.choice, Quot.sound]`); `specs/735_decidable_stab_check_ray_product_assembly/probes/stab-run-check.lean` (compiled, same axiom set)
**Standards**: report-format.md, subagent-return.md, anti-analysis.md (lean4), reference-grounding.md (lean4), adversarial-verification.md (lean4), context-hygiene.md

## Executive Summary

- **The acceptance criterion's first branch (`Decidable (PlusValidZTime φ)` machine-checked) is NOT reachable in this task**, and the reason is now a theorem rather than prose. The ray-product presentation as landed — the realization hypothesis `Presented M τ t φ lab step` (exact equality of the seam's closure-trace set with a finite presentation's run-trace set) — is **not a complete presentation notion**: on the three-state regular model A of the B2b verdict fixture, at the seam `(t, a)` with `φ := Fp`, `¬ Presented MA stayA t Fp lab step` holds for EVERY finite `Q`, `lab`, `step`. Proof: pumping. The run-trace set of a finite presentation is closed under repeating a loop, the seam's trace set contains `(¬p,Fp)^{n+1}(p,Fp)^ω` for every `n` but not its pumped limit `(¬p,Fp)^ω` (which violates the `untl` run condition `LocalRun.untl`). Compiled as `Probe735.not_presented` in `probes/presented-not-complete.lean` (246 lines, 0 sorries, standard axioms). This refutes, for this semantics, any route that would decide `PlusValidZTime φ` by enumerating `Presented`-presentations — independently of whether the B2b successor (realization of a presentation by a constructed model, `Presented (modelOf P)`) is ever built. B2b remains the right carrier for *soundness* of refutations; it cannot be the carrier for *completeness*.
- **The positive in-frame deliverable is cheaper than the landed docstring suggests, and it is compiled.** Under `Presented`, `⊡φ` at the seam is a run-level condition with no `k`-type evaluation: `PlusTruthAt M τ t (.stab φ) ↔ ∀ ρ, IsRun lab step (clNow φ) t ρ → lab (ρ t) (clPhi φ) = true` (`Probe735b.plusStab_iff_forall_run_of_presented`, 34 lines, compiled). The per-triple condition `∀ c, InFamily … → stabTargetSig …` that `plusStab_iff_forall_hitOf_of_presented`'s docstring names as this task's work collapses to this under `Presented`; the `kTypeOf_zFiber_eq_of_inFamily` + representative route is only needed under the strictly weaker hypothesis `HitCl M τ t φ k = ↑(hitOf lab step (clNow φ) k)` (call it `HitPresented`), and there `PathEntry.rep` already stores the representative. Decidability of the run-level condition reduces to state liveness in the `now`-free step graph (`live`, `live_iff`, `HasChain` in `Present.lean`; the gluing template is `exists_run_of_live` in `HitOf.lean`), ~150-250 lines, LOW-MEDIUM risk.
- **Recommended outcome: the acceptance criterion's second branch, plus the per-seam conditional check.** Land (i) the wired obstruction probe, (ii) `Decidable (PlusTruthAt M τ t (.stab φ))` under `Presented` stated IN the theorem (never `Decidable (PlusValidZTime φ)`), (iii) a recorded verdict in the Decidability README, theorem index and ROADMAP naming the three theorems the lift to validity still needs — Hit-level completeness with a computable state bound, Hit-level soundness (the B2b successor, restated at `hitOf` level), and a closure-wide (all seams, all times, `box` per time) quasimodel — none of which is in the tree and only one of which (B2b, at the wrong level) is a filed record. **No sorry-free path to `Decidable (PlusValidZTime φ)` exists from the landed substrate; this is a complete, valid outcome under the task's own acceptance text.**

## Context & Scope

The task owns the consumer of the ray-product/seam-gluing route: `Decidable (PlusValidZTime φ)` or a recorded, cited verdict that the presentation cannot deliver it, with the obstruction as a theorem or wired probe. HARD CONSTRAINTS in force: never "L⁺ is decidable" unqualified; every decidability statement carries frame class (regular ℤ-frames, `[F.IsRegular]`), language fragment (L⁺, `PlusFormula`), premise set and hypothesis; no assembly on an undischarged `Presented` presented as unconditional; no finite-fibre assumption; no complexity bound.

Inputs re-verified BY NAME (grep over `FormalSystem/`, `specs/evidence/`, `Tests/`; `lean_local_search` returned `index: error`, so name-existence evidence is grep plus successful compilation of probes that `import FormalSystem` and use the names — a stronger tier than the LSP index):

| Declaration | File:line (2026-10-08) | Role here |
|---|---|---|
| `Presented` (def, Prop) | `RaySummary/Trace.lean:278` | the realization hypothesis; refuted as complete |
| `presented_localRun` | `Trace.lean:286` | every run of a presented presentation is a `LocalRun` |
| `hit_eq_hitOf_of_presented` | `Trace.lean:301` | `HitCl = ↑hitOf` under `Presented`, `1 ≤ k` |
| `plusStab_iff_forall_hitOf_of_presented` | `Trace.lean:323` | its proof uses ONLY `hit_eq_hitOf_of_presented` (so it holds verbatim under `HitPresented`) |
| `HitCl`, `plusStab_iff_forall_hitCl`, `hitCl_eq_iUnion` | `Trace.lean:224-258` | closure-alphabet bridge |
| `hitOf`, `mem_hitOf_iff_live`, `mem_hitOf_iff`, `exists_run_of_live`, `live_of_run` | `HitOf.lean:554, 561, 795, 587, 698` | computable realized triples; run/liveness gluing templates |
| `IsRun`, `runTrace`, `PathEntry` (with `rep`), `pathTypesNow`, `mem_pathTypesNow_iff`, `live`, `live_iff`, `HasChain`, `fwdLive`, `bwdLive` | `Present.lean:162, 166, 232, 360, 581, 605, 652, 609, 667, 671` | presentations, representatives, liveness |
| `LocalRun` (with `.untl`), `Anchored`, `clTrace`, `clLetter`, `clPhi`, `clNow`, `stabTargetSig`, `stabTargetSig_determined`, `HitSig`, `plusStab_iff_forall_hitSig` | `Closure.lean:120-300` | run conditions and the generic bridge |
| `InFamily`, `family_cover` | `KTypeSummary/Family.lean:201, 207` | families |
| `kTypeOf_zFiber_eq_of_inFamily`, `kTypeOf_zFiber_eq_of_sameTriple` | `KTypeSummary/Saturation.lean:133, 108` | block type is family-determined |
| `DeterminedByKType`, `determinedByKType_eval`, `family_saturation`, `finite_family_triples` | `KTypeSummary/Universal.lean:69, 90, 107, 133` | saturation |
| `kTypeOfFin`, `kTypeOfFin_eq` | `KTypeSummary/KTypeFin.lean:121, 128` | computable `k`-type on finite segments |
| `KType sig k := NormalForm sig k 0 → Bool` | `WeakCanonical/NEquivalence.lean:62` | |
| `plusStab_iff_rays`, `plusStab_iff_omega`, `seamOmegaEquiv`, `SeqPair`, `StabFibre` | `PlusLanguage/PlusRayFibre.lean:116, 290, 271`; `Semantics/Presheaf/Ray.lean:352` | keystone, `[F.IsRegular]` |
| `spliced` (abbrev) | `RaySummary/SeamMulti.lean:188` | `((seamOmegaEquiv t (τ.state t)).symm bf).1` |
| `plusValidZTime_iff_plusValidInt`, `PlusValidZTime` | `PlusLanguage/PlusIntTransfer.lean:188`; `PlusValidity.lean:111` | carrier normalization; the target predicate |
| `Presents`, `plusStab_iff_seamSummary`, `exists_presents_iff` (737) | `Seam.lean:115, 146` | the single-family bundle, refuted by 737 as a seam condition |
| `not_finite_width_fmp` | `PlusSlicedCertificate/Limits/NoFiniteWidth.lean:1280` | no finite-fibre assumption |
| `quasistate_does_not_determine_hit` (wired probe) | `specs/evidence/seam-gluing-ray-product/quasistate-does-not-determine-hit.lean:460` | fixture reused here |
| `FrameOver.ofSlicedStep`, `ofSlicedStep_isRegular`, `ofSlicedStep_step`, `worldHistoryOfStepPath`, `PlusTruth.someFuture_iff` | used by the fixture probe; re-used verbatim | |

Task 737's verdict (summary §Overview, outcome (b)): `Presents` is dischargeable only on `⊡`-decided seams (`exists_presents_iff`), refuted on the E2 fixture (`no_presents_on_fixture`); the corrected shape is the hypothesis-free `plusStab_iff_forall_hit` with the reduction's residue isolated in `Hit`. Task 742 then computed `hitOf` on presentations and stated `Presented`. This report's obstruction is the next link: `Presented` itself is not complete.

Reference-grounding tier: **Tier 1 strict** (HWZ 2000 Definitions 11-12 / Theorem 14; Doets 1989 Lemma 1.1) composed with Tier 3 (port/extend the landed `RaySummary` modules). The HWZ 2000 corpus entry is marked `provenance_fidelity: unverified_summary`; no page number from it is treated as load-bearing. Every load-bearing claim below is machine-checked.

## Findings

### Lemma-level mapping table (H3 Tier 1, 5-column)

| Source | Prop/Location | Lean Identifier | Type Signature | Status |
|---|---|---|---|---|
| HWZ 2000 | Def 11 (run conditions over ⟨ℤ,<⟩), p. — (entry UNVERIFIED; not page-verified) | `RaySummary.LocalRun` | `structure LocalRun (φ) (c : (clSig φ).preds → ℤ → Prop) : Prop` with `.untl : c (ψUχ) z ↔ ∃ s, z < s ∧ c χ s ∧ ∀ r, z < r → r < s → c ψ r` | transcribed (742 B1) |
| HWZ 2000 | Thm 14 ⇒ (types read off a model), p. — | `clTrace_localRun`, `eq_clTrace_of_localRun_anchored` | `LocalRun φ (clTrace M φ t σ)`; anchored local run = trace | transcribed (742 B2a) |
| HWZ 2000 | Def 12 / Thm 14 ⇐ (realizability), p. — | — (B2b successor record, not filed) | `Presented (modelOf P) … lab step` | pending (successor) |
| HWZ 2000 | Thm 14 ⇐ read as COMPLETENESS of `Presented` ("every model's seam is presented") | `Probe735.not_presented` (this report, `probes/presented-not-complete.lean`) | `∀ t {Q} [Fintype Q] [DecidableEq Q] lab step, ¬ Presented MA stayA t Fp lab step` | **REFUTED, compiled** |
| this formalization | run-level `⊡` check under the hypothesis | `Probe735b.plusStab_iff_forall_run_of_presented` (`probes/stab-run-check.lean`) | `Presented M τ t φ lab step → (PlusTruthAt M τ t (.stab φ) ↔ ∀ ρ, IsRun lab step (clNow φ) t ρ → lab (ρ t) (clPhi φ) = true)` | **compiled**, pending landing |
| this formalization | decidable per-seam check under the hypothesis | `stabCheck` / `decidable_stab_of_presented` (proposed) | `Presented M τ t φ lab step → Decidable (PlusTruthAt M τ t (.stab φ))` | pending (plan Phase 2) |
| Doets 1989 | Lemma 1.1 (depth-≤k sentences are k-type-determined) | `doets_lemma_1_1`, `determinedByKType_eval`, `stabTargetSig_determined` | `DeterminedByKType sig k (fun c => eval (zFiber sig c) Fin.elim0 ψ)` for `ψ.quantifierDepth ≤ k` | transcribed (711/737) |
| Büchi (as carried by 711) | Ramsey cover / saturation | `family_cover`, `family_saturation`, `kTypeOf_zFiber_eq_of_inFamily` | see table above | transcribed (711) |
| Mathlib | pigeonhole (`Mathlib.Data.Fintype.Pigeonhole`) | `Fintype.exists_ne_map_eq_of_card_lt` | `(f : α → β) (h : card β < card α) : ∃ x y, x ≠ y ∧ f x = f y` | verified (`lean_loogle`, and used in the compiled probe) |
| this formalization | `⊡` fibre is a product of ray sets | `seamOmegaEquiv`, `plusStab_iff_omega` | `StabFibre F.toTaskFrame t s ≃ SeqPair F s`; `⊡φ ↔ ∀ bf, PlusTruthAt M (spliced τ t bf) t φ` | transcribed (landed) |
| Mathlib/Lean core | `Equiv.symm_apply_apply` | — | `e.symm (e x) = x` | used (compiled) |

### Finding 1 — Under `Presented`, the `⊡` check is run-level; no `k`-type is evaluated (compiled)

`plusStab_iff_forall_hitOf_of_presented`'s docstring frames the remaining work as making the per-triple condition `∀ c, InFamily (clSig φ) k x.1 x.2.1 x.2.2 c → stabTargetSig …` effective "through `kTypeOf_zFiber_eq_of_inFamily` and a middle-segment representative". Under the hypothesis `Presented` that detour is unnecessary. `Presented` is an equality of trace sets in both directions, so:

```
PlusTruthAt M τ t (.stab φ)
  ↔ ∀ bf, PlusTruthAt M (spliced τ t bf) t φ                  -- plusStab_iff_omega
  ↔ ∀ bf, clTrace M φ t (spliced τ t bf) (clPhi φ) t          -- clTrace_clPhi (defeq)
  ↔ ∀ ρ, IsRun lab step (clNow φ) t ρ → runTrace lab ρ (clPhi φ) t   -- Presented, both directions
  ↔ ∀ ρ, IsRun … ρ → lab (ρ t) (clPhi φ) = true              -- runTrace (defeq)
```

This is `Probe735b.plusStab_iff_forall_run_of_presented` in `probes/stab-run-check.lean`, compiled on the first attempt, axioms `[propext, Classical.choice, Quot.sound]`. It is the `⊡` bridge over the presentation with the family machinery factored out entirely.

**Decidability of the right-hand side** reduces to state liveness. `∀ ρ, IsRun … ρ → lab (ρ t) phi` is equivalent to `∀ q, OnRun q → lab q phi = true` where `OnRun q := ∃ ρ, IsRun lab step now t ρ ∧ ρ t = q`, and `OnRun q ↔ lab q now = true ∧ live Gfwd q = true ∧ live Gbwd q = true` with `Gfwd x y := step x y && !lab y now` and `Gbwd x y := step y x && !lab y now` (`live`/`live_iff`/`HasChain` in `Present.lean:605-652` are generic over any `G : Q → Q → Bool`). The ⇐ direction glues the two `HasChain` witnesses into a ℤ-indexed run exactly as `exists_run_of_live` (`HitOf.lean:587`) glues its chains; the ⇒ direction reads the chains off the run. Then `stabCheck lab step φ : Bool := decide (∀ q, lab q (clNow φ) → live Gfwd q → live Gbwd q → lab q (clPhi φ))` and

```
theorem stabCheck_iff_of_presented … (hP : Presented M τ t φ lab step) :
    stabCheck lab step φ = true ↔ PlusTruthAt M τ t (.stab φ)
def decidableStab_of_presented … (hP : Presented M τ t φ lab step) :
    Decidable (PlusTruthAt M τ t (.stab φ)) := decidable_of_iff _ (stabCheck_iff_of_presented … hP)
```

Note `t` does not occur in `stabCheck`: under `Presented` the seam time is carried by the anchor `now`. Estimated 150-250 lines, LOW-MEDIUM risk (the gluing lemma is the only non-trivial step and has a landed template). **Every statement carries `[F.IsRegular]`, L⁺, regular ℤ-frames and `Presented` in its signature; none mentions `PlusValidZTime`.**

**The per-triple route survives for the weaker hypothesis.** `plusStab_iff_forall_hitOf_of_presented` is proved by `rw [plusStab_iff_forall_hitCl …, hit_eq_hitOf_of_presented …]` (Trace.lean:331), so it holds verbatim under `HitPresented M τ t φ lab step k := HitCl M τ t φ k = ↑(hitOf lab step (clNow φ) k)`, which `hit_eq_hitOf_of_presented` shows is implied by `Presented`. Under `HitPresented` only, the `⊡` check is `∀ x ∈ hitOf, ∀ c, InFamily … x c → stabTargetSig … c`, and making THAT effective is the docstring's route: for `x ∈ hitOf` the family is nonempty (`mem_hitOf_iff` gives a run `ρ`), all members share the block `k`-type (`kTypeOf_zFiber_eq_of_inFamily`), the target is `k`-type-determined for `k ≥ 1` (`stabTargetSig_determined`), so the condition is `stabTargetSig (runTrace lab ρ)`, i.e. `lab (ρ t) phi` — and the middle path's stored representative `PathEntry.rep : List (sig.preds → Bool)` (`Present.lean:243`) carries that `now`-state's label, so `∃ ℓ ∈ e.rep, ℓ now ∧ ℓ phi` is the Bool for the entry `e` whose `ty` is `x.2.1`. Correctness needs `doets_lemma_1_1` between the representative's `listSeg` and the run's middle segment (same `k`-type, depth-1 sentence, `k ≥ 1`). Estimated 250-400 lines, MEDIUM. Whether `HitPresented` is itself satisfiable where `Presented` is not (Finding 2) is an OPEN QUESTION this report does not settle (Low confidence that it is; see Adversarial Self-Verification).

### Finding 2 — THE OBSTRUCTION: `Presented` is not complete, even for a finite regular model (compiled)

**Claim (verbatim, machine-checked).** On fixture model A of `quasistate-does-not-determine-hit.lean` — `St := Fin 3`, `RA _ u v := v = u ∨ v = b`, `FA := FrameOver.ofSlicedStep RA …` (regular by `ofSlicedStep_isRegular`), `p` at `b` only, `Fp := someFuture (.atom pa)`, seam `stayA` (constant at `a`) at any `t`:

```
theorem Probe735.not_presented (t : ℤ) {Q : Type} [Fintype Q] [DecidableEq Q]
    (lab : Q → (clSig Fp).preds → Bool) (step : Q → Q → Bool) :
    ¬ Presented MA stayA t Fp lab step
-- 'Probe735.not_presented' depends on axioms: [propext, Classical.choice, Quot.sound]
```

**Proof shape (as compiled).** Let `n := Fintype.card Q`. The history `jump (t + n + 1)` (at `a` through `t + n + 1`, at `b` after) passes through the seam, so its closure trace is a seam trace; by `Presented` (⇒) it is `runTrace lab ρ` for an anchored run `ρ`. On that trace `Fp` holds at `t` (`jump_Fp`) and `p` fails on `[t, t + n + 1]` (`jump_p_iff`). Pigeonhole (`Fintype.exists_ne_map_eq_of_card_lt`) on the `n + 1` positions `t + 1, …, t + n + 1` gives `t < i < j ≤ t + n + 1` with `ρ i = ρ j`. The pumped run `pump ρ i j` (`ρ` up to `i`, then the segment `[i, j)` forever, via a `Nat`-recursive index `loopIdx` — no modular arithmetic) is an anchored run (`pump_isRun`), its `now` is still only at `t` because the loop lies strictly after `t`, its value at every `z ≥ t` is a value of `ρ` on `[t, j)` (`pump_exists`). By `Presented` (⇐) its trace is a seam trace, hence a `LocalRun` (`clTrace_localRun`); `LocalRun.untl` at `t` for the letter `Fp = top U (atom pa)` demands `p` at some `s > t`, but every such position reads `ρ` on `[t, j) ⊆ [t, t + n + 1]` where `p` is false. Contradiction.

**What it establishes.** (i) `Presented` is unsatisfiable for a *finite-slice* regular model whose seam has an unboundedly deferrable eventuality — the fixture that 742's own research and the successor record discuss (Finding 3 (c) of 742's report speaks of closedness of the *model's* path set on a finite slice; the dual fact used here is that the *presentation's* run set is pumping-closed whatever the model, while the trace map `σ ↦ clTrace` is not continuous in the `untl` letters, so the seam's trace set need not be closed). (ii) Therefore no decision procedure for `PlusValidZTime φ` can proceed by "every regular ℤ-model refuting `φ` has a `Presented` presentation": model A refutes `⊡¬Fp` at `(t, a)` (`stab_notFp_A` in the wired probe) and has no `Presented` presentation at all. (iii) B2b (`Presented (modelOf P)` for constructed models) is untouched as a *soundness* device — `modelOf P` is built so that its trace set IS the run set — but any `P` with a pumpable eventuality-deferring run is not `Presented` by anything (`presented_localRun` already forces every run to be a `LocalRun`), so B2b's consistency conditions must exclude exactly those presentations, and B2b can never be the completeness half.

**What it does NOT establish.** Nothing about `⊡(Pp)` (forward-only, as every probe in the collection). Nothing about `HitPresented` (Finding 1): the pumped limit trace's family triple differs from every seam trace's triple at depth `k ≥ 1` (its forward type satisfies `∀x ¬p x`, theirs do not), so the pumping argument does NOT refute `HitCl = ↑hitOf` — a presentation realizing one representative per family could in principle satisfy it; this is unproven either way. No complexity statement. No claim about the ⊡-fibre of infinite-slice models.

**Literature position (contextual, not load-bearing).** HWZ 2000's Theorem 14 ⇐ realizes a quasimodel over ⟨ℤ,<⟩ by *persistent runs* ⟨r, ξ⟩ (742's research Finding 3 (c)); its ⇒ direction extracts a quasimodel from a model as per-time *type sets* — never an exact trace-set equality. The exact-equality hypothesis `Presented` is this formalization's own device (its docstring says "the paper has no counterpart"), and this finding shows it is strictly stronger than what the paper's completeness direction provides. The closed/pumping-closed character of run sets of finite graphs without acceptance condition is the standard safety-language fact (Thomas 1997, *Languages, Automata, and Logic*, corpus entry 15; section not page-verified here); it is cited only as context because the probe proves the instance it needs outright.

### Finding 3 — What `Decidable (PlusValidZTime φ)` needs beyond the per-seam check (the verdict)

`PlusValidZTime φ := PlusValidIn FrameClass.ZTime φ` quantifies over every regular ℤ-frame model, history and time. The landed route reaches, at most, `Decidable (PlusTruthAt M τ t (.stab φ))` for ONE seam of ONE model GIVEN a presentation of that seam. Three theorems separate that from the task's headline, and none is in the tree:

| Missing theorem | Statement shape (must carry `[F.IsRegular]`, L⁺, ZTime) | Status in tree / records | Why `Presented` cannot be its carrier |
|---|---|---|---|
| **(C) Completeness with a computable bound** | For every regular ℤ-model `M`, seam `(τ, t)` and `φ`, there is a presentation `(Q, lab, step)` with `card Q ≤ B(φ, k)` for a computable `B`, such that the per-seam check at `(M, τ, t)` agrees with the check on the presentation. | Not in tree; NOT a filed record. 742's successor record is soundness-only. | Finding 2: with `Presented` as "agrees", (C) is FALSE (model A). At `HitPresented` level it is open; a bound `B` would have to come from `finite_family_triples` plus an ultimately-periodic representative per family (Ramsey/Büchi, `infinite_ramsey_pairs` is in tree), i.e. a Hit-level small-presentation theorem. |
| **(S) Soundness of refutation** | Every presentation passing the local consistency checks is realized by a regular ℤ-model whose seam check agrees. | The B2b successor record (summary of 742, "Follow-up records"), NOT filed, 1,200-2,000 lines HIGH + 300-500 MEDIUM for the infinite-slice regular-frame constructor (carried-unverified figures). | `Presented (modelOf P)` is the right shape here, but only for `P` whose run set is pumping-consistent (every run a `LocalRun`, forced by `presented_localRun`); the record's consistency conditions must say so explicitly. |
| **(W) Closure-wide quasimodel** | The per-seam `⊡` check decides one `stab` letter at one seam. Validity of `φ` needs every closure formula at every time: `box` letters are per-time data over ALL histories (`Anchored.box`), `stab` letters per state, nested under `untl`/`snce`. The whole thing is HWZ's quasimodel over ⟨ℤ,<⟩ with the product repair at every seam, not a single-seam bridge. | Not in tree; not a filed record; not costed anywhere. | `Presented` is a single-seam hypothesis; (W) needs a presentation of all seams at once (a finite per-time alphabet of product summaries — 742 research Finding 3 (b)), consistent with `not_finite_width_fmp`. |

**Verdict (recorded, cited).** The ray-product presentation as landed (`seamOmegaEquiv` + `hitOf` + `Presented`) delivers a decidable per-seam `⊡` check **conditional on `Presented`** and nothing further: it cannot deliver `Decidable (PlusValidZTime φ)` because its realization hypothesis is refuted as a completeness carrier by `Probe735.not_presented` (theorem, standard axioms), and because the two further theorems (C)/(W) exist neither in the tree nor as records. The obstruction is a theorem; the missing pieces are named with their shapes. Under the task's acceptance text this is a complete outcome. The ROADMAP's critical path "742 → B2b successor → 735" must be corrected: B2b (as described) makes nothing about 735 unconditional for arbitrary models, and 735 should not carry a dependency on it for this task's deliverable.

### Finding 4 — The forbidden conditional shape, named so the plan avoids it

A theorem `(h : PresentationComplete φ) → Decidable (PlusValidZTime φ)` where `PresentationComplete φ` bundles (C), (S) and (W) as hypotheses would satisfy the acceptance criterion's letter and be exactly the defect the HARD CONSTRAINTS forbid ("a theorem whose content is carried entirely by a hypothesis"; cf. the retired-as-vacuous section of `Correctness.lean:192`). The distinction the plan must hold: `Presented M τ t φ lab step` is a hypothesis about ONE model and ONE presentation with substantial landed content on both sides (`hit_eq_hitOf_of_presented`, `mem_hitOf_iff`, `plusStab_iff_forall_run_of_presented`, the liveness decision); a bundle quantifying over all models with the decision procedure's correctness as a field has no content outside the hypothesis. Recommendation: the implement phases state only per-seam conditional results, and the verdict names (C), (S), (W) as *successor requirements*, never as hypotheses of a landed theorem.

### Finding 5 — Costs

| Item | Lines | Risk | Evidence tier |
|---|---|---|---|
| Wired obstruction probe `presented-not-complete.lean` (+ `check-evidence-probes.sh` row) | 246 (measured; compiled) | LOW | compiled in this dispatch |
| `plusStab_iff_forall_run_of_presented` into `Trace.lean` | 34 (measured; compiled) | LOW | compiled in this dispatch |
| `OnRun`/liveness characterization + `stabCheck` + `stabCheck_iff_of_presented` + `decidableStab_of_presented` (new module `RaySummary/StabCheck.lean`) | 150-250 | LOW-MEDIUM | template `exists_run_of_live` (HitOf.lean:587-694, ~100 lines for a harder gluing) |
| `#guard` witnesses that `stabCheck` evaluates on the fixture presentations (`KTypeFinEvalTest.lean`) | 20-40 | LOW | `hitOf` already evaluates there |
| Optional: `HitPresented` restatement of the bridge + representative per-triple check via `PathEntry.rep` | 250-400 | MEDIUM | Finding 1; requires `doets_lemma_1_1` on `listSeg` |
| Axiom pins (`KTypeSummaryAxiomTest.lean`), theorem-index rows (all marked **Conditional**), README "what it does not do", ROADMAP critical-path correction, Decidability README row | 100-200 | LOW | 742 Phase 10 pattern |
| **NOT in scope**: (C), (S), (W) | (S): 1,500-2,500 carried-unverified; (C), (W): uncosted | HIGH | successor requirements |

### Recommendations

1. **Plan the task to the acceptance criterion's second branch, with the per-seam conditional check as the positive deliverable.** Phases: (1) land the wired obstruction probe verbatim from `probes/presented-not-complete.lean` into `specs/evidence/seam-gluing-ray-product/presented-not-complete.lean`, wire it into `scripts/check-evidence-probes.sh`, with `#print axioms` foot; (2) land `plusStab_iff_forall_run_of_presented` beside `plusStab_iff_forall_hitOf_of_presented` in `Trace.lean`, and the liveness decision `stabCheck`/`stabCheck_iff_of_presented`/`decidableStab_of_presented` in a new `RaySummary/StabCheck.lean` (imports `Trace`, `Present`); (3) `#guard` evaluation witnesses; (4) optional `HitPresented` generalization; (5) pins, index rows (Conditional, hypothesis named in the row), READMEs, ROADMAP correction, and the recorded verdict paragraph naming (C), (S), (W). Zero sorries at every phase end; every statement under `[F.IsRegular]`.
2. **Never state `Decidable (PlusValidZTime φ)` in this task**, conditional or not (Finding 4). The theorem-index row for the per-seam decider must read "Conditional: under `Presented …`; `Presented` is refuted as a completeness carrier by `presented-not-complete.lean`".
3. **Correct the ROADMAP and the successor record's framing** (ROADMAP.md lines 28, 100, 142-159): the critical path is not "B2b → 735". B2b is (S) only; (C) and (W) are new, unfiled requirements; 735's deliverable does not depend on B2b. Add to the B2b record: "consistency conditions must exclude pumpable eventuality-deferring run sets (`presented_localRun`); completeness is out of its reach (`presented-not-complete.lean`)".
4. **Set `file_scope` at plan time** (mandatory per the task): `FormalSystem/Metalogic/Decidability/RaySummary/Trace.lean`, `FormalSystem/Metalogic/Decidability/RaySummary/StabCheck.lean` (new), `FormalSystem/Metalogic/Decidability/RaySummary.lean`, `FormalSystem.lean`, `FormalSystem/Metalogic/Decidability/RaySummary/README.md`, `FormalSystem/Metalogic/Decidability/README.md`, `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean`, `Tests/BimodalTest/Metalogic/KTypeFinEvalTest.lean`, `docs/theorem-index.md`, `scripts/check-evidence-probes.sh`, `specs/ROADMAP.md`, `specs/evidence/seam-gluing-ray-product/presented-not-complete.lean`.
5. **Do not reintroduce a finite-fibre assumption and do not claim a bound**: `stabCheck` is `decide` over `Q` with two greatest-fixpoint liveness computations; no complexity statement anywhere (the ceiling held in task 738 is unresolved and ARGUED only).

## Decisions

- D-1: The task's outcome is the recorded verdict (acceptance branch 2) plus the per-seam conditional decider; `Decidable (PlusValidZTime φ)` is not assembled in any form. Reason: Findings 2-4.
- D-2: The primary positive route is the run-level check under `Presented` (Finding 1), not the per-triple/`k`-type route the landed docstring names; the per-triple route is kept as an optional phase for the weaker `HitPresented`. Reason: compiled, 34 lines, no `k`-type evaluation; the docstring's framing predates the observation that `Presented` makes the family condition collapse.
- D-3: The obstruction is landed as a wired evidence probe on the existing fixture (model A), not as a library theorem over arbitrary models. Reason: a library-level "run sets are pumping-closed" lemma is reusable but the verdict needs exactly one instance; generalization is a follow-up if (S) wants it.
- D-4: The successor dependency on B2b is NOT added to this task. Reason: Finding 3 — B2b changes nothing about what this task may claim.

## Adversarial Self-Verification

### Claim Verification Table

| Claim | Source/Counterexample | Verification Method | Confidence |
|---|---|---|---|
| `¬ Presented MA stayA t Fp lab step` for every finite `Q`, `lab`, `step` (model A, seam `a`) | `probes/presented-not-complete.lean`, `Probe735.not_presented` | `lake env lean` compile, `#print axioms` = `[propext, Classical.choice, Quot.sound]`, no `sorryAx` | High |
| Under `Presented`, `⊡φ ↔ ∀ ρ, IsRun … ρ → lab (ρ t) (clPhi φ) = true` | `probes/stab-run-check.lean`, `Probe735b.plusStab_iff_forall_run_of_presented` | `lake env lean` compile, same axiom set | High |
| `plusStab_iff_forall_hitOf_of_presented`'s proof uses only `hit_eq_hitOf_of_presented` (so holds under `HitPresented`) | `Trace.lean:331-332` (`rw [plusStab_iff_forall_hitCl …, hit_eq_hitOf_of_presented …]; exact Iff.rfl`) | bounded `Read` of the proof body | High |
| `Presented` is discharged for no non-trivial model in the tree | `Trace.lean:271` docstring; 742 summary; README line 50 | directly-read source (two independent documents agree) | High |
| `Fintype.exists_ne_map_eq_of_card_lt` signature | Mathlib `Data/Fintype/Pigeonhole` | `lean_loogle` hit AND used in the compiled probe | High |
| `IsRun` is a per-coordinate (step + `now`-anchor) condition, hence pumping-closed | `Present.lean:162-163` | bounded `Read`; the compiled `pump_isRun` | High |
| `LocalRun.untl` is the strict-future clause with the guard on the open interval | `Closure.lean:131-136` | bounded `Read`; used by the compiled probe | High |
| The decision `∀ ρ, IsRun → lab (ρ t) phi` reduces to `now`-labelled states live in both `now`-free step graphs | `live`, `live_iff`, `HasChain` (`Present.lean:605-652`); gluing template `exists_run_of_live` (`HitOf.lean:587`) | source read; NOT compiled in this dispatch | Medium — statement shape verified, proof not run; plan Phase 2 risk item |
| `HitPresented` (`HitCl = ↑hitOf`) might be satisfiable on model A where `Presented` is not | argument: the pumped limit's forward type satisfies `∀x ¬p x`, differing from every seam trace's type; a finite union of representative traces could realize exactly the seam's triples | reasoning only; no search tool or compile | Low — stated as OPEN, not relied on |
| No theorem in the tree states (C), (S) or (W) | grep for `PlusValidZTime` consumers and `Decidable` in `FormalSystem/Metalogic/Decidability/RaySummary/`; ROADMAP lines 28-159; 742 summary Follow-ups | grep + two directly-read documents | High |
| HWZ 2000 Thm 14 ⇐ uses persistent runs, not exact trace equality | 742 research report Finding 3 (c); corpus entry 83 is UNVERIFIED-summary | secondary source only; not page-verified | Medium — contextual, not load-bearing |
| `lean_local_search` evidence tier | returned `index: error` for `Presented` (hit present) | per `<lean-readiness-context>` rule, name-existence here rests on grep + compilation, which is stronger | High (for the names used in compiled probes) |

### Contradiction Log

One apparent contradiction, resolved by the precedence ranking (directly-read/compiled Lean > secondary report prose):

- 742's research Finding 3 (c): "On a finite slice this set [histories through a state] is closed in the product topology, so any presentation whose runs defer an eventuality without bound is realized together with its limit path" — read naively, this suggests finite-slice models are the *easy* case for `Presented`. The compiled probe shows the opposite for the trace set: the *path* set of model A is closed, but the *trace* map is discontinuous in `Fp`, so the trace set is not closed, while the presentation's run-trace set always is. Both statements are true; the prose was about paths, the obstruction is about traces. No unresolved contradiction remains.

### Recommendations modified after verification

- The initial framing (from the landed docstring) that this task's work is "the effective per-triple check through `kTypeOf_zFiber_eq_of_inFamily` and a middle-segment representative" was downgraded to an optional phase after `plusStab_iff_forall_run_of_presented` compiled: under `Presented` the family condition collapses to a run-level read-off.
- The initial expectation that the obstruction would need an infinite-slice regular frame (and hence the B2b-pre constructor) was dropped after noticing that the trace map's discontinuity in `untl` letters already breaks closedness on the finite fixture; the probe reuses `ofSlicedStep` on `Fin 3` unchanged.
- The ROADMAP's critical path "742 → B2b → 735" is reported as incorrect for this task's deliverable (Recommendation 3) rather than adopted.

## Literature Proof Structure

**Source**: Hodkinson–Wolter–Zakharyaschev 2000, "Decidable fragments of first-order temporal logics" (corpus entry 83, UNVERIFIED-summary provenance; 742's research report Finding 3 and Step Map are the in-repo transcription), Definitions 10-12 and Theorem 14 over ⟨ℤ,<⟩; Doets 1989 Lemma 1.1 (`doets_lemma_1_1`); Thomas 1997 for the closed-language background (contextual).

**Strategy (paper)**: satisfiability ⇔ existence of a quasimodel: a state function over the flow assigning per-time type sets, with runs through them satisfying the local conditions; ⇒ extracts types from a model, ⇐ builds a model from persistent runs; decidability by encoding "a quasimodel exists" in MSO over ⟨ℤ,<⟩ (Büchi) or by automata.

**Step map, with the landed status and this report's deviation**:

| Step | Paper | Lean (landed / this report) | Note |
|---|---|---|---|
| 1 | Def 11 local run conditions | `LocalRun` | transcribed |
| 2 | Thm 14 ⇒ (model → types/runs) | `clTrace_localRun`, `eq_clTrace_of_localRun_anchored`, `hitCl_eq_iUnion` | transcribed per seam |
| 3 | Thm 14 ⇐ (quasimodel → model) | B2b successor, absent | pending; this report: must restrict to pumping-consistent presentations |
| 3' | ⇐ read as "every model is presented" (the formalization's `Presented`) | `Probe735.not_presented` | **divergence from the paper is forced**: the paper never asserts exact trace equality; `Presented` is stronger and refuted as complete |
| 4 | Per-seam `⊡` decision from a presentation | `plusStab_iff_forall_run_of_presented` (compiled); `stabCheck` (planned) | this report's device; no paper counterpart |
| 5 | Closure-wide quasimodel over all times (`box` per time, `stab` per state) | absent — (W) | uncosted; outside this task |
| 6 | Finite bound on the quasimodel / MSO encoding | absent — (C) | the paper's bound is on type sets, i.e. Hit-level; a `Presented`-level bound is impossible (3') |

**Dependencies**: `[F.IsRegular]` throughout; `seamOmegaEquiv`; `k ≥ 1` wherever `k`-types enter; `not_finite_width_fmp` forbids any finite-fibre shortcut.

**Potential formalization challenges**: the `OnRun ↔ liveness` gluing (ℤ-indexed from two ℕ-chains; template exists); keeping `stabCheck` computable (`decide` over `Fintype Q`, `live` already computable per `KTypeFinEvalTest.lean`); index-row wording that never drops the hypothesis.

## Tactic Survey Results

| Goal | Tactic / term | Result | Premises |
|---|---|---|---|
| `clTrace MA Fp t σ = clTrace MA Fp t (spliced stayA t (seamOmegaEquiv … ⟨σ, hσt⟩))` | `simp only [spliced, Equiv.symm_apply_apply]` | FAILED (lemma did not fire; anonymous constructor elaborated against the bare subtype, not `StabFibre`) | — |
| same | `let x : Presheaf.StabFibre FA.toTaskFrame t (stayA.state t) := ⟨σ, hσt⟩; have hrt := Equiv.symm_apply_apply (seamOmegaEquiv …) x; show …; rw [hrt]` | SUCCESS | `StabFibre F t s = {σ // σ.state t = s}` (`Ray.lean:352`) |
| `IsRun lab step now t (pump ρ i j)` | case split on `z + 1 ≤ i` / `z = i` / `i < z`, `omega` on `Int.toNat`, `split_ifs` on the wrap-around | SUCCESS first attempt | `loopIdx_bounds` by induction |
| pigeonhole on positions after `t` | `Fintype.exists_ne_map_eq_of_card_lt (fun m : Fin (n+1) => ρ (t + 1 + m))` with `Fintype.card_fin` | SUCCESS | — |
| `⊡φ ↔ ∀ runs, lab (ρ t) phi` under `Presented` | `rw [plusStab_iff_omega]`, both directions via `hP _ |>.mp/.mpr` and `rw [← hc]` on definitional `clTrace`/`runTrace` unfoldings | SUCCESS first attempt | `spliced` is an `abbrev`, so `plusStab_iff_omega`'s RHS matches syntactically |

## Context Extension Recommendations

- **Topic**: closedness of run-trace sets vs. non-closedness of closure-trace sets.
  **Gap**: `RaySummary/README.md` and the B2b successor text reason about closedness of the *path* set only; the discontinuity of the trace map in `untl`/`snce` letters is nowhere recorded.
  **Recommendation**: a short note in `.claude/context/project/lean4/patterns/` (agent-system source store) or the RaySummary README: "a per-state-labelled finite presentation can present only closed trace sets; `untl` letters make seam trace sets non-closed; `Presented` is therefore a soundness device, never a completeness one (`presented-not-complete.lean`)".
- **Topic**: `Nat`-recursive loop index for pumping bi-infinite runs.
  **Gap**: no in-tree pattern for pumping ℤ-indexed runs; `%` on variable moduli defeats `omega`.
  **Recommendation**: record `loopIdx`/`pump`/`pump_isRun` as the reusable pattern (lean4 patterns note).

## Appendix

### Search queries used

- `lean_local_search "Presented"` — hit `FormalSystem.Metalogic.Decidability.RaySummary.Presented` (`index: error`; evidence tier downgraded to grep + compile, as recorded).
- `lean_loogle "Fintype.exists_ne_map_eq_of_card_lt"` — one hit, `Mathlib.Data.Fintype.Pigeonhole`, signature as in the mapping table.
- grep (fixed-string, `FormalSystem/ specs/evidence/ Tests/`) for all 23 names in the Context table — every one resolved.
- Compile runs: `lake env lean probes/presented-not-complete.lean` (3 runs: 1 error → 1 error → EXIT 0), `lake env lean probes/stab-run-check.lean` (EXIT 0 first run).

### References to documentation

- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` ("What it does not do", lines 36-70; B2b verdict, lines 93-136)
- `specs/742_compute_hit_realizability_device/summaries/01_compute-hit-realizability-device-summary.md` (Overview; "Follow-up records")
- `specs/742_compute_hit_realizability_device/reports/01_compute-hit-realizability-device.md` (Findings 3-5)
- `specs/737_discharge_presents_mso_reduction_seam_summary/summaries/01_*.md` (field-by-field verdict)
- `specs/ROADMAP.md` lines 28, 95-100, 142-159, 195
- `docs/theorem-index.md` Decidability section, rows 194-197
- `FormalSystem/Metalogic/Decidability/Correctness.lean:192` (retired-as-vacuous section)
- `specs/evidence/seam-gluing-ray-product/quasistate-does-not-determine-hit.lean` (fixture reused)
