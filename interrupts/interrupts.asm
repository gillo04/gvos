;;; -------------------------------------------------------
;;;                SYSTEM DEFINED INTERRUPTS
;;; -------------------------------------------------------

;   [arguments] - (returned values)
;   #: not yet implemented

;   0xa0: I/O interrupts
;       0x00: Print null terminated string              [ESI: pointer to string]
;       0x01: Get key press                             (AH: pressed key scan code, AL: pressed key ascii value)
;       0x02: Get input string                          [ESI: pointer to where to store the string, EDI: input length] - ([ESI]: inputted string)
;       0x03: New line
;       0x04: Backspace
;       0x05: Clear screen
;       0x06: Set cursor position                       [DH: row, DL: column]
;   0xa1: Number operations
;       0x00: Convert decimal string to 8 bit number    [ESI: pointer to null terminated string] - (BL: number, AL: set to 1 if error occurred)
;       0x01: Convert decimal string to 16 bit number   [ESI: pointer to null terminated string] - (BX: number, AL: set to 1 if error occurred)
;       0x02: Convert decimal string to 32 bit number   [ESI: pointer to null terminated string] - (EBX: number, AL: set to 1 if error occurred)
;       0x03: Convert 8 bit number to decimal string    [BL: number, ESI: pointer to where to store the string] - ([ESI]: string)
;       0x04: Convert 16 bit number to decimal string   [BX: number, ESI: pointer to where to store the string] - ([ESI]: string)
;       0x05: Convert 32 bit number to decimal string   [EBX: number, ESI: pointer to where to store the string] - ([ESI]: string)
;      #0x06: Convert hex string to 8 bit number        [ESI: pointer to string] - (BL: number, AL: set to 1 if error occurred)
;       0x07: Convert 8 bit number to hex string        [BL: number, ESI: pointer to where to store the string] - ([ESI]: string)
;   0xa2: File system operations
;       0x00: Load sectors into memory                  [ES:BX: destination, CH: cylinder, CL: starting sector, DH: head, DL: drive, AL: number of sectors]
;      #0x01: Save memory section on disk               [ES:BX: destination, CH: cylinder, CL: starting sector, AL: number of sectors]
;       0x02: Get file info from file name              [ESI: pointer to file name] - (DH: head, CH: cylinder, CL: sector, AL: number of sectors)
;   0xb0: Graphic interrupts
;       0x00: Enter graphic mode
;       0x01: Return to previous grapich mode
;       0x02: Fill a rectangle                          [EBX: y:x, ECX: h:w, AL: color]
;       0x03: Stroke a rectangle                        [EBX: y:x, ECX: h:w, DX: stroke width, AL: color]
;       0x04: Fill a circle                             [EBX: y:x, CX: radius, AL: color]
;       0x05: Stroke a circle                           [EBX: y:x, CX: radius, DX: stroke width, AL: color]
;       0x06: Draw vector image                         [EBX: y:x, ESI: pointer to vector image definition, CX: unit size, AL: color]
;       0x07: Draw character                            [EBX: x:y, ESI: pointer to font, DL: char to draw, CX: font unit size, AL: color]
;       0x08: Draw text                                 [EBX: y:x, ESI: pointer to null rerminated string, EDI: pointer to font, CX: font unit size, DX: letter spacing, AL: color]
;       0x09: Draw line                                 [EBX: y0:x0, ECX: y1:x1, AL: color]
;       0x0a: Render graphic definition                 [ESI: pointer to graphic definition]
;       0x0b: GUI event handler                         [ESI: pointer to graphic definition, EDI: pointer to GUI status]

;;; -------------------------------------------------------
;;;                         0xA0
;;; -------------------------------------------------------
intA0:
    cmp ah, 0x00
    je PrintString
    cmp ah, 0x01
    je GetKeyPress
    cmp ah, 0x02
    je GetInputString
    cmp ah, 0x03
    je NewLine
    cmp ah, 0x04
    je BackSpace
    cmp ah, 0x05
    je ClearScreen
    cmp ah, 0x06
    je SetCursorPosition
    iret

%include "interrupts/int_A0.asm"

;;; -------------------------------------------------------
;;;                         0xA1
;;; -------------------------------------------------------
intA1:
    cmp ah, 0x00
    je DecStrToNum8
    cmp ah, 0x01
    je DecStrToNum16
    cmp ah, 0x02
    je DecStrToNum32
    cmp ah, 0x03
    je NumToDecStr8
    cmp ah, 0x04
    je NumToDecStr16
    cmp ah, 0x05
    je NumToDecStr32
    cmp ah, 0x07
    je NumToHexStr8
    iret

%include "interrupts/int_A1.asm"

;;; -------------------------------------------------------
;;;                         0xA2
;;; -------------------------------------------------------
intA2:
    cmp ah, 0x00
    je LoadSectors
    ; cmp ah, 0x01
    ; je GetKeyPress
    cmp ah, 0x02
    je GetFileInfo
    iret

%include "interrupts/int_A2.asm"

;;; -------------------------------------------------------
;;;                         0xB0
;;; -------------------------------------------------------
intB0:
    cmp ah, 0x00
    je EnterGraphicMode
    cmp ah, 0x01
    je ExitGraphicMode
    cmp ah, 0x02
    je FillRect
    cmp ah, 0x03
    je StrokeRect
    cmp ah, 0x04
    je FillCircle
    cmp ah, 0x05
    je StrokeCircle
    cmp ah, 0x06
    je DrawVectorImage
    cmp ah, 0x07
    je DrawChar
    cmp ah, 0x08
    je DrawText
    cmp ah, 0x09
    je DrawLine
    cmp ah, 0x0a
    je RenderGraphicDef
    cmp ah, 0x0b
    je GUILoop
    iret

%include "interrupts/int_B0.asm"

times 512 * 9 - ($-$$) db 0x00    ; 7 sectors + 2 to account for the bootloader and the file list size