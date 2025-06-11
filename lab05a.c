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



unsigned int input_to_decimal(char* str_input, int start_pos)
{

  unsigned int num_decimal = 0;

  for(int i = 1; i < 5; i++){
    num_decimal = num_decimal * 10 + (str_input[start_pos + i] - '0');
  }

  if(str_input[start_pos] == '-'){
    num_decimal = ~num_decimal + 1;
  }

  return num_decimal;
}


void pack(unsigned int input, unsigned int mask, unsigned int shift, unsigned int* output) {
  input = (input << shift) & mask;
  *output = *output | input;
}


void hex_code(int val){
    char hex[11];
    unsigned int uval = (unsigned int) val, aux;

    hex[0] = '0';
    hex[1] = 'x';
    hex[10] = '\n';

    for (int i = 9; i > 1; i--){
        aux = uval % 16;
        if (aux >= 10)
            hex[i] = aux - 10 + 'A';
        else
            hex[i] = aux + '0';
        uval = uval / 16;
    }
    write(1, hex, 11);
}




int main(){

  char str_input[40];
  unsigned int masks[5] = {0b111,
                  0b11111111000,
                  0b1111100000000000,
                  0b111110000000000000000,
                  0b11111111111000000000000000000000};
  int shifts[5] = {0, 3, 11, 16, 21};

  read(STDIN_FD, str_input, 30);

  unsigned int curr, output = 0;

  for(int i = 0; i < 5; i++){
    curr = input_to_decimal(str_input, 6 * i);
    pack(curr, masks[i], shifts[i], &output);
  }

  hex_code(output);

  return 0;
}