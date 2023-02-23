// MUX module
// This module selects one of the inputs according to the input select signal
// Combinational Logic
// Input : selOneHot signal ONE HOT STYLE
// : dataInBus input data bus for all channels concat from ch0 to chN
// Output : dataOut  output data according to select signal

module MUX
#(
parameter WIDTH = 32 , // width of each channel
parameter CHANNELS = 8 // number of channels
)
(
reset ,
clk ,
scan_in0 ,
scan_in1 ,
scan_in2 ,
scan_in3 ,
scan_in4 ,
scan_enable,
test_mode ,
scan_out0 ,
scan_out1 ,
scan_out2 ,
scan_out3 ,
scan_out4 ,
selOneHot , // one hot select input
dataInBus , // input bus
dataOut // output data
) ;

input
reset , // system reset
clk ; // system clock

input
scan_in0 , // test scan mode data input
scan_in1 , // test scan mode data input
scan_in2 , // test scan mode data input
scan_in3 , // test scan mode data input
scan_in4 , // test scan mode data input
scan_enable , // test scan mode enable
test_mode ; // test mode

output
scan_out0 , // test scan mode data output
scan_out1 , // test scan mode data output
scan_out2 , // test scan mode data output
scan_out3 , // test scan mode data output
scan_out4 ; // test scan mode data output

input [ (CHANNELS-1) : 0 ] selOneHot ; // one hot select input
input [ (CHANNELS*WIDTH)-1 : 0 ] dataInBus ; // input data bus
output reg[(WIDTH-1) : 0 ] dataOut ; // output data after select

genvar gv ;
//??? COMBINATIONAL SECTION ???//
// temporary array to hold input channels
wire [ (WIDTH-1):0] inputArray [0:(CHANNELS-1)] ;
generate
// generate statement to assign input channels to temp array
for (gv = 0 ; gv < CHANNELS; gv = gv+1) 
begin : arrayAssignments
	assign inputArray [gv] = dataInBus [((gv+1)*WIDTH )-1:(gv*WIDTH)] ;
end // arrayAssignments
endgenerate

// function to convert one hot to decimal
function integer decimal ;
	input [CHANNELS-1:0] oneHotInput ;
	integer i ;
		for (i = 0 ; i<CHANNELS; i = i +1)
			if (oneHotInput[i])
				decimal = i ;
endfunction

// select the output according to input oneHot
always@(*)
	begin
		dataOut = inputArray [decimal(selOneHot)] ;
end // end always
endmodule // MUX

