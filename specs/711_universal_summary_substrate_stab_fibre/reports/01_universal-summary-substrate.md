# Research Report: Task #711

**Task**: 711 - Universal-summary substrate for the `⊡` fibre check on the seam-gluing route
**Started**: 2026-10-05T19:45:00Z
**Completed**: 2026-10-05T20:40:00Z
**Effort**: 1 research dispatch (hard mode, `--lit`)
**Dependencies**: 732 (satisfied; E3 reported)
**Sources/Inputs**: Codebase (`FormalSystem/PlusLanguage/PlusRayFibre.lean`,
`FormalSystem/Metalogic/WeakCanonical/GroupModel/RamseyFactorization.lean`,
`FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/{Basic,Splice,Live,LiveFix,Stable,Tail,HalfRun,Limits/NoFiniteWidth}.lean`,
`specs/evidence/seam-gluing-ray-product/*.lean`, `scripts/check-evidence-probes.sh`,
`scripts/check-module-invariants.sh`, `FormalSystem/ForMathlib/README.md`); Mathlib source at pin
`v4.33.0-rc1` (grep sweep of `.lake/packages/mathlib/Mathlib`); lean-lsp MCP (`lean_hover_info`,
`lean_run_code` with `#print axioms`, `lean_local_search` — index `unavailable` throughout, see
Appendix); literature corpus read directly (HWZ 2000 chunks 0007, 0021–0025, 0027; GKWZ 2003
chunks 0058, 0490, 0589; Thomas 1997 chunks 0059, 0060, 0074); programme records
(`specs/archive/721_.../followup-scope-spec.md` Section B, "The 711 tension", "Ranking
ratification"; `specs/ROADMAP.md` Phase 1; task records 709, 713, 732, 733, 734, 735;
`.claude/context/project/logic/domain/ztime-no-finite-carrier-fmp.md` §8)
**Artifacts**: `specs/711_universal_summary_substrate_stab_fibre/reports/01_universal-summary-substrate.md`
**Standards**: report-format.md, subagent-return.md, anti-analysis.md (lean4), reference-grounding.md (lean4), adversarial-verification.md (lean4)

## Executive Summary

- **The device is the one E3 selected, and research has now pinned what it *is* mathematically.**
  Candidate (d), the time-axis Ramsey-coloured summary, is **Büchi's own 1962 proof of the
  complementation step inside route (c)**. Thomas 1997 (p. 30, read directly this dispatch) states
  that Büchi's original complementation argument represents recognizable sets as finite unions
  `U_i · V_i^ω` over classes of a finite-index congruence on *segments* and "applies a combinatorial
  argument (e.g., a form of Ramsey's Theorem)"; the alternative proof is determinization
  (McNaughton/Safra — candidate (a)). So the four candidates are not four routes: (c) is the frame,
  and (a), (b), (d) are three proofs of its single hard step. E3's Low-confidence framing is thereby
  resolved to Medium–High (see Adversarial Self-Verification, row 9).
- **Substrate step 1 is proved, sorry-free, on standard axioms, during this dispatch.** From the
  in-tree `FormalSystem.Metalogic.WeakCanonical.infinite_ramsey_pairs` and a composition-law
  hypothesis, a strictly increasing time sequence on which the colour is a single **idempotent**
  colour exists (`exists_idempotent_homogeneous`, forward; `exists_idempotent_homogeneous_bwd`,
  backward mirror by `n ↦ t - n`); both `#print axioms` = `[propext, Classical.choice, Quot.sound]`
  (Tactic Survey Results). Idempotence is exactly what task 709's record calls the second repair
  forced by `⊡` ("fulfilment within a period must be secured for EVERY live position at once").
- **What the substrate must contain, in order, with Lean-ready shapes** (Findings → Recommendations):
  D1 idempotent homogeneous colour (done); D2 the *segment profile* colouring of a per-time-alphabet
  presentation with its composition law; D3/D4 the device theorem on one ray — a fulfilling run
  exists iff an idempotent profile with an accepting self-loop is reachable — both directions;
  D5 the `⊡` bridge: `plusStab_iff_omega` + stratification + `live_iff`-style factorization at a
  seam *type*, stated against an abstract presentation hypothesis. D5's quasistate must carry
  **one-sided live sets**, task 709's first repair, verified here against HWZ Def 12 (p. 11): HWZ
  runs are abstract and their quasistate is a bare set of types, which is why Lemma 17's splice
  (p. 14) can create a realised type and falsify a `⊡`-label.
- **What cannot be a device in Lean**: route (c)'s discharge theorems — HWZ Thm 15 (p. 13, flow
  `⟨ℤ,<⟩` listed, proof "by a result of Büchi"), GKWZ Thm 1.28 (p. 39) and Thm 13.6 (p. 568) —
  have no Lean formalization and, under zero-debt, are `blocked` rows in the mapping table. Mathlib
  at the pin has no infinite Ramsey for pairs, no Büchi/parity/Rabin/ω-word infrastructure
  (`Computability/` is finite-word only), re-verified by grep sweep (lean-lsp index was
  `unavailable`; the sweep is the evidence tier of record).
- **The first behavioural discrimination between (c) and (d) is executability, not truth-value.**
  Being two proofs of one theorem, (c) and (d) agree on every fixture; what the ROADMAP's "first
  behavioural discrimination" can honestly mean is: on a finitely presented infinite fibre with a
  per-time alphabet (the E1 `pre/x/post` graph is the ready-made one: infinitely many states per
  time, three types), (d) computes a verdict from profiles while (c) yields an MSO `Prop` over `ℤ`
  (GKWZ's `qm_φ`, Lemma 11.23) that can only be discharged by hand. The plan should state the
  probe that way and not promise a truth-value split.
- **Operator flag answered**: a `proposed_file_scope` is in `.return-meta.json`; it names the new
  `FormalSystem/Metalogic/Decidability/RaySummary/` cluster, two evidence probes, and the
  `scripts/check-evidence-probes.sh` wiring that tasks 733/734 also declare (contention; run singly,
  as the ROADMAP already says).
- **No complexity bound is claimed**, by this report or any target it names. Route (c) is published
  as non-elementary (GKWZ p. 40); that is a statement about the MSO reduction, not a bound on
  anything here, and the task-713 2EXPTIME ceiling remains a ceiling only.

## Context & Scope

Three E3 results are carried together, as the dispatch requires: (1) `⊡(Fp)`/`⊡(Pp)` are
device-inert on finite fixtures (`Probe732Device.allPathsMeet_iff_lasso`, `allBwdPathsMeet_iff_lasso`,
`detRun_accepts_iff`, `stab_will_iff_lasso`); (2) pigeonhole-tier lasso summaries are refuted on
`⟨ℤ, b = a − 1⟩` (`not_lasso_sufficient_on_chain`), the regime forced by
`FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.NoFiniteWidth.not_finite_width_fmp`
(`NoFiniteWidth.lean:1280`, signature `lean_hover_info`-confirmed), so the substrate must work over
the time axis with a finite alphabet of per-time summaries; (3) the selection is (d) framed by (c),
on infrastructure and literature evidence. Both honest limits are carried: the `⊡(Pp)` side stays
at step-graph level (this report builds no backward Bool-fixture bridge; D4 is where one would be
lifted) and the (c)/(d) shared-core claim was Low — its named resolving check is performed below.

Reference-grounding tier: **Tier 1** (HWZ 2000, GKWZ 2003, Thomas 1997, Doets 1987 via
`RamseyFactorization.lean`), with Tier 3 inputs (the landed keystone, liveness and tail-collapse
modules, and the probe collection). Divergence audit (H5) is **not** activated: the focus prompt
contains neither "divergence" nor "audit".

Constraints honoured: no sorry deferral, no new axioms, no complexity bound, no claim that the probed
shapes discriminate, the substrate is built here and consumed by 735 (not absorbed), and the
consumer is 735, not 712.

## Findings

### Lemma-level mapping table (H3 Tier 1, 5-column)

Page numbers: HWZ 2000 uses the preprint pagination visible in the corpus chunks (journal APAL 106,
pp. 85–134); GKWZ 2003 printed pages are read from the running headers in the chunks; Thomas 1997
pages are the Handbook-chapter preprint's. Status vocabulary per the contract: `transcribed`,
`pending`, `blocked` (no Lean route under zero-debt; frame only). No row is `sorry`.

| Source | Prop/Location | Lean Identifier | Type Signature | Status |
|--------|---------------|-----------------|----------------|--------|
| Doets 1987 ch. 7 (via `RamseyFactorization.lean` header) | infinite Ramsey for pairs, pp. 89–93 | `FormalSystem.Metalogic.WeakCanonical.infinite_ramsey_pairs` | `{C : Type} [Finite C] (c : ℕ → ℕ → C) : ∃ g, StrictMono g ∧ ∃ τ, ∀ i j, i < j → c (g i) (g j) = τ` | transcribed (`lean_hover_info`; axioms `[propext, Classical.choice, Quot.sound]` by `#print axioms`) |
| Thomas 1997 | §5.1, p. 30: Büchi's complementation via finite-index segment congruence + Ramsey | `RaySummary.exists_idempotent_homogeneous` (D1, proved this dispatch in `lean_run_code`; not yet in tree) | `{C : Type} [Finite C] (comp : C → C → C) (c : ℕ → ℕ → C) (hc : ∀ i j k, i < j → j < k → c i k = comp (c i j) (c j k)) : ∃ g : ℕ → ℕ, StrictMono g ∧ ∃ τ : C, comp τ τ = τ ∧ ∀ i j, i < j → c (g i) (g j) = τ` | transcribed (compiled; pending landing) |
| Thomas 1997 | §5.1, p. 30 (backward mirror, this report's addition) | `RaySummary.exists_idempotent_homogeneous_bwd` | `{C : Type} [Finite C] (comp : C → C → C) (c : ℤ → ℤ → C) (t : ℤ) (hc : ∀ a b d : ℤ, a < b → b < d → c a d = comp (c a b) (c b d)) : ∃ g : ℕ → ℕ, StrictMono g ∧ ∃ τ : C, comp τ τ = τ ∧ ∀ i j, i < j → c (t - g j) (t - g i) = τ` | transcribed (compiled; pending landing) |
| Thomas 1997 | Theorem 5.9 (Büchi's Theorem), p. 37: Büchi-recognizable ⟺ MSO-definable | — | — | blocked (no Lean formalization; cited as frame only) |
| HWZ 2000 | Definition 10 (state function), p. 11 | `RaySummary.FwdPresentation` (D2) | `structure FwdPresentation (Ty Ev : Type) [Fintype Ty] [DecidableEq Ty] [Fintype Ev] [DecidableEq Ev] where real : ℕ → Finset Ty; suit : ℕ → Ty → Ty → Bool; pending discharged : Ty → Finset Ev` | pending |
| HWZ 2000 | Definition 11 (run), p. 11 | `RaySummary.FwdPresentation.IsRun`, `.Fulfilling` | `IsRun r := (∀ n, r n ∈ P.real n) ∧ ∀ n, P.suit n (r n) (r (n+1)) = true`; `Fulfilling r := ∀ n, ∀ e ∈ P.pending (r n), ∃ m, n < m ∧ e ∈ P.discharged (r m)` | pending |
| HWZ 2000 | Definition 12 (quasimodel), p. 11; Remark 13 (`⟨f, Ω_f⟩` suffices) | finite-width instance exists: `FormalSystem.Metalogic.Decidability.PlusSlicedCertificate` (`Basic.lean`) with `Live`/`LabRun` (`Live.lean:225`); infinite-fibre generalization with one-sided live sets | — | pending (generalization); transcribed (finite-width special case) |
| HWZ 2000 | Theorem 14, p. 11: satisfiable on `F` ⟺ satisfied in a quasimodel over `F` | D5's hypothesis `RaySummary.Presents` (the realization bridge) | see Recommendations, D5 | pending (belongs to 735's assembly; stated abstractly in 711) |
| HWZ 2000 | §4, MSO sentence `σ_φ`, pp. 12–13; Theorem 15, p. 13 (flows `⟨ℕ,<⟩`, `⟨ℤ,<⟩`, `⟨ℚ,<⟩`, finite orders, FO-definable classes); proof p. 14 "The case of `⟨ℤ,<⟩` is similar" via Büchi | `RaySummary.msoSentence` as a Lean `Prop` over `ℤ` for the discrimination probe only | `(P : Presentation) → Prop` (second-order quantification over `ℤ → Prop`) | blocked as a device (Büchi absent); pending as a specification |
| HWZ 2000 | Lemma 17 (splice at equal quasistates), pp. 14–15 | label-level splicing: `FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.splice` (`Live.lean:382`), `live_iff` (`Live.lean:519`); semantic: `stab_factors` (`Splice.lean`) | `live_iff (G) (t) (p) : G.Live t p ↔ G.FwdLive t p ∧ G.BwdLive t p` (shape; see file) | transcribed (finite-width class) |
| HWZ 2000 | Lemma 23 / Theorem 24 (ultimately periodic quasimodel over `⟨ℕ,<⟩`), chunk 0031 | finite-width only: `PlusSlicedCertificate.TailStable`, `mem_L₀_of_live_tail` (`Stable.lean:1199`), `forall_mem_R₀_of_live_head` (`Stable.lean:1214`), `Tail.lean` three-region run; infinite fibre via D3 (task 709's F4 is the fragment instance) | — | pending (D3/D4) |
| GKWZ 2003 | Theorem 1.28, p. 39 (MSO theory of `{(ℕ,<)}`, `{(ℤ,<)}`, `{(ℚ,<)}`, finite orders decidable; footnote: `(ℝ,<)` undecidable); p. 40 remark: reductions are non-elementary | — | — | blocked (frame only) |
| GKWZ 2003 | Lemma 11.23, p. 478: `𝔉 ⊨ qm_φ` iff a K-quasimodel for `φ` based on `𝔉` exists | `RaySummary.msoSentence_iff_exists_run` (discrimination probe target) | `msoSentence P ↔ ∃ r, P.IsRun r ∧ P.Fulfilling r` (proved by hand on the fixture) | pending (probe only) |
| GKWZ 2003 | Lemma 11.27, p. ~481 (splice) and Lemma 11.29 (bounded periodic form) | as HWZ Lemma 17 / Lemma 23 rows | — | transcribed / pending as above |
| GKWZ 2003 | Theorem 13.6, p. 568 (temporal epistemic logics with `L ∈ {K_m, T_m, KD45_m, S5_m}` over `⟨ℕ,<⟩` and FO-definable classes, by MSO reduction) | — | — | blocked (frame only; nearest published analogue to S5 × linear time) |
| This tree | keystone, `PlusRayFibre.lean:290` | `FormalSystem.PlusLanguage.plusStab_iff_omega` | `{F : FrameOver intOrder} [F.IsRegular] (M) (τ) (t : ℤ) (φ) : PlusTruthAt M τ t φ.stab ↔ ∀ bf : SeqPair F (τ.state t), PlusTruthAt M (↑((seamOmegaEquiv t (τ.state t)).symm bf)) t φ` | transcribed (`lean_hover_info`; axioms `[propext, Classical.choice, Quot.sound]`) |
| This tree | keystone, `PlusRayFibre.lean:116` | `FormalSystem.PlusLanguage.plusStab_iff_rays` | general task frame form | transcribed (axioms `[propext, Quot.sound]`) |
| This tree | alphabet licence | `Probe718Stratification.plusTruthAt_iff_stratum_atomize` (`stab-depth-stratification.lean:106`) | `(M) (e : Encoding) (φ) (τ) (t) : PlusTruthAt M τ t φ ↔ TruthAt (M.atomModel e) τ t (atomize e φ)` — general in `φ`, every `⊡`-depth | transcribed (probe; wired) |
| This tree | design constraint | `…NoFiniteWidth.not_finite_width_fmp` (`NoFiniteWidth.lean:1280`) | `¬ ∀ φ, ¬ PlusValidZTime φ → ∃ W, Finite W ∧ … ∃ M τ t, ¬ PlusTruthAt M τ t φ` (sliced frames over finite `W`) | transcribed (`lean_hover_info`; standard axioms) |

### Codebase Patterns

- **The Ramsey ingredient is a self-contained section.** `RamseyFactorization.lean:65–170`
  (`section Ramsey`, `variable {C : Type} [Finite C]`) imports only Mathlib
  (`Data.Fintype.Pigeonhole`, `Logic.Denumerable`, `Data.Set.Finite.Lattice`) plus two
  `WeakCanonical.GroupModel` modules it does not use for Ramsey. Its only in-tree consumers are
  `exists_zFactorization` (`:451`, `:453`) in the same file. Nothing under `Decidability/` imports
  it. A `Decidability/RaySummary/` module importing `RamseyFactorization` would pull the
  completeness-side `GroupModel` cluster into the decidability side; see Decisions D-2.
- **`ForMathlib/` is the sanctioned home for Mathlib-shaped, Mathlib-absent material.**
  `FormalSystem/ForMathlib/README.md`: "Mathlib-shaped extensions intended for upstreaming …
  Nothing under `FormalSystem/ForMathlib/` imports `FormalSystem.*`", with each module a recorded
  C24 exception in `scripts/CheckInitImportsMain.lean` (`check-module-invariants.sh:4280`). The
  Ramsey section qualifies exactly.
- **Finite-width tail collapse already has the shape D3 needs.** `Stable.lean`/`Tail.lean`
  prove, for a tail-stable sliced certificate, that liveness down a periodic tail is reference-set
  membership and that every member is live at every tail time by an explicit three-region run
  (`Tail.lean` header). `HalfRun.lean` supplies one-directional liveness from an explicit half-line.
  These are the finite-width, *given-period* instance of D3's `⇐` construction; D3 must do the same
  splicing at the level of segment profiles, where the period comes from Ramsey, not from the data.
- **Liveness is already split by direction.** `Live.lean`: `FwdLive`/`BwdLive`/`Live` with
  `live_iff` (`:519`) and the propagation lemmas `untl_push`/`snce_push`; `LiveFix.lean` computes
  `fwdLiveT`, `bwdLiveT`, `liveT := fwdLiveT ∩ bwdLiveT` (`:194`). This is the one-sided-live-set
  bookkeeping D5's quasistate must record per type; the tree already has it at the position level.
- **The keystone is promoted.** `FormalSystem/PlusLanguage/PlusRayFibre.lean` carries `BwdSeq`
  (`:148`), `FwdSeq` (`:152`), `SeqPair` (`:156`), `pathFibreEquiv` (`:169`), `seamOmegaEquiv`
  (`:271`), `plusStab_iff_omega` (`:290`); `Semantics/Presheaf/Ray.lean` carries `seamGlue`
  (`:274`). Cite these library names, not the probe's `Probe718.*` twins, as durable anchors (task
  735's record already does).
- **E1 is the ready-made finitely presented infinite fibre.** `backward-dual-asymmetric-fixture.lean`:
  carrier `pre k / x k / post k j`, finitely branching, one predecessor per node, infinitely many
  states per time, built by `FrameOver.ofReflectiveRegular` with saturation from finite fibres;
  per-time alphabet is three types. Per the collection's standing rule (header, and
  `check-evidence-probes.sh`), a new probe transcribes rather than imports it.
- **Evidence-collection contention.** Tasks 733 and 734 declare
  `scripts/check-evidence-probes.sh` in their `file_scope`; task 711's probes must too. ROADMAP
  Phase 1 already says: run singly.
- **Axiom pins.** `docs/theorem-index.md` row 18: `pcq` = `[propext, Classical.choice, Quot.sound]`,
  `pinned:C2`/`pinned:C14` name checks in `scripts/check-module-invariants.sh`;
  `Tests/BimodalTest/Metalogic/PeriodicExtensionAxiomTest.lean` is the pattern for pinning a
  choice-split as permanent evidence.

### External Resources

- **Mathlib at `v4.33.0-rc1`** (grep sweep of `.lake/packages/mathlib/Mathlib`, evidence tier of
  record because `lean_local_search` reported `index: unavailable` on every call): `ramsey` →
  `Combinatorics/Hindman.lean`, `Combinatorics/HalesJewett.lean` (mentions only) and three
  `RingTheory` false positives; `büchi|buchi|omega-regular|rabin automat|parity automat|muller` →
  none; `Computability/` contains `DFA, NFA, EpsilonNFA, RegularExpressions, MyhillNerode,
  TuringMachine, Partrec, …` and nothing on infinite words. `Finite.exists_infinite_fiber`
  (`Data/Fintype/Pigeonhole.lean:86`) is the pigeonhole `infinite_ramsey_pairs` uses;
  `exists_seq_of_forall_finset_exists` (`Data/Fintype/Basic.lean:258`) is the dependent-sequence
  lemma D3's `⇐` construction can use. This agrees with the in-tree header (`RamseyFactorization.lean:19–22`)
  and with task 732's report (`lean_leansearch`, 6 results, none Ramsey): three sources.
- **HWZ 2000** (corpus `hodkinson_wolter_zakharyaschev_2000_decidable_fragments_fotl`; the briefing
  tags it `unverified_summary`, but the chunks are a full-text OCR of the paper — chunk 0024
  contains the MSO sentence `σ_φ` verbatim; see Contradiction Log C-1): three routes (chunk 0007),
  Defs 10–12 and Thm 14 (chunk 0022, p. 11), `σ_φ` and Thm 15 (chunk 0024, pp. 12–13), proof
  (chunk 0025, p. 14), Lemma 17 (chunk 0027, pp. 14–15), Lemma 23 (chunk 0031).
- **GKWZ 2003** (corpus, TOC provenance `no_source_pdf`; running headers carry printed page
  numbers): Thm 1.28 p. 39 with non-elementary remark p. 40 (chunk 0058); `qm_φ` and Lemma 11.23
  p. 478 (chunk 0490); Lemmas 11.27/11.29 (chunks 0497/0498); Thm 13.6 p. 568 (chunk 0589).
- **Thomas 1997** (corpus `thomas_1997_languages`, `verified_conversion`): §5.1 p. 30 — "The
  original approach of [Bü62] uses a representation of Büchi recognizable sets in the form
  `⋃ U_i · V_i^ω`, where the `U_i, V_i` are classes of a sufficiently fine congruence over `A*` of
  finite index, and applies a combinatorial argument (e.g., a form of Ramsey's Theorem) to guarantee
  that the complement has again such a representation. An alternative is to proceed to deterministic
  automata." (chunk 0060); Thm 5.9 p. 37 (chunk 0074): "using McNaughton's Theorem for the
  complementation step".
- **Kupferman–Vardi FOCS 2005** remains WANTED in the index; only the 2001 rank-construction core
  is in corpus. Not consulted; candidate (b) is not selected and nothing here depends on it.

### The substrate, stated: what (d) is and what it must contain

**Why states fail and time pairs work (the E3 constraint, made precise).** Pigeonhole over states
needs a *state* to recur; on `⟨ℤ, b = a − 1⟩` none does. Ramsey over time pairs needs only the
*segment profile* between two times to recur — a finite datum even when every state is fresh. That
is the whole difference between E3's refuted pigeonhole tier and the selected device, and it is
Büchi's: his congruence classes are segment profiles.

**D1 — idempotent homogeneous colour (done).** From `infinite_ramsey_pairs` and a composition law
`c i k = comp (c i j) (c j k)` for `i < j < k`, the homogeneous colour `τ` on `g 0 < g 1 < g 2`
satisfies `comp τ τ = τ` (three instances of homogeneity and one rewrite). Backward mirror by the
colouring `(i, j) ↦ c (t − j) (t − i)`. Both compiled (Tactic Survey Results).

**D2 — segment profile of a per-time-alphabet presentation.** For a presentation
`P : FwdPresentation Ty Ev` (types realized per time, time-indexed suitability, per-type pending
and discharged eventualities), the profile of `[n, m)` is the finite relation
`Profile Ty Ev := Finset (Ty × Ty × Finset Ev)`: `(a, b, E)` iff a partial run from `a` at `n` to
`b` at `m` exists whose intermediate types discharge exactly `E`. Composition is relational
composition with union of discharge sets; `profile n k = (profile n m).comp (profile m k)` for
`n < m < k`. `Profile Ty Ev` is `Finite` from `[Fintype Ty] [Fintype Ev]`, so D1 applies to
`c n m := P.profile n m`. This is HWZ's "suitable pair" relation iterated, time-indexed; it is also
the transition monoid of the Büchi automaton for the path property, which is why (a)/(b)/(d) are
alternatives *here* and nowhere earlier.

**D3 — the device theorem on the forward ray.** A fulfilling run from type `a` at time 0 exists iff
some `b` is reachable from `a` with profile `(a, b, _)` over `[0, n)` and there is an idempotent
profile `τ` homogeneous on a strictly increasing time sequence from `n` with `(b, b, E) ∈ τ` and
`P.pending b ⊆ E`. The `⇒` direction colours the *run's own* segments (a sub-colouring with one
triple per pair), applies D1, and shows `E ⊇ pending b` because any eventuality pending at `b`
is discharged at some later time `u`, and the homogeneous segment `[g i, g k)` with `g k > u` has
the same discharge set as every other — fulfilment for every live position at once, from
idempotence. The `⇐` direction splices a prefix witness and one period witness per homogeneous
segment (each a *different* finite partial run unless `P` is periodic) by a dependent-choice
construction (`exists_seq_of_forall_finset_exists` or `Nat.rec` with `Classical.choice`; the axiom
profile is standard either way). For an **ultimately periodic presentation** (the sliced
certificate's tail-stable form, period `p` after prefix `k`), the right-hand side specializes to a
decidable check: `(b, b, E)` lies in some power `(profile k (k + p))^m`, `m ≤ |Profile Ty Ev|`, with
`pending b ⊆ E` — the idempotent power of a finite semigroup element. That specialization is the
computational content 735 consumes; the general Ramsey form is the completeness direction 709's F4
instantiates.

**D4 — the backward ray.** D3 with `BwdPresentation` (`suit n` relating time `t − n − 1` to
`t − n`), `snce`-eventualities, and `exists_idempotent_homogeneous_bwd`. This is where the carried
limit on the `⊡(Pp)` side would be lifted to a real-formula bridge; this report does not lift it.

**D5 — the `⊡` bridge.** By `plusStab_iff_omega`, `⊡φ` at `(τ, t)` is a universal over
`SeqPair F (τ.state t)`. By `plusTruthAt_iff_stratum_atomize` (general in `φ`, every depth), `φ`
may be taken `⊡`-free over the atomized model with a finite per-time alphabet. For a presentation
`(P_bwd, P_fwd)` of the seam fibre at type level, with a realization hypothesis `Presents`
(every pair of fulfilling half-runs through a seam type is realized by a `SeqPair`, and every
`SeqPair` yields one — HWZ Thm 14's two directions for *this* semantics), the universal summary is
`∀ a ∈ seamTypes (τ.state t), φ ∈ a ∨ ¬ P_fwd.ExistsFulfillingFrom a ∨ ¬ P_bwd.ExistsFulfillingFrom a`,
by the `live_iff`/`stab_factors` factorization (a bi-infinite fulfilling run through `a` is a
backward half and a forward half). The quasistate `seamTypes` must record, per type, which
one-sided live sets it realizes (`fwdLive`/`bwdLive` flags), task 709's first repair: in HWZ (Def 12,
p. 11) a quasistate is a bare set of types and runs are abstract, so splicing two runs at equal
quasistates (Lemma 17) can create a realised type the original model lacked, which is invisible to
HWZ's operators and lethal to a `⊡`-label. **Discharging `Presents` for a concrete frame is 735's
assembly work; 711 states D5 against the hypothesis.**

**What is not established by this research** (carried forward, not smoothed over): D2–D5 are
specifications with signatures, not theorems; the `⊡(Pp)` real-formula bridge remains at step-graph
level; adequacy of (d) beyond the probed shapes is exactly what D3/D4 would establish and is open
until they land; no complexity bound.

### Recommendations

1. **Land D1 first, in `FormalSystem/Metalogic/Decidability/RaySummary/Colour.lean`**, with the two
   compiled lemmas verbatim and an axiom pin (`pcq`) in the invariants harness. A phase of ~80
   lines; zero research risk (compiled this dispatch).
2. **Relocate `section Ramsey` to `FormalSystem/ForMathlib/Combinatorics/InfiniteRamseyPairs.lean`**
   (Mathlib namespace; e.g. `Nat.exists_strictMono_const_pair_colour`), register the C24 exception in
   `scripts/CheckInitImportsMain.lean` and the aggregator `FormalSystem/ForMathlib.lean`, and keep
   `FormalSystem.Metalogic.WeakCanonical.infinite_ramsey_pairs` as a one-line `theorem … :=` alias so
   every durable anchor in ROADMAP, the E3 probe header and this report keeps resolving. Rationale:
   it avoids a `Decidability → WeakCanonical.GroupModel` import, it is what `ForMathlib/README.md`
   exists for, and it costs one phase (~60 lines moved, one alias, two registrations). If the planner
   prefers not to touch `WeakCanonical`, the fallback is to import `RamseyFactorization` directly and
   accept the cross-front dependency; both are sorry-free routes, so this is a planner's call, not a
   user decision.
3. **D2 as its own phase** (`Profile.lean`, ~250–350 lines): `Profile`, `comp`, associativity
   (`Finset` relational composition over `Fintype` — the one fiddly lemma), `FwdPresentation`,
   `profile`, `profile_comp`, decidability instances. Milestone: `profile_comp` sorry-free.
4. **D3 in two phases** (`Forward.lean`, ~500–800 lines total): `⇒` (Ramsey on the run's own
   colouring; the `E ⊇ pending` argument from idempotence) then `⇐` (the dependent-choice splice).
   Then **D4** by mirror (`Backward.lean`, ~200 lines if `Forward.lean` is written parametrically
   in the direction; recommend parametrizing from the start). Then the **periodic specialization**
   (`Periodic.lean`, ~200–300 lines): the idempotent-power check and its `Decidable` instance.
5. **D5 as the last library phase** (`Stab.lean`, ~300–400 lines): state `Presents` as a structure
   of hypotheses and prove `plusStab_iff_summary` from `plusStab_iff_omega`,
   `plusTruthAt_iff_stratum_atomize` (transcribed into the library from the wired probe, or cited
   from `Metalogic/Conservativity/Plus/Atomization.lean` where `plusTruthAt_iff_atomize` lives), and
   a `live_iff`-shaped factorization at a seam type. Do **not** discharge `Presents` here; hand it to
   735 with the one-sided-live-set requirement written into its docstring.
6. **Two evidence probes, wired into `scripts/check-evidence-probes.sh`**:
   (i) `ray-summary-discrimination-probe.lean` — transcribe the E1 `pre/x/post` graph with its
   three-type per-time alphabet, compute profiles and the (d)-verdict for `⊡(Pp)` and `⊡(Fp)` at `x`
   and `post` states (cross-checking `Probe719Backward.past_stab_at_post` / `not_past_stab_at_x`),
   write GKWZ's `qm_φ` for the same presentation as a Lean `Prop` and prove it equivalent to the
   (d)-verdict by hand — recording that (c) adds no verdict (d) lacks and that its discharge theorem
   is unavailable; (ii) `stab-depth-two-probe.lean` (E2) — instantiate
   `plusTruthAt_iff_stratum_atomize` at a `⊡`-depth-2 formula (e.g. `⊡F(⊡Fp)`, `⊡(Fp → ⊡Pp)`) on the
   shared Bool fixture and decide its value through two atomization layers, since the falsifier the
   ranking names is "a `⊡`-depth-2 formula whose `⊡`-value at a class is not a function of the
   class's summary state". No written E2 specification exists beyond that sentence (grep of 718's
   reports/plans: none); the plan must define E2 from it.
7. **Set `file_scope`** from `proposed_file_scope` in `.return-meta.json` before any implement
   dispatch; dispatch singly while 733/734 are live on `check-evidence-probes.sh`.
8. **Delineation to record in the plan**: 711 = D1–D5 (generic over `Ty`/`Ev`; D5 against an
   abstract `Presents`); 709 = F4 as the instance of D3/D4 on the sliced certificate's quasistates
   for its restricted fragment; 735 = discharge `Presents` for concrete presentations and assemble
   `Decidable (PlusValidZTime φ)` or the recorded verdict. 711 builds no decision procedure and
   claims no decidability.

### Estimated cost (no complexity claim; engineering effort only)

| Deliverable | Lines (est.) | Dispatches | Risk |
|---|---|---|---|
| D1 Colour (+ pin) | ~80 | 1 (with relocation) | none — compiled |
| Relocation to `ForMathlib` + alias | ~80 touched | same dispatch | low (C24 registration) |
| D2 Profile | 250–350 | 1 | low–medium (`comp` associativity) |
| D3 Forward (⇒, ⇐) | 500–800 | 2 | medium–high (⇐ splice construction; 709's "risk R3" is exactly this) |
| D4 Backward + Periodic specialization | 400–500 | 1–2 | low–medium if parametrized |
| D5 Stab bridge | 300–400 | 1 | medium (one-sided live quasistate design) |
| Probes (i), (ii) + wiring | 300–450 | 1 | low; contention on the gate script |
| **Total** | **~1,900–2,700** | **7–9** | — |

## Decisions

- **D-1 Device identity.** Record candidate (d) as Büchi's Ramsey proof of the complementation step
  inside route (c) (Thomas 1997 p. 30), not as a fourth route. Consequence: no truth-value
  discrimination between (c) and (d) is possible; the discrimination probe is about executability.
- **D-2 Ramsey relocation.** Recommend moving `section Ramsey` to `ForMathlib/` with an alias at the
  old name (Recommendation 2); fallback is a direct import. Planner's call.
- **D-3 Scope split.** 711 owns D1–D5 generically; `Presents` is stated, not discharged; F4 (709)
  and assembly (735) consume. This keeps the dispatch's "built here, consumed downstream" rule.
- **D-4 Durable anchors.** Cite `FormalSystem.PlusLanguage.plusStab_iff_omega`,
  `…PlusSlicedCertificate.NoFiniteWidth.not_finite_width_fmp`, and (until relocation) 
  `FormalSystem.Metalogic.WeakCanonical.infinite_ramsey_pairs`; probe names are provenance.
- **D-5 No `user_decision`.** Every open choice above is a routine engineering judgment the plan
  can make; nothing requires the user's preference or an external cost.

## Adversarial Self-Verification

### Claim Verification Table

| # | Claim | Source/Counterexample | Verification Method | Confidence |
|---|-------|------------------------|----------------------|------------|
| 1 | `infinite_ramsey_pairs` exists with the stated signature on standard axioms | `RamseyFactorization.lean:146`; `#print axioms` = `[propext, Classical.choice, Quot.sound]` | `lean_hover_info`-confirmed type signature + `lean_run_code` `#print axioms` | High |
| 2 | D1 (`exists_idempotent_homogeneous`, `_bwd`) is provable from it, sorry-free, standard axioms | compiled in `lean_run_code`, `#print axioms` for both | `lean_run_code` success + `#print axioms` (no `sorryAx`) | High |
| 3 | Mathlib at the pin lacks infinite Ramsey for pairs and all ω-automata infrastructure | grep sweep (this dispatch) + `RamseyFactorization.lean` header + task 732's `lean_leansearch` | grep sweep (lean-lsp index `unavailable`, so the sweep is the tier of record) + in-tree docstring + prior-session search tool | High |
| 4 | `plusStab_iff_omega` / `plusStab_iff_rays` are in the library with the stated signatures and axiom split | `PlusRayFibre.lean:290`, `:116`; `#print axioms` = pcq / `[propext, Quot.sound]` | `lean_hover_info` + `lean_run_code` `#print axioms` | High |
| 5 | `not_finite_width_fmp` is the library name and forces infinite fibres for complete classes | `NoFiniteWidth.lean:1280`; docstring | `lean_hover_info`-confirmed signature; bounded read of header lines 1270–1290, 1295–1310 | High |
| 6 | HWZ Thm 15 lists `⟨ℤ,<⟩` and discharges by Büchi; `σ_φ` is written on pp. 12–13 | chunks 0024–0025 read in full | direct read of corpus text (two chunks) | High |
| 7 | GKWZ Thm 1.28 (p. 39), Lemma 11.23 (p. 478), Thm 13.6 (p. 568) are as cited; reduction non-elementary (p. 40) | chunks 0058, 0490, 0589 read | direct read; page numbers from running headers in the same chunks | High for content; Medium for page numbers (OCR running headers, no PDF in corpus) |
| 8 | HWZ quasistates are bare type sets and runs abstract (so a one-sided-live repair is needed for `⊡`) | Def 12 and Remark 13, chunk 0022 p. 11; Lemma 17 chunk 0027 | direct read + task 709's record (independent statement of the same repair) | High |
| 9 | **Resolving check for E3's Low-confidence limit**: Büchi's original complementation proof is Ramsey-based over a finite-index segment congruence; determinization is the alternative | Thomas 1997 §5.1 p. 30 (chunk 0060), Thm 5.9 p. 37 (chunk 0074) | direct read of the named resolving source | High that Thomas states it; **Medium** that (d) as specified *is* that argument (structural identification by this report: profiles = congruence classes; not stated in any source) |
| 10 | (c) and (d) cannot be discriminated by truth value on any fixture | consequence of 9 and of HWZ Thm 14/Lemma 11.23: both characterize "a quasimodel exists" | reasoning from directly read sources; no counterexample sought because the claim is an equivalence of two proofs of one theorem | Medium (framing, flagged as such in Recommendations 6) |
| 11 | E2 has no written specification beyond its name and the ranking's falsifier sentence | grep of `specs/718_*/reports`, `plans`, ROADMAP, 721 spec, 719 report | repository grep (4 locations) | High |
| 12 | 733/734 declare `scripts/check-evidence-probes.sh` in `file_scope` | `jq` on `specs/state.json` | direct read of state | High |
| 13 | `ForMathlib/` admits a Mathlib-only Ramsey module with a C24 exception | `ForMathlib/README.md`; `check-module-invariants.sh:4280` | bounded reads of both | High |
| 14 | The finite-width tail collapse (`Stable.lean`, `Tail.lean`, `HalfRun.lean`) is the given-period instance of D3's `⇐` | module headers + `mem_L₀_of_live_tail:1199`, `forall_mem_R₀_of_live_head:1214` | bounded header reads + grep of names | Medium (shape match read from headers; proofs not re-read) |

### Contradiction Log

- **C-1 Provenance tags vs. content.** The literature briefing tags HWZ 2000 `unverified_summary` and
  GKWZ's TOC says `no_source_pdf`, while `ztime-no-finite-carrier-fmp.md` §8 marks GKWZ p. 234
  `[verified-pdf]`, and the HWZ chunks contain the paper's formulas verbatim. Precedence: the
  primary text read directly outranks an index tag. Resolution: cite with page numbers as read;
  record that the tags are stale for these two sources (Context Extension Recommendations).
- **C-2 Keystone location.** Task 711's description cites the probe
  (`stab-fibre-is-ray-product.lean`); task 735's cites the library (`PlusRayFibre.lean`). Both exist;
  `lean_hover_info` confirms the library copy. Resolution: library names are the durable anchors
  (Decision D-4). No contradiction in content.
- **C-3 "No Ramsey" (E3) vs. a Ramsey device.** E3 proved Ramsey is *not needed* on finite fixtures
  (pigeonhole suffices) and refuted pigeonhole on an infinite acyclic fibre. Not a contradiction:
  the device is needed exactly where E3's refutation lives. Resolved by reading both files.
- No `UNRESOLVED CONTRADICTION`.

### Recommendations modified after verification

- The draft framed the discrimination probe as "the first behavioural discrimination between (c) and
  (d)" as the ROADMAP words it. After row 9 it is restated as an executability discrimination with
  a hand-proved equivalence (Recommendation 6(i)); promising a truth-value split would be an
  overclaim.
- The draft placed D1 directly in `Decidability/RaySummary/` importing `RamseyFactorization`; after
  reading `ForMathlib/README.md` and the C24 rule, relocation with an alias became the primary
  recommendation and the direct import the fallback (D-2).
- The draft's first backward-mirror proof used `simp only at …`, which made no progress; the
  compiled version drops it (Tactic Survey Results).

## Literature Proof Structure

**Source**: Hodkinson–Wolter–Zakharyaschev 2000 §§3–4 (quasimodels; MSO embedding), with GKWZ 2003
§11.3 (`qm_φ`, Lemma 11.23) and §13.2 (Thm 13.6) as the book form; Thomas 1997 §5.1 for the
complementation step that (d) replaces.

**Strategy**: satisfiable on the flow ⟺ a quasimodel exists (HWZ Thm 14); "a quasimodel exists" is
an MSO sentence `σ_φ` with unary predicates `P_s` (one per realizable state candidate, partitioning
the flow) and `R_ψ` (defining runs); decide `σ_φ` on `⟨ℤ,<⟩` by Büchi (HWZ Thm 15(2)). Büchi's
theorem's hard step is complementation, proved by Ramsey on segment classes (Thomas p. 30) — (d) —
or by determinization (McNaughton/Safra) — (a).

### Step Map

| Step | Source | Tree counterpart | Lean4 translation note |
|---|---|---|---|
| 1. Types, state candidates, `♯(φ)` bound | HWZ Defs 5–7 | stratification alphabet (`plusTruthAt_iff_stratum_atomize`) | per-time alphabet `Ty`, `Finset Ty` per time (D2) |
| 2. State function `f : W → Σ` | HWZ Def 10, p. 11 | `FwdPresentation.real` | time-indexed; forward/backward rays separately |
| 3. Run (`U`/`S` clauses) | HWZ Def 11, p. 11 | `IsRun`, `Fulfilling`; tree's `LabRun` | eventualities as `pending`/`discharged` sets |
| 4. Quasimodel `⟨f, R⟩`, Thm 14 | HWZ Def 12, Thm 14, p. 11 | `PlusSlicedCertificate` (finite width); D5's `Presents` | **repair**: quasistate carries one-sided live flags |
| 5. `σ_φ` / `qm_φ`, Lemma 11.23 | HWZ pp. 12–13; GKWZ p. 478 | `msoSentence` (probe only) | a `Prop` with `∃ (P : ℤ → Prop)`; never discharged |
| 6. Decide by Büchi; Thm 15(2) for `⟨ℤ,<⟩` | HWZ p. 13–14; GKWZ Thm 1.28 p. 39 | — | blocked; replaced by step 6′ |
| 6′. Complementation by Ramsey on segment classes | Thomas 1997 p. 30; Doets 1987 ch. 7 | `infinite_ramsey_pairs` → D1 → D2/D3 | the substrate |
| 7. Ultimately periodic form | HWZ Lemmas 17, 21, 23 / Thm 24; GKWZ 11.27, 11.29 | `TailStable`, `Tail.lean` (finite width) | D3's `⇒` via idempotence instead of successive splicing |

### Dependencies

`infinite_ramsey_pairs` (in tree) → D1 (compiled) → D2 → D3/D4 → D5; `plusStab_iff_omega`,
`plusTruthAt_iff_atomize`/stratification, `live_iff` (in tree) → D5.

### Potential Formalization Challenges

1. `⊡` quantifies over histories through a *state*; HWZ have no such operator and GKWZ §13.2's
   "agents who know the time" is the nearest analogue. D5's `Presents` must be stated at type level
   with one-sided live flags; discharging it for a concrete frame is where the mismatch bites (735).
2. D3's `⇐` is a dependent-choice splice of distinct period witnesses; the tree's `Tail.lean` does
   the finite-width given-period version and documents why two reference runs are needed — the same
   subtlety recurs at profile level.
3. Bi-infinite runs: HWZ carry `⟨ℤ,<⟩` only through the MSO route ("similar"); D4 is the explicit
   backward half, with the carried limit that no real-formula `⊡(Pp)` bridge exists yet.
4. `plusStab_iff_omega` measures `Classical.choice` via `FrameOver.worldHistoryOfStepPath`; D5
   inherits it. Pin the split as `PeriodicExtensionAxiomTest.lean` does.

## Tactic Survey Results

| Goal | Tactic / method | Result | Premises |
|---|---|---|---|
| `∃ g, StrictMono g ∧ ∃ τ, comp τ τ = τ ∧ ∀ i j, i < j → c (g i) (g j) = τ` (forward) | `obtain ⟨g, hg, τ, hτ⟩ := infinite_ramsey_pairs c`; three instances `hτ 0 1`, `hτ 1 2`, `hτ 0 2`; `rw [hc _ _ _ (hg _) (hg _), h01, h12] at h02` | success, `[propext, Classical.choice, Quot.sound]` | `infinite_ramsey_pairs`, composition law `hc` |
| same, backward mirror on `c : ℤ → ℤ → C` at seam `t` | Ramsey on `fun i j => c (t - j) (t - i)`; casts via `exact_mod_cast hg …`; `rw [hc (t - g 2) (t - g 1) (t - g 0) (by omega) (by omega), h12, h01] at h02` | first attempt failed (`simp only at …` made no progress — hypotheses already beta-reduced); second attempt success, standard axioms | as above |
| `#print axioms` of keystone and constraint theorems | `lean_run_code` with `import FormalSystem` | `plusStab_iff_omega` pcq; `plusStab_iff_rays` `[propext, Quot.sound]`; `not_finite_width_fmp` pcq | — |

No tactic was tried on D2–D5 (no statements exist yet); their signatures are specifications.

## Context Extension Recommendations

- **Topic**: in-tree Ramsey and the device identity. **Gap**: no decidability-side context file
  points at `infinite_ramsey_pairs` or records that candidate (d) is Büchi's Ramsey complementation
  proof. **Recommendation**: add to `ztime-no-finite-carrier-fmp.md` §8 a short "Route (1)'s hard
  step" paragraph citing Thomas 1997 p. 30 and the (future) `ForMathlib` module.
- **Topic**: literature provenance tags. **Gap**: HWZ 2000 is tagged `unverified_summary` and GKWZ
  `no_source_pdf` although both are full-text OCR with page headers. **Recommendation**: a
  `/literature --validate` pass to retag them.
- **Topic**: lean-lsp degraded mode. **Gap**: `lean_local_search` reported `index: unavailable` for
  the whole dispatch; the readiness context says to announce the tier, which this report does.
  **Recommendation**: record the grep-sweep fallback in `mcp-fallback-table.md` if absent.

## Appendix

### Search queries used

- `lean_local_search`: `infinite_ramsey_pairs` (2 hits: library + archived probe), `Ramsey`,
  `Buchi`, `Hindman`, `omegaRegular` (all `index: unavailable` — not evidence of absence).
- Mathlib grep sweep (`.lake/packages/mathlib/Mathlib`): `ramsey`; `büchi|buchi|omega-regular|
  omegaRegular|ω-regular|rabin automat|parity automat|muller automat`; `Combinatorics/` and
  `Computability/` listings; `Finite.exists_infinite_fiber`; `exists_seq_of_forall_finset_exists`.
- Repository greps: `infinite_ramsey_pairs` (code, docs, scripts); keystone names under
  `FormalSystem/`; `quasimodel|StateCandidate`; `König|Konig`; `E2`, `depth-2` under `specs/`;
  `ForMathlib` in `check-module-invariants.sh`; file scopes of 709/733/734/735 via `jq`.
- `literature-search.sh` FTS: two queries returned `degraded: true` with empty results; corpus read
  by direct grep/`cat` of chunk files instead (`--toc` worked).
- `lean_hover_info`: `RamseyFactorization.lean:146:9`, `PlusRayFibre.lean:290:9`,
  `NoFiniteWidth.lean:1280:9`.
- `lean_run_code`: `#print axioms` ×4 and `#check` ×2; D1 forward and backward proofs.

### References to documentation

- `FormalSystem/ForMathlib/README.md` (dependency rule); `scripts/check-module-invariants.sh:4272–4296` (C24).
- `docs/theorem-index.md:18` (`pcq`, `pinned:C2/C14`); `Tests/BimodalTest/Metalogic/PeriodicExtensionAxiomTest.lean` (axiom-split pin pattern).
- `.claude/context/project/logic/domain/ztime-no-finite-carrier-fmp.md` §8 (HWZ ↔ sliced-certificate table).
- Issue log entries this dispatch: one `kind: issue` (tooling degraded: lean-lsp index unavailable,
  FTS degraded), one `kind: win` (D1 compiled during research).
