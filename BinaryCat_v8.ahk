; # Note: start the script a few seconds after a new BinaryCat 5-min countdown began
; # preferably just after the rewards from the previous round appeared ("Unclaimed Gains / Unclaimed KITTY")

; # To get the debug logs => https://docs.microsoft.com/en-us/sysinternals/downloads/debugview

; # 0xbca7f1998Dc9FFB70b086543a808960a460aBcA7 <--- Kitty contract for JOE :)

; # Coordinate relative to entire screen
CoordMode, Mouse, Screen

OnExit("ExitFunc")
OutputDebug, "Starting ..."
round_number := 0

FOR_REAL := true               ; # If transactions must be signed or cancelled
RANDOM_WAIT := true            ; # If must wait or not before each bet
EXTERNAL_MONITOR := true       ; # Use another set of coordinates for external monitor

; # Left window, bet "up" or "down" areas
left_up_button_x := EXTERNAL_MONITOR = true ? 990 : 479
left_up_button_y := EXTERNAL_MONITOR = true ? 458 : 676
left_down_button_x := EXTERNAL_MONITOR = true ? 990 : 479
left_down_button_y := EXTERNAL_MONITOR = true ? 585 : 815

; # Right window, bet "up" or "down" areas
right_up_button_x := EXTERNAL_MONITOR = true ? 2280 : 1427
right_up_button_y := EXTERNAL_MONITOR = true ? 458 : 669
right_down_button_x := EXTERNAL_MONITOR = true ? 2280 : 1427
right_down_button_y := EXTERNAL_MONITOR = true ? 585 : 823

; # Area where to type the AVAX amount
left_amount_area_x := EXTERNAL_MONITOR = true ? 1008 : 538
left_amount_area_y := EXTERNAL_MONITOR = true ? 523 : 743
right_amount_area_x := EXTERNAL_MONITOR = true ? 2282 : 1490
right_amount_area_y := EXTERNAL_MONITOR = true ? 523 : 747

; # Metamask "Reject" button
left_reject_button_x := EXTERNAL_MONITOR = true ? 1014 : 628
left_reject_button_y := EXTERNAL_MONITOR = true ? 572 : 717
right_reject_button_x := EXTERNAL_MONITOR = true ? 2293 : 1596
right_reject_button_y := EXTERNAL_MONITOR = true ? 557 : 711

; # Metamask "Confirm" button
left_confirm_button_x := EXTERNAL_MONITOR = true ? 1179 : 824
left_confirm_button_y := EXTERNAL_MONITOR = true ? 573 : 717
right_confirm_button_x := EXTERNAL_MONITOR = true ? 2467 : 1780
right_confirm_button_y := EXTERNAL_MONITOR = true ? 558 : 711

; # Somewhere in the Metamask UI to activate the window
left_metamask_window_x := EXTERNAL_MONITOR = true ? 1083 : 708
left_metamask_window_y := EXTERNAL_MONITOR = true ? 391 : 490
right_metamask_window_x := EXTERNAL_MONITOR = true ? 2368 : 1680
right_metamask_window_y := EXTERNAL_MONITOR = true ? 395 : 493

; # "OK" button for the "Min bet amount is 0.00" alert
left_ok_min_0_button_x := EXTERNAL_MONITOR = true ? 807 : 0
left_ok_min_0_button_y := EXTERNAL_MONITOR = true ? 166 : 0
right_ok_min_0_button_x := EXTERNAL_MONITOR = true ? 2088 : 0
right_ok_min_0_button_y := EXTERNAL_MONITOR = true ? 170 : 0

; # Close "Min bet amount is 0.00" in case it's there
; # Click %right_ok_min_0_button_x% %right_ok_min_0_button_y%
; # Click %left_ok_min_0_button_x% %left_ok_min_0_button_y%

EnterAvaxAmount()
{
    ; # Decide on the amount to bet (0.02 / 0.03)
    Random, avax_amount, 2, 3, A_TickCount
    OutputDebug, Will now bet 0.0%avax_amount%

    Send, ^a, {Del}
    Sleep 500
    Send, 0
    Sleep 500
    Send, .
    Sleep 500
    Send, 0
    Sleep 500
    Send, %avax_amount%
    OutputDebug, 0.0%avax_amount% typed
}

Loop
{   
    round_number := round_number + 1
    OutputDebug, Round #%round_number%
    start_time := A_TickCount

    if (RANDOM_WAIT = true) {        
        Random, wait_ms, 10000, 53000, A_TickCount
        OutputDebug, Right | Waiting for %wait_ms%ms
        Sleep wait_ms
    }

    ; # Decide which window will go for "UP" and for "DOWN"
    Random, right_use_up, 0, 1, A_TickCount
    left_use_up := (1 - right_use_up)
    
    ; ##############################################
    ; # Right window (for instance Edge)
    ; ##############################################
    ; # Refresh the page (F5) to prevent from frozen UI issues
    Click %right_amount_area_x% %right_amount_area_y%
    Sleep 200
    OutputDebug, Right | Reloading (F5)
    Send ^{f5}
    OutputDebug, Right | Waiting for UI (22000ms)
    Sleep 22000
    
    ; # Click on "Open for betting" / amount
    OutputDebug, Right | Clicking on amount area
    Click %right_amount_area_x% %right_amount_area_y%
    Sleep 100
    Click %right_amount_area_x% %right_amount_area_y%
    Sleep 1000
    If !WinActive("BinaryCat") {
        ; # Something is wrong, exit the script
        OutputDebug, Right | No BinaryCat window active
        ExitApp, -1
    }

    ; # Delete the field content and type "0.0x" AVAX
    EnterAvaxAmount()

    ; # Bet
    Sleep 1000
    if (right_use_up = 1) {
        Click %right_up_button_x% %right_up_button_y%
    } else {
        Click %right_down_button_x% %right_down_button_y%
    }    

    ; # Sign
    ; # Wait for metamask (6s)
    OutputDebug, Right | Waiting for Metamask
    Sleep 15000
    ; # Make sure the Metamask window is active
    Click %right_metamask_window_x% %right_metamask_window_y%
    Sleep 1000
    If !WinActive("MetaMask Notification") {
        ; # Something is wrong, exit the script
        OutputDebug, Right | No MetaMask window active
        ExitApp, -1
    }
    ; # Scroll down
    Send {End}
    Sleep 2000
    if (FOR_REAL = true) {
        OutputDebug, Right | Confirming
        ; # Click "Confirm"
        Click %right_confirm_button_x% %right_confirm_button_y%
        Sleep 100
        ; # Click "Confirm" again (just in case)
        Click %right_confirm_button_x% %right_confirm_button_y%
    } else {
        OutputDebug, Right | Rejecting
        ; # Click "Reject"
        Click %right_reject_button_x% %right_reject_button_y%
        Sleep 100
        ; # Click "Reject" again (just in case)
        Click %right_reject_button_x% %right_reject_button_y%
    }
    ; ##############################################

    if (RANDOM_WAIT = true) {
        Random, wait_ms, 5000, 33000, A_TickCount
        OutputDebug, Left | Waiting for %wait_ms%ms
        Sleep wait_ms
    }

    ; ##############################################
    ; # Left window (for instance Brave)
    ; ##############################################
    ; # Refresh the page (F5) to prevent from frozen UI issues
    Click %left_amount_area_x% %left_amount_area_y%
    OutputDebug, Left | Reloading (F5)
    Send ^{f5}
    OutputDebug, Left | Waiting for UI (22000ms)
    Sleep 22000

    ; # Click on "Open for betting" / amount
    OutputDebug, Left | Clicking on amount area
    Click %left_amount_area_x% %left_amount_area_y%
    Sleep 100
    Click %left_amount_area_x% %left_amount_area_y%
    Sleep 1000
    If !WinActive("BinaryCat") {        
        ; Something is wrong, exit the script
        OutputDebug, Left | No BinaryCat window active
        ExitApp, -1
    }
    
    ; # Delete the field content and type "0.0x" AVAX
    EnterAvaxAmount()

    ; # Bet
    Sleep 1000
    if (left_use_up = 1) {
        Click %left_up_button_x% %left_up_button_y%
    } else {
        Click %left_down_button_x% %left_down_button_y%
    }

    ; # Sign
    ; # Wait for metamask (6s)
    OutputDebug, Left | Waiting for Metamask
    Sleep 15000
    ; # Make sure the Metamask window is active
    Click %left_metamask_window_x% %left_metamask_window_y%
    Sleep 1000
    If !WinActive("MetaMask Notification") {
        ; # Something is wrong, exit the script
        OutputDebug, Left | No MetaMask window active
        ExitApp, -1
    }
    ; # Scroll down
    Send {End}
    Sleep 2000
    if (FOR_REAL = true) {
        OutputDebug, Left | Confirming
        ; # Click "Confirm"
        Click %left_confirm_button_x% %left_confirm_button_y%
        Sleep 100
        ; # Click "Confirm" again (just in case)
        Click %left_confirm_button_x% %left_confirm_button_y%
    } else {
        OutputDebug, Left | Rejecting
        ; # Click "Reject"
        Click %left_reject_button_x% %left_reject_button_y%
        Sleep 100 
        ; # Click "Reject" again (just in case)
        Click %left_reject_button_x% %left_reject_button_y%
    }
    ; ##############################################

    ; # Wait for 5 minutes minus the time taken by the above
    end_time := A_TickCount
    elapsed_ms := end_time - start_time
    time_to_sleep := 300000 - elapsed_ms  
    OutputDebug, Waiting for next round (%time_to_sleep%ms) 
    Sleep time_to_sleep
}

; # Allows to exit the script by typing Esc
Esc::ExitApp

ExitFunc(ExitReason, ExitCode)
{
    OutputDebug, Exiting with reason = %ExitReason% and code = %ExitCode%
    if (ExitCode = -1) {
        Hibernate()
    }
}

Hibernate() {
    DllCall("PowrProf\SetSuspendState", "Int", 0, "Int", 0, "Int", 0)
}