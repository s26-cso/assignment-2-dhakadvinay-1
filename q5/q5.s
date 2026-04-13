.section .rodata
filename: .string "input.txt"// the filename we have to write in the strig 
yes: .string "YES\n"// the filename we have to print yes
no: .string "NO\n"//  the filename we have to print no 

.section .text
.globl main


main:
    addi sp, sp, -48
    sd ra, 40(sp)// save the return address
    sd s0, 32(sp) // save s0==fd1
    sd s1, 24(sp) // save s1= fd2
    sd s2, 16(sp) // save s2(left)
    sd s3, 8(sp)  // save s3(right)

// this all is for opening the file using the openat 
    li a7, 56// i want to open the file syscall 56 =open file
    li a0, -100// look into the current director AT_FDCWD = current directory 
    // Here AT_FDCWD means At file descriptor current working directoy 
    lla a1, filename// address of input.txt a1= address of "input.txt"
    li a2, 0// read only 0_RDONLY =0
    li a3, 0// os gave us fd1=3
    ecall // do the syscall 
    mv s0, a0 //s0=fd1(os returns fd in a0

// loads the syscall number for lseek into a7
    li a7, 62  // 
    mv a0, s0  // passing the file descriptor 

    li a1, 0   // setting offset to 0
    li a2, 2   // the seekend the pointer reaches the end of the file 
    ecall      // maked the call

    li s2, 0   // initialize the left pointer to the begining of thte file 
    addi s3, a0, -1// last index of the file 

loop:
    bge s2, s3, ispalindrone// if the right pointer is greter then the left pointer then
    //break

    li a7, 62// lseek system call 
    mv a0, s0// change the file descriptor 
    mv a1, s2// offset (left index)
    li a2, 0//  seek set form the begining 
    ecall// call the function 

    li a7, 63//read 
    li a7, 63//lseek system call
    mv a0, s0//move the file descriptor to a0
    mv a1, sp//buffer address
    li a2, 1 // no of bytes to read
    ecall // invoke the system call 
    lb t0, 0(sp) // load the byte from memory into t0system call
    mv a0, s0//move the file descriptor to a0
    mv a1, sp//buffer address
    li a2, 1 // no of bytes to read
    ecall // invoke the system call 
    lb t0, 0(sp) // load the byte from memory into t0

    li a7, 62 // syscall number for lseek 
    mv a0, s1 // file descriptor
    mv a1, s3 // offset(position in the file)
    li a2, 0 // seekset
    ecall //invoke the system call

    li a7, 63// read data form the file 
    mv a0, s1// passing the file discreptor 
    addi a1, sp, 1 //the byte taken stored at sp+1
    li a2, 1 //request the os to read exactly one byte
    ecall  #os read one byte from the file at the current offset 

    lb t1, 1(sp) #reterive the byte stored at sp+1
    bne t0, t1, notpalindrome # branch if not equal 

    addi s2, s2, 1//increasing the left index
    addi s3, s3, -1// decreasing the right index
    beq x0, x0, loop// condition to make the loop
ispalindrone:
    li a7, 64# load the sys call for writing the message 
    li a0, 1# standard output ==1 means the message is printed in the terminal 
    lla a1, yes# load the address of the string into the register 
    li a2, 4 #set the number of bytes to write 
    ecall #invoke the sys call 
    beq x0, x0, done # writing done 
notpalindrone: 
    li a7, 64 #load the sys call for writing the message 
    li a0, 1 # file descriptor standard output 
    lla a1, no # load the address of the string NO
    li a2, 3 #Number of bytes to write
    ecall # invoke the system call 
done:
    li a7, 57 //syscall 57 for closing the file 
    mv a0, s0 //so contain the file descriptor returned by openat 
    ecall// close the file descriptor 
    li a7, 57 // syscall 57 for closing the file 
    mv a0, s1 // two close the another descriptor 
    ecall // call the function 
    ld ra, 40(sp)
    ld s0, 32(sp)
    ld s1, 24(sp)// restoring all the addresses 
    ld s2, 16(sp)
    ld s3, 8(sp)
    addi sp, sp, 48// stack deallocation 
    li a0, 0
    ret // return from the program    li a7, 57
    mv a0, s0
    ecall
    li a7, 57
    mv a0, s1
    ecall 
    ld ra, 40(sp)
    ld s0, 32(sp)
    ld s1, 24(sp)
    ld s2, 16(sp)
    ld s3, 8(sp)
    addi sp, sp, 48
    li a0, 0
    ret
