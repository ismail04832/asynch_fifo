
module async_fifo #(
    parameter int DATA_WIDTH = 8,
    parameter int DEPTH      = 16
)(
    input  logic                  wr_clk,
    input  logic                  wr_rst_n,
    input  logic                  wr_en,
    input  logic [DATA_WIDTH-1:0] wr_data,
    output logic                  wr_full,

    input  logic                  rd_clk,
    input  logic                  rd_rst_n,
    input  logic                  rd_en,
    output logic [DATA_WIDTH-1:0] rd_data,
    output logic                  rd_empty
);

    localparam int ADDR_WIDTH = $clog2(DEPTH);
    localparam int PTR_WIDTH  = ADDR_WIDTH + 1;

    logic [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    
    logic [PTR_WIDTH-1:0] wr_ptr_bin,  wr_ptr_bin_next;
    logic [PTR_WIDTH-1:0] wr_ptr_gray, wr_ptr_gray_next;

    logic [PTR_WIDTH-1:0] rd_ptr_bin,  rd_ptr_bin_next;
    logic [PTR_WIDTH-1:0] rd_ptr_gray, rd_ptr_gray_next;

    
     logic [PTR_WIDTH-1:0] rd_gray_sync1, rd_gray_sync2;
     logic [PTR_WIDTH-1:0] wr_gray_sync1, wr_gray_sync2;

    
    logic wr_full_next;
    logic rd_empty_next;

    logic [PTR_WIDTH-1:0] rd_gray_full;

    // --------------------------------------------------
    // Calcul du prochain pointeur d'ecriture et du FULL
    // --------------------------------------------------
    always_comb begin
        wr_ptr_bin_next = wr_ptr_bin;

        if (wr_en && !wr_full)
            wr_ptr_bin_next = wr_ptr_bin + 1'b1;

        wr_ptr_gray_next =
            (wr_ptr_bin_next >> 1) ^ wr_ptr_bin_next;

        // Pour detecter FULL : inversion des deux MSB
        rd_gray_full = rd_gray_sync2;
        rd_gray_full[PTR_WIDTH-1 -: 2] =
            ~rd_gray_sync2[PTR_WIDTH-1 -: 2];

        wr_full_next = (wr_ptr_gray_next == rd_gray_full);
    end

    // Domaine d'ecriture
    always_ff @(posedge wr_clk or negedge wr_rst_n) begin
        if (!wr_rst_n) begin
            wr_ptr_bin  <= '0;
            wr_ptr_gray <= '0;
            wr_full     <= 1'b0;

            rd_gray_sync1 <= '0;
            rd_gray_sync2 <= '0;
        end else begin
            rd_gray_sync1 <= rd_ptr_gray;
            rd_gray_sync2 <= rd_gray_sync1;

            if (wr_en && !wr_full)
                mem[wr_ptr_bin[ADDR_WIDTH-1:0]] <= wr_data;

            wr_ptr_bin  <= wr_ptr_bin_next;
            wr_ptr_gray <= wr_ptr_gray_next;
            wr_full     <= wr_full_next;
        end
    end

    // --------------------------------------------------
    // Calcul du prochain pointeur de lecture et EMPTY
    // --------------------------------------------------
    always_comb begin
        rd_ptr_bin_next = rd_ptr_bin;

        if (rd_en && !rd_empty)
            rd_ptr_bin_next = rd_ptr_bin + 1'b1;

        rd_ptr_gray_next =
            (rd_ptr_bin_next >> 1) ^ rd_ptr_bin_next;

        rd_empty_next = (rd_ptr_gray_next == wr_gray_sync2);
    end

    // Domaine de lecture
    always_ff @(posedge rd_clk or negedge rd_rst_n) begin
        if (!rd_rst_n) begin
            rd_ptr_bin  <= '0;
            rd_ptr_gray <= '0;
            rd_empty    <= 1'b1;
            rd_data     <= '0;

            wr_gray_sync1 <= '0;
            wr_gray_sync2 <= '0;
        end else begin
            wr_gray_sync1 <= wr_ptr_gray;
            wr_gray_sync2 <= wr_gray_sync1;

            if (rd_en && !rd_empty)
                rd_data <= mem[rd_ptr_bin[ADDR_WIDTH-1:0]];

            rd_ptr_bin  <= rd_ptr_bin_next;
            rd_ptr_gray <= rd_ptr_gray_next;
            rd_empty    <= rd_empty_next;
        end
    end

endmodule
