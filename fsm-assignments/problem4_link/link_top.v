`timescale 1ns/1ps
`include "master_fsm.v"
`include "slave_fsm.v"
module link_top(
    input  wire clk,
    input  wire rst,
    output wire done
);
    wire req, ack;
    wire [7:0] data;
    wire [7:0] last;

    master_fsm u_master(
        .clk(clk), .rst(rst), .ack(ack),
        .req(req), .data(data), .done(done)
    );

    slave_fsm u_slave(
        .clk(clk), .rst(rst), .req(req), .data_in(data),
        .ack(ack), .last_byte(last)
    );
endmodule