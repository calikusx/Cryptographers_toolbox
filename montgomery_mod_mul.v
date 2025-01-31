`timescale 1ns / 1ps

module Montgomery#(parameter length = 16)(
    input [length-2:0] N,
    input [length-1:0] X,
    input [length-1:0] Y,
    output reg [length-1:0] T,
    input clk,
    input rst,
    input start,
    output reg done
    );
    parameter IDLE=0, WORK=1;
    reg state;
    reg [length-2:0] counter;
    reg [length-2:0] N_reg;
    reg [length-1:0] X_reg, Y_reg;
    reg [length:0] T_reg;
    wire m_i;
    wire [length+1:0] T_before_divide;
    always@(posedge clk or posedge rst) begin
        if(rst == 1) begin
            T <= 0;
            T_reg <= 0;
            state <= IDLE;
            counter <= 0;
            done <= 0;
        end
        else begin
            if(state == IDLE) begin
                counter <= 0;
                done <= 0;
                if(start == 1) begin
                    N_reg <= N;
                    X_reg <= X;
                    Y_reg <= Y;
                    state <= WORK;
                end
                else begin
                    N_reg <= 0;
                    X_reg <= 0;
                    Y_reg <= 0;
                    state <= IDLE;
                end
            end
            else begin
                if(counter == length+1) begin
                    counter <= 0;
                    done <= 1; 
                    if(T_reg[length-1:0]>N) begin
                         T <= T_reg[length-1:0]-N;
                    end
                    else begin
                        T <= T_reg[length-1:0];
                    end
                    T_reg <= 0;
                    state <= IDLE;
                end
                else begin
                    counter <= counter+1;
                    done <= 0; 
                    state <= WORK;
                   
                   X_reg <= X_reg>>1;
                  
                   T_reg <= (T_reg + ({(length){X_reg[0]}} & Y_reg) + ({(length-1){T_reg[0] ^ (X_reg[0] & Y_reg[0])}} & N_reg))>>1;
                    
                end
            end
        end
    end
endmodule

