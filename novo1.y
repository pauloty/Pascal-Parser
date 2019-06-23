/* Definições */
%{
#include <stdlib.h>
#include <stdio.h>

void init();
int yylex();
void yyerror(char *);

int nlinha = 1;

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
%token ASSIGNMENT
%token LE
%token GE
%token NOTEQUAL
%token STAR
%token EQUAL
%token GREATER
%token LESS
%token PLUS
%token MINUS
%token DIVIDE
%token COMMA
%token HIGH
%token DOT
%token SEMICOLON
%token COLON
%token OPENCB
%token CLOSECB
%token OPENSB
%token CLOSESB
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
%right THEN ELSE

%%

programa    : PROGRAM identifier SEMICOLON corpo DOT
            | error SEMICOLON
            ;

corpo   : dc begin comandos END
        ;

dc      : dc_c dc_v dc_p
        ;

dc_c    : CONST identifier EQUAL numero SEMICOLON dc_c
        | /* EMPTY */        
        ;

dc_v    : VAR variaveis COLON tipo_var SEMICOLON dc_v
        | /* EMPTY */ 
        ;

tipo_var    : REAL 
            | INTEGER
            ;

variaveis   : identifier mais_var
            ;

mais_var    : COMMA variaveis  
            | /* EMPTY */  
            ; 

dc_p    : PROCEDURE identifier parametros SEMICOLON corpo_p dc_p
        | /* EMPTY */ 
        ;

parametros      : OPENCB lista_par CLOSECB
                | /* EMPTY */ 
                ;

lista_par   : variaveis COLON tipo_var mais_par
            ;

mais_par    : SEMICOLON lista_par 
            | /* EMPTY */ 
            ;

corpo_p     : dc_loc begin comandos END SEMICOLON
            ;

dc_loc      : dc_v
            ;

lista_arg   : OPENCB argumentos CLOSECB
            | /* EMPTY */  
            ;

argumentos      : identifier mais_ident
                ;

mais_ident      : SEMICOLON argumentos
                | /* EMPTY */ 
                ;
/*
pfalsa      : ELSE cmd
            | /* EMPTY 
            ;*/

comandos    : cmd SEMICOLON comandos 
            | /* EMPTY */ 
            ;

cmd     : READ OPENCB variaveis CLOSECB
        | WRITE OPENCB variaveis CLOSECB
        | WHILE OPENCB condicao CLOSECB DO cmd
        | IF condicao THEN cmd
        | IF condicao THEN cmd ELSE cmd
        | identifier ASSIGNMENT expressao
        | identifier lista_arg 
        | begin comandos END
        ;

condicao    : expressao relacao expressao
            ;

relacao     : EQUAL
            | NOTEQUAL 
            | GE 
            | LE 
            | GREATER
            | LESS
            ;

expressao   : termo outros_termos
            ;

op_un   : PLUS 
        | MINUS 
        | /* EMPTY */ 
        ;

outros_termos   : op_ad termo outros_termos 
                | /* EMPTY */ 
                ;

op_ad   : PLUS
        | MINUS
        ;

termo   : op_un fator mais_fatores
        ;

mais_fatores    : op_mul fator mais_fatores 
                | /* EMPTY */ 
                ;

op_mul      : STAR 
            | DIVIDE
            ;

fator   : identifier 
        | numero
        | OPENCB expressao CLOSECB
        ;

numero      : ninteger 
            | nreal
            ;

%%
void yyerror (char *s) 
{
    fprintf(stderr, " // Linha %d // %s\n", nlinha, s); 
} 

int main (void) 
{
    init();
    
    yyparse();

    //free(reserved_words);
    //fclose(fp);

    return 0;
}
