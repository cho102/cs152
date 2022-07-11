%{
    #include <stdio.h>
    #include <stdlib.h>
    void yyerror(const char *msg);
    extern int currLine;
    extern int currPos;
    FILE *yyin;
%}

%union{
    int num_val;
    char* id_val;
}
%error-verbose
%start Program
%token  FUNCTION BEGIN_PARAMS END_PARAMS BEGIN_LOCALS END_LOCALS 
        BEGIN_BODY END_BODY INTEGER ARRAY OF IF THEN ENDIF ELSE 
        WHILE FOR DO BEGINLOOP ENDLOOP CONTINUE READ WRITE TRUE 
        FALSE SEMICOLON COLON COMMA L_PAREN R_PAREN 
        L_SQUARE_BRACKET R_SQUARE_BRACKET ASSIGN RETURN ENUM
%token <id_val> IDENT
%token <num_val> NUMBER

%left PLUS MINUS //4
%left MULT DIV MOD //3
%left LT LTE GT GTE EQ NEQ //5
%right NOT //6
%left AND //7
%left OR  //8
%right ASSIGN //9

%%
Program:                Functions                       {printf("Program -> Functions\n");}
                        ;

Functions:              /*empty*/                       {printf("Functions -> epsilon\n");}
                        | Function Functions            {printf("Functions -> Function Functions\n");}
                        ;

Function:               FUNCTION Identifier SEMICOLON BEGIN_PARAMS Dec END_PARAMS BEGIN_LOCALS Dec END_LOCALS BEGIN_BODY Stmt END_BODY
                                                        {printf("Function -> FUNCTION Identifier SEMICOLON BEGIN_PARAMS Dec END_PARAMS BEGIN_LOCALS Dec END_LOCALS BEGIN_BODY Stmt END_BODY\n");}

Dec:                    Declaration SEMICOLON Dec       {printf("Dec -> Declaration SEMICOLON Dec\n");}
                        |/*empty*/                      {printf("Dec -> epison\n");}
                        ;

Stmt:                   Statement SEMICOLON Stmt        {printf("Stmt -> Statement SEMICOLON Stmt\n");}
                        | Statement SEMICOLON           {printf("Stmt -> Statement SEMICOLON\n");}
                        ;

Declaration:            Ident COLON INTEGER             {printf("Declaration -> Ident COLON INTEGER\n");} 
                        | Ident COLON  ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER        
                                                        {printf("Declaration -> Ident COLON  ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER\n");} 
                        | Ident COLON ENUM L_PAREN Ident R_PAREN                                
                                                        {printf("Declaration -> Ident COLON ENUM L_PAREN Ident R_PAREN\n");}
                        ;

Ident:                  Identifier                           {printf("Ident -> Identifier\n");} 
                        | Identifier COMMA Ident             {printf("Ident -> Identifier COMMA Ident\n");}
                        ;

Statement:              A                               {printf("Statement -> A\n");}
                        |B                              {printf("Statement -> B\n");}
                        |C                              {printf("Statement -> C\n");}
                        |D                              {printf("Statement -> D\n");}
                        |E                              {printf("Statement -> E\n");}
                        |F                              {printf("Statement -> F\n");}
                        |G                              {printf("Statement -> G\n");}
                        |H                              {printf("Statement -> H\n");}
                        ;       

A:                      Var ASSIGN Expression           {printf("A -> Var ASSIGN Expression\n");}
                        ;

B:                      IF Bool_Expr THEN Stmt ENDIF    {printf("B -> IF Bool_Expr THEN Stmt ENDIF\n");} 
                        | IF Bool_Expr THEN Stmt ELSE Stmt ENDIF        
                                                        {printf("B -> IF Bool_Expr THEN Stmt ELSE Stmt ENDIF\n");}
                        ;

C:                      WHILE Bool_Expr BEGINLOOP Stmt ENDLOOP      
                                                        {printf("C -> WHILE Bool_Expr BEGINLOOP Stmt ENDLOOP\n");}
                        ;

D:                      DO BEGINLOOP Stmt ENDLOOP WHILE Bool_Expr       
                                                        {printf("D -> DO BEGINLOOP Stmt ENDLOOP WHILE Bool_Expr\n");}
                        ;

E:                      READ Var E_BRANCH               {printf("E -> READ Var E_BRANCH\n");}
                        ;

E_BRANCH:               COMMA Var E_BRANCH              {printf("E_BRANCH -> COMMA Var E_BRANCH\n");} 
                        |/*empty*/                      {printf("E_BRANCH -> epison\n");} 
                        ;

F:                      WRITE Var E_BRANCH              {printf("F -> WRITE Var E_BRANCH\n");}
                        ;

G:                      CONTINUE                        {printf("G -> CONTINUE\n");}
                        ;

H:                      RETURN Expression               {printf("H -> RETURN Expression\n");}
                        ;

Bool_Expr:              Relation_And_Expr RAE           {printf("Bool_Expr -> Relation_And_Expr RAE\n");}
                        ;

RAE:                    OR Relation_And_Expr RAE        {printf("RAE -> OR Relation_And_Expr RAE\n");} 
                        |/*empty*/                      {printf("RAE -> epison\n");}
                        ;

Relation_And_Expr:      Relation_Expr RE                {printf("Relation_And_Expr -> Relation_Expr RE\n");}
                        ;

RE:                     AND Relation_Expr RE            {printf("RE -> AND Relation_Expr RE\n");} 
                        |/*empty*/                      {printf("RE -> epsilon\n");}
                        ;

Relation_Expr:          RE_branch                       {printf("Relation_Expr -> RE_branch\n");} 
                        | NOT RE_branch                 {printf("Relation_Expr -> NOT RE_branch\n");}
                        ;

RE_branch:              RE_A                            {printf("RE_branch -> RE_A\n");} 
                        | TRUE                          {printf("RE_branch -> TRUE\n");} 
                        | FALSE                         {printf("RE_branch -> FALSE\n");} 
                        | RE_D                          {printf("RE_branch -> RE_D\n");}
                        ;

RE_A:                   Expression Comp Expression      {printf("RE_A -> Expression Comp Expression\n");}
                        ;

RE_D:                   L_PAREN Bool_Expr R_PAREN       {printf("RE_D -> L_PAREN Bool_Expr R_PAREN\n");}
                        ;

Comp:                   EQ                              {printf("Comp -> EQ\n");}
                        |NEQ                            {printf("Comp -> NEQ\n");}
                        |LT                             {printf("Comp -> LT\n");}
                        |GT                             {printf("Comp -> GT\n");}
                        |LTE                            {printf("Comp -> LTE\n");}
                        |GTE                            {printf("Comp -> GTE\n");}
                        ;

Expression:             Multiplicative_Expr  ME           {printf("Expression -> Multiplicative_Expr ME\n");} 
                        ;

ME:                     MINUS Multiplicative_Expr ME    {printf("ME -> MINUS Multiplicative_Expr ME\n");} 
                        | PLUS Multiplicative_Expr ME   {printf("ME -> PLUS Multiplicative_Expr ME\n");} 
                        |/*empty*/                      {printf("ME -> epison\n");} 
                        ;

Multiplicative_Expr:    Term ME_branch                  {printf("Multiplicative_Expr -> Term ME_branch\n");} 
                        ;

ME_branch:              MOD Term ME_branch              {printf("ME_branch -> MOD Term ME_branch\n");} 
                        | DIV Term ME_branch            {printf("ME_branch -> DIV Term ME_branch\n");} 
                        | MULT Term ME_branch           {printf("ME_branch -> MULT Term ME_branch\n");} 
                        |/*empty*/                      {printf("ME_branch -> epison\n");}
                        ;

Term:                   Term_branch                     {printf("Term -> Term_branch\n");} 
                        | MINUS Term_branch             {printf("Term -> MINUS Term_branch\n");} 
                        | Identifier L_PAREN Expr R_PAREN    {printf("Term -> Identifier L_PAREN Expr R_PAREN\n");}
                        ;

Term_branch:            Var                             {printf("Term_branch -> Var\n");} 
                        | NUMBER                        {printf("Term_branch -> NUMBER\n");} 
                        | L_PAREN Expression R_PAREN    {printf("Term_branch -> L_PAREN Expression R_PAREN\n");}
                        ;

Expr:                   Expr_Loop                       {printf("Expr -> Expr_Loop\n");} 
                        |/*empty*/                      {printf("Expr -> epison\n");}
                        ;

Expr_Loop:              Expression                      {printf("Expr_Loop -> Expression\n");} 
                        | Expression COMMA Expr_Loop    {printf("Expr_Loop -> Expression Comma Expr_Loop\n");}
                        ;

Var:                    Identifier                      {printf("Var -> Identifier\n");} 
                        | Identifier L_SQUARE_BRACKET Expression R_SQUARE_BRACKET        
                                                        {printf("Var -> Identifier L_SQUARE_BRACKET Expression R_SQUARE_BRACKET\n");}
                        ;

Identifier:             IDENT                           {printf("Identifier -> IDENT %s\n", $1);}

%%

int main(int argc, char **argv)
{
    if (argc > 1)
    {
        yyin = fopen(argv[1], "r");
        if(yyin == NULL)
        {
            printf("This is not a valid file name: %s filename\n", argv[1]);
            exit(0);
        }
    }
    yyparse();
    return 0;
}

void yyerror(const char *msg)
{
    printf("Error at Line %d and position %d: %s\n", currLine, currPos, msg);
    exit(0);
}