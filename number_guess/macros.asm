SYS_WRITE equ 1
SYS_READ equ 0
SYS_EXIT equ 60
SYS_OPEN equ 2
PERMISSION equ 0x441 ; read, write, append
SYS_CREAT equ 85
STDOUT equ 1
STDIN equ 0
BUFFER_LEN equ 10
SYS_TIME equ 201
SYS_CLOSE equ 3

%macro _saveRegisters 0
  ; Save registers that are arguments to syscalls in order to not to override them
  push rax
  push rdi
  push rsi
  push rdx
%endmacro

%macro _restoreRegisters 0
  ; Restore previously saved registers after syscall
  pop rdx
  pop rsi
  pop rdi
  pop rax
%endmacro

%macro _printMsg 2
  ; Display a string on STDOUT
  _saveRegisters
  mov rax, SYS_WRITE
  mov rdi, STDOUT
  mov rsi, %1
  mov rdx, %2
  syscall
  _restoreRegisters
%endmacro

%macro _exitProgram 1
  ; Exit program with an error code
  _saveRegisters
  mov rax, SYS_EXIT
  mov rdi, %1
  syscall
  _restoreRegisters
%endmacro

%macro _getInput 0
  ; Get input from STDIN and save it in register r9
  ; Input is stored in an allocated buffer
  _saveRegisters
  mov rax, SYS_READ
  mov rdi, STDIN
  mov rsi, buffer
  mov rdx, BUFFER_LEN
  syscall
  mov byte [buffer - 1 + rax], 0 ; remove possible trailing \n from the end
  _restoreRegisters
%endmacro

%macro _toInt 1
  ; Convert the string given by user to an int
  ; Store result in r9
  _saveRegisters
  mov rbx, 10
  xor rax, rax
  mov rcx, %1

  %%_loop1:
  movzx rdx, byte [rcx]

  test rdx, rdx
  jz %%_done

  inc rcx

  sub rdx, '0'
  add rax, rax
  lea rax, [rax + rax * 4]

  add rax, rdx

  jmp %%_loop1
  %%_done:
  mov r9, rax
  _restoreRegisters
%endmacro

%macro _toString 1
  ; Convert an n-digit int to its string representation
  ; Repeatedly divide the int with 10 and store the remainders
  ; Store the string in guesses and the length of the string in r12
  _saveRegisters
  xor r11, r11
  mov rax, %1
  %%_loop:
    mov rdx, 0
    mov rcx, 10
    div rcx

    %%_cont:
      add rdx, '0'
      mov [guesses + r11], rdx
      inc r11

    cmp rax, 0
    jne %%_loop

  %%_done:

  ; Now reverse the string in place
  xor r12, r12
  dec r11
  %%_loop2:
    mov r13, [guesses + r12] 
    mov r14, [guesses + r11] 
    mov [guesses + r12], r14
    mov [guesses + r11], r13
    dec r11
    inc r12
    cmp r12, r11
    jge %%_finish
    jmp %%_loop2

  ; Store the number of digits in r12
  test r12, 1
  jz %%_finish
  add r12, r12
  sub r12, 1
  jmp %%_skip

  %%_finish:
  add r12, r12
  %%_skip:
  ;mov r15, guesses
  _restoreRegisters
%endmacro
