>^RWin::AppsKey

>!,::Media_Prev

>!.::Media_Next

>!/::
WinSet, AlwaysOnTop, Toggle, A
WinGet, ExStyle, ExStyle, A
if (ExStyle & 0x8) ; 0x8 is WS_EX_TOPMOST
{
    WinSet, Transparent, 223, A
}
else
{
    WinSet, Transparent, Off, A
}
return