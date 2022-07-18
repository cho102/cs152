%{
    #define YY_NO_UNPUT
    #include <stdio.h>
    #include <stdlib.h>
    #include <map>
    #include <string.h>
    #include <set>

    int tempCount = 0;
    int labelCount = 0;
    extern char* yytext; 
    extern int currPos;
    std::map<std::string, std::string> varTemp;
    std::map<std::string, int> arrSize;
    bool mainFunc = false;
    std::set<std::string> funcs;
    std::set<std::string> reserved {"Program", "FUNCTION", "BEGIN_PARAMS", "END_PARAMS", "BEGIN_LOCALS", 
        "END_LOCALS", "BEGIN_BODY", "END_BODY", "INTEGER", "ARRAY", "OF", "IF", "THEN", "ENDIF", "ELSE", 
        "WHILE", "FOR", "DO", "BEGINLOOP", "ENDLOOP", "CONTINUE", "READ", "WRITE", "TRUE", "FALSE", 
        "SEMICOLON", "COLON", "COMMA", "L_PAREN", "R_PAREN", "L_SQUARE_BRACKET", "R_SQUARE_BRACKET", "ASSIGN", 
        "RETURN", "ENUM", "IDENT", "NUMBER", "PLUS", "MINUS", "MULT", "DIV", "MOD", "LT", "LTE", "GT", "GTE", 
        "EQ", "NEQ", "NOT", "AND", "OR", "ASSIGN", 
        "Program", "Functions", "Function", "Dec", "Stmt", "Declaration", "Ident", "Statement", "A", "B", "C",
        "D", "E", "E_BRANCH", "F", "G", "H", "Bool_Expr", "RAE", "Relation_And_Expr", "RE", "Relation_Expr", 
        "RE_branch", "RE_A", "RE_D", "Comp", "Expression", "ME", "Multiplicative_Expr", "ME_branch", "Term", 
        "Term_branch", "Expr", "Expr_Loop", "Var", "Identifier"
    }

    void yyerror(const char *msg);
    int yylex();
    std::string new_temp();
    std::string new_label():
%}

%union{
    int num;
    char* ident;
    struct S { char* code; } statement;
    struct Ew {
        char* place;
        char* code;
        bool arr;
    } expression;
}

%start Program

%token <num> NUMBER
%token <ident> IDENT
%type <expression>  Program Functions Function Dec Declaration Ident 
                    A B C D E E_BRANCH F G H Bool_Expr RAE 
                    Relation_And_Expr RE Relation_Expr RE_branch RE_A 
                    RE_D Comp Expression ME Multiplicative_Expr 
                    ME_branch Term Term_branch Expr Expr_Loop Var Identifier
%type <statement> Stmt Statement

%token  FUNCTION BEGIN_PARAMS END_PARAMS BEGIN_LOCALS END_LOCALS 
        BEGIN_BODY END_BODY BEGINLOOP ENDLOOP SEMICOLON 
        RETURN ENUM
%token COLON INTEGER COMMA ARRAY L_SQUARE_BRACKET R_SQUARE_BRACKET L_PAREN R_PAREN
%token IF ELSE THEN CONTINUE ENDIF OF READ WRITE DO WHILE FOR
%token TRUE FALSE
%left ASSIGN EQ NEQ LT LTE GT GTE ADD SUB MULT DIV MOD AND OR
%right NOT

%%
Program:                %empty                          
                        {
                            if(!mainFunc){
                                printf("No main function declared!\n");
                            }
                        }
                        | Function Program              
                        {}
                        ;


Function:               FUNCTION Identifier SEMICOLON BEGIN_PARAMS Dec END_PARAMS BEGIN_LOCALS Dec END_LOCALS BEGIN_BODY Stmt END_BODY
                        {
                            std::string temp = "func ";
                            temp.append($2.place);
                            temp.append("\n");
                            std::string s = $2.place;
                            if (s == "main"){
                                mainFunc = true;
                            }
                            temp.append($5.code);
                            std::string decs = $5.code;
                            int decNum = 0;
                            while(decs.find(".") != std::string::npos){
                                int pos = decs.find(".")
                            }
                        }

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

Comp:                   EQ                              
                        {printf("Comp -> EQ\n");}
                        |NEQ                            
                        {printf("Comp -> NEQ\n");}
                        |LT                             
                        {printf("Comp -> LT\n");}
                        |GT                             
                        {printf("Comp -> GT\n");}
                        |LTE                            
                        {printf("Comp -> LTE\n");}
                        |GTE                            
                        {printf("Comp -> GTE\n");}
                        ;

Expression:             Multiplicative_Expr  ME           {printf("Expression -> Multiplicative_Expr ME\n");} 
                        ;

ME:                     MINUS Multiplicative_Expr ME    
                        {printf("ME -> MINUS Multiplicative_Expr ME\n");
                        } 
                        | PLUS Multiplicative_Expr ME   
                        {printf("ME -> PLUS Multiplicative_Expr ME\n");
                        } 
                        |/*empty*/                      {printf("ME -> epison\n");} 
                        ;

Multiplicative_Expr:    Term ME_branch                  {printf("Multiplicative_Expr -> Term ME_branch\n");} 
                        ;

ME_branch:              MOD Term ME_branch              
                        {printf("ME_branch -> MOD Term ME_branch\n");
                        } 
                        | DIV Term ME_branch            
                        {printf("ME_branch -> DIV Term ME_branch\n");
                        } 
                        | MULT Term ME_branch           
                        {printf("ME_branch -> MULT Term ME_branch\n");
                        } 
                        |/*empty*/                      {printf("ME_branch -> epison\n");}
                        ;

Term:                   Term_branch                     {printf("Term -> Term_branch\n");} 
                        | MINUS Term_branch             
                        {printf("Term -> MINUS Term_branch\n");
                        } 
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

Var:                    Identifier                      
                        {
                            std::string temp;
                            std::string ident = $1.place;
                            if(funcs.find(ident) == funcs.end() && varTemp.find(ident) == varTemp.end()){
                                printf("Identifier %s is not declared.\n", ident.c_str());
                            } else if(arrSize[ident] > 1) {
                                printf("Did not provide index for array Identifier %s. \n", ident.c_str());
                            }
                            $$.code = strdup("");
                            $$.place = strdup(ident.c_str());
                            $$.arr = false;
                        } 
                        | Identifier L_SQUARE_BRACKET Expression R_SQUARE_BRACKET        
                        {
                            std::string temp;
                            std::string ident = $1.place;
                            if(funcs.find(ident) == funcs.end() && varTemp.find(ident) == varTemp.end()){
                                printf("Identifier %s is not declared.\n", ident.c_str());
                            } else if(arrSize[ident] > 1) {
                                printf("Did not provide index for array Identifier %s. \n", ident.c_str());
                            }
                            temp.append($1.place);
                            temp.append(", ");
                            temp.append($3.place);
                            $$.code = strdup($3.code);
                            $$.place = strdup(temp.c_str());
                            $$.arr = true;
                        }
                        ;

Identifier:             IDENT                           {printf("Identifier -> IDENT %s\n", $1);}
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
    extern int yylineno;
    extern char *yytext;

    printf("%s on line %d at char %d at symbol \"%s\"\n", msg, yylineno curPos, yytext);
    exit(1);
}

std::string new_temp() {
    std::string t = "t" + std::to_string(tempCount);
    tempCount++;
    return t;
}

std::string new_label() {
    std::string l = "L" + std::to_string(labelCount);
    labelCount++;
    return l;
}