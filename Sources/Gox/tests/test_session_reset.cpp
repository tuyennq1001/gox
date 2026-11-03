#include <iostream>
#include <string>
#include <cassert>
#include <map>
#include "Engine.h"

// Define engine global configurations
int vLanguage = 1;
int vInputType = 0; // Telex
int vFreeMark = 0;
int vCodeTable = 0;
int vSwitchKeyStatus = 0;
int vCheckSpelling = 1;
int vUseModernOrthography = 1;
int vQuickTelex = 0;
int vRestoreIfWrongSpelling = 1;
int vFixRecommendBrowser = 1;
int vUseMacro = 0;
int vUseMacroInEnglishMode = 0;
int vAutoCapsMacro = 0;
int vUseSmartSwitchKey = 1;
int vUpperCaseFirstChar = 0;
int vTempOffSpelling = 0;
int vAllowConsonantZFWJ = 0;
int vQuickStartConsonant = 0;
int vQuickEndConsonant = 0;
int vRememberCode = 0;
int vOtherLanguage = 1;
int vTempOffOpenKey = 0;

static vKeyHookState* pState;
static std::u16string screenText;

static std::map<char, int> keyMap = {
    {'a', KEY_A}, {'b', KEY_B}, {'c', KEY_C}, {'d', KEY_D}, {'e', KEY_E}, {'f', KEY_F},
    {'g', KEY_G}, {'h', KEY_H}, {'i', KEY_I}, {'j', KEY_J}, {'k', KEY_K}, {'l', KEY_L},
    {'m', KEY_M}, {'n', KEY_N}, {'o', KEY_O}, {'p', KEY_P}, {'q', KEY_Q}, {'r', KEY_R},
    {'s', KEY_S}, {'t', KEY_T}, {'u', KEY_U}, {'v', KEY_V}, {'w', KEY_W}, {'x', KEY_X},
    {'y', KEY_Y}, {'z', KEY_Z}, {' ', KEY_SPACE}
};

static char16_t toUnicodeChar(Uint32 c) {
    if (c & CHAR_CODE_MASK) return (char16_t)(c & 0xFFFF);
    Uint32 g = getCharacterCode(c);
    if (g & CHAR_CODE_MASK) return (char16_t)(g & 0xFFFF);
    for (auto& e : keyMap) {
        if (e.second == (int)(c & 0xFFFF)) {
            return (char16_t)((c & CAPS_MASK) ? toupper(e.first) : e.first);
        }
    }
    return u'?';
}

static std::string toUtf8(const std::u16string& u16) {
    std::string out;
    for (char16_t c : u16) {
        if (c < 0x80) out += (char)c;
        else if (c < 0x800) { out += (char)(0xC0 | (c >> 6)); out += (char)(0x80 | (c & 0x3F)); }
        else { out += (char)(0xE0 | (c >> 12)); out += (char)(0x80 | ((c >> 6) & 0x3F)); out += (char)(0x80 | (c & 0x3F)); }
    }
    return out;
}

static void typeString(const std::string& str) {
    for (char ch : str) {
        int key = keyMap[ch];
        vKeyHandleEvent(vKeyEvent::Keyboard, vKeyEventState::KeyDown, key, 0, false);
        if (pState->code == vDoNothing) {
            screenText += (char16_t)ch;
            continue;
        }
        for (int i = 0; i < pState->backspaceCount && !screenText.empty(); i++) {
            screenText.pop_back();
        }
        for (int k = pState->newCharCount - 1; k >= 0; k--) {
            screenText += toUnicodeChar(pState->charData[k]);
        }
        if (pState->code == vRestore || pState->code == vRestoreAndStartNewSession) {
            screenText += (char16_t)ch;
        }
        if (pState->code == vRestoreAndStartNewSession) {
            startNewSession();
        }
    }
}

static void sendMouseReset() {
    vKeyHandleEvent(vKeyEvent::Mouse, vKeyEventState::MouseDown, 0);
}

int main() {
    std::cout << "Running Gox Engine Session Reset Regression Tests..." << std::endl;
    pState = (vKeyHookState*)vKeyInit();

    // Test 1: Normal typing
    {
        screenText.clear();
        sendMouseReset();
        typeString("neeus ");
        assert(toUtf8(screenText) == "nếu ");
        std::cout << "PASS Test 1: Normal Telex typing ('neeus ' -> 'nếu ')" << std::endl;
    }

    // Test 2: Incomplete valid word in App A interrupted by mouse click / session reset
    {
        screenText.clear();
        sendMouseReset();
        typeString("xin"); // incomplete word
        assert(toUtf8(screenText) == "xin");

        // Session reset on context change
        sendMouseReset();
        screenText.clear();

        typeString("neeus ");
        assert(toUtf8(screenText) == "nếu ");
        std::cout << "PASS Test 2: Incomplete word reset ('xin' -> click -> 'neeus ' -> 'nếu ')" << std::endl;
    }

    // Test 3: Incomplete misspelled word with tone in App A interrupted by mouse click
    {
        screenText.clear();
        sendMouseReset();
        typeString("baansk"); // produces bấnk (invalid spelling with tone)
        assert(toUtf8(screenText) == "bấnk");

        // Mouse click / app switch
        sendMouseReset();
        screenText.clear();

        typeString("neeus ");
        assert(toUtf8(screenText) == "nếu ");
        std::cout << "PASS Test 3: Misspelled word with tone reset ('baansk' -> click -> 'neeus ' -> 'nếu ')" << std::endl;
    }

    // Test 4: Incomplete word in App A interrupted by mouse click / app switch
    {
        screenText.clear();
        sendMouseReset();
        typeString("carrier");

        sendMouseReset();
        screenText.clear();

        typeString("vaayj ");
        assert(toUtf8(screenText) == "vậy ");
        std::cout << "PASS Test 4: Stale word reset ('carrier' -> click -> 'vaayj ' -> 'vậy ')" << std::endl;
    }

    // Test 5: JIS Eisu (102) keypress before typing 'neeus' -> must compose to 'nếu'
    {
        screenText.clear();
        sendMouseReset();
        // Simulate hardware Eisu key
        vKeyHandleEvent(vKeyEvent::Keyboard, vKeyEventState::KeyDown, 102, 0, false);

        typeString("neeus ");
        assert(toUtf8(screenText) == "nếu ");
        std::cout << "PASS Test 5: JIS Eisu (102) key ('neeus ' -> 'nếu ')" << std::endl;
    }

    // Test 6: JIS Eisu (102) keypress before typing 'khacsh' -> must compose to 'khách'
    {
        screenText.clear();
        sendMouseReset();
        vKeyHandleEvent(vKeyEvent::Keyboard, vKeyEventState::KeyDown, 102, 0, false);

        typeString("khacsh ");
        assert(toUtf8(screenText) == "khách ");
        std::cout << "PASS Test 6: JIS Eisu (102) key ('khacsh ' -> 'khách ')" << std::endl;
    }

    // Test 7: JIS Eisu (102) keypress before typing 'seeps' -> must compose to 'sếp'
    {
        screenText.clear();
        sendMouseReset();
        vKeyHandleEvent(vKeyEvent::Keyboard, vKeyEventState::KeyDown, 102, 0, false);

        typeString("seeps ");
        assert(toUtf8(screenText) == "sếp ");
        std::cout << "PASS Test 7: JIS Eisu (102) key ('seeps ' -> 'sếp ')" << std::endl;
    }

    // Test 8: JIS Eisu (102) keypress before typing 'vaayj' -> must compose to 'vậy'
    {
        screenText.clear();
        sendMouseReset();
        vKeyHandleEvent(vKeyEvent::Keyboard, vKeyEventState::KeyDown, 102, 0, false);

        typeString("vaayj ");
        assert(toUtf8(screenText) == "vậy ");
        std::cout << "PASS Test 8: JIS Eisu (102) key ('vaayj ' -> 'vậy ')" << std::endl;
    }

    // Test 9: JIS Kana (104) then Eisu (102) keypress before typing 'khacsh'
    {
        screenText.clear();
        sendMouseReset();
        vKeyHandleEvent(vKeyEvent::Keyboard, vKeyEventState::KeyDown, 104, 0, false);
        vKeyHandleEvent(vKeyEvent::Keyboard, vKeyEventState::KeyDown, 102, 0, false);

        typeString("khacsh ");
        assert(toUtf8(screenText) == "khách ");
        std::cout << "PASS Test 9: JIS Kana (104) + Eisu (102) key ('khacsh ' -> 'khách ')" << std::endl;
    }

    std::cout << "\nALL 9 REGRESSION TESTS PASSED 100%!" << std::endl;
    return 0;
}
