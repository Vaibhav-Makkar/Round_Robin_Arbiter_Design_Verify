// NGPRC module
// Next Grant PReCalculate
// This module precalculate the mask for the Grant Process
// The mask is shifted left to dictate round robin manner
// Input : request, grant
// Output : nextGrantmask
//
module NGPRC
#(
parameter CHANNELS = 8 //total number of requestors
)
(
reset,
clk,
scan_in0,
scan_in1,
scan_in2,
scan_in3,
scan_in4,
scan_enable,
test_mode,
scan_out0,
scan_out1,
scan_out2,
scan_out3,
scan_out4,
// inputs
request , // request input
grant, //grant input
// outputs
nextGrant //next grant output
) ;
input
reset , // system reset
clk , // system clock
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
input [(CHANNELS-1):0] request ;
input [(CHANNELS-1):0] grant ;
output reg [(CHANNELS-1):0] nextGrant ;
reg [(CHANNELS-1):0] priorityMask ;
//Internal Constants//
localparam SIZE = 2 ;
// STATES
reg [(SIZE-1):0]state ;
localparam RESET ='b01 ; // 3 ' b001
localparam NEXT_GRANT = 'b10 ; // 3 ' b010

// always block for state transition
always@ (posedge clk , posedge reset )
	begin : preCalStateTransition
		if (reset == 1'b1)
			begin
				state = RESET;
end
else
// state transition
	case (state)
// check if we are out of reset
		RESET:
			begin
// transition right away once NOT in reset
				state = NEXT_GRANT;
			end
		NEXT_GRANT :
			begin
// go back to reset if there is reset
				state = state ;
			end
		default:
			begin
// stay in the same state
			state = RESET;
			end

	endcase
end
// output logic
always @(posedge clk , posedge reset)
	begin : preCalOutputLogic
if (reset == 1'b1 )
	begin
		nextGrant = 0 ;
		priorityMask = 0 ;
end
else
	case (state)
	// reset signals in reset state
		RESET :
			begin
				nextGrant = 0 ;
				priorityMask = ~ 0;
end
// set next grant and priorityMask
// Handle wrap around c a se
		NEXT_GRANT :
			begin
					// calculate priority Mask
					// Rotate left , invert and add 1
				priorityMask = ~{grant[CHANNELS-2:0],grant[CHANNELS-1]}+ 1 ;
					// if grant somehow becomes zero , set priorityMask to all 1
					if (priorityMask == 0 )
						priorityMask = ~ 0;
					else
						priorityMask = priorityMask ;
					// calculate nextGrant
						nextGrant = request & priorityMask ;
					// if we see a request but nextGrant is zero it means we wrap around
						if ((nextGrant==0) && (request!=0))
							nextGrant = request ;
						end
					// if state machine never goes out of wack we should NOT reach to this case
		default :
			begin
				// keep all the signals the same
				priorityMask = priorityMask ;
				nextGrant = nextGrant ;
			end
	endcase
end
endmodule //NGPRC