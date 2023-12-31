`include "vending_machine_def.v"

module vending_machine (

	clk,							// Clock signal
	reset_n,						// Reset signal (active-low)

	i_input_coin,				// coin is inserted.
	i_select_item,				// item is selected.
	i_trigger_return,			// change-return is triggered

	o_available_item,			// Sign of the item availability
	o_output_item,			   // Sign of the item withdrawal
	o_return_coin,			   // Sign of the coin return
	o_current_total
);

	// Ports Declaration
	input clk;
	input reset_n;

	input [`kNumCoins-1:0] i_input_coin;
	input [`kNumItems-1:0] i_select_item;
	input i_trigger_return;

	output reg [`kNumItems-1:0] o_available_item;
	output reg [`kNumItems-1:0] o_output_item;
	output reg [`kReturnCoins-1:0] o_return_coin;
	output reg [`kTotalBits-1:0] o_current_total;

	// Net constant values (prefix kk & CamelCase)
	wire [31:0] kkItemPrice [`kNumItems-1:0];	// Price of each item
	wire [31:0] kkCoinValue [`kNumCoins-1:0];	// Value of each coin
	assign kkItemPrice[0] = 400;
	assign kkItemPrice[1] = 500;
	assign kkItemPrice[2] = 1000;
	assign kkItemPrice[3] = 2000;
	assign kkCoinValue[0] = 100;
	assign kkCoinValue[1] = 500;
	assign kkCoinValue[2] = 1000;

	// Internal states. You may add your own reg variables.
	reg [`kTotalBits-1:0] current_total;
	reg [`kNumItems-1:0] num_items ; //use if needed
	reg isReturn;
	reg n_isReturn;
	reg [`kTotalBits-1:0] next_total;
    
    integer idx;

	// Combinational circuit for the next states
	always @(*) begin
	
        for (idx = 0; idx < `kNumCoins; idx = idx + 1)
                if (i_input_coin[idx]) next_total = current_total + kkCoinValue[idx];
        
        if (i_input_coin == 0) next_total = current_total;        
        
        for (idx = 0; idx < `kNumItems; idx = idx + 1)
                if (i_select_item[idx] && current_total >= kkItemPrice[idx]) next_total = current_total - kkItemPrice[idx]; 
                
        n_isReturn = i_trigger_return ? 1 : 0;
        
	end
	// Combinational circuit for the output
	always @(*) begin
	     // return coin
	     o_return_coin = 0;
         if (isReturn) 
	     begin
	     for (idx = `kNumCoins - 1; idx >= 0; idx = idx - 1) begin
	           while (next_total >= kkCoinValue[idx]) begin
	              next_total = next_total - kkCoinValue[idx];
	              o_return_coin = o_return_coin + 1;
	           end
	     end
	     end
         
         // o_available_item;
         for (idx = 0; idx < `kNumItems; idx = idx + 1)
            if (current_total >= kkItemPrice[idx]) o_available_item[idx] = 1;
            else o_available_item[idx] = 0;
         if (isReturn) o_available_item = 0;
         
	     // o_output_item;
	     o_output_item = num_items;
	     
	     
	     
	     // current_total
	     o_current_total = isReturn ? 0 : current_total;
	     

	end


	// Sequential circuit to reset or update the states
	always @(posedge clk) begin
		if (!reset_n) begin
			// TODO: reset all states.
			//reset current_total
            current_total <= 0;
            next_total <= 0;
            
            //reset num_items
            num_items <= 0;
            
            //reset isReturn
            isReturn <= 0;
            n_isReturn <= 0;
		end
		else begin
			// TODO: update all states.
            // update current total
            current_total <= next_total;
            
            // update num_items
            for (idx = 0; idx < `kNumItems; idx = idx + 1)
                if (i_select_item[idx] && current_total >= kkItemPrice[idx]) begin num_items[idx] <= 1; end
                else num_items[idx] <= 0;
            
            // update isReturn
            isReturn <= n_isReturn;
            
		end
	end

endmodule
