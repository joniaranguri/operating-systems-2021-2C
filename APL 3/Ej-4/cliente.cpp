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
sem_t *semaforo;
int servidorPid;
#define MEMORIA_RES "aranggueri-mem"
#define MEMORIA_DEF "DFFDF-gemem"
#define SEM_LEE_CLIENTE "sem-legfe-cliente"
#define SEM_LEE_SERVIDOR "sem-legef-servidor"
#define SEM_CLIENTE "sem-ssscdsfsdlissesddnfftefbro"
#define USER_SKIP_QUESTION "user_skip_question"
#define MEMORIA_PID "user_sSDFSDFSDFkip_question"

void mostrarAyuda()
{
  cout << endl
       << " Ejemplo de ejecucion:" << endl
       << "./cliente" << endl;
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
void cerrarRecursos(int signal)
{
  sem_post(semaforo);
  sem_close(semaforo);
  sem_unlink(SEM_CLIENTE);
  exit(0);
}

void reactToSigInt(int signal)
{
  cout << "Partida cancelada" << endl;
  if (servidorPid != 0)
  {
    kill(servidorPid, SIGUSR2);
  }

  cerrarRecursos(signal);
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

int main(int argc, char const *argv[])
{
  semaforo = sem_open(SEM_CLIENTE, O_CREAT, 0600, 1);

  if (sem_trywait(semaforo) != 0)
  {
    cout << "No se puede ejecutar mas de una instancia del proceso" << endl;
    return 1;
  }
  if (validarParametros(argc, argv))
  {
    cerrarRecursos(0);
  }

  signal(SIGINT, reactToSigInt);

  int idMemoriaPid = shm_open(MEMORIA_PID, O_CREAT | O_RDWR, 0600);
  int idMemoriaDefinicion = shm_open(MEMORIA_DEF, O_CREAT | O_RDWR, 0600);
  int idMemoriaRespuesta = shm_open(MEMORIA_RES, O_CREAT | O_RDWR, 0600);
  size_t tamRespuesta = sizeof(char) * 100;
  size_t tamDefinicion = sizeof(char) * 4096;
  ftruncate(idMemoriaDefinicion, sizeof(tamDefinicion));
  ftruncate(idMemoriaRespuesta, sizeof(tamRespuesta));
  ftruncate(idMemoriaPid, sizeof(int));
  char *memoriaRes = (char *)mmap(NULL, tamRespuesta,
                                  PROT_READ | PROT_WRITE, MAP_SHARED, idMemoriaRespuesta, 0);
  char *memoriaDef = (char *)mmap(NULL, tamDefinicion,
                                  PROT_READ | PROT_WRITE, MAP_SHARED, idMemoriaDefinicion, 0);
  int *memoriaPid = (int *)mmap(NULL, sizeof(int),
                                PROT_WRITE, MAP_SHARED, idMemoriaPid, 0);
  close(idMemoriaPid);
  close(idMemoriaDefinicion);
  close(idMemoriaRespuesta);
  sem_t *semLeeCliente = sem_open(SEM_LEE_CLIENTE, O_CREAT, 0600, 0);
  sem_t *semLeeServidor = sem_open(SEM_LEE_SERVIDOR, O_CREAT, 0600, 0);

  cout << "Bienvenido al autodefinido" << endl;
  cout << "Ingrese la cantidad de preguntas a realizar:" << endl;

  string consulta;
  bool isValid = false;
  while (!isValid)
  {
    getline(cin, consulta);
    if (isNumber(&consulta[0]))
    {
      isValid = true;
    }
    else
    {
      cout << "No se ingresó un numero. Intente nuevamente:" << endl;
    }
  }

  strcpy(memoriaRes, &(consulta)[0]);

  int sizeOfPartida = atoi(memoriaRes);
  servidorPid = *memoriaPid;

  cout << "Generando definiciones aleatorias. Espere por favor..." << endl;

  sem_post(semLeeServidor);
  for (int i = 0; i < sizeOfPartida; i++)
  {
    sem_wait(semLeeCliente);
    cout << memoriaDef << endl;

    string respuesta;
    getline(cin, respuesta);
    if (respuesta == "")
    {
      respuesta = USER_SKIP_QUESTION;
    }
    strcpy(memoriaRes, &(respuesta)[0]);
    sem_post(semLeeServidor);
  }
  sem_wait(semLeeCliente);
  cout << endl
       << memoriaDef << endl;
  cout << "Fin de la partida" << endl;
  cerrarRecursos(0);
  return 0;
}
