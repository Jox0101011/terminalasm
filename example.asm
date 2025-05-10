_start    ;examples
    shell_loop:
        print_prompt:
            syscall write

        read_input:
            syscall read

        parse_command:

        fork_process:
            syscall fork
        if child:
            syscall execve
        else:
            syscall wait

jmp shell_loop
