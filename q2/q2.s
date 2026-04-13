.section .rodata
fmt:
.string "%d"            # Format string for scanf to read an integer
fmt2:
.string "%d\n"          # Format string for printf to print an integer with newline

.globl main
.section .text

main:
    addi sp, sp, -96    # Allocate 96 bytes on the stack for saved registers
    sw s10, 80(sp)      # Save callee-saved registers
    sw s9, 72(sp)
    sw s8, 64(sp)
    sw s7, 56(sp)
    sw s6, 48(sp)
    sw s5, 40(sp)
    sw s4, 32(sp)
    sw s3, 24(sp)
    sw s2, 16(sp)
    sw ra, 8(sp)        # Save return address
    sw s1, 0(sp)

    # -----------------------------------------------------------
    # Allocate memory for input array
    # -----------------------------------------------------------
    addi a0, x0, 10000  # Allocate 10000 bytes
    call malloc 
    mv s0, a0           # s0 = base address of input array
    mv s3, x0           # s3 = number of elements (length = 0)

# -----------------------------------------------------------
# Input Loop: Read integers until scanf returns <= 0
# -----------------------------------------------------------
input:
    addi t1, x0, 4      # t1 = 4 (size of an integer)
    mul t0, t1, s3      # t0 = offset = 4 * index
    la a0, fmt          # Load address of "%d"
    add a1, s0, t0      # Address of arr[index]
    call scanf          # Read integer from input
    blez a0, label2     # Stop when scanf fails or EOF occurs
    addi s3, s3, 1      # Increment array length
    beq x0, x0, input   # Repeat loop (unconditional jump)

label2:
    # -----------------------------------------------------------
    # Allocate memory for stack (stores indices)
    # -----------------------------------------------------------
    li a0, 10000
    call malloc
    mv s4, a0           # s4 = base address of stack

    # Allocate memory for answer array (Next Greater Elements)
    li a0, 10000
    call malloc 
    mv s8, a0           # s8 = base address of answer array

    # Initialize stack and iterators
    addi s5, x0, -1     # s5 = stack top index (-1 indicates empty stack)
    addi t0, x0, 0      # t0 = loop index i

# -----------------------------------------------------------
# Loop1: Traverse the input array
# -----------------------------------------------------------
loop1:
    bge t0, s3, label3  # If i >= n, exit loop

    addi t1, x0, 4      # t1 = 4 (size of integer)
    mul t4, t1, t0      # Calculate offset for arr[i]
    add t4, t4, s0
    lw t4, 0(t4)        # t4 = arr[i]

# -----------------------------------------------------------
# Loop2: Process stack elements
# -----------------------------------------------------------
loop2:
    blt s5, x0, label4  # If stack is empty, push index

    mul t2, t1, s5
    add t2, t2, s4
    lw t3, 0(t2)        # t3 = stack[top] (index)

    mul s6, t3, t1
    add s7, s0, s6
    lw t5, 0(s7)        # t5 = arr[stack[top]]

    bge t5, t4, label4  # If arr[top] >= arr[i], stop popping

    # Assign Next Greater Element
    mul s6, t3, t1
    add s7, s8, s6
    sw t4, 0(s7)        # ans[top] = arr[i]

    addi s5, s5, -1     # Pop stack
    beq x0, x0, loop2   # Continue popping

# -----------------------------------------------------------
# Push current index onto stack
# -----------------------------------------------------------
label4: 
    addi s5, s5, 1      # Increment stack top
    mul t2, t1, s5
    add t2, t2, s4
    sw t0, 0(t2)        # stack[top] = i

    addi t0, t0, 1      # i++
    beq x0, x0, loop1   # Repeat Loop1

# -----------------------------------------------------------
# Print the Next Greater Elements
# -----------------------------------------------------------
label3:                     
    li s2, 0            # s2 = index for printing

loop3:
    bge s2, s3, label5  # If all elements printed, exit

    addi t1, x0, 4
    mul t2, s2, t1
    add t2, s8, t2
    lw a1, 0(t2)        # Load ans[i] into a1

    la a0, fmt2         # Load format string "%d\n"
    call printf         # Print ans[i]

    addi s2, s2, 1      # i++
    beq x0, x0, loop3   # Repeat loop

# -----------------------------------------------------------
# Restore registers and exit
# -----------------------------------------------------------
label5:
    lw s10, 80(sp)      # Restore saved registers
    lw s9, 72(sp)
    lw s8, 64(sp)
    lw s7, 56(sp)
    lw s6, 48(sp)
    lw s5, 40(sp)
    lw s4, 32(sp)
    lw s3, 24(sp)
    lw s2, 16(sp)
    lw ra, 8(sp)
    lw s1, 0(sp)
    addi sp, sp, 96     # Deallocate stack space
    li a0, 0            # Return 0
    ret                 # Exit program