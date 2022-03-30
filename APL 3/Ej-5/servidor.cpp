/*  APL N3 Ejercicio 5 (Segunda entrega)
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
#include <algorithm>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <netdb.h>

using namespace std;
string respuesta;
string archivo = "definiciones.txt";
vector<int> elegidas;
sem_t *semaforo;
#define SEM_SERVIDOR "SEM_SERVIDOR_5"
#define USER_SKIP_QUESTION "user_skip_question"
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

void cerrarRecursos(int code)
{
    cout << "Apagando servidor" << endl;
    sem_post(semaforo);
    sem_close(semaforo);
    sem_unlink(SEM_SERVIDOR);
    exit(code);
}

void clienteFinaliza(int signal)
{
    cout << "Partida cancelada" << endl;
    cerrarRecursos(signal);
}

void mostrarAyuda()
{
    cout << "Ejemplo de ejecucion: \n ./servidor 5000" << endl;
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
        else if (isNumber(argv[1]))
        {
            return 0;
        }

        return 1;
    }
    else
    {
        printf("\n Cantidad de parametros incorrecta, verifique la ayuda\n");
    }
    return 1;
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
    if (validarParametros(argc, argv))
    {
        cerrarRecursos(0);
    }
    int puerto = atoi(argv[1]);

    signal(SIGINT, SIG_IGN);
    signal(SIGUSR1, cerrarRecursos);
    signal(SIGUSR2, clienteFinaliza);
    if (leerArchivo() != 0)
    {
        cout << "No se puede leer el archivo de definiciones" << endl;
        cerrarRecursos(0);
    }

    struct sockaddr_in serverConfig;
    memset(&serverConfig, '0', sizeof(serverConfig));
    serverConfig.sin_family = AF_INET;
    serverConfig.sin_addr.s_addr = htonl(INADDR_ANY);
    serverConfig.sin_port = htons(puerto);
    int socketEscucha = socket(AF_INET, SOCK_STREAM, 0);
    bind(socketEscucha, (struct sockaddr *)&serverConfig, sizeof(serverConfig));
    listen(socketEscucha, 10);

    while (true)
    {

        cout << "Esperando conexión..." << endl;
        int socketComunicacion = accept(socketEscucha, (struct sockaddr *)NULL, NULL);
        cout << "Conectado!" << endl;
        signal(SIGUSR1, SIG_IGN);
        string pid = to_string(getpid());
        send(socketComunicacion, &pid[0], strlen(&pid[0]), 0);

        int puntajePartida = 0;
        stringstream ssError;
        stringstream ssSkip;
        ssError << "Definiciones no acertadas : " << endl;
        ssSkip << "Definiciones saltadas : " << endl;

        int sizeOfPartida = 0;
        char sizePartidaString[3];
        memset(sizePartidaString, 0, sizeof sizePartidaString);
        read(socketComunicacion, &sizePartidaString, sizeof(sizePartidaString));
        sizeOfPartida = atoi(sizePartidaString);
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

            send(socketComunicacion, &definitionFormal.str()[0], strlen(&definitionFormal.str()[0]), 0);

            char buffer[2000];
            memset(buffer, 0, sizeof buffer);
            read(socketComunicacion, buffer, 2000);

            if (strcmp(&(buffer)[0], result) == 0)
            {
                puntajePartida++;
            }
            else if (strcmp(&(buffer)[0], USER_SKIP_QUESTION) == 0)
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

        send(socketComunicacion, &(resultadoFinal.str())[0], strlen(&(resultadoFinal.str())[0]), 0);

        cout << "Termino la partida, reiniciando" << endl;
        signal(SIGUSR1, cerrarRecursos);
    }
    return 0;
}
