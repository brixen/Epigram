\section{News about updated references}
\label{sec:news}

%if False

> {-# OPTIONS_GHC -F -pgmF she #-}
> {-# LANGUAGE FlexibleInstances, TypeOperators, GADTs #-}

> module ProofState.News where

> import Data.Foldable hiding (foldr)
> import Data.Maybe
> import Data.Monoid hiding (All)

> import Evidences.Rules
> import Evidences.Tm

%endif


The news system represents stored updates to references. For performance
reasons, we do not wish to traverse the entire proof state every time
modifications are made to one part of the tree. Instead, we store news
entries below the cursor, and update following entries when the cursor
moves down. This section describes the data that is stored in the
proof state, and section \ref{sec:wire_service} describes how news is
propagated.


\subsection{News}


|News| represents possible changes to references. At the moment, it may
be |GoodNews| (the reference has become more defined) or |NoNews|
(even better from our perspective, as the reference has not
changed). Note that |News| is ordered by increasing ``niceness''.

When we come to implement functionality to remove definitions from the proof state,
we will also need |BadNews| (the reference has changed but is not more informative)
and |DeletedNews| (the reference has gone completely).

> data News = DeletedNews | BadNews | GoodNews | NoNews deriving (Eq, Ord, Show)

Handily, |News| is a monoid where the neutral element is |NoNews| and composing
two |News| takes the less nice.

> instance Monoid News where
>     mempty   = NoNews
>     mappend  = min


\subsection{News Bulletin}

A |NewsBulletin| is a list of pairs of updated references and the news about them.

> type NewsBulletin = [(REF, News)]


\subsubsection{Adding news}

The |addNews| function adds the given news to the bulletin, if it is newsworthy.

> addNews :: (REF, News) -> NewsBulletin ->  NewsBulletin
> addNews (_,  NoNews)  old  = old
> addNews (r,  n)       old  = (r, n `mappend` n') : old' where
>   -- Find previous versions n' (if any), 
>   -- Remove duplicate in old':
>   (n', old') = seek old
>   seek [] = (NoNews, [])
>   seek ((r', n') : old) | r == r' = (n', old)
>   seek (rn : old) = (n', rn : old') where (n', old') = seek old

Using |seek|, we enforce the invariant that any reference
appears at most once in a |NewsBulletin|.


\subsubsection{Getting the latest news}

The |lookupNews| function returns the news about a reference contained
in the bulletin, which may be |NoNews| if the reference is not
present.

> lookupNews :: NewsBulletin -> REF -> News
> lookupNews nb ref = fromMaybe NoNews (lookup ref nb)


The |getNews| function looks for a reference in the news bulletin,
and returns it with its news if it is found, or returns |Nothing| if
not.

> getNews :: NewsBulletin -> REF -> Maybe (REF, News)
> getNews nb ref = find ((== ref) . fst) nb


The |getLatest| function returns the most up-to-date copy of the given
reference, either the one from the bulletin if it is present, or the
one passed in otherwise. 

> getLatest :: NewsBulletin -> REF -> REF
> getLatest []                ref = ref
> getLatest ((ref', _):news)  ref
>     | ref == ref'  = ref'
>     | otherwise    = getLatest news ref

The slightly odd recursive case arises because equality for references
just compares their names.

\conor{Need to modify this to update FAKEs correctly.}


\subsubsection{Merging news}


The |mergeNews| function takes older and newer bulletins, and composes them to
produce a single bulletin with the worst news about every reference mentioned
in either.

> mergeNews :: NewsBulletin -> NewsBulletin -> NewsBulletin
> mergeNews new [] = new
> mergeNews new old = foldr addNews old new


\subsubsection{Read all about it}

The |tellNews| function applies a bulletin to a term. It returns the updated
term and the news about it (i.e.\ the least nice news of any reference used
in the term).

> tellNews :: NewsBulletin -> Tm {d, TT} REF -> (Tm {d, TT} REF, News)
> tellNews []    tm = (tm, NoNews)
> tellNews news  tm = case foldMap (lookupNews news) tm of
>     NoNews  -> (tm, NoNews)
>     n       -> (fmap (getLatest news) tm, n)

The |tellNewsEval| function takes a bulletin, term and its present value.
It updates the term with the bulletin and re-evaluates it if necessary.

> tellNewsEval :: NewsBulletin -> INTM :=>: VAL -> (INTM :=>: VAL, News)
> tellNewsEval news (tm :=>: tv) = case tellNews news tm of
>     (_,    NoNews)    -> (tm   :=>: tv,        NoNews)
>     (tm',  GoodNews)  -> (tm'  :=>: evTm tm',  GoodNews)