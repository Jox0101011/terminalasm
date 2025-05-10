.global _start

.section .data
prompt:      .asciz "$ "
input_buf:   .space 256
argv:        .quad input_buf, 0
argv:        .argv
= input_buf, argv[1] = NULL
envp:        .quad 0

.section .text
_start:
shell_loop
   // print_prompt:
   mov x0 #1
   ldr x1 =prompt 
   mov x2 #256
   mov x8 #64

   svc #0

   // read_input:
   mov x0, #0
   ldr x1, =input_buf
   mov x2, #256
   mov x8, #63
   svc #0

  // remove newline (replace \n with \0)
  ldr x1, input_buf
find_newline:
    ldrb w2, [x1]
    cmp w2, #10
    b.eq replace_newline
    cbz w2, after_parse
    add x1, x1, #1
    b find_newline
replace_newline:
    mov w2, #0
    strb w2, [x1]

after_parse:
    // fork_process:
    mov x8, #220
    svc #0
    cmp x0, #0
    b.eq is_child

// parent: wait
    mov x8, #260

    mov x0, #0
    mov x1, #0
    mov x2, #0
    mov x3, #0
    svc #0
    b shell_loop

is_child:
    // execve(input_buf, argv, envp)
    ldr x0, =input_buf
    ldr x1, =argv
    ldr x2, =envp
    mov x8, #221

    svc #0

    // if execve fails, exit(1)
    mov x0, #1
    mov x8, #93
    svc #0
