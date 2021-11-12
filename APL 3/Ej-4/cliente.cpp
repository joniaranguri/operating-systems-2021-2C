/*  APL N3 Ejercicio 4 (Segunda entrega)
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
#include <sys/mman.h>

using namespace std;
#define MEMORIA_RES "aranggueri-mem"
#define MEMORIA_DEF "DFFDF-gemem"
#define SEM_LEE_CLIENTE "sem-legfe-cliente"
#define SEM_LEE_SERVIDOR "sem-legef-servidor"
#define SEM_CLIENTE "sem-DSDFSDFfDDDem"
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

void cerrarAlmATAR(int signal)
{
  sem_unlink(SEM_CLIENTE);
  sem_unlink(SEM_LEE_CLIENTE);
  sem_unlink(SEM_LEE_SERVIDOR);
  return;
}

int main(int argc, char const *argv[])
{
  sem_t *semaforo = sem_open(SEM_CLIENTE, O_CREAT, 0600, 1);

  if (sem_trywait(semaforo) != 0)
  {
    cout << "No se puede ejecutar mas de una instancia del proceso" << endl;
    //return 1;
  }

  /* shm_unlink(MEMORIA_DEF);
    shm_unlink(MEMORIA_RES);
    sem_unlink(SEM_LEE_SERVIDOR);
    sem_unlink(SEM_LEE_CLIENTE);
*/
  if (validarParametros(argc, argv))
  {
    sem_post(semaforo);
    sem_close(semaforo);
    sem_unlink(SEM_CLIENTE);
    return 1;
  }

  signal(SIGINT, handlerSenial);
  signal(SIGKILL, cerrarAlmATAR);

  int idMemoriaDefinicion = shm_open(MEMORIA_DEF, O_CREAT | O_RDWR, 0600);
  int idMemoriaRespuesta = shm_open(MEMORIA_RES, O_CREAT | O_RDWR, 0600);
  size_t tamRespuesta = sizeof(char) * 100;
  size_t tamDefinicion = sizeof(char) * 4096;
  ftruncate(idMemoriaDefinicion, sizeof(tamDefinicion));
  ftruncate(idMemoriaRespuesta, sizeof(tamRespuesta));
  char *memoriaRes = (char *)mmap(NULL, tamRespuesta,
                                  PROT_READ | PROT_WRITE, MAP_SHARED, idMemoriaRespuesta, 0);
  char *memoriaDef = (char *)mmap(NULL, tamDefinicion,
                                  PROT_READ | PROT_WRITE, MAP_SHARED, idMemoriaDefinicion, 0);
  close(idMemoriaDefinicion);
  close(idMemoriaRespuesta);
  sem_t *semLeeCliente = sem_open(SEM_LEE_CLIENTE, O_CREAT, 0600, 0);
  sem_t *semLeeServidor = sem_open(SEM_LEE_SERVIDOR, O_CREAT, 0600, 0);










  cout << "Bienvenido al autodefinido" << endl;
  cout << "Ingrese la cantidad de preguntas a realizar:" << endl;

//Escribir cantidad de preguntas en memoria Respuesta
  cin >> memoriaRes;
  int sizeOfPartida = atoi(memoriaRes);
//Escribir cantidad de preguntas en memoria Respuesta


 sem_post(semLeeServidor); //Habilito a leer al Servidor


  for (int i = 0; i < sizeOfPartida; i++)
  {
//Leer definicion desde memoria Definicion
    sem_wait(semLeeCliente); 
    cout << memoriaDef << endl;
    cin >> memoriaRes;
    sem_post(semLeeServidor); //toma la respuesta
  }
  sem_wait(semLeeCliente); //4 dame
  cout << memoriaDef << endl;

/*
  sem_post(semaforo);
  sem_close(semaforo);
  sem_unlink(SEM_CLIENTE);
  sem_unlink(SEM_LEE_CLIENTE);
  sem_close(semLeeCliente);
  sem_unlink(SEM_LEE_CLIENTE);
*/
  return 0;
}
