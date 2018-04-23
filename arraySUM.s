# Author: Nicholas Keen
# Date: Nov 5, 2015
# Assignment: 4
# Once again I apologize for the tardiness of my program.

	.text
	.global _start
	.equ  EXIT, 1

_start:
	ldr r0, [sp]		@ argc value
	add r1, sp, #4		@ argv address
	bl main			@ call main
	mov r0, #0		@ success exit code
	mov r7, #EXIT
        svc 0			@ return to OS

# program that adds togethor all of the command line parameters
# given that they are numbers
# modifies r0, r1, r2

	.equ WRITE, 4
	.equ STDOUT, 1
main:
	mov ip, sp		@ prologue starts
	push {r4, r5, r6, fp, lr}
	sub fp, ip, #4		@ prologue ends
	mov r4, r1		@ save arg address
	mov r5, r0		@ save arg value
	mov r6, r0		@ save arg value for later recall
	add r4, r4, #4		@ skip over command line param.
0:
	sub r5, r5, #1		@ decrement r5
	cmp r5, #0
	beq 1f
	ldr r0, [r4], #4	@ load the first param. into r0
	bl atoi
	push {r0}		@ push the value onto the stack
	bal 0b
1:
	mov r0, fp
	sub r0, r0, #20		@ load starting address of array into r0
	sub r1, r6, #1		@ account for program name
	bl array_sum
	sub sp, fp, #16		@ clear stack
	mov r1, r0		@ save the array sum
	mov r0, #STDOUT		@ file descriptor
	bl printi
# done -- return
	pop {r4, r5, r6, fp, pc}@ epilogue

# procedure array_sum - sum the elements in an array
# parameters:
#	r0 - the starting address of the array
#	r1 - the number of words in the array
# returns:
# 	r0 - the sum of the elements of the array
array_sum:
	mov r2, r0
	mov r0, #0		@ initialize running sum
0:
	cmp r1, #0		@ check for zero
	moveq pc, lr
	ldr r3, [r2], #-4	@ move value into r3
	add r0, r0, r3		@ add the value into the sum
	sub r1, r1, #1		@ decrement r1
	bal 0b

# print the elements of a string array
# parameters
#   r0:   output file descriptor
#   r1:   string array pointer -- terminated with a null
# returns nothing
parray:
	push {r4, r5, lr}
	mov r4, r0		@ save r0 (fd)
	mov r5, r1		@ and r1 (string array pointer)
        bal 1f
0:
        mov r0, r4              @ pass fd in r0
        bl println              @ write the string
1:
        ldr r1, [r5], #4        @ get current string address, and advance
        cmp r1, #0              @ are we done?
        bne 0b                  @ no, write the string
        pop {r4, r5, pc}


# determine string length
# parameters
#   r0:   address of null-terminated string
# returns
#   r0:   length of string (excluding the null byte)
# modifies r0, r1, r2
strlen:
	@ push {lr}
	mov r1, r0		@ address of string
	mov r0, #0		@ length to return
0:
	ldrb r2, [r1], #1	@ get current char and advance
	cmp r2, #0		@ are we at the end of the string?
	addne r0, #1
	bne 0b
# return
	@ pop  {pc}
	mov pc, lr		@ can do this instead of using the stack

# write a null-terminated string followed by a newline
# parameters
#   r0:  output file descriptor
#   r1:  address of string to print
# modifies r0, r1, r2
println:
	push {r4, r5, r7, lr}
# first get the string length
	mov r4, r0		@ save the fd
	mov r5, r1		@ and the string address
	mov r0, r1		@ the string address
	bl strlen		@ returns the string length in r0
	mov r2, r0		@ put length in r2 for the WRITE syscall
	mov r0, r4		@ restore the fd
	mov r1, r5		@ and the string address
	mov r7, #WRITE
	svc 0
	mov r0, r4		@ retrieve the fd
	adr r1, CR		@ get the address of the CR string
	mov r2, #1		@ one char to write
	mov r7, #WRITE
	svc 0
	pop {r4, r5, r7, pc}	@ restore registers and return to caller

# procedure printi writes the ASCII string of decimal digits to the file
# descriptor after having converted them from an integer.
# parameters:
#	r0 - a file descriptor
#	r1 - an integer value
# returns:
#	r0 - address of the string
printi:
	push {r4, r5, lr}
	mov r4, r0		@ save r0
	mov r0, r1		@ move int into r0
	ldr r1, =buff		@ load the space buffer into r1
	bl itoa
	mov r5, r0		@ save address
	mov r1, r5		@ prepare to print
	mov r0, r4		@ restore file descriptor
	bl println
	mov r0, r5		@ prepare for return
	pop {r4, r5, pc}

CR:	.byte '\n

	.align 2
	.data
buff:	.space 12
