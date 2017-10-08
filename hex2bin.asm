; ref: https://board.flatassembler.net/topic.php?t=17704
; 2017-10-07
; https://xiaolaba.wordpress.com
; read input HEX file, space sperated, line end with 0x0a, 0x0d (CR/LF)
; fiter out space,0x0a,0x0d, write binary to output file
; FASM 1.71.64, windows XP


format pe gui 4.0
entry start

include 'win32ax.inc'

section '.code' code readable executable

start:
        invoke  MessageBox,HWND_DESKTOP,my_banner,invoke GetCommandLine,MB_OK

;        invoke CreateFile,"I.TXT",GENERIC_READ,NULL,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,NULL
        invoke CreateFile, sourceFile, GENERIC_READ,NULL,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,NULL

        mov [hInputFile],eax

        invoke GetFileSize,[hInputFile],NULL
        mov [dwFileSize],eax

        invoke LocalAlloc,LPTR,[dwFileSize]
        mov [lpBuffer],eax

        invoke ReadFile,[hInputFile],[lpBuffer],[dwFileSize],dwBytesRead,NULL

        invoke CloseHandle,[hInputFile]

;;;;; by xiaolab
;; remove space, 0x0a, 0x0d from the hex file
        mov esi,[lpBuffer]
        mov edi,[lpBuffer]
        mov edx,[dwFileSize]
        xor ecx,ecx     ;byte count to be written

next:   mov al, [esi]   ;read a byte
        mov [edi],al    ;store a byte anyway

        cmp al, " "     ;check if space, 0x0a or 0x0d
        je remove
        cmp al, 0x0a
        je remove
        cmp al, 0x0d
        je remove
keep:
        inc edi ; advance pointer to next storage loaction, this byte is saved, not omitted
        inc ecx ; counter +1
remove:
        inc esi ; next byte from source
        dec edx ; remains of char to process
        jg next ; repeat until all char done

        ; after removed space/0x0a/0x0d, file size
        mov [dwFileSize],ecx





;; ASCII to BIN, read two char (2byte, WORD) at one time, ie. "1A" will be converted to a byte 0x1A
        mov esi,[lpBuffer]
        mov edi,[lpBuffer]
        mov edx,[dwFileSize]
        xor ecx,ecx     ;byte count to be written

next_word:
        mov ax, [esi]   ; ASCII two char for one byte
        sub ax, "00"    ; "0..9" = 0x30..0x39, "A-F" = 0x41..0x46
        cmp al, 9       ; 1st char, check for 0..9
        jle ok
        sub al, 7       ; "A..F", convert to 0x0a...0x0f
ok:
        cmp ah, 9       ; 2nd char, check for 0..9
        jle ok1
        sub ah, 7       ; "A..F", convert to 0x0a...0x0f
ok1:

        shl al, 4       ; asseble a byte
        add ah, al
        mov [edi], ah   ; save the byte conveted

        inc edi         ; point to next storage postion
        add esi, 2      ; point next two char
        inc ecx         ; counter +1
        dec edx         ; remains of char to process
        dec edx
        jg next_word    ; repeat until all char done

        ; after ASC to BIN, file size
        mov [dwFileSize],ecx
;;;;; by xiaolab


;        invoke CreateFile,"O.TXT",GENERIC_WRITE,NULL,NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,NULL
        invoke CreateFile, targetFile, GENERIC_WRITE,NULL,NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,NULL

        mov [hOutputFile],eax

        invoke WriteFile,[hOutputFile],[lpBuffer],[dwFileSize],dwBytesWritten,NULL

        invoke CloseHandle,[hOutputFile]

        invoke LocalFree,[lpBuffer]

        invoke ExitProcess,NULL

section '.data' data readable writable

        hInputFile      dd 0
        hOutputFile     dd 0
        dwFileSize      dd 0
        dwBytesRead     dd 0
        dwBytesWritten  dd 0
        lpBuffer        dd 0
        dwIndexRead     dd 0
        dwIndexWrite    dd 0
        dwCount         dd 0
        ascii           db 0,1,2,3,4,5,6,7,8,9,0xa,0xb,0xc,0xd,0xe,0xf
        my_banner       db "2017-OCT-07, by https://xiaolaba.wordpress.com",0xa,0xd,0xa,0xd
                        db "Read input file, HEX, valid char (0-9, A-F, space), end of line with 0x0a, 0x0d (CR/LF)",0xa,0xd,0xa,0xd
                        db "Write output file, BIN mode, fiter out space,0x0a,0x0d",0xa,0xd,0xa,0xd
                        db "Done!",0xa,0xd,0xa,0xd
                        db "Ref: https://board.flatassembler.net/topic.php?t=17704",0xa,0xd,0xa,0xd
                        db 0
;        sourceFile      db "USB1.1_modem.hex",0
;        targetFile      db "USB1.1_modem.bin",0
        sourceFile      db "I.hex",0
        targetFile      db "O.bin",0

section '.idata' import data readable

 library kernel32,'KERNEL32.DLL',\
         user32,'USER32.DLL'

 include 'api\kernel32.inc'
 include 'api\user32.inc'