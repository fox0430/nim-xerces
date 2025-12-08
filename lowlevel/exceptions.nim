import types

# Result type for exception-safe operations
type
  XercesErrorKind* = enum
    xekXMLException
    xekDOMException
    xekSAXException
    xekSAXParseException
    xekUnknown

  XercesResult*[T] = object
    case success*: bool
    of true:
      when T isnot void:
        value*: T
    of false:
      errorKind*: XercesErrorKind
      errorMessage*: string
      line*: int
      column*: int

proc ok*[T](value: T): XercesResult[T] =
  result = XercesResult[T](success: true)
  when T isnot void:
    result.value = value

proc okVoid*(): XercesResult[void] =
  XercesResult[void](success: true)

proc err*[T](
    kind: XercesErrorKind, msg: string, line: int = 0, col: int = 0
): XercesResult[T] =
  XercesResult[T](
    success: false, errorKind: kind, errorMessage: msg, line: line, column: col
  )

proc isOk*[T](r: XercesResult[T]): bool =
  r.success

proc isErr*[T](r: XercesResult[T]): bool =
  not r.success

proc get*[T](r: XercesResult[T]): T =
  if r.success:
    when T isnot void:
      result = r.value
  else:
    raise newException(XercesError, r.errorMessage)

proc getOrDefault*[T](r: XercesResult[T], default: T): T =
  when T isnot void:
    if r.success: r.value else: default
