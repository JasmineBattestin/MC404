// # include <unistd.h>

#define STDIN_FD  0
#define STDOUT_FD 1

int read(int __fd, const void *__buf, int __n){
    int ret_val;
  __asm__ __volatile__(
    "mv a0, %1           # file descriptor\n"
    "mv a1, %2           # buffer \n"
    "mv a2, %3           # size \n"
    "li a7, 63           # syscall write code (63) \n"
    "ecall               # invoke syscall \n"
    "mv %0, a0           # move return value to ret_val\n"
    : "=r"(ret_val)  // Output list
    : "r"(__fd), "r"(__buf), "r"(__n)    // Input list
    : "a0", "a1", "a2", "a7"
  );
  return ret_val;
}

void write(int __fd, const void *__buf, int __n)
{
  __asm__ __volatile__(
    "mv a0, %0           # file descriptor\n"
    "mv a1, %1           # buffer \n"
    "mv a2, %2           # size \n"
    "li a7, 64           # syscall write (64) \n"
    "ecall"
    :   // Output list
    :"r"(__fd), "r"(__buf), "r"(__n)    // Input list
    : "a0", "a1", "a2", "a7"
  );
}

void exit(int code)
{
  __asm__ __volatile__(
    "mv a0, %0           # return code\n"
    "li a7, 93           # syscall exit (64) \n"
    "ecall"
    :   // Output list
    :"r"(code)    // Input list
    : "a0", "a7"
  );
}

void _start()
{
  int ret_code = main();
  exit(ret_code);
}


// STRING OPERATIONS

unsigned int str_length(char* str){
  unsigned int len = 0;
  while(str[len] != '\n' && str[len] != '\0'){
    len++;
  }
  return len;
}

void flip_str (char* num_binary){
  for(int i = 0; i < 32; i++){
    // flipar o bit
    if(num_binary[i] == '0'){
      num_binary[i] = '1';
    } 
    else{
      num_binary[i] = '0';
    } 
  }
}

void change_str_order (char* str, int len){
  // changes the order
  char aux;
  for(int i = 0; i <= ((len + 1) / 2) - 1; i++){
    aux = str[i];
    str[i] = str[len - 1 - i];
    str[len - 1 - i] = aux;
  }
}

void int_to_str(unsigned int num_input, char* num_str, int is_negative){
  int len = 0;
  
  for(int i = 0; num_input > 0; i++){
    num_str[i] = '0' + (num_input % 10);
    num_input /= 10;
    len++;
  }

  if(is_negative){
    num_str[len] = '-';
    len++;
  }

  change_str_order(num_str, len);
  num_str[len] = '\0';
}





// CONVERTION BETWEEN BASES OPERATIONS

unsigned int hex_to_decimal(char* hex_input, int start_pos){
  unsigned int num_decimal = 0;

  for(int i = start_pos; hex_input[i] != '\n'; i++){

    num_decimal *= 16;

    if(hex_input[i] - '0' >= 0 && hex_input[i] - '0' <= 9){
      // it's a number between 0 and 9
      num_decimal += hex_input[i] - '0';
    }
    else if (hex_input[i] - 'A' >= 0 && hex_input[i] - 'A' <= 5){
      // it's an uppercase letter between A and F
      num_decimal += hex_input[i] + 10 - 'A';
    }
    else if(hex_input[i] - 'a' >= 0 && hex_input[i] - 'a' <= 5){
      // it's a lowercase letter between a and f
      num_decimal += hex_input[i] + 10 - 'a';
    }

    // else{
    //   // get exceptions
    // }
        
  }

  return num_decimal;

}


unsigned int input_to_decimal(char* num_input)
{
    /*
    Input can assume 0x (unsigned) or decimal (- or not)
    Assuming big-endian notation
    */

   unsigned int num_decimal = 0, start_pos = 0;

    if(num_input[0] != '0' || num_input[1] != 'x'){
        // input already is in decimal base

        if(num_input[0] == '-'){
          start_pos = 1;
        }

        for(int i = start_pos; num_input[i] != '\n'; i++){
          num_decimal = num_decimal * 10 + (num_input[i] - '0');
        }

        // if(num_input[0] == '-'){
        //   num_decimal *= -1;
        // }

        return num_decimal;
    }
    
    start_pos = 2;
    num_decimal = hex_to_decimal(num_input, start_pos);
    return num_decimal;
}


void decimal_to_binary(unsigned int num_decimal, char* num_binary, int is_negative){
  /*
  Input can assume decimal (- or not)
  Assuming big-endian notation
  */

  unsigned int quot = num_decimal;

  if(is_negative){
    quot--; // quot = ~quot; or quot = - quot - 1  // but as it's unsigned, just make quot - 1
  }

  // find out the number of digits necessary (qt_bits stores quantity of bits ocuppied, unconsidering zeros at left)
  unsigned int test = 1, qt_bits = 1;

  while (qt_bits <= 32 && test < quot){
    test *= 2;  // test << 1; shift to the left
    qt_bits++;
  }

  if (test != quot){
    qt_bits--;
  }
  

  int pos = qt_bits;

  if(is_negative){
    int neg_ones = 32 - qt_bits;
    for (int i = 0; i < neg_ones; i++){
      num_binary[i] = '0';  // we put 0 because it will be later flipped to obtain the negative one
    }
    pos = 32;
  }

  // armazena já na endianess de interesse (big-endian)

  while(quot != 0){
    num_binary[pos - 1] = (quot % 2) + '0';
    quot = quot / 2;
    pos--;
  }

  if(is_negative){
    flip_str(num_binary);

    // all 32 bits ocuppied due to the flip of a positive number to represent in comp of 2
    write(STDOUT_FD, "0b", 2);
    write(STDOUT_FD, num_binary, 32); // CREATE ANOTHER FUNCTION 
    write(STDOUT_FD, "\n", 1);
    // is_negative variable stored in num_binary[33]
    num_binary[33] = '1';

    return;
  }

  write(STDOUT_FD, "0b", 2);
  write(STDOUT_FD, num_binary, qt_bits);  // CREATE ANOTHER FUNCTION
  write(STDOUT_FD, "\n", 1);
  num_binary[33] = '0';
}


void binary_to_hex(char* binary_input, char* hex_output){
  /*
  Input manipulation.

  For the third output.
  */

  // need to know number of bits from input
  int is_negative = binary_input[33] - '0'; // bool
  int qt_bits;

  if(is_negative) qt_bits = 32; // ocupa todos devido ao complemento
  else qt_bits = str_length(binary_input);

  unsigned int sum = 0, hex_pos = 0, value;
  char* hex_digits = "0123456789abcdef";
  // char hex_output [40];

  if (qt_bits % 4 > 0){
    
    for(int j = 0; j < qt_bits % 4; j++){
      value = (binary_input[j] - '0') << ((qt_bits % 4) - (j + 1)); // retira-se 1 porque qt_bits é 1-index e j é 0-index
      sum += value;
    }

    hex_output[0] = hex_digits[sum];
    hex_pos++;
    sum = 0;
  }


  for(int i = qt_bits % 4; i < qt_bits; i += 4){
    for(int j = 0; j < 4; j++){
      value = (binary_input[j + i] - '0') << (3 - j);
      sum += value;
    }

    hex_output[hex_pos] = hex_digits[sum];
    hex_pos++;
    sum = 0;
  }

  write(STDOUT_FD, "0x", 2);
  write(STDOUT_FD, hex_output, (qt_bits % 4 == 0) ? (qt_bits / 4) : ((qt_bits / 4) + 1));
  write(STDOUT_FD, "\n", 1);

}



int two_comp_to_decimal (char* two_comp_input){

    /*
    Input manipulation.

    For the second output:
    The value in decimal base assuming that the 32-bit number is 
    encoded in two's complement representation (In this case, if 
    the most significant bit is 1, the number is negative);
    */

   char input_copy[40];

   unsigned int len = str_length(two_comp_input), is_negative = 0;
   unsigned int decimal_value = 0;

   for(int i = 0; i < len; i++){
    input_copy[i] = two_comp_input[i];
   }


   if(len >= 32 && two_comp_input[0] == '1'){
    // the number is negative and in comp 2
    is_negative = 1;
    flip_str(input_copy);
    decimal_value = 1;    // somando 1 apos o flip
   }

   for(int i = 0; i < len; i++){
    decimal_value += (input_copy[i] - '0') << (len - 1 - i);
   }
  

  return decimal_value;

}

void endian_swap_to_decimal(char* hex_input, int is_negative){
  /*
  Input manipulation.

  For the fourth output:
  The value in decimal base assuming that the 32-bit number is 
  encoded in unsigned representation and its endianness has 
  been swapped. - For example, assuming the 32-bit number 0x00545648 
  was entered as input, after the endian swap, the number becomes 
  0x48565400, and its decimal value is 1213617152.
  */

  unsigned int len = str_length(hex_input);

  for(int i = 0; i < len; i++){
    hex_input[7 - i] = hex_input[len - 1 - i];
  }
  for(int i = 0; i < 8 - len; i++){
    hex_input[i] = '0';
  }

  unsigned int order = 6;
  unsigned int value, num_decimal = 0;
  // 1 - 0 - 3 - 2 - 5 - 4 - 7 - 6

  for(int i = 7; i >= 0; i--){
    if(hex_input[i] - '0' >= 0 && hex_input[i] - '0' <= 9){
      value = (hex_input[i] - '0') << (order * 4);
    }
    else{
      value = (hex_input[i] - 'a' + 10) << (order * 4);
    }

    num_decimal += value;

    if(order % 2 == 0) order++;
    else order -= 3;
  }

  char decimal_value_str[40];

  int_to_str(num_decimal, decimal_value_str, is_negative);
  len = str_length(decimal_value_str);

  write(STDOUT_FD, decimal_value_str, len);
  write(STDOUT_FD, "\n", 1);

}



int main()
{
  
  char str_input[40];
  read(STDIN_FD, str_input, 32);
  int is_negative = 0;  // tell if the input itself is negative

  if(str_input[0] == '-') is_negative = 1;
  
  // input manipulation: str_input (hex or decimal) -> decimal int
  unsigned int num_input = input_to_decimal(str_input);

  // Output 1
  // num_input -> binary
  char num_binary[40];
  decimal_to_binary(num_input, num_binary, is_negative);

  // Output 2
  // number in decimal, previously obtained, in string container
  int is_comp_two = 0;
  if(str_length(num_binary) == 32 && num_binary[0] == '1') is_comp_two = 1;

  if(is_negative && str_input[1] != 'x'){ // decimal and negative
    write(STDOUT_FD, str_input, str_length(str_input));
    write(STDOUT_FD, "\n", 1);
  }

  else{
    char num_decimal_str[40];

    if(is_comp_two) num_input = two_comp_to_decimal(num_binary);

    int_to_str(num_input, num_decimal_str, is_comp_two);
    unsigned int decimal_len = str_length(num_decimal_str);
    write(STDOUT_FD, num_decimal_str, decimal_len);
    write(STDOUT_FD, "\n", 1);
  }

  // Output 3
  // number in hexadecimal: binary -> hex
  char num_hex[40];
  binary_to_hex(num_binary, num_hex);

  // Output 4
  // swap endianess
  // argument 0 means it's not negative (because it's unsigned)
  endian_swap_to_decimal(num_hex, 0);

  return 0;

}
