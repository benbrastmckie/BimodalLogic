# Blocker Analysis: Task #309 (F4, second-and-last gate NO-GO)

**Parent Task**: #309 - offdiag_two_anchor_fi_chain
**Generated**: 2026-07-06
**Blocker**: Phase 13.35's k=2 correctness gate RE-RUN for `bracketEndChar_kvE'` returned NO-GO
(finding **F4**, carrier-shape defect). The 13.25 uniformization channels do not carry the
discriminating per-sub *joint* content (the sub's inner-witness structure relative to the honest
anchor pair `(w,x)`), and the retained `t`-anchored provider literal structurally cannot supply it
either. This is the pre-committed second-and-LAST gate attempt (v7 Amendment F3's one-round
uniformization budget); autonomous orchestration of 309 halted at this branch per plan v7
:915-926/:954-969 and the orchestrator handoff.

## Root Cause

**Machine evidence (verbatim from the F4 verdict record, `NfMultiAnchorBridge.lean` final section
after :5533, and the 13.35 BLOCKER block, plan v7 :893-996):**

1. **Channel (i) collapse (`rfl`-confirmed, probe A)**: `kvE_pinDisjunct` (:5374) was designed to
   realize Def 3.1's per-point pinning discipline (point type `α_j` + adjacent interval types
   `β_j, β_{j+1}` on BOTH sub-intervals, PDF p.4 md:61-74) but as landed it discards the
   `witnessZone` placement field entirely: `(kvE_pinArrangements σ).map (kvE_pinDisjunct …)` closes
   by `rfl` to `kvE_consistentZones.map (fun _ => ([⟨charK (nfk_projFresh σ)⟩], […]))` — the SAME
   formula for all seven consistent zones. Channel content is a function of `nfk_projFresh σ` (the
   σ.1-level fresh depth-`k` type) ALONE — positionally vacuous, exactly as flagged by the risk
   note left at the end of Phase 13.25 ("the landed channels carry σ.1-level positional content …
   Whether this suffices … is 13.35's machine determination").
2. **The persisting soundness crux (probe B, captured type-mismatch)**: after
   `P.correct 3 σ M h_UZ h_SZ t`, the hypothesis is
   `he : nf_eval_nf M 1 (3+1) (insertEnv e t) σ` with `insertEnv e t = [e 0, e 1, e 2, t]`
   (`ExistProviders.correct`, :4856 — anchor `t` LAST, `u/w/x` positions existentially REBOUND by
   the provider's own `e : Fin 3 → M.carrier`), against the goal
   `nf_eval_nf M 1 (3+1) (Fin.cons x_1 (Fin.cons w (Fin.cons x fun _ ↦ t))) σ`. The funext residual
   is `w = e 1`, `x = e 2` — **unpinnable**: no hypothesis anywhere relates the provider-chosen `e`
   to the honest anchors `w, x`. Channel (i)'s actual deliverable
   (`hpin : ∃ u, x < u ∧ u < w ∧ nf_eval_nf M 0 1 (fun _ => u) (nfk_projFresh σ)`) is a SEPARATE
   existential, structurally unrelated to `e 1 = w`, `e 2 = x`.
3. **Channel (ii) inert on the counterexample**: `kvE_exclConj` (:5387) applies only to negative
   subs and is guarded `if hasPos zs (nfk_projFresh σ) then ⊤ else …` (:5452-5454). In the F3/F4
   counterexample the dishonest positive `σ''` occupies the same fiber (zone `zXW`, fresh type
   `type(14)`) as the honest negatively-marked sub, so the guard collapses to `⊤` — the
   channel-(ii) exclusion never fires against the sub that actually needs excluding.
4. **Provider-independent counterexample (survives under ANY correct depth-1 bundle)**:
   `M = ℤ` (Prior UZ/SZ trivially), `p = {0}`, `r = {13}`, `x = 10`, `t = 20`, dishonest positive
   sub `σ'' := nf_characteristic M 1 4 [14,16,11,20]` (fake anchors sharing only `t`; on-fiber,
   zone `zXW`, fresh type `type(14)`), honest `char [14,15,10,20]` marked false. The extended
   carrier's LHS still HOLDS at `(10,20)` (σ'''s own fake realization plus its vacuous pin slot
   plus the guarded-off exclusion all pass); the statement is FALSE.
5. **Why this is architectural, not a coding slip in isolation**: v7 Amendment F3 (plan v7
   :277-298, held through 13.25/13.35) already establishes that **provider-side pinning is
   circular** — `nf_nvar_exist_all_depths` (the outer recursion) supplies single-anchor converters
   only (finding F-A), so a "pinned-anchor" `ExistProviders` bundle could never be instantiated at
   Phase 14. F4 now shows the complementary half: the carrier-SIDE repair attempted in 13.25 (a
   flattened, per-sub TL literal plus a zone-labelled-but-content-discarding pin slot) *also* fails
   to carry the joint content, because **the only per-sub joint channel left standing
   (`P.existF 3 σ`) is, by construction, a single evaluation-point TL literal whose own private
   existential `e` has no channel back to the bracket's actual witness positions** — and the
   "repair" (channel i) never actually used the zone/interval-type data that would supply that
   channel. Both failure modes trace to the same structural fact: **a formula evaluated at ONE
   point (whether the provider's `t`-literal or a flattened fresh-type pin) cannot itself assert a
   RELATIVE-POSITION identity between two other, independently-bound variables (`w`, `x`) unless
   the formula's own truth is built FROM an actual sub-bracket whose evaluation is anchored at
   those positions** — which is exactly what Rabinovich's Def 3.1 / Cor 5.4 F_i chains do (nested
   bracket recursion, not flattened point-literals) and what the landed `kvE'` design abandoned in
   favor of tractability at the elaboration layer.

## Route Comparison

**Route (a) — provider-side pinning ("pinned-anchor converters")**: BARRED (v7 Amendment F3,
re-confirmed by F4's probe B). A single-anchor TL formula evaluated at one point cannot uniformly
express `e 1 = w`, `e 2 = x`; strengthening `ExistProviders` to carry such a converter is circular
with the two-anchor characteristic under construction (the outer recursion supplies single-anchor
converters only — F-A). **This spawn does NOT re-open route (a).**

**Route (b) — fundamentally different carrier design.** Three candidate sub-routes, in increasing
order of architectural departure, all consistent with the G1-G6 guards and Rabinovich grounding:

1. **(b1) Repair channel (i) to actually consume `witnessZone`** (encode which of the seven
   consistent zones the pin witness occupies AND the two adjacent segment types relative to
   `(x, w, t)`, per Def 3.1's real discipline, using the already-landed non-trivial-segment
   machinery (`A_past`/`A_future`/`bracketBuildLeft/Right`, G3) instead of discarding the zone
   field). **Cheapest to probe; likely still insufficient** — reasoning below — but must be tested
   first since it is the smallest deviation from landed material.
   - *Suspected limitation (to be machine-confirmed, not assumed)*: even a zone-faithful pin
     encodes "σ's OWN witness sits in zone Z", a claim about a FRESH existential unconnected to the
     provider's `e`. It does not, by itself, force `e 1 = w`, `e 2 = x` — those are about the
     provider's rebinding, not about σ's own witness placement. If this suspicion is confirmed
     machine-side, it produces a genuine **F5 candidate finding** (documented, not silently
     dropped) and the analysis moves to (b2)/(b3).
2. **(b2) Structural-identity route**: derive `e 1 = w`, `e 2 = x` from complete-type uniqueness
   rather than from any new formula channel — i.e., use `nf_eval_unique` (NormalForm:245) /
   `nfPred_correct` (NfToVecEA:69) to show that IF `σ` is (by the outer recursion's own
   construction) the complete type realized by the actual honest quadruple `[u,w,x,t]`, THEN any
   other realizing environment (including the provider's `e`) must agree with it at each position,
   collapsing the residual. This requires establishing, as a SEPARATE hypothesis available at the
   per-sub obligation site, that `σ`'s realizing witness IS positionally the honest one (not merely
   "some environment realizes σ") — plausibly already implicit in how `qnf.2 σ = true` subs are
   selected upstream (the zone/arrangement machinery), but this has NOT yet been checked against
   the actual binder shapes at the 13.25/13.35 site and is exactly what Task 0 (below) must
   machine-probe.
3. **(b3) Nested bracket / F_i-chain recursion for positive interior subs**: instead of flattening
   an interior positive sub's content into a single TL provider literal (`P.existF 3 σ` at `t`),
   recurse Rabinovich's actual construction (Cor 5.4, md:154-157: `F_n := α_n`,
   `F_{i-1} := α_{i-1} ∧ (β_i Until F_i)`) one level down: give the sub's own witness `u` an
   EXPLICIT two-anchor sub-bracket relative to the CURRENT bracket's real interval decomposition
   (using the landed `A_past`/`A_future`/`bracketBuildLeft/Right`/`VVecEA2` machinery, generalized
   rather than reused verbatim), so that the TL evaluation at the actual honest point yields the
   honest positions directly — the joint content rides the SAME mechanism that already lets
   `A_past`/`A_future` see `(x,t)` (G3), rather than an opaque per-sub existential. This is the
   largest departure and the one most literally licensed by Prop 4.2/Lemma 5.1/5.3 + Cor 5.4
   (md:100-157), which is exactly a NESTED negation-closure/INF-splitting construction, not a
   flattened point-literal.

**Recommendation**: spawn a research/design task (Task 0) that tests (b1) first as a cheap,
falsifiable probe, and — on the expected (b1) refutation — evaluates (b2) and (b3) with a
MACHINE-CHECKED minimal probe (not full carrier machinery) before committing to a full
implementation. This avoids a third mechanical "just add another channel" round (the exact failure
mode of F3 -> F4) and instead forces an explicit, literature-grounded architectural decision, per
Rabinovich's own Prop 4.2 / Lemma 5.1 / Lemma 5.3 / Cor 5.4 (md:100-157) — the negation-closure
proof is ITSELF a nested, nowhere-flattened nowhere-single-point construction, which is the
strongest textual signal that (b3), or the identity route (b2) as a lighter-weight stand-in for it,
is the faithful target rather than another point-literal patch.

## Proposed New Tasks

### New Task 1: De-risk the joint-pinning route for the k>=2 carrier gate (F4 follow-up)
- **Effort**: 6-10 hours
- **Task Type**: lean4
- **Rationale**: F4 is the second consecutive NO-GO from mechanically adding another carrier
  channel without first confirming the channel can structurally carry the required content. Before
  committing to a full carrier rebuild (Task 2), a dedicated design task must (i) machine-test
  route (b1) (repair `kvE_pinDisjunct` to actually consume `witnessZone` + adjacent segment types),
  (ii) if refuted, machine-test route (b2) (the `nf_eval_unique`/`nfPred_correct` structural-identity
  route) and route (b3) (nested F_i-chain recursion for positive interior subs) via MINIMAL
  standalone probes (not full carrier surgery), and (iii) produce a concrete, named design spec
  (exact new definitions, signatures, and a demonstrated-closed or demonstrated-impossible crux
  goal) for whichever route is viable — or a new F5 defect record with counterexample if NONE of
  (b1)/(b2)/(b3) close in-budget, escalating again rather than silently absorbing.
- **Depends on**: None
- **File scope**: `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge.lean` (read +
  scratch probes only — no landed asset is edited; any probe code is either discarded or landed as
  a clearly-marked, non-consumed scratch/verdict addition, mirroring the F1-F4 house style)

### New Task 2: Implement the corrected k>=2 carrier and close the correctness gate (F4 resolution)
- **Effort**: 10-16 hours
- **Task Type**: lean4
- **Rationale**: Once Task 1 has identified and de-risked a viable route with a machine-checked
  probe, this task builds the FULL corrected carrier extension (or nested-bracket construction) and
  re-runs the k=2 `BracketCarrierCorrectVPrior` gate to a GO verdict — the deliverable that
  unblocks task 309's Phase 13.4 (general-k correctness) and Phase 14 (hook rewire,
  `KampPrior.lean:351`).
- **Depends on**: New Task 1, because Task 1's probe determines WHICH of (b1)/(b2)/(b3) is
  viable, what its exact signatures/deliverable names are, and what its closed (or provenly
  unclosable) crux goal looks like — Task 2 cannot be scoped or dispatched without that decision;
  building the wrong route would repeat the F3->F4 mechanical-iteration failure this spawn exists
  to stop.
- **File scope**: `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge.lean`

## Dependency Reasoning

- **Task 2 depends on Task 1**: Task 1's deliverable is not merely "permission to proceed" but the
  SPECIFIC technical content Task 2 needs to be well-scoped: which of (b1)/(b2)/(b3) closes the
  crux goal, the exact new definition names/signatures the design implies (e.g. whether the
  carrier needs a genuinely nested bracket structure vs. an additional structural-identity lemma
  threaded through the existing per-sub obligation site), and the minimal probe's proof sketch to
  transcribe at full scale. Without this, Task 2 would have to re-derive the same design decision
  mid-implementation, risking exactly the "mechanical round" pattern (F1 -> F2 -> F3 -> F4) this
  spawn is meant to break.
- **Both tasks touch the same file** (`NfMultiAnchorBridge.lean`): this is already covered by the
  explicit Task-2-depends-on-Task-1 edge above (not an additional auto-added dependency — the
  overlap is expected and intentional, since Task 2 builds on Task 1's exact probe artifacts in the
  same file region after the F4 verdict record).

## Constraints Carried Forward (binding on both new tasks; do not re-litigate)

- **Guards G1-G6 + Corrected Anchor-Cap** (plan v7 :230-260): no arity-1 collapse (G1); no
  projection-based `VecEA2`/third-free-anchor tower (G2); no trivial-top segment on off-diagonal
  arms (G3); `w` stays a bracket WITNESS, anchor set `{x,t}` fixed at 2 (G4); Cor 5.4/Prop 3.5
  `F_i` chains step-by-step, cite Rabinovich at every chain step, no `simp`/`omega`/`aesop`
  shortcuts (G5); carrier is the two-anchor FIXED-endpoint bracket, `VVecEA2` witness-growing
  codomain, never a third anchor (G6-as-amended).
- **v7 Amendment F3 still binding**: do NOT attempt provider-side pinning / pinned-anchor
  converters (route (a), rejected — circular with the outer recursion's single-anchor-only
  converters, F-A).
- **Do NOT consume `EANegation :1090/:1249`** (uniform-backward sorries) — needing them is itself
  a blocker finding to record and escalate, never a silent absorption (unchanged from v7 Amendment
  F3).
- **Preserve byte-identical**: `bracketEndChar_kv`/`kvE_body`/`bracketEndChar_kvE` (13.2, F1/F2
  exhibits), `bracketEndChar_kvE'`/`kvE'_body`/`kvE_pinDisjunct`/`kvE_exclConj` (13.25, the F4
  exhibit), the F1/F2/F3/F4 verdict records, `ExistProviders`/`BracketCarrierCorrectVPrior` (13.1),
  all task-310/311 material. New material is ADDITIVE (new names) alongside these, following the
  R2/F1-F4 house style — never an edit of a landed asset.
- **Consume, do NOT rebuild** (CONSUME-DO-NOT-REBUILD asset list, task 309's own description /
  plan v7 Preserved-Assets table, plan v7 :142-197): the E[Σ]-fold engine
  (`nf_quant_layer_fold_iff` NfEFold:391, `nf_eval_depth1_fold_iff` NfMultiAnchorBridge:5187,
  `nf0_split_assemble` NfEFold:235); the k1v proof kit (:2028-2825) and direction templates
  (:2325/:2966); `nf_eval_unique` (NormalForm:245) / `nfPred_correct` (NfToVecEA:69);
  `A_past`/`A_future`/`_correct` (NfZoneFlattenNavigable:335/:386);
  `bracketBuildLeft/Right`/`_correct` (VecEATranslation) — valid ONLY at fixed-endpoint literals;
  `VVecEA2`/`bracketFromLists`/`existsBounded_right` (VecEAFormula:271, NfMultiAnchorBridge:1883,
  VecEAClosure:265); `fChainFrom`/`fChainPred` (EANegation:552/:567, Cor 5.4 candidate shapes);
  the EANegationClosure forward stack (:401/:492/:646/:720) + `neg_orderedPointsExist_is_vbracket`
  (EANegation:347) — PROOF-SIDE ONLY, per-model direction obligations; `prior_hasAttainedINF`
  (PriorINF:224) + `HasAttainedINF` (PriorINF:202); the F1/F2/F3/F4 verdict records
  (NfMultiAnchorBridge.lean, read-only design inputs — the F4 record's crux goal is the mandatory
  adversarial test case both new tasks must re-verify still fails, or is genuinely closed, against
  any new construction).
- **Literature grounding (Rabinovich 2014, Section 5)**: Def 3.1 (p.4, md:61-74) — every
  existentially chosen point pinned by point type `α_j` AND adjacent interval types `β_j`,
  `β_{j+1}`; Lemma 3.2(2) (p.4, md:76-79) — anchor cap ≤2; Prop 4.2 (p.6, md:100-101) — negation
  closure equivalent to a disjunction of exists-forall formulas; Lemma 5.1 (md:134-135) — the main
  technical negation lemma, fixed endpoint/interval types; Lemma 5.3 (md:137-152) — base-case INF
  splitting via Dedekind completeness (`r_0 = inf{...}`, definable by a V-exists-forall formula);
  Cor 5.4 (md:154-157) — `F_n := α_n`, `F_{i-1} := α_{i-1} ∧ (β_i Until F_i)`, the F_i chain IS the
  nested (non-flattened) mechanism the literature actually uses. Both new tasks MUST cite these
  per-step (G5 discipline), and route (b3) in particular should be read as "build what Cor 5.4
  actually builds" rather than a novel invention.

## After Completion

Once New Task 1 and New Task 2 are complete, resume the parent task with `/implement 309` (or
`/revise 309` first if the plan needs a v8 re-pointing to the new deliverable names, following the
same re-pointing pattern v6 -> v7 used for the 13.25/13.35 insertion).

The blocker will be resolved because: New Task 2 will have landed a machine-checked GO verdict for
the k=2 `BracketCarrierCorrectVPrior` correctness gate against a carrier design confirmed (by New
Task 1's probe) to actually carry the discriminating per-sub joint content — closing exactly the
gap F4 identified (the provider-independent ℤ counterexample must fail against the new
construction) — which is the prerequisite Phase 13.4 (general-k correctness) and Phase 14 (hook
rewire, discharging `KampPrior.lean:351`) were gated on.
