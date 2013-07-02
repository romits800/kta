

open Ustring.Op
open Utest
open LlvmAst
open LlvmDecode
open LlvmUtils
open LlvmPPrint
open Printf

(* Help function for printing function results *)
let pprint_res r = 
  match r with 
  | None -> us"None"
  | Some(v) -> pprint_const v 

(* Ignore timing in these tests *)
let btime b1 b2 = 1 

(* Function for testing integer functions *)
let test_llvm_int_res name res expint =
  let r = match res with 
    | Some(CInt(w,v)) -> Int64.compare v (Int64.of_int expint) = 0
    | _ -> false
  in
    test name r 



let main = 
  init "Test llvm decode and pretty print";

  let ast = LlvmDecode.bcfile2ast "unittest/testcode/integerloops.bc" in
  uprint_endline (LlvmPPrint.pprint_module ast);  

  (* Test looptest1 *)
(*  let fname = "looptest1" in
  let args = [const32 10] in
  let (t,res) = LlvmEval.eval_fun ast btime (usid fname) args (-1) in
  test_llvm_int_res "Function looptest2()" res 7257600;
*)

  (* Test looptest2 *)
  let fname = "looptest2" in
  let args = [const32 10] in
  let (t,res) = LlvmEval.eval_fun ast btime (usid fname) args (-1) in
  test_llvm_int_res "Function looptest2()" res 7257600;


  result()

