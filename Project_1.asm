.data
	# Welcome Prompt 
	welc_line: .asciiz "Welcome to the Twenty-one number trick \n"
	welc_line2: .asciiz "This program will guess which number you are thinknig about! \n"
	welc_line3: .asciiz "Think of a number in the interval 1-21, and memorize it! \n"
	welc_line4: .asciiz "(Press any key to continue) \n"
	
	# Col Display 
	.align 2  # starting at adress which is divisible by 4 (2^2= 4) 
	number: .word 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21
	n: .asciiz "\n"
	space: .asciiz " "
	
	# Getting input 
	user_input: .asciiz "In which column is your number (1,2,3): "
	
	# Input Validation
	validate_input: .asciiz "The number you input is invalid! \n"
	
	# Output
	output_msg: .asciiz"The number you selected was : " 
	
	.align 2 # each memory address is 4 bytes 
	temp: .space 84 # empty array sized memory (84/4= 21)

.text
.globl main
main: 
	jal print_welcome 
	
	move s5, zero # s5 = counter that starts from zero. 
	

########### STAGE 1 - MAIN LOOP LOGIC AND USER INTERATION ############

### calls all the function for user to choose col ####
mainLoop: 
	li t0, 3
	bge s5, t0, finishGame # if the user chooses the col for third time, stop the game and go to finish game to reveal the answer

	jal display_cards  # calls the method that displays the cards with cols 
	jal get_column  # asks the users which col their number is at 
	move s2, v0 # save user choice in s2 
	jal rearrange  # rearrange the card based on user input 
	
	addi s5, s5, 1 # increment 
	j mainLoop # back to main loop 
	
##### after all 3 calls are done, then at the end we can display the user with their guess. ####
finishGame:
	jal reveal_answer
	
	# exit 
	li v0, 10
	syscall 


##### Welcome messgage function #####
print_welcome: 
	# Displaying welcome messages 
	li v0, 4
	la a0, welc_line
	syscall 
	
	li v0, 4
	la a0, welc_line2
	syscall 
	
	li v0, 4
	la a0, welc_line3
	syscall 
	
	li v0, 4
	la a0, welc_line4
	syscall 
	
	li v0, 12  # waits for user to tpye something 
	syscall
	
	jr ra

################ STAGE 2:  Card displaying function ##############
display_cards:

	# Using for loop to display the numbers in col 
	move s0, zero  # i = 0
	li t0, 7  # t0 = 7
# outer loop for row 
loop_i: 
	bge s0, t0, exit_loop   # if i >= 7, exit loop or else go below 
	
	li v0, 4 # printing the new line for new row 
	la a0, n
	syscall 
	
	# nested loop 
	move s1, zero # j = 0
	li t7, 3 # t0 = 3

# inner loop for column 
loop_j: 
	bge s1, t7, exit_loop2 # if i >= 3, exit loop
	
	# index = 3*i + j
	sll t1, s0, 1 # t1 = 2*1
	add t1, t1, s0 # s1 = 3 * i
	add t1, t1, s1 # t1 = 3*i + j 
	
	# printing array 
	sll t2, t1, 2 # t2 = index * 4
	la t3, number # t3 = base address 
	add t3, t3, t2 # t3 = number[index]
	lw a0, 0(t3) # a0 = number[index]
	
	# print value 
	li v0, 1
	syscall
	
	# print space 
	li v0, 4
	la a0, space
	syscall 
	
	addi s1, s1, 1 # j++ 
	j loop_j
	
exit_loop2: 
	addi s0, s0, 1 # i++ 
	j loop_i # repeat loop 
	
	
exit_loop: 
	jr ra 

	
################### getting user input col ################
get_column:
	# display user input promt 
	li v0, 4
	la a0, user_input 
	syscall
	
	
	# reads the input 
	li v0, 5
	syscall 
	
	# condition 
	li t0, 1
	li t1, 3
	
	blt v0, t0, invalid # if input < 1 then it is invalid (invalid call displays message again) 
	bgt v0, t1, invalid # if input > 3 
	
	jr ra # valid input, return 
	

############################# REARRANGING THE COLUMNS AS PER USER INPUT #######################################
# function for invalid input 
# if this function gets called then print the invalid msg and jump back to get column 
invalid:
	#Print invalid messge 
	li v0, 4
	la a0, validate_input
	syscall
	
	j get_column  # then jump to col 
	

# Re arrange function 
# so this function does all kind of rearranging col based on user choice 
rearrange: 
	li t0, 1
	li t1, 2
	li t2, 3
	beq s2, t0, one # go to one function if user input is 1
	beq s2, t1, two # go to two function if user input is 2
	beq s2, t2, three # go to three function if user input is 3 

############ if user input is one, then col 1 has to go in the middle 	##############

# JAVA REFERENCE 
# if(input == 1){ 
            # for(int i = 0; i < 7; i++){
                # temp[i] = arr[1+3*i];
                # temp[7+i] = arr[3*i];
                # temp[14+i] = arr[2+3*i];
            # }
            # for(int i = 0; i < arr.length; i++){
                # arr[i] = temp[i];
            # }
        # }
one: 
	move s3, zero # i = 0
	li t0, 7 

oneLoop: 
	bge s3, t0, oneLoopExit # if i >= 7, exit loop 
	
	# operation goes here 
	la t8, number # t8 = number[0]
	la t9, temp # t9 = temp[0]
	
	sll t4, s3, 1 # t4 = 2*i
	add t4, t4, s3 # t4 = 3*i
	
	#swapping 
	# so if user choose 1, then transpose of col 2 should take place from index 0 to 6, then transpose of col 1 
	# should take place from 7 to 13, then transpose of col 3 should take place from index 14 to 20. 
	
	# temp[i] = number[1+3*i] 
	addi t5, t4, 1 # t5 = 1 + t4 or (3*i)
	sll t5, t5, 2 # t5 = (1+3*i) * 4
	add t6, t8, t5 # t6 = number[1+3*i]
	lw t7, 0(t6) # t7 = number[1+3*i]
	
	sll t1, s3, 2 # t1 = i* 4
	add t2, t9, t1 # t2 = temp[i]
	sw t7, 0(t2) # temp[i] = t7
	
	# temp[7+i] = nuber[3*i]
	sll t5, t4, 2 # t5 = (3*i)*4
	add t6, t8, t5 # t6 = numnber[3*i]
	lw t7, 0(t6) # t7 = number[3*] 
	
	addi t3, s3, 7 # t0 = 7 + i
	sll t1, t3, 2 # t1 = 7+i
	add  t2, t9, t1        # t2 = temp[7+i]
    	sw   t7, 0(t2)         # t7 = temp[7+i]
	
	# temp[14+i] = number[2+3*i]
	addi t5, t4, 2         # t5 = 2 + 3*i          
	sll  t5, t5, 2         # t5 = (2 + 3*i) * 4    
	add  t6, t8, t5        # t6 = number[2 + 3*i]
	lw   t7, 0(t6)         # t7 = number[2 + 3*i]
	
	addi t3, s3, 14        # t3 = 14 + i           
	sll  t1, t3, 2         # t1 = (14 + i) * 4     
	add  t2, t9, t1        # t2 = temp[14+i]
	sw   t7, 0(t2)         # t7 = temp[14+i] 
	
	addi s3, s3, 1 # i++
	j oneLoop 
	
	# copy the array temp into number
	# basically all the array we stored in temp now we copy it back to number 
	
copy_back:
	move s4, zero      # k = 0
	li   t0, 21        # limit = 21
	
	la   t8, number    # t8 = number[0]
	la   t9, temp      # t9 = temp[0]
	
copyLoop:
	bge  s4, t0, copyDone     # if k >= 21, stop
	
	sll  t1, s4, 2            # byte offset = k * 4
	
	add  t2, t9, t1           # temp[k]
	lw   t3, 0(t2)            # temp[k]
	
	add  t4, t8, t1           # number[k]
	sw   t3, 0(t4)            # number[k] = temp[k]
	
	addi s4, s4, 1            # k++
	j    copyLoop

copyDone:
    j doneArrange             # or jr ra (depending on your structure)
	
	
oneLoopExit: 
	j copy_back 
	

# ############## If the userInput is 2: ##############

# java references 
      # else if(input == 2){
            # for(int i = 0; i < 7; i++){
                # temp[i] = arr[3*i];
                # temp[7+i] = arr[1+3*i];
                # temp[14+i] = arr[2+3*i];
            # }
            # for(int i = 0; i < arr.length; i++){
                # arr[i] = temp[i];
            # }
        # }

# Now if the user input is 2, then col 1 transposes and takes place of array from index 0 to 6, col 2 transposes and takes 
# next place from index 7 to 13, and col 3 transposes and takes place from index 14 to 20. 

two:
	move s3, zero # i = 0
	li t0, 7 # t0 = 7
	
twoLoop: 
	bge s3, t0, twoLoopExit  #if i >= 7, exit loop 
	
	la t8, number # t8 = number[0]
	la t9, temp # tp = temp[0]
	
	sll t4, s3, 1 # t4 = 2*i
	add t4, t4, s3 # t4 = 3*i
	
	#swapping 
	
	# temp[i] = number[3*i]
	sll t5, t4, 2 # t5 = (3*i) * 4
	add t6, t8, t5 # t6 = number[3*i]
	lw t7, 0(t6) # t7 = number[3*i]
	
	sll t1, s3, 2 # t1 = i * 4
	add t2, t9, t1 # t2 = temp[i]
	sw t7, 0(t2) # temp[i] = t7
	
	# temp[7+i] = number[1+3*i]
	addi t5, t4, 1 # t5 = 1 + 3*i
	sll t5, t5, 2 # t5 = (1 + 3*i) * 4
	add t6, t8, t5 # t6 = number[1+3*i]
	lw t7, 0(t6) # t7 = number[1+3*i]

	addi t3, s3, 7 # t3 = 7 + i
	sll t1, t3, 2 # t1 = (7 + i) * 4
	add t2, t9, t1 # t2 = temp[7+i]
	sw t7, 0(t2) # temp[7+i] = t7

	# temp[14+i] = number[2+3*i]
	addi t5, t4, 2 # t5 = 2 + 3*i
	sll t5, t5, 2 # t5 = (2 + 3*i) * 4
	add t6, t8, t5 # t6 = number[2+3*i]
	lw t7, 0(t6) # t7 = number[2+3*i]

	addi t3, s3, 14 # t3 = 14 + i
	sll t1, t3, 2 # t1 = (14 + i) * 4
	add t2, t9, t1 # t2 = temp[14+i]
	sw t7, 0(t2) # temp[14+i] = t7

	addi s3, s3, 1 # i++
	j twoLoop

twoLoopExit:
	j copy_back
	
############### if the user input is 3: ##################

# Java reference 
 # else if(input == 3){
            # for(int i = 0; i < 7; i ++){
                # temp[i] = arr[3*i];
                # temp[7+i] = arr[2+3*i];
                # temp[14+i] = arr[1 + 3*i];
            # }
            # for(int i = 0; i < arr.length; i++){
                # arr[i] = temp[i];
            # }
        # }
	
	
# Now if the user input is 3, than col 1 tranpsose should take place from index 0 to 6, then col 3 tranpsose should 
# take place from index 7 to 13, then col 2 transpose should take place from index 14 to 20. 

three:
	move s3, zero # i = 0
	li t0, 7 # t0 = 7

threeLoop:
	bge s3, t0, threeLoopExit # if i >= 7, exit loop

	la t8, number # t8 = number[0]
	la t9, temp # t9 = temp[0]

	sll t4, s3, 1 # t4 = 2*i
	add t4, t4, s3 # t4 = 3*i

	# swapping

	# temp[i] = number[3*i]
	sll t5, t4, 2 # t5 = (3*i) * 4
	add t6, t8, t5 # t6 = number[3*i]
	lw t7, 0(t6) # t7 = number[3*i]

	sll t1, s3, 2 # t1 = i * 4
	add t2, t9, t1 # t2 = temp[i]
	sw t7, 0(t2) # temp[i] = t7
	
	# temp[7+i] = number[2+3*i]
	addi t5, t4, 2 # t5 = 2 + 3*i
	sll t5, t5, 2 # t5 = (2 + 3*i) * 4
	add t6, t8, t5 # t6 = number[2+3*i]
	lw t7, 0(t6) # t7 = number[2+3*i]

	addi t3, s3, 7 # t3 = 7 + i
	sll t1, t3, 2 # t1 = (7 + i) * 4
	add t2, t9, t1 # t2 = temp[7+i]
	sw t7, 0(t2) # temp[7+i] = t7

	# temp[14+i] = number[1+3*i]
	addi t5, t4, 1 # t5 = 1 + 3*i
	sll t5, t5, 2 # t5 = (1 + 3*i) * 4
	add t6, t8, t5 # t6 = number[1+3*i]
	lw t7, 0(t6) # t7 = number[1+3*i]

	addi t3, s3, 14 # t3 = 14 + i
	sll t1, t3, 2 # t1 = (14 + i) * 4
	add t2, t9, t1 # t2 = temp[14+i]
	sw t7, 0(t2) # temp[14+i] = t7

	addi s3, s3, 1 # i++
	j threeLoop

threeLoopExit:
	j copy_back
	
doneArrange: 
	jr ra

############## printing the 10th index because it is the answer that user guessed ##################
reveal_answer:
	li v0, 4
	la a0, output_msg
	syscall
	
	la t0 number 
	lw a0, 40(t0) # call loads the array of number[10]
	li v0, 1
	syscall
	
	jr ra
	


############################# Java code reference: #############################

# import java.util.Scanner;

# public class twentyOneCardTrick {

    # public static void cardTrick(){
        # Scanner scan = new Scanner(System.in);
        # int input;
        # int [] temp = new int[21];
        # int arr[] = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21};

        # // this loop will display the table 3 times and each time,
        # // it asks user to choose which col their number belongs to.
        # for(int i = 0; i < 3; i++){
            # do {
                # display(arr);
                # System.out.println();
                # System.out.print("\nIn which column is your number (1,2,3): ");
                # input = scan.nextInt();
                # if(input < 1 || input > 3){
                    # System.out.println("The number you input is invalid! ");

                # }
            # }while(input < 1 || input > 3);
            # reGroup(arr, temp, input);
        # }
        # System.out.println("The number you selected was:  " + arr[10]);
    # }
    # // a method that displays the table
    # public static void display(int arr[]){
        # for(int i = 0; i < 7; i++){
            # System.out.println();
            # for(int j = 0; j< 3; j++){
                # int index = 3*i + (j);
                # System.out.print(arr[index] + "       ");
            # }
        # }
    # }

    # public static void reGroup(int []arr, int []temp, int input){
        # if(input == 1){ // if the user chooses col 1, then col 1 has to go in the middle
            # // its like we need to transpose the col 1 to col 2 and make it in the middle
            # // the new first col now becomes transpose of old col 2,
            # // then the second new col becomes the transpose of old col 1
            # // then third new col becomes the transpose of its own
            # for(int i = 0; i < 7; i++){
                # temp[i] = arr[1+3*i];
                # temp[7+i] = arr[3*i];
                # temp[14+i] = arr[2+3*i];
            # }
            # for(int i = 0; i < arr.length; i++){
                # arr[i] = temp[i];
            # }
        # }
        # else if(input == 2){
            # for(int i = 0; i < 7; i++){
                # temp[i] = arr[3*i];
                # temp[7+i] = arr[1+3*i];
                # temp[14+i] = arr[2+3*i];
            # }
            # for(int i = 0; i < arr.length; i++){
                # arr[i] = temp[i];
            # }
        # }
        # else if(input == 3){
            # for(int i = 0; i < 7; i ++){
                # temp[i] = arr[3*i];
                # temp[7+i] = arr[2+3*i];
                # temp[14+i] = arr[1 + 3*i];
            # }
            # for(int i = 0; i < arr.length; i++){
                # arr[i] = temp[i];
            # }
        # }
        # else{
            # System.out.println("Enter the correct input! ");
        # }
    # }

    # public static void main(String[] args) {
        # cardTrick(); // calling the game

    # }


# }

	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
