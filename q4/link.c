#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <dlfcn.h>


typedef int(*op_func)(int,int); // this allow the program to call function dynamically

int main(){
    char op_name[6];//store the operation name
    int num1, num2;//store the two input of the 
    int x=1;
    while(x){
        int x=scanf("%5s %d %d",op_name,&num1, &num2);
        if(x!=3){
            break;
        }
        char libname[32];
        snprintf(libname, sizeof(libname),"./lib%s.so",op_name);// this funciton will work like printf but instead of that this just 
        //write the formatted output into a character buffer.
        // here its helping to construct the shared library name dyanamically 
        // this can also be done with the string concatenation 
        void* handle = dlopen(libname, RTLD_LAZY);// it loads a shared library dynammcially at the run time 

        if(!handle){// if error occur then print the message and move on to other command 
            fprintf(stderr, "Error loading library: %s\n", dlerror());
            continue;
        }

        dlerror();//clear any previous error message 
        op_func calculate = (op_func) dlsym(handle, op_name);// attempts to locate the function symbol

        char *error=dlerror();// check whether dlsym() failed 

        if(error != NULL){// print the message and move on skip the remaining block 
            fprintf(stderr, "Error finding function: %s\n",error);
            dlclose(handle);
            continue;
        }
        
        int result = calculate(num1, num2);//f the file is accuretly located and then the function is accuretly located then 
        // call the function and calcluate the result 
        printf("%d\n",result);// print the rusult 
        dlclose(handle);
        //close the dynammically allocated liabrary
        // free the space also 
    }
    return 0;

}
