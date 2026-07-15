# Task 376 — Re-Signed Zone-Decomposed Char Seam Interface + Arity-General Provider Engine Spec

**Session**: sess_1784138518_4af6d5 · **Agent**: lean-research-hard-agent (H2/H3/H4) · **Date**: 2026-07-15
**Mode**: lean4 `--hard --lit` (Rabinovich 2014, doc_id `rabinovich_2014`, Lemma 5.3 chunk_0014 / Cor 5.4(1) chunk_0015)
**Reference-grounding tier**: Tier 1 (literature-backed, lean4 strict)
**Machine artifact**: `specs/376_arity_general_zone_decomposed_char_engine/reports/01_zone-seam-probe.lean`
— compiled this session via `lake env lean` (exit 0; the ONLY sorry is the deliberately
sorry-bodied elaboration probe, line 61). Three probes: two sorry-free theorems + one
elaboration-bar statement.

---

## Verdict (headline)

**The re-signed interface exists, elaborates, and escapes both refutations.** The seam pair
`hcharFib`/`hcharFibSoundP` (refuted by the compiled `seamPair_joint_refutation`,
`SeamPairRefutationProbe.lean:47/:145`) is replaced by a zone-guarded pair
{`hcharFibZone`, `hcharFibZoneSound`} — same shape as the old pair PLUS three guards on each:
(i) **marked-fiber guard** `qnf.2 σ = true`, (ii) **zoneHolds guard**
`zoneHolds M [w,x,t] (nf0_zoneSpec σ.atom_assgn) u` on the evaluation point, and (for the
soundness seam) (iii) **anchor-order + carrier-eval gating** (`x < w → w < t →` + the three
`igPtWFib`/`igEpLFib`/`igEpRFib` evals). Machine-grounded this session:

1. **Refutation-escape is a compiled sorry-free theorem** (`zoneGuard_blocks_seamPair_counterexample`,
   probe file line 27): the exact instantiation step (3) of the old refutation — `w := w'`,
   `τ := σ* :=` characteristic of `(w0,w0,x,t)`, `x1 := w0` — now FAILS its zoneHolds premise
   whenever `w' ≠ w0`, because σ*'s zone is AtW (both w-bits false), forcing `w0 = w'`.
2. **The re-signed statement elaborates** in the exact `correct_prior` conclusion context
   (`hcharFibZone_reSigned_gate_elaborates`, probe line 61, sorry-bodied by design — the
   mission's stated deliverable bar).
3. **Consumer re-threading costs nothing**: the key existing consumer
   (`bracketEndChar_kvFib_realize_futT`, `InteriorGateGeneralK.lean:1565`) re-proves against the
   GUARDED seam sorry-free (`bracketEndChar_kvFibZone_realize_futT`, probe line 105) — the zone
   witness is derived structurally from the native `untl` firing (`t < x1`) plus bracket anchor
   order, exactly Rabinovich Cor 5.4(1)'s witness extraction (chunk_0015 lines 23-29).

**Residual risk surfaced (do not skip):** a genuinely new cross-anchor-context attack against
the SOUNDNESS seam was constructed during adversarial self-verification (§Q2.3). It is blocked
by the marked-fiber guard + carrier gating for the intended `charFib`, but its full exclusion is
an instantiation-time fact, not an interface-time fact. The plan's Phase 1 MUST therefore be a
bounded probe against the re-signed pair (mirroring the Gap-B probe methodology) before any
volume work. This report hands the planner a refutation-hardened target, not a proven-safe one —
that distinction is exactly what the previous seam design failed to make.

---

## Findings

### H3 Tier-1 lemma mapping table (Rabinovich 2014 → Lean targets)

| Source | Prop/Location | Lean Identifier | Type Signature | Status |
|--------|---------------|-----------------|----------------|--------|
| Rabinovich 2014 | Lemma 5.3, chunk_0014 lines 7-41 (paper §5, p.8-9): induction on n; step case-splits on `r0 = inf{z ∈ (z0,z1) : P1(z)}` into (1) P1 absent → ∀-form, (2) `K⁺(P1)(z0)` ∧ `On(P2…, z0, z1)`, (3) `∃r0` INF-definable ∧ `On(P2…, r0, z1)` | `kampPrior_zoneProviders` (NEW — the arity-general engine, §Q3) | `(k : Nat) → (deps : ExistProviders sig atomMap k') → ExistProviders sig atomMap k` with `existF : (n : Nat) → NormalForm sig k (n+1) → Formula` built by recursion on n (peel first witness; three-disjunct case split; re-anchor) | pending (the follow-up implementation's core) |
| Rabinovich 2014 | Lemma 5.3 basis n=1, chunk_0014 line 9 (p.8): `¬∃x1 ∈ (z0,z1) P1(x1) ≡ (∀y ∈ (z0,z1)) ¬P1(y)` | `KampPrior.lean:519` arm (n=1 instance, k≥2) | goal shape verified by task 374 report 01 §Q1: `∃ A, ∀ M h_UZ h_SZ t, temporal_truth M atomMap t A ↔ ∃ env : Fin 1 → M.carrier, nf_eval_nf M (_k+3) 2 (insertEnv env t) _sub_nf` | sorry (target; = engine instance n=1) |
| Rabinovich 2014 | Lemma 5.3 inductive step n→n+1, chunk_0014 lines 11-41 (p.8-9) | `KampPrior.lean:522` arm (n≥2 instances) | `∃ A, … ↔ ∃ env : Fin (n+2) → M.carrier, nf_eval_nf M (k+1) (n+3) (insertEnv env t) sub_nf` | sorry (target; = engine instances n≥2, same induction) |
| Rabinovich 2014 | Cor 5.4(1) ⇐ witness extraction, chunk_0015 lines 23-29 (p.9): `y1` satisfies `αn ∧ βn+1 Until αn+1` → `∃ y2 > y1` with `αn+1` at `y2`, `βn+1` along `(y1,y2)` — order content fired by the `Until`, never by a per-point anchor-pinning formula | `bracketEndChar_kvFibZone_realize_futT` (probe line 105, compiled sorry-free) | see §Q1 block C — `igFoldBitFib qnf igZFutT σ = true` + `igEpRFib`-eval at `t` + zone-guarded soundness seam → `∃ x1 > t, nf_eval_nf M k 4 [x1,w,x,t] σ` | transcribed (this session; production landing = plan phase) |
| Rabinovich 2014 | §5 design invariant (chunk_0014 line 39 + chunk_0015 throughout, p.8-9): the `F_i`/`P_i` are UNARY formulas; anchor relations are carried positionally by the bracket, `K⁺` is an atomic operator of the canonical expansion | `hcharFibZone` / `hcharFibZoneSound` (probe lines 73-96) — the zone guards make order content structural (zoneHolds) so only point-content rides `charFib` | see §Q1 blocks A/B (full Lean text) | transcribed as statement (elaborates); instantiation = the engine |
| Rabinovich 2014 | Dedekind-completeness / `inf` (Lemma 5.3 Case 2, chunk_0014 lines 19-27, p.8) | `semantic_prior_UZ` / `semantic_prior_SZ` (`PriorDefs.lean:22/:33`) — the discrete first/last-occurrence analog | (existing, unchanged; load-tested by the landed k≤1 arms) | transcribed (pre-existing) |

### Q1 — The exact re-signed statements (compiled, verbatim from the probe file)

All three blocks below are byte-verbatim from
`specs/376_arity_general_zone_decomposed_char_engine/reports/01_zone-seam-probe.lean`, which
compiles against the current tree (`lake env lean`, exit 0). They are stated at the
`correct_prior` seam (`ExteriorGateAssembleK.lean:574-581` is what they replace); the
`gate_match` (`KampPrior.lean:1073-1082`) and `step_sound`/`step_complete`
(`InteriorGateGeneralK.lean:2115/:1742-1746`) copies re-sign identically (they are byte-mirrors
of the same binders — verified by the task-374 probe's docstring cross-checks and direct reads
this session).

**Block A — Seam 1, replaces `hcharFib` (EGA:574-578).** Added guards vs the old binder:
`qnf.2 σ = true` and `zoneHolds` on `u`:

```lean
(hcharFibZone : ∀ (w : M.carrier),
  nf_eval_nf M (k + 2) 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf →
  ∀ (σ : NormalForm sig (k + 1) 4), qnf.2 σ = true →
  ∀ (u : M.carrier),
    zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t)))
      (nf0_zoneSpec (NormalForm.atom_assgn σ)) u →
    (temporal_truth M atomMap u (charFib (k + 1) σ) ↔
      nf_eval_nf M (k + 1) 4 (Fin.cons u (Fin.cons w (Fin.cons x (fun _ => t)))) σ))
```

**Block B — Seam 2, replaces `hcharFibSoundP` (EGA:579-581).** The old binder was w-universal,
unguarded, qnf-independent — the refutation's lever. The re-signed form keeps it render-FREE
(preserving task 370's decircularization) but adds anchor order, the three carrier evals,
the marked-fiber guard, and the zoneHolds guard:

```lean
(hcharFibZoneSound : ∀ (w : M.carrier), x < w → w < t →
  (igPtWFib (nf_depth0_char_formula atomMap h_surj) (charFib (k + 1)) qnf.1
    (igFoldBitFib qnf)).eval_at M atomMap w →
  (igEpLFib (nf_depth0_char_formula atomMap h_surj) (charFib (k + 1)) qnf.1
    (igFoldBitFib qnf)).eval_at M atomMap x →
  (igEpRFib (nf_depth0_char_formula atomMap h_surj) (charFib (k + 1)) qnf.1
    (igFoldBitFib qnf)).eval_at M atomMap t →
  ∀ (τ : NormalForm sig (k + 1) 4), qnf.2 τ = true →
  ∀ (x1 : M.carrier),
    zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t)))
      (nf0_zoneSpec (NormalForm.atom_assgn τ)) x1 →
    temporal_truth M atomMap x1 (charFib (k + 1) τ) →
    nf_eval_nf M (k + 1) 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) τ)
```

**Block C — consumer re-threading witness (sorry-free).** The endpoint extraction re-proved
against the guarded seam; the marked-fiber guard is supplied by the fold-bit decode
(`igFoldBitFib qnf zs σ = decide (qnf.2 σ = true ∧ nf0_zoneSpec σ.atom_assgn = zs)`), and the
zone witness by `t < x1` (from the `untl` firing) + `x < w < t` + transitivity:

```lean
theorem bracketEndChar_kvFibZone_realize_futT … 
    (σ : NormalForm sig k 4) (hz : igFoldBitFib qnf igZFutT σ = true)
    (hepR : (igEpRFib charBase charFib qnf.1 (igFoldBitFib qnf)).eval_at M atomMap t) :
    ∃ x1 : M.carrier, t < x1 ∧
      nf_eval_nf M k 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ
```

(Full text in the probe file; proof follows `IGGK:1577-1589` verbatim plus a 15-line zoneHolds
discharge.) The `_pastX` mirror is symmetric (`snce` firing, `igZPastX`, `x1 < x`).

**Why every consumer can supply the new guards** (verified against current sources):
- `step_complete` (`IGGK:1733`): has the render `hw`; its `hz'` fold biconditional
  (`IGGK:1773-1795`) already RECONSTRUCTS `zoneHolds` from the realizer's atom layer (forward
  direction lines 1785-1793) and the zone spec from `nf0_zoneSpec` (reverse, lines 1797+) —
  i.e., the guard is exactly the data `step_complete` already manufactures.
- `step_sound` (`IGGK:2101`): destructures the carrier `.holds` into per-w evals (`hveah`,
  `IGGK:2137`, per task 370 report 02 §3 rows 1-2) — supplying the carrier-eval gates; anchor
  order comes from the carrier's order literals; all its char-seam uses go through
  `realize_futT/_pastX`-shaped extraction where the zone is structural (Block C).
- `realize_futT/_pastX` (`IGGK:1565/:1597`): Block C, compiled.
- `hreal` obligation / `kampPrior_hreal_supply` (`InteriorHrealSupplyK.lean:61`): its seven-zone
  case split is BY zone (`nf0_zoneSpec (atom_assgn σ)`), so the zoneHolds premise is available in
  every arm by construction.
- Grep confirms NO consumer invokes the char seams at an unmarked σ (`qnf.2 σ = false`) — the
  exclusion rows (`hexcl*`, EGA:609-658) are separate binders untouched by this re-signing.

### Q2 — Why the re-signed pair escapes the refutations (attack this hardest)

**Q2.1 — Escape from the compiled Gap-B probe (`seamPair_joint_refutation`,
`SeamPairRefutationProbe.lean:47`; non-vacuity `:145`) — machine-verified.** The old
refutation's three steps: (1) σ* := characteristic of `(w0,w0,x,t)`; (2) `hcharFib` at
`w := w0` `.mpr` gives `charFib σ*` true at `w0`; (3) `hcharFibSoundP` at `w := w' ≠ w0`,
`x1 := w0` forces σ*'s coincidence atoms over `[w0,w',x,t]` — contradiction with linearity.
Against the re-signed pair, step (3) must additionally supply
`zoneHolds M [w',x,t] (nf0_zoneSpec σ*.atom_assgn) w0`. σ*'s zone is AtW — bits
`(0<1) = (1<0) = false` — so zoneHolds demands `¬(w0 < w') ∧ ¬(w' < w0)`, i.e. `w0 = w'`,
contradicting `w' ≠ w0`. This is now the compiled sorry-free theorem
`zoneGuard_blocks_seamPair_counterexample` (probe line 27): the counterexample instantiation
point is UNREACHABLE. Note step (2) survives (at `w := w0` the zone guard is satisfiable at
`u := w0`) — the refutation dies precisely at the cross-`w` transport, which is the
un-Rabinovich element the old signature permitted.

**Q2.2 — Escape from Gap A (shift-homogeneous Prior models; task 374 report 01, Medium-High).**
Gap A's argument: the old ↔ forces `truth-set(charFib σ*) = {w0}`, not shift-invariant, while
fixed-formula truth sets in shift-homogeneous models are shift-invariant. Under the zone guard
the ↔ is asserted only on `{u : zoneHolds M [w,x,t] (zone σ) u}` — a set that MOVES with the
anchor context. A shift automorphism `s` maps a valid instantiation `(w,x,t,u)` to
`(w+s,x+s,t+s,u+s)`, and BOTH sides of the guarded ↔ transport along it (nf_eval, zoneHolds,
and temporal_truth are all automorphism-equivariant); the demand "truth set equals a
non-invariant point set" never arises because no single fixed set is pinned across contexts.
(Pen-and-paper over read definitions, same epistemic status as Gap A itself — flagged Medium.)

**Q2.3 — NEW adversarial attack found against my own Seam 2, and its status (the honest part).**
Attempted refutation of Block B in the Gap-B style: pick TWO anchor contexts `(w,x,t)` and
`(w',x,t)` (both satisfying the guards) sharing an evaluation point `x1` in the same zone, with
a τ whose ANCHOR-content (pred/fiber atoms of positions 1-3) holds in context A but not B —
then `charFib τ` at `x1` would have to be both true and false. Construction sketch: model
`(ℤ, P = {1})`, τ := characteristic of `(5,1,0,10)` (which declares `P` at the w-slot), contexts
`w = 1` vs `w' = 3`. **Blocked as follows**: (i) without the marked-fiber guard the attack GOES
THROUGH — `qnf.2 τ = true` is therefore load-bearing, not cosmetic (τ must be in the fixed
qnf's fiber, tying its anchor content to qnf's); (ii) the carrier-eval gates make context B
non-certifiable — `igPtWFib` at `w' = 3` contains `charBase`/`charFib`-literals for qnf's w-slot
1-type and fold bits, which fail at an anchor whose (deep) point content differs from the
rendered witness's. Residual: (ii) is an argument about the INTENDED `charFib`; whether the
carrier literals pin anchor content to the full depth τ can discriminate is an instantiation-time
question. A universal (∀ charFib) Gap-B-style refutation is structurally obstructed — the gates
themselves are `charFib`-indexed, so degenerate `charFib` choices (e.g. `fun _ _ => ⊥`) make the
premises uninstantiable rather than the conclusion false — but "obstructed" is not "proved
impossible". **Consequence for the plan (binding recommendation): Phase 1 = a bounded
refutation-or-clearance probe against {Block A, Block B} jointly, in the exact
`SeamPairRefutationProbe.lean` methodology (~60-100 lines), attempting BOTH the old
counterexample (must fail — already compiled) and the §Q2.3 cross-context attack (expected to
fail at the carrier gate; if it succeeds, STOP and re-sign with a render-gated Seam 2 variant
before any volume work).** This is exactly the discipline that would have caught the old pair
one task earlier.

**Q2.4 — Why this is the Rabinovich-faithful signature.** Chunk_0015's witness extraction never
transports a point-formula across anchor contexts: the next witness is fired by the `Until`
(`y2 > y1` with `βn+1` along `(y1,y2)`, lines 23-29), and anchor relations are positional
(bracket), not formulaic. The zone guards encode precisely that: order content enters as
`zoneHolds` (structural), and `charFib` carries only point content relative to a CERTIFIED
context — the "only unary content rides the formula" invariant, expressed at arity 4 by
guarding rather than by re-typing `charFib` to arity 1 (which would re-open the frozen carrier
trio — forbidden).

### Q3 — The arity-general provider engine (Rabinovich Lemma 5.3 → Lean shape)

**Target declaration set** (names indicative; the planner sizes and places them — suggested new
leaf file `NfMultiAnchorBridge/ZoneProviderEngine.lean`):

```lean
-- The n-recursion core (Lemma 5.3): peel the FIRST witness variable, three-disjunct split.
noncomputable def zoneExistF (atomMap …) (h_surj …) (k : Nat)
    (deps : DepthDeps sig atomMap k)   -- depth-(< k+1) recursive supplies from KampPrior's IH
    : (n : Nat) → NormalForm sig (k+1) (n + 1) → Formula
  | 0, sub => …            -- no witness variables: atom-layer char (existing depth-0 route)
  | n + 1, sub =>          -- Lemma 5.3 step: disjunction of
      …                    -- (1) "no P1 in the interval": negated Until/Since chain (∀-form)
      …                    -- (2) K⁺-analog: UZ first-occurrence at the left anchor ∧ zoneExistF n (reanchor₂ sub)
      …                    -- (3) Until-fired r0 (INF-analog via UZ) ∧ zoneExistF n (reanchor₃ sub)

theorem zoneExistF_correct … :
    temporal_truth M atomMap t (zoneExistF … n sub) ↔
      ∃ env : Fin n → M.carrier, nf_eval_nf M (k+1) (n+1) (insertEnv env t) sub

-- Bundle instance: greens kampPrior_existProviders_of_ih at ALL depths (dissolves Gap C).
noncomputable def kampPrior_zoneProviders … : ExistProviders sig atomMap (k+1) :=
  ⟨zoneExistF …, zoneExistF_correct …⟩
```

**Paper-to-Lean correspondence (chunk_0014 lines 11-41):**

| Paper element | Lean element |
|---|---|
| induction on n (all `Pi` simultaneously) | structural recursion of `zoneExistF` on `n`, `sub` re-anchored per step |
| `r0 = inf{z ∈ (z0,z1) : P1(z)}` (Dedekind) | UZ first-occurrence witness (`semantic_prior_UZ`, `PriorDefs.lean:22`) — the discrete `inf`; load-tested by the landed k≤1 arms |
| Case 1 `(∀y)¬P1(y)` (line 31) | negated `Until` chain disjunct (the n=1 basis — and the whole of the :519 instance) |
| Case 2 `K⁺(P1)(z0) ∧ On(P2…, z0, z1)` (line 33) | left-anchor-adjacent firing ∧ recursive call at n, same anchors |
| Case 3 `∃r0 (INF(z0,r0,z1,P1) ∧ On(P2…, r0, z1))` (line 35) | `Until`-fired intermediate anchor ∧ recursive call RE-ANCHORED at r0 — the re-anchoring is the `renameNF`-style environment surgery (rot5 pattern precedent, `ExteriorNegationK.lean:375`) |
| closure under ∧/∨/∃ (lines 37-41) | formula constructors; correctness by the Cor 5.4(1) ⇐ induction (witness split `y2 ≤ xn+1` vs `xn+1 < y2`, chunk_0015 lines 31-37) |

**How this discharges the targets together:**
- `:519` (n=1, k≥2): the arm calls the gate route (`gate_match` re-signed per §Q1) whose
  fiber layer + `hcharFibZone` instantiation come from `zoneExistF` at depth `_k+2`; the n=1
  existential IS `zoneExistF 1`.
- `:522` (n≥2): directly `⟨zoneExistF (n+2) sub_nf, zoneExistF_correct …⟩` — no separate
  machinery, same induction (route (a)-amended, per task 374 adjudication; route (b) remains
  closed: `ExistProviders.existF` is all-arity, `P.existF 4` consumed at 38 sites).
- Gap C dissolves: `kampPrior_zoneProviders` supplies `existF 4` at every depth, greening
  `kampPrior_existProviders_of_ih` beyond depth 0 (only `kampPrior_existProviders_zero`,
  `KampPrior.lean:1409`, is green today).
- `charFib` instantiation: `charFib (k+1) σ :=` conjunction of σ's point pred-content
  (depth-0 char) with per-fiber-element clauses built from `zoneExistF` at depth k — the
  guards of Blocks A/B are exactly what make this finite formula sufficient (order content
  never needs to be expressed by it).

### Q4 — Gap D and Gap E sizing (for the planner; not solved here)

**Gap D — general-m supplies for ledger rows 6/10/11** (grep re-confirmed this session):
- Row 6 `hexcl` (EGA:609-614): NO general-m supply exists anywhere; the only landed interior
  supply leaf is `kampPrior_hreal_supply` (row 5). This is the riskiest row: no
  interior-exclusion precedent to pattern-follow. Its shape (interval-bounded non-realization
  of UNMARKED σ) is the contrapositive face of the zone machinery — the same
  `hz'`-style fold biconditional gives `¬realizer → ¬marked` per zone. Size: 1 phase,
  ~200-400 lines, AFTER the seam re-signing lands (it consumes the same guards).
- Rows 10/11 `hexclSlicePast/Fut` (EGA:631-644): only `_zero` variants exist
  (`kvE_hexclSlicePast_supply_zero`, `ExteriorPinnedConversePastK.lean:769`;
  `kvE_hexclSliceFut_supply_zero`, `ExteriorPinnedConverseK.lean:1250`). General-m follows the
  landed general-m pattern of rows 8-9/12-13 (`kvE_hsliceFut_supply`
  `ExteriorDeepSliceSupplyK.lean:131/:161`; `kvE_hexclDeepFut_supply`
  `ExteriorDeepExclSupplyK.lean:77/:107`). Size: 1 phase per pair, ~150-350 lines each,
  independent of the engine (parallel-dispatchable, territory-disjoint files).

**Gap E — general-k arm assembly scaffolding**: `kampArm_*_kv` — zero hits repo-wide
(re-verified). Needed: general-k analogs of the k≤1 stack — trichotomy arms
`kampArm_{past,diag,future}_k{0,1}` (`AggregateHookDischarge.lean:1686-1747/:2087`,
`AggregateOffDiagK1.lean:1456/:1485`), aggregate carriers (`aggAtomK1*`, `aggPop1/aggPop1F`),
and translation glue. At fixed k≤1 this took multiple prior tasks per depth; the general-k
version is parameterized ONCE (that is the payoff of the re-signed per-qnf gate certificate
already being general-k). Size: 2-3 phases, ~300-500 lines each; strictly after the engine +
re-signed gate land; consumes (never edits) the PRESERVE list.

**Suggested phase-sizable target set for the plan** (H8-sized, one agent run each):
1. **Phase 1 (bounded, ~60-120 lines)**: joint refutation-or-clearance probe on
   {Block A, Block B} incl. the §Q2.3 cross-context attack. STOP/re-sign gate.
2. **Phase 2**: re-sign the additive `*Fib` sibling chain in place — `step_sound`
   (`IGGK:2101/:2115`), `step_complete` (`IGGK:1733/:1742-1746`), `correct_prior`
   (`EGA:559-660`), `gate_match` (`KampPrior.lean:1058-1181`) — substituting Blocks A/B;
   re-thread `realize_futT/_pastX` (Block C is the compiled template); full `lake build` green
   with the two sorries unchanged; frozen surfaces byte-identical.
3. **Phases 3-4**: `zoneExistF` engine — n=0/1 core + correctness (Phase 3), n≥2 step with
   re-anchoring + Cor 5.4(1) ⇐ witness induction (Phase 4).
4. **Phase 5**: `charFib` instantiation + `hcharFibZone`/`hcharFibZoneSound` discharge at the
   :519 site; green `kampPrior_existProviders_of_ih` at all depths.
5. **Phases 6-7**: Gap D rows (6, then 10/11 — 10/11 parallelizable with earlier phases).
6. **Phases 8-9**: Gap E arm assembly; retire `:519` then `:522`; zero sorries in
   `KampPrior.lean`; `lake build` green; `lean_verify` axiom-clean.

**Constraint compliance**: all edits are within the EDITABLE additive `*Fib` sibling chain
(task 370 report 02 §3 blast-radius table rows 1-5, re-read this session); FROZEN surfaces
(`bracketEndChar_kv` body `CarrierKv.lean:240-249`, both defeq bridges `IGGK:339-351` /
`CarrierKv.lean:294-351`, carrier trio, `kampPrior_site_rungK_gate_match` `KampPrior.lean:941`
with live consumer `EndIntervalConsumerK.lean:248`) require ZERO touches under this design —
no blocker to report. PRESERVE list is consumed, never discarded (the `hreal`/`hslice*`/
`hexclDeep*` supplies keep their signatures; only the two char-seam binders change, plus the
matching parameter lists of the four siblings that thread them).

---

## Literature Proof Structure (Tier 1)

1. **Lemma 5.3** (chunk_0014 lines 7-41; paper p.8-9): reduction of the n-witness interval
   existential to a ∨⃗∃∀ formula `On`, by induction on n. Basis (line 9): single ∀. Step
   (lines 11-41): case split on `r0 = inf` — (1) absent, (2) `K⁺` at the left anchor + `On` at
   same anchors, (3) INF-definable `r0` + `On` re-anchored at `r0`. Lean translation: `zoneExistF`
   recursion (§Q3 table); `inf` ↦ UZ/SZ first/last-occurrence (`PriorDefs.lean:22/:33`).
2. **Cor 5.4(1)** (chunk_0015 lines 3-43): bracket-tail negation ≡ `¬F0(z0) ∨ On(F1…Fn,z0,z1)`;
   the ⇐ induction (lines 19-37) extracts each next witness from the `Until` firing with the
   two-case split `y2 ≤ xn+1` / `xn+1 < y2`. Lean translation: Block C (compiled) is the
   single-step shape; the engine's correctness proof iterates it.
3. **Design invariant carried into the re-signing**: unary content on formulas, order content
   positional (bracket/zones). The old seams violated it (per-point arity-4 truth-set demand,
   the M2 stack's deviation flagged in task 374's mapping row 7); Blocks A/B restore it by
   guarding — the divergence from the old signatures is thus a REVERSION to the source, and the
   transcription-discipline justification is the compiled refutation of the divergent form
   (`SeamPairRefutationProbe.lean:47`).

## Tactic Survey Results

- Probe B: `nf_characteristic_satisfies` + `nf_eval_nf_atom_layer` + `lt_or_gt_of_ne` +
  `simp only [nf0_zoneSpec/atom_eval/Fin.cons_*]` — the Gap-B probe's own toolkit transfers
  unchanged; no new automation needed for the interface layer.
- Probe C: the landed `realize_futT` proof body (`IGGK:1577-1589`) replays verbatim; the added
  zoneHolds discharge needed explicit `Fin.cases` (a bare `Fin.cons … j` outside an application
  context needs a type ascription `(… : Fin 3 → M.carrier)` — motive inference pitfall worth a
  memory note) and `fin_cases`-free case analysis; `decide` closes the Bool-bit absurdities.
- Namespace note for the plan: probe-style files need
  `open Bimodal.Metalogic.WeakCanonical.Separation` for `nf_depth0_char_formula` /
  `formula_conjList_iff` (both live in `Separation/KampTranslation.lean`).

## Adversarial Self-Verification

| Claim | Source/Counterexample | Verification Method | Confidence |
|-------|------------------------|----------------------|------------|
| The re-signed seam pair (Blocks A/B) elaborates in the exact correct_prior conclusion context | `hcharFibZone_reSigned_gate_elaborates`, probe file line 61 | `lake env lean` compile this session, exit 0 (sole diagnostic: its deliberate `sorry` warning) | High |
| The old Gap-B counterexample instantiation is blocked by the zoneHolds guard | `zoneGuard_blocks_seamPair_counterexample`, probe line 27 — sorry-free | compiled proof (same session); attack replayed from `SeamPairRefutationProbe.lean:47` steps (1)-(3) | High |
| Consumer re-threading is zero-cost for the endpoint extraction | `bracketEndChar_kvFibZone_realize_futT`, probe line 105 — sorry-free, proof body = `IGGK:1577-1589` + zone discharge | compiled proof; source read of `IGGK:1565-1589` | High |
| `step_complete` can supply the zoneHolds guard | its own `hz'` fold biconditional constructs exactly `zoneHolds … (nf0_zoneSpec σ.atom_assgn) u` from the realizer atom layer | direct source read `IGGK:1773-1801` | High |
| `step_sound` can supply the carrier-eval + order gates | destructured `hveah` at `IGGK:2137`; task 370 report 02 §3 rows 1-2 (enrichment threading) | source read `IGGK:2101-2125` + report cross-read (2 sources) | High |
| Blocks A/B escape Gap A (shift-homogeneity) | equivariance argument §Q2.2: the guarded claim-set moves with anchors; no fixed non-invariant truth set is pinned | pen-and-paper over read definitions (`zoneHolds` `NfEFold.lean:58`, `nf0_zoneSpec` `:153`) — NOT machine-verified, same epistemic tier as Gap A itself | Medium |
| Seam 2 without the marked-fiber guard is REFUTABLE (guard is load-bearing) | §Q2.3 counterexample sketch: `(ℤ, P={1})`, τ = characteristic of `(5,1,0,10)`, contexts `w=1` vs `w'=3`, shared `x1 ∈ (3,10)` | constructed this session against my own draft (which initially lacked the guard); pen-and-paper, not compiled — Phase 1 of the plan must compile this attack against the FULL guarded form | Medium-High (that the attack kills the unguarded form); the full form's immunity is UNPROVEN — Phase 1 gate |
| Zone constants/bits as used (igZFutT = all-(false,true), AtW = ((false,false) on the w-slot)) | `IGGK:178-199` (igLtz/igEqz/igGtz/igMk3/igZ* definitions) + `zoneHolds` def | direct source reads; Probe B/C compile depends on them (machine cross-check) | High |
| Gap D facts current (row 6 no supply; rows 10/11 only `_zero`) | grep this session: `_zero` hits at `ExteriorPinnedConversePastK.lean` / `ExteriorPinnedConverseK.lean`; corroborates task 374 report | grep + prior-report cross-check (2 sources) | High |
| Gap E fact current (`kampArm_*_kv` zero hits) | repo-wide grep this session: 0 | grep + task 374 report (2 sources) | High |
| Engine shape is Lemma 5.3-faithful | §Q3 correspondence table; chunk_0014 lines 7-41 read this session; `ExistProviders` def read (`PriorInterface.lean:38-45`) | corpus chunk reads + source read | High |
| No FROZEN surface needs touching | all four re-signed declarations are the task-370 additive siblings (report 02 §3: "freely editable…disjoint from the frozen defeq"); probe compiles without importing/modifying any frozen file | report §3 re-read + probe compile | High |

**Contradiction Log.**
1. **Task-374 §Q1 sketch (single `hcharFibZone` ↔) vs this report (a PAIR: guarded ↔ + guarded
   render-free →)** — RESOLVED by direct consumer-source reads (precedence: compiled source >
   prior report sketch): `step_complete` (completeness direction) has the render but NOT the
   carrier evals (it is constructing them), while `step_sound`/`realize_*` (soundness direction)
   have the carrier evals but must stay render-free (task 370's decircularization,
   `IGGK:1562-1564` docstring). One seam cannot serve both without re-introducing either the
   circularity or the unguarded transport; the sketch's single-statement form is refined, not
   contradicted — its guard inventory (anchor context, zone-admissibility, zoneHolds) is exactly
   what both seams carry.
2. **My own draft Seam 2 (initially qnf-independent, mirroring `hcharFibSoundP`) vs the §Q2.3
   attack** — RESOLVED against the draft: the marked-fiber guard `qnf.2 τ = true` was ADDED
   after the attack succeeded on paper. Recorded per H4 ("recommendations modified after
   verification").

**Recommendations modified after verification:** (1) Seam 2 gained the `qnf.2 τ = true` guard
(§Q2.3). (2) An earlier intent to also compile a satisfiability witness for Block A at the
probe's `(ℤ,<)` instance was dropped as out-of-scope for research (it requires constructing a
concrete `charFib`, i.e., the engine itself) — replaced by the explicit Phase-1 gate
recommendation, which is the honest machine-checkable substitute.

---

## Recommended next steps

1. `/plan 376 --hard --lit`: adopt the §Q4 phase set. Phase 1 is a HARD GATE (probe the
   re-signed pair, including the §Q2.3 attack) — do not let volume phases start before it
   returns CLEAR.
2. The probe file `reports/01_zone-seam-probe.lean` is the Phase-1/Phase-2 starting template
   (Blocks A/B binders to splice; Block C proof to transplant); it is a specs-side artifact,
   deliberately NOT in the `Theories/` build.
3. Respect the FROZEN/EDITABLE/PRESERVE partition as restated in §Q4 — no frozen touch is
   required; if Phase 1 forces a Seam-2 render-gated fallback, that too stays sibling-level.

## References

- `specs/374_retire_kampprior_519_522_residual_arms/reports/01_m2-asset-sufficiency-adjudication.md` (Gap A-E ledger; §Q1 sketch this report refines)
- `specs/370_m2_defolded_interior_carrier_redesign/reports/02_phase7-divergence-audit.md` §3 (FROZEN/EDITABLE classification)
- `Theories/…/NfMultiAnchorBridge/SeamPairRefutationProbe.lean` (`seamPair_joint_refutation:47`, `_int:145`)
- rabinovich_2014 chunk_0014 (Lemma 5.3), chunk_0015 (Cor 5.4(1)) — read this session
- `specs/376_arity_general_zone_decomposed_char_engine/reports/01_zone-seam-probe.lean` (this session's compiled machine artifact)
