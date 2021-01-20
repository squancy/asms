%macro _saveToFile 0
  _saveRegisters
  ;; Try to open file
  mov rax, SYS_OPEN 
  mov rdi, fname
  mov rsi, PERMISSION
  mov rdx, 0o0644
  syscall

  ;; Check if exists
  mov rdx, 0
  cmp rdx, rax
  jle %%_write

  ;; Create file
  mov rax, SYS_CREAT
  mov rsi, 0o0644
  syscall
  
  ;; Write a short statistics about the round
  ;; [number of guesses] - [number to guess]
  %%_write:
    dec r12
    _writeFile nogMsg, nogLen
    _writeFile guesses, r12
    _writeFile nl, nlLen
  _restoreRegisters
%endmacro

%macro _writeFile 2
  _saveRegisters
  mov rbx, rax
  mov rax, SYS_WRITE
  mov rdi, rbx
  mov rsi, %1
  mov rdx, %2
  syscall
  _restoreRegisters
%endmacro

%macro _closeFile 0
  _saveRegisters
  mov rax, SYS_CLOSE
  syscall
  _restoreRegisters
%endmacro
