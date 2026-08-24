import FormalSystem.Boneyard.Kamp.KampWeakCanonical.VecEA_m
import FormalSystem.Boneyard.Kamp.KampWeakCanonical.EAVecNegationClosure
import FormalSystem.Metalogic.WeakCanonical.Separation.KampTranslation

/-!
ARCHIVED (Boneyard) — never compiled. Archived material; see the Boneyard README inventory.

# Phase 4b/4c: Proposition 4.3 — every monadic FO formula is V-EA equivalent

Rabinovich (2014), Proposition 4.3: every monadic first-order formula over a
linear order is equivalent (on strictly increasing environments) to a
`VVecEA_m` formula. The proof is a *structural* induction on the FO formula
(no NF-depth parameter, no arity tower):

- **atom**: a single endpoint predicate at the relevant free variable, built
  from `atom_literal` (requires `atomMap` surjective on the signature).
- **lt**: decided by the indices alone — under `StrictMono env`,
  `env i < env j ↔ i < j`. So the case is the constant-`⊤` or constant-`⊥`
  `VVecEA_m`.
- **and**: `VVecEA_m.conj` (Lemma 3.2(1)).
- **or** / disjunction: `VVecEA_m.disj`.
- **not**: the arbitrary-arity negation closure `neg_vec_ea_m` (Phase 4a),
  in its model-dependent existential form (Phase 4c).
- **ex**: existential closure (Lemma 3.4). The De Bruijn `.ex` binder prepends
  the witness at index 0 with *no order constraint*, whereas `existClosure`
  absorbs the rightmost free variable. The honest gap between these is Lemma 3.4
  proper (split the witness over the m+1 order positions); see the BLOCKER note
  on `prop43_correct`'s `.ex` case.

This file is **off the live import path** (imported by nothing live), matching
the Phase 4 plan: faithful assets land off-path before the Phase 5 `:391` rewire.

## References
- Rabinovich 2014, "A Proof of Kamp's Theorem", Proposition 4.3, Lemma 3.2, Lemma 3.4.
-/

#exit

namespace FormalSystem.Metalogic.WeakCanonical.Kamp

open FormalSystem.Syntax
open FormalSystem.Metalogic.WeakCanonical
open FormalSystem.Metalogic.WeakCanonical.Separation (atom_literal atom_literal_correct)

/-! ## Constant-true and constant-false VVecEA_m -/

/-- The constant-`⊤` `VVecEA_m m`: a single disjunct with `⊤` at every endpoint
    and a trivial-`⊤` bracket on every interval. Holds on every environment. -/
def VVecEA_m.tt (m : Nat) : VVecEA_m m :=
  { disjuncts := [{ endpointTypes := fun _ => TemporalPred.top
                    intervalBrackets := fun _ =>
                      ⟨0, BracketFormula.trivial TemporalPred.top⟩ }] }

theorem VVecEA_m.tt_holds {sig : MonadicSignature} {m : Nat}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (env : Fin m → M.carrier) :
    (VVecEA_m.tt m).holds M atomMap env := by
  refine ⟨_, List.mem_singleton.mpr rfl, ?_, ?_⟩
  · intro j; exact TemporalPred.eval_at_top M atomMap (env j)
  · intro j
    exact (BracketFormula.trivial_holds M atomMap TemporalPred.top _ _).mpr
      (fun y _ _ => TemporalPred.eval_at_top M atomMap y)

/-- The constant-`⊥` `VVecEA_m m`: the empty disjunction. Holds on no environment. -/
def VVecEA_m.ff (m : Nat) : VVecEA_m m := { disjuncts := [] }

theorem VVecEA_m.ff_not_holds {sig : MonadicSignature} {m : Nat}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (env : Fin m → M.carrier) :
    ¬ (VVecEA_m.ff m).holds M atomMap env := by
  rintro ⟨vea, hmem, _⟩
  simp only [VVecEA_m.ff] at hmem
  exact (List.not_mem_nil) hmem

/-! ## Atom case: single endpoint predicate -/

/-- The atom `VVecEA_m m` for predicate `p` at free variable `i`: a single
    endpoint predicate `atom_literal ... p true` at position `i`, `⊤` elsewhere. -/
noncomputable def VVecEA_m.atomAt {sig : MonadicSignature} {m : Nat}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ q : sig.preds, ∃ a : Atom, atomMap (.atom a) = q)
    (p : sig.preds) (i : Fin m) : VVecEA_m m :=
  (VecEA_m.liftEndpoint i ⟨atom_literal atomMap h_surj p true⟩).toVVecEA_m

theorem VVecEA_m.atomAt_holds {sig : MonadicSignature} {m : Nat}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_surj : ∀ q : sig.preds, ∃ a : Atom, atomMap (.atom a) = q)
    (p : sig.preds) (i : Fin m) (env : Fin m → M.carrier) :
    (VVecEA_m.atomAt atomMap h_surj p i).holds M atomMap env ↔
    M.interp p (env i) := by
  rw [VVecEA_m.atomAt, VecEA_m.toVVecEA_m_holds, VecEA_m.liftEndpoint_holds]
  simp only [TemporalPred.eval_at]
  rw [atom_literal_correct M atomMap h_surj p true (env i)]
  simp

/-! ## Order case: decided by indices under StrictMono -/

/-- The order `VVecEA_m m` for `x_i < x_j`: under `StrictMono env`,
    `env i < env j ↔ i < j`, so this is constant-`⊤` when `i < j` and
    constant-`⊥` otherwise. -/
def VVecEA_m.ltAt {m : Nat} (i j : Fin m) : VVecEA_m m :=
  if i < j then VVecEA_m.tt m else VVecEA_m.ff m

theorem VVecEA_m.ltAt_holds {sig : MonadicSignature} {m : Nat}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (i j : Fin m) (env : Fin m → M.carrier) (henv_mono : StrictMono env) :
    (VVecEA_m.ltAt i j).holds M atomMap env ↔ env i < env j := by
  rw [VVecEA_m.ltAt, henv_mono.lt_iff_lt]
  by_cases h : i < j
  · rw [if_pos h]
    exact iff_of_true (VVecEA_m.tt_holds M atomMap env) h
  · simp only [if_neg h]
    exact iff_of_false (VVecEA_m.ff_not_holds M atomMap env) h

/-! ## Proposition 4.3 (per-model existential form)

### Uniform atom/lt translation lemmas (genuine, non-vacuous)

The two atomic cases of Prop 4.3 are *uniform*: a single `VVecEA_m m` formula
(`atomAt` / `ltAt`) is equivalent to the FO atom across **all** models and
strictly increasing environments. These are the real, reusable building blocks of
Prop 4.3 and are proven sorry-free above (`atomAt_holds`, `ltAt_holds`).

### BLOCKER — the connective cases of a non-vacuous Prop 4.3

Phase 4b set out to close the "easy" structural cases (and/or/ex) of Prop 4.3 as a
per-model existential `∃ v, v.holds env ↔ eval φ`. Investigation this dispatch
established that **the per-model existential statement is vacuous**: for any φ it
is closed by `⟨tt, …⟩` when `eval φ` holds and `⟨ff, …⟩` otherwise (`tt`/`ff`
above), with no dependence on φ's structure. This is the *same* vacuity that the
codebase's `neg_2var_vec_ea` / `neg_vec_ea_m` carry — their conclusion
`∃ v', v'.holds env` is likewise closed by `⟨tt, tt_holds⟩`. A per-model
existential therefore cannot serve as Prop 4.3.

**This finding is now machine-checked and CI-protected**: `Prop42Vacuity.lean`
(`prop42_conclusion_is_vacuous`) derives `neg_2var_vec_ea`'s exact conclusion from
no hypotheses at all, confirming the diagnosis recorded in the paragraph above. The
observation here was correct when written and was nevertheless not acted on —
`Boneyard/NegationIndep.lean:357-364` subsequently adopted `neg_2var_vec_ea` as a
"PRE-AUTHORIZED model-DEPENDENT interim" supplying exactly the Prop 4.3 negation
case this paragraph rules out. The live declarations carrying the vacuous shape
(`EANegationClosure.lean:722`, `NfMultiAnchorBridge/NavigatedSpine.lean:178`) are
annotated in place.

The genuine, non-vacuous Prop 4.3 is the **uniform** statement: a single
*model-independent* function `translate : MonadicFormula sig m → VVecEA_m m` with
`∀ M atomMap env, StrictMono env → ((translate φ).holds ↔ eval φ)`. The connective
cases of a uniform `translate` are each blocked on missing infrastructure:

- **not**: requires a model-independent arity-`m` negation `VVecEA_m m → VVecEA_m m`
  with a *uniform* correctness iff. This is exactly the model-INDEPENDENT Prop 4.2
  backward that report 18 / Phase 3 proved **UNFIXABLE** at the `BracketFormula`
  level (`NegationIndep.lean:331-351`). `neg_vec_ea_m` (Phase 4a) is only the
  model-DEPENDENT existential and does not yield a uniform function.
- **and**: requires a *complete* conjunction closure (Lemma 3.2(1) as an iff).
  `VVecEA_m.conj` is sound but NOT complete — `conjStruct` discards one conjunct's
  interval segments when both carry witnesses (`VecEAClosure.lean:163-169`), so
  `conj_holds` is forward-only. A complete arity-`m` conjunction is missing.
- **all / ex**: require Lemma 3.4 (existential/universal closure at an arbitrary
  witness position). `existClosure` (`VecEA_m.lean:208`) absorbs only the
  *rightmost* variable under `StrictMono (extendEnv env z)`, whereas the De Bruijn
  `.ex`/`.all` binder prepends an order-unconstrained witness at index 0
  (`MonadicFO.lean:222-223`). Bridging these needs a witness-position split over
  the m+1 order positions plus a variable-reordering closure — neither exists.
  Even the live `KampPrior:391` use (n=1: a single witness inserted into a
  1-point environment, `KampPrior.lean:387-391`) needs BOTH a rightward and a
  leftward absorption; `existClosure` supplies only the rightward one.

Consequently no non-vacuous `prop43_correct` is shippable this dispatch without
first building: (a) a complete arity-`m` conjunction closure, (b) Lemma 3.4
(arbitrary-position existential closure incl. a leftward `existClosure`), and
(c) resolving the model-independent negation (currently UNFIXABLE per report 18) —
or restructuring Prop 4.3 to avoid the uniform-negation requirement (e.g. a
positive/De-Morgan normal form fed through a single negation at the top).

This file ships the genuine uniform atom/lt building blocks (`tt`, `ff`, `atomAt`,
`atomAt_holds`, `ltAt`, `ltAt_holds`) sorry-free and off the live import path. It
adds **zero** live-path sorries. See the Phase 4b handoff for the full blocker
write-up and the recommended unblock path.

### Update (2026-07-11) — the exterior INSTANCES are landed

The blocker above concerns the UNIFORM Prop 4.3 connective cases; those remain blocked.
The SPECIFIC finite exterior instances the k=2 gate needs are now landed on the live
import path: the one-sided complement clause families `kvE2_extNegFut`/`kvE2_extNegPast`
with `_sound` AND `_complete` (`ExteriorNegation.lean`/`ExteriorNegationPast.lean`), the
adjacent exterior brackets + enriched composed gate `bracketEndChar_kvE2Ext` (Def 7.5 /
degenerate Lemma 7.6), and the discharge theorem
`bracketEndChar_kvE2Ext_correct_two_prior_frag`
(`NfMultiAnchorBridge/ExteriorBracket.lean`), in which `hexclExt` is eliminated as an
input obligation. This confirms the Prop 4.3 re-flatten route (exterior instances +
Lemma 7.6 adjacency) is viable WITHOUT the blocked uniform machinery — the uniform cases
stay documented here as future work only.
-/

end FormalSystem.Metalogic.WeakCanonical.Kamp
