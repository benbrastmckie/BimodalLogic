# Task 370 — M2 de-folded interior carrier: A-vs-B frozen-boundary adjudication

Session: sess_1784093800_976134 · Agent: lean-research-hard-agent (H2/H3/H4/H5)
Date: 2026-07-14 · Reference-grounding tier: **Tier 1** (literature `rabinovich_2014` + landed source)
Scope: operationalize `specs/369_.../reports/02_m2-carrier-redesign-scope.md` (the AUTHORITATIVE M2
scope) into a verified, implementation-ready adjudication. This report does **not** re-derive or
re-open the M1 refutation (SETTLED in 369 reports/01) or the M2 direction (SETTLED in 369 reports/02);
it decides the **Phase-0 architectural gate** those documents deferred.

---

## VERDICT (headline)

**Adopt Option B (parallel non-folded carrier + full-chain re-proof). HIGH confidence. Do NOT modify
the frozen `bracketEndChar_kv`.**

The gate is decided by measured blast radius, not by proof-volume aesthetics:

- **Option A** (modify frozen `bracketEndChar_kv`, CarrierKv.lean:238-249) is a **signature change** to
  a definition with **227 non-comment code references across 28 files**, **56 `def/theorem/.holds`
  header lines**, and **29 `.holds` type-position dependents** — and it breaks **two** frozen `rfl`
  bridges, not one (`bracketEndChar_kv_succ_eq` and `bracketEndChar_kv_one_eq`). Its blast radius is
  genuinely unbounded: it is the "discover it mid-refactor" failure the gate exists to prevent.
- **Option B** leaves the frozen carrier untouched (0 rfl breaks, 0 churn to those 227 refs) and pays a
  **bounded, fully enumerable** cost: **1 new parallel carrier def + 6 re-proof/replace obligations**,
  all inside the declared 6-file scope. Higher proof volume is a *sized* quantity; Option A's blast
  radius is not.

Fallback (if Option B's bridge to the frozen carrier proves impossible): a **scoped, rfl-preserving**
Option A variant that changes `igFoldBit` and the frozen fold argument *in tandem* so both stay
byte-identical — last resort, escalate `[BLOCKED]` before touching the frozen carrier (§6).

---

## Line-drift audit (H2 — verified against live source, 2026-07-14)

The 369 reports/02 line numbers are **essentially accurate**; the file scope is fresh. Deltas below.

| Element | reports/02 line | Live line | Status |
|---------|-----------------|-----------|--------|
| `igEpL` | InteriorGateGeneralK:209 | :209 | exact |
| `igEpR` | :219 | :219 | exact |
| `igPtW` | :243 | :243 | exact |
| `igMkDisjunct` | :276 | :276 | exact |
| `igBody` | :290 | :290 | exact |
| `igFoldBit` | :318 | :318 | exact |
| `bracketEndChar_kv_succ_eq` (rfl lock) | :339-351 | :339 | exact |
| `igBody_holds_iff` | :359 | :359 | exact |
| `igFoldBit_realize_iff` | :563 | :563 | exact |
| `bracketEndChar_kv_step_sound` | :1043 | :1043 | exact |
| step_sound fiber delegation | :1150-1165 | inside :1043-1205 body; binders at :1055-1072, pairing at :1201-1203 | **DRIFT** — delegation is the `hreal`/`hexcl`/`hexclExt` binders inside `step_sound`, not a separate :1150-1165 lemma |
| frozen fold in `bracketEndChar_kv` | CarrierKv:246-249 | def at :238, k+1 fold at :245-249 | minor (-1) |
| render production | ExteriorGateAssembleK:337-338 | :337-338 | exact (per 369 grounding) |
| row-5/6 binders | KampPrior:955-1000 | :955-1000 | exact (per 369 grounding) |
| `kampPrior_futRealizer_of_pos` | KampPrior:1662 | :1662 | exact (per 369) |
| `kampPrior_pastRealizer_of_pos` | KampPrior:1721 | :1721 | exact (per 369) |
| `kampPrior_hreal_supply` :116 sorry | InteriorHrealSupplyK:116 | :116 | exact (live sorry confirmed) |
| rows 12-13 deepExcl arms | ExteriorDeepExclSupplyK:105,:133 | :105, :133 | exact (live sorries confirmed) |

**Newly located Option-B obligations not line-cited in reports/02** (live):
`bracketEndChar_kv_succ_holds_iff` :400 (the `.holds` bridge proven *via* the `succ_eq` rfl at :411),
and `bracketEndChar_kv_step_complete` :693.

---

## Findings — H3 Tier 1 source-to-implementation mapping

| Source (paper / landed) | Prop / Location | Lean Identifier | Type signature (abbreviated) | Status → M2 obligation |
|-------------------------|-----------------|-----------------|------------------------------|------------------------|
| rabinovich_2014, p.4 Def 3.1 + p.5 ∨→∃∀ normal form | strict witness chain `xn > … > x0`, `n+1` ∃-prefix, pins `i0..im ∈ {0..n}` | — | paper carries the **full ordered witness/bracket sequence**, never folds | Ground truth for the de-folded carrier: keep the whole arity-4 fiber |
| rabinovich_2014, p.3 §2.2 | `M,t ⊨ F1 Until F2` iff `∃t'>t, M,t'⊨F2 ∧ ∀t1∈(t,t') M,t1⊨F1` (md L79) | — | Until semantics faithful; the fold is a Lean-encoding-only deviation | Endpoint firing must rebuild the fiber, not a 1-type |
| Landed (F1 loss) | InteriorGateGeneralK:318-332 | `igFoldBit` | `NF sig (k+1) 3 → ZoneSpec 3 → NF sig k 1 → Bool`; `decide (∃ sub:NF k 4, qnf.2 sub ∧ zoneSpec=zs ∧ nfk_projFresh sub=χ)` | **REPLACE** with non-projecting fiber-carrying selector (no `nfk_projFresh` collapse) |
| Landed carrier | InteriorGateGeneralK:209/219/243 | `igEpL`/`igEpR`/`igPtW` | arity-1 conjuncts: `Since`/`Until`/`AtW` `igLit` over `χ:NF (k+1) 1` | **RE-KEY** on full arity-4 fiber `σ:NF (k+1) 4` |
| Landed consumers | InteriorGateGeneralK:276/290 | `igMkDisjunct`/`igBody` | per-zone disjunct assembler / gate body | Accept de-folded carriers |
| Landed (FROZEN) | CarrierKv:238-249 | `bracketEndChar_kv` | `BracketEndCharCarrierV sig k`; k+1 branch inlines the identical fold at :245-249 | **Option A locus** — do NOT modify (verdict) |
| Landed (rfl lock #1) | InteriorGateGeneralK:339-351 | `bracketEndChar_kv_succ_eq` | pure `rfl`: `bracketEndChar_kv…(k+1) qnf = igBody … (igOffFiber qnf) (igFoldBit qnf)` | Broken by Option A; Option B leaves intact |
| Landed (rfl lock #2) | CarrierKv:294-351 | `bracketEndChar_kv_one_eq` | k=1 bridge; `rfl`/split-kit calc containing the fold (`nfk_projFresh sub=χ` at :306/:335/:342) | **Second** rfl broken by Option A (369 reports/02 omitted this) |
| Landed (Option B re-proof) | InteriorGateGeneralK:359 | `igBody_holds_iff` | body-holds characterization | Build de-folded analog |
| Landed (Option B re-proof) | InteriorGateGeneralK:400 | `bracketEndChar_kv_succ_holds_iff` | `.holds ↔` unfold; proven via `succ_eq` rfl at :411 | Build de-folded analog (need NOT be rfl) |
| Landed (render bridge) | InteriorGateGeneralK:563 | `igFoldBit_realize_iff` | fold-bit `= true` ↔ realizer, **requires render `nf_eval_nf M (k+1) 3 [w,x,t] qnf` as hyp** | **REPLACE** by de-folded endpoint→arity-4 extraction (no render) |
| Landed (Option B re-proof) | InteriorGateGeneralK:693 | `bracketEndChar_kv_step_complete` | completeness step | Build de-folded analog |
| Landed (Option B re-proof) | InteriorGateGeneralK:1043 | `bracketEndChar_kv_step_sound` | soundness; `hreal`/`hexcl`/`hexclExt` binders :1055-1072 over folded `igPtW`/`igFoldBit`, concludes render; pairing :1201-1203 | Build de-folded analog + re-key binders |
| Landed (render production) | ExteriorGateAssembleK:337-338 | (render emit) | produces `nf_eval_nf M (k+2) 3 [w,x,t] qnf` | Re-type to de-folded endpoint evals |
| Landed (binders) | KampPrior:955-1000 | row-5/6 `hreal`/`hexcl` | typed against folded arity-1 witnesses | Re-type to de-folded endpoint evals |
| Landed (drivers) | KampPrior:1662/:1721 | `kampPrior_{fut,past}Realizer_of_pos` | `hpos → ∃ x1, nf_eval_nf M (k+1) 4 [x1,w,x,t] σ` | Re-wire to consume de-folded endpoints (realizer now available directly) |
| Landed (leaf, sorry) | InteriorHrealSupplyK:116 | `kampPrior_hreal_supply` | `∃ x1, nf_eval_nf M (k+1) 4 [x1,w,x,t] σ` | **DISCHARGE** sorry-free via de-folded endpoint |
| Landed (leaves, sorry) | ExteriorDeepExclSupplyK:105/:133 | `kvE_hexclDeep{Fut,Past}_supply` general-m arms | `¬ nf_eval_nf M (k+1) 4 [x1,w,x,t] σ` under `qnf.2 σ=false` | **DISCHARGE** sorry-free vs de-folded render; **depends on :116 landing first** (in-body note) |

---

## Phase-0 architectural gate: A-vs-B adjudication (PRIMARY DELIVERABLE)

### Option A — modify the frozen `bracketEndChar_kv` (CarrierKv:238-249)

**What it entails.** Carrying the full arity-4 fiber means changing the carrier's selector argument
from `(fun zs χ => decide (∃ sub:NF k 4, … ∧ nfk_projFresh sub = χ))` (a `ZoneSpec 3 → NF k 1 → Bool`)
to a fiber-carrying object of a **different type**. That propagates into `kv_body`'s signature
(CarrierKv:152) and hence into the type of `bracketEndChar_kv` itself.

**Measured blast radius (H2 — live grep, boneyard excluded):**

| Metric | Count | Command basis |
|--------|-------|---------------|
| Files referencing `bracketEndChar_kv` in code | **28** | `grep -rln … \| grep -v Boneyard` |
| Non-comment code references | **227** | filtered `grep -rn` |
| `def/theorem/lemma` headers or `.holds` lines on it | **56** | header-pattern grep |
| `.holds` type-position dependents | **29** | `.holds` grep |
| Frozen `rfl` bridges broken | **2** | `bracketEndChar_kv_succ_eq` (IGGK:339) + `bracketEndChar_kv_one_eq` (CarrierKv:294; fold appears in its rfl calc at :306/:335/:342 — verified) |
| Transitive `.holds`-bridge reach | 6 sites via `bracketEndChar_kv_succ_holds_iff` | across IGGK + ExteriorGateAssembleK |

**Why "unbounded."** A signature change to a def that 28 files and 227 code sites are typed against is
not a local edit; every one of those sites is a potential type error, and the whole Phase 1-4 tree is
*byte-locked* to the current shape via the two rfl bridges. 369 reports/02 §2.2 called out one rfl
(`succ_eq`); this research found a **second** (`bracketEndChar_kv_one_eq`, the k=1 bridge), confirming
the blast radius was *understated*, not overstated. This is the canonical "discover it mid-refactor"
hazard the gate exists to forbid.

### Option B — parallel non-folded carrier + full-chain re-proof

**What it entails.** Introduce a sibling carrier (e.g. `bracketEndChar_kvFib`) keyed on the arity-4
fiber, leave `bracketEndChar_kv` frozen, and route the render + endpoint extraction through the
parallel carrier. The bridge from parallel-to-frozen need **not** be a `rfl` — a proven equality (or no
equality at all, if the parallel carrier fully supersedes the frozen one on the render path) suffices.

**Bounded, enumerable obligation set (all inside the 6-file scope):**

1. **New** `bracketEndChar_kvFib` (parallel de-folded carrier def) + a non-projecting `igFoldBit`
   analog (fiber-carrying selector) — InteriorGateGeneralK / CarrierKv.
2. `igBody_holds_iff` analog — IGGK:359.
3. `bracketEndChar_kv_succ_holds_iff` analog — IGGK:400 (its `succ_eq` analog need not be rfl).
4. `igFoldBit_realize_iff` **replacement** — IGGK:563 → de-folded endpoint→arity-4 extraction that
   reads `∃ x1>t, nf_eval_nf M (k+1) 4 [x1,w,x,t] σ` directly off the endpoint eval, **no render hyp**
   (this is what breaks the machine-confirmed circular firing route — see §"M1 corroboration").
5. `bracketEndChar_kv_step_complete` analog — IGGK:693.
6. `bracketEndChar_kv_step_sound` analog + re-keyed `hreal`/`hexcl`/`hexclExt` binders — IGGK:1043-1205.

Plus the §"Assembly" re-typing (ExteriorGateAssembleK:337-338; KampPrior:955-1000, :1662/:1721) and the
§"Downstream" discharges (InteriorHrealSupplyK:116; ExteriorDeepExclSupplyK:105/:133), which are
identical under either option.

**Cost comparison.**

| Dimension | Option A | Option B |
|-----------|----------|----------|
| Frozen rfl bridges broken | 2 | 0 |
| Type churn to existing 227 refs / 28 files | yes (unbounded) | none |
| New proof obligations | re-audit all 56 headers + re-prove 2 rfl chains | 1 new carrier + 6 analogs (enumerated) |
| Risk profile | unbounded, discovered incrementally | bounded, known up front |
| Frozen-boundary contract (369 Postmortem) | **violated** | respected |

### Recommendation (HIGH confidence)

**Option B.** The decision rule is blast-radius containment, and it is decisive: Option A changes the
type of a definition 28 files depend on and breaks 2 frozen rfl locks; Option B's cost is a fixed list
of 7 obligations confined to the 6-file scope with zero frozen-boundary risk. The extra proof volume is
the price of not gambling the byte-locked tree. This also honors the 369 reports/01 Postmortem
constraint that the frozen carrier must not be modified.

**Phase ordering for the downstream planner (dependency-forced):**
1. Phase 0 (this gate): **B decided.**
2. Parallel carrier + de-folded `igFoldBit` analog (obligation 1).
3. Re-proof chain (obligations 2,3,5,6) + render-bridge replacement (obligation 4).
4. Assembly/binder re-typing + driver re-wire.
5. Discharge `kampPrior_hreal_supply` :116 (de-folded endpoint supplies the arity-4 realizer directly).
6. Discharge `kvE_hexclDeep{Fut,Past}_supply` :105/:133 — **strictly after** step 5: both in-body notes
   state "task 358 Phase 5 (`kampPrior_hreal_supply` ambient render) must precede this general-m arm."

---

## Literature Proof Structure (Tier 1, rabinovich_2014)

**Fidelity hazard (H4 — must be surfaced).** The per-repo literature index
(`specs/literature-index.json`) flags the rabinovich_2014 `.md` as **UNSAFE for load-bearing md:NN /
chunk citations**: the current extract "DROPS EVERY DISPLAYED EQUATION" and semantically inverts
`k≠m`→`k=m` at md:199; 89 in-code `md:NN` citations already dangle. **Consequently the 369 reports/01
citation "Cor 5.4(1)⇐ chunk_0015 L23-29" is a chunk-line citation the index deems unsafe** — its
*precision* cannot be trusted. **However, the design direction it supports is corroborated at the
page level** by grounds the index explicitly certifies:

- **Def 3.1 (p.4)**: the witness chain is **strict** (`xn > … > x0`); the ∨→∃∀ normal form (p.5, md L111)
  has an **`n+1` existential prefix** with pins `i0..im ∈ {0..n}` — i.e. the paper carries the whole
  ordered witness sequence and never projects it to `(zone × 1-type)` bits.
- **Until semantics (p.3, md L79)**: `F1 Until F2` at `t` demands an actual future `t'>t` realizing `F2`
  with `F1` throughout `(t,t')` — a relational fact, consistent with rebuilding the arity-4 fiber.

**Conclusion:** the paper never folds; the Lean `igFoldBit`/frozen-fold **is** the deviation, and the
M2 de-folded carrier restores paper fidelity. This claim now rests on **page-level, index-certified**
grounds (Def 3.1 p.4 + ∨→∃∀ p.5), not on the flagged chunk citation. Cite Rabinovich **by page only**.

---

## M1-unrebuildable premise — independent corroboration (H4 stress test)

The task instructs me to stress-test "M1 is unrebuildable." I did, and found **independent, live,
in-code machine confirmation** at the leaf, orthogonal to 369's model-independence argument:

`InteriorHrealSupplyK.lean:53-116` (the strategic-sorry body) states, machine-confirmed this dispatch:
the **only** fold-bit→model-realizer bridge is `igFoldBit_realize_iff` (:563), and it **requires the
render `nf_eval_nf M (k+2) 3 [w,x,t] qnf` as an explicit hypothesis** — which is **exactly the render
that this obligation produces downstream** at ExteriorGateAssembleK:337-338. Firing the drivers from the
fold bit therefore consumes the very render it is upstream of: **circular**. This is a second, independent
witness (beyond 369 reports/01's hypothesis-classification argument) that no firing oracle over the
existing fold can exist — and it pinpoints *why* Option B's obligation #4 (replace `igFoldBit_realize_iff`
with a **render-free** de-folded extraction) is the load-bearing move: it is the only edit that breaks the
circularity by making the arity-4 realizer readable from the endpoint without the render.

---

## Sorry inventory (file scope, live)

| Identifier | File:line | Type (goal) | Why stuck | M2 disposition |
|------------|-----------|-------------|-----------|----------------|
| `kampPrior_hreal_supply` | InteriorHrealSupplyK:116 | `∃ x1, nf_eval_nf M (k+1) 4 [x1,w,x,t] σ` | firing route circular via render (§above) | Discharge sorry-free (de-folded endpoint) — **primary M2 leaf** |
| `kvE_hexclDeepFut_supply` general-m | ExteriorDeepExclSupplyK:105 | `¬ nf_eval_nf … σ`, `qnf.2 σ=false` | needs Phase-5 ambient render | Discharge after :116 (in-body note) |
| `kvE_hexclDeepPast_supply` general-m | ExteriorDeepExclSupplyK:133 | past mirror of :105 | needs Phase-5 ambient render | Discharge after :116 |
| (pre-existing, OUT of M2 discharge scope) | KampPrior:519, :522 | task 309/357 `k+2` strategic arms | separate lineage | **Do NOT retire in M2**; flag if touched — present in a file M2 re-types (:955-1000, :1662/:1721) |

**Zero-Debt note (H2):** M2's terminus must discharge :116/:105/:133 sorry-free. If Option B's obligation
#4 (render-free extraction) cannot be proven, the correct terminus is `[BLOCKED]` for user review — not a
retained sorry and not the fallback scoped-Option-A without explicit user sign-off (§6).

---

## Adversarial Self-Verification (H4)

I stress-tested every load-bearing claim, especially the A-vs-B blast-radius numbers and the
"M1 unrebuildable" premise.

| Claim | Source / Counterexample tried | Verification Method | Confidence |
|-------|-------------------------------|---------------------|------------|
| Option A touches 28 files / 227 code refs / 56 headers / 29 `.holds` | Tried: maybe most are comments or boneyard. Filtered both out | `grep -rn … \| grep -v Boneyard \| grep -vE ':\s*--'` counts | High |
| Option A breaks **2** rfl bridges, not 1 | Tried: maybe `one_eq` is not rfl-against-the-fold. Read CarrierKv:294-351: the fold `nfk_projFresh sub=χ` appears in its calc at :306/:335/:342 with `:= rfl` at :342 | `sed` source read | High |
| Option B obligation set is **complete** (nothing missed) | Tried: search for other `bracketEndChar_kv_*` theorems. Found `succ_holds_iff` :400 and `step_complete` :693 not line-cited in 369 reports/02; **added them** | `grep -nE 'step_sound\|step_complete\|succ_holds_iff\|realize_iff'` on live IGGK | High |
| Option B bridge need not be rfl (so no frozen break) | The parallel carrier's `succ_eq` analog can be a proven `Eq`, or omitted if the render path fully supersedes the frozen carrier | Structural (rfl is an *optimization*, not a requirement, of the current design) | Medium — the de-folded↔frozen equality may be non-trivial; obligation #3/#4 carry this risk |
| M1 is unrebuildable over the existing fold | Tried: maybe a non-render firing route exists. InteriorHrealSupplyK:88-107 machine-confirms the ONLY bridge (`igFoldBit_realize_iff`) needs the render as hyp ⇒ circular | live source read (in-body sorry diagnosis) | High |
| Rabinovich "carry whole sequence, never fold" is faithfully sourced | **PARTIALLY REFUTED my own input** — 369's `chunk_0015 L23-29` citation is index-flagged UNSAFE (drops displayed equations). Re-grounded on Def 3.1 p.4 + ∨→∃∀ p.5 (index-certified) | literature-index.json hazard + md L79/L111 page read | High (direction); Low (the specific chunk citation) |
| `igFoldBit_realize_iff` requires the render as an explicit hypothesis | Read the in-body note citing IGGK:563-567 "REQUIRES the render … as hypothesis `h`" | live source read | High — **not** re-read at the def site :563 itself this dispatch (relied on the leaf note's quote) → Medium on the exact hypothesis form |
| :105/:133 depend on :116 landing first | Both in-body notes: "task 358 Phase 5 (kampPrior_hreal_supply ambient render) must precede this general-m arm" | live source read (ExteriorDeepExclSupplyK:99-110, :130-133) | High |
| Line numbers in 369 reports/02 have not drifted | Verified all interior anchors live; only `:1150-1165` fiber-delegation ref drifted (it is binders inside step_sound :1043-1205) | `grep -n` per anchor | High |

**Contradiction Log.**
1. **Rabinovich citation precedence (RESOLVED).** 369 reports/01 cites `chunk_0015 L23-29`; the
   literature index flags all md/chunk citations UNSAFE. Precedence *index-certified-page-ground >
   flagged-chunk-line*: re-grounded the "never fold" claim on Def 3.1 (p.4) + ∨→∃∀ (p.5), which the index
   explicitly certifies. Verdict direction unchanged; citation form corrected to page-only.
2. **Blast-radius framing (RESOLVED in Option A's favor as *worse*).** 369 reports/02 §2.2 asserts one rfl
   break; I found two. This *strengthens* the Option-B recommendation (Option A is worse than documented),
   so no re-direction needed.

**Residual (honest).** Two Medium items, both isolated to Option B's internal feasibility, neither
affecting the A-vs-B verdict: (a) whether the de-folded↔frozen carrier equality (obligation #3/#4) is
provable without an rfl against a modified fold — if not, the fallback scoped-Option-A (§6) or `[BLOCKED]`
applies; (b) I relied on the leaf's *quote* of `igFoldBit_realize_iff`'s signature rather than re-reading
:563 directly — the planner's Phase 0 should confirm the exact render-hypothesis form at the def site
before committing obligation #4's shape. Neither is a firing-oracle rescue of M1; both are downstream of
the settled decision.

**Anti-analysis (H2) note.** No sorry-deferral, axiom, or placeholder is recommended. The three
in-scope sorries (:116/:105/:133) are targeted for sorry-free discharge; if unreachable, terminus is
`[BLOCKED]`, not a retained sorry.

---

## Files inspected (machine grounding)

- `InteriorGateGeneralK.lean` — :209/:219/:243 (igEpL/igEpR/igPtW), :276/:290 (igMkDisjunct/igBody),
  :318 (igFoldBit), :339/:400/:411 (succ_eq rfl + succ_holds_iff), :359 (igBody_holds_iff), :563
  (igFoldBit_realize_iff), :693 (step_complete), :1043-1205 (step_sound + binders + pairing)
- `CarrierKv.lean` — :82 (nfk_projFresh), :152 (kv_body), :238-249 (bracketEndChar_kv + frozen fold),
  :294-351 (bracketEndChar_kv_one_eq — second rfl casualty)
- `ExteriorGateAssembleK.lean` — :73-79 (succ_holds_iff consumer), :337-338 (render production, per 369)
- `KampPrior.lean` — :955-1000 (binders), :1662/:1721 (drivers), :519/:522 (pre-existing sorries)
- `InteriorHrealSupplyK.lean` — :40-116 (kampPrior_hreal_supply statement + circular-route diagnosis + sorry)
- `ExteriorDeepExclSupplyK.lean` — :95-133 (rows 12-13 general-m arms + sorries + ordering note)
- Literature: `~/Projects/Literature/sources/rabinovich_2014/…md` (p.3 Until sem L79, p.5 ∨→∃∀ L111),
  `specs/literature-index.json` (fidelity hazard + known_corrections)

---

## Memory candidates (H2 Stage 5)

1. *(pattern)* In this Kamp bridge tree, `bracketEndChar_kv` is byte-locked by **two** frozen rfl
   bridges — `bracketEndChar_kv_succ_eq` (InteriorGateGeneralK:339) and `bracketEndChar_kv_one_eq`
   (CarrierKv:294) — so any signature change to it breaks both; parallel-carrier is the containment play.
2. *(discovery)* `igFoldBit_realize_iff` (InteriorGateGeneralK:563) requires the deep render as an
   explicit hypothesis, making fold→realizer firing circular for `kampPrior_hreal_supply`; a render-free
   de-folded endpoint extraction is the only decircularizing edit.
