; =====================================================================
; FEU TECH - Certificate of Registration (COR) & Tuition Calculator
; =====================================================================

section .data
    banner          db  "=========================================", 10
                    db  "     FEU INSTITUTE OF TECHNOLOGY         ", 10
                    db  "     CERTIFICATE OF REGISTRATION (COR)   ", 10
                    db  "=========================================", 10, 0

    lbl_header      db  10, "== COR SUMMARY / USER PROFILE ==", 10, 0
    lbl_term        db  "Enrollment Status: Term 1 SY 2026-2027", 10, 0
    lbl_stud_no     db  "Student Number   : ", 0
    lbl_name        db  "Student Name     : ", 0
    lbl_program     db  "Program          : ", 0
    lbl_curric      db  "Curriculum Code  : BSCSSE2025", 10, 0
    lbl_year        db  "Year Level       : ", 0
    lbl_status      db  "Student Type     : REGULAR", 10, 0
    lbl_units       db  "Enrolled Units   : ", 0
    lbl_tuition     db  "Tuition Fee      : PHP ", 0
    comma_space     db  ", ", 0
    space           db  " ", 0
    newline         db  10, 0
    rate_per_unit   dq  2108        ; Rate per unit

section .bss
    input_buffer    resb 512
    stud_id         resb 32
    first_name      resb 32
    middle_name     resb 32
    last_name       resb 32
    program         resb 16
    year_level      resb 8
    input_units     resb 8
    tuition_result  resb 16


%macro print_string 1
    push rax
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi

    mov rsi, %1
    xor rdx, rdx
%%calc_len:
    cmp byte [rsi + rdx], 0
    je %%do_print
    inc rdx
    jmp %%calc_len

%%do_print:
    mov rax, 1          ; sys_write
    mov rdi, 1          ; stdout
    syscall

    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    pop rax
%endmacro

section .text
    global _start

_start:
    print_string banner

    mov rax, 0          ; sys_read
    mov rdi, 0          ; stdin
    mov rsi, input_buffer
    mov rdx, 511
    syscall

    call parse_inputs

    mov rsi, input_units
    call ascii_to_int

    mov rdi, rax
    call compute_tuition


    print_string lbl_header
    print_string lbl_term

    print_string lbl_stud_no
    print_string stud_id
    print_string newline

    print_string lbl_name
    print_string last_name
    print_string comma_space
    print_string first_name
    print_string space
    print_string middle_name
    print_string newline

    print_string lbl_program
    print_string program
    print_string newline

    print_string lbl_curric
    print_string lbl_year
    print_string year_level
    print_string newline

    print_string lbl_status
    print_string lbl_units
    print_string input_units
    print_string newline

    print_string lbl_tuition
    print_string tuition_result
    print_string newline

    ; Exit Program (sys_exit)
    mov rax, 60
    xor rdi, rdi
    syscall


parse_inputs:
    mov rsi, input_buffer
    
    mov rdi, stud_id
    call extract_line

    mov rdi, first_name
    call extract_line

    mov rdi, middle_name
    call extract_line

    mov rdi, last_name
    call extract_line

    mov rdi, program
    call extract_line

    mov rdi, year_level
    call extract_line

    mov rdi, input_units
    call extract_line
    ret

extract_line:
.loop:
    mov al, [rsi]
    cmp al, 10
    je .done_line
    cmp al, 13
    je .done_line
    cmp al, 0
    je .done_all
    mov [rdi], al
    inc rsi
    inc rdi
    jmp .loop
.done_line:
    mov byte [rdi], 0
    inc rsi
    cmp byte [rsi], 10
    jne .skip_lf
    inc rsi
.skip_lf:
    ret
.done_all:
    mov byte [rdi], 0
    ret


compute_tuition:
    push rbp
    mov rbp, rsp
    push rax
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi

    mov rax, rdi
    mov rbx, [rate_per_unit]
    mul rbx                     ; RAX = units * rate_per_unit

    mov rdi, tuition_result + 15
    mov byte [rdi], 0
    dec rdi
    mov rcx, 10

.convert_loop:
    xor rdx, rdx
    div rcx
    add dl, '0'
    mov [rdi], dl
    dec rdi
    test rax, rax
    jnz .convert_loop

    inc rdi
    mov rsi, rdi
    mov rdi, tuition_result
.copy_res:
    lodsb
    stosb
    test al, al
    jnz .copy_res

    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    pop rax
    mov rsp, rbp
    pop rbp
    ret


ascii_to_int:
    xor rax, rax
.next_digit:
    movzx rcx, byte [rsi]
    cmp rcx, '0'
    jl .done_conv
    cmp rcx, '9'
    jg .done_conv
    sub rcx, '0'
    imul rax, rax, 10
    add rax, rcx
    inc rsi
    jmp .next_digit
.done_conv:
    ret