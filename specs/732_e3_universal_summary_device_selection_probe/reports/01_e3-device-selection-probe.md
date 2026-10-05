# Research Report: Task #732

**Task**: 732 - Run experiment E3: select the universal summary device for the seam-gluing stab fibre check
**Started**: 2026-10-05T17:58:17Z
**Completed**: 2026-10-05T18:35:20Z
**Effort**: 1 research dispatch (`--hard --lit`), ~45 tool calls
**Dependencies**: None (task 711 depends on this one)
**Sources/Inputs**: Codebase (`FormalSystem/PlusLanguage/PlusRayFibre.lean`, `specs/evidence/seam-gluing-ray-product/*.lean`, `FormalSystem/Metalogic/WeakCanonical/GroupModel/RamseyFactorization.lean`, `scripts/check-evidence-probes.sh`), Mathlib source at pin `v4.33.0-rc1` (grep + `lean_local_search` + `lean_leansearch`), lean-lsp MCP (`lean_hover_info`, `lean_verify`), literature corpus (HWZ 2000, GKWZ 2003, Kupferman–Vardi 2001, `~/Projects/Literature/SOURCES.md` D8), programme records (`specs/archive/721_.../followup-scope-spec.md` Section B and "Ranking ratification", `specs/ROADMAP.md`, task 711/709 descriptions), and a compiled research prototype `specs/732_e3_universal_summary_device_selection_probe/probes/device-probe-proto.lean`
**Artifacts**: this report; `specs/732_e3_universal_summary_device_selection_probe/probes/device-probe-proto.lean` (compiles under `lake env lean`, standard axioms, no warnings)
**Standards**: report-format.md, subagent-return.md, anti-analysis.md (H2 lean4), reference-grounding.md (H3 lean4, Tier 1), adversarial-verification.md (H4), context-hygiene.md

## Executive Summary

- **Every established fact the dispatch names re-verifies against the tree today**: `plusStab_iff_rays` (`PlusRayFibre.lean:116`), `pathFibreEquiv` (`:169`), `seamOmegaEquiv` (`:271`), `plusStab_iff_omega` (`:290`), all under `variable [F.IsRegular]` (`:106`, `:282`) and not unconditionally; `Probe718PathQuantifier.exists_ne_stab` (`path-quantifier-alternation.lean:159`) and `exists_ne_universal` (`:167`); `Probe718Stratification.plusTruthAt_iff_stratum_atomize` (`stab-depth-stratification.lean:106`).
- **The `⊡(Fp)`/`⊡(Pp)` shapes, run on finite fixtures, cannot discriminate the four candidate devices — and the reason is now machine-checked.** The per-path property "eventually `p`" is recognised by a 2-state *deterministic* acceptor (`detRun_accepts_iff`, compiled), so Safra/Piterman (a) and Safraless (b) have no nondeterminism to remove; and the universal summary over *any* finite step graph reduces to ultimately periodic paths by **pigeonhole alone** (`allPathsMeet_iff_lasso`, compiled via `Finite.exists_ne_map_eq_of_infinite`), so the Ramsey device (d) is exercised only at its trivial tier and the MSO device (c) has nothing to absorb. `⊡(Pp)` is the same statement on the reversed graph (`allBwdPathsMeet_iff_lasso`, one line). On these shapes all four devices coincide with the reachability summaries already proved (`Probe718FiniteGraph.will_iff_allPathsMeet`, `Probe719Backward.pastStab_iff_allBwdPathsMeet`).
- **The pigeonhole tier of (d) is refuted as a general device, also machine-checked**: on the infinite descending chain on `ℤ` the universal summary is False while its lasso restriction is vacuously True (`not_lasso_sufficient_on_chain`, compiled). Since `Probe710.not_finite_width_fmp` already forces infinite fibres for complete classes, this is the regime the substrate must handle, and the specified shapes on finite fixtures do not reach it.
- **What the comparison can decide, on evidence actually in hand, is infrastructure and literature coverage, not behaviour.** (d) is the only candidate with any substrate in this tree: `FormalSystem.Metalogic.WeakCanonical.infinite_ramsey_pairs` is proved, self-contained, on `[propext, Classical.choice, Quot.sound]` (`lean_verify`), and Mathlib lacks infinite Ramsey for pairs (grep of Mathlib source + `lean_leansearch`, two sources). (c) is the only candidate with a published theorem covering the exact target — HWZ 2000 Theorem 15 (flows including `⟨ℤ,<⟩`), GKWZ 2003 Theorem 1.28 (MSO over `⟨ℤ,<⟩` decidable) and Theorem 13.6 (PTL × S5 by MSO reduction, the nearest published analogue to TM's S5 × linear time) — but its mechanization cost is Büchi's theorem itself, which no Lean library has and which the zero-debt policy forbids citing as an axiom. (a) and (b) have zero infrastructure in Mathlib (the `Computability/` directory has DFA/NFA/εNFA/TM only; no Büchi, parity, Rabin or ω-word anywhere) and no formalization in any proof assistant (`SOURCES.md` D8); (b)'s FOCS 2005 source is paywalled/WANTED, though the corpus's Kupferman–Vardi 2001 carries the rank construction it rests on (chunks 18–23).
- **Recommended selection for the probe header** (to be written by the implement phase, not asserted here as a theorem): *"No candidate is selected by the `⊡(Fp)`/`⊡(Pp)` shapes on finite fixtures — they are device-inert, provably. Pigeonhole-tier lasso summaries are refuted for infinite fibres. On infrastructure and literature evidence, the substrate should be built on the TIME-AXIS family: the Ramsey-coloured summary (d) over time pairs via the in-tree `infinite_ramsey_pairs`, with the MSO-over-`⟨ℤ,<⟩` quasimodel route (c) as its literature frame (HWZ 2000 Thm 15; GKWZ 2003 Lemma 11.23, Thm 13.6). (a)/(b) are not selected: inert on the shapes, no infrastructure anywhere."* This is a selection by evidence of what exists and what fails, scoped exactly as stated; it is not a behavioural discrimination, and the report says so.
- **No complexity bound is claimed or implied anywhere in this report.**

## Context & Scope

E3 is specified in `specs/archive/721_decidability_programme_review_l_and_lplus/followup-scope-spec.md`, "Ranking ratification", R1 bullet "Cheapest next experiments": *"E3 a device-selection probe comparing the candidate universal devices on the `⊡(Fp)`/`⊡(Pp)` shapes, before anything is funded (Section B)"*. Section B (lines 175–189 of that file) lists the four candidates (a)–(d) verbatim as the dispatch does. Task 711's description (state.json, read 2026-10-05) restates them and records the blocked reason "DEVICE NOT YET SELECTED; PROBE E3 PENDING". `specs/ROADMAP.md:65` names the critical path **732 → 711 → 735**.

Constraints honoured: selection only, no substrate building (the prototype proves comparison lemmas about abstract step graphs, not a device); no complexity bound; no device asserted without evidence; the deliverable probe file is `specs/evidence/seam-gluing-ray-product/device-selection-probe.lean` per task 732's `file_scope`, to be wired into `scripts/check-evidence-probes.sh` (`WIRED` array, `check-evidence-probes.sh:180–185`, compiled by `lake env lean "$file"` at `:252`), both written by the implement phase.

Reference grounding tier: **Tier 1** (literature-backed — HWZ 2000, GKWZ 2003, Kupferman–Vardi 2001/2005, Safra 1988 are all named sources). The 5-column mapping table is in Findings.

Lean readiness: lean-lsp reachable; `lean_local_search` index reported `warming` throughout, so Mathlib *absence* claims below rest on direct grep of `.lake/packages/mathlib/Mathlib` plus `lean_leansearch`, never on an empty warming-index result.

## Findings

### Re-verification of the established facts (all High confidence, two sources each: grep + bounded read)

| Dispatch claim | Tree today | Line | Hypothesis |
|---|---|---|---|
| `plusStab_iff_rays` | present | `FormalSystem/PlusLanguage/PlusRayFibre.lean:116` | `variable {F : TaskFrame} [F.IsRegular]` at `:106` |
| `pathFibreEquiv` | present | `PlusRayFibre.lean:169` | section `Omega`, `[F.IsRegular]`; measures `Classical.choice` via `FrameOver.worldHistoryOfStepPath` (file header `:34–40`) |
| `seamOmegaEquiv` | present | `PlusRayFibre.lean:271` | as above; `StabFibre F.toTaskFrame t s ≃ SeqPair F s` |
| `plusStab_iff_omega` | present | `PlusRayFibre.lean:290` | `variable {F : FrameOver intOrder} [F.IsRegular]` at `:282` |
| `Probe718PathQuantifier.exists_ne_stab` | present | `specs/evidence/seam-gluing-ray-product/path-quantifier-alternation.lean:159` | Bool complete-graph fixture `Ff`, `instance : Ff.IsRegular` |
| `Probe718PathQuantifier.exists_ne_universal` | present | same file `:167` | `ExistsSummary w₀ ∧ ¬ AllPathsMeet w₀` |
| `Probe718Stratification.plusTruthAt_iff_stratum_atomize` | present | `stab-depth-stratification.lean:106` | — |
| `SeqPair F s` | `{bf : BwdSeq F × FwdSeq F // bf.1.1 0 = s ∧ bf.2.1 0 = s}` | `PlusRayFibre.lean:156` | the two-factor product the device must be universal over |

### Lemma-level mapping table (H3 Tier 1, 5-column)

Status vocabulary: `transcribed` = proved in this tree; `prototype` = proved in the research prototype (not yet in the deliverable probe); `pending` = cited, not to be transcribed by this task; `absent` = no Lean counterpart exists in Mathlib or this tree.

| Source | Prop/Location | Lean Identifier | Type Signature | Status |
|---|---|---|---|---|
| HWZ 2000 (APAL 106) | Theorem 14, §4 (corpus chunk 0025, "By Theorem 14, this holds iff ϕ is satisfied in a quasimodel") | — (quasimodel ↔ sliced certificate correspondence table, `ztime-no-finite-carrier-fmp.md` §8) | satisfiable on flow ↔ quasimodel exists | pending |
| HWZ 2000 | Theorem 15, §4 "Embedding into second-order monadic theories" (chunk 0024, lines 86–94: flows 1. `⟨ℕ,<⟩`, 2. `⟨ℤ,<⟩`, 3. `⟨ℚ,<⟩`, 4. finite orders) | — | monodic satisfiability over the listed flows is decidable, via MSO sentence `σ_ϕ` | absent (route (c) target) |
| HWZ 2000 | §1, chunk 0007 lines 10–19: "expresses the existence of a quasimodel … by a formula of monadic second-order logic … together with the Büchi and Rabin decidability theorems … non-elementary" | — | — | pending (route (c) characterisation) |
| GKWZ 2003 | Theorem 1.28 (chunk 0058 line 7): MSO theory of `{(ℤ,<)}` decidable (Büchi 1962, Rabin 1969); line 17: resulting algorithm non-elementary | — | — | absent (Büchi's theorem; no Lean formalization) |
| GKWZ 2003 | Lemma 11.23 (chunk 0490): "§ ⊨ qm_ϕ iff there exists a K-quasimodel for ϕ based on §" | — | — | pending |
| GKWZ 2003 | Theorem 13.6, §13.2 (chunk 0589 line 61 ff., chunk 0591 proof): temporal epistemic logics with `L ∈ {K_m, T_m, KD45_m, S5_m}` over `⟨ℕ,<⟩` and FO-definable classes, decidable by MSO reduction; runs quantified universally in the quasimodel | — | — | pending (nearest published analogue to TM = S5 × linear time) |
| Kupferman–Vardi 2001 (corpus) | Abstract + §§ (chunks 18–23, 40+ occurrences of "rank"): quadratic translation of Büchi/co-Büchi alternating automata to weak alternating automata without determinization; simple complementation of nondeterministic Büchi | — | — | absent (route (b) core; no ω-automata in Mathlib) |
| Kupferman–Vardi 2005 (FOCS) | "Safraless decision procedures" — `SOURCES.md` D8 line 1018: PAYWALLED, WANTED | — | — | absent |
| Safra 1988 / Piterman 2007 | `SOURCES.md` D8 lines 1008–1032: Safra paywalled; Löding–Pirogov 2019 and Piterman 2007 in corpus; "no formalization of Safra or Piterman determinization exists in ANY proof assistant (AFP topic listing enumerated directly)" | — | — | absent |
| Mathlib `v4.33.0-rc1` | `Mathlib/Data/Fintype/Pigeonhole.lean:74` | `Finite.exists_ne_map_eq_of_infinite` | `∀ {α β} [Infinite α] [Finite β] (f : α → β), ∃ x y, x ≠ y ∧ f x = f y` | transcribed (Mathlib) |
| This tree | `FormalSystem/Metalogic/WeakCanonical/GroupModel/RamseyFactorization.lean:146` | `FormalSystem.Metalogic.WeakCanonical.infinite_ramsey_pairs` | `{C : Type} [Finite C] (c : ℕ → ℕ → C) : ∃ g, StrictMono g ∧ ∃ τ, ∀ i j, i < j → c (g i) (g j) = τ` | transcribed (axioms `[propext, Classical.choice, Quot.sound]`, `lean_verify`) |
| Prototype (this task) | `probes/device-probe-proto.lean` | `Probe732Proto.allPathsMeet_iff_lasso` | `(R : S → S → Prop) (P : S → Prop) (w₀ : S) [Finite S] : AllPathsMeet R P w₀ ↔ ∀ g, IsPath R w₀ g → IsLasso g → ∃ n, 0 < n ∧ P (g n)` | prototype (`[propext, Classical.choice, Quot.sound]`) |
| Prototype | same | `Probe732Proto.allBwdPathsMeet_iff_lasso` | the `Pp` dual: `AllPathsMeet (fun a b => R b a) P w₀ ↔ …` | prototype |
| Prototype | same | `Probe732Proto.detRun_accepts_iff` | `(∃ n, detRun P g n = true) ↔ ∃ m, 0 < m ∧ P (g m)` | prototype (`[propext, Quot.sound]`) |
| Prototype | same | `Probe732Proto.not_lasso_sufficient_on_chain` | `¬ ((∀ g, chain-path g → ∃ n, 0 < n ∧ False) ↔ (∀ g, chain-path g → IsLasso g → ∃ n, 0 < n ∧ False))` | prototype (`[propext, Quot.sound]`) |

### Codebase Patterns

- **Probe collection conventions** (`scripts/check-evidence-probes.sh` header, `:1–45`; every sibling probe header): a probe imports only `FormalSystem`, never another probe; fixtures are transcribed, not imported; the header states outcome, what it licenses, and what it does NOT establish; compile line `lake env lean specs/evidence/seam-gluing-ray-product/<name>.lean`; `#print axioms` at the foot. The `WIRED` array (`:180–185`) and the commented table above it (`:49–178`) are the wiring points; the table rows are 62-char-aligned `# path | decision held in place` blocks.
- **Fixture shapes the deliverable can reuse verbatim**: the Bool complete graph `Rf : ℤ → Bool → Bool → Prop := fun _ _ _ => True`, `Ff := FrameOver.ofSlicedStep Rf Rf_fwd Rf_bwd`, `instance : Ff.IsRegular := FrameOver.ofSlicedStep_isRegular …`, `IsFwdPath w₀ g := g 0 = w₀ ∧ ∀ n, Rf 0 (g n) (g (n+1))`, `AllPathsMeet` (`path-quantifier-alternation.lean:38–58`). `IsFwdPath w₀ g` is definitionally `Probe732Proto.IsPath (Rf 0) w₀ g`, so the prototype's abstract lemmas specialise to the fixture by `Iff.rfl`-level unfolding, and `will_iff_allPathsMeet` connects them to the real `⊡(Fp)` formula `.stab (someFuture (.atom pa))` (`someFuture φ := untl top φ`, `somePast φ := snce top φ`, `Formula.lean:140,143`).
- **The time-asymmetric infinite fixture** (`backward-dual-asymmetric-fixture.lean` header): carrier `pre k / x k / post k j`, steps `pre (k+1) → pre k`, `pre k → x k`, `x k → post k 0`, `post k j → post k (j+1)`; infinite carrier, built by `FrameOver.ofReflectiveRegular` with saturation from `TaskFrame.saturation_of_fib_finite`. Its forward paths out of `pre k` include the infinite descending `pre`-chain — acyclic, so **no lasso exists**, which is precisely the regime of `not_lasso_sufficient_on_chain`. The deliverable probe can run the falsifier on this fixture rather than on the bare `ℤ`-chain if a frame-level statement is wanted; the bare chain suffices for the abstract point.
- **Existing Ramsey infrastructure**: `RamseyFactorization.lean` header (`:19–22`) records *"Infinite Ramsey for pairs — absent from Mathlib at this pin (Hindman and Hales–Jewett are present; the classical infinite Ramsey theorem is not) — is proved from scratch here (`infinite_ramsey_pairs`)"*. Supporting declarations `ramseyCol`, `ramseySeq`, `ramseyNext`, `ramseyChain`, `ramseySeq_pair_col`, `ramsey_step_exists` (`lean_local_search`, 12 hits, all in that file). The file is on the completeness side (`WeakCanonical`), imported nowhere under `Decidability/` — reusing it from a probe is an `import FormalSystem` away.
- **Existing Büchi-adjacent remarks**: `Metalogic/Decidability/BiLasso/Basic.lean:24` and `GoodCycle.lean:30` discuss the one-directional Büchi degeneralisation and deliberately avoid a `pending` counter — the base-language L decision layer is a bi-lasso (ultimately periodic in both directions) search, i.e. exactly pigeonhole-tier (d) over a *finite* carrier, which L has and L⁺ does not.

### External Resources

- **Mathlib has no ω-automata, no MSO, no infinite Ramsey for pairs** (High: grep of `.lake/packages/mathlib/Mathlib` for `büchi|buchi|omega.automat|ω-automat|parity automat|rabin` → only a false positive in `Topology/Order/Basic.lean`; `ramsey` → `Combinatorics/Hindman.lean`, `Combinatorics/HalesJewett.lean` and three RingTheory false positives; `monadic second` → none; `Computability/` directory listing: `DFA, NFA, EpsilonNFA, RegularExpressions, MyhillNerode, TuringMachine, Partrec, …` and nothing on infinite words. Cross-checked by `lean_leansearch` "infinite Ramsey theorem for pairs" → 6 results, none a Ramsey theorem: `exists_seq_of_forall_finset_exists'`, `Combinatorics.exists_mono_homothetic_copy`, `Cardinal.infinite_pigeonhole_set`, `Set.Infinite.exists_lt_map_eq_of_mapsTo`, `Finite.exists_infinite_fiber`, `Finite.exists_ne_map_eq_of_infinite`.)
- **HWZ 2000** (`~/Projects/Literature/sources/hodkinson_wolter_zakharyaschev_2000_decidable_fragments_fotl/`, 88 chunks, provenance `unverified_summary` per the briefing — but the chunks read here are OCR of the paper itself): §1 three routes (chunk 0001 lines 26–28; chunk 0007 lines 10–19, 44–48); §4 MSO embedding (chunks 0023–0025, Theorem 15 at chunk 0024 lines 88–94 listing `⟨ℤ,<⟩` as flow class 2); §5 opens (chunk 0026 lines 13–16) by naming the MSO route's complexity "non-elementary [36]" and giving the explicit `⟨ℕ,<⟩` analysis instead; §7.8 (chunk 0064) uses existential MSO over `⟨ℝ,<⟩`.
- **GKWZ 2003** (`gabbay_kurucz_wolter_zakharyaschev_2003_many_dimensional_modal_logics/`, verified-pdf per `ztime-no-finite-carrier-fmp.md` §8): Theorem 1.28 and its footnote (chunk 0058); §11.3 (chunks 0486–0492), Lemma 11.23 (chunk 0490); Theorem 13.6 and proof (chunks 0589–0591): quasistates are finite trees of types, runs are coherent/saturated functions `W → T_w`, and the quasimodel's run set `R` carries the universal quantification — the structural reason (c) needs no Safra: *the universal path quantifier is an MSO `∀R` over run predicates, and complementation is discharged inside Büchi's theorem*.
- **Kupferman–Vardi 2001** (`kupferman_vardi_2001/`, 45 chunks, PDF present): abstract (chunk 0001) — translation of Büchi/co-Büchi alternating automata to weak alternating automata *circumventing determinization*, yielding Büchi complementation; rank construction in chunks 18–23. This is the mathematical core Safraless (2005) builds on, so (b) is less source-starved than the WANTED entry suggests; it remains infrastructure-starved.
- **`SOURCES.md` D8** (`:1006–1032`): Safra, Schewe (determinisation), Colcombet–Zdanowski, Kupferman–Vardi 2005 all PAYWALLED; Löding–Pirogov 2019 and Piterman 2007 acquired; priority LOW-MEDIUM; "no formalization of Safra or Piterman determinization exists in ANY proof assistant".

### The comparison, device by device, on the specified shapes

The per-path property for `⊡(Fp)` is *"the forward path meets `p` at a positive time"*; for `⊡(Pp)` the same on the backward ray. Both are **co-safety** (witnessed by a finite prefix); their complements are **safety** (closed under finite prefixes). Three mechanized facts fix what each device can and cannot do here.

| Device | Distinctive content | What the `⊡(Fp)`/`⊡(Pp)` shapes exercise of it | Infrastructure in this tree / Mathlib | Literature coverage of the target |
|---|---|---|---|---|
| (a) Safra/Piterman determinization | turn a nondeterministic Büchi acceptor into a deterministic Rabin/parity one, then complement | **nothing** — the acceptor is already deterministic (`detRun_accepts_iff`) | none; none anywhere (D8) | generic ω-regular; no `⟨ℤ,<⟩`/S5-specific statement |
| (b) Safraless (Kupferman–Vardi 2005; 2001 core in corpus) | universal co-Büchi → nondeterministic Büchi via ranks, no determinization | **nothing** — same reason | none | generic; 2005 source WANTED |
| (c) MSO over `⟨ℤ,<⟩` + Büchi (HWZ route 1) | encode "quasimodel exists" with run predicates; `⊡`'s universal path quantifier becomes MSO `∀R`; decide by Büchi/Rabin | **nothing to compare** — on a finite fixture the MSO sentence is decided by the same reachability; the route's content is Büchi's theorem | none (Büchi's theorem absent) | **strongest**: HWZ Thm 15 (flow `⟨ℤ,<⟩` listed), GKWZ Thm 1.28, Lemma 11.23, Thm 13.6 (S5 × linear time) |
| (d) Ramsey-coloured summary (task 709's F4, `infinite_ramsey_pairs`) | colour time pairs by segment type; extract homogeneous tail; ultimately periodic witness | **only its trivial tier** — pigeonhole on states suffices (`allPathsMeet_iff_lasso`); Ramsey proper is never invoked | `infinite_ramsey_pairs` proved, standard axioms, self-contained | Doets 1987 ch. 7 (via `RamseyFactorization.lean` header); Büchi 1962's complementation is itself Ramsey-based (Low–Medium: background knowledge, not re-read this session; resolving check: Thomas 1997 "Languages, Automata, and Logic", in corpus, §on Büchi complementation) |

**Behavioural verdict on the specified shapes** (High, machine-checked): the shapes are device-inert on finite fixtures. All four candidates reduce to the reachability summaries already in the evidence collection. A probe that only ran the four devices on `⊡(Fp)`/`⊡(Pp)` over the Bool fixture would therefore record four identical "True/False at every seam state" tables and select nothing — this is the risk the research exists to pre-empt.

**Where the devices actually diverge** (High for the falsifier; Medium for the framing): once the fibre is infinite — which `Probe710.not_finite_width_fmp` makes unavoidable for complete classes — pigeonhole over *states* fails (`not_lasso_sufficient_on_chain`). Every surviving device then works over the **time axis** with a finite alphabet of per-time summaries (HWZ/GKWZ's state candidates; the sliced certificate's slices; the ray product's `SeqPair` read time-indexed): (c) as monadic predicates on `⟨ℤ,<⟩`, (d) as a finite colouring of time pairs, (a)/(b) as ω-automata over that alphabet. On this reading (c) and (d) are the same mathematics in two wrappers — HWZ discharge the universal quantifier by Büchi's theorem, whose classical proof is Ramsey-based — while (a)/(b) are alternative complementation engines for the same automata. The distinctive cost of (c) in Lean is that the theorem it cites cannot be cited: under the zero-debt policy, MSO decidability over `⟨ℤ,<⟩` would have to be *proved*, i.e. Büchi complementation mechanized, which is at least the content of (b) or (d).

### Recommendations

1. **Record the selection the evidence supports, scoped exactly.** The deliverable probe header should state: *(i)* the `⊡(Fp)`/`⊡(Pp)` shapes are device-inert on finite fixtures, with `allPathsMeet_iff_lasso`, `allBwdPathsMeet_iff_lasso` and `detRun_accepts_iff` as the mechanized reason; *(ii)* pigeonhole-tier lasso summaries are refuted for infinite fibres by `not_lasso_sufficient_on_chain`; *(iii)* on infrastructure and literature evidence the substrate (task 711) should be built on **the time-axis Ramsey-coloured summary (d) via `infinite_ramsey_pairs`, framed by the MSO/quasimodel route (c)** (HWZ 2000 Thm 15; GKWZ Lemma 11.23, Thm 13.6); *(iv)* (a) and (b) are **not selected** — inert on the shapes, no formalization anywhere, (b)'s source WANTED; *(v)* what is NOT established: any behavioural superiority of (d) over (c), any adequacy of (d) beyond the shapes probed, and any complexity bound.
2. **Make the probe discriminating by including the falsifier**, not only the two inert shapes. The acceptance criterion names "the shapes" but the finding is that they do not discriminate; the probe that honestly "compares the candidate universal devices" must show *why* they coincide (the three positive lemmas) and *where* they stop coinciding (the infinite-fibre falsifier). The prototype at `probes/device-probe-proto.lean` (184 lines, compiles clean) is the implementer's starting text; it needs only the header, a `Probe732Device` namespace, specialisation of `IsPath (Rf 0)` to the Bool fixture's `IsFwdPath` with a one-line bridge to `will_iff_allPathsMeet`, and the `#print axioms` foot.
3. **Wire** `seam-gluing-ray-product/device-selection-probe` into `WIRED` at `check-evidence-probes.sh:185` with a table row in the `:139–178` style; run the whole script once, since the collection is the gate.
4. **Do not write any device code.** The prototype's `detRun` is a 2-state acceptor used as a *counterexample to the need for determinization*, not a substrate component; the implementer should keep it labelled that way.
5. **Name the discriminating follow-up for 711's plan, not for this task**: the first behavioural discrimination lives on a finitely presented infinite fibre (the E1 `pre/x/post` graph or a periodic one) with a per-time alphabet — exactly the quasimodel setting — where (d) must colour time pairs and (c) must write the MSO sentence. That is substrate work and belongs to 711.
6. **Sorry-free path exists**: every lemma the deliverable needs is already proved in the prototype on standard axioms; no `sorry`, no new axiom, no deferral.

## Decisions

- Tier 1 reference grounding applied (literature sources named in the dispatch); the mapping table above is the required artifact.
- Treated `lean_local_search`'s `warming` index as non-evidence of absence throughout; Mathlib absence claims rest on source grep + `lean_leansearch`.
- Built a compiled prototype in the research phase rather than reasoning about what the shapes would show: H2's formal-proof bar is met by `allPathsMeet_iff_lasso` (first verified candidate within the first 30% of calls: `Finite.exists_ne_map_eq_of_infinite` located by call ~22 of ~45; `infinite_ramsey_pairs` verified by call ~20).
- Did **not** set `user_decision`: the device question is the probe's to answer on evidence, and the research answers it with an explicit scope; whether 711 proceeds on a shape-scoped, infrastructure-based selection is a `/revise 711` matter the acceptance criteria already assign elsewhere.
- Kept the prototype under `specs/732_.../probes/` (precedent: `specs/706_.../probes/`, `specs/710_.../probes/`), not under `specs/evidence/`, so the research phase writes nothing in task 732's declared `file_scope`.

## Adversarial Self-Verification

### Claim Verification Table

| Claim | Source/Counterexample | Verification Method | Confidence |
|---|---|---|---|
| All seven dispatch-cited declarations exist at the named files | grep hits with line numbers (`PlusRayFibre.lean:116,169,271,290`; `path-quantifier-alternation.lean:159,167`; `stab-depth-stratification.lean:106`) + bounded `sed` reads of the statements | grep + Read (two methods) | High |
| The keystone is under `[F.IsRegular]`, not unconditional | `variable {F : TaskFrame} [F.IsRegular]` at `:106`; `variable {F : FrameOver intOrder} [F.IsRegular]` at `:282`; scope spec R1 bullet says the same | bounded read + scope-spec cross-read | High |
| `⊡(Fp)`'s universal summary over any finite step graph reduces to lasso paths by pigeonhole alone | `Probe732Proto.allPathsMeet_iff_lasso`, compiled, `#print axioms` = `[propext, Classical.choice, Quot.sound]` | `lake env lean` exit 0 | High |
| `⊡(Pp)` is the same statement on the reversed graph | `allBwdPathsMeet_iff_lasso := allPathsMeet_iff_lasso _ P w₀` compiled; consistent with `Probe719Backward.pastStab_iff_allBwdPathsMeet` header | `lake env lean` + sibling header read | High |
| The per-path "eventually `p`" acceptor is deterministic with 2 states | `detRun_accepts_iff`, compiled, `[propext, Quot.sound]` | `lake env lean` | High |
| Pigeonhole-tier lasso sufficiency fails on an infinite acyclic fibre | `not_lasso_sufficient_on_chain`, compiled, `[propext, Quot.sound]` | `lake env lean` | High |
| Infinite fibres are unavoidable for complete classes | `Probe710.not_finite_width_fmp` as cited by task 709's description and the scope spec R4 bullet; header of `backward-dual-asymmetric-fixture.lean` | two record reads; **not** re-compiled this session | Medium |
| `infinite_ramsey_pairs` exists, is self-contained, standard axioms | `lean_hover_info` at `RamseyFactorization.lean:146:9` gives the signature; `lean_verify` → `[propext, Classical.choice, Quot.sound]`, trust standard | `lean_hover_info`-confirmed type signature + `lean_verify` | High |
| Mathlib at this pin lacks infinite Ramsey for pairs | grep of Mathlib source (only Hindman, HalesJewett + false positives); `lean_leansearch` 6 results, none Ramsey; `RamseyFactorization.lean` header says the same | grep + `lean_leansearch` + in-tree docstring (three sources) | High |
| Mathlib at this pin has no ω-automata / Büchi / parity / Rabin / MSO | `Computability/` listing; grep for the terms → one false positive in `Topology/Order/Basic.lean` | grep + directory listing | High |
| No formalization of Safra/Piterman exists in any proof assistant | `SOURCES.md` D8 `:1030–1032` ("AFP topic listing enumerated directly") | single source, read | Medium |
| HWZ 2000 Theorem 15 covers `⟨ℤ,<⟩` via MSO and needs no Safra | chunk 0024 lines 88–94 (flow class 2 = `⟨ℤ,<⟩`); chunk 0007 lines 10–19 (Büchi and Rabin decidability theorems, non-elementary); `ztime-no-finite-carrier-fmp.md` §8 | two corpus chunks + context note | High |
| GKWZ Theorem 13.6 decides S5 × linear-time logics by MSO reduction with runs quantified universally | chunk 0589 line 61 ff.; chunk 0591 proof (runs `r : W → T_w`, coherent and saturated, set `R`); chunk 0353 line 5 ("another proof of the decidability of … PTL × S5 … Theorem 13.6") | three chunks | High |
| Kupferman–Vardi 2001 carries the rank-based, determinization-free complementation that Safraless builds on | chunk 0001 abstract; "rank" 40+ occurrences in chunks 18–23 | corpus read (abstract) + term count | Medium (body not read) |
| Büchi's classical complementation proof is Ramsey-based, so (c) and (d) share a core | background knowledge only | **not verified this session**; resolving check: Thomas 1997 (corpus, `thomas_1997_languages`) | Low — presented as framing, not as a finding |
| The Bool fixture's `IsFwdPath` is definitionally the prototype's `IsPath (Rf 0)` | both definitions read (`path-quantifier-alternation.lean:52`; prototype) | Read of both; **not** compiled as a bridge lemma | Medium |

### Contradiction Log

- **Apparent contradiction**: the dispatch frames (c) as *sidestepping* "machinery nobody has mechanized", while this report finds (c)'s Lean cost to *include* that machinery (Büchi's theorem). Resolution by precedence rule 4 (primary source over secondary framing): HWZ chunk 0007 lines 13–14 state the route rests on "the Büchi and Rabin decidability theorems"; GKWZ Theorem 1.28 names Büchi 1962 / Rabin 1969 as the source of MSO decidability. The dispatch's claim is true of *Safra specifically* (no Safra construction appears in HWZ) and is kept; the stronger reading — that (c) avoids ω-automata complementation altogether — is not supported by the primary sources and is not adopted. Not an unresolved contradiction.
- **Apparent contradiction**: the acceptance criterion asks the probe to compare devices "on the `⊡(Fp)`/`⊡(Pp)` shapes", while the compiled lemmas show those shapes are device-inert. Resolution: both hold; the probe can and should run the shapes (recording inertness as the result) and must add the falsifier to say anything discriminating. No source conflict; a scoping finding, surfaced in Recommendations 1–2.

### Recommendations modified after verification

- Initial draft recommendation was "select (d) at the pigeonhole tier for the probed shapes". After the infinite-fibre falsifier compiled, this was **downgraded**: pigeonhole-tier (d) is refuted as a general device, and the selection is restated as the time-axis (d)/(c) family with (d)'s in-tree Ramsey as the substrate and (c) as the literature frame.
- The "(c) and (d) are the same mathematics" framing was **demoted** from a finding to Low-confidence framing after noting it rests on un-re-read background (Thomas 1997); the resolving check is named.

## Literature Proof Structure

**Source**: Hodkinson, Wolter, Zakharyaschev, "Decidable fragments of first-order temporal logics", APAL 106 (2000), §4 (route (1)); book form GKWZ 2003 §11.3 and §13.2.

**Strategy** (HWZ §4 / GKWZ §11.3): satisfiability on a flow ↔ existence of a quasimodel (HWZ Thm 14 / GKWZ Lemma 11.22); write "a quasimodel for ϕ exists" as an MSO sentence `σ_ϕ` (HWZ chunk 0024 / GKWZ `qm_ϕ`, Lemma 11.23) whose unary predicates are `P_s` (one per realizable state candidate `s ∈ Σ`, partitioning the flow) and `R_ψ` (one per `ψ ∈ sub_x ϕ`, defining a run); decide `σ_ϕ` over the flow by Büchi (for `⟨ℕ,<⟩`, `⟨ℤ,<⟩`) / Rabin (GKWZ Thm 1.28).

**Step map and lean4 translation considerations**:

| Step | Source | Repository counterpart | Translation note |
|---|---|---|---|
| 1. Types and state candidates; `♯(ϕ)` bounds realizable ones | HWZ Defs 5–7 | slice/fibre labels (`ztime-no-finite-carrier-fmp.md` §8 table) | stratification (`plusTruthAt_iff_stratum_atomize`) is what makes `⊡`-values atomizable per state — the alphabet |
| 2. State function `f : W → Σ` | HWZ Def 10 | per-slice labelling | finite `Σ` is the finite alphabet every device needs |
| 3. Runs `r(w) ∈ f(w)` with `U`/`S` clauses | HWZ Def 11; GKWZ 13.2 "coherent and saturated" | the target path; `SeqPair` read time-indexed | the universal `⊡` is a quantifier over runs through the seam state — device-independent statement |
| 4. Quasimodel `⟨f, R⟩`, satisfiable iff quasimodel exists | HWZ Def 12, Thm 14 | time-sliced certificate | the certificate-completeness question the sliced class failed (`Probe710.not_sliced_complete`) — infinite fibres are forced |
| 5. MSO sentence `σ_ϕ`; Lemma 11.23 | HWZ chunk 0024; GKWZ chunk 0490 | none | (c)'s content; `∀R` absorbs `⊡`'s universal quantifier |
| 6. Decidability of MSO over `⟨ℤ,<⟩` | GKWZ Thm 1.28 (Büchi 1962) | none in Mathlib or tree | the mechanization cost of (c); cannot be cited under zero-debt |
| 6′. Ramsey tail-factorization alternative | Doets 1987 ch. 7 via `infinite_ramsey_pairs`; HWZ Lemmas 17, 21, 23 (splice, bounded realisation, ultimately periodic form) | `infinite_ramsey_pairs` proved; HWZ Lemmas 17/21/23 ↔ sliced-certificate pumping / pruning / tail stability (§8 table) | (d)'s content; the only step with in-tree substrate |

**Potential formalization challenges**: (i) `⊡` quantifies over *histories agreeing at a time*, which in quasimodel terms is a quantifier over runs through a fixed state candidate element — HWZ have no such operator and GKWZ 13.2's "agents who know the time" is the nearest analogue, so the correspondence is "what to read, not identity" (§8 note); (ii) the two-factor backward/forward structure means bi-infinite runs — HWZ's `⟨ℤ,<⟩` case is "similar" to `⟨ℕ,<⟩` in their §5 and carried in full only through the MSO route; (iii) `plusStab_iff_omega` measures `Classical.choice` via `worldHistoryOfStepPath`, so any device built on the ω-form inherits it.

## Tactic Survey Results

Tested by compiling `probes/device-probe-proto.lean` with `lake env lean` (three iterations; final exit 0, no warnings).

| Goal | Tactic / lemma | Result | Premises |
|---|---|---|---|
| lasso index wraps: `g (lassoIdx i j (n + (j - i))) = g (lassoIdx i j n)` for `j ≤ n` | `congr 2; rw [show n + (j - i) - i = (n - i) + (j - i) by omega, Nat.add_mod_right]` | closes | — |
| step at the wrap boundary with variable modulus | `Nat.mod_add_mod` after `show n + 1 - i = (n - i) + 1 by omega`; then `Nat.mod_eq_of_lt` / `Nat.mod_self` by cases on `r + 1 < j - i` | closes | `set r := …` **failed** (new occurrences not abstracted); working with the raw `(n - i) % (j - i)` succeeded |
| pigeonhole with all repeat indices positive | `Finite.exists_ne_map_eq_of_infinite (fun n => g (n + 1))` then `Nat.lt_or_gt_of_ne` | closes | shifting by one avoids `g 0 = w₀` re-entering the lasso |
| negating `∃ n, 0 < n ∧ P (g n)` | `simp only [not_exists, not_and] at hno` | closes | `push_neg` is deprecated at this pin (warning: "Prefer using `push Not`") |
| descending-chain path is `w₀ - n` | `induction n` + `push_cast; ring` | closes | `chainR` unfolded |
| no lasso on the chain | rewrite both sides by the closed form, `push_cast at h; omega` | closes | — |
| unused `[Finite S]` section variable in lemmas not needing it | `omit [Finite S] in` **before the docstring** | closes | placing `omit` between docstring and `theorem` is a parse error |

## Context Extension Recommendations

- **Topic**: device-inert formula shapes for universal path summaries.
  **Gap**: no context file records that single-operator `⊡(Fp)`/`⊡(Pp)` shapes are co-safety and hence decided by reachability/pigeonhole on finite fibres, so they cannot test complementation devices.
  **Recommendation**: add a short subsection to `.claude/context/project/logic/domain/ztime-no-finite-carrier-fmp.md` (§9 or a new §9a) naming the compiled lemmas and the infinite-fibre falsifier, so future probes choose discriminating shapes/fixtures.
- **Topic**: in-tree Ramsey substrate.
  **Gap**: `infinite_ramsey_pairs` lives under `WeakCanonical/GroupModel/` and is not mentioned by any decidability-side context file.
  **Recommendation**: a one-line pointer in `.claude/context/project/lean4/README.md` or the decidability domain index: "infinite Ramsey for pairs: `FormalSystem.Metalogic.WeakCanonical.infinite_ramsey_pairs`, absent from Mathlib at pin".

## Appendix

### Search queries used

- `lean_local_search`: `Ramsey` (12 in-tree hits, index `warming`), `Buchi` (no relevant hits, `warming`), `Automaton` (no relevant hits, `warming`), `exists_ne_map_eq_of_infinite` (hit: `Finite.exists_ne_map_eq_of_infinite`, `Mathlib/Data/Fintype/Pigeonhole.lean`).
- `lean_leansearch`: "infinite Ramsey theorem for pairs: every finite colouring of pairs of naturals has an infinite homogeneous set" → 6 results, none a Ramsey theorem (listed under External Resources).
- `lean_hover_info`: `RamseyFactorization.lean:146:9` → `infinite_ramsey_pairs` signature.
- `lean_verify`: `FormalSystem.Metalogic.WeakCanonical.infinite_ramsey_pairs` → `[propext, Classical.choice, Quot.sound]`.
- grep over `.lake/packages/mathlib/Mathlib`: `büchi|buchi|omega.automat|ω-automat|parity automat|rabin`; `ramsey`; `hindman`; `monadic second`.
- grep over corpus: HWZ chunks for `monadic second|Büchi|Rabin`; GKWZ chunks for `Theorem 13.6|Theorem 11.21|Büchi|monadic second-order`; KV 2001 for `rank`, `co-Büchi`.
- Repository greps: declaration names from the dispatch; `ramsey|büchi|buchi` under `FormalSystem/` and `specs/evidence/`; `E3`, `Ranking ratification` under `specs/`.

### References to documentation

- `scripts/check-evidence-probes.sh` (`:1–45` header, `:139–185` table and `WIRED`, `:245–262` `check_probe`).
- `specs/archive/721_decidability_programme_review_l_and_lplus/followup-scope-spec.md` (`:162–218` Section B; `:578–586` "The 711 tension"; `:587–651` "Ranking ratification").
- `.claude/context/project/logic/domain/ztime-no-finite-carrier-fmp.md` §8 "The published counterpart".
- `~/Projects/Literature/SOURCES.md` `:1006–1032` (D8).
- `specs/ROADMAP.md` `:60–110`.
- Issue log entries recorded this dispatch: two `kind: win` (in-tree Ramsey discovery; prototype compile).
