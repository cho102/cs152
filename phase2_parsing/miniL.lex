/* cs152-miniL phase1 */

%{   
   /* write your C code here for definitions of variables and including headers */
   #include "y.tab.h"
   int currLine = 1, currPos = 1;
%}

/* some common rules */
DIGIT    [0-9]
LETTER   [a-zA-Z]

%%
   /* specific lexer rules in regex */

function           {printf("\n"); currPos += yyleng; return FUNCTION;}
beginparams        {printf("\n"); currPos += yyleng; return BEGIN_PARAMS;}
endparams          {printf("\n"); currPos += yyleng; return END_PARAMS;}
beginlocals        {printf("\n"); currPos += yyleng; return BEGIN_LOCALS;}
endlocals          {printf("\n"); currPos += yyleng; return END_LOCALS;}
beginbody          {printf("\n"); currPos += yyleng; return BEGIN_BODY;}
endbody            {printf("\n"); currPos += yyleng; return END_BODY;}
integer            {printf("\n"); currPos += yyleng; return INTEGER;}
array              {printf("\n"); currPos += yyleng; return ARRAY;}
enum               {printf("\n"); currPos += yyleng; return ENUM;}
of                 {printf("\n"); currPos += yyleng; return OF;}
if                 {printf("\n"); currPos += yyleng; return IF;}
then               {printf("\n"); currPos += yyleng; return THEN;}
endif              {printf("\n"); currPos += yyleng; return ENDIF;}
else               {printf("\n"); currPos += yyleng; return ELSE;}
for                {printf("\n"); currPos += yyleng; return FOR;}
while              {printf("\n"); currPos += yyleng; return WHILE;}
do                 {printf("\n"); currPos += yyleng; return DO;}
beginloop          {printf("\n"); currPos += yyleng; return BEGINLOOP;}
endloop            {printf("\n"); currPos += yyleng; return ENDLOOP;}
continue           {printf("\n"); currPos += yyleng; return CONTINUE;}
read               {printf("\n"); currPos += yyleng; return READ;}
write              {printf("\n"); currPos += yyleng; return WRITE;}
and                {printf("\n"); currPos += yyleng; return AND;}
or                 {printf("\n"); currPos += yyleng; return OR;}
not                {printf("\n"); currPos += yyleng; return NOT;}
true               {printf("\n"); currPos += yyleng; return TRUE;}
false              {printf("\n"); currPos += yyleng; return FALSE;}
return             {printf("\n"); currPos += yyleng; return RETURN;}

"-"            {printf("\n"); currPos += yyleng; return MINUS;}
"+"            {printf("\n"); currPos += yyleng; return PLUS;}
"*"            {printf("\n"); currPos += yyleng; return MULT;}
"/"            {printf("\n"); currPos += yyleng; return DIV;}
"%"            {printf("\n"); currPos += yyleng; return MOD;}

"=="            {printf("\n"); currPos += yyleng; return EQ;}
"<>"            {printf("\n"); currPos += yyleng; return NEQ;}
"<"             {printf("\n"); currPos += yyleng; return LT;}
">"             {printf("\n"); currPos += yyleng; return GT;}
"<="            {printf("\n"); currPos += yyleng; return LTE;}
">="            {printf("\n"); currPos += yyleng; return GTE;}


";"            {printf("\n"); currPos += yyleng; return SEMICOLON;}
":"            {printf("\n"); currPos += yyleng; return COLON;}
","            {printf("\n"); currPos += yyleng; return COMMA;}
"("            {printf("\n"); currPos += yyleng; return L_PAREN;}
")"            {printf("\n"); currPos += yyleng; return R_PAREN;}
"["            {printf("\n"); currPos += yyleng; return L_SQUARE_BRACKET;}
"]"            {printf("\n"); currPos += yyleng; return R_SQUARE_BRACKET;}
":="           {printf("\n"); currPos += yyleng; return ASSIGN;}

##.*           {currLine++; currPos = 1;}
(\.{DIGIT}+)|({DIGIT}+(\.{DIGIT}*)?([eE][+-]?[0-9]+)?)         {currPos += yyleng; yylval.dval = atof(yytext); return NUMBER;}

({DIGIT}+|_)({LETTER}+{DIGIT}*(_?))*{LETTER}*{DIGIT}*          {printf("Error at line %d, column %d: identifier \"%s\" must begin with a letter\n", currPos, currLine, yytext); exit(0);}
({LETTER}+{DIGIT}*(_?))*_                                      {printf("Error at line %d, column %d: identifier \"%s\" cannot end with an underscore\n", currPos, currLine, yytext); exit(0);}
({LETTER}+{DIGIT}*(_?))*{LETTER}*{DIGIT}*                      {printf("IDENT %s\n", yytext); currPos += yyleng;}

[ \t]+         {/* ignore spaces */ currPos += yyleng;}
"\n"           {currLine++; currPos = 1;}
.              {printf("Error at line %d, column %d: unrecognized symbol \"%s\"\n", currLine, currPos, yytext); exit(0);}

%%
