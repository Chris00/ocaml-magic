(* File: magic.ml

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
(* 	$Id: magic.ml,v 1.1 2005/01/24 17:28:38 chris_77 Exp $	 *)



exception Failure of string

let () = Callback.register_exception "Magic.Failure" (Failure "message")

type t (* hold magic_t *)

type flag =
  | Symlink
  | Compress
  | Devices
  | Mime
  | Continue
  | Check    (* => flush stderr for all funs.  FIXME *)
  | Preserve_atime
  | Raw

(* Keep in sync with magic.h *)
let int_of_flag = function
  | Symlink	-> 0x002
  | Compress	-> 0x004
  | Devices	-> 0x008
  | Mime	-> 0x010
  | Continue	-> 0x020
  | Check	-> 0x040
  | Preserve_atime -> 0x080
  | Raw		-> 0x100

let int_of_flags flags =
  List.fold_left (fun fs f -> fs lor (int_of_flag f)) 0x000 flags


external magic_open : int -> t = "magic_open_stub"
external close : t -> unit = "magic_close_stub"
external file : t -> string -> string = "magic_file_stub"
external buffer : t -> string -> string = "magic_buffer_stub"

external magic_setflags : t -> int -> unit = "magic_setflags_stub"
external magic_check_default : t -> bool = "magic_check_default_stub"
external magic_check : t -> string -> bool = "magic_check_stub"
external magic_compile_default : t -> unit = "magic_compile_default_stub"
external magic_compile : t -> string -> unit = "magic_compile_stub"
external magic_load_default : t -> unit = "magic_load_default_stub"
external magic_load : t -> string -> unit = "magic_load_stub"

let load cookie = function
  | [] -> magic_load_default cookie
  | filenames -> magic_load cookie (String.concat ":" filenames)

let compile cookie = function
  | [] -> magic_compile_default cookie
  | filenames -> magic_compile cookie (String.concat ":" filenames)

let check cookie = function
  | [] -> magic_check_default cookie
  | filenames -> magic_check cookie (String.concat ":" filenames)


let create ?(flags=[]) filenames =
  let cookie = magic_open(int_of_flags flags) in
  load cookie filenames;
  cookie

let setflags cookie flags =
  magic_setflags cookie (int_of_flags flags)
