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
        "Program", "Functions", "Function", "Dec", "Stmt", "Declaration", "Ident", "Statement", "B", "E_BRANCH", 
        "Bool_Expr", "RAE", "Relation_And_Expr", "RE", "Relation_Expr", "RE_branch", "Comp", "Expression", "ME", 
        "Multiplicative_Expr", "ME_branch", "Term", "Term_branch", "Expr", "Expr_Loop", "Var", "Identifier"
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
    struct E {
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
                                int pos = decs.find(".");
                                decs.replace(pos, 1, "=");
                                std::string part = ", $" + std::to_string(decNum) + "\n";
                                decNum++;
                                decs.replace(decs.find("\n", pos), 1, part);
                            }
                            temp.append(decs);

                            temp.append($8.code);
                            std::string statements = $11.code;
                            if (statements.find("continue") != std::string::npos){
                                printf("ERROR: Continue outside loop in function %s\n", $2.place);
                            }
                            temp.append(statements);
                            temp.append("endfunc\n\n");
                        }

Dec:                    Declaration SEMICOLON Dec       
                        {}
                        |/*empty*/                      
                        {}
                        ;

Stmt:                   Statement SEMICOLON Stmt        
                        {}
                        | Statement SEMICOLON           
                        {}
                        ;

Declaration:            Ident COLON INTEGER
                        {} 
                        | Ident COLON  ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER        
                        {} 
                        | Ident COLON ENUM L_PAREN Ident R_PAREN                                
                        {}
                        ;

Ident:                  Identifier
                        {} 
                        | Identifier COMMA Ident             
                        {}
                        ;

Statement:              Var ASSIGN Expression
                        {}
                        |B                              
                        {}
                        |WHILE Bool_Expr BEGINLOOP Stmt ENDLOOP                              
                        {}
                        |DO BEGINLOOP Stmt ENDLOOP WHILE Bool_Expr                              
                        {}
                        |READ Var E_BRANCH                              
                        {}
                        |WRITE Var E_BRANCH                              
                        {}
                        |CONTINUE                              
                        {}
                        |RETURN Expression                              
                        {
                            std::string temp = "ret ";
                            temp.append($2.code);
                        }
                        ;       

B:                      IF Bool_Expr THEN Stmt ENDIF    
                        {} 
                        | IF Bool_Expr THEN Stmt ELSE Stmt ENDIF        
                        {}
                        ;

E_BRANCH:               COMMA Var E_BRANCH              
                        {} 
                        |/*empty*/                      
                        {} 
                        ;

Bool_Expr:              Relation_And_Expr RAE           
                        {}
                        ;

RAE:                    OR Relation_And_Expr RAE        
                        {
                        } 
                        |/*empty*/                      
                        {}
                        ;

Relation_And_Expr:      Relation_Expr RE                
                        {}
                        ;

RE:                     AND Relation_Expr RE            
                        {
                        } 
                        |/*empty*/                      
                        {}
                        ;

Relation_Expr:          RE_branch                       
                        {} 
                        | NOT RE_branch                 
                        {
                        }
                        ;

RE_branch:              Expression Comp Expression
                        {} 
                        | TRUE                          
                        {} 
                        | FALSE                         
                        {} 
                        | L_PAREN Bool_Expr R_PAREN                          
                        {}
                        ;

Comp:                   EQ                              
                        {}
                        |NEQ                            
                        {}
                        |LT                             
                        {}
                        |GT                             
                        {}
                        |LTE                            
                        {}
                        |GTE                            
                        {}
                        ;

Expression:             Multiplicative_Expr  ME           
                        {} 
                        ;

ME:                     MINUS Multiplicative_Expr ME    
                        {
                        } 
                        | PLUS Multiplicative_Expr ME   
                        {
                        } 
                        |/*empty*/                      {} 
                        ;

Multiplicative_Expr:    Term ME_branch                  
                        {} 
                        ;

ME_branch:              MOD Term ME_branch              
                        {
                        } 
                        | DIV Term ME_branch            
                        {
                        } 
                        | MULT Term ME_branch           
                        {
                        } 
                        |/*empty*/                      {}
                        ;

Term:                   Term_branch                     
                        {} 
                        | MINUS Term_branch             
                        {
                        } 
                        | Identifier L_PAREN Expr R_PAREN    
                        {}
                        ;

Term_branch:            Var                             
                        {} 
                        | NUMBER                        
                        {} 
                        | L_PAREN Expression R_PAREN    
                        {}
                        ;

Expr:                   Expr_Loop                       
                        {} 
                        |/*empty*/                      
                        {}
                        ;

Expr_Loop:              Expression                      
                        {} 
                        | Expression COMMA Expr_Loop    
                        {}
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

Identifier:             IDENT                           
                        {}
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