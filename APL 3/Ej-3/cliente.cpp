/*  APL N3 Ejercicio 3 (Segunda entrega)
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

void handlerSenial(int signal)
{
  //Nothing to do
}

void mostrarAyuda()
{
  printf("\n Ejemplo de ejecucion: \n ./cliente\n");
  cout << "Comandos validos" << endl;
  cout << "       SUM {nombreChofer}" << endl;
  cout << "       AVG_VALOR" << endl;
  cout << "       LIST {nombreChofer}" << endl;
  cout << "       MAX_GASOIL" << endl;
}

int validarParametros(int argc, char const *argv[])
{
  if (argc > 1)
  {
    if (strcmp(argv[1], "-h") == 0 || strcmp(argv[1], "-help") == 0 || strcmp(argv[1], "-?") == 0)
    {
      mostrarAyuda();
    }
    else
    {
      printf("\n Cantidad de parametros incorrecta, verifique la ayuda\n");
    }
    return 1;
  }
  return 0;
}

void salir()
{
}

int main(int argc, char const *argv[])
{
  sem_t *semaforo = sem_open("sCliente", O_CREAT, 0600, 1);

  if (sem_trywait(semaforo) != 0)
  {
    cout << "No se puede ejecutar mas de una instancia del proceso" << endl;
    return 1;
  }

  if (validarParametros(argc, argv))
  {
    sem_post(semaforo);
    sem_close(semaforo);
    sem_unlink("sCliente");
    return 1;
  }
  signal(SIGINT, handlerSenial);
  struct sigaction action;
  action.sa_handler = handlerSenial;

  string FIFO1 = "FIFO1";
  string FIFO2 = "FIFO2";

  mkfifo(&FIFO2[0], 0600);
  mkfifo(&FIFO1[0], 0600);

  while (true)
  {

    char respuesta[500];
    string consulta;
    cout << "Ingresa tu consulta" << endl;
    getline(cin, consulta);

    int fileDescriptorFifo1 = open(&FIFO1[0], O_WRONLY);
    write(fileDescriptorFifo1, &consulta[0], strlen(&consulta[0]) + 1);
    close(fileDescriptorFifo1);

    if (strcmp(&consulta[0], "QUIT") == 0)
    {
      unlink(&FIFO1[0]);
      unlink(&FIFO2[0]);
      sem_post(semaforo);
      sem_close(semaforo);
      sem_unlink("sCliente");
      return 0;
    }

    int fileDescriptorFifo2 = open(&FIFO2[0], O_RDONLY);
    read(fileDescriptorFifo2, respuesta, sizeof(respuesta));
    close(fileDescriptorFifo2);

    cout << endl
         << respuesta << endl;
  }
  return 0;
}
