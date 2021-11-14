/*  APL N3 Ejercicio 3 (Primer entrega)
    Script: cliente.cpp
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

using namespace std;

int main(int argc, char const *argv[])
{
    mkfifo("FIFO2", 0600);
    mkfifo("FIFO1", 0600);
    while (true)
   {  
       
    char respuesta[100];
    char consulta[100];
    cout << "Ingresa tu consulta"<<endl;
    cin >> consulta;
    int fileDescriptorFifo1 = open("FIFO1", O_WRONLY);
    write(fileDescriptorFifo1, consulta, strlen(consulta)+1);
  

    int fileDescriptorFifo2 = open("FIFO2", O_RDONLY);
    read(fileDescriptorFifo2, respuesta, sizeof(respuesta));
    
    cout<< "Lei del fifo" << respuesta<< endl;   
    close(fileDescriptorFifo2);
    close(fileDescriptorFifo1);
     }


    return 0;
}
