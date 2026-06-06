\m5_TLV_version 1d: tl-x.org
\m5

\SV
   m5_makerchip_module
\TLV
   |cpu
      @0
         $reset = *reset;
         $start = $reset ? 1'b0 : (>>1$reset) ? 1'b1 : 1'b0 ;
         
         $pc[31:0] = (>>1$reset) ? 32'd0 : 
                     (>>3$taken_br) ? (>>3$br_tgt_pc): 
                     (>>1$pc + 32'd4);
      
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
         $is_sub = $dec_bits ==? 11'b1_000_0110011;
         $is_sll = $dec_bits ==? 11'b0_001_0110011;
         $is_slt = $dec_bits ==? 11'b0_010_0110011;
         $is_sltu = $dec_bits ==? 11'b0_011_0110011;
         $is_xor = $dec_bits ==? 11'b0_100_0110011;
         $is_srl = $dec_bits ==? 11'b0_101_0110011;
         $is_sra = $dec_bits ==? 11'b1_101_0110011;
         $is_or = $dec_bits ==? 11'b0_110_0110011;
         $is_and = $dec_bits ==? 11'b0_111_0110011;

         $is_beq = $dec_bits ==? 11'bx_000_1100011;
         $is_bne = $dec_bits ==? 11'bx_001_1100011;
         $is_blt = $dec_bits ==? 11'bx_100_1100011;
         $is_bge = $dec_bits ==? 11'bx_101_1100011;
         $is_bltu = $dec_bits ==? 11'bx_110_1100011;
         $is_bgeu = $dec_bits ==? 11'bx_111_1100011;
         
         $is_lui = $dec_bits ==? 11'bx_xxx_0110111;
         $is_auipc = $dec_bits ==? 11'bx_xxx_0010111;
         
         $is_jal = $dec_bits ==? 11'bx_xxx_1101111;
         $is_jalr = $dec_bits ==? 11'bx_xxx_1100111;
         
         $is_load = $opcode ==? 7'b0000011; 
         
         $is_sb = $dec_bits ==? 11'bx_000_0100011;
         $is_sh = $dec_bits ==? 11'bx_001_0100011;
         $is_sw = $dec_bits ==? 11'bx_010_0100011;
         
         $is_slti = $dec_bits ==? 11'bx_010_0010011;
         $is_sltiu = $dec_bits ==? 11'bx_011_0010011; 
         
         $is_addi = $dec_bits ==? 11'bx_000_0010011;
         $is_xori = $dec_bits ==? 11'bx_100_0010011;
         $is_ori = $dec_bits ==? 11'bx_110_0010011;
         $is_andi = $dec_bits ==? 11'bx_111_0010011;
         $is_slli = $dec_bits ==? 11'b0_001_0010011;
         $is_srli = $dec_bits ==? 11'b0_101_0010011;
         $is_srai = $dec_bits ==? 11'b1_101_0010011;

      @2
         $rf_rd_en1 = $rs1_valid; 
         $rf_rd_index1[4:0] = $rs1; 
         $rf_rd_en2 = $rs2_valid; 
         $rf_rd_index2[4:0] = $rs2; 

         $select1 = >>2$rf_wr_en && (>>1$rd == $rs1); 
         $select2 = >>2$rf_wr_en && (>>1$rd == $rs2);
         $src1_value[31:0] = $select1 ? (>>1$result) : $rf_rd_data1; 
         $src2_value[31:0] = $select2 ? (>>1$result) : $rf_rd_data2; 
         
         $br_tgt_pc[31:0] = $pc + $imm ; 

      @3
         $sltu_res[31:0] = $src1_value < $src2_value ;
         $sltiu_res[31:0] = $src1_value < $imm ; 
         $srai_res[31:0] = { {32{$src1_value[31]}}, $src1_value } >> $imm[4:0]; 
         $sra_res[31:0] = { {32{$src1_value[31]}}, $src1_value } >> $src2_value[4:0]; 
         $slt_res[31:0] = ($src1_value[31] == $src2_value[31]) ? $sltu_res : {31'b0, $src1_value[31]};
         $slti_res[31:0] = ($src1_value[31] == $imm[31]) ? $sltiu_res : {31'b0, $src1_value[31]};
         
         $result[31:0] = $is_addi ? ($src1_value + $imm) : 
                         $is_add ? ($src1_value + $src2_value) : 
                         $is_andi ? ($src1_value & $imm) :
                         $is_ori ? ($src1_value | $imm) :
                         $is_xori ? ($src1_value ^ $imm) :
                         $is_slli ? ($src1_value << $imm[5:0]) : 
                         $is_srli ? ($src1_value >> $imm[5:0]) :
                         $is_and ? ($src1_value & $src2_value) :
                         $is_or ? ($src1_value | $src2_value) :
                         $is_xor ? ($src1_value ^ $src2_value) :
                         $is_sub ? ($src1_value - $src2_value) :
                         $is_sll ? ($src1_value << $src2_value[4:0]) :
                         $is_srl ? ($src1_value >> $src2_value[4:0]) :
                         $is_sltu ? $sltu_res :
                         $is_sltiu ? $sltiu_res :
                         $is_lui ? {$imm[31:12], 12'b0} :
                         $is_auipc ? ($pc + $imm) :
                         ($is_jal || $is_jalr) ? ($pc + 32'd4) :
                         $is_srai ? $srai_res :
                         $is_sra ? $sra_res :
                         $is_slt ? $slt_res :
                         $is_slti ? $slti_res :
                         32'bx ; 
         
         $valid =  ! (>>1$taken_br || >>2$taken_br);

         $rf_wr_en = ($rd == 5'd0 || (! $valid)) ? 1'b0 : $rd_valid;  
         $rf_wr_index[4:0] = $rd; 
         
         $rf_wr_data[31:0] = $rf_wr_en ? ($result) : 32'd0; 
         
         $taken_br = (! $is_b_instr) ? 1'b0 :
                     $is_beq ? ($src1_value == $src2_value) :
                     $is_bne ? ($src1_value != $src2_value) :
                     $is_blt ? ( ($src1_value < $src2_value) ^ ($src1_value[31] != $src2_value[31]) ) : 
                     $is_bge ? ( ($src1_value >= $src2_value) ^ ($src1_value[31] != $src2_value[31]) ) : 
                     $is_bltu ? ($src1_value < $src2_value) : 
                     $is_bgeu ? ($src1_value >= $src2_value) : 
                     1'b0 ; 

   *passed = |cpu/xreg[10]>>5$value == (1+2+3+4+5+6+7+8+9) ; 
   *failed = 1'b0;
\SV
   endmodule
