# Roadmap: BX Completeness and Publication

## Overview

TM is a bimodal logic combining S5 modality with irreflexive linear temporal logic,
axiomatized via the **Burgess-Xu (BX) system**. This roadmap describes the current
state of the completeness effort as of 2026-07-07 (multi-agent trajectory assessment:
git archaeology, sorry inventory, Rabinovich coverage mapping, convergence audit).
Header sections below are current; reference sections further down retain their
original dates and remain valid as historical/technical documentation.

**Architecture**: The proof system has 41 BX axioms organized in 6 layers:
propositional (4), S5 modal (5), Burgess-Xu temporal (26), modal-temporal
interaction (2), uniformity (4), and Prior-UZ/SZ (2, discrete-only). The temporal
semantics is **irreflexive**: G/H quantify over `t < s` / `s < t` (strict
inequality), and Until/Since require strictly future/past witnesses.

**Convention**: `untl(event, guard)` matches Burgess 1982 `U(α, β)` where α=event
(at witness), β=guard (at intermediates). Migrated by task 107 Phase 9.

**Completeness architecture**: The **Chronicle** path
(`FormalSystem/Metalogic/BXCanonical/Chronicle/`) is the primary and only
active path. The BXCanonical path (task 109) is dead code — its ~17 sorries are
mathematically false under irreflexive semantics and cannot be proved.

**Completeness programme: strong vs weak terminology and per-class targets** (2026-07-27,
settled; the in-tree authority is the module docstring of
`FormalSystem/Metalogic/StrongCompleteness.lean`):

- **Terminology.** "Strong completeness" is reserved, project-wide, for consequence from
  possibly-INFINITE premise sets: `Γ : Set Formula` with the finitary set-derivability relation
  `∃ L : List Formula, (∀ ψ ∈ L, ψ ∈ Γ) ∧ Derivable fc L φ`. Because `Context = List Formula`
  is finite, any finite-context consequence statement is inter-derivable with weak
  (single-formula) completeness through the deduction theorem
  (`Γ ⊨ φ ↔ ⊨ Γ.foldr imp φ`), and is therefore named **consequence completeness**, never
  strong. The former "main_strong_completeness" finite-context framing (still visible in
  `latex/subfiles/04-Metalogic.tex`) was misleading in exactly this way and is retired; the
  LaTeX restatement is owned by task 362.
- **For a finitary proof system, genuine strong completeness entails compactness** of the class
  consequence relation, so it is available exactly where that relation is compact. Per class:

  | Class | Weak completeness | Finite-context consequence | Genuine strong (`Set Formula`) |
  |---|---|---|---|
  | Base | open — task 169 | capstone task 362 | OPEN question — compactness research, task 361 |
  | Dense | open — task 170 | capstone task 362 | OPEN question — compactness research, task 361 |
  | Discrete | DONE (pristine axiom set) | capstone task 362 | **IMPOSSIBLE** — non-compact |
  | Dedekind | in flight — task 408 | task 408 (`consequence_completeness_dedekind`) | **IMPOSSIBLE** — non-compact |

- **Why Discrete is weak-only**: `ValidDiscrete` requires `IsSuccArchimedean`/
  `IsPredArchimedean`, and `next φ = untl φ bot` is a genuine next-step operator on discrete
  orders, so `{F p} ∪ {¬Xⁿ p : n ∈ ℕ}` is finitely satisfiable over `ℤ` yet unsatisfiable over
  every Archimedean discrete carrier — compactness fails, hence no strong form.
- **Why Dedekind is weak-only**: Reynolds 1992 Theorem 7 is *weak* completeness for the
  real-line axiomatisation and the restriction is genuine — the Dedekind-class consequence
  relation is not compact. Task 408's terminus pair was renamed accordingly (headline
  `completeness_dedekind`, corollary `consequence_completeness_dedekind`; formerly
  "strong_completeness_dedekind").
- **Why Base/Dense are open rather than settled**: neither binder list imposes
  Archimedean-ness, so the counterexamples above do not apply, and Burgess-style strong
  completeness for the classical ℚ tense logic suggests plausibility — but whether the full
  task-frame consequence relation (S5 box over shift-closed `Omega`, ordered-abelian-group
  time) is compact is genuinely open. The set-based MCS layer (`SetConsistent` — correctly
  finitary, `SetMaximalConsistent`, `set_lindenbaum`, in `Metalogic/Core/MaximalConsistent.lean`)
  already exists; the missing substantive piece is a **model-existence theorem** (every
  `SetConsistent` set satisfiable in a class frame), which does NOT follow from the
  single-formula countermodel engines. Task 361 owns the feasibility verdict, the per-class
  set-consequence/set-derivability definitions, and the sub-task decomposition.

---

**Current state** (2026-07-24, final assembly + axiom audit; supersedes the 2026-07-16 block
below, which is retained only as history):

- **The Kamp chain is COMPLETE and sorry-free.** All four chain declarations —
  `nf_nvar_exist_all_depths`, `nf_characterizable_temporal_prior`,
  `kamp_prior_expressive_completeness` (Kamp/KampPrior.lean) and
  `US_expressively_complete_over_prior` (WeakCanonical/PriorExpressiveness.lean) — kernel-verify
  (`lake env lean` + `#print axioms`, authoritative over LSP-level checks) to exactly
  `[propext, Classical.choice, Quot.sound]`. This supersedes the 2026-07-16 block's "exactly
  ONE live proof-term sorry" claim: the k≥2 residual was retired by the ζ-wire
  (`kampArm_zeta`, `translate_uniformFin`, `Kamp/ZetaUniformExtract.lean` and siblings), and
  with it the Rabinovich coverage table's "sole open gap" row (Cor 5.4, k≥2 converter) is
  CLOSED.
- **`completeness_discrete` is sorryAx-free with the pristine axiom set**
  `[propext, Classical.choice, Quot.sound]` — Branch A of the task 375 native_decide
  adjudication: all 7 in-cone `native_decide` sites were swapped on first attempt
  (1 → `rfl` in `Syntax/Formula.lean`; 4 → `decide` + 2 → `rfl` in
  `Syntax/SubformulaClosure/TemporalFormulas.lean`), fallback ledger EMPTY, no compile-time
  blowup. `completeness_dense` byte-lists the same pristine set.
  `Lean.ofReduceBool`/`Lean.trustCompiler` are gone from the profile of every named theorem.
- **Live Kamp-zone statement-position sorry count: 0.** The EANegation bracket-backward pair
  is archived to `Kamp/Boneyard/EANegationVBracketBackward.lean` (task 359). The task 375
  audit's fresh scans confirm: 0 statement-position sorry/admit hits in `WeakCanonical/Kamp/`
  (Boneyard excluded) and 0 `axiom` declarations in `WeakCanonical/`.
- **Base `completeness` sorryAx residue is isolated and outside the Kamp scope**: its sole
  source is the deprecated `WeakCanonical.countermodel_discrete` (`Transfer.lean:1277`) —
  task 386 finding, stated here precisely; it is not Kamp-chain debt and was deliberately not
  fixed by task 375.
- **Batch deltas folded in**: **384** — flagship status docs fixed
  (the live Metalogic aggregator, `BXCanonical/Completeness.lean`); **385** — orphan triage:
  20 orphaned files archived to Boneyards, and the dead top-level aggregator then at
  `Theories/Bimodal/Metalogic.lean` (pre-rename path; this file was deleted outright and has
  no `FormalSystem/` equivalent) removed under the never-built Boneyard policy. The live
  surface, formerly `Metalogic/Metalogic.lean`, is now `FormalSystem/Metalogic.lean`;
  **386** — general `completeness` re-pointed, with its debt isolated to the
  deprecated discrete branch above; **359** — Boneyard hygiene (EANegation pair archived);
  **375** — Rabinovich fidelity audit verdict **ALIGNED** (no unmotivated drift), plus the
  Branch A adjudication above; all doc surfaces are now byte-consistent with measured axiom
  sets (adjudication recorded in the Axiom Classification block of
  `BXCanonical/Completeness.lean`).
- **Open remainders, with owners**: faithful Dedekind carrier relativization
  (attained-vs-Dedekind, `HasAttainedINF/SUP`) — task **378**; `F` stage-index cleanup —
  future work (descoped by task 359, currently unowned); optional `native_decide` hygiene for
  the 4 out-of-cone sites in `Metalogic/Decidability/SignedFormula.lean`
  (`:126,:132,:133,:138`) — unowned, explicitly outside task 375's charter.

---

**Current state** (2026-07-16, post-adjudication — **SUPERSEDED by the 2026-07-24 block above,
retained only as history**; supersedes the 2026-07-12 and 2026-07-07 blocks
below, both of which are retained only as history — **their owner, line numbers, and dispatch
estimate are all retired**):

- **Kamp and discrete completeness are ONE chain with ONE blocker.** `kamp_prior_expressive_completeness`
  (Kamp/KampPrior.lean:697) *is* the Kamp theorem for Prior structures (Rabinovich 2014 Thm 4.4)
  **and** is step 6 of the discrete-completeness chain: Reynolds' route needs US-expressive-completeness
  to eliminate chronicle gaps. `completeness_discrete` has **no sorry of its own** — it inherits Kamp's.
- **Exactly ONE live proof-term sorry**, in `nf_nvar_exist_all_depths` (Kamp/KampPrior.lean, decl
  `:346`, sorry in the `k+2` arm): the **k ≥ 2 residual**. All 7 other steps of the chain are
  sorry-free. Recorded axioms for `completeness_discrete`:
  `[propext, sorryAx, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler, Quot.sound]`
  (`ofReduceBool`/`trustCompiler` are `native_decide`-class and benign).
- **Two obligations closed since 2026-07-12**: the `n+2` arm is **retired** by domain restriction
  (`nf_nvar_exist_all_depths` now takes `hn : n ≤ 1`; the arm discharges via `absurd hn2 (by omega)`),
  and the `n=1` arm is **narrowed** — `kampPrior_case1_arm_k0` (`:271`) and `kampPrior_case1_arm_k1`
  (`:301`) are discharged and axiom-clean. The live sorry ledger went **2 → 1**.
- **But the residual hardened, and is the reason the old estimate is retired.** Re-adjudicated
  2026-07-15 on machine-checked, axiom-free evidence (`KampPrior.lean:517-561`;
  `specs/377_transcribe_rabinovich_faithful_nf_encoding/reports/06_kampprior-520-adjudication.md`):
  it is an **arity cap, not a missing lemma**. The k≥2 gate demands an **arity-4** joint type over
  `(x1,w,x,t)` guarded only by a lossy **unary** point type. Rabinovich has no arity-4 object in 16
  pages (Def 3.1 p.4 one variable; Lemma 3.2(2) p.4 ≤2 free variables; Def 4.1 p.5 unary E[Σ]) —
  **the unary producer is faithfulness; the arity-4 consumer is the off-paper party.** The gluing
  escape is closed: `chain_split` needs a path-shaped constraint graph, but `AtomKind.order`
  (NormalForm.lean:60) makes an arity-4 NF the complete graph K₄, so cutting at the anchor separates
  nothing (both directions machine-checked). The existing arity-4 producer `kampPrior_hreal_supply`
  is landed but **unwired, circular** (InteriorGateGeneralK.lean:1541) and **fiber-refuted**
  (ExteriorPinnedProbeM1K.lean:816).
- **Root defect is upstream of the k≥2 arms.** `nf_eval_nf` (NormalForm.lean:199-207) grows
  environment arity `n → n+1` at **every** depth descent, so the arity-4 obligation is generated by
  the evaluator that appears in the *statements* of the whole chain — it is not local to the arms.
  Rabinovich never grows arity: processed depth folds into the signature as a unary E[Σ]-atom
  (Def 4.1), making the ≤2-cap hold by construction (Prop 4.3 composition is structural, which is
  why no Feferman-Vaught is ever needed). **The faithful substrate already exists, sorry-free and
  unadopted**: `Kamp/NfEFold.lean` (688 lines) lands the fold type and evaluator, with
  `EAtomDom sig k n := ZoneSpec n × NormalForm sig k 1` making the ≤2-cap a *type-level invariant*.
  Its own docstring states the correct diagnosis; task 376's abandonment record confirms it.
- **Distance to done, honestly**: mechanically one declaration; substantively one **re-architecture
  of unknown size** onto Def 4.1 / Prop 4.3. This is the **third** attempt at this obligation —
  task 358 abandoned, task 376 abandoned *for this exact defect* ("the engine was novel mathematics,
  and the refutations were the compiler correctly rejecting a false statement"). The 2026-07-07
  framing of "~11-18 focused dispatches, a bounded endgame, not an open research problem" **no longer
  holds** and should not be used for planning.
- **Owner**: **task 379** (`/research 379 --hard --lit`). Its charter must be sized against the
  `nf_eval_nf` encoding, not only the k≥2 arms. Its quarantine-first step (excise/Boneyard the
  unwired arity-4 Fib stack, which reads as nearly-wired-up while being circular and fiber-refuted)
  is mandatory. Two hard prohibitions: no arity-4 `hreal` discharge; no Feferman-Vaught.
- **Retired as dead** (2026-07-16 review): tasks **303**, **305**, **307** — all abandoned. 303 and
  305 targeted `existPart_succ_n1_bypass` / `KampBypass.lean`, Boneyard'd since task 305 Phase 0;
  305's transcription scope was already landed sorry-free (~1,902 lines); 307's decisive question was
  answered as outcome (b) by the adjudication. Tasks **95**, **299**, **375** now depend on **379**.
- **Hold**: task **341** (carrier-layer refactor) until 379 settles which route survives.
- **Full detail**: `specs/reviews/review-2026-07-16.md`.

---

**Current state** (2026-07-07, multi-agent assessment; supersedes the 2026-06-16 block):
- **Soundness**: Sorry-free for all 3 variants (general, dense, discrete) including Prior-UZ/SZ and Z1
- **FMP completeness** (`fmp_completeness`): Sorry-free
- **Dense completeness** (`countermodel_dense`): Internally sorry-free
- **Discrete completeness**: `completeness_discrete` (BXCanonical/Completeness.lean:276) is blocked by exactly TWO live sorries, both inside `nf_nvar_exist_all_depths` (KampPrior.lean:212): the `n=1` arm at **KampPrior.lean:351** (the mathematical content — the depth-k≥2 Cor 5.4 F_i-chain converter) and the `n+2` arm at **:354** (commented "off the critical path" but in the same declaration, so it formally taints downstream; provable-or-refactorable since the main theorem needs only n=0,1). Everything else on the chain — Reynolds pipeline, `GoodStructuresModelSurgery`, `US_expressively_complete_over_prior`, `kamp_prior_expressive_completeness` — is sorry-free.
- **NOTE — stale references**: `KampBypass.lean` no longer exists (Boneyard'd, task 305 Phase 0); the former `existPart_succ_n1_bypass` sorry chain and the "task 303 critical path" below are HISTORICAL. The Stavi chain (StaviCompleteness/EFGames) is superseded by the Kamp route and parked off the live path.
- **All other Metalogic sorries (~44 sites) are parked or dead-path**: EANegation.lean:1090/:1249 (uniform-backward variants, documented non-blocking), reflexive TruthLemma variants, Bundle BFMCS (abandoned), EFGames/Stavi (superseded), Boneyard. `NfMultiAnchorBridge.lean` (7,572 lines, the active workface) carries **0 sorries** — all NO-GO verdicts live as prose records and machine-checked refutation theorems, not debt.
- **k=0 case**: fully sorry-free (task 273, June). **k=1 case**: fully sorry-free — `bracketEndChar_k1v_sound` (:2338) / `_complete` (:2979) + kit (tasks 310/311); this is the proven template for all current work.
- **k=2 correctness pair (tasks 321→324→325)**: in flight. Task 325 v2 Phase 1 landed (commits `be865449c`/`72c34be83`): nine-zone-gate VVecEA2 carrier `kvE_subBracket2V` with machine-checked NON-VACUITY pair (`kvE_subBracket2V_gate_holds_of_honest`/`_nonvacuous`) green — structurally excluding the vacuous-carrier failure class. Soundness re-drive + completeness pending.

**Critical path** (2026-07-07): task 325 v2 (driven soundness+completeness pair over the nine-zone VVecEA2 carrier, ~3-4 dispatches) → task 321 v4 (wire the pair into the outer `bracketEndChar_kvE2` gate, ~4-6 dispatches) → task 309 Phases 13.4/14 (general-k one-step correctness + KampPrior:351 rewire, ~2-4 dispatches) → KampPrior:354 n≥2 arm (generalize or restate for n≤1, ~1-2 dispatches) → final assembly + axiom audit (~1-2 dispatches). **Total: ~11-18 focused dispatches to a sorry-free `completeness_discrete`** — a bounded endgame, not an open research problem. Pre-authorized fallback if the carrier fails a fourth gate-class failure (retrospective Rec-1, "no fifth carrier"): Option B interval-typed EA-formula rebuild with witness-count induction (~700-1050 lines, scoped in 305/reports/37 §4.4).

**Trajectory & convergence** (2026-07-07 audit): 344 commits on Kamp/ since June 11, +51.8k/−29.4k lines (churn/net ≈ 3.6×), two Boneyard resets (June 16/23, ~13.9k lines of abandoned bypass infrastructure). Three consecutive k=2 carrier failures share one gate/correctness class — 321 Phase 8 (upward-only chain, missing correctness-pair architecture), 324 Phase 6 (false-∀M completeness converse, wrong codomain), 325 v1 (7-zone gate unsatisfiable, vacuous soundness) — but the sequence is **converging, not thrashing**: diagnosis latency collapsed from ~3 weeks (303/305 era) to hours (all three 07-07 failures diagnosed and answered same-day); failures narrowed monotonically (architecture → codomain shape → finite-set enumeration bug); machine-verified refutation probes replaced speculative pivots; asset reuse is rising (324's zone/extraction kit survives verbatim into 325; v2 edits only the gate + two point-types); and each failure class is mechanically fenced off once seen (driven-proof discipline after 321; mandatory non-vacuity gate after 325 v1). Root obstruction across all eras (H4-verified retrospective, 322/reports/02): a property relating two independently-chosen points cannot be asserted by a single-point formula — the arity-≤2 E[Σ]-fold machinery (task 310) exists precisely to manage this, and its one remaining exposure is the symbolic-k generalization in task 309 Phase 13.4.

**Rabinovich 2014 coverage** (paper → Lean, the best distance-to-done proxy):

| Paper artifact | Lean counterpart | Status |
|---|---|---|
| Def 3.1 (∃∀-formulas, point/segment types) | `VecEAFormula.lean`, `ExistsForallNF.lean` | sorry-free |
| Lemma 3.2 (closure + arity-≤2 firewall) | `VecEAClosure.lean`, `VecEAArityFirewall.lean` | sorry-free |
| Prop 3.5 (V-∃∀ → TL translation) | `RabinovichTranslation.lean`, `VecEATranslation.lean` | sorry-free |
| Def 4.1 (E[Σ]-fold normal form) | `NfEFold.lean` (task 310) | sorry-free |
| Prop 4.2 (negation closure, ≤2 vars) | `EANegationClosure.lean`, `EAVecNegationClosure.lean` | sorry-free (model-dependent form) |
| Lemma 5.1 (bracket-pattern negation) | `EANegationClosure.lean:401` | sorry-free (forward; syntactic backward parked, non-blocking) |
| Lemma 5.3 (base case, arrangements/segments) | `IntervalPattern`, `bracketFromLists`, k1v carrier | sorry-free at k=1 |
| Cor 5.4 (F_i chains) | `fChainFrom`/`fChainPred` (EANegation:552/567), k1v instance | k=1 CLOSED; **k≥2 converter = the sole open gap** — owner **379** (2026-07-16; the cited tasks 321/324/325 are expanded/archived and the `:351` anchor has drifted — see the current-state block above) |

Every paper artifact has a landed sorry-free counterpart except the depth-k≥2 instance of the Cor 5.4 chain converter — exactly where all current work is concentrated. By this proxy the formalization is in its last chapter.

**Key architectural finding** (task 155, 7 research agents + 4 succ_cofinal agents, 2026-05-28/29):

`succ_cofinal` is **UNPROVABLE** by the current approach. The constant-MCS gap scenario (all MCS labels identical) is consistent with ALL temporal axioms including Z1 and Prior-UZ. Six mathematical strategies were evaluated (well-founded measure, stage induction, constant-MCS exclusion, frozen guard, direct construction, infrastructure audit) — all fail because the limit-domain successor is non-constructive (Classical.choose) and the construction's point-placement does not respect limit-domain predecessor ordering.

**Reynolds BYPASSES succ_cofinal entirely.** His completeness proof (Reynolds 1994) never establishes that the chronicle is Z-isomorphic. Instead:
1. Build the chronicle (countable discrete linear order with MCS labels)
2. Prove all points are in one contemporaneous equivalence class via **Theorem 14** (gap elimination using US expressive completeness)
3. Transfer to a Z-model via **k-equivalence** (Theorem 6 / EF games)
4. The Z-model satisfies the same bounded-depth monadic sentences
5. Build the countermodel from the Z-model

The current architecture tries to prove the chronicle IS Z (via `IsSuccArchimedean → succ_embed_surjective`), which is the wrong approach. Task 202 implements the Reynolds bypass: connect the chronicle's formula structure to k-equivalence using the EF-game expressiveness infrastructure built in task 155.

**Sorry chain** (verified 2026-07-07; the former terminus `existPart_succ_n1_bypass` /
`KampBypass.lean` no longer exists — Boneyard'd by task 305 Phase 0):
```
completeness_discrete (BXCanonical/Completeness.lean:276)
  → countermodel_discrete_reynolds_v2 (IntegerModel/ReynoldsBridge.lean:724, sorry-free)
    → GoodStructuresModelSurgery (sorry-free)
      → US_expressively_complete_over_prior (PriorExpressiveness.lean:346, sorry-free)
        → kamp_prior_expressive_completeness (KampPrior.lean:480)
          → nf_characterizable_temporal_prior (KampPrior.lean:397)
            → nf_nvar_exist_all_depths (KampPrior.lean:212)
              → sorry at :351 (n=1 arm — the depth-k≥2 F_i-chain converter)
              → sorry at :354 (n+2 arm — same declaration, needs proof or n≤1 restatement)
```
Note: The old sorry chain through `chronicle_gap_contradiction → succ_cofinal →
succ_embed_surjective` is DEAD CODE — not on any live call path to `completeness_discrete`.
The `succ_cofinal` chain remains in ChronicleToCountermodel.lean but is only used by
`cantor_bfmcs_discrete_restricted_tc/fuc` which are used by `countermodel_discrete_enriched`
(not the live `completeness_discrete` path).

**WARNING — anti-pattern**: A "direct `IsSuccArchimedean` proof" (bypassing `chronicle_gap_contradiction`) is **not how it goes in the literature and must be avoided**. Reynolds 1994 (Sections 8–9, Theorem 15) never proves `IsSuccArchimedean` for the limit domain at all. His approach is: `one_class` (all points in one contemporaneous equivalence class) → very good → good → ≡k integer structure via lexicographic sums (Lemma 16). The `one_class` theorem is already proved sorry-free in `NoGapsDiscreteProof.lean`. The formalization's `IsSuccArchimedean` dependency is an artifact of building a succ-embed into ℤ and proving surjectivity — a construction the literature avoids entirely. Any plan proposing to "directly prove `IsSuccArchimedean`" is solving a problem that should not exist.

**WARNING — anti-pattern (task 273)**: A "discrete bypass" strategy — replacing `stavi_expressive_completeness` (general) with `discrete_stavi_expressive_completeness` (requires `IsSuccArchimedean`) inside `US_expressively_complete_over_prior` — **is architecturally unsound and must not be attempted**. The reason: `US_expressively_complete_over_prior` is used by `gap_prior_UZ_contradiction` (`GoodStructuresModelSurgery.lean:1266`) on a model M that has `SuccOrder + PredOrder + NoMaxOrder + NoMinOrder + semantic_prior_UZ/SZ` but does **NOT** have `IsSuccArchimedean`. The whole purpose of that theorem is to derive a contradiction that PROVES the model is `IsSuccArchimedean`. Using a discrete-only expressive completeness theorem to prove discreteness is circular.

**The literature's approach (GHR93 Section 8, Reynolds 1994)**: Stavi expressive completeness ({U,S,U',S'} for all linear time) is proved via EF games (Theorem 6 + Proposition 7) with **no discreteness assumption**. Prior-UZ/SZ then eliminates U'/S' (always false on Prior structures — proved sorry-free in PriorExpressiveness.lean). The model surgery argument uses {U,S} expressive completeness to show all equivalence classes agree, deriving the contradiction that establishes IsSuccArchimedean. This chain requires the GENERAL `stavi_expressive_completeness`, not a discrete-only version.

**Stavi sorry chain** (HISTORICAL — superseded 2026-06/07: the live path now routes
`US_expressively_complete_over_prior` through the Kamp/Rabinovich pipeline
(PriorExpressiveness.lean:24 "bypasses the sorry-tainted stavi chain entirely");
the EFGames/Stavi sorries are parked off the live path. Original 2026-06-09 record:):
```
nf_2var_existential_transfer (StaviCompleteness.lean:2353, 2435)
  → nf_2var_from_interval_data
  → nf_exist_sf_guarded_backward (StaviCompleteness.lean:2805)
  → nf_2var_exist_sf_classical → nf_characterizable_by_stavi
  → stavi_expressive_completeness (GHR93 Theorem 9.3.1)
  → US_expressively_complete_over_prior (PriorExpressiveness.lean:384)
  → gap_prior_UZ_contradiction (GoodStructuresModelSurgery.lean:1169)
  → no_gaps_discrete_model_surgery → completeness_discrete
```
Root sorry: `nf_2var_existential_transfer` at the `j'+1` case, which needs 4-variable existential transfer to prove 3-variable NF agreement. The fix (task 273, plan v12): prove a **generalized existential transfer** by strong induction on depth j, universally quantified over arity n. This is GHR93 Proposition 7 transliterated to NF types. At each inductive step, `zone_match_witness` provides the matching point, and the IH at lower depth (with higher arity) provides the transfer. Terminates because depth strictly decreases. No IsSuccArchimedean needed.

**Sorry summary (HISTORICAL — see the 2026-07-07 "Current state" block above for the
live inventory: 2 live sorries at KampPrior.lean:351/:354, ~44 parked/dead-path)**:

*Discrete branch (Reynolds pipeline — tasks 139, 140; since RESOLVED — ReynoldsBridge
and GoodStructuresModelSurgery are sorry-free as of 2026-07-07)*:
- 3 sorries in `NEquivalence.lean`: `ktype_finite`, `k_type_of`, `finite_types` (KEquivalenceFramework) — task 139
- 2 sorries in `Table.lean`: `table`, `table_depth_bound` — task 140
- Chronicle fallback in Transfer.lean pending truth transfer — task 140 (note: `Transfer.countermodel_discrete` at Transfer.lean:1256 is now DEPRECATED with an explicit sorry at :1270 — dead BX pipeline, off the `completeness_discrete` path)

*Canonical model (task 141 -- RESOLVED, not on critical path)*:
- 6 sorries in `TruthLemma.lean`: Until/Since forward/backward (4) + truth lemma cases (2) — non-critical-path, parametric truth lemma handles via BFMCS coherence
- 0 sorries in `ReflexiveCanonical.lean`: `reflCanR_linear` and `canS5R_symm` closed

*Mixed case (task 142 — RESOLVED)*:
- 0 sorries: `dd_countermodel_chronicle_mixed_sorry` eliminated via `mcs_mixed_case_absurd` + structural axiom `discrete_box_necessity` (U(T,bot) → □(U(T,bot))). The mixed case is impossible because S5 + K-distribution + the new axiom's contrapositive derive □(F'T) from ¬□(U(T,bot)), contradicting ¬□(F'T).

*Legacy (task 122)*:
- `dd_countermodel_chronicle_nondense_sorry` (line 839): Discrete BFMCS on ℤ

**Planned evolution** (after sorry-free completeness):
- **Phase 2 — Frame hierarchy + axiom cleanup**: Four-tier hierarchy Base → Dense/Discrete → Integer with Sahlqvist correspondence (task 126). Density axiom `GGp→Gp`, discreteness axiom `U(⊤,⊥)`. Then remove TF (task 124), remove A4a (task 115), redefine G/H/F/P via U/S (task 116). Reduces primitives to {S, U, □, →, ⊥}.
- **Phase 3 — Expressive extensions**: Time addition operator (+) for FO[<,+] expressiveness (task 127). Open set/interior operator for dense/continuous frames (task 128).
- **Phase 4 — Algebraic representation**: Jónsson-Tarski representation theorem for the BAO with binary S/U and unary □ (task 125). Builds on Venema 1993 (Anti-Axioms), leveraging orthodox axiomatizability for ultraproduct closure.
- **Phase 5 — Publication quality**: Verification audit (task 95), genuine truth_at completeness (task 8).

**Sorry summary (dead code)**: ~17 sorries in the BXCanonical/Bundle/Quasimodel/Filtration pipeline are mathematically false under irreflexive semantics (they assume reflexive G/H). These are bypassed by the Chronicle approach and should be archived.

BXCanonical sorries (task 109 Phase 1 removed 4 dead-code sorries from CanonicalModel):

| Category | Count | Files | Status |
|----------|-------|-------|--------|
| **Critical path** (blocking `completeness`) | 5 | `RootScopedChain.lean` | **OPEN** (task 109) |
| **Irreflexive-consequence** (BX1 removal artifacts) | 14 | Frame, TruthLemma, CanonicalModel, Construction, Realization, SigmaOrdering | **OPEN** (task 109) |
| **Total BXCanonical** | **19** | 7 files | |
| Oracle replacement (qm_bfmcs) | 6 | archived to Boneyard/OracleCoherence.lean | **ARCHIVED** (2026-04-18) |
| Legacy strict-semantics files | 107 | archived to Boneyard/StrictSemanticsLegacy/ | **DONE** (task 94, 2026-04-12) |

The 5 critical-path sorries in `RootScopedChain.lean` (lines 1065, 1092, 1099, 1107, 1114)
block `dd_countermodel`, which `Completeness.lean` delegates to for the completeness proof.
The 18 irreflexive-consequence sorries are artifacts of the BX1 removal (e.g., `bx_le_refl`,
`g_content_subset_self`, `refl_intro_until_mcs`, `sigma_le_refl`) that need redesign under
irreflexive semantics.

**BXCanonical dependency chain**: `fwd_chain_forward_F` -> `restricted_tc` -> `restricted_buc` -> `restricted_fuc`.

Chronicle sorries (task 107, updated 2026-05-08):

| Category | Count | Files | Status |
|----------|-------|-------|--------|
| **Density g-value consistency** | 1 | `CE.lean:3570` | **OPEN** (task 117 — remove Cantor iso, direct truth lemma, representation theorem) |
| **Total Chronicle (critical path)** | **1** | 1 file | |

Task 117 approach (researched 2026-05-08, 3 rounds): The sorry is genuinely
unprovable (Zorn operates on CUD, not SDC — g-values can be inconsistent).
The dependency chain: `cantor_iso` requires `DenselyOrdered X` requires
`limit_dom_dense` requires the density case in CE requires `SetConsistent g`
(the sorry). The `.density` counterexample kind is the ONLY code path needing
`SetConsistent g` — C4a/C5a explicitly use `lemma_2_8` which avoids it
(documented at CE:1026, 1607, 2105, 2631).

Fix: replace the Cantor isomorphism (bijection X ≅ ℚ, requires density)
with the natural inclusion X ⊂ ℚ (injection, requires nothing). Archive the
Cantor iso pathway and density case to `Boneyard/DenseChronicle/` for future
reuse in the dense variant. Extend `limit_f` from X to all of ℚ for non-domain
rationals. D = ℚ as before — existing parametric infrastructure unchanged.
See "Representation Theorem Goal" for the full architecture.

Closed by task 107 (Phases 1-9, 2026-04-25 to 2026-05-08):
- Phase 6: 2 ChronicleConstruction.lean C5 sorries closed via `witness_not_old` tracking
- Phase 7: `NoUnivBurgessR3` deleted (unprovable in J₀); C1 changed to CUD; 4 g-value sorries closed via Burgess's lemma_2_8 method; `BurgessR3Maximal_bot_not_mem` sorry-free
- Earlier phases: 7 c2' sorries, 2 C4 hard cases, 2 FUC sorries, 6 NoUnivBurgessR3 stubs — all closed

### Burgess 1982 Alignment Migration

**Ambition**: Migrate all Chronicle definitions to match Burgess 1982 exactly — using `ClosedUnderDerivation` (Burgess's "DCS") throughout rather than `SetDeductivelyClosed` (our stronger variant adding consistency).

**Completed alignment work**:
- BurgessR3Maximal maximality clause: changed from `SetDeductivelyClosed D` to `ClosedUnderDerivation D` (matching Burgess's maximality over ALL deductively closed sets)
- BurgessR3Maximal first conjunct: changed from `SetDeductivelyClosed B` to `ClosedUnderDerivation B` (matching Burgess's DCS = just closed under derivation)
- CUD helper variants added: `cud_contains_theorems`, `cud_modus_ponens`, `cud_conj_closed`

**Remaining divergences** (post-completion cleanup):
- c1 (Chronicle condition): still uses `SetDeductivelyClosed` for g-values; Burgess just needs CUD. Not a blocker (Zorn always produces consistent g-values) but stronger than necessary.
- Two-track r-relation: `rRelation`/`r3Relation` (obligation-propagation, monotone in B) vs `burgessR`/`burgessR3` (content-based, anti-monotone in B). Burgess has only the content-based version. c2 uses `r3Relation` (non-Burgess); c2' correctly uses `burgessR3`.
- Helper function signatures: ~20 helpers still take `SetDeductivelyClosed` parameter but only use the `ClosedUnderDerivation` part internally. Mechanical refactor.
- Convention: `untl(event, guard)` = Burgess `U(event, guard)` — aligned by task 107 Phase 9. No longer swapped.

**Migration steps in current plan**:
- Phase 4: Close NoUnivBurgessR3 stubs (bot-guard argument)
- Phase 5: EliminationResult restructuring (capture B/B'/B'' from Lemmas 2.4/2.6)
- Phase 6: C4/C4' hard cases with h_c2' parameter restoration
- Post-completion: CUD-ify helper signatures, unify r-relation tracks, c1 relaxation

**Key finding (task 107 report 25, 2026-04-25)**: The codebase's C4 definition had its arguments
SWAPPED relative to Burgess 1982 C4a. Burgess checks the EVENT (first arg of U) at f(y) and
negates the GUARD (second arg) at f(z). The codebase was checking the GUARD and negating the EVENT.
This caused forward_G to be unprovable from C4+C0 (producing φ.neg.neg instead of ⊥), leading to
25 rounds of workaround attempts involving g_ordered, two-sided seeds, and duality arguments.

With the corrected C4: G(φ) = ¬(⊤ U ¬φ). C4 checks ¬φ (EVENT) at f(y), gives ⊤.neg = ⊥ at f(z).
⊥ in MCS contradicts C0. **One-step proof of forward_G.** g_ordered is unnecessary and has been
deleted from ChronicleInvariant. The `g_content_chain_property` blocker (report 17) is resolved.

**Key finding -- density axiom** (task 107 report 11): Dense domains (e.g., Q) are WRONG for
general completeness. GGp->Gp is valid on Q but not derivable in BX. Burgess uses sparse
X ⊂ Q. The representation theorem goal (D=Rat, totally ordered abelian groups) accepts GGp->Gp
as valid for that specific frame class. General completeness (all strict linear orders) requires
sparse X where GGp->Gp may fail.

**Key finding -- left_mono_until_G** (task 107 report 45, Phase 5b): Guard strengthening
under G-information (`G(φ→χ) → (φUψ) → (χUψ)`) is needed for the g_content(A)⊆B
maximality argument. This axiom captures the semantic fact that open-guard intervals (t,s)
are covered by G-information (since (t,s) ⊂ (t,∞)). It subsumes BX2 under open-guard
semantics (the pointwise conjunct is redundant). Added as BX2H/BX2H' in task 107 Phase 5b.

**Key finding -- ClosedUnderDerivation** (task 107 handoff 48, Phase 5b-i): Burgess 1982
and Xu 1988 define DCS as "closed under derivation" WITHOUT consistency. The codebase's
`SetDeductivelyClosed` bundled consistency, excluding Set.univ from BurgessR3Maximal's
maximality quantifier. Splitting into `ClosedUnderDerivation` (closure-only) and refactoring
`SetDeductivelyClosed = SetConsistent ∧ ClosedUnderDerivation` aligns the formalization with
the literature and enables the inconsistent-case proof of g_content(A)⊆B.

See sections below for the axiom system, irreflexive semantics, canonical
construction, sorry inventory, and the Burgess-Xu Until-induction proof strategy.

---

## BX Axiom System

`FormalSystem/ProofSystem/Axioms.lean` defines 42 axiom constructors in
six layers (see `Axioms.lean:55-59` for the Burgess 1982/84, Xu 1988, and Venema 1993
references; Reynolds 1992 is cited inline at `Axioms.lean:309`, not in that block). Under
irreflexive semantics (strict `<` for G/H,
strict witness for U/S), the axiom set replaces BX1/BX1' (reflexive T) with
seriality axioms and removes BX8/BX8' (not sound under irreflexive Until/Since).

### Layer 1: Propositional (4)

| Axiom | File:Line | Statement | Role |
|-------|-----------|-----------|------|
| `prop_k` | Axioms.lean:71 | `(φ → (ψ → χ)) → ((φ → ψ) → (φ → χ))` | Intuitionistic K |
| `prop_s` | Axioms.lean:75 | `φ → (ψ → φ)` | Weakening |
| `ex_falso` | Axioms.lean:78 | `⊥ → φ` | Ex falso |
| `peirce` | Axioms.lean:81 | `((φ → ψ) → φ) → φ` | Classical |

### Layer 2: S5 Modal (5)

| Axiom | File:Line | Statement | Role |
|-------|-----------|-----------|------|
| `modal_t` | Axioms.lean:86 | `□φ → φ` | Reflexivity |
| `modal_4` | Axioms.lean:89 | `□φ → □□φ` | Transitivity |
| `modal_b` | Axioms.lean:92 | `φ → □◇φ` | Symmetry |
| `modal_5_collapse` | Axioms.lean:95 | `◇□φ → □φ` | S5 characteristic |
| `modal_k_dist` | Axioms.lean:98 | `□(φ → ψ) → (□φ → □ψ)` | Normal modality |

### Layer 3: BX Temporal (24)

| Axiom | File:Line | Statement (future direction) | Role |
|-------|-----------|------------------------------|------|
| `temp_k_dist` | Axioms.lean:107 | `G(φ → ψ) → (Gφ → Gψ)` | K for G |
| `temp_4` | Axioms.lean:112 | `Gφ → GGφ` | Transitivity; needed for `bx_le_trans` |
| BX1 `serial_future` | Axioms.lean:117 | `T → F(T)` | Seriality (replaces reflexive T) |
| BX1' `serial_past` | Axioms.lean:122 | `T → P(T)` | Mirror seriality |
| BX3 `right_mono_until` | Axioms.lean:139 | `G(φ→ψ) → ((χUφ)→(χUψ))` | Right monotonicity |
| BX3' `right_mono_since` | Axioms.lean:143 | mirror for S | |
| BX4 `connect_future` | Axioms.lean:150 | `φ → G(P(φ))` | Temporal connectedness |
| BX4' `connect_past` | Axioms.lean:155 | `φ → H(F(φ))` | Mirror |
| BX5 `self_accum_until` | Axioms.lean:161 | `(φUψ) → ((φ ∧ (φUψ))Uψ)` | **Key eventuality axiom** |
| BX5' `self_accum_since` | Axioms.lean:166 | mirror for S | |
| BX6 `absorb_until` | Axioms.lean:173 | `(φU(φ ∧ (φUψ))) → (φUψ)` | Prevents infinite deferral |
| BX6' `absorb_since` | Axioms.lean:177 | mirror for S | |
| BX7 `linear_until` | Axioms.lean:184 | four-formula linearity disjunction | Linearity of U witnesses |
| BX7' `linear_since` | Axioms.lean:194 | mirror for S | |
| BX10 `until_F` | Axioms.lean:211 | `(φUψ) → F(ψ)` | Eventuality extraction |
| BX10' `since_P` | Axioms.lean:216 | mirror for S | |
| BX11 `temp_linearity` | Axioms.lean:225 | F-witness linearity disjunction | Linear order on F witnesses |
| BX11' `temp_linearity_past` | Axioms.lean:234 | mirror for P | |
| BX12 `F_until_equiv` | Axioms.lean:243 | `F(φ) → (⊤Uφ)` | Bridges F to U |
| BX12' `P_since_equiv` | Axioms.lean:248 | `P(φ) → (⊤Sφ)` | Mirror |
| BX13 `enrichment_until` | Axioms.lean:160 | `p ∧ (φUψ) → (φU(ψ ∧ S(φ,p)))` | Burgess A3a enrichment |
| BX13' `enrichment_since` | Axioms.lean:165 | mirror for S | Burgess A3b |
| BX2H `left_mono_until_G` | Axioms.lean:140 | `G(φ→χ) → (φUψ) → (χUψ)` | Guard strengthening under G |
| BX2H' `left_mono_since_H` | Axioms.lean:146 | `H(φ→χ) → (φSψ) → (χSψ)` | Guard strengthening under H |

*Note: BX8/BX8' (until_step/since_step) removed -- not sound under irreflexive semantics.*
*Note: BX9/BX9' (until_elim/since_elim) and until_guard/since_guard removed -- not sound under open guard `(t,s)` semantics (task 113).*
*Note: BX14/BX14' (separation_until/separation_since) removed -- redundant under transitive frames. Xu 3.2.1 (BX5 self-accumulation) subsumes BX14's role in chronicle splitting (task 115).*
*Note: BX2/BX2' (left_mono_until/left_mono_since) removed in task 133. Under open-guard irreflexive semantics the pointwise conjunct in BX2 is redundant; BX2H/BX2H' (left_mono_until_G/left_mono_since_H, added in task 107 Phase 5b) subsume BX2/BX2' and are now the canonical left-monotonicity axioms.*

### Layer 4: Modal-Temporal Interaction (2 → 1 after task 124)

| Axiom | File:Line | Statement | Status |
|-------|-----------|-----------|--------|
| `modal_future` | Axioms.lean:328 | `□φ → □(Gφ)` | Primitive |
| `temp_future` | Axioms.lean:331 | `□φ → G(□φ)` | **Task 124: derive from MF+T+Modal4, remove as primitive** |

### Layer 5: Uniformity (5)

| Axiom | Statement | Role |
|-------|-----------|------|
| `discrete_symm_fwd` | `U(⊤,⊥) → S(⊤,⊥)` | Forward gap implies backward gap |
| `discrete_symm_bwd` | `S(⊤,⊥) → U(⊤,⊥)` | Backward gap implies forward gap |
| `discrete_propagate_fwd` | `U(⊤,⊥) → G(U(⊤,⊥))` | Gap propagates to all future points |
| `discrete_propagate_bwd` | `U(⊤,⊥) → H(U(⊤,⊥))` | Gap propagates to all past points |
| `discrete_box_necessity` | `U(⊤,⊥) → □(U(⊤,⊥))` | Discreteness propagates to all box-accessible worlds (task 142) |

*These encode the uniformity of discreteness in ordered abelian groups. Valid on all linear orders with AddCommGroup structure. The `discrete_box_necessity` axiom is the key to eliminating the mixed case in `completeness`: it ensures that if any world is discrete, all box-accessible worlds are discrete too.*

### Layer 6: Prior Axioms for Integers (2) — Task 119

| Axiom | Statement | Role |
|-------|-----------|------|
| `prior_UZ` | `F(φ) → U(φ, ¬φ)` | Nearest future φ-point is reachable (Reynolds 1992 §10, Venema 1993 axiom W) |
| `prior_SZ` | `P(φ) → S(φ, ¬φ)` | Nearest past φ-point is reachable (dual) |

*These are discrete-only axioms (`isBase = False`, `isDenseCompatible = False`, `isDiscreteCompatible = True`, `frameClass = .Discrete`). Valid on all discrete orders with `IsSuccArchimedean`. Soundness proofs are sorry-free (well-founded descent via `Nat.find` on succ/pred chain). Added by task 119.*

### Irreflexive semantics and the seriality switch

Under the irreflexive semantics switch (task 93), BX1/BX1' (`Gφ → φ` / `Hφ → φ`)
were replaced by seriality axioms (`T → F(T)` / `T → P(T)`). This means:

- `bx_le` is no longer reflexive (g_content(w) is NOT a subset of w)
- `g_content_set_consistent` uses seriality instead of BX1: if G(bot) in MCS,
  seriality gives F(T) = not G(neg T), and G(bot) implies G(neg T) by ex falso,
  contradiction
- BX8/BX8' (until_step/since_step) were removed entirely -- not sound under irreflexive semantics
- `φ → F(φ)` is NOT derivable -- this is the KEY insight for completeness:
  resolved defects do not re-enter as F-obligations

The critical architectural consequence: under irreflexive semantics, the
active defect count strictly decreases at each chain step, because resolved
formulas φ in M' do NOT generate F(φ) in M'. This unblocks the 5 remaining
sorry sites in RootScopedChain.lean.

---

## Irreflexive Truth Semantics

All four temporal operators in TM use strict (irreflexive) ordering. The current
point is EXCLUDED for G and H (`<`), and Until/Since witnesses must be strictly
future/past (`t < s` / `s < t`) with open guards.

From `FormalSystem/Semantics/Truth.lean:128-137` (the definition is now named `TruthAt`, not
`truth_at`). **The Lean block below is a STALE quotation** — it has not been refreshed since two
landed changes: (a) the Burgess argument-order migration, so the `untl`/`snce` clauses now read
`TruthAt … s φ ∧ ∀ r, … TruthAt … r ψ` (event first, guard second), and (b) the demotion of G/H
from primitive `Formula` constructors to derived abbreviations `allFuture`/`allPast`
(`FormalSystem/Syntax/Formula.lean:151,161`), so `TruthAt` has no `all_past`/`all_future` cases
at all. The truth conditions stated in the bullets after the block remain correct; the Lean text
does not match the source and needs a content pass:

```lean
def truth_at (M : TaskModel F) (Omega : Set (WorldHistory F))
    (τ : WorldHistory F) (t : D) : Formula → Prop
  | Formula.atom p => ∃ (ht : τ.domain t), M.valuation (τ.states t ht) p
  | Formula.bot => False
  | Formula.imp φ ψ => truth_at M Omega τ t φ → truth_at M Omega τ t ψ
  | Formula.box φ => ∀ (σ : WorldHistory F), σ ∈ Omega → truth_at M Omega σ t φ
  | Formula.all_past φ => ∀ (s : D), s < t → truth_at M Omega τ s φ
  | Formula.all_future φ => ∀ (s : D), t < s → truth_at M Omega τ s φ
  | Formula.untl φ ψ => ∃ s : D, t < s ∧ truth_at M Omega τ s ψ ∧
      ∀ r : D, t < r → r < s → truth_at M Omega τ r φ
  | Formula.snce φ ψ => ∃ s : D, s < t ∧ truth_at M Omega τ s ψ ∧
      ∀ r : D, s < r → r < t → truth_at M Omega τ r φ
```

- **G (`all_future`)**: `∀ s, t < s → ...` — strict future (excludes `t`).
- **H (`all_past`)**: `∀ s, s < t → ...` — strict past (excludes `t`).
- **U (`untl`)**: `∃ s, t < s ∧ ψ@s ∧ ∀ r, t < r < s → φ@r` — strict witness,
  open guard `(t, s)`.
- **S (`snce`)**: `∃ s, s < t ∧ ψ@s ∧ ∀ r, s < r < t → φ@r` — mirror.

Under irreflexive semantics, `Gφ → φ` is NOT valid (BX1 removed), and
`φ → F(φ)` is NOT derivable. Seriality axioms (`T → F(T)`, `T → P(T)`)
ensure the temporal order has no maximum/minimum elements.

---

## X/Y Operator Status

From `FormalSystem/Syntax/Formula.lean:430-436`:

```lean
/-- Next-step operator: X(phi) = U(phi, bot) (Burgess convention: event first, guard second).
    X(phi) at t means phi holds at t+1 (event=phi at immediate successor, guard=bot vacuous). -/
def next (φ : Formula) : Formula := Formula.untl φ Formula.bot

/-- Previous-step operator: Y(phi) = S(phi, bot) (Burgess convention: event first, guard second).
    Y(phi) at t means phi holds at t-1 (event=phi at immediate predecessor, guard=bot vacuous). -/
def prev (φ : Formula) : Formula := Formula.snce φ Formula.bot
```

Unfolding `Formula.next φ = Formula.untl φ Formula.bot` against the irreflexive
Until clause (`Truth.lean:134-135`):

```
truth_at (⊥ U φ) at t  ↔  ∃ s, t < s ∧ truth_at φ s ��� ∀ r, t < r → r < s �� truth_at ⊥ r
                       ↔  ∃ s, t < s ∧ truth_at φ s ∧ ∀ r, t < r → r < s → False
                       ↔  ∃ s, t < s ∧ truth_at φ s ∧ (∀ r, ¬(t < r ∧ r < s))
                       ↔  ∃ s, t < s ∧ truth_at φ s ∧ (t, s) = ∅
```

Under irreflexive semantics, `⊥ U φ` at `t` requires a strictly future witness
`s > t` with `φ(s)` and an empty open interval `(t, s)`. The behavior depends
on the order structure:

- **Discrete order** (e.g., `ℤ`): The interval `(t, s)` is empty iff `s = t + 1`.
  So `X(φ)` at `t` means `φ` holds at the immediate successor `t + 1`. This is
  a genuine next-step operator, matching the docstring's "discrete strict semantics."
  Similarly, `Y(φ)` at `t` means `φ` holds at `t - 1`.

- **Dense order** (e.g., `ℚ` or `ℝ`): The interval `(t, s)` is never empty for
  `s > t`. So `⊥ U φ` is unsatisfiable on dense orders, and `X(φ)` is always
  false. Similarly, `Y(φ)` is always false on dense orders.

Under the current irreflexive semantics, `X`/`Y` have genuine semantic content
on discrete orders (they are true next/previous-step operators). On dense orders,
they are vacuously false. **They are not currently used in proofs**, but they
are no longer trivially equivalent to their argument as they were under the
former reflexive semantics.

---

## Active Metalogic Paths

The **Chronicle** path (`Metalogic/BXCanonical/Chronicle/`) is the sole active
completeness path. The BXCanonical path (task 109, abandoned) is dead code — its
~17 sorries are mathematically false under irreflexive semantics.

### Chronicle Construction (Tasks 107→117→119→121→122)

The Burgess 1982 chronicle construction builds a countermodel via controlled
PointInsertion. The construction lives in `Metalogic/BXCanonical/Chronicle/`
(6 files, ~9500 lines).

**Current state (2026-05-10)**: 2 sorry sites on critical path (down from 13+ at task 107 start).
- Task 107: Eliminated all Chronicle sorry sites via 9 implementation phases
- Task 117: Removed Cantor iso, built countermodel on limit domain, dense case sorry-free
- Task 119: Added Prior-UZ/SZ axioms, proved IsSuccArchimedean via pigeonhole (modulo finiteness)

**Chronicle module structure**:
- `ChronicleTypes.lean` (~700 lines) -- Chronicle structure, `ClosedUnderDerivation`, `BurgessR3Maximal` (**sorry-free**)
- `PointInsertion.lean` (~3555 lines) -- Lemma 2.4/2.6, g_content⊆B, splitting (**sorry-free**)
- `RRelation.lean` (~1580 lines) -- R-relation, Burgess 2.3 equiv, Zorn construction (**sorry-free**)
- `CounterexampleElimination.lean` (~3600 lines) -- C4/C5 elimination (**sorry-free**)
- `ChronicleConstruction.lean` (~1220 lines) -- Omega-chain, limit construction (**sorry-free**)
- `ChronicleToCountermodel.lean` (~1200 lines) -- BFMCS wiring, dense/discrete countermodels (**2 sorries: finiteness + discrete BFMCS**)

**Key insight (report 17)**: The hybrid Int-chain + enriched seed approach is definitively
dead (dead ends #7, #13, #23, #31). The chronicle construction is NOT a dead end -- all
gaps are engineering problems, not mathematical impossibilities (report 16).

### BXCanonical Path (DEAD CODE — Task 109 Abandoned)

The BXCanonical path flows through `Metalogic/BXCanonical/`. Its ~17 sorries
assume reflexive G/H semantics (`Gφ → φ`) which is mathematically false under
the current irreflexive semantics. The Chronicle path bypasses it entirely.
Task 109 was abandoned 2026-05-10. Candidate for archival to Boneyard/.

### Module Import Graph

```
Metalogic/BXCanonical/BXCanonical.lean (28 lines, aggregator)
  ├── Frame.lean (726 lines, 1 sorry: bx_le_refl)
  │     ├── Core/MaximalConsistent
  │     ├── Core/MCSProperties
  │     ├── Bundle/TemporalContent
  │     ├── Bundle/WitnessSeed
  │     ├── Bundle/CanonicalFrame
  │     ├── Syntax/Formula
  │     └── Theorems/GeneralizedNecessitation
  │
  ├── TruthLemma.lean (319 lines, 2 sorries: until/since_backward_refl_mcs)
  │     ├── Frame
  │     ├── Semantics/Truth
  │     └── Semantics/Validity
  │
  ├── Completeness.lean (152 lines, sorry-free -- delegates to RootScopedChain)
  │     ├── RootScopedChain
  │     └── Semantics/Validity
  │
  ├── CanonicalChain.lean (160 lines, sorry-free)
  │     ├── Frame
  │     ├── Quasimodel/Construction
  │     └── Filtration/DefectChain
  │
  ├── OrderedSeedConsistency.lean (255 lines, sorry-free)
  │     ├── Frame
  │     └── CanonicalChain
  │
  ├── CanonicalModel.lean (~440 lines, 2 sorries: g/h_content_subset; dead-code removed in task 109 Phase 1)
  │     ├── CanonicalChain
  │     ├── TruthLemma
  │     └── Bundle/FMCSDef
  │
  ├── RootScopedChain.lean (1,487 lines, 5 sorries -- task 109)
  │     ├── OrderedSeedConsistency
  │     ├── CanonicalModel
  │     ├── Bundle/UntilSinceCoherence
  │     ├── Algebraic/ParametricRepresentation
  │     └── Algebraic/RestrictedParametricTruthLemma
  │
  ├── Quasimodel/
  │     ├── SubformulaClosure.lean (114 lines, sorry-free)
  │     │     └── Syntax/Formula
  │     ├── HintikkaPoint.lean (144 lines, sorry-free)
  │     │     ├── SubformulaClosure
  │     │     └── Frame
  │     ├── EnrichedClosure.lean (158 lines, sorry-free)
  │     │     ├── Syntax/BigConj
  │     │     ├── SubformulaClosure
  │     │     └── Mathlib.Data.Finset.Powerset
  │     ├── Construction.lean (885 lines, 2 sorries: refl_intro_until/since_mcs)
  │     │     ├── HintikkaPoint
  │     │     └── Mathlib.Data.List.Chain
  │     ├── Realization.lean (576 lines, 4 sorries: F/P_of_mem, g/h_content in seed)
  │     │     ├── Construction
  │     │     ├── Syntax/BigConj
  │     │     ├── Theorems/Combinators
  │     │     └── Theorems/Propositional
  │     └── LocusControl.lean (47 lines, sorry-free)
  │           └── Realization
  │
  └── Filtration/
        ├── SigmaOrdering.lean (167 lines, 3 sorries: sigma_le_refl, sigma_strict_irrefl, not_sigma_equiv)
        │     ├── Frame
        │     └── Quasimodel/EnrichedClosure
        └── DefectChain.lean (137 lines, sorry-free)
              ├── SigmaOrdering
              └── Quasimodel/Construction
```

**Total BXCanonical module: ~5,795 lines across 16 files, 19 sorries (5 critical-path + 14 irreflexive-consequence). Task 109 Phase 1 removed 4 dead-code sorries from CanonicalModel.lean.**

Legacy files (`UltrafilterChain`, `SuccChainFMCS`, `FrameConditions/Completeness`)
are still built via top-level aggregation in `Metalogic.lean` but are **not
imported** by `BXCanonical`.

---

## Canonical Model Construction (BXCanonical)

### BXPoint (Frame.lean:46-53)

```lean
structure BXPoint where
  formulas : Set Formula
  is_mcs : SetMaximalConsistent formulas
```

A canonical frame point is a maximally consistent set (MCS) of formulas.

### Canonical Temporal Ordering (Frame.lean:56-62)

```lean
def bx_le (w v : BXPoint) : Prop :=
  g_content w.formulas ⊆ v.formulas
```

Equivalently: `w ≤ v ↔ ∀ φ, G(φ) ∈ w → φ ∈ v`.

- **Reflexivity** (`bx_le_refl`): NOT valid under irreflexive semantics (BX1 removed).
  Without BX1, `g_content w ⊆ w` fails. `bx_le_refl` is sorry'd (intentionally invalid).
- **Transitivity** (`bx_le_trans`): requires `Gφ → GGφ` = `temp_4`.

### Canonical Modal Equivalence (Frame.lean:65-68)

```lean
def bx_modal_equiv (w v : BXPoint) : Prop :=
  ∀ φ : Formula, Formula.box φ ∈ w.formulas ↔ Formula.box φ ∈ v.formulas
```

### Key Infrastructure Lemmas (Frame.lean:79+)

- `g_content_closed_derivation` (Frame.lean:79-94): if `L ⊆ g_content(S)` and
  `L ⊢ φ`, then `Gφ ∈ S`. Uses `generalized_temporal_k`.
- `h_content_closed_derivation` (Frame.lean:101-114): dual for H.
- `g_content_set_consistent` (Frame.lean:122-162): `g_content` of an MCS is
  consistent; uses seriality (`T → F(T)`) to contradict `G(⊥) ∈ S` via
  `G(⊥) → G(¬⊤)` and `F(⊤) = ¬G(¬⊤)`. Sorry-free.
- `bx_forward_witness` / `bx_backward_witness`: Lindenbaum extension producing
  G/H canonical witnesses.
- `bx_modal_witness` (Frame.lean): constructs the modal-direction witness.
  Sorry-free (closed by task 102).

### Truth Lemma (TruthLemma.lean:27-36)

Proved by formula induction. The core cases (`atom`, `bot`, `imp`, `box`, `G`, `H`,
`U` forward, `S` forward) are **sorry-free**. The `U` and `S` forward cases delegate
to `bx_until_eventuality_resolution` / `bx_since_eventuality_resolution` in
`Frame.lean`, closed by tasks 98+102. Two auxiliary lemmas
(`until_backward_refl_mcs`, `since_backward_refl_mcs`) are sorry'd as
irreflexive-consequence artifacts -- they assumed reflexive Until/Since introduction
which is invalid under irreflexive semantics.

### Completeness Theorem (Completeness.lean:124-154)

```lean
theorem completeness (φ : Formula) :
    valid φ → Nonempty (DerivationTree [] φ)
```

Contrapositive proof flow:

1. Assume `valid φ` and `¬derivable φ`.
2. By `neg_consistent_of_not_derivable` (sorry-free): `{¬φ}` is consistent.
3. By `set_lindenbaum`: extend to an MCS `M` with `¬φ ∈ M`.
4. Build a canonical `TaskModel` from the BXPoint canonical frame.
5. By the truth lemma: `φ` is false at `M` in the model.
6. Contradiction with `valid φ`.

Step 4 is handled by `dd_countermodel` (in `RootScopedChain.lean`), which
`Completeness.lean` calls directly. `Completeness.lean` itself is sorry-free;
the remaining sorries are in the chain construction that `dd_countermodel`
depends on (see Sorry Inventory above).

---

## Quasimodel/Filtration Infrastructure

Nine files (2,228 lines) under `BXCanonical/` implement a Hintikka-set
quasimodel with defect-discharge to close the Until/Since eventuality
obligations. Under irreflexive semantics, 9 of these sorries are
irreflexive-consequence artifacts (Construction 2, Realization 4,
SigmaOrdering 3); the remaining files are sorry-free.

### Quasimodel/ (Hintikka-set quasimodel construction)

| File | Lines | Purpose | Key Definitions |
|------|-------|---------|-----------------|
| `SubformulaClosure.lean` | 114 | Finite subformula closure (Sigma-closure) | `subformulas`, `SubformulaClosure`, `ghEnrichment` |
| `HintikkaPoint.lean` | 144 | Hintikka point definition and sigma-signature | `HintikkaPoint`, `sigma_signature`, `sigma_signature_consistent`, `sigma_signature_maximal` |
| `EnrichedClosure.lean` | 158 | Fisher-Ladner enriched closure with G/H negation formulas | `enrichedGNegBigconj`, `enrichedHNegBigconj`, `enrichedClosure` |
| `Construction.lean` | 885 | BX axiom lemmas at MCS level with defect-discharge (2 sorries) | `hintikka_step`, `UntilDefect`, `defect_count`, `QuasimodelChain` |
| `Realization.lean` | 576 | Realization lifting from Hintikka chains to BXPoint chains (4 sorries) | `until_forward_seed`, `since_backward_seed`, `until_eventuality_resolution`, `since_eventuality_resolution` |
| `LocusControl.lean` | 47 | Delegation layer (primed variants) | `bx_until_eventuality_resolution'`, `bx_since_eventuality_resolution'` |

### Filtration/ (Sigma-restricted ordering)

| File | Lines | Purpose | Key Definitions |
|------|-------|---------|-----------------|
| `SigmaOrdering.lean` | 167 | Sigma-restricted ordering on BXPoints (3 sorries) | `sigma_le`, `sigma_strict`, `sigma_equiv`, `bx_le_implies_sigma_le` |
| `DefectChain.lean` | 137 | Defect-discharge chain via well-founded recursion | `sigma_defect_count`, `until_defect`, `defect_step_phi` |

### CanonicalChain.lean (top-level bridge)

| File | Lines | Purpose | Key Definitions |
|------|-------|---------|-----------------|
| `CanonicalChain.lean` | 160 | MCS-level BX axiom lemmas and delegation bridges (sorry-free) | `psi_imp_until_mcs`, `psi_imp_since_mcs`, `F_imp_top_until_mcs` |

---

## How Until/Since Were Closed

The four Until/Since eventuality and backward sorries in `Frame.lean` were
the hardest part of the BX completeness proof. They were closed between
2026-04-10 and 2026-04-12 through tasks 90, 92, 98, and 102.

### The Problem

The original canonical model construction used `bx_le` (defined as
`g_content w ⊆ v`) for the temporal ordering. The Until/Since eventuality
obligations require finding a witness point where the eventuality formula
is discharged. The core difficulty was the **X-vs-G mismatch**: `φ U ψ ∈ w`
does not imply `G(φ U ψ) ∈ w`, so the formula does not propagate forward
through the `g_content`-based ordering.

### The Solution: Hintikka-Set Quasimodel with Defect-Discharge

**Research (task 90)** identified two strategies. **Option A** -- a quasimodel
approach using Hintikka points with defect-discharge -- was chosen for its
proof-theoretic elegance and avoidance of Henkin witness closure machinery.

The approach works as follows:

1. **Subformula closure** (`SubformulaClosure.lean`): Define a finite
   sigma-closure of the target formula, restricting attention to a bounded
   set of subformulas.

2. **Hintikka points** (`HintikkaPoint.lean`): Define Hintikka points as
   MCS sets restricted to the sigma-closure, with sigma-signatures encoding
   consistency and maximality within the closure.

3. **Enriched closure** (`EnrichedClosure.lean`): Extend the closure with
   Fisher-Ladner enrichment formulas (G/H-negation big conjunctions) that
   ensure the finite model property.

4. **Defect-discharge construction** (`Construction.lean`, 887 lines): Build
   `QuasimodelChain`s where each step discharges an `UntilDefect` --
   a formula `φ U ψ` held at a point but not yet witnessed. The
   `defect_count` decreases at each step, ensuring termination via
   well-founded recursion on the finite sigma-closure.

5. **Realization** (`Realization.lean`): Lift the Hintikka chain construction
   back to BXPoint chains, producing the eventuality resolution and backward
   witnesses that `Frame.lean` needs.

6. **Sigma-restricted ordering** (`Filtration/`): Define `sigma_le` as a
   sigma-restricted variant of `bx_le` that respects the finite closure.
   `DefectChain.lean` uses well-founded recursion on `sigma_defect_count`
   to discharge all defects.

**Implementation (task 92)** built the initial infrastructure. **Task 98**
closed `bx_until_eventuality_resolution` and `bx_since_eventuality_resolution`.
**Task 102** closed the remaining three sorries: `bx_until_backward`,
`bx_since_backward`, and `bx_modal_witness`.

---

## Sorry Inventory

The BXCanonical module has **23 sorry proofs** in three categories.

### Critical Path (5 sorries in RootScopedChain.lean)

`Completeness.lean` is sorry-free but delegates to `dd_countermodel` in
`RootScopedChain.lean`, which depends on these 5 sorry sites:

| # | File:Line | Definition | Goal Summary | Owning Task |
|---|-----------|------------|--------------|-------------|
| 1 | RootScopedChain.lean:1065 | `fwd_chain_forward_F` | F-resolution for preserving chain | **Task 109** |
| 2 | RootScopedChain.lean:1092 | `dd_bfmcs_restricted_tc` (fwd, backward chain case) | Restricted temporal coherence (backward chain F-case) | **Task 109** |
| 3 | RootScopedChain.lean:1099 | `dd_bfmcs_restricted_tc` (backward direction) | Backward temporal coherence (P-resolution) | **Task 109** |
| 4 | RootScopedChain.lean:1107 | `dd_bfmcs_restricted_buc` | Backward Until/Since coherence | **Task 109** |
| 5 | RootScopedChain.lean:1114 | `dd_bfmcs_restricted_fuc` | Forward Until/Since coherence | **Task 109** |

### Irreflexive-Consequence (18 sorries across 6 files)

These are artifacts of the BX1/BX1' removal (task 93). Under the former reflexive
semantics, `G(φ) → φ` (BX1) made these provable; under irreflexive semantics,
they are either mathematically false (e.g., `bx_le_refl`) or require redesign.

| File | Sorries | Key Definitions |
|------|---------|-----------------|
| Frame.lean | 1 | `bx_le_refl` (intentionally invalid) |
| TruthLemma.lean | 2 | `until_backward_refl_mcs`, `since_backward_refl_mcs` |
| CanonicalModel.lean | 2 | `g_content_subset_self`, `h_content_subset_self` (4 dead-code sorries removed in task 109 Phase 1) |
| Construction.lean | 2 | `refl_intro_until_mcs`, `refl_intro_since_mcs` |
| Realization.lean | 4 | `F_of_mem`, `P_of_mem`, g/h_content subset in seed proofs |
| SigmaOrdering.lean | 3 | `sigma_le_refl`, `sigma_strict_irrefl`, `not_sigma_equiv_of_sigma_strict` |

### Irreflexive Semantics Strategy (Plan v48, 2026-04-19)

The irreflexive semantics switch (task 93, plan v48) resolves the fundamental
obstruction that blocked all previous approaches: under reflexive semantics,
`phi -> F(phi)` is derivable (from BX1), so resolving a defect phi creates
F(phi) which regenerates the defect. This "defect oscillation" blocked
pigeonhole arguments, oracle chains, and quasimodel approaches.

Under irreflexive semantics, `phi -> F(phi)` is NOT derivable because
`G(neg phi) -> neg phi` (BX1) is removed. This means:

- At each chain step, `defect_step_early` gives: for each defect chi,
  either `chi in M'` (resolved) or `F(chi) in M'` (still pending)
- Resolved defects do NOT re-enter as F-obligations
- Active defects (chi with F(chi) in M) strictly decrease at each step
- After at most |sigma_list| steps, all defects are resolved

**Key structural changes:**
- `defect_step_early` weakened from `F(chi) in M'` to `chi in M' OR F(chi) in M'`
- `fwd_chain_F_persistent` replaced by `fwd_chain_defect_one_step` (single-step)
- `defect_step_from_earliest` output weakened to disjunctive form
- `g_content_set_consistent` proved via seriality (not BX1)
- `h_content_set_consistent` proved via seriality (not BX1')
- `enriched_seed_consistent` bypassed (fwd_succ uses g_content alone)

**Phase 3-4 remaining work:** Build finite descent argument on active_defects
to close the 5 sorry sites. The defect step infrastructure is in place; the
proof requires showing that |active_defects(chain(n+1))| < |active_defects(chain(n))|
when defects are present.

### Closed Sorries (Tasks 90+92+98+102)

The following 5 sorries in `Frame.lean` were closed between 2026-04-10 and
2026-04-12 via the quasimodel/filtration infrastructure:

| Former sorry | Definition | Closed by |
|-------------|------------|-----------|
| Frame.lean (formerly :440) | `bx_modal_witness` | Task 102 |
| Frame.lean (formerly :653) | `bx_until_eventuality_resolution` | Task 98 |
| Frame.lean (formerly :675) | `bx_until_backward` | Task 102 |
| Frame.lean (formerly :690) | `bx_since_eventuality_resolution` | Task 98 |
| Frame.lean (formerly :704) | `bx_since_backward` | Task 102 |

Frame.lean has **1 sorry** (`bx_le_refl`, intentionally invalid under irreflexive semantics).
The key consistency proofs (`g_content_set_consistent`, `h_content_set_consistent`,
`bx_H_backward`) are all sorry-free using seriality. See "How Until/Since Were Closed"
below for the approach that resolved the eventuality sorries.

---

## Legacy Code Inventory

The following files were written under earlier architectural iterations and are
**not imported by `BXCanonical`** and are not on the active completeness path.
**Task 94** archived them to `Boneyard/StrictSemanticsLegacy/` (completed 2026-04-12).
This dropped approximately **~20 sorries** from the active (non-Boneyard,
non-Example) tree.

| File | Approx sorries | Category | Imported by BXCanonical? |
|------|---------------|----------|---------------------------|
| `Metalogic/Algebraic/UltrafilterChain.lean` | 4 | Legacy strict-semantics | No |
| `Metalogic/Algebraic/DovetailedChain.lean` | 6 | Deprecated (X-vs-G mismatch) | No |
| `Metalogic/Algebraic/LindenbaumQuotient.lean` | 2 | temp_k_dist derivable from BX | No |
| `Metalogic/Algebraic/InteriorOperators.lean` | 1 | temp_k_dist derivable from BX | No |
| `Metalogic/Bundle/SuccChainFMCS.lean` | 3 | Legacy strict-semantics | No |
| `Metalogic/Bundle/SuccRelation.lean` | 1 | Legacy | No |
| `Metalogic/Bundle/CanonicalFrame.lean` | 1 | BX derivability | No |
| `FrameConditions/Completeness.lean` | 2 | Wiring (temporal coherence + dense) | No |

Additional legacy code, formerly imported by `Metalogic.lean` at top-level for aggregation but
never required for BX completeness. **Both have since been archived out of the live tree** and
are no longer imported anywhere — `FormalSystem/Metalogic.lean` now aggregates only
`Soundness`, `Decidability`, `BXCanonical`, and `WeakCanonical`:

- `Metalogic/Completeness.lean` → moved verbatim to
  `FormalSystem/Boneyard/SupersededCompleteness/Completeness.lean`
- `Metalogic/Bundle/CanonicalConstruction.lean` → moved to
  `FormalSystem/Boneyard/StrictSemanticsLegacy/Bundle/CanonicalConstruction.lean`

**Verification**:
```
grep -r "import.*\(UltrafilterChain\|SuccChainFMCS\|FrameConditions\.Completeness\)" \
  FormalSystem/Metalogic/BXCanonical/
```
returns nothing.

Note: the `X`/`Y` operator definitions in `Syntax/Formula.lean:430-436` are
also candidates for archival or deletion (see "X/Y Operator Status" section) —
task 94 should decide their fate.

---

## Burgess-Xu Until-Induction Technique

### Historical Context

The BX system is named after John P. Burgess and Ming Xu. Active references
(cited in the `Axioms.lean:46-49` comment block):

- **Burgess, J. P. (1982)**. "Axioms for tense logic. I. 'Since' and 'until'."
  *Notre Dame Journal of Formal Logic* 23(4), 367-374.
  [ResearchGate](https://www.researchgate.net/publication/38355634_Axioms_for_tense_logic_I_Since''_and_until'').
- **Xu, M. (1988)**. "On some U, S-tense logics."
  *Journal of Philosophical Logic* 17, 181-202. Simplifies Burgess's axiomatization.
- **Venema, Y. (1993)**. Temporal logic survey (cited in `Axioms.lean:48`).

See also the Stanford Encyclopedia of Philosophy:

- [Burgess-Xu Axiomatic System for Since and Until](https://seop.illc.uva.nl/entries/logic-temporal/burgess-xu.html) — supplementary entry.
- [Temporal Logic](https://plato.stanford.edu/entries/logic-temporal/) — main article.

### Key Result

Burgess (1982), simplified by Xu (1988), gives a complete axiomatization of
the Since-Until tense logic over **all linear orderings**. The BX axioms
BX1-BX12 in `Axioms.lean` are modeled on this axiomatization, adapted for
irreflexive semantics (BX1/BX1' replaced by seriality, BX8/BX8' removed).

### Axiom Roles in the Until-Induction Proof

The proof of the Until case of the truth lemma proceeds by induction on the
Until-structure of formulas, using the following axioms:

1. **BX10 (`until_F`)**: `(φUψ) → Fψ` extracts an F-witness, giving some
   `v ≥ w` with `ψ ∈ v`.
2. **BX7 (`linear_until`)**: Linearity of Until witnesses — given two Until
   formulas holding simultaneously, their witnesses are comparable. Provides
   the linear-order structure on witnesses needed to choose a minimal / first
   witness.
3. **BX11 (`temp_linearity`)**: F-witness linearity — three-way disjunction
   giving comparability of F-witnesses.
4. **BX5 (`self_accum_until`)**: `(φUψ) → ((φ ∧ (φUψ))Uψ)` — the eventuality
   enriches its own guard, so at every intermediate point `u ∈ [w, v)` both
   `φ` and `φUψ` hold. This is the key guard-propagation axiom.
5. **BX6 (`absorb_until`)**: `(φU(φ ∧ (φUψ))) → (φUψ)` — prevents the
   self-accumulation from producing nested deferrals; the two-step resolution
   collapses.
6. **BX9 (`until_elim`)**: REMOVED (task 113). Was `(φUψ) → (φ ∨ ψ)`.
   Under open guard `(t,s)`, `t ∉ (t,s)` so `φ(t)` is not guaranteed.
   Not sound under open guard semantics.
7. **BX4 (`connect_future`)**: `φ → G(P(φ))` is used in the backward direction
   to propagate `¬(φUψ)` forward and derive a contradiction with the guard.
8. **BX1 (`serial_future`)**: `T → F(T)` (seriality). Replaces the former
   reflexive `Gφ → φ`. Consistency of `g_content` uses seriality to show
   `G(bot)` contradicts `F(T)`.

### Resolution: Option A (Quasimodel with Defect-Discharge)

Task 90 (research) identified two strategies for closing the 4 `bx_until_*` /
`bx_since_*` sorries:

- **Option A: Quasimodel with defect-discharge** -- Build a Hintikka-set
  quasimodel with sigma-restricted filtration ordering. Avoids Henkin closure
  machinery; uses well-founded recursion on defect count.
- **Option B: Henkin witness closure** -- Explicitly enrich the canonical frame
  with witness MCS points. Classical Burgess construction but adds machinery
  to the BXPoint type.

**Option A was chosen and implemented successfully** through tasks 92, 98,
and 102. The implementation added 2,289 lines of sorry-free infrastructure
across 9 files (see "Quasimodel/Filtration Infrastructure" and "How
Until/Since Were Closed" above). All 5 Frame.lean sorries are closed.

---

## Dead Ends (Archived)

These anti-patterns are preserved across the BX migration — they remain valid
warnings regardless of the semantic change.

1. **CoherentZChain**: Forward chain preserves G but not H; backward preserves
   H but not G. Unfixable.

2. **`f_preserving_seed_consistent` sub-case A**: Mathematically unprovable.
   Vacuous implication yields no contradiction.

3. **`omega_true_dovetailed_forward_F_resolution`**: Unfixable. Lindenbaum
   extension can add `G(¬φ)` when `F(φ)` was present.

4. **Bundle-level temporal coherence**: Insufficient for truth lemma. G/H
   operators are intrinsically single-history.

5. **Fuel-based bounded witness recursion** (tasks 48, 67, 81 plan v13):
   Repeatedly failed. Fuel conflates F-nesting depth (bounded) with
   persistence count (unbounded).

6. **Bidirectional Temporal Witness** (plan v4): BLOCKED. H_theory elements
   are not G-liftable.

7. **Combined F-seed chain construction** (task 86 plans v4-v6): The
   multi-target seed `{ψ | F(ψ) ∈ w} ∪ g_content(w)` is inconsistent in
   general. G does not distribute over disjunction — the compactness step
   in the multi-target argument is mathematically false.

8. **Constant-history canonical models for G/H** (task 86): On a constant
   history (all times map to same world), `G(α)` is semantically identical
   to `α`. It is structurally impossible to build a constant-history
   countermodel that distinguishes formulas containing G/H from their
   temporal-free flattening. This blocks backward truth lemma for G on
   constant histories.

9. **Flatten reduction** (task 86): `flatten(χ) ∈ w` does not imply `χ ∈ w`
   when χ contains G/H, because `α` does not imply `G(α)` for non-theorems.

10. **FMP bridge to completeness** (task 86): The sorry-free
    `fmp_contrapositive` cannot bridge to `valid φ → provable φ` without a
    truth lemma connecting validity to closure MCS membership. This truth
    lemma faces the same branching-vs-linear mismatch as the direct canonical
    model construction. The FMP module is valuable for decidability but does
    NOT provide a shortcut to completeness.

11. **Proof-theoretic Case B for usf_completeness** (task 86, plan v7): 8
    approaches explored to derive `⊢ ψ → χ` directly from `valid(ψ → χ)`
    without countermodel construction, all blocked by the **contextual
    necessitation gap**: temporal necessitation `⊢ α → ⊢ G(α)` requires
    empty context, so `[ψ] ⊢ α` does not give `[ψ] ⊢ G(α)`. Approaches
    tried: flatten + fragment_completeness, constant-model validity transfer,
    unflatten theorem, well-founded induction on size, FMP contrapositive,
    contextual strong completeness, case analysis on χ's structure, normal
    form reduction. Novel result: validity transfer `valid φ → valid(flatten φ)`
    for USF φ is sound but insufficient (unflatten `⊢ flatten(φ) → φ` is
    not derivable).

12. **Constant-history CanonicalEmbedding fragment completeness** (task 88):
    The entire `CanonicalEmbedding.lean` module (434 lines) attempted to
    prove fragment completeness for `{atom, bot, imp, box, G, H}` using
    constant histories (all times map to a single BXPoint). This is
    permanently impossible: on constant histories, `G(α)` is semantically
    identical to `α`, so the truth bridge for `imp` Case B
    (`valid(ψ → χ)` with χ containing G) cannot distinguish χ from its
    temporal-free flattening. File deleted in task 88; validity reduction
    lemmas (`valid_of_valid_all_future`, `valid_of_valid_all_past`,
    `valid_of_valid_box`) relocated to `Semantics/Validity.lean`. Still
    referenced as an anti-pattern at `Completeness.lean:143-148`.

13. **f_carry seed for enriched forward step** (task 93, plans v8-v14):
    `{target} union g_content(M) union f_carry(M)` is inconsistent in general.
    Counterexample: `G(F(alpha) -> neg psi) in M`, `F(alpha) in M`, `F(psi) in M`.
    The G-formula forces `F(alpha) -> neg psi` into any Lindenbaum extension
    containing g_content(M), while f_carry requires both F(alpha) and F(psi)
    to be present. No G-lift argument avoids this.

14. **Fuel-based F-nesting recursion** (task 93, plans v5-v7): Conflates
    F-nesting depth (bounded by subformula closure) with visit count
    (unbounded). F(psi) can persist through arbitrarily many round-robin
    cycles without resolution.

15. **BX11 acyclicity gate check** (task 93, plan v16 Strategy A): 3-cycle
    semantic counterexample. Three formulas psi1, psi2, psi3 with
    bx11_earlier forming a cycle in different MCS contexts. BX11 is not
    transitive and does not induce a well-order.

16. **Strategy C: direct witness contradiction on existing chain** (task 93,
    plans v16-v17): Permanent BX11 displacement is syntactically consistent.
    The `.choose` in `set_lindenbaum` is unconstrained. All three attack
    vectors (visit-step analysis, pigeonhole, discharge_single_step) fail.
    Confidence: 10-15%.

17. **Approach A: target-prioritized fold** (task 93, report 18): Reduces
    multi-step fold Case 3 to single BX11 application, but the final BX11
    between target and compound can still fire Case 3.

18. **Approach B: iterative refinement** (task 93, report 18):
    Mathematically sound but requires chain redefinition -- subsumed by the
    ordered-discharge approach.

19. **Approach C: discharge_single_step at chain level** (task 93, report 18):
    Fatal F-propagation gap at non-target resolving steps.

20. **Approach 21: Until reformulation via BX12** (task 93, report 18):
    `F(psi) -> top U psi` by BX12, then `bx_until_eventuality_resolution`.
    Produces abstract BXPoints not chain indices; `top U psi` may not be in
    `deferralClosure(root)`.

21. **Strategy C fold-order variant** (task 93, report 18 synthesis):
    Processing target last in the BX11 fold. Investigated but fold outcome
    depends on MCS content which is itself determined by `.choose`.

22. **Defect re-entry in enriched chain** (task 93, report 26): Perpetual
    deferral is semantically consistent. The BX11 ordering can permanently
    favor one formula over another, so `enriched_fwd_step` can resolve
    target psi but have F(psi) re-enter at the very next step via
    Lindenbaum extension. No termination argument exists for the enriched
    chain with round-robin scheduling.

23. **G(F(chi)) non-derivability blocking persistent-carry seed** (task 93,
    reports 22, 26): `F(chi) in M` does NOT imply `G(F(chi)) in M`. The
    persistent-carry seed `{psi} union f_carry(M) union g_content(M)` is
    inconsistent when `G(F(alpha) -> neg psi) in M` and both `F(alpha)`
    and `F(psi)` are in `f_carry(M)`. This blocks all enriched seed
    approaches that try to carry F-obligations through g_content.

24. **Non-enriched chain F-obligation loss** (task 93, report 26 Section 7.2):
    The simple `fwd_succ` step uses seed `{target} union g_content(M)` at
    resolving steps, which does NOT include `f_carry`. F-obligations for
    non-target formulas are lost at resolving steps. Round-robin scheduling
    with `fwd_succ` cannot maintain F-obligation constancy.

25. **Quasimodel BXPoint-to-Int bridging gap** (task 93, report 25):
    The sorry-free quasimodel infrastructure produces abstract BXPoint
    chains (Hintikka chains over sigma-closures), but these cannot be
    directly wired into the Int-indexed FMCS/BFMCS families required by
    the parametric representation theorem. The BXPoint chain indices are
    not ordered by `bx_le` in a way compatible with Int's linear order.

26. **Semantic coherence circularity** (task 93, report 26 Section 6.6):
    The truth lemma requires `forward_F` (to resolve F-witnesses in the
    canonical model), but proving `forward_F` on the canonical chain
    requires the truth lemma (to establish that F(psi) in an MCS means
    psi holds at some future point in the model). Standard completeness
    proofs (Burgess 1984, Goldblatt 1992) handle this semantically via
    well-founded induction on formula depth, not syntactically on the
    chain.

27. **DRM bounded_witness via single_step_forcing** (task 93, report 29):
    Negation completeness gap -- the DRM bounded witness approach fails
    because `single_step_forcing` cannot guarantee negation-complete
    intermediate states, breaking the MCS chain invariant.

28. **Full MCS bounded_witness** (task 93, report 29):
    F-reflexivity blocks the exit condition. When the bounded witness
    encounters F(psi) with psi already present, it cannot distinguish
    between "resolved" and "still pending" states, leading to infinite
    loops in the termination argument.

29. **DRM chain preventing perpetual deferral** (task 93, report 29):
    Relocates non-determinism rather than eliminating it. The DRM chain
    construction moves the `.choose` problem from the Lindenbaum extension
    to the defect-resolution oracle, without solving the core issue.

30. **Per-formula witness wired into same-family membership** (task 93,
    report 30): `restricted_temporally_coherent` requires witnesses ON the
    chain (same FMCS family), but `bx_forward_witness` produces BXPoints
    outside the chain family. Bridging BXPoint witnesses back to chain
    membership is blocked by the Lindenbaum non-determinism gap.

31. **Enriched seed approach definitively dead** (task 93, report 43):
    Counterexample: `G(F(alpha) -> neg psi) in M` with both `F(alpha)` and
    `F(psi)` in `f_carry`. The G-formula forces `F(alpha) -> neg psi` into
    any Lindenbaum extension containing `g_content(M)`, while `f_carry`
    requires both `F(alpha)` and `F(psi)` to be present, creating an
    inconsistency. No variant of the enriched seed approach can avoid this.

32. **"Sorry-free oracle" claim at OracleStep.lean is false** (task 93,
    report 44, teammate C): OracleStep.lean contains 7-8 sorry sites in the
    universal oracle infrastructure. The sigma-specific oracle
    (`hintikka_step_for_sigma_sig`, lines 188-222) IS sorry-free, but the
    universal oracle used by `qm_oracle_step` is not. Any path relying on
    the universal oracle inherits these sorries.

33. **Reynolds induction on defects.length fails** (task 93, report 44):
    Defects can oscillate: resolving phi (placing it in M') causes
    `phi in M'`, but `F(phi)` persists (F-preservation), so at the next
    step, the defect condition `F(phi) in M' AND phi in sigma_list` still
    holds. The defect count does not decrease because resolved formulas
    remain "active defects" under the current `active_defects` definition
    (which checks `F(chi) in M`, not `chi not in M`). This blocks the
    Reynolds induction approach from plan v42.

34. **Path C: Pigeonhole fix for fwd_chain_forward_F** (task 93, plan v44
    Phase 2): The BX11 fold in `resolving_enriched_fwd_exists` resolves
    SOME defect w via Lindenbaum `.choose`, but the resolved w is opaque
    and cannot be forced to equal a specific target phi. Three sub-approaches
    all fail:
    (a) **Pigeonhole on active_defects**: Active defects never shrink (F-
    persistence keeps all defects active forever), so no counting argument
    works.
    (b) **bx11_earlier minimum**: BX11 ordering is non-transitive (dead end
    #15), so no global minimum exists among defects. `target_stays_direct_in_fold`
    requires target to beat ALL others, which can't be guaranteed.
    (c) **Self-resolving chain redesign**: `self_resolving_fwd_step` resolves
    a specific target AND preserves its own F-obligation, but does NOT preserve
    F-obligations for other formulas (f_carry inclusion leads to dead end #13
    inconsistency). Round-robin targeting with `self_resolving_fwd_step` loses
    F(phi) at resolving steps for other formulas, so F(phi) may not survive
    to phi's round-robin turn. Similarly, `fwd_succ` at resolving steps kills
    f_carry (dead end #24).
    **Root cause**: Fundamental tension between target resolution and
    F-obligation preservation in Lindenbaum-based chains. Any seed that includes
    both target and f_carry is potentially inconsistent (dead end #13), and any
    seed without f_carry loses F-obligations at resolving steps.

35. **Path A: Oracle-based chain replacement partially viable but blocked by
    defect-count sorry** (task 93, plan v44 Phase 4): The oracle infrastructure
    (`hintikka_step_for_sigma_sig`) provides G-propagation, H-backward, and
    Until-propagation, all sorry-free. The strategy: F(φ) → (⊤ U φ) by BX12,
    then oracle defect-discharge resolves (⊤ U φ). Two blockers:
    (a) **Defect-count decrease sorry** (`OracleStep.lean:452`): Lindenbaum
    extension may introduce new Until-defects not present in the original MCS,
    so `defect_count(sigma_sig(oracle_step)) < defect_count(sigma_sig(w))`
    is not proven. This sorry exists in the "fully sorry-free oracle"
    `hintikka_step_oracle_for_sigma_sig`.
    (b) **Enhanced oracle seed F-preservation**: Adding `{F(φ) | F(φ) ∈ w,
    φ ∈ Sigma}` to the oracle seed IS consistent (it's a subset of w.formulas),
    which would give F-preservation. But this is novel infrastructure not yet
    built, and the defect-count sorry (a) blocks the termination argument
    regardless.
    **Positive finding**: The enhanced oracle seed approach avoids dead end #13
    because the additional F-formulas are already in the MCS (subset
    consistency), unlike the f_carry approach which adds formulas to a seed
    that may conflict with g_content.

36. **Path B: Quasimodel-derived BFMCS blocked by same Lindenbaum opacity**
    (task 93, plan v44 Phase 6): Replacing dd_bfmcs entirely with a
    palindromic quasimodel chain faces the same irreducible obstruction.
    Two independent blockers:
    (a) **F/P eventuality resolution**: ANY Int-indexed MCS chain based on
    iterated Lindenbaum extensions via `Classical.choose` makes the
    chain(n+1) MCS opaque. The proved lemma "alpha in chain(n+1) implies
    F(alpha) in chain(n)" (contrapositive of g_content propagation) goes
    the WRONG direction -- it gives F-membership at the PREDECESSOR, not
    a WITNESS at a successor. F(phi) in chain(n) requires finding m > n
    with phi in chain(m), which requires controlling what `set_lindenbaum`
    chooses, regardless of whether the chain uses preserving_fwd_step,
    oracle_step, or any other Lindenbaum-based construction.
    (b) **Until/Since step transfer**: Backward Until coherence requires
    the step transfer `(phi U psi) in chain(r+1) AND phi in chain(r)
    implies (phi U psi) in chain(r)`. This requires pulling Until from a
    successor into the current step. The only known mechanism is the
    deterministic chain's bot-Until linking `(bot U alpha) in chain(r)
    iff alpha in chain(r+1)`, which is NOT available for Lindenbaum-based
    chains. The F-membership lemma gives `F(phi U psi) in chain(r)` from
    `(phi U psi) in chain(r+1)`, but there is NO BX axiom
    `phi AND F(phi U psi) -> phi U psi` (this would require a "next"
    operator). Under reflexive semantics, `or_until_in_mcs` gives
    `psi OR (phi AND (phi U psi)) -> phi U psi`, but this requires
    `(phi U psi)` at the SAME time step, not a future step.
    **Root cause**: The irreducible obstruction is the gap between
    SEMANTIC temporal reasoning (which can freely reference future/past
    states) and SYNTACTIC MCS membership (which is local to one MCS).
    Lindenbaum extensions are non-constructive (axiom of choice) and
    provide no inter-step structural guarantees. This obstruction applies
    to ALL three paths (C, A, B) equally.

37. **Chronicle construction is NOT a dead end** (task 107, report 16):
    Assessment confirmed that all chronicle gaps are engineering problems, not
    mathematical impossibilities. The PointInsertion lemmas (2.4, 2.6) are
    sorry-free. The g_content_chain_property blocker was traced to an
    architecturally wrong unary g function (report 17), not a fundamental
    obstruction. Binary g(x,y) with C3 decomposition resolves the root cause.
    **This is an anti-assessment, not a dead end**: the chronicle path is viable
    and is the primary completeness strategy.

### Task 93: Progress and Infrastructure

Six sorry-free helper lemmas proved during v17 Phase 1 (all in
`RootScopedChain.lean`):
- `discharge_single_step`: Given F(psi) in MCS M, exists M' with psi in M'
  and g_content(M) subset M'.
- `discharge_two_step`: Two-target version using BX11 ordering.
- `enriched_resolving_seed_consistent`: Seed {psi, alpha} union g_content(M)
  is consistent when F(psi and alpha) in M.
- `bx11_earlier_resolving_seed_strong`: When target is bx11_earlier than chi,
  produces a resolving alpha from the BX11 compound.
- `rr_fwd_chain_F_obligation_forward`: F-obligation constancy (forward).
- `rr_fwd_chain_F_obligation_backward`: F-obligation constancy (backward).

F-obligation constancy infrastructure: `rr_fwd_chain_F_propagate` reduces
forward_F to "F(psi) cannot persist at every future step". The
`enriched_fwd_step_preserves` gives disjunctive F-preservation at each step.

The core finding: the `.choose` in `set_lindenbaum` (called via
`resolving_enriched_fwd_exists`) is the root cause of the forward_F gap.
Controlling this choice is the only viable path. Standard completeness proofs
(Burgess 1984, Goldblatt 1992, GHR 1994) handle forward_F semantically, not
syntactically.

### Current Strategy: Chronicle Construction (Task 107)

**Status**: The chronicle construction (task 107) is the active completeness strategy.
All three BXCanonical paths (C, A, B) from plan v44 are BLOCKED by Lindenbaum opacity
(dead ends #34-#36). The chronicle escapes this obstruction via controlled PointInsertion.

**BXCanonical obstruction (for reference)**: The gap between SEMANTIC temporal reasoning
(which can reference future/past states freely) and SYNTACTIC MCS membership (which is
local to one MCS). Lindenbaum extensions via `Classical.choose` are non-constructive
and provide no inter-step structural guarantees. The chronicle avoids this by building
MCS via PointInsertion with explicit control over the seed content.

**Chronicle approach (task 107, plan v32 + v53/v55)**:
1. **C4 definition fix**: DONE (report 25).
2. **g_ordered eliminated**: DONE.
3. **A3a/A3b enrichment axioms**: DONE (Phase 2).
4. **Lemma 2.3 (burgessR⟺burgessRSince)**: DONE (Phase 3, sorry-free).
5. **C4 nested case via BX6**: DONE (Phase 4).
6. **Lemma 2.7 gate**: DONE — valid under strict semantics (Phase 5a).
7. **left_mono_until_G + ClosedUnderDerivation + splitting_seed_consistent**: DONE (Phase 5b).
   - `g_content(A) ⊆ B` proved sorry-free via maximality + left_mono_until_G
   - `splitting_seed_consistent` proved sorry-free
   - PointInsertion.lean is sorry-free on critical path
8. **NoUnivBurgessR3 elimination + sorry #1/#3 closure**: DONE (plan v53 Phases 1-2).
   - BurgessR3Maximal reverted to SetDeductivelyClosed, then upgraded to ClosedUnderDerivation
   - Sorry #1 (Lemma 2.6 Case B pos) closed via CUD maximality extraction
   - Sorry #3 (Lemma 2.7 xi-inconsistent) closed via first-conjunct fix
   - Zorn ClosedUnderDerivation sorry resolved — RRelation.lean now sorry-free
9. **lemma_2_7_seed_consistent (sorry #2)**: DONE (plan v53 Phase 3).
   - Closed via BX5+BX7+BX13 chain + list extractors
   - PointInsertion.lean sorry-free on critical path (3 critical-path sorries closed)
10. **NoUnivBurgessR3 stubs**: TODO (Phase 4, bot-guard argument).
11. **EliminationResult restructuring**: TODO (Phase 5, capture B/B'/B'' from Lemmas 2.4/2.6).
12. **C4/C4' hard cases**: TODO (Phase 6, h_c2' parameter restoration).
13. **FUC/FSC coherence + final validation**: TODO (Phase 7).

**The hybrid Int-chain + enriched seed approach should NOT be revisited** (dead ends
#7, #13, #23, #31). The chronicle construction is confirmed to be the right path
(report 16: all gaps are engineering, not mathematical impossibilities).

**Infrastructure already in place** (all sorry-free):
- `deferralClosure`: finite set of formulas reachable by F/P-nesting from root
- `fwd_succ` / `bwd_pred`: sorry-free successor/predecessor step constructions
- `defect_step_choice_early` / `defect_step_choice_early_spec`: F-persistence + resolution
- `fwd_chain_F_persistent`: F(chi) persists across all forward chain steps
- `preserving_fwd_step_F_preserved`: F-obligations preserved at each step
- `target_stays_direct_in_fold`: target guaranteed in M' when bx11_earlier than all others
- Quasimodel infrastructure (1,816 lines across 6 files in `Quasimodel/`)
- Oracle infrastructure in `OracleStep.lean` (sigma-specific oracle sorry-free)
- Restricted parametric truth lemma (sorry-free)
- Backward Until/Since from step transfer (`backward_until_from_step`, sorry-free)
- Deterministic chain with bot-Until linking (Boneyard, sorry-free for backward Until)

**Archived code**:
- `DRMChain.lean` and proof sketch sections 1-30 in `Boneyard/RoundRobinChain/`
- Oracle coherence (qm_bfmcs) in `Boneyard/OracleCoherence.lean`

---

## Other Open Items

### Dense Completeness (task 68, 1 sorry)

- `dense_completeness_fc` needs a separate proof using a dense canonical model
  (e.g., over `ℚ`).
- Cannot reduce to `completeness_over_Int` since `Int` is not densely ordered.
- Independent of the BX canonical construction.

### FMP Truth Preservation (task 82, 0 sorries in active tree)

- The sorries previously in `TruthPreservation.lean` (`mcs_all_future_closure`
  and `mcs_all_past_closure`) have been **archived to Boneyard**. The FMP module
  is currently sorry-free in the active source tree.
- Task 82's description may need reassessment: the original sorries are gone,
  so the task may already be complete or may need a new description.
- **Decidability track only** -- not a path to the completeness representation
  theorem.
- Independent of BXCanonical.

### Soundness (sorry-free)

- `Soundness.lean`, `DenseSoundness.lean`, and `DiscreteSoundness.lean` are
  all **entirely sorry-free**. Confirmed 2026-04-13.

### Examples / Pedagogical (~57 sorries)

- `Demo.lean`, `ModalProofs.lean`, `ModalProofStrategies.lean`,
  `TemporalProofs.lean`, and others.
- Expected and intentional (exercises, demonstrations).

### Boneyard (~14 sorries)

- Archived dead code across `Boneyard/` subdirectories. Expected.

---

## Investigated Dead Ends: Logic Weakening (Task 77)

**Conclusion**: Weakening TM by using a preorder (instead of linear order)
for `D` does NOT provide a viable path to completeness. The F/P witness
blocker is independent of the order structure on `D`.

---

## Representation Theorem Goal

> "TM is complete with respect to TaskFrames over totally ordered abelian groups."

This is the stated ROADMAP goal. The representation theorem must be **general**:
for any countable linear order D arising from a chronicle construction, produce
a TaskFrame model on an AddCommGroup D' that agrees on truth values. This
generality is essential — the same theorem must support:

- **D' = Rat** for the base logic (no density/discreteness axioms)
- **D' = Rat** for the logic extended with the density axiom F'⊤
- **D' = Int** for the logic extended with discreteness axioms G'⊥ ∧ H'⊥
- Any totally ordered abelian group D' appropriate to the frame class

The chronicle construction (Burgess 1982) produces a countable linear order
X ⊂ Q as its limit domain. X is naturally sparse (not necessarily dense or
discrete). The representation theorem embeds X into an appropriate D' and
constructs a TaskFrame D' model preserving truth values.

### Architecture: Natural Inclusion Replaces Cantor Isomorphism

There is ONE semantics (`truth_at`), ONE validity definition (`valid`), and
ONE TaskFrame/WorldHistory infrastructure — unchanged from the current code.

The chronicle construction (Burgess 1982) produces a limit domain X ⊂ ℚ.
X is already a subset of ℚ by construction (midpoints at (x+y)/2, successors
at x+1). The current code maps X into ℚ via a Cantor order-isomorphism
(`Order.iso_of_countable_dense`), which requires proving `DenselyOrdered X`
— the source of the sorry. The fix: replace the Cantor **isomorphism**
(bijection, requires density) with the **natural inclusion** X ⊂ ℚ
(injection, requires nothing). Extend `limit_f` from X to all of ℚ for
non-domain rationals.

**What changes**: Only `ChronicleToCountermodel.lean` (the bridge from
chronicle to countermodel). The Cantor iso pathway (~530 lines) is archived
to `Boneyard/DenseChronicle/` and replaced by a direct extension of `limit_f`
to all of ℚ (~200-300 new lines). The density case in
`CounterexampleElimination.lean` is archived alongside it (the sorry becomes
unreachable). Everything else — TaskFrame, WorldHistory, truth_at, valid,
ParametricRepresentation, RestrictedParametricTruthLemma, Soundness — is
untouched.

**What stays the same**: D = ℚ (as before). The existing parametric
infrastructure works unchanged. The FMCS/BFMCS are still over ℚ, with the
same shifted/rooted pattern using ℚ arithmetic (t − s, etc.).

### The Limit Domain X

Burgess 1982 (p. 372-373) builds X = ⋃ dom f_n by eliminating C4a and C5a
counterexamples one at a time, inserting rational points. The `.density`
counterexample kind in the formalization is a **separate** concern — it
inserts midpoints between ALL adjacent pairs regardless of formula content,
and is the ONLY code path requiring `SetConsistent g` (the sorry at CE:3570).

Without the `.density` case, the limit domain X is a general countable linear
order without endpoints. It may be discrete in some regions (where no C4a
counterexamples arise) and dense in others (where cascading C4a insertions
fill gaps). X is NOT guaranteed to be globally discrete or globally dense for
the base logic — its order structure depends on formula content.

This does not matter for the approach: X ⊂ ℚ regardless, and the natural
inclusion works for any countable sub-order of ℚ.

### Variant Flexibility

The same natural-inclusion approach works across all variants:

- **Base logic**: X ⊂ ℚ (general countable linear order), natural inclusion,
  extend `limit_f` to all of ℚ. D = ℚ.
- **Dense variant** (axiom F'⊤): add density counterexample elimination,
  X becomes globally dense. The Cantor iso X ≅ ℚ is now legitimate (and can
  be used as an alternative to inclusion). D = ℚ. The archived density code
  in `Boneyard/DenseChronicle/` is reactivated for this variant.
- **Discrete variant** (axioms G'⊥ ∧ H'⊥): the discrete axioms ensure X is
  globally discrete (X/Y operators require immediate successors). Then
  X ≅ ℤ via Mathlib's `orderIsoIntOfLinearSuccPredArch`. D = ℤ. This is a
  separate completeness theorem (`valid_discrete`) with its own construction.

### Why AddCommGroup Is Preserved (Not Weakened)

`AddCommGroup D` is **structurally load-bearing** in the TaskFrame semantics.
TaskFrame axioms use 0, +, −. WorldHistory.respects_task uses t − s. MF/TF
soundness requires time_shift + ShiftClosed. Only MF and TF (2 of 30+
axioms) need group structure for soundness; all other axioms are purely
order-theoretic. The `truth_at` definition itself uses zero group operations
— only `LinearOrder D`. We preserve this architecture entirely: D = ℚ
provides the group structure via the natural inclusion.

### Design Constraints

- The logic is NOT weakened: all axioms (including MF/TF) remain sound
- TaskFrame, WorldHistory, truth_at, valid — all UNCHANGED
- ONE semantics, ONE truth definition, ONE validity — no parallel layers
- No `bfmcs_truth_at`, no `SimpleFrame`, no `lo_valid`
- Archive, don't delete: density code goes to `Boneyard/DenseChronicle/`
  for future reuse in the dense variant

**Only the algebraic/canonical model approach is pursued for completeness.**
The representation theorem characterizes TM by showing that every consistent
formula has a model built from the logic's own proof-theoretic structure
(MCS ↔ worlds, truth lemma connecting membership and semantic truth). This
structural correspondence is the scientific contribution — it tells us what
TM *is*, not merely that it is complete.

**Decidability-based completeness is explicitly excluded as a path to the
representation theorem.** A decision procedure can establish
`valid(φ) → provable(φ)` as a bare fact, but it provides no canonical model
construction, no truth lemma, no structural correspondence between
proof-theoretic and semantic notions, and no template for extensions of the
logic. Decidability is of independent interest (see task 82, FMP track) and
may yield a follow-up result, but it does not serve the goal of frame class
characterization.

---

## Paper Alignment Programme (possible_worlds.tex, 2026-07-28; revised same day)

The JPL paper (PossibleWorlds/JPL/possible_worlds.tex) has settled its semantic-core
decisions (PossibleWorlds/Comments/fix.md, Parts A-B): same-sign frame axioms with
identity Nullity (already this repo's axiomatization), nontrivial `D` (already
`[Nontrivial D]`), and — the load-bearing change — **official validity =
maximal-history validity**. Direction of alignment: **the repo's basic definitions
change to match the paper** (definitional alignment). No bridge lemmas, transfer
theorems, compatibility shims, or parallel validity notions: one uniform Ω-free
API, with the mathematical content of countermodel realization absorbed into the
canonical constructions themselves.

- **414** — *refactor semantics to maximal-history validity*: extension order +
  `Maximal` on `WorldHistory` (Zorn extension, shift-preservation); `TruthAt`/
  `valid`/satisfiability/consequence refactored to quantify over maximal histories,
  **removing the Omega parameter entirely** (the false Set.univ-equivalence
  docstrings die with it); Soundness propagated.
- **415** (dep: 414) — *completeness over the new semantics, internalized*: per-class
  weak completeness reproved so canonical/chronicle constructions deliver
  maximal-history countermodels outright (deterministic frames replace the
  singleton-Omega device). Rebases the targets of 169/170/408.
- **416** — *adopt the CO axiom basis*: the paper's single CO axiom (line 3250)
  becomes the official Dedekind-class basis; Reynolds-style gap principles are
  re-derived as internal theorems where proofs need them; Hoelder classification
  (complete ⇒ ≅ ℤ or ℝ; dense+complete ⇒ ℝ) recorded; rebases 408/411 targets.
- **417** (dep: 414) — *semantic FMP*, finite `WorldState` over `D = ℤ`, connected to
  the refactored `TruthAt`, + decidable model checking there (the follow-on
  descoped from 165).

Existing tasks carrying the rest — all rebasing onto the 414 semantics as they land:
**413** (TM conservativity bridge, paper thm:ConservativeExtension),
**169/170/408/361/362** (completeness programme; paper cor:tm-completeness scoped to
WEAK completeness per the settled terminology), **165/410/411/412** (tableau
decidability). Paper-side edits that remain regardless (paper's own mathematics):
weak-completeness wording, the false non-Archimedean footnote (3252-3255), ℤ-time
rescope of UZ/Z1, and the enumeration argument restated as finite W over ℤ.

**Cost note (accepted)**: the refactor temporarily regresses currently-green
theorems (restatement against the new semantics) and removes the Ω degree of
freedom the old completeness proofs exploited — the constructions must now earn
full maximal-history countermodels. This is the intended trade: uniformity and
mathematical quality over incremental cheapness.

## Recommended Priority Order

### Critical Path: Single Sorry Chain

Only ONE sorry blocks `completeness_discrete` (as of task 301 cleanup):

1. **Sole obligation** (CRITICAL): make `nf_nvar_exist_all_depths`
   (KampPrior.lean:212) sorry-free — discharge the n=1 arm (`:361`, the
   depth-`k` arity-2 existential converter for Prior structures) and eliminate
   the n+2 arm (`:364`, e.g. by restricting the domain to n ≤ 1 since only
   n=0,1 are ever called). The named route consumes task 348's
   `bracketEndChar_kvE2Ext_correct_two_prior_frag` (task 309 Phase 14).
   Task 303's old terminus `existPart_succ_n1_bypass` (KampBypass.lean) is
   historical/mis-scoped — that file was Boneyard'd (task 305 P0; see §31 and
   REVIEW_codebase-restructure/01_discrete-completeness-finish-map.md).

2. **Task 95**: `#print axioms` audit on completeness theorem. After task 303.

**Previously two chains — now one** (task 301 finding): Task 273 closed
the Stavi chain (Chain A). The `chronicle_gap_contradiction` chain (Chain B)
is dead code — `completeness_discrete` uses the Reynolds pipeline
(`countermodel_discrete_reynolds_v2`) which bypasses it entirely. Tasks 155
and 268 abandoned (task 301 phase 4).

### Sorry Cleanup: Zero Sorries for Publication

4. **Move dead Chronicle/BXCanonical/Bundle code to Boneyard/**: ~17 sorries eliminated by archival (succ_cofinal, Bundle/SuccRelation, Bundle/SuccExistence, Bundle/UntilSinceCoherence, BXCanonical/Frame, BXCanonical/Chronicle dead sorries). These are superseded by the Reynolds bypass.
5. **Close remaining WeakCanonical sorries**: TruthLemma (6), StaviCompleteness (3), OrderedSum (1), GoodStructures (1) — assess which are on the Reynolds pipeline path vs. dead code.
6. **Task 176**: Relocate Chronicle/ out of BXCanonical/, archive dead BXCanonical subtree.

### Post-Completeness: Structural Refactor → Publication

7. **Task 175**: Naming conventions + bridge/wrapper cleanup
8. **Task 180**: Copyright headers, universe polymorphism, line limits
9. **Task 131**: Restructure file hierarchy
10. **Task 161**: Final namespace rename
11. **Task 183**: Documentation standards
12. **Tasks 185-193**: Tactics library + codebase refactoring
13. **Tasks 177-178**: Final documentation + publication examples

### Documentation Track: BimodalReference Living Monograph

14. **Task 313** (skeleton, COMPLETED): five-part living monograph at
    `typst/BimodalReference.typ` (repository root, not under the library tree), replacing the
    prior flat 7-chapter
    reference core. Parts and sync-classes: I Motivation and Positioning (◇ outlook,
    stub), II The Bimodal Core (✓ lean-verified, ⧖ completeness), III Expressive Power
    and Its Price (◇ outlook, Lk-embargoed, stubs), IV Automated and Neural Reasoning
    (✓ lean-verified, complete), V Toward the Logos (◇ outlook, stubs). Infrastructure:
    `scripts/typst-status-counts.sh` + `scripts/typst-sync-check.sh` (mechanical
    claim-verification, extending the task-312 SYNC-MAP contract).
    - **Task 314**: Part I motivation chapter ("Why Construct Possible Worlds")
    - **Task 315**: Part III expressive-power chapters (four, Lk-abstracted)
    - **Task 316**: Machine-readable JSONL appendix, exported from Lean
    - **Task 317**: Part V Logos chapters (constitutive structure, tensed counterfactual logic)
    - **Task 318**: Lk slot-in for the Decidability Frontier chapter (post-TACAS-acceptance only)

---

## Task Cross-Reference

> **Updated 2026-05-05 (task 107: Phases 1-3 complete, Burgess alignment migration, ROADMAP update)**

| Task | Status | Description | Depends On |
|------|--------|-------------|------------|
| 91 | **[COMPLETED]** | Rewrite ROAD_MAP.md for BX reflexive semantics | — |
| 90 | **[COMPLETED]** | Research Option A vs Option B for Until/Since closure | — |
| 92 | **[COMPLETED]** | Implement Until/Since truth lemma approach | 90 |
| 98 | **[COMPLETED]** | Implement eventuality resolution (Frame.lean:653, 690) | 92 |
| 102 | **[COMPLETED]** | Close remaining Frame.lean sorries (675, 704, 440) | 98 |
| 93 | **[COMPLETED]** | Irreflexive semantics switch: seriality axioms, BX8 removal, defect step redesign | 102 |
| 95 | [NOT STARTED] | `#print axioms` audit on completeness theorem | 107 or 109 |
| 103 | **[COMPLETED]** | Comprehensive ROAD_MAP.md rewrite for post-Until/Since state | — |
| 94 | **[COMPLETED]** | Archive strict-semantics legacy files to Boneyard | 103 |
| 104 | [NOT STARTED] | Clean up superseded tasks + fix state.json | — |
| 105 | [NOT STARTED] | Update stale sorry-blocker comments in BXCanonical | — |
| 106 | [IMPLEMENTING] | Rewrite ROADMAP.md for irreflexive semantics | 93 |
| 107 | **[COMPLETED]** | Burgess chronicle construction: Phases 1-9 complete, 1 sorry remains (density g-value consistency at CE:3570, task 117 will fix) | 113 |
| 117 | **[RESEARCHED]** | Replace Cantor iso with natural inclusion X ⊂ ℚ. Archive density case + Cantor pathway to Boneyard. Extend limit_f to all of ℚ. Eliminates last Chronicle sorry. | 107 |
| 116 | [NOT STARTED] | Redefine G, H, F, P in terms of U and S following Burgess 1982 | 107 |
| 115 | [RESEARCHED] | Remove A4a + simplify BX2 (post-107 cleanup, subsumed) | 107 |
| 109 | [NOT STARTED] | Close 23 BXCanonical sorries (5 critical-path + 18 irreflexive-consequence) | 93 |
| 112 | **[RESEARCHED]** | Systematic literature study for task 107 representation theorem | — |
| 82 | [NOT STARTED] | FMP Truth Preservation (weak completeness, independent) | — |
| 68 | [RESEARCHED] | Dense completeness via Q canonical model | — (independent) |
| 60 | [NOT STARTED] | Remove `discrete_Icc_finite_axiom` (may already be gone) | — |

---

*Last updated: 2026-06-16 (task 301: completeness cleanup and roadmap update. Key findings: (1) SOLE remaining sorry is existPart_succ_n1_bypass k>0 (task 303). (2) chronicle_gap_contradiction is dead code. (3) Task 273 completed ~1400 lines of sorry-free proofs. (4) Tasks 155, 268, 200, 254, 176 abandoned. (5) KampBypass.lean factored from 4488 to 4 files. (6) VecEADecomposition archived to Boneyard.)*
