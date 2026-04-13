.globl makenode          # Declare makenode as a global function
.globl insert            # Declare insert as a global function
.globl get               # Declare get as a global function
.globl getatmost         # Declare getatmost as a global function

.text                    # Start of executable code section


# -----------------------------------------------------------
# Function: makenode
# Purpose : Allocate and initialize a new BST node
# Node structure:
#   offset 0  : int val
#   offset 8  : left pointer
#   offset 16 : right pointer
# -----------------------------------------------------------
makenode:
    addi sp, sp, -16     # Allocate 16 bytes on stack
    sd ra, 8(sp)         # Save return address
    sd s0, 0(sp)         # Save s0

    mv s0, a0            # Store input value (val) in s0

    li a0, 24            # Allocate 24 bytes for the node
    call malloc          # Call malloc(size)

    sw s0, 0(a0)         # node->val = val
    sd zero, 8(a0)       # node->left = NULL
    sd zero, 16(a0)      # node->right = NULL

    ld s0, 0(sp)         # Restore s0
    ld ra, 8(sp)         # Restore return address
    addi sp, sp, 16      # Deallocate stack space
    ret                  # Return pointer to new node in a0


# -----------------------------------------------------------
# Function: insert
# Purpose : Insert a value into the Binary Search Tree
# Arguments:
#   a0 = root
#   a1 = value to insert
# Returns:
#   a0 = root of BST
# -----------------------------------------------------------
insert:
    addi sp, sp, -32
    sd ra, 24(sp)        # Save return address
    sd s0, 16(sp)        # Save root
    sd s1, 8(sp)         # Save value
    sd s2, 0(sp)         # Save current/parent node

    mv s0, a0            # s0 = root
    mv s1, a1            # s1 = value to insert

    mv s2, zero          # s2 = NULL (parent)

    beq s0, zero, inslabel4  # If root is NULL, create new node

inswhile:
    mv s2, s0            # s2 = current node (parent)
    lw t0, 0(s0)         # t0 = current->val
    blt t0, s1, inslabel1 # If current->val < val, go right

    # Traverse left subtree
    ld s0, 8(s0)         # s0 = current->left
    beq zero, s0, inslabel2  # If left child is NULL, insert here
    beq x0, x0, inswhile     # Unconditional jump to continue loop

inslabel1:               # Traverse right subtree
    ld s0, 16(s0)        # s0 = current->right
    beq zero, s0, inslabel3  # If right child is NULL, insert here
    beq x0, x0, inswhile     # Repeat loop

inslabel2:               # Insert as left child
    mv a0, s1            # Pass value to makenode
    call makenode        # Create new node
    sd a0, 8(s2)         # parent->left = newnode
    beq x0, x0, insend   # Jump to function end

inslabel3:               # Insert as right child
    mv a0, s1            # Pass value to makenode
    call makenode        # Create new node
    sd a0, 16(s2)        # parent->right = newnode
    beq x0, x0, insend   # Jump to function end

inslabel4:               # Tree is empty
    mv a0, s1            # Pass value to makenode
    call makenode        # Create root node
    ld ra, 24(sp)        # Restore return address
    ld s0, 16(sp)        # Restore s0
    ld s1, 8(sp)         # Restore s1
    ld s2, 0(sp)         # Restore s2
    addi sp, sp, 32      # Deallocate stack
    ret                  # Return new root

insend:                  # Return original root
    ld s0, 16(sp)        # Restore root
    mv a0, s0            # Return root in a0
    ld ra, 24(sp)        # Restore return address
    ld s1, 8(sp)         # Restore s1
    ld s2, 0(sp)         # Restore s2
    addi sp, sp, 32      # Deallocate stack
    ret


# -----------------------------------------------------------
# Function: get
# Purpose : Search for a value in the BST
# Arguments:
#   a0 = root
#   a1 = value to search
# Returns:
#   a0 = pointer to node if found, otherwise NULL
# -----------------------------------------------------------
get:
    addi sp, sp, -32     # Allocate stack space
    sd ra, 16(sp)        # Save return address
    sd s0, 8(sp)         # Save s0
    sd s1, 0(sp)         # Save s1

    mv s0, a0            # s0 = root
    mv s1, a1            # s1 = value to search

getwhile:
    lw t0, 0(s0)         # Load current->val
    beq t0, s1, getlabel2  # If equal, value found
    blt t0, s1, getlabel1  # If smaller, go right

    ld s0, 8(s0)         # Move to left child
    beq zero, s0, getlabel2  # If NULL, not found
    beq x0, x0, getwhile     # Repeat loop

getlabel1:
    beq t0, s1, getlabel2    # Safety check
    ld s0, 16(s0)            # Move to right child
    beq zero, s0, getlabel2  # If NULL, not found
    beq x0, x0, getwhile     # Repeat loop

getlabel2:
    mv a0, s0            # Return node pointer (or NULL)
    ld ra, 16(sp)        # Restore return address
    ld s0, 8(sp)         # Restore s0
    ld s1, 0(sp)         # Restore s1
    addi sp, sp, 32      # Deallocate stack
    ret


# -----------------------------------------------------------
# Function: getatmost
# Purpose : Find the largest value ≤ given key in BST
# Arguments:
#   a0 = key
#   a1 = root
# Returns:
#   a0 = maximum value ≤ key (or -1 if none)
# -----------------------------------------------------------
getatmost:
    addi sp, sp, -32
    sd s3, 24(sp)        # Save s3 (stores result)
    sd ra, 16(sp)        # Save return address
    sd s0, 8(sp)         # Save s0
    sd s1, 0(sp)         # Save s1
    
    addi s3, x0, -1      # Initialize result to -1
    mv s0, a1            # s0 = root
    mv s1, a0            # s1 = key

getmwhile:
    lw t0, 0(s0)         # Load current->val
    beq t0, s1, getmlabel2  # If equal, return value
    bgt t0, s1, getmlabel3  # If greater, go left
    mv s3, t0            # Update maximum candidate

getmlabel3:
    blt t0, s1, getmlabel1  # If smaller, go right
    ld s0, 8(s0)            # Move to left child
    beq zero, s0, getmlabel2
    beq x0, x0, getmwhile

getmlabel1:
    beq t0, s1, getmlabel2
    ld s0, 16(s0)           # Move to right child
    beq zero, s0, getmlabel2
    beq x0, x0, getmwhile

getmlabel2:
    mv a0, s3            # Return maximum value ≤ key
    ld ra, 16(sp)        # Restore return address
    ld s0, 8(sp)         # Restore s0
    ld s1, 0(sp)         # Restore s1
    ld s3, 24(sp)        # Restore s3
    addi sp, sp, 32      # Deallocate stack
    ret