\section{UId}

%if False

> {-# OPTIONS_GHC -F -pgmF she #-}

> module Features.UId where

%endif


> import -> CanConstructors where
>   UId    :: Can t
>   Tag    :: String -> Can t

> import -> CanPats where
>   pattern UID    = C UId
>   pattern TAG s  = C (Tag s)

> import -> CanDisplayPats where
>   pattern DUID    = DC UId
>   pattern DTAG s  = DC (Tag s)

> import -> CanTraverse where
>   traverse f UId          = (|UId|)
>   traverse f (Tag s)      = (|(Tag s)|)

> import -> CanPretty where
>   pretty UId      = const (kword KwUId)
>   pretty (Tag s)  = const (kword KwTag <> text s)

> import -> CanTyRules where
>   canTy _  (Set :>: UId)    = return UId
>   canTy _  (UId :>: Tag s)  = return (Tag s)

> import -> CanHalfZip where
>   halfZip UId UId = Just UId
>   halfZip (Tag s) (Tag s') | s == s' = Just (Tag s)

> import -> OpRunEqGreen where
>   opRunEqGreen [UID,TAG s1,UID,TAG s2] | s1 == s2 = Right $ TRIVIAL
>   opRunEqGreen [UID,TAG _,UID,TAG _] = Right $ ABSURD

> import -> Coerce where
>   coerce UId _ u = Right u