<div align="center">

## Easter Egg

</div>

### Description 
- Plugin dodaje wielkanocne jajka które pojawiają się pod nogami z zabitej osoby
- Plugin posiada top10 zebranych jajek wielkanocnych ( /top10jajek )
- Zapis jajek wielkanocnych napisany jest pod fVault
- Plugin posiada dwie metody wczytywania top10 ( Na początku uruchomienia mapy lub za każdym razem po wpisaniu /top10jajek )
- w 14 linijce znajduje się `#define LOAD_METOD` i wystarczy to zakomentować aby zmienił się tryb wczytywania ) 
- Zakomentowany wczytuje za każdym razem po wpisaniu komendy

### Configure
<details>
  <summary><b>Cvar</b></summary>

```cfg
// Procent na drop Jajka
amxx4u_egg_drop_percent "100"

// Prędkość znikania Jajka
amxx4u_egg_speed_remove "3"

// Dystans podnoszenia Jajka
amxx4u_egg_distance_pickup "40.0"

```
</details>

### Screenshots

<details>
  <summary><b>Eggs</b></summary>

- MOTD

  <img src="https://raw.githubusercontent.com/KoRrNiK/easter-egg/main/assets/motd.png"></img>

- Game

  <img src="https://raw.githubusercontent.com/KoRrNiK/easter-egg/main/assets/game.png"></img>

- Chat

  <img src="https://raw.githubusercontent.com/KoRrNiK/easter-egg/main/assets/chat.png"></img>
</details>

### Requirements 
- AMXModX 1.9 / AMXModX 1.10
- ReHLDS 3.12.0.780
- ReAPI v5.21.0.252-dev
- ReGameDLL 5.21.0.556-dev
