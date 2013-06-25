

open Ustring.Op
open LlvmAst

val pprint_type : llType -> ustring
(** Pretty print llvm type *)

val pprint_const : llConst -> ustring
(** Pretty print constant *)

val pprint_val : llVal -> ustring
(** Pretty print value *)

val pprint_binop : llBinOp -> ustring
(** Pretty print binary operator *)

val pprint_icmp_pred_op : llIcmpPred -> ustring
(** Pretty printing icmp predicate operator *)

val pprint_module : llModule -> ustring
(** Pretty print a module *)
