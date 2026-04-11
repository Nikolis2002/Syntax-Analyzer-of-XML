%option noyywrap
%{
    #include "xmlBison.tab.h" //the bison header file, it also includes the helper header
    #include<stdio.h>
    #include<ctype.h>
    #define YY_DECL int yylex() //declaring the yylex
    void print_err_program(FILE *yyin, int line);
    void yyerror_at_line(int line, const char* msg); //custom error function
%}
/*our conditions*/
%s COMMENT
%s WIDTH
%s HEIGHT
%s ANDROID
%s PADDING
/*the startinng tokens*/
START_L "<LinearLayout" 
END_L "</LinearLayout>"
R_START "<RelativeLayout"
END_R "</RelativeLayout>"
T_START "<TextView"
IMAG_START "<ImageView"
BUT_START "<Button"
RADIOG_START "<RadioGroup"
RADIOG_END "</RadioGroup>"
RADIOB_START "<RadioButton"
B_START "<ProgressBar"
ELEM_END ">"
ATR_END "/>"

%%
<INITIAL>{START_L} {yylval.strval=strdup(yytext); return LINEAR_START;} /*we make the yylval value equal to yytext and return the correct token*/
<INITIAL>{END_L} {yylval.strval=strdup(yytext); return END_LINEAR;}
<INITIAL>{R_START} {yylval.strval=strdup(yytext); return RELATIVE_START;}
<INITIAL>{END_R} {yylval.strval=strdup(yytext); return END_RELATIVE;}
<INITIAL>{T_START} {yylval.strval=strdup(yytext); return TEXTVIEW_START;}
<INITIAL>{IMAG_START} {yylval.strval=strdup(yytext); return IMAGEVIEW_START;}
<INITIAL>{BUT_START} {yylval.strval=strdup(yytext); return BUTTON_START;}
<INITIAL>{RADIOG_START} {yylval.strval=strdup(yytext); return RADIOGROUP_START;}
<INITIAL>{RADIOG_END} {yylval.strval=strdup(yytext); return RADIOGROUP_END;}
<INITIAL>{RADIOB_START} {yylval.strval=strdup(yytext); return RADIOBUTTON_START;}
<INITIAL>{B_START} {yylval.strval=strdup(yytext); return BAR_START;}

<INITIAL>android: {BEGIN(ANDROID);} /*finds the first android pattern*/

<ANDROID>id=\"([^\n\"]+)\"  { /*in our flex code the strings we consider right dont have the newline character*/
    char *tmp=strdup(yytext+strlen("id=\"")); /*we move the pointer in the start of the string*/
    tmp[strlen(tmp) - 1] = '\0';/*we make the last " /0 so we only have the inside string*/
    yylval.strval=strdup(tmp); /*we copy the value to yylval*/
    BEGIN(INITIAL); return ANDROID_ID;}
<ANDROID>layout_width=\" { yylval.strval=strdup(yytext); BEGIN(WIDTH);} /*same process as above*/
<ANDROID>layout_height=\" { yylval.strval=strdup(yytext); BEGIN(HEIGHT);}
<ANDROID>text=\"[^\n\"]+\" {yylval.strval=strdup(yytext); BEGIN(INITIAL); return ANDROID_TEXT;}
<ANDROID>textColor=\"[^\n\"]+\" {yylval.strval=strdup(yytext); BEGIN(INITIAL); return ANDROID_TEXT_COLOR;}
<ANDROID>progress=\"[1-9][0-9]*\" {char *tmp=strdup(yytext+strlen("progress:\"")); 
                              tmp[strlen(tmp) - 1] = '\0';
                              yylval.strval=strdup(tmp);
                              BEGIN(INITIAL);return ANDROID_PROGRESS;}

<ANDROID>max=\"[1-9][0-9]*\" {
                            char *tmp=strdup(yytext+strlen("max=\"")); 
                            tmp[strlen(tmp) - 1] = '\0';
                           yylval.strval=strdup(tmp);
                            BEGIN(INITIAL); return ANDROID_MAX;}


<ANDROID>checkedButton=\"[^\n\"]+\" {char *tmp=strdup(yytext+strlen("checkedButton=\""));
                                    tmp[strlen(tmp) - 1] = '\0';
                                    yylval.strval=strdup(tmp); BEGIN(INITIAL);
                                    return ANDROID_CHECKBUTTON;} 

<ANDROID>orientation=\"[^\n\"]+\" {BEGIN(INITIAL); return ANDROID_ORIENTATION;}
<ANDROID>padding=\" {BEGIN(PADDING); }
<ANDROID>src=\"[^\n\"]+\" {BEGIN(INITIAL); return ANDROID_SRC;}

<ANDROID>count=\"[1-9][0-9]*\" { char *tmp=strdup(yytext+strlen("count=\"")); 
                            tmp[strlen(tmp) - 1] = '\0';
                            yylval.strval=strdup(tmp);
                            BEGIN(INITIAL); return ANDROID_COUNT;}

<ANDROID>[^\"]+ {yylval.strval=strdup(yytext); return UNDEFINED;} /*we handle more carefully the wrong input*/

<WIDTH>(wrap_content|match_parent|[1-9][0-9]*)\" {yylval.strval=strdup(yytext); BEGIN(INITIAL); return ANDROID_LAYOUT_WIDTH; } /*normal output*/
<WIDTH>[^\"]+ {yylval.strval=strdup(yytext);return ANDROID_LAYOUT_ERROR;} /*if it an error it retuens a special error token to print a correct error message*/

<HEIGHT>(wrap_content|match_parent|[1-9][0-9]*)\" {yylval.strval=strdup(yytext); BEGIN(INITIAL); return ANDROID_LAYOUT_HEIGHT; } /*same as above*/
<HEIGHT>. {yylval.strval=strdup(yytext); return ANDROID_LAYOUT_ERROR;}

<PADDING>([1-9][0-9]*)\" {yylval.strval=strdup(yytext); BEGIN(INITIAL); return ANDROID_PADDING; }
<PADDING>[^\"]+ {yylval.strval=strdup(yytext); return PADDING_ERROR;}

<INITIAL>"<!--" {BEGIN(COMMENT);} /*the condtion that finds the comments*/
<COMMENT>--[^>] {yyerror_at_line(yylineno,"Encountered \"--\" inside the comment");}/*first error --*/
<COMMENT>-{1}[>] {yyerror_at_line(yylineno,"incorrect comment form");}/*->second error*/
<COMMENT><<EOF>> {yyerror_at_line(yylineno,"incorrect comment form-comment doesnt finish");} /*if he doesnt close the comment its ann error*/
<COMMENT>. {/*ignoring the comment*/} 
<COMMENT>"-->" {BEGIN(INITIAL);} /*end the commennt*/
<INITIAL>{ELEM_END} {yylval.strval=strdup(yytext); return END_ELEM;}
<INITIAL>{ATR_END} {yylval.strval=strdup(yytext); return END_ATR;}
[\t\f\r" "]+ {} /*ignoring whitespaces*/
[\n] {yylineno++;}
. {return UNDEFINED;} /*f the programm doesnt read any other rules it means that we have encountered an error*/

%%

void yyerror_at_line(int line, const char* msg) { /*special error function that prints the program until the error and the error meassage*/
    print_err_program(yyin,line);
    fprintf(stderr, "\nError on line %d: %s\n", line, msg);
    exit(1); //exits
}




