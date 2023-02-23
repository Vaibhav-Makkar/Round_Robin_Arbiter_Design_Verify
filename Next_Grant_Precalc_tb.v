module next_grant_tb ;
localparam WIDTH = 32;
localparam CHANNELS = 8 ;
// clock period
localparam CLOCK_PERIOD = 100; //20ns (50Mhz)
wire scan_out0 , scan_out1 , scan_out2 , scan_out3 , scan_out4 ;
reg clk, reset;
reg scan_in0, scan_in1, scan_in2, scan_in3, scan_in4, scan_enable, test_mode ;
// inputs
reg [(CHANNELS-1):0] test_request ;
reg [(CHANNELS-1):0] test_grant ;
// flow control
reg [(CHANNELS-1):0] expectedNextGrant ;
reg sticky ;
// output
wire [(CHANNELS-1):0] test_nextGrant ;
wire [4:0] test_debugPreCal ;
NGPRC top (
. reset(reset) ,
. clk(clk) ,
. scan_in0(scan_in0) ,
. scan_in1(scan_in1) ,
. scan_in2(scan_in2) ,
. scan_in3(scan_in3) ,
. scan_in4(scan_in4) ,
. scan_enable(scan_enable) ,
. test_mode(test_mode) ,
. scan_out0(scan_out0) ,
. scan_out1(scan_out1) ,
. scan_out2(scan_out2) ,
. scan_out3(scan_out3) ,
. scan_out4(scan_out4) ,
// input
. request (test_request) ,
. grant(test_grant) ,
// output
. nextGrant (test_nextGrant)
) ;
initial
	begin
		$timeformat(-9,2,"ns",16) ;
		` ifdef SDFSCAN
			$sdf_annotate ( "sdf/ADDC_tsmc18_scan .sdf " , next_grant_tb.top ) ;
		`endif
			clk = 1'b0 ;
			reset = 1'b1 ;
			scan_in0 = 1'b0 ;
			scan_in1 = 1'b0 ;
			scan_in2 = 1'b0 ;
			scan_in3 = 1'b0 ;
			scan_in4 = 1'b0 ;
			scan_enable = 1'b0 ;
			test_mode = 1'b0 ;
			sticky = 0 ;
			test_request = 0 ;
			test_grant = 0 ;
			// release reset
			@(posedge clk) ;
				reset = 1'b0 ;
				// test case1
			// request = 0000_000
			// grant = don' t care
			// nextGrant = 0000_0000
			@(posedge clk) ;
				test_request = 0 ;
				test_grant = 0 ;
				expectedNextGrant = 0 ;
				$display ("--------TEST CASE 1--------") ;
				$display (" Request = %b " , test_request) ;
				$display (" Grant   = %b " , test_grant) ;
			@(negedge clk ) ;
				if(test_nextGrant!= expectedNextGrant)
					begin
						sticky = 1 ;
						$display(" Expected next Grant = %b  Actual = %b " ,expectedNextGrant ,test_nextGrant) ;
					end
				else
						$display (" Next Grant = %b " , test_nextGrant) ;


			// test case2
			// request = 1111_1111
			// grant = 0001
			// nextGrant = 1111_1110
			@(posedge clk) ;
				test_request = 8'hFF ;
				test_grant = 1 ;
				expectedNextGrant = 8'b1111_1110 ;
				$display ("--------TEST CASE 2--------") ;
				$display (" Request = %b " , test_request) ;
				$display (" Grant   = %b " , test_grant) ;
			@(negedge clk ) ;
				if(test_nextGrant!= expectedNextGrant)
					begin
						sticky = 1 ;
						$display(" Expected next Grant = %b  Actual = %b " ,expectedNextGrant ,test_nextGrant) ;
					end
				else
						$display (" Next Grant = %b " , test_nextGrant) ;
			// test case3
			// request = 1111_1110
			// grant = 0010
			// nextGrant = 1111_1100
			@(posedge clk) ;
				test_request = 8'hFF ;
				test_grant = 8'b0000_0010 ;
				expectedNextGrant = 8'b1111_1100 ;
			$display ("--------TEST CASE 3--------") ;
				$display (" Request = %b " , test_request) ;
				$display (" Grant   = %b " , test_grant) ;
			@(negedge clk ) ;
				if(test_nextGrant!= expectedNextGrant)
					begin
						sticky = 1 ;
						$display(" Expected next Grant = %b  Actual = %b " ,expectedNextGrant ,test_nextGrant) ;
					end
				else
						$display (" Next Grant = %b " , test_nextGrant) ;

			// test case4
			// request = 1111_1110
			// grant = 0000_0100
			// nextGrant = 1111_1000
			@(posedge clk) ;
				test_request = 8'hFF ;
				test_grant = 8'b0000_0100 ;
				expectedNextGrant = 8'b1111_1000 ;
			$display ("--------TEST CASE 4--------") ;
				$display (" Request = %b " , test_request) ;
				$display (" Grant   = %b " , test_grant) ;
			@(negedge clk ) ;
				if(test_nextGrant!= expectedNextGrant)
					begin
						sticky = 1 ;
						$display(" Expected next Grant = %b  Actual = %b " ,expectedNextGrant ,test_nextGrant) ;
					end
				else
						$display (" Next Grant = %b " , test_nextGrant) ;
			
			// test case5
			// request = 1111_1111
			// grant = 1000_0000
			// nextGrant = 1111_1111
			@(posedge clk) ;
				test_request = 8'hFF ;
				test_grant = 8'b1000_0000 ;
				expectedNextGrant = 8'b1111_1111 ;
			$display ("--------TEST CASE 5--------") ;
				$display (" Request = %b " , test_request) ;
				$display (" Grant   = %b " , test_grant) ;
			@(negedge clk ) ;
				if(test_nextGrant!= expectedNextGrant)
					begin
						sticky = 1 ;
						$display(" Expected next Grant = %b  Actual = %b " ,expectedNextGrant ,test_nextGrant) ;
					end
				else
						$display (" Next Grant = %b " , test_nextGrant) ;

			// test case6
			// request = 0000_0000
			// grant = xxxx
			// nextGrant = 0000_0000
			@(posedge clk) ;
				test_request = 8'h00 ;
				test_grant = 8'b1 ;
				expectedNextGrant = 8'b0 ;
			$display ("--------TEST CASE 6--------") ;
				$display (" Request = %b " , test_request) ;
				$display (" Grant   = %b " , test_grant) ;
			@(negedge clk ) ;
				if(test_nextGrant!= expectedNextGrant)
					begin
						sticky = 1 ;
						$display(" Expected next Grant = %b  Actual = %b " ,expectedNextGrant ,test_nextGrant) ;
					end
				else
						$display (" Next Grant = %b " , test_nextGrant) ;

			// test case7
			// request = 0000_0010
			// grant = 0000_0010
			// nextGrant = 0000_0010
			@(posedge clk) ;
				test_request = 8'b0000_0010 ;
				test_grant = 8'b0000_0010 ;
				expectedNextGrant = 8'b0000_0010 ;
			$display ("--------TEST CASE 7--------") ;
				$display (" Request = %b " , test_request) ;
				$display (" Grant   = %b " , test_grant) ;
			@(negedge clk ) ;
				if(test_nextGrant!= expectedNextGrant)
					begin
						sticky = 1 ;
						$display(" Expected next Grant = %b  Actual = %b " ,expectedNextGrant ,test_nextGrant) ;
					end
				else
						$display (" Next Grant = %b " , test_nextGrant) ;

			// test case8
			// request = 0000_0010
			// grant = 0
			// nextGrant = 0000_0010
			@(posedge clk) ;
				test_request = 8'b0000_0010 ;
				test_grant = 8'b0 ;
				expectedNextGrant = 8'b0000_0010 ;
			$display ("--------TEST CASE 8--------") ;
				$display (" Request = %b " , test_request) ;
				$display (" Grant   = %b " , test_grant) ;
			@(negedge clk ) ;
				if(test_nextGrant!= expectedNextGrant)
					begin
						sticky = 1 ;
						$display(" Expected next Grant = %b  Actual = %b " ,expectedNextGrant ,test_nextGrant) ;
					end
				else
						$display (" Next Grant = %b " , test_nextGrant) ;
			@(posedge clk)
			reset = 1'b1 ;
			@( posedge clk )
			reset = 1'b0 ;
			@( posedge clk ) ;
			@( posedge clk ) ;
			@( posedge clk ) ;
			if (sticky == 1 )
			$display (" Test failed !! " ) ;
			else
			$display (" Test Passed !!" ) ;
			$finish ;
			end

always #(CLOCK_PERIOD/2 )
	clk = ~ clk ;
endmodule
