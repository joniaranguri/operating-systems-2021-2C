/*  APL N3 Ejercicio 2 (Primer entrega)
    Script: ej-2.cpp
    Integrantes:
    ARANGURI JONATHAN ENRIQUE                  40.672.991	
*/

#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <semaphore.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdarg.h>
#include <signal.h>
#include <string.h>
#include <ctype.h>
#include <dirent.h>
#include <vector>
#include <mutex>
#include <thread>
#include <iostream>

using namespace std;
string directorio;
int cantHilos;
mutex mtx;
mutex mtxResults;
vector<int> results(10, 0);
char **archivos;
sem_t *semaforo;
vector<vector<int>> mat;
int cantFiles = 0;

void mostrarAyuda()
{
    printf("\n Ejemplo de ejecucion: \n ./ejercicio2 3 ./directorio\n");
}

int isNumber(char const s[])
{
    for (int i = 0; s[i] != '\0'; i++)
    {
        if (isdigit(s[i]) == 0)
            return 0;
    }
    return 1;
}

int validarParametros(int argc, char const *argv[])
{
    if (argc != 3)
    {
        if (argc == 2 && (strcmp(argv[1], "-h") == 0 || strcmp(argv[1], "-help") == 0 || strcmp(argv[1], "-?") == 0))
        {
            mostrarAyuda();
        }
        else
        {
            printf("\n Cantidad de parametros incorrecta, verifique la ayuda\n");
        }
        return 1;
    }

    struct stat info;
    if (stat(argv[2], &info) != 0)
    {
        printf("\nNo se se econtró el directorio %s\n", argv[2]);
        return 1;
    }

    if (!isNumber(argv[1]))
    {
        printf("\n El parámetro de nivel de paralelismo no es un número entero\n");
        return 1;
    }
    else
    {
        int ans = atoi(argv[1]);
        if (ans == 0)
        {
            printf("\n El parámetro de nivel de paralelismo debe ser mayor a cero\n");
            return 1;
        }
    }

    return 0;
}

void doSomething(int id)
{

    for (int i = 0; i < mat.at(id).size(); i++)
    {
        mtx.lock();
        string arch = archivos[mat.at(id).at(i)];
        mtx.unlock();

        vector<int> aux(10, 0);
        string pathname = directorio + arch + ".txt";
        FILE *f = fopen(&pathname[0], "r");
        fseek(f, 0, SEEK_END);
        size_t size = ftell(f);
        char *where = new char[size];

        rewind(f);
        fread(where, sizeof(char), size, f);
        fclose(f);
        for (int i = 0; where[i] != '\0'; i++)
            if (isdigit(where[i]))
                aux[where[i] - '0']++;

        mtxResults.lock();

        cout << endl<< "Thread " << id +1 << ": Archivo leído " << pathname << ". Apariciones";
        for (int i = 0; i < 10; i++)
        {
            cout << "  " << i << "={" << aux[i] << "}";
            results[i] += aux[i];
        }
        mtxResults.unlock();
    }
}

void mostrarResultados()
{
    cout << endl<< "Finalizado lectura: Apariciones total" ;

    for (int i = 0; i < 10; i++)
    {
        cout << "  " << i << "={" << results[i] << "}";
    }
}

void instanciarHilos(vector<vector<int>> mat)
{

    vector<thread> threads;
    for (size_t i = 0; i < cantHilos; ++i)
    {
        threads.push_back(thread(doSomething, i));
    }
    for (auto &th : threads)
    {
        th.join();
    }

    mostrarResultados();
}

void dividirArchivos()
{
    if (cantFiles < cantHilos)
    {
        cantHilos = cantFiles;
    }
    mat.resize(cantHilos);

    for (int i = 0; i < cantFiles;)
    {
        for (int j = 0; j < cantHilos && i < cantFiles; i++, j++)
        {
            mat[j].push_back(i);
        }
    }
    instanciarHilos(mat);
}

void procesarDirectorio()
{

    DIR *d;
    char *p1, *p2;
    int ret;
    struct dirent *dir;
    d = opendir(&directorio[0]);

    if (d)
    {
        while ((dir = readdir(d)) != NULL)
        {
            p1 = strtok(dir->d_name, ".");
            p2 = strtok(NULL, ".");
            if (p2 != NULL)
            {
                ret = strcmp(p2, "txt");
                if (ret == 0)
                {
                    cantFiles++;
                }
            }
        }
        archivos = new char *[cantFiles];
        rewinddir(d);
        int index = 0;
        while ((dir = readdir(d)) != NULL && index < cantFiles)
        {
            p1 = strtok(dir->d_name, ".");
            p2 = strtok(NULL, ".");
            if (p2 != NULL)
            {
                ret = strcmp(p2, "txt");
                if (ret == 0)
                {
                    archivos[index] = new char[1024];
                    strcpy(archivos[index], dir->d_name);
                    index++;
                }
            }
        }
        closedir(d);
    }

    dividirArchivos();
}

int main(int argc, char const *argv[])
{
    if (validarParametros(argc, argv))
    {
        printf("\n Parámetros inválidos\n");
        return 1;
    }
    cantHilos = atoi(argv[1]);
    directorio = string(argv[2]);
    procesarDirectorio();
    return 0;
}
