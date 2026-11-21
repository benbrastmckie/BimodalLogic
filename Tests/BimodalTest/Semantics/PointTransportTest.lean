/-
Copyright (c) 2026 Tanner Duve. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Tanner Duve
-/

import FormalSystem.Semantics.PointTransport

/-! Tests for composing distinct pointed truth judgments through explicit relations. -/

namespace BimodalTest.Semantics

open FormalSystem.Semantics FormalSystem.Semantics.PointTransport
open FormalSystem.Syntax

variable {F : TaskFrame} {M : TaskModel F}

example {p q : Point Formula F} (A : Formula) :
    At M q (A.box.box) → At M p (A.box.box) := by
  intro hq
  exact ((iffTransport_box M A.box).goal).reduce trivial hq

example {p q r : Point Formula F} (A : Formula) (h : At M p A.box) :
    At M r A.box :=
  ((iffTransport_box M A).fact.trans (iffTransport_box M A).fact).apply
    ⟨q, trivial, trivial⟩ h

end BimodalTest.Semantics
