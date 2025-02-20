`timescale 1ps/1ps

module HazardDetectionUnit(
    input clk,
    input Branch_ID, rs1use_ID, rs2use_ID,
    input[1:0] hazard_optype_ID,
    input[4:0] rd_EXE, rd_MEM, rs1_ID, rs2_ID, rs2_EXE,
    
    output PC_EN_IF, reg_FD_EN, reg_FD_stall, reg_FD_flush,
        reg_DE_EN, reg_DE_flush, reg_EM_EN, reg_EM_flush, reg_MW_EN,
    output forward_ctrl_ls,
    output[1:0] forward_ctrl_A, forward_ctrl_B
);
    //according to the diagram, design the Hazard Detection Unit
    reg[1:0] hazard_optype_EXE, hazard_optype_MEM;
    always @(posedge clk) begin
        hazard_optype_MEM <= hazard_optype_EXE;
        hazard_optype_EXE <= hazard_optype_ID & {2{~reg_DE_flush}};
    end

    //
    wire forward_A_1 = rd_EXE && rs1use_ID && rs1_ID == rd_EXE && hazard_optype_EXE == 2'b01;
    wire forward_A_2 = rd_MEM && rs1use_ID && rs1_ID == rd_MEM && hazard_optype_MEM == 2'b10;
    wire forward_A_3 = rd_MEM && rs1use_ID && rs1_ID == rd_MEM && hazard_optype_MEM == 2'b10;

    wire A_stall = rd_EXE && rs1use_ID && rs1_ID == rd_EXE && hazard_optype_EXE == 2'b10 && hazard_optype_ID != 2'b11;

    //
    wire forward_B_1 = rd_EXE && rs2use_ID && rs2_ID == rd_EXE && hazard_optype_EXE == 2'b01;
    wire forward_B_2 = rd_MEM && rs2use_ID && rs2_ID == rd_MEM && hazard_optype_MEM == 2'b01;
    wire forward_B_3 = rd_MEM && rs2use_ID && rs2_ID == rd_MEM && hazard_optype_MEM == 2'b10;

    wire B_stall = rd_EXE && rs2use_ID && rs2_ID == rd_EXE && hazard_optype_EXE == 2'b10 && hazard_optype_ID != 2'b11;
    
    //
    assign forward_ctrl_ls = hazard_optype_MEM == 2'b10 && hazard_optype_EXE == 2'b11 && rs2_EXE == rd_MEM;

    assign forward_ctrl_A = {2{forward_A_1}} & 2'b01 |
                            {2{forward_A_2}} & 2'b10 |
                            {2{forward_A_3}} & 2'b11;

    assign forward_ctrl_B = {2{forward_B_1}} & 2'b01 |
                            {2{forward_B_2}} & 2'b10 |
                            {2{forward_B_3}} & 2'b11;

    //
    assign reg_FD_stall = A_stall | B_stall;
    assign reg_DE_flush = A_stall | B_stall;

    //
    assign reg_FD_flush = Branch_ID;

    //
    assign PC_EN_IF = ~(A_stall | B_stall);
    assign reg_FD_EN = 1'b1;
    assign reg_DE_EN = 1'b1;
    assign reg_EM_EN = 1'b1;
    assign reg_MW_EN = 1'b1;
endmodule