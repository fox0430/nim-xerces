#ifndef NIM_ERROR_HANDLER_HPP
#define NIM_ERROR_HANDLER_HPP

#include <xercesc/sax/ErrorHandler.hpp>
#include <xercesc/sax/SAXParseException.hpp>
#include <xercesc/util/XMLString.hpp>
#include <vector>
#include <string>

// Error entry stored by the handler
struct NimXercesError {
    int level;  // 0=warning, 1=error, 2=fatal
    std::string message;
    int line;
    int column;
};

// C++ ErrorHandler implementation that stores errors
class NimErrorHandler : public xercesc::ErrorHandler {
private:
    std::vector<NimXercesError> errors_;

    std::string getMessage(const xercesc::SAXParseException& e) {
        const XMLCh* msg = e.getMessage();
        if (!msg) return "Unknown error";
        char* cstr = xercesc::XMLString::transcode(msg);
        std::string result(cstr);
        xercesc::XMLString::release(&cstr);
        return result;
    }

public:
    NimErrorHandler() {}

    void warning(const xercesc::SAXParseException& e) override {
        NimXercesError err;
        err.level = 0;
        err.message = getMessage(e);
        err.line = (int)e.getLineNumber();
        err.column = (int)e.getColumnNumber();
        errors_.push_back(err);
    }

    void error(const xercesc::SAXParseException& e) override {
        NimXercesError err;
        err.level = 1;
        err.message = getMessage(e);
        err.line = (int)e.getLineNumber();
        err.column = (int)e.getColumnNumber();
        errors_.push_back(err);
    }

    void fatalError(const xercesc::SAXParseException& e) override {
        NimXercesError err;
        err.level = 2;
        err.message = getMessage(e);
        err.line = (int)e.getLineNumber();
        err.column = (int)e.getColumnNumber();
        errors_.push_back(err);
    }

    void resetErrors() override {
        errors_.clear();
    }

    // Accessors for Nim
    size_t getErrorCount() const { return errors_.size(); }

    int getErrorLevel(size_t i) const {
        return i < errors_.size() ? errors_[i].level : -1;
    }

    const char* getErrorMessage(size_t i) const {
        return i < errors_.size() ? errors_[i].message.c_str() : "";
    }

    int getErrorLine(size_t i) const {
        return i < errors_.size() ? errors_[i].line : 0;
    }

    int getErrorColumn(size_t i) const {
        return i < errors_.size() ? errors_[i].column : 0;
    }

    bool hasErrors() const {
        for (const auto& e : errors_) {
            if (e.level >= 1) return true;
        }
        return false;
    }

    bool hasFatalErrors() const {
        for (const auto& e : errors_) {
            if (e.level >= 2) return true;
        }
        return false;
    }
};

#endif // NIM_ERROR_HANDLER_HPP
