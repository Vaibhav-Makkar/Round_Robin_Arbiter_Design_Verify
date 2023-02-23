module GRANT
#(
parameter CHANNELS = 8 , // t o t a l number o f request o r s
parameter WIDTH = 32 , // t h e w i d t h o f each request o r ' s w e i g h t
parameter WEIGHTLIMIT = 16
)
(
reset ,
clk ,
scan_in0 ,
scan_in1 ,
scan_in2 ,
scan_in3 ,
scan_in4 ,
scan_enable ,
test_mode ,
scan_out0 ,
scan_out1 ,
scan_out2 ,
scan_out3 ,
scan_out4 ,
// input
request , // request input
nextGrant , // nextGrant from NGPRC
weight , // weight of current request
// output
grant // request output
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
scan_enable , // test scan mode e n a b l e
test_mode ; // test mode
output
scan_out0 , // test scan mode data output
scan_out1 , // test scan mode data output
scan_out2 , // test scan mode data output
scan_out3 , // test scan mode data output
scan_out4 ; // test scan mode data output
// input
input [ (CHANNELS-1):0 ] request ;
input [ (CHANNELS-1):0 ] nextGrant ;
input [ (WIDTH-1):0 ] weight ;
// output
output reg [ (CHANNELS-1):0 ] grant ;
// internal registers
reg [ (WIDTH-1):0] s_counter ;
reg [ (CHANNELS-1):0] s_request ;
reg [ (WIDTH-1) :0] s_weight ;
// reg update ;
//??? intrnal C on s t an t s ???//
localparam SIZE = 4 ;
// STATES
reg [ ( SIZE-1):0 ] state ;
localparam RESET = 'b0001 ; // ' b00001
localparam GRANT_PROCESS = 'b0010 ; // ' b00100
localparam COUNT = 'b0100 ; // ' b01000
localparam GETWEIGHT = 'b1000 ; // ' b10000
//??? Code S t a r t s ??//
// register i / d e l a y request
always@ ( posedge clk , posedge reset )
begin : requestDelay
if ( reset == 1'b1 )
s_request = 0 ;
else
s_request = request ;
end
// always block for state transition
always@ ( posedge clk , posedge reset )
begin : requestStateTransition
// reset condition
if (reset==1'b1)
begin
state = 0 ;
end
// out of reset
else
begin
// state transisition
case ( state )
// request process this output request
GRANT_PROCESS :
begin
// if there is request
// go to COUNT state to count
if ( grant != 0 )
state = GETWEIGHT;
// just stay here and process next
else
state = state ;
end
GETWEIGHT :
begin
state = COUNT;
end
// count clock cycle according to weight
COUNT :
begin
// if counter is up
// move to request next
if ( s_counter >= s_weight )
state = GRANT_PROCESS;
// fairness limit set by user
// default is 16
else if ( s_counter >= WEIGHTLIMIT)
state = GRANT_PROCESS;
// else
// keep counting
else
state = state ;
end
// if statemachine never goes out of wack
default :
begin
state = GRANT_PROCESS;
end
endcase
end
end
// output l o g i c
always@ ( posedge clk , posedge reset )
begin : grantStateMachineOutputLogic
if ( reset == 1'b1 )
begin
grant = 0 ;
s_counter = 0 ;
s_weight = 0 ;
end
else
case ( state )
RESET :
begin
// reset everything in reset state
grant = 0 ;
s_counter = 0 ;
//s_mask = ~ 0 ;
end
GRANT_PROCESS :
begin
// update mask
//s_mask = nextGrant & (~ nextGrant + 1) ;
// requesting logic
grant = request & nextGrant & (~ nextGrant + 1 ) ;
// it takes 3 cycle to look back here
// so set the counter for when weight >= 2
s_counter = 2 ;
end
GETWEIGHT:
begin
s_weight = weight ;
end
COUNT :
begin
// count up until weight is reached account for clock cycle
s_counter = s_counter + 1 ;
// no change to request
grant = grant ;
end
// if statemachine never goes out of wack
default :
begin
grant = grant ;
s_counter = s_counter ;
end
endcase
end
endmodule // GRANT