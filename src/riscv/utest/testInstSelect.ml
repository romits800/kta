

open Ustring.Op
open Utest
open LlvmAst


let main = 

  init "Test RISC-V instruction selection.";
  
  (* Extracted test functions *)
  let integerloops_ast = LlvmDecode.bcfile2ast "ccode/integerloops.bc" in
  let f_looptest2 = LlvmUtils.get_fun integerloops_ast (usid "looptest2") in
  
  (* Test maximal munch on one block *)
  let LLFunc(_,_,blocks) = f_looptest2 in
  let LLBlock(_,insts) = List.assoc (usid "for.body") blocks in
  let forest = LlvmTree.make insts (LlvmUtils.used_in_another_block f_looptest2) in 
  let insts = RiscvInstSelect.maximal_munch forest in
  let res = RiscvPPrint.sinst_list insts in
  let exp = us"mul     %mul,%i.06,%j.05\n" ^.
            us"add     %add,%mul,%j.05\n" ^.
            us"addi    %inc,%i.06,1\n" ^.
            us"beq     %inc,%k,for.end\n" ^.
            us"j       for.body\n" in
  test_ustr "Selecting mul,add,addi,beq,j" res exp;

  (* uprint_endline (LlvmPPrint.pp_forest forest); print_endline "--------------";
  uprint_endline res; *)
   

  result()


