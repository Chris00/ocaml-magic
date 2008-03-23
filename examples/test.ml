#directory "../src";;
#load "magic.cma";;

open Printf;;

printf "\n**********OCaml script starts*************************\n%!";;
let c = Magic.create ["/usr/share/file/magic"];;

let m1 = Magic.file c "../src/dllmagic_stubs.so";;
let m2 = Magic.file c "file.ml";;
let m3 = Magic.file c "/dev/null";;
let m4 = Magic.file c "xxx";;

Magic.load c ["/etc/magic"];;

Magic.close c;;
