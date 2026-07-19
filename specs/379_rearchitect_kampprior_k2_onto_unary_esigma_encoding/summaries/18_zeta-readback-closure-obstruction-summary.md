# Phase 13e-1 Summary — ζ readback-closed `F` construction: HARD STOP (obstruction machine-checked)

- **Status:** BLOCKED / surfaced for `/research` (the plan's Phase-13e-1 DoD hard-stop clause,
  anticipated verbatim by the phase goal "it may surface a further, deeper gap (whether a joint
  fixpoint exists at all for this encoding)" and Risk-table row 1).
- **Outcome:** The committed `ReadbackClosed` predicate (`ZetaEngineClosure.lean`) is
  machine-checked **unsatisfiable for every finite `F`**. No `ReadbackClosed`-satisfying `F` can be
  constructed — not by joint fixpoint (i), not by depth-bounded readback (ii). Delivered a green,
  sorry-free, axiom-clean off-path obstruction proof instead of forcing a `sorry`/vacuous `F`.

## What was built

`Theories/Bimodal/Metalogic/WeakCanonical/Kamp/ZetaReadbackClosure.lean` (new, off live import path):

- `numUntl : Formula → Nat` — structural `untl`-constructor count (sees through `and`/`neg`/`top`).
- `numUntl_and`, `length_le_numUntl_buildRight` — `buildRight L r` carries ≥ `L.length` `untl` nodes.
- `psiConst sig F m : ExistsForallFormula sig F 1` — the ∃∀-formula (Def 3.1, PDF p.4) with `m+1`
  ordered points, free variable pinned at `x₀`, trivial point/interval types.
- `sub_le_numUntl_translateEF1`, `le_numUntl_translateProp35` —
  `m ≤ numUntl (translateProp35 … (psiConst sig F m))`: readbacks of unbounded `untl`-count.
- **`not_readbackClosed : ¬ ReadbackClosed atomMap h_surj`** — the obstruction, for every `sig`,
  finite `F`, and `(atomMap, h_surj)`.

## The obstruction (root cause)

`ReadbackClosed`'s first conjunct `∀ ξ : ExistsForallFormula sig F 1, translateProp35 … ξ ∈ F`
quantifies over an **infinite** type (`ExistsForallFormula sig F 1` has an unbounded `n : Nat`
field). `translateProp35 ξ = translateEF1 ξ.n …` nests one `untl` per existential point, so the
readback image is infinite (unbounded size). No finite `F` can contain it. The committed predicate
**over-specifies**: Rabinovich's Fischer–Ladner closure (Def 4.1 p.5, Thm 4.4 p.6) quantifies the
alphabet over a fixed target formula's FINITE closure family (bounded `n`), and Phase 13e-2's
`*_of_closed` consumers only apply closure at the finite family of ∃∀-formulas actually fed at the
ζ sites — not over all unbounded `ξ`.

## Research pivot (for `/research` + `/revise`)

Re-scope `ReadbackClosed` and its four `*_of_closed` consumers in `ZetaEngineClosure.lean` to
quantify over the finite, input-derived ξ-family (Fischer–Ladner closure of the input), then
discharge with `F` = Fischer–Ladner closure. This edits the COMMITTED probe predicate and revises
the 13e-1/13e-2 phases — no novel mathematics, no Feferman–Vaught: Rabinovich's own finite FL
closure, restated at the correct (finite) quantifier scope.

## Verification

- New file: sorry-free; axioms `[propext, Classical.choice, Quot.sound]`.
- Full `lake build`: EXIT 0 (1770 jobs).
- `#print axioms completeness_discrete`: `[propext, sorryAx, Classical.choice, Lean.ofReduceBool,
  Lean.trustCompiler, Quot.sound]` — byte-identical to baseline (`KampPrior.lean:562` `sorryAx`
  present and untouched, as required through Phase 13e-2).
- Off live import path (nothing imports `ZetaReadbackClosure`).

## Faithfulness / prohibitions honored

Rabinovich cited by PDF page only (companion `.md` treated as corrupt, unused). k≥2 blocker
anchored by declaration name `nf_nvar_exist_all_depths` (the `| _k + 2` arm). No task-number
pointers in `Theories/**`. No `sorry`/`def := True`/vacuous `F := ∅`. `EANegation.lean:1090/:1249`
and `KampPrior.lean` untouched. No reset/checkout (fix-forward).
