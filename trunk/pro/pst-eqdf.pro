%!
% PostScript prologue for pst-eqdf.tex.
% Version 2004.11, 2004/11/14
% For distribution, see pstricks.tex.
%
% Dominique Rodriguez
%
%       HISTORY
% 2004/11/14 : correction of a priority problem
%              ^ before unary - (new rule FS)
%
/tx@EqdfDict 400 dict def tx@EqdfDict begin
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Pi
/Pi 3.14159265359 def
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PS ANALYZER FOR ALGEBRAIC EXPRESSION V1.11
% E->T|E+T
% T->FS|T*FS                                  %%% NEW 2004/11/14
% FS -> F | +SF | -SF                         %%% NEW 2004/11/14
% F->P|F^P                                    %%% OLD
% F->P|F^SF                                   %%% NEW 2004/11/14  ???? ^FS
% P->(E)|literal
% literal->number|var|var[E]|func(params)%%|-P|+P%%% OLD
% params->E|E,param
%
% E expression, T term, SF signed factor, F factor, P power
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% parser
%% str -> [ LIFO vector ]
/AlgParser { InitParser SetExpr LexStr 0 exch AnalyzeListOfE ExpressionVector /ExpressionVector [] def} def
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
/SetExpr { /ExpressionString exch def } def
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
/InitParser {
  /ExpressionVector [] def  /AddVector [] def
  /AddVectorfree [] def     /MulVector [] def
  /MulVectorfree [] def     /PowVector [] def
  /PowVectorfree [] def     /OpParVector [] def
  /ClParVector [] def       /ParVectorFree [] def
  /BraVector [] def         /SemVector [] def
  /ComVector [] def         /ExpressionVector [] def
} def
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
/FLbreak { tst not {/L exch def /F exch def 2 copy L eq exch F eq and /tst exch def} {pop pop}ifelse} def
/Negbreak { tst not { dup 0 lt /tst exch def } if } def
/STOP { tst {TOUF} if} def
/tst false def
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% analyze Expression List
%% first last
/AnalyzeListOfE {
  exch SemVector {
    exch 1 index 1 sub AnalyzeExpr 1 add
  } forall%%last_char
  exch AnalyzeExpr
} def
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% analyze Expr
%% first last
/AnalyzeExpr {
  FindFirstAdd%% first last pos+
  2 copy abs 1 sub ne
  { 3 -1 roll 1 index abs 1 sub AnalyzeExpr dup abs 1 add 3 -1 roll  AnalyzeTerm EvalAdd }
  { pop AnalyzeTerm } ifelse 
} def
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% analyze Term
%% first last
/AnalyzeTerm {%%19 28 FLbreak STOP
  FindFirstMul%% first last pos*
  2 copy abs 1 sub ne
  { 3 -1 roll 1 index abs 1 sub AnalyzeTerm dup abs 1 add 3 -1 roll  AnalyzeSignedFactor EvalMul }%%% NEW 2004/11/14
  { pop AnalyzeSignedFactor } ifelse%%% NEW 2004/11/14
} def
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% NEW 2004/11/14
%% analyze Signed Factor
%% first last ->
/AnalyzeSignedFactor {
  ExpressionString 2 index get
  dup 45 eq%% a - sign
  { pop exch 1 add exch AnalyzeSignedFactor EvalNeg }
  { 43 eq%%a + sign
    { exch 1 add exch AnalyzeSignedFactor }
    { AnalyzeFactor } ifelse } ifelse
} def
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% analyze Factor
%% first last ->
/AnalyzeFactor {
  FindFirstPow%% first last pos*
  2 copy abs 1 sub ne
%  { 3 -1 roll 1 index abs 1 sub AnalyzeFactor dup abs 1 add 3 -1 roll  AnalyzePower EvalPow }
  { 3 -1 roll 1 index abs 1 sub AnalyzeFactor dup abs 1 add 3 -1 roll  AnalyzeSignedFactor EvalPow }% NEW 2004/11/14
  { pop AnalyzePower } ifelse
} def
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% analyze Power
%% first last ->
/compteur 0 def 
/AnalyzePower {
  ExpressionString 2 index get
  dup 40 eq%% an open parenthesis
  { pop 1 index UnfreePar 1 sub exch 1 add exch AnalyzeExpr }
  {  dup 45 eq%% a - sign
    { pop exch 1 add exch AnalyzePower EvalNeg }
    { dup 43 eq%%a + sign
      { pop exch 1 add exch AnalyzePower }
      { dup 46 eq 1 index 48 ge 2 index 57 le and or%%a digit or a dot
      	{ pop AnalyzeNumber }
      	{ pop AnalyzeLiteral } ifelse } ifelse } ifelse } ifelse
} def
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% analyze parameters list
%% first last
/AnalyzeParam {
  { FindFirstCom%% first last pos,
    3 -1 roll 1 index 1 sub AnalyzeExpr
    2 copy 1 sub ne { 1 add exch } { pop pop exit } ifelse
  } loop
} def
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Find the eventual addition at this level
%% first last -> position
/FindFirstAdd {
  2 copy /Last exch def /First exch def false 0
  AddVector {
    AddVectorFree 2 index get
    { /pos exch def
      true 0 1 ClParVector length 1 sub
      { ParVectorFree 1 index get
        { OpParVector 1 index get pos abs le
          ClParVector 2 index get pos abs ge and
 	  pos abs First lt pos abs Last gt or or
          { pop pop false exit } if
        } if
        pop
      } for
      { pop pop true dup exit } if
    }
    { pop } ifelse
    1 add
  } forall
  pop
  { pos UnfreeAdd}%% find one add
  { Last 1 add } ifelse
} def
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Find the eventual multiplication at this level
%% first last -> first last position
/FindFirstMul {
  2 copy /Last exch def /First exch def false 0
  MulVector {
    MulVectorFree 2 index get
    { /pos exch def
      %% if it is in the current part of the analysed expr
      pos abs First gt pos abs Last lt and
      { true 0 1 ClParVector length
        dup 0 eq%% no parenthesis
      	{ pop pop pop pop exch not exch exit }
      	{ 1 sub
      	  { ParVectorFree 1 index get
      	    { OpParVector 1 index get pos abs lt%% in this parenthesis level
      	      ClParVector 2 index get pos abs gt and
      	      { pop pop false exit } if%%then exit loop
      	    } if
      	    pop } for
      	  { pop pop true dup exit } if } ifelse } if
    } { pop } ifelse
    1 add
  } forall
  pop
  { pos UnfreeMul} %% find one mul
  { Last 1 add } ifelse
} def
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Find the eventual power at this level
%% first last -> first last position
/FindFirstPow {
  2 copy /Last exch def /First exch def false 0
  PowVector {
    PowVectorFree 2 index get
    { /pos exch def
      %% if it is in the current part of the analysed expr
      pos First gt pos Last lt and
      { true 0 1 ClParVector length
      	dup 0 eq%% no parenthesis
      	{ pop pop pop pop exch not exch exit }
      	{ 1 sub
      	  { ParVectorFree 1 index get
      	    { OpParVector 1 index get pos abs lt%% in this parenthesis level
      	      ClParVector 2 index get pos abs gt and
      	      { pop pop false exit } if%%then exit loop
      	    } if
      	    pop } for
      	  { pop pop true dup exit } if } ifelse } if
    } { pop } ifelse
    1 add
  } forall
  pop
  { pos UnfreePow} %% find one ^
  { Last 1 add } ifelse
} def
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Find the eventual comma at this level
%% first last -> first last position
/FindFirstCom {
  2 copy /Last exch def /First exch def false 0
  ComVector {
    ComVectorFree 2 index get
    { /pos exch def
      %% if it is in the current part of the analysed expr
      pos First gt pos Last lt and
      { true 0 1 ClParVector length
      	dup 0 eq%% no parenthesisSTOP 
      	{ pop pop pop pop exch not exch exit }
      	{ 1 sub
      	  { ParVectorFree 1 index get
      	    { OpParVector 1 index get pos abs lt%% in this parenthesis level
      	      ClParVector 2 index get pos abs gt and
      	      { pop pop false exit } if%%then exit loop
      	    } if
      	    pop } for
      	  { pop pop true dup exit } if } ifelse } if
    } { pop } ifelse
    1 add
  } forall
  pop
  { pos UnfreeCom} %% find one mul
  { Last 1 add } ifelse
} def
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Find the eventual addition at this level
%% first last -> first last position
/FindFirstPar {
  2 copy /Last exch def /First exch def false 0
  OpParVector {
    ParVectorFree 2 index get
    { /pos exch def
      pos First gt pos Last lt and
      { exch not exch exit } if
    } { pop } ifelse
    1 add
  } forall
  pop
  { pos dup UnfreePar }%% find one mul
  { Last 1 add } ifelse
} def
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Find the first opening bracket
%% first last -> first last position
/FindFirstBra {
  2 copy /Last exch def /First exch def
  BraVector {
    /pos exch def
    pos First gt pos Last lt and
    { exit } if
  } forall
  pos dup UnfreePar%% finding it is mandatory
} def
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Read the number and push it in the vector
%% first last -> 
/AnalyzeNumber {
  1 index sub 1 add ExpressionString 3 1 roll getinterval cvr /n exch def
  /ExpressionVector ExpressionVector aload length n exch 1 add array astore def
} def 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Read the literal and push it in the vector
%% first last -> 
/AnalyzeLiteral {
  ExpressionString 1 index get dup 41 eq%%close par at the end => function call
  { pop FindFirstPar%%first last parpos
    ExpressionString 3 index dup 3 index exch sub getinterval
    dup (SUM) eq 
    { 1 index 1 add 3 index 1 sub FindFirstCom%%
      3 -1 roll 1 index 1 sub AnalyzeExpr  toto }
    { 1 index 1 add 3 index 1 sub AnalyzeParam
      dup cvn /n exch def TrigoFunc
      /ExpressionVector ExpressionVector aload length
      /tx@EqdfDict cvx /begin cvx n cvx /end cvx 5 -1 roll 4 add array astore def
      %%n cvx exch 1 add array astore def
      pop pop pop } ifelse
  }
  { 93 eq%%close bracket => vector element
    { FindFirstBra%%first last brapos
      ExpressionString 3 index dup 3 index exch sub getinterval cvn /n exch def
      /ExpressionVector ExpressionVector aload length n cvx exch 1 add array astore def
      2 copy 1 add exch 1 sub AnalyzeExpr
      /ExpressionVector ExpressionVector aload length /cvi cvx exch /get cvx exch 2 add array astore def
      pop pop pop
    }
    { 1 index sub 1 add ExpressionString 3 1 roll getinterval cvn /n exch def
     /ExpressionVector ExpressionVector aload length n cvx exch 1 add array astore def } ifelse } ifelse
} def 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% push add in the vector
%% kind -> 
%% if kind>0 then add else sub
/EvalAdd {
  /ExpressionVector ExpressionVector aload length dup 3 add -1 roll
  0 gt { /add } { /sub } ifelse cvx exch 1 add array astore def
} def
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% push mul in the vector
%% -> 
/EvalMul {
  /ExpressionVector ExpressionVector aload length dup 3 add -1 roll
  0 gt { /mul } { /div } ifelse cvx exch 1 add  array astore def
} def
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% push exp in the vector
%% -> 
/EvalPow {
  pop /ExpressionVector ExpressionVector aload length
  /exp cvx exch 1 add array astore def
} def
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% push neg in the vector
%% -> 
/EvalNeg {
  /ExpressionVector ExpressionVector aload length /neg cvx exch 1 add array astore def
} def
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Lexical Analyzis of the string
%% -> 
/LexStr {
  /freepar 0 def /lastpar 0 def /lastchar 0 def
  0 ExpressionString
  { dup 40 eq 1 index 91 eq or %% open parenthesis
    { /OpParVector OpParVector aload length dup 3 add index exch 1 add array astore def 
      /ClParVector ClParVector aload length -1 exch 1 add array astore def
      /lastpar freepar def /freepar freepar 1 add def /NoPar false def} if
    dup 41 eq 1 index 93 eq or %% close parenthesis
    { ClParVector lastpar 3 index put lastpar
      dup 0 eq
      { pop }
      { { 1 sub dup ClParVector exch get -1 eq { /lastpar exch def exit } { dup 0 eq { pop exit} if } ifelse } loop }
      ifelse } if
    dup 42 eq %% * operator
    %%{ /MulVector MulVector aload length dup 3 add index exch 1 add array astore def } if
    { /MulVector 2 index MulVector aload length 1 add array astore def } if
    dup 43 eq %% + operator
    { %%test if it is a real operator and not the unary operator
      lastchar dup  40 ne      %% open parenthesis
           1 index  59 ne and  %% ;
           1 index  42 ne and  %% *
           1 index  43 ne and  %% +
           1 index  44 ne and  %% ,
           1 index  45 ne and  %% -
           1 index  47 ne and  %% /
           1 index   0 ne and  %% first char
           1 index  94 ne and  %% ^%%2004/11/14
              exch 124 ne and  %% |
      %%{/AddVector AddVector aload length dup 3 add index exch 1 add array astore def } if}
      {/AddVector 2 index AddVector aload length 1 add array astore def } if}
    if
    dup 44 eq %% , separator
    { /ComVector ComVector aload length dup 3 add index exch 1 add array astore def }
    if
    dup 45 eq %% - operator
    { %%test if it is a real operator and not the unary operator
      lastchar dup  40 ne      %% open parenthesis
           1 index  59 ne and  %% ;
           1 index  42 ne and  %% *
           1 index  43 ne and  %% +
           1 index  44 ne and  %% ,
           1 index  45 ne and  %% -
           1 index  47 ne and  %% /
           1 index   0 ne and  %% first char
           1 index  94 ne and  %% ^%%2004/11/14
              exch 124 ne and  %% |
      %%{/AddVector AddVector aload length dup 3 add index neg exch 1 add array astore def } if}
      {/AddVector 2 index neg AddVector aload length 1 add array astore def } if}
    if
    dup 47 eq %% / operator
    %%{ /MulVector MulVector aload length dup 3 add index neg exch 1 add array astore def }
    { /MulVector 2 index neg MulVector aload length 1 add array astore def }
    if
    dup 59 eq 1 index 124 eq or%% ; separator |
    { /SemVector SemVector aload length dup 3 add index exch 1 add array astore def }
    if
    dup 91 eq %% open bracket
    { /BraVector BraVector aload length dup 3 add index exch 1 add array astore def }
    if
    dup 94 eq %% ^ operator
    %%{ /PowVector PowVector aload length dup 3 add index exch 1 add array astore def }
    { /PowVector 2 index PowVector aload length 1 add array astore def }%%2004/11/14
    if
    /lastchar exch def 1 add
  } forall
  /AddVectorFree AddVector CreateFree def
  /MulVectorFree MulVector CreateFree def
  /ParVectorFree OpParVector CreateFree def
  /PowVectorFree PowVector CreateFree def
  /ComVectorFree ComVector CreateFree def
  1 sub
} def
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Create Free vector
%% ->
/CreateFree {
  dup length array exch
  { pop true exch } forall astore
} def
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Unfree parenthesis
%% pos ->
/UnfreePar {
  /pos exch def ParVectorFree 0
  OpParVector { pos eq { exit } if 1 add } forall
  false put
} def
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Unfree mul
%% pos ->
/UnfreeMul {
  MulVectorFree 0
  MulVector { pos eq { exit } if 1 add } forall
  false put
} def
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Unfree add
%% pos ->
/UnfreeAdd {
  AddVectorFree 0
  AddVector { pos eq { exit } if 1 add } forall
  false put
} def
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Unfree exp
%% pos ->
/UnfreePow {
  PowVectorFree 0
  PowVector { pos eq { exit } if 1 add } forall
  false put
} def
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Unfree com
%% pos ->
/UnfreeCom {
  ComVectorFree 0
  ComVector { pos eq { exit } if 1 add } forall
  false put
} def
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Convert to radians if trigo function call
%% (name) ->
/TrigoFunc {
  dup (cos) eq 1 index (sin) eq or exch (tan) eq or
  { /ExpressionVector ExpressionVector aload length 3.14159265359 /div cvx 180 /mul cvx 5 -1 roll 4 add
    array astore def
  } if
} def
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% METHODS FUNC
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% NEW FUNC
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
/PI     3.14155265359 def
/PIdiv2 1.57079632680 def
%% Make a discrete sum
%% n begin end expr ->
/SUM {} def
%% function arcsine in radians
%% x -> theta
/asin {%
  dup abs 1 gt { EQDFasinrangeerror  } if
  dup abs 1 eq
  { PIdiv2 exch -1 eq { neg } if }
  { .1 %% asin(x)
    { dup dup PI div 180 mul sin 3 index sub exch PI div 180 mul cos div
      dup abs 1e-6 lt { sub exit } if sub
    } loop
    exch pop } ifelse
} def
%% function arccosine in radians
%% x -> theta
/acos {%
  dup abs 1 gt { EQDFacosrangeerror  } if
  dup abs 1 eq
  { -1 eq { PI } { 0 } ifelse }
  { 1.5 %% asin(x)
    { dup dup PI div 180 mul cos 3 index sub exch PI div 180 mul sin neg div
      dup abs 1e-6 lt { sub exit } if sub
    } loop
    exch pop } ifelse
} def
/fact { 1 exch 2 exch 1 exch { mul } for } def
end
% END pst-eqdf.pro