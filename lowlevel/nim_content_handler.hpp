#ifndef NIM_CONTENT_HANDLER_HPP
#define NIM_CONTENT_HANDLER_HPP

#include <xercesc/sax2/ContentHandler.hpp>
#include <xercesc/sax2/Attributes.hpp>
#include <xercesc/sax/Locator.hpp>
#include <xercesc/util/XMLString.hpp>

// Callback function types for Nim (non-const to match Nim's cstring)
extern "C" {
    typedef void (*NimStartDocumentCallback)(void* userData);
    typedef void (*NimEndDocumentCallback)(void* userData);
    typedef void (*NimStartElementCallback)(
        void* userData,
        char* uri,
        char* localName,
        char* qName,
        xercesc::Attributes* attrs
    );
    typedef void (*NimEndElementCallback)(
        void* userData,
        char* uri,
        char* localName,
        char* qName
    );
    typedef void (*NimCharactersCallback)(
        void* userData,
        char* chars,
        XMLSize_t length
    );
    typedef void (*NimIgnorableWhitespaceCallback)(
        void* userData,
        char* chars,
        XMLSize_t length
    );
    typedef void (*NimProcessingInstructionCallback)(
        void* userData,
        char* target,
        char* data
    );
    typedef void (*NimStartPrefixMappingCallback)(
        void* userData,
        char* prefix,
        char* uri
    );
    typedef void (*NimEndPrefixMappingCallback)(
        void* userData,
        char* prefix
    );
}

// C++ ContentHandler implementation that calls Nim callbacks
class NimContentHandler : public xercesc::ContentHandler {
private:
    void* userData_;
    NimStartDocumentCallback onStartDocument_;
    NimEndDocumentCallback onEndDocument_;
    NimStartElementCallback onStartElement_;
    NimEndElementCallback onEndElement_;
    NimCharactersCallback onCharacters_;
    NimIgnorableWhitespaceCallback onIgnorableWhitespace_;
    NimProcessingInstructionCallback onProcessingInstruction_;
    NimStartPrefixMappingCallback onStartPrefixMapping_;
    NimEndPrefixMappingCallback onEndPrefixMapping_;
    const xercesc::Locator* locator_;

    // Helper to convert XMLCh* to C string (caller must free with releaseTranscoded)
    static char* transcodeToC(const XMLCh* xmlStr) {
        if (!xmlStr) return nullptr;
        return xercesc::XMLString::transcode(xmlStr);
    }

    static void releaseTranscoded(char* str) {
        if (str) xercesc::XMLString::release(&str);
    }

public:
    NimContentHandler()
        : userData_(nullptr)
        , onStartDocument_(nullptr)
        , onEndDocument_(nullptr)
        , onStartElement_(nullptr)
        , onEndElement_(nullptr)
        , onCharacters_(nullptr)
        , onIgnorableWhitespace_(nullptr)
        , onProcessingInstruction_(nullptr)
        , onStartPrefixMapping_(nullptr)
        , onEndPrefixMapping_(nullptr)
        , locator_(nullptr)
    {}

    // Setters for callbacks
    void setUserData(void* data) { userData_ = data; }
    void setStartDocumentCallback(NimStartDocumentCallback cb) { onStartDocument_ = cb; }
    void setEndDocumentCallback(NimEndDocumentCallback cb) { onEndDocument_ = cb; }
    void setStartElementCallback(NimStartElementCallback cb) { onStartElement_ = cb; }
    void setEndElementCallback(NimEndElementCallback cb) { onEndElement_ = cb; }
    void setCharactersCallback(NimCharactersCallback cb) { onCharacters_ = cb; }
    void setIgnorableWhitespaceCallback(NimIgnorableWhitespaceCallback cb) { onIgnorableWhitespace_ = cb; }
    void setProcessingInstructionCallback(NimProcessingInstructionCallback cb) { onProcessingInstruction_ = cb; }
    void setStartPrefixMappingCallback(NimStartPrefixMappingCallback cb) { onStartPrefixMapping_ = cb; }
    void setEndPrefixMappingCallback(NimEndPrefixMappingCallback cb) { onEndPrefixMapping_ = cb; }

    // Locator access
    const xercesc::Locator* getLocator() const { return locator_; }

    // ContentHandler interface implementation
    void setDocumentLocator(const xercesc::Locator* const locator) override {
        locator_ = locator;
    }

    void startDocument() override {
        if (onStartDocument_) onStartDocument_(userData_);
    }

    void endDocument() override {
        if (onEndDocument_) onEndDocument_(userData_);
    }

    // Helper for empty string fallback (avoids const_cast on literal)
    static char* emptyStr(char* s) {
        static char empty[] = "";
        return s ? s : empty;
    }

    void startElement(
        const XMLCh* const uri,
        const XMLCh* const localName,
        const XMLCh* const qName,
        const xercesc::Attributes& attrs
    ) override {
        if (onStartElement_) {
            char* cUri = transcodeToC(uri);
            char* cLocalName = transcodeToC(localName);
            char* cQName = transcodeToC(qName);
            onStartElement_(userData_, emptyStr(cUri), emptyStr(cLocalName), emptyStr(cQName), const_cast<xercesc::Attributes*>(&attrs));
            releaseTranscoded(cUri);
            releaseTranscoded(cLocalName);
            releaseTranscoded(cQName);
        }
    }

    void endElement(
        const XMLCh* const uri,
        const XMLCh* const localName,
        const XMLCh* const qName
    ) override {
        if (onEndElement_) {
            char* cUri = transcodeToC(uri);
            char* cLocalName = transcodeToC(localName);
            char* cQName = transcodeToC(qName);
            onEndElement_(userData_, emptyStr(cUri), emptyStr(cLocalName), emptyStr(cQName));
            releaseTranscoded(cUri);
            releaseTranscoded(cLocalName);
            releaseTranscoded(cQName);
        }
    }

    void characters(const XMLCh* const chars, const XMLSize_t length) override {
        if (onCharacters_) {
            char* cChars = transcodeToC(chars);
            onCharacters_(userData_, emptyStr(cChars), length);
            releaseTranscoded(cChars);
        }
    }

    void ignorableWhitespace(const XMLCh* const chars, const XMLSize_t length) override {
        if (onIgnorableWhitespace_) {
            char* cChars = transcodeToC(chars);
            onIgnorableWhitespace_(userData_, emptyStr(cChars), length);
            releaseTranscoded(cChars);
        }
    }

    void processingInstruction(
        const XMLCh* const target,
        const XMLCh* const data
    ) override {
        if (onProcessingInstruction_) {
            char* cTarget = transcodeToC(target);
            char* cData = transcodeToC(data);
            onProcessingInstruction_(userData_, emptyStr(cTarget), emptyStr(cData));
            releaseTranscoded(cTarget);
            releaseTranscoded(cData);
        }
    }

    void startPrefixMapping(
        const XMLCh* const prefix,
        const XMLCh* const uri
    ) override {
        if (onStartPrefixMapping_) {
            char* cPrefix = transcodeToC(prefix);
            char* cUri = transcodeToC(uri);
            onStartPrefixMapping_(userData_, emptyStr(cPrefix), emptyStr(cUri));
            releaseTranscoded(cPrefix);
            releaseTranscoded(cUri);
        }
    }

    void endPrefixMapping(const XMLCh* const prefix) override {
        if (onEndPrefixMapping_) {
            char* cPrefix = transcodeToC(prefix);
            onEndPrefixMapping_(userData_, emptyStr(cPrefix));
            releaseTranscoded(cPrefix);
        }
    }

    void skippedEntity(const XMLCh* const name) override {
        // Not commonly used, ignoring for now
    }
};

#endif // NIM_CONTENT_HANDLER_HPP
