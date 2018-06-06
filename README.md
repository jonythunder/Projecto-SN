# Projecto de Sistemas de Navegação

Desenvolvimento de um sistema de detecção de intromissão em áreas restritas baseado em GPS diferencial

## To-do

* ~~Formular matematicamente a solução de GPS diferencial (ir buscar a literatura/internet)~~
* Preparar um algoritmo que permita definir um volume para a área restrita e determinar intrusão (em coordenadas ECEF(XYZ)) 
  * ~~Para uma esfera~~
  * ~~Para um cilindro~~
  * Para uma caixa
* ~~Inicialmente não será feita análise em tempo real nem usando DGPS, de forma a poder testar mais rapidamente os resultados, usando para tal um receptor GPS de smartphone a fazer logging da posição e detectar quando/onde foram feitas intrusões~~
* Numa primeira fase usar apenas uma área restrita para validar o algoritmo, criando áreas restritas adicionais posteriormente (e voltando a validar)
* ~~Criar um algoritmo que use o output do receptor GPS e dados de efemérides e pseudo-ranges pré-obtidos para determinar a posição~~
* Aplicar correções aos pseudo-ranges originais com dados da ground station pré-obtidos, com base no ficheiro RAW, efetivamente implementando DGPS
* Aplicar correções às distorções dos pseudo-ranges da ground station devido à atmosfera e outros, com base no ficheiro HUI
* Criar um algoritmo que receba o output do receptor GPS usando porta série e descodifique o resultado
* Testar os resultados do recetor DGPS em tempo real e compará-los com os resultados de GPS
* Testar o algoritmo (em tempo real) de forma a determinar a intrusão em apenas uma área restrita e posteriormente em mais que uma, com output gráfico de aviso de intrusão

## Stretch goals

* Obter a dinâmica do utilizador (velocidade, rumo) e originar aviso se, à velocidade actual, for entrar na zona restrita em menos de X segundos
* Criar um algoritmo para obter a informação da ground-station live
* Preparar um algoritmo que permita definir um volume arbitrário para a área restrita (em coordenadas ECEF(XYZ)) 
* Ter como opção de output um ficheiro KML desse volume
* Gerar um ficheiro KML com o percurso realizado e as áreas restritas, bem como tendo as intrusões devidamente identificadas

## Perguntar ao prof

* Sensor
* ~~Dados de ground station~~
  * ~~Set de testes para testar algoritmo (incluir dados do receptor móvel)~~
  * ~~Método de acesso aos dados da ground station real-time~~
* ~~Por que raio é que as coordenadas do poste estão uma dezena de metros abaixo do chão~~
* Porque é que alguns SVN do ficheiro RAW devolvem valores acima de 32
