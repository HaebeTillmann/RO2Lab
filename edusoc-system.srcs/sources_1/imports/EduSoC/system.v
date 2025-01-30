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
    
    wire instr_req_1, instr_valid_1, instr_req_2, instr_valid_2;
    wire data_req_1, data_valid_1, data_we_1, data_req_2, data_valid_2, data_we_2;
    wire [31:0] instr_addr_1, instr_rdata_1, instr_addr_2, instr_rdata_2;
    wire [31:0] data_addr_1, data_wdata_1, data_rdata_1, data_addr_2, data_wdata_2, data_rdata_2;
    wire [2:0] s_1, s_2;

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
    
    dualCoreMemBus memBus(
        .CLK(cpu_clk),
        .RES(cpu_res),
        
        // Instruction memory
        // Core 1
        .INSTR_REQ_1(instr_req_1),
        .INSTR_VALID_1(instr_valid_1),
        .INSTR_ADDR_1(instr_addr_1),
        .INSTR_RDATA_1(instr_rdata_1),
  
        // Core 2
        .INSTR_REQ_2(instr_req_2),
        .INSTR_VALID_2(instr_valid_2),
        .INSTR_ADDR_2(instr_addr_2),
        .INSTR_RDATA_2(instr_rdata_2),  
        
        // SOC
        .INSTR_REQ(cached_instr_req),
        .INSTR_VALID(cached_instr_valid),
        .INSTR_ADDR(cached_instr_adr),
        .INSTR_RDATA(cached_instr_read),
        
        // Data memory
        // Core 1
        .DATA_REQ_1(data_req_1),
        .DATA_VALID_1(data_valid_1),
        .DATA_WE_1(data_we_1),
        .DATA_ADDR_1(data_addr_1),
        .DATA_WDATA_1(data_wdata_1),
        .DATA_RDATA_1(data_rdata_1),
        .S_1(s_1),
        
         // Core 2
        .DATA_REQ_2(data_req_2),
        .DATA_VALID_2(data_valid_2),
        .DATA_WE_2(data_we_2),
        .DATA_ADDR_2(data_addr_2),
        .DATA_WDATA_2(data_wdata_2),
        .DATA_RDATA_2(data_rdata_2),
        .S_2(s_2),
         
        // SOC
        .DATA_REQ(data_req),
        .DATA_VALID(data_valid),
        .DATA_WE(data_we),
        .DATA_ADDR(data_adr),
        .DATA_WDATA(data_write),
        .DATA_RDATA(data_read),
        .S(s)
    );
  
    proc proc(
        .core_id(0),
        .instr_read(instr_rdata_1),
        .data_read(data_rdata_1),
        .instr_valid(instr_valid_1),
        .data_valid(data_valid_1),
        .CLK(cpu_clk),
        .RES(cpu_res),
        .irq(irq),
        .irq_id(irq_id),
        
        .pc_out(instr_addr_1),
        .data_write(data_wdata_1),
        .data_adr(data_addr_1),
        .instr_req(instr_req_1),
        .data_req(data_req_1),
        .data_write_enable(data_we_1),
        .irq_ack(irq_ack),
        .irq_ack_id(irq_ack_id),
        .s(s_1)
    );
    
    proc proc2(
         .core_id(1),
        .instr_read(instr_rdata_2),
        .data_read(data_rdata_2),
        .instr_valid(instr_valid_2),
        .data_valid(data_valid_2),
        .CLK(cpu_clk),
        .RES(cpu_res),
        .irq(irq),
        .irq_id(irq_id),
        
        .pc_out(instr_addr_2),
        .data_write(data_wdata_2),
        .data_adr(data_addr_2),
        .instr_req(instr_req_2),
        .data_req(data_req_2),
        .data_write_enable(data_we_2),
        .irq_ack(irq_ack),
        .irq_ack_id(irq_ack_id),
        .s(s_2)
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
