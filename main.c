#include <vpi_user.h>
#include <stdlib.h>
// static PLI_INT32 initial_cputime_g;




static int func_compiletf(char *user_data){
	user_data[0]=7;
	int x=*(int*)user_data;
	vpi_printf("func_compiletf\t %p %d\n",user_data,x);
	return 0;
}

static int func_calltf(char *user_data){
	int x=*(int*)user_data;
	vpi_printf("func_calltf\t %p %d\n",user_data,x);
	return 0;
}

static void func_register(){
	s_vpi_systf_data tf_data;

	tf_data.type       =vpiSysFunc; // vpiSysTask, vpiSysFunc 
	tf_data.sysfunctype=vpiIntFunc; //vpiSysTask, vpi[Int,Real,Time,Sized,SizedSigned]Func
	tf_data.tfname     ="$test_func";
	tf_data.calltf     =func_calltf;
	tf_data.compiletf  =func_compiletf;
	tf_data.sizetf     =0;
	tf_data.user_data  =malloc(8);
	vpi_register_systf(&tf_data);
}

void (*vlog_startup_routines[])(void)={func_register,NULL};