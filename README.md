# Projecto de SN

## To-do

* Formular matematicamente a solução de GPS diferencial (ir buscar a literatura/internet)
* Preparar um algoritmo que permita definir um volume para a área restrita (em coordenadas ECEF(XYZ)) 
* Ter como opção de output um ficheiro KML desse volume
* Preparar um algoritmo que compute as coordenadas do receptor no referencial ECEF e determine intrusão na área restrita
* Inicialmente não será feita análise em tempo real nem usando DGPS, de forma a poder testar mais rapidamente os resultados, usando para tal um receptor GPS de smartphone a fazer logging da posição e detectar quando/onde foram feitas intrusões
* Numa primeira fase usar apenas uma área restrita para validar o algoritmo, criando áreas restritas adicionais posteriormente (e voltando a validar)
* Criar um algoritmo que receba o output do receptor GPS usando porta série e descodifique o resultado (se necessário)
* Criar um algoritmo para obter a informação da ground-station (se necessário)
* Criar um algoritmo que use o output do receptor GPS e a informação da ground-station para determinar a posição usando DGPS
* Testar o algoritmo (em tempo real) de forma a determinar a intrusão em apenas uma área restrita e posteriormente em mais que uma, com output gráfico de aviso de intrusão
* Gerar um ficheiro KML com o percurso realizado e as áreas restritas, bem como tendo as intrusões devidamente identificadas

## Stretch goals

* Obter a dinâmica do utilizador (velocidade, rumo) e originar aviso se, à velocidade actual, for entrar na zona restrita em menos de X segundos

## Perguntar ao prof

* Sensor
* Dados de ground station
* Set de testes para testar algoritmo (incluir dados do receptor móvel)
* Método de acesso aos dados da ground station real-time
* Por que raio é que as coordenadas do poste estão uma dezena de metros abaixo do chão


