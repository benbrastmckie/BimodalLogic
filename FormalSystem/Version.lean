/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Init

/-!
# The library version

`FormalSystem.version` is the library's release version as a string, and this module is its
single definition site. It holds nothing else, so that a release changes exactly one line of Lean.

The version is recorded in three places, which must agree at every release tag: the tag itself
(`vX.Y.Z`), the `version:` field of `CITATION.cff`, and the constant below. The release checklist in
`docs/development/VERSIONING.md` points here, and `.github/workflows/release.yml` refuses to
publish a release for which the three disagree.
-/

namespace FormalSystem

/-- The library's release version, following Semantic Versioning (`MAJOR.MINOR.PATCH`). -/
def version : String := "1.0.0"

end FormalSystem
