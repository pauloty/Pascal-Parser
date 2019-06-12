/* Definições */
%{
#include "y.tab.h"
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#define NUM_RESERVED_WORDS 17
#define TABLE_SIZE 137

int yylex();
void yyerror(char *);

char **reserved_words;
int check_id(char **);
char *str_read(FILE *);
int hash(char *);

int nlinha = 1;
int yywrap (void);

void init();
//void yyerror (char *s);
//void check_id(char **, char *);
//int yylex();

%}
    /* Estado criado para comentários */
%x COMMENT
    /* Expressões regulares utilizadas */
white_space                             [ \t]*
digit                                   [0-9]
alpha                                   [a-zA-Z]
alpha_num                               ({alpha}|{digit})
identifier                              {alpha}({alpha}|{digit})*
ninteger                                {digit}+
nreal                                   {digit}+\.{digit}+

/* Regras*/
%%

	int contador_comment = 0;

    /* Start condition que emprega em comentarios apenas as regras especificadas abaixo */
"{"                                     BEGIN(COMMENT);
<COMMENT>"{"							{++contador_comment;}
<COMMENT>[^}{\n]+                        /* não faz nada */
<COMMENT>\n                             fprintf(stderr, "Erro encontrado - Comentario nao fechado");nlinha += 1;BEGIN(INITIAL);
<COMMENT>"}"                            {
                                            if(contador_comment)
                                               --contador_comment; 
                                            else
                                                BEGIN(INITIAL);
                                        }


    /* Par regex/ação */
{ninteger}                              {
                                            //fprintf( stderr, " [ninteger:%d]", yylval.ival = atoi(yytext) ); 
                                            printf(" [ninteger:%d]", yylval.ival = atoi(yytext) );
					                        return ninteger;
                                        } 

{nreal}                                 {
                                            //fprintf( stderr, " [nreal:%d]", yylval.fval = atoi(yytext) ); 
                                            printf(" [nreal:%f]", yylval.fval = atoi(yytext) ); 
					                        return nreal;
                                        } 


{identifier}                            {
                                            return check_id(reserved_words);
                                        }

(=|:=|<=|>=|<>|>|<)                     {
                                            //fprintf( stderr, " [%s:%s]",yytext, yytext); 
                                            printf(" [%s:%s]",yytext, yytext); 
					                        return *yytext;
                                        }

[*/+\-,^.;:()\[\]]                      {
                                            //fprintf( stderr, " [%s:%s]",yytext, yytext); 
                                            printf(" [%s:%s]",yytext, yytext); 
					                        return yytext[0];
                                        }

{white_space}                           /* não faz nada */

\n                                      {nlinha += 1;}

{alpha}@|({alpha}|{digit})+             {yyerror("Erro lexico encontrado - Identificador mal formado");}

{digit}+\.{alpha}+{digit}*              {yyerror("Erro lexico encontrado - Numero mal formado");}

{digit}+\.{digit}*{alpha}*              {yyerror("Erro lexico encontrado - Numero mal formado");}

{digit}+\.{digit}*@{alpha}*             {yyerror("Erro lexico encontrado - Numero mal formado");}

{digit}+\.{digit}*\.{digit}*            {yyerror("Erro lexico encontrado - Numero mal formado");}

.                                       {yyerror("Erro encontrado - Simbolo nao pertencente a linguagem");}


%%
/* Código */

int yywrap (void) 
{
    return 1;
}
 
int hash(char *str)
{
    int i = 0, char_sum = 0;

    do {
        char_sum += str[i];
        i++;
    } while (str[i] != '\0');

    return char_sum % TABLE_SIZE;
}

char *str_read(FILE *fp)
{
    int i = 0;
    char c;
    char *str = NULL;
    
    do {
        fscanf(fp, "%c", &c);
        str = (char *) realloc(str, sizeof(char)*(i+1));
        str[i] = c;
        i++;
    } while (c != 10);
    str[i-1] = '\0';
    
    return str;
}

int check_id(char **reserved_words)
{
    int pos = hash(yytext);

    if (reserved_words[pos] != NULL && !strcmp(reserved_words[pos], yytext)){
        printf("%s - %s\n", yytext, yytext);
        
        if(strcmp(yytext, "end"))
            return END;
        else if(strcmp(yytext, "read"))
            return READ;
        else if(strcmp(yytext, "write"))
            return WRITE;
        else if(strcmp(yytext, "for"))
            return FOR;
        else if(strcmp(yytext, "to"))
            return TO;
        else if(strcmp(yytext, "begin"))
            return begin;
        else if(strcmp(yytext, "const"))
            return CONST;
        else if(strcmp(yytext, "do"))
            return DO;
        else if(strcmp(yytext, "else"))
            return ELSE;
        else if(strcmp(yytext, "if"))
            return IF;
        else if(strcmp(yytext, "procedure"))
            return PROCEDURE;
        else if(strcmp(yytext, "program"))
            return PROGRAM;
        else if(strcmp(yytext, "then"))
            return THEN;
        else if(strcmp(yytext, "var"))
            return VAR;
        else if(strcmp(yytext, "while"))
            return WHILE;
        else if(strcmp(yytext, "integer"))
            return INTEGER;
        else if(strcmp(yytext, "real"))
            return REAL;

    }
    else if(yyleng >= 14)
        yyerror("Erro lexico encontrado - Identificador muito grande");
    else{
        printf("%s - IDENTIFIER\n", yytext);
        return identifier;
    }
}


void init(){
        
    FILE *fp = NULL;
    char *word;
    int i, j = 1, pos;

    fp = fopen("words.txt", "r");

    reserved_words = (char **) malloc(sizeof(char *) * TABLE_SIZE);
    for (i = 0; i < TABLE_SIZE; i++) reserved_words[i] = NULL;

    for(i = 0; i < NUM_RESERVED_WORDS; i++){
        word = str_read(fp);
        pos = hash(word);
        reserved_words[pos] = word;
        word = NULL;
    }
}
