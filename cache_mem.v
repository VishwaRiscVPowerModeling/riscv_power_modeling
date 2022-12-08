`define LRU 1 
module cache #(
    parameter  LINE_ADDR_LEN = 3, 
    parameter  SET_ADDR_LEN  = 3, 
    parameter  TAG_ADDR_LEN  = 7, 
    parameter  WAY_CNT       = 3  
)(
    input  clk, rst,
    output miss,               
    input  [31:0] addr,        
    input  rd_req,             
    output reg [31:0] rd_data, 
    input  wr_req,             
    input  [31:0] wr_data      );
localparam WORD_ADDR_LEN   = 2;
localparam MEM_ADDR_LEN    = TAG_ADDR_LEN + SET_ADDR_LEN ;      
localparam UNUSED_ADDR_LEN = 32 - MEM_ADDR_LEN - LINE_ADDR_LEN - WORD_ADDR_LEN; 

localparam LINE_SIZE       = 1 << LINE_ADDR_LEN  ;         
localparam SET_SIZE        = 1 << SET_ADDR_LEN   ;         

reg [              31 : 0] cache    [SET_SIZE][WAY_CNT][LINE_SIZE]; 
reg [TAG_ADDR_LEN - 1 : 0] tag      [SET_SIZE][WAY_CNT];            
reg                        valid    [SET_SIZE][WAY_CNT];            
reg                        dirty    [SET_SIZE][WAY_CNT];            

wire [  WORD_ADDR_LEN - 1 : 0]   word_addr;
wire [  LINE_ADDR_LEN - 1 : 0]   line_addr;
wire [   SET_ADDR_LEN - 1 : 0]    set_addr;
wire [   TAG_ADDR_LEN - 1 : 0]    tag_addr;
wire [UNUSED_ADDR_LEN - 1 : 0] unused_addr;
assign {unused_addr, tag_addr, set_addr, line_addr, word_addr} = addr;  

enum  {IDLE, SWAP_OUT, SWAP_IN, SWAP_IN_OK} cache_stat;    
                                                           

reg  [   SET_ADDR_LEN - 1 : 0] mem_rd_set_addr = 0;
reg  [   TAG_ADDR_LEN - 1 : 0] mem_rd_tag_addr = 0;
wire [   MEM_ADDR_LEN - 1 : 0] mem_rd_addr = {mem_rd_tag_addr, mem_rd_set_addr};
reg  [   MEM_ADDR_LEN - 1 :0 ] mem_wr_addr = 0;
reg  [31 : 0] mem_wr_line [LINE_SIZE];
wire [31 : 0] mem_rd_line [LINE_SIZE];
wire mem_rd_req = (cache_stat == SWAP_IN );
wire mem_wr_req = (cache_stat == SWAP_OUT);
wire [   MEM_ADDR_LEN - 1 : 0] mem_addr = mem_rd_req ? mem_rd_addr : ( mem_wr_req ? mem_wr_addr : 0);
wire mem_gnt;      


reg hit = 0; 
integer hit_way = -1; 
always @ (*) begin      
	for(integer way = 0; way < WAY_CNT; way++)
		if(valid[set_addr][way] && tag[set_addr][way] == tag_addr) begin 
			hit = 1'b1;
			hit_way = way;
			break; 
		end else begin
			hit = 1'b0;
			hit_way = -1;
		end
end

assign miss = (rd_req | wr_req) & ~(hit && cache_stat == IDLE) ; 


integer swap_way[SET_SIZE]; 
`ifdef LRU
integer way_age[SET_SIZE][WAY_CNT];

integer max_age_way;
integer max_age;
`endif
always @ (posedge clk or posedge rst) begin 
	if(rst) begin
		cache_stat <= IDLE;
		for(integer i = 0; i < SET_SIZE; i++) begin
			swap_way[i] <= 0;
			for(integer j = 0; j < WAY_CNT; j++) begin
				dirty[i][j] <= 1'b0;
				valid[i][j] <= 1'b0;
`ifdef LRU
				way_age[i][j] <= 0;
`endif
				end
		end
		for(integer k = 0; k < LINE_SIZE; k++)
			mem_wr_line[k] <= 0;
		mem_wr_addr <= 0;
		{mem_rd_tag_addr, mem_rd_set_addr} <= 0;
		rd_data <= 0;
`ifdef LRU
		max_age <= 0;
		max_age_way <= 0;
`endif
		end else begin
		case(cache_stat)
			IDLE: 
				begin
					if(hit) begin 
						if(rd_req) begin    
							rd_data <= cache[set_addr][hit_way][line_addr];   
						end else if(wr_req) begin 
							cache[set_addr][hit_way][line_addr] <= wr_data;   
							dirty[set_addr][hit_way] <= 1'b1;                 
						end 
`ifdef LRU
						if(rd_req | wr_req) begin
							for(integer way = 0; way < WAY_CNT; way++)
								if(way == hit_way)
									way_age[set_addr][way] <= 0;
								else
									way_age[set_addr][way] <= way_age[set_addr][way] + 1;
							
							for(integer way = 0; way < WAY_CNT; way++)
								if(way_age[set_addr][way] > max_age) begin
									max_age = way_age[set_addr][way];
									max_age_way = way;
								end
							swap_way[set_addr] <= max_age_way;
							max_age_way <= 0;
						end
`endif
					end else begin 
						if(wr_req | rd_req) begin   
							if( valid[set_addr][swap_way[set_addr]] & dirty[set_addr][swap_way[set_addr]] ) begin 
								cache_stat  <= SWAP_OUT;
								mem_wr_addr <= { tag[set_addr][swap_way[set_addr]], set_addr };
								mem_wr_line <= cache[set_addr][swap_way[set_addr]];
							end else begin          
								cache_stat  <= SWAP_IN;
							end
							{mem_rd_tag_addr, mem_rd_set_addr} <= {tag_addr, set_addr};
						end
					end
				end
			SWAP_OUT: 
				begin
					if(mem_gnt) begin           
						cache_stat <= SWAP_IN;
					end
				end
			SWAP_IN: 
				begin
					if(mem_gnt) begin           
						cache_stat <= SWAP_IN_OK;
					end
				end
			SWAP_IN_OK: 
				begin   
					for(integer i = 0; i < LINE_SIZE; i++)
						cache[mem_rd_set_addr][swap_way[mem_rd_set_addr]][i] <= mem_rd_line[i];
					tag  [mem_rd_set_addr][swap_way[mem_rd_set_addr]] <= mem_rd_tag_addr;
					valid[mem_rd_set_addr][swap_way[mem_rd_set_addr]] <= 1'b1;
					dirty[mem_rd_set_addr][swap_way[mem_rd_set_addr]] <= 1'b0;
					cache_stat                             <= IDLE;    
`ifdef LRU
					for(integer way = 0; way < WAY_CNT; way++)
						if(way == hit_way)
							way_age[mem_rd_set_addr][way] <= 0;
						else
							way_age[mem_rd_set_addr][way] <= way_age[mem_rd_set_addr][way] + 1;
					
					for(integer way = 0; way < WAY_CNT; way++)
						if(way_age[mem_rd_set_addr][way] > max_age) begin
							max_age = way_age[mem_rd_set_addr][way];
							max_age_way = way;
						end
					swap_way[mem_rd_set_addr] <= max_age_way;
					max_age_way <= 0;
`else
					if(swap_way[mem_rd_set_addr] == WAY_CNT - 1)
						swap_way[mem_rd_set_addr] <= 0;
					else
						swap_way[mem_rd_set_addr] <= swap_way[mem_rd_set_addr] + 1;
`endif
				end
		endcase
	end
end

main_mem #(     
    .LINE_ADDR_LEN  ( LINE_ADDR_LEN          ),
    .ADDR_LEN       ( MEM_ADDR_LEN           )
) main_mem_instance (
    .clk            ( clk                    ),
    .rst            ( rst                    ),
    .gnt            ( mem_gnt                ),
    .addr           ( mem_addr               ),
    .rd_req         ( mem_rd_req             ),
    .rd_line        ( mem_rd_line            ),
    .wr_req         ( mem_wr_req             ),
    .wr_line        ( mem_wr_line            )
);

endmodule

