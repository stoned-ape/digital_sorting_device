



module minmax #(parameter int_len=32)(
	input [int_len-1:0]a,
	input [int_len-1:0]b,
	output[int_len-1:0]min,
	output[int_len-1:0]max
	);
	assign max=(a>b)?a:b;
	assign min=(a>b)?b:a;
endmodule




module sort #(parameter array_len=4,parameter int_len=32)(
	input clk,
	input load,
	input [array_len*int_len-1:0]in_array,
	output[array_len*int_len-1:0]out_array
	);
	reg even;
	reg [int_len-1:0]a   [array_len-1:0];
	reg [int_len-1:0]b   [array_len-1:0];
	wire[int_len-1:0]a2b [array_len-1:0];
	wire[int_len-1:0]b2a [array_len-1:0];
	wire[int_len-1:0]data[array_len-1:0];

	generate
		genvar j,k;
		for(j=0;j<array_len;j=j+2)begin:for1
			minmax #(.int_len(int_len))
			m0(a[j],a[j+1],a2b[j],a2b[j+1]);	
		end
		for(j=1;j<array_len-1;j=j+2)begin:for2
			minmax #(.int_len(int_len))
			m2(b[j],b[j+1],b2a[j],b2a[j+1]);
		end
		for(j=0;j<array_len;j=j+1)begin:for3
			for(k=0;k<int_len;k=k+1)begin:for3j
				buf b0(data[j][k],in_array[int_len*j+k]);
				buf b1(out_array[int_len*j+k],a[j][k]);
			end			
		end
	endgenerate

	assign b2a[0]=b[0];
	assign b2a[array_len-1]=b[array_len-1];

	integer i;
	always @(posedge clk)begin
		if(load) even=1;
		else even=!even;
		if(!even) for(i=0;i<array_len;i++) b[i]=a2b[i];
		else begin
			if(load)begin
				for(i=0;i<array_len;i++) a[i]=data[i];
			end else begin
				for(i=0;i<array_len;i++) a[i]=b2a[i];
			end
		end
	end

	initial begin
		$monitor(
			"a[3:0]={%d,%d,%d,%d} b[3:0]={%d,%d,%d,%d} clk=%b load=%b",
			a[3],a[2],a[1],a[0],b[3],b[2],b[1],b[0],
			clk,load
		);
	end
endmodule


module main();
	//array_len must be a multiple of 2
	parameter array_len=12,int_len=32;
	reg clk;
	reg load;
	integer i,j;
	wire[array_len*int_len-1:0]data_in;
	wire[array_len*int_len-1:0]data_out;
	reg[int_len-1:0]in_array[array_len-1:0];
	wire[int_len-1:0]out_array[array_len-1:0];

	generate
		genvar k,l;
		for(k=0;k<array_len;k=k+1)begin:for1
			for(l=0;l<int_len;l=l+1)begin:for2
				buf b0(data_in[int_len*k+l],in_array[k][l]);
				buf b1(out_array[k][l],data_out[int_len*k+l]);
			end
		end		
	endgenerate

	sort #(.array_len(array_len),.int_len(int_len))
	st(clk,load,data_in,data_out);
	
	initial begin
		$display("hardware sorting algorithm");
		$display("res=%d",$test_func());

		//fill array with values in reverse order
		for(j=0;j<array_len;j+=1) in_array[j]=array_len-j-1;

		load=0;
		#1 load=1; //load array into sort module
		#1 load=0;

		#(2*array_len) //wait for array_len cycles 

		//verify that the array is sorted
		for(j=0;j<array_len;j+=1) 
			if(out_array[j]!=j) $display("error");

		$finish();
	end
	initial begin 
		clk=0;
 		for(j=0;j<1000;j+=1) #1 clk=!clk;
	end
endmodule






