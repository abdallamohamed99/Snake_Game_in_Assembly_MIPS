##################################################### Project Snake!!! ##########################################################

# Written by Abdalla Mohamed
# Description: You are controlling a snake to collect as much food as you can and get higher score than the previous one

					 #################################################
                                         #             Instructions                      #
                                         # Unit width 8                                  # 
                                         # Unit height 8                                 #
					 # Display width 512                             #
					 # Display height 512                            #
					 # Base address for display is $gp               #
					 # Press "l" to move up                          #
					 # Press "." to move down                        #
					 # Press "/" to move right                       #
					 # Press "," to move left                        #
					 #################################################

.data

	BoundaryColor: .word	0xff9933
	HeadColor:     .word	0xff0000
	# Starting coordinates of the head
	HeadX:         .word	31
	HeadY:         .word	31
	# Starting coordinates of the tail
	TailX:         .word	31
	TailY:         .word	32
	# Fruit color
	FruitColor:	.word	0xF4D03F
	# x coordinate of the fruit
	FruitX:		.word	 1
	# y coordinate of the fruit
	FruitY:		.word	1
	Score:		.word	0
	Speed:		.word	100
	GameOverMessage: .asciiz "Game Over!!! Your score is: "
	
	RestartPrompt: .asciiz "Try Again!?"

.text

############################################

# Clear the display 
# for(i=0; i!=64; i++)
# HeadY=i
# for(j=0; j!=64; j++)
# HeadX=l
# printhead()
# j++
# i=$t1
# j=$t2

############################################

RestartGame:
	li	$a0, 0
	li	$t1, 0
For1:
	beq	$t1, 64, ContToGame
	sw	$t1, HeadY
	addi	$t1, $t1, 1
	li	$t2, 0
For2:
	beq	$t2, 64, For1
	sw	$t2, HeadX
	jal	PrintHead
	addi	$t2, $t2, 1
	j	For2
ContToGame:

############################################

# Printing all 4 sides of the boundary

############################################

# Reset the snake head and tail coordinates after restarting the game
# And the keyboard buffer
 
	li 	$t0, 31
	sw 	$t0, HeadX
	sw 	$t0, HeadY
	sw 	$t0, TailX
	li	$t0, 32
	sw 	$t0, TailY
	sw 	$zero, 0xffff0004
	sw	$zero, Score
	lui	$sp, 0x7fff
	ori	$sp, 0xeffc
	li	$s0, 0
	
	#Clearing the registers after restarting a new game
	li 	$t0, 0
	li 	$t1, 0
	li 	$t2, 0
	li 	$t3, 0
	li 	$t4, 0
	li 	$t5, 0
	li 	$a0, 0
	li 	$a1, 0
	li 	$a2, 0
	li 	$a3, 0
	li 	$v0, 0

	# Printing the top boundary
	add 	$t0,$zero, $gp			# $t0=$gp
TopBoundary:
	lw 	$t2, BoundaryColor		# $t2=Boundary color
	sw 	$t2, 0($t0)			# Print the first pixel
	addi 	$t0, $t0, 4			# add 4 to move to the next pixel
	addi 	$t1, $t1, 1			# i++
	bne 	$t1, 64, TopBoundary		# while(i!=64)

	# Printing the bottom boundary
	add 	$t0,$zero, $gp			# $t0=$gp
	addi 	$t0, $t0, 0x3f00		# $t0=$t0+16128 to move to the last row on the bottom
	li 	$t1, 0				# i=0
BottomBoundary:
	lw 	$t2, BoundaryColor		# $t2=Boundary color
	sw 	$t2, 0($t0)			# Print the first pixel
	addi 	$t0, $t0, 4			# add 4 to move to the next pixel
	addi 	$t1, $t1, 1			# i++
	bne 	$t1, 64, BottomBoundary		# while(i!=64)

# Printing the left boundary
	add 	$t0,$zero, $gp			# $t0=$gp
	li 	$t1,0				# i=0
LeftBoundary:
	lw 	$t2, BoundaryColor		# $t2=Boundary color
	sw 	$t2, 0($t0)			# Print the first pixel
	add 	$t0,$zero, $gp			# $t0=$gp
	addi 	$t1, $t1, 1			# i++
	mul 	$t3, $t1, 0x40			# $t3= i*64 where i= the current row
	mul 	$t3, $t3,4			# $t3=$t3*4
	add 	$t0, $t0, $t3			# $t0=$t0+$t3
	bne 	$t1, 64, LeftBoundary		# while(i!=64)

# Printing the right boundary
	add 	$t0,$zero, $gp			# $t0=$gp
	addi 	$t0,$t0, 0xfc			# $t0= $t0+252 to move to the last column on the left
	li 	$t1,0				# i=0
RightBoundary:
	lw 	$t2, BoundaryColor		# $t2=Boundary color
	sw 	$t2, 0($t0)			# Print the first pixel
	addi 	$t0,$gp, 0xfc			# $t0= $t0+252 to move to the last column on the left
	addi 	$t1, $t1, 1			# i++
	mul 	$t3, $t1, 0x40			# $t3= i*64 where i= the current row
	mul 	$t3, $t3, 4			# $t3=$t3*4
	add 	$t0, $t0, $t3			# $t0=$t0+$t3
	bne 	$t1, 64, RightBoundary		# while(i!=64)

############################################

# Printing the snake's body and movement
# press "l" to move up
# press "." to move down
# press "/" to move right
# press "," to move left

############################################

# Print snake
	lw 	$a0, HeadColor
	jal 	PrintHead
	jal 	PrintTail	
# Print fruit
	jal 	PrintFruit


#check user input and snake movement
input:

#load keyboard buffer
	la 	$t0, 0xffff0000
	lw	$t2, ($t0)
	bne 	$t2, 1, Skip
	lw 	$t1, 4($t0)
Skip:



#up
	bne 	$t1, 108, down			# if ($t1='l')
	jal 	Pause				# Pause game
	# Store head coordinates to the stack
	lw 	$t0, HeadX
	addi	$sp, $sp, -4
	sw	$t0, 0($sp)
	lw 	$t0, HeadY
	addi	$sp, $sp, -4
	sw	$t0, 0($sp)
	
	lw 	$t0, HeadY			# $t0= the snake's head y coordinate
	addi 	$t0, $t0, -1			# y=y-1
	beq	$t0, $zero, GameOver		# if y=0 print Game Over
	beq	$t0, 63, GameOver		# if y=63 print Game Over
	sw 	$t0, HeadY			# store the new y coordinate in DM
	lw 	$a0, HeadColor			# load the snake's head color from DM
	jal 	PrintHead			# Check if the snake eat the fruit
	jal	IsFruitEaten			# Check if the friut was eaten
	
	beq	$v0,1, GrowUp			# if the friut was eaten then don't clear the tail
	
	li 	$a0, 0				# $a0=0
	jal 	PrintTail			# clears the old pixel since $a0 is 0 which is black


	add	$sp, $sp, $s0			# Move the to an older location in the stack
	# copy the head coordinates to the tail coordinates from the stackyu6
	lw	$t0, ($sp)
	sw	$t0, TailY
	lw	$t0, 4($sp)
	sw	$t0, TailX
	sub	$sp, $sp, $s0			# Move back to the top of the stack

	j 	NotGrowUp
GrowUp:
	addi	$s0,$s0,8
	
NotGrowUp:	
	j 	input				# check for new input (loop back)

#down
down:
	bne 	$t1, 46, right			# if ($t1='.')
	jal 	Pause				# Pause game
	# Store head coordinates to the stack
	lw 	$t0, HeadX
	addi	$sp, $sp, -4
	sw	$t0, 0($sp)
	lw 	$t0, HeadY
	addi	$sp, $sp, -4
	sw	$t0, 0($sp)
	
	lw 	$t0, HeadY			# $t0= the snake's head y coordinate
	addi 	$t0, $t0, 1			# y=y+1
	beq	$t0, $zero, GameOver		# if y=0 print Game Over
	beq	$t0, 63, GameOver		# if y=63 print Game Over
	sw 	$t0, HeadY			# store the new y coordinate in DM
	lw 	$a0, HeadColor			# load the snake's head color from DM
	jal 	PrintHead			# Check if the snake eat the fruit
	jal	IsFruitEaten			# Check if the friut was eaten
	
	beq	$v0,1, GrowDown			# if the friut was eaten then don't clear the tail
	
	li 	$a0, 0				# $a0=0
	jal 	PrintTail			# clears the old pixel since $a0 is 0 which is black


	add	$sp, $sp, $s0			# Move the to an older location in the stack
	# copy the head coordinates to the tail coordinates from the stackyu6
	lw	$t0, ($sp)
	sw	$t0, TailY
	lw	$t0, 4($sp)
	sw	$t0, TailX
	sub	$sp, $sp, $s0			# Move back to the top of the stack

	j 	NotGrowDown
GrowDown:
	addi	$s0,$s0,8
	
NotGrowDown:
	j 	input				# check for new input (loop back)

#right
right:
	bne 	$t1, 47, left			# if ($t1='/')
	jal 	Pause				# Pause game
	# Store head coordinates to the stack
	lw 	$t0, HeadX
	addi	$sp, $sp, -4
	sw	$t0, 0($sp)
	lw 	$t0, HeadY
	addi	$sp, $sp, -4
	sw	$t0, 0($sp)
	
	lw 	$t0, HeadX			# $t0= the snake's head x coordinate
	addi 	$t0, $t0, 1			# x=x+1
	beq	$t0, $zero, GameOver		# if x=0 print Game Over
	beq	$t0, 63, GameOver		# if x=63 print Game Over
	sw 	$t0, HeadX			# store the new x coordinate in DM
	lw 	$a0, HeadColor			# load the snake's head color from DM
	jal 	PrintHead			# Check if the snake eat the fruit
	jal	IsFruitEaten			# Check if the friut was eaten
	
	beq	$v0,1, GrowRight		# if the friut was eaten then don't clear the tail
	
	li 	$a0, 0				# $a0=0
	jal 	PrintTail			# clears the old pixel since $a0 is 0 which is black


	add	$sp, $sp, $s0			# Move the to an older location in the stack
	# copy the head coordinates to the tail coordinates from the stackyu6
	lw	$t0, ($sp)
	sw	$t0, TailY
	lw	$t0, 4($sp)
	sw	$t0, TailX
	sub	$sp, $sp, $s0			# Move back to the top of the stack

	j 	NotGrowRight
GrowRight:
	addi	$s0,$s0,8
	
NotGrowRight:
	j 	input				# check for new input (loop back)

#left
left:
	bne 	$t1, 44, input			# if ($t1=',')
	jal 	Pause				# Pause game
	# Store head coordinates to the stack
	lw 	$t0, HeadX
	addi	$sp, $sp, -4
	sw	$t0, 0($sp)
	lw 	$t0, HeadY
	addi	$sp, $sp, -4
	sw	$t0, 0($sp)
	
	lw 	$t0, HeadX			# $t0= the snake's head x coordinate
	addi 	$t0, $t0, -1			# x=x-1
	beq	$t0, $zero, GameOver		# if x=0 print Game Over
	beq	$t0, 63, GameOver		# if x=63 print Game Over
	sw 	$t0, HeadX			# store the new x coordinate in DM
	lw 	$a0, HeadColor			# load the snake's head color from DM
	jal 	PrintHead			# Check if the snake eat the fruit
	jal	IsFruitEaten			# Check if the friut was eaten. 
	
	beq	$v0,1, GrowLeft			# if the friut was eaten then don't clear the tail
	
	li 	$a0, 0				# $a0=0
	jal 	PrintTail			# clears the old pixel since $a0 is 0 which is black


	add	$sp, $sp, $s0			# Move the to an older location in the stack
	# copy the head coordinates to the tail coordinates from the stackyu6
	lw	$t0, ($sp)
	sw	$t0, TailY
	lw	$t0, 4($sp)
	sw	$t0, TailX
	sub	$sp, $sp, $s0			# Move back to the top of the stack

	j 	NotGrowLeft
GrowLeft:
	addi	$s0,$s0,8
	
NotGrowLeft:
	j 	input				# check for new input (loop back)
	
#pause	
Pause: 

	li 	$v0, 32
	lw	$a0, Speed			
	syscall
	jr	$ra

# Exit program
Exit:
	li 	$v0, 10
	syscall

############################################

# function to print a pop up window that says game over
# This function also play a sound and gives you the option to restart or end the game

############################################
GameOver:
	# play a sound
	li $v0, 31
	li $a0, 11
	li $a1, 500
	li $a2, 11
	li $a3, 127
	syscall
	
	li $a0, 11
	li $a1, 1000
	li $a2, 11
	li $a3, 127
	syscall
	
	# Print Game over and score
	li 	$v0, 56
	la 	$a0, GameOverMessage
	lw 	$a1, Score
	syscall
	
	# Restart game?
	li 	$v0, 50
	la 	$a0, RestartPrompt
	syscall
	
	beqz 	$a0, RestartGame
	
	j	Exit
	
############################################

# function to Print the pixels

############################################
# PrintHead function converts the given x and y to an address and prints the the given color into that address
# color=$a0, x=$a1, y=$a2
PrintHead:
	# Print head
	lw 	$a1, HeadX			# $a1 = x
	lw 	$a2, HeadY			# $a2 = y
	li	$t0, 0				# Clear $t0
	mul 	$t0, $a2, 64			# $t0 = y * 64
	add 	$t0, $t0, $a1			# $t0 = %t0 + x
	mul 	$t0,$t0,4			# $t0 = $t0 * 4
	add 	$t0, $t0, $gp			# $t0 = $t0 + $gp
	sw 	$a0, ($t0)			# Print pixel
	jr 	$ra				# jump back to the main function
PrintTail:
	# Print tail
	lw 	$a1, TailX			# $a1 = x
	lw 	$a2, TailY			# $a2 = y
	li	$t0, 0				# Clear $t0
	mul 	$t0, $a2, 64			# $t0 = y * 64
	add 	$t0, $t0, $a1			# $t0 = %t0 + x
	mul 	$t0,$t0,4			# $t0 = $t0 * 4
	add 	$t0, $t0, $gp			# $t0 = $t0 + $gp
	sw 	$a0, ($t0)			# Print pixel
	jr 	$ra				# jump back to the main function

############################################

# function to Print the fruit

############################################
# PrintFruit function converts the given x and y to an address and prints the the given color into that address
# color=$a0, x=$a1, y=$a2
PrintFruit:

	
	# Generate random number
	li 	$v0, 42				# Generate a random number
	li 	$a1, 61				# upper limit of 61
	syscall
	
	addiu	$a0, $a0, 1			# x = x + 1
	sw 	$a0, FruitX			# Store the y coordinate in DM
	
	syscall

	addiu 	$a0, $a0, 1			# y = y + 1
	sw 	$a0, FruitY			# Store the y coordinate in DM
	# Print fruit
	lw 	$a0, FruitColor			# Fruit Color
	lw 	$a1, FruitX			# $a1 = x
	lw 	$a2, FruitY			# $a2 = y
	li	$t0, 0				# Clear $t0
	mul 	$t0, $a2, 64			# $t0 = y * 64
	add 	$t0, $t0, $a1			# $t0 = %t0 + x
	mul 	$t0,$t0,4			# $t0 = $t0 * 4
	add 	$t0, $t0, $gp			# $t0 = $t0 + $gp
	sw 	$a0, ($t0)			# Print pixel
	jr 	$ra				# jump back to the main function
	
	
	
############################################

# function to check if the fruit was eaten

############################################

IsFruitEaten:
	# Store the value of $t0 to the stack
	addi	$sp, $sp, -4				
	sw	$t0, ($sp)
	# Store the value of $t1 to thr stack
	addi	$sp, $sp, -4
	sw	$t1, ($sp)
	# Store the value of $t2 to thr stack
	addi	$sp, $sp, -4
	sw	$t2, ($sp)
	# Store the value of $t3 to thr stack
	addi	$sp, $sp, -4
	sw	$t3, ($sp)
	# Store the value of $t4 to thr stack
	addi	$sp, $sp, -4
	sw	$t4, ($sp)
	# Store the value of $ra to thr stack
	addi	$sp, $sp, -4
	sw	$ra, ($sp)
	
	lw	$t0, HeadX			# load the snake's head x coordinate
	lw	$t1, HeadY			# load the snake's head y coordinate
	lw	$t2, FruitX			# load the fruit's x coordinate
	lw	$t3, FruitY			# load the fruit's y coordinate
	# if the snake's head and the fuits's coordinates match add 10 points to the score
	bne 	$t0, $t2, Done
	bne 	$t1, $t3, Done
	
	jal	PrintFruit			# Print a new fruit
	lw	$t4, Score
	addi	$t4, $t4, 10
	sw	$t4, Score
	li	$v0, 1				# Return 1 to indicate that the fruit was eaten
	
	# Load $t0's value from the stack
	lw 	$t0, 20($sp)
	# Load $t1's value from the stack
	lw 	$t1, 16($sp)
	# Load $t2's value from the stack
	lw 	$t2, 12($sp)
	# Load $t3's value from the stack
	lw 	$t3, 8($sp)
	# Load $t4's value from the stack
	lw 	$t4, 4($sp)
	# Load $ra's value from the stack
	lw 	$ra, ($sp)
	# Clear stack
	addi	$sp, $sp, 24
	
	jr	$ra
	
Done:
	# Load $t0's value from the stack
	lw 	$t0, 20($sp)
	# Load $t1's value from the stack
	lw 	$t1, 16($sp)
	# Load $t2's value from the stack
	lw 	$t2, 12($sp)
	# Load $t3's value from the stack
	lw 	$t3, 8($sp)
	# Load $t4's value from the stack
	lw 	$t4, 4($sp)
	addi	$sp, $sp, 24
	li	$v0, 0				# Return 0 to indicate that the fruit was not eaten
	jr	$ra

