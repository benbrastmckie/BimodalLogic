# Research Report 01 — prop43_exterior_reflatten (task 348)

- **Session**: sess_1783796165_b5b482_348
- **Date**: 2026-07-11
- **Agent**: lean-research-hard-agent (H2+H3+H4+H5 contracts active)
- **Reference grounding tier**: **Tier 1 (literature-backed)** — Rabinovich 2014, "A Proof of
  Kamp's Theorem" (`~/Projects/Literature/sources/rabinovich_2014/`, chunks read on demand;
  per-repo sub-index entry `rabinovich_2014` mandates page-number-only citation)
- **Literature preflight notice**: `literature-lit-flag-resolve.sh` is absent from
  `.claude/scripts/`; per task instructions the fallback was used — `literature-search.sh`
  (FTS query returned empty / errored on dotted query), then direct chunk navigation via
  `specs/literature-index.json` → `~/Projects/Literature/sources/rabinovich_2014/chunk_*.md`.
  Chunks 0011, 0012, 0014, 0015, 0021, 0023 were read (Prop 4.2/4.3, Cor 5.4, Lemma 5.3 O_n
  device, Def 7.5, Lemma 7.6, Lemma 7.10). No whole-file dumps.
- **Method status**: The task-347 adjudication (re-flatten/adjacency, NOT exterior exclusion)
  is **confirmed, not re-opened**. One machine-grounded *qualification* on the "feed
  neg_2var_vec_ea" instruction is recorded in Finding F2 and the H5 section — it constrains
  *how* the asset feeds, not *whether* the method is right.

---

## Summary

1. The exterior-marked `hexclExt` residue is a single verbatim binder appearing at three
   sites (fold hypothesis SW:12710, gate hypotheses OuterGate.lean:312/:393), consumed at
   exactly one proof point (SharedWitness.lean:12788). Its statement is reproduced verbatim
   in Finding F1.
2. The named entry problem `Prop43.lean:120–159` is a **documented blocker comment, not
   sorried code**: Prop43.lean ships sorry-free atom/lt building blocks and a write-up of why
   the connective cases of a *uniform* (model-independent) Prop 4.3 are blocked. The
   already-proven `neg_2var_vec_ea` (EANegationClosure.lean:722) feeds the route through its
   **proof machinery** (the §5 F-chain/complement toolkit), not as a black-box theorem — its
   stated conclusion `∃ v', v'.holds M atomMap z0 z1` is pointwise and closable by a
   trivially-true `VVecEA2` (the very construction at EANegationClosure.lean:699–708), a fact
   Prop43.lean:126–129 itself records. Finding F2 gives the precise consequences.
3. The recommended architecture (Finding F3) discharges `hexclExt` in four stages:
   (P1) a cheap zone-determination lemma shrinking the genuine residue to
   `zPastX3`/`zFutT3`-marked σ; (P2) model-independent **one-sided complement clauses**
   (Cor 5.4(1)/(2) exterior analogs over the finite σ alphabet, reusing the landed Lemma 5.3
   `fChain` kit and `prior_hasAttainedINF`); (P3) adjacent exterior brackets
   (Def 7.5 / Lemma 7.10 shapes) + an enriched gate whose conjunction at the shared anchors
   `x, t` realizes the Lemma 7.6 adjacency composition; (P4) gate-level discharge theorem +
   consumer wiring (scope-coupled with 309 Phase 14 — flagged as Risk R1).
4. `HasAttainedINF` — the hypothesis of the entire §5 negation toolkit — is derivable from
   the consumer's existing `h_UZ` hypothesis via `prior_hasAttainedINF` (PriorINF.lean:224),
   so no new semantic hypothesis must be threaded.

---

## Finding F1 — the verbatim `hexclExt` goal shape as it now stands

Read directly from `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/OuterGate.lean:312–318`
(soundness half; byte-identical at `:393–399` on the assembled gate, and at
`SharedWitness.lean:12710–12715` on the fold, with `charK` generalized):

```lean
(hexclExt : ∀ w : M.carrier, x < w → w < t →
  (kvE2_sepPtW (nf_depth0_char_formula atomMap h_surj) (fun χ => P.existF 0 χ) qnf).eval_at
    M atomMap w →
  ∀ σ : NormalForm sig 1 4, qnf.2 σ = false →
    ¬ (nf0_zoneSpec σ.1 = kvE2_sep_zXW3 ∨ nf0_zoneSpec σ.1 = kvE2_sep_zWT3) →
    ∀ x1 : M.carrier, ¬ (x ≤ x1 ∧ x1 ≤ t) →
      ¬ nf_eval_nf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
```

This matches the 335 handoff (`specs/335_outer_gate_assembly_engine_kvE2_body/handoffs/03_frag-gate-for-309-and-348.md` §2) byte-for-byte.

**Sole consumption point**: `SharedWitness.lean:12788`, inside the forward direction of the
per-σ bit biconditional of `kvE2_outer_fold_frag` (SW:12665). The fold's `by_contra` +
`by_cases hcone` / `by_cases hzone` cascade (SW:12784–12788) routes: cone witnesses to
`hexcl`; exterior witnesses with interior-marked σ to the R1 lemma
`kvE2_sepInterior_exterior_notRealizable` (SW:12627); and exterior witnesses with
**non-interior-marked** σ to `hexclExt`.

**Precise extent of the residue** (from the zone constants, SW:70–96). The guard
`¬(zXW3 ∨ zWT3)` admits five canonical zones — `zPastX3` (`x1 < x`), `zAtX3` (`x1 = x`),
`zAtW3` (`x1 = w`), `zAtT3` (`x1 = t`), `zFutT3` (`t < x1`) — plus all non-canonical
`ZoneSpec 3` bit patterns. Under the exterior guard `¬(x ≤ x1 ∧ x1 ≤ t)` (i.e. strictly
`x1 < x ∨ t < x1`), a *realized* σ has its zone bits forced by the actual order relations of
`x1` against `[w, x, t]` (the depth-0 atom clause, `NormalForm.lean:201–202` — the same
transfer the R1 lemma uses at SW:12642–12649). Hence a realized exterior witness forces
`nf0_zoneSpec σ.1 = zPastX3` (side `x1 < x`) or `= zFutT3` (side `t < x1`); every other
zone marking (at-point or non-canonical) is refutable from order atoms alone, R1-style.
**The genuine mathematical residue is therefore exactly: σ marked `zPastX3` realized at some
`x1 < x`, and σ marked `zFutT3` realized at some `x1 > t`** — precisely Rabinovich's two
adjacent intervals `(−∞, x)` and `(t, ∞)`.

**Companion obligations 348 must keep intact** (335 handoff §1, verified at
OuterGate.lean:288/:299/:306): `hrealI` (interval-bounded interior realization over
`kvE2_sepPosI`, SW:211 — Cor 5.4 ⇐ shape), `hrealB` (boundary remainder, unbounded),
`hexcl` (cone exclusion). These are 309-Phase-14 provider obligations; 348 supplies only
`hexclExt`. The ⇐ (completeness) half of the gate is unconditional
(`bracketEndChar_kvE2_complete_two_prior`, OuterGate.lean:147, per handoff).

---

## Finding F2 — entry-problem state at Prop43.lean:120–159 and how `neg_2var_vec_ea` feeds it

**State (read directly)**: `Prop43.lean` (168 lines, off the live import path — "imported by
nothing live", header `:28–29`) contains **no sorries and no blocked code**. Lines 120–159
are a doc-comment BLOCKER write-up. What is landed sorry-free: `VVecEA_m.tt/ff` (+ holds
lemmas), `VVecEA_m.atomAt`/`atomAt_holds`, `VVecEA_m.ltAt`/`ltAt_holds` — the genuine uniform
atom/lt cases of Prop 4.3. The blocker records three machine-established facts:

1. **Per-model-existential vacuity** (`:123–129`): the statement
   `∃ v, (v.holds env ↔ eval φ)` at a fixed env is closed by `tt`/`ff` regardless of φ. It
   explicitly notes the same vacuity infects the *statement* of `neg_2var_vec_ea` /
   `neg_vec_ea_m`: their conclusion `∃ v', v'.holds …` is closable by the trivially-true
   witness. I verified this against the source: `neg_2var_vec_ea`
   (EANegationClosure.lean:722–731) concludes `∃ v' : VVecEA2, v'.holds M atomMap z0 z1`,
   and its own `nil` case (EANegationClosure.lean:699–708) constructs exactly the
   trivially-true `VVecEA2` that closes such a goal.
2. **Uniform negation UNFIXABLE as-constructed** (`:136–140`, corroborated by
   NegationIndep.lean:331–359): the model-INDEPENDENT construction `neg_2var_vec_ea_indep`
   has forward-only correctness (`¬v.holds → (neg_indep v).holds`, NegationIndep.lean:318–329);
   the backward direction is the report-18 B.1 gap (per-model bracket witness arrangements),
   re-confirmed with a live probe in task 305 plan v37 (comment `:349–357`).
3. **Missing closures** (`:141–153`): complete arity-m conjunction (Lemma 3.2(1) as iff) and
   Lemma 3.4 arbitrary-position existential closure (incl. leftward absorption) do not exist.

**Consequence for 348 (design constraint, not a method change)**: the instruction "feed the
already-proven `neg_2var_vec_ea`" is satisfiable only through its **proof machinery**, not
its statement. The reusable, genuinely-transcribed §5 assets are:

- The Lemma 5.3 F-chain kit: `BracketFormula.fChainFrom` (EANegation.lean:552),
  `fChainPred` (:567), `fChainFrom_base`/`_step` (:580/:616),
  `bracket_implies_fChainPred` (:660) — file header cites "Rabinovich 2014, Lemma 5.3 (p.8),
  Corollary 5.4 (p.9), Lemma 5.1 (pp.7–11)".
- The per-disjunct complement constructions inside EANegationClosure.lean
  (`neg_vecEA2`, `neg_interval_formula`, `neg_b2_bracket_formula` + its disjointness lemma,
  per NegationIndep.lean:336–338).
- `HasAttainedINF` (PriorINF.lean:202) with `prior_hasAttainedINF` (PriorINF.lean:224):
  derivable from `semantic_prior_UZ` — which the gate/consumer already carries as `h_UZ`
  (OuterGate.lean:371; KampPrior.lean's `nf_nvar_exist_all_depths` spec quantifies over
  `h_UZ h_SZ`). **No new semantic hypothesis is needed.**

**Why 348 does NOT need the full uniform Prop 4.3**: the KampPrior.lean:351 rung produces a
`{ A : Formula // ∀ M …, temporal_truth ↔ ∃ env … }` — the formula must be model-independent,
but only for the **specific, finite** family of exterior σ-clauses (σ ranges over
`NormalForm sig 1 4`, a fintype), not for arbitrary `VVecEA_m`. Rabinovich's own Cor 5.4(1)
proof (chunk_0015: "¬F0(z0) ∨ On(F1, …, Fn, z0, z1) is a ∨∃∀ formula equivalent to
¬(∃z)…") is a *syntactic* construction from the given α/β formulas — model-independent on
the page. The generic B.1 obstruction (arbitrary bracket witness arrangements varying per
model) is an artifact of negating an *arbitrary* `VVecEA2`; the exterior clauses 348 needs
have concrete known shape. Prop43.lean's blocker itself sanctions this resolution path
("restructuring Prop 4.3 to avoid the uniform-negation requirement", `:158–160`). The
first implementation phase should validate this on ONE concrete σ-clause before scaling
(Risk R2).

---

## Finding F3 — adjacency-composition architecture (what to build, where, sizes)

Faithful mechanism (settled; 347 report 01 §7 R2, verified against the paper): the exterior
arrangements belong to the adjacent intervals `(−∞, x)` / `(t, ∞)`, each with its own bracket
(Def 7.5 / Lemma 7.10 shapes), composed with the landed interior `(x, t)` bracket. Because
the seam variables `x, t` are already the gate's free anchors, **the Lemma 7.6 adjacency
primitive `(∃z1)^{<z2}_{>z0}(φ1 ∧ φ2) degenerates at this rung to plain conjunction at the
shared anchors** — no new seam existential is introduced at the k=2 gate level. (The full
`(∃z1)`-form of Lemma 7.6 is only needed if/when the general Prop 4.3 induction is built;
348's DoD does not require it.)

### P1 — Zone determination / residue triage (small; SharedWitness.lean or a small new file)

New lemma, R1-style, order-atom-only (mirror of `kvE2_sepInterior_exterior_notRealizable`,
SW:12627):

```
kvE2_exterior_zone_determination :
  nf_eval_nf M 1 4 [x1,w,x,t] σ → x < w → w < t →
  (x1 < x → nf0_zoneSpec σ.1 = kvE2_sep_zPastX3) ∧ (t < x1 → nf0_zoneSpec σ.1 = kvE2_sep_zFutT3)
```

Proof: the realized depth-0 atom clause transfers each of the six zone bits from actual order
facts (`lt_trans` chains through `x < w < t`), exactly the SW:12642–12649 transfer pattern in
reverse. Under `hexclExt`'s guards this immediately discharges every σ NOT marked
`zPastX3`/`zFutT3`, leaving two clean per-side obligations. **Est. 80–200 lines.** This is
the recommended first sorry-free lemma of the implementation (H2 bar).

### P2 — One-sided complement clauses (the mathematical core; new file, e.g. `Kamp/ExteriorNegation.lean`)

For each σ (finite alphabet) and each side, a **model-independent** `Formula` (anchored at
`t` for the future side via `Until`-navigation, at `x` for the past side via `Since`) with a
correctness lemma **pair**:

```
kvE2_extNegFut  (σ) : Formula                    -- "σ is not realized at any x1 > t"
kvE2_extNegFut_sound    : temporal_truth M atomMap t (kvE2_extNegFut σ) →
                          ∀ x1, t < x1 → ¬ nf_eval_nf M 1 4 [x1,w,x,t] σ   (modulo w,x threading)
kvE2_extNegFut_complete : (∀ x1, t < x1 → ¬ nf_eval_nf …) → temporal_truth … (kvE2_extNegFut σ)
```

(mirrored `kvE2_extNegPast` on `(−∞, x)`). Construction: Cor 5.4(1)/(2) exterior analogs —
Lemma 5.3's O_n / F-chain device over the one-sided interval, reusing
`BracketFormula.fChainFrom/fChainPred/bracket_implies_fChainPred` (EANegation.lean:552/567/660)
and `prior_hasAttainedINF` (PriorINF.lean:224, from `h_UZ`). Complication to budget for: σ is
depth-1 (its inner witnesses `v` range over zones of `[x1, w, x, t]`), so the clause must
handle inner-zone content the way the SubBracket2V kit does for interior σ — this is the
"genuine mathematical gap" the 346 spec names. **Both directions are genuinely needed**:
`_sound` discharges `hexclExt` (P4); `_complete` keeps the enriched gate's ⇐ half true (a
realized `qnf` gives, via `nf_eval_nf`'s per-σ biconditional, NO realizing `x1` anywhere for
a bit-false σ — in particular none exterior — from which `_complete` re-establishes the
clause). **Est. 800–2,000 lines across both sides; multiple dispatches; the P2 spike on one
concrete σ-clause should precede full commitment (Risk R2).**

### P3 — Adjacent exterior brackets + enriched gate (new file, e.g. `NfMultiAnchorBridge/ExteriorBracket.lean`)

- `kvE2_extBracketFut atomMap h_surj P qnf : Formula` — conjunction over `zFutT3`-marked σ:
  bit-true → existence clause (an `Until`-navigated "some `x1 > t` realizes σ"; the positive
  direction Lemma 7.10 says is TL-expressible "by a straightforward formalization as in the
  proof of Proposition 3.5", chunk_0023); bit-false → `kvE2_extNegFut σ`. Mirror
  `kvE2_extBracketPast` for `zPastX3`.
- Enriched gate = interior gate ∧ `extBracketPast` at `x` ∧ `extBracketFut` at `t` (the
  degenerate Lemma 7.6 composition; Def 7.13's `(z0, z1, ∞)`-conjunction shape, chunk_0023).
- **Est. 300–700 lines.**

### P4 — Discharge theorem + consumer wiring

- `bracketEndChar_kvE2Ext_correct_two_prior_frag`: assumes the enriched composed formula
  holds; calls `bracketEndChar_kvE2_correct_two_prior_frag` (OuterGate.lean:359) with
  `hexclExt` discharged by P1 (zone triage) + P2 `_sound` per side; extends the ⇐ half with
  P2 `_complete`. Keeps `hrealI`/`hrealB`/`hexcl` threaded outward untouched (309's
  provider). **Est. 200–400 lines.**
- KampPrior.lean:351 retirement: requires, besides 348's `hexclExt`, the 309-Phase-14
  provider discharge of `hrealI`/`hrealB`/`hexcl` and the ∀k-lift composition decision
  (335 handoff §5). See Risk R1 — the planner must either sequence 348-P4 after 309
  Phase 14 or pull the k=2 provider instantiation into 348's scope explicitly.

Files NOT to touch: `SharedWitness.lean` / `SubBracket2V.lean` below their frozen gates only
additively and only if P1 lands there (the 341/347 frozen-file discipline, 335 handoff);
`nf_eval_nf` (`NormalForm.lean:203–207`) must NOT be bounded in place (correct raw FOMLO
semantics — 347 report 01, 346 spec).

---

## Literature Proof Structure (Tier 1)

| Step | Rabinovich | What it does | 348 counterpart |
|------|-----------|--------------|-----------------|
| 1 | Prop 4.3, p.6–7 (chunk_0012) | structural induction: FO formula ≡ ∨∃∀; negation case = Lemma 3.2(2) split to ≤2-var conjuncts, then Prop 4.2 per conjunct, then Lemma 3.4 conjunction closure | the re-flatten warrant; 348 needs only its exterior-clause instances, not the full induction |
| 2 | Prop 4.2, p.6 (stmt), §5 pp.7–11 (proof) | negation of ≤2-var ∃∀ ≡ ∨∃∀ over Dedekind-complete chains | `neg_2var_vec_ea` machinery (EANegationClosure.lean; model-dependent statement — F2 qualification) |
| 3 | Lemma 5.3, p.8 + Cor 5.4, p.9 (chunks 0014/0015) | O_n / F-chain device: ¬(bounded ∃) ≡ ∨∃∀, syntactically from the α/β data | landed `fChain*` kit (EANegation.lean:552–660); P2 builds the ONE-SIDED analogs |
| 4 | Def 7.5, p.13 (chunk_0021) | `(z0, z1)`-∃∀ formula class | interior gate `bracketEndChar_kvE2` (landed) |
| 5 | Lemma 7.6, p.14 (chunk_0021) | adjacency: `(z0,z1)`-∨∃∀ ∧ `(z1,z2)`-∨∃∀ under `(∃z1)^{<z2}_{>z0}` is `(z0,z2)`-∨∃∀ | P3 composition — degenerates to conjunction at shared anchors `x, t` at this rung |
| 6 | Lemma 7.10, p.15 (chunk_0023) | one-sided `[…](z0, ∞)` brackets are TL-expressible | P3 exterior brackets' TL form (`Until`/`Since` navigation; zone docstrings SW:70/:95 already anticipate this) |

---

## H3 Lemma-Level Mapping Table (5-column, mandatory)

| Source | Prop/Location | Lean Identifier | Type Signature | Status |
|--------|---------------|-----------------|----------------|--------|
| Rabinovich 2014 | Prop 4.2, p.6 (stmt); §5 pp.7–11 (proof) | `neg_2var_vec_ea` | `HasAttainedINF M atomMap → (v : VVecEA2) → (z0 z1 : M.carrier) → z0 < z1 → ¬v.holds M atomMap z0 z1 → ∃ v' : VVecEA2, v'.holds M atomMap z0 z1` | transcribed (model-dependent; conclusion pointwise — see F2) |
| Rabinovich 2014 | Lemma 5.3, p.8 | `BracketFormula.fChainFrom` / `fChainPred` / `bracket_implies_fChainPred` (EANegation.lean:552/567/660) | chain-predicate constructions over `BracketFormula (n+1)` | transcribed |
| Rabinovich 2014 | Cor 5.4 ⇐, p.9 | `hrealI` binder shape (OuterGate.lean:288) | `∀ w, x < w → w < t → … → ∀ σ ∈ kvE2_sepPosI qnf, ∃ x1, (x < x1 ∧ x1 < t) ∧ nf_eval_nf M 1 4 [x1,w,x,t] σ` | transcribed (interior instance) |
| Rabinovich 2014 | Cor 5.4(1)/(2), p.9 — one-sided exterior analogs | target: `kvE2_extNegFut` / `kvE2_extNegPast` (+ `_sound`/`_complete`) | `Formula` + `temporal_truth M atomMap t (kvE2_extNegFut σ) ↔ ∀ x1, t < x1 → ¬ nf_eval_nf M 1 4 [x1,w,x,t] σ` (target shape, w/x threading TBD by plan) | pending (P2 — the missing core) |
| Rabinovich 2014 | Prop 4.3, p.6–7 | `VVecEA_m.atomAt_holds`, `VVecEA_m.ltAt_holds` (Prop43.lean:81/:100); connective cases | uniform atom/lt: `(VVecEA_m.atomAt …).holds M atomMap env ↔ M.interp p (env i)` etc. | atom/lt transcribed; connective cases pending (348 needs only exterior instances — F2) |
| Rabinovich 2014 | Def 7.5, p.13 | target: `kvE2_extBracketFut` / `kvE2_extBracketPast` | `(atomMap) → (h_surj) → ExistProviders sig atomMap 1 → NormalForm sig 2 3 → Formula` (target) | pending (P3) |
| Rabinovich 2014 | Lemma 7.6, p.14 | target: enriched-gate conjunction (degenerate adjacency at anchors `x, t`) | `bracketEndChar_kvE2Ext … := interior ∧ extPast(x) ∧ extFut(t)` (target) | pending (P3/P4) |
| Rabinovich 2014 | Lemma 7.10, p.15 | target: TL-expressibility of the one-sided brackets | `Until`/`Since`-navigated `Formula` at the anchor | pending (P3) |
| Rabinovich 2014 | Notation 5.2 / §5 interior-witness bounding | `kvE2_sepInterior_exterior_notRealizable` (SW:12627) | `(zone ∈ {zXW3, zWT3}) → ¬(x ≤ x1 ∧ x1 ≤ t) → ¬ nf_eval_nf M 1 4 [x1,w,x,t] σ` | transcribed (task 347 R1) |

---

## Risks and Mitigations

- **R1 (scope coupling — HIGH)**: 348's stated DoD includes "fold + soundness-half called
  with residue closed" and "KampPrior.lean:351 retired", but `hrealI`/`hrealB`/`hexcl` are
  309-Phase-14 provider obligations (335 handoff §1/§3), and the ∀k-lift fragment-scoping is
  flagged as a 309-plan decision (handoff §5). *Mitigation*: the plan must explicitly choose
  (a) 348 delivers through P4's discharge theorem with `hrealI`/`hrealB`/`hexcl` still
  threaded (348-complete, :351 retirement deferred to 309), or (b) 348 absorbs the k=2
  provider instantiation. Do not leave this implicit — it is the likeliest churn source.
- **R2 (model-independence of the one-sided complements — HIGH, the mathematical risk)**:
  the generic model-independent negation backward is UNFIXABLE as-constructed (report 18 B.1;
  NegationIndep.lean:331–359). 348 bets that the *specific* one-sided σ-clauses evade the
  obstruction (as Rabinovich's syntactic O_n construction suggests, chunk_0015).
  *Mitigation*: Phase-2 spike on ONE concrete σ-clause (both directions, sorry-free) as an
  early GO/NO-GO gate before building the full alphabet-indexed machinery. If the spike
  fails, escalate with the exact goal state — do not fall back to exterior-exclusion on the
  interior bracket (retired framing) or to a vacuous per-model existential.
- **R3 (depth-1 inner content of σ — MEDIUM)**: exterior σ are depth-1; their inner
  witnesses range over zones of `[x1, w, x, t]`, so the complement clauses need inner-zone
  handling analogous to SubBracket2V for the interior (335 report 07's info-ceiling analysis:
  exterior arrangements are constrained only through endpoint 1-types — the complement must
  supply exactly the missing per-exterior-point discrimination). *Mitigation*: reuse the
  placement-generic inner-zone constants (SW:98–128) and the SubBracket2 `fChainPred` bridge
  (SubBracket2.lean:102) rather than rebuilding.
- **R4 (statement-shape debt in feeding `neg_2var_vec_ea` — MEDIUM)**: treating it as a
  black box proves nothing (F2). *Mitigation*: the plan should name the internal assets to
  consume (`neg_vecEA2`, `neg_interval_formula`, `neg_b2_bracket_formula` + disjointness,
  `fChain*`) and forbid citing `neg_2var_vec_ea` as the discharge step itself.
- **R5 (frozen-file discipline — LOW)**: 341/347 gates freeze `SharedWitness.lean` /
  `SubBracket2V.lean` except below the SW:10210 banner. *Mitigation*: land P1 either below
  the banner or in the new file; keep OuterGate additive.
- **R6 (guard shape — LOW)**: the `hexclExt` guard is `¬(x ≤ x1 ∧ x1 ≤ t)`, which under
  linearity is `x1 < x ∨ t < x1`; the P1 side-split needs `push_neg`/`lt_of_not_le` plumbing
  on `M.carrier`'s linear order — verify `OrderedMonadicStructure` exposes a `LinearOrder`
  before writing P1 (it does everywhere else this pattern is used, e.g. SW:12784's
  `by_cases hcone`).

## Recommendations for the planner

1. Phase the work as P1 → P2-spike (GO/NO-GO) → P2-full → P3 → P4, with P1 the first
   sorry-free lemma (H2 bar) and the P2 spike an explicit gate.
2. Resolve R1 (scope boundary vs 309) in the plan header before any P4 work.
3. Cite Rabinovich by page number only (sub-index `citation_rule`); the md chunk line
   numbers are unstable.
4. Keep `Prop43.lean` off-path as the home of the general Prop 4.3 blocker documentation;
   land 348's exterior instances in the new files (P2/P3) on the gate path, updating the
   Prop43.lean blocker note to point at them once landed.

---

## Adversarial Self-Verification

Every load-bearing claim re-challenged against the sources. Verification methods: direct
`Read` of the named file/lines (equivalent-or-stronger than `lean_hover_info` for in-repo
declarations), direct `Read` of paper chunks, and `grep` declaration sweeps. Confidence per
the H4 taxonomy is folded into the Verdict column.

| Claim | Source/Counterexample | Verdict |
|-------|------------------------|---------|
| `hexclExt` binder is verbatim-identical at OuterGate.lean:312/:393, SW:12710, and the 335 handoff §2 | Read of all four sites this session | VERIFIED (High — 4 independent sites agree) |
| Sole consumption point of `hexclExt` is SW:12788 | Read SW:12774–12798; grep "hexclExt" over SharedWitness.lean shows no other consumption site (hypothesis sites only) | VERIFIED (High) |
| Prop43.lean:120–159 is a blocker doc-comment, not sorried code; file is off the live import path | Read Prop43.lean:1–168 (whole file, 168 lines); header :28–29 | VERIFIED (High) |
| `neg_2var_vec_ea`'s stated conclusion is pointwise and closable by a trivially-true `VVecEA2` | Read EANegationClosure.lean:722–731 (conclusion `∃ v', v'.holds M atomMap z0 z1`) + :699–708 (the trivially-true construction in the same proof) + Prop43.lean:126–129 (independent record) | VERIFIED (High — statement + explicit counterexample-witness construction + corroborating doc) |
| Model-independent negation backward is unprovable as-constructed (B.1) | NegationIndep.lean:331–359 (incl. task-305 plan-v37 re-confirmation probe); report 18 cited therein | VERIFIED (High as a record of prior machine probes; the *permanence* of the obstruction for the SPECIFIC one-sided clauses is untested — hence Risk R2's spike) |
| `HasAttainedINF` follows from the consumer's `h_UZ` | Read PriorINF.lean:202–239 (`prior_hasAttainedINF` proof, hypothesis exactly `semantic_prior_UZ`) | VERIFIED (High) |
| Genuine residue = `zPastX3`/`zFutT3`-marked σ at matching exterior side | Zone constants SW:70–96 (bit patterns read); transfer pattern SW:12642–12649; guard shape OuterGate.lean:317 | VERIFIED for the zone inventory (High); the P1 zone-determination lemma itself is a PROPOSED target, not yet machine-checked — flagged as pending, est. included |
| Lemma 7.6 composition degenerates to conjunction at shared anchors for the k=2 gate | Lemma 7.6 statement (chunk_0021: seam variable `z1` is the existentially-composed one); gate anchors `x, t` are free variables of `bracketEndChar_kvE2 … .holds M atomMap x t` (OuterGate.lean:400) | VERIFIED as a reading of the composition shape (Medium — this is an architectural inference, not yet a checked Lean statement; P3/P4 will test it) |
| Prop 4.3's negation case routes through Lemma 3.2(2) + Prop 4.2 + Lemma 3.4 | chunk_0012 proof text (read verbatim) | VERIFIED (High) |
| Cor 5.4's negation device is a syntactic O_n / F-chain construction | chunk_0015 (read: "¬F0(z0) ∨ On(F1,…,Fn,z0,z1) is a ∨∃∀ formula…") | VERIFIED (High) |
| `fChain*` kit exists and transcribes Lemma 5.3 | grep + EANegation.lean:21 header citation, :552/:567/:660 declaration sites | VERIFIED (High — declaration sites + header, two independent confirmations) |
| KampPrior.lean:351 is the n=1 strategic sorry of `nf_nvar_exist_all_depths` | Read KampPrior.lean:330–376 | VERIFIED (High) |
| 335 gate axiom-clean, build green, `SharedWitness` frozen | 335 summary 06 + handoff 03 (both read); NOT independently re-run this session | VERIFIED as reported (Medium — trust of a same-session artifact; re-run `lake build` + `#print axioms` at implementation start) |
| `BracketEndCharCarrierV` lives at CarrierK1V.lean:365 (task-description ":1872" is stale — pre-directory-split numbering) | grep: `abbrev BracketEndCharCarrierV` at CarrierK1V.lean:365; NfMultiAnchorBridge.lean is now a 90-line directory root; NavigatedSpine.lean:51 preserves the old ":1872" numbering as prose | VERIFIED (High) — implementers should cite CarrierK1V.lean:365 |

**Contradiction log**: none unresolved. The apparent tension "feed the already-proven
neg_2var_vec_ea" (346 spec / 347 report) vs. "its statement is vacuous as a black box"
(Prop43.lean:126–129 + direct read) resolves by precedence rule 1 (directly-read Lean source
wins): both are true simultaneously — the *statement* is weak, the *machinery* is the asset.
The 347 adjudication's phrase "the hard step, already proven" refers to the §5 construction
work, which is real and reusable. No side needed to be silently picked.

**Recommendations modified after verification**: (a) added R4 after confirming the
conclusion-shape vacuity against the source rather than trusting the blocker comment alone;
(b) downgraded the ":1872" carrier citation and replaced it with CarrierK1V.lean:365;
(c) narrowed the P2 bet with the spike gate after confirming the B.1 probe record.

## H5 Divergence Findings

No machine-checkable fact contradicts the settled re-flatten/adjacency method; the
adjudication is NOT re-opened. Two machine-grounded *qualifications* are recorded for the
planner (both already flagged above): (1) `neg_2var_vec_ea` feeds via machinery, not
statement (F2/R4 — evidence: EANegationClosure.lean:722–731 conclusion shape +
:699–708 trivially-true witness); (2) the task description's asset pointer
"`BracketEndCharCarrierV (NfMultiAnchorBridge.lean:1872)`" is a stale pre-split line
reference; the declaration is `CarrierK1V.lean:365`.

## References

- Rabinovich 2014, "A Proof of Kamp's Theorem": Prop 4.2/4.3 p.6–7; Lemma 5.3 p.8;
  Cor 5.4 p.9; Def 7.5 p.13; Lemma 7.6 p.14; Lemma 7.10 p.15
  (`~/Projects/Literature/sources/rabinovich_2014/`).
- `specs/335_outer_gate_assembly_engine_kvE2_body/handoffs/03_frag-gate-for-309-and-348.md`;
  `summaries/06_fragment-gate-summary.md`; `reports/07_hexcl-enrichment-derivability.md`.
- `specs/347_rabinovich_bracket_faithfulness_review/reports/01_bracket-faithfulness-adjudication.md`.
- `specs/346_successor_carrier_redefinition/summaries/01_successor-carrier-redefinition-summary.md`
  (§ prop43_exterior_reflatten, lines 195–278 — the authoritative spec, consumed verbatim).
- `specs/archive/330_k2_carrier_faithfulness_audit_and_correct_fold_representation/reports/01_faithfulness-audit-fold-representation.md` (REDESIGN).
- Code: `OuterGate.lean`, `SharedWitness.lean`, `Prop43.lean`, `EANegation.lean`,
  `EANegationClosure.lean`, `NegationIndep.lean`, `PriorINF.lean`, `KampPrior.lean`,
  `CarrierK1V.lean` (all under `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/`).
