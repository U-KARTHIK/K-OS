bits 16
org 0x7C00

start:
    ; Initialize data segment
    xor ax, ax
    mov ds, ax

    ; Save the boot drive number supplied by BIOS
    mov [boot_drive], dl

    ; Set destination address to 0000:8000
    mov es, ax
    mov bx, 0x8000

    ; Read sector 2: cylinder 0, head 0
    mov ah, 0x02
    mov al, 1
    mov ch, 0
    mov cl, 2
    mov dh, 0
    mov dl, [boot_drive]

    int 0x13
    jc disk_error

    ; Set up segments and pointers for marker comparison
    xor ax, ax
    mov ds, ax
    mov es, ax

    mov si, test_marker
    mov di, 0x8000
    mov cx, 19
    cld
    repe cmpsb
    jne marker_error

    ; Marker matched: print success
    mov si, success_message
    call print_string

    cli
halt:
    hlt
    jmp halt

disk_error:
    mov si, error_message
    call print_string

    cli
disk_error_halt:
    hlt
    jmp disk_error_halt

marker_error:
    mov si, marker_error_message
    call print_string

    cli
marker_error_halt:
    hlt
    jmp marker_error_halt

; Print a null-terminated string using BIOS video service
print_string:
    lodsb
    test al, al
    jz print_done

    mov ah, 0x0E
    int 0x10
    jmp print_string

print_done:
    ret

; Data
boot_drive:
    db 0

test_marker:
    db "KOS-SECTOR-2-MARKER"

success_message:
    db "Disk read and marker verified!", 0

error_message:
    db "Disk read failed!", 0

marker_error_message:
    db "Marker mismatch!", 0

; Pad boot sector to 512 bytes
times 510 - ($ - $$) db 0
dw 0xAA55
