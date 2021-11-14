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
char const * directorio;
int cantHilos;
mutex mtx;
mutex mtxResults;
vector<int> results(10, 0);
vector<dirent*> archivos;
sem_t *semaforo;

void mostrarAyuda() {
    printf("\n Ejemplo de ejecucion: \n ./ejercicio2 3 ./directorio\n");
}

int isNumber(char const s[])
{
    for (int i = 0; s[i]!= '\0'; i++)
    {
        if (isdigit(s[i]) == 0)
              return 0;
    }
    return 1;
}

int validarParametros(int argc, char const *argv[]){
       if (argc != 3) {
        if (argc == 2 && (strcmp(argv[1], "-h") == 0 || strcmp(argv[1], "-help") == 0 || strcmp(argv[1], "-?") == 0)) {
        mostrarAyuda();
    }else{
        printf("\n Cantidad de parametros incorrecta, verifique la ayuda\n");
    }
        return 1;
    }

    struct stat info;
if( stat(argv[2], &info) != 0 ){
     printf( "\nNo se se econtró el directorio %s\n", argv[2]  );
     return 1;
}

    if(!isNumber(argv[1])){
        printf("\n El parámetro de nivel de paralelismo no es un número entero\n");
        return 1;
    }else{
          int ans = atoi(argv[1]);
        if(ans == 0){
         printf("\n El parámetro de nivel de paralelismo debe ser mayor a cero\n");
        return 1;
        }
    }

 return 0;

}

void doSomething(int id) {
    int semValue;
    sem_getvalue(semaforo, &semValue);
while(semValue >0){

mtx.lock();
    dirent * archivo = archivos.front();
    archivos.erase(archivos.begin());
    sem_wait(semaforo);
    mtx.unlock();

    vector<int> aux(10, 0);
           char pathname[1024];   
       sprintf( pathname, "%s%s.txt", directorio, archivo->d_name );

           FILE* f = fopen(pathname, "r");
     fseek(f, 0, SEEK_END);
    size_t size = ftell(f);
    char* where = new char[size];

   rewind(f);
   fread(where, sizeof(char), size, f);
   fclose(f);

    for (int i = 0; where[i]!= '\0'; i++)
        if (isdigit(where[i]))
             aux[where[i]- '0']++;
        


    mtxResults.lock();
   cout <<endl<<"Thread"<< id<<": Archivo leído "<< pathname<< ". Apariciones";

    for(int i=0; i<10; i++){
        cout << "  "<<i<<"={" << aux[i]<<"}";
        results[i]+=aux[i];
    }

   mtxResults.unlock();

       sem_getvalue(semaforo, &semValue);

   }
}

void mostrarResultados(){
cout <<endl<<"Finalizado lectura: Apariciones total";

    for(int i=0; i<10; i++){
        cout << "  "<<i<<"={" << results[i]<<"}";
    }
}  

void instanciarHilos(){
    if(archivos.size() < cantHilos){

        cantHilos = archivos.size();
    }
     cout << "Iniciando el procesamiento" << endl;

semaforo = sem_open("miSemaforo", O_CREAT, 0600, archivos.size());

  vector<thread> threads;
  for (size_t i = 0; i < cantHilos; ++i) { 
    threads.push_back(thread(doSomething, i));
  }
  for (auto& th : threads) {
        th.join();
    }
    sem_close(semaforo);
    sem_unlink("miSemaforo");

    mostrarResultados();
}

void procesarDirectorio(){

      DIR *d;
    char *p1,*p2;
    int ret;
    struct dirent *dir;
    d = opendir(directorio);
    if (d)
    {
        while ((dir = readdir(d)) != NULL)
        {
            p1=strtok(dir->d_name,".");
            p2=strtok(NULL,".");
            if(p2!=NULL)
            {
                ret=strcmp(p2,"txt");
                if(ret==0)
                { 
                       archivos.push_back(dir);
                }
            }

        }
        closedir(d);
    }

   instanciarHilos();
}

int main(int argc, char const *argv[])
{   
    if(validarParametros(argc, argv)){
     printf("\n Parámetros inválidos\n");
    return 1;
    }
cantHilos = atoi(argv[1]);
directorio = argv[2];
procesarDirectorio();
    return 0;
}

