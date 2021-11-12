/*  APL N3 Ejercicio 4 (Segunda entrega)
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
#include <sys/mman.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdarg.h>
#include <signal.h>
#include <string.h>
#include <iostream>
#include <fstream>
#include <thread>
#include <vector>
#include <mutex>
#include <sstream>
#include <time.h>

using namespace std;
int parentPid;
string respuesta;
string archivo = "definiciones.txt";
vector<int> elegidas;
sem_t *semaforo;
sem_t *semLeeCliente;
sem_t *semLeeServidor;
#define MEMORIA_RES "aranggueri-mem"
#define MEMORIA_DEF "DFFDF-gemem"
#define SEM_LEE_CLIENTE "sem-legfe-cliente"
#define SEM_LEE_SERVIDOR "sem-legef-servidor"
#define SEM_SERVIDOR "sems-fsefssfsdddfsrvidorbro"
#define USER_SKIP_QUESTION "user_skip_question"
#define MEMORIA_PID "user_sSDFSDFSDFkip_question"
class AutoDef
{
public:
    string definition;

public:
    string result;

    void init(string definition, string result)
    {
        (*this).definition = definition;
        (*this).result = result;
    }
};
vector<AutoDef> registros;

void cerrarRecursos(int signal)
{

    shm_unlink(MEMORIA_RES);
    shm_unlink(MEMORIA_DEF);
    shm_unlink(MEMORIA_PID);
    sem_close(semLeeCliente);
    sem_close(semLeeServidor);
    sem_unlink(SEM_LEE_CLIENTE);
    sem_unlink(SEM_LEE_SERVIDOR);
    sem_post(semaforo);
    sem_close(semaforo);
    sem_unlink(SEM_SERVIDOR);
    cout << "Apagando servidor" << endl;
    exit(0);
}

void clienteFinaliza(int signal)
{
    cout << "Partida cancelada" << endl;
    cerrarRecursos(signal);
}

void mostrarAyuda()
{
    cout << "Ejemplo de ejecucion: \n ./servidor" << endl;
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

int leerArchivo()
{
    string line;
    try
    {
        ifstream miArchivo(archivo);
        string definition;
        while (getline(miArchivo, definition, '\t'))
        {
            string result;
            getline(miArchivo, result, '\t');
            AutoDef registro;
            registro.init(definition, result);
            registros.push_back(registro);
        }
        miArchivo.close();
    }
    catch (const std::exception &e)
    {
        std::cerr << "Ocurrió un error al leer el archivo" << endl;
        return 1;
    }
    return 0;
}

void elegirAleatorias(int cant)
{
    elegidas.clear();
    srand(time(NULL));

    while (elegidas.size() < cant)
    {
        int randomNum = rand() % registros.size();
        if (find(elegidas.begin(), elegidas.end(), randomNum) == elegidas.end())
        {
            elegidas.push_back(randomNum);
        }
    }
}

int main(int argc, char const *argv[])
{

    semaforo = sem_open(SEM_SERVIDOR, O_CREAT, 0600, 1);

    if (sem_trywait(semaforo) != 0)
    {
        cout << "No se puede ejecutar mas de una instancia del proceso" << endl;
        return 1;
    }

    signal(SIGINT, SIG_IGN);
    signal(SIGUSR1, cerrarRecursos);
    signal(SIGUSR2, clienteFinaliza);
    if (leerArchivo() != 0)
    {
        cout << "No se puede leer el archivo de definiciones" << endl;
        cerrarRecursos(0);
    }
    int idMemoriaPid = shm_open(MEMORIA_PID, O_CREAT | O_RDWR, 0600);
    int idMemoriaDefinicion = shm_open(MEMORIA_DEF, O_CREAT | O_RDWR, 0600);
    int idMemoriaRespuesta = shm_open(MEMORIA_RES, O_CREAT | O_RDWR, 0600);
    size_t tamRespuesta = sizeof(char) * 100;
    size_t tamDefinicion = sizeof(char) * 4096;
    ftruncate(idMemoriaPid, sizeof(int));
    ftruncate(idMemoriaDefinicion, sizeof(tamDefinicion));
    ftruncate(idMemoriaRespuesta, sizeof(tamRespuesta));
    char *memoriaRes = (char *)mmap(NULL, tamRespuesta,
                                    PROT_READ | PROT_WRITE, MAP_SHARED, idMemoriaRespuesta, 0);
    char *memoriaDef = (char *)mmap(NULL, tamDefinicion,
                                    PROT_READ | PROT_WRITE, MAP_SHARED, idMemoriaDefinicion, 0);
    int *memoriaPid = (int *)mmap(NULL, sizeof(int),
                                  PROT_WRITE, MAP_SHARED, idMemoriaPid, 0);
    close(idMemoriaPid);
    close(idMemoriaDefinicion);
    close(idMemoriaRespuesta);
    semLeeCliente = sem_open(SEM_LEE_CLIENTE, O_CREAT, 0600, 0);
    semLeeServidor = sem_open(SEM_LEE_SERVIDOR, O_CREAT, 0600, 0);
    *memoriaPid = getpid();

    while (true)
    {
        cout << "Esperando conexión..." << endl;
        sem_wait(semLeeServidor);

        signal(SIGUSR1, SIG_IGN);
        *memoriaPid = getpid();
        cout << "Conectado!" << endl;

        int puntajePartida = 0;
        stringstream ssError;
        stringstream ssSkip;
        ssError << "Definiciones no acertadas : " << endl;
        ssSkip << "Definiciones saltadas : " << endl;
        int sizeOfPartida = atoi(memoriaRes);
        elegirAleatorias(sizeOfPartida);
        int saltadas = 0;
        int erradas = 0;

        for (int i = 0; i < sizeOfPartida; i++)
        {
            AutoDef def = registros.at(elegidas[i]);
            char *definition = &(def.definition)[0];
            char *result = &(def.result)[0];
            stringstream definitionFormal;
            definitionFormal << definition << " ( " << strlen(result) << " letras ) ";
            strcpy(memoriaDef, &(definitionFormal.str())[0]);
            sem_post(semLeeCliente);
            sem_wait(semLeeServidor);
            if (strcmp(&(memoriaRes)[0], result) == 0)
            {
                puntajePartida++;
            }
            else if (strcmp(&(memoriaRes)[0], USER_SKIP_QUESTION) == 0)
            {
                ssSkip << definition
                       << "--> " << result << endl
                       << endl;
                saltadas++;
            }
            else
            {
                ssError << definition
                        << "--> " << result << endl
                        << endl;
                puntajePartida--;
                erradas++;
            }
        }

        stringstream resultadoFinal;

        if (saltadas > 0)
        {
            resultadoFinal << ssSkip.str() << endl
                           << endl;
        }
        if (erradas > 0)
        {
            resultadoFinal << ssError.str() << endl;
        }

        resultadoFinal << "#########################" << endl
                       << " * Puntuación final: "
                       << puntajePartida << " *" << endl
                       << "#########################" << endl;
        strcpy(memoriaDef, &(resultadoFinal.str())[0]);
        sem_post(semLeeCliente);
        cout << "Termino la partida, reiniciando" << endl;
        signal(SIGUSR1, cerrarRecursos);
    }
    return 0;
}
