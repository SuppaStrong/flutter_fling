import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fling/remote_media_player.dart';

enum PlayerDiscoveryStatus { Found, Lost }

enum MediaState {
  NoSource,
  PreparingMedia,
  ReadyToPlay,
  Playing,
  Paused,
  Seeking,
  Finished,
  Error
}

enum MediaCondition {
  Good,
  WarningContent,
  WarningBandwidth,
  ErrorContent,
  ErrorChannel,
  ErrorUnknown
}

typedef DiscoveryCallback = void Function(
    PlayerDiscoveryStatus status, RemoteMediaPlayer player);

typedef PlayerStateCallback = void Function(
    MediaState state, MediaCondition condition, int position);

class FlutterFling {
  static const MethodChannel _channel = MethodChannel('flutter_fling');
  static const EventChannel _discoveryControllerChannel =
      EventChannel('flutter_fling/discoveryControllerStream');
  static const EventChannel _playerStateChannel =
      EventChannel('flutter_fling/playerStateStream');

  static Future<void> startDiscoveryController(
      DiscoveryCallback callback) async {
    try {
      await _channel.invokeMethod('startDiscoveryController');

      _discoveryControllerChannel.receiveBroadcastStream().listen((json) {
        debugPrint(json.toString());
        callback(
            json['event'] == 'found'
                ? PlayerDiscoveryStatus.Found
                : PlayerDiscoveryStatus.Lost,
            RemoteMediaPlayer.fromJson(json));
      });
    } on PlatformException catch (e) {
      debugPrint('Error starting discovery: ${e.details}');
    }
  }

  static Future<void> play(PlayerStateCallback callback,
      {required String mediaUri,
      required String mediaTitle,
      required RemoteMediaPlayer player}) async {
    try {
      await _channel.invokeMethod('play', <String, dynamic>{
        'mediaSourceUri': mediaUri,
        'mediaSourceTitle': mediaTitle,
        'deviceUid': player.uid
      });
      _playerStateChannel.receiveBroadcastStream().listen((json) {
        callback(
            MediaState.values.firstWhere(
                (value) => value.toString() == 'MediaState.' + json['state']),
            MediaCondition.values.firstWhere((value) =>
                value.toString() == 'MediaCondition.' + json['condition']),
            json['position']);
      });
    } on PlatformException catch (e) {
      debugPrint('Error playing media: ${e.details}');
    }
  }

  static Future<void> removePlayerListener() async {
    try {
      await _channel.invokeMethod('removePlayerListener');
    } on PlatformException catch (e) {
      debugPrint('Error removing player listener: ${e.details}');
    }
  }

  static Future<void> stopDiscoveryController() async {
    try {
      await _channel.invokeMethod('stopDiscoveryController');
    } on PlatformException catch (e) {
      debugPrint('Error stopping discovery: ${e.details}');
    }
  }

  static Future<RemoteMediaPlayer?> get selectedPlayer async {
    try {
      final player = await _channel.invokeMethod('getSelectedPlayer');
      return player != null ? RemoteMediaPlayer.fromJson(player) : null;
    } on PlatformException catch (e) {
      debugPrint('Error getting selected player: ${e.details}');
      return null;
    }
  }

  static Future<void> stopPlayer() async {
    try {
      await _channel.invokeMethod('stopPlayer');
    } on PlatformException catch (e) {
      debugPrint('Error stopping player: ${e.details}');
    }
  }

  static Future<void> pausePlayer() async {
    try {
      await _channel.invokeMethod('pausePlayer');
    } on PlatformException catch (e) {
      debugPrint('Error pausing player: ${e.details}');
    }
  }

  static Future<void> playPlayer() async {
    try {
      await _channel.invokeMethod('playPlayer');
    } on PlatformException catch (e) {
      debugPrint('Error playing player: ${e.details}');
    }
  }

  static Future<void> mutePlayer(bool muteState) async {
    try {
      await _channel.invokeMethod('mutePlayer',
          <String, dynamic>{'muteState': muteState.toString()});
    } on PlatformException catch (e) {
      debugPrint('Error muting player: ${e.details}');
    }
  }

  static Future<void> seekForwardPlayer() async {
    try {
      await _channel.invokeMethod('seekForwardPlayer');
    } on PlatformException catch (e) {
      debugPrint('Error seeking forward: ${e.details}');
    }
  }

  static Future<void> seekBackPlayer() async {
    try {
      await _channel.invokeMethod('seekBackPlayer');
    } on PlatformException catch (e) {
      debugPrint('Error seeking back: ${e.details}');
    }
  }

  static Future<void> seekToPlayer({required int position}) async {
    try {
      await _channel.invokeMethod(
          'seekToPlayer', <String, String>{'position': position.toString()});
    } on PlatformException catch (e) {
      debugPrint('Error seeking to position: ${e.details}');
    }
  }
}