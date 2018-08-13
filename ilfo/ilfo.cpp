#include "stdafx.h"

extern "C" __declspec(dllexport) int GetKeyboardLayoutIndex();
extern "C" __declspec(dllexport) bool SetKeyboardLayoutIndex(int index);
extern "C" __declspec(dllexport) bool GetActiveKeyboardLayoutLanguage(::HWND window, wchar_t * buffer);
extern "C" __declspec(dllexport) bool CopyKeyboardLayout(::HWND from_window);

int GetKeyboardLayoutIndex()
{
    int length = ::GetKeyboardLayoutList(0, nullptr);
    if (length == 0)
    {
        return -1;
    }
    ::HKL * layouts = new ::HKL[length];
    length = ::GetKeyboardLayoutList(length, layouts);
    if (length == 0)
    {
        return -1;
    }
    ::HKL current_layout = ::GetKeyboardLayout(0);
    for (int i = 0; i < length; i++)
    {
        ::HKL layout = layouts[i];
        if (layout == current_layout)
        {
            return i;
        }
    }
    return -1;
}

bool SetKeyboardLayoutIndex(int index)
{
    int length = ::GetKeyboardLayoutList(0, nullptr);
    if (length == 0)
    {
        return false;
    }
    ::HKL * layouts = new ::HKL[length];
    length = ::GetKeyboardLayoutList(length, layouts);
    if (length == 0)
    {
        return false;
    }
    if (index >= 0 && index < length)
    {
        ::HKL layout = layouts[index];
        return ::ActivateKeyboardLayout(layout, KLF_SETFORPROCESS) != 0;
    }
    return false;
}

bool GetActiveKeyboardLayoutLanguage(::HWND window, wchar_t * buffer)
{
    ::DWORD thread_id = ::GetWindowThreadProcessId(window, nullptr);
    ::HKL layout = ::GetKeyboardLayout(thread_id);
    ::LANGID lang = LOWORD(layout);
    ::LCID locale = MAKELCID(lang, SORT_DEFAULT);
    int length = GetLocaleInfoW(locale, LOCALE_SISO639LANGNAME, nullptr, 0);
    wchar_t * code = new wchar_t[length];
    ::GetLocaleInfoW(locale, LOCALE_SISO639LANGNAME, code, length);
    return ::wcscpy_s(buffer, length, code) == 0;
}

bool CopyKeyboardLayout(::HWND from_window)
{
    ::DWORD from_thread_id = ::GetWindowThreadProcessId(from_window, nullptr);
    ::HKL from_layout = ::GetKeyboardLayout(from_thread_id);
    if (from_layout == nullptr) {
        return false;
    }
    return ::ActivateKeyboardLayout(from_layout, KLF_SETFORPROCESS) != 0;
}
