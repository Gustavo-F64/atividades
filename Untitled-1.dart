import 'dart:io' show stdin; // Importa todas as funcionalidades de dart:io, incluindo stdin e stdout.
import 'dart:math';

/// Classe base abstrata para todos os personagens no jogo (Cavaleiro, Monstro).
abstract class Character {
  String name;
  int health;
  int maxHealth;
  int attackPower;

  /// Construtor para a classe Character.
  /// Define o nome, a vida máxima e o poder de ataque do personagem.
  Character(this.name, this.maxHealth, this.attackPower) : health = maxHealth;

  /// Aplica dano ao personagem.
  /// Reduz a vida do personagem e garante que não seja negativa.
  void takeDamage(int damage) {
    health -= damage;
    if (health < 0) {
      health = 0;
    }
    print('$name sofreu $damage de dano. Vida atual: $health/${maxHealth} HP');
  }

  /// Verifica se o personagem ainda está vivo.
  bool isAlive() => health > 0;

  /// Exibe as estatísticas atuais do personagem.
  void displayStats() {
    // Representa a vida visualmente com corações.
    final hearts = '❤️' * (health ~/ (maxHealth / 10));
    print('$name: $hearts $health/${maxHealth} HP');
  }
}

/// Representa o personagem jogável, o Cavaleiro.
class Knight extends Character {
  int defensePower;
  bool isDefending = false;

  /// Construtor para a classe Knight.
  /// Adiciona poder de defesa específico do cavaleiro.
  Knight(String name, int maxHealth, int attackPower, this.defensePower)
    : super(name, maxHealth, attackPower);

  /// Realiza um ataque contra um alvo.
  void attack(Character target) {
    print('$name ataca ${target.name} com sua espada!');
    target.takeDamage(
      attackPower + Random().nextInt(5),
    ); // Pequena variação no ataque
  }

  /// Ativa o modo de defesa do cavaleiro.
  void defend() {
    isDefending = true;
    print('$name levanta o escudo para se defender!');
  }

  /// Sobrescreve o método takeDamage para aplicar a defesa do escudo.
  @override
  void takeDamage(int damage) {
    int finalDamage = damage;
    if (isDefending) {
      finalDamage = max(
        0,
        damage - defensePower - Random().nextInt(3),
      ); // Reduz dano com defesa
      print('$name defendeu parte do ataque com seu escudo!');
    }
    super.takeDamage(finalDamage);
    isDefending = false; // O escudo defende por apenas um turno
  }

  /// Permite que o cavaleiro se cure.
  void heal(int amount) {
    health = min(maxHealth, health + amount);
    print('$name recuperou $amount de HP. Vida atual: $health/${maxHealth} HP');
  }
}

/// Representa um inimigo, o Monstro.
class Monster extends Character {
  String description;

  /// Construtor para a classe Monster.
  Monster(String name, int maxHealth, int attackPower, this.description)
    : super(name, maxHealth, attackPower);

  /// Realiza um ataque contra um alvo.
  void attack(Character target) {
    print('$name ($description) ataca ${target.name}!');
    target.takeDamage(
      attackPower + Random().nextInt(5),
    ); // Pequena variação no ataque
  }
}

/// Enumeração para representar os estados do jogo.
enum GameState {
  exploring, // O jogador está explorando o mundo
  combat, // O jogador está em combate com um monstro
  gameOver, // O jogo terminou
}

/// Gerencia a lógica principal do jogo.
class Game {
  Knight player;
  Monster? currentEnemy; // O monstro atual em combate
  GameState state = GameState.exploring;
  Random random = Random();

  // Lista de monstros disponíveis para encontros.
  List<Monster> availableMonsters = [
    Monster('Goblin', 40, 10, 'Um pequeno e astuto Goblin'),
    Monster('Ogre', 80, 20, 'Um grande e raivoso Ogre'),
    Monster('Slime', 30, 8, 'Uma criatura gosmenta e lenta'),
    Monster('Wolf', 50, 12, 'Um lobo faminto'),
    Monster(
      'Esqueleto',
      60,
      15,
      'Um Esqueleto reanimado, empunhando uma espada quebrada',
    ),
  ];

  /// Construtor do jogo, recebe o cavaleiro como jogador.
  Game(this.player);

  /// Inicia o loop principal do jogo.
  void start() {
    print('Bem-vindo, Cavaleiro ${player.name}, à sua aventura!');
    print('Você pode usar \'w\' para avançar e explorar.');
    print(
      'Durante o combate, use \'e\' para atacar, \'q\' para defender, ou \'w\' para tentar fugir.',
    );
    print('\nPressione Enter para começar...');
    stdin.readLineSync(); // Aguarda o jogador pressionar Enter

    // Loop principal do jogo, continua enquanto o jogo não estiver no estado gameOver.
    while (state != GameState.gameOver) {
      _gameLoop();
    }
    print('\nFim de jogo. Obrigado por jogar!');
  }

  /// Controla a lógica para cada estado do jogo.
  void _gameLoop() {
    switch (state) {
      case GameState.exploring:
        _explore();
        break;
      case GameState.combat:
        _combatTurn();
        break;
      case GameState.gameOver:
        // O loop 'while' em `start()` já trata isso.
        break;
    }
  }

  /// Lógica quando o jogador está explorando.
  void _explore() {
    print('\n--- Explorando ---');
    player.displayStats();
    print('O que você quer fazer? (W: Avançar, Q: Descansar, S: Sair do Jogo)');
    String? input = stdin.readLineSync()?.toLowerCase();

    switch (input) {
      case 'w':
        print('Você avança pelos caminhos desconhecidos...');
        if (random.nextInt(100) < 65) {
          // 65% de chance de encontrar um monstro
          _encounterMonster();
        } else {
          print('Nada de interessante por enquanto. Você continua a andar.');
          // Pequena chance de curar ao avançar, se não estiver com vida cheia.
          if (player.health < player.maxHealth) {
            int healAmount = random.nextInt(5) + 3; // Cura 3-7 HP
            player.heal(healAmount);
          }
        }
        break;
      case 'q':
        print(
          'Você decide encontrar um local seguro para descansar e se recuperar.',
        );
        if (player.health < player.maxHealth) {
          int healAmount =
              random.nextInt(15) + 10; // Cura 10-24 HP ao descansar
          player.heal(healAmount);
        } else {
          print('Sua vida já está cheia. Você espera pacientemente.');
        }
        break;
      case 's':
        print('Você decide parar sua aventura por aqui. Adeus, Cavaleiro.');
        state = GameState.gameOver;
        break;
      default:
        print('Comando inválido. Tente novamente.');
    }
  }

  /// Lógica para iniciar um encontro com um monstro.
  void _encounterMonster() {
    // Escolhe um monstro aleatório e reinicia sua vida para o máximo.
    currentEnemy = availableMonsters[random.nextInt(availableMonsters.length)];
    currentEnemy!.health = currentEnemy!.maxHealth;
    print('\n--- ENCONTRO! ---');
    print(
      'Você encontrou um ${currentEnemy!.name}! (${currentEnemy!.description})',
    );
    state = GameState.combat; // Muda o estado para combate
  }

  /// Lógica para um turno de combate.
  void _combatTurn() {
    if (currentEnemy == null || !currentEnemy!.isAlive()) {
      print('Não há inimigo para combater. O combate terminou.');
      state = GameState.exploring;
      return;
    }

    print('\n--- COMBATE! ---');
    player.displayStats();
    currentEnemy!.displayStats();
    print('O que você vai fazer? (E: Atacar, Q: Defender, W: Fugir)');
    String? input = stdin.readLineSync()?.toLowerCase();

    // Turno do jogador
    switch (input) {
      case 'e':
        player.attack(currentEnemy!);
        break;
      case 'q':
        player.defend();
        break;
      case 'w':
        print('Você tenta fugir...');
        if (random.nextInt(100) < 40) {
          // 40% de chance de fugir
          print('Você conseguiu fugir do ${currentEnemy!.name}!');
          currentEnemy = null; // Limpa o inimigo
          state = GameState.exploring;
          return; // Pula o turno do inimigo
        } else {
          print('Você falhou em fugir e o ${currentEnemy!.name} te alcança!');
          // O inimigo ainda atacará.
        }
        break;
      default:
        print('Comando inválido. Tente novamente.');
        return; // Pede a entrada novamente neste turno
    }

    // Verifica se o inimigo foi derrotado após o ataque do jogador.
    if (currentEnemy != null && !currentEnemy!.isAlive()) {
      print('\nVocê derrotou o ${currentEnemy!.name}!');
      print('Você ganhou uma pequena quantidade de vida por sua vitória!');
      int healAmount =
          random.nextInt(player.attackPower ~/ 3) +
          5; // Cura com base no poder de ataque
      player.heal(healAmount);
      currentEnemy = null; // Limpa o inimigo
      state = GameState.exploring; // Volta a explorar
      return;
    }

    // Turno do inimigo (se o inimigo ainda estiver vivo e não houver fuga)
    if (currentEnemy != null) {
      currentEnemy!.attack(player);
    }

    // Verifica se o jogador foi derrotado.
    if (!player.isAlive()) {
      print('\n${player.name} foi derrotado em combate!');
      state = GameState.gameOver;
      return;
    }
  }
}

/// Função principal que inicia o jogo.
void main() {
  print('Digite o nome do seu Cavaleiro: ');
  String? knightName = stdin.readLineSync();
  if (knightName == null || knightName.trim().isEmpty) {
    knightName = 'Sir Valiant'; // Nome padrão se nada for inserido
    print('Nenhum nome inserido. Seu cavaleiro se chamará $knightName.');
  }

  // Cria o personagem do jogador com atributos iniciais.
  var playerKnight = Knight(
    knightName,
    100,
    20,
    10,
  ); // Nome, Vida, Ataque, Defesa
  var game = Game(playerKnight); // Cria uma nova instância do jogo
  game.start(); // Inicia o jogo
}