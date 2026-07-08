# Task 334 Handoff 07 — Authoritative carrier faithfulness map + confidence closure (H3+H4+H5)

- **Agent**: lean-research-hard-agent (H2+H3+H4+H5), read-only. No `Theories/` edits.
- **Priority frame (user)**: COMPLETE FAITHFULNESS to Rabinovich 2014's proof architecture — the
  formalization must be a structural transcription, no Lean-convenience divergences. Deliverable is
  the authoritative paper→Lean divergence map for the WHOLE `NfMultiAnchorBridge` carrier, plus
  closure of handoff 06's MEDIUM-HIGH residual to HIGH.
- **Primary sources**: Rabinovich 2014 (`Literature/sources/rabinovich_2014/…md`, read in full,
  245 lines); codebase at HEAD `8e2c8abf7`; handoffs 04/05/06 consolidated (not re-litigated).
- **Type-checker facts obtained this session** (`lean_verify`, NormalForm def read at source):
  1. `nf_eval_nf` unfolding (`NormalForm.lean:198-207`) — the semantic realization target.
  2. `kvE2_sepCoincidentAnchor_discharge` axioms = `[propext, Classical.choice, Quot.sound]` —
     **axiom-clean** (the faithful closed-channel brick).
  3. `kvE2_sepBody_nonvacuous` axioms = `[propext, sorryAx, Classical.choice, Quot.sound]` —
     **`sorryAx`-contaminated** (the additive-filter joint non-vacuity rests on known-FALSE scaffolds).

---

## 0. VERDICT + CONFIDENCE (one screen)

**Faithfulness state: the multi-owner requirement is faithful and on the critical path; the current
`kvE2_sep*` carrier that implements it is a Lean-convenience divergence at its structural core, and
its joint non-vacuity is not merely unproven but rests on scaffolds documented FALSE.** Confirmed
JOINT REQUIRED (Lemma 3.2(1)); confirmed the faithful form is **order-type disjunction over the
merged anchor set + region partition + a closed/point-type coincidence channel** (Option B), NOT the
flatMap-slot-list + `permutations.filter(additive-open-zone `kvE2_sepValid`)` framing.

**Confidence: HIGH** (raised from handoff 06's MEDIUM-HIGH). The residual that held 06 at
MEDIUM-HIGH — "if the outer gate's completeness reduces to independent per-σ existence, a per-σ
route could soften the verdict to singleton" — is **resolved and refuted** by a type-checked
structural fact: the semantic target `nf_eval_nf M 2 3 [w,x,t] qnf` genuinely *is* per-σ-independent
(shared `w`, `∃x1` inside `∀σ`), yet the joint merge is still **required at the representation
level**, because the carrier's output type `VVecEA2` (a disjunction of totally-ordered exists-forall
brackets — the exact normal form the Prop 4.2 negation-closure induction rides) cannot express a
conjunction of per-owner brackets without Lemma 3.2(1) itself. Per-σ semantics does NOT license a
per-σ representation. See §2.

**Single most important finding**: JOINT-ness is a property of the **output normal form**
(`VVecEA2`), not of the model semantics. This dissolves the last "maybe singleton is enough"
escape hatch (HIGH), and it tells you exactly where the faithful merge must live — in the arrangement
disjunction, with a first-class coincidence disjunct validated by the (already-green, axiom-clean)
`zAtX1L` closed bit rather than the open `zXU/zUW` bits.

---

## 1. PART 1 — Authoritative paper→Lean divergence map

Legend: **F** = FAITHFUL, **D** = DIVERGENT (Lean-convenience shortcut), **A** = ABSENT.
Paper refs are `md:<line>` into the Literature chunk; Lean refs are `file:line` (files under
`Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/` unless noted; `SW`=SharedWitness,
`SB2`=SubBracket2, `SB2V`=SubBracket2V, `CK1V`=CarrierK1V, `NS`=NavigatedSpine).

### 1a. Paper-architecture constructs

| # | Paper construct (md ref) | What the paper does | Lean site | Verdict | If D/A: faithful transcription |
|---|---|---|---|---|---|
| P1 | **Def 3.1** interval decomposition (md:61-74) | Fixed points `x_0<…<x_n` partition chain; α AT points, β ALONG open intervals; witnesses strictly interior | `k1v_sorted_realization3` three-region partition `S_XU/S_UW/S_WT` strictly interior to `(x,x1)/(x1,w)/(w,t)` around fixed anchors `x1,w` (SB2V:379-402) | **F** | — (reference impl of the pattern) |
| P2 | **Def 3.1** strict witness ORDER, source of strictness (md:65-70) | Strictness is *definitional* (chosen points); interior points cannot hit an anchor | Single-owner: `k1v_sorted_realization` insertion induction over one region gives `Pairwise (·<·)` (CK1V:1447); anchor coincidence impossible by strict interior | **F** | — |
| P3 | **Def 3.1** point types α (md:66-72) | Quantifier-free point type at each anchor | The 5 non-interior zone dischargers `kvE_nonInterior_zAtX/zAtT/zAtW_{sound,complete}` (NS:281-383): bare literal held AT the anchor | **F** | — |
| P4 | **Def 3.1** segment types β + exterior β_0/β_{n+1} (md:66-74) | β holds ALONG each open interval; β_0 before x_0, β_{n+1} after x_n | Exterior nav: `zPastX` rides `Since`, `zFutT` rides `Until` (NS:253-279, 332-354). Interior β: `kvE2_sepBracketN` per-index segment types (SW:611) | **F** (single-owner) / see P8, C7 for the multi-owner β-merge | — |
| P5 | **Lemma 3.2(1)** conjunction ≡ **disjunction** over merge order-types, ⇒ direction (soundness of filter) (md:77) | A held disjunct (one consistent arrangement) implies the conjunction | `kvE2_sepValid` filter is a *sound* over-approximation: `kvE2_sepCompat` = exact fold-bit read (SW:385, leaves :409/:422/:434/:446) | **D (soundness half faithful, but framing divergent)** | Keep the ⇒ content (compat = fold bit) but move it inside a per-order-type disjunct, not a global additive filter over a flat slot list |
| P6 | **Lemma 3.2(1)** ⇐ direction (every honest arrangement admitted) (md:77) | Every model arrangement of merged witnesses is some disjunct | **`kvE2_sepBody_complete` DOES NOT EXIST** (grep 0, SW); only `kvE2_sepBody_singleton_complete_left` (SW:2212, **sorry @2225**) | **A** | Build the disjunction-completeness: each honest merged arrangement selects its order-type disjunct (reuse `k1v_sorted_realization3`'s `mem_permutations.mpr (Perm.refl _)` selection, SB2V:1440-1444) |
| P7 | **Lemma 3.2(1)** the merge is a **disjunction of order-types**, NOT a total order (md:77; §5 md:168-173) | No joint total sort; order-type is a disjunct *choice*; coincidences identified | Live carrier: `kvE2_sepArrL/R := (kvE2_sepSlotsL/R).permutations.filter kvE2_sepValid` over the **flatMap slot union** `pos.flatMap kvE2_sepSlotsLFor` (SW:472/477, :315/:320). No `List.mergeSort` remains (retired) | **D (core)** | Disjoin over relative order-types of the **merged anchor set** `{x1_σ : σ∈pos} ∪ {w}`; per disjunct, ONE region partition (`k1v_sorted_realization3` lifted to k anchors). The `permutations`-as-disjunction shape is faithful *per single owner*; the divergence is the flat cross-owner slot union + open filter |
| P8 | **Lemma 3.2(2)** anchor cap 2, free `(x,t)` framing (md:76-79) | Exists-forall reducible to ≤2 free variables | Anchors stay `{x,t}`; `x1,w` are interior WITNESS slots (NS:80-82, "witness growth licensed, anchor growth not") | **F** | — |
| P9 | **Lemma 5.1** quantifier-free point types, NO nesting (md:134-135) | Point/segment types are QF over Σ (charBase / E[Σ]-atom); higher FO depth via Prop 4.3 re-flatten, never by nesting a depth-k characteristic | LITMUS invariant enforced ("no `x1 < e_i` literal; no nested depth-k char"; NS:44-48, 79-82); `charBase = nf_depth0_char_formula` QF (NS:26) | **F** | — |
| P10 | **Cor 5.4** F_i chains at depth (md:154-157) | `F_n:=α_n`, `F_{i-1}:=α_{i-1}∧(β_i Until F_i)` translates a SINGLE bracket | k=1 CLOSED (`fChainFrom`/`fChainPred`, EANegation:552/567); **k≥2 converter is the sole open gap** at `KampPrior.lean:351` (ROADMAP:51) | **F (as far as landed)** | k≥2 instance is downstream wiring, not a faithfulness defect |
| P11 | **§5 splitting** `A_i = A_i^- ∧ A_i^+`, case-split on WHICH i the new point matches (md:168-173, 213-219) | Insert point z: case-splits on which witness it coincides with / sits between; coincidence → one shared point carrying **meet type** α_A∧α_B | Live extractor `kvE_subBracket2_complete_extract` has only 3 **open** reverse channels `zXU/zUW/zWT` (SB2:619-624); segment builder `kvE2_sepSegLForSub/RForSub` cuts **binary** before/after (`.take i .contains`, SW:561/574) — **no "at"/coincidence case** | **D** | Add the three-way before/**at**/after cut; the "at" case merges segment types (meet) and discharges via the closed channel (P13/C7) |
| P12 | **§5 / Dedekind completeness** sole use = `INF` (md:146, 221-222) | Completeness only supplies `r_0 = inf{z|P_1(z)}` (witness existence), never point-distinctness | `HasAttainedINF` / `neg_2var_vec_ea` (Prop 4.2, EANegationClosure:722); no model point-distinctness assumed | **F** | — |
| P13 | **§5 coincidence discharge** (md:168-173) | Coincident witnesses = shared point; the point genuinely realizes both types (existential char) | `kvE2_sepCoincidentAnchor_discharge` (SW:1161): at `v=x1`, produces `kvE2_sepBits σ kvE2_sep_zAtX1L χ = true`; **axiom-clean** (verified) via extract's generic forward channel | **F (brick) — but UNROUTED** | The brick is correct; the divergence is that no filter *consumes* its closed bit (see P5/P7 and C-rows) |

### 1b. Carrier-internal constructs (the "beyond the four" divergence hunt)

| # | Carrier symbol (site) | What it does | Verdict | Note / faithful form |
|---|---|---|---|---|
| C1 | `kvE2_sepPos` (SW:193) | Positive subs = `univ.filter (qnf.2 σ)` — the "owners" | **F** | The owner set is correct; it is the merge OVER these that diverges |
| C2 | `kvE2_sepSlotsLFor`/`RFor` (SW:292/304) | Per-σ slot block (left-int: `(x,x1)`types ++ `.lX1` ++ `(x1,w)`types; etc.) | **F** (per owner) | Per-owner region content is faithful; problem is the union (C3) |
| C3 | `kvE2_sepSlotsL`/`R` (SW:315/320) | `pos.flatMap …For` — **flattens ALL owners into one list**; foreign slot `.lXU τ χ` permanently present | **D (root)** | No paper analogue (handoff 04 §3). Replace with per-owner region lists under an order-type disjunction |
| C4 | `kvE2_sepValid` (SW:466) | `decide (l.Pairwise (kvE2_sepSlotLe · ·))` — arrangement validity as a **global additive filter** | **D (core)** | Faithful only in ⇒; cannot express point-identification. Replace by per-order-type disjunct validity |
| C5 | `kvE2_sepCompat` (SW:385) + 4 leaves | Cross-σ bit-compat; leaves read **open** bits: `lX1_eq→zXU` (:409), `lX1_after→zUW` (:422), `rX1_eq→zWX1` (:434), `rX1_after→zWT` (:446). Two 1-types / two fresh ⇒ `true` | **D** | Open-zone-only; the "two-fresh ⇒ true" shortcut skips the segment-meet. The 4 leaves survive *inside* strict disjuncts; a 5th closed-zone (`zAtX1L`) leaf is needed for the coincidence disjunct |
| C6 | `kvE2_sepSlotLe` (SW:459) | same owner ⇒ rank≤rank; diff owner ⇒ `kvE2_sepCompat` | **D (partial)** | Same-owner rank order is faithful (per-owner region order); cross-owner→compat inherits C4/C5's divergence |
| C7 | `kvE2_sepSegLForSub`/`RForSub` (SW:561/574) | Per-σ exclusion segment at a cut; branches on `nf0_zoneSpec σ.1` and **before/after** cut only | **D** | Binary cut has no coincidence ("at") case → no β meet-type on overlap. Faithful form: three-way cut with meet at "at" |
| C8 | `kvE2_sepBracketN` (SW:611) | Fresh N-slot bracket `lL ++ ptW :: lR` + per-index segment types | **F (structure)** | The N-slot bracket shape is right; it must be fed per-disjunct merged anchors, not the flat union |
| C9 | `kvE2_sepBody` (SW:685) | Joint carrier `VVecEA2`: `dite` gate; flatMap over `kvE2_sepArrL × kvE2_sepArrR` of `kvE2_sepDisjunct` | **D** | The `VVecEA2` disjunction *shape* is faithful; the divergence is its index set (C3/C4). This is the composition point that the (unbuilt) `kvE2_body`/`bracketEndChar_kvE2` gate wraps |
| C10 | `kvE2_sepBody_nonvacuous` (SW:1191) | Gate-true ⇒ disjuncts ≠ [] | **D — FALSE** | Verified `sorryAx`-contaminated; proof (SW:1206-1208) calls scaffolds `kvE2_sepSlotsL_valid`/`_valid` (SW:894/901, **sorry @897/904**) documented "FALSE post-switch." Not merely unproven — rests on false lemmas |
| C11 | `kvE2_sepBody_complete` | — | **A** | Never stated (grep 0). The ⇐ half of Lemma 3.2(1) is absent (P6) |
| C12 | `kvE2_sepHonestBundleL` (SW:1083) | From honest qnf, left-int σ yields anchor x1 + real witnesses per `zXU/zUW` 1-type; reuses extract | **F (L only)** | Reusable per-owner honest bundle; the **R variant is ABSENT** |
| C13 | `kvE2_sepHonestBundleR` | — | **A** | Only L exists (Agent survey). Completeness side is half-built |
| C14 | `kvE2_sepSingleton` + `kvE2_sepBody_singleton*` (SW:1944/1952/2069/2212) | Scope predicate "≤1 positive sub"; `singleton := kvE2_sepBody` defeq (:1952); two **strategic sorries** @2093/@2225 | **D (cost-driven retreat)** | Handoff 06 §1/§6: singleton characterizes a proper subclass; not faithful sufficiency. Abandon as the completeness route |
| C15 | `kvE2_sepFreshAnchor_ne_baseChiPoint` (SW:1133) | `χ ≠ nf0_projFresh σ.1 ∧ p⊨χ → p ≠ x1` (via `nf_eval_unique`); axiom-clean | **F (reduced form)** | Correct, but antecedent `hχne` is "the genuine obstruction, not dischargeable for arbitrary cross-owner base types." Reusable only in the **non-coincident** disjuncts; the coincident disjunct uses P13 instead |
| C16 | `kvE2_sepCoincidentAnchor_discharge` (SW:1161) | See P13 — the closed-zone brick | **F** | Axiom-clean (verified). Live INPUT to the faithful coincidence disjunct |
| C17 | `List.mergeSort` | — | **absent (retired)** | Handoff 04's "mergeSort divergence" is no longer live; the live divergence is C3+C4. `.permutations` (SW:474/479) is the faithful disjunction enumeration, not a total sort |

### 1c. Composition into the outer gate (`bracketEndChar_kvE2` / `kvE2_body`)

| Item | Finding | Verdict |
|---|---|---|
| `bracketEndChar_kvE2`, `kvE2_body` live `def` | **NONE.** grep for `def/abbrev/theorem/lemma <name>` = 0 across the split files; every occurrence is a docstring citing stale monolith lines (`:5032`, `:8608`, `:8712`, `:5940`) | **A (unbuilt)** — task 321 v4 rebuild not done |
| Outer assembly engine | NS Phase-7 RESCOPE (NS:385-449): the two-level outer quant-layer connector is a "genuine unbuilt ENGINE"; four captured failed closers on the soundness crux (NS:423-435) | The gate is structurally CAPABLE (per-sub pair `kvE_subBracket2V_correctness_pair` SB2V:1855 discharges arity-4 depth-1 both ways) but the ASSEMBLY is absent |
| Intended fold `kvE2_outer_fold` | `kvE2_body … .holds ↔ (atomLayer ∧ ∀σ, (∃x1, nf_eval M 1 4 [x1,w,x,t] σ) ↔ qnf.2 σ)` (NS:445-446) | Documented target only; matches the `nf_eval_nf` unfolding (§2) |

---

## 2. PART 2 — Closing the residual confidence gap to HIGH

### 2a. Does the outer gate's completeness demand cross-σ interval consistency (joint), or only per-σ existence?

**Answer: the SEMANTIC target is per-σ-independent, but the CARRIER (VVecEA2) representation is
JOINT — and the representation is what the induction requires. So JOINT is required. HIGH.**

Type-checked ground (`NormalForm.lean:198-207`, `nf_eval_nf` at depth `k+1`):

```
nf_eval_nf M (k+1) n env ⟨atom, quant⟩ =
  (∀ a, atom_eval M env a ↔ atom a = true) ∧
  (∀ sub, (∃ x, nf_eval_nf M k (n+1) (Fin.cons x env) sub) ↔ quant sub = true)
```

Instantiating the gate target `∃ w, nf_eval_nf M 2 3 [w,x,t] qnf` (NS:406) unfolds to:

```
∃ w, atomLayer(w,x,t) ∧ ∀ σ:(NF 1 4), (∃ x1, nf_eval_nf M 1 4 [x1,w,x,t] σ) ↔ qnf.2 σ
```

- The `∃x1` sits **inside** `∀σ`; the `∃w` is a **single** shared witness **outside**. Hence for
  positive owners the witnesses `x1_σ` are **independently** existentially quantified — they may
  coincide, need no relative order. The **model semantics is genuinely per-σ**, sharing only `w,x,t`.
- **Therefore the earlier "per-σ ⇒ soften to singleton" hedge is NOT supported by the semantics
  being joint** — it is refuted by a different mechanism:

**Why JOINT is nonetheless required (the resolution).** The carrier's output type is `VVecEA2` — a
**disjunction of totally-ordered exists-forall brackets** (`VVecEA2.holds = ∃ vea ∈ list, vea.holds`,
NS:220-230; a single `VecEA2 n` is one ordered `x_0<…<x_n` bracket). This is the exact normal form
the whole Prop 4.2 negation-closure induction operates on (`neg_2var_vec_ea` consumes `VVecEA2`,
NS:178-184). To express the per-σ **conjunction** `⋀_σ (∃x1_σ …)` (existentially closed over `w`,
with the negative owners' universal β-constraints over the shared interval) **as a single
`VVecEA2`**, you must list all witnesses `(w, x1_σ, x1_τ, …)` as the ordered points of one bracket in
some order — i.e. you must perform the merge. Different orders = different disjuncts; the coincidence
`x1_σ = x1_τ` is one order-type (one shared point carrying the meet). **This is exactly Lemma 3.2(1),
and it is unavoidable**: a conjunction of two per-owner `VVecEA2`s is not a `VVecEA2` unless folded by
the conjunction-closure, and handoff 06 §3 proved the codebase's closure (`VecEAClosure.lean:87-98,
163-169`) is lossy/forward-only — and *even a correct* closure *is* Lemma 3.2(1). Per-σ semantics
does not license a per-σ **representation**; the required output normal form forces the merge.

Additionally, the negative owners' β-constraints (`qnf.2 σ = false ⇒ ∀x1, ¬nf_eval σ`) are universal
over the **shared** interval `(x,t)`, so the merged bracket's segment (β) types must be the **meet**
of all owners' segment requirements while excluding negatives — a genuinely joint, non-trivial
representational obligation (this is what C7's binary cut cannot express).

**Net for 2a**: JOINT REQUIRED, at HIGH. The joint-ness lives in the `VVecEA2` representation
(Lemma 3.2(1)) — faithfully realized as an order-type disjunction with segment-meet — not in the
model semantics. The singleton retreat therefore characterizes a strict subclass and is a divergence
(confirms handoff 06's verdict, removes its hedge).

**Honest residual (why this is "HIGH on the architecture", not "gate type-checked end-to-end")**:
`bracketEndChar_kvE2`/`kvE2_body` have **no live def** — I cannot run `lean_goal` on the gate's
completeness obligation because the gate is unbuilt (task 321 v4). What is type-checked is (i) the
semantic target's structure (`NormalForm.lean:198-207`), (ii) the carrier type's disjunction shape
(`VVecEA2.holds`), and (iii) the per-sub correctness pair (SB2V:1855). The end-to-end completeness
proof cannot be certified until the assembly engine is built — but its **required shape** is now
grounded, not speculative. This is an implementation gap, not a faithfulness uncertainty.

### 2b. Is the closed/point-type coincidence channel constructible for a FAITHFUL order-type filter?

**Answer: YES — the channel is already built, green, and axiom-clean; the only thing missing is a
filter that ROUTES it. A faithful order-type-disjunction filter can.**

- **The closed channel exists and is sound.** `kvE2_sepCoincidentAnchor_discharge` (SW:1161)
  produces `kvE2_sepBits σ kvE2_sep_zAtX1L χ = true` at `v = x1`; **`lean_verify` = axiom-clean**
  (`[propext, Classical.choice, Quot.sound]`, no `sorryAx`). Its route is the extractor's **generic
  zone-forward channel** (SB2:614-618), which quantifies over **all** `ZoneSpec 4` — including the
  closed `zAtX1L` — so the extractor **admits** the closed channel in the forward (completeness)
  direction. (No closed *reverse* channel exists, SB2:619-624 — but completeness only needs forward.)
- **Why the ADDITIVE filter cannot consume it** (re-confirmed at def level): zone keys differ in
  coordinate 0 — `zAtX1L=(false,false)·…`, `zXU=(true,false)·…`, `zUW=(false,true)·…` (SB2:123/127,
  SW:114) — so `nf0_assemble` yields **distinct keys** and `σ.2` at them are **independent** bits.
  `kvE2_sepValid` reads the open bits (C5); the coincidence produces the closed bit; no lemma bridges
  them (handoff 05 type-checker refutation; here corroborated by `kvE2_sepBody_nonvacuous` carrying
  `sorryAx`).
- **Why a FAITHFUL filter CAN consume it.** In an order-type disjunction the coincidence is a
  **distinct disjunct** whose validity predicate reads the **closed** `zAtX1L` bit (not the open
  bits). Since `VVecEA2` is already a disjunction (list of `VecEA2`) and the discharge produces
  exactly that bit, the disjunct is admissible. This is **not** Option A (adding `zAtX1L` to the
  *same* additive filter over the *same* flat slot union, which handoff 06 §5 rejected as symptom-
  patching) — it is per-order-type validity where each disjunct reads the zone bits appropriate to
  **its** arrangement (open bits for strict disjuncts, closed `zAtX1L` for the coincidence disjunct).

**Net for 2b**: constructible in principle — the make-or-break brick is already green and axiom-clean,
and the extractor admits the closed forward channel. The prior blocker was routing (additive filter),
not constructibility. HIGH.

### 2c. Confidence summary

| Question | Prior (06) | Now | Basis |
|---|---|---|---|
| Multi-owner (JOINT) required? | MEDIUM-HIGH | **HIGH** | `nf_eval_nf` structure + `VVecEA2` output-type forces Lemma 3.2(1) (§2a) |
| Additive open-zone filter faithful? | NO (MEDIUM-HIGH) | **NO, HIGH** | `sorryAx` in `kvE2_sepBody_nonvacuous` + scaffolds documented FALSE (C10) |
| Closed/point channel constructible? | open (06 asked for spike) | **YES, HIGH** | `kvE2_sepCoincidentAnchor_discharge` axiom-clean + admitting extract (§2b) |
| Gate completeness type-checked end-to-end? | N/A | **NOT YET** (unbuilt) | No live `def` for `kvE2_body`/`bracketEndChar_kvE2` (§1c) — implementation gap, not faithfulness gap |

---

## 3. PART 3 — Faithful reconstruction blueprint (inputs for a plan)

**3.1 Faithful `kvE2_sepValid` / compat structure = order-type disjunction (Lemma 3.2(1)).**
Replace `kvE2_sepArrL/R := (flatMap slot union).permutations.filter (additive kvE2_sepValid)` with a
disjunction indexed by the **relative order-types of the merged anchor set** `A := {x1_σ : σ∈pos} ∪ {w}`.
Each order-type `π` is a weak order (ties allowed) on `A`; per `π`:
- the *strict* adjacencies are validated by the surviving open-zone compat leaves (C5) —
  `kvE2_sepCompat_lX1_eq/_after_eq/_rX1_eq/_after_eq` (SW:409/422/434/446) are correct **inside a
  disjunct** and **SURVIVE**;
- each *tie* (coincidence `x1_σ = x1_τ`) is a first-class sub-case validated by a **new closed-zone
  leaf** reading `zAtX1L`, fed by `kvE2_sepCoincidentAnchor_discharge` (C16), with the segment type
  set to the **meet** (§5 md:168-173).
Of task 333's four compat leaves: **all four survive** (as strict-disjunct validators); **must add** a
fifth closed-zone (`zAtX1L`) leaf. `kvE2_sepValid`/`kvE2_sepArrL/R`/`kvE2_sepSlotLe` (C3/C4/C6) are
**rebuilt** (the flat union + global additive filter is abandoned).

**3.2 Lifting the proven region partition to multi-anchor.**
`k1v_sorted_realization3` (SB2V:379, three regions around `{x1,w}`) generalizes to a **k-region**
partition around the merged anchors `A` (per disjunct, `A` is fixed and strictly ordered). Each region
`(a_i, a_{i+1})` gets a per-region **Nodup** type list realized strictly interior, fed to the
already-proven per-region insertion induction `k1v_sorted_realization` (CK1V:1447). Distinctness is
**per-region-per-owner** (type-driven `nf_eval_unique`, NormalForm:245) — which IS available; the
joint carrier's error was demanding distinctness **across** owners **at an anchor**. This is NOT a
total single-point sort; it is per-owner region-interior witnesses over a merged, per-disjunct-fixed
anchor set. The `.permutations`-as-disjunction machinery (SB2V:129,249-251) is reused verbatim per
region.

**3.3 Closed/point-type coincidence channel (§5 meet-type).**
The coincidence disjunct's anchor is a shared point carrying `α_A ∧ α_B` (meet). Discharge = the
green `kvE2_sepCoincidentAnchor_discharge` (SW:1161) producing the `zAtX1L` bit; the merged segment
type is the meet of both owners' β requirements (new three-way cut replacing C7's binary cut). The
"unpreventable coincidence" (handoff 03) becomes the **discharge witness** (`charK` existential).

**3.4 Assets to REUSE vs DIVERGENCES to ABANDON.** (full list in §4.)

**3.5 Rough size and principal risks.**
- Size: consistent with Option B `~700-1050 lines` (305/reports/37 §4.4); net-new = k-anchor
  partition lift + order-type disjunction index + closed-zone leaf + three-way segment cut + the
  ⇐ completeness (`kvE2_sepBody_complete`) + the absent R honest bundle. The per-region engine and
  single-owner correctness pair already exist.
- **Risks (ranked):**
  1. **Order-type enumeration blow-up / decidability**: the weak-order index set on `A` must be a
     finite, `decide`-able list; tie-handling (which anchors coincide) multiplies disjuncts. Mitigate
     by keeping the index a `List` of weak orders and reusing `VVecEA2.disjList` (NS:140).
  2. **Segment-meet correctness**: the three-way cut's "at" case must set the meet type AND stay sound
     for the negative owners' universal β. This is the genuinely new proof content (C7 rebuild).
  3. **⇐ completeness (P6/C11)**: never stated before; each honest arrangement must select its
     order-type disjunct. Template exists (`mem_permutations.mpr (Perm.refl _)`, SB2V:1440) but must
     lift across owners.
  4. **Outer-gate assembly still unbuilt (§1c)**: even a faithful `kvE2_sepBody` must be wired into
     the (absent) `kvE2_body`/`bracketEndChar_kvE2` gate (task 321 v4 / NS Phase-7 engine). The
     faithful rebuild does not remove this separate assembly obligation — but it makes the rebuilt
     carrier a correct input to it.
  5. **`sorryAx` cleanup**: retire scaffolds `kvE2_sepSlotsL_valid`/`_valid` (SW:894/901) so the new
     non-vacuity is axiom-clean.

---

## 4. Divergences to ABANDON vs Assets to REUSE

**ABANDON (Lean-convenience divergences, no faithful role):**
- `kvE2_sepSlotsL`/`R` flatMap slot union (C3, SW:315/320) — the flat cross-owner list.
- `kvE2_sepValid` + `kvE2_sepArrL`/`R` additive open-zone filter (C4/C6, SW:466/472/477).
- `kvE2_sepBody_nonvacuous` (C10, SW:1191) — **`sorryAx`-contaminated, rests on FALSE scaffolds**;
  and the scaffolds `kvE2_sepSlotsL_valid`/`_valid` (SW:894/901).
- The singleton retreat `kvE2_sepSingleton` / `kvE2_sepBody_singleton*` + its two strategic sorries
  (C14, SW:1944/2069/2212, sorries @2093/@2225) — covers only a proper subclass.
- `kvE2_sepSegLForSub`/`RForSub` binary before/after cut (C7, SW:561/574) — rebuild as three-way.
- (Historical: `List.mergeSort` joint sort — already retired, C17.)

**REUSE (faithful, landed, verified):**
- `k1v_sorted_realization` (CK1V:1447) + `k1v_sorted_realization3` (SB2V:379) — the region engine
  (**F**, sorry-free). Lift to k anchors.
- `kvE_subBracket2V` (SB2V:139, codomain `VVecEA2`) + `kvE_subBracket2V_correctness_pair` (SB2V:1855,
  sorry-free, non-vacuous) — the single-owner bracket, both directions.
- `kvE_subBracket2_complete_extract` (SB2:606) incl. the **generic zone-forward channel** (SB2:614-618)
  that admits `zAtX1L`.
- `kvE2_sepCoincidentAnchor_discharge` (SW:1161) — **axiom-clean** closed-zone brick; the §5
  coincidence discharge.
- The four compat leaves `kvE2_sepCompat_{lX1,lX1_after,rX1,rX1_after}_eq` (SW:409/422/434/446) — correct
  **inside strict disjuncts**; add a 5th closed-zone leaf.
- `kvE2_sepFreshAnchor_ne_baseChiPoint` (SW:1133, reduced form) — for the **non-coincident** disjuncts.
- `kvE2_sepHonestBundleL` (SW:1083) — per-owner honest bundle; **build the absent R mirror** (C13).
- The 10 non-interior `_sound`/`_complete` dischargers + Prop 4.3 reflatten engine
  (`disjList_holds`/`reflatten_prop43`, NS:149/193) + Prop 4.2 `neg_2var_vec_ea` — all **F**, landed.

**BUILD (absent, on the faithful critical path):**
- `kvE2_sepBody_complete` — the ⇐ direction of Lemma 3.2(1) (P6/C11).
- `kvE2_sepHonestBundleR` (C13).
- The order-type disjunction index + closed-zone compat leaf + three-way segment-meet cut (§3).
- (Separately, downstream) the outer `kvE2_body`/`bracketEndChar_kvE2` assembly engine (§1c).

**Recommendation**: `/revise 334` onto Option B as scoped above. Do NOT re-dispatch `/implement`
against the additive-filter carrier; do NOT retreat to singleton. The faithful rebuild reuses the
proven region engine and single-owner pair — it is a generalization, not a fifth green-field carrier.

---

## 5. H4 adversarial self-verification — what the pass changed

Applied the Claim Verification Bar to every load-bearing claim; challenged FAITHFUL and DIVERGENT
rows in both directions.

| Claim | Source / counterexample tested | Verification method | Confidence |
|---|---|---|---|
| Semantic target is per-σ-independent (shared w) | `∃x1` inside `∀σ`, single `∃w` | `NormalForm.lean:198-207` read at source | High |
| JOINT still required despite per-σ semantics | Steelmanned "per-σ ⇒ singleton", then refuted | `VVecEA2` is the required output normal form; conj of per-owner `VVecEA2` ≠ `VVecEA2` w/o Lemma 3.2(1); handoff 06 §3 lossy closure | High |
| Closed channel constructible/axiom-clean | `kvE2_sepCoincidentAnchor_discharge` | `lean_verify` = `[propext, Classical.choice, Quot.sound]` | High |
| Additive-filter non-vacuity is FALSE, not just unproven | `kvE2_sepBody_nonvacuous` | `lean_verify` = `…, sorryAx, …`; scaffolds SW:894/901 doc "FALSE post-switch" | High |
| Region partition faithful (strict interior, fixed anchors, no total sort) | `k1v_sorted_realization3` | Survey read at SB2V:379-402; no `List.mergeSort` (grep 0) | High |
| Zone keys independent (open vs closed) | `zXU/zUW/zAtX1L` coord-0 | Def-level read SB2:123/127, SW:114 + handoff 05 type-checker | High |
| `bracketEndChar_kvE2`/`kvE2_body` unbuilt | grep for live `def` | grep 0 across split files; NS:385-449 RESCOPE record | High |
| Order-type disjunction + meet is what §5 does | md:77, md:168-173, 213-219 | Paper read in full | High |
| `kvE2_sepBody_complete` absent; R-bundle absent | grep 0; survey | Two independent surveys | High |

**What the adversarial pass changed:**
1. **Removed handoff 06's MEDIUM-HIGH hedge → HIGH.** The hedge was "if gate completeness reduces to
   per-σ existence, soften to singleton." I *confirmed* the semantics IS per-σ (which naively supports
   the hedge) and then **refuted the hedge by a different mechanism**: the joint merge is forced by the
   `VVecEA2` output-type (Lemma 3.2(1)), not by joint semantics. This inversion — per-σ semantics does
   NOT imply per-σ representation — is the main product of the pass and is what raises confidence.
2. **Reclassified the "mergeSort divergence."** It is no longer live (retired; grep 0). The LIVE
   structural divergence is the flatMap slot union + additive open-zone filter (C3/C4). I corrected
   any claim that mergeSort is the current defect.
3. **Upgraded C10 from "unproven" to "FALSE."** `lean_verify` showing `sorryAx` on
   `kvE2_sepBody_nonvacuous`, plus the scaffolds documented "FALSE post-switch," means the current
   joint non-vacuity is not a gap to fill but a false claim to abandon.
4. **Surfaced two ABSENT constructs** (`kvE2_sepBody_complete`, `kvE2_sepHonestBundleR`) not named in
   handoffs 04-06 — the ⇐/completeness side is half-built, sharpening the Part-3 BUILD list.
5. **Challenged the FAITHFUL rows** (P1-P4, P8-P10, region engine, single-owner pair): each truly
   matches the paper (verified at source, not by name) — no FAITHFUL row was downgraded, but P4/P8 were
   annotated to distinguish single-owner faithfulness from the multi-owner β-merge divergence (C7).

**Contradiction log (resolved):** none unresolved. The apparent tension "semantics per-σ (supports
singleton) vs JOINT REQUIRED" is resolved by precedence of the representation obligation (the output
`VVecEA2` normal form the negation-closure induction requires) over the model-semantics reading —
grounded in `NormalForm.lean:198-207` + `VVecEA2.holds` (NS:220). This strengthens, not weakens, the
JOINT verdict and is fully consistent with handoffs 04/05/06.
