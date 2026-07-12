# Report 09 (Teammate C) — Resolving the F1-vs-Prior Contradiction (C′ viability)

- **Task**: 349, Phase 3 research team, Angle C
- **Session**: sess_1783841542_df767b
- **Mode**: lean-research-hard (H2/H3/H4/H5). READ-ONLY. No Lean source edited.
- **Focus**: does F1 refute a Prior-guarded `charF` carrier; is C′ viable and faithful?
- **Authority**: actual Lean statements/countermodels (file:line) + Rabinovich 2014 (`md:` via report 07).

---

## VERDICT (contradiction RESOLVED — against C′)

**C′ (the Prior-hypothesis-guarded closed-formula `charF`/`kv_body` carrier) is GENUINELY DEAD.**
The report-08 "UNRESOLVED CONTRADICTION" is now resolved by a machine-checked artifact that
report 08 never located: **`f2_relativized_refutation` (RefutationF2.lean:859)**.

- F1 (`bracketEndChar_kv_factors`, CarrierKv.lean:422) alone does NOT refute a Prior-guarded
  carrier — report 08 was **correct** on that narrow point. F1 is a structure-independent
  factorization ("the machine-checked ISOLATION half", CarrierKv.lean:415), and F1's *own*
  narrative countermodel `(ℚ,<)` with finite `P` **fails** `semantic_prior_UZ` (RefutationF2.lean:86,
  919), i.e. is NON-Prior.
- **BUT** F2 = `f2_relativized_refutation` closes exactly that escape route: it re-runs the F1
  mechanism on a **genuine Prior structure** `M* = (ℤ,<)`, `P={0,10,20}` (RefutationF2.lean:104)
  for which **both** Prior hypotheses are PROVED green (`f2_UZ`:145, `f2_SZ`:156), and refutes the
  UZ/SZ-guarded k=2 (`bracketEndChar_kv … charF 2`) correctness statement **for EVERY provider
  family `charF`** (∀-quantified, RefutationF2.lean:860). Recorded axioms
  `[propext, Classical.choice, Quot.sound]` (RefutationF2.lean:958); file is in the compiled main
  library (imported by NfMultiAnchorBridge.lean:32); no `sorry`.

So: **F1 does not, but F1+F2 do, refute the Prior-guarded `charF` carrier.** C′ as defined in
report 08 ("adopt the `kv_body` construction + add `semantic_prior_UZ/SZ`") is refuted on its own
turf. Report 08's recommendation of **(D) Prop-valued carrier** as the F1/F2-agnostic primary
stands and is *strengthened*: (D) is now the only survivor, not merely the safer bet.

---

## Q1 — What EXACTLY does F1 prove, over what structure class?

**`bracketEndChar_kv_factors` (CarrierKv.lean:422) is a structure-INDEPENDENT term equality.** Its
conclusion is `bracketEndChar_kv atomMap h_surj charF (k+1) qnf = bracketEndChar_kv … qnf'`
(a `VVecEA2` *carrier equality*), with **no `M`** anywhere in statement or proof. The proof is pure
congruence: `rw [e2, e3, h1]` (CarrierKv.lean:439–453) over three agreement hypotheses —
`qnf.1 = qnf'.1` (atom layer), `hoff` (off-fiber Prop `↔`), and `hb` (fiber-existential fold bits
`∃ sub, qnf.2 sub ∧ zoneSpec = zs ∧ nfk_projFresh sub = χ`, `↔`). It quantifies over neither
general nor Prior structures — it is a fact about the carrier *function*, not about soundness.

Therefore F1, on its own, refutes **nothing semantic**. It only establishes the *information-loss
channel*: at successor depth the carrier reads `qnf.2` solely through (atom layer, off-fiber Prop,
arity-1-projection fold bits). The actual refutation requires a *semantic* second half — a model
plus two quant layers agreeing on that channel yet semantically distinct.

The `charF`/`kv_body` route this bears on: `bracketEndChar_kv` (CarrierKv.lean:238) at `k+1` is
`kv_body (nf_depth0_char_formula …) (charF k) qnf.1 (offFiber) (fun zs χ => decide ∃ sub …)`
(CarrierKv.lean:244–249). The fold bit projects each arity-4 depth-`k` sub via
`nfk_projFresh : NormalForm sig k 4 → NormalForm sig k 1` (arity-1), discarding the joint relation
between the fresh interior witness and the other three anchors `[w,x,t]`.

## Q2 — Is the F1/F2 countermodel a Prior structure?

**Two distinct countermodels; the decisive one IS Prior.**

- The obstruction report 08 cited, `endCharN0_correct_infeasible` (Base.lean:1779), is **not F1's
  countermodel at all** — it refutes the *single-point world-locality base* (`Mcex = Bool`,
  Base.lean:1761; a `TemporalPred` at `env 0` cannot read `env 1`). It is a different finding, is
  NON-Prior (no UZ/SZ), and concerns depth-0 world-locality, not the k≥2 fold collapse. Report 08
  conflated it with F1.
- F1's *narrative* countermodel is `(ℚ,<)` with finite `P` (RefutationF2.lean:26) — **NON-Prior**,
  fails `semantic_prior_UZ` (finite `P` has no first occurrence above `t`).
- **F2's countermodel `M* = (ℤ,<)`, `P={0,10,20}` (RefutationF2.lean:104) IS a Prior structure**:
  `f2_UZ`/`f2_SZ` (RefutationF2.lean:145/156) are fully proved green via the ℤ well-ordering
  (`f2_int_first`/`f2_int_last`, `Nat.find`, RefutationF2.lean:111/128). `semantic_prior_UZ`
  (PriorDefs:22) = "every future occurrence has a first occurrence with `ψ.neg` on the gap";
  `(ℤ,<)` satisfies it because nonempty subsets of `(t,∞)` have least elements.

So the answer to the mission's Q2: **the decisive refuting structure IS Prior.** The
non-Prior-ness of F1's `(ℚ,<)` model (report 08's basis for doubt) is real but irrelevant — F2
was built precisely to be Prior and still refutes.

**How F2 distinguishes the two quant layers on `M*`** (RefutationF2.lean:917–935): `qnf :=` the
depth-2 characteristic 3-type of `[w,x,t]=[15,2,18]`, realized at `w=15`; `qnf' :=` `qnf` with the
`u₂=4` sub un-marked. Two arity-4 subs `f2sub1` (type of `[12,15,2,18]`) and `f2sub2` (type of
`[4,15,2,18]`) **share** their fiber data — `f2_sub_atom_eq` (:371, atom layer), `f2_sub_proj_eq`
(:471, `u₁=12` and `u₂=4` share their complete depth-1 arity-1 type) — so `f2_carrier_eq` (:582):
the carrier CANNOT distinguish `qnf` from `qnf'`. But `f2sub1 ≠ f2sub2` (:413), witnessed by the
depth-0 5-type `e* = "P z ∧ x<z<u"` (`f2_estar_in_sub1`:382 / `f2_estar_not_in_sub2`:389 — the
`(2,4)` gap has no `P`-point). And `f2_no_witness` (:797): **no** `w'` realizes `qnf'` in `M*`.
Hence the guarded `↔` at `qnf` (carrier holds via `w=15`) transports through `f2_carrier_eq` to
`qnf'`, forcing a nonexistent `qnf'`-witness — contradiction (RefutationF2.lean:889–896).

## Q3 — Is `charF`/`nf_characterizable_temporal_prior` green and correct on Prior structures? Does the fold give determinacy?

**`charF` itself is green and correct — but that is not where C′ dies.**
`nf_characterizable_temporal_prior` (KampPrior.lean:407) returns, for every depth-`k` arity-1 NF,
a `Formula A` with `∀ M (h_UZ : semantic_prior_UZ)(h_SZ : semantic_prior_SZ)(t),
temporal_truth M atomMap t A ↔ nf_eval_nf M k 1 (fun _=>t) nf` (KampPrior.lean:413–419). It is a
sorry-free `induction k` (zero: `nf_depth0_char_formula`; succ: `nf_nvar_exist_all_depths_fn`,
KampPrior.lean:420–459). So a faithful depth-`k` **point** characterization on Prior structures
exists — the carrier already consumes it (`kv_body … (charF k) …`).

**The fold does NOT give the determinacy C′ needs, and this is provable, not conjectural.**
Report 08's open "resolving check" was: does `nf_quant_layer_fold_iff` make the fold fiber
determine quant-layer semantics on Prior structures? **Answer: NO.**
- `nf_quant_layer_fold_iff` (NfEFold:391) is stated **only for depth-0 subs**
  (`q : NormalForm sig 0 (n+1) → Bool`; `sub : NormalForm sig 0 (n+1)`). Its docstring D7 reminder
  (NfEFold:373): *"this bridge is claimed ONLY at depth-0 subs (k=1); NO depth-`k` (k≥1) pointwise
  equivalence is stated or attempted."* At depth 0 the fold is EXACT because `nf0_split_assemble`
  (NfEFold:235) is a bijection and fibers are singletons — which is exactly why `k=1`
  (`bracketEndChar_kv_correct_one`, CarrierKv.lean:395) is sorry-free and the refutation starts at
  `k=2` (RefutationF2.lean:57–60, "Isolation").
- At `k≥1` subs, a fiber `(zs, χ)` over `qnf.1` holds **≥2 subs** differing in deeper JOINT layers
  that the arity-1 projection cannot see (RefutationF2.lean:52–55, item 3). F2 machine-checks a
  concrete such pair on a Prior model. The Prior hypotheses buy attained first/last occurrences
  (`PriorINF:224`), **NOT** the joint deeper structure of same-fiber subs (RefutationF2.lean:945–946).

So `nf_quant_layer_fold_iff` gives determinacy at `k=1` only, and F2 is the explicit witness that
determinacy FAILS at `k=2` even on Prior structures.

## Q4 — Is a Prior-guarded `charF` interior faithful to Rabinovich?

**No — the `kv_body`/`charF` carrier is UNFAITHFUL at the vocabulary-enrichment step**, and the
codebase's own F2 record says so (RefutationF2.lean:60–68, 902–908, cross-checked against report 07
`md:` citations). Rabinovich works over Dedekind-complete linear orders (`md:233`), and his faithful
depth-`k` object (Def 7.13, `md:451`; §5 Notation 5.2 `[α0,β1,…,αn](z0,z1)`, `md:219`) carries the
joint content between anchors via **round-enriched vocabulary**: Def 3.1's α_j/β_j are one-variable
quantifier-free formulas *over the current (enriched) vocabulary* (`md:109–111`), and after each
Prop-4.3 fold round (`md`, PDF p.6) that vocabulary includes the previous round's TL-definable
content — the `F_i` of Cor 5.4 are **TL formulas, not base-signature types** (`md:263`, report 07:77).
The joint structure of a fresh witness relative to the anchors thus rides the enriched
interval/segment formulas.

The `kv_body` carrier instead projects subs to **plain depth-`k` 1-types over the BASE signature**
(`nfk_projFresh`), discarding exactly that joint structure (RefutationF2.lean:66–67). The arity-4
residual `[x₁,w,x,t]` whose in-fiber markings the F1/F2 counterexamples toggle "had **no Rabinovich
counterpart** — it is a Lean `nf_eval_nf` arity-growth artifact" (RefutationF2.lean:903–905). So C′
is not a faithful Rabinovich construction; a faithful closed-formula interior would require the
enriched-segment bracket (the v6 `bracketEndChar_kvE` per-sub enriched carrier,
RefutationF2.lean:947) — a strictly larger construction than `kv_body`. This dovetails with report
07's ranking: the two-endpoint FAITHFUL in-tree object is the **Prop-valued**
`nf_zone_flatten_navigable(_correct)` (Base.lean:687; report 07:148 line 6, "FAITHFUL"), which is
option D — not the closed-`Formula` `charF` carrier (report 07 rows 4/5, "UNFAITHFUL").

## Q5 — Verdict: is C′ viable / more-or-less faithful than D?

**C′ is dead** (refuted by a green Prior-structure countermodel, `f2_relativized_refutation`), and
would be **less faithful** than D even if it were not: C′ discards the anchor-joint content that
Rabinovich carries in enriched segments, whereas D (Prop-valued, subs kept at full arity 4 with the
witness outside via the green Step-A reduction `endCharStep_quant_reduceA`, NavigatedEndChar.lean:281)
preserves the relation exactly and is F1/F2-immune (the refutation mechanism only bites carriers that
project through `nfk_projFresh`; D never projects). **Recommendation: pursue (D); do NOT re-open C′.**
No `charF`-provider choice or Prior-hypothesis addition can rescue the `kv_body` codomain — `∀ charF`
is baked into F2.

---

## Reference grounding (H3 Tier 1) — source-to-Lean mapping

| Source (Rabinovich 2014 / codebase) | Location | Lean identifier | Signature (verified from source) | Status |
|---|---|---|---|---|
| §5 Notation 5.2 two-endpoint bracket | `md:219` | `bracketEndChar_kv` | `… (charF)(k) : BracketEndCharCarrierV sig k` (CarrierKv.lean:238) | GREEN carrier (but F2-refuted target) |
| Def 4.1 char formula (arity-1 depth-`k`, Prior) | `md:137` | `nf_characterizable_temporal_prior` | `(k)(nf) : {A // ∀ M h_UZ h_SZ t, temporal_truth … A ↔ nf_eval_nf M k 1 (fun _=>t) nf}` (KampPrior.lean:407) | GREEN (Prior-correct point char) |
| Prop 4.3 innermost ∃-fold (depth-0 only) | `md` p.6 | `nf_quant_layer_fold_iff` | `q : NormalForm sig 0 (n+1) → Bool; … ↔ (monadic fold ∧ off-fiber)` (NfEFold:391) | GREEN — depth-0 ONLY (D7, :373) |
| §7 Def 7.13 / Cor 5.4 enriched segments | `md:451`/`md:263` | (none faithful; `bracketEndChar_kvE` planned) | — | UNBUILT (the faithful route) |
| F1 factorization (isolation half) | — | `bracketEndChar_kv_factors` | structure-indep. carrier equality on `(atom, offFiber, fold bits)` (CarrierKv.lean:422) | GREEN |
| Single-point world-locality refutation | — | `endCharN0_correct_infeasible` | `Mcex=Bool`; NON-Prior; refutes depth-0 base (Base.lean:1779) | GREEN (unrelated to F2) |
| semantic half on a PRIOR model | — | `f2_relativized_refutation` | `∀ charF, ¬(∀ qnf …, ∀ M, UZ→SZ→∀ x t, kv.holds ↔ ∃w nf_eval)` (RefutationF2.lean:859) | GREEN — **THE C′ refutation** |
| Prior model witness | — | `F2M`,`f2_UZ`,`f2_SZ` | `(ℤ,<),P={0,10,20}`; both Prior hyps proved (RefutationF2.lean:104/145/156) | GREEN |

---

## Adversarial Self-Verification (H4)

### Claim Verification Table

| Claim | Source / Counter-probe | Verification Method | Confidence |
|---|---|---|---|
| F1 is a structure-independent carrier equality (no `M`) | CarrierKv.lean:422–453 (proof `rw [e2,e3,h1]`) | direct source type read | High |
| F1 alone does NOT refute a Prior-guarded carrier | F1 statement mentions no `M`; F1's `(ℚ,<)` model fails UZ (RefutationF2.lean:86,919) | source read | High |
| `endCharN0_correct_infeasible` is NON-Prior and is a DIFFERENT (world-locality) finding | Base.lean:1761 `Mcex=Bool`, no UZ/SZ; refutes depth-0 base | source read | High |
| `f2_relativized_refutation` refutes the UZ/SZ-guarded k=2 `kv` statement for EVERY `charF` | RefutationF2.lean:859–873 (`∀ charF`, UZ/SZ in hyps, `¬(∀ qnf …)`) | direct source type read | High |
| Its model `M*=(ℤ,<),P={0,10,20}` genuinely satisfies both Prior hyps | `f2_UZ`:145 / `f2_SZ`:156 proved via `f2_int_first/last` (`Nat.find`) | source read (proof bodies, no sorry) | High |
| C′ (kv_body+Prior) = exactly the refuted statement | report 08:19,74 defines C′ = kv_body+UZ/SZ; F2 refutes `bracketEndChar_kv … charF 2` under UZ/SZ | cross-ref + source | High |
| `nf_quant_layer_fold_iff` gives determinacy at depth-0 subs ONLY (k=1) | NfEFold:391 signature + D7 docstring :373 | direct source read | High |
| `charF` (`nf_characterizable_temporal_prior`) is green + Prior-correct point char | KampPrior.lean:407–459 (sorry-free induction) | source read | High |
| kv_body/charF carrier is UNFAITHFUL (discards enriched joint content) | RefutationF2.lean:60–68,902–908; report 07:145–149 | source + report 07 `md:` map | High |
| RefutationF2 is in the compiled main library (theorem really elaborates) | imported by NfMultiAnchorBridge.lean:32; whole-project build green at HEAD (git log task 351 ph6) | grep import + git log | High |
| Recorded axioms `[propext, Classical.choice, Quot.sound]` (no extra axioms) | RefutationF2.lean:958 in-file record | in-file record; my own `lean_verify` returned empty (cold LSP — inconclusive, non-contradicting) | Medium |

### Attempt to REFUTE my own verdict (mandatory adversarial pass)

1. **"F2 refutes only the specific `kv_body` carrier, not the general C′ notion."** — Partially
   true and I incorporate it: F2 kills the `bracketEndChar_kv`/`kv_body` construction (which is
   exactly report-08's C′), for all `charF`. It does NOT refute an entirely different closed-formula
   carrier that avoids the arity-1 `nfk_projFresh` fold (the enriched-segment `bracketEndChar_kvE`).
   But that is a *different, larger* construction, not report-08's C′, and is UNBUILT. So the verdict
   "C′ (as defined) is dead" holds; I explicitly do NOT claim "no closed-formula carrier can ever
   work" — only that the `charF`/`kv_body` one cannot.
2. **"Maybe F2M isn't really Prior / `f2_UZ` is vacuous."** — Checked: `f2_UZ`/`f2_SZ` are proved
   for arbitrary `ψ` via genuine ℤ well-ordering (`f2_int_first` uses `Nat.find`, non-vacuous);
   `semantic_prior_UZ` (PriorDefs:22) is the real first-occurrence principle. Not vacuous.
3. **"Maybe the refuted `↔` is stronger than C′'s target (e.g. drops a needed hypothesis)."** —
   The refuted statement (RefutationF2.lean:861–873) carries the six bracket-zone order bits AND
   both Prior hyps AND is stated for the exact carrier `.holds`. It is the *guarded*
   `BracketCarrierCorrectV`, i.e. C′'s target with hypotheses ADDED (not removed). A refutation of a
   more-guarded statement is strictly stronger evidence against C′. No hypothesis that C′ would add
   is missing.
4. **"My `lean_verify` returned empty axioms — maybe the theorem doesn't actually hold."** — The
   empty result is a cold-LSP artifact (no elaboration, no warnings), not `axioms: none on a real
   proof`. The theorem is imported into the compiled library and the whole-project build is green at
   HEAD; the in-file record documents the axiom check. I flag this as the one Medium-confidence link
   and recommend the synthesis agent re-run `lean_verify` after a warm build if absolute certainty is
   required — but it does not change the verdict, which rests on the green build + source.

**Result of adversarial pass**: verdict UNCHANGED and strengthened. The only scoping caveat (point 1)
is folded into the verdict: report-08's C′ is dead; a *faithful* closed-formula carrier would be the
unbuilt enriched-segment route, which is neither C′ nor smaller than D.

### Contradiction Resolution (report 08's UNRESOLVED item)

Report 08 logged: *"F1's docstring scopes it to the unconditional direction … while charF is correct
on Prior structures … resolving check not yet performed."* **RESOLVED.** Applying the precedence
machine-checked artifact > docstring > plan narrative: the missing machine-checked artifact is
`f2_relativized_refutation`, a Prior-model refutation. It supersedes the inference from F1's docstring
alone. Report 08's *narrow* claim (F1-alone doesn't refute Prior) was correct; its *practical*
conclusion (C′ might therefore be viable) is overturned by F2. Downstream risk report 08 flagged
(picking D when C′ would work) is void: C′ does not work.

---

## Cross-reference (06/08 — not repeated here)

- Report 06 (§4.5) and report 08 established: liftInterval infeasible (wrong arity), the syntactic
  `VVecEA2`-via-`bracketFromLists` carrier is inseparable from a closed-formula `charF`, and D
  (Prop-valued) consumes only green Step-A/Step-B assets. I do not re-derive these.
- **New relative to 06/08**: the decisive artifact `f2_relativized_refutation` (RefutationF2.lean)
  and its Prior model `F2M` — the semantic second half neither report cited. This is what converts
  report 08's "Low-confidence UNRESOLVED" into a **High-confidence closed verdict: C′ dead**.

## H5 divergence note

`focus_prompt` lacked the "divergence"/"audit" trigger tokens, but this dispatch functions as the
divergence resolution report 08 requested. **Root cause confirmed**: every carrier attempt has folded
the depth-`(k+1)` quant layer through an arity-1 point projection (`nfk_projFresh`), which is exact at
`k=1` (bijective fibers) but lossy at `k≥2` — and F2 proves the loss is not repaired by Prior
hypotheses. Convergent fix: stop emitting a per-witness closed type inside 349 (D), or build the
enriched-segment carrier (a new, larger task), deferring syntactic emission to 309/350 extraction.
