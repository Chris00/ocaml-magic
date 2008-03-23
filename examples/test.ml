#directory "/home/trch/Software/OCaml/ocaml-magic";;
#load "magic.cma";;

open Printf;;

printf "\n**********OCaml script starts*************************\n%!";;
let c = Magic.create ["/usr/share/file/magic"];;

let m1 = Magic.file c "dllmagic_stub.so";;
let m2 = Magic.file c "file.com";;
let m3 = Magic.file c "/dev/null";;
let m4 = Magic.file c "xxx";;

Magic.load c ["/etc/magic"];;

Magic.close c;;
