// ========================================================
// ----------------------- Cache --------------------------
// ========================================================
// = Este módulo contiene la definición para una memoria  =
// = cache de 256kB, 8-way set associative. Se implementa =
// = en el sisteme RVfpgaNexys                            =
// ========================================================
// Para pasar las señales de la entrada a la salida de la
// cache, debemos duplicar los puertos, para no afectar la
// integridad del bus AXI(cpu.) que se genera para el CDC.
// La cache maneja datos de 64 bits y direcciones de 32.
// ========================================================
module cache_64 (
    input wire clk,
    input wire rst,
    // CPU signals(Orignales):
    // AW
    input reg  [5:0]  icpu_aw_id,
    input reg  [31:0] icpu_aw_addr,
    input reg  [7:0]  icpu_aw_len,
    input reg  [2:0]  icpu_aw_size,
    input reg  [1:0]  icpu_aw_burst,
    input wire         icpu_aw_lock,
    input reg  [3:0]  icpu_aw_cache,
    input reg  [2:0]  icpu_aw_prot,
    input reg  [3:0]  icpu_aw_region,
    input reg  [3:0]  icpu_aw_qos,
    input wire         icpu_aw_valid,
    output wire        ocpu_aw_ready,
    // AR
    input reg  [5:0]  icpu_ar_id,
    input reg  [31:0] icpu_ar_addr,
    input reg  [7:0]  icpu_ar_len,
    input reg  [2:0]  icpu_ar_size,
    input reg  [1:0]  icpu_ar_burst,
    input wire         icpu_ar_lock,
    input reg  [3:0]  icpu_ar_cache,
    input reg  [2:0]  icpu_ar_prot,
    input reg  [3:0]  icpu_ar_region,
    input reg  [3:0]  icpu_ar_qos,
    input wire         icpu_ar_valid,
    output wire        ocpu_ar_ready,
    // W
    input reg  [63:0] icpu_w_data,
    input reg  [7:0]  icpu_w_strb,
    input wire         icpu_w_last,
    input wire         icpu_w_valid,
    output wire        ocpu_w_ready,
    // B
    output reg [5:0]  ocpu_b_id,
    output reg [1:0]  ocpu_b_resp,
    output wire        ocpu_b_valid,
    input wire         icpu_b_ready,
    // R
    output reg [5:0]  ocpu_r_id,
    output reg [63:0] ocpu_r_data,
    output reg [1:0]  ocpu_r_resp,
    output wire        ocpu_r_last,
    output wire        ocpu_r_valid,
    input  wire        icpu_r_ready,
    // --------------------------------
    // CPU signal (modificadas):
    output reg [5:0]  o_aw_id,
    output reg [31:0] o_aw_addr,
    output reg [7:0]  o_aw_len,
    output reg [2:0]  o_aw_size,
    output reg [1:0]  o_aw_burst,
    output wire        o_aw_lock,
    output reg [3:0]  o_aw_cache,
    output reg [2:0]  o_aw_prot,
    output reg [3:0]  o_aw_region,
    output reg [3:0]  o_aw_qos,
    output wire        o_aw_valid,
    input  wire        i_aw_ready,
    // AR
    output reg [5:0]  o_ar_id,
    output reg [31:0] o_ar_addr,
    output reg [7:0]  o_ar_len,
    output reg [2:0]  o_ar_size,
    output reg [1:0]  o_ar_burst,
    output wire        o_ar_lock,
    output reg [3:0]  o_ar_cache,
    output reg [2:0]  o_ar_prot,
    output reg [3:0]  o_ar_region,
    output reg [3:0]  o_ar_qos,
    output wire        o_ar_valid,
    input  wire        i_ar_ready,
    // W
    output reg [63:0] o_w_data,
    output reg [7:0]  o_w_strb,
    output wire        o_w_last,
    output wire        o_w_valid,
    input  wire         i_w_ready,
    // B
    input reg [5:0]   i_b_id,
    input reg [1:0]   i_b_resp,
    input wire         i_b_valid,
    output wire        o_b_ready,
    // R
    input reg [5:0]   i_r_id,
    input reg [63:0]  i_r_data,
    input reg [1:0]   i_r_resp,
    input wire         i_r_last,
    input wire         i_r_valid,
    output wire        o_r_ready
);
 // -----------------------------------
 // Modulo transparente:
 assign o_aw_id     = icpu_aw_id;       
 assign o_aw_addr   = icpu_aw_addr;
 assign o_aw_len    = icpu_aw_len;
 assign o_aw_size   = icpu_aw_size;
 assign o_aw_burst  = icpu_aw_burst;
 assign o_aw_lock   = icpu_aw_lock;
 assign o_aw_cache  = icpu_aw_cache;
 assign o_aw_prot   = icpu_aw_prot;
 assign o_aw_region = icpu_aw_region;
 assign o_aw_qos    = icpu_aw_qos;
 assign o_aw_valid  = icpu_aw_valid;
 assign ocpu_aw_ready = i_aw_ready ;

 assign o_ar_id     = icpu_ar_id;
 assign o_ar_addr   = icpu_ar_addr;
 assign o_ar_len    = icpu_ar_len;
 assign o_ar_size   = icpu_ar_size;
 assign o_ar_burst  = icpu_ar_burst;
 assign o_ar_lock   = icpu_ar_lock;
 assign o_ar_cache  = icpu_ar_cache;
 assign o_ar_prot   = icpu_ar_prot;
 assign o_ar_region = icpu_ar_region;
 assign o_ar_qos    = icpu_ar_qos;
 assign o_ar_valid  = icpu_ar_valid;
 assign ocpu_ar_ready = i_ar_ready ;
 
 assign o_w_data  = icpu_w_data;
 assign o_w_strb  = icpu_w_strb;
 assign o_w_last  = icpu_w_last;
 assign o_w_valid = icpu_w_valid;
 assign ocpu_w_ready = i_w_ready;

 assign ocpu_b_id    = i_b_id;
 assign ocpu_b_resp  = i_b_resp;
 assign ocpu_b_valid = i_b_valid;
 assign o_b_ready    = icpu_b_ready;

 assign ocpu_r_id   = i_r_id ;
 //assign ocpu_r_data = i_r_data ;        // modificar.
 assign ocpu_r_resp = i_r_resp;
 assign ocpu_r_last = i_r_last;
 assign ocpu_r_valid = i_r_valid;
 assign o_r_ready = icpu_r_ready;
 // -----------------------------------
 //reg []
 // ----- Parámetros de la cache: -----
 parameter CACHE_SIZE    = 64 * 1024; // 64kB
 parameter BLOCK_SIZE    = 16;        // bytes
 parameter ASSOCIATIVITY = 4;
 
 localparam OFFSET_BITS = $clog2(BLOCK_SIZE);
 localparam INDEX_BITS  = $clog2(CACHE_SIZE / (BLOCK_SIZE * ASSOCIATIVITY));
 localparam TAG_BITS    = 32 - INDEX_BITS - OFFSET_BITS;
 
 // Matriz bidimensional principla de la cache, para almacenar datos de 64 bits:
 reg [63:0] cache [0:((CACHE_SIZE/BLOCK_SIZE)/ASSOCIATIVITY)-1][ASSOCIATIVITY-1];

 // Resgistro de Tags para direcciones en cache:
 reg [TAG_BITS-1:0] tags [0:((CACHE_SIZE/BLOCK_SIZE)/ASSOCIATIVITY)-1][ASSOCIATIVITY-1];
 
 // Validación de datos:
 reg valid_bit [0:((CACHE_SIZE/BLOCK_SIZE)/ASSOCIATIVITY)-1][ASSOCIATIVITY-1];

 // Control de datos:
 reg HIT;
 reg [31:0] ADDRESS;
 reg [63:0] DATA;

 reg [TAG_BITS-1:0] tag;
 reg [INDEX_BITS-1:0] index;
 reg [ASSOCIATIVITY-1:0] WAY;
 // ------------------------------
 // ----- Sistema del cache: -----
 reg [4:0] state, next_state, r_state, r_next_state;

 always @(posedge clk) begin
    if (rst) begin
        // Reiniciar los parametros de la cache:
        HIT = 0;
        ocpu_r_data <= i_r_data;

        next_state   <= 5'b0;
        r_next_state <= 5'b0;
    end

    else begin
        //case (state)
            
            //if (conditions) begin
                // ===== Escritura: =====
            
            //end
        //endcase

        case (r_state)
            0: begin// IDLE:
            ocpu_r_data <= i_r_data;

            if (icpu_ar_valid && i_ar_ready) begin
                // ===== Lectura: =====
                // El cpu queire leer y la memoria está lista:
                ADDRESS <= icpu_ar_addr;
                r_next_state <= 5'b00010;
            end
            end

            2: begin  // Extraer Set, Tag y Data:
            tag   = ADDRESS[31:OFFSET_BITS+INDEX_BITS];
            index = ADDRESS[OFFSET_BITS+INDEX_BITS-1:OFFSET_BITS];

            r_next_state <= 5'b00100;
            end

            4: begin // Buscar dato en la cache:
            HIT = 0;
            WAY = 0;

            // Recorrer ways, verificar valid y addres:
            for (WAY = 0; WAY < ASSOCIATIVITY; WAY+= 1 ) begin
                if (valid_bit[index][WAY] && ((tags[index][WAY] == tag))) begin
                    HIT = 1;
                    DATA = cache[index][WAY];

                    r_next_state <= 5'b01000; // Escirbir de la cache.
                end
            end
            if (!HIT) begin
                r_next_state <= 5'b01100;
            end
            end

            8: begin // Traer datos de cache:
            ocpu_r_data <= DATA;

            r_next_state <= 4'b0;
            end

            12: begin // Traer dato de memoria:
            if (icpu_r_ready && i_r_valid) begin
                ocpu_r_data <= i_r_data;

                r_next_state <= 4'b0;
            end
            end
        endcase
    end
 end
 
 always @(~clk) begin
    state   <= next_state;
    r_state <= r_next_state;
 end
endmodule