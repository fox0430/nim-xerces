# nim-xerces

Nim bindings for [Apache Xerces-C++](https://xerces.apache.org/xerces-c/).

## Requirements

- [Nim](https://nim-lang.org) >= 2.0.6
- [Apache Xerces-C++](https://xerces.apache.org/xerces-c/)

## Usage

```nim
import pkg/xerces

const xmlData = """<?xml version="1.0"?>
<root>
  <item id="1">Hello</item>
</root>"""

proc main() =
  XMLPlatformUtils.initialize()
  defer: XMLPlatformUtils.terminate()

  let doc = parseXMLString(xmlData)
  defer: doc.release()

  let root = doc.getDocumentElement()
  echo "Root: ", root.tagName()

  for item in doc.getElementsByTagName("item"):
    echo "Item: ", item.textContent()

when isMainModule:
  main()
```

## Build

```bash
nim cpp -r yourfile.nim
```

> [!NOTE]
> Add the following lines to your .nimble
```
backend = "cpp"
```

## License

MIT
