## Basic XML Parsing Example
##
## This example demonstrates how to parse XML and extract data using nim-xerces.

import pkg/xerces

const xmlData =
  """<?xml version="1.0" encoding="UTF-8"?>
<library>
  <book id="1" category="fiction">
    <title>The Great Gatsby</title>
    <author>F. Scott Fitzgerald</author>
    <year>1925</year>
  </book>
  <book id="2" category="fiction">
    <title>1984</title>
    <author>George Orwell</author>
    <year>1949</year>
  </book>
</library>"""

proc main() =
  # Initialize Xerces (required before any XML operations)
  XMLPlatformUtils.initialize()
  defer:
    XMLPlatformUtils.terminate()

  # Parse XML string
  let doc = parseXMLString(xmlData)
  defer:
    doc.release()

  # Get root element
  let root = doc.getDocumentElement()
  echo "Root element: ", root.tagName()

  # Find all book elements
  let books = doc.findElementsByTagName("book")
  echo "Found ", books.len, " books:\n"

  for book in books:
    # Get attributes
    let id = book.attr("id")
    let category = book.attr("category")

    # Get child element text content
    let titles = book.findElementsByTagName("title")
    let authors = book.findElementsByTagName("author")
    let years = book.findElementsByTagName("year")

    echo "Book #", id, " (", category, ")"
    if titles.len > 0:
      echo "  Title:  ", titles[0].textContent()
    if authors.len > 0:
      echo "  Author: ", authors[0].textContent()
    if years.len > 0:
      echo "  Year:   ", years[0].textContent()
    echo ""

when isMainModule:
  main()
