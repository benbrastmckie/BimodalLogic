Thanks. The rule statements in `TemporalComposition.lean` match their docstrings: the unfold rules and `nextKeep`/`prevKeep` carry `ZTime ≤ fc`, and fold, intro, keep and leads-to are frame-polymorphic. `keeping` is done correctly: it accepts only `G P` on future steps and `H P` on past steps, carries `G P` (not `P`) by temporal 4, and takes its direction from the step, so a wrong-direction or current-only fact is rejected. Whole-context reflection maps every entry at the same frame class. No `sorry`, axiom or `native_decide`, and no layering violation.

Requesting changes on the points below. The rebase and `specs/` requests on #7 apply here too, and so does its section "Where the direction is written down": the three records under `records/`, how they are revised, and the note that `specs/ROADMAP.md` is generated and numbers its milestones differently. Milestone numbers below are those of `records/proof-mode.md`.

**Rebase and CI**
- Once #7 is merged, please rebase onto `main` and confirm CI is green before this is reviewed again.

**Where this PR sits**

This PR does part of two planned milestones and touches three more. "Where the work sits" in `records/proof-mode-architecture.md` already has a row for each part, marked contributed.

| Part of this PR | Record milestone | Open work it meets | State against the done-when |
|---|---|---|---|
| Until and Since introduction, `futureKeep`, `keeping` | M4, Linear-time rules | `proof_mode_until_since_intro_unfold_induction` | introduction met; monotonicity open |
| One-step unfolding at ZTime, folding at every class, `nextKeep` | M4 | same | met, and better than the plan's single equivalence |
| `linduction` (backward induction) | M4 | same | a different rule from the one planned; the generalizing induction rule stays open |
| Linearity case split | M4 | `proof_mode_linearity_case_tactic` | not in this PR; stays as planned |
| `ltime_reflect`, `reflectContext` | none | none | new; a Temporal rule with no milestone |
| `leadsToConsequence`, `leadsToTrans`, `progressCases` | M10, Safety and liveness library | `proof_mode_leads_to_invariance_library` | strict form only; the present-inclusive definition is open |
| `Formula.inclusiveUntil` / `inclusiveSince`, `ltemporal_dual view` | M16, Views tier | `proof_mode_views_tier` | views placed in a derivation elaborator |
| TM rule plus TM⁺ copy through `ofTMSubst` | M8, One interface | `proof_mode_abstract_frontend_interface` | adds to the copies M8 removes |
| Frame gate at Dense and RTime | M7, Frame coverage | `proof_mode_dense_and_real_time_rules` | not in this PR; the gate helper asked for below is what M7 will reuse |

What the PR should revise, in the same change:
- `records/proof-mode.md`: M4's done-when, to say unfolding at ZTime with folding at every class and to state which induction rule exists; and the figures under "Where it stands" (tactic count, module and line counts, `throwError` sites, negative tests).
- `records/proof-mode-architecture.md`: the rows of "Where the work sits" for what lands.
- `docs/user-guide/`: one page per family for what now exists. What is implemented is then cut from the record down to a pointer, as `records/README.md` asks.

**Order against the gates**

- M4 has a hard dependency on gate one (M3) with a GO verdict: the plan holds linear-time work until the first sweep shows the mode beats the reference proofs on its first rule set. This PR arrives before that measurement. I am willing to take the rules, and two things follow.
- Gate one's selection is fixed to exercise the rules of M1 and M2: scopes and leaf closing, on entries from the `Boolean` and `ModalBoolean` fragments and the Perpetuity section of `ModalTemporalBoolean`. Of the rules in this PR, gate-one scripts may use two: `G`/`H` carrying (`keeping`), as rows of M1's carrying table, and whole-judgment time reflection (`ltime_reflect`). Each may be used only once it is adopted into M1 before the selection is fixed. Until and Since introduction, folding and unfolding, `nextKeep`, `linduction` and the leads-to rules are not used at gate one.
- The other rules are measured at gate two (M5, `proof_mode_reprove_temporal_slice`): a selection from `TemporalBoolean` and the rest of `ModalTemporalBoolean`, at Base and at ZTime, with at least four entries each from `TemporalDerived`, `ConnectDerived` and `LinearityDerived` and `tempLinearity` among them. A RE-PLAN at gate one holds M4 and everything after it until the records are revised, and that would include what remains open here.

**Changes to existing tactics**
- `lapply` (`Basic.lean:59-104`) changes for existing scripts in four ways: goals are now ordered proof parameters, premises, then data parameters (it was parameters, then premises); data parameters are natural metavariables, so proving a premise can fix them silently; holes older than the call are no longer returned as goals; and an unresolved instance is ignored by `discard <| Term.synthesizeInstMVarCore` (`:80`) and surfaces later as a stray data goal. I am fine with the reordering and the unification. Please make an unresolved instance an error at the `lapply`, document the goal order in the guide, and add a test that pins it.
- `lstep` / `linvariant` now reject a concretely false frame class at once (`Discrete.lean:41-52`). That is an improvement; please add a test asserting the message.
- `scopedGuarantees` (`Modal.lean:88`) now runs first for `ltemporal_cases`, `ladvance`, `lstep`, modal introduction and possibility cases, and its message prints the internal operator name ("matching allFuture scope"). Please print the user-facing operator. The older checks at `Modal.lean:105` and `Temporal.lean:238` are unreachable on those paths now; remove them.
- `"keeping"` is declared as a plain atom (`Discrete.lean:140`, `Temporal.lean:760`), so it becomes a reserved token wherever these files are imported. Please make it a non-reserved keyword (`&"keeping"`).
- There are two gate policies: `lstep` / `linvariant future` ignore a local `ZTime ≤ fc` hypothesis and leave a goal, while the new routes reuse it. Please make the original gate reuse a local certificate too.

**Error messages on the new routes**
- `integerTimeGate` and `applyTemporalProofCore` (`Temporal.lean:172-201`) reuse `resolveRuleParameters` from rewriting, so `luntil unfold` at `Dense` reports "incompatible concrete frame classes in rewrite rule" and other failures report "rewrite premise has undetermined parameters". These need their own messages naming the temporal tactic.
- `timeReflect` (`Temporal.lean:657`) has no mismatch error of its own and would surface a raw `mkAppOptM` failure.
- `ltime_reflect using t` with a `t` that is not a derivation silently becomes plain `lapply` with no reflection (`Temporal.lean:669-671`). It should fail.
- `linvariant using` and `linduction using` are the same function (`Discrete.lean:129`), and `luntil using`, `lsince using` and `lprogress using` are `lapply` plus a goal-shape check. That is fine, but please say so in the guide so nobody reads them as checking more than they do.
- `operatorArgs?` unifies with fresh metavariables, so a kept term whose formula is still an unassigned metavariable would be instantiated to `G ?x` without comment. Please reject an undetermined formula in `keeping`.

**Negative tests**
- The layer adds 31 `throwError` lines (net 26) and the tests add 4 `fail_if_success` and no `#guard_msgs`. Please assert each reachable message with `#guard_msgs`, the standard M6a sets.

**Coverage**
- The architecture record asks each family for its rules in both polarities and both time directions; a module with the future rule and no past mirror is incomplete.
- No test of any kind for: every `lsince` form, `lstep … keeping`, `ltemporal_intro … keeping`, `linduction future/past`, `lprogress consequence/trans/using`, `luntil intro`, `ltemporal_dual view` and its `←` fold, and `ltime_reflect using … as`.
- TM⁺ has one new test (`ltime_reflect`) and the past direction has one (`ltemporal_cases`).
- The ZTime gate is tested with an abstract class plus a local certificate and at concrete `Dense`. Add abstract with no certificate (goal left) and concrete `ZTime`.
- `keeping` rejection covers a bare current fact only. Add a `G` fact on a past step and an `H` fact on a future step.

**Placement and naming**
- `PlusLanguage/TemporalViews.lean:128-175` defines TM-side `Formula.inclusiveUntil` / `inclusiveSince` and the `Formula.*_expand` lemmas. Those belong under `FormalSystem/Syntax/`.
- `inclusiveUntilIff` (`TemporalComposition.lean:598-632`) is `identity ∧ identity`: a definitional unfolding presented as an equivalence. Please either drop it or document it as the unfolding it is.
- The `Theorems/ProofMode/README.md` row for `TemporalComposition.lean` has an empty description.

**Draft history in deliverables**
- `TemporalComposition.lean:13,15` uses the plan label "(P3)".
- `Discrete.lean:24,30-33,40` says "unchanged", "original", "now rejected"; `Temporal.lean:33,38,53,770,857` says "(unchanged)" and "original".
- `docs/user-guide/derivation-proof-mode.md` says "legacy", "pre-existing" and "New integer-time rules". Please describe the tactics as they are; CONTRIBUTING.md, section 3, has the rule.

**The four places this differs from the plan**

Please say in the PR description which reading you intend on each, and propose the edit to the milestone's done-when. I will revise the open work against what lands.
- **Unfolding.** M4 asked for one ZTime equivalence. You split it into unfolding at ZTime and folding at every frame class, which is better and I will adopt it.
- **Induction.** M4 asks for an Until/Since induction rule of which `forwardInvariantRule` is an instance, with `linvariant` re-expressed through it. `linduction` exposes backward induction (`G(Gφ → φ)` and `F(Gφ)` give `Gφ`), which the library already had as `futureBackwardInduction`. That is useful, but it is a different rule: `forwardInvariantRule` is not an instance of it, so it does not meet the done-when, and the generalizing rule is still open. M4 of `records/proof-mode.md` gives a proposed statement for it, at `ZTime`, with guard `g`, event `e` (Lean `Formula.untl g e`), strict operators and `X φ := untl ⊥ φ`:

  ```
  ⊢[ZTime] (X(e ∨ (g ∧ C)) → C) → G(X(e ∨ (g ∧ C)) → C) → (g U e → C)
  ```

  The Since rule is its mirror by time reflection. Putting `g := ⊤`, `e := ¬A` and `C := ¬A` recovers `forwardInvariantRule` up to argument order. The statement is proposed and not yet derived: it is argued by hand on ℤ and is not machine-checked, and deriving it is the work of `proof_mode_until_since_intro_unfold_induction`. If you see a flaw in it or have a better statement, that is the most useful thing you could add to the record. The induction rule's dependency on the linearity case split is sequencing only: the pure rule sits at layer 2 and cannot import a tactic, and what it takes of linearity is a theorem (`Axiom.linear_until`, `FormalSystem/Theorems/LinearityDerived.lean`), never the case-split tactic.
- **Leads-to.** Leads-to is a named abbreviation with present-inclusive operators, and that is the form the M10 rules are stated for: the strict `G(A → F B)` says nothing about the present, so reflexivity and introduction from an implication fail for it. `leadsToConsequence`, `leadsToTrans` and `progressCases` are on the strict form. They stay as the layer beneath the present-inclusive definition, and the inclusive rules are proved from them; please label them as the strict layer. Strict as the base has merits, since it matches the primitive operators and needs no unfolding of a definition, and it is rejected on those two rules.
- **Linearity.** Not covered here; the three-way case split stays as planned.

**Design: file rules by operator family**
- `TemporalComposition.lean` holds several different things for two languages in one file. The architecture record has one Temporal family, future and past together, with Boolean interactions and frame classes filed apart. Please split the file along its tables: Until and Since introduction, `futureKeep` and `reflectContext` in `Temporal`; folding, unfolding and `nextKeep` in `TemporalZTime`; the leads-to rules in `TemporalBoolean`, since their statements are implications under a temporal operator. A pure family module has no implication in any statement, and interactions with Boolean are their own modules, so that a later language extension adds modules without changing these. The same names apply to the tactic modules, the test files and the guide pages.
- The inclusive Until and Since definitions and their `rfl` lemmas are views: they belong in the views tier (M16) as rows of its view table, and `ltemporal_dual view` is a views tactic. The tier has one pair of tactics, `lunfold` and `lfold`, each taking a view name; the pair comes with #7, and these views are reached through it. Please move them out of the temporal elaborator. Principle 1 of the record is that no tactic name serves two tiers.
- A question on keywords. `luntil unfold` and `luntil fold` are derivation steps that use the ZTime axioms, where `lunfold` and `lfold` name views. The tactic heads differ, so principle 1 is met to the letter, but one word then names a view and a logical step. My preference is to rename the keywords `expand` and `contract`, so that fold and unfold belong to the views tier alone. This is a matter of taste and is not settled; what is your view?
- Each rule appears twice, once for TM and once through `ofTMSubst` for TM⁺. Stating the rules over the `Kit`-style interface from #7 would give both from one proof, which is what M8 is for.

**Design: fewer tactic forms**
- `luntil using`, `lsince using`, `lprogress using`, `linvariant using` and `linduction using` are each `lapply` plus a check on the goal's shape. Please make this one form, an `lapply` that takes an optional expected shape, so that five names do not suggest five behaviours.
- `keeping` carries `G` and `H` facts. The scope work of M1 carries `□` and `◇` facts into a `□` scope by 4 and 5 (`proof_mode_s5_aware_box_scopes`), and `□` facts into `G` and `H` scopes by MF and TF (`proof_mode_cross_modal_scopes_mf_tf`), which is the same operation with a different carrying rule. The architecture record already says one carrying table is shared between them. Please build `keeping` as one mechanism over a table of carrying rules (which fact shape may enter which scope, by which rule), so those cases are additions to the table.
- One frame-gate helper for `lstep`, `linvariant` and the new routes, with one policy on local certificates and its own error messages, in place of reusing rewriting's parameter resolution. M7 needs the same helper at Dense and RTime.

**Purpose and measure**
- As on #7: the measure is the theorem library, and a capability earns its place by an entry it makes possible or shorter. Please name the existing proofs these rules shorten. `TemporalDerived`, `ConnectDerived` and `LinearityDerived` are where gate two draws its `TemporalBoolean` entries, so a few declarations from there re-proved with these tactics would say more than the acceptance fixtures do, and would be the start of gate two's selection.
