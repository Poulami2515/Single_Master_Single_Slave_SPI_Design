module spi_slave(
    input clk,      // Clock input
    input rst,      // Reset input
    input ss,       // Slave Select
    input mosi,     // Master Out, Slave In
    output miso,    // Master In, Slave Out
    input sck,      // Serial Clock
    output done,    // Data transmission done flag
    input [7:0] din,  // 8-bit data input
    output [7:0] dout // 8-bit data output
);

// Declare registers for internal operations
reg mosi_d, mosi_q;
reg ss_d, ss_q;
reg sck_d, sck_q;
reg sck_old_d, sck_old_q;
  reg [7:0] data_d, data_q;
reg done_d, done_q;
reg [2:0] bit_ct_d, bit_ct_q; // Bit counter, 3 bits to count 0-7
reg [7:0] dout_d, dout_q;
reg miso_d, miso_q;

// Assigning register values to output
assign miso = miso_q;
assign done = done_q;
assign dout = dout_q;

// Combinational Logic Block
always @(*) begin
    // Default assignments for combinational variables
    ss_d      = ss;
    mosi_d    = mosi;
    miso_d    = miso_q;
    sck_d     = sck;
    sck_old_d = sck_q;
    data_d    = data_q;
    done_d    = 1'b0; // Ensure done flag is low by default
    bit_ct_d  = bit_ct_q;
    dout_d    = dout_q;

    // Check if slave is selected (ss is low when selected)
    if (ss_q) begin
        bit_ct_d = 3'b0;  // Reset bit counter
        data_d   = din;   // Load new data to be transmitted
        miso_d   = data_q[7]; // Assign most significant bit to miso
    end else begin
        // On Rising edge of Serial Clock (sck)
        if (!sck_old_q && sck_q) begin 
            data_d   = {data_q[6:0], mosi_q}; // Shift in mosi bit
            bit_ct_d = bit_ct_q + 1'b1;       // Increment bit count

            // If 8 bits have been processed
            if (bit_ct_q == 3'b111) begin
                dout_d = {data_q[6:0], mosi_q}; // Update dout with received byte
                done_d = 1'b1; // Set done flag high indicating byte reception is complete
                data_d = din;  // Load new data to be transmitted next
            end
        // On Falling edge of Serial Clock (sck)
        end else if (sck_old_q && !sck_q) begin 
            miso_d = data_q[7]; // Assign most significant bit to miso
        end
    end
end

// Sequential Logic Block
always @(posedge clk) begin
    // Check if reset is active
    if (rst) begin
        // Reset all sequential variables
        done_q  <= 1'b0;
        bit_ct_q <= 3'b0;
        dout_q  <= 8'b0;
        miso_q  <= 1'b1;
    end else begin
        // Transfer values from combinational (_d) to sequential (_q) variables
        done_q <= done_d;
        bit_ct_q <= bit_ct_d;
        dout_q <= dout_d;
        miso_q <= miso_d;
    end
    
    // Update old state registers with current state values
    sck_q <= sck_d;
    mosi_q <= mosi_d;
    ss_q <= ss_d;
    data_q <= data_d;
    sck_old_q <= sck_old_d;
end

endmodule
