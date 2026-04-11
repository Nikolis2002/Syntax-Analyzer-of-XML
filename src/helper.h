#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void add_id(char ***arr, int *size, const char *value);
int id_compare(char **arr, int size);
int checkedButton_checker(char **arr, int size, char *string);
int progress_max(int max, int progress);
void print(char **arr, int size);
void print_program(FILE *yyin);
extern void print_err_program(FILE *yyin, int line);
int fileLinesSize(FILE *file);
void copyString(const char *source, char **destination);

void add_id(char ***arr, int *size, const char *value) // this is a conntainer like type funnctionn from c++
{
    if (*arr == NULL || *size == 0) // basically we make space for an array
    {
        *arr = (char **)malloc(sizeof(char *));
        *size = 1;
    }
    else if (*size > 0) // annd each time we put a new id we realloc the space +1 inn order for the new value to fit
    {
        *arr = (char **)realloc(*arr, (*size + 1) * sizeof(char *));
        (*size)++;
    }

    (*arr)[*size - 1] = (char *)malloc(strlen(value) + 1); // then we copy the value of the string(double pointers are needed beause basically this is a 2d array and its poinnter points into a string)
    strcpy((*arr)[*size - 1], value);
}

int id_compare(char **arr, int size)
{
    if (size == 1) // if size is 1 it only has onne value no need to check
        return 1;

    for (int i = 0; i < size - 1; i++)
    {
        if (strcmp(arr[size - 1], arr[i]) == 0) // we compare its elemennt ot the lst to see if they are unique
            return 0;                           // f not we returnn 0
    }
    return 1;
}

int checkedButton_checker(char **arr, int size, char *string) // similar as above but we compare a string to evry elemnt of an array
{
    if (size == 0)
        return 1;

    if (string == NULL)
        return 1;

    for (int i = 0; i < size; i++)
    {
        if (strcmp(string, arr[i]) == 0)
            return 1;
    }
    return 0;
}

int progress_max(int max, int progress)// basic comparsionn to see which is bigger
{
    if(progress==0 || max==0){
        return 0;
    }

    if (progress > max)
    {
        return 1;
    }

    return 0;
}

void print(char **arr, int size) // helper function if you want to see the elementns of the arrays
{
    printf("[ ");
    for (int i = 0; i < size; i++)
    {
        printf("string %d: %s\n", i + 1, arr[i]);
    }
    printf("]\n");
}

void print_program(FILE *yyin) // prints the whole program(when the parser is successful)
{
    fseek(yyin, 0, SEEK_SET); // reset the file pointer

    int count = 1;
    printf("%d: ", count++);
    int c;

    while ((c = fgetc(yyin)) != EOF)
    {
        if (c == '\n')
        {
            printf("%c", c);
            printf("%d: ", count);
            count++;
        }
        else
        {
            printf("%c", c);
        }
    }

    printf("\n");
}

extern void print_err_program(FILE *yyin, int line) // simlar as above but we print until the line(basically until yylinneno )
{

    int char_size = fileLinesSize(yyin);
    fseek(yyin, 0, SEEK_SET);
    int count = 1;
    int num = line + 1;
    char c[char_size]; // the array can hold every line, so we donnt have a segmetationn fault
    while ((count < num) && (fgets(c, sizeof(c), yyin) != NULL))
    {
        fprintf(stderr, "%d: %s", count, c);
        count++;
    }
}

int fileLinesSize(FILE *file) // we get the longest array inn the programm to help the function above
{
    fseek(file, 0, SEEK_SET);
    int sizeCounter = 0;
    char c;
    int maxLenCounter = 0;

    while ((c = fgetc(file)) != EOF)
    {
        if (c == '\n')
        {
            // New maximum
            if (maxLenCounter > sizeCounter)
                sizeCounter = maxLenCounter;

            maxLenCounter = 0;
        }

        maxLenCounter++;
    }

    sizeCounter++;

    return sizeCounter;
}

void copyString(const char *source, char **destination)
{
    *destination = malloc(strlen(source) + 1); // Allocate memory for the copied string
    strcpy(*destination, source);              // Copy the string
}