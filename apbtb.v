`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.10.2026 15:54:07
// Design Name: 
// Module Name: apbtb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////



module apb_register_bank_tb;

    // Testbench signals
    reg PCLK;
    reg PRESETn;
    reg [31:0] PADDR;
    reg PSEL;
    reg PENABLE;
    reg PWRITE;
    reg [31:0] PWDATA;

    wire [31:0] PRDATA;
    wire PREADY;
    wire PSLVERR;

    // Instantiate the design under test
    apb_register_bank dut (
        .PCLK(PCLK),
        .PRESETn(PRESETn),
        .PADDR(PADDR),
        .PSEL(PSEL),
        .PENABLE(PENABLE),
        .PWRITE(PWRITE),
        .PWDATA(PWDATA),
        .PRDATA(PRDATA),
        .PREADY(PREADY),
        .PSLVERR(PSLVERR)
    );

    // Clock generation: 10 ns period
    always #5 PCLK = ~PCLK;

    // APB write task
    task apb_write;
        input [31:0] addr;
        input [31:0] data;
        begin
            // SETUP phase
            @(negedge PCLK);
            PSEL    = 1'b1;
            PENABLE = 1'b0;
            PWRITE  = 1'b1;
            PADDR   = addr;
            PWDATA  = data;

            // ACCESS phase
            @(negedge PCLK);
            PENABLE = 1'b1;

            // Write is captured at the next rising edge
            @(posedge PCLK);
            #1;

            // End transfer
            @(negedge PCLK);
            PSEL    = 1'b0;
            PENABLE = 1'b0;
            PWRITE  = 1'b0;
        end
    endtask

    // APB read and data-check task
    task apb_read_check;
        input [31:0] addr;
        input [31:0] expected;
        begin
            // SETUP phase
            @(negedge PCLK);
            PSEL    = 1'b1;
            PENABLE = 1'b0;
            PWRITE  = 1'b0;
            PADDR   = addr;

            // ACCESS phase
            @(negedge PCLK);
            PENABLE = 1'b1;
            #1;

            if (PRDATA !== expected) begin
                $display("FAIL: Address=%h Expected=%h Actual=%h",
                         addr, expected, PRDATA);
            end
            else begin
                $display("PASS: Address=%h Data=%h",
                         addr, PRDATA);
            end

            @(negedge PCLK);
            PSEL    = 1'b0;
            PENABLE = 1'b0;
        end
    endtask

    initial begin
        // Initialize all signals
        PCLK    = 1'b0;
        PRESETn = 1'b0;
        PADDR   = 32'b0;
        PSEL    = 1'b0;
        PENABLE = 1'b0;
        PWRITE  = 1'b0;
        PWDATA  = 32'b0;

        // Apply reset
        repeat (2) @(negedge PCLK);
        PRESETn = 1'b1;

        $display("Reset released");

        // Test 1: Read all registers after reset
        apb_read_check(32'h00, 32'h00000000);
        apb_read_check(32'h04, 32'h00000000);
        apb_read_check(32'h08, 32'h00000000);
        apb_read_check(32'h0C, 32'h00000000);

        // Test 2: Write data to all four registers
        apb_write(32'h00, 32'h12345678);
        apb_write(32'h04, 32'hAABBCCDD);
        apb_write(32'h08, 32'h00000055);
        apb_write(32'h0C, 32'hDEADBEEF);

        // Test 3: Read back the written values
        apb_read_check(32'h00, 32'h12345678);
        apb_read_check(32'h04, 32'hAABBCCDD);
        apb_read_check(32'h08, 32'h00000055);
        apb_read_check(32'h0C, 32'hDEADBEEF);

        // Test 4: Invalid address
        @(negedge PCLK);
        PSEL    = 1'b1;
        PENABLE = 1'b0;
        PWRITE  = 1'b0;
        PADDR   = 32'h10;

        // ACCESS phase
        @(negedge PCLK);
        PENABLE = 1'b1;
        #1;

        if (PSLVERR !== 1'b1)
            $display("FAIL: Invalid address did not assert PSLVERR");
        else
            $display("PASS: Invalid address detected");

        // End transfer
        @(negedge PCLK);
        PSEL    = 1'b0;
        PENABLE = 1'b0;

        $display("All test sequences completed");
        $finish;
    end

endmodule
