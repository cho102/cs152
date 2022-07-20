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
    std::set<std::String> reserved {"FUNCTION", "BEGIN_PARAMS", "END_PARAMS", "BEGIN_LOCALS", "END_LOCALS", 
                                    "BEGIN_BODY", "END_BODY", "INTEGER", "ARRAY", "OF", "IF", "THEN", "ENDIF", "ELSE", 
                                    "WHILE", "FOR", "DO", "BEGINLOOP", "ENDLOOP", "CONTINUE", "READ", "WRITE", "TRUE", 
                                    "FALSE", "SEMICOLON", "COLON", "COMMA", "L_PAREN", "R_PAREN", 
                                    "L_SQUARE_BRACKET", "R_SQUARE_BRACKET", "ASSIGN", "RETURN", "ENUM", "IDENT",
                                    "NUMBER", "PLUS", "MINUS", "MULT", "DIV", "MOD", "LT", "LTE", "GT", "GTE",
                                    "EQ", "NEQ", "NOT", "AND", "OR", "ASSIGN",
                                    "Program", "Function", "Dec", "Stmt", "Declaration", "Ident", "Statement", "E_BRANCH", 
                                    "Bool_Expr", "Relation_And_Expr", "Relation_Expr", "RE_branch", "Comp", "Expression", 
                                    "Multiplicative_Expr", "Term", "Expr_Loop", "Var", "Identifier"}
    void yyerror(const char *msg);
    int yylex();
    std::string new_temp();
    std::string new_label();
%}

%union{
    int num;
    char* ident;
    struct S {
        char* code;
    } statement;
    struct E {
        char* place;
        char* code;
        bool arr;
    } expression;
}

%start Program

%token <num> NUMBER
%token <ident> IDENT
%type <expression>  Function Dec Declaration Ident E_BRANCH 
                    Bool_Expr Relation_And_Expr Relation_Expr RE_branch Comp 
                    Expression Multiplicative_Expr Term Expr_Loop Var Identifier
%type <statement> Statement Stmt


%token  FUNCTION BEGIN_PARAMS END_PARAMS BEGIN_LOCALS END_LOCALS BEGIN_BODY END_BODY
        BEGINLOOP ENDLOOP SEMICOLON RETURN ENUM
%token COLON INTEGER COMMA ARRAY L_SQUARE_BRACKET R_SQUARE_BRACKET L_PAREN R_PAREN
%token IF ELSE THEN CONTINUE ENDIF OF READ WRITE DO WHILE TRUE FALSE
%left PLUS MINUS
%left MULT DIV MOD
%left LT LTE GT GTE EQ NEQ
%right NOT
%left AND
%left OR
%right ASSIGN

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
                        {
                            std::string temp;
                            temp.append($1.code);
                            temp.append($3.code);
                            $$.code = strdup(temp.c_str());
                            $$.place = strdup("");
                        }
                        |%empty                      
                        {
                            $$.place = strdup("");
                            $$.code = strdup("");
                        }
                        ;

Stmt:                   Statement SEMICOLON Stmt        
                        {/*TODO*/}
                        | %empty           
                        {
                            $$.place = strdup("");
                            $$.code = strdup("");
                        }
                        ;

Declaration:            Ident COLON INTEGER             
                        {} 
                        | Ident COLON  ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER        
                        {/*TODO*/} 
                        | Ident COLON ENUM L_PAREN Ident R_PAREN                                
                        {/*TODO*/}
                        ;

Ident:                  Identifier
                        {/*TODO*/} 
                        | Identifier COMMA Ident             
                        {/*TODO*/}
                        ;

Statement:              Var ASSIGN Expression           
                        {
                            std::string temp;
                            temp += "= ";
                            temp.append($1.place);
                            temp += ", ";
                            temp.append($3.place);
                            $$.place = strdup("");
                            $$.code = strdup("");
                        }
                        |IF Bool_Expr THEN Stmt ENDIF    
                        {
                            std::string labelt = new_label();
                            std::string labelf = new_label();
                            std::string temp;
                            temp.append($2.code);
                            temp += "?:= " + labelt + ", ";
                            temp.append($2.place);
                            temp.append("\n");
                            temp += ":= " + labelf + "\n";
                            temp += ": " + labelt + "\n";
                            temp.append($4.code);
                            temp += ": " + labelf + "\n";
                            $$.place = strdup("");
                            $$.code = strdup("");
                        } 
                        |IF Bool_Expr THEN Stmt ELSE Stmt ENDIF        
                        {
                            std::string labelt = new_label();
                            std::string labelf = new_label();
                            std::string temp;
                            temp.append($2.code);
                            temp += "?:= " + labelt + ", ";
                            temp.append($2.place);
                            temp.append("\n");
                            temp += ":= " + labelf + "\n";
                            temp += ": " + labelt + "\n";
                            temp.append($4.code);
                            temp += ": " + labelf + "\n";
                            temp.append($6.code);
                            $$.place = strdup("");
                            $$.code = strdup("");
                        }
                        |WHILE Bool_Expr BEGINLOOP Stmt ENDLOOP      
                        {
                            //TODO
                        }
                        |DO BEGINLOOP Stmt ENDLOOP WHILE Bool_Expr       
                        {/*TODO*/}
                        |READ E_BRANCH              
                        {
                            std::string temp;
                            std::string dst = new_temp();
                            if($2.arr){
                                temp += ".[]< " + dst + ", ";
                                //index
                                temp.append("\n");;
                            }
                            else{
                                temp += ".[]< " + dst + "\n";
                            }

                            $$.place = strdup("");
                            $$.code = strdup("");
                        }
                        |WRITE E_BRANCH              
                        {
                            std::string temp;
                            if($2.arr){
                                temp += ".[]> ";
                                temp.append($2.place);
                                temp += ", ";
                                //index
                                temp.append("\n");;
                            }
                            else{
                                temp += ".[]>" + dst + "\n";
                            }
                            $$.place = strdup("");
                            $$.code = strdup("")
                        }
                        |CONTINUE                        
                        {}
                        |RETURN Expression               
                        {
                            std::string temp = "ret ";
                            temp.append($2.code);}
                        ;
E_BRANCH:               Var COMMA E_BRANCH              
                        {
                            std::string temp;
                            temp.append($1.code);
                            if($1.arr){
                                temp.append(".[]| ");
                            }
                            else{
                                temp.append(".| ");
                            }
                            temp.append($1.place);
                            temp.append("\n");
                            temp.append($3.code);
                            $$.code = strdup(temp.c_str());
                            $$.place = strdup("");
                        } 
                        | Var                     
                        {
                            std::string temp;
                            temp.append($1.code);
                            if($1.arr){
                                temp.append(".[]| ");
                            }
                            else{
                                temp.append(".| ");
                            }
                            temp.append($1.place);
                            temp.append("\n");
                            $$.place = strdup("");
                            $$.code = strdup("");
                        } 
                        ;
Bool_Expr:              Relation_And_Expr OR Bool_Expr        
                        {
                            std::string temp;
                            std::string dst = new_temp();
                            temp.append($1.code);
                            temp.append($3.code);
                            temp += ". " + dst + "\n";
                            temp += "|| " + dst + "\n";
                            temp.append($1.place);
                            temp.append(", ");
                            temp.append($3.place);
                            temp.append("\n");
                            $$.code = strdup(temp.c_str());
                            $$.place = strdup(dst.c_str());
                        } 
                        | Relation_And_Expr                      
                        {
                            $$.place = strdup($1.code);
                            $$.code = strdup($1.place);
                        }
                        ;
Relation_And_Expr:      Relation_Expr AND Relation_And_Expr            
                        {
                            std::string temp;
                            std::string dst = new_temp();
                            temp.append($1.code);
                            temp.append($3.code);
                            temp += ". " + dst + "\n";
                            temp += "&& " + dst + "\n";
                            temp.append($1.place);
                            temp.append(", ");
                            temp.append($3.place);
                            temp.append("\n");
                            $$.code = strdup(temp.c_str());
                            $$.place = strdup(dst.c_str());
                        } 
                        | Relation_Expr                    
                        {
                            $$.place = strdup($1.code);
                            $$.code = strdup($1.place);
                        }
                        ;
Relation_Expr:          RE_branch                       
                        {
                            $$.code = strdup($1.code);
                            $$.place = strdup($1.place);
                        } 
                        | NOT RE_branch                 
                        {
                            std::string temp;
                            std::string dst = new_temp();
                            temp.append($2.code);
                            temp += ". " + dst + "\n";
                            temp += "! " + dst + ", ";
                            temp.append($2.place);
                            temp.append("\n");
                            $$.code = strdup(temp.c_str());
                            $$.place = strdup(dst.c_str());
                        }
                        ;
RE_branch:              Expression Comp Expression
                        {
                            std::string dst = new_temp();
                            std::string temp;
                            temp.append($1.code);
                            temp.append($3.code);
                            temp = temp + ". " + dst + "\n" + $2.place + dst + ", " + $1.place + ", " + $3.place + "\n";
                            $$.code = strdup(temp.c_str());
                            $$.place = strdup(dst.c_str()); 
                        } 
                        | TRUE                          
                        {
                            std::string temp;
                            temp.append("1");
                            $$.code = strdup("");
                            $$.place = strdup(dst.c_str());
                        } 
                        | FALSE                         
                        {
                            std::string temp;
                            temp.append("0");
                            $$.code = strdup("");
                            $$.place = strdup(dst.c_str());
                        } 
                        | L_PAREN Bool_Expr R_PAREN                          
                        {
                            $$.code = strdup($2.code);
                            $$.place = strdup($2.place);
                        }
                        ;
Comp:                   EQ                              
                        {
                            $$.code = strdup("");
                            $$.place = strdup("== ";)
                        }
                        |NEQ                            
                        {
                            $$.code = strdup("");
                            $$.place = strdup("!= ";)
                        }
                        |LT                             
                        {
                            $$.code = strdup("");
                            $$.place = strdup("< ";)
                        }
                        |GT                             
                        {
                            $$.code = strdup("");
                            $$.place = strdup("> ";)
                        }
                        |LTE                            
                        {
                            $$.code = strdup("");
                            $$.place = strdup("<= ";)
                        }
                        |GTE                            
                        {
                            $$.code = strdup("");
                            $$.place = strdup(">= ";)
                        }
                        ;

Expression:             Multiplicative_Expr MINUS Expression    
                        {
                            std::string temp;
                            std::string dst = new_temp();
                            temp.append($1.code);
                            temp.append($3.code);
                            temp += ". " + dst + "\n";
                            temp += "- " + dst + ", ";
                            temp.append($1.place);
                            temp += ", ";
                            temp.append($3.place);
                            temp += "\n";
                            $$.code = strdup(temp.c_str());
                            $$.place = strdup(dst.c_str());
                        } 
                        | Multiplicative_Expr PLUS Expression   
                        {
                            std::string temp;
                            std::string dst = new_temp();
                            temp.append($1.code);
                            temp.append($3.code);
                            temp += ". " + dst + "\n";
                            temp += "+ " + dst + ", ";
                            temp.append($1.place);
                            temp += ", ";
                            temp.append($3.place);
                            temp += "\n";
                            $$.code = strdup(temp.c_str());
                            $$.place = strdup(dst.c_str());
                        } 
                        | Multiplicative_Expr   
                        {
                            $$.code = strdup($1.code);
                            $$.place = strdup($1.place);
                        } 
                        ;
Multiplicative_Expr:    Term MOD Multiplicative_Expr              
                        {
                            std::string temp;
                            std::string dst = new_temp();
                            temp.append($1.code);
                            temp.append($3.code);
                            temp.append(". ");
                            temp.append(dst);
                            temp.append("\n");
                            temp += "% " + dst + ", ";
                            temp.append($1.place);
                            temp += ", ";
                            temp.append($3.place);
                            temp += "\n";
                            $$.code = strdup(temp.c_str());
                            $$.place = strdup(dst.c_str());
                        } 
                        | Term DIV Multiplicative_Expr            
                        {
                            std::string temp;
                            std::string dst = new_temp();
                            temp.append($1.code);
                            temp.append($3.code);
                            temp.append(". ");
                            temp.append(dst);
                            temp.append("\n");
                            temp += "/ " + dst + ", ";
                            temp.append($1.place);
                            temp += ", ";
                            temp.append($3.place);
                            temp += "\n";
                            $$.code = strdup(temp.c_str());
                            $$.place = strdup(dst.c_str());
                        } 
                        | Term MULT Multiplicative_Expr           
                        {
                            std::string temp;
                            std::string dst = new_temp();
                            temp.append($1.code);
                            temp.append($3.code);
                            temp.append(". ");
                            temp.append(dst);
                            temp.append("\n");
                            temp += "* " + dst + ", ";
                            temp.append($1.place);
                            temp += ", ";
                            temp.append($3.place);
                            temp += "\n";
                            $$.code = strdup(temp.c_str());
                            $$.place = strdup(dst.c_str());
                        } 
                        | Term                      
                        {
                            $$.code = strdup($1.code);
                            $$.place = strdup($1.place);
                        }
                        ;

Term:                   Var                             
                        {
                            std::string dst = new_temp();
                            std::string temp;
                            if($1.arr){
                                temp.append($1.code);
                                temp.append(". ");
                                temp.append(dst);
                                temp.append("\n");
                                temp += "=[] " + dst + ", ";
                                temp.append($1.place);
                                temp.append("\n");
                            }
                            else {
                                temp.append(". ");
                                temp.append(dst);
                                temp.append("\n");
                                temp = temp + "= " + dst + ", ";
                                temp.append($1.place);
                                temp.append("\n");
                                temp.append($1.code);
                            }
                            if(varTemp.find($1.place) != varTemp.end()){
                                varTemp[$1.place] = dst;
                            }
                            $$.code = strdup(temp.c_str());
                            $$.place = strdup(dst.c_str());
                        } 
                        | NUMBER                        
                        {
                            std::string dst = new_temp();
                            std::string temp;
                            temp.append(". ");
                            temp.append(dst);
                            temp.append("\n");
                            temp = temp + "= " + dst + ", " + std::to_string($1) + "\n";
                            $$.code = strdup(temp.c_str());
                            $$.place = strdup(dst.c_str());     
                        } 
                        | L_PAREN Expression R_PAREN    
                        {
                            $$.code = strdup($2.code);
                            $$.place = strdup($2.place);
                        }
                        | MINUS Var                             
                        {
                            std::string dst = new_temp();
                            std::string temp;
                            if($2.arr){
                                temp.append($2.code);
                                temp.append(". ");
                                temp.append(dst);
                                temp.append("\n");
                                temp += "=[] " + dst + ", ";
                                temp.append($2.place);
                                temp.append("\n");
                            }
                            else {
                                temp.append(". ");
                                temp.append(dst);
                                temp.append("\n");
                                temp = temp + "= " + dst + ", ";
                                temp.append($2.place);
                                temp.append("\n");
                                temp.append($2.code);
                            }
                            if(varTemp.find($2.place) != varTemp.end()){
                                varTemp[$2.place] = dst;
                            }
                            temp += "* " + dst + ", " + dst + ", -1\n";
                            $$.code = strdup(temp.c_str());
                            $$.place = strdup(dst.c_str());
                        } 
                        | MINUS NUMBER                        
                        {
                            std::string dst = new_temp();
                            std::string temp;
                            temp.append(". ");
                            temp.append(dst);
                            temp.append("\n");
                            temp = temp + "= " + dst + ", " + std::to_string($2) + "\n";
                            $$.code = strdup(temp.c_str());
                            $$.place = strdup(dst.c_str());
                        } 
                        | MINUS L_PAREN Expression R_PAREN    
                        {
                            std::string temp; 
                            temp.append($3.code);
                            temp.append("* ");
                            temp.append($3.place);
                            temp.append(", ");
                            temp.append($3.place);
                            temp.append(", -1\n");
                            $$.code = strdup(temp.c_str());
                            $$.place = strdup($3.place);
                        }
                        | Identifier L_PAREN Expr_Loop R_PAREN    
                        {
                            std::string temp;
                            std::string func = $1.place;
                            if(funcs.find(func) == funcs.end()) {
                                printf("Calling undeclared function %s. \n", func.c_str());
                            }
                            std::string dst = new_temp();
                            temp.append($3.code);
                            temp += ". " + dst + "\ncall ";
                            temp.append($1.place);
                            temp ++ ", " + dst + "\n";
                            $$.code = strdup(temp.c_str());
                            $$.place = strdup(dst.c_str());
                        }
                        ;
Expr_Loop:              Expression
                        {
                            std::string temp;
                            temp.append($1.code);
                            temp.append("param ");
                            temp.append($1.place);
                            temp.append("\n");
                            $$.code = strdup(temp.c_str());
                            $$.place = strdup("");
                        } 
                        | Expression COMMA Expr_Loop
                        {
                            std::string temp;
                            temp.append($1.code);
                            temp.append("param ");
                            temp.append($1.place);
                            temp.append("\n");
                            temp.append($3.code);
                            $$.code = strdup(temp.c_str());
                            $$.place = strdup("");
                        }
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
                        {
                            $$.code = strdup("");
                            $$.place = strdup($1.place);
                        }
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

    printf("%s on line %d at char %d at symbol \"%s\"\n", msg, yylineno, curPos, yytext);
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