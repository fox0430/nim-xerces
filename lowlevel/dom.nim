import types

{.push header: "<xercesc/dom/DOM.hpp>".}

type
  DOMNodeType* {.importcpp: "xercesc::DOMNode::NodeType", size: sizeof(cshort).} = enum
    ELEMENT_NODE = 1
    ATTRIBUTE_NODE = 2
    TEXT_NODE = 3
    CDATA_SECTION_NODE = 4
    ENTITY_REFERENCE_NODE = 5
    ENTITY_NODE = 6
    PROCESSING_INSTRUCTION_NODE = 7
    COMMENT_NODE = 8
    DOCUMENT_NODE = 9
    DOCUMENT_TYPE_NODE = 10
    DOCUMENT_FRAGMENT_NODE = 11
    NOTATION_NODE = 12

  DOMNode* {.importcpp: "xercesc::DOMNode", inheritable.} = object
  DOMNodePtr* = ptr DOMNode

  DOMDocument* {.importcpp: "xercesc::DOMDocument".} = object of DOMNode
  DOMDocumentPtr* = ptr DOMDocument

  DOMElement* {.importcpp: "xercesc::DOMElement".} = object of DOMNode
  DOMElementPtr* = ptr DOMElement

  DOMText* {.importcpp: "xercesc::DOMText".} = object of DOMNode
  DOMTextPtr* = ptr DOMText

  DOMAttr* {.importcpp: "xercesc::DOMAttr".} = object of DOMNode
  DOMAttrPtr* = ptr DOMAttr

  DOMComment* {.importcpp: "xercesc::DOMComment".} = object of DOMNode
  DOMCommentPtr* = ptr DOMComment

  DOMCDATASection* {.importcpp: "xercesc::DOMCDATASection".} = object of DOMText
  DOMCDATASectionPtr* = ptr DOMCDATASection

  DOMProcessingInstruction* {.importcpp: "xercesc::DOMProcessingInstruction".} = object of DOMNode
  DOMProcessingInstructionPtr* = ptr DOMProcessingInstruction

  DOMDocumentFragment* {.importcpp: "xercesc::DOMDocumentFragment".} = object of DOMNode
  DOMDocumentFragmentPtr* = ptr DOMDocumentFragment

  DOMDocumentType* {.importcpp: "xercesc::DOMDocumentType".} = object of DOMNode
  DOMDocumentTypePtr* = ptr DOMDocumentType

  DOMNodeList* {.importcpp: "xercesc::DOMNodeList".} = object
  DOMNodeListPtr* = ptr DOMNodeList

  DOMNamedNodeMap* {.importcpp: "xercesc::DOMNamedNodeMap".} = object
  DOMNamedNodeMapPtr* = ptr DOMNamedNodeMap

  DOMImplementation* {.importcpp: "xercesc::DOMImplementation".} = object
  DOMImplementationPtr* = ptr DOMImplementation

# DOMNode methods
proc getNodeName*(node: DOMNodePtr): ptr XMLCh {.importcpp: "const_cast<XMLCh*>(#->getNodeName())".}
proc getNodeValue*(node: DOMNodePtr): ptr XMLCh {.importcpp: "const_cast<XMLCh*>(#->getNodeValue())".}
proc getNodeType*(node: DOMNodePtr): DOMNodeType {.importcpp: "#->getNodeType()".}
proc getParentNode*(node: DOMNodePtr): DOMNodePtr {.importcpp: "#->getParentNode()".}
proc getChildNodes*(
  node: DOMNodePtr
): DOMNodeListPtr {.importcpp: "#->getChildNodes()".}

proc getFirstChild*(node: DOMNodePtr): DOMNodePtr {.importcpp: "#->getFirstChild()".}
proc getLastChild*(node: DOMNodePtr): DOMNodePtr {.importcpp: "#->getLastChild()".}
proc getPreviousSibling*(
  node: DOMNodePtr
): DOMNodePtr {.importcpp: "#->getPreviousSibling()".}

proc getNextSibling*(node: DOMNodePtr): DOMNodePtr {.importcpp: "#->getNextSibling()".}
proc getAttributes*(
  node: DOMNodePtr
): DOMNamedNodeMapPtr {.importcpp: "#->getAttributes()".}

proc getOwnerDocument*(
  node: DOMNodePtr
): DOMDocumentPtr {.importcpp: "#->getOwnerDocument()".}

proc hasChildNodes*(node: DOMNodePtr): bool {.importcpp: "#->hasChildNodes()".}
proc hasAttributes*(node: DOMNodePtr): bool {.importcpp: "#->hasAttributes()".}
proc getTextContent*(node: DOMNodePtr): ptr XMLCh {.importcpp: "const_cast<XMLCh*>(#->getTextContent())".}
proc setTextContent*(
  node: DOMNodePtr, textContent: ptr XMLCh
) {.importcpp: "#->setTextContent(#)".}

proc appendChild*(
  node: DOMNodePtr, newChild: DOMNodePtr
): DOMNodePtr {.importcpp: "#->appendChild(#)".}

proc insertBefore*(
  node: DOMNodePtr, newChild: DOMNodePtr, refChild: DOMNodePtr
): DOMNodePtr {.importcpp: "#->insertBefore(#, #)".}

proc removeChild*(
  node: DOMNodePtr, oldChild: DOMNodePtr
): DOMNodePtr {.importcpp: "#->removeChild(#)".}

proc replaceChild*(
  node: DOMNodePtr, newChild: DOMNodePtr, oldChild: DOMNodePtr
): DOMNodePtr {.importcpp: "#->replaceChild(#, #)".}

proc cloneNode*(
  node: DOMNodePtr, deep: bool
): DOMNodePtr {.importcpp: "#->cloneNode(#)".}

# Namespace-related methods
proc getNamespaceURI*(node: DOMNodePtr): ptr XMLCh {.importcpp: "const_cast<XMLCh*>(#->getNamespaceURI())".}
proc getPrefix*(node: DOMNodePtr): ptr XMLCh {.importcpp: "const_cast<XMLCh*>(#->getPrefix())".}
proc getLocalName*(node: DOMNodePtr): ptr XMLCh {.importcpp: "const_cast<XMLCh*>(#->getLocalName())".}

# DOMNodeList methods
proc getLength*(list: DOMNodeListPtr): XMLSize {.importcpp: "#->getLength()".}
proc item*(list: DOMNodeListPtr, index: XMLSize): DOMNodePtr {.importcpp: "#->item(#)".}

# DOMNamedNodeMap methods
proc getLength*(map: DOMNamedNodeMapPtr): XMLSize {.importcpp: "#->getLength()".}
proc item*(
  map: DOMNamedNodeMapPtr, index: XMLSize
): DOMNodePtr {.importcpp: "#->item(#)".}

proc getNamedItem*(
  map: DOMNamedNodeMapPtr, name: ptr XMLCh
): DOMNodePtr {.importcpp: "#->getNamedItem(#)".}

proc getNamedItemNS*(
  map: DOMNamedNodeMapPtr, namespaceURI: ptr XMLCh, localName: ptr XMLCh
): DOMNodePtr {.importcpp: "#->getNamedItemNS(#, #)".}

# DOMDocument methods
proc getDocumentElement*(
  doc: DOMDocumentPtr
): DOMElementPtr {.importcpp: "#->getDocumentElement()".}

proc getDoctype*(
  doc: DOMDocumentPtr
): DOMDocumentTypePtr {.importcpp: "#->getDoctype()".}

proc getImplementation*(
  doc: DOMDocumentPtr
): DOMImplementationPtr {.importcpp: "#->getImplementation()".}

proc createElement*(
  doc: DOMDocumentPtr, tagName: ptr XMLCh
): DOMElementPtr {.importcpp: "#->createElement(#)".}

proc createElementNS*(
  doc: DOMDocumentPtr, namespaceURI: ptr XMLCh, qualifiedName: ptr XMLCh
): DOMElementPtr {.importcpp: "#->createElementNS(#, #)".}

proc createTextNode*(
  doc: DOMDocumentPtr, data: ptr XMLCh
): DOMTextPtr {.importcpp: "#->createTextNode(#)".}

proc createComment*(
  doc: DOMDocumentPtr, data: ptr XMLCh
): DOMCommentPtr {.importcpp: "#->createComment(#)".}

proc createCDATASection*(
  doc: DOMDocumentPtr, data: ptr XMLCh
): DOMCDATASectionPtr {.importcpp: "#->createCDATASection(#)".}

proc createProcessingInstruction*(
  doc: DOMDocumentPtr, target: ptr XMLCh, data: ptr XMLCh
): DOMProcessingInstructionPtr {.importcpp: "#->createProcessingInstruction(#, #)".}

proc createAttribute*(
  doc: DOMDocumentPtr, name: ptr XMLCh
): DOMAttrPtr {.importcpp: "#->createAttribute(#)".}

proc createAttributeNS*(
  doc: DOMDocumentPtr, namespaceURI: ptr XMLCh, qualifiedName: ptr XMLCh
): DOMAttrPtr {.importcpp: "#->createAttributeNS(#, #)".}

proc createDocumentFragment*(
  doc: DOMDocumentPtr
): DOMDocumentFragmentPtr {.importcpp: "#->createDocumentFragment()".}

proc getElementById*(
  doc: DOMDocumentPtr, elementId: ptr XMLCh
): DOMElementPtr {.importcpp: "#->getElementById(#)".}

proc getElementsByTagName*(
  doc: DOMDocumentPtr, tagName: ptr XMLCh
): DOMNodeListPtr {.importcpp: "#->getElementsByTagName(#)".}

proc getElementsByTagNameNS*(
  doc: DOMDocumentPtr, namespaceURI: ptr XMLCh, localName: ptr XMLCh
): DOMNodeListPtr {.importcpp: "#->getElementsByTagNameNS(#, #)".}

proc importNode*(
  doc: DOMDocumentPtr, importedNode: DOMNodePtr, deep: bool
): DOMNodePtr {.importcpp: "#->importNode(#, #)".}

# DOMElement methods
proc getTagName*(elem: DOMElementPtr): ptr XMLCh {.importcpp: "const_cast<XMLCh*>(#->getTagName())".}
proc getAttribute*(
  elem: DOMElementPtr, name: ptr XMLCh
): ptr XMLCh {.importcpp: "const_cast<XMLCh*>(#->getAttribute(#))".}

proc getAttributeNS*(
  elem: DOMElementPtr, namespaceURI: ptr XMLCh, localName: ptr XMLCh
): ptr XMLCh {.importcpp: "const_cast<XMLCh*>(#->getAttributeNS(#, #))".}

proc getAttributeNode*(
  elem: DOMElementPtr, name: ptr XMLCh
): DOMAttrPtr {.importcpp: "#->getAttributeNode(#)".}

proc getAttributeNodeNS*(
  elem: DOMElementPtr, namespaceURI: ptr XMLCh, localName: ptr XMLCh
): DOMAttrPtr {.importcpp: "#->getAttributeNodeNS(#, #)".}

proc getElementsByTagName*(
  elem: DOMElementPtr, name: ptr XMLCh
): DOMNodeListPtr {.importcpp: "#->getElementsByTagName(#)".}

proc getElementsByTagNameNS*(
  elem: DOMElementPtr, namespaceURI: ptr XMLCh, localName: ptr XMLCh
): DOMNodeListPtr {.importcpp: "#->getElementsByTagNameNS(#, #)".}

proc hasAttribute*(
  elem: DOMElementPtr, name: ptr XMLCh
): bool {.importcpp: "#->hasAttribute(#)".}

proc hasAttributeNS*(
  elem: DOMElementPtr, namespaceURI: ptr XMLCh, localName: ptr XMLCh
): bool {.importcpp: "#->hasAttributeNS(#, #)".}

proc setAttribute*(
  elem: DOMElementPtr, name: ptr XMLCh, value: ptr XMLCh
) {.importcpp: "#->setAttribute(#, #)".}

proc setAttributeNS*(
  elem: DOMElementPtr,
  namespaceURI: ptr XMLCh,
  qualifiedName: ptr XMLCh,
  value: ptr XMLCh,
) {.importcpp: "#->setAttributeNS(#, #, #)".}

proc setAttributeNode*(
  elem: DOMElementPtr, newAttr: DOMAttrPtr
): DOMAttrPtr {.importcpp: "#->setAttributeNode(#)".}

proc setAttributeNodeNS*(
  elem: DOMElementPtr, newAttr: DOMAttrPtr
): DOMAttrPtr {.importcpp: "#->setAttributeNodeNS(#)".}

proc removeAttribute*(
  elem: DOMElementPtr, name: ptr XMLCh
) {.importcpp: "#->removeAttribute(#)".}

proc removeAttributeNS*(
  elem: DOMElementPtr, namespaceURI: ptr XMLCh, localName: ptr XMLCh
) {.importcpp: "#->removeAttributeNS(#, #)".}

proc removeAttributeNode*(
  elem: DOMElementPtr, oldAttr: DOMAttrPtr
): DOMAttrPtr {.importcpp: "#->removeAttributeNode(#)".}

# DOMAttr methods
proc getName*(attr: DOMAttrPtr): ptr XMLCh {.importcpp: "const_cast<XMLCh*>(#->getName())".}
proc getValue*(attr: DOMAttrPtr): ptr XMLCh {.importcpp: "const_cast<XMLCh*>(#->getValue())".}
proc setValue*(attr: DOMAttrPtr, value: ptr XMLCh) {.importcpp: "#->setValue(#)".}
proc getOwnerElement*(
  attr: DOMAttrPtr
): DOMElementPtr {.importcpp: "#->getOwnerElement()".}

proc getSpecified*(attr: DOMAttrPtr): bool {.importcpp: "#->getSpecified()".}

# DOMText methods
proc getData*(text: DOMTextPtr): ptr XMLCh {.importcpp: "const_cast<XMLCh*>(#->getData())".}
proc setData*(text: DOMTextPtr, data: ptr XMLCh) {.importcpp: "#->setData(#)".}
proc getLength*(text: DOMTextPtr): XMLSize {.importcpp: "#->getLength()".}
proc splitText*(
  text: DOMTextPtr, offset: XMLSize
): DOMTextPtr {.importcpp: "#->splitText(#)".}

# DOMComment methods
proc getData*(comment: DOMCommentPtr): ptr XMLCh {.importcpp: "const_cast<XMLCh*>(#->getData())".}
proc setData*(comment: DOMCommentPtr, data: ptr XMLCh) {.importcpp: "#->setData(#)".}
proc getLength*(comment: DOMCommentPtr): XMLSize {.importcpp: "#->getLength()".}

# DOMDocumentType methods
proc getName*(doctype: DOMDocumentTypePtr): ptr XMLCh {.importcpp: "const_cast<XMLCh*>(#->getName())".}
proc getPublicId*(
  doctype: DOMDocumentTypePtr
): ptr XMLCh {.importcpp: "const_cast<XMLCh*>(#->getPublicId())".}

proc getSystemId*(
  doctype: DOMDocumentTypePtr
): ptr XMLCh {.importcpp: "const_cast<XMLCh*>(#->getSystemId())".}

# DOMDocument memory management
proc release*(doc: DOMDocumentPtr) {.importcpp: "#->release()".}
  ## Release a DOMDocument obtained via adoptDocument().
  ## Do NOT call this on documents obtained via getDocument() - the parser owns those.

{.pop.}

# Safe type conversion helpers
proc toElement*(node: DOMNodePtr): DOMElementPtr =
  ## Safely convert DOMNode to DOMElement. Returns nil if node is not an element.
  if node != nil and node.getNodeType() == ELEMENT_NODE:
    result = cast[DOMElementPtr](node)

proc toText*(node: DOMNodePtr): DOMTextPtr =
  ## Safely convert DOMNode to DOMText. Returns nil if node is not a text node.
  if node != nil and node.getNodeType() == TEXT_NODE:
    result = cast[DOMTextPtr](node)

proc toAttr*(node: DOMNodePtr): DOMAttrPtr =
  ## Safely convert DOMNode to DOMAttr. Returns nil if node is not an attribute.
  if node != nil and node.getNodeType() == ATTRIBUTE_NODE:
    result = cast[DOMAttrPtr](node)

proc toComment*(node: DOMNodePtr): DOMCommentPtr =
  ## Safely convert DOMNode to DOMComment. Returns nil if node is not a comment.
  if node != nil and node.getNodeType() == COMMENT_NODE:
    result = cast[DOMCommentPtr](node)

proc toCDATASection*(node: DOMNodePtr): DOMCDATASectionPtr =
  ## Safely convert DOMNode to DOMCDATASection. Returns nil if node is not a CDATA section.
  if node != nil and node.getNodeType() == CDATA_SECTION_NODE:
    result = cast[DOMCDATASectionPtr](node)

proc toProcessingInstruction*(node: DOMNodePtr): DOMProcessingInstructionPtr =
  ## Safely convert DOMNode to DOMProcessingInstruction. Returns nil if not a PI.
  if node != nil and node.getNodeType() == PROCESSING_INSTRUCTION_NODE:
    result = cast[DOMProcessingInstructionPtr](node)

proc toDocument*(node: DOMNodePtr): DOMDocumentPtr =
  ## Safely convert DOMNode to DOMDocument. Returns nil if node is not a document.
  if node != nil and node.getNodeType() == DOCUMENT_NODE:
    result = cast[DOMDocumentPtr](node)

proc toDocumentFragment*(node: DOMNodePtr): DOMDocumentFragmentPtr =
  ## Safely convert DOMNode to DOMDocumentFragment. Returns nil if not a fragment.
  if node != nil and node.getNodeType() == DOCUMENT_FRAGMENT_NODE:
    result = cast[DOMDocumentFragmentPtr](node)

proc toDocumentType*(node: DOMNodePtr): DOMDocumentTypePtr =
  ## Safely convert DOMNode to DOMDocumentType. Returns nil if not a doctype.
  if node != nil and node.getNodeType() == DOCUMENT_TYPE_NODE:
    result = cast[DOMDocumentTypePtr](node)

# Type check helpers
proc isElement*(node: DOMNodePtr): bool =
  node != nil and node.getNodeType() == ELEMENT_NODE

proc isText*(node: DOMNodePtr): bool =
  node != nil and node.getNodeType() == TEXT_NODE

proc isAttribute*(node: DOMNodePtr): bool =
  node != nil and node.getNodeType() == ATTRIBUTE_NODE

proc isComment*(node: DOMNodePtr): bool =
  node != nil and node.getNodeType() == COMMENT_NODE

proc isCDATASection*(node: DOMNodePtr): bool =
  node != nil and node.getNodeType() == CDATA_SECTION_NODE

proc isDocument*(node: DOMNodePtr): bool =
  node != nil and node.getNodeType() == DOCUMENT_NODE

# Iterator for DOMNodeList
iterator items*(list: DOMNodeListPtr): DOMNodePtr =
  if list != nil:
    let len = list.getLength()
    for i in 0 ..< len:
      yield list.item(i)

# Iterator for DOMNamedNodeMap
iterator items*(map: DOMNamedNodeMapPtr): DOMNodePtr =
  if map != nil:
    let len = map.getLength()
    for i in 0 ..< len:
      yield map.item(i)

# Iterator for child nodes
iterator children*(node: DOMNodePtr): DOMNodePtr =
  if node != nil:
    var child = node.getFirstChild()
    while child != nil:
      yield child
      child = child.getNextSibling()
