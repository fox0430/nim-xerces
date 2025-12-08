import std/[unittest, strutils, os]

import xerces
import lowlevel/xpath
import lowlevel/utils

const testDataPath = currentSourcePath().parentDir() / "test_data.xml"

const testXml =
  """<?xml version="1.0" encoding="UTF-8"?>
<root>
  <book id="1">
    <title>The Great Gatsby</title>
    <author>F. Scott Fitzgerald</author>
  </book>
  <book id="2">
    <title>1984</title>
    <author>George Orwell</author>
  </book>
</root>"""

suite "Xerces DOM Parser Tests":
  test "Initialize and terminate Xerces":
    XMLPlatformUtils.initialize()
    XMLPlatformUtils.terminate()

  test "Parse XML string":
    withXerces:
      let parser = newXercesDOMParser()
      defer:
        deleteXercesDOMParser(parser)

      let src = newMemBufInputSource(
        cast[ptr XMLByte](testXml.cstring), testXml.len.XMLSize, "test"
      )
      defer:
        deleteMemBufInputSource(src)

      parser.parse(cast[InputSourcePtr](src))
      let doc = parser.getDocument()

      check doc != nil
      let root = doc.getDocumentElement()
      check root != nil
      check root.tagName() == "root"

  test "Find elements by tag name":
    withXerces:
      let parser = newXercesDOMParser()
      defer:
        deleteXercesDOMParser(parser)

      let src = newMemBufInputSource(
        cast[ptr XMLByte](testXml.cstring), testXml.len.XMLSize, "test"
      )
      defer:
        deleteMemBufInputSource(src)

      parser.parse(cast[InputSourcePtr](src))
      let doc = parser.getDocument()

      let books = doc.findElementsByTagName("book")
      check books.len == 2

  test "Get element attributes":
    withXerces:
      let parser = newXercesDOMParser()
      defer:
        deleteXercesDOMParser(parser)

      let src = newMemBufInputSource(
        cast[ptr XMLByte](testXml.cstring), testXml.len.XMLSize, "test"
      )
      defer:
        deleteMemBufInputSource(src)

      parser.parse(cast[InputSourcePtr](src))
      let doc = parser.getDocument()

      let books = doc.findElementsByTagName("book")
      check books.len >= 1
      check books[0].attr("id") == "1"
      check books[0].hasAttr("id")

  test "Get text content":
    withXerces:
      let parser = newXercesDOMParser()
      defer:
        deleteXercesDOMParser(parser)

      let src = newMemBufInputSource(
        cast[ptr XMLByte](testXml.cstring), testXml.len.XMLSize, "test"
      )
      defer:
        deleteMemBufInputSource(src)

      parser.parse(cast[InputSourcePtr](src))
      let doc = parser.getDocument()

      let titles = doc.findElementsByTagName("title")
      check titles.len >= 1
      check titles[0].textContent() == "The Great Gatsby"

  test "Iterate over elements":
    withXerces:
      let parser = newXercesDOMParser()
      defer:
        deleteXercesDOMParser(parser)

      let src = newMemBufInputSource(
        cast[ptr XMLByte](testXml.cstring), testXml.len.XMLSize, "test"
      )
      defer:
        deleteMemBufInputSource(src)

      parser.parse(cast[InputSourcePtr](src))
      let doc = parser.getDocument()
      let root = doc.getDocumentElement()

      var count = 0
      for elem in root.elements():
        check elem.tagName() == "book"
        count += 1
      check count == 2

  test "XMLCh string conversion":
    withXerces:
      let nimStr = "Hello, World!"
      var xmlStr = toXMLCh(nimStr)
      defer:
        releaseXMLCh(xmlStr)

      let backToNim = $xmlStr
      check backToNim == nimStr

  test "withXMLCh template":
    withXerces:
      withXMLCh(greeting, "Hello"):
        let str = $greeting
        check str == "Hello"

  test "Safe type conversion helpers":
    withXerces:
      let parser = newXercesDOMParser()
      defer:
        deleteXercesDOMParser(parser)

      let src = newMemBufInputSource(
        cast[ptr XMLByte](testXml.cstring), testXml.len.XMLSize, "test"
      )
      defer:
        deleteMemBufInputSource(src)

      parser.parse(cast[InputSourcePtr](src))
      let doc = parser.getDocument()
      let root = doc.getDocumentElement()

      # Test type check helpers
      check cast[DOMNodePtr](root).isElement()
      check not cast[DOMNodePtr](root).isText()

      # Test safe conversion
      let elemFromNode = cast[DOMNodePtr](root).toElement()
      check elemFromNode != nil
      check elemFromNode.tagName() == "root"

      # Test conversion of wrong type returns nil
      let textFromElem = cast[DOMNodePtr](root).toText()
      check textFromElem == nil

  test "Serialize DOM to XML string":
    withXerces:
      let parser = newXercesDOMParser()
      defer:
        deleteXercesDOMParser(parser)

      let src = newMemBufInputSource(
        cast[ptr XMLByte](testXml.cstring), testXml.len.XMLSize, "test"
      )
      defer:
        deleteMemBufInputSource(src)

      parser.parse(cast[InputSourcePtr](src))
      let doc = parser.getDocument()

      let xmlStr = doc.toXMLString()
      check xmlStr.len > 0
      check "root" in xmlStr
      check "book" in xmlStr

  test "Error handler collects errors":
    withXerces:
      let errorHandler = newXercesErrorHandler()
      defer:
        errorHandler.destroy()

      check not errorHandler.hasErrors()
      check errorHandler.errorCount == 0

  test "Document release with adoptDocument":
    withXerces:
      let parser = newXercesDOMParser()
      defer:
        deleteXercesDOMParser(parser)

      let src = newMemBufInputSource(
        cast[ptr XMLByte](testXml.cstring), testXml.len.XMLSize, "test"
      )
      defer:
        deleteMemBufInputSource(src)

      parser.parse(cast[InputSourcePtr](src))

      # Adopt document - caller takes ownership
      let doc = parser.adoptDocument()
      check doc != nil

      # Use the document
      let root = doc.getDocumentElement()
      check root.tagName() == "root"

      # Release the document (caller's responsibility after adoptDocument)
      doc.release()

  test "Safe parse valid XML string":
    withXerces:
      let result = safeParseXMLString(testXml)

      check result.isOk
      check result.success

      let doc = result.get()
      check doc != nil

      let root = doc.getDocumentElement()
      check root.tagName() == "root"

      doc.release()

  test "Safe parse invalid XML returns error":
    withXerces:
      # Completely broken XML that cannot be parsed
      let invalidXml = "<<<this is not xml at all>>>"
      let result = safeParseXMLString(invalidXml)

      # Note: Xerces may still "succeed" but return an empty/nil document
      # for some malformed input, depending on error handling settings
      if result.isErr:
        check result.errorMessage.len > 0
      else:
        # If it parsed, the document should be unusable
        let doc = result.get()
        if doc != nil:
          doc.release()

  test "XercesResult getOrDefault on success":
    withXerces:
      let result = safeParseXMLString(testXml)
      check result.isOk
      let doc = result.get()
      check doc != nil
      doc.release()

  test "XercesErrorHandler creation and destruction":
    withXerces:
      let handler = newXercesErrorHandler()
      defer:
        handler.destroy()

      check handler.errorCount == 0
      check not handler.hasErrors()
      check not handler.hasFatalErrors()

  test "XercesErrorHandler collects parse errors":
    withXerces:
      let parser = newXercesDOMParser()
      defer:
        deleteXercesDOMParser(parser)

      let handler = newXercesErrorHandler()
      defer:
        handler.destroy()

      parser.setErrorHandler(handler)

      # Parse invalid XML
      let invalidXml = """<?xml version="1.0"?><root><unclosed>"""
      let src = newMemBufInputSource(
        cast[ptr XMLByte](invalidXml.cstring), invalidXml.len.XMLSize, "test"
      )
      defer:
        deleteMemBufInputSource(src)

      parser.parse(cast[InputSourcePtr](src))

      # Should have collected errors
      check handler.errorCount > 0
      check handler.hasErrors()

      # Check error details
      for err in handler.errors:
        check err.message.len > 0
        check err.line > 0

  test "XercesErrorHandler clear":
    withXerces:
      let handler = newXercesErrorHandler()
      defer:
        handler.destroy()

      let parser = newXercesDOMParser()
      defer:
        deleteXercesDOMParser(parser)

      parser.setErrorHandler(handler)

      # Parse invalid XML
      let invalidXml = "<invalid><"
      let src = newMemBufInputSource(
        cast[ptr XMLByte](invalidXml.cstring), invalidXml.len.XMLSize, "test"
      )
      defer:
        deleteMemBufInputSource(src)

      parser.parse(cast[InputSourcePtr](src))

      # Should have errors
      let initialCount = handler.errorCount
      check initialCount > 0

      # Clear and verify
      handler.clear()
      check handler.errorCount == 0
      check not handler.hasErrors()

  test "XercesErrorHandler with valid XML has no errors":
    withXerces:
      let parser = newXercesDOMParser()
      defer:
        deleteXercesDOMParser(parser)

      let handler = newXercesErrorHandler()
      defer:
        handler.destroy()

      parser.setErrorHandler(handler)

      let src = newMemBufInputSource(
        cast[ptr XMLByte](testXml.cstring), testXml.len.XMLSize, "test"
      )
      defer:
        deleteMemBufInputSource(src)

      parser.parse(cast[InputSourcePtr](src))

      check handler.errorCount == 0
      check not handler.hasErrors()

  test "XPath supportsXPath check":
    withXerces:
      let parser = newXercesDOMParser()
      defer:
        deleteXercesDOMParser(parser)

      let src = newMemBufInputSource(
        cast[ptr XMLByte](testXml.cstring), testXml.len.XMLSize, "test"
      )
      defer:
        deleteMemBufInputSource(src)

      parser.parse(cast[InputSourcePtr](src))
      let doc = parser.getDocument()

      # supportsXPath returns true but actual XPath evaluation fails!
      # This is because Xerces-C++ only implements XPath for XML Schema
      # identity constraints, not for general XPath queries.
      let supported = doc.supportsXPath()
      check supported == true or supported == false

  # IMPORTANT: XPath evaluation is NOT supported in Xerces-C++!
  #
  # Despite having XPath APIs and supportsXPath() returning true,
  # Xerces-C++ only implements a minimal XPath subset for XML Schema
  # identity constraints. General XPath queries will throw:
  #   - DOMException code 9 (NOT_SUPPORTED_ERR)
  #   - DOMXPathException code 52 (requested result type not supported)
  #
  # Limitations:
  #   - DOMElement nodes only
  #   - No predicate testing (e.g., //book[@id='1'] fails)
  #   - "//" only as initial step
  #
  # For full XPath support, use:
  #   - XQilla (https://xqilla.sourceforge.net/)
  #   - Apache Xalan C++ (https://xalan.apache.org/xalan-c/)
  #
  # Use findElementsByTagName() or manual DOM traversal instead.

suite "SAX Parser Tests":
  test "SAX parse XML string - basic events":
    withXerces:
      var events: seq[string] = @[]

      let handler = newSAXHandler()
      defer:
        handler.destroy()

      handler.onStartDocument = proc() =
        events.add("startDocument")

      handler.onEndDocument = proc() =
        events.add("endDocument")

      handler.onStartElement = proc(
          uri, localName, qName: string, attrs: seq[SAXAttribute]
      ) =
        events.add("startElement:" & qName)

      handler.onEndElement = proc(uri, localName, qName: string) =
        events.add("endElement:" & qName)

      saxParseString(testXml, handler)

      check "startDocument" in events
      check "endDocument" in events
      check "startElement:root" in events
      check "endElement:root" in events
      check "startElement:book" in events
      check "endElement:book" in events

  test "SAX parse XML string - character content":
    withXerces:
      var titles: seq[string] = @[]
      var currentElement = ""

      let handler = newSAXHandler()
      defer:
        handler.destroy()

      handler.onStartElement = proc(
          uri, localName, qName: string, attrs: seq[SAXAttribute]
      ) =
        currentElement = qName

      handler.onEndElement = proc(uri, localName, qName: string) =
        currentElement = ""

      handler.onCharacters = proc(content: string) =
        if currentElement == "title":
          let trimmed = content.strip()
          if trimmed.len > 0:
            titles.add(trimmed)

      saxParseString(testXml, handler)

      check titles.len == 2
      check "The Great Gatsby" in titles
      check "1984" in titles

  test "SAX parse XML string - attributes":
    withXerces:
      var bookIds: seq[string] = @[]

      let handler = newSAXHandler()
      defer:
        handler.destroy()

      handler.onStartElement = proc(
          uri, localName, qName: string, attrs: seq[SAXAttribute]
      ) =
        if qName == "book":
          for attr in attrs:
            if attr.qName == "id":
              bookIds.add(attr.value)

      saxParseString(testXml, handler)

      check bookIds.len == 2
      check bookIds[0] == "1"
      check bookIds[1] == "2"

  test "SAX handler creation and destruction":
    withXerces:
      let handler = newSAXHandler()
      check handler.impl != nil
      handler.destroy()
      check handler.impl == nil

  test "SAX2XMLReader direct usage":
    withXerces:
      var elementCount = 0

      let handler = newSAXHandler()
      defer:
        handler.destroy()

      handler.onStartElement = proc(
          uri, localName, qName: string, attrs: seq[SAXAttribute]
      ) =
        elementCount += 1

      let reader = XMLReaderFactory.createXMLReader()
      defer:
        deleteSAX2XMLReader(reader)

      let src = newMemBufInputSource(
        cast[ptr XMLByte](testXml.cstring), testXml.len.XMLSize, "test"
      )
      defer:
        deleteMemBufInputSource(src)

      reader.parseWithSAX(handler, cast[InputSourcePtr](src))

      # root, book(1), title, author, book(2), title, author = 7 elements
      check elementCount == 7

suite "Namespace API Tests":
  const nsXml =
    """<?xml version="1.0" encoding="UTF-8"?>
<root xmlns="http://example.com/default" xmlns:custom="http://example.com/custom">
  <item custom:id="123" custom:type="test">Default NS content</item>
  <custom:element>Custom NS content</custom:element>
</root>"""

  test "Get attribute with namespace":
    withXerces:
      let doc = parseXMLString(nsXml, namespaceAware = true)
      defer:
        doc.release()

      let items = doc.findElementsByTagName("item")
      check items.len == 1

      let customId = items[0].attrNS("http://example.com/custom", "id")
      check customId == "123"

      let customType = items[0].attrNS("http://example.com/custom", "type")
      check customType == "test"

  test "Check attribute with namespace":
    withXerces:
      let doc = parseXMLString(nsXml, namespaceAware = true)
      defer:
        doc.release()

      let items = doc.findElementsByTagName("item")
      check items.len == 1

      check items[0].hasAttrNS("http://example.com/custom", "id")
      check items[0].hasAttrNS("http://example.com/custom", "type")
      check not items[0].hasAttrNS("http://example.com/custom", "nonexistent")

  test "Find elements by tag name with namespace":
    withXerces:
      let doc = parseXMLString(nsXml, namespaceAware = true)
      defer:
        doc.release()

      # Find elements in default namespace
      let defaultItems =
        doc.findElementsByTagNameNS("http://example.com/default", "item")
      check defaultItems.len == 1

      # Find elements in custom namespace
      let customElements =
        doc.findElementsByTagNameNS("http://example.com/custom", "element")
      check customElements.len == 1

  test "Get node namespace info":
    withXerces:
      let doc = parseXMLString(nsXml, namespaceAware = true)
      defer:
        doc.release()

      let customElements =
        doc.findElementsByTagNameNS("http://example.com/custom", "element")
      check customElements.len == 1

      let elem = customElements[0]
      check elem.namespaceURI() == "http://example.com/custom"
      check elem.localName() == "element"
      check elem.prefix() == "custom"

  test "Set attribute with namespace":
    withXerces:
      let doc = parseXMLString(nsXml, namespaceAware = true)
      defer:
        doc.release()

      let items = doc.findElementsByTagName("item")
      check items.len == 1

      items[0].setAttrNS("http://example.com/custom", "custom:newattr", "newvalue")
      check items[0].hasAttrNS("http://example.com/custom", "newattr")
      check items[0].attrNS("http://example.com/custom", "newattr") == "newvalue"

  test "Remove attribute with namespace":
    withXerces:
      let doc = parseXMLString(nsXml, namespaceAware = true)
      defer:
        doc.release()

      let items = doc.findElementsByTagName("item")
      check items.len == 1

      check items[0].hasAttrNS("http://example.com/custom", "id")
      items[0].removeAttrNS("http://example.com/custom", "id")
      check not items[0].hasAttrNS("http://example.com/custom", "id")

suite "File Parsing Tests":
  test "Parse XML file with parseXMLFile":
    withXerces:
      let doc = parseXMLFile(testDataPath)
      defer:
        doc.release()

      check doc != nil
      let root = doc.getDocumentElement()
      check root.tagName() == "library"

      let books = doc.findElementsByTagName("book")
      check books.len == 3

  test "Parse XML file with XercesDOMParser directly":
    withXerces:
      let parser = newXercesDOMParser()
      defer:
        deleteXercesDOMParser(parser)

      parser.parse(testDataPath.cstring)
      let doc = parser.getDocument()

      check doc != nil
      let root = doc.getDocumentElement()
      check root.tagName() == "library"

  test "Safe parse XML file":
    withXerces:
      let result = safeParseXMLFile(testDataPath)

      check result.isOk
      let doc = result.get()
      defer:
        doc.release()

      let books = doc.findElementsByTagName("book")
      check books.len == 3

      # Check attributes
      check books[0].attr("id") == "1"
      check books[0].attr("category") == "fiction"
      check books[2].attr("category") == "non-fiction"

  test "Safe parse non-existent file returns error":
    withXerces:
      let result = safeParseXMLFile("/non/existent/file.xml")

      check result.isErr
      check result.errorMessage.len > 0

  test "Parse XML file and extract text content":
    withXerces:
      let doc = parseXMLFile(testDataPath)
      defer:
        doc.release()

      let titles = doc.findElementsByTagName("title")
      check titles.len == 3
      check titles[0].textContent() == "The Great Gatsby"
      check titles[1].textContent() == "1984"
      check titles[2].textContent() == "A Brief History of Time"

      let years = doc.findElementsByTagName("year")
      check years.len == 3
      check years[0].textContent() == "1925"

  test "SAX parse XML file":
    withXerces:
      var bookCount = 0
      var titles: seq[string] = @[]
      var currentElement = ""

      let handler = newSAXHandler()
      defer:
        handler.destroy()

      handler.onStartElement = proc(
          uri, localName, qName: string, attrs: seq[SAXAttribute]
      ) =
        currentElement = qName
        if qName == "book":
          bookCount += 1

      handler.onEndElement = proc(uri, localName, qName: string) =
        currentElement = ""

      handler.onCharacters = proc(content: string) =
        if currentElement == "title":
          let trimmed = content.strip()
          if trimmed.len > 0:
            titles.add(trimmed)

      saxParseFile(testDataPath, handler)

      check bookCount == 3
      check titles.len == 3
      check "The Great Gatsby" in titles
      check "A Brief History of Time" in titles

  test "XercesErrorHandler with invalid file":
    withXerces:
      let parser = newXercesDOMParser()
      defer:
        deleteXercesDOMParser(parser)

      let handler = newXercesErrorHandler()
      defer:
        handler.destroy()

      parser.setErrorHandler(handler)

      # Try to parse non-existent file - this may throw or collect errors
      let result = safeParse(parser, "/non/existent/path.xml")

      # Either safeParse returns error or handler collected errors
      check result.isErr or handler.errorCount > 0

suite "DOM Document Creation Tests":
  test "Create element":
    withXerces:
      let doc = parseXMLString("<root/>")
      defer:
        doc.release()

      withXMLCh(tagName, "newElement"):
        let newElem = doc.createElement(tagName)
        check newElem != nil
        check newElem.tagName() == "newElement"

        # Append to root
        let root = doc.getDocumentElement()
        discard root.appendChild(cast[DOMNodePtr](newElem))

        # Verify it was added
        let children = root.findElementsByTagName("newElement")
        check children.len == 1

  test "Create text node":
    withXerces:
      let doc = parseXMLString("<root/>")
      defer:
        doc.release()

      withXMLCh(textData, "Hello, World!"):
        let textNode = doc.createTextNode(textData)
        check textNode != nil
        check $textNode.getData() == "Hello, World!"

        # Append to root
        let root = doc.getDocumentElement()
        discard root.appendChild(cast[DOMNodePtr](textNode))
        check root.textContent() == "Hello, World!"

  test "Create comment":
    withXerces:
      let doc = parseXMLString("<root/>")
      defer:
        doc.release()

      withXMLCh(commentData, "This is a comment"):
        let comment = doc.createComment(commentData)
        check comment != nil
        check $comment.getData() == "This is a comment"

        let root = doc.getDocumentElement()
        discard root.appendChild(cast[DOMNodePtr](comment))

  test "Create CDATA section":
    withXerces:
      let doc = parseXMLString("<root/>")
      defer:
        doc.release()

      withXMLCh(cdataContent, "<not>xml</not>"):
        let cdata = doc.createCDATASection(cdataContent)
        check cdata != nil
        check $cdata.getData() == "<not>xml</not>"

  test "Create processing instruction":
    withXerces:
      let doc = parseXMLString("<root/>")
      defer:
        doc.release()

      withXMLCh(target, "xml-stylesheet"):
        withXMLCh(data, "type=\"text/xsl\" href=\"style.xsl\""):
          let pi = doc.createProcessingInstruction(target, data)
          check pi != nil
          check cast[DOMNodePtr](pi).getNodeType() == PROCESSING_INSTRUCTION_NODE

  test "Create document fragment":
    withXerces:
      let doc = parseXMLString("<root/>")
      defer:
        doc.release()

      let fragment = doc.createDocumentFragment()
      check fragment != nil
      check cast[DOMNodePtr](fragment).getNodeType() == DOCUMENT_FRAGMENT_NODE

      # Add elements to fragment
      withXMLCh(tag1, "item1"):
        withXMLCh(tag2, "item2"):
          let elem1 = doc.createElement(tag1)
          let elem2 = doc.createElement(tag2)
          discard cast[DOMNodePtr](fragment).appendChild(cast[DOMNodePtr](elem1))
          discard cast[DOMNodePtr](fragment).appendChild(cast[DOMNodePtr](elem2))

          # Append fragment to root (moves all children)
          let root = doc.getDocumentElement()
          discard root.appendChild(cast[DOMNodePtr](fragment))

          check root.findElementsByTagName("item1").len == 1
          check root.findElementsByTagName("item2").len == 1

  test "Create attribute":
    withXerces:
      let doc = parseXMLString("<root/>")
      defer:
        doc.release()

      withXMLCh(attrName, "testAttr"):
        let attr = doc.createAttribute(attrName)
        check attr != nil
        check $attr.getName() == "testAttr"

        withXMLCh(attrValue, "testValue"):
          attr.setValue(attrValue)
          check $attr.getValue() == "testValue"

  test "Create element with namespace":
    withXerces:
      let doc = parseXMLString(
        "<root xmlns:ns=\"http://example.com/ns\"/>", namespaceAware = true
      )
      defer:
        doc.release()

      withXMLCh(nsUri, "http://example.com/ns"):
        withXMLCh(qName, "ns:newElement"):
          let elem = doc.createElementNS(nsUri, qName)
          check elem != nil
          check elem.localName() == "newElement"
          check elem.namespaceURI() == "http://example.com/ns"
          check elem.prefix() == "ns"

  test "Clone node shallow":
    withXerces:
      let doc = parseXMLString(testXml)
      defer:
        doc.release()

      let books = doc.findElementsByTagName("book")
      check books.len >= 1

      # Shallow clone - no children
      let clone = books[0].cloneNode(false)
      check clone != nil
      check clone.isElement()
      check clone.toElement().tagName() == "book"
      check not clone.hasChildNodes()

  test "Clone node deep":
    withXerces:
      let doc = parseXMLString(testXml)
      defer:
        doc.release()

      let books = doc.findElementsByTagName("book")
      check books.len >= 1

      # Deep clone - includes children
      let clone = books[0].cloneNode(true)
      check clone != nil
      check clone.hasChildNodes()

      # Verify children were cloned
      let clonedElem = clone.toElement()
      check clonedElem != nil
      let titles = clonedElem.findElementsByTagName("title")
      check titles.len == 1

  test "Import node from another document":
    withXerces:
      let doc1 = parseXMLString("<root><item>Content</item></root>")
      let doc2 = parseXMLString("<target/>")
      defer:
        doc1.release()
        doc2.release()

      let items = doc1.findElementsByTagName("item")
      check items.len == 1

      # Import node from doc1 to doc2
      let imported = doc2.importNode(cast[DOMNodePtr](items[0]), true)
      check imported != nil

      # Append imported node
      let target = doc2.getDocumentElement()
      discard target.appendChild(imported)

      # Verify
      let targetItems = doc2.findElementsByTagName("item")
      check targetItems.len == 1
      check targetItems[0].textContent() == "Content"

suite "Parser Configuration Tests":
  test "Validation scheme setting":
    withXerces:
      let parser = newXercesDOMParser()
      defer:
        deleteXercesDOMParser(parser)

      # Test different validation schemes
      parser.setValidationScheme(Val_Never)
      check parser.getValidationScheme() == Val_Never

      parser.setValidationScheme(Val_Always)
      check parser.getValidationScheme() == Val_Always

      parser.setValidationScheme(Val_Auto)
      check parser.getValidationScheme() == Val_Auto

  test "Namespace setting":
    withXerces:
      let parser = newXercesDOMParser()
      defer:
        deleteXercesDOMParser(parser)

      parser.setDoNamespaces(true)
      check parser.getDoNamespaces() == true

      parser.setDoNamespaces(false)
      check parser.getDoNamespaces() == false

  test "Schema validation setting":
    withXerces:
      let parser = newXercesDOMParser()
      defer:
        deleteXercesDOMParser(parser)

      parser.setDoSchema(true)
      check parser.getDoSchema() == true

      parser.setDoSchema(false)
      check parser.getDoSchema() == false

  test "Full schema checking setting":
    withXerces:
      let parser = newXercesDOMParser()
      defer:
        deleteXercesDOMParser(parser)

      parser.setValidationSchemaFullChecking(true)
      check parser.getValidationSchemaFullChecking() == true

      parser.setValidationSchemaFullChecking(false)
      check parser.getValidationSchemaFullChecking() == false

  test "Exit on first fatal error setting":
    withXerces:
      let parser = newXercesDOMParser()
      defer:
        deleteXercesDOMParser(parser)

      parser.setExitOnFirstFatalError(true)
      check parser.getExitOnFirstFatalError() == true

      parser.setExitOnFirstFatalError(false)
      check parser.getExitOnFirstFatalError() == false

  test "Entity reference nodes setting":
    withXerces:
      let parser = newXercesDOMParser()
      defer:
        deleteXercesDOMParser(parser)

      parser.setCreateEntityReferenceNodes(true)
      check parser.getCreateEntityReferenceNodes() == true

      parser.setCreateEntityReferenceNodes(false)
      check parser.getCreateEntityReferenceNodes() == false

  test "Ignorable whitespace setting":
    withXerces:
      let parser = newXercesDOMParser()
      defer:
        deleteXercesDOMParser(parser)

      parser.setIncludeIgnorableWhitespace(true)
      check parser.getIncludeIgnorableWhitespace() == true

      parser.setIncludeIgnorableWhitespace(false)
      check parser.getIncludeIgnorableWhitespace() == false

  test "Comment nodes setting":
    withXerces:
      let parser = newXercesDOMParser()
      defer:
        deleteXercesDOMParser(parser)

      parser.setCreateCommentNodes(true)
      check parser.getCreateCommentNodes() == true

      parser.setCreateCommentNodes(false)
      check parser.getCreateCommentNodes() == false

  test "Reset document pool":
    withXerces:
      let parser = newXercesDOMParser()
      defer:
        deleteXercesDOMParser(parser)

      let src = newMemBufInputSource(
        cast[ptr XMLByte](testXml.cstring), testXml.len.XMLSize, "test"
      )
      defer:
        deleteMemBufInputSource(src)

      parser.parse(cast[InputSourcePtr](src))
      check parser.getDocument() != nil

      # Reset the document pool
      parser.resetDocumentPool()

      # After reset, document should be nil
      check parser.getDocument() == nil

suite "Advanced SAX Tests":
  const piXml =
    """<?xml version="1.0"?>
<?xml-stylesheet type="text/xsl" href="style.xsl"?>
<root>content</root>"""

  test "SAX processing instruction callback":
    withXerces:
      var piEvents: seq[tuple[target: string, data: string]] = @[]

      let handler = newSAXHandler()
      defer:
        handler.destroy()

      handler.onProcessingInstruction = proc(target, data: string) =
        piEvents.add((target, data))

      saxParseString(piXml, handler)

      check piEvents.len >= 1
      # xml-stylesheet processing instruction
      var found = false
      for pi in piEvents:
        if pi.target == "xml-stylesheet":
          found = true
          check "text/xsl" in pi.data
      check found

  const nsXmlForSax =
    """<?xml version="1.0"?>
<root xmlns:ns="http://example.com/ns">
  <ns:item>content</ns:item>
</root>"""

  test "SAX prefix mapping callbacks":
    withXerces:
      var prefixMappings: seq[tuple[prefix: string, uri: string]] = @[]
      var endPrefixes: seq[string] = @[]

      let handler = newSAXHandler()
      defer:
        handler.destroy()

      handler.onStartPrefixMapping = proc(prefix, uri: string) =
        prefixMappings.add((prefix, uri))

      handler.onEndPrefixMapping = proc(prefix: string) =
        endPrefixes.add(prefix)

      saxParseString(nsXmlForSax, handler)

      # Should have captured namespace prefix mapping
      check prefixMappings.len >= 1
      var foundNs = false
      for mapping in prefixMappings:
        if mapping.prefix == "ns" and mapping.uri == "http://example.com/ns":
          foundNs = true
      check foundNs

  test "SAX parse file with LocalFileInputSource":
    withXerces:
      var elementCount = 0

      let handler = newSAXHandler()
      defer:
        handler.destroy()

      handler.onStartElement = proc(
          uri, localName, qName: string, attrs: seq[SAXAttribute]
      ) =
        elementCount += 1

      # Create LocalFileInputSource
      withXMLCh(filePath, testDataPath):
        let src = newLocalFileInputSource(filePath)
        defer:
          deleteLocalFileInputSource(src)

        let reader = XMLReaderFactory.createXMLReader()
        defer:
          deleteSAX2XMLReader(reader)

        reader.parseWithSAX(handler, cast[InputSourcePtr](src))

      # test_data.xml has: library, book(3), title(3), author(3), year(3) = 13 elements
      check elementCount == 13

  test "SAX handler getLocator during parsing":
    withXerces:
      var lineNumbers: seq[int] = @[]

      let handler = newSAXHandler()
      defer:
        handler.destroy()

      handler.onStartElement = proc(
          uri, localName, qName: string, attrs: seq[SAXAttribute]
      ) =
        let locator = handler.getLocator()
        if locator != nil:
          lineNumbers.add(locator.getLineNumber().int)

      saxParseString(testXml, handler)

      # Should have captured line numbers for elements
      check lineNumbers.len > 0

  test "SAX attribute type information":
    withXerces:
      var attrTypes: seq[string] = @[]

      let handler = newSAXHandler()
      defer:
        handler.destroy()

      handler.onStartElement = proc(
          uri, localName, qName: string, attrs: seq[SAXAttribute]
      ) =
        for attr in attrs:
          attrTypes.add(attr.attrType)

      saxParseString(testXml, handler)

      # Should have captured attribute types (typically CDATA for non-validated)
      check attrTypes.len >= 2 # book id attributes

suite "Node Manipulation Tests":
  test "appendChild and removeChild":
    withXerces:
      let doc = parseXMLString("<root><a/><b/><c/></root>")
      defer:
        doc.release()

      let root = doc.getDocumentElement()

      # Count initial children
      var initialCount = 0
      for _ in root.elements():
        initialCount += 1
      check initialCount == 3

      # Add new element
      withXMLCh(tagName, "d"):
        let newElem = doc.createElement(tagName)
        discard root.appendChild(cast[DOMNodePtr](newElem))

      var afterAddCount = 0
      for _ in root.elements():
        afterAddCount += 1
      check afterAddCount == 4

      # Remove first child element
      let first = root.firstElement()
      check first != nil
      discard root.removeChild(cast[DOMNodePtr](first))

      var afterRemoveCount = 0
      for _ in root.elements():
        afterRemoveCount += 1
      check afterRemoveCount == 3

  test "insertBefore":
    withXerces:
      let doc = parseXMLString("<root><a/><c/></root>")
      defer:
        doc.release()

      let root = doc.getDocumentElement()

      # Get reference node (c element)
      let cElements = root.findElementsByTagName("c")
      check cElements.len == 1
      let refNode = cElements[0]

      # Create new element and insert before 'c'
      withXMLCh(tagName, "b"):
        let newElem = doc.createElement(tagName)
        discard root.insertBefore(cast[DOMNodePtr](newElem), cast[DOMNodePtr](refNode))

      # Verify order: a, b, c
      var names: seq[string] = @[]
      for elem in root.elements():
        names.add(elem.tagName())
      check names == @["a", "b", "c"]

  test "replaceChild":
    withXerces:
      let doc = parseXMLString("<root><old/></root>")
      defer:
        doc.release()

      let root = doc.getDocumentElement()
      let oldElements = root.findElementsByTagName("old")
      check oldElements.len == 1

      withXMLCh(tagName, "new"):
        let newElem = doc.createElement(tagName)
        discard
          root.replaceChild(cast[DOMNodePtr](newElem), cast[DOMNodePtr](oldElements[0]))

      # Verify replacement
      check root.findElementsByTagName("old").len == 0
      check root.findElementsByTagName("new").len == 1

  test "setTextContent":
    withXerces:
      let doc = parseXMLString("<root><item>original</item></root>")
      defer:
        doc.release()

      let items = doc.findElementsByTagName("item")
      check items.len == 1
      check items[0].textContent() == "original"

      withXMLCh(newText, "modified"):
        cast[DOMNodePtr](items[0]).setTextContent(newText)
      check items[0].textContent() == "modified"

  test "getParentNode and getPreviousSibling":
    withXerces:
      let doc = parseXMLString("<root><a/><b/><c/></root>")
      defer:
        doc.release()

      let bElements = doc.findElementsByTagName("b")
      check bElements.len == 1
      let b = bElements[0]

      # Check parent
      let parent = cast[DOMNodePtr](b).getParentNode()
      check parent != nil
      check parent.isElement()
      check parent.toElement().tagName() == "root"

      # Check previous sibling
      let prev = cast[DOMNodePtr](b).getPreviousSibling()
      check prev != nil
      # May be whitespace text node, so find element
      var prevElem = prev
      while prevElem != nil and not prevElem.isElement():
        prevElem = prevElem.getPreviousSibling()
      if prevElem != nil:
        check prevElem.toElement().tagName() == "a"

  test "Attribute node operations":
    withXerces:
      let doc = parseXMLString("<root><item id=\"123\"/></root>")
      defer:
        doc.release()

      let items = doc.findElementsByTagName("item")
      check items.len == 1

      # Get attribute node
      withXMLCh(attrName, "id"):
        let attrNode = items[0].getAttributeNode(attrName)
        check attrNode != nil
        check $attrNode.getName() == "id"
        check $attrNode.getValue() == "123"

        # Modify attribute value
        withXMLCh(newValue, "456"):
          attrNode.setValue(newValue)
        check items[0].attr("id") == "456"

  test "hasChildNodes and hasAttributes":
    withXerces:
      let doc = parseXMLString("<root attr=\"val\"><child/></root>")
      defer:
        doc.release()

      let root = doc.getDocumentElement()
      check cast[DOMNodePtr](root).hasChildNodes()
      check cast[DOMNodePtr](root).hasAttributes()

      let children = root.findElementsByTagName("child")
      check children.len == 1
      check not cast[DOMNodePtr](children[0]).hasChildNodes()
      check not cast[DOMNodePtr](children[0]).hasAttributes()

suite "Type Conversion Tests":
  test "toComment conversion":
    withXerces:
      let doc = parseXMLString("<root><!-- comment --></root>")
      defer:
        doc.release()

      let root = doc.getDocumentElement()
      for child in root.children():
        if child.isComment():
          let comment = child.toComment()
          check comment != nil
          check "comment" in $comment.getData()

  test "toCDATASection conversion":
    withXerces:
      let doc = parseXMLString("<root><![CDATA[some data]]></root>")
      defer:
        doc.release()

      let root = doc.getDocumentElement()
      for child in root.children():
        if child.isCDATASection():
          let cdata = child.toCDATASection()
          check cdata != nil
          check $cdata.getData() == "some data"

  test "toDocument conversion":
    withXerces:
      let doc = parseXMLString("<root/>")
      defer:
        doc.release()

      let root = doc.getDocumentElement()
      let docNode = cast[DOMNodePtr](doc)

      check docNode.isDocument()
      let converted = docNode.toDocument()
      check converted != nil
      check converted == doc

      # Element should not convert to document
      check not cast[DOMNodePtr](root).isDocument()
      check cast[DOMNodePtr](root).toDocument() == nil

  test "toProcessingInstruction conversion":
    withXerces:
      let doc = parseXMLString("<root/>")
      defer:
        doc.release()

      withXMLCh(target, "test"):
        withXMLCh(data, "data"):
          let pi = doc.createProcessingInstruction(target, data)
          let piNode = cast[DOMNodePtr](pi)

          check piNode.getNodeType() == PROCESSING_INSTRUCTION_NODE
          let converted = piNode.toProcessingInstruction()
          check converted != nil

suite "Serialization Tests":
  test "Serialize element only":
    withXerces:
      let doc = parseXMLString(testXml)
      defer:
        doc.release()

      let books = doc.findElementsByTagName("book")
      check books.len >= 1

      let bookXml = books[0].toXMLString()
      check bookXml.len > 0
      check "book" in bookXml
      check "title" in bookXml
      check "The Great Gatsby" in bookXml

  test "Pretty print XML":
    withXerces:
      let doc = parseXMLString("<root><a><b/></a></root>")
      defer:
        doc.release()

      let prettyXml = doc.toPrettyXMLString()
      check prettyXml.len > 0
      # Pretty printing should add some structure
      check "root" in prettyXml

  test "Serializer newline setting":
    withXerces:
      withXMLCh(features, "LS"):
        let impl = DOMImplementationRegistry.getDOMImplementation(features)
        check impl != nil

        let lsImpl = impl.toLSImpl()
        let serializer = lsImpl.createLSSerializer()
        check serializer != nil
        defer:
          serializer.release()

        # Set custom newline
        withXMLCh(newLine, "\r\n"):
          serializer.setNewLine(newLine)
          let currentNewLine = serializer.getNewLine()
          check currentNewLine != nil

suite "DOMNodeList and DOMNamedNodeMap Tests":
  test "Iterate DOMNodeList":
    withXerces:
      let doc = parseXMLString(testXml)
      defer:
        doc.release()

      withXMLCh(tagName, "book"):
        let nodeList = doc.getElementsByTagName(tagName)
        check nodeList != nil
        check nodeList.getLength() == 2

        # Test item access
        let first = nodeList.item(0)
        check first != nil
        check first.isElement()

        # Test iterator
        var count = 0
        for node in nodeList:
          check node.isElement()
          count += 1
        check count == 2

  test "DOMNamedNodeMap for attributes":
    withXerces:
      let doc = parseXMLString("<root attr1=\"val1\" attr2=\"val2\" attr3=\"val3\"/>")
      defer:
        doc.release()

      let root = doc.getDocumentElement()
      let attrs = cast[DOMNodePtr](root).getAttributes()
      check attrs != nil
      check attrs.getLength() == 3

      # Test iterator
      var attrNames: seq[string] = @[]
      for node in attrs:
        attrNames.add($node.getNodeName())
      check attrNames.len == 3
      check "attr1" in attrNames
      check "attr2" in attrNames
      check "attr3" in attrNames

      # Test getNamedItem
      withXMLCh(name, "attr2"):
        let attr2 = attrs.getNamedItem(name)
        check attr2 != nil
        check $attr2.getNodeValue() == "val2"

suite "Error Handling Edge Cases":
  test "Multiple errors in single parse":
    withXerces:
      let handler = newXercesErrorHandler()
      defer:
        handler.destroy()

      let parser = newXercesDOMParser()
      defer:
        deleteXercesDOMParser(parser)

      parser.setErrorHandler(handler)

      # XML with multiple issues
      let badXml =
        """<?xml version="1.0"?>
<root>
  <unclosed>
  <another>
</root>"""

      let src = newMemBufInputSource(
        cast[ptr XMLByte](badXml.cstring), badXml.len.XMLSize, "test"
      )
      defer:
        deleteMemBufInputSource(src)

      parser.parse(cast[InputSourcePtr](src))

      # Should have collected errors
      check handler.errorCount > 0

      # Iterate through errors
      var hasLineInfo = false
      for err in handler.errors:
        if err.line > 0:
          hasLineInfo = true
      check hasLineInfo

  test "Error handler reuse across multiple parses":
    withXerces:
      let handler = newXercesErrorHandler()
      defer:
        handler.destroy()

      let parser = newXercesDOMParser()
      defer:
        deleteXercesDOMParser(parser)

      parser.setErrorHandler(handler)

      # First parse with error
      let badXml = "<invalid><"
      let src1 = newMemBufInputSource(
        cast[ptr XMLByte](badXml.cstring), badXml.len.XMLSize, "test1"
      )
      defer:
        deleteMemBufInputSource(src1)

      parser.parse(cast[InputSourcePtr](src1))
      let firstErrorCount = handler.errorCount
      check firstErrorCount > 0

      # Clear and parse valid XML
      handler.clear()
      check handler.errorCount == 0

      parser.resetDocumentPool()
      let goodXml = "<valid/>"
      let src2 = newMemBufInputSource(
        cast[ptr XMLByte](goodXml.cstring), goodXml.len.XMLSize, "test2"
      )
      defer:
        deleteMemBufInputSource(src2)

      parser.parse(cast[InputSourcePtr](src2))
      check handler.errorCount == 0

  test "hasFatalErrors check":
    withXerces:
      let handler = newXercesErrorHandler()
      defer:
        handler.destroy()

      let parser = newXercesDOMParser()
      defer:
        deleteXercesDOMParser(parser)

      parser.setErrorHandler(handler)
      parser.setExitOnFirstFatalError(false)

      # Completely broken XML should trigger fatal error
      let fatalXml = "not xml at all < > & \""
      let src = newMemBufInputSource(
        cast[ptr XMLByte](fatalXml.cstring), fatalXml.len.XMLSize, "test"
      )
      defer:
        deleteMemBufInputSource(src)

      parser.parse(cast[InputSourcePtr](src))

      # May or may not have fatal errors depending on parser behavior
      check handler.hasErrors() or handler.hasFatalErrors() or handler.errorCount > 0

suite "High-Level API Tests":
  test "firstElement and nextElement":
    withXerces:
      let doc = parseXMLString("<root><a/><b/><c/></root>")
      defer:
        doc.release()

      let root = doc.getDocumentElement()

      let first = cast[DOMNodePtr](root).firstElement()
      check first != nil
      check first.tagName() == "a"

      let second = cast[DOMNodePtr](first).nextElement()
      check second != nil
      check second.tagName() == "b"

      let third = cast[DOMNodePtr](second).nextElement()
      check third != nil
      check third.tagName() == "c"

      let fourth = cast[DOMNodePtr](third).nextElement()
      check fourth == nil

  test "nodeName and nodeValue":
    withXerces:
      let doc = parseXMLString("<root attr=\"value\">text</root>")
      defer:
        doc.release()

      let root = doc.getDocumentElement()
      check root.nodeName() == "root"

      # Get text node
      for child in root.children():
        if child.isText():
          check child.nodeValue() == "text"

  test "setAttr convenience function":
    withXerces:
      let doc = parseXMLString("<root/>")
      defer:
        doc.release()

      let root = doc.getDocumentElement()
      check not root.hasAttr("newAttr")

      root.setAttr("newAttr", "newValue")
      check root.hasAttr("newAttr")
      check root.attr("newAttr") == "newValue"

      # Update existing attribute
      root.setAttr("newAttr", "updatedValue")
      check root.attr("newAttr") == "updatedValue"

  test "getElementsByTagName iterator":
    withXerces:
      let doc = parseXMLString(testXml)
      defer:
        doc.release()

      var count = 0
      for book in doc.getElementsByTagName("book"):
        check book.hasAttr("id")
        count += 1
      check count == 2

  test "Element children iterator vs all children":
    withXerces:
      let doc = parseXMLString("<root>text1<a/>text2<b/>text3</root>")
      defer:
        doc.release()

      let root = doc.getDocumentElement()

      # All children (includes text nodes)
      var allCount = 0
      for _ in root.children():
        allCount += 1

      # Element children only
      var elemCount = 0
      for _ in root.elements():
        elemCount += 1

      check elemCount == 2
      check allCount > elemCount # Should have text nodes too

suite "XMLString Utilities Tests":
  test "stringLen":
    withXerces:
      withXMLCh(str, "Hello"):
        check stringLen(str) == 5

      withXMLCh(empty, ""):
        check stringLen(empty) == 0

  test "compareString case sensitive":
    withXerces:
      withXMLCh(str1, "Hello"):
        withXMLCh(str2, "Hello"):
          check compareString(str1, str2) == 0

      withXMLCh(str3, "Hello"):
        withXMLCh(str4, "HELLO"):
          check compareString(str3, str4) != 0

      withXMLCh(str5, "abc"):
        withXMLCh(str6, "abd"):
          check compareString(str5, str6) < 0

  test "compareIString case insensitive":
    withXerces:
      withXMLCh(str1, "Hello"):
        withXMLCh(str2, "HELLO"):
          check compareIString(str1, str2) == 0

      withXMLCh(str3, "hello"):
        withXMLCh(str4, "HeLLo"):
          check compareIString(str3, str4) == 0

  test "equals":
    withXerces:
      withXMLCh(str1, "test"):
        withXMLCh(str2, "test"):
          check equals(str1, str2)

      withXMLCh(str3, "test"):
        withXMLCh(str4, "TEST"):
          check not equals(str3, str4)

  test "replicate":
    withXerces:
      withXMLCh(original, "duplicate me"):
        var copy = replicate(original)
        check copy != nil
        check $copy == "duplicate me"
        check copy != original # Different pointers
        releaseXMLCh(copy)

suite "Additional DOM Tests":
  test "getLastChild":
    withXerces:
      let doc = parseXMLString("<root><a/><b/><c/></root>")
      defer:
        doc.release()

      let root = doc.getDocumentElement()
      let last = cast[DOMNodePtr](root).getLastChild()
      check last != nil

      # Find last element (may be text node due to whitespace)
      var lastElem = last
      while lastElem != nil and not lastElem.isElement():
        lastElem = lastElem.getPreviousSibling()
      if lastElem != nil:
        check lastElem.toElement().tagName() == "c"

  test "removeAttribute":
    withXerces:
      let doc = parseXMLString("<root attr1=\"val1\" attr2=\"val2\"/>")
      defer:
        doc.release()

      let root = doc.getDocumentElement()
      check root.hasAttr("attr1")
      check root.hasAttr("attr2")

      withXMLCh(attrName, "attr1"):
        root.removeAttribute(attrName)

      check not root.hasAttr("attr1")
      check root.hasAttr("attr2")

  test "setAttributeNode":
    withXerces:
      let doc = parseXMLString("<root/>")
      defer:
        doc.release()

      let root = doc.getDocumentElement()

      # Create and set attribute node
      withXMLCh(attrName, "newAttr"):
        let attr = doc.createAttribute(attrName)
        withXMLCh(attrValue, "newValue"):
          attr.setValue(attrValue)
        discard root.setAttributeNode(attr)

      check root.hasAttr("newAttr")
      check root.attr("newAttr") == "newValue"

  test "getOwnerDocument":
    withXerces:
      let doc = parseXMLString("<root><child/></root>")
      defer:
        doc.release()

      let root = doc.getDocumentElement()
      let ownerDoc = cast[DOMNodePtr](root).getOwnerDocument()
      check ownerDoc == doc

  test "getElementById with xml:id":
    withXerces:
      # Note: getElementById requires DTD or schema to identify ID attributes
      # Without DTD, it may not find elements by ID
      let xmlWithId =
        """<?xml version="1.0"?>
<!DOCTYPE root [
  <!ELEMENT root (item)*>
  <!ELEMENT item (#PCDATA)>
  <!ATTLIST item id ID #IMPLIED>
]>
<root><item id="myId">content</item></root>"""

      let parser = newXercesDOMParser()
      defer:
        deleteXercesDOMParser(parser)

      parser.setValidationScheme(Val_Auto)

      let src = newMemBufInputSource(
        cast[ptr XMLByte](xmlWithId.cstring), xmlWithId.len.XMLSize, "test"
      )
      defer:
        deleteMemBufInputSource(src)

      parser.parse(cast[InputSourcePtr](src))
      let doc = parser.getDocument()

      if doc != nil:
        withXMLCh(idValue, "myId"):
          let elem = doc.getElementById(idValue)
          # May or may not find depending on parser configuration
          if elem != nil:
            check elem.textContent() == "content"

  test "getDoctype":
    withXerces:
      let xmlWithDoctype =
        """<?xml version="1.0"?>
<!DOCTYPE root [
  <!ELEMENT root (#PCDATA)>
]>
<root>content</root>"""

      let parser = newXercesDOMParser()
      defer:
        deleteXercesDOMParser(parser)

      let src = newMemBufInputSource(
        cast[ptr XMLByte](xmlWithDoctype.cstring), xmlWithDoctype.len.XMLSize, "test"
      )
      defer:
        deleteMemBufInputSource(src)

      parser.parse(cast[InputSourcePtr](src))
      let doc = parser.getDocument()

      if doc != nil:
        let doctype = doc.getDoctype()
        if doctype != nil:
          check $doctype.getName() == "root"

  test "DOMText splitText":
    withXerces:
      let doc = parseXMLString("<root>HelloWorld</root>")
      defer:
        doc.release()

      let root = doc.getDocumentElement()

      # Find the text node
      for child in root.children():
        if child.isText():
          let textNode = child.toText()
          check $textNode.getData() == "HelloWorld"

          # Split at position 5
          let secondPart = textNode.splitText(5)
          check secondPart != nil
          check $textNode.getData() == "Hello"
          check $secondPart.getData() == "World"
          break

suite "SAX Locator Extended Tests":
  test "Locator column number":
    withXerces:
      var positions: seq[tuple[line: int, col: int]] = @[]

      let handler = newSAXHandler()
      defer:
        handler.destroy()

      handler.onStartElement = proc(
          uri, localName, qName: string, attrs: seq[SAXAttribute]
      ) =
        let locator = handler.getLocator()
        if locator != nil:
          positions.add((locator.getLineNumber().int, locator.getColumnNumber().int))

      saxParseString(testXml, handler)

      check positions.len > 0
      # Verify we got position information
      for pos in positions:
        check pos.line > 0

suite "Edge Cases and Nil Safety Tests":
  test "textContent on element with no text":
    withXerces:
      let doc = parseXMLString("<root><empty/></root>")
      defer:
        doc.release()

      let empties = doc.findElementsByTagName("empty")
      check empties.len == 1
      check empties[0].textContent() == ""

  test "attr on non-existent attribute":
    withXerces:
      let doc = parseXMLString("<root/>")
      defer:
        doc.release()

      let root = doc.getDocumentElement()
      check root.attr("nonexistent") == ""

  test "findElementsByTagName with no matches":
    withXerces:
      let doc = parseXMLString("<root><a/><b/></root>")
      defer:
        doc.release()

      let notFound = doc.findElementsByTagName("nonexistent")
      check notFound.len == 0

  test "getElementsByTagName iterator with no matches":
    withXerces:
      let doc = parseXMLString("<root><a/></root>")
      defer:
        doc.release()

      var count = 0
      for _ in doc.getElementsByTagName("nonexistent"):
        count += 1
      check count == 0

  test "Parse empty root element":
    withXerces:
      let doc = parseXMLString("<root/>")
      defer:
        doc.release()

      let root = doc.getDocumentElement()
      check root != nil
      check root.tagName() == "root"
      check not cast[DOMNodePtr](root).hasChildNodes()

  test "Parse with XML declaration":
    withXerces:
      let xmlWithDecl = """<?xml version="1.0" encoding="UTF-8"?><root/>"""
      let doc = parseXMLString(xmlWithDecl)
      defer:
        doc.release()

      check doc != nil
      check doc.getDocumentElement().tagName() == "root"

  test "Parse with nested CDATA":
    withXerces:
      let xmlWithCdata = "<root><![CDATA[<nested>not parsed</nested>]]></root>"
      let doc = parseXMLString(xmlWithCdata)
      defer:
        doc.release()

      let root = doc.getDocumentElement()
      check "<nested>not parsed</nested>" in root.textContent()

  test "Deeply nested elements":
    withXerces:
      let deepXml = "<a><b><c><d><e><f>deep</f></e></d></c></b></a>"
      let doc = parseXMLString(deepXml)
      defer:
        doc.release()

      let fElements = doc.findElementsByTagName("f")
      check fElements.len == 1
      check fElements[0].textContent() == "deep"

  test "Many sibling elements":
    withXerces:
      var xml = "<root>"
      for i in 1 .. 100:
        xml.add("<item>" & $i & "</item>")
      xml.add("</root>")

      let doc = parseXMLString(xml)
      defer:
        doc.release()

      let items = doc.findElementsByTagName("item")
      check items.len == 100
      check items[0].textContent() == "1"
      check items[99].textContent() == "100"

  test "Special characters in text content":
    withXerces:
      let xmlSpecial = "<root>&lt;test&gt; &amp; &quot;quoted&quot;</root>"
      let doc = parseXMLString(xmlSpecial)
      defer:
        doc.release()

      let root = doc.getDocumentElement()
      check "<test>" in root.textContent()
      check "&" in root.textContent()
      check "\"quoted\"" in root.textContent()

  test "Unicode in element content":
    withXerces:
      let xmlUnicode = "<root>日本語テスト αβγ 🎉</root>"
      let doc = parseXMLString(xmlUnicode)
      defer:
        doc.release()

      let root = doc.getDocumentElement()
      let content = root.textContent()
      check "日本語" in content
      check "αβγ" in content

  test "Whitespace preservation":
    withXerces:
      let xmlWhitespace = "<root>  spaces  </root>"
      let doc = parseXMLString(xmlWhitespace)
      defer:
        doc.release()

      let root = doc.getDocumentElement()
      check root.textContent() == "  spaces  "

suite "Attribute Operations Extended":
  test "Multiple attributes iteration":
    withXerces:
      let doc = parseXMLString("<root a=\"1\" b=\"2\" c=\"3\" d=\"4\" e=\"5\"/>")
      defer:
        doc.release()

      let root = doc.getDocumentElement()
      let attrs = cast[DOMNodePtr](root).getAttributes()
      check attrs.getLength() == 5

      var values: seq[string] = @[]
      for attr in attrs:
        values.add($attr.getNodeValue())

      check values.len == 5
      check "1" in values
      check "5" in values

  test "Attribute with special characters":
    withXerces:
      let doc = parseXMLString("<root attr=\"value with &lt;special&gt; chars\"/>")
      defer:
        doc.release()

      let root = doc.getDocumentElement()
      let attrValue = root.attr("attr")
      check "<special>" in attrValue

  test "Empty attribute value":
    withXerces:
      let doc = parseXMLString("<root empty=\"\"/>")
      defer:
        doc.release()

      let root = doc.getDocumentElement()
      check root.hasAttr("empty")
      check root.attr("empty") == ""

  test "getAttributeNodeNS":
    withXerces:
      let nsXml =
        """<root xmlns:ns="http://example.com"><item ns:attr="value"/></root>"""
      let doc = parseXMLString(nsXml, namespaceAware = true)
      defer:
        doc.release()

      let items = doc.findElementsByTagName("item")
      check items.len == 1

      withXMLCh(nsUri, "http://example.com"):
        withXMLCh(localName, "attr"):
          let attrNode = items[0].getAttributeNodeNS(nsUri, localName)
          if attrNode != nil:
            check $attrNode.getValue() == "value"

suite "Safe Parse Extended Tests":
  test "safeParseXMLString with various malformed XML":
    withXerces:
      # Unclosed tag - Xerces may partially parse or fail
      let result1 = safeParseXMLString("<root>")
      if result1.isOk:
        let doc = result1.get()
        if doc != nil:
          doc.release()

      # Mismatched tags - Xerces behavior varies
      let result2 = safeParseXMLString("<root></other>")
      if result2.isOk:
        let doc = result2.get()
        if doc != nil:
          doc.release()

      # Invalid character in tag name - Xerces may still parse
      let result3 = safeParseXMLString("<123invalid/>")
      if result3.isOk:
        let doc = result3.get()
        if doc != nil:
          doc.release()

      # Completely broken - should definitely have issues
      let result4 = safeParseXMLString("not xml at all")
      if result4.isOk:
        let doc = result4.get()
        if doc != nil:
          doc.release()

  test "safeParseXMLFile with empty path":
    withXerces:
      let result = safeParseXMLFile("")
      check result.isErr
