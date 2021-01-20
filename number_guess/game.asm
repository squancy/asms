%include "macros.asm"
%include "file.asm"

section .bss
  buffer resb 10
  guesses resb 10

section .text
  global _start
 
_start:
  _printMsg welcomeMsg, welcomeLen
  _printMsg infoMsg, infoLen

_init:
  call _randNum
  mov r10, 0 ; store the number of guesses

_loop:
  ; Main game loop
  inc r10
  _toString r10
  _printMsg inputMsg, inputLen
  _getInput
  _toInt buffer
  cmp r8, r9
  je _gameWin
  cmp r9, r8
  jg _numHigh
  _printMsg lowMsg, lowLen
  jmp _loop

  _numHigh:
    _printMsg highMsg, highLen
    jmp _loop 

  _exit:
    _exitProgram 0

  _gameWin:
    _printMsg winMsg, winLen
    _printMsg guess1Msg, guess1Len
    _printMsg guesses, r12
    _printMsg guess2Msg, guess2Len
    _saveToFile
  
  ; Ask user for a new round
  _keepAsking:
    _printMsg againMsg, againLen
    _getInput
    cmp [buffer], byte 'y'
    mov r12, 0 ; reset guess counter to 0
    je _init
    cmp [buffer], byte 'n'
    je _exit
    jmp _keepAsking

_randNum:
  ; Generate a weak pseudo-random number from unix epoch
  ; Divide the number by 100 and the remainder + 1 will be the number to guess
  ; Store result in register r8
  _saveRegisters
  mov rax, SYS_TIME
  xor rdi, rdi
  syscall
  mov rdx, 0
  mov rcx, 100
  div rcx
  mov r8, rdx
  add r8, 1
  _restoreRegisters
  ret

section .data
  welcomeMsg db 'Welcome to the number guessing game!',10
  welcomeLen equ $ - welcomeMsg
  infoMsg db 'Guess a number between 1 and 100 (both inclusive).',10
  infoLen equ $ - infoMsg
  inputMsg db 'Enter number: '
  inputLen equ $ - inputMsg
  wrongMsg db 'Wrong number!',10
  wrongLen equ $ - wrongMsg
  winMsg db 'Congrats! You guessed the correct number!',10
  winLen equ $ - winMsg
  lowMsg db 'Your number is too low!',10
  lowLen equ $ - lowMsg
  highMsg db 'Your number is too high!',10
  highLen equ $ - highMsg
  guess1Msg db 'It took you '
  guess1Len equ $ - guess1Msg
  guess2Msg db ' guesses',10
  guess2Len equ $ - guess2Msg
  againMsg db 'Do you want to play again? (y/n): '
  againLen equ $ - againMsg
  fname db './statistics.txt',0
  fnameLen equ $ - fname
  nogMsg db 'Number of guesses: '
  nogLen equ $ - nogMsg
  nl db 10
  nlLen equ $ - nl
