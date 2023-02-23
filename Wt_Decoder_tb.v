module tb1 ;

localparam WIDTH = 32;
localparam CHANNELS = 8 ;
// clock period

localparam CLOCK_PERIOD = 20; //20ns (50Mhz)
wire scan_out0 , scan_out1 , scan_out2 , scan_out3 , scan_out4 ;
reg clk, reset ;
reg scan_in0, scan_in1, scan_in2, scan_in3, scan_in4, scan_enable, test_mode ;
// inputs
reg [(CHANNELS-1):0] test_selOneHot ;
reg [(CHANNELS*WIDTH)-1:0] test_dataInBus ;
// output
wire [(WIDTH-1):0] test_dataOut ;
// flow control flags
integer testDoneFlag = 0 ;
integer i = 1 ;
integer j = 0 ;
integer k = 0 ;
integer waveCounter = 1 ;
// temp reg /variables
reg [(WIDTH-1):0] tempDataIn ;
reg [(WIDTH-1):0] dataArray [(CHANNELS-1):0] ; // array to check output
MUX top (
. reset(reset) ,
. clk(clk) ,
. scan_in0(scan_in0) ,
. scan_in1(scan_in1) ,
. scan_in2(scan_in2) ,
. scan_in3(scan_in3) ,
. scan_in4(scan_in4) ,
. scan_enable (scan_enable) ,
. test_mode(test_mode) ,
. scan_out0(scan_out0) ,
. scan_out1(scan_out1) ,
. scan_out2(scan_out2) ,
. scan_out3(scan_out3) ,
. scan_out4(scan_out4) ,
. selOneHot(test_selOneHot) ,
. dataInBus(test_dataInBus) ,
. dataOut(test_dataOut)
);
initial
begin
		$timeformat (-9,2,"ns",16) ;
	` ifdef SDFSCAN
		$sdf_annotate ( "sdf/ADDC_tsmc18_scan.sdf " ,test.top ) ;
	` endif
clk = 1'b0 ;
reset = 1'b0 ;
scan_in0 = 1'b0 ;
scan_in1 = 1'b0 ;
scan_in2 = 1'b0 ;
scan_in3 = 1'b0 ;
scan_in4 = 1'b0 ;
scan_enable = 1'b0 ;
test_mode = 1'b0 ;
// initialize input to 1
test_selOneHot = 1 ;
// set the very first weight to 2 (channel 0)
test_dataInBus = 2 ;
tempDataIn = 2 ;
dataArray [0] = 2 ;
// input weight data bus generation
for ( j = 1 ; j < CHANNELS; j = j +1)
begin
// manipulate test data for each channel (increment by 2 in this case )
tempDataIn = tempDataIn + 2 ;
// set weight data bus by shifting and bitwise or
test_dataInBus = test_dataInBus|(tempDataIn << WIDTH*j ) ;
// save data to output checker array as well
dataArray [j] = tempDataIn ;
end
while(!testDoneFlag)
begin
@( posedge clk )
begin
// assign i to sel input as test vector
test_selOneHot = i ;
// i=1 will be shifted by 1 from bit 0 to bit (WIDTH?1)
i = i << 1 ;
// reset if we overflow
if(test_selOneHot == 0 )
i = 1 ;
end
end
end
// check output in parallel on negative edge
always @( negedge clk )
	begin
		for (k = 0 ; k < CHANNELS; k = k+1)
			begin
			// make sure input is valid ( one hot )
				if( test_selOneHot == 1 << k )
					// check if DUT output matches expected output
					if (test_dataOut!==dataArray [ k ] )
						begin
							// display useful information if the outputs don't match
								$display ("Wrong_output_at %0t", $time ) ;
								$display ("Expected %H,  Actual %H",dataArray[k],test_dataOut ) ;	
						 end
			end
// count waves
waveCounter = waveCounter + 1 ;
// stop if we looped through all channel values (*2 to see some extra length
if(waveCounter>=CHANNELS*2)
	$finish ;
end
// clock generation
always #(CLOCK_PERIOD/2)
	clk = ~ clk ;
endmodule

