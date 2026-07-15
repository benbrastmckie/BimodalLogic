# Phase 7 Divergence Audit — `kampPrior_hreal_supply` (`:116`) BLOCKER

**Task:** 370 (M2 de-folded interior carrier, Option B) — DIVERGENCE AUDIT (H5)
**Session:** sess_1784093800_976134 · **Mode:** lean4 HARD (read-only audit; NO Lean source edited)
**Focus:** `divergence audit phase7_discharge_116`
**Date:** 2026-07-15

---

## Verdict (HIGH confidence)

**THREADABLE — not genuinely blocked. The Phase-7 blocker's *symptom* is real (the current
`kampPrior_hreal_supply` signature is under-provisioned), but its *root-cause diagnosis and
prescribed fix are mis-scoped.**

Three specific corrections to the blocker:

1. **"The render is the SOLE missing ingredient" is REFUTED.** The de-folded endpoint evals
   `igEpRFib`@t / `igEpLFib`@x — the exact inputs Phase-3's render-free extraction lemmas
   consume — are **in scope in `bracketEndChar_kvFib_step_sound`** (`InteriorGateGeneralK.lean:2137`),
   the *direct consumer* of the `hreal` obligation. They are simply not threaded into the `hreal`
   binder's type. The render is *one* way to close `:116`; the endpoints are an **equally valid,
   already-available** way, and Phase 3 was purpose-built to consume them.

2. **The fix is a LOCAL additive signature enrichment, NOT a "Phase-6 gate_match
   re-architecture near the frozen boundary."** Every binder that must be enriched is an
   *additive de-folded sibling* landed by this task (Phases 4–6). The frozen assets
   (`bracketEndChar_kv` CarrierKv:238-249; the two `rfl` bridges IGGK:339-351 / CarrierKv:294-351;
   `KampPrior:519/:522`) are **not touched** by the enrichment. The blocker conflated "the Phase-6
   *sibling* work" with "the frozen boundary"; they are disjoint.

3. **Blocker obstruction (ii) — "σ's zone unknown" — is a non-issue.**
   `igFoldBitFib qnf zs σ = decide(qnf.2 σ = true ∧ nf0_zoneSpec(atom_assgn σ) = zs)`
   (IGGK:1349-1353). For a **marked** σ (`qnf.2 σ = true`, given by `hmark`) the zone bit fires for
   exactly `zs = nf0_zoneSpec(atom_assgn σ)`, which is **decidable/computable from σ**. The zone is a
   `by_cases`, not a missing hypothesis.

The **one** genuinely-hypothetical addition is the *non-render → char-soundness seam*
`hcharFibSound : ∀ τ x1, temporal_truth M atomMap x1 (charFib (k+1) τ) → nf_eval_nf M (k+1) 4 [x1,w,x,t] τ`.
This is **by design** a threaded hypothesis, because `charFib` is an *abstract parameter*
`(charFib : (j:Nat) → NormalForm sig j 4 → Formula)` throughout the whole stack — its soundness is
threaded exactly as the folded stack threads `P`/`hcharK` and the de-folded stack already threads the
render-gated `hcharFib`. Adding the → direction as a hypothesis is the *same kind* of by-design seam,
**not** a vacuous paper-over (see the anti-optimism check in §M1 and the H4 table).

---

## 1. Verify/refute "cannot discharge `:116` as currently provisioned"

**Live goal at `:116`** (`InteriorHrealSupplyK.lean:74-75`, sorry at :143):
`⊢ ∃ x1, nf_eval_nf M (k+1) 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ`,
under `hAmb`, `w` with `x<w<t`, `hptW : (igPtWFib … (charFib (k+1)) qnf.1 (igFoldBitFib qnf)).eval_at M atomMap w`,
`hmark : qnf.2 σ = true`, `hcons : kvE_fiberConsistent σ = true`. Hypotheses also include
`P : ExistProviders sig atomMap k`, `h_UZ`, `h_SZ`.

**Endpoint evals absent from `:116`'s own hypothesis set — CONFIRMED (as stated for the CURRENT
signature).** `kampPrior_hreal_supply` (IHS:60-75) receives only `hptW` (the `igPtWFib`@w witness eval,
`igZAtW`-zone content), `P`, `h_UZ`, `h_SZ`. No `igEpRFib`@t / `igEpLFib`@x, no non-render char seam.
The plan-prescribed firing `bracketEndChar_kvFib_realize_futT … ?hcharFib σ ?hz ?hepR` leaves the three
goals the blocker names. **This part of the blocker is accurate.**

**`hrender`-closes-it experiment — CONFIRMED structurally.** `hrender : nf_eval_nf M (k+2) 3 [w,x,t] qnf`,
`hrender.2` is the per-fiber biconditional `∀ σ, (∃x1, nf_eval [x1,w,x,t] σ) ↔ qnf.2 σ`, so
`(hrender.2 σ).mpr hmark` closes the goal. The render trivially discharges `:116` — which is *why* it is
circular (the render is produced downstream at `bracketEndChar_kvExtFib_correct_prior`, EGA:635-636).
**Accurate — but it does not establish the render is the *only* route.**

**Refutation of the load-bearing over-claim.** The critical read is
`bracketEndChar_kvFib_step_sound` (IGGK:2101-2194), the theorem that *consumes* the `hreal` obligation:

```
2135  rw [bracketEndChar_kvFib_succ_holds_iff …] at h_holds
2136  obtain ⟨_hgate, lL, _hlL, lR, _hlR, hveah⟩ := h_holds
2137  obtain ⟨hepL, hepR, hbr⟩ := hveah          -- ← igEpLFib@x, igEpRFib@t, bracket IN SCOPE
2139  obtain ⟨w, hxw, hwt, hptWe, …⟩ := k1v_bracket_extract … hbr
...
2194  exact hreal w hxw hwt hptWe sub hmark        -- ← hreal called with ONLY hptWe, NOT hepL/hepR
```

`hepL` (`igEpLFib`@x) and `hepR` (`igEpRFib`@t) are destructured at **line 2137** and are live at the
`hreal` call site (**line 2194**). They are simply **not passed** to `hreal`. So the endpoint evals are
**not absent from the call chain** — they are absent only from `hreal`'s *chosen* signature. The claim
"this upstream supply obligation receives none of the de-folded endpoint evals … the render is the sole
missing ingredient" is therefore **REFUTED**: the endpoints are one signature-slot away.

---

## 2. Trace the endpoint evals to their true source

| Fact | True source | Available where? | Threadable? |
|------|-------------|------------------|-------------|
| `igEpLFib`@x (`hepL`) | left endpoint of the carrier disjunct that holds | `step_sound` IGGK:2137 (also `kvExtFib_gate_henv` EGA:514-515) | YES — in-scope, pass at IGGK:2194 |
| `igEpRFib`@t (`hepR`) | right endpoint of the carrier disjunct | `step_sound` IGGK:2137 | YES — in-scope, pass at IGGK:2194 |
| bracket structure (`hbr`, witness `w`) | the carrier's bracket clause | `step_sound` IGGK:2137-2140 | YES — in-scope |
| zone bit `igFoldBitFib qnf zs σ` | `decide(qnf.2 σ ∧ atom-zone = zs)` | derivable from `hmark` + σ | YES — `by_cases` on σ's atom-zone |
| `hcharFibSound` (→ char seam) | **by design a hypothesis** (charFib abstract) | not in scope; propagates from eventual top instantiation | ADD as hypothesis (same kind as folded `P`/`hcharK`) |

**Is there a caller that already HAS the endpoints and merely fails to thread them? YES —
`bracketEndChar_kvFib_step_sound` itself.** It obtains `hepL`/`hepR` from the carrier's `.holds`
(the carrier being true is what makes them available — they come from the *carrier*, NOT from the
render), then delegates realizer production to `hreal` passing only `hptWe`.

**Is the fix (i) signature-threading of existing facts, or (ii) a genuine new obligation with no
source?** It is **(i) for the endpoints, the bracket, and the zone bit** (all in scope / decidable),
and **a by-design threaded hypothesis for the → char seam** (charFib is abstract, so its soundness is
*always* a hypothesis somewhere in this stack — it is never proved inside a leaf). It is **not** an
obligation with no available source, and it does **not** re-open M1 in the de-folded world (see §M1).

**Architectural note (no caller exists yet).** `kampPrior_hreal_supply`, `kampPrior_site_rungKFib_gate_match`,
and `bracketEndChar_kvExtFib_correct_prior` have **no non-definitional callers** (grep-confirmed). The
entire stack is uninstantiated hypothesis-threaded certificates; the render-gated `hcharFib` in the
gate_match binder is itself an unfulfilled hypothesis. The folded landed analog
`kampPrior_site_rungK_gate_match` (KP:941, :964-970) **also** carries `hreal` as an unfulfilled
hypothesis. **Nothing in the codebase discharges the interior supply** — `:116` is the genuine M2
primary leaf and the *first* place anyone attempts to prove it. This confirms the difficulty is inherent
to the interior-supply mathematics, and that the correct question is purely local (thread the in-scope
endpoints), not "where does the top get them" (there is no top yet).

---

## 3. Blast-radius bound (signatures that change)

All edits are **additive enrichment of de-folded SIBLING binders** (this task's own Phase 4–6 work).
**Zero** frozen-boundary touches.

| # | Symbol | File:line | Change | Frozen? |
|---|--------|-----------|--------|---------|
| 1 | `bracketEndChar_kvFib_step_sound` `hreal` binder | IGGK:2113-2118 | add `hepL`/`hepR`(/interior)/`hcharFibSound` params; supply `hepL`/`hepR` from :2137 at call :2194 | NO (Phase 5 sibling) |
| 2 | `bracketEndChar_kvFib_step_correct` `hreal` binder | IGGK:2222-2227 | propagate enriched `hreal` type | NO (Phase 5 sibling) |
| 3 | `bracketEndChar_kvExtFib_correct_prior` `hreal` binder | EGA:579-584 | enrich; endpoints derivable internally (cf. `kvExtFib_gate_henv` EGA:514-515) | NO (Phase 6 sibling) |
| 4 | `kampPrior_site_rungKFib_gate_match` `hreal` binder | KP:1084-1090 | enrich `hreal`; thread `hcharFibSound` alongside `hcharFib` | NO (Phase 6 sibling; folded `:941` untouched) |
| 5 | `kampPrior_hreal_supply` signature + body | IHS:60-143 | add matching params; **discharge** `:116` via realize lemmas + zone case-split | NO (Phase 5/7 sibling leaf) |

**NEVER touched:** `bracketEndChar_kv` (CarrierKv:238-249); rfl bridge #1 (IGGK:339-351); rfl bridge #2
(CarrierKv:294-351); do-not-retire `KampPrior:519/:522`; frozen `kampPrior_site_rungK_gate_match` (KP:941).
All five edits stay within the 6-file scope. The blocker's "touches the integration point nearest the
frozen boundary and modifies Phase-6 (frozen) work" is **misleading**: Phase-6 *siblings* are freely
editable additive work, disjoint from the frozen defeq.

---

## 4. Corrected micro-plan

### Phase 6′ — enrich the de-folded `hreal` binder to thread endpoints + → char seam
- **Symbols:** rows 1–4 above (`step_sound` IGGK:2113-2118 & call :2194; `step_correct` IGGK:2222-2227;
  `correct_prior` EGA:579-584; `gate_match` KP:1084-1090).
- **Do:** widen the `hreal` binder type to accept `hepR : (igEpRFib …).eval_at M atomMap t`,
  `hepL : (igEpLFib …).eval_at M atomMap x`, and
  `hcharFibSound : ∀ (τ:NF (k+1) 4) x1, temporal_truth M atomMap x1 (charFib (k+1) τ) → nf_eval_nf M (k+1) 4 [x1,w,x,t] τ`.
  In `step_sound`, supply `hepL`/`hepR` from the already-destructured `hveah` (IGGK:2137) at the call
  site (IGGK:2194); forward `hcharFibSound` from a new same-named hypothesis on `step_sound`. Propagate
  the new hypothesis outward through `step_correct` → `correct_prior` → `gate_match` (same threading
  pattern the render-gated `hcharFib` already uses).
- **Verification (green):** full `lake build` green; `git diff` shows CarrierKv:238-249, IGGK:339-351,
  CarrierKv:294-351, KP:519/522/941 byte-identical; `lean_verify` clean on the enriched siblings; the
  only remaining sorry is `:116`.
- **Reference-grounding:** mapping rows 8–11 (Phase-5/6 sibling binders), plan `01` §Preserved Assets.

### Phase 7′ — discharge `kampPrior_hreal_supply` (`:116`)
- **Symbols:** `kampPrior_hreal_supply` IHS:60-143; consumes `bracketEndChar_kvFib_realize_futT`
  (IGGK:1565), `bracketEndChar_kvFib_realize_pastX` (IGGK:1597), and (interior arm) the bracket
  structure / `kampPrior_fChain_realize_bracket` (KP:1660).
- **Do:** add matching `hepL`/`hepR`/`hcharFibSound` params (mirroring the enriched binder); then
  `by_cases` on `nf0_zoneSpec (atom_assgn σ)`:
  - `igZFutT` → `bracketEndChar_kvFib_realize_futT … hcharFibSound σ (zone-bit from hmark) hepR`
    (gives `x1 > t`);
  - `igZPastX` → `bracketEndChar_kvFib_realize_pastX … hcharFibSound σ (zone-bit) hepL` (gives `x1 < x`);
  - interior/`AtW` zones → from the bracket witness / `igPtWFib`@w content (needs the interior arm — see
    residual below).
  The zone bit is `igFoldBitFib qnf zs σ = decide(qnf.2 σ ∧ atom-zone = zs)`; for the matched zone it is
  `decide(true ∧ rfl) = true`.
- **Verification (green):** `lake build` of `InteriorHrealSupplyK.lean` green with `:116` **removed**;
  `lean_verify` / `#print axioms` show **no `sorryAx`**.
- **Reference-grounding:** mapping row 12; Phase-3 render-free extraction lemmas (report `01`
  §"M1 corroboration": the render-free extraction "is the only edit that breaks the circularity").

### Residual to confirm at Phase 0 of the next dispatch (Medium confidence)
- **Interior-zone coverage.** Phase 3 built only the **two exterior** render-free extraction lemmas
  (`_realize_futT`, `_realize_pastX`). If the marked population `qnf.2 σ = true` can contain **interior**
  (`igZXW`/`igZWT`/`igZAtW`) fibers, Phase 7′ needs either (a) an additive interior render-free
  extraction lemma (same *kind* as Phase 3; inputs — the bracket `hbr`/`igPtWFib`@w — are in scope in
  `step_sound`), or (b) a proof that marked σ are exterior-only at this deep-anchored site. Confirm the
  zone coverage of the marked population before committing Phase 7′'s case list. This does **not** change
  the verdict (all candidate inputs are in scope), only the count of extraction lemmas.
- **`hcharFibSound` satisfiability at instantiation.** The → seam must be dischargeable when `charFib`
  is eventually instantiated to a concrete characteristic formula. This is the same feasibility residual
  report `01` already flagged (obligation #3/#4), deferred to top-level instantiation — **not** this
  leaf's obligation, and **not** re-opening M1 (§M1).

### Escalation (only if Phase 0 refutes the residual)
If Phase 0 shows interior marked σ exist **and** no render-free interior extraction is possible **and**
`hcharFibSound` is provably unsatisfiable at exterior anchors (i.e. M1 bites in the de-folded world too),
then terminate `[BLOCKED]` for user review and escalate to the scoped rfl-preserving Option-A micro-step
with explicit user sign-off (plan `01` §Risks/Fallback). My read (§M1) says this is **not** the case.

---

## M1 anti-optimism check (is `hcharFibSound` a refuted/vacuous hypothesis?)

**No.** The M1 refutation (report `01` §192-205, corroborated at IHS:88-107) is specifically that **no
non-render firing route exists *over the existing FOLD*** — `igFoldBit_realize_iff` (IGGK:563) needs the
render, hence the *folded* route is circular. Report `01:203-205` states plainly that Option B's
de-folding "is the only edit that breaks the circularity by making the arity-4 realizer readable from the
endpoint without the render." The Phase-3 realize lemmas do exactly that, pushing the residual
render-dependence into the *→ char seam only*. M1 says nothing about the de-folded → seam being
unsatisfiable; it refuted the folded fold-bit bridge. Threading `hcharFibSound` is therefore threading a
**by-design, plausibly-satisfiable** seam (the natural soundness direction of a characteristic formula,
weaker than the render-gated ↔ already present), not a refuted one. Non-vacuity is confirmed at
instantiation, exactly as the folded stack confirms `P`/`hcharK`.

---

## Adversarial Self-Verification (H4)

| Claim | Source / Counterexample stress-tested | Verification Method | Verdict / Confidence |
|-------|----------------------------------------|---------------------|----------------------|
| Endpoint evals `hepL`/`hepR` ARE in scope where `hreal` is consumed | Tried: maybe step_sound only has `igPtWFib`@w. Read IGGK:2136-2137 + call site 2194 directly | live source read (IGGK:2101-2194) | **REFUTES blocker; High** |
| `hreal` is called with only `hptWe`, not endpoints | Read IGGK:2194 `exact hreal w hxw hwt hptWe sub hmark` | live source read | High |
| Endpoints come from the CARRIER, not the render | `hveah` obtained from `bracketEndChar_kvFib_succ_holds_iff` on `h_holds` (carrier `.holds`), no render in scope in step_sound | live source read IGGK:2135-2137 | High |
| **"Endpoint evals available upstream, just need threading"** vs **"not available anywhere without the render"** | Directly pitted: the render decomposes INTO the endpoints, but the endpoints are ALSO produced independently by the carrier being true (step_sound has them without the render) | live read of `step_sound` + `kvExtFib_gate_henv` (EGA:514-515 extracts same `hepL`/`hepR`) | **First disjunct TRUE; High** |
| Zone bit (blocker obstruction ii) is derivable, not a gap | `igFoldBitFib = decide(qnf.2 σ ∧ atom-zone=zs)`; marked σ ⇒ zone computable | live read IGGK:1349-1353 | High |
| Enrichment touches NO frozen asset | Rows 1-5 are all Phase 4-6 additive siblings; frozen `bracketEndChar_kv`/rfl bridges/`:519`/`:522`/`kampPrior_site_rungK_gate_match`:941 disjoint | grep + line-range cross-check | High |
| `hcharFibSound` is NOT a vacuous/refuted hypothesis | Tried: maybe M1 refutes it ⇒ threading it is a paper-over. M1 refuted the FOLDED fold-bit route only; charFib is abstract, seam threaded by design (folded `P`/`hcharK` analog) | report `01`:192-205 + IHS:88-107 + PriorInterface:38-45 | **Non-vacuous; Medium-High** |
| Interior marked σ may need a THIRD extraction lemma | Only `_realize_futT`/`_realize_pastX` exist (grep). Interior coverage unproven either way | grep IGGK realize lemmas | **Residual flagged; Medium** |
| Nothing discharges the interior supply anywhere (so `:116` is the genuine leaf) | Folded `kampPrior_site_rungK_gate_match`:941 ALSO threads `hreal` unfulfilled; no non-def callers of the stack | grep callers + read KP:964-970 | High |
| Whole stack is uninstantiated (no "top" to source facts from) | grep: no non-definitional callers of gate_match / correct_prior / hreal_supply | grep repo-wide | High |

**Contradiction Log.**
1. **Blocker "genuinely blocked / render-only" vs audit "threadable" (RESOLVED, audit prevails).**
   Precedence: *live source read of the consumer `step_sound` > the leaf's in-body self-diagnosis*.
   The leaf note reasons from `kampPrior_hreal_supply`'s OWN hypothesis set (correctly finding it
   under-provisioned) but never inspects its consumer `step_sound`, which holds the endpoints. Reading
   the consumer resolves the contradiction in favor of "threadable." No unresolved contradiction.

**Residual (honest).** Two Medium items, neither affecting the THREADABLE verdict: (a) interior-zone
coverage may require one additive interior extraction lemma (inputs in scope); (b) `hcharFibSound`
satisfiability is deferred to top-level instantiation (same as the folded `P`/`hcharK`; the pre-existing
obligation-#3/#4 residual). Both are Phase-0 confirmations for the next dispatch, not blockers.

**Anti-analysis (H2) note.** No sorry-deferral, axiom, or placeholder is recommended. Phase 7′ targets
sorry-free discharge of `:116`; the fallback is `[BLOCKED]` + user-signed scoped Option-A, only if
Phase 0 refutes the residual — which the M1 analysis indicates it will not.
