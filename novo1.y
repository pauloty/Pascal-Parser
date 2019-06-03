/* Definições */
%{
#include <stdlib.h>
#include <stdio.h>

void yyerror(char *);
char **reserved_words;
void check_id(char **);
char *str_read(FILE *);
int hash(char *);
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
%token end
%token read
%token write
%token for
%token to
%token begin
%token const
%token do
%token else
%token if
%token procedure
%token program
%token then
%token var
%token while
%token integer
%token real

%%

programa    : program identifier ';' corpo '.'
            ;

corpo   : dc begin comandos end
        ;

dc      : dc_c dc_v dc_p
        ;

dc_c    : const identifier '=' numero ';' dc_c
        ;

dc_v    : var variaveis ':' tipo_var ';' dc_v
        ;

tipo_var    : real 
            | integer
            ;

variaveis   : identifier mais_var
            ;

mais_var    : ',' variaveis   
            ; 

dc_p    : procedure identifier parametros ';' corpo_p dc_p
        ;

parametros      : '(' lista_par ')'
                ;

lista_par   : variaveis ':' tipo_var mais_par
            ;

mais_par    : ';' lista_par 
            ;

corpo_p     : dc_loc begin comandos end ';'
            ;

dc_loc      : dc_v
            ;

lista_arg   : '(' argumentos ')' 
            ;

argumentos      : identifier mais_ident
                ;

mais_ident      : ';' argumentos
                ;

pfalsa      : else cmd
            ;

comandos    : cmd ';' comandos 
            ;


cmd     : read '(' variaveis ')' 
        | write '(' variaveis ')' 
        | while '(' condicao ')' do cmd
        | if condicao then cmd pfalsa
        | identifier ":=" expressao
        | identifier lista_arg 
        | begin comandos end
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
        ;

outros_termos   : op_ad termo outros_termos 
                ;

op_ad   : '+'
        | '-'
        ;

termo   : op_un fator mais_fatores
        ;

mais_fatores    : op_mul fator mais_fatores 
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
    fprintf(stderr, "\nERROR, LINE %d: %s\n", yylineno, s); 
} 

int main (void) 
{
    yyparse();
}


