# Nim bindings for Apache Xerces-C++ XML parser
#
# This module provides Nim bindings for the Xerces-C++ XML parsing library,
# supporting both DOM and SAX parsing approaches.
#
# Example usage:
#
# .. code-block:: nim
#   import nim_xerces
#
#   withXerces:
#     let parser = newXercesDOMParser()
#     defer: deleteXercesDOMParser(parser)
#
#     parser.parse("example.xml")
#     let doc = parser.getDocument()
#
#     if doc != nil:
#       let root = doc.getDocumentElement()
#       echo "Root element: ", $root.getTagName()

import
  lowlevel/[
    types, platform, dom, parser, sax, utils, serializer, exceptions, safe_parser,
    error_handler,
  ]

export
  types, platform, dom, parser, sax, utils, serializer, exceptions, safe_parser,
  error_handler

# Note: XPath is NOT exported by default due to Xerces-C++ limitations.
# Import nim_xerces/xpath explicitly if needed (not recommended).
# See xpath.nim for details on limitations.

# High-level convenience API

proc parseXMLFile*(filePath: string): DOMDocumentPtr =
  ## Parse an XML file and return the DOM document.
  ## The caller is responsible for releasing the document.
  ## Use withXerces template to ensure proper initialization.
  let parser = newXercesDOMParser()
  defer:
    deleteXercesDOMParser(parser)
  parser.parse(filePath.cstring)
  result = parser.adoptDocument()

proc parseXMLString*(xmlContent: string, namespaceAware: bool = false): DOMDocumentPtr =
  ## Parse an XML string and return the DOM document.
  ## Set namespaceAware=true to enable namespace processing.
  ## The caller is responsible for releasing the document.
  ## Use withXerces template to ensure proper initialization.
  let parser = newXercesDOMParser()
  defer:
    deleteXercesDOMParser(parser)

  if namespaceAware:
    parser.setDoNamespaces(true)

  let src = newMemBufInputSource(
    cast[ptr XMLByte](xmlContent.cstring), xmlContent.len.XMLSize, "xmlBuffer"
  )
  defer:
    deleteMemBufInputSource(src)

  parser.parse(cast[InputSourcePtr](src))
  result = parser.adoptDocument()

# Convenience function to get element text content as Nim string
proc textContent*(node: DOMNodePtr): string =
  ## Get the text content of a node as a Nim string
  if node == nil:
    return ""
  let content = node.getTextContent()
  result = $content

# Convenience function to get attribute value as Nim string
proc attr*(elem: DOMElementPtr, name: string): string =
  ## Get an attribute value as a Nim string
  if elem == nil:
    return ""
  withXMLCh(xmlName, name):
    let value = elem.getAttribute(xmlName)
    result = $value

# Convenience function to set attribute value from Nim string
proc setAttr*(elem: DOMElementPtr, name, value: string) =
  ## Set an attribute value from Nim strings (without namespace)
  if elem != nil:
    withXMLCh(xmlName, name):
      withXMLCh(xmlValue, value):
        elem.setAttribute(xmlName, xmlValue)

# Namespace-aware attribute helpers

proc attrNS*(elem: DOMElementPtr, namespaceURI, localName: string): string =
  ## Get an attribute value by namespace URI and local name
  if elem == nil:
    return ""
  withXMLCh(xmlNS, namespaceURI):
    withXMLCh(xmlLocal, localName):
      let value = elem.getAttributeNS(xmlNS, xmlLocal)
      result = $value

proc setAttrNS*(elem: DOMElementPtr, namespaceURI, qualifiedName, value: string) =
  ## Set an attribute value with namespace
  ## qualifiedName should include prefix if needed (e.g., "prefix:localName")
  if elem != nil:
    withXMLCh(xmlNS, namespaceURI):
      withXMLCh(xmlQName, qualifiedName):
        withXMLCh(xmlValue, value):
          elem.setAttributeNS(xmlNS, xmlQName, xmlValue)

proc hasAttrNS*(elem: DOMElementPtr, namespaceURI, localName: string): bool =
  ## Check if element has an attribute with namespace
  if elem == nil:
    return false
  withXMLCh(xmlNS, namespaceURI):
    withXMLCh(xmlLocal, localName):
      result = elem.hasAttributeNS(xmlNS, xmlLocal)

proc removeAttrNS*(elem: DOMElementPtr, namespaceURI, localName: string) =
  ## Remove an attribute by namespace URI and local name
  if elem != nil:
    withXMLCh(xmlNS, namespaceURI):
      withXMLCh(xmlLocal, localName):
        elem.removeAttributeNS(xmlNS, xmlLocal)

# Namespace-aware element finders
proc findElementsByTagNameNS*(
    doc: DOMDocumentPtr, namespaceURI, localName: string
): seq[DOMElementPtr] =
  ## Find all elements with the given namespace URI and local name
  if doc == nil:
    return
  withXMLCh(xmlNS, namespaceURI):
    withXMLCh(xmlLocal, localName):
      let nodeList = doc.getElementsByTagNameNS(xmlNS, xmlLocal)
      if nodeList != nil:
        for node in nodeList:
          result.add(cast[DOMElementPtr](node))

proc findElementsByTagNameNS*(
    elem: DOMElementPtr, namespaceURI, localName: string
): seq[DOMElementPtr] =
  ## Find all descendant elements with the given namespace URI and local name
  if elem == nil:
    return
  withXMLCh(xmlNS, namespaceURI):
    withXMLCh(xmlLocal, localName):
      let nodeList = elem.getElementsByTagNameNS(xmlNS, xmlLocal)
      if nodeList != nil:
        for node in nodeList:
          result.add(cast[DOMElementPtr](node))

iterator getElementsByTagNameNS*(
    doc: DOMDocumentPtr, namespaceURI, localName: string
): DOMElementPtr =
  ## Iterate over elements by namespace URI and local name
  if doc != nil:
    withXMLCh(xmlNS, namespaceURI):
      withXMLCh(xmlLocal, localName):
        let nodeList = doc.getElementsByTagNameNS(xmlNS, xmlLocal)
        if nodeList != nil:
          for node in nodeList:
            yield cast[DOMElementPtr](node)

iterator getElementsByTagNameNS*(
    elem: DOMElementPtr, namespaceURI, localName: string
): DOMElementPtr =
  ## Iterate over descendant elements by namespace URI and local name
  if elem != nil:
    withXMLCh(xmlNS, namespaceURI):
      withXMLCh(xmlLocal, localName):
        let nodeList = elem.getElementsByTagNameNS(xmlNS, xmlLocal)
        if nodeList != nil:
          for node in nodeList:
            yield cast[DOMElementPtr](node)

# Node namespace info helpers
proc namespaceURI*(node: DOMNodePtr): string =
  ## Get the namespace URI of a node
  if node == nil:
    return ""
  result = $node.getNamespaceURI()

proc prefix*(node: DOMNodePtr): string =
  ## Get the namespace prefix of a node
  if node == nil:
    return ""
  result = $node.getPrefix()

proc localName*(node: DOMNodePtr): string =
  ## Get the local name of a node (without prefix)
  if node == nil:
    return ""
  result = $node.getLocalName()

# Get tag name as Nim string
proc tagName*(elem: DOMElementPtr): string =
  ## Get the tag name of an element as a Nim string
  if elem == nil:
    return ""
  result = $elem.getTagName()

# Get node name as Nim string
proc nodeName*(node: DOMNodePtr): string =
  ## Get the node name as a Nim string
  if node == nil:
    return ""
  result = $node.getNodeName()

# Get node value as Nim string
proc nodeValue*(node: DOMNodePtr): string =
  ## Get the node value as a Nim string
  if node == nil:
    return ""
  result = $node.getNodeValue()

# Find elements by tag name (returns a seq)
proc findElementsByTagName*(doc: DOMDocumentPtr, tagName: string): seq[DOMElementPtr] =
  ## Find all elements with the given tag name
  if doc == nil:
    return
  withXMLCh(xmlTag, tagName):
    let nodeList = doc.getElementsByTagName(xmlTag)
    if nodeList != nil:
      for node in nodeList:
        result.add(cast[DOMElementPtr](node))

proc findElementsByTagName*(elem: DOMElementPtr, tagName: string): seq[DOMElementPtr] =
  ## Find all descendant elements with the given tag name
  if elem == nil:
    return
  withXMLCh(xmlTag, tagName):
    let nodeList = elem.getElementsByTagName(xmlTag)
    if nodeList != nil:
      for node in nodeList:
        result.add(cast[DOMElementPtr](node))

# Iterator for element children only
iterator elements*(node: DOMNodePtr): DOMElementPtr =
  ## Iterate over element children only (skipping text nodes, comments, etc.)
  if node != nil:
    var child = node.getFirstChild()
    while child != nil:
      if child.getNodeType() == ELEMENT_NODE:
        yield cast[DOMElementPtr](child)
      child = child.getNextSibling()

# Iterator for elements by tag name
iterator getElementsByTagName*(doc: DOMDocumentPtr, tagName: string): DOMElementPtr =
  ## Iterate over elements by tag name
  if doc != nil:
    withXMLCh(xmlTag, tagName):
      let nodeList = doc.getElementsByTagName(xmlTag)
      if nodeList != nil:
        for node in nodeList:
          yield cast[DOMElementPtr](node)

iterator getElementsByTagName*(elem: DOMElementPtr, tagName: string): DOMElementPtr =
  ## Iterate over descendant elements by tag name
  if elem != nil:
    withXMLCh(xmlTag, tagName):
      let nodeList = elem.getElementsByTagName(xmlTag)
      if nodeList != nil:
        for node in nodeList:
          yield cast[DOMElementPtr](node)

# Convenience function to check if an element has an attribute
proc hasAttr*(elem: DOMElementPtr, name: string): bool =
  ## Check if element has an attribute (without namespace)
  if elem == nil:
    return false
  withXMLCh(xmlName, name):
    result = elem.hasAttribute(xmlName)

# Get first child element
proc firstElement*(node: DOMNodePtr): DOMElementPtr =
  ## Get the first child element (skipping non-element nodes)
  if node == nil:
    return nil
  var child = node.getFirstChild()
  while child != nil:
    if child.getNodeType() == ELEMENT_NODE:
      return cast[DOMElementPtr](child)
    child = child.getNextSibling()
  return nil

# Get next sibling element
proc nextElement*(node: DOMNodePtr): DOMElementPtr =
  ## Get the next sibling element (skipping non-element nodes)
  if node == nil:
    return nil
  var sibling = node.getNextSibling()
  while sibling != nil:
    if sibling.getNodeType() == ELEMENT_NODE:
      return cast[DOMElementPtr](sibling)
    sibling = sibling.getNextSibling()
  return nil

# Serialization helpers
proc toXMLString*(node: DOMNodePtr): string =
  ## Serialize a DOM node to an XML string
  if node == nil:
    return ""

  withXMLCh(features, "LS"):
    let impl = DOMImplementationRegistry.getDOMImplementation(features)
    if impl == nil:
      return ""

    let lsImpl = impl.toLSImpl()
    let serializer = lsImpl.createLSSerializer()
    if serializer == nil:
      return ""
    defer:
      serializer.release()

    let xmlStr = serializer.writeToString(node)
    if xmlStr != nil:
      var xmlStrVar = xmlStr
      defer:
        releaseXMLCh(xmlStrVar)
      result = $xmlStr

proc toXMLString*(doc: DOMDocumentPtr): string =
  ## Serialize a DOM document to an XML string
  toXMLString(cast[DOMNodePtr](doc))

proc toXMLString*(elem: DOMElementPtr): string =
  ## Serialize a DOM element to an XML string
  toXMLString(cast[DOMNodePtr](elem))

proc toPrettyXMLString*(node: DOMNodePtr): string =
  ## Serialize a DOM node to a pretty-printed XML string
  if node == nil:
    return ""

  withXMLCh(features, "LS"):
    let impl = DOMImplementationRegistry.getDOMImplementation(features)
    if impl == nil:
      return ""

    let lsImpl = impl.toLSImpl()
    let serializer = lsImpl.createLSSerializer()
    if serializer == nil:
      return ""
    defer:
      serializer.release()

    # Enable pretty printing
    let config = serializer.getDomConfig()
    withXMLCh(formatPretty, "format-pretty-print"):
      if config.canSetParameter(formatPretty, true):
        config.setParameter(formatPretty, true)

    let xmlStr = serializer.writeToString(node)
    if xmlStr != nil:
      var xmlStrVar = xmlStr
      defer:
        releaseXMLCh(xmlStrVar)
      result = $xmlStr

proc toPrettyXMLString*(doc: DOMDocumentPtr): string =
  ## Serialize a DOM document to a pretty-printed XML string
  toPrettyXMLString(cast[DOMNodePtr](doc))

proc toPrettyXMLString*(elem: DOMElementPtr): string =
  ## Serialize a DOM element to a pretty-printed XML string
  toPrettyXMLString(cast[DOMNodePtr](elem))

# Error handler helpers
proc setErrorHandler*(parser: XercesDOMParserPtr, handler: XercesErrorHandler) =
  ## Set an error handler on the parser to collect parse errors
  if handler.impl != nil:
    parser.setErrorHandler(handler.impl.toErrorHandler())
