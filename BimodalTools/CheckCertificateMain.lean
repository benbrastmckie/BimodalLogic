/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import BimodalTools.CertificateImport

/-!
# Certificate Re-Verification: the executable root

The root of `lake exe check_certificate`: `main`, and nothing else. It reads one
witness-family certificate as JSON on stdin and prints one JSON line on stdout. The parsing,
decoding, checking and serialization are `BimodalTools.CertificateImport` in
`BimodalTools/CertificateImport.lean`; the wire schema is in `BimodalTools/README.md`, beside
the tableau bridge protocol.

The split exists because an executable root declares a root-namespace `main`, and two of those
cannot share one environment — so a test module could not import the checker if the logic lived
here. This mirrors the `TableauBridgeMain` / `TableauBridge` pair.

## The trust model

A `countermodel` verdict is the erasure of a **constructed term** of
`WitnessFamily.Refutes Γ Δ`: the accepting branch of
`BimodalTools.CertificateImport.checkCertified` carries that statement as a field, so it cannot be
taken without one, and `BimodalTools.CertificateImport.refutes_of_countermodel` recovers the
statement from the printed verdict alone. The line the binary prints says so, additively, with
`"acceptance": "entailment"`.

What is kernel-checked is the **implication**, elaborated once when these modules compile:
`WitnessFamily.refutes_of_certifies` takes the four conditions to the existence of a countermodel.
What is decided at run time, per certificate, is the **hypothesis** — by the same four compiled
`Decidable` instances as before, `decidableLocalCoherentLab`, `decidableFulfillingLab`,
`decidableBoxFaithful` and `decidableTarget`, composed by `decidableCertifies`. So this is **not**
per-certificate kernel checking: the verdict still inherits whatever trust is placed in Lean's
compiler and in this module's decoding. What it no longer requires is that a reader compose the
decided conditions with the agreement theorem themselves.

The checker is one-sided by construction and **never reports validity**. `rejected` says only
that the object handed over is not a certificate; it says nothing whatever about whether the
consequence holds.

## Usage

```bash
echo '{"target":{"premises":[...],"conclusions":[...],"time":0},"bx":[...],"lassos":[...]}' \
  | lake exe check_certificate
```
-/

/-- Main entry point for `check_certificate`. Reads a certificate on stdin, prints one JSON
line on stdout. Ignores command-line arguments. -/
def main (_args : List String) : IO Unit := do
  let stdin ← IO.getStdin
  let input ← stdin.readToEnd
  IO.println (BimodalTools.CertificateImport.checkLineToJson input)
