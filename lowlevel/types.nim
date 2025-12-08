when defined(windows):
  {.passL: "-lxerces-c_3".}
else:
  {.passL: "-lxerces-c".}

type
  XMLCh* {.importcpp: "XMLCh", header: "<xercesc/util/XercesDefs.hpp>".} = uint16
  XMLByte* {.importcpp: "XMLByte", header: "<xercesc/util/XercesDefs.hpp>".} = uint8
  XMLSize* {.importcpp: "XMLSize_t", header: "<xercesc/util/XercesDefs.hpp>".} = csize_t
  XMLFilePos* {.importcpp: "XMLFilePos", header: "<xercesc/util/XercesDefs.hpp>".} =
    uint64

  MemoryManager* {.
    importcpp: "xercesc::MemoryManager", header: "<xercesc/framework/MemoryManager.hpp>"
  .} = object

  XMLExceptionObj* {.
    importcpp: "xercesc::XMLException",
    header: "<xercesc/util/XMLException.hpp>",
    inheritable
  .} = object

  DOMExceptionObj* {.
    importcpp: "xercesc::DOMException", header: "<xercesc/dom/DOMException.hpp>"
  .} = object of XMLExceptionObj

  SAXExceptionObj* {.
    importcpp: "xercesc::SAXException",
    header: "<xercesc/sax/SAXException.hpp>",
    inheritable
  .} = object

  SAXParseExceptionObj* {.
    importcpp: "xercesc::SAXParseException",
    header: "<xercesc/sax/SAXParseException.hpp>"
  .} = object of SAXExceptionObj

  ErrorHandler* {.
    importcpp: "xercesc::ErrorHandler", header: "<xercesc/sax/ErrorHandler.hpp>"
  .} = object

  # Nim exception wrappers
  XercesError* = object of CatchableError
  XMLException* = object of XercesError
  DOMException* = object of XercesError
    code*: DOMExceptionCode

  SAXException* = object of XercesError
  SAXParseException* = object of SAXException
    lineNumber*: XMLSize
    columnNumber*: XMLSize

  DOMExceptionCode* = enum
    INDEX_SIZE_ERR = 1
    DOMSTRING_SIZE_ERR = 2
    HIERARCHY_REQUEST_ERR = 3
    WRONG_DOCUMENT_ERR = 4
    INVALID_CHARACTER_ERR = 5
    NO_DATA_ALLOWED_ERR = 6
    NO_MODIFICATION_ALLOWED_ERR = 7
    NOT_FOUND_ERR = 8
    NOT_SUPPORTED_ERR = 9
    INUSE_ATTRIBUTE_ERR = 10
    INVALID_STATE_ERR = 11
    SYNTAX_ERR = 12
    INVALID_MODIFICATION_ERR = 13
    NAMESPACE_ERR = 14
    INVALID_ACCESS_ERR = 15
    VALIDATION_ERR = 16
    TYPE_MISMATCH_ERR = 17

# Exception message extraction
{.push header: "<xercesc/util/XMLException.hpp>".}
proc getMessage*(e: ptr XMLExceptionObj): ptr XMLCh {.importcpp: "#->getMessage()".}
proc getCode*(e: ptr XMLExceptionObj): cuint {.importcpp: "#->getCode()".}
{.pop.}

{.push header: "<xercesc/dom/DOMException.hpp>".}
proc getDOMExceptionCode*(e: ptr DOMExceptionObj): cshort {.importcpp: "#->code".}
proc getDOMExceptionMsg*(
  e: ptr DOMExceptionObj
): ptr XMLCh {.importcpp: "#->getMessage()".}

{.pop.}

{.push header: "<xercesc/sax/SAXException.hpp>".}
proc getSAXMessage*(e: ptr SAXExceptionObj): ptr XMLCh {.importcpp: "#->getMessage()".}
{.pop.}

{.push header: "<xercesc/sax/SAXParseException.hpp>".}
proc getLineNumber*(
  e: ptr SAXParseExceptionObj
): XMLSize {.importcpp: "#->getLineNumber()".}

proc getColumnNumber*(
  e: ptr SAXParseExceptionObj
): XMLSize {.importcpp: "#->getColumnNumber()".}

proc getSystemId*(
  e: ptr SAXParseExceptionObj
): ptr XMLCh {.importcpp: "#->getSystemId()".}

proc getPublicId*(
  e: ptr SAXParseExceptionObj
): ptr XMLCh {.importcpp: "#->getPublicId()".}

{.pop.}
