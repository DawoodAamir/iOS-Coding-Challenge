#!/bin/bash
# Patches realm-core's bundled S2 geometry library to remove std::is_pod
# specializations that are forbidden under iOS 26.4 SDK's libc++.
# Idempotent — safe to re-run after `Reset Package Caches`.
set -euo pipefail

# Locate realm-core checkout (works for any DerivedData path)
DERIVED_DATA="${BUILD_DIR:-${HOME}/Library/Developer/Xcode/DerivedData}"
SEARCH_ROOT="${DERIVED_DATA%/Build/*}"
[ -z "${SEARCH_ROOT}" ] && SEARCH_ROOT="${HOME}/Library/Developer/Xcode/DerivedData"

FILE=$(find "${SEARCH_ROOT}" -path "*/SourcePackages/checkouts/realm-core/src/external/s2/base/macros.h" 2>/dev/null | head -1)

if [ -z "${FILE}" ] || [ ! -f "${FILE}" ]; then
    echo "patch-realm-core: macros.h not found — packages may not be resolved yet"
    exit 0
fi

# If already patched, skip
if ! grep -q "template<> struct is_pod<TypeName>" "${FILE}"; then
    echo "patch-realm-core: already patched"
    exit 0
fi

chmod u+w "${FILE}"
python3 - "${FILE}" <<'PY'
import sys, re
p = sys.argv[1]
s = open(p).read()
s = re.sub(
    r'#define DECLARE_POD\(TypeName\).*?typedef int Dummy_Type_For_DECLARE_POD',
    '#define DECLARE_POD(TypeName) \\\n'
    'typedef int Dummy_Type_For_DECLARE_POD',
    s, count=1, flags=re.DOTALL)
s = re.sub(
    r'#define PROPAGATE_POD_FROM_TEMPLATE_ARGUMENT\(TemplateName\).*?typedef int Dummy_Type_For_PROPAGATE_POD_FROM_TEMPLATE_ARGUMENT',
    '#define PROPAGATE_POD_FROM_TEMPLATE_ARGUMENT(TemplateName) \\\n'
    'typedef int Dummy_Type_For_PROPAGATE_POD_FROM_TEMPLATE_ARGUMENT',
    s, count=1, flags=re.DOTALL)
open(p, 'w').write(s)
PY
echo "patch-realm-core: patched ${FILE}"
