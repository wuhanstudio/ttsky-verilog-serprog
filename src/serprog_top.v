`timescale 1ns/1ps
`default_nettype none

module tt_um_serprog_top #(
    parameter integer CLK_FREQ_HZ = 24000000,
    parameter integer BAUD_RATE   = 115200,
    parameter integer RESET_CYCLES = 100000
) (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);
    localparam integer CLKS_PER_BIT = CLK_FREQ_HZ / BAUD_RATE;

    // Pin mapping:
    //   ui_in[0]  = uart_rx
    //   uo_out[0] = uart_tx

    //   uio[0]    = flash_sck_out  
    //   uio[1]    = flash_cs_out
    //   uio[2]    = flash_mosi_out
    //   uio[3]    = flash_miso_in

    wire uart_rx        = ui_in[0];
    wire uart_tx;
    wire led_done;
    wire flash_sck_out;
    wire flash_cs_out;
    wire flash_mosi_out;
    wire flash_miso_in  = uio_in[3];

    assign uo_out  = {6'b0, led_done, uart_tx};
    assign uio_out = {4'b0, flash_miso_in, flash_mosi_out, flash_cs_out, flash_sck_out};
    assign uio_oe  = 8'b0000_0111;

    wire _unused = &{ena, uio_in[7:4], uio_in[2:0], 1'b0};

    reg [31:0] reset_count = 32'd0;
    reg        rst_i = 1'b1;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            reset_count <= 32'd0;
            rst_i <= 1'b1;
        end else begin
            if (reset_count < RESET_CYCLES) begin
                reset_count <= reset_count + 32'd1;
                rst_i <= 1'b1;
            end else begin
                rst_i <= 1'b0;
            end
        end
    end

    app #(
        .CLKS_PER_BIT(CLKS_PER_BIT)
    ) u_app (
        .clk(clk),
        .rst(rst_i),
        .uart_rx_i(uart_rx),
        .uart_tx_o(uart_tx),
        .flash_sck_out(flash_sck_out),
        .flash_cs_out(flash_cs_out),
        .flash_mosi_out(flash_mosi_out),
        .flash_miso_in(flash_miso_in),
        .done(led_done)
    );
endmodule
