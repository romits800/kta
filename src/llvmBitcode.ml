

open Printf
open Ustring.Op


(*************** Exported types and exceptions ********************)

exception Bitcode_error of string


(*************** Local types and exceptions ***********************)


type strpos = int       (* Position in the binary string *)
type decoded = int      (* Decoded but not used bits *)
type decoded_bits = int (* Number of decoded bits *)
type bitstream = BS of string * strpos * decoded * decoded_bits 


(*************** Local functions **********************************)

let intsize = Sys.word_size - 1

(* Functions raising various of decoding errors. *)
let error_header() = raise (Bitcode_error "Illegal LLVM bitcode header.")
let error_align() = raise (Bitcode_error "Illegal alignment in the LLVM bitcode data.")
let error_size() = raise (Bitcode_error "Illegal size of LLVM bitcode data.")
let error_version v = raise (Bitcode_error (sprintf "LLVM Bitcode version %d is not supported." v))
let error_intsize() = raise (Bitcode_error 
         (sprintf "The machine's word size of %d bits is not large enough." Sys.word_size))
                                                   
(* Return an integer with [n] bits set *)
let ones n = (1 lsl n) - 1 

(* Get an int value out of a string array *)
let s2int s i = int_of_char (s.[i])

(* Returns the current bit position in the stream *)
let bit_pos (BS(_,p,_,b)) = p * 8 - b 

(* Check that [size] number of bytes are possible to decode *) 
let check_byte_size s p size =  
  if p + size <= String.length s then () else error_size()

(* Check that the stream is byte aligned *)
let check_alignment b =  
  if b != 0 then error_align() else ()

(* Decode [n] number of bytes that are assumed to be byte aligned. *)
let dBytes bs n =
  let BS(s,p,d,b) = bs in
  check_alignment b;
  check_byte_size s p n;
  (String.sub s p n, BS(s,p+n,0,0))
  
(* Decode a 32-bits word in little-endian format*)
let dWord32 bs =
  let BS(s,p,d,b) = bs in
  check_alignment b;
  check_byte_size s p 4;
  let v = (s2int s p) lor ((s2int s (p+1)) lsl 8) lor 
          ((s2int s (p+2)) lsl 16) lor  ((s2int s (p+3)) lsl 24) in
  (v, BS(s,p+4,0,0))

(* Decode a Fixed width Integer of bit size [n] from a bit stream [bs].
   Returns a tuple (v,bs'), where [v] is the decoded integer value
   and [bs'] the updated bit stream. *)
let dFI bs n = 
  let BS(s,p,d,b) = bs in
  let rec decode p d b =
    if b > intsize then error_intsize() 
    else if b >= n then 
      let v =  d land (ones n) in
      (v, BS(s,p,d lsr n, b-n))
    else(
      check_byte_size s p 1;
      let d' = ((s2int s p) lsl b) lor d in
      decode (p + 1) d' (b+8))
  in decode p d b

(* Decode Variable width Integers (VBR), according to LLVM Bitcode spec. 
   Decode from bit stream [bs] using [n] bits chucks. The function 
   returns a tuple (v,bs'), where [v] is the decoded integer value
   and [bs'] the updated bit stream.  *)
let dVBR bs n =
  let checkbit = 1 lsl (n-1) in
  let maskbits = ones (n-1) in
  let rec decLoop bs acc b =
    if b > intsize then error_intsize() else    
    let (v,bs) = dFI bs n in
    let acc = ((v land maskbits) lsl b) lor acc in
    if (checkbit land v) != 0 then 
      decLoop bs acc (b+n-1)
    else 
      (acc,bs)    
  in decLoop bs 0 0
      


      
(** Decodes the bitcode header (if present) as well as the
    bitstream magic number. All data is checked for consistency *)
let decode_header bitstr =
  let decode_ir_magic bs = 
    let (str, bs) = dBytes bs 4 in
    if str = "\x42\x43\xc0\xde" then bs else error_header()
  in
  let (b0, bs) = dBytes bitstr 1 in 
  if b0 = "\xde" then (* Includes header *)
    let (b1, bs) = dBytes bs 3 in
    if b1 <> "\xc0\x17\x0b" then error_header() else
    let (version,bs) = dWord32 bs in
    if version != 0 then error_version version else
    let (offset,bs) = dWord32 bs in
    let (size,bs) = dWord32 bs in
    let (cputype,bs) = dWord32 bs in
    if bit_pos bs != offset * 8 then error_header() else
    let BS(s,_,_,_) = bs in                                      (* TEMP *)
    printf "Header: offset=%d, size_info=%d, string_size=%d\n"   (* TEMP *)
        offset size (String.length s);                           (* TEMP *)
    decode_ir_magic bs
  else 
    decode_ir_magic bitstr (* No header included *)
    


(**************** Exported functions *******************************)


let decode data =
  let bs = BS(data,0,0,0) in
  let bs = decode_header bs in
  let BS(s,p,d,b) = bs in
  printf "String length length=%d, end_pos=%d (%x)\n" (String.length data) p p;
  let (v1,bs) = dVBR bs 2 in
  let (v2,bs) = dVBR bs 8 in
  let (v3,bs) = dFI bs 4 in
  let (v4,bs) = dFI bs 18 in
  let (v5,bs) = dFI bs 8 in
  printf "Decoded %d,%d,%d,%d,%d\n" v1 v2 v3 v4 v5








