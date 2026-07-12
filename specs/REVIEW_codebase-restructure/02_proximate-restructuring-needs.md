# Angle 2 — Proximate Restructuring Needs (Kamp / WeakCanonical discrete-completeness cluster)

**Session**: sess_1783841542_df767b
**Scope**: Kamp discrete-completeness cluster ONLY (`Theories/Bimodal/Metalogic/WeakCanonical/Kamp/**` + `WeakCanonical/Transfer.lean`, `IntegerModel/ReynoldsBridge.lean`). Read-only.
**Goal**: restructuring + local archival that most reduces friction to FINISH discrete completeness (tasks 303 / 349 / 350).
**Cross-refs**: Angle 1 owns the final on/off-path liveness call; SharedWitness split owned by task 341 (not re-planned here); report 05 in `specs/349_.../reports/` = faithful ≤2-free-var endChar architecture (do not fight).

---

## 0. Key structural finding: the live entry to the whole cluster is a single edge

Established by tracing imports (`grep -rlE "^import Bimodal.*\.Kamp\." | grep -v Boneyard`):

- **The ONLY non-Boneyard, non-Kamp-internal importer of any Kamp module is `WeakCanonical/PriorExpressiveness.lean`, which imports exactly one file: `KampPrior`.** Everything else in the cluster is reachable (or not) only through the internal import chain rooted at `KampPrior`.
- `WeakCanonical/Transfer.lean` (the Reynolds integer-model bridge) imports **no** Kamp module — it is a *sibling* completeness track (ParametricCanonical / ShiftAndGlue / ReynoldsBridge), not a consumer of the Kamp NF machinery. Restructuring the Kamp cluster cannot break Transfer.
- `lakefile.lean:19-23` builds `lean_lib Bimodal` from root `Bimodal` (→ `Theories/Bimodal.lean` → `Bimodal.Bimodal`). Only the transitive-import closure of that root is compiled by default `lake build`. `Bimodal.Boneyard.**` is a **separate** lib (`BoneyardArchive`, lakefile:27-30) that is *not built by default*. **Moving a file into `Kamp/Boneyard/` therefore removes it from the default build** (the existing `Kamp/Boneyard/` files confirm this pattern).

### Transitive-import closure from `KampPrior` (the live cluster)

Computed over all non-Boneyard Kamp files. **31 files ON-PATH** (reachable from KampPrior), **10 files OFF-PATH** (orphaned — no live importer reaches them):

- **ON-PATH (31)**: Base, CarrierK1V, CarrierKv, EANegation, EANegationClosure, ExistsForallNF, ExteriorBracket, ExteriorNegation, ExteriorNegationPast, ExteriorZoneTriage, KampPrior, NavigatedSpine, NfDepth0Generalized, NfEFold, NfMultiAnchorBridge, NfToVecEA, NfZoneDepthK, NfZoneFlattenNavigable, OuterGate, PriorINF, PriorInterface, RefutationF2, SharedWitness, SubBracket, SubBracket2, SubBracket2V, Translation, VecEAClosure, VecEADecomp, VecEAFormula, VecEATranslation.
- **OFF-PATH (10)** — orphaned in the default build graph: **EAVecNegationClosure, Lemma32Reduction, NavigatedEndChar, NegationIndep, NfZoneDepthK1Probe, NfZoneNavProbe, Prop43, RabinovichTranslation, VecEAArityFirewall, VecEA_m**.

> **Liveness caveat (defer to Angle 1)**: "OFF-PATH in the KampPrior closure" ≈ "not compiled by default `lake build`" — a strong dead-code signal — but it is *not* the same as "contains no lemma anyone intends to wire in." Several off-path files (esp. NavigatedEndChar, Lemma32Reduction) sit adjacent to the in-flux task-349 endChar rebuild and may be staging ground. **Angle 1 must confirm before any file physically moves.** Every archival row below carries a liveness-uncertainty note.

---

## 1. Split-candidate table (oversized LIVE files)

Sizes via `wc -l`; structure via section markers (`/-! ##`) and `namespace`/`end`. "Frozen?" per task-349 freeze list (SubBracket2V, OuterGate, ExteriorBracket, ExteriorZoneTriage, ExteriorNegation, ExteriorNegationPast, KampPrior, Lemma32Reduction).

| File | Lines | Sorries | Structure | Frozen? | Split verdict | Rough cut points | Priority |
|------|-------|---------|-----------|---------|---------------|------------------|----------|
| **CarrierK1V.lean** | 2097 | 12 | Flat namespace, 7 phase-sections; two independent helper kits (soundness / completeness) | **No** | **SPLIT (3-way)** — cleanest large live target | Base = carrier types + k0/k1 instances + gate probes (**16–512**); **Soundness kit** = Phase 4 LHS→RHS (**513–1328**, ~815 ln); **Completeness kit** = Phase 5 RHS→LHS (**1329–2057**, ~728 ln); trailing re-probe 2057–2097 | **HIGH** |
| **Base.lean** | 1982 | 23 | Flat namespace, ~20 phase-sections spanning tasks 331/307/309/349; two logical strata | **No** | **SPLIT (extract stable stratum)** — isolate COMPLETE foundation from in-flux endChar | Extract **Deliverable-1&2 char2 + zone-flatten foundation (35–707)** ("Phase 3 Deliverable 1 COMPLETE" @207, "Phase 5 Deliverable 2 COMPLETE" @622) into `Base/Char2ZoneFlatten.lean`; leave arity-3/endChar strata (708–1982, the task-349 rebuild territory) in place | **HIGH** |
| **NfDepth0Generalized.lean** | 1772 | 1 | Flat namespace, 11 clean `/-! ##` sections; coherent (merge-infra → renaming → succ-case → main thm) | No | **DEFER / optional** — 1 sorry, already well-sectioned, low friction | If it ever becomes a work target: cut at `## The main theorem` (**1579**), infra (39–1578) vs main-thm + diagonal-congruence + relocated helpers (1579–1772) | LOW |
| **SubBracket2V.lean** | 2160 | 1 | (largest file after SharedWitness) | **FROZEN (349)** | **PROPOSAL-ONLY (post-thaw)** — do not touch | note: largest frozen live file; a post-thaw task should assess an interface/impl split | (post-thaw) |
| **ExteriorNegation.lean** | 1735 | 1 | | **FROZEN (349)** | **PROPOSAL-ONLY (post-thaw)** — do not touch | note only | (post-thaw) |
| SharedWitness.lean | 12800 | 5 | — | No | **OWNED BY TASK 341** — not re-planned here | — | (341) |

### Detail — CarrierK1V (the highest-value live split)

Section markers: Phase 9 (16), Phase 10 "DECISION GATE → NO-GO" (102), 311-P1 (136), 311-P2 "R2 NO-GO" (260), **311-P3 witness-growing V-carrier (335)**, **311-P4 soundness helper kit (513)**, **311-P5 completeness helper kit (1329)**, 311-P5 re-probe "NO-GO" (2057).

- **Extraction feasibility check**: the early carrier *definitions* — `BracketEndCharCarrier` (37), `BracketCarrierCorrect` (47), `bracketEndChar_k0` (58), `bracketEndChar_k0_correct` (72), `bracketEndChar_k1` (165) — are referenced downstream (k0_correct ×4 after L335; k1 ×3 after L335 **and by the `NfMultiAnchorBridge.lean` aggregator**). **So the "NO-GO probe" prose does NOT wrap dead-extractable code** — the k0/k1 carrier instances are live. The 10 sorries in the 16–335 region are therefore **live proof debt** (e.g. inside `bracketEndChar_k0_correct`), not archivable scaffolding.
- **Consequence**: the win here is *navigability*, not sorry-removal. Split by the Phase-4/Phase-5 seams (513, 1329) — the soundness and completeness kits are self-contained ~800-line halves that different dispatches (349 vs 350) can own independently. Base retains the shared carrier types + k0/k1 + gates.

### Detail — Base (isolate stable-from-in-flux without fighting the endChar rebuild)

Two strata are cleanly separated by the section markers:
- **Stable stratum (35–707)**: Phases 1a/1b/2/3 (nf_char2_formula + _correct, **"Deliverable 1 COMPLETE"** @207) and Phase 4/5 zone-flatten (**"Deliverable 2 COMPLETE"** @622). 4 sorries (153, 522, 524, 647).
- **In-flux stratum (708–1982)**: arity-3 endpoint-hook D2, endChar0/endChar interface, past/future off-diagonal chains (task 309), and the **task-349 endChar recursive rebuild** (Phase-1..7 @1478–1982, incl. "FEASIBILITY RESULT: frozen unconditional base is UNPROVABLE" @1720, "endCharRec DEFERRED" @1945). 19 sorries clustered here.
- **Verdict**: extracting 35–707 into `Base/Char2ZoneFlatten.lean` gives the 349/350 owners a ~700-line stable dependency and confines the churny endChar material (which report 05's faithful ≤2-free-var rebuild governs) to its own ~1000-line file. This **respects** the rebuild — it walls the rebuild's territory off from the finished char2/zone-flatten base rather than reorganizing the rebuild itself.

---

## 2. Local-archival table (dead / probe / orphaned siblings)

Sorries via `grep -c sorry`; "suspected dead?" = OFF-PATH in §0 closure AND no live importer. All rows carry a **liveness note** — final call deferred to Angle 1.

| File | Lines | Sorries | Live importers (non-Boneyard) | Suspected dead? | → Kamp/Boneyard? | Liveness note (for Angle-1) |
|------|-------|---------|-------------------------------|-----------------|------------------|------------------------------|
| **NfZoneDepthK1Probe.lean** | 151 | 3 | NONE | **Yes (high)** | **Yes** | Name says "Probe"; 0 importers anywhere; classic decision-gate scaffold. |
| **NfZoneNavProbe.lean** | 185 | 2 | NONE | **Yes (high)** | **Yes** | Name says "Probe"; 0 importers anywhere. |
| **Prop43.lean** (loose) | 182 | 2 | NONE | **Yes (high)** | **Yes** | 0 importers; a `Boneyard/Prop43.lean` (196 ln) already exists — likely superseded twin. Confirm not the live Prop 4.3 statement used elsewhere. |
| **NegationIndep.lean** | 365 | 3 | NONE (only `Boneyard/ArityReduction`) | **Yes (high)** | **Yes** | Sole importer is already-archived Boneyard code. |
| **RabinovichTranslation.lean** | 302 | 0 | NONE (only `Boneyard/RabinovichPath/*`) | **Yes (med-high)** | **Yes** | Only consumers are in Boneyard/RabinovichPath. 0 sorries (may hold a reusable defn) — verify no live Translation path wants it. |
| **NavigatedEndChar.lean** | 246 | 2 | NONE | **Yes (med)** | **Hold for Angle-1** | OFF-PATH but adjacent to the task-349 endChar rebuild; could be intended staging for report-05 architecture. **Do not move until 349 owner confirms.** |
| **VecEA_m.lean** | 659 | 0 | VecEAArityFirewall, Prop43 (both off-path) | **Yes (med)** | **Yes (as island)** | Part of the closed off-path VecEA island below. |
| **VecEAArityFirewall.lean** | 142 | 0 | EAVecNegationClosure (off-path) | **Yes (med)** | **Yes (as island)** | Island member. |
| **EAVecNegationClosure.lean** | 296 | 0 | Prop43 (off-path) | **Yes (med)** | **Yes (as island)** | Island member; top = dead Prop43. |
| **Lemma32Reduction.lean** | 549 | 5 | NONE | OFF-PATH **but FROZEN** | **NO (frozen)** | **Conflict flag**: file is on the task-349 freeze list yet unreachable from KampPrior. Cannot move (frozen). Flag to Angle-1/349-owner: is a frozen-but-orphaned file intended, or a freeze-list error? |

**Off-path VecEA island** (a self-contained dead sub-DAG): `Prop43 → EAVecNegationClosure → VecEAArityFirewall → VecEA_m` (plus `EAVecNegationClosure → EANegationClosure`, which *is* live, so the edge into live code must be preserved when archiving — archive Prop43/EAVecNegationClosure/VecEAArityFirewall/VecEA_m together, they do not feed live code downstream, only consume it).

**Aggregate declutter if §2 archival proceeds**: ~2,600 lines (NfZoneDepthK1Probe 151 + NfZoneNavProbe 185 + Prop43 182 + NegationIndep 365 + RabinovichTranslation 302 + VecEA_m 659 + VecEAArityFirewall 142 + EAVecNegationClosure 296 + optionally NavigatedEndChar 246) moved out of the default build's source tree.

---

## 3. Consolidation opportunities

1. **VecEA family fragmentation is mostly a *false* consolidation target.** The **live** VecEA chain — ExistsForallNF (339) → VecEAFormula (769) → {VecEAClosure (386), VecEATranslation (566) → NfToVecEA (567) → VecEADecomp (898)} — consists of individually well-sized (<900 ln) modules with a clean linear dependency chain. Merging them would produce one oversized file and fight the existing layering. **Recommendation: do NOT merge the live VecEA modules.** The only VecEA "consolidation" worth doing is **archiving the off-path island** (VecEA_m, VecEAArityFirewall, EAVecNegationClosure — §2), which removes the *apparent* fragmentation by removing the dead members.

2. **EA-negation trio** (EANegation 1251, EANegationClosure 766, EAVecNegationClosure 296) — EANegation is itself a §1-adjacent oversized file (1251) but has **15 sorries** and is not in the frozen list; not surveyed for cut points here (out of the top-5 size band), but flag as a **secondary split candidate** if tasks 349/350 touch the negation-closure path. EAVecNegationClosure is off-path (archive).

3. **Carrier naming split (flagged by task 341's team): k0 / k1 / kv.** Files: `CarrierKv.lean` (482), `CarrierK1V.lean` (2097); there is **no `CarrierK0.lean`** — the k0 instance (`bracketEndChar_k0`) lives *inside* CarrierK1V (58–100). This is a **cosmetic/naming** inconsistency, not a structural fragmentation. Recommendation: **low priority**; if CarrierK1V is split (§1), name the base module to make the k0/k1/kv arity ladder legible (e.g. `Carrier/Base`, `Carrier/Soundness`, `Carrier/Completeness`) rather than attempting a semantic merge with CarrierKv (different arity, legitimately separate).

4. **Boneyard `Prop43` twin.** Both `Kamp/Prop43.lean` (182, off-path) and `Kamp/Boneyard/Prop43.lean` (196) exist. Almost certainly a supersede-in-progress; archiving the loose one (§2) resolves the duplicate.

---

## 4. Priority-ranked "build-on-to-finish" shortlist

Ordered by ROI for finishing discrete completeness (tasks 303 / 349 / 350). Effort: S ≈ <½ day, M ≈ ~1 day, each within one agent dispatch.

1. **Archive the off-path dead/probe island → `Kamp/Boneyard/`.** *(Effort: S)*
   Files: NfZoneDepthK1Probe, NfZoneNavProbe, Prop43(loose), NegationIndep, RabinovichTranslation, and the VecEA island (VecEA_m, VecEAArityFirewall, EAVecNegationClosure). ~2,350 lines out of the working tree. **Cheapest, biggest declutter**; all confirmed absent from the default `lake build` graph (§0). *Gate: Angle-1 confirms liveness; preserve the `EAVecNegationClosure → EANegationClosure`(live) direction is consume-only. Do this FIRST — a smaller cluster makes the two splits below easier to reason about.*

2. **Split `CarrierK1V.lean` (2097) three ways by the Phase-4/5 seams.** *(Effort: M)*
   `Carrier/Base` (16–512: types + k0/k1 + gates) · `Carrier/Soundness` (513–1328) · `Carrier/Completeness` (1329–2057). Gives the 349 (soundness) and 350 (completeness) tracks **independently ownable ~800-line files** and cuts the 2nd-largest live file down to navigable units. No sorries removed (they are live), but the finish-work surface becomes parallelizable. *Non-frozen, safe.*

3. **Split `Base.lean` (1982): extract the COMPLETE char2/zone-flatten foundation (35–707) into `Base/Char2ZoneFlatten.lean`.** *(Effort: M)*
   Walls the finished Deliverable-1&2 base (4 sorries) off from the in-flux task-349 endChar rebuild (19 sorries, 708–1982). **Respects report-05's faithful ≤2-free-var architecture** by isolating — not reorganizing — the rebuild's territory. Gives 349/350 a stable ~700-line dependency. *Non-frozen; coordinate the cut with the 349 endChar owner so the rebuild stratum's imports are updated cleanly.*

4. **Resolve the `Lemma32Reduction` frozen-yet-orphaned conflict (decision, not edit).** *(Effort: S, analysis only)*
   It is on the freeze list but OFF-PATH (unreachable from KampPrior). Surface to the 349 owner: either it should be reachable (a missing live import — a *bug* to fix) or the freeze entry is stale. Blocks nothing but signals a possible gap in the live endChar wiring. Do not move (frozen).

5. **Post-thaw split proposals (note only, no plan): `SubBracket2V` (2160) and `ExteriorNegation` (1735).** *(Effort: deferred)*
   The two largest live files after SharedWitness, both FROZEN. When task 349's freeze lifts, a dedicated task should assess interface/impl splits. Recorded here so the post-thaw planner inherits the candidates; **no edits proposed while frozen.**

---

### Grounding index (file:line anchors used above)
- Live-entry edge: `WeakCanonical/PriorExpressiveness.lean` imports `Kamp.KampPrior` (sole non-Boneyard cluster importer).
- `lakefile.lean:19-30` (root-based `Bimodal` lib; separate non-default `BoneyardArchive`).
- CarrierK1V seams: 335 (V-carrier), 513 (soundness kit), 1329 (completeness kit); live carrier defs 37/47/58/72/165 referenced post-335 and by `NfMultiAnchorBridge.lean`.
- Base seams: 207 (Deliverable 1 COMPLETE), 622 (Deliverable 2 COMPLETE), 1478–1982 (task-349 endChar rebuild), 1720 (feasibility: frozen base UNPROVABLE), 1945 (endCharRec DEFERRED).
- Off-path set + island: §0 closure computation + `grep` importer counts (Prop43/EAVecNegationClosure/VecEAArityFirewall/VecEA_m).
