import types, dom

# DOM Level 3 Load/Save serialization

# Forward declare types
type
  DOMLSSerializer* {.
    importcpp: "xercesc::DOMLSSerializer", header: "<xercesc/dom/DOMLSSerializer.hpp>"
  .} = object
  DOMLSSerializerPtr* = ptr DOMLSSerializer

  DOMLSOutput* {.
    importcpp: "xercesc::DOMLSOutput", header: "<xercesc/dom/DOMLSOutput.hpp>"
  .} = object
  DOMLSOutputPtr* = ptr DOMLSOutput

  DOMConfiguration* {.
    importcpp: "xercesc::DOMConfiguration", header: "<xercesc/dom/DOMConfiguration.hpp>"
  .} = object
  DOMConfigurationPtr* = ptr DOMConfiguration

# DOMLSSerializer methods
{.push header: "<xercesc/dom/DOMLSSerializer.hpp>".}
proc release*(serializer: DOMLSSerializerPtr) {.importcpp: "#->release()".}
proc writeToString*(
  serializer: DOMLSSerializerPtr, node: DOMNodePtr
): ptr XMLCh {.importcpp: "const_cast<XMLCh*>(#->writeToString(#))".}

proc getDomConfig*(
  serializer: DOMLSSerializerPtr
): DOMConfigurationPtr {.importcpp: "#->getDomConfig()".}

proc setNewLine*(
  serializer: DOMLSSerializerPtr, newLine: ptr XMLCh
) {.importcpp: "#->setNewLine(#)".}

proc getNewLine*(
  serializer: DOMLSSerializerPtr
): ptr XMLCh {.importcpp: "const_cast<XMLCh*>(#->getNewLine())".}

{.pop.}

# DOMLSOutput methods
{.push header: "<xercesc/dom/DOMLSOutput.hpp>".}
proc release*(output: DOMLSOutputPtr) {.importcpp: "#->release()".}
proc setByteStream*(
  output: DOMLSOutputPtr, stream: pointer
) {.importcpp: "#->setByteStream(#)".}

proc setEncoding*(
  output: DOMLSOutputPtr, encoding: ptr XMLCh
) {.importcpp: "#->setEncoding(#)".}

proc getEncoding*(
  output: DOMLSOutputPtr
): ptr XMLCh {.importcpp: "const_cast<XMLCh*>(#->getEncoding())".}

{.pop.}

# DOMConfiguration methods
{.push header: "<xercesc/dom/DOMConfiguration.hpp>".}
proc setParameter*(
  config: DOMConfigurationPtr, name: ptr XMLCh, value: bool
) {.importcpp: "#->setParameter(#, #)".}

proc setParameter*(
  config: DOMConfigurationPtr, name: ptr XMLCh, value: pointer
) {.importcpp: "#->setParameter(#, #)".}

proc getParameter*(
  config: DOMConfigurationPtr, name: ptr XMLCh
): pointer {.importcpp: "#->getParameter(#)".}

proc canSetParameter*(
  config: DOMConfigurationPtr, name: ptr XMLCh, value: bool
): bool {.importcpp: "#->canSetParameter(#, #)".}

{.pop.}

# DOMImplementationLS for creating serializers
{.push header: "<xercesc/dom/DOMImplementationLS.hpp>".}

type DOMImplementationLS* {.importcpp: "xercesc::DOMImplementationLS".} = object

proc createLSSerializer*(
  impl: ptr DOMImplementationLS
): DOMLSSerializerPtr {.importcpp: "#->createLSSerializer()".}

proc createLSOutput*(
  impl: ptr DOMImplementationLS
): DOMLSOutputPtr {.importcpp: "#->createLSOutput()".}

{.pop.}

# DOMImplementationRegistry for getting implementations
{.push header: "<xercesc/dom/DOMImplementationRegistry.hpp>".}

type DOMImplementationRegistry* {.importcpp: "xercesc::DOMImplementationRegistry".} = object

proc getDOMImplementationImpl(
  features: ptr XMLCh
): DOMImplementationPtr {.
  importcpp: "xercesc::DOMImplementationRegistry::getDOMImplementation(@)"
.}

{.pop.}

proc getDOMImplementation*(
    _: typedesc[DOMImplementationRegistry], features: ptr XMLCh
): DOMImplementationPtr =
  getDOMImplementationImpl(features)

# Helper to cast DOMImplementation to DOMImplementationLS
proc toLSImpl*(
  impl: DOMImplementationPtr
): ptr DOMImplementationLS {.importcpp: "(xercesc::DOMImplementationLS*)(#)".}
