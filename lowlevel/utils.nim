import types

# Const pointer type for C++ interop
type ConstXMLChPtr* {.importc: "const XMLCh*".} = distinct ptr XMLCh

{.push header: "<xercesc/util/XMLString.hpp>".}

type XMLString* {.importcpp: "xercesc::XMLString".} = object

# String conversion
proc transcode*(s: cstring): ptr XMLCh {.importcpp: "xercesc::XMLString::transcode(#)".}
proc transcode*(s: ptr XMLCh): cstring {.importcpp: "xercesc::XMLString::transcode(#)".}
proc transcodeConst*(s: ConstXMLChPtr): cstring {.importcpp: "xercesc::XMLString::transcode(#)".}
proc release*(s: ptr ptr XMLCh) {.importcpp: "xercesc::XMLString::release(#)".}
proc release*(s: ptr cstring) {.importcpp: "xercesc::XMLString::release(#)".}

# String utilities
proc stringLen*(s: ptr XMLCh): XMLSize {.importcpp: "xercesc::XMLString::stringLen(#)".}
proc compareString*(
  s1, s2: ptr XMLCh
): int {.importcpp: "xercesc::XMLString::compareString(#, #)".}

proc compareIString*(
  s1, s2: ptr XMLCh
): int {.importcpp: "xercesc::XMLString::compareIString(#, #)".}

proc equals*(s1, s2: ptr XMLCh): bool {.importcpp: "xercesc::XMLString::equals(#, #)".}
proc replicate*(
  s: ptr XMLCh
): ptr XMLCh {.importcpp: "xercesc::XMLString::replicate(#)".}

{.pop.}

# High-level Nim string conversions
proc toXMLCh*(s: string): ptr XMLCh =
  ## Convert a Nim string to XMLCh*
  ## Caller is responsible for releasing the memory with releaseXMLCh
  result = transcode(s.cstring)

proc releaseXMLCh*(s: var ptr XMLCh) =
  ## Release XMLCh* memory allocated by toXMLCh
  if s != nil:
    release(addr s)
    s = nil

proc `$`*(s: ptr XMLCh): string =
  ## Convert XMLCh* to Nim string
  if s == nil:
    return ""
  var cstr = transcode(s)
  if cstr != nil:
    result = $cstr
    var cstrPtr = cstr
    release(addr cstrPtr)

proc isNil*(s: ConstXMLChPtr): bool {.borrow.}

proc `$`*(s: ConstXMLChPtr): string =
  ## Convert const XMLCh* to Nim string
  if s.isNil:
    return ""
  var cstr = transcodeConst(s)
  if cstr != nil:
    result = $cstr
    var cstrPtr = cstr
    release(addr cstrPtr)

template withXMLCh*(varname: untyped, str: string, body: untyped) =
  ## Automatically manages XMLCh* lifetime
  var varname = toXMLCh(str)
  try:
    body
  finally:
    releaseXMLCh(varname)
