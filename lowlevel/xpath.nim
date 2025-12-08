import types, dom

# XPath support for Xerces DOM
#
# WARNING: Xerces-C++ has only PARTIAL XPath 1 implementation!
# The XPath engine is designed for XML Schema identity constraints only.
#
# Limitations:
#   - DOMElement nodes only
#   - No predicate testing (e.g., //book[@id='1'] will NOT work)
#   - "//" operator allowed only as the initial step
#   - Most result types throw NOT_SUPPORTED_ERR
#
# For full XPath support, consider:
#   - XQilla (https://xqilla.sourceforge.net/)
#   - Apache Xalan C++ (https://xalan.apache.org/xalan-c/)
#
# The bindings below are provided for completeness but general XPath
# evaluation will fail with DOMException or DOMXPathException.

{.push header: "<xercesc/dom/DOMXPathResult.hpp>".}

type
  DOMXPathResultType* {.
    importcpp: "xercesc::DOMXPathResult::ResultType", size: sizeof(cint)
  .} = enum
    ANY_TYPE = 0
    NUMBER_TYPE = 1
    STRING_TYPE = 2
    BOOLEAN_TYPE = 3
    UNORDERED_NODE_ITERATOR_TYPE = 4
    ORDERED_NODE_ITERATOR_TYPE = 5
    UNORDERED_NODE_SNAPSHOT_TYPE = 6
    ORDERED_NODE_SNAPSHOT_TYPE = 7
    ANY_UNORDERED_NODE_TYPE = 8
    FIRST_ORDERED_NODE_TYPE = 9

  DOMXPathResult* {.importcpp: "xercesc::DOMXPathResult".} = object
  DOMXPathResultPtr* = ptr DOMXPathResult

# DOMXPathResult methods
proc getResultType*(
  result: DOMXPathResultPtr
): DOMXPathResultType {.importcpp: "#->getResultType()".}

proc getBooleanValue*(
  result: DOMXPathResultPtr
): bool {.importcpp: "#->getBooleanValue()".}

proc getNumberValue*(
  result: DOMXPathResultPtr
): cdouble {.importcpp: "#->getNumberValue()".}

proc getStringValue*(
  result: DOMXPathResultPtr
): ptr XMLCh {.importcpp: "const_cast<XMLCh*>(#->getStringValue())".}

proc getNodeValue*(
  result: DOMXPathResultPtr
): DOMNodePtr {.importcpp: "#->getNodeValue()".}

proc iterateNext*(result: DOMXPathResultPtr): bool {.importcpp: "#->iterateNext()".}
proc snapshotItem*(
  result: DOMXPathResultPtr, index: XMLSize
): bool {.importcpp: "#->snapshotItem(#)".}

proc getSnapshotLength*(
  result: DOMXPathResultPtr
): XMLSize {.importcpp: "#->getSnapshotLength()".}

proc getInvalidIteratorState*(
  result: DOMXPathResultPtr
): bool {.importcpp: "#->getInvalidIteratorState()".}

proc release*(result: DOMXPathResultPtr) {.importcpp: "#->release()".}

{.pop.}

{.push header: "<xercesc/dom/DOMXPathNSResolver.hpp>".}

type
  DOMXPathNSResolver* {.importcpp: "xercesc::DOMXPathNSResolver".} = object
  DOMXPathNSResolverPtr* = ptr DOMXPathNSResolver

proc lookupNamespaceURI*(
  resolver: DOMXPathNSResolverPtr, prefix: ptr XMLCh
): ptr XMLCh {.importcpp: "const_cast<XMLCh*>(#->lookupNamespaceURI(#))".}

proc lookupPrefix*(
  resolver: DOMXPathNSResolverPtr, namespaceURI: ptr XMLCh
): ptr XMLCh {.importcpp: "const_cast<XMLCh*>(#->lookupPrefix(#))".}

proc addNamespaceBinding*(
  resolver: DOMXPathNSResolverPtr, prefix: ptr XMLCh, uri: ptr XMLCh
) {.importcpp: "#->addNamespaceBinding(#, #)".}

proc release*(resolver: DOMXPathNSResolverPtr) {.importcpp: "#->release()".}

{.pop.}

{.push header: "<xercesc/dom/DOMXPathExpression.hpp>".}

type
  DOMXPathExpression* {.importcpp: "xercesc::DOMXPathExpression".} = object
  DOMXPathExpressionPtr* = ptr DOMXPathExpression

proc evaluate*(
  expr: DOMXPathExpressionPtr,
  contextNode: DOMNodePtr,
  resultType: DOMXPathResultType,
  result: DOMXPathResultPtr = nil,
): DOMXPathResultPtr {.importcpp: "#->evaluate(#, #, #)".}

proc release*(expr: DOMXPathExpressionPtr) {.importcpp: "#->release()".}

{.pop.}

{.push header: "<xercesc/dom/DOMXPathEvaluator.hpp>".}

type
  DOMXPathEvaluator* {.importcpp: "xercesc::DOMXPathEvaluator".} = object
  DOMXPathEvaluatorPtr* = ptr DOMXPathEvaluator

proc createExpression*(
  evaluator: DOMXPathEvaluatorPtr,
  expression: ptr XMLCh,
  resolver: DOMXPathNSResolverPtr = nil,
): DOMXPathExpressionPtr {.importcpp: "#->createExpression(#, #)".}

proc createNSResolver*(
  evaluator: DOMXPathEvaluatorPtr, nodeResolver: DOMNodePtr
): DOMXPathNSResolverPtr {.importcpp: "#->createNSResolver(#)".}

proc evaluate*(
  evaluator: DOMXPathEvaluatorPtr,
  expression: ptr XMLCh,
  contextNode: DOMNodePtr,
  resolver: DOMXPathNSResolverPtr,
  resultType: DOMXPathResultType,
  result: DOMXPathResultPtr = nil,
): DOMXPathResultPtr {.importcpp: "#->evaluate(#, #, #, #, #)".}

{.pop.}

# Cast DOMDocument to DOMXPathEvaluator (DOMDocument implements DOMXPathEvaluator)
# Use dynamic_cast for safety - returns nullptr if not supported
proc toXPathEvaluator*(
  doc: DOMDocumentPtr
): DOMXPathEvaluatorPtr {.importcpp: "dynamic_cast<xercesc::DOMXPathEvaluator*>(#)".}

# Check if XPath is supported on the document's implementation
{.push header: "<xercesc/dom/DOMImplementation.hpp>".}
proc hasFeature*(
  impl: DOMImplementationPtr, feature: ptr XMLCh, version: ptr XMLCh
): bool {.importcpp: "#->hasFeature(#, #)".}

{.pop.}

proc supportsXPath*(doc: DOMDocumentPtr): bool =
  ## Check if the document's implementation supports XPath
  if doc == nil:
    return false
  let impl = doc.getImplementation()
  if impl == nil:
    return false
  # Check for XPath 3.0 support (DOM Level 3)
  var feature: ptr XMLCh
  var version: ptr XMLCh
  {.
    emit:
      """
  static const XMLCh gXPath[] = { 'X', 'P', 'a', 't', 'h', 0 };
  static const XMLCh gVersion[] = { '3', '.', '0', 0 };
  `feature` = (XMLCh*)gXPath;
  `version` = (XMLCh*)gVersion;
  """
  .}
  result = impl.hasFeature(feature, version)

# Iterator for XPath result nodes (snapshot type)
iterator snapshotNodes*(result: DOMXPathResultPtr): DOMNodePtr =
  ## Iterate over nodes in a snapshot result
  if result != nil:
    let len = result.getSnapshotLength()
    for i in 0.XMLSize ..< len:
      if result.snapshotItem(i):
        let node = result.getNodeValue()
        if node != nil:
          yield node

# Iterator for XPath result nodes (iterator type)
iterator iterNodes*(result: DOMXPathResultPtr): DOMNodePtr =
  ## Iterate over nodes in an iterator result
  if result != nil:
    while result.iterateNext():
      let node = result.getNodeValue()
      if node != nil:
        yield node
