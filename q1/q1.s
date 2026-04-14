.globl make_node          # Declare makenode as a global function
.globl insert            # Declare insert as a global function
.globl get               # Declare get as a global function
.globl getAtMost         # Declare getatmost as a global function

.text                    # Start of executable code section


make_node:
    addi sp, sp, -16  # Allocate 16 bytes on stack
    sd ra, 8(sp) # Save return address
    sd s0, 0(sp)    # Save s0

    mv s0, a0 # Store input value (val) in s0

    li a0, 24   # Allocate 24 bytes for the node
    call malloc# Call malloc(size)

    sw s0, 0(a0) # node->val = val
    sd zero, 8(a0) # node->left = NULL
    sd zero, 16(a0)    # node->right = NULL

    ld s0, 0(sp)    # Restore s0
    ld ra, 8(sp)  # Restore return address
    addi sp, sp, 16      # Deallocate stack space
    ret   # Return pointer to new node in a0



insert:
    addi sp, sp, -48  # Allocate 48 bytes on stack
    sd ra, 40(sp)   # Save return address
    sd s0, 32(sp) # Save original root (caller's s0)
    sd s1, 24(sp) # Save value to insert
    sd s2, 16(sp)    # Save parent pointer

    mv s0, a0 # s0 = original root (will be returned)
    mv s1, a1  # s1 = value to insert
    mv t0, a0    # t0 = current node for traversal (DO NOT use s0!)
    mv s2, zero   # s2 = NULL (parent)

    beq t0,zero,inslabel4  # If tree is empty, go create root

inswhile:
    mv s2, t0   # s2 = current node (becomes parent for next)
    lw t1, 0(t0)   # t1 = current->val
    blt t1,s1,inslabel1  # If current->val < val, go right

    # Traverse left subtree
    ld t0, 8(t0)  # t0 = current->left
    beq zero, t0, inslabel2  # If left child is NULL, insert here
    beq x0, x0,inswhile   # Otherwise continue traversal

inslabel1:                      # Traverse right subtree
    ld t0, 16(t0)               # t0 = current->right
    beq zero, t0, inslabel3     # If right child is NULL, insert here
    beq x0, x0,inswhile                  # Otherwise continue traversal

inslabel2:                      # Insert as left child
    mv a0, s1                   # Pass value to make_node
    call make_node              # Create new node
    sd a0, 8(s2)                # parent->left = newnode
    beq x0,x0,insend                    # Jump to return

inslabel3:                      # Insert as right child
    mv a0, s1                   # Pass value to make_node
    call make_node              # Create new node
    sd a0, 16(s2)               # parent->right = newnode
    beq x0,x0,insend                    # Jump to return

inslabel4:                      # Tree is empty
    mv a0, s1                   # Pass value to make_node
    call make_node              # Create new root node
    mv s0, a0                   # Save new root as return value

insend:                         # Return root (original or new)
    mv a0, s0                   # Return root in a0
    ld ra, 40(sp)               # Restore return address
    ld s0, 32(sp)               # Restore caller's s0
    ld s1, 24(sp)               # Restore s1
    ld s2, 16(sp)               # Restore s2
    addi sp, sp, 48             # Deallocate stack
    ret

get:
    addi sp, sp, -32     # Allocate stack space
    sd ra, 24(sp)  # Save return address
    sd s0, 16(sp)  # Save s0
    sd s1, 8(sp)  # Save s1

    mv s0, a0   # s0 = root
    mv s1, a1 # s1 = value to search
    beq s0, zero, getlabel2
getwhile:
    lw t0, 0(s0)  # Load current->val
    beq t0, s1, getlabel2  # If equal, value found
    blt t0, s1, getlabel1  # If smaller, go right

    ld s0, 8(s0)  # Move to left child
    beq zero, s0, getlabel2  # If NULL, not found
    beq x0, x0, getwhile # Repeat loop

getlabel1:
    ld s0, 16(s0)   # Move to right child
    beq zero, s0, getlabel2  # If NULL, not found
    beq x0, x0, getwhile  # Repeat loop

getlabel2:
    mv a0, s0    # Return node pointer (or NULL)
    ld ra, 24(sp)  # Restore return address
    ld s0, 16(sp)  # Restore s0
    ld s1, 8(sp)   # Restore s1
    addi sp, sp, 32  # Deallocate stack
    ret



getAtMost:
    addi sp, sp, -32
    sd s3, 24(sp)  # Save s3 stores result
    sd ra, 16(sp)   # Save return address
    sd s0, 8(sp)    # Save s0
    sd s1, 0(sp)    # Save s1
    
    addi s3, x0, -1      # Initialize result to -1
    mv s0, a1            # s0 = root
    mv s1, a0            # s1 = key
    
    beq s0, zero, getmlabel2  # If tree is empty, return -1

getmwhile:
    lw t0, 0(s0)         # Load current->val
    bgt t0, s1, getmlabel1  # If current->val > key, go left
    
    # current->val <= key: update candidate and try to go right for bigger value
    mv s3, t0            # Update maximum candidate
    ld s0, 16(s0)        # Move to right child (try to find bigger value)
    bnez s0, getmwhile   # If right child exists, continue searching
    beq x0, x0, getmlabel2  # No more right children, we're done
    
getmlabel1:              # current->val > key: go left to find smaller value
    ld s0, 8(s0)         # Move to left child
    bnez s0, getmwhile   # If left child exists, continue searching
    
getmlabel2:
    mv a0, s3            # Return maximum value ≤ key
    ld ra, 16(sp)        # Restore return address
    ld s0, 8(sp)         # Restore s0
    ld s1, 0(sp)         # Restore s1
    ld s3, 24(sp)        # Restore s3
    addi sp, sp, 32      # Deallocate stack
    ret

