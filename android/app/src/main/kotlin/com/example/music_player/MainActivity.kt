package com.example.music_player

import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.net.Uri
import android.media.MediaPlayer


class MainActivity: FlutterActivity() {
  private val CHANNEL = "midi.partmaster.de/player"
  private var currentPlayer : MediaPlayer? = null;
  private var pendingPlayer : MediaPlayer? = null;

  override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
        call, result ->
        if (call.method == "load") {
            val uriString :String? = call.argument("uri");
            if(uriString != null) {
                val uri = Uri.parse(uriString)
                result.success("Player.load($uri)")
                pendingPlayer = MediaPlayer.create(this, uri)
            }
            else {
                result.error("UNAVAILABLE", "no uri.", null)
            }
        } else if(call.method == "play") {
            if(pendingPlayer != null) {
                if(currentPlayer!=null) {
                    currentPlayer?.release()
                }
                currentPlayer = pendingPlayer;
                pendingPlayer = null;
                currentPlayer?.start()
                result.success("Player.play()")
            }
            else if(currentPlayer != null) {
                currentPlayer?.start()
                result.success("Player.play()")
            } else {
                result.error("UNAVAILABLE", "nothing loaded.", null)
            }
        } else if(call.method == "pause") {
            if(currentPlayer != null) {
                currentPlayer?.pause()
                result.success("Player.pause()")
            } else {
                result.error("UNAVAILABLE", "nothing loaded.", null)
            }
        } else if(call.method == "position") {
            if(currentPlayer != null) {
                result.success(currentPlayer?.currentPosition)
            } else {
                result.error("UNAVAILABLE", "nothing loaded.", null)
            }
        } else if(call.method == "dispose") {
            if(currentPlayer != null) {
                currentPlayer?.release()
                currentPlayer = null
            }
            if(pendingPlayer != null) {
                pendingPlayer?.release()
                pendingPlayer = null
            }
            result.success("Player.dispose()")
        } else {
            result.notImplemented()
        }
      }  
    }
}