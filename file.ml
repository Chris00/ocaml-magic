(* File: file.ml

   Copyright (C) 2005

     Christophe Troestler
     email: Christophe.Troestler@umh.ac.be
     WWW: http://www.umh.ac.be/math/an/software/

   This library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public License
   version 2.1 as published by the Free Software Foundation, with the
   special exception on linking described in file LICENSE.

   This library is distributed in the hope that it will be useful, but
   WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the file
   LICENSE for more details.
*)
(* 	$Id: file.ml,v 1.1.1.1 2005/01/24 17:28:38 chris_77 Exp $	 *)

(** "file" program using OCaml libmagic bindings. *)

let () =
  if Array.length Sys.argv < 2 then begin
    let pgm = Filename.basename(Sys.executable_name) in
    print_endline(pgm ^ " <file>");
    exit 0;
  end;
  let c = Magic.create [] in
  try
    let fname = Sys.argv.(1) in
    print_endline(fname ^ ": " ^ Magic.file c fname)
  with Magic.Failure m ->
    print_endline("Error: " ^ m)
