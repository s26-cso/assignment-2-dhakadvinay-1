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

    addi s3, a0, -1 #s3=number of elements argument-1
    mv s10, a1 #save argument base pointer into s10

    li a0, 10000  # Allocate 10000 bytes
    call malloc 
    mv s0, a0           # s0 = base address of input array

    addi s2, x0, 0  # s2 = loop index i=0
input:
    bge s2, s3, label2  #all input taken 
    addi t0, s2, 1      #skip ./a.out the argv[0]
    slli t0, t0, 3      #multiply by 8
    add t1, s10, t0    # t1 = 4 (size of an integer)
    ld a0, 0(t1)     #load the string pointer 
    call atoi

    addi t1, x0, 4  # t0 = offset = 4 * index
    mul t2, s2, t1 #offset= i+4
    add t2, s0, t2
    sw a0, 0(t2)   #store parsed integer into arr[i]

    addi s2, s2, 1  #increment loop counter 
    beq x0, x0, input #repeat loop

label2:

    li a0, 10000 #argumnet passed to a0 of the total size 
    call malloc # called the function malloc 
    mv s4, a0    # s4 = base address of stack


    li a0, 10000 #allocate the memory for anser array 
    call malloc # calling the malloc 
    mv s8, a0  # s8 = base address of answer array

    li s2, 0 #reset the loop counter to 0
    li t3, -1 #set t3 to -1 so ans[i] initialize to -1
loop4:
    bge s2, s3, stack 
    li t1, 4 # storing t1=4 for integer 
    mul t2, s2, t1 # calculating the offset 
    add t2, s8, t2  # finding the address 
    sw t3, 0(t2)   # ans[i]=-1
    addi s2, s2, 1  #increase the iterator by 1
    beq x0, x0, loop4 # loop
stack:

    addi s5, x0, -1     # s5 = stack top index 
    addi t0, x0, 0      # t0 = loop index i

loop1:
    bge t0, s3, label3  # If i >= n, exit loop

    addi t1, x0, 4 # t1 = 4 (size of integer)
    mul t4, t1, t0    # Calculate offset for arr[i]
    add t4, t4, s0     #calcuated base address
    lw t4, 0(t4)        # t4 = arr[i]

loop2:
    blt s5, x0, label4  # If stack is empty, push index

    mul t2, t1, s5 #calculating the offset for the stack top element 
    add t2, t2, s4 # exact address of that element 
    lw t3, 0(t2)        # t3 = stack[top] (index)

    mul s6, t3, t1 #calculating the offset for the array index
    add s7, s0, s6 # exact address for the offset 
    lw t5, 0(s7)    # t5 = arr[stack[top]]

    bge t5, t4, label4  # If arr[top] >= arr[i], stop popping


    mul s6, t3, t1#calculaing offset for sotring answer 
    add s7, s8, s6 # exact address
    sw t0, 0(s7)   # ans[top] = i

    addi s5, s5, -1 # Pop stack
    beq x0, x0, loop2 # Continue popping



label4: 
    addi s5, s5, 1 # Increment stack top
    mul t2, t1, s5 #calculating offset
    add t2, t2, s4
    sw t0, 0(t2)  # stack[top] = i

    addi t0, t0, 1 # i++
    beq x0, x0, loop1 # Repeat Loop1


label3:                     
    li s2, 0  # s2 = index for printing

loop3:
    bge s2, s3, label5  # If all elements printed, exit

    addi t1, x0, 4  # t1==4
    mul t2, s2, t1   # calculated the offset 
    add t2, s8, t2  #found address
    lw a1, 0(t2)        # Load ans[i] into a1

    la a0, fmt2   # Load format string "%d\n"
    call printf # Print ans[i]

    addi s2, s2, 1  # i++
    beq x0, x0, loop3 # Repeat loop
# //if there is a need of printing the new line then 
# // add these 
# // la a0, fmtnl
# // call printf

label5:
    lw s10, 80(sp)# Restore saved registers
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
    addi sp, sp, 96 # Deallocate stack space
    li a0, 0   # Return 0
    ret      # Exit program




