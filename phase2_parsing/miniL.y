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
%token FUNCTION BEGIN_PARAMS END_PARAMS BEGIN_LOCALS END_LOCALS BEGIN_BODY END_BODY INTEGER ARRAY OF IF THEN ENDIF ELSE WHILE FOR DO BEGINLOOP ENDLOOP CONTINUE READ WRITE TRUE FALSE SEMICOLON COLON COMMA L_PAREN R_PAREN L_SQUARE_BRACKET R_SQUARE_BRACKET ASSIGN RETURN
%token <id_val> IDENT
%token <num_val> NUMBER

%left MULT DIV MOD PLUS MINUS
%left LT LTE GT GTE EQ NEQ
%right NOT
%left AND OR 
%right ASSIGN

%%
{printf("\n");}
Program:    Functions           {printf("Program -> Functions\n");}
            ;

Functions:  /*empty*/                   {printf("Functions\n");}
            | Function Functions        {printf("\n");}
            ;

Function:   FUNCTION IDENT SEMICOLON BEGIN_PARAMS Dec END_PARAMS BEGIN_LOCALS Dec END_LOCALS BEGIN_BODY Stmt END_BODY
                {printf("Function:     FUNCTION IDENT SEMICOLON BEGINPARAMS Dec END_PARAMS BEGIN_LOCALS Dec END_LOCALS BEGIN_BODY Stmt END_BODY\n");}

Dec:        Declaration SEMICOLON Dec       
            |/*empty*/
            ;

Stmt:       Statement SEMICOLON Stmt 
            | Statement SEMICOLON
            ;

Declaration:    Ident COLON INTEGER 
                | Ident COLON  ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER 
                | Ident COLON ENUM L_PAREN Ident R_PAREN INTEGER
                ;

Ident:      IDENT 
            | IDENT COMMA Ident
            ;

Statement:  A
            |B
            |C
            |D
            |E
            |F
            |G
            |H
            ;

A:      Var ASSIGN Expression
        ;

B:      IF Bool_Expr THEN Stmt ENDIF 
        | IF Bool_Expr THEN Stmt ELSE Stmt ENDIF
        ;

C:      WHILE Bool_Expr BEGINLOOP Stmt ENDLOOP
        ;

D:      DO BEGINLOOP Stmt ENDLOOP WHILE Bool_Expr
        ;

E:      READ Var E'
        ;

E':     COMMA Var E' 
        |/*empty*/
        ;

F:      WRITE Var E'
        ;

G:      CONTINUE
        ;

H:      RETURN Expression
        ;

Bool_Expr:      Relation_And_Expr RAE
                ;

RAE:    OR Relation_And_Expr RAE 
        |/*empty*/
        ;

Relation_And_Expr:      Relation_Expr RE
                        ;
RE:     AND Relation_Expr RE 
        |/*empty*/
        ;

Relation_Expr:      RE_branch 
                    | NOT RE_branch
                    ;

RE_branch:      RE_A 
                | TRUE 
                | FALSE 
                | RE_D
                ;
RE_A:       Expression Comp Expression
            ;

RE_D:       L_PAREN Bool_Expr R_PAREN
            ;

Comp:       EQ
            |NEQ
            |LT
            |GT
            |LTE
            |GTE
            ;

Expression:     Multiplicative_Expr 
                | ME
                ;

ME:     MINUS Multiplicative_Expr ME 
        | PLUS Multiplicative_Expr ME 
        |/*empty*/
        ;

Multiplicative_Expr:    Term 
                        | ME_branch
                        ;

ME_branch:      MOD Term ME_branch 
                | DIV Term ME_branch 
                | MULT Term ME_branch 
                |/*empty*/
                ;

Term:     Term_branch 
            | MINUS Term_branch 
            | IDENT L_PAREN Expr R_PAREN
            ;

Term_branch:     Var 
                | NUMBER 
                | L_PAREN Expression R_PAREN
                ;

Expr:     Expr_Loop 
            |/*empty*/
            ;

Expr_Loop:     Expression 
                | Expression Comma Expr_Loop
                ;

Var:     IDENT 
        | IDENT L_SQUARE_BRACKET Expression R_SQUARE_BRACKET
        ;

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