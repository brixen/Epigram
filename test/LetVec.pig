make ship : (X : Set)(x : X)(y : X)(q : :- x == y)(P : X -> Set) -> P x -> P y ;
lambda X, x, y, q, P, px ;
give coe (P x) (P y) ?q px ;
give con (refl (X -> Set) P % x y _) ;
root ;


data Nat := (zero : Nat) ; (suc : Nat -> Nat) ;
make zero := 'zero : Nat ;
make suc := (\ x -> 'suc x) : Nat -> Nat ;

let plus (m : Nat)(n : Nat) : Nat ;
<= Nat.Ind m ;
= n ;
= 'suc (plus xf^1 n) ;
root ;


module Vec ;
lambda A : Set ;

make VecD : Nat -> IDesc Nat ;
give (\ n -> IFSigma ['nil 'cons] [ (IConst (:- (zero == n))) (ISigma Nat (\
m -> IProd (IConst A) (IProd (IVar m) (IConst (:- (suc m == n)))))) ]) ;

make Vec : Nat -> Set ;
lambda n ;
give IMu Nat VecD n ;

make nil := con ['nil , _ ] : Vec 'zero ;
make cons := (\ n a as -> con ['cons n a as , _ ]) : (n : Nat) -> A -> Vec n -> Vec ('suc n) ;

make VecInd := iinduction Nat VecD : (m : Nat)(v : Vec m)
    (bp : Sig (n : Nat ; Vec n) -> Set)
    (me : (k : Nat)(x : idesc Nat (VecD k) Vec)
        (hs : idesc (Sig (i : Nat ; Vec i))
	    (ibox Nat (VecD k) Vec x) bp)
	-> bp [k , con x])
    -> bp [m , v] ;

let vappend (m : Nat)(as : Vec m)(n : Nat)(bs : Vec n) : Vec (plus m n) ;
<= VecInd m as ;

<= ship Nat 'zero k x ;
= bs ;

<= ship Nat ('suc s^4) k x ;
= cons (plus s^4 n) xf^2 (vappend s^4 xf^1 n bs) ;

root ;

make A := Enum ['a 'b 'c] : Set ;

make vab := Vec.cons A (suc zero) 'a (Vec.cons A zero 'b (Vec.nil A)) : Vec.Vec A (suc (suc zero)) ;
elab vab ;

make v := Vec.vappend A 'zero (Vec.nil A) 'zero (Vec.nil A) : Vec.Vec A 'zero ;
elab v % ! ;