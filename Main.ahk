; if it works it fucking works
#Requires AutoHotkey v2.0
COCONUT_COLOR := "0x40FF41"
TILE_SIZE := 47  ; pixels per tile
SCREEN_WIDTH := 1920
SCREEN_HEIGHT := 1080

global movespeed := InputBox("Enter your Movespeed", "Enter Movespeed").value
if movespeed = "" {
    MsgBox("Please enter a Valid Movespeed `nExiting...")
    exitapp
}

if(!A_ScreenWidth = 1920 and !A_ScreenHeight = 1080) {
    MsgBox("Your Resolution will not work with this Program`nPlease use 1920x1080")
}

#Include MoveSpeed\Walk.ahk

PixelsToTiles(pixels) {
    return Round(pixels / TILE_SIZE)
}

Move(tileamount, key1, key2:=0) {
	send "{" key1 " down}"
	if key2 {
		send "{" key2 " down}"
	}

	Walk(tileamount)

	send "{" key1 " up}"
	if key2 {
		send "{" key2 " up}"
	}
}

FindCoconut() {
    if (PixelSearch(&x, &y, 0, 0, SCREEN_WIDTH, SCREEN_HEIGHT, COCONUT_COLOR)) {
        centerX := SCREEN_WIDTH / 2
        centerY := SCREEN_HEIGHT / 2
        
        diffX := x - centerX
        diffY := y - centerY
        
        tilesX := PixelsToTiles(Abs(diffX))
        tilesY := PixelsToTiles(Abs(diffY))
        
        if (diffX < 0)
            Move(tilesX, "a")  
        else if (diffX > 0)
            Move(tilesX, "d")  
            
        if (diffY < 0)
            Move(tilesY, "w")  
        else if (diffY > 0)
            Move(tilesY, "s")  
            
        return true
    }
    return false
}

F1::{
    while true {
        if (FindCoconut()) {
            Sleep 1000
        }
        Sleep(100)  
    }
}
F2::Pause
F3::ExitApp