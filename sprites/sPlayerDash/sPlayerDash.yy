{
  "$GMSprite": "v2",
  "%Name": "sPlayerDash",
  "bboxMode": 2,
  "bbox_bottom": 31,
  "bbox_left": 6,
  "bbox_right": 25,
  "bbox_top": 8,
  "collisionKind": 1,
  "collisionTolerance": 0,
  "DynamicTexturePage": false,
  "edgeFiltering": false,
  "For3D": false,
  "frames": [
    {
      "$GMSpriteFrame": "v1",
      "%Name": "6855e0c0-ca4b-47a7-9604-2d62bf75d301",
      "name": "6855e0c0-ca4b-47a7-9604-2d62bf75d301",
      "resourceType": "GMSpriteFrame",
      "resourceVersion": "2.0"
    },
    {
      "$GMSpriteFrame": "v1",
      "%Name": "982b7dc5-d0ba-41fe-bc4f-17f6ed3283e1",
      "name": "982b7dc5-d0ba-41fe-bc4f-17f6ed3283e1",
      "resourceType": "GMSpriteFrame",
      "resourceVersion": "2.0"
    },
    {
      "$GMSpriteFrame": "v1",
      "%Name": "3c0eee19-bcac-4ceb-af0a-fffc7c98025d",
      "name": "3c0eee19-bcac-4ceb-af0a-fffc7c98025d",
      "resourceType": "GMSpriteFrame",
      "resourceVersion": "2.0"
    }
  ],
  "gridX": 2,
  "gridY": 2,
  "height": 32,
  "HTile": false,
  "layers": [
    {
      "$GMImageLayer": "",
      "%Name": "f6070a68-f3a9-4d78-9941-abc8fd67334c",
      "blendMode": 0,
      "displayName": "default",
      "isLocked": false,
      "name": "f6070a68-f3a9-4d78-9941-abc8fd67334c",
      "opacity": 100.0,
      "resourceType": "GMImageLayer",
      "resourceVersion": "2.0",
      "visible": true
    }
  ],
  "name": "sPlayerDash",
  "nineSlice": null,
  "origin": 4,
  "parent": {
    "name": "Player",
    "path": "folders/Sprites/Player.yy"
  },
  "preMultiplyAlpha": false,
  "resourceType": "GMSprite",
  "resourceVersion": "2.0",
  "sequence": {
    "$GMSequence": "v1",
    "%Name": "sPlayerDash",
    "autoRecord": true,
    "backdropHeight": 768,
    "backdropImageOpacity": 0.5,
    "backdropImagePath": "",
    "backdropWidth": 1366,
    "backdropXOffset": 0.0,
    "backdropYOffset": 0.0,
    "events": {
      "$KeyframeStore<MessageEventKeyframe>": "",
      "Keyframes": [],
      "resourceType": "KeyframeStore<MessageEventKeyframe>",
      "resourceVersion": "2.0"
    },
    "eventStubScript": null,
    "eventToFunction": {},
    "length": 3.0,
    "lockOrigin": false,
    "moments": {
      "$KeyframeStore<MomentsEventKeyframe>": "",
      "Keyframes": [],
      "resourceType": "KeyframeStore<MomentsEventKeyframe>",
      "resourceVersion": "2.0"
    },
    "name": "sPlayerDash",
    "playback": 1,
    "playbackSpeed": 16.0,
    "playbackSpeedType": 0,
    "resourceType": "GMSequence",
    "resourceVersion": "2.0",
    "showBackdrop": true,
    "showBackdropImage": false,
    "timeUnits": 1,
    "tracks": [
      {
        "$GMSpriteFramesTrack": "",
        "builtinName": 0,
        "events": [],
        "inheritsTrackColour": true,
        "interpolation": 1,
        "isCreationTrack": false,
        "keyframes": {
          "$KeyframeStore<SpriteFrameKeyframe>": "",
          "Keyframes": [
            {
              "$Keyframe<SpriteFrameKeyframe>": "",
              "Channels": {
                "0": {
                  "$SpriteFrameKeyframe": "",
                  "Id": {
                    "name": "6855e0c0-ca4b-47a7-9604-2d62bf75d301",
                    "path": "sprites/sPlayerDash/sPlayerDash.yy"
                  },
                  "resourceType": "SpriteFrameKeyframe",
                  "resourceVersion": "2.0"
                }
              },
              "Disabled": false,
              "id": "98ee0895-7274-4af9-94aa-b70558d8e81e",
              "IsCreationKey": false,
              "Key": 0.0,
              "Length": 1.0,
              "resourceType": "Keyframe<SpriteFrameKeyframe>",
              "resourceVersion": "2.0",
              "Stretch": false
            },
            {
              "$Keyframe<SpriteFrameKeyframe>": "",
              "Channels": {
                "0": {
                  "$SpriteFrameKeyframe": "",
                  "Id": {
                    "name": "982b7dc5-d0ba-41fe-bc4f-17f6ed3283e1",
                    "path": "sprites/sPlayerDash/sPlayerDash.yy"
                  },
                  "resourceType": "SpriteFrameKeyframe",
                  "resourceVersion": "2.0"
                }
              },
              "Disabled": false,
              "id": "53c85d41-bc8a-4c22-9527-b71cf5faf237",
              "IsCreationKey": false,
              "Key": 1.0,
              "Length": 1.0,
              "resourceType": "Keyframe<SpriteFrameKeyframe>",
              "resourceVersion": "2.0",
              "Stretch": false
            },
            {
              "$Keyframe<SpriteFrameKeyframe>": "",
              "Channels": {
                "0": {
                  "$SpriteFrameKeyframe": "",
                  "Id": {
                    "name": "3c0eee19-bcac-4ceb-af0a-fffc7c98025d",
                    "path": "sprites/sPlayerDash/sPlayerDash.yy"
                  },
                  "resourceType": "SpriteFrameKeyframe",
                  "resourceVersion": "2.0"
                }
              },
              "Disabled": false,
              "id": "780e3766-5312-4671-9e6f-fd95a7e9d7d6",
              "IsCreationKey": false,
              "Key": 2.0,
              "Length": 1.0,
              "resourceType": "Keyframe<SpriteFrameKeyframe>",
              "resourceVersion": "2.0",
              "Stretch": false
            }
          ],
          "resourceType": "KeyframeStore<SpriteFrameKeyframe>",
          "resourceVersion": "2.0"
        },
        "modifiers": [],
        "name": "frames",
        "resourceType": "GMSpriteFramesTrack",
        "resourceVersion": "2.0",
        "spriteId": null,
        "trackColour": 0,
        "tracks": [],
        "traits": 0
      }
    ],
    "visibleRange": null,
    "volume": 1.0,
    "xorigin": 16,
    "yorigin": 16
  },
  "swatchColours": null,
  "swfPrecision": 0.5,
  "textureGroupId": {
    "name": "Default",
    "path": "texturegroups/Default"
  },
  "type": 0,
  "VTile": false,
  "width": 32
}
