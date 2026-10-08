# Research Report: Task #742

**Task**: 742 - Compute Hit: the per-model realizability device (B1-B3) between the seam bridge and the decidable stab check
**Started**: 2026-10-08T08:29:01Z
**Completed**: 2026-10-08T09:05:19Z
**Effort**: 1 research dispatch (lean4, `--hard --lit`); one 119-line research probe compiled green during the dispatch (5 guarded single-file elaborations; the fifth: `GUARD_EXIT=0`, 0 errors, 0 sorries), one `lean_run_code` snippet for the closure alphabet
**Dependencies**: 737 (complete; `SeamMulti.lean` and the wired probe re-verified by direct read this dispatch), 711 (complete; substrate re-verified by name)
**Sources/Inputs**:
- Codebase, read this dispatch (bounded reads, every declaration re-resolved BY NAME): `FormalSystem/Metalogic/Decidability/RaySummary/SeamMulti.lean` (344 lines, in full — it is the bridge this task feeds), `RaySummary/Seam.lean` header and `SeamSummary`/`Presents`, `KTypeSummary/{Basic,Segment,Family,Saturation,Universal}.lean` declaration lists plus `InFamily`, `family_cover`, `SegmentFactorization`, `segZ`, `DeterminedByKType`, `determinedByKType_eval`, `family_saturation`, `finite_family_triples`, `target_eq_union_of_families`; `WeakCanonical/NEquivalence.lean` (`KType`, `kTypeOf`, `KEquiv`); `WeakCanonical/MixedSum.lean` (`kEquiv_orderedSum_of_kEquiv_colour`); `GroupModel/BlockDecomposition.lean` (`zFiber`); `ColourOrders.lean` (`colourSig`, `kTypeColouring`); `Expressiveness/MonadicFO.lean` (`MonadicSignature`, `MonadicFormula`, `OrderedMonadicStructure`, `eval`); `Expressiveness/NormalForm.lean` (`AtomKind`, `AtomEval`, `NormalForm`, `NfEvalNf`, `normalFormFintype`, `nf_exists_unique`, `doets_lemma_1_1`); `PlusLanguage/{Formula,PlusTruth,Subformulas,PlusRayFibre}.lean` (`PlusFormula`, `PlusTruthAt`, `subformulas`, `SeqPair`, `seamOmegaEquiv`, `plusStab_iff_omega`); `Conservativity/Plus/Atomization.lean` (`Encoding`, `atomize`, `plusTruthAt_iff_atomize`); `Semantics/TaskFrame.lean` (`FrameOver`, `IsRegular`, `Saturation`, `Limit`, `Serial`, `Compositional`, `ofReflectiveRegular`); `Semantics/SlicedFrame.lean` (`ofSlicedStep` and its `[Finite W]` sites); `PlusSlicedCertificate/Limits/NoFiniteWidth.lean` (`not_finite_width_fmp`, statement); `specs/evidence/seam-gluing-ray-product/presents-is-seam-decidedness.lean` (header and fixture declarations); `KTypeSummary/README.md` six-step table; `RaySummary/README.md`; `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` pin rows; `docs/theorem-index.md` row for `plusStab_iff_forall_hit`
- Predecessor records: `specs/737_.../reports/01_discharge-presents-verdict.md` (in full), `specs/711_.../reports/01_universal-summary-substrate.md` (D2-D5 design §, lemma table rows, cost table), `specs/711_.../summaries/02_...-summary.md` ("nothing from v1's `FwdPresentation`/`Profile` design was built"), `specs/ROADMAP.md` lines 80-125
- Lean tooling: `lean_local_search` (index `unavailable` on every call — positive hits admissible, absences not; no absence claim below rests on it), `lean_run_code` (closure alphabet check), five `lake-build-guard.sh build --no-share -- env lean` elaborations of the probe, `#print axioms` on the probe's two theorems
- Literature, read directly this dispatch: HWZ 2000 `chunk_0020.md` (Defs 6-7, Lemma 8), `chunk_0021.md` (Defs 10-11), `chunk_0022.md` (Def 12, Remark 13, Thm 14 ⇒), `chunk_0023.md` (Thm 14 ⇐), `chunk_0024.md` (σ_φ encoding, Thm 15), `chunk_0027.md` (Lemma 17 and proof); GKWZ 2003 `chunk_0497.md`-`chunk_0499.md` (Lemma 11.28 and the suitable-pair observation; OCR-degraded); Thomas 1997 `chunk_0004.md` (composition principle; UNVERIFIED summary — used only as corroboration of the landed in-tree mixing lemma, never as a source)
**Artifacts**:
- `specs/742_compute_hit_realizability_device/reports/01_compute-hit-realizability-device.md` (this report)
- `specs/742_compute_hit_realizability_device/probes/b3a-computable-ktype.lean` (research probe, compiled; logs `probes/b3a-compile-{1..5}.log`)
**Standards**: report-format.md, subagent-return.md, anti-analysis.md (H2), reference-grounding.md (H3, Tier 1), adversarial-verification.md (H4), context-hygiene.md

## Executive Summary

- **B3's structural risk is gone, machine-checked.** The predecessor rated B3 HIGH because "`kTypeOf` is `Classical.dec` by design". That is an implementation choice, not an obstruction: on a finite carrier with decidable order and decidable predicates, `NfEvalNf` is a finite conjunction of finite quantifications, so a `Decidable` instance follows by induction on the depth, and the resulting computable `kTypeOfFin` **equals** the library's `kTypeOf` pointwise (`decide` is instance-irrelevant). Compiled this dispatch: `Probe742.decNfEvalNf`, `kTypeOfFin`, `kTypeOfFin_eq`, `segZFinDec`, `kTypeOfFin_segZ`, axioms `[propext, Classical.choice, Quot.sound]`, zero sorries; `#eval` on a 3-point two-letter segment at depth 1 finds exactly one holding normal form (as `nf_exists_unique` predicts) and agrees with a 5-point segment, not with a 1-point one. One real hazard was found and is recorded: `inferInstanceAs` on `ℤ`-subtype order/equality resolves through `Int.instConditionallyCompleteLinearOrder`, which is noncomputable, so every instance must be an explicit term or the whole device silently becomes noncomputable. **B3 splits**: B3a (computable `k`-types of finite segments) is ~120 lines and LOW; B3b (effective composition) is MEDIUM, not HIGH, provided it is stated on *representatives* — see Finding 4.
- **"Compute `Hit M`" has no input datum for an arbitrary `M`, and the report says what the computable object is.** `Hit M τ t φ k` quantifies over `SeqPair F (τ.state t)` with `M.valuation : WorldState → Atom → Prop` on an arbitrary type; nothing finite is given. The computable object is `hitOf : SeamPresentation → Finset (KType × KType × KType)` over a finite per-time-alphabet presentation `P`, with two bridges: per model, `Hit M = image of SeqPair under the trace map` (B2a, provable, this record); per presentation, `Hit (modelOf P) = hitOf P` for the model *constructed from* `P` (B2b, HWZ Thm 14 ⇐ for this semantics, HIGH). Which of the two 735 consumes is settled: 735's search runs over presentations, its soundness needs B2b, its completeness is B4 (not this task). Presenting B1+B2a+B3 as "`Hit` computed" without B2b would be the true-looking-name defect the dispatch warns about; the plan must say which bridge it lands.
- **The fibre is a product, and that is the one-sided-live-flags repair in theorem form.** `seamOmegaEquiv : StabFibre F t s ≃ SeqPair F s` (landed) says the set of histories through a seam state is `BwdSeq × FwdSeq`. Consequences, all new to this record: (i) any history-set a per-state summary describes must be splice-closed at that state, so a summary must be a *product* of a backward-ray summary and a forward-ray summary — HWZ's bare set of types (Def 10) is the wrong alphabet, and 711's `fwdLive`/`bwdLive` flags are the right one; (ii) the Lemma 17 "created type" is exactly a mixed type `past(t₁)·future(t₂)` of two histories through one state, which the product automatically realizes, so a sound presentation lists it — the hazard is not avoided by a condition, it is *absorbed* by the alphabet; (iii) liveness cannot be enforced by a step graph on a finite slice (deferral paths are histories), so the constructed model of B2b needs an infinite slice with committed states, whose regularity — `Saturation` — the tree only proves for `[Finite W]` (`ofSlicedStep_saturation`); a new regular-frame constructor for "finitely many fibre shapes per time" is a named prerequisite of B2b (est. 300-500 lines).
- **B1 is as cheap as predicted, and the named Fintype plumbing is a non-issue.** `clSig φ := ⟨{ψ // ψ ∈ (subformulas φ).toFinset} ⊕ Unit⟩` with `Fintype`/`DecidableEq` by `inferInstanceAs` compiles (`lean_run_code`, card 4 for `p U q`). The local run conditions are `PlusTruthAt`'s `untl`/`snce` clauses verbatim, so soundness of the trace is `Iff.rfl` per clause; the `box` letter is per-time data and the `stab` letter per-state data (the atomization licence (e) of `Seam.lean`), both carried as anchors, not as run conditions. Estimate 300-500 lines, LOW, confirmed.
- **Re-verified component table** (engineering effort only, no complexity claim): B1 300-500 LOW; B2a 400-600 MEDIUM-LOW; B2b 1,200-2,000 HIGH plus the 300-500 Saturation prerequisite — recommend its own record; B3a ~120 LOW (probe exists); B3b 600-1,000 MEDIUM. The 737 figures were B1 300-500, B2 1,500-2,500, B3 800-1,500; the totals agree, the risk distribution does not: B3's risk moves to B2b.
- **Verdict shape recommended**: land B1, B2a, B3a, B3b in this record (`Hit M = hitOf (semanticPresentation M)` with `hitOf` computable on finite presentations), and file B2b as a successor lean4 record that 735 depends on, with the machine-checked obstruction for the HWZ-verbatim shape (per-time quasistates as bare type sets do not determine `Hit`; fixture designed in Finding 3) landed as a wired probe in this record. No `user_decision`. Everything stays under `[F.IsRegular]`, over the time axis, with a finite alphabet of per-time summaries; the only `[Finite W]` anywhere is in counterexample fixtures. The backward Bool-fixture limit is carried unchanged.

## Context & Scope

The dispatch asks for B1-B3 — alphabet and local run conditions, realizability, effective composition — with the predecessor's cost figures re-verified before phases are committed, and either `Hit` computed with every qualifier or a per-component verdict whose obstruction is machine-checked. B4 (validity quantification), `exists_presents_iff`, `plusStab_iff_forall_hit`, `PresentsMulti`, `determinedByKType_eval` are out of scope and untouched. `file_scope` is to be set at plan time.

What this report does: states exactly what "`Hit` computed" can mean (three readings, Finding 2); re-derives each component's shape against HWZ's definitions read directly; compiles the one claim that most changed a risk rating (B3a); fixes the closure alphabet; locates every hazard of B2 at a specific landed theorem (`seamOmegaEquiv`, `ofSlicedStep_saturation`, `not_finite_width_fmp`); designs the obstruction fixture for the HWZ-verbatim B2 shape; recommends phases and `file_scope`. What it does not do: it lands nothing in `FormalSystem/`, decides nothing, and builds no model.

Evidence tier announced per the readiness context: `lean_local_search` reported `index: unavailable` on all three calls (`kTypeOf`, `kEquiv_orderedSum_of_kEquiv_colour`, `plusStab_iff_forall_hit` — each a positive hit, admissible), so every absence claim below rests on a repository grep plus direct read, and every presence claim on a direct read and, where it matters, on compilation. No rate-limited search was needed: every Mathlib name used by the probe (`Fintype.decidableForallFintype`, `Fintype.decidableExistsFintype`, `instDecidableIff`, `instDecidableAnd`, `Fintype.subtype`, `decidable_of_iff`, `Int.decEq`, `Int.decLt`, `Int.instLinearOrder`, `Int.instLocallyFiniteOrder`, `Finset.mem_Ico`) was verified by the compiler.

Territory: `git status` at start showed only `specs/TODO.md`, `specs/events.jsonl`, `specs/state.json` modified; nothing outside the task directory was written.

## Findings

### Lemma-level mapping table (H3 Tier 1, 5-column)

| Source | Prop/Location | Lean Identifier | Type Signature | Status |
|---|---|---|---|---|
| HWZ 2000 | Def 6 (state candidate), p. 10, `chunk_0020.md` | B1 `clSig φ` (alphabet) and B2b `StateSummary` (types agreeing on `sub₀`: atoms, `⊡`-letters) | `clSig φ : MonadicSignature := ⟨{ψ : PlusFormula // ψ ∈ (PlusFormula.subformulas φ).toFinset} ⊕ Unit⟩`, `Fintype`/`DecidableEq` by `inferInstanceAs` | alphabet transcribed (compiled in `lean_run_code`, `Fintype.card = 4` for `p U q`); summary structure pending |
| HWZ 2000 | Def 7 (realizable state candidate) / Lemma 8 (realizability is FO-expressible), p. 10 | — (B2b's per-state realizability is the product condition of Finding 3, not an FO sentence) | — | pending (B2b) |
| HWZ 2000 | Def 10 (state function), p. 11, `chunk_0021.md` | B2b `SeamPresentation` | `ℤ → Finset StateSummary` with each summary a product `BwdSummary × FwdSummary` (Finding 3) | pending (B2b) |
| HWZ 2000 | Def 11 (run), p. 11, `chunk_0021.md`-`chunk_0022.md` | B1 `LocalRun` | `∀ ψ χ, (.untl ψ χ) ∈ cl → ∀ z, c ⟨.untl ψ χ⟩ z ↔ ∃ s, z < s ∧ c ⟨χ⟩ s ∧ ∀ r, z < r → r < s → c ⟨ψ⟩ r`, and the `snce` dual with `s < z`; plus `imp`/`bot` clauses | pending (statement fixed; matches `PlusTruthAt`'s clauses verbatim, so soundness is `Iff.rfl` per clause) |
| HWZ 2000 | Def 12 (quasimodel), second clause, p. 11, `chunk_0022.md` | B2b per-summary realizability | `∀ z, ∀ S ∈ P z, ∀ t ∈ S.types, ∃ r : Run P, r z = (S, t)` | pending (B2b) |
| HWZ 2000 | Thm 14 ⇒ (trace `t_a = {ψ ∈ sub_x φ : (M,w) ⊨_a ψ}`), p. 11, `chunk_0022.md` | B2a `clTrace`, `clTrace_localRun`, `clTrace_anchored` | `clTrace M φ t σ : (clSig φ).preds → ℤ → Prop := fun p z => match p with \| .inl ψ => PlusTruthAt M σ z ψ.1 \| .inr () => z = t`; `LocalRun (clTrace M φ t σ) ∧ Anchored M (clTrace M φ t σ) σ` | pending (LOW) |
| HWZ 2000 | Thm 14 ⇒, the characterization the per-model device needs (the paper's run `r(w) = t_{I(w)}(a)` is the *unique* run over the element's atoms) | B2a `eq_clTrace_of_localRun_anchored` | `LocalRun c → Anchored M c σ → c = clTrace M φ t σ` | pending (MEDIUM-LOW; structural induction on `ψ ∈ cl`, `untl`/`snce` cases by the run condition and IH) |
| HWZ 2000 | Thm 14 ⇐ (model from quasimodel, domain `{⟨r, ξ⟩ : r ∈ Ω_f, ξ < κ}`), pp. 11-12, `chunk_0023.md` | B2b `modelOf P`, `hit_modelOf` | `Hit (modelOf P) (seamHistory P) t φ k = hitOf P` under `[(frameOf P).IsRegular]` | pending (HIGH; Finding 3 names three sub-obstructions; recommend own record) |
| HWZ 2000 | Lemma 17 (splice at equal quasistates), pp. 14-15, `chunk_0027.md` | the splice-closure of the fibre: `seamOmegaEquiv` (landed, `PlusRayFibre.lean`) | `StabFibre F.toTaskFrame t s ≃ SeqPair F s`, `SeqPair F s := {bf : BwdSeq F × FwdSeq F // bf.1.1 0 = s ∧ bf.2.1 0 = s}` | transcribed (landed): the product IS the one-sided-live-flags repair |
| HWZ 2000 | Thm 15 (σ_φ and decidability on ⟨ℤ,<⟩), p. 13, `chunk_0024.md` | — (B4, task 735) | — | blocked (zero-debt citation; not this task) |
| GKWZ 2003 | Lemma 11.28 (every quasimodel contains a subquasimodel of bounded size), p. ~484, `chunk_0497.md`; the "suitable pair" observation, `chunk_0499.md` | — (B4's finite-presentation step) | — | blocked (frame only) |
| Thomas 1997 | composition principle ("the type of an ordinal word of length α+β is determined by the types of the α-prefix and the β-suffix"), `chunk_0004.md` [UNVERIFIED summary] | landed `kEquiv_orderedSum_of_kEquiv_colour` (Doets 1987 3.1.8, `MixedSum.lean`) → B3b `compose` on representatives | `KEquiv (colourSig (KType sig k)) k (kTypeColouring sig k m) (kTypeColouring sig k m') → KEquiv sig k (orderedSum sig I m) (orderedSum sig J m')` | transcribed (landed, classical); effective version pending (B3b) |
| Doets 1989 | Lemma 1.1 | `determinedByKType_eval` (landed, `Universal.lean`) | `ψ.quantifierDepth ≤ k → DeterminedByKType sig k (fun c => eval (zFiber sig c) Fin.elim0 ψ)` | transcribed (landed) |
| — (this formalization) | — | B3a `Probe742.decNfEvalNf`, `kTypeOfFin`, `kTypeOfFin_eq`, `segZFinDec`, `kTypeOfFin_segZ` | `kTypeOfFin M k = kTypeOf sig k M`; `kTypeOfFin (segZ sig c a b) k = kTypeOf sig k (segZ sig c a b)` | transcribed (research probe, `[propext, Classical.choice, Quot.sound]`, 0 sorries) |

### Finding 1 — Codebase: what is landed, re-verified by name

- `Hit M τ t φ k : Set (KType twoLetter k × KType twoLetter k × KType twoLetter k)` is `{tr | ∃ bf : SeqPair F (τ.state t), InFamily twoLetter k tr.1 tr.2.1 tr.2.2 (seamTrace M φ t (spliced τ t bf))}`; `hit_finite` from `finite_family_triples`; `plusStab_iff_forall_hit` needs `1 ≤ k`. `presentsMulti_seamTrace`'s `Bool` is `decide` under `open Classical` (`SeamMulti.lean`, in full).
- `kTypeOf sig k M := fun nf => @decide (NfEvalNf M k 0 Fin.elim0 nf) (Classical.dec _)` (`NEquivalence.lean`), `KType sig k := NormalForm sig k 0 → Bool`, `NormalForm` by recursion on `k` (`AtomKind sig n → Bool` at 0, a pair at `k+1`), `normalFormFintype`/`normalFormDecEq` built jointly by induction and **computable** (the probe's `Finset.univ.filter` over `NormalForm twoLetter 1 0` evaluates).
- `segZ sig c a b` has carrier `{t : ℤ // a ≤ t ∧ t < b}`, `carrierOrder := inferInstance`; `zFiber sig c` has carrier `ℤ`. `SegmentFactorization` requires only `Monotone W` plus `W 1 < W 2`, `W (-2) < W (-1)`; positive and negative segments all carry one type each.
- `InFamily` is "admits a `SegmentFactorization` with these three types" — no quotient, no `Set`. The verdict `stabTarget c` for `c` in a realized family is a coordinate of `τzero` alone for `k ≥ 1`: `now` is `k`-type-visible (`∃x now x`, depth 1) and occurs once, so a realizable triple has it in the middle segment, and `stabTarget` reads off `τzero`'s `nowPhi`-coordinate. **B3's "`compose : KType → KType → KType → KType` to the block type" is not needed for the verdict**; composition is needed only to *compute which triples are realized* (Finding 4).
- `seamOmegaEquiv t s : StabFibre F.toTaskFrame t s ≃ SeqPair F s` — the fibre is a product of the backward and forward ω-sequence spaces. `plusStab_iff_omega` restates `⊡` as a universal over the product.
- `PlusTruthAt`'s `untl`/`snce` clauses are strict (`t < s`, `s < t`) with the guard on the open interval — exactly HWZ Def 11's `(w, v)`; `box` is `∀ σ : WorldHistory F` at the same time (per-time datum); `stab` is `∀ σ, τ.state t = σ.state t → …` (per-state datum). `atomize` keeps `.box` as `.box` and atomizes `.stab` (`Atomization.lean`); `plusTruthAt_iff_atomize` is the licence to read `stab`-letters as state atoms.
- `IsRegular` has four fields; `Saturation` is "every ⊇-directed family of nonempty fibres and segments has nonempty intersection" (`TaskFrame.lean`). `FrameOver.ofReflectiveRegular` takes any `[Nonempty W]` and *proofs* of the four axioms; `FrameOver.ofSlicedStep` requires `[Finite W]` and uses it in `ofSlicedStep_fib_finite` and `ofSlicedStep_saturation` (`SlicedFrame.lean`). **There is no regular-frame constructor in the tree for an infinite slice.**
- `not_finite_width_fmp` refutes: "every non-valid `φ` has a countermodel on some `ofSlicedStep R` with `[Finite W]`" (`Limits/NoFiniteWidth.lean`). So a finite-width constructed model is not a complete source of countermodels; B2b's model must have an infinite slice.
- No decidable `eval`/`NfEvalNf` existed anywhere in `FormalSystem/` before this dispatch (repository grep for `Decidable (eval`, `Decidable (NfEvalNf`, `kTypeOfFin`, `decidableEval`: none; `lean_local_search` could not confirm absence — index `unavailable`).
- 711 summary 02 line 45: "nothing from v1's `FwdPresentation`/`Profile` design was built" — confirmed by direct read; 711's `file_scope` modules `RaySummary/{Profile,Forward,Backward,Periodic,Colour,Stab}.lean` are absent on disk (`ls`: only `Seam.lean`, `SeamMulti.lean`, `README.md`).

### Finding 2 — What "compute `Hit`" can mean (the input question)

`Hit M τ t φ k` is a set determined by `M : TaskModel F.toTaskFrame` for an arbitrary `F : FrameOver intOrder` with `[F.IsRegular]`; `M.valuation` is a `Prop`-valued function on an arbitrary `WorldState : Type`. There is no datum from which anything could be computed. Three readings, with their status:

| Reading | Statement | Status |
|---|---|---|
| (R1) per model, exact | `Hit M τ t φ k = {familyTriple (clTrace M φ t (spliced τ t bf)) : bf ∈ SeqPair F (τ.state t)}` where `clTrace` is the trace over the closure alphabet and `familyTriple` is read off a `SegmentFactorization` | a theorem (B2a + the projection from `clSig φ` to `twoLetter`), but **not a computation**: `SeqPair` is not finite |
| (R2) per finite presentation, computable | `hitOf : SeamPresentation → Finset (KType sig k × KType sig k × KType sig k)` computable, where `P` is a finite per-time-alphabet datum (ultimately periodic, finitely many state-summaries per time) | the computable object; B3a + B3b + the run/profile closure of 711's D2-D3 |
| (R3) the bridge between (R1) and (R2) | (⇒) `Presented M τ t P → Hit M τ t φ k = hitOf P` for the *semantic* presentation of `M`, which is infinite in general; (⇐) `Hit (modelOf P) (seamHistory P) t φ k = hitOf P` for the model constructed from a presentation satisfying the consistency conditions | (⇒) is B2a plus a definition; (⇐) is HWZ Thm 14 ⇐ for this semantics = **B2b**, HIGH |

What 735 consumes: its search ranges over finite `P`; soundness of a "not valid" answer needs (R3 ⇐) — a presentation satisfying the conditions must be realized by *some* regular model; completeness needs "every countermodel has a finite presentation up to the `Hit`-invariant" — HWZ Thm 15 / GKWZ Lemma 11.28, i.e. B4, 735's own frame. Therefore "B1-B3 landed" with only (R1)+(R2) delivers a computable `hitOf` and a per-model *semantic* bridge; it does **not** deliver (R3 ⇐). The dispatch's own definition of B2 — "HWZ Def 12 / Thm 14 for THIS semantics" — includes both directions, so B2b is in this task's scope by its description and is the component that should get an explicit verdict or its own record (Recommendation 2).

### Finding 3 — The fibre is a product; what that forces on B2 (the hazards, located)

**(a) The product.** `seamOmegaEquiv` is landed: histories through `(t, s)` are exactly pairs `(b, f)` of a backward and a forward ω-step-sequence out of `s`. So for *any* two histories `σ₁ = (b₁, f₁)`, `σ₂ = (b₂, f₂)` through `s`, the splices `(b₁, f₂)` and `(b₂, f₁)` are histories through `s` too. This is HWZ Lemma 17's splice, but in this semantics it is not an *operation on a quasimodel* that may or may not be sound — it is a *closure property of the fibre itself*. Consequence: the semantic type set at a state, `S_s := {type_t(σ) : σ ∈ StabFibre t s}`, is always closed under the mixing `(t₁, t₂) ↦ type_t(b₁, f₂)`. The "realised type the model lacked" of the dispatch is precisely such a mixed type when a presentation claims `S` but the realized set is `mix(S)`.

**(b) The repair is an alphabet, not a side condition.** A per-state summary must therefore be a product `BwdSummary × FwdSummary` (what 711 called `fwdLive`/`bwdLive` flags, now in theorem form), and the per-time finite alphabet is `Finset (BwdSummary × FwdSummary)`. With closure letters that look both ways (e.g. `F(Pq)` at `z` depends on the past before `z` through the future point), a type is *not* a pair of one-sided halves; so the summaries must be summaries of the two *atom-sequence* ray languages (`B_s`, `F_s`, over the atomized alphabet where `stab`-letters are state atoms and `box`-letters time atoms), and types are *derived* by the trace map, never primitive. B1's `Anchored` relation carries exactly these atoms (atoms at states, `box`-values at times, `stab`-values at states).

**(c) Liveness.** The set of histories through a state is the set of *all* step paths through it. On a finite slice this set is closed in the product topology, so any presentation whose runs defer an eventuality without bound is realized together with its limit path, whose semantic type is the limit type. HWZ avoids this because their domain elements are runs `⟨r, ξ⟩` that persist; here histories are paths and a path can switch between runs at every step. Consequence: B2b's constructed model needs an infinite slice with *committed* states (a root per summary whose successors are the per-run committed chains; the countdown gadget `s → a_n → a_{n-1} → … → a_0 → b` is the two-letter instance, whose forward language from `s` is "eventually `b`" without `a^ω`). That is consistent with `not_finite_width_fmp` and with the constraint "concede infinite fibres, seek a finite presentation": the presentation is finite per time, the slice is not.

**(d) Regularity on an infinite slice.** `Saturation` is proved in the tree only for `[Finite W]`. For the committed-state construction the fibres and segments at a fixed time take finitely many *shapes* (they are unions over summaries of "all committed chains"), so a ⊇-directed family is eventually constant and the intersection is nonempty; `Limit` is trivial (`|y| < 1` forces `y = 0`); `Serial` and `Compositional` are inherited from the step structure as in `ofSlicedStep`. This is a new constructor, `ofSlicedStepFinShape` or similar, est. 300-500 lines, and a prerequisite of B2b. It is not needed by B1, B2a, B3.

**(e) The obstruction for the HWZ-verbatim shape, as a fixture (design; plan-phase probe, ~400-500 lines).** Claim: per-time quasistates as bare sets of types with type-suitability (HWZ Defs 10-12 transcribed without the product repair) do not determine `Hit`. Fixture: three states `a`, `b`, `d`, `p` at `b` only; model A has steps `a→a, a→b, b→b, d→d, d→b`; model B has `a→a, b→b, d→d, d→b`. Over `cl = {p, Fp}` both realize at every time exactly the types `∅`, `{Fp}`, `{p, Fp}`, with the same consecutive-type relation `∅→∅, {Fp}→{Fp}, {Fp}→{p,Fp}, {p,Fp}→{p,Fp}`; but `⊡¬Fp` at the seam `(stayA, t)` is false in A (the jump) and true in B (`a`'s only neighbour is `a`). By `plusStab_iff_forall_hit` (both seams have the same `stabTarget` and `k`), `Hit_A ≠ Hit_B` as sets of triples over `twoLetter` — the inequality follows from the bridge without evaluating any `k`-type. Regularity via `ofSlicedStep_isRegular` on `W = Fin 3`, as the E2 probe does; `[Finite W]` is a counterexample's licence, not an assumption of the route. This is the machine-checked verdict to land if B2b is declared out of this record.

### Finding 4 — Effective composition is on representatives, not on `KType`

`KType sig k = NormalForm sig k 0 → Bool` contains overwhelmingly many functions that are the type of no structure (a `k`-type satisfies exactly one depth-`k` normal form, `nf_exists_unique`; a bare `Bool`-function need not). A `compose : KType → KType → KType` on bare values is therefore ill-posed off the realizable types, and no correctness statement is available for it there. The effective device that is well-posed:

- `kTypeOfFin` on finite decidable segments (B3a, compiled);
- composition **by representative**: a realizable type is carried with a finite segment realizing it; `compose (A, τ) (B, τ') := (A ++ B, kTypeOfFin (A ++ B))`, correct against `kEquiv_orderedSum_of_kEquiv_colour` with `I = Bool` (or any two-point order): the sum's `k`-type depends only on the summands' `k`-types, so the choice of representative is immaterial;
- the reachability closure over a finite presentation keeps one representative per (profile key, `k`-type) — finitely many keys since `KType sig k` is a `Fintype` with `DecidableEq` (`Fintype.decidablePiFintype` over `normalFormFintype`/`normalFormDecEq`), so the closure terminates by cardinality, not by a syntactic composition theorem. No Feferman-Vaught-style syntactic `NormalForm` composition is required, and none exists in the tree (the `sum_nf_*` lemmas of `NEquivalence.lean` are `private` and classical).

Cost: the two-point instance of the mixing lemma (~50 lines), the representative-carrying closure with its termination measure (~300-500), and the family-triple read-out from the closure, i.e. 711's D3 "idempotent homogeneous profile" argument restated on `k`-type-keyed profiles (~250-450). Total 600-1,000, MEDIUM. The D3 `⇐` splice construction is legitimate here because it splices *abstract runs of `P`*, not histories of a model — the hazard of Finding 3 lives in B2b, not in B3b.

**No complexity bound is claimed.** `decide` on `KType` equality is exponential in `|NormalForm sig k 0|`, which is itself a tower in `k`; the probe's depth-1 `#eval` is a sanity check and nothing more.

### Finding 5 — Re-verified cost and risk per component

| Component | Shape (this report) | 737's figure | Re-verified figure | Risk | Evidence |
|---|---|---|---|---|---|
| B1 | `clSig φ`, `clTrace`, `LocalRun`, `Anchored`, generic marker-`sig` restatement of `plusStab_iff_forall_hit` (same proof) | 300-500, LOW-MED | 300-500 | **LOW** | alphabet compiled (`lean_run_code`); run conditions are `PlusTruthAt`'s clauses |
| B2a | soundness `clTrace_localRun`/`clTrace_anchored`; characterization `eq_clTrace_of_localRun_anchored`; `Hit` as the image of `SeqPair` | (part of B2) | 400-600 | MEDIUM-LOW | structural induction on `ψ ∈ cl`; `untl`/`snce` by run condition + IH |
| B2b | `SeamPresentation` (product summaries), consistency conditions (`⊡`-coherence per summary, `box`-coherence per time, realizability), `modelOf P` on an infinite committed-state slice, truth lemma, `hit_modelOf` | (part of B2) | 1,200-2,000 | **HIGH** | Finding 3 (c),(d): liveness needs an infinite slice; regularity needs a new constructor |
| B2b-pre | `Saturation` for a sliced frame with finitely many fibre shapes per time; `ofSlicedStepFinShape` | — | 300-500 | MEDIUM | `ofSlicedStep_saturation` uses `[Finite W]` only through finiteness of fibres |
| B3a | `FinDec`, `decNfEvalNf`, `kTypeOfFin`, `kTypeOfFin_eq`, `segZFinDec`, `kTypeOfFin_segZ` | (part of B3, HIGH) | ~120 (compiled) | **LOW** | probe, standard axioms, 0 sorries |
| B3b | two-point mixing instance, representative closure, family read-out | (part of B3) | 600-1,000 | MEDIUM | Finding 4 |
| B2-verdict probe | A/B three-state fixture (Finding 3 (e)) | — | 400-500 | LOW | E2 probe's transcription pattern |

Totals: 737 said 2,600-4,500 for B1-B3; this report says 2,900-4,600 plus the 400-500 probe, with B3's risk moved into B2b. The dispatch's instruction to "consider whether B2 should be split before planning phases" is answered: split into B2a (this record) and B2b (successor record), with B2b-pre as B2b's first phase.

### Recommendations

1. **Land B1, B2a, B3a, B3b in this record**, in that order, as four modules under `FormalSystem/Metalogic/Decidability/RaySummary/`: `Closure.lean` (B1), `Trace.lean` (B2a), `KTypeFin.lean` (B3a; or under `WeakCanonical/KTypeSummary/` beside `Segment.lean`, since it is signature-generic), `Compose.lean` (B3b). State B1's bridge generically: `plusStab_iff_forall_hit_sig` over any `sig` with `now phi : sig.preds` and a trace `tr` satisfying `tr σ now z ↔ z = t` and `tr σ phi z ↔ PlusTruthAt M σ z φ` — the same proof as the two-letter one; the two-letter theorem stays as its instance.
2. **Do not present B1+B2a+B3 as "`Hit` computed".** The honest headline is: `hitOf` is computable on finite presentations; `Hit M` equals the image of the seam's ray pairs under a computable trace map; the per-presentation realization (R3 ⇐) is B2b. File B2b as a successor lean4 record ("Realize a seam presentation: HWZ Theorem 14 ⇐ for the ⊡ fibre") with B2b-pre as its phase 1 and 735 depending on it; land the Finding 3 (e) fixture in this record as the machine-checked verdict for the HWZ-verbatim shape (`specs/evidence/seam-gluing-ray-product/quasistate-does-not-determine-hit.lean`, wired into `scripts/check-evidence-probes.sh`).
3. **B3b on representatives, never on bare `KType`.** Write the closure over `Finset (Key × Rep)` keyed by `(fromType, toType, dischargeSet, kTypeOfFin rep)`; termination by `Fintype.card` of the key type. Record in the docstring that `compose` is defined only on realizable inputs and why.
4. **Every decidability instance for `ℤ`-segments is an explicit term** (`Int.decEq`, `Int.decLt`, `Int.instLinearOrder`, `Int.instLocallyFiniteOrder`); add one sentence to `context/project/lean4/patterns/` (Context Extension Recommendations).
5. **`file_scope` at plan time** (proposed): `FormalSystem/Metalogic/Decidability/RaySummary/{Closure,Trace,Compose}.lean`, `FormalSystem/Metalogic/WeakCanonical/KTypeSummary/KTypeFin.lean` (or `RaySummary/KTypeFin.lean`), `RaySummary.lean` and `RaySummary/README.md`, `KTypeSummary/README.md`, `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` (pins: `kTypeOfFin_eq`, `eq_clTrace_of_localRun_anchored`, `plusStab_iff_forall_hit_sig`, `hitOf_spec`), `docs/theorem-index.md`, `specs/evidence/seam-gluing-ray-product/quasistate-does-not-determine-hit.lean`, `scripts/check-evidence-probes.sh`, `specs/ROADMAP.md`. Overlap with 733/734/739 on the gate script stands; dispatch singly against them.
6. **Carry the inherited limits unchanged.** The trace characterization and the presentation are direction-symmetric at the abstract-run level, but no backward Bool-fixture bridge is built; `pastStab_iff_allBwdPathsMeet` remains the only backward fixture result, and the Finding 3 (e) fixture is forward (`¬Fp`). Say so in every module header.
7. **Zero debt, as transferred**: no HWZ/GKWZ lemma is cited in place of a proof anywhere above; Thm 15 and Lemma 11.28 appear only as `blocked` rows naming 735's frame.

## Decisions

- **D-1 B3's HIGH rating was wrong, and the report says so with a compiled probe rather than prose.** `kTypeOf`'s `Classical.dec` is an implementation choice; `kTypeOfFin_eq` makes the computable version the same function.
- **D-2 Split B2 into B2a and B2b; recommend B2b as a successor record.** The dispatch invited exactly this call; the reason is structural (Finding 3 (c),(d)), not an effort estimate.
- **D-3 Compose on representatives.** A `compose` on bare `KType` has no correctness statement off realizable values; representatives make correctness the mixing lemma's two-point instance.
- **D-4 Fixture obstruction over prose.** The HWZ-verbatim shape's failure is stated as a `Hit_A ≠ Hit_B` theorem derived through the landed bridge, so it is cheap and does not evaluate `k`-types.
- **D-5 No `user_decision`.** Module layout, record split, and representative encoding are routine engineering calls the plan can make; the finding that 735's soundness depends on B2b is a dependency to record, not a user choice.
- **D-6 Probe stays in the task directory.** Writing into `specs/evidence/` and the gate script is implementation work with declared contention; research hands the compiled text to the plan.

## Adversarial Self-Verification

### Claim Verification Table

| Claim | Source/Counterexample | Verification Method | Confidence |
|---|---|---|---|
| `NfEvalNf` is decidable on a finite carrier with decidable order/predicates, by induction on `k` | `Probe742.decNfEvalNf` compiles; depends only on `Fintype.decidableForallFintype`, `Fintype.decidableExistsFintype`, `instDecidableIff`, `instDecidableAnd`, `atomKindFintype`, `normalFormFintype` | guarded `lake env lean`, compile logs 2-5 (no error at that declaration from log 2 on) | High |
| `kTypeOfFin M k = kTypeOf sig k M` | `Probe742.kTypeOfFin_eq`, proof `decide_eq_decide.mpr Iff.rfl` | `#print axioms`: `[propext, Classical.choice, Quot.sound]` (logs 2-5) | High |
| `segZ` segments of a decidable colouring are finite and decidable, computably | `Probe742.segZFinDec`; the `inferInstanceAs` path is noncomputable through `Int.instConditionallyCompleteLinearOrder` (logs 1, 4), the explicit path compiles and `#eval`s (`lean_run_code` `f1`, `3`) | compile logs 1, 4; `lean_run_code` | High |
| `normalFormFintype` is computable | `Finset.univ.filter … |>.card` over `NormalForm twoLetter 1 0` evaluates to `1` | `#eval` in compile log 5: `1` | High |
| The closure alphabet `{ψ // ψ ∈ (subformulas φ).toFinset} ⊕ Unit` has `Fintype`/`DecidableEq` by `inferInstanceAs` | `lean_run_code`: `Fintype.card = 4` for `p U q` | `lean_run_code` | High |
| `plusTruthAt_iff_atomize` keeps `.box` and atomizes `.stab` | `atomize` equations at `Atomization.lean` (`.box φ => .box (atomize e φ)`, lines 92-98) and the theorem statement at line 160 | direct read | High |
| The fibre through a seam state is a product `BwdSeq × FwdSeq` | `seamOmegaEquiv`, `SeqPair` definitions, `PlusRayFibre.lean` | direct read (lines 150-180, 262-300) | High |
| `Saturation` is proved only under `[Finite W]` for sliced frames; no infinite-slice regular constructor exists | `ofSlicedStep_fib_finite`, `ofSlicedStep_saturation` signatures (`SlicedFrame.lean:255,263`); `ofReflectiveRegular` takes the four axioms as arguments | direct read + repository grep for `Finite W` in `SlicedFrame.lean` | High for the first part; Medium for the absence (grep sweep, `lean_local_search` index `unavailable`) |
| HWZ Thm 14 ⇐ builds the model with domain `{⟨r, ξ⟩ : r ∈ Ω_f, ξ < κ}` and a truth lemma by induction | `chunk_0023.md` lines 1-45 | direct read | High |
| HWZ Lemma 17: splice at equal quasistates is a quasimodel; the proof checks the `U` run condition across the cut | `chunk_0027.md` lines 31-55 | direct read | High |
| HWZ Def 11 run conditions are the strict `U`/`S` clauses on the open interval, matching `PlusTruthAt` | `chunk_0022.md` lines 1-7 vs `PlusTruth.lean:84-94` | direct read of both | High |
| 737's D2-D5 figures (1,900-2,700 lines) and "nothing built" | 711 report cost table; 711 summary 02 line 45 | direct read | High (as carried figures; they remain estimates) |
| `not_finite_width_fmp` refutes finite-width countermodel sufficiency | statement at `Limits/NoFiniteWidth.lean:1280` | direct read | High |
| No decidable `eval`/`NfEvalNf` existed in-tree before this dispatch | repository grep (4 patterns) | grep sweep; `lean_local_search` could not confirm absence (`unavailable`) | Medium |
| B2b's liveness obstruction: a finite-slice step graph realizes limit paths | argument of Finding 3 (c) from `StabFibre` = all step paths; countdown gadget as the positive example | reasoning over definitions read this dispatch; no compiled fixture | Medium — flagged: this is the claim a B2b design probe must test first |
| B2b's regularity via "finitely many fibre shapes per time" | argument of Finding 3 (d) | reasoning; not compiled | Low-Medium — flagged UNVERIFIED; the resolving check is the `ofSlicedStepFinShape` constructor itself |
| The A/B fixture of Finding 3 (e) has equal per-time quasistates and suitability | hand enumeration of histories of two three-state frames | not compiled | Medium — flagged; the probe is the check |

Note on the logs: logs 2-4 already establish every theorem on the standard axiom profile; log 5 is the fully computable version (`segZFinDec` explicit) and reports `GUARD_EXIT=0`, 0 errors, outputs `1`, `true`, `false`, and `[propext, Classical.choice, Quot.sound]` for both theorems. `grep -c sorry` over the probe: 0.

### Contradiction Log

- **737 report: "B3 … HIGH — `kTypeOf` is `Classical.dec` by design"** vs. **this dispatch: `kTypeOfFin_eq` compiled.** Precedence: directly-read and compiled Lean source over a predecessor's estimate. Resolved in favour of the compiled probe; the 737 claim is correct as a description of the landed definition and wrong as an obstruction.
- **Dispatch text: "B2 … per-time state realizability (the quasistate)"** vs. **Finding 3: the quasistate must be a product of ray summaries, and per-model exactness fails for bare type sets.** Precedence: landed theorem (`seamOmegaEquiv`) over the inherited description. Resolved: the dispatch's own next clause ("with one-sided live flags") is the product; the report keeps the dispatch's name and corrects the shape.
- No UNRESOLVED CONTRADICTION remains.

### Recommendations modified after verification

- The first draft recommended a syntactic composition theorem on `NormalForm` for B3b; replaced by composition on representatives after re-reading `KType`'s definition (bare `Bool`-functions) and `nf_exists_unique`.
- The first draft listed `segZFinDec` with `inferInstanceAs`; compile logs 1 and 4 showed the noncomputable instance path, and the recommendation became "explicit terms everywhere" (Recommendation 4).

## Literature Proof Structure

**Source**: HWZ 2000 §3 (Defs 6-12, Remark 13, Thm 14, Lemma 17; chunks 0020-0023, 0027 read directly), §4 (σ_φ, Thm 15; chunk 0024) for the boundary with B4; GKWZ 2003 Lemma 11.28 (chunk 0497) as the second source for the finite-presentation step; Thomas 1997 composition principle (chunk 0004, UNVERIFIED summary) as corroboration of the landed mixing lemma; Doets 1989 Lemma 1.1 (landed as `determinedByKType_eval`).

**Strategy** (HWZ): a model yields a state function with runs = traces (Thm 14 ⇒); a quasimodel yields a model with domain `{⟨r, ξ⟩}` and a truth lemma (Thm 14 ⇐); quasimodel existence is an MSO sentence decided by Büchi (Thm 15). **In this semantics** the domain elements are histories, which are *step paths* rather than persistent elements, so Thm 14 ⇐ must build a frame whose fibres are the prescribed products and whose paths cannot defer eventualities — the two things HWZ's construction never has to do.

### Step Map

1. Alphabet = subformula closure + marker (Def 6, `sub_x φ`) → B1 `clSig φ`.
2. Trace of a history = the set of closure formulas true at each time (Thm 14 ⇒, `t_a`) → B1 `clTrace`.
3. Run conditions = strict `U`/`S` clauses (Def 11) → B1 `LocalRun`; atoms/`box`/`stab` anchors → B1 `Anchored` (the atomization licence).
4. A trace is a run anchored to its path, and an anchored run is the trace (Thm 14 ⇒, the uniqueness of `r(w) = t_{I(w)}(a)`) → B2a.
5. `Hit` = family triples of traces of ray pairs → B2a (definition + `seamOmegaEquiv`).
6. Effective `k`-types of finite segments → B3a (compiled); composition by representatives against Doets 3.1.8 → B3b.
7. Realized triples of a finite presentation = reachability closure with idempotent read-out (711's D3; Thomas's composition principle) → B3b.
8. Model from a presentation with product fibres and no deferral (Thm 14 ⇐, re-engineered) → B2b, with the regular-frame constructor as its prerequisite.
9. Decide quasimodel existence (Thm 15; GKWZ 11.28) → B4, **not this task**.

### Dependencies

Steps 1-3 are independent of everything landed except `PlusTruthAt`; 4 depends on 1-3; 5 on 4 and `seamOmegaEquiv`; 6 on nothing (signature-generic); 7 on 6 and `kEquiv_orderedSum_of_kEquiv_colour`; 8 on 1-3, 7, and a new frame constructor; 9 on all of them and is absent.

### Potential Formalization Challenges

- Step 4's `box` case: `∀ σ : WorldHistory F` at time `z` is independent of the history, so the anchor is a per-time datum; the induction must thread it as such (no run condition).
- Step 7's termination: the key type must be a `Fintype` with `DecidableEq`; `KType sig k` is, via `Fintype.decidablePiFintype`; the measure is `Fintype.card` of the unreached keys.
- Step 8 (B2b): fibres must be products (Finding 3 (a)-(b)); paths must not defer (3 (c)); `Saturation` on an infinite slice (3 (d)); the truth lemma for `stab` must quantify over exactly the committed chains. Each is a named phase of the successor record.

## Tactic Survey Results

| Goal | Tactic / method | Result | Premises/Config |
|---|---|---|---|
| `Decidable (NfEvalNf M 0 n env nf)` | explicit `@Fintype.decidableForallFintype … (fun a => @instDecidableIff _ _ (decAtomEval M env a) (instDecidableEqBool _ _)) (atomKindFintype sig n)` | success | `inferInstanceAs` on the same statement failed to synthesize (log 1) |
| `Decidable (NfEvalNf M (k+1) n env ⟨atomA, quantA⟩)` | `let`-bound `dAtoms`, `dEx` (via `Fintype.decidableExistsFintype` and the recursive call), `dQuant`; `@instDecidableAnd _ _ dAtoms dQuant` | success | structural recursion on `k`; `Prod` eta makes the pattern reduce |
| `kTypeOfFin M k = kTypeOf sig k M` | `funext nf; unfold kTypeOfFin kTypeOf; exact decide_eq_decide.mpr Iff.rfl` | success, pcq | — |
| `FinDec (segZ sig c a b)` computably | `Fintype.subtype (@Finset.Ico ℤ Int.instLinearOrder.toPartialOrder.toPreorder Int.instLocallyFiniteOrder a b) (fun _ => Finset.mem_Ico)`; `@decidable_of_iff (x = y) (x.1 = y.1) ⟨Subtype.ext, congrArg Subtype.val⟩ (Int.decEq _ _)`; `@decidable_of_iff (x < y) (x.1 < y.1) Iff.rfl (Int.decLt _ _)` | success (log 5, `GUARD_EXIT=0`; the `f1` variant also `#eval`s in `lean_run_code`) | `inferInstanceAs` and plain `Finset.Ico` both route through `Int.instConditionallyCompleteLinearOrder` (noncomputable) — logs 1, 4; `decidable_of_iff`'s first explicit argument is the *target* proposition — log 3 |
| `Fintype (clSig φ).preds`, `DecidableEq` | `inferInstanceAs` on the `Subtype`/`Sum` | success; `Fintype.card = 4` | `PlusFormula.subformulas` must be namespaced |
| `#eval` count of holding depth-1 normal forms on `[0,3)` | `Finset.univ.filter` | `1` (log 5) | `normalFormFintype` computable |
| `#eval decide (kTypeOfFin [0,3) 1 = kTypeOfFin [0,5) 1)`, `… [0,1) …` | `Fintype.decidablePiFintype` | `true`, `false` (log 5) | — |
| docstrings before `#eval` | — | parse error (log 1); use `--` comments | — |

No `simp`/`omega`/`aesop` bypassed a step the literature handles explicitly; the probe is definitional.

## Context Extension Recommendations

- **Topic**: computable instances on `ℤ`-subtypes. **Gap**: no note warns that `inferInstanceAs` for `DecidableEq`/`DecidableRel`/`Preorder` on `ℤ` (and its subtypes) can resolve through `Int.instConditionallyCompleteLinearOrder`, which is noncomputable, making a `def` silently uncompilable. **Recommendation**: a short entry in `context/project/lean4/patterns/` ("explicit decidability terms for integer segments": `Int.decEq`, `Int.decLt`, `Int.instLinearOrder`, `Int.instLocallyFiniteOrder`, `decidable_of_iff` argument order).
- **Topic**: `decidable_of_iff` argument order. **Gap**: the first explicit argument is the *target* proposition `b`-first in the `@` form; the mistake cost one compile. **Recommendation**: one line in the same pattern note.
- **Topic**: the `⊡` fibre is a product. **Gap**: `ztime-no-finite-carrier-fmp.md` §8 and the RaySummary README state the one-sided-liveness repair as a design requirement; neither says it is a consequence of `seamOmegaEquiv`. **Recommendation**: fold Finding 3 (a)-(b) into the README's point (d) when B2a lands.

## Appendix

### Search queries used

- `lean_local_search`: `kTypeOf` (7 hits incl. the probe's), `kEquiv_orderedSum_of_kEquiv_colour` (1), `plusStab_iff_forall_hit` (2) — all `index: unavailable`.
- Repository greps (declaration resolution by name): `kEquiv_orderedSum_of_kEquiv_colour|sum_preservation|plusStab_iff_omega|doets_lemma_1_1|nf_exists_unique|plusTruthAt_iff_atomize`; `SeqPair|seamOmegaEquiv|zFiber|NfEvalNf|eval|OrderedMonadicStructure|segSum|kTypeColouring`; `MonadicSignature|FrameOver|IsRegular|StabFibre|atomize|closure|subformulas`; `Decidable (eval|Decidable (NfEvalNf|decidableEval|kTypeOfFin`; `live_iff|stab_factors|FwdLive|BwdLive`; `not_finite_width_fmp`; `Saturation|Limit|Serial|Compositional`; `Finite W` in `SlicedFrame.lean`; `ofReflectiveRegular`; `def PlusTruthAt`; `structure Encoding|def atomize`; `guard_msgs`/`plusStab_iff_forall_hit` in the axiom test and theorem index; `compute hit|B1|B2|B3|residue` in `ROADMAP.md`; `D2|D3|D4|D5|Lemma 17|one-sided|FwdPresentation|Profile|Estimated cost` in 711's report.
- Literature: `grep` over `hodkinson_wolter_zakharyaschev_2000_decidable_fragments_fotl/` for `Definition 1[0-2]|Lemma 17|Theorem 1[45]|Definition [67]`; over `gabbay_kurucz_wolter_zakharyaschev_2003_…` for `Lemma 11.27`, `11.28` (fixed-string; the regex form exceeded ugrep's complexity limit); over `thomas_1997/` for `composition|Feferman|Shelah`.
- Build: `lake-build-guard.sh build --no-share --timeout 900 -- env lean specs/742_…/probes/b3a-computable-ktype.lean` × 5 (log 1: instance synthesis at depth 0, noncomputable `ℤ` instances, docstring parse; log 2: `decidable_of_iff` order; log 3: `deq` order; log 4: `Finset.Ico`'s `Preorder` path; log 5: final).
- `lean_run_code` × 3 (closure alphabet ×2; `Finset.Ico` instance variants).

### References to documentation

- `FormalSystem/Metalogic/Decidability/RaySummary/SeamMulti.lean` header points (a)-(d).
- `FormalSystem/Metalogic/Decidability/RaySummary/Seam.lean` header points (c)-(f) (the alphabet licence and the joint-realization paragraph).
- `FormalSystem/Metalogic/WeakCanonical/KTypeSummary/README.md` six-step table (step 6 "out of scope — the consumer's work").
- `specs/737_…/reports/01_discharge-presents-verdict.md` Findings: "Coverage" table and residue table (B0-B4).
- `specs/711_…/reports/01_universal-summary-substrate.md` "The substrate, stated" (D2-D5) and "Estimated cost".
- `.claude/context/formats/report-format.md` (carried-figure discipline).
- Issue log this dispatch: one `win` (B3a de-risked by a compiled probe), one `issue` (noncomputable `ℤ` instance path, minor).
