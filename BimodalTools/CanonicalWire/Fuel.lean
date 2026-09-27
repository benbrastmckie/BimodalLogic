/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import BimodalTools.CanonicalWire.RoundTrip

/-!
# Canonical Wire Format, Layer 1: fuel sufficiency

The parser is total because it is fuel-indexed, and "out of fuel" is one of its protocol errors.
This module discharges the obligation that comes with that design: on canonical input, the fuel
the public entry point seeds is always enough, so the out-of-fuel branch is *unreachable* rather
than merely unlikely.

## What is and is not claimed

`parseCanonical_printCanonical` says that a printed canonical value reparses to itself through the
public `String`-level entry point, fuel included. `parseCanonical_ne_outOfFuel` is the negative
reading of the same fact: the entry point never reports out of fuel on bytes the printer produced.

It is **not** claimed that no input whatsoever can exhaust the budget. That stronger statement
would need an invariant relating fuel to input length through every rejection path, and it is not
what the trust argument rests on. The containment is worth stating plainly: an exhausted budget can
only produce a spurious *rejection*, never a misinterpretation, because the out-of-fuel branch
returns `.error`. The defect class this whole directory closes is the other one — bytes accepted as
a certificate different from the one that was sent — and nothing about fuel can reintroduce it.

## Main Results

- `parseCJson_fuel_sufficient` — seeding the fuel from the input's own length always suffices
- `parseCanonical_printCanonical` — the public entry point round-trips a canonical value
- `parseCanonical_ne_outOfFuel` — the out-of-fuel error is unreachable on canonical bytes

## References

* `BimodalTools/CanonicalWire/RoundTrip.lean` — the round-trip theorem and the measure bound
* `BimodalTools/CanonicalWire/Parse.lean` — `parseCanonical`, which seeds the fuel
-/

set_option autoImplicit false

namespace BimodalTools.CanonicalWire

/-- **The fuel the public entry point seeds is always enough.** Composing the round-trip theorem
with the measure bound: a value's budget never exceeds its own printed length, and the entry point
seeds at least that. -/
theorem parseCJson_fuel_sufficient (j : CJson) (rest : List Char) (hok : Canonical j)
    (hrest : NoDigitHead rest) :
    parseCJson (printCJson j ++ rest).length (printCJson j ++ rest) = .ok (j, rest) := by
  refine parseCJson_printCJson j rest hok hrest _ ?_
  have h := size_le_print_length j
  simp only [List.length_append]
  omega

/-- **The public entry point round-trips a canonical value**, fuel and strict end-of-input check
included. This is the layer-1 statement `Cert.lean` applies. -/
theorem parseCanonical_printCanonical (j : CJson) (hok : Canonical j) :
    parseCanonical (printCanonical j) = .ok j := by
  rw [parseCanonical]
  have hf : size j ≤ (printCanonical j).toList.length + 1 := by
    rw [printCanonical, String.toList_ofList]
    have h := size_le_print_length j
    omega
  rw [parseCJson_printCanonical j hok _ hf]
  simp

/-- **The out-of-fuel error is unreachable on canonical bytes.** The negative reading of
`parseCanonical_printCanonical`: whatever the entry point answers on bytes the printer produced, it
is not that the budget ran out. -/
theorem parseCanonical_ne_outOfFuel (j : CJson) (hok : Canonical j) :
    parseCanonical (printCanonical j) ≠ .error outOfFuelMsg := by
  rw [parseCanonical_printCanonical j hok]
  simp

end BimodalTools.CanonicalWire
