import 'package:ocarina/ocarina.dart';

class Player {
  OcarinaPlayer? currentPlayer;
  OcarinaPlayer? pendingPlayer;
  Future<void> load(filePath) {
    pendingPlayer = OcarinaPlayer(filePath: filePath);
    return pendingPlayer?.load() ?? Future.value(null);
  }
  Future<void> play(){
    if (pendingPlayer != null) {
      if (currentPlayer != null) {
        currentPlayer?.dispose();
        
      }
      currentPlayer = pendingPlayer;
      pendingPlayer = null;

    }
    return currentPlayer?.play()  ?? Future.value(null);
  }
  Future<void> pause(){
    return currentPlayer?.pause() ?? Future.value(null);
  }
  void dispose() {
    currentPlayer?.dispose();
    currentPlayer = null;
    pendingPlayer?.dispose();
    pendingPlayer = null;
  }
  Future<int> position() {
    return currentPlayer?.position() ?? Future.value(0);
  }
  bool isLoaded() {
    currentPlayer?.load();
    return currentPlayer?.isLoaded() ?? false;
  }
  Future<void> seek(Duration duration) {
    return currentPlayer?.seek(duration) ?? Future.value(null);
  }
}