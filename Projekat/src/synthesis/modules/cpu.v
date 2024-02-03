module cpu #(
    parameter ADDR_WIDTH = 6,
    parameter DATA_WIDTH = 16
) 
(
    input clk,
    input rst_n,
    input [DATA_WIDTH-1:0] mem_in,
    input [DATA_WIDTH-1:0] in,
    output reg mem_we,
    output reg [ADDR_WIDTH-1:0] mem_addr,
    output reg [DATA_WIDTH-1:0] mem_data,
    output [DATA_WIDTH-1:0] out,
    output [ADDR_WIDTH-1:0] pc,
    output [ADDR_WIDTH-1:0] sp

);

// sequentil logic
    reg [DATA_WIDTH-1:0] out_reg, out_next;
    assign out = out_reg;

    // states
    reg[3:0] state_reg, state_next;
    localparam start = 4'h0;
    localparam fetchH = 4'h1;
    localparam fetchLorExec = 4'h2;
    localparam inIndirect = 4'h3;
    localparam outFetchData = 4'h4;
    localparam outIndirectFetchAddress = 4'h5;
    localparam movWrite = 4'h6;
    localparam movReadData = 4'h7;
    localparam movWriteInd = 4'h8;
    localparam movConst = 4'h9;
// cl, ld, in, inc, dec, sr, ir, sl, il, out
    

// PC stuff    
    reg PC_cl, PC_ld, PC_inc, PC_dec, PC_sr, PC_ir, PC_sl, PC_il;
    reg [ADDR_WIDTH-1:0] PC_in;

    register #(.DATA_WIDTH(ADDR_WIDTH)) PC (.clk(clk), .rst_n(rst_n), .cl(PC_cl), .ld(PC_ld), .in(PC_in), 
        .inc(PC_inc), .dec(PC_dec), .sr(PC_sr), .ir(PC_ir), .sl(PC_sl), .il(PC_il), .out(pc));

// SP stuff
    reg SP_cl, SP_ld, SP_inc, SP_dec, SP_sr, SP_ir, SP_sl, SP_il;
    reg [ADDR_WIDTH-1:0] SP_in;

    register #(.DATA_WIDTH(ADDR_WIDTH)) SP (.clk(clk), .rst_n(rst_n), .cl(SP_cl), .ld(SP_ld), .in(SP_in), 
        .inc(SP_inc), .dec(SP_dec), .sr(SP_sr), .ir(SP_ir), .sl(SP_sl), .il(SP_il), .out(sp));

// IRH stuff
    reg IRH_cl, IRH_ld, IRH_inc, IRH_dec, IRH_sr, IRH_ir, IRH_sl, IRH_il;
    reg [15:0] IRH_in;
    wire [15:0] IRH_out;

    register #(.DATA_WIDTH(16)) IRH (.clk(clk), .rst_n(rst_n), .cl(IRH_cl), .ld(IRH_ld), .in(IRH_in),
        .inc(IRH_inc), .dec(IRH_dec), .sr(IRH_sr), .ir(IRH_sr), .sl(IRH_sl), .il(IRH_il), .out(IRH_out));
// IRL stuff
    reg IRL_cl, IRL_ld, IRL_inc, IRL_dec, IRL_sr, IRL_ir, IRL_sl, IRL_il;
    reg [15:0] IRL_in;
    wire [15:0] IRL_out;

    register #(.DATA_WIDTH(16)) IRL (.clk(clk), .rst_n(rst_n), .cl(IRL_cl), .ld(IRL_ld), .in(IRL_in),
        .inc(IRL_inc), .dec(IRL_dec), .sr(IRL_sr), .ir(IRL_sr), .sl(IRL_sl), .il(IRL_il), .out(IRL_out));

// AL stuff
    reg AL_cl, AL_ld, AL_inc, AL_dec, AL_sr, AL_ir, AL_sl, AL_il;
    reg [15:0] AL_in;
    wire [15:0] AL_out;

    register #(.DATA_WIDTH(16)) AL (.clk(clk), .rst_n(rst_n), .cl(AL_cl), .ld(AL_ld), .in(AL_in),
        .inc(AL_inc), .dec(AL_dec), .sr(AL_sr), .ir(AL_sr), .sl(AL_sl), .il(AL_il), .out(AL_out));



    always @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            out_reg <= {DATA_WIDTH{1'b0}};
            state_reg <= start;
        end else begin
            out_reg <= out_next;
            state_reg <= state_next;
        end
    end


    always @(*) begin

    // comb logic
        out_next = out_reg;
        state_next = state_reg;
    // memory signALs
        mem_we = 1'b0;
        mem_addr = {ADDR_WIDTH{1'b0}};
        mem_data = {DATA_WIDTH{1'b0}};
    // PC signALs
        PC_cl = 1'b0; PC_ld = 1'b0; PC_inc = 1'b0; PC_dec = 1'b0;
        PC_sr = 1'b0; PC_ir = 1'b0; PC_sl = 1'b0; PC_il = 1'b0;
        PC_in = {ADDR_WIDTH{1'b0}}; 
    // SP signALs
        SP_cl = 1'b0; SP_ld = 1'b0; SP_inc = 1'b0; SP_dec = 1'b0;
        SP_sr = 1'b0; SP_ir = 1'b0; SP_sl = 1'b0; SP_il = 1'b0;
        SP_in = {ADDR_WIDTH{1'b0}};     
    // IRH signALs
        IRH_cl = 1'b0; IRH_ld = 1'b0; IRH_inc = 1'b0; IRH_dec = 1'b0; 
        IRH_sr = 1'b0; IRH_ir = 1'b0; IRH_sl = 1'b0; IRH_il = 1'b0;
        IRH_in = 16'h0;
    // IRL signALs
        IRL_cl = 1'b0; IRL_ld = 1'b0; IRL_inc = 1'b0; IRL_dec = 1'b0; 
        IRL_sr = 1'b0; IRL_ir = 1'b0; IRL_sl = 1'b0; IRL_il = 1'b0;
        IRL_in = 16'h0;
    // AL signALs
        AL_cl = 1'b0; AL_ld = 1'b0; AL_inc = 1'b0; AL_dec = 1'b0; 
        AL_sr = 1'b0; AL_ir = 1'b0; AL_sl = 1'b0; AL_il = 1'b0;
        AL_in = 16'h0;

        case (state_reg)
            
            start: begin
                // start fetching in next clock
                state_next = fetchH;
                // load initial PC
                PC_in = 4'h8;
                PC_ld = 1'b1;
                // load initial SP
                SP_in = {ADDR_WIDTH{1'b1}};
                SP_ld = 1'b1;
                // reset IRH
                IRH_cl = 1'b1;
                // reset IRL
                IRL_cl = 1'b1;
                // reset AL
                AL_cl = 1'b1;
            end 

            fetchH: begin
                // TO DO : change state
                state_next = fetchLorExec;
                // IRH = mem[pc] -> setup mem[pc], the value will be available on 
                    // next clock
                mem_we = 0;
                mem_addr = pc;
                // pc = pc + 1;
                PC_inc = 1'b1;
            end

            fetchLorExec: begin
                // TO DO : change state

                // IRH = memout
                IRH_in = mem_in;
                IRH_ld = 1'b1;
                // start executing based on op code
                case (mem_in[15:12])
                    4'h7:begin
                        // IN instruction
                        case (mem_in[11])
                            1'b0:begin
                                // mem[x]
                                mem_we = 1'b1;
                                mem_data = in;
                                mem_addr = mem_in[10:8];
                                state_next = fetchH;
                            end 
                            1'b1:begin
                                // mem[mem[x]]
                                mem_we = 1'b0;
                                mem_addr = mem_in[10:8];
                                state_next = inIndirect;
                            end  
                        endcase
                    end  

                    4'h8:begin
                        // OUT instruction
                        case (mem_in[11])
                            1'b0:begin
                                // out = mem[x]
                                // read the data first
                                mem_we = 1'b0;
                                mem_addr = mem_in[10:8];
                                state_next = outFetchData;
                            end 
                            1'b1: begin
                                // out = mem[mem[x]]
                                // read mem[x] first
                                mem_we = 1'b0;
                                mem_addr = mem_in[10:8];
                                state_next = outIndirectFetchAddress;
                            end
                        endcase
                    end

                    4'h0:begin
                        // MOV instruction
                        case (mem_in[3:0])
                            4'b0000:begin
                                // first version of MOV (without the second instruction byte)
                                // check for second op (in)direct
                                case (mem_in[7])
                                    1'b0:begin
                                        // second op is direct
                                        // reading it from mem in next clock
                                        mem_we = 0;
                                        mem_addr = mem_in[6:4];
                                        state_next = movWrite;
                                    end 
                                    1'b1:begin
                                        // second op is indirect
                                        // readint its address from mem in next clock
                                        mem_we = 0;
                                        mem_addr = mem_in[6:4];
                                        state_next = movReadData;
                                    end 
                                endcase
                            end 
                            4'b1000:begin
                                // second version of MOV (with the instruction byte)
                                // fetch second byte 
                                mem_we = 0;
                                mem_addr = pc;
                                PC_inc = 1'b1;

                                state_next = movConst;
                            end
                        endcase
                    end
                endcase
            end     

            inIndirect: begin
                // TO DO : change state
                
                mem_we = 1'b1;
                mem_data = in;
                mem_addr = mem_in;
                state_next = fetchH;

            end

            outFetchData:begin
                out_next = mem_in;
                state_next = fetchH;
            end

            outIndirectFetchAddress:begin
                
                mem_we = 1'b0;
                mem_addr = mem_in;
                state_next = outFetchData;
            end

            movReadData: begin
                // setting up reading data to be written in first version of MOV
                // reading it from mem in next clock
                mem_we = 0;
                mem_addr = mem_in;
                state_next = movWrite;

            end 


            movWrite: begin
                // mem_in contains the data that is going to be written
                // check for first op (in)direct
                // instruction byte is in IRH

                case (IRH_out[11])
                    1'b0:begin
                        // direct
                        // just use first op as the address 
                        mem_we = 1;
                        mem_addr = IRH_out[10:8];
                        mem_data = mem_in;
                        state_next = fetchH;
                    end 
                    1'b1:begin
                        // indirect
                        // get the goal address using the first op as the address
                        AL_in = mem_in; AL_ld = 1'b1;
                        mem_we = 0;
                        mem_addr = IRH_out[10:8];
                        state_next = movWriteInd;
                    end 
                endcase
            end 

            movWriteInd: begin
                // mem_in contains the address to be written to
                // al contains the data to be written

                mem_we = 1;
                mem_addr = mem_in;
                mem_data = AL_out;
                AL_cl = 1;

                state_next = fetchH;
            end 

            movConst: begin
                // mem_in containt the second byte of the MOV instruction
                // load the second byte into IRL
                IRL_in = mem_in;
                IRL_ld = 1'b1;

                // set this up so data is in mem_in
                // it already is so this mightve been with one clock else but whatever

                mem_we = 1'b0;
                mem_addr = pc - 1'b1;

                state_next = movWrite;

            end 
        endcase


        

    end
    
endmodule