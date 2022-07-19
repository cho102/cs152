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

%left PLUS MINUS
%left MULT DIV MOD
%left LT LTE GT GTE EQ NEQ
%right NOT
%left AND
%left OR
%right ASSIGN

%%
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