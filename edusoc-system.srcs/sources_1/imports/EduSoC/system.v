`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: University of Stuttgart, ITI
// Engineer: Alexander Kharitonov
// 
// Create Date: 22.06.2023 13:55:05
// Design Name: 
// Module Name: system
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Basic system top component using EduSoC
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module system (
    input BOARD_CLK,
    input BOARD_RESN,
    output [3:0] BOARD_LED,
    output [2:0] BOARD_LED_RGB0,
    output [2:0] BOARD_LED_RGB1,
    input [3:0] BOARD_BUTTON,
    input [3:0] BOARD_SWITCH,
    output BOARD_VGA_HSYNC,
    output BOARD_VGA_VSYNC,
    output [3:0] BOARD_VGA_R,
    output [3:0] BOARD_VGA_G,
    output [3:0] BOARD_VGA_B,
    input BOARD_UART_RX,
    output BOARD_UART_TX
);

    wire cpu_clk;
    wire cpu_res;
    wire instr_valid;
    wire data_valid, instr_req, data_req, data_we, irq, irq_ack;
    wire cached_instr_req, cached_instr_valid;
    wire [31:0] cached_instr_adr, cached_instr_read;
    wire [4:0] irq_id, irq_ack_id;
    wire [31:0] pc_out, data_write, data_adr, instr_adr, data_read, instr_read;
    wire data_valid_mem, data_req_mem, data_we_mem;
    wire [2:0] s;
    wire [31:0] data_read_mem, data_adr_mem, data_write_mem;
    wire [3:0] data_be_mem;

    edusoc_basic soc (
      .BOARD_CLK(BOARD_CLK),
      .BOARD_RESN(BOARD_RESN),
      .BOARD_LED(BOARD_LED),
      .BOARD_LED_RGB0(BOARD_LED_RGB0),
      .BOARD_LED_RGB1(BOARD_LED_RGB1),
      .BOARD_BUTTON(BOARD_BUTTON),
      .BOARD_SWITCH(BOARD_SWITCH),
      .BOARD_VGA_HSYNC(BOARD_VGA_HSYNC),
      .BOARD_VGA_VSYNC(BOARD_VGA_VSYNC),
      .BOARD_VGA_R(BOARD_VGA_R),
      .BOARD_VGA_G(BOARD_VGA_G),
      .BOARD_VGA_B(BOARD_VGA_B),
      .BOARD_UART_RX(BOARD_UART_RX),
      .BOARD_UART_TX(BOARD_UART_TX),
      .CPU_CLK(cpu_clk),
      .CPU_RES(cpu_res),
      .INSTR_REQ(instr_req),
      .INSTR_VALID(instr_valid),
      .INSTR_ADDR(instr_adr),
      .INSTR_RDATA(instr_read),
      
      .DATA_REQ(data_req_mem),
      .DATA_VALID(data_valid_mem),
      .DATA_WE(data_we_mem),
      .DATA_BE(data_be_mem),
      .DATA_ADDR(data_adr_mem),
      .DATA_WDATA(data_write_mem),
      .DATA_RDATA(data_read_mem),
      
      .IRQ(irq),
      .IRQ_ID(irq_id),
      .IRQ_ACK(1'b0),
      .IRQ_ACK_ID(5'b0)
    );
    
    instr_cache cache(
        .clk(cpu_clk),
        .res(cpu_res),
        .cached_instr_req(cached_instr_req),
        .cached_instr_adr(cached_instr_adr),
        .cached_instr_valid(cached_instr_valid),
        .cached_instr_read(cached_instr_read),
        .instr_req(instr_req),
        .instr_adr(instr_adr),
        .instr_valid(instr_valid),
        .instr_read(instr_read)
    );
    
    memoryacces memoryacces(
        .CLK(cpu_clk),
        .RES(cpu_res),
    
        // von CPU
        .ADDR(data_adr),
        .DATA_WRITE(data_write),
        .DATA_REQ(data_req),
        .S(s),
        .WRITE_ENABLE(data_we),
    
        // von Speicher
        .DATA_READ_MEM(data_read_mem),
        .DATA_VALID_MEM(data_valid_mem),
    
        // zu CPU
        .DATA_READ(data_read),
        .DATA_VALID(data_valid),
    
        // Zu Speicher
        .DATA_ADR_MEM(data_adr_mem),
        .DATA_WRITE_MEM(data_write_mem),
        .DATA_REQ_MEM(data_req_mem),
        .DATA_WE_MEM(data_we_mem),
        .DATA_BE_MEM(data_be_mem)
    );
  
    proc proc(
    .instr_read(cached_instr_read),
    .data_read(data_read),
    .instr_valid(cached_instr_valid),
    .data_valid(data_valid),
    .CLK(cpu_clk),
    .RES(cpu_res),
    .irq(irq),
    .irq_id(irq_id),
    
    .pc_out(cached_instr_adr),
    .data_write(data_write),
    .data_adr(data_adr),
    .instr_req(cached_instr_req),
    .data_req(data_req),
    .data_write_enable(data_we),
    .irq_ack(irq_ack),
    .irq_ack_id(irq_ack_id),
    .s(s)
    );
    
    `ifdef XILINX_SIMULATOR
        reg clk;
        initial
            begin
                clk=0; 
            end
        always
            #5 clk=~clk;
    `else
        wire clk;
        assign clk=BOARD_CLK;
    `endif
endmodule
