\m5_TLV_version 1d: tl-x.org
\m5

\SV
   m5_makerchip_module
\TLV
   |cpu
      @0
         $reset = *reset;
         
         $pc[31:0] = (>>1$reset) ? 32'd0 : (>>1$pc + 32'd4);
         
      @1
         $imem_rd_en = ! $reset;
         
         $imem_rd_addr[7:0] = $pc / 4 ; 
         
         $instr[31:0] = $imem_rd_data[31:0]; 
         
         $is_i_instr = $instr[6:2] ==? 5'b0000x || 
                       $instr[6:2] ==? 5'b001x0 || 
                       $instr[6:2] ==? 5'b11001 ||
                       $instr[6:2] ==? 5'b00100 ; 
         
         $is_r_instr = $instr[6:2] ==? 5'b01011 ||
                       $instr[6:2] ==? 5'b011x0 || 
                       $instr[6:2] ==? 5'b10100 ;
         
         $is_s_instr = $instr[6:2] ==? 5'b0100x ; 
         
         $is_b_instr = $instr[6:2] ==? 5'b11000 ;
         
         $is_j_instr = $instr[6:2] ==? 5'b11011 ;
         
         $is_u_instr = $instr[6:2] ==? 5'b0x101 ; 
         
         $imm_valid = $is_r_instr ? 1'b0 : 1'b1 ; 
         ?$imm_valid
            $imm[31:0] = $is_i_instr ? { {21{$instr[31]}}, $instr[30:20] } : 
                         $is_s_instr ? { {21{$instr[31]}}, $instr[30:25], $instr[11:7] } : 
                         $is_b_instr ? { {20{$instr[31]}}, $instr[7], $instr[31:25], $instr[11:8], 1'b0 } : 
                         $is_u_instr ? { $instr[31:12] , 12'b0 } : 
                         $is_j_instr ? { {12{$instr[31]}}, $instr[19:12], $instr[20], $instr[30:21], 1'b0 } : 
                                       32'b0 ; 
         
         $funct7_valid = $is_r_instr ? 1'b1 : 1'b0 ; 
         ?$funct7_valid
            $funct7[6:0] = $instr[31:25]; 
         
         $u_or_j = $is_u_instr || $is_j_instr ; 
         
         $funct3_valid = $u_or_j ? 1'b0 : 1'b1 ;
         ?$funct3_valid
            $funct3[2:0] = $instr[14:12];
         
         $rs1_valid = $u_or_j ? 1'b0 : 1'b1 ;
         ?$rs1_valid
            $rs1[4:0] = $instr[19:15]; 
         
         $rs2_valid = ($u_or_j || $is_i_instr) ? 1'b0 : 1'b1; 
         ?$rs2_valid
            $rs2[4:0] = $instr[24:20]; 
         
         $rd_valid = ($is_s_instr || $is_b_instr) ? 1'b0 : 1'b1; 
         ?$rd_valid
            $rd[4:0] = $instr[11:7]; 
         
         $opcode[6:0] = $instr[6:0]; 
         
         $dec_bits[10:0] = { $funct7[5], $funct3, $opcode }; 
         
         $is_add = $dec_bits == 11'b0_000_0110011;
         $is_addi = $dec_bits ==? 11'bx_000_0010011; 
         
         $is_beq = $dec_bits ==? 11'bx_000_1100011;
         $is_bne = $dec_bits ==? 11'bx_001_1100011;
         $is_blt = $dec_bits ==? 11'bx_100_1100011;
         $is_bge = $dec_bits ==? 11'bx_101_1100011;
         $is_bltu = $dec_bits ==? 11'bx_110_1100011;
         $is_bgeu = $dec_bits ==? 11'bx_111_1100011;
         *passed = *cyc_cnt > 40;
   *failed = 1'b0;
\SV
   endmodule
