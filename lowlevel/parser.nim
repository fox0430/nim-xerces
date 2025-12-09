import types, dom, sax

{.push header: "<xercesc/parsers/XercesDOMParser.hpp>".}

type
  ValSchemes* = enum
    Val_Never
    Val_Always
    Val_Auto

  XercesDOMParser* {.importcpp: "xercesc::XercesDOMParser", bycopy.} = object

  XercesDOMParserPtr* = ptr XercesDOMParser

proc newXercesDOMParser*(): XercesDOMParserPtr {.
  importcpp: "new xercesc::XercesDOMParser()"
.}

proc deleteXercesDOMParser*(parser: XercesDOMParserPtr) {.importcpp: "delete #".}

# Parsing methods
proc parse*(parser: XercesDOMParserPtr, systemId: cstring) {.importcpp: "#->parse(#)".}
proc parseXMLCh*(
  parser: XercesDOMParserPtr, systemId: ptr XMLCh
) {.importcpp: "#->parse(#)".}

proc parse*(
  parser: XercesDOMParserPtr, source: InputSourcePtr
) {.importcpp: "#->parse(*#)".}

# Document access
proc getDocument*(
  parser: XercesDOMParserPtr
): DOMDocumentPtr {.importcpp: "#->getDocument()".}

proc adoptDocument*(
  parser: XercesDOMParserPtr
): DOMDocumentPtr {.importcpp: "#->adoptDocument()".}

# Validation settings
proc setValidationScheme*(
  parser: XercesDOMParserPtr, newScheme: ValSchemes
) {.importcpp: "#->setValidationScheme((xercesc::AbstractDOMParser::ValSchemes)#)".}

proc setDoNamespaces*(
  parser: XercesDOMParserPtr, newState: bool
) {.importcpp: "#->setDoNamespaces(#)".}

proc setDoSchema*(
  parser: XercesDOMParserPtr, newState: bool
) {.importcpp: "#->setDoSchema(#)".}

proc setValidationSchemaFullChecking*(
  parser: XercesDOMParserPtr, newState: bool
) {.importcpp: "#->setValidationSchemaFullChecking(#)".}

proc setHandleMultipleImports*(
  parser: XercesDOMParserPtr, newState: bool
) {.importcpp: "#->setHandleMultipleImports(#)".}

# Error handling settings
proc setExitOnFirstFatalError*(
  parser: XercesDOMParserPtr, newState: bool
) {.importcpp: "#->setExitOnFirstFatalError(#)".}

proc setValidationConstraintFatal*(
  parser: XercesDOMParserPtr, newState: bool
) {.importcpp: "#->setValidationConstraintFatal(#)".}

# Feature settings
proc setCreateEntityReferenceNodes*(
  parser: XercesDOMParserPtr, create: bool
) {.importcpp: "#->setCreateEntityReferenceNodes(#)".}

proc setIncludeIgnorableWhitespace*(
  parser: XercesDOMParserPtr, doInclude: bool
) {.importcpp: "#->setIncludeIgnorableWhitespace(#)".}

proc setCreateCommentNodes*(
  parser: XercesDOMParserPtr, create: bool
) {.importcpp: "#->setCreateCommentNodes(#)".}

# Getters
proc getValidationSchemeInt*(
  parser: XercesDOMParserPtr
): cint {.importcpp: "(int)#->getValidationScheme()".}

template getValidationScheme*(parser: XercesDOMParserPtr): ValSchemes =
  ValSchemes(parser.getValidationSchemeInt())

proc getDoNamespaces*(
  parser: XercesDOMParserPtr
): bool {.importcpp: "#->getDoNamespaces()".}

proc getDoSchema*(parser: XercesDOMParserPtr): bool {.importcpp: "#->getDoSchema()".}
proc getValidationSchemaFullChecking*(
  parser: XercesDOMParserPtr
): bool {.importcpp: "#->getValidationSchemaFullChecking()".}

proc getExitOnFirstFatalError*(
  parser: XercesDOMParserPtr
): bool {.importcpp: "#->getExitOnFirstFatalError()".}

proc getValidationConstraintFatal*(
  parser: XercesDOMParserPtr
): bool {.importcpp: "#->getValidationConstraintFatal()".}

proc getCreateEntityReferenceNodes*(
  parser: XercesDOMParserPtr
): bool {.importcpp: "#->getCreateEntityReferenceNodes()".}

proc getIncludeIgnorableWhitespace*(
  parser: XercesDOMParserPtr
): bool {.importcpp: "#->getIncludeIgnorableWhitespace()".}

proc getCreateCommentNodes*(
  parser: XercesDOMParserPtr
): bool {.importcpp: "#->getCreateCommentNodes()".}

# External schema location settings
proc setExternalSchemaLocation*(
  parser: XercesDOMParserPtr, schemaLocation: cstring
) {.importcpp: "#->setExternalSchemaLocation(#)".}

proc setExternalNoNamespaceSchemaLocation*(
  parser: XercesDOMParserPtr, schemaLocation: cstring
) {.importcpp: "#->setExternalNoNamespaceSchemaLocation(#)".}

# Reset
proc resetDocumentPool*(
  parser: XercesDOMParserPtr
) {.importcpp: "#->resetDocumentPool()".}

{.pop.}

# SAXParseExceptionObj methods moved to types.nim

# Set error handler
{.push header: "<xercesc/parsers/XercesDOMParser.hpp>".}
proc setErrorHandler*(
  parser: XercesDOMParserPtr, handler: ptr ErrorHandler
) {.importcpp: "#->setErrorHandler(#)".}

proc getErrorHandler*(
  parser: XercesDOMParserPtr
): ptr ErrorHandler {.importcpp: "#->getErrorHandler()".}

{.pop.}
