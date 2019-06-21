/* Definições */
%{
#include <stdlib.h>
#include <stdio.h>

void init();

int yylex();
void yyerror(char *);
%}

/* Tipos que o analisador léxico pode retornar */

%union {
    int ival;
    float fval;
    char* id;
}

%start programa

/* Token para os numeros */
%token <ival> ninteger;
%token <fval> nreal;

/* Token para os identificadores */
%token <id> identifier;

/* Tokens reservados */
%token END
%token READ
%token WRITE
%token FOR
%token TO
%token begin
%token CONST
%token DO
%token ELSE
%token IF
%token PROCEDURE
%token PROGRAM
%token THEN
%token VAR
%token WHILE
%token INTEGER
%token REAL

/* Definicoes adicionais */
//%left '+' '-'
//%left '*' '/'
//%nonassoc UMINUS
//%nonassoc if
//%nonassoc else
%%

programa    : PROGRAM identifier ';' corpo '.'
            ;

corpo   : dc begin comandos END
        ;

dc      : dc_c dc_v dc_p
        ;

dc_c    : CONST identifier '=' numero ';' dc_c
        | /* EMPTY */        
        ;

dc_v    : VAR variaveis ':' tipo_var ';' dc_v
        | /* EMPTY */ 
        ;

tipo_var    : REAL 
            | INTEGER
            ;

variaveis   : identifier mais_var
            ;

mais_var    : ',' variaveis  
            | /* EMPTY */  
            ; 

dc_p    : PROCEDURE identifier parametros ';' corpo_p dc_p
        | /* EMPTY */ 
        ;

parametros      : '(' lista_par ')'
                | /* EMPTY */ 
                ;

lista_par   : variaveis ':' tipo_var mais_par
            ;

mais_par    : ';' lista_par 
            | /* EMPTY */ 
            ;

corpo_p     : dc_loc begin comandos END ';'
            ;

dc_loc      : dc_v
            ;

lista_arg   : '(' argumentos ')'
            | /* EMPTY */  
            ;

argumentos      : identifier mais_ident
                ;

mais_ident      : ';' argumentos
                | /* EMPTY */ 
                ;

pfalsa      : ELSE cmd
            | /* EMPTY */ 
            ;

comandos    : cmd ';' comandos 
            | /* EMPTY */ 
            ;

cmd     : READ '(' variaveis ')' 
        | WRITE '(' variaveis ')' 
        | WHILE '(' condicao ')' DO cmd
        | IF condicao THEN cmd pfalsa
        | identifier ":=" expressao
        | identifier lista_arg 
        | begin comandos END
        ;

condicao    : expressao relacao expressao
            ;

relacao     : '=' 
            | "<>" 
            | ">=" 
            | "<=" 
            | ">" 
            | "<"
            ;

expressao   : termo outros_termos
            ;

op_un   : '+' 
        | '-' 
        | /* EMPTY */ 
        ;

outros_termos   : op_ad termo outros_termos 
                | /* EMPTY */ 
                ;

op_ad   : '+'
        | '-'
        ;

termo   : op_un fator mais_fatores
        ;

mais_fatores    : op_mul fator mais_fatores 
                | /* EMPTY */ 
                ;

op_mul      : "*" 
            | "/"
            ;

fator   : identifier 
        | numero
        | '(' expressao ')'
        ;

numero      : ninteger 
            | nreal
            ;

%%
void yyerror (char *s) 
{
    //fprintf(stderr, "\nERROR, LINE %d: %s\n", yylineno, s); 
    fprintf(stderr, "\n%s\n", s); 
} 

int main (void) 
{
    init();
    
    yyparse();

    //free(reserved_words);
    //fclose(fp);

    return 0;
}