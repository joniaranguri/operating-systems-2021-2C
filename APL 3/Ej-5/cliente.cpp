/*  APL N3 Ejercicio 5 (Segunda entrega)
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
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <netdb.h>

using namespace std;
sem_t *semaforo;
int servidorPid;
#define SEM_CLIENTE "SEM_CLIENTE_5"
#define USER_SKIP_QUESTION "user_skip_question"

void mostrarAyuda()
{
  cout << endl
       << " Ejemplo de ejecucion:" << endl
       << "./cliente" << endl;
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
  if (argc == 2)
  {
    if (strcmp(argv[1], "-h") == 0 || strcmp(argv[1], "--help") == 0 || strcmp(argv[1], "-?") == 0)
    {
      mostrarAyuda();
    }
    else
    {
      printf("\n Cantidad de parametros incorrecta, verifique la ayuda\n");
    }
  }
  else if (argc == 3)
  {
    if (!isNumber(argv[2]))
    {
      printf("\n El puerto pasado por parámetro no es un número válido\n");
    }
    else
    {
      return 0;
    }
  }
  else
  {
    printf("\n Cantidad de parametros incorrecta, verifique la ayuda\n");
  }
  return 1;
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

  int puerto = atoi(argv[2]);
  const char *ip = argv[1];
  int socketComunicacion = socket(AF_INET, SOCK_STREAM, 0);

  struct sockaddr_in socketConfig;
  memset(&socketConfig, '0', sizeof(socketConfig));
  socketConfig.sin_family = AF_INET;
  socketConfig.sin_port = htons(puerto);

  inet_pton(AF_INET, ip, &socketConfig.sin_addr);

  int resultadoConexion = connect(socketComunicacion, (struct sockaddr *)&socketConfig, sizeof(socketConfig));

  if (resultadoConexion < 0)
  {
    cout << "Error en la conexión. Verifique si el servidor está corriendo..." << endl;

    cerrarRecursos(0);
  }
  char stringPid[10];
  memset(stringPid, 0, sizeof stringPid);
  read(socketComunicacion, &stringPid, sizeof(stringPid));
  servidorPid = atoi(stringPid);
  cout << "Bienvenido al autodefinido" << endl;
  cout << "Ingrese la cantidad de preguntas a realizar:" << endl;

  string consulta;
  char buffer[2000];
  bool isValid = false;
  int sizeOfPartida = 0;
  while (!isValid)
  {
    getline(cin, consulta);
    if (isNumber(&consulta[0]))
    {
      sizeOfPartida = atoi(&consulta[0]);
      if (sizeOfPartida < 1)
      {
        cout << "Elija un número mayor a 1. Intente nuevamente:" << endl;
      }
      else
      {
        isValid = true;
      }
    }
    else
    {
      cout << "No se ingresó un numero. Intente nuevamente:" << endl;
    }
  }
  send(socketComunicacion, &consulta[0], strlen(&consulta[0]), 0);

  cout << "Generando definiciones aleatorias. Espere por favor..." << endl;

  for (int i = 0; i < sizeOfPartida; i++)
  {
    memset(buffer, 0, sizeof buffer);
    read(socketComunicacion, buffer, 2000);
    cout << buffer << endl;

    string respuesta;
    getline(cin, respuesta);
    if (respuesta == "")
    {
      respuesta = USER_SKIP_QUESTION;
    }
    send(socketComunicacion, &respuesta[0], strlen(&respuesta[0]), 0);
  }
  memset(buffer, 0, sizeof buffer);
  int valread = read(socketComunicacion, buffer, 2000);
  cout << endl
       << buffer << endl;
  cout << "Fin de la partida" << endl;
  cerrarRecursos(0);
  return 0;
}
