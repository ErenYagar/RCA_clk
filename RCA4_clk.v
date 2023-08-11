`timescale 1ns / 1ps
module RCA4_clk
(
input clk,
input rst_n,
input start,
input [3:0] A,
input [3:0] B,
output [3:0] S,
output Cout
);
wire [3:0] Cin;
wire [3:0] S_r;

reg start_d1;
reg start_d2;
wire start_TG;
reg fin_r;
reg [2:0] cnt;
reg busy_r;
wire fin_TG;

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
    start_d1 <= 1'b0;
    start_d2 <= 1'b0;
    end
    else
    begin
    start_d1 <= start;
    start_d2 <= start_d1;
    end
end
assign start_TG = start_d1 && !start_d2;


always@(posedge clk or negedge rst_n or posedge fin_TG)
begin
    if(!rst_n || fin_TG)
    begin
    busy_r <= 1'b0;
    end
    else
    begin
        if(start_TG)
        begin
        busy_r <= 1'b1;
        end
        else
        begin
        busy_r <= busy_r;
        end
    end
end

reg [3:0] A_r;
reg [3:0] B_r;

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
    A_r <= 4'd0;
    B_r <= 4'd0;
    end
    else
    begin
        if(start_TG)
        begin
        A_r <= A;
        B_r <= B;
        end
        else
        begin
        A_r <= A_r;
        B_r <= B_r;
        end
    end
end

always@(posedge clk or negedge rst_n or posedge start_TG)
begin
    if(!rst_n || start_TG)
    begin
    cnt <= 3'd0;
    end
    else
    begin
        if(busy_r && (cnt <= 3'd4))
        begin
        cnt <= cnt + 3'd1;
        end
        else
        begin
        cnt <= cnt;
        end
    end
end

always@(posedge clk or negedge rst_n or posedge start_TG)
begin
    if(!rst_n || start_TG)
    begin
    fin_r <= 1'b0;
    end
    else
    begin
        if(cnt == 3'd4)
        begin
        fin_r <= 1'b1;
        end
        else
        begin
        fin_r <= fin_r;
        end
    end
end
reg fin_d1;
always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
    fin_d1 <= 1'b0;
    end
    else
    begin
    fin_d1 <= fin_r;
    end
end
assign fin_TG = fin_r && !fin_d1;
reg [3:0] S_r2;
always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
    S_r2 <= 4'd0;
    end
    else
    begin
        if(fin_r)
        begin
        S_r2 <= S_r;
        end
        else
        begin
        S_r2 <= S_r2;
        end
    end
end
assign S = S_r2;

reg Cout_r;
always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
    Cout_r <= 1'b0;
    end
    else
    begin
        if(fin_r)
        begin
        Cout_r <= Cin[3];
        end
        else
        begin
        Cout_r <= Cout_r;
        end
    end
end

FA g0 ( .A(A_r[0]), .B(B_r[0]), .Cin(1'b0), .S(S_r[0]), .Cout(Cin[0]) );
FA g1 ( .A(A_r[1]), .B(B_r[1]), .Cin(Cin[0]), .S(S_r[1]), .Cout(Cin[1]) );
FA g2 ( .A(A_r[2]), .B(B_r[2]), .Cin(Cin[1]), .S(S_r[2]), .Cout(Cin[2]) );
FA g3 ( .A(A_r[3]), .B(B_r[3]), .Cin(Cin[2]), .S(S_r[3]), .Cout(Cin[3]) );
assign Cout = Cout_r;

endmodule