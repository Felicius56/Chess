import 'package:flutter/material.dart';
import 'package:chess/chess.dart' as chess;

void main() => runApp(const ChessLumeApp());

const ink = Color(0xFF17231F);
const forest = Color(0xFF1E5B49);
const mint = Color(0xFFBDE7D5);
const cream = Color(0xFFF5F2E9);
const lightSquare = Color(0xFFE9E2D2);
const darkSquare = Color(0xFF729486);
const gold = Color(0xFFE9B95B);

class ChessLumeApp extends StatelessWidget {
  const ChessLumeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChessLume',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: cream,
        colorScheme: ColorScheme.fromSeed(seedColor: forest, brightness: Brightness.light),
        fontFamily: 'Roboto',
      ),
      home: const ChessHome(),
    );
  }
}

class ChessHome extends StatefulWidget {
  const ChessHome({super.key});

  @override
  State<ChessHome> createState() => _ChessHomeState();
}

class _ChessHomeState extends State<ChessHome> {
  chess.Chess game = chess.Chess();
  String? selected;
  List<String> legalTargets = [];
  final List<String> history = [];
  final List<chess.Chess> snapshots = [];
  bool flipped = false;
  bool showCoordinates = true;

  static const glyphs = {
    'K': '♔', 'Q': '♕', 'R': '♖', 'B': '♗', 'N': '♘', 'P': '♙',
    'k': '♚', 'q': '♛', 'r': '♜', 'b': '♝', 'n': '♞', 'p': '♟',
  };

  bool get gameOver => game.game_over;
  String get turnName => game.turn == chess.Color.WHITE ? 'Bianchi' : 'Neri';

  String get statusText {
    if (game.in_checkmate) return 'Scacco matto · ${game.turn == chess.Color.WHITE ? "vincono i Neri" : "vincono i Bianchi"}';
    if (game.in_stalemate) return 'Patta · stallo';
    if (game.in_draw) return 'Partita patta';
    if (game.in_check) return 'Scacco ai $turnName';
    return 'Tocca ai $turnName';
  }

  String squareAt(int displayRow, int displayCol) {
    final row = flipped ? displayRow : 7 - displayRow;
    final col = flipped ? 7 - displayCol : displayCol;
    return '${String.fromCharCode(97 + col)}${row + 1}';
  }

  void tapSquare(String sq) {
    if (gameOver) return;
    final piece = game.get(sq);
    if (selected == null) {
      if (piece != null && piece.color == game.turn) {
        setState(() {
          selected = sq;
          legalTargets = game.moves({'square': sq, 'verbose': true})
              .map<String>((m) => m['to'] as String).toList();
        });
      }
      return;
    }
    if (sq == selected) {
      setState(() { selected = null; legalTargets = []; });
      return;
    }
    if (piece != null && piece.color == game.turn) {
      setState(() {
        selected = sq;
        legalTargets = game.moves({'square': sq, 'verbose': true})
            .map<String>((m) => m['to'] as String).toList();
      });
      return;
    }
    final before = game.fen;
    final move = game.move({'from': selected, 'to': sq, 'promotion': 'q'});
    if (move != null) {
      snapshots.add(chess.Chess.fromFEN(before));
      final san = move['san']?.toString() ?? '$selected–$sq';
      setState(() {
        history.add(san);
        selected = null;
        legalTargets = [];
      });
    } else {
      setState(() { selected = null; legalTargets = []; });
    }
  }

  void undo() {
    if (snapshots.isEmpty) return;
    setState(() {
      game = snapshots.removeLast();
      if (history.isNotEmpty) history.removeLast();
      selected = null;
      legalTargets = [];
    });
  }

  void newGame() {
    setState(() {
      game = chess.Chess();
      history.clear();
      snapshots.clear();
      selected = null;
      legalTargets = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context).width;
    final boardSize = (size - 32).clamp(280.0, 560.0);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                Row(children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(color: forest, borderRadius: BorderRadius.circular(15)),
                    child: const Icon(Icons.grid_4x4_rounded, color: mint, size: 25),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('ChessLume', style: TextStyle(fontSize: 23, fontWeight: FontWeight.w800, color: ink, letterSpacing: -0.6)),
                    Text('Gioca con calma. Pensa in grande.', style: TextStyle(fontSize: 12, color: Colors.black54)),
                  ])),
                  IconButton(
                    tooltip: 'Inverti scacchiera',
                    onPressed: () => setState(() => flipped = !flipped),
                    icon: const Icon(Icons.swap_vert_rounded),
                  ),
                ]),
                const SizedBox(height: 22),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: forest,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [BoxShadow(color: forest.withOpacity(.16), blurRadius: 22, offset: const Offset(0, 9))],
                  ),
                  child: Row(children: [
                    Container(
                      width: 42, height: 42,
                      decoration: BoxDecoration(color: Colors.white.withOpacity(.12), borderRadius: BorderRadius.circular(14)),
                      child: Icon(game.in_check ? Icons.warning_amber_rounded : Icons.spa_rounded, color: game.in_check ? gold : mint),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(statusText, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                      const SizedBox(height: 3),
                      Text(gameOver ? 'Avvia una nuova partita per continuare.' : 'Partita locale · due giocatori', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    ])),
                    if (game.in_check) const Icon(Icons.bolt_rounded, color: gold),
                  ]),
                ),
                const SizedBox(height: 16),
                Center(
                  child: SizedBox(
                    width: boardSize,
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.zero,
                          itemCount: 64,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8),
                          itemBuilder: (context, index) {
                            final row = index ~/ 8;
                            final col = index % 8;
                            final sq = squareAt(row, col);
                            final piece = game.get(sq);
                            final isLight = ((row + col) % 2 == 0);
                            final isSelected = selected == sq;
                            final isTarget = legalTargets.contains(sq);
                            final isLast = history.isNotEmpty && false;
                            final bg = isSelected ? gold : (isLight ? lightSquare : darkSquare);
                            return GestureDetector(
                              onTap: () => tapSquare(sq),
                              child: Container(
                                color: bg,
                                child: Stack(children: [
                                  if (showCoordinates && col == 0)
                                    Positioned(left: 3, top: 1, child: Text('${8-row}', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: isLight ? darkSquare : lightSquare))),
                                  if (showCoordinates && row == 7)
                                    Positioned(right: 3, bottom: 0, child: Text(String.fromCharCode(97 + (flipped ? 7-col : col)), style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: isLight ? darkSquare : lightSquare))),
                                  if (isTarget)
                                    Center(child: Container(
                                      width: piece == null ? 13 : 35,
                                      height: piece == null ? 13 : 35,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: piece == null ? ink.withOpacity(.28) : Colors.transparent,
                                        border: piece == null ? null : Border.all(color: ink.withOpacity(.38), width: 3),
                                      ),
                                    )),
                                  if (piece != null)
                                    Center(child: Text(
                                      glyphs[piece.type == chess.PieceType.KING ? (piece.color == chess.Color.WHITE ? 'K' : 'k') :
                                        piece.type == chess.PieceType.QUEEN ? (piece.color == chess.Color.WHITE ? 'Q' : 'q') :
                                        piece.type == chess.PieceType.ROOK ? (piece.color == chess.Color.WHITE ? 'R' : 'r') :
                                        piece.type == chess.PieceType.BISHOP ? (piece.color == chess.Color.WHITE ? 'B' : 'b') :
                                        piece.type == chess.PieceType.KNIGHT ? (piece.color == chess.Color.WHITE ? 'N' : 'n') :
                                        (piece.color == chess.Color.WHITE ? 'P' : 'p')] ?? '',
                                      style: TextStyle(
                                        fontSize: boardSize / 10.3,
                                        height: 1,
                                        color: piece.color == chess.Color.WHITE ? const Color(0xFFFFFEF8) : const Color(0xFF17231F),
                                        shadows: piece.color == chess.Color.WHITE
                                          ? [const Shadow(color: Color(0xFF34443E), blurRadius: 2, offset: Offset(0, 1))]
                                          : null,
                                      ),
                                    )),
                                ]),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(children: [
                  Expanded(child: OutlinedButton.icon(
                    onPressed: snapshots.isEmpty ? null : undo,
                    icon: const Icon(Icons.undo_rounded),
                    label: const Text('Annulla'),
                  )),
                  const SizedBox(width: 10),
                  Expanded(child: FilledButton.icon(
                    onPressed: newGame,
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Nuova partita'),
                  )),
                ]),
                const SizedBox(height: 22),
                Row(children: [
                  const Expanded(child: Text('Cronologia', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: ink))),
                  Text('${history.length} mosse', style: const TextStyle(color: Colors.black54, fontSize: 12)),
                ]),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
                  child: history.isEmpty
                    ? const Text('Le mosse appariranno qui. Tocca un pezzo per vedere le mosse legali.', style: TextStyle(color: Colors.black54, fontSize: 13))
                    : Wrap(
                        spacing: 8, runSpacing: 8,
                        children: List.generate(history.length, (i) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                          decoration: BoxDecoration(color: i.isEven ? mint.withOpacity(.55) : cream, borderRadius: BorderRadius.circular(9)),
                          child: Text('${i ~/ 2 + 1}${i.isEven ? "." : "..."} ${history[i]}', style: const TextStyle(color: ink, fontWeight: FontWeight.w600, fontSize: 12)),
                        )),
                      ),
                ),
                const SizedBox(height: 18),
                const Center(child: Text('CHESSLUME  •  MVP 0.1', style: TextStyle(color: Colors.black38, fontSize: 10, letterSpacing: 1.5))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
