%if False

> module Epitome where

%endif

\documentclass[a4paper]{report}
\usepackage{stmaryrd,wasysym,url,
            upgreek,palatino,alltt,
            color}
\usepackage{hyperref}

%include lhs2TeX.fmt
%include lhs2TeX.sty
%include polycode.fmt

%include stuff.fmt

\begin{document}

\title{An Epigram Implementation}
\author{Edwin Brady,  James Chapman, Pierre-\'{E}variste Dagand, \\
   Adam Gundry, Conor McBride, Peter Morris
}
\maketitle

\tableofcontents

\chapter{Introduction}

\input{Docs/Intro.tex}
\input{Docs/Language.tex}

\chapter{Core}

%include Root.lhs
%include Rooty.lhs
%include Tm.lhs
%include Tactics.lhs
%include Rules.lhs
%include Developments.lhs
%include DevLoad.lhs
%include Construction.lhs
%include Update.lhs

\chapter{Feature by Feature}

%include Features.lhs
%include UId.lhs
%include Enum.lhs
%include Sigma.lhs
%include Prop.lhs
%include Containers.lhs
%include Desc.lhs
%include Equality.lhs

\chapter{Concrete Syntax}

%include Lexer.lhs
%include Layout.lhs
%include TmParse.lhs
%include PrettyPrint.lhs

\chapter{Compiler}

%include Compiler.lhs

\chapter{Elaborator}

%include Elaborator.lhs

\chapter{Main}

%include Main.lhs


\appendix


\chapter{Perversity}

%include BwdFwd.lhs
%include Parsley.lhs
%include MissingLibrary.lhs
%include Nat.lhs


\cleardoublepage
\phantomsection
\addcontentsline{toc}{chapter}{Bibliography}
\bibliographystyle{plain}
\bibliography{Epitome}


\end{document}