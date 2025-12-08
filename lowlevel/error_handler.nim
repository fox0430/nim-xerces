import std/os
import types

# C++ ErrorHandler wrapper that can be set on XercesDOMParser
# and collects parse errors accessible from Nim

const nimErrorHandlerHeader = "nim_error_handler.hpp"

# Add include path for the header (path to this file's directory)
{.passC: "-I" & currentSourcePath().parentDir().}

type
  NimErrorHandler* {.importcpp: "NimErrorHandler", header: nimErrorHandlerHeader.} = object
  NimErrorHandlerPtr* = ptr NimErrorHandler

{.push header: nimErrorHandlerHeader.}

# Constructor/destructor
proc newNimErrorHandlerImpl(): NimErrorHandlerPtr {.importcpp: "new NimErrorHandler()".}
proc deleteNimErrorHandler*(handler: NimErrorHandlerPtr) {.importcpp: "delete #".}

# Accessors
proc getErrorCount*(
  handler: NimErrorHandlerPtr
): csize_t {.importcpp: "#->getErrorCount()".}

proc getErrorLevel(
  handler: NimErrorHandlerPtr, i: csize_t
): cint {.importcpp: "#->getErrorLevel(#)".}

proc getErrorMessage(
  handler: NimErrorHandlerPtr, i: csize_t
): cstring {.importcpp: "#->getErrorMessage(#)".}

proc getErrorLine(
  handler: NimErrorHandlerPtr, i: csize_t
): cint {.importcpp: "#->getErrorLine(#)".}

proc getErrorColumn(
  handler: NimErrorHandlerPtr, i: csize_t
): cint {.importcpp: "#->getErrorColumn(#)".}

proc hasErrorsImpl(handler: NimErrorHandlerPtr): bool {.importcpp: "#->hasErrors()".}
proc hasFatalErrorsImpl(
  handler: NimErrorHandlerPtr
): bool {.importcpp: "#->hasFatalErrors()".}

proc resetErrors*(handler: NimErrorHandlerPtr) {.importcpp: "#->resetErrors()".}

# Cast to ErrorHandler* for setErrorHandler
proc toErrorHandler*(
  handler: NimErrorHandlerPtr
): ptr ErrorHandler {.importcpp: "static_cast<xercesc::ErrorHandler*>(#)".}

{.pop.}

# High-level Nim wrapper
type
  ParseErrorLevel* = enum
    pelWarning
    pelError
    pelFatalError

  ParseError* = object
    level*: ParseErrorLevel
    message*: string
    line*: int
    column*: int

  XercesErrorHandlerObj* = object
    impl*: NimErrorHandlerPtr

  XercesErrorHandler* = ref XercesErrorHandlerObj

proc `=destroy`(handler: XercesErrorHandlerObj) =
  if handler.impl != nil:
    deleteNimErrorHandler(handler.impl)

proc newXercesErrorHandler*(): XercesErrorHandler =
  ## Create a new error handler that can be set on a parser
  result = XercesErrorHandler(impl: newNimErrorHandlerImpl())

proc destroy*(handler: XercesErrorHandler) =
  ## Explicitly clean up the error handler.
  ## Note: Resources are automatically freed when the handler is garbage collected,
  ## so calling this is optional but can be used for deterministic cleanup.
  if handler.impl != nil:
    deleteNimErrorHandler(handler.impl)
    handler.impl = nil

proc errorCount*(handler: XercesErrorHandler): int =
  ## Get number of collected errors
  if handler.impl != nil:
    result = handler.impl.getErrorCount().int

proc getError*(handler: XercesErrorHandler, index: int): ParseError =
  ## Get error at index
  if handler.impl != nil and index >= 0 and index < handler.errorCount:
    let level = handler.impl.getErrorLevel(index.csize_t)
    result.level =
      case level
      of 0: pelWarning
      of 1: pelError
      else: pelFatalError
    result.message = $handler.impl.getErrorMessage(index.csize_t)
    result.line = handler.impl.getErrorLine(index.csize_t).int
    result.column = handler.impl.getErrorColumn(index.csize_t).int

proc hasErrors*(handler: XercesErrorHandler): bool =
  ## Check if any errors (not just warnings) occurred
  if handler.impl != nil:
    result = handler.impl.hasErrorsImpl()

proc hasFatalErrors*(handler: XercesErrorHandler): bool =
  ## Check if any fatal errors occurred
  if handler.impl != nil:
    result = handler.impl.hasFatalErrorsImpl()

proc clear*(handler: XercesErrorHandler) =
  ## Clear all collected errors
  if handler.impl != nil:
    handler.impl.resetErrors()

iterator errors*(handler: XercesErrorHandler): ParseError =
  ## Iterate over all collected errors
  for i in 0 ..< handler.errorCount:
    yield handler.getError(i)

iterator items*(handler: XercesErrorHandler): ParseError =
  ## Iterate over all collected errors
  for e in handler.errors:
    yield e
