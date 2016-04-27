


open Printf
open Aint32relint

let debug = false

(* Exhaustive test of all combinations. Check soundsness. *)  
let test_relation relation str testfun  low high =  
  let rec work l1 h1 l2 h2 = (
    let testpoints truecase falsecase =
      for x = l1 to h1 do
        for y = l2 to h2 do
          if relation x y then
            if not (truecase x y) then 
              failwith (sprintf "%s: True case [%d,%d] [%d,%d] point %d %d failed.\n"
                          str l1 h1 l2 h2 x y)
            else
              if debug then printf "TRUE  x:%d y:%d OK.\n" x y else ()
          else
            if not (falsecase x y) then 
              failwith (sprintf "%s: False case [%d,%d] [%d,%d] point %d %d failed.\n"
                          str l1 h1 l2 h2 x y)
            else
              if debug then printf "FALSE x:%d y:%d OK.\n" x y else ()
        done
      done
    in

    let check lst1 lst2 x y =
      (List.exists (fun (rl1,rh1) -> x >= rl1 && x <= rh1) lst1) &&
      (List.exists (fun (rl2,rh2) -> y >= rl2 && y <= rh2) lst2)
    in
    
    let (tcase,fcase) = testfun (Interval(l1,h1)) (Interval(l2,h2)) in
    (match tcase with
     | Some(Interval (rl1,rh1),Interval (rl2,rh2)) ->                    
       if debug then printf "True case1: [%d,%d] [%d,%d]\n" rl1 rh1 rl2 rh2;
       testpoints (check [(rl1,rh1)] [(rl2,rh2)]) (fun x y -> true)
     | Some(IntervalList(lst1,_),IntervalList(lst2,_)) ->                    
       if debug then printf "True case2: \n";
       testpoints (check lst1 lst2) (fun x y -> true)
     | None ->
       if debug then printf "True case3: NONE\n";
       testpoints (fun x y -> false) (fun x y -> true)
     | _ -> failwith "Should not happen."
     );
    (match fcase with
     | Some(Interval(rl1,rh1),Interval(rl2,rh2)) ->
       if debug then printf "False case1: [%d,%d] [%d,%d]\n" rl1 rh1 rl2 rh2;
       testpoints (fun x y -> true) (check [(rl1,rh1)] [(rl2,rh2)])
     | Some(IntervalList(lst1,_),IntervalList(lst2,_)) ->
       if debug then printf "False case2:\n";
       testpoints (fun x y -> true) (check lst1 lst2)
     | None ->
       if debug then printf "False case3: NONE\n";
       testpoints (fun x y -> true) (fun x y -> false)
     | _ -> failwith "Should not happen."
    );)
  in
  for h1 = low to high do
    for l1 = low to h1 do
      for h2 = low to high do
        for l2 = low to h2 do
          work l1 h1 l2 h2
        done
      done
    done
  done 
       

let low = -10 
let high = 10

let main =    
  test_relation (<) "less_than" aint32_test_less_than low high;
  test_relation (<=) "less_than_equal" aint32_test_less_than_equal low high;
  test_relation (=) "equal" aint32_test_equal low high







