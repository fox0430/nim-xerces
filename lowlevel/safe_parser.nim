import types, dom, parser, sax, exceptions

# Safe parsing wrappers that catch C++ exceptions

{.
  emit:
    """
#include <xercesc/parsers/XercesDOMParser.hpp>
#include <xercesc/framework/MemBufInputSource.hpp>
#include <xercesc/util/XMLException.hpp>
#include <xercesc/dom/DOMException.hpp>
#include <xercesc/sax/SAXException.hpp>
#include <xercesc/sax/SAXParseException.hpp>
#include <xercesc/util/XMLString.hpp>
#include <string>

struct NimParseError {
    int errorKind;  // 0=XMLException, 1=DOMException, 2=SAXException, 3=SAXParseException, 4=Unknown
    char* message;
    int line;
    int column;
};

static char* duplicateString(const char* s) {
    if (!s) return nullptr;
    size_t len = strlen(s) + 1;
    char* result = new char[len];
    memcpy(result, s, len);
    return result;
}

static char* xmlChToCString(const XMLCh* xmlStr) {
    if (!xmlStr) return duplicateString("Unknown error");
    char* cstr = xercesc::XMLString::transcode(xmlStr);
    char* result = duplicateString(cstr);
    xercesc::XMLString::release(&cstr);
    return result;
}

static NimParseError safeParseFile(xercesc::XercesDOMParser* parser, const char* path) {
    NimParseError err = {-1, nullptr, 0, 0};
    try {
        parser->parse(path);
        return err;
    } catch (const xercesc::SAXParseException& e) {
        err.errorKind = 3;
        err.message = xmlChToCString(e.getMessage());
        err.line = (int)e.getLineNumber();
        err.column = (int)e.getColumnNumber();
    } catch (const xercesc::SAXException& e) {
        err.errorKind = 2;
        err.message = xmlChToCString(e.getMessage());
    } catch (const xercesc::DOMException& e) {
        err.errorKind = 1;
        err.message = xmlChToCString(e.getMessage());
    } catch (const xercesc::XMLException& e) {
        err.errorKind = 0;
        err.message = xmlChToCString(e.getMessage());
    } catch (...) {
        err.errorKind = 4;
        err.message = duplicateString("Unknown C++ exception");
    }
    return err;
}

static NimParseError safeParseMemBuf(xercesc::XercesDOMParser* parser, const xercesc::MemBufInputSource* src) {
    NimParseError err = {-1, nullptr, 0, 0};
    try {
        parser->parse(*src);
        return err;
    } catch (const xercesc::SAXParseException& e) {
        err.errorKind = 3;
        err.message = xmlChToCString(e.getMessage());
        err.line = (int)e.getLineNumber();
        err.column = (int)e.getColumnNumber();
    } catch (const xercesc::SAXException& e) {
        err.errorKind = 2;
        err.message = xmlChToCString(e.getMessage());
    } catch (const xercesc::DOMException& e) {
        err.errorKind = 1;
        err.message = xmlChToCString(e.getMessage());
    } catch (const xercesc::XMLException& e) {
        err.errorKind = 0;
        err.message = xmlChToCString(e.getMessage());
    } catch (...) {
        err.errorKind = 4;
        err.message = duplicateString("Unknown C++ exception");
    }
    return err;
}

static void freeParseError(NimParseError* err) {
    if (err->message) {
        delete[] err->message;
        err->message = nullptr;
    }
}
"""
.}

type NimParseError {.importcpp: "NimParseError", nodecl.} = object
  errorKind: cint
  message: cstring
  line: cint
  column: cint

proc safeParseFileImpl(
  parser: XercesDOMParserPtr, path: cstring
): NimParseError {.importcpp: "safeParseFile(#, #)", nodecl.}

proc safeParseMemBufImpl(
  parser: XercesDOMParserPtr, src: ptr MemBufInputSource
): NimParseError {.importcpp: "safeParseMemBuf(#, #)", nodecl.}

proc freeParseError(err: ptr NimParseError) {.importcpp: "freeParseError(#)", nodecl.}

proc toXercesErrorKind(kind: cint): XercesErrorKind =
  case kind
  of 0: xekXMLException
  of 1: xekDOMException
  of 2: xekSAXException
  of 3: xekSAXParseException
  else: xekUnknown

proc safeParse*(parser: XercesDOMParserPtr, path: string): XercesResult[void] =
  ## Parse a file with C++ exception handling.
  ## Returns an error result instead of crashing on invalid XML.
  var parseErr = safeParseFileImpl(parser, path.cstring)
  if parseErr.errorKind < 0:
    result = okVoid()
  else:
    let msg =
      if parseErr.message != nil:
        $parseErr.message
      else:
        "Unknown error"
    result = err[void](
      toXercesErrorKind(parseErr.errorKind), msg, parseErr.line.int, parseErr.column.int
    )
  freeParseError(addr parseErr)

proc safeParse*(
    parser: XercesDOMParserPtr, src: ptr MemBufInputSource
): XercesResult[void] =
  ## Parse from memory buffer with C++ exception handling.
  ## Returns an error result instead of crashing on invalid XML.
  var parseErr = safeParseMemBufImpl(parser, src)
  if parseErr.errorKind < 0:
    result = okVoid()
  else:
    let msg =
      if parseErr.message != nil:
        $parseErr.message
      else:
        "Unknown error"
    result = err[void](
      toXercesErrorKind(parseErr.errorKind), msg, parseErr.line.int, parseErr.column.int
    )
  freeParseError(addr parseErr)

proc safeParseXMLFile*(filePath: string): XercesResult[DOMDocumentPtr] =
  ## Parse an XML file safely, returning a Result type.
  ## On success, caller owns the document and must call release().
  let parser = newXercesDOMParser()
  defer:
    deleteXercesDOMParser(parser)

  let parseResult = safeParse(parser, filePath)
  if parseResult.isErr:
    return err[DOMDocumentPtr](
      parseResult.errorKind, parseResult.errorMessage, parseResult.line,
      parseResult.column,
    )

  let doc = parser.adoptDocument()
  if doc == nil:
    return err[DOMDocumentPtr](xekUnknown, "Failed to get document after parsing")

  ok(doc)

proc safeParseXMLString*(xmlContent: string): XercesResult[DOMDocumentPtr] =
  ## Parse an XML string safely, returning a Result type.
  ## On success, caller owns the document and must call release().
  let parser = newXercesDOMParser()
  defer:
    deleteXercesDOMParser(parser)

  let src = newMemBufInputSource(
    cast[ptr XMLByte](xmlContent.cstring), xmlContent.len.XMLSize, "xmlBuffer"
  )
  defer:
    deleteMemBufInputSource(src)

  let parseResult = safeParse(parser, src)
  if parseResult.isErr:
    return err[DOMDocumentPtr](
      parseResult.errorKind, parseResult.errorMessage, parseResult.line,
      parseResult.column,
    )

  let doc = parser.adoptDocument()
  if doc == nil:
    return err[DOMDocumentPtr](xekUnknown, "Failed to get document after parsing")

  ok(doc)
