# Task 320 Deliverable — Joint-Pinning Probe Results (k=2 Carrier Gate, F4 Follow-Up)

- **Task**: 320 — de-risk the joint-pinning route for the k=2 carrier gate (F4 follow-up)
- **Parent**: 309 (BLOCKED at Phase 13.35, finding F4)
- **Date**: 2026-07-07
- **Type**: lean4 (machine-checked probe; NOT full carrier surgery)
- **Outcome**: **GO — route b3 (nested F_i-chain, Cor 5.4).** b1 = NO-GO, b2 = NOT NEEDED.
- **Machine-checked probe code**: `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge.lean`,
  NON-CONSUMED verdict section appended after the F4 record (`probe_P1_channel_i_collapse`,
  `probe_P3_cor54_step_shape`, `probe_P4_b3_positions_by_eval_point`; all axiom-clean, no sorry).
- **Deliverable branch**: GO → concrete design spec for task 321 (§5 below). No F5 defect record needed.

---

## 0. Executive Summary

The F4 blocker is a genuine *flattening* defect: the landed `bracketEndChar_kvE'` carrier crams an
interior positive sub's **joint two-anchor** content (the sub's inner-witness structure relative to
the honest anchor pair `(w, x)`, which rides `σ.2`) into a single provider literal `P.existF 3 σ`
evaluated at the one point `t`. That literal's private existential `e : Fin 3 → M.carrier` rebinds
`u/w/x`, producing the unpinnable residual `w = e 1`, `x = e 2` (no hypothesis relates the
provider-chosen `e` to the honest anchors).

Three routes were probed under the position-by-evaluation-point GO-gate litmus:

| Route | Machine state | Litmus | Verdict |
|-------|---------------|--------|---------|
| **b1** — repair channel (i) to consume `witnessZone` | `probe_P1_channel_i_collapse` closes by **`rfl`**: the finite arrangement family collapses to a constant function of `nfk_projFresh σ` (σ.1-level); `witnessZone` discarded | n/a (fails at construction) | **NO-GO** |
| **b2** — structural-identity via `nf_eval_unique`/`nfPred_correct` | `probe_P4_b3` closes with `bf.holds` as its **sole** hypothesis; no uniqueness premise present | n/a | **NOT NEEDED** |
| **b3** — nested F_i-chain sub-bracket (Cor 5.4) | `probe_P4_b3` recovers honest witness positions from `bf.holds` alone, `e`-free; position rides the nested-Until eval point (`probe_P3` = Cor 5.4 step shape) | **PASS** | **GO** |

The literature-alignment audit (`reports/01`) is machine-confirmed: b3 is the literature-faithful
mechanism (Rabinovich Cor 5.4 carries joint content by the nested-Until **evaluation point**, never
by a single-point positional assertion), b1 is a boxed falsifier (Def 3.1 pins σ's *own* witnesses,
no counterpart across the provider/`e` boundary), and b2 has no construction-level counterpart and is
not required. **No route needed `EANegation :1090/:1249` or provider-side pinning** — no escalation
blocker to surface; the outcome is a clean GO with a directly-implementable design spec.

---

## 1. Baseline reconstruction (Phase 1)

**Crux goal (verbatim, provider-independent).** After `P.correct 3 σ M h_UZ h_SZ t`:

- hypothesis `he : nf_eval_nf M 1 (3+1) (insertEnv e t) σ`, where `insertEnv e t = [e 0, e 1, e 2, t]`
  (anchor `t` LAST; `u/w/x` REBOUND by the provider's own `e : Fin 3 → M.carrier`);
- goal `nf_eval_nf M 1 (3+1) (Fin.cons x_1 (Fin.cons w (Fin.cons x fun _ => t))) σ`;
- funext residual `w = e 1`, `x = e 2` — **UNPINNABLE** (no hypothesis relates `e` to the honest anchors).

This is the F4 record's Machine probe B (`NfMultiAnchorBridge.lean` :5559-5574), re-certified by the
green build of the module.

**Provider-independent ℤ counterexample (Def 3.1 / defect bar).** `M = ℤ` (Prior UZ/SZ hold),
`p = {0}`, `r = {13}`, `x = 10`, `t = 20`, dishonest positive `σ'' = char[14,16,11,20]` (fake anchors
sharing only `t`; on-fiber, zone `zXW`, fresh type `type(14)`), honest `char[14,15,10,20]` marked
false. This is verbatim the counterexample already machine-recorded and green-re-certified in the F4
verdict (:5584-5595). The counterexample's mechanistic root — the honest and dishonest subs sharing
`nfk_projFresh` (`type(14) = type(15)`) while differing at `σ.2` — is re-confirmed machine-side by
probe P1 (§2).

*Baseline capture method (deviation from a literal standalone-term rebuild):* rather than reconstruct
a fresh standalone `ExistProviders`/`ℤ` falsity term, the baseline is captured via probe P1's `rfl`
(the collapse that IS the counterexample's discriminating-failure root) plus the landed, green F4
record. This is faithful to the "machine-checked baseline" requirement and avoids re-deriving material
the landed record already certifies.

**Do-not-edit assets** (recorded; byte-identity verified in §7): `bracketEndChar_kv`/`kvE_body`/
`bracketEndChar_kvE` (13.2, F1/F2); `bracketEndChar_kvE'`/`kvE'_body`/`kvE_pinDisjunct`/`kvE_exclConj`
(13.25, F4 exhibit); F1/F2/F3/F4 verdict records; `ExistProviders`/`BracketCarrierCorrectVPrior`
(13.1); all task-310/311 material.
**Consume-do-not-rebuild** (plan v7 :142-197): E[Σ]-fold engine; k1v proof kit + direction templates;
`nf_eval_unique`/`nfPred_correct`; `A_past`/`A_future`; `bracketBuildLeft/Right`; `VVecEA2`/
`bracketFromLists`/`existsBounded_right`; `fChainFrom`/`fChainPred`; the EANegationClosure forward
stack; `prior_hasAttainedINF`/`HasAttainedINF`.

---

## 2. Route b1 — boxed fast falsifier (Phase 2): NO-GO

**Probe `probe_P1_channel_i_collapse` (closes by `rfl`).**

```
(kvE_pinArrangements σ).map (fun a => kvE_pinDisjunct charBase charK σ a)
  = kvE_consistentZones.map
      (fun _ => ([⟨charK (nfk_projFresh σ)⟩], [⟨charK (nfk_projFresh σ)⟩]))
```

**Machine state**: `rfl`. Because `kvE_pinArrangements σ` (:5364) sets every arrangement's
`witnessType := nfk_projFresh σ` and *discards* `witnessZone`, every one of the seven consistent-zone
disjuncts reduces to the identical pair `([⟨charK (nfk_projFresh σ)⟩], [⟨charK (nfk_projFresh σ)⟩])`.
The channel-(i) content is therefore a function of the σ.1-level fresh type **alone** — positionally
vacuous.

**Consequence (discrimination failure).** Two subs with equal `nfk_projFresh` — the F4 counterexample's
dishonest `char[14,16,11,20]` and honest `char[14,15,10,20]` (`type(14) = type(15)`) — receive
byte-identical channel-(i) content. The channel cannot distinguish them.

**Why the repair cannot reach the gap (Def 3.1, md:61-74).** Even a *fully* zone-faithful repair (one
that genuinely reads `witnessZone` and both adjacent segment types per Def 3.1) only ever constrains
**σ's own** existential witness `u` inside **σ's own** bracket interval decomposition — its deliverable
after `k1v_bracket_extract` is a separate existential
`hpin : ∃ u, x < u ∧ u < w ∧ nf_eval_nf M 0 1 (fun _ => u) (nfk_projFresh σ)` (F4 record :5571-5573),
unconnected to the residual `e 1 = w`, `e 2 = x`. Def 3.1 has **no** device for forcing an externally
supplied environment (the provider's `e`) to coincide with the honest anchors; the provider/`e`
boundary is a Lean-encoding artifact (`ExistProviders.correct` :4856) absent from Rabinovich.

**Litmus / verdict**: b1 fails at construction (its content is a single-point σ.1-level literal); it can
never carry an inter-anchor positional fact by an evaluation point. **NO-GO** — a captured refutation
strengthening the F4/F5 lineage, exactly as the audit predicted (`reports/01` Q2, claim 4/7). Boxed at
`rfl`; no budget spent iterating "make b1 work."

---

## 3. Cor 5.4 chain-shape confirmation (Phase 3): MATCH

**Probe `probe_P3_cor54_step_shape`** re-derives, from the landed `BracketFormula.fChainFrom_step`
(EANegation:616):

```
(bf.fChainFrom i).eval_at M atomMap x
  ↔ (bf.pointTypes i).eval_at M atomMap x
     ∧ ∃ s, x < s ∧ (bf.fChainFrom ⟨i+1,_⟩).eval_at M atomMap s
                  ∧ (∀ r, x < r → r < s → (bf.segmentTypes ⟨i+1,_⟩).eval_at M atomMap r)
```

This is **exactly** Rabinovich Cor 5.4's step `F_{i-1} := α_{i-1} ∧ (β_i Until F_i)` (md:154-157):
`F_i` at `x` holds iff `α_i(x)` and there is a forward point `s` where `F_{i+1}` holds with `β_{i+1}`
along `(x, s)`. The next anchor's position `s` is carried by the **strict-Until evaluation point**
(md:41), never asserted as a relative-position identity between two independently bound variables.

The base case `F_n := α_n ∧ (β_{n+1} Until ⊤)` (`fChainFrom_base`, EANegation:580) is the
open-interval adaptation of Cor 5.4's `F_n := α_n`, folding the trailing segment `β_{n+1}` up to the
right endpoint `z` — appropriate for the `partialBracketExist` setting (`∃ z, bracket(z_0, z)`).

**Verdict: MATCH.** The probe type-checks *only because* the landed definition and the Cor 5.4
recursion coincide definitionally. The audit's MEDIUM-confidence claim 6 (`reports/01`) —
"`fChainFrom`/`fChainPred` genuinely match the Cor 5.4 chain shape" — is machine-CONFIRMED, with the
single documented adaptation (base folds the trailing segment via `Until ⊤`). No fallback to building
the chain from `A_past`/`A_future` primitives is required; the b3 cost estimate does **not** rise.

---

## 4. Route b3 — nested F_i-chain sub-bracket (Phase 4): GO

**Probe `probe_P4_b3_positions_by_eval_point`**, delegating to the landed, proven
`BracketFormula.bracket_implies_fChainPred` (EANegation:660):

```
(h : bf.holds M atomMap z0 z) →
  ∃ x0, z0 < x0 ∧ x0 < z
      ∧ bf.fChainPred.eval_at M atomMap x0
      ∧ (∀ y, z0 < y → y < x0 → (bf.segmentTypes ⟨0,_⟩).eval_at M atomMap y)
```

**Machine state**: closes by `bf.bracket_implies_fChainPred M atomMap z0 z h`; axiom-clean
(`propext`, `Classical.choice`, `Quot.sound`); no sorry.

**Why this is the F4 fix (the demonstrated-closed crux).** When the nested bracket holds on `(z0, z)`,
the F-chain predicate `fChainPred` is satisfied at a witness `x0` **strictly inside** `(z0, z)`,
recovered from the bracket's OWN interval pattern (`bracket_implies_fChainPred` proof :671:
`refine ⟨w ⟨0,_⟩, …⟩` — the witnesses `w i` are the honest positions). Unfolding `fChainPred` through
probe P3 exhibits each subsequent anchor at its own honest position via the nested Until:

- `F_0(x0) = α_0(x0) ∧ (β_1 Until F_1)` — the **evaluation point** of the inner Until lands `F_1`
  (hence `α_1`) at the next honest witness, no equation asserted;
- iterating, every inter-anchor positional fact rides an evaluation point.

Crucially, the conclusion contains **no** provider environment `e : Fin m → M.carrier` and **no**
residual `w = e 1` / `x = e 2`. The anchor positions ARE the bracket witnesses, quantified by the
temporal semantics — nothing ever rebinds them. This is precisely the joint multi-anchor content the
flattened `P.existF 3 σ` literal fails to carry.

**Litmus (position-by-evaluation-point): PASS.** Every inter-anchor positional fact in `fChainPred` is
carried by the evaluation point of a nested temporal operator (Cor 5.4 / Prop 3.5 single-free-variable
nesting), never by a single-point formula asserting a relative-position identity. **b3 = GO.**

**G1-G6 compliance of the probed mechanism**: `fChainFrom`/`fChainPred` operate on a `BracketFormula`
between two fixed endpoints; the F_i witnesses are bracket witnesses BETWEEN the endpoints (G4: anchor
set fixed at 2, witnesses grow, no third anchor; G6-as-amended). No arity-1 collapse (G1); no
projection-based VecEA2/third-anchor tower (G2); the chain steps are the landed proven lemmas with
Rabinovich citations at each step, no `simp`/`omega`/`aesop` in any chain-construction body (G5 —
the only `by omega` are `Fin`-index typing obligations in signatures, identical to the landed
`fChainFrom_step`). Off-diagonal segments carry real interval types via `segmentTypes`/`Until`, not
trivial-top (G3).

---

## 5. Design spec for task 321 (GO branch)

**Framing (binding).** "Carrier" here denotes the **Cor 5.4 recursive construction** — a
formula-building recursion over interior subs — **NOT** a flat carrier with more channels. A flat
reading is exactly the F1→F4 failure mode. The fix replaces the per-sub flattened joint literal
(`ptSub σ = ⟨charK (nfk_projFresh σ)⟩` at :5467 and the `t`-anchored `exF = P.existF 3 σ` at :5448)
with a per-sub **nested F_i-chain sub-bracket** whose content rides the Until evaluation point.

Task 321 builds these NEW definitions (additive; alongside, never editing, the landed `kvE'` assets):

1. **`kvE_subBracket`** — the nested sub-bracket for an interior positive sub.
   ```
   noncomputable def kvE_subBracket {sig : MonadicSignature} {k : Nat}
       (charBase : NormalForm sig 0 1 → Formula) (charK : NormalForm sig k 1 → Formula)
       (r : NormalForm sig 0 3) (σ : NormalForm sig k 4) : BracketFormula m
   ```
   - Encodes σ's inner-witness structure (the sub's own `u`) as bracket witnesses between the honest
     anchor pair `(x, w)` (or `(w, t)` per σ's zone), read from **σ.2** (the joint inner structure),
     NOT from `nfk_projFresh σ` (σ.1) alone. This is the single construction obligation task 321 owns:
     expose σ.2 via the existing normal-form projections at the sub level (analogous to
     `nf_x_proj3`/`nf_t_proj3`/`nf_y_proj`, VecEADecomp:33-47), building the `pointTypes`/`segmentTypes`
     from σ's inner anchor/segment types. `m` = number of σ's inner witnesses (≥ 1; the sub's own `u`).
   - Built from landed fixed-endpoint machinery (`bracketBuildLeft/Right`, `bracketFromLists`,
     `VVecEA2`), per G3/N4/G6. Generalized one level, never a third anchor (G6-as-amended).

2. **`kvE_subChain`** — the Cor 5.4 F_i-chain TL formula for the sub-bracket.
   ```
   noncomputable def kvE_subChain … (σ : NormalForm sig k 4) : TemporalPred :=
     (kvE_subBracket charBase charK r σ).fChainPred
   ```
   Carries σ's joint content by nested-Until evaluation point (probes P3/P4). This is the drop-in
   replacement for the flattened per-sub literal.

3. **`kvE2_body`** — the corrected per-sub enriched body: `kvE'_body` with `ptSub σ` / the `t`-anchored
   `pos.map exF` joint literal replaced by `kvE_subChain σ` spliced at the honest bracket position for
   σ's zone. All *non-joint* 13.2 channels (gate, unary families, zones, arrangements) retained
   verbatim (they behaved correctly at k=1; F4 isolated the gap to the per-sub joint channel).

4. **`bracketEndChar_kvE2`** — the corrected carrier, additive alongside `bracketEndChar_kvE'`
   (UNCHANGED), same instantiation pattern; `BracketCarrierCorrectVPrior` applied to it is the k=2
   correctness gate task 321 must pass.

**Demonstrated-closed crux goal (what task 321 discharges, already probed).** The per-sub positive
soundness obligation — previously the unpinnable `w = e 1`, `x = e 2` — is discharged by instantiating
`probe_P4_b3_positions_by_eval_point` at `bf := kvE_subBracket … σ`: from the honest sub-bracket
holding, `kvE_subChain σ` recovers σ's honest witness positions with **no** `e`-to-anchor equation.
The soundness direction feeds `bf.holds` (the honest realization makes the sub-bracket hold) and reads
back the honest positions by evaluation point. No `P.existF 3 σ` rebinding literal appears on the joint
path, so the F4 residual does not arise.

**What task 321 does NOT need** (machine-established here): no structural-identity /
`nf_eval_unique` / `nfPred_correct` hypothesis (Phase 5 / §6, route b2); no provider-side pinning
(barred, v7 Amendment F3); no consumption of `EANegation :1090/:1249`. The only new construction is
`kvE_subBracket`'s σ.2 read; the recovery mechanism is entirely landed, proven `fChain` machinery.

---

## 6. Route b2 — conditional structural-identity micro-check (Phase 5): NOT NEEDED

**Gate check**: does the b3 design (§4/§5) require a structural-identity hypothesis at a per-sub
obligation site? **No.** `probe_P4_b3_positions_by_eval_point` closes with `bf.holds` as its **sole**
hypothesis — no `nf_eval_unique` (NormalForm:245) / `nfPred_correct` (NfToVecEA:69) / type-realization
uniqueness premise appears anywhere in its signature. The absence of such a premise in a *type-checked*
theorem is the machine evidence that b3 needs no structural-identity assist.

The audit's diagnosis (`reports/01` Q2) holds: b2 has no construction-level counterpart in Rabinovich
or Gabbay and would merely relocate the σ.2-exposure problem. Since b3 closes without it, b2 is a
recorded **no-op**; no new plumbing was built speculatively. (Note: the *construction* of
`kvE_subBracket` in §5 reads σ.2 directly from the sub's normal form — a projection, not a derived
identity hypothesis — so even the construction side does not invoke uniqueness.)

---

## 7. Scratch cleanup + landed-asset integrity (Phase 8)

- **Byte-identity**: `git diff` on `NfMultiAnchorBridge.lean` shows **+90 / −0** — a pure append after
  the F4 record (`end` line moved down). Every do-not-edit asset (`kvE_body`, `bracketEndChar_kvE`,
  `kvE'_body`, `kvE_pinDisjunct`, `kvE_exclConj`, `bracketEndChar_kvE'`, F1-F4 records, `ExistProviders`,
  `BracketCarrierCorrectVPrior`) is unchanged. No other landed file touched.
- **Retained probe code**: landed as a clearly-marked NON-CONSUMED verdict section (F1-F4 house style);
  nothing in the codebase references `probe_P1/P3/P4`.
- **Forbidden tactics**: no `simp`/`omega`/`aesop` in any chain-construction body; the only `by omega`
  are `Fin`-index typing obligations in statement signatures (identical to the landed `fChainFrom_step`).
- **Build**: `lake build Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge` completes green
  (1005 jobs); no new sorry on any live path; probes axiom-clean
  (`propext`, `Classical.choice`, `Quot.sound`).

---

## 8. Recommendation

**Proceed to task 321 with route b3** using the §5 design spec. The joint two-anchor content IS
expressible in a Cor 5.4 recursive (nested-bracket) construction — the landed `fChain` machinery
already carries it by evaluation point (P3/P4), so task 321 is a construction task
(`kvE_subBracket` from σ.2 + `kvE_subChain` + corrected body/carrier), not a research task. The
mandatory adversarial gate is the F4 ℤ counterexample (`char[14,16,11,20]` vs honest `char[14,15,10,20]`):
the corrected carrier must DISTINGUISH them, which it does because `kvE_subBracket` reads σ.2 (where the
two subs differ) rather than the shared σ.1 `nfk_projFresh`.

**No escalation required.** No route needed provider-side pinning or `EANegation :1090/:1249`; there is
no blocker finding to surface, and no F5 defect record is warranted (b3 is GO).

### Citations (per G5)

- Rabinovich Def 3.1 (md:61-74) — pinning discipline (b1 diagnosis).
- Rabinovich Prop 3.5 (md:87-94) — single-free-variable nested Until/Since core.
- Rabinovich Cor 5.4 (md:154-157) — `F_{i-1} := α_{i-1} ∧ (β_i Until F_i)` (b3 lead; P3/P4).
- Rabinovich Lemma 5.1 point-insertion split (md:159-173) — sub-bracket endpoint sharing (§5 design).
- Gabbay ch902 (md:17-45) — single-anchor separation, corpus-wide cross-validation of the litmus.
- Landed proven machinery: `BracketFormula.fChainFrom`/`fChainPred` (EANegation:552/567),
  `fChainFrom_step`/`fChainFrom_base` (EANegation:616/580), `bracket_implies_fChainPred` (EANegation:660);
  F4 verdict record (`NfMultiAnchorBridge.lean` :5532-5608).
