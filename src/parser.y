%{
    #include<stdio.h>
    #include<stdlib.h>//including all necessary headers and declaring all nnecessary extern variables and fuctions
    #include<string.h>
    #include"helper.h" //our own header that has fuctions that help the main programm
    extern int yylex();
    extern int yyparse();
    extern FILE* yyin;
    extern int yylineno;
    void yyerror(const char* s);
    void print_error();
    void printer();

    int id_size=0;
    int radio_id_size=0;
    int line_button=0; //its a placeholder for the line of checked_Button inn case the checked_buttonn is equal to anny of the anndroid_ids
    int line_radioButton=0; //same principle for android_count
    int max=100; //default max
    int progress=0; 
    char* error_message; //the message that we will prinnt in case it has an error
    char **arr; //the array fo the android_id's 
    char **radio_arr; //similar but only for the radiogroup android_ids
    char* checkedButton=NULL;
    int radio_count=0; //a couter that counts the number of radio buttons
    int radio_checker=0; //placeholder for android_count value
    int mode=0; //a mode for prinnting the correct message if modes:0,1
    char* pos_error="near at the start of the file"; //the position of the error , if evenn the first line is wrong it prints this default message
    
%}
//%define parse.error verbose for debugginng



%union /*union has only one type because, we atoi the integers, so basically the bison code is more respinsible for the checks */
{
    char *strval;
}

//all the tokens, annd some types that we store values
%token<strval> LINEAR_START RELATIVE_START TEXTVIEW_START IMAGEVIEW_START  BUTTON_START RADIOGROUP_START RADIOBUTTON_START BAR_START
%token<strval> ANDROID_ID ANDROID_ORIENTATION ANDROID_LAYOUT_WIDTH ANDROID_LAYOUT_HEIGHT ANDROID_TEXT ANDROID_TEXT_COLOR ANDROID_CHECKBUTTON ANDROID_PADDING ANDROID_SRC;
%token<strval> ANDROID_PROGRESS ANDROID_MAX ANDROID_COUNT 
%token END_LINEAR  END_ELEM END_ATR RADIOGROUP_END END_RELATIVE
%token<strval>  UNDEFINED ANDROID_LAYOUT_ERROR PADDING_ERROR //error_tokens
%type<strval> android_id mad_feats android_orientation android_text text_color android_checkButton android_padding android_src 
%type<strval> android_max android_progress android_count
%start xml

%%
//it is important to clarify that we followed the grammar rules of the give example in the pdf file
xml: linear_layout{} //program cann either start with linear or relative layouts
    |relative_layout{}
    ;

linear_layout: LINEAR_START mad_feats linear_optional END_ELEM linear_layout_attributes END_LINEAR {} 
             ;


linear_layout_attributes: elements 
                        | elements linear_layout_attributes {} //recusrsion beacuse linear layout can have more thann one elements
                        ;
//in the optional elements we basically list all the possible input combinations and UNDEFINNED is the token we return in case on flex rule is activated
//so basically a wrong input annd %empty because the rule is optional
linear_optional: android_id {}
               | android_orientation {}
               | android_id android_orientation {}
               | android_id UNDEFINED{ yyerror("expecting 'android:orientation=(string)'"); YYABORT;}
               | android_orientation android_id {}
               | android_orientation UNDEFINED{yyerror("expecting 'android:id=(string)'"); YYABORT;} //yyeror gets a special strinng to be printed and the we stop the parser
               | UNDEFINED{ yyerror("expecting 'android:orientation=(string)' or 'android:id=(string)'"); YYABORT;} //with non zero value, because the input is wrong
               | %empty{}
               ;

//same logic for relative layout but relative cann also have 0 elements
relative_layout: RELATIVE_START mad_feats relative_optional END_ELEM  END_RELATIVE {}
               | RELATIVE_START mad_feats relative_optional END_ELEM relative_attributes END_RELATIVE {}


relative_attributes: elements 
                   | elements relative_attributes //same recursionn as above


relative_optional: android_id //only android_id is optional 
                 | UNDEFINED{yyerror("expecting 'android:id=(string)'"); YYABORT;}
                 | %empty
                 ;

//all the elements
elements: textview {}
        | imageview {}
        | button {}
        | radiogroup {}
        | linear_layout {}
        | relative_layout {}
        | progress_bar {}
        ;

//similar logic as above ,diffrent grammar rules 
textview: TEXTVIEW_START mad_feats textview_optional android_text END_ATR 
        ;

textview_optional: android_id {}
                 | text_color {}
                 | android_id text_color {}
                 | text_color android_id {}
                 | UNDEFINED{yyerror("expecting 'android:id=(string)' or 'android:textColor=(string)'"); YYABORT;}
                 | android_id UNDEFINED {yyerror("expecting 'android:textColor=(string)'"); YYABORT;}
                 | text_color UNDEFINED {yyerror("expecting 'android:id=(string)'"); YYABORT;}
                 | %empty {}
                 ;

//imageview annd button have the same optional features
imageview: IMAGEVIEW_START mad_feats android_src button_id_optional END_ATR ;

button: BUTTON_START mad_feats android_text button_id_optional END_ATR 
    ;

button_id_optional: android_id 
                  | android_padding
                  | android_id android_padding
                  | android_padding android_id
                  | UNDEFINED{yyerror("expecting 'android:id=(string)' or 'android:padding=(positive intenger)'"); YYABORT;}
                  | android_id UNDEFINED {yyerror("expecting 'android:padding=(positive intenger)'"); YYABORT;}
                  | android_padding UNDEFINED {yyerror("expecting 'android:id=(string)'"); YYABORT;}
                  | %empty
                  ;

radiogroup:RADIOGROUP_START mad_feats android_count radiogroup_optional END_ELEM radiobutton_repeat RADIOGROUP_END {
                                                                                        //in case the check_buttonn doesnt match any radiogroup id values 
                                                                                        if(checkedButton_checker(radio_arr,radio_id_size,checkedButton)==0)
                                                                                            {
                                                                                                yylineno=line_button; //we take the line of check button
                                                                                                mode=1; //make the print mode 1 
                                                                                                yyerror("'android:checkedButton' value is different from 'android:id'");
                                                                                                YYABORT; //raise yyerror and the stop the parser
                                                                                            }
                                                                                            //in case anndroid count isnt equal to the number of radiobutton elements
                                                                                            if(radio_checker!=radio_count)
                                                                                            {
                                                                                                yylineno=line_radioButton; //same as above
                                                                                                mode=1;
                                                                                                yyerror(" 'android:count' is different by the number of 'RadioButton' elements");
                                                                                                YYABORT;
                                                                                            }
                                                                        
                                                                                            radio_count=0; //we make the cout equal to 0 in order to count the next radio buttons
                                                                                            free(radio_arr); //free the space because we dont need the values
                                                                                            *radio_arr=NULL; //make the pointer null
                                                                                            radio_id_size=0; //annd the size of the array equal to 0 again
                                                                                        }
                                                                                        ;


radiogroup_optional:android_id
                  | android_checkButton
                  | android_id  android_checkButton
                  | android_checkButton android_id
                  | UNDEFINED{yyerror("expecting 'android:checkButton=(string)' or 'android:id=(string)'"); YYABORT;}
                  | android_id UNDEFINED {yyerror("expecting 'android:checkButton=(string)'"); YYABORT;}
                  | android_checkButton UNDEFINED {yyerror("expecting 'android:id=(string)'"); YYABORT;}
                  | %empty
                  ;

radiobutton_repeat: radiobutton { radio_count++; }
                  | radiobutton radiobutton_repeat {  radio_count++;} //in this recursion we count the nnumber of radio buttons
                  ;  

radiobutton: RADIOBUTTON_START mad_feats radiobutton_optional android_text END_ATR
           ;

radiobutton_optional: android_id {add_id(&radio_arr,&radio_id_size,$1);} //we add the radiogroup android ids to the array in order to check the rule fo checkbutton
                 | UNDEFINED{yyerror("expecting 'android:id=(string)'"); YYABORT;}
                 | %empty
                 ;

progress_bar: BAR_START mad_feats bar_options END_ATR {if(progress_max(max,progress)==1) //we check the max annd progress rule and do the same as above
                                                        {
                                                          yyerror("the value of 'android:progress'is larger than 'android:max'");
                                                          YYABORT;
                                                         }
                                                    }
            ;

//similar code only diffrence aprogress bar has 3 optional elemennts
bar_options: android_id
            | android_max
            | android_progress   
            | android_id android_max
            | android_id android_progress
            | android_max android_id
            | android_max android_progress
            | android_progress android_id
            | android_progress android_max 
            | android_id android_max android_progress
            | android_id android_progress android_max
            | android_max android_id android_progress
            | android_max android_progress android_id
            | android_progress android_id android_max
            | android_progress android_max android_id
            | UNDEFINED{yyerror("expecting 'android:max=(positive intenger)' or 'android:progress=(positive intenger)' or 'android:id=(string)'"); YYABORT;} 
            | android_id UNDEFINED {yyerror("expecting 'android:max=(positive intenger)' or 'android:progress=(positive intenger)'"); YYABORT;}
            | android_max UNDEFINED {yyerror("expecting 'android:id=(string)' or 'android:progress=(positive intenger)'"); YYABORT;}
            | android_progress UNDEFINED {yyerror("expecting 'android:max=(positive intenger)' or 'android:id=(string)'"); YYABORT;}
            | android_id android_max UNDEFINED {yyerror("expecting 'android:progress=(positive intenger)'"); YYABORT;}
            | android_id android_progress UNDEFINED {yyerror("expecting 'android:max=(positive intenger)'"); YYABORT;}
            | android_max android_id UNDEFINED {yyerror("expecting 'android:progress=(positive intenger)'"); YYABORT;}
            | android_max android_progress UNDEFINED {yyerror("expecting 'android:id=(string)'"); YYABORT;}
            | android_progress android_id UNDEFINED {yyerror("expecting 'android:max=(positive intenger)'"); YYABORT;}
            | android_progress android_max UNDEFINED {yyerror("expecting 'android:id=(string)'"); YYABORT;}
            | %empty 
            ;

//the manndatory features that exist in every grammar rule 
//android layout error is a special error in case the mandatory features dont have as input wrap_content,match_parent, or an innteger 
mad_feats: ANDROID_LAYOUT_WIDTH ANDROID_LAYOUT_HEIGHT {}
         | ANDROID_LAYOUT_HEIGHT ANDROID_LAYOUT_WIDTH {}
         | ANDROID_LAYOUT_HEIGHT UNDEFINED {yyerror("expecting 'android:layout_width=(string)'"); YYABORT;}
         | ANDROID_LAYOUT_WIDTH UNDEFINED {yyerror("expecting 'android:layout_height=(string)'"); YYABORT;}
         | UNDEFINED {yyerror("expecting 'android:layout_width=(string)' or 'android:layout_height=(string)'"); YYABORT;}
         | ANDROID_LAYOUT_ERROR { mode=1; yyerror("Not accepted value, accepts 'wrap_content',\n'match_parent' or positive integer"); YYABORT;} 
         | ANDROID_LAYOUT_HEIGHT ANDROID_LAYOUT_ERROR { mode=1; yyerror("Not accepted value, accepts 'wrap_content',\n'match_parent' or positive integer"); YYABORT;}
         | ANDROID_LAYOUT_WIDTH ANDROID_LAYOUT_ERROR { mode=1; yyerror("Not accepted value, accepts 'wrap_content',\n'match_parent' or positive integer"); YYABORT;}
         ;


android_id: ANDROID_ID {add_id(&arr,&id_size,yylval.strval); //similar with the radiogroup array but here we add every anndroid id in order to check if its unique
                                                      
                            if(id_compare(arr,id_size)==0) //we check if the anndroid ids are unique
                            {
                                mode=1;
                                yyerror("'android_id' should be unique");
                                YYABORT;
                            }
                            $$=$1; //needed in order to pass the value into higher grammar rules,like radiogroup anndroid ids
                       }
          ;


android_orientation: ANDROID_ORIENTATION {} 
                   ;


android_count: ANDROID_COUNT {$$=$1; line_radioButton=yylineno; radio_checker=atoi($1);} //atoi the string to get the integer and store tha value of the line
             ;


text_color: ANDROID_TEXT_COLOR {$$=$1;}
          ;


android_text: ANDROID_TEXT


android_max: ANDROID_MAX {max=atoi($1);}
            ;

android_padding: PADDING_ERROR {mode=1; yyerror("padding should be only a positive integer");  YYABORT;} //special error padding needs to be positive
               | ANDROID_PADDING 
               ;

android_src: ANDROID_SRC 
           ;

android_checkButton: ANDROID_CHECKBUTTON {$$=$1; line_button=yylineno; checkedButton=$1;} 
    ;

android_progress: ANDROID_PROGRESS {progress=atoi($1);} 
    ;


%% 

int main(int argc,char *argv[])
{
    if(argc<2) //inn case the user doesnt give a name
    {
        fprintf(stderr,"You didnt give me a file\n");
        return 1;
    }

    yyin=fopen(argv[1],"r"); //open the file
    if(!yyin)
    {
        perror(argv[1]);
        return 1;    //if yyin is null we retur with error  
    }
    
    arr = (char**)malloc(sizeof(char*)); //making space for the arrays
    radio_arr=(char**)malloc(sizeof(char*));
    
    int parse_result=yyparse();//h=get the result of the parser

    if(parse_result==0) //if finishes with zero its a success
    {
        print_program(yyin); //we prinnt the programm
        printf("this is a certified success!!\n");
    }
    else //else we have a parse error
    {
        printer(); //annd we print until the error line and the type of error
    }
      
    fclose(yyin); //close the file
    return 0;

}

void yyerror(const char* s) {
    if(yylval.strval!=NULL)
        pos_error=yylval.strval; //locationn of the error

    copyString(s,&error_message); //copy the string to the error message inn order to print it
    
    return;
}

void print_error()
{
    if(mode==0) //based onn the mode we prinnt the correct message
        fprintf(stderr, "Parse error at line %d: %s near %s\n",yylineno,error_message,pos_error);
    else if(mode==1)
        fprintf(stderr, "Parse error at line %d: %s\n",yylineno,error_message);
}

void printer()
{
    print_err_program(yyin,yylineno); //we prinnt the programm unntil the error line 

    print_error(); //and we print the error
}