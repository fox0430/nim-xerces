import types, utils

# SAX2 types
{.push header: "<xercesc/sax2/SAX2XMLReader.hpp>".}

type
  SAX2ValSchemes* = enum
    SAX2_Val_Never
    SAX2_Val_Always
    SAX2_Val_Auto

  SAX2XMLReader* {.importcpp: "xercesc::SAX2XMLReader".} = object
  SAX2XMLReaderPtr* = ptr SAX2XMLReader

{.pop.}

# ContentHandler interface
{.push header: "<xercesc/sax2/ContentHandler.hpp>".}

type ContentHandler* {.importcpp: "xercesc::ContentHandler".} = object

{.pop.}

# DTDHandler interface
{.push header: "<xercesc/sax/DTDHandler.hpp>".}

type DTDHandler* {.importcpp: "xercesc::DTDHandler".} = object

{.pop.}

# EntityResolver interface
{.push header: "<xercesc/sax/EntityResolver.hpp>".}

type EntityResolver* {.importcpp: "xercesc::EntityResolver".} = object

{.pop.}

# Attributes interface
{.push header: "<xercesc/sax2/Attributes.hpp>".}

type
  Attributes* {.importcpp: "xercesc::Attributes".} = object
  AttributesPtr* = ptr Attributes

proc getLength*(attrs: AttributesPtr): XMLSize {.importcpp: "#->getLength()".}
proc getURI*(
  attrs: AttributesPtr, index: XMLSize
): ptr XMLCh {.importcpp: "#->getURI(#)".}

proc getLocalName*(
  attrs: AttributesPtr, index: XMLSize
): ptr XMLCh {.importcpp: "#->getLocalName(#)".}

proc getQName*(
  attrs: AttributesPtr, index: XMLSize
): ptr XMLCh {.importcpp: "#->getQName(#)".}

proc getType*(
  attrs: AttributesPtr, index: XMLSize
): ptr XMLCh {.importcpp: "#->getType(#)".}

proc getValue*(
  attrs: AttributesPtr, index: XMLSize
): ptr XMLCh {.importcpp: "#->getValue(#)".}

proc getValueByQName*(
  attrs: AttributesPtr, qName: ptr XMLCh
): ptr XMLCh {.importcpp: "#->getValue(#)".}

proc getValueByName*(
  attrs: AttributesPtr, uri: ptr XMLCh, localName: ptr XMLCh
): ptr XMLCh {.importcpp: "#->getValue(#, #)".}

proc getIndex*(
  attrs: AttributesPtr, uri: ptr XMLCh, localName: ptr XMLCh
): int {.importcpp: "#->getIndex(#, #)".}

proc getIndexByQName*(
  attrs: AttributesPtr, qName: ptr XMLCh
): int {.importcpp: "#->getIndex(#)".}

proc getTypeByQName*(
  attrs: AttributesPtr, qName: ptr XMLCh
): ptr XMLCh {.importcpp: "#->getType(#)".}

proc getTypeByName*(
  attrs: AttributesPtr, uri: ptr XMLCh, localName: ptr XMLCh
): ptr XMLCh {.importcpp: "#->getType(#, #)".}

{.pop.}

# Locator interface
{.push header: "<xercesc/sax/Locator.hpp>".}

type
  Locator* {.importcpp: "xercesc::Locator".} = object
  LocatorPtr* = ptr Locator

proc getPublicId*(loc: LocatorPtr): ptr XMLCh {.importcpp: "#->getPublicId()".}
proc getSystemId*(loc: LocatorPtr): ptr XMLCh {.importcpp: "#->getSystemId()".}
proc getLineNumber*(loc: LocatorPtr): XMLSize {.importcpp: "#->getLineNumber()".}
proc getColumnNumber*(loc: LocatorPtr): XMLSize {.importcpp: "#->getColumnNumber()".}

{.pop.}

# InputSource
{.push header: "<xercesc/sax/InputSource.hpp>".}

type
  InputSource* {.importcpp: "xercesc::InputSource", inheritable.} = object
  InputSourcePtr* = ptr InputSource

{.pop.}

# MemBufInputSource for parsing from memory
{.push header: "<xercesc/framework/MemBufInputSource.hpp>".}

type MemBufInputSource* {.importcpp: "xercesc::MemBufInputSource".} = object of InputSource

proc newMemBufInputSource*(
  srcDocBytes: ptr XMLByte,
  byteCount: XMLSize,
  bufId: cstring,
  adoptBuffer: bool = false,
): ptr MemBufInputSource {.importcpp: "new xercesc::MemBufInputSource(#, #, #, #)".}

proc deleteMemBufInputSource*(src: ptr MemBufInputSource) {.importcpp: "delete #".}

{.pop.}

# LocalFileInputSource for parsing from files
{.push header: "<xercesc/framework/LocalFileInputSource.hpp>".}

type LocalFileInputSource* {.importcpp: "xercesc::LocalFileInputSource".} = object of InputSource

proc newLocalFileInputSource*(
  filePath: ptr XMLCh
): ptr LocalFileInputSource {.importcpp: "new xercesc::LocalFileInputSource(#)".}

proc deleteLocalFileInputSource*(
  src: ptr LocalFileInputSource
) {.importcpp: "delete #".}

{.pop.}

# SAXParser (legacy SAX1)
{.push header: "<xercesc/parsers/SAXParser.hpp>".}

type
  SAXParser* {.importcpp: "xercesc::SAXParser".} = object
  SAXParserPtr* = ptr SAXParser

proc newSAXParser*(): SAXParserPtr {.importcpp: "new xercesc::SAXParser()".}
proc deleteSAXParser*(parser: SAXParserPtr) {.importcpp: "delete #".}

proc parse*(parser: SAXParserPtr, systemId: cstring) {.importcpp: "#->parse(#)".}
proc parse*(parser: SAXParserPtr, source: InputSourcePtr) {.importcpp: "#->parse(*#)".}

proc setDoNamespaces*(
  parser: SAXParserPtr, newState: bool
) {.importcpp: "#->setDoNamespaces(#)".}

proc setDoSchema*(
  parser: SAXParserPtr, newState: bool
) {.importcpp: "#->setDoSchema(#)".}

{.pop.}

# XMLReaderFactory for creating SAX2 readers
{.push header: "<xercesc/sax2/XMLReaderFactory.hpp>".}

type XMLReaderFactory* {.importcpp: "xercesc::XMLReaderFactory".} = object

proc createXMLReader*(
  _: typedesc[XMLReaderFactory]
): SAX2XMLReaderPtr {.importcpp: "xercesc::XMLReaderFactory::createXMLReader()".}

{.pop.}

# SAX2XMLReader methods
{.push header: "<xercesc/sax2/SAX2XMLReader.hpp>".}

proc deleteSAX2XMLReader*(reader: SAX2XMLReaderPtr) {.importcpp: "delete #".}

proc parse*(reader: SAX2XMLReaderPtr, systemId: cstring) {.importcpp: "#->parse(#)".}
proc parse*(
  reader: SAX2XMLReaderPtr, source: InputSourcePtr
) {.importcpp: "#->parse(*#)".}

proc setContentHandler*(
  reader: SAX2XMLReaderPtr, handler: ptr ContentHandler
) {.importcpp: "#->setContentHandler(#)".}

proc getContentHandler*(
  reader: SAX2XMLReaderPtr
): ptr ContentHandler {.importcpp: "#->getContentHandler()".}

proc setErrorHandler*(
  reader: SAX2XMLReaderPtr, handler: ptr ErrorHandler
) {.importcpp: "#->setErrorHandler(#)".}

proc getErrorHandler*(
  reader: SAX2XMLReaderPtr
): ptr ErrorHandler {.importcpp: "#->getErrorHandler()".}

proc setEntityResolver*(
  reader: SAX2XMLReaderPtr, resolver: ptr EntityResolver
) {.importcpp: "#->setEntityResolver(#)".}

proc getEntityResolver*(
  reader: SAX2XMLReaderPtr
): ptr EntityResolver {.importcpp: "#->getEntityResolver()".}

proc setDTDHandler*(
  reader: SAX2XMLReaderPtr, handler: ptr DTDHandler
) {.importcpp: "#->setDTDHandler(#)".}

proc getDTDHandler*(
  reader: SAX2XMLReaderPtr
): ptr DTDHandler {.importcpp: "#->getDTDHandler()".}

proc setFeature*(
  reader: SAX2XMLReaderPtr, name: ptr XMLCh, value: bool
) {.importcpp: "#->setFeature(#, #)".}

proc getFeature*(
  reader: SAX2XMLReaderPtr, name: ptr XMLCh
): bool {.importcpp: "#->getFeature(#)".}

{.pop.}

# Iterator for Attributes
iterator pairs*(
    attrs: AttributesPtr
): tuple[index: XMLSize, qname: ptr XMLCh, value: ptr XMLCh] =
  if attrs != nil:
    let len = attrs.getLength()
    for i in 0 ..< len:
      yield (i, attrs.getQName(i), attrs.getValue(i))

# NimContentHandler - High-level SAX parsing with Nim callbacks

import std/os

const nimContentHandlerHeader = "nim_content_handler.hpp"

# Add include path for the header
{.passC: "-I" & currentSourcePath().parentDir().}

type
  NimContentHandler* {.importcpp: "NimContentHandler", header: nimContentHandlerHeader.} = object
  NimContentHandlerPtr* = ptr NimContentHandler

# Callback types matching C++
type
  StartDocumentCallback* = proc(userData: pointer) {.cdecl.}
  EndDocumentCallback* = proc(userData: pointer) {.cdecl.}
  StartElementCallback* = proc(
    userData: pointer,
    uri: cstring,
    localName: cstring,
    qName: cstring,
    attrs: AttributesPtr,
  ) {.cdecl.}
  EndElementCallback* =
    proc(userData: pointer, uri: cstring, localName: cstring, qName: cstring) {.cdecl.}
  CharactersCallback* =
    proc(userData: pointer, chars: cstring, length: XMLSize) {.cdecl.}
  IgnorableWhitespaceCallback* =
    proc(userData: pointer, chars: cstring, length: XMLSize) {.cdecl.}
  ProcessingInstructionCallback* =
    proc(userData: pointer, target: cstring, data: cstring) {.cdecl.}
  StartPrefixMappingCallback* =
    proc(userData: pointer, prefix: cstring, uri: cstring) {.cdecl.}
  EndPrefixMappingCallback* = proc(userData: pointer, prefix: cstring) {.cdecl.}

{.push header: nimContentHandlerHeader.}

# Constructor/destructor
proc newNimContentHandlerImpl(): NimContentHandlerPtr {.
  importcpp: "new NimContentHandler()"
.}

proc deleteNimContentHandler*(handler: NimContentHandlerPtr) {.importcpp: "delete #".}

# Callback setters
proc setUserData*(
  handler: NimContentHandlerPtr, data: pointer
) {.importcpp: "#->setUserData(#)".}

proc setStartDocumentCallback*(
  handler: NimContentHandlerPtr, cb: StartDocumentCallback
) {.importcpp: "#->setStartDocumentCallback(#)".}

proc setEndDocumentCallback*(
  handler: NimContentHandlerPtr, cb: EndDocumentCallback
) {.importcpp: "#->setEndDocumentCallback(#)".}

proc setStartElementCallback*(
  handler: NimContentHandlerPtr, cb: StartElementCallback
) {.importcpp: "#->setStartElementCallback(#)".}

proc setEndElementCallback*(
  handler: NimContentHandlerPtr, cb: EndElementCallback
) {.importcpp: "#->setEndElementCallback(#)".}

proc setCharactersCallback*(
  handler: NimContentHandlerPtr, cb: CharactersCallback
) {.importcpp: "#->setCharactersCallback(#)".}

proc setIgnorableWhitespaceCallback*(
  handler: NimContentHandlerPtr, cb: IgnorableWhitespaceCallback
) {.importcpp: "#->setIgnorableWhitespaceCallback(#)".}

proc setProcessingInstructionCallback*(
  handler: NimContentHandlerPtr, cb: ProcessingInstructionCallback
) {.importcpp: "#->setProcessingInstructionCallback(#)".}

proc setStartPrefixMappingCallback*(
  handler: NimContentHandlerPtr, cb: StartPrefixMappingCallback
) {.importcpp: "#->setStartPrefixMappingCallback(#)".}

proc setEndPrefixMappingCallback*(
  handler: NimContentHandlerPtr, cb: EndPrefixMappingCallback
) {.importcpp: "#->setEndPrefixMappingCallback(#)".}

# Cast to ContentHandler* for setContentHandler
proc toContentHandler*(
  handler: NimContentHandlerPtr
): ptr ContentHandler {.importcpp: "static_cast<xercesc::ContentHandler*>(#)".}

# Get locator
proc getLocatorImpl(
  handler: NimContentHandlerPtr
): LocatorPtr {.importcpp: "const_cast<xercesc::Locator*>(#->getLocator())".}

{.pop.}

# High-level SAX Handler wrapper

type
  SAXAttribute* = object ## Represents a single attribute in SAX parsing
    uri*: string
    localName*: string
    qName*: string
    value*: string
    attrType*: string

  SAXHandlerObj* = object ## High-level SAX event handler with Nim closures
    impl*: NimContentHandlerPtr
    onStartDocument*: proc()
    onEndDocument*: proc()
    onStartElement*: proc(uri, localName, qName: string, attrs: seq[SAXAttribute])
    onEndElement*: proc(uri, localName, qName: string)
    onCharacters*: proc(content: string)
    onIgnorableWhitespace*: proc(content: string)
    onProcessingInstruction*: proc(target, data: string)
    onStartPrefixMapping*: proc(prefix, uri: string)
    onEndPrefixMapping*: proc(prefix: string)

  SAXHandler* = ref SAXHandlerObj

proc `=destroy`(handler: SAXHandlerObj) =
  if handler.impl != nil:
    deleteNimContentHandler(handler.impl)

# Convert Attributes to seq[SAXAttribute]
proc toSeq*(attrs: AttributesPtr): seq[SAXAttribute] =
  if attrs == nil:
    return @[]
  let len = attrs.getLength()
  result = newSeq[SAXAttribute](len)
  for i in 0 ..< len:
    result[i] = SAXAttribute(
      uri: $attrs.getURI(i),
      localName: $attrs.getLocalName(i),
      qName: $attrs.getQName(i),
      value: $attrs.getValue(i),
      attrType: $attrs.getType(i),
    )

# C callbacks that delegate to SAXHandler closures
proc saxStartDocument(userData: pointer) {.cdecl.} =
  let handler = cast[SAXHandler](userData)
  if handler.onStartDocument != nil:
    handler.onStartDocument()

proc saxEndDocument(userData: pointer) {.cdecl.} =
  let handler = cast[SAXHandler](userData)
  if handler.onEndDocument != nil:
    handler.onEndDocument()

proc saxStartElement(
    userData: pointer,
    uri: cstring,
    localName: cstring,
    qName: cstring,
    attrs: AttributesPtr,
) {.cdecl.} =
  let handler = cast[SAXHandler](userData)
  if handler.onStartElement != nil:
    handler.onStartElement($uri, $localName, $qName, attrs.toSeq())

proc saxEndElement(
    userData: pointer, uri: cstring, localName: cstring, qName: cstring
) {.cdecl.} =
  let handler = cast[SAXHandler](userData)
  if handler.onEndElement != nil:
    handler.onEndElement($uri, $localName, $qName)

proc saxCharacters(userData: pointer, chars: cstring, length: XMLSize) {.cdecl.} =
  let handler = cast[SAXHandler](userData)
  if handler.onCharacters != nil:
    handler.onCharacters($chars)

proc saxIgnorableWhitespace(
    userData: pointer, chars: cstring, length: XMLSize
) {.cdecl.} =
  let handler = cast[SAXHandler](userData)
  if handler.onIgnorableWhitespace != nil:
    handler.onIgnorableWhitespace($chars)

proc saxProcessingInstruction(
    userData: pointer, target: cstring, data: cstring
) {.cdecl.} =
  let handler = cast[SAXHandler](userData)
  if handler.onProcessingInstruction != nil:
    handler.onProcessingInstruction($target, $data)

proc saxStartPrefixMapping(userData: pointer, prefix: cstring, uri: cstring) {.cdecl.} =
  let handler = cast[SAXHandler](userData)
  if handler.onStartPrefixMapping != nil:
    handler.onStartPrefixMapping($prefix, $uri)

proc saxEndPrefixMapping(userData: pointer, prefix: cstring) {.cdecl.} =
  let handler = cast[SAXHandler](userData)
  if handler.onEndPrefixMapping != nil:
    handler.onEndPrefixMapping($prefix)

proc newSAXHandler*(): SAXHandler =
  ## Create a new SAX handler. Set callback procs before parsing.
  result = SAXHandler(impl: newNimContentHandlerImpl())
  # Set up C++ callbacks to call our C callbacks
  result.impl.setUserData(cast[pointer](result))
  result.impl.setStartDocumentCallback(saxStartDocument)
  result.impl.setEndDocumentCallback(saxEndDocument)
  result.impl.setStartElementCallback(saxStartElement)
  result.impl.setEndElementCallback(saxEndElement)
  result.impl.setCharactersCallback(saxCharacters)
  result.impl.setIgnorableWhitespaceCallback(saxIgnorableWhitespace)
  result.impl.setProcessingInstructionCallback(saxProcessingInstruction)
  result.impl.setStartPrefixMappingCallback(saxStartPrefixMapping)
  result.impl.setEndPrefixMappingCallback(saxEndPrefixMapping)

proc destroy*(handler: SAXHandler) =
  ## Explicitly clean up SAX handler resources.
  ## Note: Resources are automatically freed when the handler is garbage collected,
  ## so calling this is optional but can be used for deterministic cleanup.
  if handler.impl != nil:
    deleteNimContentHandler(handler.impl)
    handler.impl = nil

proc getLocator*(handler: SAXHandler): LocatorPtr =
  ## Get the document locator (available during parsing)
  if handler.impl != nil:
    result = handler.impl.getLocatorImpl()

# Convenience parsing functions

proc parseWithSAX*(reader: SAX2XMLReaderPtr, handler: SAXHandler, source: cstring) =
  ## Parse an XML file using SAX with the given handler
  reader.setContentHandler(handler.impl.toContentHandler())
  reader.parse(source)

proc parseWithSAX*(
    reader: SAX2XMLReaderPtr, handler: SAXHandler, source: InputSourcePtr
) =
  ## Parse from InputSource using SAX with the given handler
  reader.setContentHandler(handler.impl.toContentHandler())
  reader.parse(source)

proc saxParseFile*(filePath: string, handler: SAXHandler) =
  ## Convenience function to parse a file with SAX
  let reader = XMLReaderFactory.createXMLReader()
  defer:
    deleteSAX2XMLReader(reader)
  reader.parseWithSAX(handler, filePath.cstring)

proc saxParseString*(xmlContent: string, handler: SAXHandler) =
  ## Convenience function to parse an XML string with SAX
  let reader = XMLReaderFactory.createXMLReader()
  defer:
    deleteSAX2XMLReader(reader)

  let src = newMemBufInputSource(
    cast[ptr XMLByte](xmlContent.cstring), xmlContent.len.XMLSize, "xmlBuffer"
  )
  defer:
    deleteMemBufInputSource(src)

  reader.parseWithSAX(handler, cast[InputSourcePtr](src))
