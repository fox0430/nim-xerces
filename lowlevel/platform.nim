import types

{.push header: "<xercesc/util/PlatformUtils.hpp>".}

type XMLPlatformUtils* {.importcpp: "xercesc::XMLPlatformUtils".} = object

proc initialize*(
  _: typedesc[XMLPlatformUtils]
) {.importcpp: "xercesc::XMLPlatformUtils::Initialize()".}

proc terminate*(
  _: typedesc[XMLPlatformUtils]
) {.importcpp: "xercesc::XMLPlatformUtils::Terminate()".}

{.pop.}

template withXerces*(body: untyped) =
  ## Initialize Xerces, execute body, and terminate Xerces
  XMLPlatformUtils.initialize()
  try:
    body
  finally:
    XMLPlatformUtils.terminate()
