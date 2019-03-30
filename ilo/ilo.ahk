#SingleInstance, Force
#NoEnv
#Warn

; Constants
MODULE := DllCall("LoadLibrary", "Str", "ilo.dll", "Ptr")

GET_KEYBOARD_LAYOUT_INDEX := DllCall("GetProcAddress", "Ptr", MODULE, "AStr", "GetKeyboardLayoutIndex", "Ptr")
SET_KEYBOARD_LAYOUT_INDEX := DllCall("GetProcAddress", "Ptr", MODULE, "AStr", "SetKeyboardLayoutIndex", "Ptr")
GET_ACTIVE_KEYBOARD_LAYOUT_LANGUAGE := DllCall("GetProcAddress", "Ptr", MODULE, "AStr", "GetActiveKeyboardLayoutLanguage", "Ptr")
COPY_KEYBOARD_LAYOUT := DllCall("GetProcAddress", "Ptr", MODULE, "AStr", "CopyKeyboardLayout", "Ptr")

WM_INPUTLANGCHANGEREQUEST = 0x50
INPUTLANGCHANGE_FORWARD = 0x2
INPUTLANGCHANGE_BACKWARD = 0x4
HKL_PREV = 0x0
HKL_NEXT = 0x1

WS_EX_TRANSPARENT = 0x20

; Globals
KeyboardLayoutListIndex := DllCall(GET_KEYBOARD_LAYOUT_INDEX, "Int")

; Variables
SplitPath, A_ScriptName,,,, ScriptNameNoExt
EnvGet, UserProfilePath, USERPROFILE
IniPath := UserProfilePath "\" ScriptNameNoExt ".ini"

; Functions
CopyLayout(Difference)
{
  Global WM_INPUTLANGCHANGEREQUEST
  Global INPUTLANGCHANGE_BACKWARD, INPUTLANGCHANGE_FORWARD
  Global HKL_PREV, HKL_NEXT
  Global COPY_KEYBOARD_LAYOUT, SET_KEYBOARD_LAYOUT_INDEX
  Global KeyboardLayoutListIndex
  If (Difference < 0)
  {
    SendMessage, WM_INPUTLANGCHANGEREQUEST, INPUTLANGCHANGE_BACKWARD, HKL_PREV,, A
  }
  Else
  {
    SendMessage, WM_INPUTLANGCHANGEREQUEST, INPUTLANGCHANGE_FORWARD, HKL_NEXT,, A
  }
  If (!DllCall(COPY_KEYBOARD_LAYOUT, "Ptr", WinExist("A")))
  {
    DllCall(SET_KEYBOARD_LAYOUT_INDEX, "Int", KeyboardLayoutListIndex)
  }
}

UpdateIndex(Difference)
{
  Global KeyboardLayoutListIndex
  KeyboardLayoutListLength := DllCall("GetKeyboardLayoutList", "Int", 0, "Ptr", 0)
  If (Difference < 0)
  {
    If (KeyboardLayoutListIndex == 0)
    {
      KeyboardLayoutListIndex := KeyboardLayoutListLength - 1
    }
    Else
    {
      KeyboardLayoutListIndex--
    }
  }
  Else
  {
    If (KeyboardLayoutListIndex == KeyboardLayoutListLength - 1)
    {
      KeyboardLayoutListIndex := 0
    }
    Else
    {
      KeyboardLayoutListIndex++
    }
  }
  Return
}

GetLanguage(Window)
{
  Global GET_ACTIVE_KEYBOARD_LAYOUT_LANGUAGE
  VarSetCapacity(Language, 9)
  DllCall(GET_ACTIVE_KEYBOARD_LAYOUT_LANGUAGE, "Ptr", Window, "WStr", Language)
  Return Language
}

HideFlag()
{
  Gui, Destroy
  Return
}

ShowFlag()
{
  Global WS_EX_TRANSPARENT
  Global IniPath
  Language := GetLanguage(A_ScriptHwnd)
  HideFlag()
  Gui, Margin , 0, 0
  IniRead, Image, %IniPath%, %Language%, Image, %Language%.png
  If (FileExist(Image))
  {
    Gui, Add, Picture,, %Image%
    Gui, +LastFound -Caption +AlwaysOnTop +ToolWindow -Border -Disabled -SysMenu
    WinSet, ExStyle, +%WS_EX_TRANSPARENT%
    IniRead, Opacity, %IniPath%, Default, Opacity, 20
    Winset, Transparent, %Opacity%
    Gui, Show, NoActivate
    Return
  }
}

; Main
ShowFlag()

; Hotkeys
#Space::
{
  UpdateIndex(1)
  CopyLayout(1)
  ShowFlag()
  Return
}

+#Space::
{
  UpdateIndex(-1)
  CopyLayout(-1)
  ShowFlag()
  Return
}
