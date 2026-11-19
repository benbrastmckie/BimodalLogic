# Final review of the integrated plan (Opus 5.5)

**Scope.** No tool calls were made in this review. Source claims rely on the brief's audit and on the earlier reviews. Labels used throughout:
- **(a)** actual defect
- **(b)** missing specification
- **(c)** legitimately deferred theorem or prototype
- **(d)** preference

## Verdict

**There is no soundness or design blocker.** I checked each route in the plan against strictness, gates and direction. Every route builds checked evidence, and none goes from semantic results back to native derivations.

**The plan is ready to start P0 now.** P1–P2 can start once P0 passes and corrections 1–3 below are written into the plan. P3–P5 depend on ordinary theorem obligations (c), which the plan correctly does not claim as proved.

**Status of the original findings:**
- My findings F1–F4, F7 and F10 are **resolved**.
- F5, F6 and F8 are **partly resolved**.
- F9 is resolved: Plus has no dual wrappers, the Plus time-shift is existing source, and both StateLocal names are listed.
- Codex's findings B1–B8 are **resolved**: layering, the completeness rationale, signed role, uniform `as h'`, instantiated decrease, `box_global`, goal and fact transport with `keeping`, and test economy.

## Checks requested

**Signed demand composition: correct.**
- With `transfer` as a closed object implication and `demandMono` closed, composition instantiates each step at the previous output's (antecedent, consequent). The flip handles the swap.
- I traced G A = ¬U⊤¬A (flip, event G, flip). It yields `G(A⟶B) ⟶ (GA ⟶ GB)` at even parity. □¬A at odd parity needs the leaf B→A for a fact, which matches the role/polarity table.
- The goal and fact rows are right: a positive goal uses leaf B→A, so the new goal proves the old one.
- **(b)** The composite theorem's type is stated only in prose. P0 should fix it as:
  `pathTransfer p A B : ⊢ W_p(A⟶B) ⟶ (if odd p then plug p B ⟶ plug p A else plug p A ⟶ plug p B)`.

**Native Plus path transfer: the strategy is correct, but there is a typing gap. (b), significant.**
- `ofTMSubst` transfers closed *formulas*: `transfer` and the K schemas.
- `demandMono` is a *metalevel function on derivations*, so `ofTMSubst` cannot supply its Plus instance. The Plus instance must be built from Plus necessitation constructors, using the same `(op, nec, dist)` shape that `liftContext` already uses.
- The X route has no Base X-necessitation. Its `demandMono` is TN followed by the transferred `untilMonoEvent` at guard ⊥.
- `Step fc` as written types only TM `Derivation`, which contradicts "do not duplicate the planner."

**Temporal strictness and gates: correct.**
- The four unfolding directions and their gates match the audit, including the misleading Since name.
- Inclusive U is `e ∨ (g ∧ U g e)`, which is right for an open interval.
- Integer invariance keeps the current-step premise.
- `weakUntil e g = U g e ∨ G g` matches the literal definition.
- Dense forward unfolding is rejected at a decidable tag.
- **(b)** Defaults are inconsistent. §3.4 says `lrewrite` fails atomically on a missing frame proof; §5.2 says `luntil unfold` exposes it. Both are defensible, since `luntil unfold` follows the existing `lstep` convention. State the rule once: the `lstep` family exposes; `lrewrite` fails unless `obligations := expose`.

**Semantic Next cover: correct.**
- U ⊥ A at t holds iff there is s > t with A at s and (t,s) empty, which is exactly t ⋖ s. This uses no SuccOrder and no ZTime.
- It relies on histories being total over the carrier, as the audit states (WorldHistory is a subtype of total PartialHistory).
- The lemma needs only `UntlClause` and `BotClause`, plus inertness of `e` across `untl`.
- **(c)** It is not in P0; P4 is where it is needed, which is fine.

**Rank progress theorem: correct as stated.** Use well-founded induction on `rank` (via InvImage) for `P s := I s → Q s ∨ ∃u>s, Q u`.
- If the step gives `Q u`, then u > s and we are done.
- Otherwise the rank descends; the IH at u gives Q u or some v > u > s.

The strict-eventuality caveat is right.
- **(d)** "Descent only on events, without eventual events" is hard to parse. Rephrase it as: "the hypothesis asserts the existence of a later point; a rank that decreases only *if* a step occurs proves nothing."

**Layer boundary: mostly fixed.**
- **(b)** `PlusLanguage/` mixes `Derivation` and `PlusTruth`. `Semantics/ProofModeRules.lean` must therefore stay generic over `TruthClauses` and must not import `PlusLanguage`. Any Plus-specific semantic wrapper belongs in `PlusLanguage` (semantic side) or in `Automation`.
- **(b)** "Pure native rules stay at layer 2" is unverified. Confirm it in the P0 inventory.

**Transport directions: the typing is correct.**
- Fact: `R p q → At p → At q`. Goal: `R p q → At q → At p`.
- **(b)** The reuse table does not record whether each row is an Iff or one-way. My F6 asked for this. Add a direction column to the inventory, because the "fact-only cannot move goal" test depends on knowing which rows are one-way.

**Repeated advance: the mechanism is correct; the acceptance case is underspecified. (b)**
- G4 applied before scope entry leaves G P in the body. The semantic counterpart uses transitivity of `<`.
- Strictness hazard: G(A→F B) says nothing at the present point. If the test starts from A *now* rather than F A, it is unprovable, and an implementer might "fix" that unsoundly.
- Pin the scenario as `[F A, G(A→F B), G(B→F C)] ⊢ F C` at Base, with a semantic twin.
- Add the negative case `[A, G(A→F B)] ⊢ F B`, refused because strict G omits now.

## Score table

| Cat | Score | Reasons and deductions |
|---|---:|---|
| C ×3 | **8.5** | **Strengths:** signed composition, cover clause, rank theorem, gates and reflection are all correct. The completeness rationale is now right. Base regularity is handled. **Deductions:** closed-formula forms of `nextConsequence`/`prevConsequence`/`untilMono*` are unverified (`prevConsequence` may not exist; `untilMonoEvent` at guard ⊥ suffices); the layer-2 claim and PlusLanguage placement are unverified; the transport rows have no direction column. |
| P ×2.5 | **8.0** | **Strengths:** typed steps, role/polarity table, stepwise Plus, `using` capture, uniform `as h'`, `keeping`, goal reconstruction. **Deductions:** the Plus `demandMono` gap; the first-release set of scope conversions (evidence head → demand word) is not enumerated; projecting `W(A↔B)` to `W(A→B)` via composed `demandMono` is not stated; the S2 initial state is unspecified. |
| R ×2 | **8.5** | **Strengths:** the reuse map is concrete; `TruthCorr`/`HistMorphism`/`box_global`/`stab_state_only` are reused; there is no new framework and no cache; extension points are left open. **Deductions:** `Step` is not language-parametric; the semantic module could import upward through PlusLanguage. |
| A ×1.5 | **8.0** | **Strengths:** the counters, rollback, skip-on-missing-gate, actual-instance decrease and explicit-only expansion are well specified. **Deductions:** the formula measure is unnamed; it is unclear whether decrease *chooses* the orientation of an equivalence or *guards* a registered one (choosing is nondeterministic across instances; it should guard); R4 says cyclic rules "stop with rollback", but under a decrease guard they are skipped, leading to no change and therefore failure. |
| I ×1 | **8.0** | **Strengths:** P0 go/no-go gates, an 8-family suite, and a reasonable build policy. **Deductions:** P0 does not verify every table row's closed transfer; the completeness-import guard I recommended was dropped; the composite signature is in prose only. |

**Weighted total: 3·8.5 + 2.5·8.0 + 2·8.5 + 1.5·8.0 + 8.0 = 25.5 + 20 + 17 + 12 + 8 = 82.5 / 100.**

This is a review judgment, not a certificate. It is substantially above both initial grades because the integration closed real gaps, not because the two designs converged.

## Changes required before accepting the plan

1. **Make the Step kernel language-parametric. (b, required)**
   - Parameterize `Step` by the judgment family (TM/Plus) and its object implication.
   - Plus instances: `transfer` comes from `ofTMSubst` of an atomic schema instance; `demandMono` comes from Plus necessitation plus the transferred K schema. For X, use TN followed by `untilMonoEvent`.
   - Add a **P0 gate**: `ofTMSubst` of the schema at atoms reduces, by `rfl` or `simp`, to the Plus `wrap` of the Plus arguments.

2. **Enumerate the P1 scope conversions. (b, required)**
   Each pair gets its own theorem:
   - □ → {□, G, H, ⊡} (single letter);
   - G → Gᵏ and H → Hᵏ (temporal 4);
   - X/Y exact matches only.

   Mixed words such as □→GH and □→⊡G wait for the general boxed-word theorem (c). Add projection of a scoped equivalence under W via composed `demandMono`.

3. **Pin the S2 acceptance scenario. (b, required)**
   - Success: `[F A, G(A→F B), G(B→F C)] ⊢ F C`, native at Base, with its semantic twin.
   - Refusal: `[A, G(A→F B)] ⊢ F B`.

4. **Extend the P0 inventory. (b)**
   - Confirm a closed-formula transfer exists for **every** row of the §3.2 table. Use `untilMonoEvent`/`sinceMonoEvent` at guard ⊥ in place of `nextConsequence`/`prevConsequence` if those are only contextual rules.
   - Record the direction (Iff or one-way) for each transport row.
   - Confirm the layer numbers and the PlusLanguage split; keep `Semantics/ProofModeRules.lean` generic over `TruthClauses`.

5. **Restore a cheap one-way guard. (b, small)**
   Add `assert_not_exists` on the named completeness theorems in the proof-mode root modules, or extend the existing layer gate. Do not use `Classical.choice`, which is a core axiom and cannot be asserted absent. No new framework is needed.

6. **Fix the `lsimp` contract. (b)**
   - Name the measure, e.g. primitive constructor count after view preparation.
   - Equivalences carry a *registered* orientation, and the decrease check is a guard.
   - Restate the R4 outcome: a non-decreasing rule is skipped, leading to no change and a reported failure; budget exhaustion leads to rollback.

7. **Unify obligation defaults. (b, small)**
   Document a single rule: frame/evidence obligations are exposed by the `lstep`/`luntil` family, and by `lrewrite` only when `obligations := expose`.

8. **Reword the rank caveat. (d)**
   Rephrase the occurrence sentence as suggested under the rank progress check above.

## Readiness after P0

The plan correctly treats signed composition, mixed Plus paths, Base conditional Next, Base Since fold and pointed soundness as **prototypes still to be type-checked**, not as established facts.

If P0 passes, together with the additions in items 1 and 4, then P1–P2 are implementation-ready. P3–P5 rest on standard, clearly scoped obligations:
- the contextual TM reflection lemma, by induction on the derivation (MN/TN/TR cases close via `pastNecessitation` and involution);
- `next_iff`/`prev_iff`;
- the rank theorem;
- G-persistence.

None of these should be described as proved until they are.