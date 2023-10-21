module spi_master #(
    parameter CLK_DIV = 2   // Clock division factor
)(
    input clk,        // Clock input
    input rst,        // Reset input
    input miso,       // Master In Slave Out data line
    output mosi,      // Master Out Slave In data line
    output sck,       // Serial Clock line
    input start,      // Start signal
    input [7:0] data_in, // 8-bit input data
    output [7:0] data_out, // 8-bit output data
    output busy,      // Busy flag
    output new_data   // New data available flag
);

    // State definitions
    localparam STATE_SIZE = 2;
    localparam IDLE = 2'd0,
               WAIT_HALF = 2'd1,
               TRANSFER = 2'd2;

    // Internal registers
    reg [STATE_SIZE-1:0] state_d, state_q;
    reg [7:0] data_d, data_q;
    reg [CLK_DIV-1:0] sck_d, sck_q;
    reg mosi_d, mosi_q;
    reg [2:0] ctr_d, ctr_q;
    reg new_data_d, new_data_q;
    reg [7:0] data_out_d, data_out_q;

    // Output assignments
    assign mosi = mosi_d; //pragya changed from mosi_q to mosi_d
    assign sck = (~sck_q[CLK_DIV-1]) & (state_q == TRANSFER);
    assign busy = state_q != IDLE;
    assign data_out = data_out_q;
    assign new_data = new_data_q;

    // Combinational Logic Block
    always @(*) begin
        // Default assignments
        sck_d = sck_q;
        data_d = data_q;
        mosi_d = mosi_q;
        ctr_d = ctr_q;
        new_data_d = 1'b0;
        data_out_d = data_out_q;
        state_d = state_q;

        // State machine
        case (state_q)
            IDLE: begin
                sck_d = 4'b0;  // Reset clock counter
                ctr_d = 3'b0;  // Reset bit counter
                // If start signal is active
                if (start == 1'b1) begin
                    data_d = data_in; // Load input data
                    state_d = WAIT_HALF; // Move to next state
                end
            end

            WAIT_HALF: begin
                sck_d = sck_q + 1'b1;  // Increment clock counter
                // If half of the clock period has elapsed
                if (sck_q == {CLK_DIV-1{1'b1}}) begin
                    sck_d = 1'b0;  // Reset clock counter
                    state_d = TRANSFER; // Move to next state
                end
            end

            TRANSFER: begin
                sck_d = sck_q + 1'b1;  // Increment clock counter
                // If the clock counter is at zero (rising edge)
                if (sck_q == 4'b0000) begin
                    mosi_d = data_q[7];  // Set the most significant bit to mosi
                // If the clock is half full (falling edge)
                end else if (sck_q == {CLK_DIV-1{1'b1}}) begin
                    data_d = {data_q[6:0], miso};  // Shift and include miso bit
                // If clock counter is full (rising edge)
                end else if (sck_q == {CLK_DIV{1'b1}}) begin
                    ctr_d = ctr_q + 1'b1;  // Increment bit counter
                    // If we are on the last bit
                    if (ctr_q == 3'b111) begin
                        state_d = IDLE;  // Go back to idle state
                        data_out_d = data_q; // Set the output data register
                        new_data_d = 1'b1; // Indicate new data is available
                    end
                end
            end
        endcase
    end

    // Sequential Logic Block
    always @(posedge clk) begin
        if (rst) begin
            // On reset, initialize all registers
            ctr_q <= 3'b0;
            data_q <= 8'b0;
            sck_q <= 4'b0;
            mosi_q <= 1'b0;
            state_q <= IDLE;
            data_out_q <= 8'b0;
            new_data_q <= 1'b0;
        end else begin
            // Transfer intermediate values to state registers
            ctr_q <= ctr_d;
            data_q <= data_d;
            sck_q <= sck_d;
            mosi_q <= mosi_d;
            state_q <= state_d;
            data_out_q <= data_out_d;
            new_data_q <= new_data_d;
        end
    end
endmodule


