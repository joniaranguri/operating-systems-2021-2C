/*  APL N3 Ejercicio 3 (Primer entrega)
    Script: servidor.cpp
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
#include <iostream>
#include <thread>

using namespace std;

void task(){
  mkfifo("FIFO2", 0600);
    mkfifo("FIFO1", 0600);

   while (true)
   {    
    char comandoConsulta[100];
    char respuesta[100];
    int fileDescriptorFifo1 = open("FIFO1", O_RDONLY);
    read(fileDescriptorFifo1, comandoConsulta, sizeof(comandoConsulta));

    cout<< "Procesando" << comandoConsulta<< endl;   

    int fileDescriptorFifo2 = open("FIFO2", O_WRONLY);
     write(fileDescriptorFifo2,respuesta, strlen(respuesta)+1);

    close(fileDescriptorFifo2);
    close(fileDescriptorFifo1);
    }
}

int main(int argc, char const *argv[])
{

    thread t1(task);
    t1.detach();

    return 0;
}
