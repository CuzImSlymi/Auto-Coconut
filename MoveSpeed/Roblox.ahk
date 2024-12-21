/***********************************************************
* @description: Functions for automating the Roblox window
* @author SP
***********************************************************/

; Updates global variables windowX, windowY, windowWidth, windowHeight
; Optionally takes a known window handle to skip GetRobloxHWND call
; Returns: 1 = successful; 0 = TargetError
#Include 'Gdip_All.ahk'
#Include 'Gdip_ImageSearch.ahk'
pToken := Gdip_StartUp()

(bitmaps := Map()).CaseSense := 0
bitmaps["toppollen"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAACkAAAAKBAMAAADbdmpdAAAAFVBMVEUAAAASFRcTFhgUFxkUFxgWGRsXGht4cWVYAAAAAXRSTlMAQObYZgAAABd0RVh0U29mdHdhcmUAUGhvdG9EZW1vbiA5LjDNHNgxAAADWGlUWHRYTUw6Y29tLmFkb2JlLnhtcAAAAAAAPD94cGFja2V0IGJlZ2luPSfvu78nIGlkPSdXNU0wTXBDZWhpSHpyZVN6TlRjemtjOWQnPz4KPHg6eG1wbWV0YSB4bWxuczp4PSdhZG9iZTpuczptZXRhLycgeDp4bXB0az0nSW1hZ2U6OkV4aWZUb29sIDEyLjQ0Jz4KPHJkZjpSREYgeG1sbnM6cmRmPSdodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjJz4KCiA8cmRmOkRlc2NyaXB0aW9uIHJkZjphYm91dD0nJwogIHhtbG5zOmV4aWY9J2h0dHA6Ly9ucy5hZG9iZS5jb20vZXhpZi8xLjAvJz4KICA8ZXhpZjpQaXhlbFhEaW1lbnNpb24+NDE8L2V4aWY6UGl4ZWxYRGltZW5zaW9uPgogIDxleGlmOlBpeGVsWURpbWVuc2lvbj4xMDwvZXhpZjpQaXhlbFlEaW1lbnNpb24+CiA8L3JkZjpEZXNjcmlwdGlvbj4KCiA8cmRmOkRlc2NyaXB0aW9uIHJkZjphYm91dD0nJwogIHhtbG5zOnRpZmY9J2h0dHA6Ly9ucy5hZG9iZS5jb20vdGlmZi8xLjAvJz4KICA8dGlmZjpJbWFnZUxlbmd0aD4xMDwvdGlmZjpJbWFnZUxlbmd0aD4KICA8dGlmZjpJbWFnZVdpZHRoPjQxPC90aWZmOkltYWdlV2lkdGg+CiAgPHRpZmY6T3JpZW50YXRpb24+MTwvdGlmZjpPcmllbnRhdGlvbj4KICA8dGlmZjpSZXNvbHV0aW9uVW5pdD4yPC90aWZmOlJlc29sdXRpb25Vbml0PgogIDx0aWZmOlNvZnR3YXJlPlBob3RvRGVtb24gOS4wPC90aWZmOlNvZnR3YXJlPgogIDx0aWZmOlhSZXNvbHV0aW9uPjk2LzE8L3RpZmY6WFJlc29sdXRpb24+CiAgPHRpZmY6WVJlc29sdXRpb24+OTYvMTwvdGlmZjpZUmVzb2x1dGlvbj4KIDwvcmRmOkRlc2NyaXB0aW9uPgo8L3JkZjpSREY+CjwveDp4bXBtZXRhPgo8P3hwYWNrZXQgZW5kPSdyJz8+BUybogAAAEZJREFUeNqFzcEJgEAQA8A5Ud8bbMj+qxLxPHwosq8dSCIJUBqM50vXN21J14SkJNvpl85UP6LVHfrT0TBh6HNtH2oBgFIHi0UEEPtLIT4AAAAASUVORK5CYII=")
bitmaps["toppollenfill"] := Gdip_CreateBitmap(41,10), pGraphics := Gdip_GraphicsFromImage(bitmaps["toppollenfill"]), Gdip_GraphicsClear(pGraphics, 0xff121517), Gdip_DeleteGraphics(pGraphics)

; MsgBox(bitmaps['toppollen'])
; MsgBox(bitmaps['toppollenfill'])

GetRobloxClientPos(hwnd?)
{
    global windowX, windowY, windowWidth, windowHeight
    if !IsSet(hwnd)
        hwnd := GetRobloxHWND()

    try
        WinGetClientPos &windowX, &windowY, &windowWidth, &windowHeight, "ahk_id " hwnd
    catch TargetError
        return windowX := windowY := windowWidth := windowHeight := 0
    else
        return 1
}

; Returns: hWnd = successful; 0 = window not found
GetRobloxHWND()
{
	if (hwnd := WinExist("Roblox ahk_exe RobloxPlayerBeta.exe"))
		return hwnd
	else if (WinExist("Roblox ahk_exe ApplicationFrameHost.exe"))
    {
        try
            hwnd := ControlGetHwnd("ApplicationFrameInputSinkWindow1")
        catch TargetError
		    hwnd := 0
        return hwnd
    }
	else
		return 0
}

; Finds the y-offset of GUI elements in the current Roblox window
; Image is specific to BSS but can be altered for use in other games
; Optionally takes a known window handle to skip GetRobloxHWND call
; Returns: offset (integer), defaults to 0 on fail (ByRef param fail is then set to 1, else 0)
GetYOffset(hwnd?, &fail?)
{
	global bitmaps
	static hRoblox := 0, offset := 0
    if !IsSet(hwnd)
        hwnd := GetRobloxHWND()

	if (hwnd = hRoblox)
	{
		fail := 0
		return offset
	}
	else if WinExist("ahk_id " hwnd)
	{
		try WinActivate "Roblox"
		GetRobloxClientPos(hwnd)
		pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2 "|" windowY "|60|100")

		Loop 20 ; for red vignette effect
		{ 
			if ((Gdip_ImageSearch(pBMScreen, bitmaps["toppollen"], &pos, , , , , 20) = 1)
				&& (Gdip_ImageSearch(pBMScreen, bitmaps["toppollenfill"], , x := SubStr(pos, 1, (comma := InStr(pos, ",")) - 1), y := SubStr(pos, comma + 1), x + 41, y + 10, 20) = 0))
			{
				Gdip_DisposeImage(pBMScreen)
				hRoblox := hwnd, fail := 0
				return offset := y - 14
			}
			else
			{
				if (A_Index = 20)
				{
					Gdip_DisposeImage(pBMScreen), fail := 1
					return 0 ; default offset, change this if needed
				}
				else
				{
					Sleep 50
					Gdip_DisposeImage(pBMScreen)
					pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2 "|" windowY "|60|100")
				}				
			}
		}
	}
	else
		return 0
}

; Returns: 1 = successful; 0 = TargetError
ActivateRoblox()
{
	try
		WinActivate "Roblox"
	catch
		return 0
	else
		return 1
}
offsetY := GetYOffset()
; f2::GetYOffset()